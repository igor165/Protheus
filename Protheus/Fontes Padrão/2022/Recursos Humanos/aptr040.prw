#INCLUDE "APTR040.CH"
#INCLUDE "protheus.ch"      
#INCLUDE "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³APTR040     º Autor ³ Tania Bronzeri               º Data ³  06/07/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Demonstrativo de Resultados dos Pleitos                                º±±
±±º          ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Processos Trabalhistas                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Cecilia C.³04/08/2014³TQEQ39³Incluido o fonte da 11 para a 12 e efetuda a limpeza. ³±±  
±±³Renan B.  ³24/12/2015³TUBNND³Ajuste para gerar relatório de "Resultados dos plei-  ³±±  
±±³          ³          ³      ³tos" em base que não possua grupo de empresas.        ³±±  
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function APTR040()
Local	oReport   
Local	aArea 	:= GetArea()
Private	cString	:= "REL "				// alias do arquivo principal (Base)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("APT40R",.F.) 

oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Tania Bronzeri        ³ Data ³26/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Resultados de Pleitos por tipo                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ APTR040                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APTR040 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
Local oReport 
Local oSection1 
Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0002) + OemToAnsi(STR0003)	
	//"Demonstrativo de Resultados dos Pleitos" ### "Ser  impresso de acordo com os parametros solicitados pelo"  ### "usu rio."
Private aOrd    := {STR0010}	//"Tipo Pleito"
Private cTitulo	:= OemToAnsi(STR0001)			//"Demonstrativo de Resultados dos Pleitos"
Private cPerg   := "APT40R"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao dos componentes de impressao                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE REPORT oReport NAME "APTR040" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| R040Imp(oReport)} DESCRIPTION OemtoAnsi(STR0006) TOTAL IN COLUMN	
//"Este programa emite relatorio de Pleitos por Resultado."

	DEFINE SECTION oSection1 OF oReport TITLE OemToAnsi(STR0015) TABLES "REL","RE5" TOTAL IN COLUMN ORDERS aOrd	//Relacao dos Pleitos
		DEFINE CELL NAME "REL_FILIAL" OF oSection1 ALIAS "REL"
		DEFINE CELL NAME "REL_TPPLT" OF oSection1 ALIAS "REL"
		DEFINE CELL NAME "RE5_DESCR" OF oSection1 ALIAS "RE5"
		DEFINE CELL NAME "NPROCED"   OF oSection1 TITLE OemToAnsi(STR0011) PICTURE "@E 9999" 	//	Procedente
		DEFINE CELL NAME "NIMPROCED" OF oSection1 TITLE OemtoAnsi(STR0012) PICTURE "@E 9999" 	//	Improcedente
		DEFINE CELL NAME "NAGUARD"	 OF oSection1 TITLE OemToAnsi(STR0013) PICTURE "@E 9999" 	//	Aguard.Decisao
		DEFINE CELL NAME "NTOTPLTS"	 OF oSection1 TITLE OemToAnsi(STR0014) PICTURE "@E 9999" 	//	Total PLeitos
        
		DEFINE FUNCTION FROM oSection1:Cell("REL_FILIAL") FUNCTION COUNT	NO END SECTION
		DEFINE FUNCTION FROM oSection1:Cell("REL_TPPLT") FUNCTION COUNT	NO END SECTION
		DEFINE FUNCTION FROM oSection1:Cell("RE5_DESCR") FUNCTION COUNT	NO END SECTION
		DEFINE FUNCTION FROM oSection1:Cell("NPROCED")   FUNCTION SUM	NO END SECTION
		DEFINE FUNCTION FROM oSection1:Cell("NIMPROCED") FUNCTION SUM 	NO END SECTION
		DEFINE FUNCTION FROM oSection1:Cell("NAGUARD")   FUNCTION SUM 	NO END SECTION
		DEFINE FUNCTION FROM oSection1:Cell("NTOTPLTS")  FUNCTION SUM 	NO END SECTION
	                                                                                              
		TRPosition():New(oSection1,"RE5",1,{|| xFilial("RE5",REL->REL_FILIAL)+cString+REL->REL_TPPLT})

Return(oReport)


Static Function R040Imp(oReport)

Local oSection1 := oReport:Section(1)
Local cFiltro 	:= "" 
Local cAliasQry	:= ""
Local cAliasRe0	:= ""
Local cRProc	:= ""
Local cRImpr	:= ""
Local cRAguar	:= ""  
Local nNx		:= 0
Local nNu		:= 0
Local nRProc	:= 0
Local nRImpr	:= 0
Local nRAguar	:= 0
Local cResult	:= ""
Local cProNum	:= "" 
Local lValido	:= .T. 
Local lQuery	:= .F.
Local cTpPlt	:= "" 
Local cFilProc	:= ""
Local cFilPlei	:= ""
Local cTitFil	:= ""
Local cNomEmpFil:= ""

Private cOrdem		:= ""
Private dDataDe		:=	mv_par04						//  Data Processo De
Private dDataAte	:=	mv_par05   						//  Data Processo Ate
Private cProcede	:= If( Empty(mv_par07),"", AllTrim(mv_par07) )	//	Pleitos Procedentes
Private cImprocede	:= If( Empty(mv_par08),"", AllTrim(mv_par08) )	//	Pleitos Improcedentes
Private cAguardo	:= If( Empty(mv_par09),"", AllTrim(mv_par09) )	//	Pleitos Aguardando Decisao

DEFINE BREAK oBreakFil OF oSection1 WHEN oSection1:Cell("REL_FILIAL") TITLE OemToAnsi(STR0018)	// "TOTAL DA FILIAL"
DEFINE FUNCTION FROM oSection1:Cell("REL_FILIAL")	FUNCTION COUNT	BREAK oBreakFil NO END REPORT NO END SECTION 
DEFINE FUNCTION FROM oSection1:Cell("REL_TPPLT")	FUNCTION COUNT	BREAK oBreakFil NO END REPORT NO END SECTION
DEFINE FUNCTION FROM oSection1:Cell("RE5_DESCR")  	FUNCTION COUNT	BREAK oBreakFil NO END REPORT NO END SECTION
DEFINE FUNCTION FROM oSection1:Cell("NPROCED")		FUNCTION SUM	BREAK oBreakFil PICTURE "@E 9999" NO END REPORT NO END SECTION
DEFINE FUNCTION FROM oSection1:Cell("NIMPROCED")	FUNCTION SUM 	BREAK oBreakFil	PICTURE "@E 9999" NO END REPORT NO END SECTION
DEFINE FUNCTION FROM oSection1:Cell("NAGUARD")		FUNCTION SUM 	BREAK oBreakFil	PICTURE "@E 9999" NO END REPORT NO END SECTION
DEFINE FUNCTION FROM oSection1:Cell("NTOTPLTS")		FUNCTION SUM 	BREAK oBreakFil	PICTURE "@E 9999" NO END REPORT NO END SECTION

oBreakFil:OnBreak({|x,y|cTitFil:=OemToAnsi(STR0018)+" " + x + " " + If(fBuscaFil(,x,@cNomEmpFil),cNomEmpFil,"")})
oBreakFil:SetTotalText({||cTitFil})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a string de Tipos de Resultados a serem considerados   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRProc := ""
For nNx := 1 to Len(cProcede)
	nNu ++
	cRProc += Subs(cProcede,nNx,1)
	If nNu == 6
		cRProc += "*"
		nNu := 0
	EndIf
Next nNx

cRImpr := ""
For nNx := 1 to Len(cImprocede)
	nNu ++
	cRImpr += Subs(cImprocede,nNx,1)
	If nNu == 6
		cRImpr += "*"
		nNu := 0
	EndIf
Next nNx

cRAguar := ""
For nNx := 1 to Len(cAguardo)
	nNu ++
	cRAguar += Subs(cAguardo,nNx,1)
	If nNu == 6
		cRAguar += "*"
		nNu := 0
	EndIf
Next nNx


	cAliasQry := GetNextAlias()
	cAliasRe0 := cAliasQry  
	lQuery	  := .T.

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr("APT40R")
		
	BEGIN REPORT QUERY oSection1
	
	cOrdem := "%REL.REL_FILIAL,REL.REL_TPPLT,REL.REL_RESULT%"
	cFilProc:= "%AND " + FWJoinFilial( "REL", "RE0" ) + " %"
	cFilPlei:= "%AND " + FWJoinFilial( "RE5", "REL" ) + " %"
		
	BeginSql alias cAliasQry
		SELECT 	REL.REL_FILIAL, RE5.RE5_FILIAL, REL.REL_TPPLT,  RE5.RE5_CODIGO, RE0.RE0_FILIAL, REL.REL_PRONUM, 
				RE0.RE0_NUM,    RE5.RE5_TABELA, RE0.RE0_DTPROC, REL.REL_RESULT, REL.REL_CC
		FROM %table:REL% REL 
		LEFT JOIN %table:RE5% RE5
			ON	REL.REL_TPPLT = RE5.RE5_CODIGO %exp:cFilPlei%
		LEFT JOIN %table:RE0% RE0
			ON  REL.REL_PRONUM = RE0.RE0_NUM %exp:cFilProc%
		WHERE	RE5.RE5_TABELA = (%exp:cString%) AND RE0.RE0_DTPROC between (%exp:dDataDe%) AND (%exp:dDataAte%) AND
			   	REL.%NotDel% AND RE0.%NotDel% AND RE5.%NotDel%
		ORDER BY %exp:cOrdem%
	EndSql
	
	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
	END REPORT QUERY oSection1 PARAM mv_par01, mv_par02, mv_par03, mv_par06

(cAliasQry)->( dbGoTop() )
(cAliasRe0)->( dbGoTop() )

oReport:SetMeter( REL->(LastRec()) )  

//-- Incializa impressao   
oSection1:Init()                              

While !(cAliasQry)->( EOF() ) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimenta Regua de Processamento                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:IncMeter( 1 )   
	
	cProNum	:=	(cAliasQry)->REL_PRONUM
	If !(lQuery)
	   	lValido	:=	(cAliasRe0)->( dbSeek( RhFilial((cAliasRe0),(cAliasQry)->REL_FILIAL)+cProNum ) )
		IF !(lValido)
			(cAliasQry)->( dbSkip() )
			Loop
		EndIF   
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste Parametrizacao da Selecao pelo SX1                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	(!Empty((cAliasRe0)->RE0_DTPROC) .And. ((cAliasRe0)->RE0_DTPROC < dDataDe )) .Or. ;
		(!Empty((CAliasRe0)->RE0_DTPROC) .And. ((cAliasRe0)->RE0_DTPROC > dDataAte)) 
		(cAliasQry)->( dbSkip()	)
		Loop
	EndIf 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste controle de acessos e filiais validas               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(xFilial("REL"))
		If !(Alltrim((cAliasQry)->REL_FILIAL) $ fValidFil()) 
			(cAliasQry)->( dbSkip() )
			Loop
		EndIf
	Else
		If !((cAliasQry)->REL_FILIAL $ fValidFil()) 
			(cAliasQry)->( dbSkip() )
			Loop
		EndIf
	EndIf

	IF !Empty(cTpPlt) .And. cTpPlt # (cAliasQry)->REL_TPPLT .And. (nRProc+nRImpr+nRAguar > 0)
	
		oSection1:Cell("REL_FILIAL"):SetValue((cAliasQry)->REL_FILIAL)
		oSection1:Cell("REL_TPPLT"):SetValue(cTpPlt) 
		oSection1:Cell("RE5_DESCR"):SetValue(fDesc("RE5",cString+cTpPlt,"RE5_DESCR"))
		oSection1:Cell("NPROCED"  ):SetValue(nRProc)
		oSection1:Cell("NIMPROCED"):SetValue(nRImpr)
		oSection1:Cell("NAGUARD"  ):SetValue(nRAguar)
		oSection1:Cell("NTOTPLTS" ):SetValue(nRProc+nRImpr+nRAguar)
	
		oSection1:PrintLine()
   
	    nRProc 	:=	0                             
	    nRImpr	:=	0
	    nRAguar	:=	0

	EndIf

	cTpPlt	:= (cAliasQry)->REL_TPPLT   
	cResult	:= (cAliasQry)->REL_RESULT

	IF AllTrim(cResult) $ AllTrim(cRProc)
		nRProc ++
	EndIF
	IF AllTrim(cResult) $ AllTrim(cRImpr)
		nRImpr ++
	EndIF
	IF AllTrim(cResult) $ AllTrim(cRAguar) .Or. ( Empty(AllTrim(cResult)) .and. !empty(cTpPlt) )
		nRAguar ++
	EndIF

	(cAliasQry)->( dbSkip() )
	Loop
	
EndDo

If (nRProc+nRImpr+nRAguar > 0)
	oSection1:Cell("REL_TPPLT"):SetValue(cTpPlt)
	oSection1:Cell("RE5_DESCR"):SetValue(fDesc("RE5",cString+cTpPlt,"RE5_DESCR"))
	oSection1:Cell("NPROCED"  ):SetValue(nRProc)
	oSection1:Cell("NIMPROCED"):SetValue(nRImpr)
	oSection1:Cell("NAGUARD"  ):SetValue(nRAguar)
	oSection1:Cell("NTOTPLTS" ):SetValue(nRProc+nRImpr+nRAguar)
	
	oSection1:PrintLine()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza impressao inicializada pelo metodo Init             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Finish()

Return

                             

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fResults  ³ Autor ³ Tania Bronzeri   		³ Data ³11/07/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Selecionar Resultados de Pleitos na RE5                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fResults()  												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fResults( l1Elem , cPreSelect )

Local aNewSelect		:= {}
Local aPreSelect		:= {}
Local cFilRE5RST		:= xFilial("RE5")+"RSP"
Local cTitulo			:= ""
Local MvParDef			:= ""
Local MvRetor			:= ""
Local MvParam			:= ""
Local lRet				:= .T.
Local nFor				:= 0
Local nAuxFor			:= 1
Local MvPar     		:= NIL                                                     
Static __afResults__


DEFAULT cPreSelect		:= ""
DEFAULT l1Elem			:= .F.

Begin Sequence

	CursorWait()
		For nFor := 1 To Len( cPreSelect ) Step 6
			aAdd( aPreSelect , SubStr( cPreSelect , nFor , 6 ) )
		Next nFor
		
		cAlias 	:= Alias() 					
		MvPar	:= &(Alltrim(ReadVar()))	
		mvRet	:= Alltrim(ReadVar())		
		
		If !( l1Elem )
			For nFor := 1 TO Len(alltrim(MvPar))
				Mvparam += Subs(MvPar,nAuxFor,6)
				MvParam += Replicate("*",6)
				nAuxFor := (nFor * 6) + 1
			Next
		Endif
		mvPar 	:= MvParam
		
		IF Empty( __afResults__ )
			__afResults__	:= BldafResults( cFilRE5RST )
		EndIF
	CursorArrow()
	
	IF !( lRet := !Empty( __afResults__ ) )
		Aviso( STR0008, STR0009, { "OK" } )		// "Atencao!"###"Nao ha Tipos de Resultados de Pleitos Validos cadastrados. Verifique cadastramento, e tente novamente."
		Break
	EndIF	
    
	CursorWait()
		For nFor := 1 To Len( __afResults__ )
			IF ( aScan( aPreSelect , SubStr( __afResults__[ nFor ] , 1 , 6 ) ) == 0.00 )
				MvParDef+=Left(__afResults__[ nFor ],6)
				aAdd( aNewSelect , __afResults__[ nFor ] )
			EndIF
		Next nFor
	CursorArrow()
	
	IF f_Opcoes(@MvPar,cTitulo,aNewSelect,MvParDef,12,49,l1Elem,6,5)
		CursorWait()
			For nFor := 1 To Len( mVpar ) Step 6
				IF ( SubStr( mVpar , nFor , 6 ) # "******" )
					mvRetor += SubStr( mVpar , nFor , 6 )
				Endif
			Next nFor
			&MvRet := Alltrim(Mvretor)
		CursorArrow()	
	EndIF

End Sequence

dbSelectArea(cAlias)

Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³BldafResults  ³ Autor ³ Tania Bronzeri   		³ Data ³12/07/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carregar os Resultados dos Pleitos do RE5                  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fResults()  		      										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 				      								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function BldafResults( cFilRE5RSP )
Local aArea		:= GetArea()
Local aQuery	:= {}
Local aResults	:= {}
Local bSkip		:= { || aAdd( aResults , ( RE5_CODIGO + " - " + RE5_DESCR ) ) , .F. }

aQuery		:= Array( 05 )
aQuery[01]	:= "RE5_FILIAL='"+Left(cFilRE5RSP,FWGETTAMFILIAL)+"'"
aQuery[02]	:= " AND "                      
aQuery[03]	:= "RE5_TABELA='RSP'"
aQuery[04]	:= " AND "
aQuery[05]	:= "D_E_L_E_T_=' ' "

RE5->( GdMontaCols(	NIL				,;	
					NIL				,;
					NIL				,;
					NIL				,;
					NIL				,;
					{				 ;
						"RE5_FILIAL",;
						"RE5_CODIGO",;
						"RE5_DESCR"	 ;
					}				,;
					NIL				,;
					"RE5"			,;
					cFilRE5RSP		,;
					NIL				,;
					bSkip			,;
					.F.				,;
					.F.				,;
					.F.				,;
					NIL				,;
					.F.				,;
					.F.				,;
					aQuery			,;
					.F.				,;
					.T.				,;
					.F.				,;
					.T.				,;
					.F.				,;
					.F.				,;
					.F.				 ;
				   );
	  )

RestArea( aArea )

Return( aClone( aResults ) )       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fBuscaFil ºAutor  ³Microsiga           º Data ³  02/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca descricao da empresa/filial no SIGAMAT.              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fBuscaFil(cEmp,cFil,cNomEmpFil)

Local aArea		:= 	GetArea()
Local aAreaSM0	:=	SM0->(GetArea())
Local lRet		:= .F.

DEFAULT	cEmp	:= cEmpAnt
DEFAULT cFil	:= cFilAnt

cNomEmpFil	:= ""

dbSelectArea("SM0")
dbSetOrder(1)

If dbSeek(cEmp + cFil)
	lRet		:= .T.
	cNomEmpFil	:= Alltrim(SM0->M0_NOME) + " / " + Alltrim(SM0->M0_FILIAL)
EndIf	
           
RestArea(aAreaSM0)
RestArea(aArea)

Return lRet
                     
