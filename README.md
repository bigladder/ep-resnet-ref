# Standard 140 Section 7 BESTEST Cases for EnergyPlus

Modified from GARD tests in EnergyPlus V.8.2

## Requirements

- [Ruby 2.0.0-p645](https://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.0.0-p645.exe) (must add binaries to PATH): To run rake.
- [Params Catalyst](http://downloads.bigladdersoftware.com/?ref=params-catalyst-latest-win) (only command line tools): To generate input files from templates
- [Python 3.X (Anaconda distribution suggested)](https://www.anaconda.com/distribution/) (must add python to PATH): To process results and create report
    - `pip install mako`

## Running tests

Type `rake` from the top level directory.
