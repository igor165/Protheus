#INCLUDE "DTRANSIN.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DTRANSIN  ³ Autor ³ Gustavo G. Rueda       ³ Data ³22/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Relatorio para demonstrar uma relação de clientes pertencen- ³±±
±±³			 ³ tes a comunidade européia. A1_EST=="98" (INTRACOMUNITARIO)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR ³ DATA   ³   BOPS  ³  MOTIVO DA ALTERACAO                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   Marco A.  ³27/12/16³SERINN001³Se aplica CTREE para evitar la creacion³±±
±±³             ³        ³-536     ³de tablas temporales de manera fisica  ³±±
±±³             ³        ³         ³en system.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DTRANSIN()

	Local oReport	:= Nil
	Local cPerg		:= "DTRANS"

	oReport := ReportDef(cPerg)
	oReport:PrintDialog()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Gustavo G. Rueda      ³ Data ³22/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que monta todas as secoes do relatorio               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³oReport - Objeto TReport                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPerg - Nome do grupo de perguntas                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef(cPerg)

	Local aOrdem 	:= {STR0001}	//"País destino + Prefixo + NIF"
	Local oReport	:= Nil      
	Local oContr	:= Nil
	Local oMov		:= Nil
	Local oVlr1		:= Nil
	Local oVlr2		:= Nil
	Local oVlr3		:= Nil
	Local cDesc		:= ""
	Local oTotPag	:= Nil

	cDesc += STR0002 //"Tem como objetivo apresentar uma relação de operações/prestações entre o contribuintes e os clientes pertencentes a comunidade européia."

	//Componente de impressao
	oReport := TReport():New("DTRANSIN", OemToAnsi(STR0003), cPerg, {|oReport| ReportPrint(oReport)}, cDesc) //"TRANSMISSÕES INTRACOMUNITÁRIAS E OPERAÇÕES ASSIMILADAS"
	oReport:SetTotalInLine(.F.)
	oReport:SetPortrait(.T.)

	Pergunte(oReport:uParam,.F.)

	//Secao 1 - Contribuinte
	oContr := TRSection():New(oReport, OemToAnsi(STR0004), {"SM0"}, aOrdem, , )	//"Informações sobre o contribuinte"
	oContr:SetLineStyle()
	TRCell():New(oContr, "M0_CGC"		, "SM0", OemToAnsi(STR0005), "@R 999.999.999"	, 069, , ) //"NIF"
	TRCell():New(oContr, "cPeriodo"		, "SM0", OemToAnsi(STR0006), 					, 040, , ) //"Período de Imposto"
	TRCell():New(oContr, "cNome"		, "SM0", OemToAnsi(STR0007), 					, 050, , ) //"Nome/Designação social"
	TRCell():New(oContr, "cTelefone"	, "SM0", OemToAnsi(STR0008), 					, 040, , ) //"Telefone"

	//Secao 2 - Relacao de transmissoes intracomunitarias e operacoes assimiladas - Operações/prestações efetuadas
	oMov := TRSection():New(oReport, OemToAnsi(STR0009), {"TMP"}, aOrdem, , )	//"Operações/prestações efetuadas."
	oMov:SetTotalInLine(.F.)
	TRCell():New(oMov, "TMP_PAIS"	, "TMP", STR0010, "@!"					, 05					, , ) //"(1)País destino"
	TRCell():New(oMov, "TMP_PREF"	, "TMP", STR0011, "@!"					, 05					, , ) //"(2)Prefixo"
	TRCell():New(oMov, "TMP_NIF"	, "TMP", STR0012, "@!"					, TamSX3("A1_CGC")[01]	, , ) //"(3)NIF"
	TRCell():New(oMov, "TMP_VLR"	, "TMP", STR0013, "@E 999,999,999.99"	, 14					, , ) //"(4)Valor"
	TRCell():New(oMov, "TMP_TPOPER"	, "TMP", STR0014, "@!"					, 05					, , ) //"(5)Tipo da Operação"

	oTotPag	:= TRFunction():New(oMov:Cell("TMP_VLR"), /* cID */, "SUM", /*oBreak*/, STR0015, "@E 999,999,999,999.99", /*uFormula*/, /*lEndSection*/, .F., .T.) //"Soma desta página"
	oTotPag:ResetPage()

	//Secao 3 - Relacao de transmissoes intracomunitarias e operacoes assimiladas - Soma(Coluna 5 com 1)
	oVlr1 := TRSection():New(oReport, OemToAnsi(STR0016), {"SM0"}, aOrdem, , ) //"(10)Soma(Coluna 5 com 1)"
	oVlr1:SetLineStyle()
	TRCell():New(oVlr1, "nVlr1", "SM0", OemToAnsi(STR0017), "@E 999,999,999,999.99", 030, , ) //"(10)SOMA(Apenas dos valores que respeitam as operações tipificadas na coluna 5 com 1)"

	//Secao 4 - Relacao de transmissoes intracomunitarias e operacoes assimiladas - Soma(Coluna 5 com 1)
	oVlr2 := TRSection():New(oReport, OemToAnsi(STR0018), {"SM0"}, aOrdem, , )	//"(11)Total(Vendas de meios de transporte)"
	oVlr2:SetLineStyle()
	TRCell():New(oVlr2,"nVlr2", "SM0", OemToAnsi(STR0019), "@E 999,999,999,999.99", 030, , ) //"(11)Total das vendas de meios de transporte novos a particulares e equiparados de outros estados membros"

	//Secao 5 - Relacao de transmissoes intracomunitarias e operacoes assimiladas - Soma(Coluna 5 com 1)
	oVlr3 := TRSection():New(oReport, OemToAnsi(STR0020), {"SM0"}, aOrdem, , ) //"(19)Total(10 + 11)"
	oVlr3:SetLineStyle()
	TRCell():New(oVlr3, "nVlr3", "SM0", OemToAnsi(STR0020), "@E 999,999,999,999.99", 090, , ) //"(19)Total(10 + 11)"

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Gustavo G. Rueda     ³ Data ³22/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que gera o relatorio pre-definido                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oReport - Objeto TReport                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport)

	Local oContr	:= oReport:Section(1)
	Local oMov		:= oReport:Section(2)
	Local oVlr1		:= oReport:Section(3)
	Local oVlr2		:= oReport:Section(4)
	Local oVlr3		:= oReport:Section(5)
	Local cPeriodo	:= FormDate(MV_PAR01) + " a " + FormDate(MV_PAR02)
	Local cNome		:= AllTrim(SM0->M0_NOMECOM)
	Local cTelefone	:= SM0->M0_TEL
	Local cCondicao	:= "SM0->M0_CODFIL == '" + cFilAnt + "' .And. SM0->M0_CODIGO == '" + cEmpAnt + "'"
	Local lGerou	:= .F.
	Local nVlr1		:= 0
	Local nVlr2		:= 0
	Local nVlr3		:= 0
	
	Private oTmpTable := Nil

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)
	oContr:SetFilter(cCondicao)
	oVlr1:SetFilter(cCondicao)
	oVlr2:SetFilter(cCondicao)
	oVlr3:SetFilter(cCondicao)
	MakeAdvplExpr(oReport:uParam)

	//Monta e alimenta o arquivo de trabalho
	MontTR(1, oReport, .T., MV_PAR01, MV_PAR02)

	dbSelectArea("TMP")
	oReport:SetMeter(TMP->(LastRec()))

	oContr:Cell("cPeriodo"):SetBlock({|| cPeriodo }) 
	oContr:Cell("cNome"):SetBlock({|| cNome }) 
	oContr:Cell("cTelefone"):SetBlock({|| cTelefone }) 
	oContr:Init()
	oContr:Print()
	oContr:Finish()

	lGerou := .F.
	oReport:ThinLine()
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0021)	//"Operações/prestações efetuadas."
	oReport:ThinLine()
	oMov:Init()
	TMP->(dbGoTop())
	Do While !oReport:Cancel() .And. !TMP->(Eof())

		If oReport:Cancel()
			Exit
		EndIf

		oMov:IncMeter()

		If TMP->TMP_TPOPER == 1 .And. TMP->TMP_VLRTR == 0
			nVlr1 += TMP->TMP_VLR
		EndIf
		nVlr2 += TMP->TMP_VLRTR

		If TMP->TMP_VLRTR == 0
			oMov:PrintLine()
		EndIf
		lGerou := .T.

		TMP->(dbSkip())
	Enddo

	If !lGerou
		oReport:PrintText(STR0022)	//"*** Sem informação ***"
	EndIf
	oMov:Finish()

	oReport:SkipLine()
	oReport:SkipLine()
	oReport:ThinLine()
	oVlr1:Cell("nVlr1"):SetBlock({|| nVlr1}) 
	oVlr1:Init()
	oVlr1:Print()
	oVlr1:Finish()

	oVlr2:Cell("nVlr2"):SetBlock({|| nVlr2}) 
	oVlr2:Init()
	oVlr2:Print()
	oVlr2:Finish()

	nVlr3 := nVlr1 + nVlr2
	oVlr3:Cell("nVlr3"):SetBlock({|| nVlr3}) 
	oVlr3:Init()
	oVlr3:Print()
	oVlr3:Finish()

	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MontTR    ³ Autor ³ Gustavo G. Rueda      ³ Data ³22/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que monta e alimenta o arquivo de trabalho com base  ³±±
±±³          ³ no SF3.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc - 1=Cria e alimenta, 2=Apaga                           ³±±
±±³          ³oReport - Objeto TReport                                    ³±±
±±³          ³lRelat - Flag que indica se a chamada da funcao e do relato-³±±
±±³          ³ rio ou nao.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MontTR(nOpc, oReport, lRelat, dDataDe, dDataAte)

	Local cAls			:= GetNextAlias()
	Local nTam			:= 0
	Local aStr			:= {}
	Local cDE			:= ""
	Local cMVGRCMP11	:= GetNewPar("MV_GRCMP11","")
	Local cChave		:= ""
	Local cChave2		:= ""
	Local cMVRELPAIS	:= GetNewPar("MV_RELPAIS", "072=AT;876=BE;087=BE;023=DE;232=DK;301=EL;245=ES;271=FI;275=FR;628=GB;375=IE;386=IT;445=LU;764=SE")
	Local aMVRELPAIS	:= {}
	Local cPais			:= ""
	Local aOrdem		:= {}

	If nOpc == 1
		
		nTam :=	TamSx3("A1_PAIS")[1]
		aAdd(aStr, {"TMP_PAIS"		, "C", nTam	, 0})
		aAdd(aStr, {"TMP_PREF"		, "C", 002	, 0})
		nTam :=	TamSx3("A1_CGC")[1]
		aAdd(aStr, {"TMP_NIF"		, "C", nTam	, 0})
		aAdd(aStr, {"TMP_VLR"		, "N", 018	, 2})	
		aAdd(aStr, {"TMP_VLRTR"		, "N", 018	, 2})	
		aAdd(aStr, {"TMP_TPOPER"	, "N", 001	, 0})
		
		aOrdem := {"TMP_PAIS", "TMP_PREF", "TMP_NIF"}
		
		oTmpTable := FWTemporaryTable():New("TMP")
		oTmpTable:SetFields(aStr)
		oTmpTable:AddIndex("IN1", aOrdem)
		oTmpTable:Create()
		
		aMVRELPAIS	:=	LoadPais(cMVRELPAIS, @cPais)

		BeginSql Alias cAls

			//COLUMN D2_EMISSAO AS DATE
	
			//NOTA FISCAL NORMAL (QUE NAO UTILIZA FORNECEDOR)
			SELECT 	1 TPOPER, A1_CGC CGC, A1_PAIS PAIS, B1_GRUPO, F2_CLIENTE, F2_LOJA, F2_DOC, F2_SERIE, F2_VALBRUT
	
			FROM %table:SF2% SF2, %table:SA1% SA1, %table:SD2% SD2, %table:SB1% SB1
	
			WHERE 	SF2.%NotDel%          		AND				
			SA1.%NotDel%          		        AND
			SD2.%NotDel%          		        AND
			SB1.%NotDel%          		        AND
	
			SF2.F2_FILIAL  	=  %xFilial:SF2% 	AND
			SF2.F2_EMISSAO 	>= %Exp:Dtos(dDataDe)% AND 
			SF2.F2_EMISSAO 	<= %Exp:Dtos(dDataAte)% AND 
			SF2.F2_TIPO		<>	'B'				AND	//QUANDO NAO UTILIZAR FORNECEDOR
	
			SA1.A1_FILIAL  	=  %xFilial:SA1% 	AND
			SA1.A1_COD     	= 	SF2.F2_CLIENTE 	AND
			SA1.A1_LOJA    	=   SF2.F2_LOJA		AND				
			SA1.A1_EST		IN('98')			AND
	
			SD2.D2_FILIAL	=	%xFilial:SD2% 	AND
			SD2.D2_DOC		=	SF2.F2_DOC		AND
			SD2.D2_SERIE	=	SF2.F2_SERIE	AND
			SD2.D2_CLIENTE	=	SF2.F2_CLIENTE	AND
			SD2.D2_LOJA		=	SF2.F2_LOJA		AND
			SD2.D2_IDENTB6	=	' '				AND
	
			SB1.B1_FILIAL	=	%xFilial:SB1% 	AND
			SB1.B1_COD		=	SD2.D2_COD		AND
	
			//TEM QUE CONSTAR NOS LIVROS FISCAIS
			(SELECT COUNT(0) FROM %table:SF3% SF3 WHERE SF3.%NotDel% AND SF3.F3_FILIAL = %xFilial:SF3% AND 
			SF3.F3_NFISCAL = SF2.F2_DOC AND SF3.F3_SERIE = SF2.F2_SERIE AND SF3.F3_CLIEFOR = SF2.F2_CLIENTE AND 
			SF3.F3_LOJA = SF2.F2_LOJA AND SF3.F3_TIPOMOV='V')>0
	
			UNION
	
			//NOTA FISCAL UTILIZANDO FORNECEDOR
			SELECT 	1 TPOPER, A2_CGC CGC, A2_PAIS PAIS, B1_GRUPO, F2_CLIENTE, F2_LOJA, F2_DOC, F2_SERIE, F2_VALBRUT
	
			FROM %table:SF2% SF2, %table:SD2% SD2, %table:SA2% SA2, %table:SB1% SB1
	
			WHERE 	SF2.%NotDel%          		AND
			SA2.%NotDel%          		        AND
			SD2.%NotDel%          		        AND
			SB1.%NotDel%          		        AND
	
			SF2.F2_FILIAL  	=  %xFilial:SF2% 	AND
			SF2.F2_EMISSAO 	>= %Exp:Dtos(dDataDe)% AND 
			SF2.F2_EMISSAO 	<= %Exp:Dtos(dDataAte)% AND 
			SF2.F2_TIPO		=	'B'				AND	//QUANDO UTILIZAR FORNECEDOR
	
			SA2.A2_FILIAL  	=  %xFilial:SA2% 	AND
			SA2.A2_COD     	= 	SF2.F2_CLIENTE 	AND
			SA2.A2_LOJA    	=   SF2.F2_LOJA		AND				
			SA2.A2_EST		IN('98')			AND
	
			SD2.D2_FILIAL	=	%xFilial:SD2% 	AND
			SD2.D2_DOC		=	SF2.F2_DOC		AND
			SD2.D2_SERIE	=	SF2.F2_SERIE	AND
			SD2.D2_CLIENTE	=	SF2.F2_CLIENTE	AND
			SD2.D2_LOJA		=	SF2.F2_LOJA		AND
			SD2.D2_IDENTB6	=	' '				AND
	
			SB1.B1_FILIAL	=	%xFilial:SB1% 	AND
			SB1.B1_COD		=	SD2.D2_COD		AND
	
			//TEM QUE CONSTAR NOS LIVROS FISCAIS
			(SELECT COUNT(0) FROM %table:SF3% SF3 WHERE SF3.%NotDel% AND SF3.F3_FILIAL = %xFilial:SF3% AND 
			SF3.F3_NFISCAL = SF2.F2_DOC AND SF3.F3_SERIE = SF2.F2_SERIE AND SF3.F3_CLIEFOR = SF2.F2_CLIENTE AND 
			SF3.F3_LOJA = SF2.F2_LOJA AND SF3.F3_TIPOMOV='V')>0
	
			UNION
	
			//SELECT PARA IDENTIFICAR OPERACOES TRIANGULARES, D2_IDENTB6 DEVE ESTAR PREENCHIDO PARA F4_PODER3='D' E O FORNECEDOR DA SAIDA DEVE SER DIFERENTE DA NF ORIGINAL		
			SELECT 	4 TPOPER, A2_CGC CGC, A2_PAIS PAIS, B1_GRUPO, F2_CLIENTE, F2_LOJA, F2_DOC, F2_SERIE, F2_VALBRUT
	
			FROM %table:SF2% SF2, %table:SD2% SD2, %table:SA2% SA2, %table:SD1% SD1, %table:SB1% SB1
	
			WHERE 	SF2.%NotDel%          		AND
			SA2.%NotDel%          		        AND
			SD2.%NotDel%          		        AND
			SD1.%NotDel%          		        AND
			SB1.%NotDel%          		        AND
	
			SF2.F2_FILIAL  	=  	%xFilial:SF2% 	AND
			SF2.F2_EMISSAO 	>= 	%Exp:Dtos(dDataDe)% AND 
			SF2.F2_EMISSAO 	<= 	%Exp:Dtos(dDataAte)% AND
	
			SA2.A2_FILIAL  	=  %xFilial:SA2% 	AND
			SA2.A2_COD     	= 	SF2.F2_CLIENTE 	AND
			SA2.A2_LOJA    	=   SF2.F2_LOJA		AND				
			SA2.A2_EST		IN('98')			AND
	
			SD2.D2_FILIAL	=	%xFilial:SD2% 	AND
			SD2.D2_DOC		=	SF2.F2_DOC		AND
			SD2.D2_SERIE	=	SF2.F2_SERIE	AND
			SD2.D2_CLIENTE	=	SF2.F2_CLIENTE	AND
			SD2.D2_LOJA		=	SF2.F2_LOJA		AND
			SD2.D2_IDENTB6	<>	' '				AND
	
			SD1.D1_DOC		=	SD2.D2_NFORI	AND
			SD1.D1_SERIE	=	SD2.D2_SERIORI	AND
			SD1.D1_ITEM		=	SD2.D2_ITEMORI	AND
			(SD1.D1_FORNECE	<>	SD2.D2_CLIENTE	OR
			SD1.D1_LOJA		<>	SD2.D2_LOJA)	AND
	
			SB1.B1_FILIAL	=	%xFilial:SB1% 	AND
			SB1.B1_COD		=	SD2.D2_COD		AND
	
			//TEM QUE CONSTAR NOS LIVROS FISCAIS
			(SELECT COUNT(0) FROM %table:SF3% SF3 WHERE SF3.%NotDel% AND SF3.F3_FILIAL = %xFilial:SF3% AND 
			SF3.F3_NFISCAL = SF2.F2_DOC AND SF3.F3_SERIE = SF2.F2_SERIE AND SF3.F3_CLIEFOR = SF2.F2_CLIENTE AND 
			SF3.F3_LOJA = SF2.F2_LOJA AND SF3.F3_TIPOMOV = 'V') > 0
	
			ORDER BY 1

		EndSql

		TMP->(dbSetOrder(1))

		If lRelat
			oReport:SetMeter((cAls)->(LastRec()))
		EndIf

		While !(cAls)->(Eof())

			If lRelat
				oReport:IncMeter()
			EndIf

			If (nPos := aScan(aMVRELPAIS, {|aX| (cAls)->PAIS$aX[1]})) > 0
				If TMP->(dbSeek((cAls)->PAIS + aMVRELPAIS[nPos,2] + PadR(aRetDig((cAls)->CGC, .F.), TamSx3("A1_CGC")[1])))
					RecLock("TMP",.F.)
				Else
					RecLock("TMP",.T.)			
					TMP->TMP_PAIS	:= (cAls)->PAIS
					TMP->TMP_PREF	:= aMVRELPAIS[nPos,2]
					TMP->TMP_NIF	:= PadR(aRetDig((cAls)->CGC, .F.), TamSx3("A1_CGC")[1])
					TMP->TMP_TPOPER	:= (cAls)->TPOPER
				EndIf
				TMP->TMP_VLR += (cAls)->F2_VALBRUT

				//Grupo de produtos usado para identificar o conteudo a ser enviado no campo 11 - Total das vendas de 
				//	meios de transporte novos a particulares e equiparados de outros estados membros
				If !Empty(cMVGRCMP11) .And. AllTrim((cAls)->B1_GRUPO)$cMVGRCMP11
					TMP->TMP_VLRTR	+=	(cAls)->F2_VALBRUT
				EndIf

				MsUnLock()
				FkCommit()	
			EndIf
			(cAls)->(dbSkip())
		End
		(cAls)->(dbCloseArea())
	EndIf
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LoadPais  ³ Autor ³ Gustavo G. Rueda      ³ Data ³22/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao utilizada para montar um array de DEPARA para o      ³±±
±±³          ³ codigo do pais informado no campo A2_PAIS .                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aPar - Array DEPARA                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cMVRELPAIS - Conteudo do paramento MV_RELPAIS               ³±±
±±³          ³cPais - Paramentro passado por referencia para retornar uma ³±±
±±³          ³ string para montar a query.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LoadPais(cMVRELPAIS, cPais)

	Local nI	:= 1
	Local aPar	:= {}

	cMVRELPAIS := AllTrim(cMVRELPAIS)

	While nI <> 0
		aAdd(aPar,{SubStr(cMVRELPAIS, 1, 3), SubStr(cMVRELPAIS, 5, 2)})
		cPais += "'" + SubStr(cMVRELPAIS, 1, 3) + "',"

		nI := At(";", cMVRELPAIS)
		cMVRELPAIS := SubStr(cMVRELPAIS, nI + 1)
	End
	cPais := SubStr(cPais, 1, Len(cPais) - 1)

Return aPar
