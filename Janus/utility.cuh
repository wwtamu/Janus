#include "box.h"
#include "character.h"
#include "stdafx.h"

#define THREAD_X 8
#define THREAD_Y 8

#define DISPLAY_AFTER_PREPROCESS false
#define DISPLAY_AFTER_EXTRACTION true

#define SHOW_LOCATION true
#define SHOW_ORIGINAL_SIZE true
#define SHOW_BINARY_REPRESENTATION true
#define SHOW_VERTICAL_CELLED_PROJECTION true
#define SHOW_HORIZONTAL_CELLED_PROJECTION true
#define SHOW_DENSITY_MATRIX true

#define WRITE_CHARACTER_IMAGE_FILE true
#define DESCRIBE_CHARACTER false

#define TRAIN_DATA false


extern Mat preprocess(Mat image, int threshold);

extern vector<character> extract(Mat image, int max, int sized, int quadrants, string filename);