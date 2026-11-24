# EasyTier Windows 本地实验

将 [v2.6.4 官方 Windows x64 包](https://github.com/EasyTier/EasyTier/releases/tag/v2.6.4) 解压到专用目录。哈希及版本见 [技术调查](../TECH_RESEARCH.md)。在该目录用两个控制台运行以下命令，选用空闲回环端口。

~~~powershell
.\easytier-core.exe --no-tun --no-listener --disable-upnp --rpc-portal 127.0.0.1:15888 --network-name wincoherence-local-probe
~~~

~~~powershell
.\easytier-cli.exe -p 127.0.0.1:15888 node info
.\easytier-cli.exe -p 127.0.0.1:15888 peer
~~~

确认 CLI 能读取本机状态，peer 表只有 Local。在首个控制台按 Ctrl+C 退出。该步骤验证本地管理接口。Windows 网卡、服务模式、数据承载和跨网连接需要分别验证。
