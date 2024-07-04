#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA421E.CH"

Static cGA117BGrid	:= ""

/*/{Protheus.doc} GTPA421E
    Conferência de Requisições
    @type  Function
    @author Lucivan Severo Correia
    @since 18/06/2020
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @example    GTPA117B()
    @see (links_or_references)
/*/
Function GTPA421E()

Local aNewFlds  := {'GQW_USUCON', 'GQW_CONFCH', 'GQW_MOTREJ'}
Local lNewFlds  := GTPxVldDic('GQW', aNewFlds, .F., .T.)
If lNewFlds
	FWMsgRun(, {|| FWExecView("","VIEWDEF.GTPA421E",MODEL_OPERATION_UPDATE,,{|| .T.})},"", STR0001) //"Buscando Requisições..."
Else
	FwAlertHelp("Atualize o dicionário para utilizar esta rotina", "Dicionário desatualizado")
EndIf
Return()

/*/{Protheus.doc} ModelDef
    Model para a Conferência de Requisições
    @type  Static Function
    @author Lucivan Severo Correia
    @since 18/03/2018
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @example
    (GTPA117B())
    @see (links_or_references)
/*/
Static Function ModelDef()

	Local oModel	:= nil
	Local oStruG6X	:= FWFormStruct( 1, "G6X",,.F. )	// Ficha de Remessa
	Local oStruGQW	:= FWFormStruct( 1, "GQW",,.F. )	// Requisições

	oModel := MPFormModel():New("GTPA421E",,,)

	If GQW->(FieldPos('GQW_USUCON')) > 0
		oStruGQW:AddTrigger( ;
			'GQW_CONFCH'  , ;				// [01] Id do campo de origem
			'GQW_USUCON'  , ;				// [02] Id do campo de destino
			{ || .T.}, ; 					// [03] Bloco de codigo de validação da execução do gatilho
			{ || AllTrim(RetCodUsr())	} )	// [04] Bloco de codigo de execução do gatilho
	EndIf

	If GQW->(FieldPos('GQW_MOTREJ')) > 0
		oStruGQW:SetProperty('GQW_MOTREJ',MODEL_FIELD_WHEN,{|oModel|  oModel:GetValue('GQW_CONFCH') == "3" } )
	EndIf
	If GQW->(FieldPos('GQW_CONFCH')) > 0
		oStruGQW:SetProperty('GQW_CONFCH',MODEL_FIELD_INIT,{||"1"})
	EndIf
	oModel:AddFields("CABEC", /*cOwner*/, oStruG6X,,,/*bLoad*/)
	oModel:AddGrid("GRID", "CABEC", oStruGQW)
	oModel:SetRelation( 'GRID', { { 'GQW_FILIAL', 'xFilial( "G6X" )' }, ;
								  { 'GQW_CODAGE', 'G6X_AGENCI ' }, ;
								  { 'GQW_NUMFCH', 'G6X_NUMFCH' } }, GQW->(IndexKey(1)))

	// Exibe Totais

	oModel:AddCalc( 'CALC_TOTREQ', 'CABEC', 'GRID' , 'GQW_TOTDES', 'CALC_DESC', 'SUM', { | | .T.},,STR0002)	// "Valor Desconto"
	oModel:AddCalc( 'CALC_TOTREQ', 'CABEC', 'GRID' , 'GQW_TOTAL', 'CALC_VALOR', 'SUM', { | | .T.},,STR0003)	// "Valor Total"

	oModel:SetDescription(STR0004) //"Conferência de Requisições"
	oModel:GetModel('GRID'):SetMaxLine(99999)
	oModel:SetVldActivate({|oModel| GA421EVldAct(oModel)})
	oModel:SetCommit({|oModel| G421EBCommit(oModel)})

Return(oModel)

/*/{Protheus.doc} ViewDef
    View para a Conferência de Requisições
    @type  Static Function
    @author Lucivan Severo Correia
    @since 18/03/2018
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @example
    (GTPA117B())
    @see (links_or_references)
/*/
Static Function ViewDef()
	Local oView		:= nil
	Local oModel	:= FwLoadModel("GTPA421E")
	Local oMdlGQW 	:= oModel:GetModel("GRID")
	Local oStruG6X	:= FWFormStruct( 2, "G6X",{|cCpo|	(AllTrim(cCpo))$ "G6X_AGENCI|G6X_NUMFCH|G6X_DTINI|G6X_DTFIN" })	//Ficha de Remessa
	Local oStruGQW	:= FWFormStruct( 2, "GQW",, )	//Requisições
	Local oStruCalc := FWCalcStruct( oModel:GetModel('CALC_TOTREQ') )
	Local nX		:= 0
	Local aFields 	:= oMdlGQW:GetStruct():GetFields()
	Local cFields 	:= ""

// Cria o objeto de View
	oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

//campos que serão utilizados na View

	cFields := "GQW_CODIGO|"
	cFields += "GQW_REQDES|"
	cFields += "GQW_DATEMI|"
	If GQW->(FieldPos('GQW_CONFCH')) > 0
		cFields += "GQW_CONFCH|"
	EndIf
	cFields += "GQW_CODCLI|"
	cFields += "GQW_CODLOJ|"
	cFields += "GQW_NOMCLI|"
	cFields += "GQW_TOTDES|"
	cFields += "GQW_TOTAL|"
	If GQW->(FieldPos('GQW_MOTREJ')) > 0
		cFields += "GQW_MOTREJ|"
	EndIf

	For nX := 1 to Len(aFields)

		If ( !(aFields[nX][3] $ cFields) )
			oStruGQW:RemoveField(aFields[nX][3])
		Endif

	Next

	oStruG6X:SetProperty('*', MVC_VIEW_CANCHANGE , .F.)
	//oStruGQW:SetProperty('*', MVC_VIEW_CANCHANGE , .F.)

	If GQW->(FieldPos('GQW_CONFCH')) > 0 .AND.  GQW->(FieldPos('GQW_MOTREJ')) > 0
		oStruGQW:SetProperty('GQW_CONFCH', MVC_VIEW_CANCHANGE , .T.)
		oStruGQW:SetProperty('GQW_MOTREJ', MVC_VIEW_CANCHANGE , .T.)
	EndIf
	OrdGrd(oStruGQW)

	oView:AddField("VIEW_HEADER", oStruG6X, "CABEC" )
	oView:AddGrid("VIEW_DETAIL", oStruGQW, "GRID" )
	oView:AddField('VIEW_CALC', oStruCalc, 'CALC_TOTREQ')

	oView:CreateHorizontalBox("HEADER", 20 )
	oView:CreateHorizontalBox("DETAIL", 70 )
	oView:CreateHorizontalBox("TOTAL", 10 )

	oView:SetOwnerView("VIEW_HEADER", "HEADER")
	oView:SetOwnerView("VIEW_DETAIL", "DETAIL")
	oView:SetOwnerView('VIEW_CALC', 'TOTAL')

	oView:AddUserButton( "Conferir Todos", "", {|oModel| ConfereTudo(oModel)} ) // "Conferir Todos"

	oView:GetViewObj("VIEW_DETAIL")[3]:SetGotFocus({|| cGA117BGrid := "GRID" })

	oView:EnableTitleView('VIEW_HEADER',STR0005) // "Dados da Ficha de Remessa"
	oView:EnableTitleView('VIEW_DETAIL',STR0006) // "Requisições"

	oView:GetViewObj("VIEW_DETAIL")[3]:SetSeek(.T.)
	oView:GetViewObj("VIEW_DETAIL")[3]:SetFilter(.T.)

	oView:SetNoDeleteLine('VIEW_DETAIL')
	oView:SetNoInsertLine('VIEW_DETAIL')

Return(oView)

/*/{Protheus.doc} OrdGrd(oStruGQW)
    Ordena os campos das grids
    @type  Static Function
    @author Lucivan Severo Correia
    @since 18/03/2018
    @version 1
    @example
    (GTPA117B())
    @see (links_or_references)
/*/
Static Function OrdGrd(oStruGQW)

	Local aOrdemCpo	:= {}

	AADD(aOrdemCpo, {"GQW_CODIGO",	"GQW_REQDES"})
	AADD(aOrdemCpo, {"GQW_REQDES",	"GQW_TOTDES"})
	AADD(aOrdemCpo, {"GQW_TOTDES",	"GQW_TOTAL"})
	If GQW->(FieldPos('GQW_MOTREJ')) > 0
		AADD(aOrdemCpo, {"GQW_TOTAL",	"GQW_DATEMI"})
	EndIf
	If GQW->(FieldPos('GQW_CONFCH')) > 0
		AADD(aOrdemCpo, {"GQW_DATEMI",	"GQW_CONFCH"})
		AADD(aOrdemCpo, {"GQW_CONFCH",	"GQW_CODCLI",})
	Else
		AADD(aOrdemCpo, {"GQW_DATEMI",	"GQW_CODCLI"})
	EndIf
	AADD(aOrdemCpo, {"GQW_CODCLI",	"GQW_CODLOJ"})
	AADD(aOrdemCpo, {"GQW_CODLOJ",	"GQW_NOMCLI"})
	AADD(aOrdemCpo, {"GQW_NOMCLI",	"GQW_MOTREJ"})

	GTPOrdVwStruct(oStruGQW,aOrdemCpo)

Return

/*/{Protheus.doc} (oModel)
    Confere todos os bilhetes disponiveis na grid
    @type  Static Function
    @author Lucivan Severo Correia
    @since 18/03/2018
    @version 1
    @param oModel
    @return
    @example
    (GTPA117B())
    @see (links_or_references)
/*/
Static Function ConfereTudo(oModel)
	
	Local oGridGQW	:= oModel:GetModel('GRID')
	Local nX		:= 0
	Local lUsrConf  := GQW->(FieldPos('GQW_USUCON')) > 0
	Local cUserLog  := AllTrim(RetCodUsr())

	For nX := 1 To oGridGQW:Length()

		oGridGQW:GoLine(nX)

		If !(Empty(oGridGQW:GetValue('GQW_CODIGO'))) .And.;
				oGridGQW:GetValue('GQW_CONFCH') == '1'
			oGridGQW:SetValue('GQW_CONFCH','2')

			If lUsrConf
				oGridGQW:LoadValue('GQW_USUCON', cUserLog  )
			Endif
		Endif

	Next

	oGridGQW:GoLine(1)

Return

Static Function GA421EVldAct(oModel)
Local cStatus		:= G6X->G6X_STATUS
Local lRet			:= .T.
Local cMsgErro      := ""
Local cMsgSol       := ""

If cStatus <> '2'
    cMsgErro := STR0007//"Status atual da Ficha de Remessa não permite a conferência"
    cMsgSol  := ""
    lRet := .F.
Endif

If lRet .AND. !(VldArrecFch(@cMsgErro,@cMsgSol))
    lRet := .F.
EndIf

If !lRet
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G421EVldAct",cMsgErro,cMsgSol,,)
Endif

Return lRet

/*/{Protheus.doc} G421EBCommit(oModel)
    Realiza o commit dos bilhetes conferidos
    @type  Static Function
    @author Henrique Madureira
    @since 03/06/2020
    @version 1
    @param oModel
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function G421EBCommit(oModel)

Local oGridReq  := oModel:GetModel('GRID')
Local cUserLog  := AllTrim(RetCodUsr())
Local nX        := 0
Local lRet      := .T.

Begin Transaction 

	For nX := 1 To oGridReq:Length()
	
		oGridReq:GoLine(nX)

        GQW->(DbSetOrder(1))
        If GQW->(DbSeek(XFILIAL("GQW") + oGridReq:GetValue('GQW_CODIGO',nX)))
		
			RecLock("GQW",.F.)
			GQW->GQW_MOTREJ := oGridReq:GetValue('GQW_MOTREJ',nX)
			GQW->GQW_CONFCH := oGridReq:GetValue('GQW_CONFCH',nX)
			If oGridReq:GetValue('GQW_CONFCH',nX) > '1'
				GQW->GQW_USUCON := cUserLog
			Endif
			GQW->(MsUnlock())
		EndIf  
	Next
	
	If !lRet

		DisarmTransaction()
	
	Endif

End Transaction

Return lRet

