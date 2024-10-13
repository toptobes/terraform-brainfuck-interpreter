module Options where

import Options.Applicative

data Options = Options
  { maxInterpSteps :: !Int
  , maxLUTGenSteps :: !Int
  , outDir :: !FilePath
  , force  :: !Bool
  }

optsParser :: ParserInfo Options
optsParser = info
  (helper
    <*> programOptions)
  (fullDesc
    <> header "terrafuck — because why the terrafuck not?"
    <> progDesc 
      (  "Script to generate a Brainfuck interpreter in Terraform. "
      <> "Because Terraform does not for allow boundless recursion or anything of that sort, this actually "
      <> "generates a \"limited\" form of Brainfuck where you must specify the max # of steps the pure Terraform "
      <> "intepreter may make."
      ))

programOptions :: Parser Options
programOptions = Options
  <$> option auto
     (  long "max-steps"
     <> short 'i'
     <> metavar "N"
     <> value 2000
     <> help "Number of interations the brainfuck interpreter may perform (default 2000)"
     )
  <*> option auto
     (  long "max-lut-gen-steps"
     <> short 'g'
     <> metavar "N"
     <> value 10
     <> help "Number of interations the bracket LUT generator may perform (should be >= to the # of [s and ]s in your brainfuck) (default 10)"
     )
  <*> strOption
     (  long "out"
     <> metavar "DIRECTORY"
     <> short 'o'
     <> value "out"
     <> help "Directory to output the terraform files/modules (default \"out\")"
     )
  <*> switch
     (  long "clean"
     <> short 'c'
     <> help "Whether to delete and recreate the output directory on generation"
     )
