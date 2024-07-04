#Include 'protheus.ch'
#Include 'fileio.ch'
#Define lLinux IsSrvUnix()
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
	#define barra "\"
#ELSE
	#define CRLF Chr(10)
	#define barra "/"
#ENDIF
#DEFINE ARQ_LOG_CNX		"importacao_cnx.log"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSBENCNX

Rotina para leitura e importação do arquivo CNX.

@author Everton.Mateus
@since 29/09/2020
/*/
//--------------------------------------------------------------------------------------------------
Function PLSBENCNX()
	Local aSay		:= {}
	Local aButton	:= {}
	Local nOpc		:= 0
	Local Titulo	:= 'Importacao de Beneficiarios ANS'
	Local cDesc1	:= 'Este processo irá importar os dados dos beneficiários '
	Local cDesc2	:= 'que foram enviados para a ANS para dentro da '
	Local cDesc3	:= 'estrutura de tabelas do SIGAPLS '
	Local cCadastro	:= "Importação de beneficiários a partir do CNX"

	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )

	aAdd( aButton, { 5, .T., { || nOpc := 5, Pergunte('PLSSIBCNX',.T.,Titulo,.F.) } } )
	aAdd( aButton, { 1, .T., { || nOpc := 2, Iif( ValidaPergunta(), FechaBatch(), nOpc := 0 ) } } )
	aAdd( aButton, { 2, .T., { || FechaBatch() } } )

	FormBatch( Titulo, aSay, aButton )

	If nOpc == 2
		cArqCNX	:= AllTrim(mv_par01)
		If !Empty(cArqCNX)
			Processa( { || PLSCNXPRO(cArqCNX) },cCadastro,'Processando...',.F.)
		Else
			MsgInfo("Para confirmar o processamento selecione um arquivo.","TOTVS")
		EndIf
	EndIf
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaPergunta
Funcao criada para verificar se as perguntas obrigatorias foram respondidas

@return lRet	Verdadeiro (.T.) se as perguntas foram respondidas, senao Falso (.F.)

@author timoteo.bega
@since 03/06/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ValidaPergunta()
	Local lRet	:= .T.
	Local cMsg	:= ""

	If Empty(mv_par01)
		lRet := .F.
		cMsg += "Qual arquivo deve ser importado ?" + CRLF
	EndIf

	If !lRet
		MsgInfo("Os seguintes parametros nao foram respondidos: " + CRLF + CRLF + cMsg ,"TOTVS")
	EndIf
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCNXPRO
Rotina criada para processar o arquivo CNX

@param cArqCNX Arquivo CNX que será importado
@return lRet	Verdadeiro (.T.) se processou até o final. Falso (.F.) se encontrou algum erro.

@author Everton.Mateus
@since 29/09/2020
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCNXPRO(cArqCNX)
	Local oImporter := CNXImporter():new()
	Local oCNXOutBA0 := CNXOutBA0():New()
	Local oCNXOutBG9 := CNXOutBG9():New()
	Local oCNXOutBT5 := CNXOutBT5():New()
	Local oCNXOutBQC := CNXOutBQC():New()
	Local oCNXOutBTS := CNXOutBTS():New()
	Local oCNXOutBI3 := CNXOutBI3():New()
	Local oCNXOutBA1 := CNXOutBA1():New()
	Local oCNXOutBA3 := CNXOutBA3():New()
	Local nBenef := 0

	DEFAULT cArqCNX	:= AllTrim(mv_par01) //Arquivo de conferencia no formato CNX que sera processado
	oCNXOutBA1:oCnxOutBqc := oCnxOutBqc
	oCNXOutBA1:oCnxOutBi3 := oCnxOutBi3
	oCNXOutBA1:oCnxOutBts := oCnxOutBts
	oCNXOutBA1:oCnxOutBA3 := oCnxOutBA3

	conout("###Importação do arquivo CNX iniciada.###")

	oImporter:setReader(CNXReader():new(cArqCNX))
	oImporter:aPreImp := {;
		oCNXOutBA0,;
		oCNXOutBG9;
		}
	oImporter:aImp := {;
		oCNXOutBT5,;
		oCNXOutBQC,;
		oCNXOutBTS,;
		oCNXOutBI3,;
		oCNXOutBA1;
		}
	lSuccess := oImporter:import()
	If !lSuccess
		msgAlert(oImporter:getError(), "Erro ao importar o arquivo")
	EndIf
	PlsLogFil(CENDTHRL("I") + "Término do processamento do arquivo. " + cArqCNX, ARQ_LOG_CNX)
	conout("###Importação do arquivo CNX finalizada.###")
	MsgInfo("Importação do arquivo CNX finalizada.","Aviso")
	nBenef := oImporter:nQtdImp
	oImporter:destroy()
	FreeObj(oImporter)
	oImporter := nil
Return nBenef
