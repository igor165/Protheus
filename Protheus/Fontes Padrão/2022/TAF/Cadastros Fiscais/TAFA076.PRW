#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA076.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA073
Cadastro MVC da Contribuicao do PISPASEP ou da Cofins diferida em periodos anteriores - Valores a pagar no periodo

@author Fabio V. Santana
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA076()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Contribuicao do PISPASEP ou da Cofins diferida em periodos anteriores - Valores a pagar no periodo
oBrw:SetAlias( 'C4E')
oBrw:SetMenuDef( 'TAFA076' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf076Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA076" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC4E 	:= 	FWFormStruct( 1, 'C4E' )
Local oModel		:=	MPFormModel():New( 'TAFA076' ,,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C4E', /*cOwner*/, oStruC4E)

oModel:GetModel( "MODEL_C4E" ):SetPrimaryKey( { "DTOS(C4E_DTMOV)" , "C4E_TPTRIB" ,"C4E_CODCON", "C4E_NATCRD", "DTOS(C4E_DTRECE)" } )                                                                                    
                                                                                                                                                                     
Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA076' )
Local 	oStruC4E 	:= 	FWFormStruct( 2, 'C4E' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C4E', oStruC4E, 'MODEL_C4E' )

oView:EnableTitleView( 'VIEW_C4E', STR0001 ) //Contribuicao do PISPASEP ou da Cofins diferida em periodos anteriores - Valores a pagar no periodo
oView:CreateHorizontalBox( 'FIELDSC4E', 100 )
oView:SetOwnerView( 'VIEW_C4E', 'FIELDSC4E' )

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
		TAFAltStat( "C4E", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF076Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF076Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""
Local cChave   := ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C4E->( Recno() )

If C4E->C4E_STATUS $ ( " |1" )

	If Empty(C4E->C4E_DTMOV)
		AADD(aLogErro,{"C4E_DTMOV","000010", "C4E",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4E->C4E_TPTRIB)
		AADD(aLogErro,{"C4E_TPTRIB","000010", "C4E",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4E->C4E_CODCON)
		AADD(aLogErro,{"C4E_CODCON","000010", "C4E",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4E->C4E_NATCRD)
		AADD(aLogErro,{"C4E_NATCRD","000010", "C4E",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4E->C4E_DTRECE)
		AADD(aLogErro,{"C4E_DTRECE","000010", "C4E",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty(C4E->C4E_VCONTR)
		AADD(aLogErro,{"C4E_VCONTR","000010", "C4E",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4E->C4E_VCONAN)
		AADD(aLogErro,{"C4E_VCONAN","000010", "C4E",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty(C4E->C4E_PERAPU)
		AADD(aLogErro,{"C4E_PERAPU","000010", "C4E",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If !Empty(C4E->C4E_CODCON)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4E->C4E_CODCON
		xValRegTab("C1C",cChave,3,,@aLogErro,, { "C4E", "C4E_CODCON", nRecno } )
	EndIf	

	If !Empty(C4E->C4E_NATCRD)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4E->C4E_NATCRD
		xValRegTab("C0V",cChave,3,,@aLogErro,,  { "C4E", "C4E_NATCRD", nRecno } )
	EndIf	

	If !C4E->C4E_TPTRIB $ ('1|2')
		AADD(aLogErro,{"C4E_TPTRIB","000006", "C4E",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
	EndIf	

	If !Empty(C4E->C4E_VCONTR) .And. !Empty(C4E->C4E_VCRDDI)
		If !(C4E->C4E_VCONAN == (C4E->C4E_VCONTR - C4E->C4E_VCRDDI))
			AADD(aLogErro,{"C4E_VCONAN","000539", "C4E",nRecno }) //STR0539 - "O valor deve corresponder à subtração de 'Contrib. Apur.' menos 'Crd. Descont.'."
		EndIf   
	EndIf	

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C4E", cStatus )

Else
	AADD(aLogErro,{"C4E_ID","000305","C4E",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)