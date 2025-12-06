# shift
# set argv $argv[2..]

function pipefail -d "Get first error from previous pipe"
  for v in $pipestatus
    [ "$v" -eq 0 ] || return "$v"
  end
end

function fundesc -d "Get function description" -a func
  functions --details --verbose $func 2>/dev/null | tail -1
end

function pathtofile -d "Get a valid filename from a path" -a path
  echo "$path" | sed 's/[\/ ]/_/g'
end
