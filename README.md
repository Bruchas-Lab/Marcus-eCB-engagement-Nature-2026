# Terminal-NAc Relationship
These scripts analyze the temporal and causal relationships between terminal and nucleus accumbens (NAc) neural activity using various signal analysis methods. The analyses focus on understanding directional influence, phase synchronization, and temporal dynamics between these brain regions.

It should be noted that while many different analyses were attempted, only the Rayleigh test was utilized.

## Processes
**NOTE**: All scripts load pre-processed neural activity data from different NAc clusters and terminal regions, stored as numpy arrays (`.npy` file extension).

1. `preliminary_rayleigh.py`
    - **Goal**: Implement functions for Rayleigh test analysis of phase differences between neural signals
    - Contains helper functions for calculating phase differences using Hilbert transform
    - Implements Rayleigh statistics calculation (mean resultant length and angle)
    - Provides polar plotting functionality for visualizing phase relationships
    - Foundation script for phase analysis used in other notebooks

2. `rayleigh_test.ipynb`
    - **Goal**: Perform Rayleigh test to assess phase locking between terminal and NAc signals
    - Demonstrates phase difference analysis using synthetic signals
    - Applies phase analysis to real neural data from terminal and NAc clusters
    - Calculates mean resultant length and phase differences in degrees and milliseconds
    - Includes frequency domain analysis to identify significant frequency components

3. `phase_sync.ipynb`
    - **Goal**: Quantify phase synchronization between terminal and NAc activity using PSI (Phase Synchronization Index)
    - Applies bandpass filtering to focus on specific frequency ranges (0.01-4.92 Hz)
    - Calculates PSI values for each NAc cluster relative to terminal activity
    - Uses surrogate data analysis to determine statistical significance
    - Provides visualization of filtered signals and synchronization results

4. `granger_causality.ipynb`
    - **Goal**: Assess directional causal relationships between terminal and NAc clusters using Granger causality
    - Performs stationarity testing using KPSS and ADF tests
    - Implements Vector Autoregression (VAR) models for time series analysis
    - Tests for Granger causality to determine if one signal predicts another
    - Includes lag plot analysis and data preprocessing steps

5. `transfer_entropy.ipynb`
    - **Goal**: Measure information transfer between terminal and NAc using transfer entropy analysis
    - Applies bandpass filtering to focus on low-frequency components (0.01-0.5 Hz)
    - Calculates bidirectional transfer entropy (terminal→NAc and NAc→terminal)
    - Uses surrogate data permutation testing for statistical validation
    - Provides quantitative measures of information flow direction and strength

6. `individual_traces_rayleigh.ipynb`
    - **Goal**: Apply Rayleigh analysis to individual neuron traces rather than cluster averages
    - Extends the phase analysis approach to single-cell level data
    - Allows for assessment of phase relationships at finer temporal resolution

7. `robust_rayleigh.ipynb`
    - **Goal**: Implement robust versions of Rayleigh statistical tests
    - Provides alternative statistical approaches for phase analysis
    - Includes methods to handle outliers and non-uniform circular distributions