# Semi-Automatic Li-Ion battery RC model parameters estimator

Developed by ***Federico Ceccarelli***, in collaboration with Matin Moya and Lucio Santos, for a Li-Ion batterys BMS.

Universidad Nacional de Rosario

Any kind of Submission are welcome to fededc88@gmail.com

The code implement a numerical optimization algorithm using Simulink Parameter Estimation, part
of the System Identification Toolbox, to estimate R y C parameter values of a second order Li-Ion 
battery model ( a series resistance R0, plus two parallel R-C branches connected in series)
minimizing error between measured and simulated results.

###Code is based on 2 pappers and one mathworks example: 

**Battery Model Parameter Estimation Using a Layered Technique: An Example Using a Lithium Iron Phosphate Cell**
*Robyn Jackey, Michael Saginaw, Pravesh Sanghvi, and Javier Gazzarri*
MathWorks
*Tarun Huria and Massimo Ceraolo*
Università di Pisa

**Parameterization of a Battery Simulation Model Using Numerical Optimization Methods**
*Robyn A. Jackey*
The MathWorks, Inc.
*Gregory L. Plett*
University of Colorado at Colorado Springs
*Martin J. Klein*
Compact Power Inc.

**Estimate Model Parameter Values (Code)** - https://www.mathworks.com/help/sldo/ug/estimate-model-parameter-values-code.html#d122e5060


For this example was used the five pulses discharge HPPC test (0.5, 1, 2, 4, 6C) performed at 100, 95,
90, 80, 70..., 30, 25, 20, 15, 10, 5, 0 % SOC.
Data was taken from the battery test performed at the University of Wisconsin-Madison by *Dr. Phillip Kollmeyer* (phillip.kollmeyer@gmail.com). 
