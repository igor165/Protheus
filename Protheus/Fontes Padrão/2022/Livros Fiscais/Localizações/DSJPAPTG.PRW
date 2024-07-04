#INCLUDE "DSJPAPTG.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DSJPAPTG  ³ Autor ³ Gustavo G. Rueda       ³ Data ³22/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Relatorio para demonstrar uma relação de clientes que deverá ³±±
±±³			 ³ ser entregue quando há reembolso do saldo a crédito do IVA  ³±±
±±³			 ³ apurado no período                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³08/07/15³PCREQ-4256³Se elimina la funcion AjustaSX1() que  ³±±
±±³            ³        ³          ³hace modificacion a SX1 por motivo de  ³±±
±±³            ³        ³          ³adecuacion a fuentes a nuevas estruc-  ³±±
±±³            ³        ³          ³turas SX para Version 12.              ³±±
±±³M.Camargo   ³09/11/15³PCREQ-4262³Merge v12.1.8                          ³±±
±±³  Marco A.  ³27/12/16³SERINN001 ³Se aplica CTREE para evitar la creacion³±±
±±³            ³        ³-535      ³de tablas temporales de manera fisica  ³±±
±±³            ³        ³          ³en system.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DSJPAPTG

	Local oReport	:= Nil
	Local cPerg		:= "DSJPPT"
	Local nMVLIMSJP	:= GetNewPar("MV_LIMSJP", 1000)

	oReport := ReportDef(cPerg, nMVLIMSJP)
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
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef(cPerg, nMVLIMSJP)

	Local aOrdem	:= {STR0001}	//"Nr. Ident. Fiscal"
	Local oReport	:= Nil     
	Local oContr	:= Nil
	Local oMov		:= Nil
	Local oInf		:= Nil
	Local oTotal	:= Nil
	Local cDesc		:= ""

	cDesc += STR0002 //"A Relação de sujeitos passivos deverá ser entregue quando há reembolso do saldo a crédito do IVA apurado no período. Caso não exista esse pedido, não é necessária a sua geração. Embasamento legal: alínea c) do nº 1 do D. N. Nº 53/2005 de 15/12."

	//Componente de impressao
	oReport := TReport():New("DSJPAPTG", OemToAnsi(STR0003), cPerg, {|oReport| ReportPrint(oReport, nMVLIMSJP)}, cDesc)	//"RELAÇÃO DOS SUJEITOS PASSIVOS A QUE RESPEITAM AS REGULARIZAÇÕES"
	oReport:SetTotalInLine(.F.)
	oReport:SetPortrait(.T.)

	Pergunte(oReport:uParam, .F.)       

	//Secao 1 - Contribuinte
	oContr := TRSection():New(oReport,OemToAnsi(STR0004),{"SM0"},aOrdem,,)	//"Informações sobre o contribuinte"
	oContr:SetLineStyle()
	TRCell():New(oContr, "M0_CGC"	, "SM0", OemToAnsi(STR0005), "@R 999.999.999"	, 040, , ) //"NIF"
	TRCell():New(oContr, "cPeriodo"	, "SM0", OemToAnsi(STR0006), 					, 040, , ) //"Período de Imposto"

	//Secao 2 - Regularização a favor do do sujeito passivo - Operações efetuadas com sujeitos passivos nacionais
	oMov := TRSection():New(oReport,OemToAnsi(STR0007),{"TMP"},aOrdem,) //"Operações efetuadas com clientes nacionais"
	oMov:SetTotalInLine(.F.)
	TRCell():New(oMov, "TMP_SEQ"	, "TMP", STR0008, "@!"				 		, 05, , ) //"Linha"
	TRCell():New(oMov, "TMP_NIF"	, "TMP", STR0009, "@!"		   		 		, 20, , ) //"Nr. Ident. Fiscal"
	TRCell():New(oMov, "TMP_ANO"	, "TMP", STR0010, "@!"				 		, 04, , ) //"Ano"
	TRCell():New(oMov, "TMP_MES"	, "TMP", STR0011, "@!"						, 03, , ) //"Mes"
	TRCell():New(oMov, "TMP_BSREG"	, "TMP", STR0012, "@E 999,999,999,999.99"	, 18, , ) //"Base regularização"
	TRCell():New(oMov, "TMP_VLR"	, "TMP", STR0013, "@E 999,999,999.99"		, 14, , ) //"IVA regularizado"

	//Secao 3 - Regularização a favor do do sujeito passivo - Regularizações de impostos inferiores a 1.000 euros
	oInf := TRSection():New(oReport, OemToAnsi(STR0014), {"SM0"}, aOrdem, , )	//"Regularizações de impostos inferiores a 1.000 euros"
	oInf:SetLineStyle()
	TRCell():New(oInf, "nInfB", "SM0", OemToAnsi(STR0015), "@E 999,999,999,999.99"	, 020, , ) //"Base regularização"
	TRCell():New(oInf, "nInfV", "SM0", OemToAnsi(STR0016), "@E 999,999,999.99"		, 020, , ) //"IVA regularizado"

	//Secao 4 - Regularização a favor do do sujeito passivo - Totalizador
	oTotal	:= TRSection():New(oReport, OemToAnsi(STR0017), {"SM0"}, aOrdem, , )	//"Total"
	oTotal:SetLineStyle()
	TRCell():New(oTotal, "nTotalB", "SM0", OemToAnsi(STR0015), "@E 999,999,999,999.99", 020, , ) //"Base regularização"
	TRCell():New(oTotal, "nTotalV", "SM0", OemToAnsi(STR0016), "@E 999,999,999,999.99", 020, , ) //"IVA regularizado"

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Gustavo G. Rueda      ³ Data ³22/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que gera o relatorio pre-definido                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oReport - Objeto TReport                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport, nMVLIMSJP)

	Local oContr	:= oReport:Section(1)
	Local oMov		:= oReport:Section(2)
	Local oInf		:= oReport:Section(3)
	Local oTotal	:= oReport:Section(4)
	Local cPeriodo	:= FormDate(MV_PAR01) + " a " + FormDate(MV_PAR02)
	Local cCondicao	:= "SM0->M0_CODFIL == '" + cFilAnt + "' .And. SM0->M0_CODIGO == '" + cEmpAnt + "'"
	Local lGerou	:= .F.
	Local nInfB		:= 0
	Local nInfV		:= 0
	Local nTotalB	:= 0
	Local nTotalV	:= 0
	
	Private oTmpTable := Nil

	Default nMVLIMSJP := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)
	MakeAdvplExpr(oReport:uParam)

	//Monta e alimenta o arquivo de trabalho
	MontSJP(1, oReport, .T., MV_PAR01, MV_PAR02)

	dbSelectArea("TMP")
	oReport:SetMeter(TMP->(LastRec()))

	oContr:SetFilter(cCondicao)
	oContr:Cell("cPeriodo"):SetBlock({|| cPeriodo }) 
	oContr:Init()
	oContr:Print()
	oContr:Finish()

	lGerou := .F.
	oReport:ThinLine()
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0018) //"Regularização a favor do do sujeito passivo"
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0019) //"Operações efetuadas com sujeitos passivos nacionais"
	oReport:ThinLine()
	oMov:Init()
	
	TMP->(dbGoTop())
	Do While !oReport:Cancel() .And. !TMP->(Eof())

		If oReport:Cancel()
			Exit
		EndIf

		oMov:IncMeter()

		//Inferior a 1000 entra em um quadro especifico
		If TMP->TMP_VLR < nMVLIMSJP
			nInfB += TMP->TMP_BSREG
			nInfV += TMP->TMP_VLR
		Else
			oMov:PrintLine()
			lGerou := .T.
		EndIf
		nTotalB	+= TMP->TMP_BSREG
		nTotalV	+= TMP->TMP_VLR

		TMP->(dbSkip())
	Enddo
	oMov:Finish()

	If !lGerou
		oReport:PrintText(STR0020)	//"*** Sem informação ***"
	EndIf

	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0021)	//"Regularizações de impostos inferiores a 1.000 euros"
	oReport:ThinLine()
	oInf:SetFilter(cCondicao)
	oInf:Cell("nInfB"):SetBlock({|| nInfB }) 
	oInf:Cell("nInfV"):SetBlock({|| nInfV }) 
	oInf:Init()
	oInf:Print()
	oInf:Finish()

	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0017)	//"Total"
	oReport:ThinLine()
	oTotal:SetFilter(cCondicao)
	oTotal:Cell("nTotalB"):SetBlock({|| nTotalB }) 
	oTotal:Cell("nTotalV"):SetBlock({|| nTotalV }) 
	oTotal:Init()
	oTotal:Print()
	oTotal:Finish()
	
	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MontSJP   ³ Autor ³ Gustavo G. Rueda      ³ Data ³22/05/2008³±±
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
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MontSJP(nOpc, oReport, lRelat, dDataDe, dDataAte)
	
	Local cAls		:= GetNextAlias()
	Local nTam		:= 0
	Local aStr		:= {}
	Local aOrdem	:= {}

	If nOpc == 1
	
		aAdd(aStr,{"TMP_SEQ"	, "C", 005	, 0})
		nTam :=	TamSx3("A1_CGC")[1]
		aAdd(aStr,{"TMP_NIF"	, "C", nTam	, 0})
		aAdd(aStr,{"TMP_ANO"	, "C", 004	, 0})
		aAdd(aStr,{"TMP_MES"	, "C", 002	, 0})
		aAdd(aStr,{"TMP_BSREG"	, "N", 018	, 2})	
		aAdd(aStr,{"TMP_VLR"	, "N", 018	, 2})
		
		aOrdem := {"TMP_NIF", "TMP_ANO", "TMP_MES"}
		
		oTmpTable := FWTemporaryTable():New("TMP")
		oTmpTable:SetFields(aStr)
		oTmpTable:AddIndex("IN1", aOrdem)
		
		oTmpTable:Create()

		BeginSql Alias cAls

			COLUMN F3_EMISSAO AS DATE
	
			SELECT 	A1_CGC, F3_EMISSAO, F3_BASIMP1+F3_BASIMP3+F3_BASIMP4+F3_BASIMP5+F3_BASIMP6 BASIMP,
			F3_VALIMP1+F3_VALIMP3+F3_VALIMP4+F3_VALIMP5+F3_VALIMP6 VALIMP
	
			FROM %table:SF3% SF3, %table:SA1% SA1
	
			WHERE 	SF3.%NotDel%          		        AND
			SA1.%NotDel%          		        		AND
			SF3.F3_FILIAL  		=  	%xFilial:SF3% 		AND
			SF3.F3_EMISSAO 		>= 	%Exp:Dtos(dDataDe)% AND 	//Deve ser pela emissao e nao pela data de entrada, conforme exigencia do relatorio(coluna 2)
			SF3.F3_EMISSAO 		<= 	%Exp:Dtos(dDataAte)% AND
			SF3.F3_TIPOMOV		=	'V' 				AND
			SF3.F3_DTCANC		=	' '					AND
			SUBSTRING(SF3.F3_ESPECIE,1,2)	IN('NC')	AND		//Notas de crédito ou Devoluca (em localizacoes a devolucao eh feita atraves de uma nota de credito)
			SA1.A1_FILIAL	  	=  	%xFilial:SA1% 		AND
			SA1.A1_COD   	  	= 	SF3.F3_CLIEFOR 		AND
			SA1.A1_LOJA    		=   SF3.F3_LOJA			AND
			SA1.A1_EST			NOT IN('98','99')		AND		//98=INTRACOMUNITARIO/99=EXTRACOMUNITARIO - SOMENTE OS NACIONAIS
			SF3.F3_VALIMP1+SF3.F3_VALIMP3+SF3.F3_VALIMP4+SF3.F3_VALIMP5+SF3.F3_VALIMP6		>	0
	
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

			If TMP->(dbSeek(PadR(aRetDig((cAls)->A1_CGC,.F.),TamSx3("A1_CGC")[1])+StrZero(Year((cAls)->F3_EMISSAO),4)+StrZero(Month((cAls)->F3_EMISSAO),2)))
				RecLock("TMP",.F.)
			Else
				RecLock("TMP",.T.)
				TMP->TMP_SEQ	:=	StrZero(Val(TMP->TMP_SEQ) + 1, 5)
				TMP->TMP_NIF	:=	PadR(aRetDig((cAls)->A1_CGC,.F.), TamSx3("A1_CGC")[1])
				TMP->TMP_ANO	:=	StrZero(Year((cAls)->F3_EMISSAO), 4)
				TMP->TMP_MES	:=	StrZero(Month((cAls)->F3_EMISSAO), 2)
			EndIf
			TMP->TMP_BSREG	+= (cAls)->BASIMP
			TMP->TMP_VLR	+= (cAls)->VALIMP
			MsUnLock()
			FkCommit()	

			(cAls)->(dbSkip())
		End
		(cAls)->(dbCloseArea())
	EndIf
	
Return
