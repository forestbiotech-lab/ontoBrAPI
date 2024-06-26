FROM node:18.19
# Create app directory
WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --omit=dev

COPY . .

EXPOSE 3000

CMD [ "sh", "-c", "GIT_COMMIT=$(cut -f1 .FETCH_HEAD) npm start" ]

LABEL version="1.0"

