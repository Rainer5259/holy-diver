# Holy Diver - Project Rules & Workflow

## Git Workflow
- **Branching**: Every task must be implemented in a dedicated branch.
- **Naming Convention**: Use the pattern `type/task-description` (e.g., `feat/p2-combat-dodge`).
    - `feat/`: New features.
    - `refactor/`: Code improvements without changing behavior.
    - `chore/`: Maintenance, configuration, or documentation.
    - `fix/`: Bug fixes.
- **Documentation Rule**: All implementation details, logic changes, and created hooks MUST be documented in this file (or a specific CHANGELOG) within the branch **before** the final commit.
- **Commits**: Use descriptive messages following the `type: description` pattern.
- **Push**: After committing, push the branch to the remote repository using `git push origin branch-name`.

## Safety & Security
- **Destructive Commands**: AI Agents are prohibited from using commands like `git clean -fdX`, `git reset --hard` (without confirmation), or `rm -rf` on critical directories. See [AGENTS.md](./AGENTS.md) for full safety protocols.

## Feature Tracking
| Priority | Feature | Branch | Status |
|----------|---------|--------|--------|
| P1 | Base de Atributos | `feat/p1-base-attributes` | ✅ Finished |
| P2 | Combate e Esquiva | `feat/p2-combat-dodge` | ✅ Finished |
| P3 | Interação de Mapa | `feat/p3-map-interaction` | ✅ Finished |
| P4 | Sistema de Riscos | `feat/p4-hazard-system` | ✅ Finished |
| P5 | Evolução (Fogueira)| `feat/p5-progression-system` | ✅ Finished |
| P6 | HUD e Feedback | `feat/p6-hud-feedback` | ✅ Finished |
| P7 | Recheck e Refinamento | `fix/system-refinements` | ✅ Finished |
| P8 | Fix: GameManager Vars | `fix/gamemanager-missing-vars` | ✅ Finished |
| P9 | Config: Godot MCP | `chore/configure-godot-mcp` | ✅ Finished |
| P10 | Fix: Startup e Tileset | `fix/tileset-and-signals` | ✅ Finished |
| P11 | Fix: Respawn e Objetivos | `fix/respawn-and-objectives` | ✅ Finished |
| S2.1 | Drop de Moedas | `feat/s2-coin-drop` | ✅ Finished |
| S2.2 | Contadores na HUD | `feat/s2-hud-counters` | ✅ Finished |
| S2.3 | IA de Mobs Fortes | `feat/s2-strong-mob-ai` | ✅ Finished |
| S2.4 | Polimento e Mapa | `feat/s2-final-polish` | ✅ Finished |
| S3.1 | Menu da Fogueira | `feat/s3-bonfire-ui` | ✅ Finished |

## S3.1: Menu da Fogueira - Detalhes Técnicos
- **BonfireMenu.tscn**: Criada a interface interativa (`CanvasLayer`) para evolução de atributos do jogador.
- **BonfireMenu.gd**: Implementada a lógica de compra de upgrades de Vida e Estamina, conectada diretamente ao `GameManager`.
- **GameEvents**: O menu escuta o sinal `bonfire_rested` para abrir automaticamente e pausa o jogo durante a navegação.
- **Autoload**: `BonfireMenu` adicionado como autoload para garantir disponibilidade global e desacoplamento total dos objetos de fogueira.
- **Bonfire.gd**: Removida a lógica de auto-upgrade temporária, mantendo apenas a cura e o salvamento antes de disparar o sinal da UI.

## S2.4: Polimento e Mapa - Detalhes Técnicos
- **Navigation**: Área de navegação expandida para cobrir todo o mapa de teste (2500x2500px).
- **Mapa**: Instanciado o primeiro `StrongGoblin` no corredor oeste para validação imediata do sistema de IA.

## S2.3: IA de Mobs Fortes - Detalhes Técnicos
- **StrongEnemy.gd**: Nova classe que herda de `Enemy` e integra `NavigationAgent2D` para pathfinding inteligente.
- **StrongGoblin.tscn**: Novo inimigo com atributos elevados (HP, Dano) e visual diferenciado.
- **Navegação**: Adicionada `NavigationRegion2D` ao mapa principal para suportar o novo sistema de busca de caminho da IA.

## P11: Fix: Respawn e Objetivos - Detalhes Técnicos
- **Player.gd**: Implementada lógica de reset de cena (`reload_current_scene`) após a animação de morte, garantindo que o jogador possa tentar novamente.
- **Objetivo do Jogo**: Documentado o fluxo principal de gameplay para clareza do usuário.

## Objetivo do Jogo (Holy Diver)
O objetivo principal é explorar a masmorra, superar perigos e derrotar o Boss final.
1. **Exploração**: O jogador começa em uma área segura e deve navegar pelos corredores.
2. **Ativação de Mecanismos**: Encontre alavancas para abrir portas trancadas (como a `Entrance Door 1`).
3. **Coleta de Itens**: Derrote o Boss para obter a **Key** (Chave) que abre baús especiais.
4. **Combate**: Use sua espada (`J` ou `LMB`), arco (`K` ou `RMB`) e esquiva (`Espaço`) para sobreviver.
5. **Progressão**: Use fogueiras para salvar seu progresso e melhorar seus atributos.

### Como interagir com Alavancas/Baús:
1. Aproxime-se do objeto até estar dentro do raio de interação.
2. Pressione a tecla **E** ou **F** para interagir.
3. Se for uma alavanca, ela mudará de estado (Ligada/Desligada) e emitirá um sinal para abrir/fechar portas vinculadas.
4. Se for um baú trancado, você precisará da Chave no inventário (obtida ao derrotar o Boss).

## P10: Fix: Startup e Tileset - Detalhes Técnicos
- **dungeon_tileset.tres**: Corrigida estrutura do recurso que tentava instanciar uma classe inexistente (`PhysicsLayer`), movendo as propriedades de física diretamente para o recurso principal do TileSet.
- **game_events.gd**: Silenciados os avisos de "sinal não utilizado" usando anotações `# @warning_ignore`, pois são sinais de um barramento global (Event Bus) e o Godot às vezes falha em detectar seu uso dinâmico em outros arquivos.

## P7: Recheck e Refinamento - Detalhes Técnicos
- **Player.gd**: Refatorados getters/setters de atributos para evitar recursão infinita e garantir sincronia com `GameManager`.
- **Combate**: Adicionado `sword_cooldown` para evitar spam de ataques.
- **Interação**: Corrigida detecção de `Crate` no ataque de espada.
- **Estamina**: Bloqueada regeneração durante esquiva e ataque para maior peso tático.

