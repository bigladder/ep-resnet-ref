# Standard 140 Section 7 BESTEST Cases for EnergyPlus

## Requirements

- [Modelkit Catalyst](https://bigladdersoftware.com/projects/modelkit/) (only command line tools): To generate input files from templates
- [EnergyPlus v26.1 - Bug Fix](https://github.com/NatLabRockies/EnergyPlus/releases/tag/v26.1.0): To simulate EnergyPlus input files created from templates. Should be installed in default directory @ *C:\EnergyPlusV26-1-0*. If installed in a different directory, or on Mac instead of windows, you will need to update the following line in *.modelkit-config*:

      engine = 'C:\EnergyPlusV26-1-0'  # Must be an absolute path

## Running tests

Type `modelkit rake` from the top level directory.
