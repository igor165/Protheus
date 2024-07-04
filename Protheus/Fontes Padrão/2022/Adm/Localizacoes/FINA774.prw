//Bibliotecas 
#Include 'Protheus.ch'    
#Include 'FWMVCDef.ch'
#Include "ARGWSLPEG.CH"
 
//Variáveis Estáticas
Static cTitulo := STR0108
 
/*/{Protheus.doc} fina774
Função para cadastro de Contas correntes AFIP (Exemplo de Modelo 3 - FVS x FVT)
@author TOTVS
@since 03/09/2016
@version 1.0
    @return Nil, Função não tem retorno
    @example
    u_fina774()
/*/
 
Function fina774()
    Local aArea   := GetArea()
    Local oBrowse
    Private aRetLin	:= {}
     
	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()
     
	//Setando a tabela de cadastro de Conta Corrente
	oBrowse:SetAlias("FVS")
 
	//Setando a descrição da rotina
	oBrowse:SetDescription("Conta Corrente")
    
	oBrowse:AddLegend( "FVS_STATUS == '1'" ,"RED", "Pendiente" )//Pendiente
	oBrowse:AddLegend( "FVS_STATUS == '2'", "BLACK", "Rechazo AFIP" )//rejeitado
	oBrowse:AddLegend( "FVS_STATUS == '3'", "ORANGE", "Rechazo Autorizado" )//Rechazo autorizado
	oBrowse:AddLegend( "FVS_STATUS == '4'", "GREEN", "Acepte Autorizado" )//Aceite autorizado
	oBrowse:AddLegend( "FVS_STATUS == '5'", "BLUE", "Cuenta Corriente Cerrada" )//Cuenta Corriente Cerrada
   
	oBrowse:Activate()
	RestArea(aArea)
	
Return Nil
 
/*---------------------------------------*
 | Func:  MenuDef                        |
 | Autor: TOTVS                          |
 | Data:  03/09/2016                     |
 | Desc:  Criação do menu MVC            |
 *--------------------------------------*/
 
Static Function MenuDef()
    Local aRot  := {}
    Local aRot1 := {}
    //Adicionando opções

	ADD OPTION aRot TITLE 'Rechazo Deb/Cred' ACTION 'VIEWDEF.fina774'  OPERATION 4 ACCESS 0 //Alterar 
	ADD OPTION aRot TITLE 'Rechazo Total'     ACTION 'TrfRchz' OPERATION 2 ACCESS 0 //Rechazar Conta Corrente AFIP -- 'TrfRchz'
	ADD OPTION aRot TITLE 'Visualizar'  ACTION 'VIEWDEF.fina774'  OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRot TITLE 'Legenda'     ACTION 'TLeg001()' OPERATION 2 ACCESS 0 //Browse com as cores da legenda

Return aRot
 
/*---------------------------------------*
 | Func:  ModelDef                       |
 | Autor: TOTVS                          |
 | Data:  03/09/2016                     |
 | Desc:  Criação do modelo de dados MVC |
 *--------------------------------------*/
 
Static Function ModelDef()
    Local oModel       := Nil
    Local oStPai       := FWFormStruct(1, 'FVS')
    Local oStFilho     := FWFormStruct(1, 'FVT')
     
	oStFilho:AddField(            ;		// Ord. Tipo Desc.
		AllTrim( 'Legenda' )    , ;     // [01]  C   Titulo do campo
		AllTrim( 'Legenda' )    , ;     // [02]  C   ToolTip do campo
		'FVT_LEGEND'            , ;     // [03]  C   I5d
		'C'                     , ;     // [04]  C   Tipo do campo
		15                      , ;     // [05]  N   Tamanho do campo
		0                       , ;     // [06]  N   Decimal do campo
		NIL						, ;    	// [07]  B   Code-block de validação do campo
		NIL                     , ;     // [08]  B   Code-block de validação When do campo
		NIL		                , ;     // [09]  A   Lista de valores permitido do campo
		NIL                     , ;     // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'LegFVT()' ), ;     // [11]  B   Code-block de inicializacao do campo
		NIL                     , ;     // [12]  L   Indica se trata-se de um campo chave
		NIL                     , ;     // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                       )     // [14]  L   Indica se o campo é virtual     

	//Definições dos campos
	
	oStPai:SetProperty('FVS_CODCC',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStPai:SetProperty('FVS_TIPO',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStPai:SetProperty('FVS_CODIGO',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStPai:SetProperty('FVS_LOJA',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStPai:SetProperty('FVS_DESC',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStPai:SetProperty('FVS_DTCRIA',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStPai:SetProperty('FVS_MOEDA',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStPai:SetProperty('FVS_VLTOT',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStPai:SetProperty('FVS_STATUS',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStPai:SetProperty('FVS_PREOP',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição 
	oStPai:SetProperty('FVS_DTACRC',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStPai:SetProperty('FVS_OP',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStPai:SetProperty('FVS_DTOP',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição 
	oStPai:SetProperty('FVS_OPCTRF',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))								 //Modo de Edição 

	// oStPai:SetProperty('FVT_NUMCC',    MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("FVS", "XX_NUMCC")'))       //Ini Padrão
	oStFilho:SetProperty('FVT_CODCC',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStFilho:SetProperty('FVT_TIPO',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStFilho:SetProperty('FVT_CODIGO',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStFilho:SetProperty('FVT_LOJA',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStFilho:SetProperty('FVT_ESPECI',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStFilho:SetProperty('FVT_SERIE',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStFilho:SetProperty('FVT_DOC',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStFilho:SetProperty('FVT_EMIS',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStFilho:SetProperty('FVT_DTAFIP',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStFilho:SetProperty('FVT_VALOR',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStFilho:SetProperty('FVT_STATUS',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	//Criando o modelo e os relacionamentos
	
	oModel := MPFormModel():New('fina774')
	oModel:AddFields('FVSMASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('FVTDETAIL','FVSMASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner
	oModel:GetModel('FVTDETAIL'):SetOptional(.T.)
	oModel:GetModel('FVTDETAIL'):SetUniqueLine({"FVT_CODCC","FVT_CODIGO","FVT_LOJA","FVT_ESPECI","FVT_SERIE","FVT_DOC"}) // Campos que não podem se repetir no Grid
	oModel:GetModel('FVTDETAIL'):SetNoInsertLine( .T. )

	//Setando as descrições
	oModel:SetDescription("Cadastro de Conta Corrente")
	oModel:GetModel('FVSMASTER'):SetDescription('Cc')
	oModel:GetModel('FVTDETAIL'):SetDescription('Itens')

	oModel:SetRelation('FVTDETAIL', {{'FVT_FILIAL',"xFilial('FVT')"},{'FVT_CODCC', 'FVS_CODCC'}}, FVT->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('FVSMASTER'):SetPrimaryKey({"FVS_CODCC"})
	
	oModel:SetVldActivate({|oModel|ConsCC(oModel) })

Return oModel
 
/*---------------------------------------*
 | Func:  ViewDef                        |
 | Autor: TOTVS                          |
 | Data:  03/09/2016                     |
 | Desc:  Criação da visão MVC           |
 *--------------------------------------*/
 
Static Function ViewDef()
    Local oView		:= Nil
    Local oModel		:= FWLoadModel('fina774')
    Local oStPai		:= FWFormStruct(2, 'FVS')
    Local oStFilho	:= FWFormStruct(2, 'FVT')
    Local lOk			:= .T.
     
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
     
	oStFilho:AddField( ;                         // Ord. Tipo Desc.
	'FVT_LEGEND'                       	, ;      // [01]  C   Nome do Campo
	'01'                             	, ;      // [02]  C   Ordem
	AllTrim( 'Legenda' )          		, ;      // [03]  C   Titulo do campo
	AllTrim( 'Legenda' )       			, ;      // [04]  C   Descricao do campo
	{ 'Legenda' } 						, ;      // [05]  A   Array com Help
	'C'                                	, ;      // [06]  C   Tipo do campo
	'@BMP'                              , ;      // [07]  C   Picture
	NIL                                	, ;      // [08]  B   Bloco de Picture Var
	''                                 	, ;      // [09]  C   Consulta F3
	.F.                                	, ;      // [10]  L   Indica se o campo é alteravel
	NIL                                	, ;      // [11]  C   Pasta do campo
	NIL                                	, ;      // [12]  C   Agrupamento do campo
	NIL				                  	, ;      // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                                	, ;      // [14]  N   Tamanho maximo da maior opção do combo
	Nil 								, ;      // [15]  C   Inicializador de Browse                  
	.T.                                	, ;      // [16]  L   Indica se o campo é virtual
	NIL                                	, ;      // [17]  C   Picture Variavel
	NIL                                   )      // [18]  L   Indica pulo de linha após o campo
    
    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField('VIEW_FVS',oStPai,'FVSMASTER')
    oView:AddGrid('VIEW_FVT',oStFilho,'FVTDETAIL')
     
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',30)
    oView:CreateHorizontalBox('GRID',70)
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_FVS','CABEC')
    oView:SetOwnerView('VIEW_FVT','GRID')
     
    //Habilitando título
    oView:EnableTitleView('VIEW_FVS','CC')
    oView:EnableTitleView('VIEW_FVT','ITENS')
    lOk := .F.
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||lOk})

	//Cria botões
	oView:AddUserButton( 'Associar C.C.', 'C.Custo', {|oView| DEBUGTE()} )
	oView:AddUserButton( 'Transmission ', 'CLIPS', {|oView| RetLinGrd(oModel),oView:Refresh()} )
	oView:AddUserButton( 'Legenda ', 'CLIPS', {|oView| LegFeCred() } )

Return oView

 
/*/{Protheus.doc} zIniMus
Função que inicia o código sequencial da grid
@type function
@author Atilio
@since 03/09/2016
@version 1.0
/*/
 
User Function zIniMus()
    Local aArea := GetArea()
    Local cCod  := StrTran(Space(TamSX3('FVS_CODCC')[1]), ' ', '0')
    Local oModelPad  := FWModelActive()
    Local oModelGrid := oModelPad:GetModel('FVTDETAIL')
    Local nOperacao  := oModelPad:nOperation
    Local nLinAtu    := oModelGrid:nLine
    Local nPosCod    := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("FVS_CODCC")})
     
    //Se for a primeira linha
    If nLinAtu < 1
        cCod := Soma1(cCod)
     
    //Senão, pega o valor da última linha
    Else
        cCod := oModelGrid:aCols[nLinAtu][nPosCod]
        cCod := Soma1(cCod)
    EndIf
     
    RestArea(aArea)
Return cCod

FUNCTION DEBUGTE()
	
	LOCAL TESTE:=1
	LOCAL TESTE1:=2

return()


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Função    ³LegFeCred³    Autor  ³ Danilo Santos      ³ Data ³03/09/2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina monta uma dialog com a descricao das cores da    ³±±
±±³          ³Mbrowse.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/
Static function LegFeCred() 

Local aLegenda := {}				

aCores :=	{{"FVS_STATUS =='1'",'BR_VERMELHO'},;	//Pendiente
			 {"FVS_STATUS =='2'",'BR_PRETO'},;		//Rechazo AFIP
			 {"FVS_STATUS =='3'",'BR_LARANJA'},;	//Rechazo Autorizado
			 {"FVS_STATUS =='4'",'BR_VERDE'},;		//Acepte Autorizado
			 {"FVS_STATUS =='5'",'BR_AZUL'}}		//Cuenta Corriente Cerrada
			 
	Aadd(aLegenda, {"BR_VERMELHO"   ,"Pendiente"})			//Pendiente
	Aadd(aLegenda, {"BR_PRETO"   ,"Rechazo AFIP"})	// Rechazo no Aceptado
	Aadd(aLegenda, {"BR_LARANJA"  ,"Rechazo Autorizado"})	// Rechazo Autorizado
	Aadd(aLegenda, {"BR_VERDE"  ,"Acepte Autorizado"})		//Acepte Autorizado
	Aadd(aLegenda, {"BR_AZUL"  ,"Cuenta Corriente Cerrada"})//Cuenta Corriente Cerrada
	BrwLegenda("Cadastro conta corrente","TESTE",aLegenda)  

Return

Function TLeg001()

	// Cria a legenda que identifica a estrutura
	oLegend := FWLegend():New()

	// Adiciona descrição para cada legenda
	oLegend:Add( { || }, 'BR_VERMELHO' , 'Pendiente' ) // 'Pendiente'
	oLegend:Add( { || }, 'BR_LARANJA'   , 'Rechazo Autorizado' ) // 'Em Aberto'
	oLegend:Add( { || }, 'BR_PRETO' , 'Rechazo AFIP' ) // 'Baixado'
	oLegend:Add( { || }, 'BR_VERDE' , 'Acepte Autorizado' ) // 'Baixado'
	oLegend:Add( { || }, 'BR_AZUL' , 'Cuenta Corriente Cerrada' ) // 'Cuenta Corriente Cerrada'

	// Ativa a Legenda
	oLegend:Activate()

	// Exibe a Tela de Legendas
	oLegend:View()

Return Nil

Function LegFVT(cStatus)

	Local cRet := ""
	Default cStatus := ""
	
	If FVT->FVT_STATUS == "1" .Or. cStatus == "1"
		cRet := "BR_VERMELHO"
	ElseIf FVT->FVT_STATUS == "2" .Or. cStatus == "2"
		cRet := "BR_PRETO"
	ElseIf FVT->FVT_STATUS == "3" .Or. cStatus == "3"
		cRet := "BR_LARANJA"
	ElseIf FVT->FVT_STATUS == "4" .Or. cStatus == "4"
		cRet := "BR_VERDE"
	ElseIf FVT->FVT_STATUS == "5" .Or. cStatus == "5"	
		cRet := "BR_AZUL"
	Endif
	
Return cRet

/*/
==============================
{Protheus.doc} RetLinGrd
Validação do campo FVT_CODCC

@author    Danilo
@version   12.1.17
@since     10/09/2019 
@protected,
==============================
/*/

Function RetLinGrd(oModel)

Local lRet			:= .T.
Local oStFilho	:= oModel:GetModel( 'FVTDETAIL' )
Local nOperation	:= oModel:GetOperation()
Local cCodCC		:= ""
Local cDocument	:= "" 
Local cEspeci		:= ""
Local cSerie		:= ""
Local cFor			:= ""
Local cLoja		:= ""
Local cStatus		:= ""
Local lTransmis	:= .F.
Private aRetLin	:= {}

Default oModel := NIL

If nOperation == 1
	Alert("Transmissão nao disponivel na opção de visualização !!!")
	lRet := .F.
Else
	cCodCC		:= oStFilho:GetValue("FVT_CODCC")  //FVT_CODCC 
	cCodTipo	:= oStFilho:GetValue("FVT_TIPO")	//FVT_TIPO
	cFor		:= oStFilho:GetValue("FVT_CODIGO")	//FVT_CODIGO
	cLoja		:= oStFilho:GetValue("FVT_LOJA")	//FVT_LOJA 
	cEspeci	:= oStFilho:GetValue("FVT_ESPECI")	//FVT_ESPECI
	cSerie		:= oStFilho:GetValue("FVT_SERIE")	//FVT_SERIE
	cDocument	:= oStFilho:GetValue("FVT_DOC")		//FVT_DOC
	
	AADD(aRetLin,{cCodCC,cCodTipo,cFor,cLoja,cEspeci,cSerie,cDocument})
	
	If FVS->FVS_STATUS == "3"
		Alert(STR0104)
		cStatus := "3"
		lTransmis := .F.
	ElseIf FVS->FVS_STATUS == "4"
		Alert(STR0105)
		cStatus := "4"
		lTransmis := .F.
	
	ElseIf FVS->FVS_STATUS == "5"
		Alert(STR0106)
		cStatus := "5"
		lTransmis := .F.	
	ElseIf FVS->FVS_STATUS $ "1|2"
		lRet := TrfDebCred(aRetLin)
		lTransmis := .T.
	Endif
	If lTransmis
		If lRet
			cStatus := "3"
		Else
			cStatus := "2"
		Endif	
	Endif

	oModel:Activate()
	oModel:SetValue("FVTDETAIL","FVT_STATUS",cStatus)
	oModel:SetValue("FVTDETAIL","FVT_LEGEND",LegFVT(cStatus))
	oModel:SetValue("FVTDETAIL","FVT_RETAFP",FVT->FVT_RETAFP)

Endif

Return lRet

Static Function ConsCC(oModel) 

Local oModFVS	:= oModel:getModel("FVSMASTER")
Local aConsTrf:= ConsCCArg(Alltrim(FVS->FVS_CODCC))
	If valtype(aConsTrf) == "A" .and. Len(aConsTrf) > 1 .And. ! Empty(aConsTrf[2])
		RecLock("FVS", .F.)
			FVS->FVS_OPCTRF := aConsTrf[2] //Grava o campo com o conteudo da consulta
		MsUnlock()
	Endif
Return .T.
