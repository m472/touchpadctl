#!/usr/bin/env nix-shell
#!nix-shell --pure -i runghc -p "haskellPackages.ghcWithPackages (pkgs: [])"

import System.Environment (lookupEnv, setEnv, getArgs)
import System.Exit (exitFailure)
import System.Process (callCommand)
import Text.Read (readMaybe)

touchpadStateFile :: String
touchpadStateFile = "/home/matz/.touchpad_state"

data State = Enabled | Disabled deriving (Show, Read)

abort :: String -> IO ()
abort msg = do
    putStrLn msg
    exitFailure

setTouchpadState :: State -> IO ()
setTouchpadState targetState =
    let
        stateString :: State -> String
        stateString Enabled = "true"
        stateString Disabled = "false"
     in
        do
            putStrLn ("set touchpad-enabled to " ++ stateString targetState)
            callCommand ("hyprctl keyword device[bcm5974]:enabled " ++ stateString targetState)
            writeFile touchpadStateFile (show targetState)

getState :: IO State
getState = do
    content <- readFile touchpadStateFile
    case readMaybe content :: Maybe State of
        Just value -> return value
        Nothing -> error ("File `" ++ touchpadStateFile ++ "` contains an invalid value")

toggle :: IO ()
toggle = do
    state <- getState
    case state of
        Enabled -> setTouchpadState Disabled
        Disabled -> setTouchpadState Enabled

main = do
    args <- getArgs

    case args of
        ["enable"] -> setTouchpadState Enabled
        ["disable"] -> setTouchpadState Disabled
        ["toggle"] -> toggle
        _ -> error "command line arg must be one of `enable`, `disable` or `toggle`"
