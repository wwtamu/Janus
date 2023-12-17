#include "character.h"

character::character() {};

character::character(Mat i, int2 os) {
	image = i;
	original_size = os;
}

character::character(Mat i, int2 os, char* b) {
	image = i;
	original_size = os;
	binary = b;
}

character::character(Mat i, int2 os, char* b, double* d) {
	image = i;
	original_size = os;
	binary = b;
	density = d;
}

character::character(Mat i, int2 os, char* b, char* vcp, char* hcp, double* d) {
	image = i;
	original_size = os;
	binary = b;
	vertical_celled_projection = vcp;
	horizontal_celled_projection = hcp;
	density = d;
}

Mat character::getImage() {
	return image;
}

int2 character::getOriginalSize() {
	return original_size;
}

char* character::getBinary() {
	return binary;
}

char* character::getVerticalCelledProjection() {
	return vertical_celled_projection;
}

char* character::getHorizontalCelledProjection() {
	return horizontal_celled_projection;
}

double* character::getDensity() {
	return density;
}

void character::setImage(Mat i) {
	image = i;
}

void character::setOriginalSize(int2 os) {
	original_size = os;
}

void character::setBinary(char* b) {
	binary = b;
}

void character::setVerticalCelledProjection(char* vcp) {
	vertical_celled_projection = vcp;
}

void character::setHorizontalCelledProjection(char* hcp) {
	horizontal_celled_projection = hcp;
}

void character::setDensity(double* d) {
	density = d;
}
