# Behavior To Neural Trace
All of the scripts here essentially try to tease out the relationship between neural activity and observed behaviors utilizing GLM(s).

## Processes
**NOTE**: These are not in particular order, but `cluster_and_split.m` needs to run before any other analysis; or alternatively, you could save the results from the script and load it before running other analyses.

1. `cluster_and_split.m`
    - **Goal**: Separate neurons by clusters while maintaining matching cell indicies across day 5 and day 1
    - Heavily borrowed from Dr. Marcus' clustering code
    - Takes `sortCellPavD1Traces` and `sortCellPavD5Traces` as inputs, which are both of shape (num neurons, trace length)
        - Importantly, the nuerons are ordered in the same way (i.e. neuron 1 in D5 is the same as neuron 1 in D1)
    - Each cell corresponds to day 1 and day 5 and contains elements equal to the number of clusters specified
    - Each cell element represents a cluster, and stores the constituent individual neuron traces
    - The outputs, named `separated_d5` and `separated_d1` form the basis of all other analyses

2. `GLM.m`
    - **Goal**: Fit GLM on behaviors and mean cluster activities and get their beta coefficients and p-values
    - Takes above `separated_d5` and `separated_d1` and reads two excel files of behaviors. Behaviors should be represented as a 2D matrix, where each row represents a behavior
        - In our case, we used a cue aligned behavior density, but an average could be used as well
    - A GLM is fit to each cluster, saving the beta coefficients and p-values
    - No output, I manually copied over the data into an Excel file

3. `GLM_Individual_Clusters.m`
    - **Goal**: Conduct same analysis as `GLM.m` but on individual neuron level
    - Takes same input as `GLM.m`
    - A GLM is fit to each neuron in a cluster, saving the beta coefficients and p-values
    - The script outputs the data as two Excel files (D5 and D1)

4. `GLM_Individual_residuals.m`
    - **Goal**: Plot residuals of GLMs fit to individual neurons
    - Takes same input as `GLM.m`
    - Similarly to `GLM_Individual_Clusters.m`, fits a GLM to individual neurons, then plots the distribution of **standardized** residuals for each cluster
    - Saves the plot as a SVG file

5. `new_t_summary.m`
    - **Goal**: Plot t-values of GLMs fit to individual neurons; effectively treating t-values as effect size
    - Takes same input as `GLM.m`
    - Performs the same operations as `GLM_Individual_residuals.m`, but only saves the t-values instead of residuals
    - Plots the t-values by cluster and saves it as a SVG file

6. `GLM_num_encoding.m`
    - **Goal**: Print how many GLMs fit to individual neurons encode behavior (based on a beta coefficient threshold)
    - Takes same input as `GLM.m`
    - Performs the same operations as `GLM_Individual_residuals.m`, but calculates the number of neurons with beta coefficients above the threshold
    - Prints the results (no file ouput)

7. `GLM_drop_behav.m`
    - **Goal**: Print the beta coefficients and p-values of a GLM with dropped behavior
    - Takes same input as `GLM.m`
    - Performs the same operations as `GLM_Individual_residuals.m`, but drops the behavior(s) specified
    - Prints the results (no file output)

8. `GLM_shift_validation.m`
    - **Goal**: Print beta coefficients and p-values of a GLM after performing varying amounts of circular shifts
    - Takes same input as `GLM.m`
    - Performs the same operations as `GLM.m`, but shifts the behaviors for each specified amount before fitting the GLM
    - Results saved as variable (no outputs)

9. `GLM_drop_neurons.m`
    - **Goal**: Print number of encoding neurons GLM after dropping varying percentages (up to 75%) from each cluster
    - Takes same input as `GLM.m`
    - Drops 0, 25, 50, and 75% of neurons (neurons selected randomly) then fits GLM to resulting population activity
    - Prints results (no file ouput)
    - *Fun Fact*: You can tell this analysis preceeded `GLM_num_encoding.m` and was unused (cuz the code sucks, more than usual), but the idea was good in theory
