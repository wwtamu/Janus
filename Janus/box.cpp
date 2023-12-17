#include "box.h"

box::box() {};

box::box(int2 l, int w, int h) {
	location = l;
	width = w;
	height = h;
};

int2 box::getLocation() {
	return location;
}

int box::getWidth() {
	return width;
}

int box::getHeight() {
	return height;
}

void box::setLocation(int2 l) {
	location = l;
}

void box::setWidth(int w) {
	width = w;
}

void box::setHeight(int h) {
	height = h;
}