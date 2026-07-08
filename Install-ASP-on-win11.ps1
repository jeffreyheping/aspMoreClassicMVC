#Requires -RunAsAdministrator

# 仅保留叶子功能，父级依赖由 -All 参数自动安装，无冗余
$features = @(
    "IIS-ASP",                  # Classic ASP 核心引擎
    "IIS-StaticContent",        # 静态文件（html/css/js/图片）
    "IIS-DefaultDocument",      # 默认文档（访问目录自动加载 default.asp）
    "IIS-HttpErrors",           # HTTP 错误页面
    "IIS-HttpLogging",          # 访问日志
    "IIS-RequestFiltering",     # 基础请求安全筛选
    "IIS-ManagementConsole"     # IIS 管理器图形界面
)

Write-Host "正在安装 IIS + Classic ASP 组件..." -ForegroundColor Yellow
Enable-WindowsOptionalFeature -Online -FeatureName $features -All -NoRestart | Out-Null

$appcmd = "$env:SystemRoot\system32\inetsrv\appcmd.exe"

Write-Host "正在配置 ASP 运行参数..." -ForegroundColor Yellow
# 启用父路径（传统 ASP 项目必备，支持 ../ 相对路径 include）
& $appcmd set config /section:asp /enableParentPaths:"True" /commit:apphost
# 向浏览器发送详细脚本错误，方便调试
& $appcmd set config /section:asp /scriptErrorSentToBrowser:"True" /commit:apphost
# 设置默认脚本语言为 VBScript
& $appcmd set config /section:asp /defaultLanguage:"VBScript" /commit:apphost

Write-Host "正在配置应用池兼容性（32位 + 经典管道模式）..." -ForegroundColor Yellow
# 启用 32 位应用池：解决 VBScript 引擎内存异常、旧 COM 组件兼容问题
& $appcmd set apppool "DefaultAppPool" /enable32BitAppOnWin64:"True"
# 切换为经典托管管道模式：复现老版本 IIS 请求处理逻辑，规避 ASP 0240 引擎异常
& $appcmd set apppool "DefaultAppPool" /managedPipelineMode:"Classic"

Write-Host "正在重启 IIS 使配置生效..." -ForegroundColor Yellow
iisreset /restart | Out-Null

Write-Host "`n安装与配置全部完成！" -ForegroundColor Green
Write-Host "测试地址：http://localhost/test.asp"
Write-Host "IIS 管理器：inetmgr"
Write-Host "网站根目录：C:\inetpub\wwwroot"
Write-Host "`n已启用兼容配置：32 位应用池 + 经典托管管道模式"