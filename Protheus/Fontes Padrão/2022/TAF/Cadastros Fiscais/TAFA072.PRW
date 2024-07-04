#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA072.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA072
Cadastro MVC - Deducoes Diversas

@author Rodrigo Aguilar
@since 09/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA072
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Deducoes Diversas"
oBrw:SetAlias( 'C4Q' )
oBrw:SetMenuDef( 'TAFA072' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu                                                                                        

@author Rodrigo Aguilar
@since 09/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf072Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA072" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 09/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()             

Local oStruC4Q	:= FWFormStruct( 1, 'C4Q' )
Local oModel		:= MPFormModel():New( 'TAFA072' ,,,{|oModel| SaveModel(oModel)} )
      
oModel:AddFields( 'MODEL_C4Q', /*cOwner*/, oStruC4Q )   
oModel:GetModel( "MODEL_C4Q" ):SetPrimaryKey( { "C4Q_PERIOD", "C4Q_IDORDE", "C4Q_IDNTOP", "C4Q_CNPJ" } )                                                                                                       

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 09/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA072' )
Local oStruC4Q 	:= 	FWFormStruct( 2, 'C4Q' ) //"Deducoes Diversas"    

Local oView 	:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C4Q', oStruC4Q, 'MODEL_C4Q' )

oView:CreateHorizontalBox( 'FIELDSC4Q', 100 )          

oView:SetOwnerView( 'VIEW_C4Q', 'FIELDSC4Q' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Anderson Costa
@since 19/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "C4Q", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF072Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 19/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF072Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C4Q->( Recno() )

If C4Q->C4Q_STATUS $ ( " |1" )

	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(C4Q->C4Q_PERIOD)
		AADD(aLogErro,{"C4Q_PERIOD","000010", "C4Q",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4Q->C4Q_IDORDE)
		AADD(aLogErro,{"C4Q_IDORDE","000010", "C4Q",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4Q->C4Q_IDNTOP)
		AADD(aLogErro,{"C4Q_IDNTOP","000010", "C4Q",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	Else
		If !C4Q->C4Q_IDNTOP $ ('0|1')
			AADD(aLogErro,{"C4Q_IDNTOP","000006", "C4Q",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
		EndIf	
	EndIf

	If Empty(C4Q->C4Q_VLDPIS)
		AADD(aLogErro,{"C4Q_VLDPIS","000010", "C4Q",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4Q->C4Q_VLDCOF)
		AADD(aLogErro,{"C4Q_VLDCOF","000010", "C4Q",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4Q->C4Q_VLBCOP)
		AADD(aLogErro,{"C4Q_VLBCOP","000010", "C4Q",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	//------------------
	// Consultas padrão
	//------------------
	If !Empty(C4Q->C4Q_IDORDE)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4Q->C4Q_IDORDE
		xValRegTab("C1S",cChave,3,,@aLogErro,, { "C4Q", "C4Q_IDORDE", nRecno } )
	EndIf	


	//--------------------
	// Regras específicas
	//--------------------
	//Valido o campo de CNPJ, passando o terceiro parametro da funcao CGC como .F.
	//Para que nao seja apresentado o alert de validacao                          
	If !Empty(C4Q->C4Q_CNPJ)
		If !CGC(C4Q->C4Q_CNPJ,,.F.)
			AADD(aLogErro,{"C4Q_CNPJ", "000005", "C4Q", nRecno }) //STR0005 - "CPF/CNPJ Inconsistente"
		EndIf
	EndIf

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C4Q", cStatus )

Else
	AADD(aLogErro,{"C4Q_ID","000305","C4Q",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)