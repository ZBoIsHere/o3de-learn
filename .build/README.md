#### build image
```
docker build -t {IMAGE_NAME}:{TAG}
```

#### run container
```
docker run -it --runtime=nvidia  -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=all -p 5900:5900 -p 5999:5999 {IMAGE_NAME}:{TAG}
```

#### connect via browser
{IP}:5999/vnc.html

#### connect via vnc client
{IP}:5900
