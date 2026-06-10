---
description: Summarize the current chat into one copy-paste handoff prompt
---

# Relay Hand-off

We are moving to a new thread. Your **entire response** must be exactly one fenced code block — nothing else. No preamble, no summary outside the block, no duplicate sections.

## Rules (strict)

- Output **ONLY** a single fenced code block. No text before or after it.
- Do **not** output OBJECTIVE, CONTEXT, CHECKLIST, or EDGE CASES as separate sections outside the code block.
- Do **not** duplicate content: everything the next chat needs goes **only** inside the block.
- The block must be self-contained. Assume the next AI has zero prior context.
- Use plain text inside the block (markdown headings inside the block are fine).
- Do not nest code blocks inside the handoff block.
- Keep the handoff under ~400 words unless the task is genuinely large or complex.
- End the block with an **IMMEDIATE TASK** section that tells the next AI to switch to Agent mode and implement.
- Include in IMMEDIATE TASK: **Do not commit unless explicitly asked.**

## Required structure inside the single block

Use these headings in order:

### OBJECTIVE

One short paragraph: what we are building/fixing and current status (diagnosed vs implemented).

### CONTEXT

Exact file paths, node/scene structure, relevant constants, and how the affected code works today.

### GRANULAR CHECKLIST

Numbered, chronological implementation steps the next session should execute in order.

### EDGE CASES

Project-specific risks (e.g. Godot `_ready()` order, TileSet atlas config, node pooling, memory leaks with custom objects).

### IMMEDIATE TASK

The first concrete action for the next chat (e.g. edit file X, apply change Y, verify Z). Must end with: **Switch to Agent mode and implement.** Include: **Do not commit unless explicitly asked.**

Include enough detail that pasting this block alone lets the next AI start coding without reading the previous chat.
