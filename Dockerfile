# ========== ЭТАП 1: СБОРКА ==========
FROM gradle:8.4-jdk21 AS builder
WORKDIR /workspace

# Копируем ВСЕ файлы проекта в контейнер
COPY . .

# Собираем приложение (пропускаем тесты)
RUN ./gradlew :app:build -x test --no-daemon

# ========== ЭТАП 2: ЗАПУСК ==========
FROM eclipse-temurin:21-jre-alpine

LABEL maintainer="brx@EgorBrxLt"

# Создаём непривилегированного пользователя (для alpine)
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

WORKDIR /app

# Копируем JAR из этапа сборки
COPY --from=builder /workspace/app/build/libs/*.jar app.jar

ENV JAVA_OPTS="-Xmx512m -Xms256m"
EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]