<#
.DESCRIPTION
    Best practice snippets.
.NOTES
    Auther: Kennet Morales
    Github: https://github.com/swiftlyll
    Date: 2025-04-23
#>


<# home directory #>
# curlys allow the var to include special chars (:, %, #, -, etc.) treating them as literals
# avoids worst case being wrongly declared, example: ${env:ProgramFiles(x86)}
$homePath = ${env:USERPROFILE}

<# functions #>
# name function ps1 files after the function, example using below: Add-Function.ps1
function Add-Function {
    [CmdletBinding()] # always have
    param (
        # validate not null or empty, most important for me
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]] # allows for array of strings, ex. $nums = @("one","two")
        $ParamZero,
        # allow null mandatory param
        [Parameter(Mandatory=$true)]
        [AllowNull()] # same as $null
        [String] # single string only
        $ParamOne,
        # allow empty string
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()] # same as ""
        $ParamTwo,
        # validate using regex
        [Parameter(Mandatory = $true)]
        [ValidatePattern("[0-9][0-9][0-9][0-9]")]
        [String[]]
        $ParamThree
    )
    begin {
        # optional: runs without processing any input put into the function as a form of prep
    }
    process { # at least have this one, will run based off function input
        Write-Output "Main script stuff."
    }
}