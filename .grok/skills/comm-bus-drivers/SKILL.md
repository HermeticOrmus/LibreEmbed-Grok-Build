---
name: comm-bus-drivers
description: I2C/SPI/UART/CAN driver review — init, timeouts, error paths.
---

# Comm Bus Drivers

I2C/SPI/UART/CAN driver review — init, timeouts, error paths.

## Steps
1. Name buses and devices.
2. Check init order and clocks.
3. Timeouts + retries without hanging ISR.
4. Error reporting to app layer.
5. Test plan on hardware.
