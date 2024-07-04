#INCLUDE "JURA112A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TRYEXCEPTION.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA112A
Gera os registros das tabelas de auditoria

@author  Rafael Tenorio da Costa
@since 	 05/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA112A()

Local oGrid     := Nil
Local nRet      := -1
Local cPergunta := "JURA112A"

	/*Pergunte() JURA112A
		MV_PAR01 - Marca
		MV_PAR02 - Periodo De
		MV_PAR03 - Periodo Ate
		MV_PAR04 - Filial Processo
		MV_PAR05 - Processo
		MV_PAR06 - Lista de Processos
	*/

	//--------------------------------------------------------
	//@param cFunName     Nome da rotina de menu de processamento
	//@param cTitle       Titulo da rotina de menu
	//@param cDescription Descrição completa da rotina
	//@param bProcess     Bloco de código de processamento. O bloco recebe a variavel que informa que a rotina foi cancelada
	//@param cPerg        Nome do grupo de perguntas do dicionário de dados
	//--------------------------------------------------------
	
	If( JurAuto())
		Auditoria(,.F.)
	Else
		oGrid := FWGridProcess():New(cPergunta, STR0096, STR0097, {|lEnd| nRet := Auditoria(oGrid, @lEnd)}, cPergunta) //"Gera dados para a Auditoria"	//"Está rotina tem o objetivo de gerar a Auditoria nas tabelas de Processos, Objetos, Garantias e Despesas."

		//Indica a quantidade de barras de processo
		oGrid:SetMeters(2)
		oGrid:Activate()

		If nRet > 0
			ApMsgInfo(STR0099) //"Auditoria gerada com sucesso"
		ElseIf nRet == 0
			ApMsgInfo(STR0100) //"Não existe dados a serem processados com esses parâmetros"
		EndIf

	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Auditoria
Gera dados para a Auditoria

@param oGrid      Objeto da régua de progressão

@author  Rafael Tenorio da Costa
@since 	 05/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Auditoria(oGrid, lEnd)
Local nRet      := -1
Local lContinua := .T.
Local lJurAutom := JurAuto()
Local cSqlPro   := "" //Query dos processos

	If ! JurAuto()
		oGrid:SetMaxMeter(5, 1)

		//Efetua as validações antes de gerar a auditoria
		oGrid:SetIncMeter(1, STR0101) //"Validando parâmetros"
	EndIf

	lContinua := ValidAudit()

	If lContinua
		If ! lJurAutom
			oGrid:SetIncMeter(1, STR0102) //"Gerando auditoria de Processos"
		EndIf

		nRet := Processos(@cSqlPro, oGrid)

		If nRet > 0

			//Carrega query pai apenas a filial e codigo
			cSqlPro := "SELECT NSZ_FILIAL, NSZ_COD " + cSqlPro

			If ! lJurAutom
				oGrid:SetIncMeter(1, STR0103) //"Gerando auditoria de Objetos"
			EndIf

			nRet += Objetos(cSqlPro, oGrid)

			If ! lJurAutom
				oGrid:SetIncMeter(1, STR0104) //"Gerando auditoria de Garantias"
			EndIf

			nRet += Garantias(cSqlPro, oGrid)

			If ! lJurAutom
				oGrid:SetIncMeter(1, STR0105) //"Gerando auditoria de Despesas"
			EndIf

			nRet += Despesas(cSqlPro, oGrid)

			If FWAliasIndic("O0W") .And. FWAliasIndic("O0Y")
				If ! lJurAutom
					oGrid:SetIncMeter(1, STR0121) //"Gerando auditoria de Pedidos"
				EndIf

				nRet += Pedidos(cSqlPro, oGrid)
			EndIf
		EndIf
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidAudit
Efetua as validações antes de gerar a auditoria

@author  Rafael Tenorio da Costa
@since 	 09/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidAudit()
Local aArea      := GetArea()
Local lContinua  := .T.
Local cStatus    := JurGetdados("O0E", 1, xFilial("O0E") + DtoS(MV_PAR01), "O0E_STATUS")
Local cChaveO0F  := xFilial("O0F") + DtoS(MV_PAR01)
Local cMsgYesNo  := STR0108	//"Já existe auditoria com esta marca, deseja apagar a auditoria existente para continuar ?"
Local lExcAudit  := .F.
Local aAuditExc  := {}
Local nCont      := 0
Local aCajuris   := {}
Local codNSZ     := ""
Local cTipCmpNSZ := ""
Local cMsgErro   := STR0110 //"Preencha corretamente os campos, Filial e Processo"
Local lAuto      := JurAuto()

	//Valida marca
	If Empty(MV_PAR01) .Or. Empty(cStatus)
		cMsgErro  := STR0107	//"Marca inválida"
		lContinua := .F.
	EndIf

	//Marca fechada
	If lContinua .And. cStatus == "2"
		cMsgErro  := STR0109 //"Marca Fechada"
		lContinua := .F.
	EndIf

	//Valida período
	If lContinua
		cMsgErro := J112aVldDt(MV_PAR02, MV_PAR03)
		If !Empty(cMsgErro)
			lContinua := .F.
		EndIf
	EndIf

	//Valida Filial e Processo
	If lContinua .And. ( !Empty(MV_PAR04) .Or.  !Empty(MV_PAR05) .Or. !Empty(MV_PAR06)  )
		cTipCmpNSZ := JCompTable("NSZ")

		If cTipCmpNSZ != "CCC" .And. Empty(MV_PAR04)
			lContinua := .F.
			cMsgErro  := STR0119 //"Selecione a Filial para realizar o reprocessamento do(s) processo(s) selecionado(s)."
		ElseIf (!Empty(MV_PAR05) .And. !Empty(MV_PAR06))
			lContinua := .F.
			cMsgErro := STR0120 //"Não é possivel utilizar o campo de Processo e Lista de Processos simultaneamente. Se deseja reprocessar mais de um processo utilize o campo 'Lista de Processos'."
		ElseIf cTipCmpNSZ == "CCC"
			MV_PAR04 := xFilial("NSZ")
		EndIf

		If lContinua
			If (!Empty(MV_PAR05))
				MV_PAR06 := MV_PAR05
			EndIf

			If !Empty(MV_PAR06)
				aCajuris := JStrArrDst(MV_PAR06,',')
				For nCont := 1 To Len(aCajuris)
					aCajuris[nCont] := PadL(aCajuris[nCont],GetSx3Cache("NSZ_COD","X3_TAMANHO"),"0")
					If lContinua
						codNSZ := JurGetDados("NSZ", 1, MV_PAR04 + aCajuris[nCont], "NSZ_COD")
						lContinua := !Empty( codNSZ )
						If lContinua
							cChaveO0F := xFilial("O0F") + DtoS(MV_PAR01) + MV_PAR04 + aCajuris[nCont]
							lExcAudit := O0F->( DbSeek(cChaveO0F) )

							If (lExcAudit)
								aAdd(aAuditExc,cChaveO0F)
							EndIf
						EndIf
					Else
						Exit
					EndIf
				Next
			EndIf
		EndIf
	EndIf

	//Valida auditoria ja existente
	If lContinua
		If Len(aAuditExc) .Or. Len(aCajuris) == 0
			If !(lAuto)
				lAuto := MsgYesNo(STR0118) // "Já existe auditoria com esta marca, a auditoria feita anteriormente sera excluida. Deseja continuar?"
			EndIf

			If (lAuto)
 				If Len(aAuditExc) > 0
					For nCont := 1 To Len(aAuditExc)
						J112aExcAu("O0F", MV_PAR01, aAuditExc[nCont])	//Historico processo
						J112aExcAu("O0G", MV_PAR01, aAuditExc[nCont])	//Historico objeto
						J112aExcAu("O0H", MV_PAR01, aAuditExc[nCont])	//Historico garantia
						J112aExcAu("O0I", MV_PAR01, aAuditExc[nCont])	//Historico despesa
						If FWAliasIndic("O0W") .And. FWAliasIndic("O0Y")
							J112aExcAu("O0Y", MV_PAR01, aAuditExc[nCont])	//Historico pedido
						EndIf
					Next
				Else
					J112aExcAu("O0F", MV_PAR01, cChaveO0F)	//Historico processo
					J112aExcAu("O0G", MV_PAR01, cChaveO0F)	//Historico objeto
					J112aExcAu("O0H", MV_PAR01, cChaveO0F)	//Historico garantia
					J112aExcAu("O0I", MV_PAR01, cChaveO0F)	//Historico despesa
					If FWAliasIndic("O0W") .And. FWAliasIndic("O0Y")
						J112aExcAu("O0Y", MV_PAR01, cChaveO0F)	//Historico despesa
					EndIf
				EndIf
			Else
				lContinua := .F.
			EndIf
		EndIf
	Else
		JurMsgErro(cMsgErro)
	EndIf

	RestArea(aArea)

Return lContinua

//-------------------------------------------------------------------
/*/{Protheus.doc} J112aVldDt
Valida data inicial e data final

@Param dDtIni - Data Inicial
@Param dDtFim - Data Final

@author Jorge Luis Branco Martins Junior
@since 31/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function J112aVldDt(dDtIni, dDtFim)

Local cErro := ""

	If Empty(dDtIni) .Or. Empty(dDtFim)
		cErro := STR0111 //"Período não preenchido"
	EndIf

	If !IsInCallStack("JURA112B") .And. (dDtIni > Date() .Or. dDtFim > Date())
		cErro := STR0112 //"Data inicial ou final maior que data do dia"
	EndIf

	If dDtIni > dDtFim
		cErro := STR0113 //"Data inicial maior que data final"
	EndIf

Return cErro

//-------------------------------------------------------------------
/*/{Protheus.doc} J112aExcAu
Deleta registros já existentes da auditoria

@param cTabAudit  Alias da tabela de auditoria
@param dMarca     Data da marca
@param cChave     Chave da tabela de auditoria

@author  Rafael Tenorio da Costa
@since 	 09/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J112aExcAu(cTabAudit, dMarca, cChave)

Local aArea      := GetArea()
Local cCmpFilAud := cTabAudit + "_FILIAL"
Local cFilAud    := ""
Local aAuditoria := {}
Local nCont      := 0
Local cChaveO0X  := Posicione("SX2", 1, cTabAudit, "X2_UNICO")

Default cChave   := ""

	ProcRegua(0)
	IncProc()
	IncProc()

	If Empty(cChave)
		cChave := xFilial(cTabAudit) + DtoS(dMarca)
	EndIf

	//Habilita controle de Transacao
	Begin Transaction

		//Apaga tabelas de auditoria
		DbSelectArea(cTabAudit)
		(cTabAudit)->( DbSetOrder(1) )	//O0X_FILIAL+DTOS(O0X_MARCA)
		While (cTabAudit)->( DbSeek(cChave) )

			cFilAud   := &(cTabAudit + "->" + cCmpFilAud)
			cConteudo := &(cTabAudit + "->(" + cChaveO0X + ")")

			If aScan(aAuditoria, {|x| x[1] == cFilAud .And. x[2] == cConteudo}) == 0
				Aadd(aAuditoria, {cFilAud, cConteudo})
			EndIf

			RecLock(cTabAudit, .F.)
				(cTabAudit)->( DbDelete() )
			(cTabAudit)->( MsUnLock() )

			(cTabAudit)->( DbSkip() )
		EndDo

		//Apaga campos complementares
		DbSelectArea("O0C")
		O0C->( DbSetOrder(1) )		//O0C_FILIAL+DTOS(O0C_MARCA)+O0C_ENTAUD+O0C_CHVAUD+O0C_CMPFOR
		For nCont:=1 To Len(aAuditoria)

			cFilAud   := xFilial('O0C')
			cChaveO0X := aAuditoria[nCont][2]

			If O0C->( DbSeek(cFilAud + DtoS(dMarca) + cTabAudit) )

				While O0C->( DbSeek(cFilAud + DtoS(dMarca) + cTabAudit + cChaveO0X) )

					RecLock("O0C", .F.)
						O0C->( DbDelete() )
					O0C->( MsUnLock() )

					O0C->( DbSkip() )
				EndDo

			Else
				Exit
			EndIf

		Next nCont

	//Desabilita controle de Transacao
   	End Transaction

	aSize(aAuditoria, 0)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Processos
Gera a auditoria dos Processos

@param cSqlPro   Query da Auditoria de Processos
@param oGrid     Objeto da régua de progressão

@author  Rafael Tenorio da Costa
@since 	 05/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Processos(cSqlPro, oGrid)

Local aArea      := GetArea()
Local cTabPad    := "NSZ"
Local cTabAudit  := "O0F"
Local aCampos    := {}
Local aCmpsCompl := J112aCmpCo("1") //Pega os Campos complementares que devem ser gravados
Local cSql       := ""
Local cFilCajuri := ""
Local cTabSql    := GetNextAlias()
Local nCont      := 1
Local nRet       := 1
Local nQuant     := 0
Local lO0FNvCmp  := .F.

	//Verifica se os campos O0F_VINCON e O0F_VATINC existem no dicionário
	If Select("O0F") > 0
		lO0FNvCmp := (O0F->(FieldPos('O0F_VINCON')) > 0) .AND. (O0F->(FieldPos('O0F_VATINC')) > 0)
	Else
		DBSelectArea("O0F")
			lO0FNvCmp := (O0F->(FieldPos('O0F_VINCON')) > 0) .AND. (O0F->(FieldPos('O0F_VATINC')) > 0)
		O0F->( DBCloseArea() )
	EndIf

	Aadd(aCampos, {"NSZ_FILIAL", "O0F_FILPRO"})
	Aadd(aCampos, {"NSZ_COD"   , "O0F_CAJURI"})
	Aadd(aCampos, {"NSZ_CCLIEN", "O0F_CCLIEN"})
	Aadd(aCampos, {"NSZ_LCLIEN", "O0F_LCLIEN"})
	Aadd(aCampos, {"NSZ_CCUSTO", "O0F_CCUSTO"})
	Aadd(aCampos, {"NSZ_CAREAJ", "O0F_CAREAJ"})
	Aadd(aCampos, {"NSZ_CSUBAR", "O0F_CSUBAR"})
	Aadd(aCampos, {"NSZ_DTPROV", "O0F_DTPROV"})
	Aadd(aCampos, {"NSZ_CMOPRO", "O0F_CMOPRO"})
	Aadd(aCampos, {"NSZ_VLPROV", "O0F_VLPROV"}) //                Valor Provável
	Aadd(aCampos, {"NSZ_VAPROV", "O0F_VAPROV"}) //                Valor Provavel Atual
	Aadd(aCampos, {"VLPRPO"    , "O0F_VLPRPO"}) //Campo Virtual - Valor Possível
	Aadd(aCampos, {"VLPPOA"    , "O0F_VLPPOA"}) //Campo Virtual - Valor Possível Atual
	Aadd(aCampos, {"VLPRRE"    , "O0F_VLPRRE"}) //Campo Virtual - Valor remoto
	Aadd(aCampos, {"VLPREA"    , "O0F_VLPREA"}) //Campo Virtual - Valor remoto Atual
	If lO0FNvCmp
		Aadd(aCampos, {"VINCON"    , "O0F_VINCON"}) //Campo Virtual - Valor incontroverso
		Aadd(aCampos, {"VATINC"    , "O0F_VATINC"}) //Campo Virtual - Valor incontroverso Atual
	EndIf
	Aadd(aCampos, {"NSZ_VCPROV", "O0F_VCPROV"})
	Aadd(aCampos, {"NSZ_VJPROV", "O0F_VJPROV"})
	Aadd(aCampos, {"NSZ_DTULAT", "O0F_DTULAT"})
	Aadd(aCampos, {"NSZ_SITUAC", "O0F_SITUAC"})
	Aadd(aCampos, {"NSZ_DTENCE", "O0F_DTENCE"})
	Aadd(aCampos, {"NSZ_DTREAB", "O0F_DTREAB"})
	Aadd(aCampos, {"NSZ_VLFINA", "O0F_VLFINA"})
	Aadd(aCampos, {"NSZ_VAFINA", "O0F_VAFINA"})
	Aadd(aCampos, {"NSZ_CMOENC", "O0F_CMOENC"})
	Aadd(aCampos, {"NSZ_DETENC", "O0F_DETENC"})

	cSql := " SELECT NSZ.R_E_C_N_O_ RECNO"

	cSql += ", ( " + SqlVlProv("2", .F.) + " ) VLPRPO"	//Possível
	cSql += ", ( " + SqlVlProv("2", .T.) + " ) VLPPOA"	//Possível Atualizado
	cSql += ", ( " + SqlVlProv("3", .F.) + " ) VLPRRE"	//Remoto
	cSql += ", ( " + SqlVlProv("3", .T.) + " ) VLPREA"	//Remoto Atualizado
	If lO0FNvCmp
		cSql += ", ( " + SqlVlProv("4", .F.) + " ) VINCON"  //Incontroverso
		cSql += ", ( " + SqlVlProv("4", .T.) + " ) VATINC"  //Incontroverso Atualizado
	EndIf

	cSqlPro := " FROM " + RetSqlName("NSZ") + " NSZ"

	cSqlPro += " WHERE ( ( NSZ_SITUAC = '1' AND NSZ_DTINCL <= '" + DtoS(MV_PAR03) + "' ) OR "
	cSqlPro +=         " ( NSZ_SITUAC = '2' AND NSZ_DTENCE BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "') ) AND "
	cSqlPro +=           " NSZ.D_E_L_E_T_ = ' '"

	//Verifica se a filial foi preenchida
	If !Empty(MV_PAR04)
		cSqlPro += " AND NSZ_FILIAL = '" + MV_PAR04 + "'"
	EndIf

	//Verifica se o processo foi preenchida
	If !Empty(MV_PAR05) .Or. !Empty(MV_PAR06)

		If !Empty(MV_PAR05)
			MV_PAR06 := MV_PAR05
		EndIf

		aCajuris := JStrArrDst(MV_PAR06,',')
		For nCont := 1 to Len(aCajuris)
			aCajuris[nCont] := PadL(aCajuris[nCont],GetSx3Cache("NSZ_COD","X3_TAMANHO"),"0")

			cFilCajuri += "'"+ aCajuris[nCont] +"',"
		Next

		cFilCajuri := SubStr(cFilCajuri,1, Len(cFilCajuri)-1)
		cSqlPro += " AND NSZ_COD IN (" + cFilCajuri + ")"
	EndIf

	cSql := cSql + cSqlPro

	//Retorna a quantidade de processos
	nQuant := RetQtdSql(cSql)

	//Executa query de processos
	cSql := ChangeQuery(cSql)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), cTabSql, .F., .T.)

	//Grava auditoria do processo
	If !(cTabSql)->( Eof() )

		If ! JurAuto()
			oGrid:SetMaxMeter(nQuant, 2, STR0114) //"Auditando Processos"
			oGrid:SetIncMeter(2, STR0114)         //"Auditando Processos"
		EndIf

		nRet := GravaHist(cTabAudit, cTabSql, aCampos, aCmpsCompl, cTabPad, oGrid)
	Else
		nRet := 0
	EndIf

	aSize(aCampos	, 0)
	aSize(aCmpsCompl, 0)

	(cTabSql)->( DbCloseArea() )
	RestArea(aArea)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Objetos
Gera a auditoria dos Objetos

@param cSqlPro   Query da Auditoria de Processos
@param oGrid     Objeto da régua de progressão

@author  Rafael Tenorio da Costa
@since 	 05/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Objetos(cSqlPro, oGrid)

Local aArea     := GetArea()
Local cTabPad   := "NSY"
Local cTabAudit := "O0G"
Local aCampos   := {}
Local cSql      := ""
Local cTabSql   := GetNextAlias()
Local nRet      := 1
Local cBanco    := Upper( AllTrim( TcGetDb() ) )
Local nQuant    := 0
Local lPedidos  := .F.
Local lCajuri   := .F.

	Aadd( aCampos, {"NSY_FILIAL"   , "O0G_FILPRO"} )
	Aadd( aCampos, {"NSY_CAJURI"   , "O0G_CAJURI"} )
	Aadd( aCampos, {"NSY_COD"      , "O0G_COD"	  } )
	Aadd( aCampos, {"NSY_CPEVLR"   , "O0G_CPEVLR"} )
	Aadd( aCampos, {"NSY_CPROG"    , "O0G_CPROG" } )
	Aadd( aCampos, {"NSY_CDECPE"   , "O0G_CDECPE"} )
	Aadd( aCampos, {"NSY_CBASED"   , "O0G_CBASED"} )
	Aadd( aCampos, {"NSY_CCOMON"   , "O0G_CCOMON"} )
	Aadd( aCampos, {"NSY_PEDATA"   , "O0G_PEDATA"} )
	Aadd( aCampos, {"NSY_DTJURO"   , "O0G_DTJURO"} )
	Aadd( aCampos, {"NSY_CMOPED"   , "O0G_CMOPED"} )
	Aadd( aCampos, {"NSY_PEINVL"   , "O0G_PEINVL"} )
	Aadd( aCampos, {"NSY_PEVLR"    , "O0G_PEVLR" } )
	Aadd( aCampos, {"NSY_CCORPE"   , "O0G_CCORPE"} )
	Aadd( aCampos, {"NSY_CJURPE"   , "O0G_CJURPE"} )
	Aadd( aCampos, {"NSY_MULATU"   , "O0G_MULATU"} )
	Aadd( aCampos, {"NSY_PEVLRA"   , "O0G_PEVLRA"} )
	Aadd( aCampos, {"NSY_INECON"   , "O0G_INECON"} )
	Aadd( aCampos, {"NSY_VLCONT"   , "O0G_VLCONT"} )
	Aadd( aCampos, {"NSY_CCORPC"   , "O0G_CCORPC"} )
	Aadd( aCampos, {"NSY_CJURPC"   , "O0G_CJURPC"} )
	Aadd( aCampos, {"NSY_MULATC"   , "O0G_MULATC"} )
	Aadd( aCampos, {"NSY_VLCONA"   , "O0G_VLCONA"} )
	Aadd( aCampos, {"ULTIMO_CFUPRO", "O0G_CFUPRO"} )
	Aadd( aCampos, {"ULTIMO_CCLFUN", "O0G_CCLFUN"} )

	
	//Verifica se a rotina de Pedidos foi implementada 
	If Select("NSY") > 0
		lPedidos := NSY->( FieldPos('NSY_CVERBA') ) > 0
	Else
		DBSelectArea("NSY")
			lPedidos := NSY->( FieldPos('NSY_CVERBA') ) > 0
		NSY->( DBCloseArea() )
	EndIf

	If Select("O07") > 0
		lCajuri := O07->(FieldPos("O07_CAJURI")) > 0
	else
		DBSelectArea("O07")
			lCajuri := O07->(FieldPos("O07_CAJURI")) > 0
		O07->( DBCloseArea() )
	EndIf

	cSql := " SELECT NSY.R_E_C_N_O_ RECNO"

	//Pega ultimo fundamento e ultima classificação do objeto
	Do Case
		Case cBanco == 'MSSQL'
			cSql += ", ISNULL( (SELECT TOP 1 O07.O07_CFUPRO "
			cSql +=           " FROM " + RetSqlName("O07") + " O07"
			cSql +=           " WHERE O07.O07_FILIAL = NSY.NSY_FILIAL"
			cSql +=                 " AND O07.O07_COBJET = NSY.NSY_COD"
			if lCajuri
				cSql +=             " AND O07.O07_CAJURI = NSY.NSY_CAJURI"
			EndIf
			cSql +=                 " AND O07.D_E_L_E_T_ = ' ' ORDER BY O07.R_E_C_N_O_ DESC), '') ULTIMO_CFUPRO"
			cSql += ", ISNULL( (SELECT TOP 1 O07.O07_CCLFUN"
			cSql +=           " FROM " + RetSqlName("O07") + " O07"
			cSql +=           " WHERE O07.O07_FILIAL = NSY.NSY_FILIAL"
			cSql +=                 " AND O07.O07_COBJET = NSY.NSY_COD"
			if lCajuri
				cSql +=             " AND O07.O07_CAJURI = NSY.NSY_CAJURI"
			EndIf
			cSql +=                 " AND O07.D_E_L_E_T_ = ' ' ORDER BY O07.R_E_C_N_O_ DESC), '') ULTIMO_CCLFUN"
		Case cBanco $ 'ORACLE|POSTGRES'
			cSql += ", (SELECT COALESCE(O07.O07_CFUPRO, '') "
			cSql +=   " FROM " + RetSqlName("O07") + " O07"
			cSql +=   " WHERE O07.R_E_C_N_O_ =  (SELECT MAX(R_E_C_N_O_) "
			cSql +=                            " FROM " + RetSqlName("O07")
			cSql +=                            " WHERE O07_FILIAL = NSY.NSY_FILIAL "
			cSql +=                                  " AND O07_COBJET = NSY.NSY_COD "
			if lCajuri
				cSql +=                              " AND O07.O07_CAJURI = NSY.NSY_CAJURI"
			EndIf
			cSql +=                                  " AND D_E_L_E_T_ = ' ' )) ULTIMO_CFUPRO"
			cSql += ", (SELECT COALESCE(O07.O07_CCLFUN, '')"
			cSql +=   " FROM " + RetSqlName("O07") + " O07"
			cSql +=   " WHERE O07.R_E_C_N_O_ =  (SELECT MAX(R_E_C_N_O_)"
			cSql +=                            " FROM " + RetSqlName("O07")
			cSql +=                            " WHERE O07_FILIAL = NSY.NSY_FILIAL"
			cSql +=                                  " AND O07_COBJET = NSY.NSY_COD"
			if lCajuri
				cSql +=                              " AND O07.O07_CAJURI = NSY.NSY_CAJURI"
			EndIf
			cSql +=                                  " AND D_E_L_E_T_ = ' ' )) ULTIMO_CCLFUN"

		Case cBanco == 'DB2'
			cSql += ", ISNULL( (SELECT O07.O07_CFUPRO"
			cSql +=           " FROM " + RetSqlName("O07") + " O07"
			cSql +=           " WHERE O07.O07_FILIAL = NSY.NSY_FILIAL"
			cSql +=                 " AND O07.O07_COBJET = NSY.NSY_COD"
			if lCajuri
				cSql +=              " AND O07.O07_CAJURI = NSY.NSY_CAJURI"
			EndIf
			cSql +=                 " AND O07.D_E_L_E_T_ = ' ' ORDER BY O07.R_E_C_N_O_ DESC FETCH FIRST 1 ROWS ONLY), '') ULTIMO_CFUPRO"
			cSql += ", ISNULL( (SELECT O07.O07_CCLFUN"
			cSql +=           " FROM " + RetSqlName("O07") + " O07"
			cSql +=           " WHERE O07.O07_FILIAL = NSY.NSY_FILIAL"
			cSql +=                 " AND O07.O07_COBJET = NSY.NSY_COD"
			if lCajuri
				cSql +=             " AND O07.O07_CAJURI = NSY.NSY_CAJURI"
			EndIf
			cSql +=                 " AND O07.D_E_L_E_T_ = ' ' ORDER BY O07.R_E_C_N_O_ DESC FETCH FIRST 1 ROWS ONLY), '') ULTIMO_CCLFUN"
	EndCase

	cSql += " FROM " + RetSqlName("NSY")
	cSql +=       " NSY INNER JOIN (" + cSqlPro + ") NSZ" //Filtra os processos auditados
	cSql +=                   " ON NSY.NSY_FILIAL = NSZ.NSZ_FILIAL "
	cSql +=                   " AND NSY.NSY_CAJURI = NSZ.NSZ_COD "
	If lPedidos
		cSql +=                   " AND NSY.NSY_CVERBA = '' "
	EndIf
	cSql += " WHERE NSY.D_E_L_E_T_ = ' '"

	//Retorna a quantidade de Objetos
	nQuant := RetQtdSql(cSql)

	cSql := ChangeQuery(cSql)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), cTabSql, .F., .T.)

	//Grava auditoria do objeto
	If !(cTabSql)->( Eof() )

		If ! JurAuto()

			oGrid:SetMaxMeter(nQuant, 2, STR0115) //"Auditando Objetos"
			oGrid:SetIncMeter(2, STR0115)         //"Auditando Objetos"
		EndIf

		nRet := GravaHist(cTabAudit, cTabSql, aCampos, /*aCmpsCompl*/, cTabPad, oGrid)
	Else
		nRet := 0
	EndIf

	aSize(aCampos, 0)

	(cTabSql)->( DbCloseArea() )
	RestArea(aArea)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Garantias
Gera a auditoria das Garantias

@param cSqlPro   Query da Auditoria de Processos
@param oGrid     Objeto da régua de progressão

@author  Rafael Tenorio da Costa
@since 	 05/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Garantias(cSqlPro, oGrid)

Local aArea     := GetArea()
Local cTabPad   := "NT2"
Local cTabAudit := "O0H"
Local aCampos   := {}
Local cSql      := ""
Local cTabSql   := GetNextAlias()
Local nRet      := 1
Local nQuant    := 0

	Aadd( aCampos, {"NT2_FILIAL"   , "O0H_FILPRO"} )
	Aadd( aCampos, {"NT2_CAJURI"   , "O0H_CAJURI"} )
	Aadd( aCampos, {"NT2_COD"      , "O0H_COD"   } )
	Aadd( aCampos, {"NT2_MOVFIN"   , "O0H_MOVFIN"} )
	Aadd( aCampos, {"NT2_CTPGAR"   , "O0H_CTPGAR"} )
	Aadd( aCampos, {"NT2_DATA"     , "O0H_DATA"  } )
	Aadd( aCampos, {"NT2_CENVOL"   , "O0H_CENVOL"} )
	Aadd( aCampos, {"NT2_EMBREC"   , "O0H_EMBREC"} )
	Aadd( aCampos, {"NT2_CCOMON"   , "O0H_CCOMON"} )
	Aadd( aCampos, {"NT2_VALOR"    , "O0H_VALOR" } )
	Aadd( aCampos, {"LEVANTAMENTO" , "O0H_LEVANT"} )

	cSql := " SELECT GAR.R_E_C_N_O_ RECNO"

	cSql +=  ", ( SELECT ISNULL( SUM(ALV.NT2_VALOR + ALV.NT2_VCPROV + ALV.NT2_VJPROV), 0)"
	cSql +=     " FROM " + RetSqlName("NT2") + " ALV"
	cSql +=     " WHERE ALV.NT2_FILIAL = GAR.NT2_FILIAL"
	cSql +=           " AND ALV.NT2_CGARAN = GAR.NT2_COD"
	cSql +=           " AND ALV.NT2_CAJURI = GAR.NT2_CAJURI AND ALV.NT2_MOVFIN = '2' AND ALV.D_E_L_E_T_ = ' ' ) LEVANTAMENTO"
	cSql += " FROM " + RetSqlName("NT2") + " GAR INNER JOIN (" + cSqlPro + ") NSZ"		//Filtra os processos auditados
	cSql +=                                            " ON GAR.NT2_FILIAL = NSZ_FILIAL AND GAR.NT2_CAJURI = NSZ_COD"
	cSql += " WHERE GAR.NT2_MOVFIN = '1'" //1=Garantias
	cSql +=       " AND GAR.D_E_L_E_T_ = ' '"

	//Retorna a quantidade de Despesas
	nQuant := RetQtdSql(cSql)

	cSql += " ORDER BY GAR.NT2_CAJURI "

	cSql := ChangeQuery(cSql)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), cTabSql, .F., .T.)

	//Grava auditoria da garantia
	If !(cTabSql)->( Eof() )

		If ! JurAuto()

			oGrid:SetMaxMeter(nQuant, 2, STR0116) //"Auditando Garantias"
			oGrid:SetIncMeter(2, STR0116)         //"Auditando Garantias"
		EndIf

		nRet := GravaHist(cTabAudit, cTabSql, aCampos, /*aCmpsCompl*/, cTabPad, oGrid)
	Else
		nRet := 0
	EndIf

	aSize(aCampos, 0)

	(cTabSql)->( DbCloseArea() )
	RestArea(aArea)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Despesas
Gera a auditoria das Garantias

@param cSqlPro   Query da Auditoria de Processos
@param oGrid     Objeto da régua de progressão

@author  Rafael Tenorio da Costa
@since 	 05/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Despesas(cSqlPro, oGrid)

Local aArea     := GetArea()
Local cTabPad   := "NT3"
Local cTabAudit := "O0I"
Local aCampos   := {}
Local cSql      := ""
Local cTabSql   := GetNextAlias()
Local nRet      := 1
Local nQuant    := 0

	Aadd( aCampos, {"NT3_FILIAL", "O0I_FILPRO"} )
	Aadd( aCampos, {"NT3_CAJURI", "O0I_CAJURI"} )
	Aadd( aCampos, {"NT3_COD"   , "O0I_COD"	  } )
	Aadd( aCampos, {"NT3_CTPDES", "O0I_CTPDES"} )
	Aadd( aCampos, {"NT3_DATA"  , "O0I_DATA"  } )
	Aadd( aCampos, {"NT3_CMOEDA", "O0I_CMOEDA"} )
	Aadd( aCampos, {"NT3_VALOR" , "O0I_VALOR" } )

	cSql := " SELECT NT3.R_E_C_N_O_ RECNO"
	cSql += " FROM " + RetSqlName("NT3") +" NT3"
	cSql +=        " INNER JOIN (" + cSqlPro + ") NSZ" //Filtra os processos auditados
	cSql +=                " ON NT3_FILIAL = NSZ_FILIAL AND NT3_CAJURI = NSZ_COD"
	cSql += " WHERE NT3.D_E_L_E_T_ = ' '"

	//Retorna a quantidade de Garantias
	nQuant := RetQtdSql(cSql)

	cSql := ChangeQuery(cSql)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), cTabSql, .F., .T.)

	//Grava auditoria da despesa
	If !(cTabSql)->( Eof() )
		
		If ! JurAuto()
			oGrid:SetMaxMeter(nQuant, 2, STR0117) //"Auditando Despesas"
			oGrid:SetIncMeter(2, STR0117)         //"Auditando Despesas"
		EndIf
		
		nRet := GravaHist(cTabAudit, cTabSql, aCampos, /*aCmpsCompl*/, cTabPad, oGrid)
	Else
		nRet := 0
	EndIf

	aSize(aCampos, 0)

	(cTabSql)->( DbCloseArea() )
	RestArea(aArea)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Pedidos
Gera a auditoria dos Pedidos

@param cSqlPro   Query da Auditoria de Processos
@param oGrid     Objeto da régua de progressão

@since 	 23/04/2020
/*/
//-------------------------------------------------------------------
Static Function Pedidos(cSqlPro, oGrid)

Local aArea     := GetArea()
Local cTabPad   := "O0W"
Local cTabAudit := "O0Y"
Local aCampos   := {}
Local cSql      := ""
Local cTabSql   := GetNextAlias()
Local nRet      := 1
Local nQuant    := 0
	
	
	Aadd( aCampos, {"O0W_FILIAL"   , "O0Y_FILPRO"} )
	Aadd( aCampos, {"O0W_CAJURI"   , "O0Y_CAJURI"} )
	Aadd( aCampos, {"O0W_COD"      , "O0Y_COD"   } )
	Aadd( aCampos, {"O0W_PROGNO"   , "O0Y_PROGNO"} )
	Aadd( aCampos, {"O0W_VPOSSI"   , "O0Y_VPOSSI"} )
	Aadd( aCampos, {"O0W_VATPOS"   , "O0Y_VATPOS"} )
	Aadd( aCampos, {"O0W_VREMOT"   , "O0Y_VREMOT"} )
	Aadd( aCampos, {"O0W_VATREM"   , "O0Y_VATREM"} )
	Aadd( aCampos, {"O0W_VPROVA"   , "O0Y_VPROVA"} )
	Aadd( aCampos, {"O0W_VATPRO"   , "O0Y_VATPRO"} )
	Aadd( aCampos, {"O0W_VINCON"   , "O0Y_VINCON"} )
	Aadd( aCampos, {"O0W_VATINC"   , "O0Y_VATINC"} )
	Aadd( aCampos, {"O0W_CTPPED"   , "O0Y_CTPPED"} )
	Aadd( aCampos, {"O0W_VPEDID"   , "O0Y_VPEDID"} )
	Aadd( aCampos, {"O0W_VATPED"   , "O0Y_VATPED"} )

	cSql := " SELECT O0W.R_E_C_N_O_ RECNO"
	cSql += " FROM " + RetSqlName("O0W") +" O0W"
	cSql +=        " INNER JOIN (" + cSqlPro + ") NSZ" //Filtra os processos auditados
	cSql +=                " ON O0W_FILIAL = NSZ_FILIAL AND O0W_CAJURI = NSZ_COD"
	cSql += " WHERE O0W.D_E_L_E_T_ = ' '"

	//Retorna a quantidade de Pedidos
	nQuant := RetQtdSql(cSql)

	cSql := ChangeQuery(cSql)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), cTabSql, .F., .T.)

	//Grava auditoria da pedidos
	If !(cTabSql)->( Eof() )

		If ! JurAuto()

			oGrid:SetMaxMeter(nQuant, 2, STR0122) //"Auditando Pedidos"
			oGrid:SetIncMeter(2, STR0122)         //"Auditando Pedidos"

		EndIf

		nRet := GravaHist(cTabAudit, cTabSql, aCampos, /*aCmpsCompl*/, cTabPad, oGrid)
	Else
		nRet := 0
	EndIf

	aSize(aCampos, 0)

	(cTabSql)->( DbCloseArea() )
	RestArea(aArea)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J112aCmpCo
Carrega os campos complementares

@param cHistorico Conteúdo do campo Histórico
                  1=Sim - Define que o campo\formula será gravado na tabela O0C para ser comparado com outra Auditoria.
                  2=Não - Define que o campo só será apresentado no relatório de comparação, seu conteudo será pego do 
                  registro atual do processo (NSZ) no momento da comparação.

@author  Rafael Tenorio da Costa
@since 	 08/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J112aCmpCo(cHistorico)

Local aArea      := GetArea()
Local aCmpsCompl := {}
Local cSql       := ""

Default cHistorico := ""

	cSql := " SELECT O0B_CAMPO, O0B_FORMUL, O0B_TITULO, O0B_HISTOR"
	cSql += " FROM " + RetSqlName("O0B")
	cSql += " WHERE O0B_FILIAL = '" + xFilial("O0B") + "'"
	If !Empty(cHistorico)
		cSql += " AND O0B_HISTOR = '" + cHistorico + "'"
	EndIf
	cSql +=   " AND D_E_L_E_T_ = ' '"
	cSql += " ORDER BY O0B_HISTOR DESC, O0B_TITULO"

	aCmpsCompl := JurSQL(cSql, "*")

	RestArea(aArea)

Return aCmpsCompl

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaHist
Grava registros nas tabelas de historico

@param cTabAudit  Alias da tabela de auditoria
@param cTabSql    Alias da tabela auditada
@param aCampos    Campos a serem gravados
@param aCmpsCompl Campos complementares
@param cTabPad    Registro auditado
@param oGrid      Objeto da régua de progressão

@author  Rafael Tenorio da Costa
@since 	 08/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaHist(cTabAudit, cTabSql, aCampos, aCmpsCompl, cTabPad, oGrid)

Local aArea      := GetArea()
Local cCmpFilAud := cTabAudit + "_FILIAL"
Local cCmpMarca  := cTabAudit + "_MARCA"
Local cFilAud    := ""
Local cCampo     := ""
Local cCajuri    := ""
Local cCodGar    := ""
Local cFilPro    := ""
Local xConteudo  := Nil
Local oError     := Nil
Local cChaveO0X  := Posicione("SX2", 1, cTabAudit, "X2_UNICO")
Local lErro      := .F.
Local nRet       := 1
Local nCont      := 1
Local nI         := 0
Local nVlrAtu    := 0
Local nJurAtu    := 0
Local nCorAtu    := 0
Local aHistVlr   := {}

Default aCmpsCompl := {}

	While !(cTabSql)->( Eof() )

		If ! JurAuto()
			oGrid:SetIncMeter(2)
		EndIf

		//Posiciona no registro auditado, feito assim por causa de campos memos e para a execução da formula
		DbSelectArea(cTabPad)
		(cTabPad)->( DbGoTo( &(cTabSql + "->RECNO") ) )

		If !(cTabPad)->( Eof() )

			//Habilita controle de Transacao
			Begin Transaction

				//Grava tabelas de auditoria
				RecLock(cTabAudit, .T.)

					cFilAud	:= xFilial(cTabAudit)

					&(cTabAudit + "->" + cCmpFilAud) := cFilAud
					&(cTabAudit + "->" + cCmpMarca ) := MV_PAR01

					For nCont:=1 To Len(aCampos)
						cCampo := aCampos[nCont][1]

						If (cTabPad + "_") $ cCampo
							xConteudo := &(cTabPad + "->" + cCampo)
						Else
							xConteudo := &(cTabSql + "->" + cCampo)
						EndIf

						&(cTabAudit + "->" + aCampos[nCont][2]) := xConteudo
					Next nCont

					If cTabAudit == 'O0H'
						nVlrAtu  := 0
						nCorAtu  := 0
						nJurAtu  := 0
						cCajuri  := &(cTabPad + "->NT2_CAJURI")
						cCodGar  := &(cTabPad + "->NT2_COD")
						cFilPro  := &(cTabPad + "->NT2_FILIAL")

						If &(cTabSql + "->LEVANTAMENTO") > 0

							If len(aHistVlr) == 0 .or. len(aHistVlr[2]) == 0 .or. aHistVlr[1] <> cCajuri
								aSize(aHistVlr,0)
								aHistVlr := { cCajuri, JA098CriaS(cCajuri,cFilPro) }
							EndIf

							For nI := 1 to Len(aHistVlr[2])
								If aHistVlr[2][nI][8] == cCodGar
									If aHistVlr[2][nI][4] == 'SF'
										nVlrAtu += aHistVlr[2][nI][5]
									EndIf

									If aHistVlr[2][nI][4] == 'SCA'
										nCorAtu += aHistVlr[2][nI][5]
									EndIf

									If aHistVlr[2][nI][4] == 'SJA'
										nJurAtu += aHistVlr[2][nI][5]
									EndIf
								EndIf
							Next nI

							&(cTabAudit + "->O0H_VLRATU") := nVlrAtu
							&(cTabAudit + "->O0H_VCPROV") := nCorAtu
							&(cTabAudit + "->O0H_VJPROV") := nJurAtu
							
						Else
							&(cTabAudit + "->O0H_VLRATU") := &(cTabPad + "->NT2_VLRATU")
							&(cTabAudit + "->O0H_VCPROV") := &(cTabPad + "->NT2_VCPROV")
							&(cTabAudit + "->O0H_VJPROV") := &(cTabPad + "->NT2_VJPROV")

							
							If &(cTabPad + "->NT2_VLRATU") == 0
								&(cTabAudit + "->O0H_VLRATU") := &(cTabPad + "->NT2_VALOR")
							EndIf
						EndIf
					EndIf

				(cTabAudit)->( MsUnLock() )

				//Grava campos complementares
				For nCont:=1 To Len(aCmpsCompl)

					//Carrega nome do campo ou formula
					If !Empty(aCmpsCompl[nCont][1])
						cCampo 	  := AllTrim(aCmpsCompl[nCont][1])
						xConteudo := cTabPad + "->" + cCampo
					Else
						cCampo 	  := AllTrim(aCmpsCompl[nCont][2])
						xConteudo := cCampo
					EndIf

					TRY EXCEPTION
						//Condição que pode dar erro
						xConteudo := &(xConteudo)
					CATCH EXCEPTION USING oError
						//Se ocorreu erro
						xConteudo := I18n(STR0106, {cCampo}) + AllTrim(oError:Description) 	//"Erro na execução do campo\formula. Campo complementar (#1): "
						lErro	  := .T.
					END TRY

					If lErro
						Exit
					EndIf

					xConteudo := TrataCmp(xConteudo)

					RecLock("O0C", .T.)
						O0C->O0C_FILIAL := xFilial('O0C')
						O0C->O0C_MARCA  := MV_PAR01
						O0C->O0C_ENTAUD := cTabAudit
						O0C->O0C_CHVAUD := &(cTabAudit + "->(" + cChaveO0X + ")")
						O0C->O0C_CMPFOR := cCampo
						O0C->O0C_VALOR  := xConteudo
					O0C->( MsUnLock() )
				Next nCont

				If __lSX8
					ConfirmSX8()
				EndIf

			//Desabilita controle de Transacao
			End Transaction
		EndIf

		If lErro
			Exit
		EndIf

		(cTabSql)->( DbSkip() )
	EndDo

	If lErro
		nRet := -1
		JurMsgErro(xConteudo)
	EndIf

	RestArea( aArea )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataCmp
Transforma o conteudo em caracter

@param xConteudo  Conteúdo a ser tratado

@author  Rafael Tenorio da Costa
@since 	 11/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TrataCmp(xConteudo)

	Do Case
		Case ValType(xConteudo) == "D"
			xConteudo := DtoS(xConteudo)
		Case ValType(xConteudo) == "N"
			xConteudo := cValToChar(xConteudo)
		//OtherWise
		//	xConteudo := AllTrim(xConteudo)
	EndCase

Return xConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} SqlVlProv
Query que soma os Objetos da ultima instancia, por tipo de provisão sendo
retornado o valor normal ou valor atualizado.

Query retirada da função JA094VlDis.

@param cTipoProv Tipo de provisão
@param lAtual    Considera valores atualizados ou não

@author  Rafael Tenorio da Costa
@since 	 11/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SqlVlProv(cTipoProv, lAtual)

Local cQuery     := ""	
Local lPedidos   := .F.

	cQuery := " SELECT ISNULL("
	cQuery += 				" SUM ("

	//Valores atualizados
	If lAtual
		//Verifica se a rotina de Pedidos foi implementada 
		If Select("NSY") > 0
			lPedidos := NSY->( FieldPos('NSY_CVERBA') ) > 0
		Else
			DBSelectArea("NSY")
				lPedidos := NSY->( FieldPos('NSY_CVERBA') ) > 0
			NSY->( DBCloseArea() )
		EndIf

		If lPedidos
			cQuery +=              "( CASE WHEN NSY_CVERBA <> '' THEN ( "
			cQuery +=                      " ISNULL( (CASE WHEN NSY_DTCONT > ''  THEN NSY_VLCONA ELSE NSY_PEVLRA END), 0) "
			cQuery +=                      " + ISNULL( (CASE WHEN NSY_TRVLRA > 0 THEN NSY_TRVLRA ELSE NSY_TRVLR  END), 0) "
			cQuery +=                      " + ISNULL( (CASE WHEN NSY_MUATT  > 0 THEN NSY_MUATT  ELSE NSY_VLRMT  END), 0) "
			cQuery +=                      " + ISNULL( (CASE WHEN NSY_V2VLRA > 0 THEN NSY_V2VLRA ELSE NSY_V2VLR  END), 0) "
			cQuery +=                      " + ISNULL( (CASE WHEN NSY_MUATU2 > 0 THEN NSY_MUATU2 ELSE NSY_VLRMU2 END), 0) "
			cQuery +=                      " + ISNULL( (CASE WHEN NSY_V1VLRA > 0 THEN NSY_V1VLRA ELSE NSY_V1VLR  END), 0)) " //Se tiver dados de pedidos feito pela tela nova, soma a multa, honorário e encargo.
			cQuery +=                    " ELSE (CASE WHEN NSY_DTCONT > '' THEN NSY_VLCONA "
			cQuery +=                               " WHEN NSY_TRDATA > '' THEN NSY_TRVLRA "
			cQuery +=                               " WHEN NSY_DTJUR2 > '' THEN NSY_V2VLRA "
			cQuery +=                               " WHEN NSY_V1DATA > '' THEN NSY_V1VLRA "
			cQuery +=                          " ELSE NSY_PEVLRA END) "
			cQuery +=                    " END) "
		Else
			cQuery +=              " (CASE WHEN NSY_VLCONA > 0 THEN NSY_VLCONA "
			cQuery +=                    " WHEN NSY_TRVLRA > 0 THEN NSY_TRVLRA "
			cQuery +=                    " WHEN NSY_V2VLRA > 0 THEN NSY_V2VLRA "
			cQuery +=                    " WHEN NSY_V1VLRA > 0 THEN NSY_V1VLRA "
			cQuery +=                    " ELSE NSY_PEVLRA "
			cQuery +=              " END) "
		EndIf

	//Valores normais
	Else
		cQuery +=				" (CASE WHEN NSY_VLCONT > 0 THEN NSY_VLCONT "
		cQuery +=					  " WHEN NSY_TRVLR > 0 THEN NSY_TRVLR "
		cQuery +=					  " WHEN NSY_V2VLR > 0 THEN NSY_V2VLR "
		cQuery +=					  " WHEN NSY_V1VLR > 0 THEN NSY_V1VLR "
		cQuery +=					  " ELSE NSY_PEVLR "
		cQuery +=				" END) "
	EndIf

	cQuery +=				" )"
	cQuery +=			", 0) TOTAL"
	cQuery += " FROM " +RetSqlName("NSY")+ " NSY INNER JOIN " +RetSqlName("NQ7")+ " NQ7"
	cQuery +=                                          " ON NQ7_FILIAL = '" +xFilial("NQ7") + "' AND NSY_CPROG = NQ7_COD"
	cQuery += " WHERE NSY_FILIAL = NSZ_FILIAL"
	cQuery +=       " AND NSY_CAJURI = NSZ_COD"
	cQuery +=       " AND NQ7_TIPO = '" + cTipoProv + "'"	//1=Provavel;2=Possivel;3=Remoto;4=Incontroverso
	cQuery +=       " AND NSY.D_E_L_E_T_ = ' '"
	cQuery +=       " AND NQ7.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} RetQtdSql
Retorna a quantidade de registros da query.

@param cSql - Query principal executada

@author  Rafael Tenorio da Costa
@since 	 26/02/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetQtdSql(cSql)

Local aArea   := GetArea()
Local cSqlQtd := ""
Local cTabQtd := GetNextAlias()
Local nQuant  := 0

	//Executa query que retorna a quantidade de processos
	cSqlQtd := "SELECT COUNT(1) QTD FROM ( " + cSql + " ) QUANTIDADE"

	cSqlQtd := ChangeQuery(cSqlQtd)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSqlQtd), cTabQtd, .F., .T.)

	If !(cTabQtd)->( Eof() )
		nQuant := (cTabQtd)->QTD
	EndIf
	(cTabQtd)->( DbCloseArea() )

	RestArea(aArea)

Return nQuant
