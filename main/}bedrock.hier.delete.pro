﻿601,100
602,"}bedrock.hier.delete"
562,"NULL"
586,
585,
564,
565,"pY?FF<XF_6n3>qlvaAoeqUKe0We7]pUCp1xk<LqEUx5=4vkl3FW7[7ia^av;6koBqGs[MvUd90CtEiCSr>vQ[ero8o?yVRy7B5ij[l>_3>P13AYdvxA7P2mmCMD=8=y]DH];X3Hj8iqaW>Iv:FZBJDqUt:AadPvq>pnQrf8fMAQUnrg24vzTSOkDV2Jh;Yr9Zha^OiKJ"
559,1
928,0
593,
594,
595,
597,
598,
596,
800,
801,
566,0
567,","
588,"."
589,
568,""""
570,
571,
569,0
592,0
599,1000
560,4
pLogOutput
pDim
pHier
pDelim
561,4
1
2
2
2
590,4
pLogOutput,0
pDim,""
pHier,""
pDelim,"&"
637,4
pLogOutput,"Optional: write parameters and action summary to server message log (Boolean True = 1)"
pDim,"Required: Dimension, accepts wildcards (if = *, then all the dimensions)"
pHier,"Optional: Hierarchy, accepts wildcards (all hierarchies except default and Leaves deleted if = *)"
pDelim,"Optional: delimiter character for element list. Defaults to & if blank"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,219

#****Begin: Generated Statements***
#****End: Generated Statements****

################################################################################################# 
##~~ Join the bedrock TM1 community on GitHub https://github.com/cubewise-code/bedrock Ver 4.0 ~~##
################################################################################################# 

#Region @DOC
# Description:
# This process deletes a dimension or hierarchy (or a list thereof).

# Use case: Intended for development/prototyping.
# 1/ Clean up unused dimension/hierarchies after Go Live.

# Note:
# Naturally, a valid dimension name (pDim) is mandatory otherwise the process will abort.
# If no hierarchy (pHier) is specified the dimension will be deleted if not in use by a **regular** cube.
# If a hierarchy is specified, it must be valid otherwise the process will abort.
#EndRegion @DOC

### Global Variables
StringGlobalVariable('sProcessReturnCode');
NumericGlobalVariable('nProcessReturnCode');
nProcessReturnCode= 0;

### Constants ###
cThisProcName     = GetProcessName();
cUserName         = TM1User();
cTimeStamp        = TimSt( Now, '\Y\m\d\h\i\s' );
cRandomInt        = NumberToString( INT( RAND( ) * 1000 ));
cTempSub          = cThisProcName |'_'| cTimeStamp |'_'| cRandomInt;
cMsgErrorLevel    = 'ERROR';
cMsgErrorContent  = 'User:%cUserName% Process:%cThisProcName% ErrorMsg:%sMessage%';
cMsgInfoContent   = 'User:%cUserName% Process:%cThisProcName% Message:%sMessage%';
cLogInfo          = 'Process:%cThisProcName% run with parameters pDim:%pDim%, pHier:%pHier%, pDelim:%pDelim%.'; 

## LogOutput parameters
IF( pLogoutput = 1 );
    LogOutput('INFO', Expand( cLogInfo ) );   
ENDIF;

### Validate Parameters ###
nErrors = 0;

If( Scan( '*', pDim ) = 0 & Scan( '?', pDim ) = 0 & Scan( pDelim, pDim ) = 0 & Scan( ':', pDim ) > 0 & pHier @= '' );
    # A hierarchy has been passed as dimension. Handle the input error by splitting dim:hier into dimension & hierarchy
    pHier       = SubSt( pDim, Scan( ':', pDim ) + 1, Long( pDim ) );
    pDim        = SubSt( pDim, 1, Scan( ':', pDim ) - 1 );
EndIf;

If( Trim( pDim ) @= '' );
  nErrors = 1;
  sMessage = 'No dimension specified.';
  LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
ElseIF( Scan( '*', pDim ) = 0 & Scan( '?', pDim ) = 0 & Scan( pDelim, pDim ) = 0 & DimensionExists( pDim ) = 0 );
    nErrors = 1;
    sMessage = 'Invalid dimension: ' | pDim;
    LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
EndIf;

If( Trim( pHier ) @= '' );
  ## use same name as Dimension. Since wildcards are allowed this is managed inside the code below
ElseIf( Trim( pHier ) @= 'Leaves' );
  nErrors = 1;
  sMessage = 'Invalid hierarchy: "Leaves".';
  LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
ElseIf(  Scan( '*', pHier ) = 0 & Scan( '?', pHier ) = 0 & Scan( pDelim, pHier ) = 0 & Scan( '*', pDim ) = 0 & Scan( '?', pDim ) = 0 & Scan( pDelim, pDim ) = 0 & Trim( pHier ) @= Trim( pDim ) );
  nErrors = 1;
  sMessage = 'Cannot delete same named hierarchy: "}bedrock.dim.delete" process should be used for this purpose';
  LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
EndIf;

### Check for errors before continuing
If( nErrors <> 0 );
    ProcessBreak;
EndIf;


IF( Scan( '*', pHier ) = 0 & Scan( '?', pHier ) = 0 & Scan( pDelim, pHier ) = 0 & Scan( '*', pDim ) = 0 & Scan( '?', pDim ) = 0 & Scan( pDelim, pDim ) = 0 );
    If( HierarchyExists( pDim, pHier ) = 0 );
        nError = 1;
        sMessage = 'The Hierachy "' | pHier | '" is not available in "' | pDim | '" dimension' ;
        LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
    Else;
        HierarchyDestroy( pDim  ,pHier );
    Endif;
ElseIf( pHier @= 'Leaves');
    nError = 1;
    sMessage = 'The Hierachy is Leaves and can not be destroyed';
    LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
Else;
    # Loop through dimensions in pDim
    sDims = pDim;
    nDimDelimiterIndex = 1;
    sMdx = '';
    # Get 1st dimension
    While( nDimDelimiterIndex <> 0 );
        # Extract 1st dimension > sDim
        nDimDelimiterIndex = Scan( pDelim, sDims );
        If( nDimDelimiterIndex = 0 );
            sDim = sDims;
        Else;
            sDim = Trim( SubSt( sDims, 1, nDimDelimiterIndex - 1 ) );
            sDims = Trim( Subst( sDims, nDimDelimiterIndex + Long(pDelim), Long( sDims ) ) );
        EndIf;
        
          # Create subset of dimensions using Wildcard to loop through dimensions in pDim with wildcard
        sDimExp = '"'|sDim|'"';
        sMdxPart = '{TM1FILTERBYPATTERN( EXCEPT( TM1SUBSETALL( [}Dimensions] ) , TM1FILTERBYPATTERN( TM1SUBSETALL( [}Dimensions] ) , "*:*") ) ,'| sDimExp | ')}';
        IF( sMdx @= ''); 
          sMdx = sMdxPart; 
        ELSE;
          sMdx = sMdx | ' + ' | sMdxPart;
        ENDIF;
    End;
    
    If( SubsetExists( '}Dimensions' , cTempSub ) = 1 );
        # If a delimited list of dim names includes wildcards then we may have to re-use the subset multiple times
        SubsetMDXSet( '}Dimensions' , cTempSub, sMDX );
    Else;
        # temp subset, therefore no need to destroy in epilog
        SubsetCreatebyMDX( cTempSub, sMDX, '}Dimensions' , 1 );
    EndIf;
    
    # Loop through dimensions in subset created based on wildcard
    nCountDim = SubsetGetSize( '}Dimensions' , cTempSub );
    While( nCountDim >= 1 );
        sDim = SubsetGetElementName( '}Dimensions' , cTempSub, nCountDim );
        # Validate dimension name
        If( DimensionExists(sDim) = 0 );
            nErrors = 1;
            sMessage = Expand( 'Dimension %sDim% does not exist.' );
            LogOutput( 'ERROR', Expand( cMsgErrorContent ) );
        Else;
            If( pLogOutput = 1 );
              sMessage = Expand( 'Dimension %sDim% being processed....' );
              LogOutput( 'INFO', Expand( cMsgInfoContent ) );
            EndIf;
            # Loop through hierarchies in pHier
            If( Trim( pHier ) @= '' );
              ### Use main hierarchy for each dimension if pHier is empty
              sHierarchies = sDim;
            Else;
              sHierarchies              = pHier;
            EndIf;
            nDelimiterIndexA    = 1;
            sHierDim            = '}Hierarchies_'|sDim ;
            sMdxHier = '';
            While( nDelimiterIndexA <> 0 );
    
                nDelimiterIndexA = Scan( pDelim, sHierarchies );
                If( nDelimiterIndexA = 0 );
                    sHierarchy   = sHierarchies;
                Else;
                    sHierarchy   = Trim( SubSt( sHierarchies, 1, nDelimiterIndexA - 1 ) );
                    sHierarchies  = Trim( Subst( sHierarchies, nDelimiterIndexA + Long(pDelim), Long( sHierarchies ) ) );
                EndIf;
                
                # Create subset of Hierarchies using Wildcard
                sHierExp = '"'|sDim|':'|sHierarchy|'"';
                sMdxHierPart = '{TM1FILTERBYPATTERN( {TM1SUBSETALL([ ' |sHierDim| '])},'| sHierExp | ')}';
                IF( sMdxHier @= ''); 
                  sMdxHier = sMdxHierPart; 
                ELSE;
                  sMdxHier = sMdxHier | ' + ' | sMdxHierPart;
                ENDIF;
            End;
    
            If( SubsetExists( sHierDim, cTempSub ) = 1 );
                # If a delimited list of attr names includes wildcards then we may have to re-use the subset multiple times
                SubsetMDXSet( sHierDim, cTempSub, sMdxHier );
            Else;
                # temp subset, therefore no need to destroy in epilog
                SubsetCreatebyMDX( cTempSub, sMdxHier, sHierDim, 1 );
            EndIf;
        
            # Loop through subset of hierarchies created based on wildcard
            nCountHier = SubsetGetSize( sHierDim, cTempSub );
            While( nCountHier >= 1 );
                sCurrHier = SubsetGetElementName( sHierDim, cTempSub, nCountHier );
                sCurrHierName = Subst( sCurrHier, Scan(':', sCurrHier)+1, Long(sCurrHier) );
                
                # Validate hierarchy name in dimension
                If( Dimix( sHierDim , sCurrHier ) = 0 );
                    sMessage = Expand('The %sCurrHier% hierarchy does NOT exist in the %sDim% dimension.');
                    LogOutput( 'INFO' , Expand( cMsgInfoContent ) );
                Else;
                  If( pLogOutput = 1 );
                    sMessage = Expand( 'Hierarchy %sCurrHierName% in Dimension %sDim% being processed....' );
                    LogOutput( 'INFO', Expand( cMsgInfoContent ) );
                  EndIf;
                  If( Trim( sCurrHierName ) @= Trim( sDim ) );
                      ## Do not remove main hierarchy
                  ElseIf( sCurrHierName @= 'Leaves');
                      If( pLogOutput = 1 );
                        sMessage = 'The Hierachy is Leaves and can not be destroyed';
                        LogOutput( 'INFO', Expand( cMsgInfoContent ) );
                      EndIf;
                  Else;
                      HierarchyDestroy( sDim, sCurrHierName );
                      If( pLogOutput = 1 );
                        sMessage = Expand( 'Destroying hierarchy %sCurrHierName% in Dimension %sDim%' );
                      LogOutput( 'INFO', Expand( cMsgInfoContent ) );
                  EndIf;
                  Endif;
                Endif;
              
                nCountHier = nCountHier - 1;
            End;
                
        EndIf;
        
        nCountDim = nCountDim - 1;
    End;
EndIf;


### End Prolog ###
573,4

#****Begin: Generated Statements***
#****End: Generated Statements****

574,4

#****Begin: Generated Statements***
#****End: Generated Statements****

575,24

#****Begin: Generated Statements***
#****End: Generated Statements****

################################################################################################# 
##~~Join the bedrock TM1 community on GitHub https://github.com/cubewise-code/bedrock Ver 4.0~~##
################################################################################################# 

### Return code & final error message handling
If( nErrors > 0 );
    sMessage = 'the process incurred at least 1 error. Please see above lines in this file for more details.';
    nProcessReturnCode = 0;
    LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
    sProcessReturnCode = Expand( '%sProcessReturnCode% Process:%cThisProcName% completed with errors. Check tm1server.log for details.' );
Else;
    sProcessAction     = Expand( 'Process:%cThisProcName% successfully deleted the dimension:hierarchy %pDim%:%pHier%' );
    sProcessReturnCode = Expand( '%sProcessReturnCode% %sProcessAction%' );
    nProcessReturnCode = 1;
    If( pLogoutput = 1 );
        LogOutput('INFO', Expand( sProcessAction ) );   
    EndIf;
EndIf;

### End Epilog ###
576,
930,0
638,1
804,0
1217,1
900,
901,
902,
938,0
937,
936,
935,
934,
932,0
933,0
903,
906,
929,
907,
908,
904,0
905,0
909,0
911,
912,
913,
914,
915,
916,
917,0
918,1
919,0
920,50000
921,""
922,""
923,0
924,""
925,""
926,""
927,""
