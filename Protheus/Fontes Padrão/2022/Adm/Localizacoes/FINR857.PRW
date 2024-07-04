#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FINR857.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออหออออออออออหอออออออหออออออออออออออออออออออออหออออออหอออออออออออออปฑฑ
ฑฑบPrograma  บFinR857   บAutor  บMicrosiga               บ Data บ  24/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออสออออออออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     บ Demonstrativo: Rela็ใo de extratos bancแrios                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       บ SigaFin - Argentina                                            บฑฑ
ฑฑฬออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             บฑฑ
ฑฑฬออออออออออออหออออออออหออออออออออหออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ Data   บ   BOPS   บ  Motivo da Alteracao                     บฑฑ
ฑฑฬออออออออออออลออออออออลออออออออออลออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ  Marco A.  บ13/08/18บDMINA-3757บSe aplica el uso de FWTemporaryTable().   บฑฑ
ฑฑศออออออออออออสออออออออสออออออออออสออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinR857()

	Local oReport		:= Nil
	Local lTReport		:= TRepInUse()

	Private aSelFil		:= {}
	Private oTmpTabTRB	:= Nil
	Private oTmpTabQRX	:= Nil

	If !lTReport
		Help("  ",1,"FINR856R4",,STR0015,1,0) //"Fun็ใo disponํvel apenas para TReport, por favor atualizar ambiente e verifique o parametro MV_TREPORT"
		Return
	EndIf

	If Pergunte("FIR857",.T.)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Agrupar por            mv_par01 ณ
		//ณ Aglutinar movimentos   mv_par02 ณ
		//ณ Banco De               mv_par03 ณ
		//ณ Banco Ate              mv_par04 ณ
		//ณ Data De                mv_par05 ณ
		//ณ Data Ate               mv_par06 ณ
		//ณ Extrato De             mv_par07 ณ
		//ณ Extrato Ate            mv_par08 ณ
		//ณ Status                 mv_par09 ณ
		//ณ Selecionar Filial ?    mv_par10 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If MV_PAR10 == 1 .And. Len(aSelFil) <= 0
			aSelFil := AdmGetFil()
			If Len( aSelFil ) <= 0
				Return
			EndIf
		EndIf
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

	If oTmpTabTRB <> Nil 
		oTmpTabTRB:Delete()
		FreeObj(oTmpTabTRB)
		oTmpTabTRB := Nil
	EndIf

	If oTmpTabQRX <> Nil 
		oTmpTabQRX:Delete()
		FreeObj(oTmpTabQRX)
		oTmpTabQRX := Nil
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef บAutor  ณMicrosiga           บ Data ณ  24/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a estrutura de impressao do relatorio                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()

	Local oReport		:= Nil
	Local oSection1		:= Nil
	Local oSection2		:= Nil
	Local lImpAnalit	:= ( MV_PAR01 == 1 )  // Agrupado por Extrato
	Local lImpAglutin	:= ( MV_PAR02 == 1 )  // Aglutina movimentos
	Local cTitle		:= " "

	If lImpAnalit
		cTitle := OemToAnsi( STR0001 ) // "Rela็ใo De Movimentos Bancarios por Extrato"
	Else
		If lImpAglutin
			cTitle := OemToAnsi( STR0003 ) // "Rela็ใo De Movimentos Bancarios por Controle de Concilia็ใo (aglutinado)"
		Else
			cTitle := OemToAnsi( STR0002 ) // "Rela็ใo De Movimentos Bancarios por Controle de Concilia็ใo"
		EndIf
	EndIf

	DEFINE REPORT oReport NAME "FINR857" TITLE cTitle PARAMETER "FIR857" ACTION {|oReport| PrintReport(oReport)}

	DEFINE SECTION oSection1 OF oReport TITLE "Bancos" TABLES "FJE"

	DEFINE CELL NAME "FJE_FILIAL"	OF oSection1 ALIAS "FJE"          //Filial do Sistema
	DEFINE CELL NAME "BANCO"        OF oSection1 TITLE STR0007  SIZE 05 BLOCK {|| Finr857Bco(FJE->FJE_BCOCOD+FJE->FJE_BCOAGE+FJE->FJE_BCOCTA,"A6_COD") }
	DEFINE CELL NAME "AGENCIA"      OF oSection1 TITLE STR0008  SIZE 08 BLOCK {|| Finr857Bco(FJE->FJE_BCOCOD+FJE->FJE_BCOAGE+FJE->FJE_BCOCTA,"A6_AGENCIA") }
	DEFINE CELL NAME "CONTA"        OF oSection1 TITLE STR0009  SIZE 11 BLOCK {|| Finr857Bco(FJE->FJE_BCOCOD+FJE->FJE_BCOAGE+FJE->FJE_BCOCTA,"A6_NUMCON") }
	DEFINE CELL NAME "NOME"	        OF oSection1 TITLE STR0010  SIZE 30 BLOCK {|| Finr857Bco(FJE->FJE_BCOCOD+FJE->FJE_BCOAGE+FJE->FJE_BCOCTA,"A6_NOME") }
	DEFINE CELL NAME "FJE_CODEXT"	OF oSection1 ALIAS "FJE"          //Cod. Extrato
	DEFINE CELL NAME "FJE_DTEXT"	OF oSection1 ALIAS "FJE"          //Data corte
	DEFINE CELL NAME "FJE_NUMEXT"	OF oSection1 ALIAS "FJE" SIZE 15  //Num. Extrato
	DEFINE CELL NAME "FJE_SLDEXT"	OF oSection1 ALIAS "FJE" SIZE 15  //Saldo
	DEFINE CELL NAME "FJE_DTCONC"	OF oSection1 ALIAS "FJE"          //Data concil.
	DEFINE CELL NAME "FJE_ESTEXT"	OF oSection1 ALIAS "FJE" SIZE 20 BLOCK {|| Finr857Est(FJE->FJE_ESTEXT)} //Est. extrato

	If lImpAnalit
		//------------------------------------------------
		// Imprime os Movimentos Ordenados por Extrato
		//------------------------------------------------
		DEFINE SECTION oSection2 OF oSection1 TITLE "Movimentos" TABLES "TRB"

		DEFINE CELL NAME "FJF_DATMOV"	OF oSection2 ALIAS "TRB"          //Data
		DEFINE CELL NAME "FJF_CODCON"	OF oSection2 SIZE 12 ALIAS "TRB"  //Conceito
		DEFINE CELL NAME "FJF_CVALOR"	OF oSection2 Title STR0011 SIZE 15 ALIAS "TRB"  //Valor movim.
		DEFINE CELL NAME "FJF_COMPRO"	OF oSection2 SIZE 12 ALIAS "TRB"  //Comprovante
		DEFINE CELL NAME "FJG_NRCTRL" 	OF oSection2 SIZE 12 ALIAS "TRB"  //Nr Controle Conciliacao
		DEFINE CELL NAME "FJG_DATCON" 	OF oSection2 ALIAS "TRB"          //Data da Conciliacao
		DEFINE CELL NAME "E5_DOCUMEN" 	OF oSection2 SIZE 15 ALIAS "TRB"  //Doc Financeiro
		DEFINE CELL NAME "E5_DATA"  	OF oSection2 ALIAS "TRB"          //Data Financeiro
		DEFINE CELL NAME "E5_CVALOR"  	OF oSection2 Title STR0012 SIZE 15 ALIAS "TRB"  //"Vlr. Movim."
		DEFINE CELL NAME "F2_DOC"   	OF oSection2 SIZE 15 ALIAS "TRB"  //Doc Fiscal
		DEFINE CELL NAME "F2_EMISSAO"  	OF oSection2 ALIAS "TRB"          //Data Fiscal
		DEFINE CELL NAME "F2_VALFIS"  	OF oSection2 Title STR0013 SIZE 15 ALIAS "TRB"  //Valor Fiscal
	Else
		//------------------------------------------------------------------------
		// Imprime os Movimentos Ordenados pelo Numero de Controle de Conciliacao
		//------------------------------------------------------------------------
		If lImpAglutin
			//-------------------------------------------------------------
			// Valores Aglutinados pelo Numero de Controle de Conciliacao
			//-------------------------------------------------------------
			DEFINE SECTION oSection2 OF oSection1 TITLE "Movimentos" TABLES "QRX"

			DEFINE CELL NAME "FJG_DATCON" 	OF oSection2 ALIAS "QRX"          //Data da Conciliacao
			DEFINE CELL NAME "FJG_NRCTRL" 	OF oSection2 SIZE 12 ALIAS "QRX"  //Nr Controle Conciliacao
			DEFINE CELL NAME "FJF_CODCON"	OF oSection2 SIZE 12 ALIAS "QRX"  //Conceito
			DEFINE CELL NAME "FJF_DATMOV"	OF oSection2 ALIAS "QRX"          //Data
			DEFINE CELL NAME "FJF_CVALOR"	OF oSection2 Title STR0011 SIZE 15 ALIAS "QRX"  //Valor movim.
			DEFINE CELL NAME "E5_DOCUMEN" 	OF oSection2 SIZE 15 ALIAS "QRX"  //Doc Financeiro
			DEFINE CELL NAME "E5_DATA"  	OF oSection2 ALIAS "QRX"          //Data Financeiro
			DEFINE CELL NAME "E5_CVALOR"  	OF oSection2 Title STR0012 SIZE 15 ALIAS "QRX"  //"Vlr. Movim."
			DEFINE CELL NAME "F2_DOC"   	OF oSection2 SIZE 15 ALIAS "QRX"  //Doc Fiscal
			DEFINE CELL NAME "F2_EMISSAO" 	OF oSection2 ALIAS "QRX"          //Data Fiscal
			DEFINE CELL NAME "F2_VALFIS"  	OF oSection2 Title STR0013 SIZE 15 ALIAS "QRX"  //Valor Fiscal
		Else
			//---------------------------
			// Valores Nao Aglutinados
			//---------------------------
			DEFINE SECTION oSection2 OF oSection1 TITLE "Movimentos" TABLES "TRB"

			DEFINE CELL NAME "FJG_DATCON" 	OF oSection2 ALIAS "TRB"          //Data da Conciliacao
			DEFINE CELL NAME "FJG_NRCTRL" 	OF oSection2 SIZE 12 ALIAS "TRB"  //Nr Controle Conciliacao
			DEFINE CELL NAME "FJF_DATMOV"	OF oSection2 ALIAS "TRB"          //Data
			DEFINE CELL NAME "FJF_CODCON"	OF oSection2 SIZE 12 ALIAS "TRB"  //Conceito
			DEFINE CELL NAME "FJF_CVALOR"	OF oSection2 Title STR0011 SIZE 15 ALIAS "TRB"  //Valor movim.
			DEFINE CELL NAME "FJF_COMPRO"	OF oSection2 SIZE 12 ALIAS "TRB"  //Comprovante
			DEFINE CELL NAME "E5_DOCUMEN" 	OF oSection2 SIZE 15 ALIAS "TRB"  //Doc Financeiro
			DEFINE CELL NAME "E5_DATA"  	OF oSection2 ALIAS "TRB"          //Data Financeiro
			DEFINE CELL NAME "E5_CVALOR"  	OF oSection2 Title STR0012 SIZE 15 ALIAS "TRB"  //"Vlr. Movim."
			DEFINE CELL NAME "F2_DOC"   	OF oSection2 SIZE 15 ALIAS "TRB"  //Doc Fiscal
			DEFINE CELL NAME "F2_EMISSAO" 	OF oSection2 ALIAS "TRB"          //Data Fiscal
			DEFINE CELL NAME "F2_VALFIS"  	OF oSection2 Title STR0013 SIZE 15 ALIAS "TRB"  //Valor Fiscal
		EndIf
	EndIf

	oReport:SetLandScape()

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReportบAutor  ณMicrosiga          บ Data ณ  24/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtem os dados e realiza a impressใo                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrintReport(oReport)

	Local cAlias		:= GetNextAlias()
	Local cCondFil		:= ""
	Local cCondEstad	:= ""
	Local lImpAnalit	:= ( MV_PAR01 == 1 )  // Agrupado por Extrato
	Local lImpAglutin	:= ( MV_PAR02 == 1 )  // Aglutina movimentos
	Local cSectionFil	:= ""
	Local oSection1		:= oReport:Section(1)
	Local oSection2		:= oReport:Section(1):Section(1)
	Local aOrdem		:= {}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Agrupar por             mv_par01    1-Extrato / 2-Nro Controle  ณ
	//ณ Aglutinar movimentos    mv_par02    1-Sim ; 2-Nao               ณ
	//ณ Banco De                mv_par03                                ณ
	//ณ Banco Ate               mv_par04                                ณ
	//ณ Data De                 mv_par05                                ณ
	//ณ Data Ate                mv_par06                                ณ
	//ณ Extrato De              mv_par07                                ณ
	//ณ Extrato Ate             mv_par08                                ณ
	//ณ Status                  mv_par09                                ณ
	//ณ Selecionar Filial ?     mv_par10    1-Sim ; 2-Nao               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Pergunte("FIR857",.F.)

	cCondFil := GetRngFil( aSelFil , "FJE" )

	//--- Com relacao ao STATUS dos Extratos
	Do Case
		Case MV_PAR09 == 1 //Todos
		cCondEstad := "1/2/3/4"
		Case MV_PAR09 == 2 //Conciliados
		cCondEstad := "3"
		Case MV_PAR09 == 3 //Nใo conciliados
		cCondEstad := "2"
		Case MV_PAR09 == 4 //Inconsistentes
		cCondEstad := "1"
	EndCase

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Abertura do TRB ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lImpAnalit   // Agrupado por Extrato
		aOrdem := {"FJF_CODEXT", "FJF_DATMOV", "FJF_CODCON"}
	Else
		//------------------------------------------------
		// Agrupado por Numero de Controle de Conciliacao
		//------------------------------------------------
		aOrdem := {"FJF_CODEXT", "FJG_NRCTRL"}
	EndIf

	Finr857Trb(aOrdem)

	MakeAdvplExpr("FIR857")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Filtro para o Extrato ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("FJE")
	DbSetOrder(1)

	cSectionFil := "FJE->FJE_FILIAL " + cCondFil + " .AND. FJE->FJE_BCOCOD >= '" + MV_PAR03 + "' .AND. FJE->FJE_BCOCOD <= '" + MV_PAR04 + "'"
	cSectionFil += " .AND. FJE->FJE_CODEXT >= '" + MV_PAR07 + "' .AND. FJE->FJE_CODEXT <= '" + MV_PAR08 + "'"
	cSectionFil += " .AND. DtoS(FJE->FJE_DTEXT) >= '" + DtoS( MV_PAR05 ) + "' .AND. DtoS(FJE->FJE_DTEXT) <= '" + DtoS( MV_PAR06 ) + "'"
	

	oSection1:SetFilter(cSectionFil)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Agrupado por Extrato ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery := " SELECT FJF_FILIAL, FJF_CODEXT, FJF_DATMOV, FJF_CODCON, FJF_VALOR, FJF_COMPRO, FJF.R_E_C_N_O_ AS FRECNO"
	cQuery += " FROM " + RetSqlName("FJF") + " FJF "
	cQuery += " WHERE "
	cQuery += " FJF.FJF_FILIAL = '" + xFilial("FJF") + "'"
	cQuery += " AND FJF.FJF_CODEXT >= '" + MV_PAR07 + "' AND FJF.FJF_CODEXT <= '" + MV_PAR08 + "'"
	If MV_PAR09 == 1 //Todos
		cCondEstad := "'1','2','3','4'"
		cQuery += " AND FJF.FJF_ESTMOV IN (" + cCondEstad +")"
	Else
		cQuery += " AND FJF.FJF_ESTMOV IN (" + cCondEstad +")"
	EndIf	
	If !lImpAnalit
		// Somente Conciliados
		cQuery += " AND FJF.FJF_ESTMOV = '3'"
	EndIf
	cQuery += " AND FJF.D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

	TcSetField( cAlias,"FJF_DATMOV","D",8, 0)
	TcSetField( cAlias,"FJF_VALOR","N",16, 2)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Preenche o TRB ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Processa( {|lEnd| Grv857( cAlias ) },,OemToAnsi(STR0004) )    // "Gravando Temporario"

	If !lImpAnalit .And. lImpAglutin
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Processo suplemenatr para Aglutinado ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Processa( {|lEnd| Sinte857() },,OemToAnsi(STR0005) )   // "Processando Sintetico"
	EndIf

	If Select( "QRX" ) > 0
		oSection2:SetRelation( {|| FJE->FJE_CODEXT } ,"QRX" ,1 , .T. )
		oSection2:SetParentFilter({|cParam| QRX->FJF_CODEXT == cParam},{|| FJE->FJE_CODEXT })
	Else
		oSection2:SetRelation( {|| FJE->FJE_CODEXT } ,"TRB" ,1 , .T. )
		oSection2:SetParentFilter({|cParam| TRB->FJF_CODEXT == cParam},{|| FJE->FJE_CODEXT })
	EndIf

	oReport:Section(1):Print()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINR857   บAutor  ณMicrosiga           บ Data ณ  09/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtem a descricao do estado do extrato ou do movimento     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Finr857Est(cEstado)
	
	Local cRet := ""

	Default cEstado	:= ""

	Do Case
		Case cEstado == "1"
		cRet := STR0016		//"Inconsistente"
		Case cEstado == "2"
		cRet := STR0017		//"Nใo conciliado"
		Case cEstado == "3"
		cRet := STR0018		//"Conciliado"
		Case cEstado == "4"
		cRet := STR0019		//"Encerrado"
	EndCase

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINR857   บAutor  ณMicrosiga           บ Data ณ  09/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recebe o RECNO do Movimento FJF, localizo o registro de    บฑฑ
ฑฑบ          ณ Conciliacao em FJG (via Order 2 ), e retorno o conteudo    บฑฑ
ฑฑบ          ณ dos campos previamente fixados.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Finr857Ctl( nPoint, cAliasJG )

	//--- Retorno
	Local aRetor := {}

	//--- Ambiente
	Local aOrig := GetArea()

	//--- Genericas
	Local nTamRegCon := TamSX3( "FJG_REGCON" )[1]
	Local cChave     := xFilial( "FJG" ) + "FJF"
	Local cPointer   := " "
	Local cFielRet   := " "
	Local cNrCtrl    := " "
	Local xContenido := " "

	Default nPoint := 0

	If nPoint > 0
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Existe Recno registrado na FJG ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		//--- Preciso transformar o Ponteiro de FJF em caracter compativel para a chave de FJG
		cPointer := StrZero( nPoint , nTamRegCon )

		dbSelectArea( "FJG" )
		//--- FJG_FILIAL+FJG_TABCON+FJG_REGCON
		dbSetOrder( 2 )

		If dbSeek( cChave + cPointer )

			If cAliasJG == "FJG"
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Recuperacao de Dados da propria FJG ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

				// 1. FJG_NRCTRL
				cFielRet   := "FJG_NRCTRL"
				xContenido := FieldGet( FieldPos( cFielRet ) )

				Aadd( aRetor, { cFielRet , xContenido } )

				// 2. FJG_DATCON
				cFielRet   := "FJG_DATCON"
				xContenido := FieldGet( FieldPos( cFielRet ) )

				Aadd( aRetor, { cFielRet , xContenido } )

			ElseIf cAliasJG == "SE5"
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Recuperacao de Dados de Movimentacao ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

				//--- Lendo Numero de Controle da FJG
				cNrCtrl := FJG_NRCTRL

				dbSelectArea( "FJG" )
				//--- FJG_FILIAL+FJG_NRCTRL
				dbSetOrder( 1 )
				//
				dbSeek( xFilial( "FJG" ) + cNrCtrl )

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Varredura do Numero de Controle, foco em SE5 ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				While !EOf() .And. ( FJG_FILIAL+FJG_NRCTRL == xFilial( "FJG" ) + cNrCtrl )
					If FJG_TABCON == "SE5"        //--- Alias localizado
						If !Empty( FJG_REGCON )    //--- Existe Recno ??

							nPoint := Val( FJG->FJG_REGCON )
							
							dbSelectArea( "SE5" )  // ***** Estou no Alias *****
							dbGoTo( nPoint )

							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ Recuperacao de Dados ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

							// 1. E5_DOCUMEN
							cFielRet   := "E5_DOCUMEN"
							xContenido := AllTrim( FieldGet( FieldPos( cFielRet ) ) )

							Aadd( aRetor, { cFielRet , xContenido } )

							// 2. E5_DATA
							cFielRet   := "E5_DATA"
							xContenido := FieldGet( FieldPos( cFielRet ) )

							Aadd( aRetor, { cFielRet , xContenido } )

							// 3. E5_VALOR
							cFielRet   := "E5_VALOR"
							xContenido := FieldGet( FieldPos( cFielRet ) )

							Aadd( aRetor, { cFielRet , xContenido } )
						EndIf
					EndIf
					dbSelectArea( "FJG" )
					dbSkip()
				Enddo
			ElseIf cAliasJG == "SF1"
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Recuperacao de Dados de Nota de Entrada ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

				//--- Lendo Numero de Controle da FJG
				cNrCtrl := FJG_NRCTRL

				dbSelectArea( "FJG" )
				//--- FJG_FILIAL+FJG_NRCTRL
				dbSetOrder( 1 )
				dbSeek( xFilial( "FJG" ) + cNrCtrl )

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Varredura do Numero de Controle, foco em SE5 ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				While !EOf() .And. ( FJG_FILIAL+FJG_NRCTRL == xFilial( "FJG" ) + cNrCtrl )

					If FJG_TABCON == "SF1"        //--- Alias localizado

						If !Empty( FJG_REGCON )    //--- Existe Recno ??

							nPoint := Val( FJG->FJG_REGCON )
							
							dbSelectArea( "SF1" )  // ***** Estou no Alias *****
							dbGoTo( nPoint )

							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ Recuperacao de Dados ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

							// 1. F1_DOC
							cFielRet   := "F1_DOC"
							xContenido := AllTrim( FieldGet( FieldPos( cFielRet ) ) )

							Aadd( aRetor, { cFielRet , xContenido } )

							// 2. F1_EMISSAO
							cFielRet   := "F1_EMISSAO"
							xContenido := FieldGet( FieldPos( cFielRet ) )

							Aadd( aRetor, { cFielRet , xContenido } )

							// 3. F1_VALBRUT
							cFielRet   := "F1_VALBRUT"
							xContenido := FieldGet( FieldPos( cFielRet ) )

							Aadd( aRetor, { cFielRet , xContenido } )
							EXIT
						EndIf
					EndIf
					dbSkip()
				Enddo
			ElseIf cAliasJG == "SF2"
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Recuperacao de Dados de Nota de Saida ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

				//--- Lendo Numero de Controle da FJG
				cNrCtrl := FJG_NRCTRL

				dbSelectArea( "FJG" )
				//--- FJG_FILIAL+FJG_NRCTRL
				dbSetOrder( 1 )
				//
				dbSeek( xFilial( "FJG" ) + cNrCtrl )

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Varredura do Numero de Controle, foco em SE5 ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				While !EOf() .And. ( FJG_FILIAL+FJG_NRCTRL == xFilial( "FJG" ) + cNrCtrl )
					If FJG_TABCON == "SF2"        //--- Alias localizado
						If !Empty( FJG_REGCON )    //--- Existe Recno ??

							nPoint := Val( FJG->FJG_REGCON )
							
							dbSelectArea( "SF2" )  // ***** Estou no Alias *****
							dbGoTo( nPoint )

							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ Recuperacao de Dados ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							// 1. F2_DOC
							cFielRet   := "F2_DOC"
							xContenido := AllTrim( FieldGet( FieldPos( cFielRet ) ) )

							Aadd( aRetor, { cFielRet , xContenido } )

							// 2. F2_EMISSAO
							cFielRet   := "F2_EMISSAO"
							xContenido := FieldGet( FieldPos( cFielRet ) )

							Aadd( aRetor, { cFielRet , xContenido } )

							// 3. F2_VALBRUT
							cFielRet   := "F2_VALBRUT"
							xContenido := FieldGet( FieldPos( cFielRet ) )

							Aadd( aRetor, { cFielRet , xContenido } )

							EXIT
						EndIf
					EndIf
					dbSkip()
				Enddo
			EndIf
		EndIf
	EndIf

	RestArea( aOrig )

Return( aRetor )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINR857   บAutor  ณMicrosiga           บ Data ณ  09/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montagem e Abertura de Arquivo Temporario                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Finr857Trb(aOrdem)
	
	Local aCampos	:= {}

	Default aOrdem	:= {}

	AADD( aCampos, { "FJF_CODEXT" , "C" , TamSX3('FJF_CODEXT')[1],0} )
	AADD( aCampos, { "FJF_DATMOV" , "D" , TamSX3('FJF_DATMOV')[1],0} )
	AADD( aCampos, { "FJF_CODCON" , "C" , TamSX3('FJF_CODCON')[1],0} )
	AADD( aCampos, { "FJF_CVALOR" , "C" , TamSX3('FJF_VALOR')[1] ,0} )
	AADD( aCampos, { "FJF_COMPRO" , "C" , TamSX3('FJF_COMPRO')[1],0} )
	AADD( aCampos, { "FJG_NRCTRL" , "C" , TamSX3('FJG_NRCTRL')[1],0} )
	AADD( aCampos, { "FJG_DATCON" , "D" , TamSX3('FJG_DATCON')[1],0} )
	AADD( aCampos, { "E5_DOCUMEN" , "C" , TamSX3('E5_DOCUMEN')[1],0} )
	AADD( aCampos, { "E5_DATA"    , "D" , TamSX3('E5_DATA')[1],0} )
	AADD( aCampos, { "E5_CVALOR"  , "C" , TamSX3('E5_VALOR')[1],0} )
	AADD( aCampos, { "F2_DOC"     , "C" , TamSX3('F2_DOC')[1],0} )
	AADD( aCampos, { "F2_EMISSAO" , "D" , TamSX3('F2_EMISSAO')[1],0} )
	AADD( aCampos, { "F2_VALFIS"  , "C" , TamSX3('F2_VALBRUT')[1],0} )
	AADD( aCampos, { "FJF_VALOR"  , "N" , TamSX3('FJF_VALOR')[1],TamSX3('FJF_VALOR')[2]} )
	AADD( aCampos, { "FRECNO"     , "N" , 10 , 0 } )

	oTmpTabTRB := FWTemporaryTable():New("TRB")
	oTmpTabTRB:SetFields(aCampos)
	oTmpTabTRB:AddIndex("I1", aOrdem)
	oTmpTabTRB:Create()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Grv857   บAutor  ณMicrosiga           บ Data ณ  09/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ GRAVACAO de dados no Arquivo Temporario                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Grv857( cAliasQry )

	Local aRecFJG  := {}
	Local aRecSE5  := {}
	Local aRecSF1  := {}
	Local aRecSF2  := {}

	Local cNroCtrl := " "

	dbSelectArea( cAliasQry )

	ProcRegua( Reccount() )

	While !EOF()

		aRecFJG := Finr857Ctl( (cAliasQry)->FRECNO, "FJG" )

		dbSelectArea( "TRB" )

		RecLock( "TRB" , .T. )

		TRB->FJF_CODEXT := (cAliasQry)->FJF_CODEXT
		TRB->FJF_DATMOV := (cAliasQry)->FJF_DATMOV
		TRB->FJF_CODCON := (cAliasQry)->FJF_CODCON
		TRB->FJF_VALOR  := (cAliasQry)->FJF_VALOR
		TRB->FJF_CVALOR := Trans857( (cAliasQry)->FJF_VALOR )
		TRB->FJF_COMPRO := (cAliasQry)->FJF_COMPRO

		If Len( aRecFJG ) > 0
			TRB->FJG_NRCTRL := aRecFJG[ 1 ][ 2 ]
			TRB->FJG_DATCON := aRecFJG[ 2 ][ 2 ]
		EndIf

		TRB->FRECNO := (cAliasQry)->FRECNO

		MsUnLock()

		dbSelectArea( cAliasQry )
		dbSkip()
		IncProc()

	Enddo

	dbSelectArea( cAliasQry )
	dbCloseArea()

	dbSelectArea( "TRB" )
	dbGoTop()

	While !EOF()

		cNroCtrl := TRB->FJG_NRCTRL

		aRecSE5 := Finr857Ctl( TRB->FRECNO, "SE5" )
		aRecSF1 := Finr857Ctl( TRB->FRECNO, "SF1" )

		If Len( aRecSF1 ) == 0
			aRecSF2 := Finr857Ctl( TRB->FRECNO, "SF2" )
		EndIf

		RecLock( "TRB" , .F. )

		If Len( aRecSE5 ) > 0
			TRB->E5_DOCUMEN := aRecSE5[ 1 ][ 2 ]
			TRB->E5_DATA    := aRecSE5[ 2 ][ 2 ]
			TRB->E5_CVALOR  := Trans857( aRecSE5[ 3 ][ 2 ] )
		EndIf

		If Len( aRecSF1 ) > 0
			TRB->F2_DOC     := aRecSF1[ 1 ][ 2 ]
			TRB->F2_EMISSAO := aRecSF1[ 2 ][ 2 ]
			TRB->F2_VALFIS  := Trans857( aRecSF1[ 3 ][ 2 ] )
		Else
			If Len( aRecSF2 ) > 0
				TRB->F2_DOC     := aRecSF2[ 1 ][ 2 ]
				TRB->F2_EMISSAO := aRecSF2[ 2 ][ 2 ]
				TRB->F2_VALFIS  := Trans857( aRecSF2[ 3 ][ 2 ] )
			EndIf
		EndIf

		MsUnLock()

		While !EOF() .And. ( cNroCtrl == TRB->FJG_NRCTRL )
			dbSkip()
			Loop
		Enddo

	Enddo

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINR857   บAutor  ณMicrosiga           บ Data ณ  09/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que posiciona SA6 e retorna conteudo de campo       บฑฑ
ฑฑบ          ณ enviado como parametro                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Finr857Bco( cChave, cA6Campo )

	Local cOrig     := Alias()
	Local cA6Key    := xFilial("SA6") + cChave
	Local xConteudo := " "

	dbSelectArea("SA6")
	dbSetOrder( 1 )

	If dbSeek( cA6Key )
		xConteudo := &(cA6Campo)
	EndIf

	dbSelectArea( cOrig )

Return( xConteudo )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Grv857   บAutor  ณMicrosiga           บ Data ณ  09/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montagem e Abertura de Arquivo Temporario                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Sinte857()

	Local nInd		:= 1
	Local cCodExt	:= ""
	Local cControl	:= ""
	Local cChave	:= ""
	Local nValAcc	:= 0
	Local aStruct	:= {}
	Local aTempor	:= {}
	Local aOrdem	:= {"FJF_CODEXT", "FJG_NRCTRL"}

	aStruct := TRB->(dbStruct())
	
	oTmpTabQRX := FWTemporaryTable():New("QRX")
	oTmpTabQRX:SetFields(aStruct)
	oTmpTabQRX:AddIndex("I1", aOrdem)
	oTmpTabQRX:Create()

	dbSelectArea( "TRB" )
	dbGoTop()

	While TRB->(!EOF())

		nValAcc  := 0
		aTempor  := {}
		cChave   := TRB->FJF_CODEXT+TRB->FJG_NRCTRL
		cCodExt  := TRB->FJF_CODEXT
		cControl := TRB->FJG_NRCTRL

		//--- Varredura pelo Numero de Controle - Somatoria de Valor em FJF
		While !EOF() .And. ( TRB->FJF_CODEXT+TRB->FJG_NRCTRL == cChave )

			/*  Preciso determinar quantos movimentos SE5 existem */
			nValAcc += TRB->FJF_VALOR

			Aadd( aTempor, { TRB->FJF_CODEXT,;
			TRB->FJF_DATMOV,;
			TRB->FJF_CODCON,;
			TRB->FJF_CVALOR,;
			TRB->FJF_COMPRO,;
			TRB->FJG_NRCTRL,;
			TRB->FJG_DATCON,;
			TRB->E5_DOCUMEN,;
			TRB->E5_DATA,;
			TRB->E5_CVALOR,;
			TRB->F2_DOC,;
			TRB->F2_EMISSAO,;
			TRB->F2_VALFIS } )

			dbSkip()
			IncProc()
		Enddo

		//--- Atualiza o Valor Aglutinado na Primeira Linha
		aTempor[ 1 ][ 4 ] := Trans857( nValAcc )  // Transform( nValAcc , "@E 999,999,999,999.99" )

		dbSelectArea( "QRX" )

		RecLock( "QRX", .T. )

		QRX->FJF_CODEXT := aTempor[ nInd ][ 1 ]
		QRX->FJF_DATMOV := aTempor[ nInd ][ 2 ]
		QRX->FJF_CODCON := aTempor[ nInd ][ 3 ]
		QRX->FJF_CVALOR := aTempor[ nInd ][ 4 ]
		QRX->FJF_COMPRO := aTempor[ nInd ][ 5 ]
		QRX->FJG_NRCTRL := aTempor[ nInd ][ 6 ]
		QRX->FJG_DATCON := aTempor[ nInd ][ 7 ]
		QRX->E5_DOCUMEN := aTempor[ nInd ][ 8 ]
		QRX->E5_DATA    := aTempor[ nInd ][ 9 ]
		QRX->E5_CVALOR  := aTempor[ nInd ][ 10 ]
		QRX->F2_DOC     := aTempor[ nInd ][ 11 ]
		QRX->F2_EMISSAO := aTempor[ nInd ][ 12 ]
		QRX->F2_VALFIS  := aTempor[ nInd ][ 13 ]

		MsUnLock()

		dbSelectArea( "TRB" )
	Enddo

	dbSelectArea( "QRX" )
	QRX->(dbGoTop())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Trans857 บAutor  ณMicrosiga           บ Data ณ  09/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao Auxiliar que padroniza a gravacao de Valores        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Trans857( nValSet )

	Local cReto		:= ""
	Local cAux		:= ""
	Local nTamNum	:= TamSX3('F2_VALBRUT')[1]

	If nValSet == 0
		cAux := Space( nTamNum )
	Else
		cAux := AllTrim( Transform( nValSet, "@E 999,999,999,999.99" ) )
	EndIf

	cReto := PAdL( cAux, nTamNum )

Return( cReto )