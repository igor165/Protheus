#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                                         
#INCLUDE "TAFA091.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA091
Cadastro MVC de Incorporacao imobiliaria

@author Fabio V Santana
@since 08/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA091
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription(STR0001)//Incorporacao imobiliaria
oBrw:SetAlias( 'C53')
oBrw:SetMenuDef( 'TAFA091' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V Santana
@since 08/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf091Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA091" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V Santana
@since 08/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC53 	:= 	FWFormStruct( 1, 'C53' )
Local oStruC54 	:= 	FWFormStruct( 1, 'C54' )

Local oModel		:= MPFormModel():New( 'TAFA091' ,,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C53', /*cOwner*/, oStruC53)

oModel:AddGrid('MODEL_C54', 'MODEL_C53', oStruC54)
oModel:GetModel( 'MODEL_C54' ):SetUniqueLine({ 'C54_NUMPRO'}) 

oModel:SetRelation( 'MODEL_C54' , { { 'C54_FILIAL' , 'xFilial( "C54" )' } , { 'C54_ID' , 'C53_ID' } } , C54->( IndexKey( 1 ) ) )
oModel:GetModel( 'MODEL_C54' ):SetOptional( .T. )  

oModel:GetModel( "MODEL_C53" ):SetPrimaryKey( { "C53_PERIOD", "C53_INCIMO", "C53_DTREC", "C53_CODREC", "C53_ALQRET" } )
 
Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V Santana
@since 08/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA091' )
Local oStruC53 	:= 	FWFormStruct( 2, 'C53' )
Local oStruC54 	:= 	FWFormStruct( 2, 'C54' )

Local oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C53', oStruC53, 'MODEL_C53' )
oView:EnableTitleView( 'VIEW_C53', STR0001) //Incorporacao imobiliaria

oView:AddGrid ( 'VIEW_C54', oStruC54, 'MODEL_C54' )
oView:EnableTitleView( 'VIEW_C54', STR0002) //Processos Referenciados

oView:CreateHorizontalBox( 'FIELDSC53', 50 )          
oView:CreateHorizontalBox( 'GRIDC54', 50,,,,)

oView:SetOwnerView( 'VIEW_C53', 'FIELDSC53' )
oView:SetOwnerView( 'VIEW_C54', 'GRIDC54' )

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
		TAFAltStat( "C53", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF091Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF091Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""
Local cChave   := ""
Local cC54Key  := ""

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C53->( Recno() ) 

If C53->C53_STATUS $ ( " |1" )

	If Empty(C53->C53_PERIOD)
		AADD(aLogErro,{"C53_PERIOD","000010", "C53",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C53->C53_INCIMO)
		AADD(aLogErro,{"C53_INCIMO","000010", "C53",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If !Empty(C53->C53_RECREC) .And. !Empty(C53->C53_RECFIN)
		If !(C53->C53_BCRET == (C53->C53_RECREC + C53->C53_RECFIN)) 
			AADD(aLogErro,{"C53_BCRET","000551", "C53",nRecno }) //STR0551 - "O valor deve corresponder à soma dos campos 'Rec. Recebida' e 'Rec. Financ.'."
		EndIf
	EndIf 

	//INICIO C54
	C54->( DBSetOrder(1) )
	
	cC54Key := C53->C53_ID
	If C54->( MsSeek( xFilial("C54") + cC54Key ) )

		Do While !C54->( Eof() ) .And. cC54Key == C54->C54_ID

			If Empty(C54->C54_NUMPRO)
				AADD(aLogErro,{"C54_NUMPRO","000010", "C53",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If !Empty(C54->C54_NUMPRO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C54->C54_NUMPRO
				xValRegTab("C1G",cChave,3,,@aLogErro,, { "C53", "C54_NUMPRO", nRecno } )
			EndIf	

			C54->( DbSkip() )
		EndDo
	EndIf
	//FIM C54

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C53", cStatus )

Else
	AADD(aLogErro,{"C53_ID","000305","C53",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)