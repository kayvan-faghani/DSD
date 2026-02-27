import matplotlib.pyplot as plt
import numpy as np

# --- DATA FROM NIOS II ---
labels = ['Software (cos)', 'Custom Instr (cos)', 'Custom Instr (cosf)','Taylor Series (6 terms)', 'LUT (4096)']
cos_ticks = [8357, 8303, 5365,3222,1444]      # Ticks spent ONLY in the cos function
total_ticks = [9958, 9135, 5910,4594,2960]    # Total execution ticks

# --- PLOTTING ---
x = np.arange(len(labels))
width = 0.35 

fig, ax = plt.subplots(figsize=(10, 6))

# Plot Latency (Bars)
bar1 = ax.bar(x - width/2, cos_ticks, width, label='Cos Routine ms', color='#3498db', edgecolor='black')
bar2 = ax.bar(x + width/2, total_ticks, width, label='Total ms', color='#2c3e50', edgecolor='black')

# Formatting
ax.set_ylabel('Time ms', fontweight='bold')
ax.set_title('Cos Implementation Comparison Clock Cycle Latency', fontsize=14, pad=20)
ax.set_xticks(x)
ax.set_xticklabels(labels)
ax.legend(loc='upper right')
ax.grid(axis='y', linestyle='--', alpha=0.6)

# Add value labels on top of the bars
def label_bars(rects):
    for rect in rects:
        height = rect.get_height()
        ax.annotate(f'{int(height)}',
                    xy=(rect.get_x() + rect.get_width() / 2, height),
                    xytext=(0, 3), textcoords="offset points",
                    ha='center', va='bottom', fontsize=10, fontweight='bold')

label_bars(bar1)
label_bars(bar2)

fig.tight_layout()
plt.show()

# --- PRINT SPEEDUP SUMMARY ---
base_latency = cos_ticks[1] # Standard (cos) is the baseline
print(f"{'Method':<18} | {'Cos Ticks':<10} | {'Total Ticks':<12} | {'Speedup (vs Std)'}")
print("-" * 65)
for i in range(len(labels)):
    speedup = base_latency / cos_ticks[i]
    print(f"{labels[i]:<18} | {cos_ticks[i]:<10} | {total_ticks[i]:<12} | {speedup:.2f}x")