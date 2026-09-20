---
name: rtos-task-design
description: RTOS task design for Grok Build — priorities, IPC, stack sizing, inversion and starvation guards. Use when adding tasks, sizing queues, or debugging "task X never runs."
---

# Rtos Task Design

Task graph, priorities, IPC, stacks, and the inversion/starvation bugs code review misses. Real rates and budgets beat "looks like FreeRTOS."

Gold Hat: refuse invented sample rates. Teach *why* this primitive and this priority so the next task they add does not steal the deadline.

## When to use

- New multi-task firmware, or adding a task to a running system
- "Task X never runs," "stalls under load," or "works alone, fails together"
- Choosing mutex vs queue vs notification vs event group
- Sizing stacks or deciding watchdog kick policy

Do not use this as first-light bring-up (`bare-metal-bringup`, melted), heap/pool accounting (`memory-static-alloc`, stub), or on-target proof (`embedded-test-hil`, stub). Call the stub; do not invent its depth.

This skill is RTOS-agnostic. Name FreeRTOS or Zephyr primitives when the tree already picked one. Do not certify a design — that is a safety process, not a skill pass.

## Operating steps

1. **Restate the concurrent jobs** with numbers you were given: rates, payload sizes, latency budgets, who blocks. If a number is missing, ask. Do not invent Hz.
2. **Draw the minimum task graph.** One task per *truly* concurrent activity (different rate, deadline, or blocking pattern) — not one task per noun.
3. **Assign priorities with a reason.** Highest = must-run-on-time followers of ISRs / control loops. Lowest = health/housekeeping. Idle stays idle.
4. **Pick IPC from the table.** Size for the worst burst the problem statement implies, not the mean.
5. **Name inversion, starvation, and stack risks.** Then the first three fixes. Teach one reusable rule.

Stop if the only input is "add an RTOS." Demand the jobs.

## Checks (measurable)

### Task graph

| Check | Pass | Fail |
|-------|------|------|
| Count | Minimum tasks that separate rates/deadlines/blocking | Sensor-read task *and* sensor-process task with no concurrency |
| Idle | Idle (or equivalent) is not doing product work | `vTaskDelay` loops inside idle hooks as the architecture |
| Create | Every `xTaskCreate` / `k_thread_create` return checked | Handles assumed valid |

### Priority

| Check | Pass | Fail |
|-------|------|------|
| Rationale | Each priority names the deadline it protects | Sequential integers "so they are different" |
| Top of stack | Highest prio is ISR-follower or hard loop | Telemetry or logging at the top |
| Busy-run | No high-prio task spins without a bound | `while (1) { poll(); }` at prio 5 |

Heuristic (adapt names; keep the shape):

```
highest: ISR follower (notify → short work)
       : hard realtime worker (motor / control)
       : throughput worker (log / stream)
       : background (telemetry)
lowest : health / watchdog / housekeeping
idle   : reserved
```

### IPC primitive

| Use case | Primitive | Not this |
|----------|-----------|----------|
| Shared mutable state | Mutex with inheritance (or ceiling) | Counting semaphore used as a lock |
| N identical units | Counting semaphore | Mutex around a hand-rolled counter you forgot |
| ISR → task "it happened" | Task notify / `k_sem_give` from ISR | `printf` or a mutex in the ISR |
| Producer → consumer + data | Queue or stream/message buffer | Unprotected global + `volatile` hope |
| One of N events | Event group | N binary semaphores you never OR |

| Check | Pass | Fail |
|-------|------|------|
| Burst | Queue depth ≥ worst burst named in the problem | Depth 1 because "we process fast" |
| ISR | ISR path is FromISR / ISR-safe give only | Mutex take in IRQ |
| Inheritance | Mutexes that can invert use PI or ceiling | Binary sem as mutex on a core that has no PI |

### Priority inversion

Three forms. Name which one you found.

1. **Unbounded** — H waits for R held by L; M (between them) preempts L. H waits as long as M runs. Fix: inheritance or ceiling.
2. **Bounded** — H waits only for L's critical section. Fix: keep that section short; no sleep, no log, no I/O while holding R.
3. **Chain** — H waits L1 waits L2. Fix: ceiling on the chain, or collapse to one lock / message passing.

| Check | Pass | Fail |
|-------|------|------|
| Hold time | Critical sections bounded and named | Lock held across I2C, flash, or `printf` |
| Graph | Who takes which lock is listed | "We have a mutex so we are fine" |

### Stack and watchdog

| Check | Pass | Fail |
|-------|------|------|
| Size method | Call-graph + ISR nest + FPU lazy-stack (if used) + margin, **or** high-water measured | `1024` because that is the demo |
| Overflow hook | `configCHECK_FOR_STACK_OVERFLOW` / Zephyr stack sentinel enabled in debug | Silent wrap |
| Kick policy | Named pattern: idle kicker, heartbeat aggregator, or window WWDG | Kick from every path "to be safe" (hides hangs) |

Stack recipe (do not skip the measure):

1. `-fstack-usage` (or vendor equivalent) per function.
2. Deepest path from the task entry.
3. Add worst nested ISR stack (and 132 bytes on Cortex-M FPU lazy stack if FP is used).
4. Margin: 1.3 if ISR worst-case is measured; 1.5 if it is not. Say which.
5. Confirm at runtime: `uxTaskGetStackHighWaterMark` / `k_thread_stack_space_get`.

Watchdog patterns (pick one; say what it catches and misses):

- **Single low-prio kicker** — catches total hang; misses one-task death.
- **Heartbeat aggregator** — catches a silent task; misses "all heartbeats, no progress."
- **Window watchdog** — catches runaway kick loops; needs a real period.

### ISR hand-off

ISR does the minimum: clear the source, give a notify/sem, yield if needed. Heavy work in a task.

Do not: `printf` in ISR, take a mutex in ISR, do FP in ISR unless lazy stacking is configured, or leave IRQs disabled across a long section.

## Worked example — IMU sample + telemetry

Job (given): 1 kHz IMU sample, 100-byte sample, 10 ms control deadline, 1 Hz telemetry of last sample, I2C bus shared with an EEPROM writer at 10 Hz. MCU: Cortex-M4, FreeRTOS, inheritance mutexes available.

Weak:

```c
void vTask1(void *p) {
    for (;;) {
        imu_read();          /* blocks on I2C */
        log_uart();          /* holds a lock */
        eeprom_save();
        vTaskDelay(1);
    }
}
```

One task, three rates, lock + I/O mixed, delay-as-scheduler, no burst math.

Stronger graph:

| Task | Rate / deadline | Prio | IPC |
|------|-----------------|------|-----|
| `ImuTask` | 1 kHz, 10 ms | high | I2C mutex (short), notify from EXTI ISR |
| `EepromTask` | 10 Hz | mid | same I2C mutex; never hold across page wait if avoidable |
| `TelemTask` | 1 Hz | low | queue depth ≥ 1 latest sample (overwrite / last-wins) |
| `HealthTask` | kick window | lowest | heartbeat table from the three workers |

Critique of the weak loop:

```markdown
## Job
1 kHz IMU, 10 ms control, 1 Hz telem, shared I2C. Primary: samples must not miss the deadline.

## Findings
1. **Critical — graph.** One task serializes 1 kHz and EEPROM. EEPROM page delay unbounded vs 10 ms.
   Remediation: split Imu vs Eeprom; ISR notify → ImuTask.
2. **High — inversion.** UART log inside the I2C critical section. Telem (if later raised) plus EEPROM writer can invert Imu.
   Remediation: copy sample out; log without the I2C mutex.
3. **High — IPC.** No queue/notify; `vTaskDelay(1)` is not 1 kHz.
   Remediation: EXTI → `vTaskNotifyGiveFromISR`; telem reads last sample via a 1-slot overwrite queue.
4. **Medium — stack (unverified).** No `.su` / high-water. Do not claim 1 KiB is enough.

## Fixes now
1. DIP: EXTI ISR notifies ImuTask; ISR does not talk I2C.
2. I2C mutex with inheritance; hold only for the transaction.
3. Heartbeat aggregator — Imu miss must not kick the IWDG.

## Leftovers
Pool/heap budget → `memory-static-alloc` (stub). On-target rates → `embedded-test-hil` (stub).
```

That is a design: numbers from the ask, primitives with reasons, leftovers named. Not a `/rtos` theater card.

## Output shape

```markdown
## Job
[rates / payloads / deadlines / who blocks] (given | inferred — say which)

## Task graph
| Task | Rate/deadline | Prio | IPC | Stack basis |

## Findings
- [inversion|starvation|ipc|stack|watchdog] — [where] — [why] → [needed]

## Fixes (≤3)
1. …
2. …
3. …

## Teach
[one reusable sentence]

## Leftovers
- [skill] — [unmeasured rate, unrun high-water, uncertified safety]
```

If the graph is already minimal and inversion-safe, say so. Empty findings are allowed. Invented kHz are not.

## Quality bar

A pass is done when every task has a reason, every lock names its holders, queue depth cites a burst, and unverified timing is marked. Refuse "just raise the priority" without a deadline. Cortex-M0 FreeRTOS ports that lack inheritance — say so if that is the core.

## Suite

Doctrine: [grok-build-reality-os](https://github.com/HermeticOrmus/grok-build-reality-os). Gold Hat: [GOLD_HAT.md](https://github.com/HermeticOrmus/LibreEmbed-Grok-Build/blob/main/GOLD_HAT.md). Sibling Libre*-Grok-Build packs: [README suite footer](https://github.com/HermeticOrmus/LibreEmbed-Grok-Build/blob/main/README.md).
