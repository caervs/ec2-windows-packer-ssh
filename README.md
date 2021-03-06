# Packer template for building Windows with SSH public key authentication

This Packer template builds AWS AMIs that support login with SSH public key auth. When using instances created from this template you don't have to ever retrieve, worry about or use a Windows password. You can log in with SSH directly using your SSH key.

The public key is provisioned using the AWS EC2 key infrastructure. The template doesn't use WinRM at all, SSH is also used by the Packer builder.

# How to use

## Build AMI

```
packer build -var "branch=$(git rev-parse --abbrev-ref HEAD)" -var 'docker_version=1.13.1' -var 'docker_compose_version=1.11.1' -var 'git_version=2.11.1.windows.1' .\docker-ci\docker-ci.json
...
--> amazon-ebs: AMIs were created:
us-west-2: <ami-id>
```

## Create instance from AMI

### Using AWS CLI

```
$instanceid = aws ec2 run-instances --image-id <ami-id> --block-device-mapping '[{""DeviceName"": ""/dev/sda1"", ""Ebs"": {""VolumeSize"": 100, ""VolumeType"": ""gp2""}}]' --ebs-optimized --count 1 --instance-type c4.xlarge --key-name <key-name> --security-group-ids <security-group-id> --query "Instances[*].InstanceId" --output=text
aws ec2 describe-instances --instance-ids $instanceid --query "Reservations[*].Instances[*].PublicIpAddress" --output=text ; `
<ip-address>
```

## Log in

Wait for the instance to come up.

```
ssh -i <key-path> Administrator@<ip-address>
```

# Notes on Building Windows AMIs with OpenSSH

The chief concern when using these templates and building on AMIs generated with them, is making sure that the public key from the AWS metadata service is writte to the Administrator user's `~\.ssh\authorized_keys` directory on boot. There are two general ways to achieve this:

 * Do `sysprep` and make sure the key is written when an instance is launched from the sysprepped AMI. The key will only be re-written if another sysprep is done.
 * Pass in `userdata` script that writes the key from metadata. This has to be passed on every boot.

# TODO

 * Clean up the Packer builder to better support Windows
 * Don't restart at the end of builder-userdata.ps1 if possible
 * Figure out startup script that fetches public key from metadata API (perhaps using local group policy)
 * Disable WinRM and RDP after first boot (probably requires disabling the EC2 instance initialization since it relies on those services)

# Resources

 * http://jen20.com/2015/04/02/windows-amis-without-the-tears.html
 * http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2launch.html
 * https://github.com/jhowardmsft/docker-w2wCIScripts (Jenkins setup)
