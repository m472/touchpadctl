#!/usr/bin/env nix-shell
#!nix-shell --pure -i runghc -p "haskellPackages.ghcWithPackages (pkgs: [])"

import System.Directory (getHomeDirectory)
import System.Environment (getArgs, lookupEnv, setEnv)
import System.Exit (exitFailure)
import System.Process (callCommand)
import Text.Read (readMaybe)

touchpadStateFile :: IO String
touchpadStateFile = do
    home <- getHomeDirectory
    return (home ++ "/.touchpad_state")

data State = Enabled | Disabled deriving (Show, Read)
newtype Device = Device String

abort :: String -> IO ()
abort msg = do
    putStrLn msg
    exitFailure

setTouchpadState :: FilePath -> Device -> State -> IO ()
setTouchpadState file (Device id) targetState =
    let
        stateString :: State -> String
        stateString Enabled = "true"
        stateString Disabled = "false"
        hyprCtlCmd = "hyprctl keyword device[" ++ id ++ "]:enabled " ++ stateString targetState
        notifyCmd = "notify-send \"Touchpad " ++ show targetState ++ "\""
     in
        do
            putStrLn ("set touchpad-enabled to " ++ stateString targetState)
            callCommand (unwords [hyprCtlCmd, "&&", notifyCmd])
            writeFile file (show targetState)

getState :: FilePath -> IO State
getState file = do
    content <- readFile file
    case readMaybe content :: Maybe State of
        Just value -> return value
        Nothing -> error ("File `" ++ file ++ "` contains an invalid value")

toggle :: FilePath -> Device -> IO ()
toggle file device = do
    state <- getState file
    case state of
        Enabled -> setTouchpadState file device Disabled
        Disabled -> setTouchpadState file device Enabled

barstatus :: FilePath -> String -> String -> IO ()
barstatus file enabledSymbol disabledSymbol = do
    state <- getState file
    -- print text for {} in waybar
    putStrLn
        ( case state of
            Enabled -> enabledSymbol
            Disabled -> disabledSymbol
        )

    -- print state for tooltip
    print state

    -- print state for waybar class
    print state

main = do
    args <- getArgs
    file <- touchpadStateFile

    case args of
        ["enable", id] -> setTouchpadState file (Device id) Enabled
        ["disable", id] -> setTouchpadState file (Device id) Disabled
        ["toggle", id] -> toggle file (Device id)
        ["status"] -> do
            state <- getState file
            print state
        ["barstatus", enabled, disabled] -> barstatus file enabled disabled
        _ -> error "command line arg must be one of `enable`, `disable`, `toggle`, `status` or `barstatus`"
