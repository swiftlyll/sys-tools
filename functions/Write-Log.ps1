<#
.SYNOPSIS
    Alternative to Write-Output that includes date and time.

.DESCRIPTION
    Function will create a log message with time and date that will then get stored in either the default
    log folder location, or a user specified location.

.EXAMPLE
    # default use, can be used without specifying $LogMessage
    Write-Log -LogMessage "Action A completed successfully"

.EXAMPLE
    # specify alternative log folder
    Write-Log -LogMessage "Action B completed successfully" -$LogFileDirectory "C:\temp\my-logs"

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
        $LogFileDirectory
    )
    begin {
        $scriptName = (Split-Path -Leaf ${Global:MyInvocation}.MyCommand.Definition).Replace('.ps1','') # uses name of the script calling this function
        $defaultLogFileDirectory = "C:\ps-logs\$scriptName"
    }
    process {
        # cleanup for log directory path
        if ($LogFileDirectory) {
            $LogFileDirectory = $LogFileDirectory.Trim() # clean leading/trailing whitespace
            $isUserProvidedPath = $true
        } else {
            $LogFileDirectory = $defaultLogFileDirectory # fallback to default path
        }
        # verify log directory is a valid path. if checks fail disable log storage.
        if (-not (Test-Path -LiteralPath $LogFileDirectory -PathType Container)) {
            try {
                # attempt to create directory
                New-Item -Path $LogFileDirectory -ItemType Directory -ErrorAction Stop | Out-Null
            }
            catch {
                <#Do this if a terminating exception happens#>
            }
            
            
            
            write-output "test-path failed"
            # if default path is being used and is invalid, try creating
            if ($LogFileDirectory -eq $defaultLogFileDirectory) {
                try {
                    "attempt to create default path $LogFileDirectory"
                    New-Item -Path $LogFileDirectory -ItemType Directory -ErrorAction Stop | Out-Null
                    "success creating def path"
                }
                catch {
                    "failed to create def"
                    "disable log storage"
                    # disable storage due to default loc fail
                    $DisableLogStorage = $true
                }
            }
            # if user path is being used and is invalid, else try creating (implement default log storage location failover)
            else {          
                "attempt to create user path $LogFileDirectory"
                try {
                    New-Item -Path $LogFileDirectory -ItemType Directory -ErrorAction Stop | Out-Null
                }
                catch {
                    # if failed to create user path, try default
                    write-output "failed to create user path, checking default existance"
                    # first check if it already exists to prevent overwritting
                    if ((Test-Path -Path $defaultLogFileDirectory)) {
                        write-output "found existing def and assigned"
                        $LogFileDirectory = $defaultLogFileDirectory
                    }
                    # if not try creating default dir
                    else {
                        try {
                            "creating def"
                            $LogFileDirectory = $defaultLogFileDirectory
                            New-Item -Path $LogFileDirectory -ItemType Directory -ErrorAction Stop | Out-Null
                            "def created"
                        }
                        catch {
                            # disable storage due to default loc fail
                            write-output "default failover failed"
                            $DisableLogStorage = $true
                        }
                    }
                }
            }    
        }
        else {
            "path $LogFileDirectory exists"
        }
    }
}

Write-Log "Test"