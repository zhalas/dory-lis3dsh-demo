#!/bin/sh -e

function write_reg() {
	echo "$1" > /sys/devices/f9924000.i2c/i2c-4/4-001e/reg_addr
	echo "$2" > /sys/devices/f9924000.i2c/i2c-4/4-001e/reg_value
}

function read_reg() {
	echo "$1" > /sys/devices/f9924000.i2c/i2c-4/4-001e/reg_addr
	cat /sys/devices/f9924000.i2c/i2c-4/4-001e/reg_value
}

# using power_device instead of enable_device as this does not enable
# periodic acceleration reporting
echo 1 > /sys/devices/f9924000.i2c/i2c-4/4-001e/power_device

# this only enables INT1 on the Linux side
echo 1 > /sys/devices/f9924000.i2c/i2c-4/4-001e/enable_int1

CTRL_REG3=`read_reg 23`
if [ "$CTRL_REG3" != "0x40" -a "$CTRL_REG3" != "0x48" ]; then
	echo "CTRL_REG3 does not have expected initial value, bailing out"
	exit 1
fi
# CTRL_REG3: INT1 enabled, interrupt signal is high
write_reg 23 48

# this sets ODR
echo 10 > /sys/devices/f9924000.i2c/i2c-4/4-001e/poll_period_ms

# THRS1_1
write_reg 57 33

# THRS2_1
write_reg 56 30

# TIM1_1
write_reg 54 a

# TIM2_1
write_reg 52 50

# TIM3_1
write_reg 51 5

# CTRL_REG1: no hysteresis, state machine disabled
write_reg 21 0

# MASK1_A: only "z" axis, the one perpendicular to the watch face
write_reg 5a 4

# ST1_X (prog):
write_reg 40 5  # NOP / GNTH1
write_reg 41 28 # TI2 / LNTH2
write_reg 42 3  # NOP / TI3
write_reg 43 61 # GNTH2 / TI1
write_reg 44 11 # CONT

echo 2 > /sys/devices/f9924000.i2c/i2c-4/4-001e/enable_state_prog
