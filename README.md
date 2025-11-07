# PDS_Pratica2

PLANO DE DIVISÃO – PDCO6A (3 pessoas) 
Obs.: Pessoa 3 = GABRIEL (fica com um pouquinho mais de trabalho na integração/entrega)

────────────────────────────────────────────────
PESSOA 1 — Aquisição, pré-processamento e espectro
Objetivo: deixar um trecho mono (≤3 s) pronto e caracterizado no domínio da frequência.
- Buscar/gravar o áudio e documentar a fonte (licença, link ou método de gravação).
- Converter para mono (média entre canais).
- Recortar a região de interesse (manual ou automático); salvar: audio_recortado.wav.
- Normalizar para amplitude em [-1, 1].
- Calcular FFT: magnitude (linear e dB) e fase.
- Detectar picos significativos no semiespectro positivo (freq e amp).
Entregáveis:
- Tabela “Top picos” (Hz, amplitude, fase opcional).
- Gráficos: sinal no tempo, magnitude (linear e dB), fase.
- Script/notebook: 01_preprocess_fft.ipynb.

────────────────────────────────────────────────
PESSOA 2 — Reconstruções e métricas (erro & energia)
Objetivo: implementar e avaliar as duas estratégias de reconstrução.
- Incremental por componentes principais (critério de erro):
  • Ordenar componentes por magnitude.
  • Reconstruir incrementalmente.
  • Calcular NRMSE a cada K; parar quando NRMSE ≤ 10% e registrar K*.
  • Plotar curva Erro × Nº de componentes destacando K*.
- Por energia (fração alvo, ex.: 95%):
  • Selecionar componentes de maior energia (pares conjugados).
  • Reconstruir e comparar ao original (NRMSE + comentário perceptual).
Entregáveis:
- Áudios: recon_inc_Kstar.wav, recon_energia_95.wav.
- Gráficos da curva NRMSE e tabela com (K, NRMSE, fração de energia).
- Script/notebook: 02_reconstrucoes_metricas.ipynb.

────────────────────────────────────────────────
PESSOA 3 — GABRIEL — Pitch shift, integração e relatório (um pouco mais)
Objetivo: finalizar com transposição espectral e consolidar tudo.
- Pitch shift +N semitons por escalonamento espectral:
  • Fator α = 2^(N/12).
  • Interpolar o espectro complexo para Y(f/α) (magnitude + fase).
  • Reconstruir e salvar: pitch_plusN.wav (ex.: N = +3).
- Integração e reprodutibilidade:
  • Padronizar E/S (mesmo samplerate, caminhos, nomes).
  • Garantir execução fim-a-fim (main.ipynb ou main.py).
- Relatório/Slides e entrega:
  • Figuras finais, tabelas, resumo (K*, NRMSE, fração de energia, comentários perceptuais).
  • Seção “Metodologia” (DFT/FFT, critérios, fórmula NRMSE).
  • Conferir links/arquivos (áudios e figuras) no relatório final.
Entregáveis:
- 03_pitch_integration.ipynb + main.ipynb/main.py.
- Relatório curto (PDF) e/ou slides.
- Pasta final organizada (data/, figs/, audio_out/, src/).

────────────────────────────────────────────────
HANDOFFS
- Pessoa 1 → Pessoa 2: áudio normalizado/recortado + espectro + tabela de picos.
- Pessoa 2 → Gabriel: reconstruções (arquivos .wav) + métricas + gráficos.
- Gabriel → Todos: versão preliminar do relatório para revisão cruzada.

PRAZOS SUGERIDOS
- Dia 1–2: Pessoa 1 finaliza pré-processamento e picos.
- Dia 3–4: Pessoa 2 finaliza reconstruções e métricas.
- Dia 5: Gabriel finaliza pitch, integra pipeline e monta o relatório; 1/2 revisam.

BOAS PRÁTICAS (curto)
- Usar taxa de amostragem única (ex.: 44,1 kHz).
- Nomes consistentes de arquivos e pastas; seed fixa se houver aleatoriedade.
- NRMSE = ||x - x_hat||2 / ||x||2 (reportar em %).
- Respeitar pares conjugados ao selecionar componentes.
- Comentário perceptual curto para cada áudio reconstruído.

SUGESTÃO DE ESTRUTURA DE PASTAS
project/
├─ data/                 (áudio original e recortes)
├─ audio_out/            (recon_inc_Kstar.wav, recon_energia_95.wav, pitch_plusN.wav)
├─ figs/                 (tempo, espectros, curva_NRMSE.png)
├─ src/                  (scripts .py se preferirem)
├─ 01_preprocess_fft.ipynb
├─ 02_reconstrucoes_metricas.ipynb
├─ 03_pitch_integration.ipynb
└─ main.ipynb OR main.py (pipeline completo)

CHECKLIST RÁPIDO
[ ] Áudio ≤ 3 s, mono e normalizado [-1, 1]
[ ] FFT feita, magnitude (linear/dB) e fase plotadas
[ ] Tabela com principais picos (Hz, amp)
[ ] Reconstrução incremental: K* com NRMSE ≤ 10% + curva
[ ] Reconstrução por energia (95%): NRMSE + perceptual
[ ] Pitch shift +N semitons por escalonamento espectral
[ ] Relatório/slides com resultados, figuras e links de áudio
[ ] Pipeline reproduzível (main.* funcionando)

## Som Passarinho
https://sound-effects.bbcrewind.co.uk/search?q=NHU05104173
