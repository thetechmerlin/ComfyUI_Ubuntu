#!/bin/bash

# Welcome message
echo "Welcome to TechMerlin's Comfy UI installer! ^_^"
sleep 2

# Brief overview of steps
echo "This installer will:"
echo "1. Check for the required Python version (3.12)."
echo "2. Install Python 3.12 if it's not already installed."
echo "3. Set up a virtual environment."
echo "4. Install PyTorch based on your GPU type (Nvidia or AMD)."
echo "5. Install additional requirements."
echo "6. Launch the Comfy UI application."
sleep 2

# Check for Python version
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
REQUIRED_VERSION="3.12"

if [[ "$PYTHON_VERSION" != "$REQUIRED_VERSION"* ]]; then
    echo "Sorry, ComfyUI works only with Python 3.12. Would you like me to install it? (Y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Installing Python 3.12..."
        sudo apt update
        sudo apt install -y software-properties-common
        sudo add-apt-repository ppa:deadsnakes/ppa
        sudo apt update
        sudo apt install -y python3.12 python3.12-venv python3.12-dev
        curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3.12
        echo "The proper version of Python is now installed! Press any key to continue."
        read -n 1 -s
    else
        echo "Maybe next time then!"
        read -n 1 -s -r -p "Press any key to exit."
        exit 1
    fi
else
    echo "Python 3.12 is already installed."
fi

# Ask about GPU type
echo "Do you have an Nvidia or AMD GPU? (Nvidia/AMD)"
read -r gpu_type

# Set up virtual environment
echo "Setting up a virtual environment..."
python3.12 -m venv myenv
source myenv/bin/activate

# Install PyTorch based on GPU type
if [[ "$gpu_type" =~ ^([nN][vV][iI][dD][iI][aA])$ ]]; then
    echo "Installing PyTorch for Nvidia GPU..."
    pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu124
elif [[ "$gpu_type" =~ ^([aA][mM][dD])$ ]]; then
    echo "Installing PyTorch for AMD GPU..."
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.1
else
    echo "Invalid GPU type entered. Exiting installation."
    deactivate
    exit 1
fi

# Install additional requirements
echo "Next, we install requirements..."
pip install -r requirements.txt

echo "Installation Complete! Press any key to run the application."
read -n 1 -s

# Run the application
python main.py
