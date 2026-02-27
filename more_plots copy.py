import matplotlib.pyplot as plt

# Data
terms = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
results = [
    270620459008.0, 208598106112.0, 212023050240.0, 211931594752.0,
    211932446720.0, 211932430336.0, 211932430336.0, 211932430336.0,
    211932430336.0, 211932430336.0, 211932430336.0
]
true_result = 211937410255.29
latency_ticks = [275, 1252, 2218, 3259, 4226, 5198, 6255, 7238, 8198, 9235, 10213]

# Calculation
pct_errors = [abs(r - true_result) / true_result * 100 for r in results]

print(pct_errors)
# Plotting
fig, ax1 = plt.subplots(figsize=(10, 6))

# Left Y-Axis: Latency
color_lat = 'tab:blue'
ax1.set_xlabel('Number of Taylor Terms', fontweight='bold')
ax1.set_ylabel('Taylor Latency (ms)', color=color_lat, fontweight='bold')
lns1 = ax1.plot(terms, latency_ticks, marker='o', color=color_lat, label='Latency (ms)', linewidth=2)
ax1.tick_params(axis='y', labelcolor=color_lat)
ax1.grid(True, linestyle='--', alpha=0.5)

# Right Y-Axis: Error (Linear Scale)
ax2 = ax1.twinx()
color_err = 'tab:green'
ax2.set_ylabel('Percentage Error (%)', color=color_err, fontweight='bold')
lns2 = ax2.plot(terms, pct_errors, marker='^', color=color_err, label='Percentage Error (%)', linewidth=2)
ax2.tick_params(axis='y', labelcolor=color_err)

# Merge Legends
lns = lns1 + lns2
labs = [l.get_label() for l in lns]
ax1.legend(lns, labs, loc='center right')

plt.title('Number of Taylor Expansion Terms vs. Latency and Accuracy', fontweight='bold', fontsize=14)
fig.tight_layout()
plt.savefig('combined_taylor_plot.png')
plt.show()