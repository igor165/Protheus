#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER106.CH"
#INCLUDE "REPORT.CH"     
#include "topconn.ch" 

Static lPrinOn := .F.
Static cDAnt   := ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma   ³GPER106PER ºAutor  ³Cesar Perea           º Data ³   2018       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.      ³ Relatorio Folha de Pagamento                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso        ³ Folha de pagamento - Todos                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³ Data     ³ BOPS/FNC  | Motivo da Alteracao                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ³          ³          ³              							º±±
±±º            ³          ³          ³                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPER106PER()
Local	oReport
Local	aArea 			:= GetArea()
Private aFilB			:= {}
Private aGPSVal			:= {}
Private cCodFunc		:= ""
Private cDescFunc		:= ""
Private cPerg			:= "GPE106R3"
Private dDataRef		:= CtoD("  /  /  ")
Private cMesAnoRef	:= CtoD("  /  /  ")
Private cAnoMesRef	:= CtoD("  /  /  ")
Private dDtPerIni		:= Ctod("  /  /  ")
Private dDtPerFim		:= Ctod("  /  /  ")
Private dDtPago		:= Ctod("  /  /  ")
Private cTitulo		:= OemToAnsi(STR0001)	//"Folha de Pagamento"
Private cMascCus  	:= GetMv("MV_MASCCUS")
Private cCalcInf  	:= GetMv("MV_CALCINF")
Private cQuebFun  	:= GetMv("MV_QUEBFUN",,"S") //quando for igual a nao, imprime funcionario sem quebrar pagina 
Private cIRefSem  	:= GetMv("MV_IREFSEM",,"S")
Private lAglutPd  	:= (GetMv("MV_AGLUTPD",,"1") == "1" ) // 1-Aglutina verbas   2-Nao Aglutina
Private lDifLiq		:= .F.
Private lSumaVerba	:= .F.
Private nOrdSra		:= 1
Private cMod1			:= "" 
Private aLanB			:= {} 
Private aLanP			:= {}
Private aLanD   		:= {}
Private aNomeFunc		:= {} 
Private aDifLiquidos	:= {}
Private cPDLiq		:= fGetCodFol("0047")
Private oSectDifLiq
Private cDepto		:= ""  //UTILIZADO P/ INFORMAÇÃO HISTORICA
Private cDescDepto	:= ""
Private cCentroC		:= ""
Private cDescCC		:= ""
Private nTotFunc		:= 0
Private nOrdRemov 	:= 0 // QUANTIDADE DE ORDENS NAO EXISTENTES E QUE IMPACTA NA VARIAVEL NORDEM
Private nPosRemov 	:= 0 // POSICAO PARA CONTROLAR O QUE FOI REMOVIDO
Private lDepSf		:= IIf(SRA->(FieldPos("RA_DEPSF"))>0,.T.,.F.)   
Private lRaDtRec		:= IIf(SRA->(FieldPos("RA_DTREC"))>0,.T.,.F.)
Private lRaFecrei		:= IIf(SRA->(FieldPos("RA_FECREI"))>0,.T.,.F.)
Private lRaSalDia		:= IIf(SRA->(FieldPos("RA_SALDIA"))>0,.T.,.F.)
Private lRaSalInt		:= IIf(SRA->(FieldPos("RA_SALINT"))>0,.T.,.F.)
Private aOrd			:={}

	Aadd(aOrd, OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))  //1  - "Matrícula + Lançamentos"	
	Aadd(aOrd, OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))  //2  - "Nome + Lançamentos"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))	//3  - "C.Custo Cad. + Matrícula + Lançamentos"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))	//4  - "C.Custo Cad. + Nome + Lançamentos"
	Aadd(aOrd, OemToAnsi(STR0006)+"+"+OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))	//5  - "C.Custo Mov. + Matrícula + Lançamentos"
	Aadd(aOrd, OemToAnsi(STR0006)+"+"+OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))	//6  - "C.Custo Mov. + Nome + Lançamentos"
	Aadd(aOrd, OemToAnsi(STR0007)+"+"+OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))	//7  - "Depto. + Matricula + Lançamentos"
	Aadd(aOrd, OemToAnsi(STR0007)+"+"+OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))	//8  - "Depto. + Nome + Lançamentos"
	
	nPosRemov := Len(aOrd) + 1
	
Private cProcesso		:= ""
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
Private lCorpManage	:= fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gestão Corporativa no Grupo Logado
Private lSint			:= .F. // variável que informa se foi selecionado tipo sintético



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

cRot := MV_PAR02

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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Tania Bronzeri        ³ Data ³20/11/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Folha de Pagamento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER106PER                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0009)		//"Folha de Pagamento" ### "Imprime a Folha de pagamento, de acordo com os parametros solicitados pelo usu rio."
Local oSecCont
Local nSize := 14

Local bBlkEmp := { || If ( cCodFilial != (cAliasQry)->RA_FILIAL, Eval( { || fInfo(@aInfo,(cAliasQry)->RA_FILIAL), aInfo[3] } ), aInfo[3] ) }



//CRIACAO DOS COMPONENTES DE IMPRESSAO
DEFINE REPORT oReport NAME "GPER106PER" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| R106Imp(oReport) } DESCRIPTION cDesc1	

	nAnaSin   	:= mv_par13		//Tipo Relatorio: 1=Analitico; 2=Sintetico

	oReport:SetTotalInLine(.F.)	// PARA TOTALIZAR EM LINHAS
	
		oReport:nFontBody	:= 8
	
	oReport:SetDynamic()
	
	//SECTION 01 
	DEFINE SECTION oSecMat OF oReport TITLE OemToAnsi(STR0036) TABLES "SRA","SQB","CTT","RCO","RGC" ORDERS aOrd	//"Filial / Funcionário"

		DEFINE CELL NAME "ESPACO"     OF oSecMat TITLE "" BLOCK {||" "}		//Recurso alternativo para que a section do funcionário náo saia colada a collection. 
 		DEFINE CELL NAME "RA_FILIAL"  OF oSecMat ALIAS "SRA"
		DEFINE CELL NAME "RA_MAT"     OF oSecMat ALIAS "SRA" 
		DEFINE CELL NAME "RA_NOME"    OF oSecMat TITLE "Apellidos y Nombres" SIZE 45 BLOCK {|| AllTrim(AllTrim(SRA->RA_PRISOBR)+" "+AllTrim(SRA->RA_SECSOBR)+" "+AllTrim(SRA->RA_PRINOME)+" "+AllTrim(SRA->RA_SECNOME)) } //ALIAS "SRA"
	    DEFINE CELL NAME "RA_ADMISSA" OF oSecMat ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_ADMISSA) }
	    DEFINE CELL NAME "RA_DEMISSA" OF oSecMat ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_DEMISSA) }
  	    IF nAnaSin = 1
	    	DEFINE CELL NAME "VACACIONES" OF oSecMat TITLE "Vacaciones" SIZE 25 BLOCK {|| fSRF(SRA->RA_MAT,IIF(ALLTRIM(DTOS(SRA->RA_DTREC))<>"",DTOS(SRA->RA_DTREC),DTOS(SRA->RA_ADMISSA))) } 
  	    ENDIF
	    DEFINE CELL NAME "PERIODOPAG" OF oSecMat TITLE "Periodo Pago" SIZE 25 BLOCK {||Dtoc(dDtPerIni)+" - "+Dtoc(dDtPerFim)}
	    DEFINE CELL NAME "FECHAPAG"   OF oSecMat TITLE "Fecha Pago" SIZE 25 BLOCK {||DtoC(dDtPago)}
	    DEFINE CELL NAME "RA_DEPTO"	  OF oSecMat TITLE OemToAnsi(STR0007) SIZE 9 BLOCK {|| cDepto := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,3,,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,3,,.T.) )}
		DEFINE CELL NAME "QB_DESCRIC" OF oSecMat TITLE "Departamento" /*OemToAnsi(STR0028)*/ SIZE 20 BLOCK {|| cDescDepto := IIF( nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,3,2,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,3,2,.T.) ) }		
		DEFINE CELL NAME "RA_SEXO"    OF oSecMat TITLE "Sexo" SIZE 10 BLOCK {|| IIF(SRA->RA_SEXO=="M","Masculino","Femenino") } 
		DEFINE CELL NAME "CODFUNC"	  OF oSecMat TITLE OemToAnsi(STR0021) SIZE 5 BLOCK {||cCodFunc}			//"Função"
		DEFINE CELL NAME "DESCFUNC"   OF oSecMat TITLE "Cargo" /*OemToAnsi(STR0028)*/ SIZE 20 BLOCK {||Substr(cDescFunc,1,20) } 
		IF nAnaSin = 1                                                                                                                         
			DEFINE CELL NAME "TIPO"       OF oSecMat TITLE "Tipo" SIZE 20 BLOCK {|| fTabela("S024",fPosTab("S024",SRA->RA_SITTRAB, "=", 4),5) }
			DEFINE CELL NAME "SITUAESP"   OF oSecMat TITLE "Situacion Especial" SIZE 20 BLOCK {|| fTabela("S033",fPosTab("S033",SRA->RA_SITUACI, "=", 4),5) }
			DEFINE CELL NAME "RA_NASC"    OF oSecMat TITLE "Fecha Nacimiento" SIZE 10 BLOCK {|| Dtoc(SRA->RA_NASC) }
			DEFINE CELL NAME "NACIONAL"   OF oSecMat TITLE "Nacionalidad" SIZE 10 BLOCK {|| fTabela("S023",fPosTab("S023",SRA->RA_NACIONA, "=", 4),5) }
	   		DEFINE CELL NAME "DOCUMENTO"  OF oSecMat TITLE "Documento" SIZE 25 BLOCK {|| fTabela("S028",fPosTab("S028",SRA->RA_TPCIC, "=", 4),5) }
		ENDIF
		DEFINE CELL NAME "RA_CC"	  OF oSecMat TITLE  SIZE 9 BLOCK {|| cCentroC := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,2,,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,2,,.T.) )} //busca informação historicas
		DEFINE CELL NAME "CTT_DESC01" OF oSecMat TITLE OemToAnsi(STR0028) SIZE 60 BLOCK {|| cDescCC := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,2,2,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,2,2,.T.) )}
        IF nAnaSin = 1
        	DEFINE CELL NAME "PENSION"    OF oSecMat TITLE "Pension" SIZE 20 BLOCK {|| fTabela("S004",fPosTab("S004",SRA->RA_CODAFP, "=", 4),5) }
			DEFINE CELL NAME "CUSPP"      OF oSecMat TITLE "CUSPP" SIZE 15 BLOCK {|| SRA->RA_CUSPP }
			DEFINE CELL NAME "ESSALUD"    OF oSecMat TITLE "ESSALUD" SIZE 15 BLOCK {|| SRA->RA_NUMINSC }
			DEFINE CELL NAME "MONEDA"     OF oSecMat TITLE "Moneda" SIZE 5 BLOCK {|| SRA->RA_TPMOEDA }
			DEFINE CELL NAME "DIRECCION"  OF oSecMat TITLE "Dirección" SIZE 40 BLOCK {|| ALLTRIM(SRA->RA_ENDEREC) +" Tel "+ ALLTRIM(SRA->RA_TELEFON) } /*+" "+ALLTRIM(SRA->RA_COMPLEM) +" "+ ALLTRIM(SRA->RA_BAIRRO)*/
		ENDIF 
		                                                                                                        
	                   
				
		
			DEFINE CELL NAME "RA_CATFUNC" OF oSecMat ALIAS "SRA" BLOCK {|| SRA->RA_CATFUNC  }
			DEFINE CELL NAME "VALSAL"	  OF oSecMat TITLE OemToAnsi(STR0022) SIZE 20 PICTURE "@E 99,999,999,999.99" ;	//"Sal.: "
			BLOCK {||fBuscaValSal()}			
		
			
		
			
			   	
				If lDepSf
					DEFINE CELL NAME "RA_DEPSF"   OF oSecMat ALIAS "SRA"
				EndIf
			
			
			DEFINE CELL NAME "RA_HRSMES"  OF oSecMat ALIAS "SRA" 
			
			
		   
		
		DEFINE CELL NAME "PERCADT"    OF oSecMat TITLE OemToAnsi(STR0023)	SIZE 3 		//"Perc.Adto.: "
		DEFINE CELL NAME "RA_CIC"     OF oSecMat ALIAS "SRA"
		DEFINE CELL NAME "RA_CURP"    OF oSecMat ALIAS "SRA"
		 
		
	  
		 DEFINE CELL NAME "RA_CIC"      OF oSecMat TITLE  SIZE 15 BLOCK {|| SRA->RA_CIC }
	  	   
		
		
		DEFINE CELL NAME "RA_TSIMSS"  OF oSecMat ALIAS "SRA" 
		DEFINE CELL NAME "RCO_NREPAT" OF oSecMat ALIAS "RCO"   
		
		

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
		
		
			oSecMat:Cell("DESCFUNC"  ):SetCellBreak(.T.)
			oSecMat:Cell("CTT_DESC01"):SetCellBreak(.T.)
			oSecMat:Cell("QB_DESCRIC"):SetCellBreak(.T.)
				
		
		oSecMat:Cell("ESPACO2"   ):SetCellBreak(.T.)
		
		
			
				oSecMat:Cell("RA_CIC"    ):Disable()
				oSecMat:Cell("RCO_NREPAT"):Disable()
				
				
			  
					   oSecMat:Cell("RA_CIC"     ):Disable()      
			 
					oSecMat:Cell("RA_HRSMES" ):SetCellBreak(.T.)
							
			
			
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
		oSecMat:SetDynamicKey(OemToAnsi(STR0002))	//"Matrícula" 

		TRPosition():New(oSecMat,"SRA",nOrdSra,{|| If (nAnaSin == 1 , (cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT, " ")},.T.)
		

	//SECTION 02 
	DEFINE SECTION oSecLan OF oReport TITLE OemToAnsi(STR0026) TABLES "SRC", "SRD", "SRV", "SRA"	//Verbas do Funcionário

		DEFINE CELL NAME "RA_MAT" OF oSecLan ALIAS "SRA"
		DEFINE CELL NAME "PDP"    OF oSecLan TITLE OemToAnsi(STR0027) SIZE 03 PICTURE "@!"	 	//"Cod."
		DEFINE CELL NAME "DESCP"  OF oSecLan TITLE OemToAnsi(STR0028) SIZE 14 PICTURE "@!" 		//"Descrição"
		DEFINE CELL NAME "REFERP" OF oSecLan TITLE OemToAnsi(STR0029) SIZE 08 					//"Ref."
		DEFINE CELL NAME "VALORP" OF oSecLan TITLE OemToAnsi(STR0030) SIZE nSize				//"Valor"
		DEFINE CELL NAME "PIPEP"  OF oSecLan TITLE "|"        BLOCK {||"|"}

		DEFINE CELL NAME "PDD"    OF oSecLan TITLE OemToAnsi(STR0027) SIZE 03 PICTURE "@!"	 	//"Cod."
		DEFINE CELL NAME "DESCD"  OF oSecLan TITLE OemToAnsi(STR0028) SIZE 14 PICTURE "@!" 		//"Descrição"
		DEFINE CELL NAME "REFERD" OF oSecLan TITLE OemToAnsi(STR0029) SIZE 08 					//"Ref."
		DEFINE CELL NAME "VALORD" OF oSecLan TITLE OemToAnsi(STR0030) SIZE nSize				//"Valor"
		DEFINE CELL NAME "PIPED"  OF oSecLan TITLE "|"        BLOCK {||"|"}

		DEFINE CELL NAME "PDB"    OF oSecLan TITLE OemToAnsi(STR0027) SIZE 03 PICTURE "@!"	 	//"Cod."
		DEFINE CELL NAME "DESCB"  OF oSecLan TITLE OemToAnsi(STR0028) SIZE 15 PICTURE "@!" 		//"Descrição"    
		
		
		
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
		oSecLan:SetDynamicKey(OemToAnsi(STR0004))	//"Lançamentos"

	//SECTION 03 
	DEFINE SECTION oSecNom OF oReport TITLE OemToAnsi(STR0040) TABLES "SRA","SQB","CTT","RCO" ORDERS aOrd	//"Filial / Nome"

		DEFINE CELL NAME "ESPACO"     OF oSecNom TITLE "" BLOCK {||" "}		//Recurso alternativo para que a section do funcionário náo saia colada a collection.
		DEFINE CELL NAME "RA_FILIAL"  OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_NOME"    OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_MAT"     OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "CODFUNC"	  OF oSecNom TITLE OemToAnsi(STR0021) SIZE 5 BLOCK {||cCodFunc}			//"Função"
		DEFINE CELL NAME "DESCFUNC"   OF oSecNom TITLE OemToAnsi(STR0028) SIZE 20 BLOCK {||Substr(cDescFunc,1,20)}
        
		DEFINE CELL NAME "RA_CC"	  OF oSecNom TITLE  SIZE 9 BLOCK {|| cCentroC := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,2,,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,2,,.T.) )} //busca informação historicas
		DEFINE CELL NAME "CTT_DESC01" OF oSecNom TITLE OemToAnsi(STR0028) SIZE 60 BLOCK {|| cDescCC := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,2,2,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,2,2,.T.) )}
		DEFINE CELL NAME "RA_DEPTO"	  OF oSecNom TITLE OemToAnsi(STR0007) SIZE 9 BLOCK {|| cDepto := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,3,,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,3,,.T.) )}
		DEFINE CELL NAME "QB_DESCRIC" OF oSecNom TITLE OemToAnsi(STR0028)SIZE 20 BLOCK {|| cDescDepto := IIF( nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,3,2,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,3,2,.T.) ) }
		
		DEFINE CELL NAME "RA_ADMISSA" OF oSecNom ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_ADMISSA) }
		DEFINE CELL NAME "RA_CATFUNC" OF oSecNom ALIAS "SRA" BLOCK {|| SRA->RA_CATFUNC }
		DEFINE CELL NAME "VALSAL"	  OF oSecNom TITLE OemToAnsi(STR0022) SIZE 20 PICTURE "@E 99,999,999,999.99" ;	//"Sal.: "
			BLOCK {||fBuscaValSal()}
		
		    
		 
			If lDepSf
				DEFINE CELL NAME "RA_DEPSF"   OF oSecNom ALIAS "SRA"
			EndIf
		
			DEFINE CELL NAME "RA_HRSMES"  OF oSecNom ALIAS "SRA" 
		 
		
		DEFINE CELL NAME "PERCADT"    OF oSecNom TITLE OemToAnsi(STR0023)	SIZE 3 		//"Perc.Adto.: "
		DEFINE CELL NAME "RA_CIC"     OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_CURP"    OF oSecNom ALIAS "SRA" 
	
		   DEFINE CELL NAME "RA_CIC"      OF oSecNom ALIAS "SRA"
	   
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
		
				   oSecNom:Cell("RA_CIC"     ):Disable() 
		   
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ R106Imp    ³ Autor ³ Tania Bronzeri        ³ Data ³30/11/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ³±±
±±³Descri‡ao ³ Relatorio de Folha de Pagamento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER106                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

If nOrdem == 1		//Matrícula
	oSectFunc 	:= oReport:Section(1) 
ElseIf nOrdem == 2		//Nome
	oSectFunc 	:= oReport:Section(3) 
ElseIf nOrdem == 3		//C.Custo Cadastro + Matrícula
	oSectCttc	:= oReport:Section(4) 
	oSectFunc 	:= oReport:Section(1) 
	If nAnaSin == 1	//Analítico
		oSectFunc:Cell("RA_CC"     ):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable()  
	EndIf
ElseIf nOrdem == 4		//C.Custo Cadastro + Nome
	oSectCttc	:= oReport:Section(4) 
	oSectFunc 	:= oReport:Section(3) 
	If nAnaSin == 1	//Analítico
		oSectFunc:Cell("RA_CC"     ):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable() 
	EndIf
ElseIf nOrdem == 5		//C.Custo Movimento + Matrícula
	oSectCttc	:= oReport:Section(6) 
	oSectFunc 	:= oReport:Section(1) 
	If nAnaSin == 1	//Analítico
		oSectFunc:Cell("RA_CC"     ):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable() 
	EndIf
ElseIf nOrdem == 6		//C.Custo Movimento + Nome
	oSectCttc	:= oReport:Section(6) 
	oSectFunc 	:= oReport:Section(3) 
	If nAnaSin == 1	//Analítico
		oSectFunc:Cell("RA_CC"     ):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable() 
	EndIf
ElseIf nOrdem == 7		//Depto + Matrícula
	oSectDept	:= oReport:Section(5) 
	oSectFunc 	:= oReport:Section(1) 
	oSectDept:Cell("QB_FILIAL" ):Enable()
	If nAnaSin == 1	//Analítico
		oSectFunc:Cell("RA_DEPTO"  ):Disable()
		oSectFunc:Cell("QB_DESCRIC"):Disable()
	EndIf
ElseIf nOrdem == 8		//Depto + Nome
	oSectDept	:= oReport:Section(5) //section(6)
	oSectFunc 	:= oReport:Section(3) //section(4)
	oSectDept:Cell("QB_FILIAL" ):Enable()
	If nAnaSin == 1	//Analítico
		oSectFunc:Cell("RA_DEPTO"  ):Disable()
		oSectFunc:Cell("QB_DESCRIC"):Disable() 
	EndIf
EndIf

oSectFunc:SetName("FUNCIONARIO")
oSectFunc:SetLineCondition( { || Eval(bBlock) } )

cProcesso	:= mv_par01
cRoteiro	:= mv_par02
cPeriodo	:= mv_par03
cPagamento	:= mv_par04
cSituacao	:= mv_par10
cCategoria	:= mv_par11
nTpContr 	:= mv_par12						//Tipo Contrato:  1=Indeterminado; 2=Determinado; 3=Ambos
nAnaSin   	:= mv_par13						//Tipo Relatorio: 1=Analitico; 2=Sintetico
lBrkCc		:= Iif(mv_par14 == 1 .And. mv_par13 == 1,.T.,.F.)	//Salta Pag. quebra C.Custo: 1=Sim; 2=Nao
lBrkDp		:= Iif(mv_par15 == 1 .And. mv_par13 == 1,.T.,.F.)	//Salta Pag. quebra Depto:   1=Sim; 2=Nao
lImpFil  	:= Iif(mv_par16 == 1,.T.,.F.)	//Imprime totais por Filial: 1=Sim; 2=Nao
lImpEmp  	:= Iif(mv_par17 == 1,.T.,.F.)	//Imprime totais por Empr.:  1=Sim; 2=Nao
lImpUni		:= Iif(lImpEmp,.T.,.F.)	//Imprime totais por Unidade de Negocio: se imprime totais por empresa=Sim; senao = Nao
nTipCC   	:= mv_par18						//Tipo Impressao C.Custo: 1=Codigo; 2=Descricao; 3=Ambos
nTipDp		:= mv_par19						//Tipo Impressao Depto:   1=Codigo; 2=Descricao; 3=Ambos
lImpBase	:= Iif(mv_par20 == 1, .T., .F.)	//Imprimir Bases: 		  1=Sim; 2=Nao
lBrkPagFil	:= (MV_PAR23 == 1)

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
	lSumaVerba	:=  .F.



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

If (nAnaSin == 1 .And. !lSint)	//Analítico
	oSectFunc:Cell("PROVDESC"):Enable()
	If lImpBase 
		oSectFunc:Cell("PROVDESC"  ):SetBlock({||OemToAnsi(STR0024)})
			//"        P R O V E N T O S                              D E S C O N T O S                              B A S E S"
	Else	
		oSectLanc:Cell("PDB"    ):SetTitle("")	
		oSectLanc:Cell("DESCB"  ):SetTitle("")	
		oSectLanc:Cell("VALORB" ):SetTitle("")	

		oSectLanc:Cell("PDB"     ):Hide()
		oSectLanc:Cell("DESCB"   ):Hide()
		oSectLanc:Cell("VALORB"  ):Hide()
		oSectFunc:Cell("PROVDESC"):SetBlock({||OemToAnsi(STR0025)})
			//"        P R O V E N T O S                              D E S C O N T O S "
	EndIf 
Else 
	oSectFunc:Cell("PROVDESC"):Disable()
Endif

cNumPg := If (cPagamento == "99" , Nil , cPagamento)

//ESTA FUNÇÃO BUSCA TODOS OS PERIODOS EM ABERTO E FECHADO DOS FUNCIONARIOS
RetPerAbertFech(cProcesso,cRoteiro,cPeriodo,cPagamento,,,@aPerAberto,@aPerFechado)

If Empty(aPerAberto) .And. Empty(aPerFechado)
   MsgAlert(STR0031,STR0032)	//"Nao foi encontrado nenhum periodo" ### "Verifique Parâmetros de Impressão."
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
		cTitulo += " - " + OemToAnsi(STR0033)	//Analítico
	Else 
		cTitulo += " - " + OemToAnsi(STR0034)	//Sintetico
	Endif
	
	If nOrdem == 1
		cTitulo += " - " + OemToAnsi(STR0002)	//Matrícula
	ElseIf nOrdem == 2
		cTitulo += " - " + OemToAnsi(STR0003)	//Nome    
	Else
		oSectFunc:Cell("RA_FILIAL" ):Disable()
	EndIf
	
	oSectFunc:OnPrintLine(bLancamentos)
	oSectLanc:OnPrintLine(bLancamentos)

			
		oSectFunc:Cell("RA_CATFUNC"):SetBlock({||(cAliasFun)->RA_CATFUNC})
	
	
	oSectFunc:Cell("PERCADT"   ):SetBlock({||StrZero((cAliasFun)->RA_PERCADT,3)})
	
Else	//Sintético 
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
	
	
		If lDepSf
			oSectFunc:Cell("RA_DEPSF"  ):Disable()			
		EndIf
	
		oSectFunc:Cell("RA_HRSMES" ):Disable()			
	
	
	oSectFunc:Cell("PERCADT"   ):Disable()			
	oSectFunc:Cell("RA_CIC"    ):Disable()			
	oSectFunc:Cell("RA_CURP"   ):Disable()			

	   oSectFunc:Cell("RA_CIC"     ):Disable()	  
		
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
	DEFINE FUNCTION NAME "UDIFLIQ"    FROM oSectFunc:Cell("PROVDESC") FUNCTION ONPRINT BREAK oBreakDifLiq NO END SECTION NO END REPORT TITLE OemToAnsi(STR0053) PICTURE "@!" FORMULA {|| fCalcDifLiq(oSectLanc:GetFunction("ULIQVALOR"):GetLastValue())}
   		
	oBreakDifLiq:OnBreak({|x,y|cTitFun:=OemToAnsi(STR0054)})	
    oBreakDifLiq:SetTotalText({||cTitFun})
    oBreakDifLiq:SetTotalInLine(.F.)   
EndIf    

If nAnaSin == 1 .And. !lSint	//Analítico
	DEFINE BREAK oBreakFun OF oSectFunc   WHEN {||(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_MAT} 
	DEFINE FUNCTION NAME "UTOTREFERP" FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99"        	//"Ref."
	DEFINE FUNCTION NAME "UTOTVALORP" FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	//"Valor"
	DEFINE FUNCTION NAME "UTOTREFERD" FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0029) PICTURE "@E 999,999.99"  		//"Ref."
	DEFINE FUNCTION NAME "UTOTVALORD" FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"  	//"Valor"
	DEFINE FUNCTION NAME "ULIQDESC"   FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:"
	DEFINE FUNCTION NAME "ULIQVALOR"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("UTOTVALORP"):GetLastValue() - oSectLanc:GetFunction("UTOTVALORD"):GetLastValue()) } 	//"Liquido:"
			
	oBreakFun:OnBreak({|x,y|cTitFun:=OemToAnsi(STR0037)+" "+ x /*Subs(x,3,Len(x)-2)*/})	//"Totais Funcionário "
   	oBreakFun:SetTotalText({||cTitFun})
   	oBreakFun:SetTotalInLine(.F.)    
EndIf    	                                                              

If nOrdem == 7 .Or. nOrdem == 8		//Departamento
	If nAnaSin == 1	//Analítico
		
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
				
	Else			//Sintético   
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
	If nAnaSin == 1	//Analítico
		
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
	Else			//Sintético
		
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
			If nAnaSin == 1 .And. !lSint	//Analítico
				DEFINE BREAK oBreakUnN OF oReport  WHEN  { || Substr((cAliasFun)->RA_FILIAL, nStartUnN, nUnNLength) }   
			Else // Sintético
				DEFINE BREAK oBreakUnN OF oReport   ;
					WHEN { || Substr(oSectFunc:Cell("RA_FILIAL"):GetText(), nStartEmp, nEmpLength) + Substr(oSectFunc:Cell("RA_FILIAL"):GetText(), nStartUnN, nUnNLength) }  
			Endif
		EndIf		

		If lEmpFil   
			If nAnaSin == 1 .And. !lSint	//Analítico
				DEFINE BREAK oBreakEFil OF oReport  WHEN  { || Substr((cAliasFun)->RA_FILIAL, nStartEmp, nEmpLength) }
			Else //Sintético
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

//Permissão Filial
cFiltro += fAjustFil() //Retorna no filtro somente as filiais que o usuário tem acesso

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
If !Empty(mv_par06)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par06
EndIf

//DEPARTAMENTO
If !Empty(mv_par07)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par07
EndIf

//MATRICULA   
If !Empty(mv_par08)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro	+= mv_par08
EndIf

//NOME   
If !Empty(mv_par09)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par09
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
		cTitulo += " + " + OemToAnsi(STR0002)	//Matrícula
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

	

	
		cCpoAdicEsp := "%SRA.RA_FILIAL as CpoVisual%" // SE NAO FOR UM DOS PAISES MENCIONADOS ATRIBUI O CAMPO RA_FILIAL COM UM ALIAS PARA NAO FICAR VAZIO	
	
	
	cJoin1 := "% " + cJoinEsp + cJoinSQB + cJoinC + "%"
	cJoin2 := "% " + cJoinEsp + cJoinSQB + cJoinD + "%"
#IFDEF TOP
	//QUERY cAliasFun
		BeginSql alias cAliasFun

			SELECT SRA.RA_FILIAL,		SRA.RA_MAT,			SRA.RA_NOME,             
			       SRA.RA_PRINOME,		SRA.RA_SECNOME,		SRA.RA_PRISOBR, SRA.RA_SECSOBR,
			       SRA.RA_SEXO,			SRA.RA_NASC,		SRA.RA_NACIONA, SRA.RA_TPCIC,
					SRA.RA_CODAFP,      SRA.RA_CUSPP,		SRA.RA_NUMINSC, SRA.RA_TPMOEDA,
					SRA.RA_ENDEREC,	 	SRA.RA_TELEFON,		SRA.RA_DTREC,
					SRA.RA_BAIRRO, 		SRA.RA_SITUACI, SRA.RA_SITTRAB,
					SRA.RA_DEPTO,		SRA.RA_HRSMES,		SRA.RA_SALARIO,	SRA.RA_SITFOLH,  
					SRA.RA_CATFUNC,		SRA.RA_PERCADT,		SRA.RA_ADMISSA,	%exp:cDepenContr%,	
					SRA.RA_CIC,			
					%exp:cCpoAdicEsp%,
					SRC.RC_FILIAL FILIAL	%exp:cCpoCcRc%, SQB.QB_DESCRIC, SRA.RA_TPCONTR
			FROM %table:SRA% SRA    

			INNER JOIN  %table:SRC% SRC 
			ON 	    SRA.RA_FILIAL = SRC.RC_FILIAL	AND
					SRA.RA_MAT    = SRC.RC_MAT	    
			%exp:cJoin1% 
			WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
			   		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
			   		SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
			   		SRC.RC_PROCES  =   %exp:Upper(cProcesso)%  AND	
			   		SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND  
			   		SRC.RC_ROTEIR  =   %exp:Upper(cRoteiro)%   AND	
			   		SRC.RC_SEMANA  =   %exp:Upper(cPagamento)% AND
					SRA.%notDel% %exp:cFiltroC% AND SRC.%notDel% %exp:cNotDel% AND SRC.%notDel% %exp:cCoalese% 
			UNION

			SELECT SRA.RA_FILIAL,			SRA.RA_MAT,			SRA.RA_NOME,          
			        SRA.RA_PRINOME,			SRA.RA_SECNOME,		SRA.RA_PRISOBR, SRA.RA_SECSOBR,
			        SRA.RA_SEXO,			SRA.RA_NASC,		SRA.RA_NACIONA, SRA.RA_TPCIC, 
			        SRA.RA_CODAFP,			SRA.RA_CUSPP,		SRA.RA_NUMINSC, SRA.RA_TPMOEDA,
					SRA.RA_ENDEREC,	 		SRA.RA_TELEFON,     SRA.RA_DTREC,
					SRA.RA_BAIRRO, 		SRA.RA_SITUACI, SRA.RA_SITTRAB,
					SRA.RA_DEPTO,			SRA.RA_HRSMES,		SRA.RA_SALARIO,	SRA.RA_SITFOLH,  
					SRA.RA_CATFUNC,			SRA.RA_PERCADT,		SRA.RA_ADMISSA,	%exp:cDepenContr%,		
					SRA.RA_CIC,							
					%exp:cCpoAdicEsp%, 
					SRD.RD_FILIAL FILIAL	%exp:cCpoCcRd%,		SQB.QB_DESCRIC,	SRA.RA_TPCONTR
			FROM %table:SRA% SRA    

			INNER JOIN  %table:SRD% SRD
			ON 	    SRA.RA_FILIAL = SRD.RD_FILIAL	AND
					SRA.RA_MAT    = SRD.RD_MAT 		
			%exp:cJoin2%
			WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
			   		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
			   		SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
			   		SRD.RD_PROCES  =   %exp:Upper(cProcesso)%  AND	
			   		SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND  
					SRD.RD_ROTEIR  =   %exp:Upper(cRoteiro)%   AND	
			   		SRD.RD_SEMANA  =   %exp:Upper(cPagamento)% AND
					SRA.%notDel% %exp:cFiltroD% AND SRD.%notDel% %exp:cNotDel% AND SRD.%notDel% %exp:cCoalese%
			ORDER BY %exp:cOrdemFun%

		EndSql
	//END QUERY cAliasFun
#ENDIF
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
			        SRA.RA_PRINOME,			SRA.RA_SECNOME,		  SRA.RA_PRISOBR, 		  SRA.RA_SECSOBR,
					SRA.RA_SEXO,			SRA.RA_NASC,   		  SRA.RA_NACIONA, 		  SRA.RA_TPCIC,
					SRA.RA_CODAFP,			SRA.RA_CUSPP, 	  	  SRA.RA_NUMINSC, 		  SRA.RA_TPMOEDA,
					SRA.RA_ENDEREC,		    SRA.RA_TELEFON,		  SRA.RA_DTREC,
					SRA.RA_BAIRRO, 		  SRA.RA_SITUACI, 		  SRA.RA_SITTRAB,
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
			   		SRC.RC_PROCES  =   %exp:Upper(cProcesso)%  AND	
			   		SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND  
			   		SRC.RC_ROTEIR  =   %exp:Upper(cRoteiro)%   AND	
			   		SRC.RC_SEMANA  =   %exp:Upper(cPagamento)% AND
					SRA.%notDel% %exp:cFiltroC% AND SRV.%notDel% %exp:cNotDel% AND SRC.%notDel% %exp:cCoalese%   
			UNION

			SELECT SRA.RA_FILIAL,          SRA.RA_MAT,           SRA.RA_CC,              SRA.RA_NOME,
			        SRA.RA_PRINOME,		   SRA.RA_SECNOME,		 SRA.RA_PRISOBR, 		 SRA.RA_SECSOBR,
					SRA.RA_SEXO,			SRA.RA_NASC,         SRA.RA_NACIONA, 		 SRA.RA_TPCIC, 
					SRA.RA_CODAFP,			SRA.RA_CUSPP,		 SRA.RA_NUMINSC, 		 SRA.RA_TPMOEDA,
					SRA.RA_ENDEREC,			SRA.RA_TELEFON,		 SRA.RA_DTREC,
					SRA.RA_BAIRRO, 		 SRA.RA_SITUACI, 		 SRA.RA_SITTRAB,
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
			   		SRD.RD_PROCES  =   %exp:Upper(cProcesso)%  AND	
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
			   		SRC.RC_PROCES  =   %exp:Upper(cProcesso)%  AND 	
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
			   		SRD.RD_PROCES  =   %exp:Upper(cProcesso)%  AND	
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
	If nAnaSin	== 1	//Analítico
		oSectCttc:Print()
	Else				//Sintético
		oSectFunc:Print()
	EndIf
ElseIf nOrdem == 7 .Or. nOrdem == 8  
	If nAnaSin	== 1	//Analítico
		oSectDept:Print()
	Else				//Sintético
		oSectFunc:Print()
	EndIf 
EndIf

If lDifLiq .AND. nAnaSin == 1	//Analítico
	//IMPRIME AS DIFERENCAS DE LIQUIDOS
	fImprDifLiq(oReport)
	
	//FINALIZA O RELATORIO PARA IMPRESSAO DAS DIFERENCAS DE LIQUIDOS
	oReport:Finish() 
	oReport:aBreak := {}
	oReport:aCollection := {}
	oReport:aFunction := {}                                         
EndIf

If nAnaSin == 1 .AND. (oReport:nMeter > 0) //Apenas imprimir linha quando há dados no reltório.
	oReport:ThinLine()
	oReport:SkipLine()
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ fImprimeLanca ³ Autor ³ Tania Bronzeri        ³ Data ³06/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Imprime os lancamentos da Folha de Pagamento                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER106                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImprimeLanca(oSelf) 
Local aArea		:= GetArea()
Local aGPSAux	:= {}
Local cPDB		:= ""	//Horas / Dias / Valores
Local cNome     := "" 
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
	
		
	
		oSelf:SetLineStyle(.F.)
		aLanP	:= {}
		aLanD  	:= {}
		aLanB 	:= {}
		
		While (cAliasQry)->(!Eof()) .And. ;
				(cAliasQry)->FILIAL == (cAliasFun)->RA_FILIAL .And. ;
				(cAliasQry)->MAT == (cAliasFun)->RA_MAT
		     // VERIFICAR   
		    cNome:= AllTrim(AllTrim((cAliasQry)->RA_PRISOBR)+" "+AllTrim((cAliasQry)->RA_SECSOBR)+" "+AllTrim((cAliasQry)->RA_PRINOME)+" "+AllTrim((cAliasQry)->RA_SECNOME))
			cPDB:=(cAliasQry)->RV_TIPOCOD
			aNomeFunc := { (cAliasQry)->RA_FILIAL, (cAliasQry)->RA_MAT, cNome } //(cAliasQry)->RA_NOME }
			
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
				oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
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
				oSelf:Cell("DESCP" ):SetValue(aLanP[nCta,2])	//"Descrição"
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
				oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
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
				oSelf:Cell("DESCD" ):SetValue(aLanD[nCta,2])	//"Descrição"
				oSelf:Cell("REFERD"):SetValue(aLanD[nCta,3])	//"Ref."
				oSelf:Cell("VALORD"):SetValue(aLanD[nCta,4])	//"Valor"     
				lImprLine := .T.
			EndIf
		
			If nCta > nMaxB .OR. nCtaB > nMaxB
				oSelf:Cell("VALORB"):SetPicture("")
				oSelf:Cell("PDB"   ):SetValue("")	//"Cod."
				oSelf:Cell("DESCB" ):SetValue("")	//"Descrição"
				
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
					oSelf:Cell("DESCB" ):SetValue("")	//"Descrição"
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
					oSelf:Cell("DESCB" ):SetValue(Substr(aLanB[nCta,2],1,15))	//"Descrição" 
					
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
				//Imprime o total da verba 973 no primeiro funcionário, sem exibir a linha, para que seja somado no totalizador da filial
				For nCta := 1 to Len(aFilB)
	
					oSelf:Cell("REFERP"):Hide()
					oSelf:Cell("VALORP"):Hide()
					oSelf:Cell("PDP"   ):Hide()
					oSelf:Cell("DESCP" ):Hide()
					oSelf:Cell("PIPEP"):Hide()
				
					oSelf:Cell("REFERP"):SetPicture("")
					oSelf:Cell("VALORP"):SetPicture("")
					oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
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
					oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
					oSelf:Cell("REFERD"):SetValue("")	//"Ref."
					oSelf:Cell("VALORD"):SetValue("")	//"Valor"	
								
					oSelf:Cell("VALORB"):Hide()
					oSelf:Cell("PDB"   ):Hide()
					oSelf:Cell("DESCB" ):Hide()
					oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
					oSelf:Cell("PDB"   ):SetValue(aFilB[nCta,1])	//"Cod."
					oSelf:Cell("DESCB" ):SetValue(aFilB[nCta,2])	//"Descrição" 
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
							oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
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
							oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
							oSelf:Cell("REFERD"):SetValue("")	//"Ref."
							oSelf:Cell("VALORD"):SetValue("")	//"Valor" 
										
							oSelf:Cell("VALORB"):Hide()
							oSelf:Cell("PDB"   ):Hide()
							oSelf:Cell("DESCB" ):Hide()
							oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
							oSelf:Cell("PDB"   ):SetValue(aGPSVal[nCta,2])	//"Cod."
							oSelf:Cell("DESCB" ):SetValue(fDesc("SRV", aGPSVal[nCta,2], "RV_DESC"))	//"Descrição" 
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
						oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
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
						oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
						oSelf:Cell("REFERD"):SetValue("")	//"Ref."
						oSelf:Cell("VALORD"):SetValue("")	//"Valor" 
									
						oSelf:Cell("VALORB"):Hide()
						oSelf:Cell("PDB"   ):Hide()
						oSelf:Cell("DESCB" ):Hide()
						oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
						oSelf:Cell("PDB"   ):SetValue(aGPSVal[nCta,2])	//"Cod."
						oSelf:Cell("DESCB" ):SetValue(fDesc("SRV", aGPSVal[nCta,2], "RV_DESC"))	//"Descrição" 
						oSelf:Cell("VALORB"):SetValue(aGPSVal[nCta,5])	//"Valor"
						aGPSAux := {} //Zera aGPSVAL ao término da impressão pois não necessita totalizar por centro de custos
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ fImprSint     ³ Autor ³ Tania Bronzeri        ³ Data ³27/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Imprime os lancamentos da Folha de Pagamento Sintetica          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER106                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
				oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
				oSelf:Cell("REFERP"):SetValue("")	//"Ref."
				oSelf:Cell("VALORP"):SetValue("")	//"Valor"
			Else
				oSelf:Cell("REFERP"):SetPicture("@E 999,999.99")
				oSelf:Cell("VALORP"):SetPicture("@E 99,999,999,999.99")
				oSelf:Cell("PDP"   ):SetValue(aLanP[nCta,1])	//"Cod."
				oSelf:Cell("DESCP" ):SetValue(Substr(aLanP[nCta,2],1,14))	//"Descrição"
				oSelf:Cell("REFERP"):SetValue(aLanP[nCta,3])	//"Ref."
				oSelf:Cell("VALORP"):SetValue(aLanP[nCta,4])	//"Valor"
			EndIf
			If nCta > nMaxD
			
				oSelf:Cell("REFERD"):SetPicture("")
				oSelf:Cell("VALORD"):SetPicture("")
				oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
				oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
				oSelf:Cell("REFERD"):SetValue("")	//"Ref."
				oSelf:Cell("VALORD"):SetValue("")	//"Valor"
			Else
				oSelf:Cell("REFERD"):SetPicture("@E 999,999.99")
				oSelf:Cell("VALORD"):SetPicture("@E 99,999,999,999.99")
				oSelf:Cell("PDD"   ):SetValue(aLanD[nCta,1])	//"Cod."
				oSelf:Cell("DESCD" ):SetValue(Substr(aLanD[nCta,2],1,14))	//"Descrição"
				oSelf:Cell("REFERD"):SetValue(aLanD[nCta,3])	//"Ref."
				oSelf:Cell("VALORD"):SetValue(aLanD[nCta,4])	//"Valor"
			EndIf
			If nCta > nMaxB
				oSelf:Cell("VALORB"):SetPicture("")
				oSelf:Cell("PDB"   ):SetValue("")	//"Cod."
				oSelf:Cell("DESCB" ):SetValue("")	//"Descrição"
				oSelf:Cell("VALORB"):SetValue("")	//"Valor"    
									
			Else 
			   	If !lImpBase 
					oSelf:Cell("VALORB"):Hide()
					oSelf:Cell("PDB"   ):Hide()
					oSelf:Cell("DESCB" ):Hide() 
				EndIf			
				oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
				oSelf:Cell("PDB"   ):SetValue(aLanB[nCta,1])	//"Cod."
				oSelf:Cell("DESCB" ):SetValue(Substr(aLanB[nCta,2],1,15))	//"Descrição"
								
				oSelf:Cell("VALORB"):SetValue(aLanB[nCta,4])	//"Valor"
			EndIf
			If nCta < nMax
				oSelf:PrintLine()
			EndIf
		Next nCta
		
		If lImpBase .and. lImpFil 
			If Len(aFilB) > 0
				//Imprime o total da verba 973 no primeiro funcionário, sem exibir a linha, para que seja somado no totalizador da filial
				For nCta := 1 to Len(aFilB)
				
					oSelf:Cell("REFERP"):Hide()
					oSelf:Cell("VALORP"):Hide()
					oSelf:Cell("PDP"   ):Hide()
					oSelf:Cell("DESCP" ):Hide()
					oSelf:Cell("PIPEP"):Hide()
				
					oSelf:Cell("REFERP"):SetPicture("")
					oSelf:Cell("VALORP"):SetPicture("")
					oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
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
					oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
					oSelf:Cell("REFERD"):SetValue("")	//"Ref."
					oSelf:Cell("VALORD"):SetValue("")	//"Valor" 
								
					oSelf:Cell("VALORB"):Show()
					oSelf:Cell("PDB"   ):Show()
					oSelf:Cell("DESCB" ):Show()
					oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
					oSelf:Cell("PDB"   ):SetValue(aFilB[nCta,1])	//"Cod."
					oSelf:Cell("DESCB" ):SetValue(aFilB[nCta,2])	//"Descrição" 
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
							oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
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
							oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
							oSelf:Cell("REFERD"):SetValue("")	//"Ref."
							oSelf:Cell("VALORD"):SetValue("")	//"Valor" 
										
							oSelf:Cell("VALORB"):Show()
							oSelf:Cell("PDB"   ):Show()
							oSelf:Cell("DESCB" ):Show()
							oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
							oSelf:Cell("PDB"   ):SetValue(aGPSVal[nCta,2])	//"Cod."
							oSelf:Cell("DESCB" ):SetValue(fDesc("SRV", aGPSVal[nCta,2], "RV_DESC"))	//"Descrição" 
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
						oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
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
						oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
						oSelf:Cell("REFERD"):SetValue("")	//"Ref."
						oSelf:Cell("VALORD"):SetValue("")	//"Valor" 
									
						oSelf:Cell("VALORB"):Show()
						oSelf:Cell("PDB"   ):Show()
						oSelf:Cell("DESCB" ):Show()
						oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
						oSelf:Cell("PDB"   ):SetValue(aGPSVal[nCta,2])	//"Cod."
						oSelf:Cell("DESCB" ):SetValue(fDesc("SRV", aGPSVal[nCta,2], "RV_DESC"))	//"Descrição" 
						oSelf:Cell("VALORB"):SetValue(aGPSVal[nCta,5])	//"Valor"
						aGPSAux := {} //Zera aGPSVAL ao término da impressão pois não necessita totalizar por centro de custos
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ fCtrlDtRa  ³ Autor ³ Equipe RH - N3        ³ Data ³01/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Controle de habilitação e desabilitação das células de impre-³±±
±±³         ³ Sessão das datas de Admissão, Readmissão e Reconhecimento.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER106                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function fCtrlDtRA(oSecAux)
Local aArea := GetArea()

dbSelectArea(cAliasFun)    

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


RestArea(aArea)
Return

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
Static Function fGR106join(cTabela1, cTabela2,cEmbedded)
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
±±³Fun‡…cao  ³fGR106Header  ³ Autor ³  Esther Viveiro      ³ Data ³ 30/04/2014        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrica‡…o ³Definição do cabeçalho do relatório.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Parametro ³oReport    - Obrigatorio - objeto com as informações do realtório.      ³±±
±±³          ³nImpressao - Obrigatorio - Define qual tipo de impressão será realizada.³±±
±±³          ³          1 = Cabecalho de página; 2 = Cabecalho da seção sintética.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER106                                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGR106Header(oReport)   
Private cNombreT  := 'Totvs, SRL'
	cTipoContrato := EVAL({||Iif(nTpContr==1,OemToAnsi(STR0013),Iif(nTpContr==2,OemToAnsi(STR0014),OemToAnsi(STR0015)))})
	cDescProc := EVAL({||Substr(PosAlias("RCJ",cProcesso,xFilial("RCJ"),"RCJ_DESCRI"),1,20)})
	cDtPeriodo := EVAL({||Dtoc(dDtPerIni)+"-"+Dtoc(dDtPerFim)})
	
	oReport:PrintText(space(50)+ SM0->M0_NOMECOM,,,,,,.F.) //cNombreT ,,,,,,.F.)
   //	oReport:SkipLine()
	oReport:PrintText(OemToAnsi(STR0012) + cTipoContrato + space(05) + OemToAnsi(STR0016) + cProcesso + ' - RUC: ' + SM0->M0_CGC /*cDescProc*/,/*nRow*/,/*nCol*/,/*nClrText*/,/*cStyle*/,/*nCells*/,.F.) //"Tipo de Cotrato"##"Processo"
	oReport:PrintText(space(40) + RTRIM(SM0->M0_ENDENT)+", "+RTRIM(SM0->M0_CIDENT)+ " Tel. " + RTRIM(SM0->M0_TEL),,,,,,.F.)   //'Av. Benevides 540, Santiago de Surco, Lima, Perú',,,,,,.F.)
	oReport:PrintText(OemToAnsi(STR0017) + cPeriodo + space(05) + OemToAnsi(STR0018) + cPagamento + space(20) + 'D.S. No 001-98-TR' + space(20) + OemToAnsi(STR0019) + cDtPeriodo + space(05) + OemToAnsi(STR0020) + DtoC(dDtPago),/*nRow*/,/*nCol*/,/*nClrText*/,/*cStyle*/,/*nCells*/,.F.)//"Período"##"Pagamento"##"DtPeriodo"##"DtPagto"
	oReport:ThinLine()
	oReport:SkipLine()

Return

/*/{Protheus.doc} fAjustFil
Filtra pelas filiais que o usuário tem acesso.
@Type Function
@author Gabriel Almeida
@since 13/09/2016
@version 2.0
@return cRet, string com as filiais que o usuário possui acesso.
/*/
Static Function fAjustFil()

	Local cRet      := " RA_FILIAL IN( "
	Local cFiltFil  := "%" + AllTrim(MV_PAR05) + "%"
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


/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH¿
//³Función: fBusPerVac                                         ³
//³                                                            ³
//³Descripción: Busca el periodo de vacaciones del año en curso³
//³                                                            ³
//³Fecha: 09/11/2017                                           ³
//³                                                            ³
//³Autor: Abdiel Trejo                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄHÙ
ENDDOC*/

Static Function fSRF(cMAT,CADMISSA)
 
Local cDatas := ""
Local TRB6         := GetNextAlias()   
Local cQuery6    := ""
Local cDta       := substr(cPeriodo,1,4) + substr(CADMISSA,5,4)

//-->Query para sacar la informacion de fechas de vacaciones
    cQuery6 := "SELECT RF_FILIAL, RF_MAT, RF_DATABAS, RF_DATAFIM "
    cQuery6 += " FROM " + "SRF" +Alltrim(SM0->M0_CODIGO)+"0" +" SRF "
    cQuery6 += "WHERE RF_MAT = '" + cMAT + "' " 
    cQuery6 += "AND RF_DATABAS <= '" + cDta + "' "
    cQuery6 += "AND SRF.D_E_L_E_T_ = ' ' "
    cQuery6 += "Order By RF_MAT,RF_DATABAS "
    cQuery6 := ChangeQuery(cQuery6)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery6),TRB6,.F.,.T.)

    DbSelectArea(TRB6)
    

    While !(TRB6)->(Eof())
   
      cDatas := dtoc(stod((TRB6)->RF_DATABAS)) + "-" + dtoc(stod((TRB6)->RF_DATAFIM))
           
      (TRB6)->(dbSkip())
    EndDo
   
    (TRB6)->(DBCLOSEAREA())  

Return cDatas




