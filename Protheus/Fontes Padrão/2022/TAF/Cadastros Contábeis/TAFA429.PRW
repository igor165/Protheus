#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA429.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA429
Cadastro MVC de Contabilistas 

@author Erick G Dias
@since 03/03/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA429()
Local	oBrw	:= FWmBrowse():New()

If AliasIndic("T0M")
	oBrw:SetDescription( STR0001 )	//"Demonstrativo do Livro Caixa"
	oBrw:SetAlias( 'T0M')
	oBrw:SetMenuDef( 'TAFA429' )
	oBrw:Activate()
Else
	Alert(STR0002)//Tabela T0M não existe.
EndIF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Erick G Dias
@since 03/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf429Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA429" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Erick G Dias
@since 03/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT0M 	:= 	FWFormStruct( 1, 'T0M' )
Local oModel  	:= MPFormModel():New( 'TAFA429' , , , {|oModel| SaveModel( oModel ) } )
 
oModel:AddFields('MODEL_T0M', /*cOwner*/, oStruT0M) 
oModel:GetModel('MODEL_T0M'):SetPrimaryKey( {'T0M_DATA','T0M_NUM_DOC','T0M_HIST'} ) 

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Erick G Dias
@since 03/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA429' )
Local oStruT0M 	:= 	FWFormStruct( 2, 'T0M' )
Local oView 		:= 	FWFormView():New()

oStruT0M:RemoveField('T0M_ID') //Remove o campo da view

oView:SetModel( oModel )
oView:AddField( 'VIEW_T0M', oStruT0M, 'MODEL_T0M' )

oView:EnableTitleView( 'VIEW_T0M', STR0001 )	//"Demonstrativo do Livro Caixa"
oView:CreateHorizontalBox( 'FIELDST0M', 100 )
oView:SetOwnerView( 'VIEW_T0M', 'FIELDST0M' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Erick G Dias
@since 03/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		//Funcao responsavel por setar o Status do registro para Branco
		TAFAltStat( "T0M", " " )		
	EndIf
	FwFormCommit( oModel )
        
End Transaction
       
Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf429Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Erick G Dias
@since 03/03/2016
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF429Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {} 
Local lVldEnt		:= .F. 
Local lVldSai		:= .F.
Default lJob 		:= .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := T0M->( Recno() )

If T0M->T0M_STATUS $ ( " |1" )
	
	//Valida a Data
	If Empty(T0M->T0M_DATA)
		Aadd( aLogErro, {"T0M_DATA", "000001", "T0M", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o Histórico
	If Empty(T0M->T0M_HIST)		
		Aadd( aLogErro, {"T0M_HIST", "000001", "T0M", nRecno }) //STR0001 - Campo Inconsistente ou Vazio		
	EndIf 
	
	//Valida o Saldo Final
	If Empty(T0M->T0M_SLDFIN)
		Aadd( aLogErro, {"T0M_SLDFIN", "000001", "T0M", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
	EndIf	
	
	lVldEnt	:= T0M->T0M_VLENT > 0 
	lVldSai	:= T0M->T0M_VLSAI > 0	
	
	//Validação REGRA_ENTRADA_SAIDA
	If lVldEnt .AND. lVldSai
		Aadd( aLogErro, {"T0M_VLENT", "000248", "T0M", nRecno }) //Somente o valor de entrada ou de saída deverá estar preenchido	
		Aadd( aLogErro, {"T0M_VLSAI", "000248", "T0M", nRecno }) //Somente o valor de entrada ou de saída deverá estar preenchido		
	EndIF	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aLogErro)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("T0M",.F.)
			T0M->T0M_STATUS := "1"
		T0M->( MsUnlock() )
	Else
		RecLock("T0M",.F.)
			T0M->T0M_STATUS := "0"
		T0M->( MsUnlock() )
	EndIf
	
Else
	AADD(aLogErro,{"T0M_ID","000017", "T0M", nRecno })//Registros já validado
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)