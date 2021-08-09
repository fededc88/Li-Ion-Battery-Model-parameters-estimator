# Semi-Automatic Li-Ion battery RC model parameters estimator

Developed by ***Federico Ceccarelli***, in collaboration with 
[Martin Moya](https://github.com/moyamartin) and Lucio Santos, for a Li-Ion 
BMS.

Universidad Nacional de Rosario

Any kind of Submission are welcome to fededc88@gmail.com

The code implements a numerical optimization algorithm using Simulink Parameter 
Estimation, as part of the System Identification Toolbox, to estimate R y C 
parameter values of a second order Li-Ion  battery model 
(a series resistance R0 connected in series with two parallel R-C branches)
minimizing error between measured and simulated results.

For this example it was used a five pulses discharge HPPC test (0.5, 1, 2, 4, 
6C) performed at 100, 95, 90, 80, 70..., 30, 25, 20, 15, 10, 5, 0 SOC.
The data set was taken from the battery test performed at the University of 
Wisconsin-Madison by *Dr. Phillip Kollmeyer* [[1]]

## Bibliography

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

<a id="1">[1]</a> 
Dr. Phillip Kollmeyer (2018). 
Panasonic 18650PF Li-ion Battery Data

For this example was used the five pulses discharge HPPC test (0.5, 1, 2, 4, 6C) performed at 100, 95,
90, 80, 70..., 30, 25, 20, 15, 10, 5, 0 % SOC.
Data was taken from the battery test performed at the University of Wisconsin-Madison by *Dr. Phillip Kollmeyer* (phillip.kollmeyer@gmail.com).

## Referencing

Do you find this project interesting or useful for your work? Please let us know 
(@moyamartin, @fededc88, @lusho2206) and cite this work using:

```
@article {
    Author = {Ceccarelli, Federico; Moya, Martin; Santos Lucio}
    Title = {Semi-Automatic Li-Ion battery RC model parameters estimator}
    Year = {2021}
    Institute = {Faculty of Exact Sciences, Engineering and Land Surveing -
    National University of Rosario}
}
