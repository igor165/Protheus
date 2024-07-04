#Include 'TOTVS.CH'
#Include 'FILEIO.CH'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

#define lLinux IsSrvUnix()
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSR500

Relatório Analítico do SIP em formato .CSV

@author timoteo.bega
@since 01/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSR500()
	Local cAliasTmp	:= GetNextAlias()
	Local cConsulta	:= ""
	Local nFor		:= 0
	Local lAuto     := IsBlind()
	Local lOK       := .F.

	For nFor := 1 TO 2

		cConsulta := RetornaConsulta(AllTrim(Str(nFor)))

		If ExecutaConsulta(cConsulta,cAliasTmp)[1]
			if lHabMetric .and. lLibSupFw .and. lVrsAppSw
				FWMetrics():addMetrics("Relatório Analítico", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
			endif
			IIF(!lAuto,MsgRun("Processando registros","TOTVS",{ || ProcRelatorio(cAliasTmp,nFor) }),ProcRelatorio(cAliasTmp,nFor,lAuto))
			lOk:=.T.
		EndIf

	Next nFor

	(cAliasTmp)->(dbCloseArea())

Return lOK

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcRelatorio

Está função chama o processamento do relatório e copia os arquivos CSVs do servidor para o cliente

@author timoteo.bega
@since 01/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ProcRelatorio(cAliasTmp,nOpc,lAuto)
	Local cNmAmb	    := "RelAnaliticoSIP_Amb_" + DTOS(dDataBase) + "_" + StrTran(Time(),":","") + ".csv"
	Local cNmInt	    := "RelAnaliticoSIP_Int_" + DTOS(dDataBase) + "_" + StrTran(Time(),":","") + ".csv"
	Local cLocal	    := ""
	Local nArq		    := 0
	Default cAliasTmp	:= ""
	Default nOpc		:= 1
	Default lAuto       := .f.

	If nOpc == 1
		nArq := FCreate(cNmAmb,0,,.F.)
	Else
		nArq := FCreate(cNmInt,0,,.F.)
	EndIf

	If nArq > 0

		EscreveArquivo(nArq,cAliasTmp,nOpc)
		FClose(nArq)
		IIF(!lAuto,cLocal := cGetFile("TOTVS","Selecione o diretorio",,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY),cLocal :="C:\sip")

		If lAuto .Or. CpyS2T(Iif(nOpc == 1,cNmAmb,cNmInt),cLocal,.T.,.F.)
			IIF(!lAUto,MsgInfo("Arquivo gravado em " + cLocal + " " + Iif(nOpc == 1,cNmAmb,cNmInt) ),"")
		Else
			IIF(!lAUto,MsgInfo("Não foi possível copiar o arquivo do servidor " + cLocal + " " + Iif(nOpc == 1,cNmAmb,cNmInt) ),"")
		EndIf

	Else
		IIF(!lAUto,MsgInfo("Não foi possível criar o arquivo " + Iif(nOpc == 1,cNmAmb,cNmInt)),"")
	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EscreveArquivo

Escreve no arquivo .CSV cabeçalho e dados analíticos do SIP. 1 para ambulatorial e outro para internação

@author timoteo.bega
@since 01/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function EscreveArquivo(nArq,cAliasTmp,nOpc)
	Local cLinha	:= ""
	Local cCabec	:= "UF;Tri. Ocor.;Chave Despesa;Cod. Tabela;Cod. Evento;Qtde. Eve.;Vlr. Eve.;Data Eve.;Data Nasc.;Sexo;Classificacao;For. Contr.;Segmentacao;"

	If nOpc == 2
		cCabec += "Dt. Intern.;Hora Intern.;Dt. Alta;Hora Alta;Nasc. Vivo;Regime Intern.;Tipo Intern.;CID;Internacao;"
	EndIf

	cCabec += "Usuario;Data;Hora" + CRLF
	FWrite(nArq,cCabec)

	While !(cAliasTmp)->(Eof())

		cLinha := AllTrim( (cAliasTmp)->B3L_UF ) + ";"
		cLinha += AllTrim( (cAliasTmp)->B3L_TRIOCO ) + ";"
		cLinha += AllTrim( (cAliasTmp)->B3L_EVEDES ) + ";"
		cLinha += AllTrim( (cAliasTmp)->B3L_CDTPTB ) + ";"
		cLinha += AllTrim( (cAliasTmp)->B3L_CODEVE ) + ";"
		cLinha += AllTrim( AllTrim(Str((cAliasTmp)->B3L_QTDEVE)) ) + ";"
		cLinha += AllTrim( strtran(str((cAliasTmp)->B3L_VLREVE), ".", ",") ) + ";"
		cLinha += AllTrim( (cAliasTmp)->B3L_DATEVE ) + ";"
		cLinha += AllTrim( (cAliasTmp)->B3K_DATNAS ) + ";"
		cLinha += AllTrim( (cAliasTmp)->B3K_SEXO ) + ";"
		cLinha += AllTrim( (cAliasTmp)->B3L_CLASIP ) + ";"
		cLinha += AllTrim( (cAliasTmp)->B3L_FORCON ) + ";"
		cLinha += AllTrim( (cAliasTmp)->B3L_SEGMEN ) + ";"

		If nOpc == 2
			cLinha += AllTrim( (cAliasTmp)->B3L_DATINT ) + ";"
			cLinha += AllTrim( (cAliasTmp)->B3L_HORINT ) + ";"
			cLinha += AllTrim( (cAliasTmp)->B3L_DATALT ) + ";"
			cLinha += AllTrim( (cAliasTmp)->B3L_HORALT ) + ";"
			cLinha += AllTrim( AllTrim(Str((cAliasTmp)->B3L_NASVIV)) ) + ";"
			cLinha += AllTrim( RetDesc("1", (cAliasTmp)->B3L_REGINT ) ) + ";"
			cLinha += AllTrim( RetDesc("2", (cAliasTmp)->B3L_GRPINT ) ) + ";"
			cLinha += AllTrim( (cAliasTmp)->B3L_CID ) + ";"
			cLinha += AllTrim( (cAliasTmp)->B3L_EVDEIN ) + ";"
		EndIf

		cLinha += AllTrim( (cAliasTmp)->B3L_LOGIN ) + ";"
		cLinha += AllTrim( (cAliasTmp)->B3L_DTINSI ) + ";"
		cLinha += AllTrim( (cAliasTmp)->B3L_HRINSI ) + CRLF

		FWrite(nArq,cLinha)
		(cAliasTmp)->(dbSkip())

	EndDo

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaConsulta

Retorna a consulta de dados ambulatoriais ou de internação de acordo com a classificação

@author timoteo.bega
@since 01/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaConsulta(cTipo)
	Local cConsulta	:= ""
	Default cTipo	:= "1"//1-Consulta, Servico, 2-Internacao

	If cTipo == "1" //1-Consulta, Servico"

		cConsulta := "SELECT B3L_UF, B3L_TRIOCO, B3L_EVEDES, B3L_CDTPTB, B3L_CODEVE, B3L_QTDEVE, B3L_VLREVE, B3L_DATEVE, B3K_DATNAS, "
		cConsulta += "CASE WHEN B3K_SEXO = '1' THEN 'Masculino' WHEN B3K_SEXO = '3' THEN 'Feminino' END B3K_SEXO, "
		cConsulta += "B3L_CLAAMB B3L_CLASIP, "
		cConsulta += "CASE WHEN B3L_FORCON = '1' THEN 'Individual/Familiar' WHEN B3L_FORCON = '2' THEN 'Coletivo Empresarial' WHEN B3L_FORCON = '3' THEN 'Coletivo por Adesao' END B3L_FORCON, "
		cConsulta += "CASE WHEN B3L_SEGMEN = '1' THEN 'Ambulatorial' WHEN B3L_SEGMEN = '2' THEN 'Hospitalar' WHEN B3L_SEGMEN = '3' THEN 'Hospitalar Obstetrico' WHEN B3L_SEGMEN = '4' THEN 'Odontologico' END B3L_SEGMEN, "
		cConsulta += "' ' B3L_LOGIN, B3L_DTINSI, B3L_HRINSI "
		cConsulta += "FROM " + RetSqlName("B3L") + " B3L, " + RetSqlName("B3K") + " B3K WHERE B3L_FILIAL=B3K_FILIAL AND B3L_CODOPE=B3K_CODOPE AND B3L_MATRIC=B3K_MATRIC "
		cConsulta += "AND B3L_FILIAL='" + xFilial("B3L") + "' AND B3L_CODOPE='" + B3D->B3D_CODOPE + "' AND B3L_CODOBR='" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP='" + B3D->B3D_ANO + "' AND B3L_CDCOMP='" + B3D->B3D_CODIGO + "' "
		cConsulta += "AND B3L_EVDEIN = ' ' AND B3L_REGINT = ' ' AND B3L_GRPINT = ' ' AND (B3L_VLREVE > 0 OR B3L_QTDEVE > 0) "
		cConsulta += "AND B3L_EVEDES <> B3L_MATRIC AND ( B3L_CLAAMB BETWEEN 'A' AND 'D6' OR B3L_CLAAMB BETWEEN 'I' AND 'I11' OR B3L_CLAAMB = ' ' OR B3L_CLAAMB = 'H' ) "
		cConsulta += "AND ( ( B3L_EVDEIN = ' ' AND B3L_REGINT = ' ' AND B3L_GRPINT = ' ' ) OR ( B3L_CLAAMB BETWEEN 'A' AND 'A2' ) ) AND B3L.D_E_L_E_T_=' ' AND B3K.D_E_L_E_T_=' ' "
		cConsulta += "ORDER BY B3L_CLAAMB"

	Else//cTipo == "2"//2-Internacao"

		cConsulta := "SELECT B3L_UF, B3L_TRIOCO, B3L_EVDEIN, B3L_EVEDES, B3L_CDTPTB, B3L_CODEVE, B3L_QTDEVE, B3L_VLREVE, B3L_DATEVE, B3K_DATNAS, "
		cConsulta += "CASE WHEN B3K_SEXO = '1' THEN 'Masculino' WHEN B3K_SEXO = '3' THEN 'Feminino' END B3K_SEXO, "
		cConsulta += "B3L_CLAAMB B3L_CLASIP, "
		cConsulta += "CASE WHEN B3L_FORCON = '1' THEN 'Individual/Familiar' WHEN B3L_FORCON = '2' THEN 'Coletivo Empresarial' WHEN B3L_FORCON = '3' THEN 'Coletivo por Adesao' END B3L_FORCON, "
		cConsulta += "CASE WHEN B3L_SEGMEN = '1' THEN 'Ambulatorial' WHEN B3L_SEGMEN = '2' THEN 'Hospitalar' WHEN B3L_SEGMEN = '3' THEN 'Hospitalar Obstetrico' WHEN B3L_SEGMEN = '4' THEN 'Odontologico' END B3L_SEGMEN, "
		cConsulta += "' ' B3L_LOGIN, B3L_DTINSI, B3L_HRINSI, B3L_DATINT, B3L_HORINT, B3L_DATALT, B3L_HORALT, B3L_NASVIV, B3L_GRPINT, B3L_REGINT, B3L_CID "
		cConsulta += "FROM " + RetSqlName("B3L") + " B3L, " + RetSqlName("B3K") + " B3K WHERE B3L_FILIAL=B3K_FILIAL AND B3L_CODOPE=B3K_CODOPE AND B3L_MATRIC=B3K_MATRIC AND (B3L_VLREVE > 0 OR B3L_QTDEVE > 0) "
		cConsulta += "AND B3L_FILIAL='" + xFilial("B3L") + "' AND B3L_CODOPE='" + B3D->B3D_CODOPE + "' AND B3L_CODOBR='" + B3D->B3D_CDOBRI + "' AND B3L_ANOCMP='" + B3D->B3D_ANO + "' AND B3L_CDCOMP='" + B3D->B3D_CODIGO + "' "
		cConsulta += "AND B3L_EVEDES <> B3L_MATRIC AND ( B3L_EVDEIN <> ' ' OR B3L_REGINT <> ' ' OR B3L_GRPINT <> ' ' ) AND ( B3L_CLAAMB = ' ' OR B3L_CLAAMB >= 'A2' ) AND B3L.D_E_L_E_T_=' ' AND B3K.D_E_L_E_T_=' ' "
		cConsulta += "ORDER BY B3L_CLAAMB DESC"

	EndIf

Return cConsulta

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecutaConsulta

Executa a consulta e cria a area de trabalho

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExecutaConsulta(cConsulta,cAliasTmp)
	Local aRetFun			:= {.F.,"Nenhum registro encontrado para ser apresentado",""}
	Default cConsulta	:= ""
	Default cAliasTmp	:= ""

	If !Empty(cConsulta) .And. !Empty(cAliasTmp)

		If (Select(cAliasTmp) <> 0)
			dbSelectArea(cAliasTmp)
			(cAliasTmp)->(dbCloseArea())
		EndIf

		cConsulta := ChangeQuery(cConsulta)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cConsulta),cAliasTmp,.F.,.T.)

		If !(cAliasTmp)->(Eof())
			aRetFun[1] := .T.
		EndIf

	EndIf

Return aRetFun

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetDesc

Retorna a descrição de 1-tipo de internação, 2-regime de internação

@author timoteo.bega
@since 01/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetDesc(cTipo,cValor)
	Local cDesc			:= ""
	Local aDesc			:= {}
	Local nDesc			:= 0
	Default cTipo		:= "1"
	Default cValor	:= ""

	If cTipo == "1"//Tipo de Internacao

		aAdd(aDesc,{"1","Hospitalar"})
		aAdd(aDesc,{"2","Hospital-Dia"})
		aAdd(aDesc,{"3","Domiciliar"})

	ElseIf cTipo == "2"//Regime de Internacao

		aAdd(aDesc,{"1","Clinica"})
		aAdd(aDesc,{"2","Cirurgica"})
		aAdd(aDesc,{"3","Obstetrica"})
		aAdd(aDesc,{"4","Pediatrica"})
		aAdd(aDesc,{"5","Psiquiatrica"})

	ElseIf cTipo == "3"//F-Causa Internacao

		aAdd(aDesc,{"",""})

	EndIf

	nDesc := aScan(aDesc,{ |x| x[1] == cValor })

	If nDesc > 0
		cDesc := aDesc[nDesc,2]
	EndIf

Return cDesc
