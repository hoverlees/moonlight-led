#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "driver/ledc.h"
#include "nvs_flash.h"
#include "nvs.h"
#include "esp_sleep.h"
#include "esp_log.h"
#include "sdkconfig.h"
#include "rgb-led.h"
#include "gatt-server.h"

#define APP_TAG "app"
#define MAX_IDLE_MILLIS 1800000
static uint8_t fadeOutRunning = 0;
static uint32_t fadeOutSeconds = 0;
static int64_t fadeOutTotalMillis = 0;
static int64_t fadeOutRemainMillis = 0;
static int64_t idleRemainMillis = 0;
static uint8_t ledRed = 0xFF;
static uint8_t ledGreen = 0xFF;
static uint8_t ledBlue = 0xFF;

static nvs_handle_t app_nvs_handle = 0;

static void save_settings() {
    uint8_t buf[7];
    if (app_nvs_handle == 0) {
        return;
    }
    buf[0] = ledRed;
    buf[1] = ledGreen;
    buf[2] = ledBlue;
    buf[3] = (fadeOutSeconds>>0) & 0xff;
    buf[4] = (fadeOutSeconds>>8) & 0xff;
    buf[5] = (fadeOutSeconds>>16) & 0xff;
    buf[6] = (fadeOutSeconds>>24) & 0xff;
    nvs_set_blob(app_nvs_handle, "config", buf, 7);
}

void on_ble_rgb_set(uint8_t red, uint8_t green, uint8_t blue) {
    ledRed = red;
    ledGreen = green;
    ledBlue = blue;
    rgb_led_set_color(red, green, blue);
}

void on_ble_fadeout_set(uint32_t durationSeconds) {
    fadeOutSeconds = durationSeconds;
    if (fadeOutSeconds == 0xFFFFFFFF) {
        fadeOutRunning = 0;
        idleRemainMillis = 0;
        return;
    }
    fadeOutTotalMillis = durationSeconds;
    fadeOutTotalMillis *= 1000;
    fadeOutRemainMillis = fadeOutTotalMillis;
    fadeOutRunning = 1;
    idleRemainMillis = MAX_IDLE_MILLIS;
}

void on_ble_set_opt(uint8_t opt) { //目前只使用bit0, 如果为1表示保存设置，如果为0表示不保存设置。
    if (opt & 1) {
        save_settings();
    }
}

static void load_settings() {
    uint8_t buf[7]; // red, green, blue, fadeOutSeconds[0], fadeOutSeconds[1], fadeOutSeconds[2], fadeOutSeconds[3]
    size_t len = 7;
    uint32_t fadeOutSeconds;
    esp_err_t err = nvs_flash_init();
    if (err == ESP_ERR_NVS_NO_FREE_PAGES || err == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        nvs_flash_erase();
        nvs_flash_init();
    }
	nvs_open("moonlight", NVS_READWRITE, &app_nvs_handle);
    if (err != ESP_OK) {
		ESP_LOGI(APP_TAG, "can't open nvs.\n");
		return;
	}
    err = nvs_get_blob(app_nvs_handle, "config", buf, (size_t*) &len);
	if (err != ESP_OK) {
		buf[0] = 0xFF;
        buf[1] = 0x66;
        buf[2] = 0x00;
        buf[3] = 0x58;
        buf[4] = 0x02;
        buf[5] = buf[6] = 0;
	}
    on_ble_rgb_set(buf[0], buf[1], buf[2]);
    gatt_server_set_char1(ledRed, ledGreen, ledBlue);
    fadeOutSeconds = buf[3] + (buf[4]<<8) + (buf[5]<<16) + (buf[6]<<24);
    gatt_server_set_char2(fadeOutSeconds);
    on_ble_fadeout_set(fadeOutSeconds);
}

void app_main(void) {
    uint64_t tmp;
    uint8_t r,g,b;

    rgb_led_init();
    gatt_server_init();

    load_settings();

    while (1) {
        if (!fadeOutRunning) {
            if (idleRemainMillis > 0) {
                idleRemainMillis -= 10;
                if (idleRemainMillis <=0) {
                    idleRemainMillis = 0;
                    //Go to sleep mode
                    esp_deep_sleep_start();
                }
            }
            vTaskDelay(pdMS_TO_TICKS(10));
            continue;
        }

        tmp = fadeOutRemainMillis*ledRed;
        r = tmp/fadeOutTotalMillis;
        tmp = fadeOutRemainMillis*ledGreen;
        g = tmp/fadeOutTotalMillis;
        tmp = fadeOutRemainMillis*ledBlue;
        b = tmp/fadeOutTotalMillis;

        rgb_led_set_color(r, g, b);
        
		vTaskDelay(pdMS_TO_TICKS(10));
        fadeOutRemainMillis -= 10;
        if (fadeOutRemainMillis<0) {
            fadeOutRunning = 0;
        }
	}
}
