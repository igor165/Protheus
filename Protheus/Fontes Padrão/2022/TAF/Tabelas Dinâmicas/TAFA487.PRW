#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA487.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA487
Cadastro MVC Forma de Tributação para rendimentos de beneficiários no Exterior

@author Henrique Pereira	
@since 18/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA487()
Local oBrw as object
 
If TAFAlsInDic( "T9A" )
	oBrw := FwMBrowse():New()
	oBrw:SetDescription(STR0001) //"Forma de Tributação para rendimentos de beneficiários no Exterior"
	oBrw:SetAlias("T9A")
	oBrw:SetMenuDef("TAFA487")
	oBrw:Activate()
Else
	MsgInfo( STR0003 , STR0002 ) // "Não é possível proceder com a execução da Rotina, necessário atualização de dicionário referente ao layout do 1.3 do Reinf" / Tabela T9A não existe!
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Henrique Pereira	
@since 18/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA487"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Henrique Pereira	
@since 18/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT9A := FwFormStruct(1,"T9A")
Local oModel   := MpFormModel():New("TAFA487")

oModel:AddFields("MODEL_T9A",/*cOwner*/,oStruT9A)
oModel:GetModel("MODEL_T9A"):SetPrimaryKey({"T9A_FILIAL","T9A_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Henrique Pereira	
@since 18/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA487")
Local oStruT9A := FwFormStruct(2,"T9A")
Local oView    := FwFormView():New()

if TAFColumnPos("T9A_CREINF")
	oStruT9A:RemoveField("T9A_CODIGO")
	oStruT9A:SetProperty("T9A_CREINF", MVC_VIEW_ORDEM, "1")
	oStruT9A:SetProperty("T9A_DESCRI", MVC_VIEW_ORDEM, "2")
	oStruT9A:SetProperty("T9A_DTINI",  MVC_VIEW_ORDEM, "3")
	oStruT9A:SetProperty("T9A_DTFIN",  MVC_VIEW_ORDEM, "4")
	oStruT9A:RemoveField("T9A_ID")
EndIf

oView:SetModel(oModel)
oView:AddField("VIEW_T9A",oStruT9A,"MODEL_T9A")

oView:EnableTitleView("VIEW_T9A",STR0001) //"Forma de Tributação para rendimentos de beneficiários no Exterior"
oView:CreateHorizontalBox("FIELDST9A",100)
oView:SetOwnerView("VIEW_T9A","FIELDST9A")

Return(oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@author Henrique Pereira	
@since 18/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1028

If nVerEmp < nVerAtu .And. TAFAlsInDic( "T9A" ) .AND. TAFColumnPos("T9A_CREINF") //TAFAtualizado()
	aAdd( aHeader, "T9A_FILIAL" )
	aAdd( aHeader, "T9A_ID" )
	aAdd( aHeader, "T9A_CODIGO" )
	aAdd( aHeader, "T9A_CREINF" )
	aAdd( aHeader, "T9A_DESCRI" )
	aAdd( aHeader, "T9A_DTINI" )
	aAdd( aHeader, "T9A_DTFIN" )

	aAdd( aBody, { "", "00bd433f-5233-5d92-1d60-1bac24d6dc87", "0010", "10", "RETENÇÃO IRRF - ALÍQUOTA PADRÃO", "", "" } )
	aAdd( aBody, { "", "07869251-7c9f-13d9-2b12-98b7f1ff38cb", "0011", "11", "RETENÇÃO IRRF - ALÍQUOTA DA TABELA PROGESSIVA", "", "" } )
	aAdd( aBody, { "", "0eef8098-2d4d-d199-da64-617afede66f6", "0012", "12", "RETENÇÃO IRRF - ALÍQUOTA DIFERENCIADA(PAÍSES COM TRIBUTAÇÃO FAVORECIDA)", "", "" } )
	aAdd( aBody, { "", "2fdc1997-a159-16b5-6329-3014205c5d9a", "0013", "13", "RETENÇÃO IRRF - ALÍQUOTA LIMITADA CONFORME CLÁUSULA EM CONVÊNIO", "", "" } )
	aAdd( aBody, { "", "39c4cfc8-0d5a-9c23-d7e0-9ddc2f184279", "0030", "30", "RETENÇÃO IRRF - OUTRAS HIPÓTESES", "", "" } )
	aAdd( aBody, { "", "3c4fcaf1-c666-50d7-25ab-1747c8426f7f", "0040", "40", "NÃO RETENÇÃO IRRF - ISENÇÃO ESTABELECIDA EM CONVÊNIO", "", "" } )
	aAdd( aBody, { "", "73c9ce65-867d-c0a4-bd79-994af40cb264", "0041", "41", "NÃO RETENÇÃO IRRF - ISENÇÃO PREVISTA EM LEI INTERNA", "", "" } )
	aAdd( aBody, { "", "905ddb96-b881-ddf5-a2a8-3badc3fd6605", "0042", "42", "NÃO RETENÇÃO IRRF - ALÍQUOTA ZERO PREVISTA LEI INTERNA", "", "" } )
	aAdd( aBody, { "", "96c55a3d-4616-8f8f-b1d8-c3df0db22786", "0043", "43", "NÃO RETENÇÃO IRRF - PAGAMENTO ANTECIPADO DO IMPOSTO", "", ""} )
	aAdd( aBody, { "", "b2dc9bd4-359f-4003-f713-f3e62b0a761a", "0044", "44", "NÃO RETENÇÃO IRRF - MEDIDA JUDICIAL", "", "" } )
	aAdd( aBody, { "", "b35c07b0-33f6-97ef-c2fb-d31a034929ca", "0050", "50", "NÃO RETENÇÃO IRRF - OUTRAS HIPÓTESES", "", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )