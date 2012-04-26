import numpy as np
import scipy.ndimage
cimport numpy as np
cimport cython


@cython.boundscheck(False)
@cython.wraparound(False)
def _threshold_adaptive(np.ndarray[np.double_t, ndim=2] image, int block_size,
                        method, double offset, mode, param):
    cdef int r, c
    cdef np.ndarray[np.float64_t, ndim=2] thres_image

    if method == 'generic':
        thres_image = scipy.ndimage.generic_filter(image, param, block_size,
            mode=mode)
    elif method == 'gaussian':
        if param is None:
            # automatically determine sigme which covers > 99% of distribution
            sigma = (block_size - 1) / 6.0
        thres_image = scipy.ndimage.gaussian_filter(image, sigma, mode=mode)
    elif method == 'mean':
        mask = 1. / block_size * np.ones((block_size,))
        # separation of filters to speedup convolution
        thres_image = scipy.ndimage.convolve1d(image, mask, axis=0, mode=mode)
        thres_image = scipy.ndimage.convolve1d(thres_image, mask, axis=1,
            mode=mode)
    elif method == 'median':
        thres_image = scipy.ndimage.median_filter(image, block_size, mode=mode)

    for r in range(image.shape[0]):
        for c in range(image.shape[1]):
            thres_image[r,c] = image[r,c] > (thres_image[r,c] - offset)

    return thres_image.astype('bool')
