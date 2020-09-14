{-# LANGUAGE  MultiParamTypeClasses,FunctionalDependencies,FlexibleInstances,KindSignatures,DataKinds #-}

module Record where

import qualified Data.Map.Strict as M
import Data.Map.Merge.Strict
import Data.Function (on)
import Data.List
import Text.Printf
import Data.Tuple.OneTuple (only,OneTuple)


class (Bounded a,Enum a,Ord a) => Set a where
  members :: [a]
  members = enumFromTo minBound maxBound


data GenRec (f::Bool) a = Rec {unRec :: M.Map a Double}

-- Original unnormalized representation
type Rec r = GenRec 'True r

-- Normalized Representation
type Norm r = GenRec 'False r

--
-- Printing unnormalized record values

instance Show a => Show (Rec a) where
    show ts = let ts' = map (\(x,y) -> show x ++ " -> " ++ printf "%.2f" y) (fromRec ts)
              in "{" ++ intercalate ",\n " ts' ++ "}"


fromRec :: GenRec f a -> [(a,Double)]
fromRec = M.toList . unRec

mkRec :: Ord a => [(a,Double)] -> GenRec f a 
mkRec = Rec . M.fromList

emptyRec :: Ord a => GenRec f a  
emptyRec = mkRec []

-- Pritning Normalized Record
--

instance Show a => Show (Norm a) where
  show ts = let ts' = map (\(x,y) -> show x ++ " -> " ++ printf "%.1f" (y*100)) (fromRec ts)
            in "{" ++ intercalate ",\n " ts' ++ "}"

recToNorm :: Ord a => Rec a -> Norm a 
recToNorm = mkRec.fromRec 

onRec :: Ord a => (Double -> Double -> Double) -> GenRec f a -> GenRec f a -> GenRec f a
onRec g x y =  Rec $ merge preserveMissing preserveMissing
                       (zipWithMatched (\_->g)) (unRec x) (unRec y)

mapRec :: Ord a => (Double -> Double) -> GenRec f a -> GenRec f a
mapRec f =  mkRec.map (\(x,y) -> (x,f y)).fromRec

instance Ord a => Num (GenRec f a) where
  (+) = onRec (+)
  (*) = onRec (*)
  (-) = onRec (-)
  negate = mapRec negate
  abs    = mapRec abs
  signum = mapRec signum
  fromInteger x = undefined

diff :: Ord a => GenRec f a -> GenRec f a -> GenRec f a
diff = onRec (-)

(-->) :: a -> v -> (a,v)
x --> y = (x,y)

-- Record value distribution
--
type Spread o = [(o,Double)]

-- ========================== PROJECTOR =====================================
-- ==========================================================================

-- Projector type class projects an element from a tuple

class Projector a b | a -> b where
  proj :: a -> b


instance Projector (OneTuple a) a where
  proj = only

instance Projector (a,b) a where
  proj = fst

instance Projector (a,b) b where
  proj = snd

instance Projector (a,b,c) a where
  proj (a,b,c) = a

instance Projector (a,b,c) b where
  proj (a,b,c) = b

instance Projector (a,b,c) c where
  proj (a,b,c) = c

instance Projector (a,b,c,d) a where
  proj (a,b,c,d) = a

instance Projector (a,b,c,d) b where
  proj (a,b,c,d) = b

instance Projector (a,b,c,d) c where
  proj (a,b,c,d) = c

instance Projector (a,b,c,d) d where
  proj (a,b,c,d) = d
