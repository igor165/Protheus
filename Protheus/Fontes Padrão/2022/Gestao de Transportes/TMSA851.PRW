#INCLUDE "TMSA851.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSA491DEA.ch"

	//------------------------------------------------------------------------------------------------------------------------------------//
	/* Os DEFINEs  foram removidos para a "TMSA491DEA.ch" (definição de Estrura de Array), onde estão contidos os defines dos              //
	//Fontes TMSA491/TMSA850/TMSA851.Caso seja necessário a criação de mais Defines favor manter o padrão incluindo no "TMSA491DEA.ch" */ //
	//------------------------------------------------------------------------------------------------------------------------------------//
	
Static  RECNOCTRC 	 := 12		

//-- Pontos de entrada
Static lTM851FIL := ExistBlock("TM851FIL") //-- PE -> Filtro para MBrowse
Static lTM851MNU := ExistBlock("TM851MNU") //-- PE -> Montagem aRotina no MenuDef
Static lTM851MEC := ExistBlock("TM851MEC") //-- PE -> Manipular as colunas de aCampos
Static lTM491CPO := ExistBlock('TM491CPO') //-- PE -> Atualiza campos do usuario
Static lTM851CPO := ExistBlock('TM851CPO') //-- PE -> Apos geracao de fatura
Static lTM851ITE := ExistBlock('TM851ITE') //-- PE -> Apos gravacao da fatura
Static lTM851GRV := ExistBlock("TM851GRV") //-- PE -> Complementar a gravacao de alguns campos do DT6 e DVV
Static lTM851EXC := ExistBlock("TM851EXC") //-- PE -> Apos exclusao documentos da fatura

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA851
Faturas a Receber por Documentos de Transporte
Sele‡„ção de documentos (Conhecimentos) de transporte para geração da fatura a receber
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [xAutoCab], Array, Documentos
@param [nOpcAuto], Numérico, Opção
@param [xFilAut], Caracter, Filial de débito da fatura
@param [xCliFat], Caracter, Cliente da fatura
@param [xLojFat], Caracter, Loja do cliente da fatura
@param [xMoeAut], Numérico, Moeda da fatura
@param [xEmiAut], Data, Emissão da fatura
@param [xVenAut], Data, Vencimento da fatura
@return Nil Não há retorno
@obs Tabela: DRT - Fatura de Transporte a Receber (Projeto Ellece);
@obs Utilizado apenas quando há integração com o ERP Datasul (MV_TMSERP = '1').
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA851(xAutoCab, nOpcAuto, xFilAut, xCliFat, xLojFat, xMoeAut, xEmiAut, xVenAut)

	Local cFilMbrow := ""
	Local cFilMbrPE := ""
	Local lPainel   := .F.
	Local cTmsERP   := SuperGetMV("MV_TMSERP",,'0')

	Private aRotina     := MenuDef()
	Private cCadastro   := STR0001 // "Faturas a Receber"
	Private l851Auto    := xAutoCab <> Nil
	Private lMsHelpAuto := .F.
	Private aSetKey     := {}
	Private aAutoCab    := {}
	Private cFilAut     := ""
	Private cCliFat     := Space(6)
	Private cLojaFat    := Space(2)
	Private nMoeAut     := 0
	Private dEmisFat    := SuperGetMv("MV_DATAFAT",,dDataBase)
	Private dVenAut     := Ctod(Space(8))
	
	Default xAutoCab  := {}
	Default nOpcAuto  := 3
	Default xFilAut   := ""
	Default xCliFat   := ""
	Default xLojFat   := ""
	Default xMoeAut   := 0
	Default xEmiAut   := Ctod(Space(8))
	Default xVenAut   := Ctod(Space(8))
	
		
	If Type("aPanAgeTMS") == "U"
		aPanAgeTMS := Array(6)
	EndIf
	//-- Execucao pelo Painel de Agendamentos
	lPainel := IsInCallStack("TMSAF76") .And. !Empty(aPanAgeTMS)
	
	If (!IsInCallStack("TMSA850") .And. !lPainel) .Or. cTmsERP !=  '1' //-- ERP Datasul
		Help(" ", 1, "TMSA85101") // "Acesso direto ao programa nao permitido!"
		return Nil
	EndIf
	
	If ! FWHasEAI('TMSA851',.T.,,.T.)
		Help(" ", , "TMSA85102") // "Adapter para a rotina TMSA851 nao configurado para realizacao da integracao!"
		Return
	EndIf
	
	//-- MV_PAR01: Considera Loja
	Pergunte("AFI281",.F.)
	
	If l851Auto
		//-- Execucao automatica
		
		//-- Selecionar ou Cancelar
		If nOpcAuto == 3 .Or. nOpcAuto == 5
			lMsHelpAuto := .T.
			aAutoCab    := aClone(xAutoCab)
			cFilAut     := xFilAut
			cCliFat     := xCliFat
			cLojaFat    := xLojFat
			nMoeAut     := xMoeAut
			dEmisFat    := xEmiAut
			dVenAut     := xVenAut
			MBrowseAuto(nOpcAuto, Aclone(aAutoCab), "DRT", .F.)
		EndIf
	Else
		//-- Execucao manual
		
		//--Inicializa as teclas de atalho
		AAdd(aSetKey,  { VK_F12,{|a,b| Pergunte("AFI281",.T.)}} )
		TMSKeyOn(aSetKey)
	
		DbSelectArea("DRT")
		
		//-- PE -> Filtro para MBrowse
		If lTM851FIL
			cFilMbrPE := ExecBlock("TM851FIL",.F.,.F.)
			If(Valtype(cFilMbrPE) = "C") .And. !Empty(cFilMbrPE)
				cFilMbrow := cFilMbrPE
			EndIf
		EndIf
	
		If !lPainel
			MBrowse(6, 1, 22, 75, "DRT", , , , , , Tmsa851Leg(), , , , , , , , cFilMbrow)
		Else
			//-- Execucao pelo Painel de Agendamentos
			If (at("(",aPanAgeTMS[6])>0)
				&(aPanAgeTMS[6])
			Else
				&(aPanAgeTMS[6] + "('" + aPanAgeTMS[1] + "'," + StrZero(aPanAgeTMS[2],10) + "," + StrZero(aPanAgeTMS[3],2) + ")")
			EndIf
		EndIf
	
		//-- Finaliza teclas de atalhos
		TMSKeyOff(aSetKey)
	EndIf

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Montagem do menu
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@return aRotina Array com as rotinas do programa
/*/
//-------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {} //-- Definicoes das rotinas do programa
	Local aRotAdic:= {} //-- Itens a serem adicionados no aRotina via P.E.
	
	aRotina := {	{STR0002, "AxPesqui"  , 0, 1, 0, .F.},; // "Pesquisar"
					{STR0003, "Tmsa850Vis", 0, 2, 0, Nil},; // "Visualizar"
					{STR0004, "Tmsa851Aut", 0, 3, 0, Nil},; // "Selecionar"					
					{STR0032, "Tmsa851Aut", 0, 4, 0, Nil},; // "Alterar"
					{STR0006, "Tmsa850Exc", 0, 5, 0, Nil},; // "Cancelar"
					{STR0005, "Tmsa851His", 0, 6, 0, Nil},; // "Historico"
					{STR0007, "Tmsa851Par", 0, 7, 0, Nil},; // "Parametros"
					{STR0008, "Tmsa851Leg", 0, 8, 0, .F.} } // "Legenda"

	If FindFunction("TmsA491Imp")
		aAdd(aRotina, {STR0029, "TmsA491Imp", 0, 8, 0, NIL}) // "Impressão Fatura"
	EndIf
	
	//-- PE -> Montagem aRotina no MenuDef
	If lTM851MNU
		aRotAdic := ExecBlock("TM851MNU",.F.,.F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf

Return aRotina

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa851Leg
Cria uma janela contendo a legenda da mBrowse ou retorna para o BROWSE
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [cAlias], Caracter, Alias
@param [nReg], Numérico, Número do registro
@param [nOpc], Numérico, Opção
@return uRetorno Retorno lógico
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa851Leg(cAlias, nReg, nOpc)

	Local aLegenda := {	{"BR_AZUL"    , STR0009 },; // "Fatura integrada"
						{"BR_PINK"    , STR0030 },; // "Fatura impressa"
						{"BR_AMARELO" , STR0011 },; // "Fatura parcialmente baixada"
						{"BR_LARANJA" , STR0012 },; // "Fatura totalmente baixada"
						{"BR_CINZA"   , STR0013 },; // "Fatura cancelada"
						{"BR_VIOLETA" , STR0014 },; // "Fatura protestada"
						{"BR_VERMELHO", STR0031 } } // "Fatura Apoio Não Integrada"
	Local uRetorno := .T.
	
	If nReg == Nil //-- Chamada direta da funcao onde nao passa, via menu Recno eh passado
		uRetorno := {}
		AAdd(uRetorno, { "DRT_STATUS == '1'", aLegenda[1][1] } )
		AAdd(uRetorno, { "DRT_STATUS == '7'", aLegenda[2][1] } )
		AAdd(uRetorno, { "DRT_STATUS == '3'", aLegenda[3][1] } )
		AAdd(uRetorno, { "DRT_STATUS == '4'", aLegenda[4][1] } )
		AAdd(uRetorno, { "DRT_STATUS == '5'", aLegenda[5][1] } )
		AAdd(uRetorno, { "DRT_STATUS == '6'", aLegenda[6][1] } )
		AAdd(uRetorno, { "DRT_STATUS == '8'", aLegenda[7][1] } )
	Else
		BrwLegenda(cCadastro, STR0008, aLegenda) // "Legenda"
	Endif

Return uRetorno

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa851His
Apresenta o historico da fatura
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [cAlias], Caracter, Alias
@param [nReg], Numérico, Número do registro
@param [nOpc], Numérico, Opção
@return lRet Retorno lógico
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa851His(cAlias, nReg, nOpc)

	Local lRet := .T.
	Local oDlgHis
	Local oGetHis 
	Local cHistor := MSMM(DRT->DRT_CODHIS)

	DEFINE MSDIALOG oDlgHis TITLE STR0005 FROM 00,00 TO 20,50 //-- Historico
	DEFINE SBUTTON FROM 135, 170.0 TYPE 1 ENABLE OF oDlgHis ACTION (oDlgHis:End())
	@ 0.4,0.5  GET oGetHis VAR cHistor OF oDlgHis MEMO SIZE 192, 124 READONLY
	oGetHis:bRClicked := {||AllwaysTrue()} 
	ACTIVATE MSDIALOG oDlgHis CENTERED

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa851Par
Parametros
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [cAlias], Caracter, Alias
@param [nReg], Numérico, Número do registro
@param [nOpc], Numérico, Opção
@return lRet Retorno lógico
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa851Par(cAlias, nReg, nOpc)

	Local lRet := .T.
	
	Pergunte("AFI281", .T.)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa851Aut
Marca‡ção dos documentos para emissão de fatura
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [cAlias], Caracter, Alias
@param [nReg], Numérico, Número do registro
@param [nOpc], Numérico, Opção
@return Lógico Retorno lógico
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa851Aut(cAlias, nReg, nOpc)

	Local cVar
	Local lUsado    := .F.
	Local aTam      := {}
	Local nOpca     := 0
	Local nCnt1     := 0
	Local nCnt2     := 0
	Local nMoedFat  := 1	
	Local dVencFat  := CtoD(Space(08))
	Local lEof      := .F.
	Local lMrkDoc   := .F.
	Local lFatVazia := .F.
	Local aChaveLbn := {}
	Local aTitulos  := {}
	Local aDoctos   := {}
	Local aCampos   := {	{"DT6_FILDOC" , PesqPict("DT6","DT6_FILDOC"  )},; // 2
							{"DT6_DOC"    , PesqPict("DT6","DT6_DOC"     )},; // 3
							{"DT6_SERIE"  , PesqPict("DT6","DT6_SERIE"   )},; // 4
							{"DT6_VALTOT" , PesqPict("DT6","DT6_VALTOT"  )},; // 5
							{"DT6_ACRESC" , PesqPict("DT6","DT6_ACRESC"  )},; // 6
							{"DT6_DECRES" , PesqPict("DT6","DT6_DECRES"  )},; // 7
							{"_SI_VALFAT" , PesqPict("DT6","DT6_VALFRET" )},; // 8
							{"DT6_DATEMI" , PesqPict("DT6","DT6_DATEMI"  )},; // 9
							{"_SI_UFDEST" , PesqPict("SA1","A1_EST"      )},; //10
							{"DT6_NUM" 	  , PesqPict("DT6","DT6_NUM"  )}}	 // 11
	Local aColSiz    := {0, 30, 50, 45, 65, 60, 60, 65, 40, 30}
	Local nValor     := 0
	Local aVFContr   := {}
	Local aFtGeradas := {}
	Local aCamposBkp := {}
	Local lTMSA850   := Upper(AllTrim(FunName())) == "TMSA850"
	Local lContinua  := .T.

	Private aHeader := {}
	Private aCols   := {}
	Private oValTot
	Private nValTot := 0
	Private cFilDeb := Space(TamSx3("DRT_FILDEB")[1])
	Private nMaxCtrc:= 0
	Private nMinCtrc:= 0
	If Type("dEmisFat") == 'U'
		dEmisFat := dDatabase
	EndIf
	If Type("dVenAut") == "U"
		dVenAut := CtoD(Space(08))
	EndIf
	If Type("l851Auto") == "U"
		l851Auto  := .F.
	EndIf
	
	//-- Finaliza Teclas de Atalhos
	If lTMSA850
		TmsKeyOff(aSetKey)
	EndIf
	
	//-- MV_PAR01: Considera Loja
	Pergunte("AFI281",.F.)
	
	//-- PE -> Manipular as colunas de aCampos
	If lTM851MEC
		aCamposBkp := aClone(aCampos)
		aCampos := ExecBlock("TM851MEC",.F.,.F.,{aCampos})
		If ValType(aCampos) != "A" .Or. Len(aCampos) <= 0
			aCampos   := aClone(aCamposBkp)
			RECNOCTRC := Len(aCampos)
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o campo A1_CLIFAT est  em uso                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lUsado := X3Uso(GetSX3Cache("A1_CLIFAT", "X3_USADO"))
	
	dDataDe  := dDataBase
	dDataAte := dDataBase
	nValorFat:= 0
	
	//-- Rotina automatica de geracao de Faturas por Documentos
	If l851Auto
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
		If StaticCall(TMSA850, Tms850Ok, cFilDeb, cCliFat, cLojaFat, @aChaveLbn, dVenAut) 
			Tmsa851Grv(.F., nMoeAut, aDoctos, dEmisFat, dVenAut, nValor, /*cAliasTRB*/, /*cSerie*/, /*nRecDT6*/, .T., /*lExecSched*/,/*aErrosInt*/, nOpc)
		EndIf
		If !Empty(aChaveLbn)
			aEval(aChaveLbn, {|e| UnLockByName(e,.T.,.F.) } ) // Libera Lock
		EndIf
		Return Nil
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recebe dados a serem digitados                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTam    := TamSX3("DRT_CLIFAT")
	cCli    := Space(aTam[1])
	cCliFat := Space(aTam[1])

	aTam    := TamSX3("DRT_LOJFAT")
	_cLoja  := Space(aTam[1])
	cLojaFat:= Space(aTam[1])
	
	DbSelectArea(cAlias)

	If nOPc == 4
		//--- Se for uma fatura de Documento de Apoio nao permite a alteração
		cCli  	 := DRT->DRT_CLIFAT
		_cLoja	 := DRT->DRT_LOJFAT
		cFilDeb  := DRT->DRT_FILDEB
		dEmisFat := DRT->DRT_DTEMIS
		
		//--- Para Fatura do Tipo Apoio, nao é permitido alteração.
		If FindFunction("TMSA850Vld")
			lContinua:= TMSA850Vld(nOPc,.F.)
		EndIf	
	EndIf
	
	If lContinua
		//-- Funcao para montagem da tela inicial com os parametros da fatura e selecao de documentos
		//-- Utilizada no TMSA850 e TMSA851
		TMSA850Ini(        ,         ,          ,           , @cVar   , @dEmisFat, @cCli    , @_cLoja, @dVencFat, @lFatVazia,;
		           @lMrkDoc, @dDataDe, @dDataAte, @nValorFat, @cCliFat, @cLojaFat, @nMaxCtrc, @lUsado, @cFilDeb , @nMinCtrc, @aChaveLbn, @nOpca, ,nOpc)
		
	  	If nOpca == 1
			nMoedFat := Val(Substr(cVar,1,2))
		
			If !lFatVazia
			
				//-- Funcao para retornar documentos para selecao na fatura
				//-- Utilizada no TMSA850 e TMSA851
				aDoctos := TMSA850Doc(aCampos, cCli, _cLoja, dDataDe, dDataAte, cFilDeb, nMoedFat, nMinCtrc, IIF(nOpc==4,DRT->DRT_NUM,""))			
				lEof    := Len(aDoctos) = 0
		
			Else
			
				//-- Cria a matriz de doctos. a serem faturados, em branco
				AAdd(aDoctos,{.F.})
				nLen := Len(aDoctos)
				aEval(aCampos, { |e| AAdd(aDoctos[nLen], "" ) })
				AAdd(aDoctos[nLen], 0)
				
			EndIf
		
			If lEof
				Help(" ", 1, "REGNOIS") //"Nao existe registro relacionado a este codigo"
			Else
				nOpcA := 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta array com campos a serem mostrados na marcacao de ctrc   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AAdd(aTitulos," ")
				aEval(aCampos, { |e|	If(e[1] = "_SI_VALFAT", AAdd(aTitulos,STR0015),; //"Valor a faturar"
										If(e[1] = "_SI_UFDEST", AAdd(aTitulos,STR0016),; //"Uf Destino"
										AAdd(aTitulos,Posicione('SX3', 2, AllTrim(If(e[1]="DT6_VALTOT","DT6_VALFRE",e[1])), 'X3Titulo()')))) } )
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Marca os titulos ate o valor informado para a fatura         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nValor  := 0
				nQtdCtrc:= 0
		
				//-- Se NAO for uma fatura vazia, marca todos os documentos
				nValorF := nValorFat
		
				//-- Monta a tela
				nOpcA := Tmsa850Tela(lFatVazia, , "", , nMoedFat, nOpc, aCampos, aTitulos, aDoctos, @nValor, 0,;
				                     .F.,.F.,,,,,,,,,, aVFContr, lMrkDoc, aColSiz, dVencFat, @aFtGeradas)
		
			EndIf
		EndIf
	EndIf
	
	cCli      := Space(6)
	_cLoja    := Space(2)	
	dDataDe   := dDatabase
	dDataAte  := dDataBase
	nValorF   := 0
	nValorFat := 0
	
	If !Empty(aChaveLbn)
		aEval(aChaveLbn, {|e| UnLockByName(e,.T.,.F.) } ) // Libera Lock
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

Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa851Grv
Gera a Fatura
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [lMostraGet], Lógico, Mostra tela com numeros das faturas geradas?
@param [nMoedFat], Numérico, Moeda da fatura
@param [aDoctos], Array, Documentos da fatura
@param [dEmisFat], Data, Emissão da fatura
@param [dVencFat], Data, Vencimento da fatura
@param [nValor], Numérico, Valor da fatura
@param [cAliasTRB], Caracter, Alias
@param [cSerie], Caracter, Série do documento
@param [nRecDT6], Numérico, RECNO DT6
@param [lFTPorDoc], Lógico, Fatura por docto.?
@param [lExecSched], Lógico, Execução via schedule
@param [aErrosInt], Array, Execução via schedule
@return aFtGeradas Faturas geradas
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa851Grv(lMostraGet, nMoedFat, aDoctos, dEmisFat , dVencFat , nValor,;
                    cAliasTRB , cSerie  , nRecDT6, lFTPorDoc, lExecSched, aErrosInt, nOpc)

	Local aFtGeradas := {}
	Local aMsgFat    := {}
	
	Default lMostraGet := .T.
	Default nMoedFat   := 1
	Default aDoctos    := {}
	Default dEmisFat   := dDataBase
	Default dVencFat   := Ctod("")
	Default cAliasTRB  := ''
	Default cSerie     := ''
	Default nRecDT6    := 0
	Default lFTPorDoc  := .F.
	Default lExecSched := .F.
	Default aErrosInt  := {}
	Default nOpc	   := 3
	
	If lFTPorDoc
		
		//"Gravando a fatura e atualizando Ctrcs..."
		Processa({|| aFtGeradas := Tmsa851Grava(aDoctos, nMoedFat, dEmisFat, dVencFat, nValor, cAliasTRB, cSerie, @nRecDT6, lFTPorDoc, @aErrosInt, nOpc)}, STR0017)
	
		//-- Exibe o resumo para o usuario
		If Len(aFtGeradas) > 0
			AaddMsgErr(aFtGeradas, @aMsgFat)
			If Len(aMsgFat) > 0 .And. lMostraGet
				TmsMsgErr(aMsgFat, STR0001) //"Faturas a Receber"
			EndIf
		EndIf
	Else
		If lExecSched
			// "Gravando a fatura e atualizando Ctrcs..."
			BatchProcess(STR0017, STR0017, "TMSA850GRV", {|| aFtGeradas := Tmsa851Grava(aDoctos, nMoedFat, dEmisFat, dVencFat, nValor, cAliasTRB, cSerie, @nRecDT6, lFTPorDoc, @aErrosInt, nOpc)}, {||.F.})
		Else
			//"Gravando a fatura e atualizando Ctrcs..."
			Processa({|| aFtGeradas := Tmsa851Grava(aDoctos, nMoedFat, dEmisFat, dVencFat, nValor, cAliasTRB, cSerie, @nRecDT6, lFTPorDoc, @aErrosInt, nOpc)}, STR0017)
		EndIf
	EndIf

Return aFtGeradas

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa851Grava
Grava a Fatura
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [aDoctos], Caracter, Documentos da fatura
@param [nMoedFat], Caracter, Moeda da fatura
@param [dEmisFat], Caracter, Emissão da fatura
@param [dVencFat], Caracter, Vencimento da fatura
@param [nValor], Caracter, Valor da fatura
@param [cAliasTRB], Caracter, Alias TRB
@param [cSerie], Caracter, Série
@param [nRecDT6], Caracter, RECNO DT6
@param [lFTPorDoc], Caracter, Fatura por documento?
@param [aErrosInt], Array, Execução via schedule
@return aFtGeradas Faturas geradas
/*/
//-------------------------------------------------------------------------------------------------
Static Function Tmsa851Grava(aDoctos , nMoedFat, dEmisFat	, dVencFat , nValor	, cAliasTRB, ;
                             cSerie  , nRecDT6 , lFTPorDoc	, aErrosInt, nOpc)

	Local cAliasQry   := GetNextAlias()
	Local aFtGeradas  := {}
	Local aDoctosMrk  := {}
	Local cQuery      := ''
	Local cMay        := ''
	Local cRecno      := ''
	Local cRecnoCan	  := ''
	Local cCliFat     := ''
	Local cLojFat     := ''
	Local cFilDoc     := ''
	Local cDoc        := ''
	Local nLen        := 0
	Local nX          := 0
	Local nY          := 0
	Local nXCont      := 0
	Local nErro       := 0
	Local nDoctos     := 0
	Local nTent       := 0
	Local nCnt        := 0
	Local nRecDRT     := 0
	Local lTMSFMSG    := SuperGetMv("MV_TMSFMSG",.F.,.T.)
	Local lAchou      := .F.
	Local lErro       := .F.
	Local lDocApoio   := .F.
	Local aAreaDt6    := {}
	Local lRet        := .T.
	Local nAcresc     := 0
	Local nDecresc    := 0
		
	Default aDoctos   := {}
	Default nMoedFat  := 1
	Default dEmisFat  := dDataBase
	Default dVencFat  := CtoD(Space(08))
	Default nValor    := 0
	Default cAliasTRB := ''
	Default cSerie    := ''
	Default nRecDT6   := 0
	Default lFTPorDoc := .T.
	Default aErrosInt := {}
	Default nOpc	  := 3

	Private INCLUI := .T.
	Private ALTERA := .F.
	
	Begin Transaction
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ INI -> Tratamento para nao duplicar numero das faturas       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !LockByName("A280NUMFAT", .T., !Empty(xFilial("DRT"))) .And. nTent <= 50
			nTent++
			Sleep(5000)
		EndDo
		If nTent >= 50
			UserException(STR0018) //"NAO CONSEGUI LOCKBYNAME A280NUMFAT"
		EndIf
		
		If nOpc == 3
			//-- Obtem o numero da fatura e ja confirma este numero
			cFatura := Soma1(GetMv('MV_NUMFAT'), Len(DRT->DRT_NUM))
			cMay    := "DRT" + xFilial("DRT") + cFatura
			
			DRT->(DbSetOrder(1))
			//-- Verifica se esta na memoria, sendo usado
			While DRT->(MsSeek(xFilial("DRT")+cFatura)) .Or. !MayIUseCode(cMay)
				//-- Busca o proximo numero disponivel
				cFatura := Soma1(cFatura, Len(DRT->DRT_NUM))
				cMay    := "DRT" + xFilial("DRT") + cFatura
			EndDo
		
			//-- Grava no SX6 o numero da ultima fatura
			PutMV('MV_NUMFAT', cFatura)
			FreeUsedCode(.T.)
			UnLockByName("A280NUMFAT", .T., !Empty(xFilial("DRT")))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ FIM -> Tratamento para nao duplicar numero das faturas       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf nOpc == 4	
			cFatura := DRT->DRT_NUM
		EndIf	

		//-- Transferir para array aDoctosMrk somente documentos marcados
		nLen := 0
		aAreaDt6:= DT6->(GetArea())
		For nX := 1 To Len(aDoctos)
			If aDoctos[nX][MARCA]
				Aadd(aDoctosMrk, aDoctos[nX])
				nLen++
				//---- Verifica somente o primeiro Documento se é do tipo Apoio
				If nLen == 1
					If nOpc == 3
						If (IsInCallStack("TMSA850") .Or. IsInCallStack("TMSA851") .And. !IsInCallStack("TMSA491"))
							DT6->(DbGoto(aDoctos[nX, RECNOCTRC]))
						Else
							DT6->(DbGoto(aDoctos[nX, LARECNO]))
						EndIf
					Else
						DT6->(DbGoto(aDoctos[nX, RECNOCTRC]))
					EndIf	
					lDocApoio := DT6->DT6_DOCTMS $ "|B|C|H|I|N|O|" .And. !Empty(Posicione('DUI',1,xFilial('DUI')+DT6->DT6_DOCTMS,'DUI_DOCFAT'))
				EndIf
			ElseIf nOpc == 4 .And. aDoctos[nX][NUMFAT] = cFatura 
				Aadd(aDoctosMrk, aDoctos[nX])
				nLen++				
			EndIf
		Next nX
		RestArea(aAreaDt6)
		
		ProcRegua((nLen * 2) + nLen)
		
		nDoctos := 0
		while(nDoctos != nLen)
		
			cRecno := ""
			nY     := 0
		
			//-- Monta a string limitando a 14Kb
			For nX := Iif(nDoctos == 0, 1, nDoctos + 1) To nLen
				
				IncProc(STR0021 + Alltrim(Str(nX, 10)) + "/" + Alltrim(Str(nLen, 10))) //"Atualizando ctrc: "
				nDoctos++
				nY++
				If aDoctosMrk[nX,MARCA]
					If nOpc == 3
						If (IsInCallStack("TMSA850") .Or. IsInCallStack("TMSA851") .And. !IsInCallStack("TMSA491"))
							cRecno += Alltrim(Str(aDoctosMrk[nX][RECNOCTRC],20))+","
						Else
							cRecno += Alltrim(Str(aDoctosMrk[nX][LARECNO],20))+","
						EndIf
					Else
						cRecno += Alltrim(Str(aDoctosMrk[nX][RECNOCTRC],20))+","
					EndIf					
				ElseIf !Empty(aDoctosMrk[nX,NUMFAT])
					If nOPc == 3 
						If (IsInCallStack("TMSA850") .Or. IsInCallStack("TMSA851") .And. !IsInCallStack("TMSA491"))
							cRecnoCan += Alltrim(Str(aDoctosMrk[nX][RECNOCTRC],20))+","
						Else
							cRecnoCan += Alltrim(Str(aDoctosMrk[nX][LARECNO],20))+","
						EndIf
					Else
						cRecnoCan += Alltrim(Str(aDoctosMrk[nX][RECNOCTRC],20))+","		
					EndIf									
				EndIf	
				// Se atingiu 1000 ctrc, atualiza de 1000 em 1000
				If nY >= 1000 .Or. Len(cRecno)+Len(cRecnoCan) >= 13500
					Exit
				EndIf
			Next nX
			
			If !Empty(cRecno) .And. !Empty(nRecDT6)
				cRecno := cRecno + AllTrim(Str(nRecDT6)) + ","
			EndIf
			
			If nDoctos > 0
				
				//-- Atualizacao dos campos da tabela DT6 que indicam a ligacao entre o documento e a fatura
				cQuery := "UPDATE " + RetSqlName("DT6")
				cQuery += "   SET DT6_PREFIX = '"  + Space(TamSX3("E1_PREFIXO")[2])     + "',"
				cQuery += "       DT6_NUM    = '"  + cFatura                            + "',"
				cQuery += "       DT6_TIPO   = '"  + Space(TamSX3("E1_TIPO")[2])        + "',"
				cQuery += "       DT6_VENCTO = '"  + DtoS(dVencFat)                     + "' "
				cQuery += " WHERE R_E_C_N_O_ IN (" + SubStr(cRecno,1,Rat(",",cRecno)-1) + ") "
				If nOpc <> 4
					cQuery += "   AND DT6_PREFIX = '"  + Space(Len(DT6->DT6_PREFIX))        + "' "
					cQuery += "   AND DT6_NUM    = '"  + Space(Len(DT6->DT6_NUM))           + "' "
					cQuery += "   AND DT6_TIPO   = '"  + Space(Len(DT6->DT6_TIPO))          + "' "
				EndIf	
				If (nErro:=TCSqlExec(cQuery)) <> 0
					Help(" ", 1, "TMSA85103", , Alltrim(Str(nErro)), 2, 1) //"Erro ao atualizar o documento vinculado a fatura. Situacao: "
					lErro := .T.
					Exit
				EndIf
				cQuery := ''
				//Remove a marca no DT6 ref. aos documentos que faziam parte da fatura e foram desmarcados.
				If nOpc == 4 .And. !Empty(cRecnoCan)
					cQuery := "UPDATE " + RetSqlName("DT6")
					cQuery += "   SET DT6_PREFIX = '"  + Space(TamSX3("E1_PREFIXO")[2])     + "',"
					cQuery += "       DT6_NUM    = '"  + Space(TamSX3("E1_NUM")[2])         + "',"
					cQuery += "       DT6_TIPO   = '"  + Space(TamSX3("E1_TIPO")[2])        + "',"
					cQuery += "       DT6_VENCTO = '"  + DtoS(dVencFat)                     + "' "
					cQuery += " WHERE R_E_C_N_O_ IN (" + SubStr(cRecnoCan,1,Rat(",",cRecnoCan)-1) + ") "
				EndIf
				If (nErro:=TCSqlExec(cQuery)) <> 0
					Help(" ", 1, "TMSA85103", , Alltrim(Str(nErro)), 2, 1) //"Erro ao atualizar o documento vinculado a fatura. Situacao: "
					lErro := .T.
					Exit
				EndIf
			EndIf
		EndDo	

		If !lErro
			// Atualiza acrescimos e decrescimos, efetuados nos ctrcs da fatura
			For nX := 1  To nLen
		
				IncProc(STR0022 + Alltrim(Str(nX,10)) + "/" +Alltrim(Str(nLen,10))) //"Atualizando ajustes nos doctos: "
		
				If aDoctosMrk[nX][MARCA]
					If (aDoctosMrk[nX][ACRESC] + aDoctosMrk[nX][DECRESC]) > 0
						// Atualiza o acrescimo e decrescimo do ctrc atual
						cQuery := "UPDATE "
						cQuery += RetSqlName("DT6")+" "
						cQuery += "SET	DT6_ACRESC = " + Str(aDoctosMrk[nX][ACRESC],17,2) +","
						cQuery += "		DT6_DECRES = " + Str(aDoctosMrk[nX][DECRESC],17,2)
						If IsInCallStack("TMSA491") .AND. nOPc <> 4
							cQuery += " WHERE R_E_C_N_O_ = " + Alltrim(Str(aDoctosMrk[nX][LARECNO],20))
						Else
							cQuery += " WHERE R_E_C_N_O_ = " + Alltrim(Str(aDoctosMrk[nX][RECNOCTRC],20))
						EndIf
						
						cQuery += " AND DT6_PREFIX = '" + Space(TamSX3("E1_PREFIXO")[2]) + "' "
						cQuery += " AND DT6_NUM    = '" + cFatura + "' "
						cQuery += " AND DT6_TIPO   = '" + Space(TamSX3("E1_TIPO")[2])   + "' "
						TcSqlExec(cQuery)
						If (nErro:=TCSqlExec(cQuery)) <> 0
							Help(" ", 1, "TMSA85103", , Alltrim(Str(nErro)), 2, 1) //"Erro ao atualizar o documento vinculado a fatura. Situacao: "
							lErro := .T.
							Exit
						EndIf
					EndIf
					//-- PE -> Atualiza campos do usuario
					If lTM491CPO						
						ExecBlock('TM491CPO',.F.,.F., {2,aDoctosMrk[nX][IIf(IsInCallStack("TMSA491"),LARECNO,RECNOCTRC)],cAliasTRB,,cFatura,} )
					EndIf
				Endif	
				//-- Acumulo dos valores de Acrescimo e Decrescimo para serem atualizados na tabela DRT.
				nAcresc  += aDoctosMrk[nX][ACRESC] 
				nDecresc += aDoctosMrk[nX][DECRESC]			
			Next nX
		
			//-- Posiciona no DT6 que foi gerado a partir dos documentos de apoio:
			DT6->(DbSetOrder(1))
			If !Empty(nRecDT6)
				DT6->(DbGoTo(nRecDT6))
				cFilDoc := DT6->DT6_FILDOC
				cDoc    := DT6->DT6_DOC
				cSerie  := DT6->DT6_SERIE
			EndIf
		
			cCliFat := Padr(IIF(Empty(cCliFat ),cCli  ,cCliFat ),Len(SA1->A1_COD ))
			cLojFat := Padr(IIF(Empty(cLojaFat),_cLoja,cLojaFat),Len(SA1->A1_LOJA))
			If !lErro
		
				IncProc(STR0019) //"Incluindo a fatura..."
				cQuery := " SELECT 1 FROM " + RetSqlName("DT6") + " DT6 "
				cQuery += " WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
				cQuery += " AND DT6_PREFIX = '" + Space(TamSX3("E1_PREFIXO")[2]) + "' "
				cQuery += " AND DT6_NUM    = '" + cFatura + "' "
				cQuery += " AND DT6_TIPO   = '" + Space(TamSX3("E1_TIPO")[2])   + "' "
				cQuery += " AND D_E_L_E_T_ = ' ' "
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
				lAchou := (cAliasQry)->(!Eof())
				(cAliasQry)->(DbCloseArea())
				
				If lAchou
		
					//-- Problema de performace no cliente.
					RegToMemory('DRT',.T.)
					M->DRT_FILIAL := xFilial('DRT')
					M->DRT_NUM    := Pad(cFatura, Len(DRT->DRT_NUM))
					M->DRT_STATUS := Iif(lDocApoio,"8","1") //-- 1-Fatura integrada; 8-Fatura Apoio Nao Integrada
					M->DRT_DTVENC := dVencFat
					M->DRT_DTEMIS := dEmisFat
					M->DRT_CLIFAT := cCliFat
					M->DRT_LOJFAT := cLojFat
					M->DRT_MOEDA  := nMoedFat
					M->DRT_VALOR  := nValor
					M->DRT_FILDOC := cFilDoc
					M->DRT_DOC    := cDoc
					M->DRT_SERIE  := cSerie
					M->DRT_FILDEB := cFilDeb
					M->DRT_DECRES := nDecresc 
					M->DRT_ACRESC := nAcresc
					M->DRT_CODUSR := RetCodUsr()
	
					//-- PE -> Atualiza campos do usuario
					If lTM491CPO
						aCposUsr := ExecBlock('TM491CPO',.F.,.F., {3,cAliasTRB,Space(TamSX3("E1_PREFIXO")[2]),Pad(cFatura, Len(DRT->DRT_NUM)),Space(TamSX3("E1_TIPO")[2])} )
						If ValType(aCposUsr) <> 'A'
							aCposUsr := {}
						EndIf
						For nCnt := 1 To Len(aCposUsr)
							M->&(aCposUsr[nCnt,1]) := aCposUsr[nCnt,2]
						Next nCnt
					EndIf
					
					nRecDRT := 0
					
					DbSelectArea("DRT")
					RecLock('DRT',IIf(nOPc==3,.T.,.F.))
					
					For nXCont:=1 TO FCount()
						If "FILIAL"$Field(nXCont)
							FieldPut(nXCont,xFilial("DRT"))
						Else
							If Type("M->"+FieldName(nXCont)) <> "U"
								FieldPut(nXCont,M->&(FieldName(nXCont)))
							EndIf
						EndIf
					Next nXCont
					nRecDRT := DRT->(Recno())
					DRT->(MsUnLock())
		
					//-- PE -> Apos geracao de fatura
					If lTM851CPO
						ExecBlock('TM851CPO',.F.,.F.)
					EndIf
				ElseIf !lAchou
					Help(" ", 1, "TMSA85103", , STR0020, 2, 1) //"Erro ao atualizar docto.... Erro : "
					lErro := .T.
					DisarmTransaction()
				EndIf
		
				//-- PE -> Apos gravacao da fatura
				If lTM851ITE
					ExecBlock('TM851ITE',.F.,.F.)
				EndIf
				
				//-- Integracao com o contas a receber
				If !lErro
					lRet:= .T.  
					If !lDocApoio 
						If ExistFunc('FwHasEAI') .And. FWHasEAI('TMSA851',.T.,,.T.)
							IncProc(STR0026) // "Integrando com o contas a receber..."
							lRet:= Tmsa851Int(nRecDRT, @aErrosInt)
						EndIf	
					EndIf
					If lRet .And. lTMSFMSG //-- Armazena as Faturas geradas para apos o final do processamento exibir um resumo para o usuario:
						AAdd( aFtGeradas, {STR0023 + cFatura} ) //-- 'Fatura Gerada:'
					EndIf	
				EndIf	
			Else
				DisarmTransaction()
			EndIf
		Else
			DisarmTransaction()
		EndIf
	
	End Transaction

Return aFtGeradas

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T851ProcExc
Processa a exclusao dos documentos de uma fatura
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [aDoctos], Array, Documentos excluídos
@param [nTotExcluido], Numérico, Total das Exclusoes
@param [nTotFat], Numérico, Total das Faturas (SEM USO)
@param [aVFContr], Array, Array contendo os Valores (Liquido/Impostos/Bruto)
@param [lAnulacao], Lógico, Anulação?
@return lMsErroAuto Retorno lógico
/*/
//-------------------------------------------------------------------------------------------------
Function T851ProcExc(aDoctos, nTotExcluido, nTotFat, aVFContr, lAnulacao, lDoctoApoio,cFilDoc,cDoc,cSerie)

	Local cNum        := ""
	Local cCliente    := ""
	Local cLoja       := ""
	Local nLen        := Len(aDoctos)
	Local lAtuDcApoio := .F.
	Local lRet        := .T.	
	Local nX          := 0
	Local nApag       := 0
	Local aDoctosAnt  := AClone(aDoctos)
	Local nRecDRT     := 0
	Local lCancelar   := .F.
	Local cHistor     := ""

	PRIVATE lMsErroAuto := .F.
	
	DEFAULT lAnulacao   := .F.
	DEFAULT lDoctoApoio := .F.
	
	ProcRegua(nLen)
	
	Begin Transaction
	
		IncProc()
		lCancelar := .F.
		
		IncProc(STR0027) // "Cancelando titulos no contas a receber..."
		nRecDRT := DRT->(Recno())
		If !lDoctoApoio .And. ! Tmsa851Int(nRecDRT)
			DisarmTransaction()
			lRet:= .F.
			Break
		Else
			lCancelar := .T.
		EndIf
	
		If lCancelar
		
			cNum     := DRT->DRT_NUM
			cCliente := DRT->DRT_CLIFAT
			cLoja    := DRT->DRT_LOJFAT
			
			RecLock('DRT',.F.)
			DRT->DRT_STATUS := '5' //-- Fatura cancelada
			DRT->DRT_DTCANC := dDataBase
			cHistor := ""
			If ! Empty(DRT->DRT_CODHIS)
				cHistor := MSMM(DRT->DRT_CODHIS)
			Endif
			cHistor += chr(10) + chr(10) + STR0024 // "Titulos cancelados no contas a receber!"
			MSMM(Iif(!Empty(DRT->DRT_CODHIS),DRT->DRT_CODHIS,),80,,cHistor,1,,,"DRT","DRT_CODHIS")
			DRT->(MsUnLock())
		EndIf
		
		For nX := 1 To nLen
			IncProc()
	
			If aDoctos[nX][MARCA]
				
				DT6->(MsGoto(aDoctos[nX, LARECNO]))
					
				//--Verifica se o cancelamento esta sendo realizado em cima de um documento de apoio.
				//--Esta verificacao eh realizada para tratamento no cancelamento parcial. Quando houver
				//--um cancelamento parcial de uma fatura que foi gerada a partir de documentos de apoio,
				//--permite somente remover os documentos selecionados da fatura. Nao sera alterado o titulo
				//--a receber e o novo documento gerado a partir da geracao da fatura.
				lAtuDcApoio := DT6->DT6_DOCTMS $ "|B|C|H|I|N|O|" .And. !Empty(Posicione('DUI',1,xFilial('DUI')+DT6->DT6_DOCTMS,'DUI_DOCFAT'))
	
	
				//--Grava DVV somente se:
				//-- *A fatura gerada NAO foi a partir de documentos de apoio 
				//-- *Se for documento de apoio e estiver sendo realizado um cancelamento parcial da fatura
				If !lAtuDcApoio .Or. ( lAtuDcApoio .And. nQtdCtrc > 0 )
					RecLock("DVV", .T.)
					DVV->DVV_FILIAL := xFilial("DVV")
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
	
	
				//--Reabre CTRC para ser utilizado em outra fatura futuramente
				RecLock("DT6")
				DT6->DT6_PREFIX := ""
				DT6->DT6_NUM    := ""
				DT6->DT6_TIPO   := ""
				DT6->DT6_VENCTO := CToD("")
				DT6->DT6_ACRESC := 0
				DT6->DT6_DECRES := 0
				DT6->(MsUnlock())
	
				//-- PE -> Complementar a gravacao de alguns campos do DT6 e DVV
				//-- Os campos DT6_ACRESC e DT6_DECRES serao zerados no programa padrao e deverao, se for o caso,
				//-- serem atualizados pelo ponto de entrada
				If lTM851GRV
					ExecBlock( "TM851GRV", .F., .F., aDoctos )
				EndIf
			EndIf
		Next nX		
	
		//-- Deleta os Doc. 
		If lDoctoApoio .And. !Empty(cDoc)
			TMSA491CDoc(cFilDoc,cDoc,cSerie) 
		EndIf

		For nX := 1 To nLen
			nApag := aScan(adoctos, {|nX| nX[1] ==.T.})
			If nApag > 0
				Adel(aDoctos,nApag)
				Asize(aDoctos, Len(aDoctos)-1)
			EndIf
		Next nX
	
		nQtdCtrc := Len(aDoctos)
	
	End Transaction
	
	If !lRet
		Return .F.
	EndIf
	
	//-- PE -> Apos exclusao documentos da fatura
	If lTM851EXC
		ExecBlock("TM851EXC", .F., .F., {cCliente, cLoja, , cNum, aDoctosAnt})
	EndIf

Return( !lMsErroAuto )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa851Int
Chamada da integração: Fatura x Contas a Receber
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [nRecDRT], Numérico, RECNO do registro da fatura
@param [aErrosInt], Array, Execução via schedule
@return Nil Não há retorno
/*/
//-------------------------------------------------------------------------------------------------
Static Function Tmsa851Int(nRecDRT, aErrosInt)

	Local aArea    := GetArea()
	Local aAreaDRT := DRT->(GetArea())
	Local aRetEAI  := {}
	Local lRet     := .T.
	Local cMsgErr  := ""
	Local cFilial  := DRT->DRT_FILIAL
	Local cNum     := DRT->DRT_NUM
	
	Default aErrosInt := {}
	
	SetRotInteg("TMSA851")
	aRetEAI := FwIntegDef("TMSA851") //-- Integracao

	If ! Empty(aRetEAI) .And. Len(aRetEAI) >= 1
		If ! aRetEAI[1] //-- Mensagem processada com erro

			cMsgErr := " (" + STR0028 + ": " + AllTrim(cFilial) + AllTrim(cNum) + ") "
			cMsgErr += chr(10) + chr(10) + aRetEAI[2]
			Aadd(aErrosInt, cMsgErr)
			Help(" ", , "TMSA85104", , cMsgErr, 2, 1)
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaDRT)
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} IntegDef
Integração SIGATMS x Contas a Receber: chamada do adapter para processamento da mensagem
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [cXml], Caracter, XML recebido pelo EAI Protheus
@param [cType], Caracter, Tipo de transação
@param [cTypeMessage], Caracter, Tipo da mensagem do EAI
@param [cVersion], Caracter, Versão da Mensagem Única TOTVS
@param [cTransaction], Caracter, Nome da mensagem iniciada no adapter
@return Array Informações de retorno
@obs Informações de retorno:
@obs Array[1] - Processamento foi executado com sucesso (.T.) ou não (.F.)
@obs Array[2] - Uma string contendo informações sobre o processamento
@obs Array[3] - Uma string com o nome da mensagem única desta mensagem
/*/
Static Function IntegDef(cXml, cType, cTypeMessage, cVersion, cTransaction)

Local aRet      := {}

aRet := TMSI851(cXml, cType, cTypeMessage, cVersion, cTransaction)

Return aRet
