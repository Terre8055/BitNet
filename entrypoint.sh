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


# Wait for the service to be ready
echo "Waiting for the service to be ready..."
until curl -s http://localhost:8000/health; do
    echo "Service not ready, waiting..."
    sleep 5  # Wait for 5 seconds before checking again
done

# Execute the main script
exec python main.py