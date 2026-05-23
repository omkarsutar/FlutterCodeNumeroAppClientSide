$replacements = @{
    'com.example.flutterSupabaseOrderAppMobile' = 'com.numeroshastra.client'
    'com.example.flutter_supabase_order_app_mobile' = 'com.numeroshastra.client'
    'flutter_supabase_order_app_mobile' = 'numero_shastra'
    'com.example' = 'com.numeroshastra'
}

$files = @(
    "windows/runner/Runner.rc",
    "windows/runner/main.cpp",
    "windows/CMakeLists.txt",
    "macos/Runner.xcodeproj/project.pbxproj",
    "macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme",
    "linux/runner/my_application.cc",
    "linux/CMakeLists.txt",
    "ios/Runner.xcodeproj/project.pbxproj",
    "README.md"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        foreach ($key in $replacements.Keys) {
            $content = $content -replace [regex]::Escape($key), $replacements[$key]
        }
        $content | Set-Content $file
        Write-Host "Updated configuration: $file"
    }
}
