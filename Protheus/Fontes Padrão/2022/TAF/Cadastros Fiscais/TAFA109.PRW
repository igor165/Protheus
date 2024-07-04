#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA109.CH" 

STATIC aCmpsAlts	:=	{}

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA109
Cadastro MVC dos Modelos de Documentos Fiscais 

@author Fabio V. Santana
@since 14/11/2012
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA109()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Cadastro dos Modelos de Documentos Fiscais"
oBrw:SetAlias( 'C6Y' )
oBrw:SetMenuDef( 'TAFA109' )
oBrw:SetCacheView(.F.)
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

Aadd( aFuncao, { "" , "Taf109Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA109" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 14/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC6Y 	:= 	FWFormStruct( 1, 'C6Y' )
Local oModel    :=  MpFormModel():New("TAFA109",,{ |oModel| ValidModel( oModel ) } ,{|oModel| SaveModel(oModel)})

aCmpsAlts	:=	{}

oModel:AddFields('MODEL_C6Y', /*cOwner*/, oStruC6Y)       

oModel:GetModel( "MODEL_C6Y" ):SetPrimaryKey( { "C6Y_CODIGO", "C6Y_ESTOQ" } )                                                                                                                                

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 14/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA109' )
Local 	oStruC6Y 	:= 	FWFormStruct( 2, 'C6Y' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C6Y', oStruC6Y, 'MODEL_C6Y' )

oView:EnableTitleView( 'VIEW_C6Y', STR0001 )	//"Saldo em Estoque por Produto"
oView:CreateHorizontalBox( 'FIELDSC6Y', 100 )
oView:SetOwnerView( 'VIEW_C6Y', 'FIELDSC6Y' )

If TamSX3("C6Y_CODIGO")[1] == 36
	oStruC6Y:RemoveField("C6Y_CODIGO")
	oStruC6Y:SetProperty("C6Y_ITEM", 	MVC_VIEW_ORDEM, "03")
EndIf
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
		TAFAltStat( "C6Y", " " )	
	EndIf
	FwFormCommit( oModel )
End Transaction
       

Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF109Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF109Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {}

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C6Y->( Recno() )

If C6Y->C6Y_STATUS $ ( " |1" )
		
	//Codigo do Produto        
	If Empty(C6Y->C6Y_CODIGO)
		aAdd(aLogErro,{"C6Y_CODIGO","000010","C6Y",nRecno}) 	//"Campo Inconsistente ou Vazio" 
	Else
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C6Y->C6Y_CODIGO
		xValRegTab("C1L",cChave,3,,@aLogErro,, { "C6Y", "C6Y_CODIGO", nRecno } )
	EndIf
	
	//Identificacao de Mercadoria    
	If Empty(C6Y->C6Y_ESTOQ)
		aAdd(aLogErro,{"C6Y_ESTOQ","000010","C6Y",nRecno}) 	//"Campo Inconsistente ou Vazio"      
	ElseIf !(C6Y->C6Y_ESTOQ  $ ("1|2|3"))
		AADD(aLogErro,{"C6Y_ESTOQ","000006","C6Y", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
	EndIF
	
	If Empty(C6Y->C6Y_QTDEST)
		aAdd(aLogErro,{"C6Y_QTDEST","000010","C6Y",nRecno}) 	//"Campo Inconsistente ou Vazio" 
	EndIf

	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C6Y",.F.)
			C6Y->C6Y_STATUS := "1"
		C6Y->( MsUnlock() )
	Else
		RecLock("C6Y",.F.)
			C6Y->C6Y_STATUS := "0"
		C6Y->( MsUnlock() )
	EndIf
	
Else
	AADD(aLogErro,{"C6Y_ID","000305", "C6Y", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados	
EndIf

//Não apresento o alert quando utilizo o JOB para validar³
If !lJob
	xValLogEr(aLogErro)
EndIf


Return(aLogErro)
	
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao de valida da inclusao dos dados, chamada no final, no momento da gravacao do modelo

@param  oModel -> Modelo de dados
@return .T. ou  .F.

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )
Local 	nOperation 	:= 	oModel:GetOperation()
Return XFUNReflex( nOperation , aCmpsAlts , 'TAFA109' )
//-------------------------------------------------------------------
/*/{Protheus.doc} A109LogAlt
Funcao utilizada para atualizar uma variavel STATIC tratada no SAVE no modelo.
	Tratamento passado por framework para podermos identificar os campos alterados
	no modelo para podermos exibir alguns alertas.

@param  Nil

@return Sempre .T.
                
@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function A109LogAlt()

If ValType( aCmpsAlts ) == "A" .And. aScan( aCmpsAlts , ReadVar() ) == 0
	aAdd( aCmpsAlts , ReadVar() )
EndIf

Return .T.