>作者：可爱的小cherry
>
>公众号：可爱的小cherry
>
![image.png](https://cgakki.top/wp-content/uploads/2024/04/qrcode_for_gh_d5083129ff7e_258.jpg)

# 前言

大家好，这里是可爱的Cherry。

该项目是一个包含**服务端、web端、移动端** 三端齐全的**加密存储项目** ，包括**auth（存储2FA）** 和**photo（存储照片）** 两个子项目，所有代码完全开源，采用AGPL-3.0开源协议。

该项目photo部分是apple和google photos的开源代替品，支持自托管和外部S3存储，今天我们先介绍photo部分如何部署和使用，考虑到大部分照片都在手机端，所以只介绍手机端使用（主要是手机端昨天刚允许使用自托管服务，不需要自己编译，实在太好了）。

🔻Ente Photo——加密照片存储管理

![image.png](https://cgakki.top/wp-content/uploads/2024/04/13951.png)

🔻Ente Auth——加密2FA管理

![image.png](https://cgakki.top/wp-content/uploads/2024/04/13952.png)

🔴以下来自官方介绍
>Ente是一项服务，它提供了一个完全开源的端到端加密平台，您可以将数据存储在云中，而无需信任服务提供商。在这个平台上，我们已经构建了两个应用程序：Ente Photos（Apple和Google Photos的替代品）和Ente Auth（已弃用的Authy的2FA替代品）。
>
>项目包含我们所有的源代码-客户端应用程序（iOS / Android / F-Droid / Web / Linux / macOS / Windows）的产品（和更多的计划未来的！），以及为其提供动力的服务器。我们的源代码和加密技术已经过Cure 53（一家德国网络安全公司，可以说是世界上最好），Symbolic Software（法国加密专家）和Fallible（一家印度渗透测试公司）的外部审计。

---

# 系统效果
🔻app端支持按手机相册进行备份，允许对已备份的相册进行一键释放空间，允许移除重复内容。

![image.png](https://cgakki.top/wp-content/uploads/2024/04/13953.png)

🔻从安全角度出发，允许管理密钥、设置2FA认证、设置电子邮件登录认证。

![image.png](https://cgakki.top/wp-content/uploads/2024/04/13954.png)

🔻从功能角度，支持按相册管理照片，支持分享照片，支持设定活动照片用于其他人上传照片，支持按地图、时间、相册进行照片检索

![image.png](https://cgakki.top/wp-content/uploads/2024/04/13955.png)

🔻高级设置，可以设置机器学习（clip），具体的clip模型不得而知。但是在检索上，可以看到英文检索准确定还是不错的，而中文检索能力要弱很多。

![image.png](https://cgakki.top/wp-content/uploads/2024/04/13956.png)

---

# 系统部署（Photo服务端）

## 一、前期准备

```
# 以下命令逐行输入
mkdir ente && cd ente 
# 下载compose.yaml
curl -LO https://raw.gitmirror.com/ente-io/ente/main/server/compose.yaml

# 下载credentials.yaml和minio-provision.sh文件
mkdir -p scripts/compose && cd scripts/compose
curl -LO https://raw.gitmirror.com/ente-io/ente/main/server/scripts/compose/credentials.yaml
curl -LO https://raw.gitmirror.com/ente-io/ente/main/server/scripts/compose/minio-provision.sh
```

## 二、修改配置文件

1️⃣第一步：修改docker-compose.yaml

🔻第一个可以修改的地方是端口，主要修改8080这个API接口就行了。

![image.png](https://cgakki.top/wp-content/uploads/2024/04/13957.png)

🔻第二个可以修改的地方是镜像，将`docker build`内容改为`image: ghcr.io/ente-io/server`

![image.png](https://cgakki.top/wp-content/uploads/2024/04/13958.pngg)

![image.png](https://cgakki.top/wp-content/uploads/2024/04/13959.pngg)

🔻第三个可以修改的是postgres和minio的端口。

如果minio的改了。minio-provision.sh也要对应修改。

![image.png](https://cgakki.top/wp-content/uploads/2024/04/139510.png)

![image.png](https://cgakki.top/wp-content/uploads/2024/04/139511.png)

2️⃣修改`credentials.yaml`文件。路径在`ente/scripts/compose/credentials.yaml`，这三个`endpoint`必须是服务器端和手机端都可以访问到的地址，如果是局域网就是填宿主机ip，如果是外网就填外网ip或域名。

![image.png](https://cgakki.top/wp-content/uploads/2024/04/139512.png)

## 三、SSH部署

```
#来到文件夹
cd /volume1/docker/ente
#启动容器
docker-compose up -d
```

## 四、群晖部署
🔻打开container manager，选择项目，点击新建，选择penpot路径，点击下一步即可

![image.png](https://cgakki.top/wp-content/uploads/2024/04/139513.png)

## 五、威联通部署

🔻打开container station，创建应用程序，复制代码验证后部署即可

![image.png](https://cgakki.top/wp-content/uploads/2024/04/139514.png)

---

# 系统部署（web端）

🔻该项目的web端目前没有提供image，所以需要我们自己使用docekrfile，因此这里就把issuse里的dockerfile提供出来，感兴趣的可以自己docker build。

```
FROM node:20-alpine as builder

WORKDIR /app
COPY . .

ARG NEXT_PUBLIC_ENTE_ENDPOINT=http://localhost:8080  #这里需要更改为你自己的服务器地址
ENV NEXT_PUBLIC_ENTE_ENDPOINT=${NEXT_PUBLIC_ENTE_ENDPOINT}

RUN yarn install && yarn build

FROM node:20-alpine

WORKDIR /app
COPY --from=builder /app/apps/photos/out .

RUN npm install -g serve

ENV PORT=3000
EXPOSE ${PORT}

CMD serve -s . -l tcp://0.0.0.0:${PORT}
```

🔻当然，如果服务器上装有npm的，也可以使用yarn安装，但是大部分NAS应该都不支持，建议不要折腾。

```
cd ente/web
git submodule update --init --recursive
yarn install
NEXT_PUBLIC_ENTE_ENDPOINT=http://localhost:8080 yarn dev
```

---
# 系统部署（APP端）

# 一、下载app

photo安卓APP下载地址：https://github.com/ente-io/ente/releases/download/photos-v0.8.70/ente-photos-v0.8.70.apk

photo苹果APP下载地址：直接国服商店下载

## 二、连接自托管服务，并创建账号

🔻打开APP以后，连续点击中间的图标7下，解锁自托管模式。点击YES，然后在弹框中输入自托管的服务地址，如 `http://192.168.0.2:56789`，然后点击`New to ente`开始设置账号。 

![image.png](https://cgakki.top/wp-content/uploads/2024/04/139515.png)

## 三、查看日志，进行账号邮件验证码

🔻当创建账号以后，会有一个邮箱验证码，这个验证码目前官方并没有给出邮件通道，所以我们需要在后台查看。

```
# 来到ente目录，查看日志
cd /volume1/docker/ente
docker-compose logs -f
```

🔻在获取日志的时候，可以看到如下一串验证码，最后的814763就是本次邮箱验证码。注意，这里的日志查看不要关，一会我们还要用到。

![image.png](https://cgakki.top/wp-content/uploads/2024/04/139516.png)

🔻这里输入验证码即可

![image.png](https://cgakki.top/wp-content/uploads/2024/04/139517.png)

## 四、设置中文

🔻该项目支持中文，有没有感觉很棒！选择`gerneral`-`language`-'中文'即可

![image.png](https://cgakki.top/wp-content/uploads/2024/04/139518.png)

## 五、扩容存储空间

🔻首次登录系统，我们只有1G的存储空间，可以看到官方提示可以通过邀请、购买来进行扩容，这也表示该项目可以用于商用（具体看开源协议，嘿嘿）。

![image.png](https://cgakki.top/wp-content/uploads/2024/04/139519.png)

🔻开始扩容，继续看我们的日志，找到创建用户的用户ID，基本上每一条日志都有跟一个`user_id`，我们只要找到并复制这个`user_id`即可，我这里是`user_id=1580559962386438`

![image.png](https://cgakki.top/wp-content/uploads/2024/04/139520.png)

🔻按`ctrl+c`关闭日志，重回SSH指令界面，输入以后指令

```
# 把【user_id】替换成自己的ID，1580559962386438
docker-compose exec -i postgres psql -U pguser -d ente_db -c "INSERT INTO storage_bonus (bonus_id, user_id, storage, type, valid_till) VALUES ('self-hosted-myself', (SELECT user_id FROM users LIMIT 1), 【user_id】, 'ADD_ON_SUPPORT', 0)"
```

🔻返回结果`INSERT 0 1`，表示更改成功

![image.png](https://cgakki.top/wp-content/uploads/2024/04/139521.png)

🔻回到我们的手机APP，可以看到，存储空间已经变成2T了，如果没变等刷新一下即可。

![image.png](https://cgakki.top/wp-content/uploads/2024/04/139522.png)
