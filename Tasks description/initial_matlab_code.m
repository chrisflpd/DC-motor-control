% This must be calculated according to lab information
V_7805 = 5.371;
Vref_arduino = 5;

%% Code to clear arduino variable if necessary
% clear
% delete(instrfind({'Port'}, {'COM7'}));
% a = arduino;
% a = arduino('COM7');

%%
% OUTPUT ZERO CONTROL SIGNAL TO STOP MOTOR  %
analogWrite(a, 6, 0);
analogWrite(a, 9, 0);

% Information not needed
% writePWMVoltage(a, 'D6', 0)
% writePWMVoltage(a, 'D9', 0)

% Initialize matrix to fill with information
positionData = [];
velocityData = [];
eData = [];
timeData = [];

%   The input setpoint is in Volts and can vary from 0 to 10 Volts because the position pot is refered to GND
% Set the desired position
y_r = 2;

% Set initial time to zero
t=0;

% CLOSE ALL PREVIOUS FIGURES FROM SCREEN
close all

% WAIT A KEY TO PROCEED
disp(['Connect cable from Arduino to Input Power Amplifier and then press enter to start controller']);
pause()



% START CLOCK
tic
 
while(t<5)  
    
	velocity = analogRead(a, 3);
	position = analogRead(a, 5);

	theta = 3 * Vref_arduino * position / 1023;

	vtacho = 2 * (2 * velocity * Vref_arduino / 1023 - V_7805);

	% Information not needed
	% position = readVoltage(a, 'A5');
	% velocity = readVoltage(a, 'A3'); 
	% theta = 3 * Vref_arduino * position / 5;
	% vtacho = 2 * (2 * velocity * Vref_arduino / 5 - V_7805);

	e = y_r - theta;
	
	if abs(e) > 255
		e = sign(e) * 255;
	end



	if e > 0
		analogWrite(a, 6, 0);
		analogWrite(a, 9, min(round(e / 2 * 255 / Vref_arduino), 255));
		
	%	writePWMVoltage(a, 'D6', 0)
	%	writePWMVoltage(a, 'D9', abs(e) / 2)
	else
		analogWrite(a, 9, 0);
		analogWrite(a, 6, min(round(-e / 2 * 255 / Vref_arduino), 255));
	
	%    writePWMVoltage(a, 'D9', 0)
	%	writePWMVoltage(a, 'D6', abs(e) / 2)
	end

	% Set time to current time
	t = toc;

	% Update matrices with information    
	timeData = [timeData t];
	positionData = [positionData theta];
	velocityData = [velocityData vtacho];
	eData = [eData e];

end

% OUTPUT ZERO CONTROL SIGNAL TO STOP MOTOR  %
analogWrite(a, 6, 0);
analogWrite(a, 9, 0);

% Information not needed
% writePWMVoltage(a, 'D6', 0)
% writePWMVoltage(a, 'D9', 0)

disp(['End of control Loop. Press enter to see diagramms']);
pause();


figure(1)
plot(timeData, positionData);
title('position')

figure(2)
plot(timeData, velocityData);
title('velocity')

figure(3)
plot(timeData, eData);
title('error')

disp('Disonnect cable from Arduino to Input Power Amplifier and then press enter to stop controller');
pause();

