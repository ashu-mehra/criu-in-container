#!/bin/bash

source common_env_vars.sh

function start_server() {
	/opt/ibm/helpers/runtime/docker-server.sh /opt/ibm/wlp/bin/server run defaultServer &
}

function shutdown_server() {
	/opt/ibm/wlp/bin/server stop defaultServer
}

function load_db() {
	declare users=$1
	declare db_retry_counter=0
	echo "INFO: Loading the database"
	while true;
	do
		declare output="`wget -O- http://localhost:80/rest/info/loader/load?numCustomers=$users`"
		if [[ $output =~ "Loaded flights and $users customers" ]]; then
			break
		else
			if [ $db_retry_counter -eq 10 ]; then
				echo "ERROR: Unable to load flight data into app"
				shutdown_server
				exit 1

			fi
			db_retry_counter=$(($db_retry_counter+1))
			sleep 10s
		fi
	done
}

function check_server_started() {
	declare retry_counter=0
	while true;
	do
		echo "INFO: Checking if server started (retry counter=${retry_counter})"
		grep "Web application available" /logs/messages.log &> /dev/null
		declare web_app_started=$?
		grep "The server defaultServer is ready to run a smarter planet" /logs/messages.log &> /dev/null
		declare server_started=$?
		if [ ${web_app_started} -eq 0 ] && [ ${server_started} -eq 0 ]; then
			echo "INFO: Server started successfully!"
			load_db 100
			return 0	
		else
			if [ $retry_counter -eq 10 ]; then
				echo "ERROR: Liberty server did not start properly"
				exit 1
			fi
			retry_counter=$(($retry_counter+1))
			sleep 10s
		fi
	done
}

function get_server_pid() {
	echo `ps -ef | grep java | grep -v grep | awk '{ print $2 }'`
}

function checkpoint_server() {
	declare server_pid=$(get_server_pid)
	echo "INFO: Server PID: ${server_pid}"
	echo "INFO: Checkpointing the server"
	criu dump -t ${server_pid} --tcp-established -j --leave-running -v4 -o ${CRIU_DUMP_LOGFILE}
	if [ $? -eq 0 ]; then
		echo "INFO: ${CRIU_CHECKPOINT_SUCCESS_MSG}"
	else
		echo "ERROR: ${CRIU_CHECKPOINT_FAILED_MSG}"
	fi
}

function handler() {
	echo "INFO: Recieved SIGUSR1...shutting down the server"
	shutdown_server
	exit 0
}

start_server
check_server_started
server_status=$?
if [ ${server_status} -eq 0 ]; then
	checkpoint_server
	trap handler SIGUSR1
	wait
else
	echo "ERROR: Something went wrong! Check the logs"
	exit 1
fi

