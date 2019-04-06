#' Mesh3d to raster
#'
#' @param x mesh3d object
#' @param res resolution of the resulting raster. 1 or 2 values for nrows, ncols.
#'
#' @return
#' A raster
#'
#' @importFrom raster raster extent setValues xyFromCell ncell
#' @importFrom geometry tsearch
#' @importFrom methods is
#'
#' @export
#'
#' @examples
#' library(Rvcg)
#' data(humface)
#' r <- mesh_to_raster(humface)
mesh_to_raster <- function(x, res = 150) {

  if (!any(is(x) == "mesh3d")) {stop("x should be a mesh3d object")}
  if (length(res) == 1) {res <- rep(res, 2)}

  triangle_xy <- t(x$vb[1:2, ])
  ## Build a target raster with extent of the mesh
  raster_grid <- raster(extent(triangle_xy), nrows = res[1], ncols = res[2])
  raster_grid <- setValues(raster_grid, NA_real_)
  # Extract x/y coordinates of the raster
  raster_xy <- xyFromCell(raster_grid, seq_len(ncell(raster_grid)))

  ## the magic barycentric index, the interpolation engine for the target grid vertices
  ## and where they fall in each triangle relative to triangle vertices
  pid0 <- tsearch(x = triangle_xy[,1], y = triangle_xy[,2],
                  t = t(x$it),
                  xi = raster_xy[,1], yi = raster_xy[, 2],
                  bary = TRUE)

  # Determine raster cell center that really fall in a triangle of the mesh
  ok <- !is.na(pid0$idx)
  # Calculate linear interpolation of the z value using distances to vertices
  raster_grid[ok] <- colSums(matrix(x$vb[3, x$it[, pid0$idx[ok]]], nrow = 3) * t(pid0$p)[, ok])
  return(raster_grid)
}
