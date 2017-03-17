{-# LANGUAGE NoImplicitPrelude              #-}
{-# LANGUAGE MultiParamTypeClasses          #-}
{-# LANGUAGE FlexibleContexts               #-}
{-# LANGUAGE FlexibleInstances              #-}
{-# OPTIONS_GHC -fno-warn-orphans           #-}
{-# OPTIONS_GHC -fno-warn-duplicate-exports #-}
{-# LANGUAGE CPP                            #-}
#if __GLASGOW_HASKELL__ >= 800
{-# OPTIONS_GHC -fno-warn-redundant-constraints #-}
#endif

module Text.RE.TDFA.Text.Lazy
  (
  -- * Tutorial
  -- $tutorial

  -- * The Match Operators
    (*=~)
  , (?=~)
  , (=~)
  , (=~~)
  -- * The Toolkit
  -- $toolkit
  , module Text.RE
  -- * The 'RE' Type and functions
  -- $re
  , RE
  , reSource
  , compileRegex
  , compileRegexWith
  , escape
  , module Text.RE.TDFA.RE
  ) where

import           Prelude.Compat
import qualified Data.Text.Lazy                as TL
import           Data.Typeable
import           Text.Regex.Base
import           Text.RE
import           Text.RE.Types.IsRegex
import           Text.RE.Internal.AddCaptureNames
import           Text.RE.TDFA.RE
import qualified Text.Regex.TDFA               as TDFA


-- | find all matches in text
(*=~) :: TL.Text
      -> RE
      -> Matches TL.Text
(*=~) bs rex = addCaptureNamesToMatches (reCaptureNames rex) $ match (reRegex rex) bs

-- | find first match in text
(?=~) :: TL.Text
      -> RE
      -> Match TL.Text
(?=~) bs rex = addCaptureNamesToMatch (reCaptureNames rex) $ match (reRegex rex) bs

-- | the regex-base polymorphic match operator
(=~) :: ( Typeable a
        , RegexContext TDFA.Regex TL.Text a
        , RegexMaker   TDFA.Regex TDFA.CompOption TDFA.ExecOption String
        )
     => TL.Text
     -> RE
     -> a
(=~) bs rex = addCaptureNames (reCaptureNames rex) $ match (reRegex rex) bs

-- | the regex-base monadic, polymorphic match operator
(=~~) :: ( Monad m
         , Functor m
         , Typeable a
         , RegexContext TDFA.Regex TL.Text a
         , RegexMaker   TDFA.Regex TDFA.CompOption TDFA.ExecOption String
         )
      => TL.Text
      -> RE
      -> m a
(=~~) bs rex = addCaptureNames (reCaptureNames rex) <$> matchM (reRegex rex) bs

instance IsRegex RE TL.Text where
  matchOnce     = flip (?=~)
  matchMany     = flip (*=~)
  makeRegexWith = \o -> compileRegexWith o . unpackE
  makeRegex     = compileRegex . unpackE
  regexSource   = packE . reSource

-- $tutorial
-- We have a regex tutorial at <http://tutorial.regex.uk>. These API
-- docs are mainly for reference.

-- $toolkit
--
-- Beyond the above match operators and the regular expression type
-- below, "Text.RE" contains the toolkit for replacing captures,
-- specifying options, etc.

-- $re
--
-- "Text.RE.TDFA.RE" contains the toolkit specific to the 'RE' type,
-- the type generated by the gegex compiler.
