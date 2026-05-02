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
| P6 | HUD e Feedback | - | ⏳ Pending |
