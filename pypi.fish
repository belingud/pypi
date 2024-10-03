# pypi plugin to handle PyPI mirrors for Fish Shell
# Main function to handle pypi commands
pypi()
begin
    local help="
Usage: pypi <command> [options]

Commands:
  list                 List all supported PyPI mirrors and their URLs.
  use <shortname>      Switch to a specified PyPI mirror. Replace <shortname> with the desired mirror's shortname.
  ping <shortname|url> Check network connectivity to a specified PyPI mirror or URL.
  cur                  Print current pypi index

Options:
  -h, --help           Show this help message and exit.

Examples:
  pypi list            # Lists all supported PyPI mirrors
  pypi use aliyun      # Switches to the Alibaba Cloud mirror
  pypi ping tsinghua   # Checks connectivity to the Tsinghua University mirror
  pypi ping https://pypi.org/simple/  # Checks connectivity to the official PyPI URL
  pypi cur             # Will print current pypi index

For more details on each command, you can run:
  pypi <command> -h/--help

Note:
  The 'ping' command can accept either a mirror shortname or a direct URL.
  The 'use' command requires a valid shortname from the list of supported mirrors."

    function print-help
        echo $help
    end

    local command = string trim $argv[1]
    if not $command
        print-help
        return
    end

    function list-mirrors
        echo "Supported PyPI mirrors:"
        echo "[Shortname]    [URL]"
        echo "pypi:          https://pypi.org/simple/"
        echo "aliyun:        https://mirrors.aliyun.com/pypi/simple/"
        echo "tencent:       https://mirrors.cloud.tencent.com/pypi/simple/"
        echo "huawei:        https://repo.huaweicloud.com/repository/pypi/simple/"
        echo "163:           https://mirrors.163.com/pypi/simple/"
        echo "volces:        https://mirrors.volces.com/pypi/simple/"
        echo "cernet:        https://mirrors.cernet.edu.cn/pypi/web/simple/"
        echo "tsinghua:      https://pypi.tuna.tsinghua.edu.cn/simple/"
        echo "sustech:       https://mirrors.sustech.edu.cn/pypi/web/simple/"
        echo "bfsu:          https://mirrors.bfsu.edu.cn/pypi/web/simple/"
        echo "nju:           https://mirror.nju.edu.cn/pypi/web/simple/"
        echo "dnui:          https://mirrors.neusoft.edu.cn/pypi/web/simple/"
        echo "pku:           https://mirrors.pku.edu.cn/pypi/web/simple/"
        echo "njtech:        https://mirrors.njtech.edu.cn/pypi/web/simple/"
        echo "nyist:         https://mirrors.njtech.edu.cn/pypi/web/simple/"
        echo "sjtu:          https://mirror.sjtu.edu.cn/pypi/web/simple/"
        echo "zju:           https://mirrors.zju.edu.cn/pypi/web/simple/"
        echo "jlu:           https://mirrors.jlu.edu.cn/pypi/web/simple/"
        echo "testpypi:      https://test.pypi.org/simple/"
    end

    function use-mirror
        set shortname = string trim $argv[2]
        if not $shortname or $shortname = "--help" or $shortname = "-h"
            echo "Usage: pypi use <shortname>

      Switches to a specified PyPI mirror. Replace <shortname> with the desired mirror's shortname.
      Example: pypi use aliyun"
            return
        end

        switch $shortname
            case "pypi"
                set index_url "https://pypi.org/simple/"
                set trusted_host "pypi.org"
            case "aliyun"
                set index_url "https://mirrors.aliyun.com/pypi/simple/"
                set trusted_host "mirrors.aliyun.com"
            ... (continue listing cases for other mirrors)
            case "testpypi"
                set index_url "https://test.pypi.org/simple/"
                set trusted_host "test.pypi.org"
            default
                echo "Unknown mirror: $shortname"
                return 1
        end

        pip config set global.index-url $index_url
        pip config set install.trusted-host $trusted_host

        echo "Switched to $shortname: $index_url"
    end

    function ping-mirror
        set shortname_or_url = string trim $argv[2]
        if not $shortname_or_url or $shortname_or_url = "--help" or $shortname_or_url = "-h"
            echo "Usage: pypi ping <shortname|url>

      Checks network connectivity to a specified PyPI mirror or URL.
      Example: pypi ping tsinghua"
            return
        end

        ...
        # Similar switch-case structure as above for use-mirror but for getting the URL
        # and then using curl to check the connectivity.
        # This part would be implemented similarly to the use-mirror function but adapted for checking URLs.
        ...
    end

    function current-index
        local help="
Usage: pypi cur

  Print current pypi index

  Options:
    -h, --help           Show this help message and exit."

        if $argv[2] = "--help" or $argv[2] = "-h"
            echo $help
            return
        end

        set index_url (pip config get global.index-url)
        echo "Current PyPI index: $index_url"
    end

    switch $command
        case "list"
            list-mirrors
        case "use"
            use-mirror
        case "ping"
            ping-mirror
        case "cur"
            current-index
        case "-h", "--help", "help", ""
            print-help
        default
            echo "Invalid command: $command"
            print-help
    end
end
