#INCLUDE "OMSA320.CH"
#INCLUDE "PROTHEUS.CH"

//-----------------------------------------------------------
/*/{Protheus.doc} OMSA320
Programa de Retorno do carregamento
@author Henry Fila
@Since 10/05/2001
/*/
//-----------------------------------------------------------
Function OMSA320()
Local cCondicao    := ""
Local aCores       := {	{ 'DAK_ACECAR=="2"' , 'BR_VERDE' 	},; //-- "Em Aberto"
						{ 'DAK_ACECAR=="1"' , 'BR_VERMELHO' } } //-- "Processado"

Private lCriaInd   := .T.
Private nIndSd1    := 0
Private bFiltraBrw := {|| Nil}
Private cCadastro  := OemtoAnsi(STR0001) //"Retorno de Cargas"
Private aRotina    := MenuDef()

If (AMIIn(5,39)) // SigaFat - SigaOms

	//Carrega as Perguntas.
	dbSelectArea("DAK")
	dbSetOrder(1)

	cCondicao := " DAK_FEZNF = '1' And DAK_FILIAL = '"+xFilial("DAK")+"'"

	If ExistBlock("OM320FIL")
		cCondicao += " And "+ExecBlock("OM320FIL",.F.,.F.)
	EndIf

	mBrowse(6,1,22,75,"DAK",,,,,,aCores,,,,,,,,cCondicao)

	Set Key VK_F12 To
	dbSelectArea("DAK")
	RetIndex("DAK")
	dbClearFilter()

EndIf

Return (.T.)

//-----------------------------------------------------------
/*/{Protheus.doc} OMSA320MAN
otina de manutencao do retorno de carga
@author Henry Fila
@Since 08/08/2001
@params ExpC1: Alias da tabela de carga
ExpN2: Numero do Registro
ExpN3: Opcao do aRotina
@description Esta rotina tem como objetivo realizar o retorno da carga
a partir de uma nota fiscal de saida.
/*/
//-----------------------------------------------------------
Function Oms320Man(cAlias,nReg,nOpcX)
Local aArea      := GetArea()
Local aPosObj    := {}
Local aObjects   := {}
Local aSize      := {}
Local aInfo      := {}
Local aButtons   := {}
Local aButtonUsr := {}
Local aCpoEnable := { "F2_DTENTR" }
Local aCpoUsr    := {}
Local aRecSF2    := {}
Local lRetParc   := SuperGetMV("MV_OMSRETP", .F., .F.) // Permite efetuar retorno da carga parcial conforme informada as datas de entrega das notas.
Local lAltStat   := .T.
Local cCodCarga  := DAK->DAK_COD
Local cSeqCarga  := DAK->DAK_SEQCAR
Local cQuery     := ""
Local cAliasSF2  := "SF2"
Local cCondicao  := ""
Local cIndSF2    := ""
Local cSF2Cpo    := ""
Local dDataGer   := DAK->DAK_DATA
Local lQuery    := .F.

Local nOpcA      := 0
Local nUsado     := 0
Local nX         := 0
Local nI         := 0
Local nTipoOper  := OsVlEntCom()
Local nPosCpo    := 0
Local lTabDFI    := AliasIndic("DFI")
Local oStructSF2 := Nil
Local aFieldsSF2 := {}
Local aNoFields  := {}
Local nIndex     := 5
Local cSeek      := NIL
Local cWhile     := ""
Local bCond      := {|| .T.} // Se bCond .T. executa bAction1, senao executa bAction2
Local bAction1 := {|| Oms320Rec(@aRecSF2,lQuery,cAliasSF2) } // Retornar .T. para considerar o registro e .F. para desconsiderar
Local bAction2   := {|| .F.} // Retornar .T. para considerar o registro e .F. para desconsiderar

Local oDlg
Local oGetD

PRIVATE aHeader := {}
PRIVATE aCols   := {}

If nOpcX == 3
	aButtons  := {{ "RECALC" ,	{ || Oms320Dev("D") },OemToAnsi(STR0011),OemToAnsi(STR0024)},; //"Devolucao/Retorno do Documento de Saida"##"Devol."
					{ "RECALC" ,	{ || Oms320Dev("B") },OemToAnsi(STR0011),OemToAnsi(STR0040)},; //"Retorno do Documento de Saida"##"Benefic."
					{ "EXCLUIR",	{ || Oms320Del() },OemToAnsi(STR0012),OemToAnsi(STR0025)},; //"Exclusao das notas de devolucao"##"Exclusao"
					{ "PESQUISA",	{ || GdSeek(oGetD,OemtoAnsi(STR0002),,,.T.)},OemToAnsi(STR0002),OemToAnsi(STR0002)},; //"Pesquisa"
					{ "CLOCK02",	{ || Oms320Ap()  },OemToAnsi(STR0023),OemToAnsi(STR0026)} } //"Apontamento da Janela de Entregas"##"Apont."
EndIf
// Verifica se ja foi prestado conta da carga
If DAK->DAK_ACECAR == "2" .Or. nOpcX == 2

	If ExistBlock("OS320BTN")
		aButtonUsr := ExecBlock("OS320BTN",.F.,.F.)
		If ValType(aButtonUsr) == "A"
			For nI := 1 To Len(aButtonUsr)
				aAdd(aButtons,aClone(aButtonUsr[nI]))
			Next
		EndIf
	EndIf

	oStructSF2 := FwFormStruct(1,"SF2")
	aFieldsSF2 := oStructSF2:GetFields()
	AEval(aFieldsSF2,{|x| Iif(x[4] == "M",AAdd(aNoFields,x[3]),.T.)})
	AEval(aFieldsSF2,{|x| Iif(x[14] == .F.,cQuery += "SF2." + x[3] + ",", .T.)})
	cAliasSF2 := GetNextAlias()

 	cQuery := "SELECT " + cQuery + " R_E_C_N_O_, SF2.R_E_C_N_O_ SF2RECNO "
	cQuery += "FROM " + RetSqlName("SF2")+" SF2 "
	cQuery += "WHERE "

	//Verifica o tipo de operacao logistica para trazer outras filiais
	If	nTipoOper == 1
		cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND "
	EndIf
	cQuery += "SF2.F2_CARGA  = '"+cCodCarga+"' AND "
	cQuery += "SF2.F2_SEQCAR = '"+cSeqCarga+"' AND "
	cQuery += "SF2.D_E_L_E_T_= ' ' "
	cQuery += "ORDER BY "+SqlOrder(SF2->(IndexKey()))
	cQuery := ChangeQuery(cQuery)

	//-- Ponto de entrada para permitir editar campos especificos.
	If	ExistBlock("OM320CPO")
		aCpoUsr := ExecBlock("OM320CPO",.F.,.F.)
		If	ValType(aCpoUsr) == "A"
			For nI := 1 To Len(aCpoUsr)
				aAdd(aCpoEnable,aCpoUsr[nI])
			Next
		EndIf
	EndIf

	// Montagem do aHeader e aCols
	//FillGetDados( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, uSeekFor, aNoFields, aYesFields, lOnlyYes,
	//               cQuery, bMountFile, lInclui )
	//nOpcx        - Opcao (inclusao, exclusao, etc).
	//cAlias       - Alias da tabela referente aos itens
	//nOrder       - Ordem do SINDEX
	//cSeekKey     - Chave de pesquisa
	//bSeekWhile   - Loop na tabela cAlias
	//uSeekFor     - Valida cada registro da tabela cAlias (retornar .T. para considerar e .F. para desconsiderar
	//               o registro)
	//aNoFields    - Array com nome dos campos que serao excluidos na montagem do aHeader
	//aYesFields   - Array com nome dos campos que serao incluidos na montagem do aHeader
	//lOnlyYes     - Flag indicando se considera somente os campos declarados no aYesFields + campos do usuario
	//cQuery       - Query para filtro da tabela cAlias (se for TOP e cQuery estiver preenchido, desconsidera
	//	              parametros cSeekKey e bSeekWhile)
	//bMountFile   - Preenchimento do aCols pelo usuario (aHeader e aCols ja estarao criados)
	//lInclui      - Se inclusao passar .T. para qua aCols seja incializada com 1 linha em branco
	//aHeaderAux   -
	//aColsAux     -
	//bAfterCols   - Bloco executado apos inclusao de cada linha no aCols
	//bBeforeCols  - Bloco executado antes da inclusao de cada linha no aCols
	//bAfterHeader -
	//cAliasQry    - Alias da Query
	Aadd(aHeader,{RTrim(RetTitle("F2_FILIAL")),"F2_FILIAL","@!",1,0,"AllwaysTrue()","û","C","SF2","" } )
	FillGetDados	(2,					"SF2",							nIndex,			cSeek,;
					{|| &cWhile },		{{bCond,bAction1,bAction2}},	aNoFields,	/*aYesFields*/,;
					/*lOnlyYes*/,		cQuery,							/*bMontCols*/,	/*lEmpty*/,;
					/*aHeaderAux*/,		/*aColsAux*/,					/*bAfterCols*/,	/*bBeforeCols*/,;
					/*bAfterHeader*/,	cAliasSF2,						/*bCriaVar*/)
	If !lQuery
		dbSelectArea("SF2")
		RetIndex("SF2")
		dbClearFilter()
		FErase(cIndSF2+OrdBagExt())
	EndIf

	// Verifica se ha notas a serem exibidas
	If	Len(aCols) <> 0

		aSize := MsAdvSize()
		aAdd(aObjects, { 100, 020, .T., .F. })
		aAdd(aObjects, { 100, 100, .T., .T. })
		aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 5, 5}
		aPosObj := MsObjSize(aInfo, aObjects,.T.)

		DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0006) From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL //"Notas Fiscais da Carga

			@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL "" OF oDlg PIXEL

			@ aPosObj[1,1]+05,aPosObj[1,2]+02 SAY FWX3Titulo("DAK_COD") SIZE 50,7 OF oDlg PIXEL
			@ aPosObj[1,1]+05,aPosObj[1,2]+32 MsGet cCodCarga PICTURE "@!" WHEN .F. SIZE 30,7 OF oDlg PIXEL
			@ aPosObj[1,1]+05,aPosObj[1,2]+62 MsGet cSeqCarga WHEN .F. SIZE 20,7 OF oDlg PIXEL

			@ aPosObj[1,1]+05,aPosObj[1,2]+92 SAY FWX3Titulo("DAK_DATA") SIZE 50,7 OF oDlg PIXEL
			@ aPosObj[1,1]+05,aPosObj[1,2]+107 MsGet dDataGer PICTURE X3Picture("DAK_DATA") WHEN .F. SIZE 40,7 OF oDlg PIXEL

			oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"Oms320LOk()","Oms320TOk()",,.F.,aCpoEnable,1,,9999)

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetd:TudoOk(),(nOpcA := 1,oDlg:End()),nOpcA := 0)},{||oDlg:End()},,aButtons)

		If	nOpcA == 1 .And. nOpcX == 3
			//-- Parametro MV_OMSRETP: Verifica se existe nota sem data de entrega.
			If lRetParc
				nPosCpo := Ascan(aHeader,{|x| Alltrim(x[2]) == "F2_DTENTR"})
				If	nPosCpo > 0
					For nI := 1 to Len(aCols)
						If Empty(aCols[nI][nPosCpo])
							lAltStat := .F. //-- Nao alterar status da carga se existe nota sem data de entrega
							Exit
						EndIf
					Next nI
					If !lAltStat
						MsgAlert("Status da carga não sera alterado. Existem notas sem data de entrega informado.", "Retorno de Carga parcial")
					EndIf
				EndIf
			EndIf

			Begin Transaction
				//-- Atualiza campo de entrega real da nota fiscal + editaveis especificos.
				For nI := 1 to Len(aCols)
					SF2->(MsGoto(aRecSF2[nI]))
					RecLock("SF2",.F.)
					For nX := 1 To Len(aCpoEnable)
						cSF2Cpo := aCpoEnable[nX]
						nPosCpo := Ascan(aHeader,{|x| Alltrim(x[2]) == cSF2Cpo})
						If	nPosCpo > 0
							&cSF2Cpo := aCols[nI][nPosCpo]
						EndIf
					Next nX
					MsUnLock()
				Next nI

				If lAltStat
					//-- Flag de Retorno de Carga
					OsAvalDAK("DAK",5)
				EndIf

				If ExistBlock("OM320GRV")
					ExecBlock("OM320GRV",.F.,.F.)
				EndIf
			End Transaction

		EndIf
	Else
		If	lTabDFI
			//Com a nova implementacao preciso encerrar a carga, mesmo que nao exista SF2, pois
			//--pode ocorrer de todas as notas da carga ja estar em outra devido a reentrega
			OsAvalDAK("DAK",5)
		Else
			Help(" ",1,"OMS320NONF")
		EndIf
	EndIf
Else
	Help(" ",1,"OMS320JAAC") //Carga ja encerrada
EndIf
MbrChgLoop() //nao chama a tela de inclusao novamente
RestArea(aArea)
Return(.T.)

//-----------------------------------------------------------
/*/{Protheus.doc} Oms320LOk
Validacao de digitacao de linha
@author VICCO
@Since 22/07/2008
/*/
//-----------------------------------------------------------
Function Oms320LOk()
Local lRet   := .T.
Local lRetPE := .T.
If	ExistBlock("OM320LOK")
	lRetPE := ExecBlock("OM320LOK",.F.,.F.,{lRet})
	lRet   := If(ValType(lRetPE)=="L",lRetPE,lRet)
EndIf
Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} Oms320TOk
Validacao de confirmacao para gravacao
@author VICCO
@Since 22/07/2008
/*/
//-----------------------------------------------------------
Function Oms320TOk()
Local lRet   := .T.
Local lRetPE := .T.
If	ExistBlock("OM320TOK")
	lRetPE := ExecBlock("OM320TOK",.F.,.F.)
	lRet   := If(ValType(lRetPE)=="L",lRetPE,lRet)
EndIf
Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} Oms320DEV
Rotina de carregamento dos dados da nota fiscal selecionada
@author Henry Fila
@Since 08/08/2001
@Description Esta rotina tem como objetivo realizar o carregamento dos
dados necessarios para efetuar e devolucao da nota fiscal de saida.
/*/
//-----------------------------------------------------------
Static Function Oms320Dev(cTipo)
Local aArea     := GetArea()
Local aAreaSF2  := SF2->(GetArea())
Local aCab      := {}
Local aLinha    := {}
Local aItens    := {}
Local aStruSD2  := {}
Local aColsLoc  := aClone(aCols)
Local aHeaderLoc:= aClone(aHeader)

Local cQuery    := ""
Local cAliasSD2 := "SD2"
Local cFilOri   := cFilAnt
Local cTipoNf   := ""

Local nPCliente := aScan( aHeader, { |x| AllTrim( x[2] ) == "F2_CLIENTE" } )
Local nPLoja    := aScan( aHeader, { |x| AllTrim( x[2] ) == "F2_LOJA"    } )
Local nPNFiscal := aScan( aHeader, { |x| AllTrim( x[2] ) == "F2_DOC"     } )
Local nPSerie   := aScan( aHeader, { |x| AllTrim( x[2] ) == "F2_SERIE"   } )
Local nPCond    := aScan( aHeader, { |x| AllTrim( x[2] ) == "F2_COND"    } )
Local nPFilial  := aScan( aHeader, { |x| AllTrim( x[2] ) == "F2_FILIAL"  } )
Local nPEspecie := aScan( aHeader, { |x| AllTrim( x[2] ) == "F2_ESPECIE" } )
Local nPosAcols := N
Local nX        := 0
Local nSldDev   := 0
Local lOM320LIN := ExistBlock("OM320LIN")

Local lDevolucao:= .T.
Local lQuery    := .F.

Default cTipo   := "D"

dbSelectArea("SF2")
dbSetOrder(1)
If	MsSeek(aCols[n][nPFilial]+aCols[n][nPNFiscal]+aCols[n][nPSerie]+aCols[n][nPCliente]+aCols[n][nPLoja]) .And.;
	SoftLock("SF2")
	// Montagem do Cabecalho da Nota fiscal de Devolucao/Retorno
	AAdd( aCab, { "F1_DOC"    , CriaVar("F1_DOC",.F.)	, Nil } )	// Numero da NF : Obrigatorio
	AAdd( aCab, { "F1_SERIE"  , CriaVar("F1_SERIE",.F.), Nil } )	// Serie da NF  : Obrigatorio
	AAdd( aCab, { "F1_TIPO"   , cTipo 					, Nil } )	// Tipo da NF   : Obrigatorio
	AAdd( aCab, { "F1_FORNECE", aCols[n][nPCliente]	, Nil } )	// Codigo do Fornecedor : Obrigatorio
	AAdd( aCab, { "F1_LOJA"   , aCols[n][nPLoja]   	, Nil } )	// Loja do Fornecedor   : Obrigatorio
	AAdd( aCab, { "F1_EMISSAO", dDataBase           	, Nil } )	// Emissao da NF        : Obrigatorio
	AAdd( aCab, { "F1_FORMUL" , "S"                 	, Nil } )  // Formulario
	If	cPaisLoc=="BRA"
		AAdd( aCab, { "F1_ESPECIE", aCols[n][nPEspecie] , Nil } )  // Especie
	Endif
	AAdd( aCab, { "F1_COND"   , aCols[n][nPCond]   	, Nil } )	// Condicao do Fornecedor
	// Montagem dos itens da Nota Fiscal de Devolucao/Retorno
	dbSelectArea("SD2")
	dbSetOrder(3)
	lQuery    := .T.
	cAliasSD2 := "Oms320Dev"
	aStruSD2  := SD2->(dbStruct())
	cQuery    := "SELECT SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, "
	cQuery    += "SD2.D2_LOJA, SD2.D2_QTDEDEV, SD2.D2_QUANT, SD2.D2_TOTAL, "
	cQuery    += "SD2.D2_DESCON, SD2.D2_DESCZFR, SD2.D2_TES, SD2.D2_TIPO, SD2.D2_COD, "
	cQuery    += "SD2.D2_IDENTB6, SD2.D2_PICM, SD2.D2_IPI, SD2.D2_LOCAL, SD2.D2_UM, "
	cQuery    += "SD2.D2_LOTECTL, SD2.D2_NUMLOTE, SD2.D2_ITEM, SD2.D2_CCUSTO, SD2.D2_CLVL, "
	cQuery    += "SD2.D2_CONTA, SD2.D2_ITEMCC, R_E_C_N_O_, R_E_C_N_O_ SD2RECNO "
	cQuery    += "FROM "+RetSqlName("SD2")+" SD2 "
	cQuery    += "WHERE SD2.D2_FILIAL='"+OsFilial("SD2",aCols[n][nPFilial])+"' AND "
	cQuery    += "SD2.D2_DOC = '"+SF2->F2_DOC+"' AND "
	cQuery    += "SD2.D2_SERIE = '"+SF2->F2_SERIE+"' AND "
	cQuery    += "SD2.D2_CLIENTE = '"+SF2->F2_CLIENTE+"' AND "
	cQuery    += "SD2.D2_LOJA = '"+SF2->F2_LOJA+"' AND "
	cQuery    += "SD2.D2_QTDEDEV < SD2.D2_QUANT AND "
	cQuery    += "SD2.D_E_L_E_T_=' ' "
	cQuery    += "ORDER BY "+SqlOrder(SD2->(IndexKey()))

	cQuery    := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)

	For nX := 1 To Len(aStruSD2)
		If aStruSD2[nX][2]<>"C"
			TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
		EndIf
	Next nX

	While !Eof() .And. (cAliasSD2)->D2_FILIAL == OsFilial("SD2",aCols[n][nPFilial]) .And.;
		(cAliasSD2)->D2_DOC == SF2->F2_DOC .And.;
		(cAliasSD2)->D2_SERIE == SF2->F2_SERIE .And.;
		(cAliasSD2)->D2_CLIENTE == SF2->F2_CLIENTE .And.;
		(cAliasSD2)->D2_LOJA == SF2->F2_LOJA

		If (cAliasSD2)->D2_QTDEDEV < (cAliasSD2)->D2_QUANT
			// Verifica se existe um tes de devolucao correspondente
			dbSelectArea("SF4")
			DbSetOrder(1)
			If MsSeek(OsFilial("SF4",aCols[n][nPFilial])+(cAliasSD2)->D2_TES)
				If Empty(SF4->F4_TESDV) .Or. !(SF4->(MsSeek(OsFilial("SF4",aCols[n][nPFilial])+SF4->F4_TESDV)))
					Help(" ",1,"DSNOTESDEV")
					lDevolucao := .F.
					Exit
				EndIf
			EndIf

			//Calcula o Saldo a devolver
			cTipoNF := (cAliasSD2)->D2_TIPO
			If	SF4->F4_PODER3=="D"
				nSldDev := CalcTerc((cAliasSD2)->D2_COD,(cAliasSD2)->D2_CLIENTE,(cAliasSD2)->D2_LOJA,(cAliasSD2)->D2_IDENTB6,(cAliasSD2)->D2_TES,cTipoNF)[1]
			Else
				nSldDev := (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
			EndIf

			//Efetua a montagem da Linha
			aLinha := {}
			AAdd( aLinha, { "D1_COD"    , (cAliasSD2)->D2_COD    , Nil } )
			AAdd( aLinha, { "D1_QUANT"  , (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV, Nil } )
			AAdd( aLinha, { "D1_VUNIT"  , ((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR)/(cAliasSD2)->D2_QUANT, Nil })

			If (cAliasSD2)->D2_QUANT==nSldDev
				AAdd( aLinha, { "D1_TOTAL"  , (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR,Nil } )
				AAdd( aLinha, { "D1_VALDESC", (cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR , Nil } )
			Else
				AAdd( aLinha, { "D1_TOTAL"  , A410Arred(aLinha[2][2]*aLinha[3][2],"D1_TOTAL"),Nil } )
				AAdd( aLinha, { "D1_VALDESC"  , A410Arred((cAliasSD2)->D2_DESCON/(cAliasSD2)->D2_QUANT*aLinha[2][2],"D1_VALDESC"),Nil } )
			EndIf

			AAdd( aLinha, { "D1_PICM"   , (cAliasSD2)->D2_PICM   , Nil } )
			AAdd( aLinha, { "D1_IPI"    , (cAliasSD2)->D2_IPI    , Nil } )
			AAdd( aLinha, { "D1_LOCAL"  , (cAliasSD2)->D2_LOCAL  , Nil } )
			AAdd( aLinha, { "D1_TES" 	, SF4->F4_CODIGO , Nil } )
			AAdd( aLinha, { "D1_CF" 	, SubStr("123",At(SubStr(SF4->F4_CF,1,1),"567"),1)+SubStr(SF4->F4_CF,2), Nil } )
			AAdd( aLinha, { "D1_UM"     , (cAliasSD2)->D2_UM , Nil } )
			If Rastro((cAliasSD2)->D2_COD)
				AAdd( aLinha, { "D1_LOTECTL", (cAliasSD2)->D2_LOTECTL, Nil } )
				AAdd( aLinha, { "D1_NUMLOTE", (cAliasSD2)->D2_NUMLOTE, Nil } )
			EndIf
			AAdd( aLinha, { "D1_NFORI"  , (cAliasSD2)->D2_DOC    , Nil } )
			AAdd( aLinha, { "D1_SERIORI", (cAliasSD2)->D2_SERIE  , Nil } )
			AAdd( aLinha, { "D1_ITEMORI", (cAliasSD2)->D2_ITEM   , Nil } )
			AAdd( aLinha, { "D1_IDENTB6", (cAliasSD2)->D2_IDENTB6, Nil } )
			AAdd( aLinha, { "D1_CC"     , (cAliasSD2)->D2_CCUSTO , Nil } )
			AAdd( aLinha, { "D1_CLVL"   , (cAliasSD2)->D2_CLVL   , Nil } )
			AAdd( aLinha, { "D1_CONTA"  , (cAliasSD2)->D2_CONTA  , Nil } )
			AAdd( aLinha, { "D1_ITEMCTA", (cAliasSD2)->D2_ITEMCC , Nil } )
			AAdd( aLinha, { "D1RECNO",    Iif(lQuery,(cAliasSD2)->SD2RECNO,(cAliasSD2)->(RECNO()) ), Nil } )

			If lOM320LIN
				aLinha := Execblock("OM320LIN",.F.,.F.,aLinha)
			EndIf

			AAdd( aItens, aLinha)
		EndIf

		dbSelectArea(cAliasSD2)
		dbSkip()
	EndDo
	If	lQuery
		dbSelectArea(cAliasSD2)
		dbCloseArea()
		dbSelectArea("SD2")
	EndIf
	If	lDevolucao
		//Verifica se ha itens a serem devolvidos
		If	Len(aItens)>0
			cFilAnt := aCols[n][nPFilial]

			If cPaisLoc != "BRA"
				OmsDevLoc(SF2->F2_ESPECIE,aCab,aItens)
			Else
				Mata103( aCab, aItens,3,.T. )
			EndIf
			cFilAnt := cFilOri

			aCols   := aClone(aColsLoc)
			aHeader := aClone(aHeaderLoc)
			n       := nPosACols
			//Executa ponto de entrada apos o termino da nota fiscal
			If	ExistBlock("OM320DEV")
				dbSelectArea("SF2")
				dbSetOrder(1)
				MsSeek(aCols[n][nPFilial]+aCols[n][nPNFiscal]+aCols[n][nPSerie]+aCols[n][nPCliente]+aCols[n][nPLoja])

				ExecBlock("OM320DEV",.F.,.F.)
			EndIf
		Else
			Help(" ",1,"OMS320NFD") //Nota Fiscal de devolucao ja gerada
		EndIf
	EndIf
EndIf
//Restaura a entrada da rotina
MsUnLockAll()

RestArea(aAreaSF2)
RestArea(aArea)
Return(.T.)

//-----------------------------------------------------------
/*/{Protheus.doc} Oms320Del
Rotina de estorno do retorno de carga
@author Henry Fila
@Since 08/08/2001
@Description Esta rotina tem como objetivo realizar o carregamento dos
dados necessarios para efetuar e devolucao da nota fiscal de saida.
/*/
//-----------------------------------------------------------
Function Oms320Del()

Local aArea      := GetArea()
Local aNfOri     := {}
Local nPosNFis   := aScan( aHeader, { |x| AllTrim( x[2] ) == "F2_DOC"   } )
Local nPosSerie  := aScan( aHeader, { |x| AllTrim( x[2] ) == "F2_SERIE" } )
Local nPosFilial := aScan( aHeader, { |x| AllTrim( x[2] ) == "F2_FILIAL"} )
Local cAliasSA1  := "SA1"
Local cAliasSD1  := "SD1"
Local cAliasSF1  := "SF1"
Local cSavFil    := cFilAnt
//Verifica a filial da nota Fiscal de saida
If nPosFilial > 0
	cFilAnt := aCols[n][nPosFilial]
EndIf
//Verifica se necessita criar o indice por nota original no SD1

cAliasSD1 := "TMPSF1"

cQuery := "SELECT D1_FILIAL,D1_NFORI,D1_SERIORI,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_TIPO,F1_TIPO,A1_NOME,SF1.R_E_C_N_O_ SF1RECNO "

cQuery += "FROM "+RetSqlName("SD1")+" SD1, "
cQuery += RetSqlName("SF1")+" SF1, "
cQuery += RetSqlName("SA1")+" SA1 "
cQuery += "WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
cQuery += "SD1.D1_NFORI = '"+aCols[n][nPosNFis]+"' AND "
cQuery += "SD1.D1_SERIORI = '"+aCols[n][nPosSerie]+"' AND "
cQuery += "SD1.D_E_L_E_T_=' ' AND "

cQuery += "SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND "
cQuery += "SF1.F1_DOC = SD1.D1_DOC AND "
cQuery += "SF1.F1_SERIE = SD1.D1_SERIE AND "
cQuery += "SF1.F1_FORNECE = SD1.D1_FORNECE AND "
cQuery += "SF1.F1_LOJA = SD1.D1_LOJA AND "
cQuery += "SF1.F1_TIPO = SD1.D1_TIPO AND "
cQuery += "SF1.D_E_L_E_T_=' ' AND "

cQuery += "SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "
cQuery += "SA1.A1_COD  = SF1.F1_FORNECE AND "
cQuery += "SA1.A1_LOJA = SF1.F1_LOJA AND "
cQuery += "SA1.D_E_L_E_T_=' ' "

cQuery += "GROUP BY D1_FILIAL,D1_NFORI,D1_SERIORI,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_TIPO,F1_TIPO,A1_NOME,SF1.R_E_C_N_O_"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)

cAliasSA1  := "TMPSF1"
cAliasSD1  := "TMPSF1"
cAliasSF1  := "TMPSF1"

//Varre a notas orginais para trazer para selecao
	While !Eof() .And. (cAliasSD1)->D1_FILIAL+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI == ;
		xFilial("SD1")+aCols[n][nPosNFis]+aCols[n][nPosSerie]

		If aScan(aNfOri,{|x| x[1]+x[2]+x[3]+x[4] == (cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA}) == 0 .And.;
			(cAliasSD1)->D1_TIPO == "D"
			Aadd(aNfOri,{(cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,(cAliasSA1)->A1_NOME,Iif(lQuery,(cAliasSD1)->SF1RECNO,(cAliasSF1)->(Recno()))})
		EndIf
		dbSelectArea(cAliasSD1)
		dbSkip()
	Enddo

Do Case
	//Qdo existir apenas uma nota fiscal de devolucao
	Case Len(aNfOri) == 1
		SF1->(MsGoto(aNfOri[1,6]))
		If cPaisLoc != "BRA"
			NFxExclui("SF1",,SF1->(Recno()))
		Else
			Mata103(,,5,.T.)
		EndIf

	//Qdo existir diversas notas de devolucao deve haver intervencao do usuario
	Case Len(aNfOri) > 1
		DEFINE MSDIALOG oDlgDev FROM 009, 000 TO 28,80 TITLE OemtoAnsi(STR0020) OF oMainWnd //"Notas Fiscais Devolvidas"

			@ 015,005 LISTBOX oNfOri VAR cVar Fields HEADER OemtoAnsi(STR0015),;  //"Nota Fiscal"
															OemtoAnsi(STR0016),; //"Serie"
															OemtoAnsi(STR0017),; //"Cliente"
															OemtoAnsi(STR0018),; //"Loja"
															OemtoAnsi(STR0019) ; //"Nome"
															SIZE 300,120 OF oDlgDev PIXEL
			oNfOri:SetArray(aNfOri)
			oNfOri:bLine:={ ||{aNfOri[oNfOri:nAT,1],;
								aNfOri[oNfOri:nAT,2],;
								aNfOri[oNfOri:nAT,3],;
								aNfOri[oNfOri:nAT,4],;
								aNfOri[oNfOri:nAT,5]}}
			oNfOri:Refresh()
		If cPaisLoc != "BRA"
			bButtonOk := { || NFxExclui("SF1",,aNfOri[oNfOri:nAT,6]),oDlgDev:End()}
		Else
			bButtonOk := { || SF1->(MsGoto(aNfOri[oNfOri:nAT,6])),Mata103(,,5,.T.),oDlgDev:End()}
		EndIf

		ACTIVATE MSDIALOG  oDlgDev ON INIT EnchoiceBar( oDlgDev, bButtonOk , {||oDlgDev:End()}) CENTERED
	//Qdo nao existir nota fiscal de devolucao
	Case Len(aNfOri) == 0
		Help(" ",1,"OMS320NODV")
EndCase

dbSelectArea(cAliasSD1)
dbCloseArea()

//Restaura a integridade da rotina
cFilAnt := cSavFil
RestArea(aArea)
Return(.T.)

//-----------------------------------------------------------
/*/{Protheus.doc} Oms320Est
Rotina de estorno do retorno de carga
@author Henry Fila
@Since 08/08/2001
/*/
//-----------------------------------------------------------
Function Oms320Est()
Local aArea := GetArea()
Local lTabDFI := AliasIndic("DFI")
Local lRet    := .T.
Local cTipUso := "2" //--Carga

If DAK->DAK_ACEFIN == "1" .Or. DAK->DAK_ACEFIN == "3"
	Help(" ",1,"OMS320JAFIN") //"Acerto financeiro ja efetuado"
	lRet := .F.
EndIf

If DAK->DAK_ACECAR == "2"
	MsgAlert(STR0038,STR0039) //"Retorno de carga não efetuado !"##"Estorno de retorno de carga"
	lRet := .F.
EndIf

If lRet .And. lTabDFI
	DTY->(dbSetOrder(5))
	If DTY->(dbSeek(xFilial("DTY")+cTipUso+DAK->DAK_IDENT))
		MsgAlert(STR0030) //"Contrato de Carreteiro gerado, nao e permitido Estornar o Retorno da Carga"
		lRet := .F.
	EndIf
EndIf

If lRet .And. MsgYesNo(OemtoAnsi(STR0007)) //"Confirma o estorno do retorno da carga ?"
	Begin Transaction

		If lRet
			OsAvalDAK("DAK",6)
		EndIf

		If ExistBlock("OM320EST")
			ExecBlock("OM320EST",.F.,.F.)
		EndIf

	End Transaction
EndIf
RestArea(aArea)
Return

//-----------------------------------------------------------
/*/{Protheus.doc} Oms320Ap
Rotina de apontamento de entrega da carga
@author Henry Fila
@Since 08/08/2001
/*/
//-----------------------------------------------------------
Static Function Oms320Ap()

Local aArea     := GetArea()
Local aAreaDAI  := DAI->(GetArea())
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aRecno    := {}

Local nPosCli   := 0
Local nPosLoja  := 0
Local nPosHrChg := 0
Local nPosTmSrv := 0
Local nPosHrSai := 0
Local nPosSeq   := 0
Local nUsado    := 0
Local nPosChgRea:= 0
Local nPosTmRea := 0
Local nPosSdRea := 0
Local nOpca     := 0
Local nCntFor   := 0
Local nCntFor2  := 0
Local nPosCols  := 0

Local cSeek     := ""
Local cWhile    := ""

Private aHeader := {}
Private aCols   := {}

//Verifica se ja foi efetuado o apontamento da carga
DAH->(dbSetOrder(1))
If DAH->(MsSeek(xFilial("DAH")+DAK->DAK_COD+DAK->DAK_SEQCAR))
	cSeek  := xFilial("DAH")+DAK->DAK_COD+DAK->DAK_SEQCAR
	cWhile := "DAH->DAH_FILIAL+DAH->DAH_CODCAR+	DAH->DAH_SEQCAR"
	FillGetDados(2,"DAH",1,cSeek,{|| &cWhile },{||.T.},/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,{|x| Oms320ACol(x,@aRecno)},/*bBeforeCols*/)
Else

	// Apenas monta o aHeader, o aCols sera preenchido manualmente pois existem linhas
	// que podem ser aglutinadas por cliente
	FillGetDados(3,"DAH",1,/*cSeek*/,/*{|| &cWhile }*/,,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,.T.,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/)

	nPosCli    := GDFieldPos("DAH_CODCLI")
	nPosLoja   := GDFieldPos("DAH_LOJA")
	nPosHrChg  := GDFieldPos("DAH_HRCHEG")
	nPosTmSrv  := GDFieldPos("DAH_TMSERV")
	nPosHrSai  := GDFieldPos("DAH_HRSAID")
	nPosSeq    := GDFieldPos("DAH_SEQUEN")
	nPosChgRea := GDFieldPos("DAH_CHGREA")
	nPosTmRea  := GDFieldPos("DAH_TMREAL")
	nPosSdRea  := GDFieldPos("DAH_SDREAL")
	nPosRec    := GDFieldPos("DAH_REC_WT")
	nPosAlias  := GDFieldPos("DAH_ALI_WT")

	aCols := {}
	ADel(aHeader,nPosAlias)
	ADel(aHeader,nPosRec)
	ASize(aHeader,Len(aHeader)-2)
	nUsado := Len(aHeader)

	//Caso ainda nao foi feito o apontamento faz resumo da carga para trazer ja preechido
	DAI->(dbSetOrder(1))
	If DAI->(MsSeek(xFilial("DAI")+DAK->DAK_COD+DAK->DAK_SEQCAR))

		While DAI->(!Eof()) .And. DAI->DAI_FILIAL == xFilial("DAI") .And. ;
									DAI->DAI_COD == DAK->DAK_COD .And. ;
									DAI->DAI_SEQCAR == DAK->DAK_SEQCAR

			nPosCols := Ascan(aCols,{|x| x[nPosCli]+x[nPosLoja] == DAI->DAI_CLIENT+DAI->DAI_LOJA })
			If nPosCols == 0
				aadd(aCols,Array(nUsado+1))
				nPosCols := Len(aCols)

				// Cria variaveis aCols
				For nCntFor := 1 To nUsado
					If ( aHeader[nCntFor][10] != "V" )
						aCols[Len(aCols)][nCntFor] := DAH->(FieldGet(FieldPos(aHeader[nCntFor][2])))
					Else
						aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
					EndIf
				Next

				aCols[nPosCols][nPosSeq]   := DAI->DAI_SEQUEN
				aCols[nPosCols][nPosCli]   := DAI->DAI_CLIENT
				aCols[nPosCols][nPosLoja]  := DAI->DAI_LOJA
				aCols[nPosCols][nPosHrChg] := DAI->DAI_CHEGAD
				aCols[nPosCols][nPosTmSrv] := DAI->DAI_TMSERV
				aCols[nPosCols][nPosHrSai] := IntToHora(HoratoInt(DAI->DAI_CHEGAD,2)+HoraToInt(DAI->DAI_TMSERV,4),2)

			Else
				aCols[nPosCols][nPosTmSrv] += IntToHora(HoratoInt(aCols[nPosCols][nPosTmSrv],4)+HoratoInt(DAI->DAI_TMSERV,4),4)
				aCols[nPosCols][nPosHrSai] += IntToHora(HoraToInt(aCols[nPosCols][nPosHrChg],2)+HoratoInt(aCols[nPosCols][nPosTmSrv],4),2)
			Endif

			aCols[nPosCols][nPosChgRea]:= aCols[nPosCols][nPosHrChg]
			aCols[nPosCols][nPosTmRea] := aCols[nPosCols][nPosTmSrv]
			aCols[nPosCols][nPosSdRea] := aCols[nPosCols][nPosHrSai]

			aCols[Len(aCols)][Len(aHeader)+1] := .F.

			DAI->(dbSkip())

		EndDo

	Endif

EndIf

aSize := MsAdvSize()
aAdd(aObjects, { 100, 020, .T., .F. } )
aAdd(aObjects, { 100, 100, .T., .T. } )
aInfo   := { aSize[1], aSize[2], aSize[3], aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0006) From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL //"Notas Fiscais da Carga

	@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL "" OF oDlg PIXEL

	@ 45,007 SAY FWX3Titulo("DAK_COD") SIZE 50,7 OF oDlg PIXEL
	@ 42,037 MsGet DAK->DAK_COD		WHEN .F. SIZE 30,7 OF oDlg PIXEL
	@ 42,067 MsGet DAK->DAK_SEQCAR	WHEN .F. SIZE 20,7 OF oDlg PIXEL

	@ 45,097 SAY FWX3Titulo("DAK_DATA") SIZE 50,7 OF oDlg PIXEL
	@ 42,117 MsGet DAK->DAK_DATA	WHEN .F. SIZE 40,7 OF oDlg PIXEL

	oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],3,"AllwaysTrue","AllWaysTrue()",,.F.,,1,,9999)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetd:TudoOk(),(nOpcA := 1,oDlg:End()),nOpcA := 0)},{||oDlg:End()})

If nOpca == 1

	For nCntFor := 1 To Len(aCols)
		If !aCols[nCntFor,Len(aCols[nCntFor])]

			If nCntFor > Len(aRecno)
				RecLock("DAH",.T.)
			Else
				DAH->(dbGoto(aRecno[nCntFor]))
				RecLock("DAH",.F.)
			Endif


			For nCntFor2 := 1 To Len(aHeader)
				If (aHeader[nCntFor2][10] != "V" )
					DAH->(FieldPut(FieldPos(aHeader[nCntFor2][2]),aCols[nCntFor][nCntFor2]))
				EndIf
			Next nCntFor2

			DAH->DAH_FILIAL := xFilial("DAH")
			DAH->DAH_CODCAR := DAK->DAK_COD
			DAH->DAH_SEQCAR := DAK->DAK_SEQCAR

			MsUnlock()
		/*Colocado em comentário pois esta regra está há pelo menos 8 anos sem funcionar
		Else

			If nCntFor <= Len(aRecno)
				DAH->(dbGoto(aRecno[nCntFor]))
				RecLock("DAH")
					dbDelete()
				MsUnlock()
			Endif

		*/
		Endif

	Next nCntFor

Endif

RestArea(aAreaDAI)
RestArea(aArea)
Return

//-----------------------------------------------------------
/*/{Protheus.doc} Oms320Calc
Rotina de cálculo do apontamento
@author Henry Fila
@Since 08/08/2001
/*/
//-----------------------------------------------------------
Function Oms320Calc()
Local cCampo   := ReadVar()
Local nPosCheg := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAH_CHGREA"})
Local nPosTSer := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAH_TMREAL"})
Local nPosSai  := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAH_SDREAL"})

Do Case
	Case cCampo == "M->DAH_CHGREA"
		aCols[n][nPosSai] := IntToHora(HoratoInt(M->DAH_CHGREA,2)+HoratoInt(aCols[n][nPosTSer],4),2)

	Case cCampo == "M->DAH_TMREAL"
		aCols[n][nPosSai] := IntToHora(HoratoInt(aCols[n][nPosCheg],2)+HoratoInt(M->DAH_TMREAL,4),2)
EndCase

Return(.T.)

//-----------------------------------------------------------
/*/{Protheus.doc} Oms320NfData
@author Guilherme Leal
@Since 06/09/2002
@params:
ExpN1: Array com campos do cabecalho da NF.
ExpN2: Array com campos dos Itens da NF.
/*/
//-----------------------------------------------------------
Static Function A320NfData(aCab, aItens)
Local nI := 0
Local nJ := 0
Local nPosCpo := 0
Local cCampo := ""

	AEval(aCab, {|x,y| &("M->"+x[1]) := x[2] } )

	If Len(aItens) > 0

		aCols := {}

		For nI := 1 To Len(aItens)
			oGetDados:AddLine()
			For nJ := 1 To Len(aHeader)
				cCampo  := Upper(Alltrim(aHeader[nJ][2]))
				nPosCpo := AScan(aItens[nI],{|x| Upper(Alltrim(x[1]))==cCampo })
				If nPosCpo >0
					aCols[Len(aCols)][nJ] := aItens[nI][nPosCpo][2]
				EndIf
			Next nJ
		Next nI

		oGetDados:lNewLine := .F.
		MaFisClear()
		MaColsToFis(aHeader,aCols,,"MT100",.T.)
		oGetDados:obrowse:refresh()
	EndIf

Return

//-----------------------------------------------------------
/*/{Protheus.doc} Oms320DevLoc
@author Guilherme Leal
@Since 21/12/2001
@params:
ExpN1: Tipo de documento
/*/
//-----------------------------------------------------------
Static Function OmsDevLoc(cEspNF,aCab,aItens)
Local oDlgRet,oSBtn2,oSBtn3,oSay4,oCboTipos
Local aTpNf := {}
Local anTipos := {}
Local cMvparAnt := Nil

Private cLocxNFPV := ""
Private cIdPVArg  := "" //- Armazenara o id do PV p/ argentina

cEspNF := Alltrim(cEspNF)
cEspecie := Alltrim(cEspNF)
Do Case
	Case !IsRemito(1,'SF2->F2_TIPODOC')
		AAdd(aTpNf, "NCC - " + Posicione("SX5",1,xFilial("SX5")+ "42NCC   ","X5Descri()"))
		AAdd(anTipos , 4)

		AAdd(aTpNf, "NDE - " + Posicione("SX5",1,xFilial("SX5")+ "42NDE   ","X5Descri()"))
		AAdd(anTipos , 5)

		AAdd(aTpNf, "RFD - " + Posicione("SX5",1,xFilial("SX5")+ "42RFD   ","X5Descri()"))
		AAdd(anTipos , 51)

	Case IsRemito(1,'SF2->F2_TIPODOC')

		AAdd(aTpNf, "RFD - " + Posicione("SX5",1,xFilial("SX5")+"42RFD   ","X5Descri()"))
		AAdd(anTipos , 51)
EndCase

//Pergunte para informação do Ponto de Venda para o país Argentina.
If cPaisLoc == "ARG"
	cMvparAnt := MV_PAR01
	If !Pergunte("PVXARG",.T.)
		Return .F.
	Endif
	cLocxNFPV := MV_PAR01
	cIdPVArg  := POSICIONE("CFH",1, xFilial("CFH")+cLocxNFPV,"CFH_IDPV") //- Armazenara o id do PV p/ argentina
	MV_PAR01  := cMvparAnt
EndIf 

If Len(anTipos) == 1
	NFxInclui( anTipos[1],{ || A320NfData(aCab, aItens) } )
	Return
EndIf

oDlgRet := MSDIALOG():Create()
oDlgRet:cName := "oDlgRet"
oDlgRet:cCaption := FunDesc()
oDlgRet:nLeft := 0
oDlgRet:nTop := 0
oDlgRet:nWidth := 306
oDlgRet:nHeight := 160
oDlgRet:lShowHint := .F.
oDlgRet:lCentered := .T.

oSay4 := TSAY():Create(oDlgRet)
oSay4:cName := "oSay4"
oSay4:cCaption := STR0022
oSay4:nLeft := 14
oSay4:nTop := 13
oSay4:nWidth := 255
oSay4:nHeight := 28
oSay4:lShowHint := .F.
oSay4:lReadOnly := .F.
oSay4:Align := 0
oSay4:lVisibleControl := .T.
oSay4:lWordWrap := .F.
oSay4:lTransparent := .F.

oCboTipos:= TComboBox():Create(oDlgRet)
oCboTipos:aItems := AClone(aTpNf)
oCboTipos:cName := "oSay4"
oCboTipos:nLeft := 16
oCboTipos:nTop := 35
oCboTipos:nWidth := 255
oCboTipos:nHeight := 28
oCboTipos:lShowHint := .F.
oCboTipos:Align := 0
oCboTipos:lVisibleControl := .T.

oSBtn2 := SBUTTON():Create(oDlgRet)
oSBtn2:cName := "oSBtn2"
oSBtn2:nLeft := 165
oSBtn2:nTop := 100
oSBtn2:nWidth := 52
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.
oSBtn2:nType := 1
oSBtn2:bAction := { || NFxInclui( anTipos[Max(1,oCboTipos:nAt)],{ || A320NfData(aCab, aItens) } ) , oDlgRet:End() }

oSBtn3 := SBUTTON():Create(oDlgRet)
oSBtn3:cName := "oSBtn3"
oSBtn3:nLeft := 225
oSBtn3:nTop := 100
oSBtn3:nWidth := 52
oSBtn3:nHeight := 22
oSBtn3:lShowHint := .F.
oSBtn3:lReadOnly := .F.
oSBtn3:Align := 0
oSBtn3:lVisibleControl := .T.
oSBtn3:nType := 2
oSBtn3:bAction := { || oDlgRet:End() }

oDlgRet:Activate()

Return

//-----------------------------------------------------------
/*/{Protheus.doc} Menudef
Menu padrão
@author Marco Bianchi
@Since 01/09/2006
/*/
//-----------------------------------------------------------
Static Function MenuDef()
Private aRotina := {	{ OemtoAnsi(STR0002),	"PesqBrw"  ,0,1,0,.F.},;	//"Pesquisa"
						{ OemtoAnsi(STR0003),	"Oms320Man",0,2,0,NIL},;	//"Visualiza"
						{ OemtoAnsi(STR0004),	"Oms320Man",0,4,0,NIL},;	//"Efetua Retorno"
						{ OemtoAnsi(STR0005),	"Oms320Est",0,5,0,NIL},;	//"Estorna Retorno"
						{ OemtoAnsi(STR0037),	"Oms320Leg",0,6,0,.F.} }	//"Legenda"
If ExistBlock("OM320MNU")
	ExecBlock("OM320MNU",.F.,.F.)
EndIf
Return(aRotina)

//-----------------------------------------------------------
/*/{Protheus.doc} OmsLOkCmp
Linha Ok da digitacao do valor informado
@author Rodolfo
@Since 06/09/2004
/*/
//-----------------------------------------------------------
Function OmsLOkCmp()
Local lRet    := .T.
Local aKeyCmp := {'DVW_CODPAS'}
//-- Nao avalia linhas deletadas
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados
	lRet := GDCheckKey(aKeyCmp, 4)
EndIf
Return(lRet)

//-----------------------------------------------------------
/*/{Protheus.doc} OmsTOkCmp
Tudo Ok da digitacao do valor informado
@author Rodolfo
@Since 12/05/2004
/*/
//-----------------------------------------------------------
Function OmsTOkCmp()
Local lRet := .T.
//-- Analisa se os campos obrigatorios da GetDados foram informados
If	lRet
	lRet := oGetCmp:ChkObrigat(n)
EndIf
//-- Analisa o linha ok
If	lRet
	lRet := OmsLOkCmp()
EndIf
Return(lRet)

//-----------------------------------------------------------
/*/{Protheus.doc} Oms320Leg
Legenda
@author Andre Godoi
@Since 12/05/2007
/*/
//-----------------------------------------------------------
Function Oms320Leg()
Local aCores
aCores := {	{ 'BR_VERDE',		STR0035 },; //"Não efetuado"
			{ 'BR_VERMELHO',	STR0036 } } //"Efetuado"
BrwLegenda( cCadastro, STR0037, aCores) //"Legenda"
Return(Nil)

//-----------------------------------------------------------
/*/{Protheus.doc} Oms320Rec
Legenda
@author Marco Bianchi
@Since 12/05/2006
@Descrption Funcao disparada para validar cada registro da tabela
SF2 e adicionar recno no array aRecSF2.
Se retornar .T. considera o registro.
@Params ExpA1: Array com numero dos registros da tabela SF2
/*/
//-----------------------------------------------------------
Static Function Oms320Rec(aRecSF2,lQuery,cAliasSF2)
aAdd(aRecSF2,Iif(lQuery,(cAliasSF2)->SF2RECNO, SF2->(Recno())))
Return(.T.)

//-----------------------------------------------------------
/*/{Protheus.doc} Oms320ACol
Legenda
@author Marco Bianchi
@Since 12/05/2006
@Description Atualiza hora de saída
@Params ExpA1: Array aCols
@return Logico. Se .F. sai do laco While da FillGetdados
/*/
//-----------------------------------------------------------
Static Function Oms320ACol(aCols,aRecno)
Local nPosHrSai  := GDFieldPos("DAH_HRSAID")
aCols[Len(aCols)][nPosHrSai] := IntToHora(HoraToint(DAH->DAH_HRCHEG,2)+HoraToInt(DAH->DAH_TMSERV,4),2)
aadd(aRecno,DAH->(Recno()))
Return .T.
