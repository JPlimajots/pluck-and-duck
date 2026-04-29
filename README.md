# 🦆 Pluck & Duck

Um jogo arcade de galeria de tiro, desenvolvido na engine Godot 4. 

Este é um projeto prático com foco acadêmico e de engenharia de software, criado para testar e consolidar conceitos de arquitetura de jogos, gerenciamento de estado, orientação a eventos e estruturação de código escalável em GDScript.

## 👨‍💻 Autores

* **João:** Desenvolvedor Principal e Arquiteto de Sistemas.

## 🎨 Créditos e Assets

A construção visual deste projeto só foi possível graças à fantástica biblioteca de domínio público criada por **[Kenney](https://www.kenney.nl/)**. O seu trabalho é um recurso inestimável que impulsiona a comunidade de desenvolvedores independentes ao redor do mundo.

## 🚀 Fases de Desenvolvimento (Roadmap)

O escopo do projeto foi estruturado em fases de complexidade progressiva para garantir a aplicação de código limpo e responsabilidades únicas para cada sistema:

* [x] **Fase 1: O Palco e a Mira (Fundações)**
  * Estruturação de Singletons/Autoloads para gerenciamento global de camadas.
  * Ocultação do cursor nativo do SO.
  * Implementação de uma mira personalizada orientada a eventos de input.

* [x] **Fase 2: A Arma e o Tiro (Core Loop - Parte 1)**
  * Encapsulamento da lógica de negócio da munição (capacidade máxima e carga atual).
  * Captura assíncrona de cliques do mouse para mecânicas de disparo e recarga manual.
  * Implementação inicial de *feedback* de áudio.

* [x] **Fase 3: O Alvo Base (Core Loop - Parte 2)**
  * Engenharia de *hitboxes* otimizadas combinando formas geométricas primitivas.
  * Movimentação autônoma do alvo (simulação de esteira mecânica).
  * Refatoração da Mira para atuar como um "Radar Físico", detectando colisões em tempo real via sistema de Grupos nativo da Godot.

* [ ] **Fase 4: Spawner e Interface de Usuário (Sistemas)**
  * Construção de um Gerador de Alvos utilizando nós de `Timer` para controle de fluxo.
  * Instanciação dinâmica de cenas via código.
  * Desenvolvimento do *Heads-Up Display* (HUD) para exibição de pontuação.

* [ ] **Fase 5: Polimento e Animações (Game Feel)**
  * Implementação de animações de queda para os alvos abatidos.
  * Ajustes finos de cadência e balanceamento da dificuldade.