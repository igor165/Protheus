#INCLUDE "PROTHEUS.CH"
#INCLUDE "OMSA350.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE OMSA35001 "OMSA35001"
#DEFINE OMSA35002 "OMSA35002"
#DEFINE OMSA35003 "OMSA35003"

Static aDescDias := {STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013}
Static cNumDias  := "1234567"

//-------------------------------------
/*/{Protheus.doc} OMSA350
Cadastro de Calendários
@author  Henry Fila
@since   26/04/2002
@version 1.0
/*/
//-------------------------------------
Function OMSA350()
Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("DAA")         // Alias da tabela utilizada
	oBrowse:SetMenuDef("OMSA350")   // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) // Descrição do browse "Calendario do Janela de Entregas"
	oBrowse:SetAmbiente(.F.)        // Desabilita opção Ambiente do menu Ações Relacionadas
	oBrowse:SetWalkThru(.F.)        // Desabilita opção WalkThru do menu Ações Relacionadas
	oBrowse:Activate()

Return Nil

//-------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef
@author  Guilherme A. Metzger
@since   04/06/2018
@version 1.0
/*/
//-------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0  // Pesquisar
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.OMSA350" OPERATION 2 ACCESS 0  // Visualizar
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.OMSA350" OPERATION 3 ACCESS 0  // Incluir
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.OMSA350" OPERATION 4 ACCESS 0  // Alterar
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.OMSA350" OPERATION 5 ACCESS 0  // Excluir

	// Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	If ExistBlock("OMS350MNU")
		ExecBlock("OMS350MNU",.F.,.F.)
	EndIf

Return aRotina

//-------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef
@author  Guilherme A. Metzger
@since   04/06/2018
@version 1.0
/*/
//-------------------------------------
Static Function ModelDef()
Local oModel    := Nil
Local oStruCDAA := FWFormStruct(1,"DAA")
Local oStruIDAB := FWFormStruct(1,"DAB")
Local oOmsEvent := OMSA350EVOMS():New() // Evento de validação customizado

	// Todos os SetProperty abaixo podem ser removidos a partir da Release 12.1.22
	oStruCDAA:SetProperty("DAA_DIA"   ,MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID ,'StaticCall(OMSA350,ValidField,A,B,C)'))
	oStruIDAB:SetProperty("DAB_FREQUE",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID ,''))
	oStruIDAB:SetProperty("DAB_FREQUE",MODEL_FIELD_WHEN ,FwBuildFeature(STRUCT_FEATURE_WHEN  ,'StaticCall(OMSA350,SelWeekDay,A,B)'  ))
	oStruIDAB:SetProperty("DAB_DESCFR",MODEL_FIELD_INIT ,FwBuildFeature(STRUCT_FEATURE_INIPAD,'StaticCall(OMSA350,GetDesField,A,B)' ))

	oModel:= MPFormModel():New("OMSA350")
	oModel:SetDescription(STR0006) // "Calendario do Janela de Entregas"

	oModel:AddFields("MdFieldCDAA",,oStruCDAA)
	oModel:SetPrimaryKey({"DAA_CODIGO"})

	oModel:AddGrid("MdGridIDAB", "MdFieldCDAA", oStruIDAB)
	oModel:SetRelation("MdGridIDAB", { {"DAB_FILIAL","xFilial('DAB')"}, {"DAB_CODIGO","DAA_CODIGO"} }, DAB->(IndexKey(1)))

	oModel:GetModel("MdGridIDAB"):SetUniqueLine({"DAB_FREQUE","DAB_DATDIA"})

	oModel:InstallEvent("OMSE350", /*cOwner*/, oOmsEvent)

Return oModel

//-------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef
@author  Guilherme A. Metzger
@since   04/06/2018
@version 1.0
/*/
//-------------------------------------
Static Function ViewDef()
Local oModel    := FWLoadModel("OMSA350")
Local oView     := FWFormView():New()
Local cCposDAB  := "DAB_NUMSEM|DAB_FREQUE|DAB_DESCFR|DAB_DATDIA"
Local oStruCDAA := FWFormStruct(2,"DAA")
Local oStruIDAB := FWFormStruct(2,"DAB",{|cCampo| AllTrim(cCampo) $ cCposDAB})

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VwFieldCDAA", oStruCDAA , "MdFieldCDAA")
	oView:AddGrid("VwGridIDAB", oStruIDAB , "MdGridIDAB")

	oView:CreateHorizontalBox("SUPERIOR",20)
	oView:CreateHorizontalBox("INFERIOR",80)

	oView:EnableTitleView("VwFieldCDAA",STR0014) // "Janela de Entrega"
	oView:EnableTitleView("VwGridIDAB" ,STR0015) // "Itens da Janela de Entrega"

	oView:AddIncrementField("VwGridIDAB","DAB_NUMSEM")

	oView:SetOwnerView("VwFieldCDAA","SUPERIOR")
	oView:SetOwnerView("VwGridIDAB" ,"INFERIOR")

	oStruIDAB:SetProperty("DAB_NUMSEM" ,MVC_VIEW_TITULO,STR0024) // "Sequencial"
	oStruIDAB:SetProperty("DAB_FREQUE" ,MVC_VIEW_TITULO,STR0025) // "Dias"

Return oView

//-------------------------------------
/*/{Protheus.doc} ValidField
Validação de campos
@author  Guilherme A. Metzger
@since   07/06/2018
@version 1.0
/*/
//-------------------------------------
Static Function ValidField(oModel,cField,xValue)

	Do Case
		Case cField == "DAA_DIA"
			Return VldDiaMes(oModel,cField,xValue)
	End Case

Return .T.

//-------------------------------------
/*/{Protheus.doc} VldDiaMes
Verifica se o dia do mês foi informado
@author  Henry Fila
@since   29/09/2002
@version 1.0
/*/
//-------------------------------------
Static Function VldDiaMes(oModel,cField,xValue)
Local cDiaMes := xValue
Local cTipCal := oModel:GetValue("DAA_TIPO")

	If cTipCal == "1" .And. Empty(cDiaMes)
		oModel:GetModel():SetErrorMessage(oModel:GetId(),oModel:GetId(),,,OMSA35001,STR0018,STR0019) // "Quando o Calendário for do tipo 1 - Semanal o Dia Inicial deve ser preenchido." // "Preencha o campo Dia Inicial ou altere o Tipo do Calendário."
		Return .F.
	ElseIf cTipCal == "2" .And. !Empty(cDiaMes)
		oModel:GetModel():SetErrorMessage(oModel:GetId(),oModel:GetId(),,,OMSA35002,STR0020,STR0021) // "O Dia Inicial somente deve ser preenchido quando o Calendário for do tipo 1 - Semanal." // "Remova a informação do campo ou altere o Tipo do Calendário."
		Return .F.
	EndIf

	If Val(cDiaMes) > 31
		oModel:GetModel():SetErrorMessage(oModel:GetId(),oModel:GetId(),,,OMSA35003,STR0022,STR0023) // "O Dia Inicial informado é inválido." // "É necessário informar um valor entre 1 e 31."
		Return .F.
	EndIf

Return .T.

//-------------------------------------
/*/{Protheus.doc} SelWeekDay
Carrega tela para seleção dos dias da semana
@author  Guilherme A. Metzger
@since   07/06/2018
@version 1.0
/*/
//-------------------------------------
Static Function SelWeekDay(oModel,cField)
Local cRet      := oModel:GetValue("DAB_FREQUE")
Local aListBox  := {}
Local nFor      := 1
Local oDlg      := Nil
Local oListbox  := Nil
Local oOk       := LoadBitmap( GetResources(), "LBOK" ) // Objeto: Figura para item selecionado
Local oNo       := LoadBitmap( GetResources(), "LBNO" ) // Objeto: Figura para item nao selecionado
Local nOpca     := 0
Local cDescFreq := ""
Local oView     := Nil

	For nFor := 1 to Len(aDescDias)
		Aadd(aListBox,{ ( SubStr(cNumDias,nFor,1) $ cRet ), aDescDias[nFor] })
	Next nFor

	DEFINE MSDIALOG oDlg FROM 5, 5 TO 19, 50 TITLE STR0016 // "Selecione os dias:"

		@ 0.5,2 LISTBOX oListBox VAR cVarQ FIELDS HEADER "",STR0017 SIZE 150,62; // "Semana"
		      ON DBLCLICK (aListBox[oListBox:nAt,1] := !aListBox[oListBox:nAt,1],oListBox:Refresh()) NOSCROLL

		oListBox:SetArray(aListBox)
		oListBox:bLine := { || {Iif(aListBox[oListBox:nAt,1],oOk,oNo),aListBox[oListBox:nAt,2]}}

		DEFINE SBUTTON FROM 89,105  TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
		
		DEFINE SBUTTON FROM 89,138  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 1
		cRet := ""
		For nFor := 1 To Len(aListBox)
			If aListBox[nFor,1]
				cRet += SubStr(cNumDias,nFor,1)
			EndIf
		Next nFor
		// Atribui os números correspondentes aos dias selecionados
		oModel:LoadValue("DAB_FREQUE",cRet)
		// Carrega no campo DAB_DESCFR a descrição dos dias selecionados
		cDescFreq := LoadFrqSem(oModel,cRet)
		oModel:SetValue("DAB_DESCFR",cDescFreq)
		// Comandos necessários para atualizar a tela
		oView := FWViewActive()
		oView:EvalChanges()
	EndIf

Return .F.

//-------------------------------------
/*/{Protheus.doc} LoadFrqSem
Carrega os dias da semana de acordo com
a frequência selecionada em tela
@author  Guilherme A. Metzger
@since   07/06/2018
@version 1.0
/*/
//-------------------------------------
Static Function LoadFrqSem(oModel,cFrequenc,lSetValue)
Local cDescFreq := ""
Local nX        := 1
Local nPos      := 1

	If !Empty(cFrequenc)
		For nX := 1 To Len(cFrequenc)
			nPos := Val(SubStr(cFrequenc,nX,1))
			cDescFreq += Iif(Empty(cDescFreq),"",", ") + aDescDias[nPos]
		Next nX
	EndIf

Return cDescFreq

//-------------------------------------
/*/{Protheus.doc} GetDesField
Carrega descrição de campos virtuais
@author  Guilherme A. Metzger
@since   07/06/2018
@version 1.0
/*/
//-------------------------------------
Static Function GetDesField(oModel,cField)
Local nLinha    := oModel:GetQtdLine()
Local cDescFreq := ""

	// Impede que a descrição apareça na inclusão de itens durante a alteração
	If nLinha <= 0 .And. !Inclui
		cDescFreq := LoadFrqSem(oModel,AllTrim(DAB->DAB_FREQUE))
	EndIf

Return cDescFreq
