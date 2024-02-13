let carapace_completer = {|spans|
carapace $spans.0 nushell $spans | from json
}
$env.config = {
 show_banner: false,
 completions: {
 case_sensitive: false # case-sensitive completions
 quick: true    # set to false to prevent auto-selecting completions
 partial: true    # set to false to prevent partial filling of the prompt
 algorithm: "fuzzy"    # prefix or fuzzy
 external: {
     enable: true
     max_results: 100
     completer: $carapace_completer
   }
 }
}
$env.PATH = ($env.PATH |
split row (char esep) |
append /usr/bin/env
)
