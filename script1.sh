#!/bin/bash

# Настройки
OUR_WALLET="49Wg2WsaZS1WA1s4USLNmxK1o5iBqw8aK6tButK4HLgK4XHn3xXGa247BNyLiE7ZzyHR17fotQJwqJF5Mi8Lz6B4L9JGKDE"
MINER_KEYWORDS=("moneroocean.stream" "xmrig" "minerd" "cpuminer" "stratum" "pool" "mine" "cryptonight" "crypto")
SUSPICIOUS_PATHS=("/tmp" "/var/tmp" "/dev/shm")

# Функция для логирования
log() {
  echo "[$(date)] $1" >> /var/log/miner_killer.log
}

# Шаг 1: Поиск и уничтожение процессов майнеров
log "Поиск процессов майнеров..."

for keyword in "${MINER_KEYWORDS[@]}"; do
  # Ищем процессы, содержащие ключевое слово, и получаем их PID и командную строку
  ps aux | grep -i "$keyword" | grep -v grep | while read line; do
      # Извлекаем PID
      pid=$(echo $line | awk '{print $2}')
      # Извлекаем командную строку, начиная с 11-го поля
      cmd=$(echo $line | awk '{for(i=11;i<=NF;i++) printf $i" "; print ""}')

      # Проверяем, что это не наш процесс (по кошельку)
      if [[ $cmd != *"$OUR_WALLET"* ]]; then
          log "Найден чужой майнер: PID=$pid, команда: $cmd"
          # Убиваем процесс
          kill -9 $pid 2>/dev/null
          if [ $? -eq 0 ]; then
              log "Процесс $pid убит."
          else
              log "Не удалось убить процесс $pid."
          fi
      else
          log "Найден наш майнер: PID=$pid, пропускаем."
      fi
  done
done

# Шаг 2: Поиск и удаление подозрительных файлов и директорий
log "Поиск подозрительных файлов и директорий..."

# Ищем в SUSPICIOUS_PATHS файлы и директории, содержащие ключевые слова
for path in "${SUSPICIOUS_PATHS[@]}"; do
  # Ищем файлы и директории, содержащие ключевые слова в именах
  for keyword in "${MINER_KEYWORDS[@]}"; do
      find "$path" -name "*$keyword*" -type f 2>/dev/null | while read file; do
          log "Найден подозрительный файл: $file"
          rm -f "$file"
          log "Файл $file удален."
      done

      find "$path" -name "*$keyword*" -type d 2>/dev/null | while read dir; do
          log "Найден подозрительный каталог: $dir"
          rm -rf "$dir"
          log "Каталог $dir удален."
      done
  done

  # Также ищем скрытые директории с именами, начинающимися с точки, которые могут содержать майнеры
  find "$path" -type d -name ".*" 2>/dev/null | while read dir; do
      # Проверяем, есть ли внутри этой директории файлы с именами, содержащими ключевые слова
      for keyword in "${MINER_KEYWORDS[@]}"; do
          if find "$dir" -name "*$keyword*" -type f 2>/dev/null | read; then
              log "Найден скрытый каталог с майнерами: $dir"
              rm -rf "$dir"
              log "Каталог $dir удален."
              break
          fi
      done
  done
done

log "Завершено."
