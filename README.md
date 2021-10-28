# RFC Parsing with NLP

This repository contains code, models, and results for our paper, which is currently in review.

The repository has been thoroughly anonymized for the double-blind review process.

## Reproduce Our Results

You can either use our pre-trained NeuralCRF models, or train your own.  (More on this later.)  If you intend to use ours, you'll need to get them using git-LFS, like so:

```
git lfs pull
```

For easy reproducibility, we created a Dockerfile.  You can use it as follows.

First, install dependencies to allow Docker access to CUDA on your GPU(s).  For details on how to do this, refer [here](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker).  In our case, we ran:

```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update

sudo apt-get install -y nvidia-docker2

sudo systemctl restart docker
```

And tested successful installation of these dependencies via:

```
sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```

... which outputs a nice ASCII summary of available NVIDIA GPUs for CUDA.  Importantly, this should be *the exact same table* you get by simply running `nvidia-smi` on your host machine!  In our case, this table looked like:

```
Thu Oct 28 12:21:49 2021       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 460.32.03    Driver Version: 460.32.03    CUDA Version: 11.2     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  TITAN X (Pascal)    Off  | 00000000:83:00.0 Off |                  N/A |
| 17%   25C    P0    51W / 250W |      0MiB / 12196MiB |      3%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

Next, build the Docker image.

```
sudo docker build -t rfcnlp .
```

You may see some warnings about dependencies, but the image should build.

```
sudo docker run --gpus all -it rfcnlp bash
```

You will now be able to run any of the targets in the Makefile, from a prompt giving you full access to bash inside the docker image.


### NLP Results

The NLP pipeline uses machine learning and is consequentially non-deterministic.  Hence, running the NLP targets in the Makefile can produce results that differ slightly from those reported in the paper.  We encourage you to try this and see what you get, but keep in mind that the results will depend on your CPU, GPU, and drivers.

* `make dccplineartrain` - runs our LinearCRF+R model on the DCCP RFC and saves the resulting intermediary representation.
* `make tcplineartrain` - runs our LinearCRF+R model on the TCP RFC and saves the resulting intermediary representation.
* `make dccpberttrain` - runs our NeuralCRF+R model on the DCCP RFC and saves the resulting intermediary representation.
* `make tcpberttrain` - runs our NeuralCRF+R model on the TCP RFC and saves the resulting intermediary representation.

### FSM Extraction & Attacker Synthesis Results 

We do FSM Extraction and Attacker Synthesis all at once.  The relevant targets are defined below.  Synthesized attacks are saved to the `out` directory in the Docker image, and are also listed in the CLI output.  

* `make tcp2promela` - runs FSM Extraction and Attacker Synthesis on the GOLD TCP intermediary representation.
* `make dccp2promela` - runs FSM Extraction and Attacker Synthesis on the GOLD DCCP intermediary representation.

The targets for FSM Extraction and Attacker Synthesis against the NLP-derived intermediary representations are given below.

* `make tcplinear2promela` - runs FSM Extraction and Attacker Synthesis on the TCP LinearCRF+R intermediary representation.
* `make dccplinear2promela` - runs FSM Extraction and Attacker Synthesis on the DCCP LinearCRF+R intermediary representation.
* `make tcpbert2promela` - runs FSM Extraction and Attacker Synthesis on the TCP NeuralCRF+R intermediary representation.
* `make dccpbert2promela` - runs FSM Extraction and Attacker Synthesis on the DCCP NeuralCRF+R intermediary representation.

The machine learning step introduces some non-determinism, so your results might differ from those reported in our paper.  But, you can reproduce our results using our saved intermediary representations, using the targets given below.

* `make tcplinearpretrained2promela` - runs FSM Extraction and Attacker Synthesis on the specific TCP LinearCRF+R intermediary representation generated on our machine and used in our paper.
* `make dccplinearpretrained2promela` - runs FSM Extraction and Attacker Synthesis on the specific DCCP LinearCRF+R intermediary representation generated on our machine and used in our paper.
* `make tcpbertpretrained2promela` - runs FSM Extraction and Attacker Synthesis on the specific TCP NeuralCRF+R intermediary representation generated on our machine and used in our paper.
* `make dccpbertpretrained2promela` - runs FSM Extraction and Attacker Synthesis on the specific DCCP NeuralCRF+R intermediary representation generated on our machine and used in our paper.

### Troubleshooting

The FSM Extraction & Attacker Synthesis targets will not work correctly if files from a prior run are left in the working directory.  The solution to this is to use our `make clean` target to clean up the working directory in-between running FSM Extraction & Attacker Synthesis targets.  Since `make clean` deletes the synthesized attacks from `out`, you might want to save those attacks somewhere else.  Here is an example workflow:

```
# TCP GOLD
make tcp2promela
mv out tcp2promela.out
make clean

# DCCP GOLD
make dccp2promela
mv out dccp2promela.out
make clean

# TCP LinearCRF
make tcplinear2promela
mv out tcplinear2promela.out
make clean

# DCCP LinearCRF
make dccplinear2promela
mv out dccplinear2promela.out
make clean

# TCP NeuralCRF
make tcpbert2promela
mv out tcpbert2promela.out
make clean

# DCCP NeuralCRF
make dccpbert2promela
mv out dccpbert2promela.out
make clean
```

By the way, to exit the Docker image, you simply enter `exit`.

```
root@6abd73c26503:/rfcnlp# exit
exit
```

Then you could copy the results out of the Docker image and into your host computer for inspection.  Notice the use of `flamboyant_tu`; you'll have to replace this with your image's name.

```
docker cp flamboyant_tu:rfcnlp/tcp2promela.out/ tcp2promela.out/
docker cp flamboyant_tu:rfcnlp/dccp2promela.out/ dccp2promela.out/
docker cp flamboyant_tu:rfcnlp/tcplinear2promela.out/ tcplinear2promela.out/
docker cp flamboyant_tu:rfcnlp/dccplinear2promela.out/ dccplinear2promela.out/
docker cp flamboyant_tu:rfcnlp/dccpbert2promela.out/ dccpbert2promela.out/
```

There is a strange issue where when you do this, you don't have non-`sudo` permission to change or delete the copied files.  But you do have `sudo` permission, e.g., you can do `sudo rm -rf dccpbert2promela.out` if you'd like.

## Command-Line Interface

After interacting with the pre-defined [Makefile](Makefile) targets in the [Dockerfile](Dockerfile), you might want to start interacting directly with our software.  In this section, we explain the specific software provided, and how to interact with it.

### `nlp2promela/nlp2promela.py`

This script takes only one argument, namely the path to the intermediate representation of an RFC document.  It performs FSM Extraction on the provided intermediate representation.  Without loss of generality, if the path to the intermediate representation was `/dir1/dir2/dir3/protocol3.xml`, then it saves the extracted FSM as an image in `protocol3.png`, and as a Promela program in `protocol3.pml`.  

In the special case where the FSM name (in the example, `protocol3`) contains the sub-string "TCP" or "DCP", respectively, it compares the graph representation of the extracted FSM to a canonical graph representation of TCP (or DCP, resp.), stored in [testConstants.py](nlp2promela/testConstants.py), and outputs a detailed summary of the differences.  Then, it performs Attacker Synthesis on the extracted FSM, using the TCP (or DCP, resp.) correctness properties stored in `promela-models/TCP/props`, and saves any synthesized attackers to `out/`.

Example usage:

```
python3 nlp2promela/nlp2promela.py rfcs-predicted/bert_pretrained_rfcs_crf_phrases_feats/DCCP.xml
```

### `nlp-parser/linear.py`

TODO

### `nlp-parser/bert_bilstm_crf.py`

TODO

## Disclaimers

Considerable effort was taken to anonymize and automate our code-base for open-source release.  If you encounter something that does not work as expected, please feel free to open a Github Issue reporting the problem, and we will do our best to (anonymously) resolve it.
