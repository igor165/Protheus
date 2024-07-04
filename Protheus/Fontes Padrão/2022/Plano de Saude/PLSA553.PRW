#include "PROTHEUS.CH"
#include "FILEIO.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PLSA553  º Autor ³ TOTVS S/A			    º Data ³ 02/01/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Leitura e Importacao Arquivo XML   						  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA553(lAutoma)
Local aSays      := {}
Local aButtons   := {}
Local nOpca	     := 0
Local cCadastro  := "Processamento do arquivo de importação do XML do SUS"
Default lAutoma	:= .F.

Private cPerg 	:= "PLSA553" // Grupo de perguntas

aAdd(aSays,"Esta rotina irá processar o arquivo de  importação do XML do SUS.")

aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)}})
aAdd(aButtons, { 1,.T.,{|| nOpca := 1, If( .T.,FechaBatch(),nOpca := 0)}})
aAdd(aButtons, { 2,.T.,{|| FechaBatch()}})

If !lAutoma
	FormBatch(cCadastro, aSays, aButtons, , 160)

	If nOpca == 1 
		Processa({||PLPROCXML()},cCadastro,"Processando...",.T.)
	EndIf
Else 
	PLPROCXML(lAutoma)
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PLPROCXMLº Autor ³ TOTVS S/A			    º Data ³ 02/01/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Processa a Importacao Arquivo XML recebido da ANS   		  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLPROCXML(lAutoma)
LOCAL lValidXML	:= .T.
LOCAL cError	:= ""  			 // Erro ao ler o arquivo xml
LOCAL cWarning	:= ""  			 // Avisos ao ler o arquivo xml
LOCAL nRegs, nCont, nQtProc, cCodB0R 	:= 0
LOCAL cDTReg	:= ""
LOCAL nTotProc	:= 0
LOCAL aCritic	:= {}
LOCAL aRetProc	:= {}
LOCAL aRetBene	:= {}
LOCAL cDESINC	:= ""
LOCAL lCritic	:= .F.
LOCAL cMensagem	:= ""
Default lAutoma := .F.


Static oXml,oTrbXml,oXmlIde,oXmlPREST,oXmlPRE,oXmlAIHS,oXmlATE,oXmlBENE,oXmlPROC,oTrbCAB,oTrbCABID,oTrbCABOR,oTrbVER,oXmlPROCINC := Nil // Objetos XML

If !PL552VPar()
	Return (.F.)
Endif

cArqBase:=AllTrim(Mv_Par01)
While .T.
	If At('\',cArqBase)>0
		nProcBar:=(At('\',cArqBase)+1)
		cArqBase:=Substr(cArqBase,nProcBar,Len(AllTrim(Mv_Par01)))
	Else
		cArqBase:=cArqBase
		Exit
	Endif
Enddo

If Len(AllTrim(Mv_Par01))=0
	MsgInfo("Informe o caminho do arquivo XML.")
	Return .F.
Endif

If( Upper(Alltrim(TCSrvType()))<> "LINUX")
	If !ExistDir("\sus\")
		If MakeDir("\sus\" ) <> 0
			MsgStop("Diretorio \sus\ não encontrado e não foi possivel cria-lo.")
		Endif
	EndIf
	cStartPath 	:= 	"\sus\"
Else
	If !ExistDir("/sus/")
		If MakeDir("/sus/" ) <> 0
			MsgStop("Diretorio /sus/ não encontrado e não foi possivel cria-lo.")
		Endif
	EndIf
	cStartPath 	:= 	"/sus/"

Endif

If !lAutoma
	If !CPYT2S(Iif(':\' $ Mv_Par01, AllTrim(Mv_Par01), GetSrvProfString ("ROOTPATH","") + AllTrim(Mv_Par01)),cStartPath,.F.)
		MsgInfo("Informe o caminho do arquivo XML.")
		Return .F.
	Endif
EndIf

cStartPath 	:= 	cStartPath+cArqBase

If !Empty(AllTrim(Mv_Par01) )
	oXml	:= XmlParserFile(cStartPath,"_",@cError,@cWarning)  //carregou o XML
	If ValType(oXml) == "U"
		lValidXML := .F.
	Else
		oTrbXml	:= XmlChildEx(oXml,"_MENSAGEMABI") // Carrega o objeto XML com o conteudo do arquivo
		If ValType(oTrbXml) <> "O" .OR. ValType(XmlChildEx(oTrbXml:_CORPOMENSAGEM,"_ANSPARAOPERADORA")) <> "O" // Verifica se o arquivo carrega e valido
			lValidXML := .F.
		EndIf
	EndIf
Else
	MsgInfo("Informe o caminho do arquivo XML.")
	Return .F.
Endif

If !lValidXML
	MsgInfo("Arquivo selecionado é inválido!")
	Return .F.
EndIf

//Atualiza o objeto com os registros para conferencia
oTrbCAB		:= oTrbXml:_CABECALHO
oTrbCABID	:= XmlChildEx(oTrbCAB,"_IDENTIFICACAOTRANSACAO")
oTrbCABOR	:= XmlChildEx(oTrbCAB,"_ORIGEM")
oTrbVER   :=  XmlChildEx(oTrbCAB,"_VERSAOPADRAO")

oTrbXml		:= oTrbXml:_CORPOMENSAGEM:_ANSPARAOPERADORA:_ABI

If oTrbXml == Nil
	MsgInfo("Nao existem registros no arquivo para serem processados")
	Return .F.
EndIf

If ValType(oTrbXml) == "O"
	nQtRegs	:= 1 // So tenho um registro no arquivo
Else
	nQtRegs	:= Len(oTrbXml) // Tenho varios registros no arquivo
EndIf

nRegs := 1

//Valida se a importação do arquivo ainda não ocorreu
DbSelectArea("B0O")
B0O->(dbSetOrder(1)) //B0O_FILIAL+B0O_IDANS+B0O_DTXML+B0O_HRXML+B0O_STATUS
cDTReg := CTOD(SUBSTR(oTrbCABID:_dataRegistroTransacao:TEXT,9,2)+"/"+SUBSTR(oTrbCABID:_dataRegistroTransacao:TEXT,6,2)+"/"+SUBSTR(oTrbCABID:_dataRegistroTransacao:TEXT,1,4))
If !B0O->(dbSeek( xFilial("B0O") + PADR(oTrbCABOR:_identificadorANS:TEXT,tamsx3("B0O_IDANS")[1]) + DToS(cDTReg) ))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia a transacao...                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction

	//INCLUIR O RESUMO DO RESSARCIMENTO
		RecLock("B0O", .T.)
		B0O_FILIAL	:= xFilial("B0O")
		B0O_IDANS	:= oTrbCABOR:_identificadorANS:TEXT
		B0O_MESPRO	:= SUBSTR(oTrbCABID:_dataRegistroTransacao:TEXT,6,2)
		B0O_ANOPRO	:= SUBSTR(oTrbCABID:_dataRegistroTransacao:TEXT,1,4)
		B0O_QTDPRO	:= nQtRegs
		B0O_STATUS	:= '1'
		B0O_DTXML	:= cDTReg
		B0O_HRXML	:= StrTran(SUBSTR(oTrbCABID:_HoraRegistroTransacao:TEXT,1,5),":","")
		B0O->(MsUnlock())

	//OPERADORA DE SAUDE
		oXmlIde		:= XmlChildEx(oTrbXml,"_IDENTIFICACAOOPERADORA")
		oXmlPREST	:= XmlChildEx(oTrbXml,"_PRESTADORES") 
		oXmlPRE		:= XmlChildEx(oXmlPREST,"_PRESTADOR")
		If ValType(oXmlPRE) == "O"
			nQtRegs	:= 1 			// So tenho um registro no arquivo
			oXmlPRE := {oXmlPRE} 	// Transforma o objeto em Array para prosseguir com a gravação abaixo
		Else
			nQtRegs := Len(oXmlPRE) // Tenho varios registros no arquivo
		EndIf


		dbSelectArea("B0R")
		dbSetOrder(1)
		If Val(oTrbVER:TEXT) == 1
			PLA553VER1(nRegs,nQtRegs,@aCritic)
		Else
			PLA553VER2(nRegs,nQtRegs,@aCritic)
		EndIf

		If VAL(oTrbXml:_quantidadeProcesso:TEXT) > 0
			RecLock("B0O", .F.)
			B0O_QTDPRO	:= VAL(oTrbXml:_quantidadeProcesso:TEXT)
			B0O->(MsUnlock())
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza Transacao...                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	End Transaction
	If !lAutoma
		cMensagem := "Importação concluída com sucesso !!!"
		If !EMPTY(aCritic)
			cMensagem += CRLF+CRLF+ "Houveram Críticas na Importação do Arquivo."
			PLSCRIGEN(aCritic,{ {"CAMPO","@C",90} , {"CRITICA","@C",80 } },"RESUMO DE CRÍTICAS")
		EndIf
		MsgInfo(cMensagem,"Atenção" )
	EndIf
Else
	If !lAutoma
		MsgInfo("Esse arquivo já foi importado","Atenção" )
	EndIf
	Return .F.
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R992DIRECTºAutor  ³ PLS Team           º Data ³  07/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao usada no pergunte.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL992DirX(cCPO)
LOCAL cRET	:=	cGetFile("Arquivo xml | *.xml","SELECIONE O ARQUIVO XML",,"",.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY+128)

&(cCPO) 		:= cRET

Return (!Empty(cRET))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLA553Pro ºAutor  ³ Michel Montoro     º Data ³  07/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca codigo do procedimento da TUNEP na tabela BA8		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLA553Pro(cCdPaDp, cCodPro, cCodTab)
LOCAL cSQL		:= ""
LOCAL aRet		:= {.T.,"","",""}
LOCAL lSai		:= .F.

DEFAULT cCodTab := GETMV("MV_CDTUNEP")

If EMPTY(cCdPaDp+cCodPro)
	aRet[1] := .F.
	aRet[4] := "Código de Procedimento SUS não encontrado para Tipo Tabela de Saude [VAZIO]"
	Return(aRet)
EndIf

//Procura pelo codigo da TUNEP na BA8
cSQL := " SELECT BA8_FILIAL,BA8_CODPAD, BA8_CODPRO FROM "+RetSQLName("BA8")
cSQL += " WHERE BA8_CDPADP = '"+cCdPaDp+"' "
cSQL += " AND BA8_CODPRO   = '"+AllTrim(cCodPro)+"' "
cSQL += " AND BA8_FILIAL   = '"+xFilial('BA8')+"' "
If !Empty(allTrim(cCodTab))
	cSQL += " AND BA8_CODTAB = '"+cCodTab+"' "
EndIf
cSQL += " AND D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBBA8",.F.,.T.)

//Busca o correspondente na TUSS ou na tabela indicada pela operadora.
TRBBA8->( DbGoTop() )
If TRBBA8->( EOF() )
	aRet[1] := .F.
	aRet[4] := "Código de Procedimento SUS não encontrado para Tipo Tabela de Saude"+" ["+ cCdPaDp +"-"+ AllTrim(cCodPro)+"]"
Else
	While !TRBBA8->( EOF() )
		cSQL := " SELECT BW0_FILIAL,BW0_CODPD2, BW0_CODPR2 "
		cSQL += " FROM "+RetSQLName("BW0") +" BW0 "
		cSQL += " WHERE BW0_CODPD1 = '"+cCdPaDp+"' "
		cSQL += " AND   BW0_FILIAL = '"+xFilial('BW0')+"' "
		cSQL += " AND   BW0_CODPR1 = '"+Alltrim(cCodPro)+"' "
		cSQL += " AND D_E_L_E_T_ = ' ' "

		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBBW0",.F.,.T.)

		TRBBW0->( DbGoTop() )
		If ! TRBBW0->( EOF() )
			aRet[1] := .T.
			aRet[2] := TRBBW0->BW0_CODPD2
			aRet[3] := TRBBW0->BW0_CODPR2
			aRet[4] := ""
			lSai := .T.
		Else
			aRet[1] := .F.
			aRet[4] := "Código de Procedimento SUS [" + cCdPaDp+"-"+Alltrim(cCodPro) + "] não relacionado da rotina DE/PARA !!!"
		EndIf
		TRBBW0->(DbCloseArea())
		If lSai
			Exit
		EndIf
		TRBBA8->( DbSkip() )
	EndDo

EndIf

TRBBA8->(DbCloseArea())

Return(aRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLA553Ben º Autor ³ Michel Montoro     º Data ³  14/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca os dados do Beneficiário através da chave BA1_CODCCO º±±
±±º		     ³ Código de Controle Operacional							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLA553Ben(cChvBene, dDtNascto)
LOCAL aRet		:= {{.T.,"Mensagem"}}
LOCAL cSQL		:= ""

DEFAULT dDtNascto := CToD("")

If EMPTY(cChvBene)
	aRet[01][01] := .F.
	aRet[01][02] := "Código de Controle Operacional (BA1_CODCCO) do Beneficiário [VAZIO] não encontrado !!!"
	Return(aRet)
EndIf

//Procura pelo Código de Controle Operacional (BA1_CODCCO) do Beneficiário
cSQL := "SELECT BA1_FILIAL,BA1_CODINT, BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_CPFUSR,BA1_DRGUSR,BA1_DIGITO,BA1_CONEMP,BA1_VERCON,BA1_SUBCON,"
cSQL += "BA1_VERSUB,BA1_MATVID,BA1_NOMUSR "
cSQL += "FROM "+RetSQLName("BA1") + " WHERE "
cSQL += "BA1_FILIAL = '"+ xFilial('BA1') +"' AND "
cSQL += "BA1_CODCCO = '"+ AllTrim(cChvBene) +"' AND "
cSQL += "D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBBA1",.F.,.T.)

TRBBA1->( DbGoTop() )
If TRBBA1->( EOF() )
	aRet[01][01] := .F.
	aRet[01][02] := "Código de Controle Operacional (BA1_CODCCO) do Beneficiário ["+ AllTrim(cChvBene) +"] não encontrado !!!"
Else
	aAdd(aRet,AllTrim( TRBBA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ) ) // 02 B0R_USUARI:= BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	aAdd(aRet,TRBBA1->BA1_CODEMP) 	// 03 B0R_CODEMP:= BA1_CODEMP
	aAdd(aRet,TRBBA1->BA1_MATRIC) 	// 04 B0R_MATRIC:= BA1_MATRIC
	aAdd(aRet,TRBBA1->BA1_TIPREG) 	// 05 B0R_TIPREG:= BA1_TIPREG
	aAdd(aRet,TRBBA1->BA1_CPFUSR) 	// 06 B0R_CPFUSR:= BA1_CPFUSR
	aAdd(aRet,TRBBA1->BA1_DRGUSR) 	// 07 B0R_IDUSR := BA1_DRGUSR
	aAdd(aRet,TRBBA1->BA1_DIGITO) 	// 08 B0R_DIGITO:= BA1_DIGITO
	aAdd(aRet,TRBBA1->BA1_CONEMP) 	// 09 B0R_CONEMP:= BA1_CONEMP
	aAdd(aRet,TRBBA1->BA1_VERCON) 	// 10 B0R_VERCON:= BA1_VERCON
	aAdd(aRet,TRBBA1->BA1_SUBCON) 	// 11 B0R_SUBCON:= BA1_SUBCON
	aAdd(aRet,TRBBA1->BA1_VERSUB) 	// 12 B0R_VERSUB:= BA1_VERSUB
	aAdd(aRet,TRBBA1->BA1_MATVID) 	// 13 B0R_MATVID:= BA1_MATVID
	aAdd(aRet,TRBBA1->BA1_NOMUSR) 	// 14 B0R_NOMUSR:= BA1_NOMUSR
EndIf

TRBBA1->(DbCloseArea())

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fGrvAten º Autor ³ Michel Montoro     º Data ³  14/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava os campos iniciais do Atendimento identicos a todos  º±±
±±º		     ³ os atendimentos											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGrvAten()
LOCAL cCodB0R 	:= ""
LOCAL cLocate 	:= ""
LOCAL cCODESP 	:= ""
LOCAL nTAmProc	:= SX3->(tamSX3('B0R_NUMPRO')[1])

// INICIO
B0R->B0R_FILIAL	:= xFilial("B0R")
B0R->B0R_IDANS	:= B0O->B0O_IDANS

// ABI
B0R->B0R_OFICIO	:= oTrbXml:_numeroOficio:TEXT
B0R->B0R_NUMPRO	:= SUBSTR(oTrbXml:_numeroProcesso:TEXT,1,nTAmProc)
If B0R->(FieldPos('B0R_NRABI')) > 0
	B0R->B0R_NRABI 	:= oTrbXml:_numeroABI:TEXT
EndIf
//CAMPO	:= oTrbXml:_numeroABI:TEXT
//CAMPO := oTrbXml:_quantidadeProcesso:TEXT
//CAMPO := oTrbXml:_valorTotalProcess:TEXT

// IDENTIFICACAO OPERADORA
//CAMPO := oXmlIde:_CNPJ:TEXT
//CAMPO	:= oXmlIde:_registroANS:TEXT
//CAMPO	:= oXmlIde:_razaoSocial:TEXT

// CAMPOS NAO GRAVADOS DO XML
cCodB0R         := GETSX8NUM("B0R","B0R_CODIGO")// TESTE DE GATILHAMENTO AUTOMATICO PELO SX3
B0R->B0R_CODIGO	:= cCodB0R
B0R->B0R_STATUS	:= '1'
B0R->B0R_MESPRO	:= B0O->B0O_MESPRO
B0R->B0R_ANOPRO	:= B0O->B0O_ANOPRO
B0R->B0R_DATPRO	:= B0O->B0O_DTXML
B0R->B0R_HORPRO	:= B0O->B0O_HRXML//StrTran(Time(),":","")
B0R->B0R_NOMRDA	:= Posicione("BAU",1,xFilial("BAU")+GETMV("MV_RDASUS"), "BAU_NOME")
cLocate         := Posicione("BB8",1,xFilial("BAU")+GETMV("MV_RDASUS"), "BB8_CODLOC+BB8_LOCAL")
B0R->B0R_LOCATE	:= cLocate
B0R->B0R_DESLOC := Posicione("BB8",1,xFilial("BAU")+GETMV("MV_RDASUS"), "BB8_DESLOC")
B0R->B0R_CODLOC	:= Posicione("BB8",1,xFilial("BAU")+GETMV("MV_RDASUS"), "BB8_CODLOC")
cCODESP         := Posicione("BAX",1,xFilial("BAX")+GetMV("MV_RDASUS")+PLSINTPAD()+SUBS(cLocate,1,3),"BAX_CODESP")
B0R->B0R_CODESP	:= cCODESP
B0R->B0R_DESESP	:= Posicione("BAQ",1,xFilial("BAQ")+PLSINTPAD()+cCODESP,"BAQ_DESCRI")
B0R->B0R_TIPPRE	:= Posicione("BAU",1,xFilial("BAU")+GETMV("MV_RDASUS"), "BAU_TIPPRE")
B0R->B0R_ARQIMP	:= AllTrim(Mv_Par01)
B0R->B0R_CODOPE	:= PLSINTPAD()
B0R->B0R_OPERDA	:= PLSINTPAD()
B0R->B0R_CODRDA	:= GETNEWPAR("MV_RDASUS","000001")
B0R->B0R_TIPADM	:= GETNEWPAR("MV_PLSTPAD","1")
B0R->B0R_SIGLA	:= GetNEWPAR("MV_PLSIGLA","CRM")
B0R->B0R_DTDIG1	:= dDatabase

Return(cCodB0R)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLA553VER1
Importa xml do ressarcimento SUS versão 1.0

@author	Lucas de Azevedo Nonato
@since		04/12/2015
@version	P12
@Return	L
@Obs
/*/
//---------------------------------------------------------------------------------------

Function PLA553VER1(nRegs,nQtRegs,aCritic)
	LOCAL nI, nQtdAIH :=   0
	Local nTotProc:=0
	Local cMacro := "AttIsMemberOf(oXmlBENE,'_codigoBeneficiario')" //Alteração solicitada pela TECH devido ao erro na utilização da função no RPO.
	Local cMvTABSUS := GETMV("MV_TABSSUS")
	Local cCodCNES 	:= ""
	Local aEndereUPS:= {,,,} //{ endereco , municipio , codUF , cep }
	Local cNomeUPS 	:= ""
	Local oXmlUpsEnd:= Nil
	Local cTipoAdm	:= ""
	Local cVincBkp	:= ""
		
	While nRegs <= nQtRegs // Vou percorrer todos os registros de PRESTADORES do arquivo
						
            //PRESTADOR
			//CAMPO		:= oXmlPRE:_nomeUPS:TEXT
			//CAMPO		:= oXmlPRE:_naturezaUPS:TEXT
			//CAMPO		:= oXmlPRE:_quantidadePrestador:TEXT
			//CAMPO		:= oXmlPRE:_valorTotalPrestador:TEXT
			
			//ENDERECO UPS
			//oXmlUPS	:= XmlChildEx(oXmlPREST[nRegs],"_ENDERECOUPS")
			//CAMPO		:= oXmlUPS:_endereco:TEXT
			//CAMPO		:= oXmlUPS:_municipio:TEXT
			//CAMPO		:= oXmlUPS:_codigoUF:TEXT
			//CAMPO		:= oXmlUPS:_cep:TEXT
			
			//ACESSO AO NÓ DO XML REFERENTE AOS ATENDIMENTOS (AIHS->AIH)
			oXmlAIHS	:= XmlChildEx(oXmlPRE[nRegs],"_AIHS")
			oXmlAIH		:= XmlChildEx(oXmlAIHS,"_AIH")

			//Armazena o codigo do CNES do prestador e nome da UPS
			cCodCNES 	:= oXmlPRE[nRegs]:_CNES:TEXT 
			cNomeUPS	:= oXmlPRE[nRegs]:_nomeUPS:TEXT

			//Armazena dados do enredeço
			oXmlUpsEnd	  := XmlChildEx(oXmlPRE[nRegs],"_ENDERECOUPS")
			aEndereUPS[1] := oXmlUpsEnd:_endereco:TEXT
			aEndereUPS[2] := oXmlUpsEnd:_municipio:TEXT
			aEndereUPS[3] := oXmlUpsEnd:_codigoUF:TEXT
			aEndereUPS[4] := oXmlUpsEnd:_cep:TEXT

			If ValType(oXmlAIH) == "O"
				nQtdAIH	:= 1 // So tenho um registro no arquivo
			Else
				nQtdAIH	:= Len(oXmlAIH) // Tenho varios registros no arquivo
			EndIf
							
			If nQtdAIH == 1  // NO CASO DE SER SOMENTE UM AIH, O OBJETO NAO É UM ARRAY POR ESSE MOTIVO ESSA TRATATIVA

				lCritic := .F.			
				RecLock("B0R", .T.)
			    //PROCESSO - ABAIXO CORRESPONTE A CAMPOS IGUAIS A TODOS OS ATENDIMENTOS
				cCodB0R := fGrvAten()
			
				B0R->B0R_VALOR	:= VAL(oXmlAIH:_VALORTOTALAIH:TEXT)
				If B0R->(FieldPos('B0R_CDCMPT')) > 0
					B0R->B0R_CDCMPT 	:= oXmlAIH:_competenciaAIH:TEXT
				EndIf
				
				//IDENTIFICACAO DO ATENDIMENTO	
				oXmlATE		:= XmlChildEx(oXmlAIH,"_ATENDIMENTOIDENTIFICADO")
				B0R->B0R_AIHAPA	:= oXmlATE:_numeroAIHapac:TEXT
				B0R->B0R_DATEVE	:= stod(SUBSTR(oXmlATE:_dataInicioAtendimento:TEXT,1,4)+ SUBSTR(oXmlATE:_dataInicioAtendimento:TEXT,6,2)+ SUBSTR(oXmlATE:_dataInicioAtendimento:TEXT,9,2))
				B0R->B0R_DTALTA	:= stod(SUBSTR(oXmlATE:_dataFimAtendimento:TEXT,1,4)+ SUBSTR(oXmlATE:_dataFimAtendimento:TEXT,6,2)+ SUBSTR(oXmlATE:_dataFimAtendimento:TEXT,9,2))
				B0R->B0R_REGINT	:= "1"
				//B0R->B0R_REGINT	:= oXmlATE:_caraterInternacao:TEXT	
				cTipoAdm := oXmlATE:_caraterInternacao:TEXT
				cVincBkp	:= PLSVARVINC('23',, cTipoAdm)
				If !Empty(cVincBkp)
					cTipoAdm := cVincBkp
				EndIf	
				B0R->B0R_TIPADM	:= cTipoAdm		

				//BENEFICIARIO
				oXmlBENE		:= XmlChildEx(oXmlAIH,"_BENEFICIARIO")
				B0R->B0R_CODCCO	:= oXmlBENE:_codigoCCO:TEXT
				B0R->B0R_DATNAS	:= SToD(SUBSTR(oXmlBENE:_dataNascBeneficiario:TEXT,1,4)+ SUBSTR(oXmlBENE:_dataNascBeneficiario:TEXT,6,2)+ SUBSTR(oXmlBENE:_dataNascBeneficiario:TEXT,9,2))
				B0R->B0R_OPEUSR	:= PLSINTPAD()
				If B0R->(FieldPos('B0R_CODBEN')) > 0
					If &(cMacro)
						B0R->B0R_CODBEN	:= AllTrim(oXmlBENE:_codigoBeneficiario:TEXT)
					EndIf
				EndIf
				aRetBene		:= PLA553Ben(B0R->B0R_CODCCO, B0R->B0R_DATNAS)
				If aRetBene[1][1]
					B0R->B0R_USUARI:= aRetBene[02]	// Chave - BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
					B0R->B0R_CODEMP:= aRetBene[03]	// BA1_CODEMP
					B0R->B0R_MATRIC:= aRetBene[04]	// BA1_MATRIC
					B0R->B0R_TIPREG:= aRetBene[05]	// BA1_TIPREG
					B0R->B0R_CPFUSR:= aRetBene[06]	// BA1_CPFUSR
					B0R->B0R_IDUSR := aRetBene[07]	// BA1_DRGUSR
					B0R->B0R_DIGITO:= aRetBene[08]	// BA1_DIGITO
					B0R->B0R_CONEMP:= aRetBene[09]	// BA1_CONEMP
					B0R->B0R_VERCON:= aRetBene[10]	// BA1_VERCON
					B0R->B0R_SUBCON:= aRetBene[11]	// BA1_SUBCON
					B0R->B0R_VERSUB:= aRetBene[12]	// BA1_VERSUB
					B0R->B0R_MATVID:= aRetBene[13]	// BA1_MATVID
					B0R->B0R_NOMUSR:= aRetBene[14]	// BA1_NOMUSR
					B0R->B0R_MATUSA:= "1"			// 1=Matricula Principal; 2=Matricula Antiga
				Else
					If GetNewPar('MV_MGENSUS',.F.) .AND. (!Empty(GetNewPar('MV_MATGSUS',"")))//Ativa processo de Matricula Generica no Ressarcimento SUS
						B0R->B0R_USUARI:= GetNewPar('MV_MATGSUS',"99999999999999999")// Parametro de Matricula Generica para o Ressarcimento SUS
						B0R->B0R_CODEMP:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),5,4)	// BA1_CODEMP
						B0R->B0R_MATRIC:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),9,6)	// BA1_MATRIC
						B0R->B0R_TIPREG:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),15,2)	// BA1_TIPREG
						B0R->B0R_CPFUSR:= ""	// BA1_CPFUSR
						B0R->B0R_IDUSR := ""	// BA1_DRGUSR
						B0R->B0R_DIGITO:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),17,1)	// BA1_DIGITO
						B0R->B0R_CONEMP:= ""	// BA1_CONEMP
						B0R->B0R_VERCON:= ""	// BA1_VERCON
						B0R->B0R_SUBCON:= ""	// BA1_SUBCON
						B0R->B0R_VERSUB:= ""	// BA1_VERSUB
						B0R->B0R_MATVID:= ""	// BA1_MATVID
						B0R->B0R_NOMUSR:= "USUARIO GENERICO"	// BA1_NOMUSR
						B0R->B0R_MATUSA:= "1"			// 1=Matricula Principal; 2=Matricula Antiga
					Else				
						lCritic := .T.
						aADD(aCritic,{"Beneficiário não Encontrado",aRetBene[1][2]})
						B0R->B0R_STATUS	:= '2'
					EndIf
				EndIf
				
				//Grava o CNES
				B0R->B0R_CDCNES := cCodCNES		

				//Grava EnderecoUps
				if B0R->(FieldPos('B0R_NOMUPS')) > 0
					B0R->B0R_NOMUPS 	:= cNomeUPS
				EndIf

				if B0R->(FieldPos('B0R_ENRERE')) > 0
					B0R->B0R_ENRERE 	:= aEndereUPS[1]
				EndIf
				
				if B0R->(FieldPos('B0R_MUNICI')) > 0
					B0R->B0R_MUNICI 	:= aEndereUPS[2]
				EndIf
				
				if B0R->(FieldPos('B0R_CODIUF')) > 0
					B0R->B0R_CODIUF 	:= aEndereUPS[3]
				EndIf
				
				if B0R->(FieldPos('B0R_CEPUPS')) > 0
					B0R->B0R_CEPUPS 	:= aEndereUPS[4]
				EndIf
				
				//PROCEDIMENTOS
				oXmlPROCS	:= XmlChildEx(oXmlAIH,"_PROCEDIMENTOS")
				oXmlPROC	:= XmlChildEx(oXmlPROCS,"_PROCEDIMENTO")
				
				If ValType(oXmlPROC) == "O"
					nQtProc	:= 1 // So tenho um PROCEDIMENTO no arquivo
				Else
					nQtProc	:= Len(oXmlPROC) // Tenho varios PROCEDIMENTOS no arquivo
				EndIf
								
				If nQtProc == 1  // NO CASO DE EXISTIR SOMENTE UM PROCEDIMENTO, O OBJETO NAO É UM ARRAY POR ESSE MOTIVO ESSA TRATATIVA
                    
					dbSelectArea("B0W")
					dbSetOrder(1)
					RecLock("B0W", .T.)
					B0W->B0W_FILIAL	:= xFilial("B0W")
					B0W->B0W_CODIGO	:= cCodB0R
					B0W->B0W_SEQUEN	:= "001"     
					B0W->B0W_QTDPRO	:= VAL(oXmlPROC:_quantidadeProcedimento:TEXT)
					nTotProc		:= nTotProc + VAL(oXmlPROC:_quantidadeProcedimento:TEXT)
					B0W->B0W_VLRAPR := NOROUND(VAL(oXmlPROC:_valorProcedimento:TEXT) / VAL(oXmlPROC:_quantidadeProcedimento:TEXT),4) //O Valor do Procedimento já possui o valor cheio com base na quantidade.
					
					oXmlPROCINC	:= XmlChildEx(oXmlPROC,"_INCREMENTOS")
					If ValType(oXmlPROCINC) == "O"
						If VALTYPE(oXmlPROCINC:_incremento) == "O"
					   		B0W->B0W_DESINC := oXmlPROCINC:_incremento:_descricao:TEXT
						ElseIf VALTYPE(oXmlPROCINC:_incremento) == "A"
							cDESINC := ""
							For nI := 1 To LEN(oXmlPROCINC:_incremento)
								cDESINC += AllTrim(STR(nI)) +")"+ oXmlPROCINC:_incremento[nI]:_descricao:TEXT +" "
							Next nI
							B0W->B0W_DESINC := SUBSTR(cDESINC,1,250)
                        EndIf
					Else
						B0W->B0W_DESINC := ""
					Endif
					
					B0W->B0W_DATPRO	:= B0R->B0R_DATEVE
					B0W->B0W_STATUS	:= "1"
					B0W->B0W_OPEMOV	:= PLSINTPAD()
					B0W->B0W_CDPADP	:= cMvTABSUS
					B0W->B0W_TUNEP	:= oXmlPROC:_codigoProcedimento:TEXT
					If B0W->(FieldPos('B0W_DESPRO')) > 0
						B0W->B0W_DESPRO := oXmlPROC:_descricaoProcedimento:TEXT
					EndIf
					aRetProc		:= PLA553Pro(B0W->B0W_CDPADP,B0W->B0W_TUNEP)
					If aRetProc[1]
						B0W->B0W_CODPAD	:= aRetProc[2]
						B0W->B0W_CODPRO	:= aRetProc[3]
					Else
						lCritic := .T.
						aADD(aCritic,{"Procedimento não Encontrado",aRetProc[LEN(aRetProc)]})
					EndIf
					If B0W->(FieldPos('B0W_TPPROC')) > 0
						B0W->B0W_TPPROC 	:= oXmlPROC:_tipoProcedimento:TEXT
					EndIf
					//CAMPO 	:=oXmlPROC:_descricaoProcedimento:TEXT //NAO SERA USANDO

					If lCritic
						B0R->B0R_STATUS	:= "2"
						B0W->B0W_STATUS	:= "2"
					EndIf
      										
					B0W->(MsUnlock())
					
     			Else
      				nCont		:= 1  
      				nTotProc	:= 0
      				
      				dbSelectArea("B0W")
      				dbSetOrder(1)
      				While nCont <= nQtProc // Vou percorrer todos os registros do arquivo
      					RecLock("B0W", .T.)
      					B0W->B0W_FILIAL	:= xFilial("B0W")
      					B0W->B0W_CODIGO	:= cCodB0R
      					B0W->B0W_SEQUEN	:= StrZero(nCont,3)     
      					B0W->B0W_QTDPRO	:= VAL(oXmlPROC[nCont]:_quantidadeProcedimento:TEXT)
      					nTotProc		:= nTotProc + VAL(oXmlPROC[nCont]:_quantidadeProcedimento:TEXT)
						B0W->B0W_VLRAPR := NOROUND(VAL(oXmlPROC[nCont]:_valorProcedimento:TEXT) / VAL(oXmlPROC[nCont]:_quantidadeProcedimento:TEXT),4) //O Valor do Procedimento já possui o valor cheio com base na quantidade.
      					
      					oXmlPROCINC	:= XmlChildEx(oXmlPROC[nCont],"_INCREMENTOS")
      					If ValType(oXmlPROCINC) == "O"
							If VALTYPE(oXmlPROCINC:_incremento) == "O"
						   		B0W->B0W_DESINC := oXmlPROCINC:_incremento:_descricao:TEXT
							ElseIf VALTYPE(oXmlPROCINC:_incremento) == "A"
								cDESINC := ""
								For nI := 1 To LEN(oXmlPROCINC:_incremento)
									cDESINC += AllTrim(STR(nI)) +")"+ oXmlPROCINC:_incremento[nI]:_descricao:TEXT +" "
								Next nI
								B0W->B0W_DESINC := SUBSTR(cDESINC,1,250)
	                        EndIf
						Else
							B0W->B0W_DESINC := ""
						Endif
						
      					B0W->B0W_DATPRO	:= B0R->B0R_DATEVE
      					B0W->B0W_STATUS	:= "1"
      					B0W->B0W_OPEMOV	:= PLSINTPAD()
      					B0W->B0W_CDPADP	:= cMvTABSUS
      					B0W->B0W_TUNEP	:= oXmlPROC[nCont]:_codigoProcedimento:TEXT
      					If B0W->(FieldPos('B0W_DESPRO')) > 0
							B0W->B0W_DESPRO :=  oXmlPROC[nCont]:_descricaoProcedimento:TEXT
						EndIf
      					aRetProc		:= PLA553Pro(B0W->B0W_CDPADP,B0W->B0W_TUNEP)
      					If aRetProc[1]
      						B0W->B0W_CODPAD	:= aRetProc[2]
      						B0W->B0W_CODPRO	:= aRetProc[3]
      					Else
      						lCritic := .T. 
      						aADD(aCritic,{"Procedimento não Encontrado",aRetProc[LEN(aRetProc)]})
      					EndIf
      					If B0W->(FieldPos('B0W_TPPROC')) > 0
      						B0W->B0W_TPPROC 	:= oXmlPROC[nCont]:_tipoProcedimento:TEXT
						EndIf
      					
      					If lCritic
      						B0R->B0R_STATUS	:= "2"
      						B0W->B0W_STATUS	:= "2"
      					EndIf
      					
      					B0W->(MsUnlock())
      					nCont++
      					
      				EndDo
      			Endif
		   		B0R->B0R_QTDEVE := nTotProc
		   		nTotProc := 0
		   		
				//GRAVACAO DOS CAMPOS
				B0R->(MsUnlock())
				B0R->(ConfirmSX8())
				nQtProc := 0
				
			Else // PARA VARIOS OBJETOS DEVO LER ARRAY DE OBJETOS.
   				
				For nI := 1 To nQtdAIH
				
					lCritic := .F.			
					RecLock("B0R", .T.)
				    //PROCESSO - ABAIXO CORRESPONTE A CAMPOS IGUAIS A TODOS OS ATENDIMENTOS
					cCodB0R := fGrvAten()
				
					B0R->B0R_VALOR	:= VAL(oXmlAIH[nI]:_VALORTOTALAIH:TEXT)
					If B0R->(FieldPos('B0R_CDCMPT')) > 0
						B0R->B0R_CDCMPT 	:= oXmlAIH[nI]:_competenciaAIH:TEXT
					EndIf
					
					//IDENTIFICACAO DO ATENDIMENTO	
					oXmlATE		:= XmlChildEx(oXmlAIH[nI],"_ATENDIMENTOIDENTIFICADO") 
					B0R->B0R_AIHAPA	:= oXmlATE:_numeroAIHapac:TEXT
					B0R->B0R_DATEVE	:= stod(SUBSTR(oXmlATE:_dataInicioAtendimento:TEXT,1,4)+ SUBSTR(oXmlATE:_dataInicioAtendimento:TEXT,6,2)+ SUBSTR(oXmlATE:_dataInicioAtendimento:TEXT,9,2))
					B0R->B0R_DTALTA	:= stod(SUBSTR(oXmlATE:_dataFimAtendimento:TEXT,1,4)+ SUBSTR(oXmlATE:_dataFimAtendimento:TEXT,6,2)+ SUBSTR(oXmlATE:_dataFimAtendimento:TEXT,9,2))
					B0R->B0R_REGINT	:= "1"

					cTipoAdm := oXmlATE:_caraterInternacao:TEXT
					cVincBkp	:= PLSVARVINC('23',, cTipoAdm)
					If !Empty(cVincBkp)
						cTipoAdm := cVincBkp
					EndIf	
					B0R->B0R_TIPADM	:= cTipoAdm		
					
					//BENEFICIARIO
					oXmlBENE		:= XmlChildEx(oXmlAIH[nI],"_BENEFICIARIO")
					B0R->B0R_CODCCO	:= oXmlBENE:_codigoCCO:TEXT
					B0R->B0R_DATNAS	:= SToD(SUBSTR(oXmlBENE:_dataNascBeneficiario:TEXT,1,4)+ SUBSTR(oXmlBENE:_dataNascBeneficiario:TEXT,6,2)+ SUBSTR(oXmlBENE:_dataNascBeneficiario:TEXT,9,2))
					B0R->B0R_OPEUSR	:= PLSINTPAD()
					If B0R->(FieldPos('B0R_CODBEN')) > 0
						If &(cMacro)
							B0R->B0R_CODBEN	:= AllTrim(oXmlBENE:_codigoBeneficiario:TEXT)
						EndIf
					EndIf
					aRetBene		:= PLA553Ben(B0R->B0R_CODCCO, B0R->B0R_DATNAS)
					If aRetBene[1][1]
						B0R->B0R_USUARI:= aRetBene[02]	// Chave - oXmlBENE:_codigoBeneficiario
						B0R->B0R_CODEMP:= aRetBene[03]	// BA1_CODEMP
						B0R->B0R_MATRIC:= aRetBene[04]	// BA1_MATRIC
						B0R->B0R_TIPREG:= aRetBene[05]	// BA1_TIPREG
						B0R->B0R_CPFUSR:= aRetBene[06]	// BA1_CPFUSR
						B0R->B0R_IDUSR := aRetBene[07]	// BA1_DRGUSR
						B0R->B0R_DIGITO:= aRetBene[08]	// BA1_DIGITO
						B0R->B0R_CONEMP:= aRetBene[09]	// BA1_CONEMP
						B0R->B0R_VERCON:= aRetBene[10]	// BA1_VERCON
						B0R->B0R_SUBCON:= aRetBene[11]	// BA1_SUBCON
						B0R->B0R_VERSUB:= aRetBene[12]	// BA1_VERSUB
						B0R->B0R_MATVID:= aRetBene[13]	// BA1_MATVID
						B0R->B0R_NOMUSR:= aRetBene[14]	// BA1_NOMUSR
						B0R->B0R_MATUSA:= "1"			// 1=Matricula Principal; 2=Matricula Antiga
					Else
						If GetNewPar('MV_MGENSUS',.F.) .AND. (!Empty(GetNewPar('MV_MATGSUS',"")))//Ativa processo de Matricula Generica no Ressarcimento SUS
							B0R->B0R_USUARI:= GetNewPar('MV_MATGSUS',"99999999999999999")// Parametro de Matricula Generica para o Ressarcimento SUS
							B0R->B0R_CODEMP:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),5,4)	// BA1_CODEMP
							B0R->B0R_MATRIC:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),9,6)	// BA1_MATRIC
							B0R->B0R_TIPREG:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),15,2)	// BA1_TIPREG
							B0R->B0R_CPFUSR:= ""	// BA1_CPFUSR
							B0R->B0R_IDUSR := ""	// BA1_DRGUSR
							B0R->B0R_DIGITO:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),17,1)	// BA1_DIGITO
							B0R->B0R_CONEMP:= ""	// BA1_CONEMP
							B0R->B0R_VERCON:= ""	// BA1_VERCON
							B0R->B0R_SUBCON:= ""	// BA1_SUBCON
							B0R->B0R_VERSUB:= ""	// BA1_VERSUB
							B0R->B0R_MATVID:= ""	// BA1_MATVID
							B0R->B0R_NOMUSR:= "USUARIO GENERICO"	// BA1_NOMUSR
							B0R->B0R_MATUSA:= "1"			// 1=Matricula Principal; 2=Matricula Antiga
						Else
							lCritic := .T.
							aADD(aCritic,{"Beneficiário não Encontrado",aRetBene[1][2]})
							B0R->B0R_STATUS	:= '2'
						EndIf					
					EndIf

					//Grava o CNES
					B0R->B0R_CDCNES:= cCodCNES

					//Grava EnderecoUps
					if B0R->(FieldPos('B0R_NOMUPS')) > 0
						B0R->B0R_NOMUPS 	:= cNomeUPS
					EndIf

					if B0R->(FieldPos('B0R_ENRERE')) > 0
						B0R->B0R_ENRERE 	:= aEndereUPS[1]
					EndIf
					
					if B0R->(FieldPos('B0R_MUNICI')) > 0
						B0R->B0R_MUNICI 	:= aEndereUPS[2]
					EndIf
					
					if B0R->(FieldPos('B0R_CODIUF')) > 0
						B0R->B0R_CODIUF 	:= aEndereUPS[3]
					EndIf
					
					if B0R->(FieldPos('B0R_CEPUPS')) > 0
						B0R->B0R_CEPUPS 	:= aEndereUPS[4]
					EndIf

					//PROCEDIMENTOS
					oXmlPROCS	:= XmlChildEx(oXmlAIH[nI],"_PROCEDIMENTOS")
					oXmlPROC	:= XmlChildEx(oXmlPROCS,"_PROCEDIMENTO")     
					
					If ValType(oXmlPROC) == "O"
						nQtProc	:= 1 // So tenho um PROCEDIMENTO no arquivo
					Else
						nQtProc	:= Len(oXmlPROC) // Tenho varios PROCEDIMENTOS no arquivo
					EndIf
					
					If nQtProc = 1  // NO CASO DE EXISTIR SOMENTE UM PROCEDIMENTO, O OBJETO NAO EH UM ARRAY POR ESSE MOTIVO ESSA TRATATIVA
						dbSelectArea("B0W")
						dbSetOrder(1)
						RecLock("B0W", .T.)
						B0W->B0W_FILIAL	:= xFilial("B0W")
						B0W->B0W_CODIGO	:= cCodB0R
						B0W->B0W_SEQUEN	:= "001"     
						B0W->B0W_QTDPRO	:= VAL(oXmlPROC:_quantidadeProcedimento:TEXT)
						nTotProc		:= nTotProc + VAL(oXmlPROC:_quantidadeProcedimento:TEXT)
						B0W->B0W_VLRAPR := NOROUND(VAL(oXmlPROC:_valorProcedimento:TEXT) / VAL(oXmlPROC:_quantidadeProcedimento:TEXT),4) //O Valor do Procedimento já possui o valor cheio com base na quantidade.
						//B0W->B0W_VLRAPR	:= NOROUND(VAL(oXmlPROC:_valorProcedimento:TEXT)/nTotProc,5) // Grava o Vlr Unitario.
						//B0W->B0W_VLRAPR	:= NOROUND(nVPro/nTotProc,4) // Grava o Vlr Unitario.
						
						oXmlPROCINC	:= XmlChildEx(oXmlPROC,"_INCREMENTOS")
      					If ValType(oXmlPROCINC) == "O"
							If VALTYPE(oXmlPROCINC:_incremento) == "O"
						   		B0W->B0W_DESINC := oXmlPROCINC:_incremento:_descricao:TEXT
							ElseIf VALTYPE(oXmlPROCINC:_incremento) == "A"
								cDESINC := ""
								For nI := 1 To LEN(oXmlPROCINC:_incremento)
									cDESINC += AllTrim(STR(nI)) +")"+ oXmlPROCINC:_incremento[nI]:_descricao:TEXT +" "
								Next nI
								B0W->B0W_DESINC := SUBSTR(cDESINC,1,250)
	                        EndIf
						Else
							B0W->B0W_DESINC := ""
						Endif
						
						B0W->B0W_DATPRO	:= B0R->B0R_DATEVE
						B0W->B0W_STATUS	:= "1"
						B0W->B0W_OPEMOV	:= PLSINTPAD()
						B0W->B0W_CDPADP	:= cMvTABSUS
						B0W->B0W_TUNEP	:= oXmlPROC:_codigoProcedimento:TEXT
						If B0W->(FieldPos('B0W_DESPRO')) > 0
							B0W->B0W_DESPRO := oXmlPROC:_descricaoProcedimento:TEXT
						EndIf
						aRetProc		:= PLA553Pro(B0W->B0W_CDPADP,B0W->B0W_TUNEP)
						If aRetProc[1]
							B0W->B0W_CODPAD	:= aRetProc[2]
							B0W->B0W_CODPRO	:= aRetProc[3]
						Else
							lCritic := .T.
							aADD(aCritic,{"Procedimento não Encontrado",aRetProc[LEN(aRetProc)]})
						EndIf
						If B0W->(FieldPos('B0W_TPPROC')) > 0
							B0W->B0W_TPPROC 	:= oXmlPROC:_tipoProcedimento:TEXT
						EndIf
						//CAMPO 	:=oXmlPROC:_descricaoProcedimento:TEXT //NAO SERA USANDO
						
						If lCritic
							B0R->B0R_STATUS	:= "2"
							B0W->B0W_STATUS	:= "2"
						EndIf
						
						B0W->(MsUnlock())
						
					Else // ARRAY DE OBJETOS
      					
						nCont		:= 1
						nTotProc	:= 0
						
						dbSelectArea("B0W")
						dbSetOrder(1)
						While nCont <= nQtProc // Vou percorrer todos os registros do arquivo
							RecLock("B0W", .T.)
							B0W->B0W_FILIAL	:= xFilial("B0W")
							B0W->B0W_CODIGO	:= cCodB0R
							B0W->B0W_SEQUEN	:= StrZero(nCont,3)     
							B0W->B0W_QTDPRO	:= VAL(oXmlPROC[nCont]:_quantidadeProcedimento:TEXT)
							nTotProc		:= nTotProc + VAL(oXmlPROC[nCont]:_quantidadeProcedimento:TEXT)
							B0W->B0W_VLRAPR := NOROUND(VAL(oXmlPROC[nCont]:_valorProcedimento:TEXT) / VAL(oXmlPROC[nCont]:_quantidadeProcedimento:TEXT),4) //O Valor do Procedimento já possui o valor cheio com base na quantidade.
							//B0W->B0W_VLRAPR	:= NOROUND(VAL(oXmlPROC:_valorProcedimento:TEXT)/nTotProc,3) // Grava o Vlr Unitario.
							//B0W->B0W_VLRAPR	:= NOROUND(nVPro/nTotProc,4) // Grava o Vlr Unitario.
							
							oXmlPROCINC	:= XmlChildEx(oXmlPROC[nCont],"_INCREMENTOS")
	      					If ValType(oXmlPROCINC) == "O"
								If VALTYPE(oXmlPROCINC:_incremento) == "O"
							   		B0W->B0W_DESINC := oXmlPROCINC:_incremento:_descricao:TEXT
								ElseIf VALTYPE(oXmlPROCINC:_incremento) == "A"
									cDESINC := ""
									For nI := 1 To LEN(oXmlPROCINC:_incremento)
										cDESINC += AllTrim(STR(nI)) +")"+ oXmlPROCINC:_incremento[nI]:_descricao:TEXT +" "
									Next nI
									B0W->B0W_DESINC := SUBSTR(cDESINC,1,250)
		                        EndIf
							Else
								B0W->B0W_DESINC := ""
							Endif
						
							B0W->B0W_DATPRO	:= B0R->B0R_DATEVE
							B0W->B0W_STATUS	:= "1"
							B0W->B0W_OPEMOV	:= PLSINTPAD()
							B0W->B0W_CDPADP	:= cMvTABSUS
							B0W->B0W_TUNEP	:= oXmlPROC[nCont]:_codigoProcedimento:TEXT
							If B0W->(FieldPos('B0W_DESPRO')) > 0
								B0W->B0W_DESPRO := oXmlPROC[nCont]:_descricaoProcedimento:TEXT
							EndIf
							aRetProc		:= PLA553Pro(B0W->B0W_CDPADP,B0W->B0W_TUNEP)
							If aRetProc[1]
								B0W->B0W_CODPAD	:= aRetProc[2]
								B0W->B0W_CODPRO	:= aRetProc[3]
							Else
						//If lExiMSG
						//	MsgInfo(aRetProc[LEN(aRetProc)],"Atenção" )
						//Else
								FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "PLSA553: "+aRetProc[LEN(aRetProc)] , 0, 0, {})
						//EndIf
								lCritic := .T. 
								aADD(aCritic,{"Procedimento não Encontrado",aRetProc[LEN(aRetProc)]})
							EndIf
							If B0W->(FieldPos('B0W_TPPROC')) > 0
								B0W->B0W_TPPROC 	:= oXmlPROC[nCont]:_tipoProcedimento:TEXT
							EndIf
							//CAMPO 	:=oXmlPROC[nCont]:_descricaoProcedimento:TEXT //NAO SERA USANDO
							
							If lCritic
								B0R->B0R_STATUS	:= "2"
								B0W->B0W_STATUS	:= "2"
							EndIf
							
							B0W->(MsUnlock())
							nCont++
							
						EndDo
					EndIf
					
					B0R->B0R_QTDEVE := nTotProc
					nTotProc := 0
					
					//GRAVACAO DOS CAMPOS
					B0R->(MsUnlock())
					B0R->(ConfirmSX8())
					nQtProc := 0
				Next nI
						
			Endif
			
			nRegs++ // PRESTADORES
		EndDo  

Return

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLA553VER2
Importa xml do ressarcimento SUS versão 2.0

@author	Lucas de Azevedo Nonato
@since		04/12/2015
@version	P12
@Return	L 
@Obs
/*/
//---------------------------------------------------------------------------------------

Function PLA553VER2(nRegs,nQtRegs,aCritic)
	LOCAL nI, nQtdAtend :=   0
	Local nTotProc:=0
	Local cMacro  := "AttIsMemberOf(oXmlBENE,'_codigoBeneficiario')" 	//Alteração solicitada pela TECH devido ao erro na utilização da função no RPO.
	Local cMacro2 := "AttIsMemberOf(oXmlATE , '_caraterAtendimento')" //Alteração solicitada pela TECH devido ao erro na utilização da função no RPO.
	Local cMacro3 := "AttIsMemberOf(oXmlATE , '_caraterAtendimento')" //Alteração solicitada pela TECH devido ao erro na utilização da função no RPO.
	Local cMvTABSUS := GETMV("MV_TABSSUS")

	Local cCodCNES 	:= ""
	Local aEndereUPS:= {,,,} //{ endereco , municipio , codUF , cep }
	Local cNomeUPS 	:= ""
	Local oXmlUpsEnd:= Nil
	
	While nRegs <= nQtRegs // Vou percorrer todos os registros de PRESTADORES do arquivo
						
			//Armazena o codigo do CNES do prestador
			cCodCNES 	:= oXmlPRE[nRegs]:_CNES:TEXT
			cNomeUPS	:= oXmlPRE[nRegs]:_nomeUPS:TEXT

			oXmlUpsEnd	  := XmlChildEx(oXmlPRE[nRegs],"_ENDERECOUPS")
			aEndereUPS[1] := oXmlUpsEnd:_endereco:TEXT 
			aEndereUPS[2] := oXmlUpsEnd:_municipio:TEXT
			aEndereUPS[3] := oXmlUpsEnd:_codigoUF:TEXT 
			aEndereUPS[4] := oXmlUpsEnd:_cep:TEXT

			//ACESSO AO NÓ DO XML REFERENTE AOS ATENDIMENTOS (ATENDIMENTO->ATENDIMENTOS)
			oXmlATNDS	:= XmlChildEx(oXmlPRE[nRegs],"_ATENDIMENTOS")
			oXmlATEND	:= XmlChildEx(oXmlATNDS,"_ATENDIMENTO") 
			
			If ValType(oXmlATEND) == "O"
				nQtdAtend	:= 1 // So tenho um registro no arquivo
			Else
				nQtdAtend	:= Len(oXmlATEND) // Tenho varios registros no arquivo
			EndIf
							
			If nQtdAtend == 1  // NO CASO DE SER SOMENTE UM ATENDIMENTO, O OBJETO NAO É UM ARRAY POR ESSE MOTIVO ESSA TRATATIVA

				lCritic := .F.			
				RecLock("B0R", .T.)
			    //PROCESSO - ABAIXO CORRESPONTE A CAMPOS IGUAIS A TODOS OS ATENDIMENTOS
				cCodB0R := fGrvAten()
			
				B0R->B0R_VALOR	:= VAL(oXmlATEND:_valorTotal:TEXT)
				If B0R->(FieldPos('B0R_CDCMPT')) > 0
					B0R->B0R_CDCMPT 	:= oXmlATEND:_competencia:TEXT
				EndIf

				oXmlATE		:= XmlChildEx(oXmlATEND,"_ATENDIMENTOIDENTIFICADO")   
				If B0R->(FieldPos('B0R_TIPO')) > 0
					B0R->B0R_TIPO		:= oXmlATE:_tipo:TEXT
				EndIf

				oXmlATE		:= XmlChildEx(oXmlATEND,"_ATENDIMENTOIDENTIFICADO")
				B0R->B0R_AIHAPA	:= oXmlATE:_numero:TEXT
				B0R->B0R_DATEVE	:= stod(SUBSTR(oXmlATE:_dataInicioAtendimento:TEXT,1,4)+ SUBSTR(oXmlATE:_dataInicioAtendimento:TEXT,6,2)+ SUBSTR(oXmlATE:_dataInicioAtendimento:TEXT,9,2))
				B0R->B0R_DTALTA	:= stod(SUBSTR(oXmlATE:_dataFimAtendimento:TEXT,1,4)+ SUBSTR(oXmlATE:_dataFimAtendimento:TEXT,6,2)+ SUBSTR(oXmlATE:_dataFimAtendimento:TEXT,9,2))
				
				If &(cMacro2)
					//B0R->B0R_REGINT	:= oXmlATE:_caraterAtendimento:TEXT
					B0R->B0R_REGINT	:= "1"
					cTipoAdm := oXmlATE:_caraterAtendimento:TEXT
					cVincBkp	:= PLSVARVINC('23',, cTipoAdm)
					If !Empty(cVincBkp)
						cTipoAdm := cVincBkp
					EndIf	
					B0R->B0R_TIPADM	:= cTipoAdm		
				EndIf
	
				//BENEFICIARIO
				oXmlBENE		:= XmlChildEx(oXmlATEND,"_BENEFICIARIO") 
				B0R->B0R_CODCCO	:= oXmlBENE:_codigoCCO:TEXT
				B0R->B0R_DATNAS	:= SToD(SUBSTR(oXmlBENE:_dataNascBeneficiario:TEXT,1,4)+ SUBSTR(oXmlBENE:_dataNascBeneficiario:TEXT,6,2)+ SUBSTR(oXmlBENE:_dataNascBeneficiario:TEXT,9,2))
				B0R->B0R_OPEUSR	:= PLSINTPAD()
				If B0R->(FieldPos('B0R_CODBEN')) > 0
					If &(cMacro)
						B0R->B0R_CODBEN	:= AllTrim(oXmlBENE:_codigoBeneficiario:TEXT)
					EndIf
				EndIf
				aRetBene		:= PLA553Ben(B0R->B0R_CODCCO, B0R->B0R_DATNAS)
				If aRetBene[1][1]
					B0R->B0R_USUARI:= aRetBene[02]	// Chave - BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
					B0R->B0R_CODEMP:= aRetBene[03]	// BA1_CODEMP
					B0R->B0R_MATRIC:= aRetBene[04]	// BA1_MATRIC
					B0R->B0R_TIPREG:= aRetBene[05]	// BA1_TIPREG
					B0R->B0R_CPFUSR:= aRetBene[06]	// BA1_CPFUSR
					B0R->B0R_IDUSR := aRetBene[07]	// BA1_DRGUSR
					B0R->B0R_DIGITO:= aRetBene[08]	// BA1_DIGITO
					B0R->B0R_CONEMP:= aRetBene[09]	// BA1_CONEMP
					B0R->B0R_VERCON:= aRetBene[10]	// BA1_VERCON
					B0R->B0R_SUBCON:= aRetBene[11]	// BA1_SUBCON
					B0R->B0R_VERSUB:= aRetBene[12]	// BA1_VERSUB
					B0R->B0R_MATVID:= aRetBene[13]	// BA1_MATVID
					B0R->B0R_NOMUSR:= aRetBene[14]	// BA1_NOMUSR
					B0R->B0R_MATUSA:= "1"			// 1=Matricula Principal; 2=Matricula Antiga
				Else
					If GetNewPar('MV_MGENSUS',.F.) .AND. (!Empty(GetNewPar('MV_MATGSUS',"")))//Ativa processo de Matricula Generica no Ressarcimento SUS
						B0R->B0R_USUARI:= GetNewPar('MV_MATGSUS',"99999999999999999")// Parametro de Matricula Generica para o Ressarcimento SUS
						B0R->B0R_CODEMP:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),5,4)	// BA1_CODEMP
						B0R->B0R_MATRIC:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),9,6)	// BA1_MATRIC
						B0R->B0R_TIPREG:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),15,2)	// BA1_TIPREG
						B0R->B0R_CPFUSR:= ""	// BA1_CPFUSR
						B0R->B0R_IDUSR := ""	// BA1_DRGUSR
						B0R->B0R_DIGITO:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),17,1)	// BA1_DIGITO
						B0R->B0R_CONEMP:= ""	// BA1_CONEMP
						B0R->B0R_VERCON:= ""	// BA1_VERCON
						B0R->B0R_SUBCON:= ""	// BA1_SUBCON
						B0R->B0R_VERSUB:= ""	// BA1_VERSUB
						B0R->B0R_MATVID:= ""	// BA1_MATVID
						B0R->B0R_NOMUSR:= "USUARIO GENERICO"	// BA1_NOMUSR
						B0R->B0R_MATUSA:= "1"			// 1=Matricula Principal; 2=Matricula Antiga
					Else
						lCritic := .T.
						aADD(aCritic,{"Beneficiário não Encontrado",aRetBene[1][2]})
						B0R->B0R_STATUS	:= '2'
					EndIf
				EndIf
				
				//Grava o CNES				
				B0R->B0R_CDCNES := cCodCNES		

				//Grava EnderecoUps
				if B0R->(FieldPos('B0R_NOMUPS')) > 0
					B0R->B0R_NOMUPS 	:= cNomeUPS
				EndIf

				if B0R->(FieldPos('B0R_ENRERE')) > 0
					B0R->B0R_ENRERE 	:= aEndereUPS[1]
				EndIf
				
				if B0R->(FieldPos('B0R_MUNICI')) > 0
					B0R->B0R_MUNICI 	:= aEndereUPS[2]
				EndIf
				
				if B0R->(FieldPos('B0R_CODIUF')) > 0
					B0R->B0R_CODIUF 	:= aEndereUPS[3]
				EndIf
				
				if B0R->(FieldPos('B0R_CEPUPS')) > 0
					B0R->B0R_CEPUPS 	:= aEndereUPS[4]
				EndIf
				
				//PROCEDIMENTOS
				oXmlPROCS	:= XmlChildEx(oXmlATEND,"_PROCEDIMENTOS")
				oXmlPROC	:= XmlChildEx(oXmlPROCS,"_PROCEDIMENTO")     
				
				If ValType(oXmlPROC) == "O"
					nQtProc	:= 1 // So tenho um PROCEDIMENTO no arquivo
				Else
					nQtProc	:= Len(oXmlPROC) // Tenho varios PROCEDIMENTOS no arquivo
				EndIf
								
				If nQtProc == 1  // NO CASO DE EXISTIR SOMENTE UM PROCEDIMENTO, O OBJETO NAO É UM ARRAY POR ESSE MOTIVO ESSA TRATATIVA
                    
					dbSelectArea("B0W")
					dbSetOrder(1)
					RecLock("B0W", .T.)
					B0W->B0W_FILIAL	:= xFilial("B0W")
					B0W->B0W_CODIGO	:= cCodB0R
					B0W->B0W_SEQUEN	:= "001"     
					B0W->B0W_QTDPRO	:= VAL(oXmlPROC:_quantidadeProcedimento:TEXT)
					nTotProc		:= nTotProc + VAL(oXmlPROC:_quantidadeProcedimento:TEXT)
					B0W->B0W_VLRAPR := NOROUND(VAL(oXmlPROC:_valorProcedimento:TEXT) /  VAL(oXmlPROC:_quantidadeProcedimento:TEXT),4) //O Valor do Procedimento já possui o valor cheio com base na quantidade.
					
					oXmlPROCINC	:= XmlChildEx(oXmlPROC,"_INCREMENTOS")
					If ValType(oXmlPROCINC) == "O"
						If VALTYPE(oXmlPROCINC:_incremento) == "O"
					   		B0W->B0W_DESINC := oXmlPROCINC:_incremento:_descricao:TEXT
						ElseIf VALTYPE(oXmlPROCINC:_incremento) == "A"
							cDESINC := ""
							For nI := 1 To LEN(oXmlPROCINC:_incremento)
								cDESINC += AllTrim(STR(nI)) +")"+ oXmlPROCINC:_incremento[nI]:_descricao:TEXT +" "
							Next nI
							B0W->B0W_DESINC := SUBSTR(cDESINC,1,250)
                        EndIf
					Else
						B0W->B0W_DESINC := ""
					Endif
					
					B0W->B0W_DATPRO	:= B0R->B0R_DATEVE
					B0W->B0W_STATUS	:= "1"
					B0W->B0W_OPEMOV	:= PLSINTPAD()
					B0W->B0W_CDPADP	:= cMvTABSUS
					B0W->B0W_TUNEP	:= oXmlPROC:_codigoProcedimento:TEXT
					If B0W->(FieldPos('B0W_DESPRO')) > 0
						B0W->B0W_DESPRO := oXmlPROC:_descricaoProcedimento:TEXT
					EndIf
					aRetProc		:= PLA553Pro(B0W->B0W_CDPADP,B0W->B0W_TUNEP)
					If aRetProc[1]
						B0W->B0W_CODPAD	:= aRetProc[2]
						B0W->B0W_CODPRO	:= aRetProc[3]
					Else
				//If lExiMSG
				//	MsgInfo(aRetProc[LEN(aRetProc)],"Atenção" )
				//Else
						FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "PLSA553: "+aRetProc[LEN(aRetProc)] , 0, 0, {})
				//EndIf
						lCritic := .T.
						aADD(aCritic,{"Procedimento não Encontrado",aRetProc[LEN(aRetProc)]})
					EndIf
					If B0W->(FieldPos('B0W_TPPROC')) > 0
						B0W->B0W_TPPROC 	:= oXmlPROC:_tipoProcedimento:TEXT
					EndIf
					
					If lCritic
						B0R->B0R_STATUS	:= "2"
						B0W->B0W_STATUS	:= "2"
					EndIf
      										
					B0W->(MsUnlock())
					
     			Else
      				nCont		:= 1  
      				nTotProc	:= 0
      				
      				dbSelectArea("B0W")
      				dbSetOrder(1)
      				While nCont <= nQtProc // Vou percorrer todos os registros do arquivo
      					RecLock("B0W", .T.)
      					B0W->B0W_FILIAL	:= xFilial("B0W")
      					B0W->B0W_CODIGO	:= cCodB0R
      					B0W->B0W_SEQUEN	:= StrZero(nCont,3)     
      					B0W->B0W_QTDPRO	:= VAL(oXmlPROC[nCont]:_quantidadeProcedimento:TEXT)
      					nTotProc		:= nTotProc + VAL(oXmlPROC[nCont]:_quantidadeProcedimento:TEXT)
						B0W->B0W_VLRAPR := NOROUND(VAL(oXmlPROC[nCont]:_valorProcedimento:TEXT) / VAL(oXmlPROC[nCont]:_quantidadeProcedimento:TEXT),4) //O Valor do Procedimento já possui o valor cheio com base na quantidade.

      					oXmlPROCINC	:= XmlChildEx(oXmlPROC[nCont],"_INCREMENTOS")
      					If ValType(oXmlPROCINC) == "O"
							If VALTYPE(oXmlPROCINC:_incremento) == "O"
						   		B0W->B0W_DESINC := oXmlPROCINC:_incremento:_descricao:TEXT
							ElseIf VALTYPE(oXmlPROCINC:_incremento) == "A"
								cDESINC := ""
								For nI := 1 To LEN(oXmlPROCINC:_incremento)
									cDESINC += AllTrim(STR(nI)) +")"+ oXmlPROCINC:_incremento[nI]:_descricao:TEXT +" "
								Next nI
								B0W->B0W_DESINC := SUBSTR(cDESINC,1,250)
	                        EndIf
						Else
							B0W->B0W_DESINC := ""
						Endif
						
      					B0W->B0W_DATPRO	:= B0R->B0R_DATEVE
      					B0W->B0W_STATUS	:= "1"
      					B0W->B0W_OPEMOV	:= PLSINTPAD()
      					B0W->B0W_CDPADP	:= cMvTABSUS
      					B0W->B0W_TUNEP	:= oXmlPROC[nCont]:_codigoProcedimento:TEXT
      					If B0W->(FieldPos('B0W_DESPRO')) > 0
							B0W->B0W_DESPRO := oXmlPROC[nCont]:_descricaoProcedimento:TEXT
						EndIf
      					aRetProc		:= PLA553Pro(B0W->B0W_CDPADP,B0W->B0W_TUNEP)
      					If aRetProc[1]
      						B0W->B0W_CODPAD	:= aRetProc[2]
      						B0W->B0W_CODPRO	:= aRetProc[3]
      					Else
					//If lExiMSG
					//	MsgInfo(aRetProc[LEN(aRetProc)],"Atenção" )
					//Else
      						FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "PLSA553: "+aRetProc[LEN(aRetProc)] , 0, 0, {})
					//EndIf
      						lCritic := .T. 
      						aADD(aCritic,{"Procedimento não Encontrado",aRetProc[LEN(aRetProc)]})
      					EndIf
      					If B0W->(FieldPos('B0W_TPPROC')) > 0
      						B0W->B0W_TPPROC := oXmlPROC[nCont]:_tipoProcedimento:TEXT
						EndIf
      					
      					If lCritic
      						B0R->B0R_STATUS	:= "2"
      						B0W->B0W_STATUS	:= "2"
      					EndIf
      					
      					B0W->(MsUnlock())
      					nCont++
      					
      				EndDo
      			Endif
		   		B0R->B0R_QTDEVE := nTotProc
		   		nTotProc := 0
		   		
				//GRAVACAO DOS CAMPOS
				B0R->(MsUnlock())
				B0R->(ConfirmSX8())
				nQtProc := 0
				
			Else // PARA VARIOS OBJETOS DEVO LER ARRAY DE OBJETOS.
   				
				For nI := 1 To nQtdAtend
				
					lCritic := .F.			
					RecLock("B0R", .T.)
				    //PROCESSO - ABAIXO CORRESPONTE A CAMPOS IGUAIS A TODOS OS ATENDIMENTOS
					cCodB0R := fGrvAten()
				
					B0R->B0R_VALOR	:= VAL(oXmlATEND[nI]:_valorTotal:TEXT)
					If B0R->(FieldPos('B0R_CDCMPT')) > 0
						B0R->B0R_CDCMPT 	:= oXmlATEND[nI]:_competencia:TEXT
					EndIf
					
					//IDENTIFICACAO DO ATENDIMENTO	
					oXmlATE		:= XmlChildEx(oXmlATEND[nI],"_ATENDIMENTOIDENTIFICADO")   
					If B0R->(FieldPos('B0R_TIPO')) > 0
						B0R->B0R_TIPO		:= oXmlATE:_tipo:TEXT
					EndIf
					B0R->B0R_AIHAPA	:= oXmlATE:_numero:TEXT
					B0R->B0R_DATEVE	:= stod(SUBSTR(oXmlATE:_dataInicioAtendimento:TEXT,1,4)+ SUBSTR(oXmlATE:_dataInicioAtendimento:TEXT,6,2)+ SUBSTR(oXmlATE:_dataInicioAtendimento:TEXT,9,2))
					B0R->B0R_DTALTA	:= stod(SUBSTR(oXmlATE:_dataFimAtendimento:TEXT,1,4)+ SUBSTR(oXmlATE:_dataFimAtendimento:TEXT,6,2)+ SUBSTR(oXmlATE:_dataFimAtendimento:TEXT,9,2))
					
					If &(cMacro3)
						//B0R->B0R_REGINT	:= oXmlATE:_caraterAtendimento:TEXT
						B0R->B0R_REGINT	:= "1"
						cTipoAdm := oXmlATE:_caraterAtendimento:TEXT
						cVincBkp	:= PLSVARVINC('23',, cTipoAdm)
						If !Empty(cVincBkp)
							cTipoAdm := cVincBkp
						EndIf	
						B0R->B0R_TIPADM	:= cTipoAdm		
						//B0R->B0R_TIPADM	:= oXmlATE:_caraterInternacao:TEXT
					Endif	
					
					//BENEFICIARIO
					oXmlBENE		:= XmlChildEx(oXmlATEND[nI],"_BENEFICIARIO") 
					B0R->B0R_CODCCO	:= oXmlBENE:_codigoCCO:TEXT
					B0R->B0R_DATNAS	:= SToD(SUBSTR(oXmlBENE:_dataNascBeneficiario:TEXT,1,4)+ SUBSTR(oXmlBENE:_dataNascBeneficiario:TEXT,6,2)+ SUBSTR(oXmlBENE:_dataNascBeneficiario:TEXT,9,2))
					B0R->B0R_OPEUSR	:= PLSINTPAD()
					If B0R->(FieldPos('B0R_CODBEN')) > 0
						If &(cMacro)
							B0R->B0R_CODBEN	:= AllTrim(oXmlBENE:_codigoBeneficiario:TEXT)
						EndIf
					EndIf
					aRetBene		:= PLA553Ben(B0R->B0R_CODCCO, B0R->B0R_DATNAS)
					If aRetBene[1][1]
						B0R->B0R_USUARI:= aRetBene[02]	// Chave - oXmlBENE:_codigoBeneficiario
						B0R->B0R_CODEMP:= aRetBene[03]	// BA1_CODEMP
						B0R->B0R_MATRIC:= aRetBene[04]	// BA1_MATRIC
						B0R->B0R_TIPREG:= aRetBene[05]	// BA1_TIPREG
						B0R->B0R_CPFUSR:= aRetBene[06]	// BA1_CPFUSR
						B0R->B0R_IDUSR := aRetBene[07]	// BA1_DRGUSR
						B0R->B0R_DIGITO:= aRetBene[08]	// BA1_DIGITO
						B0R->B0R_CONEMP:= aRetBene[09]	// BA1_CONEMP
						B0R->B0R_VERCON:= aRetBene[10]	// BA1_VERCON
						B0R->B0R_SUBCON:= aRetBene[11]	// BA1_SUBCON
						B0R->B0R_VERSUB:= aRetBene[12]	// BA1_VERSUB
						B0R->B0R_MATVID:= aRetBene[13]	// BA1_MATVID
						B0R->B0R_NOMUSR:= aRetBene[14]	// BA1_NOMUSR
						B0R->B0R_MATUSA:= "1"			// 1=Matricula Principal; 2=Matricula Antiga
					Else
						If GetNewPar('MV_MGENSUS',.F.) .AND. (!Empty(GetNewPar('MV_MATGSUS',"")))//Ativa processo de Matricula Generica no Ressarcimento SUS
							B0R->B0R_USUARI:= GetNewPar('MV_MATGSUS',"99999999999999999")// Parametro de Matricula Generica para o Ressarcimento SUS
							B0R->B0R_CODEMP:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),5,4)	// BA1_CODEMP
							B0R->B0R_MATRIC:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),9,6)	// BA1_MATRIC
							B0R->B0R_TIPREG:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),15,2)	// BA1_TIPREG
							B0R->B0R_CPFUSR:= ""	// BA1_CPFUSR
							B0R->B0R_IDUSR := ""	// BA1_DRGUSR
							B0R->B0R_DIGITO:= Substr(GetNewPar('MV_MATGSUS',"99999999999999999"),17,1)	// BA1_DIGITO
							B0R->B0R_CONEMP:= ""	// BA1_CONEMP
							B0R->B0R_VERCON:= ""	// BA1_VERCON
							B0R->B0R_SUBCON:= ""	// BA1_SUBCON
							B0R->B0R_VERSUB:= ""	// BA1_VERSUB
							B0R->B0R_MATVID:= ""	// BA1_MATVID
							B0R->B0R_NOMUSR:= "USUARIO GENERICO"	// BA1_NOMUSR
							B0R->B0R_MATUSA:= "1"			// 1=Matricula Principal; 2=Matricula Antiga
						Else
							lCritic := .T.
							aADD(aCritic,{"Beneficiário não Encontrado",aRetBene[1][2]})
							B0R->B0R_STATUS	:= '2'
						EndIf					
					EndIf

					B0R->B0R_CDCNES:= cCodCNES

					//Grava EnderecoUps
					if B0R->(FieldPos('B0R_NOMUPS')) > 0
						B0R->B0R_NOMUPS 	:= cNomeUPS
					EndIf

					if B0R->(FieldPos('B0R_ENRERE')) > 0
						B0R->B0R_ENRERE 	:= aEndereUPS[1]
					EndIf
					
					if B0R->(FieldPos('B0R_MUNICI')) > 0
						B0R->B0R_MUNICI 	:= aEndereUPS[2]
					EndIf
					
					if B0R->(FieldPos('B0R_CODIUF')) > 0
						B0R->B0R_CODIUF 	:= aEndereUPS[3]
					EndIf
					
					if B0R->(FieldPos('B0R_CEPUPS')) > 0
						B0R->B0R_CEPUPS 	:= aEndereUPS[4]
					EndIf

					//PROCEDIMENTOS
					oXmlPROCS	:= XmlChildEx(oXmlATEND[nI],"_PROCEDIMENTOS")
					oXmlPROC	:= XmlChildEx(oXmlPROCS,"_PROCEDIMENTO")     
					
					If ValType(oXmlPROC) == "O"
						nQtProc	:= 1 // So tenho um PROCEDIMENTO no arquivo
					Else
						nQtProc	:= Len(oXmlPROC) // Tenho varios PROCEDIMENTOS no arquivo
					EndIf
					
					If nQtProc = 1  // NO CASO DE EXISTIR SOMENTE UM PROCEDIMENTO, O OBJETO NAO EH UM ARRAY POR ESSE MOTIVO ESSA TRATATIVA
						dbSelectArea("B0W")
						dbSetOrder(1)
						RecLock("B0W", .T.)
						B0W->B0W_FILIAL	:= xFilial("B0W")
						B0W->B0W_CODIGO	:= cCodB0R
						B0W->B0W_SEQUEN	:= "001"     
						B0W->B0W_QTDPRO	:= VAL(oXmlPROC:_quantidadeProcedimento:TEXT)
						nTotProc		:= nTotProc + VAL(oXmlPROC:_quantidadeProcedimento:TEXT)
						B0W->B0W_VLRAPR := NOROUND(VAL(oXmlPROC:_valorProcedimento:TEXT) / VAL(oXmlPROC:_quantidadeProcedimento:TEXT),4) //O Valor do Procedimento já possui o valor cheio com base na quantidade.
						//B0W->B0W_VLRAPR	:= NOROUND(VAL(oXmlPROC:_valorProcedimento:TEXT)/nTotProc,5) // Grava o Vlr Unitario.
						//B0W->B0W_VLRAPR	:= NOROUND(nVPro/nTotProc,4) // Grava o Vlr Unitario.
						
						oXmlPROCINC	:= XmlChildEx(oXmlPROC,"_INCREMENTOS")
      					If ValType(oXmlPROCINC) == "O"
							If VALTYPE(oXmlPROCINC:_incremento) == "O"
						   		B0W->B0W_DESINC := oXmlPROCINC:_incremento:_descricao:TEXT
							ElseIf VALTYPE(oXmlPROCINC:_incremento) == "A"
								cDESINC := ""
								For nI := 1 To LEN(oXmlPROCINC:_incremento)
									cDESINC += AllTrim(STR(nI)) +")"+ oXmlPROCINC:_incremento[nI]:_descricao:TEXT +" "
								Next nI
								B0W->B0W_DESINC := SUBSTR(cDESINC,1,250)
	                        EndIf
						Else
							B0W->B0W_DESINC := ""
						Endif
						
						B0W->B0W_DATPRO	:= B0R->B0R_DATEVE
						B0W->B0W_STATUS	:= "1"
						B0W->B0W_OPEMOV	:= PLSINTPAD()
						B0W->B0W_CDPADP	:= cMvTABSUS
						B0W->B0W_TUNEP	:= oXmlPROC:_codigoProcedimento:TEXT
						If B0W->(FieldPos('B0W_DESPRO')) > 0
							B0W->B0W_DESPRO := oXmlPROC:_descricaoProcedimento:TEXT
						EndIf
						aRetProc		:= PLA553Pro(B0W->B0W_CDPADP,B0W->B0W_TUNEP)
						If aRetProc[1]
							B0W->B0W_CODPAD	:= aRetProc[2]
							B0W->B0W_CODPRO	:= aRetProc[3]
						Else
					//If lExiMSG
					//	MsgInfo(aRetProc[LEN(aRetProc)],"Atenção" )
					//Else
							FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "PLSA553: "+aRetProc[LEN(aRetProc)] , 0, 0, {})
					//EndIf
							lCritic := .T.
							aADD(aCritic,{"Procedimento não Encontrado",aRetProc[LEN(aRetProc)]})
						EndIf
						If B0W->(FieldPos('B0W_TPPROC')) > 0
							B0W->B0W_TPPROC 	:= oXmlPROC:_tipoProcedimento:TEXT
						EndIf
						
						If lCritic
							B0R->B0R_STATUS	:= "2"
							B0W->B0W_STATUS	:= "2"
						EndIf
						
						B0W->(MsUnlock())
						
					Else // ARRAY DE OBJETOS
      					
						nCont		:= 1
						nTotProc	:= 0
						
						dbSelectArea("B0W")
						dbSetOrder(1)
						While nCont <= nQtProc // Vou percorrer todos os registros do arquivo
							RecLock("B0W", .T.)
							B0W->B0W_FILIAL	:= xFilial("B0W")
							B0W->B0W_CODIGO	:= cCodB0R
							B0W->B0W_SEQUEN	:= StrZero(nCont,3)     
							B0W->B0W_QTDPRO	:= VAL(oXmlPROC[nCont]:_quantidadeProcedimento:TEXT)
							nTotProc		:= nTotProc + VAL(oXmlPROC[nCont]:_quantidadeProcedimento:TEXT)
							B0W->B0W_VLRAPR := NOROUND(VAL(oXmlPROC[nCont]:_valorProcedimento:TEXT) / VAL(oXmlPROC[nCont]:_quantidadeProcedimento:TEXT),4) //O Valor do Procedimento já possui o valor cheio com base na quantidade.
							
							oXmlPROCINC	:= XmlChildEx(oXmlPROC[nCont],"_INCREMENTOS")
	      					If ValType(oXmlPROCINC) == "O"
								If VALTYPE(oXmlPROCINC:_incremento) == "O"
							   		B0W->B0W_DESINC := oXmlPROCINC:_incremento:_descricao:TEXT
								ElseIf VALTYPE(oXmlPROCINC:_incremento) == "A"
									cDESINC := ""
									For nI := 1 To LEN(oXmlPROCINC:_incremento)
										cDESINC += AllTrim(STR(nI)) +")"+ oXmlPROCINC:_incremento[nI]:_descricao:TEXT +" "
									Next nI
									B0W->B0W_DESINC := SUBSTR(cDESINC,1,250)
		                        EndIf
							Else
								B0W->B0W_DESINC := ""
							Endif
						
							B0W->B0W_DATPRO	:= B0R->B0R_DATEVE
							B0W->B0W_STATUS	:= "1"
							B0W->B0W_OPEMOV	:= PLSINTPAD()
							B0W->B0W_CDPADP	:= cMvTABSUS
							B0W->B0W_TUNEP	:= oXmlPROC[nCont]:_codigoProcedimento:TEXT
							If B0W->(FieldPos('B0W_DESPRO')) > 0
								B0W->B0W_DESPRO := oXmlPROC[nCont]:_descricaoProcedimento:TEXT
							EndIf
							aRetProc		:= PLA553Pro(B0W->B0W_CDPADP,B0W->B0W_TUNEP)
							If aRetProc[1]
								B0W->B0W_CODPAD	:= aRetProc[2]
								B0W->B0W_CODPRO	:= aRetProc[3]
							Else
						//If lExiMSG
						//	MsgInfo(aRetProc[LEN(aRetProc)],"Atenção" )
						//Else
								FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "PLSA553: "+aRetProc[LEN(aRetProc)] , 0, 0, {})
						//EndIf
								lCritic := .T. 
								aADD(aCritic,{"Procedimento não Encontrado",aRetProc[LEN(aRetProc)]})
							EndIf
							If B0W->(FieldPos('B0W_TPPROC')) > 0
								B0W->B0W_TPPROC 	:= oXmlPROC[nCont]:_tipoProcedimento:TEXT
							EndIf
							
							If lCritic
								B0R->B0R_STATUS	:= "2"
								B0W->B0W_STATUS	:= "2"
							EndIf
							
							B0W->(MsUnlock())
							nCont++
							
						EndDo
					EndIf
					
					B0R->B0R_QTDEVE := nTotProc
					nTotProc := 0
					
					//GRAVACAO DOS CAMPOS
					B0R->(MsUnlock())
					B0R->(ConfirmSX8())
					nQtProc := 0
				Next nI
						
			Endif
			
			nRegs++ // PRESTADORES
		EndDo  

Return
