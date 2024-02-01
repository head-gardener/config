import XMonad
import XMonad.Config.Desktop

main :: IO ()
main = xmonad desktopConfig
  { terminal    = "kitty"
  , modMask     = mod4Mask
  }
