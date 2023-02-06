#include "rgb-led.h"

static void rgb_led_pwm_start(int gpio_num, ledc_channel_t channel, uint32_t duty) {
    ledc_channel_config_t ledChannelConfig;
    ledChannelConfig.gpio_num = gpio_num;
    ledChannelConfig.speed_mode = LEDC_LOW_SPEED_MODE;
    ledChannelConfig.channel = channel;
    ledChannelConfig.intr_type = 0;
    ledChannelConfig.timer_sel = LEDC_TIMER_0;
    ledChannelConfig.duty = duty;
    ledc_channel_config(&ledChannelConfig);
}

void rgb_led_init(void) {
    ledc_timer_config_t ledTimerConfig;

    gpio_reset_pin(RED_LED_GPIO);
    gpio_reset_pin(GREEN_LED_GPIO);
    gpio_reset_pin(BLUE_LED_GPIO);
    gpio_set_direction(RED_LED_GPIO, GPIO_MODE_OUTPUT);
    gpio_set_direction(GREEN_LED_GPIO, GPIO_MODE_OUTPUT);
    gpio_set_direction(BLUE_LED_GPIO, GPIO_MODE_OUTPUT);
    gpio_set_level(RED_LED_GPIO, 0);
    gpio_set_level(GREEN_LED_GPIO, 0);
    gpio_set_level(BLUE_LED_GPIO, 0);

    ledTimerConfig.duty_resolution = LEDC_TIMER_13_BIT;
    ledTimerConfig.freq_hz = 5000;
    ledTimerConfig.speed_mode = LEDC_LOW_SPEED_MODE;
    ledTimerConfig.timer_num = LEDC_TIMER_0;
    ledTimerConfig.clk_cfg = LEDC_AUTO_CLK;
    ledc_timer_config(&ledTimerConfig);
}

static void update_channel_duty(int gpio_num, ledc_channel_t channel, uint32_t duty) {
    if (duty == 0) { //停止pwm, GPIO低电平
        ledc_stop(LEDC_LOW_SPEED_MODE, channel, 0);
    }
    else {
        rgb_led_pwm_start(gpio_num, channel, duty);
        ledc_set_duty(LEDC_LOW_SPEED_MODE, channel, duty);
        ledc_update_duty(LEDC_LOW_SPEED_MODE, channel);
    }
}

void rgb_led_set_color(int r, int g, int b) {
    int duty = 8191*r/255;
    update_channel_duty(RED_LED_GPIO, LEDC_CHANNEL_0, duty);

    duty = 8191*g/255;
    update_channel_duty(GREEN_LED_GPIO, LEDC_CHANNEL_1, duty);

    duty = 8191*b/255;
    update_channel_duty(BLUE_LED_GPIO, LEDC_CHANNEL_2, duty);
}