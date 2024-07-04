#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA338.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA338
Royalties Recebidos ou Pagos a BeneficiАrios do Brasil e do Exterior

@author Roger Cangianeli
@since 20/05/2014
@version 1.0
  
/*/
//-------------------------------------------------------------------
Function TAFA338()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 )
oBrw:SetAlias('CG2')
oBrw:SetMenuDef( 'TAFA338' )
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

Aadd( aFuncao, { "" , "Taf338Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA338" , , aFuncao )

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
Local oStruCG2 	:= 	FWFormStruct( 1, 'CG2' )
Local 	oModel 	:= MPFormModel():New( 'TAFA338' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_CG2', /*cOwner*/, oStruCG2)
oModel:GetModel( 'MODEL_CG2' ):SetPrimaryKey( { "CG2_PERIOD", "CG2_TIPROY", "CG2_PAIS" } )

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA338' )
Local 	oStruCG2 	:= 	FWFormStruct( 2, 'CG2' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CG2', oStruCG2, 'MODEL_CG2' )

oView:EnableTitleView( 'VIEW_CG2', STR0001 ) //Royalties Recebidos ou Pagos a BeneficiАrios do Brasil e do Exterior
oView:CreateHorizontalBox( 'FIELDSCG2', 100 )
oView:SetOwnerView( 'VIEW_CG2', 'FIELDSCG2' )

oStruCG2:RemoveField('CG2_ID')

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
		TAFAltStat( "CG2", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf338Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacУes caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function Taf338Vld(cAlias,nRecno,nOpc,lJob) 

Local aLogErro	:= {}
Local cBenFis	:= ''
Local cIndPro	:= ''

If (CG2->CG2_STATUS $ (' 1'))
	
	//Valida o Periodo
	If Empty(CG2->CG2_PERIOD)
		Aadd( aLogErro, { "CG2_PERIOD", "000003", "CG2", nRecno } ) //STR0003 - "Data Inconsistente ou Vazia."	
	EndIf

	//Valida o Tipo de Royalties
	If Empty(CG2->CG2_TIPROY)
		Aadd( aLogErro, { "CG2_TIPROY", "000001", "CG2", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."	
	Else
		If !CG2->CG2_TIPROY $ '1|2'
			Aadd( aLogErro, { "CG2_TIPROY", "000002", "CG2", nRecno } ) //STR0002 - "ConteЗdo do campo nЦo condiz com as opГУes possМveis."
		EndIf
	EndIf	

	//Valida o Pais
	If !Empty(CG2->CG2_PAIS)
		cChave := CG2->CG2_PAIS
		xValRegTab("C08",cChave,3,,@aLogErro,)
	Else
		AADD(aLogErro,{"CG2_PAIS","000001", "CG2",nRecno }) //STR0001 - "Campo Inconsistente ou Vazio"
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
		TAFAltStat("CG2", '1')
	Else
		TAFAltStat("CG2", '0')
	EndIf
	
Else
	AADD(aLogErro,{"CG2_ID","000017", "CG2", nRecno }) //STR0017 - "Registro jА validado"
	
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁNЦo apresento o alert quando utilizo o JOB para validarЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)