#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static aNFSData		:= {}

/*/{Protheus.doc} GTPA850
(long_description)
@type  Function
@author henrique.toyada
@since 24/05/2022
@version version
@param , param_type, param_descr
@return , return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA850()

	Local   oBrowse := FWLoadBrw('GTPA850')
	Private aRotina := MenuDef()

	oBrowse:SetMenuDef('GTPA850')

	If !IsBlind()
		oBrowse:Activate()
	EndIf

	If FindFunction('GTPANPS')
		GTPANPS()	
	Endif

Return(oBrowse)

/*/{Protheus.doc} BrowseDef
	(long_description)
	@type  Static Function
	@author henrique.toyada
	@since 24/05/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function BrowseDef()
Local oBrowse := FWMBrowse():New()
oBrowse:SetAlias("H61")
oBrowse:SetDescription("Controle CTe-OS")

//0=Normal;1=Complemento;2=Anulacao;3=Substituicao;4=Documento excluído;5=Cancelamento 
oBrowse:AddLegend("H61_STATUS=='0'", "GREEN"     ,"Normal" ,"H61_STATUS")
oBrowse:AddLegend("H61_STATUS=='1'", "YELLOW"    ,"Complemento" ,"H61_STATUS")
oBrowse:AddLegend("H61_STATUS=='2'", "GRAY"      ,"Anulacao" ,"H61_STATUS")
oBrowse:AddLegend("H61_STATUS=='3'", "BROWN"     ,"Substituicao" ,"H61_STATUS")
oBrowse:AddLegend("H61_STATUS=='4'", "RED"       ,"Documento excluído" ,"H61_STATUS")
oBrowse:AddLegend("H61_STATUS=='5'", "BLACK"     ,"Cancelamento" ,"H61_STATUS")

//1=Pendente;2=Transmitido;3=Erro de Transmissao;4=Documento Impresso
oBrowse:AddLegend("H61_STATRA=='1'", "WHITE"     ,"Pendente" ,"H61_STATRA")
oBrowse:AddLegend("H61_STATRA=='2'", "GREEN"     ,"Transmitido" ,"H61_STATRA")
oBrowse:AddLegend("H61_STATRA=='3'", "RED"       ,"Erro de Transmissao" ,"H61_STATRA")
oBrowse:AddLegend("H61_STATRA=='4'", "BLUE"      ,"Documento Impresso" ,"H61_STATRA")

oBrowse:DisableDetails()
//oBrowse:Activate()

Return oBrowse

/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 24/05/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar"			ACTION "VIEWDEF.GTPA850"	OPERATION 2 ACCESS 0  
	ADD OPTION aRotina TITLE "Incluir"				ACTION "VIEWDEF.GTPA850"	OPERATION 3 ACCESS 0 
	ADD OPTION aRotina TITLE "Alterar"				ACTION "GA850Manut(3)"		OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE "Atualizar"			ACTION "GA850Atual()"		OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE "Excluir"				ACTION "GA850Manut(5)"		OPERATION 5 ACCESS 0 
	ADD OPTION aRotina TITLE "Excesso de Bagagem"	ACTION "GTPAViewBag()"		OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE "Legenda"				ACTION "GTPA850Leg()"   	OPERATION 2 ACCESS 0 
	
Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author henrique.toyada
@since		24/05/2022
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruH61   := FWFormStruct(1,"H61")
	Local oStruH621  := FWFormStruct(1,"H62")
	Local oStruH622  := FWFormStruct(1,"H62")
	Local bPosValid  := { |oModel|PosValid(oModel)}
	Local oModel     := NIL
	Local aRelation  := {}

	Local bCommit   := {|oMdl| GTP850Commit(oMdl) }
	
	oModel := MPFormModel():New("GTPA850",/*bPreValidMdl*/, bPosValid/*bPosValidMdl*/,/*bCommit*/, /*bCancel*/ )
	oModel:SetCommit(bCommit)

	SetModelStruct(oStruH61,oStruH621,oStruH622)

	oModel:SetDescription("Complemento de Notas de Transportes de Passageiros CTeOS")
	oModel:AddFields('FIELDH61',,oStruH61)
	oModel:GetModel('FIELDH61'):SetDescription("Complemento para CTeOS")

	oModel:AddGrid("GRIDH62", "FIELDH61", oStruH621, /*bPreLine*/, /*bPosLine*/, /*bPre*/, /*bPos*/, /*bLoad*/)

	aRelation := {  {"H62_FILIAL","XFILIAL('H61')"},;
					{"H62_CODIGO","H61_CODIGO"}}

	oModel:SetRelation("GRIDH62", aRelation , H62->(IndexKey(1)))

	oModel:AddFields('FIELDH62','GRIDH62',oStruH622)

	aRelation := {  {"H62_FILIAL","XFILIAL('H62')"},;
					{"H62_CODIGO","H62_CODIGO"},;
					{"H62_EVENTO","H62_EVENTO"}}

	oModel:SetRelation("FIELDH62", aRelation , H62->(IndexKey(1)))

	oModel:SetPrimaryKey({"H61_FILIAL","H61_CODIGO"})
	
	oModel:GetModel("GRIDH62"):SetOptional(.T.)
	oModel:GetModel("FIELDH62"):SetOptional(.T.)
	oModel:GetModel( 'GRIDH62' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'FIELDH62' ):SetOnlyQuery( .T. )
Return oModel

/*/{Protheus.doc} SetModelStruct
	(long_description)
	@type  Static Function
	@author henrique.toyada
	@since 24/05/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SetModelStruct(oStruH61,oStruH621,oStruH622)

Local bTrig 	:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit		:= {|oMdl,cField| FieldInit(oMdl,cField)}
Local bFieldVld	:= {|oMdl,cField,uVal| FieldValid(oMdl,cField,uVal)}

	If fwisincallstack("GTPAViewBag") // Campo obrigatorio caso seja Excesso de Bagagem
		oStruH61:SetProperty("H61_CODGQ2", MODEL_FIELD_OBRIGAT, .T.)
	Endif

	oStruH61:SetProperty( "H61_NOTA"	, MODEL_FIELD_OBRIGAT, .F. )
	oStruH61:SetProperty( "H61_REGEST"	, MODEL_FIELD_OBRIGAT, .F. )

	oStruH621:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
	oStruH621:SetProperty('H62_EVENTO', MODEL_FIELD_INIT, bInit )
	oStruH621:SetProperty('H62_CODIGO', MODEL_FIELD_INIT, bInit )

	oStruH622:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
	oStruH622:SetProperty('H62_EVENTO', MODEL_FIELD_INIT, bInit )
	oStruH622:SetProperty('H62_CODIGO', MODEL_FIELD_INIT, bInit )
	
	oStruH61:SetProperty('H61_SERIE'  , MODEL_FIELD_VALID, bFieldVld )

	oStruH61:SetProperty('H61_SERIE'  , MODEL_FIELD_INIT, bInit )
	oStruH61:SetProperty('H61_NOME'   , MODEL_FIELD_INIT, bInit )
	oStruH61:SetProperty('H61_DMUINI' , MODEL_FIELD_INIT, bInit )
	oStruH61:SetProperty('H61_DMUFIM' , MODEL_FIELD_INIT, bInit )
	oStruH61:SetProperty('H61_NTCFOP' , MODEL_FIELD_INIT, bInit )
	oStruH61:SetProperty('H61_DESPRO' , MODEL_FIELD_INIT, bInit )

	oStruH61:AddTrigger('H61_VEIC'  , 'H61_VEIC'  ,  { || .T. }, bTrig ) 
	oStruH61:AddTrigger('H61_CLIENT', 'H61_CLIENT',  { || .T. }, bTrig ) 
	oStruH61:AddTrigger('H61_LOJA'  , 'H61_LOJA'  ,  { || .T. }, bTrig ) 
	oStruH61:AddTrigger('H61_PRODUT', 'H61_PRODUT',  { || .T. }, bTrig ) 
	oStruH61:AddTrigger('H61_TES'   , 'H61_TES'   ,  { || .T. }, bTrig ) 
	oStruH61:AddTrigger('H61_CFOP'  , 'H61_CFOP'  ,  { || .T. }, bTrig ) 
	oStruH61:AddTrigger('H61_CMUINI', 'H61_CMUINI',  { || .T. }, bTrig ) 
	oStruH61:AddTrigger('H61_CMUFIM', 'H61_CMUFIM',  { || .T. }, bTrig ) 
	oStruH61:AddTrigger('H61_QUANT' , 'H61_QUANT' ,  { || .T. }, bTrig ) 
	oStruH61:AddTrigger('H61_VLUNIT', 'H61_VLUNIT',  { || .T. }, bTrig ) 
	
	oStruH621:AddField(	"",;									// 	[01]  C   Titulo do campo
					 		"LEGENDA",;									// 	[02]  C   ToolTip do campo	//"Legenda"
					 		"LEGENDA",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		15,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
	
	oStruH621:SetProperty('LEGENDA'  , MODEL_FIELD_INIT, bInit )
Return 

/*/{Protheus.doc} FieldValid()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 07/04/2022
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function FieldValid(oMdl, cField, uVal)
Local lRet    := .T.
Local cSerie  := ""
Local aSeries := {}

If cField == 'H61_SERIE'

	cSerie	:= SuperGetMv("MV_ESPECIE")
	If( !Empty(cSerie) )	
			
		aSeries := Separa(cSerie,";")
		
		If ( Len(aSeries) > 0 )

			nP := aScan(aSeries,{|x| uVal + "=CTEOS" $ x })

			If ( nP == 0 )	
				oMdl:GetModel():SetErrorMessage(oMdl:GetId(), cField, oMdl:GetId(), cField, "FieldValid", "Série informada não cadastrada para CTEOS", "Informe uma série correspondente a CTEOS") 
				lRet := .F.	
			Endif

			If lRet .AND. ( !(SX5->(DBSEEK(XFILIAL("SX5") + "01" + uVal ))) )	
				oMdl:GetModel():SetErrorMessage(oMdl:GetId(), cField, oMdl:GetId(), cField, "FieldValid", "Série informada não cadastrada para CTEOS", "Informe uma série correspondente a CTEOS") 
				lRet := .F.	
			Endif
		Endif
	Else
		oMdl:GetModel():SetErrorMessage(oMdl:GetId(), cField, oMdl:GetId(), cField, "FieldValid", "Parâmetro MV_ESPECIE não preenchido", "Informe uma série correspondente a CTEOS no parâmetro") 
		lRet := .F.	
	Endif

Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldInit

@type Function
@author henrique.toyada 
@since 24/05/2022
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField)

Local uRet      := nil
Local oModel	:= oMdl:GetModel()
Local lInsert	:= oModel:GetOperation() == MODEL_OPERATION_INSERT 
Local aArea     := GetArea()

Do Case 
    Case cField == "H61_NOME"
        uRet := If(!lInsert,Posicione('SA1',1,xFilial('SA1') + H61->H61_CLIENT + H61->H61_LOJA,'A1_NOME'),'')
    Case cField == "H61_DMUINI"
		uRet := If(!lInsert,ALLTRIM(Posicione('CC2',1,xFilial('CC2')+H61->H61_UMUINI+H61->H61_CMUINI,"CC2_MUN" )),'')
	Case cField == "H61_DMUFIM"
		uRet := If(!lInsert,ALLTRIM(Posicione('CC2',1,xFilial('CC2')+H61->H61_UMUFIM+H61->H61_CMUFIM,"CC2_MUN" )),'')
	Case cField == "H61_SERIE"
        uRet := If(!lInsert,H61->H61_SERIE,GTPGetRules("SERIECTEOS",,,""))
	Case cField == "H61_NTCFOP"
		uRet := If(!lInsert,ALLTRIM(Posicione('SX5',1,xFilial('SX5')+'13'+H61->H61_CFOP,'X5_DESCRI')),'')
	Case cField == "H61_DESPRO"
		uRet := If(!lInsert,ALLTRIM(Posicione('SB1',1,xFilial('SB1')+H61->H61_PRODUT,'B1_DESC')),'')
	Case cField == "H62_CODIGO"
		uRet := If(!lInsert,M->H61_CODIGO,H62->H62_CODIGO)
	Case cField == "H62_EVENTO"
		uRet := If(!lInsert,"00",H62->H62_EVENTO)
	Case cField == "LEGENDA"
		uRet := If(!lInsert,IF(EMPTY(H62->H62_PROTOC),"BR_VERMELHO","BR_VERDE"),"BR_VERMELHO")
EndCase 

RestArea(aArea)

Return uRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA850ATrig
Função que preenche trigger

@sample	GA850ATrig()

@author henrique.toyada
@since 24/05/2022
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function FieldTrigger(oMdl,cField,uVal)

	Do Case 
		Case cField == 'H61_VEIC'
			oMdl:SetValue("H61_PLACA" , posicione("ST9",1,xFilial('ST9')+ uVal,'T9_PLACA'))
			oMdl:SetValue("H61_RENAVA", posicione("ST9",1,xFilial('ST9')+ uVal,'T9_RENAVAM'))
		Case cField == 'H61_CLIENT'
			oMdl:SetValue("H61_LOJA" ,Posicione('SA1',1,xFilial('SA1')+uVal,"A1_LOJA" ))
			oMdl:SetValue("H61_NOME" ,SUBSTR(Posicione('SA1',1,xFilial('SA1')+uVal+Posicione('SA1',1,xFilial('SA1')+uVal,"A1_LOJA" ),"A1_NOME" ),0,TamSX3("H61_NOME")[1]))
		Case cField == 'H61_LOJA'
			oMdl:SetValue("H61_NOME" ,SUBSTR(Posicione('SA1',1,xFilial('SA1')+oMdl:GetValue('H61_CLIENT')+uVal,"A1_NOME" ),0,TamSX3("H61_NOME")[1]))
		Case cField == 'H61_CMUINI'
			oMdl:SetValue("H61_DMUINI" ,ALLTRIM(Posicione('CC2',1,xFilial('CC2')+oMdl:GetValue('H61_UMUINI')+uVal,"CC2_MUN" )))
		Case cField == 'H61_CMUFIM'
			oMdl:SetValue("H61_DMUFIM" ,ALLTRIM(Posicione('CC2',1,xFilial('CC2')+oMdl:GetValue('H61_UMUFIM')+uVal,"CC2_MUN" )))
		Case cField == 'H61_QUANT'
			oMdl:SetValue("H61_TOTAL" ,oMdl:GetValue('H61_VLUNIT') * uVal)
		Case cField == 'H61_VLUNIT'
			oMdl:SetValue("H61_TOTAL" ,uVal * oMdl:GetValue('H61_QUANT'))
		Case cField == 'H61_TES'
			oMdl:SetValue("H61_CFOP" ,ALLTRIM(Posicione('SF4',1,xFilial('SF4')+uVal,'F4_CF')))
			oMdl:SetValue("H61_NTCFOP" ,SUBSTR(Posicione('SX5',1,xFilial('SX5')+'13'+uVal,'X5_DESCRI'),0,TamSX3("H61_NTCFOP")[1]))
		Case cField == 'H61_CFOP'
			oMdl:SetValue("H61_NTCFOP" ,SUBSTR(Posicione('SX5',1,xFilial('SX5')+'13'+uVal,'X5_DESCRI'),0,TamSX3("H61_NTCFOP")[1]))
		Case cField == 'H61_PRODUT'
			oMdl:SetValue("H61_DESPRO" ,ALLTRIM(Posicione('SB1',1,xFilial('SB1')+uVal,'B1_DESC')))
	EndCase 

Return uVal

/*/{Protheus.doc} PosValid
(long_description)
@type  Static Function
@author Teixeira
@since 24/05/2022
@version 1.0
@param oModel, objeto, param_descr
@return lRet, Lógico, Lógico
@example
(examples)
@see (links_or_references)
/*/
Static Function PosValid(oModel)

Local oMdlH61	:= oModel:GetModel('FIELDH61')
Local lRet	    := .T.
Local oView		:= FwViewActive()

If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
    
	If !(EMPTY(oMdlH61:GetValue("H61_REGEST")))
		lRet := oMdlH61:GetValue("H61_UMUINI") == oMdlH61:GetValue("H61_UMUFIM")
	
		If !lRet
			oMdlH61:LoadValue("H61_REGEST","")
			oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,,"Para operações em estados diferentes não é possível enviar o registro estadual(H61_REGEST) no XML","Preencher e enviar o Termo autori fretamento(H61_AUTTAF)")
		EndIf
	EndIf

	If lRet .AND. !(EMPTY(oMdlH61:GetValue("H61_AUTTAF")))
		lRet := oMdlH61:GetValue("H61_UMUINI") != oMdlH61:GetValue("H61_UMUFIM")
	
		If !lRet
			oMdlH61:LoadValue("H61_AUTTAF","")
			oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,,"Para operações no mesmo estados não é possível enviar o Termo autori fretamento(H61_AUTTAF) no XML","Preencher e enviar o registro estadual(H61_REGEST)")
		EndIf
	EndIf
EndIf
oView:Refresh()	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View da Rotina 
@author henrique.toyada
@since   24/05/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel	:= ModelDef()
Local oStruH61	:= FWFormStruct(2, "H61")
Local oStruH621	:= FWFormStruct(2, "H62")
Local oStruH622	:= FWFormStruct(2, "H62")

SetViewStruct(oStruH61,oStruH621,oStruH622)

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEWH61", oStruH61, "FIELDH61")
oView:AddGrid("VIEWGRIDH621", oStruH621, 'GRIDH62') 
oView:AddField("VIEWGRIDH622", oStruH622, 'FIELDH62') 

oView:CreateFolder("FOLDER")
oView:AddSheet( "FOLDER", "ABA01", "CTEOS")
oView:CreateHorizontalBox( "SUPERIOR1", 100, /*owner*/,/*lUsePixel*/, 'FOLDER', 'ABA01' )

oView:AddSheet( "FOLDER", "ABA02", "SEFAZ") 
oView:CreateHorizontalBox( "SUPERIOR2", 40, /*owner*/,/*lUsePixel*/, 'FOLDER', 'ABA02' )
oView:CreateHorizontalBox( "INFERIOR", 60, /*owner*/,/*lUsePixel*/, 'FOLDER', 'ABA02' )

oView:SetOwnerView("VIEWH61","SUPERIOR1")
oView:SetOwnerView("VIEWGRIDH621","SUPERIOR2")
oView:SetOwnerView("VIEWGRIDH622","INFERIOR")

oView:AddUserButton( "Legenda SEFAZ", "", {|| GTP850H62()} )
oView:SetViewProperty("VIEWGRIDH621", "GRIDDOUBLECLICK", {{|| GTP850H62()}})

//oView:GetModel('GRIDH62'):SetNoUpdateLine(.T.)

Return oView 

/*/{Protheus.doc} SetViewStruct
	(long_description)
	@type  Static Function
	@author henrique.toyada
	@since 24/05/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SetViewStruct(oStruH61,oStruH621,oStruH622)
	
	oStruH61:RemoveField("H61_STATUS")
	oStruH61:RemoveField("H61_STATRA")
	oStruH61:RemoveField("H61_NOTA")

	If !fwisincallstack("GTPAViewBag")
		oStruH61:RemoveField('H61_CODGQ2')
	Else
		oStruH61:SetProperty('*' , MVC_VIEW_CANCHANGE , .F. )
		oStruH61:SetProperty('H61_CODGQ2' , MVC_VIEW_CANCHANGE , .T. )
	EndIf

	If fwisincallstack("GA850Atual") // Campos apenas para atualização do xml do cteos
		oStruH61:SetProperty('H61_SERIE' , MVC_VIEW_CANCHANGE , .F. )
		oStruH61:SetProperty('H61_CLIENT', MVC_VIEW_CANCHANGE , .F. )
		oStruH61:SetProperty('H61_LOJA'  , MVC_VIEW_CANCHANGE , .F. )
		oStruH61:SetProperty('H61_PRODUT', MVC_VIEW_CANCHANGE , .F. )
		oStruH61:SetProperty('H61_TES'   , MVC_VIEW_CANCHANGE , .F. )
		oStruH61:SetProperty('H61_CFOP'  , MVC_VIEW_CANCHANGE , .F. )
		oStruH61:SetProperty('H61_QUANT' , MVC_VIEW_CANCHANGE , .F. )
		oStruH61:SetProperty('H61_VLUNIT', MVC_VIEW_CANCHANGE , .F. )
	Endif

	oStruH61:AddGroup( "GRUPO_NOTA"      , "Dados da Nota"    , ""                 , 2 )
	oStruH61:AddGroup( "GRUPO_DOCUMENTO" , "Dados para Envio" , ""                 , 2 )
	oStruH61:AddGroup( "GRUPO_VEICULO"   , "Dados do Veiculo" , ""                 , 2 )
	oStruH61:AddGroup( "GRUPO_OBS"       , "Observação"       , ""                 , 2 )

	oStruH61:SetProperty("H61_CODIGO"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA" )
	oStruH61:SetProperty("H61_SERIE"      , MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA" )
	oStruH61:SetProperty("H61_TES"        , MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA" )
	oStruH61:SetProperty("H61_CFOP"       , MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA" )
	oStruH61:SetProperty("H61_NTCFOP"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA" )
	oStruH61:SetProperty("H61_CLIENT"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA" )
	oStruH61:SetProperty("H61_LOJA"       , MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA" )
	oStruH61:SetProperty("H61_NOME"       , MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA" )
	oStruH61:SetProperty("H61_PRODUT"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA" )
	oStruH61:SetProperty("H61_DESPRO"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA" )
	oStruH61:SetProperty("H61_QUANT"      , MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA" )
	oStruH61:SetProperty("H61_VLUNIT"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA" )
	oStruH61:SetProperty("H61_TOTAL"      , MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA" )
	oStruH61:SetProperty("H61_UMUINI"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
	oStruH61:SetProperty("H61_CMUINI"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
	oStruH61:SetProperty("H61_DMUINI"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
	oStruH61:SetProperty("H61_UMUFIM"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
	oStruH61:SetProperty("H61_CMUFIM"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
	oStruH61:SetProperty("H61_DMUFIM"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
	oStruH61:SetProperty("H61_VEIC"       , MVC_VIEW_GROUP_NUMBER, "GRUPO_VEICULO" )
	oStruH61:SetProperty("H61_PLACA"      , MVC_VIEW_GROUP_NUMBER, "GRUPO_VEICULO" )
	oStruH61:SetProperty("H61_RENAVA"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_VEICULO" )
	oStruH61:SetProperty("H61_UFVEI"      , MVC_VIEW_GROUP_NUMBER, "GRUPO_VEICULO" )
	oStruH61:SetProperty("H61_QUANTP"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_VEICULO" )
	oStruH61:SetProperty("H61_UFPERC"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_VEICULO" )
	oStruH61:SetProperty("H61_DTVIAG"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_VEICULO" )
	oStruH61:SetProperty("H61_HRVIAG"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_VEICULO" )
	oStruH61:SetProperty("H61_AUTTAF"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
	oStruH61:SetProperty("H61_REGEST"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
	oStruH61:SetProperty("H61_MODAL"      , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
	oStruH61:SetProperty("H61_TPFRET"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
	If fwisincallstack("GTPAViewBag") // Campo obrigatorio caso seja Excesso de Bagagem
		oStruH61:SetProperty("H61_CODGQ2"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
	EndIf
	oStruH61:SetProperty("H61_OBSNF"      , MVC_VIEW_GROUP_NUMBER, "GRUPO_OBS" )
	oStruH61:SetProperty("H61_MSGFIS"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_OBS" )

	oStruH61:SetProperty("H61_UMUINI",	MVC_VIEW_LOOKUP , "12")
	oStruH61:SetProperty("H61_UMUFIM",	MVC_VIEW_LOOKUP , "12")
	oStruH61:SetProperty("H61_UFVEI",	MVC_VIEW_LOOKUP , "12")

	//oStruH621:RemoveField("H62_CODIGO")
	oStruH621:RemoveField("H62_XMLCTE")
	oStruH621:RemoveField("H62_XMLAUT")
	oStruH621:RemoveField("H62_XMLERR")
	oStruH621:RemoveField("H62_NFORI" )
	oStruH621:RemoveField("H62_SERORI")
	oStruH621:RemoveField("H62_FILORI")
	oStruH621:RemoveField("H62_CLIORI")
	oStruH621:RemoveField("H62_LOJORI")
	
	oStruH621:AddField(	"LEGENDA",;					// [01]  C   Nome do Campo
	                        "01",;						// [02]  C   Ordem
	                        "",;						// [03]  C   Titulo do campo
	                        "Legenda",;						// [04]  C   Descricao do campo	//"Legenda"
	                        {"Legenda"},;				// [05]  A   Array com Help // "Selecionar"	//"Legenda"
	                        "GET",;						// [06]  C   Tipo do campo
	                        "@BMP",;					// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	
	//oStruH622:RemoveField("H62_CODIGO")
	oStruH622:RemoveField("H62_EVENTO")
	oStruH622:RemoveField("H62_CHVCTE")
	oStruH622:RemoveField("H62_PROTOC")
	oStruH622:RemoveField("H62_COMPVL")
	oStruH622:RemoveField("H62_NFORI" )
	oStruH622:RemoveField("H62_SERORI")
	oStruH622:RemoveField("H62_FILORI")
	oStruH622:RemoveField("H62_CLIORI")
	oStruH622:RemoveField("H62_LOJORI")
Return 

/*/{Protheus.doc} GTP850Comiit   
    Executa o bloco Commit do MVC
    @type  Static Function
    @author henrique.toyada
    @since 24/05/2022
    @version version
    @param oModel, objeto, instância da Classe FwFormModel
    @return lRet, lógico, .t. - Efetuou o Commit com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GTP850Commit(oModel)
	
	Local lRet 		:= .T.
	Local cMsgCom   := ""

	cMsgCom := "Gerando/Excluindo registros de CTe-OS e nota fiscal de saída."
	If FWisInCallStack("GA850Atual") .OR. FWisInCallStack("GTPAViewBag")
		cMsgCom := "Atualizando registro."
	EndIf 
	FWMsgRun( ,{|| lRet := Commit(oModel), lRet}, "Atualização...", cMsgCom )

Return(lRet)


/*/{Protheus.doc} GA850Atual
Efetua atualização das informações pertinentes ao xml do cteos
@type  Function
@author henrique.toyada
@since 24/05/2022
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GA850Atual()
	If H61->H61_STATUS != '4' .AND. H61->H61_STATRA $ '1|3'
		FwExecView("","VIEWDEF.GTPA850",MODEL_OPERATION_UPDATE,,{|| .T.})
	Else
		FwAlertError("Status do CTe-OS não permitido para esta operação", "Não permitido")		
	EndIf
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GA850Manut
Função responsável pela manutenção do registro H61, tanto a alteração
quanto a exclusão

@author henrique.toyada
@since 24/05/2022
@version	P12
/*/
//-------------------------------------------------------------------
Function GA850Manut(nOpc)

	Local oModel	:= FwLoadModel("GTPA850")
	Local aEnable	:= Array(15,2)

	If H61->H61_STATUS != '4' .AND. H61->H61_STATRA $ '1|3'

		aEnable[07][1] := .T.
		aEnable[07][2] := "Confirmar"
		
		aEnable[08][1] := .T.
		aEnable[08][2] := "Cancelar"
		
		aEnable[15][1] := .F.
		aEnable[15][2] := Nil
		
		nOption := nOpc
		
		aNFSData := {;
			xFilial("SF2"),;
			H61->H61_NOTA,;
			H61->H61_SERIE,;
			H61->H61_CLIENT,;
			H61->H61_LOJA;
		}
		
		cMsgAlert := "O modo de edição de documento Cte-Os exclui o documento de saída que fora "
		cMsgAlert += "gerado durante a inclusão. Normalmente, este processo gera escrita em "
		cMsgAlert += "livros fiscais, os quais não serão excluídos junto com o documento de saída"
		cMsgAlert += " original. Caso necessite INUTILIZAR (processo CTe-OS) o documento original, "
		cMsgAlert += "será necessário excluir a escrita fiscal da nota. Basta acessar a rotina do "
		cMsgAlert += "módulo Fiscal, Acertos Fiscais."
		
		FWAlertWarning(cMsgAlert,"Alerta de alteração!")
	
		If ( nOption == MODEL_OPERATION_INSERT )

			oModel:SetOperation(MODEL_OPERATION_INSERT)
			
			oModel:Activate(.t.)
			oModel:GetModel("FIELDH61"):SetValue("H61_CODIGO", GETSXENUM("H61","H61_CODIGO"))
			oModel:GetModel("FIELDH61"):SetValue("H61_CLIENT", H61->H61_CLIENT)
			oModel:GetModel("FIELDH61"):SetValue("H61_LOJA", H61->H61_LOJA)
			oModel:GetModel("FIELDH61"):SetValue("H61_STATUS", "0")
			oModel:GetModel("FIELDH61"):SetValue("H61_STATRA", "1")

			oModel:GetModel("GRIDH62"):LoadValue("H62_CODIGO", oModel:GetModel("FIELDH61"):GetValue("H61_CODIGO"))
			oModel:GetModel("GRIDH62"):LoadValue("H62_EVENTO", "00")
			oModel:GetModel("GRIDH62"):LoadValue("H62_DSAIDA", DATE())
			oModel:GetModel("GRIDH62"):LoadValue("H62_HSAIDA", TIME())

			oModel:GetModel("FIELDH62"):LoadValue("H62_CODIGO", oModel:GetModel("FIELDH61"):GetValue("H61_CODIGO"))
			oModel:GetModel("FIELDH62"):LoadValue("H62_EVENTO", "00")
			oModel:GetModel("FIELDH62"):LoadValue("H62_DSAIDA", DATE())
			oModel:GetModel("FIELDH62"):LoadValue("H62_HSAIDA", TIME())
			
			FwExecView("Manutenção CTe-OS","GTPA850",nOpc,,,,,aEnable,,,,oModel)

		Else
			oModel:SetOperation(nOption)
			oModel:Activate()
			
			FwExecView("Manutenção CTe-OS","GTPA850",nOpc,,,,,aEnable,,,,oModel)

		EndIf

		nOption := 0
		aNFSData:= {}

	Else
		FwAlertError("Status do CTe-OS não permitido para esta operação", "Não permitido")		
	EndIf	
	
Return()

/*/{Protheus.doc} Commit   
    Executa o bloco Commit do MVC
    @type  Static Function
    @author henrique.toyada 
    @since 24/05/2022
    @version version
    @param oModel, objeto, instância da Classe FwFormModel
    @return lRet, lógico, .t. - Efetuou o Commit com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function Commit(oModel)
	
	Local lRet 		:= .T.
	
	Local cMsgErro  := ""
	Local cMsgSol   := ""
	Local cNota		:= ""
	Local nOption   := oModel:GetOperation()
	
	Local oMdlH61	:= oModel:GetModel("FIELDH61")

	If oMdlH61:GetValue("H61_STATRA") == "3"
		oMdlH61:LoadValue("H61_STATRA", "1")
	EndIf
	If (oModel:VldData())

		//Quando for manutenção, primeiramente, apaga o documento de saída
		If ( FWisInCallStack("GA850Manut") .OR. (!(FWisInCallStack("GA850Atual")) .AND. !(FWisInCallStack("GTPAViewBag")))) 
			If !(EMPTY(oModel:GetModel("FIELDH61"):GetValue("H61_NOTA")))
				lRet := GA850NFSDel()	
				If lRet 
					RecLock("H61",.F.)
					H61->H61_STATUS := '4'
					H61->( MsUnlock() )
				EndIf			
			EndIf
			If ( lRet )
		
				Begin Transaction
					
					If ( nOption != 5 )
						cNota := GeraNf(oModel,@cMsgErro,@cMsgSol)
						cNota := PadR(cNota,TamSx3("H61_NOTA")[1])
					EndIf
					
					If ( nOption == 5 .Or. (nOption != 5 .And. !Empty(cNota) .And. oMdlH61:LoadValue("H61_NOTA", cNota)) )
						lRet := FWFormCommit(oModel)
					Else
						lRet := .f.
					EndIf	

					If ( !lRet )
						DisarmTransaction()
					EndIf

				End Transaction
			
			EndIf
		Else
			lRet := FWFormCommit(oModel)
		EndIf

		If lRet .AND. nOption != 5 .AND. !(H62->(DBSEEK(XFILIAL("H61")+oModel:GetModel("FIELDH61"):GetValue("H61_CODIGO")+"00")))// .AND. !(FWisInCallStack("GA850Manut"))
			RecLock("H62",.T.)
			H62->H62_FILIAL := XFILIAL("H61")
			H62->H62_CODIGO := oModel:GetModel("FIELDH61"):GetValue("H61_CODIGO")
			H62->H62_EVENTO := "00"
			H62->H62_DSAIDA := DATE()
			H62->H62_HSAIDA := TIME()
			H62->( MsUnlock() )
		EndIf
	Endif

Return(lRet)
//------------------------------------------------------------------------------
/* /{Protheus.doc} GeraNf

@type Static Function
@author henrique.toyada
@since 24/05/2022
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GeraNf(oModel,cMsgErro,cMsgSol, cNumDoc)

	Local lRet          := .T.
	
	Local cNumero       := ""
	Local cEspecie      := "CTEOS"
	Local cEstDev       := ""
	Local cTipoCli      := ""
	Local cSitTrib      := ""
	Local cFilOld       := cFilAnt
	Local cFilAge       := ""
	
	Local aMunIni       := {}
	Local aMunFim       := {}
	Local aDadosCab     := {}
	Local aItem         := {}
	Local aDadosItem    := {}
	
	Local oMdlH61       := oModel:GetModel('FIELDH61')
	Local oMdlH62       := oModel:GetModel('FIELDH62')
	
	Local nTotal		:= 0
	
	Default cNumDoc 	:= ''
	
	cFilAge	:= Posicione('GI6',1,xFilial('GI6')+oMdlH61:GetValue('H61_CMUINI'),"GI6_FILRES")
	
	aMunIni := {oMdlH61:GetValue('H61_UMUINI'),oMdlH61:GetValue('H61_CMUINI')}
	aMunFim := {oMdlH61:GetValue('H61_UMUFIM'),oMdlH61:GetValue('H61_CMUFIM')}
	
	If !Empty(cFilAge) .and. cFilAge <> cFilAnt
		cFilAnt := cFilAge
	Endif
	
	//-------------------------------------------------------------------------------
	//Criação dos Dados de Cabeçalho
	//-------------------------------------------------------------------------------
	DbSelectArea( "SB0" )

	SA1->(DbSetOrder(1))//
	SF4->(DbSetOrder(1))
	SB1->(DbSetOrder(1))
	SBZ->(DbSetOrder(1))
	SB0->(DbSetOrder(1))

	aAdd(aDadosCab,{"F2_FILIAL"     ,xFilial("SF2")                 })
	aAdd(aDadosCab,{"F2_TIPO"       ,"N"                            })
	aAdd(aDadosCab,{"F2_SERIE"      ,oMdlH61:GetValue('H61_SERIE')                    })
	aAdd(aDadosCab,{"F2_EMISSAO"    ,oMdlH62:GetValue('H62_DSAIDA') })

	SA1->(DbSeek(xFilial('SA1')+oMdlH61:GetValue('H61_CLIENT')+oMdlH61:GetValue('H61_LOJA') ))

	aAdd(aDadosCab,{"F2_CLIENTE"    ,SA1->A1_COD })
	aAdd(aDadosCab,{"F2_LOJA"       ,SA1->A1_LOJA })

	cEstDev     := SA1->A1_EST
	cTipoCli    := SA1->A1_TIPO

	aAdd(aDadosCab,{"F2_TIPOCLI"    ,cTipoCli})
	aAdd(aDadosCab,{"F2_ESPECIE"    ,cEspecie})
	aAdd(aDadosCab,{"F2_COND"       ,'001'})
	aAdd(aDadosCab,{"F2_DTDIGIT"    ,oMdlH62:GetValue('H62_DSAIDA') })
	aAdd(aDadosCab,{"F2_EST"        ,aMunIni[1]})
	aAdd(aDadosCab,{"F2_VALMERC"    ,oMdlH61:GetValue('H61_VLUNIT') * oMdlH61:GetValue('H61_QUANT') })
	aAdd(aDadosCab,{"F2_MOEDA"      ,CriaVar( 'F2_MOEDA' )})
	aAdd(aDadosCab,{"F2_UFORIG"     ,aMunIni[1]})
	aAdd(aDadosCab,{"F2_CMUNOR"     ,aMunIni[2]})
	aAdd(aDadosCab,{"F2_UFDEST"     ,aMunFim[1]})
	aAdd(aDadosCab,{"F2_CMUNDE"     ,aMunFim[2]})

	//-------------------------------------------------------------------------------
	//Criação dos Dados de Item
	//-------------------------------------------------------------------------------
	nTotal := oMdlH61:GetValue('H61_TOTAL')
	
	aAdd(aItem,{"D2_FILIAL"     ,xFilial("SF2")     })
	aAdd(aItem,{"D2_ITEM"       ,StrZero(1,TamSx3("D2_ITEM")[1])     })
	aAdd(aItem,{"D2_SERIE"      ,oMdlH61:GetValue('H61_SERIE')             })
	aAdd(aItem,{"D2_CLIENTE"    ,SA1->A1_COD        })
	aAdd(aItem,{"D2_LOJA"       ,SA1->A1_LOJA       })
	aAdd(aItem,{"D2_EMISSAO"    ,oMdlH62:GetValue('H62_DSAIDA')            })
	aAdd(aItem,{"D2_TIPO"       ,"N"                })
	aAdd(aItem,{"D2_UM"         ,"UN"               })
	aAdd(aItem,{"D2_QUANT"      ,oMdlH61:GetValue('H61_QUANT')                  })
	aAdd(aItem,{"D2_PRUNIT"     ,oMdlH61:GetValue('H61_VLUNIT')    })
	aAdd(aItem,{"D2_PRCVEN"     ,oMdlH61:GetValue('H61_VLUNIT')    })
	aAdd(aItem,{"D2_TOTAL"      , nTotal })
	aAdd(aItem,{"D2_EST"        ,aMunIni[1] })
	aAdd(aItem,{"D2_ESPECIE"    ,cEspecie })
	
	If SB1->(DbSeek(xFilial('SB1')+oMdlH61:GetValue('H61_PRODUT') ))
				
		aAdd(aItem,{"D2_LOCAL"      ,SB1->B1_LOCPAD     })
		aAdd(aItem,{"D2_COD"        ,SB1->B1_COD        })
		aAdd(aItem,{"D2_TP"         ,SB1->B1_TIPO       })
		aAdd(aItem,{"D2_CONTA"      ,SB1->B1_CONTA      })

		If !Empty( SB1->B1_CODISS )
			aAdd(aItem,{"D2_CODISS"     ,SB1->B1_CODISS     })
		ElseIf SBZ->( dbSeek( xFilial("SBZ") + oMdlH61:GetValue('H61_PRODUT') ) ) .And. !Empty( SBZ->BZ_CODISS )//Precisa avaliar a criação desse campo ou como pegar essa informação
			aAdd(aItem,{"D2_CODISS"     ,SBZ->BZ_CODISS     })
		EndIf

		aAdd(aItem,{"D2_TES"        ,oMdlH61:GetValue('H61_TES')     })
		aAdd(aItem,{"D2_CF"         ,oMdlH61:GetValue('H61_CFOP') })//Precisa avaliar a criação desse campo ou como pegar essa informação
		aAdd(aItem,{"D2_ESTOQUE"    ,Posicione('SF4',1,xFilial('SF4')+oMdlH61:GetValue('H61_TES'),'F4_ESTOQUE')    })

		SB0->(DbSeek(xFilial("SB0")+SB1->B1_COD))
		
		//Executa funções padrões do LOJA para retornar a situação tributária a ser gravada na SD2
		Lj7Strib(@cSitTrib ) 
		Lj7AjustSt(@cSitTrib)

		aAdd(aItem,{"D2_SITTRIB"    ,cSitTrib           })

	Endif

	aAdd(aDadosItem,aItem)
	
	cNumero := GTPxNFS(oMdlH61:GetValue('H61_SERIE'),aDadosCab,aDadosItem,,cNumDoc)
	lRet := !Empty(cNumero)
	
	If !lRet
		cMsgErro    := "Não foi possivel gerar o documento de Saida"
		cMsgSol     := "Verifique se o cliente, produto, tipo de Saída ou o CFOP estão cadastrados corretamente"
	Endif

	cFilAnt := cFilOld

Return cNumero


//-------------------------------------------------------------------
/*/{Protheus.doc} GA850NFSDel
Função responsável pela exclusão da nota fiscal de saída

@author henrique.toyada
@since 24/05/2022
@version	P12
/*/
//-------------------------------------------------------------------
Function GA850NFSDel()

	//-- Recebe a marca que sera gravada nos campos F2_OK
	Local cMarca := GetMark(,"SF2","F2_OK") 

	Local aNota		:= {}
	Local aAreaSF2	:= SF2->(GetArea())
	//-- Dados das notas que serão excluidas
	Aadd(aNota,{aNFSData[2],aNFSData[3],aNFSData[4],aNFSData[5]})

	//Função que marca as notas que serão excluidas
	MarcaSF2(@cMarca,aNota)

	//-- Teste de Exclusão
	Mata521A(.T.,"SF2",cMarca,1)
	//Senão encontrou, significa que a exclusão foi realizada com sucesso
	lRet := !(SF2->(DbSeek(aNFSData[1]+aNFSData[2]+aNFSData[3]+aNFSData[4]+aNFSData[5])))

	RestArea(aAreaSF2)

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} MarcaSF2
Marca a nota a ser excluida
@author henrique.toyada
@since 24/05/2022
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function  MarcaSF2(cMarca, aNotas)
 
Local cDoc			:= ""
Local cSerie		:= ""
Local cCliFor		:= ""
Local cLoja			:= ""
Local nX 			:= ""
Local nTmDOC		:= GetSX3Cache("F2_DOC",     "X3_TAMANHO")
Local nTmSERIE		:= GetSX3Cache("F2_SERIE",   "X3_TAMANHO")
Local nTmCLIENTE	:= GetSX3Cache("F2_CLIENTE", "X3_TAMANHO")
Local nTmLOJA		:= GetSX3Cache("F2_LOJA",    "X3_TAMANHO")
Local lInverte      := ThisInv()
Local cQuery        := ""
Local lVerifMarc    := .T.
Local cAliasVerM    := GetNextAlias()

Default cMarca	:= GetMark(,"SF2", "F2_OK")
Default aNotas	:= {}

While lVerifMarc
	
	// Verificar se a marca pode ser utilizada
	cQuery := "SELECT COUNT(1) QTD "
	cQuery += "FROM "+RetSqlName("SF2")+" SF2 "
	cQuery += "WHERE SF2.F2_FILIAL='"+xFilial("SF2")+"' AND "
	If ( lInverte )
		cQuery += "SF2.F2_OK<>'"+cMarca+"' AND "
	Else
		cQuery += "SF2.F2_OK='"+cMarca+"' AND "
	EndIf
	cQuery += "SF2.D_E_L_E_T_=' '"
	cQuery := ChangeQuery(cQuery)

	DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVerM,.T.,.T.)

	If ((cAliasVerM)->QTD == 0)
		lVerifMarc := .F.
	Else
		cMarca	:= GetMark(,"SF2", "F2_OK")
	EndIf

	(cAliasVerM)->(DbCloseArea())
EndDo


DbSelectArea("SF2")
SF2->(DbSetOrder(1))
For nX := 1 to Len(aNotas)
	cDoc 	:= PADR(aNotas[nX][1], nTmDOC)
	cSerie  := PADR(aNotas[nX][2], nTmSERIE)
	cCliFor := PADR(aNotas[nX][3], nTmCLIENTE)
	cLoja 	:= PADR(aNotas[nX][4], nTmLOJA)
	If SF2->(MsSeek(cFilAnt+cDoc+cSerie+cCliFor+cLoja))
		SF2->(RecLock("SF2",.F.))
		SF2->F2_OK := cMarca
		SF2->(MsUnlock())
	EndIf
Next nX

Return

/*/{Protheus.doc} GTPAViewBag
(long_description)
@type  Function
@author henrique.toyada
@since 24/05/2022
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPAViewBag()

	If H61->H61_STATUS != '4' .AND. H61->H61_STATRA $ '1|3'
		FWExecView("Excesso de Bagagem","VIEWDEF.GTPA850", MODEL_OPERATION_UPDATE,,{|| .T.})
	Else
		FwAlertError("Status do CTe-OS não permitido para esta operação", "Não permitido")		
	EndIf

Return 

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA850Leg()
Monta Legenda
@return nil
@author henrique.toyada
@since 24/05/2022
@version 

/*/
//------------------------------------------------------------------------------------------------------
Function GTPA850Leg()

	oLegenda := FwLegend():New()

	//0=Normal;1=Complemento;2=Anulacao;3=Substituicao;4=Documento excluído;5=Cancelamento 
	oLegenda:Add( "H61_STATUS", "BR_VERDE"    ,"Normal"             )
	oLegenda:Add( "H61_STATUS", "BR_AMARELO"  ,"Complemento"        )
	oLegenda:Add( "H61_STATUS", "BR_CINZA"    ,"Anulacao"           )
	oLegenda:Add( "H61_STATUS", "BR_MARROM"   ,"Substituicao"       )
	oLegenda:Add( "H61_STATUS", "BR_VERMELHO" ,"Documento excluído" )
	oLegenda:Add( "H61_STATUS", "BR_PRETO"    ,"Cancelamento"       )

	//1=Pendente;2=Transmitido;3=Erro de Transmissao;4=Documento Impresso
	oLegenda:Add( "", ""   ,""            )
	oLegenda:Add( "H61_STATRA", "BR_BRANCO"   ,"Pendente"            )
	oLegenda:Add( "H61_STATRA", "BR_VERDE"    ,"Transmitido"         )
	oLegenda:Add( "H61_STATRA", "BR_VERMELHO" ,"Erro de Transmissao" )
	oLegenda:Add( "H61_STATRA", "BR_AZUL"     ,"Documento Impresso"  )

	oLegenda:Activate()
	
	oLegenda:View()
	oLegenda:DeActivate()

Return(Nil)

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP850H62()
Monta Legenda
@return nil
@author henrique.toyada
@since 24/05/2022
@version 

/*/
//------------------------------------------------------------------------------------------------------
Function GTP850H62()

	oLegenda := FwLegend():New()
	//If(!lInsert,IF(EMPTY(H62->H62_PROTOC),"BR_VERMELHO","BR_VERDE"),"BR_VERMELHO")
	oLegenda:Add( "LEGENDA", "BR_VERMELHO" ,"Não Autorizado")
	oLegenda:Add( "LEGENDA", "BR_VERDE"    ,"Autorizado"    )

	oLegenda:Activate()
	
	oLegenda:View()
	oLegenda:DeActivate()

Return(Nil)
