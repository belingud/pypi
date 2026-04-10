#!/usr/bin/env zsh
# pypi plugin to handle PyPI mirrors for oh-my-zsh

pypi() {
  local help="Usage: pypi <command> [options]

Commands:
  list                       List all supported PyPI mirrors and their URLs.
  use <shortname> [target]   Switch to a specified PyPI mirror.
  ping <shortname|url>       Check network connectivity to a specified PyPI mirror or URL.
  cur [target]               Print current pip and/or uv index settings.

Targets:
  --pip                      Update or show pip only (default).
  --uv                       Update or show uv user-level config only.
  --all                      Update or show both pip and uv.

Options:
  -h, --help                 Show this help message and exit.

Examples:
  pypi list
  pypi use aliyun
  pypi use aliyun --uv
  pypi use aliyun --all
  pypi ping tsinghua
  pypi ping https://pypi.org/simple/
  pypi cur
  pypi cur --all

Note:
  The 'ping' command can accept either a mirror shortname or a direct URL.
  The 'use' command requires a valid shortname from the list of supported mirrors.
  uv updates only the user-level config file: \${XDG_CONFIG_HOME:-~/.config}/uv/uv.toml.
  Project-level uv config, environment variables, and CLI options can override user-level settings."

  print_help() {
    echo "$help"
  }

  mirror_index_url() {
    local shortname=$1

    case $shortname in
    pypi) echo "https://pypi.org/simple/" ;;
    aliyun) echo "https://mirrors.aliyun.com/pypi/simple/" ;;
    tencent) echo "https://mirrors.cloud.tencent.com/pypi/simple/" ;;
    163) echo "https://mirrors.163.com/pypi/simple/" ;;
    volces) echo "https://mirrors.volces.com/pypi/simple/" ;;
    huawei) echo "https://repo.huaweicloud.com/repository/pypi/simple/" ;;
    testpypi) echo "https://test.pypi.org/simple/" ;;
    cernet) echo "https://mirrors.cernet.edu.cn/pypi/web/simple/" ;;
    tsinghua) echo "https://pypi.tuna.tsinghua.edu.cn/simple/" ;;
    sustech) echo "https://mirrors.sustech.edu.cn/pypi/web/simple/" ;;
    bfsu) echo "https://mirrors.bfsu.edu.cn/pypi/web/simple/" ;;
    nju) echo "https://mirror.nju.edu.cn/pypi/web/simple/" ;;
    pku) echo "https://mirrors.pku.edu.cn/pypi/web/simple/" ;;
    njtech) echo "https://mirrors.njtech.edu.cn/pypi/web/simple/" ;;
    nyist) echo "https://mirrors.njtech.edu.cn/pypi/web/simple/" ;;
    sjtu) echo "https://mirror.sjtu.edu.cn/pypi/web/simple/" ;;
    jlu) echo "https://mirrors.jlu.edu.cn/pypi/web/simple/" ;;
    nwafu) echo "https://mirrors.nwafu.edu.cn/pypi/" ;;
    *) return 1 ;;
    esac
  }

  mirror_host_from_url() {
    local url=$1
    local host=$url

    host=${host#https://}
    host=${host#http://}
    echo "${host%%/*}"
  }

  uv_config_file() {
    local config_home=${XDG_CONFIG_HOME:-$HOME/.config}
    echo "${config_home}/uv/uv.toml"
  }

  parse_target_flags() {
    local default_target=$1
    shift

    local target=""
    local arg

    for arg in "$@"; do
      case $arg in
      --pip|--uv|--all)
        if [[ -n $target && $target != ${arg#--} ]]; then
          echo "Error: --pip, --uv, and --all are mutually exclusive." >&2
          return 1
        fi
        target=${arg#--}
        ;;
      *)
        echo "Error: Unknown option: $arg" >&2
        return 1
        ;;
      esac
    done

    if [[ -z $target ]]; then
      target=$default_target
    fi

    echo "$target"
  }

  write_pip_index() {
    local index_url=$1
    local trusted_host

    trusted_host=$(mirror_host_from_url "$index_url")

    pip config set global.index-url "$index_url" >/dev/null &&
      pip config set install.trusted-host "$trusted_host" >/dev/null
  }

  write_uv_index() {
    local index_url=$1
    local config_file config_dir
    local base_file pip_file tmp_file

    config_file=$(uv_config_file)
    config_dir=${config_file:h}

    mkdir -p "$config_dir" || {
      echo "Error: failed to create uv config directory: $config_dir" >&2
      return 1
    }

    base_file=$(mktemp "${TMPDIR:-/tmp}/pypi-uv-base.XXXXXX") || return 1
    pip_file=$(mktemp "${TMPDIR:-/tmp}/pypi-uv-pip.XXXXXX") || {
      rm -f "$base_file"
      return 1
    }
    tmp_file=$(mktemp "${TMPDIR:-/tmp}/pypi-uv-final.XXXXXX") || {
      rm -f "$base_file" "$pip_file"
      return 1
    }

    if [[ -f $config_file ]]; then
      awk -v base_file="$base_file" -v pip_file="$pip_file" '
        function base_out(line) {
          print line >> base_file
        }

        function pip_out(line) {
          print line >> pip_file
        }

        BEGIN {
          section = "root"
        }

        {
          line = $0

          if (line ~ /^[[:space:]]*\[\[index\]\][[:space:]]*(#.*)?$/) {
            section = "index"
            next
          }

          if (line ~ /^[[:space:]]*\[pip\][[:space:]]*(#.*)?$/) {
            section = "pip"
            next
          }

          if (line ~ /^[[:space:]]*\[[^][]+\][[:space:]]*(#.*)?$/ || line ~ /^[[:space:]]*\[\[[^][]+\]\][[:space:]]*(#.*)?$/) {
            section = "other"
            base_out(line)
            next
          }

          if (section == "index") {
            next
          }

          if (section == "pip") {
            if (line ~ /^[[:space:]]*(index-url|extra-index-url)[[:space:]]*=/) {
              next
            }
            pip_out(line)
            next
          }

          if (section == "root" && line ~ /^[[:space:]]*(index-url|extra-index-url)[[:space:]]*=/) {
            next
          }

          base_out(line)
        }
      ' "$config_file" || {
        rm -f "$base_file" "$pip_file" "$tmp_file"
        echo "Error: failed to parse existing uv config: $config_file" >&2
        return 1
      }
    else
      : > "$base_file"
      : > "$pip_file"
    fi

    if [[ -s $base_file ]]; then
      cat "$base_file" > "$tmp_file"
      printf "\n" >> "$tmp_file"
    else
      : > "$tmp_file"
    fi

    cat <<EOF >> "$tmp_file"
[[index]]
url = "$index_url"
default = true

[pip]
EOF

    if [[ -s $pip_file ]]; then
      cat "$pip_file" >> "$tmp_file"
    fi

    printf 'index-url = "%s"\n' "$index_url" >> "$tmp_file"

    mv "$tmp_file" "$config_file" || {
      rm -f "$base_file" "$pip_file" "$tmp_file"
      echo "Error: failed to update uv config: $config_file" >&2
      return 1
    }

    rm -f "$base_file" "$pip_file"
  }

  read_uv_default_index() {
    local config_file

    config_file=$(uv_config_file)
    [[ -f $config_file ]] || return 0

    awk '
      function trim(value) {
        sub(/^[[:space:]]+/, "", value)
        sub(/[[:space:]]+$/, "", value)
        return value
      }

      function parse_string(line) {
        sub(/^[^=]*=[[:space:]]*/, "", line)
        sub(/[[:space:]]+#.*$/, "", line)
        line = trim(line)
        if (line ~ /^".*"$/ || line ~ /^'\''.*'\''$/) {
          line = substr(line, 2, length(line) - 2)
        }
        return line
      }

      function parse_bool(line) {
        sub(/^[^=]*=[[:space:]]*/, "", line)
        sub(/[[:space:]]+#.*$/, "", line)
        line = tolower(trim(line))
        return line == "true"
      }

      function flush_index() {
        if (default_index == "" && index_default && index_url != "") {
          default_index = index_url
        }
        index_url = ""
        index_default = 0
      }

      BEGIN {
        section = "root"
        default_index = ""
        top_level_index = ""
        index_url = ""
        index_default = 0
      }

      {
        line = $0

        if (line ~ /^[[:space:]]*\[\[index\]\][[:space:]]*(#.*)?$/) {
          if (section == "index") {
            flush_index()
          }
          section = "index"
          next
        }

        if (line ~ /^[[:space:]]*\[[^][]+\][[:space:]]*(#.*)?$/ || line ~ /^[[:space:]]*\[\[[^][]+\]\][[:space:]]*(#.*)?$/) {
          if (section == "index") {
            flush_index()
          }
          section = "other"
        }

        if (section == "index") {
          if (line ~ /^[[:space:]]*url[[:space:]]*=/) {
            index_url = parse_string(line)
          } else if (line ~ /^[[:space:]]*default[[:space:]]*=/) {
            index_default = parse_bool(line)
          }
          next
        }

        if (section == "root" && top_level_index == "" && line ~ /^[[:space:]]*index-url[[:space:]]*=/) {
          top_level_index = parse_string(line)
        }
      }

      END {
        if (section == "index") {
          flush_index()
        }

        if (default_index != "") {
          print default_index
        } else if (top_level_index != "") {
          print top_level_index
        }
      }
    ' "$config_file"
  }

  read_uv_pip_index() {
    local config_file

    config_file=$(uv_config_file)
    [[ -f $config_file ]] || return 0

    awk '
      function trim(value) {
        sub(/^[[:space:]]+/, "", value)
        sub(/[[:space:]]+$/, "", value)
        return value
      }

      function parse_string(line) {
        sub(/^[^=]*=[[:space:]]*/, "", line)
        sub(/[[:space:]]+#.*$/, "", line)
        line = trim(line)
        if (line ~ /^".*"$/ || line ~ /^'\''.*'\''$/) {
          line = substr(line, 2, length(line) - 2)
        }
        return line
      }

      BEGIN {
        in_pip = 0
      }

      {
        line = $0

        if (line ~ /^[[:space:]]*\[pip\][[:space:]]*(#.*)?$/) {
          in_pip = 1
          next
        }

        if (line ~ /^[[:space:]]*\[[^][]+\][[:space:]]*(#.*)?$/ || line ~ /^[[:space:]]*\[\[[^][]+\]\][[:space:]]*(#.*)?$/) {
          in_pip = 0
        }

        if (in_pip && line ~ /^[[:space:]]*index-url[[:space:]]*=/) {
          print parse_string(line)
          exit
        }
      }
    ' "$config_file"
  }

  list_mirrors() {
    echo "Supported PyPI mirrors:"
    echo "[Shortname]    [URL]"
    echo "pypi:          https://pypi.org/simple/"                             # PyPI Official
    echo "aliyun:        https://mirrors.aliyun.com/pypi/simple/"              # Alibaba Cloud
    echo "tencent:       https://mirrors.cloud.tencent.com/pypi/simple/"       # Tencent Cloud
    echo "huawei:        https://repo.huaweicloud.com/repository/pypi/simple/" # Huawei Cloud
    echo "163:           https://mirrors.163.com/pypi/simple/"                 # 163
    echo "volces:        https://mirrors.volces.com/pypi/simple/"              # Volces/HuoShan Engine
    echo "cernet:        https://mirrors.cernet.edu.cn/pypi/web/simple/"       # China Education and Research Network
    echo "tsinghua:      https://pypi.tuna.tsinghua.edu.cn/simple/"            # Tsinghua University
    echo "sustech:       https://mirrors.sustech.edu.cn/pypi/web/simple/"      # Southern University of Science and Technology
    echo "bfsu:          https://mirrors.bfsu.edu.cn/pypi/web/simple/"         # Beijing Foreign Studies University
    echo "nju:           https://mirror.nju.edu.cn/pypi/web/simple/"           # Nanjing University
    echo "pku:           https://mirrors.pku.edu.cn/pypi/web/simple/"          # Peking University
    echo "njtech:        https://mirrors.njtech.edu.cn/pypi/web/simple/"       # Nanjing Tech University
    echo "nyist:         https://mirrors.njtech.edu.cn/pypi/web/simple/"       # Nanyang Institute of Technology
    echo "sjtu:          https://mirror.sjtu.edu.cn/pypi/web/simple/"          # Shanghai Jiao Tong University
    # echo "zju:           https://mirrors.zju.edu.cn/pypi/web/simple/"          # Zhejiang University
    echo "jlu:           https://mirrors.jlu.edu.cn/pypi/web/simple/"          # Jilin University
    echo "testpypi:      https://test.pypi.org/simple/"                        # Test PyPI
  }

  use_mirror() {
    local help="Usage: pypi use <shortname> [--pip|--uv|--all]

  Switches to a specified PyPI mirror. Replace <shortname> with the desired mirror's shortname.

  Targets:
    --pip    Update pip only (default)
    --uv     Update uv user-level config only
    --all    Update both pip and uv

  Examples:
    pypi use aliyun
    pypi use aliyun --uv
    pypi use aliyun --all"
    local shortname=""
    local option_args=()
    local arg target index_url

    if [[ $# -eq 0 ]]; then
      echo "$help"
      return
    fi

    for arg in "$@"; do
      case $arg in
      -h|--help)
        echo "$help"
        return
        ;;
      --pip|--uv|--all)
        option_args+=("$arg")
        ;;
      *)
        if [[ -z $shortname ]]; then
          shortname=$arg
        else
          echo "Error: unexpected argument: $arg"
          return 1
        fi
        ;;
      esac
    done

    if [[ -z $shortname ]]; then
      echo "$help"
      return 1
    fi

    target=$(parse_target_flags "pip" "${option_args[@]}") || return 1
    index_url=$(mirror_index_url "$shortname") || {
      echo "Unknown mirror: $shortname"
      return 1
    }

    case $target in
    pip)
      write_pip_index "$index_url" || return 1
      echo "Switched pip to $shortname: $index_url"
      ;;
    uv)
      write_uv_index "$index_url" || return 1
      echo "Switched uv user-level config to $shortname: $index_url"
      ;;
    all)
      write_pip_index "$index_url" || return 1
      write_uv_index "$index_url" || return 1
      echo "Switched pip and uv to $shortname: $index_url"
      ;;
    esac
  }

  ping_mirror() {
    local shortname_or_url=$1
    local url

    if [[ -z $shortname_or_url || $shortname_or_url == "--help" || $shortname_or_url == "-h" ]]; then
      echo "Usage: pypi ping <shortname|url>

      Checks network connectivity to a specified PyPI mirror or URL.
      Example: pypi ping tsinghua"
      return
    fi

    if ! url=$(mirror_index_url "$shortname_or_url" 2>/dev/null); then
      url=$shortname_or_url
    fi

    if [[ $url != https* ]]; then
      echo "Error: $url is not a valid URL"
      return 1
    fi

    # -I only receive header, --max-time 5s set timeout to 5s
    read -r curl_status curl_delay < <(curl -o /dev/null -s -I -w "%{http_code} %{time_total}" --max-time 5 "$url")

    curl_delay=$(printf "%.2f" "$(echo "$curl_delay * 1000" | bc)")
    local max_status=300
    if [[ $shortname_or_url == "cernet" ]]; then
      max_status=400
    fi
    if [[ $curl_status -ge 200 && $curl_status -lt $max_status ]]; then
      echo "Mirror $url is REACHABLE (status: $curl_status, delay: $curl_delay ms)"
    else
      echo "Error: $url is UNREACHABLE (status: $curl_status, delay: $curl_delay ms)"
    fi
  }

  current_pip_index() {
    local index_url

    index_url=$(pip config get global.index-url 2>/dev/null)
    if [[ -z $index_url ]]; then
      index_url="https://pypi.org/simple/"
    fi

    echo "Current pip index: $index_url"
  }

  current_uv_indexes() {
    local index_url pip_index

    index_url=$(read_uv_default_index)
    pip_index=$(read_uv_pip_index)

    if [[ -z $index_url ]]; then
      index_url="https://pypi.org/simple/ (PyPI default)"
    fi

    if [[ -z $pip_index ]]; then
      pip_index="inherits global/default"
    fi

    echo "Current uv default index (user-level): $index_url"
    echo "Current uv pip index (user-level): $pip_index"
    echo "Note: project-level uv config, environment variables, and CLI options can override these user-level values."
  }

  current_index() {
    local help="Usage: pypi cur [--pip|--uv|--all]

  Print current pip and/or uv index settings.

  Targets:
    --pip    Show pip only (default)
    --uv     Show uv user-level config only
    --all    Show both pip and uv

  Examples:
    pypi cur
    pypi cur --uv
    pypi cur --all"
    local arg target

    for arg in "$@"; do
      case $arg in
      -h|--help)
        echo "$help"
        return
        ;;
      --pip|--uv|--all)
        ;;
      *)
        echo "Error: unexpected argument: $arg"
        return 1
        ;;
      esac
    done

    target=$(parse_target_flags "pip" "$@") || return 1

    case $target in
    pip)
      current_pip_index
      ;;
    uv)
      current_uv_indexes
      ;;
    all)
      current_pip_index
      current_uv_indexes
      ;;
    esac
  }

  local command=$1
  if [[ -z $command ]]; then
    print_help
    return
  fi
  shift

  case $command in
  list) list_mirrors ;;
  use) use_mirror "$@" ;;
  ping) ping_mirror "$@" ;;
  cur) current_index "$@" ;;
  -h|--help|help|"") print_help ;;
  *) echo "Invalid command: $command"; print_help ;;
  esac
}
