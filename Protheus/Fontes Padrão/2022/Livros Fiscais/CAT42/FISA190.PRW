#Include "FISA190.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA190
  
Rotina de Apuração do Ressarcimento ou Complemento do ICMS Retido por Substituição Tributária ou Antecipado.
Para o Estado de São Paulo, o método de apuração é determinado pela portaria CAT 42/2018.

@author ulisses.oliveira
@since 31/10/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA190()
	Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
	Private oBrowse
	Private oPanelBrw		

    If lVerpesssen
		If AliasIndic("F2T") .And. AliasIndic("F2U") .And. AliasIndic("F2V") .And. AliasIndic("F2X") .And. AliasIndic("F2W") .And. AliasIndic("F3M") 
			DbSelectArea ("F2T")
			DbSelectArea ("F2U")
			DbSelectArea ("F2V")
			DbSelectArea ("F2X")
			DbSelectArea ("F2W")
			DbSelectArea ("F3M")

			//Faz Chamada para verificação da carga inicial dos cadastros
			FwMsgRun(,{|oSay| F195Carga( oSay ) },STR0001,"") //"Processando carga inicial das Regras"

			FWExecView(STR0002,'FISA190', MODEL_OPERATION_INSERT,, { || .T. } ,{ || .T. }  ) //"Apuração do Ressarcimento do ICMS Retido por ST ou Antecipado"
		Else
			MsgStop(STR0003) //"Dicionário de dados desatualizado. Favor aplicar as atualizações necessárias."
		EndIf
	EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para criação de menu [MVC].

@author Ulisses P. Oliveira
@since 31/10/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu("FISA190")


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para criação do modelo [MVC].

@author Ulisses P. Oliveira
@since 31/10/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStruct := FWFormStruct(1,'F2X')

	oModel := MPFormModel():New('MODEL_MAIN',,{|oModel| .T. },{|oModel| .T. })
	oModel:AddFields('MODEL_MAIN',,oStruct)
	oModel:SetDescription('TOTVS')
Return oModel


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para criação da view [MVC].

@author Eduardo Vicente da Silva / Ulisses P. Oliveira
@since 01/11/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel  := FWLoadModel('FISA190')
Local oStruct := FWFormStruct(2,'F2X')
Local oView   := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW_MAIN', oStruct, 'MODEL_MAIN')

oView:AddOtherObject( 'PANEL_TREE'  ,{|oPanel| MONTATREE(oPanel)} )
oView:AddOtherObject( 'PANEL_EMPTY' ,{|oPanel| })
oView:AddOtherObject( 'PANEL_BROWSE',{|oPanel| oPanelBrw := oPanel, FBrowseMon( oPanel )} )

oView:EnableTitleView('PANEL_TREE',STR0004) //"Rotinas Disponíveis"

oView:CreateHorizontalBox( 'INFO_FUNC'	  	,00 )
oView:CreateHorizontalBox( 'EVENTO_FUNC'	,98 )
oView:CreateHorizontalBox( 'FIM_TELA'   	,02 )

oView:CreateVerticalBox( 'INFO_FUNC_ESQ'		, 100	,'INFO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_ESQ'		, 27	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_CENTER'	, 01	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_DIR'		, 72	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'FIM_TELA_EMPTY'		, 100	, 'FIM_TELA' )

oView:SetOwnerView( 'VIEW_MAIN'		, 'INFO_FUNC_ESQ' )
oView:SetOwnerView( 'PANEL_TREE'	, 'EVENTO_FUNC_ESQ' )
oView:SetOwnerView( 'PANEL_EMPTY'	, 'EVENTO_FUNC_CENTER' )
oView:SetOwnerView( 'PANEL_BROWSE'	, 'EVENTO_FUNC_DIR' )
oView:SetOwnerView( 'PANEL_EMPTY'	, 'FIM_TELA_EMPTY' )

Return oView       


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaTree
Função que cria tree com as rotinas disponíveis

@author Eduardo Vicente da Silva
@since 01/11/2018
@version 12.1.17

/*/
//--------------------------------------------------------------------------------------------------
Static Function MontaTree(oPanel)
Local oTree
Local aCoors  := FWGetDialogSize(oPanel)
Local bChange := {|| FChgTree(oTree,oPanel) }

oTree := DbTree():New(aCoors[1]+20, aCoors[2]+5, aCoors[3]-10, aCoors[4]-10, oPanel, bChange,, .T.)

oTree:AddTree(STR0005, .T., "FOLDER5" ,"FOLDER6",,,"000") //"Ressarcimento do ICMS Retido por ST ou Antecipado"
oTree:TreeSeek("001")
oTree:AddItem(STR0006,"001","PMSEDT3","",,,2) //"Apuração do Ressarcimento / Complemento"
oTree:AddItem(STR0007,"002","PMSEDT3","",,,2) //"Saldos Iniciais"
oTree:AddItem(STR0008,"003","PMSEDT3","",,,2) //"Regras"
oTree:AddItem(STR0009,"004","PMSEDT3","",,,2) //"Relatório de Conferência"
oTree:AddItem(STR0010,"005","PMSEDT3","",,,2) //"Geração do Arquivo"

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FChgTree 

@author Eduardo Vicente da Silva
@since 01/11/2018
@version 12.1.17

/*/
//--------------------------------------------------------------------------------------------------
Static Function FChgTree(oTree) 
Local cIdTreePos := ""
Local aInfTree   := {}

//---Busco a identificação de qual item da Tree estamos posicionadoss---//
cIdTreePos := oTree:GetCargo()
oPanelBrw:FreeChildren()
oBrowse:DeActivate()
aInfTree := FSA190FUNC(cIdTreePos,oTree)
FBrowseMon(oPanelBrw, aInfTree[1], aInfTree[2], aInfTree[3], aInfTree[4])
oBrowse:Refresh()

Return Nil


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FBrowseMon

@author Eduardo Vicente da Silva
@since 01/11/2018
@version 12.1.17

/*/
//--------------------------------------------------------------------------------------------------
Static Function FBrowseMon(oPanel, cFonteTree, cAliasTree, cFiltroBrw, cDescBrw)

Local cFunc := "MethIsMemberOf"

Default cFonteTree := ""
Default cAliasTree := ""
Default cFiltroBrw := ""
Default cDescBrw   := ""

oBrowse := FWmBrowse():New()

If &cFunc.(oBrowse,"SetMainProc")
	oBrowse:SetMainProc(cFonteTree)
EndIf

If Empty(cFonteTree) .And. Empty(cAliasTree)
	aInf       := FSA190FUNC()
	cFonteTree := aInf[1]
	cAliasTree := aInf[2]
	cFiltroBrw := aInf[3]
	cDescBrw   := aInf[4]
EndIf

oBrowse:SetOwner( oPanel )
oBrowse:SetDescription( cDescBrw )
oBrowse:SetAlias( cAliasTree )

oBrowse:SetMenuDef( cFonteTree )
oBrowse:DisableDetails()
oBrowse:SetFilterDefault( cFiltroBrw )

oBrowse:Activate()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA190FUNC
Função que identifica a opção selecionada pelo usuário e abre a rotina
pertinente a opção selecionada.

@author Eduardo Vicente da Silva
@since 01/11/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA190FUNC(cIdTreePos,oTree)
Local aRet := Array(04)

Do Case
	Case Empty(cIdTreePos)
		aRet[1] := 'FISA193'
		aRet[2] := 'F2X'
		aRet[3] := ""
		aRet[4] := STR0002  //"Apuração do Ressarcimento do ICMS Retido por ST ou Antecipado"
	Case cIdTreePos == "001"
        FISA192()
		oTree:TreeSeek('000')
	Case cIdTreePos == "002"
        aRet[1] 	:= 'FISA191'
		aRet[2] 	:= "F2V"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0011 //"Cadastro dos Saldos Iniciais - Ressarcimento ICMS-ST"
	Case cIdTreePos == "003"		        
        aRet[1] 	:= "FISA195"
		aRet[2] 	:= "F2W"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0012 //"Cadastro de Regras - Ressarcimento ICMS-ST"
	Case cIdTreePos == "004"		        
		FISR190()	
		oTree:TreeSeek('000')
		
	Case cIdTreePos == "005"
		FISA194()	
		oTree:TreeSeek('000')
	OtherWise
		aRet[1] 	:= ""
		aRet[2] 	:= ""
		aRet[3] 	:= ""
		aRet[4] 	:= ""
EndCase

Return aRet
