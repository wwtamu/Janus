#include <cmath>
#include <chrono>
#include <iostream>
#include <set>

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#include <opencv2\core\core.hpp>
#include <opencv2\imgproc\imgproc.hpp>
#include <opencv2\highgui\highgui.hpp>

#include <cuda_runtime.h>
#include <curand_kernel.h>
#include <device_launch_parameters.h>

using namespace cv;
using namespace std;

int _exit(char* message, int code);
