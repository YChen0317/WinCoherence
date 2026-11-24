# Phase 1 主控端 A 交接 · 2026-11-24

A 负责用 Windows 自带的 mstsc 启动两个已发布应用，B 负责宿主及物理控制台观察。当前可开展 A 端预检。真实窗口验收仍缺获授权的 Windows Server RDS 部署入口。

## B 已实测的基线

| 项目 | 状态 | 观察 |
|---|---|---|
| 系统、域、容量 | 通过 | Windows 11 Pro 26H2，26300.10075，Client，工作组。物理内存 24 GiB，C 盘可用约 221.9 GiB。 |
| 虚拟化 | 部分通过 | CPU 报告存在 hypervisor。处理器特性接口对固件虚拟化和 SLAT 均返回否。CIM 读取被拒，实际启动 Server 来宾的能力待测。 |
| 现有实验机 | 部分通过 | VMware 报告运行中虚拟机为 0。默认目录有一份来宾类型标记为 windows9-64 的配置。完整用户清单读取被拒，实际来宾系统和其他关机虚拟机待 B 本地操作者核实。 |
| 完整桌面连接 | 未验证 | B 的远程桌面关闭，TermService 已停止。A 到 B 的私网可达性待测。 |
| Server RDS、应用发布、A 的窗口行为、B 的控制台与断开状态 | 未验证 | 尚无经确认的集合、测试账号权限、RD Web 入口或两个已发布应用的原始 RDP 配置。 |

B 仅做了只读检查，无需回退。请 B 本地操作者先查 VMware 库，也可由部署所有者私下提供已有授权 Server RDS 的入口。启用远程访问、调整防火墙、配置虚拟机、安装角色、加入域或重启前，须说明影响和回退方法，取得设备所有者授权，并保留本地操作者访问能力。

## 给 A 的接手 prompt

你正在操作 WinCoherence 主控端 A。先读本页、[项目约定](../AGENTS.md)、[宿主交接](phase1-host-handoff.md)、[实验矩阵](remoteapp-lab.md)、[测试报告](../TEST_REPORT.md) 和 [项目进度](../PROGRESS.md)。请直接执行当前条件允许的步骤。

1. 在 A 的仓库根目录用 Windows PowerShell 执行下列两条命令，记录本次客户端版本、检查结果和回归退出码。把这些结果记为客户端预检。
   
   ~~~powershell
   powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\Invoke-RemoteAppProbe.ps1 -Inspect
   powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\tests\Test-RemoteAppProbe.ps1
   ~~~
2. 通过双方认可的私有渠道与 B 确认可信私网、联测时段及现有 RDS 条件。请 B 或部署管理员核对连接代理、会话主机、集合、RD Web HTTPS、证书信任、适用许可和非管理员测试账号权限。获准后发布记事本和第二款授权测试应用。由 A 确认部署名称可解析，并用同一测试账号从 RD Web 下载两个原始 .rdp 文件。
3. 对两份文件分别运行实验矩阵中的 `-RdpFile … -ValidateOnly` 命令。结构检查通过后先启动记事本，再以同一账号启动第二款应用，保持两者同时打开。凭据由操作者在系统界面输入。遇到证书或身份验证错误时记录脱敏错误，交部署管理员核查。
4. 在 A 打开一个本地窗口，实际排出“远程应用一／本地窗口／远程应用二”的前后顺序。分别记录两个独立窗口、交错遮挡、任务栏条目及分组、Alt+Tab 切换、各窗口调整大小。与 B 同步连接和断开时刻，请本地操作者记录物理屏幕、锁屏、当前会话及断开后会话状态。首轮通过后继续实验矩阵中的重连、输入和显示测试。
5. 若只有 Windows 11 Pro 对照条件，先取得 B 所有者对远程桌面开关、测试账号及可信私网范围的授权。由 B 记录原配置，保留 NLA 和本地访问能力，再由 A 用 mstsc 测完整桌面。单列连接、控制台和断开结果；两个 RemoteApp 的窗口验收继续标记为未验证。
6. 将本轮脱敏实测写入 TEST_REPORT.md 与 PROGRESS.md。每项写“通过／失败／部分通过／未验证”、观察端及证据。即使宿主暂缺，也请完成 A 端预检和记录，并写明下一步由谁提供什么。凭据、私有地址、主机及域名、原始 .rdp 和原始日志仅走认可的私有渠道。
