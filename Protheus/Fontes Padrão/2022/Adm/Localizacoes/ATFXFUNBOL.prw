#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ATFA036.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} ATF036

Rotina de Baixa de Ativos - BOLIVIA.

@author felipe.cunha
@since 14/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function ATF036BOL(nTipo,dDataI, dData, nMoedaAtf,nTaxaCorr,oModelAcum,nLineAux,nLine01)


Local nDecTax		:= TamSX3("N3_VORIG1")[2]
Local aTxVaria		
Local aValBol		:= {}
Local bContador 

Private aTaxas
Private nParCorrec	:= 0
Private nValCorr	:= 0
Private nValCorDep	:= 0

Default nTaxaCorr := 1
Default ntipo := 0
Default dDataI := dDatabase
Default dData  := dDatabase
Default nMoedaAtf := 1
Default oModelAcum := Nil
Default nLineAux := 0
Default nLine01 := 0



IF nTipo = 1
	aTaxas	:= GetTaxas( bContador, .T.)
	aTxVaria := TxVariacao( dDataI, dData, nMoedaAtf, .F. )
	nTaxaCorr := aTxVaria[nMoedaAtf] 
	nParCorrec := nTaxaCorr 
	nValCorr   := Round(Abs((SN3->N3_VORIG1 + SN3->N3_VRCACM1 + SN3->N3_AMPLIA1)*nTaxaCorr),nDecTax)  - ;
						Abs(SN3->N3_VRCACM1+SN3->N3_VORIG1+SN3->N3_AMPLIA1) 
	nValCorDep := Round(Abs(SN3->N3_VRDACM1+SN3->N3_VRCDA1+oModelAcum:GetValue("VLRDEP",1) )*nTaxaCorr,nDecTax) - ;
						Abs(SN3->N3_VRDACM1+SN3->N3_VRCDA1+oModelAcum:GetValue("VLRDEP",1) ) 
	
	If 	Empty(SN3->N3_CCORREC)
		nValCorr:=0
	EndIf
	
	If Empty(SN3->N3_CDESP)
		nValCorDep:=0
	EndIf
		
	aAdd(aValBol,{nTaxaCorr,nValCorr,nValCorDep})
EndIf

IF nTipo = 2
	nValCorr   := Round(Abs((SN3->N3_VRCACM1 + SN3->N3_VORIG1 + SN3->N3_AMPLIA1) * nTaxaCorr),nDecTax) - ;
						Abs(SN3->N3_VRCACM1 + SN3->N3_VORIG1 + SN3->N3_AMPLIA1)
	IF oModelAcum:GetValue("PERCBAIX",nLineAux) <> 0 
		nValCorr   := nValCorr * (oModelAcum:GetValue("PERCBAIX",nLineAux)/100) 
	EndIf
	nValCorDep := Round(( SN3->N3_VRDACM1 + SN3->N3_VRCDA1 + oModelAcum:GetValue("VLRDEP",nLine01) ) * nTaxaCorr ,nDecTax) - ;
	(SN3->N3_VRDACM1 + SN3->N3_VRCDA1 + oModelAcum:GetValue("VLRDEP",nLine01) )
	IF oModelAcum:GetValue("PERCBAIX",nLineAux) <> 0 
		nValCorDep := nValCorDep * (oModelAcum:GetValue("PERCBAIX",nLineAux)/100) 
	EndIf
	nValCorDep := Round(nValCorDep, X3Decimal("N3_VRCDA1" ))
	
	If 	Empty(SN3->N3_CCORREC)
		nValCorr:=0
	EndIf
	If Empty(SN3->N3_CDESP)
		nValCorDep:=0
	EndIf
	
	aAdd(aValBol,{nValCorr,nValCorDep})
EndIF

Return aValBol


Static Function TxVariacao( dDataI, dDataF, cMoedaAtf, la30Embra )

	Local lResult		:= .T.
	Local nMoeda		:= 0
	Local nDtLimite		:= 0
	Local nDtInicial	:= 0
	// *******************************
	// Controle de multiplas moedas  *
	// *******************************
	Local __nQuantas	:= AtfMoedas()
	Local aGetTx		:= Array( __nQuantas )

	If lResult
		aGetTX[ 1 ]	:= 1
		If dDataI ==  FirstDay( dDataI )
			dDataI := dDataI - 1
		Endif
		nDtInicial	:= Ascan( aTaxas, {|e| e[ 1 ] == dDataI } )
		nDtLimite	:= Ascan( aTaxas, {|e| e[ 1 ] == dDataF } )

		For nMoeda := 2 To __nQuantas
			If ( nDtLimite > 0 ) .and. ( nDtInicial > 0 )
				aGetTX[ nMoeda ] := ( aTaxas[ nDtLimite ][ nMoeda ] / aTaxas[ nDtInicial ][ nMoeda ] )
			Else
				aGetTX[ nMoeda ] := 0
			Endif
		Next

		If la30Embra
			aGetTX[ Val(cMoedaAtf) ] := ExecBlock("A30EMBRA",.F.,.F.)
		EndIf
	EndIf

Return ( aGetTX )

//-------------------------------------------------------------------
/*/{Protheus.doc} ATFA150

Rotina de Ampliação de Bem - BOLIVIA.

@author marivaldo
@since 25/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------

Function AT150TBOL  (cBase,cItem)

Local lPermit:= .T.  
	
	If !(DbSeek(XFilial("SN3")+cBase+cItem+"01"))
		lPermit:= .F.	
	Endif
	
	If !lPermit .And. (DbSeek(XFilial("SN3")+cBase+cItem+"10"))
		lPermit:= .T.
	EndIf
	
	If !lPermit	
		Help(" ",1,"AF150AMP",,STR0176,1,0) //"Opção disponível somente para bens com tipo de depreciação fiscal."
		Return
	Endif

Return ()


//-------------------------------------------------------------------
/*/{Protheus.doc} ATFA150

Rotina de Ampliação de Bem - BOLIVIA.

@author marivaldo
@since 25/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------

Function AT150VLBOL (nValorNovo)

Local nPercAc :=  1 + (GetNewPar("MV_PERCAMP",20) / 100)
local lPermit := .T.

If nValorNovo < ((SN3->N3_VORIG1+SN3->N3_VRCACM1+SN3->N3_AMPLIA1) * nPercAc)
	MsgAlert(OemToAnsi(STR0177) + Alltrim(Str(GetMv("MV_PERCAMP")))+OemToAnsi(STR0178))
	lPermit:= .F.
Endif

Return (lPermit)
//-------------------------------------------------------------------
/*/{Protheus.doc} ATFXVLD

Validacion tipo depreciacion - BOLIVIA.

@author Alejandro Parrales
@since 21/04/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function fvldTipAct (aConfig)
	Default aConfig := {}
	//				|Tipo Ativo 				|Tipo Saldo	|Metodo Depreciacao
	aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|5|7"	})
	aAdd(aConfig,	{"09|08"					,"1|"		,"1|"		})
	
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ATF036

Verifica el tipo "5 - Horas trabajadas" - BOLIVIA.

@author Adian Perez Hernandez
@since 11/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function ATFBOLHOR(cTipo,nTasa)

Local lRet:= .F.

	If (cPaisLoc=="BOL" .and. cTipo =="5" .and. nTasa>0)
		lRet:= .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ATF036

Verifica el tipo "5 - Horas trabajadas" - BOLIVIA, Y EL PARAMETRO MV_ATFDPBX  cuando es del tipo 5
no se debe tomar en cuetna el parametro

@author Adian Perez Hernandez
@since 11/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function ATFBOLHM(cTipo,cPATFDPBX  )

Local lRet:= .T.

	If (cPaisLoc=="BOL" .and. cTipo =="5" .and. cPATFDPBX=='1')
		lRet:= .F.
	EndIf

Return lRet

/*/{Protheus.doc} 
	(verifica los movimientos de apuntes horas o si ya fue realizada alguna depreciacion)
	@author Adian Perez Hernandez
	@since 18/05/2021
	@version 1.0
	/*/
Function MOVSBOLN3(cBase,cItem,cTipoDer,cFecha)
Local  dUltDepr		:= GetMv("MV_ULTDEPR")
Local  cCalcDep			:= GetNewPar("MV_CALCDEP",'0') // '0'-Mensal, '1'-Anual
Local  dDataBx :=  STOD(cFecha)
Local  lAuxRet := .F.
Local  lHorRet := .F.
Local  nAux :=0
Local  nAuxHr :=0
Local  lRet:=.F.
Local aRetorno:={}

If cPaisLoc=="BOL"
	If cCalcDep == "0"
				
		If (dDataBx > LastDay(dUltDepr+1)) .Or. ( (CMONTH(dDataBx) +  STR(YEAR( dDataBx ) )) == (CMONTH(dUltDepr+1) +  STR(YEAR( dUltDepr+1) ))     )
			lAuxRet := .T.
		EndIf
	Else
		If Year(dDataBx) >  Year(dUltDepr)+1
			lAuxRet := .T.
		EndIf
	EndIf
	//	//Help(" ",1,"AFDTBAIXA")

	dbSelectArea("SN3")
	aAreaSN3 := SN3->(GetArea())
	dbSetOrder(1)		//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
	dbGoTop()

		If SN3->(MsSeek(xFilial("SN3")+cBase+cItem))

			While SN3->(!EoF()) .and. (SN3->N3_FILIAL == xFilial("SN3")) .And. (SN3->N3_CBASE == cBase) .And. (SN3->N3_ITEM == cItem)
				
					If lAuxRet .and. !Empty(SN3->N3_DTBAIXA) .and. ( (CMONTH(SN3->N3_DTBAIXA) +  STR(YEAR( SN3->N3_DTBAIXA ) )) == (CMONTH(dUltDepr+1) +  STR(YEAR( dUltDepr+1) ))     )
						nAux++
					EndIf
		
			SN3->(dbSkip())
			ENDDO

			

		EndIf
	RestArea(aAreaSN3)

	dbSelectArea("FNA")
	aAreaFNA := FNA->(GetArea())
	dbSetOrder(2)		//FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)
	dbGoTop()

		If FNA->(MsSeek( xFilial("FNA") + cBase+cItem))

			While FNA->(!EoF()) .and. (FNA->FNA_FILIAL == xFilial("SN3")) .And. (FNA->FNA_CBASE == cBase) .And. (FNA->FNA_ITEM == cItem)
				If lAuxRet .and. (FNA_QUANTD>0) .and. ( (CMONTH(FNA_DATA) +  STR(YEAR(FNA_DATA ) )) == (CMONTH(dUltDepr+1) +  STR(YEAR( dUltDepr+1) ))     )
					nAuxHr ++
				EndIf

			FNA->(dbSkip())
			ENDDO

		

		EndIf
		RestArea(aAreaSN3)



	IF nAux>0 .and. cTipoDer=='5'
		lRet := .T.  // existen bajas
	EndIf

	IF nAuxHr>0 .and. cTipoDer=='5'
			lHorRet := .T.  //existen horas
	EndIf

EndIf

	aRetorno={lRet,lHorRet}

Return aRetorno

/*/{Protheus.doc} 
	(una vez que obtien los movimientos de depreciacion y horas la funcion valida si no hay apuntes de horas en el periodo
	para enviar un alert
	@author Adian Perez Hernandez
	@since 18/05/2021
	@version 1.0
	/*/

Function MOVBOLHD(cBase,cItem,cFecha)

	Local  lRet:= .T.
	Local  dUltDepr	:= GetMv("MV_ULTDEPR")
	Local  cCalcDep	:= GetNewPar("MV_CALCDEP",'0') // '0'-Mensal, '1'-Anual
	Local  dDataBx :=  STOD(cFecha)
	Local  lAuxRet := .F.
	Local  lHorRet := .F.
	Local  lBajRet := .F.
	Local  nAux :=0
	Local  nAuxHr :=0
	Local  lN3TDEP5 := .F.

	DEFAULT cBase := ""
	DEFAULT cItem := ""
	DEFAULT cFecha := ""

	If cCalcDep == "0"	
		If (dDataBx > LastDay(dUltDepr+1)) .Or. ( (CMONTH(dDataBx) +  STR(YEAR( dDataBx ) )) == (CMONTH(dUltDepr+1) +  STR(YEAR( dUltDepr+1) ))     )
			lAuxRet := .T.
		EndIf
	Else
		If Year(dDataBx) >  Year(dUltDepr)+1
			lAuxRet := .T.
		EndIf
	EndIf

	dbSelectArea("SN3")
	aAreaSN3 := SN3->(GetArea())
	dbSetOrder(1)		//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
	dbGoTop()
	If SN3->(MsSeek(xFilial("SN3")+cBase+cItem))
		While SN3->(!EoF()) .and. (SN3->N3_FILIAL == xFilial("SN3")) .And. (SN3->N3_CBASE == cBase) .And. (SN3->N3_ITEM == cItem)
			If SN3->N3_TPDEPR == "5"
				lN3TDEP5 := .T.
				If lAuxRet .and. !Empty(SN3->N3_DTBAIXA) .and. ( (CMONTH(SN3->N3_DTBAIXA) +  STR(YEAR( SN3->N3_DTBAIXA ) )) == (CMONTH(dUltDepr+1) +  STR(YEAR( dUltDepr+1) ))     )
					nAux++
				EndIf
			EndIf
			SN3->(dbSkip())
		EndDo
	EndIf
	RestArea(aAreaSN3)

	dbSelectArea("FNA")
	aAreaFNA := FNA->(GetArea())
	dbSetOrder(2)		//FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)
	dbGoTop()
	If FNA->(MsSeek( xFilial("FNA") + cBase+cItem))
		While FNA->(!EoF()) .and. (FNA->FNA_FILIAL == xFilial("SN3")) .And. (FNA->FNA_CBASE == cBase) .And. (FNA->FNA_ITEM == cItem)
			If lAuxRet .and. (FNA_QUANTD>0) .and. ( (CMONTH(FNA_DATA) +  STR(YEAR(FNA_DATA ) )) == (CMONTH(dUltDepr+1) +  STR(YEAR( dUltDepr+1) ))     )
				nAuxHr ++
			EndIf
			FNA->(dbSkip())
		EndDo
	EndIf
	RestArea(aAreaFNA)
	If lN3TDEP5
		If nAux > 0
			lBajRet := .T.  // existen bajas
		EndIf
		If nAuxHr > 0
			lHorRet := .T.  //existen horas
		EndIf
		If  lBajRet // existe depreciacion en el periodo
			lRet := .F.
		EndIf
		If  !lHorRet // no hay apuntes
			lRet := .F.
		EndIf
		If !lRet
			MsgAlert(OemToAnsi(STR0179)) //Sin apunte de produccion para el periodo
		EndIF
	EndIf
return lRet
