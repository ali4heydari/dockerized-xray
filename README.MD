## xray_docker_reality
xray reality docker image

[![xray_docker_reality_docker_image_build](https://github.com/wulabing/xray_docker/actions/workflows/xray_docker_reality.yml/badge.svg)](https://github.com/wulabing/xray_docker/actions/workflows/xray_docker_reality. yml)

## Basic usage
If you don't have docker installed, please install docker first

```
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
```

If you have already installed docker, you can use the following command directly, after running, the image will be downloaded automatically and the container will be started.
EXTERNAL_PORT is the port you want to use, as shown below, you will use port 443

```
docker pull wulabing/xray_docker_reality:latest
EXTERNAL_PORT=443
docker run -d --name xray_reality --restart=always -p $EXTERNAL_PORT:443 -e EXTERNAL_PORT=$EXTERNAL_PORT wulabing/xray_docker_reality:latest
```

Check the log to get the configuration information, as shown below, just follow the prompts to configure the client,

```
docker logs -f xray_reality
```

## Advanced usage

If you don't want to use port 443, you can customize the port, for example, use port 8443, as shown below

```
EXTERNAL_PORT=8443
docker run -d --name xray_reality --restart=always -p $EXTERNAL_PORT:443 -e EXTERNAL_PORT=$EXTERNAL_PORT wulabing/xray_docker_reality:latest
```

If you want to start multiple reality services, you can use different container names, and be careful not to conflict with the ports. As shown below, you will start two reality services, using ports 444 and 445 respectively

```
EXTERNAL_PORT=444
docker run -d --name xray_reality_1 --restart=always -p $EXTERNAL_PORT:443 -e EXTERNAL_PORT=$EXTERNAL_PORT wulabing/xray_docker_reality:latest
EXTERNAL_PORT=445
docker run -d --name xray_reality_2 --restart=always -p $EXTERNAL_PORT:443 -e EXTERNAL_PORT=$EXTERNAL_PORT wulabing/xray_docker_reality:latest
```

If you don’t want to use the default parameters, you can customize the parameters, such as using a custom UUID, as well as custom target address and server name, as shown below, **Please refer to the environment variable description below for supported custom parameters**

Use spaces to separate multiple SERVERNAMES, for example: www.apple.com images.apple.com

Please note that if you use custom parameters, you need to ensure the correctness of the parameters yourself, otherwise the container may fail to start
```
EXTERNAL_PORT=443
docker run -d --name xray_reality --restart=always -p $EXTERNAL_PORT:443 -e EXTERNAL_PORT=$EXTERNAL_PORT -e UUID="XXX" -e SERVERNAMES="www.apple.com images.apple.com" -e DEST="www.apple.com:443" -e PRIVATEKEY="XXX" wulabing/xray_docker_reality:latest
```

Use the following command to delete the created container, as shown below, you need to replace xray_reality with your own container name (the name set by --name)

```
docker rm -f xray_reality
```


## Environment variables
You can set the following environment variables to customize XRay's configuration.
* UUID: XRay's unique user identifier. If not set, the script will automatically generate a random UUID.
* DEST: Destination address. The default is www.apple.com:443.
* SERVERNAMES: A list of server names. The default is www.apple.com images.apple.com.
* PRIVATEKEY: private key. If not set, the script will automatically generate a new private key and corresponding public key.
* NETWORK: network type. The default is tcp.

## constants
* flow: xtls-rprx-vision
* security: reality
* shortIds: leave blank

## Precautions
Please make sure the XRay client is properly installed and configured before use.
In order to ensure security and stability, please do not disclose sensitive information such as UUID and private key to others.