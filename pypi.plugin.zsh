#!/usr/bin/env zsh
# pypi plugin to handle PyPI mirrors for oh-my-zsh
# Main function to handle pypi commands
pypi() {
  local help="Usage: pypi <command> [options]

Commands:
  list                 List all supported PyPI mirrors and their URLs.
  use <shortname>      Switch to a specified PyPI mirror. Replace <shortname> with the desired mirror's shortname.
  ping <shortname|url> Check network connectivity to a specified PyPI mirror or URL.

Options:
  -h, --help           Show this help message and exit.

Examples:
  pypi list            # Lists all supported PyPI mirrors
  pypi use aliyun      # Switches to the Alibaba Cloud mirror
  pypi ping tsinghua   # Checks connectivity to the Tsinghua University mirror
  pypi ping https://pypi.org/simple/  # Checks connectivity to the official PyPI URL

For more details on each command, you can run:
  pypi <command> -h/--help

Note:
  The 'ping' command can accept either a mirror shortname or a direct URL.
  The 'use' command requires a valid shortname from the list of supported mirrors."

  print_help() {
    echo "$help"
  }

  local command=$1
  if [[ -z $command ]]; then
    print_help
    return
  fi
  shift


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
    echo "dnui:          https://mirrors.neusoft.edu.cn/pypi/web/simple/"      # Dalian Neusoft University of Information
    echo "pku:           https://mirrors.pku.edu.cn/pypi/web/simple/"          # Peking University
    echo "njtech:        https://mirrors.njtech.edu.cn/pypi/web/simple/"       # Nanjing Tech University
    echo "nyist:         https://mirrors.njtech.edu.cn/pypi/web/simple/"       # Nanyang Institute of Technology
    echo "sjtu:          https://mirror.sjtu.edu.cn/pypi/web/simple/"          # Shanghai Jiao Tong University
    echo "zju:           https://mirrors.zju.edu.cn/pypi/web/simple/"          # Zhejiang University
    echo "jlu:           https://mirrors.jlu.edu.cn/pypi/web/simple/"          # Jilin University
    echo "testpypi:      https://test.pypi.org/simple/"                        # Test PyPI
  }

  use_mirror() {
    local shortname=$1
    if [[ -z $shortname || $shortname == "--help" || $shortname == "-h" ]]; then
      echo "Usage: pypi use <shortname>

      Switches to a specified PyPI mirror. Replace <shortname> with the desired mirror's shortname.
      Example: pypi use aliyun"
      return
    fi

    local index_url trusted_host

    case $shortname in
    pypi) index_url="https://pypi.org/simple/"; trusted_host="pypi.org" ;;
    aliyun) index_url="https://mirrors.aliyun.com/pypi/simple/"; trusted_host="mirrors.aliyun.com" ;;
    tencent) index_url="https://mirrors.cloud.tencent.com/pypi/simple/"; trusted_host="mirrors.cloud.tencent.com" ;;
    163) index_url="https://mirrors.163.com/pypi/simple/"; trusted_host="mirrors.163.com" ;;
    volces) index_url="https://mirrors.volces.com/pypi/simple/"; trusted_host="mirrors.volces.com" ;;
    huawei) index_url="https://repo.huaweicloud.com/repository/pypi/simple/"; trusted_host="repo.huaweicloud.com" ;;
    testpypi) index_url="https://test.pypi.org/simple/"; trusted_host="test.pypi.org" ;;
    cernet) index_url="https://mirrors.cernet.edu.cn/pypi/web/simple/"; trusted_host="mirrors.cernet.edu.cn" ;;
    tsinghua) index_url="https://pypi.tuna.tsinghua.edu.cn/simple/"; trusted_host="pypi.tuna.tsinghua.edu.cn" ;;
    sustech) index_url="https://mirrors.sustech.edu.cn/pypi/web/simple/"; trusted_host="mirrors.sustech.edu.cn" ;;
    bfsu) index_url="https://mirrors.bfsu.edu.cn/pypi/web/simple/"; trusted_host="mirrors.bfsu.edu.cn" ;;
    nju) index_url="https://mirror.nju.edu.cn/pypi/web/simple/"; trusted_host="mirror.nju.edu.cn" ;;
    dnui) index_url="https://mirrors.neusoft.edu.cn/pypi/web/simple/"; trusted_host="mirrors.neusoft.edu.cn" ;;
    pku) index_url="https://mirrors.pku.edu.cn/pypi/web/simple/"; trusted_host="mirrors.pku.edu.cn" ;;
    njtech) index_url="https://mirrors.njtech.edu.cn/pypi/web/simple/"; trusted_host="mirrors.njtech.edu.cn" ;;
    nyist) index_url="https://mirrors.njtech.edu.cn/pypi/web/simple/"; trusted_host="mirrors.njtech.edu.cn" ;;
    sjtu) index_url="https://mirror.sjtu.edu.cn/pypi/web/simple/"; trusted_host="mirror.sjtu.edu.cn" ;;
    zju) index_url="https://mirrors.zju.edu.cn/pypi/web/simple/"; trusted_host="mirrors.zju.edu.cn" ;;
    jlu) index_url="https://mirrors.jlu.edu.cn/pypi/web/simple/"; trusted_host="mirrors.jlu.edu.cn" ;;
    nwafu) index_url="https://mirrors.nwafu.edu.cn/pypi/"; trusted_host="mirrors.nwafu.edu.cn" ;;
    *) echo "Unknown mirror: $shortname"; return 1 ;;
    esac

    pip config set global.index-url $index_url
    pip config set install.trusted-host $trusted_host

    echo "Switched to $shortname: $index_url"
  }

  ping_mirror() {
    local shortname_or_url=$1
    if [[ -z $shortname_or_url || $shortname_or_url == "--help" || $shortname_or_url == "-h" ]]; then
      echo "Usage: pypi ping <shortname|url>

      Checks network connectivity to a specified PyPI mirror or URL.
      Example: pypi ping tsinghua"
      return
    fi

    local url
    case $shortname_or_url in
    pypi) url="https://pypi.org/simple/" ;;
    aliyun) url="https://mirrors.aliyun.com/pypi/simple/" ;;
    tencent) url="https://mirrors.cloud.tencent.com/pypi/simple/" ;;
    163) url="https://mirrors.163.com/pypi/simple/" ;;
    volces) url="https://mirrors.volces.com/pypi/simple/" ;;
    huawei) url="https://repo.huaweicloud.com/repository/pypi/simple/" ;;
    testpypi) url="https://test.pypi.org/simple/" ;;
    cernet) url="https://mirrors.cernet.edu.cn/pypi/web/simple/" ;;
    tsinghua) url="https://pypi.tuna.tsinghua.edu.cn/simple/" ;;
    sustech) url="https://mirrors.sustech.edu.cn/pypi/web/simple/" ;;
    bfsu) url="https://mirrors.bfsu.edu.cn/pypi/web/simple/" ;;
    nju) url="https://mirror.nju.edu.cn/pypi/web/simple/" ;;
    dnui) url="https://mirrors.neusoft.edu.cn/pypi/web/simple/" ;;
    pku) url="https://mirrors.pku.edu.cn/pypi/web/simple/" ;;
    njtech) url="https://mirrors.njtech.edu.cn/pypi/web/simple/" ;;
    nyist) url="https://mirrors.njtech.edu.cn/pypi/web/simple/" ;;
    sjtu) url="https://mirror.sjtu.edu.cn/pypi/web/simple/" ;;
    zju) url="https://mirrors.zju.edu.cn/pypi/web/simple/" ;;
    jlu) url="https://mirrors.jlu.edu.cn/pypi/web/simple/" ;;
    nwafu) url="https://mirrors.nwafu.edu.cn/pypi/" ;;
    *) url=$shortname_or_url ;;
    esac

    if [[ $url != https* ]]; then
      echo "Error: $url is not a valid URL"
      return 1
    fi

    read -r curl_status curl_delay < <(curl -o /dev/null -s -w "%{http_code} %{time_total}" "$url")

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

  case $command in
  list) list_mirrors ;;
  use) use_mirror "$@" ;;
  ping) ping_mirror "$@" ;;
  -h|--help|help|"") print_help ;;
  *) echo "Invalid command: $command"; print_help ;;
  esac
}
