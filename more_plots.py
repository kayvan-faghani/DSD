import matplotlib.pyplot as plt

# Data from user: [ticks/time] against [utilization]
# User specified: utilization on X, time on Y
utilization = [30.0, 29.3, 27.7]
time_ms = [9135, 9958, 31355]

# Sort data by X for a proper line plot flow
sorted_data = sorted(zip(utilization, time_ms))
x_sorted, y_sorted = zip(*sorted_data)

plt.figure(figsize=(10, 6))
plt.plot(x_sorted, y_sorted, marker='o', linestyle='-', color='tab:purple', linewidth=2, markersize=8)

# Labels and Title
plt.title('FPGA Utilization vs. Execution Time', fontweight='bold', fontsize=14)
plt.xlabel('Utilization (%)', fontweight='bold')
plt.ylabel('Time (ms)', fontweight='bold')

# Grid and Styling
plt.grid(True, linestyle='--', alpha=0.6)

# Annotate points with their specific values
for i in range(len(x_sorted)):
    plt.annotate(f"({x_sorted[i]}%, {y_sorted[i]})", 
                 (x_sorted[i], y_sorted[i]),
                 textcoords="offset points", 
                 xytext=(0,10), 
                 ha='center')

plt.tight_layout()
plt.savefig('utilization_vs_time.png')
plt.show()