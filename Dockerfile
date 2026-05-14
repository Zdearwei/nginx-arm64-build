# ===== 编译阶段 =====
FROM --platform=linux/arm64 nginx:1.29.8-alpine AS builder

RUN apk add --no-cache \
    build-base \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    git

WORKDIR /build

COPY nginx-1.29.8.tar.gz .
COPY nginx-module-vts-master ./nginx-module-vts-master

RUN tar zxvf nginx-1.29.8.tar.gz

WORKDIR /build/nginx-1.29.8

# 编译 vts 动态模块
RUN ./configure --with-compat \
    --add-dynamic-module=../nginx-module-vts-master \
    && make modules


# ===== 运行阶段 =====
FROM nginx:1.29.8

# 拷贝模块
COPY --from=builder /build/nginx-1.29.8/objs/ngx_http_vhost_traffic_status_module.so /etc/nginx/modules/

# basic auth 文件
COPY htpasswd /etc/nginx/.htpasswd

# vts文件
COPY vts.conf /etc/nginx/modules-enabled/vts.conf