{-# LANGUAGE  MultiParamTypeClasses,FunctionalDependencies,FlexibleInstances,DataKinds #-}

module MDS where

import Data.Function
import qualified Data.Map as M
import Data.Maybe 
import Text.Printf
import Data.List

import Record
import Info
import Valuation

 -- ================= MDS EXPLANATIONS ON ANNOGTATED VALUES =======================

type ValDiff a = Rec a
type Barrier a = Rec a
type Support a = Rec a
type MDS a = Rec a
type Dom a = Rec a
type Explain b = (ValDiff b,Support b,Barrier b,[Dom b],[MDS b])


explain :: Ord a => ValDiff a -> Explain a
explain v = (v,mkRec support,mkRec barrier, map mkRec ls,
             map mkRec $ reverse $ sortBy (Prelude.compare `on` f) ls')
  where
    d = map (\(x,y) -> (x,y)) (fromRec v)
    (support,barrier) = partition (\(x,y) -> y>0) d
    f = abs.sum.map snd
    btotal = f barrier
    doms = [d | d <- subsequences support, f d > btotal]
    ls = sortBy (Prelude.compare `on` length) doms
    ls'= takeWhile (\p -> length p == (length.head) ls) ls


-- ========================= PRITNTING EXPLANATIONS =====================
-- ======================================================================

pdom :: Show b => Explain b -> IO ()
pdom (x,y,z,w,_) = do
  ph (x,y,z)
  putStrLn "\nDominators:"
  mapM_ pd w

pmds :: Show b => Explain b -> IO ()
pmds (x,y,z,_,w) = do
  ph (x,y,z)
  putStrLn "\nMDS:"
  mapM_ pd w

-- ========================= HELPER FUNCTIONS============================
-- ======================================================================

pd :: Show a => a -> IO ()
pd = putStrLn.show

ph :: Show b => (ValDiff b,Support b,Barrier b) -> IO ()
ph (a,b,c) = do
      putStrLn "\nValue Difference:"
      putStrLn $ show a
      putStrLn "\nSupport:"
      pd b
      putStrLn "\nBarrier:"
      pd c



select :: Eq o => o -> Info o a -> Rec a 
select o = fromJust . lookup o . fromInfo

(!) :: Eq o => Val o a -> o -> Rec a  
(!) = flip select 

compare :: (Ord a,Eq o) => Info o a -> o -> o -> Rec a  
compare i o1 o2 = i!o1 - i!o2



-- instance Select o (Info o a) (Rec a) where
--   func = 

-- select :: Eq o => o -> Val o a -> Rec a
-- select o = fromJust . lookup o . fromVal

-- (!) :: Eq o => Val o a -> o -> Rec a
-- (!) = flip select 
