%
% (c) The GRASP/AQUA Project, Glasgow University, 1993-1996
%
%************************************************************************
%*									*
\section[HsPragmas]{Pragmas in Haskell interface files}
%*									*
%************************************************************************

See also: @Sig@ (``signatures'') which is where user-supplied pragmas
for values show up; ditto @SpecInstSig@ (for instances) and
@SpecDataSig@ (for data types).

\begin{code}
#include "HsVersions.h"

module HsPragmas where

IMP_Ubiq()

-- friends:
import HsTypes		( HsType )

-- others:
import IdInfo
import SpecEnv		( SpecEnv )
import Outputable	( Outputable(..) )
import Pretty
\end{code}

All the pragma stuff has changed.  Here are some placeholders!

\begin{code}
data GenPragmas name  = NoGenPragmas
data DataPragmas name = NoDataPragmas
data InstancePragmas name = NoInstancePragmas
data ClassOpPragmas name  = NoClassOpPragmas
data ClassPragmas name  = NoClassPragmas

noClassPragmas = NoClassPragmas
isNoClassPragmas NoClassPragmas = True

noDataPragmas = NoDataPragmas
isNoDataPragmas NoDataPragmas = True

noGenPragmas = NoGenPragmas
isNoGenPragmas NoGenPragmas = True

noInstancePragmas = NoInstancePragmas
isNoInstancePragmas NoInstancePragmas = True

noClassOpPragmas = NoClassOpPragmas
isNoClassOpPragmas NoClassOpPragmas = True

instance Outputable name => Outputable (ClassPragmas name) where
    ppr sty NoClassPragmas = ppNil

instance Outputable name => Outputable (ClassOpPragmas name) where
    ppr sty NoClassOpPragmas = ppNil

instance Outputable name => Outputable (InstancePragmas name) where
    ppr sty NoInstancePragmas = ppNil

instance Outputable name => Outputable (GenPragmas name) where
    ppr sty NoGenPragmas = ppNil
\end{code}

========================= OLD CODE SCEDULED FOR DELETION SLPJ Nov 96 ==============

\begin{code}
{-		COMMENTED OUT 

Certain pragmas expect to be pinned onto certain constructs.

Pragma types may be parameterised, just as with any other
abstract-syntax type.

For a @data@ declaration---indicates which specialisations exist.
\begin{code}
data DataPragmas name
  = NoDataPragmas
  | DataPragmas	[[Maybe (HsType name)]]  -- types to which specialised

noDataPragmas = NoDataPragmas
isNoDataPragmas NoDataPragmas = True
\end{code}

These are {\em general} things you can know about any value:
\begin{code}
data GenPragmas name
  = NoGenPragmas
  | GenPragmas	(Maybe Int)		-- arity (maybe)
		(Maybe UpdateInfo)	-- update info (maybe)
		DeforestInfo		-- deforest info
		(ImpStrictness name)	-- strictness, worker-wrapper
		(ImpUnfolding name)	-- unfolding (maybe)
		[([Maybe (HsType name)], -- Specialisations: types to which spec'd;
		  Int,			   -- # dicts to ignore
		  GenPragmas name)] 	   -- Gen info about the spec'd version

noGenPragmas = NoGenPragmas

isNoGenPragmas NoGenPragmas = True
isNoGenPragmas _            = False

data ImpUnfolding name
  = NoImpUnfolding
  | ImpMagicUnfolding FAST_STRING	-- magic "unfolding"
					-- known to the compiler by "String"
  | ImpUnfolding UnfoldingGuidance	-- always, if you like, etc.
		 (UnfoldingCoreExpr name)

data ImpStrictness name
  = NoImpStrictness
  | ImpStrictness Bool			-- True <=> bottoming Id
		  [Demand]		-- demand info
		  (GenPragmas name)	-- about the *worker*
\end{code}

For an ordinary imported function: it can have general pragmas (only).

For a class's super-class dictionary selectors:
\begin{code}
data ClassPragmas name
  = NoClassPragmas
  | SuperDictPragmas [GenPragmas name]	-- list mustn't be empty

noClassPragmas = NoClassPragmas

isNoClassPragmas NoClassPragmas = True
isNoClassPragmas _              = False
\end{code}

For a class's method selectors:
\begin{code}
data ClassOpPragmas name
  = NoClassOpPragmas
  | ClassOpPragmas  (GenPragmas name) -- for method selector
		    (GenPragmas name) -- for default method


noClassOpPragmas = NoClassOpPragmas

isNoClassOpPragmas NoClassOpPragmas = True
isNoClassOpPragmas _                = False
\end{code}

\begin{code}
data InstancePragmas name
  = NoInstancePragmas

  | SimpleInstancePragma	   -- nothing but for the dfun itself...
	(GenPragmas name)

  | ConstantInstancePragma
	(GenPragmas name)	   -- for the "dfun" itself
	[(name, GenPragmas name)]  -- one per class op

  | SpecialisedInstancePragma
	(GenPragmas name)	   -- for its "dfun"
	[([Maybe (HsType name)], -- specialised instance; type...
	  Int,			   -- #dicts to ignore
	  InstancePragmas name)]   -- (no SpecialisedInstancePragma please!)

noInstancePragmas = NoInstancePragmas

isNoInstancePragmas NoInstancePragmas = True
isNoInstancePragmas _                 = False
\end{code}

Some instances for printing (just for debugging, really)
\begin{code}
instance Outputable name => Outputable (ClassPragmas name) where
    ppr sty NoClassPragmas = ppNil
    ppr sty (SuperDictPragmas sdsel_prags)
      = ppAbove (ppPStr SLIT("{-superdict pragmas-}"))
		(ppr sty sdsel_prags)

instance Outputable name => Outputable (ClassOpPragmas name) where
    ppr sty NoClassOpPragmas = ppNil
    ppr sty (ClassOpPragmas op_prags defm_prags)
      = ppAbove (ppCat [ppPStr SLIT("{-meth-}"), ppr sty op_prags])
		(ppCat [ppPStr SLIT("{-defm-}"), ppr sty defm_prags])

instance Outputable name => Outputable (InstancePragmas name) where
    ppr sty NoInstancePragmas = ppNil
    ppr sty (SimpleInstancePragma dfun_pragmas)
      = ppCat [ppPStr SLIT("{-dfun-}"), ppr sty dfun_pragmas]
    ppr sty (ConstantInstancePragma dfun_pragmas name_pragma_pairs)
      = ppAbove (ppCat [ppPStr SLIT("{-constm-}"), ppr sty dfun_pragmas])
	    	(ppAboves (map pp_pair name_pragma_pairs))
      where
	pp_pair (n, prags)
	  = ppCat [ppr sty n, ppEquals, ppr sty prags]

    ppr sty (SpecialisedInstancePragma dfun_pragmas spec_pragma_info)
      = ppAbove (ppCat [ppPStr SLIT("{-spec'd-}"), ppr sty dfun_pragmas])
	    	(ppAboves (map pp_info spec_pragma_info))
      where
	pp_info (ty_maybes, num_dicts, prags)
	  = ppBesides [ppLbrack, ppInterleave ppSP (map pp_ty ty_maybes), ppRbrack,
		       ppLparen, ppInt num_dicts, ppRparen, ppEquals, ppr sty prags]
	pp_ty Nothing = ppPStr SLIT("_N_")
	pp_ty (Just t)= ppr sty t

instance Outputable name => Outputable (GenPragmas name) where
    ppr sty NoGenPragmas = ppNil
    ppr sty (GenPragmas arity_maybe upd_maybe def strictness unfolding specs)
      = ppCat [pp_arity arity_maybe, pp_upd upd_maybe, -- ToDo: print def?
	       pp_str strictness, pp_unf unfolding,
	       pp_specs specs]
      where
    	pp_arity Nothing  = ppNil
	pp_arity (Just i) = ppBeside (ppPStr SLIT("ARITY=")) (ppInt i)

	pp_upd Nothing  = ppNil
	pp_upd (Just u) = ppUpdateInfo sty u

	pp_str NoImpStrictness = ppNil
	pp_str (ImpStrictness is_bot demands wrkr_prags)
	  = ppBesides [ppPStr SLIT("IS_BOT="), ppr sty is_bot,
		       ppPStr SLIT("STRICTNESS="), ppStr (showList demands ""),
		       ppPStr SLIT(" {"), ppr sty wrkr_prags, ppChar '}']

	pp_unf NoImpUnfolding = ppPStr SLIT("NO_UNFOLDING")
	pp_unf (ImpMagicUnfolding m) = ppBeside (ppPStr SLIT("MAGIC=")) (ppPStr m)
	pp_unf (ImpUnfolding g core) = ppBeside (ppPStr SLIT("UNFOLD=")) (ppr sty core)

	pp_specs [] = ppNil
	pp_specs specs
	  = ppBesides [ppPStr SLIT("SPECS=["), ppInterleave ppSP (map pp_spec specs), ppChar ']']
	  where
	    pp_spec (ty_maybes, num_dicts, gprags)
	      = ppCat [ppLbrack, ppInterleave ppSP (map pp_MaB ty_maybes), ppRbrack, ppInt num_dicts, ppr sty gprags]

	    pp_MaB Nothing  = ppPStr SLIT("_N_")
	    pp_MaB (Just x) = ppr sty x
\end{code}


\begin{code}
-}
\end{code}
