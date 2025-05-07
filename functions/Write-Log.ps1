<#
.SYNOPSIS
    Creates a log message.

.DESCRIPTION
    Function will output a log message with date/time that will then get stored in either the default
    location, or a user specified location.

.EXAMPLE
    # default use, can be used without specifying $LogMessage
    Write-Log -LogMessage "Action A completed successfully"

.EXAMPLE
    # specify alternative log folder
    Write-Log -LogMessage "Action B completed successfully" -LogDirectory "C:\temp\my-logs"

.EXAMPLE
    # check why logs are not getting stored with debug messages
    Write-Log -LogMessage "Test" -LogDirectory "C:\temp" -Debug

.NOTES
    Auther: Kennet Morales
    Github: https://github.com/swiftlyll
    Date: 2025-04-23
#>

function Write-Log {
    [CmdletBinding(DefaultParameterSetName = "Log")]
    param (
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = "Log")]
        [ValidateNotNullOrEmpty()]
        [String]
        $LogMessage,
        [Parameter(Position = 1, Mandatory = $false, ParameterSetName = "Log")]
        [ValidatePattern("^[a-zA-Z]:")] # ensure valid path by checking drive letter is included
        [String]
        $LogDirectory,
        [Parameter(Position=2, ParameterSetName = "Log")]
        [switch] 
        $ErrorLog = $false,
        [Parameter(Position = 0,Mandatory = $true, ParameterSetName = "Info")]
        [switch] 
        $DisplayLogLocation = $false
    )
    begin {
        $scriptName = (Split-Path -Leaf ${Global:MyInvocation}.MyCommand.Definition).Replace('.ps1','') # uses name of the script calling this function
        $defaultLogDirectory = "C:\ps-logs\$scriptName"
    }
    process {
        # cleanup stored path in log dir var
        if ($LogDirectory) {
            $LogDirectory = $LogDirectory.Trim() # clean leading/trailing whitespace
            $isUserProvidedPath = $true # used for checks to remove unnecessary loop in case of failover
            Write-Debug "Using user provided path $LogDirectory for log storage"
        }
        else {
            $LogDirectory = $defaultLogDirectory # fallback to default path
            Write-Debug "Using default path $LogDirectory for log storage"
        }
        # verify log directory is a valid path. if checks fail disable log storage.
        if (-not (Test-Path -LiteralPath $LogDirectory -PathType Container)) {
            Write-Debug "Path $LogDirectory does not exist"
            try {
                # attempt to create directory
                Write-Debug "Attempting to create $LogDirectory"
                New-Item -Path $LogDirectory -ItemType Directory -ErrorAction Stop | Out-Null
                Write-Debug "Successfully created $LogDirectory"
            }
            catch {
                # if path is user provided, failover to default and try again
                Write-Debug "Failed to create $LogDirectory"
                if ($isUserProvidedPath) {
                    Write-Debug "Initiating failover to default path $defaultLogDirectory"
                    $LogDirectory = $defaultLogDirectory
                    if (-not (Test-Path -LiteralPath $LogDirectory -PathType Container)) {
                        try {
                            Write-Debug "Default path $LogDirectory does not exist"
                            Write-Debug "Attempting to create $LogDirectory"
                            New-Item -Path $LogDirectory -ItemType Directory -ErrorAction Stop | Out-Null
                            Write-Debug "Successfully created $LogDirectory"
                        }
                        catch {
                            Write-Debug "Failed to create $LogDirectory"
                            $disableLogStorage = $true
                            Write-Debug "Disabled log storage"
                        }
                    }
                    else {
                        Write-Debug "Confirmed path $LogDirectory exists"
                        Write-Debug "Failover to default path $LogDirectory successful"
                    }
                }
                # if path was already default but still failed then disabled log storage
                else {
                    $disableLogStorage = $true
                    Write-Debug "Disabled log storage"
                }
            }
        }
        else {
            Write-Debug "Confirmed path $LogDirectory exists"
        }
        # option to show log location
        if ($DisplayLogLocation) {
            Write-Verbose "Logs can be found inside $LogDirectory" -Verbose
            return
        }

        # create log message fields
        $logType = if ($ErrorLog) {"[ERROR]"} else {"[INFO]"}
        $timestamp = "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.ffff")]"

        # get date to append to log file name
        $date = Get-Date -Format 'yyyyMMdd'
        
        # craft log message
        if ($disableLogStorage) {
            Write-Output "$timestamp $logType $LogMessage"
        }
        else {
            Write-Output "$timestamp $logType $LogMessage" | Tee-Object -FilePath "$LogDirectory\logs_$date.txt" -Append
        }
    }
}