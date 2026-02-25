# SVM Cluster Validation
These scripts validate the existence of clusters in a higher dimensional space using Support Vector Machine (SVM) classification. The analyses take coordinate data from principal component analysis and apply SVM models to determine cluster separability.

## Processes
**NOTE**: the coordinate values and corresponding labels were generated in Matlab and imported as Excel files.

1. `cluster_3d_visualization.py`
    - **Goal**: Create 3D visualizations of cluster data using the first three principal components
    - Loads coordinate data from day 5 and day 1, along with cluster labels
    - Applies StandardScaler to normalize the data before plotting
    - Creates scatter plots with different colors for each cluster
    - Outputs basic statistics about the number of data points and clusters

2. `svm_decision_boundary.py`
    - **Goal**: Visualize SVM decision boundaries in 3D space
    - Loads pre-trained SVM model and coordinate data
    - Creates mesh grids to visualize decision boundaries across 3D space
    - Plots both the original data points and the decision boundary contours
    - Demonstrates how the SVM separates different clusters in the feature space

3. `multi_class_svm.ipynb` (Main script)
    - **Goal**: Train and evaluate multi-class SVM models on cluster data
    - Jupyter notebook for interactive analysis of SVM performance
    - Includes model training, validation, and performance metrics

4. `d1_multi_class_svm.ipynb`
    - **Goal**: Perform multi-class SVM analysis specifically on day 1 data
    - Similar to `multi_class_svm.ipynb` but focused on day 1 dataset
    - Allows comparison of cluster separability between different time points

5. `plot_decision_boundary.ipynb`
    - **Goal**: Interactive visualization of SVM decision boundaries
    - Jupyter notebook for exploring different aspects of the decision boundary
    - Provides detailed plots and analysis of how the SVM classifies the data