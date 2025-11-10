#include <iostream>
#include <cmath>
#include <vector>
#include "newton.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

static void hsv_to_rgb(float h, float s, float v, unsigned char& r, unsigned char& g, unsigned char& b) {
    float c = v * s;
    float x = c * (1 - fabs(fmod(h * 6, 2) - 1));
    float m = v - c;
    float r1, g1, b1;

    if (h < 1.0/6)      { 
        r1 = c; g1 = x; b1 = 0; 
    } else if (h < 2.0/6) { 
        r1 = x; g1 = c; b1 = 0; 
    } else if (h < 3.0/6) {
        r1 = 0; g1 = c; b1 = x; 
    } else if (h < 4.0/6) { 
        r1 = 0; g1 = x; b1 = c; 
    } else if (h < 5.0/6) { 
        r1 = x; g1 = 0; b1 = c; 
    } else { 
        r1 = c; g1 = 0; b1 = x; 
    }

    r = (unsigned char)((r1 + m) * 255);
    g = (unsigned char)((g1 + m) * 255);
    b = (unsigned char)((b1 + m) * 255);
}

int main(int argc, char *argv[]) {
    int n = 5;
    if (argc > 1) {
        n = atoi(argv[1]);
    }

    std::cout << "Generating Newton Fractal for z^" << n << " - 1 = 0\n";

    const int width = 1024, height = 1024;
    const float xmin = -2.0f, xmax = 2.0f, ymin = -2.0f, ymax = 2.0f;
    const int max_iter = 50;
    const float tol = 1e-3f;

    std::vector<float> hsv(width * height * 3);
    ispc::compute_fractal(hsv.data(), width, height, xmin, xmax, ymin, ymax, max_iter, n, tol);

    std::vector<unsigned char> rgb(width * height * 3);
    for (int i = 0; i < width * height; i++) {
        hsv_to_rgb(hsv[i*3], hsv[i*3+1], hsv[i*3+2], rgb[i*3], rgb[i*3+1], rgb[i*3+2]);
    }

    stbi_write_png("newton_fractal.png", width, height, 3, rgb.data(), width * 3);
    std::cout << "Saved to newton fractal.png\n";
    return 0;
}
