#!/bin/bash

# Check if the duration is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <duration_in_minutes>"
    exit 1
fi

# Directory to store log files
log_dir="$(pwd)/"

# Create the directory if it doesn't exist
mkdir -p "$log_dir"

# Duration in minutes, converted to seconds
duration=$(( $1 * 60 ))

# Process name to search for
process_name="wdav" # Replace with your process name

# Interval in seconds for sampling
interval=1

# Calculate the number of iterations
iterations=$(( duration / interval ))

# Monitoring loop
for (( i=0; i<iterations; i++ )); do
    # Get current timestamp
    timestamp=$(date +"%H:%M:%S")

    # Find processes matching the process name, excluding the grep process
    while IFS= read -r line; do
        # Extract PID, command, and arguments
        pid=$(echo $line | awk '{print $2}')
        cmd_with_args=$(echo $line | awk -v pname="$process_name" '{for(i=11;i<=NF;++i) printf $i " ";}' | sed -e 's/[[:space:]]*$//')
        cmd=$(echo $cmd_with_args | grep -oP "(?<=/)$process_name[^ ]*")
        args=$(echo $cmd_with_args | sed "s/$cmd//" | tr ' ' '_')

        # If no command is found, continue to next line
        [ -z "$cmd" ] && continue

        # Define filename
        filename="${cmd}${args:+_$args}_cpu_usage.log"
        filename=$(echo $filename | sed 's/[^a-zA-Z0-9_\-\.]/_/g') # Replace non-alphanumeric characters

        # Get CPU usage of the process
        cpu_usage=$(ps -p $pid -o %cpu | awk 'NR>1')

        # If process is found, write to its file
        if [ ! -z "$cpu_usage" ]; then
            echo "$timestamp $cpu_usage" >> "$log_dir/$filename"
        fi
    done < <(ps aux | grep "$process_name" | grep -v grep)

    # Wait for the specified interval
    sleep $interval
done

echo "Monitoring complete."

# Zip and delete log files
log_zip="$log_dir/cpu_usage_logs_$(date +%Y%m%d%H%M%S).zip"
zip $log_zip $log_dir/*_cpu_usage.log
rm -f $log_dir/*_cpu_usage.log

echo "Logs zipped and original files deleted."
