Add-Type -AssemblyName System.Windows.Forms
$dlg = New-Object System.Windows.Forms.OpenFileDialog
$dlg.Filter = "Image Files (*.png;*.jpg;*.jpeg;*.webp)|*.png;*.jpg;*.jpeg;*.webp|All Files (*.*)|*.*"
$dlg.Title = "शाळेचा लोगो निवडा (Select School Logo)"
$dlg.Multiselect = $false
$result = $dlg.ShowDialog()
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    Write-Output $dlg.FileName
}
