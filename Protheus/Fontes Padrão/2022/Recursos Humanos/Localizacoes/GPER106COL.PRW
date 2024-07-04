#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER106COL.CH"
#INCLUDE "REPORT.CH"

Static lPrinOn := .F.
Static cDAnt   := ""                                                      

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa   ≥GPER106col∫Autor  ≥Cesar Bautista         ∫ Data ≥ 04/10/2018   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.      ≥ Relatorio Folha de Pagamento                                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso        ≥ Folha de pagamento - Colombia                                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫             ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL.              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Programador ≥ Data     ≥ BOPS/FNC  | Motivo da Alteracao                    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫            ≥          ≥          ≥                                         ∫±±
±±∫            ≥          ≥          ≥                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function GPER106COL()

Local	oReport
Local	aArea 			:= GetArea()
Private aFilB			:= {}
Private aGPSVal			:= {}
Private cCodFunc		:= ""
Private cDescFunc		:= ""
Private cPerg			:= "GPE106COL"
Private dDataRef		:= CtoD("  /  /  ")
Private cMesAnoRef		:= CtoD("  /  /  ")
Private cAnoMesRef		:= CtoD("  /  /  ")
Private dDtPerIni		:= Ctod("  /  /  ")
Private dDtPerFim		:= Ctod("  /  /  ")
Private dDtPago			:= Ctod("  /  /  ")
Private cTitulo			:= OemToAnsi(STR0001)	//"Folha de Pagamento"
Private cMascCus  		:= GetMv("MV_MASCCUS")
Private cCalcInf  		:= GetMv("MV_CALCINF")
Private cQuebFun  		:= GetMv("MV_QUEBFUN",,"S") //quando for igual a nao, imprime funcionario sem quebrar pagina 
Private cIRefSem  		:= GetMv("MV_IREFSEM",,"S")
Private lAglutPd  		:= (GetMv("MV_AGLUTPD",,"1") == "1" ) // 1-Aglutina verbas   2-Nao Aglutina
Private lDifLiq			:= .F.
Private lSumaVerba		:= .F.
Private nOrdSra			:= 1
Private cMod1			:= "" 
Private aLanB			:= {} 
Private aLanP			:= {}
Private aLanD   		:= {}
Private aNomeFunc		:= {} 
Private aDifLiquidos	:= {}
Private cPDLiq			:= fGetCodFol("0047")
Private oSectDifLiq
Private cDepto			:= ""  //UTILIZADO P/ INFORMA«√O HISTORICA
Private cDescDepto		:= ""
Private cCentroC		:= ""
Private cDescCC			:= ""
Private nTotFunc		:= 0
Private nOrdRemov 		:= 0 // QUANTIDADE DE ORDENS NAO EXISTENTES E QUE IMPACTA NA VARIAVEL NORDEM
Private nPosRemov 		:= 0 // POSICAO PARA CONTROLAR O QUE FOI REMOVIDO
Private lDepSf			:= IIf(SRA->(FieldPos("RA_DEPSF"))>0,.T.,.F.)   
Private lRaDtRec		:= IIf(SRA->(FieldPos("RA_DTREC"))>0,.T.,.F.)
Private lRaFecrei		:= IIf(SRA->(FieldPos("RA_FECREI"))>0,.T.,.F.)
Private lRaSalDia		:= IIf(SRA->(FieldPos("RA_SALDIA"))>0,.T.,.F.)
Private lRaSalInt		:= IIf(SRA->(FieldPos("RA_SALINT"))>0,.T.,.F.)
Private aOrd			:={}

	Aadd(aOrd, OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))  //1  - "MatrÌcula + LanÁamentos"	
	Aadd(aOrd, OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))  //2  - "Nome + LanÁamentos"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))	//3  - "C.Custo Cad. + MatrÌcula + LanÁamentos"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))	//4  - "C.Custo Cad. + Nome + LanÁamentos"
	Aadd(aOrd, OemToAnsi(STR0006)+"+"+OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))	//5  - "C.Custo Mov. + MatrÌcula + LanÁamentos"
	Aadd(aOrd, OemToAnsi(STR0006)+"+"+OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))	//6  - "C.Custo Mov. + Nome + LanÁamentos"
	Aadd(aOrd, OemToAnsi(STR0007)+"+"+OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))	//7  - "Depto. + Matricula + LanÁamentos"
	Aadd(aOrd, OemToAnsi(STR0007)+"+"+OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))	//8  - "Depto. + Nome + LanÁamentos"
	
	nPosRemov := Len(aOrd) + 1
	
Private cProcesso		:= ""
Private cProcessoa		:= ""
Private cPeriodo		:= ""
Private cPagamento	:= ""
Private cRoteiro		:= ""
Private cRot			:= ""
Private cAliasFun		:= ""
Private cAliasQry		:= ""
Private cAliasFunTT	:= "" 
Private nOrdem		:= 1
Private nAnaSin   	:= 0                                                                     
Private nTpContr		:= 0
Private aInfo			:= Array(26)  
Private cCodFilial	:= "##"
Private lCorpManage	:= fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gest„o Corporativa no Grupo Logado
Private lSint			:= .F. // vari·vel que informa se foi selecionado tipo sintÈtico

Private cMoneda	:= ""
Private cRemVar	:= ""
Private cGrossu	:= ""
Private cSalEst	:= ""
Private cPerRet	:= ""
Private cValSal	:= ""
Private cTpSal	:= ""
Private cCatFun	:= ""


If lCorpManage
	Private lUniNeg    := !Empty(FWSM0Layout(cEmpAnt, 2)) // Verifica se possui tratamento para unidade de Negocios
	Private lEmpFil    := !Empty(FWSM0Layout(cEmpAnt, 1)) // Verifica se possui tratamento para Empresa
	Private cLayoutGC  := FWSM0Layout(cEmpAnt)
	Private nStartEmp  := At("E",cLayoutGC)
	Private nStartUnN  := At("U",cLayoutGC)
	Private nEmpLength := Len(FWSM0Layout(cEmpAnt, 1))
	Private nUnNLength := Len(FWSM0Layout(cEmpAnt, 2))
EndIf

Pergunte(cPerg,.F.) 

cRot := MV_PAR03

cAliasQry	:= GetNextAlias()
cAliasFun	:= GetNextAlias()
cAliasFunTT	:= GetNextAlias()

oReport := ReportDef()
oReport:PrintDialog()

If Select(cAliasQry) > 0
	(cAliasQry)->(DbCloseArea())
EndIf
If Select(cAliasFun) > 0
	(cAliasFun)->(DbCloseArea())
EndIf
If Select(cAliasFunTT) > 0
	(cAliasFunTT)->(DbCloseArea())
EndIf

RestArea(aArea)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ ReportDef  ≥ Autor ≥ Tania Bronzeri        ≥ Data ≥20/11/2007 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Relatorio de Folha de Pagamento                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPER106COL                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function ReportDef()
Local oReport 
Local oSecMat 
Local oSecNom
Local oSecLan      
Local oSecCtc
Local oSecCtm
Local oSecSqb
Local oSecRgc 
Local oSecDifLiq
Local oSectionh  
Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0009)		//"Folha de Pagamento" ### "Imprime a Folha de pagamento, de acordo com os parametros solicitados pelo usu†rio."
Local oSecCont
Local nSize := 14

Local bBlkEmp := { || If ( cCodFilial != (cAliasQry)->RA_FILIAL, Eval( { || fInfo(@aInfo,(cAliasQry)->RA_FILIAL), aInfo[3] } ), aInfo[3] ) }

//CRIACAO DOS COMPONENTES DE IMPRESSAO
DEFINE REPORT oReport NAME "GPER106COL" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| R106Imp(oReport) } DESCRIPTION cDesc1	

	nAnaSin   	:= mv_par14		//Tipo Relatorio: 1=Analitico; 2=Sintetico
	cRoteiro	:= mv_par03
	
	oReport:SetTotalInLine(.F.)	// PARA TOTALIZAR EM LINHAS
	oReport:nFontBody	:= 8
	oReport:SetDynamic()
	
	//SECTION 01 
	DEFINE SECTION oSecMat OF oReport TITLE OemToAnsi(STR0036) TABLES "SRA","SQB","CTT","RCO","RGC" ORDERS aOrd	//"Filial / Funcion·rio"

		DEFINE CELL NAME "ESPACO"     OF oSecMat TITLE "" BLOCK {||" "}		//Recurso alternativo para que a section do funcion·rio n·o saia colada a collection. 
		DEFINE CELL NAME "RA_FILIAL"  OF oSecMat ALIAS "SRA"
		DEFINE CELL NAME "RA_MAT"     OF oSecMat ALIAS "SRA" 
		DEFINE CELL NAME "RA_NOME"    OF oSecMat ALIAS "SRA"  
	   
		IF nAnaSin = 1
	   		DEFINE CELL NAME "RA_TPCIC"	  OF oSecMat ALIAS "SRA" BLOCK {|| SRA->RA_TPCIC}
	   		DEFINE CELL NAME "RA_CIC"	  OF oSecMat ALIAS "SRA" BLOCK {|| SRA->RA_CIC}
		ENDIF
		
		DEFINE CELL NAME "CODFUNC"	  OF oSecMat TITLE OemToAnsi(STR0021) SIZE 5 BLOCK {||cCodFunc}			//"FunÁ„o"
		DEFINE CELL NAME "DESCFUNC"   OF oSecMat TITLE OemToAnsi(STR0028) SIZE 20 BLOCK {||Substr(cDescFunc,1,20)}
	    
	    IF nAnaSin = 1
	   		DEFINE CELL NAME "RA_CARGO"	  OF oSecMat ALIAS "SRA" BLOCK {|| SRA->RA_CARGO}
	   		DEFINE CELL NAME "DESCARGO"   OF oSecMat TITLE "Descripcion" Size 25 BLOCK {|| AllTrim(POSICIONE("SQ3",1,xFilial("SQ3")+SRA->RA_CARGO,"Q3_DESCSUM"))}
	   		DEFINE CELL NAME "M0_NOME"	  OF oSecMat TITLE "Sede" Size 40 BLOCK {|| AllTrim(Posicione("SM0",1,cEmpAnt+SRA->RA_FILIAL,"M0_NOME"))}
		ENDIF
		
		DEFINE CELL NAME "RA_RG"		OF oSecMat TITLE OemToAnsi(STR0074) Size 20 BLOCK {|| SRA->RA_RG} 	
		DEFINE CELL NAME "RA_CC"	    OF oSecMat TITLE  SIZE 9 BLOCK {|| cCentroC := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,2,,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,2,,.T.) )} //busca informaÁ„o historicas
		DEFINE CELL NAME "CTT_DESC01"   OF oSecMat TITLE OemToAnsi(STR0028) SIZE 60 BLOCK {|| cDescCC := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,2,2,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,2,2,.T.) )}
		DEFINE CELL NAME "TPSAL" 		OF oSecMat TITLE OemToAnsi(STR0075) SIZE 20 BLOCK {|| ctpSal := IIF(SRA->RA_TIPOSAL=='1',UPPER(STR0063),IIF(SRA->RA_TIPOSAL=='2',UPPER(STR0064),IIF(SRA->RA_TIPOSAL=='3',UPPER(STR0065),UPPER(STR0066))))}	
		DEFINE CELL NAME "RA_DEPTO"	    OF oSecMat TITLE OemToAnsi(STR0007) SIZE  9 BLOCK {|| cDepto := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,3,,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,3,,.T.) )}
		DEFINE CELL NAME "QB_DESCRIC"   OF oSecMat TITLE OemToAnsi(STR0028) SIZE 60 BLOCK {|| cDescDepto := IIF( nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,3,2,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,3,2,.T.) ) }
		  
		IF nAnaSin = 1
			DEFINE CELL NAME "RA_NITARL"  OF oSecMat ALIAS "SRA" BLOCK {|| SRA->RA_NITARL}
			DEFINE CELL NAME "DESCARL"	  OF oSecMat TITLE "Descripcion" Size 60 BLOCK {|| fTabela("S008",fPosTab("S008",SRA->RA_NITARL, "=", 4),5)}
			DEFINE CELL NAME "RA_CODRPAT" OF oSecMat ALIAS "SRA" BLOCK {|| SRA->RA_CODRPAT}
			DEFINE CELL NAME "DESCPAT"	  OF oSecMat TITLE "Descripcion" Size 60 BLOCK {|| fTabela("S008",fPosTab("S008",SRA->RA_CODRPAT, "=", 4),5)}
			DEFINE CELL NAME "RA_CODAFP"  OF oSecMat ALIAS "SRA" BLOCK {|| SRA->RA_CODAFP}
			DEFINE CELL NAME "DESCAFP"	  OF oSecMat TITLE "Descripcion" Size 60 BLOCK {|| fTabela("S008",fPosTab("S008",SRA->RA_CODAFP, "=", 4),5)}
			DEFINE CELL NAME "RA_CXCOMP"  OF oSecMat ALIAS "SRA" BLOCK {|| SRA->RA_CXCOMP}
			DEFINE CELL NAME "DESCCXC"	  OF oSecMat TITLE "Descripcion" Size 60 BLOCK {|| fTabela("S008",fPosTab("S008",SRA->RA_CXCOMP, "=", 4),5)}
			DEFINE CELL NAME "RA_FUNCESA" OF oSecMat ALIAS "SRA" BLOCK {|| SRA->RA_FUNCESA}
			DEFINE CELL NAME "DESCFUN"	  OF oSecMat TITLE "Descripcion" Size 60 BLOCK {|| fTabela("S008",fPosTab("S008",SRA->RA_FUNCESA, "=", 4),5)}
		    IF cRoteiro == "CES"
		    	DEFINE CELL NAME "RA_BCDPFGT" OF oSecMat ALIAS "SRA" BLOCK {|| SRA->RA_BCDPFGT}
		   		DEFINE CELL NAME "DESCBCO"    OF oSecMat TITLE "Descripcion" Size 25 BLOCK {|| AllTrim(POSICIONE("SA6",1,xFilial("SA6")+SRA->RA_BCDPFGT,"A6_NREDUZ"))}
		    ELSE
		    	DEFINE CELL NAME "RA_BCDEPSA" OF oSecMat ALIAS "SRA" BLOCK {|| SRA->RA_BCDEPSA}
		   		DEFINE CELL NAME "DESCBCO"    OF oSecMat TITLE "Descripcion" Size 25 BLOCK {|| AllTrim(POSICIONE("SA6",1,xFilial("SA6")+SRA->RA_BCDEPSA,"A6_NREDUZ"))}
		    ENDIF
		ENDIF	
		
		DEFINE CELL NAME "CTO_DESC" 	OF oSecMat TITLE OemToAnsi(STR0076) SIZE	20 BLOCK {|| cMoneda := POSICIONE("CTO",1,XFILIAL("CTO")+SRA->RA_MOEDAPG,"CTO_DESC")}
		DEFINE CELL NAME "RA_ADMISSA"   OF oSecMat ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_ADMISSA) }
		
		DEFINE CELL NAME "RA_CATFUNC"		OF oSecMat TITLE OemToAnsi(STR0082) SIZE 20  BLOCK {|| cCatFun := SRA->RA_CATFUNC + " " + SUBSTR(POSICIONE("SX5",1,XFILIAL("SX5") + "28" + SRA->RA_CATFUNC ,"X5_DESCSPA"),1,20)  }
		DEFINE CELL NAME "VALSAL"	  	OF oSecMat TITLE( IIF(SRA->RA_TIPOSAL $"13",STR0072,STR0073)) SIZE 20 PICTURE "@E 99,999,999,999.99" BLOCK {|| SRA->RA_SALARIO}	
		DEFINE CELL NAME "RA_REMVAR" 	OF oSecMat TITLE OemToAnsi(STR0077)	SIZE 10 BLOCK {|| cRemVar := IIF(SRA->RA_REMVAR == "1", STR0067, STR0068) } 
		DEFINE CELL NAME "RA_GROSSUP"	OF oSecMat TITLE OemToAnsi(STR0078) 	SIZE 20 BLOCK {|| cGrossUp:= IIF(SRA->RA_GROSSUP== "1",STR0069,IIF(SRA->RA_GROSSUP =="2",STR0070,STR0071))}
		DEFINE CELL NAME "RA_SALEST"	OF oSecMat TITLE OemToAnsi(STR0079)  	SIZE 20 BLOCK {|| cSalExt	:= IIF(SRA->RA_SALEST=="1",STR0067,STR0068)}
							
		DEFINE CELL NAME "RA_HRSMES"    OF oSecMat ALIAS "SRA" 
		DEFINE CELL NAME "RA_TIPOPRC"	OF oSecMat ALIAS "SRA" 
		DEFINE CELL NAME "PERRET"		OF oSecMat TITLE OemToAnsi(STR0081) SIZE 20 BLOCK {||cPerRet := IIF(SRA->RA_TIPOPRC=="1",STR(SRA->RA_PERCIR)+OemToAnsi(STR0083),"") }
		
		DEFINE CELL NAME "PERCADT"      OF oSecMat TITLE OemToAnsi(STR0023)	SIZE 3 		//"Perc.Adto.: "
		DEFINE CELL NAME "RA_CIC"       OF oSecMat ALIAS "SRA"
		DEFINE CELL NAME "RA_CURP"      OF oSecMat ALIAS "SRA"
		
		DEFINE CELL NAME "RA_TSIMSS"    OF oSecMat ALIAS "SRA" 
		DEFINE CELL NAME "RCO_NREPAT"   OF oSecMat ALIAS "RCO" 

		If lRaDtrec
			DEFINE CELL NAME "RA_DTREC"   OF oSecMat ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_DTREC) }
		Endif
		
		If lRaFecrei
			DEFINE CELL NAME "RA_FECREI"  OF oSecMat ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_FECREI) } 
		Endif
		
		If lRaSalDia	
			DEFINE CELL NAME "RA_SALDIA"  OF oSecMat TITLE  SIZE 13 BLOCK {||cSaldia := IIF( nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDtPerFim,4), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDtPerFim,4))} 
		Endif
		
		If lRaSalInt
			DEFINE CELL NAME "RA_SALINT"  OF oSecMat TITLE  SIZE 13 BLOCK {||cSaldii :=	IIF( nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDtPerFim,5), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDtPerFim,5))} 
		EndIf 
		
		DEFINE CELL NAME "ESPACO2"    OF oSecMat TITLE "" BLOCK {||" "}		//Recurso alternativo para saltar linha. 
		DEFINE CELL NAME "PROVDESC"   OF oSecMat TITLE "" SIZE 125 

		oSecMat:SetLineStyle()                                                         	
		oSecMat:SetCols(3)
		oSecMat:SetTotalInLine(.F.)
		oSecMat:Cell("ESPACO"    ):SetCellBreak(.T.)
		oSecMat:Cell("RA_NOME"   ):SetCellBreak(.T.) 		
		
		oSecMat:Cell("RA_RG"):SetCellBreak(.T.)
		oSecMat:Cell("TPSAL"):SetCellBreak(.T.)
		oSecMat:Cell("CTO_DESC"):SetCellBreak(.T.)
		
		oSecMat:Cell("ESPACO2"   ):SetCellBreak(.T.)
		
		oSecMat:Cell("RA_CIC"    ):Disable()
		oSecMat:Cell("RCO_NREPAT"):Disable()
		oSecMat:Cell("PERRET" ):SetCellBreak(.T.)				
			
		oSecMat:Cell("RA_CURP"   ):Disable()
		oSecMat:Cell("RA_TSIMSS" ):Disable()
			
		If lRaDtRec
			oSecMat:Cell("RA_DTREC"  ):Disable()
		Endif
		
		If lRaFecrei
			oSecMat:Cell("RA_FECREI" ):Disable()
		Endif
			
		If lRaSaldia
			oSecMat:Cell("RA_SALDIA" ):Disable()
		Endif
			
		If lRaSalint
			oSecMat:Cell("RA_SALINT" ):Disable()				
		Endif

		oSecMat:Disable()
		oSecMat:SetCharSeparator(" ")
		oSecMat:SetDynamicKey(OemToAnsi(STR0002))	//"MatrÌcula" 

		TRPosition():New(oSecMat,"SRA",nOrdSra,{|| If (nAnaSin == 1 , (cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT, " ")},.T.)
		

	//SECTION 02 
	DEFINE SECTION oSecLan OF oReport TITLE OemToAnsi(STR0026) TABLES "SRC", "SRD", "SRV", "SRA"	//Verbas do Funcion·rio

		DEFINE CELL NAME "RA_MAT" OF oSecLan ALIAS "SRA"
		DEFINE CELL NAME "PDP"    OF oSecLan TITLE OemToAnsi(STR0027) SIZE 03 PICTURE "@!"	 	//"Cod."
		DEFINE CELL NAME "DESCP"  OF oSecLan TITLE OemToAnsi(STR0028) SIZE 14 PICTURE "@!" 		//"DescriÁ„o"
		DEFINE CELL NAME "REFERP" OF oSecLan TITLE OemToAnsi(STR0029) SIZE 08 					//"Ref."
		DEFINE CELL NAME "VALORP" OF oSecLan TITLE OemToAnsi(STR0030) SIZE nSize				//"Valor"
		DEFINE CELL NAME "PIPEP"  OF oSecLan TITLE "|"        BLOCK {||"|"}

		DEFINE CELL NAME "PDD"    OF oSecLan TITLE OemToAnsi(STR0027) SIZE 03 PICTURE "@!"	 	//"Cod."
		DEFINE CELL NAME "DESCD"  OF oSecLan TITLE OemToAnsi(STR0028) SIZE 14 PICTURE "@!" 		//"DescriÁ„o"
		DEFINE CELL NAME "REFERD" OF oSecLan TITLE OemToAnsi(STR0029) SIZE 08 					//"Ref."
		DEFINE CELL NAME "VALORD" OF oSecLan TITLE OemToAnsi(STR0030) SIZE nSize				//"Valor"
		DEFINE CELL NAME "PIPED"  OF oSecLan TITLE "|"        BLOCK {||"|"}

		DEFINE CELL NAME "PDB"    OF oSecLan TITLE OemToAnsi(STR0027) SIZE 03 PICTURE "@!"	 	//"Cod."
		DEFINE CELL NAME "DESCB"  OF oSecLan TITLE OemToAnsi(STR0028) SIZE 15 PICTURE "@!" 		//"DescriÁ„o"    
		
		DEFINE CELL NAME "VALORB" OF oSecLan TITLE OemToAnsi(STR0030) SIZE nSize 				//"Valor"
	
		oSecLan:SetName("LANCAMENTO")
		oSecLan:Cell("RA_MAT"):Disable()
		oSecLan:Cell("REFERP"):SetHeaderAlign("RIGHT")
		oSecLan:Cell("VALORP"):SetHeaderAlign("RIGHT")
		oSecLan:Cell("VALORP"):lAutoSize := .F.
		oSecLan:Cell("REFERD"):SetHeaderAlign("RIGHT")
		oSecLan:Cell("VALORD"):SetHeaderAlign("RIGHT")
		oSecLan:Cell("VALORB"):SetHeaderAlign("RIGHT")
		oSecLan:SetTotalInLine(.F.)
 		oSecLan:Disable()
		oSecLan:SetDynamicKey(OemToAnsi(STR0004))	//"LanÁamentos"

	//SECTION 03 
	DEFINE SECTION oSecNom OF oReport TITLE OemToAnsi(STR0040) TABLES "SRA","SQB","CTT","RCO" ORDERS aOrd	//"Filial / Nome"

		DEFINE CELL NAME "ESPACO"     OF oSecNom TITLE "" BLOCK {||" "}		//Recurso alternativo para que a section do funcion·rio n·o saia colada a collection.
		DEFINE CELL NAME "RA_FILIAL"  OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_NOME"    OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_MAT"     OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "CODFUNC"	  OF oSecNom TITLE OemToAnsi(STR0021) SIZE 5 BLOCK {||cCodFunc}			//"FunÁ„o"
		DEFINE CELL NAME "DESCFUNC"   OF oSecNom TITLE OemToAnsi(STR0028) SIZE 20 BLOCK {||Substr(cDescFunc,1,20)}
        
		DEFINE CELL NAME "RA_CC"	  OF oSecNom TITLE  SIZE 9 BLOCK {|| cCentroC := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,2,,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,2,,.T.) )} //busca informaÁ„o historicas
		DEFINE CELL NAME "CTT_DESC01" OF oSecNom TITLE OemToAnsi(STR0028) SIZE 60 BLOCK {|| cDescCC := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,2,2,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,2,2,.T.) )}
		DEFINE CELL NAME "RA_DEPTO"	  OF oSecNom TITLE OemToAnsi(STR0007) SIZE 9 BLOCK {|| cDepto := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,3,,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,3,,.T.) )}
		DEFINE CELL NAME "QB_DESCRIC" OF oSecNom TITLE OemToAnsi(STR0028)SIZE 20 BLOCK {|| cDescDepto := IIF( nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,3,2,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,3,2,.T.) ) }
		
		DEFINE CELL NAME "RA_ADMISSA" OF oSecNom ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_ADMISSA) }
		DEFINE CELL NAME "RA_CATFUNC" OF oSecNom ALIAS "SRA" BLOCK {|| SRA->RA_CATFUNC }
		DEFINE CELL NAME "VALSAL"	  OF oSecNom TITLE OemToAnsi(STR0022) SIZE 20 PICTURE "@E 99,999,999,999.99" ;	//"Sal.: "
			BLOCK {||f2BuscaValSalA()}
		
		DEFINE CELL NAME "RA_DEPIR"   OF oSecNom ALIAS "SRA"
		
		If lDepSf
			DEFINE CELL NAME "RA_DEPSF"   OF oSecNom ALIAS "SRA"
		EndIf
		
		DEFINE CELL NAME "RA_HRSMES"  OF oSecNom ALIAS "SRA" 
		
		DEFINE CELL NAME "PERCADT"    OF oSecNom TITLE OemToAnsi(STR0023)	SIZE 3 		//"Perc.Adto.: "
		DEFINE CELL NAME "RA_CIC"     OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_CURP"    OF oSecNom ALIAS "SRA" 
		DEFINE CELL NAME "RA_RG"      OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_TSIMSS"  OF oSecNom ALIAS "SRA" 
		DEFINE CELL NAME "RCO_NREPAT" OF oSecNom ALIAS "RCO"
				
		If lRaDtrec
			DEFINE CELL NAME "RA_DTREC"   OF oSecNom ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_DTREC) }
		Endif
		
		If lRaFecrei
			DEFINE CELL NAME "RA_FECREI"  OF oSecNom ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_FECREI)}
		Endif
		
		If lRaSalDia
			DEFINE CELL NAME "RA_SALDIA"  OF oSecNom ALIAS "SRA"
		Endif
		
		If lRaSalInt
			DEFINE CELL NAME "RA_SALINT"  OF oSecNom ALIAS "SRA"			
		Endif
		
		DEFINE CELL NAME "ESPACO2"    OF oSecNom TITLE "" BLOCK {||" "}		//Recurso alternativo para saltar linha. 
		DEFINE CELL NAME "PROVDESC"   OF oSecNom TITLE "" SIZE 125 

		oSecNom:SetLineStyle()                                                         	
		oSecNom:SetCols(3)
		oSecNom:SetTotalInLine(.F.) 
		oSecNom:Cell("ESPACO"    ):SetCellBreak(.T.)
		oSecNom:Cell("RA_MAT"    ):SetCellBreak(.T.) 
		oSecNom:Cell("DESCFUNC"  ):SetCellBreak(.T.)
		oSecNom:Cell("QB_DESCRIC"):SetCellBreak(.T.)
		oSecNom:Cell("CTT_DESC01"):SetCellBreak(.T.)
		oSecNom:Cell("ESPACO2"   ):SetCellBreak(.T.)
		

		oSecNom:Cell("RA_CIC"    ):Disable()
		oSecNom:Cell("RCO_NREPAT"):Disable()
		oSecNom:Cell("RA_RG"     ):Disable() 
		oSecNom:Cell("RA_HRSMES" ):SetCellBreak(.T.)							
		oSecNom:Cell("RA_CURP"   ):Disable()
		oSecNom:Cell("RA_TSIMSS" ):Disable()
			
		If lRaDtRec
			oSecNom:Cell("RA_DTREC"  ):Disable()
		Endif
		
		If lRaFeCrei
			oSecNom:Cell("RA_FECREI" ):Disable()
		Endif
			
		If lRaSalDia
			oSecNom:Cell("RA_SALDIA" ):Disable()
		Endif
			
		If lRaSalInt
			oSecNom:Cell("RA_SALINT" ):Disable()				
		Endif
			
		oSecNom:Disable()
		oSecNom:SetCharSeparator("")
		oSecNom:SetDynamicKey(OemToAnsi(STR0003))	//"Nome" 
		TRPosition():New(oSecNom,"SRA",nOrdSra,{|| If (nAnaSin == 1 , (cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT, " ")},.T.)

	//SECTION 04 
	DEFINE SECTION oSecCtc OF oReport TABLES "CTT" ORDERS aOrd TITLE OemToAnsi(STR0041) TOTAL IN COLUMN  // "C.Custo Cadastro"
		DEFINE CELL NAME "CTT_FILIAL" 	OF oSecCtc ALIAS "CTT"
		DEFINE CELL NAME "CTT_CUSTO"   	OF oSecCtc ALIAS "CTT" 
		DEFINE CELL NAME "CTT_DESC01"	OF oSecCtc TITLE OemToAnsi(STR0028) ALIAS "CTT"

		oSecCtc:SetLineStyle()
		oSecMat:SetCols(4)                                                         	
		oSecCtc:Disable()
		oSecCtc:SetDynamicKey(OemToAnsi(STR0005))	//"C.Custo Cad."

	//SECTION 05 
	DEFINE SECTION oSecSqb OF oReport TABLES "SQB", "CTT", "SRA" ORDERS aOrd TITLE OemToAnsi(STR0046) TOTAL IN COLUMN // "Departamento"
		
		DEFINE CELL NAME "QB_FILIAL"	OF oSecSqb ALIAS "SQB"                
		DEFINE CELL NAME "QB_DEPTO"		OF oSecSqb TITLE OemToAnsi(STR0007)	ALIAS "SQB"
		DEFINE CELL NAME "QB_DESCRIC"	OF oSecSqb TITLE OemToAnsi(STR0028)	ALIAS "SQB"	
	
		oSecSqb:SetLineStyle()
		oSecMat:SetCols(4)                                                         	
		oSecSqb:Cell("QB_FILIAL"):Disable()
		oSecSqb:Disable()
		oSecSqb:SetDynamicKey(OemToAnsi(STR0007))	//"Depto."

	//SECTION 06 
	DEFINE SECTION oSecCtm OF oReport TABLES "CTT" ORDERS aOrd TITLE OemToAnsi(STR0048) TOTAL IN COLUMN // "C.Custo Movimento"
		
		DEFINE CELL NAME "CTT_FILIAL" 	OF oSecCtm ALIAS "CTT" 
		DEFINE CELL NAME "CTT_CUSTO"   	OF oSecCtm ALIAS "CTT" 
		DEFINE CELL NAME "CTT_DESC01"	OF oSecCtm TITLE OemToAnsi(STR0028) ALIAS "CTT" 

		oSecCtm:SetLineStyle()
		oSecMat:SetCols(4)                                                         	
		oSecCtm:Disable()
		oSecCtm:SetDynamicKey(OemToAnsi(STR0006))	//"C.Custo Mov."

	//SECTION 07
	DEFINE SECTION oSecDifLiq OF oReport TITLE "" // "Dif de Liquidos"
		
Return(oReport)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ R106Imp    ≥ Autor ≥ Tania Bronzeri        ≥ Data ≥30/11/2007 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ≥±±
±±≥Descriáao ≥ Relatorio de Folha de Pagamento                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPER106                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function R106Imp(oReport)
Local oSectLanc		:= oReport:Section(2)
Local oSectFunc     
Local oSectCttc 
Local oSectDept
Local oSectLocp
Local cFiltro		:= ""   
Local cFiltroC 		:= ""   
Local cFiltroD 		:= ""   
Local cSitQuery		:= ""
Local cCatQuery		:= ""
Local cTpcQuery		:= ""
Local cVerQuery		:= ""
Local cIndCond		:= ""
Local cOrdemFun		:= ""
Local cOrdemLan		:= ""
Local cDescrVerbas	:= ""
Local cTitFil			:= ""
Local cTitUnN			:= ""
Local cTitEFil		:= ""
Local cTitCC			:= ""
Local cTitDp			:= "" 
Local cTitPd			:= ""
Local cTitFun			:= ""
Local cSinal			:= ""
Local cStatus			:= "" 
Local cBrFil			:= ""
Local cBrCc			:= ""
Local cBrDep			:= ""
Local cCpoAls			:= ""
Local cCpoAlsC		:= ""
Local cCpoAlsD		:= ""
Local cCpoView		:= ""
Local cCpoViewC		:= ""
Local cCpoViewD		:= ""
Local cCpoViewG		:= ""
Local cCpoAdView		:= ""
Local cCpoDelim		:= "" 
Local cCpoDelimC		:= ""
Local cCpoDelimD		:= ""
Local cCpoAdicLan		:= "" // CAMPOS ADICIONAIS A SEREM UTILIZADOS NA SECAO DE LANCAMENTOS
Local cCpoAdicEsp		:= "" // CAMPOS ADICIONAIS DE PAISES ESPECIFICOS
Local cCpoCcRc		:= ""
Local cCpoCcRd		:= ""
Local cJoin			:= ""
Local cJoinC			:= ""
Local cJoinD			:= ""
Local cJoinSQB		:= ""
Local cJoin1			:= "" //Juncao de todos os Joins para realizar a Query cAliasFun SRC
Local cJoin2			:= "" //Juncao de todos os Joins para realizar a Query cAliasFun SRD
Local cJoin3			:= "" //Juncao de todos os Joins para realizar a Query cAliasQry SRC
Local cJoin4			:= "" //Juncao de todos os Joins para realizar a Query cAliasQry SRD
Local cJoinEsp		:= "" // JOIN ADICIONAL DE PAISES ESPECIFICOS
Local cCCpoQuebra		:= ""
Local cDCpoQuebra		:= ""
Local cJoinView		:= ""
Local cNotDel			:= ""
Local cFilVerba		:= ""
Local cCountQ			:= ""
Local cMes				:= ""
Local cAno				:= ""
Local cNumPg			:= Space(2)
Local cExtraC			:= "%%"                
Local cExtraD			:= "%%"
Local cGroupEC		:= "%%"               
Local cGroupED		:= "%%" 
Local nReg				:= 0
Local nCont			:= 0 
Local nExist			:= 0
Local nPos				:= 0

Local lQ				:= .T.     

Local bLancamentos	:= {|oSelf|fImprimeLanca(oSelf)}
Local bLancSint		:= {|oSelf|fImprSint(oSelf)}
Local bBlock			:= {}

Local cCoalese		:= "" 
Local cDepenContr	:= ""
Local cJoinAux		:= ""  

Private aVerbas		:= {}
Private aVerbasRet	:= {}
Private aVerbasSin	:= {}
Private aPerAberto	:= {}
Private aPerFechado	:= {}
Private nHrsMes		:= 0
Private nSalario	:= 0 
Private cCpoQuebra	:= "" 
Private c2CpoQbr	:= ""
Private cFilAux 	:= "##"

nOrdSra 	:= RetOrdem("RA_FILIAL+RA_MAT")
nOrdem		:= oReport:GetOrder()

If (nOrdRemov > 0) .And. (nOrdem >= nPosRemov)
	nOrdem := nOrdem + nOrdRemov
EndIf

cCpoView	:= "%RAFILIAL RA_FILIAL"
cCpoViewG	:= "%RAFILIAL"
cCpoAls	:= "%RA_FILIAL RAFILIAL"

If nOrdem == 1		//MatrÌcula
	oSectFunc 	:= oReport:Section(1) 
ElseIf nOrdem == 2		//Nome
	oSectFunc 	:= oReport:Section(3) 
ElseIf nOrdem == 3		//C.Custo Cadastro + MatrÌcula
	oSectCttc	:= oReport:Section(4) 
	oSectFunc 	:= oReport:Section(1) 
	If nAnaSin == 1	//AnalÌtico
		oSectFunc:Cell("RA_CC"     ):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable()  
	EndIf
ElseIf nOrdem == 4		//C.Custo Cadastro + Nome
	oSectCttc	:= oReport:Section(4) 
	oSectFunc 	:= oReport:Section(3) 
	If nAnaSin == 1	//AnalÌtico
		oSectFunc:Cell("RA_CC"     ):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable() 
	EndIf
ElseIf nOrdem == 5		//C.Custo Movimento + MatrÌcula
	oSectCttc	:= oReport:Section(6) 
	oSectFunc 	:= oReport:Section(1) 
	If nAnaSin == 1	//AnalÌtico
		oSectFunc:Cell("RA_CC"     ):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable() 
	EndIf
ElseIf nOrdem == 6		//C.Custo Movimento + Nome
	oSectCttc	:= oReport:Section(6) 
	oSectFunc 	:= oReport:Section(3) 
	If nAnaSin == 1	//AnalÌtico
		oSectFunc:Cell("RA_CC"     ):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable() 
	EndIf
ElseIf nOrdem == 7		//Depto + MatrÌcula
	oSectDept	:= oReport:Section(5) 
	oSectFunc 	:= oReport:Section(1) 
	oSectDept:Cell("QB_FILIAL" ):Enable()
	If nAnaSin == 1	//AnalÌtico
		oSectFunc:Cell("RA_DEPTO"  ):Disable()
		oSectFunc:Cell("QB_DESCRIC"):Disable()
	EndIf
ElseIf nOrdem == 8		//Depto + Nome
	oSectDept	:= oReport:Section(5) //section(6)
	oSectFunc 	:= oReport:Section(3) //section(4)
	oSectDept:Cell("QB_FILIAL" ):Enable()
	If nAnaSin == 1	//AnalÌtico
		oSectFunc:Cell("RA_DEPTO"  ):Disable()
		oSectFunc:Cell("QB_DESCRIC"):Disable() 
	EndIf
EndIf

oSectFunc:SetName("FUNCIONARIO")
oSectFunc:SetLineCondition( { || Eval(bBlock) } )

cProcesso	:= mv_par01 
cProcessoa	:= mv_par02
cRoteiro	:= mv_par03
cPeriodo	:= mv_par04
cPagamento	:= mv_par05
cSituacao	:= mv_par11
cCategoria	:= mv_par12
nTpContr 	:= mv_par13						//Tipo Contrato:  1=Indeterminado; 2=Determinado; 3=Ambos
nAnaSin   	:= mv_par14						//Tipo Relatorio: 1=Analitico; 2=Sintetico
lBrkCc		:= Iif(mv_par15 == 1 .And. mv_par14 == 1,.T.,.F.)	//Salta Pag. quebra C.Custo: 1=Sim; 2=Nao
lBrkDp		:= Iif(mv_par16 == 1 .And. mv_par14 == 1,.T.,.F.)	//Salta Pag. quebra Depto:   1=Sim; 2=Nao
lImpFil  	:= Iif(mv_par17 == 1,.T.,.F.)	//Imprime totais por Filial: 1=Sim; 2=Nao
lImpEmp  	:= Iif(mv_par18 == 1,.T.,.F.)	//Imprime totais por Empr.:  1=Sim; 2=Nao
lImpUni		:= Iif(lImpEmp,.T.,.F.)	//Imprime totais por Unidade de Negocio: se imprime totais por empresa=Sim; senao = Nao
nTipCC   	:= mv_par19						//Tipo Impressao C.Custo: 1=Codigo; 2=Descricao; 3=Ambos
nTipDp		:= mv_par20						//Tipo Impressao Depto:   1=Codigo; 2=Descricao; 3=Ambos
lImpBase	:= Iif(mv_par21 == 1, .T., .F.)	//Imprimir Bases: 		  1=Sim; 2=Nao
lBrkPagFil	:= (MV_PAR24 == 1)

cTitulo := fDesc("SRY", cRoteiro, "RY_DESC", , xFilial("SRY"), RetOrdem("SRY","RY_FILIAL+RY_CALCULO"))

oReport:SetTitle(AllTrim(cTitulo))

If nAnaSin == 2
	lSint := .T.
Else
	lSint := .F.
Endif

If ( nAnaSin == 1)
   bBlock := {|| dbSelectArea("SRA"), SRA->(dbSetOrder(1)), SRA->(MsSeek((cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT)), fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc),  fCtrlDtRA(oSectFunc)}
ElseIf( nAnaSin == 2 )
	bBlock := {|| .T. }
	oSectLanc:SetParentRecno()
	oSectLanc:SetNoSkip()
EndIf

lDifLiq	:= .F.
lSumaVerba	:= IIf(cPaisLoc == "COS", lAglutPd, .F.)

If nTipCC == 1              	//-- Codigo C.Custo 
	oSectFunc:Cell("CTT_DESC01"):Disable()
ElseIf nTipCC == 2          	//-- Descricao C.Custo
	oSectFunc:Cell("RA_CC"     ):Disable()
EndIf

If nTipDp == 1              	//-- Codigo Depto.
	oSectFunc:Cell("QB_DESCRIC"):Disable()
ElseIf nTipDp == 2          	//-- Descricao Depto.
	oSectFunc:Cell("RA_DEPTO"  ):Disable()
EndIf

If (nAnaSin == 1 .And. !lSint)	//AnalÌtico
	oSectFunc:Cell("PROVDESC"):Enable()
	If lImpBase 
		oSectFunc:Cell("PROVDESC"  ):SetBlock({|| "       D E V E N G O S                                    D E S C U E N T O S                               B A S E S"}) //OemToAnsi(STR0024)})
			
	Else	
		oSectLanc:Cell("PDB"    ):SetTitle("")	
		oSectLanc:Cell("DESCB"  ):SetTitle("")	
		oSectLanc:Cell("VALORB" ):SetTitle("")	

		oSectLanc:Cell("PDB"     ):Hide()
		oSectLanc:Cell("DESCB"   ):Hide()
		oSectLanc:Cell("VALORB"  ):Hide()
		oSectFunc:Cell("PROVDESC"):SetBlock({|| "       D E V E N G O S                                 D E S C U E N T O S "}) //OemToAnsi(STR0025)})
			
	EndIf 
Else 
	oSectFunc:Cell("PROVDESC"):Disable()
Endif

cNumPg := If (cPagamento == "99" , Nil , cPagamento)

//ESTA FUN«√O BUSCA TODOS OS PERIODOS EM ABERTO E FECHADO DOS FUNCIONARIOS
RetPerAbertFech(cProcesso,cRoteiro,cPeriodo,cPagamento,,,@aPerAberto,@aPerFechado)

If Empty(aPerAberto) .And. Empty(aPerFechado)
   MsgAlert(STR0031,STR0032)	//"Nao foi encontrado nenhum periodo" ### "Verifique Par‚metros de Impress„o."
   Return
Endif          

If (nPos:=aScan(aPerAberto, {|x| x[1] == cPeriodo .And. x[2] == cNumPg})) > 0 
	cMes		:= aPerAberto[nPos,3]
	cAno		:= aPerAberto[nPos,4]		
	dDtPerIni	:= aPerAberto[nPos,5]
	dDtPerFim	:= aPerAberto[nPos,6]
	dDtPago	:= aPerAberto[nPos,7]
Elseif (nPos:=aScan(aPerFechado, {|x| x[1] == cPeriodo .And. x[2] == cNumPg})) > 0 
	cMes		:= aPerFechado[nPos,3]
	cAno		:= aPerFechado[nPos,4]		
	dDtPerIni	:= aPerFechado[nPos,5]
	dDtPerFim	:= aPerFechado[nPos,6]
	dDtPago	:= aPerFechado[nPos,7]
Endif 

//--MONTAGEM DO DDATAREF SOBRE O PERIODO
dDataRef	:= CtoD("01/" + cMes + "/" + cAno)
cMesAnoRef	:= StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)
cAnoMesRef	:= Right(cMesAnoRef,4) + Left(cMesAnoRef,2)

If cPagamento # "99"
	cTitulo += AllTrim(GR040RetPer( cPagamento, cPeriodo )) 
Else
	cTitulo += " / "+Upper(MesExtenso(Month(dDataRef)))+OemToAnsi(STR0035)+STR(YEAR(dDataRef),4) 	//" DE " 
EndIf

If nAnaSin	== 1 	//Analitico	
	If !lSint
		cTitulo += " - " + OemToAnsi(STR0033)	//AnalÌtico
	Else 
		cTitulo += " - " + OemToAnsi(STR0034)	//Sintetico
	Endif
	
	If nOrdem == 1
		cTitulo += " - " + OemToAnsi(STR0002)	//MatrÌcula
	ElseIf nOrdem == 2
		cTitulo += " - " + OemToAnsi(STR0003)	//Nome    
	Else
		oSectFunc:Cell("RA_FILIAL" ):Disable()
	EndIf
	
	oSectFunc:OnPrintLine(bLancamentos)
	oSectLanc:OnPrintLine(bLancamentos)	
	oSectFunc:Cell("PERCADT"   ):SetBlock({||StrZero((cAliasFun)->RA_PERCADT,3)})
	
Else	//SintÈtico 
	cTitulo += " - " + OemToAnsi(STR0034)	//Sintetico 
	oSectFunc:OnPrintLine(bLancSint)  
	oSectLanc:OnPrintLine(bLancSint) 
	oSectFunc:Cell("ESPACO"	   ):Disable()
	oSectFunc:Cell("RA_MAT"    ):Disable()			
	oSectFunc:Cell("RA_NOME"   ):Disable()			
	oSectFunc:Cell("CODFUNC"   ):Disable()			
	oSectFunc:Cell("DESCFUNC"  ):Disable()			
	oSectFunc:Cell("RA_ADMISSA"):Disable()			
	oSectFunc:Cell("RA_CATFUNC"):Disable()			
	oSectFunc:Cell("VALSAL"    ):Disable()
	
	  	If cPaisLoc <> "COL"			
			oSectFunc:Cell("RA_DEPIR"  ):Disable()			
			If lDepSf
				oSectFunc:Cell("RA_DEPSF"  ):Disable()			
			EndIf
		EndIf    
		oSectFunc:Cell("RA_HRSMES" ):Disable()			
	
	oSectFunc:Cell("PERCADT"   ):Disable()			
	oSectFunc:Cell("RA_CIC"    ):Disable()			
	oSectFunc:Cell("RA_CURP"   ):Disable()			
	oSectFunc:Cell("RA_RG"     ):Disable()			
	oSectFunc:Cell("RA_TSIMSS" ):Disable()			
	oSectFunc:Cell("RCO_NREPAT"):Disable()			
	
	If lRaDtRec
		oSectFunc:Cell("RA_DTREC"  ):Disable()			
	Endif
	
	If lRaFeCrei
		oSectFunc:Cell("RA_FECREI" ):Disable()			
	Endif
	
	If lRaSalDia
		oSectFunc:Cell("RA_SALDIA" ):Disable()			
	Endif
	
	If lRaSalInt
		oSectFunc:Cell("RA_SALINT" ):Disable()					
	Endif

	If nOrdem == 1 .Or. nOrdem == 2
		oSectFunc:Cell("RA_DEPTO"):Disable()			
		oSectFunc:Cell("QB_DESCRIC"):Disable()			
		oSectFunc:Cell("RA_CC"):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable()
	EndIf

	If nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5 .Or. nOrdem == 6	//C.Custo
		oSectFunc:Cell("RA_DEPTO"  ):Disable()
		oSectFunc:Cell("QB_DESCRIC"):Disable()			
	EndIf

	If nOrdem == 7 .Or. nOrdem == 8										//Depto.
		oSectFunc:Cell("RA_CC"     ):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable()                                 
	EndIf     
EndIf

If nOrdem == 3 .Or. nOrdem == 4
	cTitulo += " - " + OemToAnsi(STR0041)	//"C.Custo Cadastro"
ElseIf nOrdem == 5 .Or. nOrdem == 6 
	cTitulo += " - " + OemToAnsi(STR0048)	//"C.Custo Movimento"
ElseIf nOrdem == 7 .Or. nOrdem == 8
	cTitulo += " - " + OemToAnsi(STR0046)	//"Departamento"   
EndIf  


If ( lDifLiq .and. ( nAnaSin == 1 .And. !lSint) )
	oSectDifLiq	:= oReport:Section(7)  		
	DEFINE CELL NAME "DIFLIQ" 	OF oSectDifLiq TITLE "" SIZE 150 
	oSectDifLiq:SetLineStyle()
	
   	DEFINE BREAK oBreakDifLiq OF oSectFunc   WHEN {||(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_MAT} 		
	DEFINE FUNCTION NAME "UDIFLIQ"    FROM oSectFunc:Cell("PROVDESC") FUNCTION ONPRINT BREAK oBreakDifLiq NO END SECTION NO END REPORT TITLE OemToAnsi(STR0053) PICTURE "@!" FORMULA {|| f2CalcDifLiqU(oSectLanc:GetFunction("ULIQVALOR"):GetLastValue())}
   		
	oBreakDifLiq:OnBreak({|x,y|cTitFun:=OemToAnsi(STR0054)})	
    oBreakDifLiq:SetTotalText({||cTitFun})
    oBreakDifLiq:SetTotalInLine(.F.)   
EndIf    

If nAnaSin == 1 .And. !lSint	//AnalÌtico
	DEFINE BREAK oBreakFun OF oSectFunc   WHEN {||(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_MAT} 
	DEFINE FUNCTION NAME "UTOTREFERP" FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99"        	//"Ref."
	DEFINE FUNCTION NAME "UTOTVALORP" FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	//"Valor"
	DEFINE FUNCTION NAME "UTOTREFERD" FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99"  		//"Ref."
	DEFINE FUNCTION NAME "UTOTVALORD" FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"  	//"Valor"
	DEFINE FUNCTION NAME "ULIQDESC"   FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:"
	DEFINE FUNCTION NAME "ULIQVALOR"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("UTOTVALORP"):GetLastValue() - oSectLanc:GetFunction("UTOTVALORD"):GetLastValue()) } 	//"Liquido:"
			
	oBreakFun:OnBreak({|x,y|cTitFun:=OemToAnsi(STR0037)+" "+ x /*Subs(x,3,Len(x)-2)*/})	//"Totais Funcion·rio "
   	oBreakFun:SetTotalText({||cTitFun})
   	oBreakFun:SetTotalInLine(.F.)    
EndIf    	                                                              

If nOrdem == 7 .Or. nOrdem == 8		//Departamento
	If nAnaSin == 1	//AnalÌtico
		
		If nOrdem == 7 .Or. nOrdem == 8
			DEFINE BREAK oBreakDp  OF oSectDept WHEN  {|| ((cAliasFun)->RA_FILIAL+(cAliasFun)->QB_DEPTO) } 
			oBreakDp:lPageBreak := lBrkDp
			
			DEFINE BREAK oBreakFil OF oReport   WHEN  {|| (cAliasFun)->RA_FILIAL } 
			If lCorpManage
				If lUniNeg
					DEFINE BREAK oBreakUnN OF oReport ;
					  WHEN { || Substr((cAliasFun)->RA_FILIAL, nStartEmp, nEmpLength) + Substr((cAliasFun)->RA_FILIAL, nStartUnN, nUnNLength) } TITLE OemToAnsi(STR0030) //Quebra Unidade de Negocio  
				EndIf

				If lEmpFil
					DEFINE BREAK oBreakEFil OF oReport WHEN  { || Substr((cAliasFun)->RA_FILIAL, nStartEmp, nEmpLength) } //Quebra Empresa
				EndIf
			Else
				DEFINE BREAK oBreakEmp OF oReport WHEN  { || ""} //Quebra Empresa
			EndIf
		EndIf 
				
	Else			//SintÈtico   
		oSectFunc:Cell("RA_DEPTO"):SetBlock({||(cAliasQry)->RA_DEPTO})
		oSectFunc:Cell("QB_DESCRIC"):SetBlock({||(cAliasQry)->QB_DESCRIC})
		
		If nOrdem == 7 .Or. nOrdem == 8
			cCpoQuebra	:= "RA_DEPTO"
			cCpoAls		+= ", RA_DEPTO RADEPTO"
			cCpoView	+= ", RADEPTO RA_DEPTO"
			cCpoViewG	+= ", RADEPTO"                                      
			DEFINE BREAK oBreakDp  OF oReport WHEN  {|| oSectFunc:Cell("RA_FILIAL"):GetText() + oSectFunc:Cell("RA_DEPTO" ):GetText() } TITLE OemToAnsi(STR0047) //"Total do Departamento"
			oBreakDp:lPageBreak := lBrkDp

		   	DEFINE BREAK oBreakFil OF oReport WHEN  oSectFunc:Cell("RA_FILIAL") TITLE OemToAnsi(STR0030) //"Total da Filial "
			If lCorpManage
				If lUniNeg
					DEFINE BREAK oBreakUnN OF oReport ;
						WHEN  { || Substr(oSectFunc:Cell("RA_FILIAL"):GetText(), nStartEmp, nEmpLength) + Substr(oSectFunc:Cell("RA_FILIAL"):GetText(), nStartUnN, nUnNLength) } TITLE OemToAnsi(STR0030) //Quebra Unidade de Negocio   		
				EndIf

				If lEmpFil
					DEFINE BREAK oBreakEFil OF oReport WHEN  { || Substr(oSectFunc:Cell("RA_FILIAL"):GetText(), nStartEmp, nEmpLength) } //Quebra Empresa  				
				EndIf
			Else
				DEFINE BREAK oBreakEmp OF oReport WHEN  { || "" } //Quebra Empresa
			EndIf
		EndIf
	EndIf
	DEFINE FUNCTION NAME "DTOTREFERP" FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99"         	//"Ref."
	DEFINE FUNCTION NAME "DTOTVALORP" FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"   	//"Valor"
	DEFINE FUNCTION NAME "DTOTREFERD" FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99" 			//"Ref."
	DEFINE FUNCTION NAME "DTOTVALORD" FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"  	//"Valor"
	DEFINE FUNCTION NAME "DLIQDESC"   FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:"
	DEFINE FUNCTION NAME "DLIQVALOR"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("DTOTVALORP"):GetLastValue() - oSectLanc:GetFunction("DTOTVALORD"):GetLastValue()) } 	//"Liquido:"

	oBreakDp:OnBreak({|x,y|cTitDp:=OemToAnsi(STR0047)+" "+x})	//"Total Departamento "
   	oBreakDp:SetTotalText({||cTitDp})
   	oBreakDp:SetTotalInLine(.F.)                                                                

	If nAnaSin == 1
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() + " " + oSectLanc:Cell("DESCP"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERP"):GetValue(.T.)}	BREAK oBreakDp TITLE OemToAnsi(STR0043) PICTURE "@E 999,999.99"			NO END SECTION	NO END REPORT	//"Proventos"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| SectLanc:Cell("PDP"):GetText()} CONTENT {|| oSectLanc:Cell("VALORP"):GetValue(.T.)} BREAK oBreakDp TITLE OemToAnsi(STR0030) PICTURE "@E 999,999,999.99"	NO END SECTION	NO END REPORT	//"Valor"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() + " " + oSectLanc:Cell("DESCD"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERD"):GetValue(.T.)}	BREAK oBreakDp TITLE OemToAnsi(STR0044) PICTURE "@E 999,999.99"			NO END SECTION	NO END REPORT	//"Descontos"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| SectLanc:Cell("PDD"):GetText()} CONTENT {|| oSectLanc:Cell("VALORD"):GetValue(.T.)}	BREAK oBreakDp TITLE OemToAnsi(STR0030) PICTURE "@E 999,999,999.99"	NO END SECTION	NO END REPORT	//"Valor"

		If lImpBase		
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)} BREAK oBreakDp TITLE OemToAnsi(STR0045) PICTURE "@E 999,999,999.99"	NO END SECTION	NO END REPORT	//"Bases"
		EndIf
	EndIf
EndIf

If nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5 .Or. nOrdem == 6		//Centro de Custo
	If nAnaSin == 1	//AnalÌtico
		
		DEFINE BREAK oBreakCc   OF oReport   WHEN  {||((cAliasFun)->RA_FILIAL+(cAliasFun)->CTT_CUSTO)} 
		oBreakCc:lPageBreak := lBrkCc

 		DEFINE BREAK oBreakFil  OF oReport   WHEN  {|| (cAliasFun)->RA_FILIAL }                            
		If lCorpManage
			If lUniNeg
				DEFINE BREAK oBreakUnN OF oReport   WHEN { || Substr((cAliasFun)->RA_FILIAL, nStartEmp, nEmpLength) + Substr((cAliasFun)->RA_FILIAL, nStartUnN, nUnNLength) }  
			EndIf

			If lEmpFil
				DEFINE BREAK oBreakEFil OF oReport   WHEN { || Substr((cAliasFun)->CTT_FILIAL, nStartEmp, nEmpLength) }  
			EndIf
		Else
			DEFINE BREAK oBreakEmp OF oReport WHEN { || "" }
		EndIf
	Else			//SintÈtico
		
		oSectFunc:Cell("CTT_DESC01"):SetBlock({||(cAliasQry)->CTT_DESC01})        
	
		If nOrdem == 3 .Or. nOrdem == 4 
			oSectFunc:Cell("RA_CC"     ):SetBlock({||(cAliasQry)->RA_CC})
			cCpoQuebra	:= "RA_CC"
			cCpoAls		+= ", RA_CC RACC"
			cCpoView	+= ", RACC RA_CC"
			cCpoViewG	+= ", RACC"
			                                  
			DEFINE BREAK oBreakCc  OF oReport   WHEN  oSectFunc:Cell("RA_CC") 
			oBreakCc:lPageBreak := lBrkCc
			
		Elseif nOrdem == 5 .Or. nOrdem == 6 
			oSectFunc:Cell("RA_CC"     ):SetBlock({||(cAliasQry)->RCDCC})
			cCpoQuebra	:= "RCDCC"
			cCCpoQuebra	:= "RC_CC"
			cCpoAlsC	:= cCpoAls + ", RC_CC RCDCC"
			cCpoViewC	+= ", RCDCC RC_CC"                                      
			cDCpoQuebra	:= "RD_CC"
			cCpoAlsD	:= cCpoAls + ", RD_CC RCDCC"
			cCpoViewD	+= ", RCDCC RD_CC"  
			                                    
			DEFINE BREAK oBreakCc  OF oSectFunc   WHEN {||((cAliasQry)->FILIAL+(cAliasQry)->RCDCC)} 
			oBreakCc:lPageBreak := lBrkCc
			
		EndIf

		If nOrdem == 3 .OR. nOrdem == 4 .OR. nOrdem == 5 .OR. nOrdem == 6 
			DEFINE BREAK oBreakFil OF oReport   WHEN  oSectFunc:Cell("RA_FILIAL") 
			If lCorpManage
				If lUniNeg
					DEFINE BREAK oBreakUnN OF oReport   WHEN  { || Substr(oSectFunc:Cell("RA_FILIAL"):GetText(), nStartEmp, nEmpLength) + Substr(oSectFunc:Cell("RA_FILIAL"):GetText(), nStartUnN, nUnNLength) }
				EndIf
	
				If lEmpFil
					DEFINE BREAK oBreakEFil OF oReport   WHEN  { || Substr(oSectFunc:Cell("RA_FILIAL"):GetText(), nStartEmp, nEmpLength) }
				EndIf
			Else
				DEFINE BREAK oBreakEmp OF oReport WHEN  { || "" }
			EndIf
		EndIf 
		
	EndIf
	DEFINE FUNCTION NAME "CTOTREFERP" FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99"         	//"Ref." 
	DEFINE FUNCTION NAME "CTOTVALORP" FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"   	//"Valor"
	DEFINE FUNCTION NAME "CTOTREFERD" FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99" 			//"Ref."
	DEFINE FUNCTION NAME "CTOTVALORD" FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"  	//"Valor"
	DEFINE FUNCTION NAME "CLIQDESC"   FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:" 
	DEFINE FUNCTION NAME "CLIQVALOR"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("CTOTVALORP"):GetLastValue() - oSectLanc:GetFunction("CTOTVALORD"):GetLastValue()) } 	//"Liquido:" 

	oBreakCc:OnBreak({|x,y|cTitCC:=OemToAnsi(STR0042)+" "+x})	//"Total C.Custo"
   	oBreakCc:SetTotalText({||cTitCC})
   	oBreakCc:SetTotalInLine(.F.)   
   	
	
	If nAnaSin == 1 

		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() + " " + oSectLanc:Cell("DESCP"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERP"):GetValue(.T.)}	BREAK oBreakCc TITLE OemToAnsi(STR0043) PICTURE "@E 999,999.99"			NO END SECTION	NO END REPORT	//"Proventos"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText()} CONTENT {|| oSectLanc:Cell("VALORP"):GetValue(.T.)} BREAK oBreakCc TITLE OemToAnsi(STR0030) PICTURE "@E 999,999,999.99"	NO END SECTION	NO END REPORT	//"Valor"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() + " " + oSectLanc:Cell("DESCD"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERD"):GetValue(.T.)}	BREAK oBreakCc TITLE OemToAnsi(STR0044) PICTURE "@E 999,999.99"			NO END SECTION	NO END REPORT	//"Descontos"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText()} CONTENT {|| oSectLanc:Cell("VALORD"):GetValue(.T.)}	BREAK oBreakCc TITLE OemToAnsi(STR0030) PICTURE "@E 999,999,999.99"	NO END SECTION	NO END REPORT	//"Valor"
		
		If lImpBase		
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)} BREAK oBreakCc TITLE OemToAnsi(STR0045) PICTURE "@E 999,999,999.99"	NO END SECTION	NO END REPORT	//"Bases"
		EndIf
	EndIf
EndIf
            

If nOrdem == 1 .Or. nOrdem == 2
   	DEFINE BREAK oBreakFil OF oReport WHEN  oSectFunc:Cell("RA_FILIAL")

	If lCorpManage
		If lUniNeg               
			If nAnaSin == 1 .And. !lSint	//AnalÌtico
				DEFINE BREAK oBreakUnN OF oReport  WHEN  { || Substr((cAliasFun)->RA_FILIAL, nStartUnN, nUnNLength) }   
			Else // SintÈtico
				DEFINE BREAK oBreakUnN OF oReport   ;
					WHEN { || Substr(oSectFunc:Cell("RA_FILIAL"):GetText(), nStartEmp, nEmpLength) + Substr(oSectFunc:Cell("RA_FILIAL"):GetText(), nStartUnN, nUnNLength) }  
			Endif
		EndIf		

		If lEmpFil   
			If nAnaSin == 1 .And. !lSint	//AnalÌtico
				DEFINE BREAK oBreakEFil OF oReport  WHEN  { || Substr((cAliasFun)->RA_FILIAL, nStartEmp, nEmpLength) }
			Else //SintÈtico
				DEFINE BREAK oBreakEFil OF oReport   WHEN { || Substr(oSectFunc:Cell("RA_FILIAL"):GetText(), nStartEmp, nEmpLength) }  		
			Endif
		EndIf
	Else
		DEFINE BREAK oBreakEmp OF oReport WHEN  { || "" }
	EndIf
EndIf   

If lImpFil .Or. !lPrinOn
   
   	DEFINE FUNCTION NAME "FTOTREFERP" FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99"        	//"Ref."
	DEFINE FUNCTION NAME "FTOTVALORP" FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	//"Valor"
	DEFINE FUNCTION NAME "FTOTREFERD" FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99"  		//"Ref."
	DEFINE FUNCTION NAME "FTOTVALORD" FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"  	//"Valor"
	DEFINE FUNCTION NAME "FLIQDESC"   FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:"
	DEFINE FUNCTION NAME "FLIQVALOR"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("FTOTVALORP"):GetLastValue() - oSectLanc:GetFunction("FTOTVALORD"):GetLastValue()) } 	//"Liquido:"

	If lImpFil
		oBreakFil:OnBreak({|x,y| cTitFil := OemToAnsi(STR0038) + " " + x, oReport:ThinLine()})	//"Total Filial"
		oBreakFil:SetTotalText({||cTitFil})
		oBreakFil:SetTotalInLine(.F.)
		oBreakFil:lPageBreak := lBrkPagFil
	EndIf
	
	If lCorpManage .AND. lImpEmp

		If lUniNeg
			DEFINE FUNCTION NAME "FTUNNREFP"  FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99"        	//"Ref."
			DEFINE FUNCTION NAME "FTUNNVALP"  FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	//"Valor"
			DEFINE FUNCTION NAME "FTUNNREFD"  FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99"  		//"Ref."
			DEFINE FUNCTION NAME "FTUNNVALD"  FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"  	//"Valor"
			DEFINE FUNCTION NAME "FLUNNDESCB" FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:"
			DEFINE FUNCTION NAME "FLUNNVALB"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("FTUNNVALP"):GetLastValue() - oSectLanc:GetFunction("FTUNNVALD"):GetLastValue()) } 	//"Liquido:"

			oBreakUnN:OnBreak({ |x, y| cTitUnN := OemToAnsi(STR0059) + " " + x, oReport:ThinLine()})	//"Total Unidade de Negocios:"
			oBreakUnN:SetTotalText({ || cTitUnN })
			oBreakUnN:SetTotalInLine(.F.)
		EndIf   	 

		If lEmpFil
			DEFINE FUNCTION NAME "FTEFLREFP"  FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99"        	//"Ref."
			DEFINE FUNCTION NAME "FTEFLVALP"  FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	//"Valor"
			DEFINE FUNCTION NAME "FTEFLREFD"  FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99"  		//"Ref."
			DEFINE FUNCTION NAME "FTEFLVALD"  FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99" 	//"Valor"
			DEFINE FUNCTION NAME "FLEFLDESCB" FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:"
			DEFINE FUNCTION NAME "FLEFLVALB"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("FTEFLVALP"):GetLastValue() - oSectLanc:GetFunction("FTEFLVALD"):GetLastValue()) } 	//"Liquido:"

			oBreakEFil:OnBreak({ |x,y| cTitEFil := OemToAnsi(STR0060) + " " + x, oReport:ThinLine()})	//"Total Empresa"
			oBreakEFil:SetTotalText({ || cTitEFil })
			oBreakEFil:SetTotalInLine(.F.)
		EndIf
	ElseIf !lCorpManage .And. lImpEmp
		DEFINE FUNCTION NAME "FTEFLREFP"  FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakEmp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99"        	//"Ref."
		DEFINE FUNCTION NAME "FTEFLVALP"  FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakEmp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	//"Valor"
		DEFINE FUNCTION NAME "FTEFLREFD"  FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakEmp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99"  		//"Ref."
		DEFINE FUNCTION NAME "FTEFLVALD"  FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakEmp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99" 	//"Valor"
		DEFINE FUNCTION NAME "FLEFLDESCB" FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakEmp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:"
		DEFINE FUNCTION NAME "FLEFLVALB"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakEmp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("FTEFLVALP"):GetLastValue() - oSectLanc:GetFunction("FTEFLVALD"):GetLastValue()) } 	//"Liquido:"

		oBreakEmp:OnBreak({ |x,y| cTitEFil := OemToAnsi(STR0060) + " " + x, oReport:ThinLine()})	//"Total Empresa"
		oBreakEmp:SetTotalText({ || cTitEFil })
		oBreakEmp:SetTotalInLine(.F.)
	EndIf
	
	//Imprime a Collection apenas se solicitado Total por Filial
	If lImpFil
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() + " " + oSectLanc:Cell("DESCP"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERP"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0043) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Proventos"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() } CONTENT {|| oSectLanc:Cell("VALORP"):GetValue(.T.)} BREAK oBreakFil TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() + " " + oSectLanc:Cell("DESCD"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERD"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0044) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Descontos"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() } CONTENT {|| oSectLanc:Cell("VALORD"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
		
		If lImpBase
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)} BREAK oBreakFil TITLE OemToAnsi(STR0045) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Bases"
		EndIf
	EndIf
	
	If lCorpManage
		//Imprime a Collection apenas se solicitado Total por Unidade de Negocio
		If lImpUni .And. lUniNeg
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() + " " + oSectLanc:Cell("DESCP"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERP"):GetValue(.T.)}	BREAK oBreakUnN TITLE OemToAnsi(STR0043) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Proventos"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() } CONTENT {|| oSectLanc:Cell("VALORP"):GetValue(.T.)} BREAK oBreakUnN TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() + " " + oSectLanc:Cell("DESCD"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERD"):GetValue(.T.)}	BREAK oBreakUnN TITLE OemToAnsi(STR0044) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Descontos"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() } CONTENT {|| oSectLanc:Cell("VALORD"):GetValue(.T.)}	BREAK oBreakUnN TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
			
			If lImpBase
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)} BREAK oBreakUnN TITLE OemToAnsi(STR0045) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Bases"
			EndIf		
		EndIf
		
		//Imprime a Collection apenas se solicitado Total por Empresa
		If lImpEmp .And. lEmpFil
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() + " " + oSectLanc:Cell("DESCP"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERP"):GetValue(.T.)}	BREAK oBreakEFil TITLE OemToAnsi(STR0043) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Proventos"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() } CONTENT {|| oSectLanc:Cell("VALORP"):GetValue(.T.)} BREAK oBreakEFil TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() + " " + oSectLanc:Cell("DESCD"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERD"):GetValue(.T.)}	BREAK oBreakEFil TITLE OemToAnsi(STR0044) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Descontos"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() } CONTENT {|| oSectLanc:Cell("VALORD"):GetValue(.T.)}	BREAK oBreakEFil TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
					
			If lImpBase
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)} BREAK oBreakEFil TITLE OemToAnsi(STR0045) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Bases"
			EndIf
		EndIf
	Else
		If lImpEmp
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDP"):GetText() + " " + oSectLanc:Cell("DESCP"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERP"):GetValue(.T.)}	BREAK oBreakEmp TITLE OemToAnsi(STR0043) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Proventos"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDP"):GetText() } CONTENT {|| oSectLanc:Cell("VALORP"):GetValue(.T.)} BREAK oBreakEmp TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDD"):GetText() + " " + oSectLanc:Cell("DESCD"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERD"):GetValue(.T.)}	BREAK oBreakEmp TITLE OemToAnsi(STR0044) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Descontos"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDD"):GetText() } CONTENT {|| oSectLanc:Cell("VALORD"):GetValue(.T.)}	BREAK oBreakEmp TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
					
			If lImpBase
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)} BREAK oBreakEmp TITLE OemToAnsi(STR0045) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Bases"
			EndIf
		EndIf
	EndIf
Endif

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

If nTpContr == 3
	cTpcQuery	:= "'1', '2'"
Else	
	cTpcQuery	:= "'" + cValToChar(nTpContr) + "'"
EndIf

//ALTERA O TITULO DO RELATORIO
oReport:SetTitle(cTitulo)

MakeSqlExpr(cPerg)    

//Permiss„o Filial
cFiltro += fAjustFil() //Retorna no filtro somente as filiais que o usu·rio tem acesso

If nAnaSin == 1		//Analitico
	If nOrdem == 1
		cOrdemFun := "%RA_FILIAL,RA_MAT%"
		cOrdemLan := "%RA_FILIAL,RA_MAT,PD,SEQ%"
	ElseIf nOrdem == 2
		cOrdemFun := "%RA_FILIAL,RA_NOME,RA_MAT%"
		cOrdemLan := "%RA_FILIAL,RA_NOME,RA_MAT,PD,SEQ%"
	ElseIf nOrdem == 3
		cOrdemFun := "%RA_FILIAL,RA_CC,RA_MAT%"    
		cOrdemLan := "%RA_FILIAL,RA_CC,RA_MAT,PD,SEQ%" 
	ElseIf nOrdem == 4
		cOrdemFun := "%RA_FILIAL,RA_CC,RA_NOME,RA_MAT%"  
		cOrdemLan := "%RA_FILIAL,RA_CC,RA_NOME,RA_MAT,PD,SEQ%" 
	ElseIf nOrdem == 5
		cOrdemFun := "%FILIAL,CCUSTO,RA_MAT%"    
		cOrdemLan := "%FILIAL,CCUSTO,RA_MAT,PD,SEQ%" 
	ElseIf nOrdem == 6
		cOrdemFun := "%FILIAL,CCUSTO,RA_NOME,RA_MAT%"  
		cOrdemLan := "%FILIAL,CCUSTO,RA_NOME,RA_MAT,PD,SEQ%" 
	ElseIf nOrdem == 7
		cOrdemFun := "%RA_FILIAL,RA_DEPTO,RA_MAT%"    
		cOrdemLan := "%RA_FILIAL,RA_DEPTO,RA_MAT,PD,SEQ%"    
	ElseIf nOrdem == 8
		cOrdemFun := "%RA_FILIAL,RA_DEPTO,RA_NOME,RA_MAT%"  
		cOrdemLan := "%RA_FILIAL,RA_DEPTO,RA_NOME,RA_MAT,PD,SEQ%" 
	Endif
EndIf

cSitQuery	:= "%" + cSitQuery + "%"
cCatQuery	:= "%" + cCatQuery + "%"
cTpcQuery	:= "%" + cTpcQuery + "%"

//CENTRO DE CUSTO
If !Empty(mv_par07)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par07
EndIf

//DEPARTAMENTO
If !Empty(mv_par08)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par08
EndIf

//MATRICULA   
If !Empty(mv_par09)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro	+= mv_par09
EndIf

//NOME   
If !Empty(mv_par10)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par10
EndIf

If !Empty(cFiltro)
	cFiltroC	+= Iif(!Empty(cFiltroC)," AND "+cFiltro,cFiltro)
	cFiltroD	+= Iif(!Empty(cFiltroD)," AND "+cFiltro,cFiltro)
	cFiltro		:= Iif(!Empty(cFiltro ),cFiltro,"")
EndIf

SRA->( dbCloseArea() ) //FECHA O SRA PARA USO DA QUERY

If nAnaSin == 1 	//Analitico

	If !( TcGetDb() == "INFORMIX" )
		cCoalese := "% AND COALESCE(SQB.D_E_L_E_T_,'') <> '*'"
		cCoalese += "%"
	Else
		cCoalese := "% AND DECODE(SQB.D_E_L_E_T_,NULL,'','') <> '*'"
		cCoalese += "%"
	EndIf

	If nOrdem == 3 .Or. nOrdem == 5 .Or. nOrdem == 7 
		cTitulo += " + " + OemToAnsi(STR0002)	//MatrÌcula
	ElseIf nOrdem == 4 .Or. nOrdem == 6 
		cTitulo += " + " + OemToAnsi(STR0003)	//Nome
	EndIf
	
	Sx2ChkModo( "CTT", NIL, .F., @cMod1, NIL )
	cJoin := " INNER JOIN " + RetSqlName("CTT") + " CTT ON SRA.RA_CC = CTT.CTT_CUSTO AND " + fGR106join("SRA", "CTT")

	If !(nOrdem == 1 .Or. nOrdem == 2)
		cCpoCcRc		:= " SRA.RA_CC, SRC.RC_CC CCUSTO "
		cCpoCcRd		:= " SRA.RA_CC, SRD.RD_CC CCUSTO "
	EndIf
	
	If nOrdem == 1 .Or. nOrdem == 2
		cCpoAdicLan	:= " CTT.CTT_DESC01 "
		cNotDel		:= "% AND CTT.D_E_L_E_T_= ' ' %"
		BEGIN REPORT QUERY oSectFunc
	ElseIf nOrdem == 3 .Or. nOrdem == 4
		cCpoAdicLan	:= " CTT.CTT_FILIAL, CTT.CTT_CUSTO, CTT.CTT_DESC01 "
		cNotDel		:= "% AND CTT.D_E_L_E_T_= ' ' %"
		BEGIN REPORT QUERY oSectCttc
	ElseIf nOrdem == 5 .Or. nOrdem == 6
		cCpoAdicLan	:= " CTT.CTT_FILIAL, CTT.CTT_CUSTO, CTT.CTT_DESC01 "  
		cJoinC		:= " INNER JOIN " + RetSqlName("CTT") + " CTT ON SRC.RC_CC = CTT.CTT_CUSTO AND " + fGR106join("SRC", "CTT") 
		cJoinD 	:= " INNER JOIN " + RetSqlName("CTT") + " CTT ON SRD.RD_CC = CTT.CTT_CUSTO AND " + fGR106join("SRD", "CTT") 		
		cJoin 		:= "%%"
		cNotDel	:= "% AND CTT.D_E_L_E_T_= ' ' %"
		BEGIN REPORT QUERY oSectCttc
	ElseIf nOrdem == 7 .Or. nOrdem == 8
		cCpoAdicLan	:= " SQB.QB_FILIAL, SQB.QB_DEPTO, CTT.CTT_DESC01 "
		cNotDel		:= "% AND CTT.D_E_L_E_T_= ' ' %"
		 
		BEGIN REPORT QUERY oSectDept
	EndIf
	
	If nOrdem == 7 .Or. nOrdem == 8
		cJoinSQB := " INNER JOIN " + RetSqlName("SQB") + " SQB ON SRA.RA_DEPTO = SQB.QB_DEPTO AND " + fGR106join("SRA", "SQB")
	Else
		cJoinSQB := " LEFT JOIN " + RetSqlName("SQB") + " SQB ON SRA.RA_DEPTO = SQB.QB_DEPTO AND " + fGR106join("SRA", "SQB") 
	EndIf
	
	cJoinC		:= Iif(Empty(cJoinC),cJoin,cJoinC)
	cJoinD		:= Iif(Empty(cJoinD),cJoin,cJoinD) 
	cJoinD		:= strTran(cJoinD, "SRC", "SRD")
	cJoinD		:= strTran(cJoinD, "RC_", "RD_")

	cFiltroC	:= Iif(Empty(cFiltroC),"%%","% AND "+cFiltroC+"%")
	cFiltroD	:= Iif(Empty(cFiltroD),"%%","% AND "+cFiltroD+"%")
	cFiltro		:= Iif(Empty(cFiltro ),"%%","% AND "+cFiltro +"%")

	cCpoCcRc	:= If( !Empty(cCpoCcRc), "% , " + cCpoCcRc + ", ", "% , " ) + cCpoAdicLan + " %"
	cCpoCcRd	:= If( !Empty(cCpoCcRd), "% , " + cCpoCcRd + ", ", "% , " ) + cCpoAdicLan + " %"

	If lDepSf
		cDepenContr	:= "% SRA.RA_DEPIR, SRA.RA_DEPSF %"
	Else
		cDepenContr	:= "% SRA.RA_DEPIR %"
	EndIf

	If cPaisLoc == "COL"
			cCpoAdicEsp := "% SRA.RA_RG,SRA.RA_TIPOSAL, SRA.RA_MOEDAPG,SRA.RA_REMVAR,SRA.RA_GROSSUP,SRA.RA_SALEST,RA_TIPOPRC %"
	Else
		cCpoAdicEsp := "%SRA.RA_FILIAL as CpoVisual%" // SE NAO FOR UM DOS PAISES MENCIONADOS ATRIBUI O CAMPO RA_FILIAL COM UM ALIAS PARA NAO FICAR VAZIO	
	Endif
	
	cJoin1 := "% " + cJoinEsp + cJoinSQB + cJoinC + "%"
	cJoin2 := "% " + cJoinEsp + cJoinSQB + cJoinD + "%"

	//QUERY cAliasFun
		BeginSql alias cAliasFun

			SELECT SRA.RA_FILIAL,		SRA.RA_MAT,			SRA.RA_NOME,
					SRA.RA_PERCIR,		SRA.RA_NITARL,		SRA.RA_CODRPAT, SRA.RA_CODAFP,
					SRA.RA_CXCOMP,     SRA.RA_TPCIC,       SRA.RA_FUNCESA,	SRA.RA_BCDEPSA,
					SRA.RA_BCDPFGT,     SRA.RA_CARGO,
					SRA.RA_DEPTO,		SRA.RA_HRSMES,		SRA.RA_SALARIO,	SRA.RA_SITFOLH,  
					SRA.RA_CATFUNC,		SRA.RA_PERCADT,		SRA.RA_ADMISSA,	%exp:cDepenContr%,	
					SRA.RA_CIC,			SRA.RA_RG, 		%exp:cCpoAdicEsp%,
					SRC.RC_FILIAL FILIAL	%exp:cCpoCcRc%, SQB.QB_DESCRIC, SRA.RA_TPCONTR
			FROM %table:SRA% SRA    

			INNER JOIN  %table:SRC% SRC 
			ON 	    SRA.RA_FILIAL = SRC.RC_FILIAL	AND
					SRA.RA_MAT    = SRC.RC_MAT	    
			%exp:cJoin1% 
			WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
			   		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
			   		SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
			   		SRC.RC_PROCES  BETWEEN   %exp:Upper(cProcesso)%  AND	%exp:Upper(cProcessoa)% AND
			   		SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND  
			   		SRC.RC_ROTEIR  =   %exp:Upper(cRoteiro)%   AND	
			   		SRC.RC_SEMANA  =   %exp:Upper(cPagamento)% AND
					SRA.%notDel% %exp:cFiltroC% AND SRC.%notDel% %exp:cNotDel% AND SRC.%notDel% %exp:cCoalese% 
			UNION

			SELECT SRA.RA_FILIAL,			SRA.RA_MAT,			SRA.RA_NOME,            
					SRA.RA_PERCIR,	   		SRA.RA_NITARL,		SRA.RA_CODRPAT, SRA.RA_CODAFP,
					SRA.RA_CXCOMP,      	SRA.RA_TPCIC,       SRA.RA_FUNCESA,	SRA.RA_BCDEPSA,
					SRA.RA_BCDPFGT,     	SRA.RA_CARGO,
					SRA.RA_DEPTO,			SRA.RA_HRSMES,		SRA.RA_SALARIO,	SRA.RA_SITFOLH,  
					SRA.RA_CATFUNC,			SRA.RA_PERCADT,		SRA.RA_ADMISSA,	%exp:cDepenContr%,		
					SRA.RA_CIC,				SRA.RA_RG, 			%exp:cCpoAdicEsp%, 
					SRD.RD_FILIAL FILIAL	%exp:cCpoCcRd%,		SQB.QB_DESCRIC,	SRA.RA_TPCONTR
			FROM %table:SRA% SRA    

			INNER JOIN  %table:SRD% SRD
			ON 	    SRA.RA_FILIAL = SRD.RD_FILIAL	AND
					SRA.RA_MAT    = SRD.RD_MAT 		
			%exp:cJoin2%
			WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
			   		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
			   		SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
			   		SRD.RD_PROCES  BETWEEN   %exp:Upper(cProcesso)%  AND	%exp:Upper(cProcessoa)% AND
			   		SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND  
					SRD.RD_ROTEIR  =   %exp:Upper(cRoteiro)%   AND	
			   		SRD.RD_SEMANA  =   %exp:Upper(cPagamento)% AND
					SRA.%notDel% %exp:cFiltroD% AND SRD.%notDel% %exp:cNotDel% AND SRD.%notDel% %exp:cCoalese%
			ORDER BY %exp:cOrdemFun%

		EndSql
	//END QUERY cAliasFun

	If nOrdem == 1 .Or. nOrdem == 2
		END REPORT QUERY oSectFunc
	ElseIf nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5 .Or. nOrdem == 6 
		END REPORT QUERY oSectCttc
	ElseIf nOrdem == 7 .Or. nOrdem == 8
		END REPORT QUERY oSectDept  
	EndIf

	cCpoAdicLan := "% , " +  cCpoAdicLan + " %"
	cCpoAdicEsp := "%SRA.RA_FILIAL as CpoVisual%" // SE NAO FOR UM DOS PAISES MENCIONADOS ATRIBUI O CAMPO RA_FILIAL COM UM ALIAS PARA NAO FICAR VAZIO
	cJoinEsp := ""

	cJoin3 := "% " + FWJoinFilial("SRV", "SRA") + cJoinEsp + cJoinSQB + cJoinC + "%"
	cJoin4 := "% " + FWJoinFilial("SRV", "SRA") + cJoinEsp + cJoinSQB + cJoinD + "%"
	

	BEGIN REPORT QUERY oSectLanc
		BeginSql alias cAliasQry

			SELECT	SRA.RA_FILIAL,          SRA.RA_MAT,           SRA.RA_CC,              SRA.RA_NOME,
					SRA.RA_PERCIR,			SRA.RA_NITARL,		  SRA.RA_CODRPAT, 		  SRA.RA_CODAFP,
					SRA.RA_CXCOMP,      	SRA.RA_TPCIC,         SRA.RA_FUNCESA,		  SRA.RA_BCDEPSA,
					SRA.RA_BCDPFGT,     	SRA.RA_CARGO,
					SRA.RA_DEPTO,           SRA.RA_HRSMES,        SRA.RA_SALARIO,         SRA.RA_SITFOLH,  
					SRA.RA_CATFUNC,			SRA.RA_PERCADT,       %exp:cCpoAdicEsp%,	
					SRC.RC_FILIAL FILIAL,   SRC.RC_MAT MAT,       SRC.RC_CC CCUSTO,       SRC.RC_PD PD,   
					SRC.RC_TIPO1 TIPO1,     SRC.RC_QTDSEM QTDSEM, SRC.RC_HORINFO HORINFO, SRC.RC_HORAS HORAS, 
					SRC.RC_VALINFO VALINFO, SRC.RC_VALOR VALOR,   SRC.RC_VNAOAPL VNAOAPL, SRC.RC_DATA DATPGT, 
					SRC.RC_DTREF DTREF,     SRC.RC_SEMANA SEMANA, SRC.RC_PARCELA PARCELA, SRC.RC_TIPO2 TIPO2, 
					SRC.RC_SEQ SEQ,         SRC.RC_PROCES PROCES, SRC.RC_PERIODO PERIODO, SRC.RC_POSTO POSTO, 
					SRC.RC_NUMID NUMID,     SRC.RC_ROTEIR ROTEIR, SRV.RV_TIPOCOD,         SRV.RV_DESC, SRV.RV_IMPRIPD
					%exp:cCpoAdicLan%, SRA.RA_TPCONTR
			FROM %table:SRA% SRA    INNER JOIN      %table:SRC% SRC 
			ON 	    SRA.RA_FILIAL = SRC.RC_FILIAL	AND
					SRA.RA_MAT    = SRC.RC_MAT	
			INNER JOIN 	%table:SRV% SRV
			ON		SRV.RV_COD    = SRC.RC_PD AND				  
			
			%exp:cJoin3%
			WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
			   		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
			   		SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
			   		SRC.RC_PROCES  BETWEEN   %exp:Upper(cProcesso)%  AND	%exp:Upper(cProcessoa)% AND
			   		SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND  
			   		SRC.RC_ROTEIR  =   %exp:Upper(cRoteiro)%   AND	
			   		SRC.RC_SEMANA  =   %exp:Upper(cPagamento)% AND
					SRA.%notDel% %exp:cFiltroC% AND SRV.%notDel% %exp:cNotDel% AND SRC.%notDel% %exp:cCoalese%   
			UNION

			SELECT SRA.RA_FILIAL,          SRA.RA_MAT,           SRA.RA_CC,              SRA.RA_NOME,
					SRA.RA_PERCIR,		    SRA.RA_NITARL,			  SRA.RA_CODRPAT, 		  SRA.RA_CODAFP,
					SRA.RA_CXCOMP,          SRA.RA_TPCIC,         SRA.RA_FUNCESA,		  SRA.RA_BCDEPSA,
					SRA.RA_BCDPFGT,         SRA.RA_CARGO,
					SRA.RA_DEPTO,           SRA.RA_HRSMES,        SRA.RA_SALARIO,         SRA.RA_SITFOLH,
					SRA.RA_CATFUNC,			SRA.RA_PERCADT,	      %exp:cCpoAdicEsp%,
					SRD.RD_FILIAL FILIAL,   SRD.RD_MAT MAT,       SRD.RD_CC CCUSTO,       SRD.RD_PD PD,         
					SRD.RD_TIPO1 TIPO1,     SRD.RD_QTDSEM QTDSEM, SRD.RD_HORINFO HORINFO, SRD.RD_HORAS HORAS,   
					SRD.RD_VALINFO VALINFO, SRD.RD_VALOR VALOR,   SRD.RD_VNAOAPL VNAOAPL, SRD.RD_DATPGT DATPGT, 
					SRD.RD_DTREF DTREF,     SRD.RD_SEMANA SEMANA, 0 PARCELA,              SRD.RD_TIPO2 TIPO2,   
					SRD.RD_SEQ SEQ,         SRD.RD_PROCES PROCES, SRD.RD_PERIODO PERIODO, SRD.RD_POSTO POSTO,   
					SRD.RD_NUMID NUMID,     SRD.RD_ROTEIR ROTEIR, SRV.RV_TIPOCOD,         SRV.RV_DESC, SRV.RV_IMPRIPD 
					%exp:cCpoAdicLan%, SRA.RA_TPCONTR
			FROM %table:SRA% SRA    INNER JOIN      %table:SRD% SRD 
			ON 	    SRA.RA_FILIAL = SRD.RD_FILIAL	AND
					SRA.RA_MAT    = SRD.RD_MAT	
			INNER JOIN 	%table:SRV% SRV
			ON		SRV.RV_COD    = SRD.RD_PD AND 		   

			%exp:cJoin4%
			WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
			   		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
			   		SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
			   		SRD.RD_PROCES  BETWEEN   %exp:Upper(cProcesso)%  AND	%exp:Upper(cProcessoa)% AND
			   		SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND  
			   		SRD.RD_ROTEIR  =   %exp:Upper(cRoteiro)%   AND	
			   		SRD.RD_SEMANA  =   %exp:Upper(cPagamento)% AND
					SRA.%notDel% %exp:cFiltroD% AND SRV.%notDel% %exp:cNotDel% AND SRD.%notDel% %exp:cCoalese%
			ORDER BY %exp:cOrdemLan%                                                    					
		ENDSQL

	END REPORT QUERY oSectLanc
	If nOrdem == 1 .Or. nOrdem == 2
		//MATRICULA X LANCAMENTOS
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL+(cAliasQry)->MAT == cParam},{||(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_MAT})
	ElseIf nOrdem == 3 .Or. nOrdem == 4 
		If cMod1 == "E" 
			//C.CUSTO X MATRICULA
			oSectFunc:SetParentFilter({|cParam|(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_CC==cParam},{||(cAliasQry)->CTT_FILIAL+(cAliasQry)->CTT_CUSTO})
		Else
			//C.CUSTO X MATRICULA
			oSectFunc:SetParentFilter({|cParam|(cAliasFun)->RA_CC==cParam},{||(cAliasQry)->CTT_CUSTO})
		EndIf                                                                                         
		//MATRICULA X LANCAMENTOS
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL+(cAliasQry)->MAT == cParam},{||(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_MAT})	
	ElseIf nOrdem == 5 .Or. nOrdem == 6
		If cMod1 == "E" 
			//C.CUSTO X MATRICULA
			oSectFunc:SetParentFilter({|cParam|(cAliasFun)->FILIAL+(cAliasFun)->CCUSTO==cParam},{||(cAliasQry)->CTT_FILIAL+(cAliasQry)->CTT_CUSTO})
		Else
			//C.CUSTO X MATRICULA
			oSectFunc:SetParentFilter({|cParam|(cAliasFun)->CCUSTO==cParam},{||(cAliasQry)->CTT_CUSTO})
		EndIf                                                                                          
		//MATRICULA X LANCAMENTOS
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL+(cAliasQry)->MAT == cParam},{||(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_MAT})		
	ElseIf nOrdem == 7 .Or. nOrdem == 8
		Sx2ChkModo( "SQB", NIL, .F., @cMod1, NIL )
		If cMod1 == "E" 
			//DEPTO X MATRICULA
			oSectFunc:SetParentFilter({|cParam|(cAliasFun)->FILIAL+(cAliasFun)->RA_DEPTO==cParam},{||(cAliasQry)->QB_FILIAL+(cAliasQry)->QB_DEPTO})
		Else		
			//DEPTO X MATRICULA
			oSectFunc:SetParentFilter({|cParam|(cAliasFun)->FILIAL+(cAliasFun)->RA_DEPTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->QB_DEPTO})
		EndIf
		//MATRICULA X LANCAMENTOS
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL+(cAliasQry)->MAT==cParam},{||(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_MAT})			
	EndIf

Else	//SINTETICO                
	cCpoDelim	:= "%RA_FILIAL"
	cCpoDelimC	:= Iif(!Empty(cCCpoQuebra),							;
						cCpoDelim+","+AllTrim(cCCpoQuebra)+"%",		;
						Iif(!Empty(cCpoQuebra ),					;
							cCpoDelim+","+AllTrim(cCpoQuebra)+"%",	;
							cCpoDelim+"%"							;
							)										;
						)
						
	cCpoDelimD	:= Iif(!Empty(cDCpoQuebra),							;
						cCpoDelim+","+AllTrim(cDCpoQuebra)+"%",		;
						Iif(!Empty(cCpoQuebra ),					;
							cCpoDelim+","+AllTrim(cCpoQuebra)+"%",	;
							cCpoDelim+"%"							;
							)										;
						)
						
	cCpoDelim	+= Iif(!Empty(cCpoQuebra ),","+AllTrim(cCpoQuebra)+"%","%")
	cCpoView	+= "%"
	cCpoViewG	+= "%"
	cCpoAls	+= "%"
	
	cFiltro	:= Iif(Empty(cFiltro ),"%%","% AND "+cFiltro +"%") 
	cCpoAlsC	:= Iif(Empty(cCpoAlsC),cCpoAls,cCpoAlsC+"%")
	cCpoAlsD	:= Iif(Empty(cCpoAlsD),cCpoAls,cCpoAlsD+"%")

	cJoinC		:= "% AND SRA.RA_MAT = SRC.RC_MAT " +;
	         " INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND " + fGR106join("CTT", "SRC") + " AND CTT.CTT_CUSTO = SRC.RC_CC %" 
	cJoinD		:= "% AND SRA.RA_MAT = SRD.RD_MAT" +;
	         " INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND " + fGR106join("CTT", "SRD") + " AND CTT.CTT_CUSTO = SRD.RD_CC %" 

	Sx2ChkModo( "CTT", NIL, .F., @cMod1, NIL )

	If nOrdem == 1 .Or. nOrdem == 2
		cJoinView	:= "%%"
		cCpoAdView	:= "%%"
		cExtraC		:= "%%"                
		cExtraD		:= "%%"
		cGroupEC	:= "%%"               
		cGroupED	:= "%%"  
		BEGIN REPORT QUERY oSectFunc
	ElseIf nOrdem == 3 .Or. nOrdem == 4
		cExtraC		:= "% , SRA.RA_CC RCCC %"                
		cExtraD		:= "% , SRA.RA_CC RDCC %"
		cGroupEC	:= "% , RA_CC %"                
		cGroupED	:= "% , RA_CC %"
		
		cJoinAux := FWJoinFilial("CTT", "SRC")
    	cJoinAux := StrTran(cJoinAux,"CTT.CTT_FILIAL","CTT_FILIAL")
    	cJoinAux := StrTran(cJoinAux,"SRC.RC_FILIAL","tView.FILIAL")		
		                
		cJoinView	:= "% INNER JOIN " + RetSqlName("CTT") + " CTTA ON CTTA.CTT_CUSTO = tView.RACC AND (" + cJoinAux + ") WHERE CTTA.D_E_L_E_T_ = ' ' %"
		cCpoAdView	:= "% CTTA.CTT_DESC01, %"  
		BEGIN REPORT QUERY oSectCttc
	ElseIf nOrdem == 5 .Or. nOrdem == 6                      
		cExtraC		:= "% , SRC.RC_CC RCCC %"                
		cExtraD		:= "% , SRD.RD_CC RDCC %"  
		cGroupEC	:= "% , RC_CC %"                
		cGroupED	:= "% , RD_CC %"
		
		cJoinAux := FWJoinFilial("CTT", "SRC")
    	cJoinAux := StrTran(cJoinAux,"CTT.CTT_FILIAL","CTT_FILIAL")
    	cJoinAux := StrTran(cJoinAux,"SRC.RC_FILIAL","tView.FILIAL")		
		                  
		If cMod1 == "E"
			cJoinView	:= "% INNER JOIN " + RetSqlName("CTT") + " CTTA ON CTTA.CTT_CUSTO = tView.RCDCC AND CTTA.CTT_FILIAL = tView.RAFILIAL WHERE CTTA.D_E_L_E_T_ = ' ' %"		
		Else		
			cJoinView	:= "% INNER JOIN " + RetSqlName("CTT") + " CTTA ON CTTA.CTT_CUSTO = tView.RCDCC AND (" + cJoinAux + ") WHERE CTTA.D_E_L_E_T_ = ' ' %"
		Endif
		cCpoAdView	:= "% CTTA.CTT_DESC01, tView.RCDCC, %"  
		BEGIN REPORT QUERY oSectCttc
	ElseIf nOrdem == 7 .Or. nOrdem == 8
		cJoinAux := FWJoinFilial("SQB", "SRC")
    	cJoinAux := StrTran(cJoinAux,"SQB.QB_FILIAL","QB_FILIAL")
    	cJoinAux := StrTran(cJoinAux,"SRC.RC_FILIAL","tView.FILIAL")
    	
		cJoinView	:= "% INNER JOIN " + RetSqlName("SQB") + " SQBA ON (" + cJoinAux + ") AND SQBA.QB_DEPTO = tView.RADEPTO %"
		cCpoAdView	:= "% SQBA.QB_DESCRIC, %"
		cExtraC		:= "%%"                
		cExtraD		:= "%%"
		cGroupEC	:= "%%"               
		cGroupED	:= "%%"   
		BEGIN REPORT QUERY oSectDept 
	EndIf
	
	cJoinAux := "% " + FWJoinFilial("SRV", "SRC") + StrTran(cJoinView,"%","") + " %"
    cJoinAux := StrTran(cJoinAux,"SRV.RV_FILIAL","RV_FILIAL")
    cJoinAux := StrTran(cJoinAux,"SRC.RC_FILIAL","tView.FILIAL")
   
   //BEGIN QUERY cAliasQry 
	BeginSql alias cAliasQry
	
		SELECT	tView.SALARIO, tView.PD,        tView.HORAS,  tView.VALOR,     tView.PROCES, 
				tView.PERIODO, tView.ROTEIR,    tView.FILIAL, SRVA.RV_TIPOCOD, %exp:cCpoAdView%
				SRVA.RV_DESC,  SRVA.RV_IMPRIPD, tView.%exp:cCpoView%             
		FROM
		(
			SELECT 	SUM(SRA.RA_SALARIO) SALARIO, SRC.RC_PD PD,         SUM(SRC.RC_HORAS) HORAS, 
					SUM(SRC.RC_VALOR) VALOR,     SRC.RC_PROCES PROCES, SRC.RC_PERIODO PERIODO,  
					SRC.RC_ROTEIR ROTEIR,        SRC.RC_FILIAL FILIAL	%exp:cExtraC%, 
					SRA.%exp:cCpoAlsC%
			FROM  %table:SRA% SRA	
			INNER JOIN %table:SRC% SRC 
			ON 		SRA.RA_FILIAL = SRC.RC_FILIAL %exp:cJoinC%
			WHERE 	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND 
					SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND 
					SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND 
			   		SRC.RC_PROCES  BETWEEN   %exp:Upper(cProcesso)%  AND 	%exp:Upper(cProcessoa)% AND
					SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND 
			   		SRC.RC_ROTEIR  =   %exp:Upper(cRoteiro)%   AND	
					SRC.RC_SEMANA =    %exp:Upper(cPagamento)% AND 
					SRA.%notDel% %exp:Upper(cFiltro)% AND SRC.%notDel% 
			GROUP BY RC_PROCES, RC_PERIODO, RC_ROTEIR, %exp:cCpoDelimC%, RC_PD, RC_FILIAL %exp:cGroupEC%
			
			UNION
			
			SELECT SUM(SRA.RA_SALARIO) SALARIO, SRD.RD_PD PD,         SUM(SRD.RD_HORAS) HORAS, 
					SUM(SRD.RD_VALOR) VALOR,     SRD.RD_PROCES PROCES, SRD.RD_PERIODO PERIODO,  
					SRD.RD_ROTEIR ROTEIR,        SRD.RD_FILIAL FILIAL	%exp:cExtraD%,
					SRA.%exp:cCpoAlsD%
			FROM  %table:SRA% SRA	
			INNER JOIN %table:SRD% SRD 
			ON 		SRA.RA_FILIAL = SRD.RD_FILIAL %exp:cJoinD%
			WHERE 	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND 
					SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND 
					SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND 
			   		SRD.RD_PROCES  BETWEEN   %exp:Upper(cProcesso)%  AND	%exp:Upper(cProcessoa)% AND
					SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND 
			   		SRD.RD_ROTEIR  =   %exp:Upper(cRoteiro)%   AND	
					SRD.RD_SEMANA =    %exp:Upper(cPagamento)% AND 
					SRA.%notDel% %exp:Upper(cFiltro)% AND SRD.%notDel% 
			GROUP BY RD_PROCES, RD_PERIODO, RD_ROTEIR, %exp:cCpoDelimD%, RD_PD, RD_FILIAL %exp:cGroupED%
		) tView
		INNER JOIN	%table:SRV% SRVA
		ON			SRVA.RV_COD = tView.PD AND %exp:cJoinAux%
		GROUP BY tView.SALARIO, tView.PD,        tView.HORAS,  tView.VALOR,     tView.PROCES, 
				tView.PERIODO, tView.ROTEIR,    tView.FILIAL, SRVA.RV_TIPOCOD, %exp:cCpoAdView%
				SRVA.RV_DESC,  SRVA.RV_IMPRIPD, tView.%exp:cCpoViewG%
		ORDER BY %exp:cCpoDelim%, PD 
    EndSql

    //END cAliasQry
    
	If nOrdem == 1 .Or. nOrdem == 2
		END REPORT QUERY oSectFunc
		oSectLanc:SetParentQuery()
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL == cParam},{||(cAliasQry)->RA_FILIAL})
	ElseIf nOrdem == 3 .Or. nOrdem == 4
		END REPORT QUERY oSectCttc
		oSectFunc:SetParentQuery()
		oSectLanc:SetParentQuery()
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL+(cAliasQry)->RA_CC == cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_CC})
	ElseIf nOrdem == 5 .Or. nOrdem == 6
		END REPORT QUERY oSectCttc
		oSectFunc:SetParentQuery()
		oSectLanc:SetParentQuery()
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL+(cAliasQry)->RCDCC == cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RCDCC})
	ElseIf nOrdem == 7 .Or. nOrdem == 8
		END REPORT QUERY oSectDept
		oSectFunc:SetParentQuery()
		oSectLanc:SetParentQuery()
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL+(cAliasQry)->RA_DEPTO == cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_DEPTO})

	EndIf
	cAliasFun	:= cAliasQry
	
/*
	//CONTAGEM DE FUNCIONARIOS
	fContFunc(cJoinC,cJoinD,cSitQuery,cCatQuery,cProcesso,cPeriodo,cRoteiro,cPagamento,cFiltro)
*/
EndIf

//SELECIONA TABELA DE FUNCIONARIOS
dbSelectArea("SM0")     
dbSelectArea(cAliasQry)
(cAliasQry)->(DbGoTop())

//DEFINE O TOTAL DA REGUA DA TELA DE PROCESSAMENTO DO RELATORIO
oReport:SetMeter(LastRec())        

oReport:OnPageBreak({||fGR106Header(oReport)}) //IMPRESSAO DO CABECALHO

//ALTERA O TITULO DO RELATORIO
oReport:SetTitle(cTitulo)

If nOrdem == 1 .Or. nOrdem == 2
	oSectFunc:Print()
ElseIf nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5 .Or. nOrdem == 6 
	If nAnaSin	== 1	//AnalÌtico
		oSectCttc:Print()
	Else				//SintÈtico
		oSectFunc:Print()
	EndIf
ElseIf nOrdem == 7 .Or. nOrdem == 8  
	If nAnaSin	== 1	//AnalÌtico
		oSectDept:Print()
	Else				//SintÈtico
		oSectFunc:Print()
	EndIf 
EndIf

If lDifLiq .AND. nAnaSin == 1	//AnalÌtico
	//IMPRIME AS DIFERENCAS DE LIQUIDOS
	f2ImprDifLiqU(oReport)
	
	//FINALIZA O RELATORIO PARA IMPRESSAO DAS DIFERENCAS DE LIQUIDOS
	oReport:Finish() 
	oReport:aBreak := {}
	oReport:aCollection := {}
	oReport:aFunction := {}                                         
EndIf

If nAnaSin == 1 .AND. (oReport:nMeter > 0) //Apenas imprimir linha quando h· dados no reltÛrio.
	oReport:ThinLine()
	oReport:SkipLine()
EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ fBuscaValSal  ≥ Autor ≥ Tania Bronzeri   ≥ Data ≥28/11/2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Encontra o salario a imprimir no relatorio                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Folha Mexico                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
static Function f2BuscaValSalA()
Local nValSal	:= 0

nValSal := fBuscaSal(dDataRef,,,.F.)
If nValSal ==0 
	If nAnaSin == 1
		nValSal := (cAliasQry)->RA_SALARIO
	ElseIf nAnaSin == 2
		nValSal := (cAliasQry)->SALARIO	
	EndIf
EndIf

Return nValSal

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ fImprimeLanca ≥ Autor ≥ Tania Bronzeri        ≥ Data ≥06/12/2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Imprime os lancamentos da Folha de Pagamento                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPER106                                                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fImprimeLanca(oSelf) 
Local aArea		:= GetArea()
Local aGPSAux	:= {}
Local cPDB		:= ""	//Horas / Dias / Valores
Local nMax		:= 0	//Controle maximo de verbas por tipo
Local nMaxP		:= 0
Local nMaxD		:= 0
Local nMaxB		:= 0
Local nCta		:= 0
Local nCtaB		:= 0
Local lImprLine 
Local lImpAux	:= .F.

If oSelf:cName == "FUNCIONARIO"
	oSelf:oReport:SkipLine()
	If oSelf:lVisible == .T.
		oSelf:oReport:FatLine()
	ElseIf lSint
		nTotFunc++
	Endif
	lPrinOn	:= .T. 
ElseIf oSelf:cName == "LANCAMENTO"
	If lPrinOn
	
		//Impreme verba de desoneraÁ„o
		If cFilAux <>  (cAliasFun)->RA_FILIAL .AND. cPaisLoc == "BRA"
			fTotIdFat((cAliasFun)->RA_FILIAL)
			fGPSVal((cAliasFun)->RA_FILIAL,cPeriodo,@aGPSVal,AllTrim(STR(nTpContr)))
			cFilAux :=  (cAliasFun)->RA_FILIAL
		EndIf
	
		oSelf:SetLineStyle(.F.)
		aLanP	:= {}
		aLanD  	:= {}
		aLanB 	:= {}
		
		While (cAliasQry)->(!Eof()) .And. ;
				(cAliasQry)->FILIAL == (cAliasFun)->RA_FILIAL .And. ;
				(cAliasQry)->MAT == (cAliasFun)->RA_MAT
		
			cPDB:=(cAliasQry)->RV_TIPOCOD
			aNomeFunc := { (cAliasQry)->RA_FILIAL, (cAliasQry)->RA_MAT, (cAliasQry)->RA_NOME }
			
			If cPDB == "1"
				nPos := Ascan(aLanP,{ |x| x[1] = (cAliasQry)->PD })
				If nPos > 0 .And. lSumaVerba
					aLanP[nPos,3] += (cAliasQry)->HORAS
					aLanP[nPos,4] += (cAliasQry)->VALOR
				Else
					aAdd(aLanP,{					 ;
								(cAliasQry)->PD		,;
								Left((cAliasQry)->RV_DESC,15)	,;
								(cAliasQry)->HORAS	,;
								(cAliasQry)->VALOR	,;
								(cAliasQry)->SEQ	,;
								})
				EndIf
			ElseIf cPDB == "2"
				nPos := Ascan(aLanD,{ |x| x[1] = (cAliasQry)->PD })
				If nPos > 0 .And. lSumaVerba
					aLanD[nPos,3] += (cAliasQry)->HORAS
					aLanD[nPos,4] += (cAliasQry)->VALOR
				Else
					aAdd(aLanD,{					 ;
								(cAliasQry)->PD		,;
								Left ((cAliasQry)->RV_DESC,15)	,;
								(cAliasQry)->HORAS	,;
								(cAliasQry)->VALOR	,;
								(cAliasQry)->SEQ	,;
								})
				EndIf
			ElseIf cPDB $ "3/4" .And. (cAliasQry)->RV_IMPRIPD != "2" 
				nPos := Ascan(aLanB,{ |x| x[1] = (cAliasQry)->PD })
				If nPos > 0 .And. lSumaVerba
					aLanB[nPos,3] += (cAliasQry)->HORAS
					aLanB[nPos,4] += (cAliasQry)->VALOR
				Else
					aAdd(aLanB,{					 ;
								(cAliasQry)->PD 	,;
								Left ((cAliasQry)->RV_DESC,15)	,;
								(cAliasQry)->HORAS	,;
								(cAliasQry)->VALOR	,;
								(cAliasQry)->SEQ	,;
								(cAliasQry)->RV_IMPRIPD;
								})
				EndIf
			EndIf
		    
			(cAliasQry)->(DbSkip())     
		EndDo 
					
		nMaxP	:= Len(aLanP)
		nMaxD 	:= Len(aLanD)
		nMaxB 	:= Len(aLanB)
		nMax	:= MAX(MAX(nMaxP,nMaxD),nMaxB)                  
		
	   	aSort(aLanB,,,{ |x,y| x[6]+x[1] < y[6]+y[1]})
		lPrinOn := .F.
		nCtaB := 1		
		oSelf:Init()

		If  nMax == 0
			nMax := 1
		Endif

		For nCta :=1 to nMax

			lImprLine := .F.
			If nCta > nMaxP  
				oSelf:Cell("REFERP"):Hide()
				oSelf:Cell("VALORP"):Hide()
				oSelf:Cell("PDP"   ):Hide()
				oSelf:Cell("DESCP" ):Hide()
				oSelf:Cell("PIPEP"):Hide()
			
				oSelf:Cell("REFERP"):SetPicture("")
				oSelf:Cell("VALORP"):SetPicture("")
				oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
				oSelf:Cell("DESCP" ):SetValue("")	//"DescriÁ„o"
				oSelf:Cell("REFERP"):SetValue("")	//"Ref."
				oSelf:Cell("VALORP"):SetValue("")	//"Valor" 
				
				lImprLine := lImprLine .OR. .F.
			Else
				oSelf:Cell("REFERP"):Show()
				oSelf:Cell("VALORP"):Show()
				oSelf:Cell("PDP"   ):Show()
				oSelf:Cell("DESCP" ):Show()
				oSelf:Cell("PIPEP"):Show()
				
				oSelf:Cell("REFERP"):SetPicture("@E 999,999.99")
				oSelf:Cell("VALORP"):SetPicture("@E 99,999,999,999.99")
				oSelf:Cell("PDP"   ):SetValue(aLanP[nCta,1])	//"Cod."
				oSelf:Cell("DESCP" ):SetValue(aLanP[nCta,2])	//"DescriÁ„o"
				oSelf:Cell("REFERP"):SetValue(aLanP[nCta,3])	//"Ref."
				oSelf:Cell("VALORP"):SetValue(aLanP[nCta,4])	//"Valor" 
				lImprLine := .T.
			EndIf
		
			If nCta > nMaxD
				oSelf:Cell("REFERD"):Hide()
				oSelf:Cell("VALORD"):Hide()
				oSelf:Cell("PDD"   ):Hide()
				oSelf:Cell("DESCD" ):Hide()
				oSelf:Cell("PIPED"):Hide()
				
				oSelf:Cell("REFERD"):SetPicture("")
				oSelf:Cell("VALORD"):SetPicture("")
				oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
				oSelf:Cell("DESCD" ):SetValue("")	//"DescriÁ„o"
				oSelf:Cell("REFERD"):SetValue("")	//"Ref."
				oSelf:Cell("VALORD"):SetValue("")	//"Valor" 
				lImprLine := lImprLine .OR. .F.
			Else
				oSelf:Cell("REFERD"):Show()
				oSelf:Cell("VALORD"):Show()
				oSelf:Cell("PDD"   ):Show()
				oSelf:Cell("DESCD" ):Show()
				oSelf:Cell("PIPED"):Show()   
				
				oSelf:Cell("REFERD"):SetPicture("@E 999,999.99")
				oSelf:Cell("VALORD"):SetPicture("@E 99,999,999,999.99")
				oSelf:Cell("PDD"   ):SetValue(aLanD[nCta,1])	//"Cod."
				oSelf:Cell("DESCD" ):SetValue(aLanD[nCta,2])	//"DescriÁ„o"
				oSelf:Cell("REFERD"):SetValue(aLanD[nCta,3])	//"Ref."
				oSelf:Cell("VALORD"):SetValue(aLanD[nCta,4])	//"Valor"     
				lImprLine := .T.
			EndIf
		
			If nCta > nMaxB .OR. nCtaB > nMaxB
				oSelf:Cell("VALORB"):SetPicture("")
				oSelf:Cell("PDB"   ):SetValue("")	//"Cod."
				oSelf:Cell("DESCB" ):SetValue("")	//"DescriÁ„o"
				oSelf:Cell("VALORB"):SetValue("")	//"Valor"
				lImprLine := lImprLine .OR. .F.
			Else                                        
            	If nCta > nMaxB  
					oSelf:Cell("VALORB"):Hide()
					oSelf:Cell("PDB"   ):Hide()
					oSelf:Cell("DESCB" ):Hide()
					lImprLine := lImprLine .OR. .F.
					
					oSelf:Cell("VALORB"):SetPicture("")
					oSelf:Cell("PDB"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCB" ):SetValue("")	//"DescriÁ„o"
					oSelf:Cell("VALORB"):SetValue("")	//"Valor"    				
				Else  
				   	If !lImpBase
						oSelf:Cell("VALORB"):Hide()
						oSelf:Cell("PDB"   ):Hide()
						oSelf:Cell("DESCB" ):Hide() 
						lImprLine := lImprLine .OR. .F. 
					Else          
						oSelf:Cell("VALORB"):Show()
						oSelf:Cell("PDB"   ):Show()
						oSelf:Cell("DESCB" ):Show()
						lImprLine := .T.
					EndIf	  
					oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
					oSelf:Cell("PDB"   ):SetValue(aLanB[nCta,1])	//"Cod."
					oSelf:Cell("DESCB" ):SetValue(Substr(aLanB[nCta,2],1,15))	//"DescriÁ„o" 
					oSelf:Cell("VALORB"):SetValue(aLanB[nCta,4])	//"Valor"   
				EndIf		
			EndIf

			If nCta < nMax 
				If lImprLine 
					oSelf:PrintLine()
				Endif
			EndIf
				     
		Next nCta
		
		If lImpBase .and. lImpFil
		 	lImprLine := .F.
			If Len(aFilB) > 0
				//Imprime o total da verba 973 no primeiro funcion·rio, sem exibir a linha, para que seja somado no totalizador da filial
				For nCta := 1 to Len(aFilB)
	
					oSelf:Cell("REFERP"):Hide()
					oSelf:Cell("VALORP"):Hide()
					oSelf:Cell("PDP"   ):Hide()
					oSelf:Cell("DESCP" ):Hide()
					oSelf:Cell("PIPEP"):Hide()
				
					oSelf:Cell("REFERP"):SetPicture("")
					oSelf:Cell("VALORP"):SetPicture("")
					oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCP" ):SetValue("")	//"DescriÁ„o"
					oSelf:Cell("REFERP"):SetValue("")	//"Ref."
					oSelf:Cell("VALORP"):SetValue("")	//"Valor" 
								
					oSelf:Cell("REFERD"):Hide()
					oSelf:Cell("VALORD"):Hide()
					oSelf:Cell("PDD"   ):Hide()
					oSelf:Cell("DESCD" ):Hide()
					oSelf:Cell("PIPED"):Hide()
					
					oSelf:Cell("REFERD"):SetPicture("")
					oSelf:Cell("VALORD"):SetPicture("")
					oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCD" ):SetValue("")	//"DescriÁ„o"
					oSelf:Cell("REFERD"):SetValue("")	//"Ref."
					oSelf:Cell("VALORD"):SetValue("")	//"Valor"	
								
					oSelf:Cell("VALORB"):Hide()
					oSelf:Cell("PDB"   ):Hide()
					oSelf:Cell("DESCB" ):Hide()
					oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
					oSelf:Cell("PDB"   ):SetValue(aFilB[nCta,1])	//"Cod."
					oSelf:Cell("DESCB" ):SetValue(aFilB[nCta,2])	//"DescriÁ„o" 
					oSelf:Cell("VALORB"):SetValue(aFilB[nCta,3])	//"Valor"
					aFilB := {}
					lImprLine := .T.
				Next nCta
			EndIf
			//Imprime os totais de complemento da GPS
			If Len(aGPSVal) > 0
				lImpAux := .F.
				For nCta := 1 to Len(aGPSVal)
					If lBrkCc
						If aGPSVAL[nCta,1] == (cAliasQry)->RA_CC .or. Empty(aGPSVAL[nCta,1])
							If lImprLine .or. lImpAux
								oSelf:PrintLine()
								lImprLine := .F.
							EndIf
							oSelf:Cell("REFERP"):Hide()
							oSelf:Cell("VALORP"):Hide()
							oSelf:Cell("PDP"   ):Hide()
							oSelf:Cell("DESCP" ):Hide()
							oSelf:Cell("PIPEP"):Hide()
						
							oSelf:Cell("REFERP"):SetPicture("")
							oSelf:Cell("VALORP"):SetPicture("")
							oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
							oSelf:Cell("DESCP" ):SetValue("")	//"DescriÁ„o"
							oSelf:Cell("REFERP"):SetValue("")	//"Ref."
							oSelf:Cell("VALORP"):SetValue("")	//"Valor" 
										
							oSelf:Cell("REFERD"):Hide()
							oSelf:Cell("VALORD"):Hide()
							oSelf:Cell("PDD"   ):Hide()
							oSelf:Cell("DESCD" ):Hide()
							oSelf:Cell("PIPED"):Hide()
							
							oSelf:Cell("REFERD"):SetPicture("")
							oSelf:Cell("VALORD"):SetPicture("")
							oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
							oSelf:Cell("DESCD" ):SetValue("")	//"DescriÁ„o"
							oSelf:Cell("REFERD"):SetValue("")	//"Ref."
							oSelf:Cell("VALORD"):SetValue("")	//"Valor" 
										
							oSelf:Cell("VALORB"):Hide()
							oSelf:Cell("PDB"   ):Hide()
							oSelf:Cell("DESCB" ):Hide()
							oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
							oSelf:Cell("PDB"   ):SetValue(aGPSVal[nCta,2])	//"Cod."
							oSelf:Cell("DESCB" ):SetValue(fDesc("SRV", aGPSVal[nCta,2], "RV_DESC"))	//"DescriÁ„o" 
							oSelf:Cell("VALORB"):SetValue(aGPSVal[nCta,5])	//"Valor"						
							lImpAux := .T.
						Else
							aAdd(aGPSAux,aGPSVal[nCta])
						EndIf
					Else
						If lImprLine .or. lImpAux
							oSelf:PrintLine()
							lImprLine := .F.
						EndIf					
						oSelf:Cell("REFERP"):Hide()
						oSelf:Cell("VALORP"):Hide()
						oSelf:Cell("PDP"   ):Hide()
						oSelf:Cell("DESCP" ):Hide()
						oSelf:Cell("PIPEP"):Hide()
					
						oSelf:Cell("REFERP"):SetPicture("")
						oSelf:Cell("VALORP"):SetPicture("")
						oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
						oSelf:Cell("DESCP" ):SetValue("")	//"DescriÁ„o"
						oSelf:Cell("REFERP"):SetValue("")	//"Ref."
						oSelf:Cell("VALORP"):SetValue("")	//"Valor" 
									
						oSelf:Cell("REFERD"):Hide()
						oSelf:Cell("VALORD"):Hide()
						oSelf:Cell("PDD"   ):Hide()
						oSelf:Cell("DESCD" ):Hide()
						oSelf:Cell("PIPED"):Hide()
						
						oSelf:Cell("REFERD"):SetPicture("")
						oSelf:Cell("VALORD"):SetPicture("")
						oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
						oSelf:Cell("DESCD" ):SetValue("")	//"DescriÁ„o"
						oSelf:Cell("REFERD"):SetValue("")	//"Ref."
						oSelf:Cell("VALORD"):SetValue("")	//"Valor" 
									
						oSelf:Cell("VALORB"):Hide()
						oSelf:Cell("PDB"   ):Hide()
						oSelf:Cell("DESCB" ):Hide()
						oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
						oSelf:Cell("PDB"   ):SetValue(aGPSVal[nCta,2])	//"Cod."
						oSelf:Cell("DESCB" ):SetValue(fDesc("SRV", aGPSVal[nCta,2], "RV_DESC"))	//"DescriÁ„o" 
						oSelf:Cell("VALORB"):SetValue(aGPSVal[nCta,5])	//"Valor"
						aGPSAux := {} //Zera aGPSVAL ao tÈrmino da impress„o pois n„o necessita totalizar por centro de custos
						lImpAux := .T.
					EndIf
				Next nCta			
				aGPSVal := aClone(aGpsAux)				
			EndIf			
		EndIf		
		
		oSelf:Finish()
	EndIf
EndIf

RestArea(aArea)

Return .T.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ fImprSint     ≥ Autor ≥ Tania Bronzeri        ≥ Data ≥27/02/2008≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Imprime os lancamentos da Folha de Pagamento Sintetica          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPER106                                                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fImprSint(oSelf) 
Local aArea		:= GetArea()
Local aGpsAux 	:= {}
Local cPDB		:= ""	//Horas / Dias / Valores
Local nMax		:= 0	//Controle maximo de verbas por tipo
Local nMaxP 	:= 0
Local nMaxD 	:= 0
Local nMaxB 	:= 0
Local nCta		:= 0
Local lImprLine 
Local lImpAux	:= .F.
Local aLanP		:= {}
Local aLanD 	:= {}
Local aLanB 	:= {}
Local cCpoQbr	:= (cAliasQry)->(&(cCpoQuebra))
cDAnt := (cAliasQry)->FILIAL + IIf(Empty(cCpoQbr), "", cCpoQbr) 

lcabecalho := .T.

If oSelf:cName != "LANCAMENTO"  
	oSelf:oReport:SkipLine()
	//oSelf:oReport:ThinLine()//FatLine()
	lPrinOn	:= .T.           
Else

	If lPrinOn
	
		//Imprime verba de desoneraÁ„o
		If cFilAux <> (cAliasQry)->RA_FILIAL .AND. cPaisLoc == "BRA"
			fTotIdFat((cAliasQry)->RA_FILIAL)
			fGPSVal((cAliasQry)->RA_FILIAL,cPeriodo,@aGPSVal,AllTrim(STR(nTpContr)))
			cFilAux := (cAliasQry)->RA_FILIAL
		EndIf
			
		oSelf:lVisible := .T.
		oSelf:SetLineStyle(.F.)
		aLanP	:= {}
		aLanD  	:= {}
		aLanB 	:= {}
		
		While (cAliasQry)->(!Eof()) .And. ;
			cDAnt == (cAliasQry)->FILIAL + IIf(Empty((cAliasQry)->(&(cCpoQuebra))), "", (cAliasQry)->(&(cCpoQuebra))) 

			cPDB:=(cAliasQry)->RV_TIPOCOD
			If cPDB == "1"
				aAdd(aLanP,{						 ;
							(cAliasQry)->PD			,;
							(cAliasQry)->RV_DESC	,;
							(cAliasQry)->HORAS		,;
							(cAliasQry)->VALOR		,;
							})
			ElseIf cPDB == "2"
				aAdd(aLanD,{						 ;
							(cAliasQry)->PD			,;
							(cAliasQry)->RV_DESC	,;
							(cAliasQry)->HORAS		,;
							(cAliasQry)->VALOR		,;
							})
			ElseIf cPDB $ "3/4" .And. (cAliasQry)->RV_IMPRIPD != "2" 
				aAdd(aLanB,{						 ;
							(cAliasQry)->PD 		,;
							(cAliasQry)->RV_DESC	,;
							(cAliasQry)->HORAS		,;
							(cAliasQry)->VALOR		,;
							})
			EndIf
		
			(cAliasQry)->(DbSkip())     
		EndDo 
					
		nMaxP	:= Len(aLanP)
		nMaxD 	:= Len(aLanD)
		nMaxB 	:= Len(aLanB)
		nMax	:= MAX(MAX(nMaxP,nMaxD),nMaxB) 
		lPrinOn := .F.
		
		oSelf:Init()   

		For nCta :=1 to nMax
			If nCta > nMaxP
			
				oSelf:Cell("REFERP"):SetPicture("")
				oSelf:Cell("VALORP"):SetPicture("")
				oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
				oSelf:Cell("DESCP" ):SetValue("")	//"DescriÁ„o"
				oSelf:Cell("REFERP"):SetValue("")	//"Ref."
				oSelf:Cell("VALORP"):SetValue("")	//"Valor"
			Else
				oSelf:Cell("REFERP"):SetPicture("@E 999,999.99")
				oSelf:Cell("VALORP"):SetPicture("@E 99,999,999,999.99")
				oSelf:Cell("PDP"   ):SetValue(aLanP[nCta,1])	//"Cod."
				oSelf:Cell("DESCP" ):SetValue(Substr(aLanP[nCta,2],1,14))	//"DescriÁ„o"
				oSelf:Cell("REFERP"):SetValue(aLanP[nCta,3])	//"Ref."
				oSelf:Cell("VALORP"):SetValue(aLanP[nCta,4])	//"Valor"
			EndIf
			If nCta > nMaxD
			
				oSelf:Cell("REFERD"):SetPicture("")
				oSelf:Cell("VALORD"):SetPicture("")
				oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
				oSelf:Cell("DESCD" ):SetValue("")	//"DescriÁ„o"
				oSelf:Cell("REFERD"):SetValue("")	//"Ref."
				oSelf:Cell("VALORD"):SetValue("")	//"Valor"
			Else
				oSelf:Cell("REFERD"):SetPicture("@E 999,999.99")
				oSelf:Cell("VALORD"):SetPicture("@E 99,999,999,999.99")
				oSelf:Cell("PDD"   ):SetValue(aLanD[nCta,1])	//"Cod."
				oSelf:Cell("DESCD" ):SetValue(Substr(aLanD[nCta,2],1,14))	//"DescriÁ„o"
				oSelf:Cell("REFERD"):SetValue(aLanD[nCta,3])	//"Ref."
				oSelf:Cell("VALORD"):SetValue(aLanD[nCta,4])	//"Valor"
			EndIf
			If nCta > nMaxB
				oSelf:Cell("VALORB"):SetPicture("")
				oSelf:Cell("PDB"   ):SetValue("")	//"Cod."
				oSelf:Cell("DESCB" ):SetValue("")	//"DescriÁ„o"
				oSelf:Cell("VALORB"):SetValue("")	//"Valor"    
			Else 
			   	If !lImpBase 
					oSelf:Cell("VALORB"):Hide()
					oSelf:Cell("PDB"   ):Hide()
					oSelf:Cell("DESCB" ):Hide() 
				EndIf			
				oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
				oSelf:Cell("PDB"   ):SetValue(aLanB[nCta,1])	//"Cod."
				oSelf:Cell("DESCB" ):SetValue(Substr(aLanB[nCta,2],1,15))	//"DescriÁ„o"
				oSelf:Cell("VALORB"):SetValue(aLanB[nCta,4])	//"Valor"
			EndIf
			If nCta < nMax
				oSelf:PrintLine()
			EndIf
		Next nCta
		
		If lImpBase .and. lImpFil 
			If Len(aFilB) > 0
				//Imprime o total da verba 973 no primeiro funcion·rio, sem exibir a linha, para que seja somado no totalizador da filial
				For nCta := 1 to Len(aFilB)
				
					oSelf:Cell("REFERP"):Hide()
					oSelf:Cell("VALORP"):Hide()
					oSelf:Cell("PDP"   ):Hide()
					oSelf:Cell("DESCP" ):Hide()
					oSelf:Cell("PIPEP"):Hide()
				
					oSelf:Cell("REFERP"):SetPicture("")
					oSelf:Cell("VALORP"):SetPicture("")
					oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCP" ):SetValue("")	//"DescriÁ„o"
					oSelf:Cell("REFERP"):SetValue("")	//"Ref."
					oSelf:Cell("VALORP"):SetValue("")	//"Valor" 
								
					oSelf:Cell("REFERD"):Hide()
					oSelf:Cell("VALORD"):Hide()
					oSelf:Cell("PDD"   ):Hide()
					oSelf:Cell("DESCD" ):Hide()
					oSelf:Cell("PIPED"):Hide()
					
					oSelf:Cell("REFERD"):SetPicture("")
					oSelf:Cell("VALORD"):SetPicture("")
					oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCD" ):SetValue("")	//"DescriÁ„o"
					oSelf:Cell("REFERD"):SetValue("")	//"Ref."
					oSelf:Cell("VALORD"):SetValue("")	//"Valor" 
								
					oSelf:Cell("VALORB"):Show()
					oSelf:Cell("PDB"   ):Show()
					oSelf:Cell("DESCB" ):Show()
					oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
					oSelf:Cell("PDB"   ):SetValue(aFilB[nCta,1])	//"Cod."
					oSelf:Cell("DESCB" ):SetValue(aFilB[nCta,2])	//"DescriÁ„o" 
					oSelf:Cell("VALORB"):SetValue(aFilB[nCta,3])	//"Valor"
					aFilB := {}
					lImprLine := .T.
				Next nCta
			EndIf
			//Imprime os totais de complemento da GPS
			If Len(aGPSVal) > 0
				lImpAux := .F.
				For nCta := 1 to Len(aGPSVal)
					If lBrkCc
						If aGPSVAL[nCta,1] == (cAliasQry)->RA_CC .or. Empty(aGPSVAL[nCta,1])
							If lImprLine .or. lImpAux
								oSelf:PrintLine()
								lImprLine := .F.
							EndIf						
							oSelf:Cell("REFERP"):Hide()
							oSelf:Cell("VALORP"):Hide()
							oSelf:Cell("PDP"   ):Hide()
							oSelf:Cell("DESCP" ):Hide()
							oSelf:Cell("PIPEP"):Hide()
						
							oSelf:Cell("REFERP"):SetPicture("")
							oSelf:Cell("VALORP"):SetPicture("")
							oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
							oSelf:Cell("DESCP" ):SetValue("")	//"DescriÁ„o"
							oSelf:Cell("REFERP"):SetValue("")	//"Ref."
							oSelf:Cell("VALORP"):SetValue("")	//"Valor" 
										
							oSelf:Cell("REFERD"):Hide()
							oSelf:Cell("VALORD"):Hide()
							oSelf:Cell("PDD"   ):Hide()
							oSelf:Cell("DESCD" ):Hide()
							oSelf:Cell("PIPED"):Hide()
							
							oSelf:Cell("REFERD"):SetPicture("")
							oSelf:Cell("VALORD"):SetPicture("")
							oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
							oSelf:Cell("DESCD" ):SetValue("")	//"DescriÁ„o"
							oSelf:Cell("REFERD"):SetValue("")	//"Ref."
							oSelf:Cell("VALORD"):SetValue("")	//"Valor" 
										
							oSelf:Cell("VALORB"):Show()
							oSelf:Cell("PDB"   ):Show()
							oSelf:Cell("DESCB" ):Show()
							oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
							oSelf:Cell("PDB"   ):SetValue(aGPSVal[nCta,2])	//"Cod."
							oSelf:Cell("DESCB" ):SetValue(fDesc("SRV", aGPSVal[nCta,2], "RV_DESC"))	//"DescriÁ„o" 
							oSelf:Cell("VALORB"):SetValue(aGPSVal[nCta,5])	//"Valor"
							lImpAux := .T.						
						Else
							aAdd(aGPSAux,aGPSVal[nCta])
						EndIf
					Else
						If lImprLine .or. lImpAux
							oSelf:PrintLine()
							lImprLine := .F.
						EndIf					
						oSelf:Cell("REFERP"):Hide()
						oSelf:Cell("VALORP"):Hide()
						oSelf:Cell("PDP"   ):Hide()
						oSelf:Cell("DESCP" ):Hide()
						oSelf:Cell("PIPEP"):Hide()
					
						oSelf:Cell("REFERP"):SetPicture("")
						oSelf:Cell("VALORP"):SetPicture("")
						oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
						oSelf:Cell("DESCP" ):SetValue("")	//"DescriÁ„o"
						oSelf:Cell("REFERP"):SetValue("")	//"Ref."
						oSelf:Cell("VALORP"):SetValue("")	//"Valor" 
									
						oSelf:Cell("REFERD"):Hide()
						oSelf:Cell("VALORD"):Hide()
						oSelf:Cell("PDD"   ):Hide()
						oSelf:Cell("DESCD" ):Hide()
						oSelf:Cell("PIPED"):Hide()
						
						oSelf:Cell("REFERD"):SetPicture("")
						oSelf:Cell("VALORD"):SetPicture("")
						oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
						oSelf:Cell("DESCD" ):SetValue("")	//"DescriÁ„o"
						oSelf:Cell("REFERD"):SetValue("")	//"Ref."
						oSelf:Cell("VALORD"):SetValue("")	//"Valor" 
									
						oSelf:Cell("VALORB"):Show()
						oSelf:Cell("PDB"   ):Show()
						oSelf:Cell("DESCB" ):Show()
						oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
						oSelf:Cell("PDB"   ):SetValue(aGPSVal[nCta,2])	//"Cod."
						oSelf:Cell("DESCB" ):SetValue(fDesc("SRV", aGPSVal[nCta,2], "RV_DESC"))	//"DescriÁ„o" 
						oSelf:Cell("VALORB"):SetValue(aGPSVal[nCta,5])	//"Valor"
						aGPSAux := {} //Zera aGPSVAL ao tÈrmino da impress„o pois n„o necessita totalizar por centro de custos
						lImpAux := .T.
					EndIf
				Next nCta			
				aGPSVal := aClone(aGpsAux)				
			EndIf			
		EndIf
				
		oSelf:Finish() 
	Else

		If nAnaSin == 1
			oSelf:lVisible := .F.
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return .T.



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GPER106   ∫Autor  ≥Microsiga           ∫ Data ≥  09/11/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
static Function f2CalcDifLiqU(nValDif)
Local nCont 		:= 0
Local nProc 		:= aScan( aLanB, { |x| x[1] == cPdLiq})
Local nValLiq		:= 0
Local nTotVal		:= 0
Local nValPro		:= 0
Local nValDes		:= 0
Local cRet			:= ""

	//SOMA OS PROVENTOS
	For nCont := 1 To Len(aLanP)
		nValPro := nValPro + aLanP[ nCont, 4 ] 
	Next
	
	//SOMA OS DESCONTOS
	For nCont := 1 To Len(aLanD)
		nValDes := nValDes+ aLanD[ nCont, 4 ] 
	Next
	
	If ( nProc > 0 )
		nValLiq	:= aLanB[ nProc, 4 ]
	Else
		nValLiq := 0
	EndIf  
			
	If 	( ( nTotVal := ( nValLiq - ( nValPro - nValDes ) )  ) != 0 )
	
		cRet := " "+OemToAnsi(STR0055)+" " 	+ AllTrim(aNomeFunc[1]) 
		cRet += Space(15-Len(cRet)) + "|"
		cRet += " "+OemToAnsi(STR0002)+" " + AllTrim(aNomeFunc[2]) 
		cRet += Space(35-Len(cRet)) + "|"
		cRet += " "+OemToAnsi(STR0003)+" " + Substr(AllTrim(aNomeFunc[3]), 1, 25) 
		cRet += Space(70-Len(cRet)) + "|"
		cRet += " "+OemToAnsi(STR0027)+" " + AllTrim(cPdLiq)
 		cRet += " | "+OemToAnsi(STR0053)+" " + AllTrim(Str(nTotVal))
 		//ADICIONA RESULTADO NO ARRAY QUE SERA IMPRESSO NO FINAL DO RELATORIO COM TODAS AS DIFERENCAS DE LIQUIDOS
		aAdd(aDifLiquidos, cRet)
		cRet := " "+OemToAnsi(STR0053)+" " + AllTrim(Str(nTotVal))		
	Else
		cRet := " "+OemToAnsi(STR0039)+" 0.00" 
	EndIf
                                  
Return cRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GPER106   ∫Autor  ≥Microsiga           ∫ Data ≥  09/12/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
static Function f2ImprDifLiqU(oReport)
Local nCont		:= 0
Local nTamADif 	:= Len(aDifLiquidos)

oSectDifLiq:Init()
oSectDifLiq:cell("DIFLIQ"):SetValue( OemToAnsi(STR0053) ) 
oSectDifLiq:PrintLine()
oReport:ThinLine()     
oReport:SkipLine()

If ( nTamADif > 0 )
	For nCont := 1 To nTamADif 
		oSectDifLiq:cell("DIFLIQ"):SetValue( aDifLiquidos[ nCont ] )
   		oSectDifLiq:PrintLine()
	Next
EndIf             

oReport:SkipLine()

Return (Nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fImprQFu  ∫Autor  ≥Reginaldo           ∫ Data ≥  15/10/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥imprime a total de funcionario que foram Gerados	           ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GPER106                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
User Function fImprQFunC(oReport)
oReport:SkipLine()
oSectQtdFun:Init()
oSectQtdFun:cell("TOTFUNC"):SetValue( OemToAnsi(STR0056) + Str(nTotFunc) ) 
oSectQtdFun:PrintLine()

If nAnaSin == 1
	oReport:ThinLine()
	oReport:SkipLine()
EndIf

Return ( Nil )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fCountTotFunc∫Autor  ≥Reginaldo           ∫ Data ≥  15/10/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Conta os funcionarios que ser„o imprssos na opÁ„o analitica    ∫±±
±±∫          ≥                                                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GPER106                                                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
User Function fCountTotFuncI()
	nTotFunc++
Return Nil 

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fContFunc    ∫Autor  ≥Reginaldo           ∫ Data ≥  20/10/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Conta os funcionarios que ser„o imprssos na opÁ„o sintetica    ∫±±
±±∫          ≥                                                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GPER106                                                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fContFunc(cJoinC,cJoinD,cSitQuery,cCatQuery,cProcesso,cPeriodo,cRoteiro,cPagamento,cFiltro)

BeginSql alias cAliasFunTT
	
	SELECT Sum(TOTAL) Tot FROM (
		SELECT	COUNT(MATRICULA) TOTAL
		FROM
		(
			SELECT 	RC_FILIAL  FILIAL, RC_MAT MATRICULA
			FROM  %table:SRA% SRA	
			INNER JOIN %table:SRC% SRC 
			ON 		SRA.RA_FILIAL = SRC.RC_FILIAL %exp:cJoinC%
			WHERE 	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND 
					SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND 
					SRC.RC_PROCES  BETWEEN   %exp:Upper(cProcesso)%  AND %exp:Upper(cProcessoa)% AND
					SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND 
					SRC.RC_ROTEIR  =   %exp:Upper(cRoteiro)%   AND 
					SRC.RC_SEMANA =    %exp:Upper(cPagamento)% AND 
					SRA.%notDel% %exp:Upper(cFiltro)% AND SRC.%notDel% 
			GROUP BY RC_FILIAL, RC_MAT
			
			UNION
			
			SELECT RD_FILIAL FILIAL , RD_MAT MATRICULA 
			FROM  %table:SRA% SRA	
			INNER JOIN %table:SRD% SRD 
			ON 		SRA.RA_FILIAL = SRD.RD_FILIAL %exp:cJoinD%
			WHERE 	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND 
					SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND 
					SRD.RD_PROCES  BETWEEN   %exp:Upper(cProcesso)%  AND %exp:Upper(cProcessoa)% AND 
					SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND 
					SRD.RD_ROTEIR  =   %exp:Upper(cRoteiro)%   AND 
					SRD.RD_SEMANA =    %exp:Upper(cPagamento)% AND 
					SRA.%notDel% %exp:Upper(cFiltro)% AND SRD.%notDel% 
			GROUP BY RD_FILIAL , RD_MAT 
		) tView
		GROUP BY MATRICULA, tView.FILIAL
		)tViewTot
EndSql

nTotFunc := (cAliasFunTT)->tot

Return()	

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ fCtrlDtRa  ≥ Autor ≥ Equipe RH - N3        ≥ Data ≥01/09/2010≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Controle de habilitaÁ„o e desabilitaÁ„o das cÈlulas de impre-≥±±
±±≥         ≥ Sess„o das datas de Admiss„o, Readmiss„o e Reconhecimento.    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPER106                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/  
Static Function fCtrlDtRA(oSecAux)
Local aArea := GetArea()

dbSelectArea(cAliasFun)    
If cPaisLoc != "MEX"
	oSecAux:Cell("RA_ADMISSA"):Enable()	
Else
	If !Empty((cAliasFun)->RA_DTREC)
		oSecAux:Cell("RA_DTREC"  ):Enable()		
		oSecAux:Cell("RA_FECREI" ):Disable()
		oSecAux:Cell("RA_ADMISSA"):Disable()
	ElseIf !Empty((cAliasFun)->RA_FECREI)
		oSecAux:Cell("RA_FECREI" ):Enable()
		oSecAux:Cell("RA_DTREC"  ):Disable()
		oSecAux:Cell("RA_ADMISSA"):Disable()
	Else
		oSecAux:Cell("RA_ADMISSA"):Enable()
		oSecAux:Cell("RA_DTREC"  ):Disable()
		oSecAux:Cell("RA_FECREI" ):Disable()
	EndIf
Endif

RestArea(aArea)
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖcao  ≥fGR106join  ≥ Autor ≥  Equipe RH           ≥ Data ≥ 19/09/2012       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescricaáÖo ≥O tratamento a seguir deve-se ao problema do embedded SQL n„o      ≥±±
±±≥          ≥converter clausula "SUBSTRING" no INNER JOIN, ao usar banco de dados ≥±±
±±≥          ≥ORACLE. E segundo sustentaÁao FRAMEWORK, devemos alterar consulta SQL≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±± 
±±≥Parametro ≥ExpC1 - Obrigatorio - Vari·vel com Primeira tabela do "inner join"   ≥±±
±±≥          ≥ExpC2 - Obrigatorio - Vari·vel com Segunda  tabela do "inner join"   ≥±±
±±≥          ≥ExpC3 - Vari·vel indica se retorno dever· conter "%   %". Caso vazio ≥±±
±±≥          ≥        o seu valor padr„o ser· "".                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥GPER106                                                              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fGR106join(cTabela1, cTabela2,cEmbedded)
Local cFiltJoin := ""
Default cEmbedded := ""

cFiltJoin := cEmbedded + FWJoinFilial(cTabela1, cTabela2) + cEmbedded	

If ( TCGETDB() $ 'DB2|ORACLE|POSTGRES|INFORMIX' )
	cFiltJoin := STRTRAN(cFiltJoin, "SUBSTRING", "SUBSTR")
EndIf

Return (cFiltJoin)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖcao  ≥fGR106Header  ≥ Autor ≥  Esther Viveiro      ≥ Data ≥ 30/04/2014        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescricaáÖo ≥DefiniÁ„o do cabeÁalho do relatÛrio.                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±± 
±±≥Parametro ≥oReport    - Obrigatorio - objeto com as informaÁıes do realtÛrio.      ≥±±
±±≥          ≥nImpressao - Obrigatorio - Define qual tipo de impress„o ser· realizada.≥±±
±±≥          ≥          1 = Cabecalho de p·gina; 2 = Cabecalho da seÁ„o sintÈtica.    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥GPER106                                                                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fGR106Header(oReport)
	cTipoContrato := EVAL({||Iif(nTpContr==1,OemToAnsi(STR0013),Iif(nTpContr==2,OemToAnsi(STR0014),OemToAnsi(STR0015)))})
	cDescProc  := EVAL({||Substr(PosAlias("RCJ",cProcesso,xFilial("RCJ"),"RCJ_DESCRI"),1,20)}) 
	cDescProca := EVAL({||Substr(PosAlias("RCJ",cProcessoa,xFilial("RCJ"),"RCJ_DESCRI"),1,20)})
	cDtPeriodo := EVAL({||Dtoc(dDtPerIni)+"-"+Dtoc(dDtPerFim)})
	
	oReport:SkipLine()
	oReport:PrintText(OemToAnsi(STR0012) + cTipoContrato + space(05) + OemToAnsi(STR0016) + cProcesso + ' - ' + cDescProc + ' a ' + cProcessoa + ' - ' + cDescProca,/*nRow*/,/*nCol*/,/*nClrText*/,/*cStyle*/,/*nCells*/,.F.) //"Tipo de Cotrato"##"Processo"
	oReport:SkipLine()
	oReport:PrintText(OemToAnsi(STR0017) + cPeriodo + space(05) + OemToAnsi(STR0018) + cPagamento + space(05) + OemToAnsi(STR0019) + cDtPeriodo + space(05) + OemToAnsi(STR0020) + DtoC(dDtPago),/*nRow*/,/*nCol*/,/*nClrText*/,/*cStyle*/,/*nCells*/,.F.)//"PerÌodo"##"Pagamento"##"DtPeriodo"##"DtPagto"
	oReport:ThinLine()
	oReport:SkipLine()

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ fTotIdFat   ≥ Autor ≥ Leandro Drumond    ≥ Data ≥ 25.11.15 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Totaliza os registros ref. verba id 973 no relatio folha.  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPER106                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fTotIdFat(cFilAux)

Local aArea			:= GetArea()
Local aTabS033		:= {}
Local cRecFatEmp	:= ""
Local cVb973		:= ""
Local lGera			:= .F.
Local lRecDesTot	:= .F.
Local nCont		    := 0
Local nFatDes		:= 0
Local nFatFol		:= 0
Local nEmpFatTot	:= 0
Local nEmpFatDes	:= 0
Local nEmpFatFol	:= 0
Local nPos			:= 0
Local nProp			:= 0
Local nTpc			:= 0
Local nTotCont		:= 0
Local nTotOcorr		:= 0
Local cMesAnoOne	:= If (Type("P_FDESFOL") # "U", P_FDESFOL, "")

Private aInssEmp[24][2]

aFilB := {}

If Funname() == "GPER106COL" .And. !Empty(cMesAnoOne)
	//Se for chamado pelo GPER040 e a empresa n„o for mais desonerada n„o gera no relatÛrio o ID 0973
	If MV_PAR04 > cMesAnoOne
		Return(Nil)
	Endif
Endif

If !fInssEmp(cFilAux,@aInssEmp,,cPeriodo)
	Return
EndIf

//Verifica se a empresa efetua recolhimento da contribuicao patronal s/ o faturamento
For nTpc := 1 To Len( aInssEmp[27] )
	cRecFatEmp	:= aInssEmp[27, nTpc]//X14_RECFAT
	If cRecFatEmp $ "S*M*C"
		Exit
	EndIf
Next nTpc

//Chama fCarrTab para carregar tabela auxiliar S033
fCarrTab( @aTabS033, "S033", StoD(cPeriodo+"01") ,.T.)

//Apura a receita bruta total da empresa para verificar se havera ou nao o calculo sobre o faturamento
aEval(aTabS033, {|aTabS033| nEmpFatTot += aTabS033[7] } )
//Apura a receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
aEval(aTabS033, {|aTabS033| If( aTabS033[6] == "2", nEmpFatFol += aTabS033[7], ) } )	
//Apura a receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
aEval(aTabS033, {|aTabS033| If( aTabS033[6] == "1", nEmpFatDes += aTabS033[7], ) } )	
//Verifica se a receita desonerada da empresa e' superior a 95% do total
lRecDesTot := ( nEmpFatDes / nEmpFatTot >= 0.95 )
/*
⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
≥Somente havera recolhimento sobre o Faturamento se o total nao≥
≥desonerado da empresa for MENOR que 95% do total geral        ≥
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ*/
lGera := ( cRecFatEmp == "M" .And. ( nEmpFatFol / nEmpFatTot ) < 0.95 ) 

If lGera .Or. cRecFatEmp $ "S*C"

	//Se a empresa efetua a contribucao s; o faturamento ou misto, verifica se existe o ID 973
	If cRecFatEmp $ "S*M*C"
		cVb973 := fGetCodFol("973")//INSS Empresa s/ Faturamento
        //Verifica se a receita desonerada da empresa e' superior a 95% do total
		If !Empty(cVb973) 
		 	If cRecFatEmp != "S" .And. lRecDesTot
				//Apura o total da contribuicao previdenciaria da filial processada sobre as atividades desoneradas
				aEval(aTabS033, {|aTabS033| If( aTabS033[2] + aTabS033[6] == cFilAux + "1", nTotCont += aTabS033[9], Nil ) } )
				aEval(aTabS033, {|aTabS033| If( aTabS033[2] + aTabS033[6] == cFilAux + "1", nTotOcorr++, Nil ) } )
				//Apura a receita bruta que e' sobre as atividades desoneradas
				aEval(aTabS033, {|aTabS033| If( aTabS033[2] == cFilAux .And. aTabS033[6] == "1", nFatDes += aTabS033[7], ) } )
				//Apura a receita bruta que nao e' sobre as atividades desoneradas
				aEval(aTabS033, {|aTabS033| If( aTabS033[2] == cFilAux .And. aTabS033[6] == "2", nFatFol += aTabS033[7], ) } )
			    //Se a receita bruta da atividade desonerada for maior do que 95% do total devera ser
			    //considerado a receita bruta da atividade nao desonerada.Sera aplicado a proporcionalidade
			    //das aliquotas das atividades desoneradas conforme correspondencia do percentual da receita
			    //desonerada em relacao ao total desonerado
			    //Ex: Cod de atividade X possui receita bruta de 45.000 com aliquota de 1%. A receita bruta
			    //    total de atividade desonerada e' igual a 98.000 e ha 2.000 de atividade nao desonerada.
			    //	  Sera feito a regra de 3 para saber quanto da receita bruta da atividade corresponde
			    //    ao total desonerado. Percentual = 45.000 * 100 / 98.000 = 45,91%. O percentual sera
			    //    aplicado sobre os 2.000 da receita nao desonerada. Sobre o valorencontrado sera
			    //	  aplicado a aliquota correspondente ao codigo da atividade. Esse valor sera somado ao
			    //    que a empresa ja recolhe de contribuicao sobre a atividade desonerada.
				nTotOcorr++
				For nCont := 1 To Len(aTabS033)
					If aTabS033[nCont, 2] == cFilAux .And. aTabS033[nCont, 6] == "1"
						nProp := ( aTabS033[nCont, 7] * 100 / nFatDes ) / 100
						nTotCont += ( nProp * nFatFol ) * ( aTabS033[nCont, 8] / 100 )
					EndIf
				Next nCont
			Else
				//Apura o total da contribuicao previdenciaria da filial processada sobre as atividades desoneradas
				aEval(aTabS033, {|aTabS033| If( aTabS033[2] + aTabS033[6] == cFilAux + "1", nTotCont += aTabS033[9], Nil ) } )
				aEval(aTabS033, {|aTabS033| If( aTabS033[2] + aTabS033[6] == cFilAux + "1", nTotOcorr++, Nil ) } )
			EndIf
		EndIf
	EndIf
	
	//Se houve faturamento no periodo e existe a verba com Id 973 cadastrada,
	//adiciona os valores no array de totalizacao
	If nTotCont > 0 .And. !Empty( cVb973 )
		If ( nPos := aScan( aFilB,{|X| x[1] == cVb973 } ) ) == 0
			aAdd( aFilB, { cVb973, fDesc("SRV", cVb973, "RV_DESC"), nTotCont} )
		Else
			aFilB[nPos, 3] += nTotCont
		EndIf
	EndIf

EndIf

RestArea( aArea )

Return(Nil)


/*/{Protheus.doc} fAjustFil
Filtra pelas filiais que o usu·rio tem acesso.
@Type Function
@author Gabriel Almeida
@since 13/09/2016
@version 2.0
@return cRet, string com as filiais que o usu·rio possui acesso.
/*/
Static Function fAjustFil()

	Local cRet      := " RA_FILIAL IN( "
	Local cFiltFil  := "%" + AllTrim(MV_PAR06) + "%"
	Local cAliasQry := GetNextAlias()
	Local cFilPerm  := fValidFil()
	
	If cFiltFil <> "%%"
		BeginSql Alias cAliasQry
			SELECT DISTINCT SRA.RA_FILIAL AS FILIAL
			FROM %table:SRA% SRA
			WHERE SRA.%notDel% AND
			%Exp:cFiltFil%
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT DISTINCT SRA.RA_FILIAL AS FILIAL
			FROM %table:SRA% SRA
			WHERE SRA.%notDel%
		EndSql
	EndIf

	DbSelectArea(cAliasQry)
	(cAliasQry)->( DbGoTop() )
	
	While !( (cAliasQry)->( EOF() ) )
		If (cAliasQry)->FILIAL $ cFilPerm
			cRet += " '" + (cAliasQry)->FILIAL + "', "
		EndIf
		(cAliasQry)->( DbSkip() )
	EndDo
	
	(cAliasQry)->( DbCloseArea() )
	
	cRet += " '' )"

Return( cRet )

/*/{Protheus.doc} GPE106Val
@type  Function
@author oscar.lopez
@since 06/09/2021
@version 1.0
@param cProcIni, string, Proceso inicial
@param cProcFin, string, Proceso final
@param cRoteir, string, Procedimiento
@param cPeriodo, string, Periodo
@param cNumPag, string, Numero de pago
@return lRet, boolean, T o F si existe Periodo o Num Pago en rango de Procesos y el Procedimiento informado
@example GPE106Val(cProcIni, cProcFin, cRoteir, cPeriodo, cNumPag)
/*/
Function GPE106Val(cProcIni, cProcFin, cRoteir, cPeriodo, cNumPag)

	Local aArea		:= GetArea()
	Local cTempQry	:= GetNextAlias()
	Local cCond		:= ""
	Local lRet		:= .T.

	Default cProcIni	:= ""
	Default cProcFin	:= ""
	Default cRoteir		:= ""
	Default cPeriodo	:= ""
	Default cNumPag		:= ""

	cCond := "% D_E_L_E_T_ = '' AND RCH_FILIAL = '" + xFilial("RCH") + "' "
	cCond += "AND RCH_PROCES BETWEEN '" + cProcIni + "' AND '" + cProcFin + "' "
	cCond += "AND RCH_ROTEIR = '" + cRoteir + "' "
	cCond += "AND RCH_PER = '" + cPeriodo + "' "
	If !Empty(cNumPag)
		cCond += "AND RCH_NUMPAG = '" + cNumPag + "' "
	EndIf
	cCond += " %"

	BeginSQL Alias cTempQry
		SELECT *
		FROM %Table:RCH% RCH
		WHERE %exp:cCond%
	EndSQL

	dbSelectArea(cTempQry)

	If (cTempQry)->(EoF())
		lRet := .F.
	EndIf

	(cTempQry)->(dbCloseArea())

	RestArea(aArea)

Return ( lRet )

/*/{Protheus.doc} GPE106Fil
@type  Function
@author oscar.lopez
@since 06/09/2021
@version 1.0
@param cProcIni, string, Proceso inicial
@param cProcFin, string, Proceso final
@param cRoteir, string, Procedimiento
@param cPeriodo, string, Periodo
@return cFiltro, string, Filtro para aplicar en consulta estandar
@example GPE106Fil(cProcIni, cProcFin, cRoteir, cPeriodo)
/*/
Function GPE106Fil(cProcIni, cProcFin, cRoteir, cPeriodo)

	Local cFiltro		:= ""

	Default cProcIni	:= ""
	Default cProcFin	:= ""
	Default cRoteir		:= ""
	Default cPeriodo	:= ""

	cFiltro := "(RCH->RCH_FILIAL == '" + xFilial("RCH") + "') "
	cFiltro += ".AND. (RCH->RCH_PROCES >= '" + cProcIni + "' .AND. RCH->RCH_PROCES <= '" + cProcFin + "') "
	cFiltro += ".AND. RCH->RCH_ROTEIR == '" + cRoteir + "' "
	If !Empty(cPeriodo)
		cFiltro += ".AND. RCH->RCH_PER == '" + cPeriodo + "' "
	EndIf
	cFiltro := "@#" + cFiltro + "@#"

Return ( cFiltro )

/*/{Protheus.doc} GPE106Ret
@type  Function
@author oscar.lopez
@since 06/09/2021
@version 1.0
@param cTipo, string, Campo a validar/retornar
@return cCpoRet, string, Campo retornado
@example GPE106Ret(cTipo)
/*/
Function GPE106Ret(cTipo)

	Local cCpoRet	:= ""

	Default cTipo	:= ""

	If cTipo == "NUMPAGO"
		cCpoRet := "RCH->RCH_NUMPAG"
	Else
		cCpoRet := "RCH->RCH_PER"
	EndIf

	cCpoRet := If ( Empty(&(cCpoRet)), "",  &(cCpoRet) )

Return ( cCpoRet )
