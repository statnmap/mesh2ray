% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mesh_to_cubes.R
\name{mesh_to_cubes}
\alias{mesh_to_cubes}
\title{Get cubes coordinates from voxelized mesh3d}
\usage{
mesh_to_cubes(mesh, voxelSize, scene_dim = c(10, 545))
}
\arguments{
\item{mesh}{3dmesh}

\item{voxelSize}{voxel size for space discretization}

\item{scene_dim}{Dimensions of the scene (min and max coordinates). Vector of size 2 or 2*3 data.frame with named columns x, y, z.}
}
\description{
Get cubes coordinates from voxelized mesh3d
}
\examples{
library(Rvcg)
simple_mesh <- Rvcg::vcgIcosahedron()
cubes <- mesh_to_cubes(simple_mesh, voxelSize = 0.5)

}
