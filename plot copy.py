import matplotlib.pyplot as plt
import numpy as np

# --- INPUT DATA ---
lut_sizes = [256, 512, 1024, 2048, 4096]
cos_times = [1475, 1508, 1555, 1532, 1512]  # ms spent in lookup_cos
difference = [468156416.0, 237453312.0, 121389056.0, 64405504.0, 35569664.0]
standard_result = 211937410255.29
standard_cos_time = 5345 

# --- CALCULATIONS ---
pct_errors = [(d / standard_result) * 100 for d in difference]

# --- PLOTTING ---
fig, ax1 = plt.subplots(figsize=(10, 6))

# Set X-axis to Log Scale Base 2
ax1.set_xscale('log', base=2)
ax1.set_xticks(lut_sizes)

# Custom labels: Shows 2^n and the raw number
xtick_labels = [f'$2^{{{int(np.log2(s))}}}$\n({s})' for s in lut_sizes]
ax1.set_xticklabels(xtick_labels)

# Plot Latency (Left Y-Axis)
color_lat = 'tab:blue'
ax1.set_xlabel('LUT Size (Entries)', fontweight='bold')
ax1.set_ylabel('Latency (ms)', color=color_lat, fontweight='bold')
line1 = ax1.plot(lut_sizes, cos_times, color=color_lat, marker='o', label='LUT Latency (ms)')
ax1.axhline(y=standard_cos_time, color='blue', linestyle='--', alpha=0.3, label='Std cosf() Latency')
ax1.tick_params(axis='y', labelcolor=color_lat)

# Enable grid on both axes for the log scale
ax1.grid(True, which="both", linestyle='--', alpha=0.4)

# Create a second Y-axis for Percentage Error
ax2 = ax1.twinx()
color_pct = 'tab:green'
ax2.set_ylabel('Percentage Error (%)', color=color_pct, fontweight='bold')
line2 = ax2.plot(lut_sizes, pct_errors, color=color_pct, marker='^', linestyle='-', label='Percentage Error (%)')
ax2.tick_params(axis='y', labelcolor=color_pct)

# Titles and Legend
plt.title('LUT Size vs Latency and Percentage Error')
lines = line1 + line2
labels = [l.get_label() for l in lines]
ax1.legend(lines, labels, loc='upper right')

fig.tight_layout()
plt.savefig('lut_performance_pow2.png')
plt.show()