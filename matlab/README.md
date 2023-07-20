A matlab implementation of the morphological time window selection (MTWS) algorithm.

- `mtws.m` is the main function that accepts the input envelope and parameters and outputs the index of the left edge, the peak and the right edge of time windows.

  `[ileft,ipeak,iright] = mtws(envelope,time,maxfilt_kernel,offset)`

- Run `mtws_demo.m` for a simple example that demonstrates the MTWS algorithm.
