#Provide the subscription Id
$subscriptionId = 'ed347077-d367-4401-af11-a87b73bbae0e'

#Provide the name of your resource group
$resourceGroupName ='PROD-RG'

#Provide the name of the snapshot that will be used to create OS disk
$snapshotName = 'linuximagetest_OsDisk_1_baf1528ea4f04c3d9ac69455046b322d-snap01'

#Provide the name of the OS disk that will be created using the snapshot
$osDiskName = 'linuximagetest_OsDisk_1_baf1528ea4f04c3d9ac69455046b322d-v2'

#Provide the name of an existing virtual network where virtual machine will be created
$virtualNetworkName = 'prodnet'

#Provide the Subnet ID of the existing virtual network stubnet
$SubnetId = '/subscriptions/ed347077-d367-4401-af11-a87b73bbae0e/resourceGroups/Prod-RG/providers/Microsoft.Network/virtualNetworks/prodnet/subnets/Subnet1'

#Provide the name of the virtual machine
$virtualMachineName = 'linuximagetestv2'

#Provide the size of the virtual machine
$virtualMachineSize = 'Standard_D2s_v3'

#Set the context to the subscription Id where Managed Disk will be created
Select-AzureRmSubscription -SubscriptionId $SubscriptionId

$snapshot = Get-AzureRmSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName

$diskConfig = New-AzureRmDiskConfig -Location $snapshot.Location -SourceResourceId $snapshot.Id -CreateOption Copy
 
$disk = New-AzureRmDisk -Disk $diskConfig -ResourceGroupName $resourceGroupName -DiskName $osDiskName

#Initialize virtual machine configuration
$VirtualMachine = $Null #Make sure the Variable is not in use
$VirtualMachine = New-AzureRmVMConfig -VMName $virtualMachineName -VMSize $virtualMachineSize

#Use the Managed Disk Resource Id to attach it to the virtual machine. Please change the OS type to linux if OS disk has linux OS
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -ManagedDiskId $disk.Id -CreateOption Attach -Linux

#Get the virtual network where virtual machine will be hosted
$vnet = Get-AzureRmVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $resourceGroupName

# Create NIC in the first subnet of the virtual network
$nic = New-AzureRmNetworkInterface -Name ($VirtualMachineName.ToLower()+'_nic') -ResourceGroupName $resourceGroupName -Location $snapshot.Location -SubnetId $SubnetId

$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $nic.Id

#Create the virtual machine with Managed Disk
New-AzureRmVM -VM $VirtualMachine -ResourceGroupName $resourceGroupName -Location $snapshot.Location