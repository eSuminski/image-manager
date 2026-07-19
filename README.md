# Image Manager
My repo for storing work on iso environments and Agent deployments

## Pi model management
The base image configuration includes a `model.json` configured for my personal use: if you want to use your own configuration mount your own `model.json` config using: 
`-v $(pwd)/models.json:/home/devuser/.pi/agent/models.json`

## Hermes config
I made the custom hermes image because I wanted to have a minimal starting footprint I can add on to as I need. I also want to keep my Hermes agent isolated from my host machine as reasonably as I can, so I set up a deployment compose file to set it up (run in WSL). 