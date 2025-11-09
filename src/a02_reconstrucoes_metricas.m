% --- Parâmetros do Projeto ---
TARGET_NRMSE = 0.10;  % 10%
TARGET_ENERGY = 0.95; % 95%

%% 1. Carregar audio recortado e Calcular FFT
input_file = '../data/audio_recortado.wav';
fprintf('Carregando áudio pré-processado de: %s\n', input_file);
try
    [x, Fs] = audioread(input_file);
catch
    error('Arquivo "%s" não encontrado. Rode o script a01 primeiro.', input_file);
end

N = length(x);
X = fft(x); % Espectro original

% Helper function para NRMSE: ||x - x_hat|| / ||x||
norm_x = norm(x);
nrmse_calc = @(x_hat) norm(x - x_hat) / norm_x;

%% 2. Preparar Componentes para Reconstrução
% Ordenar as componentes únicas (DC + semiespectro positivo)
% por magnitude decrescente.
half_N = floor(N/2);
indices_unicos = (1:half_N+1)';
mags_unicas = abs(X(indices_unicos));

% Ordena as magnitudes e guarda os índices originais
[~, sort_order] = sort(mags_unicas, 'descend');
indices_ordenados = indices_unicos(sort_order);

fprintf('Total de amostras (N): %d\n', N);
fprintf('Total de componentes únicas (DC + Positivas): %d\n', length(indices_ordenados));

%% 3. Tarefa 1: Reconstrução Incremental (Critério de Erro NRMSE <= 10%)

fprintf('\n--- Tarefa 1: Reconstrução Incremental (Erro) ---\n');

X_recon_inc = zeros(N, 1, 'like', X); % Começa com espectro zerado
nrmse_history = zeros(length(indices_ordenados), 1);
components_count = zeros(length(indices_ordenados), 1);

K_star = 0;
K_star_found = false;
k_added_total = 0;

for i = 1:length(indices_ordenados)
    k = indices_ordenados(i); % Pega o índice da próxima maior componente
    
    % Adiciona a componente principal
    X_recon_inc(k) = X(k);
    k_added_total = k_added_total + 1;
    
    % Adiciona o par conjugado (se não for DC ou Nyquist)
    is_dc = (k == 1);
    is_nyquist = (mod(N, 2) == 0) && (k == half_N + 1);
    
    if ~is_dc && ~is_nyquist
        k_conj = N - k + 2;
        X_recon_inc(k_conj) = X(k_conj);
        k_added_total = k_added_total + 1;
    end
    
    % Reconstruir o sinal no tempo
    x_recon_inc_temp = real(ifft(X_recon_inc));
    
    % Calcular o erro residual
    err = nrmse_calc(x_recon_inc_temp);
    nrmse_history(i) = err;
    components_count(i) = k_added_total;
    
    % Parar quando NRMSE <= 10% e registrar K*
    if err <= TARGET_NRMSE && ~K_star_found
        K_star = k_added_total;
        K_star_found = true;
        fprintf('Meta NRMSE (<= %.1f%%) atingida!\n', TARGET_NRMSE*100);
        fprintf('K* (Componentes usadas): %d\n', K_star);
        fprintf('NRMSE em K*: %.2f%%\n', err*100);
        
        % Salvar áudio entregável
        audiowrite('../audio_out/recon_inc_Kstar.wav', x_recon_inc_temp, Fs);
    end
end

if ~K_star_found
    fprintf('Aviso: Meta de NRMSE não foi atingida. K* não definido.\n');
end

% Plotar curva Erro x Nº de componentes
figure('Name', 'Comparação: Erro (NRMSE)');
plot(components_count, nrmse_history * 100, 'b-', 'LineWidth', 1.5);
hold on;
if K_star_found
    plot(K_star, nrmse_history(components_count == K_star) * 100, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    xline(K_star, 'r--', 'LineWidth', 1.5);
    legend('Curva de Erro', sprintf('K* = %d (NRMSE <= 10%%)', K_star), 'Location', 'northeast');
end
title('Erro (NRMSE) vs. Nº de Componentes Espectrais');
xlabel('Nº de Componentes (K)');
ylabel('NRMSE (%)');
grid on;
ylim([0, 100]);
saveas(gcf, '../figs/curva_NRMSE.png'); 
saveas(gcf, '../figs/pdfs/curva_NRMSE.pdf'); 

%% 4. Tarefa 2: Reconstrução por Energia (Fração Alvo 95%)

fprintf('\n--- Tarefa 2: Reconstrução por Energia (%.1f%%) ---\n', TARGET_ENERGY*100);

% Usamos a MESMA ORDEM de componentes (indices_ordenados)
energies_all = abs(X).^2;
total_energy = sum(energies_all);
target_energy_val = TARGET_ENERGY * total_energy;

X_recon_energy = zeros(N, 1, 'like', X);
current_energy = 0;
num_comps_energy = 0;

for i = 1:length(indices_ordenados)
    k = indices_ordenados(i);
    
    % Adiciona a componente principal
    comp_energy = energies_all(k);
    X_recon_energy(k) = X(k);
    num_comps_energy = num_comps_energy + 1;
    
    % Adiciona o par conjugado
    is_dc = (k == 1);
    is_nyquist = (mod(N, 2) == 0) && (k == half_N + 1);
    
    if ~is_dc && ~is_nyquist
        k_conj = N - k + 2;
        comp_energy = comp_energy + energies_all(k_conj);
        X_recon_energy(k_conj) = X(k_conj);
        num_comps_energy = num_comps_energy + 1;
    end
    
    current_energy = current_energy + comp_energy;
    
    % Parar quando atingir a fração-alvo
    if current_energy >= target_energy_val
        break;
    end
end

% Reconstruir o sinal e comparar
x_recon_energy = real(ifft(X_recon_energy)); % <-- 1. CRIA O SINAL PRIMEIRO
        
% Renormaliza para garantir que está em [-1, 1] antes de salvar
x_recon_energy = x_recon_energy / max(abs(x_recon_energy)); 

audiowrite('../audio_out/recon_energia_95.wav', x_recon_energy, Fs); 

% Comparação quantitativa e qualitativa
nrmse_energy = nrmse_calc(x_recon_energy);
frac_energy_obtida = current_energy / total_energy;

% Tabela/Resultados para o relatório
disp('--- Resultados da Reconstrução por Energia ---');
T_energia = table(TARGET_ENERGY*100, frac_energy_obtida*100, num_comps_energy, nrmse_energy*100, ...
    'VariableNames', {'Energia Alvo (%)', 'Energia Obtida (%)', 'Componentes Usadas (K)', 'NRMSE Final (%)'});
disp(T_energia);

fprintf('\nScript da a02 concluído. Entregáveis gerados:\n');
disp('  - audio_out/recon_inc_Kstar.wav');
disp('  - audio_out/recon_energia_95.wav');
disp('  - figs/curva_NRMSE.png e pdf');