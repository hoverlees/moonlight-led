#ifndef _RGB_LED_H
#define _RGB_LED_H

#include "driver/ledc.h"
#define RED_LED_GPIO GPIO_NUM_3
#define GREEN_LED_GPIO GPIO_NUM_4
#define BLUE_LED_GPIO GPIO_NUM_5

void rgb_led_init(void);
void rgb_led_set_color(int r, int g, int b);

#endif
