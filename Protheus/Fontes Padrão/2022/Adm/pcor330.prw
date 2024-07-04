#INCLUDE "PCOR330.ch"
#INCLUDE "PROTHEUS.CH"

#define ANTES_LACO   	1
#define COND_LACO 		2
#define PROC_LACO 		3
#define DEPOIS_LACO 	4
#define PROC_FILTRO 	5
#define PROC_CARGO		6
#define BLOCK_FILTRO 	7

#define LIM_PERG 11
#define QUEB_INDEX 01
#define QUEB_LACO 02
#define QUEB_SEEK 03
#define QUEB_COND 04
#define QUEB_TITSUB 05
#define QUEB_FILTRO 06
#define COL_TIT 01
#define COL_IMPR 02
#define COL_TAM 03
#define COL_ORDEM 04
#define COL_ALIGN 05
#define COL_TRUNCA 06

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOR330  ³ AUTOR ³ Paulo Carnelossi      ³ DATA ³ 28/03/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de impressao dos movimentos (tabela AKD) de acordo  ³±±
±±³          ³ com cubo gerencial solicitado.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOR330                                                      ³±±
±±³_DESCRI_  ³ Programa de impressao dos movimentos mod SIGAPCO.            ³±±
±±³_FUNC_    ³ Esta funcao devera ser utilizada com a sua chamada normal a  ³±±
±±³          ³ partir do Menu do sistema.                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOR330(aPerg) 
Default aPerg	:=	{}

	If Len(aPerg) == 0
		Pergunte("PCR330",.F.)
   		oReport	:= PCOR330Def( "PCR330")
	Else
		aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
   		oReport	:= PCOR330Def( "PCR330" )
	EndIf
	oReport:PrintDialog()

//------------------------------------------------------------------------
Static Function PCOR330Def( cPerg )
Local oReport
Local cAliasQry	:= GetNextAlias()
Local oMovOrdem
Local cPicture  := "@E 999,999,999,999.99"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


// "Relacao de Movimentos" ### "Este relatorio ira imprimir a Relação de Movimentos de acordo com os parâmetros solicitados pelo usuário. Para mais informações sobre este relatorio consulte o Help do Programa ( F1 )."
oReport := TReport():New( "PCOR330", STR0001, cPerg, { |oReport| PCOR330Prt( oReport, cAliasQry) },STR0022) // "Este relatorio ira imprimir a Relação de Movimentos de acordo com os parâmetros solicitados pelo usuário. Para mais informações sobre este relatorio consulte o Help do Programa ( F1 )."
oReport:SetLandscape()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a  secao do relatorio                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMovOrdem := TRSection():New( oReport, STR0021  , { cAliasQry, "AKD","AK1","AK5","AK6","AKF","AL2","CTT","CTD","CTH"} , /*aOrdem*/)//"Movimentos"

TRCell():New( oMovOrdem, "AKD_CO"    	, "AKD",/*STR0008*/	, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{ || (cAliasQry)->AKD_CO }*/		) 	// Conta Orcamentaria
TRCell():New( oMovOrdem, "AK5_DESCRI"	, "AK5",        		, /*Picture*/,/*Tamanho*/	, /*lPixel*/, /*{ || (cAliasQry)->AK5_DESCRI }*/		) 	
TRCell():New( oMovOrdem, "AKD_DATA"  	, "AKD",/*STR0011*/	, /*Picture*/, 				, /*lPixel*/, 	)	// Dt.Movim.
TRCell():New( oMovOrdem, "AKD_CLASSE"	, "AKD",/*STR0012*/	, /*Picture*/, /*Tamanho*/, /*lPixel*/, 	) 	// Classe
//TRCell():New( oMovOrdem, "AK6_DESCRI"	, "AK6",        		, /*Picture*/,/*Tamanho*/	, /*lPixel*/, /*{ || (cAliasQry)->AK6_DESCRI }*/) 	
TRCell():New( oMovOrdem, "AKD_OPER"  	, "AKD",/*STR0013*/	, /*Picture*/, /*Tamanho*/, /*lPixel*/, 		) 	// Operacao
//TRCell():New( oMovOrdem, "AKF_DESCRI"	, "AKF",        		, /*Picture*/,/*Tamanho*/	, /*lPixel*/, /*{ || (cAliasQry)->AKF_DESCRI }*/) 	
TRCell():New( oMovOrdem, "AKD_HIST"  	, "AKD",/*STR0014*/	, /*Picture*/, /*Tamanho*/, /*lPixel*/, 			)	// Historico
TRCell():New( oMovOrdem, "AKD_PROCES"	, "AKD",/* STR0015*/	, /*Picture*/, 				, /*lPixel*/,			)	// Processo
TRCell():New( oMovOrdem, "DEBITO"		, 		 , STR0016	, cPicture/*Picture*/, TamSX3('AKD_VALOR1')[1]+1, /*lPixel*/, {||IIf((cAliasQry)->AKD_TIPO=="2",(cAliasQry)->AKD_VALOR1,0)}/*CodeBlock*/ )	// Debito 
TRCell():New( oMovOrdem, "CREDITO"		,      , STR0017, cPicture/*Picture*/,   TamSX3('AKD_VALOR1')[1]+1, /*lPixel*/, {||IIf((cAliasQry)->AKD_TIPO=="1",(cAliasQry)->AKD_VALOR1,0)}/*CodeBlock*/ )	// Credito

oReport:SetTotalInLine(.F.)

Return oReport

Static Function PCOR330Prt(oReport,cAliasQry)
Local oBreaks	:=	{}
Local aBreaks	:=	{}
Local aCubeStru	:=	{}
Local aCubeAux	:=	{}
Local oSection	:=	oReport:Section(1)
Local cOrder	:=	""
Local nZ		:= 0
Local nPosCfg	:= 0
Local oFunc1,oFunc2     
Local cQuery := ""
Local cQuery1:= ""
Local cDesc  := "" 
Local nQt    := 5    
Local aControle := {} 

Static nQtdEntid := CtbQtdEntd()                                     


Private cDesSubTot:= ""

DbSelectArea('AKW')
DbSetOrder(1)
If !DbSeek(xFilial()+mv_par09)
	MsgStop(STR0018)
	Return .F.
Endif	

While !Eof() .And. AKW_COD == mv_par09
	aadd(aBreaks,)
	aBreaks[Len(aBreaks)]	:=	{(MontaBlock("{|| "+ALLTRIM(StrTran(AKW->AKW_CONCCH,"AKD->",""))+"}")),;
			STR0020 + "<"+Alltrim(AKW->AKW_DESCRI)+"> ",AKW->AKW_CHAVER}
	cOrder	:=	AllTrim(AKW->AKW_CONCCH)
	DbSkip()
Enddo  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta descricao e query para atender 				³
//³a abertura de (n) entidades                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nQtdEntid == Nil
   nQtdEntid := CtbQtdEntd()
Else               
   aArea := GetArea()
   If nQtdEntid > 4
      While nQt <= nQtdEntid
          DbSelectArea('CT0')
          DbSetOrder(1)
          DbSeek(xFilial()+STRZERO(nQt,2))
          cDesc += ", "+CT0_CPODSC   
          If AScan(aControle,CT0_ALIAS) == 0
             AADD(aControle, CT0_ALIAS)
	         cQuery1 += " LEFT OUTER JOIN "  
	         cQuery1 += RetSqlName(CT0_ALIAS)+" "+CT0_ALIAS
	         DbSelectArea('SX3')
	         DbSetOrder(1)
	         DbSeek(CT0->CT0_ALIAS+"01")          
	         cQuery1 += " ON "+CT0->CT0_ALIAS+"." + X3_CAMPO +" = '"+xFilial(CT0->CT0_ALIAS)+"' "   
	         cQuery1 += " AND "+CT0->CT0_ALIAS+"." + CT0->CT0_CPOCHV +" = AKD.AKD_ENT"+STRZERO(nQt,2) 
	         cQuery1 += " AND "+CT0->CT0_ALIAS+".D_E_L_E_T_ = ' ' "
          Endif
          nQt += 1
          CT0->(DbSkip())
      Enddo
   Endif       
   RestArea(aArea)          
Endif        

cDesc	+= ", AMF_DESCRI"

cQuery1 += " LEFT OUTER JOIN "
cQuery1 += RetSqlName("AMF")+" AMF ON "
cQuery1 += " AMF_FILIAL = '"+xFilial("AMF")+"' "
cQuery1 += " AND AMF_CODIGO = AKD.AKD_UNIORC "
cQuery1 += " AND AMF.D_E_L_E_T_ = ' ' "

cDesc	:= '%' + cDesc + '%'
cQuery1	:= '%' + cQuery1 + '%'

// Monta array com a estrutura dos cubos
aCubeStru := Pco_ChvCube()
                                        
// Monta array com a estrutura do cubo selecionado nos parametros
nPosCfg		:= aScan(aCubeStru, {|x| Alltrim(x[1]) == Alltrim(mv_par09) } )  //procura o cubo
aCubeAux	:= aCubeStru[nPosCfg, 2]

For nZ:=Len(aBreaks) To 1 STEP -1
	AAdd(oBreaks, TRBreak():New( oSection,	aBreaks[nZ,1] ))	
	oBreaks[Len(oBreaks)]:SetTitle( MontaBlock("{ ||'"+ aBreaks[nZ,2]+ "' + '<' + cDesSubTot + '>' }") )
	oBreaks[Len(oBreaks)]:OnBreak( MontaBlock("{ |x| cDesSubTot := AllTrim(SubStr( x, "+Str(aCubeAux[nZ,3])+", "+Str(aCubeAux[nZ,4])+")) }") )
	TRFunction():New( oSection:Cell("DEBITO"  ), , "SUM", oBreaks[Len(oBreaks)], STR0020+STR0016/*cTitle*/ ,/*cPicture*/,/*uFormula*/, .F. , (nZ ==1) )
	TRFunction():New( oSection:Cell("CREDITO" ), , "SUM", oBreaks[Len(oBreaks)], STR0020+STR0017/*cTitle*/ ,/*cPicture*/,/*uFormula*/, .F. , (nZ ==1))
Next
MakeSqlExp( oReport:uParam )                                

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta expressao de filtro da query com os parametros informados                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//cOrder	:=	'%'+SqlOrder(StrTran(cOrder,"AKD->",""))+'%'
cOrder  := StrTran(cOrder,"AKD->","")  //primeiro tiro o ALIAS
cOrder  := StrTran(cOrder,"+",",")     //depois mudo o operador soma (concatenar) para virgula
cOrder	:=	"%"+cOrder+"%"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Query do relatorio para a secao 1                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection:BeginQuery()

If nQtdEntid <= 4
	BeginSql Alias cAliasQry
	
		SELECT
			AKD.*, AK5_DESCRI, AK6_DESCRI, AKF_DESCRI, AMF_DESCRI %exp:cDesc%
		FROM 
			%table:AKD% AKD 
	
				LEFT OUTER JOIN %table:AK1% AK1
				ON 	AK1.AK1_FILIAL = %xfilial:AK1%
					AND AK1_CODIGO = AKD_CODPLA
					AND AK1.%notDel%
	
				LEFT OUTER JOIN %table:AK5% AK5
				ON 	AK5.AK5_FILIAL = %xfilial:AK5%
					AND AK5_CODIGO = AKD_CO
					AND AK5.%notDel%
	
				LEFT OUTER JOIN %table:AK6% AK6
				ON	AK6.AK6_FILIAL = %xfilial:AK6%
					AND AK6_CODIGO = AKD_CLASSE
					AND AK6.%notDel%
	
				LEFT OUTER JOIN %table:AKF% AKF
				ON  AKF.AKF_FILIAL = %xfilial:AKF%
					AND AKF_CODIGO = AKD_OPER
					AND AKF.%notDel%
	
				LEFT OUTER JOIN %table:AL2% AL2
				ON 	AL2.AL2_FILIAL = %xfilial:AL2%
					AND AL2_TPSALD = AKD_TPSALD
					AND AL2.%notDel%
	
				LEFT OUTER JOIN %table:CTT% CTT
				ON  CTT.CTT_FILIAL = %xfilial:CTT%
					AND CTT_CUSTO  = AKD_CC
					AND CTT.%notDel%
	
				LEFT OUTER JOIN %table:CTD% CTD
				ON  CTD.CTD_FILIAL = %xfilial:CTD%
					AND CTD_ITEM  = AKD_ITCTB
					AND CTD.%notDel%
	
				LEFT OUTER JOIN %table:CTH% CTH
				ON  CTH.CTH_FILIAL = %xfilial:CTH%
					AND CTH_CLASSE  = AKD_CLVLR
					AND CTH.%notDel%        
					
				%exp:cQuery1%	
				
		WHERE
			AKD.AKD_FILIAL = %xfilial:AKD%
			AND AKD.AKD_DATA		BETWEEN %Exp:DtoS(mv_par01)% AND %Exp:DtoS(mv_par02)%
			AND AKD.AKD_CO			BETWEEN %Exp:mv_par03%  AND %Exp:mv_par04%
			AND AKD.AKD_CLASSE		BETWEEN %Exp:mv_par05% 	AND %Exp:mv_par06%
			AND AKD.AKD_OPER		BETWEEN %Exp:mv_par07%	AND %Exp:mv_par08%
			AND AKD.AKD_PROCES		BETWEEN %Exp:mv_par10%	AND %Exp:mv_par11%
			AND AKD.AKD_STATUS	!= '3'
			AND AKD.%notDel%
	
		ORDER BY %exp:cOrder%
	
	EndSql
Else
                        
	BeginSql Alias cAliasQry
	
		SELECT
			AKD.*, AK5_DESCRI, AK6_DESCRI, AKF_DESCRI
		FROM 
			%table:AKD% AKD 
	
				LEFT OUTER JOIN %table:AK1% AK1
				ON 	AK1.AK1_FILIAL = %xfilial:AK1%
					AND AK1_CODIGO = AKD_CODPLA
					AND AK1.%notDel%
	
				LEFT OUTER JOIN %table:AK5% AK5
				ON 	AK5.AK5_FILIAL = %xfilial:AK5%
					AND AK5_CODIGO = AKD_CO
					AND AK5.%notDel%
	
				LEFT OUTER JOIN %table:AK6% AK6
				ON	AK6.AK6_FILIAL = %xfilial:AK6%
					AND AK6_CODIGO = AKD_CLASSE
					AND AK6.%notDel%
	
				LEFT OUTER JOIN %table:AKF% AKF
				ON  AKF.AKF_FILIAL = %xfilial:AKF%
					AND AKF_CODIGO = AKD_OPER
					AND AKF.%notDel%
	
				LEFT OUTER JOIN %table:AL2% AL2
				ON 	AL2.AL2_FILIAL = %xfilial:AL2%
					AND AL2_TPSALD = AKD_TPSALD
					AND AL2.%notDel%
	
				LEFT OUTER JOIN %table:CTT% CTT
				ON  CTT.CTT_FILIAL = %xfilial:CTT%
					AND CTT_CUSTO  = AKD_CC
					AND CTT.%notDel%
	
				LEFT OUTER JOIN %table:CTD% CTD
				ON  CTD.CTD_FILIAL = %xfilial:CTD%
					AND CTD_ITEM  = AKD_ITCTB
					AND CTD.%notDel%
	
				LEFT OUTER JOIN %table:CTH% CTH
				ON  CTH.CTH_FILIAL = %xfilial:CTH%
					AND CTH_CLASSE  = AKD_CLVLR
					AND CTH.%notDel%
		WHERE
			AKD.AKD_FILIAL = %xfilial:AKD%
			AND AKD.AKD_DATA		BETWEEN %Exp:DtoS(mv_par01)% AND %Exp:DtoS(mv_par02)%
			AND AKD.AKD_CO			BETWEEN %Exp:mv_par03%  AND %Exp:mv_par04%
			AND AKD.AKD_CLASSE		BETWEEN %Exp:mv_par05% 	AND %Exp:mv_par06%
			AND AKD.AKD_OPER		BETWEEN %Exp:mv_par07%	AND %Exp:mv_par08%
			AND AKD.AKD_PROCES		BETWEEN %Exp:mv_par10%	AND %Exp:mv_par11%
			AND AKD.AKD_STATUS	!= '3'
			AND AKD.%notDel%
	
		ORDER BY %exp:cOrder%
	
	EndSql
EndIf
                   
oSection:EndQuery()

oSection:SetHeaderPage()			// Configura cabecalho para impressao no inicio de cada pagina

oReport:SetMeter( AKD->( RecCount() ) )

oReport:Section(1):Print()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DetalheRel ºAutor ³Paulo Carnelossi    º Data ³  15/03/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime detalhe do relatorio quando existir agrupamentos    º±±
±±º          ³de acordo com aCondicao (array contendo blocos de codigos)  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DetalheRel(aCondicao, nNivel, cAlias)
AEVAL(aCondicao,;
				{|cX, nX| (cAlias)->(Eval(aCondicao[nX][ANTES_LACO],nX)) } ,  1,  nNivel)

aCondicao[nNivel][PROC_CARGO] := Eval(aCondicao[nNivel][ANTES_LACO])

While (cAlias)->( ! Eof() .And. AvaliaCondicao(aCondicao, nNivel, cAlias) )

		If .Not. (cAlias)->(Eval(aCondicao[nNivel][PROC_FILTRO], nNivel))
			(cAlias)->(Eval(aCondicao[nNivel][BLOCK_FILTRO], nNivel))			
		Else
			(cAlias)->(Eval(aCondicao[nNivel][PROC_LACO], nNivel))
		
			If nNivel < Len(aCondicao)  // avanca para proximo nivel
				DetalheRel(aCondicao, nNivel+1, cAlias)
			EndIf
		EndIf

End

(cAlias)->(Eval(aCondicao[nNivel][DEPOIS_LACO],nNivel))

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AvaliaCondicaoºAutor ³Paulo Carnelossi    º Data ³ 23/09/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³avalia condicao while (auxiliar a funcao DetalheRel()       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AvaliaCondicao(aCondicao, nNivel, cAlias)
Local aAux := {}, lCond := .T., lRet := .T., nY

AEVAL(aCondicao,;
				{|cX, nX| aAdd(aAux,lCond:=(cAlias)->(Eval(aCondicao[nX][COND_LACO], nX))) } ,  1,  nNivel) 

For nY := 1 TO Len(aAux)
    If ! aAux[nY]
    	 lRet := .F.
    	 Exit
    EndIf
Next    

Return(lRet)