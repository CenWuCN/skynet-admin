# skynet-admin

该 demo 需要配合 web 端（[skynet-admin-web](https://github.com/CenWuCN/skynet-admin-web)）使用

## 运行

```bash
git clone https://github.com/CenWuCN/skynet-admin
cd skynet-admin
git submodule init
git submodule update
cd packages/skynet
make linux
cd ../lua-cjson
make
cp cjson.so ../skynet/luaclib
cd ../skynet
./skynet ../../web-server/config
```

即可启动服务端