%% ========================================================================
%  SCRIPT 3: PITCH SHIFT
%  ========================================================================
%  Objetivo:
%    - Aplicar pitch shift +N semitons usando escalonamento espectral
%    - Salvar o áudio transposto
%    - Gerar gráfico comparativo: Original vs. Transposto
%  ========================================================================

fprintf('=== SCRIPT a03: PITCH SHIFT ===\n\n');

%% ------------------------------------------------------------------------
%  PARÂMETROS AJUSTÁVEIS
%  ------------------------------------------------------------------------
N_semitons = 3;  % Número de semitons para transpor (ex.: +3 = 3 semitons acima)

%% ------------------------------------------------------------------------
%  1. CARREGAR O ÁUDIO PROCESSADO 
%  ------------------------------------------------------------------------
input_file = '../data/audio_recortado.wav';
fprintf('Carregando áudio base de: %s\n', input_file);

if ~isfile(input_file)
    error('Arquivo "%s" não encontrado. Execute o script a01 primeiro.', input_file);
end

[x, Fs] = audioread(input_file);
N = length(x);
fprintf('\tTaxa de amostragem: %d Hz\n', Fs);
fprintf('\tAmostras: %d (%.2f s)\n\n', N, N/Fs);

%% ------------------------------------------------------------------------
%  2. CALCULAR O FATOR DE ESCALONAMENTO (α)
%  ------------------------------------------------------------------------
% Fórmula: α = 2^(N/12), onde N é o número de semitons
alpha = 2^(N_semitons / 12);
fprintf('Transposição: +%d semitons\n', N_semitons);
fprintf('Fator de escalonamento (α): %.4f\n\n', alpha);

%% ------------------------------------------------------------------------
%  3. PITCH SHIFT POR ESCALONAMENTO ESPECTRAL
%  ------------------------------------------------------------------------
fprintf('Aplicando pitch shift via escalonamento espectral...\n');

% 3.1. Calcular a FFT do sinal original
X = fft(x);

% 3.2. Criar o eixo de frequências original
freq_original = (0:N-1) * (Fs / N);

% 3.3. Criar o novo eixo de frequências (escalonado)
freq_escalonada = freq_original / alpha;

% 3.4. Interpolar o espectro complexo
%      Detalhe: Interpolar a parte real e imaginária separadamente
X_real = interp1(freq_original, real(X), freq_escalonada, 'linear', 0);
X_imag = interp1(freq_original, imag(X), freq_escalonada, 'linear', 0);
X_shifted = X_real + 1i * X_imag;

% 3.5. Reconstruir o sinal no tempo
x_shifted = real(ifft(X_shifted));

% 3.6. Normalizar para [-1, 1]
x_shifted = x_shifted / max(abs(x_shifted));

fprintf('Pitch shift concluído!\n\n');

%% ------------------------------------------------------------------------
%  4. SALVAR O ÁUDIO TRANSPOSTO
%  ------------------------------------------------------------------------
% Adicionar sufixo ao nome do arquivo minus e plus
output_filename = sprintf('../audio_out/pitch_plus%d.wav', N_semitons);
audiowrite(output_filename, x_shifted, Fs);
fprintf('Áudio transposto salvo em: %s\n', output_filename);

%% ------------------------------------------------------------------------
%  5. PLOTAR COMPARAÇÃO: ORIGINAL vs. TRANSPOSTO
%  ------------------------------------------------------------------------
fprintf('Gerando gráfico de comparação...\n');

figure('Name', 'Comparação: Original vs. Pitch Shifted');

% Subplot 1: Sinal original no tempo
subplot(2,1,1);
t = (0:N-1)/Fs;
plot(t, x, 'b');
xlabel('Tempo [s]');
ylabel('Amplitude');
title('Sinal Original (Audio Recortado)');
grid on;

% Subplot 2: Sinal transposto no tempo
subplot(2,1,2);
plot(t, x_shifted, 'r');
xlabel('Tempo [s]');
ylabel('Amplitude');
title(sprintf('Sinal Transposto (+%d semitons, α = %.2f)', N_semitons, alpha));
grid on;

% Salvar a figura
saveas(gcf, '../figs/comparacao_pitch.png');
saveas(gcf, '../figs/pdfs/comparacao_pitch.pdf');
fprintf('Gráfico salvo em: figs/comparacao_pitch.pdf\n\n');

%% ------------------------------------------------------------------------
%  FIM DO SCRIPT
%  ------------------------------------------------------------------------
fprintf('\n=== SCRIPT 3 CONCLUÍDO ===\n');
fprintf('Entregáveis gerados:\n');
fprintf('  - audio_out/pitch_plus%d.wav\n', N_semitons);
fprintf('  - figs/comparacao_pitch.png\n');
fprintf('\n');