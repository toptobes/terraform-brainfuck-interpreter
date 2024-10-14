module Interpreter where

import qualified Data.List.NonEmpty as NE
import Data.List (lookup)

type BracketLUT = [(Int, Int)]
type Instruction = (Char, Int)

newtype InputError = InputError Text
  deriving newtype (Show, IsString)

type Attempt a = Either InputError a

data Cursor a = Cursor
  { left    :: ![a]
  , current ::  !a
  , right   :: ![a]
  , index   :: !Int
  } deriving (Show)

slidel :: Text -> Int -> Cursor a -> Attempt (Cursor a)
slidel desc n c
  | n > c.index = Left . InputError $ desc <> " cursor underflow"
  | otherwise = case splitAt (c.index - n) c.left of
    (_, [])  -> pure c
    (l, x:r) -> pure $ Cursor l x (r ++ c.current : c.right) (c.index - n)

slider :: Int -> Cursor a -> Cursor a
slider n c = case splitAt n (c.current:c.right) of
    (_, [])  -> c
    (l, x:r) -> Cursor (c.left ++ l) x r (c.index + n)

modifyCursor :: (a -> a) -> Cursor a -> Cursor a
modifyCursor f c = c { current = f c.current }

data EvalState = EvalState
  { tape       :: !(Cursor Int)
  , code       :: !(Cursor Instruction)
  , brackets   :: !BracketLUT
  , input      :: !String
  , output     :: !String
  , numSteps   :: !Int
  , maxTapeLen :: !Int
  } deriving (Show)

data EvalResult = EvalResult
  { interpSteps :: !Int
  , lutGenSteps :: !Int
  , maxTapeLen  :: !Int
  , result      :: !String
  } deriving (Show)

eval :: String -> String -> Attempt EvalResult
eval code input = do
  code' <- clump code
  lut <- genBracketLUT $ NE.toList code'

  res <- eval' EvalState
    { tape       = Cursor [] 0 (repeat 0) 0
    , code       = Cursor [] (head code') (tail code') 0
    , brackets   = lut
    , input      = input
    , output     = ""
    , numSteps   = 0
    , maxTapeLen = 0
    }

  pure $ EvalResult
    { interpSteps = res.numSteps + 1
    , lutGenSteps = length res.brackets
    , maxTapeLen  = res.maxTapeLen
    , result      = res.output
    }

eval' :: EvalState -> Attempt EvalState
eval' estate = do
  let (inst, rep) = estate.code.current

  next <- case inst of
    '>' -> do
      let tape' = slider rep estate.tape
      pure estate { tape = tape', maxTapeLen = max (tape'.index + rep) estate.maxTapeLen }
    '<' -> do
      tape' <- slidel "Code (<)" rep estate.tape
      pure estate { tape = tape' }
    '+' -> do
      pure estate { tape = modifyCursor (\v -> (v + rep) `mod` 256) estate.tape }
    '-' -> do
      pure estate { tape = modifyCursor (\v -> (v - rep + 256) `mod` 256) estate.tape }
    '.' -> do
      pure estate { output = estate.output ++ replicate rep (chr estate.tape.current) }
    ',' -> do
      (input:|rest) <- maybeToRight "Exhausted input" $ nonEmpty $ drop (rep - 1) estate.input
      pure estate { tape = modifyCursor (const $ ord input) estate.tape, input = rest }
    '[' -> do
      if estate.tape.current == 0
        then do
          close <- maybeToRight "No matching ] found" $ lookup estate.code.index estate.brackets
          let code' = slider (close - estate.code.index) estate.code
          pure estate { code = code' }
        else pure estate
    ']' -> do
      if estate.tape.current /= 0
        then do
          open  <- maybeToRight "No matching [ found" $ lookup estate.code.index estate.brackets
          code' <- slidel "Code ([)" (estate.code.index - open) estate.code
          pure estate { code = code' }
        else pure estate
    _   -> pure estate { numSteps = estate.numSteps - 1 }

  let next' = advance next
  maybe (pure next) eval' next'

advance :: EvalState -> Maybe EvalState
advance s = 
  if not $ null s.code.right
    then Just (slider 1 s.code & \code' -> s { numSteps = s.numSteps + 1, code = code' })
    else Nothing

clump :: String -> Attempt (NonEmpty Instruction)
clump = maybeToRight "Code was empty" . nonEmpty . map (head &&& length) . NE.group

genBracketLUT :: [Instruction] -> Attempt BracketLUT
genBracketLUT code = go [] [] 0 code <&> \lut' -> lut' <> map swap lut' where
  go :: [Int] -> BracketLUT -> Int -> [Instruction] -> Attempt BracketLUT
  go [] acc _ [] = pure acc
  go _  _   _ [] = Left "Unmatched opening bracket"
  go stack acc i (c:cs)
    | fst c == '[' = go (i:stack) acc (i + 1) cs
    | fst c == ']' = case stack of
                   (openIdx:rest) -> go rest ((openIdx, i):acc) (i + 1) cs
                   []             -> Left "Unmatched closing bracket"
    | otherwise = go stack acc (i + 1) cs
