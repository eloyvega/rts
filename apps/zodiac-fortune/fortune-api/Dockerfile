# Not for production use
FROM node:14.18-alpine
ENV PORT 3000
EXPOSE ${PORT}
WORKDIR /app
COPY . .
RUN npm install
ENTRYPOINT [ "npm", "start"]