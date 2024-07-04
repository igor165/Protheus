#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "OMSA090.CH"

Static lOrdGrid := FindFunction("TMSDelLnGrd")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OMSA090  ³ Autor ³ Henry Fila            ³ Data ³ 17.06.99   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nome Orig.³ DFATA09  ³                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Pontos por Setor                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APDL                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador    ³ Data   ³ BOPS ³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Mauro Paladini ³04/09/13³      ³Conversao da rotina para o padrao MVC    ³±±
±±³Mauro Paladini ³06/12/13³      ³Ajustes para o funcionamento do Mile     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function OMSA090()
Local oBrowse   := Nil

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("DA7")
	oBrowse:SetMenuDef("OMSA090")
	oBrowse:SetDescription(STR0001) // "Cadastro de Pontos por Zona e Setor"
	oBrowse:SetCacheView(.F.) //-- Desabilita Cache da View, pois gera colunas dinamicamente
	oBrowse:Activate()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ModelDef ³ Autor ³ Mauro Paladini        ³ Data ³23.08.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Modelo de dados                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oModel Objeto do Modelo                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ModelDef()
Local oModel    := Nil
Local lMile     := IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT")
// Estrutura de campos do cabecalho
Local oStruCDA7 := FwFormStruct( 1, "DA7", { |cCampo|  AllTrim( cCampo ) + "|" $ "DA7_FILIAL|DA7_PERCUR|DA7_ROTA|" } )
Local oStruCDA5 := FwFormStruct( 1, "DA5", { |cCampo|  AllTrim( cCampo ) $ "DA5_DESC" } )
// Estrutura de campos do Grid - Folder 1
Local oStruDA7F1:= FwFormStruct( 1, "DA7", { |cCampo| !(AllTrim( cCampo ) + "|" $ "DA7_PERCUR|DA7_ROTA|DA7_CEPDE|DA7_CEPATE|DA7_PEROBR|") } )
// Estrutura de campos do Grid - Folder 2
Local oStruDA7F2:= FwFormStruct( 1, "DA7", { |cCampo| !(AllTrim( cCampo ) + "|" $ "DA7_PERCUR|DA7_ROTA|DA7_CLIENT|DA7_LOJA|DA7_NOME|") } )

Local bDescZona := 'IIF( !Inclui , Posicione("DA6",1,xFilial("DA6")+ DA7->DA7_PERCUR + DA7->DA7_ROTA  ,"DA6_REF") , "" ) '
Local bPosValid := {|oMdl| PosVldMdl(oMdl)}

//-- Limpa o filtro por conta do browse utilizando FWBrwRelation()
If IsInCallStack("OMSA100") .And. nModulo == 43
	DA5->(DbClearFilter())
	DA5->(DbCloseArea())
EndIf

	Aadd(oStruCDA7:aFields,oStruCDA5:aFields[1])

	oStruCDA7:SetProperty( "DA7_PERCUR" , MODEL_FIELD_WHEN    , FWBuildFeature(MODEL_FIELD_WHEN      ,"Inclui") )
	oStruCDA7:SetProperty( "DA7_ROTA"   , MODEL_FIELD_WHEN    , FWBuildFeature(MODEL_FIELD_WHEN      ,"Inclui") )
	oStruCDA7:SetProperty( "DA7_ROTA"   , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID  ,"Oms090Vld()"))
	oStruCDA7:SetProperty( "DA5_DESC"   , MODEL_FIELD_INIT    , FwBuildFeature(STRUCT_FEATURE_INIPAD , bDescZona ))
	oStruCDA7:SetProperty( "DA5_DESC"   , MODEL_FIELD_VIRTUAL , .T.)
	oStruDA7F1:SetProperty('DA7_NOME'   , MODEL_FIELD_INIT    , FwBuildFeature(STRUCT_FEATURE_INIPAD,'StaticCall(OMSA090,GetDesField,A,B)'))

	If !lMile
		// Validação dos campos da grid de cliente
		oStruDA7F1:SetProperty( "DA7_SEQUEN", MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID   ,"StaticCall(OMSA090,ValidField,A,B)"))
		oStruDA7F1:SetProperty( "DA7_CLIENT", MODEL_FIELD_OBRIGAT,.T.)
		oStruDA7F1:SetProperty( "DA7_LOJA"  , MODEL_FIELD_OBRIGAT,.T.)

		// Validação dos campos da grid de cep
		oStruDA7F2:SetProperty( "DA7_SEQUEN", MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID   ,"StaticCall(OMSA090,ValidField,A,B)"))
		oStruDA7F2:SetProperty( "DA7_CEPDE" , MODEL_FIELD_OBRIGAT,.T.)
	EndIf

	oModel:= MpFormMOdel():New("OMSA090", /*bPreValid*/ , bPosValid , /*bCommitMdl*/ ,/*bCancel*/ )
	oModel:SetDescription(STR0001)          // // "Cadastro de Pontos por Zona e Setor"

	oModel:AddFields("MdFieldCDA7",Nil,oStruCDA7,/*prevalid*/,,/*bCarga*/)
	oModel:SetPrimaryKey({ "DA7_FILIAL","DA7_PERCUR","DA7_ROTA" })

	// Folder 1 - Clientes
	If lOrdGrid
		oModel:AddGrid("MdGridDA7F1", "MdFieldCDA7" /*cOwner*/, oStruDA7F1 , {|oModel,nLine,cAction| PreVldMdl(oModel,nLine,cAction)} , { |oModel| Oms090LOk()} , /*bPre*/ , /*bPost*/, /*bLoad*/)
	Else
		oModel:AddGrid("MdGridDA7F1", "MdFieldCDA7" /*cOwner*/, oStruDA7F1 , /* bLinePre*/ , /*bLinePost*/ , /*bPre*/ , /*bPost*/, /*bLoad*/)
	EndIf

	oModel:SetRelation( "MdGridDA7F1", { { "DA7_FILIAL", "xFilial('DA7')" }, { "DA7_PERCUR", "DA7_PERCUR" } , { "DA7_ROTA", "DA7_ROTA" } }, DA7->( IndexKey( 1 ) ) )
	oModel:GetModel( "MdGridDA7F1" ):SetLoadFilter( { { 'DA7_CLIENT' , "'      '" , MVC_LOADFILTER_NOT_EQUAL             } } )
	oModel:GetModel( "MdGridDA7F1" ):SetOptional( .T. )
	oModel:GetModel( "MdGridDA7F1" ):SetMaxLine( 9999 )
	oModel:GetModel( "MdGridDA7F1" ):SetUseOldGrid( .T. )
	oModel:GetModel( "MdGridDA7F1" ):SetUniqueLine( { "DA7_CLIENT", "DA7_LOJA" } )

	// Folder 2 - Codigos de Enderecamento Postal
	If lOrdGrid
		oModel:AddGrid("MdGridDA7F2", "MdFieldCDA7" /*cOwner*/, oStruDA7F2 , {|oModel,nLine,cAction| PreVldMdl(oModel,nLine,cAction)} /*bLinePre*/ , {|oModel| Oms090LOk2(oModel)} , /*bPre*/ , /*bPost*/,/*bLoad*/)
	Else
		oModel:AddGrid("MdGridDA7F2", "MdFieldCDA7" /*cOwner*/, oStruDA7F2 , /*bLinePre*/ , {|oModel| Oms090LOk2(oModel)} , /*bPre*/ , /*bPost*/,/*bLoad*/)
	EndIf

	oModel:SetRelation( "MdGridDA7F2", { { "DA7_FILIAL", "xFilial('DA7')" }, { "DA7_PERCUR", "DA7_PERCUR" } , { "DA7_ROTA", "DA7_ROTA" } }, DA7->( IndexKey( 1 ) ) )
	oModel:GetModel( "MdGridDA7F2" ):SetLoadFilter( { { 'DA7_CEPDE' , "'      '" , MVC_LOADFILTER_NOT_EQUAL              } , { 'DA7_CEPATE' , "'      '" , MVC_LOADFILTER_NOT_EQUAL } } )
	oModel:GetModel( "MdGridDA7F2" ):SetOptional( .T. )
	oModel:GetModel( "MdGridDA7F2" ):SetMaxLine( 99999 )
	oModel:GetModel( "MdGridDA7F2" ):SetUseOldGrid(.T.)
	oModel:GetModel( "MdGridDA7F2" ):SetUniqueLine( { "DA7_CEPDE", "DA7_CEPATE" } )

	IF !lMile
		oModel:SetVldActivate( { |oModel| Oms090Loc(oModel) } )
		oModel:SetDeActivate( { |oModel| MsUnLockAll() } )
	Endif

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ViewDef  ³ Autor ³ Mauro Paladini        ³ Data ³23.08.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe browse de acordo com a estrutura                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oView do objeto oView                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ViewDef()
Local oModel    := FwLoadModel("OMSA090")
Local oView     := Nil
Local aOpc      := {MODEL_OPERATION_VIEW,MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE,MODEL_OPERATION_DELETE}
Local nI        := 0
Local aAux      := {}
Local aButtons  := { { STR0011 , "WEB" , { || MsgRun(STR0011+"...",,{|| Oms090TOk(oModel), Oms090Mapa(@aAux) }),fGeoMapCli(aAux)} }}//"Mapa da Rota"
// Estrutura de campos do cabecalho
Local oStruCDA7 := FwFormStruct( 2, "DA7", { |cCampo|  AllTrim( cCampo ) + "|" $ "DA7_PERCUR|DA7_ROTA|" } )
Local oStruCDA5 := FwFormStruct( 2, "DA5", { |cCampo|  AllTrim( cCampo ) $ "DA5_DESC" } )
// Estrutura de campos do Grid - Folder 1
Local oStruDA7F1:= FwFormStruct( 2, "DA7", { |cCampo| !(AllTrim( cCampo ) + "|" $ "DA7_PERCUR|DA7_ROTA|DA7_CEPDE|DA7_CEPATE|DA7_PEROBR|") } )
// Estrutura de campos do Grid - Folder 2
Local oStruDA7F2:= FwFormStruct( 2, "DA7", { |cCampo| !(AllTrim( cCampo ) + "|" $ "DA7_PERCUR|DA7_ROTA|DA7_CLIENT|DA7_LOJA|DA7_NOME|") } )

	oStruCDA5:aFields[1,2] := "99" // Deve ficar depois do campo DA7_ROTA para que a consulta padrão funcione corretamente
	Aadd(oStruCDA7:aFields,oStruCDA5:aFields[1])

	oStruCDA7:SetProperty( 'DA7_PERCUR' , MVC_VIEW_CANCHANGE    , INCLUI )
	oStruCDA7:SetProperty( 'DA7_PERCUR' , MVC_VIEW_LOOKUP       , "DA6" )
	oStruCDA7:SetProperty( 'DA7_ROTA'   , MVC_VIEW_CANCHANGE    , INCLUI )
	oStruCDA7:SetProperty( 'DA5_DESC'   , MVC_VIEW_CANCHANGE    , .F. )

	oView := FwFormView():New()
	oView:SetModel(oModel)

	// Adiciona os botoes
	For nI := 1 To Len(aOpc)
		AEval( aButtons, { |x| oView:AddUserButton( x[1], x[2], x[3] ,NIL,NIL, {aOpc[nI]}) } )
	Next nI

	oView:CreateHorizontalBox("SUPERIOR",20)
	oView:CreateHorizontalBox("INFERIOR",80)

	oView:CreateFolder('FOLDER_01',"INFERIOR")
	oView:AddSheet('FOLDER_01','ABA_01', STR0014) //"Clientes "
	oView:AddSheet('FOLDER_01','ABA_02', STR0015 ) //"Codigos de Endereçamento Postal"

	oView:CreateHorizontalBox("PANELFOLDER_01",100,,,'FOLDER_01','ABA_01')
	oView:CreateHorizontalBox("PANELFOLDER_02",100,,,'FOLDER_01','ABA_02')

	oView:AddField('VwFieldCDA7', oStruCDA7 , 'MdFieldCDA7')
	oView:AddGrid( 'VwGridDA7F1', oStruDA7F1 , 'MdGridDA7F1')
	oView:AddGrid( 'VwGridDA7F2', oStruDA7F2 , 'MdGridDA7F2')

	oView:EnableTitleView('VwFieldCDA7',STR0001)

	If lOrdGrid
		oView:SetFieldAction('DA7_SEQUEN', { |oView,cIdForm,cIdCampo,cValue| Oms090Ord(oView,cIdForm,cIdCampo,cValue) } )
	EndIf

	// Cabecalho
	oView:SetOwnerView('VwFieldCDA7',"SUPERIOR")

	// Folder 1 - Clientes
	oView:SetOwnerView('VwGridDA7F1',"PANELFOLDER_01")

	// Folder 2 - Codigos de Enderecamento Postal
	oView:SetOwnerView('VwGridDA7F2',"PANELFOLDER_02")

Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Mauro Paladini        ³ Data ³14.08.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ MenuDef com as rotinas do Browse                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina array com as rotina do MenuDef                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0002    ACTION "PesqBrw"         OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003    ACTION "VIEWDEF.OMSA090" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004    ACTION "VIEWDEF.OMSA090" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.OMSA090" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.OMSA090" OPERATION 5 ACCESS 0 //"Excluir"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("OM090MNU")
		ExecBlock("OM090MNU",.F.,.F.)
	EndIf

Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PosVldMdl ³ Autor ³ Mauro Paladini        ³ Data ³03/09/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da model (compatibilizacao)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPL1 - .T./.F. Logico                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³<oModel>                                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PosVldMdl(oMdl)
Local lRet := .T.

	If oMdl <> Nil
		IF oMdl:GetOperation() == MODEL_OPERATION_INSERT .Or. oMdl:GetOperation() == MODEL_OPERATION_UPDATE
			lRet := Oms090TOk(oMdl)
		Endif
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o     ³ Dl090LOk   ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 24.06.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validações do Grid para o Folder 1 -Clientes                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Dl090Lok()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ DFata10 - Espec¡fico (DISTRIBUIDORES)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Almir Bandina³14.08.99³XXXXXX³Transforma‡Æo de RdMake para Fonte        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Oms090LOk(oModel)
Local aArea      := GetArea()
Local cAlocPer   := SuperGetMv("MV_ALOCPER",.F.,"N")
Local cCliente   := ""
Local cLoja      := ""
Local cRota      := ""
Local cPercur    := ""
Local cAliasDA7  := ""
Local cQuery     := ""
Local lRet       := .T.
Local lMile       := IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT")

	If !lMile

		// Validar campos
		cCliente := FwFldGet("DA7_CLIENT")
		cLoja    := FwFldGet("DA7_LOJA")
		cRota    := FwFldGet("DA7_ROTA")
		cPercur  := FwFldGet("DA7_PERCUR")

		If cAlocPer == "N"
			cQuery := "SELECT DA7_ROTA"
			cQuery += " FROM "+RetSqlName('DA7')+" DA7"
			cQuery += " WHERE DA7_FILIAL = '"+xFilial('DA7')+"'"
			cQuery +=   " AND DA7_CLIENT = '"+cCliente+"'"
			cQuery +=   " AND DA7_LOJA   = '"+cLoja+"'"
			cQuery +=   " AND DA7_PERCUR = '"+cPercur+"'"
			cQuery +=   " AND DA7_ROTA  <> '"+cRota+"'"
			cQuery +=   " AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasDA7 := GetNextAlias()
			dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDA7,.F.,.T.)
			If (cAliasDA7)->(!EoF())
				Help(" ",1,"DS8301042",,DA7->DA7_ROTA,05,30) // "Cliente/Loja já cadastrados neste Setor em outra Zona."
				lRet := .F.
			EndIf
			(cAliasDA7)->(DbCloseArea())
		EndIf

	EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Oms090LOk2³ Autor ³ Marcelo Nunes         ³ Data ³09.08.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Linha da GetDados, grid CEP                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Model                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Oms090LOk2(oModel)
Local lRet  := .T.
Local lMile := IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT")

	If !lMile

		// Validar campos
		cCepDe  := FwFldGet("DA7_CEPDE")
		cCepAte := FwFldGet("DA7_CEPATE")

		If  lRet .And. cCepDe > cCepAte
			Help(" ",1,"OMS090CEPM") // "Cep final deve ser maior que o inicial."
			lRet := .F.
		EndIf

	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o     ³Oms090Cep   ³ Autor ³ Henry Fila            ³ Data ³ 24.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡ao do Cep                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Dl090Lok()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Almir Bandina³14.08.99³XXXXXX³Transforma‡Æo de RdMake para Fonte        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Oms090Cep()
Local cConteudo   := &(ReadVar())
Local cCampo      := ReadVar()
Local lRet        := .T.
Local nX          := 0
Local oModel      := Nil
Local oModelCep   := Nil
Local aSaveLines  := {}
Local nLine       := 0

Local lMile := IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT")

	if !lMile

		oModel     := FWModelActive()
		oModelCep  := oModel:GetModel( "MdGridDA7F2" )
		nLine      := oModelCep:GetLine()

		If cCampo == 'M->DA7_CEPDE'
			If Len(AllTrim(cConteudo)) <> Len(DA7->DA7_CEPDE)
				Return (.F.)
			EndIf
		Else
			If Len(AllTrim(cConteudo)) <> Len(DA7->DA7_CEPATE)
				Return (.F.)
			EndIf
		EndIf

		aSaveLines  := FWSaveRows()
		For nX := 1 To oModelCep:Length()

			oModelCep:GoLine(nX)
			If  nX != nLine .And. !oModelCep:IsDeleted()
				If  cConteudo >= oModelCep:GetValue( "DA7_CEPDE" ) .And. cConteudo <= oModelCep:GetValue( "DA7_CEPATE" )
					Help(" ",1,"OMS090CEPF",, STR0016 + oModelCep:GetValue( "DA7_SEQUEN" ),4,1) //"Cep já cadastrado em um intervalo."
					lRet := .F.
					Exit
				EndIf
			EndIf

		Next nX
		FWRestRows( aSaveLines )
	EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o     ³ D090Cli    ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 21.06.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡ao do Campo DA7_LOJA na GetDados                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ D090Cli()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ .T. - loja v lida                                            ³±±
±±³          ³ .F. - loja inv lida                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function D090Cli()
Local aArea       := GetArea()
Local cCampo      := ReadVar()
Local lRet        := .T.
Local cCliente    := Space(Len(SA1->A1_COD))
Local cLoja       := Space(Len(SA1->A1_LOJA))
Local oModel      := FWModelActive()
Local oModelCab   := oModel:GetModel("MdFieldCDA7")
Local oModelCli   := oModel:GetModel("MdGridDA7F1")


	DbSelectArea("SA1")

	Do Case

		Case cCampo == "M->DA7_CLIENT"

			cCliente := M->DA7_CLIENT
			cLoja    := oModelCli:GetValue( "DA7_LOJA" )

			SA1->(dbSetOrder(1))
			If SA1->(!MsSeek(xFilial("SA1")+cCliente)) .And. Empty(cLoja)
				Help(" ",1,"REGNOIS")
				lRet := .F.
			Else
				If !Empty(cLoja)
					If  SA1->(MsSeek(xFilial("SA1")+cCliente+cLoja))
						lRet := RegistroOk("SA1")
						If lRet .And. oModelCli:GetStruct():HasField("DA7_NOME")
							oModelCli:SetValue( "DA7_NOME" , Padr(SA1->A1_NOME,TamSx3("DA7_NOME")[1] ) )
						EndIf
					EndIf
				EndIf
			EndIf

		Case cCampo == "M->DA7_LOJA"

			cCliente    := oModelCli:GetValue( "DA7_CLIENT" )
			cLoja       := M->DA7_LOJA

			SA1->(dbSetOrder(1))
			If  SA1->(!MsSeek(xFilial("SA1")+cCliente+cLoja))
				lRet := .F.
				Help(" ",1,"REGNOIS")
			Else
				lRet := RegistroOk("SA1")
				If lRet .And. oModelCli:GetStruct():HasField("DA7_NOME")
					oModelCli:SetValue( "DA7_NOME" , Padr(SA1->A1_NOME,TamSx3("DA7_NOME")[1] ) )
				EndIf
			EndIf

	EndCase

	If lRet
		//-- Busca o setor do cliente cadastrado.
		DA6->(dbSetOrder(1))
		If DA6->(MsSeek(xFilial("DA6")+ oModelCab:GetValue( "DA7_PERCUR" ) + oModelCab:GetValue( "DA7_ROTA" ) ))
			If !Empty(DA6->DA6_CODCAL)
				//-- Busca se existe regras de entrega com calendario para o cliente.
				DAD->(dbSetOrder(2))
				If DAD->(!MsSeek(xFilial("DAD")+Space(Len(SA1->A1_GRPVEN))+cCliente+cLoja))
					DAD->(MsSeek(xFilial("DAD")+SA1->A1_GRPVEN+Space(Len(SA1->A1_COD))+Space(Len(SA1->A1_LOJA))))
				EndIf
				If DAD->(Found())
					DAE->(dbSetOrder(1))
					If  DAE->(MsSeek(xFilial("DAE")+DAD->DAD_CODIGO))
						While DAE->(!Eof()) .And.   DAE->DAE_FILIAL == xFilial("DAE") .And.;
													DAE->DAE_CODIGO == DAD->DAD_CODIGO .And. lRet
							//-- Nao valida caso o calendario do setor seja incompativel.
							lRet := OmsVldCal(DA6->DA6_CODCAL,DAE->DAE_CODCAL)
							If !lRet
								Help(" ",1,"OMS080CAL") //"Existem dias incompatíveis com o calendário associado a zona."d
								Exit
							EndIf
							DAE->(dbSkip())
						EndDo
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o     ³ D090Seq    ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 21.06.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializador Padrao do N£mero da sequencia Entrega          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ D090Seq()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nNumSeq - n£mero da pr¢xima sequencia de entrega             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function D090Seq()
Local oView
Local aFolders
Local nFolder
Local oModel
Local cGridAtu
Local oModelAtu
Local aHeader
Local nTamCpo := TamSx3("DA7_SEQUEN")[1]
Local nPosSeq
Local nNumSeq := 0
Local nY      := 0
Local nI          := 0
Local aSaveLines  := {}
Local lMile       := IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT")

	if !lMile .And. (oView  := FwViewActive()) <> Nil

		aFolders    := oView:GetFolderActive("FOLDER_01",2)
		nFolder     := IIF( Len(aFolders) == 0 , 0 , aFolders[1] ) // 1-Retorna o ID do folder, 2-Retorna o titulo do folder.

		oModel      := FWModelActive()
		cGridAtu    := IIF( nFolder > 0 , "MdGridDA7F" + Str(nFolder,1) , "" )
		oModelAtu   := IIF( nFolder > 0 , oModel:GetModel( cGridAtu ) , "" )
		aHeader     := IIF( nFolder > 0 , aClone(oModelAtu:aHeader) , {} )

		//nTamCpo := TamSx3("DA7_SEQUEN")[1]
		nPosSeq := aScan(aHeader,{|x| Alltrim(x[2]) == "DA7_SEQUEN"})

		If nFolder > 0

			aSaveLines := FWSaveRows()

			For nY := 1 To oModelAtu:Length()

				oModelAtu:GoLine(nY)

				If !oModelAtu:IsDeleted()

					If  Val(oModel:GetValue( cGridAtu , "DA7_SEQUEN" )) > nNumSeq
						nNumSeq := Val(oModel:GetValue( cGridAtu , "DA7_SEQUEN" ))
					EndIf

				EndIf

			Next nY

			FWRestRows( aSaveLines )

		Endif

	Endif

Return(StrZero(nNumSeq+1,nTamCpo))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ D090Ordem  ³ Autor ³ Marcos Cesar        ³ Data ³ 21/07/1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gatilho do campo N£mero da sequencia Entrega                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA090 - Pontor por Setor                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function D090Ordem()
Local oView
Local aFolders
Local nFolder
Local oModel
Local cGridAtu
Local oModelAtu
Local aHeader
Local nTamCpo
Local nPosSeq
Local cNumSeq
Local nNumSeq
Local lMile         := IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT")

	if !lMile .And. (oView  := FwViewActive()) <> Nil

		aFolders    := oView:GetFolderActive("FOLDER_01",2)
		nFolder     := IIF( Len(aFolders) == 0 , 0 , aFolders[1] ) // 1-Retorna o ID do folder, 2-Retorna o titulo do folder.

		oModel      := FWModelActive()
		cGridAtu    := IIF( nFolder > 0 , "MdGridDA7F" + Str(nFolder,1) , "" )
		oModelAtu   := IIF( nFolder > 0 , oModel:GetModel( cGridAtu ) , "" )
		aHeader := aClone(oModelAtu)

		nTamCpo     := TamSx3("DA7_SEQUEN")[1]
		nPosSeq     := aScan(aHeader,{|x| Alltrim(x[2]) == "DA7_SEQUEN"})
		cNumSeq     := &(ReadVar())
		nNumSeq     := 0
		//-- Verifica tamanho do campo Sequencia
		If  Len(Trim(cNumSeq)) < nTamCpo
			nNumSeq := Val(cNumSeq)
			cNumSeq := StrZero(nNumSeq,nTamCpo)
			//-- Grava no Array o Numero informado pelo usuario.
			oModel:SetValue( cGridAtu , "DA7_SEQUEN" , cNumSeq )
		EndIf

	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ D090Ordem  ³ Autor ³ Vicco               ³ Data ³ 25/03/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reordena a sequencia de entrega de todos os Pontos, caso     ³±±
±±³          ³ a sequencia informada coincida com a de outro cliente.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA090 - Pontor por Setor                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function D090Reord()
Local oView     := FwViewActive()
Local aFolders  := oView:GetFolderActive("FOLDER_01",2)
Local nFolder   := IIF( Len(aFolders) == 0 , 0 , aFolders[1] ) // 1-Retorna o ID do folder, 2-Retorna o titulo do folder.
Local oModel    := FWModelActive()
Local cGridAtu  := IIF( nFolder > 0 , "MdGridDA7F" + Str(nFolder,1) , "" )
Local oModelAtu := IIF( nFolder > 0 , oModel:GetModel( cGridAtu ) , "" )
Local aArea      := GetArea()
Local aColsTrab  := {}
Local nPosCepDe  := 0
Local nPosCepAte := 0
Local nPosSequen := 0
Local nPosCliente:= 0
Local nPosLoja   := 0
Local nX         := 0
Local cCliente   := ""
Local cLoja      := ""
Local cCepDe     := ""
Local cCepAte    := ""
Local nLinAtu    := 0

Private aHeader := aClone(oModelAtu:aHeader)
Private aCols   := aClone(oModelAtu:aCols)

	If nFolder == 1
		//-- Verifica a Posicao dos Campos no aCols.
		nPosSequen := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA7_SEQUEN"})
		nPosCliente:= Ascan(aHeader,{|x| Alltrim(x[2]) == "DA7_CLIENT"})
		nPosLoja   := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA7_LOJA"})
		//-- Armazena o Cliente/Loja do Elemento do aCols. Sera usado p/
		//-- identificar qual o elemento que teve a Sequencia alterada.
		cCliente   := GdFieldGet("DA7_CLIENT")
		cLoja      := GdFieldGet("DA7_LOJA")
	Else
		nPosSequen := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA7_SEQUEN"})
		nPosCepDe  := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA7_CEPDE"})
		nPosCepAte := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA7_CEPATE"})
		cCepDe     := GdFieldGet("DA7_CEPDE")
		cCepAte    := GdFieldGet("DA7_CEPATE")
	EndIf

	If nFolder == 1

		//Copia aCols que contém os registros do modelo
		aColsTrab  := Aclone(aCols)

		//Inclui uma nova linha no array aCols, que indica a linha do modelo de dados
		AEval( aColsTrab, { |aArray,nLinha| AADD(aArray,nLinha) } )

		// Ordena pela sequência
		Asort(aColsTrab,,, {|x,y| x[nPosSequen] < y[nPosSequen]})

		// Corrige os intervalos da sequência
		D090RfzSeq(aColsTrab, nPosSequen)

		//Guarda informação da linha posicionada
		nLinAtu := oModelAtu:GetLine()

		//Ajusta sequência na grid do modelo
		//Altera até mesmo os deletados, para caso ocorra recuperação de linha
		AEval(aColsTrab,{|aArray,nLinha| oModelAtu:GoLine(aArray[Len(aArray)]), oModel:LoadValue(cGridAtu, "DA7_SEQUEN", aArray[nPosSequen])})

		//Restaura linha posicionada
		oModelAtu:GoLine(nLinAtu)
	EndIf

	oView:Refresh()

RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ D90Ordem2 ³ Autor ³ Alex Amaral         ³ Data ³ 12/06/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reordena a sequencia de entrega por cep de todos os Pontos,  ³±±
±±³          ³caso a sequencia informada coincida com a de outro cliente.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA090 - Pontor por Setor Aba Cep                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function D90Reord2()
Local oView         := FwViewActive()
Local oModel        := FWModelActive()
Local cGridAtu  := "MdGridDA7F2"
Local oModelAtu := oModel:GetModel( cGridAtu )
Local aArea      := GetArea()
Local aColsTrab2 := {}
Local aHeaderCEP := oModel:GetModel("MdGridDA7F2"):aHeader
Local aColsCEP   := oModel:GetModel("MdGridDA7F2"):aCols
Local nUsado     := 0
Local nPosCepDe  := 0
Local nPosCepAte := 0
Local nPosSequen := 0
Local nA         := 0
Local nX         := 0
Local cSequencia := ""
Local cCepDe     := ""
Local cCepAte    := ""
Local lSeqAlt    := .F.
Local aColsBkp2  := {}

	//-- Backup aColsCep
	aColsTrab2  := Aclone(aColsCEP)

	nPosSequen := Ascan(aHeaderCEP,{|x| Alltrim(x[2]) == "DA7_SEQUEN"})
	nPosCepDe  := Ascan(aHeaderCEP,{|x| Alltrim(x[2]) == "DA7_CEPDE"})
	nPosCepAte := Ascan(aHeaderCEP,{|x| Alltrim(x[2]) == "DA7_CEPATE"})
	cCepDe     := FwFldGet("DA7_CEPDE")
	cCepAte    := FwFldGet("DA7_CEPATE")
	nUsado     := Len(aHeaderCEP)

	//-- Sequencia alterada.
	cSequencia := FwFldGet("DA7_SEQUEN")

	//-- Ordena o Array de Trabalho pela Sequencia.
	Asort(aColsTrab2,,, {|x,y| x[nPosSequen] < y[nPosSequen]})
	D090RfzSeq(aColsTrab2,nPosSequen)

	//--> Faz back da aCols Original
	aColsBkp2 := aClone(aColsCEP)

	//-- Atualiza o Array.
	aColsCEP := aClone(aColsTrab2)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o Grid em MVC           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLinAtu := oModelAtu:GetLine()

	For nA := 1 To Len(aColsCEP)

		oModelAtu:GoLine(nA)

		lSeqAlt := .T.
		//--> Será validado o conteudo da aCols reoganizada com a aCols Original, para verificar se teve alteração do número da sequencia.
			If aColsBkp2[nA,nPosCepDe] == aColsTrab2[nA,nPosCepDe] .And. aColsBkp2[nA,nPosCepAte] == aColsTrab2[nA,nPosCepAte]
				lSeqAlt := .F.
			EndIf

			If !lSeqAlt //--> Caso o numero da sequencia tenha sido alterado, não verificará se a linha da aCols foi alterado utilizando os comandos do MVC IsUpdated() e IsInserted().
				If oModelAtu:IsUpdated() .Or. oModelAtu:IsInserted()
					For nX := 2 To Len(aHeaderCEP)
						oModel:LoadValue( cGridAtu , aHeaderCEP[nX,2] , aColsCEP[nA,nX] )
					Next nX
				EndIf
			Else
				For nX := 2 To Len(aHeaderCEP)
					oModel:LoadValue( cGridAtu , aHeaderCEP[nX,2] , aColsCEP[nA,nX] )
				Next nX
			EndIf
	Next nA

	oModelAtu:GoLine(nLinAtu)
	oView:Refresh("VwGridDA7F2")

RestArea(aArea)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OMSA090VLD ºAutor  ³Microsiga           º Data ³  04/24/01  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o setor digitado                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 := Zona                                              º±±
±±º          ³ ExpC2 := Setor                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Oms090Vld()
Local oModel
Local oModelCab
Local cZona
Local cSetor
Local lRet      := .T.
Local aArea     := GetArea()
Local lMile  := IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT")

	If !lMile
		oModel    := FWModelActive()
		oModelCab := oModel:GetModel("MdFieldCDA7")
		cZona     := oModelCab:GetValue( "DA7_PERCUR" )
		cSetor    := oModelCab:GetValue( "DA7_ROTA" )
		//-- Verifica a zona e setor ja estao cadastrados no DA7.
		If Empty(cZona) .And. !Empty(cSetor)
			Help(" ",1,"OBRIGAT")
			lRet := .F.
		EndIf

		If lRet .And. !Empty(cZona) .And. !Empty(cSetor)
			DA7->(dbSetOrder(1)) //DA7_FILIAL+DA7_PERCUR+DA7_ROTA+DA7_SEQUEN
			If DA7->(MsSeek(xFilial("DA7")+cZona+cSetor))
				Help(" ",1,"OMS090ZONA") //"Zona ja existe no cadastro de clientes por setor."
				lRet := .F.
			EndIf
		EndIf

		//-- Verifica se zona e setor sao correspondentes.
		If lRet .And. !Empty(cZona) .And. !Empty(cSetor)
			DA6->(dbSetOrder(1))
			If DA6->(MsSeek(xFilial("DA6")+cZona+cSetor))
				IF !Empty(DA6->DA6_REF)
					oModelCab:SetValue( "DA5_DESC" , Padr(DA6->DA6_REF,TamSx3("DA5_DESC")[1] ) )
				Else
					oModelCab:SetValue( "DA5_DESC", STR0019)//"Ponto Referência não definido"
				EndIf
			Else
				Help(" ",1,"OMS090SETO") //"Zona e setores nao correspondentes."
				lRet := .F.
			EndIf
		EndIf
	EndIf

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Oms341TOk ºAutor  ³Henry Fila          º Data ³  09/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida os campos obrigtorios                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cExp1 : Setor                                              º±±
±±º          ³ cExp2 := Zona                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Oms090TOk( oModel )
Local lRet      := .T.
Local lRetPe    := .T.
Local cZona     := oModel:GetValue( "MdFieldCDA7" , "DA7_PERCUR" )
Local cSetor    := oModel:GetValue( "MdFieldCDA7" , "DA7_ROTA" )
Local cCliente  := oModel:GetValue( "MdGridDA7F1" , "DA7_CLIENT" )
Local cLoja     := oModel:GetValue( "MdGridDA7F1" , "DA7_LOJA" )
Local cCepDe    := oModel:GetValue( "MdGridDA7F2" , "DA7_CEPDE" )
Local cCepAte   := oModel:GetValue( "MdGridDA7F2" , "DA7_CEPATE" )

	If  lRet .And. ExistBlock("OM090TOK")
		lRetPE := ExecBlock("OM090TOK",.F.,.F.)
		lRet   := If(ValType(lRetPE)=="L",lRetPE,lRet)
	EndIf

	If  lRet .And. Empty(cZona).Or. Empty(cSetor)
		Help(" ",1,"OBRIGAT")
		lRet := .F.
	EndIf

	// Valida a digitacao de pelo menos um folder
	If Empty(cCliente) .And. Empty(cLoja) .And. Empty(cCepDe) .And. Empty(cCepAte)
		Help(" ",1,"OBRIGAT")
		lRet := .F.
	Endif

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Oms090Mapa³ Autor ³ Eduardo Riera         ³ Data ³26.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina Geoprocessamento dos pontos na rota                   ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: aHeader da getdados de clientes                       ³±±
±±³          ³ExpA2: aCols da getdados de clientes                         ³±±
±±³          ³ExpA3: aHeader da getdados de CEP                            ³±±
±±³          ³ExpA4: aCols da getdados de CEP                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA5: Array com os códigos dos clientes                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo verificar os clientes que estao³±±
±±³          ³geocodificados.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms090Mapa( aCodCli )

Local aArea    := GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local nX       := 0

Local oModel    := FWModelActive()

Local aCols     := oModel:GetModel("MdGridDA7F1"):aCols
Local aHeader   := oModel:GetModel("MdGridDA7F1"):aHeader
Local nUsado1   := Len(aHeader)

Local aCols2    := oModel:GetModel("MdGridDA7F2"):aCols
Local aHeader2  := oModel:GetModel("MdGridDA7F2"):aHeader
Local nUsado2   := Len(aHeader2)

Local nPCli     := aScan( oModel:GetModel("MdGridDA7F1"):aHeader ,{|x| AllTrim(x[2]) == "DA7_CLIENT"})
Local nPLoja    := aScan( oModel:GetModel("MdGridDA7F1"):aHeader ,{|x| AllTrim(x[2]) == "DA7_LOJA"})
Local nPCep1    := aScan( oModel:GetModel("MdGridDA7F2"):aHeader ,{|x| AllTrim(x[2]) == "DA7_CEPDE"})
Local nPCep2    := aScan( oModel:GetModel("MdGridDA7F2"):aHeader ,{|x| AllTrim(x[2]) == "DA7_CEPATE"})

Local cQuery    := ""
Local cAux      := ""
Local cAliasSA1 := "SA1"

Default aCodCli  := {}

	//-- Verifica os clientes assinalados como ptos de entrega.
	If  nPCli <> 0 .And. nPLoja <> 0
		For nX := 1 To Len(aCols)
			If !aCols[nX][nUsado1+1]
				aadd(aCodCli,{aCols[nX][nPCli],aCols[nX][nPLoja]})
			EndIf
		Next nX
	EndIf

	//-- Verifica os clientes assinalados por CEP
	cAliasSA1 := "OMSA090"
	cQuery    := "SELECT A1_COD,A1_LOJA "
	cQuery    += "FROM "+RetSqlName("SA1")+" SA1 "
	cQuery    += "WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND "
	For nX := 1 To Len(aCols2)
		If !aCols2[nX][nUsado2+1]
			cAux += "OR (SA1.A1_CEP >= '"+aCols2[nX][nPCep1]+"' AND SA1.A1_CEP <= '"+aCols2[nX][nPCep2]+"') "
		EndIf
	Next nX
	If Len(cAux)>0
		cQuery += "("+SubStr(cAux,3)+") AND "
		cQuery += "SA1.D_E_L_E_T_ = ' ' "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA1)
		While !Eof()
			If aScan(aCodCli,{|x| x[1] == (cAliasSA1)->A1_COD .And. x[2]==(cAliasSA1)->A1_LOJA})==0
				aadd(aCodCli,{(cAliasSA1)->A1_COD,(cAliasSA1)->A1_LOJA})
			EndIf
			dbSkip()
		EndDo
		(cAliasSA1)->(dbCloseArea())
		dbSelectArea("SA1")
	EndIf

RestArea(aAreaSA1)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Oms090Loc ³ Autor ³ Mauro Paadini         ³ Data ³03/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se eh possivel realizar o Lock dos registros         ³±±
±±³          ³Conversao para o padrao MVC                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Tipo de operacao (inclusao, alteracao, etc)          ³±±
±±³          ³ExpL2: Verifica se travou DA7                               ³±±
±±³          ³ExpN3: 1=Folder Clientes   2=Folder CEP                     ³±±
±±³          ³ExpA4: Array com registros da Folder "Clientes"             ³±±
±±³          ³ExpA5: Array com registros da Folder "CEP"                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms090Loc(oModel)
Local lRet      := .T.
Local aDA7Area  := DA7->( GetArea() )
Local cZona     := DA7->DA7_PERCUR
Local cSetor    := DA7->DA7_ROTA

	IF !oModel:GetOperation() == MODEL_OPERATION_DELETE .And. !oModel:GetOperation() == MODEL_OPERATION_UPDATE
		Return .T.
	Endif

	DA7->( DbSetOrder(1) )
	IF DA7->( DbSeek( xFilial("DA7") + cZona + cSetor ) )

		While DA7->( !Eof() .And.  DA7_FILIAL+DA7_PERCUR+DA7_ROTA == xFilial("DA7") + cZona + cSetor .And. lRet )

			If !( SoftLock("DA7" ) )
				lRet := .F.
			Endif
			DA7->( DbSkip() )

		End

	Endif

	If !lRet
		DA7->( MsUnLockAll() )
	Endif

	RestArea(aDA7Area)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³D090RfzSeq ºAutor  ³Marcelo Nunes       º Data ³  15/06/16  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Marcelo Nunes                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aColsDA7 = array com dados da DA7                          º±±
±±             nPosSeq = posicao do campo sequencia no array              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function D090RfzSeq(aColsDA7,nPosSeq)
Local nContSeq
Local nTamSeq := TamSx3("DA7_SEQUEN")[1]

	For nContSeq := 1 To Len(aColsDA7)
		aColsDA7[nContSeq][nPosSeq] := StrZero(nContSeq,nTamSeq)
	Next nContSeq

Return nil

/*/-----------------------------------------------------------
{Protheus.doc} PreVldMdl
Pré-valida a Linha do grid

@sample
//PreVldMdl(oModelGrid,nLine,cAction)

@author Felipe Marques Barbieri
@since 18/11/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function PreVldMdl(oModelGrid,nLine,cAction)
Local lRet  := .T. // Recebe o Retorno
Local oView := FwViewActive() // Recebe a View Ativa

	oModelGrid:GoLine(nLine)

	If cAction == 'DELETE' // Reordenação quando linha estiver sendo excluida
		TMSOrdDel(oView,oModelGrid,"DA7_SEQUEN",nLine,.F.)
	ElseIf cAction == 'UNDELETE'   // Reordenação quando linha estiver sendo Recuperada
		TMSOrdDel(oView,oModelGrid,"DA7_SEQUEN",nLine,.T.)
	EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} Oms090Ord
Realiza a Reordenação do Grid de Roteiros

@sample
//Af012Reord(oView,cIdForm,cIdCampo,cValue)

@author Felipe Marques Barbieri
@since 18/11/2016
@version 1.0
-----------------------------------------------------------/*/
Function Oms090Ord(oView,cIdForm,cIdCampo,cValue)
Local aArea      := GetArea()      // Recebe a Area Atual
Local oModel     := NIL            // Recebe o modelo
Local nLine

Default oView    := FwViewActive() // Recebe a View ativa
Default cIdForm  := ""             // Recebe o Id do formulario
Default cIdCampo := ""             // Recebe o Id do Campo
Default cValue   := ""             // Recebe o valor do campo

	// Monta o objeto do ModelGrid
	oModel := oView:GetModel()
	oViewObj := oView:GetViewObj(cIdForm)
	oModelGrid := oModel:GetModel( oViewObj[6] )
	nLine := oModelGrid:GetLine()

	// Chama a Função de Reordenação
	TMSOrdGrd(oView,oModelGrid,cIdForm,cIdCampo,cValue)

	 //Atualiza a tela
	oView:Refresh(cIdForm) //Atualiza a tela
	oView:GoLine(oModelGrid:getId(),nLine)

RestArea(aArea)
Return

/*/-----------------------------------------------------------
{Protheus.doc} ValidField
Regra de validação dos campos

@author  Amanda Rosa Vieira
@since   04/01/2018
@version 1.0
-----------------------------------------------------------/*/
Static Function ValidField(oModel,cField)
Local lRet := .T.
	If cField == "DA7_SEQUEN"
		//Reordena a sequencia de entrega do Folder 1 -Clientes
		If (lRet := D090Ordem()) .And. !lOrdGrid
			If oModel:GetId() == "MdGridDA7F1"
				lRet := D090Reord()
			Else
				lRet := D90Reord2()
			EndIf
		EndIf
	EndIf
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} GetDesField
Retorna o nome do cliente para o Grid
@author  Wander Horongoso
@since   03/03/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function GetDesField(oModel,cField)
Local nLinha := oModel:GetQtdLine()
Local cRet   := ""
	
	// Impede que a descrição apareça na inclusão de itens durante a alteração
	If nLinha == 0 .And. !Inclui .And. cField == "DA7_NOME" 
		DbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+DA7->DA7_CLIENT+DA7->DA7_LOJA))
		cRet := SA1->A1_NOME
	EndIf
Return cRet
