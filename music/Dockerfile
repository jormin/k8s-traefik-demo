FROM alpine:latest

# 设置固定的项目路径
ENV WORKDIR /app

# 添加应用可执行文件，并设置执行权限
ADD ./music   $WORKDIR/music
RUN chmod +x $WORKDIR/music

RUN echo -e http://mirrors.ustc.edu.cn/alpine/v3.7/main/ > /etc/apk/repositories \
    && apk update \
    && apk add tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

WORKDIR $WORKDIR
CMD ./music