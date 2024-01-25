function sleep_disk --wraps='echo disk | doas tee /sys/power/state' --description 'alias sleep_disk=echo disk | doas tee /sys/power/state'
  echo disk | doas tee /sys/power/state $argv
        
end
