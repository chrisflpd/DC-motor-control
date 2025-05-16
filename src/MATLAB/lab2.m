% This must be calculated according to lab information
V_7805 = 5.371;
Vref_arduino = 5;

km = 218.89;
kt = 0.00127;
k0 = 0.188;
w = 2197.33;
kmi = 1/36;
tm = 0.47;
vt = 2.78;

k1 = 0.01;
k2 = 4.706;



%1 ERWTHMA
%y_r = 8;




%% Code to clear arduino variable if necessary
% clear
% delete(instrfind({'Port'}, {'COM7'}));
% a = arduino('COM7');

%%
% OUTPUT ZERO CONTROL SIGNAL TO STOP MOTOR  %
analogWrite(a, 6, 0);
analogWrite(a, 9, 0);



% Initialize matrix to fill with information
positionData = [];
velocityData = [];
omegaData = [];
eData = [];
uData = [];
timeData = [];
yrData = [];


% Set initial time to zero
t=0;

% CLOSE ALL PREVIOUS FIGURES FROM SCREEN
close all

% WAIT A KEY TO PROCEED
disp(['Connect cable from Arduino to Input Power Amplifier and then press enter to start controller']);
pause()



% START CLOCK
tic

%5 ERWTHMA
%bale 20 sto c
while(t<5)  
    
	velocity = analogRead(a, 3);
	position = analogRead(a, 5);

	theta = 3 * Vref_arduino * position / 1023;

	vtacho = 2 * (2 * velocity * Vref_arduino / 1023 - V_7805);
    omega = vtacho / kt;




    %5 ERWTHMA
    %bale 20second na trexei to loop
    %w_experiment = 6 * pi / 5;
    %w_experiment = 2 * pi / 5;
    %w_experiment = 2 * pi / 20;

    %y_r = 8 + 2*sin(w_experiment * t);





	e = y_r - theta;
	
	if abs(e) > 255
		e = sign(e) * 255;
	end

    u = -k1*omega - k2*theta + k2*y_r;

	if u > 0
		analogWrite(a, 6, 0);
		analogWrite(a, 9, min(round(u / 2 * 255 / Vref_arduino), 255));
		
	
	else
		analogWrite(a, 9, 0);
		analogWrite(a, 6, min(round(-u / 2 * 255 / Vref_arduino), 255));
	
	
	end

	% Set time to current time
	t = toc;

	% Update matrices with information    
	timeData = [timeData t];
	positionData = [positionData theta];
	velocityData = [velocityData vtacho];
    omegaData = [omegaData omega];
	eData = [eData e];
    uData = [uData u];
    yrData = [yrData y_r];

end

% OUTPUT ZERO CONTROL SIGNAL TO STOP MOTOR  %
analogWrite(a, 6, 0);
analogWrite(a, 9, 0);



disp(['End of control Loop. Press enter to see diagramms']);
pause();

grid on;
figure(1)
plot(timeData, positionData); hold on;
plot(timeData, yrData);
xlim([0 5])
title('position')
grid on;

figure(2)
plot(timeData, omegaData);
title('omega')
grid on;

figure(3)
plot(timeData, eData);
title('error')
grid on;

figure(4)
plot(timeData, uData);
title('controller')
grid on;

% disp('Disonnect cable from Arduino to Input Power Amplifier and then press enter to stop controller');
% pause();

