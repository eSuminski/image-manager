# Image Manager
My repo for storing work on iso environments

## Pi model management
The base image configuration includes a `model.json` configured for my personal use: if you want to use your own configuration mount your own `model.json` config using: 
`-v $(pwd)/models.json:/home/devuser/.pi/agent/models.json`