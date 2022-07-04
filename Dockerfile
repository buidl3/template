FROM node:16-alpine

USER node
WORKDIR /home/node/app

COPY package.json .

ENV NPM_CONFIG_LOGLEVEL warn
RUN npm install
RUN ./node_modules/.bin/pm2 install typescript

COPY . .

CMD ["./node_modules/.bin/pm2-runtime", "start", "ecosystem.config.js"]