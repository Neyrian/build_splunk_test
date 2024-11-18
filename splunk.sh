#!/bin/bash 

# Script name: splunk.sh

# Variables
container_name="splunk"   # Docker container ID or name
destination_path="/opt/splunk/var/log/splunk/" # Destination path in the container
working_dir=$HOME

## Apache Conf File
## Source: https://github.com/logpai/loghub
apache_logfile_path="$working_dir/Apache/Apache.log" # Path to your local log file
apache_host_name="apacheserver"              # Host name to set in Splunk
apache_sourcetype="apache_error"            # Sourcetype to set in Splunk
apache_index_name="apache"            # Splunk index name

## SSH Conf File
## Source: https://github.com/logpai/loghub
ssh_logfile_path="$working_dir/SSH/SSH.log" # Path to your local log file
ssh_host_name="sshhost"              # Host name to set in Splunk
ssh_sourcetype="linux_secure"            # Sourcetype to set in Splunk
ssh_index_name="linux"            # Splunk index name

## Linux Conf File
## Source: https://github.com/logpai/loghub
linux_logfile_path="$working_dir/Linux/Linux.log" # Path to your local log file
linux_host_name="linuxhost"              # Host name to set in Splunk
linux_sourcetype="linux_audit"            # Sourcetype to set in Splunk
linux_index_name="linux"            # Splunk index name

## windows Conf File
## Source: https://github.com/d4rk-d4nph3/Windows-Event-Samples
windows_logfile_path="$working_dir/Windows/Windows.log" # Path to your local log file
windows_host_name="windowshost"              # Host name to set in Splunk
windows_sourcetype="XmlWinEventLog"            # Sourcetype to set in Splunk
windows_index_name="windows"            # Splunk index name

## Apps
## Download them on the official splunk website https://splunkbase.splunk.com/
apache_ta_path="$working_dir/splunk-add-on-for-apache-web-server_210.tgz"
windows_ta_path="$working_dir/splunk-add-on-for-microsoft-windows_900.tgz"
linux_ta_path="$working_dir/splunk-add-on-for-unix-and-linux_920.tgz"


# Define the log function
log_message() {
    local log_level=$1
    shift
    local log_message="$@"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    echo "$timestamp [$log_level] $log_message"
}



# Check if no arguments were passed
if [ $# -eq 0 ]; then
    log_message "WARN" "Usage ./splunk.sh <option>"
    log_message "INFO" "./splunk.sh checks -> chekcs if everything is good"
    log_message "INFO" "./splunk.sh getLogFiles -> download the log Files"
    log_message "INFO" "./splunk.sh start -> start the containter splunk"
    log_message "INFO" "./splunk.sh delete -> delete the containter"
    log_message "INFO" "./splunk.sh stop -> stop the container"
    log_message "INFO" "./splunk.sh pause -> pause the container"
    log_message "INFO" "./splunk.sh unpause -> unpause the container"
    log_message "INFO" "./splunk.sh create -> create the container"
    log_message "INFO" "./splunk.sh status -> check the container status"
    log_message "INFO" "./splunk.sh restart -> restart splunk"
    log_message "INFO" "./splunk.sh shell -> start a shell as splunk user in the splunk docker"
    log_message "INFO" "./splunk.sh config -> display splunk config"
    log_message "INFO" "./splunk.sh import -> import the logs"
    log_message "INFO" "./splunk.sh apps -> install TA windows, linux, apache"
elif [ "$1" == "checks" ]; then
    log_message "INFO" "Checking Docker status"
    d_status=$(service docker status)
    if [ "$d_status" == "Docker is running." ]; then
        log_message "OK" "Docker is runnning"
    else
        log_message "INFO" "Starting docker"
        sudo service docker start
        sleep 5
    fi
    log_message "INFO" "Download the last docker image"
    sudo docker pull splunk/splunk:latest
    
    log_message "INFO" "Checking if all app files exists..."

    if ! [ -e $apache_ta_path ]; then
        log_message "WARN" "Apache TA doesn't exsits. Download it from https://splunkbase.splunk.com/ and put the archive in $working_dir"
    fi
    if ! [ -e $windows_ta_path ]; then
        log_message "WARN" "Windows TA doesn't exsits. Download it from https://splunkbase.splunk.com/ and put the archive in $working_dir"
    fi
    if ! [ -e $linux_ta_path ]; then
        log_message "WARN" "Linux TA doesn't exsits. Download it from https://splunkbase.splunk.com/ and put the archive in $working_dir"
    fi

    log_message "INFO" "Checking if all log files exists..."

    if ! [ -e $ssh_logfile_path ]; then
        log_message "WARN" "SSH log file doesn't exists"
    fi
    if ! [ -e $apache_logfile_path ]; then
        log_message "WARN" "Apache log file doesn't exists"
    fi
    if ! [ -e $linux_logfile_path ]; then
        log_message "WARN" "Linux log file doesn't exists"
    fi
    if ! [ -e $windows_logfile_path ]; then
        log_message "WARN" "Windows log file doesn't exists"
    fi
    log_message "INFO" "Checks finished..."

elif [ "$1" == "getLogFiles" ]; then
    log_message "INFO" "Download log files if missing..."
    cd $working_dir
    if ! [ -e $windows_logfile_path ]; then
        log_message "Warm" "DL windows logs"
        if ! [ -e $(dirname "$windows_logfile_path") ]; then mkdir $(dirname "$windows_logfile_path"); fi
        wget "https://raw.githubusercontent.com/d4rk-d4nph3/Windows-Event-Samples/refs/heads/main/WinEvents.log" -O "Windows.log" 
        mv Windows.log $working_dir/Windows
    fi
    if ! [ -e $ssh_logfile_path ]; then
        if ! [ -e $(dirname "$ssh_logfile_path") ]; then mkdir $(dirname "$ssh_logfile_path"); fi
        wget "https://zenodo.org/records/8196385/files/SSH.tar.gz?download=1" -O "SSH.tar.gz"
        tar -xzf $working_dir/SSH.tar.gz -C $working_dir/SSH/
        rm -f $working_dir/SSH.tar.gz
    fi
    if ! [ -e $apache_logfile_path ]; then
        if ! [ -e $(dirname "$apache_logfile_path") ]; then mkdir $(dirname "$apache_logfile_path"); fi
        wget "https://zenodo.org/records/8196385/files/Apache.tar.gz?download=1" -O "Apache.tar.gz"
        tar -xzf $working_dir/Apache.tar.gz -C $working_dir/Apache/
        rm -f $working_dir/Apache.tar.gz
    fi
    if ! [ -e $linux_logfile_path ]; then
        if ! [ -e $(dirname "$linux_logfile_path") ]; then mkdir $(dirname "$linux_logfile_path"); fi
        wget "https://zenodo.org/records/8196385/files/Linux.tar.gz?download=1" -O "Linux.tar.gz"
        tar -xzf $working_dir/Linux.tar.gz -C $working_dir/Linux/
        rm -f $working_dir/Linux.tar.gz
    fi


elif [ "$1" == "start" ]; then
    log_message "INFO" "No args, checking if spunk containter exists..."
    if [ "$(sudo docker ps -aq -f status=exited -f name=splunk)" ]; then
        log_message "INFO" "Starting containter..."
        sudo docker container start splunk
    else
        log_message "WARN" "No Splunk container or already running..."
    fi
elif [ "$1" == "delete" ]; then
    if [ "$(sudo docker ps -q -f  name=splunk)" ]; then
        log_message "ERROR" "The containter is running, can't delete..."
    elif [ "$(sudo docker ps -aq -f status=exited -f name=splunk)" ]; then
        log_message "INFO" "Deleting the splunk containter."
        sudo docker container rm splunk
    else
        log_message "WARN" "No Splunk container..."
        log_message "WARN" "run splunk.sh create"
    fi
elif [ "$1" == "stop" ]; then
    if [ "$(sudo docker ps -q -f  name=splunk)" ]; then
        log_message "INFO" "Stoping the splunk containter."
        sudo docker container stop splunk
    else
        log_message "ERROR" "Container not running..."
    fi
elif [ "$1" == "pause" ]; then
    if [ "$(sudo docker ps -q -f  name=splunk)" ]; then
        log_message "INFO" "Pausing the splunk containter."
        sudo docker container pause splunk
    else
        log_message "ERROR" "Container not running..."
    fi
elif [ "$1" == "unpause" ]; then
    if [ "$(sudo docker ps -q -f  name=splunk)" ]; then
        log_message "INFO" "Pausing the splunk containter."
        sudo docker container unpause splunk
    else
        log_message "ERROR" "Container not running..."
    fi
elif [ "$1" == "create" ]; then
    log_message "INFO" "checking if no spunk containter exists..."
    if [ "$(sudo docker ps -aq -f status=exited -f name=splunk)" ]; then
        log_message "WARN" "Splunk container exists."
        log_message "INFO" "Deleting the splunk containter."
        sudo docker container rm splunk
    fi
    log_message "INFO" "Creating spunk containter..."
    sudo docker run -d -p 8000:8000 -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_PASSWORD=Admin#123" --name splunk splunk/splunk:latest
    log_message "INFO" "Use import and app to upload logs file and install required app to your instance"
elif [ "$1" == "status" ]; then
    sudo docker container logs splunk
    sudo docker container ls -a
elif [ "$1" == "restart" ]; then
    if [ "$(sudo docker ps -q -f  name=splunk)" ]; then
        log_message "INFO" "Restarting splunk."
        sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk restart"
    else
        log_message "ERROR" "Container not running..."
    fi
elif [ "$1" == "shell" ]; then
    if [ "$(sudo docker ps -q -f  name=splunk)" ]; then
        log_message "INFO" "Open shell as splunk user"
        sudo docker exec --user splunk -it "$container_name" /bin/bash
    else
        log_message "ERROR" "Container not running..."
    fi
elif [ "$1" == "config" ]; then
    log_message "CONF" "linux: sourcetype=linux_audit index=linux host=linuxhost"
    log_message "CONF" "ssh: sourcetype=linux_secure index=linux host=sshhost"
    log_message "CONF" "apache: sourcetype=apache_error index=apache host=apacheserver"
    log_message "CONF" "windows: sourcetype=XmlWinEventLog index=windows host=windowshost"
elif [ "$1" == "import" ]; then
    sudo docker exec --user splunk -it "$container_name" /bin/bash -c "mkdir /opt/splunk/etc/apps/search/local"

    log_message "INFO" "Add index apache"
    sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add index $apache_index_name"
    log_message "INFO" "Add apache config"
    sudo docker exec --user splunk -it splunk /bin/bash -c "
        echo '[apache]
LINE_BREAKER = ([\r\n]+)
NO_BINARY_CHECK = true
SHOULD_LINEMERGE = false 
TIME_FORMAT = %a %b %d %H:%M:%S %Y
category = Custom
disabled = false
pulldown_type = true' >> /opt/splunk/etc/apps/search/local/props.conf"

    log_message "INFO" "Add index linux"
    sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add index $ssh_index_name"
    log_message "INFO" "Add linux config"
    sudo docker exec --user splunk -it splunk /bin/bash -c "
        echo '[linux]
LINE_BREAKER = ([\r\n]+)
NO_BINARY_CHECK = true
SHOULD_LINEMERGE = false 
TIME_FORMAT = %b %d %H:%M:%S
category = Custom
disabled = false
pulldown_type = true' >> /opt/splunk/etc/apps/search/local/props.conf"

    log_message "INFO" "Add index windows"
    sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add index $windows_index_name"
    log_message "INFO" "Add windows config"
    sudo docker exec --user splunk -it splunk /bin/bash -c "
        echo '[windows]
LINE_BREAKER = ([\r\n]+)
NO_BINARY_CHECK = true
SHOULD_LINEMERGE = true 
TIME_FORMAT = %Y-%m-%dT%H:%M:%S.%6N%:z
category = Custom
disabled = false
pulldown_type = true' >> /opt/splunk/etc/apps/search/local/props.conf"

    log_message "INFO" "Importing Apache Logs"
    log_message "INFO" "Copying apache log file to Docker container..."
    sudo docker cp "$apache_logfile_path" "$container_name":"$destination_path"
    log_message "INFO" "Changing ownership and rights "
    sudo docker exec -it "$container_name" /bin/bash -c "sudo chown splunk:splunk ${destination_path}$(basename "$apache_logfile_path") && sudo chmod 600 ${destination_path}$(basename "$apache_logfile_path")"
    log_message "INFO" "Importing log file into Splunk..."
    sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add oneshot ${destination_path}$(basename "$apache_logfile_path") -index $apache_index_name -sourcetype $apache_sourcetype -hostname $apache_host_name"
    log_message "INFO" "ApacheLog file has been imported into Splunk with host configuration."


    log_message "INFO" "Importing SSH Logs"
    log_message "INFO" "Copying SSH log file to Docker container..."
    sudo docker cp "$ssh_logfile_path" "$container_name":"$destination_path"
    log_message "INFO" "Changing ownership and rights "
    sudo docker exec -it "$container_name" /bin/bash -c "sudo chown splunk:splunk ${destination_path}$(basename "$ssh_logfile_path") && sudo chmod 600 ${destination_path}$(basename "$ssh_logfile_path")"
    log_message "INFO" "Importing log file into Splunk..."
    sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add oneshot ${destination_path}$(basename "$ssh_logfile_path") -index $ssh_index_name -sourcetype $ssh_sourcetype -hostname $ssh_host_name"
    log_message "INFO" "SSH logfile has been imported into Splunk with host configuration."

    log_message "INFO" "Importing Linux Logs"
    log_message "INFO" "Copying linux log file to Docker container..."
    sudo docker cp "$linux_logfile_path" "$container_name":"$destination_path"
    log_message "INFO" "Changing ownership and rights "
    sudo docker exec -it "$container_name" /bin/bash -c "sudo chown splunk:splunk ${destination_path}$(basename "$linux_logfile_path") && sudo chmod 600 ${destination_path}$(basename "$linux_logfile_path")"
    log_message "INFO" "Importing log file into Splunk..."
    sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add oneshot ${destination_path}$(basename "$linux_logfile_path") -index $linux_index_name -sourcetype $linux_sourcetype -hostname $linux_host_name"
    log_message "INFO" "linux logfile has been imported into Splunk with host configuration."

    log_message "INFO" "Importing Windows Logs"
    log_message "INFO" "Copying Windows log file to Docker container..."
    sudo docker cp "$windows_logfile_path" "$container_name":"$destination_path"
    log_message "INFO" "Changing ownership and rights "
    sudo docker exec -it "$container_name" /bin/bash -c "sudo chown splunk:splunk ${destination_path}$(basename "$windows_logfile_path") && sudo chmod 600 ${destination_path}$(basename "$windows_logfile_path")"
    log_message "INFO" "Importing log file into Splunk..."
    sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add oneshot ${destination_path}$(basename "$windows_logfile_path") -index $windows_index_name -sourcetype $windows_sourcetype -hostname $windows_host_name"
    log_message "INFO" "windows logfile has been imported into Splunk with host configuration."

elif [ "$1" == "apps" ]; then
    log_message "INFO" "Copying TAs"
    sudo docker cp "$apache_ta_path" "$container_name":"/tmp"
    sudo docker cp "$linux_ta_path" "$container_name":"/tmp"
    sudo docker cp "$windows_ta_path" "$container_name":"/tmp"

    log_message "INFO" "Installing TAs"
    sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk install app /tmp/$(basename "$apache_ta_path")"
    sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk install app /tmp/$(basename "$linux_ta_path")"
    sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk install app /tmp/$(basename "$windows_ta_path")"
fi
