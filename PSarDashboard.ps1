<#
.SYNOPSIS
    This dashboard will display all the information about your Azure Subscription
.DESCRIPTION
    -Cost Consumption Usage
    -Virtual Machines usage
    -Networks usage
    -Storages usage
.NOTES
    Author: Nicolas PRIGENT - MVP Cloud & Datacenter Management
    blog: www.get-cmd.com
    Date: 18/03/2018
.EXAMPLE
    .\PSarDashboard.ps1
#>

#Connect to Azure subscription
($AZsubscription = Get-AzureRmSubscription) | Out-Null
if ($AZsubscription -eq $NULL) { 
  $AZsubscription = Login-AzureRmAccount
} 
#Stop the dashboard
Get-UDDashboard | Stop-UDDashboard

    #Create the home page
    $HomePage = New-UDPage -Name "Home" -Icon home -Content { 
        $AzureRG = Get-AzureRmResourceGroup
        $TotalRG = (Get-AzureRmResourceGroup).count
        New-UDTable -Title "Resource Groups: $TotalRG"  -Headers @("ResourceGroupName","Location","ProvisioningState") -Endpoint {
            $AzureRG  | Out-UDTableData -Property @("ResourceGroupName","Location","ProvisioningState")
        }
    }

    #Create the network usage page
    $NetworkUsagePage = New-UDPage -Name "Network Usage" -Icon binoculars -Content {  
          New-UDInput -Title "Network Usage" -Id "NetworkForm" -Content {
            New-UDInputField -Type 'textbox' -Name 'Netlocation' -Placeholder 'Azure Location'
          } -Endpoint {
            param($Netlocation)
            #Then run the below command to check the Network usage details.
            $networks=Get-AzureRmNetworkUsage -Location $Netlocation | select @{label="Name";expression={$_.resourcetype}},currentvalue,@{label="PercentageUsed";expression={[math]::Round(($_.currentvalue/$_.limit)*100,1)}}
            New-UDInputAction -Content @(
                New-UDTable -Title "Network Usage" -Headers @("Name", "CurrentValue", "PercentageUsed") -Endpoint {
                $storages  | sort CurrentValue -Descending | Out-UDTableData -Property @("Name", "CurrentValue", "PercentageUsed")
                }
            )
        }
     }   

    #Create the storage usage page
    $StorageUsagePage = New-UDPage -Name "Storage Usage" -Icon percent -Content { 
        $storages=Get-AzureRmStorageUsage | select name,currentvalue,limit
        #Then run the below command to check the Storage usage details.
        New-UDTable -Title "Resource Groups: $TotalRG"  -Headers @("Name","CurrentValue","limit") -Endpoint {
            $storages  | sort CurrentValue -Descending | Out-UDTableData -Property @("Name", "CurrentValue", "limit")
        }
    }

    #Create the VM usage page
    $VMUsagePage = New-UDPage -Name "Virtual Machines Usage" -Icon institution -Content { 
      New-UDInput -Title "Virtual Machines Usage" -Id "VMForm" -Content {
            New-UDInputField -Type 'textbox' -Name 'VMlocation' -Placeholder 'Azure Location'
        } -Endpoint {
            param($VMlocation)
            #Then run the below command to check the VM usage details.
            $vms=Get-AzureRmVMUsage -Location $VMlocation | select currentvalue,@{label="PercentageUsed";expression={[math]::Round(($_.currentvalue/$_.limit)*100,1)}},@{label="Name";expression={$_.name.LocalizedValue}}
            New-UDInputAction -Content @(
                New-UDTable -Title "VMs Usage" -Headers @("Name", "CurrentValue", "PercentageUsed") -Endpoint {
                $vms  | sort CurrentValue -Descending | Out-UDTableData -Property @("Name", "CurrentValue", "PercentageUsed")
                }
            )
        }
     }  
 
     #Create the License page
     $PoshUDLicensePage = New-UDPage -Name "PoshUD License" -Icon exclamation_circle -Content { 
         $UDLicense = Get-UDLicense
         New-UDTable -Title "PoshUD License" -Headers @(" ", " ") -Endpoint{
            @{
               'Start Date' = $UDLicense.StartDate
               'User Name' = $UDLicense.UserName
                'Product Name' = $UDLicense.ProductName
                'End Date' = $UDLicense.EndDate
                'Host Number' = $UDLicense.SeatNumber
                'Is Trial?' = $UDLicense.IsTrial
            }.GetEnumerator() | Out-UDTableData -Property @("Name", "Value")
        }
     }

     #Create the Cost page
     $CostPage = New-UDPage -Name "Azure Cost" -Icon windows -Content { 
         New-UDInput -Title "Azure Consumption" -Id "CostForm" -Content {
            New-UDInputField -Type 'textbox' -Name 'StartDate' -Placeholder 'Start Date'
            New-UDInputField -Type 'textbox' -Name 'EndDate' -Placeholder 'End Date'
        } -Endpoint {
            param($StartDate, $EndDate)
               $Costing = Get-AzureRmConsumptionUsageDetail -StartDate $StartDate -EndDate $EndDate | select UsageStart,UsageEnd,InstanceName,PretaxCost,BillableQuantity
               New-UDInputAction -Content @(
                    New-UDTable -Title "Get Azure Consumption Usage" -Headers @("Usage Start","Usage End","Instance Name","Cost","Billable Quantity") -Endpoint {
                        $Costing  | Out-UDTableData -Property @("UsageStart","UsageEnd","InstanceName","PretaxCost","BillableQuantity")
                    }
               )
        }
     }

     #Create the About page
     $AboutPage = New-UDPage -Name "About" -Icon question_circle -Content { 
        New-UDTable -Title "About Nicolas PRIGENT" -Headers @(" ", " ") -Endpoint{
            @{
               'Name' = "Nicolas PRIGENT"
                'Job' = 'System Engineer'
                'Blog' = 'www.get-cmd.com'
                'About' = 'PowerShell Hero + MVP Cloud & Datacenter + MCSE Cloud And Infrastructure + MCSA Windows Servers'
                'Follow Me' = '@PrigentNico'
            }.GetEnumerator() | Out-UDTableData -Property @("Name", "Value")
        }
    }   

    #Create the theme
    $Theme = New-UDTheme -Name "Basic" -Definition @{
        UDDashboard = @{
            BackgroundColor = "rgb(153, 206, 255)"
            FontColor = "rgb(0, 0, 0)"
        }
    }

    #Create the footer
    $Footer = New-UDFooter -Copyright "Nicolas PRIGENT [ www.get-cmd.com ] - MVP Cloud & Datacenter Management"
    
    #Create the dashboard
    $MyDashboard = New-UDDashboard -Pages @($HomePage,$VMUsagePage, $NetworkUsagePage, $StorageUsagePage, $CostPage, $PoshUDLicensePage, $AboutPage) -Title "PowerShell Azure Reporting (PSAR) Dashboard" -Color "#00264d" -Theme $Theme -Footer $Footer

    #Start the dashboard
    Start-UDDashboard -Port 1002 -Dashboard $MyDashboard
