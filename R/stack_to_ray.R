#' Image and elevation to Rayshader
#'
#' @param elevation Raster for elevation or path to elevation raster with same number of rows/cols
#' @param image RasterStack or path to png image. If not same dimension, image is resampled
#'
#' @importFrom methods is
#' @importFrom raster raster stack compareRaster extent as.array as.matrix resample setExtent
#'
#' @return
#' A list with 'elevation' for the elevation matrix and 'overlay' for the rgb overlay from the 'image'
#'
#' @export
stack_to_ray <- function(elevation, image = NULL) {

  if (is(elevation)[1] != "RasterLayer") {elevation <- raster(elevation)}

  # Elevation matrix
  datamat <- t(as.matrix(elevation))

  if (!is.null(image)) {
    r_rgb <- stack(image)

    if (!compareRaster(r_rgb, elevation, extent = FALSE, rowcol = TRUE, crs = FALSE, stopiffalse = FALSE)) {
      r_rgb <- setExtent(r_rgb, extent(elevation))
    }
    if (!compareRaster(r_rgb, elevation, extent = TRUE, rowcol = TRUE, crs = FALSE, stopiffalse = FALSE)) {
      r_rgb_res <- resample(r_rgb, elevation, method = "ngb")
      r_rgb_array <- as.array(r_rgb_res/255)
    } else {
      r_rgb_array <- as.array(r_rgb/255)
    }

    if (dim(r_rgb_array)[3] == 4) {
      # Change NA to 0 in dim 4 (alpha layer)
      r_rgb_array[,,4][which(is.na(r_rgb_array[,,4]))] <- 0
    }
  } else {
    r_rgb_array <- NULL
  }

  list(
    elevation = datamat,
    overlay = r_rgb_array)
}
