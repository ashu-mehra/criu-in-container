#!/bin/bash

check_server_started() {
        local retry_counter=0
        while true;
        do
                echo "INFO: Checking if server started (retry counter=${retry_counter})"
                grep "Web application available" /logs/messages.log &> /dev/null
                local web_app_started=$?
                grep "The defaultServer server is ready to run a smarter planet" /logs/messages.log &> /dev/null
                local server_started=$?
                if [ ${web_app_started} -eq 0 ] && [ ${server_started} -eq 0 ]; then
                        echo "INFO: Server started successfully!"
			break
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

get_server_pid() {
	echo `ps -ef | grep java | grep -v grep | awk '{ print $2 }'`
}

start_app() {
	# start the application and set app_pid to the pid of the application process
	/opt/ibm/helpers/runtime/docker-server.sh /opt/ibm/wlp/bin/server run defaultServer &
	check_server_started
	if [ $? -eq 0 ]; then
		app_pid=$(get_server_pid)
		echo "INFO: Writing app pid ${app_pid} to ${CR_LOG_DIR}/${APP_PID_FILE}"
		echo "${app_pid}" > ${CR_LOG_DIR}/${APP_PID_FILE}
	fi
}

stop_app() {
	/opt/ibm/wlp/bin/server stop defaultServer

}

