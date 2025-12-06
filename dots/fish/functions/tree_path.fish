function tree_path -d "Tree a nix path" -a target
  argparse --min-args=1 --max-args=1 'l/less' -- $argv
  or return 1;

  fd -d1 -td "$argv[1]" /nix/store/ \
    | xargs tree -C \
    | if set -ql _flag_less; $PAGER; else; cat; end
end
