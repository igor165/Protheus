#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA003
 
@author Erick G. Dias
@since 26/09/2013
@version 11.90

/*/
//-------------------------------------------------------------------
Function FISA003
Local	oBrw	:= FWmBrowse():New()


oBrw:SetDescription('Descrição')
oBrw:SetAlias( 'CLA')
oBrw:SetMenuDef( 'FISA003' )	
oBrw:Activate()  
	                            

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   

Local aRotina	:= {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FISA003' OPERATION 2 ACCESS 0 //"Visualizar"

Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCLA 	:= 	FWFormStruct( 1, 'CLA')
Local oStruCL4 	:= 	FWFormStruct( 1, 'CL4',{ |cCampo| CMPCL4(cCampo) } )
Local oModel
Local aAux := {}

//oModel	:=	MPFormModel():New('FISA003',,{ |oModel| ValidForm(oModel) }, {|oModel| Grava(oModel) } )
oModel	:=	MPFormModel():New('FISA003',,{ |oModel| .T. } , {|oModel| Grava(oModel, .T.) } )

//Adiciona a estrutura da CLA
oModel:AddFields( 'MODEL_CLA' , /*cOwner*/ , oStruCLA )
oStruCLA:SetProperty( 'CLA_DTREF'	 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
oStruCLA:SetProperty( 'CLA_CHV'	 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
oStruCLA:SetProperty( 'CLA_TPAJU'	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
oStruCLA:SetProperty( 'CLA_TPAJU' , MODEL_FIELD_INIT ,{|| Iif(ASA002CKZ()[4] $ '1/3/5','1' ,'0') } )

IF CL4->(FieldPos("CL4_IDCLA")) > 0 
	
	//Adiciona um grid com estrutura da CGB
	oModel:AddGrid( 'MODEL_CL4', 'MODEL_CLA', oStruCL4)
	oModel:SetRelation( 'MODEL_CL4', { { 'CL4_FILIAL', 'xFilial( "CL4" )' },;										 
										 { 'CL4_CHV', 'CLA_CHV' },;
										 { 'CL4_IDCLA', 'CLA_ID' }},;
										 CL4->( IndexKey( 1 ) ) )
EndIF

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local	oModel 		:= 	FWLoadModel( 'FISA003' )
Local  oStruCL4 	:= 	FWFormStruct( 2, 'CL4',{ |cCampo| CMPCL4(cCampo) } )
Local	oStruCLA 	:= 	Nil
Local	oView 		:= 	FWFormView():New()
Local cDescri		:= 'Ajustes EFD Contribuições '

oView:SetModel( oModel )
oStruCLA	:= 	FWFormStruct( 2, 'CLA' )
oView:AddField( 'VIEW_CLA', oStruCLA, 'MODEL_CLA' )

IF CL4->(FieldPos("CL4_IDCLA")) > 0 

	oView:AddGrid( 'VIEW_CL4', oStruCL4, 'MODEL_CL4' )
	oView:EnableTitleView( 'VIEW_CL4', 'Detalhamento dos ' + cDescri )	//"Percentuais por Tributo"
	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
	oView:CreateHorizontalBox( 'INFERIOR', 60 )

	oView:SetOwnerView( 'VIEW_CLA', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_CL4', 'INFERIOR' )
	
EndIF


cDescri	:= ASA002CKZ()[3]
oView:EnableTitleView( 'VIEW_CLA', cDescri )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Função que irá atualizar os valores de ajustes conforme edição do usuário 

@return oView - Objeto da View MVC

@author Erick G. Dias
@since 08/07/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function Grava(oModel)

Local	oModel		:=	FWModelActive()
Local	oModelCLA	:=	oModel:GetModel('MODEL_CLA')
Local	cChave		:=	oModelCLA:GetValue('CLA_CHV' )
Local cTpAju		:=  oModelCLA:GetValue('CLA_TPAJU' )
Local cCodAju		:=  oModelCLA:GetValue('CLA_COD' ) 
Local cNumDoc		:=  oModelCLA:GetValue('CLA_NUM' )
Local cDescr		:=  oModelCLA:GetValue('CLA_DESCR' )
Local nValAju		:=  oModelCLA:GetValue('CLA_VLAJU' )
Local dDtRef		:=  oModelCLA:GetValue('CLA_DTREF' )
Local cCodCred	:= SubStr(cChave,11,3)
Local cTrib		:= SubStr(cChave,9,1)
Local lGrava		:= .T.
Local cSoma		:= '2'
Local cSubTrai	:= '1'
Local cDebCrd		:= Iif(ASA002CKZ()[4] $'5/6' ,'1' ,'2' ) //1-credito - 2-debito
Local nValOrig	:= 0
Local	oAjustes

If cDebCrd == '1'//Se for crédito

	If  cTpAju == '0' .AND. CL8->(MSSEEK(xFilial('CL8')+dTos(MV_PAR01)+cChave)) 
	
		//Se o valor de redução for maior que o valor do crédito disponível, não irá efetuar o ajuste.
		IF nValAju > (CL8->CL8_VLCRED+CL8->CL8_AJAC)
			lGrava	:= .F.
			Alert("O valor da redução é maior que o valor do crédito disponível")
		EndIF
	EndIF
	
Else//débito
	
	If cTpAju == '0' .AND. CKS->(MSSEEK(xFilial('CKS')+dTos(MV_PAR01)+cChave))
		//Se o valor de redução for maior que o valor do crédito disponível, não irá efetuar o ajuste.
		IF nValAju > ((CKS->CKS_VLTRIB+CKS->CKS_AJAC+CKS->CKS_DIFANT)-CKS->CKS_AJRD-CKS->CKS_DIF)
			lGrava	:= .F.
			Alert("O valor da redução é maior que o valor do crédito disponível")
		EndIF
	EndIF		

EndIF

IF oModel:GetOperation() == MODEL_OPERATION_UPDATE //Alteração
	If CLA->(MSSEEK(xFilial('CLA')+cChave+cTpAju+cCodAju+padr(cNumDoc,50)+padr(cDescr,100)+dTos(dDtRef)))
		//busco o valor original para que possa saber se a edição foi para valor a maior ou a menor.
		nValOrig	:= CLA->CLA_VLAJU			
	EndIF
EndIF

If lGrava

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oModelCLA:SetValue( 'CLA_PERUTI' ,cvaltochar(strzero(month(MV_PAR01),2)) + cvaltochar(year(MV_PAR01)))
		oModelCLA:SetValue( 'CLA_CONSOL' ,ASA002CKZ()[7])
	EndIF

	FWFormCommit(oModel)	
	oAjustes 	:= AJUSTEEFD():New()
	oAjustes:SetConsol(ASA002CKZ()[7])
	oAjustes:SetDtIni(MV_PAR01)
	oAjustes:SetDtIni(MV_PAR01)
	oAjustes:SetDtRefer(MV_PAR01)
	oAjustes:SetTributo(cTrib)
	oAjustes:SetCrdDeb(cDebCrd)
	oAjustes:SetTpAjust(cTpAju)
	oAjustes:SetCodAju(cCodAju)
	oAjustes:SetNumDoc(cNumDoc)
	oAjustes:SetDescAju(cDescr)
	oAjustes:SetVlAjGrv(nValAju)
	oAjustes:SetCodDC(cCodCred)
	oAjustes:SetCHVEFD(cChave)	

	IF oModel:GetOperation() == MODEL_OPERATION_UPDATE //Alteração
		IF nValOrig > nValAju
			//Foi editado e mudou valor para menor, subtrair diferença
			oAjustes:SetVlAjGrv(nValOrig - nValAju)
			oAjustes:SetEdita(cSubTrai) 
		Else
			//Foi editado e mudou valor para maior, somar diferença
			oAjustes:SetVlAjGrv(nValAju - nValOrig)
			oAjustes:SetEdita(cSoma)
		EndIF	
	ElseIF oModel:GetOperation() == MODEL_OPERATION_DELETE //Exclusão
		oAjustes:SetVlAjGrv(nValAju)
		oAjustes:SetEdita(cSubTrai)
	EndIF

	oAjustes:AtuAjuste()
	
	oAjustes	:= NIl
EndIF


Return lGrava
//-------------------------------------------------------------------
/*/{Protheus.doc} CMPCL4
Funcao generica MVC do View

@return lRet - Indica se o campo será considerado ou não na estrutura

@author Erick G. Dias
@since 24/11/2015
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function CMPCL4(cCampo)                                       	

Local lRet	:= .T.

If alltrim(cCampo) $ "/CL4_PER/CL4_ID/CL4_CHV/CL4_IDCLA/"
	lRet	:= .F.
EndIF 


Return lRet
 