# Define an array with subscription products and their corresponding usage products
$subscriptions = @{
    "Cove Data Protection `| Server - Commitment" = "Cove Data Protection `| Server"
    "Cove Data Protection `| Virtual Machine Server - Commitment" = "Cove Data Protection `| Virtual Machine Server"
    "N-able N-sight `| Node - Postpaid Commitment" = "N-able N-sight `| Node"
    # Add more subscriptions and corresponding usage products as needed
}


# Get the script's current location and the path to the Invoices folder
$scriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$invoicesPath = Join-Path -Path $scriptPath -ChildPath "Invoices"

# Get all CSV files in the Invoices folder
$csvFiles = Get-ChildItem -Path $invoicesPath -Filter *.csv

foreach ($file in $csvFiles) {
    # Read the CSV file
    $records = Import-Csv -Path $file.FullName

    # Create a list to store subscription information
    $subscriptionList = @()

    # Iterate through the records to find subscriptions
    foreach ($record in $records) {
        if ($record.'Rating Method' -eq 'Subscription' -and $subscriptions.ContainsKey($record.Product)) {
            $subscriptionList += [PSCustomObject]@{
                Product = $record.Product
                Rate    = $record.Rate
                Quantity = $record.Quantity
            }
        }
    }

    # Iterate through the records again to update usage records
    foreach ($record in $records) {
        if ($record.'Rating Method' -eq 'Usage') {
            foreach ($subscription in $subscriptionList) {
                if ($record.Product -eq $subscriptions[$subscription.Product]) {
                    $record.Rate = $subscription.Rate
                    $record.Cost = [math]::Round([double]$record.Quantity * [double]$record.Rate, 2)
                    $subscription.Quantity -= $record.Quantity
                }
            }
        }
    }

    # # Check if any subscription quantities are less than zero
    # foreach ($subscription in $subscriptionList) {
    #     if ($subscription.Quantity -lt 0) {
    #         Write-Warning "Shortage in subscription quantity for product $($subscription.Product)"
    #     }
    # }

    # Write the updated records to a new CSV file
    $newFileName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name) + "_updated.csv"
    $newFilePath = Join-Path -Path $file.DirectoryName -ChildPath $newFileName
    $records | Export-Csv -Path $newFilePath -NoTypeInformation
}
