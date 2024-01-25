#!/usr/bin/env fish

function rainbowify -d "Rainbow-ify text"
  set -l RAINBOW red FF8800 yellow green blue purple

  set LENGTH (string length $argv)
  set SPLIT (string split '' $argv)

  for i in (seq $LENGTH)
    set PERC (math -s2 $i / $LENGTH)
    set _STEP (math "$PERC * 6.0")
    set STEP (printf '%.0f' (echo "$_STEP/1" | bc -l))
    if [ $STEP = 0 ]
      set STEP 1
    end

    echo -n (set_color $RAINBOW[$STEP])$SPLIT[$i]
  end
  set_color normal
end

echo "#!/usr/bin/env fish" > colors.fish
echo "" >> colors.fish
chmod +x colors.fish

for i in (set -n | string match 'fish*_color*')
  echo "set -U $i $$i" >> colors.fish
end

echo "echo \""(rainbowify "Fish colors have been set")"\"" >> colors.fish

echo "Exported your "(rainbowify "colors")" to "(set_color cyan --underline)"colors.fish"(set_color normal)
echo "Now, just copy that file to your remote machine and run it."
