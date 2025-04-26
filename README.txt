========================================================
Daline - A Data-driven Power Flow Linearization Toolbox
========================================================
Version: 1.1.7
Authors: Mengshuo Jia, Wen Yi Chan, Gabriela Hug
Power Systems Lab, ETH Zurich
April 25, 2025
Copyright (c) 2025, Mengshuo Jia and Gabriela Hug
Copying and distribution of this file, with or without modification, are permitted in any medium without royalty provided the copyright notice and this notice are preserved. This file is offered as-is, without any warranty.

————————————
INTRODUCTION
————————————
Daline is a MATLAB(R) toolbox for generalized data-driven power flow linearization in power systems research and education. Unlike traditional model-driven approaches, Daline uses system measurements to train linear models, accommodating realistic impacts like control actions and variable system parameters. It includes over 55 linearization methods and is designed to help users perform complex simulation and comparison tasks using just a few simple commands.

———————————— 
TERMS OF USE
————————————
• Daline is distributed under the 3-clause BSD license from version 1.1.2 onwards.
• No warranty is provided.
• Refer to the LICENSE file for detailed conditions.
• Citing Daline: Citing Daline in publications is requested by the authors:

  @ARTICLE{Daline,
    author={Jia, Mengshuo and Chan, Wen Yi and Hug, Gabriela},
    title={Daline: A Data-driven Power Flow Linearization Toolbox for Power Systems Research and Education},
    url={https://doi.org/10.3929/ethz-b-000681867},
    year={2024}}

———————————————  
GETTING STARTED
———————————————
System Requirements:
• Compatible with 64-bit Linux, macOS, and Windows.
• Suggest but not mandatory: MATLAB version 2020b or later.

Installation:
Step 1. Download the Daline117.zip file from the website or GitHub.
Step 2. Unzip and move the folder to a desired location.
Step 3. In MATLAB, set the current folder to the Daline117 directory and run daline_setup.

—————————————— 
RUNNING DALINE
—————————————— 
To run some simple commands of Daline:
• Data Generation:   data   = daline.data('case.name', 'case14');
• Fit Model:         model  = daline.fit(data, 'method.name', 'PLS_SIM');
• Rank accuracy:     models = daline.rank(data, {'PLS_SIM', 'RR', 'LS_COD'});
• Rank Time:         time   = daline.time(data, {'QR', 'PLS_SIMRX', 'LS_COD'});
• Complete Workflow: model  = daline.all('case118', 'method.name', 'RR_VCS', 'PLOT.style', 'light');

For many other additional commands, refer to the User's Manual in Daline117/doc/ for more detailed usage instructions and additional examples .