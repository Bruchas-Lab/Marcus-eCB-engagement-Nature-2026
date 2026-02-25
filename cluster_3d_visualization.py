import pickle

import numpy as np
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Load data
d5_coords = np.load("/Users/hades/Desktop/Bruchas Lab/Encoder_Decoder/DJM_binary_classification/Cluster_Validation/cluster_data/matched_data_5pc/d5_truncated_coordinates.npy")
d1_coords = np.load("/Users/hades/Desktop/Bruchas Lab/Encoder_Decoder/DJM_binary_classification/Cluster_Validation/cluster_data/matched_data_5pc/d1_truncated_coordinates.npy")
cluster_labels = np.load("/Users/hades/Desktop/Bruchas Lab/Encoder_Decoder/DJM_binary_classification/Cluster_Validation/cluster_data/matched_data_5pc/cluster_labels.npy")

# Load model
# with open('/Users/hades/Desktop/Bruchas Lab/Encoder_Decoder/DJM_binary_classification/linear_kernel_SVM_C100.pkl', 'rb') as f:
#     svm = pickle.load(f)

# Prepare the data
scaler = StandardScaler()
X_scaled = scaler.fit_transform(d5_coords)

# Create the 3D plot
fig = plt.figure(figsize=(12, 8))
ax = fig.add_subplot(111, projection='3d')

# Plot the data points
unique_labels = np.unique(cluster_labels)
colors = plt.cm.rainbow(np.linspace(0, 1, len(unique_labels)))
for label, color in zip(unique_labels, colors):
    mask = (cluster_labels == label)
    ax.scatter(X_scaled[mask, 0], X_scaled[mask, 1], X_scaled[mask, 2], 
               c=[color], label=f'Cluster {label}', s=50, alpha=0.7)

# Set labels and title
ax.set_xlabel('PC 1')
ax.set_ylabel('PC 2')
ax.set_zlabel('PC 3')
ax.set_title('SVM Classification w/ 3 PCs')

# Add a legend
ax.legend()

# Adjust the view angle for better visibility
ax.view_init(elev=20, azim=45)

plt.tight_layout()
plt.show()

# Print some basic statistics
print(f"Number of data points: {len(X_scaled)}")
print(f"Number of clusters: {len(unique_labels)}")
for label in unique_labels:
    print(f"Number of points in Cluster {label}: {np.sum(cluster_labels == label)}")



def plot_2d_pca(X_scaled, cluster_labels):
    # Create the 2D plot
    fig, ax = plt.subplots(figsize=(10, 8))

    # Plot the data points
    unique_labels = np.unique(cluster_labels)
    colors = plt.cm.rainbow(np.linspace(0, 1, len(unique_labels)))
    
    for label, color in zip(unique_labels, colors):
        mask = (cluster_labels == label)
        ax.scatter(X_scaled[mask, 0], X_scaled[mask, 1], 
                   c=[color], label=f'Cluster {label}', s=50, alpha=0.7)

    # Set labels and title
    ax.set_xlabel('PC 1')
    ax.set_ylabel('PC 2')
    ax.set_title('Clusters Visualized w/ 2 PC')

    # Add a legend
    ax.legend()

    # Add grid lines
    ax.grid(True, linestyle='--', alpha=0.7)

    # Adjust layout and display the plot
    plt.tight_layout()
    plt.show()

# Assuming X_scaled and cluster_labels are already defined
plot_2d_pca(X_scaled, cluster_labels)