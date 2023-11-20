import os
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# Set directory to current working directory
log_dir = os.getcwd()

# Iterate over each log file in the directory
for filename in os.listdir(log_dir):
    if filename.endswith('_cpu_usage.log'):
        # Construct the full file path
        file_path = os.path.join(log_dir, filename)
        
        # Read the log file into a pandas DataFrame
        try:
            data = pd.read_csv(file_path, sep='\\s+', names=['Time', 'CPU_Usage'])
            data['Time'] = pd.to_datetime(data['Time'], format='%H:%M:%S')
            data['CPU_Usage'] = data['CPU_Usage'].astype(float)
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
            continue
        
        # Plotting
        plt.figure(figsize=(10, 6))
        plt.plot(data['Time'], data['CPU_Usage'], marker='o', linestyle='-')
        plt.xlabel('Time')
        plt.ylabel('CPU Usage (%)')
        plt.title(f'CPU Usage Over Time: {filename}')
        
        # Formatting the x-axis with appropriate time interval
        plt.gcf().autofmt_xdate()
        plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%H:%M:%S'))
        plt.gca().xaxis.set_major_locator(mdates.AutoDateLocator())

        # Setting y-axis limits to show the CPU usage range with some padding
        cpu_usage_min = data['CPU_Usage'].min() - 1
        cpu_usage_max = data['CPU_Usage'].max() + 1
        plt.ylim(cpu_usage_min, cpu_usage_max)

        plt.grid(True)
        plt.tight_layout()
        
        # Save the plot
        graph_filename = f"{filename.replace('.log', '')}_graph.png"
        plt.savefig(os.path.join(log_dir, graph_filename))
        plt.close()
        
        print(f"Graph saved as: {graph_filename}")
