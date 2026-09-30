---
name: bare-metal-bringup
description: Bare-metal bring-up checklist for Grok Build. Use when a board will not blink, reset never reaches main, clocks or linker maps are unverified, or first UART/LED is still a guess.
---

# Bare Metal Bringup

First light on a board you own: clocks, reset, linker, stack, one observable. Truth over "it should work." Measurable findings beat vendor-demo folklore.

Gold Hat: name the first observable before you touch registers. Teach the *why* of each failed check so the next board is theirs, not a paste they cannot defend.

## When to use

- New MCU project, or a board that reset but never reached `main`
- "Why no blink / no UART" with no map file and no clock tree
- Reviewing startup, vector table, linker script, or first GPIO/UART
- Before adding an RTOS, a bus driver, or any heap

Do not use this skill as an RTOS design, OTA, or HIL pass. After first light, hand to `rtos-task-design` (melted in this pack) for tasks/IPC, and to `memory-static-alloc` / `comm-bus-drivers` (stubs) for pools and buses. Call the stub; do not invent its depth.

Stop if you cannot name the part number, the intended first observable, and whether you are allowed to flash this hardware. Guessing a clock tree is extraction.

## Operating steps

1. **Name the first observable.** LED pin, UART TX pin + baud, or a scope probe. One thing a human can see without a debugger. If unknown, ask.
2. **Confirm toolchain + flash path.** Compiler, linker script, programmer (SWD/JTAG/dfu), and the `.elf`/`.bin` you will actually write. Record the command that produced the image.
3. **Walk reset → `Reset_Handler` → data/bss init → `main` → idle.** If any hop is missing or weak-aliased to a trap, first light never happens.
4. **Check clocks, then linker, then stack.** Clock enable before peripheral writes. Map file before "maybe SRAM is too small."
5. **Prove one observable.** Blink or a known UART byte. Then teach one reusable sentence. Document residual risks.

Do not invent frequencies, flash sizes, or vector offsets. If the datasheet or map was not opened, mark **unverified**.

## Checks (measurable)

### Toolchain and image

| Check | Pass | Fail |
|-------|------|------|
| Image identity | `size`/`nm` run on the file you flash; flash/RAM totals named | "The IDE built something" with no path |
| ISA / ABI | Target flag matches the core (e.g. `-mcpu=cortex-m4 -mthumb`) | Default host `gcc` or a leftover M0 flag on an M4 |
| Flash path | Programmer talks to the part; read-back or probe confirms | Cable plugged in; no IDCODE / no write |

### Reset path

| Check | Pass | Fail |
|-------|------|------|
| Vector table | Reset vector points at `Reset_Handler` (or equivalent) at the boot address the part actually uses | Table in RAM only, or VTOR never set when the image is not at 0 |
| Init | `.data` copied from flash, `.bss` zeroed, then `main` | Globals still garbage; first C use faults |
| Unused IRQs | Weak default handler traps (`BKPT` / tight loop with IRQs off) | Unused vectors are `NULL` or fall through |

### Clocks and first peripheral

| Check | Pass | Fail |
|-------|------|------|
| Clock enable | RCC/clock bit set **and** read back (bus latency flush) before the first MMIO write | Writes to a gated peripheral that "do nothing" |
| Source | HSE/HSI/PLL choice matches the crystal that is actually populated | 8 MHz code on a 25 MHz board, or PLL lock assumed |
| First pin | Mode, AF, and pull match the schematic net | LED on the wrong port; UART AF leftover from another package |

### Linker and stack

| Check | Pass | Fail |
|-------|------|------|
| Regions | `MEMORY` flash/RAM origins match the reference manual | Script for a bigger sibling MCU |
| Stack | `_estack` at the top of SRAM; MSP set from the vector table | Stack in the middle of `.bss` |
| Map | `.text` in flash, `.bss` in RAM; overflow is a link error | "Should fit" with no `arm-none-eabi-size -A` (or vendor equivalent) |

### First observable

| Check | Pass | Fail |
|-------|------|------|
| LED | Atomic set/reset (e.g. BSRR), not a non-atomic `ODR ^=` from an ISR | Toggles in the debugger, dark on the bench |
| UART | Known byte at a named baud; TX pin scoped or terminal confirmed | `printf` with no `_write`, or poll with no timeout |
| Timebase | SysTick (or equivalent) reload derived from a **named** `SystemCoreClock` | Magic `delay` loops calibrated on another board |

## Problem → cause → first fix

| Complaint | Likely cause | First fix |
|-----------|--------------|-----------|
| Dark LED, debugger in `main` | Clock not enabled, or wrong pin | Enable GPIO clock; read the IDR/ODR of the schematic pin |
| HardFault before `main` | Bad vector / stack / data copy | Dump VTOR, SP, and `.data` LMA vs VMA from the map |
| UART noise or nothing | Wrong baud clock, wrong AF | Measure `fCK`, recompute BRR; confirm AF index for *this* package |
| Random reset | Watchdog left on, or stack smash | Disable IWDG until first light, then enable overflow hooks |
| "It worked in the vendor demo" | Demo clock tree / linker for a different board | Diff `MEMORY` and the HSE value against *your* schematic |

## Worked example — first blink + one UART byte

Job: prove STM32-class bring-up on a Nucleo-style PA5 LED and USART1 at 115200. Primary observable: LED period you can count, then the byte `0x55` on TX.

Weak:

```c
int main(void) {
    GPIOA->ODR ^= (1u << 5);
    printf("hi\n");
    for (;;) {}
}
```

No clock enable, non-atomic toggle, `printf` with no backend, no timebase, no timeout.

Stronger (principle-tagged, still board-specific — adapt pins):

```c
RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
(void)RCC->AHB1ENR; /* read-back flush */

GPIOA->MODER = (GPIOA->MODER & ~(3u << 10)) | (1u << 10); /* PA5 output */
GPIOA->BSRR  = (1u << 5);                                  /* atomic set */

/* After UART clock + AF + BRR from a named fCK: */
while (!(USART1->SR & USART_SR_TXE)) { /* cycle-count timeout here */ }
USART1->DR = 0x55u;
```

- **Clock enable:** write then read-back before GPIO/UART MMIO.
- **Atomic pin:** BSRR, not `ODR ^=` (that RMW loses bits if an ISR writes ODR).
- **Observable:** one known byte, not a formatted string that needs a C library.
- **Map:** after link, `arm-none-eabi-size -A firmware.elf` — flash/RAM totals named, not guessed.

Three concrete fixes if you only have the weak `main`: (1) enable GPIO clock and set PA5 via BSRR, (2) add a SysTick 1 ms tick from `SystemCoreClock` so the blink period is measurable, (3) send `0x55` with a timeout — then run `rtos-task-design` only if you actually need tasks.

## Output shape

```markdown
## Job
[part / board / first observable]

## Reset path
[vector → init → main] — [does it?]

## Findings
- [check] — [file or register] — [current] → [needed] (measured | unverified)

## Fixes (≤3)
1. [change] — serves [check]
2. …
3. …

## Teach
[one reusable sentence]

## Leftovers
- [skill] — [what you did not pretend to finish]
```

If first light already works, say so. Empty findings are allowed. Invented clock trees are not.

## Quality bar

A pass is done when the first observable is named, every finding points at a register/section/command, unverified numbers are marked, and leftovers go to the matching skill. Refuse "just use the HAL cube output" as a conclusion — say which clock, which pin, which map line.

## Suite

Doctrine: [grok-build-reality-os](https://github.com/HermeticOrmus/grok-build-reality-os). Gold Hat: [GOLD_HAT.md](https://github.com/HermeticOrmus/LibreEmbed-Grok-Build/blob/main/GOLD_HAT.md). Sibling Libre*-Grok-Build packs: [README suite footer](https://github.com/HermeticOrmus/LibreEmbed-Grok-Build/blob/main/README.md).
