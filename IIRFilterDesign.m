% IIR Digital Low Pass Filter Design 2016.07.23 for AHRS (Hong Hyosung)
clear; close all;
%% Desired filter spec
% fc = 1;  %Hz Cutoff frequency
% fa = 2;  %Hz Attenuation frequency
% Ma = -10;    % dB Attenuation magnitude
% fs = 1000;    %Hz Sampling frequency
fc = 20;  %Hz Cutoff frequency
fa = 2*fc;  %Hz Attenuation frequency
Ma = -10;    % dB Attenuation magnitude
fs = 200;    %Hz Sampling frequency
%% Calculate digital frequency
theta_c = 2*pi*fc/fs;
theta_a = 2*pi*fa/fs;

%% Calculate prewarping frequency
wc_p = tan(theta_c/2);
wa_p = tan(theta_a/2);

%% Design the prototype Butterworth low pass filter
wa = wa_p/wc_p;

%% Calculate the filter order N
N_temp = log(10^(-Ma/10)-1)/(2*log(wa));
N = ceil(N_temp);

%% Get digital filter
[z,p,k] = buttap(N);
[bp,ap] = zp2tf(z,p,k);
[b,a] = lp2lp(bp,ap,2*pi*fc);
[bz,az] = bilinear(b,a,fs);
tf(bz,az);

%% Filter code
fprintf('For fc = %.1fHz, fa = %.1fHz, the IIR low pass filter result is \n', fc, fa);
if N==2
    fprintf('y[k] = %.10f x[k] + %.10f x[k-1] + %.10f x[k-2] + %.10f y[k-1] + %.10f y[k-2]  \n', bz(1), bz(2), bz(3), -az(2), -az(3));
elseif N==3
    fprintf('y[k] = %.10f x[k] + %.10f x[k-1] + %.10f x[k-2] + %.10f x[k-3] + %.10f y[k-1] + %.10f y[k-2] + %.10f y[k-3] \n', bz(1), bz(2), bz(3), bz(4) ,-az(2), -az(3), -az(4));
else
    fprintf('필터의 차수가 N=3을 초과합니다.\n');
end

%% Plot the result
% bode plot in Hz scale
figure(1)
opts = bodeoptions('cstprefs');
opts.FreqUnits = 'Hz';
bodeplot(tf(b,a),opts);
grid on
title('Butterworth LPF')

% IIR filter stability check
figure(2)
zplane(bz,az);
title('pole-zero plot');

% digital filter magnitude check with respect to digital frequency(rad)
theta = -pi:pi/300:pi;
m = freqz(bz,az,theta);
figure(3)
plot(theta,0.707,theta,abs(m))
grid on
xlabel('Digital frequency (rad)')
ylabel('|H(z)|')
