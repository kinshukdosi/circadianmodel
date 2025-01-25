25/01/25 - added matlab gui for analysis of the simple model from the same paper (SNF, NNF and PNF)


MATLAB App <br> <br>
Analysing how the amplitude of certain proteins changes with varying levels of initial concentrations <br>
Built using the detailed model described in the paper 'A mechanism for robust circadian timekeeping via stoichiometric balance' by Kim and Forger, 2012.
<br>https://www.embopress.org/doi/full/10.1038/msb.2012.62<br><br>
The model has been taken from the paper above and can be found in its original file DetailedModel.m
<br><br>
The app can be used to generate graphs of amplitudes of variables used in the detailed model against concentration relative to normal.<br>
To install as a standalone app for Apple Silicon devices, download the M1MacOSInstaller folder and run the installer<br>
To run in MATLAB, download app1.mlapp and run in MATLAB App Designer<br><br>

App Window:<br>
<img width="895" alt="image" src="https://github.com/user-attachments/assets/22c27f32-773a-4dd7-bd8c-60f55d27af9d">

<br><br>
Example generated graph for the amplitude of the concentration of Bmals mRNA in the nucleus varying the concentrations from Supplementary Table 1 between 50% and 150% of their original value (Note that the amplitude varies slightly at different times, which is why it has been calculated at 40 hours, 100 hours and 200 hours) <br><br>
<img width="547" alt="image" src="https://github.com/user-attachments/assets/71a2039c-d7e9-499c-a1fd-b3b1b202cc8e">
<br><br>
Note: Amplitudes have been calculated by subtracting the minimum value from the maximum value in a small range around t=40, 100 and 200, where the closest peak and trough is found. Also, the simulation is ran every 5%, meaning there are three data points every 5% on the graph. The larger the range specified, the longer the program will take to run.
