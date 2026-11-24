# WinCoherence Phase 1 · 宿主设备 Agent 交接

你现在操作的是 B（被控端）。A 是已有 WinCoherence 仓库的主控端。目标是准备可以从 A 连接的 RemoteApp 实验宿主，并协助确认两个远程应用各自拥有独立窗口。当前原型使用 Windows 自带的 mstsc，宿主侧使用 Windows Server RDS 发布应用。先阅读 [项目约定](../AGENTS.md)、[实验矩阵](remoteapp-lab.md) 和 [现有测试报告](../TEST_REPORT.md)。

## 1. 先采集环境

在 B 的 PowerShell 执行这些只读命令。需要进一步权限时，先报告哪些信息无法读取。记录 Windows 版本、安装类型、虚拟化能力和空余空间。私有主机名、域名和网络信息仅交给设备所有者。

~~~powershell
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' |
    Select-Object EditionID, InstallationType, DisplayVersion, CurrentBuild, UBR
Get-CimInstance Win32_ComputerSystem |
    Select-Object PartOfDomain, HypervisorPresent, TotalPhysicalMemory
Get-PSDrive -Name C | Select-Object Free
Get-Service -Name vmms, TermService -ErrorAction SilentlyContinue |
    Select-Object Name, Status
~~~

确认用户授权用于实验的账号、设备和网络。只读检查先执行。若需要启用远程访问、改变防火墙、安装角色、加入域、安装 Hyper-V、部署虚拟机或重启，明确告知变更范围和回退方式，再取得宿主所有者授权。保留本地操作者的访问能力。首轮仅使用可信私网，避免在路由器配置入站端口映射。

## 2. 根据 B 的系统选择路径

### B 是 Windows 11 Pro 或 Enterprise

可做完整桌面对照。经授权，在「设置 → 系统 → 远程桌面」开启远程桌面，保留网络级别身份验证，授权专用测试账号。让 A 在可信私网使用 mstsc 连接 B。观察连接成功、B 物理控制台的锁屏或会话状态，以及断开后的行为。记录原开关、授权组及防火墙状态，以便恢复本次改动。

独立窗口实验走下方的 Server RDS 路径。若 B 还要日常使用，优先评估另建 Windows Server 实验虚拟机，保留原系统。虚拟机里需要单独安装测试应用。普通 Windows Home 记录为该桌面对照路径不适用。 [微软客户端连接说明](https://learn.microsoft.com/windows-server/remote/remote-desktop-services/clients/windows)

### B 是受支持的 Windows Server，或已有获授权的 Server 虚拟机

1. 优先利用现有 RDS 实验部署。在 Server Manager → Remote Desktop Services 检查连接代理、RD Web Access、RD Session Host 和会话集合。若尚未部署，按微软会话型 RDS 指南准备域和 DNS，然后通过服务器管理器安装所需角色。在获授权的测试部署中配置适用的 RDS CAL 和客户端信任的证书。保留部署产生的主机名与路由配置。 [部署指南](https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds-deploy-infrastructure) · [RDS CAL 指南](https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds-client-access-license)
2. 创建或选定实验会话集合，授权专用的非管理员测试账号或测试组。发布记事本及另一款已获授权的测试应用。确认可执行文件存在于该集合各会话主机上，并确认账号有权访问集合和这两个应用。记录集合名和应用别名。 [会话集合与 RemoteApp 发布](https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds-create-collection)
3. 让 A 在可信私网访问部署的 RD Web HTTPS 地址，用测试账号获取两个原始 RDP 文件。确认 A 可解析部署配置所使用的名称。测试凭据通过双方认可的受控渠道交接，每次登录由操作者在系统界面输入。证书警告、访问拒绝或许可错误先诊断并记录。
4. 若本次新增发布或授权，记录变更前状态。清理时只撤销本次添加的测试应用、账号授权和网络规则。复用既有 RDS 部署时保留其他集合与角色。

## 3. 与主控端 A 联测

A 从仓库根目录运行下列命令。用实际下载位置替换示例路径，然后用相同账号启动第二个应用。

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\Invoke-RemoteAppProbe.ps1 -RdpFile 'C:\Lab\Notepad.rdp' -ValidateOnly
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\Invoke-RemoteAppProbe.ps1 -RdpFile 'C:\Lab\Notepad.rdp'
~~~

A 观察两个独立窗口能否和本地窗口交错、调整大小并通过任务栏与 Alt+Tab 切换。B 的操作者观察物理控制台、锁屏及断开后的会话状态。通过首轮后按 [实验矩阵](remoteapp-lab.md) 继续验证对话框、IME、剪贴板、重连、多显示器、DPI 和 GPU。仅通过结构检查的项目记录为客户端预检通过。

## 4. 回传结果

按下面格式给主控端 Agent 回传结果。无法完成时记录当前可执行的最小下一步及所需授权。私有地址、账号、证书私钥、原始 RDP 文件和未经脱敏的日志不进入公开 GitHub 仓库。主控端用脱敏结果更新 TEST_REPORT.md 和 PROGRESS.md。

~~~text
B 系统版本、版本号与角色：
选定路径（完整桌面对照 / Server RDS）：
A 到 B 的连接条件（只写私网类型和可达性）：
已执行的变更及回退状态：
测试项 | 通过 / 失败 / 部分通过 / 未验证 | 观察结果或脱敏错误：
下一步与阻塞：
~~~
