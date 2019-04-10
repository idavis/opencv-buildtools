# OpenCV Build Tools

Scaffolding around the compilation of OpenCV

The `Makefile` only supports CUDA builds at the moment. For a desired CUDA configuration, the `Dockerfile`'s base image can be updated and a recipe added to the `Makefile`.

## Usage

Run `make` with a target and the output will be copied to `./dist/OpenCV-<version>-<platform>.sh`

Example:

`make opencv-4.0.1-10.0-cudnn7-devel-ubuntu18.04`
