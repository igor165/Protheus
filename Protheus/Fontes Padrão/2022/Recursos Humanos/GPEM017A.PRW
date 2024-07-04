#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM017.CH"

Static nTamRJEKey	:= 0
Static lParcial		:= .F.
Static lVerRJ5

//-------------------------------------------------------------------
/*/{Protheus.doc} function GPEM017A
Fonte para biblioteca de funções utilizadas na integração com o Middleware
@author  Allyson Mesashi
@since   16/07/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Function GPEM017A()
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} function GetInfRJE
Função que busca as informações do registro na RJE
@author  Allyson Mesashi
@since   16/07/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Function GetInfRJE( nOrdem, cChave, cStatRJE, cOperRJE, cRetfRJE, nRecnRJE, cRecibo, cRecAnt, lVldFil, cVldFil, lVldS3000, cDtIni)

Local aArea			:= GetArea()
Local cIndex		:= ""
Local cStat3000		:= "-1"
Local nLenChave		:= 0

Default nOrdem		:= 1
Default cChave		:= ""
Default cStatRJE	:= "-1"
Default cOperRJE	:= "I"
Default cRetfRJE	:= "1"
Default nRecnRJE	:= 0
Default cRecibo		:= ""
Default cRecAnt		:= ""
Default lVldFil 	:= .F.
Default cVldFil		:= cFilAnt
Default lVldS3000 	:= .F.
Default cDtIni		:= ""

dbSelectArea("RJE")
RJE->( dbSetOrder(nOrdem) )

cIndex 		:= RJE->( IndexKey(nOrdem) )
nLenChave	:= Len(cChave)

If RJE->( dbSeek(cChave) )
	While RJE->( !EoF() ) .And. SubStr( &(cIndex), 1, nLenChave ) == cChave
		If RJE->RJE_EXC != "1" .And. (!lVldFil .Or. lVldFil .And. cVldFil == RJE->RJE_FIL)
			cStatRJE := RJE->RJE_STATUS
			cOperRJE := RJE->RJE_OPER
			cRetfRJE := RJE->RJE_RETF
			cRecibo  := AllTrim(RJE->RJE_RECIB)
			cRecAnt  := AllTrim(RJE->RJE_RECANT)
			cDtIni	 := RJE->RJE_INI
			nRecnRJE := RJE->( Recno() )
		EndIf
		RJE->( dbSkip() )
	End
EndIf

If lVldS3000 .And. !Empty(cRecibo)
	GetInfRJE( 4, "S3000"+cRecibo, @cStat3000 )
	If cStat3000 == "4"
		cStatRJE	:= "-1"
		cOperRJE	:= "I"
		cRetfRJE	:= "1"
		cRecibo  	:= ""
		cRecAnt  	:= ""
		nRecnRJE	:= 0
	ElseIf cStat3000 != "-1"
		cStatRJE := "99"
	EndIf
EndIf

RestArea(aArea)

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGravaRJE
Função que grava os dados na RJE
@author  Allyson Mesashi
@since   16/07/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fGravaRJE( aDados, cXML, lNovo, nRecRJE )

Local aArea			:= GetArea()
Local lRet			:= .T.
Local cTpAfa		:= ""
Local dDtEve		:= CTOD("//")
Local lCpoFil		:= RJE->(ColumnPos("RJE_DTEVE")) > 0

Default aDados 		:= {}
Default cXML 		:= ""
Default lNovo 		:= .T.
Default nRecRJE 	:= 1

//Caso encontre o campo RJE_DTEVE procura a data de alteração do evento
If lCpoFil .And. !Empty(aDados) .And. (aDados[1, 05] == "S2230" .Or. aDados[1, 05] == "S2200")
	fGetAltXML(aDados[1, 05], cXML, @cTpAfa, @dDtEve, aDados[1, 07])
EndIf

If !Empty(aDados)
	If !lNovo
		RJE->( dbGoTo(nRecRJE) )
	EndIf
	If RJE->( Reclock("RJE", lNovo) )
		RJE->RJE_FILIAL	:= aDados[1, 01]
		RJE->RJE_FIL	:= aDados[1, 02]
		RJE->RJE_TPINSC	:= aDados[1, 03]
		RJE->RJE_INSCR	:= aDados[1, 04]
		RJE->RJE_EVENTO	:= aDados[1, 05]
		RJE->RJE_INI	:= aDados[1, 06]
		RJE->RJE_KEY	:= aDados[1, 07]
		RJE->RJE_RETKEY	:= aDados[1, 08]
		RJE->RJE_RETF	:= aDados[1, 09]
		RJE->RJE_VERS	:= aDados[1, 10]
		RJE->RJE_STATUS	:= aDados[1, 11]
		RJE->RJE_XML	:= cXML
		RJE->RJE_DTG	:= aDados[1, 12]
		RJE->RJE_HORAG	:= aDados[1, 13]
		RJE->RJE_OPER	:= aDados[1, 14]
		If Len(aDados[1]) >= 15
			RJE->RJE_RECIB	:= aDados[1, 15]
			RJE->RJE_RECANT	:= aDados[1, 16]

 			// USADO PARA IMPORTAÇÃO DE TERCEIROS (GPEM017F).
			If RJE->(ColumnPos("RJE_IDMDEV")) > 0 .And. Len(aDados[1]) > 16
				RJE->RJE_IDMDEV	:= aDados[1, 17]
			EndIf
		EndIf
		If lCpoFil .And. !Empty(dDtEve)
			RJE->RJE_DTEVE	:= dDtEve
			RJE->RJE_TPAFA	:= cTpAfa
		EndIf
		RJE->RJE_USRXML	:= ""
		RJE->( MsUnlock() )
	Else
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} function fExcluiRJE
Função que exclui os dados na RJE
@author  Allyson Mesashi
@since   16/07/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fExcluiRJE( nRecRJE )

Local aArea			:= GetArea()
Local lRet			:= .T.

Default nRecRJE 	:= 0

If nRecRJE > 0
	RJE->( dbGoTo(nRecRJE) )
	If RJE->( Reclock("RJE", .F.) )
		RJE->( dbDelete() )
		RJE->( MsUnlock() )
	Else
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} function fXMLIdEve
Função que gera no XML o grupo de tags ideEvento
@author  Allyson Mesashi
@since   16/07/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fXMLIdEve( cXML, aArray, cVersEnvio, aInfos )

Local aArea		:= GetArea()
Local aCabec 	:= {"indRetif", "nrRecibo", "indApuracao", "perApur", "tpAmb", "procEmi", "verProc"} // N C N C N N C
Local nCont		:= 0
Local lRescisao := IsInCallStack("fInt2299") .Or. IsInCallStack("fTrf2299")
Local nPosIGuia := IIf(lRescisao, 3, 5) // Ordem da tag <indGuia> dentro do grupo: se for rescisão gera após <nrRecibo> e nos demais casos gera após <perApur>

Default cXML	:= ""
Default aArray	:= ""
Default cVersEnvio := ""
Default aInfos	:= fXMLInfos()

Private lIndGuia := (cVersEnvio >= "9.0.00" .And. Len(aInfos) >= 5 .And. aInfos[5] $ "21*22")

cXml += '<ideEvento>'

For nCont := 1 to Len(aArray)
	If nCont > Len(aCabec)
		Exit
	EndIf
	If nCont == nPosIGuia
		If lIndGuia
			cXml += "<indGuia>" + "1" + "</indGuia>"
		EndIf
	EndIf
	If aArray[nCont] == Nil
		Loop
	EndIf
	If aCabec[nCont] == "tpAmb"
		cXml += '<' + Alltrim(aCabec[nCont]) + '>' + AllTrim(SuperGetMv('MV_GPEAMBE',, "2")) + '</' + Alltrim(aCabec[nCont]) + '>'
		Loop
	EndIf

	If ValType(aArray[nCont]) == 'D'
		cXml += '<' + Alltrim(aCabec[nCont]) + '>' + dToC(aArray[nCont]) + '</' + Alltrim(aCabec[nCont]) + '>'
	EndIf
	If ValType(aArray[nCont]) == 'N'
		cXml += '<' + Alltrim(aCabec[nCont]) + '>' + Alltrim(STR(aArray[nCont] )) + '</' + Alltrim(aCabec[nCont]) + '>'
	EndIf
	If ValType(aArray[nCont]) == 'C'
		cXml += '<' + Alltrim(aCabec[nCont]) + '>' + aArray[nCont] + '</' + Alltrim(aCabec[nCont]) + '>'
	EndIf
Next

cXml += '</ideEvento>'

RestArea(aArea)

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} function fXMLIdEmp
Função que gera no XML o grupo de tags ideEmpregador
@author  Allyson Mesashi
@since   16/07/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fXMLIdEmp( cXML, aArray )

Local aArea		:= GetArea()
Local aCabec 	:= {"tpInsc", "nrInsc"} // N C
Local nCont		:= 0

Default cXML	:= ""
Default aArray	:= ""

cXml += '<ideEmpregador>'

For nCont := 1 to Len(aArray)
	If nCont > Len(aCabec)
		Exit
	EndIf
	If aArray[nCont] == Nil
		Loop
	EndIf
	If ValType(aArray[nCont]) == 'D'
		cXml += '<' + Alltrim(aCabec[nCont]) + '>' + dToC(aArray[nCont]) + '</' + Alltrim(aCabec[nCont]) + '>'
	EndIf
	If ValType(aArray[nCont]) == 'N'
		cXml += '<' + Alltrim(aCabec[nCont]) + '>' + Alltrim(STR(aArray[nCont] )) + '</' + Alltrim(aCabec[nCont]) + '>'
	EndIf
	If ValType(aArray[nCont]) == 'C'
		cXml += '<' + Alltrim(aCabec[nCont]) + '>' + aArray[nCont] + '</' + Alltrim(aCabec[nCont]) + '>'
	EndIf
Next

cXml += '</ideEmpregador>'

RestArea(aArea)

Return( )


//-------------------------------------------------------------------
/*/{Protheus.doc} function fXMLInfos
Função que retornar o ID do cabecalho do XML, tipo de inscr e numero
@author  Gisele Nuncherino
@since   29/07/2019
@version V 1.0

A identificação única do evento (Id) é composta por 36 caracteres, conforme o que segue:

IDTNNNNNNNNNNNNNNAAAAMMDDHHMMSSQQQQQ

ID - Texto Fixo "ID";

T - Tipo de Inscrição do Empregador (1 - CNPJ; 2 - CPF);

NNNNNNNNNNNNNN - Número do CNPJ ou CPF do empregador - Completar com
zeros à direita. No caso de pessoas jurídicas, o CNPJ informado deve conter 8 ou 14
posições de acordo com o enquadramento do contribuinte para preenchimento do campo
{ideEmpregador/nrInsc} do evento S-1000, completando-se com zeros à direita, se
necessário.

AAAAMMDD - Ano, mês e dia da geração do evento;

HHMMSS - Hora, minuto e segundo da geração do evento;

QQQQQ - Número sequencial da chave. Incrementar somente quando ocorrer geração de
eventos na mesma data/hora, completando com zeros à esquerda.
OBS.: No caso de pessoas jurídicas, o CNPJ informado deverá conter 8 ou 14 posições de
acordo com o enquadramento do contribuinte para preenchimento do campo
{ideEmpregador/nrInsc} do evento S-1000, completando-se com zeros à direita, se
necessário.
/*/
//-------------------------------------------------------------------

Function fXMLInfos( cPeriodo )

Local aArea		:= GetArea()
Local cID 		:= "ID"
Local cMsgErro	:= ""
Local aInfos	:= {} // ID, TIPO INSCRICAO, NUMERO INSCRICAO
Local cSeq		:= ""
Local cTempo	:= Time()
Local dData		:= Date()

Default cPeriodo := AnoMes(dDatabase)

If !ChkFile("RJ9")
	cMsgErro := CRLF + OemToAnsi(STR0245) + CRLF //"Tabela RJ9 não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
	return
EndIf

RJ9->( dbSetOrder(5) )
If ( RJ9->( dbSeek( AllTrim(SM0->M0_CGC) ) ) .Or. (RJ9->( dbSeek( SubStr(SM0->M0_CGC, 1, 8) ) ) .And. RJ9->RJ9_TPINSC == "1" .And. !(RJ9->RJ9_NATJ $ "101-5/104-0/107-4/116-3")) ) .And. RJ9->RJ9_INI <= cPeriodo
	cSeq	:= StrZero(Randomize(1, 99999), 5)
	CID 	+= RJ9->RJ9_TPINSC + PadR( Iif( RJ9->RJ9_TPINSC == "1" .And. !(RJ9->RJ9_NATJ $ "101-5/104-0/107-4/116-3"), SubStr(RJ9->RJ9_NRINSC, 1, 8), AllTrim(RJ9->RJ9_NRINSC) ), 14, "0") + dToS(dData) + StrTran(cTempo, ":", "") + cSeq
	aInfos 	:= { RJ9->RJ9_TPINSC, RJ9->RJ9_NRINSC, cID, (RJ9->RJ9_NATJ $ "101-5/104-0/107-4/116-3"), RJ9->RJ9_CLASS }
EndIf

RestArea(aArea)

Return(aInfos)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fVld1000
Função que busca a existência do evento S-1000 transmitido na tabela RJE
@author  Allyson Mesashi
@since   08/08/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fVld1000( cPeriodo, cStatRJE, cFilEmp, cEmpP )

Local aArea		 := GetArea()
Local aSM0    	 := FWLoadSM0(.T.,,.T.)
Local cOperRJE	 := "I"
Local lOk		 := .F.
Local nFilEmp	 := 0

Default cFilEmp	 := cFilAnt
Default cPeriodo := AnoMes(dDatabase)
Default cStatRJE := "-1"
Default cEmpP 	 := cEmpAnt

RJ9->( dbSetOrder(5) )
If ( RJ9->( dbSeek( AllTrim(SM0->M0_CGC) ) ) .Or. (RJ9->( dbSeek( SubStr(SM0->M0_CGC, 1, 8) ) ) .And. RJ9->RJ9_TPINSC == "1" .And. !(RJ9->RJ9_NATJ $ "101-5/104-0/107-4/116-3")) ) .And. RJ9->RJ9_INI <= cPeriodo
	If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpP .And. X[18] == AllTrim(RJ9->RJ9_NRINSC) }) ) > 0
		cFilEmp := aSM0[nFilEmp, 2]
	Else
		cFilEmp := cFilAnt
	EndIf
	GetInfRJE( 2, RJ9->RJ9_TPINSC + PadR( Iif( RJ9->RJ9_TPINSC == "1" .And. !(RJ9->RJ9_NATJ $ "101-5/104-0/107-4/116-3"), SubStr(RJ9->RJ9_NRINSC, 1, 8), AllTrim(RJ9->RJ9_NRINSC) ), 14, " ") + "S1000" + Padr(cFilEmp, fTamRJEKey(), " ") + RJ9->RJ9_INI, @cStatRJE, @cOperRJE )
	If cStatRJE == "4" .And. cOperRJE != "E"
		lOk := .T.
	EndIf
EndIf

RestArea(aArea)

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} function fVerMW
Função que verifica se utiliza Middleware
@author  Allyson Mesashi
@since   12/08/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fVerMW()

Local lMW 	:= SuperGetMv("MV_MID",, .F.)

Return lMW

//-------------------------------------------------------------------
/*/{Protheus.doc} function fPosFil
Função que força o posicionamento da SM0
@author  Allyson Mesashi
@since   19/08/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fPosFil( cEmp, cFil )

Default cEmp	:= cEmpAnt
Default cFil	:= cFilAnt

SM0->( dbSetOrder(1) )
SM0->( dbSeek( cEmp + cFil ) )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} function fVldPred
Função que busca a existência dos eventos predecessores do S-2200 na tabela RJE
@author  Allyson Mesashi
@since   28/08/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fVldPred( cPeriodo, cStatRJE, cChave )

Local aArea		 := GetArea()
Local cOperRJE	 := "I"
Local lOk		 := .F.

Default cPeriodo := AnoMes(dDatabase)
Default cStatRJE := "-1"
Default cChave 	 := ""

dbSelectArea("RJE")
RJE->( dbSetOrder(2) )

cIndex 		:= RJE->( IndexKey(2) )
nLenChave	:= Len(cChave)

If RJE->( dbSeek(cChave) )
	While RJE->( !EoF() ) .And. SubStr( &(cIndex), 1, nLenChave ) == cChave
		If RJE->RJE_INI <= cPeriodo
			cStatRJE := RJE->RJE_STATUS
			cOperRJE := RJE->RJE_OPER
			lOk := .T.
		EndIf
		RJE->( dbSkip() )
	End
EndIf

RestArea(aArea)

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} function fPred2299
Função que busca a existência dos eventos predecessores do S-2299/S-2399 na tabela RJE
@author  Allyson Mesashi
@since   06/09/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fPred2299( cPeriodo, aErros, cRegistro, lOk, aDados, lAdmPubl, cTpInsc, cNrInsc )

Local aArea		 	:= GetArea()
Local cChaveMid	 	:= ""
Local cKeyMid		:= ""
Local cStatus	 	:= "I"
Local nCont	 		:= 0

Default cPeriodo 	:= AnoMes(dDatabase)
Default aErros 	 	:= "-1"
Default cRegistro	:= ""
Default lOk 	 	:= .F.
Default aDados 	 	:= {}
Default lAdmPubl 	:= .F.
Default cTpInsc 	:= ""
Default cNrInsc 	:= ""
Default lVerRJ5		:= (fVldObraRJ(@lParcial, .F.) .And. !lParcial)

For nCont := 1 To Len(aDados)
	If cRegistro == "S1005"
		cKeyMid		:= aDados[nCont, 5]
	ElseIf cRegistro == "S1010"
		cKeyMid		:= xFilial("SRV", SRA->RA_FILIAL)+aDados[nCont, 3]
		If aDados[nCont, 17] <= 0
			Loop
		EndIf
	Else
		If (!lVerRJ5 .And. Empty( xFilial("CTT") )) .Or. (lVerRJ5 .And. Empty( xFilial("RJ3") ))
			cKeyMid		:= xFilial("CTT") + aDados[nCont, 4]
		Else
			cKeyMid		:= aDados[nCont, 4]
		EndIf
	EndIf
	cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + cRegistro + Padr(cKeyMid, fTamRJEKey(), " ")
	cStatus 	:= "-1"
	//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
	fVldPred( AnoMes(M->RG_DATADEM), @cStatus, cChaveMid )
	If cStatus != "4" .And. aScan(aErros, { |x| STR0267 + cKeyMid $ x }) == 0//"Chave: "
		lOk := .F.
		Do Case
			Case cStatus == "-1" // nao encontrado na base de dados
				aAdd( aErros, STR0267 + cKeyMid + ". " + OemToAnsi(STR0268) + "S-"+SubStr(cRegistro, 2) + OemToAnsi(STR0269) )//"Chave: "##"Registro do evento X-XXXX não localizado na base de dados"
			Case cStatus == "1" // nao enviado para o governo
				aAdd( aErros, STR0267 + cKeyMid + ". " + OemToAnsi(STR0268) + "S-"+SubStr(cRegistro, 2) + OemToAnsi(STR0270) )//"Chave: "##"Registro do evento X-XXXX não transmitido para o governo"
			Case cStatus == "2" // enviado e aguardando retorno do governo
				aAdd( aErros, STR0267 + cKeyMid + ". " + OemToAnsi(STR0268) + "S-"+SubStr(cRegistro, 2) + OemToAnsi(STR0271) )//"Chave: "##"Registro do evento X-XXXX aguardando retorno do governo"
			Case cStatus == "3" // enviado e retornado com erro
				aAdd( aErros, STR0267 + cKeyMid + ". " + OemToAnsi(STR0268) + "S-"+SubStr(cRegistro, 2) + OemToAnsi(STR0272) )//"Chave: "##"Registro do evento X-XXXX retornado com erro do governo"
		EndCase
	EndIf
Next nCont

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetIdRJF
Função que busca a existência de um identificador de rubrica na tabela RJF
@author  Allyson Mesashi
@since   01/10/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fGetIdRJF(cFilSRV, cCodERP, lGrvNovo)

Local cIdAux		:= ""
Local cIdTabela		:= ""
Local lChangeId		:= .F.
Local lRet			:= .F.
Local oModel		:= Nil

Default cFilSRV 	:= cFilAnt
Default cCodERP 	:= ""
Default lGrvNovo 	:= .F.

RJF->( dbSetOrder(2) )
If RJF->( dbSeek( xFilial("RJF", cFilSRV) + cCodERP ) )
	cIdTabela := RJF->RJF_ID
EndIf

//Na geração do S-1010, grava um novo identificador caso não encontre registro na tabela RJF
If Empty(cIdTabela) .And. lGrvNovo
	oModel 	:= FWLoadModel("GPEA939")
	oModel:SetOperation(3)
	oModel:Activate()

	cIdAux 	:= oModel:GetModel("MODEL_RJF"):GetValue("RJF_ID", "GPEA939")

	RJF->( dbSetOrder(1) )
	//Percorre o laço enquanto não encontrar o próximo numero disponivel no license.
	While RJF->( dbSeek( xFilial("RJF", cFilSRV) + cIdAux ) )
		RJF->( ConfirmSX8() )
		cIdAux 		:= GetSx8Num("RJF", "RJF_ID")
		lChangeId 	:= .T.
	EndDo

	If lChangeId
		oModel:LoadValue("MODEL_RJF", "RJF_ID", cIdAux )
	EndIf

	oModel:LoadValue( "MODEL_RJF", "RJF_FILIAL", xFilial( "RJF", cFilSRV ) )
	oModel:LoadValue( "MODEL_RJF", "RJF_CODERP", cCodERP )

	lRet := FWFormCommit( oModel )

	If lRet
		cIdTabela := cIdAux
	EndIf

	oModel:DeActivate()
	oModel     := Nil
EndIf

Return cIdTabela

//-------------------------------------------------------------------
/*/{Protheus.doc} function fVerPred
Função que busca a existência dos eventos predecessores na tabela RJE
@author  Allyson Mesashi
@since   08/10/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fValPred(cKeyMid, cRegistro, cPeriodo, aErros, lAdmPubl, cTpInsc, cNrInsc )

Local cChaveMid		:= ""
Local cStatus 		:= "-1"

Default cKeyMid		:= ""
Default cRegistro	:= ""
Default cPeriodo	:= ""
Default aErros		:= {}
Default lAdmPubl	:= .F.
Default cTpInsc		:= ""
Default cNrInsc		:= ""

cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + cRegistro + Padr(cKeyMid, fTamRJEKey(), " ")
//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
fVldPred( cPeriodo, @cStatus, cChaveMid )
If cStatus != "4" .And. aScan(aErros, { |x| STR0267 + cKeyMid $ x }) == 0//"Chave: "
	Do Case
		Case cStatus == "-1" // nao encontrado na base de dados
			aAdd( aErros, STR0267 + cKeyMid + ". " + OemToAnsi(STR0268) + "S-"+SubStr(cRegistro, 2) + OemToAnsi(STR0269) )//"Chave: "##"Registro do evento X-XXXX não localizado na base de dados"
		Case cStatus == "1" // nao enviado para o governo
			aAdd( aErros, STR0267 + cKeyMid + ". " + OemToAnsi(STR0268) + "S-"+SubStr(cRegistro, 2) + OemToAnsi(STR0270) )//"Chave: "##"Registro do evento X-XXXX não transmitido para o governo"
		Case cStatus == "2" // enviado e aguardando retorno do governo
			aAdd( aErros, STR0267 + cKeyMid + ". " + OemToAnsi(STR0268) + "S-"+SubStr(cRegistro, 2) + OemToAnsi(STR0271) )//"Chave: "##"Registro do evento X-XXXX aguardando retorno do governo"
		Case cStatus == "3" // enviado e retornado com erro
			aAdd( aErros, STR0267 + cKeyMid + ". " + OemToAnsi(STR0268) + "S-"+SubStr(cRegistro, 2) + OemToAnsi(STR0272) )//"Chave: "##"Registro do evento X-XXXX retornado com erro do governo"
	EndCase
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} function MidEXCPER
Função
@author  Silvia Taguti
@since   21/10/2019
@version V 1.0
/*/
//-------------------------------------------------------------------

Function MidEXCPER(aPar, cFilExcl, lSkipAlert, aTipos)

Local aRet       	:= {}
Local oProcessFil	:= Nil
Local lRet 			:= .T.

Default cTipos		:=  ""
Default lSkipAlert		:= .F.

oProcessFil := TAFProgress():New( { |lEnd| aRet := fLimpLoteRJE(@lEnd, @oProcessFil, aPar, cFilExcl, aTipos, lSkipAlert) }, OemToAnsi(STR0294), .F. )   //"Processando Exclusão"
oProcessFil:Activate()

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fExcLoteRJE
Função Função para Limpeza de Base - Tabela RJE
@author  Silvia Taguti
@since   21/10/2019
@version V 1.0
/*/
//-------------------------------------------------------------------

Function fLimpLoteRJE( lEnd, oProcessFil, aPar, cFilMid, aTipos, lSkipAlert)

Local aAreaRJE  	:= RJE->(GetArea())
Local lRet			:= .T.
Local cAmbEsocial   := ''
Local cAliasRJE     := "QRJE"
Local nFilSel		:= 0
Local aEmpAux		:= {}
Local aLisFil		:= {}
Local aRet       	:= {}
Local nQtdReg		:= 0
Local cQuery		:= ""
Local cFilComp      := "S-2200|S-2100|S-2300"
Local cFilSGY	    := "S-1035"
Local cFilCargFunc	:= "S-1030|S-1040"
Local nTp			:= 0
Local cFilEvent		:= ""
Local cMensagem  	:= ''
Local lCargSQ3		:= SuperGetMv("MV_CARGSQ3",, .F.) //Define se o envio do evento S-1030 serão feito pela tabela SQ3 e não pela SRJ (Padrão .F. -> SRJ).

Default aPar		:= {}
Default cTipos		:= ""
Default lSkipAlert		:= .F.

//Verifica se a Empresa está Operando em Produção
cAmbEsocial := GetNewPar( "MV_GPEAMBE", "3" )

If lMsgRJE
	If !Empty(cMensagem)
		cMensagem += CRLF+CRLF
	endif
	cMensagem += OemToAnsi(STR0289)
	cMensagem += CRLF+ OemToAnsi(STR0290)   //"Empresa operando em "
	If cAmbEsocial == '1' //1-Produção
		cMensagem += OemToAnsi(STR0291)		//"Produção"
	ElseIf cAmbEsocial == '2' 				//2-Pré Produção - Dados Reais
		cMensagem += OemToAnsi(STR0292)		//"Pré Produção - Dados Reais"
	ElseIf cAmbEsocial == '3' 				//3-Pré Produção - Dados Fictícios
		cMensagem += OemToAnsi(STR0293)		//"Pré Produção - Dados Fictícios"
	EndIf

	cMensagem += CRLF
	cMensagem += OemToAnsi(STR0295)			//"Esse processo excluirá todos os registros "
	If cAmbEsocial == '1' //1-Produção
		cMensagem += OemToAnsi(STR0296)		//"não transmitidos "
	EndIf
	cMensagem += OemToAnsi(STR0297)			//"das tabelas de movimentação do eSocial desconsiderando o período de data."
	cMensagem += CRLF+CRLF

	If lSkipAlert
		lRet := .F.
	Else
		If Aviso(OemToAnsi(STR0298), cMensagem, {OemToAnsi(STR0299),OemToAnsi(STR0300)}, 3) == 1    //"Exclusão "  //
			lRet := .T.
		EndIf
	EndIf
	lMsgRJE := .F.
Endif

If lRet
	//Guardo a filial corrente que esta logado para restaurar no final do processo

	aAdd( aEmpAux , { cEmpAnt , cFilAnt } )

	aAdd( aLisFil, { .T., cFilMid } )

	dbSelectArea("RJE")
	RJE->( dbSetOrder(1) )
	RJE->(Dbgotop())

	If Len(aLisFil) > 0

		oProcessFil:Set1Progress( Len(aLisFil) )
		// Loop pelas filiais selecionadas
		For nFilSel := 1 To Len(aLisFil)

			SM0->( MsSeek( cEmpAnt + aLisFil[ nFilSel , 2 ] , .T. ) )
			cFilAnt	:=	FWGETCODFILIAL

			oProcessFil:Inc1Progress( OemToAnsi(STR0301) +  cEmpAnt +"/"+ aLisFil[ nFilSel , 2 ] )        //"Empresa/Filial "
			oProcessFil:Set2Progress( 4 )
			oProcessFil:Inc2Progress( OemToAnsi(STR0289))        //"eSocial"

			For nTp := 1 to Len(aTipos)
				cTipEvent := Alltrim(Substr(aTipos[nTp,1],1,6) )
				If cTipEvent $ cFilComp
				   cFilEvent := cFilMid
				ElseIf cTipEvent $ cFilSGY
				   cFilEvent := xFilial( "SGY", cFilAnt)
				ElseIf cTipEvent $ cFilCargFunc
					If !lCargSQ3
						cFilEvent := xFilial("SQ3", cFilAnt)
					Else
						cFilEvent := xFilial("SRJ", cFilAnt)
					EndIf
				Else
				   cFilEvent := Alltrim(Substr(aTipos[nTp,2],1,3) )
				   cFilEvent := xFilial( cFilEvent)
				Endif
				cTipEvent := StrTran(cTipEvent,"-","")

				cQuery := "SELECT RJE.R_E_C_N_O_ REGREC "
				cQuery += "FROM " + RetSqlName("RJE") + " " + "RJE" + " "
				cQuery += "WHERE D_E_L_E_T_ = '' "
				cQuery += "  AND " + "RJE_FIL  = '" + cFilEvent + "'"
				cQuery += "  AND " + "RJE_EVENTO  = '" + cTipEvent + "'"
	//			cQuery += "  AND " + "RJE_FILIAL = '" + xFilial( "RJE", cFilAnt ) + "'"
	//			cQuery += "  AND " + "RJE_EVENTO IN (" + fSqlIN( cTipos, 5 ) + ")"

				If cAmbEsocial == '1' //1-Produção
					cQuery += "  AND " + "RJE_STATUS NOT IN ('2','4') "
				Endif

				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasRJE, .F., .T.)

				Begin Transaction

				DbSelectArea("RJE")
				DbSetOrder(1)
				If !(cAliasRJE)->(Eof())
					(cAliasRJE)->(dbGoToP())
					While (cAliasRJE)->(!Eof())
						RJE->(dbGoTo((cAliasRJE)->(REGREC)))
						RJE->(RecLock( "RJE",.F., .F.))
						RJE->(dbDelete())
						(cAliasRJE)->(DbSkip())
						nQtdRje++
						RJE->(MsUnlock())
					EndDo
				EndIF
				(cAliasRJE)->(DbCloseArea())

				End Transaction
			Next nTipEvent
		Next nFilSel
	Endif

	//Restauro a filial que estava logado no inicio do processo
	SM0->( MsSeek( aEmpAux[ 1 , 1 ] + aEmpAux[ 1 , 2 ] , .T. ) )
	cFilAnt	:=	FWGETCODFILIAL
Endif

RestArea(aAreaRJE)

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} function fRegRJE
Função que busca a existência de eventos com Status enviados com sucesso para o Ret
@author  Silvia Taguti Garcia
@since   21/11/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fRegRJE(cFilEvent, cTpIns, cInsc, cTipEvent, cChave, aErros)

	Local aAreaRJE  := RJE->(GetArea())
	Local cQueryRJE	:= GetNextAlias()
	Local cAchou	:= "N"
	Local nTamFil   := GetSx3Cache("RJE_FIL", "X3_TAMANHO")
	Local nTamChave := nTamFil + 7
	Local cWhereRJE	:= ""

	Default cEvento := ""
	Default cChave	:= ""
	Default cStatus	:= "N"
	Default cTpIns	:= ""
	Default cInsc	:= ""
	Default aErros  := {}

	If cTipEvent $ "S1295/S1298/S1299"
		cWhere := "% RJE.D_E_L_E_T_ = ' '"
		cWhere += " AND RJE.RJE_FIL = '" + cFilEvent + "'"
		cWhere += " AND RJE.RJE_TPINSC = '" + cTpIns + "'"
		cWhere += " AND RJE.RJE_INSCR = '" + cInsc + "'"
		cWhere += " AND RJE.RJE_EVENTO = '" + cTipEvent + "'"
		cWhere += " AND RJE.RJE_FILIAL = '" + xFilial("RJE", cFilAnt) + "'"
		cWhere += " AND Substring(RJE_KEY, 1, " + cValToChar(nTamChave) + ") = '" + cChave + "'"
		cWhere += " AND RJE.RJE_STATUS = '4'"
		cWhere += " AND RJE.RJE_EXC = ' '"
		cWhere += " %"
	Else
		cWhere := "% RJE.D_E_L_E_T_ = ' '"
		cWhere += " AND RJE.RJE_FIL = '" + cFilEvent + "'"
		cWhere += " AND RJE.RJE_TPINSC = '" + cTpIns + "'"
		cWhere += " AND RJE.RJE_INSCR = '" + cInsc + "'"
		cWhere += " AND RJE.RJE_EVENTO = '" + cTipEvent + "'"
		cWhere += " AND RJE.RJE_FILIAL = '" + xFilial("RJE", cFilAnt) + "'"
		cWhere += " AND Substring(RJE_KEY, 1, 7) = '" + cChave + "'"
		cWhere += " AND RJE.RJE_STATUS = '4'"
		cWhere += " AND RJE.RJE_EXC = ' '"
		cWhere += " %"
	EndIf

	BeginSql alias cQueryRJE
		SELECT COUNT(1) AS QTD
		FROM %table:RJE% RJE
		WHERE %exp:cWhere%
	EndSql

	If (cQueryRJE)->QTD > 0
		cAchou := "S"
	Else
		aAdd(aErros, OemToAnsi(STR0353) + cTipEvent + OemToAnsi(STR0354) + SubStr(cChave, Len(cFilEvent)+1, 6))
	EndIf

	(cQueryRJE)->(dbCloseArea())

	Restarea(aAreaRJE)

Return cAchou

//-------------------------------------------------------------------
/*/{Protheus.doc} function fTamRJEKey
Função que busca o tamanho do campo RKE_KEY
@author  Allyson Mesashi
@since   07/01/2020
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fTamRJEKey()

If Empty(nTamRJEKey)
	nTamRJEKey := TamSX3( "RJE_KEY" )[1]
EndIf

Return nTamRJEKey

/*/{Protheus.doc} fExcRJO()
Função que exclui as rubricas do trabalhador na RJO
@type function
@author allyson.mesashi
@since 23/01/2020
@version 1.0
@param cFilRJO		= Filial do trabalhador
@param cTpFolha		= Indicador de apuração
@param cPerApur		= Período de apuração
@param cCPF			= CPF do trabalhador
@param cEvento		= Código do evento
/*/
Function fExcRJO( cFilRJO, cTpFolha, cPerApur, cCPF, cEvento )

RJO->(dbSetOrder(1))//RJO_FILIAL+RJO_INDAPU+RJO_PERAPU+RJO_CPF+RJO_EVENTO
If RJO->( dbSeek( cFilRJO + cTpFolha + Padr(cPerApur, 6) + cCPF + cEvento ) )
	While RJO->( !EoF() ) .And. RJO->RJO_FILIAL+RJO->RJO_INDAPU+RJO->RJO_PERAPU+RJO->RJO_CPF+RJO->RJO_EVENTO == cFilRJO + cTpFolha + Padr(cPerApur, 6) + cCPF + cEvento
		If RJO->( Reclock( "RJO", .F. ) )
			RJO->( dbDelete() )
			RJO->( MsUnlock() )
		EndIf
		RJO->( dbSkip() )
	EndDo
EndIf
If cEvento $ "S-1200/S-2299/S-2399"
	If RJO->( dbSeek( cFilRJO + cTpFolha + Padr(cPerApur, 6) + cCPF + "S-5001" ) )
		While RJO->( !EoF() ) .And. RJO->RJO_FILIAL+RJO->RJO_INDAPU+RJO->RJO_PERAPU+RJO->RJO_CPF+RJO->RJO_EVENTO == cFilRJO + cTpFolha + Padr(cPerApur, 6) + cCPF + "S-5001"
			If RJO->( Reclock( "RJO", .F. ) )
				RJO->( dbDelete() )
				RJO->( MsUnlock() )
			EndIf
			RJO->( dbSkip() )
		EndDo
	EndIf
	If RJO->( dbSeek( cFilRJO + cTpFolha + Padr(cPerApur, 6) + cCPF + "S-5003" ) )
		While RJO->( !EoF() ) .And. RJO->RJO_FILIAL+RJO->RJO_INDAPU+RJO->RJO_PERAPU+RJO->RJO_CPF+RJO->RJO_EVENTO == cFilRJO + cTpFolha + Padr(cPerApur, 6) + cCPF + "S-5003"
			If RJO->( Reclock( "RJO", .F. ) )
				RJO->( dbDelete() )
				RJO->( MsUnlock() )
			EndIf
			RJO->( dbSkip() )
		EndDo
	EndIf
EndIf

Return

/*/{Protheus.doc} fGrvRJO()
Função que grava as rubricas do trabalhador na RJO
@type function
@author allyson.mesashi
@since 23/01/2020
@version 1.0
@param cFilRJO		= Filial do trabalhador
@param cTpFolha		= Indicador de apuração
@param cPerApur		= Período de apuração
@param cCPF			= CPF do trabalhador
@param cNome		= Nome do trabalhador
@param cMatric		= Matricula eSocial do trabalhador
@param cCateg		= Categoria eSocial do trabalhador
@param cTpInsc		= Tipo de inscrição
@param cNrInsc		= Número de inscrição
@param cCodLot		= Código de lotação
@param cNaturez		= Natureza da rubrica
@param cTpRub		= Tipo da rubrica
@param cIncCP		= Incidência CP da rubrica
@param cIncFgts		= Incidência FGTS da rubrica
@param cIncIRRF		= Incidência IRRF da rubrica
@param nValor		= Valor da rubrica
@param cEvento		= Código do evento
@param cIndDec		= Indicador de 13º salário
@param cTpVlr		= Tipo de valor
@param cTpCR		= Código da Receita (CR)
@param cIncop		= Incid RPPS
@param cTetoP		= Teto Remun
/*/
Function fGrvRJO( cFilRJO, cTpFolha, cPerApur, cCPF, cNome, cMatric, cCateg, cTpInsc, cNrInsc, cCodLot, cNaturez, cTpRub, cIncCP, cIncFgts, cIncIRRF, nValor, cEvento, cIndDec, cTpVlr, cTpCR, cIncop, cTetoP )

Local   cVersEnvio  := ""
Default cFilRJO 	:= ""
Default cTpFolha 	:= ""
Default cPerApur 	:= ""
Default cCPF 		:= ""
Default cNome 		:= ""
Default cMatric 	:= ""
Default cCateg 		:= ""
Default cTpInsc 	:= ""
Default cNrInsc 	:= ""
Default cCodLot 	:= ""
Default cNaturez 	:= ""
Default cTpRub 		:= ""
Default cIncCP 		:= ""
Default cIncFgts 	:= ""
Default cIncIRRF 	:= ""
Default nValor 		:= 0
Default cEvento 	:= ""
Default cIndDec 	:= ""
Default cTpVlr 		:= ""
Default cTpCr 		:= ""
Default cIncop		:= ""
Default cTetoP		:= ""

If FindFunction("fVersEsoc")
	fVersEsoc( "S1200",,,, @cVersEnvio,,)
EndIf

If RJO->( Reclock( "RJO", .T. ) )
	RJO->RJO_FILIAL		:= cFilRJO
	RJO->RJO_INDAPU		:= cTpFolha
	RJO->RJO_PERAPU		:= cPerApur
	RJO->RJO_CPF		:= cCPF
	RJO->RJO_NOME		:= cNome
	RJO->RJO_MATRIC		:= cMatric
	RJO->RJO_CATEG		:= cCateg
	RJO->RJO_TPINSC		:= cTpInsc
	RJO->RJO_NRINSC		:= cNrInsc
	RJO->RJO_CODLOT		:= cCodLot
	RJO->RJO_EVENTO		:= cEvento
	RJO->RJO_NATRUB		:= cNaturez
	RJO->RJO_TPRUBR		:= cTpRub
	RJO->RJO_INCCP		:= cIncCP
	RJO->RJO_INCFGT		:= cIncFgts
	RJO->RJO_INCIRF		:= cIncIRRF
	RJO->RJO_INDDEC		:= cIndDec
	RJO->RJO_TPVLR		:= cTpVlr
	RJO->RJO_TPCR		:= cTpCr
	RJO->RJO_VALOR		:= nValor
	If cVersEnvio >= "9.0"
		RJO->RJO_INCOP	:= cIncop
		RJO->RJO_TETOP	:= cTetoP
	Endif
	RJO->( MsUnlock() )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMidTrPath
Troca a Startpath do XML (copia de fTrocaPath)
Essa função foi criada para permitir que os Erp's possam mandar
a StartPath com namespace, por questões de performace não foi utilizado
as funções XPathGetRootNsList e XPathRegisterNsList para identificar os
namespaces e registra-los.
@author evandro.oliveira
@since 03/02/2016
@version 1.0
@param cXml, character, (Xml a ser avaliado)
@param cPath, character, (StartPath (Tag Inicial) que deve substituir a atual)
@return ${cXmlRet}, ${Xml com a StartPath alterada }
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Function fMidTrPath(cXml,cPath)

	Local nStart	:= 0
	Local cXmlRet	:= ""

	nStart := AT(">",cXml)
	cXmlRet := "<" + cPath + Substr(cXml,nStart,Len(cXml)-(nStart-1))

Return cXmlRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fVldRJ9
Função que verifica se a filial é a matriz:
@author  lidio.oliveira
@since   10/08/2020
@version V 1.0
@param cNrInsc		= Número de Inscrição (CNPJ/CPF)
/*/
//-------------------------------------------------------------------
Function fVldRJ9( cNrInsc )

Local aArea		 := GetArea()
Local lMatriz	 := .F.

	Default cNrInsc	 := ""

	RJ9->( dbSetOrder(5) )
	If (RJ9->( dbSeek( cNrInsc )))
		lMatriz	:= .T.
	EndIf

	RestArea(aArea)

Return lMatriz

//---------------------------------------------------------------------
/*/{Protheus.doc} GPENorStrES

Altera caracteres descritos no manual do desenvolvedor e-Social para
o formato especificado no mesmo.

@Author	Evandro dos Santos Oliveira Teixeira
@Since	28/11/2017
@Version 1.0

@param cString  -> String a ser convertida
@param nConvert -> Modo de Conversão
				   1 - Converte
				   2 - Desconverte

@return cAlter -> String Convertida
/*/
//---------------------------------------------------------------------
Function GPENorStrES(cString,nConvert)

	Local cAlter := ""
	Local aMapChar := {}
	Local nX := 0

	Default nConvert := 1

	cAlter := cString

	If nConvert == 1

		aAdd(aMapChar,{"&","&amp;"}) //deve ser executado por primeiro nesta opção
		aAdd(aMapChar,{">","&gt;"})
		aAdd(aMapChar,{"<","&lt;"})
		aAdd(aMapChar,{'"',"&quot;"})
		aAdd(aMapChar,{"'","&apos;"})

		For nX := 1 To Len(aMapChar)
			cAlter := StrTran(cAlter,aMapChar[nX][1],aMapChar[nX][2])
		Next nX
	Else

		aAdd(aMapChar,{">","&gt;"})
		aAdd(aMapChar,{"<","&lt;"})
		aAdd(aMapChar,{'"',"&quot;"})
		aAdd(aMapChar,{"'","&apos;"})
		aAdd(aMapChar,{"&","&amp;"}) //deve ser executado por ultimo nesta opção

		For nX := 1 To Len(aMapChar)
			cAlter := StrTran(cAlter,aMapChar[nX][2],aMapChar[nX][1])
		Next nX
	EndIf

Return cAlter

//-------------------------------------------------------------------
/*/{Protheus.doc} Function GpeVerTSS
Função que retorna a versão do TSS
@author  Silvia Taguti
@since   30/09/2021
@version V 1.0
@Return cVersao - Versão do TSS
/*/
//-------------------------------------------------------------------

Function GpeVerTSS(cIdEnt)
	Local aArea			:= GetArea()
	Local cURL      := PadR(GetNewPar("MV_GPEMURL","http://"),250)
	Local oWS
	Local cVersao	:= ""
	Local lRetorno  := .F.

	Default cIdEnt  := ""

	//Verifica se o servidor da Totvs esta no ar
	oWs := WsSpedCfgNFe():New()
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	oWS:cVersao    := "0.00"
	oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"

	If oWs:CFGCONNECT()
		lRetorno := .T.
	EndIf

	If lRetorno
		// Verifica a versão
		lOk := oWS:CFGTSSVERSAO()
		cVersao        := oWS:cCfgTSSVersaoResult
	EndIf

	RestArea(aArea)

Return(cVersao)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGPETokenMid
Função que retorna um token válido
@author  lidio.oliveira
@since   29/09/2021
@version V 1.0
@param cClient	= ClientId
@param cSecret	= Client Secret
@param cNrInsc	= Número de Inscrição (CNPJ)
@param cURLTSS	= URL do TSS
@param cNmRest	= Nome do serviço Rest
@param cErro	= Retornar erros por parâmetro
@Return cret 	= Token válido
/*/
//-------------------------------------------------------------------
Function fGPETokenMid(cClient, cSecret, cNrInsc, cURLTSS, cURLREST, cNmRest, cErro)

	Local aArea		:= GetArea()
	Local cRet		:= ""
	Local cBody		:= ""
	Local cResult	:= ""
	Local aDados	:= {}
	Local aDadosRJ0	:= {}
	Local aHeader	:= {}
	Local lOk		:= .T.
	Local dDataAtu	:= DATE()
	Local cHoraAtu	:= TIME()
	Local dDataFim	:= CTOD("//")
	Local cHoraFim	:= ""
	Local cHora		:= ""
	Local cMin		:= ""
	Local lUsaCred	:= .F.
	Local lRefresh	:= .F.
	Local lGeraToken:= .T.
	Local nFimTxt	:= 0
	Local nFimHr	:= 0
	Local oMID
	Local oRet
	Local oBody

	Default	cClient	:= ""
	Default cSecret	:= ""
	Default cNrInsc	:= ""
	Default cURLTSS	:= ""
	Default cURLREST:= ""
	Default cNmRest	:= ""
	Default cErro	:= ""

	//Caso ClientID ou Client Secret não sejam informados pesquisa na RJ9 a partir do número de inscrição
	If (Empty(cClient) .Or. Empty(cSecret)) .And. !Empty(cNrInsc)
		aDados := fGetCredTSS(cNrInsc)
		If Len(aDados) > 0
			cClient	:= aDados[1]
			cSecret	:= aDados[2]
		Else
			lOk	:= .F.
		EndIf
	EndIf

	//Se a URL do TSS não foi informada pesquisa valor no parâmetro MV_GPEMURL
	If Empty(cURLTSS)
		cURLTSS := ALLTRIM( SuperGetMv( "MV_GPEMURL",, "" ))
		If Empty(cURLTSS)
			lOk	:= .F.
		EndIf
	EndIf

	//Caso o nome do serviço REST não tenha sido informado
	IF Empty(cNmRest)
		cNmRest := ALLTRIM( SuperGetMv( "MV_APIMI02",, "" ))
	EndIf

	//Ajusta o nome do rest
	nFimTxt		:= AT( "/", cNmRest )
	cNmRest 	:= "/" + Substr(cNmRest, 1, nFimTxt -1)

	//Busca a URL do REST caso não seja informada
	If Empty(cURLREST)
		cURLREST	:= ALLTRIM( SuperGetMv( "MV_APIMI01",, "" ))
		If Empty(cURLREST)
			lOk	:= .F.
		EndIf
	EndIf

	//Pesquisa na RJ0 os dados do Token
	If lOk
		aDadosRJ0 := fTokenRJ0(cClient, cSecret)
	EndIf

	//Verifica se o último token gravado na RJ0 está valido, caso esteja retorna conteúdo
	If Len(aDadosRJ0) > 0
		If dDataAtu >= aDadosRJ0[5]
			lUsaCred	:= .T.
		ElseIf cHoraAtu  > aDadosRJ0[6]
			lRefresh	:= .T.
			lUsaCred	:= .T. //retirar posteriormente
		Else
			cRet		:= alltrim(aDadosRJ0[3])
			lGeraToken	:= .F.
		EndIf
	Else
		lOk	:= .F.
	EndIf

	//Geração de novo token
	If lOk .And. lGeraToken
		// Montagem do Header
		aadd(aHeader, "Content-Type: application/json; charset=UTF-8")

		// Montagem do corpo para geração do Token
		oBody					:= JsonObject():new()
		oBody["urlTSS"]			:= cURLTSS
		oBody["grantType"]		:= If(lUsaCred, 1, 2) //1-Usa credenciais
		If lUsaCred
			oBody["clientId"]		:= alltrim(aDadosRJ0[1])
			oBody["clientSecret"]	:= alltrim(aDadosRJ0[2])  // Retorna a versão de Layout do evento enviado
		Elseif lRefresh
			oBody["refreshToken"]	:= alltrim(aDadosRJ0[4])  // Retorna a versão de Layout do evento enviado
		EndIf

		// Converve o objeto para texto e o compacta
		cBody := fCompress( @oBody )

		// Chamada da API
		oMID := FwRest():New( cURLREST )
		oMID:setPath( cNmRest + "/WSTSSAuth/v1" )
		oMID:SetPostParams( cBody )

		lHeader := oMID:Post( aHeader )

		// Verificação de Retorno
		oRet := JsonObject():new()
		lRet := FWJsonDeserialize( oMID:GetResult(), @oRet )

		//Chama a gravação da tabela RJ0
		If lRet .And. lHeader .And. !Empty( oRet )
			cResult	:= oMID:GetResult()

			dDataFim := dDataAtu + 1
			cHoraFim := cValToChar(Min2Hrs((Hrs2Min( cHoraAtu ) + (oRet:expiresIn / 60))))

			//Ajusta cHoraFim para o formato HH:MM:SS
			nFimHr	:= AT(".", cHoraFim)
			cHora	:= padl(SUBSTR( cHoraFim, 1, nFimHr -1), 2, "0")
			cMin 	:= SUBSTR( cHoraFim, nFimHr + 1, 2)
			cHoraFim:= cHora + ":" + cMin + ":" +"00"

			//Faz gravação dos dados na tabela RJ0
			fGrvRJ0(cClient, cSecret, oRet:accesstoken, oRet:refreshToken, cValToChar(oRet:expiresIn), oRet:tokenType, dDataAtu, cHoraAtu, dDataFim, cHoraFim)

			//Retorna o token gerado
			cRet := oRet:accesstoken
		Else
			If !lHeader .And. oMID != Nil
				cErro := STR0418 + CRLF + CRLF + STR0419 + cURLREST + cNmRest + CRLF + STR0420 + cURLTSS + CRLF + CRLF //"Falha ao gerar o token para o TSS, verifique se os serviços de REST e TSS estão corretos."
				cErro += STR0421 + DecodeUtf8(oMID:CINTERNALERROR) + CRLF + CRLF  //"Erro retornado: "
				cErro += STR0422 //"Caso os endereços estejam corretos, verifique também se as credencias informadas no cadastro do empregador estão corretas. "
				If !IsInCallStack("fGetIdEnt")
					cErro += STR0423 //"Se necessário, faça nova configuração do certificado para correta gravação dos parâmetros envolvidos neste processo ou consulte os parâmetros em https://tdn.totvs.com/x/jAJFFw."
				EndIf
			ElseIf	!lRet .And. oRET != Nil
				cErro := DecodeUtf8(oRET:MESSAGE)
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetCredTSS
Função que retorna as credencias gravadas na tabela RJ9
@author  lidio.oliveira
@since   29/09/2021
@version V 1.0
@param cNrInsc	= Número de Inscrição (CNPJ)
@return aRet -> Retorna array com os dados das credenciais da RJ9
/*/
//-------------------------------------------------------------------
Function fGetCredTSS(cNrInsc)

	Local aArea	:= GetArea()
	Local aRet	:= {}

	If RJ9->(ColumnPos("RJ9_CLIENT")) > 0
		RJ9->( dbSetOrder(5) )
		If RJ9->( dbSeek( cNrInsc )) .Or. RJ9->(DbSeek( SubStr( cNrInsc, 1, 8 ) ))
			aRet	:= {RJ9->RJ9_CLIENT, RJ9->RJ9_SECRET}
		EndIf
	EndIf

	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fTokenRJ0
Função que retorna as dados do Token na RJ0
@author  lidio.oliveira
@since   29/09/2021
@version V 1.0
@param cClient	= ClientId
@param cSecret	= Client Secret
@return aRet -> Retorna array com os dados da RJ0
/*/
//-------------------------------------------------------------------
Function fTokenRJ0(ClientId, cSecret)

	Local aArea	:= GetArea()
	Local aRet	:= {}

	If RJ9->(ColumnPos("RJ9_CLIENT")) > 0
		RJ0->( dbSetOrder(1) )
		If (RJ0->( dbSeek( xFilial("RJ0") + ClientId + cSecret) ))
			aRet	:= {RJ0->RJ0_CLIENT,; //[1] CLIENT
				RJ0->RJ0_SECRET,; //[2] SECRET
				RJ0->RJ0_TOKEN,; //[3] TOKEN
				RJ0->RJ0_RFTOKEN,; //[4] RERESH FTOKEN
			    RJ0->RJ0_DATAF,; //[5] DATA FINAL
				RJ0->RJ0_HORAF} //[6] HORA FINAL
		EndIf
	EndIf

	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fCompress
Compress String Object
@author  Hugo de Oliveira
@since   30/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fCompress(oObj)
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

//-------------------------------------------------------------------
/*/{Protheus.doc} fGrvRJ0()
Função que grava os dados do Token na RJ0
@author  lidio.oliveira
@since   29/09/2021
@version V 1.0
@param cClient	= ClientId
@param cSecret	= Client Secret
@param cToken	= Token
@param cRfToken	= Refresh Token
@param cExpire	= Expiração em segundos
@param cType	= tipo
@param dData	= Data de geração
@param cHora	= Hora de geração
@param dDataFim	= Data final de validade do Token
@param cHoraFim	= Hora final de validade do Token
/*/
//-------------------------------------------------------------------
Function fGrvRJ0( cClient, cSecret, cToken, cRfToken, cExpire, cType, dData, cHora, dDataFim, cHoraFim)

	Local aArea		:= GetArea()
	Local lNovoRJ0	:= .F.

	Default cClient 	:= ""
	Default cSecret 	:= ""
	Default cToken 		:= ""
	Default cRfToken 	:= ""
	Default cExpire		:= ""
	Default cType 		:= ""
	Default dData 		:= ""
	Default cHora 		:= ""
	Default dDataFim 	:= ""
	Default cHoraFim 	:= ""

	//Posicona a tabela RJ0 no indice 1 RJ0_FILIAL+RJ0_TPINSCl+RJ0_NRINSC
    RJ0->( dbSetOrder(1) )

	//Verifica se deve ser incluído um novo registro:
    lNovoRJ0 := RJ0->( !dbSeek( xFilial("RJ0") + cClient + cSecret) )

	If lNovoRJ0
		If RJ0->( Reclock( "RJ0", lNovoRJ0) )
			RJ0->RJ0_FILIAL		:= xFilial("RJ0")
			RJ0->RJ0_CLIENT		:= cClient
			RJ0->RJ0_SECRET		:= cSecret
			RJ0->RJ0_TOKEN 		:= cToken
			RJ0->RJ0_RFTOKE		:= cRfToken
			RJ0->RJ0_EXPIRE		:= cExpire
			RJ0->RJ0_TYPE  		:= cType
			RJ0->RJ0_DATA  		:= dData
			RJ0->RJ0_HORA  		:= cHora
			RJ0->RJ0_DATAF   	:= dDataFim
			RJ0->RJ0_HORAF   	:= cHoraFim
			RJ0->( MsUnlock() )
		EndIf
	Else
		If RJ0->( Reclock( "RJ0", lNovoRJ0) )
			RJ0->RJ0_TOKEN 		:= cToken
			RJ0->RJ0_RFTOKE		:= cRfToken
			RJ0->RJ0_EXPIRE		:= cExpire
			RJ0->RJ0_TYPE  		:= cType
			RJ0->RJ0_DATA  		:= dData
			RJ0->RJ0_HORA  		:= cHora
			RJ0->RJ0_DATAF   	:= dDataFim
			RJ0->RJ0_HORAF   	:= cHoraFim
			RJ0->( MsUnlock() )
		EndIf
	EndIf

	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetAltXML()
Função utilizda para retornar os dados do XML
@author  lidio.oliveira
@since   10/01/2022
@version V 1.0
@param cEvent		= Evento
@param cXML			= XML
@param cTpAfa		= Tipo do Afastamento
@param dDtEve		= Data de alteração do evento
@param cKeyAfaFim	= Chave do fim do afastamento
/*/
//-------------------------------------------------------------------
Static Function fGetAltXML(cEvent, cXML, cTpAfa, dDtEve, cKeyAfaFim)

	Local aArea			:= GetArea()
	Local aAreaRJE      := RJE->(GetArea())
	Local oXml 			:= tXmlManager():New()
	Local aPathXML		:= {}
	Local cTpS2230		:= "/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/codMotAfast"
	Local cFimS2230		:= "/eSocial/evtAfastTemp/infoAfastamento/fimAfastamento/dtTermAfast"
	Local nPos 			:= 0
	Local nRecAfaI		:= 0
	Local cKeyAfaIni	:= ""

	Default	cEvent		:= ""
	Default cXML		:= ""
	Default cTpAfa		:= ""
	Default dDtEve		:= CTOD("//")
	Default cKeyAfaFim	:= ""

	//Adiciona no array os diretório para cada evento
	aAdd(aPathXML, {"S2200", "/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/dtAdm"})
	aAdd(aPathXML, {"S2205", "/eSocial/evtAltCadastral/alteracao/dtAlteracao"})
	aAdd(aPathXML, {"S2236", "/eSocial/evtAltContratual/altContratual/dtAlteracao"})
	aAdd(aPathXML, {"S2230", "/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/dtIniAfast"})
	aAdd(aPathXML, {"S2299", "/eSocial/evtDeslig/infoDeslig/dtDeslig"})
	aAdd(aPathXML, {"S2300", "/eSocial/evtTSVInicio/infoTSVInicio/dtInicio"})
	aAdd(aPathXML, {"S2306", "/eSocial/evtTSVAltContr/infoTSVAlteracao/dtAlteracao"})
	aAdd(aPathXML, {"S2399", "/eSocial/evtTSVTermino/infoTSVTermino/dtTerm"})

	//Localiza no array o diretório conforme o evento
	nPos := aScan(aPathXML, {|x| x[1] == cEvent})

	//Verifica se o XML possui início e fim para pesquisar os dados
	If oXml:Parse( fMidTrPath(cXML,"eSocial") ) .And. nPos > 0
		dDtEve	:= sToD(STRTRAN(oXml:XPathGetNodeValue( aPathXML[nPos,2] ), "-"))

		//Apenas para o evento S2230 retorna o tipo de afastamento e pesquisa pela data final.
		If cEvent == "S2230"
			//Se a data continuar vazia utiliza o evento inicial para retornar o tipo de afastamento
			If Empty(dDtEve)
				dDtEve	:= sToD(STRTRAN(oXml:XPathGetNodeValue( cFimS2230 ), "-"))

				//Ajusta a chave e encontra o RECNO do registro inicio do afastamento
				cKeyAfaIni := "S2230" + SUBSTR(cKeyAfaFim, 1, LEN(cKeyAfaFim) -1 ) + "I"
				GetInfRJE( 4, cKeyAfaIni, Nil, Nil, Nil, @nRecAfaI, Nil, Nil, Nil, Nil, .F.)
				If nRecAfaI > 0
					//Posiciona no registro e obtem do XML de Início o motivo de afastamento
					RJE->( dbGoTo(nRecAfaI) )
					cTpAfa	:= fGetXML("codMotAfast", RJE->RJE_XML)
				EndIf
			Else
				cTpAfa	:= oXml:XPathGetNodeValue( cTpS2230 )
			EndIf
		EndIf
	EndIf

	oXml := Nil

	RestArea(aAreaRJE)
	RestArea(aArea)

Return

/*/{Protheus.doc} function fGetXML
Retorna o valor de uma TAG do XML informado
@author  Hugo de Oliveira
@since   09/12/2019
@version 1.0
/*/
Static Function fGetXML( cTAG, cXML )
	Local nIni 	:= 0
	Local nFim 	:= 0
	Local cData := ""

	nIni 	:= AT("<" + cTAG + ">",  cXML )
	nFim 	:= AT("</" + cTAG + ">", cXML )
	cData 	:= ALLTRIM( STRTRAN(  SUBSTR( cXML, nIni, nFim-nIni ), "<" + cTAG + ">","" ) )

Return cData
