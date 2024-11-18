# Purpose

This script aim to easly build a local splunk, and imports logs for tests purposes.

## Set up

Get the script from this repo 
```bash
git clone https://github.com/Neyrian/build_splunk_test.git
```

ensure that you have docker installed, otherwise run
```bash
sudo apt install docker.io
```

Then run the cheks command and getLogFiles
```bash
./splunk.sh checks
./splunk.sh getLogFiles
```

## Usages

You can display the "help" menu by running the script wuthout any args.
For your first run, you'd run the following commands
```bash
./splunk.sh create
./splunk.sh checks
./splunk.sh getLogFiles
./splunk.sh import
```
And your splunk instance should be available on http://localhost:8000/

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
