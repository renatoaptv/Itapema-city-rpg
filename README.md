# ITAPEMA CITY RPG — Meia Praia (protótipo Godot)

## Situação do projeto
**Versão 0.2 — cenário demonstrativo em 3D.**

O projeto agora separa o cenário em `scripts/city_world.gd`, facilitando a troca gradual dos prédios gerados por modelos 3D de fachadas reais.

**Incluído nesta atualização**
- Personagem com câmera em terceira pessoa mais próxima, controles para computador e joystick para celular;
- Torres com janelas, sacadas, vitrines e detalhes de fachada;
- Calçadão com piso, bancos, lixeiras, luminárias e palmeiras;
- Ciclovia, areia, guarda-sóis, mar e morros no horizonte;
- Menus de corretores, imóveis, missões, eventos, loja e chat **somente local**;
- Arquivo de verificação automática no GitHub Actions.

**Importante:** os prédios continuam fictícios. Não são cópias dos prédios de Itapema. A visualização é um estágio intermediário antes de modelar fachadas reais com fotos, endereços e autorização de uso.

**Nota de geografia:** o trecho típico da orla de Meia Praia não tem avenida de carros entre a primeira linha de prédios e a areia. Esta versão prioriza a configuração de calçadão + ciclovia + praia; há trechos com urbanização diferenciada, como entre as ruas 319 e 323B.

## Abrir no Windows
1. No GitHub, clique no botão **Code > Download ZIP**.
2. Extraia o arquivo em uma nova pasta (não misture com a versão anterior).
3. No Godot 4.7.2 (Standard), selecione **Importar** e escolha `project.godot`.
4. Abra `scenes/main.tscn` e pressione **F5**.

## Comandos
- W/A/S/D ou setas: caminhar.
- Shift: correr.
- Botão direito do mouse e arrastar: girar a câmera.
- E: abrir imóveis demonstrativos.
- No celular: orientar na horizontal, mover o joystick com o dedo e usar os controles de tela.

## O que falta para chegar à imagem de referência
1. Escolher **uma quadra real específica** em Meia Praia e registrar os lotes e edifícios;
2. Levantar fotos recentes de fachadas, sacadas, hall, calçadas e enquadramento;
3. Modelar cada prédio em Blender e salvar em formato GLB;
4. Implementar texturas de alta qualidade, iluminação, sombras e otimização mobile;
5. Criar backend, login, mensagens em tempo real e moderação;
6. Exportar e testar Android e depois iOS.

A imagem-conceito gerada anteriormente **não é uma captura de jogo funcional**. Essa base ainda não tem visual fotográfico nem multiplayer.

## Organização
- `project.godot`: configuração do jogo.
- `scenes/main.tscn`: cena inicial.
- `scripts/main.gd`: controles, avatar, menus e lógica.
- `scripts/city_world.gd`: geometria do bairro em 3D.

Código inicial e assets demonstrativos, sem marcas comerciais dos prédios reais.
