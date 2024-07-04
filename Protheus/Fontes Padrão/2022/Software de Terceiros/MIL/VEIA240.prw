//Bibliotecas
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#include "AP5MAIL.CH"
#Include 'VEIA240.CH'

Static oTabTmp := NIL

/*/{Protheus.doc} VEIA240

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
 
Function VEIA240()

	oBrwVN0 := FwMBrowse():New()
	oBrwVN0:SetDescription( STR0001 ) // Pacote de Configuração
	oBrwVN0:SetAlias('VN0')
	oBrwVN0:AddLegend( 'VN0_STATUS=="0"' , 'BR_BRANCO'   , STR0002 ) // Pendente
	oBrwVN0:AddLegend( 'VN0_STATUS=="1"' , 'BR_VERDE'    , STR0003 ) // Ativado
	oBrwVN0:AddLegend( 'VN0_STATUS=="2"' , 'BR_VERMELHO' , STR0004 ) // Desativado
	oBrwVN0:Activate()

Return NIL


Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.VEIA241' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.VEIA240' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.VEIA241' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0008 ACTION 'VEIA244()' OPERATION 4 ACCESS 0 // Replicar Custo/Frete
	ADD OPTION aRotina TITLE STR0009 ACTION 'VEIA250( VN0->VN0_CODMAR , VN0->VN0_MODVEI , VN0->VN0_SEGMOD )' OPERATION 4 ACCESS 0 // Cadastro de Markup/Desconto
	ADD OPTION aRotina TITLE STR0010 ACTION 'VA2400171_EnviarEmail(.t.,.t.)' OPERATION 9 ACCESS 0 // Enviar e-mail de alteração na Lista de Preços dos Pacotes

Return aRotina


Static Function ModelDef()

	Local oModel 

	Local oMModVN0 		:= VA2400125_CamposGridVN0()
	Local oMModVN2 		:= VA2400135_CamposGridVN2()
	Local oMModVQC 		:= VA2400015_CamposGridVQC()
	Local oMModVQD 		:= VA2400025_CamposGridVQD()
	Local oMModSel 		:= VA2400105_CamposGridItemPacote()

	Local oModeloVN0 	:= oMModVN0:GetModel()
	Local oModeloVN2 	:= oMModVN2:GetModel()
	Local oModeloVQC 	:= oMModVQC:GetModel()
	Local oModeloVQD 	:= oMModVQD:GetModel()
	Local oModeloSel 	:= oMModSel:GetModel()

	oModeloSel:AddTrigger( "CPOVALOPC", "CPOVALOPC", {|| .T.}, { |oModel| VA2400115_CalculoOpcionaisSel(oModel) } )

	oModel := MPFormModel():New( 'VEIA240', /* bPre */,  , {|| VA2400175_GravaPacote() } /* bCommit */ , { || .T. } /* bCancel */ )
	oModel:AddFields('FILTRO'	, /* cOwner */	, oModeloVN0 , /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ )
	oModel:AddFields('PACOTE'		, 'FILTRO'	, oModeloVN2 , /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ )

	oModel:AddGrid('CABCONFIG'		,'PACOTE'	, oModeloVQC , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* <bLoad> */ )
	oModel:AddGrid('ITECONFIG'		,'CABCONFIG', oModeloVQD , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* <bLoad> */ )
	oModel:AddGrid('ITESELCFG'		,'PACOTE'	, oModeloSel , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* <bLoad> */ )

	oModel:SetDescription(STR0001) // Pacote de Configuração
	
	oModel:GetModel("FILTRO"):SetDescription(STR0011)		// Filtro de Configuração
	oModel:GetModel("CABCONFIG"):SetDescription(STR0012)	// Configuração
	oModel:GetModel("ITECONFIG"):SetDescription(STR0013)	// Itens da Configuração
	oModel:GetModel("PACOTE"):SetDescription(STR0014)		// Dados Pacote de Configuração
	oModel:GetModel("ITESELCFG"):SetDescription(STR0015)	// Itens selecionados da Configuração

	oModel:GetModel("CABCONFIG"):SetNoInsertLine( .T. )
	oModel:GetModel("CABCONFIG"):SetNoDeleteLine( .T. )

	oModel:GetModel("ITECONFIG"):SetNoInsertLine( .T. )
	oModel:GetModel("ITECONFIG"):SetNoDeleteLine( .T. )

	oModel:GetModel("ITESELCFG"):SetNoInsertLine( .T. )
	oModel:GetModel("ITESELCFG"):SetNoDeleteLine( .T. )

	oModel:SetRelation('ITECONFIG', { { 'VQD_FILIAL', 'xFilial("VQD")' }, { 'VQD_CODVQC', 'VQC_CODIGO' } })

	oModel:SetPrimaryKey({})
	
Return oModel

Static Function ViewDef()

	Local oModel	:= FWLoadModel( 'VEIA240' )
	Local oView 	:= Nil

	Local oMModVN0 := VA2400125_CamposGridVN0()
	Local oMModVN2 := VA2400135_CamposGridVN2()
	Local oMModVQC := VA2400015_CamposGridVQC()
	Local oMModVQD := VA2400025_CamposGridVQD()
	Local oMModSel := VA2400105_CamposGridItemPacote()

	Local oModeloVN0 := oMModVN0:GetView()
	Local oModeloVN2 := oMModVN2:GetView()
	Local oModeloVQC := oMModVQC:GetView()
	Local oModeloVQD := oMModVQD:GetView()
	Local oModeloSel := oMModSel:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField('FIELD_FILTRO'	, oModeloVN0 , 'FILTRO')
	oView:AddField('FIELD_PACOTE'	, oModeloVN2 , 'PACOTE')

	oView:AddGrid('GRID_CONFIG'		, oModeloVQC , 'CABCONFIG')
	oView:AddGrid('GRID_ITECONF'	, oModeloVQD , 'ITECONFIG')
	oView:AddGrid('GRID_OPCSEL'		, oModeloSel , 'ITESELCFG')

	oModeloSel:RemoveField('CPOCODPAC')
	oModeloSel:RemoveField('CPOCODCONF')
	oModeloSel:RemoveField('CPOCODVQD')

	oModeloVQC:RemoveField('CPOCODMAR')
	oModeloVQC:RemoveField('CPOGRUMOD')
	oModeloVQC:RemoveField('CPOMODVEI')
	oModeloVQC:RemoveField('CPOSEGMOD')

	oView:EnableTitleView('FIELD_FILTRO',STR0016) // Filtro
	oView:EnableTitleView('FIELD_PACOTE',STR0017) // Informações do Pacote

	oView:SetNoInsertLine('GRID_CONFIG')
	oView:SetNoDeleteLine('GRID_CONFIG')
	oView:EnableTitleView('GRID_CONFIG',STR0012) // Configuração

	oView:SetNoInsertLine('GRID_ITECONF')
	oView:EnableTitleView('GRID_ITECONF',STR0013) // Itens da Configuração

	oView:SetNoInsertLine('GRID_OPCSEL')
	oView:EnableTitleView('GRID_OPCSEL',STR0018) // Itens selecionados para o Pacote

	oView:CreateHorizontalBox('BOX_PACOTE',30)
	oView:CreateHorizontalBox('BOX_ITCONF',35)
	oView:CreateHorizontalBox('BOX_INCPAC',35)

	oView:createVerticalBox('BOX_FILTRO', 45, 'BOX_PACOTE')
	oView:createVerticalBox('BOX_CONFIG', 55, 'BOX_PACOTE')

	oView:createVerticalBox('BOX_INFPAC', 40, 'BOX_INCPAC')
	oView:createVerticalBox('BOX_OPCSEL', 60, 'BOX_INCPAC')

	oView:SetOwnerView('FIELD_FILTRO','BOX_FILTRO')
	oView:SetOwnerView('GRID_CONFIG' ,'BOX_CONFIG')
	oView:SetOwnerView('GRID_ITECONF','BOX_ITCONF')
	oView:SetOwnerView('FIELD_PACOTE','BOX_INFPAC')
	oView:SetOwnerView('GRID_OPCSEL' ,'BOX_OPCSEL')


	oView:SetCloseOnOk({||.T.})

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o 
	// qustionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 
	
	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

Return oView

Static Function VA2400015_CamposGridVQC()
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','MODSELVQC', FWBuildFeature(STRUCT_FEATURE_VALID,"VA2400085_MarkVQC()") , .t.)

	oRetorno:AddFieldDictionary( "VN0", "VN0_CODMAR" , { {"cIdField" , "CPOCODMAR"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VN0", "VN0_GRUMOD" , { {"cIdField" , "CPOGRUMOD"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VN0", "VN0_MODVEI" , { {"cIdField" , "CPOMODVEI"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VN0", "VN0_SEGMOD" , { {"cIdField" , "CPOSEGMOD"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )

	oRetorno:AddFieldDictionary( "VQC", "VQC_CODIGO" , { {"cIdField" , "CPOCODCONF"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQC", "VQC_DESCRI" , { {"cIdField" , "CPODESCONF"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )

Return oRetorno

Static Function VA2400025_CamposGridVQD()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','MODSELVQD', FWBuildFeature(STRUCT_FEATURE_VALID,"VA2400095_ItemPacote()") , .t.)
	
	oRetorno:AddFieldDictionary( "VQC", "VQC_CODIGO" , { {"cIdField" , "CPOCODCONF"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQC", "VQC_DESCRI" , { {"cIdField" , "CPODESCONF"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQD", "VQD_CODIGO" , { {"cIdField" , "CPOCODVQD"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQD", "VQD_BASCOD" , { {"cIdField" , "CPOBASCOD"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQD", "VQD_DESUSR" , { {"cIdField" , "CPOCONFBAS"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VJV", "VJV_CODOPC" , { {"cIdField" , "CPOCODOPC"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VJV", "VJV_DESOPC" , { {"cIdField" , "CPODESOPC"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQD", "VQD_VALCON" , { {"cIdField" , "CPOVALOPC"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )

Return oRetorno


Static Function VA2400105_CamposGridItemPacote()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddFieldDictionary( "VN0", "VN0_CODIGO" , { {"cIdField" , "CPOCODPAC"}		, { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQC", "VQC_CODIGO" , { {"cIdField" , "CPOCODCONF"}	, { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQD", "VQD_CODIGO" , { {"cIdField" , "CPOCODVQD"}		, { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VJV", "VJV_CODOPC" , { {"cIdField" , "CPOCODOPC"}		, { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VJV", "VJV_DESOPC" , { {"cIdField" , "CPODESOPC"}		, { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQD", "VQD_BASCOD" , { {"cIdField" , "CPOBASCOD"}		, { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQD", "VQD_DESUSR" , { {"cIdField" , "CPOCONFBAS"}	, { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQD", "VQD_VALCON" , { {"cIdField" , "CPOVALOPC"}		, { "lVirtual", .t. } , { "lCanChange" , .f. } } )

Return oRetorno


Static Function VA2400125_CamposGridVN0()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddFieldDictionary( "VN0", "VN0_CODMAR" , { {"cIdField" , "VN0_CODMAR"} } )
	oRetorno:AddFieldDictionary( "VN0", "VN0_GRUMOD" , { {"cIdField" , "VN0_GRUMOD"} } )
	oRetorno:AddFieldDictionary( "VN0", "VN0_MODVEI" , { {"cIdField" , "VN0_MODVEI"} } )
	oRetorno:AddFieldDictionary( "VN0", "VN0_SEGMOD" , { {"cIdField" , "VN0_SEGMOD"} } )
	oRetorno:AddFieldDictionary( "VN0", "VN0_BASCOD" , { {"cIdField" , "VN0_BASCOD"} } )

	oRetorno:AddButton(STR0019,'BTNPESQUISA',{ |oMdl| VA2400075_BuscarConfiguracao(oMdl) }) // Buscar Configurações

Return oRetorno


Static Function VA2400135_CamposGridVN2()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddFieldDictionary( "VN0", "VN0_DESPAC" , { {"cIdField" , "CPODESPAC"} } )
	oRetorno:AddFieldDictionary( "VN0", "VN0_CFGBAS" , { {"cIdField" , "CPOCFGBAS"} } )

	oRetorno:AddFieldDictionary( "VN2", "VN2_DATINI" , { {"cIdField" , "CPODATINI"} } )
	oRetorno:AddFieldDictionary( "VN2", "VN2_VALPAC" , { {"cIdField" , "CPOVALPAC"} } )
	oRetorno:AddFieldDictionary( "VN2", "VN2_FREPAC" , { {"cIdField" , "CPOFREPAC"} } )

Return oRetorno


Static Function VA2400045_GetVQC(cCodMar,cGruMod,cModVei,cSegMod,cBasCod)

Local i := 0
Local aRetorno := {}

Private oSqlSrv   := DMS_SqlHelper():New()
Private oArHlpSrv := DMS_ArrayHelper():New()

cQuery := "SELECT '', VQC_CODIGO, VQC_DESCRI "
cQuery += "FROM " + RetSqlName("VQC") + " VQC "
cQuery += "WHERE VQC.VQC_FILIAL = '" +xFilial("VQC")+ "' "
cQuery +=  " AND VQC.VQC_CODMAR = '" + cCodMar + "' "
cQuery +=  " AND VQC.VQC_GRUMOD = '" + cGruMod + "' "
cQuery +=  " AND VQC.VQC_MODVEI = '" + cModVei + "' "
cQuery +=  " AND VQC.VQC_SEGMOD = '" + cSegMod + "' "
cQuery +=  " AND EXISTS( SELECT NULL "
cQuery +=				" FROM " +RetSqlName("VQD")+ " VQD "
cQuery +=				" WHERE VQD.VQD_FILIAL ='" +xFilial("VQD")+ "' "
cQuery +=					" AND VQD.VQD_CODVQC = VQC.VQC_CODIGO "
cQuery +=					" AND VQD.VQD_BASCOD ='" +cBasCod + "' "
cQuery +=					" AND VQD.D_E_L_E_T_ =' ')"
cQuery +=  " AND VQC.D_E_L_E_T_ = ' ' "

adata := oSqlSrv:GetSelectArray(cQuery,3)

For i := 1 to Len(adata)
	adata[i,1] := .f.
Next

aRetorno := oArHlpSrv:Map(adata , {|aEl| {0, aEl} })

Return aRetorno


Static Function VA2400055_GetVQD(cCodVQC,cBasCod)

Local i := 0
Local aRetorno := {}

Private oSqlPrd := DMS_SqlHelper():New()
Private oArHlpPrd := DMS_ArrayHelper():New()

cQuery := "SELECT '', VQD_BASCOD, VQD_DESUSR, VJV_CODOPC, VJV_DESOPC, VQD_VALCON, VQD_CODIGO "
cQuery += "FROM " + RetSqlName("VQD") + " VQD "
cQuery += " LEFT JOIN " + RetSqlName("VJV") + " VJV "
cQuery += 		" ON VJV.VJV_FILIAL = '" + xFilial("VJV") + "' "
cQuery += 		"AND VJV.VJV_CODIGO = VQD.VQD_CODVJV "
cQuery += 		"AND VJV.D_E_L_E_T_ = ' '"
cQuery += "WHERE VQD.VQD_FILIAL = '" +xFilial("VQD")+ "' "
cQuery +=  " AND VQD.VQD_CODVQC = '" + cCodVQC + "' "
cQuery +=  " AND VQD.VQD_BASCOD = '" + cBasCod + "' "
cQuery +=  " AND VQD.D_E_L_E_T_ = ' ' "

adata := oSqlPrd:GetSelectArray(cQuery,7)

For i := 1 to Len(adata)
	adata[i,1] := .f.
Next

aRetorno := oArHlpPrd:Map(adata , {|aEl| {0, aEl} })

Return aRetorno

Static Function VA2400075_BuscarConfiguracao()

	Local nVQC, nVQD:= 0
	Local oModel	:= FWModelActive()
	Local oView		:= FWViewActive()
	Local aVQCRel	:= {}
	Local aVQDRel	:= {}

	oModFiltro  := oModel:GetModel("FILTRO")
	oModCabConf := oModel:GetModel("CABCONFIG")
	oModIteConf := oModel:GetModel("ITECONFIG")

	oModCabConf:SetNoInsertLine(.f.)
	oModIteConf:SetNoInsertLine(.f.)

	aVQCRel := VA2400045_GetVQC(oModFiltro:GetValue("VN0_CODMAR"),oModFiltro:GetValue("VN0_GRUMOD"),oModFiltro:GetValue("VN0_MODVEI"),oModFiltro:GetValue("VN0_SEGMOD"), oModFiltro:GetValue("VN0_BASCOD"))

	For nVQC:= 1 to Len(aVQCRel)

		oModCabConf:AddLine()

		oModCabConf:SetValue("MODSELVQC" , aVQCRel[nVQC,2,1] )
		oModCabConf:LoadValue("CPOCODMAR" , oModFiltro:GetValue("VN0_CODMAR") )
		oModCabConf:LoadValue("CPOGRUMOD" , oModFiltro:GetValue("VN0_GRUMOD") )
		oModCabConf:LoadValue("CPOMODVEI" , oModFiltro:GetValue("VN0_MODVEI") )
		oModCabConf:LoadValue("CPOSEGMOD" , oModFiltro:GetValue("VN0_SEGMOD") )

		oModCabConf:LoadValue("CPOCODCONF" , aVQCRel[nVQC,2,2] )
		oModCabConf:LoadValue("CPODESCONF" , aVQCRel[nVQC,2,3] )

		aVQDRel := VA2400055_GetVQD(aVQCRel[nVQC,2,2],oModFiltro:GetValue("VN0_BASCOD"))

		For nVQD:= 1 to Len(aVQDRel)

			oModIteConf:AddLine()

			oModIteConf:SetValue("MODSELVQD"  , aVQDRel[nVQD,2,1] )
			oModIteConf:LoadValue("CPOCODCONF" , aVQCRel[nVQC,2,2] )
			oModIteConf:LoadValue("CPODESCONF" , aVQCRel[nVQC,2,3] )
			oModIteConf:LoadValue("CPOBASCOD"  , aVQDRel[nVQD,2,2] )
			oModIteConf:LoadValue("CPOCONFBAS" , aVQDRel[nVQD,2,3] )
			oModIteConf:LoadValue("CPOCODOPC"  , aVQDRel[nVQD,2,4] )
			oModIteConf:LoadValue("CPODESOPC"  , aVQDRel[nVQD,2,5] )
			oModIteConf:LoadValue("CPOVALOPC"  , aVQDRel[nVQD,2,6] )
			oModIteConf:LoadValue("CPOCODVQD"  , aVQDRel[nVQD,2,7] )

		Next

	Next

	If oModCabConf:Length() > 1
		oModCabConf:GoLine(1)
	EndIf

	If oModIteConf:Length() > 1
		oModIteConf:GoLine(1)
	EndIf

	oView:Refresh()

Return .t.


Function VA2400085_MarkVQC()

	Local oModel	:= FWModelActive()
	Local oView		:= FWViewActive()
	Local cCodVQC	:= ""
	Local nVQD		:= 0
	
	oMod_VQC := oModel:GetModel("CABCONFIG")
	oMod_VQD := oModel:GetModel("ITECONFIG")

	cCodVQC := oMod_VQC:GetValue("CPOCODCONF")

	For nVQD:= 1 to oMod_VQD:Length()
		oMod_VQD:GoLine(nVQD)
		If oMod_VQD:SeekLine({{"MODSELVQD",!(oMod_VQC:GetValue("MODSELVQC"))},{"CPOCODCONF",cCodVQC}},.f.,.f.)
			oMod_VQD:SetValue("MODSELVQD"  , oMod_VQC:GetValue("MODSELVQC") )
			VA2400095_ItemPacote()
		EndIf
	Next
	oMod_VQD:GoLine(1)
	oView:Refresh()

Return .t.

Function VA2400095_ItemPacote(nLineVQD)

	Local oModel	:= FWModelActive()
	Local oView		:= FWViewActive()

	Default nLineVQD := 0

	oMod_VQD 	:= oModel:GetModel("ITECONFIG")
	oMod_ItemPac:= oModel:GetModel("ITESELCFG")

	oMod_ItemPac:SetNoInsertLine(.f.)

	If oMod_VQD:GetValue("MODSELVQD")

		If oMod_ItemPac:SeekLine({{"CPOCODVQD",oMod_VQD:GetValue("CPOCODVQD")}},.f.,.f.)
		Else
			oMod_ItemPac:AddLine()

			oMod_ItemPac:LoadValue("CPOCODCONF" , oMod_VQD:GetValue("CPOCODCONF") )
			oMod_ItemPac:LoadValue("CPOCODVQD"  , oMod_VQD:GetValue("CPOCODVQD") )

			oMod_ItemPac:LoadValue("CPOCODOPC"  , oMod_VQD:GetValue("CPOCODOPC") )
			oMod_ItemPac:LoadValue("CPODESOPC"  , oMod_VQD:GetValue("CPODESOPC") )
			oMod_ItemPac:LoadValue("CPOBASCOD" , oMod_VQD:GetValue("CPOBASCOD") )
			oMod_ItemPac:SetValue("CPOVALOPC"  , oMod_VQD:GetValue("CPOVALOPC") )
		EndIf

	EndIF

	oMod_ItemPac:SetNoInsertLine(.t.)

	oMod_ItemPac:GoLine(1)
	oView:Refresh()

Return .t.

Static Function VA2400115_CalculoOpcionaisSel(oModExec)
	Local nRetorno := 0
	Local oModel	:= FWModelActive()

	oMod_VN2 	:= oModel:GetModel("PACOTE")

	nRetorno := oMod_VN2:GetValue("CPOVALPAC")
	nRetorno += oModExec:GetValue("CPOVALOPC")

	oMod_VN2:LoadValue( "CPOVALPAC", nRetorno )

Return nRetorno

Static Function VA2400175_GravaPacote()

	Local oModel	:= FWModelActive()
	Local oModelVN0 := FWLoadModel( 'VEIA241' )
	Local nx := 0
	Local lGrvDta := .t.

		oModFIl := oModel:GetModel('FILTRO')
		oModPac := oModel:GetModel('PACOTE')
		oModSel := oModel:GetModel('ITESELCFG')

		If oModSel:Length() > 0

			oModelVN0:SetOperation( MODEL_OPERATION_INSERT )
			lRet := oModelVN0:Activate()

			if lRet
				oModelVN0:SetValue( "VN0MASTER", "VN0_STATUS", "0" )
				oModelVN0:SetValue( "VN0MASTER", "VN0_CODMAR", oModFIl:GetValue('VN0_CODMAR') )
				oModelVN0:SetValue( "VN0MASTER", "VN0_GRUMOD", oModFIl:GetValue('VN0_GRUMOD') )
				oModelVN0:SetValue( "VN0MASTER", "VN0_MODVEI", oModFIl:GetValue('VN0_MODVEI') )
				oModelVN0:SetValue( "VN0MASTER", "VN0_SEGMOD", oModFIl:GetValue('VN0_SEGMOD') )
				oModelVN0:SetValue( "VN0MASTER", "VN0_BASCOD", oModFIl:GetValue('VN0_BASCOD') )
				oModelVN0:SetValue( "VN0MASTER", "VN0_DESPAC", oModPac:GetValue('CPODESPAC') )
				oModelVN0:SetValue( "VN0MASTER", "VN0_CFGBAS", oModPac:GetValue('CPOCFGBAS') )

				oModDtVN1 := oModelVN0:GetModel("VN1DETAIL")

				for nX := 1 to oModSel:Length()

					If oModSel:IsDeleted(nX)
						loop
					Else
						oModSel:GoLine(nX)

						oModDtVN1:AddLine()

						oModDtVN1:SetValue( "VN1_CODVN0", oModelVN0:GetValue( "VN0MASTER", "VN0_CODIGO") )
						oModDtVN1:SetValue( "VN1_CODVQC", oModSel:GetValue("CPOCODCONF") )
						oModDtVN1:SetValue( "VN1_CODVQD", oModSel:GetValue("CPOCODVQD") )

					EndIf
				next

				oModDtVN2 := oModelVN0:GetModel("VN2DETAIL")

				If lGrvDta
					lGrvDta := .f.
					oModDtVN2:AddLine()

					oModDtVN2:SetValue( "VN2_CODVN0", oModelVN0:GetValue( "VN0MASTER", "VN0_CODIGO") )
					oModDtVN2:SetValue( "VN2_STATUS", "1" )
					oModDtVN2:SetValue( "VN2_DATINI", oModPac:GetValue('CPODATINI') )
					oModDtVN2:SetValue( "VN2_VALPAC", oModPac:GetValue('CPOVALPAC') )
					oModDtVN2:SetValue( "VN2_FREPAC", oModPac:GetValue('CPOFREPAC') )
					oModDtVN2:SetValue( "VN2_USRCAD", __cUserID )
				EndIf

				If ( lRet := oModelVN0:VldData() )
					if ( lRet := oModelVN0:CommitData())
					Else
						Help("",1,"COMMITVN0",,STR0020,1,0) // Não foi possivel incluir o(s) registro(s)
					EndIf
				Else
					Help("",1,"VALIDVN0",,STR0021,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
				EndIf
			Else
				Help("",1,"ACTIVEVN0",,STR0022,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VN0
			EndIf
		
		Endif

Return lRet

/*/
{Protheus.doc} VA2400141_CustoTotal
Retorna o Valor de Custo + Frete do Pacote pelo CHAINT ou Codigo do Pacote

@author Andre Luis Almeida
@since 15/07/2021
/*/
Function VA2400141_CustoTotal( cChaInt , cCodPac )
Local oSqlHlp := DMS_SqlHelper():New()
Local cQuery  := ""
Default cCodPac := ""
If Empty(cCodPac)
	cCodPac := VA2400161_QualPacote( cChaInt )
EndIf
cQuery := "SELECT VN2_VALPAC + VN2_FREPAC "
cQuery += "  FROM " + RetSqlName("VN2")
cQuery += " WHERE VN2_FILIAL = '"+xFilial("VN2")+"' "
cQuery += "   AND VN2_CODVN0 = '"+cCodPac+"'"
cQuery += "   AND VN2_STATUS = '1' "
cQuery += "   AND VN2_DATINI <= '"+dtos(dDataBase)+"' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY VN2_DATINI DESC "
Return FM_SQL(oSqlHlp:TOPFunc( cQuery ,1))

/*/
{Protheus.doc} VA2400151_ValorVendaPacote
Retorna o Valor de Venda do Pacote pelo CHAINT ou Codigo do Pacote

@author Andre Luis Almeida
@since 15/07/2021
/*/
Function VA2400151_ValorVendaPacote( cChaInt , cCodPac , cTpRet )
Local nVlrVda := 0
Local nCusPct := 0
Local nMarkAP := 0
Local nMarkAV := 0
Local nVlrAP  := 0
Local nVlrAV  := 0
Local nArred  := GetNewPar("MV_MIL0170",2) // Preços Pacotes - utilizar arredondamento (round). Exemplo: 2 = 2 casas decimais, 1 = 1 casa decimal, 0 = valor sem decimal
Default cCodPac := ""
Default cTpRet  := "0" // 0 = Retorna o Valor Maior / 1 = Preço A VISTA / 2 = Preço A PRAZO
If Empty(cCodPac)
	cCodPac := VA2400161_QualPacote( cChaInt )
EndIf
If !Empty(cCodPac)
	VN0->(DbSetOrder(1))
	VN0->(DbSeek(xFilial("VN0")+cCodPac))
	nCusPct := VA2400141_CustoTotal( cChaInt , cCodPac ) // Custo + Frete
	If nCusPct > 0
		If cTpRet == "0" .or. cTpRet == "1" // 0 = Retorna o Valor Maior / 1 = Preço A VISTA
			nMarkAV := VA2500021_Retorna_Indice_VN3( VN0->VN0_CODMAR , VN0->VN0_MODVEI , VN0->VN0_SEGMOD , "1" , dDataBase ) // 1 - Markup A VISTA
		EndIf
		If cTpRet == "0" .or. cTpRet == "2" // 0 = Retorna o Valor Maior / 2 = Preço A PRAZO
			nMarkAP := VA2500021_Retorna_Indice_VN3( VN0->VN0_CODMAR , VN0->VN0_MODVEI , VN0->VN0_SEGMOD , "2" , dDataBase ) // 2 - Markup A PRAZO
		EndIf
		Do Case
			Case cTpRet == "0" // 0 = Retorna o Valor Maior
				// Utilizar o Markup que tras o maior Valor de Venda
				If nMarkAP > 0
					nVlrAP := ( nCusPct / nMarkAP ) // utiliza Markup A PRAZO
				EndIf
				If nMarkAV > 0
					nVlrAV := ( nCusPct / nMarkAV ) // utiliza Markup A VISTA
				EndIf
				nVlrVda := IIf( nVlrAP > nVlrAV , nVlrAP , nVlrAV ) // Pegar o Valor Maior
			Case cTpRet == "1" // 1 = Preço A VISTA
				If nMarkAV > 0
					nVlrVda  := ( nCusPct / nMarkAV ) // utiliza Markup A VISTA
				EndIf
			Case cTpRet == "2" // 2 = Preço A PRAZO
				If nMarkAP > 0
					nVlrVda  := ( nCusPct / nMarkAP ) // utiliza Markup A PRAZO
				EndIf
		EndCase
	EndIf
EndIf
Return round(nVlrVda,nArred)

/*/
{Protheus.doc} VA2400161_QualPacote
Retorna qual pacote o CHAINT esta relacionado

@author Andre Luis Almeida
@since 15/07/2021
/*/
Function VA2400161_QualPacote( cChaInt )
Local cQuery  := ""
cQuery := "SELECT VQE_CODPAC "
cQuery += "  FROM "+RetSqlName("VQE")
cQuery += " WHERE VQE_FILIAL = '" + xFilial("VQE") + "'"
cQuery += "   AND VQE_CHAINT = '" + cChaInt + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
Return FM_SQL(cQuery)

/*/
{Protheus.doc} VA2400171_EnviarEmail
Enviar E-mail referente a alteração na Lista de Preços dos Pacotes

@author Andre Luis Almeida
@since 26/07/2021
/*/
Function VA2400171_EnviarEmail(lMsg,lVld)
Local lOk := .f., lSendOK := .f.
Local cError     := ""
Local cMailConta := GETMV("MV_EMCONTA") // Usuario/e-mail de envio
Local cMailServer:= GETMV("MV_RELSERV") // Server de envio
Local cMailSenha := GETMV("MV_EMSENHA") // Senha e-mail de envio
Local lAutentica := GetMv("MV_RELAUTH",,.f.)          // Determina se o Servidor de E-mail necessita de Autenticacao
Local cUserAut   := Alltrim(GetMv("MV_RELAUSR",," ")) // Usuario para Autenticacao no Servidor de E-mail
Local cPassAut   := Alltrim(GetMv("MV_RELAPSW",," ")) // Senha para Autenticacao no Servidor de E-mail
Local cEmail	 := GetNewPar("MV_MIL0169","")        // E-mail destinatario ao alterar a Lista de Preço dos Pacotes
Local cTitulo    := STR0023 // Alteração na Lista de Preços dos Pacotes
Local lContinua  := .t.
Default lMsg     := .t.
Default lVld     := .f.
Private cMensagem := ""
If Empty(cEmail)
	lContinua := .f.
	If lVld
		MsgInfo(STR0024+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"MV_MIL0169",STR0025) // Necessário configurar o parametro referente ao e-mail do destinatário para avisar sobre mudança na Lista de Preços dos Pacotes. / Atenção
	EndIf
EndIf
If lContinua
	If lMsg
		lContinua := MsgYesNo(STR0026+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cEmail,STR0025) // Deseja enviar e-mail informando que houve mudança na Lista de Preços dos Pacotes? / Atenção
	EndIf
	If lContinua
		// Envia e-mail
		If !Empty(cMailConta) .And. !Empty(cMailServer) .And. !Empty(cMailSenha)
			// Conecta uma vez com o servidor de e-mails
			CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk
			If lOk
				If lAutentica
					If !MailAuth(cUserAut,cPassAut)
						If lMsg
							MsgStop(STR0027,STR0025) // Erro na autenticação do usuário de e-mail. / Atenção
						EndIf
						lOk := .f.
						DISCONNECT SMTP SERVER
					EndIf
				EndIf
				If lOk
					// HTML Padrao //
					cMensagem += "<center>"
					cMensagem += "<font size=3 face='verdana,arial' Color=black><b>"+cTitulo+"</b></font>"
					cMensagem += "<br><br><br>"
					cMensagem += "<font size=3 face='verdana,arial' Color=black>"
					cMensagem += STR0028+": "+__cUserID+" - "+left(UPPER(Alltrim(UsrRetName(__CUSERID))),20)+"<br>" // Usuário
					cMensagem += STR0029+": "+Transform(dDataBase,"@D")+" "+Transform(time(),"@R 99:99") // Data/Hora
					cMensagem += "</font>"
					cMensagem += "<br><br><br><hr width=90%></center>"
					// Envia e-mail com os dados necessarios
					SEND MAIL FROM cMailConta to Alltrim(cEmail) SUBJECT (cTitulo) BODY cMensagem FORMAT TEXT RESULT lSendOk
					If !lSendOk
						//Erro no Envio do e-mail
						GET MAIL ERROR cError
						If lMsg
							MsgStop(STR0030,STR0025) // Erro no envio de e-mail. / Atenção
						EndIf
					Else
						If lMsg
							MsgInfo(STR0031,STR0025) // E-mail enviado com sucesso! / Atenção
						EndIf
					EndIf
					// Desconecta com o servidor de e-mails
					DISCONNECT SMTP SERVER
				EndIf
			Else
				If lMsg
					MsgStop((STR0032+chr(13)+chr(10)+cMailServer),STR0025) // Nao foi possivel conectar no servidor de e-mail. / Atenção
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
Return .t.