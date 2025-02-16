'''Define architecture of CNN

   author: @phfranz
'''

from tensorflow import keras

def create_conv_net(input_shape, num_classes):
    '''set architecture of CNN
    input_shape: first dimension = length of sample
                 second dimension = number of channels '''

    return keras.Sequential(
      [ 
         keras.layers.Input(input_shape),
         keras.layers.Conv1D(filters=128, kernel_size=8, padding="same", activation=None,  data_format="channels_last"),
         keras.layers.BatchNormalization(),
         keras.layers.ReLU(),

         keras.layers.Conv1D(filters=256, kernel_size=5, padding="same", activation=None, data_format="channels_last"),
         keras.layers.BatchNormalization(),
         keras.layers.ReLU(),

         keras.layers.Conv1D(filters=128, kernel_size=3, padding="same", activation=None, data_format="channels_last"),
         keras.layers.BatchNormalization(),
         keras.layers.ReLU(),

         keras.layers.GlobalAveragePooling1D(),
         keras.layers.Dense(num_classes, use_bias=True ,activation="softmax")]
      )

    