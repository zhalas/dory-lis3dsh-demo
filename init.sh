#!/bin/sh -e
echo 1 > /sys/devices/f9924000.i2c/i2c-4/4-001e/enable_device
echo 1 > /sys/devices/f9924000.i2c/i2c-4/4-001e/enable_int1
echo 23 > /sys/devices/f9924000.i2c/i2c-4/4-001e/reg_addr
CTRL_REG3=`cat /sys/devices/f9924000.i2c/i2c-4/4-001e/reg_value`
if [ "$CTRL_REG3" != "0x40" -a "$CTRL_REG3" != "0x48" ]; then
	echo "CTRL_REG3 does not have expected initial value, bailing out"
	exit 1
fi
echo 48 > /sys/devices/f9924000.i2c/i2c-4/4-001e/reg_value
echo 2 > /sys/devices/f9924000.i2c/i2c-4/4-001e/enable_state_prog
