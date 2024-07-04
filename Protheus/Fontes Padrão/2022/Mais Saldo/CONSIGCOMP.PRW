#INCLUDE "PROTHEUS.CH"
#INCLUDE "CONSIGCOMP.CH"

#DEFINE TAB  			CHR ( 13 ) + CHR ( 10 )

Private oError
Private bError      := { |e| oError := e, Break(e) }
Private bErrorBlock := ErrorBlock( bError )


Static	cRetConsParc :=	"" // Retorno da Consulta Específica fCPdrParc

/*/{Protheus.doc} function fConsTKConsig
Realiza a consulta do token de autenticação no Portal TOTVS Consignado.
@author  hugo.de.oliveira
@since   19/09/2020
@version 1.0
/*/
Function fConsTKConsig()
    Local cResponse     := ""
    Local cHeaderRet    := ""
    Local cBody         := ""
    Local cRacToken     := ""
	Local cRACID 		:= ""
	Local cRACSecret    := ""
	Local cRACURL       := fGetURLRac()
    Local aHeader       := {}
    Local nTimeOut      := 120 // Segundos
    Local oResponse     := JsonObject():New()
    Local cURL          := ""
	Local oConfig  		:= FWTFConfig() // Retorna as configurações da integração TechFin/Carol.

    Aadd(aHeader, "Content-Type: application/x-www-form-urlencoded")
    AAdd(aHeader, "User-Agent: Protheus " + GetBuild())

	cURL := cRACURL + "/totvs.rac/connect/token"

	If !Empty(oConfig["platform-clientId"]) .AND. !Empty(oConfig["platform-secret"])
		cRACID  	 := PadR(oConfig["platform-clientId"], 32)
		cRACSecret := ALLTRIM(PadR(oConfig["platform-secret"], 32))
	EndIf

	cBody := "client_id="     + cRACID + "&"
	cBody += "client_secret=" + cRACSecret + "&"
	cBody += "grant_type=client_credentials&"
	cBody += "scope=authorization_api"
	cResponse := HttpPost(cUrl, "", cBody, nTimeOut, aHeader, cHeaderRet)

	If AT("200 OK", cHeaderRet) > 0 .AND. AT("access_token", cResponse) > 0
		oResponse:fromJson(cResponse)
		cRacToken := Alltrim(oResponse:GetJsonText("access_token"))
	EndIf

	cRacToken := ALLTRIM(cRacToken)
	
Return cRacToken


/*/{Protheus.doc} function fConsParceiros
Realiza a consulta de Parceiros no TOTVS Consignado.
@author  hugo.de.oliveira
@since   19/09/2020
@version 1.0
/*/
Function fConsParceiros()
  Local oInteg
	Local cRacToken  := ""
  Local oRet 		 := JsonObject():New()
	Local aHeader    := {}
	Local cEndConsig := fGetURLCsg()

	If !Empty(cEndConsig)
		oInteg    := FwRest():New(cEndConsig + "/api/erp/v1/partner")
		cRacToken := fConsTKConsig()
		aAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
		aAdd(aHeader, "Authorization: Bearer " + cRacToken)

		oInteg:setPath("?")
	
		If oInteg:Get(aHeader)
			If oInteg:ORESPONSEH:CSTATUSCODE == "200" .AND. !Empty(oInteg:GetResult())
				FWJsonDeserialize(oInteg:GetResult(), @oRet)
			EndIf
		EndIf
	EndIf
Return oRet


/*/{Protheus.doc} function fCPdrParc
Função utilizada na consulta padrão genérica para consultar de Parceiros no TOTVS Consignado.
@author  hugo.de.oliveira
@since   19/09/2020
@version 1.0
/*/
Function fCPdrParc()
    Local oRadio
    Local oDlg
    Local oSay1
		Local oParceiros
    Local cCodigo        	:= ""
    Local cDesc          	:= ""
    Local nRadio 	     		:= 1
    Local nX             	:= 1
    Local lOk			 				:= .F.
    Local aAdv1Size		 		:= {}
    Local aInfo1AdvSize		:= {}
    Local aObj1Size		 		:= {}
    Local aObj1Coords	 		:= {}
    Local aAdv12Size	 		:= {}
    Local aInfo12AdvSize 	:= {}
    Local aObj12Size 	 		:= {}
    Local aObj12Coords	 	:= {}
    Local aItems         	:= {}
    Local aCodigos       	:= {}
    Local bFecha		 			:= {||lOk:=.F., oDlg:End()}
    Local bOK			 				:= {||lOk:=.T., oDlg:End()}

    // Realiza a consulta da Integração de Parceiros
    oParceiros := fConsParceiros()

    If VALTYPE(oParceiros) == "O" .AND. !Empty(oParceiros:ITEMS)
        For nX := 1 To Len(oParceiros:ITEMS)
            cCodigo := ALLTRIM(oParceiros:ITEMS[nX]:CODE)
            cDesc   := ALLTRIM(DecodeUTF8(oParceiros:ITEMS[nX]:SOCIALREASON))
                Aadd(aItems, cDesc)
                Aadd(aCodigos, cCodigo)
        Next nX
    Else
        Aviso( OemToAnsi(STR0001), OemToAnsi(STR0002) , { OemToAnsi( "Ok") }, 3 ) // STR0001: "Aviso Integração" e STR0002: "Não foi possível realizar a consulta de operadoras disponíveis para o TOTVS Consignado. Serviço indisponível ou dados para conexão inválidos."
        cRetConsParc := STR0003 // "Erro ao consultar Operadoras."
        Return .T.
    EndIf

    aAdv1Size	:= MsAdvSize(,.T.,380)
    aInfo1AdvSize	:= { aAdv1Size[1] , aAdv1Size[2] , aAdv1Size[3] , aAdv1Size[4] , 5 , 5}
    aAdd(aObj1Coords , { 000 , 010 , .T. , .F. })
    aAdd(aObj1Coords , { 000 , 010 , .T. , .F. })
    aObj1Size	:= MsObjSize( aInfo1AdvSize , aObj1Coords )

    aAdv12Size		:= aClone(aObj1Size[1])
    aInfo12AdvSize	:= { aAdv12Size[2] , aAdv12Size[1] , aAdv12Size[4] , aAdv12Size[3] , 1 , 1 }
    aAdd( aObj12Coords , { 005 , 000 , .F. , .T. } )			//1-Coluna 1
    aAdd( aObj12Coords , { 000 , 000 , .T. , .T. } )			//2-Coluna 2
    aObj12Size		:= MsObjSize( aInfo12AdvSize , aObj12Coords,,.T. )

    DEFINE MSDIALOG oDlg FROM 180,180 TO 500,600 PIXEL TITLE OemToAnsi(STR0004) // STR0004: "Consulta de Operadoras"

    oSay1 := tSay():New(aObj1Size[1,1],aObj1Size[1,2]+5, {||OemToAnsi(STR0005)}, oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,250,10) // STR0005: "Escolha abaixo qual operadora será utilizada:"
    nRadio := 0
    oRadio := TRadMenu():New (aObj12Size[2,1]+10, aObj12Size[2,2], aItems,,oDlg,,,,,,,,200,12,,,,.T.)
    oRadio:bSetGet := {|u|Iif (PCount()==0, nRadio, nRadio:=u)}

    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bOK, bFecha, NIL, NIL, NIL )

    If lOK .And. nRadio != 0
        cRetConsParc := aCodigos[nRadio] + " - " + aItems[nRadio]
    EndIf

Return .T.


/*/{Protheus.doc} function fRCPdrParc
Função utilizada para retorno do conteúdo da consulta específica fCPdrParc
@author  hugo.de.oliveira
@since   19/09/2020
@version 1.0
/*/
Function fRCPdrParc()
Return cRetConsParc


/*/{Protheus.doc} fValOper
Percorre os registros e realiza as validações de acordo com as regras do Crédito Consignado
@author oliveira.hugo
@since 08/09/2020
/*/
Function fValOper(cTabela, cIdParc, cDescOper, cVerbaFol, cVerbaRes)
	Local oParceiros
	Local nX					:= 1
	Local nPosCampo		:= 0
	Local cCampoProc	:= ""
	Local cNovaFil		:= ""
	Local cFilAtual		:= ""
	Local cValor			:= ""
	Local lRet 				:= .T.
	Local lVerifTodos	:= .F.
	Local lVerifFil		:= .F.
	Local lFolVazia		:= .F.
	Local lResVazia		:= .F.
	Local aDescParc		:= {}

	Local nPosFinal 	:= Len(aCols)
	Local nPosFil			:= IIf(GdFieldPos("RCC_FIL") > 0, GdFieldPos("RCC_FIL", aHeader), 1)
	Local nPosFol			:= IIf(GdFieldPos("CODVERBFOL") > 0, GdFieldPos("CODVERBFOL", aHeader), 1)
	Local nPosRes			:= IIf(GdFieldPos("CODVERBRES") > 0, GdFieldPos("CODVERBRES", aHeader), 1)
	Local lFilInform 	:= !Empty(aCols[nPosFinal][nPosFil])

	DEFAULT cTabela 	:= ""
	DEFAULT cIdParc  	:= ""
	DEFAULT cDescOper := ""
	DEFAULT cVerbaFol := ""
	DEFAULT cVerbaRes := ""
	
	// Seta Propriedades de validação
	If !Empty(ALLTRIM(cVerbaFol))
		cCampoProc := "CODVERBFOL"
	
	ElseIf !Empty(ALLTRIM(cVerbaRes))
		cCampoProc := "CODVERBRES"
	
	ElseIf !Empty(ALLTRIM(cDescOper))
		cCampoProc := "DESCOPER"

		// Valida Parceiros
		oParceiros 	:= fConsParceiros()

		If VALTYPE(oParceiros) == "O" .AND. !Empty(oParceiros:ITEMS)
			For nX := 1 To Len(oParceiros:ITEMS)
				Aadd(aDescParc, ALLTRIM(DecodeUTF8(oParceiros:ITEMS[nX]:SOCIALREASON)))
			Next nX
		EndIf

		// Valida descrição Informada
		lRet := .F.
		For nX := 1 To Len(aDescParc)
			If aDescParc[nX] == SUBSTR(ALLTRIM(cDescOper), 8, LEN(ALLTRIM(cDescOper)))
				lRet := .T.
				Exit
			EndIf
		Next nX
	Else
		cCampoProc := "RCC_FIL"
	EndIf

	If lRet
		// Caso seja informado apenas 1 registro
		If nPosFinal == 1
			If  (cCampoProc == "CODVERBFOL" .AND. Empty(cVerbaFol)) .OR. ;
				(cCampoProc == "CODVERBRES" .AND. Empty(cVerbaRes)) .OR. ;
				(cCampoProc == "DESCOPER"   .AND. Empty(cDescOper))
					lRet := .F.
			EndIf
		Else
			// Percorre todos os registros anteriores para validação
			For nX := 1 to nPosFinal-1
				nPosCampo := GdFieldPos(cCampoProc, aHeader)
				cValor 	  := IIF(cCampoProc == 'RCC_FIL', aCols[nX][nPosCampo], ALLTRIM(aCols[nX][nPosCampo]))

				cFilAtual := aCols[nX][nPosFil]
				cNovaFil  := aCols[nPosFinal][nPosFil]

				lVerifTodos := !lFilInform .AND. cValor == IIF(cCampoProc == 'RCC_FIL', cNovaFil, ALLTRIM(&cCampoProc))
				lVerifFil   := lFilInform .AND. cValor == IIF(cCampoProc == 'RCC_FIL', cNovaFil, ALLTRIM(&cCampoProc)) .AND. (cFilAtual == cNovaFil .OR. Empty(cFilAtual))
				lFolVazia	:= Empty(ALLTRIM(aCols[nPosFinal][nPosFol]))
				lResVazia	:= Empty(ALLTRIM(aCols[nPosFinal][nPosRes]))

				If  lVerifTodos .OR. ; // Verifica se o campo se repete em todos os anteriores, pois a filial está vazia
					lVerifFil 	.OR. ; // Verifica se o campo se repete nas filiais anteriores, pois a filial foi informada
					(cCampoProc == "DESCOPER" .AND. !Empty(ALLTRIM(cDescOper)) .AND. (lFolVazia .OR. lResVazia)) // Verifica se a descrição foi informada e as verbas não
						lRet := .F.
						Exit
				EndIf
			Next nX
		EndIf
	EndIf
Return lRet


/*/{Protheus.doc} function fAjustTam
Ajusta o conteúdo do campo informado de acordo com o dicionário
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Function fAjustTam(cCampo, cValor)
	Local nTamSX3 := 0
	
	DEFAULT cCampo := ""
	DEFAULT cValor := ""
	
	cCampo  := ALLTRIM(cCampo)
	cValor  := ALLTRIM(cValor)
	nTamSX3 := TamSx3(cCampo)[1]

	If !Empty(cCampo) .AND. LEN(cValor) < nTamSX3
		cValor += Space(nTamSX3 - LEN(cValor))
	EndIf
Return cValor


/*/{Protheus.doc} function fConsVerba
Consulta campo específico, no cadastro de Verbas.
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Function fConsVerba(cFilSRV, cVerba, cCampoRet)
	Local cAlias 	:= "SRV"
	Local cRet		:= ""
	
	DEFAULT cFilSRV := ""
	DEFAULT cVerba 	:= ""

	If !Empty(cFilSRV) .AND. !Empty(cVerba) .AND. !Empty(cCampoRet)
		
		(cAlias)->(dbSetOrder(1)) // RV_FILIAL, RV_COD

		If (cAlias)->(dbSeek(xFilial(cAlias, cFilSRV) + cVerba))
			cRet := (cAlias)->&(cCampoRet)
		EndIf
	EndIf
Return cRet


/*/{Protheus.doc} function fConsCabPer
Realiza a consulta de dados do cabeçalho do período
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Function fConsCabPer(cFil, cProcess, cAno, cMes, cCampo)
	Local cValor 	:= ""
	Local cAlias 	:= "RCF"

	DEFAULT cFil 	 := ""
	DEFAULT cProcess := ""
	DEFAULT cAno 	 := ""
	DEFAULT cMes 	 := ""
	DEFAULT cCampo 	 := ""

	If !Empty(cFil) .And. !Empty(cAno) .And. !Empty(cMes) .And. !Empty(cProcess)
		(cAlias)->(dbSetOrder(3)) // RCF_FILIAL, RCF_PROCES, RCF_PER
		
		If (cAlias)->(dbSeek(xFilial(cAlias, cFil) + cProcess + (cAno + cMes)))
			cValor := (cAlias)->&(cCampo)
		EndIf
	EndIf

	cValor := fAjustTam(cCampo, cValor)
return cValor


/*/{Protheus.doc} function fConsPer
Realiza a consulta de dados do Período
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Function fConsPer(cFilRCH, cProc, cPeriodo, cCampoRet)
	Local cAlias 	:= "RCH"
	Local cRet	 	:= ""
	Local cRot		:= fGetRotOrdinar() // Roteiro da folha

	DEFAULT cFilRCH 	:= ""
	DEFAULT cProc 		:= ""
	DEFAULT cPeriodo 	:= ""
	DEFAULT cCampoRet 	:= ""

	If !Empty(cFilRCH) .AND. !Empty(cProc) .AND. !Empty(cPeriodo) .AND. !Empty(cCampoRet)
		(cAlias)->(dbSetOrder(4)) // RCH_FILIAL, RCH_PROCES, RCH_ROTEIR, RCH_PER

		If (cAlias)->(dbSeek(xFilial(cAlias, cFilRCH) + cProc + cRot + cPeriodo))
			cRet := (cAlias)->&(cCampoRet)
		EndIf
	EndIf
Return cRet


/*/{Protheus.doc} function fConsFunc
Realiza a consulta de dados do Funcionário
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Function fConsFunc(cFilSRA, cMatricula, cCampoRet)
	Local cValor := ""
	Local cAlias := "SRA"

	DEFAULT cFilSRA    := ""
	DEFAULT cMatricula := ""
	DEFAULT cCampoRet  := ""

	If !Empty(cFilSRA) .And. !Empty(cMatricula) .And. !Empty(cCampoRet)
		(cAlias)->(dbSetOrder(1)) // RA_FILIAL, RA_MAT
		
		If (cAlias)->(dbSeek(xFilial(cAlias, cFilSRA ) + ALLTRIM(cMatricula)))
			cValor := Alltrim((cAlias)->&(ALLTRIM(cCampoRet)))
		EndIf
	EndIf

	If Alltrim(cCampoRet) != "RA_NOME"
		cValor := fAjustTam(cCampoRet, cValor)
	EndIf
return cValor


/*/{Protheus.doc} fValidS137
Valida cadastro de vínculo entre parceiro e verba.
@author oliveira.hugo
@since 12/09/2020
/*/
Function fValidS137(aHeader, aCols)
	Local nX 		:= 1
	Local lRet 		:= .T.
	Local cMsg 		:= ""
	
	Local nPosFil	:= IIf(GdFieldPos("RCC_FIL") 	> 0, GdFieldPos("RCC_FIL"), 1)
	Local nPosFol	:= IIf(GdFieldPos("CODVERBFOL") > 0, GdFieldPos("CODVERBFOL", aHeader), 1)
	Local nPosRes   := IIf(GdFieldPos("CODVERBRES") > 0, GdFieldPos("CODVERBRES", aHeader), 1)
	Local nPosDesc  := IIf(GdFieldPos("DESCOPER")   > 0, GdFieldPos("DESCOPER",   aHeader), 1)
	
	DEFAULT aHeader := {}
	DEFAULT aCols 	:= {}

	For nX := 1 To LEN(aCols)
		If Empty(aCols[nX][nPosFol]) .OR. Empty(aCols[nX][nPosRes]) .OR. Empty(aCols[nX][nPosDesc])
			cMsg := STR0006 // "Há campos obrigatórios não preenchidos."
			lRet := .F.
		
		ElseIf !EMPTY(aCols[nX][nPosFil]) .And. !(ExistCpo("SM0", cEmpAnt + aCols[nX][nPosFil], 1, /*Help*/, .F.))
			cMsg := STR0010 // "Informe uma filial válida ou deixe o campo em branco."
			lRet := .F.

		ElseIf !EMPTY(aCols[nX][nPosFil]) .And. xFilial("RCC") != xFilial("RCC", aCols[nX][nPosFil])
			cMsg := STR0007 // "A filial selecionada deve estar de acordo com o modo de compartilhamento da tabela RCC."
			lRet := .F.

		ElseIf !EMPTY(aCols[nX][nPosFol])  .AND. !EMPTY(aCols[nX][nPosRes]) .AND. !EMPTY(aCols[nX][nPosDesc]) .AND. !fChkFilDup()
			cMsg := STR0008 // "Há campos obrigatórios repetidos."
			lRet := .F.
		EndIf
	Next nX

	If !lRet
		Aviso(OemToAnsi(STR0009), OemToAnsi(cMsg), {OemToAnsi("OK")}, 3) // STR0009: "Erro na Gravação"
	EndIf
return lRet


/*/{Protheus.doc} function fChkFilDup
Procura Filiais repetidas
@author  hugo.de.oliveira
@since   05/11/2020
@version 1.0
/*/
static Function fChkFilDup()
	Local nX		 := 1
	Local nPesqFil	 := 0
	Local lRes 		 := .T.
	Local nPosFil	 := IIf(GdFieldPos("RCC_FIL") > 0, GdFieldPos("RCC_FIL", aHeader), 1)
	Local nPosFol 	 := IIf(GdFieldPos("CODVERBFOL") > 0, GdFieldPos("CODVERBFOL", aHeader), 1)
	Local nPosRes 	 := IIf(GdFieldPos("CODVERBRES") > 0, GdFieldPos("CODVERBRES", aHeader), 1)
	Local nPosDesc   := IIf(GdFieldPos("DESCOPER") > 0, GdFieldPos("DESCOPER", aHeader), 1)

	If Len(aCols) > 1
		For nX := 1 To Len(aCols)
			cFilAtual  := aCols[nX][nPosFil]
			nPesqFil   := aScan(aCols, {|x| x[nPosFil] == cFilAtual })
			
			If (nPesqFil != nX) .AND. cFilAtual == aCols[nPesqFil][nPosFil] .AND. ;
				(aCols[nX][nPosFol] == aCols[nPesqFil][nPosFol] .OR. aCols[nX][nPosRes] == aCols[nPesqFil][nPosRes] .OR. aCols[nX][nPosDesc] == aCols[nPesqFil][nPosDesc])
					lRes := .F.
					Exit
			EndIf
		Next nX
	EndIf
Return lRes


/*/{Protheus.doc} function fUpdSX6
Função utilizada para atualização de parâmetros na SX6
@author  Hugo de Oliveira
@since   09/11/2020
@version 1.0
/*/
Function fUpdSX6(cParam, cConteu, cDesc, cTipo)
  	DEFAULT cParam 	:= ""
	DEFAULT cConteu := ""
	DEFAULT cDesc 	:= ""
	DEFAULT cTipo 	:= "C"

    If !Empty(cParam) .AND. !Empty(cDesc) .AND. (cTipo == "L" .OR. (!Empty(cConteu) .AND. cTipo == "C"))
        dbSelectArea("SX6")
        dbSetOrder(1)

        If !PutMv(Alltrim(cParam), Alltrim(cConteu))
            SX6->(RecLock("SX6",.T.))
            SX6->X6_FIL		:= xFilial("SX6")
            SX6->X6_VAR		:= Alltrim(cParam)
			SX6->X6_TIPO 	:= Alltrim(cTipo)
            SX6->X6_DESCRIC := Alltrim(cDesc)
            SX6->X6_CONTEUD := Alltrim(cConteu)
            SX6->X6_CONTSPA := Alltrim(cConteu)
            SX6->X6_CONTENG := Alltrim(cConteu)
            SX6->X6_PROPRI	:= "S"
            SX6->(MsUnLock())
        EndIf
    Endif
Return


/*/{Protheus.doc} function fSetErrorHandler
Tratamento de Erros
@author  Hugo de Oliveira
@since   23/11/2020
@version 12.1.25
/*/
Function fSetErrorHandler(cTitle)
	bError  	:= { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
	bErrorBlock := ErrorBlock( bError )
Return .T.


/*/{Protheus.doc} function fResetErrorHandler
Tratamento de Erros
@author  Hugo de Oliveira
@since   23/11/2020
@version 12.1.25
/*/
Function fResetErrorHandler(cTitle)
	bError  	:= { |e| oError := e , Break(e) }
	bErrorBlock := ErrorBlock( bError )
Return .T.


/*/{Protheus.doc} function fGetURL
Consulta endpoints de acordo com os Inputs informados.
@author  Hugo de Oliveira
@since   23/11/2020
@version 12.1.25
aParams[1] = page
aParams[2] = pageSize
aParams[3] = order
nTypeIn = 1 - GET
nTypeIn = 2 - PUT
nTypeIn = 3 - POST
/*/
Function fGetURL(cEndPointIn, aHeaderIn, aParamsIn, nTypeIn, cBody)
  Local oInteg
	Local oUser		 		:= JsonObject():New()
	Local nX 		 			:= 1
	Local cToken   	 	:= ""
	Local cEnv		 		:= ""
	Local cPathParam 	:= ""
	Local cValue	 		:= ""
	Local aHeader    	:= {}

	DEFAULT cEndPointIn := ""
	DEFAULT aHeaderIn   := {}
	DEFAULT aParamsIn		:= {}
	DEFAULT nTypeIn 		:= 1
	DEFAULT cBody 			:= ""

	If !Empty(cEndPointIn) .AND. !Empty(aHeaderIn[1])
		cToken := fConsTKConsig()

		If !Empty(cToken)
			aadd(aHeader, "Content-Type: application/json; charset=UTF-8")
			aadd(aHeader, "Authorization: Bearer " + cToken)

			For nX := 1 To LEN(aHeaderIn[1])
				If aHeaderIn[1][nX] $ "registration|cpf|cnpj|ip"
					oUser[ALLTRIM(aHeaderIn[1][nX])] := ALLTRIM(aHeaderIn[2][nX])
				EndIf
			Next nX

			aadd(aHeader, "totvs-user: " + encode64(oUser:TOJSON()))

			cEnv := fGetURLCsg()
			If !Empty(cEnv)
				oInteg := FwRest():New(cEnv + ALLTRIM(cEndPointIn))
				
				If !Empty(aParamsIn)
					cPathParam := ""

					If LEN(aParamsIn) > 1
						For nX := 1 To LEN(aParamsIn[1])
							If nX != 1
								cPathParam += "&"
							EndIf
							
							If	VALTYPE(aParamsIn[2]) == "A"
								cValue := IIf(VALTYPE(aParamsIn[2][nX]) == "N", ALLTRIM(STR(aParamsIn[2][nX])), IIf(Empty(aParamsIn[2][nX]),"''",aParamsIn[2][nX]))
							Else
								cValue := aParamsIn[2]
							EndIf

							cPathParam 	+= aParamsIn[1][nX] + "=" + cValue
						Next nX

						oInteg:setPath("?" + cPathParam)
					Else
						oInteg:setPath("?" + aParamsIn[1][1])
					EndIf
				Else
					oInteg:setPath("?")
				EndIf

				If !Empty(cBody)
					oInteg:SetPostParams(cBody)
				EndIf

				If nTypeIn == 1
					oInteg:Get(aHeader)

				ElseIf nTypeIn == 2
					oInteg:PUT(aHeader, cBody)

				ElseIf nTypeIn == 3
					oInteg:Post(aHeader)
				EndIf
			EndIf
		EndIf
	EndIf
Return oInteg


/*/{Protheus.doc} function fCompress
Função que compacta e converte objeto JSON para String
@author  Hugo de Oliveira
@since   08/12/2020
@version 1.0
/*/
Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.
	
	// Set gzip format to Json Object
	cJson := oObj:toJSON()

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf
	
	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif
Return cComp


/*/{Protheus.doc} function fSetResp
Função que retorna response da API formatada no padrão que o front-end espera.
@author  Hugo de Oliveira
@since   29/01/2020
@version 1.0
/*/
Function fSetResp(oRet)
	Local nX 		:= 1
	Local cJson 	:= ""
	Local cTemp		:= ""
	Local oResult	:= JsonObject():New()
	Local aMessages := StrTokArr(SUBSTR(oRet:CRESULT, 2, LEN(oRet:CRESULT)-2), "}")

	If Len(aMessages) > 1
		For nX := 1 To Len(aMessages)
			aMessages[nX] += "}"
			cTemp := SUBSTR(aMessages[nX],AT('"Message\":\"', aMessages[nX])+13, LEN(aMessages[nX]))
			If !Empty(cJson)
				cJson += " "
			EndIf

			cTemp := SUBSTR(cTemp, AT(':',cTemp)+2, LEN(cTemp))
			cTemp := SUBSTR(cTemp, 0, LEN(cTemp)-19)
			cJson += cTemp
		Next nX
	Else
		oResult:fromJson(SUBSTR(oRet:CRESULT, 2, LEN(oRet:CRESULT)-2))
		cJson := oResult:GetJsonText("Message")
	EndIf

Return cJson


/*/{Protheus.doc} function fGetFolStatus
Consulta situação da folha de uma matrícula informada
@author  hugo.de.oliveira
@since   12/11/2020
@version 1.0
/*/
Function fGetFolStatus(cMatricula, cfilMat)
	Local cSituacao	:= ""
	Local cAlias 	:= "SRA"

	If !Empty(cMatricula)
		(cAlias)->(dbSetOrder(1)) // Filial, Matrícula

		If (cAlias)->(dbSeek(xFilial(cAlias, cfilMat) + ALLTRIM(cMatricula)))
			cSituacao := (cAlias)->RA_SITFOLH
		EndIf
	EndIf
Return cSituacao


/*/{Protheus.doc} function fGetURLRac
Consulta URL do RAC
@author  alberto.ortiz
@since   21/02/2022
@version 1.0
/*/
Function fGetURLRac()
	Local cRacURL := ""
	Local cFullURL := FwTotvsAppsRegistry():GetServiceURL("rac-token")
	Local nPos := 0
	If !Empty(cFullURL)
		nPos     := At('app', cFullURL)
		cRacURL  := SUBSTR(cFullURL, 0, nPos+2)
	EndIf

	cRacURL := ALLTRIM(cRacURL)

Return cRacURL

/*/{Protheus.doc} function fGetURLCsg
Consulta URL do consignado, caso esteja em ambiente local
utiliza o appserver.ini, caso não esteja configurado
utiliza a função do frame.
@author  alberto.ortiz
@since   21/02/2022
@version 1.0
/*/
Function fGetURLCsg()
	Local cURLConsig := ""
	Local cFullURL   := ""
	Local nPos       := 0
	Local cURLLocal  := fGetURLIni()

	cFullURL   := FwTotvsAppsRegistry():GetServiceURL("consignado-parceiros")
	nPos       := At('app', cFullURL)
	cFullURL   := IIF(Empty(cFullURL), "", SUBSTR(cFullURL, 0, nPos+2))
	cURLConsig := IIF(Empty(cURLLocal), ALLTRIM(cFullURL), ALLTRIM(cURLLocal))

Return cURLConsig

/*/{Protheus.doc} function fGetURLIni
Consulta URL do Consignado local, caso esteja configurada no .ini
@author  alberto.ortiz
@since   21/02/2022
@version 1.0
/*/
Function fGetURLIni()
  Local cServerIni := GetAdv97()
  Local cSecao := "CONSIGNADO"
  Local cPadrao := ""
  Local cChave := "URL"
  Local cURLLocal := ""
  
  cURLLocal := GetPvProfString(cSecao, cChave, cPadrao, cServerIni)

Return cURLLocal


/*/{Protheus.doc} function SplitArray(aBranch, aSize)
Divide o array informado em arrays menores com o tamanho informado.
@author  hugo.de.oliveira
@since   11/04/2022
@version 1.0
/*/
Function SplitArray(aArray, nSize)
	Local aClone    := {}
	Local aArrays   := {}
	Local nFullSize := 0
	Local nX 	 	:= 1
	Local nPosIni 	:= 1

	DEFAULT aArray := {}
	DEFAULT nSize  := 0

	nFullSize := Len(aArray)

	If nFullSize < nSize
		aClone := fFillClone(aArray, nPosIni, nSize)
		aadd(aArrays, aClone)
	Else
		nQtde := Round((nFullSize / nSize), 0)
		For nX := 1 To nQtde
			aClone := fFillClone(aArray, nPosIni, nSize)
			aadd(aArrays, aClone)
			nPosIni += nSize
		Next nX
	EndIf
Return aArrays


Function fFillClone(aArray, nStart, nSize)
	Local nX 	 := nStart
	Local aClone := {}
	Local nEndPos := nStart + (nSize - 1)

	For nX := nStart To nEndPos
		If nX > Len(aArray)
			Exit
		EndIf
		Aadd(aClone, aArray[nX])
	Next nX
Return aClone


Function fSelAllMBrowse(oMBrowse)
	Local nLast

	oMBrowse:GoBottom(.F.)
	nLast := oMBrowse:At()
	oMBrowse:GoTop()
	
	While .T.
		oMBrowse:MarkRec()
		If nLast == oMBrowse:At()
			oMBrowse:GoTop()
			Exit
		EndIf
		oMBrowse:GoDown()
	EndDo
Return
