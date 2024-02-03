import Control.Monad
import Libnotify
import Libnotify qualified as LN
import XMonad
import XMonad.Config.Desktop
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Util.EZConfig
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Util.Loggers
import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders (noBorders)

main :: IO ()
main = do
  xmonad
    . ewmh
    . ewmhFullscreen
    . withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) defToggleStrutsKey
    $ myConfig

myConfig =
  desktopConfig
    { terminal = term,
      modMask = mod4Mask,
      layoutHook = spacingWithEdge 10 layout,
      normalBorderColor = "#3c3c3c",
      focusedBorderColor = "black"
    }
    `additionalKeysP` myKeys

popup :: String -> X ()
popup s = liftIO $ void $ LN.display $ summary s

myKeys :: [(String, X ())]
myKeys =
  [ ("C-<Print>", spawn "scrot -s"),
    ("<Print>", spawn "scrot"),
    ( "M-r",
      do
        popup "restarting"
        restart "/home/hunter/config/dots/xmonad/result/bin/xmonad" True
    ),
    ("M-d", spawn "main-menu"),
    ("M-n", liftIO $ void $ LN.display $ summary "hey"),
    ("<XF86AudioRaiseVolume>", spawn "cpanel volup"),
    ("<XF86AudioLowerVolume>", spawn "cpanel voldown"),
    ("<XF86AudioMute>", spawn "cpanel volmute"),
    ("<XF86MonBrightnessUp>", spawn "cpanel blup"),
    ("<XF86MonBrightnessDown>", spawn "cpanel bldown"),
    ("M-C-<Return>", spawn (term ++ " " ++ shell))
  ]

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = magenta " • "
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2
    , ppHidden          = white . wrap " " ""
    , ppHiddenNoWindows = lowWhite . wrap " " ""
    , ppUrgent          = red . wrap (yellow "!") (yellow "!")
    , ppOrder           = \[ws, l, _, wins] -> [ws, l, wins]
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where
    formatFocused   = wrap (white    "[") (white    "]") . magenta . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . blue    . ppWindow

    -- | Windows should have *some* title, which should not not exceed a
    -- sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

    blue, lowWhite, magenta, red, white, yellow :: String -> String
    magenta  = xmobarColor "#ff79c6" ""
    blue     = xmobarColor "#bd93f9" ""
    white    = xmobarColor "#f8f8f2" ""
    yellow   = xmobarColor "#f1fa8c" ""
    red      = xmobarColor "#ff5555" ""
    lowWhite = xmobarColor "#bbbbbb" ""

term, shell :: String
term = "kitty"
shell = "fish"

layout = tiled ||| Mirror tiled ||| noBorders Full
  where
    tiled = Tall nmaster delta ratio
    nmaster = 1
    ratio = 13 / 21
    delta = 3 / 100
