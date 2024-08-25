module Main where

import FileActions
import qualified Data.Text as T

main :: IO ()
main = runFileActions $ do
  deleteDir "out"
  mkRoot "out"

mkRoot :: FilePath -> FileActionF ()
mkRoot dirName = do
  entryFile <- FileDesc "main.tf" <$> useTemplateFile "root/main.tf" []

  interpreterModule <- mkTemplateModule "interpreter" 2000
  bracketLUTModule  <- mkTemplateModule "bracket_lut" 20

  createDir $ DirDesc dirName [entryFile] [interpreterModule, bracketLUTModule]

mkTemplateModule :: FilePath -> Int -> FileActionF DirDesc
mkTemplateModule name size = do
  contentStart <- useTemplateFile (name <> "/start.tf") []

  contentIntermediate <- forM [1..size] $ \i -> do
    useTemplateFile (name <> "/step.tf") [("index", show i), ("prev_index", show $ i - 1)]

  contentEnd <- useTemplateFile (name <> "/end.tf") [("prev_index", show size)]

  let content = T.concat $ concat [[contentStart], contentIntermediate, [contentEnd]]
      mainFile = FileDesc "main.tf" content

  pure $ DirDesc ("modules/" <> name) [mainFile] []
