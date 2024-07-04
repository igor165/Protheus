#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'OFINJD41.CH'

#define PULALINHA chr(13) + chr(10)

/*/{Protheus.doc} OFINJD41
  Rotina scheduler que gera um relatorio de peças sem venda e 
  envia para a jhonn deere

  Pontos de entrada:

	Parametros:

  @author Vinicius Gati
  @since  10/11/2016
/*/
Function OFINJD41(aParam)
	Local cArqLocal := ""
	Local nIdx      := 1
	Local nHdl      := 0
	Local cHeadRet  := ""
	Local sPostRet  := ""
	Local oObj      := Nil
	Local aButton   := {}
	Local cMensagem := ""
	Local aSay      := {STR0015 /*'Esta rotina cria e envia dados de peças sem venda para assodeere.'*/}
	Private lMenu   := (VALTYPE(aParam) == "U")
	Private cModo   := 'MENU'
	if ! lMenu
		cModo       := 'SCHE'
		nModulo     := 41
		cModulo     := "PEC"
		__cInternet := 'AUTOMATICO'
		cEmpr       := aParam[1]
		cFil        := aParam[2]
		If Type("cArqTab") == "U"
			cArqTab:=""
		EndIf
		cFOPENed := ""
		DbCloseAll()
		Prepare Environment Empresa cEmpr Filial cFil Modulo cModulo 
	EndIf
	Private cPerg      := "JD41SCH"
	Private oSqlHlp    := DMS_SqlHelper():New()
	Private oLogger    := DMS_Logger():New("OFINJD41.LOG")
	Private oFilHlp    := DMS_FilialHelper():New()
	Private oDpm       := DMS_Dpm():New()
	Private cSend      := ""

	//CriaPerg()
	//Local cOpcGetFil := AllTrim(Str( GETF_RETDIRECTORY ))
	////"Pasta Exp."
	//aAdd(aRegs,{STR0001,STR0001,STR0001,"MV_CH1","C",99,0,0,'G',"MV_PAR01:=cGetFile('Arquivos |*.*','',,,,"+cOpcGetFil+")","MV_PAR01",'','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
	////"Dias Sem Venda"
	//AADD(aRegs,{STR0002,STR0002,STR0002,'MV_CH2','N',03,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})

  //
	if lMenu
	  aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T.)     }} )
	  aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
	  aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
	  FormBatch( "Peças Sem Vendas - Portal de Peças Assodeere", aSay, aButton )
	EndiF
	//
	Pergunte(cPerg,.F. )
	//
	cArqLocal := ALLTRIM(MV_PAR01) + "PECAS_SEM_VENDA_" + SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".XML"

	cTblLogCod := oLogger:LogToTable({;
	  {'VQL_AGROUP'     , 'OFINJD41'         },;
	  {'VQL_TIPO'       , 'LOG_EXECUCAO'     },;
	  {'VQL_DADOS'      , "MODO: " + cModo   } ;
	})

	if !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
		nHdl := Fcreate( cArqLocal )
	Else
		if lMenu
			/*"Informações necessárias não foram corretamente preenchidas, por favor acesse a rotina e preencha os parametros"*/
			MSGINFO(STR0003, STR0004 /*"Informação"*/)
			Return .F.
		else
			conout("OFINJD41: " + STR0003)
			oLogger:LogToTable({;
			  {'VQL_AGROUP'     , 'OFINJD41' },;
			  {'VQL_CODVQL'     , cTblLogCod },;
			  {'VQL_TIPO'       , 'INFO'     },;
			  {'VQL_DADOS'      , STR0003    } ;
			})
			Return .F.
		EndIf
	EndIf

	cSend := '<?xml version="1.0" encoding="UTF-8" ?>'
	cSend += '<pecas>'
	FWRITE(nHdl,'<?xml version="1.0" encoding="UTF-8" ?>'+PULALINHA)
	FWRITE(nHdl,'<pecas>'+PULALINHA)

	aFilis := oDpm:GetFiliais()
	For nIdx := 1 to LEN(aFilis)
		JD41FndPecs(aFilis[nIdx, 1], nHdl, @cSend)
	Next

	FWRITE(nHdl,'</pecas>')
	FCLOSE(nHdl)

	sPostRet := HttpPost('http://deere.autoavaliar.com.br/parts/service/upload/totvs',"","user=teste&token=$KlhelalnasjukIUkjasdnlYasdkWkuafg&file_content="+cSend,120,,@cHeadRet)
	if !empty(sPostRet)
		If FWJsonDeserialize(sPostRet,@oObj)
			cMensagem := STR0013 /*"Um erro ocorreu."*/ + PULALINHA + STR0014 /*"Erro: "*/ + JD41TRD(oObj:data:message)
			if lMenu
				MsgStop(cMensagem, STR0004/* informacao */)
			else
				conout(cMensagem)
			EndIf
		Endif
	Else
		cMensagem := STR0012 /* "Não foi possível localizar o servidor, tente novamente mais tarde." */
		if lMenu
			MsgStop(cMensagem, STR0004/* informacao */)
		else
			conout(cMensagem)
		EndIf
		MsgStop(cMensagem, STR0004/* informacao */)
	EndIf
  varinfo("WebPage", sPostRet)

	oLogger:CloseOpened(cTblLogCod)
Return .T.

/*/{Protheus.doc} JD41FndPecs
  Pega as peças sem venda na filial passada por parametro

  @author Vinicius Gati
  @since  11/11/2016
/*/
Static Function JD41FndPecs( cFil, nHdl, cSend )
	Local cQuery   := ""
	Local cXML     := ""
	Local cAl      := GETNEXTALIAS()
	if Empty(cFil)
		Return ""
	EndIf

	cFilAnt := cFil

	dbSelectArea("SA2")
	dbGoTo( oFilHlp:GetFornecedor( xFilial('VS1') ) )

	cQuery += "   SELECT D2_FILIAL filial, B1_GRUDES grupo_desconto, B1_DESC descricao_peca, D2_COD codigo_peca, SUM(B2_QATU) saldo, MAX(SD2.D2_EMISSAO) ultima_venda "
	cQuery += "     FROM " + oSqlHlp:Nolock("SB2")
	cQuery += "     JOIN " + oSqlHlp:Nolock("SD2") + " ON SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SD2.D2_COD    = SB2.B2_COD   AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += "     JOIN " + oSqlHlp:Nolock("SB1") + " ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD    = SD2.D2_COD   AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "     JOIN " + oSqlHlp:Nolock("SBM") + " ON SBM.BM_FILIAL = '" + xFilial("SBM") + "' AND SBM.BM_GRUPO  = SB1.B1_GRUPO AND SBM.BM_CNSPOR  = '1' AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += "     JOIN " + oSqlHlp:Nolock("SF4") + " ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD2.D2_TES   AND SF4.F4_OPEMOV = '05' AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "    WHERE SB2.B2_FILIAL = '" + xFilial("SB2") + "'"
	cQuery += "      AND SB2.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY D2_FILIAL, B1_GRUDES, B1_DESC, D2_COD "
	cQuery += "   HAVING MAX(SD2.D2_EMISSAO) < '" + DTOS(dDataBase - MV_PAR02) + "' " 
	cQuery += "      AND SUM(B2_QATU) > 0 "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )
	dbSelectArea(cAl)
	While !(cAl)->(EOF())
		cXML := ''
		cXML += ' <peca>' + PULALINHA
		cXML += '  <filial>'         + ALLTRIM( (cAl)->filial )                     +'</filial>'         + PULALINHA
		cXML += '  <cnpj>'           + ALLTRIM( SA2->A2_CGC )                       +'</cnpj>'           + PULALINHA
		cXML += '  <codigo_peca>'    + ALLTRIM( (cAl)->codigo_peca )                +'</codigo_peca>'    + PULALINHA
		cXML += '  <descricao_peca>' + ALLTRIM( NOACENTO( (cAl)->descricao_peca ) ) +'</descricao_peca>' + PULALINHA
		cXML += '  <grupo_desconto>' + ALLTRIM( (cAl)->grupo_desconto )             +'</grupo_desconto>' + PULALINHA
		cXML += '  <quantidade>'     + ALLTRIM( STR((cAl)->saldo) )                 +'</quantidade>'     + PULALINHA
		cXML += '  <ultima_venda>'   + ALLTRIM( (cAl)->ultima_venda )               +'</ultima_venda>'   + PULALINHA
		cXML += ' </peca>' + PULALINHA
		FWRITE(nHdl,cXML)
		cSend += cXML

		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())
Return cXML


/*/{Protheus.doc} JD41TRD
  Traduz a mensagem de erro do webservice

  @author Vinicius Gati
  @since  05/12/2016
/*/
Static Function JD41TRD(cMsg)
	DO CASE
		CASE cMsg $ "Unknown User";                      Return STR0005 /*"Usuário não encontrado."*/
		CASE cMsg $ "Only POST is allowed";              Return STR0006 /*"Requisição em modelo errado."*/
		CASE cMsg $ "Access Denied. Invalid user/token"; Return STR0007 /*"Usuário ou senha inválidos."*/
		CASE cMsg $ "Failed to save file";               Return STR0008 /*"Erro ao salvar arquivo, arquivo provavelmente grande demais."*/
		CASE cMsg $ "Invalid filetype";                  Return STR0009 /*"Tipo do arquivo inválido."*/
		CASE cMsg $ "Request has no file";               Return STR0010 /*"Arquivo em branco ou não encontrado."*/
		CASE cMsg $ "Coudn't parse xml.";                Return STR0011 /*"Arquivo inválido detectado."*/
	END CASE
Return cMsg