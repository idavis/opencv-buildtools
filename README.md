# OpenCV Build Tools



https://docs.opencv.org/master/d2/de6/tutorial_py_setup_in_ubuntu.html
https://docs.opencv.org/master/d7/d9f/tutorial_linux_install.html

https://www.tensorflow.org/lite/guide/python

```bash
make wheelhouse
make opencv
make app
xhost +local:docker
docker run --rm -it --privileged -e "DISPLAY" --net host demo-app /bin/bash
```