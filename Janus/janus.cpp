#include "stdafx.h"
#include "utility.cuh"

int main(int argc, char** argv)
{
	if (argc != 6) {
		_exit("Usage: janus [image_file] [threshold] [max character size recognized] [sized character] [density quadrants]", EXIT_FAILURE);
	}


	Mat image;
	image = imread(argv[1], CV_LOAD_IMAGE_COLOR);

	if (!image.data) {
		_exit("Could not open or find the image", EXIT_FAILURE);
	}

	cout << image.cols << "x" << image.rows << endl << endl;

	int threshold = atoi(argv[2]);

	int max = atoi(argv[3]);

	int sized = atoi(argv[4]);

	int quadrants = atoi(argv[5]);

	std::string str(strrchr(argv[1], '.'));


	Mat trainingImage(1000, 1200, CV_8UC3, Scalar(255, 255, 255));
	
	int delta = 40;
	int offset = delta;
	
	for (int font = 0; font < 6; font++) {
		putText(trainingImage, "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z", cvPoint(5, offset + font * 1), font, 1.0, cvScalar(0, 0, 0), 1, 8);
		offset += delta;
		putText(trainingImage, "a b c d e f g h i j k l m n o p q r s t u v w x y z", cvPoint(5, offset + font * 2), font, 1.0, cvScalar(0, 0, 0), 1, 8);
		offset += delta;
		putText(trainingImage, "0 1 2 3 4 5 6 7 8 9", cvPoint(5, offset + font * 3), font, 1.0, cvScalar(0, 0, 0), 1, 8);
		offset += delta;
		putText(trainingImage, "` ~ ! @ # $ % ^ & * ( ) - = _ + { } [ ] : \" ; ' , . / < > ?", cvPoint(5, offset + font * 4), font, 1.0, cvScalar(0, 0, 0), 1, 8);
		offset += delta;
	}

	vector<character> tableau = extract(preprocess(trainingImage, threshold), max, sized, quadrants, str);
	
	vector<character> recognized = extract(preprocess(image, threshold), max, sized, quadrants, str);

	tableau.insert(tableau.end(), recognized.begin(), recognized.end());

	return EXIT_SUCCESS;
}
