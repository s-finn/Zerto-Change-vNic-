#requires -Version 5
#requires -RunAsAdministrator
<#
.SYNOPSIS
   This script is intended to create a secure password file for use with other example scripts for those users who do not want to store their credentials in a string value within the script itself. In the example below
   a folder on the ZVM C:\ drive named ZertoScripts (full path C:\ZertoScripts) is required to save the password file. You will need to create this folder manually ahead of time. 
   You can place this script and other scripts leveraging this script into this directory.

   If you wish to save the password file and scripts to another location, you will need to update the script according with the absolute path 
   
.DESCRIPTION
   This script must be executed first, and will create a file containing the vCenter details including vCenter IP, vCenter User, vCenter password. The IP and User will be requested to be entered via command prompt and the
   password will be requested to be entered into a Windows Dialog Box. 


.EXAMPLE
   Examples of script execution
.VERSION 
   Applicable versions of Zerto Products script has been tested on.  Unless specified, all scripts in repository will be 5.0u3 and later.  If you have tested the script on multiple
   versions of the Zerto product, specify them here.  If this script is for a specific version or previous version of a Zerto product, note that here and specify that version 
   in the script filename.  If possible, note the changes required for that specific version.  
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
$vcenter = read-host -Prompt 'Enter vCenter IP Address'
$user = read-host -Prompt 'Enter vCenter Username'
$pass = read-host -assecurestring -Prompt 'Enter vCenter password' | convertfrom-securestring -Key (1..16)


$vCenter = "vCenter="+$vCenter
$vcenter | Out-File C:\ZertoScripts\passfile.txt

$user = "username="+$user
$user | Out-File C:\ZertoScripts\passfile.txt -Append

$pass = "password="+$pass
$pass | Out-file C:\ZertoScripts\passfile.txt -Append