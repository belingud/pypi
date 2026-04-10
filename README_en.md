# PyPI Plugin User Guide

[中文](./README.md) | English

<!-- TOC -->
* [PyPI Plugin User Guide](#pypi-plugin-user-guide)
  * [Introduction](#introduction)
  * [Installation](#installation)
  * [Usage](#usage)
    * [Basic Commands](#basic-commands)
    * [Command Details](#command-details)
    * [Examples](#examples)
  * [Supported Mirrors](#supported-mirrors)
  * [Notes](#notes)
  * [Help](#help)
  * [License](#license)
<!-- TOC -->

## Introduction

This is a plugin for oh-my-zsh to manage PyPI mirrors. The plugin provides several convenient commands to list available PyPI mirrors, switch mirrors for `pip` and `uv`, and test mirror connectivity.

## Installation

Using `git`

```shell
git clone https://github.com/belingud/pypi ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/pypi
```

Or copy the plugin script to the `~/.oh-my-zsh/custom/plugins/` directory manually, then add the plugin name to `~/.zshrc`. For example:

```shell
plugins=(... pypi ...)
```

## Usage

### Basic Commands

1. **List Supported Mirrors**

    ```shell
    pypi list
    ```
   This command lists all supported PyPI mirrors and their URLs.

2. **Switch Mirrors**

    ```shell
    pypi use <shortname> [--pip|--uv|--all]
    ```

   Switch to the specified mirror, where `<shortname>` is the mirror's short name. The target flags are:

   - `--pip`: update `pip` only, the default
   - `--uv`: update the user-level `uv` config only
   - `--all`: update both `pip` and `uv`

   For example:

    ```shell
    pypi use aliyun
    ```

    ```shell
    pypi use aliyun --uv
    ```

    ```shell
    pypi use aliyun --all
    ```

3. **Test Mirror Connectivity**

   ```shell
   pypi ping <shortname|url>
   ```

   Check the network connectivity of the specified mirror, where `<shortname>` is the mirror's short name, or you can directly use the mirror's URL. For example:

   ```shell
   pypi ping tsinghua
   ```
   or

   ```shell
   pypi ping https://pypi.org/simple/
   ```

4. **Show Current Configuration**

   ```shell
   pypi cur [--pip|--uv|--all]
   ```

   Show the current mirror configuration for `pip` and/or `uv`. For example:

   ```shell
   pypi cur
   ```

   ```shell
   pypi cur --all
   ```

### Command Details

- `pypi list` lists all supported PyPI mirrors and their URLs.
- `pypi use <shortname> [--pip|--uv|--all]` switches to the specified PyPI mirror.
- `pypi ping <shortname|url>` tests the network connectivity of the specified mirror or URL.
- `pypi cur [--pip|--uv|--all]` shows the current mirror configuration for `pip` and/or `uv`.

### Examples

List all supported mirrors:

```shell
pypi list
```

Switch to the Aliyun mirror:

```shell
pypi use aliyun
```

Switch only the user-level `uv` config to the Aliyun mirror:

```shell
pypi use aliyun --uv
```

Switch both `pip` and `uv` to the Tsinghua mirror:

```shell
pypi use tsinghua --all
```

Test the connectivity of the Tsinghua mirror:

```shell
pypi ping tsinghua
```

Show the current `pip` and `uv` configuration:

```shell
pypi cur --all
```

## Supported Mirrors

Here are some supported PyPI mirrors and their short names:

- pypi: https://pypi.org/simple/
- aliyun: https://mirrors.aliyun.com/pypi/simple/
- tencent: https://mirrors.cloud.tencent.com/pypi/simple/
- huawei: https://repo.huaweicloud.com/repository/pypi/simple/
- 163: https://mirrors.163.com/pypi/simple/
- tsinghua: https://pypi.tuna.tsinghua.edu.cn/simple/
- bfsu: https://mirrors.bfsu.edu.cn/pypi/web/simple/

More mirrors can be viewed by running `pypi list`.

## Notes

- The `ping` command accepts both mirror short names and direct URLs.
- The `use` command requires a valid mirror short name.
- `pypi use <shortname>` updates `pip` only by default. Use `--uv` or `--all` to update `uv`.
- `uv` is managed via the user-level config file at `${XDG_CONFIG_HOME:-~/.config}/uv/uv.toml`.
- If the `uv` config file does not exist, the plugin creates it. If index-related settings already exist, the plugin normalizes those settings into a single-mirror configuration while preserving non-index settings.
- Project-level `uv` config, environment variables, and CLI flags can override the user-level config.

## Help

To view detailed help information for each command, run:

```shell
pypi <command> -h/--help
```

For example:

```shell
pypi use -h
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
