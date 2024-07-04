#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA860.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA860()
Log de Eventos dos alertas 

@Return 	nil
@author	Serviços
@since 		19/09/2013
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA860()

Local oBrowse

oBrowse := FwMBrowse():New()

oBrowse:SetAlias("TFK")

oBrowse:SetDescription(STR0001) // Log de Eventos
oBrowse:DisableDetails()

oBrowse:Activate()

Return(Nil)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Log de Eventos dos alertas

@Return	MenuDef
@author 	Serviços
@since 		19/09/2013
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw" 			OPERATION 1	ACCESS 0	// "Pesquisar"
	ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TECA860"	OPERATION 2 	ACCESS 0	// "Visualizar"
	
Return(aRotina)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Log de Eventos dos alertas

@Return 	model
@author 	Serviços
@since 		19/09/2013
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel	
Local oStruTFK := FWFormStruct(1,"TFK")
Local oStruTFM := FWFormStruct(1,"TFM")

// Tira a obrigatoriedade do campo para prosseguir com o processo de gravação, 
// a prioridade de consistencia o VALID do campo vem antes da gravação.
oStruTFM:SetProperty("TFM_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
oStruTFM:SetProperty("TFM_CODLOG", MODEL_FIELD_OBRIGAT, .F.)

oModel := MPFormModel():New("TECA860",/* bPreValidacao */,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

oModel:AddFields("TFKMASTER",/*cOwner*/,oStruTFK, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( "TFMDETAIL","TFKMASTER",oStruTFM,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/)
oModel:SetRelation( "TFMDETAIL",{{"TFM_FILIAL","xFilial('TFM')"},{"TFM_CODLOG","TFK_CODIGO"}} ,"TFM_FILIAL+TFM_CODLOG")
oModel:SetDescription(STR0001) // Log de Eventos

Return(oModel)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Log de Eventos dos alertas

@Return 	view
@author 	Serviços
@since 		20/09/2013
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel("TECA860")  
Local oStruTFK := FWFormStruct(2,"TFK")
Local oStruTFM := FWFormStruct(2,"TFM")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_TFK",oStruTFK,"TFKMASTER")
oView:AddGrid( "VIEW_TFM",oStruTFM,"TFMDETAIL")
oView:CreateHorizontalBox("SUPERIOR", 30 )	// 30 = % utilizado da tela
oView:CreateHorizontalBox("INFERIOR", 70 )
oView:SetOwnerView( "VIEW_TFK", "SUPERIOR" )
oView:SetOwnerView( "VIEW_TFM", "INFERIOR" )

Return(oView)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At860GrvCab(aLogEvento)
Log de Eventos dos alertas 

@param		aLogEvento - Matriz com os valores desejados para gravacao do LOG.
@sample	At840GrvCab(aLogEvento)
@Return 	nil
@author 	Serviços
@since 		19/09/2013
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At860GrvCab(aLogEvento, aDesLog)

Local oModel, oModelTFM
Local nI, nJ
Local aArea 		:= GetArea()
local aErro 		:= {}

Default aLogEvento := {}
	
oModel 	:= FWLoadModel( "TECA860" )	// Carregamos o model
oModelTFM 	:= oModel:GetModel( "TFMDETAIL" )

dbSelectArea("TFK")
dbSelectArea("TFM") 
				
If Len(aLogEvento) > 0

	For nI:= 1 To Len(aLogEvento)
		
		If ValType(aLogEvento[nI][4]) <> "C"
			aLogEvento[nI][4] := AllTrim(Str(aLogEvento[nI][4])) 
		EndIf
		
		If ValType(aLogEvento[nI][5]) <> "C"
			aLogEvento[nI][5] := AllTrim(Str(aLogEvento[nI][5])) 
		EndIf			
			
		oModel:SetOperation( 3 )		// 3 = Inclusão		
		oModel:Activate()				// Ativamos o Model
				
		oModel:SetValue( "TFKMASTER", "TFK_CODEVE", 	aLogEvento[nI][1]	)	// Codigo do evento
		oModel:SetValue( "TFKMASTER", "TFK_EXPEVE", 	aLogEvento[nI][2]	)	// Expressao do evento
		oModel:SetValue( "TFKMASTER", "TFK_DATEML", 	Date()				)	// Data do disparo de emails
		oModel:SetValue( "TFKMASTER", "TFK_HOREML", 	Left(Time(),5)	)	// Hora do disparo de emails
		oModel:SetValue( "TFKMASTER", "TFK_UNICO" , 	aLogEvento[nI][3]	)	// X2_UNICO da tabela utilizada no eveto
		oModel:SetValue( "TFKMASTER", "TFK_VALOR" , 	aLogEvento[nI][4]	)	// Valor do campo encontrado no evento
		oModel:SetValue( "TFKMASTER", "TFK_VLRRET", 	aLogEvento[nI][5]	)	// Valor do campo retorno encontrado no evento
									
		For nJ:= 1 To Len(aDesLog)		
			
			if nJ <> 1
				oModelTFM:AddLine()
			EndIf
			
			oModel:SetValue( "TFMDETAIL", "TFM_CODDES" , 	aDesLog[nJ][1])
			oModel:SetValue( "TFMDETAIL", "TFM_EMAIL"  , 	aDesLog[nJ][2])
			oModel:SetValue( "TFMDETAIL", "TFM_STATUS" , 	aDesLog[nJ][3])					
					
		Next nJ		
		
		If 	oModel:VldData() 		// Aplica a validações aos campos alimentados				
			oModel:CommitData() 	// Efetua a gravação e commit		
			oModel:DeActivate()	// Desativamos o Model			
		Else 		
			aErro := oModel:GetErrorMessage()
			conout( STR0004	+ ' [' + AllToChar( aErro[1] ) + ']' ) // Id do formulário de origem:
			conout( STR0005	+ ' [' + AllToChar( aErro[2] ) + ']' ) // Id do campo de origem: 
			conout( STR0006	+ ' [' + AllToChar( aErro[3] ) + ']' ) // Id do formulário de erro: 
			conout( STR0007	+ ' [' + AllToChar( aErro[4] ) + ']' ) // Id do campo de erro: 
			conout( STR0008	+ ' [' + AllToChar( aErro[5] ) + ']' ) // Id do erro: 
			conout( STR0009	+ ' [' + AllToChar( aErro[6] ) + ']' ) // Mensagem do erro: 
			conout( STR0010	+ ' [' + AllToChar( aErro[7] ) + ']' ) // Mensagem da solução: 
			conout( STR0011	+ ' [' + AllToChar( aErro[8] ) + ']' ) // Valor atribuído: 
			conout( STR0012	+ ' [' + AllToChar( aErro[9] ) + ']' ) // Valor anterior: 		
		EndIf 		
		
	Next nI
	
EndIf

RestArea(aArea)

Return(Nil)