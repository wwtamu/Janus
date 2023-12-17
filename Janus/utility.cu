#include "utility.cuh"

static __global__ void encapsulate_kernel(int width, int height, int* artifact, int2* characters, int max)
{
	int x = blockIdx.x*blockDim.x + threadIdx.x;
	int y = blockIdx.y*blockDim.y + threadIdx.y;
	if (x < width && y < height)
	{
		if (artifact[y*width + x] == 0) {

			int2 character[4] = {
				{ x, y },
				{ x, y },
				{ x, y },
				{ x, y }
			};

			if (x != 0 && y != 0) {
				character[0].x--; 
				character[0].y--;
				character[1].y--;
				character[3].x--;
			}
			else if (x != width && y != height) {
				character[1].x++;
				character[2].x++;
				character[2].y++;
				character[3].y++;
			}

			bool finished = false, restart = false;

			int count = 0;

			while (!finished && count <= max) {

				if (!restart) {
					for (int i = 0; i < abs(character[0].x - character[1].x); i++) {

						if (artifact[character[0].y*width + (character[0].x + i)] == 0) {
							restart = true;
							character[0].y--;
							character[1].y--;

							break;
						}
					}
				}

				if (!restart) {
					for (int i = 0; i < abs(character[1].y - character[2].y); i++) {

						if (artifact[(character[1].y + i)*width + character[1].x] == 0) {
							restart = true;
							character[1].x++;
							character[2].x++;

							break;
						}
					}
				}

				if (!restart) {
					for (int i = 0; i < abs(character[2].x - character[3].x); i++) {

						if (artifact[character[2].y*width + (character[2].x - i)] == 0) {
							restart = true;
							character[2].y++;
							character[3].y++;

							break;
						}
					}
				}

				if (!restart) {
					for (int i = 0; i < abs(character[3].y - character[0].y); i++) {

						if (artifact[(character[3].y - i)*width + character[3].x] == 0) {
							restart = true;
							character[3].x--;
							character[0].x--;

							break;
						}
					}
				}

				if (!restart) {
					finished = true;
				}
				else {
					restart = false;
				}

				count++;

			}

			if (count < max) {

				//V[z][y][x] : z*s(y)*s(x) + y*s(x) + x

				characters[x*height * 4 + y * 4 + 0] = { character[0].x, character[0].y };
				characters[x*height * 4 + y * 4 + 1] = { character[1].x, character[1].y };
				characters[x*height * 4 + y * 4 + 2] = { character[2].x, character[2].y };
				characters[x*height * 4 + y * 4 + 3] = { character[3].x, character[3].y };
				
				for (int i = 0; i < abs(character[0].x - character[1].x); i++) {
					artifact[character[0].y*width + (character[0].x + i)] = 150;
				}
				for (int i = 0; i < abs(character[1].y - character[2].y); i++) {
					artifact[(character[1].y + i)*width + character[1].x] = 150;
				}
				for (int i = 0; i < abs(character[2].x - character[3].x); i++) {
					artifact[character[2].y*width + (character[2].x - i)] = 150;
				}
				for (int i = 0; i < abs(character[3].y - character[0].y); i++) {
					artifact[(character[3].y - i)*width + character[3].x] = 150;
				}
				
			}

		}

	}

}

static cudaError_t encapsulate(int width, int height, int* artifact, int2* characters, int max, int gx, int gy, int bx, int by)
{
	cudaError_t cudaStatusA;
	cudaError_t cudaStatusB;
	{
		dim3 grid(gx, gy, 1);
		dim3 block(bx, by, 1);
		encapsulate_kernel<<<grid, block>>>(width, height, artifact, characters, max);
	}
	cudaStatusA = cudaGetLastError(); if (cudaStatusA != cudaSuccess) { fprintf(stderr, "encapsulate_kernel launch failed: %s\n", cudaGetErrorString(cudaStatusA)); goto Error; }
	cudaStatusB = cudaDeviceSynchronize(); if (cudaStatusB != cudaSuccess) { fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching encapsulate_kernel!\n", cudaStatusB); goto Error; }
	;
Error:
	;
	return (cudaStatusA != cudaSuccess) ? cudaStatusA : (cudaStatusB != cudaSuccess) ? cudaStatusB : cudaSuccess;
}

Mat preprocess(Mat image, int threshold) {

	chrono::high_resolution_clock::time_point start = chrono::high_resolution_clock::now();

	cv::cvtColor(image, image, CV_BGR2GRAY);
	cv::threshold(image, image, threshold, 255, CV_THRESH_BINARY);

	chrono::high_resolution_clock::time_point stop = chrono::high_resolution_clock::now();

	cout << "preprocess: " << chrono::duration_cast<chrono::milliseconds>(stop - start).count() << " milliseconds" << endl << endl;

	if (DISPLAY_AFTER_PREPROCESS) {

		namedWindow("Janus", WINDOW_AUTOSIZE);
		imshow("Janus", image);

		waitKey(0);

	}

	return image;
}

vector<character> extract(Mat image, int max, int sized, int quadrants, string filename) {

	int GRID_X = ((image.cols + THREAD_X - 1) / THREAD_X);
	int GRID_Y = ((image.rows + THREAD_Y - 1) / THREAD_Y);

	chrono::high_resolution_clock::time_point start = chrono::high_resolution_clock::now();

	int* artifact = (int*)malloc(image.cols*image.rows*sizeof(int));

	int2* characters = (int2*)malloc(image.cols*image.rows * 4 * sizeof(int2));


	int* devArtifact; cudaMalloc((void **)&devArtifact, image.cols*image.rows*sizeof(int));

	int2* devCharacters; cudaMalloc((void **)&devCharacters, image.cols*image.rows * 4 * sizeof(int2));


	for (int x = 0; x < image.cols; x++) {

		for (int y = 0; y < image.rows; y++) {

			//V[z][y][x] : z*s(y)*s(x) + y*s(x) + x

			characters[x*image.rows * 4 + y * 4 + 0] = { -1, -1 };
			characters[x*image.rows * 4 + y * 4 + 1] = { -1, -1 };
			characters[x*image.rows * 4 + y * 4 + 2] = { -1, -1 };
			characters[x*image.rows * 4 + y * 4 + 3] = { -1, -1 };
			
			Scalar intensity = image.at<uchar>(y, x);

			artifact[y*image.cols + x] = (int)intensity.val[0];
		}
	}


	cudaMemcpy(devArtifact, artifact, image.cols*image.rows * sizeof(int), cudaMemcpyHostToDevice);

	cudaMemcpy(devCharacters, characters, image.cols*image.rows * 4 * sizeof(int2), cudaMemcpyHostToDevice);
	

	if (encapsulate(image.cols, image.rows, devArtifact, devCharacters, max, GRID_X, GRID_Y, THREAD_X, THREAD_Y) != cudaSuccess) {
		_exit("encapsulation failed", EXIT_FAILURE);
	}


	cudaMemcpy(artifact, devArtifact, image.cols*image.rows*sizeof(int), cudaMemcpyDeviceToHost);

	cudaMemcpy(characters, devCharacters, image.cols*image.rows * 4 * sizeof(int2), cudaMemcpyDeviceToHost);

	cudaFree(devArtifact);
	cudaFree(devCharacters);


	set<box> boxes;

	for (int i = 0; i < image.cols*image.rows * 4; i += 4) {

		if (characters[i].x > 0) {

			if (abs(characters[i + 1].x - characters[i].x) > 2 && abs(characters[i + 2].y - characters[i + 1].y) > 2) {
				boxes.insert(box(make_int2(characters[i].x, characters[i].y), abs(characters[i + 1].x - characters[i].x)/* + 1*/, abs(characters[i + 2].y - characters[i + 1].y)/* + 1*/));
			}

		}

	}

	
	Size size(sized, sized);

	vector<character> tableau;

	set<box>::iterator it;

	int count = 1;

	for (it = boxes.begin(); it != boxes.end(); ++it) {

		box boxed_character = *it;
		
		// how often does it go out of bounds? how far out of bounds does it go? should be handled when making boxed_character
		if ((boxed_character.getLocation().x + boxed_character.getWidth()) <= image.cols && 
			(boxed_character.getLocation().y + boxed_character.getHeight()) <= image.rows) 
		{

			Mat sub_image(image, Rect(boxed_character.getLocation().x, boxed_character.getLocation().y, boxed_character.getWidth(), boxed_character.getHeight()));

			int2 original_size = { sub_image.cols, sub_image.rows };

			if (SHOW_LOCATION) {
				cout << "location: " << boxed_character.getLocation().x << "," << boxed_character.getLocation().y << endl;
			}
			if (SHOW_ORIGINAL_SIZE) {
				cout << "original size: " << original_size.x << "," << original_size.y << endl;
			}

			Mat sized_character;

			resize(sub_image, sized_character, size);

			char* vertical_celled_projection = (char*)malloc(sized_character.cols*sized_character.rows*sizeof(char));
			char* horizontal_celled_projection = (char*)malloc(sized_character.cols*sized_character.rows*sizeof(char));


			char* binary = (char*)malloc(sized_character.cols*sized_character.rows*sizeof(char));

			double* density = (double*)malloc(quadrants*quadrants*sizeof(double));

			int* ones = (int*)malloc(quadrants*quadrants*sizeof(int));
			int* zeroes = (int*)malloc(quadrants*quadrants*sizeof(int));

			int quad_size = sized / quadrants;

			int index = 0;
			int _ones = 0;
			int _zeroes = 0;

			for (int qx = 0; qx < sized_character.cols; qx += quad_size) {
				for (int qy = 0; qy < sized_character.rows; qy += quad_size) {
					for (int x = qx; x < qx + quad_size; x++) {
						for (int y = qy; y < qy + quad_size; y++) {
							if (sized_character.at<uchar>(x, y) == 255) {
								binary[x*sized_character.rows + y] = '0';
								_zeroes++;
							}
							else {
								binary[x*sized_character.rows + y] = '1';
								_ones++;
							}
							vertical_celled_projection[x*sized_character.rows + y] = '0';
							horizontal_celled_projection[x*sized_character.rows + y] = '0';
						}
					}
					ones[index] = _ones;
					zeroes[index] = _zeroes;
					_ones = 0;
					_zeroes = 0;
					index++;
				}

			}
			
			if (SHOW_BINARY_REPRESENTATION) {
				cout << "binary representation" << endl << endl;
				for (int x = 0; x < sized_character.cols; x++) {
					for (int y = 0; y < sized_character.rows; y++) {
						cout << binary[x*sized_character.rows + y];
					}
					cout << endl;
				}
				cout << endl;
			}


			if (SHOW_VERTICAL_CELLED_PROJECTION) {
				cout << "density matrix" << endl << endl;
				for (int x = 0; x < quadrants; x++) {
					for (int y = 0; y < quadrants; y++) {
						density[x*quadrants + y] = (double)ones[x*quadrants + y] / (double)(ones[x*quadrants + y] + zeroes[x*quadrants + y]);
						if (y < quadrants - 1) {
							printf("%.2f,", density[x*quadrants + y]);
						}
						else {
							printf("%.2f", density[x*quadrants + y]);
						}
					}
					cout << endl;
				}
				cout << endl;
			}

			int slice_gap = sized / quadrants;

			for (int sx = 0; sx < sized_character.cols; sx += slice_gap) {
				for (int x = sx; x < sx + slice_gap; x++) {
					for (int y = 0; y < sized_character.rows; y++) {
						if (binary[x*sized_character.rows + y] == '1') {
							vertical_celled_projection[sx*sized_character.rows + y] = '1';
						}
					}
				}
			}

			for (int sy = 0; sy < sized_character.rows; sy += slice_gap) {
				for (int y = sy; y < sy + slice_gap; y++) {
					for (int x = 0; x < sized_character.cols; x++) {
						if (binary[x*sized_character.rows + y] == '1') {
							horizontal_celled_projection[x*sized_character.rows + sy] = '1';
						}
					}
				}
			}

			if (SHOW_VERTICAL_CELLED_PROJECTION) {
				cout << "vertical celled projection" << endl << endl;
				for (int x = 0; x < sized_character.cols; x++) {
					for (int y = 0; y < sized_character.rows; y++) {
						cout << vertical_celled_projection[x*sized_character.rows + y];
					}
					cout << endl;
				}
				cout << endl;
			}


			if (SHOW_HORIZONTAL_CELLED_PROJECTION) {
				cout << "horizontal celled projection" << endl << endl;
				for (int x = 0; x < sized_character.cols; x++) {
					for (int y = 0; y < sized_character.rows; y++) {
						cout << horizontal_celled_projection[x*sized_character.rows + y];
					}
					cout << endl;
				}
				cout << endl;
			}


			if (WRITE_CHARACTER_IMAGE_FILE) {
				imwrite("output/character" + to_string(count) + ".jpg", sized_character);
				count++;
			}

			if (DESCRIBE_CHARACTER) {
				namedWindow("Janus", WINDOW_AUTOSIZE);
				imshow("Janus", sized_character);
				char c = waitKey(0);
				cout << c << endl;
			}

			if (0) cout << endl;

			tableau.push_back(character(sized_character, original_size, binary, vertical_celled_projection, horizontal_celled_projection, density));

			free(binary);
			free(ones);
			free(zeroes);
			free(density);
		}
		else {
			cout << "box out of bounds" << endl;
		}
		
	}

	cout << tableau.size() << " characters in tableau" << endl << endl;


	for (int x = 0; x < image.cols; x++) {

		for (int y = 0; y < image.rows; y++) {

			image.at<uchar>(y, x) = artifact[y*image.cols + x];

		}
	}


	free(artifact);
	free(characters);

	
	chrono::high_resolution_clock::time_point stop = chrono::high_resolution_clock::now();

	cout << "extracting: " << chrono::duration_cast<chrono::milliseconds>(stop - start).count() << " milliseconds" << endl;


	if (DISPLAY_AFTER_EXTRACTION) {
		
		imwrite("output/" + filename + ".jpg", image);

		namedWindow("Janus", WINDOW_AUTOSIZE);
		imshow("Janus", image);

		waitKey(0);

	}

	return tableau;
}