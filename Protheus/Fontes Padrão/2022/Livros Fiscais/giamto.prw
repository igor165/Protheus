#Include "GIAMTO.ch"
#Include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GIAMTO    ³ Autor ³  Luciana P. Munhoz    ³ Data ³ 07.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³GIAM - Guia de Informacao e Apuracao do ICMS Mensal - TO    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD -> Data incial do periodo - mv_par01                   ³±±
±±³          ³ExpD -> Data final do periodo  - mv_par02                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GIAMTO(dDtInicial, dDtFinal)
	Local aTrbs		:= {}
	Private aCfp 	:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera arquivos temporarios            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTrbs := GeraTemp()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rotina Cfp                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Cfp()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recupera dados do arquivo Cfp                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAutomato
			aCfp := aWizAuto
		Else
			xMagLeWiz("GIAMTO",@aCfp,.T.)
		EndIf
		Processa({||ProcGIAMTO(dDtInicial, dDtFinal)})
	Endif

Return(aTrbs)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcGIAMTO ³ Autor ³Luciana P. Munhoz      ³ Data ³ 07.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro da GIAM-TO                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcGIAMTO(dDtInicial, dDtFinal)

Local DtAIni := Stod(aCfp[4][03])
Local DtAFim := Stod(aCfp[4][04])
Local DtBIni := Stod(aCfp[4][05])
Local DtBFim := Stod(aCfp[4][06])
Local cDomFis:= "A"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Regitros                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se houve mudança de domicilio fiscal                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(aCfp[4][01],1,1)== "S"

	If !ValidPar(dDtInicial, dDtFinal)
		Return(Nil)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa os registros necessários para Domicilio Atual(A) e Anterior(B) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcRegA(dDtInicial, dDtFinal, cDomFis)		//Registro Tipo A - Informacoes Economico-Fiscais / Identificacao do Contribuinte / Apuracao do Imposto

	ProcRegB(DtAIni, DtAFim, "A")			 	//Registro Tipo B - Entradas e Saidas de Mercadorias, Bens e/ou Servicos no Estabelecimento do Contribuinte
	ProcRegB(DtBIni, DtBFim, "B")			 	//Registro Tipo B - Entradas e Saidas de Mercadorias, Bens e/ou Servicos no Estabelecimento do Contribuinte

	If Substr(aCfp[1][10],1,1)== "S"
		ProcRegC(dDtInicial, dDtFinal, cDomFis) 	//Registro Tipo C - Demonstrativo de Estoque
	EndIf

	ProcRegD(DtAIni, DtAFim, "A")			 	//Registro Tipo D - Det. das Entradas/Saidas de Mercadorias e/ou Prest. de Serv. por Unidade da Federacao
	ProcRegD(DtBIni, DtBFim, "B")			 	//Registro Tipo D - Det. das Entradas/Saidas de Mercadorias e/ou Prest. de Serv. por Unidade da Federacao

	ProcRegE(dDtInicial, dDtFinal, cDomFis)		//Registro Tipo E - ICMS a Recolher
	ProcRegJ(dDtInicial, dDtFinal, cDomFis)	    //Registro Tipo J - Informações TARE
	ProcRegK(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo K - Informações TARE
	ProcRegL(dDtInicial, dDtFinal, cDomFis)	    //Registro Tipo L - Informações TARE

	//Versão 9.0.0

	ProcRegM(DtAIni, DtAFim, "A")	 	   		//Registro Tipo M - Saidas e/ou Prestações e Entradas e/ou Aquisições do Estabelecimento do Contribuinte por Municipio de Origem (campo 15)
	ProcRegM(DtBIni, DtBFim, "B")	    		//Registro Tipo M - Saidas e/ou Prestações e Entradas e/ou Aquisições do Estabelecimento do Contribuinte por Municipio de Origem (campo 15)

	ProcRegN(DtAIni, DtAFim, "A")		   		//Registro Tipo N - Relação de Mercadorias e/ou Produtos adquiridos de outros Municipios Tocantinenses com Diferimento de do ICMS (campo 16 - Total das Notas Fiscais por Inscrição Estadual)
	ProcRegN(DtBIni, DtBFim, "B")			    //Registro Tipo N - Relação de Mercadorias e/ou Produtos adquiridos de outros Municipios Tocantinenses com Diferimento de do ICMS (campo 16 - Total das Notas Fiscais por Inscrição Estadual)

	ProcRegO(DtAIni, DtAFim, "A")			    //Registro Tipo O - Relação de Mercadorias e/ou Produtos adquiridos de outros Municipios Tocantinenses com Diferimento de do ICMS (campo 16 - Notas Fiscais por Inscrição Estadual)
	ProcRegO(DtBIni, DtBFim, "B")	    		//Registro Tipo O - Relação de Mercadorias e/ou Produtos adquiridos de outros Municipios Tocantinenses com Diferimento de do ICMS (campo 16 - Notas Fiscais por Inscrição Estadual)

	ProcRegP(DtAIni, DtAFim, "A")			    //Registro Tipo P - Detalhamento do Diferencial de Alíquotas por UF (7.6.1)
	ProcRegP(DtBIni, DtBFim, "B")	    		//Registro Tipo P - Detalhamento do Diferencial de Alíquotas por UF (7.6.1)

	ProcRegQ(DtAIni, DtAFim, "A")			    //Registro Tipo Q - Especificação da Complementação de Alíquotas por UF (7.9.1)
	ProcRegQ(DtBIni, DtBFim, "B")	    		//Registro Tipo Q - Especificação da Complementação de Alíquotas por UF (7.9.1)

	ProcRegR(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo R - Especificação de Outros Debitos (5.2.1)

	ProcRegS(DtAIni, DtAFim, "A")			    // Especificação do Diferencial de Alíquotas Consumidor Final (Saídas) por UF   7.13.1
	ProcRegS(DtAIni, DtAFim, "B")			    // Especificação do Diferencial de Alíquotas Consumidor Final (Saídas) por UF   7.13.1

	ProcRegZ(dDtInicial)						//Registro Tipo Z - Indica o Final da Declaracao

Else
	ProcRegA(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo A - Informacoes Economico-Fiscais / Identificacao do Contribuinte / Apuracao do Imposto
	ProcRegB(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo B - Entradas e Saidas de Mercadorias, Bens e/ou Servicos no Estabelecimento do Contribuinte
	If Substr(aCfp[1][10],1,1)== "S"
		ProcRegC(dDtInicial, dDtFinal, cDomFis) //Registro Tipo C - Demonstrativo de Estoque
	EndIf
	ProcRegD(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo D - Det. das Entradas/Saidas de Mercadorias e/ou Prest. de Serv. por Unidade da Federacao
	ProcRegE(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo E - ICMS a Recolher
	ProcRegJ(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo J - Informações TARE
	ProcRegK(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo K - Informações TARE
	ProcRegL(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo L - Informações TARE
	//Versão 9.0.0
	ProcRegM(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo M - Saidas e/ou Prestações e Entradas e/ou Aquisições do Estabelecimento do Contribuinte por Municipio de Origem (campo 15)
	ProcRegN(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo N - Relação de Mercadorias e/ou Produtos adquiridos de outros Municipios Tocantinenses com Diferimento de do ICMS (campo 16 - Total das Notas Fiscais por Inscrição Estadual)
	ProcRegO(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo O - Relação de Mercadorias e/ou Produtos adquiridos de outros Municipios Tocantinenses com Diferimento de do ICMS (campo 16 - Notas Fiscais por Inscrição Estadual)
	ProcRegP(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo P - Detalhamento do Diferencial de Alíquotas por UF (7.6.1)
	ProcRegQ(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo Q - Especificação da Complementação de Alíquotas por UF (7.9.1)
	ProcRegR(dDtInicial, dDtFinal, cDomFis)     //Registro Tipo R - Especificação de Outros Debitos (5.2.1)
	// 10.00
	ProcRegS(dDtInicial, dDtFinal, cDomFis)     //Especificação do Diferencial de Alíquotas Consumidor Final (Saídas) por UF   7.13.1
	//
	ProcRegZ(dDtInicial)                        //Registro Tipo Z - Indica o Final da Declaracao
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegA   ³ Autor ³Luciana P. Munhoz      ³ Data ³ 07.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo A - Informacoes Economico-Fiscais /   ³±±
±±³			 ³Identificacao do Contribuinte / Apuracao do Imposto          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegA(dDtInicial, dDtFinal, cDomFis)
	Local cApurICM		:= ""
	Local cAliasSD1    	:="SD1"
	
	Local nSaldoIni		:= Iif (Month(dDtInicial) == 01,Val(aCfp[1][07]),0)
	Local nSaldoFim 	:= Iif (Month(dDtInicial) == 12,Val(aCfp[1][08]),0)
	Local lSimples 		:= Iif(SuperGetMv("MV_SIMPLES")=="S",.T.,.F.)
	Local nDebImpSa 	:= 0
	Local nDebImpOu 	:= 0
	Local nDebImpEs 	:= 0
	Local nCreImpEn 	:= 0
	Local nCreImpOu 	:= 0
	Local nCreImpEs 	:= 0
	Local nCreImpSa 	:= 0
	Local nApuDed		:= 0
	Local nApuDif  		:= 0
	Local nVlrProd 		:= 0
	Local nBase  		:= 0
	Local nICMSST  		:= 0
	Local nCredICM 		:= 0
	Local lQuery	:= .F.
	Local aSaidaST  := {}
	#IFDEF TOP
		Local aStruSD1 	:=	{}
		Local cQuery   	:=	""
		Local nX		:=	0
	#ELSE
		Local cInd		:=	""
		Local cChave	:=	""
		Local cFiltro	:=	""
		Local nRetInd	:=	0
	#ENDIF
	                 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento da Apuracao	                                   	       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                               

	cApurICM := FisApur("IC",Year(dDtInicial),Month(dDtFinal),2,0,"*",.F.,{},1,.T.,"APR","")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acumula Valor da Apuracao          	                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
	
	dbSelectArea("APR")
	DbGoTop()
	
	Do While ! APR->(Eof())
		nDebImpSa += Iif(AllTrim(APR->CODIGO) == "001",APR->VALOR,0)
		nDebImpOu += Iif(AllTrim(APR->CODIGO) == "002" .And. Alltrim(APR->SUBCOD) == "002.00",APR->VALOR,0)
		nDebImpEs += Iif(AllTrim(APR->CODIGO) == "003" .And. Alltrim(APR->SUBCOD) == "003.00",APR->VALOR,0)
		nCreImpEn += Iif(AllTrim(APR->CODIGO) == "005" ,APR->VALOR,0)
		nCreImpOu += Iif(AllTrim(APR->CODIGO) == "006" .And. Alltrim(APR->SUBCOD) == "006.00",APR->VALOR,0)
		nCreImpEs += Iif(AllTrim(APR->CODIGO) == "007" .And. Alltrim(APR->SUBCOD) == "007.00",APR->VALOR,0)
		nCreImpSa += Iif(AllTrim(APR->CODIGO) == "009",APR->VALOR,0)
		nApuDed	  += Iif(AllTrim(APR->CODIGO) == "012" .And. Alltrim(APR->SUBCOD) == "012.00",APR->VALOR,0)
		nApuDif   += Iif(AllTrim(APR->CODIGO) == "016",APR->VALOR,0)
		APR->(dbSkip())
	Enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona a entradas dos produtos a ser pesquisado com ICMS ST. 							   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea("SD1")
	dbSetOrder(1)
	ProcRegua(LastRec())
	
	#IFDEF TOP
	// NFE que deve ser de outro de um estado diferente de TO, com Antecipacao Tributaria e ICMS ST
	// Filtro agrupando pelo codigo da TES 
		If TcSrvType()<>"AS/400"
			lQuery		:= .T.
			cAliasSD1	:= "SD1_GIAMTO"
			aStruSD1	:= SD1->(dbStruct())
			cQuery		:= "SELECT D1_TES, SUM(D1_TOTAL) D1_TOTAL,SUM(D1_BRICMS) D1_BRICMS, "
			cQuery    	+= "SUM(D1_ICMSRET) D1_ICMSRET,SUM(D1_VALICM) D1_VALICM "
			cQuery    	+= "FROM " + RetSqlName("SD1") + " "
			cQuery    	+= "WHERE D1_FILIAL = '" + xFilial("SD1") + "' AND "
			cQuery 		+= "D1_EMISSAO >= '" + Dtos(dDtInicial) + "' AND "
			cQuery 		+= "D1_EMISSAO <= '" + Dtos(dDtFinal) + "' AND "
			cQuery    	+= "D1_ICMSRET > 0  AND D1_TIPO NOT IN ('D','B','S') AND "
			cQuery    	+= "D_E_L_E_T_ <> '*' "
			cQuery    	+= "Group by D1_TES "
			cQuery 		:= ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1)
			For nX := 1 To len(aStruSD1)
				If aStruSD1[nX][2] <> "C"
					TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
				EndIf
			Next nX
			
			dbSelectArea(cAliasSD1)
			  			
		Else
	#ENDIF
			cIndex    := CriaTrab(NIL,.F.)
			cCondicao := 'D1_FILIAL == "' + xFilial("SD1") + '" .And. '
			cCondicao += 'DTOS(D1_EMISSAO) >= "' + Dtos(dDtInicial) + '" .And. '
			cCondicao += 'DTOS(D1_EMISSAO) <= "' + Dtos(dDtFinal) + '" .And. '
			cCondicao += 'D1_ICMSRET > 0 .And. ! D1_TIPO $ "D/B/S" '
			IndRegua(cAliasSD1,cIndex,SD1->(IndexKey()),,cCondicao)
			dbSelectArea(cAliasSD1)
			ProcRegua(LastRec())
			dbGoTop()
	#IFDEF TOP
		Endif
	#ENDIF
	// Chamada da funcao ProSD2ST () 
	// Retorno:
	// aSaidaST[1] contem o Valor dos Produtos
	// aSaidaST[2] contem a Base de Calculo
	// aSaidaST[3] contem o Debito de ICMS ST
	// aSaidaST[4] contem o Credito de ICMS ST
	
	aSaidaST := ProSD2ST(dDtInicial, dDtFinal, cDomFis)
	
	// Utilizando o TOP
	If lQuery
		
		dbSelectArea("SF4")
		dbSetOrder(1)
		Do While !(cAliasSD1)->(Eof())
			SF4->(DbSeek(xFilial("SF4")+(cAliasSD1)->D1_TES))
			If SF4->F4_ANTICMS == "1" // Condicao para que a NFE selecionada tenha antecipacao tributaria
				nVlrProd 	+= (cAliasSD1)->D1_TOTAL
				nBase 		+= (cAliasSD1)->D1_BRICMS
				nICMSST  	+= (cAliasSD1)->D1_ICMSRET
			EndIf
			(cAliasSD1)->(Dbskip())
		Enddo
	
		// Somatorio das Notas Fiscais de Entradas e Saidas com suas respectivas condicoes
		nVlrProd 	+= aSaidaST[1]
		nBase 		+= aSaidaST[2]
		nICMSST  	+= aSaidaST[3]
		nCredICM 	:= aSaidaST[4]
	Else
	// Se for DBF
		Do While !((cAliasSD1)->(Eof()))
			nVlrProd	+= (cAliasSD1)->D1_TOTAL
			nBase 		+= (cAliasSD1)->D1_BRICMS
			nICMSST 	+= (cAliasSD1)->D1_ICMSRET
			(cAliasSD1)->(dbSkip())
		Enddo
		
		nVlrProd 	+= aSaidaST[1]
		nBase 		+= aSaidaST[2]
		nICMSST  	+= aSaidaST[3]
		nCredICM 	:= aSaidaST[4]
		                                     
	Endif
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento Registro RTA	            		                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
	
	dbSelectArea("RTA")
	RecLock("RTA",.T.)
	
	RTA->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
	RTA->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
	RTA->RETIFICA 	:= Val(aCfp[2][07])
	RTA->ATIVIDADE 	:= Val(aFisFill(SM0->M0_CNAE,9))
	RTA->TIPOESTAB	:= Left(Alltrim(aCfp[1][01]),1)
	RTA->TARE		:= Left(Alltrim(aCfp[1][02]),1)
	RTA->TIPOESCR	:= Left(Alltrim(aCfp[1][05]),1)
	RTA->SALDOINI	:= Iif (Alltrim(aCfp[1][05])=="Fiscal",nSaldoIni,0)
	RTA->SALDOFIM  	:= Iif (Alltrim(aCfp[1][05])=="Fiscal",nSaldoFim,0)
	RTA->USAECF  	:= Left(Alltrim(aCfp[1][06]),1)
	RTA->CPFDECLAR 	:= Alltrim(aCfp[2][01])
	RTA->NOMEDECLAR	:= Alltrim(aCfp[2][02])
	RTA->CRCCONTAB 	:= ALLTRIM(aCfp[2][03])
	RTA->UFCRCCONTA	:= Alltrim(aCfp[2][04])
	RTA->NOMECONTAB	:= Alltrim(aCfp[2][05])
	RTA->FONECONTAB	:= Alltrim(aCfp[2][06])
	RTA->SAIDADEBI	:= Iif (lSimples,0,nDebImpSa)
	RTA->OUTROSDEB	:= Iif (substr(RTA->PERIODOREF,3,4) + substr(RTA->PERIODOREF,1,2) < substr("082012",3,4) + substr("082012",1,2),nDebImpOu,0)
	RTA->ESTORCRED	:= Iif (lSimples,0,nDebImpEs)
	RTA->ENTRADEBI 	:= Iif (lSimples,0,nCreImpEn)
	RTA->OUTROSCRED	:= 0
	RTA->ESTORDEB	:= Iif (lSimples,0,nCreImpEs)
	RTA->SALDOCRED	:= 0
	RTA->DEDUCOES	   := 0
	RTA->DIFALIQREC	:= nApuDif
	RTA->VLRPROD   	:= nVlrProd
	RTA->BASECALC  	:= nBase
	RTA->ICMSSUBST 	:= nICMSST
	RTA->CREDICMS	:= nCredICM
	RTA->OUTRCREDI	:= Iif(AllTrim(APR->CODIGO) == "006" .And. Alltrim(APR->SUBCOD) == "006.00",APR->VALOR,0)
	RTA->NUMTARE  	:= Alltrim(aCfp[1][03])
	RTA->DTVENCTARE	:= Substr(aCfp[1][04],7,2) + Substr(aCfp[1][04],5,2) + Substr(aCfp[1][04],1,4)
	RTA->DIFALIQATU	:= 0
	RTA->DIFALIQANT	:= 0
	RTA->TIPOENCERR	:= Iif (SM0->M0_CNAE == "5050400",Left(Alltrim(aCfp[2][08]),1),"")
	RTA->COMPLALIQ  := 0
	RTA->DIFALQCONF	:= 0
	RTA->HOUVEMUD   := Substr(aCfp[4][01],1,1)
	If Substr(aCfp[4][01],1,1)=="S"
		RTA->MUNICIPANT := Val(AllTrim(aCfp[4][02]))
		RTA->DINIMUNATU := Substr(aCfp[4][03],7,2) + Substr(aCfp[4][03],5,2) + Substr(aCfp[4][03],1,4)   //DDMMAAAA
		RTA->DFIMMUNATU := Substr(aCfp[4][04],7,2) + Substr(aCfp[4][04],5,2) + Substr(aCfp[4][04],1,4)   //DDMMAAAA
		RTA->DINIMUNANT := Substr(aCfp[4][05],7,2) + Substr(aCfp[4][05],5,2) + Substr(aCfp[4][05],1,4)   //DDMMAAAA
		RTA->DFIMMUNANT := Substr(aCfp[4][06],7,2) + Substr(aCfp[4][06],5,2) + Substr(aCfp[4][06],1,4)   //DDMMAAAA
	EndIf
	MsUnlock()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SD1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SD1")
		dbClearFilter()
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSD1)
		dbCloseArea()
	Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ProSD2ST  ºAutor  ³Henrique Lustosa    º Data ³  02/14/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Seleciona na tabela D2 os requisitos com as seguintes     º±±
±±º          ³condicoes: NF de Saida , operacoes internas e ICMS-ST.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ProSD2ST(dDtInicial, dDtFinal, cDomFis)
	
	Local cAliasSD2 :="SD2"
	Local aSaidaST  := array(4)
	Local lQuery    := .F.
	
	#IFDEF TOP
		Local aStruSD2 	:=	{}
		Local cQuery   	:=	""
		Local nX		:=	0
	#ELSE
		Local cInd		:=	""
		Local cChave	:=	""
		Local cFiltro	:=	""
		Local nRetInd	:=	0
	#ENDIF
	aSaidaST      := {0,0,0,0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona a entradas dos produtos a ser pesquisado com ICMS ST. 							   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetMv ("MV_ESTADO") == "TO"
		dbSelectArea("SD2")
		dbSetOrder(1)
		ProcRegua(LastRec())
	// NFS que deve ser de TO para TO(0peracoes Internas) e ICMS-ST	
		#IFDEF TOP
			If TcSrvType()<>"AS/400"
				lQuery		:= .T.
				cAliasSD2	:= "SD2_GIAMTO"
				aStruSD1	:= SD2->(dbStruct())
				cQuery		:= "SELECT SUM(D2_TOTAL) D2_TOTAL,SUM(D2_BRICMS) D2_BRICMS, "
				cQuery    	+= "SUM(D2_ICMSRET) D2_ICMSRET,SUM(D2_VALICM) D2_VALICM "
				cQuery    	+= "FROM " + RetSqlName("SD2") + " "
				cQuery    	+= "WHERE D2_FILIAL = '" + xFilial("SD2") + "' AND "
				cQuery 		+= "D2_EMISSAO >= '" + Dtos(dDtInicial) + "' AND "
				cQuery 		+= "D2_EMISSAO <= '" + Dtos(dDtFinal) + "' AND "
				cQuery 		+= "D2_EST = '" + "TO" + "' AND "
				cQuery    	+= "D2_ICMSRET > 0  AND D2_TIPO NOT IN ('D','B','S') AND "
				cQuery    	+= "D_E_L_E_T_ <> '*' "
				cQuery 		:= ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2)
				For nX := 1 To len(aStruSD2)
					If aStruSD2[nX][2] <> "C"
						TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
					EndIf
				Next nX
			Else
		#ENDIF
				cIndex    := CriaTrab(NIL,.F.)
				cCondicao := 'D2_FILIAL == "' + xFilial("SD2") + '" .And. '
				cCondicao += 'DTOS(D2_EMISSAO) >= "' + Dtos(dDtInicial) + '" .And. '
				cCondicao += 'DTOS(D2_EMISSAO) <= "' + Dtos(dDtFinal) + '" .And. '
				cCondicao += 'D2_EST == "TO"'+' .And. '
				cCondicao += 'D2_ICMSRET > 0 .And. !D2_TIPO $ "D/B/S" '
				IndRegua(cAliasSD2,cIndex,(cAliasSD2)->(IndexKey()),,cCondicao)
				dbSelectArea(cAliasSD2)
				ProcRegua(LastRec())
				dbGoTop()
		#IFDEF TOP
			Endif
		#ENDIF
		// Utilizando o TOP
		If lQuery
			dbSelectArea(cAliasSD2)
				
			aSaidaST[1] 	+= (cAliasSD2)->D2_TOTAL			// Valor dos Produtos
			aSaidaST[2]  	+= (cAliasSD2)->D2_BRICMS			// Base de Calculo
			aSaidaST[3]  	+= (cAliasSD2)->D2_ICMSRET			// Debito de ICMS ST
			aSaidaST[4]		+= (cAliasSD2)->D2_VALICM 			// Credito de ICMS ST
	
		Else
		// Se for DBF
			Do While !((cAliasSD2)->(Eof()))
				aSaidaST[1] 	+= (cAliasSD2)->D2_TOTAL			// Valor dos Produtos
				aSaidaST[2]  	+= (cAliasSD2)->D2_BRICMS			// Base de Calculo
				aSaidaST[3]  	+= (cAliasSD2)->D2_ICMSRET			// Debito de ICMS ST
				aSaidaST[4]		+= (cAliasSD2)->D2_VALICM 			// Credito de ICMS ST
				(cAliasSD2)->(dbSkip())
			Enddo
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclui area de trabalho utilizada - SD1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lQuery
			RetIndex("SD2")
			dbClearFilter()
			Ferase(cIndex+OrdBagExt())
		Else
			dbSelectArea(cAliasSD2)
			dbCloseArea()
		Endif
	Endif
Return aSaidaST
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegB   ³ Autor ³Luciana P. Munhoz      ³ Data ³ 07.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo B - Entradas e Saidas de Mercadorias, ³±±
±±³          ³Bens e/ou Servicos no Estabelecimento do Contribuinte        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegB(dDtInicial, dDtFinal, cDomFis)
	LOCAL cAliasSF3 	:= "SF3"
	Local cEntrSai 	:= ""
	Local nDiferenc	:= 0
	Local lSimples 	:= Iif(SuperGetMv("MV_SIMPLES")=="S",.T.,.F.)
	Local cMvVlCtSt	:= SuperGetMv("MV_VLCTST",,"")
	#IFDEF TOP
		Local aStruSF3 	:=	{}
		Local cQuery   	:=	""
		Local nX		:=0
	#ELSE
		Local cIndSF3	:= ""
		Local cChave	:= ""
		Local cFiltro	:= ""
	#ENDIF
	Default cDomFis := "A"

	#IFDEF TOP
		lQuery := .T.
		cAliasSF3	:= "a953AMontSF3"
		aStruSF3	:= SF3->(dbStruct())
		cQuery 	+= "SELECT SF3.F3_FILIAL,SF3.F3_ENTRADA,SF3.F3_TIPO,SF3.F3_DTCANC, "
		cQuery 	+=	"SF3.F3_CFO, SF3.F3_VALICM, SF3.F3_VALCONT, SF3.F3_BASEICM, SF3.F3_OUTRICM, "
		cQuery 	+=	"SF3.F3_ICMSRET, SF3.F3_ESTADO, SF3.F3_OUTRICM, SF3.F3_VALCONT, SF3.F3_ISENICM "
		cQuery 	+= "FROM "+RetSqlName("SF3")+" SF3 "
		cQuery 	+= "WHERE F3_FILIAL	= 	'"+xFilial("SF3")+"' AND "
		cQuery 	+= "SF3.F3_ENTRADA		>=	'"+Dtos(dDtInicial)+"' AND "
		cQuery 	+= "SF3.F3_ENTRADA		<=	'"+Dtos(dDtFinal)+"' AND "
		cQuery		+= "SF3.F3_TIPO 			<>	'S' AND "
		cQuery		+= "SF3.F3_DTCANC			= 	'"+Dtos(Ctod(""))+"' AND "
		cQuery 	+= "SF3.D_E_L_E_T_ 		<> '*' "
		cQuery 	+= "ORDER BY "+SqlOrder(SF3->(IndexKey()))
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
	
		For nX := 1 To len(aStruSF3)
			If aStruSF3[nX][2] <> "C" .And. FieldPos(aStruSF3[nX][1])<>0
				TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSF3)
		(cAliasSF3)->(DbGoTop())
	#ELSE
		dbSelectArea(cAliasSF3)
		cIndSF3	:=	CriaTrab(NIL,.F.)
		cChave	:=	IndexKey()
		cFiltro	:=	"SF3->F3_FILIAL=='"+xFilial("SF3")+"' .And. DTOS(SF3->F3_ENTRADA)>='"+Dtos(dDtInicial)+"' .AND. DTOS(SF3->F3_ENTRADA)<='"+Dtos(dDtFinal)+"'"
		cFiltro	+=	" .And. DTOS(SF3->F3_DTCANC)=='"+Dtos(Ctod(""))+"'"
		cFiltro	+=	" .And. SF3->F3_TIPO <> 'S' "
		IndRegua(cAliasSF3,cIndSF3,cChave,,cFiltro)
		(cAliasSF3)->(DbgoTop())
	#ENDIF
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processamento Registro RTB	                                   	       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

	Do While (cAliasSF3)->(!Eof())	
		DbSelectArea("RTB")
		cEntrSai := ""			
		If (cAliasSF3)->F3_CFO < "5000"
			cEntrSai := "0"
		Else
			cEntrSai := "1"
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processamento por CFOPS		                                   	     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

			nDiferenc	:= 0
			If ((cAliasSF3)->F3_BASEICM+(cAliasSF3)->F3_OUTRICM+(cAliasSF3)->F3_ICMSRET) > 0
				nDiferenc  := ((cAliasSF3)->F3_VALCONT) - ((cAliasSF3)->F3_BASEICM+(cAliasSF3)->F3_OUTRICM+(cAliasSF3)->F3_ICMSRET)
			EndIF

			If !RTB->(DbSeek(AllTrim((cAliasSF3)->F3_CFO)))
				RecLock("RTB",.T.)
				RTB->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
				RTB->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
				RTB->RETIFICA		:= Val(aCfp[2][07])
				RTB->ENTRSAIDA	:= cEntrSai					
				RTB->CFOP			:= (cAliasSF3)->F3_CFO
								
				If Alltrim((cAliasSF3)->F3_CFO) $ cMvVlCtSt
					RTB->SUBSTTRIB	:= (cAliasSF3)->F3_VALCONT
				Else
					RTB->BASECAL  	:= Iif (lSimples,0,(cAliasSF3)->F3_BASEICM)
					RTB->ISENTAS  	:= Iif (lSimples,0,(cAliasSF3)->F3_ISENICM)
					RTB->OUTRAS   	:= (cAliasSF3)->F3_OUTRICM + nDiferenc
					RTB->SUBSTTRIB	:= (cAliasSF3)->F3_ICMSRET
					RTB->CREDDEB		:= Iif (lSimples,0,(cAliasSF3)->F3_VALICM)
				EndIf				 
				RTB->VLRCONTAB	:= (cAliasSF3)->F3_VALCONT
				RTB->DOMICFISC  	:= cDomFis
				MsUnlock()
			Else
				RecLock("RTB",.F.)				
				If Alltrim((cAliasSF3)->F3_CFO) $ cMvVlCtSt
					RTB->SUBSTTRIB	+= (cAliasSF3)->F3_VALCONT
				Else
					RTB->BASECAL  	+= Iif (lSimples,0,(cAliasSF3)->F3_BASEICM)
					RTB->ISENTAS  	+= Iif (lSimples,0,(cAliasSF3)->F3_ISENICM)
					RTB->OUTRAS   	+= (cAliasSF3)->F3_OUTRICM + nDiferenc
					RTB->SUBSTTRIB	+= (cAliasSF3)->F3_ICMSRET
					RTB->CREDDEB		+= Iif (lSimples,0,(cAliasSF3)->F3_VALICM)
				EndIf
				RTB->VLRCONTAB	+= (cAliasSF3)->F3_VALCONT				
			EndIf
		(cAliasSF3)->(dbSkip())
	Enddo
	If !lQuery
		RetIndex(cAliasSF3)
		dbClearFilter()
	Else
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegC   ³ Autor ³Luciana P. Munhoz      ³ Data ³ 07.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo C - Demonstrativo de Estoque          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegC(dDtInicial, dDtFinal, cDomFis)

	Local dDtFecEst := Stod(aCfp[1][9])
	Local lSimples  := Iif(SuperGetMv("MV_SIMPLES")=="S",.T.,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula Estoques Iniciais e Finais³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

	dbSelectArea("RTC")
	RecLock("RTC",.T.)
	
	RTC->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
	RTC->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
	RTC->RETIFICA	:= Val(aCfp[2][07])
	RTC->EINITRIB	:= 0
	RTC->EINIISENT	:= 0
	RTC->EINIOUTRA	:= 0
	RTC->EINISUBTR	:= 0
	RTC->EINIVLRTOT	:= 0
	RTC->EFIMTRIB	:= 0
	RTC->EFIMISENT	:= 0
	RTC->EFIMOUTRA	:= 0
	RTC->EFIMSUBTR	:= 0
	RTC->EFIMVLRTOT	:= 0
	MsUnlock()
	RTC->(dbGoTop())
	RecLock("RTC",.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processando o saldo inicial do periodo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEst := {"EST",""}
	FsEstInv(aEst,1,.T.,.F.,dDtFecEst,.F.,.F.,,,,,,,,,,,,.F.)

	EST->(dbGoTop())
	Do While ! EST->(Eof())

		// Estoque na empresa
		If EST->SITUACA == "1"
			Do Case
			Case EST->CLASSFIS $ "10/30/60/70" //Substituição Tributária
				RTC->EINISUBTR	+= EST->CUSTO
			Case EST->CLASSFIS $ "40/41"		//Isentas
				RTC->EINIISENT	+= Iif (lSimples,0,EST->CUSTO)
			Case EST->CLASSFIS $ "50/51/90"  	//Outros
				RTC->EINIOUTRA	+= EST->CUSTO
			OtherWise                       	//Tributadas
				RTC->EINITRIB	+= EST->CUSTO
			EndCase
		ElseIf EST->SITUACA == "3" // Estoque de terceiros na empresa (nao deve fazer parte do montante)
			Do Case
			Case EST->CLASSFIS $ "10/30/60/70" //Substituição Tributária
				RTC->EINISUBTR	-= EST->CUSTO
			Case EST->CLASSFIS $ "40/41"		//Isentas
				RTC->EINIISENT	-= Iif (lSimples,0,EST->CUSTO)
			Case EST->CLASSFIS $ "50/51/90"  	//Outros
				RTC->EINIOUTRA	-= EST->CUSTO
			OtherWise                       	//Tributadas
				RTC->EINITRIB	-= EST->CUSTO
			EndCase
		Endif

		EST->(dbSkip())
	Enddo

	// Excluindo area aberta pela funcao FsEstInv
	FsEstInv(aEst,2,,,dDtFecEst,.F.,.F.,,,,,,,,,,,,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processando o saldo final do periodo  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEst := {"EST",""}
	FsEstInv(aEst,1,.T.,.F.,dDtFecEst,.F.,.F.,,,,,,,,,,,,.F.)

	EST->(dbGoTop())
	Do While ! EST->(Eof())

		// Estoque na empresa
		If EST->SITUACA == "1"
			Do Case
			Case EST->CLASSFIS $ "10/30/60/70" //Substituição Tributária
				RTC->EFIMSUBTR	+= EST->CUSTO
			Case EST->CLASSFIS $ "40/41"		//Isentas
				RTC->EFIMISENT	+= EST->CUSTO
			Case EST->CLASSFIS $ "50/51/90"  	//Outros
				RTC->EFIMOUTRA	+= EST->CUSTO
			OtherWise                       	//Tributadas
				RTC->EFIMTRIB	+= EST->CUSTO
			EndCase
		ElseIf EST->SITUACA == "3" // Estoque de terceiros na empresa (nao deve fazer parte do montante)
			Do Case
			Case EST->CLASSFIS $ "10/30/60/70" //Substituição Tributária
				RTC->EFIMSUBTR	-= EST->CUSTO
			Case EST->CLASSFIS $ "40/41"		//Isentas
				RTC->EFIMISENT	-= EST->CUSTO
			Case EST->CLASSFIS $ "50/51/90"  	//Outros
				RTC->EFIMOUTRA	-= EST->CUSTO
			OtherWise                       	//Tributadas
				RTC->EFIMTRIB	-= EST->CUSTO
			EndCase
		Endif

		EST->(dbSkip())
	Enddo

	// Excluindo area aberta pela funcao FsEstInv
	FsEstInv(aEst,2,,,dDtFecEst,.F.,.F.,,,,,,,,,,,,.F.)

	RTC->EINIVLRTOT 	+= RTC->EINISUBTR + RTC->EINIISENT + RTC->EINIOUTRA + RTC->EINITRIB
	RTC->EFIMVLRTOT 	+= RTC->EFIMSUBTR + RTC->EFIMISENT + RTC->EFIMOUTRA + RTC->EFIMTRIB
	MsUnLock()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegD   ³ Autor ³Luciana P. Munhoz      ³ Data ³ 07.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo D - Detalhamento das Entradas/Saidas  ³±±
±±³          ³de Mercadorias e/ou Prestacoes de Servicos por Unidade da    ³±±
±±³          ³Federacao                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegD(dDtInicial, dDtFinal, cDomFis)
	LOCAL cAliasSF3 	:= "SF3"
	Local cEntrSai	:= ""
	Local nDiferenc	:= 0
	Local nDebimpnc	:= 0
	Local nDebCred 	:= 0	
	Local lSimples 	:= Iif(SuperGetMv("MV_SIMPLES")=="S",.T.,.F.)
	Local cMvVlCtSt	:= SuperGetMv("MV_VLCTST",,"")
	Local lNaoContr	:= .F. // Se .T. é não contribuinte

	Local lQuery	:= .F.
	
	#IFDEF TOP
		Local aStruSF3	:=	{}
		Local cQuery   	:=	""
		Local nX			:= 0
	#ELSE
		Local cIndSF3	:= ""
		Local cChave	:= ""
		Local cFiltro	:= ""
	#ENDIF
	SA1->(DbSetOrder(1))
	SA2->(DbSetOrder(1))
	#IFDEF TOP
		lQuery := .T.
		cAliasSF3	:= "a953AMontSF3"
		aStruSF3	:= SF3->(dbStruct())
		cQuery 	:= "SELECT SF3.F3_FILIAL,SF3.F3_ENTRADA,SF3.F3_TIPO,SF3.F3_DTCANC,SF3.F3_CLIEFOR,SF3.F3_LOJA, " 
		cQuery 	+=	"SA1.A1_FILIAL,SA1.A1_COD,SA1.A1_LOJA, "
		cQuery 	+=	"SA2.A2_FILIAL,SA2.A2_COD,SA2.A2_LOJA, "
		cQuery 	+=	"SF3.F3_CFO, SF3.F3_VALICM, SF3.F3_VALCONT, SF3.F3_BASEICM, SF3.F3_OUTRICM, "
		cQuery 	+=	"SF3.F3_ICMSRET, SF3.F3_ESTADO, SF3.F3_OUTRICM, SF3.F3_VALCONT, SF3.F3_ISENICM, "
		cQuery 	+=	" "
       cQuery 	+= "Case "
       cQuery 	+= "When SF3.F3_CFO > '5000' AND SF3.F3_TIPO NOT IN ('D','B')	then SA1.A1_INSCR " 
       cQuery 	+= "When SF3.F3_CFO > '5000' AND SF3.F3_TIPO IN ('D','B') 		then SA2.A2_INSCR "
       cQuery 	+= "When SF3.F3_CFO < '5000' AND SF3.F3_TIPO NOT IN ('D','B') 	then SA2.A2_INSCR " 
       cQuery 	+= "When SF3.F3_CFO < '5000' AND SF3.F3_TIPO IN ('D','B') 		then SA1.A1_INSCR " 
       cQuery 	+= "End as A1_INSCR,"
       cQuery 	+= "Case "
       cQuery 	+= "When SF3.F3_CFO >= '5000' AND SF3.F3_TIPO NOT IN ('D','B')	then SA1.A1_TIPO " 
       cQuery 	+= "When SF3.F3_CFO >= '5000' AND SF3.F3_TIPO IN ('D','B') 		then SA2.A2_TIPO "
       cQuery 	+= "When SF3.F3_CFO < '5000' AND SF3.F3_TIPO NOT IN ('D','B') 	then SA2.A2_TIPO " 
       cQuery 	+= "When SF3.F3_CFO < '5000' AND SF3.F3_TIPO IN ('D','B') 		then SA1.A1_TIPO " 
       cQuery 	+= "End as A1_TIPO "
		cQuery 	+= "FROM 					"+RetSqlName("SF3")+" SF3 "
		cQuery 	+= "Left Join 			"+RetSqlName("SA1")+" SA1 on " 
		cQuery 	+= "SA1.A1_FILIAL		= 	'"+xFilial("SA1")+"' AND "
		cQuery 	+= "SA1.A1_COD 		= 	SF3.F3_CLIEFOR AND "
		cQuery 	+= "SA1.A1_LOJA		= 	SF3.F3_LOJA AND "
		cQuery 	+= "SA1.D_E_L_E_T_ 	<> '*' "
		cQuery 	+= "Left Join 			"+RetSqlName("SA2")+" SA2 on " 
		cQuery 	+= "SA2.A2_FILIAL		=	'"+xFilial("SA2")+"' AND "
		cQuery 	+= "SA2.A2_COD 		= 	SF3.F3_CLIEFOR AND "
		cQuery 	+= "SA2.A2_LOJA 		= 	SF3.F3_LOJA AND "
		cQuery 	+= "SA2.D_E_L_E_T_ 	<>	'*' "
		cQuery 	+= "WHERE F3_FILIAL	=	'"+xFilial("SF3")+"' AND "
		cQuery 	+= "SF3.F3_ENTRADA	>=	'"+Dtos(dDtInicial)+"' AND "
		cQuery 	+= "SF3.F3_ENTRADA	<=	'"+Dtos(dDtFinal)+"' AND "
		cQuery		+= "SF3.F3_TIPO 		<> 	'S' AND "
		cQuery		+= "SF3.F3_DTCANC 	= 	'"+Dtos(Ctod(""))+"' AND "
		cQuery 	+= "SF3.D_E_L_E_T_ 	<> 	'*' "
		cQuery 	+= "ORDER BY 				"+SqlOrder(SF3->(IndexKey()))
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
	
		For nX := 1 To len(aStruSF3)
			If aStruSF3[nX][2] <> "C" .And. FieldPos(aStruSF3[nX][1])<>0
				TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSF3)
	#ELSE
		lQuery := .F.
		dbSelectArea(cAliasSF3)
		cIndSF3	:=	CriaTrab(NIL,.F.)
		cChave	:=	IndexKey()
		cFiltro	:=	"SF3->F3_FILIAL=='"+xFilial("SF3")+"' .And. DTOS(SF3->F3_ENTRADA)>='"+Dtos(dDtInicial)+"' .AND. DTOS(SF3->F3_ENTRADA)<='"+Dtos(dDtFinal)+"'"
		cFiltro	+=	" .And. DTOS(SF3->F3_DTCANC)=='"+Dtos(Ctod(""))+"'"
		cFiltro	+=	" .And. SF3->F3_TIPO <> 'S' "
		IndRegua(cAliasSF3,cIndSF3,cChave,,cFiltro)
		(cAliasSF3)->(DbgoTop())
	#ENDIF
	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento Registro RTD	                                   	       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	
	DbSelectArea(cAliasSF3)
	DbGoTop()
	
	If !lQuery
			SA1->(DbSetOrder(1))
			SD2->(DbSetOrder(3))
	EndIf
	
	Do While ! (cAliasSF3)->(Eof())
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificacao - Contribuinte ou nao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		#IFDEF TOP
			If (AllTrim ((cAliasSF3)->F3_CFO)$"618/619/545/645/553/653/751/563/663") .Or.(AllTrim ((cAliasSF3)->F3_CFO)$"6107/6108/5258/6258/5307/6307/5357/6357") .Or.;
					("ISENT" $Upper((cAliasSF3)->A1_INSCR) .And. Left ((cAliasSF3)->F3_CFO,1)>= "5") .Or. (Empty ((cAliasSF3)->A1_INSCR) .And. (cAliasSF3)->A1_TIPO != "L" .And. Left ((cAliasSF3)->F3_CFO,1)>= "5")	//Nao Contribuinte
					lNaoContr := .T.
					nDebimpnc := (cAliasSF3)->F3_VALICM
			Else
					lNaoContr := .F.
					nDebCred	:= (cAliasSF3)->F3_VALICM
			Endif
		#ELSE
			If SA1->(DbSeek(xFilial('SA1')+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				If (AllTrim ((cAliasSF3)->F3_CFO)$"618/619/545/645/553/653/751/563/663") .Or.(AllTrim ((cAliasSF3)->F3_CFO)$"6107/6108/5258/6258/5307/6307/5357/6357") .Or.;
						("ISENT" $Upper(SA1->A1_INSCR) .And. Left ((cAliasSF3)->F3_CFO,1)>= "5") .Or. (Empty (SA1->A1_INSCR) .And. SA1->A1_TIPO != "L" .And. Left ((cAliasSF3)->F3_CFO,1)>= "5")	//Nao Contribuinte
						lNaoContr := .T.
						nDebimpnc := (cAliasSF3)->F3_VALICM
				Else
						lNaoContr := .F.
						nDebCred	:= (cAliasSF3)->F3_VALICM
				Endif
			EndIf		
		#ENDIF		

		dbSelectArea ("RTD")
		nDiferenc	:= 0
		IF ((cAliasSF3)->F3_BASEICM+(cAliasSF3)->F3_OUTRICM+(cAliasSF3)->F3_ICMSRET) > 0
			nDiferenc  := ((cAliasSF3)->F3_VALCONT) - ((cAliasSF3)->F3_BASEICM+(cAliasSF3)->F3_OUTRICM+(cAliasSF3)->F3_ICMSRET)
		EndIf
		cEntrSai := ""
		If Left((cAliasSF3)->F3_CFO,1) $ "123"
			cEntrSai := "0"
		Else
			cEntrSai := "1"
		Endif
				
		RTD->(dbSetOrder(1))
		                                             
		If !RTD->(DbSeek(LocalizaUF((cAliasSF3)->F3_ESTADO)+cEntrSai))
			RecLock("RTD",.T.)
			RTD->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
			RTD->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
			RTD->RETIFICA	:= Val(aCfp[2][07])
			RTD->ENTRSAIDA 	:= cEntrSai
			cNumUF := LocalizaUF((cAliasSF3)->F3_ESTADO)						
			RTD->CODUF 		:= Val(cNumUF)
			
			If Alltrim((cAliasSF3)->F3_CFO) $ cMvVlCtSt
				RTD->ICMSSUBST	:= (cAliasSF3)->F3_VALCONT	
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³O layout indica que as entradas sempre devem ser impressas no campo D7 (no caso RTD->BASECONTR)			³
				//³e nas saidas, apenas para contribuintes. O campo D8 possui os valores das saidas para nao contribuintes	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				If cEntrSai == "1" //Saida
					RTD->BASECONTR	:= Iif (lSimples,0,Iif(!lNaoContr,(cAliasSF3)->F3_BASEICM,0))
					RTD->BASENCONTR	:= Iif (lSimples,0,Iif(lNaoContr,(cAliasSF3)->F3_BASEICM,0))
				Else
					RTD->BASECONTR	:= Iif (lSimples,0,(cAliasSF3)->F3_BASEICM)
					RTD->BASENCONTR	:= 0
				Endif			 
				RTD->ISENTAS		:= Iif (lSimples,0,(cAliasSF3)->F3_ISENICM)
				RTD->OUTRAS		:= (cAliasSF3)->F3_OUTRICM + nDiferenc
				RTD->ICMSSUBST	:= (cAliasSF3)->F3_ICMSRET
				
				RTD->CREDDEB		:= Iif (lSimples,0,nDebCred)
				RTD->DEBIMPNC		:= Iif (lSimples,0,nDebimpnc)
			EndIf			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O layout indica que as entradas sempre devem ser impressas no campo D12 (no caso RTD->VLRCONTRIB)		³
			//³e nas saidas, apenas para contribuintes. O campo D13 possui os valores das saidas para nao contribuintes	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			If cEntrSai == "1" //Saida
				RTD->VLRCONTRIB	:= Iif (lSimples,0,Iif(!lNaoContr,(cAliasSF3)->F3_VALCONT,0))
				RTD->VLRNAOCONT	:= Iif (lSimples,0,Iif(lNaoContr,(cAliasSF3)->F3_VALCONT,0))
			Else
				RTD->VLRCONTRIB	:= Iif (lSimples,0,(cAliasSF3)->F3_VALCONT) // Verificar
				RTD->VLRNAOCONT	:= 0
			Endif			
			RTD->DOMICFISC  := cDomFis
		Else
			RecLock("RTD",.F.)
			If Alltrim((cAliasSF3)->F3_CFO) $ cMvVlCtSt
				RTD->ICMSSUBST	+= (cAliasSF3)->F3_VALCONT
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³O layout indica que as entradas sempre devem ser impressas no campo D7 (no caso RTD->BASECONTR)			³
				//³e nas saidas, apenas para contribuintes. O campo D8 possui os valores das saidas para nao contribuintes	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				If cEntrSai == "1" //Saida
					RTD->BASECONTR	+= Iif (lSimples,0,Iif(!lNaoContr,(cAliasSF3)->F3_BASEICM,0))
					RTD->BASENCONTR	+= Iif (lSimples,0,Iif(lNaoContr,(cAliasSF3)->F3_BASEICM,0))
				
				Else
					RTD->BASECONTR	+= Iif (lSimples,0,(cAliasSF3)->F3_BASEICM)
					RTD->BASENCONTR	+= 0
				Endif			                       
				RTD->ISENTAS		+= Iif (lSimples,0,(cAliasSF3)->F3_ISENICM)
				RTD->OUTRAS		+= (cAliasSF3)->F3_OUTRICM + nDiferenc
				RTD->ICMSSUBST	+= (cAliasSF3)->F3_ICMSRET
				RTD->CREDDEB		+= Iif (lSimples,0,nDebCred)
				RTD->DEBIMPNC		+= Iif (lSimples,0,nDebimpnc)
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O layout indica que as entradas sempre devem ser impressas no campo D12 (no caso RTD->VLRCONTRIB)		³
			//³e nas saidas, apenas para contribuintes. O campo D13 possui os valores das saidas para nao contribuintes	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			If cEntrSai == "1" //Saida
				RTD->VLRCONTRIB	+= Iif (lSimples,0,Iif(!lNaoContr,(cAliasSF3)->F3_VALCONT,0)) // Verificar
				RTD->VLRNAOCONT	+= Iif (lSimples,0,Iif(lNaoContr,(cAliasSF3)->F3_VALCONT,0))
			Else
				RTD->VLRCONTRIB	+= Iif (lSimples,0,(cAliasSF3)->F3_VALCONT) // Verificar
				RTD->VLRNAOCONT	+= 0
			Endif		    
		Endif
		nDebimpnc := nDebCred := 0
		MsUnlock()
		(cAliasSF3)->(dbSkip())
	Enddo
	
	If !lQuery
		RetIndex(cAliasSF3)
		dbClearFilter()
	Else
		DbSelectArea(cAliasSF3)
		DbCloseArea()
	Endif
	
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegE   ³ Autor ³Luciana P. Munhoz      ³ Data ³ 07.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo E - ICMS a Recolher                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegE(dDtInicial, dDtFinal, cDomFis)
	Local aICMRec 		:= {0,0,0,0}
	Local cApur1  		:= ""
	Local cApur2  		:= ""
	Local lSimples 		:= Iif(SuperGetMv("MV_SIMPLES")=="S",.T.,.F.)
	Local nx

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento da Apuracao                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cApur1 	:= FisApur("IC",Year(dDtInicial),Month(dDtFinal),2,0,"*",.F.,{},1,.T.,"NOD","")
	cApur2 	:= FisApur("ST",Year(dDtInicial),Month(dDtFinal),2,0,"*",.F.,{},1,.T.,"TST","")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acumula Valor da Apuracao                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If	(Alltrim(aCfp[3][01])=="Normal") .Or. (Alltrim(aCfp[3][01])=="Todos") .Or.;
		(Alltrim(aCfp[3][01])=="Diferencial de Alíquota") .Or. (Alltrim(aCfp[3][01])=="Complementação de Alíquota")
		DbSelectArea("NOD")
		DbGoTop()
		Do While ! NOD->(Eof())
			If (Alltrim(aCfp[3][01])=="Normal") .Or. (Alltrim(aCfp[3][01])=="Todos")
				aICMRec[01]	+= Iif(AllTrim(NOD->CODIGO) == "013",NOD->VALOR,0)
			Endif
			If (Alltrim(aCfp[3][01])=="Diferencial de Alíquota") .Or. (Alltrim(aCfp[3][01])=="Todos")
				aICMRec[02]	+= Iif(AllTrim(NOD->CODIGO) == "016",NOD->VALOR,0)
			Endif
			If (Alltrim(aCfp[3][01])=="Complementação de Alíquota") .Or. (Alltrim(aCfp[3][01])=="Todos") .and. lSimples
				aICMRec[04]	+= Iif(AllTrim(NOD->CODIGO) == "016",NOD->VALOR,0)
			Endif
			NOD->(dbSkip())
		Enddo
	Endif
	If (Alltrim(aCfp[3][01])=="Subst. Tributária") .Or. (Alltrim(aCfp[3][01])=="Todos")
		DbSelectArea("TST")
		DbGoTop()
		Do While ! TST->(Eof())
			aICMRec[03]	+= Iif(AllTrim(TST->CODIGO) == "015",TST->VALOR,0)
			TST->(dbSkip())
		Enddo
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento do Registo RTE                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nx:=1 to Len(aICMRec)
		If aICMRec[nx] > 0
			dbSelectArea("RTE")
			RecLock("RTE",.T.)
			             
			RTE->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
			RTE->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
			RTE->RETIFICA	:= Val(aCfp[2][07])
			RTE->TIPOICMS	:= Iif(nx==1,"N",Iif(nx==2,"D",Iif(nx==4,"C","S")))
			RTE->DTVENC		:= Iif(nx==1 .And. lSimples,"",Substr(aCfp[3][02],7,2) + Substr(aCfp[3][02],5,2) + Substr(aCfp[3][02],1,4))
			RTE->VLRICMS	:= Iif(nx==1 .And. lSimples,0,aICMRec[nx])
			MsUnlock()
		Endif
	Next

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegJ   ³ Autor ³Sueli C. Santos        ³ Data ³ 12.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo J - Informações sobre TARE            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegJ(dDtInicial, dDtFinal, cDomFis)

	RecLock("RTJ",.T.)
	RTJ->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
	RTJ->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
	RTJ->RETIFICA	:= Val(aCfp[2][07])
	RTJ->NTARE    	:= Replicate("0",20-Len(AllTrim(aCfp[1][03]))) + AllTrim(aCfp[1][03])
	RTJ->DTVENCTO 	:= Substr(aCfp[1][04],7,2) + Substr(aCfp[1][04],5,2) + Substr(aCfp[1][04],1,4)
	MsUnLock()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegK   ³ Autor ³Sueli C. Santos        ³ Data ³ 12.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo K - Especificação de Outros Creditos  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegK(dDtInicial, dDtFinal, cDomFis)
Local aOutCred  :={}
Local nI 		:= 0
Local lSimples 	:= Iif(SuperGetMv("MV_SIMPLES")=="S",.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento da Apuracao                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aOutCred := FisApur("IC",Year(dDtInicial),Month(dDtFinal),2,0,"*",.F.,{},1,.T.,"","")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acumula Valor da Apuracao                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lSimples
	For nI := 1 To Len(aOutCred)
		If aOutCred[nI,1] == "006" 	.And. !(aOutCred[nI,4]== "006.00")
			If !RTK->(Dbseek(Substr(Alltrim(aOutCred[nI,4]),5,2)))
				RecLock("RTK",.T.)
				RTK->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
				RTK->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
				RTK->RETIFICA	:= Val(aCfp[2][07])
				RTK->CODBASE	:= Substr(Alltrim(aOutCred[nI,4]),5,2)
				RTK->VLRCRED	:= aOutCred[nI,3]
			Else
				RecLock("RTK",.F.)
				RTK->VLRCRED	+= aOutCred[nI,3]
			Endif
			RTK->(MsUnLock())
		EndIf
	Next
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegR   ³ Autor ³Natalia Antonucci      ³ Data ³ 22.10.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo R - Especificação de Outros Debitos   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegR(dDtInicial, dDtFinal, cDomFis)
Local aOutDebi :={}
Local nI       := 0
Local lSimples := Iif(SuperGetMv("MV_SIMPLES")=="S",.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento da Apuracao                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aOutDebi := FisApur("IC",Year(dDtInicial),Month(dDtFinal),2,0,"*",.F.,{},1,.T.,"","")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acumula Valor da Apuracao                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !lSimples
	For nI := 1 To Len(aOutDebi)
		If aOutDebi[nI,1] == "002" 	.And. !(aOutDebi[nI,4]== "002.00")
			If !RTR->(Dbseek(Substr(Alltrim(aOutDebi[nI,4]),5,2)))
				RecLock("RTR",.T.)
				RTR->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
				RTR->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
				RTR->RETIFICA	:= Val(aCfp[2][07])
				RTR->CODBASE	:= Substr(Alltrim(aOutDebi[nI,4]),5,2)
				RTR->VLRDEBI	:= aOutDebi[nI,3]
			Else
				RecLock("RTR",.F.)
				RTR->VLRDEBI	+= aOutDebi[nI,3]
			Endif
			RTR->(MsUnLock())
		EndIf
	Next
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegL   ³ Autor ³Sueli C. Santos        ³ Data ³ 12.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo L - Especificação das Deducoes        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegL(dDtInicial, dDtFinal, cDomFis)
Local aDed     :={}
Local nI       := 0
Local lSimples := Iif(SuperGetMv("MV_SIMPLES")=="S",.T.,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento da Apuracao                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aDed := FisApur("IC",Year(dDtInicial),Month(dDtFinal),2,0,"*",.F.,{},1,.T.,"","")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acumula Valor da Apuracao                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lSimples
	For nI := 1 To Len(aDed)
		If aDed[nI,1] == "012" 	.And. !(aDed[nI,4]== "012.00")
			If !RTL->(Dbseek(Substr(Alltrim(aDed[nI,4]),5,2)))
				RecLock("RTL",.T.)
				RTL->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
				RTL->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
				RTL->RETIFICA	:= Val(aCfp[2][07])
				RTL->CODBASE	:= Substr(Alltrim(aDed[nI,4]),5,2)
				RTL->VLRDED	:= aDed[nI,3]
			Else
				RecLock("RTL",.F.)
				RTL->VLRDED	+= aDed[nI,3]
			Endif
			RTK->(MsUnLock())
		EndIf
	Next
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegM   ³ Autor ³Roberto Souza          ³ Data ³ 14.04.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo M                                     ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegM(dDtInicial, dDtFinal, cDomFis)

Default cDomFis := "A"

If Substr(aCfp[3][03],1,1) <> "S"  
	Return Nil
EndIf

//Processa Saidas para Registro M
ProcSaiM(dDtInicial, dDtFinal,cDomFis )

//Processa Entradas para Registro M
ProcEntM(dDtInicial, dDtFinal,cDomFis )

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |ProcSaiM   ³ Autor ³Roberto Souza          ³ Data ³ 14.04.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa movimentos de Saídas do Registro Tipo M             ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcSaiM(dDtInicial, dDtFinal, cDomFis )

Local lQuery 	:= .F.
Local nVlEnt 	:= 0
Local nVlSai 	:= 0

#IFDEF TOP
	Local cAliasM   := ""
	Local cQuery 	:= ""
#ELSE
	Local cIndSF3	:= ""
	Local cChave	:= ""
	Local cFiltro	:= ""
#ENDIF

#IFDEF TOP
	If TcSrvType()<>"AS/400"
		lQuery := .T.
		cAliasM:= GetNextAlias()
		cQuery += " SELECT "
		cQuery += " SF3.F3_FILIAL,SF3.F3_ENTRADA,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR"
		cQuery += " ,SF3.F3_LOJA,SF3.F3_CFO,SF3.F3_ESTADO,SF3.F3_EMISSAO,SF3.F3_VALCONT"
		cQuery += " ,SF3.F3_BASEICM,SF3.F3_VALICM,SF3.F3_ISENICM,SF3.F3_OUTRICM,SF3.F3_BASEIPI"
		cQuery += " ,SF3.F3_VALIPI,SF3.F3_ISENIPI,SF3.F3_OUTRIPI,SF3.F3_ICMSRET,SF3.F3_TIPO"
		cQuery += " ,SF3.F3_ICMSCOM,SF3.F3_ESPECIE,SF3.F3_DTLANC,SF3.F3_DTCANC,SF3.F3_ICMSDIF"
		cQuery += " ,SF3.F3_ECF"
		cQuery += " FROM "
		cQuery += RetSqlName("SF3") + " SF3"
		cQuery += " WHERE "
		cQuery += " SF3.F3_FILIAL = '" + xFilial("SF3") + "' AND "
		cQuery += " SF3.F3_ENTRADA >= '" + Dtos(dDtInicial) + "' AND "
		cQuery += " SF3.F3_ENTRADA <= '" + Dtos(dDtFinal) + "' AND "
		cQuery += " SUBSTRING(SF3.F3_CFO,1,1) = '5' AND " //Somente saidas internas
		cQuery += " LTRIM(RTRIM(SF3.F3_CFO)) NOT IN ('5360','5601','5602','5603','5605','5606','5650','5654','5667','5922'," // Excluindo as saidas internas que os CFOPs
		cQuery += " '5926','5927','5928','5929','5931','5932','5933','5934') AND " // não constam na lista da consulta realizada na secretaria da fazenda de tocantins - Chamado: TUZJEL
		cQuery += " SF3.F3_DTCANC ='' AND "
		cQuery += " SF3.D_E_L_E_T_=''"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasM,.T.,.T.)
		DbSelectArea(cAliasM)
	Else
#ELSE
		dbSelectArea("SF3")
		cIndSF3 := CriaTrab(NIL,.F.)
		cChave  := IndexKey()
		cFiltro := "F3_FILIAL=='"+xFilial("SF3")+"' .And. DTOS(F3_ENTRADA)>='"+Dtos(dDtInicial)+"' .AND. DTOS(F3_ENTRADA)<='"+Dtos(dDtFinal)+"'"
		cFiltro += " .And. DTOS(F3_DTCANC)=='"+Dtos(Ctod(""))+"'"
		cFiltro += " .And. SUBSTR(F3_CFO,1,1) == '5'"	//Somente saidas internas
		cFiltro += " .And. !(Alltrim(F3_CFO) $ '5360/5601/5602/5603/5605/5606/5650/5654/5667/5922/" // Excluindo as saidas internas que os CFOPs
		cFiltro += "5926/5927/5928/5929/5931/5932/5933/5934')" // não constam na lista da consulta realizada na secretaria da fazenda de tocantins - Chamado: TUZJEL
		IndRegua("SF3",cIndSF3,cChave,,cFiltro)
		SF3->(DbgoTop())
#ENDIF

#IFDEF TOP
	Endif
	Do While ! (cAliasM)->(Eof())
		nVlSai += (cAliasM)->F3_VALCONT
		(cAliasM)->(dbSkip())
	EndDo
	DbSelectArea("RTM")
	RecLock("RTM",.T.)
	RTM->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
	RTM->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
	RTM->RETIFICA	:= Val(aCfp[2][07])
	RTM->CODMUNORI  := Val(aFisFill(SM0->M0_CODMUN,7))
	RTM->DOMICFISC  := cDomFis
	RTM->SAIDAS		:= nVlSai
	RTM->ENTRADAS	:= nVlEnt
	MsUnlock()
#ELSE
	Do While ! SF3->(Eof())
		nVlSai += SF3->F3_VALCONT
		SF3->(dbSkip())
	EndDo
	DbSelectArea("RTM")
	RecLock("RTM",.T.)
	RTM->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
	RTM->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
	RTM->RETIFICA	:= Val(aCfp[2][07])
	RTM->CODMUNORI  := Val(aFisFill(SM0->M0_CODMUN,7))
	RTM->DOMICFISC  := cDomFis
	RTM->SAIDAS		:= nVlSai
	RTM->ENTRADAS	:= nVlEnt
	MsUnlock()
#ENDIF
	//Exclui area de trabalho utilizada - SF3
	If !lQuery
		RetIndex("SF3")
		dbClearFilter()
		Ferase(cIndSF3+OrdBagExt())
	Else
		dbSelectArea(cAliasM)
		dbCloseArea()
	Endif
Return Nil



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |ProcEntM   ³ Autor ³Roberto Souza          ³ Data ³ 14.04.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa movimentos de Entradas do Registro Tipo M           ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function ProcEntM(dDtInicial, dDtFinal, cDomFis )

local cCodMun := ''
local lQuery  := .F.
local nVlEnt  := 0
local nVlSai  := 0

#IFDEF TOP
	local cAliasM := ""
	local cQuery  := ""
#ELSE
	local cIndSF3 := ""
	local cChave  := ""
	local cFiltro := ""
#ENDIF

#IFDEF TOP

	if TcSrvType()<>"AS/400"
		lQuery  := .T.
		cAliasM := GetNextAlias()
		cQuery += " SELECT DISTINCT"
		cQuery += " SF3.F3_FILIAL,SF3.F3_ENTRADA,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR
		cQuery += " ,SF3.F3_LOJA,SF3.F3_CFO,SF3.F3_ESTADO,SF3.F3_EMISSAO,SF3.F3_VALCONT"
		cQuery += " ,SF3.F3_BASEICM,SF3.F3_VALICM,SF3.F3_ISENICM,SF3.F3_OUTRICM,SF3.F3_BASEIPI"
		cQuery += " ,SF3.F3_VALIPI,SF3.F3_ISENIPI,SF3.F3_OUTRIPI,SF3.F3_ICMSRET,SF3.F3_TIPO"
		cQuery += " ,SF3.F3_ICMSCOM,SF3.F3_ESPECIE,SF3.F3_DTLANC,SF3.F3_DTCANC,SF3.F3_ICMSDIF"
		cQuery += " ,SF3.F3_ECF"
		cQuery += " FROM "
		cQuery += RetSqlName("SF3") + " SF3,"
		cQuery += " WHERE "
		cQuery += " SF3.F3_FILIAL = '" + xFilial("SF3") + "' AND "
		cQuery += " SF3.F3_ENTRADA >= '" + Dtos(dDtInicial) + "' AND "
		cQuery += " SF3.F3_ENTRADA <= '" + Dtos(dDtFinal) + "' AND "
		cQuery += " SUBSTRING(SF3.F3_CFO,1,1) IN ('1','2','3') AND " // Somente entradas
		cQuery += " LTRIM(RTRIM(SF3.F3_CFO)) NOT IN ('1251','1252','1253','1254','1255','1256','1257','1302','1303','1304','1305','1306'," // Excluindo as saidas internas
		cQuery += "'1352','1353','1354','1355','1356','1360','1601','1602','1603','1604','1605','1931'," // que os CFOPs não constam na lista da consulta
		cQuery += "'1932','1933','1934','2204','2252','2253','2254','2255','2256','2257','2302','2303'," // realizada na secretaria da fazenda de tocantins
		cQuery += "'2304','2305','2306','2352','2353','2354','2355','2356','2603','2922','2931','2932'," // - Chamado: TUZJEL
		cQuery += "'2933','2934','3352','3353','3354','3355','3356') AND "
		cQuery += " SF3.F3_DTCANC ='' AND "
		cQuery += " SF3.F3_TIPO <>'S' AND "
		cQuery += " SF3.D_E_L_E_T_='' "
		cQuery += " ORDER BY F3_CLIEFOR, F3_LOJA"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasM,.T.,.T.)
		DbSelectArea(cAliasM)
	Else
#ELSE
		dbSelectArea("SF3")
		cIndSF3 := CriaTrab(NIL,.F.)
		cChave  := IndexKey()
		cFiltro := "F3_FILIAL=='"+xFilial("SF3")+"' .And. DTOS(F3_ENTRADA)>='"+Dtos(dDtInicial)+"' .AND. DTOS(F3_ENTRADA)<='"+Dtos(dDtFinal)+"'"
		cFiltro += " .And. DTOS(F3_DTCANC)=='"+Dtos(Ctod(""))+"'"
		cFiltro += " .And. SUBSTR(F3_CFO,1,1) $ '1/2/3/'"
		cFiltro += " .And. !(Alltrim(F3_CFO) $ '1251/1252/1253/1254/1255/1256/1257/1302/1303/1304/1305/1306/1352/1353/1354/1355/1356/" // Excluindo as saidas internas
		cFiltro += "1360/1601/1602/1603/1604/1605/1931/1932/1933/1934/2204/2252/2253/2254/2255/2256/2257/2302/2303/2304/2305/2306/2352/2353/" // que os CFOPs não constam na lista da consulta
		cFiltro += "2354/2355/2356/2603/2922/2931/2932/2933/2934/3352/3353/3354/3355/3356')" // realizada na secretaria da fazenda de tocantins - Chamado: TUZJEL
		IndRegua("SF3",cIndSF3,cChave,,cFiltro)
		SF3->(DbgoTop())
#ENDIF

#IFDEF TOP
	Endif

	SA1->(DbSetOrder(1))
	SA2->(DbSetOrder(1))
	
	
	do while ! (cAliasM)->(Eof())

		//Tratamento para atender issue DSERFIS1-2305 (conforme consultoria Tributária)
		if substr(F3_CFO,1,1) == '1'
			If (cAliasM)->F3_TIPO $ "DB"
				IF (SA1->(dbSeek(xFilial("SA1")+(cAliasM)->F3_CLIEFOR+(cAliasM)->F3_LOJA)))
					cCodMun := SA1->A1_COD_MUN
				EndIf
			Else
				IF (SA2->(dbSeek(xFilial("SA2")+(cAliasM)->F3_CLIEFOR+(cAliasM)->F3_LOJA)))
					cCodMun := SA2->A2_COD_MUN
				EndIf 
			Endif
		else
			cCodMun := SubStr(SM0->M0_CODMUN,3,5)		
		endif

		nVlEnt := 0
		nVlSai := 0

		DbSelectArea("RTM")
		If !RTM->(Dbseek(Val("17"+cCodMun)))
			RecLock("RTM",.T.)
			RTM->INSCRICAO  := Val(aFisFill(SM0->M0_INSC,9))
			RTM->PERIODOREF := StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
			RTM->RETIFICA   := Val(aCfp[2][07])
			RTM->CODMUNORI  := val("17"+cCodMun)
			RTM->DOMICFISC  := cDomFis
			RTM->SAIDAS     := nVlSai
			RTM->ENTRADAS   := (cAliasM)->F3_VALCONT
		Else
			RecLock("RTM",.F.)
			RTM->ENTRADAS   +=  (cAliasM)->F3_VALCONT
		EndIf
		RTM->(MsUnlock())
		(cAliasM)->(DbSkip())
	EndDo

#ELSE
	Do While ! SF3->(Eof())
		if substr(F3_CFO,1,1) == '1'
			If SF3->F3_TIPO $ "DB"
				cCodMun:= Posicione('SA1',1,xFilial('SA1')+SF3->F3_CLIEFOR+SF3->F3_LOJA,'A1_COD_MUN')
			Else
				cCodMun:= Posicione('SA2',1,xFilial('SA2')+SF3->F3_CLIEFOR+SF3->F3_LOJA,'A2_COD_MUN')
			Endif
		else
			cCodMun := SubStr(SM0->M0_CODMUN,3,5)	
		endif

		nVlEnt := SF3->F3_VALCONT
		nVlSai := 0

		DbSelectArea("RTM")
		If !RTM->(Dbseek(Val("17"+cCodMun)))
			RecLock("RTM",.T.)
			RTM->INSCRICAO  := Val(aFisFill(SM0->M0_INSC,9))
			RTM->PERIODOREF := StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
			RTM->RETIFICA   := Val(aCfp[2][07])
			RTM->CODMUNORI  := val("17"+cCodMun)
			RTM->DOMICFISC  := cDomFis
			RTM->SAIDAS     := nVlSai
			RTM->ENTRADAS   := nVlEnt
		Else
			RecLock("RTM",.F.)
			RTM->ENTRADAS   += nVlEnt
		EndIf
		RTM->(MsUnlock())
		SF3->(dbSkip())
	EndDo
#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SF3")
		dbClearFilter()
		Ferase(cIndSF3+OrdBagExt())
	Else
		dbSelectArea(cAliasM)
		dbCloseArea()
	Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegN   ³ Autor ³Roberto Souza          ³ Data ³ 14.04.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo N                                     ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegN(dDtInicial, dDtFinal, cDomFis)

Local cAliasN  := ""
Local lQuery   := .F.
Local cQuery   := ""
Local nVlEnt   := 0
Local cCodEmp  := ""
Local cCpoCCI  := GetNewPar("MV_CCI_TO","")
Local cAliasSF3:="SF3"

#IFDEF TOP
	If TcSrvType()<>"AS/400"
		lQuery 	:= .T.
		cAliasN	:= GetNextAlias()
		cQuery += " SELECT DISTINCT"
		cQuery += " SF3.F3_FILIAL,SF3.F3_ENTRADA,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR
		cQuery += " ,SF3.F3_LOJA,SF3.F3_CFO,SF3.F3_ESTADO,SF3.F3_EMISSAO,SF3.F3_VALCONT"
		cQuery += " ,SF3.F3_BASEICM,SF3.F3_VALICM,SF3.F3_ISENICM,SF3.F3_OUTRICM,SF3.F3_BASEIPI"
		cQuery += " ,SF3.F3_VALIPI,SF3.F3_ISENIPI,SF3.F3_OUTRIPI,SF3.F3_ICMSRET,SF3.F3_TIPO"
		cQuery += " ,SF3.F3_ICMSCOM,SF3.F3_ESPECIE,SF3.F3_DTLANC,SF3.F3_DTCANC,SF3.F3_ICMSDIF"
		cQuery += " ,SF3.F3_ECF"
		cQuery += " ,SA2.A2_FILIAL,SA2.A2_COD,SA2.A2_LOJA,SA2.A2_COD_MUN,SA2.A2_EST,SA2.A2_INSCR "
		If !Empty(cCpoCCI) .And. SA2->(FieldPos(cCpoCCI))<>0
			cQuery += " ,"+cCpoCCI+ " AS A2_CCI"
		Else
			cQuery += " , '' AS A2_CCI"
		EndIf
		cQuery += " FROM "
		cQuery += RetSqlName("SF3") + " SF3,"
		cQuery += RetSqlName("SA2") + " SA2 "
		cQuery += " WHERE "
		cQuery += " SF3.F3_FILIAL = '" + xFilial("SF3") + "' AND "
		cQuery += " SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND "
		cQuery += " SF3.F3_ENTRADA >= '" + Dtos(dDtInicial) + "' AND "
		cQuery += " SF3.F3_ENTRADA <= '" + Dtos(dDtFinal) + "' AND "
		cQuery += " SF3.F3_ICMSDIF >0 AND " //ICMS Diferido
		cQuery += " SUBSTRING(SF3.F3_CFO,1,1) IN ('1','2','3','4') AND "
		cQuery += " SF3.F3_CLIEFOR = SA2.A2_COD AND SF3.F3_LOJA = SA2.A2_LOJA AND"
		cQuery += " SF3.F3_DTCANC ='' AND "
		cQuery += " SA2.A2_EST ='TO' AND " // Somente para domiciliados em Tocantins
		cQuery += " SF3.D_E_L_E_T_='' AND "
		cQuery += " SA2.D_E_L_E_T_=''"
		cQuery += " ORDER BY A2_COD, A2_LOJA"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasN,.T.,.T.)
		DbSelectArea(cAliasN)
	Else
#ELSE
		dbSelectArea(cAliasSF3)
		cIndSF3 := CriaTrab(NIL,.F.)
		cChave  := IndexKey()
		cFiltro := "F3_FILIAL=='"+xFilial("SF3")+"' .And. DTOS(F3_ENTRADA)>='"+Dtos(dDtInicial)+"' .AND. DTOS(F3_ENTRADA)<='"+Dtos(dDtFinal)+"'"
		cFiltro += " .And. DTOS(F3_DTCANC)=='"+Dtos(Ctod(""))+"'"
		cFiltro += " .And. SUBSTR(F3_CFO,1,1) $ '1/2/3/4/'"
		cFiltro += " .And. F3_ICMSDIF >0 "
		IndRegua(cAliasSF3,cIndSF3,cChave,,cFiltro)
		dbSelectArea(cAliasSF3)
		ProcRegua(LastRec())
		dbGoTop()
		RetIndex("SF3")
#ENDIF

#IFDEF TOP
	Endif

	Do While ! (cAliasN)->(Eof())
		cCodEmp := (cAliasN)->A2_COD
		cLojEmp := (cAliasN)->A2_LOJA
		nVlEnt  := 0
		cCodMun := (cAliasN)->A2_COD_MUN
		cCCITO  := (cAliasN)->A2_CCI
		Do While (cAliasN)->A2_COD == cCodEmp .And. (cAliasN)->A2_LOJA == cLojEmp .And. ! (cAliasN)->(Eof())
			nVlEnt += (cAliasN)->F3_VALCONT
			(cAliasN)->(dbSkip())
		EndDo

		DbSelectArea("RTN")
		RecLock("RTN",.T.)
		RTN->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
		RTN->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
		RTN->RETIFICA	:= Val(aCfp[2][07])
		RTN->IDEMPCCI   := cCCITO
		RTN->DOMICFISC  := cDomFis
		RTN->CODMUNORI	:= Val("17"+cCodMun)
		RTN->TOTNFEMP	:= nVlEnt
		RTN->(MsUnlock())
	EndDo

#ELSE
	
	DbSelectArea("SF3")
	DbSetOrder(4)
	Do While ! SF3->(Eof())

		cCodEmp := SF3->F3_CLIEFOR
		cLojaEmp:= SF3->F3_LOJA
		nVlEnt  := 0
		cCodMun := Posicione('SA2',1,xFilial('SA2')+SF3->F3_CLIEFOR+SF3->F3_LOJA,'A2_COD_MUN')
		cCodCCi := Posicione('SA2',1,xFilial('SA2')+SF3->F3_CLIEFOR+SF3->F3_LOJA,cCpoCCI)

		Do While SF3->F3_CLIEFOR == cCodEmp .And. SF3->F3_LOJA == cLojaEmp .And. ! SF3->(Eof())
			nVlEnt += SF3->F3_VALCONT
			SF3->(dbSkip())
		EndDo

		DbSelectArea("RTN")

		RecLock("RTN",.T.)
		RTN->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
		RTN->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
		RTN->RETIFICA	:= Val(aCfp[2][07])
		RTN->IDEMPCCI   := cCodCCi
		RTN->DOMICFISC  := cDomFis
		RTN->CODMUNORI	:= Val("17"+cCodMun)
		RTN->TOTNFEMP	:= nVlEnt
		RTN->(MsUnlock())
	EndDo
#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SF3")
		dbClearFilter()
		Ferase(cIndSF3+OrdBagExt())
	Else
		dbSelectArea(cAliasN)
		dbCloseArea()
	Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegO   ³ Autor ³Roberto Souza          ³ Data ³ 14.04.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo O                                     ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegO(dDtInicial, dDtFinal, cDomFis)

Local cAliasO   := ""
Local lQuery 	:= .F.
Local cQuery 	:= ""
Local nVlEnt 	:= 0
Local cCodEmp   := ""
Local cCpoCCI   := GetNewPar("MV_CCI_TO","")

#IFDEF TOP

	If TcSrvType()<>"AS/400"
		lQuery := .T.
		cAliasO:= GetNextAlias()
		cQuery += " SELECT DISTINCT"
		cQuery += " SF3.F3_FILIAL,SF3.F3_ENTRADA,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR
		cQuery += " ,SF3.F3_LOJA,SF3.F3_CFO,SF3.F3_ESTADO,SF3.F3_EMISSAO,SF3.F3_VALCONT"
		cQuery += " ,SF3.F3_BASEICM,SF3.F3_VALICM,SF3.F3_ISENICM,SF3.F3_OUTRICM,SF3.F3_BASEIPI"
		cQuery += " ,SF3.F3_VALIPI,SF3.F3_ISENIPI,SF3.F3_OUTRIPI,SF3.F3_ICMSRET,SF3.F3_TIPO"
		cQuery += " ,SF3.F3_ICMSCOM,SF3.F3_ESPECIE,SF3.F3_DTLANC,SF3.F3_DTCANC,SF3.F3_ICMSDIF"
		cQuery += " ,SF3.F3_ECF"
		cQuery += " ,SA2.A2_FILIAL,SA2.A2_COD,SA2.A2_LOJA,SA2.A2_COD_MUN,SA2.A2_EST,SA2.A2_INSCR "
		If !Empty(cCpoCCI) .And. SA2->(FieldPos(cCpoCCI))<>0
			cQuery += " ,"+cCpoCCI+ " AS A2_CCI"
		Else
			cQuery += " , '' AS A2_CCI"
		EndIf
		cQuery += " FROM "
		cQuery += RetSqlName("SF3") + " SF3,"
		cQuery += RetSqlName("SA2") + " SA2 "
		cQuery += " WHERE "
		cQuery += " SF3.F3_FILIAL = '" + xFilial("SF3") + "' AND "
		cQuery += " SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND "
		cQuery += " SF3.F3_ENTRADA >= '" + Dtos(dDtInicial) + "' AND "
		cQuery += " SF3.F3_ENTRADA <= '" + Dtos(dDtFinal) + "' AND "
		cQuery += " SF3.F3_ICMSDIF >0 AND " //ICMS Diferido
		cQuery += " SUBSTRING(SF3.F3_CFO,1,1) IN ('1','2','3','4') AND "
		cQuery += " SF3.F3_CLIEFOR = SA2.A2_COD AND SF3.F3_LOJA = SA2.A2_LOJA AND"
		cQuery += " SF3.F3_DTCANC ='' AND "
		cQuery += " SA2.A2_EST ='TO' AND " // Somente para domiciliados em Tocantins
		cQuery += " SF3.D_E_L_E_T_='' AND "
		cQuery += " SA2.D_E_L_E_T_=''"
		cQuery += " ORDER BY A2_COD, A2_LOJA"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasO,.T.,.T.)
		DbSelectArea(cAliasO)
	Else
#ELSE
		dbSelectArea("SF3")
		cIndSF3 := CriaTrab(NIL,.F.)
		cChave  := IndexKey()
		cFiltro := "F3_FILIAL=='"+xFilial("SF3")+"' .And. DTOS(F3_ENTRADA)>='"+Dtos(dDtInicial)+"' .AND. DTOS(F3_ENTRADA)<='"+Dtos(dDtFinal)+"'"
		cFiltro += " .And. DTOS(F3_DTCANC)=='"+Dtos(Ctod(""))+"'"
		cFiltro += " .And. SUBSTR(F3_CFO,1,1) $ '1/2/3/4/'"
		cFiltro += " .And. F3_ICMSDIF >0 "
		IndRegua("SF3",cIndSF3,cChave,,cFiltro)
		DbgoTop()
		RetIndex("SF3")
#ENDIF

#IFDEF TOP
	Endif

	Do While ! (cAliasO)->(Eof())
		cCodEmp := (cAliasO)->A2_COD
		nVlEnt += (cAliasO)->F3_VALCONT
		cCodMun := (cAliasO)->A2_COD_MUN

		DbSelectArea("RTO")
		RecLock("RTO",.T.)
		RTO->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
		RTO->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
		RTO->RETIFICA	:= Val(aCfp[2][07])
		RTO->IDEMPCCI   := (cAliasO)->A2_CCI
		RTO->DOMICFISC  := cDomFis
		RTO->NUMNOTA	:= Val(Right((cAliasO)->F3_NFISCAL,7))
		RTO->VALNOTA	:= nVlEnt
		RTO->(MsUnlock())
		(cAliasO)->(dbSkip())
	EndDo

#ELSE
	DbSelectArea("SF3")
	DbSetOrder(4)
	Do While ! SF3->(Eof())

		cCodEmp := SF3->F3_CLIEFOR
		cLojaEmp:= SF3->F3_LOJA
		nVlEnt  := SF3->F3_VALCONT
		nNota   := Val(Right(F3_NFISCAL,7))
		cCodMun := Posicione('SA2',1,xFilial('SA2')+SF3->F3_CLIEFOR+SF3->F3_LOJA,'A2_COD_MUN')
		cCodCCi := Posicione('SA2',1,xFilial('SA2')+SF3->F3_CLIEFOR+SF3->F3_LOJA,cCpoCCI)

		DbSelectArea("RTO")
		RecLock("RTO",.T.)
		RTO->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
		RTO->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
		RTO->RETIFICA	:= Val(aCfp[2][07])
		RTO->IDEMPCCI   := cCodCCi
		RTO->DOMICFISC  := cDomFis
		RTO->NUMNOTA	:= nNota
		RTO->VALNOTA	:= nVlEnt

		RTO->(MsUnlock())
		
		DbSelectArea("SF3")
		dbSkip()
		
	EndDo

#ENDIF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SF3")
		dbClearFilter()
		Ferase(cIndSF3+OrdBagExt())
	Else
		dbSelectArea(cAliasO)
		dbCloseArea()
	Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegP   ³ Autor ³Roberto Souza          ³ Data ³ 14.04.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo P                                     ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegP(dDtInicial, dDtFinal, cDomFis)

Local cAliasP := ""
Local lQuery  := .F.
Local cCodEmp := ""
Local cCodEst := ""
Local cCodUf  := ""
Local nVlBas  := 0
Local nVlDif  := 0

#IFDEF TOP
	If TcSrvType()<>"AS/400"
		lQuery := .T.
		cAliasP:= GetNextAlias()
		BeginSql Alias cAliasP
			SELECT DISTINCT
				SF3.F3_FILIAL,SF3.F3_ENTRADA,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR,
				SF3.F3_LOJA,SF3.F3_CFO,SF3.F3_ESTADO,SF3.F3_EMISSAO,SF3.F3_VALCONT,
				SF3.F3_BASEICM,SF3.F3_VALICM,SF3.F3_ISENICM,SF3.F3_OUTRICM,SF3.F3_BASEIPI,
				SF3.F3_VALIPI,SF3.F3_ISENIPI,SF3.F3_OUTRIPI,SF3.F3_ICMSRET,SF3.F3_TIPO,
				SF3.F3_ICMSCOM,SF3.F3_ESPECIE,SF3.F3_DTLANC,SF3.F3_DTCANC,SF3.F3_ICMSDIF,
				SF3.F3_ECF,SD1.D1_PICM,
				SA2.A2_FILIAL,SA2.A2_COD,SA2.A2_LOJA,SA2.A2_COD_MUN,SA2.A2_EST,SA2.A2_INSCR
			FROM %table:SF3% SF3, %table:SD1% SD1, %table:SA2% SA2
			WHERE
				SF3.F3_FILIAL = %xfilial:SF3% AND
				SF3.F3_ENTRADA >= %Exp:dDtInicial% AND
				SF3.F3_ENTRADA <= %Exp:dDtFinal% AND
				SF3.F3_ICMSCOM >0 AND //Diferencial de aliquota de ICMS
				SUBSTRING(SF3.F3_CFO,1,1) IN ('1','2','3','4') AND
				SF3.F3_DTCANC ='' AND
				SF3.%notDel% AND
				SD1.D1_FILIAL = %xfilial:SD1% AND 
				SD1.D1_DOC = SF3.F3_NFISCAL AND
				SD1.D1_SERIE = SF3.F3_SERIE AND
				SD1.D1_FORNECE = SF3.F3_CLIEFOR AND
				SD1.D1_LOJA = SF3.F3_LOJA AND
				SD1.%notDel% AND 
				SA2.A2_FILIAL = %xfilial:SA2% AND
				SF3.F3_CLIEFOR = SA2.A2_COD AND SF3.F3_LOJA = SA2.A2_LOJA AND
				SA2.A2_EST <> 'TO' AND // Somente para domiciliados fora de Tocantins
				SA2.%notDel%
			ORDER BY A2_EST, A2_COD, A2_LOJA"
		EndSql
		DbSelectArea(cAliasP)
#ELSE
		dbSelectArea("SF3")
		cIndSF3 := CriaTrab(NIL,.F.)
		cChave  := IndexKey()
		cFiltro := "F3_FILIAL=='"+xFilial("SF3")+"' .And. DTOS(F3_ENTRADA)>='"+Dtos(dDtInicial)+"' .AND. DTOS(F3_ENTRADA)<='"+Dtos(dDtFinal)+"'"
		cFiltro += " .And. DTOS(F3_DTCANC)=='"+Dtos(Ctod(""))+"'"
		cFiltro += " .And. SUBSTR(F3_CFO,1,1) $ '1/2/3/4/'"
		cFiltro += " .And. F3_ICMSCOM >0 "
		IndRegua("SF3",cIndSF3,cChave,,cFiltro)
		SF3->(DbgoTop())
#ENDIF

#IFDEF TOP
	Endif

	Do While ! (cAliasP)->(Eof())
		cCodEmp := (cAliasP)->A2_COD
		nVlBas  := (cAliasP)->F3_BASEICM
		cCodMun := (cAliasP)->A2_COD_MUN
		cCodEst := (cAliasP)->A2_EST
		nVlCont := (cAliasP)->F3_VALCONT
		nVlDif  := (cAliasP)->F3_ICMSCOM
		cCodUf  := LocalizaUF(cCodEst)
		DbSelectArea("RTP")
		If ! RTP->(DbSeek(cCodUf))
			RecLock("RTP",.T.)
		Else
			RecLock("RTP",.F.)
		EndIf
		RTP->INSCRICAO  := Val(aFisFill(SM0->M0_INSC,9))
		RTP->PERIODOREF := StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
		RTP->RETIFICA   := Val(aCfp[2][07])
		RTP->DOMICFISC  := cDomFis
		RTP->CODUF      := cCodUf
		RTP->VALCONT    += nVlCont
		RTP->BASECALC   += nVlBas
		RTP->DIFALIQ    += nVlDif
		RTP->ALIQUOTA   := (cAliasP)->D1_PICM
		RTP->(MsUnlock())
		(cAliasP)->(dbSkip())
	EndDo
#ELSE
	Do While ! SF3->(Eof())
		cCodEmp := SF3->F3_CLIEFOR
		nVlBas  := SF3->F3_BASEICM
		cCodEst := Posicione('SA2',1,xFilial('SA2')+SF3->(F3_CLIEFOR+F3_LOJA),'A2_EST')
		nVlDif  := SF3->F3_ICMSCOM
		nVlCont := SF3->F3_VALCONT
		cCodUf  := LocalizaUF(cCodEst)
		DbSelectArea("RTP")
		If ! RTP->(DbSeek(cCodUf))
			RecLock("RTP",.T.)
		Else
			RecLock("RTP",.F.)
		EndIf
		RTP->INSCRICAO  := Val(aFisFill(SM0->M0_INSC,9))
		RTP->PERIODOREF := StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
		RTP->RETIFICA   := Val(aCfp[2][07])
		RTP->DOMICFISC  := cDomFis
		RTP->CODUF      := cCodUf
		RTP->VALCONT    += nVlCont
		RTP->BASECALC   += nVlBas
		RTP->DIFALIQ    += nVlDif
		RTP->ALIQUOTA   := Posicione('SD1',1,xFilial('SD1')+SF3->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA),'D1_PICM')
		RTP->(MsUnlock())
		(cAliasP)->(dbSkip())
	EndDo
#ENDIF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SF3")
		dbClearFilter()
		Ferase(cIndSF3+OrdBagExt())
	Else
		dbSelectArea(cAliasP)
		dbCloseArea()
	Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegQ   ³ Autor ³Natalia Antonucci      ³ Data ³ 22.10.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo Q                                     ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegQ(dDtInicial, dDtFinal, cDomFis)

Local cAliasQ   := ""
Local lQuery 	:= .F.
Local cQuery 	:= ""
Local nVlEnt 	:= 0
Local cCodEmp   := ""
Local cCodEst   := ""
Local lSimples	:= Iif(SuperGetMv("MV_SIMPLES")=="S",.T.,.F.)

#IFDEF TOP

	If TcSrvType()<>"AS/400"
		lQuery 	:= .T.
		cAliasQ	:= GetNextAlias()
		cQuery += " SELECT DISTINCT"
		cQuery += " SF3.F3_FILIAL,SF3.F3_ENTRADA,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR
		cQuery += " ,SF3.F3_LOJA,SF3.F3_CFO,SF3.F3_ESTADO,SF3.F3_EMISSAO,SF3.F3_VALCONT"
		cQuery += " ,SF3.F3_BASEICM,SF3.F3_VALICM,SF3.F3_ISENICM,SF3.F3_OUTRICM,SF3.F3_BASEIPI"
		cQuery += " ,SF3.F3_VALIPI,SF3.F3_ISENIPI,SF3.F3_OUTRIPI,SF3.F3_ICMSRET,SF3.F3_TIPO"
		cQuery += " ,SF3.F3_ICMSCOM,SF3.F3_ESPECIE,SF3.F3_DTLANC,SF3.F3_DTCANC,SF3.F3_ICMSDIF"
		cQuery += " ,SF3.F3_ECF,SF3.F3_ALIQICM"
		cQuery += " ,SA2.A2_FILIAL,SA2.A2_COD,SA2.A2_LOJA,SA2.A2_COD_MUN,SA2.A2_EST,SA2.A2_INSCR "
		cQuery += " FROM "
		cQuery += RetSqlName("SF3") + " SF3,"
		cQuery += RetSqlName("SA2") + " SA2 "
		cQuery += " WHERE "
		cQuery += " SF3.F3_FILIAL = '" + xFilial("SF3") + "' AND "
		cQuery += " SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND "
		cQuery += " SF3.F3_ENTRADA >= '" + Dtos(dDtInicial) + "' AND "
		cQuery += " SF3.F3_ENTRADA <= '" + Dtos(dDtFinal) + "' AND "
		cQuery += " SF3.F3_ICMSCOM >0 AND " //Diferencial de aliquota de ICMS
		cQuery += " SUBSTRING(SF3.F3_CFO,1,1) IN ('2') AND "
		cQuery += " SF3.F3_CLIEFOR = SA2.A2_COD AND SF3.F3_LOJA = SA2.A2_LOJA AND"
		cQuery += " SF3.F3_DTCANC ='' AND "
		cQuery += " SA2.A2_EST <>'TO' AND " // Somente para domiciliados fora de Tocantins
		cQuery += " SF3.D_E_L_E_T_='' AND "
		cQuery += " SA2.D_E_L_E_T_=''"
		cQuery += " ORDER BY A2_EST, A2_COD, A2_LOJA"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQ,.T.,.T.)
		DbSelectArea(cAliasQ)
#ELSE
		dbSelectArea("SF3")
		cIndSF3 := CriaTrab(NIL,.F.)
		cChave  := IndexKey()
		cFiltro := "F3_FILIAL=='"+xFilial("SF3")+"' .And. DTOS(F3_ENTRADA)>='"+Dtos(dDtInicial)+"' .AND. DTOS(F3_ENTRADA)<='"+Dtos(dDtFinal)+"'"
		cFiltro += " .And. DTOS(F3_DTCANC)=='"+Dtos(Ctod(""))+"'"
		cFiltro += " .And. SUBSTR(F3_CFO,1,1) $ '2'"
		cFiltro += " .And. F3_ICMSCOM >0 "
		IndRegua("SF3",cIndSF3,cChave,,cFiltro)
		SF3->(DbgoTop())
#ENDIF

#IFDEF TOP
	Endif

	Do While ! (cAliasQ)->(Eof()) .and. lSimples
		cCodEmp := (cAliasQ)->A2_COD
		nVlEnt  := (cAliasQ)->F3_VALCONT
		nVlBas  := (cAliasQ)->F3_BASEICM
		cCodMun := (cAliasQ)->A2_COD_MUN
		cCodEst := (cAliasQ)->A2_EST
		nVlCont := (cAliasQ)->F3_VALCONT
		nVlDif  := (cAliasQ)->F3_ICMSCOM
		
		DbSelectArea("RTQ")
		If ! RTQ->(DbSeek(LocalizaUF(cCodEst)))
			RecLock("RTQ",.T.)
		Else
			RecLock("RTQ",.F.)
		EndIf

		RTQ->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
		RTQ->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
		RTQ->RETIFICA	:= Val(aCfp[2][07])
		RTQ->DOMICFISC  := cDomFis
		RTQ->CODUF  	:= LocalizaUF(cCodEst)
		RTQ->VALCONT    += nVlCont
		RTQ->BASECALC   += nVlBas
		RTQ->COMPALIQ   += nVlDif
		RTQ->ALIQUOTA   := (cAliasQ)->F3_ALIQICM
		RTQ->(MsUnlock())
		(cAliasQ)->(dbSkip())
	EndDo

#ELSE

	Do While ! SF3->(Eof())
		cCodEmp := SF3->F3_CLIEFOR
		nVlBas  := SF3->F3_BASEICM
		cCodEst := Posicione('SA2',1,xFilial('SA2')+SF3->F3_CLIEFOR+SF3->F3_LOJA,'A2_EST')
		nVlDif  := SF3->F3_ICMSCOM
		nVlCont := SF3->F3_VALCONT

		DbSelectArea("RTQ")
		If ! RTQ->(DbSeek(LocalizaUF(cCodEst)))
			RecLock("RTQ",.T.)
		Else
			RecLock("RTQ",.F.)
		EndIf

		RTQ->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
		RTQ->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
		RTQ->RETIFICA	:= Val(aCfp[2][07])
		RTQ->DOMICFISC  := cDomFis
		RTQ->CODUF  	:= LocalizaUF(cCodEst)
		RTQ->VALCONT    += nVlCont
		RTQ->BASECALC   += nVlBas
		RTQ->COMPALIQ   += nVlDif
		RTQ->ALIQUOTA   := SF3->F3_ALIQICM
		RTQ->(MsUnlock())
		(cAliasQ)->(dbSkip())
	EndDo

#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !lQuery
		RetIndex("SF3")
		dbClearFilter()
		Ferase(cIndSF3+OrdBagExt())
	Else
		dbSelectArea(cAliasQ)
		dbCloseArea()
	Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegS   ³ Autor ³Henrique Pereira       ³ Data ³ 08.11.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo S                                     ³±±
±±³          ³Especificação do Diferencial de Alíquotas Consumidor Final   ³±±
±±³          ³(Saídas) por UF                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegS(dDtInicial, dDtFinal, cDomFis)

	Local cAliasS   	:= ""
	Local lQuery 		:= .F.
	Local cQuery 		:= ""
	Local nVlEnt 		:= 0
	Local nVlrDifDes	:= 0
	Local nVlBas  	:= 0
	Local nVlCont 	:= 0
	Local nVlDif		:= 0
	Local cCodEmp   	:= ""
	Local cCodEst   	:= ""

	#IFDEF TOP

		If TcSrvType()<>"AS/400"

			lQuery 		:= .T.
			cAliasS	:= GetNextAlias()

			cQuery += " SELECT SFT.FT_FILIAL,SFT.FT_ENTRADA,SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_CLIEFOR
			cQuery += " ,SFT.FT_LOJA,SFT.FT_CFOP,SFT.FT_VALCONT,SFT.FT_BASEICM"
			cQuery += " ,SFT.FT_ICMSCOM,SFT.FT_DTCANC,SFT.FT_ALIQICM,SFT.FT_DIFAL,SD2.D2_ALIQCMP"
			cQuery += " ,SA1.A1_FILIAL,SA1.A1_COD,SA1.A1_LOJA,SA1.A1_COD_MUN,SA1.A1_EST,SA1.A1_TIPO"
			cQuery += " FROM "
			cQuery += RetSqlName("SFT") + " SFT "
			cQuery += "INNER JOIN " + RetSqlName("SD2") + "	SD2 "
			cQuery += "ON SD2.D2_FILIAL 	= '" + xFilial("SD2")+ "' AND "
			cQuery += "SD2.D2_DOC			= SFT.FT_NFISCAL	AND "
			cQuery += "SD2.D2_SERIE			= SFT.FT_SERIE	AND "
			cQuery += "SD2.D2_ITEM 			= SFT.FT_ITEM 	AND "
			cQuery += "SD2.D2_CLIENTE		= SFT.FT_CLIEFOR	AND "
			cQuery += "SD2.D2_LOJA			= SFT.FT_LOJA 	AND "
			cQuery += "SD2.D_E_L_E_T_		<> '*' "
			cQuery += "INNER JOIN " + RetSqlName("SA1") + "	SA1 "
			cQuery += "ON SA1.A1_FILIAL 	= '" + xFilial("SA1")+ "' AND "
			cQuery += "SA1.A1_COD 			= SFT.FT_CLIEFOR	AND "
			cQuery += "SA1.A1_LOJA			= SFT.FT_LOJA 	AND "
			cQuery += "SA1.A1_EST 			<> 'TO' AND " // Somente para domiciliados fora de Tocantins
			cQuery += "SA1.A1_TIPO 			= 	'F' AND " // Somente para domiciliados fora de Tocantins
			cQuery += "SA1.D_E_L_E_T_ <> '*' "
			cQuery += " WHERE "
			cQuery += "SFT.FT_ENTRADA 		>= '" + Dtos(dDtInicial)	+ "' AND "
			cQuery += "SFT.FT_ENTRADA 		<= '" + Dtos(dDtFinal) 	+ "' AND "
			cQuery += "SFT.FT_ICMSCOM 		> 0 AND " //Diferencial de aliquota de ICMS
			cQuery += "SUBSTRING(SFT.FT_CFOP,1,1) IN ('6','7') AND "
			cQuery += "SFT.FT_DTCANC 		= '' AND "
			cQuery += "SFT.D_E_L_E_T_		<> '*' "
			cQuery += "ORDER BY A1_EST, A1_COD, A1_LOJA"
		
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasS,.T.,.T.)

			DbSelectArea(cAliasS)

		#ELSE
			lQuery := .F.
			dbSelectArea("SFT")
			cIndSFT	:=	CriaTrab(NIL,.F.)
			cChave	:=	IndexKey()
			cFiltro	:=	"  FT_FILIAL == '"+xFilial("SFT")+"'"
			cFiltro	:=	" .And. DTOS(FT_ENTRADA) >= '"+Dtos(dDtInicial)+"'"
			cFiltro 	:=	" .AND. DTOS(FT_ENTRADA) <= '"+Dtos(dDtFinal)+"'"
			cFiltro	+= 	" .And. DTOS(FT_DTCANC)=='"+Dtos(Ctod(""))+"'"
			cFiltro	+= 	" .And. SUBSTR(FT_CFOP,1,1) $ '6/7'"
			cFiltro	+= 	" .And. FT_ICMSCOM >0 "
	
			IndRegua("SFT",cIndSFT,cChave,,cFiltro)
			SFT->(DbgoTop())

		#ENDIF

		#IFDEF TOP
		Endif
		If !lQuery
			SA1->(DbSetOrder(1))
			SD2->(DbSetOrder(3))
		EndIf
		Do While !(cAliasS)->(Eof())
			cCodEmp 	:= (cAliasS)->A1_COD
			nVlEnt  	:= (cAliasS)->FT_VALCONT
			nVlBas  	:= (cAliasS)->FT_BASEICM
			cCodMun 	:= (cAliasS)->A1_COD_MUN
			cCodEst 	:= (cAliasS)->A1_EST
			nVlCont 	:= (cAliasS)->FT_VALCONT
			nVlDif		:= (cAliasS)->FT_ICMSCOM
			nVlrDifDes	:= (cAliasS)->FT_DIFAL
			nAliqCmp	:= (cAliasS)->D2_ALIQCMP
		
			DbSelectArea("RTS")
			If !RTS->(DbSeek(LocalizaUF(cCodEst)))
				RecLock("RTS",.T.)
			Else
				RecLock("RTS",.F.)
			EndIf

			RTS->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
			RTS->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
			RTS->RETIFICA		:= Val(aCfp[2][07])
			RTS->DOMICFISC  	:= cDomFis
			RTS->CODUF			:= LocalizaUF(cCodEst)
			RTS->VALCONT		+= nVlCont
			RTS->BASECALC		+= nVlBas
			RTS->DIFALIQ		+= nVlDif+nVlrDifDes
			RTS->ALIQUOTA		:= nAliqCmp
			RTS->ORIGEM		+= nVlDif
			RTS->DESTINO		+= nVlrDifDes
			RTS->(MsUnlock())
			(cAliasS)->(dbSkip())
		EndDo

	#ELSE

		Do While ! SFT->(Eof())
			If	SA1->(DbSeek(xFilial('SA1')+SFT->FT_CLIEFOR+SFT->FT_LOJA)) .And. SA1->A1_TIPO == 'F' .And. SA1->A1_EST <>'TO' .And. ;
				SD2->(DbSeek(xFilial("SD2")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))
				cCodEmp	:= SFT->FT_CLIEFOR
				nVlBas  	:= SFT->FT_BASEICM
				cCodEst 	:= SA1->A1_EST
				nVlDif  	:= SFT->FT_ICMSCOM
				nVlCont 	:= SFT->FT_VALCONT
				nVlrDifDes	:= SFT->FT_DIFAL
				nAliqCmp	:= (cAliasS)->D2_ALIQCMP
	
				DbSelectArea("RTS")
				If !RTS->(DbSeek(LocalizaUF(cCodEst)))
					RecLock("RTS",.T.)
				Else
					RecLock("RTS",.F.)
				EndIf
	
				RTS->INSCRICAO  := Val(aFisFill(SM0->M0_INSC,9))
				RTS->PERIODOREF := StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
				RTS->RETIFICA	  := Val(aCfp[2][07])
				RTS->DOMICFISC  := cDomFis
				RTS->CODUF  	  := LocalizaUF(cCodEst)
				RTS->VALCONT    += nVlCont
				RTS->BASECALC   += nVlBas
				RTS->DIFALIQ	  += nVlDif+nVlrDifDes
				RTS->ALIQUOTA   := nAliqCmp
				RTS->ORIGEM	  += nVlDif
				RTS->DESTINO	  += nVlrDifDes
				RTS->(MsUnlock())
			EndIF
			SFT->(dbSkip())
		EndDo


	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !lQuery
		RetIndex("SFT")
		dbClearFilter()
		Ferase(cIndSFT+OrdBagExt())
	Else
		dbSelectArea(cAliasS)
		dbCloseArea()
	Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegZ   ³ Autor ³Luciana P. Munhoz      ³ Data ³ 07.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo Z - Indica o Final da Declaracao      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegZ(dDtInicial)

	dbSelectArea("RTZ")
	RecLock("RTZ",.T.)

	RTZ->INSCRICAO	:= Val(aFisFill(SM0->M0_INSC,9))
	RTZ->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
	RTZ->RETIFICA	:= Val(aCfp[2][07])
	MsUnlock()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³Luciana P. Munhoz      ³ Data ³ 07.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()
	Local aStru		:= {}
	Local aTrbs		:= {}
	Local cArq		:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo A - Informacoes Economico-Fiscais / Identificacao do Contribuinte / Apuracao do Imposto          |                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"ATIVIDADE"		,"N",007,0})   	//Atividade Economica Principal - CNAE
	AADD(aStru,{"TIPOESTAB"		,"C",001,0})	//Tipo de Estabelecimento - U=Unico, M=Matriz, F=Filial
	AADD(aStru,{"TARE"			,"C",001,0})  	//Portador de TARE - S=Sim, N=Nao
	AADD(aStru,{"TIPOESCR"		,"C",001,0})  	//Tipo de Escrituracao - F=Fiscal, C=Contabil
	AADD(aStru,{"SALDOINI"		,"N",014,2}) 	//Saldo Inicial de Caixa
	AADD(aStru,{"SALDOFIM"		,"N",014,2})	//Saldo Final de Caixa
	AADD(aStru,{"USAECF"		,"C",001,0})	//Usuario de ECF - S=Sim, N=Nao
	AADD(aStru,{"CPFDECLAR"		,"C",011,0})	//CPF Declarante
	AADD(aStru,{"NOMEDECLAR"	,"C",050,0})	//Nome Declarante
	AADD(aStru,{"CRCCONTAB"		,"C",010,0})	//N. CRC Contabilista
	AADD(aStru,{"UFCRCCONTA" 	,"C",002,0})	//UF CRC Contabilista
	AADD(aStru,{"NOMECONTAB"	,"C",050,0})	//Nome Contabilista
	AADD(aStru,{"FONECONTAB"	,"C",020,0})	//Telefone Contabilista
	// Debito do Imposto
	AADD(aStru,{"SAIDADEBI"		,"N",014,2})	//Saida/Prestacoes com debito do imposto
	AADD(aStru,{"OUTROSDEB"		,"N",014,2})	//Outros Debitos
	AADD(aStru,{"ESTORCRED"		,"N",014,2})	//Estorno de Creditos (Incluir os creditos transferidos)
	// Credito do Imposto
	AADD(aStru,{"ENTRADEBI"		,"N",014,2})	//Entradas/Aquisicoes com debito do imposto
	AADD(aStru,{"OUTROSCRED" 	,"N",014,2})	//Outros Creditos (Incuir os creditos recebidos por transferencia)
	AADD(aStru,{"ESTORDEB"   	,"N",014,2})	//Estorno de debito
	AADD(aStru,{"SALDOCRED"  	,"N",014,2})	//Saldo credor do periodo anterior
	// Apuracao do periodo
	AADD(aStru,{"DEDUCOES"   	,"N",014,2})	//Deducoes
	AADD(aStru,{"DIFALIQREC" 	,"N",014,2})	//Diferencial de aliquota a recolher
	// Apuracao da Substituicao Tributaria Interna
	AADD(aStru,{"VLRPROD"    	,"N",014,2})	//Valor dos Produtos
	AADD(aStru,{"BASECALC"   	,"N",014,2})	//Base de calculo
	AADD(aStru,{"ICMSSUBST"  	,"N",014,2})	//ICMS Substituicao Tributaria
	AADD(aStru,{"CREDICMS"   	,"N",014,2})	//Credito de ICMS
	AADD(aStru,{"OUTRCREDI"  	,"N",014,2})	//Outros Creditos
	// Informacoes Adicionais
	AADD(aStru,{"NUMTARE"    	,"C",020,0})	//Numero do TARE - Informar caso possua
	AADD(aStru,{"DTVENCTARE" 	,"C",008,0}) 	//Data vencimento do TARE - DDMMAAAA - Informar caso possua TARE
	AADD(aStru,{"DIFALIQATU" 	,"N",010,2})	//Diferencial de Aliquota do periodo
	AADD(aStru,{"DIFALIQANT" 	,"N",010,2})	//Diferencial de Aliquota a recolher transportado do periodo anterior
	AADD(aStru,{"TIPOENCERR" 	,"C",001,0})	//Tipo de Encerrante Considerado na Escrituracao de LMC - M=Mecanico, E=Eletronico
	AADD(aStru,{"COMPLALIQ" 	,"N",014,2})	//Diferencial de Aliquota a recolher transportado do periodo anterior
	//Versão 10.00
	AADD(aStru,{"DIFALQCONF"	,"N",014,2})	//Diferencial de Aliquota Consumidor Final
	//Versão 9.0
	AADD(aStru,{"HOUVEMUD"  	,"C",001,0})	//Mudou de domicilio
	AADD(aStru,{"MUNICIPANT" 	,"N",007,0})	//Cod IBGE Municipio Anterior
	AADD(aStru,{"DINIMUNATU" 	,"C",008,0})	//Data Inicial Cidade Atual
	AADD(aStru,{"DFIMMUNATU" 	,"C",008,0})	//Data Final Cidade Atual
	AADD(aStru,{"DINIMUNANT" 	,"C",008,0})	//Data Inicial Cidade Anterior
	AADD(aStru,{"DFIMMUNANT" 	,"C",008,0})	//Data Final Cidade Anterior


	
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTA")
	IndRegua("RTA",cArq,"PERIODOREF")
	AADD(aTrbs,{cArq,"RTA"})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo B - Entradas e Saidas de Mercadorias, Bens e/ou Servicos no Estabelecimento do Contribuinte]	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"ENTRSAIDA"  	,"C",001,0})   //Indica se Entrada ou Saida - Entrada=0, Saida=1
	AADD(aStru,{"CFOP"       	,"C",004,0}) 	//Codigo CFOP - Verificar Tabela
	AADD(aStru,{"BASECAL"    	,"N",014,2}) 	//Base de Calculo
	AADD(aStru,{"ISENTAS"    	,"N",014,2})	//Insentas/Nao Tributadas
	AADD(aStru,{"OUTRAS"     	,"N",014,2})	//Outras
	AADD(aStru,{"SUBSTTRIB"  	,"N",014,2})	//Substituicao Tributaria
	AADD(aStru,{"VLRCONTAB"  	,"N",014,2})	//Valor Contabil
	AADD(aStru,{"CREDDEB"   	,"N",014,2})	//Credito do Imposto na Entrada e Debito do Imposto na Saida
	//Versao 9.0
	AADD(aStru,{"DOMICFISC"   	,"C",001,0})	//Domicilio Fiscal A=ATUAL, B=ANTERIOR

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTB")
	IndRegua("RTB",cArq,"CFOP")
	AADD(aTrbs,{cArq,"RTB"})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo C - Demonstrativo de Estoque																      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	
	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	// Estoque Inicial
	AADD(aStru,{"EINITRIB"   	,"N",014,2})	//Tributadas
	AADD(aStru,{"EINIISENT"  	,"N",014,2})	//Isentas e/ou tributadas
	AADD(aStru,{"EINIOUTRA"  	,"N",014,2})	//Outras
	AADD(aStru,{"EINISUBTR"  	,"N",014,2})	//Substituicao Tributaria
	AADD(aStru,{"EINIVLRTOT" 	,"N",014,2})	//Valor Total
	// Estoque Final
	AADD(aStru,{"EFIMTRIB"   	,"N",014,2})	//Tributadas
	AADD(aStru,{"EFIMISENT"  	,"N",014,2})   	//Isentas e/ou tributadas
	AADD(aStru,{"EFIMOUTRA"  	,"N",014,2})	//Outras
	AADD(aStru,{"EFIMSUBTR"  	,"N",014,2})	//Substituicao Tributaria
	AADD(aStru,{"EFIMVLRTOT" 	,"N",014,2}) 	//Valor Total
	
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTC")
	IndRegua("RTC",cArq,"PERIODOREF")
	AADD(aTrbs,{cArq,"RTC"})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                           
	//³Registro Tipo D - Detalhamento das Entradas/Saidas de Mercadorias e/ou Prest. de Serv. por Unidade da Federacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"ENTRSAIDA"  	,"C",001,0})   //Indica se Entrada ou Saida - Entrada=0, Saida=1
	AADD(aStru,{"CODUF"      	,"N",002,0})	//Codigo da UF
	AADD(aStru,{"BASECONTR"  	,"N",014,2})	//Base de Calculo ou Base de Calculo Contribuinte em caso de Saida
	AADD(aStru,{"BASENCONTR" 	,"N",014,2})	//Base de Calculo Não Contribuinte em caso de saida
	AADD(aStru,{"ISENTAS"     	,"N",014,2})	//Outras, isentas e/ou não trib. caso entradas. Outras, isentas e/ou trib. caso saidas.
	AADD(aStru,{"OUTRAS"     	,"N",014,2})	//Outras, isentas e/ou não trib. caso entradas. Outras, isentas e/ou trib. caso saidas.
	AADD(aStru,{"ICMSSUBST" 	,"N",014,2})	//ICMS cobrado por substituicao tributaria
	AADD(aStru,{"VLRCONTRIB" 	,"N",014,2})	//Valor contabil quando entrada/ Valor contabil contribuinte quando saida
	AADD(aStru,{"VLRNAOCONT" 	,"N",014,2})	//Valor contabil nao contribuinte - em caso de entrada deve ser zero
	AADD(aStru,{"CREDDEB"     	,"N",014,2})	//Credito e Debito
	AADD(aStru,{"DEBIMPNC"   	,"N",014,2})	//Credito do Imposto na Entrada e Debito do Imposto na Saida
	//Versao 9.0
	AADD(aStru,{"DOMICFISC"   	,"C",001,0})	//Domicilio Fiscal A=ATUAL, B=ANTERIOR
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTD")
	IndRegua("RTD",cArq,"StrZero(CODUF,2)+ENTRSAIDA")
	AADD(aTrbs,{cArq,"RTD"})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo E - ICMS a Recolher									   										  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	
	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"TIPOICMS"		,"C",001,0})	//Tipo de ICMS - Normal=N, Diferencial de Aliq.=D, Subst. Tributaria=S
	AADD(aStru,{"DTVENC"     	,"C",008,0}) 	//Data de Vencimento - DDMMAAA
	AADD(aStru,{"VLRICMS"    	,"N",014,2})	//Valor do ICMS a recolher
	
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTE")
	IndRegua("RTE",cArq,"TIPOICMS")
	AADD(aTrbs,{cArq,"RTE"})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo J - Informações sobre TARE  		      									  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	
	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"NTARE"   		,"C",020,0})   	//Numero TARE
	AADD(aStru,{"DTVENCTO"  	,"C",008,0})   	//Nuemro TARE
		
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTJ")
	AADD(aTrbs,{cArq,"RTJ"})
   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo K - Outros Creditos                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	
	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"CODBASE"      	,"C",002,0})   	//Codigo Base Legal
	AADD(aStru,{"VLRCRED"    	,"N",014,2})   	//Valor do Credito

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTK")
	IndRegua("RTK",cArq,"CODBASE")
	AADD(aTrbs,{cArq,"RTK"})


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo L - Esecificação das Deducoes                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	
	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"CODBASE"      	,"C",002,0})   	//Codigo Base Legal
	AADD(aStru,{"ICMSDEV"    	,"N",014,2})   	//Valor do Credito
	AADD(aStru,{"MICMS"     	,"N",014,2})   	//Valor do Credito
	AADD(aStru,{"VLRDED"    	,"N",014,2})   	//Valor do Credito

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTL")
	IndRegua("RTL",cArq,"CODBASE")
	AADD(aTrbs,{cArq,"RTL"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo M - Saidas e/ou Prestações e Entradas e/ou Aquisições do Estabelecimento do Contribuinte por Municipio de Origem (campo 15)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	
	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"CODMUNORI"		,"N",014,0})   	//Cod Municipio de Origem - IBGE
	AADD(aStru,{"DOMICFISC"    	,"C",002,0})   	//Domicilio Fiscal
	AADD(aStru,{"SAIDAS"     	,"N",014,2})   	//Valor do Credito
	AADD(aStru,{"ENTRADAS"    	,"N",014,2})   	//Valor do Credito
     
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTM")
	IndRegua("RTM",cArq,"CODMUNORI")
	AADD(aTrbs,{cArq,"RTM"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo N - Relação de Mercadorias e/ou Produtos adquiridos de outros Municipios Tocantinenses com Diferimento de do ICMS (campo 16 - Total das Notas Fiscais por Inscrição Estadual)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	
	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"IDEMPCCI"		,"C",012,0})   	//Identificacao daempresa - CCI
	AADD(aStru,{"DOMICFISC"    	,"C",002,0})   	//Domicilio Fiscal
	AADD(aStru,{"CODMUNORI"		,"N",007,0})   	//Cod Municipio de Origem  - IBGE
	AADD(aStru,{"TOTNFEMP"    	,"N",014,2})   	//Total das NFs por IE (N5)
     
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTN")
	IndRegua("RTN",cArq,"IDEMPCCI")
	AADD(aTrbs,{cArq,"RTN"})
                            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo O - Relação de Mercadorias e/ou Produtos adquiridos de outros Municipios Tocantinenses com Diferimento de do ICMS (campo 16 - Notas Fiscais por Inscrição Estadual)          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	
	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"IDEMPCCI"		,"C",012,0})   	//Identificacao daempresa - CCI
	AADD(aStru,{"DOMICFISC"    	,"C",002,0})   	//Domicilio Fiscal
	AADD(aStru,{"NUMNOTA"		,"N",007,0})   	//Numero da Nota
	AADD(aStru,{"VALNOTA"    	,"N",014,2})   	//Total das NFs por IE --Igual (N8)
     
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTO")
	IndRegua("RTO",cArq,"INSCRICAO")
	AADD(aTrbs,{cArq,"RTO"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo P - Detalhamento do Diferencial de Alíquotas por UF (7.6.1) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	
	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"DOMICFISC"    	,"C",001,0})   	//Domicilio Fiscal
	AADD(aStru,{"CODUF"  		,"C",002,0})   	//Codigo da UF
	AADD(aStru,{"VALCONT"		,"N",014,2})   	//Valor Contabil
	AADD(aStru,{"BASECALC"    	,"N",014,2})   	//Base de Calculo
	AADD(aStru,{"DIFALIQ"    	,"N",014,2})   	//Diferencial de aliquota
	AADD(aStru,{"ALIQUOTA"    	,"N",004,0})   	//aliquota
     
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTP")
	IndRegua("RTP",cArq,"CODUF")
	AADD(aTrbs,{cArq,"RTP"})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo Q - Especificação da Complementação de Alíquotas por UF (7.9.1)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	
	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"DOMICFISC"    	,"C",001,0})   	//Domicilio Fiscal
	AADD(aStru,{"CODUF"  		,"C",002,0})   	//Codigo da UF
	AADD(aStru,{"VALCONT"		,"N",014,2})   	//Valor Contabil
	AADD(aStru,{"BASECALC"    	,"N",014,2})   	//Base de Calculo
	AADD(aStru,{"COMPALIQ"    	,"N",014,2})   	//Complementacao de aliquota
	AADD(aStru,{"ALIQUOTA"    	,"N",004,0})   	//aliquota
     
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTQ")
	IndRegua("RTQ",cArq,"CODUF")
	AADD(aTrbs,{cArq,"RTQ"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo R - Especificação de Outros Debitos (5.2.1)      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""

	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"CODBASE"      	,"C",002,0})   	//Codigo Base Legal
	AADD(aStru,{"VLRDEBI"    	,"N",014,2})   	//Valor do Credito

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTR")
	IndRegua("RTR",cArq,"CODBASE")
	AADD(aTrbs,{cArq,"RTR"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo S - Especificação do Diferencial de Alíquotas Consumidor Final (Saídas) por UF   7.13.1] ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	
	AADD(aStru,{"INSCRICAO"		,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"		,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"DOMICFISC"    	,"C",001,0})   	//Domicilio Fiscal
	AADD(aStru,{"CODUF"  		,"C",002,0})   	//Codigo da UF
	AADD(aStru,{"VALCONT"		,"N",014,2})   	//Valor Contabil
	AADD(aStru,{"BASECALC"    	,"N",014,2})   	//Base de Calculo
	AADD(aStru,{"DIFALIQ"    	,"N",014,2})   	//Diferencial de aliquota
	AADD(aStru,{"ALIQUOTA"    	,"N",004,0})   	//aliquota
	AADD(aStru,{"ORIGEM"     	,"N",014,2})   	//Origem
	AADD(aStru,{"DESTINO"    	,"N",014,2})   	//Origem
     
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTS")
	IndRegua("RTS",cArq,"CODUF")
	AADD(aTrbs,{cArq,"RTS"})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo Z - Indica o Final da Declaracao  						       									  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	
	AADD(aStru,{"INSCRICAO"	    ,"N",009,0})	//Inscricao Estadual
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"RETIFICA"		,"N",002,0})   	//Retificacao
	AADD(aStru,{"TOTALREG"   	,"N",003,0})   	//Total de Registro q compoe a declaracao - Nao incluindo o Seg. Z
	
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTZ")
	IndRegua("RTZ",cArq,"PERIODOREF")
	AADD(aTrbs,{cArq,"RTZ"})

Return (aTrbs)
                 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CFP        ³ Autor ³Luciana P. Munhoz		 ³ Data ³ 07.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina CFP                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CFP()
	Local aTxtPre 		:= {}
	Local aPaineis 		:= {}
	
	Local cTitObj1		:= ""
	Local cTitObj2		:= ""
	Local cMask2		:= Replicate("!",20)	//Numero do TARE
	Local cMask3		:= Replicate("!",50)	//Mascara do Nome
//    Local cMask4		:= Replicate("!",250)	//Mascara dos CFOPS
	Local lGeraWiz	:= .F.

	Local nPos			:= 0

	If !lAutomato

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta wizard com as perguntas necessarias³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aTxtPre,STR0015)			//"Assistente de parametrização da GIAM-TO"
		AADD(aTxtPre,STR0016)			//"Atenção"
		AADD(aTxtPre,STR0017)			//"Preencha as informações solicitadas para a geração do arquivo magnetico"
		AADD(aTxtPre,STR0018)	   		//"GIAM - Guia de Informação e Apuração do ICMS Mensal - Governo do Estado de Tocantins - TO"
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Painel 1 - Informacoes Economico-Fiscais / Identificacao do Cont. / Apuracao do Imposto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		aAdd(aPaineis,{})
		nPos :=	Len(aPaineis)
		aAdd(aPaineis[nPos],STR0019)	//"Assistente de parametrização"
		aAdd(aPaineis[nPos],STR0020)	//"Informações Econômico/Fiscais / Identificação do Contribuinte / Apuração do Imposto: "
		aAdd(aPaineis[nPos],{})
		
		cTitObj1 :=	STR0021				//"Tipo de Estabelecimento?" 			//Cfp[1][01]
		cTitObj2 :=	STR0022				//"Portador de TARE?"       			//Cfp[1][02]
		aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
		aAdd(aPaineis[nPos][3],{3,,,,,{STR0023,STR0024,STR0025},,})  			//"Unico","Matriz","Filial"
		aAdd(aPaineis[nPos][3],{3,,,,,{STR0026,STR0027},,})          			//"Sim","Não"
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		
		cTitObj1 :=	STR0028				//"Número do TARE?"						//Cfp[1][03]
		cTitObj2 :=	STR0029				//"Data de Vencimento do TARE?"			//Cfp[1][04]
		aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
		aAdd(aPaineis[nPos][3],{2,,cMask2,1,,,,20})
		aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		
		cTitObj1 :=	STR0030				//"Tipo de Escrituração?"				//Cfp[1][05]
		cTitObj2 :=	STR0031				//"Usuário de ECF?"						//Cfp[1][06]
		aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
		aAdd(aPaineis[nPos][3],{3,,,,,{STR0032,STR0033},,})                   //"Fiscal","Contábil"
		aAdd(aPaineis[nPos][3],{3,,,,,{STR0026,STR0027},,})          			//"Sim","Não"
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		
		cTitObj1 :=	STR0034				//"Saldo Inicial de caixa?"				//Cfp[1][07]
		cTitObj2 :=	STR0035				//"Saldo Final de caixa?"   			//Cfp[1][08]
		aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
		aAdd(aPaineis[nPos][3],{2,,"@E 99,999,999.99",2,2,,,14})
		aAdd(aPaineis[nPos][3],{2,,"@E 99,999,999.99",2,2,,,14})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		
		
		cTitObj1 :=	STR0067   // "Data do fechamento de estoque?"   Cfp[1][09]
		cTitObj2 :=	"Gera Registro Tipo C - Demonstrativo de"	//	"Gera Registro Tipo C - Demonstrativo de Estoque?"   Cfp[1][10]
		cTitObj3 :=	"Estoque ?"
		aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
		aAdd(aPaineis[nPos][3],{1,"",,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj3,,,,,,})
		aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})
		aAdd(aPaineis[nPos][3],{3,,,,,{STR0026,STR0027},,})          			//"Sim","Não"
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Painel 2 - Continuacao - Informacoes Economico-Fiscais / Identificacao do Cont. / Apuracao do Imposto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		aAdd(aPaineis,{})
		nPos :=	Len(aPaineis)
		aAdd(aPaineis[nPos],STR0036) 	//"Assistente de parametrização - Continuação")
		aAdd(aPaineis[nPos],STR0020)	//"Informações Econômico/Fiscais / Identificação do Contribuinte / Apuração do Imposto: "
		aAdd(aPaineis[nPos],{})
	
		cTitObj1 := STR0037				//"CPF do Declarante?"					//Cfp[2][01]
		cTitObj2 :=	STR0038				//"Nome do Declarante?"					//Cfp[2][02]
		aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
		aAdd(aPaineis[nPos][3],{2,,"99999999999",1,,,,11})
		aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,50})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		
		cTitObj1 := STR0039				//"Número CRC do Contabilista?"			//Cfp[2][03]
		cTitObj2 :=	STR0040				//"UF do Contabilista?"					//Cfp[2][04]
		aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
		aAdd(aPaineis[nPos][3],{2,,"!!!!!!!!!!",1,,,,10})
		aAdd(aPaineis[nPos][3],{2,,"!!",1,,,,2})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		                                                                         
		cTitObj1 :=	STR0041				//"Nome do Contabilista?"		   		//Cfp[2][05]
		cTitObj2 :=	STR0042				//"Telefone do Contabilista?" 			//Cfp[2][06]
		aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
		aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,50})
		aAdd(aPaineis[nPos][3],{2,,cMask2,1,,,,20})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		
		cTitObj1 :=	STR0043				//"Qual número da retificação?"			//Cfp[2][07]
		cTitObj2 :=	STR0045				//"Tipo de Encerrante - Escrit. LMC?" 		//Cfp[2][08]
		aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
		aAdd(aPaineis[nPos][3],{2,,"99",1,,,,2})
		aAdd(aPaineis[nPos][3],{3,,,,,{STR0046,STR0047},,})  					//"Mecânico","Eletrônico"
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Painel 3 - Informacoes Economico-Fiscais / Identificacao do Cont. / Apuracao do Imposto e 			³
		//³			  Detalhamento das E/S de Mercadorias e/ou Prestações de Serviços por UF					³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		aAdd(aPaineis,{})
		nPos :=	Len(aPaineis)
		aAdd(aPaineis[nPos],STR0019)	//"Assistente de parametrização"
		aAdd(aPaineis[nPos],STR0048)	//"Entradas e Saidas de Mercadorias, Bens e/ou Servicos no Estabelecimento do Contribuinte : "
		aAdd(aPaineis[nPos],{})
	
		cTitObj1 :=	STR0049				//"Tipo de ICMS a Recolher?"			 	//Cfp[3][01]
		cTitObj2 :=	STR0050				//"Data de Vencimento - ICMS a Recolher?" 	//Cfp[3][02]
	
		aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
		aAdd(aPaineis[nPos][3],{3,,,,,{STR0051,STR0052,STR0053,STR0068,STR0055},,})			//"Normal","Diferencial de Alíquota","Subst. Tributária","Todos"
		aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	
		cTitObj1 :=	STR0056  //"Gera Registro Tipo M (Campo 15)?"
		cTitObj2 :=	STR0057  //"Possui IE centralizada?"
	
		aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
		aAdd(aPaineis[nPos][3],{3,,,,,{STR0026,STR0027},,}) //"Sim"###"Não"
		aAdd(aPaineis[nPos][3],{3,,,,,{STR0026,STR0027},,}) //"Sim"###"Não"
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Painel 4 - Informacoes De mudança de Domicilio                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aAdd(aPaineis,{})
		nPos :=	Len(aPaineis)
		aAdd(aPaineis[nPos],STR0019)	//"Assistente de parametrização"
		aAdd(aPaineis[nPos],STR0066)  	//"Informacoes De mudança de Domicilio")
		aAdd(aPaineis[nPos],{})
	
		cTitObj1 := STR0058  	//"Houve Mudança de Domicílio?" 								  //Cfp[4][01]
		cTitObj2 :=	STR0059     //"Cod IBGE Municipio Anterior"  								  //Cfp[4][02]
	
		aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
		aAdd(aPaineis[nPos][3],{3,,,,,{STR0026,STR0027},,}) //"Sim"###"Não"
		aAdd(aPaineis[nPos][3],{2,,"99999999",1,,,,7})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	
		cTitObj1 :=	STR0060  //"Data Inicial domicilio Atual"	                                  //Cfp[4][03]
		cTitObj2 :=	STR0061  //"Data Final domicilio Atual"	                                  //Cfp[4][04]
	
		aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
		aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})
		aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	
		cTitObj1 :=	STR0062  //	"Data Inicial domicilio Anterior"		                          //Cfp[4][05]
		cTitObj2 :=	STR0063  //	"Data Final domicilio Anterior"		                          //Cfp[4][06]
	
		aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
		aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
		aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})
		aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})
		aAdd(aPaineis[nPos][3],{0,"",,,,,,})

		lGeraWiz := xMagWizard(aTxtPre,aPaineis,"GIAMTO")
	Else
		lGeraWiz := .T.
	EndIf

Return(lGeraWiz)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocalizaCFOPºAutor  ³Luciana P. Munhoz   º Data ³ 07/02/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Localiza o Código refente ao CFOP posicionado.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GIAMTO                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocalizaCFOP(cCFOP)
Local cNumCFOP	:= ""

Do Case
	Case (cCFOP >= "1101" .And. cCFOP <= "1126") .Or. (cCFOP >= "1651" .And. cCFOP <= "1653") // Compras
		cNumCFOP	:= "01"
	Case (cCFOP >= "1151" .And. cCFOP <= "1154") .Or. (cCFOP >= "1658" .And. cCFOP <= "1659") // Transferências
		cNumCFOP	:= "02"
	Case (cCFOP >= "1201" .And. cCFOP <= "1209") .Or. (cCFOP >= "1660" .And. cCFOP <= "1662") // Devoluções
		cNumCFOP	:= "03"
	Case (cCFOP >= "1251" .And. cCFOP <= "1257")												// Energia Elétrica
		cNumCFOP	:= "04"
	Case (cCFOP >= "1301" .And. cCFOP <= "1306")												// Serviço de Comunicação
		cNumCFOP	:= "05"
	Case (cCFOP >= "1351" .And. cCFOP <= "1356") .Or. (cCFOP >= "1931" .And. cCFOP <= "1932")	// Serviço de Transporte
		cNumCFOP	:= "06"
	Case (cCFOP >= "1401" .And. cCFOP <= "1415")												// Regime Substituição Trib.
		cNumCFOP	:= "07"
	Case (cCFOP >= "1451" .And. cCFOP <= "1452") 												// Retorno de Insumo
		cNumCFOP	:= "08"
	Case (cCFOP == "1664")	 																	// Retorno combus. ou Lubrif. Arm.
		cNumCFOP	:= "34"
	Case (cCFOP >= "1501" .And. cCFOP <= "1504")												// Fim específico Exportação
		cNumCFOP	:= "09"
	Case (cCFOP >= "1551" .And. cCFOP <= "1555")												// Ativo Imobilizado
		cNumCFOP	:= "10"
	Case (cCFOP >= "1556" .And. cCFOP <= "1557") 												// Material de Consumo
		cNumCFOP	:= "11"
	Case (cCFOP >= "1601" .And. cCFOP <= "1603")												// Créditos e Ressarc. de ICMS
		cNumCFOP	:= "12"
	Case (cCFOP == "1605")																		// Receb., por Transf., de saldo devedor de ICMS
		cNumCFOP	:= "36"
	Case (cCFOP == "1933")																		// Aquis. de Serv. Tributado pelo ISSQN
		cNumCFOP	:= "37"
	Case (cCFOP >= "1901" .And. cCFOP <= "1926") .Or. (cCFOP == "1663") .Or. (cCFOP == "1949") // Outras Entradas
		cNumCFOP	:= "13"
	Case (cCFOP >= "2101" .And. cCFOP <= "2126") .Or. (cCFOP >= "2651" .And. cCFOP <= "2653") // Compras
		cNumCFOP	:= "14"
	Case (cCFOP >= "2151" .And. cCFOP <= "2154") .Or. (cCFOP >= "2658" .And. cCFOP <= "2659") // Transferências
		cNumCFOP	:= "15"
	Case (cCFOP >= "2201" .And. cCFOP <= "2209") .Or. (cCFOP >= "2660" .And. cCFOP <= "2662") // Devoluções
		cNumCFOP	:= "16"
	Case (cCFOP >= "2251" .And. cCFOP <= "2257")												// Energia Elétrica
		cNumCFOP	:= "17"
	Case (cCFOP >= "2301" .And. cCFOP <= "2306")												// Serviço de Comunicação
		cNumCFOP	:= "18"
	Case (cCFOP >= "2351" .And. cCFOP <= "2356") .Or. (cCFOP >= "2931" .And. cCFOP <= "2932")	// Serviço de Transporte
		cNumCFOP	:= "19"
	Case (cCFOP >= "2401" .And. cCFOP <= "2415")												// Regime Substituição Trib.
		cNumCFOP	:= "20"
	Case (cCFOP == "2664")	 																	// Retorno combus. ou Lubrif. Arm.
		cNumCFOP	:= "35"
	Case (cCFOP >= "2501" .And. cCFOP <= "2504")												// Fim específico Exportação
		cNumCFOP	:= "21"
	Case (cCFOP >= "2551" .And. cCFOP <= "2555")												// Ativo Imobilizado
		cNumCFOP	:= "22"
	Case (cCFOP >= "2556" .And. cCFOP <= "2557") 												// Material de Consumo
		cNumCFOP	:= "23"
	Case (cCFOP == "2603")																		// Créditos e Ressarc. de ICMS
		cNumCFOP	:= "24"
	Case (cCFOP == "2933")																		// Aquis. de Serv. Tributado pelo ISSQN
		cNumCFOP	:= "38"
	Case (cCFOP == "2663") .Or. (cCFOP == "2949") .Or. (cCFOP >= "2901" .And. cCFOP <= "2925") // Outras Entradas
		cNumCFOP	:= "25"
	Case (cCFOP >= "3101" .And. cCFOP <= "3127") .Or. (cCFOP >= "3651" .And. cCFOP <= "3653") // Compras
		cNumCFOP	:= "26"
	Case (cCFOP >= "3201" .And. cCFOP <= "3211")												// Devoluções
		cNumCFOP	:= "27"
	Case (cCFOP == "3251")																		// Energia Elétrica
		cNumCFOP	:= "28"
	Case (cCFOP == "3301")																		// Serviço de Comunicação
		cNumCFOP	:= "29"
	Case (cCFOP >= "3350" .And. cCFOP <= "3356")												// Serviço de Transporte
		cNumCFOP	:= "30"
	Case (cCFOP == "3503")																		// Fim específico Exportação
		cNumCFOP	:= "31"
	Case (cCFOP >= "3551" .And. cCFOP <= "3553")												// Ativo Imobilizado
		cNumCFOP	:= "32"
	Case (cCFOP == "3556") 																		// Material de Consumo
		cNumCFOP	:= "39"
	Case (cCFOP >= "3901" .And. cCFOP <= "3949") 												// Outras Entradas
		cNumCFOP	:= "33"
	Case (cCFOP >= "5101" .And. cCFOP <= "5125") .Or. (cCFOP >= "5651" .And. cCFOP <= "5656") // Vendas
		cNumCFOP	:= "01"
	Case (cCFOP >= "5151" .And. cCFOP <= "5156") .Or. (cCFOP == "5658") .Or. (cCFOP == "5659") // Transferências
		cNumCFOP	:= "02"
	Case (cCFOP >= "5201" .And. cCFOP <= "5210") .Or. (cCFOP >= "5660" .And. cCFOP <= "5662") // Devoluções
		cNumCFOP	:= "03"
	Case (cCFOP >= "5251" .And. cCFOP <= "5258")												// Energia Elétrica
		cNumCFOP	:= "04"
	Case (cCFOP >= "5301" .And. cCFOP <= "5307")												// Serviço de Comunicação
		cNumCFOP	:= "05"
	Case (cCFOP >= "5351" .And. cCFOP <= "5357") .Or. (cCFOP == "5359")						// Serviço de Transporte
		cNumCFOP	:= "06"
	Case (cCFOP >= "5401" .And. cCFOP <= "5415")												// Regime Substituição Trib.
		cNumCFOP	:= "07"
	Case (cCFOP == "5451") 																		// Remessa de Insumo
		cNumCFOP	:= "08"
	Case (cCFOP == "5657")	 																	// Remessa Combus. ou Lubrif.
		cNumCFOP	:= "32"
	Case (cCFOP == "5663" .Or. cCFOP == "5666")												// Remessa Combus. ou Lubrif. Arm.
		cNumCFOP	:= "33"
	Case (cCFOP == "5664" .Or. cCFOP == "5665")												// Retorno Combus. ou Lubrif. Arm.
		cNumCFOP	:= "34"
	Case (cCFOP >= "5501" .And. cCFOP <= "5503")												// Fim específico Exportação
		cNumCFOP	:= "09"
	Case (cCFOP >= "5551" .And. cCFOP <= "5555")												// Ativo Imobilizado
		cNumCFOP	:= "10"
	Case (cCFOP >= "5556" .And. cCFOP <= "5557") 												// Material de Consumo
		cNumCFOP	:= "41"
	Case (cCFOP >= "5601" .And. cCFOP <= "5603")												// Créditos e Ressarc. de ICMS
		cNumCFOP	:= "11"
	Case (cCFOP == "5605")																		// Transf. de saldo devedor de ICMS
		cNumCFOP	:= "38"
	Case (cCFOP == "5933")																		// Prestação de Serv. Tributado pelo ISSQN
		cNumCFOP	:= "39"
	Case (cCFOP >= "5901" .And. cCFOP <= "5932") .Or. (cCFOP == "5949")						// Outras Saídas
		cNumCFOP	:= "12"
	Case (cCFOP >= "6101" .And. cCFOP <= "6125") .Or. (cCFOP >= "6651" .And. cCFOP <= "6656") // Vendas
		cNumCFOP	:= "13"
	Case (cCFOP >= "6151" .And. cCFOP <= "6156") .Or. (cCFOP == "6658") .Or. (cCFOP == "6659") // Transferências
		cNumCFOP	:= "14"
	Case (cCFOP >= "6201" .And. cCFOP <= "6210") .Or. (cCFOP >= "6660" .And. cCFOP <= "6662") // Devoluções
		cNumCFOP	:= "15"
	Case (cCFOP >= "6251" .And. cCFOP <= "6258")												// Energia Elétrica
		cNumCFOP	:= "16"
	Case (cCFOP >= "6301" .And. cCFOP <= "6307")												// Serviço de Comunicação
		cNumCFOP	:= "17"
	Case (cCFOP >= "6351" .And. cCFOP <= "6357") .Or. (cCFOP == "6359")						// Serviço de Transporte
		cNumCFOP	:= "18"
	Case (cCFOP >= "6401" .And. cCFOP <= "6415")												// Regime Substituição Trib.
		cNumCFOP	:= "19"
	Case (cCFOP == "6657")	 																	// Remessa Combus. ou Lubrif.
		cNumCFOP	:= "35"
	Case (cCFOP == "6663") .Or. (cCFOP == "6666")												// Remessa Combus. ou Lubrif. Arm.
		cNumCFOP	:= "36"
	Case (cCFOP >= "6664" .And. cCFOP >= "6665")												// Retorno Combus. ou Lubrif. Arm.
		cNumCFOP	:= "37"
	Case (cCFOP >= "6501" .And. cCFOP <= "6503")												// Fim específico Exportação
		cNumCFOP	:= "20"
	Case (cCFOP >= "6551" .And. cCFOP <= "6555")												// Ativo Imobilizado
		cNumCFOP	:= "21"
	Case (cCFOP >= "6556" .And. cCFOP <= "6557") 												// Material de Consumo
		cNumCFOP	:= "42"
	Case (cCFOP == "6603")																		// Créditos e Ressarc. de ICMS
		cNumCFOP	:= "22"
	Case (cCFOP == "6933")																		// Prest. de Serv. Tributado pelo ISSQN
		cNumCFOP	:= "40"
	Case (cCFOP == "6949") .Or. (cCFOP >= "6901" .And. cCFOP <= "6932") 						// Outras Saídas
		cNumCFOP	:= "23"
	Case (cCFOP >= "7101" .And. cCFOP <= "7127") .Or. (cCFOP == "7651") .Or. (cCFOP == "7654") // Vendas
		cNumCFOP	:= "24"
	Case (cCFOP >= "7201" .And. cCFOP <= "7211")												// Devoluções
		cNumCFOP	:= "25"
	Case (cCFOP == "7251")																		// Energia Elétrica
		cNumCFOP	:= "26"
	Case (cCFOP == "7301")																		// Serviço de Comunicação
		cNumCFOP	:= "27"
	Case (cCFOP == "7358")																		// Serviço de Transporte
		cNumCFOP	:= "28"
	Case (cCFOP == "7501")																		// Fim específico Exportação
		cNumCFOP	:= "29"
	Case (cCFOP >= "7551" .And. cCFOP <= "7553")												// Ativo Imobilizado
		cNumCFOP	:= "30"
	Case (cCFOP == "7556") 																		// Material de Consumo
		cNumCFOP	:= "43"
	Case (cCFOP == "7930") .Or. (cCFOP == "7949") 												// Outras Saídas
		cNumCFOP	:= "31"
	Case (cCFOP == "5606")																		// Utiliz. saldo credor de ICMS para extinção por compensação de débitos fiscais
		cNumCFOP	:= "44"
EndCase

Return(cNumCFOP)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocalizaUF  ºAutor  ³Luciana P. Munhoz   º Data ³ 07/02/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Localiza o Código refente á Unidade de Federação posicionada. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GIAMTO                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/         
Function LocalizaUF(cUF)
Local cNumUF	:= ""

Do Case
	Case cUF == "AC"  	//Acre
		cNumUF	:= "01"
	Case cUF == "AL"	//Alagoas
		cNumUF	:= "02"
	Case cUF == "AP" 	//Amapá
		cNumUF	:= "03"
	Case cUF == "AM"	//Amazonas
		cNumUF	:= "04"
	Case cUF == "BA" 	//Bahia
		cNumUF	:= "05"
	Case cUF == "CE"	//Ceará
		cNumUF	:= "06"
	Case cUF == "DF"	//Distrito Federal
		cNumUF	:= "07"
	Case cUF == "ES"	//Espírito Santo
		cNumUF	:= "08"
	Case cUF == "GO"	//Goiás
		cNumUF	:= "10"
	Case cUF == "MA"   	//Maranhão
		cNumUF	:= "12"
	Case cUF == "MT"	//Mato Grosso
		cNumUF	:= "13"
	Case cUF == "MG"	//Minas Gerais
		cNumUF	:= "14"
	Case cUF == "PA"	//Pará
		cNumUF	:= "15"
	Case cUF == "PB"	//Paraíba
		cNumUF	:= "16"
	Case cUF == "PR"	//Paraná
		cNumUF	:= "17"
	Case cUF == "PE"	//Pernambuco
		cNumUF	:= "18"
	Case cUF == "PI"	//Piauí
		cNumUF	:= "19"
	Case cUF == "RN"	//Rio Grande do Norte
		cNumUF	:= "20"
	Case cUF == "RS"	//Rio Grande do Sul
		cNumUF	:= "21"
	Case cUF == "RJ"	//Rio de Janeiro
		cNumUF	:= "22"
	Case cUF == "RO"	//Rondônia
		cNumUF	:= "23"
	Case cUF == "RR"	//Rorâima
		cNumUF	:= "24"
	Case cUF == "SC"	//Santa Catarina
		cNumUF	:= "25"
	Case cUF == "SP"	//São Paulo
		cNumUF	:= "26"
	Case cUF == "SE"	//Sergipe
		cNumUF	:= "27"
	Case cUF == "MS"	//Mato Grosso do Sul
		cNumUF	:= "28"
	Case cUF == "TO"	//Tocantins
		cNumUF	:= "29"
	Case cUF == "EX"	//Exterior
		cNumUF	:= "90"
EndCase

Return(cNumUF)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GIAMTODel   ºAutor  ³Luciana P. Munhoz   º Data ³ 07/02/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GIAMTO                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/         
Function GIAMTODel(aDelArqs)
	Local aAreaDel := GetArea()
	Local nI := 0
	
	For nI:= 1 To Len(aDelArqs)
		If File(aDelArqs[nI,1]+GetDBExtension())
			dbSelectArea(aDelArqs[ni,2])
			dbCloseArea()
			Ferase(aDelArqs[nI,1]+GetDBExtension())
			Ferase(aDelArqs[nI,1]+OrdBagExt())
		Endif
	Next

	RestArea(aAreaDel)

Return

Static Function ValidPar(dDtInicial, dDtFinal)
Local lRet := .T.

Do Case
	Case dDtInicial <>  Stod(aCfp[4][05])
		lRet := .F.
		MsgInfo(STR0064,STR0065)  //"Inconsistencia nas datas."###"Arquivo não gerado.")

	Case dDtFinal <>  Stod(aCfp[4][04])
		lRet := .F.
		MsgInfo(STR0064,STR0065)  //"Inconsistencia nas datas."###"Arquivo não gerado.")

	Case (Stod(aCfp[4][03]) - Stod(aCfp[4][06]) ) <> 1
		lRet := .F.
		MsgInfo(STR0064,STR0065)  //"Inconsistencia nas datas."###"Arquivo não gerado.")

	OtherWise
		lRet := .T.
EndCase

Return(lRet)
