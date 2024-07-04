#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                                   
#INCLUDE "TAFA092.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA092
Cadastro MVC de Demonstrativo de Crédito sobre Transporte Aéreo - DCTA

@author Danilo L Zanaga
@since 16/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA092()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Demonstrativo de Crédito sobre Transporte Aéreo - DCTA
oBrw:SetAlias('C5H')
oBrw:SetMenuDef( 'TAFA092' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf092Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA092" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Danilo L Zanaga
@since 16/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC5H 	:= 	FWFormStruct( 1, 'C5H' )
Local 	oModel 	:=  MPFormModel():New( 'TAFA092' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_C5H', /*cOwner*/, oStruC5H)    

oModel:GetModel( "MODEL_C5H" ):SetPrimaryKey( { "C5H_PERIOD" } )                                                                                                                                     

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Danilo L Zanaga
@since 16/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA092' )
Local 	oStruC5H 	:= 	FWFormStruct( 2, 'C5H' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C5H', oStruC5H, 'MODEL_C5H' )

oView:EnableTitleView( 'VIEW_C5H', STR0001 ) //Demonstrativo de Crédito sobre Transporte Aéreo - DCTA
oView:CreateHorizontalBox( 'FIELDSC5H', 100 )
oView:SetOwnerView( 'VIEW_C5H', 'FIELDSC5H' )

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
		//Funcao responsavel por setar o Status do registro para Branco
		TAFAltStat( "C5H", " " )	
	EndIf
	FwFormCommit( oModel )
        
End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF092Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF092Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {}

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C5H->( Recno() ) 

If C5H->C5H_STATUS $ ( " |1" )

	/*+------------------------------------------------------+
	  | Data:26.08.2014	     	                 				 |
	  | Responsável: Evandro dos Santos Oliveira             |
	  | Descrição da Alteração: Inclusão das validações para |
	  | os campos obrigatórios	 						   	 	 |
	  +------------------------------------------------------+*/ 	
	If Empty(C5H->C5H_PERIOD)
		aAdd(aLogErro,{"C5H_PERIOD","000010","C5H",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C5H->C5H_VCARGA)
		aAdd(aLogErro,{"C5H_VCARGA","000010","C5H",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C5H->C5H_VLPASS)
		aAdd(aLogErro,{"C5H_VLPASS","000010","C5H",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C5H->C5H_VLFATU)
		aAdd(aLogErro,{"C5H_VLFATU","000010","C5H",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C5H->C5H_INDRAT)
		aAdd(aLogErro,{"C5H_INDRAT","000010","C5H",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf
	
	If Empty(C5H->C5H_VICANT)
		aAdd(aLogErro,{"C5H_VICANT","000010","C5H",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C5H->C5H_VBCICM)
		aAdd(aLogErro,{"C5H_VBCICM","000010","C5H",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C5H->C5H_VICMAP)
		aAdd(aLogErro,{"C5H_VICMAP","000010","C5H",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C5H->C5H_VBICAP)
		aAdd(aLogErro,{"C5H_VBICAP","000010","C5H",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C5H->C5H_VDIFER)
		aAdd(aLogErro,{"C5H_VDIFER","000010","C5H",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	
	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C5H",.F.)
			C5H->C5H_STATUS := "1"
		C5H->( MsUnlock() )
	Else
		RecLock("C5H",.F.)
			C5H->C5H_STATUS := "0"
		C5H->( MsUnlock() )
	EndIf
Else
	AADD(aLogErro,{"C5H_ID","000305", "C5H", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
	