'''
    Evaluate the previously-trained neural network
    author: @phfranz
'''

import numpy as np
import dataset
import cnn

import tensorflow as tf
from tensorflow import keras
from tensorflow import random

from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import accuracy_score
from sklearn.metrics import confusion_matrix
from sklearn.metrics import classification_report

import matplotlib.pyplot as plt
import seaborn as sns

if __name__ == "__main__":

    # ---------------------------------------------------------------------
    # User defined parameters
    # ---------------------------------------------------------------------

    AoA = 8           # Angle of attack

    path_cp = 'path/to/data' # path to datasets

    split = 3   # set split to 1, 2 or 3 # splits, see Paper


    # ---------------------------------------------------------------------

    num_channels = 37       # sensors with uncorrupted signals
    skiprows = 4000         # how many measurement points to neglect before using the data 4000 ~ 40s
    num_samples = 89        # number of signal windows to extract from one time series
    window_size = 150       # length of a signal window in measurement points
    skiprows_end = 1000     # how many measurement points to neglect at the end of each measurement

    test_column, training_column = dataset.handle_case(case=split)

    model_name = "model_AoA_" + str(AoA) + "_split_" + str(split)

    experiments_matrix = np.matrix('3 4 5; 7 8 9; 12 13 14; 16 17 18; 22 23 24; 26 27 28; 31 32 33; 35 36 37; 41 42 43; 45 46 47; 50 51 52; 54 55 56; 60 61 62; 64 65 66; 69 70 71; 73 74 75; 79 80 81; 83 84 85; 88 89 90; 92 93 94; 98 99 100; 102 103 104; 107 108 109; 111 112 113')

    test_exp = experiments_matrix[:,test_column].A1

    # load experimental data in lists

    test_list, test_labels = dataset.load_data(test_exp, path_cp, AoA, skiprows, num_samples)

    # load test windows

    test_data = dataset.extract_windows(test_list, num_samples, num_channels, window_size, skiprows_end)


    # ---------------------------------------------------------------------
    # normalize training and test data: subtract mean over all channels from sample and divide by standard deviation over all channels (standard scaling)

    test_data_normalized = np.zeros(test_data.shape)  

    for j in range(test_data.shape[0]):
        
        sample_mean_test = test_data[j,:,:].mean()
        sample_std_test = test_data[j,:,:].std()

        test_data_normalized[j,:,:] = (test_data[j,:,:] - sample_mean_test)/sample_std_test

    test_set = test_data_normalized.transpose(0,2,1)

    # load previously trained model

    model = keras.models.load_model("best_" + model_name + ".tf")
    y_proba =model.predict(test_set)
    y_classes = y_proba.argmax(axis=1)


    # ---------------------------------------------------------------------
    # Compute and print evaluation metrics

    cmatrix = confusion_matrix(test_labels, y_classes)
    print('------------------------------------')
    print('Accuracy score: ',accuracy_score(test_labels, y_classes))
    print('------------------------------------')
    print(cmatrix)
    print('------------------------------------')
    print(classification_report(test_labels, y_classes))
    print('------------------------------------')

    fig = plt.figure()
    sns.heatmap(np.round(cmatrix/356,3), annot=True, cmap='Blues', annot_kws={'size':12}, cbar_kws={'label': 'Relative frequency $[-]$'}, vmin=0, vmax=1.0)
    plt.xlabel('Predicted class')
    plt.ylabel('True class')
    plt.savefig('cmatrix_' + model_name + '.pdf', bbox_inches="tight" )

