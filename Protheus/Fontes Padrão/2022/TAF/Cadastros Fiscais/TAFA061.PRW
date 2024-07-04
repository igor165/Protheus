#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "TAFA061.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA061
Cadastro MVC de Centro de Custos

@author Fabio V. Santana
@since 22/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA061()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro de Centro de Custos
oBrw:SetAlias( 'C1P')
oBrw:SetMenuDef( 'TAFA061' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 22/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf061Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA061" , , aFuncao)

Return( aRotina )      

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 22/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC1P 	:= 	FWFormStruct( 1, 'C1P' )
Local oModel		:= MPFormModel():New( 'TAFA061' ,,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C1P', /*cOwner*/, oStruC1P)  
oModel:GetModel( "MODEL_C1P" ):SetPrimaryKey( { "C1P_CODCUS", "C1P_DTALT" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 22/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA061' )
Local 	oStruC1P 	:= 	FWFormStruct( 2, 'C1P' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C1P', oStruC1P, 'MODEL_C1P' )

oView:EnableTitleView( 'VIEW_C1P', STR0001 ) //Cadastro de Centro de Custos
oView:CreateHorizontalBox( 'FIELDSC1P', 100 )
oView:SetOwnerView( 'VIEW_C1P', 'FIELDSC1P' )

Return oView	

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Anderson Costa
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()

Begin Transaction 

	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "C1P", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF061Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 17/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF061Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C1P->( Recno() ) 

If C1P->C1P_STATUS $ ( " |1" )

	/*+------------------------------------------------------+
	  | Data:27.08.2014	     	                 				 |
	  | Responsável: Evandro dos Santos Oliveira             |
	  | Descrição da Alteração: Inclusão das validações para |
	  | os campos obrigatórios	 						   	 	 |
	  +------------------------------------------------------+*/ 	
	If Empty(C1P->C1P_CODCUS)
		aAdd(aLogErro,{"C1P_CODCUS","000010","C1P",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C1P->C1P_CCUS)
		aAdd(aLogErro,{"C1P_CCUS"  ,"000010","C1P",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C1P->C1P_DTALT)
		aAdd(aLogErro,{"C1P_DTALT","000010","C1P",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C1P", cStatus )

Else
	AADD(aLogErro,{"C1P_ID","000305","C1P",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)