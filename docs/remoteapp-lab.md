# RemoteApp 融合实验

## 环境

主控端使用 Windows 11 与系统自带的 mstsc。宿主对照组使用受支持的 Windows Server RDS 会话部署，包含连接代理和会话集合，配置适用的 RDS CAL、受信任的证书及专用测试账号。通过现有受信任的专用网络访问。使用 RDS 控制台发布记事本及第二个已授权的测试应用，从 RD Web 下载各自的原始 RDP 文件。

另设普通 Windows 11 Pro 或 Enterprise 宿主作为对照。记录系统版本、更新、RDP 配置及控制台会话行为。先用普通桌面会话验证到该宿主的连接能力。RemoteApp 宿主验证以该环境存在适用的官方发布方法为前提，缺失时记录为无支持的测试路径。

## 从仓库根目录运行

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\Invoke-RemoteAppProbe.ps1 -Inspect
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\tests\Test-RemoteAppProbe.ps1
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\Invoke-RemoteAppProbe.ps1 -RdpFile 'C:\Lab\Notepad.rdp' -ValidateOnly
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\Invoke-RemoteAppProbe.ps1 -RdpFile 'C:\Lab\Notepad.rdp'
~~~

仅选择从已知 RDS 部署下载的配置。结构检查只用于识别 RemoteApp 配置。mstsc 负责连接、签名信任判断、服务器身份验证和凭据交互。复用部署导出的路由、证书及重定向设置。首次测试可在 RDS 策略中关闭驱动器重定向并按需开启剪贴板。

## 观察和判定

1. 启动记事本，再以同一账号启动第二个已发布应用。确认有独立可调整的窗口，可与本地窗口交错，任务栏和 Alt+Tab 均能切换，记录任务栏分组。
2. 测试最大化、最小化、Snap、尺寸改变后的布局、右键菜单、下拉菜单和模态文件对话框。
3. 在测试记事本双向复制合成文本，再验证中文和日文 IME 的组合输入。记录客户端和宿主的输入法设置。
4. 在记事本保留一段未保存的合成文本。短暂断开实验网络，在会话超时前通过同一账号和配置重新打开，检查文本和会话是否恢复。
5. 在两个显示器之间移动窗口，记录各屏缩放、字体清晰度及焦点。对 GPU 编码或渲染分别记录驱动、策略及计数器证据。
6. 由宿主本地操作者观察锁屏、当前会话、物理显示器内容及断开后的状态。在报告中记录每项为通过、失败、部分通过或未验证。
