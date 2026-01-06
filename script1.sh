#!/bin/bash

# Файл для логов
LOG_FILE="/var/log/malware_clean.log"

echo "=== Поиск процессов из /tmp/.x/ ===" | tee -a $LOG_FILE
date | tee -a $LOG_FILE

# Найти PID процессов
PIDS=$(ps aux | grep "/tmp/.x/" | grep -v grep | awk '{print $2}')

if [ -n "$PIDS" ]; then
    echo "Найдены процессы: $PIDS" | tee -a $LOG_FILE
    
    # Завершить процессы
    for PID in $PIDS; do
        echo "Завершаем процесс $PID" | tee -a $LOG_FILE
        kill -9 $PID 2>/dev/null && echo "Процесс $PID завершен" | tee -a $LOG_FILE
    done
else
    echo "Процессы из /tmp/.x/ не найдены" | tee -a $LOG_FILE
fi

# Удалить директорию
if [ -d "/tmp/.x" ]; then
    echo "Удаляем директорию /tmp/.x" | tee -a $LOG_FILE
    rm -rf /tmp/.x && echo "Директория удалена" | tee -a $LOG_FILE
else
    echo "Директория /tmp/.x не существует" | tee -a $LOG_FILE
fi
