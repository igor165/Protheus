#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA791.ch'

/*/{Protheus.doc} FINA791
Rotina de cadastro de Fatura de Hotel

@author Alvaro Camillo Neto
@since 19/01/2016
@version P12.1.11
/*/
Function FINA791()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "FO8" )
	oBrowse:SetDescription(STR0001) //"Fatura de Hotel"

	oBrowse:AddLegend( "FO8_STATUS == '1'", "GREEN", STR0002 ) //"Ativa"
	oBrowse:AddLegend( "FO8_STATUS == '2'", "RED"  , STR0003 ) //"Cancelada"

	oBrowse:SetMenuDef( "FINA791" )
	oBrowse:Activate()
Return Nil

/*/{Protheus.doc} MenuDef
Definição do menu da tela de Fatura de Hotel

@author Alvaro Camillo Neto
@since 19/01/2016
@version P12.1.11
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.FINA791" OPERATION 2 ACCESS 0 //"Visualizar"
	//ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.FINA791" OPERATION 3 ACCESS 0
	//ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.FINA791" OPERATION 4 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Alvaro Camillo Neto
@since 19/01/2016
@version P12.1.11
/*/
Static Function ModelDef()
	Local oModel
	Local oStr1 := FWFormStruct( 1, 'FO8' )
	Local oStr2 := FWFormStruct( 1, 'FO9' )
	Local oStr3 := FWFormStruct( 1, 'FOA' )
	Local oStr4 := FWFormStruct( 1, 'FOB' )
	Local oStr5 := FWFormStruct( 1, 'FOC' )
	Local aRelation  := { { "FO9_FILIAL", "xFilial('FO9')" }, { "FO9_NUMFAT", "FO8_NUM" }, { "FO9_CLIFAT", "FO8_CLI" }, { "FO9_LOJFAT", "FO8_LOJA" } }
	Local aRelation2 := { { "FOA_FILIAL", "xFilial('FOA')" }, { "FOA_NUMFAT", "FO8_NUM" }, { "FOA_CLIFAT", "FO8_CLI" }, { "FOA_LOJFAT", "FO8_LOJA" } }
	Local aRelation3 := { { "FOB_FILIAL", "xFilial('FOB')" }, { "FOB_NUMFAT", "FO8_NUM" }, { "FOB_CLIFAT", "FO8_CLI" }, { "FOB_LOJFAT", "FO8_LOJA" } }
	Local aRelation4 := { { "FOC_FILIAL", "xFilial('FOC')" }, { "FOC_NUMFAT", "FO8_NUM" }, { "FOC_CLIFAT", "FO8_CLI" }, { "FOC_LOJFAT", "FO8_LOJA" } }
	
	oModel := MPFormModel():New( "FINA791", /*bPre*/, /*bPosVld*/, /*bCommit*/, /*bCancel*/ )

	oModel:SetDescription(STR0001) //'Fatura de Hotel'
	oModel:addFields('FO8MASTER',,oStr1)
	oModel:addGrid('FO9DETAIL','FO8MASTER',oStr2)
	oModel:addGrid('FOADETAIL','FO8MASTER',oStr3)
	oModel:addGrid('FOBDETAIL','FO8MASTER',oStr4)
	oModel:addGrid('FOCDETAIL','FO8MASTER',oStr5)
	
	oModel:GetModel("FO9DETAIL"):SetOptional( .T. )
	oModel:GetModel("FOADETAIL"):SetOptional( .T. )
	oModel:GetModel("FOBDETAIL"):SetOptional( .T. )
	oModel:GetModel("FOCDETAIL"):SetOptional( .T. )

	oModel:SetRelation( "FO9DETAIL", aRelation , FO9->( IndexKey( 1 ) ) ) //FO9_FILIAL+FO9_NUMFAT+FO9_CLIFAT+FO9_LOJFAT+FO9_SERIE+FO9_NUMDOC
	oModel:SetRelation( "FOADETAIL", aRelation2, FOA->( IndexKey( 1 ) ) ) //FOA_FILIAL+FOA_NUMFAT+FOA_CLIFAT+FOA_LOJFAT+FOA_PREFIX+FOA_NUM+FOA_PARCEL+FOA_TIPO
	oModel:SetRelation( "FOBDETAIL", aRelation3, FOB->( IndexKey( 1 ) ) ) //FOB_FILIAL+FOB_NUMFAT+FOB_CLIFAT+FOB_LOJFAT+FOB_PREFIX+FOB_NUM+FOB_PARCEL+FOB_TIPO
	oModel:SetRelation( "FOCDETAIL", aRelation4, FOC->( IndexKey( 1 ) ) ) //FOC_FILIAL+FOC_NUMFAT+FOC_CLIFAT+FOC_LOJFAT+FOC_SERIE+FOC_NUMDOC

	oModel:getModel('FO8MASTER'):SetDescription(STR0001 ) //'Fatura de Hotel'
	oModel:getModel('FO9DETAIL'):SetDescription(STR0005 ) //'Fatura Hotel x NFS-e'
	oModel:getModel('FOADETAIL'):SetDescription(STR0006 ) //'Fatura Hotel x Titulos'
	oModel:getModel('FOBDETAIL'):SetDescription(STR0010 ) //'Fatura Hotel x Comissão'
	oModel:getModel('FOCDETAIL'):SetDescription(STR0013 ) //'Fatura Hotel x NF-e'
	
Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Alvaro Camillo Neto
@since 19/01/2016
@version P12.1.11
/*/
Static Function ViewDef()
	Local oView
	Local oModel := ModelDef()
	Local oStr1 := FWFormStruct(2, 'FO8')
	Local oStr2 := FWFormStruct(2, 'FOA')
	Local oStr3 := FWFormStruct(2, 'FO9')
	Local oStr4 := FWFormStruct(2, 'FOB')
	Local oStr5 := FWFormStruct(2, 'FOC')

	oStr3:RemoveField( 'FO9_FILIAL' )
	oStr3:RemoveField( 'FO9_NUMFAT' )
	oStr3:RemoveField( 'FO9_CLIFAT' )
	oStr3:RemoveField( 'FO9_LOJFAT' )

	oStr2:RemoveField( 'FOA_FILIAL' )
	oStr2:RemoveField( 'FOA_NUMFAT' )
	oStr2:RemoveField( 'FOA_CLIFAT' )
	oStr2:RemoveField( 'FOA_LOJFAT' )

	oStr4:RemoveField( 'FOB_FILIAL' )
	oStr4:RemoveField( 'FOB_NUMFAT' )
	oStr4:RemoveField( 'FOB_CLIFAT' )
	oStr4:RemoveField( 'FOB_LOJFAT' )

	oStr5:RemoveField( 'FOC_FILIAL' )
	oStr5:RemoveField( 'FOC_NUMFAT' )
	oStr5:RemoveField( 'FOC_CLIFAT' )
	oStr5:RemoveField( 'FOC_LOJFAT' )

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField('VIEW_FO8', oStr1,'FO8MASTER')
	oView:AddGrid('VIEW_FOA' , oStr2,'FOADETAIL')
	oView:AddGrid('VIEW_FO9' , oStr3,'FO9DETAIL')
	oView:AddGrid('VIEW_FOB' , oStr4,'FOBDETAIL')
	oView:AddGrid('VIEW_FOC' , oStr5,'FOCDETAIL')

	oView:CreateHorizontalBox( 'SUPERIOR', 30 )
	oView:CreateHorizontalBox( 'MEIO', 70 )

	oView:CreateFolder( 'PASTA_INFERIOR', 'MEIO' )
	oView:AddSheet( 'PASTA_INFERIOR', 'ABA_NFSE'    , STR0011 ) //"Documentos Fiscais"
	oView:AddSheet( 'PASTA_INFERIOR', 'ABA_NFE'     , STR0014 ) //"DANFE sobre Cupom"
	oView:AddSheet( 'PASTA_INFERIOR', 'ABA_TITULO'  , STR0008 ) //"Contas a Receber"
	oView:AddSheet( 'PASTA_INFERIOR', 'ABA_COMISSAO', STR0012 ) //"Comissão"

	oView:CreateHorizontalBox( 'TITULO'  , 100, , , 'PASTA_INFERIOR', 'ABA_TITULO' )
	oView:CreateHorizontalBox( 'NOTA'    , 100, , , 'PASTA_INFERIOR', 'ABA_NFSE' )
	oView:CreateHorizontalBox( 'NFE'     , 100, , , 'PASTA_INFERIOR', 'ABA_NFE' )
	oView:CreateHorizontalBox( 'COMISSAO', 100, , , 'PASTA_INFERIOR', 'ABA_COMISSAO' )

	oView:SetOwnerView( 'VIEW_FO8', "SUPERIOR" )
	oView:SetOwnerView( 'VIEW_FOB', "COMISSAO" )
	oView:SetOwnerView( 'VIEW_FOA', "TITULO" )
	oView:SetOwnerView( 'VIEW_FO9', "NOTA" )
	oView:SetOwnerView( 'VIEW_FOC', "NFE" )

	oView:EnableTitleView('VIEW_FO8', STR0009 ) //"Fatura"
	oView:EnableTitleView('VIEW_FOB', STR0012 ) //"Comissão"
	oView:EnableTitleView('VIEW_FOA', STR0008 ) //"Contas a Receber"
	oView:EnableTitleView('VIEW_FO9', STR0011 ) //"Documentos Fiscais"
	oView:EnableTitleView('VIEW_FOC', STR0014 ) //"DANFE sobre Cupom"

Return oView

/*/{Protheus.doc} IntegDef
Função para chamada do adapter ao receber/enviar uma mensagem única

@param cXml, XML recebido pelo EAI Protheus
@param nType, Tipo de transação ("0" = TRANS_RECEIVE, "1" = TRANS_SEND)
@param cTypeMsg, Tipo da mensagem do EAI ("20" = EAI_MESSAGE_BUSINESS, "21" = EAI_MESSAGE_RESPONSE
"22" = EAI_MESSAGE_RECEIPT, "23" = EAI_MESSAGE_WHOIS)
@param cVersion, Versão da Mensagem Única TOTVS

@author Alvaro Camillo Neto
@since 19/01/2016
@version P12.1.11
/*/
Static Function IntegDef( cXml, nType, cTypeMsg, cVersion )

	Local aRet := {}
	aRet := FINI791( cXml, nType, cTypeMsg, cVersion )

Return aRet

/*/{Protheus.doc} ViewDef
Definição do interface

@author Alvaro Camillo Neto
@since 19/01/2016
@version P12.1.11
/*/
Function FIN791INI(cCampo,lComiss)
	Local xRet := Nil

	Default lComiss := .F.

	If lComiss
		If !INCLUI
			//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			xRet := Posicione( "SE2", 1, xFilial( "SE2", FOB->FOB_TITFIL ) + FOB->FOB_PREFIX + FOB->FOB_NUM + FOB->FOB_PARCEL + FOB->FOB_TIPO + FOB->FOB_FORCOM + FOB->FOB_LOJCOM, cCampo )
		Else
			xRet := CriaVar(cCampo,.F.)
		EndIf
	Else
		If !INCLUI
			xRet := Posicione( "SE1", 2, xFilial( "SE1", FOA->FOA_TITFIL ) + FOA->FOA_CLIFAT + FOA->FOA_LOJFAT + FOA->FOA_PREFIX + FOA->FOA_NUM + FOA->FOA_PARCEL + FOA->FOA_TIPO, cCampo )
		Else
			xRet := CriaVar(cCampo,.F.)
		EndIf
	EndIf

Return xRet
