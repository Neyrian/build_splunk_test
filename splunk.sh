#!/bin/bash 

# Script name: splunk.sh

##################
# You can edit these variable
container_name="splunk"   # Docker container ID or name
debug=true
splunk_pwd="Admin#123"
working_dir=$HOME
##################

destination_path="/opt/splunk/var/log/splunk/" # Destination path in the container

## Apache Conf File
## Source: https://github.com/logpai/loghub
apache_logfile_path="$working_dir/Apache/Apache.log" # Path to your local log file
apache_host_name="apacheserver"              # Host name to set in Splunk
apache_sourcetype="apache:error"            # Sourcetype to set in Splunk
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
linux_sourcetype="linux_secure"            # Sourcetype to set in Splunk
linux_index_name="linux"            # Splunk index name

## windows Conf File
## Source: https://github.com/d4rk-d4nph3/Windows-Event-Samples
windows_logfile_path="$working_dir/Windows/Windows.log" # Path to your local log file
windows_host_name="windowsjsonhost"              # Host name to set in Splunk
windows_sourcetype="windows_json"            # Sourcetype to set in Splunk
windows_index_name="windows"            # Splunk index name

## XML windows  Security Conf File
securitywindows_logfile_path="$working_dir/Windows/xmlwineventlogSecurity.xml" # Path to your local log file
securitywindows_host_name="windowsxmlhost"              # Host name to set in Splunk
securitywindows_sourcetype="XmlWinEventLog"            # Sourcetype to set in Splunk
securitywindows_index_name="windows"            # Splunk index name
securitywindows_source="XmlWinEventLog:Security"

## XML windows  system Conf File
systemwindows_logfile_path="$working_dir/Windows/xmlwineventlogSystem.xml" # Path to your local log file
systemwindows_host_name="windowsxmlhost"              # Host name to set in Splunk
systemwindows_sourcetype="XmlWinEventLog"            # Sourcetype to set in Splunk
systemwindows_index_name="windows"            # Splunk index name
systemwindows_source="XmlWinEventLog:System"            # Source to set in Splunk

## XML windows  application Conf File
applicationwindows_logfile_path="$working_dir/Windows/xmlwineventlogApplication.xml" # Path to your local log file
applicationwindows_host_name="windowsxmlhost"              # Host name to set in Splunk
applicationwindows_sourcetype="XmlWinEventLog"            # Sourcetype to set in Splunk
applicationwindows_index_name="windows"            # Splunk index name
applicationwindows_source="XmlWinEventLog:Application"            # Source to set in Splunk

## Apps
## Download them on the official splunk website https://splunkbase.splunk.com/
apache_ta_path="$working_dir/splunk-add-on-for-apache-web-server_210.tgz"
windows_ta_path="$working_dir/splunk-add-on-for-microsoft-windows_900.tgz"
linux_ta_path="$working_dir/splunk-add-on-for-unix-and-linux_920"


# Define the log function
log_message() {
    if [ "$debug" = true ]; then
        local log_level=$1
        shift
        local log_message="$@"
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

        echo "$timestamp [$log_level] $log_message"
    fi
}

# Check if no arguments were passed
if [ $# -eq 0 ]; then
    log_message "WARN" "Usage ./splunk.sh <option>"
    log_message "INFO" "./splunk.sh checks -> chekcs if everything is good"
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
    log_message "INFO" "./splunk.sh createIndexes -> create the indexes $apache_index_name, $ssh_index_name, $windows_index_name and their config"
    log_message "INFO" "./splunk.sh importLogs -> import the logs"
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
    
    log_message "INFO" "Checking if all app files exist..."

    if ! [ -e $apache_ta_path ]; then
        log_message "WARN" "Apache TA doesn't exsits. Download it from https://splunkbase.splunk.com/ and put the archive in $working_dir"
    fi
    if ! [ -e $windows_ta_path ]; then
        log_message "WARN" "Windows TA doesn't exsits. Download it from https://splunkbase.splunk.com/ and put the archive in $working_dir"
    fi
    if ! [ -e $linux_ta_path ]; then
        log_message "WARN" "Linux TA doesn't exsits. Download it from https://splunkbase.splunk.com/ and put the archive in $working_dir"
    fi

    log_message "INFO" "Checking if all log files exist..."

    if ! [ -e $ssh_logfile_path ]; then
        log_message "WARN" "SSH log file doesn't exist"
    fi
    if ! [ -e $apache_logfile_path ]; then
        log_message "WARN" "Apache log file doesn't exist"
    fi
    if ! [ -e $linux_logfile_path ]; then
        log_message "WARN" "Linux log file doesn't exist"
    fi
    if ! [ -e $windows_logfile_path ]; then
        log_message "WARN" "Windows log file doesn't exist"
    fi
    if ! [ -e $securitywindows_logfile_path ]; then
        log_message "WARN" "Windows Security XmlWinEventLog file doesn't exist"
    fi
    if ! [ -e $applicationwindows_logfile_path ]; then
        log_message "WARN" "Windows Application XmlWinEventLog file doesn't exist"
    fi
    if ! [ -e $systemwindows_logfile_path ]; then
        log_message "WARN" "Windows System XmlWinEventLog file doesn't exist"
    fi
    log_message "INFO" "Checks finished..."
elif [ "$1" == "start" ]; then
    log_message "INFO" "No args, checking if spunk containter exists..."
    if [ "$(sudo docker ps -aq -f status=exited -f name=$container_name)" ]; then
        log_message "INFO" "Starting containter..."
        sudo docker container start $container_name
    else
        log_message "WARN" "No existed container named $container_name"
    fi
elif [ "$1" == "delete" ]; then
    if [ "$(sudo docker ps -q -f  name=$container_name)" ]; then
        log_message "ERROR" "The containter is running, can't delete..."
    elif [ "$(sudo docker ps -aq -f status=exited -f name=$container_name)" ]; then
        log_message "INFO" "Deleting the containter named $container_name"
        sudo docker container rm $container_name
    else
        log_message "WARN" "No container named $container_name"
        log_message "WARN" "run splunk.sh create"
    fi
elif [ "$1" == "stop" ]; then
    if [ "$(sudo docker ps -q -f  name=$container_name)" ]; then
        log_message "INFO" "Stoping the containter."
        sudo docker container stop $container_name
    else
        log_message "ERROR" "The container named $container_name not running..."
    fi
elif [ "$1" == "pause" ]; then
    if [ "$(sudo docker ps -q -f  name=$container_name)" ]; then
        log_message "INFO" "Pausing the containter."
        sudo docker container pause $container_name
    else
        log_message "ERROR" "The container named $container_name not running..."
    fi
elif [ "$1" == "unpause" ]; then
    if [ "$(sudo docker ps -q -f  name=$container_name)" ]; then
        log_message "INFO" "Pausing the containter."
        sudo docker container unpause $container_name
    else
        log_message "ERROR" "The container named $container_name not running..."
    fi
elif [ "$1" == "create" ]; then
    log_message "INFO" "checking if no spunk containter exists..."
    if [ "$(sudo docker ps -aq -f status=exited -f name=$container_name)" ]; then
        log_message "WARN" "A container named $container_name already exists."
    else
        log_message "INFO" "Creating containter $container_name"
        sudo docker run -d -p 8000:8000 -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_PASSWORD=$splunk_pwd" --name $container_name splunk/splunk:latest
    fi
elif [ "$1" == "status" ]; then
    sudo docker container logs $container_name
    sudo docker container ls -a
elif [ "$1" == "restart" ]; then
    if [ "$(sudo docker ps -q -f  name=$container_name)" ]; then
        log_message "INFO" "Restarting the container $container_name."
        sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk restart"
    else
        log_message "ERROR" "Container not running..."
    fi
elif [ "$1" == "shell" ]; then
    if [ "$(sudo docker ps -q -f  name=$container_name)" ]; then
        log_message "INFO" "Open shell as splunk user"
        sudo docker exec --user splunk -it "$container_name" /bin/bash
    else
        log_message "ERROR" "Container not running..."
    fi
elif [ "$1" == "config" ]; then
    log_message "CONF" "Linux: sourcetype=$linux_sourcetype index=$linux_index_name host=$linux_host_name"
    log_message "CONF" "SSH: sourcetype=$ssh_sourcetype index=$ssh_index_name host=$ssh_host_name"
    log_message "CONF" "Apache: sourcetype=$apache_sourcetype index=$apache_index_name host=$apache_host_name"
    log_message "CONF" "Windows json: sourcetype=$windows_sourcetype index=$windows_index_name host=$windows_host_name"
    log_message "CONF" "XmlWinEventLog Security: sourcetype=$securitywindows_sourcetype index=$securitywindows_index_name host=$securitywindows_host_name source=$securitywindows_source"
    log_message "CONF" "XmlWinEventLog Application: sourcetype=$applicationwindows_sourcetype index=$applicationwindows_index_name host=$applicationwindows_host_name source=$applicationwindows_source"
    log_message "CONF" "XmlWinEventLog system: sourcetype=$systemwindows_sourcetype index=$systemwindows_index_name host=$systemwindows_host_name source=$systemwindows_source"
elif [ "$1" == "createIndexes" ]; then
    log_message "INFO" "Add index apache"
    sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add index $apache_index_name"

    log_message "INFO" "Add index linux"
    sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add index $ssh_index_name"

    log_message "INFO" "Add index windows"
    sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add index $windows_index_name"
elif [ "$1" == "importLogs" ]; then
    sudo docker exec --user splunk -it "$container_name" /bin/bash -c "mkdir /opt/splunk/etc/apps/search/local"
    if [ -e $apache_logfile_path ]; then
        log_message "INFO" "Importing Apache Logs"
        log_message "INFO" "Copying apache log file to Docker container..."
        sudo docker cp "$apache_logfile_path" "$container_name":"$destination_path"
        log_message "INFO" "Changing ownership and rights "
        sudo docker exec -it "$container_name" /bin/bash -c "sudo chown splunk:splunk ${destination_path}$(basename "$apache_logfile_path") && sudo chmod 600 ${destination_path}$(basename "$apache_logfile_path")"
        log_message "INFO" "Importing log file into Splunk..."
        sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add oneshot ${destination_path}$(basename "$apache_logfile_path") -index $apache_index_name -sourcetype $apache_sourcetype -hostname $apache_host_name"
        log_message "INFO" "ApacheLog file has been imported into Splunk with host configuration."
    fi

    if [ -e $ssh_logfile_path ]; then
        log_message "INFO" "Importing SSH Logs"
        log_message "INFO" "Copying SSH log file to Docker container..."
        sudo docker cp "$ssh_logfile_path" "$container_name":"$destination_path"
        log_message "INFO" "Changing ownership and rights "
        sudo docker exec -it "$container_name" /bin/bash -c "sudo chown splunk:splunk ${destination_path}$(basename "$ssh_logfile_path") && sudo chmod 600 ${destination_path}$(basename "$ssh_logfile_path")"
        log_message "INFO" "Importing log file into Splunk..."
        sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add oneshot ${destination_path}$(basename "$ssh_logfile_path") -index $ssh_index_name -sourcetype $ssh_sourcetype -hostname $ssh_host_name"
        log_message "INFO" "SSH logfile has been imported into Splunk with host configuration."
    fi

    if [ -e $linux_logfile_path ]; then
        log_message "INFO" "Importing Linux Logs"
        log_message "INFO" "Copying linux log file to Docker container..."
        sudo docker cp "$linux_logfile_path" "$container_name":"$destination_path"
        log_message "INFO" "Changing ownership and rights "
        sudo docker exec -it "$container_name" /bin/bash -c "sudo chown splunk:splunk ${destination_path}$(basename "$linux_logfile_path") && sudo chmod 600 ${destination_path}$(basename "$linux_logfile_path")"
        log_message "INFO" "Importing log file into Splunk..."
        sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add oneshot ${destination_path}$(basename "$linux_logfile_path") -index $linux_index_name -sourcetype $linux_sourcetype -hostname $linux_host_name"
        log_message "INFO" "linux logfile has been imported into Splunk with host configuration."
    fi

    if [ -e $windows_logfile_path ]; then
        log_message "INFO" "Importing Windows JSON Logs"
        log_message "INFO" "Copying Windows log file to Docker container..."
        sudo docker cp "$windows_logfile_path" "$container_name":"$destination_path"
        log_message "INFO" "Changing ownership and rights "
        sudo docker exec -it "$container_name" /bin/bash -c "sudo chown splunk:splunk ${destination_path}$(basename "$windows_logfile_path") && sudo chmod 600 ${destination_path}$(basename "$windows_logfile_path")"
        log_message "INFO" "Importing log file into Splunk..."
        sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add oneshot ${destination_path}$(basename "$windows_logfile_path") -index $windows_index_name -sourcetype $windows_sourcetype -hostname $windows_host_name"
        log_message "INFO" "windows logfile has been imported into Splunk with host configuration."
    fi 

    if [ -e $securitywindows_logfile_path ]; then
        log_message "INFO" "Importing Windows Security Logs"
        log_message "INFO" "Copying Windows Security log file to Docker container..."
        sudo docker cp "$securitywindows_logfile_path" "$container_name":"$destination_path"
        log_message "INFO" "Changing ownership and rights "
        sudo docker exec -it "$container_name" /bin/bash -c "sudo chown splunk:splunk ${destination_path}$(basename "$securitywindows_logfile_path") && sudo chmod 600 ${destination_path}$(basename "$securitywindows_logfile_path")"
        log_message "INFO" "Importing log file into Splunk..."
        sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add oneshot ${destination_path}$(basename "$securitywindows_logfile_path") -index $securitywindows_index_name -sourcetype $securitywindows_sourcetype -hostname $securitywindows_host_name -rename-source $securitywindows_source"
        log_message "INFO" "windows security logfile has been imported into Splunk with host configuration."
    fi

    if [ -e $systemwindows_logfile_path ]; then
        log_message "INFO" "Importing Windows system Logs"
        log_message "INFO" "Copying Windows system log file to Docker container..."
        sudo docker cp "$systemwindows_logfile_path" "$container_name":"$destination_path"
        log_message "INFO" "Changing ownership and rights "
        sudo docker exec -it "$container_name" /bin/bash -c "sudo chown splunk:splunk ${destination_path}$(basename "$systemwindows_logfile_path") && sudo chmod 600 ${destination_path}$(basename "$systemwindows_logfile_path")"
        log_message "INFO" "Importing log file into Splunk..."
        sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add oneshot ${destination_path}$(basename "$systemwindows_logfile_path") -index $systemwindows_index_name -sourcetype $systemwindows_sourcetype -hostname $systemwindows_host_name -rename-source $systemwindows_source"
        log_message "INFO" "windows system logfile has been imported into Splunk with host configuration."
    fi

    if [ -e $applicationwindows_logfile_path ]; then
        log_message "INFO" "Importing Windows application Logs"
        log_message "INFO" "Copying Windows application log file to Docker container..."
        sudo docker cp "$applicationwindows_logfile_path" "$container_name":"$destination_path"
        log_message "INFO" "Changing ownership and rights "
        sudo docker exec -it "$container_name" /bin/bash -c "sudo chown splunk:splunk ${destination_path}$(basename "$applicationwindows_logfile_path") && sudo chmod 600 ${destination_path}$(basename "$applicationwindows_logfile_path")"
        log_message "INFO" "Importing log file into Splunk..."
        sudo docker exec -it "$container_name" /bin/bash -c "sudo /opt/splunk/bin/splunk add oneshot ${destination_path}$(basename "$applicationwindows_logfile_path") -index $applicationwindows_index_name -sourcetype $applicationwindows_sourcetype -hostname $applicationwindows_host_name -rename-source $applicationwindows_source"
        log_message "INFO" "windows application logfile has been imported into Splunk with host configuration."
    fi

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
