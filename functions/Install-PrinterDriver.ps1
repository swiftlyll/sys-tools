<#
.DESCRIPTION
    Generic printer driver installation script. This will also work for Win32 deployments.
.NOTES
    Author: Kennet Morales
    Github: https://github.com/swiftlyll
    Date: November 18, 2024
#>

. .\Write-Log

function Install-PrinterDriver {
    [CmdletBinding()]
    param (
    [Parameter(Position = 0, Mandatory)]
    [ValidateNotNullOrEmpty()]    
    [string] 
    $DriverPackagePath,
    [Parameter(Position = 1, Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] 
    $PrinterDriver
    )
    process {
        <# check for 64-bit session #>
        if ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
            Write-Log "Running 32-bit PowerShell"
            Write-Log "Attempting to switch to 64-bit session"
            try {
                & "$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $scriptPath            
            }
            catch {
                Write-Log "Failed to start 64-bit session" -ErrorLog
                Write-Log "Terminating process" 
                Exit 1
            }
        } 
        else {
            try {
                Write-Log "Running 64-bit PowerShell"
                
                # install driver store
                Write-Log "Installing driver store $DriverPackagePath"
                pnputil.exe /add-driver $DriverPackagePath
                
                # install driver
                Write-Log "Installing driver $PrinterDriver"
                Add-PrinterDriver -Name $PrinterDriver -ErrorAction Stop
                Write-Log "Driver installation complete"
            }
            catch {
                Write-Log "Error istalling driver" -ErrorLog
                Write-Log "Verify INF file and/or driver name are correct" -ErrorLog
            }
        }
    }
}