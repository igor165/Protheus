#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWIZARD.CH"
//#INCLUDE "FISA214.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE MODEL_OPERATION_CANCLOTE	30
Static __nOper  := 0
Static lAutomato := IsBlind()

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA214
Função para gerar o browser
@author Raphael Augustos
@since 11/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Function FISA214()
	Local oBrowse
	private cIdEnt    := FSA095IDEnt()
	private cURL      := Padr(GetNewPar("MV_SPEDURL","http://"),250)

//Verifico se as tabelas existem antes de prosseguir
	IF AliasIndic("CIB")
		CIB->(DbSetOrder(2))
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("CIB")
		//- Definição de Legendas
		oBrowse:AddLegend( "Alltrim(CIB_GNREWS)==''", "BLUE"	    , "Lote Não Transmitido" )
		oBrowse:AddLegend( "Alltrim(CIB_GNREWS)=='T'", "YELLOW"	    , "Lote Transmitido"     )
		oBrowse:AddLegend( "Alltrim(CIB_GNREWS)=='S'", "GREEN"	    , "Lote Autorizado"      )
		oBrowse:AddLegend( "Alltrim(CIB_GNREWS)=='N'", "BLACK"	    , "Lote Não Autorizado"  )
		oBrowse:AddLegend( "Alltrim(CIB_GNREWS)=='C'", "RED"	    , "Lote Cancelado"  )
		oBrowse:SetFilterDefault( " CIB_FILIAL == '" + xFilial("CIB") + "'" )
		oBrowse:SetDescription("GNRE - Múltiplos itens - Entidade:" + cIdEnt )//"GNRE - Múltiplos itens"
		oBrowse:SetMenuDef( 'FISA214' )
		oBrowse:Activate()
	Else
		Help("",1,"Help","Help","Dicionário desatualizado, favor verificar atualização da GNRE 2.0",1,0)//"Dicionário desatualizado, favor verificar atualização da GNRE 2.0"
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para gerar o browser
@author Raphael Augustos
@since 11/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina	:= {}
	ADD OPTION aRotina TITLE "Visualizar"	    ACTION 'VIEWDEF.FISA214' OPERATION 2 ACCESS 0  //"Visualizar"
	ADD OPTION aRotina TITLE "Gerar Lote"	    ACTION 'VIEWDEF.FISA214' OPERATION 3 ACCESS 0   //"Incluir"
	ADD OPTION aRotina TITLE "Alterar"	        ACTION 'VIEWDEF.FISA214' OPERATION 4 ACCESS 0  //"Alterar"
	ADD OPTION aRotina TITLE "Cancelar"     	ACTION 'FIS214CANC()'    OPERATION 4 ACCESS 0  //"Cancelar"
	ADD OPTION aRotina TITLE "Excluir"	        ACTION 'VIEWDEF.FISA214' OPERATION 5 ACCESS 0  //"Excluir"
	ADD OPTION aRotina TITLE "Transmitir"	    ACTION 'Fis214Trans'     OPERATION 4 ACCESS 0  //"Transmtir"
	ADD OPTION aRotina TITLE 'Monitor'	        ACTION 'Fisa095Mnt'		 OPERATION 10 ACCESS 0  //"Monitor"
	ADD OPTION aRotina TITLE 'Ambiente'	        ACTION 'Fisa095Amb'		 OPERATION 7  ACCESS 0  //"Ambiente"
	ADD OPTION aRotina TITLE 'Imprimir'	        ACTION 'Fisa095Imp'		 OPERATION 11 ACCESS 0  //"Imprimir"
	ADD OPTION aRotina TITLE 'Wizard'	        ACTION 'Fisa095CFG'		 OPERATION 11 ACCESS 0  //"Wizard"
	ADD OPTION aRotina TITLE 'Inf. Extras'	    ACTION 'Fisa095Ext'		 OPERATION 11 ACCESS 0  //"Wizard"
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para gerar o ViewDef
@author Raphael Augustos
@since 11/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel     := FWLoadModel( "FISA214" )
	Local oStruCIB   := FWFormStruct(2,"CIB")
	Local oStruSF6   := FWFormStruct(2,"SF6", {|x| Alltrim(x) $ "MARK,F6_NUMERO,F6_EST,F6_VALOR,F6_DTARREC,F6_DTVENC,F6_DTPAGTO,F6_CODREC"})
	Local oView      := FWFormView():New()


	ViewStru(oStruSF6)
	oStruSF6:SetProperty('*',  MVC_VIEW_CANCHANGE  , .F.)
	oStruSF6:SetProperty('MARK',  MVC_VIEW_CANCHANGE  , .T.)
	oStruSF6:SetProperty('F6_NUMERO',  MVC_VIEW_CANCHANGE  , .T.)

	oStruCIB:SetProperty('*',  MVC_VIEW_CANCHANGE  , .F.)
	oStruCIB:SetProperty('CIB_DTPGTO',  MVC_VIEW_CANCHANGE  , .T.)
	oStruCIB:RemoveField("CIB_IDGUIA")
	oStruCIB:RemoveField("CIB_GNREWS")

// Cancelamento não pode deixar alterar nenhuma campo.
	If __nOper == MODEL_OPERATION_CANCLOTE
		oStruSF6:SetProperty('MARK',  MVC_VIEW_CANCHANGE  , .F.)
		oStruSF6:SetProperty('F6_NUMERO',  MVC_VIEW_CANCHANGE  , .F.)
	EndIf

	oView:SetModel( oModel )

	oView:AddField( "VIEW_CIB" , oStruCIB , "CIBMASTER" )
	oView:AddGrid("VIEW_SF6",oStruSF6,"SF6DETAIL")

	oView:CreateHorizontalBox("SUPERIOR",20)
	oView:CreateHorizontalBox("INFERIOR",80)

	oView:SetOwnerView("VIEW_CIB","SUPERIOR")
	oView:SetOwnerView("VIEW_SF6","INFERIOR")

	oView:EnableTitleView('VIEW_CIB'    , "Lote da GNRE" )  // "GNRE - Cabeçalho do lote"
	oView:EnableTitleView('VIEW_SF6'    , "Guias do lote" ) // "Guias do lote

//oView:SetViewProperty("VIEW_SF6", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineMode,a,b,c| SF6DbClick(oFormulario,cFieldName,nLineGrid,nLineMode,a,b,c) }} )

	oView:AddUserButton("Marcar Todos"      , '', {|| F6Mark(1)} , , , {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE}) 						//"Marcar todos"
	oView:AddUserButton("Desmarcar Todos"   , '', {|| F6Mark(3)} , , , {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE}) 						//"Desmarcar Todos"

	oView:SetViewProperty("VIEW_SF6", "ENABLENEWGRID")
	oView:SetViewProperty("VIEW_SF6", "GRIDSEEK", {.T.})

	oView:SetViewCanActivate( { |oView|  ViewCanAct(oView)} )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para gerar o ModelDef
@author Raphael Augustos
@since 11/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel    := Nil
	Local oStruCIB  := FWFormStruct(1, "CIB")
	Local oStruSF6  := FWFormStruct(1, "SF6")

	ModelStru(oStruSF6)

	oStruSF6:SetProperty('*',  MODEL_FIELD_OBRIGAT , .F.)
	oStruSF6:SetProperty('F6_NUMERO',  MODEL_FIELD_VALID  , {|| .T.})
	oStruCIB:SetProperty('CIB_ID',  MODEL_FIELD_INIT  , FWBuildFeature( STRUCT_FEATURE_INIPAD , 'GetSxENum("CIB","CIB_ID")' ) )

	oModel	:=	MPFormModel():New('FISA214',/*Pre-Validacao*/,{|oModel|bPost(oModel)}, {|oModel| bCommit(oModel)})
	oModel:AddFields("CIBMASTER",,oStruCIB)
	oModel:AddGrid("SF6DETAIL", "CIBMASTER", oStruSF6 , {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| bLinePreF6 (oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)} )

	oModel:SetRelation('SF6DETAIL', { {'F6_FILIAL','xFilial("SF6")'} , {'F6_EST' ,'CIB_EST'} ,{'F6_IDGUIA' ,'CIB_ID'}}, SF6->( IndexKey(1)))
	oModel:SetPrimaryKey( {"CIB_FILIAL","CIB_ID"} )

	oModel:GetModel("SF6DETAIL"):SetOnlyQuery()
	oModel:GetModel("SF6DETAIL"):SetUniqueLine({"F6_FILIAL","F6_NUMERO","F6_EST"})
	oModel:GetModel('CIBMASTER'):SetDescription("Lote da GNRE")  //"Lote da GNRE"

	oModel:SetActivate({|oModel| SetModAct(oModel) })

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} bPost
Função do bloco de cógio bPost do MPFormModel
@author Raphael Augustos
@since 11/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Static Function bPost(oModel)
	Local nOperation := oModel:GetOperation()
	Local lRet       := .T.
	Local dDataPgto  := oModel:GetValue("CIBMASTER", "CIB_DTPGTO" )
	Local nTotal     := oModel:GetValue("CIBMASTER", "CIB_VALOR" )
	Local cTipo      := oModel:GetValue("CIBMASTER", "CIB_TPGNRE" )
	Local aSaveLines := FWSaveRows()

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		If cTipo == "0"
			Help("",1,"Help","Help","É obrigatório que o lote possua mais de uma guia selecionada.",1,0)//"Dicionário desatualizado, favor verificar atualização da GNRE 2.0"
			lRet := .F.
		EndIf
		If dDataPgto < dDataBase
			Help("",1,"Help","Help","A data de pagamento do documento não pode ser menor que a data atual",1,0)//"Dicionário desatualizado, favor verificar atualização da GNRE 2.0"
			lRet := .F.
		EndIf

		IF nTotal <=  0
			Help("",1,"Help","Help","O valor total não pode ser zero. Selecione ao menos uma guia para compor o lote de envio",1,0)//"Dicionário desatualizado, favor verificar atualização da GNRE 2.0"
			lRet := .F.
		EndIf
	EndIf


	FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} bCommit
Função do bloco de cógio bCommit do MPFormModel. 
Se possível colocar todas as validações na função bPost.
@author Raphael Augustos
@since 11/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Static Function bCommit(oModel)
	Local cLog       := ""
	Local cLote      := oModel:GetValue("CIBMASTER", "CIB_ID" )
	Local nOperation := oModel:GetOperation()
	Local nX         := 1
	Local dDataPgto  := oModel:GetValue("CIBMASTER", "CIB_DTPGTO" )
	Local nTotal     := oModel:GetValue("CIBMASTER", "CIB_VALOR" )
	Local oGrid      := oModel:GetModel("SF6DETAIL")
	Local lRet       := .T.

	If oModel:VldData()
		lRet := FWFormCommit(oModel)
		If lRet
			SF6->(DbSetOrder(1))
			For nX := 1 To oGrid:Length()
				oGrid:GoLine(nX)
				lMarca      := oGrid:GetValue("MARK")
				cNumero     := oGrid:GetValue("F6_NUMERO")
				cEst        := oGrid:GetValue("F6_EST")
				If nOperation == MODEL_OPERATION_INSERT .And. lMarca
					If SF6->(DbSeek( xFilial("SF6") + cEst + cNumero  ))
						RecLock("SF6")
						SF6->F6_IDGUIA := cLote
						SF6->(MsUnlock())
					EndIf
					// Alterando o lote
				ElseIf nOperation == MODEL_OPERATION_UPDATE
					If SF6->(DbSeek( xFilial("SF6") + cEst + cNumero ))
						RecLock("SF6")
						SF6->F6_IDGUIA := IIF( lMarca , cLote, '' )
						SF6->F6_IDTSS  := ' '
						SF6->F6_AMBIWS := ' '

						// Operações de cancelamento do lote - Libera as guias (SF6) do lote
						If __nOper == MODEL_OPERATION_CANCLOTE
							IF AllTrim(SF6->F6_GNREWS) == "S"
								SF6->F6_RECIBO := ' '
								SF6->F6_CDBARRA := ' '
								SF6->F6_NUMCTRL := ' '
							EndIf
						EndIf
						SF6->F6_GNREWS := ' '

						SF6->(MsUnlock())
					EndIf
					// Exluindo o lote
				ElseIf nOperation == MODEL_OPERATION_DELETE
					If SF6->(DbSeek( xFilial("SF6") + cEst + cNumero ))
						RecLock("SF6")
						SF6->F6_IDGUIA := ' '
						SF6->F6_IDTSS  := ' '
						SF6->F6_AMBIWS := ' '
						IF AllTrim(SF6->F6_GNREWS) == "S"
							SF6->F6_RECIBO := ' '
							SF6->F6_CDBARRA := ' '
							SF6->F6_NUMCTRL := ' '
						EndIf
						SF6->F6_GNREWS := ' '
						SF6->(MsUnlock())
					EndIf
				EndIf
			Next nX
			If nOperation == MODEL_OPERATION_INSERT
				CIB->(ConfirmSX8())
			EndIf
		Endif
	Else
		If nOperation == MODEL_OPERATION_INSERT
			CIB->(RollBackSX8())
		EndIf
		lRet := .F.
		cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
		cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
		cLog += cValToChar(oModel:GetErrorMessage()[6])
		Help( ,,"FIS214COMMIT",,cLog, 1, 0 )
		AutoGRLog(cLog)
	EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewCanAct
Função que diz se o VIew pode ser ativado
@author Raphael Augustos
@since 11/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Static Function ViewCanAct( oView )
	Local lRet       := .T.
	Local nOperation := oView:GetOperation()
	Local oModel     := oView:GetModel()
	Local oStruSF6   := oView:GetViewStruct("VIEW_SF6")
	Local cParamID   := SM0->M0_CODIGO+SM0->M0_CODFIL+ "FIS214INC"
	Local aParamBox  := {}
	Local aParam     := { CTOD("") , CTOD("") , Space(2)}
	Local cParamTit  := "Filtro das guias do lote"

	oStruSF6:SetProperty('F6_NUMERO',  MVC_VIEW_CANCHANGE  , .F.)
	If nOperation == MODEL_OPERATION_DELETE
		If CIB->CIB_GNREWS == 'S'
			Help("",1,"Help","Help","Não é possível exluir um lote GNRE que foi autorizado.",1,0)//"Dicionário desatualizado, favor verificar atualização da GNRE 2.0"
			lRet := .F.
		EndIf
	EndIf

	If __nOper == MODEL_OPERATION_CANCLOTE
		If AllTrim(CIB->CIB_GNREWS) <> "S"
			Help("",1,"Help","Help","Só é possível cancelar um Lote Autorizado.",1,0)//"Dicionário desatualizado, favor verificar atualização da GNRE 2.0"
			Return .F.
		EndIf
	EndIf

	If nOperation == MODEL_OPERATION_INSERT
		aAdd(aParamBox,{1,"Dt.Pgto Inicial" ,dDataBase,"","","" ,"",60,.T.})
		aAdd(aParamBox,{1,"Dt.Pgto Final"   ,dDataBase,"","","" ,"",60,.T.})
		aAdd(aParamBox,{1,"Estado "         ,aParam[3],"@!","ExistCpo('SX5','12' + MV_PAR03)","12" ,"",20,.T.})

		MV_PAR01 := aParam[01] := ParamLoad(cParamID,aParamBox,1,aParam[01])
		MV_PAR02 := aParam[02] := ParamLoad(cParamID,aParamBox,2,aParam[02])
		MV_PAR03 := aParam[03] := ParamLoad(cParamID,aParamBox,3,aParam[03])

		If ParamBox(aParamBox,cParamTit,@aParam,,,,,,,cParamID,.T.,.T.)
			lRet    := .T.
			If !AllTrim(MV_PAR03) $ "AC,PE,RS,SC"
				Help("",1,"Help","Help","Essa opção não está disponível para o estado selecionado. Verifique a disponibilidade desse recurso junto a SEFAZ.",1,0)//"Não é possível alterar um lote que já foi autorizado pela SEFAZ"
				lRet    := .F.
			EndIf
		Else
			lRet    := .F.
		EndIf

	ElseIf nOperation == MODEL_OPERATION_UPDATE
		oStruSF6:SetProperty('F6_NUMERO',  MVC_VIEW_CANCHANGE  , .T.)
		oStruSF6:SetProperty("F6_NUMERO", MVC_VIEW_LOOKUP , "SF6" )
		If CIB->CIB_GNREWS == 'S' .And. !__nOper == MODEL_OPERATION_CANCLOTE
			Help("",1,"Help","Help","Não é possível alterar um lote que já foi autorizado pela SEFAZ",1,0)//"Não é possível alterar um lote que já foi autorizado pela SEFAZ"
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F6Mark
Função para gerar selecionar todas as GNRE somente nas opções Incluir
@author Raphael Augustos
@since 11/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Static Function F6Mark(nOpc)
	Local oModel	    := FwModelActive()
	Local nX            := 1
	Local oGridSF6      := oModel:GetModel("SF6DETAIL")
	Local aSaveLines    := FWSaveRows()
	Default nOpc        :=  1

	If __nOper == MODEL_OPERATION_CANCLOTE
		Help("",1,"Help","Help","Opção não disponível. Não é necessário marcar ou desmarcar nenhuma guia durante o cancelamento. O cancelamento sempre é total e nunca parcial.",1,0)
		return .F.
	EndIf

	For nX := 1 to oGridSF6:Length()
		oGridSF6:GoLine(nX)
		If nOpc == 1 // Marca Todos
			oGridSF6:SetValue("MARK",.T.)
		ElseIf nOpc == 2 // Inverter seleção
			oGridSF6:SetValue("MARK", IiF( oGridSF6:SetValue("MARK") , .F. , .T.)  )
		ElseIf nOpc // Dermarcar Todos
			oGridSF6:SetValue("MARK",.F.)
		EndIf
	Next nX

	FWRestRows(aSaveLines)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} bLinePreF6
Função de duplo clique do grid da SF6 (view)
@author Raphael Augustos
@since 11/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Static Function bLinePreF6( oGridModel, nLine, cAction, cIDField, xAtuValue, xAntvalue)
	Local oModel        := FWModelActive()
	Local nOperation    := oModel:GetOperation()
	Local lRet          := .T.
	Local cEstLote      := oModel:GetValue("CIBMASTER","CIB_EST")
	Local nNumero       := ""

	If cAction == "CANSETVALUE"
		If  nOperation == MODEL_OPERATION_UPDATE
			If cIDField == "F6_NUMERO"
				If !oGridModel:IsInserted(nLine)
					lRet := .F.
				EndIf
			EndIf
		EndIf
	ElseIf cAction == "DELETE"
		// Só permite deletar linhas que foram adicionados pelo usuário no momento do Update
		If oGridModel:IsInserted(nLine)
			lRet := .T.
		Else
			Help("",1,"help","Help","Não é possível deletar essa linha. Opções disponíveis: Dermarcar a flag do campo" ,1,0)//"Dicionário desatualizado, favor verificar atualização da GNRE 2.0"
			lRet := .F.
		EndIf
	ElseIf cAction == "SETVALUE"
		If  nOperation == MODEL_OPERATION_UPDATE
			If cIDField == "F6_NUMERO"
				SF6->(DbSetOrder(1))

				// Se o usuário não usou a consulta padrão e digitou a guia manualmente no campo é necessário posicionar a SF6 maunalmente.
				If !IsInCallStack("F3GET")
					If !SF6->(DbSeek( xFilial("SF6") + cEstLote +  xAtuValue ))
						Help("",1,"help","Help","A guia informada não existe ou não é do mesmo estado do lote. Estado do lote :" + cEstLote ,1,0)//"Dicionário desatualizado, favor verificar atualização da GNRE 2.0"
						Return .F.
					EndIf
				EndIf
				// Validações individuais do que pode ser adicionado dentro de um lote
				If !Empty(AllTrim(SF6->F6_IDGUIA))
					Help("",1,"help","Help","GNRE já pertence a um lote. Código do lote: " + SF6->F6_IDGUIA + "." ,1,0)
					Return  .F.
				EndIf
				If Empty(SF6->F6_DTPAGTO )
					Help("",1,"help","Help","Preencha a Data de Pagamento da guia para poder utilizar ela dentro do lote"  ,1,0)
					Return  .F.
				EndIf
				If !Empty(AllTrim(SF6->F6_RECIBO))
					Help("",1,"help","Help","Essa guia já possui código de recibo preenchido"  ,1,0)
					Return  .F.
				EndIf
				If !( SF6->F6_TIPOIMP == '3'  .OR.  !SF6->F6_TIPOIMP == 'B')
					Help("",1,"help","Help","Só é permitido utilizar guias do tipo ICMS/ST ou Difal"  ,1,0)
					Return  .F.
				EndIf
				If !SF6->F6_EST ==  cEstLote
					Help("",1,"help","Help","A guia selecionada não é do mesmo estado do lote. Estado do lote: " + cEstLote  ,1,0)
					Return  .F.
				EndIf
				If  SF6->F6_GNREWS == 'S'
					Help("",1,"help","Help","Essa guia já foi autorizada, não é possível utilizar ela dentro de um lote"  ,1,0)
					Return  .F.
				EndIf

				// If !(Empty(AllTrim(SF6->F6_IDGUIA)) .AND. !Empty(SF6->F6_DTPAGTO ) .AND. Empty(AllTrim(SF6->F6_RECIBO)) .AND. ( Empty(AllTrim(SF6->F6_GNREWS )) .OR. SF6->F6_GNREWS == 'N' ) .AND. ( SF6->F6_TIPOIMP == '3'  .OR.  SF6->F6_TIPOIMP == 'B')  .AND. SF6->F6_EST ==  cEstLote)

				oGridModel:LoadValue("F6_NUMERO",SF6->F6_NUMERO)
				oGridModel:LoadValue("F6_EST",SF6->F6_EST)
				oGridModel:LoadValue("F6_VALOR",SF6->F6_VALOR)
				oGridModel:LoadValue("F6_DTARREC",SF6->F6_DTARREC)
				oGridModel:LoadValue("F6_DTVENC",SF6->F6_DTVENC)
				oGridModel:LoadValue("F6_DTPAGTO",SF6->F6_DTPAGTO)
				oGridModel:LoadValue("F6_CODREC",SF6->F6_CODREC)
			EndIf
		Endif
		If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
			If cIDField == "MARK"
				If xAtuValue
					// Não permite marcar uma guia que já está com lote.
					SF6->(DbSetOrder(1))
					If SF6->(DbSeek( oGridModel:GetValue( "F6_FILIAL") + oGridModel:GetValue( "F6_NUMERO") + oGridModel:GetValue( "F6_EST") ))
						If !Empty(SF6->F6_IDGUIA)
							Help("",1,"help","Help","Essa guia já está sendo utilizada em outro lote",1,0)//"Dicionário desatualizado, favor verificar atualização da GNRE 2.0"
							lRet    := .F.
						EndIf
					EndIf
				EndIf
				CIBTot(oGridModel, xAtuValue, nLine)
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CIBTot
Função que atualiza o cabeçalho do lote baseado na seleção das guias.
@author Raphael Augustos
@since 11/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Static Function CIBTot( oModelGrid , xAtuValue , nLine)
	Local nX         := 1
	Local nTotal     := 0
	Local nQtd       := 0
	Local cReceita   := ""
	Local aReceitas  := {}
	Local oView      := FwViewActive()
	Local oModel     := FwModelActivate()
	Local nOperation := oModel:GetOperation()
	Local aSaveLines := FWSaveRows()

	private cUF	   		:= ''

	For nX := 1 To oModelGrid:length()
		oModelGrid:GoLine(nX)
		If ( oModelGrid:GetValue("MARK") .And. nX <> nLine) .Or. (nX == nLine .And. xAtuValue)
			cReceita    := oModelGrid:GetValue("F6_CODREC")
			nTotal      += oModelGrid:GetValue("F6_VALOR")
			nQtd++
			If aScan(aReceitas,cReceita) == 0
				aadd(aReceitas,cReceita)
			EndIf
		EndIf
	Next nX
// Define o tipo de guia
	If nQtd == 1
		oModel:SetValue("CIBMASTER","CIB_TPGNRE","0")
	ElseIf nQtd > 1 .And. Len(aReceitas) == 1
		oModel:SetValue("CIBMASTER","CIB_TPGNRE","1")
	ElseIf nQtd > 1 .And. Len(aReceitas) > 1
		oModel:SetValue("CIBMASTER","CIB_TPGNRE","2")
	EndIf

// Totaliza o total do lote da GNRE
	oModel:SetValue("CIBMASTER","CIB_VALOR", nTotal)

	FWRestRows(aSaveLines)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewStru
Cria campo de seleção do Grid - oStru do View.
@author Raphael Augustos
@since 11/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Static Function ViewStru(oStruSF6)

	oStruSF6:AddField("MARK"	    ,;	// [01]  C   Nome do Campo
	"00"			,;	// [02]  C   Ordem
	'Seleção'		,;	// [03]  C   Titulo do campo - Ignora Item Bloq.
	'Seleção'		,;	// [04]  C   Descricao do campo - Ignora itens inconsistentes da planilha.
	NIL				,;	// [05]  A   Array com Help
	"L"				,;	// [06]  C   Tipo do campo
	"@!"			,;	// [07]  C   Picture
	NIL				,;	// [08]  B   Bloco de Picture Var
	""				,;	// [09]  C   Consulta F3
	.T.				,;	// [10]  L   Indica se o campo é alteravel
	NIL				,;	// [11]  C   Pasta do campo
	NIL				,;	// [12]  C   Agrupamento do campo
	NIL				,;	// [13]  A   Lista de valores permitido do campo (Combo)
	NIL				,;	// [14]  N   Tamanho maximo da maior opção do combo
	NIL				,;	// [15]  C   Inicializador de Browse
	.T.				,;	// [16]  L   Indica se o campo é virtual
	NIL				,;	// [17]  C   Picture Variavel
	NIL				)	// [18]  L   Indica pulo de linha após o campo					)	// 	[14]  L   Indica se o campo é virtual

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MStruSF6
Cria campo de seleção do Grid - oStru do model.
@author Raphael Augustos
@since 11/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Static Function ModelStru(oStruSF6)

	oStruSF6:AddField( ;
		'Selecao' , ; // [01] C Titulo do campo
	'Selecao' , ; // [02] C ToolTip do campo
	'MARK' , ;    // [03] C identificador (ID) do Field
	'L' , ;             // [04] C Tipo do campo
	1 , ;              // [05] N Tamanho do campo
	0 , ;               // [06] N Decimal do campo
	NIL , ;             // [07] B Code-block de validação do campo
	NIL , ;             // [08] B Code-block de validação When do campo
	NIL , ;             // [09] A Lista de valores permitido do campo
	NIL , ;             // [10] L Indica se o campo tem preenchimento obrigatório
	{ || IIF(INCLUI .Or. __nOper == MODEL_OPERATION_CANCLOTE,.F.,.T.) } , ;   // [11] B Code-block de inicializacao do campo
	NIL , ;             // [12] L Indica se trata de um campo chave
	.F. , ;             // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )               // [14] L Indica se o campo é virtual

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadGrid
Funçção de validação do model
@author Raphael Augustos
@since 11/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Static Function SetModAct(oModel)
	Local aArea		 := GetArea()
	Local nOperation := oModel:GetOperation()
	Local oGrid      := oModel:GetModel("SF6DETAIL")
	Local cTmp		 :=  GetNextAlias()
	Local nX         := 1


	If nOperation == MODEL_OPERATION_INSERT
		oModel:SetValue("CIBMASTER","CIB_EST",MV_PAR03)
		oGrid:SetNoDeleteLine(.F.) // Não permite deletar
		oGrid:SetNoInsertLine(.F.) // Não permite Inserir
		BeginSQL Alias cTmp
        column F6_DTARREC as Date
        column F6_DTVENC as Date
        column F6_DTPAGTO as Date

        SELECT F6_NUMERO, F6_EST , F6_VALOR, F6_DTARREC, F6_DTVENC, F6_DTPAGTO ,F6_CODREC 
        FROM %Table:SF6%
        WHERE 	F6_FILIAL = %XFilial:SF6%
                AND F6_IDGUIA = ' ' AND F6_DTPAGTO >= %Exp:MV_PAR01% AND F6_DTPAGTO <= %Exp:MV_PAR02%
                AND F6_RECIBO = ' ' AND ( F6_GNREWS = ' ' OR F6_GNREWS = 'N' ) 
                AND ( F6_TIPOIMP = '3'  OR  F6_TIPOIMP = 'B')  AND F6_EST =  %Exp:MV_PAR03%
                AND %NotDel%
        ORDER BY %Order:SF6,1%
		EndSQL

		While  (cTmp)->(!Eof())
			If nX > 1
				nP := oGrid:AddLine(.t.)
			EndIf
			oGrid:LoadValue("F6_NUMERO",(cTmp)->F6_NUMERO)
			oGrid:LoadValue("F6_EST",(cTmp)->F6_EST)
			oGrid:LoadValue("F6_VALOR",(cTmp)->F6_VALOR)
			oGrid:LoadValue("F6_DTARREC",(cTmp)->F6_DTARREC)
			oGrid:LoadValue("F6_DTVENC",(cTmp)->F6_DTVENC)
			oGrid:LoadValue("F6_DTPAGTO",(cTmp)->F6_DTPAGTO)
			oGrid:LoadValue("F6_CODREC",(cTmp)->F6_CODREC)
			nX++
			(cTmp)->(DbSkip())
		End
		(cTmp)->(DBCloseArea())
		RestArea(aArea)
		//oGrid:SetNoInsertLine(.T.) // Não permite Insert
		oGrid:SetNoDeleteLine(.T.) // Não permite deletar
	EndIf

// Muda o status do lote para cancelado
	If __nOper ==  MODEL_OPERATION_CANCLOTE
		oGrid:SetNoDeleteLine(.T.) // Não permite deletar
		oGrid:SetNoInsertLine(.T.) // Não permite Inserir
		oGrid:SetNoUpdateLine(.T.) // Não permite Update
		oModel:SetValue("CIBMASTER","CIB_GNREWS","C")
	EndIf

	If nOperation == MODEL_OPERATION_UPDATE
		oGrid:SetNoInsertLine(.F.)
		oGrid:SetNoDeleteLine(.F.) // Não permite Delete
	Endif


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FIS214CANC
Função que cancela o lote.
@author Raphael Augustos
@since 11/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Function  FIS214CANC()
	Local cTitulo       := "Cancelar lote da GNRE"
	Local cPrograma     := "FISA214"
	Local nOperation    := MODEL_OPERATION_UPDATE
	Local nRet          := 0
	Local oModel

	__nOper      := MODEL_OPERATION_CANCLOTE // Suboperação da rotina
	nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )
	__nOper      := 0
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fis214Trans
Rotina de Transmissão da GNRE WS
@author Raphael Augusts
@since 21.10.2019
@version 1.0
/*/
//-------------------------------------------------------------------     
function Fis214Trans()

	local oWizard	:= Nil

	local aArea		:= GetArea()
	local aPerg   	:= {}
	local aParam  	:= { space(len(CIB->CIB_ID)) , space(len(CIB->CIB_ID)) , space(len(CIB->CIB_EST)) }
	local aTexto	:= {"",""}
	local cAmbiente	  := alltrim(GetMV("MV_AMBGNRE",,"2"))
	local cVerGNRE := alltrim(GetMV("MV_GNREVE",,"1.00"))
	local cRetGNRE	:= ""
	local cAmbGnre	:= ""
	local cParRem	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"FISA214REM"

	MV_PAR01 := aParam[01] := PadR(ParamLoad(cParRem,aPerg,1,aParam[01]),len(CIB->CIB_ID))
	MV_PAR02 := aParam[02] := PadR(ParamLoad(cParRem,aPerg,2,aParam[02]),len(CIB->CIB_ID))
	MV_PAR03 := aParam[03] := PadR(ParamLoad(cParRem,aPerg,3,aParam[03]),len(CIB->CIB_EST))

	aadd(aPerg,{1,"Lote Inicial",aParam[01],"",".T.","",".T.",50,.T.}) //"Número GNRE Inicial:"
	aadd(aPerg,{1,"Lote Final",aParam[02],"",".T.","",".T.",50,.T.}) //"Número GNRE Final:"
	aadd(aPerg,{1,"Estado",aParam[03],"@!",".T.","12",".T.",40,.T.}) //"Estado

	//Apresentação ambiente
	if cAmbiente $ "1"
		cAmbGnre := "1-Produção"
	else
		cAmbGnre := "2-Homologação"
	endif

	// Montagem da Interface  de Transmissão
	aadd(aTexto,{})

	aTexto[1] := "Esta rotina tem como objetivo auxilia-lo na transmissão da GNRE para TSS. "+CRLF
	aTexto[1] += "Neste momento o sistema, está operando com a seguinte configuração: "+CRLF
	aTexto[1] += "Ambiente: "+ cAmbGnre + CRLF
	aTexto[1] += "Versão GNRE: "+ cVerGNRE + CRLF

	aadd(aTexto,{})

	DEFINE WIZARD oWizard ;
		TITLE "Assistente de Transmissão da GNRE via Web Service. ";
		HEADER "Atenção";
		MESSAGE "Siga atentamente os passos para a configuração da GNRE - Web Service";
		TEXT aTexto[1] ;
	NEXT {|| .T.} ;
	FINISH {||.T.}

CREATE PANEL oWizard  ;
	HEADER "Assistente de Transmissão da GNRE via Web Service. ";
	MESSAGE ""	;
	BACK {|| .T.} ;
	NEXT {|| ParamSave(cParRem,aPerg,"1"),Processa({|lEnd| cRetGNRE := GnreTrans(Alltrim(aParam[1]),Alltrim(aParam[2]),cAmbiente,@lEnd,AllTrim(aParam[3]))}),aTexto[02]:= cRetGNRE,.T.} ;
	PANEL
ParamBox(aPerg,"Transmissão do lote da GNRE",@aParam,,,,,,oWizard:oMPanel[2],cParRem,.T.,.T.) //"Transmissão de GNRE"


CREATE PANEL oWizard  ;
	HEADER "Assistente de Transmissão da GNRE via Web Service. ";
	MESSAGE "";
	BACK {|| .T.} ;
	FINISH {|| .T.} ;
	PANEL
@ 010,010 GET aTexto[02] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]

ACTIVATE WIZARD oWizard CENTERED

RestArea(aArea)
return

//-------------------------------------------------------------------
/*/{Protheus.doc} GnreTrans
Obtem o codigo da entidade apos enviar o post para o Totvs Service SOA
@author Raphael Augustos
@since 21.10.2019
@version 12.25
@param		cLoteIni	Número Lote inicial
@param		cLoteFim	Número Lote final
@param		cAmbiente	Ambiente de Transmissão (1-Produção / 2-Homologação)
/*/
//-------------------------------------------------------------------
static function GnreTrans(cLoteIni,cLoteFim,cAmbiente,lEnd,cUFFav)

	local aXML			:= {}
	local aLotes		:= {}
	local aCposCIB      := {}
	local aCposSF6      := {}
	local cRetorno		:= ""
	local cAliasSF6		:= ""
	local cAliasCIB     := ""
	local cSelect       := ""
	local nY			:= 0
	local nX3			:= 0
	local nB			:= 0
	Local cLote         := {}
	Local cVersao	    := GetMv("MV_GNREVE",,"1.00")
	local cMVUFGNWS		:= GetNewPar('MV_UFGNWS' ,'') //Apenas as UF's que possuem GNRE Web Service.
	Local cMsgUF	 	:= ""
	Local cEspaco		:= CHR(10) + CHR(13)
	Local lPrim		    := .T. // Flag de controle para o primeiro campo da Select

	default cLoteIni	:= ""
	default cLoteFim	:= ""
	default cAmbiente	:= ""
	default cUFFav	:= ""

	if !(empty(cLoteIni) .and. empty(cLoteFim) .and. empty(cAmbiente))

		DbSelectArea('CIB')
		CIB->(DbSetOrder(2))
		cWhere := "%"
		If !Empty(cUFFav)
			cWhere += " AND CIB.CIB_EST = '" + cUFFav + "'"
		EndIf
		cWhere += "%"
		cAliasCIB := GetNextAlias()
		// Separa os lotes
		BeginSql Alias cAliasCIB
        SELECT DISTINCT CIB.CIB_FILIAL,CIB.CIB_ID,CIB.CIB_EST FROM
            %Table:CIB% CIB
        WHERE
            CIB.CIB_FILIAL=%xFilial:CIB% AND
            CIB.CIB_ID >= %Exp:cLoteIni% AND CIB.CIB_ID <= %Exp:cLoteFim% AND
            CIB.%NotDel%  
            %Exp:cWhere%
        ORDER BY %Order:CIB%
		EndSql

		If (cAliasCIB)->(!Eof())

			aCposCIB := FWSX3Util():GetListFieldsStruct('CIB', .F.)
			aCposSF6 := FWSX3Util():GetListFieldsStruct('SF6', .F.)

			cSelect := "%"
			For nX3 := 1 to Len(aCposCIB)
				If aCposCIB[nX3][2] == "M" // Não levo campo memos pois reduz performance
					Loop
				EndIf
				If lPrim
					cSelect += "CIB."+Alltrim(aCposCIB[nX3][1])+""
					lPrim := .F.
				Else
					cSelect += ",CIB."+Alltrim(aCposCIB[nX3][1])+""
				Endif
			Next nX3

			For nX3 := 1 to Len(aCposSF6)
				If aCposSF6[nX3][2] == "M" // Não levo campo memos pois reduz performance
					Loop
				EndIf
				cSelect += ",SF6."+Alltrim(aCposSF6[nX3][1])+""
			Next nX3

			cSelect += "%"

			FwFreeArray(aCposCIB)
			FwFreeArray(aCposSF6)
		EndIf

		(cAliasCIB)->(DbGoTop())
		// Processa um lote por vez
		while (cAliasCIB)->(!Eof())

			cLote  := (cAliasCIB)->CIB_ID

			// Não permite transmitir guias para os estados que não estão no parâmetro MV_UFGNWS
			If !(cAliasCIB)->CIB_EST $ cMVUFGNWS
				cMsgUF += "Estado: " + (cAliasCIB)->CIB_EST +" - LOTE: " + (cAliasCIB)->CIB_ID + cEspaco
				(cAliasCIB)->(dbSkip())
				Loop
			EndIf

			cAliasSF6 := GetNextAlias()
			BeginSql Alias cAliasSF6
            column F6_DTVENC as Date
            column F6_DTPAGTO as Date
            column CIB_DTPGTO as Date

            SELECT %Exp:cSelect% 
                FROM %Table:CIB% CIB 
                INNER JOIN %Table:SF6% SF6 ON
                CIB.CIB_FILIAL = SF6.F6_FILIAL
                AND CIB.CIB_ID = SF6.F6_IDGUIA
                AND CIB.CIB_EST = SF6.F6_EST
                AND SF6.%NotDel%
            WHERE
                CIB.CIB_FILIAL= %xFilial:CIB% AND
                CIB.CIB_ID = %Exp:cLote% AND
                CIB.%NotDel%
            ORDER BY %Order:CIB%
			EndSql
			(cAliasSF6)->(DbGoTop())

			While (cAliasSF6)->(!Eof())
				IncProc("(2/2) "+ "Transmitindo lote da GNRE: " + cLote )
				aadd(aXML,{})
				nY := Len(aXML)
				aXML[nY] := ExecBlock("GnreXMLEnv",.F.,.F.,{cAliasSF6})
				(cAliasSF6)->(DbSkip())
			End
			(cAliasSF6)->(DbCloseArea())

			(cAliasCIB)->(DbSkip())
		enddo


		If Len(aXML) > 0

			//Gravo o id na tabela CIB
			for nB:= 1 to Len( aXML )

				aRet := TSSIDLote(aXML[nB,1])
				cXml        := aXML[nB,2]
				If CIB->( DbSeek( xFilial("CIB") + aRet[2] + aRet[3] ))
					RecLock("CIB",.F.)
					CIB->CIB_IDTSS  := aXML[nB,1]
					CIB->CIB_XMLENV := cXml
					MsUnlock()
					GrvF6IdTSS( aRet[2] + aRet[3],aXML[nB,1])
				endif
			next

			//Transmissão da GNRE
			cRetorno := StaticCall( FISA095 ,  RemessaGnre , cAmbiente, aXML, @aLotes )

			//Atualiza o Status da GNRE
			If Len( aLotes ) > 0
				for nY:=1 to Len( aLotes )
					aRet := TSSIDLote(aLotes[nY,1])
					If CIB->( DbSeek( xFilial("CIB") + aRet[2] + aRet[3] ))
						RecLock("CIB",.F.)
						CIB->CIB_GNREWS := "T"
						CIB->CIB_AMBIWS := cAmbiente
						CIB->CIB_IDTSS  := aLotes[nY,1]
						MsUnlock()
						GrvF6IdTSS( aRet[2] + aRet[3],aLotes[nY,1],"T",cAmbiente)
					Endif
				Next nY
			Endif
		Endif

		If !Empty(AllTrim(cMsgUF))
			cRetorno += cEspaco + "Os seguintes lotes não foram transmitidos por não configuração do parâmetro MV_UFGNWS :  " + cEspaco
			cRetorno += cMsgUF + cEspaco
		EndIf

	Endif

	(cAliasCIB)->(DbCloseArea())

return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} TSSIDLote
Função que desmembra o ID do Lote GNRE utilizado nos metodos Remessa, monitor e schema.
@author Raphael Augustos
@since 21.10.2019
@version 12.25
/*/
//-------------------------------------------------------------------
Function TSSIDLote(cID)
	Local aRet := {'','',''}
	Default cID := ""
	cID := AllTrim(cId)
	If Len(cID) > 0
		aRet[1] := SubStr(cID,1,1) // Caracter L que diferencia os ID dos metodos remessa e monitor entre as rotinas FISA095 E FISA214
		aRet[2] := SubStr(cID,2,2) // Estado
		aRet[3] := SubStr(cID,4,Len(cID)) // Número da guia
	EndIf
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TSSIDLote
Função responsável por gravar na SF6 o campo ID TSS baseado no lote. Utilziado para remessa, monitor e schema.
@author Raphael Augustos
@since 21.10.2019
@version 12.25
/*/
//-------------------------------------------------------------------
Static Function GrvF6IdTSS(cSeek,cIDTSS,cStatus,cAmbiente)
	Local aAreaSF6  :=  SF6->(GetArea())
	DEFAULT cLote       := ""
	DEFAULT cIDTSS      := ""
	DEFAULT cStatus     := ""
	DEFAULT cAmbiente   := ""

	SF6->(DbSetOrder(5))
	If sF6->( DbSeek ( xFilial("SF6") + cSeek ) )
		While SF6->(!Eof()) .And. SF6->( F6_EST+F6_IDGUIA ) == cSeek
			RecLock("SF6",.F.)
			SF6->F6_IDTSS  = cIDTSS
			SF6->F6_AMBIWS = cAmbiente
			SF6->F6_GNREWS = cStatus
			SF6->(MsUnlock())
			SF6->(DbSkip())
		End
	EndIf

	RestArea(aAreaSF6)
Return aRet
