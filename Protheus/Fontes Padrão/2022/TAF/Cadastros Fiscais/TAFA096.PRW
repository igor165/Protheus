#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA096.CH"                                        

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA096
Cadastro MVC - Controle de Produção Diária da Usina

@author Rodrigo Aguilar
@since 30/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA096
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Controle de Produção Diária da Usina"
oBrw:SetAlias( 'C6N' )
oBrw:SetMenuDef( 'TAFA096' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu                                                                                        

@author Rodrigo Aguilar
@since 30/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf096Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA096" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 30/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()             
Local oStruC6N	:= FWFormStruct( 1, 'C6N' )

Local oModel		:= MPFormModel():New( 'TAFA096' ,,,{|oModel| SaveModel(oModel)} )
      
oModel:AddFields( 'MODEL_C6N', /*cOwner*/, oStruC6N )     
oModel:GetModel( "MODEL_C6N" ):SetPrimaryKey( { "C6N_CODPRO", "C6N_DTPRD" } )                                                                                                                         

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 30/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA096' )
Local oStruC6N 	:= 	FWFormStruct( 2, 'C6N' ) //"Contr.Prod.Diaria da Usina"

Local oView 	:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C6N', oStruC6N, 'MODEL_C6N' )
oView:EnableTitleView( 'VIEW_C6N', STR0001 ) //"Controle de Produção Diária da Usina"

oView:CreateHorizontalBox( 'FIELDSC6N', 100 )          

oView:SetOwnerView( 'VIEW_C6N', 'FIELDSC6N' )

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
		TAFAltStat( "C6N", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF096Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF096Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""
Local cChave   := ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C6N->( Recno() )

If C6N->C6N_STATUS $ ( " |1" )

	If Empty(C6N->C6N_PERIOD)
		AADD(aLogErro,{"C6N_PERIOD","000010", "C6N",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C6N->C6N_CODPRO)
		AADD(aLogErro,{"C6N_CODPRO","000010", "C6N",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C6N->C6N_DTPRD)
		AADD(aLogErro,{"C6N_DTPRD","000010", "C6N",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf
	
	If !C6N->C6N_CODPRO $ ('01|02|03')
		AADD(aLogErro,{"C6N_CODPRO","000006", "C6N",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
	EndIf	
	

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C6N", cStatus )

Else
	AADD(aLogErro,{"C6N_ID","000305","C6N",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar³
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)