FROM --platform=${BUILDPLATFORM} node:24-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:stable-alpine-slim

LABEL org.opencontainers.image.source="https://github.com/Cozidian/ferroprint"

COPY --from=build /app/dist /usr/share/nginx/html

# Once's proxy requires a successful /up check before it routes traffic.
RUN printf 'ok\n' > /usr/share/nginx/html/up

HEALTHCHECK CMD wget -q -O /dev/null http://localhost/up || exit 1
