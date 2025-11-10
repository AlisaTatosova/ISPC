struct Complex {
    varying float r;
    varying float i;
};

inline Complex complex_add(Complex a, Complex b) {
    Complex res;
    res.r = a.r + b.r;
    res.i = a.i + b.i;
    return res;
}

inline Complex complex_sub(Complex a, Complex b) {
    Complex res;
    res.r = a.r - b.r;
    res.i = a.i - b.i;
    return res;
}

inline Complex complex_mul(Complex a, Complex b) {
    Complex res;
    res.r = a.r * b.r - a.i * b.i;
    res.i = a.r * b.i + a.i * b.r;
    return res;
}

inline Complex complex_div(Complex a, Complex b) {
    Complex res;
    varying float denom = b.r * b.r + b.i * b.i;
    varying bool valid = denom != 0.0f;
    if (any(valid)) {
        res.r = (a.r * b.r + a.i * b.i) / denom;
        res.i = (a.i * b.r - a.r * b.i) / denom;
    } else {
        res.r = a.r;
        res.i = a.i;
    }
    return res;
}

inline Complex complex_pow(Complex z, uniform int n) {
    Complex res = z;
    for (uniform int k = 1; k < n; k++)
        res = complex_mul(res, z);
    return res;
}

inline Complex newton_step(Complex z, uniform int n) {
    Complex fz = complex_pow(z, n);
    fz.r -= 1.0f;                      // f(z) = z^n - 1

    Complex dfz = complex_pow(z, n - 1);
    dfz.r *= n;
    dfz.i *= n;

    Complex ratio = complex_div(fz, dfz);
    return complex_sub(z, ratio);      // z = z - f/f'
}

inline varying int find_root_index(Complex z, uniform int n, uniform float tol) {
    varying int result = -1;
    for (uniform int k = 0; k < n; k++) {
        uniform float angle = 2.0f * 3.1415926f * k / n;
        uniform float rr = cos(angle);
        uniform float ri = sin(angle);
        varying float dist2 = (z.r - rr)*(z.r - rr) + (z.i - ri)*(z.i - ri);
        if (result < 0 & dist2 < tol)
            result = k;
    }
    return result;
}

export void compute_fractal(
    uniform float *uniform output,
    uniform int width,
    uniform int height,
    uniform float xmin,
    uniform float xmax,
    uniform float ymin,
    uniform float ymax,
    uniform int max_iter,
    uniform int n,
    uniform float tol) {

    foreach (index = 0 ... (width * height)) {
        int i = index % width;
        int j = index / width;

        Complex z;
        z.r = xmin + (xmax - xmin) * (float)i / (width - 1);
        z.i = ymin + (ymax - ymin) * (float)j / (height - 1);

        varying int iter = 0;
        varying int root_index = -1;

        while (any(iter < max_iter & root_index < 0)) {
            z = newton_step(z, n);
            varying int root = find_root_index(z, n, tol);
            if (any(root >= 0))
                root_index = select(root_index, root, root_index < 0 & root >= 0);
            iter += 1;
        }

        float hue = (root_index >= 0) ? ((float)root_index / n) : 0.0f;
        float brightness = (iter < max_iter) ? (1.0f - (float)iter / max_iter) : 0.0f;

        output[index * 3 + 0] = hue;
        output[index * 3 + 1] = 1.0f;
        output[index * 3 + 2] = brightness;
    }
}
