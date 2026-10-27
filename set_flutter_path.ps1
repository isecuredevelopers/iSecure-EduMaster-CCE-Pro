$flutterBin = "D:\flutter_windows_3.38.9-stable\flutter\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$flutterBin*") {
    $updatedPath = "$flutterBin;$currentPath"
    [Environment]::SetEnvironmentVariable("Path", $updatedPath, "User")
    Write-Host "SUCCESS: Flutter path added to User Environment Variable: $flutterBin"
} else {
    Write-Host "ALREADY_PRESENT: Flutter path is already in User PATH: $flutterBin"
}

# Verify
$newPath = [Environment]::GetEnvironmentVariable("Path", "User")
Write-Host "Current User PATH starts with: $($newPath.Substring(0, [Math]::Min(120, $newPath.Length)))"
