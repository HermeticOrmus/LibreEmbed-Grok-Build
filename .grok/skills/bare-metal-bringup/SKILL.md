---
name: bare-metal-bringup
description: Bare-metal bring-up checklist: clocks, reset, linker, first blink.
---

# Bare Metal Bringup

Bare-metal bring-up checklist: clocks, reset, linker, first blink.

## Steps
1. Confirm toolchain + flash path.
2. Map reset → main → idle.
3. Check linker sections / stack.
4. First observable (LED/UART).
5. Document residual risks.
