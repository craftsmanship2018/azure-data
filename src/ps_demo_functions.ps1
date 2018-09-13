<#-----------------------------------------------------------------------------
  Azure Helper Functions

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
 
  This module is Copyright (c) 2017 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author. 
 -----------------------------------------------------------------------------#>

#region Connect-PSToAzure
<#---------------------------------------------------------------------------#>
<# Connect-PSToAzure                                                         #>
<#---------------------------------------------------------------------------#>
function Connect-PSToAzure ()
{ 
<#
  .SYNOPSIS
  Connects the current PowerShell session to Azure, if it is not already 
  connected.
  
  .DESCRIPTION
  If a path/file is passed in, will attempt to copy the contents to the
  clipboard with the assumption it is your password. It will then call the
  cmdlet to connect to Azure. You just key in your user ID, then can paste
  in your password. 

  WARNING: Of course it is dangerous to leave your password laying around
  in a text file. Be sure your machine is secure, or optionally omit the
  file and just key it in each time. 

  .PARAMETER Path
  The directory where your password file is stored

  .PARAMETER PasswordFile
  The file holding your password.

  .INPUTS
  System.String

  .OUTPUTS
  System.String

  .EXAMPLE
  Connect-PSToAzure 'C:\Test'

  .EXAMPLE
  Connect-PSToAzure -Path 'C:\Test'

  .EXAMPLE
  Connect-PSToAzure -Path 'C:\Test' -PasswordFile 'mypw.txt'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [string]$Path
       , [string]$ContextFile = 'ProfileContext.ctx'
       )

  $fn = 'Connect-PSToAzure:'

  # Login if we need to
  if ( $(Get-AzureRmContext).Account -eq $null )
  {
    # Copy your password to the clipboard
    if ($Path -ne $null)
    {
      $contextPathFile = "$Path\$ContextFile"
      Write-Verbose "$fn Context File: $contextPathFile"
      if ($(Test-Path $contextPathFile))
      {
        # Old method I copied my PW to the clipboard
        # Set-Clipboard $(Get-Content $pwPathFile )

        # With AzureRM 4.4 update they fixed Import-AzureRmContext, so am
        # going back to that method
        try 
        {
          Import-AzureRmContext -Path $contextPathFile
        }
        catch
        {
          # Don't sweat an error if the file is gone, so just begin 
          # the manual login process
          Add-AzureRMAccount  # Login
        }
      }
      else
      {
        # Begin the manual login process
        Add-AzureRMAccount  # Login
      }
    }    
  }

}
#endregion Connect-PSToAzure

#region Set-PSSubscription
<#---------------------------------------------------------------------------#>
<# Set-PSSubscription                                                        #>
<#---------------------------------------------------------------------------#>
function Set-PSSubscription ()
{
<#
  .SYNOPSIS
  Sets the current Azure subscription.

  .DESCRIPTION
  When you have multiple Azure subscriptions, this function provides an easy
  way to change between them. The function will check to see what your current
  subscription is, and if different from the one passed in it will change it.

  .PARAMETER Subscription
  The name of the subscription to change to
  
  .INPUTS
  System.String

  .OUTPUTS
  n/a

  .EXAMPLE
  Set-PSSubscription -Subscription 'Visual Studio Ultimate with MSDN'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The subscription name to change to'
                   )
         ]
         [string]$Subscription
       )

  $fn = 'Set-PSSubscription:'
  # Get the current context we're running under. From that we can
  # derive the current subscription name
  $currentAzureContext = Get-AzureRmContext
  $currentSubscriptionName = $currentAzureContext.Subscription.Name

  if ($currentSubscriptionName -eq $Subscription)
  {
    # If we're already running under it, do nothing
    Write-Verbose "$fn Current Subscription is already set to $Subscription"  
  }
  else
  {
    # Change to the new subscription
    Write-Verbose "$fn Current Subscription: $currentSubscriptionName"
    Write-Verbose "$fn Changing Subscription to $Subscription "

    # Set the subscription to use
    Set-AzureRmContext -SubscriptionName $Subscription
  }
  
}
#endregion Set-PSSubscription

#region New-PSResourceGroup
<#---------------------------------------------------------------------------#>
<# New-PSResourceGroup                                                       #>
<#---------------------------------------------------------------------------#>
function New-PSResourceGroup ()
{ 
<#
  .SYNOPSIS
  Create a new resource group.

  .DESCRIPTION
  Checks to see if the passed in resource group name exists, if not it will 
  create it in the location that matches the location parameter.
  
  .PARAMETER ResourceGroupName
  The name of the resource group to create

  .PARAMETER Location
  The Azure geographic location to store the resource group in.

  .INPUTS
  System.String

  .OUTPUTS
  n/a

  .EXAMPLE
  New-PSResourceGroup -ResourceGroupName 'ArcaneRG' -Location 'southcentralus'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the resource group to create'
                   )
         ]
         [string]$ResourceGroupName 
       , [Parameter( Mandatory=$true
                   , HelpMessage='The geo location to store the Resource Group in'
                   )
         ]
         [string]$Location
       )
  
  $fn = 'New-PSResourceGroup:'
  # Check to see if the resource group already exists
  Write-Verbose "$fn Checking for Resource Group $ResourceGroupName"

  # Method 1 - Ignores errors
  # $rgExists = Get-AzureRmResourceGroup -Name $ResourceGroupName `
  #                                      -ErrorAction SilentlyContinue

  # Method 2 - Filters on this end
  $rgExists = Get-AzureRmResourceGroup |
     Where-Object {$_.ResourceGroupName -eq $ResourceGroupName}

  
  # If not, create it.
  if ( $rgExists -eq $null )
  {
    Write-Verbose "$fn Creating Resource Group $ResourceGroupName"
    New-AzureRmResourceGroup -Name $ResourceGroupName `
                             -Location $Location
  }
}
#endregion New-PSResourceGroup

#region New-PSStorageAccount
<#---------------------------------------------------------------------------#>
<# New-PSStorageAccount                                                      #>
<#---------------------------------------------------------------------------#>
function New-PSStorageAccount ()
{ 
<#
  .SYNOPSIS
  Create a new storage account

  .DESCRIPTION
  Checks to see if an Azure storage account exists in a particular resource
  group. If not, it will create it. 

  .PARAMETER StorageAccountName
  The name of the storage account to create.

  .PARAMETER ResourceGroupName
  The resource group to put the storage account in.

  .Parameter Location
  The Azure geographic location to put the storage account in.

  .INPUTS
  System.String

  .OUTPUTS
  A new storage account

  .EXAMPLE
  New-PSStorageAccount -StorageAccountName 'ArcaneStorageAcct' `
                       -ResourceGroupName 'ArcaneRG' `
                       -Location 'southcentralus'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the storage account to create'
                   )
         ]
         [string]$StorageAccountName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The resource group to put the storage account in'
                   )
         ]
         [string]$ResourceGroupName 
       , [Parameter( Mandatory=$true
                   , HelpMessage='The geo location to put the storage account in'
                   )
         ]
         [string]$Location
       )

  $fn = 'New-PSStorageAccount:'

  # Check to see if the storage account exists
  Write-Verbose "$fn Checking Storage Account $StorageAccountName"
  $saExists = Get-AzureRMStorageAccount `
                -ResourceGroupName $ResourceGroupName `
                -Name $StorageAccountName `
                -ErrorAction SilentlyContinue

  # If not, create it.
  if ($saExists -eq $null)
  { 
    Write-Verbose "$fn Creating Storage Account $StorageAccountName"
    New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName `
                              -Name $StorageAccountName `
                              -Location $Location `
                              -Type Standard_LRS
  }
}
#endregion New-PSStorageAccount

#region Get-PSStorageAccountKey
<#---------------------------------------------------------------------------#>
<# Get-PSStorageAccountKey                                                   #>
<#---------------------------------------------------------------------------#>
function Get-PSStorageAccountKey ()
{
<#
  .SYNOPSIS
  Gets the key associated with a storage account

  .DESCRIPTION
  Every storage account has a special key assoicated with it. This key unlocks
  the storage vault to get data in or out of it. This cmdlet will get the key
  for the passed storage account.

  .PARAMETER ResourceGroupName
  The name of the resource group containing the storage account

  .PARAMETER StorageAccountName
  The name of the storage account you need the key for

  .INPUTS
  System.String

  .OUTPUTS
  Storage Account Key

  .EXAMPLE
  Get-PSStorageAccountKey -ResourceGroupName 'ArcaneRG' `
                          -StorageAccountName 'ArcaneStorageAcct'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group containing the storage account'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the storage account to get the key for'
                   )
         ]
         [string]$StorageAccountName
       )

  $fn = 'Get-PSStorageAccountKey:'

  Write-Verbose "$fn Getting storage account key for storage account $StorageAccountName"
  $storageAccountKey = $(Get-AzureRmStorageAccountKey `
                           -ResourceGroupName $ResourceGroupName `
                           -Name $StorageAccountName `
                        ).Value[0]

  return $storageAccountKey
}
#endregion Get-PSStorageAccountKey

#region Get-PSStorageContext
<#---------------------------------------------------------------------------#>
<# Get-PSStorageContext                                                      #>
<#---------------------------------------------------------------------------#>
function Get-PSStorageContext ()
{
<#
  .SYNOPSIS
  Get the context for a storage account.

  .DESCRIPTION
  To fully access a storage account you use its context. The context is based
  on a combination of the account name and key. This cmdlet will retrieve the
  context so you can use it in subsequent storage operations.

  .PARAMETER ResourceGroupName
  The resource group containing the storage account.

  .PARAMETER StorageAccountName
  The name of the storage account. 

  .INPUTS
  System.String

  .OUTPUTS
  Context

  .EXAMPLE
  Get-PSStorageContext -ResourceGroupName 'ArcaneRG' `
                       -StorageAccountName 'ArcaneStorageAcct'


  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group containing the storage account'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the storage account to get the context for'
                   )
         ]
         [string]$StorageAccountName
       )
  
  $fn = 'Get-PSStorageContext:'
  # This uses the custom cmdlet declared earlier in this file
  $storageAccountKey = Get-PSStorageAccountKey `
                         -ResourceGroupName $ResourceGroupName `
                         -StorageAccountName $StorageAccountName
  

  # Now that we have the key, we can get the context
  Write-Verbose "$fn Getting Storage Context for account $StorageAccountName"
  $context = New-AzureStorageContext `
               -StorageAccountName $StorageAccountName `
               -StorageAccountKey $storageAccountKey

  return $context
}
#endregion Get-PSStorageContext

#region New-PSStorageContainer
<#---------------------------------------------------------------------------#>
<# New-PSStorageContainer                                                    #>
<#---------------------------------------------------------------------------#>
function New-PSStorageContainer ()
{ 
<#
  .SYNOPSIS
  Create a new Azure Blob Storage Container.

  .DESCRIPTION
  Checks to see if a storage container already exists for the name passed in.
  If not, it will create a new Blob Storage Container. 

  .PARAMETER ContainerName
  The name of the container to create.

  .PARAMETER ResourceGroupName
  The name of the resource group containing the storage account

  .PARAMETER StorageAccountName
  The name of the storage account you want to create a container in

  .INPUTS
  System.String

  .OUTPUTS
  A new Azure Blob Storage Container

  .EXAMPLE
  New-PSStorageContainer -ContainerName 'ArcaneContainer' `
                         -ResourceGroupName 'ArcaneRG' `
                         -StorageAccountName 'ArcaneStorageAcct'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the container to create'
                   )
         ]
         [string]$ContainerName 
       , [Parameter( Mandatory=$true
                   , HelpMessage='The resource group containing the storage account'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the storage account to create the container in'
                   )
         ]
         [string]$StorageAccountName
       )
  
  $fn = 'New-PSStorageContainer:'
  Write-Verbose "$fn Checking for Storage Container $ContainerName"

  # First we have to have the storage context
  $context = Get-PSStorageContext `
               -ResourceGroupName $ResourceGroupName `
               -StorageAccountName $StorageAccountName
  
  # Now we can check to see if it exists
  $exists = Get-AzureStorageContainer -Name $ContainerName `
                                      -Context $context `
                                      -ErrorAction SilentlyContinue

  # If it doesn't exist, we'll create it                            
  if ($exists -eq $null)
  { 
    Write-Verbose "$fn Creating Storage Container $ContainerName"
    New-AzureStorageContainer -Name $ContainerName `
                              -Context $context `
                              -Permission Blob
  }
  
  # Whether it already existed or we just created it, we'll grab a reference
  # to it and return it from the function
  Write-Verbose "$fn Retrieving container $ContainerName information"
  $container = Get-AzureStorageContainer -Name $ContainerName `
                                         -Context $context
  return $container
}
#endregion New-PSStorageContainer

#region New-PSAzureSQLServer
<#---------------------------------------------------------------------------#>
<# New-PSAzureSQLServer                                                      #>
<#---------------------------------------------------------------------------#>
function New-PSAzureSQLServer ()
{
<#
  .SYNOPSIS
  Create a new AzureSQL SQL Server.

  .DESCRIPTION
  Checks to see if an AzureSQL SQL Server already exists for the name passed
  in. If not, it will create a new AzureSQL SQL Server. 

  .PARAMETER ServerName
  The name of the server to create.

  .PARAMETER ResourceGroupName
  The name of the resource group to create the AzureSQL SQL Server in.

  .PARAMETER Location
  The geographic location to place the server in (southcentralus, etc)

  .PARAMETER UserName
  The name to use as the administrator user

  .PARAMETER Password
  The password to associate with the administrator user

  .INPUTS
  System.String

  .OUTPUTS
  A new AzureSQL SQL Server

  .EXAMPLE
  New-PSAzureSQLServer -ServerName 'MySQLServer' `
                       -ResourceGroupName 'ArcaneRG' `
                       -Location 'southcentralus' `
                       -UserName 'ArcaneCode' `
                       -Password 'mypasswordgoeshere'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the SQL Server to create'
                   )
         ]
         [string]$ServerName 
       , [Parameter( Mandatory=$true
                   , HelpMessage='The resource group to put the SQL Server in'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the geographic location to create the server in'
                   )
         ]
         [string]$Location
       , [Parameter( Mandatory=$true
                   , HelpMessage='The user name for the administrator of the SQL Server'
                   )
         ]
         [string]$UserName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The password for the administrator of the SQL Server'
                   )
         ]
         [string]$Password
       )

  $fn = 'New-PSAzureSQLServer:'
  Write-Verbose "$fn Checking for SQL Server $ServerName"
  $exists = Get-AzureRmSqlServer | Where-Object ServerName -eq $serverName

  # If the server doesn't exist, create it.
  if ($exists -eq $null)
  {   
    # Generate a credential object for use with the server
    $passwordSecure = $Password | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object PSCredential ($username, $passwordSecure)
  
    # Now create the server
    Write-Verbose "$fn Creating the SQL Server $serverName"
    New-AzureRmSqlServer -ResourceGroupName $resourceGroupName `
                         -ServerName $serverName `
                         -Location $location `
                         -SqlAdministratorCredentials $cred
  }

}
#endregion New-PSAzureSQLServer

#region New-PSAzureSQLServerFirewallRule
<#---------------------------------------------------------------------------#>
<# New-PSAzureSQLServerFirewallRule                                          #>
<#---------------------------------------------------------------------------#>
function New-PSAzureSQLServerFirewallRule ()
{
<#
  .SYNOPSIS
  Create a new firewall on an existing AzureSQL SQL Server.

  .DESCRIPTION
  Checks to see if the passed in name for the firewall on the specified 
  AzureSQL SQL Server already exists. If not, it will create the firewall 
  using the supplied parameters. 

  .PARAMETER ServerName
  The name of the server to apply the firewall rule to.

  .PARAMETER ResourceGroupName
  The name of the resource group containing the AzureSQL SQL Server

  .PARAMETER FirewallRuleName
  The name to give to this firewall rule

  .PARAMETER StartIpAddress
  The beginning IP address to open up

  .PARAMETER EndIpAddress
  The last IP address to open up

  .INPUTS
  System.String

  .OUTPUTS
  A new firewall rule

  .EXAMPLE
  New-PSAzureSQLServerFirewallRule -ServerName 'MySQLServer' `
                                   -ResourceGroupName 'ArcaneRG' `
                                   -FirewallRuleName 'myfirewallrule' `
                                   -StartIpAddress '192.168.0.1' `
                                   -EndIpAddress '192.168.1.255'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The name of the SQL Server to create the rule for'
                   )
         ]
         [string]$ServerName 
       , [Parameter( Mandatory=$true
                   , HelpMessage='The resource group holding the SQL Server'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the firewall rule to create'
                   )
         ]
         [string]$FirewallRuleName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The beginning IP Address this rule applies to'
                   )
         ]
         [string]$StartIpAddress
       , [Parameter( Mandatory=$true
                   , HelpMessage='The ending IP Address this rule applies to'
                   )
         ]
         [string]$EndIpAddress
       )

  $fn = 'New-PSAzureSQLServerFirewallRule:'

  Write-Verbose "$fn Checking for Firewall Rule $FirewallRuleName"
  $exists = Get-AzureRmSqlServerFirewallRule `
              -ResourceGroupName $ResourceGroupName `
              -ServerName $Servername `
              -FirewallRuleName $FirewallRuleName `
              -ErrorAction SilentlyContinue
  

  # If not found, create it
  if ($exists -eq $null)
  { 
    Write-Verbose "$fn Creating Firewall Rule $FirewallRuleName"
    New-AzureRmSqlServerFirewallRule `
       -ResourceGroupName $ResourceGroupName `
       -ServerName $Servername `
       -FirewallRuleName $FirewallRuleName `
       -StartIpAddress $StartIpAddress `
       -EndIpAddress $EndIpAddress
  }
  
}
#endregion New-PSAzureSQLServerFirewallRule

#region New-PSBacPacFile
<#---------------------------------------------------------------------------#>
<# New-PSBacPacFile                                                          #>
<#---------------------------------------------------------------------------#>
function New-PSBacPacFile ()
{
<#
  .SYNOPSIS
  Generates a BACPAC file from a SQL Server Database.

  .DESCRIPTION
  Uses the SQLPackage application to generate a BACPAC file from a 
  SQL Server database. 

  .PARAMETER DatabaseName
  The name of the database to create a bacpac from.

  .PARAMETER Path
  The folder (aka directory) to place the created bacpac file in.

  .PARAMETER SourceServer
  The SQL Server holding the database to create the bacpac from

  .INPUTS
  System.String

  .OUTPUTS
  A bacpac file

  .EXAMPLE
  New-PSBacPacFile -DatabaseName 'MyDbToBacPac' `
                   -Path 'C:\Temp' `
                   -SourceServer 'localhost' 

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The database to create a backpac file from'
                   )
         ]
         [string]$DatabaseName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The folder to write the bacpac file to'
                   )
         ]
         [string]$Path
       , [Parameter( Mandatory=$true
                   , HelpMessage='The server holding the database to export'
                   )
         ]
         [string]$SourceServer
       )
  
  $fn = 'New-PSBacPacFile:'

  # Out output file name
  $targetFile = "$Path\$($DatabaseName).bacpac"
  Write-Verbose "$fn Creating bacpac $targetFile"
  
  # This uses the SQLPackage utility that ships with SQL Server. Note your
  # location may change. In addition, the most recent versions of SQL Server
  # (2017 and later) may have SQLPackage as a separate download. 
  $sqlPackage = '"C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin\sqlpackage.exe"'
  Write-Verbose "$fn Loading SQLPackage from $sqlPackage"

  # These are the parameters that are passed into the SQLPackage.exe
  $params = '/Action:Export ' `
          + "/SourceServerName:$($SourceServer) " `
          + "/SourceDatabaseName:$($DatabaseName) " `
          + "/targetfile:`"$($TargetFile)`" " `
          + '/OverwriteFiles:True '
  
  # Combine the sqlpackage.exe with the parameters
  $cmd = "& $($sqlPackage) $($params)"
  
  # Now execute it to create the bacpac
  Write-Verbose "$fn Executing $cmd"
  Invoke-Expression $cmd

}
#endregion New-PSBacPacFile

#region Set-PSBlobContent
<#---------------------------------------------------------------------------#>
<# Set-PSBlobContent                                                         #>
<#---------------------------------------------------------------------------#>
function Set-PSBlobContent ()
{
<#
  .SYNOPSIS
  Uploads a local file to a storage container.

  .DESCRIPTION
  This will upload a local file to an Azure storage container. First though,
  it checks to see if the file already exists, and if so is it the same size
  in Azure storage as it is on the local drive. If they match, then it skips
  the upload unless the -Force switch is used. 

  .PARAMETER FilePathName
  The path and file name to the local file to be uploaded.

  .PARAMETER ResourceGroupName
  The Resource Group holding the storage account.

  .PARAMETER StorageAccountName
  The storage account holding the container.

  .PARAMETER ContainerName
  The name of the container to upload to.

  .PARAMETER TimeOut
  Optional. The timeout period before the upload fails. Defaults to 500000 seconds.

  .PARAMETER Force
  A Switch that when present will always upload the file even if it already
  exists and is the same size locally as it is in the container.

  .INPUTS
  System.String

  .OUTPUTS
  A new file in the container.

  .EXAMPLE
  Set-PSBlobContent -FilePathName 'C:\Temp\myfile.txt' `
                    -ResourceGroupName 'ArcaneRG' `
                    -StorageAccountName 'ArcaneStorageAcct' `
                    -ContainerName 'ArcaneContainer'

  .EXAMPLE
  Set-PSBlobContent -FilePathName 'C:\Temp\myfile.txt' `
                    -ResourceGroupName 'ArcaneRG' `
                    -StorageAccountName 'ArcaneStorageAcct' `
                    -ContainerName 'ArcaneContainer' `
                    -TimeOut 900000 `
                    -Force

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2017 All rights reserved

.LINK
  http://arcanecode.me
#>
  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The directory / file name of the file to upload'
                   )
         ]
         [string]$FilePathName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The resource group holding the storage account'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The storage account name holding the container'
                   )
         ]
         [string]$StorageAccountName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the container to upload to'
                   )
         ]
         [string]$ContainerName
       , [int]$TimeOut = 500000
       , [switch]$Force
       )

  $fn = 'Set-PSBlobContent:'


  # We need the storage account key based on the account name
  Write-Verbose "$fn Getting key for account $StorageAccountName"
  $storageAccountKey = $(Get-AzureRmStorageAccountKey `
                          -ResourceGroupName $ResourceGroupName `
                          -Name $StorageAccountName `
                        ).Value[0]
  
  # With the account key we can get the storage context
  Write-Verbose "$fn Getting context for account $StorageAccountName"
  $context = New-AzureStorageContext `
               -StorageAccountName $storageAccountName `
               -StorageAccountKey $storageAccountKey
  
  # Get a file object from the path/file name
  Write-Verbose "$fn Getting a reference to $FilePathName"
  $localFile = Get-ChildItem -Path $FilePathName
  
  # Set a flag that assumes we'll need to upload
  $upload = $true

  # See if the file exists on the server and if so what size
  Write-Verbose "$fn Checking to see if $FilePathName already exists on the server"
  $azureFile = Get-AzureStorageBlob -Container $containerName -Context $context |
                    Where-Object Name -eq $localFile.Name
  
  # If it found the file...
  if ($azureFile -ne $null)
  {
    # ...and sizes are the same, no need to upload
    if ($azureFile.Length -eq $localFile.Length)
    { 
      $upload = $false 

      # As long as the user didn't include the force switch, let
      # them know the upload will be skipped
      if ($Force -eq $false)
      { Write-Verbose "$fn File already exists, upload will be skipped" }
    }
  }

  # If user inculded the Force switch, always upload even if
  # the file is already there and the same size
  if ($Force)
  { 
    Write-Verbose "$fn Force switched used, upload will occur"
    $upload = $true 
  }
  
  # Time outs are the biggest issue here, so going to catch the error
  # and stop the script if one occurs
  if ($upload -eq $true)
  { 
    Write-Verbose "$fn Uploading $localFile"
    
    try 
    { 
      Set-AzureStorageBlobContent -File $localFile.FullName `
                                  -Container $containerName `
                                  -Blob $localFile.Name `
                                  -Context $context `
                                  -ServerTimeoutPerRequest $TimeOut `
                                  -ClientTimeoutPerRequest $TimeOut `
                                  -Force
    }
    catch
    {
      throw $_  # Display the error
      break     # Halt the script
    }
  } # if ($upload -eq $true)
}
#endregion Set-PSBlobContent

#region Remove-PSAzureSQLDatabase
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureSQLDatabase                                                 #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureSQLDatabase ()
{
<#
  .SYNOPSIS
  Removes (aka drops) a database from an AzureSQL SQL Server

  .DESCRIPTION
  The routine first checks to see if the passed in database exists on the 
  target AzureSQL SQL Server. If so, it removes (or in SQL terminology drops)
  the database. It does so without prompting or any request for confirmation. 

  .PARAMETER ResourceGroupName
  The name of the resource group containing the server.

  .PARAMETER ServerName
  The name of the server holding the database to be dropped.

  .PARAMETER DatabaseName
  The name of the database to drop (remove).

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Remove-PSAzureSQLDatabase -ResourceGroupName 'MyResourceGroup' `
                            -ServerName 'localhost' `
                            -DatabaseName 'UnneededDatabase' 

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group holding the storage account'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The AzureSQL Server holding the db to drop'
                   )
         ]
         [string]$ServerName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database to drop'
                   )
         ]
         [string]$DatabaseName
       )

  $fn = 'Remove-PSAzureSQLDatabase:'

  Write-Verbose "$fn Checking to see if $DatabaseName exists on server $ServerName"
  $exists = Get-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName `
                                   -ServerName $ServerName |
            Where-Object DatabaseName -eq $DatabaseName
  
  if ($exists -ne $null)
  {
    Write-Verbose "$fn Removing database $DatabaseName from server $ServerName"
    Remove-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName `
                              -ServerName $ServerName `
                              -DatabaseName $DatabaseName `
                              -Force
  }

}
#endregion Remove-PSAzureSQLDatabase

#region New-PSAzureSQLDatabaseImport
<#---------------------------------------------------------------------------#>
<# New-PSAzureSqlDatabaseImport                                              #>
<#---------------------------------------------------------------------------#>
function New-PSAzureSqlDatabaseImport ()
{
<#
  .SYNOPSIS
  Begins the importation of a bacpac file into an AzureSQL SQL Server.

  .DESCRIPTION
  Begin the process to import a bacpac file into an AzureSQL SQL Server. This
  is an asyncronous process, once the process begins control is returned to
  PowerShell. 
  
  The routine returns a request object which can then be used to monitor the
  progress of the import. 

  .PARAMETER ResourceGroupName
  The name of the resource group containing the server.

  .PARAMETER ServerName
  The name of the server holding the database to be imported to.

  .PARAMETER DatabaseName
  The name of the database to import.

  .PARAMETER StorageAccountName
  Storage Account Name holding the bacpac file

  .PARAMETER StorageContainerName
  Storage Container Name holding the bacpac file
             
  .PARAMETER UserName
  Username for the SQL Administrator

  .PARAMETER Password
  The SQL Admins Password

  .PARAMETER DbEdition
  The database edition (Basic, Premimum, Standard, etc)'

  .PARAMETER ServiceObjectiveName
  Database Service Objective (Basic, P1, etc)'

  .PARAMETER DatabasemaxSizeBytes 
  (Optional) The projected maximum database size in bytes. Default value is 5000000

  .INPUTS
  System.String

  .OUTPUTS
  Return an object of type 
  Microsoft.Azure.Commands.Sql.Database.Model.AzureSqlDatabaseImportExportBaseModel

  .EXAMPLE
  $request = New-PSAzureSQLDatabaseImport `
                -ResourceGroupName 'myresourcegroup' `
                -ServerName 'myazuresqlserver' `
                -DatabaseName 'adatabase' `
                -StorageAccountName 'myaccountname' `
                -StorageContainerName 'mycontainer' `
                -UserName 'ArcaneCode' `
                -Password 'mypassword' `
                -DbEdition 'Basic' `
                -ServiceObjectiveName 'Basic'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The AzureSQL Server that will hold the imported db'
                   )
         ]
         [string]$ServerName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database to import'
                   )
         ]
         [string]$DatabaseName
       , [Parameter( Mandatory=$true
                   , HelpMessage='Storage Account Name holding the bacpac file'
                   )
         ]
         [string]$StorageAccountName
       , [Parameter( Mandatory=$true
                   , HelpMessage='Storage Container Name holding the bacpac file'
                   )
         ]
         [string]$StorageContainerName
       , [Parameter( Mandatory=$true
                   , HelpMessage='Username for the SQL Admin'
                   )
         ]
         [string]$UserName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The SQL Admins Password'
                   )
         ]
         [string]$Password
       , [Parameter( Mandatory=$true
                   , HelpMessage='The database edition (Basic, Premimum, Standard, etc)'
                   )
         ]
         [string]$DbEdition
       , [Parameter( Mandatory=$true
                   , HelpMessage='DB Service Objective (Basic, P1, etc)'
                   )
         ]
         [string]$ServiceObjectiveName
       , [int]$DatabasemaxSizeBytes = 5000000
       )

  $fn = 'New-PSAzureSqlDatabaseImport:'
  Write-Verbose "$fn ResourceGroupName $ResourceGroupName"
  Write-Verbose "$fn ServerName $ServerName"
  Write-Verbose "$fn DatabaseName $DatabaseName"
  Write-Verbose "$fn StorageAccountName $StorageAccountName"
  Write-Verbose "$fn StorageContainerName $StorageContainerName"
  Write-Verbose "$fn UserName $UserName"
  Write-Verbose "$fn DbEdition $DbEdition"
  Write-Verbose "$fn ServiceObjectiveName $ServiceObjectiveName"
  
  # Generate a credential object for use with the server
  $passwordSecure = $Password | ConvertTo-SecureString -AsPlainText -Force
  $cred = New-Object PSCredential ($UserName, $passwordSecure)

  # We now need the storage account key, and storage context
  Write-Verbose "$fn Getting Key for Storage Account $StorageAccountName"
  $storageAccountKey = Get-PSStorageAccountKey `
                          -ResourceGroupName $ResourceGroupName `
                          -StorageAccountName $StorageAccountName

  Write-Verbose "$fn Getting Storage Context for Storage Account $StorageAccountName"
  $context = Get-PSStorageContext -ResourceGroupName $ResourceGroupName `
                                  -StorageAccountName $StorageAccountName
  
  # With the key and context, we can get the URI to the bacpac file
  $storageUri = ( Get-AzureStorageBlob `
                    -blob "$($DatabaseName).bacpac" `
                    -Container $StorageContainerName `
                    -Context $context `
                ).ICloudBlob.uri.AbsoluteUri
  Write-Verbose "$fn StorageURI $storageUri"

  # Now we can begin the import process
  Write-Verbose "$fn Beginning Import of $DatabaseName"
  $request = New-AzureRmSqlDatabaseImport `
                -ResourceGroupName $ResourceGroupName `
                -ServerName $ServerName `
                -DatabaseName $DatabaseName `
                -StorageKeyType StorageAccessKey `
                -StorageKey $storageAccountKey `
                -StorageUri $storageUri `
                -AdministratorLogin $cred.UserName `
                -AdministratorLoginPassword $cred.Password `
                -Edition $DbEdition `
                -ServiceObjectiveName $ServiceObjectiveName `
                -DatabasemaxSizeBytes $DatabasemaxSizeBytes  

  Write-Verbose "New-PSAzureSqlDatabaseImport request $($request)"
  return $request               
}
#endregion New-PSAzureSqlDatabaseImport

#region Remove-PSAzureSqlDatabase
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureSqlDatabase                                                 #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureSqlDatabase ()
{
<#
  .SYNOPSIS
  Remove an Azure SQL Database

  .DESCRIPTION
  Removes an AzureSQL SQL Server Database, if it exists. 

  .PARAMETER ResourceGroupName
  The name of the resource group containing the server.

  .PARAMETER ServerName
  The name of the server holding the database to be imported to.

  .PARAMETER DatabaseName
  The name of the database to remove.

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group holding the server'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The AzureSQL Server that will holds the db to remove'
                   )
         ]
         [string]$ServerName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the database to remove'
                   )
         ]
         [string]$DatabaseName
       )

  $fn = 'Remove-PSAzureSqlDatabase:'

  Write-Verbose "$fn Checking for the existance of $DatabaseName"
  $exists = Get-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName `
                                   -ServerName $ServerName |
            Where-Object DatabaseName -eq $DatabaseName
  
  if ($exists -ne $null)
  {
    Write-Verbose "$fn Removing database $DatabaseName"
    Remove-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName `
                              -ServerName $ServerName `
                              -DatabaseName $DatabaseName `
                              -Force
  } 
  
}
#endregion Remove-PSAzureSQLDatabase

#region Remove-PSAzureSqlServerFirewallRule
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureSqlServerFirewallRule                                       #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureSqlServerFirewallRule ()
{
<#
  .SYNOPSIS
  Remove a firewall rule from an Azure SQL Server.

  .DESCRIPTION
  Removes a firewall rule from an Azure SQL Server.

  .PARAMETER ResourceGroupName
  The name of the resource group containing the server.

  .PARAMETER ServerName
  The name of the server holding the firewall rule to remove.

  .PARAMETER FirewallRuleName
  The name of the firewall rule to remove

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Remove-PSAzureSqlServerFirewallRule -ResourceGroupName 'myresourcegroup' `
                                      -ServerName 'myservername' `
                                      -FirewallRuleName 'firewallruletodelete'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group holding the server'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The AzureSQL Server that will holds the firewall rule to remove'
                   )
         ]
         [string]$ServerName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the firewall rule to remove'
                   )
         ]
         [string]$FirewallRuleName
       )
  
  $fn = 'Remove-PSAzureSqlServerFirewallRule:'

  Write-Verbose "$fn Checking for the existance of the firewall rule $FirewallRuleName on the server $servername"
  $exists = Get-AzureRmSqlServerFirewallRule `
               -ResourceGroupName $ResourceGroupName `
               -ServerName $ServerName `
               -FirewallRuleName $FirewallRuleName `
               -ErrorAction SilentlyContinue

  if ($exists -ne $null)
  { 
     Write-Verbose "$fn Removing the firewall rule $FirewallRuleName from the server $Servername"
     Remove-AzureRmSqlServerFirewallRule `
           -ResourceGroupName $ResourceGroupName `
           -ServerName $ServerName `
           -FirewallRuleName $FirewallRuleName `
           -Force
  }

}
#endregion Remove-PSAzureSqlServerFirewallRule

#region Remove-PSAzureSqlServer
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureSqlServer                                                   #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureSqlServer ()
{
<#
  .SYNOPSIS
  Remove an Azure SQL Server

  .DESCRIPTION
  Removes an Azure SQL Server from Azure

  .PARAMETER ResourceGroupName
  The name of the resource group containing the server.

  .PARAMETER ServerName
  The name of the server holding the database to be imported to.

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
   Remove-PSAzureSqlServer -ResourceGroupName 'myresourcegroup' `
                           -ServerName 'servernametodelete' 
   
  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group holding the server'
                   )
         ]
         [string]$ResourceGroupName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The AzureSQL Server that will holds the db to remove'
                   )
         ]
         [string]$ServerName
       )

  $fn = 'Remove-PSAzureSqlServer:'

  Write-Verbose "$fn Checking for the existance of the SQL Server $ServerName"
  $exists = Get-AzureRmSqlServer | Where-Object ServerName -eq $ServerName

  if ($exists -ne $null)
  { 
    Write-Verbose "$fn Remove-PSAzureSqlServer Removing the SQL Server $ServerName"
    Remove-AzureRmSqlServer -ResourceGroupName $ResourceGroupName `
                            -ServerName $ServerName `
                            -Force
  } 

}
#endregion Remove-PSAzureSqlServer

#region Remove-PSAzureStorageContainer
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureStorageContainer                                            #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureStorageContainer ()
{
<#
  .SYNOPSIS
  Removes an Azure storage container from a storage account.

  .DESCRIPTION
  Removes an Azure storage container, and everything it contains, if that
  container exists. Be warned, it does not provide warnings, confirmations, 
  and the like.

  .PARAMETER ResourceGroupName
  The name of the resource group holding the storage container to remove.

  .PARAMETER StorageAccountName
  The name of the storage account holding the container to remove.

  .PARAMETER ContainerName
  The name of the container to be removed

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Remove-PsAzureStorageContainer -ResourceGroupName 'resourcegroupname' `
                                 -StorageAccountName 'storageaccount' `
                                 -ContainerName 'containertoremove'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group holding the storage account'
                   )
         ]
         [string]$ResourceGroupName 
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the storage account holding the container'
                   )
         ]
         [string]$StorageAccountName
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the container to remove'
                   )
         ]
         [string]$ContainerName
       )

  $fn = 'Remove-PSAzureStorageContainer:'

  Write-Verbose "$fn Get context for storage account $StorageAccountName"
  $context = Get-PSStorageContext -ResourceGroupName $ResourceGroupName `
                                  -StorageAccountName $StorageAccountName `
                                  -Verbose

  Write-Verbose "$fn Checking for Container $ContainerName"
  $exists = Get-AzureStorageContainer -Name $ContainerName `
                                      -Context $context `
                                      -ErrorAction SilentlyContinue

  # If it exists, we'll remove it                            
  if ($exists -ne $null)
  { 
    Write-Verbose "$fn Removing Container $ContainerName"
    Remove-AzureStorageContainer -Name $containerName `
                                 -Context $context `
                                 -Force 
  }
}
#endregion Remove-PSAzureStorageContainer

#region Remove-PSAzureStorageAccount
<#---------------------------------------------------------------------------#>
<# Remove-PSAzureStorageAccount                                              #>
<#---------------------------------------------------------------------------#>
function Remove-PSAzureStorageAccount ()
{
<#
  .SYNOPSIS
  Removes an Azure storage account.

  .DESCRIPTION
  Removes an Azure storage account, and everything it contains, if that account
  exists. Be warned, it does not provide warnings, confirmations, and the like.

  .PARAMETER ResourceGroupName
  The name of the resource group holding the storage account to remove.

  .PARAMETER StorageAccountName
  The name of the storage account to remove.

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Remove-PsAzureStorageAccount -ResourceGroupName 'resourcegroupname' `
                               -StorageAccountName 'accounttoremove'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group to put the storage account in'
                   )
         ]
         [string]$ResourceGroupName 
       , [Parameter( Mandatory=$true
                   , HelpMessage='The name of the storage account to create'
                   )
         ]
         [string]$StorageAccountName
       )

  $fn = 'Remove-PSAzureStorageAccount:'

  Write-Verbose "$fn Checking for account $StorageAccountName in group $ResourceGroupName"
  $saExists = Get-AzureRMStorageAccount `
                -ResourceGroupName $ResourceGroupName `
                -Name $StorageAccountName `
                -ErrorAction SilentlyContinue

  if ($saExists -ne $null)
  {
    Write-Verbose "$fn Removing account $StorageAccountName from group $ResourceGroupName"
    Remove-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName `
                                 -AccountName $StorageAccountName `
                                 -Force
  }
}
#endregion Remove-PSAzureStorageAccount

#region Remove-PsAzureResourceGroup
<#---------------------------------------------------------------------------#>
<# Remove-PsAzureResourceGroup                                               #>
<#---------------------------------------------------------------------------#>
function Remove-PsAzureResourceGroup ()
{
<#
  .SYNOPSIS
  Removes an Azure Resource Group

  .DESCRIPTION
  Removes an Azure Resource Group and everything it contains, if that group
  exists. Be warned, it does not provide warnings, confirmations, and the like.

  .PARAMETER ResourceGroupName
  The name of the resource group to remove.

  .INPUTS
  System.String

  .OUTPUTS
  none

  .EXAMPLE
  Remove-PsAzureResourceGroup -ResourceGroupName 'resourcegrouptoremove'

  .NOTES
  Author: Robert C. Cain  @arcanecode
  Website: http://arcanecode.me
  Copyright (c) 2018 All rights reserved

.LINK
  http://arcanecode.me
#>

  [cmdletbinding()]
  param(
         [Parameter( Mandatory=$true
                   , HelpMessage='The resource group to delete'
                   )
         ]
         [string]$ResourceGroupName
       )

  $fn = 'Remove-PsAzureResourceGroup:'

  Write-Verbose "$fn Checking for resource group $ResourceGroupName"
  $exists = Get-AzureRmResourceGroup | 
    Where-Object -Property 'ResourceGroupName' -eq $ResourceGroupName
  
  if ($exists -ne $null)
  {
    Write-Verbose "$fn Removing resource group $ResourceGroupName"
    Remove-AzureRmResourceGroup -Name $ResourceGroupName -Force
  }

}
#endregion Remove-PsAzureResourceGroup