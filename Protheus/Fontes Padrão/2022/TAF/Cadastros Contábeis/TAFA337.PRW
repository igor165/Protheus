#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA337.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA337
COMERCIO ELETRтNICO

@author Roger Cangianeli
@since 20/05/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA337()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 )
oBrw:SetAlias('CG0')
oBrw:SetMenuDef( 'TAFA337' )
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

Aadd( aFuncao, { "" , "Taf337Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA337" , , aFuncao )

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
Local oStruCG0 	:= 	FWFormStruct( 1, 'CG0' )
Local 	oModel 	:= MPFormModel():New( 'TAFA337' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_CG0', /*cOwner*/, oStruCG0)
oModel:GetModel( 'MODEL_CG0' ):SetPrimaryKey( { "CG0_PERIOD", "CG0_PAIS" } )

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA337' )
Local 	oStruCG0 	:= 	FWFormStruct( 2, 'CG0' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CG0', oStruCG0, 'MODEL_CG0' )

oView:EnableTitleView( 'VIEW_CG0', STR0001 ) //COMERCIO ELETRтNICO
oView:CreateHorizontalBox( 'FIELDSCG0', 100 )
oView:SetOwnerView( 'VIEW_CG0', 'FIELDSCG0' )

oStruCG0:RemoveField('CG0_ID')

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
		TAFAltStat( "CG0", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf337Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacУes caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function Taf337Vld(cAlias,nRecno,nOpc,lJob) 

Local aLogErro	:= {}
Local cBenFis	:= ''
Local cIndPro	:= ''

If (CG0->CG0_STATUS $ (' 1'))
	
	//Valida o Periodo
	If Empty(CG0->CG0_PERIOD)
		Aadd( aLogErro, { "CG0_PERIOD", "000003", "CG0", nRecno } ) //STR0003 - "Data Inconsistente ou Vazia."	
	EndIf

	//Valida o Pais
	If !Empty(CG0->CG0_PAIS)
		cChave := CG0->CG0_PAIS
		xValRegTab("C08",cChave,3,,@aLogErro,)
	Else
		AADD(aLogErro,{"CG0_PAIS","000001", "CG0",nRecno }) //STR0001 - "Campo Inconsistente ou Vazio."
	EndIf	

	//Valida o Homepage Disponivel
	If Empty(CG0->CG0_HOMEDI)
		Aadd( aLogErro, { "CG0_HOMEDI", "000001", "CG0", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."	
	Else
		If !CG0->CG0_HOMEDI $ '1|2'
			Aadd( aLogErro, { "CG0_HOMEDI", "000002", "CG0", nRecno } ) //STR0002 - "ConteЗdo do campo nЦo condiz com as opГУes possМveis."
		EndIf
	EndIf

	//Valida o Servidor DisponМvel
	If Empty(CG0->CG0_SERVDI)
		Aadd( aLogErro, { "CG0_SERVDI", "000001", "CG0", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."
	Else
		If !CG0->CG0_SERVDI $ '1|2'
			Aadd( aLogErro, { "CG0_SERVDI", "000002", "CG0", nRecno } ) //STR0002 - "ConteЗdo do campo nЦo condiz com as opГУes possМveis."
		EndIf
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
		TAFAltStat("CG0", '1')
	Else
		TAFAltStat("CG0", '0')
	EndIf
	
Else
	AADD(aLogErro,{"CG0_ID","000017", "CG0", nRecno }) //000017 - "Registro jА validado"
	
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁNЦo apresento o alert quando utilizo o JOB para validarЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)