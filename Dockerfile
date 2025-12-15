FROM node:lts-alpine3.17 AS builder

# Instalacja zależności systemowych do prismy (jeśli potrzebne)
#RUN apk update && apk add --no-cache libssl1.1

WORKDIR /app

# Kopiuj package.json i package-lock.json
COPY package*.json ./

# Instaluj zależności
RUN npm ci

# Kopiuj resztę kodu
COPY . .

# Build aplikacji
RUN npm run build


FROM node:lts-alpine3.17 AS production

# Instalacja zależności systemowych w produkcji
RUN apk update && apk add --no-cache libssl1.1

WORKDIR /app

# Kopiuj node_modules i wygenerowane rzeczy z buildera
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/src ./src
COPY --from=builder /app/dist ./dist

# Port aplikacji
EXPOSE 3000

# Cały setup Prisma i start aplikacji
CMD ["sh", "-c", "npm --version &&npm run db:setup && node /app/dist/api/main.js"]
