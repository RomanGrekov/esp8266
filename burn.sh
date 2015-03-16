#!/bin/bash

sudo ../esp8266_tools/esptool-master/esptool.py --port /dev/tty$1 write_flash 0x000000 images/nodemcu_latest.bin

