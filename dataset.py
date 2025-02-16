'''
    Functions required to load data for training and testing the neural network
    author: @phfranz
'''

import numpy as np

def handle_case(case):
    match case:
        case 1:

            test_column = 0
            training_column = [1,2]

            return test_column, training_column

        case 2:

            test_column = 1
            training_column = [0,2]

            return test_column, training_column
            
        case 3:

            test_column = 2
            training_column = [0,1]

            return test_column, training_column

        case _:
            return "Choose a split between from 1, 2 or 3."


def load_data(experiments, filepath:str, AoA: int, skiprows: int, num_samples: int):
    '''Function to load training and test data'''
    
    # columns in .csv files that correspond to working sensors. 
    working_sensors = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38]

    list_experiments = []
    labels = np.zeros([len(experiments)*num_samples])
    
    for counter, exp in enumerate(experiments):

        # get correct file name (AoA required for this)
        if exp < 10:
            filename = '/aoa_'+str(AoA)+'deg_Exp_00'+str(exp)+'_cp_aerosense_test.csv'

        elif exp > 9 and exp < 100:
            filename = '/aoa_'+str(AoA)+'deg_Exp_0'+str(exp)+'_cp_aerosense_test.csv'

        else: 
            filename = '/aoa_'+str(AoA)+'deg_Exp_'+str(exp)+'_cp_aerosense_test.csv'
            
        # each column in use cols corresponds to a functioning sensor in the .csv-files
        list_experiments.append(np.loadtxt(filepath+filename, delimiter=' ', skiprows=skiprows+1, 
            usecols=working_sensors))
        
        # get correct label for regarded data
        if exp < 20:                    # healthy samples
            label = 0.0

        elif exp > 19 and exp < 39:     # added mass
            label = 1.0

        elif exp > 38 and exp < 58:     # 5 mm crack
            label = 2.0

        elif exp > 57  and exp < 77:    # 10 mm crack
            label = 3.0

        elif exp > 76  and exp < 96:    # 15 mm crack
            label = 4.0
            
        else: 
            label = 5.0                 # 20 mm crack

        labels[counter*num_samples:(counter+1)*num_samples] = label

        
    return list_experiments, labels


def extract_windows(list_experiments, num_samples: int, num_channels: int, window_size: int, skiprows_end: int):
    '''Extract multivariate signal windows from time series data'''

    # shape: [i,j,k] i ~ number of windows, j ~ number of channels (considered sensors), k ~ length of window

    data = np.zeros([num_samples*len(list_experiments), num_channels, window_size])
    
    for i, exp in enumerate(list_experiments):

        # create starting points 

        rows = exp.shape[0]

        starting_points = np.rint(np.linspace(0,rows-window_size-skiprows_end,num_samples)).astype(int) #-1 added to match pandas.csv_read

        for j, point in enumerate(starting_points):

            # extract windows from experimental data
            data[(i*num_samples)+j, :, :] = np.transpose(list_experiments[i][point:point+window_size,:])

    return data
            