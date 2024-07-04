#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA187.CH"                     

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA187
Cadastro MVC - Cadastro de Codigos Totalizadores Reducao Z  

@author Rodrigo Aguilar
@since 28/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA187
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Codigos Totalizadores de Reducao Z"
oBrw:SetAlias( 'C6D' )
oBrw:SetMenuDef( 'TAFA187' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu                                                                                        

@author Rodrigo Aguilar
@since 28/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf187Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA187" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 28/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()             
Local oStruC6D	:= FWFormStruct( 1, 'C6D' )

Local oModel		:= MPFormModel():New( 'TAFA187' ,,,{|oModel| SaveModel(oModel)} )
      
oModel:AddFields( 'MODEL_C6D', /*cOwner*/, oStruC6D )  
oModel:GetModel( "MODEL_C6D" ):SetPrimaryKey( { "C6D_CODIGO" } )                                                                                                                          

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 28/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA187' )
Local oStruC6D 	:= 	FWFormStruct( 2, 'C6D' ) //"Equipamentos de ECF"

Local oView 	:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C6D', oStruC6D, 'MODEL_C6D' )
oView:EnableTitleView( 'VIEW_C6D', STR0001 ) //"Codigos Totalizadores de Reducao Z"

oView:CreateHorizontalBox( 'FIELDSC6D', 100 )          

oView:SetOwnerView( 'VIEW_C6D', 'FIELDSC6D' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "C6D", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF187Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF187Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""

Default lJob := .F. 

If C6D->C6D_STATUS $ ( " |1" )

	If Empty(C6D->C6D_CODIGO)
		AADD(aLogErro,{"C6D_CODIGO","000010", "C6D",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C6D", cStatus )

Else
	AADD(aLogErro,{"C6D_ID","000305","C6D",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)