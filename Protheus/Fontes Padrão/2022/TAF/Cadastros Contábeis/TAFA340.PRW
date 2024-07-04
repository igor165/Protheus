#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA340.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA340
Rendimentos Relativos a Servicos, Juros e Dividendos Recebidos do Brasil e do Exterior

@author Roger Cangianeli
@since 20/05/2014
@version 1.0

/*/  
//-------------------------------------------------------------------
Function TAFA340()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 )
oBrw:SetAlias('CG5')
oBrw:SetMenuDef( 'TAFA340' )
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

Aadd( aFuncao, { "" , "Taf340Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA340" , , aFuncao )

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
Local oStruCG5 	:= 	FWFormStruct( 1, 'CG5' )
Local 	oModel 	:= MPFormModel():New( 'TAFA340' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_CG5', /*cOwner*/, oStruCG5)
oModel:GetModel( 'MODEL_CG5' ):SetPrimaryKey( { "CG5_PERIOD", "CG5_PAIS" } )

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA340' )
Local 	oStruCG5 	:= 	FWFormStruct( 2, 'CG5' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CG5', oStruCG5, 'MODEL_CG5' )

oView:EnableTitleView( 'VIEW_CG5', STR0001 ) //Rendimentos Relativos a Servicos, Juros e Dividendos Recebidos do Brasil e do Exterior
oView:CreateHorizontalBox( 'FIELDSCG5', 100 )
oView:SetOwnerView( 'VIEW_CG5', 'FIELDSCG5' )

oStruCG5:RemoveField('CG5_ID')

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
		TAFAltStat( "CG5", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf340Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacУes caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function Taf340Vld(cAlias,nRecno,nOpc,lJob) 

Local aLogErro	:= {}
Local cBenFis	:= ''
Local cIndPro	:= ''

If (CG5->CG5_STATUS $ (' 1'))

	//Valida o Periodo
	If Empty(CG5->CG5_PERIOD)
		Aadd( aLogErro, { "CG5_PERIOD", "000003", "CG5", nRecno } ) //STR0003 - "Data Inconsistente ou Vazia"	
	EndIf

	//Valida o Pais
	If !Empty(CG5->CG5_PAIS)
		cChave := CG5->CG5_PAIS
		xValRegTab("C08",cChave,3,,@aLogErro,)
	Else
		AADD(aLogErro,{"CG5_PAIS","000001", "CG5",nRecno }) //STR0001 - "Campo Inconsistente ou Vazio."
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
		TAFAltStat("CG5", '1')
	Else
		TAFAltStat("CG5", '0')
	EndIf
	
Else
	AADD(aLogErro,{"CG5_ID","000017", "CG5", nRecno }) //STR0017 - "Registro jА validado"
	
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁNЦo apresento o alert quando utilizo o JOB para validarЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)