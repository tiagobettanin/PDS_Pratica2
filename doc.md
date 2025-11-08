## 📄 Script 1: `a01_preprocess_fft.m`

Este script é responsável pela **Etapa 1** do projeto: aquisição, pré-processamento e análise espectral do áudio. Ele prepara o arquivo de áudio que será usado por todas as outras etapas do trabalho.

### Propósito
O objetivo é isolar um evento sonoro (0.5s a 3s), limpá-lo (mono, normalizado) e realizar uma análise de frequência (FFT) para identificar seus componentes principais.

### Entradas (Inputs)
* `audio_original.wav` (ou `.mp3`): O arquivo de áudio bruto gravado ou baixado. Deve estar na mesma pasta do script.

### Saídas (Outputs / Entregáveis)
* **`data/audio_recortado.wav`**: O **"Handoff"**. Este é o áudio processado (mono, recortado, normalizado) que será usado pelas Pessoas 2 e 3.
* **`figs/espectro_magnitude.png`**: Gráfico do sinal no tempo, espectro de magnitude (linear) e espectro de magnitude (dB).
* **`figs/espectro_fase.png`**: Gráfico do espectro de fase.
* **Tabela no Console**: Uma tabela com os "Top picos" de frequência (Hz) e suas amplitudes.

### Parâmetros Ajustáveis (no código)
* `file` (linha 4): Nome do arquivo de áudio original.
* `t_inicio` (linha 19): Tempo (em segundos) onde o recorte do áudio deve começar.
* `t_fim` (linha 20): Tempo (em segundos) onde o recorte do áudio deve terminar.
* `num_picos` (linha 61): Quantidade de picos de frequência a serem exibidos na tabela do console.

### Fluxo de Execução
1.  **Aquisição:** Carrega o áudio original usando `audioread`.
2.  **Conversão para Mono:** Verifica se o áudio é estéreo (2 canais) e, em caso afirmativo, o converte para mono calculando a média dos canais.
3.  **Recorte:** Isola a região de interesse do áudio usando os índices calculados a partir de `t_inicio` e `t_fim`.
4.  **Normalização:** Normaliza o áudio recortado para que sua amplitude máxima seja `1.0` (garantindo o intervalo `[-1, 1]`).
5.  **Handoff (Salvar):** Cria a pasta `data/` (se não existir) e salva o áudio processado como `data/audio_recortado.wav`.
6.  **Análise FFT:** Calcula a FFT (`fft`) do sinal processado.
7.  **Correção de Amplitude:** Calcula o semi-espectro (metade positiva) e ajusta as amplitudes para refletirem a magnitude real das senóides (multiplicando por 2, exceto DC e Nyquist).
8.  **Detecção de Picos:** Usa `findpeaks` para localizar os picos de maior magnitude no espectro.
9.  **Geração de Entregáveis:** Cria a pasta `figs/` (se não existir), plota os gráficos solicitados e os salva como arquivos `.png`. Exibe a tabela de picos no console.

---

## 🧑‍🔬 Script 2: `a02_reconstrucoes_metricas.m`

Este script é responsável pela **Etapa 2**: reconstruir o sinal usando dois critérios diferentes (Erro NRMSE e Energia) e avaliar a qualidade dessas reconstruções.

### Propósito
Implementar e avaliar as duas estratégias de reconstrução do sinal a partir de seus componentes de frequência, conforme especificado no PDF da atividade.

### Entradas (Inputs)
* `data/audio_recortado.wav`: O arquivo de áudio processado e entregue pela Pessoa 1.

### Saídas (Outputs / Entregáveis)
* `audio_out/recon_inc_Kstar.wav`: Áudio reconstruído usando o critério de erro (NRMSE <= 10%).
* `audio_out/recon_energia_95.wav`: Áudio reconstruído usando o critério de energia (mantendo 95% da energia total).
* `figs/curva_NRMSE.png`: Gráfico da curva de Erro (NRMSE) vs. Número de Componentes (K) usadas.
* **Tabelas no Console**: Resumo dos resultados da reconstrução por energia.

### Parâmetros Ajustáveis (no código)
* `TARGET_NRMSE` (linha 16): O limiar de erro para a primeira reconstrução (definido como `0.10` ou 10%).
* `TARGET_ENERGY` (linha 17): A fração de energia a ser mantida na segunda reconstrução (definida como `0.95` ou 95%).

### Fluxo de Execução
1.  **Setup:** Cria a pasta `audio_out/` (se não existir).
2.  **Carregar Handoff:** Carrega o `data/audio_recortado.wav`.
3.  **Preparação:** Calcula a FFT do sinal original (`X`). Em seguida, ordena todos os componentes de frequência únicos (semi-espectro) por magnitude, da maior para a menor.
4.  **Tarefa 1: Reconstrução Incremental (Erro NRMSE):**
    * Inicia um loop `for` que itera sobre os componentes ordenados (do mais forte para o mais fraco).
    * A cada iteração, adiciona o componente atual (e seu par conjugado) a um espectro de reconstrução (`X_recon_inc`) que começou zerado.
    * Calcula a IFFT (`ifft`) para obter o sinal no tempo (`x_recon_inc_temp`).
    * Calcula o `NRMSE` (Erro) comparando o sinal reconstruído com o original.
    * Quando o `NRMSE` atinge o alvo (`<= 10%`) pela primeira vez, ele registra o número de componentes (`K*`), salva o áudio `recon_inc_Kstar.wav` (após normalizá-lo) e para de salvar.
    * O loop continua até o fim para gerar o gráfico completo.
    * Ao final do loop, plota e salva o gráfico `figs/curva_NRMSE.png`.
5.  **Tarefa 2: Reconstrução por Energia:**
    * Inicia um segundo loop, também iterando pelos componentes ordenados.
    * Calcula a energia total do sinal original.
    * A cada iteração, adiciona a energia do componente atual (e seu par conjugado) a um acumulador (`current_energy`).
    * Adiciona os componentes ao espectro `X_recon_energy`.
    * O loop para (`break`) assim que a `current_energy` atinge o alvo (95% da energia total).
    * Calcula a IFFT (`ifft`), normaliza o sinal resultante e o salva como `recon_energia_95.wav`.
    * Exibe no console uma tabela com os resultados (NRMSE final, componentes usadas, etc.).

# Pastas

project/
├─ data/                 (áudio original e recortes)
├─ audio_out/            (recon_inc_Kstar.wav, recon_energia_95.wav, pitch_plusN.wav)
├─ figs/                 (tempo, espectros, curva_NRMSE.png)
├─ src/                  (scripts .py se preferirem)
├─ a01_preprocess_fft.m
├─ a02_reconstrucoes_metricas.m
├─ a03_pitch_integration.m
├─ audio_original.wav
├─ doc.md
└─ main.ipynb OR main.py (pipeline completo)
