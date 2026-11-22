# Open a throwaway graphics device for the duration of a test, so plotting
# tests draw nothing to disk or screen and always clean up after themselves.
local_null_device <- function(env = parent.frame()) {
  grDevices::pdf(NULL)
  device <- grDevices::dev.cur()
  withr::defer(grDevices::dev.off(device), envir = env)
  invisible(device)
}
