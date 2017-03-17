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

module Text.RE.PCRE.Sequence
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
  , module Text.RE.PCRE.RE
  ) where

import           Prelude.Compat
import qualified Data.Sequence                 as S
import           Data.Typeable
import           Text.Regex.Base
import           Text.RE
import           Text.RE.Types.IsRegex
import           Text.RE.Internal.AddCaptureNames
import           Text.RE.PCRE.RE
import qualified Text.Regex.PCRE               as PCRE


-- | find all matches in text
(*=~) :: (S.Seq Char)
      -> RE
      -> Matches (S.Seq Char)
(*=~) bs rex = addCaptureNamesToMatches (reCaptureNames rex) $ match (reRegex rex) bs

-- | find first match in text
(?=~) :: (S.Seq Char)
      -> RE
      -> Match (S.Seq Char)
(?=~) bs rex = addCaptureNamesToMatch (reCaptureNames rex) $ match (reRegex rex) bs

-- | the regex-base polymorphic match operator
(=~) :: ( Typeable a
        , RegexContext PCRE.Regex (S.Seq Char) a
        , RegexMaker   PCRE.Regex PCRE.CompOption PCRE.ExecOption String
        )
     => (S.Seq Char)
     -> RE
     -> a
(=~) bs rex = addCaptureNames (reCaptureNames rex) $ match (reRegex rex) bs

-- | the regex-base monadic, polymorphic match operator
(=~~) :: ( Monad m
         , Functor m
         , Typeable a
         , RegexContext PCRE.Regex (S.Seq Char) a
         , RegexMaker   PCRE.Regex PCRE.CompOption PCRE.ExecOption String
         )
      => (S.Seq Char)
      -> RE
      -> m a
(=~~) bs rex = addCaptureNames (reCaptureNames rex) <$> matchM (reRegex rex) bs

instance IsRegex RE (S.Seq Char) where
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
-- "Text.RE.PCRE.RE" contains the toolkit specific to the 'RE' type,
-- the type generated by the gegex compiler.
