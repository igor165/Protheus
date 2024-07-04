#INCLUDE 'protheus.ch'
#INCLUDE 'apwizweb.ch'

STATIC _aPanData := {}	// Informações por Panel

//-------------------------------------------------------------------
/*/{Protheus.doc} SayInfoMRH
Constrói a interface dentro do painel de edição do ApWebWizard
@author  marcelo faria
@since   10/05/2019
@version 12
@protected
/*/
//-------------------------------------------------------------------
Function SayInfoMRH(lCreate,oPanelFoco,nNodeLine,oObjExplorer)
Local nEdBtn AS NUMERIC
Local bEdBlock AS BLOCK

Local oView AS OBJECT
oView := FWLoadView("apwiz160")

If nNodeLine == 1
	If lCreate
		// Monta code-block para botão de ediçao
		bEdBlock := {|| WizReload(ApWizMRH(.F.,.F.,nNodeLine)) ,;
						IIF(WizReload(),oObjExplorer:Deactivate(),NIL) }
			// Armazena os botões ... 
		aadd(_aPanData,{})
		aadd(_aPanData[nNodeLine],bEdBlock 	  )
		
		oView:SetOwner(oPanelFoco)
		oView:Activate()
	Else

		// Recupera os botões  ... 
		bEdBlock 	 	:= _aPanData[nNodeLine][1]

		// Reatribui Code-Block e Habilita botão de Edição ... 
		nEdBtn := GetIdEdBtn()
		oObjExplorer:aDButton[nEdBtn]:cToolTip 	:= STR0019 //'Editar Configuração'
		oObjExplorer:aDButton[nEdBtn]:bAction 	:= bEdBlock
		oObjExplorer:aDButton[nEdBtn]:Enable()
		oObjExplorer:aDButton[nEdBtn]:Show()

		// Refresh no Panel
		oPanelFoco:Refresh()

	Endif
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FreeInfoMRH
Limpa Arrays STATIC deste programa
/*/
//-------------------------------------------------------------------
Function FreeInfoMRH()
_aPanData := {}
Return .T.
