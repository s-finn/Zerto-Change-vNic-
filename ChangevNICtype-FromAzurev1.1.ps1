#requires -Version 5
#requires -RunAsAdministrator
<#
.SYNOPSIS
   This script is intended to be utilized for customers failing back from Azure to vCenter. When fail back occurs the virtual machines are natively configured with vNICs that are E1000. This
   script will power down the VMware VMs specificed in the NICs.csv import file, automatically change the network adapter for those VMs in vCenter to VMXNet3, and power them on. It is important 
   to note in some instances the Guest OS in VMware needs to be verified. Because of this is it is recommended to put the intended Guest OS into the CSV with the VM name. Note these naming 
   conventions are not typical OS names, for instance when trying to update a VMs Guest OS to Windows Server 2012 PowerCLI will require the -GuestID to be windows8Server64Guest. A list of examples 
   can be referenced from the following blog: http://www.virtualnebula.com/blog/2014/12/3/vcac-guest-os-ids-vmwarevirtualcenteroperatingsystem. 
   
   In its current configuration the script is intended to be run as a Post Recovery Script within a Zerto VPG and is required to reside on the ZVM. Due to this the ZVM is required to have PowerCLI
   installed to be able to execute this script appropriately. 

.DESCRIPTION
   Before running this script, you must run the setup-environment.ps1 script to create the necessary credentials file for this script to run. In this example the credentials file is being read 
   from C:\ZertoScripts\passfile.txt. If that is not the appropriate folder location and file name of your credentials file edit line 48 of this script accordingly.  

   This script is accepting the %ZertoOperations% parameter to determine whether the operation is a Fail over Test or a Fail Over
   Live / Move. If it is a test the script will automatically append the word ' - testing recovery' to the VM name so the script can accurately locate the VMware VM. 
   
   In addition to this script, the specific VPGs required to utilize this will need to have their VPG Recovery tab Post-recovery settings set as follows: 
   command to run: powershell.exe Params(optional): scriptfilelocationonzvm %ZertoOperation%

   If the script resides in a folder such as C:\ZertoScripts\changevnictype-fromazurev1.v1.ps1 then you would want the param to be C:\ZertoScripts\changevnictype-fromazurev1.v1.ps1 %ZertoOperation%  

.EXAMPLE
   Examples of script execution
.VERSION 
   Applicable versions of Zerto Products script has been tested on.  Unless specified, all scripts in repository will be 5.0u3 and later.  If you have tested the script on multiple
   versions of the Zerto product, specify them here.  If this script is for a specific version or previous version of a Zerto product, note that here and specify that version 
   in the script filename.  If possible, note the changes required for that specific version.
   
   If PowerCLI version older than 6.5 is being used remove the comment on line #80 and comment out line #81  
.LEGAL
   Legal Disclaimer:

----------------------
This script is an example script and is not supported under any Zerto support program or service.
The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without 
limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability 
to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages.  The entire risk arising out of the use or 
performance of the sample scripts and documentation remains with you.
----------------------
#>
#------------------------------------------------------------------------------#
# Declare variables
#------------------------------------------------------------------------------#

$envdetails = Get-Content C:\ZertoScripts\passfile.txt | out-string | ConvertFrom-StringData
$envdetails.password = $envdetails.password | ConvertTo-SecureString -key (1..16)
$mycredentials = New-Object System.Management.Automation.PSCredential ($envdetails.username, $envdetails.password)
$VMsCSV = "C:\Users\shaun.finn\Documents\Product Management\Automation\VMXNet3\NICs.csv"
$Operation = $env:ZertoOperation


########################################################################################################################
# Nothing to configure below this line - Starting the main function of the script
########################################################################################################################
Write-Host -ForegroundColor Yellow "Informational line denoting start of script GOES HERE." 
Write-Host -ForegroundColor Yellow "   Legal Disclaimer:

----------------------
This script is an example script and is not supported under any Zerto support program or service.
The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without 
limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability 
to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages.  The entire risk arising out of the use or 
performance of the sample scripts and documentation remains with you.
----------------------
"

#------------------------------------------------------------------------------#
# Importing the CSV of VMs to change adapter
#------------------------------------------------------------------------------#
$VMsCSVImport = Import-Csv $VMsCSV

#------------------------------------------------------------------------------#
# Add VMware Snapin for PowerCLI / Import Module
#------------------------------------------------------------------------------#
#add-pssnapin vmware.vimautomation.core
Import-Module VMware.PowerCLI

#------------------------------------------------------------------------------#
# Connect to vCenter Server
#------------------------------------------------------------------------------#
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer -Server $envdetails.vCenter -Protocol https -Credential $mycredentials -WarningAction SilentlyContinue | Out-Null

#------------------------------------------------------------------------------#
# Stop script from running if rollback is occuring
#------------------------------------------------------------------------------#
If($Operation -eq "FailoverRollback" -or $Operation -eq "MoveRollback"){
    
    break

}
Else{

    Foreach ($VM in $VMsCSVImport) {
        
        #for Fail Over Test append - testing recovery to VM name
        If($Operation -eq "Test") {
           $VMName = $VM.VMName + ' - testing recovery'
        }
        Else {
           $VMName = $VM.VMName
        }
            Stop-VM -VM $VMName -Confirm:$false
            Start-Sleep -Seconds 10
            $VMGuestID = Get-VM $VMName.GuestID

        IF($VM.GuestID -ne $VMGuestID){
            Get-VM $VMName | Set-VM Guest-ID $VM.GuestID -confirm:$False
        }

            Get-VM $VMName | Get-NetworkAdapter | Set-NetworkAdapter -Type Vmxnet3 -Confirm:$false
            Start-Sleep -Seconds 10
            Start-VM -VM $VMName
    }
}





