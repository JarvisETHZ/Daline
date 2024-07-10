![dalinelogo](dalinelogo.png)

# Daline: A Data-driven Power Flow Linearization Toolbox

**Official Website:** https://www.shuo.science/daline

**Version:** 1.1.5

**Authors:** [Mengshuo Jia](https://www.shuo.science), Wen Yi Chan, [Gabriela Hug](https://psl.ee.ethz.ch/people/prof--gabriela-hug.html)

**Affiliation:** Power Systems Lab, ETH Zurich

**Date:** June 27, 2024

**Copyright:** © 2024, Mengshuo Jia and Gabriela Hug

*Copying and distribution of this file, with or without modification, are permitted in any medium without royalty provided the copyright notice and this notice are preserved. This file is offered as-is, without any warranty.*

## Introduction

Daline is a MATLAB toolbox for data-driven power flow linearization in power systems research and education. Unlike traditional model-driven approaches, Daline uses system measurements to train linear models, accommodating realistic impacts like control actions and variable system parameters. It includes over 55 linearization methods and is designed to help users perform complex simulation and comparison tasks using just a few simple commands.

## Getting Started

### System Requirements

- Compatible with 64-bit Linux, macOS, and Windows.
- Suggested but not mandatory: MATLAB version 2020b or later.

### Installation

1. **Download** the Daline115.zip file from the [official website](https://www.shuo.science/daline) or [GitHub](https://github.com/JarvisETHZ/Daline).
2. **Unzip** and move the folder to a desired location.
3. **Set Up**: In MATLAB, set the current folder to the Daline115 directory and run `daline_setup`.

## Running Daline

To execute some basic commands in Daline:

- **Data Generation**:

  ```matlab
  data = daline.data('case.name', 'case14');
  ```

- **Fit Model**:

  ```matlab
  model = daline.fit(data, 'method.name', 'PLS_SIM');
  ```

- **Rank Accuracy**:

  ```matlab
  models = daline.rank(data, {'PLS_SIM', 'RR', 'LS_COD'});
  ```

- **Rank Time**:

  ```matlab
  time = daline.time(data, {'QR', 'PLS_SIMRX', 'LS_COD'});
  ```

- **Complete Workflow**:

  ```matlab
  model = daline.all('case118', 'method.name', 'RR_VCS', 'PLOT.style', 'light');
  ```

For more detailed usage instructions and additional examples, refer to the Daline User Manual in `Daline115/doc/`.

## Terms of Use

- Daline is distributed under the 3-clause BSD license from version 1.1.5 onwards.
- No warranty is provided.
- Refer to the LICENSE file for detailed conditions.

### Citing Daline

Citing Daline in publications is requested by the authors:

```latex
@article{Daline,
  author = {Jia, Mengshuo and Chan, Wen Yi and Hug, Gabriela},
  title = {Daline: A Data-driven Power Flow Linearization Toolbox for Power Systems Research and Education}, 
  journal = {ETH Research Collection},
  year = {2024}, 
  url = {https://doi.org/10.3929/ethz-b-000681867},
  doi = {10.3929/ethz-b-000681867}
}
```