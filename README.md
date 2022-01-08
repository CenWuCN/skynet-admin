# skynet-admin

该 demo 需要配合 web 端（[skynet-admin-web](https://github.com/CenWuCN/skynet-admin-web)）使用

## 运行

需要编译 cjson 库（[kyne cjson](https://github.com/mpx/lua-cjson/)）并且把 cjson.so 复制到 skynet/luaclib 下

把 web-server 复制到 skynet 文件夹下，执行命令

```bash
./skynet ./web-server/config
```

即可启动服务端