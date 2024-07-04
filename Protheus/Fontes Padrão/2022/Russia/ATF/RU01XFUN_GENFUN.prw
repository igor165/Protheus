#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU01XFUN.CH'

#define DBS_NAME				1
#define DBS_VALUE				5
#define STATUS_SN4_STORNO		"1"

/*/{Protheus.doc} VldRelOKOF
(long_description)
@type function
@author Felipe Morais
@since 16/01/2017
@version 1.0
@return ${return}, ${return_description}
@see (links_or_references)
/*/

Function VldRelOKOF(cOKOF as Character, cGroup as Character)
Local lRet as Logical
Local aArea as Object
Local aAreaFM0 as Object
Local aAreaFM1 as Object
Local aAreaFM2 as Object

lRet := .T.
aArea := GetArea()
aAreaFM0 := FM0->(GetArea())
aAreaFM1 := FM1->(GetArea())
aAreaFM2 := FM2->(GetArea())

If (ReadVar() == "M->N1_OKOF")
	If !(Empty(cOKOF))
		lRet := ExistCpo("FM0", cOKOF)
	Endif
Endif

If (ReadVar() == "M->N1_DEPGRP")
	If !(Empty(cGroup))
		lRet := ExistCpo("FM1", cGroup)
	Endif	
Endif

If (!(Empty(cOKOF)) .And. !(Empty(cGroup)))
	DbSelectArea("FM2")
	FM2->(DbSetOrder(1))
	If !(FM2->(DbSeek(xFilial("FM2") + cGroup + cOKOF)))
		lRet := .F.
	Endif
Endif

RestArea(aAreaFM0)
RestArea(aAreaFM1)
RestArea(aAreaFM2)
RestArea(aArea)	
Return(lRet)

/*/{Protheus.doc} VldRelOKOF
(long_description)
@type function
@author Felipe Morais
@since 16/01/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Function FltRelOKOF()
Local lRet as Logical
Local aArea as Object
Local aAreaFM2 as Object

lRet := .T.
aArea := GetArea()
aAreaFM2 := FM2->(GetArea())

If (ReadVar() == "M->N1_OKOF")
	If !(Empty(M->N1_DEPGRP))
		DbSelectArea("FM2")
		FM2->(DbSetOrder(1))
		If !(FM2->(DbSeek(xFilial("FM2") + M->N1_DEPGRP + FM0->FM0_CODE)))
			lRet := .F.
		Endif
	Endif
Endif

If (ReadVar() == "M->N1_DEPGRP")
	If !(Empty(M->N1_OKOF))
		DbSelectArea("FM2")
		FM2->(DbSetOrder(1))
		If !(FM2->(DbSeek(xFilial("FM2") + FM1->FM1_CODE + M->N1_OKOF)))
			lRet := .F.
		Endif
	Endif
Endif

RestArea(aAreaFM2)
RestArea(aArea)	
Return(lRet)


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01CHKOPE

Check if the fixed asset is in operation

@param		CHARACTER cFil - Branch of the fixed asset
@param		CHARACTER cBase - Base code of the fixed asset
@param		CHARACTER cItem - Item of the fixed asset
@param		CHARACTER cType - Item of the fixed asset
@return		LOGICAL
@author 	victor.rezende
@since 		11/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01CHKOPE(cFil AS CHAR, cBase AS CHAR, cItem AS CHAR)
Local lRet		AS LOGICAL
Local cQuery	AS CHARACTER
Local cAlsTmp	AS CHARACTER

cQuery	:= " SELECT N3_CBASE "
cQuery	+= "   FROM " + RetSqlName("SN3")
cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
cQuery	+= "    AND N3_FILIAL = '"+cFil+"' "
cQuery	+= "    AND N3_CBASE = '"+cBase+"' "
cQuery	+= "    AND N3_ITEM = '"+cItem+"' "
cQuery	+= "    AND N3_OPER = '1' "
cQuery := ChangeQuery(cQuery) 
cAlsTmp	:= RU01GETALS(cQuery)
lRet	:= (cAlsTmp)->(! EOF())
(cAlsTmp)->(dbCloseArea())

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01INCCHR

Incremental function

@param		CHARACTER cPar
@param		LOGICAL lAlphaNum
@return		CHARACTER cRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01INCCHR(cPar AS CHARACTER, lAlphaNum AS LOGICAL)
Local nPos		AS NUMERIC
Local nSize		AS NUMERIC
Local cRet		AS CHARACTER
Local cCurChar	AS CHARACTER
Local lExit		AS LOGICAL

Default lAlphaNum	:= .F.

nSize		:= Len(cPar)
cRet		:= cPar
For nPos := 1 To nSize
	cCurChar	:= SubStr(cRet, nSize - nPos + 1, 1)
	lExit		:= .F.

	If ! ( ;
		(lAlphaNum .And. ((cCurChar >= "0" .And. cCurChar <= "9") .Or. (cCurChar >= "A" .And. cCurChar <= "Z"))) .Or. ;
		(! lAlphaNum .And. (cCurChar >= "0" .And. cCurChar <= "9")) ;
	)
			cRet	:= ""
			Exit
	EndIf
	If 	( ! lAlphaNum .And. cCurChar >= "0" .And. cCurChar <= "8" ) .Or. ;
		( lAlphaNum .And. (cCurChar >= "0" .And. cCurChar <= "8" .Or. cCurChar >= "A" .And. cCurChar <= "Y") )
			cCurChar	:= CHR(ASC(cCurChar) + 1)
			lExit		:= .T.
	ElseIf lAlphaNum .And. cCurChar == "9"
		cCurChar	:= "A"
		lExit		:= .T.
	ElseIf ! lAlphaNum .And. cCurChar == "9"
		cCurChar	:= "0"
	ElseIf lAlphaNum .And. cCurChar == "Z"
		cCurChar	:= "0"
	EndIf
	cRet		:= SubStr(cRet, 1, nSize - nPos) + cCurChar + IIf(nPos > 1, SubStr(cRet, nSize - nPos + 2), "")
	If lExit
		Exit
	EndIf
	If nPos == nSize
		cRet	:= ""
	EndIf
Next nPos

Return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01UUIDV4

Return a Universally Unique IDentifier

@param		None
@return		CHARACTER cUuid
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01UUIDV4()
Return UPPER(FWUUIDV4())

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01QRY2MD

Generic function that load query results into a MVC model

@param		CHARACTER cQuery
@param		OBJECT oModel
@param		LOGICAL lGrid
@param		LOGICAL lAddFirstLine
@param		ARRAY aIgnoreFld
@param		BLOCK bPosInsert
@param		LOGICAL lInitPad
@param		CHARACTER cIncField
@param		ARRAY aAlsPosRec
@param		LOGICAL lEnforceDi
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01QRY2MD(cQuery AS CHARACTER, oModel AS OBJECT, lGrid AS LOGICAL, lAddFirstLine AS LOGICAL, aIgnoreFld AS ARRAY, bPosInsert AS BLOCK, lInitPad AS LOGICAL, cIncField AS CHARACTER, aAlsPosRec AS ARRAY, lEnforceDi AS LOGICAL)
Local nRecno	AS NUMERIC
Local cAliasQry	AS CHARACTER
Local lRet		AS LOGICAL
Local lFirstLn	AS LOGICAL
Local aFields	AS ARRAY

Default lGrid			:= .F.
Default lAddFirstLine	:= .T.
Default lInitPad		:= .F.
Default lEnforceDi		:= .F.
Default aIgnoreFld		:= {}
Default cIncField		:= ""
Default aAlsPosRec		:= {}

lRet		:= .T.

If lRet
	aFields		:= IIf(lEnforceDi,;
		RU01MVCGRC(oModel:GetStruct()),;
		oModel:GetStruct():GetFields())
	cAliasQry	:= RU01GETALS(cQuery)
	lRet		:= (cAliasQry)->(! EOF())
EndIf

If lRet
	If lGrid
		lFirstLn	:= .T.
		While (cAliasQry)->(! EOF())
			If ! Empty(aAlsPosRec)
				nRecno	:= &("('"+cAliasQry+"')->"+aAlsPosRec[02])
				(aAlsPosRec[01])->(dbGoTo(nRecno))
			EndIf
			IIf(! lFirstLn .Or. lAddFirstLine, oModel:AddLine(), Nil)
			lFirstLn	:= .F.
			RU01QRY2MStaticCall(aFields, cAliasQry, oModel, aIgnoreFld, lInitPad, cIncField, aAlsPosRec)
			If ValType(bPosInsert) == "B"
				Eval(bPosInsert, oModel)
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
	ElseIf (cAliasQry)->(! EOF())
		RU01QRY2MStaticCall(aFields, cAliasQry, oModel, aIgnoreFld, lInitPad, Nil, aAlsPosRec)
	EndIf

	(cAliasQry)->(dbCloseArea())
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01QRY2MStaticCall

Static function to support RU01QRY2MD and load data into model

@param		ARRAY aFields
@param		CHARACTER cAliasQry
@param		OBJECT oModel
@param		ARRAY aIgnoreFld
@param		LOGICAL lInitPad
@param		CHARACTER cIncField
@param		ARRAY aAlsPosRec
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RU01QRY2MStaticCall(aFields AS ARRAY, cAliasQry AS CHARACTER, oModel AS OBJECT, aIgnoreFld AS ARRAY, lInitPad AS LOGICAL, cIncField AS CHARACTER, aAlsPosRec AS ARRAY)
Local nX		AS NUMERIC
Local cField	AS CHARACTER
Local cInit		AS CHARACTER
Local lRet		AS LOGICAL
Local xValue

lRet		:= .T.
For nX := 1 To Len(aFields)
	cField	:= AllTrim(aFields[nX, MODEL_FIELD_IDFIELD])
	If Empty(AScan(aIgnoreFld, {|x|x==cField}))
		xValue	:= &("('"+cAliasQry+"')->"+cField)
		If aFields[nX, MODEL_FIELD_TIPO] == 'D' .And. ValType(xValue) <> "D"
			xValue	:= SToD(xValue)
		EndIf
		oModel:LoadValue(cField, xValue)
	EndIf
	If ! Empty(aAlsPosRec)
		xValue	:= &("('"+cAliasQry+"')->"+aAlsPosRec[02])
		If (aAlsPosRec[01])->(Recno()) <> xValue
			(aAlsPosRec[01])->(dbGoTo(xValue))
		EndIf
	EndIf
	If lInitPad
		cInit	:= GetSx3Cache(cField, "X3_RELACAO")
		If ! Empty(cInit)
			If Empty(oModel:GetValue(cField))
				oModel:LoadValue(cField, &(cInit))
			EndIf
		EndIf
	EndIf
Next nX
If ! Empty(cIncField)
	oModel:LoadValue(cIncField, StrZero(oModel:GetLine(), GetSx3Cache(cIncField, "X3_TAMANHO")))
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01MVCERR

Report MVC model error

@param		OBJECT oModel
@return		None
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01MVCERR(oModel AS OBJECT)
Local aError	AS ARRAY

aError	:= oModel:GetErrorMessage()
AutoGrLog( STR0001 + " [" + AllToChar( aError[1]  ) + "]" ) //"ID of sub-model: "
AutoGrLog( STR0002 + " [" + AllToChar( aError[2]  ) + "]" ) //"Field:           "
AutoGrLog( STR0003 + " [" + AllToChar( aError[3]  ) + "]" ) //"Error ID:        "
AutoGrLog( STR0004 + " [" + AllToChar( aError[4]  ) + "]" ) //"Error field:     "
AutoGrLog( STR0005 + " [" + AllToChar( aError[5]  ) + "]" ) //"Error code:      "
AutoGrLog( STR0006 + " [" + AllToChar( aError[6]  ) + "]" ) //"Error message:   "
AutoGrLog( STR0007 + " [" + AllToChar( aError[7]  ) + "]" ) //"Solution:        "
AutoGrLog( STR0008 + " [" + AllToChar( aError[8]  ) + "]" ) //"Current value:   "
AutoGrLog( STR0009 + " [" + AllToChar( aError[9]  ) + "]" ) //"Previous value:  "

If !IsBlind()
	MostraErro()
EndIf

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01GETALS

Return an alias for a given query

@param		CHARACTER cQuery
@return		CHARACTER cAliasQry
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01GETALS(cQuery AS CHARACTER)
Local cAliasQry	AS CHARACTER
cAliasQry	:= CriaTrab(Nil, .F.)
DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry )
Return cAliasQry

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU0134STEN

Process standard transactions

@param		CHARACTER cStdEntry - Code of standard transaction (CT5_LANPAD)
@param		CHARACTER cRoutine - Code of the routine
@param		CHARACTER cBaseAlias - Main alias for processing
@param		ARRAY aRegisters - Pair alias-recno that should be positioned in every call of detprova (check RU01T01RUS-RU01T01STE)
@param		LOGICAL lDisplay - Display accounting entries?
@param		LOGICAL lGroup - Group accounting entries?
@param		LOGICAL lOffline - Off-line accounting?
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU0134STEN(cStdEntry AS CHARACTER, cRoutine AS CHARACTER, cBaseAlias AS CHARACTER, aRegisters AS ARRAY, lDisplay AS LOGICAL, lGroup AS LOGICAL, lOffline AS LOGICAL)
Local nX        AS NUMERIC
Local nY		AS NUMERIC
Local nBaseRec	AS NUMERIC
Local nTotal    AS NUMERIC
Local nHdlPrv   AS NUMERIC
Local nValCtb   AS NUMERIC
Local cLAField	AS CHARACTER
Local cAlsTmp	AS CHARACTER
Local cFile     AS CHARACTER
Local cFALot    AS CHARACTER
Local cUnique	AS CHARACTER
Local lFlagCTB  AS LOGICAL
Local lRet      AS LOGICAL
Local aAlsLA	AS ARRAY
Local aArea		AS ARRAY
Local aAreaALS	AS ARRAY
Local aTmpALS	AS ARRAY
Local aFlagCTB  AS ARRAY

Default lDisplay	:= .T.
Default lGroup		:= .F.
Default lOffline	:= .F.

aArea		:= GetArea()
lRet        := .T.
aTmpALS		:= {}
aAreaALS	:= {}
cUnique		:= ""
For nX := 1 To Len(aRegisters)
	For nY := 1 To Len(aRegisters[nX])
		cAlsTmp	:= aRegisters[nX,nY,01]
		If Empty(AScan(aTmpALS, cAlsTmp))
			dbSelectArea(cAlsTmp)
			aAdd(aAreaALS, GetArea())
			aAdd(aTmpALS, cAlsTmp)

			If cAlsTmp == cBaseAlias
				If SX2->(dbSeek(cBaseAlias))
					If ! Empty(SX2->X2_UNICO)
						cUnique	:= AllTrim(SX2->X2_UNICO)
					EndIf
				EndIf
			EndIf
		EndIf
	Next nY
Next nX

// Set standard transactions configurations
cFile		:= " "
nTotal		:= 0
aFlagCTB	:= {}
aAlsLA		:= {}
lFlagCTB	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/ )
nHdlPrv     := 0
cFALot      := ""
cLAField	:= IIf(SubStr(cBaseAlias, 1, 1) == "S",;
	SubStr(cBaseAlias, 2, 2),;
	cBaseAlias) + "_LA"
If VerPadrao(cStdEntry)
    cFALot	:= LoteCont("ATF")
    nHdlPrv	:= HeadProva(cFALot, cRoutine, Substr(cUsername,1,6), @cFile)
EndIf

If nHdlPrv > 0
	For nX := 1 To Len(aRegisters)
		// Position all registers specified in aRegisters
		nBaseRec	:= 0
		For nY := 1 To Len(aRegisters[nX])
			dbSelectArea(aRegisters[nX,nY,01])
			dbGoTo(aRegisters[nX,nY,02])
			If aRegisters[nX,nY,01] == cBaseAlias
				nBaseRec	:= aRegisters[nX,nY,02]
			EndIf
		Next nY

		nValCtb	:= DetProva( ;
            nHdlPrv, ;
            cStdEntry, ;
            cRoutine, ;
            cFALot, ;
            /*nLinha*/, ;
            /*lExecuta*/, ;
            /*cCriterio*/, ;
            /*lRateio*/, ;
            /*cKey cChaveBusca */, ;
            /*aCT5*/, ;
            /*lPosiciona*/, ;
            @aFlagCTB, ;
            /*{cBaseAlias, nBaseRec} aTabRecOri*/, ;
            /*aDadosProva*/)
		
		If nValCtb <> 0
            If lFlagCTB
                aAdd(aFlagCTB, {;
					cLAField,;
					"S",;
					cBaseAlias,;
					nBaseRec,0,0,0})
            Else
                aAdd(aAlsLA, nBaseRec)
            EndIf
            
            nTotal  += nValCtb
        EndIf
	Next nX
EndIf

// Commit standard entry
If nHdlPrv > 0 .And. nTotal <> 0
    cA100Incl(cFile, nHdlPrv, 3, cFALot, lDisplay, lGroup)
	dbSelectArea(cBaseAlias)
    For nX := 1 To Len(aAlsLA)
		dbGoTo(aAlsLA[nX])
        RecLock(cBaseAlias, .F.)
        &(cBaseAlias + '->'+cLAField+' := "S"')
        MsUnLock()
    Next nX
	RodaProva(nHdlPrv, nTotal)
EndIf

For nX := 1 To Len(aAreaALS)
	RestArea(aAreaALS[nX])
Next nX
RestArea(aArea)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01NEXTNU

Get the next available FA num for a given SNG group

@param		CHARACTER cNGGroup
@return		CHARACTER cNextNum
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01NEXTNU(cNGGroup AS CHARACTER)
Local cNextItem      AS CHARACTER
Local nX			AS NUMERIC
Local aArea         AS ARRAY
Local aAreaSNG      AS ARRAY
Local aNextNum		AS ARRAY

Default lItem	:= .F.

cNextNum    := ""
aNextNum	:= {}
nX			:= 1
cNextItem	:=	StrZero( nX, GetSx3Cache("N1_ITEM", "X3_TAMANHO"))

aArea       := GetArea()
aAreaSNG    := SNG->(GetArea())

SNG->(dbSetOrder(1))    //NG_FILIAL+NG_GRUPO
If SNG->(dbSeek(xFilial("SNG") + cNGGroup))
    If ! Empty(SNG->NG_NUMBSER)
       aAdd(aNextNum, RU09D03Nmb("FACARD", SNG->NG_NUMBSER, cFilAnt))
    EndIf
EndIf

While (SN1->(dbSeek(xFilial("SN1") + aNextNum[1] + cNextItem)))
	nX++
	cNextItem	:=	StrZero( nX, GetSx3Cache("N1_ITEM", "X3_TAMANHO"))
EndDo

aAdd(aNextNum, cNextItem)

RestArea(aAreaSNG)
RestArea(aArea)

Return aNextNum

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01SEEK

Return a value for a given record search

@param		CHARACTER cAlias
@param		NUMERIC nIndexOrd
@param		CHARACTER cKey
@param		CHARACTER cContent
@param		LOGICAL lPrePendBr
@return		MIXED xRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01SEEK(cAlias AS CHARACTER, nIndexOrd AS NUMERIC, cKey AS CHARACTER, cContent AS CHARACTER, lPrePendBr AS LOGICAL)
Local nRecno		AS NUMERIC
Local cRet			AS CHARACTER
Local aArea			AS ARRAY
Local aAreaAls		AS ARRAY
Local xRet

Default lPrePendBr	:= .T.

nRecno		:= 0
xRet		:= Nil

If lPrePendBr
	cKey	:= xFilial(cAlias) + cKey
EndIf

If (cAlias)->&( (cAlias)->(IndexKey(nIndexOrd)) ) == cKey
	xRet	:= (cAlias)->&(cContent)
EndIf

If Empty(xRet)
	aArea		:= GetArea()
	aAreaAls	:= (cAlias)->(GetArea())

	dbSelectArea(cAlias)
	dbSetOrder(nIndexOrd)
	If dbSeek(cKey)
		nRecno	:= Recno()
	EndIf

	RestArea(aAreaAls)
	RestArea(aArea)
EndIf

If Empty(xRet) .And. ! Empty(nRecno)
	(cAlias)->(dbGoTo(nRecno))
	xRet	:= (cAlias)->&(cContent)
EndIf

Return xRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01FIXBAI

Fix a bug in FWCommitModel from ATFA012

@param		CHARACTER cBase
@param		CHARACTER cItem
@return		LOGICAL lRet
@author 	victor.rezende
@since 		04/04/2018
@version 	1.4
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01FIXBAI(cBase AS CHARACTER)
Local cQuery		AS CHARACTER
Local cAlias		AS CHARACTER
Local lRet			AS LOGICAL

lRet	:= .T.

cQuery	:= " SELECT R_E_C_N_O_ AS N3RECNO "
cQuery	+= "   FROM " + RetSqlName("SN3")
cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
cQuery	+= "    AND N3_FILIAL = '"+xFilial("SN3")+"' "
cQuery	+= "    AND N3_CBASE = '"+cBase+"' "
cQuery	+= "    AND N3_BAIXA = ' ' "
cQuery:=ChangeQuery(cQuery)
cAlias	:= RU01GETALS(cQuery)

While (cAlias)->(! EOF())
	SN3->(dbGoTo((cAlias)->N3RECNO))

	If SN3->(Recno()) == (cAlias)->N3RECNO
		Reclock("SN3", .F.)
		SN3->N3_BAIXA	:= "0"
		MsUnLock()
	EndIf

	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01MVCGRC()

Return a array with the real parseable fields from MVC structure

@param		OBJECT oStruct
@return		ARRAY aFields
@author 	victor.rezende
@since 		04/04/2018
@version 	1.4
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01MVCGRC(oStruct AS OBJECT)
Local nX			AS NUMERIC
Local aStruFields	AS ARRAY
Local aFields		AS ARRAY

aStruFields	:= oStruct:GetFields()
aFields		:= {}
For nX := 1 To Len(aStruFields)
	If aStruFields[nX, MODEL_FIELD_TIPO] $ "NCLD" .And. ;
		! aStruFields[nX, MODEL_FIELD_VIRTUAL]
			aAdd(aFields, aStruFields[nX])
	EndIf
Next nX

Return aFields

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01MVCRender()

Render a MVC screen

@param		OBJECT oModel
@param		OBJECT oView
@return		NUMERIC nButtonPress
@author 	victor.rezende
@since 		04/04/2018
@version 	1.4
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01MVCRender(oModel AS OBJECT, oView AS OBJECT)
Local nButtonPress	AS NUMERIC
Local oExecView		AS OBJECT

oExecView	:= FWViewExec():New()

oExecView:setTitle(oModel:GetDescription())
oExecView:setOperation(oModel:GetOperation())
oExecView:setCloseOnOK({|| .T.})
oExecView:setModel(oModel)
oExecView:setView(oView)
oExecView:openView()

nButtonPress	:= oExecView:getButtonPress()

FreeObj(oExecView)

Return nButtonPress

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01TXDEPR()

Return the rate of depreciation for a given useful life

@param		NUMERIC nLife
@return		NUMERIC nRate
@author 	victor.rezende
@since 		04/04/2018
@version 	1.4
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01TXDEPR(nLife AS NUMERIC, cPref AS CHARACTER)
Local nRate			AS NUMERIC
Local nRound		AS NUMERIC
If GetNewPar("MV_CALCDEP", "0") == "1"
	nLife	:= nLife * 12
EndIf
Do Case
	Case cPref == 'SN3'
		nRound := TAMSX3("N3_TXDEPR1")[2]
	Case cPref == 'SNG'
		nRound := TAMSX3("NG_TXDEPR1")[2]
	Case cPref == 'FNG'
		nRound := TAMSX3("FNG_TXDEP1")[2]
EndCase

nRate		:= NoRound( (12 * 100) / nLife, nRound ) 
Return nRate

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01RULES()

Enforce the rules estabilished for localization model events

@param		CHARACTER cBase
@param		CHARACTER cItem
@return		LOGICAL lRet
@author 	victor.rezende
@since 		04/04/2018
@version 	1.4
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01RULES(cBase AS CHARACTER, cItem AS CHARACTER)
Local cDescr		AS CHARACTER
Local lRet			AS LOGICAL
Local aArea			AS ARRAY
Local aAreaSN1		AS ARRAY
Local oModel		AS OBJECT
Local oModelRest	AS OBJECT

lRet		:= .T.
oModelRest	:= FWModelActive()
aArea		:= GetArea()
aAreaSN1	:= SN1->(GetArea())

dbSelectArea("SN1")
dbSetOrder(1)	// N1_FILIAL+N1_CBASE+N1_ITEM
If dbSeek(xFilial("SN1") + cBase + cItem)
	cDescr		:= SN1->N1_DESCRIC
	oModel		:= FWLoadModel("ATFA012")
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()
	oModel:GetModel("SN1MASTER"):LoadValue("N1_DESCRIC", cDescr)
	If ! oModel:VldData()
		RU01MVCERR(oModel)
	Else
		oModel:CommitData()
	EndIf
	oModel:Deactivate()
	FreeObj(oModel)
EndIf

If ! Empty(oModelRest)
	FWModelActive(oModelRest)
EndIf

RestArea(aAreaSN1)
RestArea(aArea)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01MSG

Message about auto created fixed asset

@param		CHARACTER cMsg
@param		CHARACTER cTitle
@param		NUMERIC nType
@return		
@author 	Alexandra.Menyashina
@since 		09/04/2018
@version 	1.4
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01MSG(cMsg AS CHARACTER, cTitle as CHARACTER, nType as NUMERIC)
Local cMessage as CHARACTER
Default cTitle := STR0010
Default nType := 3	//3-Info [default value], 2-Warning, 1-Error, optional

if nType == 3
	cMessage := STR0011 +SUBSTR(cMsg, 1, Len(cMsg)-2)//Created FA: ...
	AVISO( cTitle, cMessage, /*<aButtons>*/, /*<nTamanho> */)
EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01STOSN4()

Register the storno

@param		CHARACTER cKey			= Key for seek SN4
@param		CHARACTER cPatrimSN1	= Value Classificator (N1_PATRRIM)
@param		CHARACTER cUUID			= Unique Id of operation record
@return		nil
@author 	alexandra.menyashina
@since 		02/08/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01STOSN4(cKey AS CHARACTER, cPatrimSN1 as CHARACTER, cUUID AS CHARACTER)
Local lOk			AS LOGICAL
Local aArea			AS ARRAY
Local aAreaSN3		AS ARRAY
Local aAreaSN4		AS ARRAY
Local aStructSN4	AS ARRAY
Local aCurrency 	AS ARRAY
Local nI			AS NUMERIC
Local nX			as Numeric
Local aRecNewSN4	AS NUMERIC
Local aRecOldSN4	AS NUMERIC
Local nUID			AS NUMERIC
Local nStorno		AS NUMERIC
Local nVORIG1		AS NUMERIC
Local nCurrency		AS NUMERIC
Local cConta		AS CHARACTER
Local cSignal		AS CHARACTER
Local cTipo			AS CHARACTER
Local cAtfCur		AS CHARACTER
Local bCondSN4		as BLOCK

Default cPatrimSN1 := "N"

lOk			:= .T.
nUID		:= 0
nStorno		:= 0
nVORIG1		:= 0
cAtfCur    := GetNewPar("MV_ATFMOED", "")
nCurrency	:= Posicione("SM2", 1, DToS(dDataBase), "M2_MOEDA"+cAtfCur)
cConta		:= ''
cSignal		:= "-"
aCurrency	:= {}
aArea		:= GetArea()
aAreaSN3	:= SN3->(GetArea())
aAreaSN4	:= SN4->(GetArea())
aStructSN4	:= {}
aRecOldSN4	:= {}
aRecNewSN4	:= {}

If lOk
	dbSelectArea("SN3")
	dbSetOrder(12)	// N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ                                                                                                       
	lOk	:= dbSeek(cKey)
	If !lOk
		 Help("",1,"RU01XSN3",,STR0032 ,1,0)	//"SN3 not found"
	EndIf
EndIf
If lOk
	SN4->(dbSetOrder(11)) // N4_FILIAL+N4_ORIUID
	If  SN4->(dbSeek( xFilial("SN4") + cUUID))
		bCondSN4 := {|| SN4->N4_FILIAL == xFilial("SN4") .And. SN4->N4_ORIUID == cUUID}                                                                          
		While Eval(bCondSN4)
			aAdd(aStructSN4,SN4->(DBStruct()))
			aAdd(aRecOldSN4, SN4->(RECNO()))
			For nI := 1 to Len(aStructSN4[Len(aStructSN4)])
				aAdd(aStructSN4[Len(aStructSN4)][nI], &("SN4->" + aStructSN4[Len(aStructSN4)][nI][1]))	//Add value of fields
			Next nI

			SN4->(DbSkip())
		Enddo
	Else
		lOk	:= .F.
		Help("",1,"RU01XSN4",,STR0033 ,1,0)	//"SN4 not found"
	EndIf
EndIf

BEGIN TRANSACTION
	If lOk
		For nX := 1 to Len(aStructSN4)
			RecLock('SN4',.T.)
			For nI := 1 to Len(aStructSN4[nX])		//load the old register values
				Do Case
					Case aStructSN4[nX][nI][DBS_NAME] == "N4_UID"
						nUID	:= nI
					Case aStructSN4[nX][nI][DBS_NAME] == "N4_STORNO"
						nStorno	:= nI
					Case aStructSN4[nX][nI][DBS_NAME] == "N4_VLROC1"
						nVORIG1	:= nI	
					Otherwise
						&("SN4->"+aStructSN4[nX][nI][DBS_NAME]) := aStructSN4[nX][nI][DBS_VALUE]
				EndCase
			Next nI
			If nUID <> 0
				SN4->N4_ORIUID	:= aStructSN4[nX][nUID][DBS_VALUE]
			Else 
				lOk := .F.
			EndIf
			If nStorno <> 0
				SN4->N4_STORNO	:= "0"
			Else 
				lOk := .F.
			EndIf
			If nVORIG1 <> 0
				SN4->N4_VLROC1	:= (-1) * aStructSN4[nX][nVORIG1][DBS_VALUE]	//(11/04/19): reverse of value
			Else 
				lOk := .F.
			EndIf
			If lOk
				SN4->N4_UID := RU01UUIDV4()
				aAdd(aRecNewSN4, SN4->(RECNO()))
			EndIf
			If lOk
				Do Case
					Case SN4->N4_TIPOCNT == '2'
						cConta	:=	SN3->N3_CCORREC
					Case SN4->N4_TIPOCNT == '3'
						cConta	:=	SN3->N3_CDEPREC
					Case SN4->N4_TIPOCNT == '4'
						cConta	:=	SN3->N3_CCDEPR
					Case SN4->N4_TIPOCNT == '5'
						cConta	:=	SN3->N3_CDESP
					Otherwise
						cConta	:=	SN3->N3_CCONTAB
				EndCase
			EndIf
			If lOk
				If AtClssVer(cPatrimSN1) .Or. Empty(cPatrimSN1)
					cTypeDep	:= "2"
				Elseif cPatrimSN1 $ "CAS"
					cTypeDep	:= "E"
				Else
					cTypeDep	:= "F"
				EndIf
			EndIf
			aCurrency := AtfMultMoe(,,{|x| IIf(x==1,SN3->N3_VRCACM1,0) })
			ATFXSLDCTB(cConta, dDataBase, cTypeDep, SN4->N4_VLROC1,0,0,0,0 ,cSignal,nCurrency,;
						SN3->N3_SUBCCOR,,SN3->N3_CLVLCOR,SN3->N3_CCCORR,SN4->N4_TIPOCNT, aCurrency )
			MsUnlock()
			If lOk
				SN4->(dbGoTo(aRecOldSN4[nX]))
				RecLock('SN4',.F.)
					SN4->N4_STORNO	:= STATUS_SN4_STORNO
				MsUnlock()
				SN4->(dbGoTo(aRecNewSN4[nX]))
			EndIf
		Next nX
		SN4->(dbGoTo(aRecNewSN4[1]))
	EndIf
END TRANSACTION

RestArea(aAreaSN3)
RestArea(aArea)
Return lOk

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01XN4MOV()

list of operation description

@param		CHARACTER cOccor	= N4_OCORR

@return		nil
@author 	alexandra.menyashina
@since 		02/08/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01XN4MOV()
Local cOpcBox	:= "" 
	cOpcBox += "01=" + STR0012 + ";"	//"Write-off"
	cOpcBox += "02=" + STR0013 + ";"	//"Substitution"
	cOpcBox += "03=" + STR0014 + ";"	//"Transfer from"
	cOpcBox += "04=" + STR0015 + ";"	//"Transfer to"
	cOpcBox += "05=" + STR0016 + ";"	//"Implementation"
	cOpcBox += "06=" + STR0017 + ";"	//"Depreciation"
	cOpcBox += "07=" + STR0018 + ";"	//"Correction"
	cOpcBox += "08=" + STR0019 + ";"	//"Depreciation correction"
	cOpcBox += "09=" + STR0020 + ";"	//"Enlargement"
	cOpcBox += "10=" + STR0021 + ";"	//"Accelerated depreciation"
	cOpcBox += "11=" + STR0022 + ";"	//"Negative depreciation"
	cOpcBox += "12=" + STR0023 + ";"	//"Positive depreciation"
	cOpcBox += "13=" + STR0024 + ";"	//"Inventory"
	cOpcBox += "15=" + STR0025 + ";"	//"Write-off by transfer"
	cOpcBox += "16=" + STR0026 + ";"	//"Acquisition by transfer"
	cOpcBox += "18=" + STR0027 + ";"	//"Accum.depr. for monthly exch.adjust."
	cOpcBox += "20=" + STR0028 + ";"	//"Management depreciation"
	cOpcBox += "61=" + STR0029 + ";"	//"Putting into operation"
	cOpcBox += "62=" + STR0030 + ";"	//"Modernization"
	cOpcBox += "63=" + STR0031 + ";"	//"63 - Reevaluation"
	cOpcBox += "97=" + STR0035 + ";"	//"97 - Reevaluation"
	cOpcBox += "98=" + STR0036 + ";"	//"96 - Reevaluation"
	
return cOpcBox

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01XFUN01_AccumDeprBeforeModer()

Function returns accumulated depreciation before modernization

@param		type of model
@param		data of operation

@return		nil
@author 	alexandra.menyashina
@since 		02/08/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01XFUN01_AccumDeprBeforeModer(cBase as Character, cItem as Character, cType as Character, cSeq as Character, dDtDepr as Date)
local aRet			as Array
Local cQuery		as Character
Local aArea   		as Array
Local cAliasQry		as Character
Local cAliasQry1	as Character
Local dDtModer		as Date
Local nX			as Numeric
Local nQtyCur		as Numeric
Local dRevaluation 	as Date
Local nRevaluation 	as Numeric

cQuery := ""
aRet	:= {}
nQtyCur		:= AtfMoedas()
aArea   	:= GetArea()

For nX := 1 to nQtyCur
	AADD(aRet, 0)
Next nX
//Last revaluation 
cQuery := " SELECT MAX(N4_DATA) LASTMODER"
cQuery += " FROM " + RetSqlName("SN4")
cQuery += " WHERE N4_FILIAL = '" + xFilial("SN4") + "'"
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery += " AND N4_CBASE = '" + cBase + "'"
cQuery += " AND N4_ITEM = '" + cItem + "'"
cQuery += " AND N4_TIPO ='" + cType + "'"
cQuery += " AND N4_SEQ = '" + cSeq + "'"
cQuery += " AND N4_ORIGEM = 'RU01T04'"
cQuery += " AND N4_MOTIVO = '09'"
cQuery += " AND N4_STORNO <> '1' "
cQuery += " AND N4_DATA < '" + DToS(FirstDay(dDtDepr)) + "'"

cQuery := ChangeQuery(cQuery) 
cAliasQry1 := RU01GETALS(cQuery)
dRevaluation :=  SToD((cAliasQry1)->LASTMODER)

//Get F4T_VRDACM
cQuery := "SELECT F4T_VRDACM"
cQuery += " FROM " + RetSqlName("SN4")
cQuery += " JOIN " + RetSqlName("F4T") + " ON F4T_SN4UID = N4_UID "
cQuery += " AND F4T_UID = N4_ORIUID "
cQuery += " AND " + RetSqlName("F4T") + ".D_E_L_E_T_=' '"
cQuery += " AND F4T_FILIAL = '" + xFilial("F4T") + "'"
cQuery += " WHERE N4_FILIAL = '" + xFilial("SN4") + "'"
cQuery += " AND N4_CBASE = '" + cBase + "'"
cQuery += " AND N4_ITEM = '" + cItem + "'"
cQuery += " AND N4_TIPO ='" + cType + "'"
cQuery += " AND N4_SEQ = '" + cSeq + "'"
cQuery += " AND " + RetSqlName("SN4") + ".D_E_L_E_T_ = ' '"
cQuery += " AND N4_DATA = '" + DToS(dRevaluation) + "'"

cQuery := ChangeQuery(cQuery) 
cAliasQry1 := RU01GETALS(cQuery)
nRevaluation := (cAliasQry1)->F4T_VRDACM

//Last Modernization
cQuery := " SELECT MAX(N4_DATA) AS LASTMODER "
cQuery += " FROM " + RetSqlName("SN4")
cQuery += " WHERE N4_FILIAL = '" +xFilial("SN4")+ "'"
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery += " AND N4_CBASE = '" + cBase + "'"
cQuery += " AND N4_ITEM = '" + cItem + "'"
cQuery += " AND N4_TIPO ='" + cType + "'"
cQuery += " AND N4_SEQ = '" + cSeq + "'"
cQuery += " AND N4_OCORR = '62'"
cQuery += " AND N4_STORNO <> '1'"
cQuery += " AND N4_DATA < '" + DToS(FirstDay(dDtDepr)) +"'"

cQuery := ChangeQuery(cQuery) 
cAliasQry1 := RU01GETALS(cQuery)
dDtModer :=  SToD((cAliasQry1)->LASTMODER)
(cAliasQry1)->(dbCloseArea())

If !Empty(dDtModer) .And. dDtModer < dDtDepr
	cQuery := "SELECT "
	For nX := 1 to nQtyCur
		cQuery += " SUM(N4_VLROC"+ AllTrim(Str(nX)) + ") " 
		If nX== 1 .and. dRevaluation < dDtModer
			cQuery += "+" + STR(nRevaluation) 
		Endif
		cQuery += " AS DEPBEFMOD" + AllTrim(Str(nX)) + ", "
	Next nX
	cQuery := SubStr(cQuery,1,Len(cQuery)-2)
	cQuery += " FROM " + RetSqlName("SN4")
	cQuery += " WHERE N4_FILIAL = '" + xFilial("SN4") + "'"
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery += " AND N4_TIPOCNT = '3'"
	cQuery += " AND N4_CBASE = '" + cBase + "'"
	cQuery += " AND N4_ITEM = '" + cItem + "'"
	cQuery += " AND N4_TIPO ='" + cType + "'"
	cQuery += " AND N4_SEQ = '" + cSeq + "'"
	If cPaisLoc=='RUS'
		cQuery += " AND N4_STORNO != '1'"
	Endif
	cQuery += " AND N4_OCORR IN ('06','07','08','10','11','12','17','18','20') "
	If dRevaluation < dDtModer
		cQuery += " AND N4_DATA > '"+DToS(dRevaluation) + "' "	//date of last revaluation
	Endif
	cQuery += " AND N4_DATA < '"+DToS(LastDay(dDtModer) + 1) + "' "	//date of last modernization 
Else
	cQuery:=''
Endif


If !Empty(cQuery) .and. dRevaluation < dDtModer
	cQuery := ChangeQuery(cQuery) 
	cAliasQry := RU01GETALS(cQuery)
	For nX := 1 to nQtyCur
		aRet[nX] := (cAliasQry)->&("DEPBEFMOD" + AllTrim(Str(nX)))
	Next nX
	(cAliasQry)->(dbCloseArea())
EndIf
RestArea(aArea)
return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01XFUN02_MonthBeforeModer

Function returns counts of monthes before latest modernization 

@param		type of model
@param		data of operation

@return		nil
@author 	alexandra.menyashina
@since 		02/08/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01XFUN02_MonthBeforeModer(cBase as Character, cItem as Character, cType as Character, cSeq as Character)
Local nRet			as Numeric
Local cAliasQry		as Character
Local cQuery		as Character
Local aArea		as Array
cQuery := ""
nRet	:= 0
aArea   	:= GetArea()

cQuery := "SELECT SUM(F4V_MANAGP) MONBEFMOD"
cQuery += " FROM " + RetSqlName("SN4") + " N4 "
cQuery += " JOIN " + RetSqlName("F4V") + " F4V ON F4V_SN4UID = N4.N4_UID"
cQuery += " JOIN "+RetSqlName("F4U")+" F4U ON F4V_LOT = F4U_LOT "
cQuery += " WHERE F4V_FILIAL = '" +xFilial("F4V")+ "' "
cQuery += " AND N4_FILIAL = '" +xFilial("SN4")+ "' "
cQuery += " AND F4U_FILIAL = '" +xFilial("F4U")+ "' "
cQuery += " AND N4.D_E_L_E_T_ = ' ' "
cQuery += " AND F4U.D_E_L_E_T_ = ' ' "
cQuery += " AND F4V.D_E_L_E_T_ = ' ' "
cQuery += " AND N4_CBASE = '" + cBase + "' "
cQuery += " AND N4_ITEM = '" + cItem + "' "
cQuery += " AND N4_TIPO ='" + cType + "' "
cQuery += " AND N4_SEQ ='" + cSeq + "' "
cQuery += " AND N4_STORNO <> '1' "
cQuery += " AND N4_OCORR = '62' "
cQuery += " AND F4U_DATE < '" + DToS(FirstDay(dDataBase)) + "' "

cQuery := ChangeQuery(cQuery) 
cAliasQry := RU01GETALS(cQuery)
nRet := IIf(Empty((cAliasQry)->MONBEFMOD), 0, (cAliasQry)->MONBEFMOD)

(cAliasQry)->(dbCloseArea())
RestArea(aArea)
Return nRet



//-------------------------------------------------------------------
/*/{Protheus.doc}ATFNValMod

New valuations models for fixed assets

Example:	ATFNValMod( {1,3,4}, ',' )
			In this case, will be returned types 1, 3 and 4

Types:	1 = Main (type 10)
		2 = Modernization revaluation (type 12)
		3 = Negative revaluation (type 17)
		4 = Positive revaluation (type 16)
			
@param		aType	types array to be returned. Ex: {1,3,4}
@param		cSep	String separator		
@return		String with the new models, separated by cSep
@author		Fabio Cazarini
@since		09/03/2017
@version	12
@project	MA3
/*/
//-------------------------------------------------------------------
Function _ATFNValMod(aType as array, cSep as string)
	Local cRet as string
	Local cModAtf as string
	Local aNewModels as array
	Local nX as numeric
	Local cAuxModels as string
	Local aAuxModels as array
	Local nType as numeric
	Local nY as numeric

	cRet	:= ""
	cModAtf	:= SuperGetMv("MV_MODATF",.F.,"") // Ex.: 96/97/98/99;A1/A2/A3/A4

	If ! "10" $ cModAtf
		cModAtf	:= "10/16/17/12" + IIf(Empty(cModAtf), "", ";") + cModAtf
	EndIf

	If !Empty(cModAtf)
		aNewModels := Separa(cModAtf, ';', .t.)
		
		For nX := 1 to len( aNewModels )
			cAuxModels := aNewModels[nX]
			aAuxModels := Separa(cAuxModels, '/', .t.) 
			If len(aAuxModels) == 4
				For nY := 1 TO len(aType)
					nType	:= aType[nY]
					If nType >= 1 .and. nType <= 4
						cRetAux	:= aAuxModels[nType]
						If !empty(cRet)
							cRet += cSep
						Endif
						cRet += cRetAux
					Endif
				Next nY
			Endif
		Next nX
	Endif
 
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc}ATFNValNM

Return the new valuations models for fixed assets for the main model
indicated

Example:	ATFNValMod( '10' )
			In this case, will be returned types 2 (12), 3 (17) and 
			4 (16)

Types:	1 = Main (type 10)
		2 = Modernization revaluation (type 12)
		3 = Negative revaluation (type 17)
		4 = Positive revaluation (type 16)
			
@param		cType10	= main model indicated		
@return		Array with the new models 2 (12), 3 (17) and 4 (16)
@author		Fabio Cazarini
@since		28/03/2017
@version	12
@project	MA3
/*/
//-------------------------------------------------------------------
Function _ATFNValNM(cType10 as string)
	Local aRet as array
	Local cModAtf as string
	Local aNewModels as array
	Local nX as numeric
	Local cAuxModels as string
	Local aAuxModels as array

	aRet	:= {space(02), space(02), space(02)}
	cModAtf	:= SuperGetMv("MV_MODATF",.F.,"") // Ex.: 96/97/98/99;A1/A2/A3/A4

	If !Empty(cModAtf) .and. !empty(cType10)
		aNewModels := Separa(cModAtf, ';', .t.)
		
		For nX := 1 to len( aNewModels )
			cAuxModels := aNewModels[nX]
			aAuxModels := Separa(cAuxModels, '/', .t.) 
			If len(aAuxModels) == 4
				If aAuxModels[01] == cType10
					aRet := {aAuxModels[02], aAuxModels[03], aAuxModels[04]}
					Exit			
				Endif
			Endif
		Next nX
	Endif
 
Return aRet


//--------------------------------------------------
/*/{Protheus.doc} RUPATFSIX
Function of change index parameter (only for Russia) for SN4 (N4_FILIAL+N4_ORIUID)
Used in RupAtf 
@author Menyashina Alexandra (MA-3)
@since 15/08/2018
@version P12.1.22

@return nil
/*/
//--------------------------------------------------
Function RUPATFSIX()
	Local aAreaSIX  AS ARRAY
	Local cInd		AS Character

	aAreaSIX	:= SIX->(GetArea())
	cInd		:= "B"

	SIX->(dbSetOrder(1))	//INDICE+ORDEM
	SIX->(dbGoTop())

	If SIX->(dbSeek("SN4"+cInd))
		If RecLock( "SIX", .F. )
			SIX->IX_VIRTUAL  := "2"
		EndIf
	SIX->(MsUnlock())
	EndIf

	RestArea(aAreaSIX)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} RU01XFN001_CheckN4OCORR
First Russian complementer of the function AF012AltEx 
Check if the asset has moviments with the occourency 04 or 006
@author Eduardo.FLima
@since 22/11/2019
@version 1.0
@project MA3 - Russia
@Parameter 

@Return
	lCheck: 	Logically, Returns if the SN4 with Ocoureency 06 or 20  is found./*/
//-------------------------------------------------------------------
Function RU01XFN001_CheckN4OCORR()
	Local lCheck 		as Logical
	Local cQuery 		as Character
	Local cAliasTMP 	as Character
	
	lCheck		:=.T.
	cQuery		:=""
	cAliasTMP	:=""

	cQuery:= " SELECT N4_OCORR"
	cQuery+= " FROM " + RetSqlName("SN1")
	cQuery+= " LEFT JOIN " + RetSqlName("SN4")
	cQuery+= " ON N1_FILIAL = N4_FILIAL"
	cQuery+= " AND N1_CBASE = N4_CBASE"
	cQuery+= " AND N1_ITEM = N4_ITEM"
	cQuery+= " WHERE N1_FILIAL ='" +  xFilial("SN1") + "'"
	cQuery+= " AND N1_CBASE ='" + SN1->N1_CBASE + "'"
	cQuery+= " AND N1_ITEM ='" + SN1->N1_ITEM + "'"
	cQuery += " AND N4_OCORR IN ('06','20')  "
	cQuery+= " AND " + RetSqlName("SN4") + ".D_E_L_E_T_=''"
	cQuery+= " AND " + RetSqlName("SN1") + ".D_E_L_E_T_=''"
	cAliasTMP := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
	lCheck := (cAliasTMP)->(EOF())
Return lCheck



//-------------------------------------------------------------------
/*/{Protheus.doc} RU01XFN002_updateSN4accounts
Seccond Russian complementer of the function AF012AltEx 
Update SN4 if change ledger accounts
@author Eduardo.FLima
@since 22/11/2019
@version 1.0
@project MA3 - Russia
@Parameter 
    oModel: Object Model of the fixed assets from the routine ATFA012
@Return
	aRet: 	aRet: 	Array, Returns a list with the recnos of the SN4 changed./*/
//-------------------------------------------------------------------
Function RU01XFN002_updateSN4accounts(oModel)
	Local nX	As Numeric
	Local cKey	As CHARACTER
	Local aRet	As Array

	Default oModel		:= FWModelActive()

	nX:= 0
	cKey:= ""
	aRet:= {}

	dbSelectArea("SN4")  
	SN4->(dbSetOrder(1))	//N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ
	For nX := 1 to oModel:GetModel("SN3DETAIL"):Length()
		oModel:GetModel("SN3DETAIL"):GoLine(nX)
		cKey := xFilial("SN4") 
		cKey += oModel:GetModel("SN3DETAIL"):GetValue('N3_CBASE')
		cKey += oModel:GetModel("SN3DETAIL"):GetValue('N3_ITEM')
		cKey += oModel:GetModel("SN3DETAIL"):GetValue('N3_TIPO') 
		cKey += DTOS(oModel:GetModel("SN3DETAIL"):GetValue('N3_AQUISIC'))
		cKey += "05" 
		cKey += oModel:GetModel("SN3DETAIL"):GetValue('N3_SEQ') 
		If (!oModel:GetModel("SN3DETAIL"):IsDeleted()) .and. SN4->(dbSeek( cKey))
			aSize(aRet,nX)			
			aRet[nx]:= ATFXMOV(;
			xFilial("SN3"),;
			/*cIDMOV*/,;
			oModel:GetModel("SN3DETAIL"):GetValue('N3_AQUISIC'),;
			SN4->N4_OCORR,;
			oModel:GetModel("SN3DETAIL"):GetValue("N3_CBASE"),;
			oModel:GetModel("SN3DETAIL"):GetValue("N3_ITEM"),;
			oModel:GetModel("SN3DETAIL"):GetValue("N3_TIPO"),;
			oModel:GetModel("SN3DETAIL"):GetValue("N3_BAIXA"),;
			oModel:GetModel("SN3DETAIL"):GetValue("N3_SEQ"),;
			oModel:GetModel("SN3DETAIL"):GetValue("N3_SEQREAV"),;
			SN4->N4_TIPOCNT,;
			oModel:GetModel("SN1MASTER"):GetValue("N1_QUANTD"),;
			oModel:GetModel("SN3DETAIL"):GetValue("N3_TPSALDO"),;
			Nil,;
			/*aValues*/,;
			/*aCompData*/,;
			SN4->(RECNO()),;
			.T.,;
			Nil,;
			Nil,;
			Nil,;
			SN4->N4_LP,;
			"ATFA012",;
				/*cUUID*/)
		EndIf
	Next nX	
Return aRet



//-------------------------------------------------------------------
/*/{Protheus.doc} VldPerFM1

Validate the link between depreciation period and depreciation group
Used in N3_PERDEPR valid

@param		None		
@return		Logical .t. = valid period / .f. invalid period 
@author		Fabio Cazarini
@since		13/04/2017
@version	12
@project	MA3
/*/
//-------------------------------------------------------------------
Function VldPerFM1()
	Local nPerDepr		AS NUMERIC
	Local nOper			AS NUMERIC
	Local cCalcDep		AS CHARACTER
	Local cDepGrp		AS CHARACTER
	Local lRetFM1		AS LOGICAL
	Local aArea			AS ARRAY
	Local aAreaFM1		AS ARRAY
	Local oModel		AS OBJECT
	Local oAux			AS OBJECT

	lRetFM1		:= .T.
	aArea		:= GetArea()
	aAreaFM1	:= FM1->(GetArea())

	oModel 		:= FwModelActive()
	oAux 		:= oModel:GetModel('SN3DETAIL')

	If ! oAux:IsDeleted()
		cCalcDep	:= GetNewPar("MV_CALCDEP","0") // 0 = Monthly or 1 = Annually
		nPerDepr	:= 0
		nOper		:= oModel:GetOperation()
		cDepGrp		:= oModel:GetValue('SN1MASTER','N1_DEPGRP')
		nPerDepr	:= oAux:GetValue('N3_PERDEPR')

		If (nOper == 3 .OR. nOper == 4) .And. ! Empty(cDepGrp)
			FM1->(DbSetOrder(1)) // FM1_FILIAL+FM1_CODE
			If FM1->(DbSeek(xFilial("FM1") + cDepGrp))
				If cCalcDep == "1" // 0 = Monthly or 1 = Annually
					nPerDepr := nPerDepr * 12
				EndIf
				If nPerDepr > 0 .AND. (nPerDepr <= (FM1->FM1_FROM*12) .OR. nPerDepr > (FM1->FM1_TO*12))
					Help("",1,"ATFA012PDOG",,STR0034,1,0)	// "The period of depreciation is out of depreciation group interval"
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaFM1)
	RestArea(aArea)

Return lRetFM1

//-----------------------------------------------------------------------
/*/{Protheus.doc} AF036RUSOI()

Russian function to generate outflow invoice for sold fixed assets

@param		CHARACTER cSeries - Serie for the invoice
@param		CHARACTER cCustomer - Code of the customer (A1_COD)
@param		CHARACTER cCustUnit - Unit of the customer (A1_LOJA)
@param		CHARACTER cPaymCond - Payment condition
@param		CHARACTER cClass - Class of the operation
@param		NUMERIC nSalesCurr - Currency used in sales order
@param		ARRAY aItems
	Invoice items {
		Product code,
		Quantity,
		Unit Price,
		TIO,
		Operation Type,
		Fiscal Code
	}
@return		ARRAY aInvoice {cInvNumber, cInvSerie}
@author 	victor.rezende
@since 		09/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function AF036RUSOI(cSeries AS CHARACTER, cCustomer AS CHARACTER, cCustUnit AS CHARACTER, cPaymCond AS CHARACTER, cClass AS CHARACTER, nSalesCurr AS NUMERIC, aItems AS ARRAY)
Local nX			AS NUMERIC
Local cQuery		AS CHARACTER
Local cTmpAls		AS CHARACTER
Local cSONumber		AS CHARACTER
Local cInvNumber	AS CHARACTER
Local cInvSerie		AS CHARACTER
Local cIteSO		AS CHARACTER
Local lRet			AS LOGICAL
Local aSOHeader		AS ARRAY
Local aSOItems		AS ARRAY
Local aTmp			AS ARRAY
Local aSOBalances	AS ARRAY
Local aSOBlocked	AS ARRAY
Local aParams		AS ARRAY
Local aInvRegs		AS ARRAY
Local aInvoices		AS ARRAY
Local aArea			AS ARRAY
Local aAreaSC5		AS ARRAY

Private lMsErroAuto	:= .F.

aArea		:= GetArea()
aAreaSC5	:= SC5->(GetArea())
lRet		:= .T.
cInvNumber	:= ""
cInvSerie	:= ""

BEGIN TRANSACTION

// Generate sales order for fixed asset
If lRet
	aSOHeader	:= {}
	aAdd(aSOHeader, { "C5_TIPO",	"N",		Nil })
	aAdd(aSOHeader, { "C5_DOCGER ",	"1",		Nil })	// Generate invoice
	aAdd(aSOHeader, { "C5_CLIENTE",	cCustomer,	Nil })
	aAdd(aSOHeader, { "C5_LOJACLI",	cCustUnit,	Nil })
	aAdd(aSOHeader, { "C5_CONDPAG",	cPaymCond,	Nil })
	aAdd(aSOHeader, { "C5_NATUREZ",	cClass,	Nil })
	If ! Empty(nSalesCurr)
		aAdd(aSOHeader, { "C5_MOEDA",	nSalesCurr,	Nil })
	EndIf

	aSOItems	:= {}
	For nX := 1 To Len(aItems)
		cIteSO		:= StrZero(nX, GetSX3Cache("C6_ITEM", "X3_TAMANHO"))
		aTmp		:= {}
		aAdd(aTmp, { "C6_ITEM",		cIteSO,	Nil })
		aAdd(aTmp, { "C6_PRODUTO",	aItems[nX, 01],	Nil })
		aAdd(aTmp, { "C6_QTDVEN", 	aItems[nX, 02],	Nil })
		aAdd(aTmp, { "C6_PRCVEN", 	aItems[nX, 03],	Nil })
		aAdd(aTmp, { "C6_TES",		aItems[nX, 04],	Nil })
		aAdd(aSOItems, aTmp)
	Next nX

	lMsErroAuto	:= .F.
	MSExecAuto( { |x,y,z| MATA410(x,y,z) }, aSOHeader, aSOItems, 3 )
	lRet		:= ! lMsErroAuto
	If ! lRet
		MostraErro()
		Help("",1,"AF036RUSSOCREATE",,STR0037,1,0)	// "Error creating sales order for write-off"
	Else
		cSONumber	:= SC5->C5_NUM
	EndIf
EndIf

// Perform evaluation of available balances
If lRet
	If lRet
		SC5->(dbSetOrder(1))	// C5_FILIAL+C5_NUM
		lRet	:= lRet .And. SC5->(dbSeek(xFilial("SC5") + cSONumber))
		If ! lRet
			Help("",1,"AF036RUSSONOTFOUND",,STR0038,1,0)	// "Sales order of writen-off fixed asset not found"
		EndIf
	EndIf

	If lRet
		aSOBalances	:= {}
		aSOBlocked	:= {}
		Ma410LbNfs( 2, @aSOBalances, @aSOBlocked )
		Ma410LbNfs( 1, @aSOBalances, @aSOBlocked )

		aInvRegs	:= {}
		For nX := 1 To Len(aSOBalances)
			aAdd(aInvRegs, aSOBalances[nX, 08])
		Next nX

		lRet	:= lRet .And. ! Empty(aSOBalances) .And. Empty(aSOBlocked)
		If ! lRet
			Help("",1,"AF036RUSSONOBALANCE",,STR0039,1,0)	// "The preparation of the sales order for invoicing failed, check inventory balances."
		EndIf
	EndIf
EndIf

// Generate invoice
If lRet
	Pergunte("MTA410FAT", .F.)
	aParams	:= {}
	aAdd(aParams, SC5->C5_NUM)	// Sales order - from
	aAdd(aParams, SC5->C5_NUM)	// Sales order - to
	aAdd(aParams, SC5->C5_CLIENTE)	// Customers - from
	aAdd(aParams, SC5->C5_CLIENTE)	// Customers - to
	aAdd(aParams, SC5->C5_LOJACLI)	// Customers unit - from
	aAdd(aParams, SC5->C5_LOJACLI)	// Customers unit - to
	aAdd(aParams, MV_PAR01)	// Group from
	aAdd(aParams, MV_PAR02)	// Group to
	aAdd(aParams, MV_PAR03)	// Aggregator from
	aAdd(aParams, MV_PAR04)	// Aggregator to
	aAdd(aParams, MV_PAR05)	// Show acc entries
	aAdd(aParams, MV_PAR06)	// Group acc entries
	aAdd(aParams, MV_PAR07)	// Online acc entries
	aAdd(aParams, 2)	// Inverse
	aAdd(aParams, MV_PAR08)	// Update binding
	aAdd(aParams, MV_PAR09)	// Group
	aAdd(aParams, MV_PAR10)	// Minimum value
	aAdd(aParams, 2)	// 
	aAdd(aParams, "")	// Transporter from
	aAdd(aParams, "Z")	// Transporter to
	aAdd(aParams, MV_PAR11)	// Readjust on same NF
	aAdd(aParams, MV_PAR12)	// Bill order through
	aAdd(aParams, MV_PAR13)	// Currency
	aAdd(aParams, MV_PAR14)	// Account by
	aAdd(aParams, 1)	// Type of SO
	
	// Invoices are being returned even when operation is cancelled,
	//	should check manually
	aInvoices	:= a468nFatura(;
		"SC9" /* cAlias */,;
		aParams /* aParams */,;
		aInvRegs /* aRecs */,;
		/* cCamposQueb */,;
		/* lCarga */,;
		/* lAuto */,;
		/* aNotas */,;
		/* lMT310 */,;
		cSeries /* c310Ser */,;
		/* c310Num */)
	
	SX5->(MsUnLock())
	FWPutSX5("TRANSL", "01", cSeries, AllTrim(SX5->X5_DESCRI), AllTrim(SX5->X5_DESCRI), AllTrim(SX5->X5_DESCRI), AllTrim(SX5->X5_DESCRI))
EndIf

If lRet
	cInvNumber	:= ""
	cInvSerie	:= ""

	cQuery	:= " select d2_doc, d2_serie "
	cQuery	+="   from " + RetSqlName("SD2")
	cQuery	+= "  where d_e_l_e_t_ = ' ' "
	cQuery	+= "    and d2_filial = '"+xFilial("SD2")+"' "
	cQuery	+= "    and d2_pedido = '"+cSONumber+"' "
	cQuery	+= " group by d2_doc, d2_serie "

	cTmpAls		:= RU01GETALS(cQuery)
	lRet		:= (cTmpAls)->(! EOF())
	If lRet
		cInvNumber	:= (cTmpAls)->D2_DOC
		cInvSerie	:= (cTmpAls)->D2_SERIE

		lRet		:= ! Empty(cInvNumber) .And. ! Empty(cInvSerie)
	EndIf
	(cTmpAls)->(dbCloseArea())

	If ! lRet
		Help("",1,"AF036RUSSONOINVOICE",,STR0040,1,0)	// "The outflow invoice was not created."
	EndIf
EndIf

If ! lRet
	DisarmTransaction()
EndIf

END TRANSACTION

RestArea(aAreaSC5)
RestArea(aArea)

Return {cInvNumber, cInvSerie}

//-----------------------------------------------------------------------
/*/{Protheus.doc} ProcFARules

Enforce localization rules

@param		ARRAY aFARules
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        EV01A012RU
/*/
//-----------------------------------------------------------------------
Function ProcFARules(aFARules AS ARRAY)
Local nX		AS NUMERIC
Local cBase		AS CHARACTER
Local cItem		AS CHARACTER
Local aProc		AS ARRAY
aProc		:= {}

For nX := 1 To Len(aFARules)
	cBase		:= aFARules[nX,01]
	cItem		:= aFARules[nX,02]

	If Empty(AScan(aProc, cBase + cItem))
		RU01RULES(cBase, cItem)
		aAdd(aProc, cBase + cItem)
	EndIf
Next nX

Return Nil



Function RU01XFN003_AF012RUTAX(cCampo)
	Local cMsg as Character
	Local lContinue as Logical
	Local oModel as Object
	Local oAux as Object
	Local nNewPerDep as Numeric
	Local nNewTxDep as Numeric 
	Local cCBASE as Character
	Local cITEM as Character
	Local cTIPO as Character
	Local cBAIXA as Character
	Local cSEQ as Character
	local nQuantas as Numeric
	Local nX as Numeric
	Local cCalcDep as Character
	Local lExistSN3 as Logical
	Local aArea		AS ARRAY
	Local aAreaSN3	AS ARRAY

	// If the execution is by job (without interace), quit
	If IsBlind() 
		Return
	Endif

	If !("N3_PERDEPR" $ ReadVar() .or. "N3_TXDEPR" $ ReadVar())
		RETURN
	Endif

	oModel		:= FWModelActive()
	oAux		:= oModel:GetModel( 'SN3DETAIL' )

	lContinue 	:= .F.
	cMsg		:= ""

	cCalcDep	:= GetNewPar("MV_CALCDEP","0") // 0 = Monthly or 1 = Annually
	cCBASE		:= oAux:GetValue('N3_CBASE')
	cITEM		:= oAux:GetValue('N3_ITEM')
	cTIPO		:= oAux:GetValue('N3_TIPO')
	cBAIXA		:= oAux:GetValue('N3_BAIXA')
	cSEQ		:= oAux:GetValue('N3_SEQ')

	lContinue 	:= .T.

	aArea		:= GetArea()
	aAreaSN3 	:= SN3->(GetArea())
	SN3->(DbSetOrder(1))
	lExistSN3 := SN3->(MsSeek(xFilial("SN3") + cCBASE + cITEM + cTIPO + cBAIXA + cSEQ))

	If lExistSN3
		If left(cCampo,9) == "N3_TXDEPR"
			nNewTxDep	:= oAux:GetValue('N3_TXDEPR1')
			If nNewTxDep > 0
				cMsg := STR0041 + " " + right(cCampo,1) + " ?" // "Do you really want to alter the field Depreciation Rate"
				lContinue := RusCheckModer() .Or. MsgYesNo(cMsg, STR0042) //"Confirma Alteracao?"
			Endif	
		Elseif cCampo == "N3_PERDEPR"
			nNewPerDep	:= oAux:GetValue('N3_PERDEPR')
			If nNewPerDep > 0
				cMsg := STR0043 // "Do you really want to alter the field Annual Depreciation Period?"
				lContinue := RusCheckModer() .Or. MsgYesNo(cMsg, STR0042) //"Confirma Alteracao?"
			Endif	
		Endif
	Endif

	nQuantas := AtfMoedas() // multiple currencies

	If lContinue
		If cCampo == "N3_TXDEPR1"
			// Calculate the depreciation period according to the new depreciation tax
			nNewTxDep	:= oAux:GetValue('N3_TXDEPR1')

			If nNewTxDep > 0
				nNewPerDep := (100 * 12)  / nNewTxDep
				If cCalcDep == "1" // 1 = Annually
					If nNewPerDep / 12 == Int(nNewPerDep / 12)
						nNewPerDep := nNewPerDep / 12
					Else
						nNewPerDep := Int(nNewPerDep / 12) + 1					
					Endif	
				Endif
				nNewPerDep := NoRound(nNewPerDep,  TAMSX3('N3_PERDEPR')[2])
				
				oAux:LoadValue('N3_PERDEPR', nNewPerDep) // update the field 
			Endif
		Elseif cCampo == "N3_PERDEPR"
			// Calculate the depreciation tax according to the new depreciation period
			nNewPerDep	:= oAux:GetValue('N3_PERDEPR')

			If nNewPerDep > 0
				nNewTxDep	:= RU01TXDEPR(nNewPerDep, 'SN3')
				For nX := 1 to nQuantas // multiple currencies
					oAux:LoadValue('N3_TXDEPR' + Alltrim(Str(nX)), nNewTxDep) // update the field
				Next nX
			Endif
		Endif
	Else
		If lExistSN3
			// return the original value of the fields
			If cCampo == "N3_TXDEPR1"
				For nX := 1 to nQuantas // multiple currencies
					oAux:LoadValue('N3_TXDEPR' + Alltrim(Str(nX)), SN3->&('N3_TXDEPR' + Alltrim(Str(nX)))) 
				Next nX
			Elseif cCampo == "N3_PERDEPR"
				oAux:LoadValue('N3_PERDEPR', SN3->N3_PERDEPR)	
				For nX := 1 to nQuantas // multiple currencies
					oAux:LoadValue('N3_TXDEPR' + Alltrim(Str(nX)), SN3->&('N3_TXDEPR' + Alltrim(Str(nX)))) 
				Next nX
			Endif
		Endif
	Endif

	RestArea(aAreaSN3)
	RestArea(aArea)

Return 


//-------------------------------------------------------------------

//-----------------------------------------------------------------------
/*/{Protheus.doc} RusCheckModer

Check for revaluation or modernization functions in call stack

@param		None
@return		LOGICAL
@author 	victor.rezende
@since 		03/10/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RusCheckModer()
Return IsInCallStack("RU01T03COM")


//-------------------------------------------------------------------
/*/{Protheus.doc} PerGrpFM1

Validate the link between depreciation period and depreciation group
Used in N1_DEPGRP valid

@param		None		
@return		Logical .t. = valid period / .f. invalid period 
@author		Fabio Cazarini
@since		12/04/2017
@version	12
@project	MA3
/*/
//-------------------------------------------------------------------
Function PerGrpFM1()
	Local lRetFM1 as Logical
	Local cCalcDep as String
	Local nPerDepr as Numeric
	Local oModel as Object
	Local oAux as Object
	Local nOper as Numeric
	Local nX as Numeric
	Local lAlerta as Logical
	Local cDepGrp as String
	Local aArea		AS ARRAY
	Local aAreaFM1	AS ARRAY

	If IsBlind()
		Return .T.
	Endif

	lRetFM1		:= .T.
	cCalcDep	:= SuperGetMv("MV_CALCDEP",.F.,"") // 0 = Monthly or 1 = Annually
	nPerDepr	:= 0
	lAlerta		:= .F.

	oModel 		:= FwModelActive()
	oAux 		:= oModel:GetModel('SN3DETAIL')
	nOper		:= oModel:GetOperation()

	cDepGrp := oModel:GetValue('SN1MASTER','N1_DEPGRP')

	If (nOper == 3 .OR. nOper == 4)
		If !Empty(cDepGrp)
			aArea		:= GetArea()
			aAreaFM1 	:= FM1->(GetArea())
		
			FM1->(DbSetOrder(1)) // FM1_FILIAL+FM1_CODE                                                                                                                                             
			If FM1->(DbSeek(xFilial("FM1") + cDepGrp))
				For nX := 1 To oAux:Length()
					If !oAux:IsDeleted(nX)
						nPerDepr := oAux:GetValue('N3_PERDEPR',nX)
						If cCalcDep == "1" // 0 = Monthly or 1 = Annually
							nPerDepr := nPerDepr * 12
						Endif
						If nPerDepr > 0 .AND. (nPerDepr <= (FM1->FM1_FROM*12) .OR. nPerDepr > (FM1->FM1_TO*12))
							lAlerta := .T.
							Exit
						Endif  
					Endif
				Next nX
			EndIf

			RestArea(aAreaFM1)
			RestArea(aArea)
		Endif
	Endif	

	If lAlerta
		Help("",1,"ATFA012DGOI",,STR0044,1,0)	// "In the Balances and Values grid there are one or more items with the period of depreciation out of group interval"
	Endif

Return lRetFM1


//-------------------------------------------------------------------
/*/{Protheus.doc}AF012APERD

X3_WHEN of the field N3_PERDEPR

@author Fabio Cazarini
@since  28/04/2017
@version 12
/*/   
//-------------------------------------------------------------------
Function AF012APERD()
	Local oModel	:= FWModelActive()
	Local lRet		:= .T.

	lRet	:= lRet .And. (M->N1_STATUS $ " 0" .Or. RusCheckModer())
	lRet	:= lRet .And. (ValType(oModel) == "U" .Or. ! oModel:IsActive() .Or. oModel:GetValue('SN3DETAIL','N3_TPDEPR') != "F")

	oModel := Nil
Return lRet 



//-----------------------------------------------------------------------
/*/{Protheus.doc} A050Conservation

Russian Project

Validates if the positioned fixed asset is eligible for depreciation
calculation.

@param		None
@return		LOGICAL
@author 	victor.rezende
@since 		11/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01XFN004_A050Conservation()
	Local cF44Key	:= ""
	Local lRet		:= .T.
	Local lShouldDep:= .T.
	Local dDtIniC	:= CToD("  /  /  ")
	Local dDtEndC	:= CToD("  /  /  ")

	cF44Key	:= RU01T02CDO(dDataBase)
	If !Empty(cF44Key)
		F44->(dbSetOrder(1))	//F44_FILIAL+F44_CODE+F44_TYPE
		If F44->(dbSeek(cF44Key))
			While F44->(!EOF()) .And. F44->(F44_FILIAL+F44_CODE) == cF44Key
				If F44->F44_STATUS <> "1"
					// Skip stornoed registers
				ElseIf F44->F44_TYPE == "1"
					lShouldDep	:= !(F44->F44_DEPREC == "1")
					dDtIniC		:= F44->F44_DATE
				ElseIf F44->F44_TYPE == "2"
					lShouldDep	:= lShouldDep .And. !(F44->F44_DEPREC == "1")
					dDtEndC		:= F44->F44_DATE
				EndIf
				F44->(dbSkip())
			EndDo
		EndIf
	EndIf

	If ! lShouldDep
		If dDataBase >= LastDay(dDtIniC) + 1
			If Empty(dDtEndC) .Or. dDataBase <= LastDay(dDtEndC)
				lRet	:= .F.
			EndIf
		EndIf
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} InFieldSN1

Initialize SN1 fields 

@param		oModel = FWLoadModel
			cField = Field name
			lIsCopy = Is copy operation?		
@return		Initial value of the fields 
@author		Fabio Cazarini
@since		17/04/2017
@version	12
@project	MA3
/*/
//-------------------------------------------------------------------
Function InFieldSN1(oModel, cField, lIsCopy)
	Local cRet
	Local nOper as Numeric
	Local cItem as String
	Local aAreaSN1 as Array
	Local cSeqPla as String

	Default oModel 	:= FWModelActive() 
	Default cField 	:= strtran(Alltrim(Upper(ReadVar())),'M->','') 
	Default lIsCopy	:= .F.
	
	If IsInCallStack("AF012CPY")
		lIsCopy := .T.
	EndIf

	nOper		:= oModel:GetOperation()
	cRet 		:= oModel:GetValue('SN1MASTER',cField)

	If nOper == 3 .or. lIsCopy
		If cField == 'N1_ITEM'
			cItem 	:= STRZERO(1,LEN(SN1->N1_ITEM))
			cRet	:= cItem

		Elseif cField == 'N1_CBASE'
			cItem		:= STRZERO(1,LEN(SN1->N1_ITEM))
			
			aAreaSN1 	:= SN1->(GetArea())
			SN1->(DbSetOrder(1)) // N1_FILIAL + N1_CBASE + N1_ITEM
			Do while .t.
				cRet := PADR(GETSXENUM("SN1", "N1_CBASE", "N1_CBASE" + CEMPANT), LEN(SN1->N1_CBASE))
				If !SN1->(DbSeek(xFilial("SN1") + cRet + cItem))
					Exit
				Endif
			Enddo	
			SN1->(RestArea(aAreaSN1))

		Elseif cField == 'N1_CHAPA'
			cSeqPla := Alltrim(GetMV("MV_SEQPLA")) // 1=Manually, 2=Sequential and 3=Asset code  
		
			If cSeqPla == "2"
				aAreaSN1 := SN1->(GetArea())
				SN1->(DbSetOrder(2)) // N1_FILIAL + N1_CHAPA
				Do while .t.
					cRet := PADR(GETSXENUM("SN1", "N1_CHAPA", "N1_CHAPA" + cEmpAnt), Len(SN1->N1_CHAPA))
					If !SN1->(DbSeek(xFilial("SN1") + cRet))
						Exit
					Endif
				Enddo	
				SN1->(RestArea(aAreaSN1))
			Elseif cSeqPla == "3"
				cRet := PADR(oModel:GetValue('SN1MASTER','N1_CBASE'), Len(SN1->N1_CHAPA))
			Endif

		Endif

		If lIsCopy .and. (cField == "N1_ITEM" .or. cField == "N1_CBASE" .or. cField == "N1_CHAPA")
			oModel:LoadValue("SN1MASTER",cField,cRet)
		Endif
	Endif

Return cRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} AF036RUQRY

Query baixa lote russia

@param		LOGICAL lRusDepBonus = Define se esta utilizando depreciacao bonus
@param		CHARACTER cRusTypeDepBonus = Define o tipo de depreciacao bonus
@param		OBJECT oModelPar = Model contendo parametros do pergunte
@return		CHARACTER
@author 	victor.rezende
@since 		05/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01XFN005_AF036RUQRY(lRusDepBonus AS LOGICAL, cRusTypeDepBonus AS CHARACTER, oModelPar AS OBJECT)
	Local cQuery	AS CHARACTER
	Local cAtfCur	AS CHARACTER
	Local lDeprMod	AS LOGICAL

	cQuery		:= ""
	cAtfCur		:= ""
	lDeprMod	:= .F.

	cAtfCur		:= GetNewPar("MV_ATFMOED", "")
	lDeprMod	:= oModelPar:GetValue("DEPRBONUS") == 1 .And. oModelPar:GetValue("DEPBNSTYPE") != 1

	cQuery := "SELECT " + CRLF
	cQuery += "N1_FILIAL "	+ CRLF
	cQuery += ",N1_DESCRIC "	+ CRLF
	cQuery += ",N1_CBASE "	+ CRLF
	cQuery += ",N1_ITEM "		+ CRLF
	cQuery += ",N1_QUANTD "	+ CRLF
	If lDeprMod
		cQuery += ", N3_AMPLIA"+cAtfCur+" * FM1_BONUS / (N3_AMPLIA"+cAtfCur+" + N3_VORIG"+cAtfCur+") AS FM1_BONUS "	+ CRLF
	Else
		cQuery += ",FM1_BONUS "	+ CRLF
	EndIf
	cQuery += " FROM " + RetSqlName("SN1") + " SN1 " + CRLF
	cQuery += "," + RetSqlName("FM1") + " FM1 " + CRLF
	cQuery += "," + RetSqlName("SN3") + " SN3 " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += " SN1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND SN1.N1_QUANTD > 0 " + CRLF
	cQuery += " AND SN3.N3_OPER = '1' " + CRLF
	cQuery += " AND SN3.N3_BAIXA = '0' " + CRLF
	cQuery += " AND SN3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND SN3.N3_FILIAL = SN1.N1_FILIAL " + CRLF
	cQuery += " AND SN3.N3_CBASE = SN1.N1_CBASE " + CRLF
	cQuery += " AND SN3.N3_ITEM = SN1.N1_ITEM " + CRLF
	cQuery += " AND SN3.N3_TPDEPR <> 'N' " + CRLF
	If lRusDepBonus
		cQuery += " AND SN3.N3_TIPO = '" + cRusTypeDepBonus + "' " + CRLF
		If oModelPar:GetValue("DEPBNSTYPE") == 1
			cQuery += " AND SN3.N3_DINDEPR BETWEEN '" + DToS(FirstDay(dDataBase)) + "' AND '" + DToS(LastDay(dDataBase)) + "' " + CRLF
		EndIf
		cQuery += " AND NOT EXISTS ( " + CRLF
		cQuery += " SELECT 1 " + CRLF
		cQuery += " FROM " + RetSqlName("FN7") + " FN7" + CRLF
		cQuery += " WHERE FN7.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += " AND FN7.FN7_FILIAL = SN3.N3_FILIAL " + CRLF
		cQuery += " AND FN7.FN7_CBASE = SN3.N3_CBASE " + CRLF
		cQuery += " AND FN7.FN7_CITEM = SN3.N3_ITEM " + CRLF
		cQuery += " AND FN7.FN7_TIPO = SN3.N3_TIPO " + CRLF
		cQuery += " AND FN7.FN7_TPSALD = SN3.N3_TPSALDO " + CRLF
		cQuery += " AND FN7.FN7_MOTIVO = '09' " + CRLF
		cQuery += " AND FN7.FN7_STATUS = '1' " + CRLF
		cQuery += " ) " + CRLF
	EndIf
	cQuery += " AND SN1.N1_STATUS = '1' " + CRLF
	cQuery += " AND FM1.FM1_CODE BETWEEN	'"		+ oModelPar:GetValue("GRUPODE")			+ "' AND '" + oModelPar:GetValue("GRUPOATE")		+ "' " + CRLF
	cQuery += " AND FM1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND FM1.FM1_FILIAL = SN1.N1_FILIAL " + CRLF
	cQuery += " AND FM1.FM1_CODE = SN1.N1_DEPGRP " + CRLF
	cQuery += " AND SN1.N1_FILIAL BETWEEN '"	+ oModelPar:GetValue("FILIALDE")		+ "' AND '" + oModelPar:GetValue("FILIALATE")		+ "' " + CRLF
	cQuery += " AND SN1.N1_CBASE BETWEEN	'"		+ oModelPar:GetValue("CODIGODE")		+ "' AND '" + oModelPar:GetValue("CODIGOATE")		+ "' " + CRLF
	cQuery += " AND SN1.N1_ITEM BETWEEN	'"		+ oModelPar:GetValue("ITEMDE")			+ "' AND '" + oModelPar:GetValue("ITEMATE")		+ "' " + CRLF
	cQuery += " AND SN1.N1_AQUISIC BETWEEN '"	+ DTOS(oModelPar:GetValue("DATADE"))	+ "' AND '" + DTOS(oModelPar:GetValue("DATAATE"))+ "' " + CRLF

	/*
	* Ponto de Entrada para filtro da seleção de ativos na tela de baixa de ativos em lote
	*/
	If ExistBlock("AF36AFIL")
		cQuery += " AND " + ExecBlock("AF36AFIL",.F.,.F.) + CRLF
	EndIf

	cQuery += "GROUP BY " + CRLF
	cQuery += "N1_FILIAL "	+ CRLF
	cQuery += ",N1_DESCRIC "	+ CRLF
	cQuery += ",N1_CBASE "	+ CRLF
	cQuery += ",N1_ITEM "		+ CRLF
	cQuery += ",N1_QUANTD "	+ CRLF
	If lDeprMod
		cQuery += ",N3_AMPLIA"+cAtfCur+", FM1_BONUS, N3_VORIG"+cAtfCur+" " + CRLF
	Else
		cQuery += ",FM1_BONUS "	+ CRLF
	EndIf

	cQuery += " ORDER BY " + CRLF
	cQuery += " N1_FILIAL ,N1_CBASE,N1_ITEM " + CRLF

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc}AF430CBG1

Return a string to be used in X3_CBOX field

Example:	#AF430CBG1({'01','10'})

@param		aChave = Array with the G1 SX5 table key 		
@return		String to be used in X3_CBOX field
@author		Fabio Cazarini
@since		29/03/2017
@version	12
@project	MA3
/*/
//-------------------------------------------------------------------
Function AF430CBG1(aChave)
	Local cRet as Character
	Local aArea as array
	Local aAreaSX5 as array
	Local lTemMod10 as logical
	Local aValMod as array
	Local cValMod as Character
	Local nValMod as numeric

	cRet		:= ''
	aArea		:= GetArea()
	aAreaSX5	:= SX5->( GetArea() )
	lTemMod10	:= .F.
	aValMod		:= {}
	cValMod		:= ''
	nValMod		:= 0

	DbSelectArea('SX5')
	DbSetOrder(1)
	MsSeek(xFilial('SX5')+'G1')

	Do while !SX5->(EOF()) .AND. (SX5->X5_FILIAL + SX5->X5_TABELA) == (xFilial('SX5')+'G1') 
		If AsCan(aChave,{|aX| AllTrim(aX) == AllTrim(SX5->X5_CHAVE)}) > 0
			cRet := cRet + IIf(empty(cRet),'',';') + Alltrim(SX5->X5_CHAVE) + '=' + Alltrim(X5Descri())
		EndIf

		If Alltrim(SX5->X5_CHAVE) == '10'
			lTemMod10 := .T.
		Endif
			
		SX5->(DbSkip())
	EndDo

	If lTemMod10 
		cValMod	:= ATFNValMod( {1}, '/' )
		aValMod	:= Separa(cValMod, '/', .f.) 

		DbSelectArea('SX5')
		DbSetOrder(1) // X5_FILIAL+X5_TABELA+X5_CHAVE                                                                                                                                    
		For nValMod := 1 to len(aValMod)
			If MsSeek(xFilial('SX5')+'G1'+aValMod[nValMod])
				cRet := cRet + IIf(empty(cRet),'',';') + Alltrim(SX5->X5_CHAVE) + '=' + Alltrim(X5Descri())
			Endif
		Next nValMod
	Endif

	RestArea(aAreaSX5)
	RestArea(aArea)

Return(cRet)
