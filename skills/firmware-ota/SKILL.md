---
name: firmware-ota
description: OTA / dual-bank / rollback hygiene for Grok Build. Use when reviewing field updates, A/B slots, confirm-after-self-test, or power-loss safety. Never embed real keys.
---

# Firmware Ota

Field update hygiene: how the image gets to a spare bank, how it is checked, when it becomes permanent, and how the device comes back if power dies mid-write. Checklists beat "we have MCUBoot."

Gold Hat: the person in the field owns the brick risk. Teach the *why* of confirm-after-self-test and power-loss atomicity so they can refuse a cute single-bank flash.

## When to use

- Adding or reviewing OTA / FOTA / USB-DFU / serial update on a device you own
- Dual-bank, A/B, or MCUBoot-style slots without a named rollback trigger
- "We hash the image" with no anti-rollback and no confirm
- Writing the first field-failure telemetry for success/fail

Do not use this as a bring-up (`bare-metal-bringup`), protocol-picker (`iot-protocol-pick`, stub), energy budget (`power-budget`, stub), or HIL flash loop (`embedded-test-hil`, stub). Do not write exploit steps, key material, or a bypass of signing.

Never paste live signing keys, device certs, or production endpoint secrets into the skill output. Placeholders only (`KEY_ID`, `slot1`, `sha256:...`).

## Operating steps

1. **Name the update path.** Transport (UART/USB/BLE/MQTT/HTTP), who writes flash, which slot is inactive, who swaps. If single-bank in-place on a product that cannot be bench-recovered, say the brick risk out loud.
2. **Walk verify → write → confirm → rollback.** Integrity (hash/signature, high-level), alignment, boot counter, self-test, previous-slot restore.
3. **Power-loss and anti-rollback.** State lives in NVM or backup domain, not RAM. Older images than the committed version are rejected.
4. **Telemetry.** Success, fail-verify, fail-write, rollback — counters a human can read. No secrets in the payload.
5. **Three concrete fixes.** Teach one reusable rule. Hand leftovers to stubs.

Do not invent a signature scheme or claim "secure boot" unless the tree shows a verifier and a key story (without the key).

## Checks (measurable)

### Path and slots

| Check | Pass | Fail |
|-------|------|------|
| Slots | Two (or more) banks/slots; write hits the **inactive** one | In-place overwrite of the only running image on an unrecoverable device |
| Size | Image + header ≤ slot; write refused past the end | "It is smaller than flash" with no slot length |
| Bootloader vs app | Who parses the header and who jumps is named | App "OTA" that erases its own vector table |

Single-bank is allowed only when (a) a hardware recovery path exists (SWD, ROM dfu) **and** (b) the user accepts brick-on-power-loss. Write that acceptance down.

### Integrity (high-level)

| Check | Pass | Fail |
|-------|------|------|
| Hash | Image hash checked before mark-bootable | Length-only, or hash after jump |
| Signature | Asymmetric verify against a **key id** in the tree, or an honest "unsigned lab build" label | "We should add signing later" on a field device |
| Version | Monotonic compare vs committed version (anti-rollback) | Any image with a valid header is accepted |

Talk about *that* a verify step exists, which algorithm the project already chose, and where the public key lives. Do not generate keys here. Do not describe how to strip or bypass a verifier.

### Confirm and rollback

| Check | Pass | Fail |
|-------|------|------|
| Confirm | After **self-test** (sensors, radio, or the product's must-work set), not after first instruction in `main` | `ota_confirm()` as line 1 of `main` |
| Boot counter | Stored in NVM / RTC backup / OTP-equivalent; survives reset | Counter in `.bss` |
| Trigger | N failed boots → swap to previous + reset | No previous slot, or swap with no bound |
| Window | Confirm deadline named (e.g. 30 s of health) | Eternal "pending" that never rolls back |

### Power-loss and write

| Check | Pass | Fail |
|-------|------|------|
| Atomic mark | Slot state (empty / writing / ready / confirmed) updates **after** a complete page/header write | "Ready" bit set, then bytes streamed |
| Alignment | Writes gathered to the MCU's min program unit; pad `0xFF` | Byte-at-a-time to a word-program flash |
| Resume | Interrupted write leaves the inactive slot invalid; boot stays on the confirmed slot | Resume into a half-written header treated as bootable |
| Erase | Inactive slot erased before program; erase failure aborts | Erase of the running slot |

### Field signals

| Check | Pass | Fail |
|-------|------|------|
| Outcomes | Distinct codes: verify-fail, write-fail, boot-loop, confirm-ok | Boolean "updated" |
| Secrets | No keys, tokens, or raw image in logs | PEM in UART |

## Problem → cause → first fix

| Complaint | Likely cause | First fix |
|-----------|--------------|-----------|
| Bricked after a drop | Confirm-on-boot or single-bank | Confirm after self-test; keep the last good slot |
| Loops new image 3× then dies | Rollback has no previous, or both slots bad | Never overwrite last-confirmed until new is confirmed |
| "Signed" but old malware boots | No anti-rollback | Reject `new_ver < committed_ver` |
| Corrupt after brownout | Ready flag before last page | Sequence: write body → write header/magic last → then pending |
| Can't tell field failures | No outcome enum | Four counters, no payload secrets |

## Worked example — pending image + boot counter

Job: dual-bank MCU, serial OTA. Primary: a bad image or a mid-write unplug must boot last-confirmed.

Weak:

```c
void ota_apply(void) {
    flash_erase(APP_BASE, image_len);
    flash_write(APP_BASE, image, image_len);
    NVIC_SystemReset();
}

int main(void) {
    ota_confirm_image(); /* first line */
    app();
}
```

Running slot erased, no hash, confirm-before-self-test, no counter.

Stronger shape (illustrative — adapt to MCUBoot/MCUboot-compat or a vendor A/B API; no keys in the file):

```c
/* Bootloader: if pending && boot_count >= 3 → activate previous slot. */
void bootloader_check_rollback(void) {
    if (!image_pending_confirm()) { return; }
    if (backup_boot_count() >= 3u) {
        activate_previous_slot();
        backup_boot_count_set(0);
        NVIC_SystemReset();
    }
    backup_boot_count_add(1);
}

/* App: only after the product self-test passes. */
void ota_confirm_after_self_test(bool sensors_ok) {
    if (!sensors_ok) { return; }
    mark_image_confirmed();
    backup_boot_count_set(0);
}
```

- **Inactive write:** body to the other bank; magic/header last so a cut cable cannot look valid.
- **Verify:** compare length + hash (and signature if the project already has a key id) **before** pending.
- **Anti-rollback:** `new_ver >= committed_ver` from NVM.
- **Confirm:** after the same checks a human would use to ship the board — not "we reached `main`."

Three concrete fixes if you only have the weak `ota_apply`: (1) write the inactive slot only, (2) move confirm behind self-test + boot counter in backup/NVM, (3) refuse images past slot end and older than committed — then `embedded-test-hil` (stub) for a power-cut-during-write loop, `power-budget` (stub) if radio OTA energy matters.

## Output shape

```markdown
## Job
[device / transport / slots / who can recover a brick]

## Path
[inactive write → verify → pending → self-test → confirm | rollback]

## Findings
- [slots|integrity|confirm|power-loss|telemetry] — [where] — [why] → [needed]

## Fixes (≤3)
1. …
2. …
3. …

## Teach
[one reusable sentence]

## Leftovers
- [skill] — [unsigned lab exception, unrun power-cut test, unmeasured radio energy]
```

If the update path is already dual-bank, verified, and confirm-after-self-test, say so. Do not invent a "secure boot score."

## Quality bar

A pass is done when brick cases are named, confirm is after a real self-test, power-loss leaves the last-good slot bootable, and no secret appears in the answer. Refuse a request to bypass signing or to recover keys. High-level hygiene only.

## Suite

Doctrine: [grok-build-reality-os](https://github.com/HermeticOrmus/grok-build-reality-os). Gold Hat: [GOLD_HAT.md](https://github.com/HermeticOrmus/LibreEmbed-Grok-Build/blob/main/GOLD_HAT.md). Sibling Libre*-Grok-Build packs: [README suite footer](https://github.com/HermeticOrmus/LibreEmbed-Grok-Build/blob/main/README.md).
