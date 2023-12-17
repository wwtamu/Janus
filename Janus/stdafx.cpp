#include "stdafx.h"

int _exit(char* message, int code) {
	cout << message << endl;
	system("pause");
	exit(code);
}