import Control.Monad
import Data.Semigroup (Endo)
import Libnotify
import Libnotify qualified as LN
import XMonad
import XMonad.Actions.Commands
import XMonad.Actions.CycleRecentWS (toggleRecentNonEmptyWS)
import XMonad.Actions.DwmPromote (dwmpromote)
import XMonad.Actions.EasyMotion
import XMonad.Actions.FindEmptyWorkspace (tagToEmptyWorkspace, viewEmptyWorkspace)
import XMonad.Actions.GridSelect
import XMonad.Actions.Search
import XMonad.Config.Desktop
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.Circle
import XMonad.Layout.DecorationMadness (circleDefault, circleSimpleDefault)
import XMonad.Layout.NoBorders (noBorders)
import XMonad.Layout.Spacing
import XMonad.StackSet qualified as W
import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import XMonad.Util.Run

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
      manageHook = myManage,
      layoutHook = spacingWithEdge 10 layout,
      normalBorderColor = "#3c3c3c",
      focusedBorderColor = "black"
    }
    `additionalKeysP` toKeys myKeys

myManage =
  composeAll
    [ className =? "Xmessage" --> doFloat,
      className =? "Conky" --> doIgnore,
      manageDocks
    ]

notif :: String -> X ()
notif s =
  liftIO $
    void $
      LN.display $
        summary "XMonad notification" <> LN.body s

toKeys :: [(String, String, X ())] -> [(String, X ())]
toKeys = fmap (\(a, _, b) -> (a, b))

toCommands :: [(String, String, X ())] -> [(String, X ())]
toCommands = fmap (\(a, b, c) -> (a ++ ": " ++ b, c))

myKeys :: [(String, String, X ())]
myKeys =
  [ ("C-<Print>", "screenshot select", spawn "scrot -s"),
    ("<Print>", "screenshot", spawn "scrot"),
    ( "M-r",
      "restart from dev dir",
      do
        notif "restarting"
        restart "/home/hunter/config/dots/xmonad/result/bin/xmonad" True
    ),
    ("M-d", "main menu", spawn "main-menu"),
    ("<XF86AudioRaiseVolume>", "vol up", spawn "cpanel volup"),
    ("<XF86AudioLowerVolume>", "vol down", spawn "cpanel voldown"),
    ("<XF86AudioMute>", "vol mute", spawn "cpanel volmute"),
    ("<XF86MonBrightnessUp>", "backlight up", spawn "cpanel blup"),
    ("<XF86MonBrightnessDown>", "backlight down", spawn "cpanel bldown"),
    ("M-C-<Return>", "spawn no-tmux shell", spawn (term ++ " " ++ shell)),
    ("M-c", "run command", myCommands >>= runCommand),
    ("M-a", "toggle non-empty ws", toggleRecentNonEmptyWS),
    ("M-m", "dwm promote", dwmpromote),
    ("M-e", "find empty", viewEmptyWorkspace),
    ("M-S-e", "tag to empty", tagToEmptyWorkspace),
    ("M-f", "easy motion", selectWindow myEasyMotion >>= (`whenJust` windows . W.focusWindow)),
    ("M-s", "search", do
      eng <- gridselect myGSConfig searchEngines
      maybe (return ()) (promptSearch def) eng),
    ("M-g", "grid select goto", goToSelected myGSConfig),
    ( "M-C-p",
      "colorpicker",
      do
        c <- runProcessWithInput "xcolor" [] ""
        xmessage c
    )
  ]

searchEngines :: [(String, SearchEngine)]
searchEngines =
  [ ("duck", duckduckgo),
    ("github", github),
    ("home-manager", searchEngine "home-manager" "https://mipmip.github.io/home-manager-option-search/?query="),
    ("nixos-packages", searchEngine "nixos packages" "https://search.nixos.org/packages?channel=23.11&from=0&size=50&sort=relevance&type=packages&query="),
    ("nixos-options", searchEngine "nixos options" "https://search.nixos.org/options?channel=23.11&size=50&sort=relevance&type=packages&query="),
    ("stackage", stackage)
  ]

myEasyMotion :: EasyMotionConfig
myEasyMotion =
  def
    { txtCol = cs_white defaultCS,
      bgCol = cs_black defaultCS,
      borderCol = cs_white defaultCS,
      overlayF = textSize,
      cancelKey = xK_Escape,
      emFont = "xft: LilexNerdFont-100"
    }

keyRef :: X ()
keyRef = runCommand $ toCommands myKeys

-- https://hackage.haskell.org/package/xmonad-contrib-0.18.0/docs/XMonad-Actions-GridSelect.html
myGSConfig :: GSConfig a
myGSConfig =
  (buildDefaultGSConfig colorizer)
    { gs_navigate = navNSearch,
      gs_cellwidth = 130,
      gs_cellheight = 80,
      gs_font = "xft:LilexNerdFont-medium-9",
      gs_bordercolor = cs_white defaultCS
    }
  where
    colorizer _ True = return (cs_darkgrey defaultCS, cs_white defaultCS)
    colorizer _ False = return (cs_black defaultCS, cs_blue defaultCS)

myCommands :: X [(String, X ())]
myCommands = (++ other) <$> defaultCommands
  where
    other = [("key-ref", keyRef)]

myXmobarPP :: PP
myXmobarPP =
  def
    { ppSep = magenta " • ",
      ppTitleSanitize = xmobarStrip,
      ppCurrent = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2,
      ppHidden = white . wrap " " "",
      ppHiddenNoWindows = lowWhite . wrap " " "",
      ppUrgent = red . wrap (yellow "!") (yellow "!"),
      ppOrder = \[ws, l, _, wins] -> [ws, l, wins],
      ppExtras = [logTitles formatFocused formatUnfocused]
    }
  where
    formatFocused = wrap (white "[") (white "]") . magenta . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . blue . ppWindow

    -- \| Windows should have *some* title, which should not not exceed a
    -- sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 20

    blue, lowWhite, magenta, red, white, yellow :: String -> String
    magenta = xmobarColor (cs_pink defaultCS) ""
    blue = xmobarColor (cs_blue defaultCS) ""
    white = xmobarColor (cs_white defaultCS) ""
    yellow = xmobarColor (cs_yellow defaultCS) ""
    red = xmobarColor (cs_red defaultCS) ""
    lowWhite = xmobarColor (cs_grey defaultCS) ""

term, shell :: String
term = "kitty"
shell = "fish"

data ColorScheme = ColorScheme
  { cs_white,
    cs_black,
    cs_darkgrey,
    cs_grey,
    cs_red,
    cs_pink,
    cs_blue,
    cs_magenta,
    cs_yellow ::
      String
  }

defaultCS :: ColorScheme
defaultCS = ColorScheme "#b3afaf" "#1c1c1c" "#3c3c3c" "#9a9a9a" "#905050" "#d0a4a4" "#87afaf" "#f1fa8c" "#ffa500"

layout = tiled ||| Mirror tiled ||| noBorders Full
  where
    tiled = Tall nmaster delta ratio
    nmaster = 1
    ratio = 13 / 21
    delta = 3 / 100
