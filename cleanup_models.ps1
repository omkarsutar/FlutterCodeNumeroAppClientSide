$path = "lib\features\postLogin\birthdate_analysis\model\numerology_models.dart"
$content = Get-Content $path -Raw
$content = $content -replace "case AppLanguage\.english:\r?\n\s+default:", "case AppLanguage.english:"
Set-Content $path $content
Write-Output "Cleanup complete."
