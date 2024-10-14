module Options where

import Options.Applicative

data Options = Options
   { config :: !CodeGenConfig
   , outDir :: !FilePath
   , clean  :: !Bool
   }

data CodeGenConfig
   = ManualConfig
     { maxInterpSteps :: !Int
     , maxLUTGenSteps :: !Int
     , tapeLength     :: !(Maybe Int)
     }
  | ConfigFromCode
     { code   :: !String
     , input  :: !(Maybe String)
     }

optsParser :: ParserInfo Options
optsParser = info
  (helper <*> programOpts)
  (fullDesc
    <> header "terrafuck — because why the terrafuck not?"
    <> progDesc
      (  "Script to generate a Brainfuck interpreter in Terraform. "
      <> "Because Terraform does not for allow boundless recursion or anything of that sort, this actually "
      <> "generates a \"limited\" form of Brainfuck where you must specify the max # of steps the pure Terraform "
      <> "intepreter may make."
      ))

programOpts :: Parser Options
programOpts = Options 
   <$> (programOptsFromArgs <|> programOptsFromCode)
   <*> outDirPathParser
   <*> cleanOutDirParser

programOptsFromArgs :: Parser CodeGenConfig
programOptsFromArgs = ManualConfig
  <$> option auto
     (  long "interp-steps"
     <> short 'i'
     <> metavar "N"
     <> value 2000
     <> help "Number of interations the brainfuck interpreter may perform (default 2000)"
     )
  <*> option auto
     (  long "lut-gen-steps"
     <> short 'l'
     <> metavar "N"
     <> value 10
     <> help "Number of interations the bracket LUT generator may perform (should be >= to the # of [s and ]s in your brainfuck) (default 10)"
     )
  <*> optional (option auto
     (  long "default-tape-len"
     <> short 't'
     <> metavar "N"
     <> help "Default length of the brainfuck tape if not explicitly set as a tfvar"
     ))

programOptsFromCode :: Parser CodeGenConfig
programOptsFromCode = ConfigFromCode
  <$> strOption
     (  long "code"
     <> metavar "CODE"
     <> short 'c'
     <> help "Brainfuck code to infer the number of steps/tape length to use"
     )
  <*> optional (strOption
     (  long "input"
     <> metavar "INPUT"
     <> short 'i'
     <> help "Input for the brainfuck code that will be run"
     ))

outDirPathParser :: Parser FilePath
outDirPathParser = strOption
  (  long "out"
  <> metavar "DIRECTORY"
  <> short 'o'
  <> value "out"
  <> help "Directory to output the terraform files/modules (default \"out\")"
  )

cleanOutDirParser :: Parser Bool
cleanOutDirParser = switch
  (  long "clean"
  <> short 'c'
  <> help "Whether to delete and recreate the output directory on generation"
  )
