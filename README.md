# PyPI 插件使用指南

## 简介

这是一个用于管理 PyPI 镜像的 oh-my-zsh 插件。该插件提供了几个便捷的命令，允许用户列出可用的 PyPI 镜像、切换镜像，以及测试镜像的网络连通性。

## 安装

使用`git`

```shell
git clone https://github.com/belingud/ohmyzsh-pypi $ZSH_HOME
```

将插件脚本复制到 ~/.oh-my-zsh/custom/plugins/ 目录下，然后在 ~/.zshrc 中添加插件名称即可。例如：

```shell
plugins=(... pypi ...)
```
## 使用

### 基本命令

1. **列出支持的镜像**

    ```shell
    pypi list
    ```
    该命令列出所有支持的 PyPI 镜像及其 URL。

2. **切换镜像**

    ```shell
    pypi use <shortname>
    ```
    
    使用指定的镜像，<shortname> 是镜像的简写名。例如：
    
    ```shell
    pypi use aliyun
    ```

3. **测试镜像连通性**

   ```shell
   pypi ping <shortname|url>
   ```
   
   检查指定镜像的网络连通性，`<shortname>` 是镜像的简写名，也可以直接使用镜像的`URL`。例如：
   
   ```shell
   pypi ping tsinghua
   ```
   或
   
   ```shell
   pypi ping https://pypi.org/simple/
   ```

### 命令详情

- `pypi list` 列出支持的 PyPI 镜像及其 URL。
- `pypi use <shortname>` 切换到指定的 PyPI 镜像。
- `pypi ping <shortname|url>` 测试指定镜像或 URL 的网络连通性。

### 例子

列出所有支持的镜像：

```shell
pypi list
```

切换到阿里云镜像：

```shell
pypi use aliyun
```

测试清华大学镜像的连通性：

```shell
pypi ping tsinghua
```
## 支持的镜像
以下是一些支持的 PyPI 镜像及其简写名：

- pypi: https://pypi.org/simple/
- aliyun: https://mirrors.aliyun.com/pypi/simple/
- tencent: https://mirrors.cloud.tencent.com/pypi/simple/
- huawei: https://repo.huaweicloud.com/repository/pypi/simple/
- 163: https://mirrors.163.com/pypi/simple/
- tsinghua: https://pypi.tuna.tsinghua.edu.cn/simple/
- bfsu: https://mirrors.bfsu.edu.cn/pypi/web/simple/

更多镜像请使用 pypi list 查看。

## 注意事项

ping 命令接受镜像简写名或直接 URL。
use 命令需要提供有效的镜像简写名。

## 帮助

要查看每个命令的详细帮助信息，可以运行：

```shell
pypi <command> -h/--help
```

例如：

```shell
pypi use -h
```