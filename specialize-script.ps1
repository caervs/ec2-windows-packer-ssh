$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Push-Location $Env:ProgramFiles\OpenSSH-Win64
.\ssh-keygen -A
.\ssh-add ssh_host_dsa_key
.\ssh-add ssh_host_rsa_key
.\ssh-add ssh_host_ecdsa_key
.\ssh-add ssh_host_ed25519_key
del *_key
Pop-Location

$keyPath = "C:\Users\Administrator\.ssh\authorized_keys"
$keyUrl = "http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key"
New-Item -ErrorAction Ignore -Type Directory C:\Users\Administrator\.ssh
Do { Start-Sleep 1 ; Invoke-WebRequest $keyUrl -UseBasicParsing -OutFile $keyPath } While ( -Not (Test-Path $keyPath) )