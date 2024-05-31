param (
    [string]$InputFile,
    [string]$OutputFile,
    [switch]$Vault,
    [switch]$Help
)
if ($Help -and ($InputFile -or $OutputFile -or $Vault))
{
    Write-Error "Invalid Use Of Parameters."
    exit
}

if ($Help) {
    $helpMessage = @"
    NAME
        MimikatzToCSV.ps1 - Script to parse Mimikatz sekurlsa::ekeys and vault::cred credentials into a CSV file.

    SYNOPSIS
        This script parses Mimikatz sekurlsa::ekeys and vault::cred credentials from a text file and exports the parsed data to a CSV file.

    SYNTAX
        .\MimikatzToCSV.ps1 [-InputFile] <string> [-OutputFile] <string> [-Vault] [-Help]

    DESCRIPTION
        The script reads a Mimikatz output file, extracts relevant credential information, and exports it to a specified CSV file.
        It supports parsing both sekurlsa::ekeys and vault::cred outputs, controlled by the -Vault switch.

    PARAMETERS
        -InputFile <string>
            The path to the Mimikatz output text file to be parsed.

        -OutputFile <string>
            The path to the CSV file where the parsed credentials will be saved.

        -Vault
            A switch to indicate if the input file contains vault::cred output. If this switch is set, the script will parse vault::cred credentials.

        -Help
            A switch to display this help message.

    EXAMPLES
        .\MimikatzToCSV.ps1 -InputFile "C:\Users\user\Documents\mimikatz_output.txt" -OutputFile "C:\Users\user\Documents\parsed_credentials.csv"

            This command parses sekurlsa::ekeys credentials from the specified input file and saves the parsed data to the specified output CSV file.

        .\MimikatzToCSV.ps1 -InputFile "C:\Users\user\Documents\mimikatz_output_vault.txt" -OutputFile "C:\Users\user\Documents\parsed_credentials_vault.csv" -Vault

            This command parses vault::cred credentials from the specified input file and saves the parsed data to the specified output CSV file.

        .\MimikatzToCSV.ps1 -Help

            This command displays the help message for the script.

    NOTES
        Author: Ismail Barrous
        Date: 30-05-2024
        Version: 1.0

        This script requires PowerShell 5.0 or later.
"@
    Write-Host $helpMessage
    exit
}

if (-not $InputFile -or -not $OutputFile)
{
    Write-Error "Mandatory Parameters Are Not Set. Use -Help To Show All Needed Parameters."
    exit
}
if (-not (Test-Path $InputFile)) {
    Write-Error "Invalid Mimikatz InputFile ! Check the file's existence or the associated permissions with it."
    exit
}

$parsedObjects = @()
$currentObject = $null
$keyListStarted = $false
$AllowedKeys = @("Username", "SID", "Domain", "Password", "Key List", "UserName", "Comment", "Credential")
$banner = @"
 __  __ _           _ _         _    _______     _____  _______      __
|  \/  (_)         (_) |       | |  |__   __|   / ____|/ ____\ \    / /
| \  / |_ _ __ ___  _| | ____ _| |_ ___| | ___ | |    | (___  \ \  / / 
| |\/| | | |_  |_ \| | |/ / _| | __|_  / |/ _ \| |     \___ \  \ \/ /  
| |  | | | | | | | | |   < (_| | |_ / /| | (_) | |____ ____) |  \  /   
|_|  |_|_|_| |_| |_|_|_|\_\__,_|\__/___|_|\___/ \_____|_____/    \/    

                            by $( [char]27 )[1;31mIsmail Barrous$( [char]27 )[0m
                            Version: $( [char]27 )[1;31m1.0$( [char]27 )[0m

"@
Write-Host "$banner"
Get-Content $InputFile | ForEach-Object {
    $line = $_.Trim()

    $InputType = "Authentication Id"

    if ($Vault){
        $InputType = "TargetName"
    }     

    if ($line -match "^$InputType\s*:\s*(.+)$") {
        if ($currentObject) {
            $parsedObjects += $currentObject
        }
        $currentObject = New-Object PSCustomObject
        $keyListStarted = $false
        Write-Host "`n[+] New Set Of Credentials Was Found !" -ForegroundColor Green
    }
    
    if ($currentObject -ne $null -and $keyListStarted -and $line -match "^\s*(\S+)\s+([a-fA-F0-9]+)\s*$") {
        $keyListKey = $matches[1].Trim()
        $keyListValue = $matches[2].Trim()
        $currentObject | Add-Member -MemberType NoteProperty -Name $keyListKey -Value $keyListValue
    }

    if ($currentObject -ne $null -and $line -match "^\s*([^:]+)\s*:\s*(.*)\s*$") {
        $key = $matches[1] -replace '\*', ''
        $key = $key.Trim()
        $value = $matches[2].Trim()
        if ($AllowedKeys -contains $key)
        {
            if ($key -like "*Key List*" ) {
                $keyListStarted = $true
            } else {
                $currentObject | Add-Member -MemberType NoteProperty -Name $key -Value $value -Force
            }
        }
    }
}

if ($currentObject) {
    $parsedObjects += $currentObject
}
Write-Host
try {
    $parsedObjects | Export-Csv -Path $OutputFile -NoTypeInformation
    Write-Host "[+] Parsed data has been exported to $OutputFile`n" -ForegroundColor Yellow    
}catch{
    Write-Error $_
}
