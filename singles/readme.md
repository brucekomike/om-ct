# how to build
## wiki
1.45.1
```
docker build --build-arg HTTPS_PROXY=$http_proxy -f mediawiki45.dockerfile --network host -t ossmediawiki:1.45.1 .
```
## wiki-fpm
1.45.1
```
docker build --build-arg HTTPS_PROXY=$http_proxy -f mediawiki45-fpm.dockerfile --network host -t ossmediawiki:1.45.1-fpm .
```
## frp
```
docker build --build-arg HTTPS_PROXY=$http_proxy -f frp.dockerfile --network host -t ossmediafrp:latest .
```