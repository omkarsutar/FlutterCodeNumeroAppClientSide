$oldName = 'package:flutter_supabase_order_app_mobile/'
$newName = 'package:numero_shastra/'

Get-ChildItem -Path lib,test -Filter *.dart -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName
    $newContent = $content -replace $oldName, $newName
    if ($content -ne $newContent) {
        $newContent | Set-Content $_.FullName
        Write-Host "Updated: $($_.FullName)"
    }
}
