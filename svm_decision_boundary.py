import pickle

import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Load data
d5_coords = np.load("/Users/hades/Desktop/Bruchas Lab/Encoder_Decoder/DJM_binary_classification/cluster_data/matched_data_5pc/d5_truncated_coordinates.npy")
d1_coords = np.load("/Users/hades/Desktop/Bruchas Lab/Encoder_Decoder/DJM_binary_classification/cluster_data/matched_data_5pc/d1_truncated_coordinates.npy")
cluster_labels = np.load("/Users/hades/Desktop/Bruchas Lab/Encoder_Decoder/DJM_binary_classification/cluster_data/matched_data_5pc/cluster_labels.npy")

# Load the model
with open('/Users/hades/Desktop/Bruchas Lab/Encoder_Decoder/DJM_binary_classification/linear_kernel_SVM_C100.pkl', 'rb') as f:
    svm: SVC = pickle.load(f)

X = d5_coords
y = cluster_labels

# Select three dimensions for visualization
dim1, dim2, dim3 = 0, 1, 2  # You can change these to visualize different dimensions

# Create a mesh grid
x_min, x_max = X[:, dim1].min() - 0.5, X[:, dim1].max() + 0.5
y_min, y_max = X[:, dim2].min() - 0.5, X[:, dim2].max() + 0.5
z_min, z_max = X[:, dim3].min() - 0.5, X[:, dim3].max() + 0.5

n_points = 50  # Number of points to use for each dimension in the contour plot
xx, yy = np.meshgrid(np.linspace(x_min, x_max, n_points),
                     np.linspace(y_min, y_max, n_points))

# Flatten the grid for prediction
grid = np.c_[xx.ravel(), yy.ravel()]
grid = np.hstack([grid, np.mean(X[:, 2:], axis=0) * np.ones((grid.shape[0], 3))])

# Predict
Z = svm.predict(grid)
Z = Z.reshape(xx.shape)

# Create the 3D plot
fig = plt.figure(figsize=(10, 7))
ax = fig.add_subplot(111, projection='3d')

# Plot the decision boundary
z_range = np.linspace(z_min, z_max, 20)
for z in z_range:
    cs = ax.contour(xx, yy, Z, levels=[0], colors='r', alpha=0.5, zdir='z', offset=z)

# Plot the original data
scatter = ax.scatter(X[:, dim1], X[:, dim2], X[:, dim3], c=y, cmap=plt.cm.coolwarm, edgecolor='black', s=50)

ax.set_xlabel(f'Dimension {dim1+1}')
ax.set_ylabel(f'Dimension {dim2+1}')
ax.set_zlabel(f'Dimension {dim3+1}')
ax.set_title('3D SVM Decision Boundary (3 out of 5 dimensions)')

# Set the limits for z-axis
ax.set_zlim(z_min, z_max)

# Add a color bar
plt.colorbar(scatter)

plt.show()
