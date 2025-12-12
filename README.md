# On the Potential of Aerodynamic Pressure Measurements for Structural Damage Detection

This repository contains the code and trained convolutional neural networks (CNNs) that accompany the preprint:

    Franz, P. I., Abdallah, I., Duthé, G., Deparday, J., Jafarabadi, A., Jian, X., von Danwitz, M., Popp, A., Barber, S. & Chatzi, E.:
    On the Potential of Aerodynamic Pressure Measurements for Structural Damage Detection, Wind Energ. Sci. Discuss. [preprint accepted for publication], 2025, https://doi.org/10.5194/wes-2025-26
    
The raw aerodynamic pressure measurements can be found in this repository: 

    https://doi.org/10.34808/gq12-wx33  
    
All CNN models provided here were trained with Python 3.10, TensorFlow 2.14.0 and Keras 2.14.0. The CNNs use aerodynamic pressure coefficient data, not the raw sensor recordings. To convert the raw measurements into aerodynamic pressure coefficient data, proceed as follows:

1.) Download the file "AeroSense-WT-EPFL.zip" from the data repository. \
2.) Copy the "aerosense_data" folder that contains the raw measurement data and the labbook "Labbook_Aerosense_Dynamic_Experiments.csv" into the folder "process_raw_data".\
3.) Then, use "main_postprocess.m" to convert the raw data in pressure coefficient data.

The raw data was converted into aerodynamic pressure coefficient data with Matlab R2021b.







