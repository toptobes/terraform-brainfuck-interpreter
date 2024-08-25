{-# LANGUAGE TemplateHaskell #-}

module FileActions where

import Control.Monad.Free
import Control.Monad.Free.TH
import qualified Data.Text as T
import System.Directory
import System.FilePath

type FileActionF = Free FileAction

data FileDesc = FileDesc
  { name     :: FilePath
  , content  :: Text
  } deriving (Show)

data DirDesc = DirDesc
  { name  :: FilePath
  , files :: [FileDesc]
  , dirs  :: [DirDesc]
  } deriving (Show)

data FileAction next
  = UseTemplateFile FilePath [(Text, Text)] (Text -> next)
  | CreateDir DirDesc  next
  | DeleteDir FilePath next
  deriving (Functor)

$(makeFree ''FileAction)

runFileActions :: FileActionF a -> IO a
runFileActions = iterM go where
  go (UseTemplateFile fp vars next) = runUseTemplateFile fp vars next
  go (CreateDir desc next) = runCreateDir desc next
  go (DeleteDir desc next) = runDeleteDir desc next

runUseTemplateFile :: FilePath -> [(Text, Text)] -> (Text -> IO a) -> IO a
runUseTemplateFile fp vars next = do
  content <- readFileText $ "templates/" </> fp
  next $ foldl' (\content' (k, v) -> T.replace ("\\{" <> k <>"}") v content') content vars

runCreateDir :: DirDesc -> IO a -> IO a
runCreateDir desc next = go "" [desc] >> next where
  go base descs = forM_ descs $ \desc' -> do
    createDirectoryIfMissing True (base </> desc'.name)

    forM_ desc'.files $ \file -> do
      writeFileText (base </> desc'.name </> file.name) file.content
  
    go (base </> desc'.name) desc'.dirs

runDeleteDir :: FilePath -> IO a -> IO a
runDeleteDir name next = do
  removePathForcibly name
  next

printFileActions :: FileActionF a -> IO a
printFileActions = iterM go where
  go (UseTemplateFile fp vars next) = printUseTemplateFile fp vars next
  go (CreateDir desc next) = printCreateDir desc next
  go (DeleteDir desc next) = printDeleteDir desc next

printUseTemplateFile :: FilePath -> [(Text, Text)] -> (Text -> IO a) -> IO a
printUseTemplateFile fp vars next = do
  putTextLn $ T.intercalate " " ["UseTemplateFile", toText fp, show vars]
  next "<content>"

printCreateDir :: DirDesc -> IO a -> IO a
printCreateDir desc next = do
  putTextLn $ T.intercalate " " ["CreateDir", show desc]
  next

printDeleteDir :: FilePath -> IO a -> IO a
printDeleteDir name next = do
  putTextLn $ T.intercalate " " ["DeleteDir", toText name]
  next
