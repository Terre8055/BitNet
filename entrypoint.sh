#!/bin/bash

# Run any setup commands here
echo "Running setup before main.py"

# Initialize conda for the shell
eval "$(/opt/conda/bin/conda shell.bash hook)"

# Activate the conda environment
conda init && conda activate bitnet-cpp

# Execute the main script
exec python main.py