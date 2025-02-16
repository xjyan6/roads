# Copyright 2018 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#NOTICE: This function has been modified from https://github.com/bcgov/clus/blob/master/R/SpaDES-modules/roadCLUS/roadCLUS.R


#' Get shortest path between points in list
#' 
#' @param sim sim list
#' @noRd
shortestPaths<- function(sim){
  # finds the least cost paths between a list of two points
  if(!length(sim$paths.list) == 0){
    #create a list of shortest paths
    paths <- unlist(lapply(sim$paths.list,
                           function(x){
                             igraph::get.shortest.paths(sim$g, x[1], 
                                                        x[2], out = "both") 
                           } ))
    
    paths.v <- paths[grepl("vpath", names(paths))] 
    
    # save the vertices for mapping
    sim$paths.v <- rbind(data.table::data.table(paths.v), 
                         sim$paths.v) 
    
    # use vertices to update cost raster to 0 at new roads need copy so old cost
    # available in pathsToLines
    sim$costSurfaceNew <- sim$costSurface
    sim$costSurfaceNew[unique(paths.v)] <- 0
    
    # get edges for updating graph
    paths.e <- paths[grepl("epath", names(paths))]
    
    rm(paths)
    
    # updates the cost(weight) associated with the edge that became a road
    igraph::edge_attr(sim$g, 
                      index = igraph::E(sim$g)[igraph::E(sim$g) %in% paths.e],
                      name = "weight") <- 0.00001 
    
    rm(paths.e)

  }
  return(invisible(sim))
}

#' Get shortest path between points in list updating cost after each
#' 
#' @param sim sim list
#' @noRd
dynamicShortestPaths<- function(sim){
  # finds the least cost paths between a list of two points
  if(!length(sim$paths.list) == 0){
    #create a list of shortest paths
    path.vs <- vector("list", length = length(sim$paths.list))
    
    for (i in seq_along(sim$paths.list)) {
      path.list <- sim$paths.list[[i]]
      path <- igraph::get.shortest.paths(sim$g, path.list[1], path.list[2], out = "both")
      
      path <- unlist(path)
      
      # update the cost(weight) associated with the edge that became a road
      igraph::edge_attr(sim$g, 
                        index = igraph::E(sim$g)[igraph::E(sim$g) %in% path[grepl("epath", names(path))]],
                        name = "weight") <- 0.00001 
      
      # get vertices
      path.vs[[i]] <- data.table::data.table(path[grepl("vpath", names(path))] )
    }
    paths.v <-  do.call(rbind, path.vs)
    
    # use vertices to update cost raster to 0 at new roads need copy so old cost
    # available in pathsToLines
    sim$costSurfaceNew <- sim$costSurface
    sim$costSurfaceNew[unique(paths.v)$V1] <- 0
    
    sim$paths.v <- rbind(sim$paths.v, paths.v)
    
  }
  return(invisible(sim))
}
