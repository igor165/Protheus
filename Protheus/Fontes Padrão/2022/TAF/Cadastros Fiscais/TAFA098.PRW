#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                          
#INCLUDE "TAFA098.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA098
Cadastro MVC de Consolidacao da Contribuicao Previdenciaria sobre a receita bruta
e Ajustes da Contribuicao Previdenciaria sobre a receita bruta

@author Danilo L Zanaga 
@since 22/08/2012       
@version 1.0 

@author Demetrio Fontes De Los Rios
@since  11/02/2013    
@version 2.0

/*/
//-------------------------------------------------------------------
Function TAFA098()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0002) //Consolidacao da Contribuicao Previdenciaria sobre a receita bruta
oBrw:SetAlias( 'C81')
oBrw:SetMenuDef( 'TAFA098' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Danilo L Zanaga
@since 22/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf098Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA098" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Danilo L Zanaga
@since 22/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()     
Local oStruC81 	:= 	FWFormStruct( 1, 'C81' )
Local oStruC6E 	:= 	FWFormStruct( 1, 'C6E' )

Local oModel		:= MPFormModel():New( 'TAFA098' ,,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C81', /*cOwner*/, oStruC81)
                                                          
oModel:AddGrid('MODEL_C6E', 'MODEL_C81', oStruC6E)
oModel:GetModel( 'MODEL_C6E' ):SetUniqueLine( { 'C6E_INDAJU','C6E_CODAJU','C6E_NUMDOC'} ) 

oModel:SetRelation( 'MODEL_C6E' , { { 'C6E_FILIAL' , 'xFilial( "C6E" )' } , { 'C6E_ID' , 'C81_ID' } } , C6E->( IndexKey( 4 ) ) )
oModel:GetModel( 'MODEL_C6E' ):SetOptional( .T. ) 
                  
oModel:GetModel( "MODEL_C81" ):SetPrimaryKey( { "C81_DTMOV", "C81_CODREC" } )                                                                                              

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Danilo L Zanaga
@since 22/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA098' )  
Local 	oStruC81 	:= 	FWFormStruct( 2, 'C81' )
Local 	oStruC6E 	:= 	FWFormStruct( 2, 'C6E' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C81', oStruC81, 'MODEL_C81' )
oView:EnableTitleView( 'VIEW_C81', STR0002 ) //Consolidacao da Contribuicao Previdenciaria sobre a receita bruta    
      
oView:AddGrid ( 'VIEW_C6E', oStruC6E, 'MODEL_C6E' )  

oView:CreateHorizontalBox( 'FIELDSC81', 30 )          
oView:CreateHorizontalBox( 'FOLDERGERAL', 70 )    

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0001) //Ajustes da Contribuição Previdenciária sobre a receita bruta
oView:CreateHorizontalBox( 'GRIDC6E', 100,,, 'FOLDER1', 'ABA01' )       

oView:SetOwnerView( 'VIEW_C81', 'FIELDSC81' )
oView:SetOwnerView( 'VIEW_C6E', 'GRIDC6E' ) 


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
		TAFAltStat( "C81", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF098Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF098Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""
Local cChave   := ""
Local cC6EKey  := ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C81->( Recno() )

If C81->C81_STATUS $ ( " |1" )

	/*
	If Empty(C81->C81_PERREF)
		AADD(aLogErro,{"C81_PERREF","000010", "C81",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf
	
	
	If Empty(C81->C81_VLRDEV)
		AADD(aLogErro,{"C81_VLRDEV","000010", "C81",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf
	*/
	If Empty(C81->C81_VALTOT)
		AADD(aLogErro,{"C81_VALTOT","000010", "C81",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C81->C81_CODREC)
		AADD(aLogErro,{"C81_CODREC","000010", "C81",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	//INICIO C6E
	dbSelectArea("C6E")
	C6E->(DBSetOrder(4))
	cC6EKey := C81->C81_ID
	
	If C6E->( MsSeek( xFilial("C6E") + cC6EKey ) )

		Do While !C6E->( Eof() ) .And. cC6EKey == C6E->C6E_ID

			If Empty(C6E->C6E_INDAJU)
				AADD(aLogErro,{"C6E_INDAJU","000010", "C81",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C6E->C6E_CODAJU)
				AADD(aLogErro,{"C6E_CODAJU","000010", "C81",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C6E->C6E_VLRAJU)
				AADD(aLogErro,{"C6E_VLRAJU","000010", "C81",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If !Empty(C6E->C6E_CODAJU)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C6E->C6E_CODAJU
				xValRegTab("C1D",cChave,3,,@aLogErro,, { "C81", "C6E_CODAJU", nRecno } )
			EndIf	

			If !C6E->C6E_INDAJU $ ('0|1')
				AADD(aLogErro,{"C6E_INDAJU","000006", "C81",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
			EndIf	

			C6E->( DbSkip() )
		EndDo
	EndIf
	//FIM C6E
	
	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C81", cStatus )

Else
	AADD(aLogErro,{"C81_ID","000305","C81",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)