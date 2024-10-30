#!/bin/bash

# Run any setup commands here
echo "Running setup before main.py"

# Initialize conda for the shell
eval "$(/opt/conda/bin/conda shell.bash hook)"

# Activate the conda environment
conda init && conda activate bitnet-cpp

# Run the setup environment commands
python setup_env.py -md models/Llama3-8B-1.58-100B-tokens -q i2_s

python setup_env.py -md models/bitnet_b1_58-large -q i2_s

python setup_env.py -md models/bitnet_b1_58-3B -q i2_s


# Execute the main script
exec python main.py