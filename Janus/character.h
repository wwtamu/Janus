#include "stdafx.h"

class character {

private:

	Mat image;
	int2 original_size;
	char* binary;
	char* vertical_celled_projection;
	char* horizontal_celled_projection;
	double* density;

public:

	character();
	character(Mat i, int2 os);
	character(Mat i, int2 os, char* b);
	character(Mat i, int2 os, char* b, double* density);
	character(Mat i, int2 os, char* b, char* vcp, char* hcp, double* density);

	Mat getImage();
	int2 getOriginalSize();
	char* getBinary();
	char* getVerticalCelledProjection();
	char* getHorizontalCelledProjection();
	double* getDensity();

	void setImage(Mat i);
	void setOriginalSize(int2 os);
	void setBinary(char* b);
	void setVerticalCelledProjection(char* vcp);
	void setHorizontalCelledProjection(char* hcp);
	void setDensity(double* d);
	
};