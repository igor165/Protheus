#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA339.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA339
Rendimentos Relativos a Servicos, Juros e Dividendos Recebidos do Brasil e do Exterior

@author Roger Cangianeli
@since 20/05/2014
@version 1.0
  
/*/
//-------------------------------------------------------------------
Function TAFA339()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 )
oBrw:SetAlias('CG3')
oBrw:SetMenuDef( 'TAFA339' )
oBrw:SetCacheView(.F.)
oBrw:Activate()  


Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf339Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA339" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCG3 	:= 	FWFormStruct( 1, 'CG3' )
Local 	oModel 	:= MPFormModel():New( 'TAFA339' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_CG3', /*cOwner*/, oStruCG3)
oModel:GetModel( 'MODEL_CG3' ):SetPrimaryKey( { "CG3_PERIOD", "CG3_PAIS" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View
@return oView - Objeto da View MVC
@author Denis R de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA339' )
Local 	oStruCG3 	:= 	FWFormStruct( 2, 'CG3' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CG3', oStruCG3, 'MODEL_CG3' )

oView:EnableTitleView( 'VIEW_CG3', STR0001 ) //Rendimentos Relativos a Servicos, Juros e Dividendos Recebidos do Brasil e do Exterior
oView:CreateHorizontalBox( 'FIELDSCG3', 100 )
oView:SetOwnerView( 'VIEW_CG3', 'FIELDSCG3' )

oStruCG3:RemoveField('CG3_ID')

Return oView   

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
	
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁFuncao responsavel por setar o Status do registro para BrancoЁ
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		TAFAltStat( "CG3", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf339Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacУes caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function Taf339Vld(cAlias,nRecno,nOpc,lJob) 

Local aLogErro	:= {}
Local cBenFis	:= ''
Local cIndPro	:= ''

If (CG3->CG3_STATUS $ (' 1'))
	
	//Valida o Periodo
	If Empty(CG3->CG3_PERIOD)
		Aadd( aLogErro, { "CG3_PERIOD", "000003", "CG3", nRecno } ) //STR0003 - "Data Inconsistente ou Vazia."	
	EndIf

	//Valida o Pais
	If !Empty(CG3->CG3_PAIS)
		cChave := CG3->CG3_PAIS
		xValRegTab("C08",cChave,3,,@aLogErro,)
	Else
		AADD(aLogErro,{"CG3_PAIS","000001", "CG3",nRecno }) //STR0001 - "Campo Inconsistente ou Vazio."
	EndIf	


	//зддддддддддддддддддддддддддддд©
	//ЁATUALIZO O STATUS DO REGISTROЁ
	//Ё1 = Registro Invalido        Ё
	//Ё0 = Registro Valido          Ё
	//юддддддддддддддддддддддддддддды
	If Len(aLogErro)>0
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁUtilizo RecLock, pois o SETVALUE somente funciona em campos USADOSЁ
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		TAFAltStat("CG3", '1')
	Else
		TAFAltStat("CG3", '0')
	EndIf
	
Else
	AADD(aLogErro,{"CG3_ID","000017", "CG3", nRecno }) //STR0017 - "Registro jА validado"
	
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁNЦo apresento o alert quando utilizo o JOB para validarЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)