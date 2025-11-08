clear; clc; close all;

%% 1. Aquisição
file = "audio_original.wav"; 
[x, Fs] = audioread(file);
fprintf('Arquivo original: %s\nTaxa de amostragem: %d Hz\n', file, Fs);
fprintf('Duração original: %.2f s\n', length(x)/Fs);
% sound(x, Fs); % Opcional: ouvir o áudio original

%% 2. Converter para mono
if size(x,2) > 1
    x = mean(x, 2);
    fprintf('Convertido para mono.\n');
end

%% 3. Recortar a região de interesse (Manual)
% (Ajustar 't_inicio' e 't_fim' para pegar < 3s do som principal)
t_inicio = 0.5; % [s] Início do recorte (AJUSTAR)
t_fim = 1.8;    % [s] Fim do recorte (AJUSTAR)

% Cálculo dos índices
idx_inicio = round(t_inicio * Fs) + 1;
idx_fim = round(t_fim * Fs);

% Garante que os índices estão dentro dos limites
if idx_inicio < 1; idx_inicio = 1; end
if idx_fim > length(x); idx_fim = length(x); end

x_recortado = x(idx_inicio:idx_fim);
fprintf('Áudio recortado entre %.2f s e %.2f s.\n', t_inicio, t_fim);
fprintf('Duração final: %.2f s (Amostras: %d)\n', length(x_recortado)/Fs, length(x_recortado));

%% 4. Normalizar o trecho final para amplitude em [-1, 1]
x_proc = x_recortado / max(abs(x_recortado));
fprintf('Amplitude normalizada para [-1, 1].\n');

%% 5. Salvar o áudio processado (Handoff para Pessoa 2)
output_filename = 'data/audio_recortado.wav';
audiowrite(output_filename, x_proc, Fs);
fprintf('Handoff salvo em: %s\n', output_filename);

%% 6. Calcular FFT
N = length(x_proc);
X = fft(x_proc);

% Correção de Amplitude (Refinamento Técnico)
% A magnitude real da senóide é 2*|X(k)|/N
P2 = abs(X/N);
X_mag_pos = P2(1:floor(N/2)+1);
X_mag_pos(2:end-1) = 2*X_mag_pos(2:end-1); % Multiplica por 2 (exceto DC e Nyquist)

f_pos = (0:floor(N/2))*(Fs/N); % Eixo de frequência positivo
X_mag_db_pos = 20*log10(X_mag_pos + eps); % em dB

% Fase
X_phase = angle(X);
X_phase_pos = X_phase(1:floor(N/2)+1);

%% 7. Localizar picos principais no espectro positivo
num_picos = 5; % número de picos a exibir
[pks, locs] = findpeaks(X_mag_pos, f_pos, 'SortStr', 'descend');

n = min(num_picos, length(pks));
pks = pks(1:n);
locs = locs(1:n);

% Entregável: Tabela "Top picos"
T = table((1:n)', locs(:), pks(:), 20*log10(pks(:) + eps), ...
    'VariableNames', {'#', 'Frequencia_Hz', 'Amplitude_linear', 'Amplitude_dB'});

disp('--- Maiores componentes espectrais ---');
disp(T);

%% 8. Plotar resultados (Entregáveis Gráficos)
t = (0:length(x_proc)-1)/Fs;

% Gráfico 1: Sinal e Espectros
figure('Name', 'Analise Espectral (Pessoa 1)');
subplot(3,1,1);
plot(t, x_proc);
xlabel('Tempo [s]'); ylabel('Amplitude');
title('Sinal Normalizado e Recortado');
grid on;

subplot(3,1,2);
plot(f_pos, X_mag_pos);
hold on; plot(locs, pks, 'ro');
xlabel('Frequência [Hz]'); ylabel('Magnitude (linear)');
title('Espectro de Magnitude (linear)');
grid on; xlim([0 Fs/2]);

subplot(3,1,3);
plot(f_pos, X_mag_db_pos);
hold on; plot(locs, 20*log10(pks + eps), 'ro');
xlabel('Frequência [Hz]'); ylabel('Magnitude [dB]');
title('Espectro de Magnitude (dB)');
grid on; xlim([0 Fs/2]);

saveas(gcf, 'figs/espectro_magnitude.png');

% Gráfico 2: Fase
figure('Name', 'Espectro de Fase (Pessoa 1)');
plot(f_pos, unwrap(X_phase_pos));
xlabel('Frequência [Hz]');
ylabel('Fase [rad]');
title('Espectro de Fase (unwrap)');
grid on; xlim([0 Fs/2]);
saveas(gcf, 'figs/espectro_fase.png');

fprintf('Script da Pessoa 1 concluído. Gráficos salvos em /figs/.\n');