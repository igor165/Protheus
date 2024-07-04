#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE  "TAFA056.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA056
STR0001 "Cadastro de Fatores de Conversão de Unidade de Medida"
STR0002 "Cadastro das Unidades de Medidas"
 
@author Marcio Nunes
@since 23/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA056
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription(STR0001)
oBrw:SetAlias('C1K')
oBrw:SetMenuDef( 'TAFA056' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Denis R de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf056Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA056" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC1K 	:= 	FWFormStruct( 1, 'C1K' )
Local oStruC6X 	:= 	FWFormStruct( 1, 'C6X' )
Local 	oModel 	 := MPFormModel():New( 'TAFA056' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields( 'MODEL_C1K' , /*cOwner*/ , oStruC1K )

oModel:AddGrid ( 'MODEL_C6X' , 'MODEL_C1K' , oStruC6X )
oModel:GetModel( 'MODEL_C6X' ):SetUniqueLine( { 'C6X_UNCONV'} )

oModel:SetRelation( 'MODEL_C6X', { { 'C6X_FILIAL', 'xFilial( "C6X" )' }, { 'C6X_ID', 'C1K_ID' } }, C6X->( IndexKey( 1 ) ) )
oModel:GetModel( "MODEL_C1K" ):SetPrimaryKey( { "C1K_CODIGO" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Gustavo G. Rueda
@since 07/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 		:= 	FWLoadModel( 'TAFA056' )
Local oStruC1K 	:= 	FWFormStruct( 2, 'C1K' )
Local oStruC6X 	:= 	FWFormStruct( 2, 'C6X' )
Local oView 		:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C1K', oStruC1K, 'MODEL_C1K' )
oView:EnableTitleView( 'VIEW_C1K', STR0002 )

oView:AddGrid ( 'VIEW_C6X', oStruC6X, 'MODEL_C6X' )
oView:EnableTitleView( 'VIEW_C6X', STR0001 )

oView:CreateHorizontalBox( 'FIELDSC1K', 40 )
oView:CreateHorizontalBox( 'GRIDC6X', 60 )
oView:SetOwnerView( 'VIEW_C1K', 'FIELDSC1K' )
oView:SetOwnerView( 'VIEW_C6X', 'GRIDC6X' )

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
		//Funcao responsavel por setar o Status do registro para Branco³
		TAFAltStat( "C1K", " " )		
	EndIf
	FwFormCommit( oModel )
End Transaction
       
Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf026Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF056Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {}

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C1K->( Recno() )

If C1K->C1K_STATUS $ ( " |1" )
	
	//Código da unidade de medida PADRÃO do estoque
	If !Empty(C1K->C1K_CODIGO)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C1K->C1K_CODIGO
		xValRegTab("C1J",cChave,3,,@aLogErro, , { "C1K", "C1K_CODIGO", nRecno } )
	EndIf
	
	//Valida a Grid Cadastro de Fatores de Coonversão de Unidade de Medida - UM Conversao / Fat Conv 
	dbSelectArea("C6X")
	C6X->(dbSetORder(1))
	If C6X->(MsSeek(xFilial("C6X") + C1K->C1K_ID))
		cId:=C6X->C6X_ID
		While (!C6X->(Eof()) .And. cId==C6X->C6X_ID)
			
			//Unidade de Conversao
			If Empty(C6X->C6X_UNCONV)
				Aadd( aLogErro, { "C6X_UNCONV","000010","C1K", nRecno } ) //000010 - Campo Inconsistente ou Vazio
		
			Else
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C6X->C6X_UNCONV
				xValRegTab("C1J",cChave,3,,@aLogErro,, { "C1K", "C6X_UNCONV", nRecno } )
			EndIf
			
			//Fator Conversao
			If !(C6X->C6X_FATCON > 0) .Or. Empty(C6X->C6X_FATCON)
				AADD(aLogErro,{"C6X_FATCON","000520","C1K", nRecno }) //STR0520 - "O valor informado no campo deve ser maior que “0” (zero)."
			EndIF
			
			//Unidade de Medida e Unidade de Conversao
			If Alltrim(C6X->C6X_UNCONV) == Alltrim(C1K->C1K_CODIGO)
				AADD(aLogErro,{"C6X_UNCONV","000521","C1K", nRecno }) //STR0521 - "O valor informado no campo unidade de conversao deve existir no campo unidade de medida"				
			EndIF
			
			C6X->(dbSkip())

		Enddo
	Endif
	
	//Atualizo o Registro
	If Len(aLogErro)>0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C1K",.F.)
			C1K->C1K_STATUS := "1"
		C1K->( MsUnlock() )
	Else
		RecLock("C1K",.F.)
			C1K->C1K_STATUS := "0"
		C1K->( MsUnlock() )
	EndIf
Else
	AADD(aLogErro,{"C1K_ID","000305", "C1K", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
	