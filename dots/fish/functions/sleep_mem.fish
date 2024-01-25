function sleep_mem --wraps='echo mem | doas tee /sys/power/state' --description 'alias sleep_mem=echo mem | doas tee /sys/power/state'
  echo mem | doas tee /sys/power/state $argv
        
end
