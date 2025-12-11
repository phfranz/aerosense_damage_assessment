'''
    Training routine of neural network
    Training of the neural network inspired by the code of Hassan Ismail Fawaz (https://github.com/hfawaz/dl-4-tsc/tree/master) for the paper: 
    Ismail Fawaz, H., Forestier, G., Weber, J., Idoumghar, L., Muller, P.-A. "Deep learning for time series classification: a review." Data Min Knowl Disc 33, 917–963 (2019). https://doi.org/10.1007/s10618-019-00619-1
    
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

if __name__ == "__main__":

    # ---------------------------------------------------------------------
    # User defined parameters
    # ---------------------------------------------------------------------

    AoA = 8           # Angle of attack

    path_cp = 'path/to/data' # path to datasets

    split = 2   # set split to 1, 2 or 3 # splits, see Paper

    # ---------------------------------------------------------------------

    num_channels = 37       # sensors with uncorrupted signals of Aerosense sensing node used in experiments
    skiprows = 4000         # how many measurement points to neglect before using the data 4000 ~ 40s
    num_samples = 89        # number of signal windows to extract from one time series
    window_size = 150       # length of a signal window in measurement points
    skiprows_end = 1000     # how many measurement points to neglect at the end of each measurement

    
    test_column, training_column = dataset.handle_case(case=split)


    model_name = "model_AoA_" + str(AoA) + "_split" + str(split)

    experiments_matrix = np.matrix('3 4 5; 7 8 9; 12 13 14; 16 17 18; 22 23 24; 26 27 28; 31 32 33; 35 36 37; 41 42 43; 45 46 47; 50 51 52; 54 55 56; 60 61 62; 64 65 66; 69 70 71; 73 74 75; 79 80 81; 83 84 85; 88 89 90; 92 93 94; 98 99 100; 102 103 104; 107 108 109; 111 112 113')


    test_exp = experiments_matrix[:,test_column].A1
    train_exp = np.sort(np.hstack([experiments_matrix[:,training_column[0]].A1,experiments_matrix[:,training_column[1]].A1])) 

    # load experimental data in lists

    training_list, training_labels = dataset.load_data(train_exp, path_cp, AoA, skiprows, num_samples)
    test_list, test_labels = dataset.load_data(test_exp, path_cp, AoA, skiprows, num_samples)


    # load training and test windows

    training_data = dataset.extract_windows(training_list, num_samples, num_channels, window_size, skiprows_end)
    test_data = dataset.extract_windows(test_list, num_samples, num_channels, window_size, skiprows_end)

    # normalize training and test data: subtract mean over all channels from sample and divide by standard deviation over all channels (standard scaling)

    training_data_normalized = np.zeros(training_data.shape)
    test_data_normalized = np.zeros(test_data.shape)

    for j in range(training_data.shape[0]):

        sample_mean = training_data[j,:,:].mean()
        sample_std = training_data[j,:,:].std()

        training_data_normalized[j,:,:] = (training_data[j,:,:] - sample_mean)/sample_std
        

    for j in range(test_data.shape[0]):
        
        sample_mean_test = test_data[j,:,:].mean()
        sample_std_test = test_data[j,:,:].std()

        test_data_normalized[j,:,:] = (test_data[j,:,:] - sample_mean_test)/sample_std_test

    # ---------------------------------------------------------------------
    # split training data set into training and validation set using stratifiedKFold

    skf = StratifiedKFold(n_splits=4, random_state=1, shuffle=True)

    split_1, split_2, split_3, split_4 = skf.split(training_data_normalized[:,14,:], training_labels)

    training_set = training_data_normalized[split_1[0],:,:]
    training_set_labels = training_labels[split_1[0]]

    validation_set = training_data_normalized[split_1[1],:,:]
    validation_set_labels = training_labels[split_1[1]]

    # reshape training and test set 

    training_set = training_set.transpose(0,2,1)
    validation_set = validation_set.transpose(0,2,1)
    test_set = test_data_normalized.transpose(0,2,1)

    print("Num GPUs Available: ", len(tf.config.list_physical_devices('GPU')))


    # set random seeds for reproducible results
    np.random.seed(1) 
    random.set_seed(1)
    tf.keras.utils.set_random_seed(1)
    tf.config.experimental.enable_op_determinism()


    # ---------------------------------------------------------------------
    # Set up convolutional neural network

    model = cnn.create_conv_net(input_shape=[window_size, num_channels], num_classes=6)
    model.summary()

    # define callbacks for improved training
    callbacks = [
    keras.callbacks.ModelCheckpoint(
            "best_" + model_name + ".tf", save_best_only=True, monitor="val_loss"
        ),
        keras.callbacks.ReduceLROnPlateau(
            monitor="val_loss", factor=0.5, patience=15, min_lr=0.0001
        )]

    # set optimizer and loss function
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=0.05),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"]
    )

    # fit model to training data
    model.fit(
        training_set,
        training_set_labels,
        batch_size=10,
        epochs=150,
        callbacks=callbacks,
        validation_data = (validation_set, validation_set_labels),
        verbose=1
        )


    # ---------------------------------------------------------------------
    # Evaluate best model on test set

    model = keras.models.load_model("best_" + model_name + ".tf")
    y_proba =model.predict(test_set)
    y_classes = y_proba.argmax(axis=1)

    # Compute and print evaluation metrics

    cmatrix = confusion_matrix(test_labels, y_classes)
    print('------------------------------------')
    print('Accuracy score: ',accuracy_score(test_labels, y_classes))
    print('------------------------------------')
    print(cmatrix)
    print('------------------------------------')
    print(classification_report(test_labels, y_classes))
    print('------------------------------------')
