#Include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GNREON    ºAutor  ³Natalia Antonucci   º Data ³  22/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Preparacao do meio magnetico GNREON - A Guia Nacional de    º±±
±±º          ³Recolhimento de Tributos Estaduais, tem sido um documento   º±±
±±º          ³de uso habitual por todos os contribuintes que realizam     º±±
±±º          ³operações de vendas interestaduais sujeitas à substituição  º±±
±±º          ³tributária.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GNREON()
Local lEnd      := .F.
Local aWizard   := {}
Local cNomWiz   := "GNREON"
Local aArea     := GetArea()
Local aAreaSM0  := SM0->(GetArea())
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

If lVerpesssen
	cMsg := 'Está disponível a rotina para Transmissão da GNRE via Web Service.' + CRLF
	cMsg += 'Para maiores esclarecimentos acesse http://tdn.totvs.com/x/8JMGDg.'

	MsgInfo(cMsg)
	If Wizard(cNomWiz)
		Processa({||PrGNREON(@lEnd, aWizard)})
	EndIf
EndIf 

RestArea(aAreaSM0)
RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrGNREON  ºAutor  ³Natalia Antonucci   º Data ³  22/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao principal de processamento do arq. magnetico GNREON  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrGNREON(lEnd,aWizard)
Local cFilDe     := ""
Local cFilAte    := ""
Local cDir       := ""
Local cFileDest  := "GNREON.XML"
Local cNomeCfp   := "GNREON"
Local cMvEstado  := ""
Local cAliasSF6  := "SF6"
Local cFiltro    := ""
Local cIndex     := ""
Local cXml       := ""
lOCAL cCodR      := ""
Local cInsc      := ""
Local cFilBkp    := ""
Local cTipoDoc   := ""
Local cTipoRef   := ""
Local cChvDoc    := ""
Local cCodDoc    := ""
Local cCodRec    := ""
Local cTpPessoa  := ""
Local cSubTrib   := ""
Local cFoneEmi   := ""
Local cEspecie   := ""
Local lCliente   := .T.
Local lChaveNF   := .F.
Local cCODRECAP  := GetNewPar("MV_RECEAPU","") //Informe codigo da receita por Apuracao.
Local cMVSUBTRIB := IIf(FindFunction("GETSUBTRIB"), GetSubTrib(), SuperGetMv("MV_SUBTRIB")) //Numero da Inscricao Estadual do contribuinte em outro estado quando houver Substituicao Tributaria.
Local cMVUFGNRE  := GetNewPar("MV_UFGNRE" ,"") //Apenas as UF's que possuem GNRE Online.
Local dDataDe    := ctod("//")
Local dDataAte   := ctod("//")
Local aAreaSM0   := SM0->(GetArea())
Local aFieldDt   := {}
Local aTelEmi    := {}
//-- Referencia Periodo
Local aPeriodo   :=	{	{"AC","100021"},;
						{"AL","100099"},;
						{"AM","100099|100013|100021|100030|100056|100080|100102"},;
						{"AP","100102|100110"},;
						{"BA","100013|100021|100030|100099|100102|100110|100129|100137"},;
						{"CE","100110|100137"},;
						{"DF","100013|100030"},;
						{"GO","100110"},;
						{"MA","100013|100021|100030"},;
						{"PE","100013"},;
						{"PR","100013|100021|100030|100110"},;
						{"RR","100013"},;
						{"RS","100013|100021|100110|100137"},;
						{"SC","100110"},;
						{"SE","100102|100056|100099|100110|100129"}}

//-- Participante Destinatario
Local aPartDest  :=	{	{"AC","100099|100102|100110"},;
						{"AL","100056|100099|100102|100129"},;
						{"AM","100021|100030|100099|100102"},;
						{"AP","100099|100102"},;
						{"CE","100099|100102|100129"},;
						{"GO","100056|100099|100102"},;
						{"MA","100013|100021|100056|100099|100102|100129"},;
						{"MG","100099"},;
						{"MS","100056|100099|100102|100129"},;
						{"MT","100030|100056|100080|100099"},;
						{"PA","100099|100102|100110"},;
						{"PB","100013"},;
						{"PE","100099|100102|100129"},;
						{"PI","100099|100102|100129"},;
						{"RN","100013|100021|100056|100099|100102|100129"},;
						{"RS","100099|100102|100129"},;
						{"SE","100056|100099|100102|100129"},;
						{"TO","100030|100056|100102|100110|100129|100137|100099"} }

//-- Campos Extras
Local aTagEx     :=	{	{"AC","100102|100110"},;
						{"AL","100013|100021|100030|100056|100080|100102|100129"},;
						{"AM","100030"},;
						{"BA","100102|100129"},;
						{"CE","100080"},;
						{"GO","100013|100021|100030|100056"},;
						{"MA","100102|100110|100129|100137"},;
						{"MG","100013|100021|100030|100056|100080"},;
						{"MS","100102|100129"},;
						{"PB","100102|100129|100137"},;
						{"PE","100013|100080|100102"},;
						{"PI","100056"},;
						{"PR","100056|100102"},;
						{"RN","100013|100021|100030|100056|100080"},;
						{"RO","100102"},;
						{"RS","100013|100030|100056|100080|100102|100110|100129|100137"},;
						{"RR","100013|100021|100048|100056|100080|100099|100102|100110"},;
						{"SC","100102"},;
						{"TO","100099|100102|100110|100129|100137"}}

//-- Campos Extras - Informacoes complementares e Observacao
Local aTipoExc   :=	{	{"AL","65"},;
						{"AM","13"},;
						{"CE","54"},;
						{"GO","10"},;
						{"MG","45"},;
						{"PE","04"},;
						{"PI","11"},;
						{"PR","56"},;
						{"RN","61"},;
						{"RR","71"},;
						{"RS","62"},;
						{"AC","68"},;
						{"GO","10"},;
						{"TO","72"},;
						{"SE","73"} }

//Chave NF-e Novos Codigos 
Local aUFChvNFe   := {	{"AC", "100102|100110|100099"				, "76"},;
						{"AM", "100099|100102"						, "12"},;
						{"AP", "100099|100102"						, "47"},;
						{"BA", "100102|100129"						, "86"},;
						{"MA", "100102|100129"						, "94"},;
						{"MS", "100099"								, "27"},;
						{"MS", "100102|100129"						, "88"},;
						{"MT", "100099|100102|100129"				, "17"},;
						{"PB", "100099|100102|100129"				, "30"},;
						{"PE", "100099"						      	, "9"},;
						{"PE", "100102"						      	, "92"},;
						{"PR", "100102"								, "107"},;
						{"RO", "100099|100102"						, "83"},;
						{"RR", "100099|100102"						, "36"},;
						{"RS", "100030|100080|100099|100102|100129", "74"},;
						{"SC", "100099|100102"						, "84"},;
						{"SE", "100099|100102|100129"				, "77"},;
						{"TO", "100099|100102|100129"				, "80"} }

Local nIndex     := 0
Local nCount     := 0
Local nLote      := 0
Local nX         := 0

Local nPos       := 0
Local nPosEx     := 0
Local nPosIni    := 0
Local nPosFim    := 0

Local lGerou     := .F.
Local lQuery     := .F.
Local lParcela   := .F.
Local cSerieFil  := ""
Local cCond      := ""
Local cLib       := ''
Local lHtml      := .F.
Local cStartPath := AllTrim(GetSrvProfString("StartPath",""))
Local nRetType	 := 0

#IFDEF TOP
	Local cFilBack  := cFilAnt
	Local aFilsCalc := {}
	Local aFilClone := {}
	Local lPriFil   := .T.
	Local lSelFil   := .F.
	Local lAglFil   := .F.
	Local nPosFil   := 0
#ENDIF

nRetType := GetRemoteType(@cLib)
lHtml:= Iif(nRetType == 5 ,.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atribuo o conteudo do CFP gerado pelo wizard no array aWizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (!xMagLeWiz (cNomeCfp, @aWizard, .T.))
	Return	//Se por algum motivo a leitura do CFP falhar aborto a rotina.
EndIf

dDataDe  := SToD(aWizard[1][1])
dDataAte := SToD(aWizard[1][2])
cDir     := Alltrim(aWizard[1][3])
cFileDest:= AllTrim(aWizard[1][4])
cFilDe   := Alltrim(aWizard[1][5])
cFilAte  := Alltrim(aWizard[1][6])
cSerieFil:= Alltrim(aWizard[1][9])

If ( ( Month(dDataAte) == 3 .and. Year(dDataAte) == 2017 ) .or. ( Month(dDataDe) == 3 .and. Year(dDataDe) == 2017 ) ) .and. cPaisLoc == 'BRA'
	BannerTAF()
	cFileDest := ''
	Return .F.
Endif

cCond	:=	"%"
If Len(Alltrim(cSerieFil)) > 0
	If Substr(cSerieFil,Len(Alltrim(cSerieFil)), Len(Alltrim(cSerieFil))) <> ';'
		cSerieFil += ';'
	EndIf
	
	cCond	+=	" SF6.F6_SERIE IN ("
	nPosIni	:= 1
	nPosFim	:= AT(';',cSerieFil)
	While	nPosIni < Len(Alltrim(cSerieFil))
		cCond	+=	"'" + Substr(Alltrim(cSerieFil),nPosIni,nPosFim - 1) + "'"
		nPosIni := nPosIni + nPosFim
		nPosFim   := AT(';',Substr(Alltrim(cSerieFil),nPosIni,Len(Alltrim(cSerieFil))))
	
		If 	nPosIni < Len(Alltrim(cSerieFil))
			cCond	+=	","
		EndIf
	EndDo
	cCond	+=	") AND "
EndIf
cCond	+=	"%"

cCodRec += Iif((aWizard[2][1])="T","100013/","N/") //"100013 - ICMS Comunição"
cCodRec += Iif((aWizard[2][2])="T","100021/","N/") //"100021 - ICMS Energia Elétrica"
cCodRec += Iif((aWizard[2][3])="T","100030/","N/") //"100030 - ICMS Transporte"
cCodRec += Iif((aWizard[2][4])="T","100048/","N/") //"100048 - ICMS ST por Apuração"
cCodRec += Iif((aWizard[2][5])="T","100056/","N/") //"100056 - ICMS Importação"
cCodRec += Iif((aWizard[2][6])="T","100080/","N/") //"100080 - ICMS Recolhimento Especiais"
cCodRec += Iif((aWizard[2][7])="T","100099/" ,"N/" ) //"100099 - ICMS ST por Operação"
cCodRec += Iif((aWizard[2][8])="T","100102/" ,"N/" ) //"100102 - ICMS Consumidor Final não contribuinte outra UF por Operação"
cCodRec += Iif((aWizard[2][9])="T","100110/" ,"N/" ) //"100110 - ICMS Consumidor Final não contribuinte outra UF por Apuração"
cCodRec += Iif((aWizard[2][10])="T","100129/","N/" ) //"100129 - ICMS Fundo Estadual de Combate à Pobreza por Operação"
cCodRec += Iif((aWizard[2][11])="T","100137","N" ) //"100137 - ICMS Fundo Estadual de Combate à Pobreza por Apuração"


#IFDEF TOP
	lSelFil := (  aWizard[1][7] == 'Sim')
	lAglFil := ( (aWizard[1][8] == 'Sim') .And. lSelFil )

	If !lSelFil
		cFilDe := cFilAte := cFilAnt
		Aadd(aFilsCalc,{.T., SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC,SM0->M0_INSC})
	Else
		aFilsCalc := MatFilCalc( lSelFil, , , (lSelFil .and. lAglFil), , 2 )
	EndIf

	If lSelFil .And. ( Len(aFilsCalc) >= 1 )
		aFilClone := aSort(aFilsCalc, , , { | x,y | x[2] < y[2] } )
		cFilDe  := aFilClone[01][02]
		cFilAte := aFilClone[Len(aFilClone)][02]
	EndIf
#EndIf

//Trata Diretorio
If (SubStr (cDir, Len (cDir), 1)<>"\")
	cDir += "\"
EndIf

//Definicao da ordem das tabelas

DbSelectArea("SA1") //Cadastro do Cliente
SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

DbSelectArea("SA2") //Cadastro de Fornecedor
SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA

DbSelectArea("SF6") //GNRE
SF6->(DbSetOrder(1)) //F6_FILIAL+F6_EST+F6_NUMERO

DbSelectArea("SF3") //Livros Fiscais
SF3->(dbSetOrder(4)) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE

cFilBKP := SM0->M0_CODFIL
aAreaSM0 := SM0->(GetArea())
DbSelectArea("SM0")
SM0->(DbGoTop())
SM0->(DbSeek (cEmpAnt+cFilDe, .T.))	//Pego a filial mais proxima 
Do While !SM0->(Eof()) .And. (cEmpAnt==SM0->M0_CODIGO .And. SM0->M0_CODFIL <= cFilAte) 
	cFilAnt := SM0->M0_CODFIL
	cMvEstado := GetNewPar("MV_ESTADO", "")

	DbSelectArea("SF6")
	SF6->(DbSetOrder(1))
	#IFDEF TOP

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se foram selecionadas as filiais, identifica se a filial posicionada esta selecionada no array³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSelFil .and. ( ( nPosFil := aScan(aFilsCalc,{|x| Alltrim(x[2]) == Alltrim(SM0->M0_CODFIL)}) ) = 0 .or. !aFilsCalc[nPosFil,1] )
			SM0->(dbSkip())
			Loop
		EndIf

		If (TcSrvType ()<>"AS/400")
			lQuery    := .T.
			cAliasSF6 := GetNextAlias()

			aAdd(aFieldDt,"F6_DTVENC")
			aAdd(aFieldDt,"F6_DTPAGTO")

			BeginSql Alias cAliasSF6
				SELECT SF6.F6_FILIAL, SF6.F6_DTARREC, SF6.F6_MESREF, SF6.F6_EST, SF6.F6_CODREC, SF6.F6_TIPOIMP, SF6.F6_VALOR, SF6.F6_ANOREF,
				SF6.F6_DOC, SF6.F6_NUMCONV, SF6.F6_CLIFOR, SF6.F6_LOJA, SF6.F6_NUMERO, SF6.F6_DTVENC, SF6.F6_DTPAGTO, SF6.F6_OPERNF,
				SF6.F6_SERIE, SF6.F6_MULTA, SF6.F6_JUROS, SF6.F6_ATMON, SF6.F6_CODPROD, SF6.F6_REF, SF6.F6_INF, SF6.F6_DESCOMP, SF6.F6_TIPODOC, SF6.F6_INSC, SF6.F6_CNPJ, SF6.F6_DETRECE, F6_PROCESS, SF6.F6_OBSERV
				FROM
					%Table:SF6% SF6
				WHERE
					SF6.F6_FILIAL=%xFilial:SF6% AND
					SF6.F6_DTARREC>=%Exp:dDataDe% AND
					SF6.F6_DTARREC<=%Exp:dDataAte% AND
					(SF6.F6_TIPOIMP = '3' OR SF6.F6_TIPOIMP = 'B') AND
					SF6.F6_EST <> %Exp:cMvEstado% AND
					%Exp:cCond%
					SF6.%NotDel%
				ORDER BY %Order:SF6%
			EndSql
			For nX := 1 To Len(aFieldDt)
				TcSetField(cAliasSF6,aFieldDt[nX],"D",8,0)
			Next nX
		Else
	#EndIf
			cIndex  := CriaTrab(NIL,.F.)
			cFiltro := 'F6_FILIAL=="'+xFilial ("SF6")+'".And.'
			cFiltro += 'DToS (F6_DTARREC)>="'+DToS (dDataDe)+'".And.DToS (F6_DTARREC)<="'+DToS (dDataAte)+'" '
			cFiltro += '.And. (F6_TIPOIMP =="3" .Or. F6_TIPOIMP =="B")'
			cFiltro += '.And. F6_OPERNF =="2" '
			cFiltro += '.And. F6_EST <> "'+cMvEstado+'" '
			IndRegua (cAliasSF6, cIndex, SF6->(IndexKey ()),, cFiltro)
			nIndex := RetIndex(cAliasSF6)
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF
			dbSelectArea (cAliasSF6)
			dbSetOrder (nIndex+1)
	#IFDEF TOP
		EndIf
	#EndIf

	DbSelectArea (cAliasSF6)
	(cAliasSF6)->(DbGoTop ())
	ProcRegua ((cAliasSF6)->(RecCount ()))
	#IFDEF TOP
		If !lAglFil
			cNomeArq := cFileDest+cFilAnt
			nLote    := 1
			lGerou   := .F.
		Else
			cNomeArq := cFileDest+cFilBack
		EndIf
	#ELSE
		cNomeArq := cFileDest+cFilAnt
		nLote    := 1
		lGerou   := .F.
	#EndIf
	cNomeArq := StrTran(cNomeArq," ","")

	//Telefone emitente
	aTelEmi	:= FisGetTel(SM0->M0_TEL)
	cFoneEmi 	:= IIF(aTelEmi[2] > 0,ConvType(aTelEmi[2],3),"") // Código da Área
	cFoneEmi 	+= IIF(aTelEmi[3] > 0,ConvType(aTelEmi[3],9),"") // Código do Telefone

	While !(cAliasSF6)->(Eof ())
		nCount := 0
		#IFDEF TOP
			If !lAglFil .Or. lPriFil
				cXml := ""
				cXml := GrvCab(nLote,@cNomeArq)
				lPriFil := .F.
			EndIf
		#EndIf
		While !(cAliasSF6)->(Eof ()) .And. nCount < 50

			cSubTrib := Alltrim(SubStr((cAliasSF6)->F6_EST,1,2)+(cAliasSF6)->F6_INSC)
			lGrava   := .F.
			If Empty((cAliasSF6)->F6_PROCESS) .Or. (cAliasSF6)->F6_PROCESS=="2"
				lGerou := .T.
				If (cAliasSF6)->F6_EST$cMVUFGNRE
					cInsc := IESubTrib((cAliasSF6)->F6_EST)
					cCodR := IIf(!Empty(cCODRECAP), cCODRECAP, Alltrim((cAliasSF6)->F6_CODREC))

					If (cAliasSF6)->F6_OPERNF == "2" .And. !Alltrim((cALiasSF6)->F6_TIPODOC) $ "B|D"
						SA1->(Dbseek(xFilial("SA1")+(cAliasSF6)->F6_CLIFOR+(cAliasSF6)->F6_LOJA))
						cTpPessoa := RetPessoa(SA1->A1_CGC)
						lCliente  := .T.
					Else
						SA2->(Dbseek(xFilial("SA2")+(cAliasSF6)->F6_CLIFOR+(cAliasSF6)->F6_LOJA))
						cTpPessoa := RetPessoa(SA2->A2_CGC)
						lCliente  := .F.
					EndIf

					SF3->(dbSeek(xFilial("SF3")+(cAliasSF6)->F6_CLIFOR+(cAliasSF6)->F6_LOJA+(cAliasSF6)->F6_DOC+(cAliasSF6)->F6_SERIE))

					If cSubTrib$cMVSUBTRIB .And. "100048"$(cCodRec) .And. cCodR == "100048"
						lGrava := .T.
						cXml += MontaXML("TDadosGNRE",,,,,,5,.T.,.F.,.T.)
						cXml += MontaXML("c01_UfFavorecida",(cAliasSF6)->F6_EST,,,,,9,.T.,.T.,.T.)
						cXml += MontaXML("c02_receita",cCodR,"C",9,2,,9,.T.,.T.,.T.)

						If !Empty((cAliasSF6)->F6_DETRECE)
							cXml += MontaXML("c25_detalhamentoReceita",AllTrim((cAliasSF6)->F6_DETRECE),"C",9,2,,9,.T.,.T.,.T.)
						EndIf

						If (cAliasSF6)->F6_CODPROD > 0 .AND. (cAliasSF6)->F6_EST$"AL/GO/MA/MG/PI/RN/RO/SE/TO/CE/MS/RR/DF"
							cXml += MontaXML("c26_produto",(cAliasSF6)->F6_CODPROD,"N",9,2,,9,.T.,.T.,.T.)
						EndIf

						If !Empty((cAliasSF6)->F6_DOC)
							cXml += MontaXML("c28_tipoDocOrigem","10","C",9,2,,9,.T.,.T.,.T.)
							cXml += MontaXML("c04_docOrigem",(cAliasSF6)->F6_DOC,"C",9,2,,9,.T.,.T.,.T.)
						EndIf

						If (cAliasSF6)->F6_VALOR > 0
							cXml += MontaXML("c06_valorPrincipal",(cAliasSF6)->F6_VALOR,"N",9,2,"@R 9999999999999999999.99",9,.T.,.T.,.T.)
						EndIf

						If (cAliasSF6)->F6_VALOR > 0 .or. (cAliasSF6)->F6_ATMON > 0 .or. (cAliasSF6)->F6_JUROS > 0 .or. (cAliasSF6)->F6_MULTA > 0
							cXml += MontaXML("c10_valorTotal",(cAliasSF6)->F6_VALOR+(cAliasSF6)->F6_ATMON+(cAliasSF6)->F6_JUROS+(cAliasSF6)->F6_MULTA,"N",9,2,"@R 9999999999999999999.99",9,.T.,.T.,.T.)
						EndIf

						cXml += MontaXML("c14_dataVencimento",StrZero (Year ((cAliasSF6)->F6_DTVENC), 4)+"-"+StrZero (Month ((cAliasSF6)->F6_DTVENC), 2)+"-"+StrZero (Day ((cAliasSF6)->F6_DTVENC), 2),"C",,,,9,.T.,.T.,.T.)

						If !Empty((cAliasSF6)->F6_NUMCONV)
							cXml += MontaXML("c15_convenio",(cAliasSF6)->F6_NUMCONV,"N",9,2,,9,.T.,.T.,.T.)
						EndIf

						cXml += MontaXML("c17_inscricaoEstadualEmitente",cInsc,,,,,9,.T.,.T.,.T.)

						cXml += MontaXML("c33_dataPagamento",StrZero (Year ((cAliasSF6)->F6_DTPAGTO), 4)+"-"+StrZero (Month ((cAliasSF6)->F6_DTPAGTO), 2)+"-"+StrZero (Day ((cAliasSF6)->F6_DTPAGTO), 2),"C",,,,9,.T.,.T.,.T.)

						cXml += MontaXML("c05_referencia",,,,,,5,.T.,.F.,.T.)

						If (cAliasSF6)->F6_REF$"1" .AND. (cAliasSF6)->F6_EST$"AC/AM/AP/BA/CE/MA/MS/PE/PR/RO/RR/RS/SE/DF"
							cXml += MontaXML("periodo",0,"N",9,2,,9,.T.,.T.,.T.)
						EndIf

						If (cAliasSF6)->F6_MESREF > 0
							cXml += MontaXML("mes",StrZero((cAliasSF6)->F6_MESREF,2),"N",9,2,,9,.T.,.T.,.T.)
						EndIf

						If (cAliasSF6)->F6_ANOREF > 0
							cXml += MontaXML("ano",(cAliasSF6)->F6_ANOREF,"N",9,2,,9,.T.,.T.,.T.)
						EndIf

						If !(cAliasSF6)->F6_EST$"BA/GO"
							cXml += MontaXML("parcela","1","N",9,2,,9,.T.,.T.,.T.)	
						EndIf

						cXml += MontaXML("c05_referencia",,,,,,5,.F.,.T.,.T.)

						If (cAliasSF6)->F6_EST=="RR" .And. !Empty(SF3->F3_CHVNFE)
							cXml += MontaXML("c39_camposExtras",,,,,,5,.T.,.F.,.T.)
							cXml += MontaXML("campoExtra",,,,,,5,.T.,.F.,.T.)
							cXml += MontaXML("codigo","36","C",9,2,,9,.T.,.T.,.T.)
							cXml += MontaXML("tipo","T","C",9,2,,9,.T.,.T.,.T.)
							cXml += MontaXML("valor",SF3->F3_CHVNFE,"C",9,2,,9,.T.,.T.,.T.)
							cXml += MontaXML("campoExtra",,,,,,5,.F.,.T.,.T.)
							cXml += MontaXML("c39_camposExtras",,,,,,5,.F.,.T.,.T.)
						EndIf
						cXml += MontaXML("TDadosGNRE",,,,,,5,.F.,.T.,.T.)
						cXml += Chr(13)+Chr(10)

					ElseIf !(cSubTrib$cMVSUBTRIB) .And. "100099"$(cCodRec) .And. (Alltrim((cAliasSF6)->F6_CODREC) == "100099")
						lGrava := .T.
						cXml += MontaXML("TDadosGNRE",,,,,,5,.T.,.F.,.T.)
						cXml += MontaXML("c01_UfFavorecida",(cAliasSF6)->F6_EST,,,,,9,.T.,.T.,.T.)
						cXml += MontaXML("c02_receita",AllTrim((cAliasSF6)->F6_CODREC),"C",9,2,,9,.T.,.T.,.T.)
						If !Empty((cAliasSF6)->F6_DETRECE)
							cXml += MontaXML("c25_detalhamentoReceita",AllTrim((cAliasSF6)->F6_DETRECE),"C",9,2,,9,.T.,.T.,.T.)
						EndIf

						If (cAliasSF6)->F6_CODPROD > 0 .AND. (cAliasSF6)->F6_EST$"AC/AL/AM/BA/CE/DF/GO/MA/MS/PE/PI/RN/RO/RR/SC/SE/TO"
							cXml += MontaXML("c26_produto",(cAliasSF6)->F6_CODPROD,"N",9,2,,9,.T.,.T.,.T.)
						EndIf

						If Len(AllTrim(SM0->M0_CGC))>=14
							cXml += MontaXML("c27_tipoIdentificacaoEmitente","1",,,,,9,.T.,.T.,.T.)
						EndIf

						cXml += MontaXML("c03_idContribuinteEmitente",,,,,,9,.T.,.F.,.T.)

						If Len(AllTrim(SM0->M0_CGC))>=14
							cXml += MontaXML("CNPJ",SM0->M0_CGC,,,,,12,.T.,.T.,.T.)
						EndIf

						cXml += MontaXML("c03_idContribuinteEmitente",,,,,,9,.F.,.T.,.T.)

						If !Empty(SF3->F3_ESPECIE)
							cXml += MontaXML("c28_tipoDocOrigem",Iif(Alltrim(SF3->F3_ESPECIE)=="NFA","01",Iif(Alltrim(SF3->F3_ESPECIE)$"NF/SPED","10",Iif(Alltrim(SF3->F3_ESPECIE)$"CTR/CTE","07","00"))),"C",9,2,,9,.T.,.T.,.T.)
						EndIf

						If !Empty((cAliasSF6)->F6_DOC)
							cXml += MontaXML("c04_docOrigem",(cAliasSF6)->F6_DOC,"C",9,2,,9,.T.,.T.,.T.)
						EndIf

						If (cAliasSF6)->F6_VALOR > 0
							cXml += MontaXML("c06_valorPrincipal",(cAliasSF6)->F6_VALOR,"N",9,2,"@R 9999999999999999999.99",9,.T.,.T.,.T.)
						EndIf

						If (cAliasSF6)->F6_VALOR > 0 .Or. (cAliasSF6)->F6_ATMON > 0 .Or. (cAliasSF6)->F6_JUROS > 0 .Or. (cAliasSF6)->F6_MULTA > 0
							cXml += MontaXML("c10_valorTotal",(cAliasSF6)->F6_VALOR+(cAliasSF6)->F6_ATMON+(cAliasSF6)->F6_JUROS+(cAliasSF6)->F6_MULTA,"N",9,2,"@R 9999999999999999999.99",9,.T.,.T.,.T.)
						EndIf

						//-- Para Ceara, considerar data vencimento = data pagamento
						If (cAliasSF6)->F6_EST == "CE"
							cXml += MontaXML("c14_dataVencimento",StrZero (Year ((cAliasSF6)->F6_DTPAGTO), 4)+"-"+StrZero (Month ((cAliasSF6)->F6_DTPAGTO), 2)+"-"+StrZero (Day ((cAliasSF6)->F6_DTPAGTO), 2),"C",,,,9,.T.,.T.,.T.)
						Else
							cXml += MontaXML("c14_dataVencimento",StrZero (Year ((cAliasSF6)->F6_DTVENC ), 4)+"-"+StrZero (Month ((cAliasSF6)->F6_DTVENC ), 2)+"-"+StrZero (Day ((cAliasSF6)->F6_DTVENC ), 2),"C",,,,9,.T.,.T.,.T.)
						EndIf

						If !Empty((cAliasSF6)->F6_NUMCONV)
							cXml += MontaXML("c15_convenio",(cAliasSF6)->F6_NUMCONV,"N",9,2,,9,.T.,.T.,.T.)
						EndIf

						cXml += MontaXML("c16_razaoSocialEmitente", HTMLEnc(SM0->M0_NOMECOM),,,,,9,.T.,.T.,.T.,,,,.T.)
						cXml += MontaXML("c18_enderecoEmitente"   , Substr(AllTrim(SM0->M0_ENDENT)+IIf(!Empty(SM0->M0_COMPENT),'-'+AllTrim(SM0->M0_COMPENT),''),1,60),,,,,9,.T.,.T.,.T.)
						cXml += MontaXML("c19_municipioEmitente"  , Right( Alltrim(SM0->M0_CODMUN),5),,,,,9,.T.,.T.,.T.)
						cXml += MontaXML("c20_ufEnderecoEmitente" , SM0->M0_ESTENT,,,,,9,.T.,.T.,.T.)
						cXml += MontaXML("c21_cepEmitente",SM0->M0_CEPENT,,,,,9,.T.,.T.,.T.)
						if ! empty( cFoneEmi )
							cXml += MontaXML("c22_telefoneEmitente",cFoneEmi,,,,,9,.T.,.T.,.T.)
						endif
						
						//Define se deve ou não gerar dados Participante
						nPos := aScan(aPartDest,{ |x| x[1] == (cAliasSF6)->F6_EST .And. Alltrim((cAliasSF6)->F6_CODREC) $ x[2]})
						if nPos > 0

							cXml += PartDest( cAliasSF6, lCliente )

						endif

						cXml += MontaXML("c33_dataPagamento",StrZero (Year ((cAliasSF6)->F6_DTPAGTO), 4)+"-"+StrZero (Month ((cAliasSF6)->F6_DTPAGTO), 2)+"-"+StrZero (Day ((cAliasSF6)->F6_DTPAGTO), 2),"C",,,,9,.T.,.T.,.T.)

						cXml += MontaXML("c05_referencia",,,,,,9,.T.,.F.,.T.)

						//Tipo de Referencia
						If ! Empty((cAliasSF6)->F6_REF)
							cTipoRef := TipoRefe( (cAliasSF6)->F6_REF )
							nPos := aScan(aPeriodo,{ |x| x[1] == (cAliasSF6)->F6_EST .And. Alltrim((cAliasSF6)->F6_CODREC) $ x[2]})
							If nPos > 0
								cXml += MontaXML( "periodo", cTipoRef, , , , , 15, .T., .T., .T. )
							EndIf
						EndIf

						If (cAliasSF6)->F6_MESREF > 0
							cXml += MontaXML("mes",StrZero((cAliasSF6)->F6_MESREF,2),"N",9,2,,12,.T.,.T.,.T.)
						EndIf

						If (cAliasSF6)->F6_ANOREF > 0
							cXml += MontaXML("ano",(cAliasSF6)->F6_ANOREF,"N",9,2,,12,.T.,.T.,.T.)
						EndIf

						If !(cAliasSF6)->F6_EST$"BA/GO"
							cXml += MontaXML("parcela","1","N",9,2,,12,.T.,.T.,.T.)
						EndIf

						cXml += MontaXML("c05_referencia",,,,,,9,.F.,.T.,.T.)

						//Extras

						nPos := aScan( aTipoExc,{ |aX| aX[1] == ( cAliasSF6 )->F6_EST } )
						
						//Código da Chave para as informações Extras
					   cCodDoc:= RetCodChv( aUFChvNFe, (cAliasSF6)->F6_EST, (cAliasSF6)->F6_CODREC )
					   lChvNFe	:=  iif(! empty( cCodDoc ) .And.  ! Empty(SF3->F3_CHVNFE), .T., .F.)
						
						nPosEx := aScan( aTagEx, { |x| x[1] == ( cAliasSF6 )->F6_EST .and. AllTrim( ( cAliasSF6 )->F6_CODREC ) $ x[2] } )
						
						If nPosEx > 0 .or. lChvNFe .or. ( cAliasSF6 )->F6_EST $ "MT"

							cXml += MontaXML("c39_camposExtras",,, , ,,9,.T.,.F.,.T.)

							//MT deve ser gerada a informação com a Data de Emissão da NF
							if (cAliasSF6)->F6_EST $ "MT"
								cEmissao :=  StrZero ( Year ( SF3->F3_EMISSAO   ), 4)+ "-" + StrZero ( Month ( SF3->F3_EMISSAO ), 2  )+ "-" + StrZero ( Day ( SF3->F3_EMISSAO ) , 2)
								cXml += MontaXML("campoExtra"      ,,, , ,,12,.T.,.F.,.T.)
								cXml += MontaXML("codigo","16","C",9,2,,15,.T.,.T.,.T.)
								cXml += MontaXML("tipo"  ,"D"    ,"C",9,8,,15,.T.,.T.,.T.)
								cXml += MontaXML("valor" ,cEmissao,"C",9,10,,15,.T.,.T.,.T.)
								cXml += MontaXML("campoExtra"      ,,, , ,,12,.F.,.T.,.T.)

							endif
							
							//Informações Complementares e Observação
							If nPos > 0 .and. !Empty( ( cAliasSF6 )->F6_OBSERV )
								cXml += MontaXML( "campoExtra",,,,,, 12, .T., .F., .T. )
								cXml += MontaXML( "codigo", aTipoExc[nPos][2], "C", 9, 2,, 15, .T., .T., .T. )
								cXml += MontaXML( "tipo", "T", "C", 9, 2,, 15, .T., .T., .T. )
								cXml += MontaXML( "valor", ( cAliasSF6 )->F6_OBSERV, "C", 9, 2,, 15, .T., .T., .T. )
								cXml += MontaXML( "campoExtra",,,,,, 12, .F., .T., .T. )
							EndIf
														
							//Chave NF-e
							if lChvNFe

								if (cAliasSF6)->F6_EST == "PB"
									cEspecie:= AModNot(SF3->F3_ESPECIE)
									cCodDoc	:= Iif(cEspecie$"55","30",Iif(cEspecie$"01#1B","31",""))
									cChvDoc	:= Iif(cCodDoc=="30",SF3->F3_CHVNFE,(cAliasSF6)->F6_DOC)
								else
									cChvDoc	:= SF3->F3_CHVNFE
								endif

								cXml += MontaXML("campoExtra",,,,,,12,.T.,.F.,.T.)
								cXml += MontaXML("codigo",cCodDoc,"C",9,2,,15,.T.,.T.,.T.)
								cXml += MontaXML("tipo","T","C",9,2,,15,.T.,.T.,.T.)
								cXml += MontaXML("valor",cChvDoc,"C",9,2,,15,.T.,.T.,.T.)
								cXml += MontaXML("campoExtra",,,,,,12,.F.,.T.,.T.)

							endif

							cXml += MontaXML("c39_camposExtras",,, , ,,9,.F.,.T.,.T.)
						endif

						cXml += MontaXML("TDadosGNRE",,,,,,5,.F.,.T.,.T.)
						cXml += Chr(13) + Chr(10)

					ElseIf (Alltrim((cAliasSF6)->F6_CODREC)$(cCodRec)) .And. !(Alltrim((cAliasSF6)->F6_CODREC) $ "100099/100048")
						lGrava := .T.
						
						//Defino se a Parcela sera preenchida
						lParcela := .F.
						If (cAliasSF6)->F6_EST == "DF" .And. Alltrim((cAliasSF6)->F6_CODREC) $ "100013/100021/100030/100056"
							lParcela := .T.
						EndIf
						
						//Inicializa Impressao da GNRE 
						cXml += MontaXML( "TDadosGNRE",,,,,,9,.T.,.F.,.T. )
						
						//UF Favorecida (Obrigatorio)
						cXml += MontaXML( "c01_UfFavorecida", (cAliasSF6)->F6_EST, , , , , 12, .T., .T., .T. )

						//Codigo da Receita (Obrigatorio)
						cXml += MontaXML( "c02_receita", Alltrim((cAliasSF6)->F6_CODREC), , , , , 12, .T., .T., .T. )

						//Codigo do Detalhamento da Receita
						If !Empty((cAliasSF6)->F6_DETRECE)
							cXml += MontaXML("c25_detalhamentoReceita",AllTrim((cAliasSF6)->F6_DETRECE),"C",9,2,,12,.T.,.T.,.T.)
						EndIf

						//Codigo do Produto 
						If !Empty( (cAliasSF6)->F6_CODPROD )
							cXml += MontaXML("c26_produto",(cAliasSF6)->F6_CODPROD,"N",9,2,,12,.T.,.T.,.T.)
						EndIf

						If !((cAliasSF6)->F6_EST$"PR" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100013/100021/100030/100080")
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Tipo de Identificacao do Emitente, de acordo com o Layout quando informada        ³
							//³a IE do Emitente este campo deve ser emitido, caso contrario eh exibido "1" (CNPJ)³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If Alltrim((cAliasSF6)->F6_CODREC)$"100056"
								If Len(Alltrim((cAliasSF6)->F6_CNPJ)) == 14 .And. CGC(Alltrim((cAliasSF6)->F6_CNPJ))
									cXml += MontaXML("c27_tipoIdentificacaoEmitente","1",,,,,12,.T.,.T.,.T.)
								ElseIf Len(Alltrim((cAliasSF6)->F6_CNPJ)) == 11 .And. CGC(Alltrim((cAliasSF6)->F6_CNPJ))
									cXml += MontaXML("c27_tipoIdentificacaoEmitente","2",,,,,12,.T.,.T.,.T.)
								EndIf
							ElseIf !(Alltrim((cAliasSF6)->F6_CODREC)=="100013" .And. ((cAliasSF6)->F6_EST$"PE"))
								cXml += MontaXML("c27_tipoIdentificacaoEmitente",Iif(!Empty(SM0->M0_CGC),"1","2"),,,,,12,.T.,.T.,.T.)
							EndIf

							//CNPJ do Emitente
							If !Empty( SM0->M0_CGC )
								cXml += MontaXML( "c03_idContribuinteEmitente", , , , , , 12, .T., .F., .T. )
								cXml += MontaXML( "CNPJ", SM0->M0_CGC, , , , , 15, .T., .T., .T. )
								cXml += MontaXML( "c03_idContribuinteEmitente", , , , , , 12, .F., .T., .T. )
							EndIf

							Do Case
								Case Alltrim(SF3->F3_ESPECIE)=="NFA"
									cTipoDoc := "01"
								Case Alltrim(SF3->F3_ESPECIE)$"NF/SPED"
									cTipoDoc := "10"
								Case Alltrim(SF3->F3_ESPECIE)=="CA"
									cTipoDoc := "08"
								Case Alltrim(SF3->F3_ESPECIE)$"CTR/CTE"
									cTipoDoc := "07"
								Case (Alltrim(SF3->F3_ESPECIE)$"NTST/NFCEE" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100013/100021" .And. !(cAliasSF6)->F6_EST$"PI")
									cTipoDoc := "10"
								Case (Alltrim((cAliasSF6)->F6_CODREC)=="100013" .And. (cAliasSF6)->F6_EST=="PI")
									cTipoDoc := "01"
								OtherWise
									cTipoDoc := "00"
							EndCase

							If Alltrim((cAliasSF6)->F6_CODREC)$"100056" .And. !(cAliasSF6)->F6_EST$"AC" 
								If !Empty((cAliasSF6)->F6_TIPODOC)
									cXml += MontaXML("c28_tipoDocOrigem",(cAliasSF6)->F6_TIPODOC,"C",2,2,,12,.T.,.T.,.T.)
								EndIf
								
								//Numero do Documento de Origem
								
								If !Empty((cAliasSF6)->F6_DOC)
									cXml += MontaXML("c04_docOrigem",(cAliasSF6)->F6_DOC,"C",9,2,,12,.T.,.T.,.T.)
								EndIf
							EndIf
							
							//Tipo do Documento de Origem 
							If !Alltrim((cAliasSF6)->F6_CODREC)$"100056"
								If !((cAliasSF6)->F6_EST$"BA/PR" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100030/100013")
									If Alltrim(SF3->F3_ESPECIE)$"CTR/CTE" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100030" .And. (cAliasSF6)->F6_EST$"TO/SC"
										cTipoDoc := "10"
									EndIf
									If !Empty( cTipoDoc )
										cXml += MontaXML("c28_tipoDocOrigem",cTipoDoc,"C",2,2,,12,.T.,.T.,.T.)
									EndIf

									//Numero do Documento de Origem
									If !Empty((cAliasSF6)->F6_DOC)
										cXml += MontaXML("c04_docOrigem",(cAliasSF6)->F6_DOC,"C",9,2,,12,.T.,.T.,.T.)
									EndIf
								EndIf
							EndIf
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Valor Original da Guia (Sem Impostos)    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Valor Original da Guia (Com Impostos)    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (cAliasSF6)->F6_VALOR > 0
							If (cAliasSF6)->F6_EST$"MA/PA/PI/RO/RR/TO/SC" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100013/100021/100030/100056/100102/100110/100129/100137"
								cXml += MontaXML("c06_valorPrincipal",(cAliasSF6)->F6_VALOR,"N",9,2,"@R 9999999999999999999.99",12,.T.,.T.,.T.)
								cXml += MontaXML("c10_valorTotal",(cAliasSF6)->F6_VALOR+(cAliasSF6)->F6_ATMON+(cAliasSF6)->F6_JUROS+(cAliasSF6)->F6_MULTA,"N",9,2,"@R 9999999999999999999.99",12,.T.,.T.,.T.)
							ElseIf Alltrim((cAliasSF6)->F6_CODREC)$"100021/100030/100056/100102/100129" .And. !((cAliasSF6)->F6_EST$"MT" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100102") 
								cXml += MontaXML("c06_valorPrincipal",(cAliasSF6)->F6_VALOR,"N",9,2,"@R 9999999999999999999.99",12,.T.,.T.,.T.)
							ElseIf !((cAliasSF6)->F6_EST$"RS/PE")
								cXml += MontaXML("c10_valorTotal",(cAliasSF6)->F6_VALOR+(cAliasSF6)->F6_ATMON+(cAliasSF6)->F6_JUROS+(cAliasSF6)->F6_MULTA,"N",9,2,"@R 9999999999999999999.99",12,.T.,.T.,.T.)								
							EndIf
						EndIf
 
						//Data de Vencimento da Guia (Obrigatorio)
						If !Empty((cAliasSF6)->F6_DTVENC)
							cXml += MontaXML("c14_dataVencimento",StrZero (Year ((cAliasSF6)->F6_DTVENC), 4)+"-"+StrZero (Month ((cAliasSF6)->F6_DTVENC), 2)+"-"+StrZero (Day ((cAliasSF6)->F6_DTVENC), 2),"C",,,,12,.T.,.T.,.T.)
						EndIf

						
						//Codigo do Convenio 
						If !Empty((cAliasSF6)->F6_NUMCONV)
							cXml += MontaXML( "c15_convenio", (cAliasSF6)->F6_NUMCONV, , , , , 12, .T., .T., .T. )
						EndIf

						//Razao Social, de acordo com o Layout quando informada a IE do Emitente este campo deve ser emitido 
						
						If !((cAliasSF6)->F6_EST$"PR" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100013/100021/100030")
							If !Empty( SM0->M0_NOMECOM )
								cXml += MontaXML("c16_razaoSocialEmitente",HTMLEnc(SM0->M0_NOMECOM),,,,,12,.T.,.T.,.T.,,,,.T.)
							EndIf
						EndIf

						
						//Inscricao Estadual do Emitente 
						If !Empty((cAliasSF6)->F6_INSC) .And. ;
						((Alltrim((cAliasSF6)->F6_CODREC)$"100013/100021/100080" .And. ((cAliasSF6)->F6_EST$"PE/RN")) .Or. (cAliasSF6)->F6_EST$"PR/RR" .Or. Alltrim((cAliasSF6)->F6_CODREC) $ "100110/100137")
							cXml += MontaXML("c17_inscricaoEstadualEmitente",(cAliasSF6)->F6_INSC,,,,,12,.T.,.T.,.T.)
						EndIf

						//Endereco do Emitente, de acordo com o Layout quando informada IE do Emitente este campo deve ser emitido  
						
						If !((cAliasSF6)->F6_EST$"PR" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100013/100021")
							If !Empty( SM0->M0_ENDENT )
								cXml += MontaXML("c18_enderecoEmitente",Substr(AllTrim(SM0->M0_ENDENT)+IIf(!Empty(SM0->M0_COMPENT),'-'+AllTrim(SM0->M0_COMPENT),''),1,60),,,,,12,.T.,.T.,.T.)
							EndIf

							
							//Municipio do Emitente, de acordo com o Layout quando informada a IE do Emitente este campo deve ser emitido 
							
							If !Empty( SM0->M0_CODMUN )
								cXml += MontaXML( "c19_municipioEmitente", Right( Alltrim( SM0->M0_CODMUN ), 5 ), , , , , 12, .T., .T., .T. )
							EndIf

							
							//UF do Emitente, de acordo com o Layout quando informada a IE do Emitente este campo deve ser emitido
							
							If !Empty( SM0->M0_ESTENT )
								cXml += MontaXML("c20_ufEnderecoEmitente",SM0->M0_ESTENT,,,,,12,.T.,.T.,.T.)
							EndIf

							//CEP do emitente, de acordo com o Layout quando informada a IE do Emitente este campo deve ser emitido
							
							If !Empty( SM0->M0_CEPENT )
								cXml += MontaXML("c21_cepEmitente",SM0->M0_CEPENT,,,,,12,.T.,.T.,.T.)
							EndIf
							
							//Telefone do emitente, de acordo com o Layout quando informada a IE do Emitente este campo deve ser emitido                       ³
							
							If !Empty( SM0->M0_TEL )
								cXml += MontaXML("c22_telefoneEmitente",cFoneEmi,,,,,12,.T.,.T.,.T.)
							EndIf

						EndIf

						//Caso seja informado o Participante no cadastro de Guias, deve-se gerar as informacoes de destinatario (Substituicao Tributaria) 
						
						nPos := aScan(aPartDest,{ |x| x[1] == (cAliasSF6)->F6_EST .And. Alltrim((cAliasSF6)->F6_CODREC) $ x[2]})
						
						If nPos > 0

							cXml += PartDest( cAliasSF6, lCliente )
							
						EndIf

						
						//Data de Pagamento da Guia (Obrigatorio)
						If !Empty((cAliasSF6)->F6_DTPAGTO)
							cXml += MontaXML("c33_dataPagamento",StrZero (Year ((cAliasSF6)->F6_DTPAGTO), 4)+"-"+StrZero (Month ((cAliasSF6)->F6_DTPAGTO), 2)+"-"+StrZero (Day ((cAliasSF6)->F6_DTPAGTO), 2),"C",,,,12,.T.,.T.,.T.)			
						EndIf

						
						//Periodo, Mes, Ano e Parcela a qual se refere a Guia
						
						cXml += MontaXML( "c05_referencia", , , , , , 12, .T., .F., .T. )
						
						//Tipo de Referencia
						cTipoRef := TipoRefe( (cAliasSF6)->F6_REF )
						nPos := aScan(aPeriodo,{ |x| x[1] == (cAliasSF6)->F6_EST .And. Alltrim((cAliasSF6)->F6_CODREC) $ x[2]})
						If nPos > 0
							cXml += MontaXML( "periodo", cTipoRef, , , , , 15, .T., .T., .T. )
						EndIf

						If (cAliasSF6)->F6_MESREF > 0
							cXml += MontaXML("mes",StrZero((cAliasSF6)->F6_MESREF,2),"N",9,2,,15,.T.,.T.,.T.)
						EndIf
						If (cAliasSF6)->F6_ANOREF > 0
							cXml += MontaXML("ano",(cAliasSF6)->F6_ANOREF,"N",9,2,,15,.T.,.T.,.T.)
						EndIf

						If lParcela
							cXml += MontaXML("parcela","1","N",9,2,,15,.T.,.T.,.T.)
						EndIf

						cXml += MontaXML( "c05_referencia" , , , , , , 12, .F. , .T. , .T. )

						nPos   	:= aScan(aTipoExc,{ |aX| aX[1] == (cAliasSF6)->F6_EST })
						
						//Tratamento para código da Chave da NF-e/CT-e/DF-e
						
						cCodExtra := RetCodChv( aUFChvNFe, (cAliasSF6)->F6_EST, (cAliasSF6)->F6_CODREC )
					    lChaveNF  :=  iif(! empty( cCodExtra ) .And.  ! Empty(SF3->F3_CHVNFE), .T., .F.)
						
						
						nPosEx 	:= aScan(aTagEx,  { | x|  x[1] == (cAliasSF6)->F6_EST .And. Alltrim((cAliasSF6)->F6_CODREC) $ x[2]})
						
						
						If nPosEx > 0 .Or. lChaveNF						
							If(((cAliasSF6)->F6_EST == 'AL' .And. Alltrim(cCodExtra)=="65").Or. (cAliasSF6)->F6_EST <> 'AL')						
								cXml += MontaXML("c39_camposExtras",,,,,,12,.T.,.F.,.T.)
															
								//-- Informacoes complementares e Observacao
								If nPos > 0 .And. !empty((cAliasSF6)->F6_INF) .and. (cAliasSF6)->F6_EST <>"PR"
									cXml += MontaXML("campoExtra",,,,,,15,.T.,.F.,.T.)
									cXml += MontaXML("codigo",aTipoExc[nPos][2],"C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("tipo","T","C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("valor",(cAliasSF6)->F6_INF,"C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("campoExtra",,,,,,15,.F.,.T.,.T.)
								EndIf
								
								
								//-- Relacao a Chave
								If (((cAliasSF6)->F6_EST$"MS" .And. Alltrim((cAliasSF6)->F6_CODREC)=="100056") .And. !((cAliasSF6)->F6_EST$"AM" .And. Alltrim((cAliasSF6)->F6_CODREC)=="100030") .And. !Empty(SF3->F3_CHVNFE))
									cXml += MontaXML("campoExtra",,,,,,15,.T.,.F.,.T.)
									cXml += MontaXML("codigo",Iif((cAliasSF6)->F6_EST$"MS","27","36"),"C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("tipo","T","C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("valor",SF3->F3_CHVNFE,"C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("campoExtra",,,,,,15,.F.,.T.,.T.)
								EndIf
								//Chave NF-e Novos Códigos Receita
								If lChaveNF
									
									//Rondonia possui tratamento tanto para a Chave NF-e quanto CT-e
									if (cAliasSF6)->F6_EST == "RO" .And. Alltrim((cAliasSF6)->F6_CODREC) =='100102'			 
										cCodExtra := Iif(AModNot(Alltrim(SF3->F3_ESPECIE))$"57","89", "83")							
									endif
																			
									cXml += MontaXML("campoExtra",,,,,,15,.T.,.F.,.T.)
									cXml += MontaXML("codigo",cCodExtra,"C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("tipo","T","C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("valor",SF3->F3_CHVNFE,"C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("campoExtra",,,,,,15,.F.,.T.,.T.)
								EndIf
															
								If (cAliasSF6)->F6_EST=="RS" .And. Alltrim((cAliasSF6)->F6_CODREC)== "100137"
									cXml += MontaXML("campoExtra",,,,,,15,.T.,.F.,.T.)
									cXml += MontaXML("codigo","82","C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("tipo","T","C",9,2,,9,.T.,.T.,.T.)
									cXml += MontaXML("valor",AllTrim((cAliasSF6)->F6_DETRECE),"C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("campoExtra",,,,,,15,.F.,.T.,.T.)
								EndIf							
								
								If (cAliasSF6)->F6_EST=="AM" .And. Alltrim((cAliasSF6)->F6_CODREC)=="100030"
									cXml += MontaXML("campoExtra",,,,,,15,.T.,.F.,.T.)
									cXml += MontaXML("codigo","14","N",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("tipo","N","N",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("valor",(cAliasSF6)->F6_DESCOMP,"N",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("campoExtra",,,,,,15,.F.,.T.,.T.)
								EndIf
								
								If (cAliasSF6)->F6_EST=="AC" .And. Alltrim((cAliasSF6)->F6_CODREC)=="100030"
									cXml += MontaXML("campoExtra",,,,,,15,.T.,.F.,.T.)
									cXml += MontaXML("codigo","24","C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("tipo","T","C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("valor",HTMLEnc(SM0->M0_NOMECOM),,,,,17,.T.,.T.,.T.,,,,.T.)
									cXml += MontaXML("campoExtra",,,,,,15,.F.,.T.,.T.)
									cXml += MontaXML("campoExtra",,,,,,15,.T.,.F.,.T.)
									cXml += MontaXML("codigo","25","C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("tipo","T","C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("valor",SM0->M0_CGC,,,,,17,.T.,.T.,.T.)
									cXml += MontaXML("campoExtra",,,,,,15,.F.,.T.,.T.)
									cXml += MontaXML("campoExtra",,,,,,15,.T.,.F.,.T.)
									cXml += MontaXML("codigo","26","C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("tipo","T","C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("valor",(cAliasSF6)->F6_DOC,"C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("campoExtra",,,,,,15,.F.,.T.,.T.)
								EndIf

								If nPos > 0 .And. ( !empty((cAliasSF6)->F6_INF) .Or. !Empty( ( cAliasSF6 )->F6_OBSERV ) );
							        .and. (cAliasSF6)->F6_EST=="PR"
							 		
									cMsgExtra := alltrim( (cAliasSF6)->F6_INF + ' ' + ( cAliasSF6 )->F6_OBSERV )
	
									cXml += MontaXML("campoExtra",,,,,,15,.T.,.F.,.T.)
									cXml += MontaXML("codigo",aTipoExc[nPos][2],"C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("tipo","T","C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("valor",cMsgExtra,"C",9,2,,17,.T.,.T.,.T.)
									cXml += MontaXML("campoExtra",,,,,,15,.F.,.T.,.T.)
								EndIf

								cXml += MontaXML("c39_camposExtras",,,,,,12,.F.,.T.,.T.)
							Endif
						EndIf
						
						//Tratamento realizado para que não ocorra erro de validação se não tiver valor referente aos campos extras
						if !"campoExtra" $ cXml
							cXml := strtran(cXml,"<c39_camposExtras>","")
							cXml := strtran(cXml,"</c39_camposExtras>","")						
						endif
						
						
						cXml += MontaXML("TDadosGNRE",,,,,,9,.F.,.T.,.T.)
						cXml += Chr(13)+Chr(10)
					EndIf
				EndIf
			EndIf
			//-- Guia de Recolhimento processada.
			SF6->( dbSetOrder(1))
			If SF6->(MsSeek(xFilial("SF6")+(cAliasSF6)->F6_EST+(cAliasSF6)->F6_NUMERO)) .And. (cAliasSF6)->F6_EST$cMVUFGNRE
				If ( Empty((cAliasSF6)->F6_PROCESS) .Or. (cAliasSF6)->F6_PROCESS=="2" ) .And. lGrava
					nCount++
					RecLock("SF6",.F.)
					SF6->F6_PROCESS := "1"
					SF6->(MsUnlock())
				EndIf
			EndIf
			(cAliasSF6)->(DbSkip())
		Enddo
		#IFDEF TOP
		If lGerou .And. !lAglFil
		#ELSE
		If lGerou
		#EndIf
			cXml += MontaXML("guias"     ,,,,,,,.F.,.T.,.T.)
			cXml += MontaXML("TLote_GNRE",,,,,,,.F.,.T.,.T.)
			MemoWrite(iif(lHtml,cStartPath,cDir)+cNomeArq,cXml)
			If lHtml
				CPYS2TW(cStartPath+cNomeArq)
			EndIf
			nLote++
			cNomeArq := cFileDest+cFilAnt
		#IFDEF TOP
		ElseIf lGerou
			nLote++
		#EndIf
		EndIf

	EndDo

	#IFDEF TOP
		DbSelectArea(cAliasSF6)
		(cAliasSF6)->(DbCloseArea())
	#EndIf

	SM0->(DbSkip())
EndDo

#IFDEF TOP
If lGerou .And. lAglFil
	cXml += MontaXML("guias",,,,,,,.F.,.T.,.T.)
	cXml += MontaXML("TLote_GNRE",,,,,,,.F.,.T.,.T.)
	MemoWrite(iif(lHtml,cStartPath,cDir)+cNomeArq,cXml)
	If lHtml
		CPYS2TW(cStartPath+cNomeArq)
	EndIf
EndIf
#EndIf

SM0->(RestArea(aAreaSM0))

cFilAnt := cFilBkp

If !lQuery
	RetIndex("SF6")
	dbClearFilter()
	Ferase(cIndex+OrdBagExt())
EndIf

If !Empty(cFileDest)
	MsgInfo("Arquivo " + cFileDest + " gerado com sucesso!") //"Arquivo "###" gerado com sucesso!"
Else
	MsgAlert("Não foi possível gerar o arquivo!") //"Não foi possível gerar o arquivo!"
EndIf

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GrvCab    ºAutor  ³Natalia Antonucci   º Data ³  22/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o Cabecalho do XML                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrvCab(nLote,cNomeArq)
Local cMontXml := ""

cNomeArq := cNomeArq + ALLTRIM(Str(nLote)) + ".XML"

cMontXml += MontaXML("?xml",,,,,,,.T.,.F.,.T.,"version="+'"1.0"'+" encoding="+'"UTF-8" standalone="yes"'+" ?")
cMontXml += MontaXML("TLote_GNRE",,,,,,,.T.,.F.,.T.,' xmlns="http://www.gnre.pe.gov.br"' )
cMontXml += MontaXML("guias",,,,,,,.T.,.F.,.T.,.T.)

Return(cMontXml)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Wizard    ºAutor  ³Natalia Antonucci   º Data ³  22/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o Wizard da rotina.                                  º±±
±±º          ³ Retorna .T. se finalizado com sucesso                      º±±
±±º          ³ Retorna .F. se foi cancelado                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Wizard(cNomWiz)
Local aTxtApre := {}
Local aPaineis := {}
Local cTitObj1 := ""
Local cTitObj2 := ""
Local lRet     := .T.

//ÚÄÄÄÄÄÄÄÄ¿
//³Painel 0³
//ÀÄÄÄÄÄÄÄÄÙ
aAdd (aTxtApre, "Parâmetros necessários.")
aAdd (aTxtApre, "")
aAdd (aTxtApre, "Preencha corretamente as informações solicitadas.")
aAdd (aTxtApre, "Informações necessárias para a geração do meio-magnético GNREON.")

//ÚÄÄÄÄÄÄÄÄ¿
//³Painel 1³
//ÀÄÄÄÄÄÄÄÄÙ
aAdd (aPaineis, {})
nPos := Len(aPaineis)
aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
aAdd (aPaineis[nPos], "Parâmetros para Geração")
aAdd (aPaineis[nPos], {})
//
cTitObj1	:=	"Data de";									cTitObj2	:=	"Data até"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
aAdd (aPaineis[nPos][3], {2,,,3,,,,});						aAdd (aPaineis[nPos][3], {2,,,3,,,,})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Diretório do Arquivo Destino";				cTitObj2	:=	"Nome do Arquivo Destino"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 50);						cTitObj2	:=	Replicate ("X", 20)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});			aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Filial de"; 								cTitObj2	:=	"Filial ate"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 8);							cTitObj2	:=	Replicate ("X", 8)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,8});			aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,8})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})

#IFDEF WINDOWS
	//
	cTitObj1	:=	"Seleciona Filiais?";					cTitObj2	:=	"Aglutina por CNPJ + I.E.?"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});			aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	//
	aAdd (aPaineis[nPos][3], {3,,,,,{"Sim", "Não"},,});	aAdd (aPaineis[nPos][3], {3,,,,,{"Sim", "Não"},,})
#EndIf
//
aAdd (aPaineis[nPos][3], {1,"",,,,,,});					aAdd (aPaineis[nPos][3], {1,"",,,,,,})

cTitObj1	:=	"Para gerar a guia filtrada por série de NF, ";						cTitObj2	:=	""	
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1,"",,,,,,})
cTitObj1	:=	"informe as séries separadas por (;) Ex: 01;02;";					cTitObj2	:=	""
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});									aAdd (aPaineis[nPos][3], {1,"",,,,,,})
//
cTitObj1	:=	Replicate ("X", 20);													cTitObj2	:=	""
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,20});									aAdd (aPaineis[nPos][3], {1,"",,,,,,})	

aAdd (aPaineis[nPos][3], {1,"",,,,,,});					aAdd (aPaineis[nPos][3], {1,"",,,,,,})

//ÚÄÄÄÄÄÄÄÄ¿
//³Painel 2³
//ÀÄÄÄÄÄÄÄÄÙ
//
aAdd (aPaineis, {})
nPos := Len(aPaineis)
aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
aAdd (aPaineis[nPos], "Informar qual código de receita deve ser levado ao arquivo .xml.")
aAdd (aPaineis[nPos], {})
//
cTitObj2	:=	"100013 - ICMS Comunição";				cTitObj1	:=	"100021 - ICMS Energia Elétrica"
aAdd (aPaineis[nPos][3], {4, cTitObj2,,,,,.T.,});	aAdd (aPaineis[nPos][3], {4, cTitObj1,,,,,.T.,})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});				aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj2	:=	"100030 - ICMS Transporte";				cTitObj1	:=	"100048 - ICMS ST por Apuração"
aAdd (aPaineis[nPos][3], {4, cTitObj2,,,,,.T.,});	aAdd (aPaineis[nPos][3], {4, cTitObj1,,,,,.T.,})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});				aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj2	:=	"100056 - ICMS Importação";				cTitObj1	:=	"100080 - ICMS Recolhimento Especiais"
aAdd (aPaineis[nPos][3], {4, cTitObj2,,,,,.T.,});	aAdd (aPaineis[nPos][3], {4, cTitObj1,,,,,.T.,})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});				aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj2	:=	"100099 - ICMS ST por Operação"	;		cTitObj1	:=	"100102 - ICMS Não Contrib por Operação"
aAdd (aPaineis[nPos][3], {4, cTitObj2,,,,,.T.,});	aAdd (aPaineis[nPos][3], {4, cTitObj1,,,,,.T.,})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});				aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj2	:=	"100110 - ICMS Não Contrib por Apuração"; 	cTitObj1	:=	"100129 - ICMS FECP por Operação" 	
aAdd (aPaineis[nPos][3], {4, cTitObj2,,,,,.T.,});			aAdd (aPaineis[nPos][3], {4, cTitObj1,,,,,.T.,})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})		

cTitObj2	:=	"100137 - ICMS FECP por Apuração"	
aAdd (aPaineis[nPos][3], {4, cTitObj2,,,,,.T.,})	
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,}) 

lRet	:=	xMagWizard (aTxtApre, aPaineis, cNomWiz)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConvType  ºAutor  ³Natalia.antonucci   º Data ³  27/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tratamento de caracteres especiais                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConvType(xValor,nTam,nDec)

Local cNovo := ""
DEFAULT nDec := 0
Do Case
	Case ValType(xValor)=="N"
		If xValor <> 0
			cNovo := AllTrim(Str(xValor,nTam,nDec))	
		Else
			cNovo := "0"
		EndIf
	Case ValType(xValor)=="D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)
	Case ValType(xValor)=="C"
		If nTam==Nil
			xValor := AllTrim(xValor)
		EndIf
		DEFAULT nTam := 60
		cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
EndCase
Return(cNovo)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldIE     ºAutor  ³Natalia Antonucci   º Data ³  27/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida Incricao Estadual                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldIE(cInsc,lContr,lIsent)
Local cRet := ""
Local nI   := 1

Default lContr := .T.
Default lIsent := .T.

For nI:=1 To Len(cInsc)
	If Isdigit(Subs(cInsc,nI,1)) .Or. IsAlpha(Subs(cInsc,nI,1))
		cRet+=Subs(cInsc,nI,1)
	EndIf
Next
cRet := AllTrim(cRet)

If lIsent
	If "ISENT"$Upper(cRet)
		cRet := ""
	EndIf
	If !(lContr) .And. !Empty(cRet)
		cRet := "ISENTA"
	EndIf
EndIf
Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PartDest
Função criada para gerar as tags referente ao Participante destinatário

@author Simone Oliveira
@since 14.04.2016
@version 11.80
                                                                                                                      
/*/
//-------------------------------------------------------------------
Static Function PartDest( cAliasSF6, lCliente )

local cXml:= ""
Local lGnreCE := (cAliasSF6)->F6_EST$"CE" .And. Alltrim((cAliasSF6)->F6_CODREC) == "100099" .And. !Empty(SA1->A1_INSCR)

default lCliente:= .t.

If lCliente .And. !Alltrim((cALiasSF6)->F6_TIPODOC) $ "B|D"
							
	// 1 = Pessoa Juridica ou 2 = Pessoa Fisica  
	cTpPessoa := Iif(!Empty(SA1->A1_CGC) .And. RetPessoa(SA1->A1_CGC) == "J","1","2")
	If !lGnreCE	
		cXml += MontaXML("c34_tipoIdentificacaoDestinatario",cTpPessoa,,,,,12,.T.,.T.,.T.)
	Endif
	
	//Inscricao Estadual do Destinatario
	
	If  !Empty((cAliasSF6)->F6_DOC) .And. !Empty((cAliasSF6)->F6_SERIE) .And. !Empty((cAliasSF6)->F6_CLIFOR)
		If !Empty(SA1->A1_INSCR) .And. UPPER(Alltrim(SA1->A1_INSCR)) <> 'ISENTO' .And. !((cAliasSF6)->F6_EST$"AM" .And. Alltrim((cAliasSF6)->F6_CODREC)=="100021");
			.And. ! lGnreCE
			cXml += MontaXML( "c36_inscricaoEstadualDestinatario", ConvType(VldIE(SA1->A1_INSCR,.F.,.F.)), , , , , 12, .T., .T., .T. )
		Else
			//CPF/CNPJ do Destinatario
			If !Empty( SA1->A1_CGC )
				cXml += MontaXML( "c35_idContribuinteDestinatario", , , , , , 12, .T., .F., .T. )
				cXml += MontaXML( IIf(cTpPessoa=="1","CNPJ","CPF"), SA1->A1_CGC, , , , , 15, .T., .T., .T. )
				cXml += MontaXML( "c35_idContribuinteDestinatario", , , , , , 12, .F., .T., .T. )
				If lGnreCE 
					cXml += MontaXML( "c36_inscricaoEstadualDestinatario", ConvType(VldIE(SA1->A1_INSCR,.F.,.F.)), , , , , 12, .T., .T., .T. )
				Endif
			EndIf
			
			//³Razao Social do Destinatario 
			
			If !Empty( SA1->A1_NOME )
				cXml += MontaXML( "c37_razaoSocialDestinatario", SA1->A1_NOME, , , , , 12, .T., .T., .T. )
			EndIf
			
			//³Codigo do Municipio do Destinatario 
			If !Empty( SA1->A1_COD_MUN )
				cXml += MontaXML("c38_municipioDestinatario",Alltrim(SA1->A1_COD_MUN),,,,,12,.T.,.T.,.T.)
			EndIf
		EndIf
	EndIf
Else
	//1 = Pessoa Juridica ou 2 = Pessoa Fisica
	
	cTpPessoa := Iif(!Empty(SA2->A2_CGC) .And. RetPessoa(SA2->A2_CGC) == "J","1","2")
	cXml += MontaXML("c34_tipoIdentificacaoDestinatario",cTpPessoa,,,,,12,.T.,.T.,.T.)
	
	//Inscricao Estadual do Destinatario
	
	If  !Empty((cAliasSF6)->F6_DOC) .and. !Empty((cAliasSF6)->F6_SERIE) .and. !Empty((cAliasSF6)->F6_CLIFOR)
		If !Empty(SA2->A2_INSCR) .And. !((cAliasSF6)->F6_EST$"AM" .And. Alltrim((cAliasSF6)->F6_CODREC)=="100021") .And.  !(Alltrim((cAliasSF6)->F6_CODREC)$"100056" .And. (cAliasSF6)->F6_EST$"TO")
			cXml += MontaXML( "c36_inscricaoEstadualDestinatario", ConvType(VldIE(SA2->A2_INSCR,.F.,.F.)), , , , , 12, .T., .T., .T. )
		Else
			
			//CPF/CNPJ do Destinatario
			If !Empty( SA2->A2_CGC )
				cXml += MontaXML( "c35_idContribuinteDestinatario", , , , , , 12, .T., .F., .T. )
				cXml += MontaXML( IIf(cTpPessoa=="1","CNPJ","CPF"), SA2->A2_CGC, , , , , 15, .T., .T., .T. )
				cXml += MontaXML( "c35_idContribuinteDestinatario", , , , , , 12, .F., .T., .T. )
			EndIf
			
			//Razao Social do Destinatario
			If !Empty( SA2->A2_NOME )
				cXml += MontaXML( "c37_razaoSocialDestinatario", SA2->A2_NOME, , , , , 12, .T., .T., .T. )
			EndIf
			
			//Codigo do Municipio do Destinatario
			If !Empty( SA2->A2_COD_MUN )
				cXml += MontaXML("c38_municipioDestinatario",Alltrim(SA2->A2_COD_MUN),,,,,12,.T.,.T.,.T.)
			EndIf
		EndIf
	EndIf
EndIf

return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} TipoRefe
Função criada para tratar o tipo de referência a ser tratado no xml 

@author Simone Oliveira
@since 14.04.2016
@version 11.80
                                                                                                                      
/*/
//-------------------------------------------------------------------
static function TipoRefe( cRefSF6 )

local cTipoRef := ""

default cRefSF6 := ""

Do Case
	Case cRefSF6 == "1"
		cTipoRef := "0"
	Case cRefSF6 == "2"
		cTipoRef := "1"
	Case cRefSF6 == "3"
		cTipoRef := "2"
	Case cRefSF6 == "4"
		cTipoRef := "3"
	Case cRefSF6 == "5"
		cTipoRef := "4"
	Case cRefSF6 == "6"
		cTipoRef := "5"
	OtherWise
		cTipoRef := "0"
EndCase



return cTipoRef

//-------------------------------------------------------------------
/*/{Protheus.doc} RetCodChv
Função que retorna o código referente à Chave da NF-e/DF-e/CT-e para 
as informações extras

@author Simone dos Santos de Oliveira
@since 02/05/2016
@version 11.80
/*/
//-------------------------------------------------------------------
static function RetCodChv(aUFChvNFe, cUF, cCodRec )

local cCodChv		:= ''
local cSX5Descri	:= ''
local cSX5Rec		:= ''

local lAchouSX5	:= .f.

local nSX5Rec		:= 0


default aUFChvNFe	:= {}
default cUf		:= ''
default cCodRec	:= '' 


//Primeiramente, verifico se tem informação na SX5, caso não encontre irá buscar do array aUFChvNFe

if ! ( empty( cUF) .and. empty(cCodRec) )						
	
	//Tratamento pela SX5
	
	dbselectarea("SX5")
	dbsetorder(1)
	
	if dbseek(xFilial("SX5")+'88'+cUF)
		
		//Todo conteúdo de acordo com a UF posicionada
		cSX5Descri  := alltrim( SX5->X5_DESCRI )
	
		//Posição Inicial conforme código da Receita
		nSX5Rec := at(alltrim( cCodRec ),cSX5Descri)
	
		if nSX5Rec > 0
			//Conteúdo conforme posição Inicial 
			aCodExtra := StrToArray(AllTrim(cSX5Descri),"/")
			nPosExtra := aScan(aCodExtra,{|aX| AllTrim(cCodRec) $ aX })
			
			If nPosExtra > 0
				cSX5Rec := aCodExtra[nPosExtra]
			EndIf
			
			//Posição Inicial para considerar o código referente à Informação Extra - Chave
			cCodChv := substr(cSX5Rec, at('-',AllTrim(cSX5Descri))+1 ,10)
			
			lAchouSX5:= .t.
		endif
			
	endif
	
	//Tratamento caso não encontre na SX5 busca do Array (legado)
	if !lAchouSX5 .and. len( aUFChvNFe ) > 0
		
		//Posiciona no Array conforme UF e Código de Receita
		nPosChvNFe	:= ascan(aUFChvNFe,{ |aX| aX[1] == cUF .And. alltrim(cCodRec) $ aX[2]})
		
		if nPosChvNFe > 0
			cCodChv	:= aUFChvNFe[nPosChvNFe][3]
		endif
	
	endif

endif
						
						
return cCodChv						

//-------------------------------------------------------------------
/*/{Protheus.doc} BannerTAF

Funcao responsabel em existir a mensagem de obrigatoriedade de uso do TAF para gerar as obrigações fiscais a partir de uma determinada data.
Ela utiliza um jpg desenvolvido por MKT ( banner_taf.jpg ).
Se existir compilado o resource de Banner (.jpg) no repositório, ele utiliza uma apresentacao mais elaborada. Pode acontecer do programa 
não estar no RPO, por isso faz um tratamento com getResArray.

@param Nil

@return Nil

@author Gustavo G. Rueda
@since 09/09/2016
/*/
//-------------------------------------------------------------------
Static Function BannerTAF()
Local	nLin	as	numeric
Local	ncol	as	numeric
Local	oDlg	as	object
Local	oLayer	as	object
Local	oSay	as	object
Local	bClick	as	codeblock
Local	oFont 	as	object
Local	cImg	as	char
Local	cTxt	as	char
Local	aRes	as	array

cImg			:=	'banner_taf'
aRes			:=	getResArray( cImg + '.jpg' )
cTxt			:=	''
oFont 			:= 	TFont():New('Arial',,-12,.T.)
oLayer 			:= 	FWLayer():New()
bClick			:=	{|| ShellExecute("open","http://tdn.totvs.com.br/pages/viewpage.action?pageId=268587913","","",1)}
nLin			:=	0
nCol			:=	820

If !( len( aRes ) > 0 )
	cTxt	:=	'<b>Prezado cliente,</b><br><br>'+ CRLF + CRLF
	cTxt	+=	'Sabemos que o cotidiano do profissional da área de tributos é bastante dinâmico e exige um controle detalhado de todas as atividades que envolvem obrigações fiscais.<br><br>'
	cTxt	+=	'Pensando nisso, a TOTVS desenvolveu o <b>TAF - TOTVS Automação Fiscal</b>, que é uma solução especialista em consolidação de informações e convergência fiscal.<br><br>'
	cTxt	+=	'Ao utilizar essa solução, você ganha <b>desempenho</b> na geração de obrigações fiscais, <b>velocidade na implementação, suporte técnico personalizado e consultoria tributária.</b><br><br>'
	cTxt	+=	'A partir de Fevereiro de 2017, algumas obrigações fiscais na linha Microsiga Protheus passarão a ser atendidas somente através do TAF.<br><br>'
EndIf

if !Empty( cTxt ) //quando o resoruce ( banner ) não estiver no rpo
	nLin	:=	470
else
	//foi necessário aumentar a tela de 520 para 570 e 420 para 470 devido a um problema de lib onde o botão (X) que fecha a tela
	//não está aparecendo na versão 12. Ajustar após correção do fw.
	nLin	:=	570
endif

//foi necessário comentar o "nOr( WS_VISIBLE, WS_POPUP )" devido a um problema de lib onde o botão (X) que fecha a tela do objeto FWLayer
//não está aparecendo na versão 12. Descomentar após correção do fw.
oDlg := MsDialog():New( 0, 0, nLin, nCol, "",,,, /*nOr( WS_VISIBLE, WS_POPUP )*/,,,,, .T.,,,, .F. )
oLayer:Init( oDlg, .T. )
oLayer:AddLine( "LINE01", 100 )
oLayer:AddCollumn( "BOX01", 100,, "LINE01" )
oLayer:AddWindow( "BOX01", "PANEL01", 'IMPORTANTE...', 100, .F.,,, "LINE01" )

If !Empty( cTxt )
	oSay	:=	TSay():New(10,10,{|| cTxt },oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ),,oFont,,,,.T.,,,380,nLin,,,,,,.T.)
	oSay:lWordWrap = .T.
	TButton():New( 155, 335, "SAIBA MAIS",oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ), bClick, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
Else
	TBitmap():New(0,0,nLin,nCol,cImg,,.T.,oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ),bClick,bClick,,.F.,,,,,.T.)
EndIf

oDlg:Activate(,,,.T.)

Return
