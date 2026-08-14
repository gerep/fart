# F.A.R.T.

## Feed And Raise Turrets

**Tagline:** You Are What You Shoot.

## Concept

F.A.R.T. is a small tower-defence game where every turret begins identical and evolves according to what it kills. The player places turrets beside the path and assigns persistent targeting rules to control each turret's “diet.” Runners make turrets faster, tanks make them stronger, and swarms give them splash damage. The fun comes from cultivating specialized or strange hybrid turrets while surviving escalating waves.

**Jam constraints:** Four days, solo development, Godot and GDScript, primarily sourced assets.

## Design Pillars

1. **Evolution replaces upgrade menus.** Turrets improve only through their kills.
2. **Targeting is the main decision.** The player guides evolution with placement and simple targeting priorities, never manual attacks.
3. **Readable cause and effect.** Players can immediately see what a turret ate, what it will become, and why it evolved.
4. **Tiny, complete scope.** One map and a few strongly differentiated enemies are enough.

## Core Loop

`Place turret → choose targeting priority → survive wave → earn coins and traits from kills → place more turrets → face a harder wave`

- Enemies reaching the exit damage the base.
- The run ends when base HP reaches zero.
- **Assumption:** Surviving 10 waves wins the run. Endless scoring is optional.

## Rules

### Turret placement

- The player spends coins to place a basic turret anywhere beside the path, without a grid.
- Turrets cannot overlap the path or another turret. Path-blocking is excluded to avoid dynamic pathfinding.
- Placement preview shows validity and attack range.
- Once placed, a turret stays in position.

### Automatic combat

- Turrets automatically attack valid enemies within range.
- The player selects one persistent targeting priority per turret:
  - **Closest:** nearest enemy to the turret.
  - **Fastest:** highest movement speed; Closest breaks ties.
  - **Toughest:** highest maximum HP; Closest breaks ties.
- There is no manual enemy selection and no direct unit control.

### Evolution

Each enemy has one diet category. A turret records the category of every enemy it kills.

| Enemy eaten | Trait gained | Effect |
|---|---|---|
| Runner | Quick | Increased fire rate |
| Tank | Heavy | Increased shot damage |
| Swarm | Burst | Unlocks or increases splash damage |

- Turrets evolve at **6, 15, and 30 lifetime kills**.
- At each threshold, the most-killed category since the previous evolution grants its trait, then the three diet counters reset.
- Traits may repeat and stack: Quick + Quick + Heavy is valid.
- A tied diet is resolved by the category of the turret's most recent kill.
- Evolution changes combat stats immediately and produces an obvious visual and audio burst.

Initial tuning targets, to be changed through playtesting:

- Quick: 30% shorter attack cooldown.
- Heavy: 50% more shot damage.
- Burst: first stack adds a small blast radius; later stacks increase it.

### Economy

- Kills award coins; tougher enemies are worth more.
- New turrets are the only required purchase.
- Every completed wave also awards a small guaranteed stipend, preventing one weak wave from causing an unrecoverable income spiral.
- Evolution is automatic and costs nothing.

### Enemies and waves

| Enemy | Readable identity | Purpose |
|---|---|---|
| Runner | Small and fast | Feeds Quick evolution; punishes slow coverage |
| Tank | Large and slow with high HP | Feeds Heavy evolution; tests damage output |
| Swarm | Numerous and fragile | Feeds Burst evolution; overwhelms single-target fire |

- Enemies follow a fixed path and never attack turrets.
- Waves increase enemy count and HP, then introduce mixed groups.
- Speed increases should be modest so targeting and evolution remain readable.
- Early waves teach one category at a time before mixing them.

## Interface and Feedback

- HUD: coins, base HP, wave number, and Start Wave button/countdown.
- Selected turret panel:
  - Targeting buttons: Closest, Fastest, Toughest.
  - Three coloured diet counters with icons.
  - Current stacked traits.
  - Kills remaining until the next evolution.
- Enemy silhouettes and colours must clearly communicate Runner, Tank, and Swarm categories.
- A kill briefly sends a coloured essence particle from the enemy to the killing turret.
- Humorous evolution names and exaggerated sounds support the title, but must not delay the complete loop.

## Scope

### Required

- One fixed map and path.
- Free placement with range preview and collision validation.
- One basic turret with automatic targeting and projectiles.
- Three targeting priorities.
- Three enemy categories and their traits.
- Three evolution checkpoints with stacking traits.
- Coins, wave stipend, escalating waves, base HP, win, loss, and restart.
- Enough UI to understand targeting and evolution.
- Exported, tested jam build with asset credits.

### Optional, only after the complete loop is stable

- Evolution-specific turret visuals.
- Funny generated names for trait combinations.
- Endless mode or score leaderboard.
- Selling turrets.
- Additional map, enemy, trait, music, and juice.

### Out of scope

- Manual attacks or individual enemy targeting.
- Traditional purchased upgrades or multiple purchasable turret classes.
- Towers attacking towers.
- Movable soldiers, spells, bosses, branching paths, or procedural maps.
- Turrets blocking the path or enemies recalculating routes.
- Complex trait trees or bespoke implementation for every trait combination.

## Four-Day Plan

### Day 1 — Prove the hook

- Fixed path, one enemy, one turret, placement, range, shooting, and kills.
- Add three enemy tags, targeting priorities, diet counters, and one evolution threshold.
- **Exit condition:** changing targeting visibly changes which trait a turret earns.

### Day 2 — Complete the run

- Coins, turret costs, three enemy behaviours, waves, base HP, loss, restart, and victory.
- Implement all evolution checkpoints and stacked trait effects.
- **Exit condition:** the game is playable from start to finish with placeholders.

### Day 3 — Make it understandable

- Selected-turret UI, placement feedback, enemy readability, evolution effects, sound, and tuning.
- Source final assets and record credits as each asset is added.
- Export and run the build outside the editor.

### Day 4 — Stabilize and submit

- Playtest, tune economy and waves, fix blockers, and add only cheap polish.
- Prepare screenshots, description, controls, credits, and known issues.
- Upload early, download the submission, and test it again.

## Main Risks

| Assumption | Cheapest test | Response if false |
|---|---|---|
| Players can intentionally influence evolution | Prototype three targeting buttons and mixed enemies | Improve range/diet UI; do not add manual targeting |
| Evolution is noticeable and satisfying | Compare a basic turret with each first trait | Increase trait strength and audiovisual feedback |
| Last-hit credit feels predictable | Watch several overlapping turret ranges | Space placements better or count dominant damage instead |
| Losing kills does not create an economy collapse | Intentionally leak part of two waves | Increase guaranteed wave stipend |

## Open Questions

- Exact starting coins, turret cost, kill rewards, stipend, and base HP.
- Whether waves start manually or after a short countdown.
- Whether 10 waves feels complete or too long for a jam session.
- Final visual theme and available asset pack.

## Next Milestone

Build a grey-box prototype containing one path, mixed coloured enemy circles, placeable turret circles, the three targeting priorities, and the first six-kill evolution. Continue only if the player can deliberately produce Quick, Heavy, or Burst by changing targeting and placement.
