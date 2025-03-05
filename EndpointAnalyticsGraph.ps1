<#
.SYNOPSIS
This script generates an email report for devices that need attention based on Intune Analytics data.

.DESCRIPTION
The script checks if the required graph modules are installed and installs them if necessary. It then connects to the Microsoft Graph API using the Connect-MgGraph cmdlet. It retrieves a list of devices that need attention and sends an email report to the specified recipient(s) with details about the devices and their application crash/hang information.

.PARAMETER EmailTitle
The subject of the email.

.PARAMETER EmailFrom
The email address from which the email will be sent.

.PARAMETER EmailBCC
The email address(es) to be BCC'd on the email.

.PARAMETER tenantId
The ID of the tenant to connect to.

.PARAMETER EmailTo
The email address to which the email will be sent.

.EXAMPLE
.\EndpointAnalyticsGraph.ps1 -EmailTitle "Your Device Needs Attention" -EmailFrom "sender@example.com" -EmailTo "recipient@example.com" -tenantId "<YourTenantId>"

.NOTES
Author: Your Name
Date: Current Date
#>

# Prerequisites
#check if the required graph modules are installed
if (-not (Get-Module -Name Microsoft.Graph.Authentication -ListAvailable)) {
    # If not installed, install the Microsoft.Graph.Authentication
    Write-output "Microsoft.Graph.Authentication module is not installed. Installing Microsoft.Graph.Authentication"
    Install-Module Microsoft.Graph.Authentication  -Force 
    Import-Module Microsoft.Graph.Authentication
    Write-output "Microsoft.Graph.Authentication has been installed."
}
else {
    Write-output "Microsoft.Graph.Authentication module is already installed."  
    Import-Module Microsoft.Graph.Authentication  
}
if (-not (Get-Module -Name Microsoft.Graph.beta.DeviceManagement -ListAvailable)) {
    # If not installed, install the Microsoft.Graph.beta.DeviceManagement
    Write-output "Microsoft.Graph.beta.DeviceManagement module is not installed. Installing Microsoft.Graph.beta.DeviceManagement"
    Install-Module Microsoft.Graph.beta.DeviceManagement  -Force 
    Import-Module Microsoft.Graph.beta.DeviceManagement
    Write-output "Microsoft.Graph.beta.DeviceManagement has been installed."
}
else {
    Write-output "Microsoft.Graph.beta.DeviceManagement module is already installed."    
    Import-Module Microsoft.Graph.beta.DeviceManagement
}
# Check if the PSWriteHTML module is installed
if (-not (Get-Module -Name PSWriteHTML -ListAvailable)) {
    # If not installed, install the PSWriteHTML
    Write-output "PSWriteHTML module is not installed. Installing PSWriteHTML"
    Install-Module PSWriteHTML  -Force 
    Write-output "PSWriteHTML has been installed."
}
else {
    Write-output "PSWriteHTML module is already installed."    
}

# Variables
$EmailTitle = "Your Device Needs Attention"
$EmailFrom = "sender@example.com"
$EmailCC = ""
$EmailBCC = ""
$TenantId = "<YourTenantId>"

# Funtions
Function Send-Email {
    Param ($subj, $Body, $priority, $EmailCC, $Attachments, $EmailFrom, $EmailTo, $EmailBCC)
    $SendMailProps = @{
        From = $EmailFrom        
        To = $EmailTo
        Subject = $subj
        Body = $Body 
        SmtpServer = "internalsmtp.uk.corp.investec.com"
        Priority = $priority      		
    }
    If($emailCC){$SendMailProps.Add("CC",$emailCC)}
	If($EmailBCC){$SendMailProps.Add("BCC",$EmailBCC)}
    Send-MailMessage @SendMailProps -BodyAsHtml
}

# Main Script

# connect to the Microsoft Graph API
Connect-MgGraph -TenantId $tenantId -Scopes "DeviceManagementConfiguration.Read.All" -NoWelcome -TenantId $tenantId -Interactive

#filter by "needs attention"
$DeviceNeedsAttention = Get-MgBetaDeviceManagementUserExperienceAnalyticAppHealthDevicePerformance -all -Filter "healthStatus eq microsoft.graph.UserExperienceAnalyticsHealthState'needsAttention'" | Select-Object DeviceDisplayName, DeviceId, HealthStatus

#get the user details for each device in $deviceNeedsAttention
foreach ($device in $DeviceNeedsAttention) {
    #get the primary user of the device
    $DevicePrimaryUser = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/manageddevices('$($device.DeviceId)')/users"
    
    #initialize the $UserDetails variable
    $UserDetails = @()

    #if the device has a primary user, get the user details
    $UserDetails = $DevicePrimaryUser.value | Select-Object displayName, userPrincipalName

    #if no user details are found, skip the device
    if ($null -eq $UserDetails) {
        continue
    }
    # group appdisplayname and event type when they are the same and count the number of occurences
    $AppCrashDetails = Get-MgBetaDeviceManagementUserExperienceAnalyticAppHealthDevicePerformanceDetail -Filter "deviceId eq '$($device.DeviceId)'" -all | Group-Object appDisplayName | Select-Object Name, Count, @{Name='EventType';Expression={$_.Group[0].eventType}}    
   
    # email users with devices that need attention and their app crash details using PSWriteHTML
    $EmailBodyReport = EmailBody {    				   
		EmailText -FontFamily 'Calibri' -FontSize 16 -Color Black -Alignment left -FontStyle normal -Text "Hello, $($UserDetails.displayName)"
		EmailText -LineBreak
		EmailTextBox -FontFamily 'Calibri' -Size 16  -Color Black -Alignment left -FontStyle normal {
			"Intune Analytics has identified that your device $($device.DeviceDisplayName) has been having few application crashes/hangs in the last 14 days."
            "Please see the details below:"              
		} 
        EmailTable -DataTable ($AppCrashDetails) -AutoSize {                
			$AppCrashDetails | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | % {
				EmailTableHeader -BackGroundColor SkyBlue -FontSize 18 -Color Black -Names $_
			}				
		} -HideFooter
		EmailText -LineBreak
		EmailTextBox -FontFamily 'Calibri' -Size 16  -Color Black -Alignment left -FontStyle normal {
			"Should you need any assistance, please contact the Technology Service Desk."
		} 
		EmailText -LineBreak	
    }
    # Set the email recipient
    $Emailto = $UserDetails.userPrincipalName
    # Send the email
    Send-Email -subj "$EmailTitle" -Body $EmailBodyReport  -priority "normal" -emailBCC $emailBCC -EmailFrom $EmailFrom -EmailTo $Emailto
}

# disconnect from the Microsoft Graph API
Disconnect-MgGraph