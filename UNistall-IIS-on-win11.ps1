#Requires -RunAsAdministrator

Write-Host "正在彻底卸载 IIS 全部组件..." -ForegroundColor Yellow
# 卸载根角色 + -All 参数递归移除所有子功能
$result = Disable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -All -NoRestart

Write-Host ""
if ($result.RestartNeeded) {
    Write-Warning "卸载完成，系统需要重启才能完全生效。"
} else {
    Write-Host "✓ 全部 IIS 组件已卸载" -ForegroundColor Green
}

Write-Host ""
Write-Host "提示："
Write-Host "  • C:\inetpub 网站目录不会自动删除，可手动清理"
Write-Host "  • 自定义的应用池、站点配置会随组件卸载一并清除"
