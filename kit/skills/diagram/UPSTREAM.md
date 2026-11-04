# Upstream

- Source: https://github.com/cathrynlavery/diagram-design (MIT, `LICENSE` here is theirs)
- Pinned commit: `f903933a534ba92cde1c85a28186267b3a317bb2`

## What this folder ships

- `SKILL.md`: rewritten in plain words. The rules (budget, connector rules,
  palette, the remove test) are hers, restated.
- `scripts/self_check.py`, `scripts/verify-geometry.py`,
  `scripts/mermaid_extract.py`: copied from upstream. Python standard library
  only, no network, no subprocess. Edits: em dashes replaced with commas, and
  one comment reworded.
- `assets/template.html`: the light template, unchanged.

## What was left out, and why

- The 57 per-type reference files and the example gallery: too much for a
  starter kit. Read them in the upstream repo when you need a type's details.
- The dark, terminal and motion templates. `self_check.py` looks for
  `assets/template-motion.html` only when a diagram contains motion markup;
  copy it from upstream if you want animated diagrams.
- Plugin, marketplace and auto-update files: auto-update means prompt changes
  arrive without anyone reviewing them.
- The full editorial page variant (big serif title, uppercase kicker, summary
  cards): it reads as generic AI design. Ship the bare diagram.
