# Vue + Flask + uWSGI+ Gunicorn + Nginx + Docker + GitLab + Heroku + 全圖文解說

# 請深呼吸保持良好精神，本教學文會很長，但別擔心!!我已經附上很多圖文解說!!跟著做保證成功!!

## 專案大綱
- 使用 Docker 包所有套件
- 使用 Nginx 實現反向代理兩個後端伺服器
- 前端使用 Vue3
- 後端使用兩個 Flask 
- uWSGI 與 Gunicorn 分別點啟 Flask
- 利用 GitLab CI/CD Build Docker Image，並自動 Deploy 至 Heroku
> [前往 Heroku 成果網址](https://cn.vitejs.dev/guide/#scaffolding-your-first-vite-project)

## 事前準備
- 1.安裝 Node.js
- 2.安裝 Python3
- 3.安裝 Git
- 4.安裝 Docker
- 5.申請 GitLab 帳號
- 6.申請 Heroku 帳號

## 準備前端頁面
### 第一步: 創建 Vite
- `npm init vite@latest <project-name>`
> [官網指令](https://cn.vitejs.dev/guide/#scaffolding-your-first-vite-project)	

### 第二步: 創建專案
![image](https://i.imgur.com/T2XkFHV.png)

### 第三步: 選擇 vue
![image](https://i.imgur.com/7yTq6aG.png)

### 第四步: 完成的樣子
![image](https://i.imgur.com/2qOzZ08.png)

### 第五步: 更換工作路徑與安裝需要的套件
![image](https://i.imgur.com/DAKVZ4z.png)

### 第六步: 安裝 axios
![image](https://i.imgur.com/3rYwNFG.png)

### 第七步: 修改 App.vue 文件，增加兩個往後端方發請求的按鈕
```vue
<template>
    <img alt="Vue logo" src="./assets/logo.png"/>
    <HelloWorld msg="Hello Vue 3 + Vite"/>
    <h1>{{ data.flask1 }}</h1>
    <button @click="api('/api1/', 'flask1')">Flask1 Api</button>
    <h1>{{ data.flask2 }}</h1>
    <button @click="api('/api2/', 'flask2')">Flask2 Api</button>
</template>

<script>
    import HelloWorld from './components/HelloWorld.vue'
    import axios from 'axios'
    import {reactive} from 'vue'

    export default {
        name: 'App',
        components: {HelloWorld},
        setup() {
            let data = reactive({
                flask1: '',
                flask2: ''
            })

            function api(url, flask) {
                axios.get(url).then(
                    response => {
                        data[flask] = response.data
                    },
                    error => {
                        alert(error)
                    }
                )
            }

            return {
                api,
                data
            }
        }
    }
</script>

<style>
    #app {
        font-family: Avenir, Helvetica, Arial, sans-serif;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        text-align: center;
        color: #2c3e50;
        margin-top: 60px;
    }
</style>
```

### 第八步: 修改 vite.config.js 文件，測試時需要代理 proxy
```js
import {defineConfig} from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
    plugins: [vue()],
    server: {
        proxy: {
            '/api1': {
                target: 'http://localhost:5000/',
                changeOrigin: true,
                rewrite: path => path.replace(/^\/api1/, 'api1/')
            },
            '/api2': {
                target: 'http://localhost:5001/',
                changeOrigin: true,
                rewrite: path => path.replace(/^\/api2/, 'api2/')
            },
        }
    }
})
```

### 第九步: run vite
![image](https://i.imgur.com/RxAygZx.png)

### 第十步: 打開瀏覽器 http://localhost:3000/
![image](https://i.imgur.com/o9020wO.png)


## 準備後端伺服器
### 第一步: 新增放後端程式的資料夾

### 第二步: 安裝 Flask
![image](https://i.imgur.com/AEmkcOT.png)

### 第三步: 新增 base.py
```python
from flask import Flask, jsonify
import random

app = Flask(__name__)
app.config["DEBUG"] = True
app.config["JSON_AS_ASCII"] = False

```

### 第四步: 新增 flask1.py
```python
from base import app, jsonify, random


@app.route("/api1/", methods=['GET'])
def index():
    return jsonify({'msg': '我是 flask1', 'num': random.randint(1, 100)})


if __name__ == '__main__':
    app.run(host='localhost', port=5000)

```

### 第五步: 新增 flask2.py
```python
from base import app, jsonify, random


@app.route("/api2/", methods=['GET'])
def index():
    return jsonify({'msg': '我是 flask2', 'num': random.randint(1, 100)})


if __name__ == '__main__':
    app.run(host='localhost', port=5001)

```
### 第六步: 執行 flask1.py 與 flask2.py
![image](https://i.imgur.com/4cq6Efn.png)


## 前後端都準備完成了! 可以先看一下成果如何!
![image](https://i.imgur.com/GEPFuRf.gif)


## 使用 Docker 
### 第一步: 刪掉前端資料夾下的 node_modules

### 第二步: 在後端資料夾下新增 requirements.txt
```
flask
uwsgi
gunicorn
```

### 第三步: 在後端資料夾下新增 uwsgi.ini
```
[uwsgi]
wsgi-file=flask2.py
callable=app
socket=0.0.0.0:5001
master=true
chdir=/usr/src/app/backend
enable-threads=True
```

### 第四步: 在後端資料夾下新增 Run.sh (注意! 如果不是在 UNIX 下寫.sh 會出問題!!)
```shell script
#! /bin/bash

nohup gunicorn -b 0.0.0.0:5000 flask1:app > gunicorn_log.txt 2>&1 &

nohup uwsgi --ini uwsgi.ini > uwsgi.txt 2>&1 &
```

### 第五步: 新增 nginx.conf
```
upstream flask1 {
    server    0.0.0.0:5000;
}
upstream flask2 {
    server    0.0.0.0:5001;
}

server {
    listen 48763 ;
    server_name 0.0.0.0;
    client_max_body_size 1024M;
    access_log /var/log/nginx/nginx.vhost.access.log;
    error_log /var/log/nginx/nginx.vhost.error.log;

    location / {
	    root   /usr/src/app/frontend;
	    try_files $uri $uri/ @router;
	    index  index.html;
    }

    location @router {
        rewrite ^.*$ /index.html last;
    }

    location /api1/ {
        proxy_pass http://flask1;
        proxy_redirect off;
        proxy_set_header Host $host:80;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /api2/ {
        root   /usr/src/app/backend;
        index  index.html;
        include /etc/nginx/uwsgi_params;
        uwsgi_pass flask2;
	}
}
```

![image](https://i.imgur.com/CwdzFU9.png)

### 第六步: 新增 Dockerfile
```dockerfile
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
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 48763
CMD ./Run.sh && nginx -g 'daemon off;'
```

### 第七步: Docker build `docker build -t test .`
![image](https://i.imgur.com/V5FmcQQ.png)

### 第八步: Docker run `docker run -p 48763:48763 test`
![image](https://i.imgur.com/Kfg9gmA.png)

### 第九步: 打開瀏覽器 http://localhost:48763/ 看看成果如何!
![image](https://i.imgur.com/Pzu9xSp.gif)


## 使用 GitLab CD 推到 Heroku !
### Heroku 創專案
![image](https://i.imgur.com/zjedodP.gif)

### GitLab 創專案
![image](https://i.imgur.com/v55EqBk.gif)

### 取得 Heroku API Key
![image](https://i.imgur.com/jrzMmUS.png)

### GitLab 設定 Heroku API Key
![image](https://i.imgur.com/Utx6K9D.png)
![image](https://i.imgur.com/9bywoop.png)

### 新增 .gitlab-ci.yml
#### 範例: 請修改 `<gitlab account>` `<gitlab project name>` `<heroku project name>` 總共有四個地方要修改(注意! GitLab 專案名字如果有大寫，yml 的 gitlab project name 要全小寫!)
```yaml
image: docker:latest
stages:
  - build
services:
  - docker:dind

variables:
  DOCKER_HOST: tcp://docker:2376
  DOCKER_TLS_CERTDIR: "/certs"
  CI_REGISTRY_IMAGE: registry.gitlab.com/<gitlab account>/<gitlab project name>
  HEROKU_REGISTRY: registry.heroku.com/<heroku project name>/web

before_script:
  - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY

build_and_deploy_to_heroku:
  stage: build
  services:
    - docker:dind
  script:
    - docker pull $CI_REGISTRY_IMAGE:latest || true
    - docker build --cache-from $CI_REGISTRY_IMAGE:latest --tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA --tag $CI_REGISTRY_IMAGE:latest .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker push $CI_REGISTRY_IMAGE:latest
    - docker login --username=_ --password=$HEROKU_API_KEY registry.heroku.com
    - docker tag $CI_REGISTRY_IMAGE:latest $HEROKU_REGISTRY:latest
    - docker push $HEROKU_REGISTRY:latest
    - docker run --rm -e HEROKU_API_KEY=$HEROKU_API_KEY dickeyxxx/heroku-cli heroku container:release web --app <heroku project name>
```
https://docs.gitlab.com/ee/ci/variables/predefined_variables.html

#### 我的版本
```yaml
image: docker:latest
stages:
  - build
services:
  - docker:dind

variables:
  DOCKER_HOST: tcp://docker:2376
  DOCKER_TLS_CERTDIR: "/certs"
  CI_REGISTRY_IMAGE: registry.gitlab.com/hgalytoby/vue-flask-uwsgi-gunicorn-nginx-docker-gitlab-heroku
  HEROKU_REGISTRY: registry.heroku.com/vue-python-nginx-gitlab-docker/web

before_script:
  - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY

build_and_deploy_to_heroku:
  stage: build
  services:
    - docker:dind
  script:
    - docker pull $CI_REGISTRY_IMAGE:latest || true
    - docker build --cache-from $CI_REGISTRY_IMAGE:latest --tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA --tag $CI_REGISTRY_IMAGE:latest .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker push $CI_REGISTRY_IMAGE:latest
    - docker login --username=_ --password=$HEROKU_API_KEY registry.heroku.com
    - docker tag $CI_REGISTRY_IMAGE:latest $HEROKU_REGISTRY:latest
    - docker push $HEROKU_REGISTRY:latest
    - docker run --rm -e HEROKU_API_KEY=$HEROKU_API_KEY dickeyxxx/heroku-cli heroku container:release web --app vue-python-nginx-gitlab-docker
```

### 新增 heroku.conf 
```
upstream flask1 {
    server    0.0.0.0:5000;
}
upstream flask2 {
    server    0.0.0.0:5001;
}

server {
    listen $PORT default_server;
    client_max_body_size 1024M;
    access_log /var/log/nginx/nginx.vhost.access.log;
    error_log /var/log/nginx/nginx.vhost.error.log;

    location / {
	    root   /usr/src/app/frontend;
	    try_files $uri $uri/ @router;
	    index  index.html;
    }

    location @router {
        rewrite ^.*$ /index.html last;
    }

    location /api1/ {
        proxy_pass http://flask1;
        proxy_redirect off;
        proxy_set_header Host $host:80;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /api2/ {
        root   /usr/src/app/backend;
        index  index.html;
        include /etc/nginx/uwsgi_params;
        uwsgi_pass flask2;
	}
}
```

### 修改 Dockerfile (將原本 Docker 的改名自己留著參考)
```dockerfile
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

```

### 將專案 Push 到 GitLab 

### 完成後到自己的 Heroku 上看結果!
![image](https://i.imgur.com/MvjDMxV.gif)
