function sleep_freeze --wraps='echo freeze | doas tee /sys/power/state' --description 'alias sleep_freeze=echo freeze | doas tee /sys/power/state'
  echo freeze | doas tee /sys/power/state $argv
        
end
