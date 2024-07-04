#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER105.CH"
#INCLUDE "Report.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER105   ºAutor  ³Tania Bronzeri          º Data ³ 29/10/2007   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para tratar a emissao do relatorio de Incidências.       º±±
±±º          ³ Formato Horizontal                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Folha de pagamento  - Mexico                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³ Data     ³ BOPS/FNC   | Motivo da Alteracao                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±  
±±ºCarlos E. O.³17/09/2013³M12RH01     ³Ajustes referentes a ordem de impressaoº±±
±±º            ³          ³184703      ³escolhida. Checa existencia do campo   º±±
±±º            ³          ³            ³RA_CODRPAT. Retirada funcao AjustSX1() º±±
±±ºCecilia Car.³16/06/2014³M12RH01     ³Correcao para que nao ocorra error.log º±±
±±º            ³          ³184703      ³ao imprimir relatorio num ambiente que º±±
±±º            ³          ³            ³possui integracao com SIGAORG.         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER105()
	Local	oReport   
	Local	aArea 		:= GetArea()
	Private cPerg		:= "GPE105R"
	Private cCond       := "1" // Seta variavel para funcao gpRCHFiltro utilizada na pergunta Periodo, para mostrar apenas periodos abertos	
	Private cProcesso	:= ""
	Private cPeriodo	:= ""
	Private cPagamento	:= ""
	Private cRot        := ""   	
	Private cAliasQry	:= ""
	Private cRepete		:= ""
	Private cTitulo		:= OemToAnsi(STR0012)	//"Incidências por Verba no Período"
	Private nOrdem		:= 1
	Private lRepete		:= .F.
	Private lImpEmpr  	:= .T.
	Private lVlDiaHor	:= .F.
	Private lUsaArqui	:= Iif(GetMv("MV_ORGCFG",,"0")=="0",.F.,.T.)	// 0-Nao utiliza	1-Utiliza Postos e Deptos	2-Utiliza so Deptos.
	Private aOrd		   := {}
    Private cVisaoDepto := ""

	Private cVerQry		:= ""
	Private cVerQry0	:= ""
	Private cFiltro 	:= ""  
	Private cSitQuery	:= ""
	Private cCatQuery	:= ""
	Private aQryVerba	:= {}
	Private aVerQry		:= {}

	Private cUnion		:= "" 
	Private cJoinDepto	:= "" 
	Private cOrgJoin	:= ""
	Private cSum		:= ""
	Private cDiasHor	:= ""
	Private cQVerba		:= ""
	Private cCellVerba	:= ""
	Private cTitFil		:= ""
	Private cTitCC		:= ""
	Private cTitDp		:= ""
	Private cCodigos	:= ""
	Private cOrdem		:= ""
	Private cCpoQuebra	:= "" 
	Private cCpoDelim	:= "" 
	Private cCpoAdic	:= ""
	Private cSum		:= ""
	Private cChaveArq   := ""
	Private aChaveArq   := {}

	Private cAuxCods    := ""
	
	Private lTpHora		:= .F.
	Private aPosics		:= Array(3)
	Private cCodPesq    := ""
	Private aAuxCods    := {}

	Private lImpLinFun  := .F.   
	Private aVerbas		:= {}

	Private cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0003) + OemToAnsi(STR0002) 
					//"Relatorio por Codigo" ### "Este relatório imprime as incidências por período, referente às verbas selecionadas." ### "Ser  impresso de acordo com os parâmetros solicitados pelo usu rio."
           
	
	Aadd(aOrd, OemToAnsi(STR0004))													//1 - "Matricula"	
	Aadd(aOrd, OemToAnsi(STR0006))													//2 - "Nome"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0004))							//3 - "C.Custo + Matrícula"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0006))							//4 - "C.Custo + Nome"
	Aadd(aOrd, OemToAnsi(STR0008)+"+"+OemToAnsi(STR0004))							//5 - "Depto + Matricula"
	Aadd(aOrd, OemToAnsi(STR0008)+"+"+OemToAnsi(STR0006)) 							//6 - "Depto + Nome"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0008)+"+"+OemToAnsi(STR0004))	//7 - "C.Custo + Depto + Matricula"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0008)+"+"+OemToAnsi(STR0006))	//8 - "C.Custo + Depto + Nome"

	dbSelectArea("SRA")	
	If SRA->(FIELDPOS("RA_CODRPAT")) > 0//Se existe o campo - tratamento para o Mexico
		
		Aadd(aOrd, OemToAnsi(STR0026)+"+"+OemToAnsi(STR0004))                       		//9 - "Reg. Patronal+Matricula"
		Aadd(aOrd, OemToAnsi(STR0026)+"+"+OemToAnsi(STR0006))                       		//10 - "Reg. Patronal+Nome"						
	
	Endif	
	
	Pergunte(cPerg,.F.)
	
	cProcesso	:= mv_par08
	cRot 		:= mv_par09 	                  

	lImpLinFun := MsgYesNo("Imprime um funcionário por linha? Caso contrário, a impressão será agrupada/quebrada por funcionário.")
	
	if lImpLinFun
		oReport := RptImpLin()
	Else
		oReport := ReportDef()
	Endif

	oReport:SetLandScape()
	oReport:PrintDialog()
	
	RestArea( aArea )
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ RptImpLin  ³ Autor ³ Tania Bronzeri        ³ Data ³29/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Incidências por Verba Horizontal                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER105                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RptImpLin()

Local oReport 
Local oSecFun 
Local oSecNom
Local oSecCtt
Local oSecSqb 
Local oSectionh        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao dos componentes de impressao                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE REPORT oReport NAME "GPER105" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| R105Imp(oReport)} DESCRIPTION cDesc1	

	oReport:SetTotalInLine(.F.)     // para totalizar em linhas
	oReport:nFontBody	:= 7
	oReport:SetDynamic()

	//1
	DEFINE SECTION oSecFun OF oReport TITLE OemToAnsi(STR0022) TABLES "SRA", "SQB" ORDERS aOrd	//Processo / Periodo

		DEFINE CELL NAME "RA_FILIAL"  OF oSecFun ALIAS "SRA" BLOCK {||(cAliasQry)->RA_FILIAL} TITLE OemToAnsi(STR0020)	//"Fil."		
		DEFINE CELL NAME "RA_MAT"     OF oSecFun ALIAS "SRA" TITLE OemToAnsi(STR0011)	//"Matric."
		DEFINE CELL NAME "RA_NOME"    OF oSecFun ALIAS "SRA" 
		DEFINE CELL NAME "SINAL"      OF oSecFun TITLE "."
		DEFINE CELL NAME "STATUS"     OF oSecFun TITLE "."
		DEFINE CELL NAME "RA_CC"      OF oSecFun ALIAS "SRA" 
		DEFINE CELL NAME "RA_DEPTO"   OF oSecFun ALIAS "SRA"
		DEFINE CELL NAME "QB_DESCRIC" OF oSecFun ALIAS "SQB"

		oSecFun:SetTotalInLine(.F.)
		oSecFun:Cell("SINAL"     ):Disable()              
		oSecFun:Cell("STATUS"    ):Disable()
		oSecFun:Cell("QB_DESCRIC"):Disable()
		oSecFun:Disable()
		oSecFun:SetDynamicKey(OemToAnsi(STR0004))	//"Matrícula"
 
		
	//2
	DEFINE SECTION oSecNom OF oReport TITLE OemToAnsi(STR0022) TABLES "SRA", "SQB" ORDERS aOrd	//Processo / Periodo

		DEFINE CELL NAME "RA_FILIAL"  OF oSecNom ALIAS "SRA" BLOCK {||Iif(lRepete,"",(cAliasQry)->RA_FILIAL)} TITLE OemToAnsi(STR0020)	//"Fil."
		DEFINE CELL NAME "RA_NOME"    OF oSecNom ALIAS "SRA" 
		DEFINE CELL NAME "RA_MAT"     OF oSecNom ALIAS "SRA" TITLE OemToAnsi(STR0011)	//"Matric."
		DEFINE CELL NAME "SINAL"      OF oSecNom TITLE "."
		DEFINE CELL NAME "STATUS"     OF oSecNom TITLE "."
		DEFINE CELL NAME "RA_CC"      OF oSecNom ALIAS "SRA" 
		DEFINE CELL NAME "RA_DEPTO"   OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "QB_DESCRIC" OF oSecNom ALIAS "SQB"

		oSecNom:SetTotalInLine(.F.)
		oSecNom:Cell("SINAL"     ):Disable()
		oSecNom:Cell("STATUS"    ):Disable()
		oSecNom:Cell("QB_DESCRIC"):Disable()
		oSecNom:Disable()
		oSecNom:SetDynamicKey(OemToAnsi(STR0006))	//"Nome"

	//3
	DEFINE SECTION oSecCtt OF oReport TABLES "SRA" ORDERS aOrd TITLE OemToAnsi(STR0007) TOTAL IN COLUMN // "Centro de Custo"
		
		DEFINE CELL NAME "RA_FILIAL" 	OF oSecCtt ALIAS "SRA"
		DEFINE CELL NAME "RA_CC"    	OF oSecCtt BLOCK {|| (cAliasQry)->CCUSTO}//ALIAS "SRA" 
		DEFINE CELL NAME "SINAL"    	OF oSecCtt TITLE "."
		DEFINE CELL NAME "STATUS"   	OF oSecCtt TITLE "."

		oSecCtt:Cell("SINAL"     ):Disable()
		oSecCtt:Cell("STATUS"    ):Disable()
		oSecCtt:Disable()
		oSecCtt:SetDynamicKey(OemToAnsi(STR0005))	//"C.Custo"

	//4
	DEFINE SECTION oSecSqb OF oReport TABLES "SRA", "SQB" ORDERS aOrd TITLE OemToAnsi(STR0009) TOTAL IN COLUMN // "Departamento"
		
		DEFINE CELL NAME "RA_FILIAL" 	OF oSecSqb ALIAS "SRA"
		DEFINE CELL NAME "RA_DEPTO"   	OF oSecSqb ALIAS "SRA"
		DEFINE CELL NAME "QB_DESCRIC"	OF oSecSqb ALIAS "SQB" //BLOCK {|| (cAliasQry)->QB_DESCRIC}

		oSecSqb:Cell("RA_FILIAL"):Disable()
		oSecSqb:Disable()
		oSecSqb:SetDynamicKey(OemToAnsi(STR0008))	//"Depto."

	//5
	DEFINE SECTION oSecRco OF oReport TABLES "RCO" ORDERS aOrd TITLE OemToAnsi(STR0025) TOTAL IN COLUMN // "Registro Patronal"
		
		DEFINE CELL NAME "RCO_FILIAL" 	OF oSecRco ALIAS "RCO"
		DEFINE CELL NAME "RCO_CODIGO"  	OF oSecRco ALIAS "RCO"
		DEFINE CELL NAME "RCO_NREPAT"	OF oSecRco ALIAS "RCO"
		DEFINE CELL NAME "RCO_NOME" 	OF oSecRco ALIAS "RCO"

		oSecRco:SetLineStyle()                                                         	
		oSecRco:Cell("RCO_FILIAL"):Disable()
		oSecRco:Disable()
		oSecRco:SetDynamicKey(OemToAnsi(STR0026))	//"Reg.Patronal"
		
Return(oReport)


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definição do Layout para a impressao por quebra 
@author  Gisele Nuncherino	
@since   17/09/2018
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport 
Local oSecFun 
Local oSecNom
Local oSecCtt
Local oSecSqb 
Local oSectionh        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao dos componentes de impressao                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE REPORT oReport NAME "GPER105" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| ImpLinFunc(oReport)} DESCRIPTION cDesc1	

	oReport:SetTotalInLine(.F.)     // para totalizar em linhas
	oReport:nFontBody	:= 7
	oReport:SetDynamic()

	//1
	DEFINE SECTION oSecFun OF oReport TITLE OemToAnsi(STR0022) TABLES "SRA", "SQB" ORDERS aOrd	//Processo / Periodo

		DEFINE CELL NAME "RA_FILIAL"  OF oSecFun ALIAS "SRA" BLOCK {||(cAliasQry)->RA_FILIAL} TITLE OemToAnsi(STR0020)	//"Fil."		
		DEFINE CELL NAME "RA_MAT"     OF oSecFun ALIAS "SRA" TITLE OemToAnsi(STR0011)	//"Matric."
		DEFINE CELL NAME "RA_NOME"    OF oSecFun ALIAS "SRA" 
		DEFINE CELL NAME "SINAL"      OF oSecFun TITLE "."
		DEFINE CELL NAME "STATUS"     OF oSecFun TITLE "."
		DEFINE CELL NAME "RA_CC"      OF oSecFun ALIAS "SRA" 
		DEFINE CELL NAME "RA_DEPTO"   OF oSecFun ALIAS "SRA"
		DEFINE CELL NAME "QB_DESCRIC" OF oSecFun ALIAS "SQB"

		oSecFun:SetTotalInLine(.F.)
		oSecFun:Cell("SINAL"     ):Disable()              
		oSecFun:Cell("STATUS"    ):Disable()
		oSecFun:Cell("QB_DESCRIC"):Disable()
		oSecFun:Disable()
		oSecFun:SetDynamicKey(OemToAnsi(STR0004))	//"Matrícula"
 
		
	//2
	DEFINE SECTION oSecNom OF oReport TITLE OemToAnsi(STR0022) TABLES "SRA", "SQB" ORDERS aOrd	//Processo / Periodo

		DEFINE CELL NAME "RA_FILIAL"  OF oSecNom ALIAS "SRA" BLOCK {||Iif(lRepete,"",(cAliasQry)->RA_FILIAL)} TITLE OemToAnsi(STR0020)	//"Fil."
		DEFINE CELL NAME "RA_NOME"    OF oSecNom ALIAS "SRA" 
		DEFINE CELL NAME "RA_MAT"     OF oSecNom ALIAS "SRA" TITLE OemToAnsi(STR0011)	//"Matric."
		DEFINE CELL NAME "SINAL"      OF oSecNom TITLE "."
		DEFINE CELL NAME "STATUS"     OF oSecNom TITLE "."
		DEFINE CELL NAME "RA_CC"      OF oSecNom ALIAS "SRA" 
		DEFINE CELL NAME "RA_DEPTO"   OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "QB_DESCRIC" OF oSecNom ALIAS "SQB"

		oSecNom:SetTotalInLine(.F.)
		oSecNom:Cell("SINAL"     ):Disable()
		oSecNom:Cell("STATUS"    ):Disable()
		oSecNom:Cell("QB_DESCRIC"):Disable()
		oSecNom:Disable()
		oSecNom:SetDynamicKey(OemToAnsi(STR0006))	//"Nome"

	//3
	DEFINE SECTION oSecCtt OF oReport TABLES "SRA" ORDERS aOrd TITLE OemToAnsi(STR0007) TOTAL IN COLUMN // "Centro de Custo"
		
		DEFINE CELL NAME "RA_FILIAL" 	OF oSecCtt ALIAS "SRA"
		DEFINE CELL NAME "RA_CC"    	OF oSecCtt BLOCK {|| (cAliasQry)->CCUSTO}//ALIAS "SRA" 
		DEFINE CELL NAME "SINAL"    	OF oSecCtt TITLE "."
		DEFINE CELL NAME "STATUS"   	OF oSecCtt TITLE "."

		oSecCtt:Cell("SINAL"     ):Disable()
		oSecCtt:Cell("STATUS"    ):Disable()
		oSecCtt:Disable()
		oSecCtt:SetDynamicKey(OemToAnsi(STR0005))	//"C.Custo"

	//4
	DEFINE SECTION oSecSqb OF oReport TABLES "SRA", "SQB" ORDERS aOrd TITLE OemToAnsi(STR0009) TOTAL IN COLUMN // "Departamento"
		
		DEFINE CELL NAME "RA_FILIAL" 	OF oSecSqb ALIAS "SRA"
		DEFINE CELL NAME "RA_DEPTO"   	OF oSecSqb ALIAS "SRA"
		DEFINE CELL NAME "QB_DESCRIC"	OF oSecSqb ALIAS "SQB" //BLOCK {|| (cAliasQry)->QB_DESCRIC}

		oSecSqb:Cell("RA_FILIAL"):Disable()
		oSecSqb:Disable()
		oSecSqb:SetDynamicKey(OemToAnsi(STR0008))	//"Depto."

	//5
	DEFINE SECTION oSecRco OF oReport TABLES "RCO" ORDERS aOrd TITLE OemToAnsi(STR0025) TOTAL IN COLUMN // "Registro Patronal"
		
		DEFINE CELL NAME "RCO_FILIAL" 	OF oSecRco ALIAS "RCO"
		DEFINE CELL NAME "RCO_CODIGO"  	OF oSecRco ALIAS "RCO"
		DEFINE CELL NAME "RCO_NREPAT"	OF oSecRco ALIAS "RCO"
		DEFINE CELL NAME "RCO_NOME" 	OF oSecRco ALIAS "RCO"

		oSecRco:SetLineStyle()                                                         	
		oSecRco:Cell("RCO_FILIAL"):Disable()
		oSecRco:Disable()
		oSecRco:SetDynamicKey(OemToAnsi(STR0026))	//"Reg.Patronal"
		
Return(oReport)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ R105Imp    ³ Autor ³ Tania Bronzeri        ³ Data ³29/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Incidências por Verba                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER105                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R105Imp(oReport)

Local aAreaRep 		:= GetArea()
Local oSectDet  	
Local lShar

Local nPosx     	:= 0
Local nReg			:= 0
Local nCont			:= 0

Private oSectHead 
Private oSectH2


cSituacao   := mv_par06					
cCategoria 	:= mv_par07
cProcesso	:= mv_par08
cRot		:= mv_par09 	                  					
cPeriodo	:= mv_par10        
cPagamento	:= mv_par11        			
cCodigos  	:= AllTrim(mv_par12)			// Codigos ( Verbas )
lImpEmpr  	:= If(mv_par13=1,.T.,.F.)		// Listar total empresa
lVlDiaHor	:= If(mv_par14=1,.F.,.T.)		// Imprime Valor ou Horas/Dias (para verbas do tipo H/D)

If Empty(cCodigos)
	MsgAlert(OemToAnsi(STR0024),OemToAnsi(STR0023))	//"N'ao foi selecionada nenhuma verba para impress'ao." ### "Aten;'ao!"
	RestArea(aAreaRep)
	Return
EndIf

If "*" $ cCodigos
	MsgAlert(OemToAnsi(STR0034),OemToAnsi(STR0023))	//"Máximo de verbas para impressão é 10. Selecione os códigos" ### "Aten;'ao!"
	RestArea(aAreaRep)
	Return
EndIf

If lUsaArqui 	//Se uas Arquitetura Organizadional (SIGAORG)
	cCodVisao	:= mv_par15
   cCodDepto	:= mv_par16
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
    cOrgJoin	+= " ON TRB.RA_DEPTO = TVRD4.RD4_CODIDE "
	 If !lShar
	     cOrgJoin+= " AND TRB.RA_FILIAL = TVRD4.RD4_FILIDE "
	 EndIf

    cVisaoDepto	:=	OemToAnsi(STR0029) + AllTrim(cCodVisao)								
EndIf
       
nOrdem := oReport:GetOrder()

If nOrdem == 1		//Matrícula
	oSectDet 	:= oReport:Section(1)
	
ElseIf nOrdem == 2	//Nome
	oSectDet	:= oReport:Section(2)
	
ElseIf nOrdem == 3	//C.Custo + Matrícula
	oSectHead:= oReport:Section(3)
	oSectHead:SetCols(4)
	oSectHead:SetLineStyle()
	oSectHead:SetCharSeparator(": ")
	oSectDet	:= oReport:Section(1)
			
ElseIf nOrdem == 4	//C.Custo + Nome
	oSectHead:= oReport:Section(3)
	oSectHead:SetCols(4)
	oSectHead:SetLineStyle()
	oSectHead:SetCharSeparator(": ")
	oSectDet	:= oReport:Section(2)
	
ElseIf nOrdem == 5	//Depto + Matrícula
	oSectHead	:= oReport:Section(4)
	oSectDet	:= oReport:Section(1)
	oSectHead:SetCols(4)
	oSectHead:SetLineStyle()
	oSectHead:SetCharSeparator(": ")
	
ElseIf nOrdem == 6	//Depto + Nome
	oSectHead	:= oReport:Section(4)
	oSectDet	:= oReport:Section(2)
	oSectHead:SetCols(4)
	oSectHead:SetLineStyle()
	oSectHead:SetCharSeparator(": ")
	
ElseIf nOrdem == 7 //C.Custo + Depto + Matricula
	oSectHead:= oReport:Section(3)
	oSectHead:SetCols(4)
	oSectHead:SetLineStyle()
	oSectHead:SetCharSeparator(": ")
	
	oSectH2	:= oReport:Section(4)
	oSectH2:SetCols(4)
	oSectH2:SetLineStyle()
	oSectH2:SetCharSeparator(": ")
	
	oSectDet	:= oReport:Section(1)	     
ElseIf nOrdem == 8 //C.Custo + Depto + Nome
	oSectHead:= oReport:Section(3)
	oSectHead:SetCols(4)
	oSectHead:SetLineStyle()
	oSectHead:SetCharSeparator(": ") 
	oSectH2	:= oReport:Section(4)
	oSectH2:SetCols(4)
	oSectH2:SetLineStyle()
	oSectH2:SetCharSeparator(": ")
	oSectDet	:= oReport:Section(2)
		
ElseIf nOrdem == 9 //RegPatronal + Matricula             
	oSectHead:= oReport:Section(5)
	oSectHead:SetLineStyle()
	oSectHead:SetCharSeparator(": ") 
	oSectDet	:= oReport:Section(1)
		    
ElseIf nOrdem == 10 //RegPatronal + Nome
	oSectHead:= oReport:Section(5)
	oSectHead:SetLineStyle()
	oSectHead:SetCharSeparator(": ") 
	oSectDet	:= oReport:Section(2)
	    
EndIf

If !(AllTrim(oReport:Title()) == cTitulo)
	cTitulo	:= oReport:Title()
Endif

If nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 7 .Or. nOrdem == 8

	oSectDet:Cell("RA_CC"):bCellBlock := {|| (cAliasQry)->CCUSTO}
		
	DEFINE BREAK oBreakCC OF oSectHead WHEN  {||(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO} TITLE OemToAnsi(STR0013) //"Total do Centro de Custo "
		
	oBreakCc:OnBreak({|x,y|cTitCC:=OemToAnsi(STR0013)+" "+oSectHead:Cell("RA_CC"):GetText()})
	oBreakCc:SetTotalText({||cTitCC})
	oBreakCc:SetTotalInLine(.F.)
	
Endif

If nOrdem == 5 .Or. nOrdem == 6 .Or. nOrdem == 7 .Or. nOrdem == 8
	
	oSectDet:Cell( "RA_DEPTO"  ):Disable() 
	oSectDet:Cell( "QB_DESCRIC"):Disable()

	If nOrdem == 5 .Or. nOrdem == 6 	
		oSectHead:Cell("QB_DESCRIC"):Enable()
	Endif		

	If nOrdem == 5 .Or. nOrdem == 6 
		DEFINE BREAK oBreakDp OF oSectHead WHEN  {||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_DEPTO} TITLE STR0018 //"Total do Departamento"
		oBreakDp:OnBreak({|x,y|cTitDp:=OemToAnsi(STR0018)+" "+oSectHead:Cell("RA_DEPTO"):GetText()})			
	Else
		DEFINE BREAK oBreakDp OF oSectH2 WHEN  {||(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO+(cAliasQry)->RA_DEPTO} TITLE STR0018 //"Total do Departamento"
		oBreakDp:OnBreak({|x,y|cTitDp:=OemToAnsi(STR0018)+" "+oSectH2:Cell("RA_DEPTO"):GetText()})	
	Endif
	
	oBreakDp:SetTotalText({||cTitDp})
	oBreakDp:SetTotalInLine(.F.)

EndIf
                                  
If nOrdem == 1 .Or. nOrdem == 2
	DEFINE BREAK oBreakFil OF oSectDet  WHEN {||(cAliasQry)->RA_FILIAL} TITLE OemToAnsi(STR0019) //"Total da Filial "	
Else
	DEFINE BREAK oBreakFil OF oReport WHEN {||(cAliasQry)->RA_FILIAL} TITLE OemToAnsi(STR0019) //"Total da Filial "
EndIf
	
oBreakFil:OnBreak({|x,y|cTitFil:=x,	oSectDet:SetHeaderSection(.T.)})	
oBreakFil:SetTotalText({||cTitFil:=OemToAnsi(STR0019)+" "+cTitFil})
oBreakFil:SetTotalInLine(.F.)

For nReg:=1 to Len(cCodigos) step 3
	 cCodPesq := Subs(cCodigos,nReg,3)
    nPosx := aScan( aAuxCods , { |x| x == cCodPesq } )
    If nPosx = 0  
        aAdd( aAuxCods , cCodPesq )
        cAuxCods += cCodPesq
    EndIf 
Next nReg 
cCodigos := cAuxCods

For nCont:= 1 to Len(Alltrim(cCodigos)) Step 3
	cCellVerba	:= Substr(cCodigos,nCont,3)
	If PosSrv(cCellVerba,xFilial("SRA"),"RV_COD" ) == cCellVerba
                          
		lTpHora  := PosSrv(cCellVerba,xFilial("SRA"),"RV_TIPO") == "H" //Verba do tipo Dias/Horas
		
		DEFINE CELL NAME (cCellVerba) OF oSectDet TITLE cCellVerba PICTURE "@E 99,999,999,999.99" SIZE 20 ;
				BLOCK {||(cAliasQry)->&(cCellVerba)}
				
		oSectDet:Cell(cCellVerba):SetHeaderAlign("RIGHT")
		oSectDet:Cell(cCellVerba):SetAutoSize()		
		oSectDet:Cell(cCellVerba):SetTitle(cCellVerba+"-"+DescPd(cCellVerba,xFilial("SRA"),10))	//Cod.+Descricao

		
		If lImpEmpr
			DEFINE FUNCTION NAME ("T"+cCellVerba) FROM oSectDet:Cell(cCellVerba) FUNCTION SUM PICTURE "@E 99,999,999,999.99"	NO END SECTION 
		EndIf
		
		If nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 7 .Or. nOrdem == 8
			DEFINE FUNCTION NAME ("C"+cCellVerba) FROM oSectDet:Cell(cCellVerba) FUNCTION SUM BREAK oBreakCC NO END SECTION NO END REPORT PICTURE "@E 99,999,999,999.99"
		Endif
		  
		If nOrdem == 5 .Or. nOrdem == 6 .Or. nOrdem == 7 .Or. nOrdem == 8
			DEFINE FUNCTION NAME ("D"+cCellVerba) FROM oSectDet:Cell(cCellVerba) FUNCTION SUM BREAK oBreakDp NO END SECTION NO END REPORT PICTURE "@E 99,999,999,999.99"  
		EndIf
		
		DEFINE FUNCTION NAME ("F"+cCellVerba) FROM oSectDet:Cell(cCellVerba) FUNCTION SUM BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 99,999,999,999.99"  

		aAdd(aQryVerba,AllTrim(cCellVerba))                                                               
	EndIf
Next

oSectDet:Cell("RA_MAT"    ):Enable()
oSectDet:Cell("RA_NOME"   ):Enable()

If nOrdem != 1 .And. nOrdem != 2
	oSectDet:Cell("RA_CC"     ):Disable()
	oSectDet:Cell("RA_DEPTO"  ):Disable()
Endif
	
//Monta a query para filtragem dos dados a serem impressos
RetQuery()


//-- Altera o titulo do relatorio
oReport:SetTitle(cTitulo)

If nOrdem == 1 .Or. nOrdem == 2
	BEGIN REPORT QUERY oSectDet
Else
	BEGIN REPORT QUERY oSectHead
EndIf
    
lKEYLOC := SRA->(FIELDPOS("RA_CODRPAT") > 0) //Tratamento para o Mexico
    
If lKEYLOC //cPaisLoc == "MEX"
	BeginSql alias cAliasQry
		SELECT 	TRB.RA_FILIAL, TRB.RA_MAT, TRB.RA_CC,  		TRB.RA_NOME, 	TRB.RA_DEPTO, 	TRB.RA_SITFOLH,	TRB.FILIAL, 
				TRB.MAT,       TRB.CCUSTO, %exp:cDiasHor%, %exp:cSum%, 	TRB.SEMANA,  	TRB.PROCES,   	TRB.PERIODO,    
				TRB.ROTEIR,    TRB.SEQ, 	TRB.RA_CODRPAT 	%exp:cCpoAdic%
		FROM  	%exp:cUnion% 
		GROUP BY TRB.RA_FILIAL, TRB.RA_MAT, TRB.RA_CC,  TRB.RA_NOME, TRB.RA_DEPTO, TRB.RA_SITFOLH, TRB.FILIAL, 
				TRB.MAT,        TRB.CCUSTO, TRB.SEMANA, TRB.PROCES,  TRB.PERIODO,  TRB.ROTEIR,    TRB.SEQ, 
			   	TRB.RA_CODRPAT %exp:cCpoAdic%
		ORDER BY %exp:cOrdem%
	EndSql   
Else
	BeginSql alias cAliasQry
		SELECT 	TRB.RA_FILIAL, TRB.RA_MAT, TRB.RA_CC,  TRB.RA_NOME, TRB.RA_DEPTO, TRB.RA_SITFOLH, TRB.FILIAL, 
				TRB.MAT,  %exp:cDiasHor%, %exp:cSum%, TRB.SEMANA,  TRB.PROCES,   TRB.PERIODO,    
				TRB.ROTEIR %exp:cCpoAdic%
		FROM  	%exp:cUnion% 
		GROUP BY TRB.RA_FILIAL, TRB.RA_MAT, TRB.RA_CC,  TRB.RA_NOME, TRB.RA_DEPTO, TRB.RA_SITFOLH, TRB.FILIAL, 
				TRB.MAT, TRB.SEMANA, TRB.PROCES,  TRB.PERIODO,  TRB.ROTEIR %exp:cCpoAdic%
		ORDER BY %exp:cOrdem%		
	EndSql   
EndIf
    
If nOrdem == 1 .Or. nOrdem == 2

	END REPORT QUERY oSectDet
	
ElseIf nOrdem == 3 .Or. nOrdem == 4

	END REPORT QUERY oSectHead
	
	oSectDet:SetParentQuery()
	oSectDet:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO})
	
ElseIf nOrdem == 5 .Or. nOrdem == 6                             
	END REPORT QUERY oSectHead
	oSectDet:SetParentQuery()
	oSectDet:SetParentFilter({|cParam|RA_FILIAL+RA_DEPTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_DEPTO})
	
ElseIf nOrdem == 7 .OR. nOrdem == 8

	END REPORT QUERY oSectHead
	
	oSectH2:SetParentQuery()                                                                                       
	oSectH2:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO})
	                                                                                       
	oSectDet:SetParentQuery() 
	oSectDet:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO+(cAliasQry)->RA_DEPTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO+(cAliasQry)->RA_DEPTO})
	
ElseIf nOrdem == 9 .Or. nOrdem == 10

	END REPORT QUERY oSectHead	
	oSectDet:SetParentQuery()                                                                                      
	oSectDet:SetParentFilter({|cParam|RA_CODRPAT==cParam},{||(cAliasQry)->RCO_CODIGO})
	
	EndIf

oReport:OnPageBreak({||	fGR105Header(oReport)})	
	
	//-- Verifica se o usuário cancelou a impressão do relatorio
	If oReport:Cancel()
		Return
	EndIf               

	dbSelectArea( cAliasQry )

	For nCont:= 1 to Len(Alltrim(cCodigos)) Step 3
		oSectDet:Cell(Substr(cCodigos,nCont,3)):SetTitle(Substr(cCodigos,nCont,3)+"-"+DescPd(Substr(cCodigos,nCont,3),(cAliasQry)->RA_FILIAL,8))	//Cod.+Descricao
	Next

	If (nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 7 .Or. nOrdem == 8) 
		oSectHead:SetLineCondition({||!Empty((cAliasQry)->CCUSTO)})
	EndIf
	oSectDet:SetLineCondition({||fAcumValores(@oSectDet,cCodigos)})

	If nOrdem == 1 .Or. nOrdem == 2 
	    oSectDet:Print()
	Else
		oSectHead:Print()
	EndIf

RestArea(aAreaRep)
	        
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ImpLinFunc
Impressao dos dados - Funcionarios por Linha
@author  Gisele Nuncherino	
@since   17/09/2018
/*/
//-------------------------------------------------------------------
Static Function ImpLinFunc(oReport)

	Local oVerbas
	Local aAreaRep		:= GetArea()
	Local oSectDet  	
	Local lShar
	Local cSumValTot	:= ""
	Local nReg			:= 0
	Local nCont			:= 0
	
	Private oSectHead 
	Private oSectH2
	
	cSituacao	:= mv_par06					
	cCategoria	:= mv_par07
	cProcesso	:= mv_par08
	cRot		:= mv_par09 	                  					
	cPeriodo	:= mv_par10        
	cPagamento	:= mv_par11        			
	cCodigos	:= AllTrim(mv_par12)			// Codigos ( Verbas )
	lImpEmpr	:= If(mv_par13=1,.T.,.F.)		// Listar total empresa
	lVlDiaHor	:= If(mv_par14=1,.F.,.T.)		// Imprime Valor ou Horas/Dias (para verbas do tipo H/D)
	
	If oReport:nDevice == 4 .And. oReport:nExcelPrintType == 3
		if lImpLinFun
			lFormatTab := MsgYesNo( OemToAnsi(STR0038) )
			If !lFormatTab
			oReport:CancelPrint()
			Return( Nil )
			EndIf
		Else
			MsgAlert(OemToAnsi(STR0039) )
			oReport:CancelPrint()
			Return( Nil )
		EndIf	
	EndIf
	
	If Empty(cCodigos)
		MsgAlert(OemToAnsi(STR0024),OemToAnsi(STR0023))	//"N'ao foi selecionada nenhuma verba para impress'ao." ### "Aten;'ao!"
		RestArea(aAreaRep)
		Return
	EndIf
	
	If "*" $ cCodigos
		MsgAlert(OemToAnsi(STR0034),OemToAnsi(STR0023))	//"Máximo de verbas para impressão é 10. Selecione os códigos" ### "Aten;'ao!"
		RestArea(aAreaRep)
		Return
	EndIf
	
	If lUsaArqui 	//Se uas Arquitetura Organizadional (SIGAORG)
		cCodVisao	:= mv_par15
	    cCodDepto	:= mv_par16
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
	    cOrgJoin	+= " ON TRB.RA_DEPTO = TVRD4.RD4_CODIDE "
		 If !lShar
		     cOrgJoin+= " AND TRB.RA_FILIAL = TVRD4.RD4_FILIDE "
		 EndIf
	
	    cVisaoDepto	:=	OemToAnsi(STR0029) + AllTrim(cCodVisao)								
	EndIf
	       
	nOrdem := oReport:GetOrder()
	
	If nOrdem == 1		//Matrícula
		oSectDet 	:= oReport:Section(1)
		
	ElseIf nOrdem == 2	//Nome
		oSectDet	:= oReport:Section(2)
		
	ElseIf nOrdem == 3	//C.Custo + Matrícula
		oSectHead:= oReport:Section(3)
		oSectHead:SetCols(4)
		oSectHead:SetLineStyle()
		oSectHead:SetCharSeparator(": ")
		oSectDet	:= oReport:Section(1)
				
	ElseIf nOrdem == 4	//C.Custo + Nome
		oSectHead:= oReport:Section(3)
		oSectHead:SetCols(4)
		oSectHead:SetLineStyle()
		oSectHead:SetCharSeparator(": ")
		oSectDet	:= oReport:Section(2)
		
	ElseIf nOrdem == 5	//Depto + Matrícula
		oSectHead	:= oReport:Section(4)
		oSectDet	:= oReport:Section(1)
		oSectHead:SetCols(4)
		oSectHead:SetLineStyle()
		oSectHead:SetCharSeparator(": ")
	
	ElseIf nOrdem == 6	//Depto + Nome
		oSectHead	:= oReport:Section(4)
		oSectDet	:= oReport:Section(2)
		oSectHead:SetCols(4)
		oSectHead:SetLineStyle()
		oSectHead:SetCharSeparator(": ")
	
	ElseIf nOrdem == 7 //C.Custo + Depto + Matricula
		oSectHead:= oReport:Section(3)
		oSectHead:SetCols(4)
		oSectHead:SetLineStyle()
		oSectHead:SetCharSeparator(": ")
	
		oSectH2	:= oReport:Section(4)
		oSectH2:SetCols(4)
		oSectH2:SetLineStyle()
		oSectH2:SetCharSeparator(": ")
		oSectDet	:= oReport:Section(1)	     

	ElseIf nOrdem == 8 //C.Custo + Depto + Nome
		oSectHead:= oReport:Section(3)
		oSectHead:SetCols(4)
		oSectHead:SetLineStyle()
		oSectHead:SetCharSeparator(": ") 
		oSectH2	:= oReport:Section(4)
		oSectH2:SetCols(4)
		oSectH2:SetLineStyle()
		oSectH2:SetCharSeparator(": ")
		oSectDet	:= oReport:Section(2)
	
	ElseIf nOrdem == 9 //RegPatronal + Matricula             
		oSectHead:= oReport:Section(5)
		oSectHead:SetLineStyle()
		oSectHead:SetCharSeparator(": ") 
		oSectDet	:= oReport:Section(1)
	
	ElseIf nOrdem == 10 //RegPatronal + Nome
		oSectHead:= oReport:Section(5)
		oSectHead:SetLineStyle()
		oSectHead:SetCharSeparator(": ") 
		oSectDet	:= oReport:Section(2)
		
	EndIf
		    
		//Definida a seção onde serão impressas as verbas
		DEFINE SECTION oVerbas OF oSectDet TITLE OemToAnsi(STR0037) TABLES "SRA", "SQB" ORDERS aOrd	//Processo / Periodo
		oVerbas:SetLeftMargin(4)
	
		
	If !(AllTrim(oReport:Title()) == cTitulo)
		cTitulo	:= oReport:Title()
	Endif

	If nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 7 .Or. nOrdem == 8
		oSectDet:Cell("RA_CC"):bCellBlock := {|| (cAliasQry)->CCUSTO}
	
		DEFINE BREAK oBreakCC OF oSectHead WHEN  {||(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO} TITLE OemToAnsi(STR0013) //"Total do Centro de Custo "
	
		oBreakCc:OnBreak({|x,y|cTitCC:=OemToAnsi(STR0013)+" "+oSectHead:Cell("RA_CC"):GetText()})
		oBreakCc:SetTotalText({||cTitCC})
		oBreakCc:SetTotalInLine(.F.)
	Endif
	
	If nOrdem == 5 .Or. nOrdem == 6 .Or. nOrdem == 7 .Or. nOrdem == 8
		oSectDet:Cell( "RA_DEPTO"  ):Disable() 
		oSectDet:Cell( "QB_DESCRIC"):Disable()
	
		If nOrdem == 5 .Or. nOrdem == 6 	
			oSectHead:Cell("QB_DESCRIC"):Enable()
		Endif		
		
		If nOrdem == 5 .Or. nOrdem == 6 
			DEFINE BREAK oBreakDp OF oSectHead WHEN  {||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_DEPTO} TITLE STR0018 //"Total do Departamento"
			oBreakDp:OnBreak({|x,y|cTitDp:=OemToAnsi(STR0018)+" "+oSectHead:Cell("RA_DEPTO"):GetText()})			
		Else
			DEFINE BREAK oBreakDp OF oSectH2 WHEN  {||(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO+(cAliasQry)->RA_DEPTO} TITLE STR0018 //"Total do Departamento"
			oBreakDp:OnBreak({|x,y|cTitDp:=OemToAnsi(STR0018)+" "+oSectH2:Cell("RA_DEPTO"):GetText()})	
		Endif

		oBreakDp:SetTotalText({||cTitDp})
		oBreakDp:SetTotalInLine(.F.)
		EndIf
	
	If (oReport:nDevice <> 4 .And. oReport:nExcelPrintType <> 3)
		DEFINE BREAK oBreakFil OF oReport WHEN {||(cAliasQry)->RA_FILIAL} TITLE OemToAnsi(STR0019) //"Total da Filial "
			
		oBreakFil:OnBreak({|x,y|cTitFil:=x,	oSectDet:SetHeaderSection(.T.)})	
		oBreakFil:SetTotalText({||cTitFil:=OemToAnsi(STR0019)+" "+cTitFil})
		oBreakFil:SetTotalInLine(.F.)
	Endif
	
	For nReg:=1 to Len(cCodigos) step 3
		 cCodPesq := Subs(cCodigos,nReg,3)
	    nPosx := aScan( aAuxCods , { |x| x == cCodPesq } )
	    If nPosx = 0  
	        aAdd( aAuxCods , cCodPesq )
	        cAuxCods += cCodPesq
	    EndIf 
	Next nReg 

	cCodigos := cAuxCods
	
	For nCont:= 1 to Len(Alltrim(cCodigos)) Step 3
		cCellVerba	:= Substr(cCodigos,nCont,3)
		If PosSrv(cCellVerba,xFilial("SRA"),"RV_COD" ) == cCellVerba
	                          
			lTpHora  := PosSrv(cCellVerba,xFilial("SRA"),"RV_TIPO") == "H" //Verba do tipo Dias/Horas
	
			DEFINE CELL NAME (cCellVerba) OF oVerbas TITLE cCellVerba PICTURE "@E 99,999,999,999.99" SIZE 20 BLOCK {||(cAliasQry)->&(cCellVerba)}
					
			oVerbas:Cell(cCellVerba):SetHeaderAlign("RIGHT")
			oVerbas:Cell(cCellVerba):SetAutoSize(.T.)		
			oVerbas:Cell(cCellVerba):SetTitle(cCellVerba+"-"+DescPd(cCellVerba,xFilial("SRA"),10))	//Cod.+Descricao
	
			If lImpEmpr
				DEFINE FUNCTION NAME ("T"+cCellVerba) FROM oVerbas:Cell(cCellVerba) FUNCTION SUM PICTURE "@E 99,999,999,999.99"	NO END SECTION
			EndIf
			
			If nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 7 .Or. nOrdem == 8
				DEFINE FUNCTION NAME ("C"+cCellVerba) FROM oVerbas:Cell(cCellVerba) FUNCTION SUM BREAK oBreakCC NO END SECTION NO END REPORT PICTURE "@E 99,999,999,999.99"
			EndIf
				  
			If nOrdem == 5 .Or. nOrdem == 6 .Or. nOrdem == 7 .Or. nOrdem == 8
				DEFINE FUNCTION NAME ("D"+cCellVerba) FROM oVerbas:Cell(cCellVerba) FUNCTION SUM BREAK oBreakDp NO END SECTION NO END REPORT PICTURE "@E 99,999,999,999.99"
			EndIf
			
			IF (oReport:nDevice <> 4 .And. oReport:nExcelPrintType <> 3)
				DEFINE FUNCTION NAME ("F"+cCellVerba) FROM oVerbas:Cell(cCellVerba) FUNCTION SUM BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 99,999,999,999.99"
			EndIf
	
			aAdd(aQryVerba,AllTrim(cCellVerba))                                                               
		EndIf
	Next
	
	//define celula "valor total" quando não for horas/dias
	If !lVlDiaHor
		DEFINE CELL NAME "ValTot" OF oVerbas TITLE Upper(OemToAnsi(STR0036)) PICTURE "@E 99,999,999,999.99" SIZE 20 
		oVerbas:Cell("ValTot"):SetHeaderAlign("RIGHT")
		oVerbas:Cell("ValTot"):SetAutoSize(.T.)
	EndIf
	
	oSectDet:Cell("RA_MAT"    ):Enable()
	oSectDet:Cell("RA_NOME"   ):Enable()
	
	If nOrdem != 1 .And. nOrdem != 2
		oSectDet:Cell("RA_CC"     ):Disable()
		oSectDet:Cell("RA_DEPTO"  ):Disable()
	Endif
	
	//Monta a query para filtragem dos dados a serem impressos
	RetQuery()
	
	//-- Altera o titulo do relatorio
	oReport:SetTitle(cTitulo)
	
	If nOrdem == 1 .Or. nOrdem == 2
		BEGIN REPORT QUERY oSectDet
	Else
		BEGIN REPORT QUERY oSectHead
	EndIf
	
	lKEYLOC := SRA->(FIELDPOS("RA_CODRPAT") > 0) //Tratamento para o Mexico
	
	If lKEYLOC //cPaisLoc == "MEX"
		BeginSql alias cAliasQry
			SELECT 	TRB.RA_FILIAL, TRB.RA_MAT, TRB.RA_CC,  		TRB.RA_NOME, 	TRB.RA_DEPTO, 	TRB.RA_SITFOLH,	TRB.FILIAL, 
					TRB.MAT,       TRB.CCUSTO, %exp:cDiasHor%, %exp:cSum%,  %exp:cSumValTot%, TRB.SEMANA,  	TRB.PROCES,   	TRB.PERIODO,    
					TRB.ROTEIR,    TRB.SEQ, 	TRB.RA_CODRPAT 	%exp:cCpoAdic%
			FROM  	%exp:cUnion% 
			GROUP BY TRB.RA_FILIAL, TRB.RA_MAT, TRB.RA_CC,  TRB.RA_NOME, TRB.RA_DEPTO, TRB.RA_SITFOLH, TRB.FILIAL, 
					TRB.MAT,        TRB.CCUSTO, TRB.SEMANA, TRB.PROCES,  TRB.PERIODO,  TRB.ROTEIR,    TRB.SEQ, 
				   	TRB.RA_CODRPAT %exp:cCpoAdic%
			ORDER BY %exp:cOrdem%
		EndSql   
	Else
		BeginSql alias cAliasQry
			SELECT 	TRB.RA_FILIAL, TRB.RA_MAT, TRB.RA_CC,  TRB.RA_NOME, TRB.RA_DEPTO, TRB.RA_SITFOLH, TRB.FILIAL, 
					TRB.MAT,  %exp:cDiasHor%, %exp:cSum%,  %exp:cSumValTot%, TRB.SEMANA,  TRB.PROCES,   TRB.PERIODO,    
					TRB.ROTEIR %exp:cCpoAdic%
			FROM  	%exp:cUnion% 
			GROUP BY TRB.RA_FILIAL, TRB.RA_MAT, TRB.RA_CC,  TRB.RA_NOME, TRB.RA_DEPTO, TRB.RA_SITFOLH, TRB.FILIAL, 
					TRB.MAT, TRB.SEMANA, TRB.PROCES,  TRB.PERIODO,  TRB.ROTEIR %exp:cCpoAdic%
			ORDER BY %exp:cOrdem%		
		EndSql   
	EndIf
	
	If nOrdem == 1 .Or. nOrdem == 2
	
		END REPORT QUERY oSectDet
		oVerbas:SetParentQuery()
		oVerbas:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT})
		
	ElseIf nOrdem == 3 .Or. nOrdem == 4
	
		END REPORT QUERY oSectHead
		
		oSectDet:SetParentQuery()
		oSectDet:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO})
		oVerbas:SetParentQuery()
		oVerbas:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT})
		
	ElseIf nOrdem == 5 .Or. nOrdem == 6                             
		END REPORT QUERY oSectHead
		oSectDet:SetParentQuery()
		oSectDet:SetParentFilter({|cParam|RA_FILIAL+RA_DEPTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_DEPTO})
		
		oVerbas:SetParentQuery()
		oVerbas:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT})
	
	ElseIf nOrdem == 7 .OR. nOrdem == 8
	
		END REPORT QUERY oSectHead
		
		oSectH2:SetParentQuery()                                                                                       
		oSectH2:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO})
		                                                                                       
		oSectDet:SetParentQuery() 
		oSectDet:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO+(cAliasQry)->RA_DEPTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO+(cAliasQry)->RA_DEPTO})
		
		oVerbas:SetParentQuery()
		oVerbas:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT})
	
	ElseIf nOrdem == 9 .Or. nOrdem == 10
	
		END REPORT QUERY oSectHead	
		oSectDet:SetParentQuery()                                                                                      
		oSectDet:SetParentFilter({|cParam|RA_CODRPAT==cParam},{||(cAliasQry)->RCO_CODIGO})
		
		oVerbas:SetParentQuery()
		oVerbas:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT})
	
	EndIf
	
	oReport:OnPageBreak({||	fGR105Header(oReport)})	
	
	//-- Verifica se o usuário cancelou a impressão do relatorio
	If oReport:Cancel()
		Return
	EndIf               

	dbSelectArea( cAliasQry )

	For nCont:= 1 to Len(Alltrim(cCodigos)) Step 3
		oVerbas:Cell(Substr(cCodigos,nCont,3)):SetTitle(Substr(cCodigos,nCont,3)+"-"+DescPd(Substr(cCodigos,nCont,3),(cAliasQry)->RA_FILIAL,8))	//Cod.+Descricao
	Next

	If (nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 7 .Or. nOrdem == 8) 
		oSectHead:SetLineCondition({||!Empty((cAliasQry)->CCUSTO)})
	EndIf

	oSectDet:SetLineCondition({||fAcumValores(@oVerbas,cCodigos)})

	If nOrdem == 1 .Or. nOrdem == 2 
	    oSectDet:Print()
	Else
		oSectHead:Print()
	EndIf

RestArea(aAreaRep)
	        
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fAcumValores() ³ Autor ³ Tania Bronzeri   ³ Data ³29/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Acumula os valores das Verbas selecionadas.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Folha Mexico                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fAcumValores(oSection1, cCodigos)

	Local aArea 	:= GetArea()
	Local cPd		:= ""
	Local cTpCod	:= ""	//Sinal - Retorna 1,2,3 ou 4
	Local cTpval	:= ""	//Status - Retorna H,D ou V
	Local nCont		:= 0	    
	Local nAcum		:= 0
	Local lRet		:= .T.
	           
	For nCont	:= 1 to Len(Alltrim(cCodigos)) Step 3
		cPd		:= Substr(cCodigos,nCont,3)
		If !lVlDiaHor
			oSection1:Cell(cPd):SetValue((cAliasQry)->&("V"+cPd))
			nAcum += (cAliasQry)->&("V"+cPd)
		Else
			oSection1:Cell(cPd):SetValue((cAliasQry)->&("H"+cPd))
			nAcum += (cAliasQry)->&("H"+cPd)		
		EndIf
	Next
	
	If !(nAcum == 0) 
		If cRepete == ((cAliasQry)->RA_FILIAL + (cAliasQry)->RA_MAT)
			lRepete	:= .T.
		Else
			lRepete := .F.
			cRepete := ((cAliasQry)->RA_FILIAL + (cAliasQry)->RA_MAT)
		EndIf                 
	EndIf
	                                   
	If !lImpLinFun .AND. !lVlDiaHor
		oSection1:Cell("ValTot"):SetHeaderAlign("RIGHT")
		oSection1:Cell("ValTot"):SetAutoSize()		
		oSection1:Cell("ValTot"):SetValue(nAcum)
		DEFINE FUNCTION NAME ("T"+"ValTot") FROM oSection1:Cell("ValTot") FUNCTION SUM PICTURE "@E 99,999,999,999.99"	NO END SECTION
	EndIf

	RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ fQueryVisao   ³ Autor ³ Tania Bronzeri        ³ Data ³19/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Pesquisa Visao / Departamento para a Arquitetura Organizacional.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER105                                                         ³±±
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…cao  ³fGR105Header  ³ Autor ³  Esther Viveiro      ³ Data ³ 06/06/2014        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrica‡…o ³Definição do cabeçalho do relatório.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Parametro ³oReport    - Obrigatorio - objeto com as informações do realtório.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER105                                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGR105Header(oReport)
	
	oReport:SkipLine()
	oReport:PrintText(OemToAnsi(STR0014) + ': ' + cProcesso + space(05)  + ; //"Processo"
						OemToAnsi(STR0015) + ': ' + cPeriodo + space(05)   + ; //"Período"
						OemToAnsi(STR0016) + ': ' + cPagamento + space(05) +; //"Pagamento"
						OemToAnsi(STR0017) + ': ' + cRot ; //"Roteiro"
						,/*nRow*/,/*nCol*/,/*nClrText*/,/*cStyle*/,/*nCells*/,.F.)
	
	If lUsaArqui .And. !Empty(mv_par16) .AND. !Empty(mv_par17) //!Empty(cCodVisao + cCodDepto)
		oReport:PrintText(OemToAnsi(STR0028) + cVisaoDepto ; //"Arquitetura Organizacional - " 
		,/*nRow*/,/*nCol*/,/*nClrText*/,/*cStyle*/,/*nCells*/,.F.)
	EndIf 
	
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()
 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Gp105VldPd    ³ Autor ³ Leandro Drumond       ³ Data ³04/08/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Nao permitir * nas verbas.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER105                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp105VldPd()
Local lRet		:= .T.
Local cVar		:= &(ReadVar())

If !Empty(cVar)
	If "*" $ cVar
		MsgAlert(OemToAnsi(STR0035),OemToAnsi(STR0023))	//"Deve selecionar no máximo 10 verbas para impressão." ### "Aten;'ao!"
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} RetQuery
Monta a query para filtragem dos dados a serem impressos
@author  Gisele Nuncherino
@since   17/09/18
/*/
//-------------------------------------------------------------------
Static Function RetQuery()

Local nReg, nCont
 
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

dbSelectArea("SRA")
dbSetOrder(1)

SRA->( DbGoTop() )

MakeSqlExpr(cPerg)    

If nOrdem == 1
	cOrdem := "%TRB.RA_FILIAL,TRB.RA_MAT"
	cTitulo += " - " + OemToAnsi(STR0004)	//Matrícula
ElseIf nOrdem == 2
	cOrdem := "%TRB.RA_FILIAL,TRB.RA_NOME,TRB.RA_MAT"
	cTitulo += " - " + OemToAnsi(STR0006)	//Nome
ElseIf nOrdem == 3
	cOrdem := "%TRB.RA_FILIAL,TRB.CCUSTO,TRB.RA_MAT"
	cTitulo += " - " + OemToAnsi(STR0007) 	//"Centro de Custo"
	cTitulo += " + " + OemToAnsi(STR0004)	//" + Matrícula"
ElseIf nOrdem == 4                    
	cOrdem := "%TRB.RA_FILIAL,TRB.CCUSTO,TRB.RA_NOME,TRB.RA_MAT"
	cTitulo += " - " + OemToAnsi(STR0007)	//"Centro de Custo"
	cTitulo += " + " + OemToAnsi(STR0006)	//" + Nome"
ElseIf nOrdem == 5
	cOrdem := "%TRB.RA_FILIAL,TRB.RA_DEPTO,TRB.RA_MAT" 
	cTitulo += " - " + OemToAnsi(STR0009)	//"Departamento"
	cTitulo += " + " + OemToAnsi(STR0004)	//" + Matrícula"
ElseIf nOrdem == 6
	cOrdem := "%TRB.RA_FILIAL,TRB.RA_DEPTO,TRB.RA_NOME,TRB.RA_MAT"
	cTitulo += " - " + OemToAnsi(STR0009) 	//"Departamento"
	cTitulo += " + " + OemToAnsi(STR0006)	//" + Nome"
ElseIf nOrdem == 7
	cOrdem  := "%TRB.RA_FILIAL,TRB.CCUSTO,TRB.RA_DEPTO,TRB.RA_MAT"		
	cTitulo += " - " + OemToAnsi(STR0007)	//"Centro de Custo"
	cTitulo += " + " + OemToAnsi(STR0009) 	//"Departamento"
	cTitulo += " + " + OemToAnsi(STR0004)	//"Matrícula"
ElseIf nOrdem == 8
	cOrdem  := "%TRB.RA_FILIAL,TRB.CCUSTO,TRB.RA_DEPTO,TRB.RA_NOME, TRB.RA_MAT"		
	cTitulo += " - " + OemToAnsi(STR0007)	//"Centro de Custo"
	cTitulo += " + " + OemToAnsi(STR0009) 	//"Departamento"
	cTitulo += " + " + OemToAnsi(STR0006)	//"Nome" 
ElseIf nOrdem == 9
	cOrdem  := "%TRB.RA_FILIAL,TRB.RA_CODRPAT,TRB.RA_MAT,TRB.RA_DEPTO"		
	cTitulo += " - " + OemToAnsi(STR0026)	//"Registro Patronal"
	cTitulo += " + " + OemToAnsi(STR0004) 	//"Matricula" 
ElseIf nOrdem == 10
	cOrdem  := "%TRB.RA_FILIAL,TRB.RA_CODRPAT,TRB.RA_NOME,TRB.RA_DEPTO"		
	cTitulo += " - " + OemToAnsi(STR0026)	//"Registro Patronal"
	cTitulo += " + " + OemToAnsi(STR0006) 	//"Matricula"
Endif                        
cOrdem		:= cOrdem + "%" //+ ",TRB.SEQ%"
		
cAliasQry	:= GetNextAlias()
   
//-- Filial
If !Empty(mv_par01)
	cFiltro += mv_par01
EndIf

//-- Centro de Custo
If !Empty(mv_par02)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par02
EndIf

//-- Departamento
If !Empty(mv_par03)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par03
EndIf

//=== Matricula   
If !Empty(mv_par04)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro	+= mv_par04
EndIf

//=== Nome   
If !Empty(mv_par05)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par05
EndIf
 
cVerQry	+= "RGB.RGB_SEMANA SEMANA, " 
cVerQry	+= "RGB.RGB_PROCES PROCES, "
cVerQry	+= "RGB.RGB_PERIOD PERIODO, " 
cVerQry	+= "RGB.RGB_ROTEIR ROTEIR, "
cVerQry	+= "RGB.RGB_SEQ SEQ 		"                         	
cVerQry	+= "FROM " 
cVerQry	+= RetSqlName("SRA")  + " SRA "
cVerQry	+= "INNER JOIN  " 
cVerQry	+= RetSqlName("RGB")  + " RGB ON "
cVerQry	+= "SRA.RA_FILIAL = RGB.RGB_FILIAL AND "
cVerQry	+= "SRA.RA_MAT = RGB.RGB_MAT "
cVerQry	+= "WHERE " 
cVerQry	+= Iif(Empty(cFiltro),"",cFiltro + " AND ")  
cVerQry	+= Iif(Empty(cSitQuery),"","SRA.RA_SITFOLH IN (" + cSitQuery + ") AND ") 
cVerQry	+= Iif(Empty(cCatQuery),"","SRA.RA_CATFUNC IN (" + cCatQuery + ") AND ")  
cVerQry	+= "RGB.RGB_PROCES  = Upper('" + cProcesso  + "') AND "
cVerQry	+= "RGB.RGB_PERIOD  = Upper('" + cPeriodo   + "') AND " 
cVerQry	+= "RGB.RGB_ROTEIR  = Upper('" + cRot   + "') AND "
cVerQry	+= "RGB.RGB_SEMANA  = Upper('" + cPagamento + "') AND " 
cVerQry	+= "SRA.D_E_L_E_T_= ' ' AND RGB.D_E_L_E_T_= ' ' "

cVerQry0	:= "SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_CC, SRA.RA_NOME, SRA.RA_DEPTO, "
cVerQry0	+= "SRA.RA_SITFOLH, RGB.RGB_FILIAL FILIAL, RGB.RGB_MAT MAT, RGB.RGB_CC CCUSTO, "
 
If SRA->(FIELDPOS ("RA_CODRPAT") > 0) //cPaisLoc == "MEX"
 	cVerQry0 	+= "SRA.RA_CODRPAT,"		    
EndIf

aVerQry	:= Array(Len(aQryVerba))
For nReg	:= 1 to Len(aVerQry)
	aVerQry[nReg] := cVerQry0	
Next

For nReg := 1 to Len(aQryVerba)
	cSum	 += Iif(Empty(cSum),"",", ")
	cDiasHor += Iif(Empty(cDiasHor),"",", ")
	cSum	 += " SUM(V" + aQryVerba[nReg] + ") V" + aQryVerba[nReg]
	cDiasHor += " SUM(H" + aQryVerba[nReg] + ") H" + aQryVerba[nReg]		
	    
	For nCont	:= 1 to Len(aVerQry)
		If nReg == nCont
		    aVerQry[nReg]	+= "RGB.RGB_HORAS H" + aQryVerba[nReg] + ", " + "RGB.RGB_VALOR V" + aQryVerba[nReg] + ", "
		Else
			aVerQry[nCont]	+= "0 H" + aQryVerba[nReg] + ", " + "0 V" + aQryVerba[nReg] + ", " 
		EndIf
	Next
Next
    
cUnion	:= Iif(!Empty(aVerQry[1]), " (" + aVerQry[1] + cVerQry + " AND " + "RGB.RGB_PD = '" + aQryVerba[1]  + "' ", "")

For nCont	:= 2 to Len(aVerQry)
	cUnion	+= Iif(!Empty(aVerQry[nCont]), " UNION ALL " + aVerQry[nCont] + cVerQry + " AND " + "RGB.RGB_PD = '" + aQryVerba[nCont] + "' ", "")
Next
        
cUnion		+= ") TRB "

If nOrdem == 3 .Or. nOrdem == 4 .OR. nOrdem == 7 .OR. nOrdem == 8

	cCpoAdic	:= ",TRB.CCUSTO"	

Endif

If nOrdem == 5 .OR. nOrdem == 6 .OR. nOrdem == 7 .OR. nOrdem == 8

	For nCont := 1 to 3
		aPosics[nCont] := Len(FWSM0Layout(,nCont)) //Pega quantidade de caracteres usados para empresa, unid. negocio, filial
	Next
 
	cCpoAdic += ",SQB.QB_DESCRIC"
	cJoinDepto := " INNER JOIN " + retSqlName("SQB") + " SQB"
	cJoinDepto += " ON SQB.QB_DEPTO=TRB.RA_DEPTO"
	cJoinDepto += " " + fGetJOINGestaoEmpresa(aPosics, 'SQB', 'QB_FILIAL', 'TRB', 'RA_FILIAL') 

	cUnion += cJoinDepto
EndIf

If nOrdem == 9 .Or. nOrdem == 10   
	cUnion += " Inner Join "+ RetSqlName("RCO") +" RCO On RCO.RCO_CODIGO=TRB.RA_CODRPAT "
	If RhFilial("RCO" , SRA->RA_FILIAL)!= Space(FWGETTAMFILIAL)
		cUnion += " And RCO.RCO_FILIAL=TRB.RA_FILIAL "		
	EndIf
	cCpoAdic	:= ",RCO.RCO_FILIAL , RCO.RCO_CODIGO, RCO.RCO_NREPAT, RCO.RCO_NOME"
end if                                                                                          
            	
cUnion		+= Iif(Empty(cOrgJoin),"",cOrgJoin)                                                
cUnion		:= "%" + cUnion		+ "%"
cFiltro		:= "%" + cFiltro	+ "%"
cSitQuery	:= "%" + cSitQuery	+ "%"
cCatQuery	:= "%" + cCatQuery	+ "%"
cSum		:= "%" + cSum 	  	+ "%"
cDiasHor	:= "%" + cDiasHor 	+ "%"
cCpoAdic	:= "%" + cCpoAdic 	+ "%"

Return
