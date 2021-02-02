# HVD_TF_Worker_Desync_BugReport

## To reproduce:

#### 1. Open the Dockerfile and decide if you want to test LATEST or STABLE Horovod

https://github.com/DEKHTIARJonathan/HVD_TF_Worker_Desync_BugReport/blob/master/Dockerfile#L49-L55

#### 2. Build and Start the container: `./build_and_start_container.sh`

#### 3. Execute the script to see the problem: `./exec.sh`


## Results:

```sh
1/1 - 3s - loss: nan
rank 0 completed step...


[2021-02-02 21:19:07.345988: W /tmp/pip-install-dxtho7yu/horovod_0bde588442554cf4b80c76441efc4e03/horovod/common/stall_inspector.cc:105] One or more tensors were submitted to be reduced, gathered or broadcasted by subset of ranks and are waiting for remainder of ranks for more than 10 seconds. This may indicate that different ranks are trying to submit different tensors or that only subset of ranks is submitting tensors, which will cause deadlock. 
Missing ranks:
0: [cond_1/then/_10/cond_1/SGD/PartitionedCall/DistributedSGD_Allreduce/cond/then/_79/DistributedSGD_Allreduce/cond/HorovodAllreduce_grads_0]


[2021-02-02 21:19:17.346253: W /tmp/pip-install-dxtho7yu/horovod_0bde588442554cf4b80c76441efc4e03/horovod/common/stall_inspector.cc:105] One or more tensors were submitted to be reduced, gathered or broadcasted by subset of ranks and are waiting for remainder of ranks for more than 10 seconds. This may indicate that different ranks are trying to submit different tensors or that only subset of ranks is submitting tensors, which will cause deadlock. 
Missing ranks:
0: [cond_1/then/_10/cond_1/SGD/PartitionedCall/DistributedSGD_Allreduce/cond/then/_79/DistributedSGD_Allreduce/cond/HorovodAllreduce_grads_0]


Traceback (most recent call last):
  File "main.py", line 45, in <module>
    model.fit(x=x, y=np.ones(1), verbose=2)
  File "/usr/local/lib/python3.6/dist-packages/tensorflow/python/keras/engine/training.py", line 1134, in fit
    tmp_logs = self.train_function(iterator)
  File "/usr/local/lib/python3.6/dist-packages/tensorflow/python/eager/def_function.py", line 818, in __call__
    result = self._call(*args, **kwds)
  File "/usr/local/lib/python3.6/dist-packages/tensorflow/python/eager/def_function.py", line 879, in _call
    return self._stateless_fn(*args, **kwds)
  File "/usr/local/lib/python3.6/dist-packages/tensorflow/python/eager/function.py", line 2994, in __call__
    filtered_flat_args, captured_inputs=graph_function.captured_inputs)  # pylint: disable=protected-access
  File "/usr/local/lib/python3.6/dist-packages/tensorflow/python/eager/function.py", line 1939, in _call_flat
    ctx, args, cancellation_manager=cancellation_manager))
  File "/usr/local/lib/python3.6/dist-packages/tensorflow/python/eager/function.py", line 569, in call
    ctx=ctx)
  File "/usr/local/lib/python3.6/dist-packages/tensorflow/python/eager/execute.py", line 60, in quick_execute
    inputs, attrs, num_outputs)
tensorflow.python.framework.errors_impl.UnknownError:  Horovod has been shut down. This was caused by an exception on one of the ranks or an attempt to allreduce, allgather or broadcast a tensor after one of the ranks finished execution. If the shutdown was caused by an exception, you should see the exception in the log before the first shutdown message.
	 [[{{node cond_1/then/_10/cond_1/SGD/PartitionedCall/DistributedSGD_Allreduce/cond/then/_79/DistributedSGD_Allreduce/cond/HorovodAllreduce_grads_0}}]] [Op:__inference_train_function_628]

Function call stack:
train_function

--------------------------------------------------------------------------
Primary job  terminated normally, but 1 process returned
a non-zero exit code. Per user-direction, the job has been aborted.
--------------------------------------------------------------------------
--------------------------------------------------------------------------
mpirun detected that one or more processes exited with non-zero status, thus causing
the job to be terminated. The first process to do so was:

  Process name: [[56671,1],1]
  Exit code:    1
--------------------------------------------------------------------------

```
