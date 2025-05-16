% This must be calculated according to lab information
V_7805 = 5.371;
Vref_arduino = 5;

km = 218.89;
kt = 0.00127;
k0 = 0.188;
w = 2197.36;
kmi = 1/36;
tm = 0.47;
vt = 2.78;

k1 = 0.005;
k2 = 5;

s1 = -3;
s2 = -10;
%kalitero apotelesma me -20 kai -50

p1 = -s1-s2;
p2 = s1*s2;

omega_hat = 0;
theta_hat = 0;

x_hat = [omega_hat; theta_hat];
y_r = 8;

A = [-1/tm 0;
    kmi*k0 0];
B = [km/tm;
    0];
C = [0 1];
L = [-407.47*p1 + 866.96 + 191.57*p2;
    p1 - 2.13];


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
zetaData = [];
position_hatData = [];
omega_hatData = [];



% Set initial time to zero
t=0;

% CLOSE ALL PREVIOUS FIGURES FROM SCREEN
close all

% WAIT A KEY TO PROCEED
disp(['Connect cable from Arduino to Input Power Amplifier and then press enter to start controller']);
pause()

position = analogRead(a, 5);

theta = 3 * Vref_arduino * position / 1023;
x_hat(2) = theta;

% START CLOCK
tic


 
while(t<5)  
    
	velocity = analogRead(a, 3);
	position = analogRead(a, 5);

	theta = 3 * Vref_arduino * position / 1023;

	vtacho = 2 * (2 * velocity * Vref_arduino / 1023 - V_7805);
    omega = vtacho / kt;

   
    
    %1 ERWTHMA
    u = 7;

    %2 ERWTHMA
    %u = -k1*omega_hat - k2*theta_hat + k2*y_r;
    

    x_hat = x_hat + (toc - t) * (A*x_hat + B*u + L*(theta - C*x_hat));
    omega_hat = x_hat(1);
    theta_hat = x_hat(2);

 

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
    uData = [uData u];
    yrData = [yrData y_r];
    position_hatData = [position_hatData theta_hat];
    omega_hatData = [omega_hatData omega_hat];

end

% OUTPUT ZERO CONTROL SIGNAL TO STOP MOTOR  %
analogWrite(a, 6, 0);
analogWrite(a, 9, 0);


disp(['End of control Loop. Press enter to see diagramms']);
pause();



%1 ERWTHMA
figure(1)
plot(timeData, positionData); hold on;
plot(timeData, position_hatData); 
title('position')
grid on;



%2 ERWTHMA
%{
figure(1)
plot(timeData, positionData); hold on;
plot(timeData, position_hatData); hold on;
plot(timeData, yrData);
title('position')
grid on;
%}

figure(2)
plot(timeData, omegaData); hold on;
plot(timeData, omega_hatData);
title('velocity')
grid on;

figure(3)
plot(timeData, uData);
title('controller')
grid on;



% disp('Disonnect cable from Arduino to Input Power Amplifier and then press enter to stop controller');
% pause();

