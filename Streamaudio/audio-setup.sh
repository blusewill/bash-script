#!/bin/bash

# Setup Virtual Audio for Streaming
pw-loopback -m '[ FL FR]' --capture-props='media.class=Audio/Sink node.name=spotify' -n 'Music-Audio'
