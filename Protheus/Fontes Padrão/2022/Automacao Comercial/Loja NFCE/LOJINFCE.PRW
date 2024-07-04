#INCLUDE "TOTVS.CH"
#INCLUDE "AUTODEF.CH"

/*Classe para metodos relativos a impressão da NFC-e*/
Class LOJINFCE
	Data lIsPos			// é totvsPDV ?
	Data lCondensa		// texto condensado ?
	Data lConting 		// Esta trabalhando em Contigencia da NFC-e
	Data lEstCont 		// Estado (UF) permite contigencia
	Data cMsgConting	// Mensagem da Contigencia
	
	Method New()
	Method ImpMsgCon(lContigen, cTexto, nRetImp)
	Method RetMsgCon(lContigen)
	Method ImpTexto(cTexto,nVias,nRetImp)
	Method ImpCompCnc(cPDV, cDoc, cSerie, dData, cHora)
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} LNfceTemCo
Valida se o estado permite a impressão da 2 via em contingência
@param   cMV_LJ2VCON , caracter, retorno do parametro MV_LJ2VCON
@author  Julio Nery Jr.
@since   05/08/2019
@version P12
@return  cTexto, string, texto a ser impresso
/*/
//-------------------------------------------------------------------
Function LNfceTemCo()
Local cMV_LJ2VCON := SuperGetMV("MV_LJ2VCON",,"AM|RJ")
Local lTemContin  := SM0->M0_ESTCOB $ cMV_LJ2VCON
Return lTemContin

//-------------------------------------------------------------------
/*/{Protheus.doc} New
@author  Julio Nery Jr.
@since   08/08/2019
@version P12
@return  Self, classe
/*/
//-------------------------------------------------------------------
Method New() Class LOJINFCE
Local cModelo := ""

::lIsPos	:= STFIsPOS()

cModelo		:= AllTrim( IIF(::lIsPos, STFGetStation("IMPFISC"), LJGetStation("IMPFISC")) )
::lCondensa	:= SuperGetMV("MV_LJCONDE",,.F.) .OR. IIf("EPSON" $ cModelo, .T., .F.)

::lConting	:= .F.
::lEstCont	:= LNfceTemCo()
::cMsgConting	:= ""

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpMsgCon
Emite impressão de segunda via em contingencia da NFC-e
@param	 cTexto, string, texto a ser impresso
@param   nVias, numerico, qtde de vias
@author  Julio Nery Jr.
@since   05/08/2019
@version P12
@return  lRet, logico, executa impressao de contingencia ou não ?
/*/
//-------------------------------------------------------------------
Method ImpTexto(cTexto,nVias,nRetImp)  Class LOJINFCE
Local lRet	:= .F.
Local nX	:= 0

Default nVias := 1

If !Empty(AllTrim(cTexto))
	For nX := 1 to nVias
		If ::lIsPos
			nRetImp := STWPrintTextNotFiscal(cTexto)
		Else
			nRetImp := INFTexto(cTexto)
		EndIf
		
		If nRetImp == 0
			lRet := .T.
		Else
			lRet := .F.
			Exit
		EndIf
	Next nX
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpMsgCon
Emite impressão de segunda via em contingencia da NFC-e
@param   lContigen , logico, esta em contingencia ?
@param	 cTexto, string, texto a ser impresso
@param   nRetImp, numerico, retorno da impressora
@author  Julio Nery Jr.
@since   05/08/2019
@version P12
@return  lRet, logico, executa impressao de contingencia ou não ?
/*/
//-------------------------------------------------------------------
Method ImpMsgCon(lContigen, cTexto, nRetImp)  Class LOJINFCE
Local lRet		:= .F.
Local cTextoAux	:= ""

::lConting := lContigen

If ::lEstCont .And. ::lConting
		
	If Empty(AllTrim(::cMsgConting))
		Self:RetMsgCon(.T.)
	EndIf
	
	cTextoAux := StrTran(cTexto,::cMsgConting,"")
	
	lRet := ::ImpTexto(cTextoAux,1,@nRetImp)
	If lRet
		lRet := ::ImpTexto(cTexto,1,@nRetImp)
	EndIf

	::cMsgConting := ""
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetMsgCon
Retorna mensagem de segunda via em contingencia da NFC-e
@param   lContigen , logico, esta em contingencia ?
@author  Julio Nery Jr.
@since   05/08/2019
@version P12
@return  cTexto, string, texto a ser impresso
/*/
//-------------------------------------------------------------------
Method RetMsgCon(lContigen) Class LOJINFCE
Local cTexto		:= ""
Local cCrLf			:= Chr(10)
Local cTagCondIni	:= ""
Local cTagCondFim	:= ""

::lConting := lContigen

If ::lEstCont .And. ::lConting
	cTagCondIni := Iif(::lCondensa, TAG_CONDEN_INI , "")
	cTagCondFim := Iif(::lCondensa, TAG_CONDEN_FIM , "")
	
	cTexto := cTagCondIni
	cTexto += TAG_CENTER_INI + TAG_NEGRITO_INI + "VIA DO ESTABELECIMENTO" + TAG_NEGRITO_FIM + TAG_CENTER_FIM 
	cTexto += cTagCondFim	
	cTexto += cCrLf
	::cMsgConting := cTexto
Else
	::cMsgConting := ""
EndIf

Return cTexto

//----------------------------------------------------------------
/*/{Protheus.doc} ImpCompCnc
Impressao do comprovante de solicitacao de cancelamento da NFC-e.
Imprime um simples comprovante de Solicitacao de Cancelamento da NFC-e.
@param	 cPDV 		Numero do PDV
@param	 cDOC		Numero do Documento
@param	 cSerie		Numero de Serie do Documento
@param	 dData		Data da solicitacao do Cancelamento
@param	 cHora		Hora da solicitacao do Cancelamento
@return	 nRet		nRet = 0 (Sucesso na impressao);  nRet <> 0 (erro na impressao)
@author  Varejo
@version P11.8
@since   24/05/2016
/*/
//------------------------------------------------------------------
Method ImpCompCnc(cPDV, cDoc, cSerie, dData, cHora) Class LOJINFCE
Local nRet 			:= 0
Local nSaltoLn		:= SuperGetMV("MV_FTTEFLI",, 1)		// Linha pula entre comprovante
Local lGuil			:= SuperGetMV("MV_FTTEFGU",, .T.)	// Ativa guilhotina
Local cCrLf			:= Chr(10)
Local cTagCondIni	:= Iif(::lCondensa, TAG_CONDEN_INI , "")
Local cTagCondFim	:= IIf(::lCondensa, TAG_CONDEN_FIM , "")
Local cTracejado 	:= IIf(::lCondensa, Replicate("-",56),Replicate("-",31))
Local cLinha		:= TAG_CENTER_INI + cTagCondIni + cTracejado + cTagCondFim + TAG_CENTER_FIM + cCrLf
Local cTexto 		:= ""
Local nX 			:= 0
Local cModDoc 		:= ""

Default dData 	:= DToC(dDatabase)
Default cHora	:= Time()

cModDoc := Substr( RetField("SL1",2,xFilial("SL1") + cSerie + cDoc, "L1_KEYNFCE" ), 21,2) 

//-------------------------
// Dados da empresa
//-------------------------
cTexto += cTagCondIni + AllTrim(SM0->M0_NOMECOM) + cCrLf 						//Denominação
cTexto += AllTrim("CNPJ:" + SM0->M0_CGC + " / IE:" + SM0->M0_INSC) + cCrLf		//CNPJ //Inscrição Estadual
cTexto +=	AllTrim(SM0->M0_ENDENT) + ;											//Endereco
			AllTrim(SM0->M0_BAIRENT) + "," + ;
			AllTrim(SM0->M0_CIDENT) + ", " + ;
			AllTrim(SM0->M0_ESTENT) + cTagCondFim + cCrLf
cTexto += cLinha

//-------------------------
// Cabecalho do Comprovante
//-------------------------
cTexto += TAG_CENTER_INI + cTagCondIni + iif(cModDoc=="65","NFC-e","NF-e") + cTagCondFim + TAG_CENTER_FIM + cCrLf
cTexto += TAG_CENTER_INI + cTagCondIni + "SOLICITACAO DE CANCELAMENTO" + cTagCondFim + TAG_CENTER_FIM + cCrLf
cTexto += cLinha

//-------------------------
// Corpo do Comprovante
//-------------------------		
cTexto += "PDV: " + PadR(cPDV,4) + Space(6) + "Data: " + DToC(dData) + " Hora: " + cHora + Replicate(cCrLf,2)
cTexto += "Enviada a solicitação de cancelamento de " + iif(cModDoc=="65","NFC-e","NF-e") + "."+ Replicate(cCrLf,2)
cTexto += "Numero: " + cDoc + " / Serie: " + cSerie + Replicate(cCrLf,2)
cTexto += cLinha

//Salta linha extra
For nX := 1 to nSaltoLn
	cTexto += cCrLf
Next nX

If lGuil
	cTexto += TAG_GUIL_INI+TAG_GUIL_FIM		//Corte de Papel
EndIf

::ImpTexto(cTexto,1,@nRet)

If nRet <> 0
	MsgStop("Ocorreu problema na impressão do comprovante de Solicitação de Cancelamento da NFC-e: " + cDoc + " / Serie: " + cSerie)
	LjGrvLog( NIL, "Ocorreu problema na impressão do comprovante de Solicitação de Cancelamento da NFC-e: " + cDoc + " / Serie: " + cSerie)
EndIf

Return nRet