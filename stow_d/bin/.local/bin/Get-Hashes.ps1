param(
    [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true)]
    [String[]]$Files,

    #[ValidateSet("MD5","SHA1","SHA256","SHA384","SHA512")]
    #[string]$Algorithm = "SHA256",
    # Don't put ValidateSet here if you want to accept CSV from cmd.exe.
    #[String[]]$Algorithms = @("SHA256"),
    [String[]]$Algorithms = @("MD5","SHA1","SHA256","SHA384","SHA512"),

    [ValidateSet("Normal","Hidden","Registry")]
    [String]$RunType = "Normal"
)

# Canonical allowed list.
$validArgs = "MD5","SHA1","SHA256","SHA384","SHA512"

#PS C:\Users\User> Get-Help ?
#Name    Category    Module    Synopsis
#----    --------    ------    --------
#%       Alias                 ForEach-Object
#?       Alias                 Where-Object
#h       Alias                 Get-History
#r       Alias                 Invoke-History

# Normalize if we got a single CSV string like "MD5,SHA1".
if ($Algorithms -and $Algorithms.count -eq 1 -and $Algorithms[0] -match ',') {
    $Algorithms = $Algorithms[0] -split ',' | % { $_.Trim() }
}

# Trim any stray quotes and normalize case.
$Algorithms = $Algorithms | % { $_.Trim('"',"'") } | % { $_.ToUpperInvariant() }

# Handle ALL.
if ($Algorithms -Contains 'ALL') {
    $Algorithms = $validArgs
}

# Validate elements.
$bad = $Algorithms | ? { $validArgs -NotContains $_ }
if ($bad) {
    throw "Invalid algorithm(s): $($bad -join ', '). Valid options: $($validArgs -join ', ')"
}

# From here $Algorithms contains only upper-case valid names.
# E.g. "MD5","SHA1" etc.



# Bad because of horizontal scroll appereance
#$host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size (500, $host.UI.RawUI.BufferSize.Height)



# ComboBox, only 1 item.
#function Select-Algorithm {
#    Add-Type -AssemblyName System.Windows.Forms
#
#    $form = New-Object Windows.Forms.Form
#    $form.Text = "Select Hash Algorithm"
#    $form.Size = New-Object Drawing.Size(300,150)
#    $form.StartPosition = "CenterScreen"
#
#    $combo = New-Object Windows.Forms.ComboBox
#    $combo.Location = New-Object Drawing.Point(50,20)
#    $combo.Size = New-Object Drawing.Size(200,20)
#    $combo.DropDownStyle = 'DropDownList'
#    $combo.Items.AddRange(@("MD5","SHA1","SHA256","SHA384","SHA512"))
#    $combo.SelectedIndex = 2   # default SHA256
#    $form.Controls.Add($combo)
#
#    $okButton = New-Object Windows.Forms.Button
#    $okButton.Text = "OK"
#    $okButton.Location = New-Object Drawing.Point(50,60)
#    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
#    $form.AcceptButton = $okButton
#    $form.Controls.Add($okButton)
#
#    $cancelButton = New-Object Windows.Forms.Button
#    $cancelButton.Text = "Cancel"
#    $cancelButton.Location = New-Object Drawing.Point(150,60)
#    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
#    $form.CancelButton = $cancelButton
#    $form.Controls.Add($cancelButton)
#
#    $result = $form.ShowDialog()
#
#    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
#        return $combo.SelectedItem
#    }
#    else {
#        return $null
#    }
#}

# ListBox, multiple items
function Select-Algorithms {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object Windows.Forms.Form
    $form.Text = "Select Hash Algorithms"
    $form.Size = New-Object Drawing.Size(350,350)
    $form.StartPosition = "CenterScreen"

    # Multi-select listbox
    $listBox = New-Object Windows.Forms.ListBox
    $listBox.Location = New-Object Drawing.Point(20,20)
    $listBox.Size = New-Object Drawing.Size(200,200)
    $listBox.SelectionMode = 'MultiExtended'  # allows Ctrl+Click and Shift+Click
    $listBox.Items.AddRange(@("MD5","SHA1","SHA256","SHA384","SHA512"))
    $listBox.SelectedIndex = 2   # default select SHA256
    $form.Controls.Add($listBox)

    # Select All button
    $btnSelectAll = New-Object Windows.Forms.Button
    $btnSelectAll.Text = "Select All"
    $btnSelectAll.Location = New-Object Drawing.Point(230,20)
    $btnSelectAll.Add_Click({
        for ($i=0; $i -lt $listBox.Items.Count; ++$i) {
            $listBox.SetSelected($i,$true)
        }
    })
    $form.Controls.Add($btnSelectAll)

    # Deselect All button
    $btnDeselectAll = New-Object Windows.Forms.Button
    $btnDeselectAll.Text = "Deselect All"
    $btnDeselectAll.Location = New-Object Drawing.Point(230,60)
    $btnDeselectAll.Add_Click({
        for ($i=0; $i -lt $listBox.Items.Count; ++$i) {
            $listBox.SetSelected($i,$false)
        }
    })
    $form.Controls.Add($btnDeselectAll)

    # OK button
    $okButton = New-Object Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Location = New-Object Drawing.Point(80,240)
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    # Cancel button
    $cancelButton = New-Object Windows.Forms.Button
    $cancelButton.Text = "Cancel"
    $cancelButton.Location = New-Object Drawing.Point(180,240)
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    # Show form
    $result = $form.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $listBox.SelectedItems
    }
    else {
        return $listBox.SelectedItems  # default
        #return @()  # nothing selected
    }
}

# $true - visible console (likely normal run)
# $false - no console (likely -WindowStyle Hidden, or run from Explorer context menu, scheduled task, etc.)
Add-Type -Namespace WinAPI -Name NativeMethods -MemberDefinition @"
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
"@



[Boolean]$hasConsole = [WinAPI.NativeMethods]::GetConsoleWindow() -ne [IntPtr]::Zero

if (-not $PSBoundParameters.ContainsKey('Algorithm')) {
    if ($RunType -eq "Normal" -and $hasConsole) {
        # Force manual algorithms selection if no Algorithms
        # provided, RunType="Normal" and $hasConsole=$true
        $Algorithms = Select-Algorithms
    }
}


# --- REGISTRY RUN (context menu, etc): CSV-structured hashes to session file.
if ($RunType -eq "Registry") {
    $sessionFile = "$env:TEMP\Get-Hashes-Session.txt"
    $lockFile    = "$env:TEMP\Get-Hashes-Session.lock"
    $smutex = New-Object System.Threading.Mutex($false, "Global\GetHashesSessionMutex")
    $smutex.WaitOne() | Out-Null

    $fullPath = Get-Item -LiteralPath $Files[0]
    $props = [ordered]@{
        Path = $fullPath.FullName
    }
    #Write-Host "$fullPath`n$Algorithms`t$($Algorithms.GetType())"
    foreach ($alg in $Algorithms) {
        #Write-Host "$alg`t$($alg.GetType())"
        try {
            $hash = (Get-FileHash -LiteralPath $fullPath -Algorithm $alg).Hash.ToLower()
            #Write-Host "$hash"
            $props[$alg] = $hash
        }
        catch {
            $props[$alg] = "ERROR: $_"
        }
    }
    $props = [PSCustomObject]$props

    # --- Critical section: append atomically.
    $props | Export-Csv -Path $sessionFile -Append -NoTypeInformation -Encoding UTF8

    # Touch lock file (for timestamp).
    Set-Content -LiteralPath $lockFile -Value (Get-Date)
    $smutex.ReleaseMutex()
    $smutex.Dispose()

    # Sleep for a while delaying finalizer.
    Start-Sleep -Seconds 1.5
    $lockFile = "$env:TEMP\Get-Hashes-Session.lock"
    $fmutex = New-Object System.Threading.Mutex($false, "Global\GetHashesFinalizerMutex")
    $fmutex.WaitOne() | Out-Null
    if (Test-Path $lockFile) {
        # Check if the file is stale enough to consider whether the last record was written.
        $age = (Get-Date) - (Get-Item $lockFile).LastWriteTime
        if ($age -gt [TimeSpan]::FromSeconds(1)) {
            $sessionFile = "$env:TEMP\Get-Hashes-Session.txt"

            # Avoid multiple Set-Clipboard invocations.
            if (Test-Path $sessionFile) {
                $data = [PSCustomObject[]](Import-Csv -Path $sessionFile -Encoding UTF8) | Sort-Object Path
                $maxLen = ($data | % { $_.PSObject.Properties.Name } | Measure-Object Length -Maximum ).Maximum
                # Format nicely and set clipboard.
                $text = ($data | % {
                    $lines = $_.PSObject.Properties | % {
                        $name = $_.Name.PadRight($maxLen)  # pad to max length
                        "$name : $($_.Value)"
                    }
                    $lines -join "`r`n"
                }) -join "`r`n`r`n"
                if ($text) {
                    Set-Clipboard -Value $text
                }
            } else { Write-Host "NO SESSION FILE" }

            Remove-Item $sessionFile,$lockFile -ErrorAction Ignore
        }
    } else { Write-Host "NO LOCK FILE" }
    $fmutex.ReleaseMutex()
    $fmutex.Dispose()
    return
}



# Build objects.
$objects = foreach ($f in $Files) {
    $fullPath = Get-Item -LiteralPath $f
    $props = [ordered]@{
        Path = $fullPath
    }
    foreach ($alg in $Algorithms) {
        #$alg = $Algorithm
        try {
            $hash = (Get-FileHash -LiteralPath $f -Algorithm $alg).Hash.ToLower()
            $props[$alg] = $hash
        }
        catch {
            $props[$alg] = "ERROR: $_"
        }
    }
    [PSCustomObject]$props
}

# Copy to clipboard
#$results -join "`r`n" | Set-Clipboard

# 1. Console (pretty table, wrapped)
#$objects | Format-Table -AutoSize -Wrap
$objects | Format-List

# 2. Clipboard (text, human-readable)
#$objects | Format-Table -AutoSize -Wrap | Out-String | Set-Clipboard
$objects | Format-List | Out-String -Width 200 | Set-Clipboard

# 3. Log file (structured data, not truncated)
#$objects | Export-Csv -NoTypeInformation -Append -Path "$env:TEMP\Get-Hashes.csv"










# --- REGISTRY RUN (context menu, etc): Format-List hashes to session file.
#if ($RunType -eq "Registry") {
#    $sessionFile = "$env:TEMP\Get-Hashes-Session.txt"
#    $lockFile    = "$env:TEMP\Get-Hashes-Session.lock"
#    $smutex = New-Object System.Threading.Mutex($false, "Global\GetHashesSessionMutex")
#    # Block until free.
#    $smutex.WaitOne() | Out-Null
#
#    $fullPath = Get-Item -LiteralPath $Files[0]
#    $props = [ordered]@{
#        Path = $fullPath
#    }
#    #Write-Host "$fullPath`n$Algorithms`t$($Algorithms.GetType())"
#    foreach ($alg in $Algorithms) {
#        #Write-Host "$alg`t$($alg.GetType())"
#        try {
#            $hash = (Get-FileHash -LiteralPath $fullPath -Algorithm $alg).Hash.ToLower()
#            #Write-Host "$hash"
#            $props[$alg] = $hash
#        }
#        catch {
#            $props[$alg] = "ERROR: $_"
#        }
#    }
#    $props = [PSCustomObject]$props
#
#    # --- Critical section: append atomically.
#    # 'OpenOrCreate', 'Append'
#    $fs = [System.IO.File]::Open($sessionFile, 'Append', 'Write', 'None')
#    try {
#        $sw = New-Object System.IO.StreamWriter($fs)
#        #$sw.BaseStream.Seek(0, 'End') | Out-Null
#        #$sw.WriteLine("$($hash.Hash) $($hash.Path)")
#        $sw.Write("$(($props | Format-List | Out-String -Width 200 -Stream | % { $_.Trim() }) -ne """" -join ""`r`n"")`r`n`r`n")
#        $sw.Flush()
#        $sw.Close()
#        #$props | Export-Csv -NoTypeInformation -Append -Path $sessionFile -Encoding UTF8
#    } finally {
#        $fs.Close()
#        #$smutex.ReleaseMutex()
#        #$smutex.Dispose()
#    }
#
#    # Touch lock file (for timestamp).
#    Set-Content -LiteralPath $lockFile -Value (Get-Date)
#    $smutex.ReleaseMutex()
#    $smutex.Dispose()
#
#
#    # Schedule finalizer.
#    #Start-Process powershell -ArgumentList @(
#    #    '-NoProfile','-ExecutionPolicy','Bypass','-Command',
#    #    "& {
#    #        Start-Sleep -Seconds 2
#    #        $lockFile = '$lockFile'
#    #        if (Test-Path $lockFile) {
#    #            $age = (Get-Date) - (Get-Item $lockFile).LastWriteTime
#    #            if ($age -gt [TimeSpan]::FromSeconds(1)) {
#    #                $sessionFile = '$sessionFile'
#    #                $data = Get-Content $sessionFile
#    #                Set-Clipboard ($data -join \"`r`n\")
#    #                Remove-Item $sessionFile,$lockFile -ErrorAction Ignore
#    #            }
#    #        }
#    #    }"
#    #) -WindowStyle Hidden
#
#    # Does not work if parent exits early.
#    #Start-Job {
#    Start-Sleep -Seconds 2
#    $lockFile = "$env:TEMP\Get-Hashes-Session.lock"
#    if (-not (Test-Path $lockFile)) { return }
#    $age = (Get-Date) - (Get-Item $lockFile).LastWriteTime
#    if ($age -gt [TimeSpan]::FromSeconds(1)) {
#        $sessionFile = "$env:TEMP\Get-Hashes-Session.txt"
#        $fmutex = New-Object System.Threading.Mutex($false, "Global\GetHashesFinalizerMutex")
#        $fmutex.WaitOne() | Out-Null
#
#        # Avoid multiple Set-Clipboard invocations.
#        if (Test-Path $sessionFile) {
#            $data = Get-Content $sessionFile
#            if ($data.count -gt 2) {
#                $data = $data[0..($data.count-2)]
#            }
#            #$data = Get-Content -Raw -Encoding UTF8 $sessionFile
#            if ($data) {
#                Set-Clipboard ($data -join "`r`n")
#            }
#        }
#        Remove-Item $sessionFile,$lockFile -ErrorAction Ignore
#
#        $fmutex.ReleaseMutex()
#        $fmutex.Dispose()
#    }
#    #} | Out-Null
#
#    return
#}

# --- REGISTRY RUN (context menu, etc): JSON-structured hashes to session file.
#if ($RunType -eq "Registry") {
#    $sessionFile = "$env:TEMP\Get-Hashes-Session.txt"
#    $lockFile    = "$env:TEMP\Get-Hashes-Session.lock"
#    $smutex = New-Object System.Threading.Mutex($false, "Global\GetHashesSessionMutex")
#    $smutex.WaitOne() | Out-Null
#
#    $fullPath = Get-Item -LiteralPath $Files[0]
#    $props = [ordered]@{
#        Path = $fullPath.FullName
#    }
#    #Write-Host "$fullPath`n$Algorithms`t$($Algorithms.GetType())"
#    foreach ($alg in $Algorithms) {
#        #Write-Host "$alg`t$($alg.GetType())"
#        try {
#            $hash = (Get-FileHash -LiteralPath $fullPath -Algorithm $alg).Hash.ToLower()
#            #Write-Host "$hash"
#            $props[$alg] = $hash
#        }
#        catch {
#            $props[$alg] = "ERROR: $_"
#        }
#    }
#    $props = [PSCustomObject]$props
#    $propsJson = (ConvertTo-Json $props -Compress)
#
#    # --- Critical section: append atomically.
#    Add-Content -Path $sessionFile -Value $propsJson -Encoding UTF8
#    #$props | Export-Csv -NoTypeInformation -Append -Path $sessionFile -Encoding UTF8
#
#    # Touch lock file (for timestamp).
#    Set-Content -LiteralPath $lockFile -Value (Get-Date)
#    $smutex.ReleaseMutex()
#    $smutex.Dispose()
#
#    # Sleep for a while delaying finalizer.
#    Start-Sleep -Seconds 1.5
#    $lockFile = "$env:TEMP\Get-Hashes-Session.lock"
#    $fmutex = New-Object System.Threading.Mutex($false, "Global\GetHashesFinalizerMutex")
#    $fmutex.WaitOne() | Out-Null
#    if (Test-Path $lockFile) {
#        # Check if the file is stale enough to consider whether the last record was written.
#        $age = (Get-Date) - (Get-Item $lockFile).LastWriteTime
#        if ($age -gt [TimeSpan]::FromSeconds(1)) {
#            $sessionFile = "$env:TEMP\Get-Hashes-Session.txt"
#
#            # Avoid multiple Set-Clipboard invocations.
#            if (Test-Path $sessionFile) {
#                $data = [PSCustomObject[]](Get-Content -Encoding UTF8 $sessionFile | % { ConvertFrom-Json $_ })
#                $maxLen = ($data | % { $_.PSObject.Properties.Name } | Measure-Object Length -Maximum ).Maximum
#                #([PSCustomObject]@{
#                #    "data" = $data
#                #    "data.PSObject" = $data.PSObject
#                #    "data.PSObject.Properties" = $data.PSObject.Properties
#                #    "data.PSObject.Properties.Name" = $data.PSObject.Properties.Name
#                #    "maxLen" = $maxLen
#                #}) #| % { "$($_.PSObject.Properties.Name) : $($_.PSObject.Properties.Value)" -join "`r`n" })
#                # Format nicely and set clipboard.
#                $text = ($data | % {
#                    $lines = $_.PSObject.Properties | % {
#                        $name = $_.Name.PadRight($maxLen)  # pad to max length
#                        "$name : $($_.Value)"
#                    }
#                    $lines -join "`r`n"
#                }) -join "`r`n`r`n"
#                if ($text) {
#                    Set-Clipboard -Value $text
#                }
#            } else { Write-Host "NO SESSION FILE" }
#
#            Remove-Item $sessionFile,$lockFile -ErrorAction Ignore
#        }
#    } else { Write-Host "NO LOCK FILE" }
#    $fmutex.ReleaseMutex()
#    $fmutex.Dispose()
#    return
#}