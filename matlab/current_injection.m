% This Matlab script generates current step input for the FS model (two neurons) and writes two files 
dt     =    1.0e-4;     % sec
Tinj   =    5.00;       % Stimulus length (sec).
Tdel   =    0.05;       % Time before stimulus (delay, sec).
Tend   =    0.50;       % Time after stimulus (sec).

Iinj =  57.0 * 1.0e-12; q = 0.2 * 74.0 * 1.0e-12; % th_m = -22mV, gd = 16.0

% Create current step.
for n = 0:1
	I =     q*normrnd(0, 1, [round(Tdel/dt)  1]);
	I = [I; q*normrnd(0, 1, [round(Tinj/dt)  1]) + Iinj];
	I = [I; q*normrnd(0, 1, [round(Tend/dt)  1])];
   
	fname = sprintf('../input/fsn%d_istim.dat', n);
	fprintf('File output: %s\n', fname);
	save(fname, 'I', '-ascii');
end
