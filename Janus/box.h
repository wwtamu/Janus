#include "stdafx.h"

class box {

private:

	int2 location;

	int width;
	int height;

public:

	box();
	box(int2 l, int w, int h);

	int2 getLocation();
	int getWidth();
	int getHeight();

	void setLocation(int2 l);
	void setWidth(int w);
	void setHeight(int h);

	friend bool operator < (const box& lhs, const box& rhs)
	{
		if (lhs.location.x < rhs.location.x) {
			return true;
		}
		else if (lhs.location.x == rhs.location.x) {
			if (lhs.location.y < rhs.location.y) {
				return true;
			}
		}
		return false;
	}

};