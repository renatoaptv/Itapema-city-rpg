# ITAPEMA CITY RPG — protótipo Godot 4

Projeto **independente** de RPG imobiliário mobile, com câmera em terceira pessoa e cenário costeiro inspirado em Meia Praia, Itapema/SC.

## Estado atual
- Projeto-fonte para Godot 4 (Compatibility / OpenGL), pensado para Windows e futuramente Android.
- Personagem 3D controlável, câmera em terceira pessoa, avenida, ciclovia, praia, palmeiras e prédios com vidros e sacadas, criados proceduralmente.
- Interface horizontal com joystick de toque, menus de imóveis, missão e chat **local de demonstração**.
- Jogável no editor com F6/F5; não é um APK.
- **Os prédios são fictícios e não correspondem a fachadas ou endereços reais.** O visual conceitual aprovado é uma meta de direção de arte, não um resultado já atingido.

## Como abrir
1. Instale Godot 4.4+ (edição Standard, sem precisar de .NET).
2. Clone ou baixe este repositório como ZIP (botão verde **Code > Download ZIP**).
3. No Godot, **Importar** e selecione `project.godot`.
4. Pressione F5. Se perguntar sobre a cena principal, escolha `scenes/main.tscn`.

## Controles
- PC: W/A/S/D ou setas para mover; mouse com botão direito para girar a câmera; Shift para correr; E para interagir.
- Mobile: orientação horizontal; toque/arraste na parte inferior esquerda para o joystick; arraste a metade direita da tela para girar; botões CORRER e INTERAGIR.

## Etapas para transformar na cidade real
1. Definir uma quadra exata de Meia Praia e mapear os endereços.
2. Reunir fotos recentes e utilizáveis das fachadas (direitos de uso e datas verificados).
3. Criar modelos 3D individuais no Blender e importar em GLB.
4. Implementar identificação de imóveis e cadastro de corretores.
5. Criar autenticação, moderação e chat multiplayer com backend e regras de privacidade.
6. Testar desempenho e exportar APK Android.

Não é necessário instalar plug-ins nem criar conta no Godot. Este repositório é uma base editável para evolução. Não publicamos dados pessoais nem anúncios reais sem autorização.