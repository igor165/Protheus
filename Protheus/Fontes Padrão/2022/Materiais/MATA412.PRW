#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA412.CH"
#INCLUDE "FILEIO.CH"

#DEFINE ACTION_ITEM_INCLUDE	1
#DEFINE ACTION_ITEM_DELETE	2
#DEFINE ACTION_ITEM_UPDATE	3
#DEFINE ACTION_ITEM_NOTHING	11

#DEFINE MESSAGE_FUNCTION_UPDATE		4
#DEFINE MESSAGE_FUNCTION_REPLACE	5
#DEFINE MESSAGE_FUNCTION_INSERT		9
#DEFINE MESSAGE_FUNCTION_RESPONSE	11

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA412
Rotina de Programação de Entrega. 
Cadastra uma entrega programada, conforme a necessidade de um cliente,
manualmente ou através do TOTVS Colaboração, podendo gerar um Pedido
de venda através da função Ma412GerPV().

@sample 	MATA412()

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function MATA412()

Local oBrowse	:= nil

Private aRotina 	:= MenuDef()	// Monta menu da Browse
Private cCadastro	:= STR0001		// "Programação de Entrega"

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("SD0")
oBrowse:SetDescription( cCadastro )

//Cria a legenda da tela principal (Browse)
oBrowse:AddLegend( "D0_STATUS == '  '", "YELLOW", STR0009 )	// "Pedido de Venda não gerado"
oBrowse:AddLegend( "D0_STATUS == '01'", "GREEN" , STR0010 )	// "Pedido de Venda gerado"
oBrowse:AddLegend( "D0_STATUS == '02'", "BLUE"  , STR0011 )	// "Pedido de Venda parcialmente entregue"
oBrowse:AddLegend( "D0_STATUS == '03'", "RED"   , STR0012 )	// "Pedido de Venda entregue"

oBrowse:Activate()	//Ativa tela principal (Browse)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para montar o menu principal da rotina.

@sample 	MenuDef()

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action "VIEWDEF.MATA412" 	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0 DISABLE MENU	//"Visualizar"
ADD OPTION aRotina Title STR0003 Action "VIEWDEF.MATA412" 	OPERATION MODEL_OPERATION_INSERT 	ACCESS 0					//"Incluir"
ADD OPTION aRotina Title STR0004 Action "VIEWDEF.MATA412" 	OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0 DISABLE MENU	//"Alterar"
ADD OPTION aRotina Title STR0005 Action "VIEWDEF.MATA412" 	OPERATION MODEL_OPERATION_DELETE 	ACCESS 0 DISABLE MENU	//"Excluir"
ADD OPTION aRotina Title STR0006 Action "MA412GerPV" 		OPERATION 4 						ACCESS 0 DISABLE MENU	//"Gerar Pedido de Venda"
ADD OPTION aRotina Title STR0028 Action "MA412CanPV" 		OPERATION 4							ACCESS 0 DISABLE MENU	//"Cancelar Pedido de Venda"
ADD OPTION aRotina Title STR0069 Action "At412LtOs" 		OPERATION MODEL_OPERATION_VIEW		ACCESS 0 DISABLE MENU	//"Legenda"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para definir o model da rotina.

@sample 	ModelDef()

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= nil
Local oStruSD0		:= nil
Local oStruSDX		:= nil
Local oStruSDXFat	:= nil
Local bCommit		:= { |oModel| MA412Grava( oModel ) }	//Bloco de código para gravação do model
Local cDXNota		:= '"' + PadR('',TamSX3('DX_NOTA')[1]) + '"'
Local aQtdEnt		:= TAMSX3("C6_QTDENT")

oModel 		:= MPFormModel():New( "MATA412", , , bCommit )	//Cria um objeto de Modelo de dados baseado no fonte informado
oStruSD0	:= FWFormStruct( 1, "SD0" )							//Cria as estruturas a serem usadas na View (Master)
oStruSDX	:= FWFormStruct( 1, "SDX" )							//Cria as estruturas a serem usadas na View (Detail)
oStruSDXFat	:= FWFormStruct( 1, "SDX" )							//Cria as estruturas a serem usadas na View (Detail)

//Cria no model o campo de quantidade entregue
oStruSDX:AddField(STR0079, ; //"Qtd.Entregue"				// [01] C Titulo do campo
						STR0080 , ; //"Quantidade Entregue"	// [02] C ToolTip do campo
						'DX_QTDENT' , ; 					// [03] C identificador (ID) do Field
						'N' , ; 							// [04] C Tipo do campo
						aQtdEnt[1] , ; 						// [05] N Tamanho do campo
						aQtdEnt[2] , ;						// [06] N Decimal do campo
						NIL , ;								// [07] B Code-block de validação do campo
						NIL , ;	 							// [08] B Code-block de validação When do campo
						NIL , ;								// [09] A Lista de valores permitido do campo
						NIL , ; 							// [10] L Indica se o campo tem preenchimento obrigatório
						FwBuildFeature(STRUCT_FEATURE_INIPAD,'!INCLUI .AND. Posicione("SC6", 1, xFilial("SC6") + SD0->D0_PEDIDO + SDX->DX_ITEM + SDX->DX_PRODUTO, "C6_QTDENT")') , ; // [11] B Code-block de inicializacao do campo
						NIL , ; 							// [12] L Indica se trata de um campo chave
						.F. , ; 							// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. ) 								// [14] L Indica se o campo é virtual
					
oStruSDXFat:AddField(STR0079, ; //"Qtd.Entregue"			// [01] C Titulo do campo
						STR0080 , ; //"Quantidade Entregue"	// [02] C ToolTip do campo
						'DX_QTDENT' , ; 					// [03] C identificador (ID) do Field
						'N' , ; 							// [04] C Tipo do campo
						aQtdEnt[1] , ;						// [05] N Tamanho do campo
						aQtdEnt[2] , ; 						// [06] N Decimal do campo
						NIL , ;								// [07] B Code-block de validação do campo
						NIL , ;	 							// [08] B Code-block de validação When do campo
						NIL , ;								// [09] A Lista de valores permitido do campo
						NIL , ; 							// [10] L Indica se o campo tem preenchimento obrigatório
						FwBuildFeature(STRUCT_FEATURE_INIPAD,'!INCLUI .AND. Posicione("SC6", 1, xFilial("SC6") + SD0->D0_PEDIDO + SDX->DX_ITEM + SDX->DX_PRODUTO, "C6_QTDENT")') , ; // [11] B Code-block de inicializacao do campo
						NIL , ; 							// [12] L Indica se trata de um campo chave
						.F. , ; 							// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. ) 								// [14] L Indica se o campo é virtual

//Altera o inicializador padrão do campo na estrutura
oStruSDX:SetProperty( 'DX_ITEM', MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "MA412Inc()" ) )

oStruSDX:SetProperty( 'DX_PRODUTO', MODEL_FIELD_WHEN, FwBuildFeature( STRUCT_FEATURE_WHEN, "Ma412AltQt()"))
oStruSDX:SetProperty( 'DX_QUANT', MODEL_FIELD_WHEN, FwBuildFeature( STRUCT_FEATURE_WHEN, "Ma412AltQt()"))

oModel:AddFields( "SD0MASTER", , oStruSD0 )				//Adiciona no nosso View um controle do tipo formulário
oModel:AddGrid( "SDXDETAIL", "SD0MASTER", oStruSDX, , { || MA412VldLn( oModel ) } )		//Adiciona no nosso View um controle do tipo Grid para os itens não faturados
oModel:AddGrid( "SDXFATURA", "SD0MASTER", oStruSDXFat )	//Adiciona no nosso View um controle do tipo Grid para os itens faturados

oModel:SetRelation( "SDXDETAIL", { { "DX_FILIAL", "xFilial('SDX')" }, { "DX_NUMENT", "D0_NUMENT" } }, SDX->( IndexKey(1) ) )
oModel:SetRelation( "SDXFATURA", { { "DX_FILIAL", "xFilial('SDX')" }, { "DX_NUMENT", "D0_NUMENT" } }, SDX->( IndexKey(1) ) )

//oModel:SetDescription(cCadastro)
oModel:GetModel("SD0MASTER"):SetDescription(STR0007)	// "Cadastro de Programação de Entrega"

//Configura grid de itens não faturados
oModel:GetModel("SDXDETAIL"):SetDescription(STR0021)					// "Itens não faturados"
If IsBlind()
	oModel:GetModel("SDXDETAIL"):SetLoadFilter({ {"DX_NOTA", cDXNota, MVC_LOADFILTER_EQUAL} })	//Carrega apenas se o campo DX_NOTA estiver vazio (Item não faturado)
Else
	oModel:GetModel("SDXDETAIL"):SetLoadFilter( , " ( " + Ma412MtFlt(D0_NUMENT) + " ) " ) 	//Carrega apenas se o campo DX_NOTA estiver vazio (Item não faturado)
EndIf
		
//Configura grid de itens faturados
oModel:GetModel("SDXFATURA"):SetDescription(STR0022)	// "Itens Faturados"
oModel:GetModel("SDXFATURA"):SetOptional(.T.)			// Define grid como opcional, permite não ter linhas
oModel:GetModel("SDXFATURA"):SetLoadFilter({ {"DX_NOTA", cDXNota, MVC_LOADFILTER_NOT_EQUAL} })	//Carrega apenas se o campo DX_NOTA estiver preenchido (Item faturado)
oModel:GetModel("SDXFATURA"):SetNoUpdateLine(.T.)	// Bloqueia alteração nos registros da grid
oModel:GetModel("SDXFATURA"):SetNoDeleteLine(.T.)	// Bloqueia exclusão nos registros da grid
oModel:GetModel("SDXFATURA"):SetNoInsertLine(.T.)	// Bloqueia inserir registros na grid

oModel:SetPrimaryKey( { "D0_FILIAL", "D0_NUMENT" } )
oModel:SetVldActivate( { |oModel| MA412Activ( oModel ) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para criar a visualização da rotina.

@sample 	ViewDef()

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= nil
Local oStruSD0	:= nil
Local oStruSDX	:= nil
Local oView		:= nil

oModel		:= FWLoadModel( "MATA412" )	//Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
oStruSD0	:= FWFormStruct( 2, "SD0" )	//Cria as estruturas a serem usadas na View
oStruSDX	:= FWFormStruct( 2, "SDX" )	//Cria as estruturas a serem usadas na View
oView 		:= FWFormView():New()		//Cria o objeto de View

//Remoção de campos da View
oStruSD0:RemoveField("D0_STATUS")
oStruSDX:RemoveField("DX_NUMENT")

//Cria na view o campo de quantidade entregue
oStruSDX:AddField('DX_QTDENT' , ; 										// [01] C Nome do Campo
					'06' , ; 											// [02] C Ordem
					STR0079 , ; //"Qtd.Entregue"						// [03] C Titulo do campo
					STR0080 , ; //"Quantidade Entregue"					// [04] C Descrição do campo
					{ STR0081 } , ; //"Quantidade já faturada do item."	// [05] A Array com Help
					'N' , ; 											// [06] C Tipo do campo
					PesqPict( "SC6", "C6_QTDENT" ) , ;				 	// [07] C Picture
					NIL , ; 											// [08] B Bloco de Picture Var
					Nil , ; 											// [09] C Consulta F3
					.F. , ; 											// [10] L Indica se o campo é editável
					NIL , ; 											// [11] C Pasta do campo
					NIL , ; 											// [12] C Agrupamento do campo
					NIL , ; 											// [13] A Lista de valores permitido do campo (Combo)
					NIL , ; 											// [14] N Tamanho Máximo da maior opção do combo
					NIL , ; 											// [15] C Inicializador de Browse
					.T. , ; 											// [16] L Indica se o campo é virtual
					NIL ) 												// [17] C Picture Variável

oView:SetModel( oModel )	//Define qual Modelo de dados será utilizado

oView:AddField( "VIEW_SD0", oStruSD0, "SD0MASTER" )		//Adiciona no nosso View um controle do tipo formulário
oView:AddGrid( "VIEW_SDX", oStruSDX, "SDXDETAIL" )		//Adiciona um controle do tipo Grid para exibir itens não faturados
oView:AddGrid( "VIEW_FATURA", oStruSDX, "SDXFATURA" )	//Adiciona um controle do tipo Grid para exibir os itens faturados

oView:CreateHorizontalBox( "CABECALHO", 25 )	//Cria um box superior para exibir a Master
oView:CreateHorizontalBox( "ITENS", 40 )		//Cria um box inferior para exibir a Detail
oView:CreateHorizontalBox( "ITENSFAT", 35 )		//Cria um box inferior para exibir a Detail com itens faturados

oView:SetOwnerView( "VIEW_SD0", "CABECALHO" )	//Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( "VIEW_SDX", "ITENS" )		//Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( "VIEW_FATURA", "ITENSFAT" )	//Relaciona o identificador (ID) da View com o "box" para exibição

oView:EnableTitleView("VIEW_SDX")
oView:EnableTitleView("VIEW_FATURA")

//Adiciona funções auxiliares
oView:AddUserButton( STR0013, "", { |oModel| MA412DlgDes(oModel) } )	// "Desmembrar itens"
oView:AddUserButton( STR0030, "", { |oModel| MA412InsTES(oModel) } )	// "Inserir TES"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412Activ
Ativação do Model.

@sample 	MA412Activ( oModel ) 
@param		oModel - Modelo de dados
@return	lRet (Boolean) - Indica se ativa o módulo ou não.

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function MA412Activ( oModel )

Local aArea := GetArea()
Local lRet	:= .T.

Do Case

	//Validação em caso de alteração
	Case oModel:GetOperation() == MODEL_OPERATION_UPDATE
		
		//Não permite alteração se todos os itens foram faturados
		If ( SD0->D0_STATUS == "03" )
			Help( " ", 1, "MA412Activ", , STR0032, 1 )	//"Não é permitido alterar uma Programação de Entrega faturada."
			lRet := .F.
		EndIf
	
	//Validação em caso de exclusão	
	Case oModel:GetOperation() == MODEL_OPERATION_DELETE
	
		//Não permite exclusão se existem itens faturados
		If ( SD0->D0_STATUS $ ("02|03") )
			Help( " ", 1, "MA412Activ", , STR0033, 1 )	//"Não é permitido excluir uma Programação de Entrega com itens faturados."
			lRet := .F.
		ElseIf ( SD0->D0_STATUS == "01" )
			Help( " ", 1, "MA412Activ", , STR0034, 1 )	//"Existe Pedido de Venda gerado para essa entrega. Cancele o pedido antes de efetuar a exclusão."
			lRet := .F.
		EndIf
		
End Case

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412Grava
Grava a Programação de Entrega atualizando o pedido de venda, caso
tenha sido gerado, nas operações de alteração e exclusão.

@sample 	MA412Grava( oModel )
@param		oModel - Modelo de dados 

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function MA412Grava( oModel )

Local aArea		:= GetArea()
Local lRet		:= .T.
Local nOpc		:= oModel:GetOperation()
Local oModelSD0	:= nil
Local oModelSDX	:= nil
Local aMaster	:= {}
Local aDetail	:= {}
Local nI		:= 0
Local lExistePV	:= .F.
Local cPedido	:= ""

Private lMsErroAuto := .F.

oModelSD0	:= oModel:GetModel("SD0MASTER")
oModelSDX 	:= oModel:GetModel("SDXDETAIL")

//Verifica se existe pedido de venda, não considerando se a gravação foi acionada pela Ma412GerPV()
lExistePV := ExistePV()

//-------------------------------------------------------------------------
// Se existe pedido de venda, monta array de cabeçalho e itens, de acordo 
// com a operação, apenas alteração e exclusão, para atualizar o pedido 
// via ExecAuto.
//-------------------------------------------------------------------------
If ( lExistePV )
	
	Do Case
	
		//Trata se for alteração
		Case( nOpc == MODEL_OPERATION_UPDATE )
		
			//Valida dados alterados
			If ( !MA412VldPV( oModel ) )
				Return .F.
			EndIf
			
			AddHeader( oModelSD0, @aMaster, nOpc )	//Monta array de cabeçalho (Master)
			
			For nI := 1 To oModelSDX:Length()
				
				oModelSDX:GoLine(nI)
				
				//Se item foi incluído e depois deletado não adiciona ao array, se o campo de nota esta preenchido não deve gravar alterações
				If !( oModelSDX:IsUpdated() .And. oModelSDX:IsInserted() .And. oModelSDX:IsDeleted() ) .And. Empty(oModelSDX:GetValue('DX_NOTA'))
					AddItem( oModelSD0, oModelSDX, @aDetail, nI, nOpc )	//Monta array de itens (Detail)
				EndIf
				
			Next nI
		
		//Trata se for exclusão		
		Case( nOpc == MODEL_OPERATION_DELETE )
		
			AddHeader( oModelSD0, @aMaster, nOpc )	//Monta array de cabeçalho (Master)
	
	End Case
	
EndIf

//-------------------------------------------------------------------------
// Se não for inclusão e pedido já foi gerado, atualiza o pedido.
//-------------------------------------------------------------------------
If ( lRet ) .And. ( nOpc != 3 ) .And. ( lExistePV )
	
	cPedido := oModelSD0:GetValue("D0_PEDIDO")
	
	DbSelectArea("SC5")
	SC5->( DbSetOrder(1) )	//C5_FILIAL + C5_NUM
	
	If ( SC5->( DbSeek( xFilial("SC5") + cPedido ) ) )
	
		MSExecAuto( { |x, y, z| Mata410(x, y, z) }, aMaster, aDetail, nOpc )
	
	EndIf
	
	//Trata erro na ExecAuto
	If ( lMsErroAuto )
		lRet := .F.
		MostraErro()
	EndIf
EndIf

//-------------------------------------------------------------------------
// Grava o model
//-------------------------------------------------------------------------
If ( lRet )
	FWFormCommit( oModel )
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412InsTES
Insere uma TES nos itens que estiverem sem calor preenchido.

@sample 	MA412InsTES( oModel )
@param		oModel - Modelo de dados

@author	Danilo Dias
@since		06/08/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function MA412InsTES( oModel )

Local cTES 			:= Space( TamSX3("DX_TES")[1] )
Local oModelSDX 	:= Nil
Local nI			:= 1
Local cTitulo		:= STR0030
Local nOpc			:= 0
Local cCampoTES		:= Nomecampo( "DX_TES" )[1]


oModelSDX := oModel:GetModel( "SDXDETAIL" )

oDlg := MSDialog():New( 0, 0, 120, 300, cTitulo, , , , , , , , oMainWnd, .T., , , , ) 
   
    oSay  	:= TSay():New( 010, 015, { || cCampoTES }, oDlg,,,,,,.T.,,, 60, 10 )
    oTES  	:= TGet():New( 020, 015, { |u| If( PCount() > 0, cTES := u, cTES ) }, oDlg, 060, 010,,{|| Empty(cTES) .Or. ExistCpo( "SF4", cTES, 1 )},,,,,,.T.,,,,,,,,, "SF4", "cTES",,,, .T., .F. )
         
    oBtnIns 	:= tButton():New( 040, 020, STR0030 , oDlg, { || oDlg:End(), nOpc := 1 }, 050,,,,,.T.,,,,,,, )	//"Inserir TES" 
    oBtnCanc	:= tButton():New( 040, 085, STR0044 , oDlg, { || oDlg:End(), nOpc := 0 }, 050,,,,,.T.,,,,,,, )	//"Cancelar"      	     	    	    
		    
oDlg:Activate( ,,,.T.,,,,, ) 

If nOpc == 1
	
	If ( cTES != Nil ) .And. ( !Empty( cTES ) )
	
		For nI := 1 To oModelSDX:Length()
			oModelSDX:GoLine(nI)
			
			If ( Empty( oModelSDX:GetValue( "DX_TES" ) ) )
				oModelSDX:SetValue( "DX_TES", cTES )
			EndIf
			
		Next nI

	EndIf
	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412Inc
Controla o incremento de uma coluna quando não for possível usar
o incremento automático da view.

@sample 	MA412Inc()

@author	Danilo Dias
@since		06/08/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function MA412Inc()

Local aArea		:= GetArea()
Local oModel 		:= Nil
Local oModelSDX	:= Nil
Local oModelFAT	:= Nil
Local cInc			:= Nil

oModel := FwModelActive()

oModelSDX := oModel:GetModel("SDXDETAIL")
oModelFAT := oModel:GetModel("SDXFATURA")

//Obtém o maior valor já usado entre as duas grids da view, 
//a de itens faturados e itens não faturados
cInc := GetMaxValue( { oModelSDX, oModelFAT }, "DX_ITEM" )	

//Se encontrou itens na grid soma 1 senão fixa "01"
If ( ValType(cInc) == "C" )
	cInc := Soma1(cInc)
Else
	cInc := "01"
EndIf
	
RestArea(aArea)

Return cInc

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412GerPV
Gera o Pedido de Venda a partir de uma Programação de Entrega.

@sample 	MA412GerPV() 

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function MA412GerPV()

Local aArea		:= GetArea()	//Salva contexto atual
Local lRet			:= .T.			//Indica se o pedido foi gerado com sucesso.
Local aMaster		:= {}			//Array com dados da Master para geração do Pedido de Venda
Local aDetail		:= {}			//Array com dados da Detail para geração do Pedido de Venda
Local oModel		:= nil
Local oModelSD0	:= nil
Local oModelSDX	:= nil
Local nI			:= 0
Local bAction		:= { || MSExecAuto( { |x, y, z| Mata410(x, y, z) }, aMaster, aDetail, 3 ) }

Private lMsErroAuto := .F.

RegToMemory( "SD0", .F. )

//Valida dados para geração do Pedido de Venda
If ( MA412VldPV() )
	
	oModel := FWLoadModel( "MATA412" )
	oModel:SetOperation( MODEL_OPERATION_UPDATE )
	
	If ( oModel:Activate() )
		
		oModelSD0	:= oModel:GetModel("SD0MASTER")
		oModelSDX	:= oModel:GetModel("SDXDETAIL")			
		
		//Montagem dos arrays com dados da ExecAuto da MATA410
		AddHeader( oModelSD0, @aMaster, MODEL_OPERATION_INSERT )
	
		For nI := 1 To oModelSDX:Length()
			AddItem( oModelSD0, oModelSDX, @aDetail, nI, MODEL_OPERATION_INSERT )
		Next nI
		
		//Inicia transação
		Begin Transaction	
		
			MsAguarde( bAction, "MA412GerPV", STR0024 )
		
			//Tratamento de erro na execução automática	
			If (!lMsErroAuto)	  
					
				oModelSD0:SetValue( "D0_STATUS", "01" )
				oModelSD0:SetValue( "D0_PEDIDO", SC5->C5_NUM )
				
				If ( oModel:VldData() )
					//Executa o commit dos dados
					oModel:CommitData()
				Else
					DisarmTransaction()
					Help( " ", 1, "MA412CanPV", , STR0026, 1 )	//"Erro na atualização do Status da Programação de Entrega."
				EndIf
				
			Else
				DisarmTransaction()
				MostraErro()
			EndIf
			
		End Transaction
			
	EndIf
	
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412CanPV
Cancela o Pedido de Venda gerado a partir de uma Programação de 
Entrega.

@sample 	MA412CanPV() 

@author	Danilo Dias
@since		02/08/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function MA412CanPV()

Local aArea		:= GetArea()
Local oModel 		:= Nil
Local oModelSD0	:= Nil
Local aHeader		:= {}
Local aDetail		:= {}
Local bAction		:= { || MsExecAuto( { |x, y, z| MATA410( x, y, z ) } , aHeader, aDetail, 5 ) }

Private lMsErroAuto := .F.

RegToMemory( "SD0", .F. )

//Valida dados para cancelamento do Pedido de Venda
If ( MA412VlCan() )

	oModel := FwLoadModel("MATA412")
	oModel:SetOperation( MODEL_OPERATION_UPDATE )
	
	//Executa apenas se ativou o Model
	If ( oModel:Activate() )
	
		oModelSD0	:= oModel:GetModel("SD0MASTER")
		
		If ( !Empty( oModelSD0:GetValue("D0_STATUS") ) )
			
			//Não permite cancelamento quando tem itens faturados
			If !( oModelSD0:GetValue("D0_STATUS") $("02|03") )
			
				//Monta o array com os dados da tabela Master
				AddHeader( oModelSD0, @aHeader, 5 )
				
				MA412EstPV( oModelSD0:GetValue("D0_PEDIDO") )	//Estorna a liberação do Pedido de Venda
				
				Begin Transaction
				
					//Exclui o Pedido de Venda
					MsAguarde( bAction, "MA412CanPV", STR0025 )	//"Aguarde, excluindo Pedido de Venda."
					
					If ( lMsErroAuto )
						DisarmTransaction()
						MostraErro()
					Else
						oModelSD0:SetValue( "D0_STATUS", "  " )
						oModelSD0:SetValue( "D0_PEDIDO", "      " )
						
						If ( oModel:VldData() )
							//Executa o commit dos dados
							oModel:CommitData()
						Else
							DisarmTransaction()
							Help( " ", 1, "MA412CanPV", , STR0026, 1 )	//"Erro na atualização do Status da Programação de Entrega."
						EndIf
					EndIf
			
				End Transaction
				
			Else
				Help( " ", 1, "MA412CanPV", , STR0027, 1 )	//"Pedidos de Venda com itens faturados não podem ser cancelados."
			EndIf
		
		Else
			Help( " ", 1, "MA412CanPV", , STR0029, 1 )	//"Não foi possível cancelar, a programação selecionada não gerou Pedido de Venda."
		EndIf
	
	EndIf
	
EndIf

RestArea(aArea)
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412EstPV
Estorna a liberação do Pedido de Venda.

@sample 	MA412EstPV( cPedido ) 
@param		cPedido - Número do pedido a ser estornado
@return	lRet - (.T. ou .F.) Indica se o cliente informado existe ou não.

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function MA412EstPV( cPedido )

Local aArea := GetArea()

Default cPedido := ""

DbSelectArea("SC9")
SC9->(DbSetOrder(1))	//C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO
SC9->(DbGoTop())

//Busca o pedido no SC9 - Pedidos Liberados
If ( SC9->( MsSeek( xFilial("SC9") + cPedido ) ) )

	//Estorna item a item do pedido
	While SC9->(!Eof()) .And. SC9->C9_PEDIDO == cPedido
	
		A460Estorna( .F., .T., 0 )
		SC9->(DbSkip())
		
	EndDo

EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412DlgDes
Tela para desmembramento de um item.

@sample 	MA412DlgDes() 
@param		

@author	Danilo Dias
@since		03/08/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function MA412DlgDes( oModel )

Local oModelSDX 	:= oModel:GetModel("SDXDETAIL")
Local nQtde		:= 0
Local cItem		:= ""
Local cProduto	:= ""
Local cDescProd	:= ""
Local cTES			:= ""
Local dDataEnt	:= dDataBase
Local cHoraEnt	:= ""
Local cStatus		:= ""
Local nLinha		:= 1
Local nOpc			:= 0
Local cTitulo		:= STR0013	//"Confirmação Parcial"
Local aTipEnt		:= {}
Local aBusca		:= {}
Local aSaveLine	:= {}
Local lExiste		:= .F.
Local cGet  
Local oGet
Local oDlg
Local oFont
 
oFont := TFont():New( "Tahoma", 0, 16 )

cItem		:= oModelSDX:GetValue( "DX_ITEM" )
cDescPro 	:= AllTrim( oModelSDX:GetValue( "DX_PRODUTO" ) ) + " - " + AllTrim( oModelSDX:GetValue( "DX_DESC" ) )
cProduto 	:= oModelSDX:GetValue( "DX_PRODUTO" )
dDataEnt	:= oModelSDX:GetValue( "DX_DATENT" )
cHoraEnt 	:= oModelSDX:GetValue( "DX_HORENT" )
cTES		:= oModelSDX:GetValue( "DX_TES" )

//Carrega tipos de entrega do campo combo pelo X3_CBOX                   
dbSelectArea("SX3")
SX3->(dbSetOrder(2))        
If SX3->(dbSeek("DX_TIPENT"))
	aTipEnt := StrToKarr( X3CBox(), ";" )
EndIf

//Tela para desmembramento parcial dos itens
oDlg := MSDialog():New( 0, 0, 260, 300, cTitulo, , , , , , , , oMainWnd, .T., , , , ) 
   
    oSay     	:= TSay():New( 010, 015, { || STR0038 + cItem }, oDlg,,,,,,.T.,,, 60, 10 )	//"Item:"
    oSay     	:= TSay():New( 022, 015, { || STR0039 + cDescPro }, oDlg,,,,,,.T.,,, 120, 10 )	//"Produto:"
    oSay     	:= TSay():New( 034, 015, { || STR0040 }, oDlg,,,,,,.T.,,, 60, 10 )	//"Tipo Entrega:"
    oTipEnt 	:= TComboBox():New( 034, 070, { |u| If( PCount() > 0, cStatus := u, cStatus ) }, aTipEnt, 060, 010, oDlg,,,,,,.T.,,,,,,,,, "cStatus" )
    oSay     	:= TSay():New( 050, 015, { || STR0041 }, oDlg,,,,,,.T.,,, 60, 10 )	//"Quantidade"
    oQtde  		:= TGet():New( 050, 070, { |u| If( PCount() > 0, nQtde := u, nQtde ) }, oDlg, 060, 010, SDX->(X3Picture("DX_QUANT")), { || MA412VldQtd( nQtde, nOpc ) },,,,,,.T.,,,,,,,,,,"nQtde" )
    oSay     	:= TSay():New( 066, 015, { || STR0042 }, oDlg,,,,,,.T.,,, 60, 10 )	//"Data Entrega"
    oData  		:= TGet():New( 066, 070, { |u| If( PCount() > 0, dDataEnt := u, dDataEnt ) }, oDlg, 060, 010,, { || MA412VldDt( dDataEnt ) },,,,,,.T.,,,,,,,,,,"dDataEnt" )
        
    oBtnDesm := tButton():New( 100, 020, STR0043 , oDlg, { || oDlg:End(), nOpc := 1 }, 050,,,,,.T.,,,,,,, )	//"Desmembrar" 
    oBtnCanc := tButton():New( 100, 085, STR0044 , oDlg, { || oDlg:End(), nOpc := 0 }, 050,,,,,.T.,,,,,,, )	//"Cancelar"      	     	    	    
		    
oDlg:Activate( ,,,.T.,,,,, ) 

If nOpc == 1

	MA412Desm( oModelSDX, cProduto, nQtde, cStatus, dDataEnt, cHoraEnt, cTES )              
	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412Desm
Desmembra um item, gerando um novo. Caso exista um item 
igual ao desmembrado eles serão agrupados.

@sample 	MA412Desm() 
@param		oModelGrid		Modelo de dados com a grid de itens
			cProduto		Código do produto desmembrado
			nQtde			Quantidade a desmembrar
			cStatus		Status dos itens desmembrados
			dDataEnt		Data da entrega do item desmembrado
			cHoraEnt		Hora da entrega do item desmembrado

@author	Danilo Dias
@since		03/08/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function MA412Desm( oModelGrid, cProduto, nQtde, cStatus,;
                    dDataEnt, cHoraEnt, cTES )

Local aSaveLine 	:= {}
Local aBusca 		:= {}
Local lExiste		:= .F.
Local nLinha		:= 1
Local nQtdeAnt	:= oModelGrid:GetValue( "DX_QUANT" )
Local cStatusAnt	:= oModelGrid:GetValue( "DX_TIPENT" )

aSaveLine := FwSaveRows()

//Verifica se já existe item com dados do desmembramento
AAdd( aBusca, { "DX_PRODUTO", cProduto } )
AAdd( aBusca, { "DX_TIPENT", cStatus } )
AAdd( aBusca, { "DX_DATENT", dDataEnt } )
AAdd( aBusca, { "DX_HORENT", cHoraEnt } )

lExiste := oModelGrid:SeekLine( aBusca )

If ( nQtde >= nQtdeAnt )

	If ( !lExiste )
	
		FWRestRows( aSaveLine )
		
		oModelGrid:SetValue( "DX_TIPENT", cStatus )
		oModelGrid:SetValue( "DX_QUANT", nQtde )
		oModelGrid:SetValue( "DX_DATENT", dDataEnt )

	Else
	
		nQtde += oModelGrid:GetValue( "DX_QUANT" )
		oModelGrid:SetValue( "DX_QUANT", nQtde )
		
		FwRestRows( aSaveLine )
		
		oModelGrid:DeleteLine()
	
	EndIf

Else
	
	If ( lExiste )
		oModelGrid:SetValue( "DX_QUANT", nQtde + oModelGrid:GetValue( "DX_QUANT" ) )
	Else		
		
		nLinha += oModelGrid:Length()
		
		If ( oModelGrid:AddLine() == nLinha )
				
			oModelGrid:SetValue( "DX_PRODUTO", cProduto )
			oModelGrid:SetValue( "DX_QUANT", nQtde )
			oModelGrid:SetValue( "DX_TES", cTES )
			oModelGrid:SetValue( "DX_TIPENT", cStatus )
			oModelGrid:SetValue( "DX_DATENT", dDataEnt )
			oModelGrid:SetValue( "DX_HORENT", cHoraEnt )
			
		EndIf
	EndIf
	
	FwRestRows( aSaveLine )
	oModelGrid:SetValue( "DX_QUANT", nQtdeAnt - nQtde )
	
EndIf
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MA412When
Função para o When de campos da rotina que não podem ser alterados
durante a alteração da Programação de Entrega.

@sample 	MA412When() 
@return	(Boolean) Indica se o campo pode ou não ser editado.

@author	Danilo Dias
@since		31/07/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function MA412When()

Local lRet 	:= .T.
Local aArea	:= GetArea()

// Se não for inclusão
If ( !Inclui )

	// Se Programação teve itens faturados bloqueia alteração
	If ( SD0->D0_STATUS == "02" ) .Or. ( SD0->D0_STATUS == "03" )
		lRet := .F.
	EndIf

EndIf

RestArea(aArea)

Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} Ma412Stat
Atualiza o status da Programação de Entrega, após faturar um item do Pedido de
venda, gerado pela programação.

@sample 	Ma412Stat( cPedido ) 
@param		cPedido - Número do Pedido de Venda gerado pela Programação
			
@author	Danilo Dias
@since		30/07/2012
@version	P12
/*/
//----------------------------------------------------------------------------
Function Ma412Stat( cPedido )

Local aArea		:= GetArea()
Local aAreaSD0	:= SD0->(GetArea())
Local aAreaSDX	:= SDX->(GetArea())
Local aAreaSC6	:= SC6->(GetArea())
Local cStatus	:= "P"
Local cFilSDX	:=  xFilial("SDX")
Local cFilSC6	:=  xFilial("SC6")

Default cPedido 	:= ""

SD0->(DbSetOrder(3))	//D0_FILIAL + D0_PEDIDO + D0_CLIENTE + D0_LOJA
SDX->(DbSetOrder(1))	//DX_FILIAL + DX_NUMENT + DX_ITEM + DX_PRODUTO

If( SD0->( MsSeek( xFilial("SD0") + cPedido ) ) )

	If ( SDX->( MsSeek( cFilSDX + SD0->D0_NUMENT + SC6->C6_ITEM + SC6->C6_PRODUTO) ) )
	
		If SC6->C6_QTDENT < SDX->DX_QUANT
			cStatus := "P"
		Else
			SC6->(DbSetOrder(1))	//C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
			SDX->( MsSeek( cFilSDX + SD0->D0_NUMENT ) )
			While SDX->(!Eof()) .And. SDX->DX_FILIAL == cFilSDX .And. SDX->DX_NUMENT == SD0->D0_NUMENT
				If SC6->( MsSeek( cFilSC6 + cPedido + SDX->DX_ITEM + SDX->DX_PRODUTO ) )
					If SC6->C6_QTDENT < SDX->DX_QUANT
						cStatus := "P"
						Exit
					EndIf
					cStatus := "F"
				EndIf
				SDX->(DbSkip())			
			EndDo
		EndIf				
	EndIf	
EndIf

//Atualiza status da programação de entrega
RecLock( "SD0", .F. )

If ( cStatus == "P" )
	SD0->D0_STATUS := "02"	//Parcialmente entregue
ElseIf ( cStatus == "F" )
	SD0->D0_STATUS := "03"	//Entregue
EndIf

MsUnlock()

RestArea(aAreaSC6)
RestArea(aAreaSD0)
RestArea(aAreaSDX)
RestArea(aArea)

aSize(aAreaSC6, 0)
aAreaSC6 := Nil
aSize(aAreaSD0, 0)
aAreaSD0 := Nil
aSize(aAreaSDX, 0)
aAreaSDX := Nil
aSize(aArea, 0)
aArea := Nil

Return

//----------------------------------------------------------------------------
/*/{Protheus.doc} MA412Job
Função para recebimento de Programação de Entrega através de Job.

@sample 	MA412Job( aParam ) 
@param		aParam		Parâmetros para preparação do ambiente.
						{ cEmpresa, cFilial, cUsuario }

@author	Danilo Dias
@since		23/08/2012
@version	P12
/*/
//----------------------------------------------------------------------------
Main Function MA412Job( aParam )

Local cUsaColab := "" //Parametro que indica se usa TOTVS Colaboração
Local lUsaColab	:= .F.	//Verifica se usa TOTVS Colaboração 2.0 para recebimento
Local cLog		:= ""	//Mensagem de log da execução da rotina
Local xParam3	:= aParam[3]

RpcSetEnv( aParam[1], aParam[2], aParam[3] )	//Inicializa ambiente
cUsaColab := SuperGetMV( "MV_SPEDCOL", .F., "N" )
lUsaColab := UsaColaboracao("6")

//Executa apenas se parametrizado para usar TOTVS Colaboração
//Executa apenas se parametrizado para usar TOTVS Colaboração
If lUsaColab
	//-- TOTVS Colaboracao 2.0
	lUsaColab := ColCheckUpd()
	If !lUsaColab
		cLog := STR0082	//"UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0"
		GravarLog( cLog, ProcName() )
	Else
		ConOut( "[" + STR0083 + DtoC( date() ) + " - " + time() + " ] " + STR0084 + CRLF ) // "COLABORACAO MATA411 PV " ## "Iniciando processo de geracao do pedido de venda" 
		MA412RecCol(Nil,Nil,xParam3)	//Aciona função de recebimento de documentos TOTVS Colaboração 2.0
		ConOut( "[" + STR0083 + DtoC( date() ) + " - " + time() + " ] " + STR0085 + CRLF ) // "COLABORACAO MATA411 PV " ## "Finalizando processo de geracao do pedido de venda"
	EndIf
ElseIf ( cUsaColab == "S" )
	MA412RecDoc()	//Aciona função de recebimento de documentos
EndIf

RpcClearEnv()	//Limpa ambiente criado
	
Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} MA412RecCol
Recebe documentos através do TOTVS Colaboração 2.0.

@sample 	MA411RecDoc( dDtInic, dDtFim )
@param		dDtInic	Data inicial para recebimento de documentos
@param		dDtFim		Data final para recebimento de documentos 
			
@author	Leonardo Kichitaro
@since		17/09/2014
@version	P11.8
/*/
//----------------------------------------------------------------------------
Function MA412RecCol( dDtInic, dDtFim, xParam3 )

Local oDoc
Local oXML
Local lUsaColab		:= .F.	//Verifica se usa TOTVS Colaboração 2.0 para recebimento
Local lGerPed		:= .T.
Local aDocColFil	:= {}
Local aQueue		:= {"252"}
Local aSm0			:= FWLoadSM0()
Local nSM0			:= 0
Local nI			:= 0
Local nY			:= 0
Local nX			:= 0
Local nZ			:= 0
Local nTag			:= 0
Local nRec			:= 0		// Número de pedidos recebidos
Local nErro			:= 0		// Número de erros ocorridos na recepção de pedidos
Local cXML			:= ""
Local cMsg			:= ""		// Mensagem para gravação no log
Local cCNPJ			:= ""
Local cEmp			:= ""
Local cFil			:= ""
Local cLog			:= ""
Local cError		:= ""	//Mensagem de erro na manipulação do arquivo com XML recebido
Local cWarning		:= ""	//Mensagem de alerta na manipulação do arquivo com XML recebido

//Data padrão para recebimento de documentos
Default dDtInic	:= CToD( "01/01/2000" )
Default dDtFim	:= Date()

ConOut( "[" + STR0083 + DtoC( date() ) + " - " + time() + " ] " + STR0086 + CRLF )  // "COLABORACAO MATA411 PV " ## "JOB Iniciado"

oDoc := ColaboracaoDocumentos():new()
For nY := 1 To Len(aQueue)
	oDoc:cFlag		:= "0"
	oDoc:cQueue		:= aQueue[nY]
	oDoc:cTipoMov	:= "2"
	
	If oDoc:buscaListaDocumentos()
		If ValType("oDoc:aNomeArq") <> "U" .And. Len(oDoc:aNomeArq) > 0
			aDocColFil := {}
			For nX := 1 To Len(oDoc:aNomeArq)
				oDoc:cNomeArq	:= oDoc:aNomeArq[nX,1]
				oDoc:cFlag		:= "0"
				oDoc:Consultar()

				cXml := oDoc:cXmlRet
				nTag := At('</BusinessEvent>',cXml)
				If nTag <> 0
					cXml := SubStr(cXml,nTag+16)
				EndIf

				oXML := XMLParser( cXML, "_", @cError, @cWarning )

				If ( ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) )

					//----------------------------------------------------------------------------
					// Busca o CNPJ/CPF para verificar no SigaMat e definir empresa/filial
					//----------------------------------------------------------------------------
					If ( XmlChildEx( oXML:_BUSINESSCONTENT, '_VENDORTAXID' ) != Nil )
						cCNPJ := oXML:_BUSINESSCONTENT:_vendortaxid:Text
					EndIf

					// Verifica se existe mais de uma filial com mesmo CNPJ, neste caso a validação para importação da nota será feita pela inscricao estadual
					cEmp := ""
					cFil := ""
					For nSM0 := 1 To Len(aSm0)
						If cCNPJ $ aSm0[nSM0][18]
							cEmp := aSm0[nSM0][1]
							cFil := aSm0[nSM0][2]
							Exit
						EndIf
					Next
	
					If !Empty(cEmp) .And. !Empty(cFil)
						Aadd(aDocColFil,{cEmp,cFil,cCNPJ,oDoc:aNomeArq[nX,1],cXML})
					EndIf
				Else
					cLog := STR0007 + CRLF	//"Falha na leitura do arquivo XML recebido."
					cLog += IIf( Empty( cWarning ), cError, cWarning )
					GravarLog( cLog, ProcName() )
				EndIf
			Next

			Asort(aDocColFil,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
			For nZ := 1 To Len(aDocColFil)
				lGerPed	:= .T.
				If cEmpAnt <> aDocColFil[nZ][1] .Or. cFilAnt <> aDocColFil[nZ][2]
					RpcClearEnv()	//Limpa ambiente criado
					RpcSetEnv( aDocColFil[nZ][1], aDocColFil[nZ][2], xParam3 )	//Inicializa ambiente
					lUsaColab := UsaColaboracao("6")
				
					//Executa apenas se parametrizado para usar TOTVS Colaboração
					If lUsaColab
						//-- TOTVS Colaboracao 2.0
						lUsaColab := ColCheckUpd()
						If !lUsaColab
							lGerPed	:= .F.
							cLog := STR0082	//"UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0"
							GravarLog( cLog, ProcName() )
						EndIf
					EndIf
				EndIf

				If lGerPed
					If ( !MA412GrvDoc( {StrTran(Upper(aDocColFil[nZ][4]),".XML",""),aDocColFil[nZ][5]} ) )
						nErro 	+= 1	//Incrementa quantidade de erros ocorridos
						cMsg 	+= STR0001 + " [" + STR0029 + aDocColFil[nZ][4] + "]" + CRLF	//"Erro na gravação do Pedido de Venda." | "Documento: "
					Else
						oDoc:cNomeArq	:= aDocColFil[nZ][4]
						oDoc:cFlag		:= "1"

						oDoc:flegadocumento()
					EndIf
				EndIf

				nRec += 1	//Incrementa quantidade de pedidos recebidos
			Next

			//Encerra o recebimento de documentos
			If ( nRec > 0 )
				cMsg += cValToChar(nRec) + " " + STR0002 + CRLF	//"pedido(s) recebido(s)."
			Else
				cMsg += STR0003 + CRLF	//"Nenhum pedido pendente no servidor."
			EndIf
			
			If ( nErro > 0 )
				cMsg += cValToChar(nErro) + " " + STR0004 + CRLF	//"erro(s)."
			EndIf
			
			cMsg += CRLF + "**************************************************************************************************"
			GravarLog( cMsg, ProcName() )	
		Else
			ConOut( "[" + STR0087 + DtoC( date() ) + " - " + time() + " ] " + STR0088 + CRLF ) // "COLABORACAO MATA412 PE " ## "Sem documentos a serem processados!"
		EndIf
	EndIf
Next

ConOut( "[" + STR0087 + DtoC( date() ) + " - " + time() + " ] " + STR0089 + CRLF ) // "COLABORACAO MATA412 PE " ## "JOB Finalizado"

Return

//----------------------------------------------------------------------------
/*/{Protheus.doc} MA412RecDoc
Recebe documentos através do TOTVS Colaboração.

@sample 	MA412RecDoc( dDtInic, dDtFim )
@param		dDtInic	Data inicial para recebimento de documentos
@param		dDtFim		Data final para recebimento de documentos 
			
@author	Danilo Dias
@since		17/08/2012
@version	P12
/*/
//----------------------------------------------------------------------------
Function MA412RecDoc( dDtInic, dDtFim )
Local lRet		:= .T.

Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} MA412Conf
Confirmação de documentos no servidor do TOTVS Colaboração.

@sample 	MA412Conf() 
			
@author	Danilo Dias
@since		17/08/2012
@version	P12
/*/
//----------------------------------------------------------------------------
Function MA412Conf( cIdTSS )

Return -1

//----------------------------------------------------------------------------
/*/{Protheus.doc} MA412GrvDoc
Monitora documentos no servidor do TOTVS Colaboração.

@sample 	MA412GrvDoc( aDocs ) 
@param		aDoc - Array contendo os dados do documento recebido do TSS
					aDoc[1] - cIdTSS
					aDoc[2] - cXML
			
@author	Danilo Dias
@since		17/08/2012
@version	P12
/*/
//----------------------------------------------------------------------------
Function MA412GrvDoc( aDocs )

Local aArea			:= GetArea()
Local lRet			:= .T.
Local nI			:= 1
Local nJ			:= 1
Local nCount		:= 0
Local nAux			:= 0
Local nHandle		:= 0
Local aMsgerro		:= {}	//Mensagem de erro no commit do model
Local cLogErro		:= ""	//Mensagem de erro no commit do model
Local cCaminho		:= ""	//Caminho do arquivo com conteúdo XML
Local cArquivo		:= ""	//Nome do arquivo que será criado para guardar o XML
Local cLog			:= ""	//Texto a ser gravado no arquivo de log
Local lLog			:= .T.	//Indica se deve gerar log
Local cXML			:= ""	//XML recebido do TSS
Local oXML			:= Nil	//Objeto com estrutura XML
Local oXMLContent	:= Nil	//Objeto com estrutura parcial do XML (Business Content)
Local oXMLItens		:= Nil	//Objeto com estrutura parcial do XML (Entrega dos Itens)
Local oModel		:= Nil	//Modelo de dados da rotina
Local oModelMast	:= Nil	//Modelo de dados parcial da rotina (SD0)
Local oModelDet		:= Nil	//Modelo de dados parcial da rotina (SDX)
Local cError		:= ""	//Mensagem de erro na manipulação do arquivo com XML recebido
Local cWarning		:= ""	//Mensagem de alerta na manipulação do arquivo com XML recebido
Local cChave		:= ""	//Chave de busca para o Seek
Local aMaster		:= {}	//Array com dados da Master para atualização do model
Local aDetail		:= {}	//Array com dados da Detail para atualização do model
Local aBusca		:= {}	//Array com dados da chave de busca para o seekline
Local nFuncao		:= 0	//Função da mensagem ( 4-Alteração | 5-Substituição | 9-Original | 11-Resposta )
Local cCNPJ			:= ""	//CNPJ do comprador
Local cCliente		:= ""	//Código do cliente
Local cLoja			:= ""	//Loja do cliente
Local cTipoCodIt	:= ""	//Tipo do código do item ( EN-EAN/DUN | UP-UPC | BP-Código Comprador )
Local cCodItem		:= ""	//Código do item de acordo com o campo typecodprod
Local nAcaoItem		:= 0	//Ação do item ( 1-Adicionar | 2-Excluir | 3-Alterar | 11-Não Alterada )
Local cPedCli		:= ""	//Código do pedido do cliente
Local cDataEmis		:= ""	//Data de emissão da Programação de Entrega
Local cDataEnt		:= ""	//Data da entrega
Local cHoraEnt		:= ""	//Hora da entrega
Local nQtde			:= 0	//Quantidade do item
Local cTipoEnt		:= ""	//Tipo da entrega ( 1-Firme | 4-Previsto | 10-Imediato | 10E-Prometido )
Local cTES			:= ""	//TES utilizada para geração do pedido
Local cCondicao		:= ""	//Condição de pagamento para geração do pedido
Local cTabela		:= ""	//Tabela de preço para a geração do pedido
Local aConfirm		:= {}	//Recebe o status da confirmação de documentos
Local cTESPadrao	:= SuperGetMV( "MV_FATTSPD", .F., "" )
Local lUsaColab		:= UsaColaboracao("6")

cCaminho	:= "\xml\In\"

//----------------------------------------------------------
// Verifica se existe o caminho para salvar mensagens
// recebidas, se não existir cria a pasta no server.
//----------------------------------------------------------
If !lUsaColab
	If ( !ExistDir( cCaminho ) )
		If ( !MakeDir( cCaminho ) == 0 )
			If ( lLog )
				cLog := STR0049 + CRLF + Str(FError())	//"Falha na criação da pasta de entrada de documentos no servidor. Verifique as permissões de acesso."
				GravarLog( cLog, ProcName() )
				Return .F.
			EndIf
		EndIf
	EndIf
EndIf

//----------------------------------------------------------
// Efetua a gravação dos documentos recebidos
//----------------------------------------------------------
If !lUsaColab
	cArquivo := cCaminho + "DeliverySchedule_" + AllTrim( aDocs[1] ) + "_" + DToS( Date() ) + StrTran( Time(), ":" ) + ".xml"

	nHandle := FCreate( cArquivo )
EndIf

//Valida a criação do arquivo XML
If ( nHandle == -1 )
	If (lLog )
		cLog := STR0050 + CRLF + Str(FError())	//"Falha na criação do arquivo XML. Verifique a existência da pasta de destino e suas permissões."
		GravarLog( cLog, ProcName() )
	EndIf
Else
	cXML := aDocs[2]
	If !lUsaColab
		FWrite( nHandle, cXML )
		FClose( nHandle )
	EndIf
	
	oXML := XMLParser( cXML, "_", @cError, @cWarning )
	
	//Valida se não houve erro no parse
	If ( ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) )
		
		//Monta objetos com estrutura parcial do XML para facilitar o código
		If lUsaColab
			oXMLContent 	:= oXML:_BusinessContent
			oXMLItens		:= oXMLContent:_ListOfItensDeliveryScheduling
		Else
			oXMLContent 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent		
			oXMLItens		:= oXMLContent:_ListOfItensDeliveryScheduling
		EndIf
		//---------------------------------------------------------------------------------------
		// Carrega dados da tabela Master da Programação de Entrega
		//---------------------------------------------------------------------------------------
		
		//Lê a função da mensagem ( 4-Alteração | 5-Substituição | 9-Original | 11-Resposta )
		If ( XmlChildEx( oXMLContent, '_FUNCMSGPROG' ) != Nil )
			nFuncao := Val( oXMLContent:_funcmsgprog:Text )
		EndIf
		
		//Lê o código do pedido do cliente
		If ( XmlChildEx( oXMLContent, '_DOCUMENTNUMBER' ) != Nil )
			cPedCli := oXMLContent:_documentnumber:Text
		EndIf
		
		//Lê CNPJ do comprador e busca dados no SA1 pelo CNPJ
		If ( XmlChildEx( oXMLContent, '_BUYERCNPJ' ) != Nil )
			
			cCNPJ := oXMLContent:_buyercnpj:Text
			
			//Busca o cliente no SA1 através do CNPJ
			DbSelectArea("SA1")		//Clientes
			SA1->( DbSetOrder(3) )	//A1_FILIAL + A1_CGC
			SA1->( DbGoTop() )
			
			If ( SA1->( MsSeek( xFilial("SA1") + cCNPJ ) ) )
				cCliente	:= SA1->A1_COD
				cLoja		:= SA1->A1_LOJA
				cTabela	:= SA1->A1_TABELA	//Tabela de preços padrão para o cliente
				cCondicao	:= SA1->A1_COND	//Condição de pagamento padrão do cliente
			Else
				cLog += CRLF + STR0068 + cCNPJ	//"Pedido " | " não encontrado na base de dados."
				GravarLog( cLog, ProcName() )
				Return .F.
			EndIf
			
		EndIf
		
		//Lê a data e hora de emissão da Programação de Entrega
		If ( XmlChildEx( oXMLContent, '_DHEMISDOCUMENT' ) != Nil )
			cDataEmis := oXMLContent:_dhemisdocument:Text
			cDataEmis := StrTran( SubStr( cDataEmis, 1, 10 ), "-" )
		EndIf

		If ( nFuncao == MESSAGE_FUNCTION_UPDATE ) .Or. ( nFuncao == MESSAGE_FUNCTION_REPLACE )
			DbSelectArea("SD0")		//Cabeçalho da Programação de Entrega
			SD0->( DbSetOrder(2) )	//D0_FILIAL+D0_CLIENTE+D0_LOJA+D0_PEDCLI
			If ( !SD0->( DbSeek( xFilial("SD0") + cCliente + cLoja + cPedCli ) ) )
				nFuncao := MESSAGE_FUNCTION_INSERT
			EndIf
		EndIf
		
		//Monta o array com os dados da master para atualização do model				
		AAdd( aMaster, { "D0_TABELA"	, cTabela } )
		AAdd( aMaster, { "D0_CONDPAG"	, cCondicao } )
		
		//Se for uma alteração de uma programação com pedido gerado, não altera
		//os campos abaixo.
		If ( Empty( SD0->D0_STATUS ) )	.Or. ( nFuncao == MESSAGE_FUNCTION_INSERT )		
			AAdd( aMaster, { "D0_PEDCLI"	, cPedCli } )
			AAdd( aMaster, { "D0_EMISSAO"	, SToD( cDataEmis ) } )
			AAdd( aMaster, { "D0_CLIENTE"	, cCliente } )
			AAdd( aMaster, { "D0_LOJA"		, cLoja } )
		EndIf
		
		//---------------------------------------------------------------------------------------
		// Carrega dados da tabela Detail da Programação de Entrega
		//---------------------------------------------------------------------------------------
	
		If ( XmlChildEx( oXMLItens, '_ITENSDELIVERYSCHEDULINGINFORMATION' ) == Nil )
			cLog := STR0058 + CRLF	//"Falha na leitura do arquivo XML recebido."
			cLog += 'Arquivo não possui itens.'
			GravarLog( cLog, ProcName() )
			Return .F.
		EndIf
		
		//Transforma em array quando o nó de entrega tiver apenas um item
		If ( ValType( oXMLItens:_ItensDeliverySchedulingInformation ) != 'A' )
			XmlNode2Arr( oXMLItens:_ItensDeliverySchedulingInformation, "_ITENSDELIVERYSCHEDULINGINFORMATION")
		EndIf
		
		For nI := 1 To Len( oXMLItens:_ItensDeliverySchedulingInformation )
			
			//Ação do item ( 1-Adicionar | 2-Excluir | 3-Alterar | 11-Não Alterada )
			If ( XmlChildEx( oXMLItens:_ItensDeliverySchedulingInformation[nI], '_ACTIONITEM' ) != Nil )
				nAcaoItem := Val( oXMLItens:_ItensDeliverySchedulingInformation[nI]:_actionitem:Text )
			EndIf
			
			//Tipo do código do item ( EN-EAN/DUN | UP-UPC | BP-Código Comprador )
			If ( XmlChildEx( oXMLItens:_ItensDeliverySchedulingInformation[nI], '_TYPECODPROD' ) != Nil )
				cTipoCodIt := oXMLItens:_ItensDeliverySchedulingInformation[nI]:_typecodprod:Text
			EndIf
			
			//-------------------------------------------------------------------------------------
			// Busca o produto na tabela SB1 utilizando as tags ItemCode e ProdCodSuplli
			//-------------------------------------------------------------------------------------
			If ( XmlChildEx( oXMLItens:_ItensDeliverySchedulingInformation[nI], '_ITEMCODE' ) != Nil )
				
				cCodItem := oXMLItens:_ItensDeliverySchedulingInformation[nI]:_itemcode:Text				
				DbSelectArea("SB1")	//Produtos
				
				Do Case
				
					//Busca o produto pelo código EAN
					Case ( cTipoCodIt == "EN" ) 					
						SB1->( DbSetOrder(5) )	//B1_FILIAL + B1_CODBAR
						cCodItem 	:= AllTrim( cCodItem ) + EANDigito( AllTrim( cCodItem ) )
						cChave 	:= PadR( cCodItem, TamSX3("B1_CODBAR")[1], " " )
					
					//Busca o produto pelo código UPC
					Case ( cTipoCodIt == "UP" )
						SB1->( DbSetOrder(5) )	//B1_FILIAL + B1_CODBAR
						cCodItem 	:= AllTrim( cCodItem ) + EANDigito( AllTrim( cCodItem ) )
						cChave 	:= PadR( cCodItem, TamSX3("B1_CODBAR")[1], " " )
					
					//Busca pelo código de referência do comprador
					Case ( cTipoCodIt == "BP" )
						SB1->( DbSetOrder(1) )	//B1_FILIAL + B1_COD
						DBSelectArea("SA7")
						//-----------------------------------------------------------------------
						//Se for Colaboração 2.0 utiliza o índice de cliente + loja + produto.
						//-----------------------------------------------------------------------
						If lUsaColab
							SA7->( DbSetOrder( 1 ) )	//A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_PRODUTO                                                                                                                         
						Else
						 	SA7->( DbSetOrder( 3 ) )	//A7_FILIAL + A7_CLIENTE + A7_LOJA + A7_CODCLI
						EndIf                                                                                                                        
						SA7->( DbGoTop() )
						
						If ( SA7->( MsSeek( xFilial("SA7") + cCliente + cLoja + cCodItem ) ) )
							cChave := SA7->A7_PRODUTO
						EndIf
						
				End Case
				
				SB1->( DbGoTop() )
				
				If ( SB1->( MsSeek( xFilial("SB1") + cChave ) ) )
					cCodItem := SB1->B1_COD
				Else
					cCodItem := ""
				EndIf				
				
			EndIf
			
			//Se não encontrar o produto pela tag ItemCode ou não for informada, 
			//verifica se foi informado pelo cliente, o código do fornecedor.
			If ( Empty( cCodItem ) )
				If ( XmlChildEx( oXMLItens:_ItensDeliverySchedulingInformation[nI], '_PRODCODSUPLLI' ) != Nil )
					cCodItem := oXMLItens:_ItensDeliverySchedulingInformation[nI]:_prodcodsuplli:Text
					cCodItem := PadR( cCodItem, TamSX3("B1_COD")[1], " " )
					
					SB1->( DbSetOrder(1) )	//B1_FILIAL + B1_COD
					SB1->( DbGoTop() )
					
					If ( !SB1->( MsSeek( xFilial("SB1") + cCodItem ) ) )
						cCodItem := ""
						cLog := STR0062 + CRLF	//"Produto não encontrado."
						cLog += STR0063 + oXMLItens:_ItensDeliverySchedulingInformation[nI]:_itemcode:Text	//"Código: "
					EndIf
				EndIf
			EndIf	
			
			//Transforma em array quando o nó de entrega tiver apenas um item
			If ( ValType( oXMLItens:_ItensDeliverySchedulingInformation[nI]:_Deliveries:_Delivery) != "A" )
				XmlNode2Arr( oXMLItens:_ItensDeliverySchedulingInformation[nI]:_Deliveries:_Delivery, "_DELIVERY")
			EndIf
			
			//---------------------------------------------------------------------------------------
			// Carrega dados da entrega do item
			//---------------------------------------------------------------------------------------
			For nJ := 1 To Len( oXMLItens:_ItensDeliverySchedulingInformation[nI]:_Deliveries:_Delivery )
				
				nCount++
				
				//Data e hora da entrega
				If ( XmlChildEx( oXMLItens:_ItensDeliverySchedulingInformation[nI]:_Deliveries:_Delivery[nJ], '_DHDELIVERYREMIT' ) != Nil )
					cDataEnt := oXMLItens:_ItensDeliverySchedulingInformation[nI]:_Deliveries:_Delivery[nJ]:_dhdeliveryremit:Text
					cHoraEnt := StrTran( SubStr( cDataEnt, 12, 5 ), ":" )
					cDataEnt := StrTran( SubStr( cDataEnt, 1, 10 ), "-" )
				EndIf
		
				//Quantidade do item
				If ( XmlChildEx( oXMLItens:_ItensDeliverySchedulingInformation[nI]:_Deliveries:_Delivery[nJ], '_QUANTREQUEST' ) != Nil )
					nQtde := Val( oXMLItens:_ItensDeliverySchedulingInformation[nI]:_Deliveries:_Delivery[nJ]:_quantrequest:Text )
				EndIf
				
				//Tipo da entrega ( 1-Firme | 4-Previsto | 10-Imediato | 10E-Prometido )
				If ( XmlChildEx( oXMLItens:_ItensDeliverySchedulingInformation[nI]:_Deliveries:_Delivery[nJ], '_DELIVERYSTATUS' ) != Nil )
					cTipoEnt := oXMLItens:_ItensDeliverySchedulingInformation[nI]:_Deliveries:_Delivery[nJ]:_deliverystatus:Text
					
					Do Case
						Case cTipoEnt == "1"
							cTipoEnt := "1"
						Case cTipoEnt == "4"
							cTipoEnt := "2"
						Case ctipoEnt == "10"
							cTipoEnt := "1"
						OtherWise
							cTipoEnt := "2"
					End Case
					
				EndIf
				
				//Monta array com dados dos itens para atualização do Model	
				AAdd( aDetail, {} )			
				AAdd( aDetail[nCount], { "DX_PRODUTO"	, cCodItem } )
				AAdd( aDetail[nCount], { "DX_QUANT"	, nQtde } )
				AAdd( aDetail[nCount], { "DX_TIPENT"	, cTipoEnt } )
				AAdd( aDetail[nCount], { "DX_DATENT"	, SToD( cDataEnt ) } )
				AAdd( aDetail[nCount], { "DX_HORENT"	, cHoraEnt } )
				
				If ( !Empty( SB1->B1_TS ) )
					AAdd( aDetail[nCount], { "DX_TES"	, SB1->B1_TS } )
				ElseIf ( !Empty( cTESPadrao ) )
					AAdd( aDetail[nCount], { "DX_TES"	, cTESPadrao } )
				EndIf
				
				AAdd( aDetail[nCount], { "ActionItem"	, nAcaoItem } )
								
				//Monta array de busca em caso de alteração
				AAdd( aBusca, {} )
				AAdd( aBusca[nCount], { "DX_PRODUTO"	, cCodItem } )
				AAdd( aBusca[nCount], { "DX_TIPENT"	, cTipoEnt } )
				AAdd( aBusca[nCount], { "DX_DATENT"	, SToD( cDataEnt ) } )
				AAdd( aBusca[nCount], { "DX_HORENT"	, cHoraEnt } )
				
			Next nJ
		
		Next nI
		
		//Carrega model com estrutura da Programação de Entrega
		oModel := FwLoadModel( 'MATA412' )
		
		DbSelectArea("SD0")		//Programação de Entrega
		SD0->( DbSetOrder(2) )	//D0_FILIAL + D0_CLIENTE + D0_LOJA + D0_PEDCLI
				
		//Seta o Model com a operação realizada, de acordo com a função da mensagem	
		Do Case
			
			//Alteração
			Case nFuncao == MESSAGE_FUNCTION_UPDATE
				
				cLog := STR0051 + cPedCli + "."	//"Alteração do pedido "
				
				INCLUI := .F.		
				
				//Busca programação de entrega na base para alteração
				If ( SD0->( MsSeek( xFilial("SD0") + cCliente + cLoja + cPedCli ) ) )
					oModel:SetOperation( MODEL_OPERATION_UPDATE )
				Else
					cLog += CRLF + STR0052 + cPedCli + STR0053	//"Pedido " | " não encontrado na base de dados."
					GravarLog( cLog, ProcName() )
					Return .F.
				EndIf	
			
			//Substituição	
			Case nFuncao == MESSAGE_FUNCTION_REPLACE
			
				cLog := STR0067 + cPedCli + "."	//"Substituição do pedido "
				
				//Busca programação de entrega na base para substituição
				If ( SD0->( MsSeek( xFilial("SD0") + cCliente + cLoja + cPedCli ) ) )
					INCLUI := .F.
					oModel:SetOperation( MODEL_OPERATION_UPDATE )
				Else
					INCLUI := .T.
					oModel:SetOperation( MODEL_OPERATION_INSERT )
				EndIf
				
			//Original (Inclusão)
			Case nFuncao == MESSAGE_FUNCTION_INSERT
			
				cLog := STR0054 + cPedCli + "."		//"Inclusão do pedido "
				
				INCLUI := .T.
				
				//Busca programação de entrega na base para inclusão
				If !( SD0->( MsSeek( xFilial("SD0") + cCliente + cLoja + cPedCli ) ) )
					oModel:SetOperation( MODEL_OPERATION_INSERT )
				Else
					cLog += CRLF + STR0052 + cPedCli + STR0055	//"Pedido " | " já existe na base de dados."
					GravarLog( cLog, ProcName() )
					If !lUsaColab
						MA412Conf( aDocs[1] )
					EndIf
					Return .F.
				EndIf
				
			//Resposta
			Case nFuncao == MESSAGE_FUNCTION_RESPONSE
				Return .F.
				
		EndCase
		
		//Ativa o model
		oModel:Activate()	
		oModelMast	:= oModel:GetModel( "SD0MASTER" )
		oModelDet	:= oModel:GetModel( "SDXDETAIL" )
		
		TrataModel( @oModelMast, @oModelDet, nFuncao, oModel:GetOperation() )	//Prepara o Model de acordo com a função da mensagem
		UpdateModel( @oModelMast, @oModelDet, aMaster, aDetail, aBusca, "ActionItem" )
		
		If oModel:VldData()
		
			//Confirma o documento junto ao servidor TSS
			If !lUsaColab
				If ( MA412Conf( aDocs[1] ) < 0 )
				
					//Em caso de falha na confirmação, cancela as alterações no Model
					oModel:CancelData()
					cLog := STR0060 + CRLF	//"Operação cancelada."
					cLog += STR0061			//"Falha na confirmação do documento junto ao servidor TOTVS Colaboração."
					GravarLog( cLog, ProcName() )
					Help( " ", 1, 'MA412CONF', , cLog, 1 )
					lRet := .F.
					
				EndIf
			EndIf			

			//Grava o model
			If ( lRet )
			
				oModel:CommitData()	//Aciona code block definido no método New do Model ( { |oModel| MA412Grava( oModel ) } )
				FErase( cArquivo )	//Apaga arquivo recebido
			
				If ( lLog )
					cLog := STR0052 + cPedCli + STR0056 + CRLF + cArquivo	//"Pedido " | " gravado com sucesso!"
					GravarLog( cLog, ProcName() )
				EndIf
			
				lRet := .T.
			
			EndIf
			
		Else
			//Trata erro de gravação do model
			lRet := .F.
			aMsgErro := oModel:GetErrorMessage()
			cLogErro := ''
			cLog := STR0057 + CRLF + cArquivo + CRLF	//"Falha na gravação dos dados recebidos!"
			
			For nI := 1 To Len(aMsgErro)
		    
				If ( ValType( aMsgErro[nI] ) == 'C' )
					cLogErro += aMsgErro[nI] + '|'
					cLog += aMsgErro[nI] + CRLF
				EndIf 
				
			Next nI

			If ( lLog )				
				GravarLog( cLog, ProcName() )
			EndIf
			Help( " ", 1, 'MA412GRVDOC', , cLogErro, 1 )			
			ConOut( cLogErro )
		EndIf		
	
	Else
		lRet := .F.
		
		If ( lLog )
			cLog := STR0058 + CRLF	//"Falha na leitura do arquivo XML recebido."
			cLog += cLog + IIf( Empty( cWarning ), cError, cWarning )
			GravarLog( cLog, ProcName() )
		EndIf
	EndIf
	
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
//-------------------------------------------------------------------
//                  Funções de validação da rotina
//-------------------------------------------------------------------
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412VldQtd
Valida a quantidade para o desmembramento do item.

@sample 	MA412VldQtd() 
@return	lRet - (.T. ou .F.) Indica se a quantidade é válida.

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function MA412VldQtd( nQtde )

Local lRet := .T.

If ( nQtde <= 0 )
	
	Help( " ", 1, "MA412VldQtd", , STR0036, 1 )	//"Quantidade deve ser maior que 0!"
	lRet := .F.
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412VldDt
Valida a data digitada para o desmembramento do item.

@sample 	MA412VldDt() 
@return	lRet - (.T. ou .F.) Indica se a data é válida.

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function MA412VldDt( dData )

Local lRet := .T.

If ( Empty(dData) ) .Or. ( dData < dDataBase )
	
	Help( " ", 1, "MA412VldDt", , STR0037, 1 )	//"Data de entrega deve ser igual ou superior à data base!"
	lRet := .F.
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412VlCli
Valida o código do cliente.

@sample 	MA412VlCli() 
@param		cCliente - Código do cliente a ser validado
			cLoja - Código da loja do cliente.
@return		( Boolean ) Indica se o cliente informado existe 
          	ou não.

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function MA412VlCli( cCliente, cLoja )

Local lRet 	:= .T.			//Indica se o cliente foi encontrado ou não
Local aArea	:= GetArea()	//Salva o contexto atual

//Busca o cliente de acordo com o código e a loja informados
If ( !Empty(cCliente) .And. !Empty(cLoja) )
	DBSelectArea("SA1")
	SA1->(DBSetOrder(1))
	lRet := SA1->( DBSeek( xFilial("SA1") + cCliente + cLoja ) )
EndIf

//Se não encontrar o cliente alerta usuário
If ( !lRet )
	Help( " ", 1, "MA412VlCli", , STR0015, 1 )	//"Cliente não encontrado! Verifique o código do cliente e a loja."
EndIf

RestArea(aArea)	//Restaura contexto salvo

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412VldLn
Valida os dados da linha do grid.

@sample 	MA412VldLn( oModel ) 
@param		oModel - Modelo de dados.
@return	(Boolean) Indica se a linha está OK.

@author	Danilo Dias
@since		31/07/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function MA412VldLn( oModel )

	Local lExistePV := ExistePV()
	
	//Validação caso o Pedido de Venda tenha sido gerado
	If ( lExistePV )
		
		//Valida se a TES da linha está preenchida	
		If ( Empty( oModel:GetValue( "SDXDETAIL", "DX_TES" ) ) )
			Help( " ", 1, STR0018, , STR0023, 1 )	// "Atenção" | "O preenchimento da TES é obrigatório, para alterar ou incluir um item, quando o Pedido de Venda já foi gerado."
			Return .F.
		EndIf
		
	EndIf
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412VlCan
Validações para cancelamento do Pedido de Venda.

@sample 	MA412VlCan() 
			
@return	(Boolean) Indica se o Pedido de Venda pode ser cancelado.

@author	Danilo Dias
@since		13/08/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function MA412VlCan()

	Local aArea		:= GetArea()
	Local lExistePV 	:= .F.
	
	//Verifica se existe pedido de venda
	If ( !ExistePV() )
		Help( " ", 1, STR0018, , STR0009, 1 )	// "Atenção" | "Pedido de Venda não gerado"
		Return .F.
	EndIf	
	
	//Valida se há itens faturados
	If ( SD0->D0_STATUS $ "02|03" )
		Help( " ", 1, STR0018, , STR0035, 1 )	// "Atenção" | "Não é possível cancelar um Pedido de Venda com itens faturados."
		Return .F.
	EndIf
	
	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MA412VldPV
Validações para geração do Pedido de Venda.

@sample 	MA412VldPV( oModel ) 
@param		oModel - Modelo de dados da rotina.
			
@return	(Boolean) Indica se o Pedido de Venda pode ser gerado.

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function MA412VldPV( oModel )

	Local aArea		:= GetArea()
	Local lExistePV 	:= .F.
	Local cCondPag	:= ""
	Local cFilSDX	:= xFilial("SDX")
	
	//Verifica se existe pedido de venda, não considerando se a gravação foi acionada pela Ma412GerPV()
	lExistePV := ExistePV()	
	
	//Valida se o Pedido de Venda já foi gerado
	If ( !Empty( SD0->D0_STATUS ) ) .And. ( !lExistePV )
		Help( " ", 1, STR0018, , STR0014, 1 )	// "Atenção" | "A Programação de Entrega selecionada já possui Pedido de Venda gerado!"
		Return .F.
	EndIf
	
	//Valida preenchimento da condição de pagamento
	If ( ValType( oModel ) == "O" )
		cCondPag := oModel:GetValue( "SD0MASTER", "D0_CONDPAG" )
	Else
		cCondPag := SD0->D0_CONDPAG
	EndIf
	
	If ( Empty( cCondPag ) )
		Help( " ", 1, STR0018, , STR0016, 1 )	// "Atenção" | "Informe a condição de pagamento para a geração do Pedido de Venda."
		Return .F.
	EndIf

	
	//Valida os itens da Programação de Entrega
	DbSelectArea("SDX")
	SDX->(DbSetOrder(1))	//DX_FILIAL +  DX_NUMENT + DX_ITEM + DX_PRODUTO
	
	If ( SDX->( MsSeek( cFilSDX + SD0->D0_NUMENT ) ) )
	
		While SDX->(!Eof()) .And. SDX->DX_FILIAL == cFilSDX .And. SDX->DX_NUMENT == SD0->D0_NUMENT
			
			//Valida preenchimento da TES nos itens
			If ( Empty( SDX->DX_TES ) )
				Help( " ", 1, STR0018, , STR0017, 1 )	// "Atenção" | "Informe o tipo de saída de todos os itens para a geração do Pedido de Venda."
				Return .F.
			EndIf
			
			SDX->(DbSkip())
			
		EndDo
		
	EndIf
	
	RestArea(aArea)

Return .T.


//-------------------------------------------------------------------
//-------------------------------------------------------------------
//                    Funções auxiliares da rotina
//-------------------------------------------------------------------
//-------------------------------------------------------------------

//----------------------------------------------------------------------------
/*/{Protheus.doc} AddHeader
Adiciona os dados do cabeçalho ao array aMaster para a ExecAuto da MATA410.

@sample 	AddHeader( oModelMaster, aMaster, nOperation ) 
@param		oModelMaster - Modelo com dados da tabela master (SD0).
			aMaster - Array passado por referência para os dados da master.
			nOperation - Operação que está sendo executada. (Inclusão, alteração ou exclusão)
			
@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//----------------------------------------------------------------------------
Static Function AddHeader( oModelMaster, aMaster, nOperation )

	//Adiciona cabeçalho ao array aMaster para gravação do pedido de venda via ExecAuto
	AAdd( aMaster, { "C5_FILIAL", xFilial("SC5"), Nil } )
	
	//Não adiciona o número do pedido se for uma inclusão
	If ( nOperation != MODEL_OPERATION_INSERT )
		AAdd( aMaster, { "C5_NUM", oModelMaster:GetValue( "D0_PEDIDO" ), Nil } )
	EndIf
	
	AAdd( aMaster, { "C5_TIPO"   , "N", Nil } )
	AAdd( aMaster, { "C5_CLIENTE", oModelMaster:GetValue( "D0_CLIENTE" ), Nil } )
	AAdd( aMaster, { "C5_LOJACLI", oModelMaster:GetValue( "D0_LOJA" ), Nil } )
	AAdd( aMaster, { "C5_TIPOCLI", Posicione("SA1",1,(xFilial("SA1")+oModelMaster:GetValue( "D0_CLIENTE" )+oModelMaster:GetValue( "D0_LOJA" )),"A1_TIPO"), Nil } )
	AAdd( aMaster, { "C5_CONDPAG", oModelMaster:GetValue( "D0_CONDPAG" ), Nil } )
	AAdd( aMaster, { "C5_TABELA" , oModelMaster:GetValue( "D0_TABELA" ), Nil } )
	AAdd( aMaster, { "C5_EMISSAO", oModelMaster:GetValue( "D0_EMISSAO" ), Nil } )
	AAdd( aMaster, { "C5_NUMENT" , oModelMaster:GetValue( "D0_NUMENT" ), Nil } )
	If cPaisLoc == "ARG"
		AAdd( aMaster, { "C5_PAISENT" , Posicione("SA1",1,(xFilial("SA1")+oModelMaster:GetValue( "D0_CLIENTE" )+oModelMaster:GetValue( "D0_LOJA" )),"A1_PAIS"), Nil } )
	EndIf
	AAdd( aMaster, { "C5_ORIGEM" , "MATA412", Nil } )
	
Return .T.

//----------------------------------------------------------------------------
/*/{Protheus.doc} AddItem
Adiciona os dados do item ao array aDetail para a ExecAuto da MATA410.

@sample 	AddItem( oModelMaster, oModelDetail, aDetail, nPos, nOperation ) 
@param		oModelMaster - Modelo com dados da tabela master (SD0).
			oModelDetail - Modelo com dados da tabela detail (SDX).
			aDetail - Array passado por referência para os dados da detail.
			nPos - Indica a posição para o GoLine no Model Detail
			nOperation - Operação que está sendo executada. (Inclusão, alteração ou exclusão)
			
@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//----------------------------------------------------------------------------
Static Function AddItem( oModelMaster, oModelDetail, aDetail, nPos, nOperation )

	Local nI 		:= 0	//Indice para incluir item no array
	Local cExclui	:= ""	//Indica se a linha deve ser excluída (S -> Exclui | N -> Não exclui)
	Local cItem	:= ""	
	Local lLibera	:= SuperGetMV( "MV_FATLBAT", .F., ".T." )
	Local lGeraPV	:= IsInCallStack("MA412GerPV")
	
	nI			:= Len(aDetail) + 1
	cExclui 	:= "N"
	
	//Adiciona item ao array aDetail para gravação do pedido de venda via ExecAuto
	AAdd( aDetail, {} )
	oModelDetail:GoLine(nPos)	//Posiciona o model na linha
	
	cItem := AllTrim(oModelDetail:GetValue( "DX_ITEM" ))
	
	//Verifica se linha foi excluída
	If ( oModelDetail:IsDeleted() )
		cExclui := "S"
	EndIf
	
	//Formata a hora
	If ( !Empty( oModelDetail:GetValue( "DX_HORENT" ) ) )
		cHora := oModelDetail:GetValue( "DX_HORENT" )
		//cHora := SubStr( cHora, 1, 2 ) + ":" + SubStr( cHora, 3, 2 )
	Else
		cHora := ""
	EndIf
	
	//Não adiciona se for uma inclusão
	//Esse item é adicionado para localizar a linha na Execauto quando a linha é alterada ou excluída
	If ( !lGeraPV ) .And. (!oModelDetail:IsInserted())
		AAdd( aDetail[nI], { "LINPOS", "C6_ITEM", cItem } )
	EndIf
	
	AAdd( aDetail[nI], { "AUTDELETA", cExclui, nil } )	//Indica se a linha está sendo excluída ou não
	AAdd( aDetail[nI], { "C6_FILIAL", xFilial("SC6"), nil } )
	
	//Não adiciona o número do pedido se for uma inclusão
	If ( nOperation != MODEL_OPERATION_INSERT )
		AAdd( aDetail[nI], { "C6_NUM", oModelMaster:GetValue( "D0_PEDIDO" ), nil } )	
	EndIf
		
	AAdd( aDetail[nI], { "C6_ITEM"   , cItem, Nil } )
	AAdd( aDetail[nI], { "C6_PRODUTO", oModelDetail:GetValue( "DX_PRODUTO" ), Nil } )
	AAdd( aDetail[nI], { "C6_QTDVEN" , oModelDetail:GetValue( "DX_QUANT" ), Nil } )	
	
	If ( lLibera )
		AAdd( aDetail[nI], { "C6_QTDLIB" , oModelDetail:GetValue( "DX_QUANT" ), Nil } )
	EndIf
		
	AAdd( aDetail[nI], { "C6_TES"    , oModelDetail:GetValue( "DX_TES" ), Nil } )
	
	If ( oModelDetail:GetValue( "DX_TIPENT" ) == "1")
		AAdd( aDetail[nI], { "C6_TPOP"   , "F", Nil } )
	Else
		AAdd( aDetail[nI], { "C6_TPOP"   , "P", Nil } )
	EndIf
	
	AAdd( aDetail[nI], { "C6_ENTREG" , oModelDetail:GetValue( "DX_DATENT" ), Nil } )
	AAdd( aDetail[nI], { "C6_HORENT" , cHora, Nil } )
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateModel 
Função para atualização do model conforme dados recebidos via 
TOTVS Colaboração.

@sample 	UpdateModel(	oModelMaster, oModelDetail, aMaster,;
                       	aDetail, aBusca, cCampoAcao )
@param		oModelMaster (Ref)	Modelo de dados da Master
			oModelDetail (Ref)	Modelo de dados da Detail
			aMaster 				Dados da master
			aDetail				Dados da detail
			aBusca					Dados para a busca do registro no model
			cCampoAcao				Nome do campo que indica a ação sobre o registro
				
@return	lRet - Inidica se a execução foi bem sucedida.

@author	Danilo Dias
@since		29/08/2012
@version	P11.7
/*/
//-------------------------------------------------------------------
Static Function UpdateModel( oModelMaster, oModelDetail, aMaster,;
                             aDetail, aBusca, cCampoAcao )

//Variaveis de Proteção
//Local aSaveLine	:= FWSaveRows()	//Salva contexto do model ativo
Local aArea		:= GetArea()		//Salva alias ativo

//Variáveis da função
Local lRet				:= .T.		//Retorno da função
Local nI				:= 0		//Contador de uso geral
Local nL				:= 0		//Contador de uso geral
Local nPosCodigo		:= 0		//Posição do campo que contém o código para busca no array de itens
Local nPosAcao		:= 0		//Posição do campo que contém a ação sobre o item
Local nAcao			:= 0		//Ação sobre o item ( 1-Adicionar | 2-Excluir | 3-Alterar | 11-Não Alterada )
Local lExiste			:= .F.		//Indica se existe o item na detail do model

//Valores default para os parâmetros da função
Default oModelMaster	:= Nil
Default oModelDetail	:= Nil
Default aMaster		:= {}
Default aDetail		:= {}
Default aBusca	 	:= {}

//Atualiza Master
For nI := 1 To Len( aMaster )
	oModelMaster:SetValue( aMaster[nI][1], aMaster[nI][2] )
Next nI
	
//Atualiza Detail
For nI := 1 To Len( aDetail )
	
	nPosAcao	:= aScan( aDetail[nI], { |nLinha| nLinha[1] == cCampoAcao } )		//Posição da ação no array
	nAcao		:= aDetail[nI][nPosAcao][2]												//Ação realizada no item
	
	//Busca a linha na Detail de acordo com os dados do array aBusca	
	lExiste := oModelDetail:SeekLine( aBusca[nI] )
		
	//Verifica a operação sobre o item	
	If ( nAcao == ACTION_ITEM_DELETE )
		If ( lExiste )
			//Se o item foi excluido na origem e existe no destino, exclui do model
			oModelDetail:DeleteLine()
		EndIf
	Else
		//Se não existir o registro na detail adiciona linha
		If ( !lExiste )
			//Verifica se já existe linha em branco na detail antes de incluir
			If ( !oModelDetail:IsEmpty() )
				nAux := oModelDetail:Length()				
				If ( !oModelDetail:AddLine() == nAux + 1 )
				     lRet := .F.
				     Exit
				EndIf
				
			EndIf
		EndIf
		
		//Atualiza itens do model com os dados recebidos
		For nL := 1 To Len(aDetail[nI])-1
			oModelDetail:LoadValue( aDetail[nI][nL][1], aDetail[nI][nL][2] )
		Next nL			
	EndIf				
Next nI

//FWRestRows( aSaveLine )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMaxValue
Obtém o maior valor de uma coluna em um ou mais grids.

@sample 	GetMaxValue( aModel, cCampo )
@param		aModel - Array contendo objetos que representam uma ou 
			         mais grids do model para comparar os valores da 
			         coluna e obter o maior valor.
			cCampo - Nome da coluna para obter o maior valor. 
@return	xMax	- Maior valor encontrado para a coluna.

@author	Danilo Dias
@since		07/08/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function GetMaxValue( aModel, cCampo )

Local nI 		:= 1
Local nJ 		:= 1
Local xMax		:= Nil
Local xValue 	:= Nil

For nI := 1 To Len(aModel)

	For nJ := 1 To aModel[nI]:Length()
		
		aModel[nI]:GoLine(nJ)
		
		If ( !aModel[nI]:IsDeleted() )
			xValue := aModel[nI]:GetValue( cCampo )
		EndIf
		
		If ( xMax == Nil ) .Or. ( xValue > xMax )
			xMax := xValue
		EndIf			
		
	Next nJ
	
Next nI 

Return xMax


//-------------------------------------------------------------------
/*/{Protheus.doc} NomeCampo
Retorna o título e a descrição do campo no dicionário de dados.

@sample 	NomeCampo( cCampo )
@param		cCampo - Nome do campo. 
@return	Array	- { cTitulo, cDescricao }

@author	Danilo Dias
@since		07/08/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function NomeCampo( cCampo )

Local aArea		:= GetArea()
Local cTitulo	:= ""
Local cDesc		:= ""

Default cCampo := ""

DbSelectArea("SX3")
SX3->(DbSetOrder(2))

If ( SX3->( DbSeek( cCampo ) ) )

	cTitulo	:= X3Titulo()
	cDesc		:= X3Descric()
	
EndIf

RestArea( aArea )

Return { cTitulo, cDesc }

//-------------------------------------------------------------------
/*/{Protheus.doc} ExistePV
Verifica se foi gerado Pedido de Venda para uma Programação de 
Entrega.

@sample 	ExistePV() 
@return	(Boolean) Indica se existe Pedido de Venda 
           para a Programação de Entrega.

@author	Danilo Dias
@since		31/07/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ExistePV()

	Local lRet	 	:= .F.
	Local cPedido	:= ""
	
	cPedido := M->D0_PEDIDO
	//Verifica se tem pedido gerado, desconsiderando se a rotina de 
	//geração do Pedido está sendo executada
	lRet := !Empty( cPedido ) .And. !IsInCallStack( "MA412GerPV" )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GravarLog
Grava mensagem no arquivo de log.

@sample 	GravarLog( cMsg )
@param		cMsg		Mensagem a ser gravada no log
@param		cFuncao	Funcao que acionou o log

@author	Danilo Dias
@since		11/09/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function GravarLog( cMsg, cFuncao )

Local aArea		:= Getarea()
Local cLogFile	:= "\xml\DeliverySchedule.log"
Local cLog		:= ""

Default cMsg 	:= ""
Default cFuncao := ""

// Abre arquivo de Log do recebimento de mensagens
If ( !File( cLogFile, 0, .F. ) )
	nHandleLog := FCreate( cLogFile )
	cLog := STR0059 + CRLF	//"LOG DE TRANSAÇÕES DE PROGRAMAÇÃO DE ENTREGA"
	cLog += CRLF + "**************************************************************************************************"
Else
	nHandleLog := FOpen( cLogfile, FO_READWRITE, , .F. )
	cLog := "" + CRLF
EndIf

// Se o arquivo for aberto ou criado com sucesso grava log
If ( nHandleLog != -1 )
	
	FSeek( nHandleLog, 0, 2 )
	FWrite( nHandleLog, cLog + CRLF )

	// Grava log no arquivo
	cLog := "[" + DToC( Date() ) + " " + Time() + "] - " + cFuncao + CRLF + cMsg
	FWrite( nHandleLog, cLog )
	FClose( nHandleLog )

EndIf

RestArea( aArea )

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} TrataModel
Trata o modelo de dados de acordo com a função da mensagem.

- Substituição: 	Exclui todas as entregas para substituir,
					respeitando as regras de validação.
- Alteração:		Exclui as entregas com status Previsto e as demais
					que possuírem data de entrega igual ou superior
					à data base do sistema.

@sample 	TrataModel( oModelMast, oModelDet, nFuncao, nOpc )
@param		oModelMaster (Ref)	Modelo de dados da Master
@param		oModelDetail (Ref)	Modelo de dados da Detail
@param		nFuncao				Funcao da mensagem recebida
@param		nOpc					Operação executada no Model

@author	Danilo Dias
@since		14/09/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function TrataModel( oModelMast, oModelDet, nFuncao, nOpc )

Local aArea		:= GetArea()	
Local nI		:= 1
Local cTipoEnt	:= ""
Local dDataEnt	:= ""

Default nFuncao := Nil

If ( nFuncao != Nil )
	
	Do Case
	
		//Alteração
		Case nFuncao == MESSAGE_FUNCTION_UPDATE
			
			For nI := 1 To oModelDet:Length()
						
				oModelDet:GoLine(nI)
				
				cTipoEnt := oModelDet:GetValue( "DX_TIPENT" )
				dDataEnt := oModelDet:GetValue( "DX_DATENT" )
				
				If( !Empty( oModelDet:GetValue( "DX_NOTA" ) ) )
					Loop
				EndIf
				
				//Exclui entregas com status de Previsto
				If ( cTipoEnt == "2" )
					oModelDet:DeleteLine()
					Loop
				EndIf
				
				//Exclui entregas com data igual ou superior à data base
				If ( dDataEnt >= dDataBase )
					oModelDet:DeleteLine()
				EndIf
				
			Next nI
	
		//Substituição
		Case nFuncao == MESSAGE_FUNCTION_REPLACE
			
			If ( nOpc == MODEL_OPERATION_UPDATE )
			
				//Exclui todas as entregas para substituição
				For nI := 1 To oModelDet:Length()
					
					oModelDet:GoLine(nI)
					
					If( Empty( oModelDet:GetValue( "DX_NOTA" ) ) )
						oModelDet:DeleteLine()
					EndIf					
					
				Next nI
			
			EndIf
			
	End Case
	
EndIf

Return Nil


Function At412LtOs()   
Local oLegenda := FWLegend():New() // Objeto FwLegend. 

oLegenda:Add("","YELLOW",STR0009) // "Pedido de Venda não gerado" 
oLegenda:Add("","GREEN",STR0010) // "Pedido de Venda gerado" 
oLegenda:Add("","BLUE",STR0011) // "Pedido de Venda parcialmente entregue" 
oLegenda:Add("","RED",STR0012)// "Pedido de Venda entregue"

oLegenda:Activate() 
oLegenda:View() 
oLegenda:DeActivate() 
Return Nil

static function UsaColaboracao(cModelo)
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
endif
Return (lUsa)


//-------------------------------------------------------------------
/*/{Protheus.doc} Ma412VlPro()
Valida se existe preço de venda no produto, ou na tabela de preços

@sample 	Ma412VlPro() 
@return	(Boolean) Indica se existe produto com preço de venda 
			cadastrado
           
@author	Serviços
@since		19/11/2014
@version	P11
/*/
//-------------------------------------------------------------------
	
Function Ma412VlPro()

Local aArea		:= GetArea()
Local lRet			:= .T.
Local cProduto 	:= ""
Local oModel		:= FWModelActive()
Local oModelSD0	:= oModel:GetModel("SD0MASTER")
Local oModelSDX 	:= oModel:GetModel("SDXDETAIL")
Local cVar			:= ReadVar()
Local nX			:= 0

If cVar $"M->D0_TABELA"
	
	If !(Empty(FwFldget( "DX_PRODUTO" )))
		If !(Empty(FwFldget( "D0_TABELA" )))
			dbSelectArea("DA0")
			DA0->(dbSetOrder(1))
			If dbSeek(xFilial("DA0")+FwFldget( "D0_TABELA" ))
				For nX:= 1 to oModelSDX:Length()
					oModelSDX:GoLine(nX)
					cProduto := FwFldget( "DX_PRODUTO" )	
					nValProd:= Posicione("DA1",1,(xFilial("DA1") + FwFldget( "D0_TABELA" ) + cProduto),"DA1_PRCVEN")
					If nValProd <= 0
						nValProd:= Posicione("SB1",1,(xFilial("SB1")+cProduto),"B1_PRV1")
						If nValProd <= 0
							lRet := .F.
							Help( " ", 1,STR0018,,STR0070, 1)//"Existe(m) produto(s) informado(s) que não pertence(m) a tabela de preço, ou nao possue(m) preço de venda cadastrado."
							Exit
						EndIf	
					EndIf
				Next nX	
			EndIf
		Else
			//Se limpar a tabela de preço do cadastro valida os produtos na sb1
			For nX:= 1 to oModelSDX:Length()
				oModelSDX:GoLine(nX)
				cProduto := FwFldget( "DX_PRODUTO" )
				nValProd:= Posicione("SB1",1,(xFilial("SB1")+cProduto),"B1_PRV1") 
				If nValProd <= 0
					lRet := .F.
					Help( " ", 1,STR0018,,STR0070, 1)//"Existe(m) produto(s) informado(s) que não pertence(m) a tabela de preço, ou nao possue(m) preço de venda cadastrado."
					Exit
				EndIf
			Next nX	
		EndIf			
	EndIf
	
Else
	//Verifica se o produto informado possui preço de venda na tabela de preços, 
	//ou no próprio cadastro
	cProduto := FwFldget( "DX_PRODUTO" )
	If !(Empty(FwFldget( "D0_TABELA" )))
		dbSelectArea("DA0")
		DA0->(dbSetOrder(1))
		If dbSeek(xFilial("DA0")+FwFldget( "D0_TABELA" ))
			nValProd:= Posicione("DA1",1,(xFilial("DA1") + FwFldget( "D0_TABELA" ) + cProduto),"DA1_PRCVEN")
			If nValProd <= 0
				nValProd:= Posicione("SB1",1,(xFilial("SB1")+cProduto),"B1_PRV1")
				If nValProd <= 0
					lRet := .F.
					Help( " ", 1,STR0018,,STR0071,1)//"Produto sem preço de venda cadastrado"
				EndIf	
			EndIf
		EndIf	
	Else
		nValProd:= Posicione("SB1",1,(xFilial("SB1")+cProduto),"B1_PRV1") 
		If nValProd <= 0
			lRet := .F.
			Help( " ", 1,STR0018,,STR0071, 1 )	//"Produto sem preço de venda cadastrado"
		EndIf
	EndIf	
EndIf
	
RestArea(aArea)	
	
Return lRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} Ma412MtFlt()
Retorno a quantidade entregue do item conforme SC6

@sample 	Ma412MtFlt() 
@return	(Caracter) Filtro de itens não faturados.
           
@author	 Serviços
@since	 30/05/2019
@version P12
/*/
//-------------------------------------------------------------------

Function Ma412MtFlt(cNUMENT)

Local aArea 	:= GetArea()
Local aAreaSD0 	:= SD0->(GetArea())
Local aAreaSDX 	:= SDX->(GetArea())
Local aItens	:= {}
Local cExprs := "(DX_NOTA = '" + SPACE(GetSX3Cache('DX_NOTA','X3_TAMANHO')) + "')"
Local cAliasQry	:= ""
Local cPedido	:= ""
Local nItens	:= 0
Local cFilSDX	:= xFilial("SDX")


Default cNUMENT := ""

DbSelectArea("SD0")
SD0->(DbSetOrder(1))	//D0_FILIAL + D0_PEDIDO + D0_CLIENTE + D0_LOJA
If SD0->( MsSeek( xFilial("SD0") + cNUMENT) )
	cPedido := SD0->D0_PEDIDO

	If !Empty(cPedido)
		
		DbSelectArea("SDX")
		SDX->(DbSetOrder(1))	//DX_FILIAL + DX_NUMENT + DX_ITEM + DX_PRODUTO
		If SDX->( MsSeek( xFilial("SDX") + SD0->D0_NUMENT ) )
			While SDX->(!Eof()) .And. SDX->DX_FILIAL == cFilSDX .And. SDX->DX_NUMENT == SD0->D0_NUMENT
				aAdd(aItens,{SDX->DX_ITEM,SDX->DX_PRODUTO})
				SDX->(DbSkip())			
			EndDo
		
			cAliasQry := GetNextAlias()
		
			cQuery := ""
			cQuery += "SELECT C6_ITEM, C6_QTDENT FROM" + RetSqlName( "SC6" )
			cQuery += "WHERE "
			cQuery += "C6_FILIAL = '" + xFilial( "SC6" )  + "' AND "
			cQuery += "C6_BLQ <> 'R' AND "
			cQuery += "C6_NUM = '" + cPedido  + "' AND ("
			
			For nItens := 1 To Len(aItens)
				cQuery += " (C6_ITEM = '" + aItens[nItens][1]  + "'"
				cQuery += " AND C6_PRODUTO = '" + aItens[nItens][2]  + "')"
				If nItens < Len(aItens)
					cQuery += " OR "
				EndIf
			Next nItens
			
			cQuery += ") AND D_E_L_E_T_=' ' ORDER BY C6_ITEM"
			cQuery := ChangeQuery(cQuery)
		
			DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
			
			While !(cAliasQry)->(Eof())
				cExprs += " OR (DX_ITEM = '" + (cAliasQry)->C6_ITEM + "' AND DX_QUANT > '" + STR((cAliasQry)->C6_QTDENT) + "')"
				(cAliasQry)->(DbSkip())
			Enddo
			(cAliasQry)->(DbCloseArea()) 
		EndIf
	EndIf
EndIf	

RestArea(aAreaSDX)
RestArea(aAreaSD0)
RestArea(aArea)

aSize(aAreaSDX, 0)
aAreaSDX := Nil
aSize(aAreaSD0, 0)
aAreaSD0 := Nil
aSize(aArea, 0)
aArea := Nil

Return cExprs

//-------------------------------------------------------------------
/*/{Protheus.doc} Ma412AltQt()
Verifica se produto e quantidade podem ser alterados.

@sample 	Ma412AltQt() 
@return	(Lógico) .T. - Podem ser feitas alteralções.
				 .F. - Não podem ser feitas alteralções.
           
@author	 Serviços
@since	 30/05/2019
@version P12
/*/
//-------------------------------------------------------------------

Function Ma412AltQt()

Local aArea		:= GetArea()
Local oModel 	:= Nil
Local oModelSDX	:= Nil
Local lAlt		:= .T.

oModel := FwModelActive()

oModelSDX := oModel:GetModel("SDXDETAIL")

If !Empty(oModelSDX:GetValue('DX_NOTA'))
	lAlt := .F.
EndIf

RestArea(aArea)

aSize(aArea, 0)
aArea := Nil

Return lAlt
