# Stage 1: Build environment
FROM python:3.9-slim AS build

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    clang \
    llvm \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/conda \
    && rm miniconda.sh \
    && /opt/conda/bin/conda clean -afy

# Add conda to PATH
ENV PATH="/opt/conda/bin:$PATH"

# (Recommended) Create a new conda environment and install requirements
RUN conda create -n bitnet-cpp python=3.9 -y \
    && /opt/conda/bin/conda run -n bitnet-cpp pip install -r requirements.txt

# Stage 2: Runtime environment
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy conda environment from the build stage
COPY --from=build /opt/conda /opt/conda

# Add conda to PATH
ENV PATH="/opt/conda/bin:$PATH"

RUN conda activate bitnet-cpp \
    && python setup_env.py -md models/Llama3-8B-1.58-100B-tokens -q i2_s \
    && python setup_env.py -md models/bitnet_b1_58-large -q i2_s \
    && python setup_env.py -md models/bitnet_b1_58-3B -q i2_s



# Copy the current directory contents into the container at /app
COPY . .

# Command to run your application
CMD ["python", "main.py"]