#' Discard lines whose codes do not occur in the Warlpiri dictionary skeleton grammar
#'
#' @param wlp_lexicon a Warlpiri lexicon data frame, or path to a Warlpiri dictionary file
#' @param grammar_file a Nearley grammar file (default is `wlp_skeleton-simple.ne`)
#'
#' @importFrom dplyr filter
#' @importFrom purrr discard map
#' @importFrom rlang sym
#' @importFrom stringr str_extract_all str_remove_all
#'
#' @export
#'

skeletonise_df <- function(wlp_lexicon, grammar_file = system.file("structures/wlp_skeleton-simple.ne", package = "yinarlingi")) {

    skeleton_codes <-
        readLines(grammar_file) %>%
        str_remove_all("#.*$") %>%      # discard Nearley comments
        str_extract_all('"(.*?)"') %>%  # get the literals, e.g. '"ant"'
        unlist() %>%
        str_remove_all('"') %>%         # remove literals' double quotes, '"ant"' -> 'ant'
        sort()

    wlp_lexicon %>%
        make_wlp_df() %>%
        filter(code1 %in% skeleton_codes)

}
