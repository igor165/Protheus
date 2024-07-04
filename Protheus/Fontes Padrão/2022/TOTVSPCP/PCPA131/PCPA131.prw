#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA131.CH"

/*/{Protheus.doc} PCPA131()
Cadastro do Calendário MRP
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return NIL
/*/
Function PCPA131()

	Local aArea := GetArea()
	Local oBrowse

	//Proteção do fonte para não ser utilizado pelos clientes neste momento.
	If !(FindFunction("RodaNewPCP") .And. RodaNewPCP())
		HELP(' ',1,"Help" ,,STR0043,2,0,,,,,,) //"Rotina não disponível nesta release."
		Return
	EndIf

	oBrowse := BrowseDef()
	oBrowse:Activate()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} BrowseDef
Definição do Browse
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return oBrowse
/*/
Static Function BrowseDef()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SVX")
	oBrowse:SetDescription(STR0001) //"Calendário MRP"

Return oBrowse

/*/{Protheus.doc} MenuDef
Definição do Menu
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
Static Function MenuDef()

	Private aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.PCPA131" OPERATION OP_VISUALIZAR ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.PCPA131" OPERATION OP_INCLUIR    ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.PCPA131" OPERATION OP_ALTERAR    ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.PCPA131" OPERATION OP_EXCLUIR    ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0021 ACTION "PCPA131Imp()"    OPERATION OP_INCLUIR    ACCESS 0 //"Importar Calendários"
	ADD OPTION aRotina TITLE STR0040 ACTION "PCPA132()"       OPERATION OP_VISUALIZAR ACCESS 0 //"Validar Períodos"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return oModel
/*/
Static Function ModelDef()

	Local oModel	:= MPFormModel():New("PCPA131")
	Local oStruSVX	:= FWFormStruct(1,"SVX")
	Local oStruSVZ	:= FWFormStruct(1,"SVZ",{|cCampo| ! P131FormVa(cCampo) $ "|VZ_CALEND|"})
	Local oEventDef := PCPA131EVDEF():New()
	Local oEventAPI := PCPA131API():New()

	//Mestre (SVX - Dicionário MRP)
	P131AddSVX(.T., @oStruSVX)
	oModel:AddFields("SVX_MASTER", /*cOwner*/, oStruSVX)
	oModel:GetModel( "SVX_MASTER" ):SetDescription(STR0006) //"Calendário MRP - Mestre"

	//Detalhe - Modelo para exibição da tela (SVZ - Dicionário MRP)
	P131AddSVZ(.T., @oStruSVZ)
	oStruSVX:SetProperty( "VX_DATAINI", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"P131VldPer('VX_DATAINI')"))
	oStruSVX:SetProperty( "VX_DATAFIM", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"P131VldPer('VX_DATAFIM')"))
	oStruSVZ:SetProperty( "VZ_HORAINI", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"P131VldHor('VZ_HORAINI')"))
	oStruSVZ:SetProperty( "VZ_HORAFIM", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"P131VldHor('VZ_HORAFIM')"))
	oStruSVZ:SetProperty( "VZ_INTERVA", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"P131VldHor('VZ_INTERVA')"))

	oModel:AddGrid(  "SVZ_DETAIL", "SVX_MASTER", oStruSVZ)
	oModel:GetModel( "SVZ_DETAIL" ):SetDescription(STR0007) //"Calendário MRP - Detalhe"
	oModel:SetRelation("SVZ_DETAIL", { { 'VZ_FILIAL', 'xFilial("SVZ")' },{ 'VZ_CALEND', 'VX_CALEND' } }, SVZ->( IndexKey( 1 ) ) )
	oModel:GetModel( "SVZ_DETAIL" ):SetOptional( .T. )
	oModel:GetModel( "SVZ_DETAIL" ):SetOnlyQuery()
	oModel:GetModel( "SVZ_DETAIL" ):SetUniqueLine( {"VZ_DATA"} )

	//Detalhe - Modelo para realizar o Commit (SVZ - Dicionário MRP)
	oModel:AddGrid(  "SVZ_COMMIT", "SVX_MASTER", oStruSVZ )
	oModel:GetModel( "SVZ_COMMIT" ):SetDescription(STR0007) //"Calendário MRP - Detalhe"
	oModel:GetModel( "SVZ_COMMIT" ):SetOptional( .F. )
	oModel:GetModel( "SVZ_COMMIT" ):SetUniqueLine( {"VZ_DATA"} )
	oModel:SetRelation("SVZ_COMMIT",{{"VZ_FILIAL","xFilial('SVZ')"},{"VZ_CALEND","VX_CALEND"}}, SVZ->(IndexKey(1)))

	//Demais definições do modelo
	oModel:SetPrimaryKey( {} )
	oModel:SetDescription(STR0001) //"Calendário MRP"
	oModel:InstallEvent("PCPA131EVDEF", /*cOwner*/, oEventDef)
	oModel:InstallEvent("PCPA136EVAPI", /*cOwner*/, oEventAPI)

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return oView
/*/
Static Function ViewDef()

	Local oModel	:= FWLoadModel("PCPA131")
	Local oStruSVX	:= FWFormStruct(2,"SVX")
	Local oStruSVZ	:= FWFormStruct(2,"SVZ",{|cCampo| ! P131FormVa(cCampo) $ "|VZ_CALEND|"})
	Local oView		:= FWFormView():New()

	oView:SetModel( oModel )

	//Mestre (SVX - Dicionário MRP)
	P131AddSVX(.F., @oStruSVX)
	oView:AddField("VIEW_SVX", oStruSVX, "SVX_MASTER" )

	//Detalhe (SVZ - Dicionário MRP)
	oView:AddGrid( "VIEW_SVZ_DETAIL", oStruSVZ, "SVZ_DETAIL" )
	oView:SetViewProperty("VIEW_SVZ_DETAIL", "GRIDSEEK")
	oView:SetViewProperty("VIEW_SVZ_DETAIL", "GRIDDOUBLECLICK", {{|| P131DClick()}})

	//Detalhe (SVZ - Dicionário MRP)
	oView:AddGrid( "VIEW_SVZ_COMMIT", oStruSVZ, "SVZ_COMMIT" )
	oView:SetViewProperty("VIEW_SVZ_COMMIT", "GRIDSEEK")

	oView:CreateHorizontalBox( "HEADER", 80, , .T.) //Tamanho em Pixels
	oView:CreateHorizontalBox( "DETAIL_VISIVEL", 100 )
	oView:CreateHorizontalBox( "DETAIL_INVISIVEL", 0 )

	oView:SetOwnerView( "VIEW_SVX",	"HEADER" )
	//Os boxs DETAIL_VISIVEL e DETAIL_INVISIVEL são setados na função P131CanAct
	oView:SetViewCanActivate({ |oView| P131CanAct(oView) })

	oView:AddUserButton(STR0008, "", {|oView| ReplicaHor(oView)}, , , {MODEL_OPERATION_UPDATE,MODEL_OPERATION_INSERT}, .T.) //"Replicar Horário"

Return oView

/*/{Protheus.doc} P131AddSVX
Altera a estrutura SVX incluindo campos que não existem no dicionário
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@param 01 lModel, lógico, indica se é estrutura de Model ou View
@param 02 oStru,  objeto, estrutura a ser alterada
@return Nil
/*/
Static Function P131AddSVX(lModel, oStru)

	If lModel
		//Controle interno do modelo para saber se foi alterada a Data nicial ou Final (campo não exibido em tela)
		oStru:AddField( STR0018						,;	// [01]  C   Titulo do campo  - "Data Alterada"
						STR0018						,;	// [02]  C   ToolTip do campo - "Data Alterada"
						"VX_DATALT"				,;	// [03]  C   Id do Field
						"L", 1, 0, , NIL, NIL, .F.	,;
						{|| .F.}					,;	// [11]	 B   Inicialização do campo
						NIL, NIL, .T.)

		oStru:AddTrigger("VX_DATAINI", "VX_DATALT", {||.T.}, {||.T.})
		oStru:AddTrigger("VX_DATAFIM", "VX_DATALT", {||.T.}, {||.T.})
	EndIf

Return

/*/{Protheus.doc} P131AddSVZ
Altera a estrutura SVZ incluindo campos que não existem no dicionário
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@param 01 lModel, lógico, indica se é estrutura de Model ou View
@param 02 oStru,  objeto, estrutura a ser alterada
@return Nil
/*/
Static Function P131AddSVZ(lModel, oStru)

	If lModel
		//Controle interno do modelo para saber se a linha teve o campo Hora Inicial, Final ou Intervalo alterado (campo não exibido em tela)
		oStru:AddField( STR0019			,;	// [01]  C   Titulo do campo  - "Linha Alterada"
						STR0019			,;	// [02]  C   ToolTip do campo - "Linha Alterada"
						"SVZ_LINALT"	,;	// [03]  C   Id do Field
						"L", 1, 0, , NIL, NIL, .F., NIL, NIL, NIL, .T.)

		//Controle interno do modelo para saber se a linha precisa ser integrada com o MRP (API)
		oStru:AddField( STR0045                   ,;	// [01]  C   Titulo do campo  - "Integra Linha"
						STR0045                   ,;	// [02]  C   ToolTip do campo - "Integra Linha"
						"SVZ_INTLIN"              ,;	// [03]  C   Id do Field
						"L", 1, 0, , NIL, NIL, .F.,;
						{|| .F.}                  ,;	// [11]	 B   Inicialização do campo
						NIL, NIL, .T.)
	EndIf

Return

/*/{Protheus.doc} P131FormVa
Função para formatar a variável para utilização do operador $
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@param 01 cVar, caracter, campo a ser tratado
@return cVar, caracter, campo formatado
/*/
Static Function P131FormVa(cVar)

	cVar := "|" + AllTrim(cVar) + "|"

Return cVar

/*/{Protheus.doc} P131VldHor
Função para validar a hora informada e replicar para as demais linhas (se marcado o check)
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@param 01 cCampo, caracter, ID do campo a ser validado
@param 02 cHora , caracter, hora a ser validada (se não passado)
@return lOk, lógico, indica se o campo está válido
/*/
Function P131VldHor(cCampo, cHora)

	Local oModel    := FWModelActive()
	Local oModelSVZ := oModel:GetModel("SVZ_DETAIL")
	Local nLine     := oModelSVZ:GetLine()
	Local lOk       := .T.
	Local cSolucao  := STR0014 //"Corrija o campo "
	Default cHora   := oModelSVZ:GetValue(cCampo, nLine)

	//Trata a digitação do campo Hora
	lOk := TrataHora(@cHora)

	//Atualiza o campo tratado
	If !Empty(cCampo)
		cSolucao += AllTrim(RetTitle(cCampo)) + " (" + DToC( oModelSVZ:GetValue("VZ_DATA", nLine) ) + ")"
		oModelSVZ:LoadValue(cCampo, cHora)
	Else
		cSolucao += "'" + cHora + "'."
	EndIf

	//Validação da Hora
	If !lOk
		Help( ,  , "Help", ,  STR0013, 1, 0, , , , , , {cSolucao}) //"Hora inválida."
	EndIf

Return lOk

/*/{Protheus.doc} TrataHora
Função para formatar o campo Hora de acordo com a máscara 99:99 validando a existência da hora
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@param cHora, caracter, hora a ser formatada e validada
@return lOk, lógico, indica se a hora está válida
/*/
Static Function TrataHora(cHora)

	Local lOk := .T.

	If Empty( Subs(cHora,1,1) )			// " X:XX"
		cHora := "0" + Subs(cHora,2,4)	// "0X:XX"
	EndIf

	If Empty( Subs(cHora,2,1) )								// "X :XX"
		cHora := Subs(cHora,1,1) + "0" + Subs(cHora,3,3)	// "X0:XX"
	EndIf

	If Empty( Subs(cHora,4,1) )								// "XX: X"
		cHora := Subs(cHora,1,3) + "0" + Subs(cHora,5,1)	// "XX:0X"
	EndIf

	If Empty( Subs(cHora,5,1) )			// "XX:X "
		cHora := Subs(cHora,1,4) + "0"	// "XX:X0"
	EndIf

	If Val(Subs(cHora, 1, 2)) < 0 .Or. Val(Subs(cHora, 1, 2)) > 24 .Or. Val(Subs(cHora, 4, 2)) < 0 .Or. Val(Subs(cHora, 4, 2)) > 59
		lOk := .F.
	EndIf

	If Val(Subs(cHora, 1, 2)) == 24 .And. Val(Subs(cHora, 4, 2)) <> 0
		lOk := .F.
	EndIf

Return lOk

/*/{Protheus.doc} PCPA131Imp
Função para importar calendários do MATA780
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return Nil
/*/
Function PCPA131Imp()

	Local oGridProc := Nil
	Local cTexto	:= STR0022 + "<br><br>" + STR0032 + "<br>" + STR0033 + "<br><br>" + STR0035 //"De acordo com os parâmetros informados na..."
	Local nRet		:= 0 // == 0 (Rotina não foi executada ou foi pressionado ESC/"Cancelar"
	                     // == 1 (Rotina foi executada, mas havia erro nos parâmetros da Pergunta)
	                     // == 2 (Rotina executada sem erros)
	                     // == 3 (Rotina executada com algum erro)

	oGridProc := FWGridProcess():New("PCPA131", STR0021, cTexto, {|oGridProc| nRet := P131Import(oGridProc)},"PCPA131IMP") //"Importar Calendários"
	oGridProc:SetMeters(1)

	While .T.
		nRet := 0
		oGridProc:Activate()
		If nRet != 1
			Exit
		EndIf
	End

	If nRet == 2
		MsgInfo(STR0034,; //"Importação finalizada"
		        STR0021)  //"Importação finalizada com sucesso."
	ElseIf nRet > 3
		Help( ,  , "Help", ,  STR0024,; //"Importação finalizada com erro."
			 1, 0, , , , , , {STR0025}) //"Verifique o Log de Processos."
	EndIf

Return

/*/{Protheus.doc} P131Import
Função para processar a importação dos calendários
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@param  oGridProc, objeto  , objeto que está realizando o processamento
@return nRet     , numérico, indicador de status do processamento
/*/
Static Function P131Import(oGridProc)

	Local aArea			:= GetArea()
	Local aErro			:= {}
	Local oModel		:= FwLoadModel("PCPA131")
	Local cQuery		:= ""
	Local cAloc			:= ""
	Local cHoraIni		:= ""
	Local cHoraFim		:= ""
	Local cIntervalo	:= ""
	Local cDiaSemana	:= ""
	Local cCalImport	:= ""
	Local cCalend       := ""
	Local cAliasSH7		:= GetNextAlias() //Cadastro de Calendário
	Local nIndDia		:= 0
	Local nImportado	:= 0
	Local nRet			:= 2
	Local dData			:= NIL
	Local lHouveErro	:= .F.
	Local nPrecisao 	:= GetMV("MV_PRECISA")

	//Verifica se os parâmetros foram informados.
	If Empty(MV_PAR01)
		oGridProc:SaveLog(STR0046) //"Código do calendário para importação não foi informado."
		Help( , , "Help", , STR0046, 1, 0) //"Código do calendário para importação não foi informado."
		Return 1
	EndIf

	If Empty(MV_PAR02) .Or. Empty(MV_PAR03)
		oGridProc:SaveLog(STR0039) //"A Data Inicial e/ou a Data Final não foram informadas."
		Help( ,  , "Help", ,  STR0039, 1, 0) //"A Data Inicial e/ou a Data Final não foram informadas."
		Return 1
	EndIf

	If MV_PAR02 > MV_PAR03
		oGridProc:SaveLog(STR0047) //"Período inicial não pode ser maior que o período final."
		Help( , , "Help", , STR0047, 1, 0) //"Período inicial não pode ser maior que o período final."
		Return 1
	EndIf

	//Verifica se já existe outro calendário cadastrado no range de datas informado.
	If existCalend(MV_PAR02, MV_PAR03, "", @cCalend)
		oGridProc:SaveLog(STR0048 + AllTrim(cCalend) + "'.") //"O período escolhido não será processado pois tem datas concorrentes com o calendário 'xxx'"
		Help( , , "Help", , STR0048 + AllTrim(cCalend) + "'.", 1, 0) //"O período escolhido não será processado pois tem datas concorrentes com o calendário 'xxx'"
		Return 1
	EndIf

	If ! SH7->(dbSeek(xFilial("SH7")+MV_PAR01))
		oGridProc:SaveLog(STR0052) //"Calendário informado para importação não existe."
		Help( , , "Help", , STR0052, 1, 0) //"Calendário informado para importação não existe."
		Return 1
	EndIf

	oGridProc:SetMaxMeter((MV_PAR03-MV_PAR02)+1, 1, STR0049) //"Processando a importação de calendários"

	cQuery := "SELECT H7_CODIGO, H7_DESCRI, H7_ALOC, R_E_C_N_O_ "
	cQuery +=  " FROM " + RetSqlName("SH7")
	cQuery += " WHERE H7_FILIAL  = '" + xFilial("SH7")    + "'"
	cQuery +=   " AND H7_CODIGO  = '" + MV_PAR01 + "'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasSH7, .F., .T.)

	dbSelectArea("SH9")
	SH9->( dbSetOrder(1) )

	While !(cAliasSH7)->(Eof())

		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		nImportado++

		If (cAliasSH7)->(FCOUNT()) == 4
			cAloc := (cAliasSH7)->H7_ALOC
		Else
			SH7->(dbGoTo( (cAliasSH7)->R_E_C_N_O_ ))
			cAloc := SH7->H7_ALOC
		EndIf

		cHoraSeg	:= SubStr(cAloc, 01, (24 * nPrecisao))
		cHoraTer	:= SubStr(cAloc, (24 * nPrecisao)+1, (24 * nPrecisao))
		cHoraQua	:= SubStr(cAloc, (24 * 2 * nPrecisao)+1, (24 * nPrecisao))
		cHoraQui	:= SubStr(cAloc, (24 * 3 * nPrecisao)+1, (24 * nPrecisao))
		cHoraSex	:= SubStr(cAloc, (24 * 4 * nPrecisao)+1, (24 * nPrecisao))
		cHoraSab	:= SubStr(cAloc, (24 * 5 * nPrecisao)+1, (24 * nPrecisao))
		cHoraDom	:= SubStr(cAloc, (24 * 6 * nPrecisao)+1, (24 * nPrecisao))

		oModel:SetValue("SVX_MASTER", "VX_DESCAL",  AllTrim((cAliasSH7)->H7_DESCRI))
		oModel:SetValue("SVX_MASTER", "VX_DATAINI", MV_PAR02)
		oModel:SetValue("SVX_MASTER", "VX_DATAFIM", MV_PAR03)

		If oModel:VldData("SVX_MASTER", .F.)
			oModel:GetModel("SVZ_DETAIL"):SetNoInsertLine( .F. )
			oModel:GetModel("SVZ_DETAIL"):SetNoUpdateLine( .F. )
			oModel:GetModel("SVZ_DETAIL"):SetNoDeleteLine( .F. )

			For nIndDia := 1 To oModel:GetModel("SVZ_DETAIL"):Length()

				oModel:GetModel("SVZ_DETAIL"):GoLine(nIndDia)

				dData		:= oModel:GetModel("SVZ_DETAIL"):GetValue("VZ_DATA", nIndDia)
				cExcecao	:= ""

				oGridProc:SetIncMeter(1, STR0027 + (cAliasSH7)->H7_CODIGO + " (" + AllTrim((cAliasSH7)->H7_DESCRI) + ") - " + DtoC(dData)) //"Calendário "

				SH9->( dbSeek(xFilial("SH9") + "E" + ;
				              SPACE(GetSx3Cache("H9_CCUSTO", "X3_TAMANHO")) + ;
				              SPACE(GetSx3Cache("H9_RECURSO","X3_TAMANHO")) + ;
				              DTOS(dData)) )
				If !SH9->(Eof())                    .And. ;
				   SH9->H9_FILIAL == xFilial("SH9") .And. ;
				   SH9->H9_TIPO   == "E"            .And. ;
				   SH9->H9_DTINI  == dData
					cExcecao := SH9->H9_ALOC
				EndIf

				If Empty(cExcecao)
					cDiaSemana := oModel:GetModel("SVZ_DETAIL"):GetValue("VZ_DSEMANA", nIndDia)

					If cDiaSemana == "1"
						ConvAloc(cHoraDom, @cHoraIni, @cHoraFim, @cIntervalo)
					ElseIf cDiaSemana == "2"
						ConvAloc(cHoraSeg, @cHoraIni, @cHoraFim, @cIntervalo)
					ElseIf cDiaSemana == "3"
						ConvAloc(cHoraTer, @cHoraIni, @cHoraFim, @cIntervalo)
					ElseIf cDiaSemana == "4"
						ConvAloc(cHoraQua, @cHoraIni, @cHoraFim, @cIntervalo)
					ElseIf cDiaSemana == "5"
						ConvAloc(cHoraQui, @cHoraIni, @cHoraFim, @cIntervalo)
					ElseIf cDiaSemana == "6"
						ConvAloc(cHoraSex, @cHoraIni, @cHoraFim, @cIntervalo)
					ElseIf cDiaSemana == "7"
						ConvAloc(cHoraSab, @cHoraIni, @cHoraFim, @cIntervalo)
					EndIf
				Else
					ConvAloc(cExcecao, @cHoraIni, @cHoraFim, @cIntervalo)
				EndIf

				oModel:GetModel("SVZ_DETAIL"):SetValue("VZ_HORAINI", cHoraIni)
				oModel:GetModel("SVZ_DETAIL"):SetValue("VZ_HORAFIM", cHoraFim)
				oModel:GetModel("SVZ_DETAIL"):SetValue("VZ_INTERVA", cIntervalo)

				If oModel:HasErrorMessage()
					lHouveErro := .T.
					Exit
				EndIf
			Next nIndDia

			If !lHouveErro
				oGridProc:SetIncMeter(1, STR0050) //"Gravando dados..."
				If oModel:VldData()
					If !oModel:CommitData()
						lHouveErro := .T.
					EndIf
				Else
					lHouveErro := .T.
				EndIf
			EndIf
		Else
			lHouveErro := .T.
		EndIf

		If lHouveErro
			aErro	:= oModel:GetErrorMessage( .T. )
			cMsgLog	:=	STR0027	 + (cAliasSH7)->H7_CODIGO + ": " + AllTrim(aErro[6]) + ; //"Calendário "
						IIF( Empty(aErro[7]), "", " - " + STR0028 + AllTrim(aErro[7]) )       + ; //"Solução: "
						IIF( Empty(aErro[8]), "", " - " + STR0029 + AllTrim(aErro[8]) + ").")     //"Valor informado: "
			oGridProc:SaveLog(cMsgLog)
			oModel:DeActivate()
			nRet := 3
			Exit
		Else
			If nImportado == 1
				cCalImport := (cAliasSH7)->H7_CODIGO + " (" + oModel:GetModel("SVX_MASTER"):GetValue("VX_CALEND") + ")"
			Else
				cCalImport += ", " + (cAliasSH7)->H7_CODIGO + " (" + oModel:GetModel("SVX_MASTER"):GetValue("VX_CALEND") + ")"
			EndIf
		EndIf

		oModel:DeActivate()
		(cAliasSH7)->(dbSkip())
	End

	SH9->(DbCloseArea())

	If nImportado > 0
		oGridProc:SaveLog(STR0038 + AllTrim(cCalImport)) //"Importação realizada. Calendários importados: "
	Else
		oGridProc:SaveLog(STR0051 + AllTrim(MV_PAR01) + "'.") //"Não foi encontrado o calendário 'xxx'.
	EndIf

	(cAliasSH7)->(DbCloseArea())

	RestArea(aArea)

Return nRet

/*/{Protheus.doc} ConvAloc
Converte H7_ALOC para hora "HH:MM"
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@param 01 cAloc     , caracter, horário no formato do calendário padrão
@param 02 cHoraIni  , caracter, hora inicial a ser extraída (passado por referência)
@param 03 cHoraFim  , caracter, hora final a ser extraída (passado por referência)
@param 04 cIntervalo, caracter, intervalo a ser extraído (passado por referência)
@return Nil
/*/
Static Function ConvAloc(cAloc, cHoraIni, cHoraFim, cIntervalo)

	Local nInicio	:= 0
	Local nFim		:= 0
	Local nInd		:= 0
	Local nQtdPausa	:= 0

	nInicio	:=  AT("X", cAloc)
	nFim	:= RAT("X", cAloc)

	If nInicio != nFim
		For nInd := nInicio To nFim
			If SubStr(cAloc, nInd, 1) == " "
				nQtdPausa += 1
			EndIf
		Next nInd

		nInicio--
	EndIf

	cHoraIni	:= ConvHora(nInicio)
	cHoraFim	:= ConvHora(nFim)
	cIntervalo	:= ConvHora(nQtdPausa)

Return

/*/{Protheus.doc} ConvHora
Converte para hora
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@param nQtdHora, numérico, quantidade de hora a ser convertida para HH:MM
@return PadL( cValToChar(nHora), 2, "0" ) + ":" + PadL( cValToChar(nMinuto), 2, "0" )
/*/
Static Function ConvHora(nQtdHora)

	Local nHora		:= 0
	Local nMinuto	:= 0
	Local nPrecisao := GetMV("MV_PRECISA")

	nHora	:= nQtdHora / nPrecisao
	nHora	:= NoRound( nHora, 0 )
	nMinuto	:= Mod( nQtdHora, nPrecisao )
	nMinuto	:= nMinuto * (60 / nPrecisao)

Return PadL( cValToChar(nHora), 2, "0" ) + ":" + PadL( cValToChar(nMinuto), 2, "0" )

/*/{Protheus.doc} P131CanAct
Trata a exibição da View COMMIT ou DETAIL
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@param oView, objeto, view principal
@return .T.
/*/
Static Function P131CanAct(oView)

	//INSERT ou UPDATE
	If oView:GetOperation() == OP_INCLUIR .Or. oView:GetOperation() == OP_ALTERAR
		//As manipulações são feitas no model DETAIL e repassadas ao final (GridPosVld) para o model COMMIT
		oView:SetOwnerView("VIEW_SVZ_DETAIL", "DETAIL_VISIVEL")
		oView:SetOwnerView("VIEW_SVZ_COMMIT", "DETAIL_INVISIVEL")
	Else
		//Exclusão e Visualização exibem o modelo COMMIT que já faz o Relation automaticamente
		oView:SetOwnerView("VIEW_SVZ_DETAIL", "DETAIL_INVISIVEL")
		oView:SetOwnerView("VIEW_SVZ_COMMIT", "DETAIL_VISIVEL")
	EndIf

Return .T.

/*/{Protheus.doc} P131DClick
Função executada ao dar duplo clique no Grid dos dias/horas
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return .T.
/*/
Static Function P131DClick()

	Local oModel := FWModelActive()

	If Empty(oModel:GetModel("SVZ_DETAIL"):GetValue("VZ_DATA", 1))
		oModel:GetModel("SVZ_DETAIL"):SetNoUpdateLine( .T. )
		Help( ,  , "Help", ,  STR0030,; //"Data Inicial e Data Final não informadas."
			 1, 0, , , , , , {STR0031}) //"Informe os campos Data Inicial e Data Final para preencher os dias e horários."
	Else
		oModel:GetModel("SVZ_DETAIL"):SetNoUpdateLine( .F. )
	EndIf

Return .T.

/*{Protheus.doc} P131VldPer
Função que verifica se as novas datas nao criam um perí­odo concorrente com outro calendário
@author Douglas Heydt
@since 04/06/2019
@version 1.0
@param cField, caracter, ID do campo a ser validado
@return lOk, lógico, indica se o campo está válido
/*/
Function P131VldPer(cField)

	Local aArea		:= GetArea()
	Local oModel	:= FWModelActive()
	Local oModelSVX := oModel:GetModel("SVX_MASTER")
	Local cCod		:= oModelSVX:Getvalue("VX_CALEND")
	Local cCalend   := ""
	Local lOk 		:= .T.
	Local dtIni
	Local dtFim
	Local oEvent	:= gtMdlEvent(oModel, "PCPA131EVDEF")

	dtIni := oModelSVX:GetValue("VX_DATAINI")
	dtFim := oModelSVX:GetValue("VX_DATAFIM")

	If !Empty(dtIni) .And. !Empty(dtFim)
		If existCalend(dtIni, dtFim, cCod, @cCalend)
			lOk := .F.
		EndIf
	EndIf

	RestArea(aArea)
	If !lOk
		Help( ,  , "Help", ,  STR0044 + AllTrim(cCalend),1, 0, , , , , , {}) //"O período escolhido não pode ser efetivado pois tem datas concorrentes com o calendário: "
	Else
		//Se a data foi alterada, seta a varisável de controle da alteração da Data Mestre
		oEvent:CarregaGrid(cField, Iif(cField == "VX_DATAINI", dtIni, dtFim))
	EndIf

Return lOk

/*/{Protheus.doc} gtMdlEvent
Recupera a referência do objeto dos Eventos do modelo.
@author Marcelo Neumann
@since 23/07/2019
@version 1.0
@return lOk
@param oModel  , Object   , Modelo de dados
@param cIdEvent, Character, ID do evento que se deseja recuperar.
@return oEvent , Object   , Referência do evento do modelo de dados.
/*/
Static Function gtMdlEvent(oModel, cIdEvent)
	Local nIndex  := 0
	Local oEvent  := Nil
	Local oMdlPai := Nil

	If oModel != Nil
		oMdlPai := oModel:GetModel()
	EndIf

	If oMdlPai != Nil .And. AttIsMemberOf(oMdlPai, "oEventHandler", .T.) .And. oMdlPai:oEventHandler != NIL
		For nIndex := 1 To Len(oMdlPai:oEventHandler:aEvents)
			If oMdlPai:oEventHandler:aEvents[nIndex]:cIdEvent == cIdEvent
				oEvent := oMdlPai:oEventHandler:aEvents[nIndex]
				Exit
			EndIf
		Next nIndex
	EndIf

Return oEvent

/*/{Protheus.doc} existCalend
Verifica se já existe um calendário cadastrado nas datas início/fim.

@type  Static Function
@author lucas.franca
@since 14/08/2019
@version P12.1.28
@param dDataIni , Date     , Data inicial do calendário
@param dDataFim , Date     , Data final do calendário
@param cCalend  , Character, Código de calendário que deve ser desconsiderado da pesquisa.
@param cCalExist, Character, Variável para retornar o código do calendário já existente. Passar por referência.
@return lExiste, Logic, Identifica se já existe um calendário cadastrado nas datas utilizadas
/*/
Static Function existCalend(dDataIni, dDataFim, cCalend, cCalExist)
	Local cAliasQry := ""
	Local cQuery    := ""
	Local lExiste   := .F.

	cCalExist := ""

	cQuery := "SELECT SVX.VX_CALEND "
	cQuery +=  " FROM " + RetSqlName("SVX") + " SVX "
	cQuery += " WHERE SVX.VX_FILIAL = '" + xFilial("SVX") + "' "
	If !Empty(cCalend)
		cQuery +=   " AND SVX.VX_CALEND <> '" + cCalend + "' "
	EndIf
	cQuery +=   " AND ((SVX.VX_DATAINI BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "')"
	cQuery +=     " OR (SVX.VX_DATAFIM BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "') "
	cQuery +=     " OR (SVX.VX_DATAINI <= '" + DTOS(dDataFim) + "' AND VX_DATAFIM >= '" + DTOS(dDataFim) + "')) "
	cQuery +=   " AND SVX.D_E_L_E_T_  = ' ' "

	cQuery    := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	If (cAliasQry)->(!Eof())
		cCalExist := (cAliasQry)->(VX_CALEND)
		lExiste   := .T.
	EndIf
	(cAliasQry)->(dbCloseArea())

Return lExiste

/*/{Protheus.doc} ReplicaHor
Abre uma tela para digitação do horário a ser replicado
@type  Static Function
@author marcelo.neumann
@since 20/01/2019
@version P12
@param oView, Object, Objeto da view ativa.
@return lRet, Logic , indica se o horário foi replicado
/*/
Static Function ReplicaHor(oView)
	Local aBackVar   := Array(2)
	Local oModel     := oView:GetModel()
	Local oModelSVZ  := oModel:GetModel("SVZ_DETAIL")
	Local cHoraIni   := "00:00"
	Local cHoraFim   := "00:00"
	Local cIntervalo := "00:00"
	Local lDomingo   := .F.
	Local lSegunda   := .T.
	Local lTerca     := .T.
	Local lQuarta    := .T.
	Local lQuinta    := .T.
	Local lSexta     := .T.
	Local lSabado    := .F.
	Local lRet       := .T.
	Local nIndDia	 := 1
	Local nQtdDatas	 := oModelSVZ:Length(.F.)

	If oModelSVZ:IsEmpty()
		Return .T.
	EndIf

	DEFINE MSDIALOG oDlg FROM 000,000 TO 200,500 TITLE STR0008 PIXEL  //"Replicar Horário"

	TCheckBox():New(40,  05, STR0053, {|| lSegunda}, oDlg, 80,,, {|| lSegunda := !lSegunda},,,,,,, STR0053) //"Segunda-Feira"
	TCheckBox():New(40,  55, STR0054, {|| lTerca  }, oDlg, 80,,, {|| lTerca   := !lTerca  },,,,,,, STR0054) //"Terça-Feira"
	TCheckBox():New(40, 105, STR0055, {|| lQuarta }, oDlg, 80,,, {|| lQuarta  := !lQuarta },,,,,,, STR0055) //"Quarta-Feira"
	TCheckBox():New(40, 155, STR0056, {|| lQuinta }, oDlg, 80,,, {|| lQuinta  := !lQuinta },,,,,,, STR0056) //"Quinta-Feira"
	TCheckBox():New(40, 205, STR0057, {|| lSexta  }, oDlg, 80,,, {|| lSexta   := !lSexta  },,,,,,, STR0057) //"Sexta-Feira"
	TCheckBox():New(55,  05, STR0058, {|| lSabado }, oDlg, 80,,, {|| lSabado  := !lSabado },,,,,,, STR0058) //"Sábado"
	TCheckBox():New(55,  55, STR0059, {|| lDomingo}, oDlg, 80,,, {|| lDomingo := !lDomingo},,,,,,, STR0059) //"Domingo"

	TGet():New(70,  05, {|u| If(PCount() > 0, cHoraIni   := u, cHoraIni  )}, oDlg, 30, 15, PesqPict('SVZ','VZ_HORAINI'),;
	           {|| lRet := P131VldHor(, @cHoraIni)  },/*09*/,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,;
			   /*20*/,.F.,.F.,/*23*/,"cHoraIni"  ,/*25*/,/*26*/,/*27*/,.F.,.T.,/*30*/,STR0060,1) //"Hora Início"

	TGet():New(70,  55, {|u| If(PCount() > 0, cHoraFim   := u, cHoraFim  )}, oDlg, 30, 15,PesqPict('SVZ','VZ_HORAFIM'),;
	           {|| lRet := P131VldHor(, @cHoraFim)  },/*09*/,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,;
	           /*20*/,.F.,.F.,/*23*/,"cHoraFim"  ,/*25*/,/*26*/,/*27*/,.F.,.T.,/*30*/,STR0061,1) //"Hora Fim"

	TGet():New(70, 105, {|u| If(PCount() > 0, cIntervalo := u, cIntervalo)}, oDlg, 30, 15,PesqPict('SVZ','VZ_INTERVA'),;
	           {|| lRet := P131VldHor(, @cIntervalo)},/*09*/,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,;
	           /*20*/,.F.,.F.,/*23*/,"cIntervalo",/*25*/,/*26*/,/*27*/,.F.,.T.,/*30*/,STR0062,1) //"Intervalo"

	/*
		Variáveis INCLUI e ALTERA definidas como .F. neste ponto, para que a função EnchoiceBar crie os botões com as descrições
		corretas (Confirmar/Cancelar) em todos os pontos.
	*/
	aBackVar[1] := Iif(Type("INCLUI")=="L",INCLUI,Nil)
	aBackVar[2] := Iif(Type("ALTERA")=="L",ALTERA,Nil)
	INCLUI := .F.
	ALTERA := .F.

	ACTIVATE MSDIALOG oDlg CENTER ;
		ON INIT (EnchoiceBar(oDlg, {|| (lRet := .T., IIf(P131HoraOk(cHoraIni,cHoraFim,cIntervalo), oDlg:End(), lRet := .F.))},;
		                           {|| (lRet := .F., oDlg:End())},/*lMsgDel*/,/*aButtons*/,/*nRecno*/,/*cAlias*/,.F.,.F.,.F.,.T.,.F.),;
				 SetKey( K_CTRL_O, {|| (lRet := .T., oDlg:End())} ))

	INCLUI := aBackVar[1]
	ALTERA := aBackVar[2]

	If lRet
		For nIndDia := 1 To nQtdDatas
			If (oModelSVZ:GetValue("VZ_DSEMANA", nIndDia) == "1" .And. lDomingo) .Or. ;
			   (oModelSVZ:GetValue("VZ_DSEMANA", nIndDia) == "2" .And. lSegunda) .Or. ;
			   (oModelSVZ:GetValue("VZ_DSEMANA", nIndDia) == "3" .And. lTerca  ) .Or. ;
			   (oModelSVZ:GetValue("VZ_DSEMANA", nIndDia) == "4" .And. lQuarta ) .Or. ;
			   (oModelSVZ:GetValue("VZ_DSEMANA", nIndDia) == "5" .And. lQuinta ) .Or. ;
			   (oModelSVZ:GetValue("VZ_DSEMANA", nIndDia) == "6" .And. lSexta  ) .Or. ;
			   (oModelSVZ:GetValue("VZ_DSEMANA", nIndDia) == "7" .And. lSabado )

				oModelSVZ:GoLine(nIndDia)
				oModelSVZ:LoadValue("VZ_HORAINI", cHoraIni)
				oModelSVZ:LoadValue("VZ_HORAFIM", cHoraFim)
				oModelSVZ:LoadValue("VZ_INTERVA", cIntervalo)
				oModelSVZ:LoadValue("SVZ_LINALT", .F.)
				oModelSVZ:LoadValue("SVZ_INTLIN", .T.)
			EndIf
		Next nIndDia

		oModelSVZ:GoLine(1)
	EndIf

Return lRet

/*/{Protheus.doc} P131HoraOk
Valida os horários digitados (início, fim e intervalo)
@type Function
@author marcelo.neumann
@since 20/01/2019
@version P12
@param 01 cHoraIni  , Character, Hora início digitada
@param 02 cHoraFim  , Character, Hora Fim digitada
@param 03 cIntervalo, Character, Intervalo digitado
@param 04 cData     , Character, Data que está sendo validada (opcional)
@return Logic, indica se o horário informado é válido
/*/
Function P131HoraOk(cHoraIni, cHoraFim, cIntervalo, cData)

	Local cSolucao := "."

	If !Empty(cData)
		cSolucao := " (" + cData + ")."
	EndIf

	If SubHoras(cHoraFim, cHoraIni) < 0
		Help( ,  , "Help", ,  STR0015,;            //"Hora Inicial não pode ser maior que Hora Final."
			 1, 0, , , , , , {STR0020 + cSolucao}) //"Corrija a Hora Inicial e/ou Final"
		Return .F.
	EndIf

	If SubHoras(cHoraFim, cHoraIni) - SubHoras(cIntervalo,"00:00") < 0
		Help( ,  , "Help", ,  STR0016,;            //"O Intervalo deve ser menor que a quantidade de horas."
			 1, 0, , , , , , {STR0017 + cSolucao}) //"Informe um Intervalo menor ou aumente a quantidade de horas"
		Return .F.
	EndIf

Return .T.
