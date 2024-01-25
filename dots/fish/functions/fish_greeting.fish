function fish_greeting
  tput civis

  set sl 0.03
  echo -ne $fish_greeting | while read -l $line
    echo -e $line
    if test $sl -gt 0
      set sl $(math $sl - 0.001)
    end
    sleep $sl
  end

  set time $(uptime | sed -E 's|.*up\s+(.*),\s+[0-9]+\s+user.*|\1|g')
  echo -e "$(set_color bryellow )| no sleep for $(set_color red)$time$(set_color bryellow) and counting |$(set_color normal)"

  tput cnorm
end
