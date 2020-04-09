# Legal Disclaimer
This script is an example script and is not supported under any Zerto support program or service. The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.

# Change vNIC
This script is intended to be used as a Zerto Post Recovery script to automate the configuration change of VMware VMs network adapter types. The script is currently configured to run on Fail Over Test, Fail Over Live, or Move operation. If the script is intended to be run during only specific operations additional user configuration will be required. **As part of the network adapter change each VM in the NICs CSV input file will need to be powered off to make the change and then powered back on.** 

# Getting Started 
Before running the ChangevNicType-FromAzure1.1ps1 file the setup-environment.ps1 must be run to create a credentials file that is used by ChangevNicType-FromAzure1.1ps1. In the examples provided no passwords are written in plain text. 

# Prerequisites 
This script must reside in a folder on the recovery ZVM for the vSphere environment the VMs are being recovered to by Zerto. 
  # Environment Requirements (recovery ZVM) 
  - PowerShell 5.0+ 
  - PowerCLI 6.0+ 
  - VPG Post Recovery command to run setting 
  - VPG Post Recovery Params setting 
  - ZVM Service account with permisions to execute script 
  
 #In Script Variables 
 - NICs CSV input file location
 - Credentials file location 
 
 # Running Script
 Once the necessary configuration requirements have been completed the script will run automatically on the recovery ZVM during a Fail Over Test, Fail Over Live, or Move Operation for the VMs determined in the NICs.csv file
