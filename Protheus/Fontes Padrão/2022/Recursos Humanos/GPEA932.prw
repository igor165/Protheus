#include "Protheus.ch"
#include "GPEA932.CH"
#Include 'FWMVCDEF.CH' 
#INCLUDE "FWMBROWSE.CH"

//Recuperar versão de envio
Static cVersEnvio := ""
Static cVersGPE   := ""
Static lIntTAF    := ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 0 )
Static lMiddleware:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static cEFDAviso  := If( cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0" )			//Se nao encontrar este parametro apenas emitira alertas  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ão    ³ GPEA932  ³ Autor ³ Claudinei Soares                  ³ Data ³ 14/11/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Carreiras Públicas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA932()                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL NA VERSAO MVC              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data      ³ ISSUE/FNC/TICKET ³ Motivo da Alteracao                     ³±±
±±³Marcos Cout ³ 17/01/2018³ DRHESOCP-2490    ³ Criando os eventos extemporâneos do even³±±
±±³            ³           ³                  ³_to S-1035 - Carreiras Públicas          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION GPEA932
	Local cFiltraRh
	Local oBrwSGY

	If !ChkFile("SGY")
		//ATENCAO"###"Tabela SGY não encontrada na base de dados. Execute o UPDDISTR."
		Help( " ", 1, OemToAnsi(STR0007),, OemToAnsi(STR0008), 1, 0 )
		Return 																													
	EndIf																														

	If lMiddleware .And. !ChkFile("RJE")
		cMsgDesatu := CRLF + OemToAnsi(STR0009) + CRLF //"Tabela RJE não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
	EndIf	

  	oBrwSGY := FWmBrowse():New()
	oBrwSGY:SetAlias( 'SGY' )
	oBrwSGY:SetDescription(OemToAnsi(STR0001))	//"Carreiras Públicas"

	//Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh	:= CHKRH(FunName(),"SGY","1")
	
	//Filtro padrao do Browse conforme tabela SGY (Carreiras Públicas)
	oBrwSGY:SetFilterDefault(cFiltraRh)
	oBrwSGY:SetLocate()

	oBrwSGY:ExecuteFilter(.T.)

	oBrwSGY:Activate()
	
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuDef     ³ Autor ³ Claudinei Soares    ³ Data ³ 14/11/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Menu Funcional                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {}
	Local aArea :={}

ADD OPTION aRotina Title OemToAnsi(STR0002)  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0003)  Action 'VIEWDEF.GPEA932'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'VIEWDEF.GPEA932' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA932'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA932'	OPERATION 5 ACCESS 0 //"Excluir"
	
Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ModelDef    ³ Autor ³ Claudinei Soares    ³ Data ³ 14/11/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Modelo de dados e Regras de Preenchimento para o Cadastro de  ³±±
±±³          ³Carreiras Públicas                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ModelDef()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruSGY := FWFormStruct( 1, 'SGY', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oMdlSGY
	
	// Blocos de codigo do modelo
    Local bPosValid 	:= { |oMdl| Gp932PosVal( oMdl )}
    Local bCommit		:= { |oMdl| Gp932Grav( oMdl )}
    
	// Bloco de codigo doa Fields
	Local bTOkVld		:= { |oMdl| Gp932TOk( oMdl )}
	
	// Cria o objeto do Modelo de Dados
	oMdlSGY := MPFormModel():New('GPEA932', /*bPreValid*/, bTOkVld, bCommit, /*bCancel*/ )
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oMdlSGY:AddFields( 'MODELGPEA932', /*cOwner*/, oStruSGY, /*bLOkVld*/, Nil, /*bCarga*/ )
	
	// Adiciona a descricao do Modelo de Dados
	oMdlSGY:SetDescription(OemToAnsi(STR0001))//"Carreiras Públicas"
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oMdlSGY:GetModel( 'MODELGPEA932' ):SetDescription(OemToAnsi(STR0001)) //"Carreiras Públicas"

Return oMdlSGY
	
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewDef     ³ Autor ³ Claudinei Soares    ³ Data ³ 14/11/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizador de dados do Cadastro de Carreiras Públicas      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ViewDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oMdlSGY   := FWLoadModel( 'GPEA932' )
	// Cria a estrutura a ser usada na View
	Local oStruSGY := FWFormStruct( 2, 'SGY' )
	Local oView
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado
	oView:SetModel( oMdlSGY )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_GPEA932', oStruSGY, 'MODELGPEA932' )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'FORMFIELD' , 100 )
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_GPEA932', 'FORMFIELD' )

Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp932PosVal ³ Autor ³ Claudinei Soares    ³ Data ³ 14/11/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pos-validacao do Cadastro de Carreiras Públicas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp932PosVal( oMdlSGY )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlSGY = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp932PosVal( oMdlSGY )
	Local lRetorno      := .T.
	//Local nOperation

	// Seta qual é a operacao corrente
	//nOperation := oMdlSGY:GetOperation()

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp932Grav   ³ Autor ³ Claudinei Soares    ³ Data ³ 14/11/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao responsavel pelo commit do Cadastro de Cargos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp932Grav( oMdlSGY )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlSGY = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp932Grav( oMdlSGY )

Local lRetorno       := .T.	
    
FWFormCommit( oMdlSGY )    	

	
Return lRetorno                                      
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp932TOk    ³ Autor ³ Claudinei Soares    ³ Data ³ 14/11/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tudo Ok do Cadastro de Carreiras Públicas                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp932TOk( oGrid, oMdlSGY )                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oGrid   = Objeto da Grid                                     ³±±
±±³          ³ oMdlSGY = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp932TOk( oMdlSGY )
Local lRet       := .T.
Local aItens     := {}
Local nOperation := oMdlSGY:nOperation
Local cCarreira  := ""
Local dDataAux   := dDataBase
Local cData      := cValToChar( StrZero( Month(dDataAux), 2 ) ) + cValToChar( Year(dDataAux))
Local cAnoMes    := cValToChar( Year(dDataAux)) + "-" + cValToChar( StrZero( Month(dDataAux), 2 ) )
Local cChave     := ""
Local lSemFilial := .F.
Local lGeraCod   := .F.
Local cStatus    := "-1"
Local aErros     := {}
Local aFilInTaf  := {}
Local aArrayFil  := {}
Local cFilEnv    := ""
Local lIntegra   := .F.
Local cXml		 := ""
Local cMsg		 := ""
Local cMsgErro	 := ""
Local cVersMid	 := ""
Local cChave	 := ""
Local cMsgRJE	 := ""
Local cIni 		 := LEFT(DTOS(DDATABASE),6)
Local lAdmPubl	 := .F.
Local aInfos	 := {}
Local aDados	 := {}
Local cFilEmp	 := ""
Local dDtGer	 := Date()
Local cHrGer	 := Time()
Local lRet		 := .T.
Local cRetfNew	 := ""
Local cRetfRJE	 := ""
Local cRetKey	 := ""
Local cOperNew 	 := ""
Local cOperRJE	 := "I"
Local cRetfNew	 := ""
Local cStatNew	 := ""
Local lNovoRJE	 := .F.
Local nOpcao 	 := 3
Local nRecRJE  	 := 0
Local lS1000 	 := .F.
Local nOpcAx	 := oMdlSGY:GetOperation()
Local aSM0    	 := FWLoadSM0(.T.,,.T.)

//Verificando versão do GPE
lIntegra := Iif(FindFunction("fVersEsoc"), fVersEsoc("S-1035", .F., /*@aRetGPE*/, /*@aRetTAF*/, @cVersEnvio,@cVersGPE,@cVersMid), .F. )

//----------------------------------
//| E X T E M P O R Â N E O  S-1035 
//----------------------------------
//Se a integração estiver ativa e não for consistência de tabela
If ((lInttaf .Or. lMiddleware) .And. (cVersGPE < "9.0")) .And. FUNNAME() <> "GPEM035"
	If !lMiddleware
		//Identificando Filial de Envio
		fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf
	Endif
		
	//Tratamento de compartilhamento da tabela SGY
	If Empty( xFilial("SGY") )
		lSemFilial := .T.
	EndIf

	cCarreira  := Iif( lSemFilial, AllTrim( oMdlSGY:GetValue("MODELGPEA932", "GY_CODIGO") ), AllTrim( xFilial("SGY") + oMdlSGY:GetValue("MODELGPEA932", "GY_CODIGO") ) )
	If lMiddleware
		// verificar os predecessores - evento S1000
		lS1000 := fVld1000( AnoMes(dDataBase), @cStatus )		
		/*
			* 1 - Não enviado - Gravar por cima do registro encontrado
			* 2 - Enviado - Aguarda Retorno - Enviar mensagem em tela e não continuar com o processo
			* 3 - Retorno com Erro - Gravar por cima do registro encontrado
			* 4 - Retorno com Sucesso -?Efetivar a gravação
		*/
		If lS1000 //evento S-1000
			aInfos   := fXMLInfos()
				
			IF Len(aInfos) >= 4
				cTpInsc  := aInfos[1]
				lAdmPubl := aInfos[4]
				cNrInsc  := aInfos[2]
			Else
				cTpInsc  := ""
				lAdmPubl := .F.
				cNrInsc  := "0"
			EndIf

			If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpAnt .And. X[18] == cNrInsc }) ) > 0
				cFilEmp := aSM0[nFilEmp, 2]
			Else
				cFilEmp := cFilAnt
			EndIf

			// verifica se ja existe o evento s1035 na base de dados
			cChave 	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1035" + Padr(xFilial("SGY", cFilAnt) + oMdlSGY:GetValue("MODELGPEA932", "GY_CODIGO"), fTamRJEKey(), " ") + AnoMes(dDataBase)
			cStatus := "-1"
			//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
			GetInfRJE( 2, cChave, @cStatus, @cOperRJE, @cRetfRJE, @nRecRJE )

			//Alteração ou exclusão
			If nOpcAx == 4 .Or. nOpcAx == 5
				//Retorno pendente impede o cadastro
				If cStatus == "2"
					cMsgRJE 	:= STR0010//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
					lRet		:= .F.
				//ALTERACAO
				ElseIf nOpcAx == 4 .AND. cStatus <> "2"
					//Evento de exclusão sem transmissão impede o cadastro
					If cOperRJE == "E" .And. cStatus != "4"
						cMsgRJE 	:= STR0011//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						lRet		:= .F.
					//Não existe na fila, será tratado como inclusão
					ElseIf cStatus == "-1"
						nOpcao 		:= 3
						cOperNew 	:= "I"
						cRetfNew	:= "1"
						cStatNew	:= "1"
						lNovoRJE	:= .T.
					//Evento sem transmissão, irá sobrescrever o registro na fila
					ElseIf cStatus $ "1/3"
						If cOperRJE == "A"
							nOpcao 	:= 4
						EndIf
						cOperNew 	:= cOperRJE
						cRetfNew	:= cRetfRJE
						cStatNew	:= "1"
						lNovoRJE	:= .F.
					//Evento diferente de exclusão transmitido, irá gerar uma retificação
					ElseIf cOperRJE != "E" .And. cStatus == "4"
						nOpcao 		:= 4
						cOperNew 	:= "A"
						cRetfNew	:= "2"
						cStatNew	:= "1"
						lNovoRJE	:= .T.
					//Evento de exclusão transmitido, será tratado como inclusão
					ElseIf cOperRJE == "E" .And. cStatus == "4"
						nOpcao 		:= 3
						cOperNew 	:= "I"
						cRetfNew	:= "1"
						cStatNew	:= "1"
						lNovoRJE	:= .T.
					EndIf
				//Exclusão
				ElseIf nOpcAx == 5
					nOpcao 		:= 5
					//Evento de exclusão sem transmissão impede o cadastro
					If cOperRJE == "E" .And. cStatus != "4"
						cMsgRJE 	:= STR0011//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						lRet		:= .F.
					//Evento diferente de exclusão transmitido irá gerar uma exclusão
					ElseIf cOperRJE != "E" .And. cStatus == "4"
						cOperNew 	:= "E"
						cRetfNew	:= cRetfRJE
						cStatNew	:= "1"
						lNovoRJE	:= .T.
					EndIf
				EndIf
			ElseIf nOpcAx == 3
				//Retorno pendente impede o cadastro
				If cStatus == "2"
					cMsgRJE 	:= STR0010//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
					lRet		:= .F.
				//Evento de exclusão sem transmissão impede o cadastro
				ElseIf cOperRJE == "E" .And. cStatus != "4"
					cMsgRJE 	:= STR0011//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
					lRet		:= .F.
				//Evento sem transmissão, irá sobrescrever o registro na fila
				ElseIf cStatus $ "1/3"
					nOpcao		:= Iif( cOperRJE == "I", 3, 4 )
					cOperNew 	:= cOperRJE
					cRetfNew	:= cRetfRJE
					cStatNew	:= "1"
					lNovoRJE	:= .F.
				//Evento diferente de exclusão transmitido, irá gerar uma retificação
				ElseIf cOperRJE != "E" .And. cStatus == "4"
					cOperNew 	:= "A"
					cRetfNew	:= "2"
					cStatNew	:=  "1"
					lNovoRJE	:= .T.
				//Ser?tratado como inclusão
				Else
					cOperNew 	:= "I"
					cRetfNew	:= "1"
					cStatNew	:= "1"
					lNovoRJE	:= .T.
				EndIf
			EndIf

			If lRet
				If (fCarrS1035("", cCarreira, cAnoMes, lGeraCod, cValToChar(nOpcao), aErros, xFilial("SGY", cFilAnt), cVersEnvio, oMdlSGY, @cXml, cVersMid, @cRetKey))

					aAdd( aDados, { xFilial("RJE", cFilAnt), xFilial("SGY", cFilAnt), cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1035", cIni, xFilial("SGY", cFilAnt) + oMdlSGY:GetValue("MODELGPEA932", "GY_CODIGO"), cRetKey, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew } )
					
					//Se não for uma exclusão de registro não transmitido, cria/atualiza registro na fila
					If !( nOpcAx == 5 .And. ((cOperRJE == "E" .And. cStatus == "4") .Or. cStatus $ "-1/1/3") )
						If !( lRet := fGravaRJE( aDados, cXml, lNovoRJE, nRecRJE ) )
							cMsgRJE := STR0012//"Ocorreu um erro na gravação do registro na tabela RJE"
						EndIf
					//Se for uma exclusão e não for de registro de exclusão transmitido, exclui registro de exclusão na fila
					ElseIf nOpcAx == 5 .And. cStatus != "-1" .And. !(cOperRJE == "E" .And. cStatus == "4")
						If !( lRet := fExcluiRJE( nRecRJE ) )
							cMsgRJE := STR0013//"Ocorreu um erro na exclusão do registro na tabela RJE"
						EndIf
					EndIf
				Else
					LRET := .f.
				EndIf
				if !lRet
					Help(" ", 1, OemToAnsi(STR0007),, cMsgRJE, 1, 0) 
				EndIf
			Else
				Help(" ", 1, OemToAnsi(STR0007),, cMsgRJE, 1, 0) 
			EndIf
		Else
			lret := .F.
			cMsgRJE := STR0015//"Problemas com evento S1035"
			Do Case 
				Case cStatus == "-1" // nao encontrado na base de dados
					cMsgRJE := STR0016 //"Registro do evento S-1000 não localizado na base de dados"
				Case cStatus == "1" // nao enviado para o governo
					cMsgRJE := STR0017 //"Registro do evento S-1000 não transmitido para o governo"
				Case cStatus == "2" // enviado e aguardando retorno do governo
					cMsgRJE := STR0018 //"Registro do evento S-1000 aguardando retorno do governo"
				Case cStatus == "3" // enviado e retornado com erro 
					cMsgRJE := STR0019 //"Registro do evento S-1000 retornado com erro do governo"
			Endcase

			// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
			If cEFDAviso == "0"
				MsgInfo(cMsgRJE,OemToAnsi(STR0007))	
			ElseIf cEFDAviso == "1"
				lTudoOk	:= lret
				Help(" ", 1, OemToAnsi(STR0007),, cMsgRJE, 1, 0) 
			EndIf			
		EndIf			
	Else
		//Montando as variaveis utilizadas na chave de pesquisa
		cChave     := cCarreira + ";" + cData

		//-------------------------------------------------
		//| Função centralizadora para gerar Extemporâneos
		//| Extemporâneo S-1035: GY_CODIGO + MMAAAA
		//-------------------------------------------------
		nOperation := fVerExtemp( "S-1035", cChave, nOperation, @cStatus )

		//-------------------------------------------------
		//| Baseado no evento de retorno, geramos o nOpc
		//| nOpc irá variar de 3 <inclusao>, 4 <alteracao> e 5 <exclusao>
		//----------------------------------------------------------------
		If ( nOperation > 0 )
			//Realizando integração do evento
			lRet := fCarrS1035("", cCarreira, cAnoMes, lGeraCod, cValToChar(nOperation), aErros, cFilEnv, cVersEnvio, oMdlSGY)

			If( !lRet )
				Help(,,,OemToAnsi(STR0007),aErros[1],1,0) //##"Atenção"
			ElseIf FindFunction("fEFDMsg") .AND. lRet
				fEFDMsg()
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
Endif

Return lRet
