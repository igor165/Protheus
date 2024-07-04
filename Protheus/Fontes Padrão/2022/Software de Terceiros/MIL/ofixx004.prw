#include "TOTVS.ch"
#include "OFIXX004.ch"
#include "TOPCONN.ch"

#define STR0033 "" // Reaproveitar
#define STR0064 "" // Reaproveitar

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OFIXX004   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Como Pagar de Pecas e Servicos                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Auto-Pecas ORCAMENTO                                         |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXX004(cTabela,nOpc,aOrcs,lMostrTel,lSoFin)
Local nCntFor    := 0
Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.t.)
Local lAbrePesq  := .t.
Local lRet       := .t.
//
Default aOrcs    := {}
Default lMostrTel:= .t.
Default lSoFin   := .f. // se .T., só gera Financeiro
//
Private lPreDig  := .f.
Private oFnt1    := TFont():New( "System", , 12 )
Private oFnt2    := TFont():New( "Courier New", , 16,.t. )
Private oFnt3    := TFont():New( "Arial", , 14,.t. )
Private cPrefBAL := GetNewPar("MV_PREFBAL","BAL")
Private cMoeda   := GetMV("MV_SIMB1")
Private aIteParc := {}
Private n        := 1
Private aNewBot  := {{"FORM",	{|| OX001AVARES(nOpc)},	STR0031}}
Private cNFCF    := ""
Private cSimVda  := "P" // Pecas
Private lNegPag	 := .t. // Indica se o usuario pode alterar qq informacao no formulario
// Variaveis do cabecalho do formulario
Private nValFre  := 0
Private nValDes  := 0
Private nValTot  := 0
Private nValDup  := 0
Private nValSeg  := 0
Private nValSer  := 0
Private nValPec  := 0
Private nValST   := 0
Private nValIPI  := 0
Private nValPis  := 0
Private nValCof  := 0
Private nValICM  := 0
Private cTipPag  := SPACE(TamSX3("E4_CODIGO")[1]) // Tipo de Pagamento para montar Parcelas
Private cBanco   := VS1->VS1_CODBCO
Private cSaldo   := ""
Private cDesCond := ""
Private nAcresFin:= 0
Private nTtAcrFin:= 0
// Variaveis da aCols
Private aHeaderCP:= {}
Private aAlterCP := {}
Private cTipAva  := "2"  // Pecas
Private lMultOrc := .f.
Private cResAlm  := GetMv( "MV_RESITE" )
Private lFezRes  := At("R",GetNewPar("MV_FASEORC","0FX")) > 0 
Private lFormaID := VS9->(FieldPos("VS9_FORMID")) > 0 .and. GetNewPar("MV_TEFMULT","F") == .t.
Private cCartao  := "0"
Private cCheque  := "0"
//
Private oLogger := DMS_Logger():New()
Private aLog    := {}
Private aLogVQL := {}
//
Private lVS1_VLBRNF := VS1->(FieldPos("VS1_VLBRNF")) > 0
Private lVS1_FPGBAS := VS1->(FieldPos("VS1_FPGBAS")) > 0
//
if !Empty(aOrcs)
	lMultOrc := .t.
endif
//
If lSoFin
	aNewBot  := {} // Nao ter opções quando for somente para gerar Financeiro
Else
	aAdd(aNewBot, {"REORD", {|| OX004REORD()}, STR0079}) // Reordenar Pagamentos
EndIf

aAdd(aNewBot, {"MOTIVO", {|| OX0040026_SemaforoCliente()}, STR0080}) // Motivo

If ( ExistBlock("OX004ABT") )
	aNewBot := ExecBlock("OX004ABT",.f.,.f.,{aNewBot})
EndIf

INCLUI := ( nOpc == 3 )
ALTERA := ( nOpc == 4 )
EXCLUI := ( nOpc == 5 )
//################################################################################################
//# Posiciona na equipe tecnica para verificar parametros de permissao (VAI_NEGPAG e VAI_ALTPAR) #
//################################################################################################
DBSelectArea("VAI")
DBSetOrder(4)
DBSeek(xFilial("VAI")+__cUserID)
if VAI->VAI_NEGPAG == "0"
	lNegPag   := .f.
	lAbrePesq := .f.
ElseIf VAI->VAI_NEGPAG == "2" .And. !Empty(VS1->VS1_FORPAG)
	lNegPag   := .f.
endif

//################################################################################################
//# Montagem das informacoes coletadas do orcamento                                              #
//################################################################################################
aImposVEC := {}

if cTabela == "VS1"
	if Empty(aOrcs)
		aAdd(aOrcs,VS1->VS1_NUMORC)
	endif
	cDesCond := ""
	For nCntFor := 1 to Len(aOrcs)
		DBSelectArea("VS1")
		DBSetOrder(1)
		DBSeek(xFilial("VS1")+aOrcs[nCntFor])

		cTipPag := VS1->VS1_FORPAG
		
		DBSelectArea("SE4")
		DBSetOrder(1)
		dbSeek(xFilial("SE4")+cTipPag)  
		If SE4->(FieldPos("E4_FORMA")) > 0 .and. VS1->(FieldPos("VS1_TIPPAG")) > 0 
			If !Empty(SE4->E4_FORMA) .and. Alltrim(VS1->VS1_TIPPAG) == Alltrim(SE4->E4_FORMA)+"/"
				lNegPag := .f.
			Endif
		Endif
	
		DBSelectArea("VS3")
		DBSetOrder(1)
		DBSeek(xFilial("VS3")+VS1->VS1_NUMORC)
		while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL+ VS3->VS3_NUMORC
			nValPec += ( Round(VS3->VS3_VALPEC*VS3->VS3_QTDITE,2) - VS3->VS3_VALDES )
			DBSkip()
		enddo
		//
		DBSelectArea("VS4")
		DBSetOrder(1)
		DBSeek(xFilial("VS4")+VS1->VS1_NUMORC)
		while !eof() .and. xFilial("VS4")+VS1->VS1_NUMORC == VS4->VS4_FILIAL+ VS4->VS4_NUMORC
			nValSer += VS4->VS4_VALSER  - VS4->VS4_VALDES
			DBSkip()
		enddo
		nValFre += VS1->VS1_VALFRE
		nValDes += VS1->VS1_DESACE
		nValTot += VS1->VS1_VTOTNF
		nValDup += VS1->VS1_VALDUP
		nValSeg += VS1->VS1_VALSEG
		nValST  += VS1->VS1_ICMRET
		nValIPI += VS1->VS1_VALIPI
		if lMultOrc
			nValPis := VS3->VS3_VALPIS
			nValCof := VS3->VS3_VALCOF 
			nValICM := VS3->VS3_ICMCAL
			aAdd(aImposVEC,{nValICM, nValPis, nValCof})
		endif
	next
endif

//

if !lMultOrc

	//Valores que precisam ser zerados para recalculo quando VS1_VLBRNF = 0 
	If lVS1_VLBRNF .and. VS1->VS1_VLBRNF == "0" .and. lVS1_FPGBAS .and. !Empty(VS1->VS1_FPGBAS)
		nValIPI  := 0
		nValST   := 0
		nValDup	 := 0
	EndIf

	For nCntFor:=1 to Len(oGetPecas:aCols)
		//
		oGetPecas:nAt := nCntFor
		//
		if oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])]
			Loop
		Endif
		//
		OX001PecFis()

		//VS1_VLBRNF = 0 recalcula valores com o desconto zerado (não é enviado para o faturamento)
		If lVS1_VLBRNF .and. VS1->VS1_VLBRNF == "0" .and. lVS1_FPGBAS .and. !Empty(VS1->VS1_FPGBAS)
			MaFisAlt("IT_DESCONTO"	,0,n)
			MaFisAlt("IT_PRCUNI"	,oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_VALPEC","aHeaderP")] - ( oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_VALDES","aHeaderP")] / oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_QTDITE","aHeaderP")] ),n)
			MaFisAlt("IT_VALMERC"	,oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_VALTOT","aHeaderP")],n)

			nValIPI	+= MaFisRet(n,"IT_VALIPI")
			nValST	+= MaFisRet(n,"IT_VALSOL")
		EndIf

		nValPis 	:= MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2")
		nValCof 	:= MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2")
		aLivroVEC 	:= MaFisRet(n,"IT_LIVRO")
		nValICM 	:= aLivroVEC[5]
		OX001FisPec()
		//
		aAdd(aImposVEC,{nValICM, nValPis, nValCof})
	next
	nValDup	:= MaFisRet(,"NF_BASEDUP")
endif	

nSaldo := nValDup
nSaldo += nAcresFin
cSaldo := Transform(nSaldo,"@E 999,999,999.99")
nSaldoF8 := nSaldo
//
If ExistBlock("OX004F8")
	SETKEY(VK_F8,{|| ExecBlock("OX004F8",.f.,.f.,{nSaldoF8}) })
EndIf


// ######################################################
// # Cria Variaveis de Memoria e aHeader                #
// ######################################################
nUsadoE := 0
cNaoAltVS9 := "VS9_ENTRAD"
cNaoMosVS9 := "VS9_FILIAL,VS9_NUMIDE,VS9_TIPOPE,VS9_OBSERV,VS9_OBSMEM,VS9_SEQUEN,VS9_DATBAI,VS9_TIPFEC,VS9_TIPTIT,VS9_SEQPRO"

If !lFormaID
	cNaoMosVS9 += ",VS9_FORMID"
EndIf

//
DBSelectArea("SX3")
DBSetOrder(1)
DBSeek("VS9")
While !Eof().And.(x3_arquivo=="VS9")
	If  X3USO(x3_usado) .And. cNivel>=x3_nivel  .and. !(Alltrim(x3_campo) $ cNaoMosVS9)
		nUsadoE:=nUsadoE+1
		Aadd(aHeaderCP,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,	SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
		SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT, X3CBOX(), SX3->X3_RELACAO, ".T."})
		if x3_usado != "V" .and. (INCLUI .or. ALTERA) .and. !(Alltrim(x3_campo) $ cNaoAltVS9)
			aAdd(aAlterCP,x3_campo)
		endif
	endif
	DbSkip()
EndDo
// ######################################################
// # Cria aCols                                         #
// ######################################################
If INCLUI
	lPreDig := .t.
	aColsCP := { Array(nUsadoE+1) }
	aColsCP[1,nUsadoE+1] := .F.
	For nCntFor:=1 to nUsadoE
		aColsCP[1,nCntFor] := CriaVar(aHeaderCP[nCntFor,2])
	Next
Else
	aColsCP:={}
	dbSelectArea("VS9")
	dbSetOrder(1)
	If dbSeek(xFilial("VS9")+VS1->VS1_NUMORC)
		While !eof() .and. VS9->VS9_FILIAL == xFilial("VS9") .and. Alltrim(VS9->VS9_NUMIDE) == VS1->VS1_NUMORC
			AADD(aColsCP,Array(nUsadoE+1))
			For nCntFor:=1 to nUsadoE
				if aHeaderCP[nCntFor,10] == "V"
					SX3->(DBSetOrder(2))
					SX3->(DBSeek(aHeaderCP[nCntFor,2]))
					aColsCP[Len(aColsCP),nCntFor] := &(sx3->x3_relacao)
				else
					aColsCP[Len(aColsCP),nCntFor] := FieldGet(FieldPos(aHeaderCP[nCntFor,2]))
				endif
			Next
			aColsCP[Len(aColsCP),nUsadoE+1]:=.F.
			DbSkip()
		EndDo
	Else
		lPreDig := .t.
	EndIf
EndIf
// ######################################################
// # Montagem da tela do Formulario                     #
// ######################################################
// Fator de reducao da tela do como pagar = 0.8
for nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
next
//
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 }// Tamanho total da tela
AAdd( aObjects, { 0, 6, .T., .f. } )
//
AAdd( aObjects, { 0, 80, .T., .f. } )
AAdd( aObjects, { 0, 08, .T., .T. } )
AAdd( aObjects, { 0, 40, .T., .f. } )
aPos := MsObjSize( aInfo, aObjects )
//
aObjects2 := {}
AAdd( aObjects2, { 0, 15, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .T. } )
//
aAbaCab := { aPos[1,2], aPos[1,1], aPos[1,4], aPos[1,3] , 3, 3 }
aPosCab := MsObjSize( aAbaCab, aObjects2 )
//
aObjects3 := {}
AAdd( aObjects3, { 0, 08, .T., .f. } )
AAdd( aObjects3, { 0, 08, .T., .f. } )
AAdd( aObjects3, { 0, 08, .T., .f. } )
AAdd( aObjects3, { 0, 08, .T., .f. } )
AAdd( aObjects3, { 0, 08, .T., .T. } )
AAdd( aObjects3, { 0, 08, .T., .T. } )
aAbaCab2 := { aPos[4,2], aPos[4,1], aPos[4,4], aPos[4,3] , 3, 3 }
aPosCab2 := MsObjSize( aAbaCab2, aObjects3 )
//
dyc := (aPos[1,4] - aPos[1,2])
dyc2 := (aPos[1,4] - aPos[1,2]) / 2	// step horizontal
dyc4 := (aPos[1,4] - aPos[1,2]) / 4	// step horizontal
dyc5 := (aPos[1,4] - aPos[1,2]) / 5	// step horizontal
dyc6 := (aPos[1,4] - aPos[1,2]) / 9	// step horizontal
col3_5 := dyc5 * 3
col3_6 := dyc6 * 1.85
  
DBSelectArea("SA1")
DBSetOrder(1)
DBSeek(xFilial("SA1")+VS1->VS1_CLIFAT+VS1->VS1_LOJA)


	// ######################################################
	// # Definicao do  Formulario                           #
	// ######################################################
	DEFINE MSDIALOG oDlgOX004 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0001 OF oMainWnd PIXEL

	oSayCli := TSay():New(aPosCab[1,1]+004,(aPosCab[1,2]),{|| STR0065 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,80,8)
	@ aPosCab[1,1],aPosCab[1,2]+dyc5 MSGET oCodCli VAR VS1->VS1_CLIFAT SIZE dyc6,10 PIXEL OF oDlgOX004 WHEN .f.
	@ aPosCab[1,1],aPosCab[1,2]+col3_6+dyc6  MSGET oLojCli VAR VS1->VS1_LOJA SIZE 40,10 PIXEL OF oDlgOX004 WHEN .f.

	oSayNome := TSay():New(aPosCab[1,1]+004,aPosCab[2,2]+col3_5,{|| STR0066 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)
	@ aPosCab[1,1],aPosCab[1,2]+col3_5+dyc5  MSGET SA1->A1_NOME SIZE dyc5,10 PICTURE "@!" PIXEL OF oDlgOX004  WHEN .f.

	// Linha 1
	oSay01 := TSay():New(aPosCab[2,1],aPosCab[2,2],{|| STR0002 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)
	@ aPosCab[2,1],aPosCab[2,2]+dyc5  MSGET oTipPag VAR cTipPag F3 "SE4" VALID OX004COND(lSoFin) SIZE dyc5,8 PIXEL OF oDlgOX004 WHEN ( !lSoFin .and. nOpc != 2 .and. (lNegPag .or. lAbrePesq) )

	
	// Linha 2
	oSay02 := TSay():New(aPosCab[3,1],aPosCab[3,2],{|| cDesCond },oDlgOX004,,oFnt2,,,,.t.,CLR_BLACK,,dyc2,8)
	//
	oSay001 := TSay():New(aPosCab[4,1],aPosCab[4,2],{|| STR0003 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)
	@ aPosCab[4,1],aPosCab[4,2]+dyc5  MSGET nValPec SIZE dyc5,8 PICTURE "@E 999,999,999.99" WHEN .f. PIXEL OF oDlgOX004
	//
	oSay002 := TSay():New(aPosCab[5,1],aPosCab[5,2],{|| STR0004 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)
	@ aPosCab[5,1],aPosCab[5,2]+dyc5  MSGET nValSer SIZE dyc5,8 PICTURE "@E 999,999,999.99" WHEN .f. PIXEL OF oDlgOX004
	//
	oSay003 := TSay():New(aPosCab[2,1],aPosCab[2,2]+col3_5,{|| STR0005 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)
	@ aPosCab[2,1],aPosCab[2,2]+col3_5+dyc5  MSGET nValFre VALID (IIF(nValFre<0,.f.,OX004FDS())) SIZE dyc5,8 PICTURE "@E 999,999,999.99" PIXEL OF oDlgOX004  WHEN ( !lSoFin .and. nOpc != 2 .and. lNegPag )
	//
	oSay004 := TSay():New(aPosCab[3,1],aPosCab[3,2]+col3_5,{|| STR0006 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)
	@ aPosCab[3,1],aPosCab[3,2]+col3_5+dyc5  MSGET nValDes VALID (IIF(nValDes<0,.f.,OX004FDS())) SIZE dyc5,8 PICTURE "@E 999,999,999.99" PIXEL OF oDlgOX004  WHEN ( !lSoFin .and. nOpc != 2 .and. lNegPag )
	//
	oSay005 := TSay():New(aPosCab[4,1],aPosCab[4,2]+col3_5,{|| STR0007 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)
	@ aPosCab[4,1],aPosCab[4,2]+col3_5+dyc5  MSGET nValSeg VALID (IIF(nValSeg<0,.f.,OX004FDS())) SIZE dyc5,8 PICTURE "@E 999,999,999.99" PIXEL OF oDlgOX004  WHEN ( !lSoFin .and. nOpc != 2 .and. lNegPag )
	//
	oSay006 := TSay():New(aPosCab[5,1],aPosCab[5,2]+col3_5,{|| STR0008 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)
	
	@ aPosCab[5,1],aPosCab[5,2]+col3_5+dyc5  MSGET nValDup SIZE dyc5,8 PICTURE "@E 999,999,999.99" WHEN .f. PIXEL OF oDlgOX004
	
	// Acrescimo e Total com Acrescimo
	oSay006 := TSay():New(aPosCab[6,1],aPosCab[6,2],{|| STR0070 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8) // "Acrésc.Financeiro"
	@ aPosCab[6,1],aPosCab[6,2]+dyc5  MSGET nAcresFin SIZE dyc5,8 PICTURE "@E 999,999,999.99" WHEN .f. PIXEL OF oDlgOX004
	//
	oSay006 := TSay():New(aPosCab[6,1],aPosCab[6,2]+col3_5,{|| STR0071 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8) // "Total c/ Acréscimo"
	@ aPosCab[6,1],aPosCab[6,2]+col3_5+dyc5  MSGET nTtAcrFin SIZE dyc5,8 PICTURE "@E 999,999,999.99" WHEN .f. PIXEL OF oDlgOX004
	
	// Banco
	oSay007 := TSay():New(aPosCab[7,1],aPosCab[7,2],{|| STR0069 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8) // "Banco"
	@ aPosCab[7,1],aPosCab[7,2]+dyc5  MSGET cBanco F3 "BCO" VALID (FG_Seek("SA6","cBanco",1,.f.).or.Empty(cBanco)) SIZE dyc5,8 PIXEL OF oDlgOX004 WHEN ( !lSoFin .and. lNegPag )
	//
	oSay007 := TSay():New(aPosCab[7,1],aPosCab[7,2]+col3_5,{|| STR0009 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)//Saldo
	oSaldo := TGet():New( aPosCab[7,1],aPosCab[7,2]+col3_5+dyc5,{|| cSaldo},oDlgOX004,dyc5,8,"@!",,0,,,.F.,,.T.,,.F.,{||.f.},.F.,.F.,,.F.,.F.,,cSaldo,,,, )

	If cPaisLoc == "BRA"
		oSay001a := TSay():New(aPosCab[8,1],aPosCab[3,2],{|| STR0032 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)
		@ aPosCab[8,1],aPosCab[8,2]+dyc5  MSGET nValST SIZE dyc5,8 PICTURE "@E 999,999,999.99" WHEN .f. PIXEL OF oDlgOX004
	endif

	// Tratamento da integracao com o sigaloja
	if VS1->(FieldPos("VS1_CFNF")) > 0
		DBSelectArea("SX3")
		DBSetOrder(2)
		DBSeek("VS1_CFNF")
		If  X3USO(x3_usado)
			if !Empty(VS1->VS1_CFNF)
				cNFCF := VS1->VS1_CFNF
			end
		end
	end
	
	If Empty(cNFCF)
		If Substr(GetMv("MV_LOJAVEI",,"NNNNNNFFF"),4,1)=="C" // Cupom
			cNFCF := "2"// +STR0010 // Default Cupom
		else
			cNFCF := "1"// +STR0011 // Default NF
		EndIf
	EndIf
	
	//
	oSay008 := TSay():New(aPosCab[8,1],aPosCab[8,2]+col3_5,{|| ( STR0011+" / "+STR0010 ) },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)
	//
	@ aPosCab[8,1],aPosCab[8,2]+col3_5+dyc5 COMBOBOX oCFNF VAR cNFCF ITEMS {"1="+STR0011,"2="+STR0010} SIZE dyc5,8 PIXEL OF oDlgOX004 WHEN ( !lSoFin .and. Substr(GetMv("MV_LOJAVEI",,"NNNNNNFFF"),7,1) <> "F" )
	
	// ############
	// # GETDADOS #
	// ############
	oGetP004 := MsNewGetDados():New(aPos[3,1]+7, aPos[3,2], aPos[3,3] ;
	,aPos[3,4],nOpc,"OX004LOK","OX004TOK",,aAlterCP,0,999,"OX004FOK",,,oDlgOX004,aHeaderCP,aColsCP )

	If !lSoFin
		oGetP004:oBrowse:bDelete       := {|| OX004DLIN(),oGetP004:oBrowse:Refresh() }
	Else
		oGetP004:oBrowse:bDelete       := {|| .t. }
	EndIf

	If !Empty(cTipPag)
		DBSelectArea("SE4")
		DBSetOrder(1)
		dbSeek(xFilial("SE4")+cTipPag)
		If !( SE4->E4_TIPO $ "A.9" ) // Se não for Condição Negociada não deixa alterar a GetDados das Parcelas
			oGetP004:aAlter := oGetP004:oBrowse:aAlter := {}
		EndIf
	EndIf

	// ############
	// # TRAILLER #
	// ############
	dDataIni := ctod("")
	nDias    := 0
	nParc    := 0
	nInter   := 0
	//
	oSay001 := TSay():New(aPosCab2[1,1],aPosCab2[1,2],{|| STR0012 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)
	@ aPosCab2[1,1],aPosCab2[1,2]+dyc5 GET oDtIni VAR  dDataIni SIZE dyc5 * 0.75 ,8 PICTURE "@D" OF oDlgOX004 PIXEL WHEN ( !lSoFin .and. nOpc != 2 .and. SE4->E4_TIPO $ "A.9" .and. lNegPag )
	//
	oSay001 := TSay():New(aPosCab2[2,1],aPosCab2[2,2],{|| STR0013 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)
	@ aPosCab2[2,1],aPosCab2[2,2]+dyc5 GET oDias VAR nDias SIZE dyc5 * 0.75 ,8 PICTURE "@E 99999" OF oDlgOX004 PIXEL WHEN ( !lSoFin .and. nOpc != 2 .and. SE4->E4_TIPO $ "A.9"  .and. lNegPag )
	//
	oSay001 := TSay():New(aPosCab2[1,1],aPosCab2[1,2]+2*dyc5,{|| STR0014 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)
	@ aPosCab2[1,1],aPosCab2[1,2]+3 * dyc5 GET oParc VAR nParc SIZE  dyc5 * 0.75 ,8 PICTURE "@E 999" OF oDlgOX004 PIXEL WHEN ( !lSoFin .and. nOpc != 2 .and. SE4->E4_TIPO $ "A.9" .and. lNegPag )
	//
	oSay001 := TSay():New(aPosCab2[2,1],aPosCab2[2,2]+2*dyc5,{|| STR0015 },oDlgOX004,,oFnt3,,,,.t.,CLR_BLACK,,dyc5,8)
	@ aPosCab2[2,1],aPosCab2[2,2]+3 * dyc5  GET oInter VAR  nInter SIZE dyc5 * 0.75 ,8  PICTURE "@E 999" OF oDlgOX004 PIXEL WHEN ( !lSoFin .and. nOpc != 2 .and. SE4->E4_TIPO  $ "A.9" .and. lNegPag )
	//
	@ aPosCab2[1,1],aPosCab2[1,2]+4* dyc5 BUTTON oBtn1 PROMPT OemToAnsi(STR0016) OF oDlgOX004 SIZE dyc5,8 PIXEL ACTION OX004CALC() WHEN ( !lSoFin .and. nOpc != 2 .and. SE4->E4_TIPO  $ "A.9" .and. lNegPag )
	@ aPosCab2[2,1],aPosCab2[2,2]+4* dyc5 BUTTON oBtn2 PROMPT OemToAnsi(STR0017) OF oDlgOX004 SIZE dyc5,8 PIXEL ACTION OX004DESF() WHEN ( !lSoFin .and. nOpc != 2 .and. SE4->E4_TIPO == "A" .and. lNegPag )
	//
	// Caso exista informacao no tipo de pagamento escolhido deve-se executar a montagem e preenchimento das telas e saldos.
	//
	If lMostrTel
		if !Empty(cTipPag)
			SE4->(DBSetOrder(1))
			SE4->(DBSeek(xFilial("SE4")+cTipPag))
			if Alltrim(SE4->E4_TIPO) <> "9"
				lRet := OX004COND(lSoFin)
			Endif
		endif
		//
		ACTIVATE MSDIALOG oDlgOX004 CENTER ON INIT (EnchoiceBar(oDlgOX004,{|| IIF(OX004FAT(nOpc,lSoFin,aOrcs),oDlgOX004:End(),.f.)},{ || oDlgOX004:End() },, aNewBot))
		//
	Else
	
		lRet := ( OX004COND() .and. OX004FAT(nOpc,lSoFin,aOrcs) )

		ACTIVATE MSDIALOG oDlgOX004 CENTER ON INIT (oDlgOX004:End())
	
	Endif

	SetKey(VK_F8, Nil )

return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX004COND  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Faz a montagem da tela de condicao de pagamento. A rotina de-|##
##|          | ve ser executada quando houver mudanca na condicao de paga-  |##
##|          | mento ou quando houver alteracao no valor total da nota.     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX004COND(lSoFin)
Local nCntFor, nCntFor2 
Local nTTipVS9    := TamSX3("VS9_TIPPAG")[1]
Local cVAI_TIPVEN := ""
Local cCondBase := ""
Local cCondAnt  := ""

Default lSoFin := .f.

Private aTipPag   := {} // Variavel pode ser manipulada no Pontos de Entrada OX004ACP
//###############################################################################
//# Sequencia para zerar condicoes calculadas e deixar apenas as digitadas      #
//# caso a condicao de pagamento esteja em branco                               #
//###############################################################################
If VAI->VAI_NEGPAG == "2" .And. !Empty(VS1->VS1_FORPAG)
	MsgStop(STR0081, STR0019) // Usuário sem Permissão de Alteração da Condição de Pagamento! / Atenção
	Return .f.
EndIf

cDesCond := ""
If !Empty(cTipPag)
	DBSelectArea("SE4")
	DBSetOrder(1)
	If !DBSeek(xFilial("SE4")+cTipPag)
		return .f.
	endif
	cDesCond := SE4->E4_CODIGO + " - " + SE4->E4_DESCRI
EndIf
If Empty(cTipPag) .or. ( SE4->E4_TIPO $ "A.9" ) // Se não preencheu ou for Condição Negociada deixa alterar a GetDados
	oGetP004:aAlter := oGetP004:oBrowse:aAlter := aClone(aAlterCP) // Altera Campos Padroes
Else
	oGetP004:aAlter := oGetP004:oBrowse:aAlter := {}
EndIf

If lSoFin
	Return .t.
Endif

if Alltrim(SE4->E4_TIPO) <> "A" .and. Alltrim(SE4->E4_TIPO) <> "9" .and. lNegPag // usuario tem permissao para Negociar Parcelas
	aIteParc := {}
EndIf

if SE4->(Fieldpos("E4_FORMVR")) <> 0
	if !lMultOrc .and. cTipPag <> M->VS1_FORPAG
		cFormul := FS_FORMULA()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a Condicao esta bloqueada ou nao       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE4->(FieldPos("E4_MSBLQL")) > 0 .AND. !Empty(cTipPag)
			If SE4->E4_MSBLQL=="1"
				Help(" ",1,"REGBLOQ")
	    		Return(.f.)
			Endif	
		EndIf		
		//
		cVAI_TIPVEN := FM_SQL("SELECT VAI_TIPVEN FROM "+RetSQLName("VAI")+" WHERE VAI_FILIAL='"+xFilial("VAI")+"' AND VAI_CODVEN='"+M->VS1_CODVEN+"' AND D_E_L_E_T_=' '")
		//
		Do Case
			Case cVAI_TIPVEN == "1" // Varejo
				if  cFormul <> '"'+M->VS1_FORMUL+'"'
				    nPos1    := At(VS1->VS1_STATUS,GetNewPar("MV_FASEORC","0FX"))
				    nPosicao := At("2",GetNewPar("MV_FASEORC","0FX"))
					if nPos1 > nPosicao .or. nPosicao == 0
					    cTipPag := M->VS1_FORPAG 
						MsgInfo(STR0034)
						oTipPag:Refresh()
			    		Return(.f.)
	        	    Endif
				Endif
			Case cVAI_TIPVEN == "2" // Atacado
				if  cFormul <> '"'+M->VS1_FORMUL+'"' 
				    nPos1    := At(VS1->VS1_STATUS,GetNewPar("MV_FASEORC","0FX"))
				    nPosicao := At("2",GetNewPar("MV_FASEORC","0FX")) 
					if nPos1 > nPosicao .or. nPosicao == 0
					    cTipPag := M->VS1_FORPAG 
						MsgInfo(STR0034)
						oTipPag:Refresh()
			    		Return(.f.)
					Endif
				Endif
			Case cVAI_TIPVEN == "3" // Todos
	            if M->VS1_TIPVEN == "1"
					if cFormul <> '"'+M->VS1_FORMUL+'"'
				   	 	nPos1    := At(VS1->VS1_STATUS,GetNewPar("MV_FASEORC","0FX"))
				    	nPosicao := At("2",GetNewPar("MV_FASEORC","0FX"))
						if nPos1 > nPosicao .or. nPosicao == 0
						    cTipPag := M->VS1_FORPAG 
							MsgInfo(STR0034)
							oTipPag:Refresh()
			    			Return(.f.)
	   		       		Endif          
	    		    Endif                  
				Elseif M->VS1_TIPVEN == "2"
					if cFormul <> '"'+M->VS1_FORMUL+'"' 
				    	nPos1    := At(VS1->VS1_STATUS,GetNewPar("MV_FASEORC","0FX"))
					    nPosicao := At("2",GetNewPar("MV_FASEORC","0FX")) 
						if nPos1 > nPosicao .or. nPosicao == 0
						    cTipPag := M->VS1_FORPAG 
							MsgInfo(STR0034)
							oTipPag:Refresh()
			    			Return(.f.)
						Endif
					Endif
	        	Endif
		EndCase
		//
	Endif
Endif
//#############################################################################
//# Ponto de Entrada para montagem do como pagar                              #
//#############################################################################
if ExistBlock("OX004ACP")
	if !ExecBlock("OX004ACP",.f.,.f.)
		Return(.f.)
	Endif
Endif

if !Empty(cTipPag)
	nValFixo := 0

	nAcresFin := (nValDup - nValFixo) * (SE4->E4_ACRSFIN/100)
	nTtAcrFin := nValDup+nAcresFin
endif

If Len(aIteParc) == 0
	if Empty(cTipPag)
		aColsTmp := {}
		// monta vetor temporario com as parcelas digitadas
		for nCntFor := 1 to Len(oGetP004:aCols)
			if !Empty(oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")])
				if !(oGetP004:aCols[nCntFor,FG_POSVAR("VS9_ENTRAD","aHeaderCP")] $ "N")
					aAdd(aColsTmp,oGetP004:aCols[nCntFor])
				endif
			endif
		next
		// se nao sobrou nenhuma acrescenta um registro vazio na acols
		if Len(aColsTmp) == 0
			oGetP004:aCols := { Array(nUsadoE + 1) }
			oGetP004:aCols[1,nUsadoE+1] := .F.
			For nCntFor:=1 to nUsadoE
				oGetP004:aCols[1,nCntFor]:=CriaVar(aHeaderCP[nCntFor,2])
			Next
		else
			oGetP004:aCols :=aClone(aColsTmp)
		endif
		nTotParc := 0
		// monta a acols e calcula o saldo
		for nCntFor := 1 to Len(oGetP004:aCols)
			if !(oGetP004:aCols[nCntFor,Len(oGetP004:aCols[nCntFor])])
				nTotParc += oGetP004:aCols[nCntFor,FG_POSVAR("VS9_VALPAG","aHeaderCP")]
			endif
		next
		nSaldo := nValDup-nTotParc
		nSaldo += nAcresFin
		cSaldo := Transform(nSaldo,"@E 999,999,999.99")
		oSaldo:CtrlRefresh()
		//
		oGetP004:nat := 1
		oGetP004:obrowse:refresh()
		return .t.
	endif
	//########################################################################################
	//# Quando a condicao de pagamento for NEGOCIADA segrega os digitados antes de preencher #
	//########################################################################################
	aColsTmp := {}
	aIteParc := {}
	if Alltrim(SE4->E4_TIPO)  $ "A.9" .and. ;
		(VS1->(FieldPos("VS1_TIPPAG")) == 0 .or. ;
		(VS1->(FieldPos("VS1_TIPPAG")) > 0 .and. Empty(VS1->VS1_TIPPAG)))
		for nCntFor := 1 to Len(oGetP004:aCols)
			if !Empty(oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")])
				if !(oGetP004:aCols[nCntFor,FG_POSVAR("VS9_ENTRAD","aHeaderCP")] == "N")
					if !(oGetP004:aCols[nCntFor,Len(oGetP004:aCols[nCntFor])])
						nValFixo += oGetP004:aCols[nCntFor,FG_POSVAR("VS9_VALPAG","aHeaderCP")]
					endif
					aAdd(aColsTmp,oGetP004:aCols[nCntFor])
				endif
			endif
		next
	else
		cCondBase := SE4->E4_CODIGO
		cCondAnt  := cCondBase
		If Alltrim(SE4->E4_TIPO) == "A" .and. lVS1_FPGBAS .and. !Empty(VS1->VS1_FPGBAS)
			cCondBase := VS1->VS1_FPGBAS
		EndIf
		//###############################################################################
		//# Monta as parcelas dos valores calculados (aIteParc) e insere na acols       #
		//###############################################################################
		aIteParc := Condicao(nValDup - nValFixo + nAcresFin,cCondBase,nValIpi,DDATABASE,nValST,,,nAcresFin)
		SE4->(DbSeek(xFilial("SE4") + cCondAnt))

		For nCntFor := 1 to Len(aIteParc)
			aAdd(aTipPag,"DP")
		Next
		//
		If lPreDig // PreDigitacao dos Tipos de Pagamentos
			aTipPag := OX0040158_condPreDigitada(aTipPag)
		EndIf
	Endif
Endif
//	
oGetP004:aCols := {}
If len(aIteParc) > 0
	cCartao := "0"
	cCheque := "0"

	for nCntFor := 1 to Len(aIteParc)
		If len(aTipPag) < nCntFor
			aAdd(aTipPag,"DP")

			If lPreDig // PreDigitacao dos Tipos de Pagamentos
				aTipPag := OX0040158_condPreDigitada(aTipPag)
			EndIf

		EndIf

		AADD(oGetP004:aCols,Array(nUsadoE+1))
		oGetP004:aCols[Len(oGetP004:aCols),nUsadoE+1] := .f.
		For nCntFor2:=1 to nUsadoE
			If aHeaderCP[nCntFor2,2]  == "VS9_TIPPAG"
				oGetP004:aCols[Len(oGetP004:aCols),nCntFor2] := aTipPag[nCntFor] // Tipo de Pagamento
			elseif aHeaderCP[nCntFor2,2]  == "VS9_DATPAG"
				oGetP004:aCols[Len(oGetP004:aCols),nCntFor2] := aIteParc[nCntFor,1]
			elseif aHeaderCP[nCntFor2,2]  == "VS9_VALPAG"
				oGetP004:aCols[Len(oGetP004:aCols),nCntFor2] := aIteParc[nCntFor,2]
			elseif aHeaderCP[nCntFor2,2]  == "VS9_DESPAG"
				oGetP004:aCols[Len(oGetP004:aCols),nCntFor2] := POSICIONE("VSA",1,xFilial("VSA")+Left(aTipPag[nCntFor]+space(10),nTTipVS9),"VSA_DESPAG")
			elseif aHeaderCP[nCntFor2,2]  == "VS9_ENTRAD"
				oGetP004:aCols[Len(oGetP004:aCols),nCntFor2] := "N"
			elseif lFormaID .And. aHeaderCP[nCntFor2,2] == "VS9_FORMID"
				If AllTrim(aTipPag[nCntFor]) == "CC"
					cCartao := Soma1(cCartao, 1)
					oGetP004:aCols[Len(oGetP004:aCols), nCntFor2] := cCartao
				ElseIf AllTrim(aTipPag[nCntFor]) == "CH"
					cCheque := Soma1(cCheque, 1)
					oGetP004:aCols[Len(oGetP004:aCols), nCntFor2] := cCheque
				EndIf
			else
				oGetP004:aCols[Len(oGetP004:aCols),nCntFor2]:=CriaVar(aHeaderCP[nCntFor2,2])
			endif
		next
	next
Else
	oGetP004:aCols := { Array(nUsadoE + 1) }
	oGetP004:aCols[1,nUsadoE+1] := .F.
	For nCntFor:=1 to nUsadoE
		oGetP004:aCols[1,nCntFor]:=CriaVar(aHeaderCP[nCntFor,2])
	Next
EndIf

// Caso a condicao nao seja negociada o saldo sera zero
nTotParc := 0
for nCntFor := 1 to Len(oGetP004:aCols)
	if !(oGetP004:aCols[nCntFor,Len(oGetP004:aCols[nCntFor])])
		nTotParc += oGetP004:aCols[nCntFor,FG_POSVAR("VS9_VALPAG","aHeaderCP")]
	endif
next
nSaldo := nValDup-nTotParc
nSaldo += nAcresFin
cSaldo := Transform(nSaldo,"@E 999,999,999.99")
oSaldo:CtrlRefresh()
//
oGetP004:nat := 1
oGetP004:oBrowse:refresh()
//
// PE DEPOIS DO COMO PAGAR
if ExistBlock("OX004DCP")
	if !ExecBlock("OX004DCP",.f.,.f.)
		Return(.f.)
	Endif
Endif

return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX004FOK   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | FieldOK da acols do VS9                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX004FOK()
Local nCntFor
Local cFormaID := ""

DBSelectArea("VAI")
DBSetOrder(4)
DBSeek(xFilial("VAI")+__cUserID)

// se o usuario nao possui permissao de alterar retorna .f.
if !(VAI->VAI_ALTPAR =="1")
	return .f.
endif
//
DBSelectArea("SE4")
DBSetOrder(1)
if !(DBSeek(xFilial("SE4")+cTipPag))
	return .f.
Else
	If SE4->(FieldPos("E4_FORMA")) > 0 .and. VS1->(FieldPos("VS1_TIPPAG")) > 0 
		If !Empty(SE4->E4_FORMA) .and. Alltrim(VS1->VS1_TIPPAG) == Alltrim(SE4->E4_FORMA)
			Return .f.
		Endif
	Endif
endif

// Melhoria para condição de pagamento 
If ExistBlock("OX004SE4")
	If !ExecBlock("OX004SE4",.f.,.f.)
		Return(.f.)
	EndIf
EndIf

//###############################################################################
if readvar()=="M->VS9_TIPPAG"
	//###############################################################################
	// nao permite alterar o tipo de pagamento se a condicao nao for negociada
	If !(Alltrim(SE4->E4_TIPO) $ "A.9")
		return .f. 
	endif
	DBSelectArea("VSA")
	DBSetOrder(1)
	if !dbSeek(xFilial("VSA")+M->VS9_TIPPAG)
		return .f.
	endif
	M->VS9_DESPAG := VSA->VSA_DESPAG
	oGetP004:aCols[oGetP004:nAt,FG_POSVAR("VS9_DESPAG","aHeaderCP")] := VSA->VSA_DESPAG

	// Somar corretamente para exibição na tela
	If lFormaID
		If AllTrim(M->VS9_TIPPAG) == "CC"
			cCartao  := Soma1(cCartao, 1)
			cFormaID := cCartao
		ElseIf AllTrim(M->VS9_TIPPAG) == "CH"
			cCheque  := Soma1(cCheque, 1)
			cFormaID := cCheque
		EndIf
		oGetP004:aCols[oGetP004:nAt, FG_POSVAR("VS9_FORMID", "aHeaderCP")] := cFormaID
	EndIf
endif
//###############################################################################
if readvar()=="M->VS9_PORTAD"
	//###############################################################################
	DBSelectArea("SA6")
	DBSetOrder(1)
	if !dbSeek(xFilial("SA6")+M->VS9_PORTAD)
		return .f.
	endif
	M->VS9_DESPOR := SA6->A6_NOME
	oGetP004:aCols[oGetP004:nAt,FG_POSVAR("VS9_DESPOR","aHeaderCP")] := SA6->A6_NOME
endif
//###############################################################################
if readvar()=="M->VS9_VALPAG"
	// nao permite valor menor ou igual a 0
	If M->VS9_VALPAG <= 0
		return .f.
	endif
	// nao permite alterar o tipo de pagamento se a condicao nao for negociada
	if Empty(oGetP004:aCols[oGetP004:nAt,FG_POSVAR("VS9_TIPPAG","aHeaderCP")])
		MsgStop(STR0038)
		return .f.
	endif
	If !(Alltrim(SE4->E4_TIPO) $ "A.9")
		return .f.
	endif
	// armazena valor anterior
	nTmp := oGetP004:aCols[oGetP004:nAt,FG_POSVAR("VS9_VALPAG","aHeaderCP")]
	oGetP004:aCols[oGetP004:nAt,FG_POSVAR("VS9_VALPAG","aHeaderCP")] := M->VS9_VALPAG
	// armazena o valor total dos titulos apos a modificacao do valor
	nTotParc := 0
	for nCntFor := 1 to Len(oGetP004:aCols)
		if !(oGetP004:aCols[nCntFor,Len(oGetP004:aCols[nCntFor])])
			nTotParc += oGetP004:aCols[nCntFor,FG_POSVAR("VS9_VALPAG","aHeaderCP")]
		endif
	next
	nSaldo := nValDup-nTotParc
	nSaldo += nAcresFin
	cSaldo := Transform(nSaldo,"@E 999,999,999.99")
	oSaldo:CtrlRefresh()
endif
//###############################################################################
if readvar()=="M->VS9_DATPAG"
	//###############################################################################
	// nao permite alterar o tipo de pagamento se a condicao nao for negociada
	If !(Alltrim(SE4->E4_TIPO) $ "A.9")
		return .f.
	endif
endif
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX004LOK   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | LinOk   da acols do VS9                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX004LOK()
Local nCntFor
Local lIDCt := .f.

// pula registros deletados
If oGetP004:aCols[oGetP004:nAt,len(aHeaderCP)+1]
	Return .t.
EndIf

lIDCt := lFormaID .And. AllTrim(oGetP004:aCols[oGetP004:nAt, FG_POSVAR("VS9_TIPPAG", "aHeaderCP")]) $ "CC.CH"

// verifica a obrigatoriedade apenas dos campos citados abaixo
For nCntFor:=1 to Len(aHeaderCP)
	//	If X3Obrigat(aHeaderCP[nCntFor,2])  .and. Empty(oGetP004:aCols[oGetP004:nAt,nCntFor])
	If aHeaderCP[nCntFor,2] $ "VS9_DATPAG,VS9_VALPAG,VS9_TIPPAG" .and. Empty(oGetP004:aCols[oGetP004:nAt,nCntFor])
		Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderCP[nCntFor,2]),4,1)
		Return .f.
	ElseIf lIDCt .And. aHeaderCP[nCntFor,2] $ "VS9_FORMID" .And. Empty(oGetP004:aCols[oGetP004:nAt,nCntFor])
		Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderCP[nCntFor,2]),4,1)
		Return .f.
	EndIf
Next

// Verificar linha duplicada (Tipo de Pagamento e Data iguais)
If Len(oGetP004:aCols) >= 2
	OX0040016_VerificarLinhaDuplicada(oGetP004:nAt)
EndIf
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX004DLIN  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Delecao de linhas da aCols                                   |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX004DLIN()
Local nCntFor
//###############################################################################
//# Nao permite delecao em linha de parcela calculada                           #
//###############################################################################
if oGetP004:aCols[oGetP004:nAt,FG_POSVAR("VS9_ENTRAD","aHeaderCP")]=="N"
	return .f.
endif
//
If oGetP004:aCols[oGetP004:nAt,Len(oGetP004:aCols[oGetP004:nAt])]
	oGetP004:aCols[oGetP004:nAt,Len(oGetP004:aCols[oGetP004:nAt])] := .f.
Else
	oGetP004:aCols[oGetP004:nAt,Len(oGetP004:aCols[oGetP004:nAt])] := .t.
EndIf
// Calcula saldo remanescente apos a delecao
nTotParc := 0
for nCntFor := 1 to Len(oGetP004:aCols)
	if !(oGetP004:aCols[nCntFor,Len(oGetP004:aCols[nCntFor])])
		nTotParc += oGetP004:aCols[nCntFor,FG_POSVAR("VS9_VALPAG","aHeaderCP")]
	endif
next
nSaldo := nValDup-nTotParc
nSaldo += nAcresFin
cSaldo := Transform(nSaldo,"@E 999,999,999.99")
oSaldo:CtrlRefresh()
//
oGetP004:nat := 1
oGetP004:oBrowse:refresh()
//
// Verificar linha duplicada (Tipo de Pagamento e Data iguais)
If Len(oGetP004:aCols) >= 2 .And. !(oGetP004:aCols[oGetP004:nAt,Len(oGetP004:aCols[oGetP004:nAt])])
	OX0040016_VerificarLinhaDuplicada(oGetP004:nAt)
EndIf
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX004FDS   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Atualiza informacoes em caso de alteracao de frete, despesa  |##
##|          | ou seguro.                                                   |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX004FDS()
//
if MaFisFound('NF') .and. !lMultOrc
		MaFisRef("NF_DESPESA",,nValDes)
		MaFisRef("NF_SEGURO",,nValSeg)
		MaFisRef("NF_FRETE",,nValFre)
		nValTot := MaFisRet(,"NF_TOTAL") - MaFisRet(,"NF_DESCZF")
		nValDup := MaFisRet(,"NF_BASEDUP") - MaFisRet(,"NF_DESCZF")
		OX004COND()
endif
// 
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX004REORD | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Reordena o vetor da acols por ordem de data e atualiza tela  |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX004REORD()
aSort(oGetP004:aCols,,,{|x,y| ;
dtos(x[FG_POSVAR("VS9_DATPAG","aHeaderCP")])+x[FG_POSVAR("VS9_TIPPAG","aHeaderCP")]+str(x[FG_POSVAR("VS9_VALPAG","aHeaderCP")]);
< dtos(y[FG_POSVAR("VS9_DATPAG","aHeaderCP")])+y[FG_POSVAR("VS9_TIPPAG","aHeaderCP")]+str(y[FG_POSVAR("VS9_VALPAG","aHeaderCP")])  })
//
oGetP004:oBrowse:refresh()
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX004CALC  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Toma as informacoes digitadas no trailer e calcula as parc.  |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX004CALC()
Local nCntFor, nCntFor2
//#####################################################################################
//# Segrega os valores digitados no vetor aColsTemp para descontar no valor calculado #
//#####################################################################################
aColsTmp := {}
nValFixo := 0
for nCntFor := 1 to Len(oGetP004:aCols)
	if !Empty(oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")])
		if !(oGetP004:aCols[nCntFor,FG_POSVAR("VS9_ENTRAD","aHeaderCP")] == "N")
			if !(oGetP004:aCols[nCntFor,Len(oGetP004:aCols[nCntFor])])
				nValFixo += oGetP004:aCols[nCntFor,FG_POSVAR("VS9_VALPAG","aHeaderCP")]
			endif
			aAdd(aColsTmp,oGetP004:aCols[nCntFor])
		endif
	endif
next
// nao ha calculo a ser realizado se o saldo remansecente for negativo
nValor := nValDup + nAcresFin - nValFixo
if nValor < 0
	MsgInfo(STR0018,STR0019)
	return
end
// validacao dos campos do trailer
If (nParc < 1) .or. (dDataIni < ddatabase)
	MsgInfo(STR0020,STR0019)
	Return
EndIf
//
oGetP004:aCols := aClone(aColsTmp)
//#####################################################################################
//# Calcula as parcelas do Como Pagar e insere na aCols                               #
//#####################################################################################
aIteParc := {}
nValBase := Round(nValor / nParc ,2)
//
For nCntFor := 1 to nParc
	aAdd(aIteParc, {(dDataIni + nDias) + ((nCntFor - 1)*nInter ) , nValBase} )
Next
//
nResto := nValor - (nValBase * nParc)
//
aIteParc[1,2] += nResto
//
for nCntFor := 1 to Len(aIteParc)
	AADD(oGetP004:aCols,Array(nUsadoE+1))
	oGetP004:aCols[Len(oGetP004:aCols),nUsadoE+1] := .f.
	For nCntFor2:=1 to nUsadoE
		If aHeaderCP[nCntFor2,2]  == "VS9_TIPPAG"
			oGetP004:aCols[Len(oGetP004:aCols),nCntFor2] := "DP"
		elseif aHeaderCP[nCntFor2,2]  == "VS9_DATPAG"
			oGetP004:aCols[Len(oGetP004:aCols),nCntFor2] := aIteParc[nCntFor,1]
		elseif aHeaderCP[nCntFor2,2]  == "VS9_VALPAG"
			oGetP004:aCols[Len(oGetP004:aCols),nCntFor2] := aIteParc[nCntFor,2]
		elseif aHeaderCP[nCntFor2,2]  == "VS9_DESPAG"
			oGetP004:aCols[Len(oGetP004:aCols),nCntFor2] := POSICIONE("VSA",1,xFilial("VSA")+VS9->VS9_TIPPAG,"VSA_DESPAG")
		elseif aHeaderCP[nCntFor2,2]  == "VS9_ENTRAD"
			oGetP004:aCols[Len(oGetP004:aCols),nCntFor2] := "N"
		else
			oGetP004:aCols[Len(oGetP004:aCols),nCntFor2] := CriaVar(aHeaderCP[nCntFor2,2])
		endif
	next
next
// Calcula o saldo
nTotParc := 0
for nCntFor := 1 to Len(oGetP004:aCols)
	if !(oGetP004:aCols[nCntFor,Len(oGetP004:aCols[nCntFor])])
		nTotParc += oGetP004:aCols[nCntFor,FG_POSVAR("VS9_VALPAG","aHeaderCP")]
	endif
next
nSaldo := nValDup-nTotParc
nSaldo += nAcresFin
cSaldo := Transform(nSaldo,"@E 999,999,999.99")
oSaldo:CtrlRefresh()
//
oGetP004:nat := 1
oGetP004:oBrowse:refresh()
//
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX004DESF  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Desfaz as parcelas calculadas pelo trailer                   |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX004DESF()
Local nCntFor

//###############################################################################
//# Sequencia para zerar condicoes calculadas e deixar apenas as digitadas      #
//###############################################################################
aColsTmp := {}
for nCntFor := 1 to Len(oGetP004:aCols)
	if !Empty(oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")])
		if !(oGetP004:aCols[nCntFor,FG_POSVAR("VS9_ENTRAD","aHeaderCP")] $ "NA")
			aAdd(aColsTmp,oGetP004:aCols[nCntFor])
		endif
	endif
next
if Len(aColsTmp) == 0
	oGetP004:aCols := { Array(nUsadoE + 1) }
	oGetP004:aCols[1,nUsadoE+1] := .F.
	For nCntFor:=1 to nUsadoE
		oGetP004:aCols[1,nCntFor]:=CriaVar(aHeaderCP[nCntFor,2])
	Next
else
	oGetP004:aCols :=aClone(aColsTmp)
endif
// Calcula o saldo
nTotParc := 0
for nCntFor := 1 to Len(oGetP004:aCols)
	if !(oGetP004:aCols[nCntFor,Len(oGetP004:aCols[nCntFor])])
		nTotParc += oGetP004:aCols[nCntFor,FG_POSVAR("VS9_VALPAG","aHeaderCP")]
	endif
next
nSaldo := nValDup-nTotParc
nSaldo += nAcresFin
cSaldo := Transform(nSaldo,"@E 999,999,999.99")
oSaldo:CtrlRefresh()
//
oGetP004:nat := 1
oGetP004:oBrowse:Refresh()
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |OX004FAT    | Autor |  Luis Delorme         | Data | 31/07/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |Gravacao e Integracao                                         |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX004FAT(nOpc,lSoFin,aOrcs)
Local lRet := .f.
Default lSoFin   := .f. // se .T., só gera Financeiro

// Verificar linha duplicada (Tipo de Pagamento e Data iguais)
If Len(oGetP004:aCols) >= 2
	If !OX0040016_VerificarLinhaDuplicada(0)
		Return .f.
	EndIf
EndIf

If lSoFin // Só Gera Financeiro
	cTipPag  := VS1->VS1_FORPAG
	oProcFAT := MsNewProcess():New({ |lEnd| lRet := OX004GERFIN(VS1->VS1_NUMORC,VS1->VS1_NUMNFI,VS1->VS1_SERNFI) }," ","",.f.)
	oProcFAT:Activate()
	If !lRet
		MsgInfo(STR0067,STR0019) //"Existe(m) inconsistência(s) na Geração dos Titulos. Favor corrigir a(s) pendência(s) para solicitar novamente a Geração do Financeiro."
	Else
		// Exclui os LOGS gerados no momento do faturamento 
		cQuery := "DELETE FROM "+ RetSqlName("VQL")
		cQuery += " WHERE VQL_FILIAL = '"+xFilial("VQL")+"' "
		cQuery += "   AND VQL_AGROUP = 'OFIXX004' "
		cQuery += "   AND VQL_FILORI = '" + VS1->VS1_FILIAL + "' "
		cQuery += "   AND VQL_TIPO = 'VS1-" + VS1->VS1_NUMORC + "'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		TcSqlExec(cQuery)
	Endif
Else
	oProcFAT := MsNewProcess():New({ |lEnd| lRet := OX004FAT2(nOpc,aOrcs) }," ","",.f.)
	oProcFAT:Activate()
Endif
//
return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX004FAT2  | Autor |  Luis Delorme         | Data | 31/07/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |Gravacao e Integracao de Veiculos Normais                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX004FAT2(nOpc,aOrcs)
	
Local nCntFor, nCntFor2
Local cPrefAnt    := ""
Local cAliasSE1   := "SqlSE1"
Local cQuery      := "" 
Local nRecSA1     := 0 
Local nRecVS1     := 0
Local cTipPer     := Left(Alltrim(GetNewPar("MV_TIPPER","TP"))+space(3),Len(SE1->E1_TIPO)) // Tipo de Titulo Provisorio
Local lOkReserv   := .T.
Local cNumIte     := "00"
Local cOrcOrcT    := VS1->VS1_NUMORC
Local cVS9TipPag  := ""
//
Local n_VALPEC    := 0 // Valor de Pecas
Local n_PERDES    := 0 // Percentual de desconto
Local n_VALDES    := 0 // Valor do desconto
Local c1DUPNAT    := GetMV("MV_1DUPNAT")
Local n_VALTOT    := 0 // Valor Total
Local lAltSA1     := .f.  // Controla se Foi alterado o cliente para geracao de Titulo        
Local cBkpNatSA1  := ""
Local cTipCli     := ""
//
Local cMsgSC9 := ""
Local lESTNEG     := (GetMV("MV_ESTNEG") == "S")
//
Local cBkpUserName // Guarda o login atual do usuario
//
Local	nModBkp := nModulo
Local	cModBkp := cModulo

Local	cLOTECT := ""
Local 	cNUMLOT := ""
//
Local lMVLJCNVDA := GetNewPar("MV_LJCNVDA",.f.)
Local cMVTABPAD  := Alltrim(GetNewPar("MV_TABPAD","1"))
//
Local lVS1_GERFIN := ( VS1->(FieldPos("VS1_GERFIN")) > 0 )
Local cAtuGerFin  := ""
Local nVlrTotParc := 0
//
Local cFormaID    := ""
//
Private cSerie    := ""
Private cNumero   := ""
Private lMudouNum := .f.
Private aItePv    := {}
// variaveis usada na nova integração com o Loja (LOJA701)
Private _aCabLJ   := {}
Private _aItemLJ  := {}
Private _aParcLJ  := {}
//
Private aVS9SE1   := {}   // Contem os registros da VS9 quando for condicao negociada
Private nCntSE1   := 0
Private lVS1_VLBRNF := ( VS1->(FieldPos("VS1_VLBRNF")) > 0 )
Private aParcBRNF	:= {}
//
if (nOpc == 2)
	return .t.
endif

if  Type("aOrcs") == "U"
	aOrcs := {VS1->VS1_NUMORC}
endif

// Verifica se existe tipo de pagamento com valor zerado
for nCntFor := 1 to Len(oGetP004:aCols)
	if !Empty(oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")]) .and. oGetP004:aCols[nCntFor,FG_POSVAR("VS9_VALPAG","aHeaderCP")] == 0 .and. !(oGetP004:aCols[nCntFor,len(aHeaderCP)+1])
  		MsgStop(STR0037)
   	Return(.f.)
    Endif	  
Next

//
if cNFCF  == "1" .and. VSA->(FieldPos("VSA_CRIFIN")) > 0
	for nCntFor := 1 to Len(oGetP004:aCols)
		If !(oGetP004:aCols[nCntFor,len(aHeaderCP)+1])
			cVS9TipPag := oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")]
			DBSelectArea("VSA")
			DBSetOrder(1)
			if DBSeek(xFilial("VSA")+cVS9TipPag)
				if VSA->VSA_CRIFIN == "0"
					MsgStop(STR0035 + Alltrim(cVS9TipPag) + STR0036)
					return .f.
				endif
			endif
		endif
	next
endif
//
if nSaldo != 0
	MsgInfo(STR0021,STR0019)
	return .f.
endif
//#############################################################################
//# Ponto de Entrada para verificacoes antes do faturamento                   #
//#############################################################################
if ExistBlock("OXX004AFAT") // O B S O L E T O
	if !ExecBlock("OXX004AFAT",.f.,.f.)
		Return(.f.)
	Endif
Endif

if ExistBlock("OX004AFT")
	if !ExecBlock("OX004AFT",.f.,.f.)
		Return(.f.)
	Endif
Endif

//#############################################################################
//# Verifica se houve alteracao dos titulos e muda a condicao de pagamento    #
//#############################################################################
if !lMultOrc
	DBSelectArea("VS1")
	DBSetOrder(1)
	DBSeek(xFilial("VS1")+cOrcOrcT)
	if VS1->VS1_STATUS == "X" .or. VS1->VS1_STATUS == "C" .or. VS1->VS1_STATUS == "I"
		MsgInfo(STR0022,STR0019)
		return .t.
	endif
else
	DBSelectArea("VS1")
	DBSetOrder(1)
	DBSeek(xFilial("VS1")+aOrcs[1])
endif

nVlrTotParc := 0
nVlrTotParc := nValDup
If FindFunction("FMX_VLDSE4") 
	If !FMX_VLDSE4("",nVlrTotParc) // Verifica Valor SUPERIOR e INFERIOR para utilizar o SE4
		Return .f.
	EndIf
EndIf
nAcresFin := (nVlrTotParc) * (SE4->E4_ACRSFIN/100)
nTtAcrFin := nVlrTotParc+nAcresFin
aIteParc  := Condicao(nVlrTotParc + nAcresFin, SE4->E4_CODIGO, nValIpi, DDATABASE, nValST,,,nAcresFin)
//
OX004REORD()
//
naColsValidas := 0
for nCntFor := 1 to Len(oGetP004:aCols)
	If !(oGetP004:aCols[oGetP004:nAt,len(aHeaderCP)+1])
		naColsValidas := naColsValidas + 1
	endif
next
//
if Alltrim(cTipPag) == "" 
	cTipPag := RetCondVei()
EndIf

DBSelectArea("SE4")
DBSetOrder(1)
DBSeek(xFilial("SE4")+cTipPag)
//
DBSelectArea("SA6")
DBSetOrder(1)
DBSeek(xFilial("SA6")+cBanco)
//
//#######################
//# Gravacao do VS1     #
//#######################
oProcFAT:SetRegua1(3)
oProcFAT:IncRegua1( STR0041)
oProcFAT:SetRegua2(1)
oProcFAT:IncRegua2(STR0042)
//
if !lMultOrc
	DbSelectArea("VS1")
	reclock("VS1",.f.)
	VS1->VS1_VALFRE := nValFre
	VS1->VS1_CODBCO := cBanco
	VS1->VS1_DESACE := nValDes
	VS1->VS1_VTOTNF := nValTot
	VS1->VS1_VALDUP := nValDup
	VS1->VS1_VALSEG := nValSeg
	VS1->VS1_FORPAG := SE4->E4_CODIGO
	msunlock()
endif
//
DBSelectArea("SA1")
DBSetOrder(1)
DBSeek(xFilial("SA1")+VS1->VS1_CLIFAT+VS1->VS1_LOJA)
lPeriodico := .f.
if SA1->A1_COND == VS1->VS1_FORPAG .and. !Empty(SA1->A1_COND)
	lPeriodico := .t.
endif
//
lIntegraLoja := .f.
lGeraPedido := .t.
lGeraNF := .t.
//
if cNFCF == "2"
	lIntegraLoja := .t.
	lGeraPedido := .f.
	lGeraNF := .f.
endif
//
// Tratamento Argentina
//
if cPaisLoc != "BRA"
	if VS1->VS1_TIPVEN  == '1' // minorista
		lIntegraLoja := .t.
		lGeraPedido := .f.
		lGeraNF := .f.
	else
		lIntegraLoja := .f.
		lGeraPedido := .t.
		lGeraNF := .f.
	endif
endif
// ANTES DA INTEGRACAO COM O LOJA
if ExistBlock("OXX004ILOJ") // O B S O L E T O
	ExecBlock("OXX004ILOJ",.f.,.f.)
Endif
if ExistBlock("OX004ILJ")
	ExecBlock("OX004ILJ",.f.,.f.)
Endif

//
DBSelectArea("VS1")
DBSetOrder(1)
DBSeek(xFilial("VS1")+cOrcOrcT)

oProcFAT:IncRegua2(STR0043)
if lIntegraLoja // Cupom

	/////////////////////////////////////////////////////////////////
	// Verificar/Incluir o Tipo do Titulo na tabela 24 e 05 do SX5 //
	/////////////////////////////////////////////////////////////////
	DbSelectArea("SX5")
	dbSetOrder(1)
	For nCntFor := 1 to len(oGetP004:aCols)
		If !dbSeek(xFilial("SX5")+"24"+oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")]) // Tabela 24 - Loja (SL4)
	  	    RecLock("SX5",.t.)
			SX5->X5_FILIAL := xFilial("SX5")
			SX5->X5_TABELA := "24"
	    	SX5->X5_CHAVE  := oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")]
		    SX5->X5_DESCRI := oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")]
	    	MsUnlock()
		EndIf
		If !dbSeek(xFilial("SX5")+"05"+oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")]) // Tabela 05 - Faturamento/Financeiro (SE1/SE2)
	  	    RecLock("SX5",.t.)
			SX5->X5_FILIAL := xFilial("SX5")
			SX5->X5_TABELA := "05"
	    	SX5->X5_CHAVE  := oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")]
		    SX5->X5_DESCRI := oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")]
	    	MsUnlock()
		EndIf
    Next
    
	/////////////////////////////////
	// Gerar Pedido/Venda no Loja  //
	/////////////////////////////////                                               
	for nCntFor := 1 to Len(oGetP004:aCols)
		if !oGetP004:aCols[nCntFor,len(oGetP004:aCols[nCntFor])] .and. !Empty(oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")])

			If lFormaID
				cFormaID := oGetP004:aCols[nCntFor,FG_POSVAR("VS9_FORMID","aHeaderCP")]
			EndIf

			If Empty(cFormaID)
				cFormaID := " "
			EndIf

			aAdd(_aParcLJ,{{"L4_DATA"		, oGetP004:aCols[nCntFor,FG_POSVAR("VS9_DATPAG","aHeaderCP")]	,NIL},;
							{"L4_VALOR"		, oGetP004:aCols[nCntFor,FG_POSVAR("VS9_VALPAG","aHeaderCP")]	,NIL},;
							{"L4_FORMA"		, Padr(oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")],TamSX3("L4_FORMA")[1])	,NIL},;
							{"L4_ADMINIS"	, " "				,NIL},;
							{"L4_FORMAID"	, cFormaID			,NIL},;
							{"L4_MOEDA"		, 0					,NIL}})

		endif
	next

	/////////////////////////////////////////////////////////////////////////////////
	// Carregar Vetores para Integracao SLQ (SL1) / SLR (SL2) / SL4                //
	/////////////////////////////////////////////////////////////////////////////////

	cItem := StrZero(1,Len(SL2->L2_ITEM))
	nVlrLoja := 0

	nVS1_PESOL := 0
	nVS1_PESOB :=  0
	nVS1_VOL1 := 0

	for nCntFor := 1 to Len(aOrcs)
		dbSelectArea("VS1")
		dbSetOrder(1)
		dbSeek(xFilial("VS1")+aOrcs[nCntFor])
		If VS1->(Fieldpos('VS1_PESOB')) > 0 // Se possui o update dos novos campos processa
			nVS1_PESOL += VS1->VS1_PESOL
			nVS1_PESOB += VS1->VS1_PESOB
			nVS1_VOL1 += VS1->VS1_VOLUM1
		EndIf
		dbSelectArea("VS3")
		dbSetOrder(1)
		dbSeek(xFilial("VS3")+aOrcs[nCntFor])

		While VS3->VS3_FILIAL == xFilial("VS3") .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC .and. VS3->(!eof())
			
			FG_Seek("SB1","VS3->VS3_GRUITE+VS3->VS3_CODITE",7,.f.)

			If lVS1_VLBRNF .and. VS1->VS1_VLBRNF == "0" // Nao passar o Valor Bruto para NF/Loja
				n_VALPEC := VS3->VS3_VALPEC - ( VS3->VS3_VALDES / VS3->VS3_QTDITE )
				n_PERDES := 0
				n_VALDES := 0
			Else // Passar Valor Bruto e Desconto para NF/Loja
				n_VALPEC := VS3->VS3_VALPEC
				n_PERDES := VS3->VS3_PERDES
				n_VALDES := VS3->VS3_VALDES
			EndIf

			/////////////////////////////////////////////////////////////////////////////////
			// Atualizar SB0 - Precos por Produto ( Veiculo ) - Tabela OBRIGATORIA no Loja //
			/////////////////////////////////////////////////////////////////////////////////
			If !lMVLJCNVDA // Quando o parametro MV_LJCNVDA for .T. o LOJA utilizara a tabela de preco da totvs (DA0)
				SB0->(DbSetOrder(1))
				SB0->(DbSeek(xFilial("SB0")+SB1->B1_COD))
				RecLock("SB0",!SB0->(Found()))
					SB0->B0_FILIAL := xFilial("SB0")
					SB0->B0_COD    := SB1->B1_COD
					//&("SB0->B0_PRV"+Alltrim(GetNewPar("MV_TABPAD","1"))) := n_VALPEC
					&("SB0->B0_PRV"+cMVTABPAD) := n_VALPEC
				MsUnLock()
			EndIf

			nVlrLoja += VS3->VS3_VALTOT

			lPegaRes := .f.
			if lFezRes .or. ( (VS3->(FieldPos("VS3_RESERV")) > 0) .and. (VS3->VS3_RESERV == '1'))
				lPegaRes := .t.
			endif

			//Pega a classificacao fiscal de acordo com o estado do cliente
			cCFiscal := FG_CLAFIS(VS3->VS3_CODTES)

			SB1->(DbSetOrder(7))
			SB1->(DbSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
			If !Empty(VS3->VS3_LOCAL)
				cLocal := VS3->VS3_LOCAL
			Else
				cLocal := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
			EndIf
			If !Empty(VS3->VS3_LOCALI) .and. !lPegaRes
				cLocali := VS3->VS3_LOCALI
			Else
				SBF->(DbSetOrder(2))
				SBF->(DbSeek(xFilial("SBF")+SB1->B1_COD+IIF(lPegaRes,cResAlm,cLocal)))
				cLocali := SBF->BF_LOCALIZ
			EndIf

			//
			cLOTECT := ""
			cNUMLOT := ""
			if VS3->(FieldPos("VS3_LOTECT")) > 0 .and. !Empty(VS3->VS3_LOTECT)
				cLOTECT := VS3->VS3_LOTECT
				cNUMLOT := VS3->VS3_NUMLOT
			EndIf
			aAdd(_aItemLJ,{{"LR_FILIAL" 	, xFilial("SL2")			,NIL},;
					{ "LR_PRODUTO"	, SB1->B1_COD						,NIL},;
					{ "LR_LOCAL"	, IIF(lPegaRes,cResAlm,cLocal)		,NIL},;
					{ "LR_LOCALIZ"	, cLocali							,NIL},;
					{ "LR_TABELA" 	, "1"								,NIL},;
					{ "LR_ITEM" 	, cItem								,NIL},;
					{ "LR_QUANT"  	, VS3->VS3_QTDITE					,NIL},;
					{ "LR_UM"     	, SB1->B1_UM						,NIL},;
					{ "LR_VRUNIT" 	, n_VALPEC							,NIL},;
					{ "LR_VLRITEM" 	, n_VALPEC*VS3->VS3_QTDITE			,NIL},;
					{ "LR_DESC"   	, 0									,NIL},;
					{ "LR_VALDESC"	, n_VALDES							,NIL},;
					{ "LR_TES"    	, VS3->VS3_CODTES					,NIL},;
					{ "LR_DOC"    	, ""								,NIL},;
					{ "LR_SERIE"  	, ""								,NIL},;
					{ "LR_PDV"    	, "0001"							,NIL},;
					{ "LR_PRCTAB"  	, n_VALPEC							,NIL},;
					{ "LR_DESCPRO"	, 0									,NIL},;
					{ "LR_LOCAL"	, IIF(lPegaRes,cResAlm,cLocal)		,NIL},;
					{ "LR_LOCALIZ"	, cLocali							,NIL},;
					{ "LR_LOTECTL"	, cLOTECT							,NIL},;
					{ "LR_NLOTE"	, cNUMLOT							,NIL},;
					{ "LR_VEND"		, VS1->VS1_CODVEN					,NIL}})

			cItem := Soma1(cItem)
			//
			DbSelectArea("VS3")
			DbSkip()
	
		Enddo
	next

	cTipCli := IIF( ( VS1->(FieldPos("VS1_TIPCLI")) > 0 .And. !Empty(VS1->VS1_TIPCLI) ) , VS1->VS1_TIPCLI , SA1->A1_TIPO )

	_aCabLJ := {  	{"LQ_VEND"		, VS1->VS1_CODVEN	,NIL},;
					{"LQ_COMIS"		, 0					,NIL},;
					{"LQ_CLIENTE"	, SA1->A1_COD		,NIL},;
					{"LQ_LOJA"		, SA1->A1_LOJA		,NIL},;
					{"LQ_TIPOCLI"	, cTipCli			,NIL},;
					{"LQ_NROPCLI"	, "         "		,NIL},;
					{"LQ_DTLIM"		, VS1->VS1_DATVAL	,NIL},;
					{"LQ_DOC"		, ""				,NIL},;
					{"LQ_SERIE"		, ""				,NIL},;
					{"LQ_PDV"		, "0001      "		,NIL},;
					{"LQ_EMISNF"	, dDatabase			,NIL},;
					{"LQ_TIPO"		, "V"				,NIL},;
					{"LQ_DESCNF"	, 0					,NIL},;
					{"LQ_OPERADO"	, xNumCaixa()		,NIL},;
					{"LQ_PARCELA"	, 0					,NIL},;
					{"LQ_FORMPG"	, "R$"				,NIL},;
					{"LQ_EMISSAO"	, dDatabase			,NIL},;
					{"LQ_NUMCFIS"	, ""				,NIL},;
					{"LQ_IMPRIME"	, "1S        "		,NIL},;
					{"LQ_VLRDEBI"	, 0					,NIL},;
					{"LQ_HORA"		, time()			,NIL},;
					{"LQ_NUMMOV"	,"1 "				,NIL},;
					{"LQ_ORIGEM"	, "V"				,NIL},;
					{"LQ_FRETE"		, nValFre			,NIL},;
					{"LQ_SEGURO"	, nValSeg			,NIL},;
					{"LQ_DESPESA"	, nValDes			,NIL},;
					{"LQ_COMIS"		, SA3->A3_COMIS		,NIL},;
					{"LQ_VEND2"		, VS1->VS1_CODVE2	,NIL},;
					{"LQ_VEND3"		, VS1->VS1_CODVE3	,NIL},;
					{"LQ_VEICTIP"	, "1" 				,NIL},;
					{"LQ_VEIPESQ"	, VS1->VS1_NUMORC	,NIL}}

		If SLQ->(Fieldpos("LQ_TRANSP")) > 0				
			aAdd(_aCabLJ, {"LQ_TRANSP"	, VS1->VS1_TRANSP	,NIL})
      Endif
		If SLQ->(Fieldpos("LQ_TPFRET")) > 0				
			aAdd(_aCabLJ, {"LQ_TPFRET"	, VS1->VS1_PGTFRE	,NIL})
      Endif
		If VS1->(Fieldpos('VS1_PESOB')) > 0 // Se possui o update dos novos campos processa
			aAdd(_aCabLJ, {"LQ_PLIQUI"  , nVS1_PESOL  , Nil})
			aAdd(_aCabLJ, {"LQ_PBRUTO"  , nVS1_PESOB  , Nil})
			aAdd(_aCabLJ, {"LQ_VOLUME"  , nVS1_VOL1 , Nil})
			aAdd(_aCabLJ, {"LQ_ESPECIE" , VS1->VS1_ESPEC1 , Nil})
		EndIf
		aAdd(_aCabLJ, {"AUTRESERVA"   , "000001"         , Nil})	
		aAdd(_aCabLJ, {"LQ_MENNOTA"   , VS1-> VS1_MENNOT , Nil})
		

Endif
//#############################################################################
//# Pega numeracao de NF e Serie                                             #
//#############################################################################
oProcFAT:IncRegua2(STR0044)
if lGeraNF
	if cNFCF == "1" // NF
		lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"))
		If !lRet
			Return .f.
		EndIf
	endif
endif
//
DBSelectArea("VS1")
DBSetOrder(1)
DBSeek(xFilial("VS1")+cOrcOrcT)
// PE ANTES DA TRANSACAO DO FATURAMENTO
If ExistBlock("OXX004ATRA") // O B S O L E T O
	ExecBlock("OXX004ATRA",.f.,.f.)
EndIf
//
If ExistBlock("OX004ATR")
	ExecBlock("OX004ATR",.f.,.f.)
EndIf

DBSelectArea("VS1")
DBSetOrder(1)
DBSeek(xFilial("VS1")+cOrcOrcT)
//
//#############################################################################
//# INICIO DO CONTROLE DE TRANSACAO                                           #
//#############################################################################
oProcFAT:IncRegua1(STR0045)
oProcFAT:SetRegua2(3)
oProcFAT:IncRegua2(STR0046)

BEGIN TRANSACTION
//If lMudouNum
// TODO: Como passar para a integracao o novo numero caso seja alterado no SX5NumNota?
//EndIf
if lIntegraLoja // Cupom Fiscal

	if ExistBlock("OX004AOR")
		if !ExecBlock("OX004AOR",.f.,.f.)
			Return(.f.)
		Endif
	Endif
	
	lMsErroAuto := .f.

	////////////////////////////////////////////////
	// Salvar FUNNAME                             //
	////////////////////////////////////////////////
	cSFunName := FunName()
	nSModulo  := nModulo

	SB1->(DbSetOrder(1))
	
	cBkpUserName := cUserName // Armazena o usuario logado atualmente
	////////////////////////////////////////////////
	// Mudar Usuario para Usuario do Caixa        //
	////////////////////////////////////////////////
	cUserName := ALlTrim(GetNewPar("MV_MIL0019",cUserName))
	////////////////////////////////////////////////
	// Mudar para Modulo 12 - Siga Loja           //
	////////////////////////////////////////////////
	nModulo := 12
	////////////////////////////////////////////////
	// Setar FunName LOJA701, para chamar LOJA701 //
	////////////////////////////////////////////////
	SetFunName("LOJA701")
	MSExecAuto({|a,b,c,d,e,f,g,h| LOJA701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},_aCabLJ,_aItemLJ,_aParcLJ)
	////////////////////////////////////////////////
	cUserName := cBkpUserName // Volta o usuario logado ...
	////////////////////////////////////////////////
	// Voltar FunName salvo                       //
	////////////////////////////////////////////////
	SetFunName(cSFunName)
	////////////////////////////////////////////////
	// Voltar Modulo 14 ou 41					  //
	////////////////////////////////////////////////
	nModulo := nSModulo

	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
		RollbackSxe()
		Return .f.
	Else
		If !Empty(SL1->L1_NUM)
			for nCntFor := 1 to Len(aOrcs)
				DBSelectArea("VS1")
				DBSetOrder(1)
				If DBSeek(xFilial("VS1")+aOrcs[nCntFor])
					RecLock("VS1",.f.)
					VS1->VS1_PESQLJ := SL1->L1_NUM // Pedido de Venda no Loja
					MsUnLock()	
				EndIf
			next
			//
		EndIf
	EndIf

endif
//#############################################################################
//# SE FOI ENCONTRADA NF PARA ESSA TRANSACAO HOUVE UM ERRO INESPERADO         #
//#############################################################################
if lGeraNF // NF
	//	set delete off
	DBSelectArea("SF2")
	DBSetOrder(1)                 	
	If GetNewPar("MV_TPNRNFS","1") <> "3"  // Nao trata-se de numeração pelo SD9
		If DBSeek(xFilial("SF2")+cNumero+cSerie) 
			MsgInfo(STR0023,STR0019)
			DisarmTransaction()
			Return .f.
		EndIf
	EndIf
	//	set delete on
endif
//#############################################################################
//# Grava VS9                                                                 #
//#############################################################################
oProcFAT:IncRegua2(STR0047)
DBSelectArea("VS9")
nVS9Seq := 0
for nCntFor := 1 to Len(oGetP004:aCols)
	if !oGetP004:aCols[nCntFor,len(oGetP004:aCols[nCntFor])] .and. !Empty(oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")])
		nVS9Seq++
		reclock("VS9",.t.)
		VS9_FILIAL := xFilial("VS9")
		VS9_NUMIDE := VS1->VS1_NUMORC
		VS9_SEQUEN := STRZERO(nVS9Seq,TamSX3("VS9_SEQUEN")[1])
		for nCntFor2 := 1 to Len(aHeaderCP)
			if aHeaderCP[nCntFor2,10] <> "V"
				&(aHeaderCP[nCntFor2,2]) := oGetP004:aCols[nCntFor,nCntFor2]
			endif
		next
		msunlock()
	endif
next
//################################################################
//# Desreserva dos Itens
//################################################################
oProcFAT:IncRegua2(STR0048)
for nCntFor := 1 to Len(aOrcs)
	DBSelectArea("VS1")
	DBSetOrder(1)
	DBSeek(xFilial("VS1")+aOrcs[nCntFor])
	
	if VS3->(FieldPos("VS3_RESERV")) > 0 .and. VS1->(FieldPos("VS1_RESERV")) > 0
		DBSelectArea("VS3")
		DBSetOrder(1)
		DBSeek(xFilial("VS3")+VS1->VS1_NUMORC)
		while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL+VS3->VS3_NUMORC
			if VS3->VS3_RESERV == "1"
				DBSelectArea("VS1")
				reclock("VS1",.f.)
				VS1->VS1_RESERV := "1"
				msunlock()
				exit
			endif
			DBSkip()
		enddo
	endif	
	
	// PE ANTES DE DESRESERVAR O ITEM
	If ExistBlock("OX04RESITE")       // O B S O L E T O
		lOkReserv := ExecBlock("OX04RESITE",.F.,.F.,{VS1->VS1_NUMORC})
	Endif
	
	If ExistBlock("OX004RIT")
		lOkReserv := ExecBlock("OX004RIT",.F.,.F.,{VS1->VS1_NUMORC})
	Endif
	
	//
	DBSelectArea("VS1")
	DBSetOrder(1)
	DBSeek(xFilial("VS1")+aOrcs[nCntFor])
	//
	If lOkReserv .and. !lIntegraLoja
		if VS1->(FieldPos("VS1_RESERV")) > 0 .and. VS1->VS1_RESERV == "1"
			cRetRes := OX001RESITE(VS1->VS1_NUMORC,.f., {"9999"})
			if Empty(cRetRes)
				DisarmTransaction()
				Return .f.
			EndIf
		elseif At("R",OI001GETFASE(VS1->VS1_NUMORC)) != 0 .or. At("T",OI001GETFASE(VS1->VS1_NUMORC)) != 0
			cRetRes := OX001RESITE(VS1->VS1_NUMORC,.f.)
			if Empty(cRetRes)
				DisarmTransaction()
				Return .f.
			EndIf
		endif
	Endif
next
//################################################################
//# Se gera Pedido de Venda, verifica se tem estoque disponivel  #
//# para atender o pedido                                        #
//################################################################
oProcFAT:IncRegua2(STR0049)

if lGeraPedido .and. GetMV("MV_ESTNEG") <> "S"
	if OFXFA0034_AlgumaPecaSemSaldo(aOrcs, .t.)
		DisarmTransaction()
		Return .f.
	endif
EndIf

//################################################################
//# Gravacao do Pedido de Venda                                  #
//################################################################
//
oProcFAT:IncRegua2(STR0050)
if lGeraPedido // NF
	// PE ANTES DA MONTAGEM DO PEDIDO DE VENDA
	if ExistBlock("OXX004AMPV") // O B S O L E T O
		if !ExecBlock("OXX004AMPV",.f.,.f.)
			DisarmTransaction()
			Return(.f.)
		Endif
	Endif
	
	if ExistBlock("OX004AMP")
		if !ExecBlock("OX004AMP",.f.,.f.)
			DisarmTransaction()
			Return(.f.)
		Endif
	Endif


	nVS1_DESACE := 0
	nVS1_VALFRE := 0
	nVS1_VALSEG := 0

	nVS1_PESOL := 0
	nVS1_PESOB :=  0
	nVS1_VOL1 := 0
	nVS1_VOL2 := 0
	nVS1_VOL3 := 0
	nVS1_VOL4 := 0
		
	for nCntFor := 1 to Len(aOrcs)
		dbSelectArea("VS1")
		dbSetOrder(1)
		dbSeek(xFilial("VS1")+aOrcs[nCntFor])

		nVS1_DESACE += VS1->VS1_DESACE
		nVS1_VALFRE += VS1->VS1_VALFRE
		nVS1_VALSEG += VS1->VS1_VALSEG

		If VS1->(Fieldpos('VS1_PESOB')) > 0 // Se possui o update dos novos campos processa
			nVS1_PESOL += VS1->VS1_PESOL
			nVS1_PESOB += VS1->VS1_PESOB
			nVS1_VOL1 += VS1->VS1_VOLUM1
			nVS1_VOL2 += VS1->VS1_VOLUM2
			nVS1_VOL3 += VS1->VS1_VOLUM3
			nVS1_VOL4 += VS1->VS1_VOLUM4
		EndIf

		DBSelectArea("VS3")
		DBSetOrder(1)
		DBSeek(xFilial("VS3")+VS1->VS1_NUMORC)
		while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL+VS3->VS3_NUMORC
			//
			aIteTempPV := {}
			cLocaliz := SB1->B1_LOCALIZ
			//
			DBSelectArea("SB1")
			DBSetOrder(7)
			DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE)
			//
			cNumIte := SOMA1(cNumIte)
			//
			If lVS1_VLBRNF .and. VS1->VS1_VLBRNF == "0" // Nao passar o Valor Bruto para NF/Loja
				n_VALPEC := VS3->VS3_VALPEC - ( VS3->VS3_VALDES / VS3->VS3_QTDITE )
				n_VALDES := 0
				n_VALTOT := VS3->VS3_VALTOT
			Else // Passar Valor Bruto e Desconto para NF/Loja
				n_VALPEC := VS3->VS3_VALPEC
				n_VALDES := VS3->VS3_VALDES
				n_VALTOT := VS3->VS3_VALTOT+VS3->VS3_VALDES
			EndIf
			//
			aAdd(aIteTempPV,{"C6_ITEM"   ,cNumIte			       			,Nil})
			aAdd(aIteTempPV,{"C6_PRODUTO",SB1->B1_COD  						,Nil})
			aAdd(aIteTempPV,{"C6_TES"    ,VS3->VS3_CODTES  					,Nil})
			aAdd(aIteTempPV,{"C6_ENTREG" ,dDataBase  						,Nil})
			aAdd(aIteTempPV,{"C6_UM"     ,SB1->B1_UM           				,Nil})
			aAdd(aIteTempPV,{"C6_LOCAL"  ,VS3->VS3_LOCAL					,Nil})
			aAdd(aIteTempPV,{"C6_QTDVEN" ,VS3->VS3_QTDITE					,Nil})
			aAdd(aIteTempPV,{"C6_QTDLIB" ,0              		,Nil})
			aAdd(aIteTempPV,{"C6_PRUNIT" ,n_VALPEC							,Nil})
			aAdd(aIteTempPV,{"C6_PRCVEN" ,n_VALPEC							,Nil})
			aAdd(aIteTempPV,{"C6_VALOR"  ,n_VALTOT							,Nil})
			aAdd(aIteTempPV,{"C6_VALDESC",n_VALDES		  					,Nil})
			// Ticket: 1932063
			// ISSUE: MMIL-2426
			// O TES está sendo enviado novamente pois na base o cliente ocorria uma falha. O conteudo do TES na aCols (MATA410)
			// ficava com conteúdo VAZIO.
			// O problema nao foi reproduzido em base teste, mas verificamos que passando o TES novamente a falha não ocorria novamente
			// A mensagem de HELP disparada era A410VZ.
			aAdd(aIteTempPV,{"C6_TES"    ,VS3->VS3_CODTES  					,Nil})
			if VS3->(FieldPos("VS3_SITTRI")) > 0
				aAdd(aIteTempPV,{"C6_CLASFIS",VS3->VS3_SITTRI  				,Nil})
			endif
			aAdd(aIteTempPV,{"C6_CLI"    ,VS1->VS1_CLIFAT      				,Nil})
			aAdd(aIteTempPV,{"C6_LOJA"   ,VS1->VS1_LOJA  				    ,Nil})
			if VS3->(FieldPos("VS3_LOTECT")) > 0 .and. !Empty(VS3->VS3_LOTECT)
				aAdd(aIteTempPV,{"C6_LOTECTL" ,VS3->VS3_LOTECT         		,Nil})
				aAdd(aIteTempPV,{"C6_NUMLOTE" ,VS3->VS3_NUMLOT         		,Nil})			
			endif
			if VS3->(FieldPos("VS3_LOCALI")) > 0 .and. !Empty(VS3->VS3_LOCALI)
				aAdd(aIteTempPV,{"C6_LOCALIZ" ,VS3->VS3_LOCALI         		,Nil})
			endif                                       
			if VS1->VS1_TIPORC == "1"
				If SC6->(FieldPos("C6_CC"))>0 .and. VS3->(FieldPos("VS3_CENCUS"))>0 
					aAdd(aIteTempPV,{"C6_CC" , VS3->VS3_CENCUS , Nil})
				Endif

				If SC6->(FieldPos("C6_CONTA"))>0 .and. VS3->(FieldPos("VS3_CONTA"))>0
					aAdd(aIteTempPV,{"C6_CONTA" , VS3->VS3_CONTA , Nil})
				Endif
			
				If SC6->(FieldPos("C6_ITEMCTA"))>0 .and. VS3->(FieldPos("VS3_ITEMCT"))>0
					aAdd(aIteTempPV,{"C6_ITEMCTA" , VS3->VS3_ITEMCT , Nil})
				Endif

				If SC6->(FieldPos("C6_CLVL"))>0 .and. VS3->(FieldPos("VS3_CLVL"))>0
					aAdd(aIteTempPV,{"C6_CLVL" , VS3->VS3_CLVL , Nil})
				Endif
			Endif
			If SC6->(FieldPos("C6_FCICOD"))>0 .and. (VS3->(FieldPos("VS3_FCICOD"))>0 .and. !Empty(VS3->VS3_FCICOD) )
				aAdd(aIteTempPV,{"C6_FCICOD" , VS3->VS3_FCICOD , Nil})
			Endif                
			
			If SC6->(FieldPos("C6_NUMPCOM"))>0 .and. (VS3->(FieldPos("VS3_PEDXML"))>0 .and. !Empty(VS3->VS3_PEDXML) )
				aAdd(aIteTempPV,{"C6_NUMPCOM" , VS3->VS3_PEDXML , Nil})
			Endif                

			If SC6->(FieldPos("C6_ITEMPC"))>0 .and. (VS3->(FieldPos("VS3_ITEXML"))>0 .and. !Empty(VS3->VS3_ITEXML) )
				aAdd(aIteTempPV,{"C6_ITEMPC" , VS3->VS3_ITEXML , Nil})
			Endif

			// NT 2021.004 v1.21 - Alecsandre Ferreira
			if SC6->(FieldPos("C6_OBSCONT")) > 0 .AND. (VS3->(FieldPos("VS3_OBSCON")) > 0 .and. !Empty(VS3->VS3_OBSCON) )
				aAdd(aIteTempPV,{"C6_OBSCONT", VS3->VS3_OBSCON, Nil})
			endif          

			if SC6->(FieldPos("C6_OBSCCMP")) > 0 .AND. (VS3->(FieldPos("VS3_OBSCCM")) > 0 .and. !Empty(VS3->VS3_OBSCCM) )
				aAdd(aIteTempPV,{"C6_OBSCCMP", VS3->VS3_OBSCCM, Nil})
			endif         

			if SC6->(FieldPos("C6_OBSFISC")) > 0 .AND. (VS3->(FieldPos("VS3_OBSFIS")) > 0 .and. !Empty(VS3->VS3_OBSFIS) )
				aAdd(aIteTempPV,{"C6_OBSFISC", VS3->VS3_OBSFIS, Nil})
			endif         

			if SC6->(FieldPos("C6_OBSFCMP")) > 0 .AND. (VS3->(FieldPos("VS3_OBSFCP")) > 0 .and. !Empty(VS3->VS3_OBSFCP) )
				aAdd(aIteTempPV,{"C6_OBSFCMP", VS3->VS3_OBSFCP, Nil})
			endif
			// NT 2021.004 v1.21        
		
			If ( ExistBlock("OXX004AIPV") )
				aIteTempPV := ExecBlock("OXX004AIPV",.f.,.f.,{aIteTempPV})
			EndIf
			// CUSTOMIZACAO DO ITEM DO PEDIDO DE VENDA MATA410
			If ( ExistBlock("OX004AIP") )
				aIteTempPV := ExecBlock("OX004AIP",.f.,.f.,{aIteTempPV})
			EndIf
			//
			aAdd(aItePv,aClone(aIteTempPV))
			//
			DBSelectArea("VS3")
			DBSkip()
		enddo
	next
	//
	aCabPV := {}
	//
	aVendedores := {{VS1->VS1_CODVEN,0},{VS1->VS1_CODVE2,0},{VS1->VS1_CODVE3,0},{VS1->VS1_CODVE4,0},{VS1->VS1_CODVE5,0}}
	For nCntFor := 1 to 5
		DBSelectArea("SA3")
		DBSetOrder(1)
		DBSeek(xFilial("SA3")+aVendedores[nCntFor,1])
		aVendedores[nCntFor,2] := SA3->A3_COMIS
	next
	aAdd(aCabPV,{"C5_TIPO"   ,"N"				,Nil})
	aAdd(aCabPV,{"C5_CLIENTE",VS1->VS1_CLIFAT  	,Nil})
	aAdd(aCabPV,{"C5_LOJACLI",VS1->VS1_LOJA  	,Nil})
	if ( VS1->(FieldPos("VS1_TIPCLI")) > 0 .And. !Empty(VS1->VS1_TIPCLI) )
		aAdd(aCabPV,{"C5_TIPOCLI",VS1->VS1_TIPCLI ,Nil})
	Else
		aAdd(aCabPV,{"C5_TIPOCLI",SA1->A1_TIPO		 ,Nil})
	endif
	aAdd(aCabPV,{"C5_TRANSP" ,VS1->VS1_TRANSP  	,Nil})
	//
	aAdd(aCabPV,{"C5_CONDPAG",cTipPag			,Nil})
	//
	aAdd(aCabPV,{"C5_VEND1"  ,aVendedores[1,1]	,Nil})
	aAdd(aCabPV,{"C5_COMIS1" ,aVendedores[1,2] 	,Nil})
	aAdd(aCabPV,{"C5_VEND2"  ,aVendedores[2,1]	,Nil})
	aAdd(aCabPV,{"C5_COMIS2" ,aVendedores[2,2]	,Nil})
	aAdd(aCabPV,{"C5_VEND3"  ,aVendedores[3,1]	,Nil})
	aAdd(aCabPV,{"C5_COMIS3" ,aVendedores[3,2]	,Nil})
	aAdd(aCabPV,{"C5_VEND4"  ,aVendedores[4,1]	,Nil})
	aAdd(aCabPV,{"C5_COMIS4" ,aVendedores[4,2]	,Nil})
	aAdd(aCabPV,{"C5_VEND5"  ,aVendedores[5,1]	,Nil})
	aAdd(aCabPV,{"C5_COMIS5" ,aVendedores[5,2]	,Nil})
	aAdd(aCabPV,{"C5_EMISSAO",ddatabase         ,Nil})
	if VS1->(FieldPos("VS1_MENNOT")) > 0
		aAdd(aCabPV,{"C5_MENNOTA",VS1->VS1_MENNOT ,Nil})
		aAdd(aCabPV,{"C5_MENPAD" ,VS1->VS1_MENPAD ,Nil})
	endif
	aAdd(aCabPV,{"C5_EMISSAO",ddatabase         ,Nil})
	aAdd(aCabPV,{"C5_MOEDA"  , 1                ,Nil}) // Moeda
	If !Empty(cBanco) // Se preencheu o Banco na TELA, passar para integração - Faturamento Agrupado não passava
		aAdd(aCabPV,{"C5_BANCO"  ,cBanco   ,Nil})
	Else
		aAdd(aCabPV,{"C5_BANCO"  ,VS1->VS1_CODBCO   ,Nil})
	EndIf
	aadd(aCabPV,{"C5_DESPESA",nVS1_DESACE   ,Nil}) // Despesas na Venda a Integrar na NF
	aadd(aCabPV,{"C5_FRETE"  ,nVS1_VALFRE   ,Nil}) // Despesas na Venda a Integrar na NF
	aadd(aCabPV,{"C5_SEGURO" ,nVS1_VALSEG   ,Nil}) // Despesas na Venda a Integrar na NF
	aadd(aCabPV,{"C5_TPFRETE",VS1->VS1_PGTFRE   ,Nil})

	If VS1->(Fieldpos('VS1_PESOB')) > 0 // Se possui o update dos novos campos processa
		aAdd(aCabPV, {"C5_PESOL"  , nVS1_PESOL  , Nil})
		aAdd(aCabPV, {"C5_PBRUTO" , nVS1_PESOB  , Nil})
		aAdd(aCabPV, {"C5_VEICULO", VS1->VS1_VEICUL , Nil})
		aAdd(aCabPV, {"C5_VOLUME1", nVS1_VOL1 , Nil})
		aAdd(aCabPV, {"C5_VOLUME2", nVS1_VOL2 , Nil})
		aAdd(aCabPV, {"C5_VOLUME3", nVS1_VOL3 , Nil})
		aAdd(aCabPV, {"C5_VOLUME4", nVS1_VOL4 , Nil})
		aAdd(aCabPV, {"C5_ESPECI1", VS1->VS1_ESPEC1 , Nil})
		aAdd(aCabPV, {"C5_ESPECI2", VS1->VS1_ESPEC2 , Nil})
		aAdd(aCabPV, {"C5_ESPECI3", VS1->VS1_ESPEC3 , Nil})
		aAdd(aCabPV, {"C5_ESPECI4", VS1->VS1_ESPEC4 , Nil})
	EndIf
	If SC5->(FieldPos("C5_NATUREZ")) <> 0
		aAdd(aCabPV,{"C5_NATUREZ" , VS1->VS1_NATURE , Nil } ) // Natureza no Pedido
	EndIf
	If SC5->(FieldPos("C5_INDPRES")) > 0 .and. ( VS1->(FieldPos("VS1_INDPRE")) > 0 .and. !Empty(VS1->VS1_INDPRE) )
		aAdd(aCabPV, {"C5_INDPRES",  VS1->VS1_INDPRE , Nil}) //Presenca do Comprador
	Endif
	If SC5->(FieldPos("C5_NTEMPEN")) > 0 .And. ( VS1->(FieldPos("VS1_NTEMPE")) > 0 .and. !Empty(VS1->VS1_NTEMPE) )
		aAdd(aCabPV, {"C5_NTEMPEN",  VS1->VS1_NTEMPE , Nil}) // Nt Empenho
	EndIf
	If SC5->(FieldPos("C5_CODA1U")) > 0 .and. ( VS1->(FieldPos("VS1_CODA1U")) > 0 .and. !Empty(VS1->VS1_CODA1U) )
		aAdd(aCabPV, {"C5_CODA1U",  VS1->VS1_CODA1U , Nil})
	Endif

	// #################################################
	// # CHAMADA DO MATA410 COM OS DADOS DA INTEGRACAO #
	// #################################################
	lMsErroAuto := .f.
	// PE ANTES DA GERACAO DO PEDIDO DE VENDA
	if ExistBlock("OXX004APV")
		if !ExecBlock("OXX004APV",.f.,.f.)
			Return(.f.)
		Endif
	Endif
	if ExistBlock("OX004APV")
		if !ExecBlock("OX004APV",.f.,.f.)
			Return(.f.)
		Endif
	Endif
	//
	DBSelectArea("VS1")
	DBSetOrder(1)
	DBSeek(xFilial("VS1")+cOrcOrcT)
   //
	aTitSE1 := {}
	cCondVS9 := ""
	OX004SC5NEG(@cCondVS9) // Carrega negociacao quando condicao de pagamento do tipo 9
	//
	MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItePv,3)
	//
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
		Return .f.
	EndIf
	//
	DBSelectArea("VS1")
	DBSetOrder(1)
	DBSeek(xFilial("VS1")+cOrcOrcT)
	//
	if VS1->(FieldPos("C5_NUMORC")) > 0
		reclock("SC5",.f.)
		SC5->C5_NUMORC = VS1->VS1_NUMORC
		msunlock()
	endif
	
	lCredito := .t.
	lEstoque := .t.
	lLiber   := .t.
	lTransf  := .f.

	SC9->(dbSetOrder(1))
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM + "01"))
	While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == SC5->C5_NUM

		If !SC9->(dbSeek(xFilial("SC9")+SC5->C5_NUM+SC6->C6_ITEM))
			nQtdLib := SC6->C6_QTDVEN
			nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,(!lESTNEG),lLiber,lTransf)
		EndIf

		SC6->(dbSkip())
	Enddo
endif
//
//
//################################################################
//# Gera F2/D2, Atualiza Estoque, Financeiro, Contabilidade      #
//################################################################

if lGeraNF
	cNumPed := SC5->C5_NUM
	//
	// Contem os titulos gerados ...
	// Utilizado para atualizar o E1_TITPAI no final da geracao da NF
	aTitSE1 := {}
	//
	cCondVS9 := ""
	OX004SC5NEG(@cCondVS9) // Carrega negociacao quando condicao de pagamento do tipo 9
	//
	aPvlNfs := {}
	SB1->(dbSetOrder(1))
	SC5->(dbSetOrder(1))
	SC6->(dbSetOrder(1))
	SB5->(dbSetOrder(1))
	SB2->(dbSetOrder(1))
	SF4->(dbSetOrder(1))
	SE4->(dbSetOrder(1))
	SC9->(dbSeek(xFilial("SC9") + cNumPed + "01"))
	While !SC9->(Eof()) .and. xFilial("SC9") == SC9->C9_FILIAL .and. SC9->C9_PEDIDO == cNumPed
		If Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST)
			SC5->(dbSeek( xFilial("SC5") + SC9->C9_PEDIDO ))
			SC6->(dbSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM ))
			SB1->(dbSeek( xFilial("SB1") + SC9->C9_PRODUTO ))
			SB2->(dbSeek( xFilial("SB2") + SB1->B1_COD ))
			SB5->(dbSeek( xFilial("SB5") + SB1->B1_COD ))
			SF4->(MsSeek( xFilial("SF4") + SC6->C6_TES ))
			SE4->(MsSeek( xFilial("SE4") + SC5->C5_CONDPAG ))
			nPrcVen := SC9->C9_PRCVEN
			If ( SC5->C5_MOEDA <> 1 )
				nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
			EndIf
			Aadd(aPvlNfs,{ SC9->C9_PEDIDO,;
				SC9->C9_ITEM,;
				SC9->C9_SEQUEN,;
				SC9->C9_QTDLIB,;
				nPrcVen,;
				SC9->C9_PRODUTO,;
				.f.,;
				SC9->(RecNo()),;
				SC5->(RecNo()),;
				SC6->(RecNo()),;
				SE4->(RecNo()),;
				SB1->(RecNo()),;
				SB2->(RecNo()),;
				SF4->(RecNo()) } )
		Else
			If !Empty(SC9->C9_BLCRED)
				cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLCRED"))+": "+SC9->C9_BLCRED+CHR(13)+CHR(10)
			EndIf
			If !Empty(SC9->C9_BLEST)
				cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLEST"))+": "+SC9->C9_BLEST+CHR(13)+CHR(10)
			EndIf
		EndIf
		SC9->(dbSkip())
	Enddo
	//
	If !Empty(cMsgSC9)
		DisarmTransaction()
		MsgStop(STR0039+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsgSC9,STR0019) // Existem um ou mais item do pedido de venda (SC5) que não foram liberado! / Atencao
		Return(.f.)
	EndIf
	If len(aPvlNfs) == 0 .and. !FGX_SC5BLQ(cNumPed,.t.) // Verifica SC5 bloqueado
		DisarmTransaction()
		RollbackSxe()
		Return(.f.)
	EndIf
	//
	DBSelectArea("VS1")
	DBSetOrder(1)
	DBSeek(xFilial("VS1")+cOrcOrcT)
	//
	
	If Len(aPvlNfs) > 0
		If nVerParFat == 1 // NAO mostrar os Parametros do Faturamento no momento da geracao da NF
			PERGUNTE("MT460A",.f.)
		Else // nVerParFat == 2 // Mostrar os Parametros do Faturamento no momento da geracao da NF
			While .t.
				If PERGUNTE("MT460A",.t.)
					Exit
				EndIf
			EndDo
		EndIf
		// Altera natureza para gerar o titulo na natureza correta ...
		if !(Alltrim(SE4->E4_TIPO) $ "A.9")
			if !Empty(VS1->VS1_NATURE)
				If c1DUPNAT == "SA1->A1_NATUREZ" .and. SA1->A1_NATUREZ <> VS1->VS1_NATURE
					lAltSA1 := .t.
					cBkpNatSA1 := SA1->A1_NATUREZ
					RecLock("SA1",.f.)
					SA1->A1_NATUREZ := VS1->VS1_NATURE
					SA1->(MsUnLock())
				EndIf
   				nRecSA1 := SA1->(Recno())
	        Endif
        Endif
        oProcFAT:IncRegua2(STR0051)    

		
		nModBkp := nModulo
		cModBkp := cModulo
		nModulo := 5
		cModulo := "FAT"
		cNota := MaPvlNfs(aPvlNfs,;         //1
							   cSerie,;				//2
							   (mv_par01 == 1),;	//3
							   (mv_par02 == 1),; //4
							   (mv_par03 == 1),; //5
							   (mv_par04 == 1),; //6
							   .F.,;					//7
							    0,;					//8
							    0,; 					//9
							   .T.,;					//10
							   .F.,;					//11
								,;          		//12
								{ |x| OX100VS9E1(x,cPrefBal,(SE4->E4_TIPO == "9"),lPeriodico,cTipPer) } ,;  //13
								,;          		//14
								,;          		//15
								,)          		//16
								
		nModulo := nModBkp
		cModulo := cModBkp
		If lMsErroauto
			DisarmTransaction()
			Return(.f.)
		EndIf
	EndIf
	//                     
	oProcFAT:IncRegua2(STR0052)                     
	cNota := PadR(cNota,TAMSX3("F2_DOC")[1])

	dbSelectArea("SF2")
	dbSetOrder(1)
	dbSeek(xFilial("SF2")+cNota+cSerie)
	cCliFatura := SF2->F2_CLIENTE
	cLojaFatura := SF2->F2_LOJA
	//
	DBSelectArea("SF2")
	reclock("SF2",.f.)
	cPrefAnt := SF2->F2_PREFIXO
	SF2->F2_PREFORI := cPrefBAL
	cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
	SF2->F2_PREFIXO := cPrefNF
	msunlock()
	
	SE1->(DbSetorder(1))
	
	If !Empty(SF2->F2_DUPL)
		cQuery    := "SELECT SE1.R_E_C_N_O_ RECSE1 "
		cQuery    += "FROM "+RetSqlName("SE1")+" SE1 "
		cQuery    += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND SE1.E1_PREFIXO = '"+cPrefAnt+"' AND SE1.E1_NUM = '"+SF2->F2_DUPL+"' AND  "
		cQuery    += "SE1.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSE1, .F., .T. )
		While ( cAliasSE1 )->(!Eof())
			DbSelectArea("SE1")
			DbGoTo(( cAliasSE1 )->RECSE1)
			RecLock("SE1",.f.)
				SE1->E1_PREFIXO := SF2->F2_PREFIXO
				SE1->E1_PREFORI := SF2->F2_PREFORI
				if lPeriodico
					SE1->E1_TIPO := cTipPer // MV_TIPPER - Tipo de Titulo Provisorio
				endif
			msunlock()
			( cAliasSE1 )->(DbSkip())
		Enddo
		( cAliasSE1 )->( dbCloseArea() )
	EndIf

	// Acerta E1_TITPAI para titulos gerados por condicao de pagamento padrao ...
	If FindFunction("OX100E1TITPAI")
		If !OX100E1TITPAI(aTitSE1)
			DisarmTransaction()
			MostraErro()
			Return(.f.)
		EndIf
	EndIf
	//
EndIf
//################################################################
//# Fim da Emissao da Nota Fiscal de Saida                       #
//################################################################
oProcFAT:IncRegua2(STR0054)

DBSelectArea("VS1")
DBSetOrder(1)
DBSeek(xFilial("VS1")+cOrcOrcT)

DBSelectArea("VS3")
DBSetOrder(1)
DBSeek(xFilial("VS3")+VS1->VS1_NUMORC)
//
DbSelectArea("SF4")
DbSetOrder(1)
dbSeek(xFilial("SF4") + VS3->VS3_CODTES)

DBSelectArea("SE4")
DBSetOrder(1)
DBSeek(xFilial("SE4")+cTipPag)
cAtuGerFin := ""
If SF4->F4_DUPLIC == "S"
	If Alltrim(SE4->E4_TIPO)=="A"
		cAtuGerFin := "0"
	Else
		cAtuGerFin := "1"
	Endif
Endif

//
//#############################################################################
//# Gravacao dos Titulos a receber                                            #
//#############################################################################

for nCntFor := 1 to Len(aOrcs)
	//
	DBSelectArea("VS1")
	DBSetOrder(1)
	DBSeek(xFilial("VS1")+aOrcs[nCntFor])
	//
	cVS1StAnt := VS1->VS1_STATUS
	//
	reclock("VS1",.f.)
	VS1->VS1_STATUS := "X"
	VS1->VS1_FORPAG := cTipPag // Gravar o VS1_FORPAG em todos os Orcamentos
	VS1->VS1_CFNF   := cNFCF
	if lGeraPedido
		VS1->VS1_NUMPED := SC5->C5_NUM
	endif
	if lGeraNF // NF
		VS1->VS1_NUMNFI := cNota
		VS1->VS1_SERNFI := cSerie
		if VS1->(FieldPos("VS1_STARES")) > 0 
			VS1->VS1_STARES := "3"
		endif
		If lVS1_GERFIN
			VS1->VS1_GERFIN := cAtuGerFin
		Endif
	endif
	If lIntegraLoja
		If lVS1_GERFIN
			VS1->VS1_GERFIN := " "
		Endif
	EndIf
	msunlock()
	If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
		OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0095 ) // Grava Data/Hora na Mudança de Status do Orçamento / Orçamento por Fases
	EndIf
next
//
if nRecSA1 <> 0
	SA1->(DbGoTo(nRecSA1))

	// Restaura a Natureza do Cliente
	If lAltSA1
		RecLock("SA1",.f.)
		SA1->A1_NATUREZ := cBkpNatSA1
		SA1->(MsUnLock())
	EndIf
Endif

If FindFunction("FM_GerLog")
	//grava log das alteracoes das fases do orcamento
	FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,cVS1StAnt)
EndIF
// DEPOIS DA GERACAO DA NOTA FISCAL
if ExistBlock("OX004DNF")
	if !ExecBlock("OX004DNF",.f.,.f.)
		DisarmTransaction()
		Return(.f.)
	Endif
Endif
//
DBSelectArea("VS1")
DBSetOrder(1)
DBSeek(xFilial("VS1")+cOrcOrcT)
//
//################################################################
//# Gravacao da Movto gerencial (VEC)                            #
//################################################################
oProcFAT:IncRegua2(STR0055)
if lGeraNF // NF
	//
	FM_GVECVSC(SF2->F2_DOC,SF2->F2_SERIE,"VEC")
	//
Endif
//
End Transaction
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
MsRUnLock()
//
oProcFAT:IncRegua1(STR0053)
//
//################################################################
//# Geracao dos Titulos                                          #
//################################################################
DBSelectArea("VS1")
DBSetOrder(1)
MsSeek(xFilial("VS1")+cOrcOrcT)

lOkTit := OX004GERFIN(VS1->VS1_NUMORC,VS1->VS1_NUMNFI,VS1->VS1_SERNFI)
If lVS1_GERFIN .and. lGeraNF
	nRecVS1 := VS1->(RecNo())
	For nCntFor := 1 to Len(aOrcs)
		DBSelectArea("VS1")
		DBSetOrder(1)
		DBSeek(xFilial("VS1")+aOrcs[nCntFor])
		reclock("VS1",.f.)
		VS1->VS1_GERFIN := IIf(lOkTit,"1","0")
		msunlock()

		// Se foi possivel gerar financeiro, vamos excluir todos os registros de logs ja gravados
		If lOkTit
			// Exclui os LOGS gerados no momento do faturamento 
			cQuery := "DELETE FROM "+ RetSqlName("VQL")
			cQuery += " WHERE VQL_FILIAL = '"+xFilial("VQL")+"' "
			cQuery += "   AND VQL_AGROUP = 'OFIXX004' "
			cQuery += "   AND VQL_FILORI = '" + VS1->VS1_FILIAL + "' "
			cQuery += "   AND VQL_TIPO = 'VS1-" + VS1->VS1_NUMORC + "'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			TcSqlExec(cQuery)
		EndIf
		//


	Next
	VS1->(DbGoTo(nRecVS1))
Endif
//
If !lOkTit
	//
	MsgInfo(STR0068,STR0019) // "O Orçamento foi Finalizado gerando NF, porém existe(m) inconsistência(s) na Geração dos Titulos. Favor corrigir a(s) pendência(s) e solicitar novamente a Geração dos Titulos. "
	//
Endif
//
oProcFAT:IncRegua1(STR0052)
oProcFAT:IncRegua2(STR0056)
//
DBSelectArea("VS1")
DBSetOrder(1)
MsSeek(xFilial("VS1")+cOrcOrcT)
//
// PE DEPOIS DO FATURAMENTO
if ExistBlock("OX004DFT")
	if !ExecBlock("OX004DFT",.f.,.f.)
		Return(.f.)
	Endif
Endif
//
if lGeraNF // NF
	// IMPRIME A NF
	if ExistBlock("NFPECSER")
		ExecBlock("NFPECSER",.f.,.f.,{cNota,cSerie})
	Endif
else
	MsgInfo(STR0025+" "+VS1->VS1_PESQLJ)
endif
//
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_FORMULA ºAutor  ³Thiago              º Data ³  05/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Formula para calculo do preco da peca.					   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FORMULA()
Local cFormul     := ""
Local cVAI_TIPVEN := ""
if SE4->(Fieldpos("E4_FORMVR")) <> 0
	if !Empty(M->VS1_FORPAG)
		cVAI_TIPVEN := FM_SQL("SELECT VAI_TIPVEN FROM "+RetSQLName("VAI")+" WHERE VAI_FILIAL='"+xFilial("VAI")+"' AND VAI_CODVEN='"+M->VS1_CODVEN+"' AND D_E_L_E_T_=' '")
		dbSelectArea("SE4")
		dbSetOrder(1)
		dbSeek(xFilial("SE4")+cTipPag)
		Do Case
			Case cVAI_TIPVEN == "1" // Varejo
				if !Empty(SE4->E4_FORMVR)
					cFormul := '"'+SE4->E4_FORMVR+'"'
				Endif
			Case cVAI_TIPVEN == "2" // Atacado
				if !Empty(SE4->E4_FORMAT)
					cFormul := '"'+SE4->E4_FORMAT+'"'
				Endif
			Case cVAI_TIPVEN == "3" // Todos
    	        if M->VS1_TIPVEN == "1"
					if !Empty(SE4->E4_FORMVR)
						cFormul := '"'+SE4->E4_FORMVR+'"'
			    	Endif
				Elseif M->VS1_TIPVEN == "2"
					if !Empty(SE4->E4_FORMAT)
						cFormul := '"'+SE4->E4_FORMAT+'"'
				    Endif
				Endif
		EndCase
    Else
    	cFormul := GETMV("MV_FMLPECA")
	Endif
Endif
if Empty(cFormul)
	cFormul := GETMV("MV_FMLPECA")
Endif	
Return(cFormul)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OX004TPPG º Autor ³ Andre Luis Almeida º Data ³  16/03/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Selecionar os Tp Pagamentos para PreDigitacao do Como Pagar º±±
±± ROTINA DESCONTINUADA.													±±
±± APONTA PARA A ROTINA OX0040115_TipoDePagamento.							±±
±± MANTIDA POR QUESTÕES DE LEGADO											±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX004TPPG(nOpc,lTela)
OX0040115_TipoDePagamento(nOpc,lTela)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_OX004TP º Autor ³ Andre Luis Almeida º Data ³  16/03/16  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao Auxiliar da OX004TPPG                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OX004TP(cTp,aTpPagNao,aTpPagSim,aAuxParc,aParcPre)
Local aAux := {}
Local ni   := 0
Local nx   := 0
//
Do Case
	Case cTp == ">>"
		//
		/*DBSelectArea("SE4")
		DBSetOrder(1)
		MsSeek(xFilial("SE4")+M->VS1_FORPAG)
		If SE4->E4_TIPO $ "A.9"
			FMX_HELP("OFIXX004_001",STR0072) // A Condição de Pagamento selecionada é do tipo Negociada. Impossível selecionar Tipos de Pagamento para composição das Parcelas.
			Return
		EndIf*/
		//
		If aTpPagNao[oTpPagNao:nAt,1] <> "X"
			If aTpPagSim[oTpPagSim:nAt,1] == "X"
				aTpPagSim := {}
			EndIf
			If len(aAuxParc) > 0 .and. len(aTpPagSim) == len(aAuxParc) // Maximo de Tipos de Pagamento selecionados em relacao a Condicao de Pagamento
				FMX_HELP("OFIXX004_002",STR0073) // Atingido o número máximo de Tipos de Pagamento permitidos para a Condição de Pagamento selecionada.
				Return
			EndIf
			aAdd(aTpPagSim,aClone(aTpPagNao[oTpPagNao:nAt]))
			aDel(aTpPagNao,oTpPagNao:nAt)
			aSize(aTpPagNao,Len(aTpPagNao)-1)
			If oTpPagNao:nAt > 1
				oTpPagNao:nAt--
			EndIf
		EndIf
	Case cTp == "<<"
		If aTpPagSim[oTpPagSim:nAt,1] <> "X"
			If aTpPagNao[oTpPagNao:nAt,1] == "X"
				aTpPagNao := {}
			EndIf
			aAdd(aTpPagNao,aClone(aTpPagSim[oTpPagSim:nAt]))
			aDel(aTpPagSim,oTpPagSim:nAt)
			aSize(aTpPagSim,Len(aTpPagSim)-1)
			If oTpPagSim:nAt > 1
				oTpPagSim:nAt--
			EndIf
		EndIf
	Case cTp == "/\"
		If oTpPagSim:nAt > 1
			aAux := aClone(aTpPagSim[oTpPagSim:nAt-1])
			aTpPagSim[oTpPagSim:nAt-1] := aClone(aTpPagSim[oTpPagSim:nAt])
			aTpPagSim[oTpPagSim:nAt]   := aClone(aAux)
			oTpPagSim:nAt--
		EndIf
	Case cTp == "\/"
		If oTpPagSim:nAt < len(aTpPagSim)
			aAux := aClone(aTpPagSim[oTpPagSim:nAt+1])
			aTpPagSim[oTpPagSim:nAt+1] := aClone(aTpPagSim[oTpPagSim:nAt])
			aTpPagSim[oTpPagSim:nAt]   := aClone(aAux)
			oTpPagSim:nAt++
		EndIf
EndCase
aParcPre := {}
If len(aAuxParc) > 0 // Selecionou condicao de Pagamento
	For ni := 1 to len(aAuxParc)
		aAdd(aParcPre,{aAuxParc[ni,1],"",""})
		If len(aTpPagSim) < len(aParcPre)
			nx := len(aTpPagSim)
		Else
			nx := ni
		EndIf
		If len(aTpPagSim) >= nx .and. nx > 0
			aParcPre[ni,2] := aTpPagSim[nx,2]
			aParcPre[ni,3] := aTpPagSim[nx,3]
		EndIf
	Next		
EndIf
If len(aParcPre) <= 0
	aAdd(aParcPre,{ctod(""),"",""})
EndIf
If len(aTpPagNao) <= 0
	aAdd(aTpPagNao,{"X","",""})
EndIf
If len(aTpPagSim) <= 0
	aAdd(aTpPagSim,{"X","",""})
EndIf
If !Empty(cTp)
	oTpPagNao:SetArray(aTpPagNao)
	oTpPagNao:bLine := { || { aTpPagNao[oTpPagNao:nAt,2]+" - "+aTpPagNao[oTpPagNao:nAt,3] }}
	oTpPagNao:Refresh()
	oTpPagSim:SetArray(aTpPagSim)
	oTpPagSim:bLine := { || { IIf(!Empty(aTpPagSim[oTpPagSim:nAt,2]),Transform(oTpPagSim:nAt,"@E 999999999"),"") , aTpPagSim[oTpPagSim:nAt,2]+" - "+aTpPagSim[oTpPagSim:nAt,3] }}
	oTpPagSim:Refresh()
EndIf
If len(aAuxParc) > 0 // Condicao de Pagamento possui parcelas
	oParcPre:SetArray(aParcPre)
	oParcPre:bLine := { || { Transform(aParcPre[oParcPre:nAt,1],"@D") , aParcPre[oParcPre:nAt,2]+" - "+aParcPre[oParcPre:nAt,3] }}
	oParcPre:Refresh()
EndIf
//
Return()


/*/{Protheus.doc} OX004SC5NEG

Funcao responsavel por montar as parcelas  no cabecalho do pedido de venda quando utilizada uma condicao de pagamento do tipo '9'

@author Rubens / Manoel
@since 14/10/2016
@version 1.0
@param cCondVS9, character, Contem clausula para pesquisa quando utiliza condicao do tipo "A"

/*/
Static Function OX004SC5NEG(cCondVS9)

Local cAliasVS9 	:= "TVS9"
Local nPosSC5
Local nPosVS9SE1

SE4->(dbSetOrder(1))
SE4->(MsSeek( xFilial("SE4") + VS1->VS1_FORPAG ))

// Condicao negociada
If SE4->E4_TIPO == "9" .OR. SE4->E4_TIPO == "A"
	//VS1_VLBRNF identifica se manda o valor bruto do item
	//Refaz as parcelas com o Condicao
	If lVS1_VLBRNF .and. VS1->VS1_VLBRNF == "0" ;
		.and. lVS1_FPGBAS .and. !Empty(VS1->VS1_FPGBAS);
		.and. !lMultOrc

		aParcBRNF := Condicao(nValDup,VS1->VS1_FPGBAS,nValIPI,DDATABASE,nValST)

		cParcela := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0" // cParcela igual ao MATA410A, funcao A410Tipo9()
		cSQL := "SELECT VS9_TIPPAG, VS9_DATPAG , VS9_VALPAG , VS9_TIPPAG "
		cSQL += "  FROM " + RetSQLName("VS9") + " VS9"
		cSQL += " WHERE VS9.VS9_FILIAL = '" + xFilial("VS9") + "'"
		cSQL += "   AND VS9.VS9_TIPOPE = ' '"
		cSQL += "   AND VS9.VS9_NUMIDE = '" + VS1->VS1_NUMORC + "'"
		cSQL += "   AND VS9.D_E_L_E_T_ = ' '"
		cSQL += " ORDER BY VS9_NUMIDE , VS9_DATPAG , VS9_SEQUEN"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS9 , .F., .T. )
		While !(cAliasVS9)->(Eof())

			If (nPosVS9SE1 := aScan( aVS9SE1 ,{ |x| x[1] == (cAliasVS9)->VS9_DATPAG .and. x[2] == (cAliasVS9)->VS9_TIPPAG })) == 0
				AADD( aVS9SE1 , { (cAliasVS9)->VS9_DATPAG , (cAliasVS9)->VS9_TIPPAG , "" } )
				nPosVS9SE1 := Len(aVS9SE1)
				aVS9SE1[nPosVS9SE1,3] := SubStr(cParcela,nPosVS9SE1,1)
				
				aAdd(aCabPV,{"C5_DATA" + aVS9SE1[nPosVS9SE1,3] , StoD((cAliasVS9)->VS9_DATPAG)  , Nil }) // Data da Parcela
				aAdd(aCabPV,{"C5_PARC" + aVS9SE1[nPosVS9SE1,3] , aParcBRNF[nPosVS9SE1,2]        , Nil }) // Valor da Parcela
			Else
			
				nPosSC5 := aScan(aCabPV,{ |x| x[1] == "C5_PARC" + aVS9SE1[nPosVS9SE1,3] })
				aCabPV[ nPosSC5 , 2 ] += aParcBRNF[nPosVS9SE1,2]
			EndIf

			(cAliasVS9)->(dbSkip())
		End
		(cAliasVS9)->(dbCloseArea())		
	Else
		cParcela := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0" // cParcela igual ao MATA410A, funcao A410Tipo9()
		cSQL := "SELECT VS9_TIPPAG, VS9_DATPAG , VS9_VALPAG , VS9_TIPPAG "
		cSQL += "  FROM " + RetSQLName("VS9") + " VS9"
		cSQL += " WHERE VS9.VS9_FILIAL = '" + xFilial("VS9") + "'"
		cSQL += "   AND VS9.VS9_TIPOPE = ' '"
		cSQL += "   AND VS9.VS9_NUMIDE = '" + VS1->VS1_NUMORC + "'"
		cSQL += "   AND VS9.D_E_L_E_T_ = ' '"
		cSQL += " ORDER BY VS9_NUMIDE , VS9_DATPAG , VS9_SEQUEN"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS9 , .F., .T. )
		While !(cAliasVS9)->(Eof())

			If (nPosVS9SE1 := aScan( aVS9SE1 ,{ |x| x[1] == (cAliasVS9)->VS9_DATPAG .and. x[2] == (cAliasVS9)->VS9_TIPPAG })) == 0
				AADD( aVS9SE1 , { (cAliasVS9)->VS9_DATPAG , (cAliasVS9)->VS9_TIPPAG , "" } )
				nPosVS9SE1 := Len(aVS9SE1)
				aVS9SE1[nPosVS9SE1,3] := SubStr(cParcela,nPosVS9SE1,1)
				
				aAdd(aCabPV,{"C5_DATA" + aVS9SE1[nPosVS9SE1,3] , StoD((cAliasVS9)->VS9_DATPAG)  , Nil }) // Data da Parcela
				aAdd(aCabPV,{"C5_PARC" + aVS9SE1[nPosVS9SE1,3] , (cAliasVS9)->VS9_VALPAG        , Nil }) // Valor da Parcela
			Else
			
				nPosSC5 := aScan(aCabPV,{ |x| x[1] == "C5_PARC" + aVS9SE1[nPosVS9SE1,3] })
				aCabPV[ nPosSC5 , 2 ] += (cAliasVS9)->VS9_VALPAG
			EndIf

			(cAliasVS9)->(dbSkip())
		End
		(cAliasVS9)->(dbCloseArea())
	EndIf
EndIf
//
Return 


/*/{Protheus.doc} OX004GERFIN
Funcao responsavel por gerar o Financeiro 
@author Manoel
@since 29/11/2017
@version 1.0
/*/
Static Function OX004GERFIN(_cOrcOrcT,_cNota,_cSerie)
Local cPrefNF     := ""
Local cNatureza   := ""
Local nCntFor     := 0
Local cNumPed     := ""
Local _nRecSC5    := 0
Local _nRecSA1    := 0
Local c1DUPNAT    := GetMV("MV_1DUPNAT")
Local lVS1_GERFIN := ( VS1->(FieldPos("VS1_GERFIN")) > 0 )
Local cQuery      := ""
Local cAliasVS1   := "SQLVS1"

DBSelectArea("VS1")
DBSetOrder(1)
DBSeek(xFilial("VS1")+_cOrcOrcT)

// Orcamento integrado com o Loja / Faturamento Direto, neste caso o controle de titulos no financeiro será do BackOffice
If !Empty(VS1->VS1_PESQLJ)
	Return .t.
EndIf
//
DBSelectArea("VS3")
DBSetOrder(1)
DBSeek(xFilial("VS3")+VS1->VS1_NUMORC)
SF4->(dbSeek(xFilial("SF4") + VS3->VS3_CODTES))
//
//################################################################
//# Gera Titulos caso necessario                                 #
//################################################################
//
DbSelectArea("SF2")
DbSetOrder(1)
DbSeek(xFilial("SF2")+_cNota+_cSerie)
_nRecSC5 := FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSQLName("SC5")+" WHERE C5_FILIAL='"+xFilial("SC5")+"' AND C5_NOTA='"+_cNota+"' AND C5_SERIE='"+_cSerie+"' AND D_E_L_E_T_=' '")
If _nRecSC5 > 0
	DbSelectArea("SC5")
	DbGoTo(_nRecSC5)
	cNumPed := SC5->C5_NUM
EndIf
//
cPrefNF := &(GetNewPar("MV_1DUPREF","_cSerie"))
//
//
Begin Transaction
//
oProcFAT:IncRegua2(STR0053)
//
//#############################################################################
//# Gravacao dos Titulos a receber                                            #
//#############################################################################
if Alltrim(SE4->E4_TIPO)=="A" .and. SF4->F4_DUPLIC == "S"
	//
	nParcelas := 0
	//
	dbSelectArea("SA3")
	dbSetOrder(1)
	dbSeek(xFilial("SA3")+VS1->VS1_CODVEN)
	//
	for nCntFor := 1 to Len(oGetP004:aCols)
		If !(oGetP004:aCols[nCntFor,len(aHeaderCP)+1])
			cNatureza := oGetP004:aCols[nCntFor,FG_POSVAR("VS9_NATURE","aHeaderCP")]
			//
			if Empty(cNatureza) .and. !Empty(VS1->VS1_NATURE)
				cNatureza := VS1->VS1_NATURE
			EndIf
			if Empty(cNatureza) .and. !Empty(SA1->A1_NATUREZ)
				cNatureza := SA1->A1_NATUREZ
			EndIf
			If Empty(cNatureza)
				cNatureza := &(c1DUPNAT)
			Endif
			//
			cCodBco :=  oGetP004:aCols[nCntFor,FG_POSVAR("VS9_PORTAD","aHeaderCP")]
			//
			cTipCob  := if(!Empty(cCodBco),"1","0") // TODO:
			//
			if Empty(cCodBco)
				cCodBco := VS1->VS1_CODBCO
				if Empty(cCodBco)
					cCodBco := GetNewPar("MV_BCOCXA","")
					if Empty(cCodBco)
						MsgInfo(STR0024 ,STR0019)
						DisarmTransaction()
						return .f.
					Endif
				Endif
			endif
			//
			FG_Seek("SA6","cCodBco",1,.f.)
			if SA6->A6_BORD == "0"
				cNumBord := "BCO"+SA6->A6_COD
				dDatBord := dDataBase
			else
				cNumBord :=""
				dDatBord := cTod("")
			Endif
			//
			nParcelas++
			if TamSx3("E1_PARCELA")[1] = 1
				cParcela := ConvPN2PC(nParcelas)
			Else
				cParcela := Soma1( strzero(nParcelas-1,TamSx3("E1_PARCELA")[1]) )
			Endif

			If lVS1_VLBRNF .and. VS1->VS1_VLBRNF == "0" .and. lVS1_FPGBAS .and. !Empty(VS1->VS1_FPGBAS) .and. !lMultOrc
				nValTit := aParcBRNF[nCntFor,2]
			Else
				nValTit := oGetP004:aCols[nCntFor,FG_POSVAR("VS9_VALPAG","aHeaderCP")]
			EndIf
			//
			aTitulo := {{"E1_PREFIXO" ,cPrefNF																	,Nil},;
			{"E1_NUM"     ,_cNota 																				,Nil},;
			{"E1_PARCELA" ,cParcela																				,Nil},;
			{"E1_TIPO"    ,oGetP004:aCols[nCntFor,FG_POSVAR("VS9_TIPPAG","aHeaderCP")]	,Nil},;
			{"E1_NATUREZ" ,cNatureza																			,Nil},;
			{"E1_SITUACA",cTipCob			  																	,Nil},;
			{"E1_CLIENTE" ,SF2->F2_CLIENTE																,Nil},;
			{"E1_LOJA"    ,SF2->F2_LOJA																		,Nil},;
			{"E1_EMISSAO" ,dDataBase																			,Nil},;
			{"E1_VENCTO"  ,oGetP004:aCols[nCntFor,FG_POSVAR("VS9_DATPAG","aHeaderCP")]     		        		,Nil},;
			{"E1_VENCREA" ,DataValida(oGetP004:aCols[nCntFor,FG_POSVAR("VS9_DATPAG","aHeaderCP")]) 				,Nil},;
			{"E1_VALOR"   ,nValTit													    			         	,Nil},;
			{"E1_NUMBOR"  ,cNumBord																				,Nil},;
			{"E1_DATABOR" ,dDatBord																				,Nil},;
			{"E1_PORTADO" ,cCodBco																				,Nil},;
			{"E1_PREFORI" ,cPrefBAL 																			,Nil},;
			{"E1_VEND1"  , SA3->A3_COD																		,nil},;
			{"E1_COMIS1" , SA3->A3_COMIS																	,nil},;
			{"E1_BASCOM1", oGetP004:aCols[nCntFor,FG_POSVAR("VS9_VALPAG","aHeaderCP")]							,nil},;
			{"E1_PEDIDO" , cNumPed																				,nil},;
			{"E1_NUMNOTA", _cNota				  																,nil},;
			{"E1_ORIGEM" , "MATA460"																			,nil},;
			{"E1_SERIE"  , _cSerie																				,nil} }

			cMsgErr := OX0040143_LogArrayExecAuto(aTitulo)
			pergunte("FIN040",.F.)
			//
			_nRecSA1 := SA1->(Recno())//Salva posicao SA1
			//

			//PE para permitir a manipulação do vetor aTitulo
			If ExistBlock("OX004TIT")
				aTitulo := ExecBlock("OX004TIT",.f.,.f.,{aTitulo,oGetP004:aCols[nCntFor]})
				
				cMsgErr +=  CRLF + CRLF + "OX004TIT" + CRLF + OX0040143_LogArrayExecAuto(aTitulo)

			EndIf

			lMsErroAuto := .f.
			MSExecAuto({|x| FINA040(x)},aTitulo)
			//
			SA1->(Dbgoto(_nRecSA1))//Volta posicao SA1
			//
			If lMsErroAuto
				DisarmTransaction()
				cMsgErr +=  CRLF + CRLF + "lMsErroAuto" + CRLF + MostraErro()

				aLogVQL := {}

				cVQLDados := STR0093

				//Gerar log de execução no VQL
				aAdd(aLogVQL,{'VQL_AGROUP'     , 'OFIXX004'                })
				aAdd(aLogVQL,{'VQL_TIPO'       , 'VS1-' + VS1->VS1_NUMORC  })
				aAdd(aLogVQL,{'VQL_FILORI'     , VS1->VS1_FILIAL           })
				aAdd(aLogVQL,{'VQL_DADOS'      , cVQLDados }) // 'PROBLEMA NA GERAÇÃO DAS PARCELAS'

				If VQL->(FieldPos("VQL_MSGLOG")) > 0
					aAdd(aLogVQL,{'VQL_MSGLOG'     , cMsgErr })
				EndIf

				cTblLogCod := oLogger:LogToTable(aLogVQL)

				Return .f.
			EndIf
			//
		endif
	next
endif
//
// #######################################
// # BAIXA AUTOMATICA DO TITULO A VISTA  #
// #######################################
if GetNewPar("MV_BXPEC","N") == "S"
	DBSelectArea("SE1")
	DBSetOrder(1)
	DBSeek(xFilial("SE1")+cPrefNF+_cNota)
	//
	while !eof() .and. Alltrim(xFilial("SE1")+cPrefNF+_cNota) == Alltrim(SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM)
		//
		if SE1->E1_VENCTO == ddatabase
			aBaixa  := {;
				{"E1_PREFIXO"  ,E1_PREFIXO             ,Nil } ,;
				{"E1_NUM"	   ,E1_NUM                 ,Nil } ,;
				{"E1_PARCELA"  ,E1_PARCELA             ,Nil } ,;
				{"E1_TIPO"	   ,E1_TIPO                ,Nil } ,;
				{"AUTMOTBX"	   ,"NOR"                  ,Nil } ,;
				{"AUTDTBAIXA"  ,dDataBase              ,Nil } ,;
				{"AUTDTCREDITO",dDataBase              ,Nil } ,;
				{"AUTHIST"	   ,"BAIXA AUTOMATICA"     ,Nil } ,;
				{"AUTVALREC"   ,SE1->E1_VALOR          ,Nil }}
			//

			//PE criado para passagem de parâmetros customizados no ExecAuto do FINA070, seguindo o parâmetro MV_BXPEC
			If ExistBlock("OX004BXF")
				aBaixa := ExecBlock("OX004BXF", .F., .F., aBaixa)
			Endif

			MSExecAuto({|x| FINA070(x)},aBaixa)
			//
			If lMsErroAuto
				DisarmTransaction()
				cMsgErr := VarInfo("",aBaixa,NIL,.F.,.F.)
				cMsgErr +=   CRLF + CRLF + "lMsErroAuto" + CRLF + MostraErro()

				aLogVQL := {}

				cVQLDados := STR0094
				//Gerar log de execução no VQL
				aAdd(aLogVQL,{'VQL_AGROUP'     , 'OFIXX004'         })
				aAdd(aLogVQL,{'VQL_TIPO'       , 'VS1-' + VS1->VS1_NUMORC         })
				aAdd(aLogVQL,{'VQL_FILORI'     , VS1->VS1_FILIAL           })
				aAdd(aLogVQL,{'VQL_DADOS'      , cVQLDados }) // "PROBLEMA NA BAIXA AUTOMÁTICA DAS PARCELAS A VISTA"

				If VQL->(FieldPos("VQL_MSGLOG")) > 0
					aAdd(aLogVQL,{'VQL_MSGLOG'     , cMsgErr })
				EndIf

				cTblLogCod := oLogger:LogToTable(aLogVQL)

				Return .f.
			EndIf
		EndIf
		DBSelectArea("SE1")
		DBSkip()
	enddo
Endif
//
//////////////////////////////////////////////////////////////////////
// Gravar o F2_VALFAT com a soma de todos os titulos referente a NF //
//////////////////////////////////////////////////////////////////////
If !Empty(VS1->VS1_NUMNFI+VS1->VS1_SERNFI)
	dbSelectArea("SF2")
	dbSetOrder(1)
	If dbSeek(xFilial("SF2")+VS1->VS1_NUMNFI+VS1->VS1_SERNFI)
		RecLock("SF2",.f.)
		SF2->F2_DUPL := VS1->VS1_NUMNFI
		SE4->(DBSetOrder(1))
		If SE4->(dbSeek(xFilial("SE4")+SF2->F2_COND)) .and. SE4->E4_TIPO == "A"
			SE1->(Dbgoto(SE1->(RecNo()))) // Reposiciona no SE1 para ser considerado no SQL dentro da transacao
			SF2->F2_VALFAT := FMX_VALFIN( SF2->F2_PREFIXO , SF2->F2_DUPL , SF2->F2_CLIENTE , SF2->F2_LOJA )
		EndIf
		MsUnLock()
	EndIf
EndIf
//
If lVS1_GERFIN
	cQuery := "SELECT VS1.R_E_C_N_O_ AS RECVS1 "
	cQuery += "FROM "
	cQuery += RetSqlName( "VS1" ) + " VS1 " 
	cQuery += "WHERE " 
	cQuery += "VS1.VS1_FILIAL = '"+xFilial("VS1") +"' AND "
	cQuery += "VS1.VS1_NUMNFI = '"+VS1->VS1_NUMNFI+"' AND "
	cQuery += "VS1.VS1_SERNFI = '"+VS1->VS1_SERNFI+"' AND "
	cQuery += "VS1.D_E_L_E_T_=' '"		
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS1, .T., .T. )
	Do While !( cAliasVS1 )->( Eof() )  
		DbSelectArea("VS1")
		DbGoTo( ( cAliasVS1 )->RECVS1 )
		reclock("VS1",.f.)
		VS1->VS1_GERFIN := "1"
		msunlock()
		( cAliasVS1 )->(dbSkip())
	Enddo
	( cAliasVS1 )->( dbCloseArea() )
EndIf
//
End Transaction
//
DBSelectArea("VS1")
DBSetOrder(1)
DBSeek(xFilial("VS1")+_cOrcOrcT)
//
DBSelectArea("SE4")
DBSetOrder(1)
DBSeek(xFilial("SE4")+cTipPag)
//
Return .t.

/*/{Protheus.doc} OX0040016_VerificarLinhaDuplicada
// Verificar linha duplicada (Tipo de Pagamento e Data iguais)
@author Fernando Vitor Cavani
@since 21/02/2020
@param  nLinha - Numérico - Linha para comparação
@return lRet   - Lógico   - Retorno .t. ou .f. (caso TudoOk)
@type function
/*/
Static Function OX0040016_VerificarLinhaDuplicada(nLinha)
Local nCntFor  := 0
Local nDin     := 0
Local cTipo    := ""
Local cTipoAux := ""
Local dData
Local dDataAux
Local cIDCt    := ""
Local cIDCtAux := ""
Local cMsg     := ""
Local lErro    := .f.
Local lRet     := .t.

Default nLinha := 0

If nLinha <> 0
	cTipoAux := oGetP004:aCols[nLinha, FG_POSVAR("VS9_TIPPAG", "aHeaderCP")] // Tipo de Pagamento

	If AllTrim(cMoeda) == AllTrim(cTipoAux)
		// Verificação de Tipo de Pagamento Dinheiro
		nDin++
	EndIf

	If cNFCF == "2"
		// Cupom Fiscal (Integração com Loja)
		dDataAux := oGetP004:aCols[nLinha, FG_POSVAR("VS9_DATPAG", "aHeaderCP")] // Data

		If lFormaID
			cIDCtAux := oGetP004:aCols[nLinha, FG_POSVAR("VS9_FORMID", "aHeaderCP")] // ID Cartão
		EndIf
	EndIf
EndIf

If cNFCF == "1"
	// Nota Fiscal
	// Verificação Apenas de Tipo de Pagamento Dinheiro
	If nDin == 1 .Or. nLinha == 0
		For nCntFor := 1 To Len(oGetP004:aCols)
			If nCntFor <> nLinha .And. !(oGetP004:aCols[nCntFor, Len(oGetP004:aCols[nCntFor])])
				cTipo := oGetP004:aCols[nCntFor, FG_POSVAR("VS9_TIPPAG", "aHeaderCP")] // Tipo de Pagamento

				If AllTrim(cMoeda) == AllTrim(cTipo)
					// Verificação de Tipo de Pagamento Dinheiro
					nDin++
					If nDin >= 2
						FMX_HELP("OFIXX004_003", STR0077) // Dinheiro - Não é possível repetir por ser a vista

						If nLinha == 0
							// TudoOk
							lRet := .f.
						EndIf

						Exit
					EndIf
				EndIf
			EndIf
		Next
	EndIf
Else
	// Cupom Fiscal (Integração com Loja)
	For nCntFor := 1 To Len(oGetP004:aCols)
		If nCntFor <> nLinha .And. !(oGetP004:aCols[nCntFor, Len(oGetP004:aCols[nCntFor])])
			cTipo := oGetP004:aCols[nCntFor, FG_POSVAR("VS9_TIPPAG", "aHeaderCP")] // Tipo de Pagamento

			If AllTrim(cMoeda) == AllTrim(cTipo) .And. ((AllTrim(cMoeda) == AllTrim(cTipoAux)) .Or. nLinha == 0)
				// Verificação de Tipo de Pagamento Dinheiro
				nDin++
				If nDin >= 2
					lErro := .t.

					Exit
				EndIf
			Else
				// Verificação Demais Tipos de Pagamento
				dData := oGetP004:aCols[nCntFor, FG_POSVAR("VS9_DATPAG", "aHeaderCP")] // Data

				If lFormaID
					cIDCt := oGetP004:aCols[nCntFor, FG_POSVAR("VS9_FORMID", "aHeaderCP")] // ID Cartão
				EndIf

				// Mesmo Tipo de Pagamento, mesma Data e mesmo ID Cartão
				If nLinha == 0
					// TudoOK
					If lFormaID .And. AllTrim(cTipo) $ "CC.CH"
						// Cartão e Cheque
						If aScan(oGetP004:aCols, { |x| AllTrim(x[FG_POSVAR("VS9_TIPPAG", "aHeaderCP")]) == Alltrim(cTipo) .And. x[FG_POSVAR("VS9_DATPAG", "aHeaderCP")] == dData .And. AllTrim(x[FG_POSVAR("VS9_FORMID", "aHeaderCP")]) == Alltrim(cIDCt) }) <> nCntFor
							lErro := .t.

							Exit
						EndIf
					Else
						// Demais Tipos de Pagamento
						If aScan(oGetP004:aCols, { |x| AllTrim(x[FG_POSVAR("VS9_TIPPAG", "aHeaderCP")]) == Alltrim(cTipo) .And. x[FG_POSVAR("VS9_DATPAG", "aHeaderCP")] == dData }) <> nCntFor
							lErro := .t.

							Exit
						EndIf
					EndIf
				Else
					// LinOk
					If lFormaID .And. AllTrim(cTipo) $ "CC.CH"
						// Cartão e Cheque
						If AllTrim(cTipo) == AllTrim(cTipoAux) .And. dData == dDataAux .And. AllTrim(cIDCt) == AllTrim(cIDCtAux)
							lErro := .t.

							Exit
						EndIf
					Else
						// Demais Tipos de Pagamento
						If AllTrim(cTipo) == AllTrim(cTipoAux) .And. dData == dDataAux
							lErro := .t.

							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next

	If lErro
		If lFormaID
			cMsg := STR0075 +;    // Cartão - Não é possível repetir informando mesma Data e mesmo Id Cartão
				CHR(13)+ CHR(10) +;
				CHR(13)+ CHR(10) +;
				STR0076 +;        // Cheque - Não é possível repetir informando mesma Data e mesmo Id Cartão
				CHR(13)+ CHR(10) +;
				CHR(13)+ CHR(10)
		EndIf

		Aviso(STR0019,; // Atenção
			STR0074 +;            // Inconsistência encontrada, verifique:
			CHR(13)+ CHR(10) +;
			CHR(13)+ CHR(10) +;
			cMsg +;
			STR0077 +;            // Dinheiro - Não é possível repetir por ser a vista
			CHR(13)+ CHR(10) +;
			CHR(13)+ CHR(10) +;
			STR0078, { "Ok" }, 3) // Demais Tipos de Pagamento - Não é possível repetir informando mesma Data

		If nLinha == 0
			// TudoOk
			lRet := .f.
		EndIf
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OX0040026_SemaforoCliente
// Abrir Semáforo com as informações do Cliente
@author Fernando Vitor Cavani
@since 30/04/2020
@type function
/*/
Static Function OX0040026_SemaforoCliente()
If !Empty(VS1->VS1_FORPAG) .And. alltrim(VS1->VS1_FORPAG) $ GetMv("MV_CPNCLC")
	MsgAlert(STR0082, STR0019) // A Forma de Pagamento informada no Orçamento não considera Limite de Crédito! / Atenção
EndIf

FG_CKCLINI(VS1->VS1_CLIFAT + VS1->VS1_LOJA, .t., .t.)
Return .t.

/*/{Protheus.doc} OX0040026_SemaforoCliente
// Abrir Semáforo com as informações do Cliente
@author Fernando Vitor Cavani
@since 30/04/2020
@type function
/*/
Function OX0040115_TipoDePagamento(nOpc,lTela)

	Local aSize			:= FWGetDialogSize( oMainWnd )
	Local nCont			:= 0
	Local nTTipVS9		:= TamSX3("VS9_TIPPAG")[1]
	Local ni			:= 0
	Local nTTipVS1  := TamSX3("VS1_TIPPAG")[1]
	
	Private aParcelas 	:= {}
	Private aTpPag 		:= {}
	Private aTpPagSel 	:= {}
	Private cCond 		:= space(TamSX3("E4_CODIGO")[1])

	Default nOpc		:= 2
	Default lTela		:= .f.
	
	If lTela .or. Empty(M->VS1_TIPPAG)
		Aadd(aTpPagSel,{"","",""})
		aAdd(aParcelas,{"","",""})

		cQuery := "SELECT VSA_TIPPAG , VSA_DESPAG FROM "+RetSQLName("VSA")+" WHERE VSA_FILIAL='"+xFilial("VSA")+"' AND VSA_TIPO='5' AND D_E_L_E_T_=' ' ORDER BY VSA_TIPPAG"
		TcQuery cQuery New Alias "TMPVSA"
		While !TMPVSA->( Eof() )
			aAdd(aTpPag,{ cValToChar(nCont++) , TMPVSA->VSA_TIPPAG , TMPVSA->VSA_DESPAG, .f. })
			TMPVSA->( DbSkip() )
		EndDo
		TMPVSA->( DbCloseArea() )

		nAux := ( len(Alltrim(M->VS1_TIPPAG)) / ( nTTipVS9 + 1 ) )
		For ni := 1 to nAux
			cAux := substr(M->VS1_TIPPAG,(ni*(nTTipVS9+1))-nTTipVS9,nTTipVS9)
			If !Empty(cAux)
				nPosSel := aScan(aTpPag,{ |x| x[2] == cAux })
				If nPosSel > 0
					OX0040065_AdicionaTipoPagamento(aTpPag[nPosSel])
				EndIf
			EndIf
		Next

		If !Empty(M->VS1_FPGBAS)
			cCond := M->VS1_FPGBAS
		EndIf

		oDlgTpPag := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0003, , , , nOr( WS_VISIBLE, WS_POPUP ) , , , , , .T., , , , .F. )    // "Área de Trabalho"

			oLayer := FWLayer():new()
			oLayer:Init(oDlgTpPag,.f.)

			//Cria as linhas do Layer
			oLayer:addLine( 'L1', 30, .F. )
			oLayer:addLine( 'L2', 69, .F. )

			//Cria as colunas do Layer
			oLayer:addCollumn('C1L1',50,.F.,"L1")
			oLayer:addCollumn('C2L1',49,.F.,"L1")

			//Cria as colunas do Layer
			oLayer:addCollumn('C1L2',50,.F.,"L2")
			oLayer:addCollumn('C2L2',49,.F.,"L2")

			oLayer:AddWindow('C1L1','WIN_FORPG',STR0083,100,.F.,.F.,,'L1',) //Forma de Pagamento
			oLayer:AddWindow('C2L1','WIN_TPPGT',STR0084,100,.F.,.F.,,'L1',) //Disponiveis
			oLayer:AddWindow('C1L2','WIN_PARCE',STR0085,100,.F.,.F.,,'L2',) //Parcelas
			oLayer:AddWindow('C2L2','WIN_PGSEL',STR0086,100,.F.,.F.,,'L2',) //Selecionados

			_cTopCol1 := oLayer:GetWinPanel('C1L1','WIN_FORPG', 'L1')
			_cTopCol2 := oLayer:GetWinPanel('C2L1','WIN_TPPGT', 'L1')

			_cBotCol1 := oLayer:GetWinPanel('C1L2','WIN_PARCE', 'L2')
			_cBotCol2 := oLayer:GetWinPanel('C2L2','WIN_PGSEL', 'L2')

			nLinIni := 5

			oSayCond := tSay():New( nLinIni  , 005, {|| STR0087 } , _cTopCol1,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Forma de Pagamento Base
			oGetCond := TGet():New( nLinIni+8, 005, { | u | If( PCount() == 0, cCond, cCond := u ) },_cTopCol1, 060, 010, "@!",{ || IIf(!Empty(cCond),OX0040035_CondicaoPagamento(cCond,nOpc),.f.),oTpPgDisp:SetFocus() },,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCond",,,,,.F.)
			oGetCond:cF3 := "SE4"

			// Cria browse
			oTpPgDisp := MsBrGetDBase():new( 0, 0, 260, 170,,,, _cTopCol2,,,,,,,,,,,, .F.,, .T.,, .F.,,, )
			oTpPgDisp:Align := CONTROL_ALIGN_ALLCLIENT
			oTpPgDisp:bLDblClick := {|| OX0040055_SelecionaTipoPagamento(aTpPag[oTpPgDisp:nAt]) }
			oTpPgDisp:Setcss("QTableWidget {background-color : transparent;}")
			// Define vetor para a browse
			oTpPgDisp:setArray( aTpPag )
		
			// Cria colunas do browse
			oTpPgDisp:addColumn( TCColumn():new( STR0089 , { || aTpPag[oTpPgDisp:nAt,2] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Tipo
			oTpPgDisp:addColumn( TCColumn():new( STR0090 , { || aTpPag[oTpPgDisp:nAt,3] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Descricao

			oTpPgDisp:Refresh()

			// Cria browse
			oParcela := MsBrGetDBase():new( 0, 0, 260, 170,,,, _cBotCol1,,,,,,,,,,,, .F.,, .T.,, .F.,,, )
			oParcela:Align := CONTROL_ALIGN_ALLCLIENT

			// Define vetor para a browse
			oParcela:setArray( aParcelas )
		
			// Cria colunas do browse
			oParcela:addColumn( TCColumn():new( STR0063 , { || aParcelas[oParcela:nAt,1] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Data
			oParcela:addColumn( TCColumn():new( STR0089 , { || aParcelas[oParcela:nAt,2] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Tipo

			oParcela:Refresh()

			// Cria browse
			oTpPgSel := MsBrGetDBase():new( 0, 0, 260, 170,,,, _cBotCol2,,,,,,,,,,,, .F.,, .T.,, .F.,{|| .f.},, )
			oTpPgSel:Align := CONTROL_ALIGN_ALLCLIENT

			// Define vetor para a browse
			oTpPgSel:setArray( aTpPagSel )
		
			// Cria colunas do browse
			oTpPgSel:addColumn( TCColumn():new( STR0088 , { || aTpPagSel[oTpPgSel:nAt,1] },,,, "LEFT",, .F., .T.,,,, .F. ) ) // Sequencia
			oTpPgSel:addColumn( TCColumn():new( STR0089 , { || aTpPagSel[oTpPgSel:nAt,2] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Tipo
			oTpPgSel:addColumn( TCColumn():new( STR0090 , { || aTpPagSel[oTpPgSel:nAt,3] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Descricao
			oTpPgSel:bDelOk := { || OX0040125_DelecaoTipoPagamento(aTpPagSel[oTpPgSel:nAt]) }
			oTpPgSel:bLDblClick := { || nValAnt:= aTpPagSel[oTpPgSel:nAt,1], lEditCell( aTpPagSel , oTpPgSel , "@!" , 1, , , { || OX0040135_ValidaSequencia(&(ReadVar()))} ), OX0040085_OrdenaTpPagamento(aTpPagSel[oTpPgSel:nAt],nValAnt) }
			oTpPgSel:bAdd := { || OX0040065_AdicionaTipoPagamento(aTpPag[oTpPgDisp:nAt]) }
			oTpPgSel:Refresh()

			OX0040035_CondicaoPagamento(cCond,nOpc)

		oDlgTpPag:Activate( , , , .t. , , ,EnchoiceBar( oDlgTpPag, { || OX0040105_Confirmar(cCond), oDlgTpPag:End() }, { || oDlgTpPag:End() }, , , , , , , .F., .T. ) ) //ativa a janela criando uma enchoicebar
	Else
		
		If ( nOpc == 3 .or. nOpc == 4 )
			If right(Alltrim(M->VS1_TIPPAG),1) <> "/"
				M->VS1_TIPPAG := left(Alltrim(M->VS1_TIPPAG)+"/"+space(100),nTTipVS1)
			EndIf
		EndIf
		
	EndIf

Return

Function OX0040035_CondicaoPagamento(cCondicao,nOpcao)
	
	Local i := 0
	Local nTTipVS9		:= TamSX3("VS9_TIPPAG")[1]
	Local nTTipVS1  := TamSX3("VS1_TIPPAG")[1]

	OX0040045_LimpaVetor(aParcelas)
	aParcelas := {}

	DBSelectArea("SE4")
	DBSetOrder(1)
	DBSeek(xFilial("SE4")+cCondicao)
	aAuxParc := Condicao(10000,SE4->E4_CODIGO,,dDataBase)

	For i := 1 to Len(aAuxParc)
		aAdd(aParcelas,{aAuxParc[i,1],"",cCondicao})
	Next

	If (nOpcao == 3 .or. nOpcao == 4)
		If SE4->(FieldPos("E4_FORMA")) > 0
			If !Empty(SE4->E4_FORMA)
				M->VS1_TIPPAG := left(left(SE4->E4_FORMA,nTTipVS9)+"/"+space(100),nTTipVS1)
			Endif
		Endif
	Endif

	OX0040075_RelacionaParcelas()

Return .t.

Static function OX0040045_LimpaVetor(aArray)
	aArray := aSize(aArray,0)
Return

Static function OX0040055_SelecionaTipoPagamento(aTpSel)
	Local lAddTp := .f.

	If aScan(aTpPagSel,{|x| x[2] == aTpSel[2]}) == 0
		aTpSel[4] := .t.
		lAddTp := .t.
		oTpPgSel:recAdd()
	EndIf

	If lAddTp
		//bColor := {|| RGB(80,200,0) }
		//oTpPgDisp:SetBlkBackColor(bColor)
		//oTpPgDisp:Refresh()
		OX0040075_RelacionaParcelas()
	EndIf

Return

Static function OX0040065_AdicionaTipoPagamento(aSelTp)
	Local nPrimlin := 0

	nPrimlin:= aScan(aTpPagSel,{|x| x[1] == ""})
	If nPrimlin > 0
		aTpPagSel[nPrimlin,1] := "1"
		aTpPagSel[nPrimlin,2] := aSelTp[2]
		aTpPagSel[nPrimlin,3] := aSelTp[3]
	Else
		aadd( aTpPagSel, { cValToChar(Len(aTpPagSel)+1), aSelTp[2], aSelTp[3] })
	EndIf

Return .t.

Static function OX0040075_RelacionaParcelas()
	Local ni     := 0

	If Len(aParcelas) > 0
		For ni := 1 to len(aParcelas)
			If len(aTpPagSel) < len(aParcelas)
				nx := len(aTpPagSel)
			Else
				nx := ni
			EndIf
			If len(aTpPagSel) >= nx .and. nx > 0
				aParcelas[ni,2] := aTpPagSel[nx,2]
			EndIf
		Next
	EndIf
	
	oParcela:setArray( aParcelas )
	oParcela:Refresh()

Return

Static function OX0040085_OrdenaTpPagamento(aSelecao,cSeqAnt)

	nPos := aScan(aTpPagSel,{|x| x[1] == aSelecao[1] .and. x[2] <> aSelecao[2] })
	If nPos > 0
		aTpPagSel[nPos,1] := cSeqAnt
	EndIf

	aSort(aTpPagSel,,,{|x,y| x[1] < y[1] })
	
	oTpPgSel:setArray( aTpPagSel )
	oTpPgSel:Refresh()

	OX0040075_RelacionaParcelas()

Return

Static function OX0040095_ValidaSequencia(aSelTp)

	Local lRet := .t.

	If Val(aSelTp[1]) > Len(aTpPagSel)
		lRet := .f.
		MsgInfo(STR0091,STR0092)//"O sequencial informado é maior que a quantidade de tipos de pagamentos selecionados" / "Atenção"
	EndIf

Return lRet

Static function OX0040105_Confirmar(cCond)

	Local ni := 0
	Local nTTipVS1  := TamSX3("VS1_TIPPAG")[1]

	M->VS1_TIPPAG := ""
	For ni := 1 to len(aTpPagSel)
		M->VS1_TIPPAG += aTpPagSel[ni,2]+"/"
	Next
	M->VS1_TIPPAG := left(M->VS1_TIPPAG+space(100),nTTipVS1)
	M->VS1_FPGBAS := cCond
Return

Static function OX0040125_DelecaoTipoPagamento(aTpDel)

	nPos := aScan(aTpPagSel,{|x| x[1] == aTpDel[2] })
	If nPos > 0
		aDel(aTpPagSel,nPos)
		aSize(aTpPagSel,Len(aTpPagSel)-1)
	EndIf

	aSort(aTpPagSel,,,{|x,y| x[1] < y[1] })
	
	oTpPgSel:setArray( aTpPagSel )
	oTpPgSel:Refresh()

	OX0040075_RelacionaParcelas()

Return

Static function OX0040135_ValidaSequencia(cSequen)

Return !Empty(cSequen) .and. Val(cSequen) <= Len(aTpPagSel)

Static Function OX0040143_LogArrayExecAuto(aParExecAuto)
	Local nPosArray
	Local cLog := ""

	For nPosArray := 1 to Len(aParExecAuto)
		cLog += PadR(aParExecAuto[nPosArray,1],12) + " -> " + AllTrim(cValToChar(aParExecAuto[nPosArray,2])) + CRLF
	Next nPosArray

Return cLog

/*/{Protheus.doc} OX0040158_condPreDigitada 
	Função para preencher o aTipPag com a condição pre digitada
	Chamado pela função OX004COND
	@type function
	@author Matheus Teixeira
	@since 24/08/2021
/*/
Static Function OX0040158_condPreDigitada(aTipPag)
	Local nCntPreD	:= 0
	Local nAux 		:= 0
	Local nTTipVS9  := TamSX3("VS9_TIPPAG")[1]	

	If VS1->(FieldPos("VS1_TIPPAG")) > 0 .and. !Empty(VS1->VS1_TIPPAG)
		nAux := ( len(Alltrim(VS1->VS1_TIPPAG)) / ( nTTipVS9 + 1 ) )
		If nAux > 0
			For nCntPreD := 1 to nAux
				cAux := substr(VS1->VS1_TIPPAG,(nCntPreD*(nTTipVS9+1))-nTTipVS9,nTTipVS9)
				If len(aTipPag) >= nCntPreD
					If !Empty(cAux) .and. ( FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSQLName("VSA")+" WHERE VSA_FILIAL='"+xFilial("VSA")+"' AND VSA_TIPPAG='"+cAux+"' AND D_E_L_E_T_=' '") > 0 )
						aTipPag[nCntPreD] := cAux
					EndIf
				EndIf
			next
			If len(aTipPag) > nAux
				For nCntPreD := nAux+1 to len(aTipPag)
					aTipPag[nCntPreD] := cAux
				Next
			EndIf
		EndIf
	EndIf

Return aTipPag