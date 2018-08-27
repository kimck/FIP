# FIP
Basic scripts for visualizing processed FIP data, acquired using the FIP gui: https://github.com/deisseroth-lab/multifiber

See paper in Nature Methods for details:

Kim, C., Yang, S., Pichamoorthy, N., Young, N., Kauvar, I., Jennings, J., Lerner, T., Berndt, A., Lee, S.Y., Ramakrishnan, C., Davidson, T., Inoue, M., Bito, H., & Deisseroth, K. (2016). Simultaneous fast measurement of circuit dynamics at multiple sites across the mammalian brain. Nature Methods.

# Background
Frame-projected independent-fiber photometry records the sum fluorescence from each of several optical fibers by imaging the fiber bundle onto a camera sensor and digitally cropping and summing the fluorescence from each fiber. Alternating excitation wavelengths for successive frames enables concurrent sampling of multiple spectral channels and/or optical stimulation.

# Output
To process the traces output by the FIP gui, we perform the following:
1) Optional: subtract bleaching from both the 405 nm (reference) and 470 nm (signal) channels using an exponential fit.
2) Scale the reference channel to fit the signal channel using a linear least-squares regression, and subtract the scaled reference channel. Note that if the reference channel is very noisy, you may wish to additionaly smooth/filter the scaled reference channel prior to subtraction.
3) Optional: perform a low-pass filter or sliding-window smoothing of reference-subtracted signal.
4) Caculate the normalized fluorescence signal, using either deltaF/F [( F(t) - median(F) ) / median(F)] or zscore.

To calculate the stimulus-triggered responses, you must check "enable AI logging" on the FIP gui.

# Software requirements
MATLAB (tested with R2017a)
MATLAB statistic toolbox
MATLAB curve fitting toolbox
