module Main where

import FileActions
import Options
import TFGen
import Options.Applicative

main :: IO ()
main = customExecParser (prefs showHelpOnEmpty) optsParser >>= runFileActions . genTfFiles >>= putTextLn
