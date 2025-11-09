%% ========================================================================
%  MAIN.M - Pipeline Completo de Processamento de Sinais (PDS - Prática 2)
%  ========================================================================
%  Autores: Gabriel, Leonardo e Tiago
%  
%  Descrição:
%    Este script executa TODOS os passos do trabalho em sequência:
%      1. Pré-processamento e análise espectral 
%      2. Reconstruções e métricas
%      3. Pitch shift e integração final
%  
%  Requisitos:
%    - Arquivo "data/audio_original.wav" deve existir
%    - Scripts a01, a02 e a03 devem estar em src/
%    - MATLAB R2018b ou superior
%  
%  Saídas:
%    - data/audio_recortado.wav
%    - audio_out/*.wav (reconstruções e pitch shift)
%    - figs/*.png e *.pdf (gráficos)
%  ========================================================================

clear; clc; close all;

%% ========================================================================
%  CONFIGURAÇÃO INICIAL
%  ========================================================================
fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════════════╗\n');
fprintf('║       PIPELINE COMPLETO - PDS PRÁTICA 2 (3 Scripts)           ║\n');
fprintf('╚════════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

% Registrar o tempo de início
tic;

%% ------------------------------------------------------------------------
%  1. CRIAR PASTAS NECESSÁRIAS
%  ------------------------------------------------------------------------
fprintf('>>> Criando estrutura de pastas...\n');
if ~exist('src', 'dir'); mkdir('src'); end
if ~exist('data', 'dir'); mkdir('data'); end
if ~exist('audio_out', 'dir'); mkdir('audio_out'); end
if ~exist('figs', 'dir'); mkdir('figs'); end
if ~exist('figs/pdfs', 'dir'); mkdir('figs/pdfs'); end
fprintf('    [OK] Pastas criadas/verificadas: src/, data/, audio_out/, figs/, figs/pdfs/\n\n');

%% ------------------------------------------------------------------------
%  2. VERIFICAR ARQUIVO DE ENTRADA
%  ------------------------------------------------------------------------
fprintf('>>> Verificando arquivo de entrada...\n');
input_audio = 'data/audio_original.wav';
if ~isfile(input_audio)
    error(['Arquivo "%s" não encontrado!\n' ...
           'Por favor, coloque o áudio original na pasta data/ antes de executar.'], ...
           input_audio);
end
fprintf('    [OK] Arquivo encontrado: %s\n\n', input_audio);

%% ========================================================================
%  ETAPA 1: PRÉ-PROCESSAMENTO E ANÁLISE ESPECTRAL
%  ========================================================================
fprintf('╔════════════════════════════════════════════════════════════════╗\n');
fprintf('║  ETAPA 1: Pré-processamento e Análise Espectral                ║\n');
fprintf('╚════════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

try
    run('src/a01_preprocess_fft.m');
    fprintf('\n[✓] ETAPA 1 CONCLUÍDA COM SUCESSO!\n\n');
catch ME
    fprintf('\n[✗] ERRO NA ETAPA 1:\n');
    fprintf('    %s\n', ME.message);
    fprintf('    Abortando pipeline...\n\n');
    rethrow(ME);
end

pause(1); % Pequena pausa para organização

%% ========================================================================
%  ETAPA 2: RECONSTRUÇÕES E MÉTRICAS
%  ========================================================================
fprintf('╔════════════════════════════════════════════════════════════════╗\n');
fprintf('║  ETAPA 2: Reconstruções e Métricas                             ║\n');
fprintf('╚════════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

try
    run('src/a02_reconstrucoes_metricas.m');
    fprintf('\n[✓] ETAPA 2 CONCLUÍDA COM SUCESSO!\n\n');
catch ME
    fprintf('\n[✗] ERRO NA ETAPA 2:\n');
    fprintf('    %s\n', ME.message);
    fprintf('    Abortando pipeline...\n\n');
    rethrow(ME);
end

pause(1);

%% ========================================================================
%  ETAPA 3: PITCH SHIFT E INTEGRAÇÃO FINAL 
%  ========================================================================
fprintf('╔════════════════════════════════════════════════════════════════╗\n');
fprintf('║  ETAPA 3: Pitch Shift                                          ║\n');
fprintf('╚════════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

try
    run('src/a03_pitch_integration.m');
    fprintf('\n[✓] ETAPA 3 CONCLUÍDA COM SUCESSO!\n\n');
catch ME
    fprintf('\n[✗] ERRO NA ETAPA 3:\n');
    fprintf('    %s\n', ME.message);
    fprintf('    Abortando pipeline...\n\n');
    rethrow(ME);
end

%% ========================================================================
%  RESUMO FINAL E VALIDAÇÃO
%  ========================================================================
tempo_total = toc;

fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════════════╗\n');
fprintf('║               PIPELINE CONCLUÍDO COM SUCESSO!                  ║\n');
fprintf('╚════════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

fprintf('Tempo total de execução: %.2f segundos (%.2f minutos)\n', tempo_total, tempo_total/60);
fprintf('\n');

%% ------------------------------------------------------------------------
%  VALIDAÇÃO DOS ENTREGÁVEIS
%  ------------------------------------------------------------------------
fprintf('=== VALIDAÇÃO DOS ENTREGÁVEIS ===\n\n');

% Áudios
audios_esperados = {
    'data/audio_recortado.wav', ...
    'audio_out/recon_inc_Kstar.wav', ...
    'audio_out/recon_energia_95.wav', ...
    'audio_out/pitch_plus3.wav'
};

fprintf('📁 Arquivos de Áudio:\n');
for i = 1:length(audios_esperados)
    if isfile(audios_esperados{i})
        fprintf('   [✓] %s\n', audios_esperados{i});
    else
        fprintf('   [✗] %s (FALTANDO!)\n', audios_esperados{i});
    end
end
fprintf('\n');

%% ------------------------------------------------------------------------
%  MENU INTERATIVO: REPRODUZIR ÁUDIOS
%  ------------------------------------------------------------------------

fprintf('╔════════════════════════════════════════════════════════════════╗\n');
fprintf('║                    REPRODUÇÃO DE ÁUDIOS                        ║\n');
fprintf('╚════════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

% Perguntar se deseja ouvir os áudios
resposta = input('Deseja ouvir os áudios gerados? (s/n): ', 's');

if strcmpi(resposta, 's') || strcmpi(resposta, 'sim')
    fprintf('\n--- Menu de Áudios ---\n');
    
    % Lista de áudios disponíveis
    audios_menu = {
        'data/audio_recortado.wav', 'Áudio Recortado e Normalizado';
        'audio_out/recon_inc_Kstar.wav', 'Reconstrução Incremental (K*)';
        'audio_out/recon_energia_95.wav', 'Reconstrução por Energia (95%%)';
        'audio_out/pitch_plus3.wav', 'Pitch Shift (+3 semitons)'
    };
    
    continuar = true;
    while continuar
        fprintf('\nEscolha um áudio para reproduzir:\n');
        for i = 1:size(audios_menu, 1)
            fprintf('  [%d] %s\n', i, audios_menu{i, 2});
        end
        fprintf('  [0] Sair\n');
        
        escolha = input('\nOpção: ');
        
        if escolha == 0
            continuar = false;
            fprintf('Encerrando reprodução de áudios.\n');
        elseif escolha >= 1 && escolha <= size(audios_menu, 1)
            arquivo = audios_menu{escolha, 1};
            if isfile(arquivo)
                fprintf('\n▶ Reproduzindo: %s\n', audios_menu{escolha, 2});
                [audio_data, Fs_audio] = audioread(arquivo);
                sound(audio_data, Fs_audio);
                fprintf('  Duração: %.2f segundos\n', length(audio_data)/Fs_audio);
                fprintf('  (Aguarde o término da reprodução...)\n');
                pause(length(audio_data)/Fs_audio + 0.5); % Aguarda a reprodução
            else
                fprintf('\n[!] Arquivo não encontrado: %s\n', arquivo);
            end
        else
            fprintf('\n[!] Opção inválida. Tente novamente.\n');
        end
    end
else
    fprintf('Reprodução de áudios ignorada.\n');
end

fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════════════╗\n');
fprintf('║                    FIM DO PIPELINE                             ║\n');
fprintf('╚════════════════════════════════════════════════════════════════╝\n');
fprintf('\n');