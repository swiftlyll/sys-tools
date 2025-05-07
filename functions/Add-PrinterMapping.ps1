<#
.DESCRIPTION
    WORK IN PROGRESS
    Maps a printer based on provided information. Ensure driver is installed beforehand.
.NOTES
    Auther: Kennet Morales
    Github: https://github.com/swiftlyll
    Date: 2025-05-06
#>

. .\Write-Log.ps1

function Add-PrinterMapping {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $PrinterName,
        [Parameter(Mandatory = $true)]
        [String]
        $DriverName,
        [Parameter(Mandatory = $true)]
        [String]
        $PrinterPort
    )
    process {
        # validate required ports not in use
        $ports = Get-PrinterPort
        foreach ($port in $ports) {
            if ($PrinterPort -match $port) {
                Write-Log "Required printer port $(port.Name) is in use"
                # add section
                # existing printer = get-printer -computername $port.name
                # if required port is being used by a printer with the same driver and name: "confirmed printer $printername is already mapped"
                    # ex if (existing.name -eq printername -and existing.driver -eq drivername)
                    # return
                # if required port is being used by a printer with the same driver but different name, rename printer instead
                    # ex if (existing.name -ne printername -and existing.driver -eq drivername)
                    # return
                # if switch -Force is used, remove old mapping and replace with new one. Remove existing printer, remove exisisting printer port (better than the old one being misconfigured), continute mapping.
                    # ex if ($Force)
                    # script continues as normal
            }
        }

        # start printer mapping
        Write-Log "Initializing printer mapping for $PrinterName"
        
        # create printer port
        try {
            Write-Log "Attempting to create printer port $PrinterPort"
            Add-PrinterPort -Name $PrinterPort -PrinterHostAddress $PrinterPort -ErrorAction Stop
            Write-Log "Successfully created printer port $PrinterPort"
        }
        catch {
            Write-Log "Failed to create printer port $PrinterPort" -ErrorLog
            return
        }

        # create printer
        try {
            Write-Log "Attempting to create printer $PrinterName"
            Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PrinterPort -ErrorAction Stop
            Write-Log "Successfully created printer $PrinterName"
        }
        catch {
            Write-Log "Failed to create printer $PrinterName" -ErrorLog
            return
        }

        # configure default printer preferences: B&W + no duplex
        Write-Log "Configuring printer preferences"
        Set-PrintConfiguration -PrinterName $PrinterName -Color:$false -DuplexingMode OneSided -ErrorAction SilentlyContinue
        
        Write-Log "Printer mapping for $PrinterName complete"
    }
}