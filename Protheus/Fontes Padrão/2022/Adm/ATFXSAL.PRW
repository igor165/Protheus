#INCLUDE "ATFXSAL.CH"
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "DBINFO.CH"

#DEFINE POS_VLR_ORGINIAL			1
#DEFINE POS_AMPLIACAO				2
#DEFINE POS_DEPR_FISCAL			3
#DEFINE POS_DEPR_INCENTIVADA		4
#DEFINE POS_DEPR_GERENCIAL		5
#DEFINE POS_CORREC_BEM			6
#DEFINE POS_CORREC_DEPR			7
#DEFINE POS_BAIXAS				8
#DEFINE POS_QUANTD				9
#DEFINE POS_VENDA				10
#DEFINE POS_RED_VL_REC			11


STATIC __lCusto
STATIC __lItem
STATIC __lClVL
STATIC __lCpoSaldo
STATIC __lTabSld
STATIC __lPROVCTR 
STATIC _cNomePr1
STATIC _cNomePr2
STATIC _oATFXSAL
STATIC _aDecimal := {}
STATIC _cQryAtfX := ""
STATIC cAtftioa	 := SuperGetMV("MV_ATFTIOA")
STATIC lAtfr072  := IsIncallStack("ATFR072") .or. FunName() == "ATFR072_ROBO"
STATIC _lAtfr073  := IsIncallStack("ATFR073") .or. FunName() == "ATFR073"
STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ATFXSLDCTB ³ Autor ³ TOTVS SA            ³ Data ³ 10/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza‡„o de saldos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1,ExpD1,ExpC2,ExpN1,ExpN2,ExpN3,ExpN4,ExpN5,ExpC2      ³±±
±±³          ³ aVlMoed=Vetor com valor de todas as moedas(multiplas Moedas)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Tipos de contas:
"1" - Conta do Bem
"2" - Conta de Correção do Bem
"3" - Conta de Despesa Depreciação
"4" - Conta de Depreciação Acumulada
"5" - Conta de Correção da Depreciação Acumulada
"6" - Conta de Correção da Conta de Capital Social
*/

Function ATFXSLDCTB(	cConta,dData,cTipo,nValor1,nValor2,nValor3,nValor4,nValor5,;
cSinal,nTaxa,cSubConta,cFil,cClvl,cCusto, cTipoCnt, aVlMoed,cTipoSld,cMotivo,cTipBem,cCustProv, cOcorr)

Local cAlias  		:= ALIAS()
Local cFilOld 		:= cFilAnt
Local cTipoAux		:= ""
Local nX,nTotMoeda
Local lDelSN5	:= .T.
Local lDelSNC	:= .T.
Local lDelSN6	:= .T.
Local lDelSNA	:= .T.

Local aValor 	:= If(Valtype(aVlMoed)="A",aClone(aVlMoed),nil)

//********************************
// Controle de multiplas moedas  *
//********************************
Local __nQuantas := AtfMoedas()
Local cQuery     := ""
Local cTbl       := SN4->(GetNextAlias())
Local lExecSld   := .T.
Local aParQry    := {}

DEFAULT cCusto 		:= Space(TamSxg("004")[1])
DEFAULT cSubConta 	:= Space(TamSxg("005")[1])
DEFAULT cClVl       := Space(TamSxg("006")[1])
DEFAULT cTipoCnt	:= ""
DEFAULT cTipoSld	:= ""
DEFAULT cMotivo		:= ""
DEFAULT cTipBem		:= ""
DEFAULT cCustProv	:= ""
DEFAULT cOcorr		:= ""

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para tipo de Saldo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
If __lTabSld == Nil
	__lTabSld := .T.
EndIf

If __lTabSld
	cTipoSld := IIF( Empty(cTipoSld), SN3->N3_TPSALDO , cTipoSld )
	cTipBem  := IIF( Empty(cTipBem ), SN3->N3_TIPO    , cTipBem  )
Else
	cTipoSld := ''
	cTipBem  := ''
EndIf

// Tratamento para ativos com a classificação de ativos de custo/provisão
If __lPROVCTR == Nil
	__lPROVCTR := AFXAtCsPrv()
EndIf

// Se o N3 esta classificado como ativo de custo/provisao, a movimentação não entrará para o saldo
If __lPROVCTR 
	cCustProv := IIF( !Empty(cCustProv) , cCustProv , SN3->N3_ATFCPR)
	If Alltrim(cCustProv) == '1'
		Return Nil
	EndIf
EndIf


//********************************************
// Tratamento de incompatibilidade de Fontes *
//********************************************
If Valtype(aValor)<>"A"
	aValor	:= AtfMultMoe(,,{|x| 0})
	aValor[1]:= nValor1
	aValor[2]:= nValor2
	aValor[3]:= nValor3
	aValor[4]:= nValor4
	aValor[5]:= nValor5
EndIf

nTaxa	:= Iif(nTaxa = Nil, 0, nTaxa)

If __lCusto = Nil
	__lCusto  := CtbMovSaldo("CTT")
	__lItem	  := CtbMovSaldo("CTD")
	__lCLVL	  := CtbMovSaldo("CTH")
Endif

Set( _SET_DECIMALS ,4 )

If ValType( nTaxa ) # "N"
	nTaxa := 0
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite o tratamento para trocar uma determinada conta                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("ATFCONTA")
	cConta := Execblock("ATFCONTA",.f.,.f.,{cConta,dData,cTipo,aValor[1],aValor[2],aValor[3],aValor[4],aValor[5],cSinal,nTaxa,cSubConta,cFil,cClvl,cCusto,aValor})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite o tratamento para trocar uma determinada conta                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("ATFSINAL")
	cSinal := Execblock("ATFSINAL",.f.,.f.,{cConta,dData,cTipo,aValor[1],aValor[2],aValor[3],aValor[4],aValor[5],cSinal,nTaxa,cSubConta,cFil,cClvl,cCusto,cTipoCnt, FunName(), aValor })
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite o tratamento para trocar uma determinada conta                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("ATFTIPO")
	cTipoAux := Execblock("ATFTIPO",.f.,.f.,{cConta,dData,cTipo,aValor[1],aValor[2],aValor[3],aValor[4],aValor[5],cSinal,nTaxa,cSubConta,cFil,cClvl,cCusto,cTipoCnt,FunName(),aValor})
Endif

dbSelectArea("SN5" )
dbSetOrder ( 1 )
cFil := Iif(cFil == NIL, xFilial(), cFil)

//********************************
// Controle de multiplas moedas  *
//********************************

If Len(_aDecimal)==0
	For nX := 1 to __nQuantas
		aAdd(_aDecimal, X3Decimal("N5_VALOR" + Alltrim(Str(nX))))	
	Next nX
EndIf

nTotMoeda := 0
For nX := 1 to __nQuantas	
	aValor[nX] := Round(aValor[nX],_aDecimal[nX])
	nTotMoeda	+= aValor[nX]
Next

IF (nTotMoeda) == 0 .or. Empty(cConta) .or. Empty(dData)
	Return Nil
EndIF

/*/ 1 - Motivo de baixa 18 - Transferencia Interna de Filial não altera os saldos contabeis da conta 
    pois a transferencia já diminui o saldo*/
IF FWIsInCallStack("ATFA120")  //refaz saldo

	If ( cOcorr == '01' .And. cTipBem == "01" .And. cTipoCnt $ "3|4" )
		
		If _cQryAtfX == ""

			cQuery := " SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("SN4")
			cQuery += "  Where D_E_L_E_T_ = ' ' "
			cQuery += "    AND N4_FILIAL  = ? " 
			cQuery += "    AND N4_DATA    = ? "
			cQuery += "    AND N4_CONTA   = ? "
			cQuery += "    AND N4_SUBCTA  = ? "
			cQuery += "    AND N4_OCORR   = '01' "
			cQuery += "    AND N4_TIPO    = ? "
			cQuery += "    AND N4_TIPOCNT = ? "
			cQuery += "    AND N4_MOTIVO  = ? " 
						
			_cQryAtfX := ChangeQuery(cQuery)
		
		EndIf

		aadd(aParQry, cFil )        	// P1 Filial
		aadd(aParQry, DTOS(dData) ) 	// P2 Data Movim.
		aadd(aParQry, cConta )      	// P3 Conta
		aadd(aParQry, cSubConta )   	// P4 Item da Conta
		aadd(aParQry, cTipBem )			// P5 Tipo ativo

		If Alltrim(cMotivo) == "18"     //18 - Transferência
			aadd(aParQry, cTipoCnt )	// P6 Tipo da Conta
			aadd(aParQry, cMotivo )		// P7 Motivo Movim.
		ElseIf Alltrim(cMotivo) == "06" //06 - Baixa
			aadd(aParQry, "3" )	// P6 Tipo da Conta
			aadd(aParQry, cMotivo )		// P7 Motivo Movim.
		EndIf	
		
		dbUseArea(.T.,"TOPCONN",TcGenQry2(,,_cQryAtfX, aParQry),cTbl,.T.,.T.)

		If (cTbl)->(RECNO) > 0
			lExecSld := .F.
		Endif
		
		If Select(cTbl) > 0
			DbSelectArea(cTbl)
			DbCloseArea()
		EndIf
	EndIf

	IF (Alltrim(cMotivo) == "18" .And. ((cTipo == "5" .And. cTipoCnt== "3") .OR. (cTipo == "8" .And. cTipoCnt== "3"))) .or. !lExecSld //ignorar saldo de transferencia quando saldo inicial. 
		Return Nil
	EndIF
EndIf

//Motivo de baixa 18 - Transferencia Interna de Filial não altera os saldos contabeis da conta pois a transferencia já diminui o saldo
IF Alltrim(cMotivo) == "18" .And. ( (cTipo == "5" .And. cTipoCnt== "4" ) .OR. ! ( cTipoCnt $ "3|4" ) )
	Return Nil
EndIF

If !Empty(cConta)
	//************************************
	// LocByName para atualizacao do SN5 *
	//************************************
	While !LockByName("SN5"+cFil+cConta+Dtos(dData)+cTipo+cTipBem+cTipoSld,.T.,.T.,.T.)
		Sleep(1)
	EndDo
	DbSelectArea("SN5")
	dbSeek( cFil+cConta+Dtos(dData)+cTipo+cTipBem+cTipoSld)
	If !Found()
		Reclock("SN5",.T.)
			SN5->N5_FILIAL := cFil
			SN5->N5_CONTA  := cConta
			SN5->N5_DATA   := dData
			SN5->N5_TIPO   := cTipo
			If __lTabSld
				SN5->N5_TPSALDO   := cTipoSld
				SN5->N5_TPBEM     := cTipBem
			EndIf
	Else
		Reclock("SN5")
	EndIf
	
	SN5->N5_TAXA := nTaxa
	
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	For nX := 1 to __nQuantas
		IF cSinal == "+"
			SN5->(FieldPut(FieldPos("N5_VALOR" + Alltrim(Str(nX)) ) , FieldGet(FieldPos("N5_VALOR" + Alltrim(Str(nX)) )) + aValor[nX] ))
		Else
			SN5->(FieldPut(FieldPos("N5_VALOR" + Alltrim(Str(nX)) ) , FieldGet(FieldPos("N5_VALOR" + Alltrim(Str(nX)) )) - aValor[nX] ))
		EndIf
	Next
	
	If ExistBlock("ATFGRSLD")
		Execblock("ATFGRSLD",.f.,.f.,{cTipoAux, cSinal,"SN5"})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso as contas sejam zeradas, ser„o autom ticamente deletadas             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	For nX := 1 to __nQuantas
		If SN5->(FieldGet(FieldPos("N5_VALOR" + Alltrim(Str(nX)) )))<>0
			lDelSN5	:= .F.
			Exit
		EndIf
	Next
	IF lDelSN5
		Reclock("SN5" ,.F.,.T.)
		dbDelete()
	EndIf
	SN5->(msUnlock())
	FKCOMMIT()
	//**************************************
	// UnLocByName para liberaracao do SN5 *
	//**************************************
	UnLockByName("SN5"+cFil+cConta+Dtos(dData)+cTipo+cTipBem+cTipoSld,.T.,.T.,.T.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o Centro de Custo estiver preenchido atualizo saldos no SNC    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If __lCusto .And. !Empty(cCusto)
	dbSelectArea("SNC" )
	dbSetOrder ( 1 )
	cFil := Iif(cFil == NIL, xFilial(), cFil)
	
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	For nX := 1 to __nQuantas
		aValor[nX] := Round(aValor[nX],X3Decimal("NC_VALOR" + Alltrim(Str(nX))))
	Next
	
	dbSetOrder ( 1 )
	//************************************
	// LocByName para atualizacao do SNC *
	//************************************
	While !LockByName("SNC"+cFil+cConta+cCusto+Dtos(dData)+cTipo+cTipBem+cTipoSld,.T.,.T.,.T.)
		Sleep(1)
	EndDo
	dbSeek( cFil+cConta+cCusto+Dtos(dData)+cTipo+cTipBem+cTipoSld )
	If !Found()
		Reclock("SNC",.T.)
		SNC->NC_FILIAL := cFil
		SNC->NC_CONTA  := cConta
		SNC->NC_CCUSTO := cCusto
		SNC->NC_DATA   := dData
		SNC->NC_TIPO   := cTipo
		If __lTabSld
			SNC->NC_TPSALDO   := cTipoSld
			SNC->NC_TPBEM     := cTipBem
		EndIf
	Else
		Reclock("SNC",.F.)
	EndIf
	
	SNC->NC_TAXA := nTaxa
	
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	For nX := 1 to __nQuantas
		IF cSinal == "+"
			SNC->(FieldPut(FieldPos("NC_VALOR" + Alltrim(Str(nX)) ) , FieldGet(FieldPos("NC_VALOR" + Alltrim(Str(nX)) )) + aValor[nX] ))
		Else
			SNC->(FieldPut(FieldPos("NC_VALOR" + Alltrim(Str(nX)) ) , FieldGet(FieldPos("NC_VALOR" + Alltrim(Str(nX)) )) - aValor[nX] ))
		EndIf
	Next
	
	If ExistBlock("ATFGRSLD")
		Execblock("ATFGRSLD",.f.,.f.,{cTipoAux, cSinal, "SNC"})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso as contas sejam zeradas, ser„o autom ticamente deletadas             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	For nX := 1 to __nQuantas
		If SNC->(FieldGet(FieldPos("NC_VALOR" + Alltrim(Str(nX)) )))<>0
			lDelSNC	:= .F.
			Exit
		EndIf
	Next
	IF lDelSNC
		Reclock("SNC" ,.F.,.T.)
		dbDelete()
	EndIf
	MsUnlock()
	FKCOMMIT()
	//**************************************
	// UnLocByName para liberaracao do SNC *
	//**************************************
	UnLockByName("SNC"+cFil+cConta+cCusto+Dtos(dData)+cTipo+cTipBem+cTipoSld,.T.,.T.,.T.)
	
	dbSelectArea("SNC")
	dbSetOrder(1)
	dbSeek(cFilOld)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso as subContas estejam preenchidas atualizo saldos no SN6        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If __lItem .And. !Empty(cSubConta)
	dbSelectArea("SN6" )
	dbSetOrder ( 1 )
	cFil := Iif(cFil == NIL, xFilial(), cFil)
	
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	For nX := 1 to __nQuantas
		aValor[nX] := Round(aValor[nX],X3Decimal("N6_VALOR" + Alltrim(Str(nX))))
	Next
	
	dbSetOrder ( 1 )
	//************************************
	// LocByName para atualizacao do SN6 *
	//************************************
	While !LockByName("SN6"+cFil+cConta+cCusto+cSubConta+Dtos(dData)+cTipo+cTipBem+cTipoSld,.T.,.T.,.T.)
		Sleep(1)
	EndDo
	dbSeek( cFil+cConta+cCusto+cSubConta+Dtos(dData)+cTipo+cTipBem+cTipoSld )
	If !Found()
		Reclock("SN6",.T.)
		SN6->N6_FILIAL := cFil
		SN6->N6_CONTA  := cConta
		SN6->N6_CCUSTO := cCusto
		SN6->N6_SUBCTA := cSubConta
		SN6->N6_DATA   := dData
		SN6->N6_TIPO   := cTipo
		If __lTabSld
			SN6->N6_TPSALDO   := cTipoSld
			SN6->N6_TPBEM     := cTipBem
		EndIf
	Else
		Reclock("SN6",.F.)
	EndIf
	
	SN6->N6_TAXA := nTaxa
	
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	For nX := 1 to __nQuantas
		IF cSinal == "+"
			SN6->(FieldPut(FieldPos("N6_VALOR" + Alltrim(Str(nX)) ) , FieldGet(FieldPos("N6_VALOR" + Alltrim(Str(nX)) )) + aValor[nX] ))
		Else
			SN6->(FieldPut(FieldPos("N6_VALOR" + Alltrim(Str(nX)) ) , FieldGet(FieldPos("N6_VALOR" + Alltrim(Str(nX)) )) - aValor[nX] ))
		EndIf
	Next
	
	If ExistBlock("ATFGRSLD")
		Execblock("ATFGRSLD",.f.,.f.,{cTipoAux, cSinal,"SN6"})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso as contas sejam zeradas, ser„o autom ticamente deletadas             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	For nX := 1 to __nQuantas
		If SN6->(FieldGet(FieldPos("N6_VALOR" + Alltrim(Str(nX)) )))<>0
			lDelSN6	:= .F.
			Exit
		EndIf
	Next
	IF lDelSN6
		Reclock("SN6" ,.F.,.T.)
		dbDelete()
	EndIf
	MsUnlock()
	FKCOMMIT()
	//**************************************
	// UnLocByName para liberaracao do SN6 *
	//**************************************
	UnLockByName("SN6"+cFil+cConta+cCusto+cSubConta+Dtos(dData)+cTipo+cTipBem+cTipoSld,.T.,.T.,.T.)
	
	dbSelectArea("SN6")
	dbSetOrder(1)
	dbSeek(cFilOld)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso as Cl Vlrs   estejam preenchidas atualizo saldos no SNA        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If __lCLVL .And. !Empty(cClvl)
	dbSelectArea("SNA")
	dbSetOrder(1)
	cFil := Iif(cFil == NIL, xFilial(), cFil)
	
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	For nX := 1 to __nQuantas
		aValor[nX] := Round(aValor[nX],X3Decimal("NA_VALOR" + Alltrim(Str(nX))))
	Next
	
	dbSetOrder (1)
	//************************************
	// LocByName para atualizacao do SNA *
	//************************************
	While !LockByName("SNA"+cFil+cConta+cCusto+cSubConta+cClvl+Dtos(dData)+cTipo+cTipBem+cTipoSld,.T.,.T.,.T.)
		Sleep(1)
	EndDo
	dbSeek(cFil+cConta+cCusto+cSubConta+cClvl+Dtos(dData)+cTipo+cTipBem+cTipoSld)
	If !Found()
		Reclock("SNA",.T.)
		SNA->NA_FILIAL := cFil
		SNA->NA_CONTA  := cConta
		SNA->NA_CCUSTO := cCusto
		SNA->NA_SUBCTA := cSubConta
		SNA->NA_CLVL   := cClvl
		SNA->NA_DATA   := dData
		SNA->NA_TIPO   := cTipo
		If __lTabSld
			SNA->NA_TPSALDO   := cTipoSld
			SNA->NA_TPBEM     := cTipBem
		EndIf
	Else
		Reclock("SNA",.F.)
	EndIf
	
	SNA->NA_TAXA := nTaxa
	
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	For nX := 1 to __nQuantas
		IF cSinal == "+"
			SNA->(FieldPut(FieldPos("NA_VALOR" + Alltrim(Str(nX)) ) , FieldGet(FieldPos("NA_VALOR" + Alltrim(Str(nX)) )) + aValor[nX] ))
		Else
			SNA->(FieldPut(FieldPos("NA_VALOR" + Alltrim(Str(nX)) ) , FieldGet(FieldPos("NA_VALOR" + Alltrim(Str(nX)) )) - aValor[nX] ))
		EndIf
	Next
	
	If ExistBlock("ATFGRSLD")
		Execblock("ATFGRSLD",.f.,.f.,{cTipoAux, cSinal,"SNA"})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso as contas sejam zeradas, ser„o autom ticamente deletadas             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	For nX := 1 to __nQuantas
		If SNA->(FieldGet(FieldPos("NA_VALOR" + Alltrim(Str(nX)) )))<>0
			lDelSNA	:= .F.
			Exit
		EndIf
	Next
	IF lDelSNA
		Reclock("SNA" ,.F.,.T.)
		dbDelete()
	EndIf
	MsUnlock()
	FKCOMMIT()
	//**************************************
	// UnLocByName para liberaracao do SNA *
	//**************************************
	UnLockByName("SNA"+cFil+cConta+cCusto+cSubConta+cClvl+Dtos(dData)+cTipo+cTipBem+cTipoSld,.T.,.T.,.T.)
	
	dbSelectArea("SNA")
	dbSetOrder(1)
	dbSeek(cFilOld)
Endif

dbSelectArea("SN5")
dbSetOrder(1)
dbSeek(cFilOld)

dbSelectArea ( cAlias )
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFGERSLDMºAutor  ³Alvaro Camillo Neto º Data ³  20/09/10            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera aquivo temporário com informações do saldo do bem               º±±
±±º          ³por moeda na data                                           		   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 01-oMeter     = Controle da regua                                   ³±±
±±³          ³ 02-oText      = Controle da regua                                   ³±±
±±³          ³ 03-oDlg       = Janela                                              ³±±
±±³          ³ 04-lEnd       = Controle da regua -> finalizar                      ³±±
±±³          ³ 05-cArqtmp    = Arquivo temporario                                  ³±±
±±³          ³ 06-dAquIni    = Data Inicial de Aquisição de Bens                   ³±±
±±³          ³ 07-dAquFim    = Data Final de Aquisição de Bens                     ³±±
±±³          ³ 08-dDataSLD   = Data do saldo dos bem                               ³±±
±±³          ³ 09-cBemIni    = Codigo de Bem Inicial                               ³±±
±±³          ³ 10-cBemFim    = Codigo de Bem Final                                 ³±±
±±³          ³ 11-cItemIni	 = Item do Bem Inicial                                 ³±±
±±³          ³ 12-cItemFim   = Item do Bem Final                                   ³±±
±±³          ³ 13-cContaIni  = Conta do Bem Inicial (N3_CCONTAB)                   ³±±
±±³          ³ 14-cContaFim  = Conta do Bem Final   (N3_CCONTAB)                   ³±±
±±³          ³ 15-cCCIni     = Centro de Custo Inicial (N3_CUSTBEM)                ³±±
±±³          ³ 16-cCCFim     = Centro de Custo Final   (N3_CUSTBEM)                ³±±
±±³          ³ 17-cItCtbIni  = Item Contabil Inicial(N3_SUBCCON)                   ³±±
±±³          ³ 18-cItCtbFim  = Item Contabil Final  (N3_SUBCCON)                   ³±±
±±³          ³ 19-cClvlIni   = Classe de Valor Inicial (N3_CLVLCON)                ³±±
±±³          ³ 20-cClVlFim   = Classe de Valor Final   (N3_CLVLCON)                ³±±
±±³          ³ 21-cGrupoIni  = Grupo de Bem Inicial                                ³±±
±±³          ³ 22-cGrupoFim  = Grupo de Bem Final                                  ³±±
±±³          ³ 23-aMoeda     = Array de Moedas                                     ³±±
±±³          ³ 24-aSelFil    = Array de Filiais                                    ³±±
±±³          ³ 25-lTodasFil  = Se mostra todas as Filiais                          ³±±
±±³          ³ 26-cChave     = Chave de indexação do arquivo temporario            ³±±
±±³          ³ 27-lAgrupa    = Se agrupa as sequencias do bem (N3_SEQ e N3_SEQREAV)³±±
±±³          ³ 28-aTipos     = Permite a seleção dos tipos de bem                  ³±±
±±³          ³ 29-cFilter    = Permite a insercao de um novo filtro na query       ³±±
±±³          ³ 30-cBaixa     = Opção de filtro de Baixa:                           ³±±
±±³          ³            1  = Somente Ativos                                      ³±±
±±³          ³            2  = Somente Baixados                                    ³±±
±±³          ³            3  = Ambos        									   ³±±
±±³          ³ 31-cSaldoFil  = Tipo de Saldo                                       ³±±
±±³          ³ 32-aClassif   = Array de classificações patrimoniais                ³±±
±±³          ³ 33-lParRlProv = Parâmetro que verifica se os bens de custos de pro  ³±±
±±³          ³ Devem ser filtrados ou não.										   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFGERSLDM(oMeter,oText,oDlg,lEnd,cArqtmp,dAquIni,dAquFim,dDataSLD,cBemIni,cBemFim,cItemIni,cItemFim,cContaIni,cContaFim,;
cCCIni,cCCFim,cItCtbIni,cItCtbFim,cClvlIni,cClVlFim,cGrupoIni,cGrupoFim,aMoeda,aSelFil,lTodasFil,cChave,lAgrupa,aTipos,cFilter,cBaixa,cSaldoFil,;
aClassif,lParRlProv,cTabName)

Local aCampos	  := {}
Local cAliasBem	  := "" // Alias auxiliar dos Bens
Local aValor	  := {}
Local nMoeda	  := 0
Local lDefTop 	  := IfDefTopCTB() // verificar se pode executar query (TOPCONN)
Local cSeq 	   	  := ""
Local cFlagBaix   := "0"
Local cTipoFiscal := ATFXTpBem(1)
Local cTipoGerenc := ATFXTpBem(2)
Local cTipoIncent := ATFXTpBem(3)
Local cSaldo	  := ""
Local aTmpFil	  := {}
Local nX		  
Local lRealProv	  := .F.
Local lProcedure  := .F.
Local cTypesNM	  := IIF(lIsRussia,"/" + AtfNValMod({1,2}, "/"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - main and recoverable models
Local aChave      := {}
Local cCodAnt     := ""

Default oMeter	  := Nil
Default oText     := Nil
Default oDlg      := Nil
Default lEnd      := .F.
Default cArqtmp   := ""
Default dAquIni   := StoD("")
Default dAquFim	  := StoD("20301231")
Default dDataSLD  := GetNewPar("MV_ULTDEPR", STOD("19800101"))
Default cBemIni   := ""
Default cBemFim   := Replicate("Z",TamSX3("N1_CBASE")[1])
Default cItemIni  := ""
Default cItemFim  := Replicate("Z",TamSX3("N1_ITEM")[1])
Default cContaIni := ""
Default cContaFim := Replicate("Z",TamSX3("CT1_CONTA")[1])
Default cCCIni	  := ""
Default cCCFim	  := Replicate("Z",TamSX3("CTT_CUSTO")[1])
Default cItCtbIni := ""
Default cItCtbFim := Replicate("Z",TamSX3("CTD_ITEM")[1])
Default cClvlIni  := ""
Default cClVlFim  := Replicate("Z",TamSX3("CTH_CLVL")[1])
Default cGrupoIni := ""
Default cGrupoFim := Replicate("Z",TamSX3("N1_GRUPO")[1])
Default aMoeda    := {"01"}
Default aSelFil   := {cFilAnt}
Default lTodasFil := .F.
Default cChave    := ""
Default lAgrupa   := .T.
Default aTipos    := {} 
Default aClassif  := {} 
Default cFilter	  := ""
Default cBaixa	  := "1"
Default cSaldoFil := "*"
Default cTabName  := ""

If __lCpoSaldo == Nil
	__lCpoSaldo := SN3->(FieldPos("N3_TPSALDO")) > 0 .AND. SN4->(FieldPos("N4_TPSALDO")) > 0
EndIf

If !lDefTop
	Help("  ",1,"ATFGERTOP",,"Função disponível apenas para ambientes TopConnect" ,1,0) //"Função disponível apenas para ambientes TopConnect"
	Return
EndIf

/*
 * Verificação do campo para ativos de custo de provisão
 */
If Select("SN3") == 0
	DbSelectArea("SN3")	
EndIf

lRealProv := SN3->(FieldPos("N3_ATFCPR")) > 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definição dos campos do arquivo temporário³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqTmp := IIF(Empty(cArqTmp),GetNextAlias(),cArqTmp)

aAdd(aCampos,{"FILIAL"		,"C",TamSX3("N1_FILIAL")[1]		,00	})
aAdd(aCampos,{"CBASE" 		,"C",TamSX3("N1_CBASE")[1]		,00	})
aAdd(aCampos,{"ITEM"  		,"C",TamSX3("N1_ITEM")[1]		,00	})
aAdd(aCampos,{"MOEDA" 		,"C",02					  		,00	})
aAdd(aCampos,{"CLASSIF"		,"C",TamSX3("N1_PATRIM")[1]		,00	})
aAdd(aCampos,{"TIPO"		,"C",TamSX3("N3_TIPO")[1]		,00	})
aAdd(aCampos,{"DESC_SINT"	,"C",TamSX3("N1_DESCRIC")[1]	,00	})
aAdd(aCampos,{"AQUISIC" 	,"D",8 					   		,00	})
aAdd(aCampos,{"DTBAIXA" 	,"D",8 							,00	})
aAdd(aCampos,{"DTSALDO" 	,"D",8 							,00	})
aAdd(aCampos,{"CHAPA"	 	,"C",TamSX3("N1_CHAPA")[1]		,00	})
aAdd(aCampos,{"GRUPO"	 	,"C",TamSX3("N1_GRUPO")[1]		,00	})
aAdd(aCampos,{"CONTA"	 	,"C",TamSX3("CT1_CONTA")[1]		,00	}) // Conta do Bem
aAdd(aCampos,{"CCUSTO"	 	,"C",TamSX3("CTT_CUSTO")[1]		,00	}) // C Custo do Bem
aAdd(aCampos,{"SUBCTA"	 	,"C",TamSX3("CTD_ITEM")[1]		,00	}) // Item Contabil do Bem
aAdd(aCampos,{"CLVL"	 	,"C",TamSX3("CTH_CLVL")[1]		,00	}) // Classe de Valor do Bem
aAdd(aCampos,{"SEQ"	   		,"C",TamSX3("N3_SEQ")[1]		,00	})
aAdd(aCampos,{"SEQREAV"	 	,"C",TamSX3("N3_SEQREAV")[1]	,00	})
aAdd(aCampos,{"FLAGBAIXA" 	,"C",TamSX3("N3_BAIXA")[1]   	,00	})
aAdd(aCampos,{"TPSALDO" 	,"C",1						  	,00	})

aAdd(aCampos,{"QUANTD"	 	,"N",TamSX3("N1_QUANTD")[1]		,TamSX3("N1_QUANTD")[2]	})
aAdd(aCampos,{"ORIGINAL"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"AMPLIACAO"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"ATUALIZ"		,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"DEPRECACM"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"RESIDUAL"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"CORRECACM"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"CORDEPACM"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"VLBAIXAS"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"VLVENDA" 	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"CODIND"		,"C",TamSX3("N3_CODIND")[1]		,00	})

If Empty(cChave)
	cChave := "FILIAL+CBASE+ITEM+TIPO+MOEDA"
EndIf
//procedure a ser utilizado no relatorio ATFR072
lProcedure := FunName() == "ATFR072" .And. CriaProc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a seleção dos Bens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAliasBem := ATFSelBem(cBemIni,cBemFim,cItemIni,cItemFim,dAquIni,dAquFim,cContaIni,cContaFim,cCCIni,cCCFim,cItCtbIni,cItCtbFim,cClvlIni,cClVlFim,cGrupoIni,cGrupoFim,aSelFil,lTodasFil,dDataSLD,lAgrupa,aTipos,cFilter,cBaixa,/*nEntidade*/,cSaldoFil,aTmpFil,aClassif,lRealProv)

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria a tabela temporária no Banco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
If(_oATFXSAL <> NIL)

	_oATFXSAL:Delete()
	_oATFXSAL := NIL

EndIf
_oATFXSAL := FWTemporaryTable():New(cArqtmp)
_oATFXSAL:SetFields(aCampos)

aChave := StrTokArr2(cChave, "+")
aChave := AEval(aChave, {|xV, nI| aChave[nI] := AllTrim(xV)})
_oATFXSAL:AddIndex("1", aChave)

_oATFXSAL:Create()

//Obtem o nome real para as rotinas que precisam executar query sobre a tabela temporaria
cTabName := _oATFXSAL:GetRealName()

While (cAliasBem)->(!EOF())
	If cCodAnt != (cAliasBem)->(N1_FILIAL + N1_CBASE + N1_ITEM + N3_TIPO + N3_TPSALDO)
		cCodAnt := (cAliasBem)->(N1_FILIAL + N1_CBASE + N1_ITEM + N3_TIPO + N3_TPSALDO)
	Else
		If AllTrim((cAliasBem)->N3_TIPO) != '11' //ampliacao
			(cAliasBem)->(dbSkip())
			LOOP
		EndIf
	EndIf

	If __lCpoSaldo
		cSaldo := (cAliasBem)->N3_TPSALDO
	EndIf
	
	If lAgrupa
		aRet			:= ATFMaxSeq((cAliasBem)->N1_FILIAL,(cAliasBem)->N1_CBASE,(cAliasBem)->N1_ITEM,(cAliasBem)->N3_TIPO,(cAliasBem)->N3_SEQREAV,cSaldo,dDataSLD,lProcedure)
		cSeq 	  		:= aRet[1]
		cFlagBaix   := aRet[2]
	EndIF
	
	If !lParRlProv
		If (cAliasBem)->N3_ATFCPR == '1'
			(cAliasBem)->(dbSkip())
			Loop
		EndIf
	EndIf
		
	aValor := SaldoSN4( (cAliasBem)->N1_FILIAL,(cAliasBem)->N1_CBASE,(cAliasBem)->N1_ITEM,(cAliasBem)->N3_TIPO,cSeq,(cAliasBem)->N3_SEQREAV,aMoeda,dDataSLD,lAgrupa,,cSaldo)
	If !Empty(aValor)
		For nMoeda := 1 to Len(aValor)
			RecLock(cArqTmp,.T.)
			(cArqTmp)->FILIAL		:= (cAliasBem)->N1_FILIAL
			(cArqTmp)->CBASE		:= (cAliasBem)->N1_CBASE
			(cArqTmp)->ITEM			:= (cAliasBem)->N1_ITEM
			(cArqTmp)->MOEDA		:= aValor[nMoeda][1]
			(cArqTmp)->CLASSIF		:= (cAliasBem)->N1_PATRIM
			(cArqTmp)->TIPO			:= (cAliasBem)->N3_TIPO
			(cArqTmp)->DESC_SINT	:= (cAliasBem)->N1_DESCRIC
			(cArqTmp)->AQUISIC 		:= (cAliasBem)->N1_AQUISIC
			(cArqTmp)->DTBAIXA 		:= (cAliasBem)->N1_BAIXA
			(cArqTmp)->FLAGBAIXA	:= cFlagBaix
			(cArqTmp)->DTSALDO 		:= dDataSLD
			(cArqTmp)->CHAPA	 	:= (cAliasBem)->N1_CHAPA
			(cArqTmp)->GRUPO	 	:= (cAliasBem)->N1_GRUPO
			(cArqTmp)->CONTA	 	:= (cAliasBem)->CONTA
			(cArqTmp)->CCUSTO	 	:= (cAliasBem)->CCUSTO
			(cArqTmp)->SUBCTA	 	:= (cAliasBem)->SUBCTA
			(cArqTmp)->CLVL	 		:= (cAliasBem)->CLVL
			(cArqTmp)->SEQ	   		:= cSeq
			(cArqTmp)->SEQREAV	 	:= (cAliasBem)->N3_SEQREAV
			(cArqTmp)->ORIGINAL		:= iIF(lAtfr072 .and. (cAliasBem)->N3_TIPO $ cAtftioa  , aValor[nMoeda][2][POS_RED_VL_REC] ,aValor[nMoeda][2][POS_VLR_ORGINIAL]) 
			(cArqTmp)->AMPLIACAO	:= aValor[nMoeda][2][POS_AMPLIACAO]
			(cArqTmp)->VLBAIXAS		:= aValor[nMoeda][2][POS_BAIXAS]
			(cArqTmp)->VLVENDA		:= aValor[nMoeda][2][POS_VENDA]
			
			If __lCpoSaldo
				(cArqTmp)->TPSALDO :=  cSaldo
			EndIf
			
			If (cAliasBem)->N3_TIPO $ cTipoFiscal
				(cArqTmp)->DEPRECACM	:= aValor[nMoeda][2][POS_DEPR_FISCAL]
			ElseIf (cAliasBem)->N3_TIPO $ ("10/12" + cTypesNM) // Tratamento especial para o tipo 10 e 12 para trata o legado ou tratamento especial para tipos localização Russia
				(cArqTmp)->DEPRECACM	:= aValor[nMoeda][2][POS_DEPR_GERENCIAL] + aValor[nMoeda][2][POS_DEPR_FISCAL]
			ElseIf (cAliasBem)->N3_TIPO $ cTipoGerenc
				(cArqTmp)->DEPRECACM	:= aValor[nMoeda][2][POS_DEPR_GERENCIAL]
			ElseIf (cAliasBem)->N3_TIPO $ cTipoIncent
				(cArqTmp)->DEPRECACM	:= aValor[nMoeda][2][POS_DEPR_INCENTIVADA]
			EndIf
			If cPaisLoc $ "ARG|CHI"
				(cArqTmp)->DEPRECACM	+= aValor[nMoeda][2][POS_CORREC_DEPR]
			Endif
			
			(cArqTmp)->CORRECACM	:= aValor[nMoeda][2][POS_CORREC_BEM]
			(cArqTmp)->CORDEPACM	:= aValor[nMoeda][2][POS_CORREC_DEPR]
			(cArqTmp)->QUANTD	 	:= aValor[nMoeda][2][POS_QUANTD]
			If ! ((cAliasBem)->N3_TIPO $ '07/08/09')
				(cArqTmp)->ATUALIZ		:= aValor[nMoeda][2][POS_VLR_ORGINIAL] + (cArqTmp)->AMPLIACAO + (cArqTmp)->CORRECACM - (cArqTmp)->VLBAIXAS 
				(cArqTmp)->RESIDUAL		:= (cArqTmp)->ATUALIZ - (cArqTmp)->DEPRECACM
			Else
				(cArqTmp)->ATUALIZ		:= 0
				(cArqTmp)->RESIDUAL		:= 0
			EndIf
			MsUnLock()
		Next nMoeda
	EndIf
	
	
	(cAliasBem)->(dbSkip())
EndDo

For nX := 1 TO Len(aTmpFil)
	CtbTmpErase(aTmpFil[nX])
Next

//dropa as procedures caso utilizada
If lProcedure
	AtfDropPrc()
EndIf

Return cArqTmp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFGERCOMPºAutor  ³Alvaro Camillo Neto º Data ³  01/04/11            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera aquivo temporário com informações do saldo do bem               º±±
±±º          ³por periodos                                                		   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 01-oMeter      = Controle da regua                                  ³±±
±±³          ³ 02-oText       = Controle da regua                                  ³±±
±±³          ³ 03-oDlg        = Janela                                             ³±±
±±³          ³ 04-lEnd        = Controle da regua -> finalizar                     ³±±
±±³          ³ 05-cArqtmp     = Arquivo temporario                                 ³±±
±±³          ³ 06-dAquIni    = Data Inicial de Aquisição de Bens                   ³±±
±±³          ³ 07-dAquFim    = Data Final de Aquisição de Bens                     ³±±
±±³          ³ 08-aPeriodo      = Array com Períodos                               ³±±
±±³          ³ 09-cBemIni      = Codigo de Bem Inicial                             ³±±
±±³          ³ 10-cBemFim   = Codigo de Bem Final                                  ³±±
±±³          ³ 11-cItemIni	= Item do Bem Inicial                                  ³±±
±±³          ³ 12-cItemFim      = Item do Bem Final                                ³±±
±±³          ³ 13-cContaIni      = Conta do Bem Inicial (N3_CCONTAB)               ³±±
±±³          ³ 14-cContaFim    = Conta do Bem Final   (N3_CCONTAB)                 ³±±
±±³          ³ 15-cCCIni    = Centro de Custo Inicial (N3_CUSTBEM)                 ³±±
±±³          ³ 16-cCCFim    = Centro de Custo Final   (N3_CUSTBEM)                 ³±±
±±³          ³ 17-cItCtbIni    = Item Contabil Inicial(N3_SUBCCON)                 ³±±
±±³          ³ 18-cItCtbFim      = Item Contabil Final  (N3_SUBCCON)               ³±±
±±³          ³ 19-cClvlIni     = Classe de Valor Inicial (N3_CLVLCON)              ³±±
±±³          ³ 20-cClVlFim  = Classe de Valor Final   (N3_CLVLCON)                 ³±±
±±³          ³ 21-cGrupoIni   = Grupo de Bem Inicial                               ³±±
±±³          ³ 22-cGrupoFim     = Grupo de Bem Final                               ³±±
±±³          ³ 23-cMoeda      = Moeda                                              ³±±
±±³          ³ 24-aSelFil     = Array de Filiais                                   ³±±
±±³          ³ 25-lTodasFil     = Se mostra todas as Filiais                       ³±±
±±³          ³ 26-cChave   = Chave de indexação do arquivo temporario              ³±±
±±³          ³ 27-lAgrupa   = Se agrupa as sequencias do bem (N3_SEQ e N3_SEQREAV) ³±±
±±³          ³ 28-aTipos   = Permite a seleção dos tipos de bem                    ³±±
±±³          ³ 29-cFilter   = Permite a insercao de um novo filtro na query         ³±±
±±³          ³ 30-cBaixa   = Opção de filtro de Baixa:                             ³±±
±±³          ³            1  = Somente Ativos                                      ³±±
±±³          ³            2  = Somente Baixados                                    ³±±
±±³          ³            3  = Ambos        								  	   ³±±
±±³          ³ 31-nEntidade   = Opção de Entidades Contábeis do Bem: 	            ³±±
±±³          ³            1  = Entidadedes do Bem                                   ³±±
±±³          ³            2  = Entidades da Deprecicacao Acm                       ³±±
±±³          ³            3  = Entidades da Despesa de Depreciacao				   ³±±
±±³          ³            4  = Entidades da Despesa de Depreciacao				   ³±±
±±³          ³            5  = Entidades da Despesa de Depreciacao				   ³±±
±±³          ³ 32-cSaldoFil   = Tipo do saldo                           	       ³±±
±±³          ³ 33-aClassif   = Array de classificações patrimoniais                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFGERCOMP(oMeter,oText,oDlg,lEnd,cArqtmp,dAquIni,dAquFim,aPeriodo,cBemIni,cBemFim,cItemIni,cItemFim,cContaIni,cContaFim,;
cCCIni,cCCFim,cItCtbIni,cItCtbFim,cClvlIni,cClVlFim,cGrupoIni,cGrupoFim,cMoeda,aSelFil,lTodasFil,cChave,lAgrupa,aTipos,cFilter,cBaixa,nEntidade,cSaldoFil,;
aClassif,lParRlProv)

Local aCampos	   		:= {}
Local cAliasBem	   		:= "" // Alias auxiliar dos Bens
Local aValor	   		:= {}
Local lDefTop 	   		:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)
Local cSeq 	   	   		:= ""
Local cFlagBaix   		:= "0"
Local cTipoFiscal		:= ATFXTpBem(1)
Local cTipoGerenc    	:= ATFXTpBem(2)
Local cTipoIncent		:= ATFXTpBem(3)
Local aMoeda			:= {}
Local nPeriodo			:= 0
Local cPeriodo			:= 0
Local dDataIni			:= cToD("")
Local dDataFim			:= cToD("")
/* projeto argentina */
Local nDepAcm			:= 0
Local nCorrAcm			:= 0
Local nCorDepAcm		:= 0
/* projeto argentina */
Local nOriginal			:= 0
Local aTmpFil			:= {}
Local nX
Local lRealProv		:= .F.
Local lProcedure := .F.

Local cTypesNM			:= IIF(lIsRussia,"/" + AtfNValMod({1,2}, "/"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - main and recoverable models
Default oMeter			:= Nil
Default oText       	:= Nil
Default oDlg        	:= Nil
Default lEnd        	:= .F.
Default cArqtmp     	:= ""
Default dAquIni     	:= StoD("")
Default dAquFim	   		:= StoD("20301231")
Default aPeriodo		:= {}
Default cBemIni    		:= ""
Default cBemFim     	:= Replicate("Z",TamSX3("N1_CBASE")[1])
Default cItemIni 		:= ""
Default cItemFim 		:= Replicate("Z",TamSX3("N1_ITEM")[1])
Default cContaIni		:= ""
Default cContaFim		:= Replicate("Z",TamSX3("CT1_CONTA")[1])
Default cCCIni			:= ""
Default cCCFim	  		:= Replicate("Z",TamSX3("CTT_CUSTO")[1])
Default cItCtbIni		:= ""
Default cItCtbFim		:= Replicate("Z",TamSX3("CTD_ITEM")[1])
Default cClvlIni 		:= ""
Default cClVlFim 		:= Replicate("Z",TamSX3("CTH_CLVL")[1])
Default cGrupoIni		:= ""
Default cGrupoFim		:= Replicate("Z",TamSX3("N1_GRUPO")[1])
Default cMoeda     		:= "01"
Default aSelFil    		:= {cFilAnt}
Default lTodasFil  		:= .F.
Default cChave     		:= ""
Default lAgrupa   		:= .T.
Default aTipos   		:= {} 
Default aClassif   		:= {} 
Default cFilter	  		:= ""
Default cBaixa			:= "1"
Default nEntidade		:= 1
Default cSaldoFil 			:= "*"

If __lCpoSaldo == Nil
	__lCpoSaldo := .T.
EndIf

If !lDefTop
	Help("  ",1,"ATFGERTOP",,STR0001 ,1,0) //"Função disponível apenas para ambientes TopConnect"
	Return
EndIf
//procedure a ser utilizado no relatorio ATFR072
lProcedure := FunName() == "ATFR072" .And. CriaProc()

aAdd(aMoeda,cMoeda)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definição dos campos do arquivo temporário³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqTmp := IIF(Empty(cArqTmp),GetNextAlias(),cArqTmp)

aAdd(aCampos,{"FILIAL"		,"C",TamSX3("N1_FILIAL")[1]		,00	})
aAdd(aCampos,{"CBASE" 		,"C",TamSX3("N1_CBASE")[1]		,00	})
aAdd(aCampos,{"ITEM"  		,"C",TamSX3("N1_ITEM")[1]		,00	})
aAdd(aCampos,{"MOEDA" 		,"C",02					  		,00	})
aAdd(aCampos,{"CLASSIF"		,"C",TamSX3("N1_PATRIM")[1]		,00	})
aAdd(aCampos,{"TIPO"	 	,"C",TamSX3("N3_TIPO")[1]		,00	})
aAdd(aCampos,{"DESC_SINT"	,"C",TamSX3("N1_DESCRIC")[1]	,00	})
aAdd(aCampos,{"AQUISIC" 	,"D",8 					   		,00	})
aAdd(aCampos,{"DTBAIXA" 	,"D",8 							,00	})
aAdd(aCampos,{"DTINIPER" 	,"D",8 							,00	})
aAdd(aCampos,{"DTFIMPER" 	,"D",8 							,00	})
aAdd(aCampos,{"PERIODO" 	,"C",2						  	,00	}) // Número do período
aAdd(aCampos,{"CHAPA"	 	,"C",TamSX3("N1_CHAPA")[1]		,00	})
aAdd(aCampos,{"GRUPO"	 	,"C",TamSX3("N1_GRUPO")[1]		,00	})
aAdd(aCampos,{"CONTA"	 	,"C",TamSX3("CT1_CONTA")[1]		,00	}) // Conta do Bem
aAdd(aCampos,{"CCUSTO"	 	,"C",TamSX3("CTT_CUSTO")[1]		,00	}) // C Custo do Bem
aAdd(aCampos,{"SUBCTA"	 	,"C",TamSX3("CTD_ITEM")[1]		,00	}) // Item Contabil do Bem
aAdd(aCampos,{"CLVL"	 	,"C",TamSX3("CTH_CLVL")[1]		,00	}) // Classe de Valor do Bem
aAdd(aCampos,{"SEQ"	   		,"C",TamSX3("N3_SEQ")[1]		,00	})
aAdd(aCampos,{"SEQREAV"	 	,"C",TamSX3("N3_SEQREAV")[1]	,00	})
aAdd(aCampos,{"FLAGBAIXA" 	,"C",TamSX3("N3_BAIXA")[1]   	,00	})
aAdd(aCampos,{"TPSALDO" 	,"C",1						   	,00	})
aAdd(aCampos,{"TPDEPR"  	,"C",TamSX3("N3_TPDEPR")[1]    	,00	})

aAdd(aCampos,{"QUANTD"	 	,"N",TamSX3("N1_QUANTD")[1]		,TamSX3("N1_QUANTD")[2]	})
aAdd(aCampos,{"ORIGINAL"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"AMPLIACAO"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"ATUALIZ"		,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"DEPRECACM"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"DEPRECMES"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"RESIDUAL"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"CORRECACM"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"CORDEPACM"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})

If cPaisLoc $ "ARG|CHI"
	/* projeto argentina */
	aAdd(aCampos,{"CORREMENS"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
	aAdd(aCampos,{"CORDEPMEN"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
	/* projeto argentina */
Endif
aAdd(aCampos,{"VLBAIXAS"	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})
aAdd(aCampos,{"VLVENDA" 	,"N",TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]	})

If Empty(cChave)
	cChave := "FILIAL+CBASE+ITEM+TIPO+MOEDA+TPSALDO+SEQ+SEQREAV+PERIODO"
EndIf

/*
 * Verificação do campo para ativos de custo de provisão
 */
If Select("SN3") == 0
	DbSelectArea("SN3")	
EndIf

lRealProv := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a seleção dos Bens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasBem := ATFSelBem(cBemIni,cBemFim,cItemIni,cItemFim,dAquIni,dAquFim,cContaIni,cContaFim,cCCIni,cCCFim,cItCtbIni,cItCtbFim,cClvlIni,;
cClVlFim,cGrupoIni,cGrupoFim,aSelFil,lTodasFil,aPeriodo[1][1],lAgrupa,aTipos,cFilter,Nil,nEntidade,cSaldoFil,aTmpFil,aClassif,lRealProv)

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria a tabela temporária no Banco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
If Select(cArqTmp) > 0
	(cArqTmp)->(dbCloseArea())
EndIf
MsErase(cArqTmp)
MsCreate(cArqTmp, aCampos, 'TOPCONN' )
Sleep(1000)
dbUseArea( .T., 'TOPCONN', cArqTmp, cArqTmp, .T., .F. )
//Cria o Indice
IndRegua(cArqTmp,cArqTmp,cChave,,)

While (cAliasBem)->(!EOF())
	If __lCpoSaldo
		cSaldo := (cAliasBem)->N3_TPSALDO
	EndIf
	
	If lAgrupa
		aRet			:= ATFMaxSeq((cAliasBem)->N1_FILIAL,(cAliasBem)->N1_CBASE,(cAliasBem)->N1_ITEM,(cAliasBem)->N3_TIPO,(cAliasBem)->N3_SEQREAV,cSaldo,dDataFim,lProcedure)
		cSeq 	  		:= aRet[1]
		cFlagBaix   := aRet[2]
	EndIf
	
	If lParRlProv
		If (cAliasBem)->N3_ATFCPR == '1'
			(cAliasBem)->(dbSkip())
			Loop
		EndIf
	EndIf
	nDepAcm:= 0
	nCorrAcm := 0
	nCorDepAcm := 0
	nOriginal := 0
	
	For nPeriodo := 0 to Len(aPeriodo)
		cPeriodo			:= StrZero(nPeriodo,2)
		If nPeriodo == 0 // 1º Periodo o Valor é acumulado até o dia anterior do primeiro dia
			dDataIni			:= cToD("")
			dDataFim			:= aPeriodo[nPeriodo+1][1] - 1
		Else
			dDataIni			:= aPeriodo[nPeriodo][1]
			dDataFim			:= aPeriodo[nPeriodo][2]
		EndIf
		
		aValor := SaldoSN4( (cAliasBem)->N1_FILIAL,(cAliasBem)->N1_CBASE,(cAliasBem)->N1_ITEM,(cAliasBem)->N3_TIPO,cSeq,(cAliasBem)->N3_SEQREAV,aMoeda,dDataFim,lAgrupa,dDataIni,cSaldo)
		
		
		If nPeriodo == 0 .And. !Empty(aValor)
			If (cAliasBem)->N3_TIPO $ cTipoFiscal
				nDepAcm	+= aValor[1][2][POS_DEPR_FISCAL]
			ElseIf (cAliasBem)->N3_TIPO $ ("10/12" + cTypesNM) // Tratamento especial para o tipo 10 e 12 para trata o legado e para tratamentos especiais tipo Russia
				nDepAcm	+= aValor[1][2][POS_DEPR_GERENCIAL] + aValor[1][2][POS_DEPR_FISCAL]
			ElseIf (cAliasBem)->N3_TIPO $ cTipoGerenc
				nDepAcm	+= aValor[1][2][POS_DEPR_GERENCIAL]
			ElseIf (cAliasBem)->N3_TIPO $ cTipoIncent
				nDepAcm	+= aValor[1][2][POS_DEPR_INCENTIVADA]
			EndIf
			If cPaisLoc == "CHI"
				nCorrAcm += aValor[1][2][POS_CORREC_BEM]
				nCorDepAcm += aValor[1][2][POS_CORREC_DEPR]
				nOriginal := aValor[1][2][POS_VLR_ORGINIAL]
			Endif
		ElseIf nPeriodo != 0
			RecLock(cArqTmp,.T.)
			(cArqTmp)->FILIAL		:= (cAliasBem)->N1_FILIAL
			(cArqTmp)->CBASE		:= (cAliasBem)->N1_CBASE
			(cArqTmp)->ITEM			:= (cAliasBem)->N1_ITEM
			(cArqTmp)->MOEDA		:= cMoeda
			(cArqTmp)->CLASSIF		:= (cAliasBem)->N1_PATRIM
			(cArqTmp)->TIPO			:= (cAliasBem)->N3_TIPO
			(cArqTmp)->DESC_SINT	:= (cAliasBem)->N1_DESCRIC
			(cArqTmp)->AQUISIC 		:= (cAliasBem)->N1_AQUISIC
			(cArqTmp)->DTBAIXA 		:= (cAliasBem)->N1_BAIXA
			(cArqTmp)->FLAGBAIXA	:= cFlagBaix
			(cArqTmp)->DTINIPER		:= dDataIni
			(cArqTmp)->DTFIMPER		:= dDataFim
			(cArqTmp)->PERIODO 		:= cPeriodo
			(cArqTmp)->CHAPA	 	:= (cAliasBem)->N1_CHAPA
			(cArqTmp)->GRUPO	 	:= (cAliasBem)->N1_GRUPO
			(cArqTmp)->CONTA	 	:= (cAliasBem)->CONTA
			(cArqTmp)->CCUSTO	 	:= (cAliasBem)->CCUSTO
			(cArqTmp)->SUBCTA	 	:= (cAliasBem)->SUBCTA
			(cArqTmp)->CLVL	 		:= (cAliasBem)->CLVL
			(cArqTmp)->SEQ	   		:= cSeq
			(cArqTmp)->SEQREAV	 	:= (cAliasBem)->N3_SEQREAV
			(cArqTmp)->TPDEPR	 	:= GetAdvFval("SN3","N3_TPDEPR",(cArqTmp)->(FILIAL+CBASE+ITEM+TIPO+FLAGBAIXA+SEQ+SEQREAV),1,"")
			If __lCpoSaldo
				(cArqTmp)->TPSALDO 	:=  cSaldo
			EndIf
			If !Empty(aValor)
				If !Empty(aValor[1][2][POS_VLR_ORGINIAL])
					nOriginal := aValor[1][2][POS_VLR_ORGINIAL]
				EndIf
				If IsIncallStack("ATFR073")
					(cArqTmp)->ORIGINAL		:= (cAliasBem)->N3_VORIG1
				Else
					(cArqTmp)->ORIGINAL		:= nOriginal
				EndIf
				(cArqTmp)->AMPLIACAO	:= aValor[1][2][POS_AMPLIACAO]
				(cArqTmp)->VLBAIXAS		:= aValor[1][2][POS_BAIXAS]
				(cArqTmp)->VLVENDA		:= aValor[1][2][POS_VENDA]
				
				If (cAliasBem)->N3_TIPO $ cTipoFiscal
					(cArqTmp)->DEPRECMES	:= aValor[1][2][POS_DEPR_FISCAL]
				ElseIf (cAliasBem)->N3_TIPO $ ("10/12" + cTypesNM) // Tratamento especial para o tipo 10 e 12 para trata o legado e tratamento especial para tipos Russia
					(cArqTmp)->DEPRECMES	:= aValor[1][2][POS_DEPR_GERENCIAL] + aValor[1][2][POS_DEPR_FISCAL]
				ElseIf (cAliasBem)->N3_TIPO $ cTipoGerenc
					(cArqTmp)->DEPRECMES	:= aValor[1][2][POS_DEPR_GERENCIAL]
				ElseIf (cAliasBem)->N3_TIPO $ cTipoIncent
					(cArqTmp)->DEPRECMES	:= aValor[1][2][POS_DEPR_INCENTIVADA]
				EndIf
				nDepAcm 				+= (cArqTmp)->DEPRECMES
				(cArqTmp)->DEPRECACM	:= nDepAcm
				If cPaisLoc $ "ARG|CHI"
					/* Projeto argentina */
					nCorrAcm 				+= aValor[1][2][POS_CORREC_BEM]
					(cArqTmp)->CORREMENS	:= aValor[1][2][POS_CORREC_BEM]
					(cArqTmp)->CORRECACM	:= nCorrAcm
					nCorDepAcm				+= aValor[1][2][POS_CORREC_DEPR]
					(cArqTmp)->CORDEPMEN	:= aValor[1][2][POS_CORREC_DEPR]
					(cArqTmp)->CORDEPACM	:= nCorDepAcm
					/* Projeto Argentina */
				Else
					(cArqTmp)->CORRECACM	:= aValor[1][2][POS_CORREC_BEM]
					(cArqTmp)->CORDEPACM	:= aValor[1][2][POS_CORREC_DEPR]
				Endif
				(cArqTmp)->QUANTD	 	:= aValor[1][2][POS_QUANTD]
				If ! ((cAliasBem)->N3_TIPO $ '07/08/09')
					(cArqTmp)->ATUALIZ		:= (cArqTmp)->ORIGINAL + (cArqTmp)->AMPLIACAO + (cArqTmp)->CORRECACM - (cArqTmp)->VLBAIXAS
					(cArqTmp)->RESIDUAL		:= (cArqTmp)->ATUALIZ - (cArqTmp)->DEPRECACM
					If cPaisLoc == "CHI"
						(cArqTmp)->RESIDUAL -= nCorDepAcm
					Endif
				Else
					(cArqTmp)->ATUALIZ		:= 0
					(cArqTmp)->RESIDUAL		:= 0
				EndIf
			Else
				(cArqTmp)->ORIGINAL		:= 0
				(cArqTmp)->AMPLIACAO	:= 0
				(cArqTmp)->VLBAIXAS		:= 0
				(cArqTmp)->DEPRECMES	:= 0
				(cArqTmp)->DEPRECACM	:= 0
				(cArqTmp)->CORRECACM	:= 0
				(cArqTmp)->CORDEPACM	:= 0
				(cArqTmp)->QUANTD	 	:= 0
				(cArqTmp)->ATUALIZ		:= 0
				(cArqTmp)->RESIDUAL		:= 0
				
				
			EndIf
			MsUnLock()
		EndIf
	Next nPeriodo
	
	(cAliasBem)->(dbSkip())
EndDo

For nX := 1 TO Len(aTmpFil)
	CtbTmpErase(aTmpFil[nX])
Next

//dropa as procedures caso utilizada
If lProcedure
	AtfDropPrc()
EndIf

Return cArqTmp



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SaldoSN4 ºAutor  ³Alvaro Camillo Neto º Data ³  20/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o saldo do Bem na Data                             º±±
±±º          ³                                                            º±±
±±º          ³aRetorno[1] --> Valor Original                    		  º±±
±±º          ³aRetorno[2] --> Amplicação                        		  º±±
±±º          ³aRetorno[3] --> Depreciação                       		  º±±
±±º          ³aRetorno[4] --> DEPR. INCENTIVADA                   		  º±±
±±º          ³aRetorno[5] --> DEPR. GERENCIAL                     		  º±±
±±º          ³aRetorno[6] --> Correção Monetária do bem         		  º±±
±±º          ³aRetorno[7] --> Correção Monetária da depreciação 		  º±±
±±º          ³aRetorno[8] --> Baixas                            		  º±±
±±º          ³aRetorno[9] --> Quantidade                          		  º±±
±±º          ³aRetorno[10] --> Valores de Venda                     		  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SaldoSN4( cFilBem,cCodBase,cItem,cTipo,cSeq,cSeqReav,aMoeda,dDataSLD,lAgrupa,dDataIni,cSaldo)
Local aValor	:= {}
Local aValorAux	:= {}
Local aArea		:= GetArea()
Local cAliasBem	:= GetNextAlias()
Local cQuery	:= ""
Local nX		:= ""
Local aCpoValor	:= {}
Local aCpoOrig	:= {}
Local cCpoValor := ""
Local cCpoOrig := ""
Local cFilX		:= cFilAnt
Local nPos		:= 00
Local nValor	:= 0
Local nQuant	:= 0
Local nVenda	:= 0

Default aMoeda	:= {}
Default dDataSLD	:= SuperGetMV("MV_ULTDEPR", ,STOD("19800101"))
Default lAgrupa		:= .F.
Default dDataIni	:= STOD("")
Default cSaldo		:= "*"

If __lCpoSaldo == Nil
	__lCpoSaldo := .T.
EndIf

cFilAnt := IIF(Empty(cFilBem),cFilAnt,cFilBem)
aMoeda 	:= IIF(Empty(aMoeda),{"01"},aMoeda)

For nX:= 1 to Len(aMoeda)
	cCpoValor := "N4_VLROC" + cValToChar(Val(aMoeda[nX]) )
	cCpoOrig  := "N4_ORIG" + cValToChar(Val(aMoeda[nX]) )
	aAdd(aCpoValor,cCpoValor)
	aAdd(aCpoOrig,cCpoOrig)
Next nX

If Select(cAliasBem) > 0
	(cAliasBem)->(dbCloseArea())
EndIf

cQuery	:= " SELECT " + CRLF
cQuery	+= " N4_OCORR, N4_TIPOCNT,N4_MOTIVO "+ CRLF
For nX := 1 to Len(aCpoValor)
	cQuery	+= " , SUM(" + aCpoValor[nX] + ") " + aCpoValor[nX] + CRLF
Next nX

cQuery	+= " ,SUM(N4_QUANTD) N4_QUANTD "+ CRLF
cQuery	+= " ,SUM(N4_VENDA) N4_VENDA "+ CRLF

If lAtfr072 .and. cTipo $ cAtftioa 

	For nX := 1 to Len(aMoeda)
		cQuery	+= " , MAX(" + aCpoValor[nX] + ") " + aCpoOrig[nX] + CRLF
	Next nX
EndIF

cQuery	+= " FROM " + RetSQLTab("SN4")+ CRLF
cQuery	+= " WHERE "+ CRLF
cQuery	+= " N4_FILIAL 	= '"+xFilial("SN4")+"' AND "+ CRLF
cQuery	+= " N4_CBASE 	= '"+cCodBase+"' AND "+ CRLF
cQuery	+= " N4_ITEM 	= '"+cItem+"' AND "+ CRLF
cQuery	+= " N4_TIPO 	= '"+cTipo+"' AND "+ CRLF
cQuery	+= " N4_SEQREAV = '"+cSeqReav+"' AND "+ CRLF

If !lAgrupa
	cQuery	+= " N4_SEQ 	= '"+cSeq+"' AND "+ CRLF
EndIf

If !Empty(dDataIni)
	cQuery	+= " N4_DATA	>= '"+DtoS(dDataIni)+"' AND "+ CRLF
EndIf

If !Empty(cSaldo) .AND. __lCpoSaldo .AND. cSaldo != '*'
	cQuery	+= " N4_TPSALDO	= '"+cSaldo+"' AND "+ CRLF
EndIf

cQuery	+= " N4_DATA	<= '"+DtoS(dDataSLD)+"' AND "+ CRLF
cQuery	+= " SN4.D_E_L_E_T_ = '' "+ CRLF
cQuery	+= " GROUP BY N4_OCORR, N4_TIPOCNT,N4_MOTIVO "+ CRLF
cQuery	+= " ORDER BY N4_OCORR, N4_TIPOCNT,N4_MOTIVO "+ CRLF

cQuery := ChangeQuery(cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasBem , .T. , .F.)
TcFieldAll(cAliasBem)

(cAliasBem)->(dbGoTop())
While (cAliasBem)->(!EOF())
	For nX := 1 to Len(aCpoValor)
		nPos := aScan(aValor,{ |x| ALLTRIM(x[1]) == Alltrim(aMoeda[nX]) })
		If nPos > 0
			aValorAux := aClone(aValor[nPos][2])
		Else
			aAdd(aValor,{aMoeda[nX], {} })
			aValorAux := Array(11) // Quantidade de posições do array de retorno
			Afill(aValorAux,0)
			nPos := Len(aValor)
		EndIf
		nValor 	:= (cAliasBem)->&(aCpoValor[nX])
		cOcorr 	:= (cAliasBem)->N4_OCORR
		cTipoCnt:= (cAliasBem)->N4_TIPOCNT
		nVenda	:=  (cAliasBem)->N4_VENDA
		If cTipo $ '01/03' .or.  (cTipo $ '10' .and. lAtfr072 ) // Apenas tipos aquisição e adiantamento influenciam na quantidade do bem
			nQuant	:= (cAliasBem)->N4_QUANTD
		Else
			nQuant := 0
		Endif
		
		If (cAliasBem)->N4_OCORR == "01" //Baixa
			If (cAliasBem)->N4_MOTIVO $ '13' .And. (cAliasBem)->N4_TIPOCNT == '1' //“1” – Conta do Bem e a baixa foi por conversão, a baixa é apenas para registro da operação
				aValorAux[POS_VLR_ORGINIAL]  			-= nValor
			ElseIf 	(cAliasBem)->N4_MOTIVO $ '18' .And. (cAliasBem)->N4_TIPOCNT == '1' // Se a baixa foi por transferencia o valor já vai ser abatido do valor original com as proximas transações
				aValorAux[POS_QUANTD] 					-= nQuant	
			ElseIf (cAliasBem)->N4_TIPOCNT == '1' //“1” – Conta do Bem
				aValorAux[POS_BAIXAS] 					+= nValor
				aValorAux[POS_QUANTD] 					-= nQuant
				If (cAliasBem)->N4_MOTIVO $ '01' // Motivo de Venda
					aValorAux[POS_VENDA] 				+= nVenda
				EndIf
			ElseIf (cAliasBem)->N4_TIPOCNT == '2' //“2” – Conta de Correção do Bem
				aValorAux[POS_CORREC_BEM] 				-= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '4' //“4” – Conta de Depreciação Acumulada
				aValorAux[POS_DEPR_FISCAL]  			-= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '5' //“5” – Conta de Correc. da Depr. Acumulada
				aValorAux[POS_CORREC_DEPR] 			-= nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "02" //Substituição
			If (cAliasBem)->N4_TIPOCNT == '1' //“1” – Conta do Bem
				aValorAux[POS_VLR_ORGINIAL]  	-= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '2' //“2” – Conta de Correção do Bem
				aValorAux[POS_CORREC_BEM] -= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '4' //“4” – Conta de Depreciação Acumulada
				aValorAux[POS_DEPR_FISCAL]  			-= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '5' //“5” – Conta de Correc. da Depr. Acumulada
				aValorAux[POS_CORREC_DEPR] 			-= nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "03" //Transferência de
			If (cAliasBem)->N4_TIPOCNT == '1' //“1” – Conta do Bem
				aValorAux[POS_VLR_ORGINIAL]  	-= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '2' //“2” – Conta de Correção do Bem
				aValorAux[POS_CORREC_BEM] -= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '4' //“4” – Conta de Depreciação Acumulada
				aValorAux[POS_DEPR_FISCAL]  			-= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '5' //“5” – Conta de Correc. da Depr. Acumulada
				aValorAux[POS_CORREC_DEPR] 			-= nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "04" //Transferência Para
			If (cAliasBem)->N4_TIPOCNT == '1' //“1” – Conta do Bem
				aValorAux[POS_VLR_ORGINIAL]  	+= nValor
				aValorAux[POS_QUANTD] 			+= nQuant
			ElseIf (cAliasBem)->N4_TIPOCNT == '2' //“2” – Conta de Correção do Bem
				aValorAux[POS_CORREC_BEM] += nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '4' //“4” – Conta de Depreciação Acumulada
				aValorAux[POS_DEPR_FISCAL]  			+= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '5' //“5” – Conta de Correc. da Depr. Acumulada
				aValorAux[POS_CORREC_DEPR] 			+= nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "05" //Implantação
			If (cAliasBem)->N4_TIPOCNT == '1' //“1” – Conta do Bem
				aValorAux[POS_VLR_ORGINIAL]  	+= nValor
				aValorAux[POS_QUANTD] 			+= nQuant
				If lAtfr072 .and. cTipo $ cAtftioa 
					aValorAux[POS_RED_VL_REC] := (cAliasBem)->&(aCpoOrig[nX])
				EndIf
			ElseIf (cAliasBem)->N4_TIPOCNT == '2' //“2” – Conta de Correção do Bem
				aValorAux[POS_CORREC_BEM] += nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '4' //“4” – Conta de Depreciação Acumulada
				aValorAux[POS_DEPR_FISCAL]  			+= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '5' //“5” – Conta de Correc. da Depr. Acumulada
				aValorAux[POS_CORREC_DEPR] 			+= nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "06" //Depreciação
			If (cAliasBem)->N4_TIPOCNT == '4' //“4” – Conta de Depreciação Acumulada
				aValorAux[POS_DEPR_FISCAL] += nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "07" //Correção
			If (cAliasBem)->N4_TIPOCNT == '2' //“2” – Conta de Correção do Bem
				aValorAux[POS_CORREC_BEM] += nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "08" //Correção da depreciação
			If (cAliasBem)->N4_TIPOCNT == '5' //“5” – Conta de Correc. da Depr. Acumulada
				aValorAux[POS_CORREC_DEPR] += nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "09" //Ampliação
			If (cAliasBem)->N4_TIPOCNT == '1' //“1” – Conta do Bem
				aValorAux[POS_AMPLIACAO] += nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "10" //Depreciação Acelerada
			If (cAliasBem)->N4_TIPOCNT == '4' //“4” – Conta de Depreciação Acumulada
				aValorAux[POS_DEPR_FISCAL]  			+= nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "11" //Depreciação Inc. Negativa
			If (cAliasBem)->N4_TIPOCNT == '4' //“4” – Conta de Depreciação Acumulada
				aValorAux[POS_DEPR_INCENTIVADA]         -= nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "12" //Depreciação Inc. Positiva
			If (cAliasBem)->N4_TIPOCNT == '4' //“4” – Conta de Depreciação Acumulada
				aValorAux[POS_DEPR_INCENTIVADA] 		+= nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "13" //Inventário
			If (cAliasBem)->N4_TIPOCNT == '1' //“1” – Conta do Bem
				aValorAux[POS_VLR_ORGINIAL]  	+= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '2' //“2” – Conta de Correção do Bem
				aValorAux[POS_CORREC_BEM] += nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '4' //“4” – Conta de Depreciação Acumulada
				aValorAux[POS_DEPR_FISCAL]  			+= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '5' //“5” – Conta de Correc. da Depr. Acumulada
				aValorAux[POS_CORREC_DEPR] 			+= nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "15" //Baixa por Transferência
			If (cAliasBem)->N4_TIPOCNT == '1' //“1” – Conta do Bem
				aValorAux[POS_VLR_ORGINIAL]  	-= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '2' //“2” – Conta de Correção do Bem
				aValorAux[POS_CORREC_BEM] -= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '4' //“4” – Conta de Depreciação Acumulada
				aValorAux[POS_DEPR_FISCAL]  			-= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '5' //“5” – Conta de Correc. da Depr. Acumulada
				aValorAux[POS_CORREC_DEPR] 			-= nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "16" //Aquisição por Transferência
			If (cAliasBem)->N4_TIPOCNT == '1' //“1” – Conta do Bem
				aValorAux[POS_VLR_ORGINIAL]  	+= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '2' //“2” – Conta de Correção do Bem
				aValorAux[POS_CORREC_BEM] += nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '4' //“4” – Conta de Depreciação Acumulada
				aValorAux[POS_DEPR_FISCAL]  			+= nValor
			ElseIf (cAliasBem)->N4_TIPOCNT == '5' //“5” – Conta de Correc. da Depr. Acumulada
				aValorAux[POS_CORREC_DEPR] 			+= nValor
			EndIf
		ElseIf (cAliasBem)->N4_OCORR == "18" //Depreciação Acumulada da correção monetária mensal
			If (cAliasBem)->N4_TIPOCNT == '5' //“5” – Conta de Correc. da Depr. Acumulada
				aValorAux[POS_CORREC_DEPR] 		  += nValor
			EndIf
		ElseIf cPaisLoc!="RUS" .and. (cAliasBem)->N4_OCORR == "20" //Depreciação Gerencial
			If (cAliasBem)->N4_TIPOCNT == '4' //“4” – Conta de Depreciação Acumulada
				aValorAux[POS_DEPR_GERENCIAL] 		+= nValor
			EndIf
		EndIf
		
		aValor[nPos][2] := aClone(aValorAux)
		
	Next nX
	(cAliasBem)->(dbSkip())
EndDo

(cAliasBem)->(dbCloseArea())

cFilAnt :=cFilX
RestArea(aArea)
Return aValor


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFSelBem ºAutor  ³Alvaro Camillo Neto º Data ³  20/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seleciona os bens para processamento                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFXSAL                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ATFSelBem(cBemIni,cBemFim,cItemIni,cItemFim,dAquIni,dAquFim,cContaIni,cContaFim,cCCIni,cCCFim,cItCtbIni,cItCtbFim,;
cClvlIni,cClVlFim,cGrupoIni,cGrupoFim,aSelFil,lTodasFil,dDataSLD,lAgrupa,aTipos,cFilter,cBaixa,nEntidade,cSaldo,aTmpFil,aClassif,lRealProv)
Local cAliasBem := GetNextAlias()
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cAuxQuery := ""
Local nX		:= 0
Local cConta	:= ""
Local cCCusto	:= ""
Local cItemCtb 	:= ""
Local cClasse	:= ""
Local cTmpFil

Default lAgrupa := .F.
Default aTipos  := {}
Default dDataSLD := STOD("")
Default cBaixa := "1"
Default cFilter := ""
Default nEntidade := 1
Default cSaldo := "*"
Default aTmpFil := {} 
Default aClassif := {}

If __lCpoSaldo == Nil
	__lCpoSaldo := .T.
EndIf

If Select(cAliasBem) > 0
	(cAliasBem)->(dbCloseArea())
EndIf

//Entidades Contábeis
If nEntidade == 1 // Entidades da Conta
	cConta		:= "N3_CCONTAB"
	cCCusto		:= "N3_CUSTBEM"
	cItemCtb	:= "N3_SUBCCON"
	cClasse		:= "N3_CLVLCON"
ElseIf nEntidade == 2 // Entidades da Depreciação Acumulada
	cConta		:= "N3_CCDEPR"
	cCCusto		:= "N3_CCCDEP"
	cItemCtb 	:= "N3_SUBCCDE"
	cClasse		:= "N3_CLVLCDE"
ElseIF nEntidade == 3  // Entidades da Despesa de Depreciação
	cConta		:= "N3_CDEPREC"
	cCCusto		:= "N3_CCDESP"
	cItemCtb 	:= "N3_SUBCDEP"
	cClasse		:= "N3_CLVLDEP"
ElseIF nEntidade == 4  // Entidades da Correção do Bem
	cConta		:= "N3_CCORREC"
	cCCusto		:= "N3_CCCORR"
	cItemCtb 	:= "N3_SUBCCOR"
	cClasse		:= "N3_CLVLCOR"
ElseIF nEntidade == 5  // Entidades da Correção da Depreciação
	cConta		:= "N3_CDESP"
	cCCusto		:= "N3_CCCDES"
	cItemCtb 	:= "N3_SUBCDES"
	cClasse		:= "N3_CLVLDES"
EndIf

cQuery := " SELECT " + CRLF

If lAgrupa
	cQuery += " N1_FILIAL,N1_CBASE,N1_GRUPO,N1_ITEM,N1_AQUISIC,N1_DESCRIC,N1_BAIXA,N1_CHAPA,N1_PATRIM, "+ CRLF
	cQuery += " N3_TIPO,N3_SEQREAV "
	cQuery += ", " + cConta + " CONTA , " + cCCusto + " CCUSTO , " + cItemCtb + " SUBCTA , " + cClasse+ " CLVL "
	If __lCpoSaldo
		cQuery += " , N3_TPSALDO "+ CRLF
	EndIf
Else
	cQuery += " N1_FILIAL,N1_CBASE,N1_GRUPO,N1_ITEM,N1_AQUISIC,N1_DESCRIC,N1_BAIXA,N1_CHAPA,N1_PATRIM,"+ CRLF
	cQuery += " N3_TIPO,N3_SEQ,N3_SEQREAV,N3_BAIXA "+ CRLF
	cQuery += ", " + cConta + " CONTA , " + cCCusto + " CCUSTO , " + cItemCtb + " SUBCTA , " + cClasse+ " CLVL "
	If __lCpoSaldo
		cQuery += " , N3_TPSALDO "+ CRLF
	EndIf
EndIf

If lRealProv
	cQuery += ", N3_ATFCPR " + CRLF
EndIf

If _lAtfr073 .or. lAtfr072
	IF lAgrupa .and. _lAtfr073
		cQuery += ",SUM (N3_VORIG1) N3_VORIG1 " + CRLF
	Else
		cQuery += ", N3_VORIG1 " + CRLF
	EndIf
EndIf

cQuery += " FROM " + RetSQLTab("SN1")+ CRLF
cQuery += " INNER JOIN " + RetSQLTab("SN3") + " ON "+ CRLF
cQuery += " N1_FILIAL = N3_FILIAL AND "+ CRLF
cQuery += " N1_CBASE  = N3_CBASE  AND "+ CRLF
cQuery += " N1_ITEM   = N3_ITEM "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += " N1_CBASE BETWEEN '" + cBemIni + "' AND '" + cBemFim + "' AND "+ CRLF
cQuery += " N1_ITEM  BETWEEN '" + cItemIni + "' AND '" + cItemFim + "' AND "+ CRLF
cQuery += " N1_GRUPO  BETWEEN '" + cGrupoIni + "' AND '" + cGrupoFim + "' AND "+ CRLF
cQuery += " N1_AQUISIC  BETWEEN '" + DTOS(dAquIni) + "' AND '" + DTOS(dAquFim) + "' AND "+ CRLF
cQuery += " "+cConta+" BETWEEN '" + cContaIni + "' AND '" + cContaFim + "' AND "+ CRLF
cQuery += " "+cCCusto+" BETWEEN '" + cCCIni + "' AND '" + cCCFim + "' AND "+ CRLF
cQuery += " "+cItemCtb+" BETWEEN '" + cItCtbIni + "' AND '" + cItCtbFim + "' AND "+ CRLF
cQuery += " "+cClasse+" BETWEEN '" + cClvlIni + "' AND '" + cClVlFim + "' AND "+ CRLF

If __lCpoSaldo .And. Alltrim(cSaldo) != '*' .AND. !Empty(cSaldo)
	cQuery += " N3_TPSALDO = '" + cSaldo + "' AND "+ CRLF
EndIf

If !Empty(dDataSLD)
	If Alltrim(cBaixa) == "1" // Apenas Ativos
		cQuery += " ( N3_DTBAIXA > '" + DTOS(dDataSLD) + "'  OR N3_DTBAIXA = '') AND "+ CRLF
		cQuery += " (N1_BAIXA   > '" + DTOS(dDataSLD) + "' OR N1_BAIXA = '')  AND "+ CRLF
	ElseIf Alltrim(cBaixa) == "2" // Apenas Baixados
		cQuery += " ( N3_DTBAIXA <= '" + DTOS(dDataSLD) + "'  AND N3_DTBAIXA <> '') AND "+ CRLF
		cQuery += " (N1_BAIXA   <= '" + DTOS(dDataSLD) + "' AND N1_BAIXA <> '')  AND "+ CRLF
	EndIf
EndIf

If Len(aTipos) > 0
	For nX := 1 to Len(aTipos)
		cAuxQuery += aTipos[nX] + "\"
	Next nX
	cAuxQuery := Left(cAuxQuery, Len(cAuxQuery) - 1 )
	cAuxQuery := "IN " + FormatIn(cAuxQuery,"\") + " "
	cQuery += " N3_TIPO " + cAuxQuery + " AND "+ CRLF
EndIf
                
//Filtra as classificações
If Len(aClassif) > 0 
	cQuery += " N1_PATRIM IN " + FORMATCLAS(aClassif,.T.) + " AND "+ CRLF
EndIf

cQuery += " SN1.D_E_L_E_T_ = '' AND "+ CRLF
cQuery += " SN3.D_E_L_E_T_ = '' "+ CRLF

	cQuery += " AND N1_FILIAL " + GetRngFil( aSelFil, "SN1", .T., @cTmpFil )+ CRLF
	aAdd(aTmpFil, cTmpFil)


If !Empty(cFilter)
	cQuery += ' ' + cFilter
EndIf

If lAgrupa
	
	cQuery += " GROUP BY "+ CRLF
	cQuery += " N1_FILIAL,N1_CBASE,N1_GRUPO,N1_ITEM,N1_AQUISIC,N1_DESCRIC,N1_BAIXA,N1_CHAPA,N1_PATRIM, "+ CRLF
	cQuery += " N3_TIPO,N3_SEQREAV "+ CRLF
	cQuery += ", " + cConta + "  , " + cCCusto + "  , " + cItemCtb + " , " + cClasse + CRLF
	If __lCpoSaldo
		cQuery += " ,N3_TPSALDO "+ CRLF
	EndIf
	
	If lRealProv
		cQuery += ", N3_ATFCPR " + CRLF
	EndIf
	If  lAtfr072
		cQuery += ", N3_VORIG1 " + CRLF
	EndIf
EndIf

cQuery += " ORDER BY N1_FILIAL,N1_CBASE,N1_ITEM,N3_TIPO "+ CRLF
If __lCpoSaldo
	cQuery += " , N3_TPSALDO "+ CRLF
EndIf

cQuery := ChangeQuery(cQuery )

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasBem , .T. , .F.)

TcFieldAll(cAliasBem)

RestArea(aArea)
Return cAliasBem


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFMaxSeqºAutor  ³Alvaro Camillo Neto º Data ³  04/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o maior valor de sequencia ativa para o Bem         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ATFMaxSeq(cFilBem,cCodBase,cItem,cTipo,cSeqReav,cSaldo,dDataSLD,lProcedure)
Local aArea	  		:= GetArea()
Local cAliasBem	:= GetNextAlias()
Local cRetSeq		:= ""
Local cFlagBaix	:= ""
Local cOcorr		:= ""
Local cQuery		:= ""
Local cFilX			:= cFilAnt

Default dDataSLD	:= GetNewPar("MV_ULTDEPR", STOD("19800101"))
Default cSaldo		:= "*"
Default lProcedure := .F.

If __lCpoSaldo == Nil
	__lCpoSaldo := .T.
EndIf

cFilAnt := IIF(Empty(cFilBem),cFilAnt,cFilBem)

If Select(cAliasBem) > 0
	(cAliasBem)->(dbCloseArea())
EndIf


If cTipo == "07"	// Depreciacao acelerada
	cOcorr	:= "10"
ElseIf cTipo == "08"	// Depreciacao incentivada positiva
	cOcorr	:= "12"
ElseIf cTipo == "09"	// Depreciacao incentivada negativa
	cOcorr	:= "11"
Else
	cOcorr	:= "05"
EndIF

If lProcedure
	//Execucao por Procedure
	If Empty(cSaldo) .OR. !__lCpoSaldo .OR. cSaldo == '*'
		cSaldo := " "
	EndIf
	//executa a procedure 1
	aResult	:= TCSPEXEC( 	xProcedures( _cNomePr1 ),;
								xFilial("SN4"),;		//xFilial("SN4")
								cCodBase,;				//codigo base do ativo
	 							cItem,;					//item do ativo
	 							cTipo,;					//tipo do bem
	 							cSeqReav,;				//Seq.Reav.
	 							cSaldo,;				//tipodeSaldo
	 							cOcorr,;				//Ocorrencia
	 							DtoS(dDataSLD )	)		//data do Saldo

		If Empty( aResult )
			lProcedure := .F.
			cRetSeq := ""
			If !IsBlind()
				MsgAlert( STR0028 + " " + _cNomePr1 + ": " + TCSqlError() ) // "Erro executando a Stored Procedure"
			EndIf
		Else
			cRetSeq := aResult[1]
		EndIf

		If lProcedure 
			//executa a procedure 2
			aResult	:= TCSPEXEC( 	xProcedures( _cNomePr2 ),;
								xFilial("SN4"),;		//xFilial("SN4")
								cCodBase,;				//codigo base do ativo
	 							cItem,;					//item do ativo
	 							cTipo,;					//tipo do bem
	 							cSeqReav,;				//Seq.Reav.
	 							cSaldo,;				//tipodeSaldo
	 							cRetSeq )				//sequencia
	 							
			If Empty( aResult )
				lProcedure := .F.
				cFlagBaix := " "
				If !IsBlind()
					MsgAlert( STR0028 + " " + _cNomePr2 + ": " + TCSqlError() ) // "Erro executando a Stored Procedure"
				EndIf
			Else
				cFlagBaix := aResult[1]
			EndIf
	
			If Empty(cFlagBaix)
				cFlagBaix := "0"
			EndIf
			
			If Empty(cRetSeq)
				cRetSeq 	 := STRZERO(1,TamSX3("N4_SEQ")[1])
			EndIf
			
		EndIf
		
EndIf

If !lProcedure   //se nao passar pela procedure faz a rotina padrao com query
	If Select(cAliasBem) > 0
		(cAliasBem)->(dbCloseArea())
	EndIf
	
	cQuery	+= " SELECT  "+ CRLF
	cQuery	+= "     MAX(N4_SEQ) N4_SEQ "+ CRLF
	cQuery	+= " FROM " + RetSQLTab("SN4")+ CRLF
	cQuery	+= " WHERE "+ CRLF
	cQuery	+= " 		N4_FILIAL 	= '"+xFilial("SN4")+"' AND "+ CRLF
	cQuery	+= " 		N4_CBASE 	= '"+cCodBase+"' AND "+ CRLF
	cQuery	+= " 		N4_ITEM 	= '"+cItem+"' AND "+ CRLF
	cQuery	+= " 		N4_TIPO 	= '"+cTipo+"' AND "+ CRLF
	cQuery	+= " 		N4_SEQREAV = '"+cSeqReav+"' AND "+ CRLF
	If !Empty(cSaldo) .AND. __lCpoSaldo .AND. cSaldo != '*'
		cQuery	+= " 	N4_TPSALDO	= '"+cSaldo+"' AND "+ CRLF
	EndIf
	cQuery	+= " 		N4_OCORR = '"+cOcorr+"' AND "+ CRLF
	cQuery	+= "     N4_DATA <= '"+DtoS(dDataSLD)+"' AND "+ CRLF
	cQuery	+= "     SN4.D_E_L_E_T_ = ' '  "+ CRLF
	
	cQuery := ChangeQuery(cQuery )
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasBem , .T. , .F.)
	
	(cAliasBem)->(dbGoTop())
	
	If (cAliasBem)->(!EOF())
		cRetSeq := (cAliasBem)->N4_SEQ
		cFlagBaix := ATFRetFlgB(cFilBem,cCodBase,cItem,cTipo,cRetSeq,cSeqReav,cSaldo)
	Else
		cRetSeq 	 := STRZERO(1,TamSX3("N4_SEQ")[1])
		cFlagBaix := "0"
	EndIf
	
	(cAliasBem)->(dbCloseArea())
EndIf

cFilAnt :=cFilX
RestArea(aArea)
Return {cRetSeq,cFlagBaix}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFRetFlgBºAutor  ³Microsiga           º Data ³  04/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o Flag de baixa na data                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ATFRetFlgB(cFilBem,cCodBase,cItem,cTipo,cSeq,cSeqReav,cSaldo)
Local aArea	  		:= GetArea()
Local cAliasBem	:= GetNextAlias()
Local cFlagBaix	:= ""
Local cQuery		:= ""
Local cFilX			:= cFilAnt

If __lCpoSaldo == Nil
	__lCpoSaldo := .T.
EndIf

cFilAnt := IIF(Empty(cFilBem),cFilAnt,cFilBem)

If Select(cAliasBem) > 0
	(cAliasBem)->(dbCloseArea())
EndIf

cQuery	+= " SELECT  "+ CRLF
cQuery	+= "     N3_BAIXA "+ CRLF
cQuery	+= " FROM " + RetSQLTab("SN3")+ CRLF
cQuery	+= " WHERE "+ CRLF
cQuery	+= " 		N3_FILIAL 	= '"+xFilial("SN4")+"' AND "+ CRLF
cQuery	+= " 		N3_CBASE 	= '"+cCodBase+"' AND "+ CRLF
cQuery	+= " 		N3_ITEM 	= '"+cItem+"' AND "+ CRLF
cQuery	+= " 		N3_TIPO 	= '"+cTipo+"' AND "+ CRLF
cQuery	+= " 		N3_SEQREAV = '"+cSeqReav+"' AND "+ CRLF
If !Empty(cSaldo) .AND. __lCpoSaldo .AND. cSaldo != '*'
	cQuery	+= " 	N3_TPSALDO	= '"+cSaldo+"' AND "+ CRLF
EndIf
cQuery	+= " 		N3_SEQ = '"+cSeq+"' AND "+ CRLF
cQuery	+= "     SN3.D_E_L_E_T_ = ''  "+ CRLF

cQuery := ChangeQuery(cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasBem , .T. , .F.)

(cAliasBem)->(dbGoTop())

If (cAliasBem)->(!EOF())
	cFlagBaix := (cAliasBem)->N3_BAIXA
Else
	cFlagBaix := "0"
EndIf

(cAliasBem)->(dbCloseArea())
cFilAnt :=cFilX
RestArea(aArea)

Return cFlagBaix

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TcFieldAllºAutor  ³Alvaro Camillo Neto º Data ³  06/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Aplica o comando TcSetField em todos os campos de uma query º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TcFieldAll(qQuery)
Local aStruQry 	:= {}
Local nI		:= 0
Local aArea		:= GetArea()
Local AAreaSX3	:= SX3->(GetArea())

SX3->(dbSetOrder(2)) //X3_CAMPO
aStruQry   := (qQuery)->(dbStruct())
For nI := 1 To Len(aStruQry)
	If SX3->(dbSeek(aStruQry[nI][1]))
		aStruQry[nI][2] := SX3->X3_TIPO
		If aStruQry[nI][2] <> "C"
			TcSetField(qQuery ,aStruQry[nI][1],aStruQry[nI][2],aStruQry[nI][3],aStruQry[nI][4])
		EndIf
	EndIf
Next nI
RestArea(AAreaSX3)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AfDescSal ³ Autor ³ Wagner Xavier         ³ Data ³ 17/08/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra a descri‡„o do Saldo.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AfDescSal( cTipo )
LOCAL nTipo := IIF( ValType( cTipo ) = "C", Val( cTipo ), nTipo )

Local aDescSaldo :={		OemToAnsi(STR0034) , ;  //"Saldo Inicial"
							OemToAnsi(STR0002) , ;  //"Imobilizacao"
							OemToAnsi(STR0003) , ;  //"Ampliacao"
							OemToAnsi(STR0004) , ;  //"Reavaliacao"
							OemToAnsi(STR0005) , ;  //"Depreciacao"
							OemToAnsi(STR0006) , ;  //"Baixa"
							OemToAnsi(STR0007) , ;  //"Correc. Monet."
							OemToAnsi(STR0008) , ;  //"Corr. Deprec."
							OemToAnsi(STR0009) , ;  //"Transf. de"
							OemToAnsi(STR0010) , ;  //"Transf. para"
							OemToAnsi(STR0011) , ;  //"Capital"
							OemToAnsi(STR0012) , ;  //"Capital Prej"
							OemToAnsi(STR0013) , ;  //"Baixa Capital"
							OemToAnsi(STR0014) , ;  //"Bx Cap Prej."
							OemToAnsi(STR0015) , ;  //"Ampl Capital"
							OemToAnsi(STR0016) , ;  //"Ampl Cap Prj."
							OemToAnsi(STR0017) , ;  //"Tr d/ - Patr."
							OemToAnsi(STR0018) , ;  //"Tr d/ - Prej."
							OemToAnsi(STR0019) , ;  //"Tr p/ - Patr."
							OemToAnsi(STR0020) , ;  //"Tr p/ - Prej."
							OemToAnsi(STR0021) , ;  //"Dep Acel Pos."
							OemToAnsi(STR0022) , ;  //"Dep Acel Neg."
							OemToAnsi(STR0023) , ;  //"Equiv Positiva"
							OemToAnsi(STR0024) , ;  //"Equiv negativa"
							OemToAnsi(STR0007) , ;  //"Correc. Monet."
							OemToAnsi(STR0025) , ;  //"Invent rio"
							OemToAnsi(STR0026) , ;  //"Aquis por Transf"
							OemToAnsi(STR0027) , ;  //"Bx Aquis Transf."
							OemToAnsi(STR0028) , ;  //"Tr de bens Fil"
							OemToAnsi(STR0029) , ;  //"Tr para bens Fil"
							OemToAnsi(STR0030) , ;  //"Tr de Patrim Fil"
							OemToAnsi(STR0031) , ;  //"Tr para Patrim Fil"
							OemToAnsi(STR0032) , ;	//"Especifico Argentina"
							OemToAnsi(STR0033)}   	//"Depr. Gerencial"

If cTipo == "A";nTipo := 10;End
If cTipo == "B";nTipo := 11;End
If cTipo == "C";nTipo := 12;End
If cTipo == "D";nTipo := 13;End
If cTipo == "E";nTipo := 14;End
If cTipo == "F";nTipo := 15;End
If cTipo == "G";nTipo := 16;End
If cTipo == "H";nTipo := 17;End
If cTipo == "I";nTipo := 18;End
If cTipo == "J";nTipo := 19;End
If cTipo == "K";nTipo := 20;End
If cTipo == "L";nTipo := 21;End
If cTipo == "M";nTipo := 22;End
If cTipo == "N";nTipo := 23;End
If cTipo == "O";nTipo := 24;End
If cTipo == "P";nTipo := 25;End
If cTipo == "Q";nTipo := 26;End
If cTipo == "R";nTipo := 27;End
If cTipo == "S";nTipo := 28;End
If cTipo == "T";nTipo := 29;End
If cTipo == "U";nTipo := 30;End
If cTipo == "V";nTipo := 31;End
If cTipo == "W";nTipo := 32;End
If cTipo == "Y";nTipo := 33;End

Return aDescSaldo [ nTipo+1 ]

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AtfSaldo ³ Autor ³ Wagner Xavier         ³ Data ³ 30/09/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza‡„o de saldos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1,ExpD1,ExpC2,ExpN1,ExpN2,ExpN3,ExpN4,ExpN5,ExpC2      ³±±
±±³          ³ aVlMoed=Vetor com valor de todas as moedas(multiplas Moedas)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Tipos de contas:
"1" - Conta do Bem
"2" - Conta de Correção do Bem
"3" - Conta de Despesa Depreciação
"4" - Conta de Depreciação Acumulada
"5" - Conta de Correção da Depreciação Acumulada
"6" - Conta de Correção da Conta de Capital Social
*/

Function AtfSaldo(	cConta,dData,cTipo,nValor1,nValor2,nValor3,nValor4,nValor5,;
							cSinal,nTaxa,cSubConta,cFil,cClvl,cCusto, cTipoCnt, aVlMoed,cTipoSld,cMotivo,cTipBem,cCustProv, cOcorr)

Default cMotivo := ""
Default cTipBem := ""
Default cCustProv := ""

Return ATFXSLDCTB(cConta,dData,cTipo,nValor1,nValor2,nValor3,nValor4,nValor5,cSinal,nTaxa,cSubConta,cFil,cClvl,cCusto, cTipoCnt, aVlMoed,cTipoSld,cMotivo,cTipBem,cCustProv, cOcorr)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaProc   ºAutor  ³Paulo Carnelossi   º Data ³  11/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Procedures a ser utilizado nas funcoes ATFMaxSeq /          º±±
±±º          ³   ATFRetFlgB                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CriaProc()
Local lRet    := .F.
Local cQuery  := ""
Local cRet    := ""
Local cProc1  := ""
Local cProc2  := ""

//carrega variaveis static com nome das procedures
_cNomePr1 := CriaTrab(,.F.)
_cNomePr2 := CriaTrab(,.F.)

//cria procedure 1
cProc1 := _cNomePr1+"_"+cEmpAnt
If !TCSPExist( cProc1 )

	cQuery := " CREATE PROCEDURE "+ cProc1 +" ( "+CRLF
	cQuery += " @IN_FILIAL char("+Alltrim(Str(Len(SN4->N4_FILIAL)))+"), "+CRLF
	cQuery += " @IN_CBASE char("+Alltrim(Str(Len(SN4->N4_CBASE)))+"), "+CRLF
	cQuery += " @IN_ITEM char("+Alltrim(Str(Len(SN4->N4_ITEM)))+"), "+CRLF
	cQuery += " @IN_TIPO char("+Alltrim(Str(Len(SN4->N4_TIPO)))+"), "+CRLF
	cQuery += " @IN_SEQREAV char("+Alltrim(Str(Len(SN4->N4_SEQREAV)))+"), "+CRLF
	If SN4->(FieldPos("N4_TPSALDO")) > 0	
		cQuery += " @IN_TPSALD char("+Alltrim(Str(Len(SN4->N4_TPSALDO)))+"), "+CRLF
	Else
		cQuery += " @IN_TPSALD char(1), "+CRLF
	EndIf
	cQuery += " @IN_OCORR char("+Alltrim(Str(Len(SN4->N4_OCORR)))+"), "+CRLF
	cQuery += " @IN_DTSALDO char(8), "+CRLF
	cQuery += " @OUT_RET char("+Alltrim(Str(Len(SN4->N4_SEQ)))+") output )"+CRLF
	
	cQuery += " AS "+CRLF
	cQuery += " Declare @cMaxSeq char("+Alltrim(Str(Len(SN4->N4_SEQ)))+") "+CRLF
	cQuery += " Select @cMaxSeq = ' ' "+CRLF
	cQuery += " Select @OUT_RET = ' '"+CRLF
		
	cQuery += "	begin"+CRLF
	
	cQuery	+= " SELECT  @cMaxSeq = isnull( max(N4_SEQ), ' ') "+ CRLF
	cQuery	+= " FROM " + RetSQLTab("SN4")+ CRLF
	cQuery	+= " WHERE "+ CRLF
	cQuery	+= " 		N4_FILIAL 	  = @IN_FILIAL AND "+ CRLF
	cQuery	+= " 		N4_CBASE 	  = @IN_CBASE AND "+ CRLF
	cQuery	+= " 		N4_ITEM 	  = @IN_ITEM AND "+ CRLF
	cQuery	+= " 		N4_TIPO 	  = @IN_TIPO AND "+ CRLF
	cQuery	+= " 		N4_SEQREAV    = @IN_SEQREAV AND "+ CRLF
	If SN3->(FieldPos("N3_TPSALDO")) > 0 .AND. SN4->(FieldPos("N4_TPSALDO")) > 0	
		cQuery	+= " 	    N4_TPSALDO	  = @IN_TPSALD AND "+ CRLF
	Else
		cQuery	+= " 	    ( @IN_TPSALD = ' ' OR @IN_TPSALD = '*' OR N4_TPSALDO = @IN_TPSALD) AND "+ CRLF
	EndIf
	cQuery	+= " 		N4_OCORR      = @IN_OCORR AND "+ CRLF
	cQuery	+= "        N4_DATA      <= @IN_DTSALDO AND "+ CRLF
	cQuery	+= "       SN4.D_E_L_E_T_ = ' '  "+ CRLF
	
	cQuery:=cQuery+"		select @OUT_RET = @cMaxSeq"+CRLF
	
	cQuery:=cQuery+"	end"+CRLF
	cQuery:=MsParse(cQuery,Alltrim(TcGetDB()))
	
	If cQuery=''
		If !IsBlind()
			MsgAlert( "Error in the creation of the procedure" + " " + cProc1 + ": " + MsParseError() ) // "Error in the creation of the procedure"
		EndIf
	Else
		
		If Alltrim(Upper(TcGetDB()))=="ORACLE"
			cQuery:=StrTran(cQuery,"= ''","is null")
		EndIf

		//instala procedure 1
		cRet:=TcSqlExec(cQuery)
		If cRet <> 0
			If !IsBlind()
				MsgAlert( "Error in the creation of the procedure" + " " + cProc1 + ": " + TCSQLError() )  // "Error in the creation of the procedure"
			EndIf
			lRet := .f.
		Else
			lRet := .T.
		EndIf
	EndIf
EndIf

//cria procedure 2
cProc2 := _cNomePr2+"_"+cEmpAnt
cQuery := ""
If !TCSPExist( cProc2 )

	cQuery := " CREATE PROCEDURE "+ cProc2 +" ( "+CRLF
	cQuery += " @IN_FILIAL char("+Alltrim(Str(Len(SN3->N3_FILIAL)))+"), "+CRLF
	cQuery += " @IN_CBASE char("+Alltrim(Str(Len(SN3->N3_CBASE)))+"), "+CRLF
	cQuery += " @IN_ITEM char("+Alltrim(Str(Len(SN3->N3_ITEM)))+"), "+CRLF
	cQuery += " @IN_TIPO char("+Alltrim(Str(Len(SN3->N3_TIPO)))+"), "+CRLF
	cQuery += " @IN_SEQREAV char("+Alltrim(Str(Len(SN3->N3_SEQREAV)))+"), "+CRLF
	If SN3->(FieldPos("N3_TPSALDO")) > 0	
		cQuery += " @IN_TPSALD char("+Alltrim(Str(Len(SN3->N3_TPSALDO)))+"), "+CRLF
	Else
		cQuery += " @IN_TPSALD char(1), "+CRLF
	EndIf
	cQuery += " @IN_SEQ char("+Alltrim(Str(Len(SN3->N3_SEQ)))+"), "+CRLF
	cQuery += " @OUT_RET char("+Alltrim(Str(Len(SN3->N3_BAIXA)))+") output )"+CRLF
	
	cQuery += " AS "+CRLF
	cQuery += " Declare @cN3Baixa char("+Alltrim(Str(Len(SN3->N3_BAIXA)))+") "+CRLF
	cQuery += " Select @cN3Baixa = ' ' "+CRLF
	cQuery += " Select @OUT_RET = ' ' "+CRLF
	
	cQuery += "	begin"+CRLF
	
	cQuery	+= " SELECT  @cN3Baixa = isnull( N3_BAIXA, ' ') "+ CRLF
	cQuery	+= " FROM " + RetSQLTab("SN3")+ CRLF
	cQuery	+= " WHERE "+ CRLF
	cQuery	+= " 		N3_FILIAL 	  = @IN_FILIAL AND "+ CRLF
	cQuery	+= " 		N3_CBASE 	  = @IN_CBASE AND "+ CRLF
	cQuery	+= " 		N3_ITEM 	  = @IN_ITEM AND "+ CRLF
	cQuery	+= " 		N3_TIPO 	  = @IN_TIPO AND "+ CRLF
	cQuery	+= " 		N3_SEQREAV    = @IN_SEQREAV AND "+ CRLF
	If SN3->(FieldPos("N3_TPSALDO")) > 0 .AND. SN4->(FieldPos("N4_TPSALDO")) > 0	
		cQuery	+= " 	    N3_TPSALDO	  = @IN_TPSALD AND "+ CRLF
	Else
		cQuery	+= " 	    ( @IN_TPSALD = ' ' OR @IN_TPSALD = '*' OR N3_TPSALDO = @IN_TPSALD) AND "+ CRLF
	EndIf
	cQuery	+= " 		N3_SEQ        = @IN_SEQ AND "+ CRLF
	cQuery	+= "       SN3.D_E_L_E_T_ = ' '  "+ CRLF
	
	cQuery:=cQuery+"		select @OUT_RET = @cN3Baixa"+CRLF

	cQuery:=cQuery+"	end"+CRLF
	cQuery:=MsParse(cQuery,Alltrim(TcGetDB()))
	
	If cQuery=''
		If !IsBlind()
			MsgAlert( "Error in the creation of the procedure" + " " + cProc2 + ": " + MsParseError() ) // "Error in the creation of the procedure"
		EndIf
	Else
		
		If Alltrim(Upper(TcGetDB()))=="ORACLE"
			cQuery:=StrTran(cQuery,"= ''","is null")
		EndIf

		//instala procedure 2
		cRet:=TcSqlExec(cQuery)
		If cRet <> 0
			If !IsBlind()
				MsgAlert( "Error in the creation of the procedure" + " " + cProc2 + ": " + TCSQLError() )  // Error in the creation of the procedure
			EndIf
			lRet := .f.
		Else
			lRet := .T.
		EndIf
	EndIf
EndIf

If lRet
	lRet := TCSPExist( cProc1 ) .And. TCSPExist( cProc2 )
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtfDropPrc   ºAutor  ³Paulo Carnelossi   º Data ³  11/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Drop das Procedures a ser utilizado nas funcoes ATFMaxSeq /          º±±
±±º          ³   ATFRetFlgB                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtfDropPrc()
Local lRet := .F.

If TCSPExist( _cNomePr1+"_"+cEmpAnt )
	If TcSqlExec("DROP PROCEDURE "+ _cNomePr1+"_"+cEmpAnt) <> 0
 		UserException("Error in delete procedure :" + _cNomePr1+"_"+cEmpAnt + CRLF + TCSqlError() )
   	Else
		lRet := .T.
	EndIf
Endif

If TCSPExist( _cNomePr2+"_"+cEmpAnt )
	If TcSqlExec("DROP PROCEDURE "+ _cNomePr2+"_"+cEmpAnt) <> 0
 		UserException("Error in delete procedure :" + _cNomePr2+"_"+cEmpAnt + CRLF + TCSqlError() )
   	Else
		lRet := .T.
	EndIf
Endif

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ATFTempTable
Gera tabela temporaria a partir de uma query.
 
@sample	oTable := ATFTempTable(cQuery,cAlias,aIndex,aFldConv)
 
@param	cQuery		- Caractere. Select que terá seu resultset convertido em tabela temporária 	
@param	cAlias 		- Caractere. Alias definido para a tabela temporária
@param	aIndex 		- Array. Array com os índices que serão montados para o arquivo temporário
			aIndex[n,1]	- STRING. Nome do índice
			aIndex[n,2]	- ARRAY. Array com os campos do índice
					aIndex[n,2][n]	- STRING. Nome do Campo 
@param	aFldConv 	- Array. array com os campos que terão os dados convertidos para a montagem
							do arquivo temporário
			aFldConv[n,1]	- Caractere. Nome do campo da Tabela
			aFldConv[n,2]	- Caractere. tipo de dado que será convertido para o campo
			aFldConv[n,3]	- Numérico. Tamanho do campo
			
@return oTable		- objeto. Instância da Classe FwTemporaryTable

@author	Fernando Radu Muscalu
@since	 16/08/2018
@version P12
/*/
//------------------------------------------------------------------------------------------
Function ATFTempTable(cQuery,cAlias,aIndex,aFldConv)

Local oTable

Local cAliasResSet	:= GetNextAlias()
Local cInternalQry	:= "%" + Substr(Alltrim(cQuery),At("SELECT",UPPER(cQuery))+Len("SELECT")) + "%"
Local nI			:= 0

Default cAlias		:= GetNextAlias()
Default aIndex		:= {}
Default aFldConv	:= {}

BeginSQL Alias cAliasResSet

	SELECT	%Exp:cInternalQry%

EndSQL

//Monta o ResultSet
//MPSysOpenQuery(cQuery, cAliasResSet)

For nI := 1 to Len(aFldConv)	
	
	If ( Len(aFldConv[nI]) == 3 )
		TCSetField(cAliasResSet,aFldConv[nI,1],aFldConv[nI,2],aFldConv[nI,3])
	ElseIf ( Len(aFldConv[nI]) == 4 )
		TCSetField(cAliasResSet,aFldConv[nI,1],aFldConv[nI,2],aFldConv[nI,3],aFldConv[nI,4])
	EndIf
		
Next nI

oTable := FWTemporaryTable():New(cAlias)

oTable:SetFields((cAliasResSet)->(DbStruct()))

For nI := 1 to Len(aIndex)
	oTable:AddIndex(aIndex[nI,1],aClone(aIndex[nI,2]))
Next nI

oTable:Create()
(oTable:GetAlias())->( __dbZap() )

(cAliasResSet)->(DbGoTop())

Begin Transaction

	While ( (cAliasResSet)->(!Eof()) )
		
		RecLock(oTable:GetAlias(),.t.)	
		
			For nI := 1 to (cAliasResSet)->(FCount())
				(oTable:GetAlias())->&(FieldName(nI)) := (cAliasResSet)->&(FieldName(nI))	
			Next nI
		
		(oTable:GetAlias())->(MsUnlock())
		
		(cAliasResSet)->(DbSkip())
		
	EndDo

End Transaction

(cAliasResSet)->(DbCloseArea())

(oTable:GetAlias())->(DbGoTop())

Return(oTable)

/*/{Protheus.doc} ATFFld2Str()
    Converte campos das estruturas do MVC ou de tabela para string
    @type  Function
    @author Fernando Radu Muscalu
    @since 16/08/2018
    @version version
    
	@param	xStruct		- objeto ou Caracter, instância ou da classe FwFormModelStruct ou da FWFormViewStruct ou alias (caracter) da tabela
	@param	lStr4Qry	- lógico, .t. - Os campos carregados são para utilização em query (devem existir 
										no banco de dados)
	@param	aFldConv	- Array. array com os campos que terão os dados convertidos para a montagem
							do arquivo temporário
				aFldConv[n,1]	- Caractere. Nome do campo da Tabela
				aFldConv[n,2]	- Caractere. tipo de dado que será convertido para o campo
				aFldConv[n,3]	- Numérico. Tamanho do campo
	@param	lReset		- Lógico. .t. limpa o array aFldConv		
	@param	lSetDefault	- Lógico. .t. define um conteúdo defaul para o campo do select
	@param	lQuebra		- Lógico. .t. acrescenta o caracter 'enter' ao final de cada campo e vírgula do select
    
	@return cFldStr, caractere, cadeia de campos separados por vírgula.

    @example cFldStr := ATFFld2Str(xStruct,.t.) -> Ex: "CAMPO1, CAMPO2, ..., CAMPON"
    @see (links_or_references)
/*/
Function ATFFld2Str(xStruct,lStr4Qry,aFldConv,lReset,lSetDefault,lQuebra)

Local cFldStr 	:= ""
Local cAliasTab	:= ""

Local nI		:= 0	
Local nInd		:= 0

Local aFldStruct:= {}

Default lStr4Qry	:= .f.	//Consversão para Query
Default aFldConv	:= {}
Default lReset		:= .t.
Default lSetDefault	:= .f.
Default lQuebra		:= .f.

If ( ValType(xStruct) == "O" )

	If ( Upper(Alltrim(xStruct:ClassName())) == "FWFORMMODELSTRUCT" )	

		nInd 		:= 3
		nIndTipo	:= 4
		nIndTam		:= 5
		cAliasTab 	:= xStruct:GetTable()[1]
		aFldStruct	:= xStruct:GetFields()
		
	ElseIf (Upper(Alltrim(xStruct:ClassName())) == "TABLESTRUCT" )

		nInd		:= 1
		nIndTipo 	:= 2
		nIndTam		:= 3
		cAliasTab	:= xStruct:cAlias
		aFldStruct	:= xStruct:aFields

	EndIf

Else

	nInd		:= 1
	nIndTipo 	:= 2
	nIndTam		:= 3
	cAliasTab	:= xStruct
	aFldStruct 	:= (xStruct)->(DbStruct())

EndIf

If ( lReset )
	aFldConv := {}
EndIf	

For nI := 1 to Len(aFldStruct)

	If ( lStr4Qry )
		lOk := (cAliasTab)->(FieldPos(aFldStruct[nI,nInd])) > 0
		aAdd(aFldConv,{aFldStruct[nI,nInd],aFldStruct[nI,nIndTipo],aFldStruct[nI,nIndTam]})
	Else
		lOk := .t.
	EndIf

	If ( lOk )
	
		If ( lSetDefault .and. lStr4Qry )
			
			If ( aFldConv[Len(aFldConv),2] $ "C|D|L" )
				cFldStr += "'" + Space(aFldConv[Len(aFldConv),3]) + "'"
			ElseIf ( aFldConv[Len(aFldConv),2] == "N" )
				cFldStr += ATFCastType(0,"C")
			EndIf
			
			cFldStr += Space(1) + aFldConv[Len(aFldConv),1] + ", " + Iif(lQuebra,chr(13),"")
			 
		Else
			cFldStr += aFldStruct[nI,nInd] + ", " + Iif(lQuebra,chr(13),"")
		EndIf				
	EndIf

Next nI

cFldStr := SubStr(cFldStr,1,Rat(",",cFldStr)-1)

Return(cFldStr)

/*/{Protheus.doc} ATFSeekTemp()
    Função para pesquisar dados em tabela temporária da classe FWTemporaryTable
    @type  Function
    @author Fernando Radu Muscalu
    @since 16/08/2018
    @version version
    
	@param	oTableTemp	- objeto, instância da classe FWTemporaryTable
	@param	aSeek		- array, matriz que contém a chave de pesquisa dos registros.
				aSeek[n,1]	- caractere, campo que será analisado na pesquisa
				aSeek[n,2]	- qualquer, conteúdo do campo que será pesquisado
				aSeek[n,3]	- caractere, operador de comparação (ex: ">"; ">="; "<"; "<="). 
							Se este elemento não for informado, será considerado o operador de igualdade ("=")
	@param	aResultSet	- Array. array com o resultSet da pesquisa. Se o array não for passado
						será retornado todos os campos da tabela para a consulta.
				aResultSet[1,x] - Caractere. Campos retornados na consulta.
				aFldConv[n,1]	- Caractere. Nome do campo da Tabela
				aFldConv[n,2]	- Caractere. tipo de dado que será convertido para o campo
				aFldConv[n,3]	- Numérico. Tamanho do campo
	@param	lReset		- Lógico. .t. limpa o array aResultSet		
	@param	cOrderBy	- Caractere. Definição da ordem da consulta. Ex: "campo1, campo2, ..., campon"
	@param	lOrderBy	- Lógico. .t. Ordenará a query de acordo com os campos do resultset, a não ser que o parâmetro
						cOrderBy tenha sido informado.
    
	@return lRet		- Lógico, .t. a pesquisa retornou dados.
		retorno indireto -> aResultSet. O Array será alimentado com os dados da consulta

    @example lRet := ATFSeekTemp(oTableTemp,aSeek,aResultSet,lReset,cOrderBy,lOrderBy)
    @see (links_or_references)
/*/
Function ATFSeekTemp(oTableTemp,aSeek,aResultSet,lReset,cOrderBy,lOrderBy)

Local aStruct	:= (oTableTemp:GetAlias())->(DbStruct())

Local cAlias	:= GetNextAlias()
Local cWhere	:= ""
Local cCompare	:= ""
Local cFields	:= ""
Local cFldOrd	:= ""
Local cOperator	:= ""

Local nI		:= 0
Local nP		:= 0

Local aHeaderSet 	:= {}
Local aCellSet		:= {}
	
Local lRet	:= .f.

Default aResultSet 	:= {}
Default lReset 		:= .t.
Default cOrderBy	:= ""
Default lOrderBy	:= .f.

If ( Valtype(oTableTemp) == "O" )

	cFields := "%"
	
	If ( Len(aResultSet) > 0 )
		aEval(aResultSet[1],{|x| cFields += x + ", "})
	Else
		aEval(oTableTemp:GetStruct():aFields,{|x| cFields += x[1] + ", ", aAdd(aHeaderSet,x[1])})
		aAdd(aResultSet,aClone(aHeaderSet))
	EndIf
	
	If ( !Empty(cOrderBy) .And. lOrderBy )
		cFldOrd := cOrderBy
	ElseIf ( lOrderBy )
		cFldOrd := SubStr(cFields,1,Rat(",",cFields)-1)	
	EndIf
		
	cFields += " R_E_C_N_O_ RECNO %" 
	
	If ( Len(aResultSet) > 0 )
		aAdd(aResultSet[1],"R_E_C_N_O_")
	EndIF	
	
	If ( Len(aSeek) > 0 )
		
		cWhere := "% " + oTableTemp:GetRealName() + " WHERE "
		
		For nI := 1 to Len(aSeek)
			
			nP := aScan(aStruct,{|x| Upper(Alltrim(x[1])) == Upper(Alltrim(aSeek[nI,1]))})
			
			If ( nP > 0 )	
			
				If ( aStruct[nP,2] == "C" )
					cCompare := "'" + aSeek[nI,2] + "'"
				ElseIf ( aStruct[nP,2] == "N" )
					cCompare := ATFCastType(aSeek[nI,2],"C")
				ElseIf ( aStruct[nP,2] == "D" )
					cCompare := "'" + ATFCastType(aSeek[nI,2],"C","AAAAMMDD") + "'"
				ElseIf ( aStruct[nP,2] == "L" )
					cCompare := "'" + ATFCastType(aSeek[nI,2],"C") + "'"	
				EndIf
			
			EndIf
			
			If ( Len(aSeek[nI]) == 3 )
				cOperator := aSeek[nI,3]
			Else
				cOperator := "="
			EndIf

			If ( nI == Len(aSeek) ) 
				cWhere += aSeek[nI,1] + cOperator + cCompare
			Else
				cWhere += aSeek[nI,1] + cOperator + cCompare + " AND "
			EndIf
				  
		Next nI
		
		If ( !Empty(cFldOrd) )
			cWhere += " ORDER BY " + cFldOrd 
		EndIf
		
		cWhere += "%"
		
		BeginSQL Alias cAlias
		
			SELECT
				%Exp:cFields%
			FROM
				%Exp:cWhere%
									
		EndSQL
	
		lRet := (cAlias)->(!Eof())
	
		If ( lRet )
		
			If ( Len(aResultSet) > 0 )
				
				aHeaderSet := aClone(aResultSet[1])
				
				If ( lReset )
					aResultSet := {aClone(aHeaderSet)}
				EndIf
				
				
				While ( (cAlias)->(!EoF()) )
					
					(oTableTemp:GetAlias())->(DbGoTo((cAlias)->RECNO))
					
					For nI := 1 to Len(aHeaderSet)
					
						If ( aHeaderSet[nI] <> "R_E_C_N_O_" )
							aAdd(aCellSet,(oTableTemp:GetAlias())->&(aHeaderSet[nI]))
						Else
							aAdd(aCellSet,(cAlias)->RECNO)
						EndIf
						
					Next nI
					
					aAdd(aResultSet,aClone(aCellSet))
					
					aCellSet := {}
					
					(cAlias)->(DbSkip())
					
				End While	
				 
			EndIf
			
			(cAlias)->(DbGoTop())
			
			(oTableTemp:GetAlias())->(DbGoTo((cAlias)->RECNO))
			
		EndIf
		
		(cAlias)->(DbCloseArea())
			
	Else
		lRet := .f.
	EndIf

EndIf

Return(lRet)

/*/{Protheus.doc} ATFSeekTable()
    Função para pesquisar dados em tabela física do banco de dados
    @type  Function
    @author Fernando Radu Muscalu
    @since 16/08/2018
    @version version
    
	@params	
		cAliasTable	- Caractere, Alias da tabela a ser consultada
		aSeek		- array, matriz que contém a chave de pesquisa dos registros.
				aSeek[n,1]	- caractere, campo que será analisado na pesquisa
				aSeek[n,2]	- qualquer, conteúdo do campo que será pesquisado
				aSeek[n,3]	- caractere, operador de comparação (ex: ">"; ">="; "<"; "<="). 
							Se este elemento não for informado, será considerado o operador de igualdade ("=")
		aResultSet	- Array. array com o resultSet da pesquisa. Se o array não for passado
						será retornado todos os campos da tabela para a consulta.
				aResultSet[1,x] - Caractere. Campos retornados na consulta.
				aFldConv[n,1]	- Caractere. Nome do campo da Tabela
				aFldConv[n,2]	- Caractere. tipo de dado que será convertido para o campo
				aFldConv[n,3]	- Numérico. Tamanho do campo
		lReset		- Lógico. .t. limpa o array aResultSet		
		cOrderBy	- Caractere. Definição da ordem da consulta. Ex: "campo1, campo2, ..., campon"
		lOrderBy	- Lógico. .t. Ordenará a query de acordo com os campos do resultset, a não ser que o parâmetro
						cOrderBy tenha sido informado.
		cRealName	- Caractere. None real da tabela				
    
	@return lRet		- Lógico, .t. a pesquisa retornou dados.
		retorno indireto -> aResultSet. O Array será alimentado com os dados da consulta

    @example lRet := ATFSeekTemp(oTableTemp,aSeek,aResultSet,lReset,cOrderBy,lOrderBy)
    @see (links_or_references)
/*/
Function ATFSeekTable(cAliasTable,aSeek,aResultSet,lReset,cOrderBy,lOrderBy,cRealName)

Local cAlias		:= GetNextAlias()
Local cWhere		:= ""
Local cOperator		:= ""
Local cFldOrd		:= ""

Local nI			:= 0
	
Local lRet			:= .f.

Local aHeaderSet 	:= {}
Local aCellSet		:= {}
Local aFields		:= {}

Default aResultSet 	:= {}
Default lReset 		:= .t.
Default cOrderBy	:= ""
Default lOrderBy	:= .f.
Default cRealName	:= RetSQLName(cAliasTable)

cFields := "%"

If ( Len(aResultSet) > 0 )
	aEval(aResultSet[1],{|x| cFields += x + ", "})
Else
	aFields := (cAliasTable)->(DbStruct())

	aEval(aFields,{|x| cFields += x[1] + ", ",aAdd(aHeaderSet,x[1])})
	aAdd(aResultSet,aClone(aHeaderSet))

EndIf

If ( !Empty(cOrderBy) .And. lOrderBy )
	cFldOrd := cOrderBy
ElseIf ( lOrderBy )
	cFldOrd := SubStr(cFields,1,Rat(",",cFields)-1)	
EndIf

cFields += " R_E_C_N_O_ RECNO %" 

If ( Len(aSeek) > 0 )
	
	cWhere := "% " + cRealName + " " + cAliasTable + " WHERE "
	
	For nI := 1 to Len(aSeek)
	
		If ( GetSx3Cache(aSeek[nI,1],"X3_TIPO") == "C" )
			cCompare := "'" + aSeek[nI,2] + "'"
		ElseIf ( GetSx3Cache(aSeek[nI,1],"X3_TIPO") == "N" )
			cCompare := ATFCastType(aSeek[nI,2],"C")
		ElseIf ( GetSx3Cache(aSeek[nI,1],"X3_TIPO") == "D" )
			cCompare := "'" + ATFCastType(aSeek[nI,2],"C","AAAAMMDD") + "'"
		ElseIf ( GetSx3Cache(aSeek[nI,1],"X3_TIPO") == "L" )
			cCompare := "'" + ATFCastType(aSeek[nI,2],"C") + "'"
		Else
			cCompare := "'" + aSeek[nI,2] + "'"
		EndIf
		
		If ( Len(aSeek[nI]) == 3 )
			cOperator := aSeek[nI,3]
		Else
			cOperator := "="
		EndIf
		
		cWhere += aSeek[nI,1] + " " + cOperator + " " + cCompare + " AND "		
			  
	Next nI
	
	cWhere += cAliasTable + ".D_E_L_E_T_ = '' "
	
	If ( !Empty(cFldOrd) )
		cWhere += " ORDER BY " + cFldOrd 
	EndIf
	
	cWhere += "%"
	
	BeginSQL Alias cAlias
	
		SELECT
			%Exp:cFields%
		FROM
			%Exp:cWhere%	
	EndSQL
	
	lRet := (cAlias)->(!Eof())

	If ( lRet )
	
		If ( Len(aResultSet) > 0 )
			
			aHeaderSet := aClone(aResultSet[1])
			
			If ( lReset )
				aResultSet := {aClone(aHeaderSet)}
			EndIf
			
			aAdd(aHeaderSet,"RECNO")
			
			While ( (cAlias)->(!EoF()) )
				
				(cAliasTable)->(DbGoTo((cAlias)->RECNO))
				
				For nI := 1 to Len(aHeaderSet)
					
					If ( aHeaderSet[nI] <> "RECNO" )
						aAdd(aCellSet,(cAliasTable)->&(aHeaderSet[nI]))
					EndIf
						
				Next nI
				
				aAdd(aCellSet,(cAlias)->RECNO)
				
				aAdd(aResultSet,aClone(aCellSet))
				
				aCellSet := {}
				
				(cAlias)->(DbSkip())
				
			End While	
			 
		EndIf
		
		(cAlias)->(DbGoTop())
		
		(cAliasTable)->(DbGoTo((cAlias)->RECNO))
		
	EndIf
	
	(cAlias)->(DbCloseArea())
	
Else
	lRet := .f.
EndIf

Return(lRet)

/*/{Protheus.doc} ATFCastType
	Função de conversão de tipos de dados
	@type  Function
	@author Fernando Radu Muscalu
	@since 16/08/2018
	@version 1
	@param xValue, qualquer, Tipo de Dado a ser convertido
			cConvType, caractere, para qual tipo será convertido: 
				"C" - Caractere;
				"N" - Numérico;
				"D" - Data;
				"L" - Lógico
	@return xRet, qualquer, Tipo de Dado que foi convertida
	@example
	(examples)
	@see (links_or_references)
/*/
Function ATFCastType(xValue,cConvType,cFormat,nLength)

Local xRet

Default cFormat := ""
Default nLength	:= 1

Do Case
Case ( ValType(xValue) == "C" )

	If ( cConvType == "C" )

		If ( At(":",cFormat) > 0 )	//vamos considerar que seja hora
			xRet := ATFFrmtHour(xValue, cFormat)
		ElseIf ( !Empty(cFormat) )	
			xRet := Transform(xValue,cFormat)
		Else
			xRet := xValue
		EndIf

	ElseIf ( cConvType == "N" )
		xRet := Val(xValue)
	ElseIf ( cConvType == "D" )
		
		If ( At("/",xValue) > 0 )
			xRet := CToD(xValue)
		Else
			xRet := STOD(xValue)
		EndIf

	ElseIf ( cConvType == "L" )
		
		If ( At("T",xValue) > 0 )
			xRet := .t.
		Else
			xRet := .f.
		Endif

	EndIf

Case ( ValType(xValue) == "N" )

	If ( cConvType == "C" )
		
		If ( Empty(cFormat) )
			xRet := cValToChar(xValue)
		Else
			xRet := Transform(xValue,cFormat)	
		EndIf	

	ElseIf ( cConvType == "N" )
		xRet := xValue
	ElseIf ( cConvType == "D" )
		xRet := xValue
	ElseIf ( cConvType == "L" )
		
		If ( xValue <= 0 )
			xRet := .f.
		Else
			xRet := .T.
		Endif

	EndIf

Case ( ValType(xValue) == "D" )

	If ( cConvType == "C" )
		
		If ( Empty(cFormat) .or. Alltrim(Lower(cFormat)) $ "dd/mm/yyyy|dd/mm/aaaa" )
			xRet := DToC(xValue)
		ElseIf ( Alltrim(Lower(cFormat)) $ "yyyymmdd|aaaammdd" )
			xRet := DToS(xValue)
		EndIf

	ElseIf ( cConvType == "N" )
		xRet := xValue
	ElseIf ( cConvType == "D" )
		xRet := xValue
	ElseIf ( cConvType == "L" )
		xRet := xValue
	EndIf

Case ( ValType(xValue) == "L" )

	If ( cConvType == "C" )
		xRet := IIf(xValue,"T","F")
	ElseIf ( cConvType == "N" )
		xRet := IIf(xValue,1,0)
	ElseIf ( cConvType == "D" )
		xRet := xValue
	ElseIf ( cConvType == "L" )
		xRet := xValue
	EndIf

Case ( Valtype(xValue) == "U" )

	If ( cConvType == "C" )
		xRet := space(nLength)
	ElseIf ( cConvType == "N" )
		xRet := 0
	ElseIf ( cConvType == "D" )
		xRet := SToD("")
	ElseIf ( cConvType == "L" )
		xRet := .f.
	ElseIf ( cConvType == "M" )
		xRet := ""	
	EndIf
	
End Case

Return(xRet)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ATFFrmtHour

Esta função efetua a formação de horas no formato passado por parâmetro (cFormat). As máscaras aceitas 
pela função são:

cFormat 
	- 9999
	- 99999
	- 99:99
	- 99:99:99
	- 99.99
	- 99.99.99
	- 99h
	- 99h99
	- 99h99m99s

@params:
	xHour:		Undefined. A hora poderá ser passada como tipo string ou tipo numérico.
	cFormat:	String. Objeto de classe FormModelStruct
	 
@return: 
	cHour:	String. Retorno da hora formata de acordo com a máscara. 

@sample: cHour := ATFFrmtHour(xHour, cFormat)

@author Fernando Radu Muscalu/Lucas Brustolin

@since 18/08/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function ATFFrmtHour(xHour, cFormat)

Local cHour			:= ""	
Local cPureForm		:= "" 
Local cSeparator	:= ""
Local nI			:= 1
Local nLenAux		:= 2
Default cFormat := "99:99:99"

If ( Valtype(xHour) == "N" )
	cHour := cValToChar(xHour)
Else
	cHour := xHour
Endif 

If ( At(".",cHour) > 0 )
	cSeparator := "."	
ElseIf ( At(":",cHour) > 0 )
	cSeparator := ":"
Endif

If ( !Empty(cSeparator) )
	
	aHour := Separa(cHour, cSeparator)
	
	cHour := ""
	
	For nI := 1 to Len(aHour)
	
		If ( Len(Alltrim(aHour[nI])) == 1 .and. nI == 1 )
			aHour[nI] := "0" + Alltrim(aHour[nI])
		ElseIf Len(Alltrim(aHour[nI])) == 1 .and. nI <> 1
			aHour[nI] := Alltrim(aHour[nI]) + "0" 	 
		Endif
		If  nI == 1
			nLenAux := Len(aHour[nI])
		Endif
		cHour += aHour[nI]
		
	Next nI

Endif

For nI := 1 to Len(cFormat)
	
	If ( IsDigit(Substr(cFormat, nI, 1)) )
		cPureForm += Substr(cFormat, nI, 1)
	Endif

Next nI

If ( Len(cHour) <= 2)
	cHour := PadL(cHour,nLenAux,"0")+"00"
Else
	cHour := PadL(cHour,nLenAux,"0")+ PadR(Substr(cHour,nLenAux+1),2,"0")
EndIf

cHour := Transform(cHour, "@R " + cFormat )

Return(cHour)
