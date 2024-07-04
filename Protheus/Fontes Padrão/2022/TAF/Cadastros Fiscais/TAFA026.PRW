#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA026.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA026
Cadastro de Veículos

@author Marcio Nunes
@since 10/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA026()

Local oBrw :=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Veículos
oBrw:SetAlias( 'C0Q' )
oBrw:SetMenuDef( 'TAFA026' )
oBrw:SetCacheView( .F. )
oBrw:Activate()  

Return ( Nil )

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

Aadd( aFuncao, { "" , "Taf026Vld" , "2" } )

aRotina :=	xFunMnuTAF( "TAFA026" , , aFuncao )

Return ( aRotina )

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

Local oStruC0Q 	:= 	FWFormStruct( 1, 'C0Q' )
Local 	oModel 	:= MPFormModel():New( 'TAFA026' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_C0Q', /*cOwner*/, oStruC0Q)
oModel:GetModel( 'MODEL_C0Q' ):SetPrimaryKey( { "C0Q_CODIGO" } )

Return ( oModel )

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

Local 	oModel 	:= 	FWLoadModel( 'TAFA026' )
Local 	oStruC0Q 	:= 	FWFormStruct( 2, 'C0Q' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0Q', oStruC0Q, 'MODEL_C0Q' )

oView:EnableTitleView( 'VIEW_C0Q', STR0001 ) //Cadastro de Veículos
oView:CreateHorizontalBox( 'FIELDSC0Q', 100 )
oView:SetOwnerView( 'VIEW_C0Q', 'FIELDSC0Q' )

Return ( oView )   

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
		TAFAltStat( "C0Q", " " )		
	EndIf
	FwFormCommit( oModel )
        
End Transaction     

Return ( .T. )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf026Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function Taf026Vld( cAlias, nRecno, nOpc, lJob ) 

Local cChave 	 := ""
Local aLogErro := {}

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C0Q->( Recno() )

//Verifico se o Status eh passível de validação
If ( C0Q->C0Q_STATUS $ (' 1') )
	
	//Valida o Codigo
	If Empty( C0Q->C0Q_CODIGO )
		Aadd( aLogErro, { "C0Q_CODIGO", "000010", "C0Q", nRecno } ) //000010 - Campo Inconsistente ou Vazio	
	EndIf
	
	//Valida a Placa
	If Empty( C0Q->C0Q_PLACA )
		Aadd( aLogErro, { "C0Q_PLACA", "000010", "C0Q", nRecno } ) //000010 - Campo Inconsistente ou Vazio	
	EndIf
	
	//Valida o UF Placa
	If Empty( C0Q->C0Q_UF ) 
		Aadd( aLogErro, { "C0Q_UF", "000010", "C0Q", nRecno } ) //000010 - Campo Inconsistente ou Vazio	
	Else
	
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C0Q->C0Q_UF
		xValRegTab( "C09", cChave, 3, , @aLogErro, , { "C0Q", "C0Q_UF", nRecno } )
	EndIf
	
	//Valida o Munic. de licenc do veiculo
	If Empty( C0Q->C0Q_CODMUN )
		Aadd( aLogErro, { "C0Q_CODMUN", "000010", "C0Q", nRecno } ) //000010 - Campo Inconsistente ou Vazio	
	Else
	
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C0Q->C0Q_CODMUN
		xValRegTab( "C07", cChave, 3, , @aLogErro, ,{ "C0Q", "C0Q_CODMUN", nRecno } )
	EndIf  
	
	//Valida a Descrição
	If Empty( C0Q->C0Q_DESCRI )
		Aadd( aLogErro, { "C0Q_DESCRI", "000010", "C0Q", nRecno } ) //000010 - Campo Inconsistente ou Vazio	
	EndIf
	
	//Valida o Chassi
	If Empty( C0Q->C0Q_CHASSI )
		Aadd( aLogErro, { "C0Q_CHASSI", "000010", "C0Q", nRecno } ) //000010 - Campo Inconsistente ou Vazio	
	EndIf
	
	//Valida o Tipo do Veiculo
	If !Empty( C0Q->C0Q_TPVEIC )
		If !( C0Q->C0Q_TPVEIC $ ("0|1") )
			Aadd( aLogErro, { "C0Q_TPVEIC", "000006", "C0Q", nRecno } ) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
		EndIf
	EndIF
	
	//Valida o Tipo de Navegacao
	If !Empty( C0Q->C0Q_TPNAV ) 
		If !( C0Q->C0Q_TPNAV $ ("0|1") )
			Aadd( aLogErro,{ "C0Q_TPNAV", "000006", "C0Q", nRecno } ) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
		EndIf
	EndIF
	
	//Atualizo o Status do Registro  
	If Len( aLogErro ) > 0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos Usados
		RecLock( "C0Q", .F. )
			C0Q->C0Q_STATUS := "1"
		C0Q->( MsUnlock() )
	Else		
		RecLock( "C0Q", .F. )
			C0Q->C0Q_STATUS := "0"
		C0Q->( MsUnlock() )
	EndIf
	
Else
	Aadd( aLogErro, { "C0Q_ID", "000305", "C0Q", nRecno } ) //"Registros que já foram transmitidos ao Fisco, não podem ser validados."	
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr( aLogErro )
EndIf

Return( aLogErro )
