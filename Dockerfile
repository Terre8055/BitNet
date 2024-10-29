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

COPY . .

RUN ls -al 

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

RUN apt-get update && apt-get install -y \
    cmake \
    clang \
    llvm \

# Copy the entrypoint script into the container
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh


# Copy the current directory contents into the container at /app
COPY . .

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]