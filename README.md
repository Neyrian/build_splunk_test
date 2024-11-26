# Purpose

This script aim to easly build a local splunk, and imports logs for tests purposes.

## Set up

1. Get the script from this repo 
```bash
git clone https://github.com/Neyrian/build_splunk_test.git
```

2. Ensure that you have docker installed, otherwise run
```bash
sudo apt install docker.io
```

3. Change the var $workind_dir in the script with your working dir.

4. Download in your $workind_dir the following splunk apps:
- Windows TA https://splunkbase.splunk.com/app/742
- Apache TA https://splunkbase.splunk.com/app/3186
- Unix and Linux TA https://splunkbase.splunk.com/app/833

5. (Optional) On a windows machine, export Security, Application and System logs in xml and put them in the folder $workind_dir/Windows under xmlwineventlogSecurity.xml, xmlwineventlogApplication.xml, xmlwineventlogSystem.xml.

5. Then run the cheks command
```bash
./splunk.sh checks
```

## Usages

You can display the "help" menu by running the script wuthout any args.
For your first run, you'd run the following commands
```bash
./splunk.sh checks
./splunk.sh create
./splunk.sh createIndexes
./splunk.sh importLogs
./splunk.sh apps
```
And your splunk instance should be available on http://localhost:8000/ with creds: admin:Admin#123 (by default)

## Using WSL2

If you are using WSL, you may encounter some issue accessing the splunk instance. It is likely a port forwarding issue.
Powershell command:
```Powershell
netsh interface portproxy add v4tov4 listenport=<Win_port> listenaddress=0.0.0.0 connectport=<WSL2_port> connectaddress=<WSL2_IP>
```
Obtain <WSL2_IP> from

```powershell
wsl hostname -I
```
To see existing port-forwardings:
```Powershell
netsh interface portproxy show all
```

To delete a particular port-forwarding:
```Powershell
netsh interface portproxy delete v4tov4 listenport=<port> listenaddress=<IP>
```
