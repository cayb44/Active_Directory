$cred = Get-Credential Administrator
$dc1 = New-PSSession 192.168.249.155 -Credential $cred