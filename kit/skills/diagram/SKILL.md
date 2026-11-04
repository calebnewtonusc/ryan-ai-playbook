---
name: diagram
description: "Draw a diagram as one self-contained HTML file with inline SVG, checked locally: architecture, flowchart, sequence, state, database schema, timeline, simple charts. Use to draw, diagram, map out or visualize a system or process, or to redraw a Mermaid diagram."
license: MIT
---

# Diagram

Draw a diagram by hand-writing SVG into one HTML file, then check it with two
small scripts. Nothing is sent to an outside service, so this is safe for
private numbers and internal systems.

The method and the checker scripts come from Cathryn Lavery's diagram-design
(MIT). What was kept and changed is in [UPSTREAM.md](UPSTREAM.md). Her full
set of per-type guides lives at https://github.com/cathrynlavery/diagram-design.

## 1. Decide whether to draw at all

Usually the best diagram is no diagram. Skip it when:

- it is a list of things (use a list or a table)
- a three-column table says the same thing
- it is one box (write the sentence)
- only details change between before and after (use a table)

**Before drawing, write one sentence: what should a reader understand from
this picture that they would miss in a paragraph?** If you cannot write it,
do not draw.

## 2. Pick the type

| Showing                                  | Type            |
| ---------------------------------------- | --------------- |
| Parts of one system and how they connect | Architecture    |
| Decisions with branches                  | Flowchart       |
| Messages between actors over time        | Sequence        |
| States and what moves between them       | State machine   |
| Tables, columns, keys                    | Database schema |
| Handoffs between people or teams         | Swimlane        |
| Events in time                           | Timeline        |
| Two-axis positioning                     | Quadrant        |
| Parent and children                      | Tree            |
| Comparing categories                     | Bar chart       |

If two types fit, pick the one whose main direction (time, hierarchy, flow)
carries the meaning. State the type and anything you will leave out, in one
line, before drawing.

## 3. Stay inside the budget

| Limit                               | Per diagram |
| ----------------------------------- | ----------- |
| Boxes                               | 9           |
| Arrows                              | 12          |
| Highlighted (accent color) elements | 2           |
| Callout notes                       | 2           |

Over budget means two diagrams: an overview and a detail. Put positions on a
4px grid.

## 4. Six connector rules

1. Arrows that change direction use right-angle elbows with rounded corners.
   A straight line only when both ends line up. No diagonals.
2. Every arrow label (short, 14 characters or fewer) sits on a solid
   background patch, a little clear of its line.
3. Arrows never overlap. Parallel arrows run 12px apart.
4. Several arrows leaving one side of a box spread out evenly along it.
5. An arrow never passes behind a box that is not one of its ends.
6. A label's background patch never overlaps a box drawn after it.

Draw arrows first, then labels, then boxes, so lines sit behind boxes.

## 5. Look

- Background `#f5f5f5`, text `#2d3142`, secondary `#4f5d75`, one accent
  `#eb6c36` used on two things at most.
- Geist for box names, Geist Mono only for technical text (ports, commands,
  URLs, arrow labels).
- No drop shadows. Corner radius 6 to 10px. The legend sits as a strip along
  the bottom.

Signs of a generated-looking diagram: dark mode with neon glow, monospace
everywhere, every box identical, the accent color on everything, labels with
no background, text running vertically along arrows.

## 6. Make one

1. Copy `assets/template.html` to your project as `my-diagram.html`.
2. Replace the title, the SVG body, every `[diagram-slug]`, the `<title>` (60
   characters or fewer) and the `<desc>` (one sentence on what it shows).
3. Keep the SVG's `min-width` equal to its viewBox width inside the scrolling
   wrapper, so a phone scrolls the diagram instead of squashing it.
4. Run the checks below.

## 7. Check it

From this skill's folder:

```sh
python3 scripts/self_check.py path/to/my-diagram.html      # accessibility and single-file safety
python3 scripts/verify-geometry.py path/to/my-diagram.html # labels hidden behind boxes
```

Both exit 0 on a clean file. Rules 1 to 5 have no checker, so read the
connectors yourself. Then open the file in a browser at full width and at
phone width (375px).

Last, the remove test, done by you: can any box, arrow or label go without
the reader losing anything? Can two boxes merge? Explain your answer for each
one you keep.

## Redrawing a Mermaid diagram

Redraw, never convert. Pull out the content and draw it fresh under the rules
above:

```sh
python3 scripts/mermaid_extract.py diagram.mmd
```

It prints the nodes, edges, likely diagram types and whether it fits the
budget. It never runs anything inside the Mermaid file.
