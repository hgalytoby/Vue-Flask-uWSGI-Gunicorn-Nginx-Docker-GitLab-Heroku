FROM node:14 as vite-test
WORKDIR /usr/src/app
COPY vite-test/package.json .
RUN npm i
COPY vite-test/ .
RUN npm run build

FROM nginx:1.21.1
WORKDIR /usr/src/app/backend
COPY --from=vite-test /usr/src/app/dist /usr/src/app/frontend
COPY backend/requirements.txt .
RUN apt-get update && apt-get install -y python3-pip && python3 -m pip install --upgrade pip && pip3 install -r requirements.txt
COPY backend/ .
COPY heroku.conf /etc/nginx/conf.d/default.conf
CMD chmod a+x Run.sh && bash ./Run.sh && /bin/bash -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'