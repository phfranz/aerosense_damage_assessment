# Aerosense: Structural Damage Detection based on Aerodynamic Pressure Measurements

Code and classification models for the preprint "On the Potential of Aerodynamic Pressure Measurements for Structural Damage Detection", written by Philip Franz, Imad Abdallah, Gregory Duthé, Julien Deparday, Ali Jafarabadi, Xudong Jian, Max von Danwitz, Alexander Popp, Sarah Barber and Eleni Chatzi. The preprint is available under  https://doi.org/10.5194/wes-2025-26. 


The raw aerodynamic pressure measurements can be found in the repository: https://doi.org/10.34808/gq12-wx33. 
The CNNs provided in this repository use aerodynamic pressure coefficient data, not the raw sensor recordings. To convert the raw measurements into aerodynamic pressure coefficient data proceed as follows:


1.) Download the aerodynamic pressure measurements available in the folder "aerosense_data", and the accompanying file Labbook_Aerosense_Dynamic_Experiments.csv. \
2.) Copy the "aerosense_data" folder that contains the raw measurement data and the labbook file into the folder "process_raw_data".\
3.) Then, use main_postprocess.m to convert the raw data in pressure coefficient data.




