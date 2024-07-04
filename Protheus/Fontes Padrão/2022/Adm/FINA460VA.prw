#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH' 
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE "fina460VA.ch"

Static aVATitGer	:= {}
Static cProc		:= ""

/*/{Protheus.doc}FINA460VA
Valores Acessórios.
@author Simone Mie Sato Kakinoana 	
@since  13/10/2016
@version 12

/*/	
Function FINA460VA(cProcesso)

Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
Default cProcesso := ""

	cProc := cProcesso

FWExecView( STR0003 + " - " + STR0001,"FINA460VA", MODEL_OPERATION_UPDATE,/**/,/**/,/**/,,aEnableButtons )		//"Valores Acessórios"###"Alteração"

Return

/*/{Protheus.doc}ViewDef
Interface.
@author Simone Mie Sato Kakinoana
@since  13/10/2016
@version 12
/*/	
Static Function ViewDef()
Local oView  := FWFormView():New()
Local oModel := FWLoadModel('FINA460VA')
Local oFO0 	 := FWFormStruct(2,'FO0', { |x| ALLTRIM(x) $ 'FO0_PROCES' })
Local oFO2 	 := FWFormStruct(2,'FO2')
Local oFKD	 := FWFormStruct(2,'FKD', { |x| ALLTRIM(x) $ 'FKD_CODIGO, FKD_DESC, FKD_TPVAL,FKD_ACAO,FKD_VALOR' })
	
oFKD:SetProperty( 'FKD_TPVAL'	, MVC_VIEW_ORDEM,	'06')
oFKD:SetProperty( 'FKD_VALOR'	, MVC_VIEW_ORDEM,	'07')
oFKD:SetProperty( 'FKD_ACAO'	, MVC_VIEW_ORDEM,	'08')
	
oView:SetModel( oModel )	
oView:AddField("VIEWFO0",oFO0,"FO0MASTER")
oView:AddGrid("VIEWFKD" ,oFKD,"FKDDETAIL")
	
oView:SetViewProperty("VIEWFO0","SETLAYOUT",{FF_LAYOUT_HORZ_DESCR_TOP ,1})
	
	//
	
oView:CreateHorizontalBox( 'BOXFO0', 015 )
oView:CreateHorizontalBox( 'BOXFKD', 085 )
	
oView:SetOwnerView('VIEWFO0', 'BOXFO0') 
oView:SetOwnerView('VIEWFKD', 'BOXFKD')
	
oView:EnableTitleView('VIEWFO0' , STR0002 /*'Liquidação'*/ ) 
oView:EnableTitleView('VIEWFKD' , STR0003/*'Valores Acessórios'*/ ) 
	
oView:SetOnlyView('VIEWFO0')

Return oView

/*/{Protheus.doc}ModelDef
Modelo de dados.
@author Simone Mie Sato Kakinoana
@since  26/07/2016
@version 12
/*/	
Static Function ModelDef()
Local oModel	:= MPFormModel():New('FINA460VA',/*Pre*/,/*Pos*/,{|oModel|F460VAGRV( oModel )}/*Commit*/)
Local oFO0		:= FWFormStruct(1, 'FO0')
Local oFKD		:= FWFormStruct(1, 'FKD')
Local bFKDLP	:= { |oModel, nLine, cAction| F040VALP( oModel, nLine, cAction ) }
Local aAuxFKD	:= {}
Local aAuxFO2	:= {}
Local aTamAcao	:= TamSx3("FKC_ACAO")
Local bInitDesc	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_DESC"),"")')
Local bInitVal	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_TPVAL"),"")')
Local bInitPer	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_PERIOD"),"")')
Local bInitAcao	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_ACAO"),"")')

	oFO0:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)
		
	oFKD:AddTrigger( "FKD_CODIGO", "FKD_TPVAL" , {|| .T. },{|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_TPVAL")})
	oFKD:AddTrigger( "FKD_CODIGO", "FKD_DESC"  , {|| .T. },{|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_DESC")})
	oFKD:AddTrigger( "FKD_CODIGO", "FKD_PERIOD", {|| .T. },{|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_PERIOD")})
	oFKD:AddTrigger( "FKD_CODIGO", "FKD_ACAO"  , {|| .T. },{|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_ACAO")})	
	oFKD:AddTrigger( "FKD_VALOR" , "FKD_VLCALC", {|| .T. },{|oModel| oModel:GetValue("FKD_VALOR")})

	oFKD:SetProperty('FKD_CODIGO'	, MODEL_FIELD_OBRIGAT, .T. )
	oFKD:SetProperty('FKD_DESC'		, MODEL_FIELD_INIT, bInitDesc )    
	oFKD:SetProperty('FKD_PERIOD'	, MODEL_FIELD_INIT, bInitPer  )   
	oFKD:SetProperty('FKD_TPVAL'	, MODEL_FIELD_INIT, bInitVal  )
	oFKD:SetProperty('FKD_ACAO'		, MODEL_FIELD_INIT, bInitAcao )
	
	oFO0:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)
		
	oModel:AddFields("FO0MASTER",/*cOwner*/	, oFO0/*bPreVld*/	, /*bPost*/		,)
	oModel:AddGrid("FKDDETAIL"  ,"FO0MASTER", oFKD, bFKDLP,{||F040ValCod(oModel )})
	
	oModel:SetPrimaryKey({'FO0_FILIAL','FO0_PROCES'})
	oModel:GetModel( 'FKDDETAIL' ):SetUniqueLine( { 'FKD_CODIGO' } )
	oModel:GetModel( 'FKDDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'FKDDETAIL' ):SetOnlyQuery( .T. ) 	
	oModel:GetModel( 'FO0MASTER' ):SetOnlyQuery( .T. )
	
	oModel:SetActivate({|oModel|LoadFO0VA(oModel)})
	
	
Return oModel

/*/{Protheus.doc} LoadFO0VA
Função para Preencher o FO0_PROCES
@author jose.aribeiro
@since 20/10/2016
@version undefined
@return .T., Retorna .T. para o SetActivate
/*/
Function LoadFO0VA(oModel)
Local aDados		:= {}
Local oModelFO0		:= oModel:GetModel("FO0MASTER")

	
oModelFO0:LoadValue("FO0_PROCES",cProc)
	
Return .T.
/*/{Protheus.doc}F460VAGRV
Gravação do modelo de dados.
@param oModel - Modelo FINA040VA.
@author Simone Mie Sato Kakinoana
@since  26/07/2015
@version 12
/*/	
Function F460VAGRV( oModel )

Local oFKD			:= Nil  

Local nLine			:= 0
Local nFkd			:= 0  

oFKD			:= oModel:GetModel("FKDDETAIL")

nLine		:= oFKD:GetLine()
For nFkd := 1 to oFKD:Length()
	oFKD:GoLine(nFkd)
	If !oFKD:IsDeleted()
		AADD(aVaTitGer,	{oFKD:GetValue("FKD_CODIGO"), oFKD:GetValue("FKD_VALOR")})
		
	EndIf				
Next
oFKD:GoLine(nLine)

Return(.T.)

/*/{Protheus.doc}F460AAVA
Retorna o array dos valores acessórios

@author Simone Mie Sato Kakinoana
@since  19/10/2016
@version 12
/*/	
Function F460AAVA()

Return(aVATitGer)

/*/{Protheus.doc}F460CLEARVA
Limpa o array aVATiger
@author Simone Mie Sato Kakinoana
@since  19/10/2016
@version 12
/*/	
Function F460CLEARVA()

aVaTitGer	:= {}
	

Return(aVATitGer)
