# 项目进度

当前进行 Phase 0 和 Phase 1 客户端预检。仓库已有远端历史，初始提交仅含 README。已建立原生客户端启动器、配置检查、自动预检和 RDS 实验说明。

实际融合测试需要获授权访问的 Windows Server RDS 会话部署、已发布应用及测试账号。普通 Windows 的相关对照需要第二台获授权的 Windows 设备。测试状态见 [测试报告](TEST_REPORT.md)。网络集成仍处于候选验证。

Windows PowerShell 自动预检及 EasyTier v2.6.4 回环状态查询已通过。下一步取得授权 RDS 实验宿主，执行双应用窗口、输入和重连矩阵。

已补充启动参数回归。测试捕获 mstsc 调用并核对原文件哈希。连接与独立窗口仍需授权 RDS 实验环境。
