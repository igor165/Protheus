#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER065.CH"
#INCLUDE "report.ch"

Static lTemCCT

/*                                                                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPER065  ³ Autor ³ Leandro Drumond                        ³ Data ³ 28.02.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER065(void)                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de Outros Beneficios                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Uso       ³ Generico                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         		ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programador ³   Data   ³ BOPS / Chamado ³  Motivo da Alteracao                            ³±±
±±³Luis Artuso ³ 15/07/15 ³         TSUKL4 ³  Ajuste na picture do valor base.				 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/               
Function GPER065()
Local aArea 			:= GetArea() 
Local oReport

Private cCodVale	    := ""
Private cDesVale  	 	:= ""
Private cTipRel  	 	:= "0"   
Private nTpVale			:= 0
Private nValUnitario 	:= 0
Private nValTot 	    := nValeDif := 0
Private nQtdeVale  		:= nValUnAn := nValUnAt := 0
Private nCustFun 		:= nCustEmp := nTotCust := 0
Private nValor6			:= nValor7  := 0
Private cAliasQry		:= "SRA"
Private cAliasRel   	:= "RIQ"
Private lPerFech    	:= .T.
Private cRoteir     	:= "" 
Private cRot			:= "" 
Private cCodCCT 		:= ""
Private cPerg			:= "GPR065"

DEFAULT lTemCCT 		:= fChkCCT(cPerg)

Pergunte(cPerg,.F.)

cRot 		:= cRoteir := fGetCalcRot('I')
cProcesso 	:= mv_par01
    
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef  ³ Autor ³ Leandro Drumond       ³ Data ³28/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Outros Beneficios                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPER065                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
Local oReport 
Local oSection1 
Local oSection2        
Local cDesc1    := ""	
Local cFilRCH	:= xFilial("RCH")
Local cRepProc  := mv_par01
Local cRepPer   := mv_par02
Local cRepNmPg  := mv_par03

Private aOrd    := {}	
Private cTitulo	:= ""  
	
fPerBene(cRepProc, cRepPer, cRepNmpg, cRoteir)

aOrd := {OemToAnsi(STR0003),OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008)}	
             //"Matricula","Nome","C. Custo + Matricula","C.Custo + Nome","Depto. + Matricula","Depto. + Nome"

If lTemCCT
	Aadd(aOrd, OemToAnsi(STR0025)) //"CCT + Filial + Centro Custo"
EndIf
                    
cDesc1	:= OemToAnsi(STR0001) //"Relatório de Outros Beneficios será impresso de acordo com os parâmetros informados pelo usuário."
cTitulo	:= OemToAnsi(STR0002) 	//"Relatório de Outros Beneficios"

DEFINE REPORT oReport NAME "GPER065" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| GR065Imp(oReport)} DESCRIPTION OemToAnsi(STR0009)
//"Esta rotina gera um relatório com as informações do cálculo de Outros Beneficios"

DEFINE SECTION oSRA OF oReport TITLE OemToAnsi(STR0010) ORDERS aOrd TABLES "SRA" TOTAL IN COLUMN TOTAL TEXT STR0010

DEFINE CELL NAME "RA_FILIAL"  	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_FILIAL}
DEFINE CELL NAME "RA_CC"	  	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_CC}
DEFINE CELL NAME "RA_DEPTO" 	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_DEPTO}
DEFINE CELL NAME "RA_PROCES"  	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_PROCES}
DEFINE CELL NAME "RA_MAT"	  	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_MAT}
DEFINE CELL NAME "RA_NOME"	  	OF oSRA ALIAS "SRA"	SIZE 20	BLOCK {|| (cAliasQry)->RA_NOME}

If lTemCCT
	DEFINE CELL NAME "CODCCT"   OF oSRA BLOCK {|| cCodCCT } TITLE OemToAnsi(STR0026) //"Conv. Colet. Trab."
EndIf
oSRA:SetHeaderBreak(.T.)

DEFINE SECTION oRIQ OF oReport  TITLE OemToAnsi(STR0010) ORDERS aOrd TABLES cAliasRel TOTAL IN COLUMN TOTAL TEXT  STR0010

DEFINE CELL NAME "TIPO"	        OF oRIQ TITLE STR0011 BLOCK {|| cTpBen	+ " - " + cDescTpBen } ALIGN LEFT 
DEFINE CELL NAME "CODIGO"       OF oRIQ TITLE STR0012 BLOCK {|| cCodBen	+ " - " + cDesCdBen	 } ALIGN LEFT 
DEFINE CELL NAME "VLBASE"		OF oRIQ TITLE STR0021 BLOCK {|| nVlBase   }		PICTURE "@E 99,999.99"
DEFINE CELL NAME "VLBENEF"		OF oRIQ TITLE STR0013 BLOCK {|| nVlBenef   }	PICTURE "@E 999,999,999.99"
DEFINE CELL NAME "VLDESC"	  	OF oRIQ TITLE STR0014 BLOCK {|| nVlDesc }      	PICTURE "@E 999,999,999.99"
DEFINE CELL NAME "VLEMP" 		OF oRIQ TITLE STR0015 BLOCK {|| nVlEmp } 		PICTURE "@E 999,999,999.99"

oRIQ:SetHeaderBreak(.T.)
	
Return( oReport )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GR065Imp  ºAutor  ³Leandro Drumond     º Data ³ 28/02/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressão Mapa de Benefícios                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPER009                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GR065Imp(oReport)
Local oSection1 	:= oReport:Section(1)
Local oSection2 	:= oReport:Section(2)  
Local cSitQuery		:= ""
Local cCatQuery		:= ""  
Local cTitFil  		:= ""
Local cTitCc   		:= ""
Local cTitDP		:= ""

//Variaveis de Acesso do Usuario
Local cAcessaSRA	:= &( " { || " + ChkRH( "GPER065" , "SRA" , "2" ) + " } " )
Local cAcessaRIQ	:= ""
Local nReg			:= 0
Local lPass     	:= .T.

Private nOrdem	   	:= oSection1:GetOrder()
Private cProc       := mv_par01
Private cPeriodo    := mv_par02    // 	Periodo
Private cNumPag     := mv_par03    // 	Nro pagamento
Private cTpBenef	:= mv_par09
Private lSalta      := .F.
Private cSituacao   := mv_par10        //  Situacoes
Private cCategoria  := mv_par11        //  Categorias
Private cCCT 		:= ""

If lTemCCT
	MakeAdvPlExpr(cPerg)
	cCCT 		:= Replace(MV_PAR12, "RCE_CCT", If(cAliasRel=="RIQ", "RIQ_CODCCT", "RIR_CODCCT"))
EndIf

If Empty(cNumPag) .or. Empty(cProc) .or. Empty(cPeriodo)
	MsgAlert(OemToAnsi(STR0024), OemToAnsi(STR0023)) //"Processo + Período + Número de Pagamento não encontrado" ###"Atencao"
EndIf

If lPerFech 
    cAcessaRIQ := &( " { || " + ChkRH( "GPER065" , "RIR" , "2" ) + " } " )
Else
    cAcessaRIQ := &( " { || " + ChkRH( "GPER065" , "RIQ" , "2" ) + " } " )
EndIf

oSection2:SetLeftMargen(60)
//Totalizador de Funcionario
oBreakFunc 	:= TRBreak():New(oSection1, oSection1:Cell("RA_MAT"),STR0016, .F.)

DEFINE FUNCTION FROM oSection2:Cell("VLBENEF") 		FUNCTION SUM BREAK oBreakFunc TITLE STR0016  	PICTURE "@E 99,999.99" 		NO END SECTION NO END REPORT
DEFINE FUNCTION FROM oSection2:Cell("VLDESC")  		FUNCTION SUM BREAK oBreakFunc TITLE STR0016  	PICTURE "@E 99,999.99" 		NO END SECTION NO END REPORT
DEFINE FUNCTION FROM oSection2:Cell("VLEMP")  		FUNCTION SUM BREAK oBreakFunc TITLE STR0016  	PICTURE "@E 99,999.99" 		NO END SECTION NO END REPORT

If nOrdem == 3 .OR. nOrdem == 4
	lSalta      := If(mv_par07 == 1 , .T. , .F.)    //  Imprime C.C em outra Pagina
	oBreakCC 	:= TRBreak():New(oSection1, {||(cAliasQry)->RA_FILIAL + (cAliasQry)->RA_CC},STR0017, .F.,, lSalta)
	oBreakCC:OnBreak({|x,y|,cTitCC:=OemToAnsi(STR0017)+"  "+x}) //TOTAL C. CUSTO
	oBreakCC:SetTotalText({||cTitCC})

	DEFINE FUNCTION oCCBenef   	NAME "CCBENEF" FROM oSection2:Cell("VLBENEF") FUNCTION SUM BREAK oBreakCC TITLE "" OF oSection2	NO END SECTION NO END REPORT
	DEFINE FUNCTION oCCDesc   	NAME "CCDESC"  FROM oSection2:Cell("VLDESC")  FUNCTION SUM BREAK oBreakCC TITLE "" OF oSection2	NO END SECTION NO END REPORT
	DEFINE FUNCTION oCCEmp   	NAME "CCEMP"   FROM oSection2:Cell("VLEMP")   FUNCTION SUM BREAK oBreakCC TITLE "" OF oSection2	NO END SECTION NO END REPORT
	
EndIf

If nOrdem == 5 .OR. nOrdem == 6
	oBreakDP 	:= TRBreak():New(oSection1, {||(cAliasQry)->RA_FILIAL + (cAliasQry)->RA_DEPTO},STR0019, .F.)
	oBreakDP:OnBreak({|x,y|,cTitDP:=OemToAnsi(STR0019)+"  "+x}) //TOTAL DEPARTAMENTO
	oBreakDP:SetTotalText({||cTitDP})

	DEFINE FUNCTION oDPBenef   	NAME "DPBENEF" FROM oSection2:Cell("VLBENEF") FUNCTION SUM BREAK oBreakDP TITLE "" OF oSection2	NO END SECTION NO END REPORT
	DEFINE FUNCTION oDPDesc   	NAME "DPDESC"  FROM oSection2:Cell("VLDESC")  FUNCTION SUM BREAK oBreakDP TITLE "" OF oSection2	NO END SECTION NO END REPORT
	DEFINE FUNCTION oDPEmp   	NAME "DPEMP"   FROM oSection2:Cell("VLEMP")   FUNCTION SUM BREAK oBreakDP TITLE "" OF oSection2	NO END SECTION NO END REPORT
	
EndIf

//Totalizador de Filial
oBreakFil	:= TRBreak():New(oSection1, oSection1:Cell("RA_FILIAL"),STR0020, .F.,,.T.)

oBreakFil:OnBreak({|x,y|cTitFil:=OemToAnsi(STR0020)+" "+x})
oBreakFil:SetTotalText({||cTitFil})

DEFINE FUNCTION oVlBenef   	NAME "VLBENEF" FROM oSection2:Cell("VLBENEF") FUNCTION SUM BREAK oBreakFil TITLE "" OF oSection2	NO END SECTION NO END REPORT
DEFINE FUNCTION oVlDesc   	NAME "VLDESC"  FROM oSection2:Cell("VLDESC")  FUNCTION SUM BREAK oBreakFil TITLE "" OF oSection2	NO END SECTION NO END REPORT
DEFINE FUNCTION oVlEmp   	NAME "VLEMP"   FROM oSection2:Cell("VLEMP")   FUNCTION SUM BREAK oBreakFil TITLE "" OF oSection2	NO END SECTION NO END REPORT

If lTemCCT .and. nOrdem == 7
	DEFINE BREAK oBreakCCT OF oSection1 WHEN {|| cCodCCT } 	TITLE OemToAnsi(STR0027) //"Total Conv. Colet. Trab."
	DEFINE FUNCTION NAME "CCTCAL"    FROM oSection2:Cell("VLBENEF") FUNCTION SUM BREAK oBreakCCT NO END SECTION NO END REPORT TITLE "" PICTURE GetSx3Cache( "R0_VALCAL" , "X3_PICTURE" )
	DEFINE FUNCTION NAME "CCTFUN"    FROM oSection2:Cell("VLDESC") FUNCTION SUM BREAK oBreakCCT NO END SECTION NO END REPORT TITLE "" PICTURE GetSx3Cache( "R0_VLRFUNC" , "X3_PICTURE" )
	DEFINE FUNCTION NAME "CCTEMP"    FROM oSection2:Cell("VLEMP") FUNCTION SUM BREAK oBreakCCT NO END SECTION NO END REPORT TITLE "" PICTURE GetSx3Cache( "R0_VLREMP" , "X3_PICTURE" )
EndIf

oSection2:SetHeaderBreak(.T.)

cAliasQry := GetNextAlias()

//Modifica variaveis para a Query 
cSitQuery := ""
For nReg:=1 to Len(cSituacao)
	cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cSituacao)
		cSitQuery += "," 
	EndIf
Next nReg        
cSitQuery := "%" + cSitQuery + "%"
	
cCatQuery := ""
For nReg:=1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCategoria)
		cCatQuery += "," 
	EndIf
Next nReg  
      
cCatQuery := "%" + cCatQuery + "%"
   
//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)
			
oSection1:BeginQuery()
	
If nOrdem == 1
	cOrdem := "%SRA.RA_FILIAL,SRA.RA_MAT%"
ElseIf nOrdem == 2
	cOrdem := "%SRA.RA_FILIAL,SRA.RA_NOME%"
ElseIf nOrdem == 3
	cOrdem := "%SRA.RA_FILIAL,SRA.RA_CC,SRA.RA_MAT%"
ElseIf nOrdem == 4
	cOrdem := "%SRA.RA_FILIAL,SRA.RA_CC,SRA.RA_NOME%"
ElseIf nOrdem == 5
	cOrdem := "%SRA.RA_FILIAL,SRA.RA_DEPTO,SRA.RA_MAT%"
ElseIf nOrdem == 6
	cOrdem := "%SRA.RA_FILIAL,SRA.RA_DEPTO,SRA.RA_NOME%"
ElseIf nOrdem == 7
	cOrdem := "%SRA.RA_SINDICA,SRA.RA_FILIAL,SRA.RA_CC%"
EndIf

BEGIN REPORT QUERY oSection1	
	BeginSql alias cAliasQry
		SELECT RA_FILIAL, RA_MAT,RA_SITFOLH, RA_CATFUNC, RA_CC, RA_PROCES, RA_NOME, RA_DEPTO
		FROM %table:SRA% SRA
		WHERE SRA.RA_SITFOLH	IN	(%exp:Upper(cSitQuery)%)	AND
			SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%)	AND
			SRA.%notDel%
		ORDER BY %exp:cOrdem%
	EndSql    
END REPORT QUERY oSection1 PARAM mv_par04, mv_par05, mv_par06, mv_par08

oSection1:EndQuery()

//Utiliza a query do Pai  
oSection1:SetParentQuery(.T.)
	
//Define o total da regua da tela de processamento do relatorio
oReport:SetMeter( 200 )  

oReport:SetTitle(OemToAnsi(STR0002))

oSection1:Init()
oSection2:Init()

dbSelectArea(cAliasQry)

While !EOF() 
	//Movimenta Regua Processamento                                
	oReport:IncMeter(1)
	lPass := .T.
	                                   
	//Cancela impressao                                            
	If oReport:Cancel()
		Exit
	EndIf 
	
	//Verifica se func. tem  V.T.                                  
   If cAliasRel=="RIQ" 
		DbSelectArea("RIQ")
		RIQ->(dbSetOrder(RetOrder("RIQ", "RIQ_FILIAL+RIQ_MAT+RIQ_PROCES+RIQ_ROTEIR+RIQ_PERIOD+RIQ_NUMPAG+RIQ_TPBENE+RIQ_COD")))
		If !(RIQ->(dbSeek((cAliasQry)->RA_FILIAL + (cAliasQry)->RA_MAT + (cAliasQry)->RA_PROCES + cRoteir + cPeriodo + cNumPag ) ) )
			dbSelectArea(cAliasQry)
			dbSkip()
	     	Loop
		EndIf 
	Else
		DbSelectArea("RIR")
		RIR->(dbSetOrder(RetOrder("RIR", "RIR_FILIAL+RIR_MAT+RIR_PROCES+RIR_ROTEIR+RIR_PERIOD+RIR_NUMPAG+RIR_TPBENE+RIR_COD")))
		If !(RIR->(dbSeek((cAliasQry)->RA_FILIAL + (cAliasQry)->RA_MAT + (cAliasQry)->RA_PROCES + cRoteir + cPeriodo + cNumPag))) 	    
			dbSelectArea(cAliasQry)
			dbSkip()
	     	Loop
		EndIf 	
	EndIf

	If lTemCCT .And. !Empty(cCCT) .And. !(cAliasRel)->( &(cCCT) )
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf

	//Consiste Filiais e Acessos
	If !( (cAliasQry)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
		dbSelectArea(cAliasQry)
		dbSkip()
     	Loop
	EndIf

	If !((cAliasQry)->RA_SITFOLH $ cSituacao) .Or. !((cAliasQry)->RA_CATFUNC $ cCategoria)
		dbSelectArea(cAliasQry)
		dbSkip()
     	Loop
	EndIf
   
   	If cAliasRel=="RIQ"
		DbSelectArea("RIQ")
		While !Eof() .And. ( (cAliasQry)->RA_FILIAL + (cAliasQry)->RA_MAT + cPeriodo + cNumPag == RIQ->RIQ_FILIAL + RIQ->RIQ_MAT + RIQ_PERIOD + RIQ_NUMPAG)
	 	    
			If !Empty(cTpBenef) .and. !(RIQ->RIQ_TPBENE $ cTpBenef)
				dbSelectArea("RIQ")
			   	RIQ->( dbSkip()) 
	    	   	Loop
			EndIf
	                                            
			//Consiste Filiais e Acessos
			If !( RIQ->RIQ_FILIAL $ fValidFil() ) .or. !Eval( cAcessaRIQ )
			 	dbSelectArea("RIQ")
			   	RIQ->( dbSkip()) 
				Loop
			EndIf
			 
			cTpBen 		:= RIQ->RIQ_TPBENE
			cDescTpBen	:= fDescRCC("S011",RIQ->RIQ_TPBENE,1,2,3,30)
			cCodBen		:= RIQ->RIQ_COD
			cDesCdBen	:= FDESC('RIS',RIQ->RIQ_TPBENE+RIQ->RIQ_COD,'RIS_DESC')
			nVlBase		:= RIQ->RIQ_VALCAL
			nVlBenef	:= RIQ->RIQ_VALBEN
			nVlDesc		:= RIQ->RIQ_VLRFUN
			nVlEmp		:= RIQ->RIQ_VLREMP
			If lTemCCT
				cCodCCT 	:= RIQ->RIQ_CODCCT
			EndIf
		
		  	If lPass
			   //Incializa impressao   
			   oSection1:PrintLine()
			   lPass := .F.
   		  	EndIf
	                
		  	oSection2:PrintLine()
	
		  	dbSelectArea("RIQ")
		  	RIQ->( dbSkip() ) 
		EndDo
	Else 
	    DbSelectArea("RIR")
	    While !Eof() .And. ( (cAliasQry)->RA_FILIAL + (cAliasQry)->RA_MAT + cPeriodo + cNumPag == RIR->RIR_FILIAL + RIR->RIR_MAT + RIR->RIR_PERIOD + RIR->RIR_NUMPAG )
                                            
			If !Empty(cTpBenef) .and. !(RIR->RIR_TPBENE $ cTpBenef)
				dbSelectArea("RIR")
			   	RIR->( dbSkip()) 
	    	   	Loop
			EndIf
		    //Consiste Filiais e Acessos
 		    If !( RIR->RIR_FILIAL $ fValidFil() ) .or. !Eval( cAcessaRIQ )
			     dbSelectArea("RIR")
		   	     RIR->( dbSkip()) 
    	   	     Loop
		    EndIF                                         
		
			cTpBen 		:= RIR->RIR_TPBENE
			cDescTpBen	:= fDescRCC("S011",RIR->RIR_TPBENE,1,2,3,30)
			cCodBen		:= RIR->RIR_COD
			cDesCdBen	:= FDESC('RIS',RIR->RIR_TPBENE+RIR->RIR_COD,'RIS_DESC')
			nVlBase		:= RIR->RIR_VALCAL
			nVlBenef	:= RIR->RIR_VALBEN
			nVlDesc		:= RIR->RIR_VLRFUN
			nVlEmp		:= RIR->RIR_VLREMP		
			If lTemCCT
				cCodCCT 	:= RIR->RIR_CODCCT
			EndIf
		    
		    If lPass
			     //Incializa impressao   
			     oSection1:PrintLine()
			     lPass := .F.
   		    EndIf
                
		    oSection2:PrintLine()

		    dbSelectArea("RIR")
	 	    RIR->( dbSkip() ) 
	    Enddo
   	EndIf 
   	dbSelectArea(cAliasQry)
	dbSkip()
	lPass := .T.
EndDo

//Termino do relatorio                                         
oSection1:Finish()
oSection2:Finish() 

Return( Nil ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ fPerBene º Autor ³ Leandro Drumond    º Data ³ 28/02/2014  º±±
±±ÃÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica periodo do beneficio.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPER009                                                    º±±
±±ÀÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fPerBene(cBeneProc, cBenePer, cBeneNmpg, cBeneRot)
Local cFilRCH	   := xFilial("RCH")

	DbSelectArea("RCH")
	RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" ) ) )
	RCH->( dbSeek( cFilRCH + cBeneProc + cBenePer + cBeneNmPg + cBeneRot, .F. ) )
	If RCH->( !Eof() )
		If !Empty(RCH->RCH_DTFECH)
		    cAliasRel := "RIR"
		    lPerFech  := .T.
		Else //periodo atual
		    cAliasRel   := "RIQ"
		    lPerFech  := .F.
		EndIf
	EndIf 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³GpR065Per   	³ Autor ³ Leandro Drumond   ³ Data ³ 28.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valid do pergunte periodo.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function  GpR065Per(cPeriodo)

Local aArea := GetArea()
Local cFil := FWxFilial("RCH")
Local lRet := .T.	

DbSelectArea("RCH")
DbSetOrder(RetOrder ("RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER"))

lRet := DbSeek(cFil+mv_par01+cRot+cPeriodo)

If !lRet
	MsgAlert(OemToAnsi(STR0022), OemToAnsi(STR0023)) //"Periodo nao encontrado!"###"Atencao"
Endif

RestArea(aArea) 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³GpR065SetVar 	³ Autor ³ Leandro Drumond   ³ Data ³ 05.03.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seta variavel cProcesso para filtro do periodo			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gpr065SetVar()

cProcesso := &(ReadVar())

Return .T.

/*/{Protheus.doc} fChkCCT
//Verifica se a pergunta e campos da CCT existem
@author Leandro Drumond
@since 04/07/2022
/*/
Static Function fChkCCT(cPerg)
Local lRet 		:= .F.
Local oSX1

If RIQ->(ColumnPos("RIQ_CODCCT")) > 0
	//Verifica se existe a pergunta GPCR14
	oSX1 := FWSX1Util():New()
	oSX1:AddGroup(cPerg)
	oSX1:SearchGroup()
	
	If (Len(oSX1:aGrupo) >= 1 .And. Len(oSX1:aGrupo[1][2]) >= 12)
		lRet := .T.
	EndIf

	FreeObj(oSX1)
EndIf

Return lRet
