#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA029.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA029
Cadastro de AIDF (Autorização de Impressão de Documentos Fiscais)

@author Marcio Nunes
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA029()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de AIDF (Autorização de Impressão de Documentos Fiscais)
oBrw:SetAlias( 'C0T' )
oBrw:SetMenuDef( 'TAFA029' )
oBrw:Activate()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf029Vld" , "2" } )
aRotina :=	xFunMnuTAF( "TAFA029" , , aFuncao )

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruC0T 	:= 	FWFormStruct( 1, 'C0T' )
Local oStruC6V 	:= 	FWFormStruct( 1, 'C6V' )
Local 	oModel 	:= MPFormModel():New( 'TAFA029' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_C0T', /*cOwner*/, oStruC0T)
oModel:AddGrid('MODEL_C6V', 'MODEL_C0T' , oStruC6V)

oModel:SetRelation( 'MODEL_C6V', { { 'C6V_FILIAL', 'xFilial( "C6V" )' } , { 'C6V_ID' , "C0T_ID" } }, C6V->( IndexKey( 1 ) ) )
oModel:GetModel( "MODEL_C0T" ):SetPrimaryKey( { "C0T_CODISP", "C0T_NUNAUT" } )

oModel:GetModel( 'MODEL_C6V' ):SetUniqueLine( { 'C6V_CODMOD', 'C6V_SERDIS', 'C6V_NDIINI', 'C6V_NDIFIN' } )

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA029' )
Local 	oStruC0T 	:= 	FWFormStruct( 2, 'C0T' )
Local 	oStruC6V 	:= 	FWFormStruct( 2, 'C6V' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0T', oStruC0T, 'MODEL_C0T' )
oView:EnableTitleView( 'VIEW_C0T', STR0001 ) //Cadastro de AIDF (Autorização de Impressão de Documentos Fiscais)

oView:AddGrid ( 'VIEW_C6V', oStruC6V, 'MODEL_C6V' )
oView:EnableTitleView( 'VIEW_C6V', STR0002 )	//'Documentos Fiscais Autorizados por AIDF'

oView:CreateHorizontalBox( 'FIELDSC0T', 40 )
oView:CreateHorizontalBox( 'GRIDC6V', 60 )
oView:SetOwnerView( 'VIEW_C0T', 'FIELDSC0T' )
oView:SetOwnerView( 'VIEW_C6V', 'GRIDC6V' )

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
		TAFAltStat( "C0T", " " )		
	EndIf

	FwFormCommit( oModel )
End Transaction
       
Return ( .T. )
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf029Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function Taf029Vld( cAlias, nRecno, nOpc, lJob )

Local aLogErro := {}
Local cChave	 := "" 
Local cCodIsp	 := ""
Local cC6VKey	 := ""

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C0T->( Recno() )

If C0T->C0T_STATUS $ ( " |1" )
	
	//Valida o Dispositivo Autorizado
	If Empty(C0T->C0T_CODISP)
		Aadd( aLogErro, { "C0T_CODISP", "000010", "C0T", nRecno } ) //000010 - Campo Inconsistente ou Vazio
	Else
	
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C0T->C0T_CODISP
		xValRegTab( "C6C", cChave, 3, , @aLogErro, , { "C0T", "C0T_CODISP", nRecno } )
		
		cCodIsp:= Alltrim(Posicione("C6C",3,xFilial("C6C")+C0T->C0T_CODISP,"C6C_CODIGO"))
		
		If !(cCodIsp $ ("00|01|02|03|04|05"))
			AADD( aLogErro,{ "C0T_CODISP", "000006", "C0T", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
		EndIf
	EndIf
	
	//Valida o Numero Autorizacao
	If Empty(C0T->C0T_NUNAUT)
		Aadd( aLogErro, { "C0T_NUNAUT", "000010", "C0T", nRecno } ) //000010 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida a Data emissao da AIDF
	If Empty(C0T->C0T_EMISSA)
		Aadd( aLogErro, { "C0T_EMISSA", "000010", "C0T", nRecno } ) //000010 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida a Grid Documentos Fiscais Autorizados por AIDF - Codigo de Modelo 			  
	//Inicio C6V
	C6V->( DBSetOrder(1) )
	
	cC6VKey := C0T->C0T_ID
	If C6V->( MsSeek( xFilial("C6V") + cC6VKey ) )

		Do While !C6V->( Eof() ) .And. cC6VKey == C6V->C6V_ID

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C6V->C6V_CODMOD)
				AADD(aLogErro,{"C6V_CODMOD","000010", "C0T",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C6V->C6V_SERDIS)
				Aadd( aLogErro, { "C6V_SERDIS", "000010", "C0T", nRecno } ) //000010 - Campo Inconsistente ou Vazio
			EndIf
			
			If Empty(C6V->C6V_NDIINI)
				Aadd( aLogErro, { "C6V_NDIINI", "000010", "C0T", nRecno } ) //000010 - Campo Inconsistente ou Vazio
			EndIf
			
			If Empty(C6V->C6V_NDIFIN)
				Aadd( aLogErro, { "C6V_NDIFIN", "000010", "C0T", nRecno } ) //000010 - Campo Inconsistente ou Vazio
			EndIf
			
			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C6V->C6V_CODMOD)
				
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C6V->C6V_CODMOD
				xValRegTab( "C01", cChave, 3,, @aLogErro, , { "C0T", "C6V_CODMOD", nRecno } )
			EndIf	

			C6V->( DbSkip() )
		EndDo
	EndIf
	
	//Atualizo o Status do Registro
	If Len(aLogErro)>0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C0T",.F.)
			C0T->C0T_STATUS := "1"
		C0T->( MsUnlock() )
	Else
		RecLock("C0T",.F.)
			C0T->C0T_STATUS := "0"
		C0T->( MsUnlock() )
	EndIf
	
Else	
	AADD(aLogErro,{"C0T_ID","000305", "C0T", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf

Return( aLogErro ) 
