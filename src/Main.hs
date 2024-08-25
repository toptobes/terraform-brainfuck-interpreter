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

  interpreterModules <- mkInterpreterModules 2000

  createDir $ DirDesc dirName [entryFile] [interpreterModules]

mkInterpreterModules :: Int -> FileActionF DirDesc
mkInterpreterModules size = do
  contentStart <- useTemplateFile "interpreter/start.tf" []

  contentIntermediate <- forM [1..size] $ \i -> do
    useTemplateFile "interpreter/step.tf" [("index", show i), ("prev_index", show $ i - 1)]

  contentEnd <- useTemplateFile "interpreter/end.tf" [("prev_index", show size)]

  let content = T.concat $ concat [[contentStart], contentIntermediate, [contentEnd]]
      mainFile = FileDesc "main.tf" content

  pure $ DirDesc "modules/interpreter" [mainFile] []

-- mkInterpreterModules :: Int -> FileActionF DirDesc
-- mkInterpreterModules size = do
--   logicFile <- FileDesc "main.tf" <$> useTemplateFile "interpreter/logic.tf" []
--   let logicDir = DirDesc "interpreter_logic" [logicFile] []

--   contentStart <- useTemplateFile "interpreter/main_start.tf" [("index", show size)]

--   contentIntermediate <- forM [(size-1), (size-2)..1] $ \i -> do
--     useTemplateFile "interpreter/main_cont.tf" [("index", show i), ("prev_index", show $ i + 1)]

--   contentEnd <- useTemplateFile "interpreter/main_end.tf" []

--   let content = T.concat $ concat [[contentStart], contentIntermediate, [contentEnd]]
--       mainFile = FileDesc "main.tf" content
--       mainDir = DirDesc "interpreter" [mainFile] []

--   pure $ DirDesc "modules" [mainFile] [mainDir, logicDir]
