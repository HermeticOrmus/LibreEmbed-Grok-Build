---
name: comm-bus-drivers
description: "Stub, not a playbook. I2C/SPI/UART/CAN driver review, init, timeouts, error paths. Real depth: the communication-buses plugin, grok plugin install communication-buses@libre-embed-grok --trust."
---

# Comm Bus Drivers

Stub, not a playbook. Real depth: the [`communication-buses`](https://github.com/HermeticOrmus/LibreEmbed-Claude-Code/tree/main/plugins/communication-buses) plugin from LibreEmbed-Claude-Code. Install it from this marketplace: `grok plugin install communication-buses@libre-embed-grok --trust`.

I2C/SPI/UART/CAN driver review — init, timeouts, error paths.

## Steps
1. Name buses and devices.
2. Check init order and clocks.
3. Timeouts + retries without hanging ISR.
4. Error reporting to app layer.
5. Test plan on hardware.
