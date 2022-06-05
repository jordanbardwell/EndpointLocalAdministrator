## Variables
$EnrollmentType = "EnrollmentTypeChangeMe"
$ConfirmationID = "ConfirmationCodeChangeMe"
$UserPrincipalName = "UserPrincipalNameChangeMe"
$Type = "TypeChangeMe"
$URI = "URIChangeMe"

## Function: Logging
#$HostName = $env:computername
#$ScriptName = $MyInvocation.MyCommand.Name.Replace(".ps1","")
$LogfileName = "Set-IntuneLocalAdministrator"
$LogLocation = "C:\Windows\Logs\Endpoint Local Administrator"
function Write-Log
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("LogContent")]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [Alias('LogPath')]
        [string]$Path="$LogLocation\$LogfileName.log",
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Error","Warn","Info")]
        [string]$Level="Info",
        
        [Parameter(Mandatory=$false)]
        [switch]$NoClobber
    )

    Begin
    {
        # Set VerbosePreference to Continue so that verbose messages are displayed.
        $VerbosePreference = 'Continue'
    }
    Process
    {
        
        # If the file already exists and NoClobber was specified, do not write to the log.
        if ((Test-Path $Path) -AND $NoClobber) {
            Write-Error `
	"Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."
            Return
            }

        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
        elseif (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            $NewLogFile = New-Item $Path -Force -ItemType File
            }

        else {
            # Nothing to see here yet.
            }

        # Format Date for our Log File
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        # Write message to error, warning, or verbose pipeline and specify $LevelText
        switch ($Level) {
            'Error' {
                Write-Error $Message
                $LevelText = 'ERROR:'
                }
            'Warn' {
                Write-Warning $Message
                $LevelText = 'WARNING:'
                }
            'Info' {
                Write-Verbose $Message
                $LevelText = 'INFO:'
                }
            }
        
        # Write log entry to $Path
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append
    }
    End
    {
    }
}

## Function: Add-LocalAdmin
function Set-IntuneLocalAdministrator{
    <#
    .SYNOPSIS
    Adds an Azure AD user to local admin group
    
    .DESCRIPTION
        Adds an Azure AD user to local admin group.
    
    .PARAMETER UserPrincipalName
    The userPrinipalName of the user you'd like to add
    
    .EXAMPLE
    Add-AzureADLocalAdmin -UserPrincipalName john@contoso.com
    
    .NOTES
    Created by Jordan Bardwell - 07/01/2020
    #>
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true)]
    [string]$UserPrincipalName,
    [Parameter(Mandatory=$true)]
    [string]$EnrollmentType,
    [Parameter(Mandatory=$true)]
    [ValidateSet('Add','Remove')]
    [string]$Type
    )

    # Specify Domain
    if($EnrollmentType -like "*azure*" -or $EnrollmentType -like "*Azure*")
    {
        $DomainType = "AzureAD"
        $User = $UserPrincipalName
        $ShortUserName = $UserPrincipalName.Split('@')[0]
    }
    else {
        $DomainType = $env:userdomain
        $User = $UserPrincipalName.Split('@')[0]
        $ShortUserName = $UserPrincipalName.Split('@')[0]
    }

    if ($Type -eq 'Add') 
    {
        # Check Local Administrators Group
        $AdministratorsGroup = Invoke-Expression -Command "net localgroup administrators"
        if ($AdministratorsGroup -like "*\$ShortUserName") 
        {
            Write-Log "User is already a local administrator" -level Warn
        }
        else 
        {
            # Add User to Administrators
            try {
                Add-LocalGroupMember -Group "Administrators" -Member "$DomainType\$User" -ErrorAction Stop
                Write-Log "Successfully added $User to Administrators"
            }
            catch {
                Write-Log "Failed to add $User to Administrators" -Level Warn
                Write-Log $PSItem.Exception -Level Error
            }
        }
            
    }
    else {
        # Remove User from Administrators
        try {
            Remove-LocalGroupMember -Group "Administrators" -Member "$DomainType\$User" -ErrorAction Stop
            Write-Log "Successfully removed $User to Administrators"
        }
        catch {
            Write-Log "Failed removing $User from Administrators" -Level Warn
            Write-Log $PSItem.Exception -Level Error
        }
        
    }
}

## Function: Send Status to Mothership
function Send-ELAStatusUpdate{
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true)]
    [string]$URI,
    [Parameter(Mandatory=$true)]
    [string]$ConfirmationID,
    [Parameter(Mandatory=$true)]
    [string]$Type,
    [Parameter(Mandatory=$true)]
    [ValidateSet('Success','Failed')]
    [string]$Status
    )
    $Body = New-Object -TypeName psobject @{
        Status = $Status
        Type = $Type
        ConfirmationID = $ConfirmationID
    } | ConvertTo-JSON
    Invoke-WebRequest -Uri $URI -Method Post -Body $Body -ContentType application/json -UseBasicParsing
}

# Execute
try
{
    Write-Log "Enrollment Type: $EnrollmentType"
    Write-Log "Confirmation ID: $ConfirmationID"
    Write-Log "UserPrincipalName: $UserPrincipalName"
    Write-Log "Type: $Type"
    Write-Log "Running Set-IntuneLocalAdministrator..."
    Set-IntuneLocalAdministrator -Type $Type -UserPrincipalName $UserPrincipalName -EnrollmentType $EnrollmentType -ErrorAction Stop
    Write-Log "Executed Successfully."
    Write-Log "Sending Status to Mothership..."
    Send-ELAStatusUpdate -URI $URI -ConfirmationID $ConfirmationID -Type $Type -Status Success
}
catch
{
    Write-Log $PSItem.Exception -Level Error
    Write-Log "Sending Status to Mothership..."
    Send-ELAStatusUpdate -URI $URI -ConfirmationID $ConfirmationID -Type $Type -Status Failed    
}
