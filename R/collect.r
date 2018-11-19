#' Bring the disk.frame into R as data.table/data.frame
#' @import purrr furrr
#' @param df a disk.frame
#' @param parallel if TRUE the collection is performed in parallel. By default if there are delayed/lazy steps then it will be parallel, otherwise it will not be in parallel. This is because parallel requires transferring data from background R session to the current R session and if there is no computation then it's better to avoid tranferring data between session, hence parallel = F is a better choice
#' @export
#' @rdname collect
collect.disk.frame <- function(df, ..., parallel = !is.null(attr(df,"lazyfn"))) {
  if(nchunks(df) > 0) {
    if(parallel) {
      furrr::future_map_dfr(1:nchunks(df), ~get_chunk.disk.frame(df, .x))
    } else {
      purrr::map_dfr(1:nchunks(df), ~get_chunk.disk.frame(df, .x))
    }
  } else {
    data.table()
  }
}

#' Bring the disk.frame into R as list
#' @import purrr furrr
#' @export
#' @rdname collect
collect_list <- function(df, ... , simplify = F, parallel = !is.null(attr(df,"lazyfn"))) {
  if(nchunks(df) > 0) {
    res <- NULL
    if (parallel) {
      res = furrr::future_map(1:nchunks(df), ~get_chunk.disk.frame(df, .x))
    } else {
      res = purrr::map(1:nchunks(df), ~get_chunk.disk.frame(df, .x))
    }
    if (simplify) {
      return(simplify2array(res))
    } else {
      return(res)
    }
  } else {
    list()
  }
}