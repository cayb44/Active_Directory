# 01 Installing the Domain Controller

1. Use `sconfig` to:
    - Change the hostname
    - Change the IP address to static
    - Change the DNS server to our own IP address

    To do this with PS use this commands:

    ```shell
    Rename-Computer -NewName "myName" -DomainCredential myDomain\myUser -Restart

    Get-NetIPInterface -AddressFamily IPv4
    Set-NetIPInterface -InterfaceIndex 'ifIndex' -Dhcp Disabled
    New-NetIPAddress -InterfaceIndex 'ifIndex' -AddressFamily IPv4 -IPAddress 'x.x.x.x' -PrefixLength 'x' -DefaultGateway 'x.x.x.x'
    Set-DnsClientServerAddress -InterfaceIndex 'ifIndex' -ServerAddresses 'x.x.x.x' -PassThru
    ```

2. Install the Active Directory Windows Feature


```shell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```