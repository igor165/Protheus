#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#INCLUDE "VEIA114.CH"

/*/{Protheus.doc} VEIA114
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VEIA114()

	Private oDlgVA114

	Private oBrwVJJ
	Private oBrwVJP
	Private oBrwVJM

	Private cFilCodMar := "" // Variavel utilizada na consulta padrao da VV2

	MontaTela()

	ACTIVATE MSDIALOG	oDlgVA114

Return


/*/{Protheus.doc} MontaTela
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MontaTela()

	Local oInterface := DMS_InterfaceHelper():New()
	Local oSizePrinc

	oInterface:nOpc := 3

	oInterface:SetOwnerPvt("VEIA114")

	//Tamanho do Form superior
	oSizePrinc := oInterface:CreateDefSize( .F. , ;
		{ ;
			{ "LINHA1" , 100 , 050 , .T. , .T. } ,; //
			{ "LINHA2" , 100 , 050 , .T. , .T. }  ; //
		} , ,  )
	oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
	oSizePrinc:Process()

	oInterface:SetDefSize(oSizePrinc)
	oDlgVA114 := oInterface:CreateDialog(STR0001 + " - JDQuote") // Painel
	
	// Browse de Cotacoes
	oInterface:SetDialog(oDlgVA114)
	oInterface:SetDefSize(oSizePrinc,"LINHA1")
	oPanVJJ := oInterface:CreateTPanel()
	oBrwVJJ := StaticCall(VEIA110,BrowseDef)
	oBrwVJJ:SetOwner(oPanVJJ)
	oBrwVJJ:SetMenuDef( 'VEIA110' )
	oBrwVJJ:Activate()

	oInterface:SetDialog( oDlgVA114 )
	oInterface:SetDefSize(oSizePrinc,"LINHA2")
	oPanFolder := oInterface:CreateTFolder( {;
		{"ABAS" , {"PO", STR0002 + " - CKC"} } ;
		} )

	oBrwVJM := StaticCall(VEIA112,BrowseDef)
	oBrwVJM:SetOwner(oPanFolder:aDialogs[1])
	oBrwVJM:SetMenuDef( 'VEIA112' )
	oBrwVJM:Activate()

	oBrwVJP := StaticCall(VEIA111,BrowseDef)
	oBrwVJP:SetOwner(oPanFolder:aDialogs[2])
	oBrwVJP:SetMenuDef( 'VEIA111' )
	oBrwVJP:Activate()


	oRelVJJ_VJM := FWBrwRelation():New()
	oRelVJJ_VJM:AddRelation( oBrwVJJ , oBrwVJM , {{ "VJM_FILIAL", "xFilial('VJM')" }, { "VJM_CODVJJ", "VJJ_CODIGO" } })
	oRelVJJ_VJM:Activate()

	oRelVJJ_VJP := FWBrwRelation():New()
	oRelVJJ_VJP:AddRelation( oBrwVJJ , oBrwVJP , {{ "VJP_FILIAL", "xFilial('VJP')" }, { "VJP_CODIGO", "VJJ_CODVJP" } })
	oRelVJJ_VJP:Activate()


Return