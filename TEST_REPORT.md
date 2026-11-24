# 测试报告 · 2026-11-24

## 环境

Windows 11 Pro 26H2，build 26300.10075，mstsc 10.0.26100.9949。Intel Arc 140V 驱动 32.0.101.9175，另检测到 GameViewer Virtual Display Adapter 15.6.5.199。系统发现 dotnet 宿主，SDK 列表为空。CMake、cl、rustc 未在 PATH 找到。项目使用 Windows PowerShell 5.1，Git 使用校验过的便携 MinGit。

| 测试 | 状态 | 证据 |
|---|---|---|
| Windows 和 mstsc 版本探测 | 通过 | PowerShell 输出 Professional、26H2、26300.10075、10.0.26100.9949 |
| UTF-16 RemoteApp 配置及包含空格的文件路径 | 通过 | 有效配置通过结构检查 |
| 拒绝大小写不同的重复键、桌面模式、非发布别名、缺失地址、格式错误 | 通过 | 五例被拒绝，测试脚本退出码 0 |
| EasyTier 发布包和 CLI | 通过 | SHA-256 匹配，两个程序均报告 2.6.4-8428a89d |
| EasyTier 无 TUN 和无入站隧道监听的本地 RPC | 通过 | node info 与 peer 退出码 0，peer 表仅有 Local |
| 真实 RDS 配置、服务器签名与认证 | 未验证 | 缺可访问的授权 RDS 实验宿主 |
| 记事本、同时启动多个应用、独立窗口、任务栏、Alt+Tab | 未验证 | 同上 |
| 窗口缩放、吸附、菜单、模态对话框 | 未验证 | 同上 |
| 剪贴板、中文与日文输入法、音频、文件关联 | 未验证 | 同上 |
| 会话恢复、多显示器、DPI、GPU、被控端物理控制台 | 未验证 | 同上 |
| 普通 Windows 宿主、Windows 10/11 Enterprise/Home 对照 | 未验证 | 缺独立授权宿主 |
| EasyTier 服务管理、Windows 网卡、两端 TCP/UDP、跨网直连、中继 | 未验证 | 本次仅运行单机无 TUN 实例 |

Windows PowerShell 默认执行策略阻止了首次启动。用本次进程的 RemoteSigned 策略运行回归，管理员和用户组策略均未设置。首次回归发现提前抛错后延迟读行可能占用临时文件句柄。改为读取有大小上限的完整行数组后，回归退出码为 0。
