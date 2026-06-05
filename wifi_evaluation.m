%% Performance Evaluation of 802.11 Adaptive Modulation with SER
clear; clc; close all;

% 1. Network Parameters
dist = 1:0.5:100;         
txPower = 20;             
c = 3e8;                  
noiseFloor = -95;         

freq_24 = 2.4e9;          
freq_5 = 5e9;             

n = 3;                    
wall_distance = 30;       
wall_attenuation = 12;    

% 2. Path Loss & SNR Calculation
L0_24 = 20*log10(1) + 20*log10(freq_24) - 147.55;
L0_5  = 20*log10(1) + 20*log10(freq_5)  - 147.55;

snr_24 = zeros(size(dist));
snr_5  = zeros(size(dist));

for i = 1:length(dist)
    pl_24 = L0_24 + 10 * n * log10(dist(i));
    pl_5  = L0_5  + 10 * n * log10(dist(i));
    
    if dist(i) >= wall_distance
        pl_24 = pl_24 + wall_attenuation;
        pl_5  = pl_5 + wall_attenuation;
    end
    
    snr_24(i) = (txPower - pl_24) - noiseFloor;
    snr_5(i)  = (txPower - pl_5)  - noiseFloor;
end

% 3. Adaptive Modulation & SER Logic
% Now we extract both the Throughput and the Modulation Order (M)
[throughput_24, M_24] = map_snr_to_throughput(snr_24);
[throughput_5, M_5]   = map_snr_to_throughput(snr_5);

% Calculate SER based on the current SNR and Modulation Order
ser_24 = calculate_ser(snr_24, M_24);
ser_5  = calculate_ser(snr_5, M_5);

% 4. Visualization
figure('Name', '802.11 Performance & SER Evaluation', 'Position', [100, 50, 800, 800]);

% Subplot 1: Signal-to-Noise Ratio
subplot(3,1,1);
plot(dist, snr_24, 'b', 'LineWidth', 2); hold on;
plot(dist, snr_5, 'r', 'LineWidth', 2);
ylims1 = ylim; 
plot([wall_distance wall_distance], ylims1, '--k', 'LineWidth', 1.5); 
grid on;
title('Signal-to-Noise Ratio (SNR) vs Distance');
ylabel('SNR (dB)');
legend('2.4 GHz', '5 GHz', 'Concrete Wall', 'Location', 'northeast');

% Subplot 2: Throughput (The Staircase)
subplot(3,1,2);
stairs(dist, throughput_24, 'b', 'LineWidth', 2); hold on;
stairs(dist, throughput_5, 'r', 'LineWidth', 2);
ylims2 = [-5 60]; ylim(ylims2);
plot([wall_distance wall_distance], ylims2, '--k', 'LineWidth', 1.5);
grid on;
title('Adaptive Modulation: Throughput vs Distance');
ylabel('Throughput (Mbps)');

% Subplot 3: Symbol Error Rate (Logarithmic Scale)
subplot(3,1,3);
% We use semilogy because error rates drop exponentially
semilogy(dist, ser_24, 'b', 'LineWidth', 2); hold on;
semilogy(dist, ser_5, 'r', 'LineWidth', 2);
ylims3 = [1e-8 1.5]; ylim(ylims3);
plot([wall_distance wall_distance], ylims3, '--k', 'LineWidth', 1.5);
grid on;
title('Symbol Error Rate (SER) vs Distance');
xlabel('Distance (meters)'); ylabel('SER (Log Scale)');