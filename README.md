# Features:

    Dictionary attacks with a mask
    Attacks of hybrid brute force
    Testing of service accounts
    Testing local administrator accounts (Built-in and Group)

# Dependencies:

- ActiveDirectory Module
  
- Import-PSSession module

# Possible Errors and Solutions:

- ***Module import error:***
- Verify that the modules are installed and that PowerShell is running as an administrator.
  
- ***Error in authentication:***
- Check the domain name, username and password.
- Make sure the target accounts are unlocked.
  
- ***Error in connection:***
- Make sure the target computers are accessible.
- Verify that firewall policies allow remote communication

# Examples of Use:

- Dicionário attack with mask:

      $script -Domain "test.com" -ComputerList "SERVER1,SERVER2" -DictionaryFile "dictionary.txt" -Mask "user?123"

- Testing Service Accounts:

      $script -Domain "test.com" -ComputerList "SERVER 1,SERVER 2" -ServiceAccount List "SERVICE1,SERVICE2"

# Future Improvements:

- [ ] Generation of detailed reports

# Disclaimer

- ***The author of the script is not responsible for the use of the script for illegal purposes.***
  
- ***Remember if: Use it responsibly and only for legitimate purposes, such as authorized penetration testing.***
