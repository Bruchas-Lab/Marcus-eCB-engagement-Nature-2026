# %%
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

# %%
"""
Functions
"""
def phase_difference(x, y):
    # Calculate the analytic signal using the Hilbert transform
    analytic_x = signal.hilbert(x)
    analytic_y = signal.hilbert(y)
    
    # Calculate the instantaneous phase difference
    phase_diff = np.angle(analytic_y) - np.angle(analytic_x)
    
    # Wrap to [-pi, pi]
    return np.angle(np.exp(1j * phase_diff))

def rayleigh_stats(phase):
    # Calculate mean vector
    mean_x = np.mean(np.cos(phase))
    mean_y = np.mean(np.sin(phase))
    
    # Calculate mean resultant length and angle
    R = np.sqrt(mean_x**2 + mean_y**2)
    theta_mean = np.arctan2(mean_y, mean_x)
    
    return R, theta_mean

def plot_rayleigh(phase, R, theta_mean):
    fig, ax = plt.subplots(figsize=(8, 8), subplot_kw=dict(projection='polar'))
    
    # Plot data points (all with radius 1)
    ax.scatter(phase, np.ones_like(phase), alpha=0.5)
    
    # Plot mean vector
    ax.arrow(0, 0, theta_mean, R, alpha=0.8, width=0.02,
             edgecolor='red', facecolor='red', lw=2, zorder=5)
    
    ax.set_ylim(0, 1.1)  # Set radial limit
    ax.set_rticks([0.5, 1])  # Add some radial ticks
    ax.set_rlabel_position(-22.5)  # Move radial labels away from plotted line
    ax.grid(True)
    
    ax.set_title("Phase Difference Rayleigh Plot")
    plt.tight_layout()
    plt.show()

# %%
"""
Test on sin and cos waves -- confirm it works as expected
"""
# Generate example time series
t = np.linspace(0, 10, 1000)
f1, f2 = 1, 1  # frequencies
phase_shift = np.pi/2  # phase shift between signals

x = np.sin(2 * np.pi * f1 * t)
y = 2 * np.cos(2 * np.pi * f2 * t + phase_shift)

# Add some noise
x += 0.1 * np.random.randn(len(t))
y += 0.1 * np.random.randn(len(t))

# Calculate phase differences
phase_diff = phase_difference(x, y)

# Calculate Rayleigh statistics
R, theta_mean = rayleigh_stats(phase_diff)

print(f"Mean resultant length (R): {R:.4f}")
print(f"Mean phase difference (degrees): {np.degrees(theta_mean):.2f}")

# Plot the results
plot_rayleigh(phase_diff, R, theta_mean)

# Plot the original time series
plt.figure(figsize=(10, 6))
plt.plot(t, x, label='Signal 1')
plt.plot(t, y, label='Signal 2')
plt.xlabel('Time')
plt.ylabel('Amplitude')
plt.title('Original Time Series')
plt.legend()
plt.show()

# %%
"""
Load signal data
"""
import os

# Change path to data
source = "/Users/hades/Desktop/Bruchas Lab/Encoder_Decoder/DJM_binary_classification/signal_data"

files = sorted([f for f in os.listdir(source) if f.endswith(".npy")])
full_paths = [os.path.join(source, f) for f in files]
np_arrs = [np.load(f) for f in full_paths]

# %%
"""
assign more intuitive names to arrays
"""
nac1 = np_arrs[0]
nac2 = np_arrs[1]
nac3 = np_arrs[2]
nac4 = np_arrs[3]
nac5 = np_arrs[4]
terminal = np_arrs[5]

# %%
"""
Plot the Rayleigh plot and the original time series
"""
# Change to cluster to visualize
y = nac1


x = terminal
t = np.arange(0, x.shape[0])

phase_diff = phase_difference(x, y)

# Calculate Rayleigh statistics
R, theta_mean = rayleigh_stats(phase_diff)

print(f"Mean resultant length (R): {R:.4f}")
print(f"Mean phase difference (degrees): {np.degrees(theta_mean):.2f}")

# Calculate time shift
sampling_rate = 700 / 71
period = 1 / sampling_rate
time_shift = (np.abs(theta_mean)/360) * period
print(f"Mean phase difference (milliseconds): {time_shift * 1e3:.2f}")

# Plot the results
plot_rayleigh(phase_diff, R, theta_mean)

# Plot the original time series
plt.figure(figsize=(10, 6))
plt.plot(t, x, label='Terminal')
plt.plot(t, y, label='Nac Cluster')
plt.xlabel('Time')
plt.ylabel('Amplitude')
plt.title('Original Time Series')
plt.legend()
plt.show()


