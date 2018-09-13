<#-----------------------------------------------------------------------------
  Powering Azure SQL With PowerShell

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2017/2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 
 -----------------------------------------------------------------------------#>

 <#-----------------------------------------------------------------------------
  
  The above is the copyright from the original author,
  Some changes/comments are made/added by Jenny Zhan to make it work
  for her task of being the helper in a craftsmanship 
  
 -----------------------------------------------------------------------------#>
 
 <#---------------------------------------------------------------------------#>
<# Module - Introduction                                                     #>
<#                                                                           #>
<#---------------------------------------------------------------------------#>

$dir = "C:\Users\zhanj\jz_project\SoftwareCraftship\demo"

Set-Location $dir

# Create a shorter path to display
New-PSDrive -Name jzdemo `
            -PSProvider FileSystem `
            -Root $dir

Set-Location jzdemo:

# Show the version of AzureRM in use  
# jz: need to run these steps if AzureRM is not installed: 
#	1) installed msi for windows7(in my case) to upgrade ps from 3.0 to 5.0
#	2) install-module -Name AzureRM
Get-Module AzureRM -ListAvailable 

# Run a script with functions used by multiple scripts in this course
# jz: have to make the script runnable by check the file's properties from file system
. .\ps_demo_functions.ps1.ps1   


# Login
Add-AzureRMAccount #has prompt coming out

# Set the session to use the correct subscription
#$useSub = 'Visual Studio Ultimate with MSDN'
$useSub = 'Pay-As-You-Go'
Set-PSSubscription $useSub

#endregion Module - Introduction

#region Module - Resource Groups and Storage Accounts
<#---------------------------------------------------------------------------#>
<# Module - Resource Groups and Storage Accounts                             #>
<# anything.                                                                 #>
<#---------------------------------------------------------------------------#>
$resourceGroupName = 'PSAzSQLPlaybookDemo'
$location = 'southcentralus'          # Geographic location to store everything
$storageAccountName = 'pbstoragedemo' # Name of the storage account
$containerName = 'pbstoragecontainer' # Name of container inside storage account

# Create the resource group, if needed
New-PSResourceGroup -ResourceGroupName $resourceGroupName `
                    -Location $location `
                    -Verbose

$storageAccountName = 'pbstoragedemojz'  #pbstoragedemo was taken, pbstoragedemo_jz was wrong with '_'

# Create the storage account, if needed
New-PSStorageAccount -StorageAccountName $storageAccountName `
                     -ResourceGroupName $resourceGroupName `
                     -Location $location `
                     -Verbose

# Create the Storage Container, if needed
$container = New-PSStorageContainer -ContainerName $containerName `
                                    -ResourceGroupName $resourceGroupName `
                                    -StorageAccountName $storageAccountName `
                                    -Verbose

#endregion Module - Resource Groups and Storage Accounts

#region Module - Create an Azure SQL Server
<#---------------------------------------------------------------------------#>
<# Module - Create an Azure SQL Server                                       #>
<#                                                                           #>
<#---------------------------------------------------------------------------#>

# Setup variables
$resourceGroupName = 'PSAzSQLPlaybookDemo'
$location = 'southcentralus'          # Geographic location to store everything
$serverName = 'psplaybooksqlserverjz'   # Name for our new SQL Server
$userName = 'ArcaneCode'              # Admin User Name for the SQL Server

# Read the password to use from a text file 
# (evil practice but makes it easy to demo)
$pwFile = "$dir\pw.txt"
$password = Get-Content $pwFile 

New-PSAzureSQLServer -ServerName $serverName `
                     -ResourceGroupName $resourceGroupName `
                     -Location $location `
                     -UserName $userName `
                     -Password $password `
                     -Verbose

$firewallRuleName = 'ArcaneCodesFirewallRule' 

# There are two ways to get the IP address for the firewall.
# First, you can get the IP Address of the computer running this script

############### jz: this part didn't work, can't find Get-NetIPAddress
#$x = Get-NetIPAddress -AddressFamily IPv4
#$startIP = $x[0].IPAddress
#$endIP = $x[0].IPAddress

# Alternatively, you can manually enter a range of IPs. Here it's just
# been opened to the entire internet, in reality you'd limit it to just 
# the range needed by your company
$startIP = '0.0.0.0'
$endIP = '255.255.255.255'

# Now we can call our helper function to create the new firewall rule
New-PSAzureSQLServerFirewallRule -ServerName $serverName `
                                 -ResourceGroupName $resourceGroupName `
                                 -FirewallRuleName $firewallRuleName `
                                 -StartIpAddress $startIP `
                                 -EndIpAddress $endIP `
                                 -Verbose
#endregion Module - Create an Azure SQL Server

#region Module - Migrate a Local Database to AzureSQL
<#---------------------------------------------------------------------------#>
<# Module - Migrate a Local Database to AzureSQL                             #>
<#---------------------------------------------------------------------------#>

# Setup variables
$storageAccountName =  'pbstoragedemojz' # Name of the storage account
$containerName = 'pbstoragecontainer' # Name of container inside storage account
$serverName = 'psplaybooksqlserverjz'   # Name for our new SQL Server
$userName = 'ArcaneCode'              # Admin User Name for the SQL Server
$resourceGroupName = 'PSAzSQLPlaybookDemo'

# Read the password to use from a text file 
# (evil practice but makes it easy to demo)
$pwFile = "$dir\pw.txt"
$password = Get-Content $pwFile 

# Create the bacpac
$dbName = 'jzfirstazuredb'
#New-PSBacPacFile -DatabaseName $dbName `
#                 -Path $dir `
#                 -SourceServer 'localhost' `
#                 -Verbose*
#jz: not succesfull in creating a new backpack, as no such sqlpackage.exe exists
# instead, create the bacpac file from SSMS
###############################

# Upload the bacpac file to storage
$bacPacFile = "$dir\$($dbName).bacpac"
Set-PSBlobContent -FilePathName $bacPacFile `
                  -ResourceGroupName $resourceGroupName `
                  -StorageAccountName $storageAccountName `
                  -ContainerName $containerName `
                  -Verbose

# The import will fail if the db exists, so we need to check and delete it
# if it does
Remove-PSAzureSQLDatabase -ResourceGroupName $resourceGroupName `
                          -ServerName $serverName `
                          -DatabaseName $dbName `
                          -Verbose

# Database Type
$dbEdition = 'Basic'
$serviceObjectiveName = 'Basic'

# Now we can start the import process
$request = New-PSAzureSqlDatabaseImport `
              -ResourceGroupName $resourceGroupName `
              -ServerName $serverName `
              -DatabaseName $dbName `
              -StorageAccountName $storageAccountName `
              -StorageContainerName $containerName `
              -UserName $userName `
              -Password $password `
              -DbEdition $dbEdition `
              -ServiceObjectiveName $serviceObjectiveName `
              -Verbose

# After starting the import, Azure immediately returns control to PowerShell.
# We will need to call another cmdlet to check the status. Here we've created
# a loop to call it ever 10 seconds and check the status. For a large database
# you will likely want to up the time to minutes or maybe even hours. The loop
# will end once we no longer get the InProgress message.

# Just a flag to keep the while loop going
$keepGoing = $true

# It can be useful to know how long loads take. Using a stopwatch can
# make this easy.
$processTimer = [System.Diagnostics.Stopwatch]::StartNew()

# Keep looping until we find out it is done. 
while ($keepGoing -eq $true)
{
  # This will tell us the status, but we will need the request object
  # returned by our function New-PSAzureSQLDatabaseImport
  $status = Get-AzureRmSqlDatabaseImportExportStatus `
               -OperationStatusLink $request.OperationStatusLink
  
  if ($status.Status -eq 'InProgress') # Display a progress message
  {
    Write-Host "$((Get-Date).ToLongTimeString()) - $($status.StatusMessage)" `
      -ForegroundColor DarkYellow
    Start-Sleep -Seconds 10
  }
  else                                 # Let user know we're done
  {
    $processTimer.Stop()
    Write-Host "$($status.Status) - Elapsed Time $($processTimer.Elapsed.ToString())" `
      -ForegroundColor Yellow
    $keepGoing = $false
  }
}

# Just to wrap this up, show proof the DB now exists
Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName `
                       -ServerName $serverName |
  Select-Object ResourceGroupName, ServerName, DatabaseName, Status

#endregion Module - Migrate a Local Database to AzureSQL


<#---------------------------------------------------------------------------#>
<# jz: to do: try the last two modules and make sure it works:			     #>
<# 		  - Apply Additional SQL Scripts Against the Azure SQL Database      #>
<# 		  - Removing AzureSQL                                                #>
<#---------------------------------------------------------------------------#>
