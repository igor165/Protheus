#Include 'Protheus.ch'
#include 'Fileio.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"

#DEFINE ARQ_LOG		"rotina_xml_sip.log"
#Define D_EVENT	 1 //Eventos
#Define D_BENEF	 2 //Beneficiarios
#Define D_DESPE	 3 //Despesas
#Define D_AMD "ambulatorial"
#Define D_HOS "hospitalar"
#Define D_OBS "hospitalarObstetricia"
#Define D_ODO "odontologico"
#Define F_BLOCK  512
#define lLinux IsSrvUnix()
#IFDEF lLinux
	#define BARRA '/'
#ELSE
	#define BARRA '\'
#ENDIF
STATIC MV_PLCENDB := GetNewPar("MV_PLCENDB",.F.)
//M้tricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLCNXMLSIP

Gera o arquivo XML para o SIP

@param cCodOpe		Numero de registro da operadora na ANS
@param cCodObr		Chave da obrigacao
@param cCodComp		Chave do compromisso
@param cAno			Ano do compromisso

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLCNXMLSIP(cCodOpe,cCodObr,cCodComp,cAno,cTipo,lAuto)
	Local 	cSequen 	:= GetNewPar("MV_PLSEQSIP","000000000001")
	Local nCod			:= val(cCodComp)
	Local lOk			:= .T.
	Local cTexto		:= ""
	Default lAuto       := .F.
	Private cDir    	:= "C:\"//MV_PAR06
	Private cMesIni		:= AllTrim(StrZero(nCod + 2*(nCod-1),2)) //Calcula o m๊s inicial do trimestre Ex.: 3บ trimestre -> 3 + 2*(3-1) = m๊s 7
	Private cPerData	:= Alltrim(cAno)+SUBSTR(cCodComp,2,2)//Periodo
	Private cDtOcorren	:= ""//Referencia
	Private cPicEvento	:= "@E 99999999999"
	Private cPicBenefi 	:= "@E 99999999999"
	Private cPicTotal 	:= "@E 99999999999.99"
	Private isXMLOnFile	:= .F.//Quando o XML maior que .7 MB, e usado um arquivo secundario para nao estourar o String do Protheus.
	Private lCriaHashFi	:= .T.
	Private cXmlTempFile	:= ""
	Private cXmlSwapFile := ""
	Private cHashFile	:= "siphashfile_"+cSequen+".txt"
	Private cTipPla		:= ""
	Private cUF			:=	Space(2)
	Private cAnoSel		:=	cAno

	If Pergunte("PLSSIPXML",.T.)

		cDir := IIF(!lAuto,alltrim(MV_PAR01),"\sip\")

		If !ExistDir(cDir)
			MsgInfo("Selecione um diret๓rio para grava็ใo do arquivo!")
			PLCNXMLSIP(cCodOpe,cCodObr,cCodComp,cAno,cTipo)
		Else

			cXmlTempFile	:= Alltrim(cDir)+"sipbuffer.xml"
			cXmlSwapFile:= Alltrim(cDir)+"sipswap.xml"

			//Valido se os XSDs estใo na pasta do SIP
			if !existDir(BARRA + "sip")
				nRet := makeDir( BARRA + "sip" )
				if nRet != 0
					lAdminEmp := .T.
					lOk := .F.
					cTexto := "Nใo foi possํvel criar o diret๓rio " + GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97()) + BARRA + "sip" + " "  //"Nใo foi possํvel criar o diret๓rio \cfglog no servidor"###"C:\MP811\Protheus_Data"
					cTexto += Replicate("-",30) + Chr(13)
					cTexto += Replicate("-",30) + Chr(13)
				endIf
			endif

			if lOk

				cDirSip := BARRA + "sip"

				cArq := ""
				aArqSch := directory(cDirSip + BARRA + "SIPV1_02.XSD")
				If len(aArqSch) = 0
					If Len(aArqSch) == 0
						cArq += IIf(Empty(cArq),"",",") + " SIPV1_02.XSD"
					EndIf
				EndIf
				aArqSch1 := directory(cDirSip + BARRA + "SIPSIMPLETYPEV1_02.XSD")
				If Len(aArqSch1) == 0
					cArq += IIf(Empty(cArq),"",",") + " SIPSIMPLETYPEV1_02.XSD"
				EndIf
				aArqSch2 := directory(cDirSip + BARRA + "SIPCOMPLEXTYPEV1_02.XSD")
				If Len(aArqSch2) == 0
					cArq += IIf(Empty(cArq),"",",") + " SIPCOMPLEXTYPEV1_02.XSD"
				EndIf
				If !Empty(cArq)
					cTexto += "O(s) arquivo(s) "+ cDirSip + BARRA + cArq + " nใo foi(ram) encontrado(s) no servidor." + Chr(13)
					cTexto += Replicate("-",30) + Chr(13)
					cTexto += Replicate("-",30) + Chr(13)
					LogGerArq(cTexto)
				Else
					BA0->(DbSetOrder(5))
					If BA0->(MsSeek(xFilial("BA0")+cCodOpe))
						PlsLogFil(CENDTHRL("I") + " MontaSIPXml Inicio",ARQ_LOG)
						//Organiza o XML para envio.
						Processa( {||MontaSIPXml(cSequen,cCodOpe) } , "Processando" , "Aguarde gera็ใo do XML SIP" , .F. )
						if lHabMetric .and. lLibSupFw .and. lVrsAppSw
							FWMetrics():addMetrics("Gera Arquivo de Envio - SIP", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
						endif

						PlsLogFil(CENDTHRL("I") + " MontaSIPXml Termino",ARQ_LOG)
					Else
						MsgAlert("Operadora nใo localizada.")
					EndIf
				EndIf
			Else
				LogGerArq(cTexto)
			EndIf
		EndIf
	EndIf

Return .T.
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaSIPXml

Monta as mensagens do SIP XML

@param cSequen		Sequencial do arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MontaSIPXml(cSequen,cCodOpe)
	Local cXmlOnMemory	:=	""
	//Atencao nao mudar a ordem de declaracao das variaveis cTag?????
	Local cTagMsgSip 	:=	TMensagemSIP()
	Local cTagCabecalho	:=	TCabecalho(cSequen)
	Local cTagMensagem	:=	""
	Local cTagFimSip	:=	SIPMontaXML("mensagemSIP",,,,,,,.F.,.T.,,,,.F.)
	Default cCodOpe	:= ""

	cTagMensagem := TagMensagem(cSequen,cCodOpe)

	If isXMLOnFile
		//Insere os itens que estao faltando do XML.
		InsInXMLTemp(cTagCabecalho,.T.)
		InsInXMLTemp(cTagMsgSip,.T.)

		InsInXMLTemp(TEpilogo(),.F.)
		InsInXMLTemp(cTagFimSip,.F.)
	Else
		cXmlOnMemory	+= cTagMsgSip
		cXmlOnMemory	+= cTagCabecalho
		cXmlOnMemory	+= cTagMensagem
		cXmlOnMemory 	+= TEpilogo()
		cXmlOnMemory	+= cTagFimSip
	EndIf


	IncProc("Gravando arquivo....")
	ProcessMessage()
	//Grava o arquivo do SIP
	WriteXMLFile(cXmlOnMemory,cSequen)
	If !IsBlind() .AND. MsgYesNo("Deseja marcar o compromisso como 4-Em processamento ANS ?","TOTVS")
		MarcaComp()
	EndIf

Return .T.
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMensagemSIP

Inicializa o cabecalho do arquivo e chama a montagem do arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TMensagemSIP()
	Local cXMLCabec	:=	""
	Local cTmpTag		:=	""

	cTmpTag := "version="+'"1.0"'+" encoding="+'"ISO-8859-1"'+"?"
	cXMLCabec += SIPMontaXML("?xml",,,,,,,.T.,.F.,.T.,cTmpTag,,.F.)

	cTmpTag :='xsi:noNamespaceSchemaLocation="http://www.ans.gov.br/padroes/sip/schemas/sipV1_02.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
	cXMLCabec += SIPMontaXML("",,,,,,,.F.,.F.,,cTmpTag,,.F.)

	cXMLCabec += SIPMontaXML("mensagemSIP",,,,,,,.T.,.F.,.T.,cTmpTag,,.F.)

Return cXMLCabec
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TCabecalho

Escreve o cabecalho do arquivo e chama a montagem do arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TCabecalho(cSequen)
	Local cTag	:=	""
	ProcRegua(1)
	IncProc("Gerando cabe็alho do arquivo...")

	cTag += SIPMontaXML("cabecalho",,,,,,4,.T.,.F.,,,,.T.)

	cTag += SIPMontaXML("identificacaoTransacao",,,,,,8,.T.,.F.,,,,.T.)
	cTag += SIPMontaXML("tipoTransacao","ENVIO_SIP",,,,,12,.T.,.T.,,,,.T.)
	cTag += SIPMontaXML("sequencialTransacao",cSequen,,,,,12,.T.,.T.,,,,.T.) //MV_PLSEQSIP
	cDate:=  Gravadata(ddatabase,.F.,8)
	cTag += SIPMontaXML("dataHoraRegistroTransacao",Substr(cDate,1,4)+"-"+Substr(cDate,5,2)+"-"+Substr(cDate,7,2)+"T"+Time(),,,,,12,.T.,.T.,,,,.T.)
	cTag += SIPMontaXML("identificacaoTransacao",,,,,,8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("origem",,,,,,8,.T.,.F.,,,,.T.)

	If ! Empty(BA0->BA0_SUSEP)
		cTag += SIPMontaXML("registroANS",PadL(Trim(BA0->BA0_SUSEP),6,"0"),,,,,12,.T.,.T.,,,,.T.)
	Else
		cTag += SIPMontaXML("cnpj",PadL(Trim(BA0->BA0_CGC),14,"0"),,,,,12,.T.,.T.,,,,.T.)
	EndIf

	cTag += SIPMontaXML("origem",,,,,,8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("destino",,,,,,8,.T.,.F.,,,,.T.)
	//CNPJ da ANS : 03.589.068/0001-46
	cTag += SIPMontaXML("cnpj",PadL("03589068000146",14,"0"),,,,,12,.T.,.T.,,,,.T.)

	cTag += SIPMontaXML("destino",,,,,,8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("versaoPadrao","1.02",,,,,8,.T.,.T.,,,,.T.)

	cTag += SIPMontaXML("identificacaoSoftwareGerador",,,,,,8,.T.,.F.,,,,.T.)
	cTag += SIPMontaXML("nomeAplicativo","Microsiga Protheus - Central de Obrigacoes",,,,,12,.T.,.T.,,,,.T.)
	cTag += SIPMontaXML("versaoAplicativo","12",,,,,12,.T.,.T.,,,,.T.)
	cTag += SIPMontaXML("fabricanteAplicativo","TOTVS",,,,,12,.T.,.T.,,,,.T.)
	cTag += SIPMontaXML("identificacaoSoftwareGerador",,,,,,8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("cabecalho",,,,,,4,.F.,.T.,,,,.T.)

	If isXMLOnFile
		InsInXMLTemp(cTag,.T.)
	EndIf

Return cTag
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TagMensagem

Escreve a mensagem do SIP

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TagMensagem(cSequen,cCodOpe)
	Local cTagMsg			:=	""
	Local cTagFormCont	:=	""
	Default cSequen		:= ""
	Default cCodOpe		:= ""

	IncProc("Carregando detalhes do arquivo...")
	ProcessMessage()

	//Forma de Contratacao
	cTagMsg += SIPMontaXML("mensagem",,,,,,4,.T.,.F.,,,,.T.)
	cTagMsg += SIPMontaXML("operadoraParaANS",,,,,,8,.T.,.F.,,,,.T.) //OpeANS
	cTagMsg += SIPMontaXML("sipOperadoraParaAns",,,,,,8,.T.,.F.,,,,.T.) //sipOperadoraParaAns

	cTagMsg += SIPMontaXML("envioSip",,,,,,12,.T.,.F.,,,,.T.) //EnvioSIP
	//dataTrimestreReconhecimento na abertura
	cTagMsg += SIPMontaXML("dataTrimestreReconhecimento",,,,,,16,.T.,.F.,,,,.T.)
	cTagMsg += SIPMontaXML("dia","01",,,,,20,.T.,.T.,,,,.T.)
	cTagMsg += SIPMontaXML("mes",cMesIni,,,,,20,.T.,.T.,,,,.T.)
	cTagMsg += SIPMontaXML("ano",cAnoSel,,,,,20,.T.,.T.,,,,.T.)
	cTagMsg += SIPMontaXML("dataTrimestreReconhecimento",,,,,,16,.F.,.T.,,,,.T.)
	//fim dataTrimestreReconhecimento

	cTagMsg += SIPMontaXML("formaContratacao",,,,,,16,.T.,.F.,,,,.T.)

	//Segmentacao
	cTagFormCont := TFormaContratacao(20,cCodOpe)

	If isXMLOnFile
		InsInXMLTemp(cTagMsg,.T.)
		cTagMsg	:= ""
	Else
		cTagMsg	+=	cTagFormCont
	EndIf

	cTagMsg += SIPMontaXML("formaContratacao",,,,,,16,.F.,.T.,,,,.T.)
	cTagMsg += SIPMontaXML("envioSip",,,,,,12,.F.,.T.,,,,.T.) //EnvioSIP

	cTagMsg += SIPMontaXML("sipOperadoraParaAns",,,,,,8,.F.,.T.,,,,.T.) // OpeANS
	cTagMsg += SIPMontaXML("operadoraParaANS",,,,,,8,.F.,.T.,,,,.T.) // OpeANS
	cTagMsg += SIPMontaXML("mensagem",,,,,,4,.F.,.T.,,,,.T.) //Mensagem

	If isXMLOnFile
		InsInXMLTemp(cTagMsg,.F.)
		cTagMsg	:= ""
	EndIf

Return cTagMsg
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TEpilogo

Escreve o epilogo do arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TEpilogo()
	Local	cTag := ""

	cTag += SIPMontaXML("epilogo",,,,,,4,.T.,.F.,,,,.F.)
	cTag += SIPMontaXML("hash",GetXmlEpilogo(),,,,,4,.T.,.T.,,,.T.,.F.)
	cTag += SIPMontaXML("epilogo",,,,,,4,.F.,.T.,,,,.F.)

Return cTag
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QueryExpostos

Monta a area de trabalho com os dados dos beneficiarios expostos

@param cTipPla		Tipo de contratacao do plano
@param cItem		Item assistencial

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function QueryExpostos(cTipPla, cItem)
	Local cSql	:=	""

	//Recupero os beneficiแrios por Tipo de contrato, segmenta็ใo e classifica็ใo
	cSql	+=	"Select B3M_FORCON,B3M_ITEM,MAX(B3M_QTDBEN) B3M_QTDBEN"
	cSql	+=	"From   " + RetSqlName("B3M")
	cSql	+=	"	Where		"+RetSqlName("B3M")+".D_E_L_E_T_ = ' ' "
	cSql	+=	"	AND B3M_FILIAL = '" + xFilial("B3M") + "' "
	cSql	+=	"	AND B3M_TRIREC = '" + cPerData + "' "
	cSql	+=	"	AND B3M_FORCON = '" + cTipPla + "' "
	cSql	+=	"	AND B3M_ITEM = '" + cItem + "' "
	cSql	+=	"	AND ( B3M_QTDEVE > 0 OR B3M_VLRTOT > 0 OR B3M_QTDBEN > 0 ) "//Se tiver frequencia OU despesa ou expostos ja considero
	cSql	+=	" GROUP BY B3M_FORCON,B3M_ITEM,B3M_SEGMEN "
	cSql	+=	" ORDER BY B3M_QTDBEN DESC "
	cSql := ChangeQuery(cSql)

	If MV_PLCENDB
		PlsLogFil(CENDTHRL("I") + "QueryExpostos: " + cSql,ARQ_LOG)
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbExpo",.F.,.T.)

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QueryUF

Monta a area de trabalho com os dados por UF

@param cTipPla		Tipo de contratacao do plano
@param cItem		Item assistencial

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function QueryUF(cTipPla)
	Local cSql	:=	""
	Local lRet	:= .T.
	//Recupero os registros da tabela sintetica por Tipo de contrato, segmenta็ใo e classifica็ใo
	cSql	+=	"Select DISTINCT B3M_FORCON,B3M_UF,B3M_TRIOCO "
	cSql	+=	"From   " + RetSqlName("B3M")
	cSql	+=	"	Where		"+RetSqlName("B3M")+".D_E_L_E_T_ = ' ' "
	cSql	+=	"	AND B3M_UF <> 'FC' "
	cSql	+=	"	AND B3M_UF <> 'ZZ' "
	cSql	+=	"	AND B3M_FILIAL = '" + xFilial("B3M") + "' "
	cSql	+=	"	AND B3M_TRIREC = '" + cPerData + "' "
	cSql	+=	"	AND B3M_FORCON = '" + cTipPla + "' "
	cSql	+=	"	AND ( B3M_QTDEVE > 0 OR B3M_VLRTOT > 0 OR B3M_QTDBEN > 0 ) "//Se tiver frequencia OU despesa ou expostos ja considero
	cSql	+=	" ORDER BY B3M_UF, B3M_TRIOCO, B3M_FORCON "

	cSql := ChangeQuery(cSql)

	If MV_PLCENDB
		PlsLogFil(CENDTHRL("I") + "QueryUF: " + cSql,ARQ_LOG)
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbUF",.F.,.T.)

	lRet := !TrbUF->(Eof())
Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QueryEventos

Monta a area de trabalho com os dados das despeas

@param cTipPla		Tipo de contratacao do plano
@param cUF			Unidade federativa / estado
@param cItem		Item assistencial

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function QueryEventos(cTipPla,cUF,cItem)
	Local cSql	:=	""
	//Recupero os registros da tabela sintetica por Tipo de contrato, segmenta็ใo e classifica็ใo
	cSql	+=	"Select B3M_FORCON,B3M_UF,B3M_ITEM,B3M_VLRTOT,B3M_QTDEVE,B3M_TRIOCO "
	cSql	+=	"From   " + RetSqlName("B3M")
	cSql	+=	"	Where		"+RetSqlName("B3M")+".D_E_L_E_T_ = ' ' "
	cSql	+=	"	AND B3M_UF <> 'FC' "
	cSql	+=	"	AND B3M_UF <> 'ZZ' "
	cSql	+=	"	AND B3M_FILIAL = '" + xFilial("B3M") + "' "
	cSql	+=	"	AND B3M_TRIREC = '" + cPerData + "' "
	cSql	+=	"	AND B3M_TRIOCO = '" + cDtOcorren + "' "
	cSql	+=	"	AND B3M_FORCON = '" + cTipPla + "' "
	cSql	+=	"	AND B3M_UF = '" + cUF + "' "
	cSql	+=	"	AND B3M_ITEM = '" + cItem + "' "
	cSql	+=	"	AND (B3M_QTDEVE > 0 OR B3M_VLRTOT > 0) "//Se tiver frequencia OU despesa ja considero
	cSql	+=	" ORDER BY B3M_FORCON,B3M_UF "
	cSql := ChangeQuery(cSql)

	If MV_PLCENDB
		PlsLogFil(CENDTHRL("I") + "QueryEventos: " + cSql,ARQ_LOG)
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbEve",.F.,.T.)
Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TFormaContratacao

Monta as tags por forma de contratacao

@param nIdent		Tamanho do deslocamento

@return cTag		Conteudo da Tag que ira para o arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TFormaContratacao(nIdent,cCodOpe)
	Local nForCont	:= 0
	Local cTag		:=	""
	Local aForCon	:= {}
	Local oObj      := FWSX1Util():New()
	Local aPergunte :={}
	Local lPerg     := .F.
	Local  lMV_PLQDOBS := GetNewPar("MV_PLQDOBS",.T.)
	Default cCodOpe	:= ""

	oObj:AddGroup("PLSSIPXML")
	oObj:SearchGroup()
	aPergunte := oObj:GetGroup("PLSSIPXML")

	If len(aPergunte)>1
		lPerg:=len(aPergunte[2])>1
	endif

	aForCon := GetFormaContratacao(cCodOpe)

	For nForCont := 1 to Len(aForCon)	//Trazer apenas
		If aForCon[nForCont,1] == '1'
			cContTag		:= "individualFamiliar"
		ElseIf aForCon[nForCont,1] == '2'
			cContTag		:= "coletivoEmpresarial"
		ElseIf aForCon[nForCont,1] == '3'
			cContTag		:= "coletivoAdesao"
		EndIf

		IncProc("Carregando dados da tag " + cContTag)
		ProcessMessage()

		cTag += SIPMontaXML(cContTag,,,,,,nIdent,.T.,.F.,,,,.T.)
		cTag += SIPMontaXML("segmentacao",,,,,,nIdent+4,.T.,.F.,,,,.T.)

		cTipPla := aForCon[nForCont,1]
		cSegEmAnalise	:=	""//'1=Ambulatorial;2=Hospitalar;3=Hospitalar obstetrico;4=Odontologico'

		If (!lPerg .OR. MV_PAR02 == 1) .OR. (MV_PAR02 == 2 .And. VerSeg(cTipPla,'A'))

			cSegEmAnalise		:= D_AMD
			IncProc("Carregando dados do segmento " + cSegEmAnalise)
			ProcessMessage()
			cTag += TagAmbulatorial(nIdent+8,cTipPla)
			ChkXMLSize(@cTag)
		endif
		If lMV_PLQDOBS
			If (!lPerg .OR. MV_PAR02 == 1)  .OR. (MV_PAR02 == 2 .And. VerSeg(cTipPla,'B'))

				cSegEmAnalise		:= D_OBS
				IncProc("Carregando dados do segmento " + cSegEmAnalise)
				ProcessMessage()
				cTag += TagObsHospitalar(nIdent+8,cTipPla)
				ChkXMLSize(@cTag)
			EndIf
		Else
			If (!lPerg .OR. MV_PAR02 == 1)  .OR. (MV_PAR02 == 2 .And. VerSeg(cTipPla,'B'))

				cSegEmAnalise		:= D_HOS
				IncProc("Carregando dados do segmento " + cSegEmAnalise)
				ProcessMessage()
				cTag += TagHospitalar(nIdent+8,cTipPla)
				ChkXMLSize(@cTag)
			endif
		EndIf

		If (!lPerg .OR. MV_PAR02 == 1)  .OR. (MV_PAR02 == 2 .And. VerSeg(cTipPla,'I'))

			cSegEmAnalise		:= D_ODO
			IncProc("Carregando dados do segmento " + cSegEmAnalise)
			ProcessMessage()
			cTag += TagOdontologico(nIdent+8,cTipPla)
		ENDIF

		cTag += SIPMontaXML("segmentacao",,,,,,nIdent+4,.F.,.T.,,,,.T.)
		cTag += SIPMontaXML(cContTag,,,,,,nIdent,.F.,.T.,,,,.T.)

		ChkXMLSize(@cTag)

	Next nForCon

Return cTag
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TagAmbulatorial

Monta e retorna a tag ambulatorial

@param nIdent		Tamanho do deslocamento
@param cTipPla		Tipo de contratacao do plano

@return cTag		Conteudo da Tag que ira para o arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TagAmbulatorial(nIdent,cTipPla)
	Local cTag		:=	""

	If QueryUF(cTipPla)
		cTag += SIPMontaXML("ambulatorial",,,,,,nIdent,.T.,.F.,,,,.T.)

		Do While !TrbUF->(Eof()) .and. TrbUF->(B3M_FORCON) == cTipPla
			cTag += SIPMontaXML("quadro",,,,,,nIdent+4,.T.,.F.,,,,.T.)
			cDtOcorren := Alltrim(TrbUF->B3M_TRIOCO)
			//Cabecalho
			cTag += TagDataTrimestreOcorrencia(cDtOcorren,TrbUF->B3M_UF)

			//ItenConsultas Medicas
			cTag += TItensConsultasMedicas(nIdent+8)

			//ItensOutrosAtendAmbu
			cTag += TItensOutrosAtendAmbu(nIdent+8)

			//ItensExames
			cTag += TItensExames(nIdent+8)

			//ItensTerapias
			cTag += TItensTerapias(nIdent+8)

			//ItensDemDespMedHosp
			cTag += 	TItensDemDespMedHosp(nIdent+8)
			cTag += SIPMontaXML("quadro",,,,,,nIdent+4,.F.,.T.,,,,.T.)
			cDtOcorren := ""

			TrbUF->(DbSkip())
		EndDo

		cTag += SIPMontaXML("ambulatorial",,,,,,nIdent+4,.F.,.T.,,,,.T.)
	EndIf
	TrbUF->(Dbclosearea())

Return cTag
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TagHospitalar

Monta e retorna a tag hospitalar

@param nIdent		Tamanho do deslocamento
@param cTipPla		Tipo de contratacao do plano

@return cTag		Conteudo da Tag que ira para o arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TagHospitalar(nIdent,cTipPla)
	Local cTag	:=	""

	//A tag hospitalar obstreticia contem todos os iten do hospitalar + obstrtecia.
	cTag	:=	TagObsHospitalar(nIdent,cTipPla)

Return cTag
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TagObsHospitalar

Monta e retorna a tag observacao hospitalar

@param nIdent		Tamanho do deslocamento
@param cTipPla		Tipo de contratacao do plano

@return cTag		Conteudo da Tag que ira para o arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TagObsHospitalar(nIdent,cTipPla)
	Local cTag	:=	""

	If QueryUF(cTipPla)

		cTag += SIPMontaXML(cSegEmAnalise,,,,,,nIdent,.T.,.F.,,,,.T.)

		Do While !TrbUF->(Eof()) .AND.TrbUF->(B3M_FORCON) == cTipPla

			cDtOcorren := Alltrim(TrbUF->B3M_TRIOCO)

			cTag += SIPMontaXML("quadro",,,,,,nIdent+4,.T.,.F.,,,,.T.)
			//Cabecalho
			cTag += TagDataTrimestreOcorrencia(cDtOcorren,TrbUF->B3M_UF)

			//ct_quadroHospInternacoes
			cTag += TCtQuadroHospInternacoes(nIdent+8)

			cTag += TInterObstetricas(nIdent+8)
			//parto
			If cSegEmAnalise == D_OBS
				cTag += TParto(nIdent+8)
			EndIf

			cTag += TCausaInterna(nIdent+8)
			//nascidoVivo
			If cSegEmAnalise == D_OBS
				cTag +=	TNascidoVivo(nIdent+8)
			EndIf

			cTag += TDemDespMedHosp(nIdent+8)

			cTag += SIPMontaXML("quadro",,,,,,nIdent+4,.F.,.T.,,,,.T.)
			cDtOcorren := ""
			TrbUF->(dbSkip())

		EndDo

		cTag += SIPMontaXML(cSegEmAnalise,,,,,,nIdent+4,.F.,.T.,,,,.T.)

	EndIf

	TrbUF->(Dbclosearea())

Return cTag
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TagOdontologico

Monta e retorna a tag odontologico

@param nIdent		Tamanho do deslocamento
@param cTipPla		Tipo de contratacao do plano

@return cTag		Conteudo da Tag que ira para o arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TagOdontologico(nIdent,cTipPla)
	Local cTag		:=	""

	If QueryUF(cTipPla)
		cTag += SIPMontaXML("odontologico",,,,,,nIdent,.T.,.F.,,,,.T.)

		Do While !TrbUF->(Eof()) .AND.TrbUF->(B3M_FORCON) == cTipPla
			cDtOcorren := Alltrim(TrbUF->B3M_TRIOCO)
			cTag += SIPMontaXML("quadro",,,,,,nIdent+4,.T.,.F.,,,,.T.)

			//Cabecalho
			cTag += TagDataTrimestreOcorrencia(cDtOcorren,TrbUF->B3M_UF)

			//procOdonto
			cTag += TagProcOdonto(nIdent+8)

			cTag += SIPMontaXML("quadro",,,,,,nIdent+4,.F.,.T.,,,,.T.)
			TrbUF->(dbSkip())
		EndDo
		cTag += SIPMontaXML("odontologico",,,,,,nIdent+4,.F.,.T.,,,,.T.)
	EndIf
	TrbUF->(Dbclosearea())
Return cTag
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TagDataTrimestreOcorrencia

Monta e retorna a tag trimestre de ocorrencia

@param cAnoMes		Trimestre de ocorrencia
@param cUF			Unidade federativa / estado

@return cTag		Conteudo da Tag que ira para o arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TagDataTrimestreOcorrencia(cAnoMes,cUf)
	Local cTag		:=	""
	Local cMes		:=	"10"

	cTag += SIPMontaXML("dataTrimestreOcorrencia",,,,,,36,.T.,.F.,,,,.T.)  // data trimestre de ocorrencia

	If Substr(cAnoMes,5,2)=='01'
		cMes := "01"
	ElseIF Substr(cAnoMes,5,2)=='02'
		cMes := "04"
	ElseIf Substr(cAnoMes,5,2)=='03'
		cMes := "07"
	EndIf

	cTag += SIPMontaXML("dia","01",,,,,40,.T.,.T.,,,,.T.)
	cTag += SIPMontaXML("mes",cMes,,,,,40,.T.,.T.,,,,.T.)
	cTag += SIPMontaXML("ano",Substr(cAnoMes,1,4),,,,,40,.T.,.T.,,,,.T.)
	cTag += SIPMontaXML("dataTrimestreOcorrencia",,,,,,36,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("uf",cUf,,,,,36,.T.,.T.,,,,.T.)

Return cTag
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TItensConsultasMedicas

Monta e retorna a tag itens consultas medicas

@param nIdent		Tamanho do deslocamento

@return cTag		Conteudo da Tag que ira para o arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TItensConsultasMedicas(nIdent)
	Local cTag			:=	""

	cTag += SIPMontaXML("itensConsultasMedicas",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += SIPMontaXML("consultasMedicas",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	//Monta o Totalizador
	cTag += GetTagEvento("",{D_EVENT,D_BENEF,D_DESPE},nIdent+8,"A")

	cTag += TagMedicasAmbConsulta(nIdent+12)

	cTag += TagMedProntSocConsulta(nIdent+12)

	cTag += SIPMontaXML("consultasMedicas",,,,,,nIdent+4,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("itensConsultasMedicas",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TagMedicasAmbConsulta

Monta e retorna a tag itens consultas medicas ambulatoriais

@param nIdent		Tamanho do deslocamento

@return cTag		Conteudo da Tag que ira para o arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TagMedicasAmbConsulta(nIdent)
	Local cTag	:=	""
	Local aCons	:= {}
	Local nCons	:= 0

	aAdd(aCons,{"alergiaImunologia"			,"A11"})
	aAdd(aCons,{"angiologia" 				,"A12"})
	aAdd(aCons,{"cardiologia" 			  	,"A13"})
	aAdd(aCons,{"cirurgiaGeral" 				,"A14"})
	aAdd(aCons,{"clinicaMedica" 				,"A15"})
	aAdd(aCons,{"dermatologia" 				,"A16"})
	aAdd(aCons,{"endocrinologia" 		  	,"A17"})
	aAdd(aCons,{"gastroenterologia" 	  		,"A18"})
	aAdd(aCons,{"geriatria" 					,"A19"})
	aAdd(aCons,{"ginecologiaObstetricia" 	,"A110"})
	aAdd(aCons,{"hematologia" 				,"A111"})
	aAdd(aCons,{"mastologia" 				,"A112"})
	aAdd(aCons,{"nefrologia" 				,"A113"})
	aAdd(aCons,{"neurocirurgia" 				,"A114"})
	aAdd(aCons,{"neurologia" 				,"A115"})
	aAdd(aCons,{"oftalmologia" 				,"A116"})
	aAdd(aCons,{"oncologia" 					,"A117"})
	aAdd(aCons,{"otorrinolaringologia"		,"A118"})
	aAdd(aCons,{"pediatria" 					,"A119"})
	aAdd(aCons,{"proctologia" 			  	,"A120"})
	aAdd(aCons,{"psiquiatria" 			  	,"A121"})
	aAdd(aCons,{"reumatologia" 				,"A122"})
	aAdd(aCons,{"tisiopneumologia" 			,"A123"})
	aAdd(aCons,{"traumatologiaOrtopedica"	,"A124"})
	aAdd(aCons,{"urologia" 				  	,"A125"})

	cTag += SIPMontaXML("consultasMedicasAmb",,,,,,nIdent,.T.,.F.,,,,.T.)
	//Totais
	cTag += GetTagEvento("",{D_EVENT,D_BENEF,D_DESPE},nIdent+4,"A1")

	For nCons := 1 TO Len(aCons)
		//Especialidades
		cTag += SIPMontaXML(aCons[nCons,1],,,,,,nIdent,.T.,.F.,,,,.T.)
		//Eventos
		cTag += GetTagEvento("",{D_EVENT},nIdent+4,aCons[nCons,2])

		cTag += SIPMontaXML(aCons[nCons,1],,,,,,nIdent,.F.,.T.,,,,.T.)

	Next nCons

	cTag += SIPMontaXML("consultasMedicasAmb",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TagMedProntSocConsulta

Monta e retorna a tag itens consultas medicas me pronto socorro

@param nIdent		Tamanho do deslocamento

@return cTag		Conteudo da Tag que ira para o arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TagMedProntSocConsulta(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("consultaMedProntSoc",,,,,,nIdent,.T.,.F.,,,,.T.)
	//Totais
	cTag += GetTagEvento("",{D_EVENT,D_BENEF,D_DESPE},nIdent+4,"A2")

	cTag += SIPMontaXML("consultaMedProntSoc",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TItensOutrosAtendAmbu

Monta e retorna a tag outros atendimentos ambulatoriais

@param nIdent		Tamanho do deslocamento

@return cTag		Conteudo da Tag que ira para o arquivo

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TItensOutrosAtendAmbu(nIdent)
	Local cTag	:=	""
	Local aOutro:= {}
	Local nOutro:= 0

	aAdd(aOutro,{"consultaSessaoFisio","B1"})
	aAdd(aOutro,{"consultaSessaoFono","B2"})
	aAdd(aOutro,{"consultaSessaoNutri","B3"})
	aAdd(aOutro,{"consultaSessaoTerap","B4"})
	aAdd(aOutro,{"consultaSessaoPsico","B5"})

	cTag += SIPMontaXML("itensOutrosAtendAmbu",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += SIPMontaXML("outrosAtendAmb",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	//Monta o Totalizador
	cTag += GetTagEvento("",{D_EVENT,D_BENEF,D_DESPE},nIdent+8,"B")

	For nOutro := 1 TO Len(aOutro)
		//Especialidades
		cTag += SIPMontaXML(aOutro[nOutro,1],,,,,,nIdent,.T.,.F.,,,,.T.)
		//Eventos
		cTag += GetTagEvento("",{D_EVENT},nIdent+4,aOutro[nOutro,2])

		cTag += SIPMontaXML(aOutro[nOutro,1],,,,,,nIdent,.F.,.T.,,,,.T.)

	Next nOutro

	cTag += SIPMontaXML("outrosAtendAmb",,,,,,nIdent+4,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("itensOutrosAtendAmbu",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TItensExames(nIdent)
	Local cTag	:=	""
	Local aExame:= {}
	Local nExame:= 0

	aAdd(aExame,{"ressonanciaMagnet" 	,"C1",{D_EVENT},.F.})
	aAdd(aExame,{"tomografiaComputa"	,"C2",{D_EVENT},.F.})
	aAdd(aExame,{"procedDiagnCitopat"	,"C3",{D_EVENT,D_BENEF},.F.})
	aAdd(aExame,{"densitometriaOssea"	,"C4",{D_EVENT},.F.})
	aAdd(aExame,{"ecodopplerTranstora"	,"C5",{D_EVENT},.F.})
	aAdd(aExame,{"broncoscopiabiopsia"	,"C6",{D_EVENT},.F.})
	aAdd(aExame,{"endoscopiaDigestiva"	,"C7",{D_EVENT},.F.})
	aAdd(aExame,{"colonoscopia"			,"C8",{D_EVENT},.F.})
	aAdd(aExame,{"holter24h"			,"C9",{D_EVENT},.F.})
	aAdd(aExame,{"mamografiaConvDig"	,"C10",{D_EVENT},.T.})
	//aAdd(aExame,{"mamografia50a69"		,"C101",{D_EVENT,D_BENEF},.F.})
	aAdd(aExame,{"cintilografiaMiocard"	,"C11",{D_EVENT},.F.})
	aAdd(aExame,{"cintilografiaRenal"	,"C12",{D_EVENT},.F.})
	aAdd(aExame,{"hemoglobinaGlicada"	,"C13",{D_EVENT},.F.})
	aAdd(aExame,{"pesqSangueOculto"		,"C14",{D_EVENT,D_BENEF},.F.})
	aAdd(aExame,{"radiografia"			,"C15",{D_EVENT},.F.})
	aAdd(aExame,{"testeErgometrico"		,"C16",{D_EVENT},.F.})
	aAdd(aExame,{"ultraSonAbdoTotal"	,"C17",{D_EVENT},.F.})
	aAdd(aExame,{"ultraSonAbdoInfer"	,"C18",{D_EVENT},.F.})
	aAdd(aExame,{"ultraSonAbdoSuper"	,"C19",{D_EVENT},.F.})
	aAdd(aExame,{"ultraSonObstMorfo"	,"C20",{D_EVENT},.F.})

	cTag += SIPMontaXML("itensExames",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += SIPMontaXML("exames",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	//Monta o Totalizador
	cTag += GetTagEvento("",{D_EVENT,D_BENEF,D_DESPE},nIdent+8,"C")

	For nExame := 1 TO Len(aExame)

		//Especialidades
		cTag += SIPMontaXML(aExame[nExame,1],,,,,,nIdent,.T.,.F.,,,,.T.)
		//Eventos
		cTag += GetTagEvento("",aExame[nExame,3],nIdent+4,aExame[nExame,2])

		If aExame[nExame,4]

			//Especialidades
			cTag += SIPMontaXML("mamografia50a69",,,,,,nIdent,.T.,.F.,,,,.T.)
			//Eventos
			cTag += GetTagEvento("",{D_EVENT,D_BENEF},nIdent+4,"C101")

			cTag += SIPMontaXML("mamografia50a69",,,,,,nIdent,.F.,.T.,,,,.T.)

		EndIf

		cTag += SIPMontaXML(aExame[nExame,1],,,,,,nIdent,.F.,.T.,,,,.T.)

	Next nExame

	cTag += SIPMontaXML("exames",,,,,,nIdent+4,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("itensExames",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TItensTerapias(nIdent)
	Local cTag	:=	""
	Local aTera	:= {}
	Local nTera	:= 0

	aAdd(aTera,{"transfusaoAmbulatorial" 	,"D1"})
	aAdd(aTera,{"quimioSistemica" 			,"D2"})
	aAdd(aTera,{"radioterapiaMegavolt" 		,"D3"})
	aAdd(aTera,{"hemodialiseAguda" 			,"D4"})
	aAdd(aTera,{"hemodialiseCronica" 		,"D5"})
	aAdd(aTera,{"implanteDispIntrauterino"	,"D6"})

	cTag += SIPMontaXML("itensTerapias",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += SIPMontaXML("terapias",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	//Monta o Totalizador
	cTag += GetTagEvento("",{D_EVENT,D_BENEF,D_DESPE},nIdent+8,"D")

	For nTera := 1 TO Len(aTera)
		//Especialidades
		cTag += SIPMontaXML(aTera[nTera,1],,,,,,nIdent,.T.,.F.,,,,.T.)
		//Eventos
		cTag += GetTagEvento("",{D_EVENT},nIdent+4,aTera[nTera,2])

		cTag += SIPMontaXML(aTera[nTera,1],,,,,,nIdent,.F.,.T.,,,,.T.)

	Next nTera

	cTag += SIPMontaXML("terapias",,,,,,nIdent+4,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("itensTerapias",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TItensDemDespMedHosp(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("itensDemDespMedHosp",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += SIPMontaXML("demaisDespMedHosp",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_DESPE},nIdent+4,"H")
	cTag += SIPMontaXML("demaisDespMedHosp",,,,,,nIdent,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("itensDemDespMedHosp",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TCtQuadroHospInternacoes(nIdent)
	Local cTag			:=	""
	Local cTagQuadro  :=	"ct_quadroHospInternacoes"

	If cSegEmAnalise == D_OBS
		cTagQuadro	:=	"ct_quadroHospObstInternacoes"
	EndIf

	cTag += SIPMontaXML(cTagQuadro,,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += SIPMontaXML("internacoes",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	//Monta o Totalizador
	cTag += GetTagEvento("",{D_EVENT,D_BENEF,D_DESPE},nIdent+8,"E")

	cTag += TTipoInternacao(nIdent+12)

	cTag += SIPMontaXML("internacoes",,,,,,nIdent+4,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML(cTagQuadro,,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TTipoInternacao(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("tipoInternacao",,,,,,nIdent,.T.,.F.,,,,.T.)

	cTag += GetTagEvento("",{D_EVENT},nIdent+8,"E1")//Totalizando tipoInternaxao
	//Clinica
	cTag += TClinica(nIdent+8)
	//Cirurgica
	cTag += TCirurgica(nIdent+8)
	//Pediatrica
	cTag += TPediatrica(nIdent+8)
	//Psiquiatrica
	//cTag += GetTagEvento("psiquiatrica" 	,{D_EVENT},nIdent+8	,"E15")
	cTag += TPsiquiatrica(nIdent+8)
	//Regime de internacao
	cTag += TRegimeInterncao(nIdent+8)

	cTag += SIPMontaXML("tipoInternacao",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TClinica(nIdent)
	Local cTag	:= ""

	cTag += SIPMontaXML("clinica",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent	,"E11")
	cTag += SIPMontaXML("clinica",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TPsiquiatrica(nIdent)
	Local cTag	:= ""

	cTag += SIPMontaXML("psiquiatrica",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent	,"E15")
	cTag += SIPMontaXML("psiquiatrica",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TCirurgica(nIdent)
	Local cTag	:=	""
	Local aCirur:= {}
	Local nCirur:=0

	aAdd(aCirur,{"cirurgiaBariatrica" 	,"E121",{D_EVENT}})
	aAdd(aCirur,{"laqueaduraTubaria"	,"E122",{D_EVENT}})
	aAdd(aCirur,{"vasectomia" 			,"E123",{D_EVENT}})
	aAdd(aCirur,{"fraturaFemur60" 		,"E124",{D_EVENT,D_BENEF}})
	aAdd(aCirur,{"revisaoArtroplastia" 	,"E125",{D_EVENT}})
	aAdd(aCirur,{"implanteCdi" 			,"E126",{D_EVENT}})
	aAdd(aCirur,{"implantacaoMarcap" 	,"E127",{D_EVENT}})

	cTag += SIPMontaXML("cirurgica",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+4	,"E12")//cirurgica

	For nCirur := 1 TO Len(aCirur)
		//Cirurgicas
		cTag += SIPMontaXML(aCirur[nCirur,1],,,,,,nIdent,.T.,.F.,,,,.T.)
		//Eventos
		cTag += GetTagEvento("",aCirur[nCirur,3],nIdent+4,aCirur[nCirur,2])

		cTag += SIPMontaXML(aCirur[nCirur,1],,,,,,nIdent,.F.,.T.,,,,.T.)

	Next nCirur

	cTag += SIPMontaXML("cirurgica",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TPediatrica(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("pediatrica",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("" 	,{D_EVENT},nIdent+4	,"E14")//Pediatrica

	cTag += SIPMontaXML("internacaoRespira",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF},nIdent+8,"E141")//
	cTag += SIPMontaXML("internacaoRespira",,,,,,nIdent+4,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("internacaoUtiNeo",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento(""	,{D_EVENT},nIdent+4,"E142")//internacaoUtiNeo

	cTag += SIPMontaXML("internacoesUtiNeo48",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento(""	,{D_EVENT},nIdent+4,"E1421")
	cTag += SIPMontaXML("internacoesUtiNeo48",,,,,,nIdent,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("internacaoUtiNeo",,,,,,nIdent+4,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("pediatrica",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TRegimeInterncao(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("regimeInternacao",,,,,,nIdent,.T.,.F.,,,,.T.)

	cTag += GetTagEvento("",{D_EVENT},nIdent	,"E2")//regimeInternacao
	//Hospitalar
	cTag += SIPMontaXML("hospitalar",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF},nIdent+8,"E21")//
	cTag += SIPMontaXML("hospitalar",,,,,,nIdent+4,.F.,.T.,,,,.T.)

	//Hospital Dia
	cTag += SIPMontaXML("hospitalDia",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF},nIdent+4	,"E22")
	//Saude mental
	cTag += SIPMontaXML("hospitalSaudeMental",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+8,"E221")
	cTag += SIPMontaXML("hospitalSaudeMental",,,,,,nIdent+4,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("hospitalDia",,,,,,nIdent+4,.F.,.T.,,,,.T.)

	//Domiciliar
	cTag += SIPMontaXML("domiciliar",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF},nIdent+8,"E23")//
	cTag += SIPMontaXML("domiciliar",,,,,,nIdent+4,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("regimeInternacao",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TInterObstetricas(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("interObstetricas",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += SIPMontaXML("obstetrica",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("" 	,{D_EVENT},nIdent+8	,"E13")
	cTag += SIPMontaXML("obstetrica",,,,,,nIdent,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("interObstetricas",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TParto(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("parto",,,,,,nIdent,.T.,.F.,,,,.T.)
	//partoNormal
	cTag += SIPMontaXML("partoNormal",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+4	,"E131")
	cTag += SIPMontaXML("partoNormal",,,,,,nIdent,.F.,.T.,,,,.T.)
	//partoCesareo
	cTag += SIPMontaXML("partoCesareo",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+4	,"E132")
	cTag += SIPMontaXML("partoCesareo",,,,,,nIdent,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("parto",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TCausaInterna(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("causaInterna",,,,,,nIdent,.T.,.F.,,,,.T.)

	cTag += TNeoplasias(nIdent)
	cTag += TDiabetesMellitus(nIdent)
	cTag += TDAparelhoCirc(nIdent)
	cTag += TDoeAparResp(nIdent)
	cTag += TCausasExternas(nIdent)

	cTag += SIPMontaXML("causaInterna",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TNeoplasias(nIdent)
	Local cTag	:= ""
	Default nIdent	:= 0

	//Neoplasias
	cTag += SIPMontaXML("neoplasias",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("" 	,{D_EVENT},nIdent+8	,"F1")//neoplasias

	//cancerMamaFem
	cTag += SIPMontaXML("cancerMamaFem",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("" 	,{D_EVENT},nIdent+8	,"F11")//cancerMamaFem
	cTag += SIPMontaXML("tratCirurgCancerMam",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+8	,"F111")
	cTag += SIPMontaXML("tratCirurgCancerMam",,,,,,nIdent+4,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("cancerMamaFem",,,,,,nIdent+4,.F.,.T.,,,,.T.)

	//cancerColoUtero
	cTag += SIPMontaXML("cancerColoUtero",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("" 	,{D_EVENT},nIdent+8	,"F12")//cancerColoUtero
	cTag += SIPMontaXML("tratCirurgCancerColo",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+8	,"F121")
	cTag += SIPMontaXML("tratCirurgCancerColo",,,,,,nIdent+4,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("cancerColoUtero",,,,,,nIdent+4,.F.,.T.,,,,.T.)

	//cancerColonReto
	cTag += SIPMontaXML("cancerColonReto",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("" 	,{D_EVENT},nIdent+8	,"F13")//cancerColonReto
	cTag += SIPMontaXML("tratCirurgCancerColoReto",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+8	,"F131")
	cTag += SIPMontaXML("tratCirurgCancerColoReto",,,,,,nIdent+4,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("cancerColonReto",,,,,,nIdent+4,.F.,.T.,,,,.T.)

	//cancerProstata
	cTag += SIPMontaXML("cancerProstata",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("" 	,{D_EVENT},nIdent+8	,"F14")//cancerProstata
	cTag += SIPMontaXML("tratCirurgCancerProst",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+8	,"F141")
	cTag += SIPMontaXML("tratCirurgCancerProst",,,,,,nIdent+4,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("cancerProstata",,,,,,nIdent+4,.F.,.T.,,,,.T.)

	//neoplasias
	cTag += SIPMontaXML("neoplasias",,,,,,nIdent+4,.F.,.T.,,,,.T.)

Return cTag

Static Function TDAparelhoCirc(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("doencasAparelhoCirc",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+4	,"F3")

	cTag += SIPMontaXML("infartoAgudoMiocardio",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+4	,"F31")
	cTag += SIPMontaXML("infartoAgudoMiocardio",,,,,,nIdent,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("doencasHipertensivas",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+4	,"F32")
	cTag += SIPMontaXML("doencasHipertensivas",,,,,,nIdent,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("insuficienciaCardCong",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+4	,"F33")
	cTag += SIPMontaXML("insuficienciaCardCong",,,,,,nIdent,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("doencasCerebrovasc",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+4	,"F34")

	cTag += SIPMontaXML("acidenteVascularCere",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+4	,"F341")
	cTag += SIPMontaXML("acidenteVascularCere",,,,,,nIdent,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("doencasCerebrovasc",,,,,,nIdent,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("doencasAparelhoCirc",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TDoeAparResp(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("doencasAparelhoResp",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+4	,"F4")
	cTag += SIPMontaXML("doencaPulmoObstrCron",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+4	,"F41")
	cTag += SIPMontaXML("doencaPulmoObstrCron",,,,,,nIdent,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("doencasAparelhoResp",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TNascidoVivo(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("nascidoVivo",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += SIPMontaXML("nascidoVivo",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+4	,"G")
	cTag += SIPMontaXML("nascidoVivo",,,,,,nIdent,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("nascidoVivo",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TCausasExternas(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("causasExternas",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+4	,"F5")
	cTag += SIPMontaXML("causasExternas",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TDiabetesMellitus(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("diabetesMellitus",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+4	,"F2")
	cTag += SIPMontaXML("diabetesMellitus",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TDemDespMedHosp(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("demDespMedHosp",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += SIPMontaXML("demaisDespMedHosp",,,,,,nIdent,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_DESPE},nIdent+4	,"OO")
	cTag += SIPMontaXML("demaisDespMedHosp",,,,,,nIdent,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("demDespMedHosp",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function TagProcOdonto(nIdent)
	Local cTag	:=	""

	cTag += SIPMontaXML("procOdonto",,,,,,nIdent,.T.,.F.,,,,.T.)
	//Totais
	cTag += SIPMontaXML("procedimentosOdonto",,,,,,nIdent+4,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF,D_DESPE},nIdent+8,"I")//procedimentosOdonto

	cTag += SIPMontaXML("consultasOdontoInic",,,,,,nIdent+8,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF,D_DESPE},nIdent+12,"I1")	//Monta o Totalizador
	cTag += SIPMontaXML("consultasOdontoInic",,,,,,nIdent+8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("examesRadiograficos",,,,,,nIdent+8,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF},nIdent+12,"I2")	//Monta o Totalizador
	cTag += SIPMontaXML("examesRadiograficos",,,,,,nIdent+8,.F.,.T.,,,,.T.)
	//procedimentosPrevent
	cTag += SIPMontaXML("procedimentosPrevent",,,,,,nIdent+8,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF,D_DESPE},nIdent+8,"I3")//procedimentosPrevent

	cTag += SIPMontaXML("atividadeEduIndividual",,,,,,nIdent+8,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+12,"I31")	//Monta o Totalizador
	cTag += SIPMontaXML("atividadeEduIndividual",,,,,,nIdent+8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("aplicTopProfFluorHemi",,,,,,nIdent+8,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT},nIdent+12,"I32")	//Monta o Totalizador
	cTag += SIPMontaXML("aplicTopProfFluorHemi",,,,,,nIdent+8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("selanteElemDentario",,,,,,nIdent+8,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF},nIdent+12,"I33")	//Monta o Totalizador
	cTag += SIPMontaXML("selanteElemDentario",,,,,,nIdent+8,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("procedimentosPrevent",,,,,,nIdent+8,.F.,.T.,,,,.T.)
	//procedimentosPrevent
	cTag += SIPMontaXML("raspSupraGengHemi",,,,,,nIdent+8,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF},nIdent+12,"I4")	//Monta o Totalizador
	cTag += SIPMontaXML("raspSupraGengHemi",,,,,,nIdent+8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("restauraDenteDeciduo",,,,,,nIdent+8,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF},nIdent+12,"I5")	//Monta o Totalizador
	cTag += SIPMontaXML("restauraDenteDeciduo",,,,,,nIdent+8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("restauraDentePerma",,,,,,nIdent+8,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF},nIdent+12,"I6")	//Monta o Totalizador
	cTag += SIPMontaXML("restauraDentePerma",,,,,,nIdent+8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("exodontiasSimplesPer",,,,,,nIdent+8,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF,D_DESPE},nIdent+12,"I7")	//Monta o Totalizador
	cTag += SIPMontaXML("exodontiasSimplesPer",,,,,,nIdent+8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("trataEndoConclDentesD",,,,,,nIdent+8,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF},nIdent+12,"I8")	//Monta o Totalizador
	cTag += SIPMontaXML("trataEndoConclDentesD",,,,,,nIdent+8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("trataEndoConclDentesP",,,,,,nIdent+8,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF},nIdent+12,"I9")	//Monta o Totalizador
	cTag += SIPMontaXML("trataEndoConclDentesP",,,,,,nIdent+8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("protesesOdontologicas",,,,,,nIdent+8,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_BENEF,D_DESPE},nIdent+12,"I10")	//Monta o Totalizador
	cTag += SIPMontaXML("protesesOdontologicas",,,,,,nIdent+8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("protesesOdontoUnitarias",,,,,,nIdent+8,.T.,.F.,,,,.T.)
	cTag += GetTagEvento("",{D_EVENT,D_DESPE},nIdent+12,"I11")	//Monta o Totalizador
	cTag += SIPMontaXML("protesesOdontoUnitarias",,,,,,nIdent+8,.F.,.T.,,,,.T.)

	cTag += SIPMontaXML("procedimentosOdonto",,,,,,nIdent+4,.F.,.T.,,,,.T.)
	cTag += SIPMontaXML("procOdonto",,,,,,nIdent,.F.,.T.,,,,.T.)

Return cTag

Static Function GetTagEvento(cTagName,aReqEvent,nIdent,cItemSip)
	Local cTagPai		:=	""
	Local cTagFilho		:=	""
	Local cValor	:=	"0"
	Local cTagItem	:=	""
	Local	cPicture	:=	""
	Local nReqIte	:=	0
	Local nValor	:=	0
	Local aValores := RetQtdEveVlr(cItemSip,aReqEvent)

	Default cTagName := ""

	For nReqIte := 1 To Len(aReqEvent)
		nValor	:=	0

		If aReqEvent[nReqIte] == D_EVENT
			cPicture	:= cPicEvento//"@E 9999999999"
			cTagItem	:=	"eventos"
			nValor	:=	aValores[1]
		ElseIf aReqEvent[nReqIte] == D_BENEF
			cPicture	:= cPicBenefi//"@E 9999999999"
			cTagItem	:=	"beneficiarios"
			nValor	:=	aValores[2]
		ElseIf aReqEvent[nReqIte] == D_DESPE
			cPicture 	:= cPicTotal//"@E 9999999999.99"
			cTagItem	:=	"despesas"
			nValor	:=	aValores[3]
		EndIf

		cValor	:=	Transform(nValor,cPicture)
		cTagFilho 	+= SIPMontaXML(cTagItem,cValor,,,,,nIdent+4,.T.,.T.,,,,.T.)

	Next nReqIte

	If Empty(cTagName)
		cTagPai += cTagFilho
	ElseIf !Empty(cTagFilho)
		cTagPai += SIPMontaXML(cTagName,,,,,,nIdent,.T.,.F.,,,,.T.)
		cTagPai += cTagFilho
		cTagPai += SIPMontaXML(cTagName,,,,,,nIdent,.F.,.T.,,,,.T.)
	EndIf

Return cTagPai

Static Function RetQtdEveVlr(cItem,aReqEvent)
	Local aArea		:= GetArea()
	Local aRet 		:= {0,0,0}
	Local nQtdEve 	:= 0
	Local nVlrTot 	:= 0
	Local nQtdBenef := 0
	Local nPos		:= 0
	Local cTipPla 	:= TrbUF->B3M_FORCON
	Local cUF 		:= TrbUF->B3M_UF

	nPos := Ascan(aReqEvent, D_EVENT) + Ascan(aReqEvent, D_DESPE) //Se estแ solicitando Evento e/ou Despesa
	If nPos > 0
		QueryEventos(cTipPla,cUF,cItem)
		If TrbEve->(!Eof())
			nQtdEve := Int( TrbEve->B3M_QTDEVE )
			nVlrTot := TrbEve->B3M_VLRTOT
		EndIf
		TrbEve->(Dbclosearea())
	EndIf
	nPos := Ascan(aReqEvent, D_BENEF) //Se estแ solicitando beneficiแrio
	If nPos > 0
		QueryExpostos(cTipPla,cItem)
		If !TrbExpo->(Eof())
			nQtdBenef	:=	TrbExpo->B3M_QTDBEN
		EndIf
		TrbExpo->(Dbclosearea())
	EndIf
	aRet := {nQtdEve,nQtdBenef,nVlrTot}
	RestArea(aArea)

Return aRet

Static Function InsInXMLTemp(cXMLText,lOnTop)
	Local nFile			:=	0
	Local nSwapFile	:=	0
	Local nBytesRead	:=	0
	Local cBuffer 		:= Space(F_BLOCK)
	Local lDone 		:= .F.

	If lOnTop
		//Cria um arquivo de swap.
		nSwapFile	:= FCreate(cXmlSwapFile,0,,.F.)
		FWrite(nSwapFile,StrTran(cXmlText,"> ","> "+chr(10)))

		//Abre o arquivo que contem os dados que serao adicionados ao final do arquivo de Swap
		nFile := FOpen(cXmlTempFile,FO_READWRITE + FO_SHARED)
		If nFile <> - 1
			Do While !lDone
				nBytesRead := FRead(nFile,@cBuffer,F_BLOCK)
				If FWrite(nSwapFile,cBuffer, nBytesRead) < nBytesRead
					lDone := .T.
				Else
					lDone := (nBytesRead == 0)
				EndIf
			EndDo
			FClose(nSwapFile)
			FClose(nFile)
		Else
			MsgInfo("Nao foi possivel localizar o arquivo contendo o XML.")
		EndIf
		//Renomeia de Swap para o nome correto.
		FErase(cXmlTempFile)
		FRename(cXmlSwapFile,cXmlTempFile)
	Else
		//
		nFile := FOpen(cXmlTempFile,FO_READWRITE + FO_SHARED)
		If nFile > 0
			FSeek(nFile, 0, FS_END) //Posiciona no fim do arquivo
			FWrite(nFile,StrTran(cXmlText,"> ","> "+chr(10)) )
		EndIf
		FClose(nFile)
	EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณSIPMontaXMบAuthor ณMicrosiga           บ Date ณ  08/19/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFoi necessario a criacao de uma nova funcao para calcular o บฑฑ
ฑฑบ          ณHash do arquivo para seguir a normas da ANS.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function SIPMontaXML(cTag,cCampo,cTipo,nTam,nDec,cMask,nDesloc,lTagIn,lTagFim,lQuebra,cAtrib,lAcento,lDiopsfin)
	Local cSIPTag		:=	""
	Local nFile		:=	0

	cSIPTag		:=	MontaXML(cTag,cCampo,cTipo,nTam,nDec,cMask,nDesloc,lTagIn,lTagFim,.F.,cAtrib,lAcento,.F.)//mata950
	cSipTag	:=	Alltrim(cSipTag)
	//Grava no arquivo para geracao do Hash.
	If lDiopsfin
		If lCriaHashFi
			nFile			:= FCreate(cHashFile,0,,.F.)
			lCriaHashFi	:=	.F.
		Else
			nFile := FOpen(cHashFile,FO_READWRITE + FO_SHARED)
			FSeek(nFile, 0, FS_END) //Posiciona no fim do arquivo
		EndIf

		If nFile <> -1
			FWrite(nFile,cSipTag)
		Else
			MsgInfo("Erro na gravacao do arquivo temporario para calculo do hash.")
		EndIf

		FClose(nFile)
	EndIf

Return cSIPTag

Static Function AddNode(aArray,cTag,xValor,nCont,nNivel)
	nLen := Len(aArray)
	If nCont = nNivel
		aAdd(aArray,{cTag,xValor})
	Else
		AddNode(aArray[nLen],cTag,xValor,nCont++,nNivel)
	EndIf
Return aArray

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณChkXMLSizeบAuthor ณMicrosiga           บ Date ณ  08/19/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCaso o tamanho do XML que esta sendo gerado ultrapasse o li-บฑฑ
ฑฑบ          ณmite da String do Protheus 1Mb, inicia o processo de grava- บฑฑ
ฑฑบ          ณcao em arquivo temporario.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ChkXMLSize(cXML)
	Local nXMLSize	:=	 Len(cXML)/1048576 //Tamanho da variavel em MB
	Local nFile	:=	0

	If nXMLSize > 2
		If ! isXMLOnFile
			nFile	:= FCreate(cXmlTempFile,0,,.F.)
		Else
			nFile := FOpen(cXmlTempFile,FO_READWRITE + FO_SHARED)
			FSeek(nFile, 0, FS_END) //Posiciona no fim do arquivo
		EndIf

		If nFile <> -1
			FWrite(nFile,StrTran(cXML,"> ","> "+chr(10)) )
			cXML	:=	Nil
			cXML	:=	""
		Else
			MsgInfo("Erro na gravacao do XML")
		EndIf

		FClose(nFile)
		isXMLOnFile	:=	.T.
	EndIf

Return .T.

Static Function WriteXMLFile(cXMLContent,cSequen)
	Local	cFileName	:= BA0->BA0_SUSEP+"_"+ "01"+cMesIni+cAnoSel+"_"+Gravadata(ddatabase,.F.,5)+StrTran(Time(),":","")+".xsip"
	Local cFileDest	:= Alltrim(cDir)+cFileName
	Local nXMLFile		:= 0
	Local lGravado		:=	.T.
	Local cError := ""
	Local cWarning := ""
	Local cTexto :=	""

	If isXMLOnFile
		FRename(cXmlTempFile,cFileDest)
	Else

		cDirSip := BARRA + "sip"

		aArqSch   := directory(cDirSip + BARRA + "SIPV1_02.XSD")
		If len(aArqSch) > 0
			cSchemaPath :=BARRA + "sip" + BARRA + aArqSch[1,1]
			lValidXML := XmlSVldSch (cXMLContent,cSchemaPath, @cError, @cWarning )
		Else
			lValidXML	:= .F.
			cTexto += "O arquivo "+ cDirSip + BARRA + "SIPV1_02.XSD nใo foi encontrado." + Chr(13)
			cTexto += Replicate("-",30) + Chr(13)
			cTexto += Replicate("-",30) + Chr(13)
		EndIf

		If lValidXML
			nXMLFile		:= FCreate(cFileDest,0,,.F.)
			If nXMLFile > 0
				FWrite( nXMLFile,StrTran(cXMLContent,"> ","> " + Chr(13)) )
			Else
				cTexto += "Nao foi possivel gravar o xml no local indicado." + Chr(13)
				cTexto += Replicate("-",30) + Chr(13)
				cTexto += Replicate("-",30) + Chr(13)
				lGravado	:= .F.
			EndIf
			FClose( nXMLFile )
		Else
			lGravado := .F.
		EndIf

		If lGravado
			cTexto += "XML gravado em: " + Alltrim(cDir) + Chr(13)
			cTexto += Replicate("-",30) + Chr(13)
			cTexto += Replicate("-",30) + Chr(13)
			PutMV("MV_PLSEQSIP",Soma1(cSequen))
		Else
			cTexto += "Avisos: " + cWarning + Chr(13)
			cTexto += Replicate("-",30) + Chr(13)
			cTexto += Replicate("-",30) + Chr(13)
			cTexto += "Erros: " + cError + Chr(13)

		EndIf

	EndIf

	LogGerArq(cTexto)

Return .T.

Function LogGerArq(cTexto)
	Local oDlg
	Local cMask     := "Arquivos Texto (*.TXT) |*.txt|"

	cTexto := "Log da atualiza็ใo "+CHR(13)+CHR(10)+cTexto

	__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

	DEFINE FONT oFont NAME "Mono AS" SIZE 5,12   //6,15
	If !IsBlind()
		DEFINE MSDIALOG oDlg TITLE "XML SIP." From 3,0 to 340,417 PIXEL

		@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL

		oMemo:bRClicked := {||AllwaysTrue() }

		oMemo:oFont:=oFont
		oMemo:lReadOnly:=.T.

		DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga

		DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."

		ACTIVATE MSDIALOG oDlg CENTER
	EndIf

Return

/*
Retorna o valor da hash para a tag epilogo
*/
Static Function GetXmlEpilogo()
	Local cHash			:=	""
	Local cBuffer		:=	""
	Local cHashBuffer	:=	""
	Local nBytesRead	:=	0
	Local nFileSize	:=	0
	Local nInfile		:=	0

	aFile := Directory(cHashFile,"F")
	If Len(aFile) > 0
		nFileSize := aFile[1,2]/1048576

		If nFileSize > 0.9
			cHash	:= MD5File(cHashFile)
		Else
			cBuffer 	:= Space(F_BLOCK)
			nInfile 	:= FOpen(cHashFile, FO_READ)
			nFileSize	:= aFile[1,2]//Tamnho em bytes

			Do While nFileSize > 0
				nBytesRead := FRead(nInfile, @cBuffer, F_BLOCK)
				nFileSize -= nBytesRead
				cHashBuffer	+= cBuffer
			EndDo

			FClose(nInfile)
			FErase(cHashFile)
			cHash	:= MD5(cHashBuffer,2)
		EndIf
	Else
		MsgInfo("Nใo foi possivel fazer o calculo da hash. O arquivo "+cHashFile+ " nใo foi encontrado.")
	EndIf

Return cHash

Function SIPXMLDIR(cCPO)
	Local cRet := ""
	Local nOptions := GETF_LOCALHARD
	Local lServer := .T.

	If !FWISINCALLSTACK("PLSSIBRPX") .AND. !FWISINCALLSTACK("PLSSIBCNX") .AND. !FWISINCALLSTACK("PLSBENCNX")

		nOptions += GETF_RETDIRECTORY
		If B3D->B3D_TIPOBR == "2" .OR. B3D->B3D_TIPOBR == "4"
			lServer := .F.
		EndIf
	Else
		nOptions += 0
	EndIf

	cRet := cGetFile(,"Selecione o diretorio",,"",,nOptions,lServer)

	&(cCPO)	:= cRet

Return (!Empty(cRet))

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DataReconPeg

Funcao criada para retornar numa matriz as formas de contratacao e segmentacao dos produtos da central

@author timoteob.bega
@since 31/08/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function GetFormaContratacao(cCodOpe)
	Local aForCon		:= {{"1",""},{"2",""},{"3",""}}
	Local cSql			:= ""
	Default cCodOpe	:= ""

	cSql := "SELECT DISTINCT B3J_FORCON FROM " + RetSqlName("B3J") + " WHERE B3J_FILIAL='" + xFilial("B3J") + "' AND B3J_CODOPE = '" + cCodOpe + "' AND B3J_STATUS='2' AND D_E_L_E_T_=' ' ORDER BY B3J_FORCON"
	cSql := ChangeQuery(cSql)

	If MV_PLCENDB
		PlsLogFil(CENDTHRL("I") + "GetFormaContratacao: " + cSql,ARQ_LOG)
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBF",.F.,.T.)

	If TRBF->(Eof())
		PlsLogFil(CENDTHRL("W") + " Nใo foi encontrado produto valido para a operadora " + cCodOpe ,ARQ_LOG)
	Else
		aForCon		:= {}
		While !TRBF->(Eof())

			If ExisDespProd(cCodOpe,TRBF->B3J_FORCON)

				aAdd(aForCon,{TRBF->B3J_FORCON,""})

			Else

				PlsLogFil(CENDTHRL("W") + " Despesa nao encontrada para forma de contratacao " + TRBF->B3J_FORCON,ARQ_LOG)

			EndIf

			TRBF->(dbSkip())

		EndDo
	EndIf
	TRBF->(dbCloseArea())
Return aForCon

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MarcaComp

Marca o compromisso como Em Processamento ANS ao termino da geracao do xml de envio do SIP

@author timoteob.bega
@since 20/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function MarcaComp()

	B3D->(dbSetOrder(1))//B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO
	If B3D->(MsSeek(xFilial("B3D")+B3D->(B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO)))
		RecLock("B3D",.F.)
		B3D->B3D_STATUS = "4"
		B3D->(msUnLock())
	End

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExisDespProd

Verifica se existe despesa para a segmentacao e forma de contratacao do produto

@author timoteob.bega
@since 20/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisDespProd(cCodOpe,cForCon)
	Local cSql		:= ""
	Local lRetorno	:= .T.
	Local cTriRec	:= Alltrim(B3D->B3D_ANO) + StrZero(val(SubStr(B3D->B3D_REFERE,1,1)),2)
	Default cCodOpe	:= ""
	Default cForCon	:= ""

	cSql := "SELECT R_E_C_N_O_ REC FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' AND B3L_CODOPE = '" + cCodOpe + "' AND B3L_CODOBR = '" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B3L_CDCOMP = '" + B3D->B3D_CODIGO + "' AND B3L_EVEDES = B3L_MATRIC AND B3L_FORCON = '" + cForCon + "' AND B3L_SEGMEN <> ' ' AND B3L_TRIREC = '" + cTriRec + "' AND D_E_L_E_T_=' ' "
	cSql := ChangeQuery(cSql)

	If MV_PLCENDB
		PlsLogFil(CENDTHRL("I") + "QueryExisDespProd: " + cSql,ARQ_LOG)
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TEDP",.F.,.T.)

	If TEDP->(Eof())
		lRetorno := .F.
	EndIf

	TEDP->(dbCloseArea())

Return lRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Verifica segmentos

Verifica se hแ movimenta็ใo em determinado segmento

@author TOTVS PLS Team
@since 31/10/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function VerSeg(cTipPla,cSegmen)
	Local cSql	    := ""
	Local lRet	    := .T.
	Default cSegmen := ""
	Default cTipPla := ""

	cSql	+=	"SELECT DISTINCT B3M_FORCON,B3M_UF,B3M_TRIOCO "
	cSql	+=	"FROM   " + RetSqlName("B3M")
	cSql	+=	"	WHERE		"+RetSqlName("B3M")+".D_E_L_E_T_ = ' ' "
	cSql	+=	"	AND B3M_UF <> 'FC' "
	cSql	+=	"	AND B3M_UF <> 'ZZ' "
	cSql	+=	"	AND B3M_FILIAL = '" + xFilial("B3M") + "' "
	cSql	+=	"	AND B3M_TRIREC = '" + cPerData + "' "
	cSql	+=	"	AND B3M_FORCON = '" + cTipPla + "' "

	If cSegmen == 'A'
		cSql	+=	"   AND B3M_ITEM   IN ('A','B','C','D','H') "
	ElseIf cSegmen == 'B'
		cSql	+=	"   AND B3M_ITEM   IN ( 'A','B','C','D','E','F','G','H') "
	Else
		cSql	+=	"   AND B3M_ITEM   IN ( '" + cSegmen + "' ) "
	endif

	cSql	+=	"	AND (B3M_QTDEVE > 0 OR B3M_VLRTOT > 0 OR B3M_QTDBEN > 0) "
	cSql	+=	" ORDER BY B3M_UF, B3M_TRIOCO, B3M_FORCON "

	cSql := ChangeQuery(cSql)
	If MV_PLCENDB
		PlsLogFil(CENDTHRL("I") + "QueryVerSeg: " + cSql,ARQ_LOG)
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbSeg",.F.,.T.)

	lRet := !TrbSeg->(Eof())
	TrbSeg->(Dbclosearea())

Return lRet

