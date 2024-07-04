#INCLUDE "TMSA850.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSA491DEA.ch"

	//------------------------------------------------------------------------------------------------------------------------------------//
	/* Os DEFINEs  foram removidos para a "TMSA491DEA.ch" (definição de Estrura de Array), onde estão contidos os defines dos              //
	//Fontes TMSA491/TMSA850/TMSA851.Caso seja necessário a criação de mais Defines favor manter o padrão incluindo no "TMSA491DEA.ch" */ //
	//------------------------------------------------------------------------------------------------------------------------------------//

Static  RECNOCTRC := 12

Static lTM850TOk := ExistBlock("TM850TOK")
Static lTM491TIP := ExistBlock('TM491TIP')
Static lTM850FAT := ExistBlock("TM850FAT")
Static lTMFATFIL := ExistBlock("TMFATFIL")
Static _lConLoj  := nil
Static __EmpFil  := nil 
Static __lTMSCTe := nil 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Tms850   ³ Autor ³ Claudio Donizete Souza³ Data ³ 08/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Sele‡„o de Doctos (Conhecimento de NF) de transporte       ³±±
±±³          | para geracao da fatura a Receber                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa850()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa850(xAutoCab, nOpcAuto, xTipAut, xFilAut, xCliFat, xLojFat, xMoeAut, xEmiAut, xVenAut, xNatAut)

Local cFilMbrow   := ""
Local cFilMbrPE   := ""
Local lPainel     := .F.
Local cTmsERP     := SuperGetMV("MV_TMSERP",,'0')

PRIVATE aRotina   := MenuDef()
PRIVATE dEmisFat  := SuperGetMv("MV_DATAFAT",,dDataBase)
PRIVATE l850Auto  := xAutoCab <> Nil
Private cCadastro := STR0005 //"Faturas a Receber"

If  Type("cCli") == "U" 
	Private cCli      := Space(6)
	Private _cLoja    := Space(2)
	Private cCliFat   := Space(6)
	Private cLojaFat  := Space(2)
	Private cPrefix   := Space(3)
	Private dVencto   := Ctod(Space(8))
	Private dDataDe   := dDataBase
	Private dDataAte  := dDataBase
	Private nTotAbat  := 0 //-- Uso FINA280
	Private nValorFat := 0 //-- Uso FINA280
	Private nValorF   := 0 //-- Uso FINA280
	Private nVLCruz   := 0 //-- Uso FINA280
	Private nVlrAtu   := 0 //-- Uso FINA280
	Private nQtdCtrc  := 0
	Private nValtot   := 0
	Private aSetKey   := {}
	Private aAutoCab  := {}
	Private nMoeAut   := 0
	Private cTipAut   := ""
	Private cFilAut   := ""
	Private dVenAut   := Ctod(Space(8))
	Private cNatAut   := ""
	Private nDTCRECISS:= 0  // Essa variavel e usada no FINXFIN
	Private nDTCISS   := 0	// Essa variavel e usada no FINXFIN
EndIf

Default xAutoCab  := {}
Default nOpcAuto  := 3
Default xTipAut   := ""
Default xFilAut   := ""
Default xCliFat   := ""
Default xLojFat   := ""
Default xMoeAut   := 0
Default xEmiAut   := Ctod(Space(8))
Default xVenAut   := Ctod(Space(8))
Default xNatAut   := ""

CheckHLP("PTMSA85027", {"Não foram localizados documentos da ",;
                        "fatura."},{''},{''},.T.)

CheckHLP("PTMSA85028", {"Este cliente exige que a fatura seja",;
                        " proveniente de uma Pré-Fatura. Exec",;
                        "ute a rotina de pré-fatura!         "},{''},{''},.T.)

If cTmsERP ==  '1' //-- ERP Datasul
    return Iif(l850Auto, TMSA851(xAutoCab, nOpcAuto, xFilAut, xCliFat, xLojFat, xMoeAut, xEmiAut, xVenAut), TMSA851())
EndIf
If Type("aPanAgeTMS") == "U"
	aPanAgeTMS := Array(6)
EndIf
lPainel := IsInCallStack("TMSAF76") .And. !Empty(aPanAgeTMS)

//--MV_PAR01: Considera Loja
Pergunte("TMA850",.F.)

If l850Auto
	If nOpcAuto == 3 .Or. nOpcAuto == 5
		lMsHelpAuto := .T.
		aAutoCab := aClone(xAutoCab)
		cTipAut  := xTipAut
		cFilAut  := xFilAut
		cCliFat  := xCliFat
		cLojaFat := xLojFat
		nMoeAut  := xMoeAut
		dEmisFat := xEmiAut
		dVenAut  := xVenAut
		cNatAut  := xNatAut
		MBrowseAuto(nOpcAuto, Aclone(aAutoCab), "SE1", .F.)
	EndIf
Else
	//--Inicializa as teclas de atalho
	AAdd(aSetKey,  { VK_F12,{|a,b| Pergunte("TMA850",.T.)}} )
	TMSKeyOn(aSetKey)

	DbSelectArea("SE1")
	//-- Filtro para MBrowse
	If ExistBlock("TM850FIL")
		cFilMbrPE := ExecBlock("TM850FIL",.F.,.F.)
		If(Valtype(cFilMbrPE) = "C") .And. !Empty(cFilMbrPE)
			cFilMbrow := cFilMbrPE
		EndIf
	EndIf

	If !lPainel
		MBrowse(6,1,22,75,"SE1",,,,,,Tmsa850Leg(),,,,,,,,cFilMbrow)
	Else
		If (at("(",aPanAgeTMS[6])>0)
			&(aPanAgeTMS[6])
		Else
			&(aPanAgeTMS[6] + "('" + aPanAgeTMS[1] + "'," + StrZero(aPanAgeTMS[2],10) + "," + StrZero(aPanAgeTMS[3],2) + ")")
		EndIf
	EndIf

	//-- Finaliza teclas de atalhos
	TMSKeyOff(aSetKey)
EndIf

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa850Aut³ Autor ³ Claudio D. de Souza   ³ Data ³ 09/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Marca‡ao dos doctos para emissao de fatura                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa850Aut(cAlias,nReg,nOpcx,oTempTable,cCliDev,cLojDev,cNumPre,dDataMax,dDataMin,aMsgErr)

Local cVar
Local lUsado    := .F.
Local aTam      := {}
Local nOpca     := 0
Local nCnt1     := 0
Local nCnt2     := 0
Local nMoedFat  := 1
Local cPrfx     := ""
Local dVencFat  := CtoD(Space(08))
Local lEof      := .F.
Local lFatVazia := .F.
Local lMrkDoc   := .F.
Local aChaveLbn := {}
Local aTitulos  := {}
Local aDoctos   := {}
Local aCampos   := {	{"DT6_FILDOC" , PesqPict("DT6","DT6_FILDOC"  )},; // 2
						{"DT6_DOC"    , PesqPict("DT6","DT6_DOC"     )},; // 3
						{"DT6_SERIE"  , PesqPict("DT6","DT6_SERIE"   )},; // 4
						{"DT6_VALTOT" , PesqPict("DT6","DT6_VALTOT"  )},; // 5
						{"DT6_ACRESC" , PesqPict("DT6","DT6_ACRESC"  )},; // 6
						{"DT6_DECRES" , PesqPict("DT6","DT6_DECRES"  )},; // 7
						{"_SI_VALFAT" , PesqPict("DT6","DT6_VALFRE" )},; // 8
						{"DT6_DATEMI" , PesqPict("DT6","DT6_DATEMI"  )},; // 9						
						{"_SI_UFDEST" , PesqPict("SA1","A1_EST"      )},; // 10
						{"DT6_NUM" 	, PesqPict("DT6","DT6_NUM"  	 )} } // 11
Local aColSiz    := {0, 30, 50, 45, 65, 60, 60, 65, 40, 30}
Local lPrefix    := .F. //-- Variavel para controlar a digitacao do campo 'Prefixo'
Local nValor     := 0
Local cNat       :=	Space(10)
Local aVFContr   := {}
Local aFtGeradas := {}
Local aCamposBkp := {}
Local lTMSA850   := Upper(AllTrim(FunName())) == "TMSA850"
Local lOkPreFat  := .T.
Local lMV_TMSFMSG := SuperGetMv("MV_TMSFMSG",.F.,.T.)

Local aAreaDT6    := DT6->(GetArea())
 
PRIVATE aHeader := {}
PRIVATE aCols   := {}
PRIVATE oValTot
PRIVATE nValTot := 0
PRIVATE nUsado  := 0 //-- Uso FINA280
PRIVATE nValCruz:= 0 //-- Uso FINA280
PRIVATE nVlrAtu := 0 //-- Uso FINA280
PRIVATE cTipo   := Criavar("E1_TIPOFAT")
PRIVATE cFilDeb := Space(TamSx3("E1_FILDEB")[1]) // SuperGetMv("MV_FATFIL",,"")
PRIVATE nMaxCtrc:= 0
PRIVATE nMinCtrc:= 0
PRIVATE dVencCond := CtoD(Space(08))

If Type("l850Auto") == "U"
	PRIVATE aRotina   := MenuDef()
	PRIVATE dEmisFat  := SuperGetMv("MV_DATAFAT",,dDataBase)
	PRIVATE l850Auto  := .F.
	Private cCadastro := STR0005 //"Faturas a Receber"
EndIf

If  Type("cCli") == "U" 
	Private cCli      := Space(6)
	Private _cLoja    := Space(2)
	Private cCliFat   := Space(6)
	Private cLojaFat  := Space(2)
	Private cPrefix   := Space(3)
	Private dVencto   := Ctod(Space(8))
	Private dDataDe   := dDataBase
	Private dDataAte  := dDataBase
	Private nTotAbat  := 0 //-- Uso FINA280
	Private nValorFat := 0 //-- Uso FINA280
	Private nValorF   := 0 //-- Uso FINA280
	Private nVLCruz   := 0 //-- Uso FINA280
	Private nQtdCtrc  := 0
	Private aSetKey   := {}
	Private aAutoCab  := {}
	Private nMoeAut   := 0
	Private cTipAut   := ""
	Private cFilAut   := ""
	Private dVenAut   := Ctod(Space(8))
	Private cNatAut   := ""
	Private nDTCRECISS:= 0 // Essa variavel e usada no FINXFIN
	Private nDTCISS   := 0 // Essa variavel e usada no FINXFIN	
EndIf

Default oTempTable := {}
Default cCliDev    := ""
Default cLojDev    := ""
Default cNumPre    := ""
Default dDataMax   := CToD("")
Default dDataMin   := CToD("")
Default aMsgErr    := {}

//-- Limpa o filtro por conta do browse utilizando FWBrwRelation()
DT6->(DbClearFilter())
DT6->(DbCloseArea())

If !Empty(oTempTable)
	nValFat  := 0
	nQtdCTRC := 0
EndIf

If Type("l850Auto") == "U"
	l850Auto  := .F.
EndIf

//-- Finaliza Teclas de Atalhos
If lTMSA850
	TmsKeyOff(aSetKey)
EndIf

//-- MV_PAR01: Considera Loja
Pergunte("TMA850",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para manipular as colunas de aCampos.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("TM850MEC")
	aCamposBkp := aClone(aCampos)
	aCampos := ExecBlock("TM850MEC",.F.,.F.,{aCampos})
	RECNOCTRC := Len(aCampos) + 2
	If ValType(aCampos) != "A" .Or. Len(aCampos) <= 0
		aCampos   := aClone(aCamposBkp)
		RECNOCTRC := Len(aCampos)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o campo A1_CLIFAT est  em uso                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lUsado := X3Uso(GetSX3Cache("A1_CLIFAT", "X3_USADO"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero do Lote - FinxFun                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LoteCont("FIN")

cPrefix := PadR(SuperGetMv("MV_FATPREF",,Space(3)),3)
If Empty(cPrefix)
	cPrefix := Space(3)
EndIf

dDataDe  := dDataBase
dDataAte := dDataBase
nValorFat:= 0

If ExistBlock("TM850PREF")
	cPrfx := ExecBlock("TM850PREF",.F.,.F.) //PE para manipular o prefixo da fatura
	If !Empty(cPrfx) .And. ValType(cPrfx) == "C"
		cPrefix := cPrfx
	EndIf
EndIf

//-- Rotina automatica de geracao de Faturas por Documentos
If l850Auto
	cTipo   := cTipAut
	cFilDeb := cFilAut
	nValor  := 0
	For nCnt1 := 1 To Len(aAutoCab)
		AAdd(aDoctos,{.T.}) //-- CTE/CTRC marcado para faturar
		nLen := Len(aDoctos)
		For nCnt2 := 1 To Len(aCampos)
			cCampo := aCampos[nCnt2, 1]
			nPos := aScan(aAutoCab[nCnt1], {|x| x[1]==cCampo} )
			AAdd(aDoctos[nLen], Iif(nPos > 0, aAutoCab[nCnt1, nPos, 2],Nil))
		Next nCnt2
		//-- RECNO do CTE informado na MsExecAuto
		nPos := aScan(aAutoCab[nCnt1], {|x| x[1]=="RECNO"} )
		AAdd(aDoctos[nLen], aAutoCab[nCnt1, nPos, 2]) //-- RecNo CTE/CTRC
	Next nCnt1
	AEval( aDoctos, {|e| nValor += e[VALFAT]} )
	TMS850Cli(cCliFat,cLojaFat, @cCliFat, @cLojaFat, @dVencFat,@nValorFat,@nMaxCtrc,lUsado,@dVencCond)	
	If Tms850Ok(cFilDeb, cCliFat, cLojaFat, @aChaveLbn, dVenAut, dVencCond)
		TMSA850Grv(.F.,"",nMoeAut,aDoctos,dEmisFat,dVenAut,,,,nValor,cNatAut,,.T.,,dVencCond)
	EndIf
	If !Empty(aChaveLbn)
		aEval(aChaveLbn, {|e| UnLockByName(e,.T.,.F.) } ) // Libera Lock
	EndIf
	Return Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebe dados a serem digitados                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam    := TamSX3("E1_CLIENTE")
cCli    := Space(aTam[1])
cCliFat := Space(aTam[1])

aTam    := TamSX3("E1_LOJA")
_cLoja  := Space(aTam[1])
cLojaFat:= Space(aTam[1])

lPrefix := Empty( cPrefix )

DbSelectArea(cAlias)

//-- Funcao para montagem da tela inicial com os parametros da fatura e selecao de documentos
//-- Utilizada no TMSA850 e TMSA851
If Empty(oTempTable)
	TMSA850Ini(@cPrefix, @lPrefix, @cTipo   , @cNat     , @cVar   , @dEmisFat, @cCli    , @_cLoja, @dVencFat, @lFatVazia,;
	           @lMrkDoc, @dDataDe, @dDataAte, @nValorFat, @cCliFat, @cLojaFat, @nMaxCtrc, @lUsado, @cFilDeb , @nMinCtrc, @aChaveLbn, @nOpca, @dVencCond)
Else
	cPrefix   := PadR(SuperGetMv("MV_FATPREF",,Space(TamSX3("E1_PREFIXO")[1])),TamSX3("E1_PREFIXO")[1])
	cTipo     := PadR(SuperGetMv("MV_TIPFAT" ,,Space(TamSX3("E1_TIPO")[1]))   ,TamSX3("E1_TIPO")[1])
	cNat      := PadR(SuperGetMv("MV_NATFAT" ,,Space(TamSX3("E1_NATUREZ")[1])),TamSX3("E1_NATUREZ")[1])
	cVar      := StrZero(1,TamSX3("E1_MOEDA")[1])
	dEmisFat  := dDataBase
	cCli      := cCliDev
	_cLoja    := cLojDev
	dVencFat  := CToD("")
	dDataDe   := dDataMin
	dDataAte  := dDataMax
	nValorFat := 0
	cCliFat   := cCliDev
	cLojaFat  := cLojDev
	nMaxCtrc  := 0
	lUsado    := X3Uso(GetSX3Cache("A1_CLIFAT","X3_USADO"))
	cFilDeb   := cFilAnt
	nMinCtrc  := 0
	nOpca     := 1
	dVencCond := CToD("")
EndIf

If nOpca == 1
	nMoedFat := Val(Substr(cVar,1,2))
	If !lFatVazia
	
		//-- Funcao para retornar documentos para selecao na fatura
		//-- Utilizada no TMSA850 e TMSA851
		aDoctos   := TMSA850Doc(aCampos, cCli, _cLoja, dDataDe, dDataAte, cFilDeb, nMoedFat, nMinCtrc, , oTempTable, cCliDev, cLojDev, cNumPre, @aMsgErr)
		lEof      := Len(aDoctos) = 0

		//-- Se o perfil do cliente não permitir "Quebra de pré-fatura", valida a qtde de doctos da QRY x Pré-fat
		If !Empty(oTempTable)
			If !(lOkPreFat := Len(aDoctos) == (oTempTable:GetAlias())->(RecCount()))
				aAdd(aMsgErr, {STR0175 + cNumPre + STR0176 +AllTrim(Str( (oTempTable:GetAlias())->(RecCount()) )) + STR0177 + AllTrim(Str(Len(aDoctos))) + STR0178, "00",""}) //-- "Pré-Fatura " ## " continha " ## " doctos, mas apenas " ## " estão aptos!"
			EndIf
		EndIf
	Else
		// Cria a matriz de doctos. a serem faturados, em branco
		AAdd(aDoctos,{.F.})
		nLen := Len(aDoctos)
		aEval(aCampos, { |e| AAdd(aDoctos[nLen], "" ) })
		AAdd(aDoctos[nLen], 0)
	EndIf

	If lEof .Or. !lOkPreFat
		If lEof .And. Empty(oTempTable)
			Help(" ",1,"REGNOIS") //"Nao existe registro relacionado a este codigo"
		EndIf
	Else
		nOpcA := 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array com campos a serem mostrados na marcacao de ctrc   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aTitulos," ")
		aEval(aCampos, { |e|	If(e[1] = "_SI_VALFAT", AAdd(aTitulos,STR0100),; //"Valor a faturar"
								If(e[1] = "_SI_UFDEST", AAdd(aTitulos,STR0101),; //"Uf Destino"
								AAdd(aTitulos,Posicione('SX3', 2, AllTrim(If(e[1]="DT6_VALTOT","DT6_VALFRE",e[1])), 'X3Titulo()')))) } )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Marca os titulos ate o valor informado para a fatura         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(oTempTable)
			nValor  := 0
			nQtdCtrc:= 0
		Else
			nValor  := nValFat
		EndIf
	
		//-- Se NAO for uma fatura vazia, marca todos os documentos
		nValorF := nValorFat
	
		//-- Monta a tela
		nOpcA := Tmsa850Tela( lFatVazia, cPrefix, "", cNat, nMoedFat, nOpcX, ;
								aCampos, aTitulos, aDoctos, @nValor, 0, .F.,.F.,,,,,,,,,, aVFContr, ;
								lMrkDoc, aColSiz, dVencFat, @aFtGeradas, dVencCond, oTempTable)
	EndIf
EndIf

If !lMV_TMSFMSG .And. !l850Auto
	While nOpcA == 1 
		aDoctos  := TMSA850Doc(aCampos, cCliFat, _cLoja, dDataDe, dDataAte, cFilDeb, nMoedFat, nMinCtrc, , oTempTable, cCliDev, cLojDev, cNumPre, @aMsgErr)
		nOpcA 	 := Tmsa850Tela( lFatVazia, cPrefix, "", cNat, nMoedFat, nOpcX, ;
									aCampos, aTitulos, aDoctos, @nValor, 0, .F.,.F.,,,,,,,,,, aVFContr, ;
									lMrkDoc, aColSiz, dVencFat, @aFtGeradas, dVencCond, oTempTable)
	EndDo
EndIf

cFatura   := CriaVar("DT6_FATURA")
cCli      := Space(6)
cNat      := Space(10)
cPrefix   := Space(3)
_cLoja    := Space(2)
dDataDe   := dDatabase
dDataAte  := dDataBase
nValorF   := 0
nValorFat := 0
nValCruz  := 0
nVlrAtu   := 0

If !Empty(aChaveLbn)
	aEval(aChaveLbn, {|e| UnLockByName(e,.T.,.F.) } ) // Libera Lock
EndIf

//-- Atualiza tela do lote de notas fiscais quando vindo de lá
If Type("oBrowseUp") != "U"
	If FindFunction("TMSA170Ref") .And. IsInCallStack('TMSA170')
		TMSA170Ref()
	EndIf
EndIf

//-- Inicializa Teclas de Atalhos
If lTMSA850
	TmsKeyOn(aSetKey)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("DT6")
DbSetOrder(1)

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

//-- Retorna a area por conta da limpeza de filtro
If IsInCallStack("TMSA170")
	RestArea(aAreaDT6)
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tms850Ok    ³ Autor ³ Claudio D. de Souza  ³ Data ³ 17/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao do botao ok para emitir a fatura                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial de Debito                                    ³±±
±±³          ³ ExpC2 - Cliente Devedor                                     ³±±
±±³          ³ ExpA1 - Array com Filial/Cliente/Loja Travados              ³±±
±±³          ³ ExpD1 - Data Vencimento Fatura                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tms850Ok(cFilDeb, cCliDev, cLojDev, aChaveLbn, dVencFat, dVencCond,dEmisFat)

Local lRet     := .T.
Local cChave   := ""
Local aAreaSa1 := SA1->(GetArea())
Local aArea    := GetArea()
Local cTmsERP  := SuperGetMV("MV_TMSERP",,'0')
Local aPerfil  := {}
Local lCpoMult := DUO->(ColumnPos('DUO_MULTFA'))
Local lMultFat := .F.

If l850Auto
	Default dEmisFat := dDataBase
Else	
	Default dEmisFat := CToD("")
EndIf

	If lCpoMult
		aPerfil := TmsPerfil(cCliDev,cLojDev,,.F.)
		If Len(aPerfil) >= 60 .And. aPerfil[60] == "1" //--Permite multifaturamento
			lMultFat := .T.
		EndIf
	EndIf
	
	If Empty(dEmisFat)
		Help(1," ","NVAZIO",,STR0058,4,0) //"Este campo deve ser informado"
		lRet:= .F.
	EndIf

	If cTmsERP == "0" //-- ERP Protheus
		If !Empty(dVencCond) .And. dVencFat <> dVencCond .And. !l850Auto
			If !MsgYesNo("A data informada no vencimento da fatura, e diferente da data da condição de pagamento informada no cadastro do cliente, assumir a nova data informada?",STR0151)
				dVencFat := dVencCond
			EndIf
		EndIf
		
		If Empty(dVencFat) .And. l850Auto 
			dVencFat := dVencCond
		EndIf
	EndIf

	If lRet
		If !lMultFat //--Nao permite o multi faturamento
			If mv_par01 == 2 // Se nao considera loja, trava todas as lojas para nao permitir faturamento por outro usuario
				SA1->(DbSetOrder(1))
				SA1->(MsSeek(FWxFilial("SA1") + cCliDev))
				While SA1->(!Eof() .And. A1_COD == cCliDev)
					//-- Parametros da Funcao LockByName() :
					//   1o - Nome da Trava
					//   2o - usa informacoes da Empresa na chave
					//   3o - usa informacoes da Filial na chave 
					cChave := "FAT"+cFilDeb+cCliDev+SA1->A1_LOJA
					If LockByName(cChave,.T.,.F.)
						AAdd(aChaveLbn, cChave )
					Else
						lRet := .F.
						Help(" ",1,"TMSA85001") //"Existe outro usuário gerando fatura para este cliente. Não é permitida a geração de fatura para o mesmo cliente por dois usuários"
						Exit
					EndIf
					SA1->(DbSkip())
				EndDo
			Else
				//-- Parametros da Funcao LockByName() :
				//   1o - Nome da Trava
				//   2o - usa informacoes da Empresa na chave
				//   3o - usa informacoes da Filial na chave 
				cChave := "FAT"+cFilDeb+cCliDev+cLojDev
				If !LockByName(cChave,.T.,.F.)
					//-- Se Ja estiver reservado retorna .F. pois nao pode executar a Rotina	
					Help(" ",1,"TMSA85001") //"Existe outro usuário gerando fatura para este cliente. Não é permitida a geração de fatura para o mesmo cliente por dois usuários"
					lRet := .F.
				Else
					AAdd(aChaveLbn, cChave )
				EndIf
			EndIf		
		EndIf
		If lRet
			lRet := Tmsa850Venc(dEmisFat,cCliDev,cLojDev,@dVencFat)
		EndIf
	EndIf

	// restaura ambiente
	SA1->(RestArea(aAreaSa1))
	RestArea(aArea)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa850VEmis³ Autor ³ Claudio D. de Souza  ³ Data ³ 14/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida data de emissao da fatura                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tmsa850VEmis()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data Emissao Fatura                                 ³±±
±±³          ³ ExpC1 - Cliente Devedor                                     ³±±
±±³          ³ Expc2 - Loja Cliente Devedor                                ³±±
±±³          ³ ExpD2 - Data Vencimento Fatura                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa850VEmis(dEmisFat,cCliente,cLoja,dVencFat)
Local lRet  := .T.
Local lVenc := ExistBlock("TM850EMIS")

If lVenc
	lRet := ExecBlock( "TM850EMIS", .F., .F.,{cCliente, cLoja, dEmisFat, dVencFat})
	If ValType(lRet) != "L" //-- Se retornar Data,Caracter ou outro tipo que cause error.log,
		lRet := .F.         //-- o retorno sera falso. Se o retorno for Logico, entao sera aceito.
	EndIf
EndIf

If Empty(dEmisFat)
	NaoVazio(dEmisFat)
	lRet := .F.
Endif

If lRet .and. CtbInUse()
	// Valida a Emissao da fatura para nao ser menor que o fechamento contabil	
	If !CtbValiDt(1,dEmisFat)
		lRet := .F.
	Endif
Endif

If lRet .and. dEmisFat > dDataBase
	Help(" ",1,"TMSA85010") //"Emissão da fatura não pode ser superior a data base do sistema"
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento n„o ‚ menor que data limite de ³
//³ movimentacao no financeiro - MV_DATAFIN						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := DtMovFin(dEmisFat,,"2")

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa850Ddat ³ Autor ³ Alex Amaral          ³ Data ³ 26/03/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida data de Titulos emitidos entre:                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tmsa850Ddat()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa850Ddat(dDataDe,dDataAte)
Local lRet  := .T.

If !Empty(dDataDe) .And. !Empty(dDataAte) .And. dDatade > dDataBase
	MsgAlert('A data De: não pode ser maior que a data do Sistema')
	lRet := .F.
EndIf

If lRet .And. !Empty(dDataAte) .And. dDataAte > dDataBase 
	MsgAlert('A data Até: não pode ser maior que a data do Sistema')
	lRet := .F.
EndIf

If lRet .And. !Empty(dDataDe) .And. !Empty(dDataAte) .And. dDataAte < dDataDe 
		MsgAlert('A data Até: não pode ser menor que a data De:')
		lRet := .F.
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa850Venc ³ Autor ³ Claudio D. de Souza  ³ Data ³ 27/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida data de vencimento da fatura                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tmsa850Venc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data Emissao Fatura                                 ³±±
±±³          ³ ExpC1 - Cliente Devedor                                     ³±±
±±³          ³ Expc2 - Loja Cliente Devedor                                ³±±
±±³          ³ ExpD2 - Data Vencimento Fatura                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa850Venc(dEmisFat,cCliente,cLoja,dVencFat)
Local lRet  := .T.
Local lVenc := ExistBlock("TM850VENC")

If lVenc
	lRet := ExecBlock( "TM850VENC", .F., .F.,{cCliente, cLoja, dEmisFat, dVencFat})
	If ValType(lRet) != "L" //-- Se retornar Data,Caracter ou outro tipo que cause error.log,
		lRet := .F.         //-- o retorno sera falso. Se o retorno for Logico, entao sera aceito.
	EndIf
EndIf

If lRet .And. !Empty(dVencFat) .And. dVencFat < dEmisFat
	Help(" ",1,"TMSA85011") //"Vencimento da fatura não pode ser inferior a data de emissão"
	lRet := .F.
Endif

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa850Vis³ Autor ³ Claudio D. De Souza   ³ Data ³ 15/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualizacao dos titulos que montam uma fatura             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA850Vis(cAlias,nReg,nOpcx)
Local aAreaDt6     := DT6->(GetArea())
Local aInfVis      := Tmsa850Erp()
Local nOpca        := 0
Local nTotFat      := 0
Local nTotCanc     := 0
Local nValor       := 0
Local cQuery       := ""
Local lEof         := .T.
Local aStru        := DT6->(DbStruct())
Local aTitulos     := {}
Local aDoctos      := {}
Local aCampos      := {	{"DT6_FILDOC" , PesqPict("DT6","DT6_FILDOC" )},; // 2
						{"DT6_DOC"    , PesqPict("DT6","DT6_DOC"    )},; // 3
						{"DT6_SERIE"  , PesqPict("DT6","DT6_SERIE"  )},; // 4
						{"DT6_VALTOT" , PesqPict("DT6","DT6_VALTOT" )},; // 5
						{"DT6_ACRESC" , PesqPict("DT6","DT6_ACRESC" )},; // 6
						{"DT6_DECRES" , PesqPict("DT6","DT6_DECRES" )},; // 7
						{"_SI_VALFAT" , PesqPict("DT6","DT6_VALFRE")},; // 8
						{"DT6_DATEMI" , PesqPict("DT6","DT6_DATEMI" )},; // 9
						{"_SI_UFDEST" , PesqPict("SA1","A1_EST"     )} } // 10
Local aColSiz      := {0, 30, 50, 45, 65, 60, 60, 65, 40, 30}

PRIVATE nValCruz   := 0 //-- Uso FINA280
PRIVATE nVlrAtu    := 0 //-- Uso FINA280
PRIVATE nMaxCtrc   := 0
PRIVATE nMinCtrc   := 0
PRIVATE nValorFat  := 0

If  Type("cCli") == "U" 
	Private cCli      := Space(6)
	Private _cLoja    := Space(2)
	Private cCliFat   := Space(6)
	Private cLojaFat  := Space(2)
	Private cPrefix   := Space(3)
	Private dVencto   := Ctod(Space(8))
	Private dDataDe   := dDataBase
	Private dDataAte  := dDataBase
	Private nTotAbat  := 0 //-- Uso FINA280
	Private nValorF   := 0 //-- Uso FINA280
	Private nQtdCtrc  := 0
	Private nValtot   := 0
	Private aSetKey   := {}
	Private aAutoCab  := {}
	Private nMoeAut   := 0
	Private cTipAut   := ""
	Private cFilAut   := ""
	Private dVenAut   := Ctod(Space(8))
	Private cNatAut   := ""
	Private nDTCRECISS:= 0 // Essa variavel e usada no FINXFIN
	Private nDTCISS   := 0 // Essa variavel e usada no FINXFIN	 
EndIf

If IsInCallStack("TMSA510")
	Private cCadastro := STR0005 //"Faturas a Receber"
EndIf

//-- Limpa o filtro por conta do browse utilizando FWBrwRelation()
DT6->(DbClearFilter())
DT6->(DbCloseArea())

Pergunte("TMA850",.F.)

cQuery := "SELECT SUM(DVV.DVV_VALTOT+DVV.DVV_ACRESC-DVV.DVV_DECRES) TOTEXCLUIDO, SUM(DT6.DT6_VALFAT+DVV.DVV_ACRESC-DVV.DVV_DECRES) FATEXCLUIDO "
cQuery += "FROM "+RetSqlName("DVV")+ " DVV, "
cQuery +=         RetSqlName("DT6")+ " DT6 "
cQuery += "WHERE "
cQuery += " DVV_FILIAL='"	+ FWxFilial("DVV") + "'"
cQuery += " AND DVV.DVV_PREFIX = '" + aInfVis[E1PREFIXO] +"'"
cQuery += " AND DVV.DVV_NUM    = '" + aInfVis[E1NUM] +"'"
cQuery += " AND DVV.DVV_TIPO   = '" + aInfVis[E1TIPO] +"'"
cQuery += " AND DT6.DT6_FILIAL = '" + FWxFilial("DT6") + "'"
cQuery += " AND DT6.DT6_FILDOC = DVV.DVV_FILDOC"
cQuery += " AND DT6.DT6_DOC    = DVV.DVV_DOC"
cQuery += " AND DT6.DT6_SERIE  = DVV.DVV_SERIE"
cQuery += " AND DVV.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
TcSetField("TRB","TOTEXCLUIDO"  ,"N", 17,2)
TcSetField("TRB","FATEXCLUIDO"  ,"N", 17,2)
If TRB->FATEXCLUIDO > 0
	nTotCanc := TRB->FATEXCLUIDO
Else
	nTotCanc := TRB->TOTEXCLUIDO
EndIf
TRB->(DbCloseArea())
RestArea( aAreaDt6 )

cQuery := ""
// Adiciona os campos que existirem no DT6 na matriz de campos a serem selecionados
aEval(aCampos,{|e| If(DT6->(FieldPos(e[1])) > 0, cQuery += ","+AllTrim(e[1]), Nil)})
cQuery := "SELECT "+SubStr(cQuery,2)
cQuery +=         ","+"DT6_VALFAT "
cQuery +=         ","+"DT6.R_E_C_N_O_ RECNO "
cQuery +=         ","+"DUY.DUY_EST UFDEST "
cQuery += "FROM "+RetSqlName("DT6")+ " DT6 "
cQuery += "LEFT JOIN "+RetSqlName("DUY")+ " DUY "
cQuery += "  ON DUY.DUY_FILIAL = '"+FWxFilial("DUY")+"'"
cQuery += " AND DUY.DUY_GRPVEN = DT6.DT6_CDRDES"
cQuery += " AND DUY.D_E_L_E_T_ = ' ' "
cQuery += "WHERE "
cQuery += "DT6_FILIAL='"	+ FWxFilial("DT6") + "'"
cQuery += " AND DT6.DT6_FILDEB = '" + aInfVis[E1FILDEB] + "'"
//Foi removido a Cod/loja da query para os casos do F12 Considera Lojas SIM/NAO e para os casos do Cliente de Faturamento A1_CLIFAT
cQuery += " AND DT6.DT6_PREFIX ='" + aInfVis[E1PREFIXO] + "'"
cQuery += " AND DT6.DT6_NUM    ='" + aInfVis[E1NUM]     + "'"
If aInfVis[E1TIPO] $ MVABATIM + "|"+ MVIRABT +"|" + MVINABT 
	cQuery += " AND DT6.DT6_TIPO NOT IN" + FormatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT,"|") + " "
Else
	cQuery += " AND DT6.DT6_TIPO   ='" + aInfVis[E1TIPO]    + "' "
EndIf

cQuery += " AND DT6.D_E_L_E_T_  = ' '"
cQuery += " ORDER BY " + SqlOrder(DT6->(IndexKey(1))+"+RECNO")
AAdd(aStru, {"RECNO","N",10,0})
Processa({|| Tms850QryToMem(cQuery, aStru, aCampos, @aDoctos )}) // Cria arquivo temporario
lEof := Len(aDoctos) = 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Certifica se foram encontrados registros na condi‡„o selecionada       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEof
	If nTotCanc > 0
		T850ConExc(nTotCanc)
	Else
		Help(" ",1,"TMSA85027")	//-- "Não foram localizados documentos da fatura."
	EndIf
Else
	// Localiza o cliente para exibir o nome
	SA1->(DbSetOrder(1))
	SA1->(MsSeek(FWxFilial("SA1")+aInfVis[E1CLIENTE]+aInfVis[E1LOJA])) // 
	
	AEval( aDoctos, {|e| Iif(!Posicione("DT6",1,FWxFilial("DT6") + e[FILDOC] + e[CTRC] + e[SERIE],"DT6_DOCTMS") $ ("B,C,H,I,N,O") .Or. ;
	 						Empty(Posicione('DUI',1,FWxFilial('DUI',DT6->DT6_FILDOC)+DT6->DT6_DOCTMS,'DUI_DOCFAT')) ,nValor += e[VALFAT],)} )

	If Empty(nValor)
		nValor  := (aInfVis[E1VALOR] - aInfVis[E1DECRESC])
	EndIf
	
	nTotFat := nValor
	nQtdCtrc:= Len(aDoctos)
	nValorF := aInfVis[E1VALOR]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array com campos a serem mostrados na marcacao de ctrc   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd(aTitulos," ")
	aEval(aCampos, { |e|	If(e[1] = "_SI_VALFAT", AAdd(aTitulos,STR0107),;	//"Valor faturado"
							If(e[1] = "_SI_UFDEST", AAdd(aTitulos,STR0101),; 	//"Uf Destino"
							AAdd(aTitulos,Posicione('SX3', 2, AllTrim(If(e[1]="DT6_VALTOT","DT6_VALFRE",e[1])), 'X3Titulo()')))) } )
	// Monta a tela
	nOpcA := Tmsa850Tela(.F., aInfVis[E1PREFIXO], aInfVis[E1NUM], aInfVis[E1NATUREZ], aInfVis[E1MOEDA], nOpcX, aCampos, aTitulos,aDoctos,@nValor,0,.F.,.T., nTotCanc,,,,,,,,,,,aColSiz)
EndIf

//-- Retorna a area por conta da limpeza de filtro
If IsInCallStack("TMSA170")
	RestArea(aAreaDT6)
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tms850Pesq³ Autor ³ Claudio D. De Souza   ³ Data ³08.02.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Tela de pesquisa                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto ListBox contendo documentos                 ³±±
±±³          ³ ExpA1 = Array contendo Doctos                              ³±±
±±³          ³ ExpN1 = Origem da pesquisa 1=aDoctos;2=aCols               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function T850Pesq(oObj, aDoctos, nOnde)
Local nAscan  := 0
Local nOpca   := 0
Local cFilDoc := Space(Len(DT6->DT6_FILDOC))
Local cDoc    := Space(Len(DT6->DT6_DOC))
Local cSerie  := Space(Len(DT6->DT6_SERIE))
Local oDlg

DEFINE MSDIALOG oDlg TITLE STR0108 From 9,0 To 16,75 OF oMainWnd //"Pesquisa de docto."
	@  35,   5 Say STR0109   OF oDlg PIXEL SIZE 20,9 //"Fil. doc."
	@  35,  30 MSGET cFilDoc OF oDlg PIXEL PICTURE "@!"
	@  35,  90 Say STR0110   OF oDlg PIXEL SIZE 20,9 //"Docto."
	@  35, 110 MSGET cDoc    OF oDlg PIXEL PICTURE "@!"
	@  35, 175 Say STR0111   OF oDlg PIXEL SIZE 15,9 //"Série"
	@  35, 195 MSGET cSerie  OF oDlg PIXEL PICTURE "@!"
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca := 0,oDlg:End()}) CENTER

If nOpca == 1
	If nOnde == 1
		// Pesquisa na matriz de doctos.
		nAscan :=  Ascan(aDoctos, {|e| e[2]+e[3]+e[4] == cFilDoc + cDoc + cSerie } )
	Else
		// Pesquisa em aCols
		nAscan :=  Ascan(aDoctos, {|e| e[1]+e[2]+e[3] == cFilDoc + cDoc + cSerie } )
	Endif
	// Se encontrou
	If nAscan > 0
		// Atualiza a linha do objeto
		If nOnde == 1
			oObj:nAt := nAscan
			oObj:Refresh(.T.)
		Else
			oObj:Goto(nAscan)
		EndIf
	Else
		Help(" ",1,"TMSA85002") //"Docto. não encontrado!"
	EndIf
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa850Exc³ Autor ³ Claudio D. De Souza   ³ Data ³ 14/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Excluir doctos de uma fatura                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa850Exc(cAlias, nReg, nOpcx, aM, aDocExclui, lMostraTela, lAnulacao, aVetPre, nLinha, aMsgErr)

Local aArea        := GetArea()
Local aAreaDt6     := DT6->(GetArea())
Local aAreaSE1     := SE1->(GetArea())
Local cTmsERP      := SuperGetMV("MV_TMSERP",,'0')
Local aInfVis      := Tmsa850Erp()
Local nOpca        := 0
Local nValor       := 0
Local nTotFat      := 0
Local nTotExcluido := 0
Local nPos1        := 0
Local nPos2        := 0
Local nCnt1        := 0
Local nCnt3        := 0
Local cQuery       := ""
Local cAliasQry    := ""
Local aStru        := DT6->(DbStruct())
Local aTitulos     := {}
Local aDoctos      := {}
Local aCampos      := {	{"DT6_FILDOC" , PesqPict("DT6","DT6_FILDOC" )},; // 02
						{"DT6_DOC"    , PesqPict("DT6","DT6_DOC"    )},; // 03
						{"DT6_SERIE"  , PesqPict("DT6","DT6_SERIE"  )},; // 04
						{"DT6_VALTOT" , PesqPict("DT6","DT6_VALTOT" )},; // 05
						{"DT6_ACRESC" , PesqPict("DT6","DT6_ACRESC" )},; // 06
						{"DT6_DECRES" , PesqPict("DT6","DT6_DECRES" )},; // 07
						{"_SI_VALFAT" , PesqPict("DT6","DT6_VALFAT" )},; // 08
						{"DT6_DATEMI" , PesqPict("DT6","DT6_DATEMI" )},; // 09
						{"_SI_UFDEST" , PesqPict("SA1","A1_EST"     )} } // 10
Local aColSiz      := {0, 30, 50, 45, 65, 60, 60, 65, 40, 30}
Local lEof         := .T.
Local cChaveLbn    := ""
Local lTM850Del    := ExistBlock("TM850DEL")
Local lDelFat      := .F.
Local dDatFTMS     := SuperGetMv("MV_DATATMS",.F.,Ctod(""))
Local cFilDoc      := ''
Local cDoc         := ''
Local cSerie       := ''
Local aVFContr     := {}
Local lDoctoApoio  := .F.
Local lRet         := .T.
Local lAuto        := .F.
Local lTMSA850     := Upper(AllTrim(FunName())) == "TMSA850"
Local aApoioCTR    := {} //| Documentos gerado a partir de Documentos de Apoio
Local nValApoio    := 0

PRIVATE nValCruz   := 0 //-- Uso FINA280
PRIVATE nVlrAtu    := 0 //-- Uso FINA280
PRIVATE nMaxCtrc   := 0
PRIVATE nMinCtrc   := 0

If Type("l850Auto") == "U"
	PRIVATE aRotina   := MenuDef()
	PRIVATE dEmisFat  := SuperGetMv("MV_DATAFAT",,dDataBase)
	PRIVATE l850Auto  := .F.
EndIf

If  Type("cCli") == "U" 
	Private cCli      := Space(6)
	Private _cLoja    := Space(2)
	Private cCliFat   := Space(6)
	Private cLojaFat  := Space(2)
	Private cPrefix   := Space(3)
	Private dVencto   := Ctod(Space(8))
	Private dDataDe   := dDataBase
	Private dDataAte  := dDataBase
	Private nTotAbat  := 0 //-- Uso FINA280
	Private nValorFat := 0 //-- Uso FINA280
	Private nValorF   := 0 //-- Uso FINA280
	Private nQtdCtrc  := 0
	Private nValtot   := 0
	Private aSetKey   := {}
	Private aAutoCab  := {}
	Private nMoeAut   := 0
	Private cTipAut   := ""
	Private cFilAut   := ""
	Private dVenAut   := Ctod(Space(8))
	Private cNatAut   := ""
	Private nDTCRECISS:= 0 // Essa variavel e usada no FINXFIN
	Private nDTCISS   := 0 // Essa variavel e usada no FINXFIN	
EndIf

DEFAULT aM          := {}
DEFAULT aDocExclui  := {}
DEFAULT lMostraTela := .T.
DEFAULT lAnulacao   := .F.
DEFAULT aVetPre     := {}
DEFAULT aMsgErr     := {}

//-- Limpa o filtro por conta do browse utilizando FWBrwRelation()
DT6->(DbClearFilter())
DT6->(DbCloseArea())

If Type("l850Auto") == "U"
	l850Auto  := .F.
EndIf

//--- Validação da Fatura
lRet:= TMSA850Vld(5, lAnulacao, lMostraTela, Aclone(aVetPre), nLinha, @aMsgErr) //5- Cancelamento
If !lRet
	Return .F.
Else
	cCli     := SE1->E1_CLIENTE
	_cLoja   := SE1->E1_LOJA
	cFilDeb  := SE1->E1_FILORIG
	Pergunte("TMA850",.F.)
Endif

//-- Verifica se a fatura foi gerada a partir de documentos de apoio:
cQuery := "SELECT COUNT(*) NUMDOCS "
cQuery += " FROM " + RetSQLTab('DT6') "
cQuery += " JOIN " + RetSqlName("DUI")+ " DUI "
cQuery += "  ON DUI.DUI_FILIAL = '"+FWxFilial("DUI")+"'"
cQuery += " AND DUI.DUI_DOCTMS = DT6_DOCTMS "
cQuery += " AND DUI_DOCFAT     <> ' ' "
cQuery += " AND DUI.D_E_L_E_T_ = ' ' "
cQuery += " WHERE DT6.DT6_FILIAL ='" + FWxFilial("DT6") + "' "
cQuery += "   AND DT6.DT6_CLIDEV ='" + PadR(aInfVis[E1CLIENTE], Len(aInfVis[E1CLIENTE])) + "' "
cQuery += "   AND DT6.DT6_LOJDEV ='" + PadR(aInfVis[E1LOJA]   , Len(aInfVis[E1LOJA]))    + "' "
cQuery += "   AND DT6.DT6_PREFIX ='" + PadR(aInfVis[E1PREFIXO], Len(aInfVis[E1PREFIXO])) + "' "
cQuery += "   AND DT6.DT6_NUM    ='" + PadR(aInfVis[E1NUM]    , Len(aInfVis[E1NUM]))     + "' "
cQuery += "   AND DT6.DT6_TIPO   ='" + PadR(aInfVis[E1TIPO]   , Len(aInfVis[E1TIPO]))    + "' "
cQuery += "   AND DT6_DOCTMS IN('B','C','H','I','N','O') "
cQuery += "   AND DT6.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
cAliasQry := GetNextAlias()
DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T.)
lDoctoApoio := !(cAliasQry)->(Eof()) .And. (cAliasQry)->NUMDOCS > 0
(cAliasQry)->(DbCloseArea())


//--Com o SE1 posicionado, verifica qual
//--documento foi gerado a partir do faturamento
//--dos documentos de apoio
aApoioCTR := TM850RecACT( @cFilDoc, @cDoc, @cSerie)

//--Verifica se pode cancelar a fatura que 
//--foi gerada a partir do documentos de apoio
//--Consiste a data de fechamento fiscal e a data
//--de fechamento das movimentacoes do TMS:
If lDoctoApoio

	//Tratamento nao para deixar excluir um documento caso exista um documento complementar
	For nCnt3 := 1 To Len(aApoioCTR)

		cFilDoc := aApoioCTR[nCnt3,1]
		cDoc    := aApoioCTR[nCnt3,2]
		cSerie  := aApoioCTR[nCnt3,3]

		aAreaDT6 := DT6->(GetArea())
		cChave   := xFilial('DT6')+cFilDoc+cDoc+cSerie
		DT6->(DbSetOrder(8)) //DT6_FILIAL+DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO
		DT6->(DbGoTop())
		If DT6->(MsSeek(cChave)) .And. !(DT6->DT6_DOCTMS == 'J' .And. DT6->DT6_TIPFRE == '3')
			RestArea(aAreaDT6)
			Help(' ', 1, 'TMSA20029',,cFilDoc + "/" + cDoc + "/" + cSerie + CHR(13) + CHR(10) ,2,13) //"Existe Manutencao de Doctos. feita para o CTRC : "###". 
			Return( .F. )
		EndIf
		RestArea(aAreaDT6)
	

		DT6->(DbSetOrder(1))
		If DT6->( dbSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie) )
			If !TMSDelNFS( cDoc, cSerie, .F. )
				Return( .F. )
			ElseIf !Empty(dDatFTMS) .And. DT6->DT6_DATEMI <= dDatFTMS
				Help(" ",1,"FECHATMS") //"Não pode ser digitado movimento com data anterior a última data de fechamento (MV_DATATMS)."
				Return( .F. )
			EndIf
		EndIf
	Next nCnt3
EndIf

cChaveLbn := "CANC"+aInfVis[E1PREFIXO]+aInfVis[E1NUM]+aInfVis[E1TIPO]

//-- Parametros da Funcao LockByName() :
//   1o - Nome da Trava
//   2o - usa informacoes da Empresa na chave
//   3o - usa informacoes da Filial na chave 
If !LockByName(cChaveLbn,.T.,.F.)
	//-- Se Ja estiver reservado retorna .F. pois nao pode executar a Rotina	
	Help(" ",1,"TMSA85003") //"Existe outro usuário cancelando esta fatura. Não é permitido o cancelamento da mesma fatura por dois usuários ao mesmo tempo"
	Return( .F. )
EndIf

//-- Finaliza Teclas de Atalhos
If lTMSA850
	TmsKeyOff(aSetKey)
EndIf

Pergunte("TMA850",.F.)

cQuery := ""
// Adiciona os campos que existirem no DT6 na matriz de campos a serem selecionados
aEval(aCampos,{|e| If(DT6->(FieldPos(e[1])) > 0, cQuery += ","+AllTrim(e[1]), Nil)})
cQuery := "SELECT "+SubStr(cQuery,2) + ", DT6_VALFAT, DT6.R_E_C_N_O_ RECNO, DUY.DUY_EST UFDEST "
cQuery += "     FROM " + RetSqlName("DT6") + " DT6 "
cQuery += "LEFT JOIN " + RetSqlName("DUY") + " DUY "
cQuery += "   ON DUY.DUY_FILIAL = '"+xFilial("DUY")+"'"
cQuery += "  AND DUY.DUY_GRPVEN = DT6.DT6_CDRDES"
cQuery += "  AND DUY.D_E_L_E_T_ = ' ' "
cQuery += "WHERE DT6_FILIAL     = '" + xFilial("DT6")  + "'"
If !lAnulacao
	cQuery += "  AND DT6.DT6_FILDEB = '" + aInfVis[E1FILDEB]  + "'"
EndIf
cQuery += "  AND DT6.DT6_PREFIX = '" + aInfVis[E1PREFIXO] + "'"
cQuery += "  AND DT6.DT6_NUM    = '" + aInfVis[E1NUM]     + "'"
//Foi removido a Cod/loja da query para os casos do F12 Considera Lojas SIM/NAO e para os casos do Cliente de Faturamento A1_CLIFAT
cQuery += "  AND DT6.DT6_TIPO   = '" + aInfVis[E1TIPO]    + "'"
cQuery += "  AND DT6.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY " + SqlOrder(DT6->(IndexKey(1))+"+RECNO")
AAdd(aStru, {"RECNO","N",10,0})

Processa({|| Tms850QryToMem(cQuery, aStru, aCampos, @aDoctos)}) // Cria arquivo temporario
lEof := (Len(aDoctos) == 0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Certifica se foram encontrados registros na condi‡„o selecionada       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEof
	Help(" ",1,"TMSA85027")	//-- "Não foram localizados documentos da fatura."
Else

	//-- Localiza cliente para exibir nome
	SA1->(MsSeek(FWxFilial("SA1")+aInfVis[E1CLIENTE]+aInfVis[E1LOJA]))

	nValor   := 0

	AEval( aDoctos, {|e| Iif(Posicione("DT6",1,FWxFilial("DT6") + e[FILDOC] + e[CTRC] + e[SERIE],"DT6_DOCTMS") $ ("B,C,H,I,N,O") .And.;
	 						!Empty(Posicione('DUI',1,FWxFilial('DUI',DT6->DT6_FILDOC)+DT6->DT6_DOCTMS,'DUI_DOCFAT')) ,nValApoio += e[VALFAT],)} )
	
	AEval( aDoctos, {|e| nValor += e[VALFAT] } )

	nValor -= nValApoio
	
	nQtdCTRC := Len(aDoctos)
	nTotFat  := nValor
	
	If Len(aDocExclui) > 0
		lAuto  := .T.
		For nCnt1 := 1 To Len(aDocExclui)
			nSeek := Ascan( aDoctos, { | e | e[FILDOC]+e[CTRC]+e[SERIE] == aDocExclui[nCnt1,1]+aDocExclui[nCnt1,2]+aDocExclui[nCnt1,3] })
			If nSeek > 0
				aDoctos[nSeek,MARCA] := .T.
				nTotExcluido += aDoctos[nSeek,VALFAT]
				nQtdCTRC -= 1
			EndIf
		Next nCnt1
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array com campos a serem mostrados na marcacao de ctrc   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd(aTitulos," ")
	aEval(aCampos, { |e|	If(e[1] = "_SI_VALFAT", AAdd(aTitulos,STR0107),; 	//"Valor faturado"
							If(e[1] = "_SI_UFDEST", AAdd(aTitulos,STR0101),; 	//"Uf Destino"
							AAdd(aTitulos,Posicione('SX3', 2, AllTrim(If(e[1]="DT6_VALTOT","DT6_VALFRE",e[1])), 'X3Titulo()')))) } )

	//-- Rotina automatica de exclusao de Faturas por Documentos
	If l850Auto
		//-- Marcacao para exclusao da Fatura dos CTE/CTRC informados na MsExecAuto
		nPos1 := aScan(aAutoCab[1], {|x| x[1]=="RECNO"})
		For nCnt1 := 1 To Len(aAutoCab)
			nRecDT6 := aAutoCab[nCnt1, nPos1, 2]
			//-- Localiza CTE pelo RECNO
			nPos2 := aScan(aDoctos, {|e| Atail(e)==nRecDT6})
			aDoctos[nPos2, MARCA] := .T.
		Next nCnt1
		AEval(aDoctos, {|e| If( e[MARCA], nTotExcluido+=e[VALFAT],Nil)})
		nQtdCTRC := 0
		nOpcA    := 1
	ElseIf lMostraTela
		//--Monta a tela
		nOpcA := Tmsa850Tela( .F., aInfVis[E1PREFIXO], aInfVis[E1NUM], aInfVis[E1NATUREZ], aInfVis[E1MOEDA],;
								nOpcX, aCampos, aTitulos,aDoctos,@nValor,@nTotExcluido,.T., .F.,,,,,;
								aInfVis[E1CLIENTE],aInfVis[E1LOJA], cFilDoc, cDoc, cSerie, @aVFContr,,aColSiz,,,,,IIf(nValApoio > 0, .T., .F.),nValApoio )
	Else
		//--Quando nao exibe a janela, ja
		//--realiza a marcacao dos doctos. e
		//--atualiza o valor das exclusoes:
		nOpcA := 1
		If !lAuto
			AEval(aDoctos, {|e| e[MARCA] := .T., nTotExcluido += e[VALFAT]})
			nQtdCTRC := 0
			nValor   := 0
		EndIf
	EndIf

	//--Nao permite excluir uma determinada fatura
	If lTM850Del
		lDelFat := ExecBlock( "TM850DEL", .F., .F.,{ aInfVis[E1PREFIXO], aInfVis[E1NUM], aInfVis[E1TIPO], aDoctos, nOpcA} )
		If ValType(lDelFat) == "L" .And. lDelFat
			nOpcA := 0
		Else
			nOpcA := 1
		EndIf
	EndIf
EndIf

If nOpcA == 1
	Processa( { || Iif(cTmsERP == '1' , T851ProcExc(aDoctos, nTotExcluido, nTotFat, aVFContr, lAnulacao,lDoctoApoio,@cFilDoc, @cDoc, @cSerie),;
	                                   T850ProcExc(aDoctos, nTotExcluido, nTotFat, aVFContr, lAnulacao,!Empty(aVetPre))) }, STR0117 ) //"Excluindo da fatura os doctos. marcados..."
EndIf

// Libera o lock do cancelamento
UnLockByName(cChaveLbn,.T.,.F.)

//-- Inicializa Teclas de Atalhos
If lTMSA850
	TmsKeyOn(aSetKey)
EndIf

// reposiciona na ordem anterior para evitar que mude a ordem no browse que chama esta rotina
SE1->(RestArea(aAreaSE1))
DT6->(RestArea(aAreaDt6))
RetIndex("DT6")

If lRet
	lRet := (nOpcA == 1)
EndIf

//-- Retorna a area por conta da limpeza de filtro
If IsInCallStack("TMSA170")
	RestArea(aAreaDT6)
EndIf

RestArea(aArea)

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³T850ProcEx³ Autor ³ Claudio D. De Souza   ³ Data ³ 26/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Processa a exclusao dos documentos de uma fatura           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array contendo Doctos                              ³±±
±±³          ³ ExpN1 = Total das Exclusoes                                ³±±
±±³          ³ ExpN2 = Total das Faturas (SEM USO)                        ³±±
±±³          ³ ExpA2 = Array contendo os Valores (Liquido/Impostos/Bruto) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function T850ProcExc(aDoctos, nTotExcluido, nTotFat, aVFContr, lAnulacao, lPreFat)
Local cPrefixo
Local cNum
Local cParcela
Local cTipo
Local nLen        := Len(aDoctos)
Local lSigaTMS    := .F.
Local lAtuDcApoio := .F.
Local lContinua   := .T.
Local lRet        := .T.
Local lTm850Grv   := ExistBlock("TM850GRV")
Local lTm850Oc    := ExistBlock("TM850OC")
Local lTm850EXC   := ExistBlock("TM850EXC")
Local lCancFt     := SuperGetMv("MV_CANCFT" ,,.F.)
Local lCancHst    := SuperGetMv("MV_CANCHST",,.F.)
Local aCond       := {} // Condicao de pagamento
Local aTit        := {}
Local aBaixa      := {}
Local cSeek       := ''
Local cFilDocDT6  := ''
Local cDocDT6     := ''
Local cSerieDT6   := ''
Local cCondicao   := ""
Local nX          := 0
Local nI          := 0
Local nK          := 0
Local nNotDocSel  := 0
Local nValProp    := 0
Local nValDiff    := 0
Local nApag       := 0
Local nRecnoSE1   := 0
Local aDoctosAnt  := AClone(aDoctos)
Local cAliasQry   := GetNextAlias()
Local lRetTran    := .T. 
Local nErrorDig   := 0
Local xDecimal    := GetSx3Cache("E1_SALDO","X3_DECIMAL")
Local nErroSql    := 0
Local aArea       := GetArea()
Local lAchouDEB

PRIVATE lMsErroAuto := .F.
PRIVATE aItemsFI2   := {}   // Utilizada na gravacao de instrucoes de cobranca
PRIVATE cMotBx      := "BCF" // Utilizada no cancelamento da fatura no sigafin

DEFAULT lAnulacao   := .F.
DEFAULT lPreFat     := .F.

//-- Verifica se a fatura foi gerada pelo modulo SIGATMS.
If Upper(AllTrim(SE1->E1_ORIGEM)) $ "TMSA491#TMSA850"
	lSigatms := .T.
EndIf

//-- Verifica se podera ser cancelado documentos da fatura
If !lCancFt
	If !Empty(SE1->E1_IDCNAB) .And. !Empty(SE1->E1_NUMBOR) .And. SE1->E1_SITUACA != "0"
		Help(" ",1,"TMSA85021") //"Não será permitido o cancelamento desta fatura, pois o título já foi enviado ao Banco."
		Return( .F. )
	EndIf
EndIf

//Quando ha mais de uma parcela no SE1, Ex: para uma condição de pagamento 30 / 60 dias o sistema cria mais de um SE1
cQuery := "SELECT SUM(E1_SALDO) SALDO "
cQuery += "FROM "+RetSqlName("SE1")+ " SE1 "
cQuery += "WHERE "
cQuery += " SE1.E1_FILIAL='"	+ FWxFilial("SE1") + "'"
cQuery += " AND SE1.E1_PREFIXO = '" + SE1->E1_PREFIXO +"'"
cQuery += " AND SE1.E1_NUM     = '" + SE1->E1_NUM +"'"
cQuery += " AND SE1.E1_TIPO    = '" + SE1->E1_TIPO +"'"
cQuery += " AND SE1.E1_CLIENTE = '" + SE1->E1_CLIENTE +"'"
cQuery += " AND SE1.E1_LOJA    = '" + SE1->E1_LOJA +"'"
cQuery += " AND SE1.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

nErrorDig    := nTotExcluido
nTotExcluido := (Int((nTotExcluido * (10 ^ xDecimal))) / (10 ^ xDecimal))

If nTotExcluido > (cAliasQry)->SALDO
	//-- Tolerancia de 0.01
	If (nTotExcluido - (cAliasQry)->SALDO) > 0.01
		Help(" ",1,"TMSA85023") //"O valor total a ser cancelado é maior, que o saldo total no financeiro."
		(cAliasQry)->(DbCloseArea())
		Return( .F. )
	EndIf
EndIf

(cAliasQry)->(DbCloseArea())
RestArea(aArea)

//-------------------------------------------------------------------------
//| Hack devido problemas de floating point
nErrorDig -= nTotExcluido
If nErrorDig <> 0
	nTotExcluido += nErrorDig
EndIf
//-------------------------------------------------------------------------

//-- Seleciona o DT6 gerado a partir do documento de apoio.
aApoioCTR := Tm850RecAct(@cFilDocDT6,@cDocDT6,@cSerieDT6)

ProcRegua(nLen)

Begin Transaction
	For nX := 1 To nLen
		IncProc()

		If aDoctos[nX][MARCA]
	
			DT6->(MsGoto(aDoctos[nX][LARECNO]))

			//--Verifica se o cancelamento esta sendo realizado em cima de um documento de apoio.
			//--Esta verificacao eh realizada para tratamento no cancelamento parcial. Quando houver
			//--um cancelamento parcial de uma fatura que foi gerada a partir de documentos de apoio,
			//--permite somente remover os documentos selecionados da fatura. Nao sera alterado o titulo
			//--a receber e o novo documento gerado a partir da geracao da fatura.
			If !lAtuDcApoio
				lAtuDcApoio := DT6->DT6_DOCTMS $ "|B|C|H|I|N|O|" .And. !Empty(Posicione('DUI',1,FWxFilial('DUI',DT6->DT6_FILDOC)+DT6->DT6_DOCTMS,'DUI_DOCFAT'))
			EndIf

			If Upper(Alltrim(SE1->E1_ORIGEM)) $ "TMSA491#TMSA850" .Or. lAnulacao
				//--Grava DVV somente se:
				//-- *A fatura gerada NAO foi a partir de documentos de apoio 
				//-- *Se for documento de apoio e estiver sendo realizado um cancelamento parcial da fatura
				If !lAtuDcApoio .Or. ( lAtuDcApoio .And. nQtdCtrc > 0 )
					RecLock("DVV", .T.)
					DVV->DVV_FILIAL := FWxFilial("DVV")
					DVV->DVV_FILDOC := DT6->DT6_FILDOC
					DVV->DVV_DOC    := DT6->DT6_DOC
					DVV->DVV_SERIE  := DT6->DT6_SERIE
					DVV->DVV_PREFIX := DT6->DT6_PREFIX
					DVV->DVV_NUM    := DT6->DT6_NUM
					DVV->DVV_TIPO   := DT6->DT6_TIPO
					DVV->DVV_DTEXCL := dDataBase
					DVV->DVV_USER   := cUserName
					DVV->DVV_VALTOT := DT6->DT6_VALTOT
					DVV->DVV_ACRESC := DT6->DT6_ACRESC
					DVV->DVV_DECRES := DT6->DT6_DECRES
					DVV->(MsUnlock())
				EndIf
			EndIf

			RecLock("DT6",.F.)
			DT6->DT6_PREFIX := ""
			DT6->DT6_NUM    := ""
			DT6->DT6_TIPO   := ""
			DT6->DT6_VENCTO := CToD("")
			DT6->DT6_ACRESC := 0
			DT6->DT6_DECRES := 0
			DT6->(MsUnlock())

			//-- Ao excluir a fatura, verifica (apenas 1 vez) se é necessário atualiza a pré-fatura que a gerou
			If !lPreFat .And. lAchouDEB == Nil
				If DEB->(ColumnPos("DEB_FILDOC")) > 0
					cQuery := " SELECT COUNT(1) NREG "
					cQuery += "  FROM " + RetSqlName("DT6") + " DT6AUX "
					cQuery += "  JOIN " + RetSqlName("DEB") + " DEBAUX "
					cQuery += "    ON DEBAUX.DEB_FILIAL = '" + FWxFilial("DEB") + "' "
					cQuery += "   AND DEBAUX.DEB_FILDOC = DT6AUX.DT6_FILDOC  "	
					cQuery += "   AND DEBAUX.DEB_DOC    = DT6AUX.DT6_DOC     "
					cQuery += "   AND DEBAUX.DEB_SERIE  = DT6AUX.DT6_SERIE   "
					cQuery += "   AND DEBAUX.D_E_L_E_T_ = ' '  "
					cQuery += " WHERE DT6AUX.R_E_C_N_O_ = " + Str(DT6->(Recno()))
					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
					lAchouDEB := (cAliasQry)->(!Eof()) .And. (cAliasQry)->NREG > 0
					(cAliasQry)->(DbCloseArea())
					RestArea(aArea)
				Else
					lAchouDEB := .F.
				EndIf
			EndIf

			If lPreFat .Or. lAchouDEB
				// Atualiza os campos da pré-fatura que ligam o ctrc a fatura 
				cQuery := " UPDATE " + RetSqlName("DEB") 
				cQuery += " SET DEB_PREFIX = ' ', "
				cQuery += "     DEB_NUMFAT = ' ', "
				cQuery += "     DEB_TIPO   = ' '  "
				cQuery += " WHERE R_E_C_N_O_ IN ( SELECT DEBAUX.R_E_C_N_O_ "
				cQuery += "                           FROM " + RetSqlName("DT6") + " DT6AUX "
				cQuery += "                           JOIN " + RetSqlName("DEB") + " DEBAUX "
				cQuery += "                             ON DEBAUX.DEB_FILIAL = '" + xFilial("DEB") + "' "
				cQuery += "                            AND DEBAUX.DEB_FILDOC = DT6AUX.DT6_FILDOC  "	
				cQuery += "                            AND DEBAUX.DEB_DOC    = DT6AUX.DT6_DOC     "
				cQuery += "                            AND DEBAUX.DEB_SERIE  = DT6AUX.DT6_SERIE   "
				cQuery += "                            AND DEBAUX.D_E_L_E_T_ = ' '  "
				cQuery += "                          WHERE DT6AUX.R_E_C_N_O_ = " + Str(DT6->(Recno()))
				cQuery += "                          ) "
				If (nErroSql := TCSqlExec(cQuery)) <> 0
					DisarmTransaction()
					lRetTran := .F.
					Help(" ",1,"TMSA85006",,RetTiTle("DEB_NUMPRE") + " : " + Alltrim(Str(nErroSql)),2,1) //"Erro ao atualizar docto.... Erro : "
					Break
				EndIf
			EndIf
			// No ponto de entrada o usuario podera complementar a gravacao de alguns campos do DT6 e DVV.
			// Os campos DT6_ACRESC e DT6_DECRES serao zerados no programa padrao e deverao, se for o caso,
			// serem atualizados pelo ponto de entrada.
			If lTm850Grv
				ExecBlock( "TM850GRV", .F., .F., aDoctos )
			EndIf
		EndIf
	Next nX

	For nX := 1 To nLen
		nApag := aScan(adoctos, {|nX| nX[1] ==.T.})
		If nApag > 0
			Adel(aDoctos,nApag)
			Asize(aDoctos, Len(aDoctos)-1)
		EndIf
	Next nX

	nQtdCtrc := Len(aDoctos)

	If lContinua
		//-- Checa a condicao de pagamento utilizada na geracao da fatura:
		nI := 1
		cCondicao := Posicione("SF2",2,xFilial("SF2")+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV+PadR(DT6->DT6_DOC,Len(DT6->DT6_DOC))+DT6->DT6_SERIE,"F2_COND")
		If Empty(cCondicao)
			cCondicao := Posicione("SA1",1,xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA),"A1_COND")
		EndIf
		If Empty(cCondicao)
			cCondicao := Fa280PedCd()
		EndIf
		// Incluida essa validacao para os casos em que o documento e gerado pela rotina fatura por documento (TMSA850), pois não respeita  
		// a condição de pagamento informada no cliente e sim a que foi informa na hora da geração da fatura.
		If Alltrim(SE1->E1_ORIGEM) = "TMSA850" 
			aCond := { { SE1->E1_VENCTO, nTotExcluido } }
		Else
			aCond := Condicao(nTotExcluido, cCondicao, 0, SE1->E1_EMISSAO)
		EndIf
		If Len(aCond) == 0
			Help(" ",1,"REGNOIS",,AllTrim(RetTitle("A1_COND"))+": "+cCondicao,3,0)
			DisarmTransaction()
			lRetTran := .F.
			Break
		EndIf

		aAreaSE1 := GetArea("SE1")
		DbSelectArea("SE1")
		DbSetOrder(2)
		SE1->(MsSeek(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM))

		cPrefixo := SE1->E1_PREFIXO
		cNum     := SE1->E1_NUM
		cParcela := SE1->E1_PARCELA
		cTipo    := SE1->E1_TIPO
		cCliente := SE1->E1_CLIENTE
		cLoja    := SE1->E1_LOJA

		While SE1->(!EOF()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == FWxFilial("SE1")+cCliente+cLoja+cPrefixo+cNum
			//--Registros agregados
			If SE1->E1_TIPO $ MVABATIM +"/"+MVIRABT+"/"+MVINABT   // AB-/IR-/IN-
				SE1->(DbSkip())
				Loop
			EndIf

			nRecnoSE1 := SE1->(Recno())

			//--Atualiza o titulo gerado a partir da Fatura,
			//--SOMENTE se o contrato nao estiver configurado
			//--para cobranca do valor fixo (Veiculo Dedicado) ou
			//--se a fatura NAO foi gerada a partir de Documentos
			//--de Apoio:
			If Len(aVFContr) == 0 .Or. (Len(aVFContr) > 0 .And. (aVFContr[1] == 0 .Or. !aVFContr[2])) .And. !lAtuDcApoio
				//--So gera instrucao, caso o titulo esteja 
				//--em banco e ja foi gerado o arquivo CNAB
				If !Empty(SE1->E1_IDCNAB)
					//--Se nao existir o ponto de entrada TM850OC
					//--ou se ele existir e retornar .T., grava a 
					//--instrucao para o banco
					If lTm850Oc .And. ExecBlock("TM850OC", .F., .F.)
						lRet := Fa040AltOk({"E1_DECRESC" }, { nTotExcluido })
					EndIf
				EndIf

				RecLock("SE1",.F.)
				//--Grava o valor das exclusoes em decrescimo,
				If Len(aCond) > 0
					If  SE1->E1_DECRESC + aCond[nI, 2] > SE1->E1_SALDO
						SE1->E1_DECRESC := SE1->E1_SALDO
						SE1->E1_SDDECRE := SE1->E1_SALDO
					Else
						SE1->E1_DECRESC += aCond[nI, 2]
						SE1->E1_SDDECRE += aCond[nI, 2]
						If dDataBase > SE1->E1_VENCTO 
							SE1->E1_PORCJUR := 0
							SE1->E1_VALJUR  := 0 
						EndIf
						// Se o descrescimo for igual ao saldo, e está sendo efetuado um cancelamento de fatura que já baixa parcial, zerar o saldo e atualizar o status da Fatura para "Baixado".
						If SE1->E1_DECRESC = SE1->E1_SALDO .And. nQtdCtrc > 0
							SE1->E1_SALDO  := 0
							SE1->E1_STATUS := "B"
						EndIf						
					EndIf
					If SE1->E1_ACRESC > 0 .And. !lCancHst
						SE1->E1_DECRESC += SE1->E1_ACRESC
						SE1->E1_SDDECRE += SE1->E1_ACRESC
					EndIf
				EndIf
				SE1->(MsUnLock())

				If AliasInDic('FI2') .And. !Empty(SE1->E1_IDCNAB)
					//--Se nao existir o ponto de entrada TM850OC 
					//--ou se ele existir e retornar .T., grava a 
					//--instrucao para o banco
					If lRet .And. lTm850Oc .And. ExecBlock("TM850OC", .F., .F.)
						F040GrvFI2() //-- Ocorrencias CNAB
					EndIf
				EndIf
			EndIf

			//--Se cancelou a fatura inteira, marca a fatura como cancelada
			If nQtdCtrc <= 0
				If Upper(AllTrim(SE1->E1_ORIGEM)) $ "TMSA491#TMSA850" .Or. lAnulacao

					//--Limpo referencias de apuracao de impostos.
					aRecSE1 := FImpExcTit("SE1",SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA)
					For nX := 1 to Len(aRecSE1)
						SE1->(MSGoto(aRecSE1[nX]))
						FaAvalSE1(4)
					Next nX
					//--Exclui os registros de relacionamentos do SFQ - Amarracao de Parcelas
					SE1->(MsGoTo(nRecnoSE1))
					FImpExcSFQ("SE1",SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA)

					//--Apaga registros agregados.
					Tm850ExcAgre(cPrefixo, cNum, cParcela, cTipo)

					If lAtuDcApoio
						//--Documento de Apoio: Exclui o titulo financeiro
						aTit := {}
						AAdd(aTit , {"E1_FILIAL"  , xFilial("SE1")  , Nil})
						AAdd(aTit , {"E1_PREFIXO" , SE1->E1_PREFIXO , Nil})
						AAdd(aTit , {"E1_NUM"     , SE1->E1_NUM     , Nil})
						AAdd(aTit , {"E1_PARCELA" , SE1->E1_PARCELA , Nil})
						AAdd(aTit , {"E1_TIPO"    , SE1->E1_TIPO    , Nil})
						AAdd(aTit , {"E1_CLIENTE" , SE1->E1_CLIENTE , Nil})
						AAdd(aTit , {"E1_LOJA"    , SE1->E1_LOJA    , Nil})
						AAdd(aTit , {"E1_NOMCLI"  , SA1->A1_NREDUZ  , Nil})
						MSExecAuto({|x, y| FINA040(x, y)}, aTit, 5)
					ElseIf !lCancHst
						//--Baixa o titulo pelo motivo de Cancelamento de Fatura
						aBaixa := {}
						AAdd(aBaixa , {"E1_PREFIXO"   , SE1->E1_PREFIXO , Nil})
						AAdd(aBaixa , {"E1_NUM"       , SE1->E1_NUM     , Nil})
						AAdd(aBaixa , {"E1_PARCELA"   , SE1->E1_PARCELA , Nil})
						AAdd(aBaixa , {"E1_TIPO"      , SE1->E1_TIPO    , Nil})
						AAdd(aBaixa , {"AUTMOTBX"     , "BCF"           , Nil})
						AAdd(aBaixa , {"AUTBANCO"     , ""              , Nil})
						AAdd(aBaixa , {"AUTAGENCIA"   , ""              , Nil})
						AAdd(aBaixa , {"AUTCONTA"     , ""              , Nil})
						AAdd(aBaixa , {"AUTDTBAIXA"   , dDataBase       , Nil})
						AAdd(aBaixa , {"AUTDTCREDITO" , dDataBase       , Nil})
						AAdd(aBaixa , {"AUTHIST"      , STR0118         , Nil}) //"Baixa por cancelamento de fatura"
						AAdd(aBaixa , {"AUTDESCONT"   , 0               , Nil})
						AAdd(aBaixa , {"AUTDECRESC"   , SE1->E1_DECRESC , Nil})
						AAdd(aBaixa , {"AUTACRESC"    , 0               , Nil})
						AAdd(aBaixa , {"AUTMULTA"     , 0               , Nil})
						AAdd(aBaixa , {"AUTJUROS"     , 0               , Nil})
						AAdd(aBaixa , {"AUTVALREC"    , 0               , Nil})
						MSExecAuto({|x, y| Fina070(x, y )}, aBaixa, 3)
					EndIf

					If lMsErroAuto
						DisarmTransaction()
						MostraErro()
					Else
						SE1->(MsGoTo(nRecnoSE1))
						RecLock("SE1",.F.)
						If lCancHst
							//--Documento de Apoio: Exclui o titulo financeiro
							aTit := {}
							AAdd(aTit , {"E1_FILIAL"  , xFilial("SE1")  , Nil})
							AAdd(aTit , {"E1_PREFIXO" , SE1->E1_PREFIXO , Nil})
							AAdd(aTit , {"E1_NUM"     , SE1->E1_NUM     , Nil})
							AAdd(aTit , {"E1_PARCELA" , SE1->E1_PARCELA , Nil})
							AAdd(aTit , {"E1_TIPO"    , SE1->E1_TIPO    , Nil})
							AAdd(aTit , {"E1_CLIENTE" , SE1->E1_CLIENTE , Nil})
							AAdd(aTit , {"E1_LOJA"    , SE1->E1_LOJA    , Nil})
							AAdd(aTit , {"E1_NOMCLI"  , SA1->A1_NREDUZ  , Nil})
							MSExecAuto({|x, y| FINA040(x, y)}, aTit, 5)
						Else
							SE1->E1_SITFAT := "3"
							SE1->E1_PIS    := 0
							SE1->E1_COFINS := 0
							SE1->E1_CSLL   := 0
							//--Campos que controlam os saldos a abater dos impostos (PIS, COFINS e CSLL)
							SE1->E1_SABTPIS := 0
							SE1->E1_SABTCOF := 0
							SE1->E1_SABTCSL := 0
						EndIf
						SE1->(MsUnLock())

						//--Executa o cancelamento das faturas 
						//--atraves do modulo SIGATMS
						If lSigaTms .And. lAtuDcApoio
							DbSelectArea("DVV")
							DbSetOrder(2)
							cSeek := xFilial("DVV") + SE1->(E1_PREFIXO + E1_NUM + E1_TIPO)
							If DVV->( MsSeek( cSeek ) )
								Do While DVV->( cSeek == DVV_FILIAL + DVV_PREFIX + DVV_NUM + DVV_TIPO )
									Reclock("DVV",.F.)
									DVV->( DbDelete() )
									DVV->( MsUnlock() )
									DVV->( DbSkip() )
								EndDo
							EndIf

							//-- Deleta os Doc.
							For nK := 1 To Len(aApoioCTR)
								TMSA491CDoc(aApoioCTR[nk,1], aApoioCTR[nk,2],aApoioCTR[nk,3])
							Next nK
						EndIf
					EndIf
				ElseIf Upper(AllTrim(SE1->E1_ORIGEM)) == "TMSA880"
					Tm850ExcAgre(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
					//--Exclui o titulo gerado pela Baixa de Doctos.
					RecLock('SE1',.F.)
					SE1->(DbDelete())
					SE1->(MsUnLock())
				Endif
			Else
				//--Cancelamento parcial.

				//--Quando for realizado o cancelamento parcial da fatura
				//--e o contrato do cliente estiver configurado para cobranca
				//--do valor fixo (Veiculo Dedicado) apenas retira o documento 
				//--da fatura e faz novamente a proporcao do valor fixo entre os 
				//--demais documentos da fatura.
				If Len(aVFContr) > 0 .And. aVFContr[1] > 0 .And. aVFContr[2]
					//--Obtem a Qtde. de Documentos que nao marcados para exclusao
					AEval( aDoctos, {|e| If( !e[MARCA], nNotDocSel++, Nil )} )

					//--Proporcionaliza o valor fixo do contrato
					//--entre os documentos que estao selecionados:
					nValProp := Round( aVFContr[5] / nNotDocSel, TamSX3("DT6_VALFRE")[2] )

					//--Atualiza o vetor 'aDoctos' com o novo valor proporcional:
					AEval( aDoctos, {|e| e[ACRESC] := nValProp} )

					//--Verifica se existe diferenca de arredondamento:
					nValDiff := aVFContr[5] - Round( nValProp * nNotDocSel, TamSX3("DT6_VALFRE")[2] )
					If nValDiff <> 0
						//--Identifica o primeiro documento que NAO esta selecionado na fatura:
						nX := AScan( aDoctos, {|x| x[1] == .F.} )
						If nX > 0
							//--Ajusta os Valores
							If nValDiff > 0
								aDoctos[nX][ACRESC] += nValDiff
							Else
								aDoctos[nX][ACRESC] -= (nValDiff * -1)
							EndIf
						EndIf
					EndIf

					//--Atualiza os dados dos documentos restantes:
					For nX := 1 To Len(aDoctos)
						If !aDoctos[nX][MARCA]
							DT6->( DbGoto(aDoctos[nX][LARECNO]) )
							RecLock('DT6', .F.)
							DT6->DT6_ACRESC := aDoctos[nX][ACRESC]
							DT6->(MsUnLock())
						EndIf
					Next nX
				Endif
			EndIf
			SE1->(DbSkip())
			If (nI+1) < Len(aCond)
				nI++
			EndIf
		EndDo
		RestArea(aAreaSE1)
	EndIf
End Transaction

If !lRetTran
	Return( .F. )
EndIf

//-- Apos exclusao documentos da fatura
If lTm850EXC
	ExecBlock("TM850EXC", .F., .F., {cCliente,cLoja,cPrefixo,cNum,aDoctosAnt})
EndIf

Return( !lMsErroAuto )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa850Leg  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 22.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria uma janela contendo a legenda da mBrowse ou retorna a ³±±
±±³          ³ para o BROWSE                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA850 / TMSA491                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa850Leg(nReg)

Local aLegenda := {	{"BR_VERDE"   , STR0086 },; //"Fatura em aberto"
					{"BR_AZUL"    , STR0119 },; //"Fatura Impressa"
					{"BR_AMARELO" , STR0120 },; //"Fatura Protestada"
					{"BR_VERMELHO", STR0088 },; //"Fatura Baixada"
					{"BR_PRETO"   , STR0089 } } //"Fatura Cancelada"
Local uRetorno := .T.

If  Type("cCli") == "U" 
	Private cCli      := Space(6)
	Private _cLoja    := Space(2)
	Private cCliFat   := Space(6)
	Private cLojaFat  := Space(2)
	Private cPrefix   := Space(3)
	Private dVencto   := Ctod(Space(8))
	Private dDataDe   := dDataBase
	Private dDataAte  := dDataBase
	Private nTotAbat  := 0 //-- Uso FINA280
	Private nValorFat := 0 //-- Uso FINA280
	Private nValorF   := 0 //-- Uso FINA280
	Private nVLCruz   := 0 //-- Uso FINA280
	Private nVlrAtu   := 0 //-- Uso FINA280
	Private nQtdCtrc  := 0
	Private nValtot   := 0
	Private aSetKey   := {}
	Private aAutoCab  := {}
	Private nMoeAut   := 0
	Private cTipAut   := ""
	Private cFilAut   := ""
	Private dVenAut   := Ctod(Space(8))
	Private cNatAut   := ""
	Private nDTCRECISS:= 0 // Essa variavel e usada no FINXFIN
	Private nDTCISS   := 0 // Essa variavel e usada no FINXFIN	
EndIf

If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	AAdd(uRetorno, { 'E1_SITFAT="3"', aLegenda[5][1] } )
	AAdd(uRetorno, { 'ROUND(E1_SALDO,2) == ROUND(E1_VALOR,2) .and. E1_SITUACA $ "F6"', aLegenda[3][1] } )
	AAdd(uRetorno, { 'ROUND(E1_SALDO,2) = 0', aLegenda[4][1] } )
	AAdd(uRetorno, { 'E1_SITFAT="2"', aLegenda[2][1] } )
	AAdd(uRetorno, { '.T.', aLegenda[1][1] } )
Else
	BrwLegenda(cCadastro, STR0072, aLegenda) //"Legenda"
Endif

Return( uRetorno )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tms850QryToM³ Autor ³ Claudio D. de Souza   ³ Data ³21.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Envia o conteudo de uma Query para um array                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tms850QryToMem(cQuery,aStru,aCampos,aDados,oTempTable,cCliDev,cLojDev,cNumPre,aMsgErr)

Local nI        := 0
Local cAlias    := GetNextAlias()
Local nAscan    := 0
Local nPosCpo   := 0
Local aArea     := GetArea()
Local aAreaDEB  := DEB->(GetArea())
Local aAreaSA1  := SA1->(GetArea())
Local lRet      := .T.
Local nAcresc   := 0
Local nDecresc  := 0
Local nValorDEB := 0
Local lAchouDEB := .F.

Local lBkErAut, lBkAutNFil, lBkHelpAut, aErro, cErro //-- Tratamento de erros - Pré-Fatura

Local nValFatura := 0
Local nValorDT6	 := 0

Default oTempTable := {}
Default cCliDev    := ""
Default cLojDev    := ""
Default cNumPre    := ""
Default aMsgErr    := {}

SA1->(DbSetOrder(1))
SA1->(MsSeek(FWxFilial("SA1") + cCliDev + cLojDev))

aDados := {}
cQuery := ChangeQuery(cQuery)
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)},STR0121) //"Aguarde! Obtendo os dados..."

For nI := 1 to Len(aCampos)
	nAscan := aScan(aStru, {|e| Alltrim(e[1]) == Alltrim(aCampos[nI][NOMEDOCAMPO])})
	If nAscan > 0 .And. aStru[nAscan,2] != 'C'
		TCSetField(cAlias, aStru[nAscan,1], aStru[nAscan,2],aStru[nAscan,3],aStru[nAscan,4])
	EndIf
Next nI

If !Empty(oTempTable) 
	//-- Salva variáveis private do sistema
	If Type("lMsErroAuto")  <> "U"
		lBkErAut := lMsErroAuto
	EndIf
	If Type("lMsHelpAuto") <> "U"
		lBkHelpAut := lMsHelpAuto
	EndIf
	If Type("lAutoErrNoFile") <> "U"
		lBkAutNFil := lAutoErrNoFile
	EndIf
EndIf

Do While !(cAlias)->(Eof())
	//-- Validar registros retornados pela consulta SQL
	If	lTM850FAT
		lRet := ExecBlock( "TM850FAT",.F.,.F.,{(cAlias)->DT6_FILDOC,(cAlias)->DT6_DOC,(cAlias)->DT6_SERIE})
		If	Valtype(lRet) <> "L"
			lRet :=  .T.
		EndIf
	EndIf
	If	lRet
		//-- Acréscimo e decréscimo (apenas quando vem da Pré-fatura )
		nAcresc   := 0
		nDecresc  := 0
		If !Empty(oTempTable)
			//-- Chama função que define se utiliza o valor da DT6 ou da DEB
			nValorDT6 := (cAlias)->(If(DT6_VALFAT>0,DT6_VALFAT,DT6_VALTOT)+DT6_ACRESC-DT6_DECRES)
			nValorDEB := 0
			DEB->(DbSetOrder(4)) 
			If (lAchouDEB := DEB->( MsSeek( xFilial("DEB") + SA1->A1_CGC + cNumPre + (cAlias)->(DT6_FILDOC+DT6_DOC+DT6_SERIE) )) )
				nValorDEB := DEB->DEB_VALOR
			EndIf

			If FindFunction("TmsPreVFat")
				nValFatura := TmsPreVFat(cCliDev,cLojDev,nValorDEB,nValorDT6)

				//-- Caso o valor da Fatura seja diferente, trata do acréscimo e decréscimo
				If nValFatura > nValorDT6
					nAcresc  := nValFatura - nValorDT6
				ElseIf nValFatura < nValorDT6
					nDecresc := nValorDT6 - nValFatura
				EndIf
			Else
				nValFatura := nValorDT6
			EndIf

		Else
			nValFatura := (cAlias)->(If(DT6_VALFAT>0,DT6_VALFAT,DT6_VALTOT)+DT6_ACRESC-DT6_DECRES)
		EndIf

		AAdd(aDados,{Iif(Empty(oTempTable),.F.,.T.)})
		nLen := Len(aDados)
		aEval(aCampos, {|e| nPosCpo := (cAlias)->(FieldPos(e[1])),;
							AAdd(aDados[nLen], If(nPosCpo > 0,;
												  (cAlias)->(FieldGet(nPosCpo)), ;
												  If(e[1]="_SI_UFDEST",;
													 (cAlias)->UFDEST,;
													 nValFatura;
													);
												 )) } )
		AAdd(aDados[nLen], (cAlias)->RECNO)

		//-- Faz "ajuste" no valor quando tem pré-fatura
		If !Empty(nAcresc) .Or. !Empty(nDecresc)
			aDados[nLen][ACRESC ] := nAcresc
			aDados[nLen][DECRESC] := nDecresc
			aDados[nLen][VALFAT]  := aDados[nLen][VALFRETE]+aDados[nLen][ACRESC]-aDados[nLen][DECRESC]
		EndIf

		//-- Ao montar o array quando pré-fatura, já valida e, em caso de rejeição, grava help no campo da DEB .
		If !Empty(oTempTable) 
			lMsErroAuto    := .F.	//-- Variável private para MsExecAuto (emulação)
			lMsHelpAuto    := .T.	//-- Inibe HELP dos Campos
			lAutoErrNoFile := .T.	//-- Não grava arquivo, para que se recupere as mensagens em array

			//-- Valida o Docto
			If !TMA850Val(.F./*lExclui*/,/*nValFat*/,/*lCONTDOC*/,/*nQtdCTRC*/,aDados[nLen,FILDOC],aDados[nLen,CTRC],;
									aDados[nLen,SERIE],aDados[nLen,VALFRETE],aDados[nLen,ACRESC],;
									aDados[nLen,DECRESC],/*aMsgErr*/,.F./*lExbHlp*/)

				//-- Grava o Help na Observação da DEB
				aErro := GetAutoGRLog()   // Le os dados do erro e guarda no vetor
				cErro := "" 
				aEval(aErro, { |x| cErro += AllTrim(StrTran(StrTran(x,Chr(10)," "),Chr(13)," ")) + Chr(13) + Chr(10) } )
				If lAchouDEB
					RecLock("DEB",.F.)
					DEB->DEB_STATUS := "["+DtoC(Date()) + "-" + Time() + "] " + cErro + Repl("-",40) + Chr(13)+ Chr(10) + AllTrim(DEB->DEB_STATUS) 
					MsUnLock()
				EndIf
				aAdd(aMsgErr, {aDados[nLen,FILDOC] + "-" + aDados[nLen,CTRC] + "-" + aDados[nLen,SERIE]+":"+StrTran(cErro,Chr(13)+Chr(10),""), "00",""})
				aSize(aErro,0)        //-- Libera a memória do array 
				aSize(aDados,nLen-1)  //-- Retira o documento que não passar na validação do array aDoctos.
			Else
				nValFat  += nValFatura
				nQtdCTRC ++
			EndIf
		EndIf
	EndIf
	(cAlias)->(DbSkip())
EndDo
(cAlias)->(dbCloseArea())

If !Empty(oTempTable) 
	//-- Restaura variáveis private do sistema
	If ValType(lBkErAut)  <> "U"
		lMsErroAuto := lBkErAut
	EndIf
	If ValType(lBkHelpAut) <> "U"
		lMsHelpAuto := lBkHelpAut
	EndIf
	If ValType(lBkAutNFil) <> "U"
		lAutoErrNoFile := lBkAutNFil
	EndIf
EndIf

RestArea( aAreaDEB )
RestArea( aAreaSA1 )
RestArea( aArea )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa850bLin³ Autor ³ Claudio D. de Souza  ³ Data ³ 13/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao da bLine do Docto.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa850bLine(nAt,aDoctos,aCampos)

Local nX        := 0
Local abLine    := {}
Local nLen      := Len(aCampos)
Local oNoMarked := LoadBitmap( GetResources(),'LBNO' )
Local oMarked   := LoadBitmap( GetResources(),'LBOK' )

If Len(aDoctos) > 0
	AAdd( abLine, Iif(aDoctos[nAt,MARCA], oMarked, oNoMarked ) )
	For nX := 1 To nLen
		AAdd( abLine, Transform(aDoctos[nAt,nX+1],aCampos[nX][MASCARA]))
	Next
Endif

Return( abLine )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA850Inv    ³ Autor ³ V.Raspa               ³ Data ³ 09.Out.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca / Desmarca documentos                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA850Inv(	nAcao, aDoctos, oLbxDocto, oMark, cFilOriDe,;
							cFilOriAte, cUFDestDe, cUFDestAte, nValFat,;
							nQtdCTRC, aVFContr, lExclui, nTotCanc, lDocApoio )
Local nStart    := 0
Local nCount    := 0
Local nValProp  := 0
Local nValDiff  := 0
Local nX        := 0
Local lContinua := .T.
Local lMostrouHelp := .F.
Local lFat 		:= .T.
Local lCONTDOC	:= SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran") //--Parametro para controle de Transações da Viagem mod2,
					//-- o documento ficara locado até confirmar ou fechar a viagem impossibilitando o uso do documento por outras Estações.

Local nCntFor1 := 0
Local aMsgErr  := {}

Default lDocApoio := .F.

//--Valores para "nAcao":
//-- 1: Apenas marca/desmarca o documento selecionado.
//-- 2: Marca todos documentos / Desmarca todos documentos (Conforme opcao selecionada em "oMark")
//-- 3: Marca os documentos conforme parametrizacao - Filial de Origem / UF Destino
If nAcao == 1
	If !aDoctos[oLbxDocto:nAT,MARCA]
		lContinua := TMA850Val(lExclui,@nValFat,lCONTDOC,@nQtdCTRC,aDoctos[oLbxDocto:nAT,FILDOC],aDoctos[oLbxDocto:nAT,CTRC],;
				     		   aDoctos[oLbxDocto:nAT,SERIE],aDoctos[oLbxDocto:nAT,VALFRETE],aDoctos[oLbxDocto:nAT,ACRESC],;
				     		   aDoctos[oLbxDocto:nAT,DECRESC],@aMsgErr,.T.)
		//--Deve marcar somente o documento selecionado:
		If lContinua
			aDoctos[oLbxDocto:nAT][MARCA] := !aDoctos[oLbxDocto:nAT][MARCA]
			nStart := oLbxDocto:nAT
			nCount := 1
		EndIf
	Else
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		If lCONTDOC
			TmsConTran(aDoctos[oLbxDocto:nAT,FILDOC],aDoctos[oLbxDocto:nAT,CTRC],aDoctos[oLbxDocto:nAT,SERIE],.F.)
		EndIf
		aDoctos[oLbxDocto:nAT][MARCA] := !aDoctos[oLbxDocto:nAT][MARCA]
		nStart := oLbxDocto:nAT
		nCount := 1
	EndIf
ElseIf nAcao == 2 .Or. nAcao == 3
	//--Atualiza as variaveis de controle
	nStart := 1
	nCount := Len(aDoctos)

	If !lExclui
		nValFat  := 0
		nQtdCTRC := 0
	Else
		nTotCanc := 0
		nQtdCTRC := Len(aDoctos)
	EndIf
	
	If nAcao == 2
		//-- Marca/Desmarca -TODOS- documentos, conforme opcao selecionada no Radio (oMark):
		//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
		For nCntFor1 := 1 To Len(aDoctos)
			If !aDoctos[nCntFor1,MARCA] .And. oMark:nOption == 1
				lContinua := TMA850Val(lExclui,@nValFat,lCONTDOC,@nQtdCTRC,aDoctos[nCntFor1,FILDOC],aDoctos[nCntFor1,CTRC],;
						     		   aDoctos[nCntFor1,SERIE],aDoctos[nCntFor1,VALFRETE],aDoctos[nCntFor1,ACRESC],;
						     		   aDoctos[nCntFor1,DECRESC],@aMsgErr,.F.)
				If lContinua
					aDoctos[nCntFor1,MARCA] := (oMark:nOption == 1)
				Else
					Exit
				EndIf
			Else
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				If lCONTDOC
					TmsConTran(aDoctos[nCntFor1,FILDOC],aDoctos[nCntFor1,CTRC],aDoctos[nCntFor1,SERIE],.F.)
				EndIf
				aDoctos[nCntFor1,MARCA] := (oMark:nOption == 1)
			EndIf
		Next nCntFor1
	Else
		//--Marca os documentos conforme parametrizacao realizada:
		For nCntFor1 := 1 To Len(aDoctos)
			If (aDoctos[nCntFor1,FILDOC]    >= cFilOriDe .And. aDoctos[nCntFor1,FILDOC]    <= cFilOriAte) .And. ;
			   (aDoctos[nCntFor1,UFDESTINO] >= cUFDestDe .And. aDoctos[nCntFor1,UFDESTINO] <= cUFDestAte)
				If !aDoctos[nCntFor1,MARCA]  .And. oMark:nOption == 1
					lContinua := TMA850Val(lExclui,@nValFat,lCONTDOC,@nQtdCTRC,aDoctos[nCntFor1,FILDOC],aDoctos[nCntFor1,CTRC],;
							     		   aDoctos[nCntFor1,SERIE],aDoctos[nCntFor1,VALFRETE],aDoctos[nCntFor1,ACRESC],;
							     		   aDoctos[nCntFor1,DECRESC],@aMsgErr,.F.)
					If lContinua
						aDoctos[nCntFor1,MARCA] := .T.
					Else
						Exit
					EndIf
				Else
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					If lCONTDOC
						TmsConTran(aDoctos[nCntFor1,FILDOC],aDoctos[nCntFor1,CTRC],aDoctos[nCntFor1,SERIE],.F.)
					EndIf
					aDoctos[nCntFor1,MARCA] := .F.
				EndIf
			EndIf
		Next nCntFor1
	EndIf
EndIf

If lContinua
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZACAO DOS VALORES³
	//³ACUMULADOS DA FATURA   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//
	If !lExclui	
		//--Atualiza a Qtde. de 
		//--documentos selecionados:
		AEval(	aDoctos,;
				{|e| If(e[MARCA], nQtdCTRC++, If(nAcao==1, nQtdCTRC--, NIL))},; 
				nStart, nCount )
					
		//-- Trava o registro que está sendo usado por outra estação 			
		If lCONTDOC .And. !Empty(aDoctos)
					
			For nX := 1 to Len(aDoctos)						
				DT6->(DbSetOrder(1))
				If DT6->( DbSeek(xFilial('DT6')+aDoctos[nX][FILDOC] + aDoctos[nX][CTRC] + aDoctos[nX][SERIE]) )
					If DT6->DT6_STATUS $ "B/C" 
						//-- Limpa marcas dos agendamentos
						//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
						If !IsInCallStack("TMSAF76")
							TMSALimAge(StrZero(ThreadId(),20))
						EndIf
						Help("  ",1,"TMSA14438",,+" "+ STR0110 + DT6->DT6_FILDOC +"-"+ DT6->DT6_DOC +"-"+ DT6->DT6_SERIE,5,18)
						lMostrouHelp   := .T.			
						aDoctos[nX][MARCA] := .F.					
						lFat := .F.	
					EndIf																	
				EndIf
			Next	
		EndIf 		
		If Len(aVFContr) == 0 .Or. (Len(aVFContr) > 0 .And. aVFContr[1] == 0)
			//--Se o contrato nao possui tratamento
			//--referente a cobranca do valor fixo:

			//--Atualiza os valores do vetor 'aDoctos':
			If lFat
				AEval(	aDoctos,;
						{|e| If(e[MARCA], e[VALFAT] := e[VALFAT], NIL)},; 
						nStart, nCount )
	
				AEval(	aDoctos,;
						{|e| If(e[MARCA], nValFat+=e[VALFAT], If(nAcao==1, nValFat-=e[VALFAT], NIL))},; 
						nStart, nCount )					
			EndIf			
		Else
			//--Tratamento referente a cobranca do valor fixo do contrato:

			//--Proporcionaliza o valor fixo do contrato
			//--entre os documentos que estao selecionados:	
			If lFat
				nValProp := Round( aVFContr[5] / nQtdCTRC, TamSX3("DT6_VALFRE")[2] ) 
	
				//--Atualiza os valores do vetor 'aDoctos':
	
				//--1o. Atualiza a coluna "ACRESCIMO" com o valor fixo do contrato:
				AEval(	aDoctos,;
						{|e|, If(e[MARCA], e[ACRESC] := nValProp, e[ACRESC] := 0)} )
	
				//--Verifica se existe diferenca de arredondamento:
				nValDiff := aVFContr[5] - Round( nValProp * nQtdCTRC, TamSX3("DT6_VALFRE")[2] )
				If nValDiff <> 0
					//--Identifica o primeiro documento
					//--que esta selecionado na fatura:
					nX := AScan( aDoctos, {|x| x[1] == .T.} )
					If nX > 0
						//--Ajusta os Valores
						If nValDiff > 0
							aDoctos[nX][ACRESC] += nValDiff
							aDoctos[nX][VALFAT] += nValDiff
						Else
						aDoctos[nX][ACRESC] -= (nValDiff * -1)
							aDoctos[nX][VALFAT] -= (nValDiff * -1)
						EndIf
					EndIf
				EndIf	
				//--2o. Atualiza a coluna "DECRESCIMO" quando
				//--o contrato esta configurado para cobranca
				//--somente do valor fixo:
				If aVFContr[2]
					AEval(	aDoctos,;
							{|e| If(e[MARCA], e[DECRESC] := e[VALFRETE], e[DECRESC] := 0)},;
							nStart, nCount )
				EndIf
					//--3o. Atualiza a coluna "VALOR DA FATURA":
				AEval(	aDoctos,;
						{|e| If(e[MARCA], e[VALFAT] := ((e[VALFRETE]+e[ACRESC])-e[DECRESC]), e[VALFAT] := 0)} )
	
				//--Atualiza o valor da Fatura:
				nValFat := 0
				AEval(	aDoctos,;
						{|e| If(e[MARCA], nValFat += e[VALFAT], NIL)} )			
			EndIf			
		EndIf
	Else
		//--Tratamento especifico para cancelamento das faturas:

		//--Atualiza a Qtde. de documentos selecionados:
		nQtdCTRC := 0
		AEval( aDoctos, {|e| Iif(e[MARCA],nQtdCTRC += 1,)})
	
		//--Atualiza o Total referente a exclusao dos documentos:
		AEval(	aDoctos,;
				{|e| Iif(!(Posicione("DT6",1,FWxFilial("DT6") + e[FILDOC] + e[CTRC] + e[SERIE],"DT6_DOCTMS") $ ("B,C,H,I,N,O")) .Or. ;
						Empty(Posicione('DUI',1,FWxFilial('DUI',DT6->DT6_FILDOC)+DT6->DT6_DOCTMS,'DUI_DOCFAT')),;
						Iif(e[MARCA],nTotCanc+=e[VALFAT],Iif(nAcao == 1,nTotCanc -= e[VALFAT],NIL)),)},; 
				nStart, nCount )
	EndIf
EndIf

//--Forca um Refresh na lista:
oLbxDocto:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa850Grava ³ Autor ³ Claudio D. de Souza  ³ Data ³ 27/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a Fatura                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa850Grava(	cPrefix, cTipo, aDoctos, nMoedFat, dEmisFat,;
								cNumFat, cAliasTRB, cSerie, cOrigem, cNat,;
								nRecDT6, lFTPorDoc, aVenc, lPreFat )

Local nLen        := Len(aDoctos)
Local nValTotal   := 0
Local nX          := 0
Local lErro       := .F.
Local nY          := 0
Local cQuery      := ''
Local cMay        := ''
Local cRecno      := ''
Local nErro       := 0
Local nDoctos     := 0
Local nTent       := 0
Local lTM491CPO   := ExistBlock('TM491CPO')
Local lTM850CPO   := ExistBlock('TM850CPO')
Local lTM850ITE   := ExistBlock('TM850ITE')
Local nCnt        := 0
Local lMV_TMSFMSG := SuperGetMv("MV_TMSFMSG",.F.,.T.)
Local cCliSe1     := ''
Local cLojSe1     := ''
Local cAliasQry   := GetNextAlias()
Local lAchou      := .F.
Local lMV_TMSNFAT := SuperGetMv("MV_TMSNFAT",.F.,.T.)
Local cTMSMFat    := SuperGetMv("MV_TMSMFAT",.F.," ")
Local cDocPrefix  := ''
Local cDocTipo    := ''
Local cDocNum     := ''
Local dDocVenc    := Ctod('')
Local cSeek       := ''
Local cNumNota    := ''
Local aFtGeradas  := {}
Local nPerJur     := SuperGetMv("MV_TXPER",,0)
Local nValJur     := 0
Local nComis1     := 0
Local nXCont      := 0
Local aColsSave   := {}
Local dVencRea    := ''
Local lAlqInt     := .F. //| Aliquota Interna
Local cCDRCAL     := ""
Local nValBaseIr  := 0
Local lBaseImpIr  := .F.
Local aBases      := NIL
Local cDocTms     := ""


Local aAreaSA1    := SA1->(GetArea())

Local nImpISS     := 0
Local lTPABISS    := IIf(GetNewPar("MV_TPABISS", "1") == "1",.T.,.F.)
Local lDescIss    := IIf(GetNewPar("MV_DESCISS", .T.) == .T.,.T.,.F.)  

Default nMoedFat  := 1
Default dEmisFat  := dDataBase
Default cNumFat   := ''
Default cAliasTRB := ''
Default cSerie    := ''
Default cOrigem   := "TMSA850"
Default cNat      := ''
Default aVenc     := {}
Default lPreFat   := .T.

If TYPE("aDocAct") <> "A"
	Private aDocAct := {}
EndIf

If !Empty(aVenc)
	dVencRea := DToS(aVenc[1][1]) 	
EndIf

PRIVATE lAltera     := .F.
PRIVATE lF040Auto   := .F.
PRIVATE cBancoAdt   := CriaVar("A6_COD")
PRIVATE cAgenciaAdt := CriaVar("A6_AGENCIA")
PRIVATE cNumCon     := CriaVar("A6_NUMCON")
PRIVATE nVlRetPis   := 0
PRIVATE nVlRetCof   := 0
PRIVATE nVlRetCsl   := 0
PRIVATE nVlRetIRF   := 0
PRIVATE nVlOriCof   := 0
PRIVATE nVlOriCsl	:= 0
PRIVATE nVlOriPis   := 0
PRIVATE aDadosRet   := Array(6)
PRIVATE nIndexSE1   := 0
PRIVATE cIndexSE1   := ""
PRIVATE cLote       := ""
PRIVATE cTitPai     := ""
PRIVATE INCLUI      := .T.
PRIVATE ALTERA      := .F.
If  Type("aAutoCab") =="U"
	Private aAutoCab      := {}
EndIf
AFill( aDadosRet, 0 )

Pergunte("FIN040",.F.)

If Empty(cNumFat) .Or. (nTipoDoc == 2 .And. lMV_TMSNFAT)
	//-- Tratamento para nao duplicar numero das faturas
	While !LockByName("A280NUMFAT",.T.,!Empty(FWxFilial("SE1"))) .And. nTent <= 50
		nTent++
		Sleep(5000)
	EndDo
	If nTent >= 50
		UserException(STR0064) //"NAO CONSEGUI LOCKBYNAME A280NUMFAT"
	EndIf
	//-- Obtem o numero da fatura e ja confirma este numero
	cFatura := Soma1(GetMv('MV_NUMFAT'),Len(SE1->E1_NUM))
	cMay    := "SE1"+FWxFilial("SE1")+cFatura
	SE1->(DbSetOrder(1))
	While SE1->(MsSeek(FWxFilial("SE1")+PadR(cPrefix,3)+cFatura)) .Or. !MayIUseCode(cMay)	//-- Verifica se esta na memoria, sendo usado
		//-- Busca o proximo numero disponivel
		cFatura := Soma1(cFatura,Len(SE1->E1_NUM))
		cMay    := "SE1"+xFilial("SE1")+cFatura
	EndDo
	//-- Grava no SX6 o numero da ultima fatura
	PutMV('MV_NUMFAT',cFatura)
	FreeUsedCode(.T.)
	UnLockByName("A280NUMFAT",.T.,!Empty(FWxFilial("SE1")))
	//-- Fim do tratamento para nao duplicar as faturas
Else
	cFatura := cNumFat
EndIf

ProcRegua( (nLen*2)+Len(aCols) )

For nX := 1  To nLen
	cRecno  := ""
	nDoctos := 0
	// Monta a string limitando a 14Kb
	For nY := nX To nLen
		IncProc(STR0126 + Alltrim(Str(nY,10)) + "/" +Alltrim(Str(nLen,10))) //"Atualizando ctrc: "
		If aDoctos[nY][MARCA]
			nDoctos++
			If (IsInCallStack("TMSA850") .Or. IsInCallStack("TMSA851") .Or. IsInCallStack("TMSAE45PRC") .Or. IsInCallStack("TMSA170"))  .And. !IsInCallStack("TMSA491")
				cRecno += Alltrim(Str(aDoctos[nY][RECNOCTRC],20))+","
			Else
				cRecno += Alltrim(Str(aDoctos[nY][LARECNO],20))+","
			EndIf
			// Se atingiu 1000 ctrc, atualiza de 1.000 em 1.000
			If nDoctos >= 1000 .Or.;
				Len(cRecno) >= 13500
				Exit
			EndIf
		EndIf
	Next nY
	//| Aqui nRecDT6 se refere ao documento gerado por meio de documento de apoio.
	If !Empty(cRecno) .And. !Empty(nRecDT6)
		cRecno:=cRecno+AllTrim(Str(nRecDT6))+","
	EndIf
	If nDoctos > 0
		// Atualiza os campos que ligam o ctrc a fatura para os ctrc envolvidos
		cQuery := "UPDATE " + RetSqlName("DT6")
		cQuery += " SET DT6_PREFIX = '" + cPrefix + "',"
		cQuery += "     DT6_NUM    = '" + cFatura + "',"
		cQuery += "     DT6_TIPO   = '" + cTipo   + "',"
		cQuery += "     DT6_VENCTO = '" + dVencRea+ "' "
		cQuery += "WHERE R_E_C_N_O_ IN ("+SubStr(cRecno,1,Rat(",",cRecno)-1)+") "
		cQuery += " AND DT6_PREFIX = '" + Space(Len(DT6->DT6_PREFIX)) + "' "
		cQuery += " AND DT6_NUM    = '" + Space(Len(DT6->DT6_NUM))    + "' "
		cQuery += " AND DT6_TIPO   = '" + Space(Len(DT6->DT6_TIPO))   + "' "
		If (nErro:=TCSqlExec(cQuery)) <> 0
			Help(" ",1,"TMSA85006",,Alltrim(Str(nErro)),2,1) //"Erro ao atualizar docto.... Erro : "
			lErro := .T.
			Exit
		EndIf

		If lPreFat
			// Atualiza os campos da pré-fatura que ligam o ctrc a fatura 
			cQuery := " UPDATE " + RetSqlName("DEB") 
			cQuery += " SET DEB_PREFIX = '" + cPrefix + "', "
			cQuery += "     DEB_NUMFAT = '" + cFatura + "', "
			cQuery += "     DEB_TIPO   = '" + cTipo   + "'  "
			cQuery += " WHERE R_E_C_N_O_ IN ( SELECT DEBAUX.R_E_C_N_O_ "
			cQuery += "                           FROM " + RetSqlName("DT6") + " DT6AUX "
			cQuery += "                           JOIN " + RetSqlName("DEB") + " DEBAUX "
			cQuery += "                             ON DEBAUX.DEB_FILIAL = '" + xFilial("DEB") + "' "
			cQuery += "                            AND DEBAUX.DEB_FILDOC = DT6AUX.DT6_FILDOC  "	
			cQuery += "                            AND DEBAUX.DEB_DOC    = DT6AUX.DT6_DOC     "
			cQuery += "                            AND DEBAUX.DEB_SERIE  = DT6AUX.DT6_SERIE   "
			cQuery += "                            AND DEBAUX.D_E_L_E_T_ = ' '  "
			cQuery += "                           WHERE DT6AUX.R_E_C_N_O_ IN ("+SubStr(cRecno,1,Rat(",",cRecno)-1)+") "
			cQuery += "                          ) "
			If (nErro:=TCSqlExec(cQuery)) <> 0
				Help(" ",1,"TMSA85006",,RetTiTle("DEB_NUMPRE") + " : " + Alltrim(Str(nErro)),2,1) //"Erro ao atualizar docto.... Erro : "
				lErro := .T.
				Exit
			EndIf
		EndIf
	EndIf
	nX := nY
Next nX

If !lErro
	// Atualiza acrescimos e decrescimos, efetuados nos ctrcs da fatura
	nDTCISS := 0
	nImpISS := 0 
	aAreaDTC := DTC->(GetArea())
	DTC->(DbSetOrder(3)) // DTC->DTC_FILDOC, DTC->DTC_DOC, DTC->DTC_SERIE
	
	For nX := 1  To nLen

		IncProc(STR0128 + Alltrim(Str(nX,10)) + "/" +Alltrim(Str(nLen,10))) //"Atualizando ajustes nos doctos: "

		If aDoctos[nX][MARCA]
			If (aDoctos[nX][ACRESC] + aDoctos[nX][DECRESC]) > 0
				// Atualiza o acrescimo e decrescimo do ctrc atual
				cQuery := "UPDATE "
				cQuery += RetSqlName("DT6")+" "
				cQuery += "SET	DT6_ACRESC = " + Str(aDoctos[nX][ACRESC],17,2) +","
				cQuery += "		DT6_DECRES = " + Str(aDoctos[nX][DECRESC],17,2)
				If IsInCallStack("TMSA491")
					cQuery += " WHERE R_E_C_N_O_ = " + Alltrim(Str(aDoctos[nX][LARECNO],20))
				Else
					cQuery += " WHERE R_E_C_N_O_ = " + Alltrim(Str(aDoctos[nX][RECNOCTRC],20))
				EndIf
				cQuery += " AND DT6_PREFIX = '" + cPrefix + "' "
				cQuery += " AND DT6_NUM    = '" + cFatura + "' "
				cQuery += " AND DT6_TIPO   = '" + cTipo   + "' "
				TcSqlExec(cQuery)
				If (nErro:=TCSqlExec(cQuery)) <> 0
					Help(" ",1,"TMSA85006",,Alltrim(Str(nErro)),2,1) //"Erro ao atualizar docto.... Erro : "
					lErro := .T.
					Exit
				EndIf
			EndIf
			//-- Atualiza campos do usuario  
			If lTM491CPO
				ExecBlock('TM491CPO',.F.,.F., {2,aDoctos[nX][IIf(IsInCallStack("TMSA491"),LARECNO,RECNOCTRC)],cAliasTRB,cPrefix,cFatura,cTipo} )
			EndIf
			
			//Verifica se o documento selecionado possui retencao de ISS
			If DTC->(DbSeek(FWxFilial("DTC",aDoctos[nX][2]) + aDoctos[nX][2] + aDoctos[nX][3] + aDoctos[nX][4])) .and. DTC->DTC_DOCTMS $ "5/D/F/G/H/C/I/N/O" //|somente para 5-NF; D-NF Reentrega; F-NF Armazenagem; G-NF complementar; H/C/I/N/O - Apoio
				If aDoctos[nX][MARCA] .And. DTC->DTC_RECISS == "1" //| Informou na Entrada de NF Cliente (TMSAa050) que retem ISS										
					nDTCRECISS := 1
				ElseIf aDoctos[nX][MARCA] .And. DTC->DTC_RECISS == "2" //| Informou na Entrada de NF Cliente (TMSAa050) que retem ISS, por conta do cliente
					nDTCRECISS := 2
				EndIf
			EndIf
	
			DT6->(DbSetOrder(1))
			If (IsInCallStack("TMSA850") .Or. IsInCallStack("TMSA851") .Or. IsInCallStack("TMSAE45PRC") .Or. IsInCallStack("TMSA170")) .And. !IsInCallStack("TMSA491")
				DT6->(MsGoto(aDoctos[nX, RECNOCTRC]))
			Else
				DT6->(MsGoto(aDoctos[nX, LARECNO]))
			EndIf

			If DT6->DT6_DOCTMS == '5'
				nImpISS += DT6->DT6_VALIMP
			EndIf

			cCDRCAL := DT6->DT6_CDRCAL
			lAlqInt := IIf(DT6->DT6_VALFRE == DT6->DT6_VALTOT,.T.,.F.) //| Paliativo para verificar se a aliquota está embutida no frete.
			cDocTms := DT6->DT6_DOCTMS

		Endif		
	Next nX
	
	nValTotal := 0
	nLen      := Len(aCols)
	
	If Type("nDTCRECISS") <> "N"
		nDTCRECISS := Val(SA1->A1_RECISS)
	EndIf
		
	If Type("nDTCRECISS") == "N"
		If nDTCRECISS == 1 .And. lDescIss .And. !lTPABISS  //Cenário 01 - Campo A1_RECISS = S e parâmetros MV_TPABISS= 2 e MV_DESCISS= .T.
			nDTCISS   := nImpISS
		ElseIf nDTCRECISS == 1 .And. lDescIss	.And. lTPABISS //Cenário 02 - Campo A1_RECISS = S e parâmetros MV_TPABISS= 1 e MV_DESCISS = .T.
			nDTCISS   := 0
		ElseIf nDTCRECISS == 1 .And. !lDescIss	.And. !lTPABISS //Cenário 03 - Campo A1_RECISS = S e parâmetros MV_TPABISS= 2 e MV_DESCISS = .F.
			nDTCISS   := 0
		ElseIf nDTCRECISS == 2 .And. lDescIss	.And. !lTPABISS //Cenário 04 -  Alterando campo ? A1_RECISS para N e parâmetros MV_TPABISS = 2 e MV_DESCISS = .T.
			nDTCISS   := nImpISS
		Else			
			nDTCISS   := nImpISS
		EndIf
	EndIf

	DTC->(RestArea(aAreaDTC))

	//--Posiciona no DT6 que foi gerado a partir
	//--dos documentos de apoio:
	DT6->(DbSetOrder(1))
	If !Empty(nRecDT6)
		DT6->(DbGoTo(nRecDT6))
		cNumNota := DT6->DT6_DOC
	EndIf

	cCliSe1 := Padr(IIF(Empty(cCliFat ),cCli  ,cCliFat ),Len(SA1->A1_COD ))
	cLojSe1 := Padr(IIF(Empty(cLojaFat),_cLoja,cLojaFat),Len(SA1->A1_LOJA))
	If !lErro
		For nX := 1 To nLen
			IncProc(STR0129) //"Incluindo a fatura..."
			cQuery := " SELECT 1 FROM " + RetSqlName("DT6") + " DT6 "
			cQuery += " WHERE DT6_FILIAL = '" + FWxFilial("DT6") + "' "
			cQuery += " AND DT6_PREFIX = '" + cPrefix + "' "
			cQuery += " AND DT6_NUM    = '" + cFatura + "' "
			cQuery += " AND DT6_TIPO   = '" + cTipo   + "' "
			cQuery += " AND D_E_L_E_T_ = ' ' "
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
			lAchou := (cAliasQry)->(!Eof())
			(cAliasQry)->(DbCloseArea())
			If aCols == Nil
				aCols := AClone(aColsSave)
			EndIf
			If !GdDeleted(nX) .And. lAchou
				DbSelectArea("SA1")
				dbSetOrder(1) //A1_FILIAL+A1_COD+A1_LOJA
				MsSeek(FWxFilial("SA1")+cCliSe1+cLojSe1)

				//-- Calcula o Valor do Juros
				nValJur := Round((aCols[nX][5] * nPerJur)/100, TamSx3("E1_VALOR")[2])

				//-- Tratamento para grava o percentual da comissão
				If !Empty(SA1->A1_VEND)
					If !Empty(SA1->A1_COMIS)
						nComis1 := SA1->A1_COMIS
					Else
						nComis1 := Posicione("SA3", 1, xFilial("SA3") + SA1->A1_VEND, "A3_COMIS")
					EndIf
				EndIf

				//-- Problema de performace no cliente.
				RegToMemory('SE1',.T.)
				M->E1_FILIAL  := FWxFilial('SE1')
				M->E1_PREFIXO := Pad(aCols[nX][1],Len(SE1->E1_PREFIXO))
				M->E1_NUM     := Pad(cFatura, Len(SE1->E1_NUM))
				M->E1_PARCELA := Pad(aCols[nX][2],Len(SE1->E1_PARCELA))
				M->E1_TIPO    := Pad(cTipo,Len(SE1->E1_TIPO))
				M->E1_NATUREZ := cNat
				M->E1_SITUACA := "0"
				M->E1_VENCTO  := aCols[nX][4]
				M->E1_VENCREA := DataValida(aCols[nX][4],.T.)
				M->E1_VENCORI := DataValida(aCols[nX][4],.T.)
				M->E1_EMISSAO := dEmisFat
				M->E1_EMIS1   := dEmisFat
				M->E1_CLIENTE := cCliSe1
				M->E1_LOJA    := cLojSe1
				M->E1_NOMCLI  := IIF(Empty(SA1->A1_NREDUZ),SA1->A1_NOME,SA1->A1_NREDUZ)
				M->E1_MOEDA   := nMoedFat
				M->E1_VALOR   := aCols[nX][5]
				M->E1_SALDO   := aCols[nX][5]
				M->E1_VLCRUZ  := xMoeda(aCols[nX][5],nMoedFat,1)
				M->E1_STATUS  := 'A'
				M->E1_OCORREN := '01'
				M->E1_ORIGEM  := cOrigem
				M->E1_NUMNOTA := cNumNota
				M->E1_SERIE   := cSerie
				M->E1_PORCJUR := nPerJur
				M->E1_VALJUR  := nValJur
				M->E1_SITFAT  := '1'
				M->E1_FILDEB  := cFilDeb
				M->E1_FILORIG := cFilAnt
				M->E1_VEND1   := SA1->A1_VEND
				M->E1_COMIS1  := nComis1

				//-- Calcula impostos dependendo da natureza
				FA040Natur()
				//-- A rotina FA040Natur() calcula o imposto de ISS novamente, mas não considera o produto de calculo devido a isso o campo E1_ISS é
				//-- sobrescrito com o valor calculado por esta rotina TMSA850
				M->E1_ISS	   := nImpISS

				//-- Necessario gravar os impostos calculados no calculo do frete devido natureza para nao calcular impostos.
				If cTMSMFat == "2" .And. Len(aDoctos) >= nX
					If (IsInCallStack("TMSA850") .Or. IsInCallStack("TMSA851") .Or. IsInCallStack("TMSAE45PRC") .Or. IsInCallStack("TMSA170")) .And. !IsInCallStack("TMSA491")
						DT6->(DbGoto(aDoctos[nX, RECNOCTRC]))
					Else
						DT6->(DbGoto(aDoctos[nX, LARECNO]))
					EndIf
					
					SF2->(DbSetOrder(1)) //--F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
					If SF2->(MsSeek(FWxFilial("SF2")+DT6->(DT6_DOC+DT6_SERIE+DT6_CLIDEV+DT6_LOJDEV)))
						M->E1_PIS    := SF2->F2_VALPIS
						M->E1_COFINS := SF2->F2_VALCOFI
						M->E1_CSLL   := SF2->F2_VALCSLL
					EndIf
					//| Calcula o IR se a natureza solicitar.
					SED->(DbSetorder(1))
					If SED->(MsSeek(FWxFilial("SED")+M->E1_NATUREZ))
						If SED->ED_CALCIRF == "S"
							lBaseImpIr := FA040Irf()
							nValBaseIr := If (lBaseImpIr .and. M->E1_BASEIRF > 0, M->E1_BASEIRF, M->E1_VALOR)
							M->E1_IRRF := F040CalcIr(nValBaseIr,aBases,.T.)
						EndIf
					EndIf
				EndIf

				//-- Atualiza campos do usuario
				If lTM491CPO
					aCposUsr := ExecBlock('TM491CPO',.F.,.F., {3,cAliasTRB,Pad(aCols[nX][1],Len(SE1->E1_PREFIXO)),Pad(cFatura, Len(SE1->E1_NUM)),Pad(cTipo,Len(SE1->E1_TIPO))} )
					If ValType(aCposUsr) <> 'A'
						aCposUsr := {}
					EndIf
					For nCnt := 1 To Len(aCposUsr)
						M->&(aCposUsr[nCnt,1]) := aCposUsr[nCnt,2]
					Next nCnt
				EndIf

				DbSelectArea("SE1")
				RecLock('SE1',.T.)
				For nXCont:=1 TO FCount()
					If "FILIAL"$Field(nXCont)
						FieldPut(nXCont,FWxFilial("SE1"))
					Else
						If Type("M->"+FieldName(nXCont)) <> "U"
							FieldPut(nXCont,M->&(FieldName(nXCont)))
						EndIf
					EndIf
				Next nXCont

				//-- Atualiza campos do usuario

				If lTM850CPO
					ExecBlock('TM850CPO',.F.,.F.)
				EndIf

				DbSelectArea("SE1")

				//-- Função padrão de complemento de gravação e execução de P.E.
				aColsSave := AClone(aCols)
				FA040AXINC('SE1')
				aCols := AClone(aColsSave)
				MsUnLock()
				//Passa o Numero da Fatura, para a impressao da Fatura na rotina de geracao de pre-fatura
				If IsInCallStack("TMSAE45PRC")
					Aadd(aPreFat,{M->E1_PREFIXO,M->E1_NUM,M->E1_EMISSAO})
				EndIf
			ElseIf !lAchou
				Help(" ",1,"TMSA85006",,STR0143,2,1) //"Erro ao atualizar docto.... Erro : "
				lErro := .T.
				DisarmTransaction()
				Exit
			EndIf
		Next nX

		//--Armazena as Faturas geradas para
		//--apos o final do processamento exibir
		//--um resumo para o usuario:
		If lMV_TMSFMSG
			AAdd( aFtGeradas, {STR0142 + cFatura} ) //-- 'Fatura Gerada:'
		EndIf

		//-- Apos gravacao da fatura
		If lTM850ITE
			ExecBlock('TM850ITE',.F.,.F.)
		EndIf

		If !lFTPorDoc
			//-- Apos geracao da duplicata, consistir verificacao para doctos ACT, gravar campos prefixo/num/tipo/dt vencto
			If Len(aDocAct) > 0
				SE1->(DbSetOrder(2))
				For nX := 1 to Len(aDocAct)
					If SE1->(DbSeek(cSeek :=aDocAct[nX,1]+aDocAct[nX,2]+aDocAct[nX,3]+aDocAct[nX,4]+aDocAct[nX,5]))
						cDocPrefix  := SE1->E1_PREFIXO
						cDocTipo    := SE1->E1_TIPO
						If lTM491TIP
							//-- Permite alterar tipo de faturamento
							cDocUser := ExecBlock("TM491TIP",.F.,.F.,{cDocTipo})
							// Serie do Documento contem tamanho limite do campo
							If ValType(cDocUser) == "C" .And. Len(Alltrim(cDocUser)) <= Len(Alltrim(SE1->E1_TIPO))
								cDocTipo := cDocUser
							EndIf
						EndIf
						While SE1->(!Eof()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == cSeek
							cDocNum  := SE1->E1_NUM
							dDocVenc := SE1->E1_VENCREA
							SE1->(DbSkip())
						EndDo
						DT6->(DbGoto(aDocAct[nX,6]))
						RecLock('DT6',.F.)
						DT6->DT6_PREFIX := cDocPrefix
						DT6->DT6_NUM    := cDocNum
						DT6->DT6_TIPO   := cDocTipo						
						DT6->DT6_VENCTO := dDocVenc //-- Data de Vencimento da Ultima parcela do SE1
						DT6->(MSUnlock())
					EndIf
				Next nX
			EndIf
			aDocAct := {}
		EndIf
	EndIf
EndIf

RestArea( aAreaSA1 )
 
Return( aFtGeradas )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa850Ajustes³ Autor ³ Claudio D. de Souza   ³ Data ³ 16/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Exibe a tela para que o usuario realize os ajustes nos ctrcs     ³±±
±±³          ³a faturar e tambem permite a inclusao de ctrcs nao selecion.     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa850Ajustes(	oLbxDocto, aDoctos, oValor, oQtdTit, nValor, lFatVazia )
Local oGet
Local nOpca     := 0
Local nLen      := 0
Local nAscan    := 0
Local lAddNewLin:= .F.
Local nValorAnt := 0
Local nDif      := 0
Local nX        := 0
Local nPosDif   := 0
Local nPosRecno := 0
Local lOk       := .F.
Local aAlter    := {}
Local aFldDT6		:= {}
Local aHeadDT6		:= {"DT6_FILDOC", "DT6_DOC", "DT6_SERIE", "_SI_VALFAT", "DT6_VALFRE","_SI_VALAJU", "DT6_ACRESC", "DT6_DECRES", "_SI_RECNO"}
Local aFldCustom	:= {}
Local nI			:= 0
Local nPos			:= 0

Default lFatVazia := .F.

//--Salva aCols e aHeader
SaveInter()

aCols := {}
aHeader := {}
aCopDoctos := aClone(aDoctos)
aFldDT6 := ApBuildHeader("DT6")
aAdd(aFldCustom, {STR0059, "_SI_VALFAT", "@E 999,999,999.99", 15, 2, "T850ValFat(__oGetDad)", USADO, "N", , "V"}) //"Valor a Faturar"
aAdd(aFldCustom, {STR0132, "_SI_VALAJU", "@E 999,999,999.99", 15, 2, "T850ValAju(__oGetDad)", USADO, "N", , "V"}) //"Ajuste"
aAdd(aFldCustom, {STR0133, "_SI_RECNO" , ""					, 15, 0, ""						, USADO, "N", , "V"}) //"Controle"
nValFat  := 0

For nI := 1 To Len(aHeadDT6)
	If (nPos := aScan(aFldCustom, {|x| AllTrim(x[2]) == aHeadDT6[nI]})) > 0
		aAdd(aHeader, aFldCustom[nPos])
	ElseIf (nPos := aScan(aFldDT6, {|x| AllTrim(x[2]) == aHeadDT6[nI]})) > 0
		aAdd(aHeader, aFldDT6[nPos])
		If aHeadDT6[nI] == "DT6_DOC"
			aHeader[Len(aHeader)][6] := "T850ValSer(aCopDoctos,__oGetDad,1,'DT6_DOC')"
		ElseIf aHeadDT6[nI] == "DT6_SERIE"
			aHeader[Len(aHeader)][6] := "T850ValSer(aCopDoctos,__oGetDad,1,'DT6_SERIE')"
		EndIf
	EndIf
Next

aAlter := {"DT6_FILDOC", "DT6_DOC", "DT6_SERIE", "_SI_VALFAT", "_SI_VALAJU"}

DEFINE MSDIALOG oDlg TITLE STR0134 From 9,0 To 28,80 OF oMainWnd //"Inclusão de ctrcs e ajustes nos ctrcs para faturamento"
	oGet := MSGetDados():New(33,2,138,315,3,{|| .T. },,,.T.,aAlter,,,99999)
	oGet:oBrowse:lHScroll := .F.
	oGet:oBrowse:bChange := { || Tmsa850ChLin(oGet) }
	__oGetDad := oGet

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
	{||nOpca:=1,If(oGet:TudoOk(),oDlg:End(),nOpca := 0)},;
	{||nOpca:=0,If((Len(aCols) > 1 .Or. (Len(aCols) = 1) .And. !Empty(aCols[n][1]) ) .And. MsgYesNo("Deseja realmente desistir dos ajustes?"), oDlg:End(),If(Empty(aCols[n][1]),oDlg:End(),Nil))}) CENTER

If nOpca == 1
	nLen := Len(aCols)
	// Pesquisa os ctrcs a serem ajustados, marca e registra os ajustes a credito ou a debito
	nPosDif		:= aScan(aHeader, {|e| e[2] == "_SI_VALAJU" } )
	nPosRecno	:= aScan(aHeader, {|e| e[2] == "_SI_RECNO" } )
	For nX := 1 To nLen
		lOk 		:= .F.
		lAddNewLin	:= .F.
		nValorAnt   := 0
		// Se a linha nao estiver deletada
		If ! GdDeleted(nX)
			nAscan := aScan(aDoctos, {|e| e[FILDOC]+e[CTRC]+e[SERIE] == aCols[nX][1]+aCols[nX][2]+aCols[nX][3] })
			If nAscan > 0
				//--Zera acrescimos/decrescimos anteriores
				aDoctos[nAscan][ACRESC ] := 0
				aDoctos[nAscan][DECRESC] := 0

				nDif := aCols[nX][nPosDif]
				lOk := .T.
				// Diferença positiva, gera acrescimo
				If nDif > 0
					aDoctos[nAscan][ACRESC ] := aDoctos[nAscan][ACRESC ] + Abs(nDif)
				Else
					// Senao, gera decrescimo
					aDoctos[nAscan][DECRESC] := aDoctos[nAscan][DECRESC] + Abs(nDif)
				EndIf
			Else
				If aCols[nX][nPosRecno] > 0
					DT6->(MsGoto(aCols[nX][nPosRecno]))
					// Verifica se o ctrc nao foi faturado ainda
					If Empty(DT6->(DT6_PREFIX+DT6_NUM+DT6_TIPO))
						// Valida Devedor
						If DT6->DT6_CLIDEV == Left(cCli, Len(SA1->A1_COD)) .And. (MV_PAR01 == 2 .Or. DT6->DT6_LOJDEV == _cLoja) .And.;
							DT6->DT6_FILDEB == cFilDeb
							// Se a matriz de doctos (ctrc) estiver vazia na primeira linha, inclui nesta linha, senao inclui novas linhas
							AAdd(aDoctos, { .T., DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, DT6->DT6_VALTOT	,;
								If(aCols[nX][nPosDif]>0,aCols[nX][nPosDif],0)									,;
								If(aCols[nX][nPosDif]<0,Abs(aCols[nX][nPosDif]),0)								,;
								If(DT6->DT6_VALFAT>0,DT6->DT6_VALFAT,DT6->DT6_VALTOT),DT6->DT6_DATEMI			,;
								Posicione('DUY',1,FWxFilial('DUY')+DT6->DT6_CDRDES,'DUY_EST'),,DT6->(Recno()) } )
							
							nAscan 		:= Len(aDoctos)
							lAddNewLin	:= .T.
							nQtdCTRC ++
							lOk := .T.
						EndIf
					EndIf
				EndIf
			EndIf
			If lOk
				// Atualiza o valor a faturar
				If !lAddNewLin
					nValorAnt := aDoctos[nAscan][VALFAT] // equivale a acao de desmarcar documento
				EndIf
				aDoctos[nAscan][VALFAT] := aDoctos[nAscan][VALFRETE]+aDoctos[nAscan][ACRESC]-aDoctos[nAscan][DECRESC]
				// Atualiza o valor total da fatura com o valor de acrescimo ou decrescimo.
				If aDoctos[nAscan][MARCA]
					If lAddNewLin
						nValor  += aDoctos[nAscan][VALFAT ]
					Else
						//nValor  += aDoctos[nAscan][ACRESC ]
						//nValor  -= aDoctos[nAscan][DECRESC]
						nValor  += aDoctos[nAscan][VALFAT]
						nValor  -= nValorAnt
					EndIf
					nValFat := nValor
				EndIf
			EndIf
		EndIf
	Next
EndIf

oLbxDocto:Refresh()

//--Restura aCols e aHeader
RestInter()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³T850Valser   ³ Autor ³ Claudio D. de Souza   ³ Data ³ 16/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida a serie para pesquisa do ctrc a ser incluido/excluido    ³±±
±±³          ³de uma fatura                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function T850ValSer(aDoctos,oGet,nTipo,cCampo)
Local aMsgErr     := {}
Local nAscan      := 0
Local nPosFilDoc  := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_FILDOC" } )
Local nPosDoc     := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_DOC"    } )
Local nPosSerie   := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_SERIE"  } )
Local nPosValFret := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_VALFRE" } )
Local nPosValFat  := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALFAT" } )
Local nPosRecno   := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_RECNO"  } )
Local nPosAjuste  := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALAJU" } )
Local nPosValAcr  := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_ACRESC" } )
Local nPosValDecr := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_DECRES" } )
Local lRet        := .F.
Local lOkCTe      := .F.
Local cVar        := ReadVar()
Local cChave      := ""

Local cFilDoc  := ""
Local cDoc     := ""
Local cSerie   := ""
Local lCONTDOC := SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran")

If !GdDeleted()
    lOkCTe := .F.

	// Se a serie ja estiver preenchida, pesquisa com as informacoes ja existentes
	If cCampo = "DT6_SERIE" .Or. !Empty(aCols[n][nPosSerie])
		If cCampo = "DT6_DOC"
			cFilDoc := aCols[n][nPosFilDoc]
			cDoc    := &cVar
			cSerie  := aCols[n][nPosSerie]
			cChave := aCols[n][nPosFilDoc]+&cVar+aCols[n][nPosSerie]
		Else
			cFilDoc := aCols[n][nPosFilDoc]
			cDoc    := aCols[n][nPosDoc]
			cSerie  := &cVar
			cChave := aCols[n][nPosFilDoc]+aCols[n][nPosDoc]+&cVar
		EndIf
		// n = Publica definida na GetDados
		// nTipo - 1 = Inclusao/Alteracao, 2=Exclusao
		nAscan := aScan(aDoctos, {|e| e[FILDOC]+e[CTRC]+e[SERIE] == cChave })
		If nAscan > 0
			aCols[n][nPosValFret] := aDoctos[nAscan][VALFRETE]
			aCols[n][nPosValAcr ] := aDoctos[nAscan][ACRESC  ]
			aCols[n][nPosValDecr] := aDoctos[nAscan][DECRESC ]
			If nTipo == 1 // Inclusao
				// Atualiza o valor a faturar e o valor do frete
				aCols[n][nPosValFat] := aDoctos[nAscan][VALFRETE]+aCols[n][nPosValAcr]-aCols[n][nPosValDecr]
			Endif
			If ValType(oGet) == "O"
				oGet:Refresh()
			Endif
			lRet := .T.
		Else
			// Se for inclusao/Alteracao, pesquisa CTRC
			If nTipo == 1
				lRet := TMA850Val(.F.,@nValFat,lCONTDOC,@nQtdCTRC,cFilDoc,cDoc,cSerie,aCols[n][nPosValFret],aCols[n][nPosValAcr ],;
								  aCols[n][nPosValDecr],@aMsgErr,.T.)

				If lRet
					// Atualiza o valor a faturar e o valor do frete
					aCols[n][nPosValFret] := DT6->DT6_VALTOT
					aCols[n][nPosValAcr ] := DT6->DT6_ACRESC
					aCols[n][nPosValDecr] := DT6->DT6_DECRES
					aCols[n][nPosValFat]  := DT6->(DT6_VALTOT+DT6_ACRESC-DT6_DECRES)
					aCols[n][nPosAjuste]  := DT6->(DT6_ACRESC-DT6_DECRES)
					aCols[n][nPosRecno]   := DT6->(Recno())
					If ValType(oGet) == "O"
						oGet:Refresh()
					Endif
				EndIf
			EndIf
		Endif
	Else
		lRet := .T.	
	Endif
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³T850ValFat      ³ Autor ³ Claudio D. de Souza   ³ Data ³ 16/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Calcula o valor do ajuste, apos ser informado o valor             ³±±
±±³          ³a faturar                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function T850ValFat(oGet)
Local nPosDif     := aScan(aHeader, {|e| e[2] == "_SI_VALAJU" } )
Local nPosValFret := aScan(aHeader, {|e| e[2] == "DT6_VALFRE" } )
Local nPosValAcr  := aScan(aHeader, {|e| e[2] == "DT6_ACRESC" } )
Local nPosValDecr := aScan(aHeader, {|e| e[2] == "DT6_DECRES" } )
Local nValFat     := 0
Local nDif        := 0
Local lRet        := .T.
Local lRet2       := .T.

If ! GdDeleted()
	//-- Valor a faturar menos o valor do frete, gera a diferenca de ajuste
	nValFat := &(ReadVar())
	nDif    := nValFat - aCols[n][nPosValFret]
	If nValFat > 0
		aCols[n][nPosDif] := nDif
		If nDif > 0
			//-- Acrescimo
			aCols[n][nPosValAcr ] := nDif
			aCols[n][nPosValDecr] := 0
		Else
			//-- Decrescimo
			aCols[n][nPosValDecr] := ( nDif * -1 )
			aCols[n][nPosValAcr ] := 0
		EndIf
		If ValType(oGet) == "O"
			oGet:Refresh()
		EndIf
	Else
		Help("",1,"TMSA85016") //-- Valor da Fatura invalido.
		lRet := .F.
	EndIf
Endif
If lRet .And. lTM850Fat
	//-- Validar valor da fatura na opcao Ajuste
	lRet2 := ExecBlock( "TM850FAT", .F., .F.,{ } )
	If (ValType(lRet2) == "L")
		lRet := lRet2
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³T850ValAju      ³ Autor ³ Claudio D. de Souza   ³ Data ³ 16/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Calcula o valor a faturar, apos ser informado o valor do ajuste    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function T850ValAju(oGet)
Local nPosValFat  := aScan(aHeader, {|e| e[2] == "_SI_VALFAT" } )
Local nPosValFret := aScan(aHeader, {|e| e[2] == "DT6_VALFRE" } )
Local nPosValAcr  := aScan(aHeader, {|e| e[2] == "DT6_ACRESC" } )
Local nPosValDecr := aScan(aHeader, {|e| e[2] == "DT6_DECRES" } )
Local lTM850AJU   := ExistBlock("TM850AJU")
Local nValTotFat  := aCols[n][nPosValFret]
Local nValFat     := 0
Local nDif        := 0
Local lRet        := .T.
Local lRet2       := .F.

If ! GdDeleted()
	//-- Valor do ajuste mais o valor do frete, gera o valor a faturar
	nDif    := &(ReadVar())
	nValFat :=  nValTotFat + nDif
	If nValFat > 0
		aCols[n][nPosValFat] := nValFat
		If nDif > 0
			//-- Acrescimo
			aCols[n][nPosValAcr ] := nDif
			aCols[n][nPosValDecr] := 0
		Else
			//-- Decrescimo
			aCols[n][nPosValDecr] := ( nDif * -1 )
			aCols[n][nPosValAcr ] := 0
		EndIf
		If ValType(oGet) == "O"
			oGet:Refresh()
		EndIf
	Else
		Help("",1,"TMSA85016") //-- Valor da Fatura invalido.
		lRet := .F.
	EndIf
	If lRet .And. lTM850AJU
		//-- Valida ajuste da fatura
		lRet2 := ExecBlock("TM850AJU", .F., .F.,{ })
		If (ValType(lRet2) == "L")
			lRet := lRet2
		EndIf
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa850Tela ³ Autor ³ Claudio D. de Souza   ³ Data ³ 16/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Exibe a tela para selecao/exclusao/visualizacao dos ctrcs  de  ³±±
±±³          ³uma fatura                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa850Tela( lFatVazia, cPrefix, cFatura, cNat, nMoedFat, nOpcX, ;
						aCampos, aTitulos, aDoctos, nValFat, nTotExcluido, lExclui,;
						lVisual, nTotCanc, nVlrImp, aFatCli, nLinha, cCliente, cLoja,;
						cFilDoc, cDoc, cSerie, aVFContr, lMrkDoc, aColSiz, dVencFat, aFtGeradas, dVencCond, oTempTable, lDocApoio, nValApoio)

Local oDlg
Local bInit
Local cFilOriDe  := Space(Len(DT6->DT6_FILDOC))
Local cUfDestDe  := Space(2)
Local cFilOriAte := Replicate( "Z", Len(DT6->DT6_FILDOC))
Local cUfDestAte := "ZZ"
Local lTMSA850   := Upper(AllTrim(FunName())) == "TMSA850"
Local cTmsERP    := SuperGetMV("MV_TMSERP",,'0')
Local nMark      := If(lExclui .Or. (lTMSA850 .And. !lMrkDoc),2,1)
Local nOpca      := 0
Local aBut       := {}
Local aBut2      := {}
Local cSeek      := ""
Local aAreaSE1   := ""
Local nValorAux  := 0
Local nParcelas  := 0
Local nI         := 0
Local nX         := 0
Local lMarcTodos := .F.
Local bCodBar := {|| TM850CodBr(lFatVazia,aDoctos,oLbxDocto,oMark,@nValFat,@nQtdCTRC,aVFContr, lExclui, @nTotExcluido) }   
Local oBold
Local oSay
Local oTotCanc
Local oCliente
Local oValorFat
Local lTMSA491  := Upper(AllTrim(FunName())) == "TMSA491"
Local lCONTDOC	:= SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran") //--Parametro para controle de Transações da Viagem mod2,
					//-- o documento ficara locado até confirmar ou fechar a viagem impossibilitando o uso do documento por outras Estações.
Local aDoctosBkp := IIF(lCONTDOC, aClone(aDoctos), {})

Local lOfuscated:= .F.
Local lLGPD		:= FindFunction('FWPDCanUse') .And. FWPDCanUse(.T.) .And. FindFunction('TMLGPDCpPr') .And. AliasInDic("XAM")
Local nTamCpos	:= 0
Local aBkpKey	:= {}

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

Default nTotCanc := 0
Default nVlrImp  := 0
Default cCliente := ''
Default cLoja    := ''
Default cFilDoc  := ''
Default cDoc     := ''
Default cSerie   := ''
Default aVFContr := {}
Default nMaxCTRC := 0
Default lMrkDoc  := .F.
Default lFatVazia  := .F.
Default cPrefix    := ''
Default cFatura    := ''
Default cNat       := ''
Default aColSiz    := {}
Default dVencFat   := CtoD(Space(08))
Default aFtGeradas := {}
Default oTempTable := {}
Default lDocApoio  := .F.
Default nValApoio  := 0

If Type("lFtAut") == "U"
	Private lFtAut := .F.
EndIf
If Type("aSetKey") == "U"
	Private aSetKey := {}
EndIf

aBkpKey	:= AClone(aSetKey)
aSetKey := {}

Pergunte("TMA850",.F.)

If  lLGPD
	aCposProte := TMLGPDCpPr({"A1_NOME"},"SA1")
	nTamCpos := Len(aCposProte)
	If nTamCpos > 0
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aCposProte )) < nTamCpos
			lOfuscated := .T.
		EndIf
	EndIf		
EndIf
// Deleta a primeira linha da matriz de doctos, para exibir a tele em branco ao usuario. Se criar o
// listbox com a matriz em branco, nao sera possivel adicionar novas linhas e se deixar a primeira linha
// em branco, pode ocorrer de o usuario selecionar esta linha.
bInit := { || If(lFatVazia, aDoctos := aSize(aDoctos,0),Nil), oLbxDocto:Refresh()}

//--Verifica a configuracao do contrato
//--em relacao ao valor fixo (Veiculo Dedicado):
If lExclui .Or. lVisual
	If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
		//--Cancelamento de uma fatura gerada a 
		//--partir de um documento de apoio:
		DT6->(DbSetOrder(1)) //--DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
		If DT6->( DbSeek(xFilial('DT6') + aDoctos[1][FILDOC] + aDoctos[1][CTRC] + aDoctos[1][SERIE]) )

			aVFContr := TMSA491VlrC(	cCliente, cLoja,;
										DT6->DT6_TIPFRE, DT6->DT6_SERVIC,;
										DT6->DT6_DATEMI	)
		EndIf
	EndIf
EndIf

//--Realiza tratamento referente a 
//--Marcacao/Desmarcacao dos documentos
//--APENAS PARA FATURA P/ DOCUMENTO:
If	(lTMSA850 .Or. cTmsErp == '1') .And. (!lExclui .And. !lVisual)
	If !lMrkDoc .And. nOpcx <> 4
		AEval( aDoctos, {|e| e[MARCA] := .F.} )
		nQtdCTRC := 0
		nValFat  := 0
	Else
		If nValorF == 0 .And. nMaxCTRC == 0
			//--Se nao for definido valor maximo
			//--para a fatura e qtde. maxima de 
			//--CTRC's, traz -TODOS- documentos 
			//--marcados
			AEval( aDoctos, {|e| If(!Empty(e[NUMFAT]),(e[MARCA] := .T.,nQtdCTRC++,nValFat += e[VALFAT]),)} )
			
		ElseIf nValorF > 0 .And. nMaxCTRC > 0
			//--**Marca os documentos ate atingir
			//--o maximo de documentos definido
			//--**Marca os documentos ate atingir o
			//--valor maximo da fatura definido
			For nI := 1 To Len( aDoctos )
				If nQtdCTRC < nMaxCTRC
					nValorAux += aDoctos[nI][VALFAT]
					If nValorAux <= nValorF
						aDoctos[nI][MARCA] := .T.
						nQtdCTRC++
						nValFat += aDoctos[nI][VALFAT]
					Else
						nValorAux -= aDoctos[nI][VALFAT]
					EndIf
				EndIf
			Next nI
			//-- Trava o registro que está sendo usado por outra estação
			If lCONTDOC .And. !Empty(aDoctos)		
				For nX := 1 to Len(aDoctos)
					If aDoctos[nX][MARCA] == .T. .And. !TmsConTran(aDoctos[nX][FILDOC],aDoctos[nX][CTRC],aDoctos[nX][SERIE], .T.)				
						lFat := .F.											
						lContinua := .F.				
					EndIf	
				Next nX				 					 
			EndIf	
			
		ElseIf nMaxCTRC > 0
			//--Marca os documentos ate atingir o
			//--maximo de documentos definido
			AEval( aDoctos, {|e| e[MARCA] := .T., nQtdCTRC++, nValFat += e[VALFAT]},, nMaxCTRC)

		ElseIf nValorF > 0
			//--Marca os documentos ate atingir o valor 
			//--maximo da  fatura definido
			For nI := 1 To Len( aDoctos )
				nValorAux += aDoctos[nI][VALFAT]
				If nValorAux <= nValorF
					aDoctos[nI][MARCA] := .T.
					nQtdCTRC++
					nValFat += aDoctos[nI][VALFAT]
				Else
					nValorAux -= aDoctos[nI][VALFAT]
				EndIf
			Next
		EndIf
	EndIf	
EndIf

If Empty(oTempTable)
	DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 44,120 OF oMainWnd //"Fatura a Receber"	
	
	   @ 02.5, 00.3 TO 04.4,15 OF oDlg
	
		If cTmsERP == '1'
			If !lExclui .And. !lVisual
				@ 2.9, 00.8 SAY STR0024 + AllTrim(Str(nMoedFat,2,0)) FONT oDlg:oFont //"Moeda: "
			Else
				@ 2.9, 00.8 SAY STR0139 + cFatura //"Fatura Nº: "
				@ 3.7, 00.8 SAY STR0024 + AllTrim(Str(nMoedFat,2,0)) FONT oDlg:oFont //"Moeda: "
			EndIf
		Else
		   @ 2.9, 00.8 SAY STR0051 + cPrefix FONT oDlg:oFont //"Prefixo: "
			If !lExclui .And. !lVisual
				@ 02.9, 06.0 SAY STR0023 + Substr(cNat,1,10) FONT oDlg:oFont //"Natureza: "
			Else
				@ 02.9, 06 SAY STR0139 + cFatura //"Fatura Nº: "
				@ 3.7,  06 SAY STR0023 + Substr(cNat,1,10) FONT oDlg:oFont //"Natureza: "
			EndIf
			@ 3.7, 00.8 SAY STR0024 + AllTrim(Str(nMoedFat,2,0)) FONT oDlg:oFont //"Moeda: "
		EndIf
	
		@ 2.5, 15.0 TO 4.4,59 OF oDlg
		@ 2.9, 15.5 SAY STR0017 FONT oDlg:oFont //"Cliente"
		If !lExclui .And. !lVisual .And. Type('cCli') <> 'U'
			cCli := cCli + '-' + Posicione('SA1',1, FWxFilial('SA1')+cCli+_cLoja,'A1_NOME')
			If lLGPD
				@ 3.7, 17.5 MSGET oCliente Var cCli Size 120,9 Of oDlg 	FONT oBold OFUSCATED lOfuscated WHEN .F.
			Else
				@ 3.7, 15.5 MSGET oCliente Var cCli Size 120,9 Of oDlg 	FONT oBold WHEN .F.
			EndIf	
		Else			
			cCli := SA1->(A1_COD+"-"+A1_NOME)
			If llGPD
				@ 3.7, 17.5 MSGET oCliente Var cCli Size 120,9 Of oDlg FONT oBold OFUSCATED lOfuscated WHEN .F.
			Else
				@ 3.7, 15.5 MSGET oCliente Var cCli Size 120,9 Of oDlg FONT oBold WHEN .F.
			EndIf
		EndIf
	
		//--Somente controla o valor maximo da fatura quando a geracao 
		//--da fatura nao esteja sendo realizada de forma automatica:
		If !lTMSA491 .And. !lExclui .And. !lVisual  
			@ 2.7, 31.3 SAY STR0095 FONT oDlg:oFont //"Vlr. Maximo da Fatura"
			@ 3.1, 31.3 SAY STR0146 FONT oDlg:oFont //"(0=Sem Limite)"
			@ 3.7, 31.3 MSGET oValorFat VAR nValorF SIZE 79,9 Of oDlg Picture "@E 9,999,999,999.99" FONT oBold WHEN .F. HASBUTTON
		EndIf
		
		   @ 2.9, 41.5 SAY STR0016 FONT oDlg:oFont //"Valor da fatura"
	       @ 3.7, 41.5 MSGET oValor VAR nValFat SIZE 85,9 OF oDlg Picture "@E 999,999,999,999.99" FONT oBold WHEN .F. HASBUTTON
	       @ 2.7, 53.9 SAY STR0140 FONT oDlg:oFont //"Qtde."
	       @ 3.1, 53.7 SAY STR0127 FONT oDlg:oFont //"Doctos."
	       @ 3.7, 52.7 MSGET oQtdTit VAR nQtdCtrc SIZE 12,9 Of oDlg PICTURE "@E 9,999,999" FONT oBold WHEN .F.
	
		If nOpcX == 4 .Or. nOpcx == 5 //Se for alteração traz os documentos contidos na fatura, com o mark.
			If cTmsERP == '1' 
				If nOpcX == 5
					//-- Quando houver integracao com o ERP Datasul, somente permitira o cancelamento total
					lMarcTodos := .T.
				EndIf
			Else
				//-- Quando houver integracao com o SIGAFIN, se houver mais de uma parcela para a fatura,
				//-- somente permitira o cancelamento total
				aAreaSE1 := SE1->(GetArea())
				If nOpcX == 4 .And. Len(aDoctos) > 0
					DbSelectArea("SE1")
					DbSetOrder(2)
					SE1->(MsSeek(cSeek := FWxFilial("SE1")+cCliente+cLoja+cPrefix+cFatura))
					While SE1->(!EOF()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == cSeek
						nParcelas++
						DbSkip()
						If nParcelas > 1
							lMarcTodos := .T.
							Exit
						EndIf
					EndDo
				EndIf
				RestArea(aAreaSE1)
			EndIf
			
			If lDocApoio	//-- Se existir pelo menos um documento de apoio marca todos os documentos
				lMarcTodos := .T.
			EndIf
			
			//--Ja traz todos documentos marcados:
			If lMarcTodos				
				AEval( aDoctos, {|e| e[MARCA] := .T.} )
				If lExclui .And. lDocApoio 
					AEval( aDoctos, {|e| nTotExcluido += e[VALFAT] } )
					nTotExcluido -= nValApoio
				Else
					nQtdCTRC := 0
					AEval( aDoctos, {|e| Iif(!Posicione("DT6",1,xFilial("DT6") + e[FILDOC] + e[CTRC] + e[SERIE],"DT6_DOCTMS") $ ("B,C,H,I,N,O") .Or.;
											 Empty(Posicione('DUI',1,xFilial('DUI',DT6->DT6_FILDOC)+DT6->DT6_DOCTMS,'DUI_DOCFAT')),nTotExcluido += e[VALFAT],)} )
					AEval( aDoctos, {|e| Iif(!Posicione("DT6",1,xFilial("DT6") + e[FILDOC] + e[CTRC] + e[SERIE],"DT6_DOCTMS") $ ("B,C,H,I,N,O") .Or.;
											 Empty(Posicione('DUI',1,xFilial('DUI',DT6->DT6_FILDOC)+DT6->DT6_DOCTMS,'DUI_DOCFAT')),nQtdCTRC += 1,)} )
				EndIf
			EndIf
		EndIf
	
		oSay := TSay():New(238,350, {|| STR0121 },,,oBold,,,,.T.,CLR_HRED,,,,,,,,) //--"Aguarde! Obtendo os dados..."
		oSay:Hide()
	
		// Se nao for visualizacao, exibe os campos para marcacao e desmarcacao dos ctrcs a faturar
		If !lVisual .And. !lMarcTodos
	
			@ 04.6, 00.3 TO 06.3,15 OF oDlg
			@ 65.0, 05.0	RADIO 		oMark ;
							VAR			nMark ;
							PROMPT		STR0141, STR0138 ;
							ON CHANGE	(CursorWait(), oSay:Show(), TMSA850Inv(2, aDoctos, oLbxDocto, oMark,,,,,@nValFat, @nQtdCTRC, aVFContr, lExclui, @nTotExcluido ), oSay:Hide(), oValor:Refresh(), oQtdTit:Refresh(), If(ValType(oTotCanc)=="O", oTotCanc:Refresh(), NIL), CursorArrow()) ;
							SIZE 68,9 PIXEL OF oDlg
	
			@ 04.6, 15.0 To 06.3, 59.0 OF oDlg
			@ 05.1, 16.0 Say STR0125 OF oDlg //"Filial de Origem (De/Ate)"
			@ 05.7, 16.0 MSGET cFilOriDe SIZE 20, 9 OF oDlg PICTURE "@!"
			@ 05.9, 19.0 Say "/" Of oDlg Font oBold
			@ 05.7, 20.0 MSGET cFilOriAte Valid cFilOriAte >= cFilOride SIZE 20, 9 OF oDlg PICTURE "@!" 
	
			@ 05.1, 26.0 Say STR0123 OF oDlg  //"UF Destino (De/Ate)"
			@ 05.7, 26.0 MSGET cUFDestDe SIZE 20, 9 OF oDlg PICTURE "@!"
			@ 05.9, 29.0 Say "/" OF oDlg Font oBold
			@ 05.7, 30.0 MSGET cUFDestAte Valid cUfDestAte >= cUfDestDe SIZE 20, 9 OF oDlg PICTURE "@!"
	
			TButton():New(72.5,350.0, STR0003 , oDlg,; //--"Selecionar"
							{|| (CursorWait(), oSay:Show(), TMSA850Inv(3, aDoctos, oLbxDocto, oMark, cFilOriDe, cFilOriAte, cUFDestDe, cUFDestAte, @nValFat, @nQtdCTRC, aVFContr, lExclui, @nTotExcluido), oSay:Hide(), oValor:Refresh(), oQtdTit:Refresh(), If(Type("oTotCanc")=="O", oTotCanc:Refresh(), NIL), CursorArrow()) },;
					         053,012,,,,.T.,,,,,,)
	
			//--Controla os documentos
			//--selecionados (Valor)
			If lExclui
				@ 238.0, 005.0 SAY STR0122 OF oDlg PIXEL FONT oBold //"Total de exclusões"
				@ 236.0, 070.0 MSGET oTotCanc VAR nTotExcluido	SIZE 60, 9 OF oDlg PIXEL PICTURE "@E 9,999,999,999.99" WHEN .F. FONT oBold HASBUTTON
			EndIf
		Else
			If nTotCanc > 0
				@ 238.0, 005.0 SAY STR0122 OF oDlg PIXEL FONT oBold //"Total de exclusões"
				@ 236.0, 070.0 MSGET oTotCanc VAR nTotCanc		SIZE 60, 9 OF oDlg PIXEL PICTURE "@E 9,999,999,999.99" WHEN .F. FONT oBold HASBUTTON
			EndIf
		EndIf
	
		If nOpcX == 2
			aBut := { {"EXCLUIR"  ,{|| T850ConExc(nTotCanc) },STR0116 , STR0115} } //"Consulta Doctos Excluidos"
	
		ElseIf nOpcX == 3 .Or. nOpcx == 4// Geracao da fatura
			//-- "Esta opção não está disponível quando o contrato do cliente está configurado para cobrança do valor fixo (Veículo Dedicado)."
			aBut := { {"SIMULACAO",{|| If( Len(aVFContr) >0 .And. aVFContr[1] > 0, Help(" ",1,"TMSA85018"), Tmsa850Ajustes(oLbxDocto,aDoctos,oValor,oQtdTit,@nValFat,lFatVazia)) }, STR0112 , STR0106 } } //"Ajustes nos valores a faturar e inclusão de novos ctrcs"
		EndIf
	
		AAdd(aBut, {"PESQUISA",{|| T850Pesq(oLbxDocto, aDoctos,1) }, STR0103 , STR0093 } ) //"Pesquisa Docto."
		AAdd(aBut, {"DEVOLNF" ,{|| If(Len(aDoctos) > 0, T850Visual(aDoctos[oLbxDocto:nAt][2]+aDoctos[oLbxDocto:nAt][3]+aDoctos[oLbxDocto:nAt][4]), Help(" ",1,"TMSA85002")) }, STR0092 , STR0091 } ) //"Visualiza Docto"###"Docto. não encontrado!"
		AAdd(aBut, {"CODBAR"  ,bCodBar                             , STR0160 , STR0160 } )	// "Leitura Por código de barras - <F8>"
		
		
		If !lExclui .And. !lVisual
			AAdd(aBut, {"MRKDOCTMS",{|| T850MrkDoc(oLbxDocto, aDoctos, oMark, @nValFat, @nQtdCTRC, aVFContr, lExclui, @nTotExcluido), oValor:Refresh(), oQtdTit:Refresh(), If(ValType(oTotCanc)=="O", oTotCanc:Refresh(), NIL) }, STR0153 , STR0153 } ) //"Marcar por Doc.Transp."
		EndIf
		
		If	ExistBlock('TM850BUT')
			//-- Alteracao botoes da fatura
			aBut2 := ExecBlock('TM850BUT',.F.,.F.,{aBut})
			If	ValType(aBut2) == 'A' .And. aBut <> aBut2
				aBut := aClone(aBut2)
			EndIf
		EndIf
	
		If !lVisual .And. !lMarcTodos
			oLbxDocto := TWBrowse():New( 89, 3, 468, 165, NIL, ;
	                                      aTitulos, NIL, oDlg, NIL, NIL, NIL,,,,,,,,,, "ARRAY", .T. )
		Else
			oLbxDocto := TWBrowse():New( 66, 3, 468, 180, NIL, ;
	                                      aTitulos, NIL, oDlg, NIL, NIL, NIL,,,,,,,,,, "ARRAY", .T. )
		EndIf
	
		//-- Se for visualizacao, nao permite marcacao
		If (!lVisual .And. !lMarcTodos .And. !lDocApoio)
			oLbxDocto:bLDblClick := {|| TMSA850Inv(1, aDoctos, oLbxDocto, oMark,,,,,@nValFat, @nQtdCTRC, aVFContr, lExclui, @nTotExcluido, lDocApoio), oValor:Refresh(), oQtdTit:Refresh(), If(ValType(oTotCanc)=="O", oTotCanc:Refresh(), NIL) }
		ElseIf lMarcTodos
			If lDocApoio
				oLbxDocto:bLDblClick := {|| Iif(cTmsERP == '1', Help(' ', 1, 'TMSA85026'),Help( ,, 'Help',, STR0179 , 1, 0,,,,,, {STR0180} ))} //"Existem documentos de apoio."  Solução: "Nenhum documento poderá ser retirado da seleção." 
			Else
				oLbxDocto:bLDblClick := {|| Iif(cTmsERP == '1', Help(' ', 1, 'TMSA85026'), Help(' ', 1, 'TMSA85020'))} //"Este faturamento foi desdobrado em várias parcelas ou existe retenção de impostos para o título principal da fatura."
			EndIf	
		EndIf

		oLbxDocto:SetArray( aDoctos )
		oLbxDocto:bLine := { || Tmsa850bLine(oLbxDocto:nAT,aDoctos, aCampos ) }
		If (! Empty(aColSiz))
			oLbxDocto:aColSizes := aColSiz
			oLbxDocto:lHScroll  := .F.
		EndIf
		
		Aadd(aSetKey, { VK_F8 ,  bCodBar    } )
		//-- Inicializa Teclas de Atalhos
		TmsKeyOn(aSetKey)
	
	ACTIVATE MSDIALOG oDlg ON INIT (Eval(bInit),;
		      EnchoiceBar(oDlg,	{ || nOpca := 1, If( T850TudoOk(lExclui, nTotExcluido, nQtdCTRC, nValFat, aDoctos, aVFContr),;
			                                          If(!lExclui .And. !lVisual .And. !lFtAut,;
			                                              If (Tms850Save(@aFtGeradas, nMoedFat, aDoctos, dEmisFat, dVencFat, nValFat, cNat, dVencCond, nOpcx), oDlg:End(), ),;
			                                              oDlg:End() ),;
			                                          nOpca:=0 ) },;
			                     { || nOpca := 2, oDlg:End() }, , aBut ) ) CENTER

	//-- Finaliza teclas de atalhos
	TMSKeyOff(aSetKey)

Else
	nOpca := 1
	Tms850Save(@aFtGeradas, nMoedFat, aDoctos, dEmisFat, dVencFat, nValFat, cNat, dVencCond, nOpcx,.F.,oTempTable)
EndIf

//-- Se cancelou a fatura, volta aDoctos com a situacao anterior
If nOpcA != 1
	If lCONTDOC
		aDoctos := aClone(aDoctosBkp)
		For nX := 1 to Len(aDoctos)
			TmsConTran(aDoctos[nX][FILDOC],aDoctos[nX][CTRC],aDoctos[nX][SERIE], .F.)
		Next nX
	EndIf
	aSize(aDoctos, 0) 
EndIf

aSetKey	:= AClone(aBkpKey)

Return( nOpcA )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³T850TudoOk  ³ Autor ³ V.Raspa               ³ Data ³ 19.Out.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Validacao da tela de selecao de documentos                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±	±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function T850TudoOk(lExclui, nTotExcluido, nQtdCTRC, nValFat, aDoctos, aVFContr)
Local lRet        := .T.
Local nX          := 0
Local lDoctoApoio := .F.
Local aAreaDT6    := {}
Local aAreaDUI    := {}

Default aVFContr  := {}

If lExclui
	If nTotExcluido > 0
		If Len(aVFContr) > 0 .And. aVFContr[1] > 0 .And.; 
			nQtdCTRC > 0 .And. aVFContr[2]
			lRet := Aviso(STR0046, STR0147, {STR0006, STR0004} ) == 1 //--"Atencao"###"O cancelamento parcial de faturas cujo contrato do cliente esteja configurado para cobrança do Valor Fixo (Veículo Dedicado) apenas removerá o documento da fatura. Nao haverá alteração nos valores da fatura."###"Confirma"###"Cancelar"

		ElseIf nQtdCTRC > 0
			//--Verifica se o cancelamento que esta
			//--sendo realizado eh em cima de uma fatura
			//--gerada a partir de documentos de apoio:
			aAreaDT6 := DT6->(GetArea())
			aAreaDUI := DUI->(GetArea())
			For nX := 1 To Len(aDoctos)
				If aDoctos[nX][MARCA] .And. !lDoctoApoio
					//--Consiste somente os documentos marcados:	
					DT6->(DbSetOrder(1))
					If DT6->(MsSeek(FWxFilial("DT6") + aDoctos[nX,FILDOC] + aDoctos[nX,CTRC] + aDoctos[nX,SERIE]))
						lDoctoApoio := DT6->DT6_DOCTMS $ "|B|C|H|I|N|O|" .And. !Empty(Posicione('DUI',1,FWxFilial('DUI',DT6->DT6_FILDOC)+DT6->DT6_DOCTMS,'DUI_DOCFAT'))
					EndIf
				EndIf
			Next nX
			RestArea(aAreaDT6)
			RestArea(aAreaDUI)
			If lDoctoApoio
				lRet := Aviso(STR0046, STR0148, {STR0006, STR0004} ) == 1 //--"Atencao"###"O cancelamento de faturas que tenham sido geradas a partir de Documentos de Apoio irá remover todos os documentos selecionados da fatura."###"Confirma"###"Cancelar"
			EndIf
		EndIf
	Else
		Help(" ",1,"VLFATNEG") //"Valor dos títulos selecionados para a fatura não pode ser menor ou igual a zero !"
		lRet := .F.
	EndIf
Else
	lRet := Fa280ValOK(nValFat)
EndIf

If lRet .And. lTM850TOk
	//-- Validacoes complementates (TudoOk) na tela de documentos
	lRet := ExecBlock("TM850TOK",.F.,.F.)
	If ValType(lRet) <> 'L'
		lRet := .T.
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa850ChLin³ Autor ³ Claudio D. de Souza   ³ Data ³ 16/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Avalia se a nova linha da GetDados esta vazia e forca entrada  ³±±
±±³          ³do campos com o conteudo da linha superior                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa850ChLin(oGetd)

If Len(aCols) > 1 .And. n >= Len(aCols)

	//-- Inicializa a filial do docto. e a serie com o conteudo anteriormente informado
	aCols[n][1] := aCols[n-1][1]
	aCols[n][3] := aCols[n-1][3]

	oGetD:oBrowse:Refresh()
	oGetD:oBrowse:goRight()

EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³T850ConExc  ³ Autor ³ Claudio D. de Souza   ³ Data ³ 19/01/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Consulta doctos excluidos de uma fatura                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function T850ConExc(nTotCanc)

Local aArea   := GetArea()
Local aInfVis := Tmsa850Erp()
Local aSavACols
Local aSavAHeader
Local oBold
Local oGet
Local cQuery  := ""
Local aBut    := {}
Local aCampos := {	{"DT6_FILDOC" , PesqPict("DT6","DT6_FILDOC")},;
					{"DT6_DOC"    , PesqPict("DT6","DT6_DOC"   )},;
					{"DT6_SERIE"  , PesqPict("DT6","DT6_SERIE" )},;
					{"DT6_VALFRE" , PesqPict("DT6","DT6_VALFRE")},;
					{"DT6_ACRESC" , PesqPict("DT6","DT6_ACRESC")},;
					{"DT6_DECRES" , PesqPict("DT6","DT6_DECRES")},;
					{"_SI_VALFAT" , PesqPict("DT6","DT6_VALTOT")},;
					{"DVV_DTEXCL" , PesqPict("DVV","DVV_DTEXCL")} }
Local aFldAux	:= {}
Local aFldAll	:= {}
Local nI		:= 0
Local nPos		:= 0

aFldAux := ApBuildHeader("DT6")
For nI := 1 To Len(aFldAux)
	aAdd(aFldAll, aFldAux[nI])
Next

aFldAux := ApBuildHeader("DVV")
For nI := 1 To Len(aFldAux)
	aAdd(aFldAll, aFldAux[nI])
Next

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

If Type("aCols") == "A"
	aSavACols := aClone(aCols)
Endif
If Type("aHeader") == "A"
	aSavAHeader := aClone(aHeader)
Endif

aCols   := {}
aHeader := {}

cQuery := "SELECT DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE, DVV.DVV_VALTOT, DVV.DVV_ACRESC, DVV.DVV_DECRES, DT6.DT6_VALFAT, DVV.DVV_DTEXCL "
cQuery += "FROM "+RetSqlName("DVV")+ " DVV, "
cQuery +=         RetSqlName("DT6")+ " DT6 "
cQuery += "WHERE DVV_FILIAL  ='"+ xFilial("DVV") + "'"
cQuery += "  AND DVV.DVV_PREFIX = '" + aInfVis[E1PREFIXO] + "'"
cQuery += "  AND DVV.DVV_NUM    = '" + aInfVis[E1NUM]     + "'"
cQuery += "  AND DVV.DVV_TIPO   = '" + aInfVis[E1TIPO]    + "'"
cQuery += "  AND DT6.DT6_FILIAL = '" + xFilial("DT6")  + "'"
cQuery += "  AND DT6.DT6_FILDOC = DVV.DVV_FILDOC"
cQuery += "  AND DT6.DT6_DOC    = DVV.DVV_DOC"
cQuery += "  AND DT6.DT6_SERIE  = DVV.DVV_SERIE"
cQuery += "  AND DVV.D_E_L_E_T_ <> '*'"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
TcSetField("TRB","DT6_VALTOT"  ,"N", 17,2)
TcSetField("TRB","DVV_DTEXCL"  ,"D", 8,0)

// Carrega os dados dos doctos. excluidos para exibir na GetDados
While !Eof()
	AAdd(aCols, { TRB->DT6_FILDOC, TRB->DT6_DOC, TRB->DT6_SERIE, TRB->DVV_VALTOT, TRB->DVV_ACRESC, TRB->DVV_DECRES, Iif(TRB->DVV_ACRESC<>0 .Or. TRB->DVV_DECRES<>0, TRB->(DVV_VALTOT+DVV_ACRESC-DVV_DECRES), TRB->DT6_VALFAT), TRB->DVV_DTEXCL, "", .F. } )
	DbSkip()
End

AAdd(aBut, {"PESQUISA",{|| T850Pesq(oGet, aCols,2) }, STR0103 , STR0093 } ) //"Pesquisa Docto."
AAdd(aBut, {"DEVOLNF" ,{|| T850Visual(aCols[n][1]+aCols[n][2]+aCols[n][3]) }, STR0092 , STR0091 } ) //"Visualiza Docto"

// Utilizada na rotina de ajustes e exlusoes de CTRC
aHeader := {}
For nI := 1 To Len(aCampos)
	If aCampos[nI][1] == "_SI_VALFAT"
		AAdd( aHeader, { STR0107 , "_SI_VALFAT"  , "@E 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor Faturado"
	Else
		nPos := aScan(aFldAll, {|x| AllTrim(x[2]) == aCampos[nI][1]})
		If nPos > 0
			aAdd(aHeader, {aFldAll[nPos][1], aFldAll[nPos][2], aFldAll[nPos][3], aFldAll[nPos][4], aFldAll[nPos][5], ".T", USADO, aFldAll[nPos][8], , "V"})
		EndIF
	EndIf
Next

AAdd( aHeader, { "", "", "", 1, 0, ".F.", USADO, "C",, "V" } )

DEFINE MSDIALOG oDlg TITLE STR0090 From 9,0 To 30,98 OF oMainWnd //"Consulta de Doctos Excluidos da Fatura"
oGet := MSGetDados():New(35,2,127,385,2,{|| .T. },,,.F.,{"DT6_FILDOC","DT6_DOC","DT6_SERIE"},,,99999)
oGet:oBrowse:lHScroll := .F.

// Exibe total cancelado
@ 130, 05 SAY STR0122 PIXEL OF oDlg FONT oBold //"Total de Exclusões"
@ 130, 90 MSGET nTotCanc SIZE 60, 9 OF oDlg PIXEL PICTURE "@E 9,999,999,999.99" WHEN .F. FONT oBold HASBUTTON

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End() },,aBut) CENTER

TRB->(DbCloseArea())
RestArea( aArea )

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³T850Visual  ³ Autor ³                       ³ Data ³ 19/01/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Visualiza Docto                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function T850Visual(cChave)

If IsInCallStack("TMSA510")
	Private aRotina := StaticCall(TMSA500,MenuDef)
EndIf

If DT6->(MsSeek(FWxFilial("DT6")+cChave))
	TmsA500Mnt('DT6', DT6->(Recno()), 2 )
EndIf

If IsInCallStack("TMSA510")
	aRotina := Nil
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa850Grv  ³ Autor ³ Claudio D. de Souza   ³ Data ³ 19/01/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Gera a Fatura                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA850Grv(lMostraGet, cCondicao, nMoedFat, aDoctos, dEmisFat,;
						dVencFat, cNumFat, cAliasTRB, cSerie, nValor, cNat,;
						nRecDT6, lFTPorDoc, lExecSched, dVencCond, oTempTable)

Local aVenc := {}
Local nDup  := 0
Local nOpca := 0
Local oGet
Local oDlg2
Local aFtGeradas := {}
Local aMsgFat    := {}
Local lTMSA491   := Upper(AllTrim(FunName())) == "TMSA491" .Or. Fwisincallstack("A491THREAD")
Local aTm850DtVe := {}


Local nI         := 0
Local lValida    := .T.

Default lMostraGet := .T.
Default cCondicao  := ''
Default nMoedFat   := 1
Default dEmisFat   := dDataBase
Default dVencFat   := Ctod("")
Default cNumFat    := ''
Default cAliasTRB  := ''
Default cSerie     := ''
Default cNat       := ''
Default nRecDT6    := 0
Default lExecSched := .F.  // indica execucao via schedule
Default dVencCond  := Ctod("")
Default oTempTable := {}

If Empty(oTempTable)
	If Empty(cCondicao)
		If Empty(dVencFat)
			cCondicao := If(Empty(SA1->A1_COND), Fa280PedCd(),SA1->A1_COND)	// Monta tela para pedir condicao de pgto, caso nao foi informada no cliente
			// Posiciona na condicao para obter a descricao na proxima tela
			SE4->(MsSeek(xFilial("SE4")+cCondicao))
			aVenc := Condicao(nValor,cCondicao,0,dEmisFat)
		Else
			cCondicao := If(Empty(SA1->A1_COND), "",SA1->A1_COND)	// Monta tela para pedir condicao de pgto, caso nao foi informada no cliente
			SE4->(MsSeek(FWxFilial("SE4")+cCondicao))
			If Empty(cCondicao)
			  aVenc := { { dVencFat, nValor } }
			Else
				If dVencCond == dVencFat
					aVenc := Condicao(nValor,cCondicao,0,dEmisFat)
				Else
					cCondicao := SA1->A1_COND
					aVenc := { { dVencFat, nValor } }
				EndIf	
			EndIf
		EndIf
	Else
		aVenc := Condicao(nValor,cCondicao,0, dEmisFat)
	EndIf
Else
	// Condição de pagamento para a pre-fatura
	aVenc := dtVencPfat(oTempTable, nValor, dEmisFat)
EndIf

// Ponto de entrada para alterar a(s) data(s) de vencimento(s).
If ExistBlock("TM850DTVE")
    aTm850DtVe := ExecBlock("TM850DTVE", .F., .F., {cCli, _cLoja, cCondicao, dEmisFat, aClone(aVenc)})
    If Len(aTm850DtVe) == Len(aVenc) //Verifica a se qtde de registros são iguais.
        For nI := 1 To Len(aVenc)
            If aTm850DtVe[nI][2] <> aVenc[nI][2] .OR. aTm850DtVe[nI][1] < dEmisFat //Verifica se não foi mudado o valor e a data vencimento é maior que a data de emissão.
                lValida := .F.
            EndIf
        Next
        If lValida
            aVenc := aTm850DtVe
        EndIf
    EndIf
EndIf

nDup  := Len(aVenc)
If nDup > 0 
	aCols := GravaDp(nDup,cPrefix,,nValor,dDatabase,aVenc,cTipo, "TMSA850")

	If lMostraGet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Mostra tela com os diversos titulos                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValTot := 0
		AEval(aCols,{|x|nValTot+=x[5]})

		DEFINE MSDIALOG oDlg2 TITLE STR0028	From 0,0 TO 300,680 OF oMainWnd PIXEL //"Dados Cont beis Financeiros"
			@ 040, 010 SAY STR0029 PIXEL //"Data Contabiliza‡„o : "
			@ 040, 065 SAY dDataBase FONT oDlg2:oFont PIXEL 
			@ 040, 100 SAY STR0030 PIXEL //"Condi‡„o de Pagamento : "
			@ 040, 165 SAY cCondicao + "-" + If(SE4->(!Eof()), SE4->E4_DESCRI, STR0082) PIXEL //"Não encontrada!"
			@ 040, 230 SAY STR0031 PIXEL //"Valor Total:"
			@ 040, 290 SAY oValTot VAR nValTot Picture "@E 9,999,999,999.99" FONT oDlg2:oFont PIXEL
		oGet := MSGetDados():New(54,5,128,340,1,"Fa280LinOk","Fa280TudOk","",.T.)
		ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{||nOpca:=1,if(oGet:TudoOk(),oDlg2:End(),nOpca := 0)},{||oDlg2:End()}) CENTERED
	Else
		nOpcA := 1
	EndIf

	If ExistBlock("TM850PXAL")
		cPrfx := ExecBlock("TM850PXAL",.F.,.F.) //PE para manipular o prefixo da fatura
		If !Empty(cPrfx) .And. ValType(cPrfx) == "C"
			cPrefix := cPrfx
		EndIf
	EndIf
Else
	nOpcA := 0
EndIf

If nOpcA == 1
	If lFTPorDoc
		Begin Transaction
			Processa( { || aFtGeradas := Tmsa850Grava(cPrefix,cTipo,aDoctos,nMoedFat,dEmisFat,cNumFat,cAliasTRB,cSerie,,cNat,@nRecDT6,lFTPorDoc,aVenc,!Empty(oTempTable))  }, STR0081 ) //"Gravando a fatura e atualizando Ctrcs..."
		End Transaction
		//--Exibe o resumo para o usuario
		//--**Fora da transacao:
		If Len( aFtGeradas ) > 0
			AaddMsgErr( aFtGeradas, @aMsgFat )
			If Len(aMsgFat) > 0 .And. lMostraGet
				TmsMsgErr( aMsgFat, STR0005 ) //"Faturas a Receber"
			EndIf
		EndIf
	Else
		If lExecSched
			BatchProcess(STR0081, STR0081 , "TMSA850GRV" , { || aFtGeradas := Tmsa850Grava(cPrefix,cTipo,aDoctos,nMoedFat,dEmisFat,cNumFat,cAliasTRB,cSerie,Iif( lTMSA491 , "TMSA491" , "TMSA850" ),cNat,@nRecDT6,lFTPorDoc, aVenc, !Empty(oTempTable)) } , { || .F. } )  // "Gravando a fatura e atualizando Ctrcs..." //Ajustado gravar E1_ORIGEM doc apoio
		Else
			Processa( { || aFtGeradas := Tmsa850Grava(cPrefix,cTipo,aDoctos,nMoedFat,dEmisFat,cNumFat,cAliasTRB,cSerie,;
						Iif( lTMSA491 , "TMSA491" , "TMSA850" ),cNat,@nRecDT6,lFTPorDoc, aVenc, !Empty(oTempTable)) }, STR0081 ) //"Gravando a fatura e atualizando Ctrcs..." 
						//-- Quando executada a rotina TMSA491, gravo no E1_ORIGEM "TMSA491"
		EndIf
	EndIf
EndIf

Return( aFtGeradas )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tm850ExcAg³ Autor ³ Claudio D. de Souza   ³ Data ³03.02.05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³apaga registros agregados ao SE1 no cancelamento da fatura  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tm850ExcAgre(cPrefixo, cNum, cParcela, cTipo)

Local cChave   := ""
Local aAreaSe1 := SE1->(GetArea())
Local aArea    := GetArea()

// Atualiza tambem os registros agregados
If !( cTipo $ MVRECANT+"/"+MV_CRNEG)
	DbSelectArea("SE1")
	DbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	MsSeek(cChave := FWxFilial("SE1") + cPrefixo+cNum+cParcela)
	While SE1->(!EOF()) .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA) == cChave
		If SE1->E1_TIPO $ MVABATIM +"/"+MVIRABT+"/"+MVINABT   // AB-/IR-/IN-
			RecLock("SE1" ,.F.)
			DbDelete()
			MsUnlock()
		EndIf
		SE1->(DbSkip())
	Enddo
Endif

SE1->(RestArea(aAreaSe1))
RestArea(aArea)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tms850Cli ³ Autor ³ Vitor Raspa           ³ Data ³07.04.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se existe definido no cadastro do cliente o        ³±±
±±³          ³   "Cliente Fatura"                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tms850Cli( cCliente, cLoja, cCliFat, cLojaFat, dVencFat, nValorFat, nMaxCtrc , lUsado, dVencCond )

Local lRet := .T.
Local cVar := ReadVar()

Local aPerfil := {}

Default cLoja := ''
Default lUsado:= .F.

If lUsado
	cCliFat := Posicione('SA1',1,xFilial('SA1')+cCliente+cLoja,'A1_CLIFAT')
Else
	cCliFat := cCliente
EndIf
If Empty(cCliFat)
	cCliFat := cCliente
EndIf
SA1->(DbSetOrder(1))
If mv_par01 == 1 //-- Considera Loja
	If SA1->(!MsSeek(FWxFilial('SA1')+cCliFat+AllTrim(cLoja)))
		SA1->(MsSeek(FWxFilial('SA1')+cCliFat))
	EndIf
	cLojaFat := SA1->A1_LOJA
Else
	SA1->(MsSeek(FWxFilial('SA1')+cCliFat))
	cLojaFat := SA1->A1_LOJA
EndIf

If cVar == "CCLI"
	If MV_PAR01 == 1
		lRet := TMA850Cli(cCliente,,,,,dEmisFat)
	Else
		lRet := TMA850Cli(cCliente,,@dVencFat,@nValorFat,@nMaxCtrc,dEmisFat)
	EndIf
	If Empty(_cLoja)
		_cLoja := cLojaFat
	EndIf
ElseIf cVar == "_CLOJA" .or. l850Auto  //Rotina automatica sempre considera loja
	lRet := TMA850Cli(cCliente,cLoja,@dVencFat,@nValorFat,@nMaxCtrc,dEmisFat)
EndIf

If lRet .And. (cVar $ "|CCLI|_CLOJA|") .And. !Empty(cCliente) .And. !Empty(cLoja)
	aPerfil := TmsPerfil(cCliente,cLoja,,.F.)
	If Len(aPerfil) >= 61 .And. ValType(aPerfil[61]) == "A" .And. Len(aPerfil[61]) >= 7 .And. aPerfil[61][1] == "1";
	   .And. ( !("TMSAE45" $ FunName()) .Or. !IsInCallStack("TMSAE45A"))

		Help(" ",1,"TMSA85028") //-- "Este cliente exige que a fatura seja proveniente de uma Pré-Fatura. Execute a rotina de pré-fatura!"
		lRet := .F.
	EndIf
EndIf
dVencCond := dVencFat // A variavel irá receber o data de vencimento informada apartir da condicao de pagamento informada no cliente, para depois ser comparada com a data digita
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Private aRotina := {	{ STR0001,"AxPesqui"   , 0 , 1 ,0,.F.},; //"Pesquisar"
						{ STR0002,"Tmsa850Vis" , 0 , 2 ,0,NIL},; //"Visualizar"
						{ STR0003,"Tmsa850Aut" , 0 , 3 ,0,NIL},; //"Selecionar"
						{ STR0004,"Tmsa850Exc" , 0 , 5 ,0,NIL},; //"Cancelar"
						{ STR0072,"Tmsa850Leg" , 0 , 6 ,0,.F.} } //"Legenda"						
						
If FindFunction("TmsA491Imp")
	aAdd(aRotina,{ STR0152,"TmsA491Imp" , 0, 8,0,NIL }) //Impressão Fatura
EndIf

//-- Rotina comentada pois esta opção não será expedida na versão 12.1.23
//If FindFunction("Tmsa854")
//	aAdd(aRotina,{ STR0165,"VIEWDEF.TMSA854" , 0, 3,0,NIL }) //"Fatura Cod. Barras"
//EndIf

If ExistBlock("TM850MNU")
	ExecBlock("TM850MNU",.F.,.F.)
EndIf

Return( aRotina )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tm850RecAct  ³ Autor ³ Andre Sperandio      ³ Data ³ 05/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao responsavel por armazenar a numero do RECNO referente ³±±
±±³          ³ ao CTRC gerado pelos Documentos de Apoio.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tm850RecAct(cFilDoc, cDoc, cSerie)
Local cAliasNew := GetNextAlias()
Local cQuery    := ""
Local aInfVis   := Tmsa850Erp()
Local aLstDoctos:= {}

cQuery := " SELECT DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE"
cQuery += " FROM " + RetSqlName("DT6") + " DT6 "
cQuery += " WHERE DT6_FILIAL ='" + FWxFilial("DT6") + "' "
cQuery += "   AND DT6_CLIDEV ='" + PadR(aInfVis[E1CLIENTE], Len(aInfVis[E1CLIENTE])) + "' "
cQuery += "   AND DT6_LOJDEV ='" + PadR(aInfVis[E1LOJA]   , Len(aInfVis[E1LOJA]))    + "' "
cQuery += "   AND DT6_PREFIX ='" + PadR(aInfVis[E1PREFIXO], Len(aInfVis[E1PREFIXO])) + "' "
cQuery += "   AND DT6_NUM    ='" + PadR(aInfVis[E1NUM]    , Len(aInfVis[E1NUM]))     + "' "
cQuery += "   AND DT6_TIPO   ='" + PadR(aInfVis[E1TIPO]   , Len(aInfVis[E1TIPO]))    + "' "
cQuery += "   AND DT6_DOCTMS NOT IN('B','C','H','I','N','O') "
cQuery += "   AND DT6.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

	While (cAliasNew)->(!Eof())
		cFilDoc := (cAliasNew)->DT6_FILDOC
		cDoc    := (cAliasNew)->DT6_DOC
		cSerie  := (cAliasNew)->DT6_SERIE

		Aadd(aLstDoctos,{cFilDoc,cDoc,cSerie})

		(cAliasNew)->(DbSkip())
	EndDo


(cAliasNew)->(DbCloseArea())

Return aLstDoctos

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA850Ini
Monta a tela inicial da opcao Selecionar, utilizada no TMSA850 e TMSA851
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [cPrefix], Caracter, Prefixo
@param [lPrefix], Lógico, Habilita prefixo?
@param [cTipo], Caracter, Tipo fatura
@param [cNat], Caracter, Natureza fatura
@param [cVar], Caracter, Moeda selecionada
@param [dEmisFat], Data, Data de emissão
@param [cCli], Caracter, Cliente
@param [_cLoja	], Caracter, Loja
@param [dVencFat], Data, Vencimento
@param [lFatVazia], Lógico, Fatura vazia?
@param [lMrkDoc], Lógico, Marca documentos?
@param [dDataDe], Data, Data inicial seleção documentos
@param [dDataAte], Data, Data final seleção documentos
@param [nValorFat], Numérico, Valor da fatura
@param [cCliFat], Caracter, Cliente fatura (quando utiliza A1_CLIFAT)
@param [cLojaFat], Caracter, Loja cliente fatura (quando utiliza A1_CLIFAT)
@param [nMaxCtrc], Numérico, Quantidade máxima de documentos
@param [lUsado	], Lógico, Utiliza A1_CLIFAT?
@param [cFilDeb], Caracter, Filial de debito
@param [nMinCtrc], Numérico, Valor mínimo do documento
@param [aChaveLbn], Matriz, Chave fatura
@param [nOpca]	, Numérico, Opção selecionada pelo usuário
@return Nil Não há retorno
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA850Ini(cPrefix		, lPrefix	, cTipo   	, cNat     , cVar   , dEmisFat, cCli    , _cLoja, dVencFat, lFatVazia,;
                    lMrkDoc		, dDataDe	, dDataAte	, nValorFat, cCliFat, cLojaFat, nMaxCtrc, lUsado, cFilDeb , nMinCtrc ,;
					aChaveLbn	, nOpca		, dVencCond	, nOpc)

Local cTmsERP   := SuperGetMV("MV_TMSERP",,'0')
Local aMoedas   := {}
Local aPosObj   := {}
Local cPictPref := ""
Local nQtdMoedas:= 0
Local nTotMoedas:= 0

Local oDlg
Local oChkFatVz
Local oChkMrkDoc
Local oCbx


Default nOpc := 3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura aTxMoedas         ³
//³ [1] -> Nome Moeda          	³
//³ [2] -> Taxa a Ser Utilizada	³
//³ [3] -> Picture          	³
//³ [4] -> Taxa do dia atual    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
nTotMoedas := MoedFin()
For nQtdMoedas := 1	To nTotMoedas
	cMoedaTx :=	Str(nQtdMoedas,IIf(nQtdMoedas <= 9,1,2))
	AAdd( aMoedas, StrZero(Val(cMoedaTx),2) + " " + SuperGetMv("MV_MOEDA"+cMoedaTx) )
Next


ASort(aMoedas)
cVar := aMoedas[1]

If cTmsERP ==  '0' //-- ERP Protheus
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa picture E1_PREFIXO                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPictPref := GetSX3Cache("E1_PREFIXO", "X3_PICTURE")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Matriz com posicoes de objetos que ficam diferentes quando ha integracao ERP Datasul ³
//³ aPosObj[Obj][1] = Linha                                                              ³ 
//³ aPosObj[Obj][2] = Coluna                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
Case (cTmsERP ==  '1') //-- ERP Datasul)	
	Aadd(aPosObj, {008, 010}) //-- [1] - Label Moeda
	Aadd(aPosObj, {018, 010}) //-- [2] - Moeda
	Aadd(aPosObj, {008, 059}) //-- [3] - Label Emissao
	Aadd(aPosObj, {018, 059}) //-- [4] - Emissao
OtherWise //-- ERP Protheus)
	Aadd(aPosObj, {008, 123}) //-- [1] - Label Moeda
	Aadd(aPosObj, {018, 123}) //-- [2] - Moeda
	Aadd(aPosObj, {008, 172}) //-- [3] - Label Emissao
	Aadd(aPosObj, {018, 172}) //-- [4] - Emissao
EndCase

DEFINE MSDIALOG oDlg FROM 22,9 TO 317,540 TITLE STR0009 PIXEL // "Faturas a Receber"

@ 004, 004 TO 036, 226 OF oDlg PIXEL

If cTmsERP ==  '0' //-- ERP Protheus
	@ 008, 010 SAY STR0010 OF oDlg PIXEL //"Prefixo"
	@ 018, 010	MSGET cPrefix PICTURE cPictPref WHEN lPrefix SIZE 10, 11 OF oDlg PIXEL
	
	@ 008, 034 SAY STR0054 OF oDlg PIXEL //"Tipo"
	@ 018, 034	MSGET cTipo F3 "05" PICTURE "@!" VALID (!Empty(cTipo) .And. FA280Tipo(@cTipo)) SIZE 10, 11 OF oDlg PIXEL HASBUTTON
	
	@ 008, 069 SAY STR0012 OF oDlg PIXEL //"Natureza"
	@ 018, 069	MSGET cNat F3 "SED" PICTURE "@!" VALID Fa280Nat(cNat) SIZE 55, 11 OF oDlg PIXEL HASBUTTON
EndIf

@ aPosObj[1][1], aPosObj[1][2] SAY STR0013 OF oDlg PIXEL //"Moeda"
@ aPosObj[2][1], aPosObj[2][2] COMBOBOX oCbx VAR cVar ITEMS aMoedas SIZE 46, 14 OF oDlg PIXEL

@ aPosObj[3][1], aPosObj[3][2] SAY STR0058 OF oDlg PIXEL //"Emissao da Fatura"
@ aPosObj[4][1], aPosObj[4][2]	MSGET dEmisFat VALID Tmsa850VEmis(dEmisFat,cCli,_cLoja,@dVencFat) WHEN nOpc <> 4 SIZE 50, 11 OF oDlg PIXEL HASBUTTON

@ 038, 004 CHECKBOX oChkFatVz  VAR lFatVazia PROMPT STR0094 SIZE 90,9 OF oDlg PIXEL //"Deseja iniciar fatura em branco"
@ 038, 100 CHECKBOX oChkMrkDoc VAR lMrkDoc   PROMPT STR0149 SIZE 90,9 OF oDlg PIXEL //"Trazer Documentos Marcados?"

@ 048, 004 TO 080, 226 OF oDlg PIXEL

@ 052, 010 SAY STR0014 OF oDlg PIXEL //"Emissao de"
@ 062, 010	MSGET dDataDe WHEN !lFatVazia VALID Tmsa850Ddat(dDataDe,dDataAte) SIZE 50, 11 OF oDlg PIXEL HASBUTTON

@ 052, 063 SAY STR0015 OF oDlg PIXEL //"At‚"
@ 062, 063	MSGET dDataAte WHEN !lFatVazia VALID Tmsa850Ddat(dDataDe,dDataAte) SIZE 50, 11 OF oDlg PIXEL HASBUTTON

@ 052, 116 SAY STR0095 OF oDlg PIXEL //"Valor maximo da Fatura (0=Sem limite)"
@ 062, 116	MSGET nValorFat PICTURE "@E 9,999,999,999.99" SIZE 65, 11 OF oDlg PIXEL HASBUTTON

@ 085, 004 TO 143, 226 OF oDlg PIXEL

@ 089, 010 SAY STR0017 OF oDlg PIXEL //"Cliente"
@ 099, 010	MSGET cCli F3 "SA1"	VALID Tms850Cli(cCli,_cLoja,@cCliFat,@cLojaFat,@dVencFat,@nValorFat,@nMaxCtrc,lUsado,@dVencCond) WHEN nOpc <> 4 SIZE 65, 11 OF oDlg PIXEL HASBUTTON 

@ 089, 078 SAY STR0018 OF oDlg PIXEL //"Loja"
@ 099, 078	MSGET _cLoja PICTURE "@!" VALID TMS850Cli(cCli,_cLoja,@cCliFat,@cLojaFat,@dVencFat,@nValorFat,@nMaxCtrc,lUsado,@dVencCond) WHEN MV_PAR01 == 1 .And. nOpc <> 4 SIZE 21, 11 OF oDlg PIXEL

If lUsado
	@ 089, 103 SAY STR0019 OF oDlg PIXEL //"Cliente a Faturar"
	@ 099, 103 MSGET cCliFat  F3 "SA1"		VALID TMA850Cli(cCliFat)            SIZE 70, 11 OF oDlg PIXEL HASBUTTON
	@ 099, 176 MSGET cLojaFat PICTURE "@!"	VALID TMA850Cli(cCliFat, cLojaFat ) SIZE 21, 11 OF oDlg PIXEL
EndIf

@ 118, 010 SAY STR0096 OF oDlg PIXEL //"Filial de Debito"
@ 125, 010 MSGET cFilDeb  F3 "SM0" VALID !Empty(cFilDeb) WHEN nOpc <> 4  SIZE 35, 11 OF oDlg PIXEL HASBUTTON

@ 118, 058 SAY STR0097 OF oDlg PIXEL //"Vencto. da fatura"
@ 125, 058 MSGET dVencFat SIZE 50, 11 OF oDlg PIXEL VALID Tmsa850Venc(dEmisFat,cCli,_cLoja,@dVencFat) HASBUTTON

@ 118, 108 SAY STR0098 OF oDlg PIXEL //"Qtde. Max. CTRC"
@ 125, 108 MSGET nMaxCtrc SIZE 42, 11 OF oDlg PIXEL PICTURE "@E 99,999,999"

@ 118, 153 SAY STR0099 OF oDlg PIXEL //"Vlr Min. CTRC"
@ 125, 153 MSGET nMinCtrc SIZE 65, 11 OF oDlg PIXEL PICTURE "@E 9,999,999,999.99" HASBUTTON

DEFINE SBUTTON FROM 07, 230 TYPE 1 ACTION (nOpca:=1,IF(Fa280Ok(oDlg) .And. Tms850Ok(cFilDeb, cCli, _cLoja, @aChaveLbn, @dVencFat, dVencCond,dEmisFat),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
DEFINE SBUTTON FROM 24, 230 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA850Doc
Retorna documentos (conhecimentos) que estarão disponíveis para seleção na fatura
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [aCampos], Matriz, Campos
@param [cCli], Caracter, Cliente da fatura
@param [_cLoja], Caracter, Loja do cliente da fatura
@param [dDataDe], Data, Data inicial seleção documentos
@param [dDataAte], Data, Data final seleção documentos
@param [cFilDeb], Caracter, Filial de débito da fatura
@param [nMoedFat], Numérico, Moeda da fatura
@param [nMinCtrc], Numérico, Valor mínimo do documento
@param [cNUmFat], Numérico, Valor mínimo do documento
@return aDoctos Documentos para seleção
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA850Doc(aCampos, cCli, _cLoja, dDataDe, dDataAte, cFilDeb, nMoedFat, nMinCtrc, cNumFat, oTempTable, cCliDev, cLojDev, cNumPre, aMsgErr)

Local cQuery  := ""
Local aDoctos := {}
Local aPerfil := {}
Local aStru   := DT6->(DbStruct())

Default __lTMSCTe  := SuperGetMv( "MV_TMSCTE", .F., .F. ) //-- Parametro do CT-e ativo.
Default cNumFat    := Space(Len(DT6->DT6_NUM))
Default oTempTable := {}
Default cCliDev    := Space(Len(DT6->DT6_CLIDEV))
Default cLojDev    := Space(Len(DT6->DT6_LOJDEV))
Default cNumPre    := Space(Len(DEB->DEB_NUMPRE))
Default aMsgErr    := {}

Pergunte("TMA850",.F.)

// Adiciona os campos que existirem no DT6 na matriz de campos a serem selecionados
aEval(aCampos,{|e| If(DT6->(FieldPos(e[1])) > 0, cQuery += ","+AllTrim(e[1]), Nil)})
cQuery := "SELECT "+SubStr(cQuery,2)
cQuery +=       ","+"DT6_VALFAT "
cQuery +=       ","+"DT6.R_E_C_N_O_ RECNO "
cQuery +=       ","+"DUY.DUY_EST UFDEST "
cQuery +=       ","+"F2_TIPO "
cQuery += "     FROM "+RetSqlName("DT6")+" DT6 "
cQuery += "LEFT JOIN "+RetSqlName("DUY")+" DUY "
cQuery += "  ON DUY.DUY_FILIAL = '"+FWxFilial("DUY")+"'"
cQuery += " AND DUY.DUY_GRPVEN = DT6.DT6_CDRDES"
cQuery += " AND DUY.D_E_L_E_T_ = ' ' "
If __lTMSCTe
	cQuery += "LEFT JOIN "+RetSqlName("DTP")+" DTP "
	cQuery += "  ON DTP.DTP_FILORI = DT6.DT6_FILDOC "
	cQuery += " AND DTP.DTP_LOTNFC = DT6.DT6_LOTNFC "
	cQuery += " AND DTP.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " JOIN "+RetSqlName("DUI")+ " DUI "
cQuery += "   ON " + TmQryFilial( "DUI" /*cAlias*/, "DUI.DUI_FILIAL"/*cCpoFilial*/, "DT6.DT6_FILDOC"/*cCpoFilOri*/)

cQuery += " AND DUI.DUI_DOCTMS = DT6_DOCTMS "
cQuery += " AND DUI_DOCFAT     = ' ' "
cQuery += " AND DUI.D_E_L_E_T_ = ' ' "
cQuery += "     JOIN "+RetSqlName("SF2")+ " SF2 "
cQuery += "       ON " + TmQryFilial( "SF2" /*cAlias*/, "SF2.F2_FILIAL"/*cCpoFilial*/, "DT6.DT6_FILDOC"/*cCpoFilOri*/)

cQuery += " AND SF2.F2_DOC     	= DT6.DT6_DOC"
cQuery += " AND SF2.F2_SERIE   	= DT6.DT6_SERIE"
cQuery += " AND SF2.D_E_L_E_T_ 	= ' ' "
If Empty(cNumFat)
	cQuery += " WHERE (DT6.DT6_FILIAL 	= '"+FWxFilial("DT6") + "'"
Else
	cQuery += "WHERE DT6.DT6_NUM   	= '"+cNumFat + "'"
	cQuery += " OR (DT6.DT6_FILIAL 	= '"+xFilial("DT6") + "'"
EndIf

cQuery += " AND DT6.DT6_CLIDEV	= '"+cCli+"'"
If mv_par01 == 1
	cQuery += " AND DT6.DT6_LOJDEV = '"+_cLoja+"'"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso cliente utilize comprovante de entrega, ira gerar fatura apenas  ³
//³ para documentos que tiverem comprovantes de entrega.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPerfil := TmsPerfil(cCli,_cLoja,,.F.)
If aPerfil[8] == '1'
	cQuery += " AND DT6.DT6_LOTCET <> ''"
EndIf
cQuery += " AND DT6.DT6_PREFIX  ='"+Space(Len(DT6->DT6_PREFIX))+"'"
If Empty(cNumFat)
	cQuery += " AND DT6.DT6_NUM ='"+Space(Len(DT6->DT6_NUM))+"'"
Else
	cQuery += " AND DT6.DT6_NUM     IN ('"+Space(Len(DT6->DT6_NUM)) +"','" + cNumFat + "')" + ""
EndIf	
cQuery += " AND DT6.DT6_TIPO    ='"+Space(Len(DT6->DT6_TIPO))+"'"
cQuery += " AND DT6.DT6_DATEMI >='"+DTOS(dDataDe) +"'"
cQuery += " AND DT6.DT6_DATEMI <='"+DTOS(dDataAte)+"'"
cQuery += " AND DT6.DT6_FILDEB  ='"+cFilDeb+"'"
cQuery += " AND DT6.DT6_MOEDA   = "+AllTrim(Str(nMoedFat,2,0))
cQuery += " AND DT6.DT6_VALFAT+DT6.DT6_ACRESC-DT6.DT6_DECRES >= "+AllTrim(Str(nMinCtrc,15,2))
// Fatura apenas documentos validos de transporte
cQuery += " AND DT6.DT6_DOCTMS NOT IN ( '1', 'A', 'K' )"    //('K'= Carregamento em Partes do Internacional)
cQuery += " AND DT6.DT6_SERIE <> 'PED'"
If __lTMSCTe // AUTORIZADO O USO DO CTE DT6_SITCTE = '2'
	cQuery += " AND ((DT6.DT6_SITCTE = ' ' AND DTP.DTP_TIPLOT = '1') OR "
	cQuery += "      (DT6.DT6_SITCTE = '0' AND DTP.DTP_TIPLOT = '1') OR "
	cQuery += "      (DT6.DT6_SITCTE = '1' AND DTP.DTP_TIPLOT = '3') OR "
	cQuery += "      (DT6.DT6_SITCTE = '2' AND DTP.DTP_TIPLOT = '3') OR "
	cQuery += "      (DT6.DT6_SITCTE = '4' AND DTP.DTP_TIPLOT = '3') OR "
	cQuery += "      (DTP.DTP_TIPLOT = '3' AND DT6.DT6_DOCTMS = '" + StrZero( 5, Len( DT6->DT6_DOCTMS ) ) + "') OR "    //--Nota Fiscal de Serv. de Transp.
	cQuery += "      (DTP.DTP_TIPLOT = '3' AND DT6.DT6_DOCTMS = '" + Replicate('D', Len( DT6->DT6_DOCTMS ) ) + "') OR " //--Nota Fiscal de Reentrega
	cQuery += "      (DTP.DTP_TIPLOT = '3' AND DT6.DT6_DOCTMS = '" + Replicate('F', Len( DT6->DT6_DOCTMS ) ) + "') OR " //--Nota Fiscal de Armazenagem
	cQuery += "      (DTP.DTP_TIPLOT = '3' AND DT6.DT6_DOCTMS = '" + Replicate('G', Len( DT6->DT6_DOCTMS ) ) + "') OR "   //--Nota Fiscal de Complemento
	cQuery += "      (DT6.DT6_SITCTE = '2' AND DTP.DTP_TIPLOT = '4') OR "
	cQuery += "      (DT6.DT6_SITCTE = '4' AND DTP.DTP_TIPLOT = '4')) "
EndIf // ((AUTORIZADO O USO DO CTE e Lote Eletronico) ou (CTRC antigos e Lote Normal))
// Nao permite FATURAR ctrc que tenham solicitacoes de transferencias em aberto.
cQuery += " AND DT6.DT6_NUMSOL = ' '"
cQuery += " AND DT6.DT6_STATUS NOT IN ('9','B','C','D')"
If	lTMFATFIL
	cQuery += ExecBlock("TMFATFIL",.F.,.F., {cQuery, .T.})
EndIf
cQuery += " AND DT6.D_E_L_E_T_ = ' ')"

//-- Condição usada na pré fatura
If !Empty(oTempTable)
	cQuery += " AND EXISTS (SELECT 1 "
	cQuery += "               FROM " + oTempTable:GetRealName() + " "
	cQuery += "              WHERE TRB_CLIDEV = '" + cCliDev + "' "
	cQuery += "                AND TRB_LOJDEV = '" + cLojDev + "' "
	cQuery += "                AND TRB_NUMPRE = '" + cNumPre + "' "
	cQuery += "                AND TRB_FILDOC = DT6_FILDOC "
	cQuery += "                AND TRB_DOC    = DT6_DOC "
	cQuery += "                AND TRB_SERIE  = DT6_SERIE) "
EndIf

If !Empty(cNumFat)
	cQuery += " ORDER BY  DT6_NUM " + " DESC "
Else	
	cQuery += " ORDER BY " + SqlOrder(DT6->(IndexKey(1))+"+RECNO") 
EndIf

AAdd(aStru, {"RECNO","N",10,0})
Processa({|| Tms850QryToMem(cQuery, aStru, aCampos, @aDoctos, oTempTable, cCliDev, cLojDev, cNumPre, @aMsgErr )}) // Cria arquivo temporario

Return aDoctos

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa850Erp
Conforme parametro MV_TMSERP, define se as informacoes do vetor aInfVis serao do financeiro Protheus ou financeiro Datasul
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@return aInfVis Array com informações da fatura
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa850Erp()

Local cTmsERP := SuperGetMV("MV_TMSERP",,'0')
Local aInfVis := {}

Do Case
Case (cTmsERP == '1') //-- ERP Datasul

	Aadd(aInfVis, Space(TamSX3("E1_PREFIXO")[2])) //-- [E1PREFIXO] [01] Prefixo da fatura
	Aadd(aInfVis, DRT->DRT_NUM)                   //-- [E1NUM]     [02] Numero da fatura
	Aadd(aInfVis, Space(TamSX3("E1_TIPO")[2]))    //-- [E1TIPO]    [03] Tipo da fatura
	Aadd(aInfVis, DRT->DRT_DOC)                   //-- [E1NUMNOTA] [04] Numero nota documento de apoio
	Aadd(aInfVis, DRT->DRT_SERIE)                 //-- [E1SERIE]   [05] Serie nota documento de apoio
	Aadd(aInfVis, DRT->DRT_CLIFAT)                //-- [E1CLIENTE] [06] Cliente da fatura
	Aadd(aInfVis, DRT->DRT_LOJFAT)                //-- [E1LOJA]    [07] Loja do cliente da fatura
	Aadd(aInfVis, DRT->DRT_VALOR)                 //-- [E1VALOR]   [08] Valor da fatura
	Aadd(aInfVis, 0)              				  //-- [E1DECRESC] [09] Valor descrescimo da fatura ---não carregado o desconto devido o drt_valor já está com o desconto aplicado
	Aadd(aInfVis, Space(TamSX3("E1_NATUREZ")[2])) //-- [E1NATUREZ] [10] Natureza da fatura
	Aadd(aInfVis, DRT->DRT_MOEDA)                 //-- [E1MOEDA]   [11] Moeda da fatura
	Aadd(aInfVis, DRT->DRT_FILDEB)                //-- [E1FILDEB]  [12] Filial debito da fatura
	
Case (cTmsERP == '0') //-- ERP Protheus

	Aadd(aInfVis, SE1->E1_PREFIXO)                //-- [E1PREFIXO] [01] Prefixo da fatura
	Aadd(aInfVis, SE1->E1_NUM)                    //-- [E1NUM]     [02] Numero da fatura
	Aadd(aInfVis, SE1->E1_TIPO)                   //-- [E1TIPO]    [03] Tipo da fatura
	Aadd(aInfVis, SE1->E1_NUMNOTA)                //-- [E1NUMNOTA] [04] Numero nota documento de apoio
	Aadd(aInfVis, SE1->E1_SERIE)                  //-- [E1SERIE]   [05] Serie nota documento de apoio
	Aadd(aInfVis, SE1->E1_CLIENTE)                //-- [E1CLIENTE] [06] Cliente da fatura
	Aadd(aInfVis, SE1->E1_LOJA)                   //-- [E1LOJA]		[07] Loja do cliente da fatura
	Aadd(aInfVis, SE1->E1_VALOR)                  //-- [E1VALOR]   [08] Valor da fatura
	Aadd(aInfVis, SE1->E1_DECRESC)                //-- [E1DECRESC]	[09] Valor descrescimo da fatura
	Aadd(aInfVis, SE1->E1_NATUREZ)                //-- [E1NATUREZ]	[10] Natureza da fatura
	Aadd(aInfVis, SE1->E1_MOEDA)                  //-- [E1MOEDA]   [11] Moeda da fatura
	Aadd(aInfVis, SE1->E1_FILDEB)                 //-- [E1FILDEB]  [12] Filial debito da fatura
	
EndCase

Return aInfVis

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tms850Save
Quando for inclusão (Selecionar), após clicar no botão OK, esta função realiza a chamada da função
para geração da fatura e caso ocorra algum erro, volta a apresentar a tela de selação de conhecimentos.
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [aFtGeradas], Array, Fatura gerada
@param [nMoedFat], Numérico, Moeda
@param [aDoctos], Array, Documentos selecionados
@param [dEmisFat], Data, Data de emissão
@param [dVencFat], Data, Data de vencimento
@param [nValor], Numérico, Valor total da fatura
@param [cNat], Caracter, Natureza
@param [dVencCond], Data, Data vencimento condição de cobrança
@return lRet Lógico Retorna se o processamento ocorreu com sucesso ou não
/*/
//-------------------------------------------------------------------------------------------------
Static Function Tms850Save(aFtGeradas, nMoedFat, aDoctos, dEmisFat, dVencFat, nValor, cNat, dVencCond, nOPC, lMostra, oTempTable)

Local lRet    := .F.
Local cTmsERP := SuperGetMV("MV_TMSERP",,'0')
Local lMV_TMSFMSG := SuperGetMv("MV_TMSFMSG",.F.,.T.)

Default aFtGeradas 	:= {}
Default nOpc		:= 3
Default lMostra     := .T.
Default oTempTable  := {}

Do Case
Case (cTmsERP == '1') //-- ERP Datasul
	aFtGeradas := Tmsa851Grv(.T., nMoedFat, aDoctos, dEmisFat, dVencFat, nValor, /*cAliasTRB*/, /*cSerie*/, /*nRecDT6*/, .T., /*lExecSched*/, , nOpc)
Case (cTmsERP == '0') //-- ERP Protheus
	aFtGeradas := TMSA850Grv(Iif(lMostra,.T.,.F.),'',nMoedFat, aDoctos, dEmisFat, dVencFat,,,,nValor,cNat,/*nRecDT6*/,.T. /*lFTPorDoc*/,/*lExecSched*/,dVencCond,oTempTable)
EndCase

If ! Empty(aFtGeradas) .And. Len(aFtGeradas) > 0 .Or. !lMV_TMSFMSG
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T850MrkDoc
Efetua a marcação dos documentos conforme Docto. Transp (DOCTMS)
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 06/03/2017
@param [oLbxDocto], Objeto, Tela marcação de documentos
@param [aDoctos], Array, Documentos selecionados
@param [oMark], Objeto, Objeto de marcação
@param [nValFat], Numérico, Valor Fatura
@param [nQtdCTRC], Numérico, Quantidade CTRC
@param [aVFContr], Array, Valor Contrato
@param [lExclui], Lógico, Exclui?
@param [nTotExcluido], Numérico, Total excluído
@return lRet Lógico True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function T850MrkDoc(oObj, aDoctos, oMark, nValFat, nQtdCTRC, aVFContr, lExclui, nTotExcluido)

	Local lRet       := .T.
	Local lSrvAdd    := .F.
	Local cTitDocTms := ""
	Local cF3DocTms  := ""
	Local cItFilDoc  := ""
	Local cItDoc     := ""
	Local cItSerie   := ""
	Local cItDocTms  := ""
	Local cDocTms    := Space(Len(DC5->DC5_DOCTMS))
	Local nOpca      := 0
	Local nCntFor1   := 0
	Local oChkSrvAdd
	Local oDlgMrkDoc

	cTitDocTms := GetSX3Cache("DC5_DOCTMS", "X3_TITULO")
	cF3DocTms := GetSX3Cache("DC5_DOCTMS", "X3_F3")

	DEFINE MSDIALOG oDlgMrkDoc TITLE STR0153 From 9,0 To 16,75 OF oMainWnd //STR0153 'Marcar por Doc.Transp.'
	@  35,    5 Say   cTitDocTms OF oDlgMrkDoc PIXEL SIZE 40,9
	@  35,   45 MSGET cDocTms    OF oDlgMrkDoc PIXEL PICTURE "@!" F3 cF3DocTms HASBUTTON
	@  38,   85 CHECKBOX oChkSrvAdd VAR lSrvAdd PROMPT STR0154 OF oDlgMrkDoc SIZE 150,9 WHEN cDocTms == '5' PIXEL //STR0154 "Docto. Serv. Adic."
	ACTIVATE MSDIALOG oDlgMrkDoc ON INIT EnchoiceBar(oDlgMrkDoc, {|| nOpca:= 1, oDlgMrkDoc:End()}, {|| nOpca := 0, oDlgMrkDoc:End()}) CENTER

	If nOpca == 1

		dbSelectArea("DT6")
		DT6->(dbSetOrder(1))
		For nCntFor1 := 1 To Len(aDoctos)

			cItFilDoc  := aDoctos[nCntFor1, FILDOC]
			cItDoc     := aDoctos[nCntFor1, CTRC]
			cItSerie   := aDoctos[nCntFor1, SERIE]

			//-- Obtem tipo do documento de transporte
			If DT6->(MsSeek(FWxFilial("DT6") + cItFilDoc + cItDoc + cItSerie))
				cItDocTms := DT6->DT6_DOCTMS
			EndIf

			If ! aDoctos[nCntFor1, MARCA] .And. cItDocTms == cDocTms
				If (cDocTms != StrZero(5, Len(DC5->DC5_DOCTMS)))                 .Or. ;
				   (cDocTms == StrZero(5, Len(DC5->DC5_DOCTMS)) .And. ! lSrvAdd) .Or. ;
				   (cDocTms == StrZero(5, Len(DC5->DC5_DOCTMS)) .And. lSrvAdd    .And.;
				   FindFunction("TMSA853DSa")                                    .And.; 
				   TMSA853DSa(cItFilDoc, cItDoc, cItSerie, cItDocTms))

					oObj:nAt := nCntFor1
					oObj:Refresh(.T.)
					TMSA850Inv(1, aDoctos, oLbxDocto, oMark,,,,,@nValFat, @nQtdCTRC, aVFContr, lExclui, @nTotExcluido)

				EndIf
			EndIf
		Next nCntFor1
	EndIf
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA850Vld
Validação da Manutenção da Fatura (Alteração/Cancelamento)
@type function
@author Katia Tiemi
@version 12
@since 08/01/2018
@return Logico (T ou F)
/*/
//-------------------------------------------------------------------------------------------------

Function TMSA850Vld(nOpcx,lAnulacao,lExbHlp,aVetPre,nLinha,aMsgErr)
Local aArea		:= GetArea()
Local aAreaDRT	:= DRT->(GetArea())
Local aAreaSE1	:= SE1->(GetArea())
Local aAreaSA1  := SA1->(GetArea())
Local dDataFIN	:= SuperGetMV("MV_DATAFIN",.F.,CtoD(""))
Local lRet			:= .T.
Local cTmsERP		:= SuperGetMV("MV_TMSERP",,'0')
Local lFatApoio	:= .F.
Local cQuery		:= ""
Local cAliasDRT	:= ""
Local aInfVis		:= {}

Local cDocto := ""

Default lAnulacao := .F.
Default lExbHlp   := .T.
Default aVetPre   := {}
Default nLinha    := 0
Default aMsgErr   := {}

If !Empty(aVetPre) .And. nLinha > 0
	cDocto := Posicione("SA1",3,xFilial("SA1") + aVetPre[nLinha,1],"A1_COD") + "-" + SA1->A1_LOJA + "-" + SA1->A1_NOME + " / " + ;
			  aVetPre[nLinha,2] + " / " + ;
			  aVetPre[nLinha,3] + "-" + aVetPre[nLinha,4] + "-" + aVetPre[nLinha,5]
EndIf

Do Case
Case (cTmsERP == '1') //-- ERP Datasul

	Do Case
	   	Case (DRT->DRT_STATUS == "3" .Or. DRT->DRT_STATUS == "4")
	   		If nOpcx <> 4
				If lExbHlp
	  				Help(" ", 1, "TMSA85025") //-- "Cancelamento nao permitido! Existe um ou mais movimentos de baixa para os titulos da fatura."
				Else
					If !Empty(cDocto)
						AAdd(aMsgErr,{cDocto,'00',''})
						cDocto := ""
					EndIf
					AAdd(aMsgErr,{STR0166,'00',''})
				EndIf
	   		Else
		   		If lExbHlp
		   			Help(Nil, 1,'HELP',Nil, STR0155 + Chr(13) + Chr(10) + STR0156 , 1, 0)  //-- "Manutenção de Fatura nao permitido! Existe um ou mais movimentos de baixa para os titulos da fatura.
				Else
					If !Empty(cDocto)
						AAdd(aMsgErr,{cDocto,'00',''})
						cDocto := ""
					EndIf
					AAdd(aMsgErr,{STR0167,'00',''})
				EndIf
	   		EndIf	
			lRet:= .F.
		Case (DRT->DRT_STATUS == "5")
			If lExbHlp
				Help(" ", 1, "TMSA85013") //-- "Esta fatura ja foi cancelada"
			Else
				If !Empty(cDocto)
					AAdd(aMsgErr,{cDocto,'00',''})
					cDocto := ""
				EndIf
				AAdd(aMsgErr,{STR0168,'00',''})
			EndIf
			lRet:= .F.
	EndCase

OtherWise //-- ERP Protheus

	//-- Verifica se a fatura foi gerada pelo modulo SIGATMS.
	If SE1->E1_SITFAT = "2" .And. ! ChkPsw(104)
		lRet:= .F.
	EndIf
	
	If SE1->E1_SITFAT = "3" // Fatura Cancelada
		If lExbHlp
			Help(" ",1,"TMSA85013") //"Esta fatura já foi cancelada"
		Else
			If !Empty(cDocto)
				AAdd(aMsgErr,{cDocto,'00',''})
				cDocto := ""
			EndIf
			AAdd(aMsgErr,{STR0168,'00',''})
		EndIf
		lRet:= .F.
	Endif
	
	If Empty(SE1->E1_SALDO) // Fatura Baixada
		If nOpcx <> 4
			If lExbHlp
				Help(" ",1,"TMSA85014") //"Esta fatura já foi paga! Cancelamento não permitido"
			Else
				If !Empty(cDocto)
					AAdd(aMsgErr,{cDocto,'00',''})
					cDocto := ""
				EndIf
				AAdd(aMsgErr,{STR0169,'00',''})
			EndIf
		Else
			If lExbHlp
				Help(Nil, 1,'HELP',Nil, STR0155 + Chr(13) + Chr(10) + STR0157 , 1, 0)  //-- "Manutenção de Fatura nao permitido! Esta fatura já foi paga!  
			Else
				If !Empty(cDocto)
					AAdd(aMsgErr,{cDocto,'00',''})
					cDocto := ""
				EndIf
				AAdd(aMsgErr,{STR0170,'00',''})
			EndIf
		EndIf	
		lRet:= .F.
	Endif
	
	If !lAnulacao .And. !(Upper(AllTrim(SE1->E1_ORIGEM)) $ "TMSA491#TMSA850#TMSA880#TMSAE45A")
		If nOpcx <> 4
			If lExbHlp
				Help(" ",1,"TMSA85019") //"Esta fatura foi gerada por outra rotina! Cancelamento não permitido"
			Else
				If !Empty(cDocto)
					AAdd(aMsgErr,{cDocto,'00',''})
					cDocto := ""
				EndIf
				AAdd(aMsgErr,{STR0171,'00',''})
			EndIf
		Else
			If lExbHlp
				Help(Nil, 1,'HELP',Nil, STR0155 + Chr(13) + Chr(10) + STR0158 , 1, 0)  //-- "Manutenção de Fatura nao permitido! Esta fatura foi gerada por outra rotina!
			Else
				If !Empty(cDocto)
					AAdd(aMsgErr,{cDocto,'00',''})
					cDocto := ""
				EndIf
				AAdd(aMsgErr,{STR0172,'00',''})
			EndIf
 		EndIf	
		lRet:= .F.
	EndIf
	
	If !Empty(dDataFIN) .And. dDataBase < dDataFIN
		If lExbHlp
			Help (" ",1,"DTMOVFIN") //--"Nao sao permitidas movimentacoes financeiras com datas menor ou igual a data limite de movimentacoes no Financeiro.
		Else
			If !Empty(cDocto)
				AAdd(aMsgErr,{cDocto,'00',''})
				cDocto := ""
			EndIf
			AAdd(aMsgErr,{STR0173,'00',''})
		EndIf
		lRet:= .F.
	EndIf
EndCase

If lRet .And. nOpcx == 4  //Alteração da Fatura
	aInfVis	:= Tmsa850Erp() 
	cAliasDRT	:= GetNextAlias()
	
	//-- Verifica se a fatura foi gerada a partir de documentos de apoio:
	cQuery := "SELECT COUNT(*) NUMDOCS "
	cQuery += " FROM " + RetSqlName('DT6')+ " DT6 "
	cQuery += " JOIN " + RetSqlName("DUI")+ " DUI "
	cQuery += "  ON DUI.DUI_FILIAL = '"+xFilial("DUI")+"'"
	cQuery += " AND DUI.DUI_DOCTMS = DT6_DOCTMS "
	cQuery += " AND DUI_DOCFAT     <> ' ' "
	cQuery += " AND DUI.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DT6.DT6_FILIAL ='" + xFilial("DT6") + "' "
	cQuery += "   AND DT6.DT6_CLIDEV ='" + PadR(aInfVis[E1CLIENTE], Len(aInfVis[E1CLIENTE])) + "' "
	cQuery += "   AND DT6.DT6_LOJDEV ='" + PadR(aInfVis[E1LOJA]   , Len(aInfVis[E1LOJA]))    + "' "
	cQuery += "   AND DT6.DT6_PREFIX ='" + PadR(aInfVis[E1PREFIXO], Len(aInfVis[E1PREFIXO])) + "' "
	cQuery += "   AND DT6.DT6_NUM    ='" + PadR(aInfVis[E1NUM]    , Len(aInfVis[E1NUM]))     + "' "
	cQuery += "   AND DT6.DT6_TIPO   ='" + PadR(aInfVis[E1TIPO]   , Len(aInfVis[E1TIPO]))    + "' "
	cQuery += "   AND DT6_DOCTMS IN('B','C','H','I','N','O') "
	cQuery += "   AND DT6.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery ), cAliasDRT, .F., .T.)
	If !(cAliasDRT)->(Eof()) .And. (cAliasDRT)->NUMDOCS > 0
		lFatApoio:= .T.
	EndIf
	(cAliasDRT)->(DbCloseArea())
EndIf
	
If lRet .And. lFatApoio
	If lExbHlp
		Help(Nil, 1,'HELP',Nil, STR0155 + Chr(13) + Chr(10) + STR0159 , 1, 0)  //-- "Manutenção de Fatura nao permitido! Fatura com Documentos de Apoio.
	Else
		If !Empty(cDocto)
			AAdd(aMsgErr,{cDocto,'00',''})
			cDocto := ""
		EndIf
		AAdd(aMsgErr,{STR0174,'00',''})
	EndIf
	lRet:= .F.
EndIf

RestArea(aArea)
RestArea(aAreaDRT)
RestArea(aAreaSE1)
RestArea(aAreaSA1)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T850FatBrc
Verifica o documento à ser inserido na fatura (se esta apto a ser faturado) 
@type function
@author felipe.barbieri
@version 12
@since 14/12/2018
@return posicao do aCols 
/*/
//-------------------------------------------------------------------------------------------------

Function T850FatBrc(lFatVazia,cChave, aDoctos, lVldCli)
Local nPos        := 0
Local lAddaDocto  := .F.

Default lFatVazia := .F.
Default cChave    := ""
Default aDoctos   := {}
Default lVldCli   := .T.

DT6->(DbSetOrder(18)) //DT6_FILIAL+DT6_CHVCTE
If !Empty(cChave) .And. DT6->(DbSeek(xFilial("DT6") + cChave))
	If !Empty(aDoctos)
		nPos := AScan(aDoctos, {|x| x[FILDOC]+x[CTRC]+x[SERIE] == DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE) })
	EndIf

	//| Se não localizou o documento em aDoctos[] inclui o registro na matriz. ** SOMENTE SE foi informado que a Fatura inicia-se fazia.
	If nPos == 0 .And. lFatVazia

		//| Verifica se o CTRC nao foi faturado ainda
		If Empty(DT6->(DT6_PREFIX+DT6_NUM+DT6_TIPO))

			//| Valida Devedor
			If !lVldCli .Or. (lVldCli .And. DT6->DT6_CLIDEV == Left(cCli, Len(SA1->A1_COD)) .And. (MV_PAR01 == 2 .Or. DT6->DT6_LOJDEV == _cLoja) .And. ;
							  DT6->DT6_FILDEB == cFilDeb)
				lAddaDocto := .T.	
			EndIf
		EndIf
	EndIf

	If lAddaDocto
		//| Inclui na matriz de doctos (ctrc) o documento localizado pelo código de barras
		AAdd(aDoctos, { .F., DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, DT6->DT6_VALTOT	,;
						DT6->DT6_ACRESC, DT6->DT6_DECRES,;
						If(DT6->DT6_VALFAT>0,DT6->DT6_VALFAT,DT6->DT6_VALTOT), DT6->DT6_DATEMI	,;
						Posicione('DUY',1,FWxFilial('DUY')+DT6->DT6_CDRDES,'DUY_EST'),,DT6->(Recno()) } )	
		nPos := Len(aDoctos)
	EndIf
Else
	Help(" ",1,"TMSA85009") //-- "Ctrc não encontrado!"
	lRet := .F.
EndIf

Return nPos

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMA850Ler
Faz a leitura da chave do CT-e e posiciona no registro do browser
@type function
@author Tiago Santos
@version 12
@since 13/12/2018
@return NIL
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMA850CLer(lFatVazia,oGetBar,oMsg,cChaveCTe,aDoctos,oLbxDocto,oMark,nValFat,nQtdCTRC,aVFContr, lExclui, nTotCanc)
 Local lResult    := .F.
 Local nPos       := 0
 Local cFilOriDe  := Space(Len(DT6->DT6_FILORI))
 Local cFilOriAte := Replicate("9",Len(DT6->DT6_FILORI))
 Local cUFDestDe  := Space(Len(DUY->DUY_EST))
 Local cUFDestAte := Replicate("9",Len(DUY->DUY_EST))
 
    cChaveCTe := STRTRAN(cChaveCTe,chr(10),'')
    cChaveCTe := STRTRAN(cChaveCTe,chr(13),'')

	oMsg:SetText("") 
	nPos := T850FatBrc(lFatVazia, cChaveCTe, aDoctos)
	If nPos > 0
		oLbxDocto:nAt := nPos

		//-- Marca ou Desmarca o documento
		TMSA850Inv(	1, aDoctos, oLbxDocto, oMark, cFilOriDe,;
								cFilOriAte, cUFDestDe, cUFDestAte, @nValFat,;
								@nQtdCTRC, aVFContr, lExclui, @nTotCanc )
		
		cChaveCTe := Space(Len(DT6->DT6_CHVCTE))
		oGetBar:CtrlRefresh()		
	ElseIf !Empty(cChaveCTe)		
		oMsg:SetText(STR0161 + STR0162 + SubStr(cChaveCTe,26,9) + STR0163 + SubStr(cChaveCTe,23,3))
		oMsg:CtrlRefresh()	
	EndIf

Return lResult
//-------------------------------------------------------------------
/*/{Protheus.doc} TM850CodBr
Leitura Cód Barras dos Documentos da Viagem

@class
@author 	Alex Amaral
@version	1.0
@since		19/12/2018

/*/
//-------------------------------------------------------------------
Function TM850CodBr(lFatVazia,aDoctos,oLbxDocto,oMark,nValFat,nQtdCTRC,aVFContr, lExclui, nTotCanc)

Local cCodbar  := Space(Len(DT6->DT6_CHVCTE))
Local cCodbar2 := Space(Len(DT6->DT6_CHVCTE))
Local cMsgAlert := "....."+ Space(200)
Local oGetBar,oMsg
Local lRet := .T.

Local oDlgBar := NIl

DEFINE DIALOG oDlgBar FROM 0,0 TO 100,400 TITLE STR0160 Of oMainWnd PIXEL  //--"Leitura do Cód. de Barras por Documento"

@ 10,10 SAY STR0164 Of oDlgBar PIXEL SIZE 100,10 //--Cód de barras"
@ 20,10 MSGET oGetBar VAR cCodbar SIZE 160,10 Picture '@!' VALID (!Empty(cCodBar) .And. TMA850CLer(lFatVazia,@oGetBar,@oMsg,@cCodbar,aDoctos,oLbxDocto,oMark,@nValFat,@nQtdCTRC,aVFContr, lExclui, @nTotCanc)) PIXEL
oMsg := TSay():New(34,10, {|| cMsgAlert },oDlgBar,,,,,,.T.,CLR_HRED,,190,9,,,,,)
@ 25,11 MSGET oGetBar2 VAR cCodbar2 SIZE 1,1 //-- campo para mudanca de foco e execucao do valid


ACTIVATE DIALOG oDlgBar CENTERED 

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMA850Val
Valida inclusão do documento na fatura
@type function
@author Valdemar Roberto Mognon
@version 12
@since 01/02/2019
@return NIL
/*/
//-------------------------------------------------------------------------------------------------

Function TMA850Val(lExclui,nValFat,lCONTDOC,nQtdCTRC,cFilDoc,cDoc,cSerie,nValFrete,nAcresc,nDecresc,aMsgErr,lExbHlp,;
				   nValMax,nQtdMax,cCliDev,cLojDev,cFilFat,lConLoj)
Local lRet     	:= .T.
Local nValAux  	:= 0
Local lEletronic := .F.

Default lExclui   := .F.
Default nValFat   := 0
Default lCONTDOC  := .T.
Default nQtdCTRC  := 0
Default cFilDoc   := ""
Default cDoc      := ""
Default cSerie    := ""
Default nValFrete := 0
Default nAcresc   := 0
Default nDecresc  := 0
Default aMsgErr   := {}
Default lExbHlp   := .F.
Default nValMax   := nValorFat
Default nQtdMax   := nMaxCtrc
Default cCliDev   := cCli
Default cLojDev   := _cLoja
Default cFilFat   := cFilDeb

If lConLoj == nil
	If _lConLoj == nil .or. !__EmpFil == cEmpAnt+cFilAnt
		Pergunte("TMA850",.F.)
		_lConLoj := (MV_PAR01 == 1)
		__EmpFil := cEmpAnt+cFilAnt
	EndIf 
	Default lConLoj   := _lConLoj
EndIf

//-- Verifica se o documento existe
If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
	DT6->(DbSetOrder(1))
	If !DT6->(MsSeek(FWxFilial("DT6") + cFilDoc + cDoc + cSerie))
		Help(" ",1,"TMSA85009") //-- "Ctrc não encontrado!"
		lRet := .F.
	EndIf

	//-- Valida se o documento é do cliente e da filial de debito indicados
	If lRet .And. !lExclui .And. !(DT6->DT6_CLIDEV == Left(cCliDev,Len(SA1->A1_COD)) .And. (!lConLoj .Or. DT6->DT6_LOJDEV == cLojDev) .And. DT6->DT6_FILDEB == cFilFat)
		Help(" ",1,"TMSA85008") //-- "Ctrc não é do cliente/loja ou da filial de débito escolhida!"
		lRet := .F.
	EndIf

	//-- Valida se o documento já está faturado
	If lRet .And. !lExclui .And. !Empty(DT6->(DT6_PREFIX + DT6_NUM + DT6_TIPO))
		Help(" ",1,"TMSA85007") //-- "Ctrc já foi faturado!"
		lRet := .F.
	EndIf

	//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
	If lRet .And. !lExclui
		If !TMSAVerAge("1",cFilDoc,cDoc,cSerie,,,,,,,,,"2",.T.,lExbHlp)
			lRet := .F.
			If !lExbHlp
				Aadd(aMsgErr,{"O agendamento do documento " + cFilDoc + "-" + cDoc + "-" + cSerie + ;
							  " não foi localizado ou está sendo utilizado.","00",""})
			EndIf
		EndIf
	EndIf

	//-- Verifica se o registro que está sendo usado por outra estação
	If lRet .And. !lExclui
		If lCONTDOC .And. !TmsConTran(cFilDoc,cDoc,cSerie, .T.)				
			lRet := .F.				
		EndIf	
	EndIf
	//lEletronic := (Posicione("DTP",1,FWxFilial("DTP")+DT6->DT6_LOTNFC,"DTP_TIPLOT") $ "3|4")
	DTP->(dbSetOrder(1))
	lEletronic := DTP->(MsSeek(FWxFilial("DTP")+DT6->DT6_LOTNFC)) .and. DTP->DTP_TIPLOT $ '3|4'
	//-- Verifica se o documento está autorizado pela SEFAZ e Doc <> Apoio
	If lRet .And. !lExclui
		If DT6->DT6_SITCTE <> "2" .And. lEletronic
			lRet := .F.
			If Alltrim(DT6->DT6_DOCTMS) == StrZero(5,Len(DT6->DT6_DOCTMS)) .Or.;		//--Nota Fiscal de Serv. de Transp.
				Alltrim(DT6->DT6_DOCTMS) == Replicate('D',Len(DT6->DT6_DOCTMS)) .Or.;	//--Nota Fiscal de Reentrega
				Alltrim(DT6->DT6_DOCTMS) == Replicate('F',Len(DT6->DT6_DOCTMS)) .Or.;	//--Nota Fiscal de Armazenagem
				Alltrim(DT6->DT6_DOCTMS) == Replicate('G',Len(DT6->DT6_DOCTMS)) .Or.;	//--Nota Fiscal de Complemento
				Alltrim(DT6->DT6_DOCTMS) == Replicate('H',Len(DT6->DT6_DOCTMS)) .Or.;	//--Documento de Apoio
				Alltrim(DT6->DT6_DOCTMS) == Replicate('B',Len(DT6->DT6_DOCTMS)) .Or.;    //--Documento de Apoio 
				Alltrim(DT6->DT6_DOCTMS) == Replicate('C',Len(DT6->DT6_DOCTMS)) .Or.;	//--Documento de Apoio 
				Alltrim(DT6->DT6_DOCTMS) == Replicate('N',Len(DT6->DT6_DOCTMS)) .Or.;	//--Documento de Apoio 
				Alltrim(DT6->DT6_DOCTMS) == Replicate('O',Len(DT6->DT6_DOCTMS)) .Or.;	//--Documento de Apoio 
				Alltrim(DT6->DT6_DOCTMS) == Replicate('I',Len(DT6->DT6_DOCTMS))			//--Documento de Apoio
				lRet := .T.
			EndIf
		EndIf
		If !lRet
			Help(" ",1,"TMSA85022") // CTE Nao Autorizado o Uso pelo SEFAZ
		EndIf
	EndIf
			
	//--Valida o Valor Maximo da fatura (Somente p/ Faturas por Docto)
	If lRet .And. !lExclui
		nValorFat := nValMax
		nValAux   := nValFat + ((nValFrete + nAcresc) - nDecresc ) 
		If nValAux > nValorFat .And. nValorFat > 0
			Help(" ",1,"TMSA85005") //-- "Valor da fatura irá ultrapassar o valor máximo informado."
			lRet := .F.
		EndIf
	EndIf
			
	//-- Valida a Qtde. Maxima de CTRC's (Somente p/ Faturas por Docto)
	If lRet .And. !lExclui
		nMaxCTRC := nQtdMax
		If (nQtdCTRC + 1) > nMaxCTRC .and. nMaxCTRC > 0
			Help(" ",1,"TMSA85004") //-- "Qtde. de ctrc irá ultrapassar o máximo informado para a fatura."
			lRet := .F.
		EndIf
	EndIf
	//-- Valida se o cliente exige Pré-Fatura
	If lRet .And. !lExclui
		aPerfil := TmsPerfil(DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,,.F.)
		If Len(aPerfil) >= 61 .And. ValType(aPerfil[61]) == "A" .And. Len(aPerfil[61]) >= 7 .And. aPerfil[61][1] == "1";
		.And. ( !("TMSAE45" $ FunName()) .Or. !IsInCallStack("TMSAE45A"))

			Help(" ",1,"TMSA85028") //-- "Este cliente exige que a fatura seja proveniente de uma Pré-Fatura. Execute a rotina de pré-fatura!"
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} dtVencPfat
Valida data do Vencimento da fatura com base no com DUO_TPVENC
@type function
@author Fabio Marchiori Sampaio
@version 12
@since 01/03/2019
@return NIL
/*/
//-------------------------------------------------------------------------------------------------

Function dtVencPfat(oTempTable, nValor, dEmisFat)

Local aVenc			:= {}
Local aPerfil		:= {}
Local cAliasTRB 	:= oTempTable:GetAlias()
Local cCondicao		:= ""

Default oTempTable	:= {}
Default nValor		:= 0
Default	dEmisFat	:= dDataBase

If DUO->(ColumnPos("DUO_TPVENC")) > 0

	(cAliasTRB)->(DbGoTop())
	aPerfil := TmsPerfil((cAliasTRB)->TRB_CLIDEV,(cAliasTRB)->TRB_LOJDEV,,.F.)

	If aPerfil[61][7] = '1'  //--Cond.Pagto Cliente ou Dt.Pré-Fatura
		aVenc := { { stoD((cAliasTRB)->TRB_DATVEN), nValor } }
	Else
		cCondicao := Posicione("SA1",1,xFilial("SA1")+((cAliasTRB)->TRB_CLIDEV+(cAliasTRB)->TRB_LOJDEV),"A1_COND")
		aVenc := Condicao(nValor,cCondicao,0, dEmisFat)
	EndIf

EndIf

Return(aVenc)

//---------------------------------------------------------------
/*/{Protheus.doc} TmQryFilial
Realiza adequação de sintaxe para comparação do campo FILIAL de um dado Alias com campos do tipo FILDOC/FILORI dentro de uma query, 
semelhante ao 2º argumento da função advpl FWxFilial.

@type		function
@author  	Daniel Leme
@version 	P12
@since   	14/10/2019
@return  	Nil
/*/
//---------------------------------------------------------------
Static Function TmQryFilial( cAlias, cCpoFilial, cCpoFilOri)
Local cFilQry := ""
Local nAux  
Local nResto

//-- Se tabela Totalmente compartilhada, FILIAL com espaços
If FWModeAccess(cAlias,1) == 'C' .And. FWModeAccess(cAlias,2) == "C" .And. FWModeAccess(cAlias,3) == "C"
	cFilQry += "  "+cCpoFilial +" = '"+Space(FWSizeFilial())+"'"
//-- Se tabela Totalmente Exclusiva, FILIAL preenchida com filial de origem
ElseIf FWModeAccess(cAlias,1) == 'E' .And. FWModeAccess(cAlias,2) == "E" .And. FWModeAccess(cAlias,3) == "E"
	cFilQry += "  "+cCpoFilial+" = "+cCpoFilOri+" "
//-- Se tabela Parcialmente Compartilhada, comparara até onde for o compartilhamento da tabela
Else
	nAux   := Len(RTrim(FWxFilial(cAlias)))
	nResto := FWSizeFilial() - nAux
	cFilQry += "  "+cCpoFilial+" = SUBSTRING("+cCpoFilOri+",1," + cValToChar(nAux) + ") + '" + Space(nResto) + "' "
EndIf

Return cFilQry

/*-------------------------------------------------------------------------------------------------
{Protheus.doc} TMA850Cli
Valida inclusão do documento na fatura
@type function
@author Valdemar Roberto Mognon
@version 12
@since 15/02/2022
@return NIL
-------------------------------------------------------------------------------------------------*/
Function TMA850Cli(cCodCli,cLojCli,dDatVen,nValMax,nQtdMax,dDatEmi)
Local aAreas  := {SA1->(GetArea()),DUO->(GetArea()),GetArea()}
Local lRet    := .T.
Local aPerfil := {}
Local aConPag := {}

Default cCodCli := ""
Default cLojCli := ""
Default dDatVen := dDataBase
Default nValMax := 0
Default nQtdMax := 0
Default dDatEmi := dDataBase

If !Empty(cCodCli) .And. ((MV_PAR01 == 1 .And. !Empty(cLojCli)) .Or. MV_PAR01 == 2)
	SA1->(DbSetOrder(1))
	If !SA1->(MsSeek(FWxFilial("SA1") + cCodCli + cLojCli))
		Help(" ",1,"A280CLI")
		lRet := .F.
	Endif
	
	If lRet
		//-- Verifica se deverá ser considerada a loja do cliente
		If ReadVar() == "_CLOJA" .Or. ReadVar() == "CCLI" .Or. l850Auto
			//-- Calcula a data de vencimento da fatura
			If Empty(dDatVen)
				aConPag := Condicao(1,SA1->A1_COND,0,dDatEmi)
				If Len(aConPag) > 0 .And. ValType(aConPag[1,1]) == "D"
					dDatVen := DataValida(aConPag[1,1],.T.)
				Else
					dDatVen := CriaVar("E1_VENCTO",.F.)
				EndIf
			EndIf
			If MV_PAR01 == 2
				aPerfil := TmsPerfil(SA1->A1_COD,_cLoja)
			Else
				aPerfil := TmsPerfil(SA1->A1_COD,SA1->A1_LOJA)
			EndIf
			
			If Len(aPerfil) > 0
				nValMax	:= If(Empty(nValMax),aPerfil[10],nValMax)	//-- Valor máximo da fatura
				nQtdMax	:= If(Empty(nQtdMax),aPerfil[11],nQtdMax)	//-- Quantidade de CTes por fatura
			Else
				nValMax := If(Empty(nValMax),0,nValMax)
				nQtdMax := If(Empty(nQtdMax),0,nQtdMax)
			Endif	
		EndIf
	Endif
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet
