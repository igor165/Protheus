#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA807.ch'
#include "PLSMGER.CH"
#include "PLSMCCR.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA807
Funcao para abrir Visitas de Relacionamento
@author Oscar Zanin
@since 15/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA807()
Local oBrowse
LOCAL nFor := 0
LOCAL aAlias := {"B9W", "B9K", "B9L", "B9X", "BIN", "BB8", "BH7", "B9V", "BID", "B9L", "BAQ", "B9Q", "B9R", "B18", "BAX"}
LOCAL cAlias := ""
	
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B9W')
oBrowse:SetDescription(FunDesc())
	
	//Cria Legenda do Browse
obrowse:AddLegend( "!(Vazio(B9W_DATAVI))", "BLUE", STR0001) //"Visita Realizada"
obrowse:AddLegend( "(Vazio(B9W_DATAVI))", "GRAY", STR0002) //"Visita Pendente"
oBrowse:Activate()

//	Fecha as tabelas utilizadas na rotina
FOR nFor := 1 TO LEN(aAlias)
	IF SELECT(aAlias[nFor]) > 0
		cAlias := aAlias[nFor] 
		( cAlias )->( DbCloseArea() )
	ENDIF
NEXT
								
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 15/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	
Private aRotina := {}
	
Add Option aRotina Title STR0003 /*'Visualizar'*/ Action 'VIEWDEF.PLSA807' Operation 2 Access 0
Add Option aRotina Title STR0004 /*'Incluir'*/    Action 'VIEWDEF.PLSA807' Operation 3 Access 0
Add Option aRotina Title STR0005 /*'Alterar'*/    Action 'VIEWDEF.PLSA807' Operation 4 Access 0
Add Option aRotina Title STR0006 /*'Excluir'*/    Action 'VIEWDEF.PLSA807' Operation 5 Access 0
Add Option aRotina Title STR0007 /*'Imprimir'*/   Action 'VIEWDEF.PLSA807' Operation 8 Access 0
Add Option aRotina Title STR0008 /*'Copiar'  */   Action 'VIEWDEF.PLSA807' Operation 9 Access 0
	
AaDd( aRotina,{ STR0009 /*"Conhecimento"*/	,"PLS807BAN()"	, 0 , 0 } )
	
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since 13/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel // Modelo de dados construído
Local oStrB9W	:= FWFormStruct(1,'B9W')// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que iráconsiderar
Local oStrB9Q	:= FWFormStruct(1,'B9Q')// Cria as estruturas a serem usadas no Modelo de Dados
Local oStrB9R	:= FWFormStruct(1,'B9R') // Cria as estruturas a serem usadas no Modelo de Dados
Local oStrB9V	:= FWFormStruct(1,'B9V') // Cria as estruturas a serem usadas no Modelo de Dados

oModel := MPFormModel():New( 'PLSA807' , , {|| PLSA807OK(oModel) }, , {|| PLSA807SXE() } ) // Cria o objeto do Modelo de Dados e insere a funçao de pós-validação
	
oModel:addFields('MasterB9W',/*cOwner*/,oStrB9W)  // Adiciona ao modelo um componente de formulário
	
oModel:AddGrid('B9VDetail', 'MasterB9W', oStrB9V) // Adiciona ao modelo uma componente de grid
oModel:AddGrid('B9QDetail', 'B9VDetail', oStrB9Q) // Adiciona ao modelo uma componente de grid
oModel:AddGrid('B9RDetail', 'B9VDetail', oStrB9R) // Adiciona ao modelo uma componente de grid
 	
oModel:SetRelation( 'B9VDetail', { ;
	{ 'B9V_FILIAL'	, 'xFilial( "B9V" )' },;
	{ 'B9V_CODINT'	, 'B9W_CODINT' 		},;
	{ 'B9V_SEQB9V'	, 'B9W_SEQVIS' 		},;
	{ 'B9V_CODPRE'	, 'B9W_CODPRE'		} },;
	B9V->( IndexKey(  ) ) )  // Faz relacionamento entre os componentes do model

oModel:SetRelation( 'B9QDetail', {	;
	{ 'B9Q_FILIAL'	, 'xFilial( "B9Q" )'	},;
	{ 'B9Q_CODPRE'	, 'B9V_CODPRE' 		},;
	{ 'B9Q_CODINT'	, 'B9V_CODINT' 		},;
	{ 'B9Q_SEQVIS'	, 'B9V_SEQB9V' 		},;
	{ 'B9Q_CODLOC'	, 'B9V_CODSEQ'		} },;
	B9Q->( IndexKey(  ) ) )  // Faz relacionamento entre os componentes do model 

oModel:SetRelation( 'B9RDetail', { ;
	{ 'B9R_FILIAL' 	, 'xFilial( "B9R" )' },;
	{ 'B9R_CODINT'	, 'B9V_CODINT' 		},;
	{ 'B9R_CODPRE'	, 'B9V_CODPRE'		},;
	{ 'B9R_SEQVIS'	, 'B9V_SEQB9V' 		},;
	{ 'B9R_CODLOC'	, 'B9V_CODSEQ'		} },;
	B9R->( IndexKey(  ) ) )  // Faz relacionamento entre os componentes do model
	
oModel:GetModel( 'B9QDetail' ):SetUniqueLine( { 'B9Q_CODESP' } ) //Nao deixa cadastrar dois registros iguais
oModel:GetModel( 'B9RDetail' ):SetUniqueLine( { 'B9R_CODSER' } ) //Nao deixa cadastrar dois registros iguais
	
oModel:GetModel('MasterB9W'):SetDescription(FunDesc()) // Adiciona a descrição do Modelo de Dados
	
oModel:GetModel('B9QDetail'):SetOptional(.T.) //Torna o preenchimento da Grid opicional
oModel:GetModel('B9RDetail'):SetOptional(.T.) //Torna o preenchimento da Grid opicional
	
oModel:GetModel('B9VDetail'):SetNoInsertLine(.T.) //Não permite a adição de outro endereço, visto a visita ser em apenas um endereço
	
//Ajusta, temporariamente, o inicializador padrão do campo para a rotina.
oStrB9V:SetProperty( 'B9V_CODSEQ' , MODEL_FIELD_VALID, { || PLS807VLD(oModel) } )

//Seta os campos para inicializar com valroes corretos e evitar problemas futuros
oStrB9V:setProperty( "B9V_CODPRE" , MODEL_FIELD_INIT, { || oModel:getModel("MasterB9W"):getValue("B9W_CODPRE")} )
oStrB9V:setProperty( "B9V_SEQB9V" , MODEL_FIELD_INIT, { || oModel:getModel("MasterB9W"):getValue("B9W_SEQVIS")} ) 
oStrB9V:setProperty( "B9V_CODINT" , MODEL_FIELD_INIT, { || PlsIntPad()} )

oStrB9V:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F.)
oStrB9Q:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F.)
oStrB9R:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F.)
oStrB9W:SetProperty( 'B9W_CPFCGC', MODEL_FIELD_INIT, { || IF(INCLUI,"",POSICIONE("BAU",1,XFILIAL("BAU")+B9W->B9W_CODPRE,"BAU_CPFCGC"))} )
oStrB9W:SetProperty( 'B9W_PRESTA', MODEL_FIELD_INIT, { || IF(INCLUI,"",POSICIONE("BAU",1,XFILIAL("BAU")+B9W->B9W_CODPRE,"BAU_NOME")) } )
	
oStrB9V:SetProperty( 'B9V_CODSEQ' , MODEL_FIELD_OBRIGAT, .T.)
oStrB9V:SetProperty( 'B9V_CODSEQ' , MODEL_FIELD_WHEN   , { || IIf(INCLUI, .T., .F.) } )
	
oModel:SetPrimaryKey( { "B9W_CODPRE", "B9W_SEQVIS", "B9W_CODINT" } )
	
Return oModel // Retorna o Modelo de dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 13/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oView  // Interface de visualização construída
Local oModel := FWLoadModel( 'PLSA807' ) // Cria as estruturas a serem usadas na View
Local oStrB9W:= FWFormStruct(2, 'B9W', { |cCampo| PLSAB9W807(cCampo) } )
Local oStrB9Q:= FWFormStruct(2, 'B9Q', { |cCampo| PLSAB9Q807(cCampo) } )
Local oStrB9R:= FWFormStruct(2, 'B9R', { |cCampo| PLSAB9R807(cCampo) } )
Local oStrB9V:= FWFormStruct(2, 'B9V', { |cCampo| PLSAB9V807(cCampo) } )
Local oStrObs:= FWFormStruct(2, 'B9W', { |cCampo| !PLSOBS807(cCampo) } )
	
oView := FWFormView():New() // Cria o objeto de View
	
oView:SetModel(oModel)		// Define qual Modelo de dados será utilizado
	
oView:AddField('ViewB9W' , oStrB9W,'MasterB9W' ) // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
	
oView:AddGrid( 'ViewB9Q' , oStrB9Q,'B9QDetail' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'ViewB9R' , oStrB9R,'B9RDetail' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'ViewB9V' , oStrB9V,'B9VDetail' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddField( 'ViewOBS', oStrObs,'MasterB9W' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	
oView:AddIncrementField( 'ViewB9Q' , 'B9Q_CODSEQ') //Adiciona Campo incremental na View
oView:AddIncrementField( 'ViewB9R' , 'B9R_CODSEQ') //Adiciona Campo incremental na View
	
oView:CreateHorizontalBox( 'SUPERIOR' , 100,,, 'ABA', 'T1' ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente
oView:CreateHorizontalBox( 'INFERIOR1', 25,,, 'ABA', 'T2'  ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente
oView:CreateHorizontalBox( 'INFERIOR2', 25,,, 'ABA', 'T2'  ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente
oView:CreateHorizontalBox( 'INFERIOR3', 25,,, 'ABA', 'T2'  ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente
oView:CreateHorizontalBox( 'INFERIOR4', 25,,, 'ABA', 'T2'  ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente
	
oView:EnableTitleView( 'ViewB9Q', STR0010 /*'Especialidades' */							) //Atribui título para a View
oView:EnableTitleView( 'ViewB9R', STR0011 /*'Serviços'			*/							) //Atribui título para a View
oView:EnableTitleView( 'ViewB9V', STR0012 /*'Endereço de Atendimento a ser visitado'*/	) //Atribui título para a View
oView:EnableTitleView( 'ViewOBS', STR0013 /*'Observações/Sugestões/Críticas'	*/			) //Atribui título para a View
	
oView:SetOwnerView('ViewB9W','SUPERIOR' ) // Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('ViewB9V','INFERIOR1') // Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('ViewB9Q','INFERIOR2') // Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('ViewB9R','INFERIOR3') // Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('ViewOBS','INFERIOR4') // Relaciona o identificador (ID) da View com o "box" para exibição
	
oView:AddUserButton(STR0009/*'Conhecimento'*/,"", { |oView| PLS807BAN() }) //Cria o botão de ocnhecimento na View
	
oView:SetFieldAction('B9W_DATAAG', { |oView| PLS807DTAG(oView) } ) //Gera alerta ao cadastrar mais de uma visita para o agente na mesma data
oView:SetFieldAction('B9W_CODPRE', { |oView| PLS807GRD(oView, oModel) } ) //Carrega os dados do Prestador e limpa grids
oView:SetFieldAction('B9V_CODSEQ', { |oView| PLS807GESP(oView, oModel), PLS807END(oView) } )//Carrega o endereço do registro e as especialidades da Localidade escolhida
	
oStrB9W:SetProperty( '*', MVC_VIEW_FOLDER_NUMBER, '1')
oStrB9Q:SetProperty( '*', MVC_VIEW_FOLDER_NUMBER, '2')
oStrB9V:SetProperty( '*', MVC_VIEW_FOLDER_NUMBER, '2')
oStrB9R:SetProperty( '*', MVC_VIEW_FOLDER_NUMBER, '2')
oStrObs:SetProperty( '*', MVC_VIEW_FOLDER_NUMBER, '2')
	
//Impede a edição dos campos da Grid, com exceção ao código da localidade, e atribui consulta padrão para o campo nesta Rotina.
oStrB9V:SetProperty( '*', MVC_VIEW_CANCHANGE, .F.)
oStrB9Q:SetProperty( '*', MVC_VIEW_CANCHANGE, .F.)
oStrB9R:SetProperty( '*', MVC_VIEW_CANCHANGE, .F.)
oStrB9V:SetProperty( 'B9V_CODSEQ', MVC_VIEW_CANCHANGE, .T.)
	
oView:CreateFolder( 'ABA' ) //Cria estrutura de abas
	
oView:AddSheet( 'ABA', 'T1', STR0014 ) ///*'Formulário Visita'*/
oView:AddSheet( 'ABA', 'T2', STR0015 ) ///*'Dados Prestador'*/
	
Return oView // Retorna o objeto de View criado


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSOBS807
Tratamento para separar o campo de Observação da estrutura Mestre e colocá-lo no detalhe correto.
@author Oscar Zanin
@since 15/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSOBS807 (cCampo)
	
Local lRet	:= .T.
	
If cCampo == "B9W_OBSERV"
	lRet := .F.
EndIf
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA807OK
Validar Inclusão da Visita
@author Oscar Zanin
@since 14/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA807OK(oModel)
	
LOCAL lRet     			:= .T.
LOCAL cMsg     			:= ""
LOCAL oModelDetail		:= oModel:GetModel( 'MasterB9W' )
LOCAL cAgente			:= oModelDetail:GetValue('B9W_AGENTE')
LOCAL oModB9V			:= oModel:GetModel( 'B9VDetail' )
LOCAL cCidade			:= AllTrim(oModB9V:GetValue('B9V_CIDADE'))
LOCAL cCodInt			:= PLSINTPAD()
LOCAL nOpc				:= oModel:GetOperation()
Local cCodCid			:= oModB9V:GetValue('B9V_CODCID')
	
//Verifica se há registros deletados de Localidade com especialidades/serviços não-deletados, caso haja, deleta os correspondentes também.
PLS807VDEL(oModel)
	
If (nOpc <> 5)
		
	//Cadastra o tipo de Logradouro e Código da Cidade
	//PLSA807NTIP(oModel)
		
	//Verifica se o agente atende a cidade que está sendo designado para a visita
	If !(PLSCPRO807 (oModel, cAgente, cCidade, cCodInt, cCodCid))
			
		cMsg := STR0016 /*"O Agente Informado Não atende a cidade de "*/ + cCidade + STR0017/*"!"*/
		Help( ,, 'HELP',, cMsg, 1, 0)
		lRet := .F.
			
	EndIf
		
EndIf

//Atenção! para que não sejam "perdidos" números sequenciais, o código abaixo deve ser executado somente após todas as validações terem 
//sido realziadas e o retorno for ser .T.. Caso for ser incluída alguma validação nova, por favor, insira ela antes desta
//passagem.
If nOpc == 3 //Somente para Inclusão

	If lRet //Somente se todas as validações anteriores retornaram .T.
	
		//Atribui o sequencial pra B9W, que será repassado pelo relacionamento às demais tabelas envolvidas
		oModelDetail:SetValue( "B9W_SEQVIS", PLS807SQNC() )
		if ( empty(oModel:GetModel('B9VDetail'):getvalue("B9V_CODPRE")) )
			oModel:GetModel('B9VDetail'):loadvalue("B9V_SEQB9V", oModelDetail:getvalue("B9W_SEQVIS"))
			oModel:GetModel('B9VDetail'):loadvalue("B9V_CODPRE", oModelDetail:getvalue("B9W_CODPRE"))
			oModel:GetModel('B9VDetail'):loadvalue("B9V_CODINT", oModelDetail:getvalue("B9W_CODINT"))
		endif 	
		
	EndIf
EndIF
	
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS807BAN
Banco de Conhecimento
@author Oscar Zanin
@since 20/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS807BAN()
LOCAL aAreaB9W			:= B9W->(GetArea())
LOCAL cQuery			:= ""
LOCAL cIndex			:= ""
LOCAL cChaveInt  		:= B9W->(B9W_CODINT+B9W_SEQVIS) //B9P->(B9P_CODINT) + B9W->(B9W_SEQVIS)
Private CCADASTRO 		:= STR0018 //"Visita de Relacionamento"
Private aRotina 		:= {}

aRotina := {{STR0009 /*"Conhecimento"*/,'MsDocument',0/*permite exclusao do registro*/,1/*visualizar arquivo*/},{STR0019 /*"Inclusão Rápida"*/,'PLSDOcs',0,3}}
	
B9W->( DbSetOrder(2) )
B9W->( MsSeek( xFilial("B9W") + cChaveInt ) )
	
cIndex := CriaTrab(NIL,.F.)
cQuery := "B9W_FILIAL == '" + xFilial("B9W") + "' "
cQuery += " .AND. B9W_CODINT == '" + PLSINTPAD() + "' "
cQuery += " .AND. B9W_SEQVIS == '" + B9W->B9W_SEQVIS + "' "
	
IndRegua("B9W",cIndex,"B9W->(B9W_FILIAL+B9W_CODINT+B9W_SEQVIS)",,cQuery)
	
If B9W->(!Eof())
	
	MsDocument( "B9W", B9W->( RecNo() ), 2 )
	
EndIf
	
RetIndex( "B9W" )
dbClearFilter()
FErase( cIndex+OrdBagExt() )
RestArea(aAreaB9W)	
	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCPRO807
Verifica se o agente atende a cidade informada.
@author Oscar Zanin
@since 20/01/2015
@version P12
/*/
//-------------------------------------------------------------------

Function PLSCPRO807 (oModel, cCodAgt, cCidade, cCodInt, cCodCid)
LOCAL lAtende			:= .F.
	
B9K->(DbSetOrder(3)) //B9K_FILIAL + B9K_CODINT + B9K_CODAGE
	
//Posiciona no primeiro registro agente
If B9K->(MsSeek(xFilial("B9K") + cCodInt + cCodAgt))
		
	//Verifica se ele está associado à cidade informada
	While (lAtende == .F.) .AND. (!B9K->(EoF())) .AND. (cCodAgt == B9K->B9K_CODAGE)
			
		If (cCidade == AllTrim(POSICIONE("BID",1,XFILIAL("B9K")+B9K->B9K_CODCID,"BID_DESCRI")))
			lAtende := .T.
		EndIf
			
		B9K->(DbSkip())
			
	EndDo
		
EndIf
	
Return (lAtende)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS807DTAG
Verifica se foi informado mais de uma visita para o Agente, na mesma data
@author Oscar Zanin
@since 23/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS807DTAG(oView)
	
Local oViewDetail	:= oView:GetModel( 'MasterB9W' )
Local cDataAg 		:= DToS(oViewDetail:GetValue('B9W_DATAAG'))
Local cAgente		:= oViewDetail:GetValue('B9W_AGENTE')
Local cCodInt		:= PLSINTPAD()
	
B9W->(DbSetOrder(3)) //B9W_FILIAL + B9W_CODINT + B9W_AGENTE + B9W_DATAAG
	
If (B9W->(MsSeek(XFilial("B9W") + cCodInt + cAgente + cDataAg)))
	cMsg := STR0022 //"O Agente Informado já possui outra Visita cadastrada para a mesma data!"
	MsgInfo( cMsg, STR0021 /*'Atenção!'*/)
EndIf
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAB9V807
Tratamento para ajustar os campos a ser utilizados da tabela B9V.
@author Oscar Zanin
@since 29/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSAB9V807(cCampo)
	
Local lRet	:= .T.
	
If cCampo == "B9V_EMAIL " //Não para o e-mail
	lRet := .F.
EndIf
	
If cCampo == "B9V_CONTAT" //Não para o contato
	lRet := .F.
EndIf
	
If cCampo == "B9V_CNES  " //Não para o CNES
	lRet := .F.
EndIf

If cCampo == "B9V_CODPRO" //Não para o Código do Prospect
	lRet := .F.
EndIf
	
If cCampo == "B9V_CODPRE" //Não para o Código do Prestador
	lRet := .F.
EndIf

If cCampo == "B9V_CODINT" //Não para o Código da Operadora
	lRet := .F.
EndIf

If cCampo == "B9V_DESINT" //Não para a Descrição da operadora
	lRet := .F.
EndIf

If cCampo == "B9V_SEQB9V" //Não para o Sequencial da tabela
	lRet := .F.
EndIf
	
If cCampo == "B9V_TEL   " //Não para o Telefone
	lRet := .F.
EndIf

If cCampo == "B9V_DEFERE" //Campo da Rotina de Credenciamento
	lRet := .F.
EndIf
	
If cCampo == "B9V_TIPLOC" //Campo da Rotina de Credenciamento
	lRet := .F.
EndIf
	
If cCampo == "B9V_DESLOC" //Campo da Rotina de Credenciamento
	lRet := .F.
EndIF
		
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAB9Q807
Tratamento para ajustar os campos a ser utilizados da tabela B9Q. (VIEW)
@author Oscar Zanin
@since 29/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSAB9Q807(cCampo)
	
Local lRet	:= .F.
	
If cCampo == "B9Q_CODESP" //Sim para Código da Especialidade
	lRet := .T.
EndIf
	
If cCampo == "B9Q_DESESP" //Sim para Descrição da Especialidade
	lRet := .T.
EndIf
	
If cCampo == "B9Q_CODSEQ" //Sim para sequencial da especialidade
	lRet := .T.
EndIf
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS807VDEL
Tratamento para deletar registros de especialiade e serviços, caso seja
deletado o registro do endereço correspondente
@author Oscar Zanin
@since 05/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS807VDEL(oModel)
	
Local oB9V		:= oModel:GetModel( 'B9VDetail' ) //Endereço
Local oB9Q		:= oModel:GetModel( 'B9QDetail' ) //Especialidade
Local oB9R		:= oModel:GetModel( 'B9RDetail' ) //Serviço
Local nI		:= 0
Local nJ		:= 0
Local nK		:= 0
	
For nI := 1 To oB9V:Length() //Verifica quantas linhas tem o Model de Endereços
	oB9V:GoLine( nI ) //Vai para a primeira linha
		
	If oB9V:IsDeleted() //Se o endereço foi deletado, exclúi as especialidades e serviços vinculados
			
		For nJ := 1 To oB9Q:Length() //Exclusão das Especialidades sem endereço correspondente
			oB9Q:GoLine( nJ )
			If oB9Q:GetValue( 'B9Q_CODLOC' ) == oB9V:GetValue('B9V_CODSEQ')
				oB9Q:DeleteLine()
			EndIf
		Next
			
		For nK	:= 1 To oB9R:Length() //Exclusão dos Serviços sem endereço correspondente
			oB9R:GoLine( nK )
			If oB9R:GetValue( 'B9R_CODLOC' ) == oB9V:GetValue( 'B9V_CODSEQ' )
				oB9R:DeleteLine()
			EndIf
		Next
			
	EndIf
Next
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS807VTPV
Valida se o Motivo de visita informado não é referente à Captação
@author Oscar Zanin
@since 10/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS807VTPV(cCampo)
Local lRet 		:= .F.
Local cCodInt	:= PLSINTPAD()
Local cMotivo 	:= PLS806Zero(cCampo)
	
B9L->(DbSetOrder(7))
	
//Tenta posicionar para tipo "Relacionamento"
If B9L->(MsSeek(xFilial("B9L") + cCodInt + cMotivo + "1"))	
	lRet := .T.	
EndIf
	
//Tenta posicionar para tipo "Ambos"
If B9L->(MsSeek(xFilial("B9L") + cCodInt + cMotivo + "2"))
	lRet := .T.
EndIf
	
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS807AVI1
Alerta que não poderá ser alterado o prestador após a conclusão do cadastro
@author Oscar Zanin
@since 22/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS807AVI1()
	
Local cMsg := ""
	
cMsg := STR0023 //"Verifique o prestador informado, pois não será permitida a alteração deste campo após a gravação!"
MsgInfo( cMsg, STR0021 /*'Atenção!'*/)
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS807GRD
Tratamento para Resetar as Grids ao preencher o código do prestador
@author Oscar Zanin
@since 20/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS807GRD(oView, oModel)
	
Local oB9W		:= oView:GetModel( 'MasterB9W' ) 	//Visita Relacionamento
Local aCampos	:= {}    							//Array que irá receber a estrutura dos campos
Local aValores	:= {}							//Array que irá receber o nome e o valor correspondente de cada campo
	
PLS807AVI1()
	
aCampos := oB9W:GetStruct():GetFields()	//Passamos a estrutura para o Array
aEval( aCampos, { |aX| Aadd(aValores, {aX[3],oB9W:GetValue(aX[3])}) } ) //Passamos os valores e campos
	
oModel:DeActivate() 	//Desativamos a Model, para limpar os SubModelos
	
oModel:Activate()		//Reativamos a Model "limpa" para continuar o uso normal da Rotina
	
aEval( aValores, { |aX| oB9W:SetValue(aX[1], aX[2]) } ) 	//Retornamos os valores do Form que o usuário digitou antes de escolher o prestador
	
oView:Refresh()
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS807GESP
Tratamento para Preencher as Grids conforme o local de atendimento do prestador
@author Oscar Zanin
@since 20/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS807GESP(oView, oModel)
	
Local oB9W		:= oView:GetModel( 'MasterB9W' ) 	//Visita Relacionamento
Local oB9V		:= oView:GetModel( 'B9VDetail' ) 	//Endereço
Local oB9Q		:= oView:GetModel( 'B9QDetail' ) 	//Especialidade
Local oB9R		:= oView:GetModel( 'B9RDetail' ) 	//Serviço
Local cCodPre	:= oB9W:GetValue("B9W_CODPRE")   	//Código do Prestador
Local cCodInt	:= PLSINTPAD()					 	//Código da Operadora
Local aCampos	:= {}    							//Array que irá receber a estrutura dos campos
Local aValores	:= {}							//Array que irá receber o nome e o valor correspondente de cada campo
Local aBAX		:= {}								//Array para pegar os valores da BAX do Prestador (Especialidades)
Local aBIN		:= {}								//Array para pegar os valores da BIN do Prestador (serviços)
Local nK		:= 0
Local nJ		:= 0
Local cCodLoc	:= oB9V:GetValue( "B9V_CODSEQ" )
Local cDesEsp	:= ""
Local cDesSer 	:= ""
Local nContB9Q 	:= 1
Local nContB9R 	:= 1
	
PLS807AVI2() //Mostra aviso para o Usuário
	
aCampos := oB9W:GetStruct():GetFields()	//Passamos a estrutura para o Array
aEval( aCampos, { |aX| Aadd(aValores, {aX[3],oB9W:GetValue(aX[3])}) } ) //Passamos os valores e campos
	
oModel:DeActivate() 	//Desativamos a Model, para limpar os SubModelos
	
oModel:Activate()		//Reativamos a Model "limpa" para continuar o uso normal da Rotina
	
BAX->(DbSetOrder(4))
BAX->(MsSeek(xFilial("BAX") + cCodInt + cCodPre + cCodLoc))
	
//Especialidades
While (BAX->(BAX_FILIAL) == xFilial("BAX") .AND. BAX->(BAX_CODIGO) == cCodPre .AND. BAX->(!(EoF())))
		
	cDesEsp := Posicione("BAQ",7,XFILIAL("BAQ")+BAX->BAX_CODESP,"BAQ_DESCRI") 	//Descrição da especialidada é Virtual então nós atribuímos o valor para a variável
		
	AAdd(aBAX, {BAX->(BAX_CODESP), cDesEsp, BAX->(BAX_CODLOC)})		//Criamos Array com os campos que utilizaremos da BAX
		
	BAX->(DbSkip())
		
EndDo
	
//Serviços
BIN->(DbSetOrder(1))
BIN->(MsSeek(xFilial("BIN") + cCodPre + cCodInt + cCodLoc))
	
While (BIN->(BIN_FILIAL) == xFilial("BIN") .AND. BIN->(BIN_CODIGO) == cCodPre .AND. BIN->(!(EoF())))
		
	cDesSer := Posicione("BH7",1,XFILIAL("BH7")+BIN->BIN_CODGRU,"BH7_DESCRI")		//Descrição do serviço é Virtual, então atribuímos o valor à variável
		
	AAdd(aBIN, {BIN->(BIN_CODGRU), cDesSer, BIN->(BIN_CODLOC)})		//Criamos o Array com os campos que utilizaremos da BIN
		
	BIN->(DbSkip())
		
EndDo
	
//Atribuímos os Arrays para as Grids
For nK := 1 To Len (aBAX) //Especialidades!
		
	If aBAX[nK][3] == cCodLoc
			
		If nContB9Q > 1
			oB9Q:AddLine()
		EndIf
			
		oB9Q:SetValue("B9Q_CODESP", aBAX[nK][1])
		oB9Q:SetValue("B9Q_CODLOC", cCodLoc)
			
		nContB9Q++
	EndIf
		
Next
	
For nJ := 1 To Len (aBIN) //Serviços!
		
	If aBIN[nJ][3] == cCodLoc
			
		If nContB9R > 1
			oB9R:AddLine()
		EndIF
			
		oB9R:LoadValue("B9R_CODSER", Right(aBIN[nJ][1], 2) )
		oB9R:LoadValue("B9R_DESSER", AllTrim(aBIN[nJ][2])  )
		oB9R:LoadValue("B9R_CODLOC", cCodLoc)
			
		nContB9R++
	EndIf
Next
	
aEval( aValores, { |aX| oB9W:SetValue(aX[1], aX[2]) } ) 	//Retornamos os valores do Form que o usuário digitou antes de escolher o prestador
	
oB9V:SetValue("B9V_CODSEQ", cCodLoc) //Devolvemos o CodLoc, que perdemos no DeActivate/Activate
	
	oView:Refresh()
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS807VLD
Cria Valid do campo para esta rotina
@author Oscar Zanin
@since 20/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS807VLD(oModel)
	
Local cCodPre 	:= oModel:GetValue( 'MasterB9W', "B9W_CODPRE" )
Local cCodLoc 	:= PLS806Zero(oModel:GetValue( 'B9VDetail', "B9V_CODSEQ" ))
Local cCodInt	:= PLSINTPAD()
Local lRet 		:= .F.
	
BB8->(DbSetorder(6))
	
//Busca se a Localidade existe
If BB8->(MsSeek(xFilial("BB8") + cCodInt + cCodPre + cCodLoc))	
	lRet := .T.	
EndIf
	
//Verifica se o CodLoc está em branco
If Empty(cCodLoc)	
	lRet := .T.	
EndIf
	
If lRet	
	oModel:GetModel("B9VDetail"):SetValue("B9V_CODSEQ", cCodLoc)	
EndIf
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA807SXE
Função dá rollback no sxe reservado
@author Oscar Zanin
@since 25/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA807SXE()

//Somente para a operação de Inclusão
if INCLUI
	ROLLBACKSXE()
EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS807SQNC
Gera o Sequencial da Visita
@author Oscar Zanin
@since 26/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS807SQNC()
Local cSequen 	:= ""
Local nTam 		:= Len( Space(TamSX3("B9W_SEQVIS")[1]) )
local cSql 		:= ""

cSql := " SELECT MAX(B9W_SEQVIS) SEQ FROM " + RetSqlName("B9W")
cSql += "   WHERE B9W_FILIAL = '" + xFilial("B9W") + "' AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSql)),"MAXVIS", .f., .t.)
cSequen := MAXVIS->SEQ
MAXVIS->(dbcloseArea())
 
cSequen := StrZero(Val(cSequen) + 1, nTam)

Return (cSequen)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS807AVI2
Alerta que não pode haver alteração do Local após a conclusão do cadastro.
@author Oscar Zanin
@since 22/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS807AVI2()
	
Local cMsg := ""
	
cMsg := STR0024 //"Verifique o Local informado, pois não será permitida a alteração deste campo após a gravação!"
MsgInfo( cMsg, STR0021 /*'Atenção!'*/)
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAB9W807
Separar os campos a Exibir na View
@author Oscar Zanin
@since 20/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSAB9W807(cCampo)
	
Local lRet	:= .T.
	
If cCampo == "B9W_SEQVIS"
	lRet := .F.
EndIf
	
If cCampo == "B9W_CODINT"
	lRet := .F.
EndIf
	
If cCampo == "B9W_DESINT"
	lRet := .F.
EndIf
	
If cCampo == "B9W_OBSERV"
	lRet := .F.
EndIf
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAB9R807
Separar os campos a Exibir na View
@author Oscar Zanin
@since 20/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSAB9R807(cCampo)

Local lRet := .F.
	
If cCampo == "B9R_CODSER" //Sim para Código do Serviço
	lRet := .T.
EndIf
	
If cCampo == "B9R_DESSER" //Sim para Descrição do Serviço
	lRet := .T.
EndIf
	
If cCampo == "B9R_CODSEQ" //Sim para sequencial do serviço
	lRet := .T.
EndIf
	
Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS807END
Preenche os campos correspondentes à Localidade informada na B9V
@author Oscar Zanin
@since 31/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS807END(oView)

Local cTipLog 	:= ""
Local cEnd		:= ""
Local cCodMun 	:= ""
Local cBairro	:= ""

Local cMunici	:= ""
Local cLogra	:= ""
Local cNum		:= ""
Local cCompl	:= ""
Local cCEP		:= ""

BB8->(DbSetOrder(1))

//Limpa os valores, caso o valor esteja Vazio
If Vazio(oView:GetModel("B9VDetail"):GetValue("B9V_CODSEQ"))

	oView:GetModel("B9VDetail"):LoadValue("B9V_CODLOG" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_ENDER"  , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_CODCID" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_BAIRRO" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_CIDADE" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_DESLOG" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_NUMERO" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_COMEND" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_CEP"    , "")
	
//Carrega os valores, caso exista o código
ElseIf BB8->(MsSeek(xFilial("BB8") + oView:GetModel("MasterB9W"):GetValue("B9W_CODPRE") + PLSINTPAD() + oView:GetModel("B9VDetail"):GetValue("B9V_CODSEQ")))

	cTipLog := BB8->BB8_TIPLOG
	cEnd	 := BB8->BB8_END
	cCodMun := BB8->BB8_CODMUN
	cBairro := AllTrim(BB8->BB8_BAIRRO)
	cNum	 := BB8->BB8_NR_END
	cCompl	 := BB8->BB8_COMEND
	cCEP	 := BB8->BB8_CEP
	
	cMunici := POSICIONE("BID",1,XFILIAL("BID")+cCodMun,"BID_DESCRI")
	cLogra	 := ALLTRIM(POSICIONE("B18",1,XFILIAL("B18")+cTipLog,'B18_DESCRI'))
	
	oView:GetModel("B9VDetail"):LoadValue("B9V_CODLOG" , cTipLog)
	oView:GetModel("B9VDetail"):SetValue("B9V_ENDER"  , cEnd)
	oView:GetModel("B9VDetail"):LoadValue("B9V_CODCID" , cCodMun)
	oView:GetModel("B9VDetail"):LoadValue("B9V_BAIRRO" , cBairro)
	oView:GetModel("B9VDetail"):LoadValue("B9V_DESLOG" , cLogra)
	oView:GetModel("B9VDetail"):LoadValue("B9V_CIDADE" , cMunici)
	oView:GetModel("B9VDetail"):LoadValue("B9V_NUMERO" , cNum)
	oView:GetModel("B9VDetail"):LoadValue("B9V_COMEND" , cCompl)
	oView:GetModel("B9VDetail"):LoadValue("B9V_CEP"    , cCEP)

//Limpa os demais campos, caso não atenda os anteriores
Else

	oView:GetModel("B9VDetail"):LoadValue("B9V_CODLOG" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_ENDER"  , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_CODCID" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_BAIRRO" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_CIDADE" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_DESLOG" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_NUMERO" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_COMEND" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_CEP"    , "")
	
EndIF
oView:Refresh()

Return()
