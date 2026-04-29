#!/bin/bash

# Проверяем аргументы командной строки
if [ $# -ne 2 ]; then
    echo "Использование: $0 <файл_с_доменами> <файл_результата>"
    echo "Пример: $0 domains.txt results.txt"
    exit 1
fi

DOMAINS_FILE="$1"
OUTPUT_FILE="$2"

# Проверяем существует ли файл с доменами
if [ ! -f "$DOMAINS_FILE" ]; then
    echo "Ошибка: Файл '$DOMAINS_FILE' не найден!"
    exit 1
fi

# Очищаем или создаём файл результата
> "$OUTPUT_FILE"

echo "Начинаю обработку доменов из файла: $DOMAINS_FILE"
echo "Результаты сохраняются в: $OUTPUT_FILE"
echo "----------------------------------------"

# Читаем файл с доменами построчно
while IFS= read -r domain; do
    # Пропускаем пустые строки
    if [ -z "$domain" ]; then
        continue
    fi
    
    echo -n "Обработка: $domain -> "
    
    # Делаем nslookup и извлекаем IPv4 адрес (первый найденный)
    ip=$(nslookup "$domain" 2>/dev/null | grep -A1 "Name:" | grep "Address:" | tail -1 | awk '{print $2}')
    
    # Проверяем результат
    if [ -n "$ip" ]; then
        echo "$ip"  # Выводим IP в консоль
        echo "$ip" >> "$OUTPUT_FILE"  # В файл сохраняем только IP
    else
        echo "[НЕ НАЙДЕН]"  # Выводим статус в консоль
        echo "[НЕ НАЙДЕН]" >> "$OUTPUT_FILE"  # В файл тоже статус
    fi
    
done < "$DOMAINS_FILE"

echo "----------------------------------------"
echo "Готово! Результаты сохранены в: $OUTPUT_FILE"
