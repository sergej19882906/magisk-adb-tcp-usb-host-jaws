# ADB TCP + USB Host for Xiaomi Jaws

[English version](README.md)

Специализированный Magisk-модуль для Xiaomi `MiTV-AFKR0` (`jaws`), который оставляет внешний USB-A в host-режиме для накопителя и одновременно поддерживает ADB по TCP-порту `5555`.

## Аппаратное ограничение

У устройства один внешний dual-role USB-канал. Через один физический порт невозможно одновременно предоставить компьютеру USB ADB и быть USB-хостом для флешки. Модуль использует:

- USB host для флешки;
- ADB по локальной сети.

USB-хаб не устраняет ограничение ролей host/device.

## Совместимость

Установщик намеренно принимает только:

- product device: `jaws`;
- SoC: `AMLS905X4`;
- доступный vendor-переключатель `/sys/class/gpio/gpio474/direction`.

Проверено на:

- Xiaomi `MiTV-AFKR0`;
- Android 14 / семейство сборок `UKG3`;
- Magisk 31.1;
- SELinux enforcing;
- FAT32-флешке, смонтированной Android StorageManager.

Не обходите проверку совместимости на другом устройстве. GPIO 474 и триггер `ro.boot.otg_device` специфичны для этой платы и семейства прошивок.

## Предупреждение о безопасности

ADB TCP слушает сетевые интерфейсы на порту `5555`. Используйте его только в доверенной локальной сети:

- не пробрасывайте порт `5555` из роутера в интернет;
- не отключайте RSA-аутентификацию ADB;
- контролируйте список авторизованных компьютеров;
- отключайте или удаляйте модуль, когда сетевой ADB больше не нужен.

Модуль не меняет ADB root, authentication, TLS, persistent USB properties, gadget/configfs или firewall.

## Установка

1. Скачайте устанавливаемый ZIP и `SHA256SUMS` из последнего [релиза GitHub](https://github.com/sergej19882906/magisk-adb-tcp-usb-host-jaws/releases/latest).
2. Проверьте контрольную сумму ZIP.
3. Установите ZIP через **Magisk → Модули → Установить из хранилища**.
4. Перезагрузите устройство.
5. Подключитесь по сети:

```sh
adb connect DEVICE_IP:5555
```

Не устанавливайте автоматически созданный GitHub-архив **Source code**. Используйте ZIP, приложенный к релизу.

## Проверка

Замените `DEVICE_IP` адресом Android TV:

```sh
adb connect DEVICE_IP:5555
adb -s DEVICE_IP:5555 shell getprop init.svc.adbd
adb -s DEVICE_IP:5555 shell getprop service.adb.tcp.port
adb -s DEVICE_IP:5555 shell cat /sys/class/gpio/gpio474/direction
adb -s DEVICE_IP:5555 shell sm list-volumes all
```

Ожидается:

- `adbd`: `running`;
- порт ADB: `5555`;
- направление GPIO: `out`;
- флешка отображается как смонтированный public volume.

Журнал модуля:

```sh
su -c 'cat /data/adb/modules/adb_tcp_usb_host_jaws/service.log'
```

## Как это работает

Late-start service поддерживает три runtime-инварианта:

1. `service.adb.tcp.port=5555`;
2. `ro.boot.otg_device=2`;
3. `adbd` работает, vendor GPIO сообщает `out`.

Когда требуется исправление, модуль один раз перезапускает `adbd`, чтобы vendor init-правило Xiaomi применило USB host-переключатель. Watchdog проверяет состояние каждые 30 секунд и не перезапускает `adbd`, когда всё уже настроено.

Все изменения действуют только до перезагрузки. Модуль не записывает persistent USB/ADB properties.

## Отключение и удаление

1. **Безопасно извлеките флешку в настройках Android.**
2. Отключите или удалите модуль в Magisk.
3. Перезагрузитесь.

Не переключайте порт обратно в device-режим, пока файловая система смонтирована. Скрипт удаления только останавливает watchdog; штатная USB-роль вернётся после перезагрузки.

## Решение проблем

### После загрузки ADB кратковременно отключается

Один короткий разрыв ожидаем: `adbd` перезапускается для применения TCP и host-режима. После этого watchdog поддерживает работу daemon.

### Флешка не монтируется

Проверьте питание, поддержку файловой системы и Android StorageManager:

```sh
sm list-disks
sm list-volumes all
```

Дискам с высоким потреблением может понадобиться активный USB-хаб. Хаб всё равно не позволит одновременно использовать USB ADB и USB host.

### Сетевой ADB не возвращается

Проверьте Wi-Fi/Ethernet и порт `5555`. При необходимости через локальный интерфейс Android отключите модуль и перезагрузитесь. Модуль намеренно не ослабляет ADB-аутентификацию и не меняет firewall.

## Сборка из исходников

Единственная зависимость — Python 3:

```sh
python scripts/build.py
python scripts/verify.py
```

Результаты:

```text
dist/magisk-adb-tcp-usb-host-jaws-vX.Y.Z.zip
dist/SHA256SUMS
```

Сборка побайтово воспроизводима.

## Лицензия

[MIT](LICENSE) © 2026 sergej19882906
