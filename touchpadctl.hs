#!/usr/bin/env nix-shell
#!nix-shell --pure -i runghc -p "haskellPackages.ghcWithPackages (pkgs: [])"

import System.Environment (lookupEnv, setEnv, getArgs)
import System.Exit (exitFailure)
import System.Process (callCommand)
import System.Directory (getHomeDirectory)
import Text.Read (readMaybe)

touchpadStateFile :: IO String
touchpadStateFile = do
    home <- getHomeDirectory 
    return (home ++ "/.touchpad_state")

data State = Enabled | Disabled deriving (Show, Read)

abort :: String -> IO ()
abort msg = do
    putStrLn msg
    exitFailure

setTouchpadState :: FilePath -> State -> IO ()
setTouchpadState file targetState =
    let
        stateString :: State -> String
        stateString Enabled = "true"
        stateString Disabled = "false"
     in
        do
            putStrLn ("set touchpad-enabled to " ++ stateString targetState)
            callCommand ("hyprctl keyword device[bcm5974]:enabled " ++ stateString targetState)
            writeFile file (show targetState)

getState :: FilePath -> IO State
getState file = do
    content <- readFile file
    case readMaybe content :: Maybe State of
        Just value -> return value
        Nothing -> error ("File `" ++ file ++ "` contains an invalid value")

toggle :: FilePath -> IO ()
toggle file = do
    state <- getState file
    case state of
        Enabled -> setTouchpadState file Disabled
        Disabled -> setTouchpadState file Enabled

main = do
    args <- getArgs
    file <- touchpadStateFile

    case args of
        ["enable"] -> setTouchpadState file Enabled
        ["disable"] -> setTouchpadState file Disabled
        ["toggle"] -> toggle file
        _ -> error "command line arg must be one of `enable`, `disable` or `toggle`"
