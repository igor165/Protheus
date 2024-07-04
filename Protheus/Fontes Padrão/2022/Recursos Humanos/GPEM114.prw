#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'GPEM114.CH'

/*/{Protheus.doc} GPEM114
	Fun��o respons�vel pela gera��o da contabiliza��o da folha
	em arquivo(TXT ou XML)
@author PHILIPE.POMPEU
@since 27/07/2016
@version P11
@param cMesAnoCtab, caractere, MesAno cont�bil(ex: 092014)
@param cFilConDe, caractere, Filtro de Filial De
@param cFilConAte, caractere, Filtro de Filial At�
@return Nil, valor nulo
/*/
Function GPEM114(cMesAnoCtab, cFilConDe, cFilConAte)
	Local lIntegra		:= SuperGetMv("MV_RHCONEX",,.F.)
	Private lIntegDef	:= FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI")
	Private lErpCmnet	:= GetMvRH("MV_ERPCM",,.F.)
	Default cFilConDe	:= cFilAnt
	Default cFilConAte	:= cFilAnt
	Default cMesAnoCtab	:= ""

	lErpLogix := IIF(Type("lErpLogix") == "U",SuperGetMv("MV_ERPLOGI",,"2") == "1",lErpLogix)

	If Empty(cMesAnoCtab)
		cMesAnoCtab := GetMesAno(IIF(Type("dDataBase") == "D",dDataBase,Date()))
	EndIf

	If lIntegra

		if(lIntegDef)
			lIntegDef := FWHasEAI("CTBA102", .T.)
		endIf

		if(Type("cLote") == "U")
			Private cLote	:= ""
			cLote := Gpem110LoteCont( "GPE" , cFilAnt )
		endIf
		if(Type("INCLUI") == "U")
			Private INCLUI		:= .T.
		endIf
		if(Type("ALTERA") == "U")
			Private ALTERA		:= .T.
		endIf

		/*Quando vindo do GPEM110 n�o permite altera��o dos filtros.*/
		Private lEditFiltr := !IsInCallStack("GPEM110")

		MontaTela(@cMesAnoCtab, @cFilConDe, @cFilConAte)
	Else 
		MsgInfo(OemToAnsi(STR0067), STR0001 )//"Sistema nao esta configurado para realizar integracao contabil com sistemas externos"
	EndIf

Return

/*/{Protheus.doc} MontaTela
	Monta a interface gr�fica respons�vel pela gera��o do arquivo;
	Essa fun��o existia no GPEM110 com outro nome e foi movida p/ o
	GPEM114.
@author philipe.pompeu
@since 27/07/2016
@version P11
@param cCompetencia, character, (Descri��o do par�metro)
@param cFilConDe, character, (Descri��o do par�metro)
@param cFilConAte, character, (Descri��o do par�metro)
@return ${return}, ${return_description}
/*/
Static Function MontaTela(cCompetencia, cFilConDe, cFilConAte)
	Local oDlgMain	:= Nil
	Local nOpca		:= 0
	Local oDirPesq	:= Nil
	Local cDirPesq	:= SuperGetMv("MV_PASCON",,"")
	Local cHist		:= Space(3)
	Local oHist		:= Nil	
	Local aFolder 	:= {}
	Local oFolder 	:= Nil
	Local oPanel 	:= Nil	
	Local oComp
	Local oFilDe
	Local oFilAte
	/*Variaveis para Dimensionar Tela*/	
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	/*----*/	
	Local bSet15	:= {|| lRet := GeraArquivo(cDirPesq, cCompetencia ,cHist, cFilConDe, cFilConAte,(oFolder:nOption = 2)),If(lRet,oDlgMain:End(),)}
	Local bSet24	:= {|| oDlgMain:End()}
	Local aHeader	:= {}
	Private oGreen	:= LoadBitmap( GetResources(), "BR_VERDE")
	Private oRed	:= LoadBitmap( GetResources(), "BR_VERMELHO")
	Private aCols	:= {}
	Private oGet	:= Nil

	/*Monta as Dimensoes dos Objetos*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )	

	DEFINE MSDIALOG oDlgMain TITLE OemToAnsi(STR0003) FROM  0,0 TO aAdvSize[1]+ 525, aAdvSize[1] + 800 OF oMainWnd PIXEL //"Integra��o Cont�bil - Protheus GPE X Sistema Externo"
	oPanel:= TPanel():New(01,01,"",oDlgMain,oDlgMain:oFont,.T.,,,,0,35,.T.)
	oPanel:Align := CONTROL_ALIGN_TOP

	@ 05, 05	SAY OemToAnsi(STR0032)Of oPanel PIXEL
	@ 05, 45	MSGET oComp VAR cCompetencia	Of oPanel PIXEL SIZE 30,5 WHEN lEditFiltr

	If !lErpCmnet
		@ 05, 95		SAY OemToAnsi(STR0014) 	Of oPanel PIXEL 	//"C�digo do Hist�rico Padr�o: "
		@ 05, 170	MSGET oHist VAR cHist 	Of oPanel PIXEL SIZE 18,5 PICTURE "@!" F3 "CT8"
	EndIf

	@ 20, 05	SAY OemToAnsi(STR0033) Of oPanel PIXEL
	@ 20, 45	MSGET oFilDe VAR cFilConDe	Of oPanel PIXEL SIZE 30,5 F3 "XM0"  WHEN lEditFiltr
	
	@ 20, 95 	SAY OemToAnsi(STR0034) Of oPanel PIXEL
	@ 20, 125	MSGET oFilAte VAR cFilConAte	Of oPanel PIXEL SIZE 30,5 F3 'XM0'  WHEN lEditFiltr

	If !(lErpCmnet)
		aFolder :=	{"TXT","XML(EAI)"}
	Else
		aFolder := {"TXT"}
	EndIf

	oFolder := TFolder():New(41, 01, aFolder, aFolder, oDlgMain,,,, .T., .F., 0,((aAdvSize[1]+525)*0.38))
	oFolder:Align := CONTROL_ALIGN_TOP

	If(lIntegDef)
		oFolder:SetOption(2)
		oFolder:aEnable(1, .F.)
		oFolder:aEnable(2, .T.)
	Else
		oFolder:aEnable(1, .T.)
		If !(lErpCmnet)
			oFolder:aEnable(2, .F.)
		EndIF
	EndIf

	aEval(oFolder:aDialogs,{|x|x:oFont := oDlgMain:oFont})

	If(lErpLogix)
		@ 5, 5 SAY OemToAnsi(STR0004) Of oFolder:aDialogs[1] PIXEL //"Ser�o exportadas as informa��es contabilizadas no GPE (Lote 008890) da Tabela CT2 com as seguintes informa��es separadas por pipe (|)"
		@ 15 , 5 SAY OemToAnsi(STR0005) Of oFolder:aDialogs[1] PIXEL //" - Empresa Sistema Externo"
		@ 25 , 5 SAY OemToAnsi(STR0006) Of oFolder:aDialogs[1] PIXEL //" - N�mero do Lote"
		@ 35 , 5 SAY OemToAnsi(STR0007) Of oFolder:aDialogs[1] PIXEL //" - C�digo do sistema (fixo GPE)"
		@ 45 , 5 SAY OemToAnsi(STR0008) Of oFolder:aDialogs[1] PIXEL //" - Data de refer�ncia"
		@ 55 , 5 SAY OemToAnsi(STR0009) Of oFolder:aDialogs[1] PIXEL //" - N�mero da Conta"
		@ 65 , 5 SAY OemToAnsi(STR0010) Of oFolder:aDialogs[1] PIXEL //" - Tipo de Lan�amento"
		@ 75 , 5 SAY OemToAnsi(STR0011) Of oFolder:aDialogs[1] PIXEL //" - Data de Movimento"
		@ 85 , 5 SAY OemToAnsi(STR0012) Of oFolder:aDialogs[1] PIXEL //" - Valor do Lan�amento"
		@ 95 , 5 SAY OemToAnsi(STR0013) Of oFolder:aDialogs[1] PIXEL //" - C�digo do Rateio (fixo 0)"
		@ 105, 5 SAY OemToAnsi(STR0068) Of oFolder:aDialogs[1] PIXEL //" - C�digo do Lan�amento Padr�o"	
		@ 115, 5 SAY OemToAnsi(STR0015) Of oFolder:aDialogs[1] PIXEL //" - Texto Complementar"
		@ 125, 5 SAY OemToAnsi(STR0016) Of oFolder:aDialogs[1] PIXEL //" - Situa��o do Lan�amento (fixo N)"
		@ 135, 5 SAY OemToAnsi(STR0017) Of oFolder:aDialogs[1] PIXEL //" - Item Cont�bil"	
		
	ElseIf (lErpCmnet)
		@ 05 , 5 SAY OemToAnsi(STR0036) Of oFolder:aDialogs[1] PIXEL //"Gera��o do arquivo cont�bil para integra��o CMNET."
		@ 15 , 5 SAY OemToAnsi(STR0037) Of oFolder:aDialogs[1] PIXEL //"Ser�o exportadas as informa��es contabilizadas no GPE da tabela CT2. O arquivo possuir� as seguintes informa��es:"
		@ 25 , 5 SAY OemToAnsi(STR0038) Of oFolder:aDialogs[1] PIXEL //" - Data do Lan�amento"
		@ 35 , 5 SAY OemToAnsi(STR0039) Of oFolder:aDialogs[1] PIXEL //" - Tipo de Lan�amento (0,1,2)"
		@ 45 , 5 SAY OemToAnsi(STR0040) Of oFolder:aDialogs[1] PIXEL //" - Tipo de Lan�amento (D,C)"
		@ 55 , 5 SAY OemToAnsi(STR0041) Of oFolder:aDialogs[1] PIXEL //" - Compet�ncia (N�mero do Documento)"
		@ 65 , 5 SAY OemToAnsi(STR0042) Of oFolder:aDialogs[1] PIXEL //" - Hist�rico 1"
		@ 75 , 5 SAY OemToAnsi(STR0043) Of oFolder:aDialogs[1] PIXEL //" - Centro de Custo"	
		@ 85 , 5 SAY OemToAnsi(STR0044) Of oFolder:aDialogs[1] PIXEL //" - Conta Cont�bil"
		@ 95 , 5 SAY OemToAnsi(STR0045) Of oFolder:aDialogs[1] PIXEL //" - Valor do Lan�amento"
		@ 105, 5 SAY OemToAnsi(STR0046) Of oFolder:aDialogs[1] PIXEL //" - Item (SubConta)"
		@ 115, 5 SAY OemToAnsi(STR0047) Of oFolder:aDialogs[1] PIXEL //" - C�digo Hist�rico Padr�o"
		@ 125, 5 SAY OemToAnsi(STR0048) Of oFolder:aDialogs[1] PIXEL //" - Documento (Planilha)"
		@ 135, 5 SAY OemToAnsi(STR0049) Of oFolder:aDialogs[1] PIXEL //" - Linha (Lan�amento)"
	Else
		@ 5, 5 SAY OemToAnsi(STR0004) Of oFolder:aDialogs[1] PIXEL //"Ser�o exportadas as informa��es contabilizadas no GPE (Lote 008890) da Tabela CT2 com as seguintes informa��es separadas por pipe (|)"
		@ 15 , 5 SAY OemToAnsi(STR0025) Of oFolder:aDialogs[1] PIXEL //" - Empresa Protheus"
		@ 25 , 5 SAY OemToAnsi(STR0026) Of oFolder:aDialogs[1] PIXEL //" - Filial Protheus"		
		@ 35 , 5 SAY OemToAnsi(STR0006) Of oFolder:aDialogs[1] PIXEL //" - N�mero do Lote"
		@ 45 , 5 SAY OemToAnsi(STR0007) Of oFolder:aDialogs[1] PIXEL //" - C�digo do sistema (fixo GPE)"
		@ 55 , 5 SAY OemToAnsi(STR0008) Of oFolder:aDialogs[1] PIXEL //" - Data de refer�ncia"
		@ 65 , 5 SAY OemToAnsi(STR0009)+ OemToAnsi(STR0027) Of oFolder:aDialogs[1] PIXEL //" - N�mero da Conta"#" Debito, caso houver"
		@ 75 , 5 SAY OemToAnsi(STR0009)+ OemToAnsi(STR0028) Of oFolder:aDialogs[1] PIXEL //" - N�mero da Conta"#" Credito, caso houver"
		@ 85 , 5 SAY OemToAnsi(STR0010) Of oFolder:aDialogs[1] PIXEL //" - Tipo de Lan�amento"
		@ 95 , 5 SAY OemToAnsi(STR0011) Of oFolder:aDialogs[1] PIXEL //" - Data de Movimento"
		@ 105, 5 SAY OemToAnsi(STR0012) Of oFolder:aDialogs[1] PIXEL //" - Valor do Lan�amento"
		@ 115, 5 SAY OemToAnsi(STR0013) Of oFolder:aDialogs[1] PIXEL //" - C�digo do Rateio (fixo 0)"
		@ 125, 5 SAY OemToAnsi(STR0015) Of oFolder:aDialogs[1] PIXEL //" - Texto Complementar"
		@ 135, 5 SAY OemToAnsi(STR0016) Of oFolder:aDialogs[1] PIXEL //" - Situa��o do Lan�amento (fixo N)"
		@ 145, 5 SAY OemToAnsi(STR0017)+ OemToAnsi(STR0027) Of oFolder:aDialogs[1] PIXEL //" - Item Cont�bil"#" Debito, caso houver"
		@ 155, 5 SAY OemToAnsi(STR0017)+ OemToAnsi(STR0028)	Of oFolder:aDialogs[1] PIXEL //" - Item Cont�bil"#" Credito, caso houver"
	EndIf

	@ 165, 130	SAY OemToAnsi(STR0018) 	Of oFolder:aDialogs[1] PIXEL 	//"Destino: "
	@ 165, 155	MSGET oDirPesq VAR cDirPesq	PICTURE "@!"  Of oFolder:aDialogs[1] PIXEL SIZE 100,7
	@ (162)*2, (252)*2 	BTNBMP oBtn1 NAME "S4WB058N" SIZE 72,30 ACTION GetDirPesq(@cDirPesq)	 OF oFolder:aDialogs[1] PIXEL

	If !(lErpCmnet)
		@ 5, 5 SAY OemToAnsi(STR0031) Of oFolder:aDialogs[2] PIXEL

		aAdd(aHeader,{"OK?"					,"OK"		,"@BMP",05,0,"",,"C",,})
		aAdd(aHeader,{OemToAnsi(STR0035)	,"DESCR"	,""		,150,0,"",,"C",,})

		oGet := MsNewGetDados():New(10,5,120,100,,/*cLinhaOk*/,/*cTudoOk*/,/*cIniCpos*/,{},;
										0,999,/*cFieldOk*/,/*cSuperDel*/,/*"AllwaysTrue"*/,oFolder:aDialogs[2],aHeader,aCols)
		oGet:oBrowse:Align := CONTROL_ALIGN_BOTTOM
		oGet:Enable()
		oGet:GoTop()
	EndIf

	ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar( oDlgMain , bSet15 , bSet24 ) CENTERED

	PutMv("MV_PASCON",cDirPesq)	

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetDirPesq     �Autor  �Leandro Drumond  � Data �  23/01/13 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o diretorio selecionado pelo usuario.               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetDirPesq(cDirPesq)

	_oWnd := GetWndDefault()

	cDirPesq:=cGetFile(OemToAnsi(STR0019),OemToAnsi(STR0020),0,,.F.,GETF_LOCALHARD + GETF_RETDIRECTORY)

	If _oWnd != Nil
		GetdRefresh()
	EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GeraArquivo   �Autor  �Leandro Drumond  � Data �  23/01/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria arquivo para integracao com LOGIX.                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeraArquivo(cDirPesq, cCompetencia, cHist, cFilConDe, cFilConAte,lUsaEai)
	Local aAreas	:= {SM0->(GetArea()),GetArea()}
	Local aStruCT2	:= CT2->(dbStruct())
	Local aItemAux	:= {}
	Local aContaD	:= {}
	Local aContaC	:= {}
	Local aLinha	:= {} //array para montar linha do arquivo CMNET.
	Local aLog		:= {} //array para montar arquivo de log da operacao. Utilizado para CMNET.
	Local cQuery	:= ""
	Local cWhere	:= ""
	Local cFilAux	:= ""
	Local cFilLog	:= "" //Filial Logix
	Local cFilLogA	:= "" //Filial Logix Auxiliar
	Local cItemD	:= ""
	Local cItemC	:= ""
	Local cItem		:= ""
	Local cItemAux	:= ""
	Local cArquivo	:= ""
	Local cArqLog	:= "" //nome do arquivo do log da operacao. Utilizado para CMNET.
	Local cMsg		:= ""
	Local cContaD	:= ""
	Local cContaC	:= ""
	Local cConta	:= ""
	Local cTpLcto1	:= ""
	Local cTpLcto2	:= ""
	Local cLinha	:= ""
	Local cBalanco	:= ""
	Local cAliasTrb	:= GetNextAlias()
	Local dDataIni	:= CtoD("01/"+SubStr(cCompetencia,1,2)+"/"+SubStr(cCompetencia,3,4))
	Local dDataFim	:= CtoD(StrZero(f_UltDia(dDataIni),2)+"/"+SubStr(cCompetencia,1,2)+"/"+SubStr(cCompetencia,3,4))
	Local nArq		:= 0
	Local nArqLog	:= 0 //arquivo do log de operacao. Utilizado para CMNET.
	Local nErro		:= 0 //variavel para controle de emissao de mensagem de erro - validacao do programa
	Local nLinha	:= 0
	Local nX		:= 0
	Local nValDeb	:= 0
	Local nValCred	:= 0
	Local cLoteCT2	:= ""
	Local dDataLanc	:= CtoD("//") 
	Local cLote1	:= ""
	Local cSubLote	:= ""
	Local cDoc		:= ""
	Local cFilOrig	:= cFilAnt	
	Default lUsaEai	:= .F.

	if(lUsaEai)
		SM0->(DbSetOrder(1))	
	endIf

	If Empty(cDirPesq)  .And. !lUsaEai
		MsgInfo( STR0024, STR0002 ) // Atencao#"Diret�rio de destino n�o especificado"
		Return .F.
	EndIf

	cLoteCT2 := PadL(allTrim(cLote), tamsx3("CT2_LOTE")[1], "0")

	cWhere := "		CT2_FILIAL >= '" + xFilial("CT2",cFilConDe) + "' AND CT2_FILIAL <= '" + xFilial("CT2",cFilConAte) + "' AND "
	cWhere += "		CT2_DATA >= '" + DtoS(dDataIni) + "' AND CT2_DATA <= '" + Dtos(dDataFim) + "' AND "
	cWhere += "		CT2_LOTE = '"+cLoteCT2+"' AND "
	cWhere += "		D_E_L_E_T_=' ' "

	cQuery := "SELECT "
	if(lUsaEai)
		cQuery += " DISTINCT CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC "
	else
		cQuery += " * "
	endIf

	cQuery += " FROM " + InitSqlName( "CT2" ) + " WHERE "
	cQuery += cWhere
	cQuery += " AND CT2_SEQUEN IN ( SELECT MAX(CT2_SEQUEN) FROM " + InitSqlName("CT2") + " WHERE " + cWhere + " GROUP BY CT2_FILIAL) "
	cQuery += "		ORDER BY CT2_FILIAL, CT2_DATA "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb)
	if(lUsaEai)
		TcSetField(cAliasTrb,"CT2_DATA","D")
	else
		For nX := 1 To Len(aStruCT2)
			If ( aStruCT2[nX,2] <> "C" )
				TcSetField(cAliasTrb,aStruCT2[nX,1],aStruCT2[nX,2],aStruCT2[nX,3],aStruCT2[nX,4])
			EndIf
		Next nX
	endIf

	dbSelectArea(cAliasTrb)
	If (cAliasTrb)->( !Eof() )
		While (cAliasTrb)->( !Eof() )

			if(lUsaEai)/*Nesse caso ao inv�s de gerar o arquivo .txt ele vai gerar a mensagem �nica*/
				if((cAliasTrb)->CT2_FILIAL != xFilial("CT2"))/*Caso a Filial seja diferente muda*/
					SM0->(DbSeek(cEmpAnt + AllTrim((cAliasTrb)->CT2_FILIAL)))
					cFilAnt := PadR(SM0->M0_CODFIL,FWSizeFilial())
				endIf

				dDataLanc	:= (cAliasTrb)->CT2_DATA 
				cLote1		:= (cAliasTrb)->CT2_LOTE
				cSubLote	:= (cAliasTrb)->CT2_SBLOTE
				cDoc		:= (cAliasTrb)->CT2_DOC
				Private aReturn := {}

				/*Seta variaveis como falsas p/ que o CTBA102 entenda que deve enviar um XML de delecao*/
				INCLUI := .F.
				ALTERA := .F.
				/*Tenta executar a exclus�o antes do envio, caso exista.*/
				MsAguarde({||aReturn := CT102EAI(dDataLanc, cLote1, cSubLote, cDoc, cHist, "GPE")},"Aguarde","Processando[1]")

				/*Se a mensagem retornou .F. eh porque nao foi poss�vel efetuar a exclusao.
				Obs.:Quando nao ha registro a ser deletado o Logix retorna .T., dessa forma soh dah erro 
				quando realmente houver registro e ele nao puder ser deletado.*/
				if!(aReturn[1])
					aAdd(aCols,{oRed,Left(aReturn[2],99),.F.})

					oGet:SetArray(aCols,.T.)
		    		oGet:Refresh()
		    	else
					aSize(aReturn,0)
					INCLUI := .T.
					ALTERA := .T.
					/*Realiza o envio*/
					MsAguarde({||aReturn := CT102EAI(dDataLanc, cLote1, cSubLote, cDoc, cHist, "GPE")},"Aguarde","Processando[2]")

					aAdd(aCols,{IIF(aReturn[1],oGreen,oRed),Left(aReturn[2],99),.F.})

					oGet:SetArray(aCols,.T.)
					oGet:Refresh()
				endIf

				if(cFilAnt != cFilOrig) /*Restaura a Filial*/
					cFilAnt := cFilOrig
				endIf
			ElseIf lErpCmnet
				//posicoes aLinha: 
				//DtLcto; TpLcto1; TpLcto2;OrigemAplicacao;Nr.Doc;Hist1;Hist2;Hist3;Hist4;Hist5;CC;ContaContabil;Vlr.Lcto;
				//Vlr.Ofic.;Vlr.Geren.1;Vlr.Geren.2;Vlr.Geren.3;AtivProj;SubConta;HistPadrao;Planilha;Lcto;PlnoPrev;Patroc.
				If !(cFilAux == (cAliasTrb)->CT2_FILIAL)
					If !Empty(cFilAux) .AND. !Empty(nArq)
						FClose(nArq)
						cBalanco := fBalanco(nValDeb, nValCred) //verifica balanco final da contabilizacao
						aAdd(aLog, (OemToAnsi(STR0050) + cValToChar(nValDeb) + CRLF)) //"Valor a D�bito: "
						aAdd(aLog, (OemToAnsi(STR0051) + cValToChar(nValCred) + CRLF)) //"Valor a Cr�dito: "
						aAdd(aLog, (OemToAnsi(STR0052) + cBalanco + CRLF)) //"Balan�o: "
						aAdd(aLog, (OemToAnsi(STR0053)+CRLF)) //"Arquivo gerado com sucesso!"
						aAdd(aLog, (Replicate("-",50) + CRLF))
						nValDeb	:= 0
						nValCred	:= 0
						nLinha		:= 0
						cBalanco	:= ""
					EndIf
					cFilAux := (cAliasTrb)->CT2_FILIAL
					cArquivo:= cDirPesq + "contabFOL_" + Year2Str((cAliasTrb)->CT2_DATA) + Month2Str((cAliasTrb)->CT2_DATA) + "_" + FwGrpCompany() + AllTrim(cFilAux)+ "_" + STRTRAN(TIME(),":","") + ".TXT" //contabFOL_AAAA_MM_EMPFILIAL_seq.txt
					nArq	:= FCREATE(cArquivo, 0, , .F.)//Quarto parametro define que o arquivo sera criado com o nome id�ntico ao que est� sendo passado.
					If Ferror() # 0 .And. nArq = -1 
						cMsg := OemToAnsi(STR0021) + STR(Ferror(),3) //-- "Erro de Gravacao do Arquivo - Codigo DOS: "
						MsgInfo( cMsg, STR0002 ) // Atencao
						Return(.F.)
					EndIf
					aAdd(aLog, (OemToAnsi(STR0054)+ FwGrpCompany() + "/" + (cAliasTrb)->CT2_FILIAL + CRLF)) //"Empresa/Filial: "
					aAdd(aLog, (OemToAnsi(STR0055) + (cAliasTrb)->CT2_DOC + CRLF)) //"N�mero do Documento no Protheus: "
				EndIf
				If (cAliasTrb)->CT2_DC == "1"
					cTpLcto1 	:= "0"
					cTpLcto2 	:= "D"
					cCC 		:= (cAliasTrb)->CT2_CCD
					cConta 		:= (cAliasTrb)->CT2_DEBITO
					cItem 		:= (cAliasTrb)->CT2_ITEMD
					nValDeb		+= (cAliasTrb)->CT2_VALOR
					nLinha++
					aAdd(aLinha,{DtoC((cAliasTrb)->CT2_DATA),cTpLcto1,cTpLcto2,Space(1),PadR(Year2Str((cAliasTrb)->CT2_DATA)+"/"+Month2Str((cAliasTrb)->CT2_DATA),15),;
								(cAliasTrb)->CT2_HIST,Space(40),Space(40),Space(40),Space(40),PadR(cCC,10),PadR(cConta,18),StrZero((cAliasTrb)->CT2_VALOR,17,2),"00000000000000.00",;
								"00000000000000.00","00000000000000.00","00000000000000.00",Space(8),"00000000000000.00",PadR(cItem,6),PadR((cAliasTrb)->CT2_HP,4),;
								PadR((cAliasTrb)->CT2_DOC,8),PadR(cValToChar(nLinha),8),Space(10),Space(10) })
					For nX := 1 to Len(aLinha[1])
						cLinha += aLinha[1][nX]
					Next nX
					cLinha += CRLF
					Fwrite( nArq, cLinha )
					aLinha := {}
					cLinha := ""
				ElseIf (cAliasTrb)->CT2_DC == "2"
					cTpLcto1 	:= "1"
					cTpLcto2 	:= "C"
					cCC 		:= (cAliasTrb)->CT2_CCC
					cConta 		:= (cAliasTrb)->CT2_CREDIT
					cItem 		:= (cAliasTrb)->CT2_ITEMC
					nValCred	+= (cAliasTrb)->CT2_VALOR
					nLinha++
					aAdd(aLinha,{DtoC((cAliasTrb)->CT2_DATA),cTpLcto1,cTpLcto2,Space(1),PadR(Year2Str((cAliasTrb)->CT2_DATA)+"/"+Month2Str((cAliasTrb)->CT2_DATA),15),;
								(cAliasTrb)->CT2_HIST,Space(40),Space(40),Space(40),Space(40),PadR(cCC,10),PadR(cConta,18),StrZero((cAliasTrb)->CT2_VALOR,17,2),"00000000000000.00",;
								"00000000000000.00","00000000000000.00","00000000000000.00",Space(8),"00000000000000.00",PadR(cItem,6),PadR((cAliasTrb)->CT2_HP,4),;
								PadR((cAliasTrb)->CT2_DOC,8),PadR(cValToChar(nLinha),8),Space(10),Space(10) })
					For nX := 1 to Len(aLinha[1])
						cLinha += aLinha[1][nX]
					Next nX
					cLinha += CRLF
					Fwrite( nArq, cLinha )
					aLinha := {}
					cLinha := ""
				ElseIf (cAliasTrb)->CT2_DC == "3"
					cTpLcto1 := "2" //partida dobrada. Gera 2 linhas no arquivo.
					//linha 1 D
					cTpLcto2 	:= "D"
					cCC 		:= (cAliasTrb)->CT2_CCD
					cConta 		:= (cAliasTrb)->CT2_DEBITO
					cItem 		:= (cAliasTrb)->CT2_ITEMD
					nValDeb		+= (cAliasTrb)->CT2_VALOR
					nLinha++
					aAdd(aLinha,{DtoC((cAliasTrb)->CT2_DATA),cTpLcto1,cTpLcto2,Space(1),PadR(Year2Str((cAliasTrb)->CT2_DATA)+"/"+Month2Str((cAliasTrb)->CT2_DATA),15),;
								(cAliasTrb)->CT2_HIST,Space(40),Space(40),Space(40),Space(40),PadR(cCC,10),PadR(cConta,18),StrZero((cAliasTrb)->CT2_VALOR,17,2),"00000000000000.00",;
								"00000000000000.00","00000000000000.00","00000000000000.00",Space(8),"00000000000000.00",PadR(cItem,6),PadR((cAliasTrb)->CT2_HP,4),;
								PadR((cAliasTrb)->CT2_DOC,8),PadR(cValToChar(nLinha),8),Space(10),Space(10) })
					For nX := 1 to Len(aLinha[1])
						cLinha += aLinha[1][nX]
					Next nX
					cLinha += CRLF
					Fwrite( nArq, cLinha )
					aLinha := {}
					cLinha := ""

					//linha 2 C
					cTpLcto2 	:= "C"
					cCC 		:= (cAliasTrb)->CT2_CCC
					cConta 		:= (cAliasTrb)->CT2_CREDIT
					cItem 		:= (cAliasTrb)->CT2_ITEMC
					nValCred	+= (cAliasTrb)->CT2_VALOR
					nLinha++
					aAdd(aLinha,{DtoC((cAliasTrb)->CT2_DATA),cTpLcto1,cTpLcto2,Space(1),PadR(Year2Str((cAliasTrb)->CT2_DATA)+"/"+Month2Str((cAliasTrb)->CT2_DATA),15),;
								(cAliasTrb)->CT2_HIST,Space(40),Space(40),Space(40),Space(40),PadR(cCC,10),PadR(cConta,18),StrZero((cAliasTrb)->CT2_VALOR,17,2),"00000000000000.00",;
								"00000000000000.00","00000000000000.00","00000000000000.00",Space(8),"00000000000000.00",PadR(cItem,6),PadR((cAliasTrb)->CT2_HP,4),;
								PadR((cAliasTrb)->CT2_DOC,8),PadR(cValToChar(nLinha),8),Space(10),Space(10) })
					For nX := 1 to Len(aLinha[1])
						cLinha += aLinha[1][nX]
					Next nX
					cLinha += CRLF
					Fwrite( nArq, cLinha )
					aLinha := {}
					cLinha := ""
				Else
					//valor invalido!
					nErro:= 1 //variavel para emissao da mensagem de erro
					Exit
				EndIf
			Else
				If !cFilAux == (cAliasTrb)->CT2_FILIAL
					cFilAux := (cAliasTrb)->CT2_FILIAL
					cFilLogA := GetFilEAI(cEmpAnt,cFilAux)
					If !(cFilLogA == cFilLog)
						If !Empty(cFilLog)
							FClose(nArq)
						EndIf
						cFilLog := cFilLogA
						cArquivo:= cDirPesq + AllTrim(STRTRAN(cFilLog,"|","")) + "GPE" + substr((cAliasTrb)->CT2_SEQUEN,6,5) + ".CON"
						nArq := FCREATE(cArquivo, 0, , .F.)//Quarto parametro define que o arquivo sera criado com o nome id�ntico ao que est� sendo passado.
						If Ferror() # 0 .And. nArq = -1 
							cMsg := OemToAnsi(STR0021) + STR(Ferror(),3) //-- "Erro de Gravacao do Arquivo - Codigo DOS: "
							MsgInfo( cMsg, STR0002 ) // Atencao
							Return(.F.)
						EndIf
					EndIf
					If Empty(cFilLog)
						MsgInfo(  OemToAnsi(STR0022),STR0001 ) //Aviso#N�o h� DE/PARA de c�digos entre Empresa/Filial Protheus X Empresa Externa (APCFG050) no Configurador.
						Exit
					EndIf
				EndIf
				If lErpLogix
					If (cAliasTrb)->CT2_DC $ "1|3"
						If Empty((cAliasTrb)->CT2_ITEMD)
							cItemD	:= "0|0|0|0
						Else
							cItemAux := If(Len((cAliasTrb)->CT2_ITEMD) < 8,(cAliasTrb)->CT2_ITEMD + Space(8-(Len((cAliasTrb)->CT2_ITEMD))),(cAliasTrb)->CT2_ITEMD)
							aItemAux := {If(Empty(SubStr(cItemAux,1,2)),"0",AllTrim(SubStr(cItemAux,1,2))),If(Empty(SubStr(cItemAux,3,2)),"0",AllTrim(SubStr(cItemAux,3,2))),If(Empty(SubStr(cItemAux,5,2)),"0",AllTrim(SubStr(cItemAux,5,2))),If(Empty(SubStr(cItemAux,7,2)),"0",AllTrim(SubStr(cItemAux,7,2)))}
							cItemD   := aItemAux[1] + "|" + aItemAux[2] + "|" + aItemAux[3] + "|" + aItemAux[4]
						EndIf
						cContaD := CFGA070Ext( "LOGIX", 'CT1', 'CT1_CONTA', cEmpAnt + "|" + xFilial("CT1") + "|" + (cAliasTrb)->CT2_DEBITO)
						If Empty(cContaD)
							cContaD := (cAliasTrb)->CT2_DEBITO
						Else
							aContaD := Separa(cContaD,"|")
							If Len(aContaD) > 1
								cContaD := aContaD[2]
							Else
								cContaD := aContaD[1]
							EndIf
						EndIf
						cLinha := AllTrim(cFilLog) + "|" + AllTrim((cAliasTrb)->CT2_SEQUEN) + "|" + "GPE" + "|" + DtoC((cAliasTrb)->CT2_DATA) + "|" + AllTrim(cContaD) + "|" + "D" + "|" + DtoC((cAliasTrb)->CT2_DATA) + "|" + CVALTOCHAR((cAliasTrb)->CT2_VALOR) + "|" + "0" + "|" + If(Empty(cHist), (cAliasTrb)->CT2_LP, cHist) + "|" + AllTrim((cAliasTrb)->CT2_HIST) + "|" + "N" + "|" + cItemD + CRLF
						Fwrite( nArq, cLinha )
					EndIf
					If (cAliasTrb)->CT2_DC $ "2|3"
						If Empty((cAliasTrb)->CT2_ITEMC)
							cItemC	:= "0|0|0|0
						Else
							cItemAux := If(Len((cAliasTrb)->CT2_ITEMC) < 8,(cAliasTrb)->CT2_ITEMC + Space(8-(Len((cAliasTrb)->CT2_ITEMC))),(cAliasTrb)->CT2_ITEMC)
							aItemAux := {If(Empty(SubStr(cItemAux,1,2)),"0",AllTrim(SubStr(cItemAux,1,2))),If(Empty(SubStr(cItemAux,3,2)),"0",AllTrim(SubStr(cItemAux,3,2))),If(Empty(SubStr(cItemAux,5,2)),"0",AllTrim(SubStr(cItemAux,5,2))),If(Empty(SubStr(cItemAux,7,2)),"0",AllTrim(SubStr(cItemAux,7,2)))}
							cItemC   := aItemAux[1] + "|" + aItemAux[2] + "|" + aItemAux[3] + "|" + aItemAux[4]
						EndIf
						cContaC := CFGA070Ext( "LOGIX", 'CT1', 'CT1_CONTA', cEmpAnt + "|" + xFilial("CT1") + "|" + (cAliasTrb)->CT2_CREDIT)
						If Empty(cContaC)
							cContaC := (cAliasTrb)->CT2_CREDIT
						Else
							aContaC := Separa(cContaC,"|")
							If Len(aContaC) > 1
								cContaC := aContaC[2]
							Else
								cContaC := aContaC[1]
							EndIf
						EndIf
						cLinha := AllTrim(cFilLog) + "|" + AllTrim((cAliasTrb)->CT2_SEQUEN) + "|" + "GPE" + "|" + DtoC((cAliasTrb)->CT2_DATA) + "|" + AllTrim(cContaC) + "|" + "C" + "|" + DtoC((cAliasTrb)->CT2_DATA) + "|" + CVALTOCHAR((cAliasTrb)->CT2_VALOR) + "|" + "0" + "|" + If(Empty(cHist), (cAliasTrb)->CT2_LP, cHist) + "|" + AllTrim((cAliasTrb)->CT2_HIST) + "|" + "N" + "|" + cItemC + CRLF
						Fwrite( nArq, cLinha )
					EndIf
				Else
					cLinha := AllTrim(cFilLog) + "|" + AllTrim((cAliasTrb)->CT2_SEQUEN) + "|" + "GPE" + "|" + DtoC((cAliasTrb)->CT2_DATA) + "|" + AllTrim((cAliasTrb)->CT2_DEBITO) + "|" + AllTrim((cAliasTrb)->CT2_CREDIT) + "|" + AllTrim((cAliasTrb)->CT2_DC) + "|" + DtoC((cAliasTrb)->CT2_DATA) + "|" + CVALTOCHAR((cAliasTrb)->CT2_VALOR) + "|" + "0" + "|" + cHist + "|" + AllTrim((cAliasTrb)->CT2_HIST) + "|" + "N" + "|" + AllTrim((cAliasTrb)->CT2_ITEMD) + "|" + AllTrim((cAliasTrb)->CT2_ITEMC) + CRLF
					Fwrite( nArq, cLinha )
				EndIf
			endIf

			dbSelectArea(cAliasTrb)
			dbSkip()
		EndDo
		If lErpCmnet .AND. !Empty(aLog) //arquivo de log
			cArqLog	:= cDirPesq + "contabFOL_Log_" + DTOS(Date()) + "_" + STRTRAN(TIME(),":","") + ".TXT" //contabFOL_Log_data.txt
			nArqLog := FCREATE(cArqLog, 0, , .F.)//Quarto parametro define que o arquivo sera criado com o nome id�ntico ao que est� sendo passado.
			If Ferror() # 0 .And. nArqLog = -1 
				cMsg := OemToAnsi(STR0021) + STR(Ferror(),3) //-- "Erro de Gravacao do Arquivo - Codigo DOS: "
				MsgInfo( cMsg, STR0002 ) // Atencao
				Return(.F.)
			EndIf
			If nErro == 0
				cBalanco := fBalanco(nValDeb, nValCred) //verifica balanco final da contabilizacao
				cBalanco += CRLF + OemToAnsi(STR0053) //"Arquivo gerado com sucesso!"
			ElseIf nErro == 1 //Tipo de Lancamento incorreto
				cBalanco := OemToAnsi(STR0064) + CRLF //"Execu��o interrompida."
				cBalanco += OemToAnsi(STR0062) + (cAliasTrb)->CT2_LINHA + "(CT2_LINHA)" + CRLF //"Erro na linha: "
				cBalanco += OemToAnsi(STR0066) + (cAliasTrb)->CT2_LP + CRLF //Lancamento Padrao:"
				cBalanco += OemToAnsi(STR0065) + OemToAnsi(STR0056) //"Mensagem: "
			EndIf
			aAdd(aLog, (OemToAnsi(STR0050) + cValToChar(nValDeb) + CRLF)) //"Valor a D�bito: "
			aAdd(aLog, (OemToAnsi(STR0051) + cValToChar(nValCred) + CRLF)) //"Valor a Cr�dito: "
			aAdd(aLog, (OemToAnsi(STR0052) + cBalanco + CRLF)) //"Balan�o: "
			aAdd(aLog, (Replicate("-",50) + CRLF))	
			For nX:= 1 to Len(aLog)
				Fwrite(nArqLog,aLog[nX])
			Next nX
			FClose(nArqLog)
		EndIf
		If (nArq != 0)
			FClose(nArq)
			If !(lErpCmnet)
				MsgInfo(  "Arquivo ["+ cArquivo + "] gerado com sucesso.", STR0001 )
			Else
				If nErro == 0
					MsgInfo(OemToAnsi(STR0053) + OemToAnsi(STR0057), STR0001 )//"Arquivo(s) gerado(s) com sucesso!"#"Verifique o log para mais informa��es."
				Else
					MsgInfo(OemToAnsi(STR0063) +" "+ OemToAnsi(STR0057), STR0001 )//"Ocorreu erro durante a montagem dos arquivos. "#"Verifique o log para mais informa��es."
				EndIf
			EndIf
		EndIf
	Else
		MsgInfo( OemToAnsi(STR0023), STR0001 ) //Aviso#N�o existem informacoes para serem contabilizadas no Sistema Externo.
	EndIf

	aEval(aAreas,{|x|RestArea(x)})
Return .F.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetFilEAI  �Autor  �Leandro Drumond  � Data �  23/01/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carregar informacoes do DE/PARA de empresa/filial LOGIX.    ���
���          �Frame nao dispoe de nenhuma funcao para tal                 ���
���          �FWEAIEMPFIL, que nao possui documentacao, eh usada apenas p/���
���          �obter a empresa filial protheus.                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetFilEAI(cEmpPrt,cFilPrt)
	Local aArea 	:= GetArea()
	Local cFilRet   := ""
	Local aTemp		:= {}
	
	If lErpLogix

		//Testar tamanho do array pra evitar erro.
		aTemp := FWEAIEMPFIL( cEmpPrt, cFilPrt, "LOGIX",.T.) 
		if(Len(aTemp) < 2)	
			Return cFilRet						
		endIf
		cFilRet := aTemp[1] 

		//Ponto de entrada que permite customizar 
		//o codigo de filial utilizado no retorno
		If ExistBlock("GP110LgxF")
			cFilRet := ExecBlock("GP110LgxF", .F., .F.,{cFilPrt})
		EndIf	
	Else
		cFilRet := cEmpPrt + "|" + cFilPrt
	EndIf
	
	RestArea(aArea)
Return cFilRet

/*/{Protheus.doc} GetMesAno
	Retorna cMesAno(MMAAAA), ao contraio da funcao MesAno, que retorna cAnoMes(AAAAMM)
@author PHILIPE.POMPEU
@since 27/05/2016
@version P11
@param dData, data, valor do tipo Data
@return cMesAno, caractere, valor no formato MMAAAA
/*/
Static Function GetMesAno(dData)
	Local cMesAno := "" 
	Default dData := IIF((Type('dDatabase') == 'D'), dDatabase, Date())
	
	cMesAno := StrZero(Month(dData),2) + cValToChar(Year(dData))
	
Return cMesAno

/*/{Protheus.doc} fBalanco
	Retorna o balanco final da contabilizacao da Filial, a partir dos valores a Debito e Credito enviados.
@author esther.viveiro
@since 11/04/2017
@version P12.1.16
@param nValDeb, numerico, total de valores a Debito
@param nValCred, numerico, total de valores a Credito
@return cBalanco, caractere, saldo final - indicando se esta a maior em Debito/Credito ou balanceado.
/*/
Static Function fBalanco(nValDeb, nValCred)
	Local cBanlanco	:= ""
	Default nValDeb	:= 0
	Default nValCred	:= 0

	If nValDeb > nValCred
		cBalanco:= OemToAnsi(STR0058) + cValToChar(nValDeb - nValCred) + OemToAnsi(STR0059)//"Saldo de "#" a Debito."
	ElseIf nValDeb < nValCred
		cBalanco:= OemToAnsi(STR0058) + cValToChar(nValCred - nValDeb) + OemToAnsi(STR0060)//"Saldo de "#" a Cr�dito."
	Else
		cBalanco:= OemToAnsi(STR0061)//"Documento balanceado."
	EndIf

Return cBalanco
