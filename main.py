import tensorflow as tf
import horovod.tensorflow.keras as hvd
import argparse
import numpy as np
import time

parser = argparse.ArgumentParser()
parser.add_argument("--use_amp", action="store_true")
args = parser.parse_args()

# Startup Horovod
hvd.init()

gpus = tf.config.experimental.list_physical_devices('GPU')
if gpus:
    tf.config.experimental.set_visible_devices(gpus[hvd.local_rank()], 'GPU')

# Enable AMP
if args.use_amp:
    policy = tf.keras.mixed_precision.experimental.Policy('mixed_float16')
    tf.keras.mixed_precision.experimental.set_policy(policy)

# Create dummy model
model = tf.keras.models.Sequential()
model.add(tf.keras.layers.Dense(1, use_bias=False))

# Enable AMP (this position works)
if args.use_amp:
    policy = tf.keras.mixed_precision.experimental.Policy('mixed_float16')
    tf.keras.mixed_precision.experimental.set_policy(policy)

# Create optimizer
opt = tf.keras.optimizers.SGD(learning_rate=1e-6)
opt = hvd.DistributedOptimizer(opt)

#if True:
if False:
    def my_loss_fn(y_true, y_pred):
        squared_difference = tf.square(y_true - y_pred)
        return tf.reduce_mean(squared_difference, axis=-1)

    model.compile(optimizer=opt, loss=my_loss_fn)
else:
    model.compile(optimizer=opt, loss='mae')

# On rank 0, set input to NaN to generate NaN gradient
if hvd.rank() == 0:
    x = np.ones(1, dtype=np.float32)
    x[:] = np.nan
else:
    x = np.ones(1, dtype=np.float32)

model.fit(x=x, y=np.ones(1), verbose=2)
print("rank {} completed step...".format(hvd.rank()))
# Sleep to keep ranks from killing job prematurely
time.sleep(10)

