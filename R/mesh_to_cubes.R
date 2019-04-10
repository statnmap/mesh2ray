#' Get cubes coordinates from voxelized mesh3d
#'
#' @param mesh 3dmesh
#' @param scene_dim Dimensions of the scene (min and max coordinates). Vector of size 2 or 2*3 data.frame with named columns x, y, z.
#' @inheritParams Rvcg::vcgUniformRemesh
#'
#' @importFrom Rvcg vcgUniformRemesh
#' @importFrom dplyr as_tibble rename mutate summarise
#' @importFrom stats setNames
#' @importFrom scales rescale
#' @importFrom utils head
#'
#' @examples
#' library(Rvcg)
#' simple_mesh <- Rvcg::vcgIcosahedron()
#' cubes <- mesh_to_cubes(simple_mesh, voxelSize = 0.5)
#'
#' @export

mesh_to_cubes <- function(mesh, voxelSize, scene_dim = c(10, 545))  {

  if (length(scene_dim) == 2) {
    scene_dim <- as.data.frame(matrix(rep(scene_dim, 3), ncol = 3, byrow = FALSE)) %>%
      setNames(c("x", "y", "z"))
  }

  mesh_resample <- vcgUniformRemesh(mesh, voxelSize = voxelSize, multiSample = TRUE,
                                    discretize = TRUE)

  # as tibble
  mesh_resample_xyz <- t(mesh_resample$vb) %>%
    # t(humresample$vb) %>%
    as_tibble(.name_repair = "universal") %>%
    rename(x = ...1, y = ...2, z = ...3) %>%
    mutate(z_layer = as.numeric(as.factor(z)),
           z_alpha = LETTERS[z_layer])

  range_x <- range(mesh_resample_xyz$x, na.rm = TRUE)
  range_y <- range(mesh_resample_xyz$y, na.rm = TRUE)
  range_z <- range(mesh_resample_xyz$z, na.rm = TRUE)

  # Recalculate dimensions of the mesh inside the scene_dim provided
  # Find the smallest rescale ratio among x, y, or z
  ratios <- data.frame(
    x = diff(scene_dim$x)/diff(range_x),
    y = diff(scene_dim$y)/diff(range_y),
    z = diff(scene_dim$z)/diff(range_z)
  )
  # Get the size of the scene with iso ratio where will be the mesh
  scene_dim_iso <- data.frame(
    x = rep(diff(range_x) * min(ratios)/2, 2) * c(-1, 1) + mean(scene_dim$x),
    y = rep(diff(range_y) * min(ratios)/2, 2) * c(-1, 1) + mean(scene_dim$y),
    z = rep(diff(range_z) * min(ratios)/2, 2) * c(-1, 1) + mean(scene_dim$z)
  )

  # Calculate positions in the scene
  mesh_resample_xyz_scene <- mesh_resample_xyz %>%
    mutate(x_scene = rescale(x, to = scene_dim_iso$x, from = rev(range_x)),
           y_scene = rescale(y, to = scene_dim_iso$y, from = range_y),
           z_scene = rescale(z, to = scene_dim_iso$z, from = rev(range_z)))

  # Calculate cube dimensions
  cube_size <- mesh_resample_xyz_scene %>%
    summarise(x_diff = 2 * min(sort(unique(x_scene)) - c(NA, head(sort(unique(x_scene)), -1)), na.rm = TRUE),
              y_diff = 2 * min(sort(unique(y_scene)) - c(NA, head((sort(unique(y_scene))), -1)), na.rm = TRUE),
              z_diff = 2 * min(sort(unique(z_scene)) - c(NA, head((sort(unique(z_scene))), -1)), na.rm = TRUE))

  list(cube_center = mesh_resample_xyz_scene,
       cube_size = cube_size,
       mesh_resample = mesh_resample)

}



#' Add cubes to an existing scene
#'
#' @param scene scene
#' @param cubes cubes calculated with \code{mesh_to_cubes}
#' @param material 1 material or a tibble of materials (1 row for each cube) from rayrender. lambertian, dielectric
#'
#' @importFrom rayrender add_object lambertian
#'
#' @return
#' rayrender scene with cubes
#'
#' @examples
#' \dontrun{
#' library(Rvcg)
#' simple_mesh <- Rvcg::vcgIcosahedron()
#' cubes <- mesh_to_cubes(simple_mesh, voxelSize = 0.5, scene_dim = c(80, 475))
#'
#' library(rayrender)
#' scene <- generate_cornell(lightintensity = 10)
#' # _add cubes on scene
#' scene <- mesh2ray::add_cubes_to_scene(scene, cubes = cubes,
#'                                      material = lambertian(color = "ivory"))
#' render_scene(scene, lookfrom = c(278, 278, -800) ,
#'   lookat = c(278, 278, 0), fov = 40, ambient_light = FALSE,
#'   samples = 500, parallel = TRUE, clamp_value = 5)
#' }
#'
#' @export
#'
add_cubes_to_scene <- function(scene, cubes, material = lambertian(color = "ivory")) {

  if (nrow(material) != 1 & nrow(material) != nrow(cubes$cube_center)) {
    stop("material should be 1 matrial or a tibble with rows of same number of elements than number of cubes")
  }

  # for (i in 1:nrow(cubes$cube_center)) {
    all_cubes <- purrr::map_df(1:nrow(cubes$cube_center), function(i) {
      if (nrow(material) == 1) {mat = 1} else {mat = i}

      cube(x = cubes$cube_center$x_scene[i],
           y = cubes$cube_center$y_scene[i],
           z = cubes$cube_center$z_scene[i],
           xwidth = cubes$cube_size$x_diff,
           ywidth = cubes$cube_size$y_diff,
           zwidth = cubes$cube_size$z_diff,
           material = material[mat,])
    })

    scene <- add_object(scene, all_cubes)
  # }
  scene
}
