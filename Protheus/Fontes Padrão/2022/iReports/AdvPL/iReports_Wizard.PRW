#INCLUDE "APWIZARD.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "BIDefs.ch"
#INCLUDE "iReportDefs.ch"
#INCLUDE "iRep_Wizard.ch"

#DEFINE REPORTS_EXTENS	"jrxml"
#DEFINE REP_EXT_MASCARA	"*.j*"
#DEFINE REP_EXT_LABEL	"Report files (*.jrxml, *.jasper ) | *.j*"

// ########################################################################################
// Projeto: iReports
// Modulo : Wizard
// Fonte  : iReports_Wizard - Wizard de Configuração/instalação do iReports no ambiente do Microsiga Protheus
// ---------+---------------------+--------------------------------------------------------
// Data     | Autor               | Descricao
// ---------+---------------------+--------------------------------------------------------
// 27.07.09 | 2481-Paulo R Vieira |
// ----------------------------------------------------------------------------------------
function cfgIReport()
	Local oWizard		:= Nil
	Local oPanel		:= Nil
	Local cTitle     	:= ''
	Local cMsg			:= ''
	Local cText			:= ''
	Local ciRepName   	:= '' 
	Local aItems		:= {"ODBC", "MSSQL", "ORACLE", "DB2", "DB2/400"}

	private cIRWS 		:= adjustSpaces( SuperGetMV("MV_IRWS"	, .F., ""), 255 )
	private cIRDBURL	:= adjustSpaces( SuperGetMV("MV_IRDBURL", .F., ""), 40 )
	private cIRDBPOR	:= adjustSpaces( SuperGetMV("MV_IRDBPOR", .F., ""), 10 )
	private cIRDB		:= adjustSpaces( SuperGetMV("MV_IRDB"	, .F., ""), 50 )
	private cIRDBUSR	:= adjustSpaces( SuperGetMV("MV_IRDBUSR", .F., ""), 40 )
	private cIRDBPSS	:= adjustSpaces( SuperGetMV("MV_IRDBPSS", .F., ""), 30 )
	private	cIRDBTP		:= adjustSpaces( SuperGetMV("MV_IRDBTP"	, .F., Upper( TCGetDB() )), 30 )
	
	private oLstRpts, oRepName
	
	cTitle	:= STR0014 //###"Configurador iReports"
	cMsg 	:= STR0015 //###"Integrador Microsiga Protheus com relatórios iReports"
	cText	:= STR0016+CRLF+STR0017+CRLF+STR0018 //###"Bem vindo ao assistente de configuração e operação de relatórios iReports a partir do Microsiga Protheus."###"Neste assistente será possível configurar o ambiente necessário e realizar o upload dos relatórios iReports a serem disponibilizados."###""Clique em 'Avançar' para prosseguir por cada etapa."
	
	DEFINE WIZARD oWizard TITLE cTitle MESSAGE cMsg TEXT cText FINISH {|| .T. } PANEL
	
	// painel de configuração
	cTitle 	:= STR0019 //###"Configuração de parâmetros"
	cMsg	:= STR0020 //###"Para a utilização do iReports, é necessário informar os seguintes parâmetros"
	CREATE PANEL oWizard HEADER cTitle MESSAGE cMsg BACK {|| .T. } NEXT {|| persistFields() } FINISH {|| .F. } PANEL
	
	// painel de carregamento de relatórios
	cTitle 	:= STR0021 //###"Upload de Relatórios iReports"
	cMsg	:= STR0022 //###"Atenção, o tamanho permitido para o nome do relatório é de no máximo 10 caracteres."
	CREATE PANEL oWizard HEADER cTitle MESSAGE cMsg BACK {|| .T. } NEXT {|| .T. } FINISH {|| .F. } PANEL
	
	// painel de inclusão de menus
	cTitle 	:= STR0030 //###"Configuração menu Microsiga Protheus"
	cMSg	:= STR0035 //###"Para maiores informações, consulte o help."
	CREATE PANEL oWizard HEADER cTitle MESSAGE cMsg BACK {|| .T. } NEXT {|| .F. } FINISH {|| .T. } PANEL
	
	//Informar parâmetros
	oPanel := oWizard:GetPanel(2) 
	
	@ 10,10 SAY STR0003			OF oPanel SIZE 90,8 PIXEL //###"URL do webservice do Protheus"
	@ 16,10 MsGet cIRWS  		OF oPanel SIZE 180,9 When .T. PIXEL
	
	@ 30,10 SAY STR0005			OF oPanel SIZE 90,8  PIXEL //###"URL do banco de dados"
	@ 36,10 MsGet cIRDBURL		OF oPanel SIZE 130,9 When .T. PIXEL    
	
	@ 30,150 SAY STR0007			OF oPanel SIZE 95,8 PIXEL //###"Porta"
	@ 36,150 MsGet cIRDBPOR		OF oPanel SIZE 40,9 When .T. PIXEL    
	
	@ 50,10 SAY STR0041			OF oPanel SIZE 90,8 PIXEL  //"Tipo de driver JDBC"
	TComboBox():Create(oPanel,{|u|if(PCount()>0,cIRDBTP:=u,cIRDBTP)},56,10, aItems,180,9,,,,,,.T.,,,,,,,,,'cIRDBTP')
	
	//--------------------------------------------------------------------------------
	// Caso seja utilizado conexão ODBC, só está homologado para versão 7 ou anterior.
	//--------------------------------------------------------------------------------
	TSay():New(66,10,{|| iif(AllTrim(cIRDBTP) == "ODBC", STR0042, "")},oPanel,,,,,,.T.,CLR_RED,CLR_WHITE,180,8) // "O Driver nativo ODBC está homologado somente para Java 7 ou anterior."

	@ 73,10 SAY STR0009			OF oPanel SIZE 90,8  PIXEL //###"Nome do database"
	@ 79,10 MsGet cIRDB			OF oPanel SIZE 180,9 When .T. PIXEL
	
	@ 93,10 SAY STR0011	   		OF oPanel SIZE 90,8 PIXEL //###"Usuário do Banco de Dados"
	@ 99,10 MsGet cIRDBUSR		OF oPanel SIZE 90,9 When .T. PIXEL
	
	@ 113,10 SAY STR0013			OF oPanel SIZE 90,8 PIXEL //###"Senha do Banco de Dados"
	@ 119,10 MsGet cIRDBPSS		OF oPanel SIZE 90,9 When .T. PIXEL PASSWORD
	
	// carregar relatórios
	oPanel := oWizard:GetPanel(3)
	@ 10,10 SAY STR0023			OF oPanel SIZE 90,8 PIXEL //###"Adicionar Relatório"
	@ 16,10 MsGet oRepName var ciRepName  	OF oPanel SIZE 100,9 When .T. PIXEL //###"Localizar"
	
	tButton():New(16,110,"...",oPanel,{|| ciRepName := findFile() },10,11,,,,.T.) //###"Localizar"
	tButton():New(16,130,STR0025,oPanel,{|| uploadFile(ciRepName, self) },60,11,,,,.T.) //###"Adicionar ao Servidor"
	
	@ 60,10 SAY STR0026			OF oPanel SIZE 150,8 PIXEL //###"Relatórios disponíveis no servidor"
	oLstRpts := TCBrowse():New(36,10,278,100,,,,oPanel,,,,,,,,,,,,,,.T.)
	oLstRpts:setArray(listReports())
	oColumn := TCColumn():New()
	oColumn:cHeading := ""
	oColumn:lBitmap := .T.
	oColumn:nWidth := 10
	oColumn:nAlign := 1
	oColumn:bData := {|| iif(oLstRpts:nAt > 0 .and. len(oLstRpts:aArray) >= oLstRpts:nAt, LoadBitmap(GetResources(), 'br_cancel'), "") }
	oLstRpts:AddColumn(oColumn)

	oColumn := TCColumn():New()
	oColumn:cHeading := STR0036 //###"Relatório"
	oColumn:lBitmap := .F.
	oColumn:nWidth := 40
	oColumn:nAlign := 0
	oColumn:bData := {|| iif(oLstRpts:nAt > 0 .and. len(oLstRpts:aArray) >= oLstRpts:nAt, oLstRpts:aArray[oLstRpts:nAt, 1], "") }
	oLstRpts:AddColumn(oColumn)
	
	oColumn := TCColumn():New()
	oColumn:cHeading := STR0037 //###"Detalhes"
	oColumn:lBitmap := .F.
	oColumn:nWidth := 30
	oColumn:nAlign := 0
	oColumn:bData := {|| iif(oLstRpts:nAt > 0 .and. len(oLstRpts:aArray) >= oLstRpts:nAt, oLstRpts:aArray[oLstRpts:nAt, 2], "") }
	oLstRpts:AddColumn(oColumn)
	
	oLstRpts:blDblClick := {|a,b| iif(b<=1,doDelClick(oLstRpts:nAt), "")}
	
	// carregar relatórios
	oPanel := oWizard:GetPanel(4)
	@ 10,10 SAY STR0031 OF oPanel SIZE 250,30 PIXEL //###""Para a disponibilização de relatórios iReports, configure o menu do Protheus para acessar os relatórios iReports. Para cada relatório a ser disponibilizado será necessário o cadastro de um menu no Microsiga Protheus."
	@ 60,10 SAY STR0032 OF oPanel SIZE 250,8  PIXEL //###"Lembrando que:"
	@ 70,10 SAY STR0033 OF oPanel SIZE 250,8  PIXEL //###"O tipo de Menu deverá ser configurado como 'Relatório do iReports'"
	@ 80,10 SAY STR0034 OF oPanel SIZE 250,8  PIXEL //###"E o nome da função do menu deverá conter o nome físico do relatório iReports (sem extensão)"
	
	ACTIVATE WIZARD oWizard CENTERED WHEN {||.T.}
	
	DelClassIntf()
	
return nil

// ----------------------------------------------------------------------------------------
// Essa funcao ira criar os parametros MVs no SX6 conforme os dados informados pelo usuário
// ----------------------------------------------------------------------------------------
static function persistFields()
	Local nInd	:= 0
	Local nI	:= 0
	Local nJ	:= 0
	Local cAux  := ''
	Local lRet 	:= .T.
	Local lRecLock := .F.
	Local aStruct := {}
	Local aSX6 := {}
	Local aParams := {}
	
	aParams := { { "MV_IRWS", "C", "S", STR0002, .T., STR0001 + ": " + STR0003 }, ; 		//###"WebService do Microsiga Protheus responsável por recuperar o relatório iReports no Server"###"Campo obrigatório"###"Servidor WebService"
				{ "MV_IRDBURL", "C", "S", STR0004, .T., STR0001 + ": " + STR0005 }, ; 	//###"Conexão com o Servidor de Banco de Dados"###"Conexão Banco de Dados"
				{ "MV_IRDBPOR", "C", "S", STR0006, .F., NIL }, ; 						//###"Porta da Conexão com o Servidor de Banco de Dados"
				{ "MV_IRDBTP", "C", "S", STR0040, .T., STR0001 + ": " + STR0040 }, ; 	//###"Driver JDBC"###"Driver JDBC"
				{ "MV_IRDB", "C", "S", STR0008, .T., STR0001 + ": " + STR0009 }, ; 		//###"Nome do database utilizado para recuperar os dados para os relatórios iReports"###"Nome Banco de Dados"
				{ "MV_IRDBUSR", "C", "S", STR0010, .T., STR0001 + ": " + STR0011 }, ; 	//###"Usuário a ser utilizado na autenticação no Servidor de Banco de Dados"###"Usuário Banco de Dados"
				{ "MV_IRDBPSS", "C", "S", STR0012, .T., STR0001 + ": " + STR0013 } }	//###"Senha a ser utilizada na autenticação no Servidor de Banco de Dados"###"Senha Banco de Dados"


	dbSelectArea("SX6")
	
	For nInd := 1 to len( aParams )
		aStruct := {}
		aSX6 := {}

		SX6->( dbSetOrder(1) )
		SX6->( dbGoTop() )
		
		cAux := allTrim(&("c"+strTran(aParams[nInd, 1], "MV_", "")))
		If aParams[nInd, 5] .AND. empty(cAux)
			MsgStop(aParams[nInd, 6]) // Mensagem de erro
			lRet := .F.
		Else
			If !SX6->( dbSeek( xFilial("SX6") + adjustSpaces(aParams[nInd, 1], 10)))
				lReclock := .T.

				aStruct := { "X6_FIL", "X6_VAR", "X6_TIPO", "X6_PROPRI", "X6_DESCRIC", "X6_DSCSPA", "X6_DSCENG", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG" }
				aSX6 := { xFilial("SX6"), ; //X6_FIL
					aParams[nInd, 1], ; 	//X6_VAR
					aParams[nInd, 2], ; 	//X6_TIPO
					aParams[nInd, 3], ; 	//X6_PROPRI
					aParams[nInd, 4], ; 	//X6_DESCRIC
					aParams[nInd, 4], ; 	//X6_DSCSPA
					aParams[nInd, 4], ;		//X6_DSCENG
					cAux			, ; 	//X6_CONTEUD
					cAux			, ; 	//X6_CONTSPA
					cAux			 } 		//X6_CONTENG
			Else
				aStruct := { "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG" }
				aSX6 := { cAux			   , ; //X6_CONTEUD
					cAux				   , ; //X6_CONTSPA
					cAux				   } //X6_CONTENG
			EndIf

			For nI := 1 to len( aSX6 )
				RecLock( "SX6", lReclock )
					For nJ := 1 To Len( aSX6[nI] )
						If FieldPos( aStruct[nJ] ) > 0
							FieldPut( FieldPos( aStruct[nJ] ), aSX6[nI][nJ] )
						EndIf
					Next nJ
				MsUnLock()
			Next
		EndIf
	Next
	
	FWFreeArray( aStruct )
return lRet

// ----------------------------------------------------------------------------------------
// Essa funcao ira ajustar o valor de um determinado campo com o máximo de caracteres que
// ele poderá conter. Isso é necessário para campso de tela MsGet. Será adicionado espaços
// em branco ao final do valor até a quantidade de caracteres máxima.
// Parms:
//	pcValue, string, valor a ser "ajustado"
//	pnSpaces, numérico, quantidade máxima de caracteres
// ----------------------------------------------------------------------------------------
static function adjustSpaces(pcValue, pnQtdeCaracter)
	
	If len(pcValue) < pnQtdeCaracter
		pcValue := pcValue + space(pnQtdeCaracter - len(pcValue))
	Else
		pcValue := right(pcValue, pnQtdeCaracter)
	EndIf
	
return pcValue

// ----------------------------------------------------------------------------------------
// Essa funcao exibe uma caixa de seleção de arquivos para serem carregados no servidor Protheus
// Parms: ciRepName, string, nome do arquivo selecionado (passado por referência)
// ----------------------------------------------------------------------------------------
static function findFile()
		
return AllTrim(cGetFile(REP_EXT_LABEL, STR0027, 0 ,  , .F. , nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NETWORKDRIVE ), , .T. )) //###"Selecione o arquivo que deseja subir para o servidor"

// ----------------------------------------------------------------------------------------
// Essa funcao ira subir/upload de um arquivo iReport/JasperSoft para o servidor Protheus
// Parms: ciRepName, string, nome com caminho completo do arquivo
// ----------------------------------------------------------------------------------------
static function uploadFile(ciRepName, oCGetFile)
	
	Local aAux
	
	If empty(ciRepName)
		MsgStop(STR0027) //###"Selecione o arquivo que deseja subir para o servidor"
	Else
		aAux := aBIToken(ciRepName, "\")
		If len(strTran(aAux[len(aAux)], "."+REPORTS_EXTENS)) > 10
			MsgStop(STR0022) //###"Atenção, o tamanho permitido para o nome do relatório é de no máximo 10 caracteres (excluindo a extensão)"
		ElseIf !CpyT2S(ciRepName, REPORTS_PATH)
			MsgStop(STR0028, allTrim(ciRepName)) //###"Erro ao carregar arquivo para o servidor"
		Else
			MsgInfo(STR0029, allTrim(ciRepName)) //###"Arquivo carregado com sucesso para o servidor"
			oLstRpts:setArray(listReports())
			oLstRpts:Refresh()
			oRepName:cText := ""
			oRepName:Refresh()
		EndIf
	EndIF
	
return

// ----------------------------------------------------------------------------------------
// Essa funcao ira listar os arquivos criados pelo iReports/JasperSoft e contidos no servidor Protheus
// ----------------------------------------------------------------------------------------
function listReports()
	
	Local aDirectory
	Local cCurDir := CurDir()
	
	CurDir(REPORTS_PATH)
	aDirectory := DIRECTORY(REP_EXT_MASCARA,"F", , .F.)
	aEval( aDirectory, {|aFile, i| aDirectory[i] := {aFile[1], cBIStr(Day(aFile[3]))+"/"+cBIStr(Month(aFile[3]))+"/"+cBIStr(Year(aFile[3])) + " " + aFile[4] + " - " + cBIStr(aFile[2]) + "B" } } )
	CurDir(cCurDir)
	
return aDirectory

// ----------------------------------------------------------------------------------------
// Essa funcao ira excluir o arquivo selecionado na grid de relatórios contidos no servidor
// ----------------------------------------------------------------------------------------
static function doDelClick(nRow)
	Local cCurDir := CurDir()
	Local oFile
	Local cFileName := oLstRpts:aArray[nRow, 1]
	
	CurDir(REPORTS_PATH)
	oFile := TBIFileIO():New(REPORTS_PATH+"\"+cFileName)
	If oFile:lExists()
		if oFile:lErase()
			MsgInfo(STR0038, allTrim(cFileName)) //###"Arquivo excluído com sucesso do servidor"
		Else
			MsgStop(STR0039, allTrim(cFileName)) //###"Erro ao excluír arquivo do servidor"
		EndIf
	EndIf
	oFile:lClose()
	CurDir(cCurDir)
	
	oLstRpts:setArray(listReports())
	oLstRpts:Refresh()
return

// Function de Teste
Main function tstcfgIRept()
	prepare environment empresa "99" filial "01"
	cfgIReport()
return

