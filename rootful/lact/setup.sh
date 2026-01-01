#!/bin/bash

# Enable AMD GPU overclocking functionality (reboot required)
grubby --update-kernel=ALL --args="amdgpu.ppfeaturemask=0xffffffff"
