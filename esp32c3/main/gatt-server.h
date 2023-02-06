#ifndef _GATT_SERVER_H
#define _GATT_SERVER_H

#include <stdio.h>
#include "freertos/FreeRTOS.h"
extern void on_ble_rgb_set(uint8_t red, uint8_t green, uint8_t blue);
extern void on_ble_fadeout_set(uint32_t durationSeconds);
extern void on_ble_set_opt(uint8_t opt);
void gatt_server_init();
void gatt_server_set_char1(uint8_t r, int g, int b);
void gatt_server_set_char2(uint32_t fadeOutSeconds);

#endif
