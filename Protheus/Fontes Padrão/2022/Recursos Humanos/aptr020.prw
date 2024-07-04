#INCLUDE "aptr020.ch"
#INCLUDE "protheus.ch"      
#INCLUDE "report.ch"

Static	lPropri	:=	IIF(TamSx3("RE5_TABELA")[1]==3,.F.,.T.)	//Verifica se a Categoria tem "S-Sistema" ou "U-Usuario"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³APTR020   º Autor ³ Andreia Santos                  º Data ³  10/08/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Historico dos Processos.                                                º±±
±±º          ³                                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Processos Trabalhistas                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Cecilia C.³12/08/2014³TQEQCC³Incluido o fonte da 11 para a 12 e efetuada a limpeza. ³±±
±±³Renan B.  ³24/12/2015³TUBNND³Ajuste para imprimir relatório de historico de processo³±±
±±³          ³          ³      ³em base que não possua gestão de empresas.              ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function APTR020()
Local oReport   
Local aArea 	:= GetArea()
Private Inclui	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("APT20R",.F.) 
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Tania Bronzeri        ³ Data ³22/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Historico dos Processos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ APTR020                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico - Release 4                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
Local oReport 
Local oSection1 
Local oSection2     
Local oSection3 
Local oSection4 
Local oSection5     
Local oSection6 
Local oSection7 
Local oSection8     
Local oSection9 
Local oSection10 
Local oSection11 
Local cDesc1		:=	OemToAnsi(STR0001) + OemToAnsi(STR0002) + OemToAnsi(STR0003)	
	//"Historico dos Processos" ### "Ser  impresso de acordo com os parametros solicitados pelo"  ### "usu rio."
Private aOrd    := {OemToAnsi(STR0036)}	//"Processo"	
Private cTitulo	:= OemToAnsi(STR0001)	//"Historico dos Processos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao dos componentes de impressao                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE REPORT oReport NAME "APTR020" TITLE cTitulo PARAMETER "APT20R" ACTION {|oReport| APT20Imp(oReport)} DESCRIPTION OemToAnsi(STR0081)
		//"Emite Relatorio de Historico dos Processos Trabalhistas."

	DEFINE SECTION oSection1 OF oReport TITLE OemToAnsi(STR0077) TABLES "RE0","REC","RER","RE1","SA1","RCE","RE5" ORDERS aOrd	//Processo
	//"                                                         P R O C E S S O                                                            "
		DEFINE BORDER OF oSection1 EDGE_ALL

		DEFINE CELL NAME "RE0_NUM"		OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_DESCR"  	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_DTPROC"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_TPACAO"  	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_FASEDS"	OF oSection1 TITLE OemToAnsi(STR0082) SIZE 30	;
				BLOCK {||RE0FaseDsX3Relacao("RE0")}
		DEFINE CELL NAME "RE0_RECLAM"	OF oSection1 TITLE OemToAnsi(STR0076) SIZE 6	;	//"Reclamante"
				BLOCK {||Left(If(RE0->RE0_TPACAO#"1",space(06),RE0->RE0_RECLAM)+space(06),6)}
		DEFINE CELL NAME "RE0_RECNOM"	OF oSection1 TITLE OemToAnsi(STR0083) SIZE 30	;		//"Nome do Reclamante"
				BLOCK {||Left(If(RE0->RE0_TPACAO#"1",OemToAnsi(STR0084),fDesc("RD0",RE0->RE0_RECLAM,"RD0_NOME"))+Space(31),31)}	//"DIVERSOS"
		DEFINE CELL NAME "RE0_FUNASS"  	OF oSection1 TITLE OemToAnsi(STR0085) SIZE 6	;	//"Matr.Func.Assoc."
				BLOCK {||IIF(!Empty(RE0->RE0_RECLAM),EntGetInfo("SRA","RA_MAT",RE0->RE0_RECLAM),"")}
		DEFINE CELL NAME "RE0_DESLIG"	OF oSection1 TITLE OemToAnsi(STR0086) SIZE 10	;	//"Desligamento"
				BLOCK {||IIF(!Empty(RE0->RE0_RECLAM),DtoC(EntGetInfo("SRA","RA_DEMISSA",RE0->RE0_RECLAM)),"  /  /  ")}
		DEFINE CELL NAME "RE0_LIMITE"  	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_CC"	  	OF oSection1 ALIAS "RE0" 
		DEFINE CELL NAME "RE0_ANO"		OF oSection1 TITLE OemToAnsi(STR0087) SIZE 4	;	//"Ano"
				BLOCK {||Transform(Year(RE0->RE0_DTPROC),"9999")}
		DEFINE CELL NAME "RE0_N1INST"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_N2INST"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_NSUPTR"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_NCONS"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_COMAR"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "REC_NOME"		OF oSection1 ALIAS "REC"
		DEFINE CELL NAME "RER_DESCR"	OF oSection1 ALIAS "RER"
		DEFINE CELL NAME "RE0_VARA"		OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE1_DESCR"	OF oSection1 ALIAS "RE1"
		DEFINE CELL NAME "RE0_CODCLI"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_LOJA"		OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "A1_NOME"		OF oSection1 ALIAS "SA1"
		DEFINE CELL NAME "RE0_CODSIN"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RCE_DESCRI"	OF oSection1 ALIAS "RCE"
		DEFINE CELL NAME "RE0_DTPROT"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_DTDIST"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_DTCITA"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_DTPRES"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_DTARQU"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_VLRCSA"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_IDT"		OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_VLRCOR"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_VLRPGT"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_VLPGCO" OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_PROGN"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE5_DESCR"	OF oSection1 ALIAS "RE5"
		DEFINE CELL NAME "RE0_RISCO"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_SITE"		OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_LOCARQ"	OF oSection1 ALIAS "RE0"
		DEFINE CELL NAME "RE0_COBS"	 	OF oSection1 ALIAS "RE0"	SIZE 150 	;
				BLOCK {||MSMM(RE0->RE0_COBS,,,,3,,,,,"RE6")}

		oSection1:ShowHeader()
		oSection1:SetLineStyle()  
		oSection1:SetPageBreak()     
		oSection1:Cell("RE0_COBS"):SetLineBreak()		//Impressao de campo Memo
		TRPosition():New(oSection1,"REC",1,{|| xfilial("REC",RE0->RE0_FILIAL)+RE0->RE0_COMAR},.T.)
		TRPosition():New(oSection1,"RER",1,{|| xfilial("RER",REC->REC_FILIAL)+REC->REC_REGIAO},.T.)
		TRPosition():New(oSection1,"RE1",1,{|| xfilial("RE1",RE0->RE0_FILIAL)+RE0->RE0_COMAR+RE0->RE0_VARA},.T.)
		TRPosition():New(oSection1,"SA1",1,{|| xfilial("SA1",RE0->RE0_FILIAL)+RE0->RE0_CODCLI+RE0->RE0_LOJA},.T.)
		TRPosition():New(oSection1,"RCE",1,{|| xfilial("RCE",RE0->RE0_FILIAL)+RE0->RE0_CODSIN},.T.)
		IF lPropri
			TRPosition():New(oSection1,"RE5",1,{|| xfilial("RE5",RE0->RE0_FILIAL)+"RE0 "+RE0->RE0_PROGN},.T.)
		Else
			TRPosition():New(oSection1,"RE5",1,{|| xfilial("RE5",RE0->RE0_FILIAL)+"RE0"+RE0->RE0_PROGN},.T.)
		EndIf


	DEFINE SECTION oSection2 OF oSection1 TITLE OemToAnsi(STR0048) TABLES "REL","RD0","RE5","SRA","SRV"
	//"                                                          P L E I T O S                                                           "
		DEFINE BORDER OF oSection2 EDGE_ALL

		DEFINE CELL NAME "REL_PRONUM"	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "REL_CODPLT"	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "REL_DESCR"	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "REL_RECLAM" 	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "RD0_NOME"		OF oSection2 ALIAS "RD0"
		DEFINE CELL NAME "REL_TPPLT" 	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "RE5_DESCR"	OF oSection2 ALIAS "RE5"
		DEFINE CELL NAME "REL_FUNASS"	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "RA_NOME"		OF oSection2 TITLE "" SIZE 30	;
				BLOCK {||IIF(!EMPTY(REL->REL_RECLAM),EntGetInfo("SRA","RA_NOME",REL->REL_RECLAM),"")}
		DEFINE CELL NAME "RA_DEMISSA" 	OF oSection2 ALIAS "SRA"
		DEFINE CELL NAME "REL_LIMITE" 	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "REL_VERBA" 	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "RV_DESC"		OF oSection2 ALIAS "SRV"
		DEFINE CELL NAME "REL_PERINI"	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "REL_PERFIM" 	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "REL_PARAD1" 	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "REL_PARNO1"	OF oSection2 TITLE "" SIZE 30	;
				BLOCK {||fDesc("RD0",REL->REL_PARAD1,"RD0_NOME")}
		DEFINE CELL NAME "REL_PARAD2" 	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "REL_PARNO2"	OF oSection2 TITLE "" SIZE 30	;
				BLOCK {||fDesc("RD0",REL->REL_PARAD2,"RD0_NOME")}
		DEFINE CELL NAME "REL_PARAD3" 	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "REL_PARNO3"	OF oSection2 TITLE "" SIZE 30	;
				BLOCK {||fDesc("RD0",REL->REL_PARAD3,"RD0_NOME")}
		DEFINE CELL NAME "REL_VALPLT"	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "REL_IDT"		OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "REL_VLRCOR"	OF oSection2 ALIAS "REL"
		DEFINE CELL NAME "REL_COBS"	 	OF oSection2 ALIAS "REL" SIZE 150		;
				BLOCK {||MSMM(REL->REL_COBS,,,,3,,,,,"RE6")}

		oSection2:ShowHeader()
		oSection2:SetLineStyle()                                      
		oSection2:Cell("REL_COBS"):SetLineBreak()		//Impressao de campo Memo
		TRPosition():New(oSection2,"RD0",1,{|| xfilial("RD0",REL->REL_FILIAL)+REL->REL_RECLAM},.T.)
		TRPosition():New(oSection2,"SRA",1,{|| xfilial("SRA",REL->REL_FILIAL)+REL->REL_FUNASS},.T.)
		TRPosition():New(oSection2,"SRV",1,{|| xfilial("SRV",REL->REL_FILIAL)+REL->REL_VERBA},.T.)
		IF lPropri
			TRPosition():New(oSection2,"RE5",1,{|| xfilial("RE5",REL->REL_FILIAL)+"REL "+REL->REL_TPPLT},.T.)
		Else
			TRPosition():New(oSection2,"RE5",1,{|| xfilial("RE5",REL->REL_FILIAL)+"REL"+REL->REL_TPPLT},.T.)
		EndIf


	DEFINE SECTION oSection3 OF oSection2 TITLE OemToAnsi(STR0078) TABLES "REH","RE5","RD0","REU"
	//"                                                         P E R I C I A S                                                            "
		DEFINE BORDER OF oSection3 EDGE_ALL

		DEFINE CELL NAME "REH_PRONUM"	OF oSection3 ALIAS "REH"
		DEFINE CELL NAME "REH_CODPLT"	OF oSection3 ALIAS "REH"
		DEFINE CELL NAME "REH_DTPERI" 	OF oSection3 ALIAS "REH"
		DEFINE CELL NAME "REH_TIPO"		OF oSection3 ALIAS "REH"
		DEFINE CELL NAME "RE5_DESCR"	OF oSection3 ALIAS "RE5"
		DEFINE CELL NAME "REH_DTSOLI"	OF oSection3 ALIAS "REH"
		DEFINE CELL NAME "REH_RESULT"	OF oSection3 ALIAS "REH"
		DEFINE CELL NAME "REH_RESDES"	OF oSection3 ALIAS "REH"  		;	
				BLOCK{||IIF(lPropri,fDesc("RE5","RST "+REH->REH_RESULT,"RE5_DESCR"),fDesc("RE5","RST"+REH->REH_RESULT,"RE5_DESCR"))}
		DEFINE CELL NAME "REH_PERITO"	OF oSection3 ALIAS "REH"
		DEFINE CELL NAME "RD0_NOME"		OF oSection3 ALIAS "RD0"
		DEFINE CELL NAME "REH_PERSGL"	OF oSection3 ALIAS "REH"
		DEFINE CELL NAME "REU_NUMREG"	OF oSection3 ALIAS "REU"
		DEFINE CELL NAME "REH_ASSTEC"	OF oSection3 ALIAS "REH"
		DEFINE CELL NAME "REH_ASSNOM"	OF oSection3 ALIAS "REH" 		;	
				BLOCK{||fDesc("RD0",REH->REH_ASSTEC,"RD0_NOME")}
		DEFINE CELL NAME "REH_COBS"	 	OF oSection3 ALIAS "REH"	SIZE 150		;
				BLOCK {||MSMM(REH->REH_COBS,,,,3,,,,,"RE6")}

		oSection3:SetLineStyle()                                      
		oSection3:SetLeftMargin(15)
		oSection3:ShowHeader()
		oSection3:Cell("REH_COBS"):SetLineBreak()		//Impressao de campo Memo
		TRPosition():New(oSection3,"RD0",1,{|| xfilial("RD0",REH->REH_FILIAL)+REH->REH_PERITO},.T.)
		TRPosition():New(oSection3,"REU",1,{|| xfilial("REU",REH->REH_FILIAL)+REH->REH_PERITO+REH->REH_PERSGL},.T.)
		IF lPropri
			TRPosition():New(oSection3,"RE5",1,{|| xfilial("RE5",REH->REH_FILIAL)+"REH "+REH->REH_TIPO},.T.)
		Else
			TRPosition():New(oSection3,"RE5",1,{|| xfilial("RE5",REH->REH_FILIAL)+"REL"+REH->REH_TIPO},.T.)
		EndIf


	DEFINE SECTION oSection4 OF oSection1 TITLE OemToAnsi(STR0067) TABLES "RE4","RD0","RE8","REU","RE3"
	//"                                                        A D V O G A D O S                                                          "
		DEFINE BORDER OF oSection4 EDGE_ALL

		DEFINE CELL NAME "RE4_PRONUM"	OF oSection4 ALIAS "RE4"
		DEFINE CELL NAME "RE4_CODADV"	OF oSection4 ALIAS "RE4"
		DEFINE CELL NAME "RD0_NOME"		OF oSection4 ALIAS "RD0"
		DEFINE CELL NAME "RE8_SIGLA"	OF oSection4 ALIAS "RE8"
		DEFINE CELL NAME "REU_NUMREG" 	OF oSection4 ALIAS "REU"
		DEFINE CELL NAME "RE4_PARTE" 	OF oSection4 ALIAS "RE4"
		DEFINE CELL NAME "RE4_ESCRIT"	OF oSection4 ALIAS "RE4"
		DEFINE CELL NAME "RE3_NOME"		OF oSection4 ALIAS "RE3"
		DEFINE CELL NAME "RE4_DTINGR" 	OF oSection4 ALIAS "RE4"
		DEFINE CELL NAME "RE4_DTAFAS" 	OF oSection4 ALIAS "RE4"
		DEFINE CELL NAME "RE4_COBS"	 	OF oSection4 ALIAS "RE4"	SIZE 150 		;
				BLOCK {||MSMM(RE4->RE4_COBS,,,,3,,,,,"RE6")}

		oSection4:ShowHeader()
		oSection4:SetLineStyle()                                      
		oSection4:Cell("RE4_COBS"):SetLineBreak()		//Impressao de campo Memo
		TRPosition():New(oSection4,"RD0",1,{|| xfilial("RD0",RE4->RE4_FILIAL)+RE4->RE4_CODADV},.T.)
		TRPosition():New(oSection4,"RE8",1,{|| xFilial("RE8")+"ADV"},.T.)
		TRPosition():New(oSection4,"REU",1,{|| xfilial("REU",RE4->RE4_FILIAL)+RE4->RE4_CODADV+fDesc("RE8","ADV","RE8_SIGLA")},.T.)
		TRPosition():New(oSection4,"RE3",1,{|| xfilial("RE3",RE4->RE4_FILIAL)+RE4->RE4_ESCRIT},.T.)


	DEFINE SECTION oSection5 OF oSection1 TITLE OemToAnsi(STR0068) TABLES "REA","RE5","RD0","RE8","REU","REJ"
	//"                                                       A U D I E N C I A S                                                         "
		DEFINE BORDER OF oSection5 EDGE_ALL

		DEFINE CELL NAME "REA_PRONUM"	OF oSection5 ALIAS "REA"
		DEFINE CELL NAME "REA_DATA"		OF oSection5 ALIAS "REA"
		DEFINE CELL NAME "REA_HORA"		OF oSection5 ALIAS "REA"
		DEFINE CELL NAME "REA_TIPO" 	OF oSection5 ALIAS "REA"
		DEFINE CELL NAME "RE5_DESCR"	OF oSection5 ALIAS "RE5"
		DEFINE CELL NAME "REA_TPPREP" 	OF oSection5 ALIAS "REA"
		DEFINE CELL NAME "REA_PRECOD"	OF oSection5 ALIAS "REA"
		DEFINE CELL NAME "RD0_NOME"		OF oSection5 ALIAS "RD0"
		DEFINE CELL NAME "REA_ADRDAC" 	OF oSection5 ALIAS "REA"
		DEFINE CELL NAME "REA_ADRDAN"	OF oSection5 ALIAS "REA"		;
				BLOCK {||fDesc("RD0",REA->REA_ADRDAC,"RD0_NOME")}
		DEFINE CELL NAME "RE8_SIGLA" 	OF oSection5 ALIAS "RE8"
		DEFINE CELL NAME "REU_NUMREG" 	OF oSection5 ALIAS "REU"
		DEFINE CELL NAME "REA_ADRTEC"	OF oSection5 ALIAS "REA"
		DEFINE CELL NAME "REA_ADRTEN"	OF oSection5 ALIAS "REA"		;
				BLOCK {||fDesc("RD0",REA->REA_ADRTEC,"RD0_NOME")}
		DEFINE CELL NAME "RE8_SIGLA" 	OF oSection5 ALIAS "RE8"
		DEFINE CELL NAME "REA_OABRTE"	OF oSection5 ALIAS "REA"		;
				BLOCK {||fDesc("REU",REA->REA_ADRTEC+(FDESC("RE8","ADV","RE8_SIGLA")),"REU_NUMREG")}
		DEFINE CELL NAME "REA_JUIZ_C"	OF oSection5 ALIAS "REA"
		DEFINE CELL NAME "REJ_NOME" 	OF oSection5 ALIAS "REJ"        ;
				BLOCK {||fDesc("REJ",REA->REA_JUIZ_C,"REJ_NOME")}
		DEFINE CELL NAME "REA_VALOFE" 	OF oSection5 ALIAS "REA"
		DEFINE CELL NAME "REA_VALACO" 	OF oSection5 ALIAS "REA"
		DEFINE CELL NAME "REA_REPLIC" 	OF oSection5 ALIAS "REA"
		DEFINE CELL NAME "REA_REPPRZ"	OF oSection5 ALIAS "REA"
		DEFINE CELL NAME "REA_CCONCL" 	OF oSection5 ALIAS "REA"	SIZE 150 		;
				BLOCK {||MSMM(REA->REA_CCONCL,,,,3,,,,,"RE6")}
		DEFINE CELL NAME "REA_CPROVI" 	OF oSection5 ALIAS "REA"	SIZE 150 		;
				BLOCK {||MSMM(REA->REA_CPROVI,,,,3,,,,,"RE6")}
		DEFINE CELL NAME "REA_COBS" 	OF oSection5 ALIAS "REA"	SIZE 150 		;
				BLOCK {||MSMM(REA->REA_COBS,,,,3,,,,,"RE6")}

		oSection5:ShowHeader()
		oSection5:SetLineStyle()                                      
		oSection5:Cell("REA_COBS"):SetLineBreak()		//Impressao de campo Memo Observacoes
		oSection5:Cell("REA_CCONCL"):SetLineBreak()		//Impressao de campo Memo Conclusao
		oSection5:Cell("REA_CPROVI"):SetLineBreak()		//Impressao de campo Memo Providencias
		TRPosition():New(oSection5,"RD0",1,{|| xfilial("RD0",REA->REA_FILIAL)+REA->REA_PRECOD},.T.)
		TRPosition():New(oSection5,"RE8",1,{|| xFilial("RE8")+"ADV"},.T.)
		TRPosition():New(oSection5,"REU",1,{|| xfilial("REU",REA->REA_FILIAL)+REA->REA_ADRDAC+(fDesc("RE8","ADV","RE8_SIGLA"))},.T.)
		TRPosition():New(oSection5,"REU",1,{|| xfilial("REU",REA->REA_FILIAL)+REA->REA_ADRDAC+(fDesc("RE8","ADV","RE8_SIGLA"))},.T.)
		IF lPropri
			TRPosition():New(oSection5,"RE5",1,{|| xfilial("RE5",REA->REA_FILIAL)+"REA "+REA->REA_TIPO},.T.)
		Else
			TRPosition():New(oSection5,"RE5",1,{|| xfilial("RE5",REA->REA_FILIAL)+"REA"+REA->REA_TIPO},.T.)
		EndIf


	DEFINE SECTION oSection6 OF oSection5 TITLE OemToAnsi(STR0066) TABLES "RE9","RD0"
	//"                                                      T E S T E M U N H A S                                                        "
		DEFINE BORDER OF oSection6 EDGE_ALL

		DEFINE CELL NAME "RE9_PRONUM"	OF oSection6 ALIAS "RE9"
		DEFINE CELL NAME "RE9_DATA"		OF oSection6 ALIAS "RE9"
		DEFINE CELL NAME "RE9_TESCOD" 	OF oSection6 ALIAS "RE9"
		DEFINE CELL NAME "RD0_NOME"		OF oSection6 ALIAS "RD0"
		DEFINE CELL NAME "RE9_PARTE"	OF oSection6 ALIAS "RE9"
		DEFINE CELL NAME "RE9_COBS"	 	OF oSection6 ALIAS "RE9"	SIZE 150		;
				BLOCK {||MSMM(RE9->RE9_COBS,,,,3,,,,,"RE6")}

		oSection6:SetLineStyle()                                      
		oSection6:SetLeftMargin(15)
		oSection6:ShowHeader()
		oSection6:Cell("RE9_COBS"):SetLineBreak()		//Impressao de campo Memo
		TRPosition():New(oSection6,"RD0",1,{|| xfilial("RD0",RE9->RE9_FILIAL)+RE9->RE9_TESCOD},.T.)


	DEFINE SECTION oSection7 OF oSection1 TITLE OemToAnsi(STR0079) TABLES "REO","RE5","REJ","RD0"
	//"                                                      O C O R R E N C I A S                                                         "
		DEFINE BORDER OF oSection7 EDGE_ALL

		DEFINE CELL NAME "REO_PRONUM"	OF oSection7 ALIAS "REO"
		DEFINE CELL NAME "REO_DATA"		OF oSection7 ALIAS "REO"
		DEFINE CELL NAME "REO_LIMITE"	OF oSection7 ALIAS "REO"
		DEFINE CELL NAME "REO_TIPO" 	OF oSection7 ALIAS "REO"
		DEFINE CELL NAME "RE5_DESCR"	OF oSection7 ALIAS "RE5"
		DEFINE CELL NAME "REO_JUIZ_C"	OF oSection7 ALIAS "REO"
		DEFINE CELL NAME "REJ_NOME" 	OF oSection7 ALIAS "REJ"
		DEFINE CELL NAME "REO_CODADV" 	OF oSection7 ALIAS "REO"
		DEFINE CELL NAME "RD0_NOME"		OF oSection7 ALIAS "RD0"
		DEFINE CELL NAME "REO_COCOR" 	OF oSection7 ALIAS "REO"	SIZE 150 		;
				BLOCK {||MSMM(REO->REO_COCOR,,,,3,,,,,"RE6")}

		oSection7:ShowHeader()
		oSection7:SetLineStyle()                                      
		oSection7:Cell("REO_COCOR"):SetLineBreak()		//Impressao de campo Memo Observacoes
		TRPosition():New(oSection7,"REJ",1,{|| xfilial("REJ",REO->REO_FILIAL)+REO->REO_JUIZ_C},.T.)
		TRPosition():New(oSection7,"RD0",1,{|| xfilial("RD0",REO->REO_FILIAL)+REO->REO_CODADV},.T.)
		IF lPropri
			TRPosition():New(oSection7,"RE5",1,{|| xfilial("RE5",REO->REO_FILIAL)+"REO "+REO->REO_TIPO},.T.)
		Else
			TRPosition():New(oSection7,"RE5",1,{|| xfilial("RE5",REO->REO_FILIAL)+"REO"+REO->REO_TIPO},.T.)
		EndIf


	DEFINE SECTION oSection8 OF oSection1 TITLE OemToAnsi(STR0055) TABLES "RES","RE5","REJ","RD0","REU"
	//"                                                        S E N T E N C A S                                                          "
		DEFINE BORDER OF oSection8 EDGE_ALL

		DEFINE CELL NAME "RES_PRONUM"	OF oSection8 ALIAS "RES"
		DEFINE CELL NAME "RES_JULGAM"	OF oSection8 ALIAS "RES"
		DEFINE CELL NAME "RES_TIPO" 	OF oSection8 ALIAS "RES"
		DEFINE CELL NAME "RE5_DESCR"	OF oSection8 ALIAS "RE5"
		DEFINE CELL NAME "RES_JUIZ_C"	OF oSection8 ALIAS "RES"
		DEFINE CELL NAME "REJ_NOME" 	OF oSection8 ALIAS "REJ"
		DEFINE CELL NAME "RES_PUBLIC"	OF oSection8 ALIAS "RES"
		DEFINE CELL NAME "RES_JAUX1" 	OF oSection8 ALIAS "RES"
		DEFINE CELL NAME "RES_JAX1NO"	OF oSection8 ALIAS "RES"		;
				BLOCK {||fDesc("REJ",RES->RES_JAUX1,"REJ_NOME")}
		DEFINE CELL NAME "RES_JAUX2" 	OF oSection8 ALIAS "RES"
		DEFINE CELL NAME "RES_JAX2NO"	OF oSection8 ALIAS "RES"		;
				BLOCK {||fDesc("REJ",RES->RES_JAUX2,"REJ_NOME")}
		DEFINE CELL NAME "RES_VALCON"	OF oSection8 ALIAS "RES"
		DEFINE CELL NAME "RES_VLCORE"	OF oSection8 ALIAS "RES"
		DEFINE CELL NAME "RES_PERITO"	OF oSection8 ALIAS "RES"
		DEFINE CELL NAME "RD0_NOME"		OF oSection8 ALIAS "RD0"
		DEFINE CELL NAME "RES_PERSGL"	OF oSection8 ALIAS "RES"
		DEFINE CELL NAME "REU_NUMREG" 	OF oSection8 ALIAS "REU"
		DEFINE CELL NAME "RES_PAGTO"	OF oSection8 ALIAS "RES"
		DEFINE CELL NAME "RES_EMBARG"	OF oSection8 ALIAS "RES"
		DEFINE CELL NAME "RES_DTEMB"	OF oSection8 ALIAS "RES"
		DEFINE CELL NAME "RES_CSENT" 	OF oSection8 ALIAS "RES"	SIZE 150 		;
				BLOCK {||MSMM(RES->RES_CSENT,,,,3,,,,,"RE6")}

		oSection8:ShowHeader()
		oSection8:SetLineStyle()                                      
		oSection8:Cell("RES_CSENT"):SetLineBreak()		//Impressao de campo Memo Observacoes
		TRPosition():New(oSection8,"REJ",1,{|| xfilial("REJ",RES->RES_FILIAL)+RES->RES_JUIZ_C},.T.)
		TRPosition():New(oSection8,"RD0",1,{|| xfilial("RD0",RES->RES_FILIAL)+RES->RES_PERITO},.T.)
		TRPosition():New(oSection8,"REU",1,{|| xfilial("REU",RES->RES_FILIAL)+RES->RES_PERITO+RES->RES_PERSGL},.T.)
		IF lPropri
			TRPosition():New(oSection8,"RE5",1,{|| xfilial("RE5",RES->RES_FILIAL)+"RES "+RES->RES_TIPO},.T.)
		Else
			TRPosition():New(oSection8,"RE5",1,{|| xfilial("RE5",RES->RES_FILIAL)+"RES"+RES->RES_TIPO},.T.)
		EndIf


	DEFINE SECTION oSection9 OF oSection1 TITLE OemToAnsi(STR0059) TABLES "REM","RE5"
	//"                                                         R E C U R S O S                                                           "
		DEFINE BORDER OF oSection9 EDGE_ALL

		DEFINE CELL NAME "REM_PRONUM"	OF oSection9 ALIAS "REM"
		DEFINE CELL NAME "REM_DATA"		OF oSection9 ALIAS "REM"
		DEFINE CELL NAME "REM_TIPO" 	OF oSection9 ALIAS "REM"
		DEFINE CELL NAME "RE5_DESCR"	OF oSection9 ALIAS "RE5"
		DEFINE CELL NAME "REM_VALOR"	OF oSection9 ALIAS "REM"
		DEFINE CELL NAME "REM_CRCRSO" 	OF oSection9 ALIAS "REM"	SIZE 150 		;
				BLOCK {||MSMM(REM->REM_CRCRSO,,,,3,,,,,"RE6")}
		DEFINE CELL NAME "REM_CCTRAZ" 	OF oSection9 ALIAS "REM"	SIZE 150 		;
				BLOCK {||MSMM(REM->REM_CCTRAZ,,,,3,,,,,"RE6")}

		oSection9:ShowHeader()
		oSection9:SetLineStyle()                                      
		oSection9:Cell("REM_CRCRSO"):SetLineBreak()		//Impressao de campo Memo Recurso
		oSection9:Cell("REM_CCTRAZ"):SetLineBreak()		//Impressao de campo Memo Contra-Razoes
		IF lPropri
			TRPosition():New(oSection9,"RE5",1,{|| xfilial("RE5",REM->REM_FILIAL)+"REM "+REM->REM_TIPO},.T.)
		Else
			TRPosition():New(oSection9,"RE5",1,{|| xfilial("RE5",REM->REM_FILIAL)+"REM"+REM->REM_TIPO},.T.)
		EndIf


	DEFINE SECTION oSection10 OF oSection1 TITLE OemToAnsi(STR0064) TABLES "RC1","SE2","RE5"
	//"                                            D E S P E S A S   E   P A G A M E N T O S                                              "
		DEFINE BORDER OF oSection10 EDGE_ALL

		DEFINE CELL NAME "RC1_PRONUM"	OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RC1_FILTIT"	OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RC1_CC"	 	OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RC1_PREFIX"	OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RC1_NUMTIT"	OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RC1_DESCRI"	OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RC1_VALOR"	OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RC1_TIPO"		OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RC1_EMISSA"	OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RC1_VENCTO"	OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RC1_VENREA"	OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RC1_NATURE"	OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RC1_FORNEC"	OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RC1_LOJA"		OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "E2_NOMFOR"	OF oSection10 ALIAS "SE2"
		DEFINE CELL NAME "RC1_PARC"		OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RC1_TPDESP" 	OF oSection10 ALIAS "RC1"
		DEFINE CELL NAME "RE5_DESCR"	OF oSection10 ALIAS "RE5"

		oSection10:ShowHeader()
		oSection10:SetLineStyle() 
		      
		TRPosition():New(oSection10,"RC1",3,{|| xfilial("RC1",RE0->RE0_FILIAL)+RC1->RC1_PRONUM+RC1->RC1_PREFIX+RC1->RC1_NUMTIT+RC1->RC1_PARC},.T.)                               
		TRPosition():New(oSection10,"SE2",1,{|| xfilial("SE2",RC1->RC1_FILIAL)+RC1->RC1_FORNEC+RC1->RC1_LOJA},.T.)
		
		IF lPropri		    
			TRPosition():New(oSection10,"RE5",1,{|| xfilial("RE5",RC1->RC1_FILIAL)+"RC1 "+RC1->RC1_TPDESP},.T.)
		Else
			TRPosition():New(oSection10,"RE5",1,{|| xfilial("RE5",RC1->RC1_FILIAL)+"RC1"+RC1->RC1_TPDESP},.T.)
		EndIf


	DEFINE SECTION oSection11 OF oSection1 TITLE OemToAnsi(STR0080) TABLES "REG","SN1"
	//" 	                                     B E N S   E M   G A R A N T I A   /   P E N H O R A                                         "
		DEFINE BORDER OF oSection11 EDGE_ALL

		DEFINE CELL NAME "REG_PRONUM"	OF oSection11 ALIAS "REG"
		DEFINE CELL NAME "REG_CODIGO"	OF oSection11 ALIAS "REG"
		DEFINE CELL NAME "REG_ITEM"	 	OF oSection11 ALIAS "REG"
		DEFINE CELL NAME "N1_DESCRIC"	OF oSection11 ALIAS "SN1"
		DEFINE CELL NAME "N1_CHAPA"		OF oSection11 ALIAS "SN1"
		DEFINE CELL NAME "N1_PLACA"		OF oSection11 ALIAS "SN1"
		DEFINE CELL NAME "REG_PENHOR"	OF oSection11 ALIAS "REG"
		DEFINE CELL NAME "REG_DATPEN"	OF oSection11 ALIAS "REG"
		DEFINE CELL NAME "REG_VALPEN"	OF oSection11 ALIAS "REG"
		DEFINE CELL NAME "REG_MANDAD"	OF oSection11 ALIAS "REG"
		DEFINE CELL NAME "REG_COBS" 	OF oSection11 ALIAS "REG"	SIZE 150 		;
				BLOCK {||MSMM(REG->REG_COBS,,,,3,,,,,"RE6")}

		oSection11:ShowHeader()
		oSection11:SetLineStyle()                                      
		oSection11:Cell("REG_COBS"):SetLineBreak()		//Impressao de campo Memo 
		TRPosition():New(oSection11,"SN1",1,{|| xfilial("SN1",REG->REG_FILIAL)+REG->REG_CODIGO+REG->REG_ITEM},.T.)

		oSection1:SetCols(4)
		oSection2:SetCols(4)
		oSection3:SetCols(4)
		oSection4:SetCols(4)
		oSection5:SetCols(4)
		oSection6:SetCols(4)
		oSection7:SetCols(4)
		oSection8:SetCols(4)
		oSection9:SetCols(4)
		oSection10:SetCols(4)
		oSection11:SetCols(4)

Return(oReport)

Static Function APT20Imp(oReport)

Local oSection1 	:= oReport:Section(1)	//Processo
Local oSection2 	:= oSection1:Section(1)	//Pleito
Local oSection3		:= oSection2:Section(1)	//Pericias
Local oSection4		:= oSection1:Section(2)	//Advogados
Local oSection5		:= oSection1:Section(3)	//Audiencias
Local oSection6		:= oSection5:Section(1)	//Testemunhas
Local oSection7		:= oSection1:Section(4)	//Ocorrencias
Local oSection8		:= oSection1:Section(5)	//Sentencas
Local oSection9		:= oSection1:Section(6)	//Recursos
Local oSection10	:= oSection1:Section(7)	//Despesas e Pagamentos
Local oSection11	:= oSection1:Section(8)	//Bens em Garantia / Penhora	
Local cFiltro 		:= "" 
Local cIndCond		:= ""
Local cString		:= "RE0"
Private cPastas		:= 	mv_par05					//  Pastas a Imprimir

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeAdvplExpr("APT20R")
	
dbSelectArea( "RE0")
cIndCond:= "RE0->RE0_FILIAL + RE0->RE0_NUM"
dbSetOrder(1)

//-- Adiciona no filtro o parametro tipo Range
//-- Filial
If !Empty(mv_par01)
	cFiltro += mv_par01
EndIf

//-- Processo
If !Empty(mv_par02)
	cFiltro += Iif(!Empty(cFiltro)," .AND. ","")
	cFiltro += mv_par02
EndIf

//-- Data do Processo
If !Empty(mv_par03)
	cFiltro += Iif(!Empty(cFiltro)," .AND. ","")
	cFiltro += mv_par03
EndIf

//-- Comarca
If !Empty(mv_par04)
	cFiltro += Iif(!Empty(cFiltro)," .AND. ","")
	cFiltro += mv_par04
EndIf

oSection1:SetFilter(cFiltro) 
RE0->( DbGoTop() )

oSection2:SetRelation({||xfilial("REL",RE0->RE0_FILIAL)+RE0->RE0_NUM},"REL",1,.T.)
oSection2:SetParentFilter({|cParam|REL->REL_FILIAL+REL->REL_PRONUM == cParam},{||RE0->RE0_FILIAL+RE0->RE0_NUM})

oSection3:SetRelation({||xfilial("REH",REL->REL_FILIAL)+REL->REL_PRONUM+REL->REL_CODPLT},"REH",1,.T.)
oSection3:SetParentFilter({|cParam|REH->REH_FILIAL+REH->REH_PRONUM+REH->REH_CODPLT == cParam},{||REL->REL_FILIAL+REL->REL_PRONUM+REL->REL_CODPLT})

oSection4:SetRelation({||xfilial("RE4",RE0->RE0_FILIAL)+RE0->RE0_NUM},"RE4",1,.T.)
oSection4:SetParentFilter({|cParam|RE4->RE4_FILIAL+RE4->RE4_PRONUM == cParam},{||RE0->RE0_FILIAL+RE0->RE0_NUM})

oSection5:SetRelation({||xfilial("REA",RE0->RE0_FILIAL)+RE0->RE0_NUM},"REA",1,.T.)
oSection5:SetParentFilter({|cParam|REA->REA_FILIAL+REA->REA_PRONUM == cParam},{||RE0->RE0_FILIAL+RE0->RE0_NUM})

oSection6:SetRelation({||xfilial("RE9",REA->REA_FILIAL)+REA->REA_PRONUM+DtoS(REA->REA_DATA)},"RE9",1,.T.)
oSection6:SetParentFilter({|cParam|RE9->RE9_FILIAL+RE9->RE9_PRONUM+DtoS(RE9->RE9_DATA) == cParam},{||REA->REA_FILIAL+REA->REA_PRONUM+DtoS(REA->REA_DATA)})

oSection7:SetRelation({||xfilial("REO",RE0->RE0_FILIAL)+RE0->RE0_NUM},"REO",1,.T.)
oSection7:SetParentFilter({|cParam|REO->REO_FILIAL+REO->REO_PRONUM == cParam},{||RE0->RE0_FILIAL+RE0->RE0_NUM})

oSection8:SetRelation({||xfilial("RES",RE0->RE0_FILIAL)+RE0->RE0_NUM},"RES",1,.T.)
oSection8:SetParentFilter({|cParam|RES->RES_FILIAL+RES->RES_PRONUM == cParam},{||RE0->RE0_FILIAL+RE0->RE0_NUM})

oSection9:SetRelation({||xfilial("REM",RE0->RE0_FILIAL)+RE0->RE0_NUM},"REM",1,.T.)
oSection9:SetParentFilter({|cParam|REM->REM_FILIAL+REM->REM_PRONUM == cParam},{||RE0->RE0_FILIAL+RE0->RE0_NUM})

oSection10:SetIdxOrder(3)
oSection10:SetRelation({||xfilial("RC1",RE0->RE0_FILIAL)+RE0->RE0_NUM},"RE0",1,.T.)
oSection10:SetParentFilter({|cParam|RC1->RC1_FILIAL+RC1->RC1_PRONUM == cParam},{||RE0->RE0_FILIAL+RE0->RE0_NUM})

oSection11:SetRelation({||xfilial("REG",RE0->RE0_FILIAL)+RE0->RE0_NUM},"REG",1,.T.)
oSection11:SetParentFilter({|cParam|REG->REG_FILIAL+REG->REG_PRONUM == cParam},{||RE0->RE0_FILIAL+RE0->RE0_NUM})

//-- Condicao de impressao do Processo
oSection1:SetLineCondition({|| If(!Empty(xFilial("RE0")),Alltrim(RE0->RE0_FILIAL) $ Alltrim(fValidFil()),RE0->RE0_FILIAL $ fValidFil() )}) 

//-- Define o total da regua da tela de processamento do relatorio
oReport:SetMeter( 100 )  

If !("1"$cPastas)		//Processos
	oSection1:Hide()
EndIf

If !("2"$cPastas)		//Pleitos  
	oSection2:Disable()
	oSection3:Disable()
Else
	If !("3"$cPastas)	//Pericias   
		oSection3:Disable()
	EndIf
EndIf		

If !("4"$cPastas)		//Advogados
	oSection4:Disable()
EndIf

If !("5"$cPastas)		//Audiencias
	oSection5:Disable()
	oSection6:Disable()
Else
	If !("6"$cPastas)	//Testemunhas
		oSection6:Disable()
	EndIf
EndIf

If !("7"$cPastas)		//Ocorrencias
	oSection7:Disable()
EndIf

If !("8"$cPastas)		//Sentencas  
	oSection8:Disable()
EndIf

If !("9"$cPastas)		//Recursos   
	oSection9:Disable()
EndIf

If !("A"$cPastas)		//Despesas   
	oSection10:Disable()
EndIf

If !("B"$cPastas)		//Bem Garantia/Penhora
	oSection11:Disable()
EndIf           

oSection3:SetTitle(OemToAnsi(STR0088))
oSection6:SetTitle(OemToAnsi(STR0089))
oSection1:Print()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino do relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Device To Screen
dbSelectArea("RE0")
dbSetOrder(1)
dbgotop()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³a20Pastas ºAutor  ³Andreia Santos      º Data ³  13/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                 	      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a20Pastas()

Local cTitulo	:=	""
Local MvParDef	:=	""
Local l1Elem 	:= .F. 
Local MvPar		:= ""
Local oWnd
Local cTipoAu

Private aResul	:={}

oWnd := GetWndDefault()
MvPar	:=	&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet	:=	Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

cTitulo := STR0035 //"Imprimir Pastas"
aResul  := {STR0036,STR0037,STR0043,STR0038,STR0039,STR0047,STR0040,STR0041,STR0042,STR0044,STR0046/*,STR0045*/} //"Processo"###"Pleitos"###"Pericias"###"Advogados"###"Audiencias"###"Testemunhas"###"Ocorrencias"###"Sentencas"###"Recursos"###"Despesas"###"Bem/Penhora"###"Dep.Recursivo"
 
//MvParDef	:=	"123456789ABC"
MvParDef	:=	"123456789AB"

f_Opcoes(@MvPar,cTitulo,aResul,MvParDef,12,49,l1Elem,,11)		// Chama funcao f_Opcoes
&MvRet := mvpar 					   	// Devolve Resultado
Return
