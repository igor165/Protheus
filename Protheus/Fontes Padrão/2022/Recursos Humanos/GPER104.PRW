#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER104.CH"
#INCLUDE "Report.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER104   ºAutor  ³Tania Bronzeri      º Data ³ 10/09/2007   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Incidencias por Funcionario.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Folha de pagamento  - Mexico                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³ Data     ³ BOPS   | Motivo da Alteracao                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCarlos E. O.³17/09/2013³M12RH01 ³Ajustes referentes a ordem de impressaoº±±
±±º            ³          ³184703  ³escolhida. Checa existencia dos campos º±±
±±º            ³          ³        ³RA_KEYLOC, RA_CODRPAT. Retirada funcao º±±
±±º            ³          ³        ³AjustSX1()                             º±±
±±ºEsther de   ³05/06/2014³M12RH01 ³Adicao das funcoes fGR104join (para    º±±
±±º Viveiro    ³          ³184703  ³tratar comparacao entre filais) e      º±±
±±º            ³          ³        ³fGR104Header (para impressao do cabe-  º±±
±±º            ³          ³        ³calho). Ajustes de leiaute.            º±±
±±ºCecilia Car.³16/06/2014³M12RH01 ³Correcao para que nao ocorra error.log º±±
±±º            ³          ³184703  ³ao imprimir relatorio num ambiente que º±±
±±º            ³          ³        ³possui integracao com SIGAORG.         º±±
±±º  Marco A.  ³24/04/2018³DMINA-  ³Se realizan cambios al Orden utilizado º±±
±±º            ³          ³247     ³en impresion de GPER104 para COL y PER.º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER104()
	Local	oReport   
	Local	aArea 		    := GetArea()
	Private cPerg		    := "GPE104R"     
	Private cCond           := "1" // Seta variavel para funcao gpRCHFiltro utilizada na pergunta Periodo, para mostrar apenas periodos abertos
	Private cProcesso	    := ""
	Private cRot	    	:= ""
	Private cPeriodo	    := ""
	Private cPagamento	    := ""
	Private cHDV		    := ""	//Horas / Dias / Valores
	Private cPDB		    := ""	//Proventos / Descontos / Bases
	Private cAliasQry	    := ""
	Private cTitulo		    := OemToAnsi(STR0012)	//"Incidências por Funcionário"
	Private nOrdem		    := 1
	Private nSinAna   	    := 0
	Private lUsaArqui	    := Iif(GetMv("MV_ORGCFG",,"0")=="0",.F.,.T.)	// 0-Nao utiliza	1-Utiliza Postos e Deptos	2-Utiliza so Deptos.
	Private aOrd		    := {}
	Private nItensRetirados := 0
	Private nPosRetirada 	:= 0	
    Private cVisaoDepto	:= ""
		
	Aadd(aOrd, OemToAnsi(STR0004)+"+"+OemToAnsi(STR0003))													//1 - "Matricula + Incidências"	
	Aadd(aOrd, OemToAnsi(STR0006)+"+"+OemToAnsi(STR0003))													//2 - "Nome + Incidências"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0003))							//3 - "C.Custo + Matrícula + Incidências"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0006)+"+"+OemToAnsi(STR0003))							//4 - "C.Custo + Nome + Incidências"
	Aadd(aOrd, OemToAnsi(STR0007)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0003))							//5 - "Depto + Matricula + Incidências"
	Aadd(aOrd, OemToAnsi(STR0007)+"+"+OemToAnsi(STR0006)+"+"+OemToAnsi(STR0003)) 							//6 - "Depto + Nome + Incidências"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0007)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0003))		//7 - "C.Custo + Depto + Matricula + Incidências"	
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0007)+"+"+OemToAnsi(STR0006)+"+"+OemToAnsi(STR0003))		//8 - "C.Custo + Depto + Nome + Incidências"

	nPosRetirada := Len(aOrd) + 1

	dbSelectArea("SRA")	
	If SRA->(FIELDPOS("RA_KEYLOC")) > 0 //Se existe o campo - tratamento para o Mexico
		Aadd(aOrd, OemToAnsi(IIf(cPaisLoc $ "COL", STR0044, STR0035))+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0003))	//9 - "Loc.Pago + Matrícula + Incidências" - "Centro Trab."
		Aadd(aOrd, OemToAnsi(IIf(cPaisLoc $ "COL", STR0044, STR0035))+"+"+OemToAnsi(STR0006)+"+"+OemToAnsi(STR0003))	//10 - "Loc.Pago + Nome + Incidências"     - "Centro Trab."
		nPosRetirada += 2
	Else
		nItensRetirados += 2
	Endif
		
	If SRA->(FIELDPOS("RA_CODRPAT")) > 0//Se existe o campo - tratamento para o Mexico
		If !(cPaisLoc $ "PER|COL")
			Aadd(aOrd, OemToAnsi(STR0038)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0003))	//11 - "Reg.Patronal + Matricula + Incidências"
			Aadd(aOrd, OemToAnsi(STR0038)+"+"+OemToAnsi(STR0006)+"+"+OemToAnsi(STR0003))	//12 - "Reg.Patronal + Nome + Incidências"
			
			If nItensRetirados == 0
				nPosRetirada += 2
			Endif
		EndIf
	Else
		nItensRetirados += 2		  	
	Endif
			
	Aadd(aOrd, OemToAnsi(STR0013)+"+"+OemToAnsi(STR0003))														//13 - "Verba + Incidências"

	Pergunte(cPerg,.F.)

	cProcesso := mv_par08
	cRot := mv_par09	                  
	
	oReport := ReportDef()
	oReport:PrintDialog()
	
	RestArea( aArea )
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Tania Bronzeri        ³ Data ³10/09/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Incidencias por Funcionario.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER104                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local oReport 
Local oSecFun 
Local oSecInc      
Local oSecNom
Local oSecCtt
Local oSecSqb 
Local oSecSrv
Local oSecProc  
Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0008) + OemToAnsi(STR0002)
					//"Relatorio de Incidências por Funcionário"  
					//"Imprime a Relação das Incidências por Funcionário no Período." 
					//"Ser  impresso de acordo com os parametros solicitados pelo usu rio."
					
Local cTitulo	:= OemToAnsi(STR0012)	//"Incidências por Funcionário"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao dos componentes de impressao                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE REPORT oReport NAME "GPER104" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| R104Imp(oReport)} DESCRIPTION cDesc1	

	oReport:SetTotalInLine(.F.)     // para totalizar em linhas
	oReport:nFontBody	:= 8
	oReport:SetDynamic()

	//1
	DEFINE SECTION oSecFun OF oReport TITLE OemToAnsi(STR0011) TABLES "SRA", "SQB" ORDERS aOrd	//"Filial / Funcionário"

		DEFINE CELL NAME "RA_FILIAL"  OF oSecFun ALIAS "SRA"
		DEFINE CELL NAME "FILIAL"	  OF oSecFun TITLE " - " SIZE 30 BLOCK {||fDesc("SM0",(cAliasQry)->RA_FILIAL,"M0_FILIAL")}	//Filial
		DEFINE CELL NAME "RA_CC"      OF oSecFun ALIAS "SRA" 
		DEFINE CELL NAME "RA_DEPTO"   OF oSecFun ALIAS "SRA"
		DEFINE CELL NAME "QB_DESCRIC" OF oSecFun ALIAS BLOCK {||fDesc("SQB",(cAliasQry)->RA_DEPTO,"SQB->QB_DESCRIC")} //ALIAS "SQB"
		DEFINE CELL NAME "RA_MAT"     OF oSecFun ALIAS "SRA" 
		DEFINE CELL NAME "RA_NOME"    OF oSecFun ALIAS "SRA"

		DEFINE CELL NAME "RA_HRSMES"   OF oSecFun ALIAS "SRA" 
		DEFINE CELL NAME "RA_SALARIO"  OF oSecFun ALIAS "SRA" 

		oSecFun:SetLineStyle()  
		oSecFun:SetCols(3)
		oSecFun:SetTotalInLine(.F.)
		oSecFun:Cell("RA_CC"):SetCellBreak(.T.)
		oSecFun:Cell("QB_DESCRIC"):SetCellBreak(.T.)		
		oSecFun:Disable()
		oSecFun:SetDynamicKey(OemToAnsi(STR0004))	//"Matrícula"        

	//2
	DEFINE SECTION oSecInc OF oReport TITLE OemToAnsi(STR0027) TABLES "RGB", "SRV", "SRA"	//Verbas do Funcionário

		DEFINE CELL NAME "RA_FILIAL" 	OF oSecInc ALIAS "SRA"
		DEFINE CELL NAME "RA_MAT" 		OF oSecInc ALIAS "SRA"
		DEFINE CELL NAME "RA_NOME"		OF oSecInc ALIAS "SRA"

		DEFINE CELL NAME "PD"     OF oSecInc TITLE OemToAnsi(STR0009) SIZE 03	PICTURE "@!"	; 	//"Cod."
			BLOCK {||Upper((cAliasQry)->RGB_PD)}		
		DEFINE CELL NAME "DESC"   OF oSecInc TITLE OemToAnsi(STR0026) SIZE 20	PICTURE "@!" 	;	//"Descrição"
			BLOCK {|| Left((cAliasQry)->RV_DESC,20)}
		DEFINE CELL NAME "HORAS"  OF oSecInc TITLE OemToAnsi(STR0022) SIZE 08 PICTURE "@E 999,999.99"	;	//"Horas"
			BLOCK {||Iif(cHDV=="H",(cAliasQry)->RGB_HORAS,0)}
		DEFINE CELL NAME "DIAS"   OF oSecInc TITLE OemToAnsi(STR0023) SIZE 08 PICTURE "@E 999,999.99"	;	//"Dias"
			BLOCK {||Iif(cHDV=="D",(cAliasQry)->RGB_HORAS,0)}
		DEFINE CELL NAME "REFER"  OF oSecInc TITLE OemToAnsi(STR0019) SIZE 08 PICTURE "@E 999,999.99"	;	//"Referência"
			BLOCK {||Iif(cHDV<>"H" .And. cHDV<>"D",(cAliasQry)->RGB_HORAS,0)}
		DEFINE CELL NAME "PROVEN" OF oSecInc TITLE OemToAnsi(STR0024) SIZE 20 PICTURE "@E 99,999,999,999.99"	;	//"Provento"
			BLOCK {||Iif(cPDB=="1",(cAliasQry)->RGB_VALOR,0)}
		DEFINE CELL NAME "DESCON" OF oSecInc TITLE OemToAnsi(STR0025) SIZE 20 PICTURE "@E 99,999,999,999.99"	;	//"Desconto"
			BLOCK {||Iif(cPDB=="2",(cAliasQry)->RGB_VALOR,0)}
		DEFINE CELL NAME "SINAL"  OF oSecInc TITLE "."   BLOCK {||cPDB} PICTURE "@!"
		DEFINE CELL NAME "STATUS" OF oSecInc TITLE "HDV" BLOCK {||cHDV}

		oSecInc:Cell("HORAS" ):SetHeaderAlign("RIGHT")
		oSecInc:Cell("DIAS"  ):SetHeaderAlign("RIGHT")
		oSecInc:Cell("PROVEN"):SetHeaderAlign("RIGHT")
		oSecInc:Cell("DESCON"):SetHeaderAlign("RIGHT")
		oSecInc:Cell("SINAL" ):Disable()  
		oSecInc:Cell("STATUS"):Disable()
		oSecInc:Cell("RA_FILIAL"):Disable()
		oSecInc:Cell("RA_MAT"   ):Disable()
		oSecInc:Cell("RA_NOME"  ):Disable()
		oSecInc:SetTotalInLine(.F.)
		oSecInc:SetLineCondition({|| cPDB:=(cAliasQry)->RV_TIPOCOD, cHDV:=(cAliasQry)->RV_TIPO })
		oSecInc:Disable()
		oSecInc:SetDynamicKey(OemToAnsi(STR0003))	//"Incidências"
		
	//3
	DEFINE SECTION oSecNom OF oReport TITLE OemToAnsi(STR0011) TABLES "SRA", "SQB" ORDERS aOrd	//"Filial / Funcionário"

		DEFINE CELL NAME "RA_FILIAL"  OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "FILIAL" 	  OF oSecNom TITLE " - " SIZE 30 BLOCK {||fDesc("SM0",(cAliasQry)->RA_FILIAL,"M0_FILIAL")}	//Filial
		DEFINE CELL NAME "RA_CC"      OF oSecNom ALIAS "SRA" 
		DEFINE CELL NAME "RA_DEPTO"   OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "QB_DESCRIC" OF oSecNom ALIAS BLOCK {||fDesc("SQB",(cAliasQry)->RA_DEPTO,"SQB->QB_DESCRIC")} //"SQB"
		DEFINE CELL NAME "RA_NOME"    OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_MAT"     OF oSecNom ALIAS "SRA" 

		DEFINE CELL NAME "RA_HRSMES"   OF oSecNom ALIAS "SRA" 
		DEFINE CELL NAME "RA_SALARIO"  OF oSecNom ALIAS "SRA" 

		oSecNom:SetLineStyle()  
		oSecNom:SetTotalInLine(.F.)
		oSecNom:Cell("QB_DESCRIC"):SetCellBreak(.T.)
		oSecNom:Disable()
		oSecNom:SetDynamicKey(OemToAnsi(STR0006))	//"Nome"

	//4
	DEFINE SECTION oSecCtt OF oReport TABLES "CTT", "SRA" ORDERS aOrd TITLE OemToAnsi(STR0020) TOTAL IN COLUMN // "Centro de Custo"
		
		DEFINE CELL NAME "RA_FILIAL" 	OF oSecCtt ALIAS "SRA"
		DEFINE CELL NAME "CTT_FILIAL" 	OF oSecCtt ALIAS "CTT"
		DEFINE CELL NAME "CTT_CUSTO"   	OF oSecCtt ALIAS "CTT" 

		oSecCtt:Cell("CTT_FILIAL"):Disable()
		oSecCtt:Disable()
		oSecCtt:SetLineStyle()  
		oSecCtt:SetDynamicKey(OemToAnsi(STR0005))	//"C.Custo"

	//5
	DEFINE SECTION oSecSqb OF oReport TABLES "SQB", "SRA" ORDERS aOrd TITLE OemToAnsi(STR0021) TOTAL IN COLUMN // "Departamento"
		
		DEFINE CELL NAME "RA_FILIAL"	OF oSecSqb ALIAS "SRA"		
		DEFINE CELL NAME "QB_FILIAL" 	OF oSecSqb ALIAS "SQB"
		DEFINE CELL NAME "QB_CC"    	OF oSecSqb ALIAS "SQB" 		
		DEFINE CELL NAME "QB_DEPTO"   	OF oSecSqb ALIAS "SQB"
		DEFINE CELL NAME "QB_DESCRIC"	OF oSecSqb ALIAS "SQB"

		oSecSqb:Cell("QB_FILIAL"):Disable()
		oSecSqb:Cell("QB_CC"):Disable()	
		oSecSqb:Disable()
		oSecSqb:SetDynamicKey(OemToAnsi(STR0007))	//"Depto."

	//6
	DEFINE SECTION oSecSrv OF oReport TABLES "SRV", "RGB" TITLE OemToAnsi(STR0013)	// "Verba"
		
		DEFINE CELL NAME "RV_COD" 		OF oSecSRV ALIAS "SRV" TITLE OemToAnsi(STR0013) BLOCK {|| (cAliasQry)->RGB_PD} 	// "Verba"
		DEFINE CELL NAME "RV_DESC"		OF oSecSRV ALIAS "SRV" BLOCK {|| Left((cAliasQry)->RV_DESC, 20)} 

		oSecSrv:SetLineStyle()
		oSecSrv:Disable()
		oSecSrv:SetDynamicKey(OemToAnsi(STR0013))	//"Verba" 

	//7
	DEFINE SECTION oSecRgc OF oReport TABLES "RGC" ORDERS aOrd TITLE OemToAnsi(STR0034) TOTAL IN COLUMN // "Localidade Pagamento"
		
		DEFINE CELL NAME "RGC_FILIAL" 	OF oSecRgc ALIAS "RGC"
		DEFINE CELL NAME "RGC_KEYLOC"  	OF oSecRgc ALIAS "RGC"
		DEFINE CELL NAME "RGC_DESLOC"	OF oSecRgc ALIAS "RGC"

		oSecRgc:SetLineStyle()                                                         	
		oSecRgc:Cell("RGC_FILIAL"):Disable()
		oSecRgc:Disable()
		oSecRgc:SetDynamicKey(OemToAnsi(IIf(cPaisLoc == "COL", STR0044, STR0035)))	//"Loc.Pago" - Para COL se utiliza "Centro Trab."

	//8
	DEFINE SECTION oSecRco OF oReport TABLES "RCO" ORDERS aOrd TITLE OemToAnsi(STR0037) TOTAL IN COLUMN // "Registro Patronal"
		
		DEFINE CELL NAME "RCO_FILIAL" 	OF oSecRco ALIAS "RCO"
		DEFINE CELL NAME "RCO_CODIGO"  	OF oSecRco ALIAS "RCO"
		DEFINE CELL NAME "RCO_NREPAT"	OF oSecRco ALIAS "RCO"
		DEFINE CELL NAME "RCO_NOME" 	OF oSecRco ALIAS "RCO"

		oSecRco:SetLineStyle()                                                         	
		oSecRco:Cell("RCO_FILIAL"):Disable()
		oSecRco:Disable()
		oSecRco:SetDynamicKey(OemToAnsi(STR0038))	//"Reg.Patronal"		

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ R104Imp    ³ Autor ³ Tania Bronzeri        ³ Data ³10/09/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Valores por Funcionario                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER104                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R104Imp(oReport)
Local oSectIncid	
Local oSectFunc
Local oSectCcus 
Local oSectDept 
Local oSectVerb 
Local oSectRgc 
Local oSectRco
Local cFiltro 		:= "" 
Local cFilPD		:= ""  
Local cSitQuery		:= ""
Local cCatQuery		:= ""
Local cVerQuery		:= ""
Local cIndCond		:= ""
Local cOrdem		:= ""
Local cDescrVerbas	:= ""
Local cTitFil		:= ""
Local cTitCC		:= ""
Local cTitDp		:= "" 
Local cTitPd		:= ""
Local cTitFun		:= ""
Local cSinal		:= ""
Local cStatus		:= "" 
Local cBrFil		:= ""
Local cBrCc			:= ""
Local cBrDep		:= ""
Local cAuxPrc		:= ""
Local cRProc		:= ""
Local cCountQ		:= ""
Local cCpoAdic		:= ""
Local cJoin			:= ""
Local cJoinSQB		:= ""
Local cFilJoin		:= ""
Local cOrgJoin		:= ""
Local cNotDel		:= ""
Local cChaveArq		:= ""
Local nReg			:= 0
Local nCont			:= 0 
Local nExist		:= 0
Local nTamCod		:= 0
Local lQ			:= .T.
Local lShar			:= .T.
Local aChaveArq		:= array(2)
Local cModAcesso	:= ""
Local cAuxCods   := ""
Local cCodPesq   := ""
Local nPosx      := 0
Local aAuxCods   := {}

Local cCTTRGB := fGR104join("CTT", "RGB")
Local cSQBSRA := fGR104join("SQB", "SRA")
Local cRGCSRA := fGR104join("RGC", "SRA")
Local cRCOSRA := fGR104join("RCO", "SRA")
Local cSRVSRA := fGR104join("SRV", "SRA","%")

Private cCodVisao	:= ""
Private cCodDepto	:= ""
Private aVerbas		:= {}
Private aVerbasRet	:= {}
Private aVerbasSin	:= {}
Private nHrsMes		:= 0
Private nSalario	:= 0 

nOrdem		:= oReport:GetOrder()

If cPaisLoc $ "COL|PER" .AND. nOrdem == 11
	nOrdem := 13
EndIf

If (nItensRetirados > 0) .And. (nOrdem >= nPosRetirada) 

	nOrdem += nItensRetirados 
	//Isso aqui foi necessario porque inicialmente cada item de seleção do combo das ordens
	//foi deixado com numeros fixos nos ifs e nesta modificacao tem opcoes de ordens
	//que foram retiradas para o usuario com ids menores que o 13, dependendo da existencia de campos,
	//deslocando o ultimo item para cima.
Endif

If nOrdem == 1		//Matrícula
	oSectFunc 	:= oReport:Section(1)
	oSectIncid 	:= oReport:Section(2)
	
ElseIf nOrdem == 2	//Nome
	oSectFunc	:= oReport:Section(3) 
	oSectFunc:Cell("RA_FILIAL"):SetCellBreak(.T.)
	oSectFunc:SetCols(3)
	oSectIncid	:= oReport:Section(2)
	
ElseIf nOrdem == 3	//C.Custo + Matrícula
	oSectCcus:= oReport:Section(4) 
	oSectCcus:SetLineStyle()
	oSectCcus:SetCols(4)
	oSectCcus:SetCharSeparator(": ")
		
	oSectFunc	:= oReport:Section(1)	 
	oSectFunc:Cell("RA_FILIAL"):Disable()
	oSectFunc:Cell("RA_CC"    ):Disable()
	oSectFunc:Cell("FILIAL"   ):Disable()
	oSectFunc:SetCols(3)
	oSectFunc:SetLineStyle()
	
	oSectIncid	:= oReport:Section(2)	
	
ElseIf nOrdem == 4	//C.Custo + Nome
	oSectCcus:= oReport:Section(4) 
	oSectCcus:SetLineStyle()
	oSectCcus:SetCharSeparator(": ")
	oSectFunc	:= oReport:Section(3) 
	oSectIncid	:= oReport:Section(2) 
	oSectFunc:Cell("RA_FILIAL"):Disable()
	oSectFunc:Cell("RA_CC"    ):Disable()
	oSectFunc:Cell("FILIAL"   ):Disable()
	oSectCcus:SetCols(4)
	oSectFunc:SetCols(3)
	oSectFunc:SetLineStyle()
	
ElseIf nOrdem == 5	//Depto + Matrícula
	oSectDept	:= oReport:Section(5) 
	oSectFunc	:= oReport:Section(1)
	oSectIncid	:= oReport:Section(2) 
	oSectFunc:Cell("RA_FILIAL" ):Disable()
	oSectFunc:Cell("RA_DEPTO"  ):Disable()
	oSectFunc:Cell("QB_DESCRIC"):Disable()
	oSectFunc:Cell("FILIAL"    ):Disable()
	oSectFunc:Cell("RA_CC"     ):Disable()
	oSectDept:SetCols(4)
	oSectFunc:SetCols(3)
	oSectDept:SetLineStyle()
	oSectFunc:SetLineStyle()
	
ElseIf nOrdem == 6	//Depto + Nome
	oSectDept	:= oReport:Section(5)
	oSectFunc	:= oReport:Section(3) 
	oSectIncid	:= oReport:Section(2) 
	oSectFunc:Cell("RA_FILIAL" ):Disable()
	oSectFunc:Cell("RA_DEPTO"  ):Disable()
	oSectFunc:Cell("QB_DESCRIC"):Disable()
	oSectFunc:Cell("FILIAL"    ):Disable()
	oSectFunc:Cell("RA_CC"     ):Disable()
	oSectDept:SetCols(4) 
	oSectFunc:SetCols(3)
	oSectDept:SetLineStyle()
	oSectFunc:SetLineStyle()
	
ElseIf nOrdem == 7 //Centro Custo + Depto + Matricula + Incidencias

	oSectCcus:= oReport:Section(4) 
	oSectCcus:SetCols(4)	
	oSectCcus:SetLineStyle()
	oSectCcus:SetCharSeparator(": ")
	oSectCcus:Cell("CTT_FILIAL"):Disable()
		
	oSectDept	:= oReport:Section(5) 
	oSectDept:Cell("QB_FILIAL" ):Disable()
	oSectDept:Cell("RA_FILIAL" ):Disable()		
	oSectDept:SetCols(4)		
	oSectDept:SetLineStyle()

	oSectFunc	:= oReport:Section(1)
	oSectFunc:Cell("FILIAL"):Disable()
	oSectFunc:Cell("RA_CC"    ):Disable()
	oSectFunc:Cell("RA_DEPTO"):Disable()
	oSectFunc:Cell("QB_DESCRIC"):Disable()
	oSectFunc:SetLineStyle()
	
	oSectIncid	:= oReport:Section(2)	
	 
ElseIf nOrdem == 8
	oSectCcus:= oReport:Section(4) 
	oSectCcus:SetLineStyle()
	oSectCcus:SetCharSeparator(": ")
	oSectCcus:Cell("CTT_FILIAL"):Disable()
	oSectCcus:SetCols(4)
		
	oSectDept	:= oReport:Section(5) 
	oSectDept:Cell("QB_FILIAL" ):Disable()
	oSectDept:Cell("RA_FILIAL" ):Disable()		
	oSectDept:SetCols(4)		
	oSectDept:SetLineStyle()
	
	oSectFunc	:= oReport:Section(3)                        
	oSectFunc:Cell("FILIAL"):Disable()
	oSectFunc:Cell("RA_CC"    ):Disable()
	oSectFunc:Cell("RA_DEPTO"):Disable()
	oSectFunc:Cell("QB_DESCRIC"):Disable()
	oSectFunc:SetCols(3)
	oSectFunc:SetLineStyle()
	
	oSectIncid	:= oReport:Section(2)	
	
ElseIf nOrdem == 9 
	//Loc.Pago + Matrícula
	oSectRgc:= oReport:Section(7) 
	oSectRgc:SetLineStyle()
	oSectRgc:SetCharSeparator(": ")
	oSectFunc	:= oReport:Section(1)
	oSectIncid	:= oReport:Section(2) 
	oSectFunc:Cell("RA_FILIAL"):Disable()
	oSectFunc:Cell("RA_CC"    ):Disable()
	oSectFunc:Cell("FILIAL"   ):Disable()
	oSectFunc:SetLineStyle()
	oSectRgc:OnPrintLine({||oReport:SkipLine(), oReport:FatLine()})
	
ElseIf nOrdem == 10
	//Loc.Pago + Nome
	oSectRgc:= oReport:Section(7)
	oSectRgc:SetLineStyle()
	oSectRgc:SetCharSeparator(": ")
	oSectFunc	:= oReport:Section(3) 
	oSectIncid	:= oReport:Section(2) 
	oSectFunc:Cell("RA_FILIAL"):Disable()
	oSectFunc:Cell("RA_CC"    ):Disable()
	oSectFunc:Cell("FILIAL"   ):Disable()
	oSectFunc:SetLineStyle()
	oSectRgc:OnPrintLine({||oReport:SkipLine(), oReport:FatLine()})
	  
ElseIf nOrdem == 11 
	//Reg.Patronal + Matrícula
	oSectRco:= oReport:Section(8)
	oSectRco:SetLineStyle()
	oSectRco:SetCharSeparator(": ")
	oSectFunc	:= oReport:Section(1)
	oSectIncid	:= oReport:Section(2) 
	oSectFunc:Cell("RA_FILIAL"):Disable()
	oSectFunc:Cell("RA_CC"    ):Disable()
	oSectFunc:Cell("FILIAL"   ):Disable()
	oSectFunc:SetLineStyle()
	oSectRco:OnPrintLine({||oReport:SkipLine(), oReport:FatLine()})
	
ElseIf nOrdem == 12
	//Reg.Patronal + Nome
	oSectRco:= oReport:Section(8) 
	oSectRco:SetLineStyle()
	oSectRco:SetCharSeparator(": ")
	oSectFunc	:= oReport:Section(3) 
	oSectIncid	:= oReport:Section(2) 
	oSectFunc:Cell("RA_FILIAL"):Disable()
	oSectFunc:Cell("RA_CC"    ):Disable()
	oSectFunc:Cell("FILIAL"   ):Disable()
	oSectFunc:SetLineStyle()
	oSectRco:OnPrintLine({||oReport:SkipLine(), oReport:FatLine()})
	
ElseIf nOrdem == 13	//Verba + Nome
	oSectVerb:= oReport:Section(6) 
	oSectVerb:SetLineStyle()
	oSectVerb:SetCols(4)	
	oSectIncid:= oReport:Section(2) 
	oSectIncid:AutoSize()
	
EndIf  

If nOrdem == 13
	oSectVerb:OnPrintLine({||oReport:ThinLine(), oReport:SkipLine()})
Else
	oSectFunc:OnPrintLine({||oReport:ThinLine(), oReport:SkipLine()})
EndIf

cSituacao   := mv_par06					
cCategoria 	:= mv_par07					
cProcesso	:= Iif(Empty(mv_par08),"",AllTrim(mv_par08))
cRot		:= mv_par09
cPeriodo	:= mv_par10
cPagamento	:= mv_par11
cCodigos  	:= AllTrim(mv_par12)			// Codigos ( Verbas )
cCodigos  	+= AllTrim(mv_par13)		
lAllVerbas 	:= If(("*" $ AllTrim(mv_par12) .AND. "*" $ AllTrim(mv_par13)),.T.,.F.)		// Imprimir todas as verbas
lSalario  	:= If(mv_par14=1,.T.,.F.)		// Salario Cadastro
lImpEmpr  	:= If(mv_par15=1,.T.,.F.)		// Listar total empresa

If !(AllTrim(oReport:Title()) == cTitulo)
	cTitulo	:= oReport:Title()
Endif
   
If lUsaArqui 	//Se uas Arquitetura Organizadional (SIGAORG)
	cCodVisao	:= mv_par16
   cCodDepto	:= mv_par17
Else
	cCodVisao	:= ""
	cCodDepto	:= ""	
EndIf  

If !Empty(cCodVisao + cCodDepto)
	 aChaveArq	:= fQueryVisao()
	 cChaveArq	:= aChaveArq[2]
	 lShar		:= Iif(Empty(aChaveArq[1]),.T.,.F.)
    cOrgJoin	:= " INNER JOIN (SELECT RD4.RD4_FILIDE, RD4.RD4_CODIDE, RD4.RD4_CHAVE "
    cOrgJoin	+= " FROM " + RetSqlName("RD4") + " RD4 "
	 
    If cPaisLoc == "MEX"
		  cOrgJoin	+= " WHERE RD4_CHAVE LIKE '" + AllTrim(cChaveArq) + "%' AND RD4.D_E_L_E_T_ = ' ' ) TVRD4 "
    Else
		  cOrgJoin	+= " WHERE RD4_CODIDE >= '" + cCodDepto + "' AND RD4.D_E_L_E_T_ = ' ' ) TVRD4 "
    EndIf		
	cOrgJoin	+= " ON SRA.RA_DEPTO = TVRD4.RD4_CODIDE "
	If !lShar
		cOrgJoin+= " AND SRA.RA_FILIAL = TVRD4.RD4_FILIDE "
	EndIf
	
	cVisaoDepto	:= OemToAnsi(STR0041) + AllTrim(cCodVisao)
							
EndIf

If nOrdem == 1
	cTitulo += " - " + OemToAnsi(STR0004)	//Matrícula
ElseIf nOrdem == 2
	cTitulo += " - " + OemToAnsi(STR0006)	//Nome
EndIf
		              
If nOrdem ==1 .Or. nOrdem ==2
	oSectFunc:Cell("RA_FILIAL" ):Enable()
	oSectFunc:Cell("FILIAL"    ):Disable()
	oSectFunc:Cell("RA_CC"     ):Enable() 
	oSectFunc:Cell("RA_DEPTO"  ):Enable()
	oSectFunc:Cell("QB_DESCRIC"):Enable()
	oSectFunc:SetCharSeparator(": ")
EndIf

If nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 7 .Or. nOrdem == 8 //Centro de Custo

	cTitulo 	+= " - " + OemToAnsi(STR0020)
	
	If nOrdem == 7 .Or. nOrdem == 8
		cTitulo	+= " + " + OemToAnsi(STR0007)	//"Depto."  
	EndIf
	
	DEFINE BREAK oBreakCc  OF oSectCCus WHEN { || (cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO }  TITLE OemToAnsi(STR0029) //"Total do Centro de Custo "
	
	DEFINE FUNCTION NAME "CTOTHORAS"  FROM oSectIncid:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
	DEFINE FUNCTION NAME "CTOTDIAS"   FROM oSectIncid:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"
	DEFINE FUNCTION NAME "CPROVVALOR" FROM oSectIncid:Cell("PROVEN") FUNCTION SUM     BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectIncid:Cell("SINAL" ):GetText() == "1" } 	//"Provento:"
	DEFINE FUNCTION NAME "CDESCVALOR" FROM oSectIncid:Cell("DESCON") FUNCTION SUM     BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectIncid:Cell("SINAL" ):GetText() == "2" } 	//"Desconto:

	oBreakCc:OnBreak({|x,y|cTitCC:=OemToAnsi(STR0029)+" "+x})	//"Total Centro de Custo"
   	oBreakCc:SetTotalText({||cTitCC})
   	oBreakCc:SetTotalInLine(.F.)
   	oBreakCc:OnPrintTotal({|| oReport:SkipLine() }) 
   	
	DEFINE COLLECTION OF oSectIncid FUNCTION COUNT FORMULA {|| oSectIncid:Cell("PD"):GetText() + " - " + oSectIncid:Cell("DESC"):GetText()} CONTENT {|| oSectIncid:Cell("PD"):GetText()} BREAK oBreakCc TITLE OemToAnsi(STR0013) PICTURE "9999"	NO END REPORT	NO END SECTION	//"Verba"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("HORAS" ):GetValue(.T.)}	BREAK oBreakCc TITLE OemToAnsi(STR0022) PICTURE "@E 9,999,999.99"		NO END REPORT	NO END SECTION	//"Horas"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("DIAS"  ):GetValue(.T.)}	BREAK oBreakCc TITLE OemToAnsi(STR0023) PICTURE "@E 9,999,999.99"		NO END REPORT	NO END SECTION	//"Dias"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("PROVEN"):GetValue(.T.)}	BREAK oBreakCc TITLE OemToAnsi(STR0024) PICTURE "@E 9,999,999,999,999.99"	NO END REPORT	NO END SECTION	//Provento"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("DESCON"):GetValue(.T.)}	BREAK oBreakCc TITLE OemToAnsi(STR0025) PICTURE "@E 9,999,999,999,999.99"	NO END REPORT	NO END SECTION	//"Desconto"                                                               
EndIf

If nOrdem == 5 .Or. nOrdem == 6 .Or. nOrdem == 7 .Or. nOrdem == 8		//Departamento

	If nOrdem == 5 .Or. nOrdem == 6
		cTitulo 	+= " - " + OemToAnsi(STR0021)
	EndIf
	
	cCpoQuebra	:= "RA_DEPTO"
	oSectDept:SetCharSeparator(": ")
	
	DEFINE BREAK oBreakDp  OF oSectDept WHEN {||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_CC+(cAliasQry)->QB_DEPTO} TITLE OemToAnsi(STR0010) //"Total do Departamento"
	
	DEFINE FUNCTION NAME "DTOTHORAS"  FROM oSectIncid:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
	DEFINE FUNCTION NAME "DTOTDIAS"   FROM oSectIncid:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"
	DEFINE FUNCTION NAME "DPROVVALOR" FROM oSectIncid:Cell("PROVEN") FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectIncid:Cell("SINAL" ):GetText() == "1" } 	//"Provento:"
	DEFINE FUNCTION NAME "DDESCVALOR" FROM oSectIncid:Cell("DESCON") FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectIncid:Cell("SINAL" ):GetText() == "2" } 	//"Desconto:
	
	oBreakDp:OnBreak({|x,y|cTitDp:=OemToAnsi(STR0010) + " " + SUBSTR(x, 18, 9)})	//Corte da string da quebra para imprimir apenas o codigo do departamento
	oBreakDp:SetTotalText({||cTitDp})	//"Total do Departamento "
	oBreakDp:SetTotalInLine(.F.)
	oBreakDp:OnPrintTotal({|| oReport:SkipLine() })
   	
	DEFINE COLLECTION OF oSectIncid FUNCTION COUNT FORMULA {|| oSectIncid:Cell("PD"):GetText() + " - " + oSectIncid:Cell("DESC"):GetText()} CONTENT {|| oSectIncid:Cell("PD"):GetText()} BREAK oBreakDp TITLE OemToAnsi(STR0013) PICTURE "9999"	NO END REPORT	NO END SECTION	//"Verba"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("HORAS" ):GetValue(.T.)}	BREAK oBreakDp TITLE OemToAnsi(STR0022) PICTURE "@E 9,999,999.99"		NO END REPORT	NO END SECTION	//"Horas"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("DIAS"  ):GetValue(.T.)}	BREAK oBreakDp TITLE OemToAnsi(STR0023) PICTURE "@E 9,999,999.99"		NO END REPORT	NO END SECTION	//"Dias"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("PROVEN"):GetValue(.T.)}	BREAK oBreakDp TITLE OemToAnsi(STR0024) PICTURE "@E 9,999,999,999,999.99"	NO END REPORT	NO END SECTION	//Provento"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("DESCON"):GetValue(.T.)}	BREAK oBreakDp TITLE OemToAnsi(STR0025) PICTURE "@E 9,999,999,999,999.99"	NO END REPORT	NO END SECTION	//"Desconto"

EndIf

If nOrdem == 9 .Or. nOrdem == 10 //Loc Pago
	cTitulo 	+= " - " + OemToAnsi(IIf(cPaisLoc $ "COL", STR0044, STR0035)) //"Loc.Pago" - Para COL se utiliza "Centro Trab."
	DEFINE BREAK oBreakRgc OF oSectRgc WHEN  oSectRgc:Cell("RGC_KEYLOC" ) TITLE OemToAnsi(STR0036) //"Total da Loc Pago "
	DEFINE FUNCTION NAME "CTOTHORAS"  FROM oSectIncid:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakRgc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
	DEFINE FUNCTION NAME "CTOTDIAS"   FROM oSectIncid:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakRgc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"
	DEFINE FUNCTION NAME "CPROVVALOR" FROM oSectIncid:Cell("PROVEN") FUNCTION SUM     BREAK oBreakRgc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectIncid:Cell("SINAL" ):GetText() == "1" } 	//"Provento:"
	DEFINE FUNCTION NAME "CDESCVALOR" FROM oSectIncid:Cell("DESCON") FUNCTION SUM     BREAK oBreakRgc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectIncid:Cell("SINAL" ):GetText() == "2" } 	//"Desconto:

	oBreakRgc:OnBreak({|x,y| cTitCC:=OemToAnsi(STR0036)+" "+x})	//"Total da Loc Pago"
   	oBreakRgc:SetTotalText({||cTitCC})
   	oBreakRgc:SetTotalInLine(.F.)   
   	
	DEFINE COLLECTION OF oSectIncid FUNCTION COUNT FORMULA {|| oSectIncid:Cell("PD"):GetText() + " - " + oSectLanc:Cell("DESC"):GetText()} CONTENT {|| oSectLanc:Cell("PD"):GetText()} BREAK oBreakRgc TITLE OemToAnsi(STR0005) PICTURE "9999"	NO END REPORT	NO END SECTION	//"Verba"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("HORAS" ):GetValue(.T.)}	BREAK oBreakRgc TITLE OemToAnsi(STR0022) PICTURE "@E 9,999,999.99"		NO END REPORT	NO END SECTION	//"Horas"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("DIAS"  ):GetValue(.T.)}	BREAK oBreakRgc TITLE OemToAnsi(STR0023) PICTURE "@E 9,999,999.99"		NO END REPORT	NO END SECTION	//"Dias"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("PROVEN"):GetValue(.T.)}	BREAK oBreakRgc TITLE OemToAnsi(STR0024) PICTURE "@E 9,999,999,999,999.99"	NO END REPORT	NO END SECTION	//Provento"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("DESCON"):GetValue(.T.)}	BREAK oBreakRgc TITLE OemToAnsi(STR0025) PICTURE "@E 9,999,999,999,999.99"	NO END REPORT	NO END SECTION	//"Desconto"                                                                                                                            
EndIf  

If nOrdem == 11 .Or. nOrdem == 12 //Reg Patronal
	cTitulo 	+= " - " + OemToAnsi(STR0037)
	DEFINE BREAK oBreakRco OF oSectRco WHEN  oSectRco:Cell("RCO_CODIGO" ) TITLE OemToAnsi(STR0039) //"Total do Reg Patronal "
	DEFINE FUNCTION NAME "CTOTHORAS"  FROM oSectIncid:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakRco NO END SECTION NO END REPORT TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
	DEFINE FUNCTION NAME "CTOTDIAS"   FROM oSectIncid:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakRco NO END SECTION NO END REPORT TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"
	DEFINE FUNCTION NAME "CPROVVALOR" FROM oSectIncid:Cell("PROVEN") FUNCTION SUM     BREAK oBreakRco NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectIncid:Cell("SINAL" ):GetText() == "1" } 	//"Provento:"
	DEFINE FUNCTION NAME "CDESCVALOR" FROM oSectIncid:Cell("DESCON") FUNCTION SUM     BREAK oBreakRco NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectIncid:Cell("SINAL" ):GetText() == "2" } 	//"Desconto:

	oBreakRco:OnBreak({|x,y| cTitCC:=OemToAnsi(STR0039)+" "+x})	//"Total Reg Patronal"
   	oBreakRco:SetTotalText({||cTitCC})
   	oBreakRco:SetTotalInLine(.F.)                                                                

	DEFINE COLLECTION OF oSectIncid FUNCTION COUNT FORMULA {|| oSectIncid:Cell("PD"):GetText() + " - " + oSectLanc:Cell("DESC"):GetText()} CONTENT {|| oSectLanc:Cell("PD"):GetText()} BREAK oBreakRco TITLE OemToAnsi(STR0005) PICTURE "9999"	NO END REPORT	NO END SECTION	//"Verba"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("HORAS" ):GetValue(.T.)}	BREAK oBreakRco TITLE OemToAnsi(STR0022) PICTURE "@E 9,999,999.99"		NO END REPORT	NO END SECTION	//"Horas"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("DIAS"  ):GetValue(.T.)}	BREAK oBreakRco TITLE OemToAnsi(STR0023) PICTURE "@E 9,999,999.99"		NO END REPORT	NO END SECTION	//"Dias"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("PROVEN"):GetValue(.T.)}	BREAK oBreakRco TITLE OemToAnsi(STR0024) PICTURE "@E 9,999,999,999,999.99"	NO END REPORT	NO END SECTION	//Provento"
	DEFINE COLLECTION OF oSectIncid FUNCTION SUM   FORMULA {|| oSectIncid:Cell("PD"):GetText()} CONTENT {|| oSectIncid:Cell("DESCON"):GetValue(.T.)}	BREAK oBreakRco TITLE OemToAnsi(STR0025) PICTURE "@E 9,999,999,999,999.99"	NO END REPORT	NO END SECTION	//"Desconto"                                                                                                                            
EndIf

If nOrdem == 13	//Verba
	cTitulo 	+= " - " + OemToAnsi(STR0032)	//"Por Verba"
	oSectIncid:Cell("PD"        ):Disable()
	oSectIncid:Cell("DESC"      ):Disable()
	oSectIncid:Cell("RA_FILIAL" ):Enable()
	oSectIncid:Cell("RA_MAT"    ):Enable()
	oSectIncid:Cell("RA_NOME"   ):Enable()
		
	oSectVerb:SetCharSeparator(": ")
	DEFINE BREAK oBreakPd OF oSectVerb WHEN  {||(cAliasQry)->RV_COD} TITLE OemToAnsi(STR0033) //"Total da Verba"
		DEFINE FUNCTION NAME "VTOTHORAS"  FROM oSectIncid:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakPd NO END SECTION NO END REPORT TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
		DEFINE FUNCTION NAME "VTOTDIAS"   FROM oSectIncid:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakPd NO END SECTION NO END REPORT TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"
		DEFINE FUNCTION NAME "VPROVVALOR" FROM oSectIncid:Cell("PROVEN") FUNCTION SUM     BREAK oBreakPd NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" 	//"Provento:"
		DEFINE FUNCTION NAME "VDESCVALOR" FROM oSectIncid:Cell("DESCON") FUNCTION SUM     BREAK oBreakPd NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" 	//"Desconto:
		oBreakPd:OnBreak({|x,y|cTitPd:=OemToAnsi(STR0033)+" "+x})	//"Total da Verba"
    	oBreakPd:SetTotalText({||cTitPd})
    	oBreakPd:SetTotalInLine(.F.)
    	oBreakPd:OnPrintTotal({|| oReport:SkipLine() })
Else
	oSectFunc:Cell("RA_MAT"    ):Enable()
	oSectFunc:Cell("RA_NOME"   ):Enable()
	If lSalario
		oSectFunc:Cell("RA_HRSMES" ):Enable()
		oSectFunc:Cell("RA_SALARIO"):Enable()
	Else
		oSectFunc:Cell("RA_HRSMES" ):Disable()
		oSectFunc:Cell("RA_SALARIO"):Disable()
	EndIf 

	DEFINE BREAK oBreakFun OF oSectFunc WHEN  {||(cAliasQry)->RA_MAT} TITLE OemToAnsi(STR0018) //"Total do Funcionário "
		DEFINE FUNCTION NAME "UTOTHORAS"  FROM oSectIncid:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
		DEFINE FUNCTION NAME "UTOTDIAS"   FROM oSectIncid:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"
		DEFINE FUNCTION NAME "UPROVVALOR" FROM oSectIncid:Cell("PROVEN") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectIncid:Cell("SINAL" ):GetText() == "1" } 	//"Provento:"
		DEFINE FUNCTION NAME "UDESCVALOR" FROM oSectIncid:Cell("DESCON") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectIncid:Cell("SINAL" ):GetText() == "2" } 	//"Desconto:
		oBreakFun:OnBreak({|x,y|cTitFun:=OemToAnsi(STR0018)+" "+x})	//"Total do Funcionário"
    	oBreakFun:SetTotalText({||cTitFun})
    	oBreakFun:SetTotalInLine(.F.)
    	oBreakFun:OnPrintTotal({|| oReport:SkipLine() })                                                                                                        
EndIf

if oreport:nDevice <> 4 //impressão diferente de planiha

	DEFINE BREAK oBreakFil OF oReport WHEN {|| (cAliasQry)->RA_FILIAL} TITLE OemToAnsi(STR0030) //"Total da Filial "	

	oBreakFil:OnBreak({|x,y|cTitFil:=OemToAnsi(STR0030)+" "+x})	//"Total da Filial"
	oBreakFil:SetTotalText({||cTitFil})
	oBreakFil:SetTotalInLine(.F.)
	oBreakFil:OnPrintTotal({|| oReport:SkipLine() })

	If lImpEmpr
		
		DEFINE FUNCTION NAME "FTOTHORAS"  FROM oSectIncid:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
		DEFINE FUNCTION NAME "FTOTDIAS"   FROM oSectIncid:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"
		
		If nOrdem == 13
			DEFINE FUNCTION NAME "FPROVVALOR" FROM oSectIncid:Cell("PROVEN") FUNCTION SUM     BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" 	//"Provento:"
			DEFINE FUNCTION NAME "FDESCVALOR" FROM oSectIncid:Cell("DESCON") FUNCTION SUM     BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" 	//"Desconto:
		Else
			DEFINE FUNCTION NAME "FPROVVALOR" FROM oSectIncid:Cell("PROVEN") FUNCTION SUM     BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectIncid:Cell("SINAL" ):GetText() == "1" } 	//"Provento:"
			DEFINE FUNCTION NAME "FDESCVALOR" FROM oSectIncid:Cell("DESCON") FUNCTION SUM     BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectIncid:Cell("SINAL" ):GetText() == "2" } 	//"Desconto:
		EndIf

	EndIf
Endif

If nOrdem == 3 .Or. nOrdem == 5 .Or. nOrdem == 7
	cTitulo += " + " + OemToAnsi(STR0004)	//Matrícula
ElseIf nOrdem == 4 .Or. nOrdem == 6 .Or. nOrdem == 8
	cTitulo += " + " + OemToAnsi(STR0006)	//Nome
EndIf

cSitQuery	:= ""
For nReg:=1 to Len(cSituacao)
	cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cSituacao)
		cSitQuery += "," 
	Endif
Next nReg     

cCatQuery	:= ""
For nReg:=1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCategoria)
		cCatQuery += "," 
	Endif
Next nReg

cFiltro := ""

MakeSqlExpr(cPerg)    

If nOrdem == 1
	cOrdem := "%RGB_PROCES,RA_FILIAL,RA_MAT,RGB_PD%"
ElseIf nOrdem == 2
	cOrdem := "%RGB_PROCES,RA_FILIAL,RA_NOME,RA_MAT,RGB_PD%"
ElseIf nOrdem == 3
	cOrdem := "%RGB_PROCES,RA_FILIAL,RGB_CC,RA_MAT,RGB_PD%"
ElseIf nOrdem == 4
	cOrdem := "%RGB_PROCES,RA_FILIAL,RGB_CC,RA_NOME,RA_MAT,RGB_PD%"
ElseIf nOrdem == 5
	cOrdem := "%RGB_PROCES,RA_FILIAL,RA_DEPTO,RA_MAT,RGB_PD%" 
ElseIf nOrdem == 6
	cOrdem := "%RGB_PROCES,RA_FILIAL,RA_DEPTO,RA_NOME,RA_MAT,RGB_PD%"
ElseIf nOrdem == 7
	cOrdem := "%RGB_PROCES,RA_FILIAL,RGB_CC,RA_DEPTO,RA_MAT,RGB_PD%"
ElseIf nOrdem == 8
	cOrdem := "%RGB_PROCES,RA_FILIAL,RGB_CC,RA_DEPTO,RA_NOME,RGB_PD%"
ElseIf nOrdem == 9
	cOrdem := "%RGB_PROCES,RA_FILIAL,RA_KEYLOC,RA_MAT,RGB_PD%"
ElseIf nOrdem == 10
	cOrdem := "%RGB_PROCES,RA_FILIAL,RA_KEYLOC,RA_NOME,RGB_PD%"  
ElseIf nOrdem == 11
	cOrdem := "%RCO_FILIAL, RCO_CODIGO,RA_FILIAL,RA_MAT,RGB_PD%"
ElseIf nOrdem == 12
	cOrdem := "%RCO_FILIAL, RCO_CODIGO,RA_FILIAL,RA_NOME,RGB_PD%"	
ElseIf nOrdem == 13
	cOrdem := "%RGB_PROCES,RGB_FILIAL,RGB_PD,RGB_MAT%"				
Endif

//se verbas forem informados, tratar para que nao haja duas ou mais verbas iguais
//para nao ocorrer error.log na query
If !lAllVerbas
	For nReg:=1 to Len(cCodigos) step 3
		 cCodPesq := Subs(cCodigos,nReg,3)
       nPosx := aScan( aAuxCods , { |x| x == cCodPesq } )
       If nPosx = 0  
           aAdd( aAuxCods , cCodPesq )
           cAuxCods += cCodPesq
       EndIf 
	Next nReg 
   cCodigos := cAuxCods

	For nReg:=1 to Len(cCodigos) step 3
		cVerQuery += "'"+Subs(cCodigos,nReg,3)+"'"
		If ( nReg+1 ) <= Len(cCodigos)
			cVerQuery += "," 
		Endif
	Next nReg 
	if '*' $ cVerQuery
		cVerQuery	:= Subs(cVerQuery,1,Len(cVerQuery)) 
	else 	
		cVerQuery	:= Subs(cVerQuery,1,Len(cVerQuery)-1) 
	endif 
EndIf
	
//== Verbas
If !lAllVerbas                            
	cFiltro += 	cFiltro + ;
				Iif(!Empty(cVerQuery) .And. !Empty(cFiltro)," AND ","") + ;
				Iif(!Empty(cVerQuery)," RGB.RGB_PD IN ("+cVerQuery+")","")
EndIf
cFiltro	:= 	Iif(!Empty(cFiltro  ),"%"+cFiltro+" AND %","%%")

cSitQuery	:= "%" + cSitQuery + "%"
cCatQuery	:= "%" + cCatQuery + "%"

cAliasQry	:= GetNextAlias()

SRA->( dbCloseArea() ) //Fecha o SRA para uso da Query

Sx2ChkModo( "SQB", NIL, .F., @cModAcesso, NIL )
cJoinSQB := "%%"

If nOrdem == 1 .Or. nOrdem == 2
	cCpoAdic	:= "%%"
	cJoin		:= "%%"
	cNotDel		:= "%%"
	BEGIN REPORT QUERY oSectFunc
ElseIf nOrdem == 3 .Or. nOrdem == 4
	cCpoAdic	:= "% , RGB.RGB_CC,CTT.CTT_FILIAL, CTT.CTT_CUSTO %"
	cJoin		:= "% INNER JOIN " + RetSqlName("CTT") + " CTT ON " + cCTTRGB + "	AND RGB.RGB_CC = CTT.CTT_CUSTO %" 
	cNotDel		:= "% AND CTT.D_E_L_E_T_= ' ' %"
	BEGIN REPORT QUERY oSectCcus
ElseIf nOrdem == 5 .Or. nOrdem == 6
	cCpoAdic	:= "% , SQB.QB_FILIAL, SQB.QB_DEPTO, SQB.QB_DESCRIC %"
	cJoin		:= "%%"
	cNotDel		:= "% AND SQB.D_E_L_E_T_= ' ' %"
	cJoinSQB	:= "% INNER JOIN " + RetSqlName("SQB") + " SQB ON SRA.RA_DEPTO = SQB.QB_DEPTO"
	cJoinSQB 	+=  " AND " + cSQBSRA + "%" 
	BEGIN REPORT QUERY oSectDept
ElseIf nOrdem == 7 .Or. nOrdem == 8
	cCpoAdic	:= "% , RGB.RGB_CC CCUSTO,CTT.CTT_FILIAL, CTT.CTT_CUSTO"  
	cCpoAdic	+= "  , SQB.QB_FILIAL, SQB.QB_CC, SQB.QB_DEPTO, SQB.QB_DESCRIC %"
	cJoinSQB	:= "% INNER JOIN " + RetSqlName("SQB") + " SQB ON SRA.RA_DEPTO = SQB.QB_DEPTO "
	cJoinSQB 	+=  " AND " + cSQBSRA + "%" 	
	cJoin		:= "% INNER JOIN " + RetSqlName("CTT") + " CTT ON " + cCTTRGB + "	AND RGB.RGB_CC = CTT.CTT_CUSTO%"	
	cNotDel		:= "% AND CTT.D_E_L_E_T_= ' '"
	cNotDel		+= "  AND SQB.D_E_L_E_T_= ' ' %"
	BEGIN REPORT QUERY oSectCcus
ElseIf nOrdem == 9 .Or. nOrdem == 10
	cCpoAdic	:= "% , SRA.RA_KEYLOC, RGC.RGC_FILIAL, RGC.RGC_KEYLOC, RGC.RGC_DESLOC %"
	cJoin		:= "% INNER JOIN " + RetSqlName("RGC") + " RGC ON " + cRGCSRA + " AND SRA.RA_KEYLOC = RGC.RGC_KEYLOC %"
	cNotDel		:= "% AND RGC.D_E_L_E_T_= ' ' %"
	BEGIN REPORT QUERY oSectRgc 
ElseIf nOrdem == 11 .Or. nOrdem == 12   
	cCpoAdic	:= "% , SRA.RA_CODRPAT, RCO.RCO_FILIAL, RCO.RCO_CODIGO, RCO.RCO_NREPAT, RCO.RCO_NOME %"
	cJoin		:= "% INNER JOIN " + RetSqlName("RCO") + " RCO ON" + cRCOSRA + " AND SRA.RA_CODRPAT = RCO.RCO_CODIGO %"
	cNotDel		:= "% AND RCO.D_E_L_E_T_= ' ' %"
	BEGIN REPORT QUERY oSectRco
ElseIf nOrdem == 13
	cFilJoin	:= ""
	cCpoAdic	:= "%, SRV.RV_FILIAL, SRV.RV_COD %"
	cJoin		:= "%%"
	cNotDel		:= "% AND SRV.D_E_L_E_T_= ' ' %"
	BEGIN REPORT QUERY oSectVerb 
EndIf

cJoin		:= Iif(Empty(cOrgJoin),cJoin,Left(AllTrim(cJoin),Len(AllTrim(cJoin))-1)+cOrgJoin+"%")
//cFilPd	    := xFilial("SRV",SRA->RA_FILIAL)  
		
BeginSql alias cAliasQry
	
	SELECT	SRA.RA_FILIAL,  SRA.RA_MAT, SRA.RA_CC, SRA.RA_NOME, SRA.RA_DEPTO, SRA.RA_HRSMES, 
			SRA.RA_SALARIO, RGB.RGB_FILIAL, RGB.RGB_MAT, RGB.RGB_PROCES, RGB.RGB_PERIOD, 
			RGB.RGB_SEMANA, RGB.RGB_ROTEIR, RGB.RGB_PD, RGB.RGB_VALOR, RGB.RGB_HORAS, RGB.RGB_TIPO1,
			SRV.RV_TIPO, SRV.RV_TIPOCOD, SRV.RV_DESC	 %exp:cCpoAdic%
	FROM %table:SRA% SRA	
		INNER JOIN %table:RGB% RGB ON SRA.RA_FILIAL = RGB.RGB_FILIAL AND SRA.RA_MAT = RGB.RGB_MAT 
		%exp:cJoin% 
		INNER JOIN %table:SRV% SRV ON %exp:cSRVSRA%/*SRV.RV_FILIAL = %exp:cFilPd%*/ AND SRV.RV_TIPOCOD IN ('1','2') AND SRV.RV_COD = RGB.RGB_PD
		%exp:cJoinSQB%									
	WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery )%) AND
	   		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery )%) AND
	   		RGB.RGB_PROCES =  (%exp:Upper(cProcesso )%) AND
	   		RGB.RGB_PERIOD =  (%exp:Upper(cPeriodo  )%) AND
	   		RGB.RGB_ROTEIR =  (%exp:Upper(cRot  )%) AND
	   		RGB.RGB_SEMANA =  (%exp:Upper(cPagamento)%) AND  
	    	%exp:Upper(cFiltro)%	                   
	   		SRA.%notDel%   AND RGB.%notDel% AND SRV.%notDel% %exp:cNotDel%
	ORDER BY %exp:cOrdem%
EndSql

If nOrdem == 1 .Or. nOrdem == 2

	END REPORT QUERY oSectFunc PARAM mv_par01, mv_par02, mv_par03, mv_par04, mv_par05
	//-- Funcionário x Lançamentos
	oSectIncid:SetParentQuery()
	oSectIncid:SetParentFilter({|cParam|RGB_FILIAL+RGB_MAT == cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT})

ElseIf nOrdem == 3 .Or. nOrdem == 4
	
	END REPORT QUERY oSectCcus PARAM mv_par01, mv_par02, mv_par03, mv_par04, mv_par05
	//-- C.Custo x Matrícula
	oSectFunc:SetParentQuery()    
	oSectFunc:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_CC==cParam },{||(cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO}) 
	//As filiais devem ser da mesma tabela por motivos de compatibilidade devido a Gestão Corporativa.
	
	//-- Matrícula x Lançamentos
	oSectIncid:SetParentQuery()
	oSectIncid:SetParentFilter({|cParam|(cAliasQry)->RGB_FILIAL+(cAliasQry)->RGB_CC+(cAliasQry)->RGB_MAT==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_CC+(cAliasQry)->RA_MAT})
	
ElseIf nOrdem == 5 .Or. nOrdem == 6
	
	END REPORT QUERY oSectDept PARAM mv_par01, mv_par02, mv_par03, mv_par04, mv_par05
	//-- Depto x Matrícula
	oSectFunc:SetParentQuery()    
	oSectFunc:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_DEPTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->QB_DEPTO})
	//-- Matrícula x Lançamentos
	oSectIncid:SetParentQuery()
	oSectIncid:SetParentFilter({|cParam|(cAliasQry)->RGB_FILIAL+(cAliasQry)->RGB_MAT==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT})

ElseIf nOrdem == 7 .Or. nOrdem == 8
	
	END REPORT QUERY oSectCcus PARAM mv_par01, mv_par02, mv_par03, mv_par04, mv_par05
	
	//-- C.Custo x Depto
	oSectDept:SetParentQuery()
	oSectDept:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO})	
		
	//-- Depto x Matrícula
	oSectFunc:SetParentQuery()    
	oSectFunc:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_DEPTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->QB_DEPTO})	
	
	//-- Matrícula x Incidências
	oSectIncid:SetParentQuery()
	oSectIncid:SetParentFilter({|cParam|(cAliasQry)->RGB_FILIAL+(cAliasQry)->CCUSTO+;
										(cAliasQry)->RA_DEPTO+(cAliasQry)->RGB_MAT==cParam},;
								{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_CC+(cAliasQry)->RA_DEPTO+(cAliasQry)->RA_MAT})	
	
ElseIf nOrdem == 9 .Or. nOrdem == 10
	
	END REPORT QUERY oSectRgc PARAM mv_par01, mv_par02, mv_par03, mv_par04, mv_par05
	//-- LocPago x Matrícula              
	oSectFunc:SetParentQuery()    
	oSectFunc:SetParentFilter({|cParam|RA_KEYLOC==cParam},{||(cAliasQry)->RGC_KEYLOC})
	//-- Matrícula x Lançamentos
	oSectIncid:SetParentQuery()
	oSectIncid:SetParentFilter({|cParam|RGB_FILIAL+RGB_MAT==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT})

ElseIf nOrdem == 11 .Or. nOrdem == 12
	
	END REPORT QUERY oSectRco PARAM mv_par01, mv_par02, mv_par03, mv_par04, mv_par05
	//-- RegPatronal x Matrícula
	oSectFunc:SetParentQuery()    
	oSectFunc:SetParentFilter({|cParam|RA_FILIAL+RA_CODRPAT==cParam},{||(cAliasQry)->RCO_FILIAL+(cAliasQry)->RCO_CODIGO})
	//-- Matrícula x Lançamentos
	oSectIncid:SetParentQuery()
	oSectIncid:SetParentFilter({|cParam|RGB_FILIAL+RGB_MAT==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT})
		
ElseIf nOrdem == 13

	END REPORT QUERY oSectVerb PARAM mv_par01, mv_par02, mv_par03, mv_par04, mv_par05
	//-- Verba x Lançamentos 
	oSectIncid:SetParentQuery()
	oSectIncid:SetParentFilter({|cParam|RA_FILIAL+RGB_PD==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RV_COD})
	
EndIf

//-- Seleciona tabela de funcionarios  
dbSelectArea( "SM0" )
dbSelectArea( cAliasQry )

oReport:OnPageBreak({|| fGR104Header(oReport) })

//-- Altera o titulo do relatorio
oReport:SetTitle(cTitulo)

If nOrdem == 1 .Or. nOrdem == 2
	oSectFunc:Print()
ElseIf nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 7 .Or. nOrdem == 8
	oSectCcus:Print()
ElseIf nOrdem == 5 .Or. nOrdem == 6  
	oSectDept:Print()
ElseIf nOrdem == 13 
	oSectVerb:Print()  
ElseIf nOrdem == 9 .Or. nOrdem == 10
	oSectRgc:Print()                 
ElseIf nOrdem == 11 .Or. nOrdem == 12
	oSectRco:Print()	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ fQueryVisao   ³ Autor ³ Tania Bronzeri        ³ Data ³25/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Pesquisa Visao / Departamento para a Arquitetura Organizacional.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER104                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fQueryVisao() 

Local aArea		:= GetArea()
Local aChave	:= array(2)
Local cQuery 	:= ""
Local cQryAlias	:= GetNextAlias()

dbSelectArea("RD4")
dbCloseArea()               
cQuery := "SELECT RD4.RD4_CHAVE, RD4.RD4_FILIDE FROM " + RetSqlName("RD4") + " RD4 "
cQuery += "INNER JOIN " + RetSqlName("RDK") + " RDK "
cQuery += "ON RD4_CODIGO = RDK_CODIGO AND RD4_FILIAL = RDK_FILIAL "
cQuery += "WHERE RD4_CODIDE = '" + cCodDepto + "' AND RDK_HIERAR = '1' AND RDK_CODIGO = '" + cCodVisao + "' "
cQuery += "AND RD4.D_E_L_E_T_ = ' ' AND RDK.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQryAlias,.T.,.T.)

aChave[1]	:= (cQryAlias)->RD4_FILIDE
aChave[2]	:= (cQryAlias)->RD4_CHAVE

(cQryAlias)->(DbCloseArea())

RestArea( aArea )

Return aChave

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…cao  ³fGR106join  ³ Autor ³  Equipe RH           ³ Data ³ 19/09/2012       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrica‡…o ³O tratamento a seguir deve-se ao problema do embedded SQL não      ³±±
±±³          ³converter clausula "SUBSTRING" no INNER JOIN, ao usar banco de dados ³±±
±±³          ³ORACLE. E segundo sustentaçao FRAMEWORK, devemos alterar consulta SQL³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Parametro ³ExpC1 - Obrigatorio - Variável com Primeira tabela do "inner join"   ³±±
±±³          ³ExpC2 - Obrigatorio - Variável com Segunda  tabela do "inner join"   ³±±
±±³          ³ExpC3 - Variável indica se retorno deverá conter "%   %". Caso vazio ³±±
±±³          ³        o seu valor padrão será "".                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER106                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGR104join(cTabela1, cTabela2,cEmbedded)
Local cFiltJoin := ""

Default cEmbedded := ""

cFiltJoin := cEmbedded + FWJoinFilial(cTabela1, cTabela2) + cEmbedded	

If ( TCGETDB() $ 'DB2|ORACLE|POSTGRES|INFORMIX' )
	cFiltJoin := STRTRAN(cFiltJoin, "SUBSTRING", "SUBSTR")
EndIf

Return (cFiltJoin)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…cao  ³fGR104Header  ³ Autor ³  Esther Viveiro      ³ Data ³ 06/06/2014        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrica‡…o ³Definição do cabeçalho do relatório.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Parametro ³oReport    - Obrigatorio - objeto com as informações do realtório.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER104                                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGR104Header(oReport)
	
	oReport:SkipLine()
	oReport:PrintText(OemToAnsi(STR0014) + ': ' + cProcesso + space(05)  + ; //"Processo"
						OemToAnsi(STR0015) + ': ' + cPeriodo + space(05)   + ; //"Período"
						OemToAnsi(STR0016) + ': ' + cPagamento + space(05) +; //"Pagamento"
						OemToAnsi(STR0017) + ': ' + cRot ; //"Roteiro"
						,/*nRow*/,/*nCol*/,/*nClrText*/,/*cStyle*/,/*nCells*/,.F.)
	
	If lUsaArqui .And. !Empty(mv_par16) .AND. !Empty(mv_par17)
		oReport:PrintText(OemToAnsi(STR0040) + cVisaoDepto ; //"Arquitetura Organizacional - " 
		,/*nRow*/,/*nCol*/,/*nClrText*/,/*cStyle*/,/*nCells*/,.F.)
	EndIf 
	
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()
 
Return
