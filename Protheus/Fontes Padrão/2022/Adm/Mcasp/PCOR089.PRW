#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCOR089.CH"

#DEFINE 	TAM_VALOR 			30
#DEFINE     DD_ESPEC  1 
#DEFINE     DD_CATEG  2  
#DEFINE     DD_VLCR1  2  
#DEFINE     DD_VLCS1  3  
#DEFINE     DD_VLPB1  4  
#DEFINE     DD_VLCR2  5         
#DEFINE     DD_VLCS2  6  
#DEFINE     DD_VLPB2  7  
#DEFINE     DD_VLCR3  8  
#DEFINE     DD_VLCS3  9  
#DEFINE     DD_VLPB3  10  
#DEFINE     DADOS_RT  1 
#DEFINE     DADOS_RP  2  
#DEFINE     DADOS_DT  3  
#DEFINE     DADOS_DP  4  
#DEFINE     DADOS_III  5  
#DEFINE     DADOS_RN  6         
#DEFINE     DADOS_DC  7  
#DEFINE     DADOS_DL  8  

  


/*/{Protheus.doc} PCOR089
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function PCOR089()

Local cPerg	   	:= "PCOR089" 
Local lRet      := .T.

/*PERGUNTE
MV_PAR01 - Codigo do PPA ?
MV_PAR02 - Versao do PPA ?
MV_PAR03 - Ano de  ?
MV_PAR04 - Anot Até ?	
*/

SX1->(dbSetOrder(1))


If GetRpoRelease() < "12.1.023"
    Help(,, "Help",, OemToAnsi("STR0003"), 1, 0) //"Relatorio Demonstrativo PPA - Receitas da Administração Direta e Indireta - Fontes de Financiamento disponível a partir da versao 12.1.23"
    lRet := .F.
ElseIf !SX1->(dbSeek(Padr(cPerg, Len(SX1->X1_GRUPO), " ")))
    Help(,, "Help",, OemToAnsi("STR0004"), 1, 0) //"Para utilizaçao do relatorio Demonstrativo PPA - Receitas da Administração Direta e Indireta - Fontes de Financiamento é necessário aplicar o pacote acumulado da controladoria."
    lRet := .F.
Else 
    //Perguntas do Relatório
    lRet := Pergunte(cPerg, .T.) 
EndIf 

If lRet
 
	oReport := ReportDef() 

	oReport:PrintDialog()
	      
EndIf

Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Esta funcao tem como objetivo definir as secoes, celulas,
totalizadores do relatorio que poderao ser configurados pelo relatorio.

@author TOTVS
@since 20/10/2020
@version 12.1.30
@return oReport - Objeto da classe TReport
/*/
//---------------------------------------------------------------------------------------
Static Function ReportDef()  
local aArea	   		:= GetArea()   
Local cReport		:= "PCOR089"
Local cTitulo		:= STR0001 //"Demonstrativos de Metas Anuais"
Local cDESC			:= STR0002 //"Este programa ira imprimir o Desenv. Demonstrativos de Metas Anuais, de acordo com os parâmetros informados pelo usuário."
Local cPerg	   	:= "PCOR089" 

Local oSection1, oCabec1, oCabec2, oBorder
Pergunte(cPerg,.F.) 

oReport	:= TReport():New( cReport,cTitulo,cPerg,;
	{ |oReport| Pergunte(cPerg,.F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, CDESC)


oBorder := TRBorder():New(oReport, 5,, 0)

//Criacao da Secao Cabecalho 1
oCabec1 := TRSection():New(oReport, "CABEC_1", {}, /*aOrdem*/) 
TRCell():New(oCabec1, "CABEC_1",, "STR0004",, 60, /*lPixel*/, /*CodeBlock*/, "CENTER",, "CENTER",,,,,, .T.) //" Avaliação do Cumprimento das Metas Fiscais do Exercício Anterior"
oCabec1:oHBrdBottom := oBorder //Remove a borda do cabecalho 1
oCabec1:setLinesBefore(0)

//Criacao da Secao Cabecalho 1
oCabec2 := TRSection():New(oReport, "STR0005", {}, /*aOrdem*/)  // "EXERCICIO "
TRCell():New(oCabec2, "EXERCICIO",, "",, 60, /*lPixel*/, /*CodeBlock*/, "CENTER",, "CENTER",,,,,, .T.) 
oCabec2:oHBrdBottom := oBorder //Remove a borda do cabecalho 2
oCabec2:setLinesBefore(0)

oReport:SetLandScape(.T.)       //define q relatorio sera sempre em paisagem
oReport:DisableOrientation()

//somente leitura dos parametros do pergunte
oReport:ParamReadOnly()


oSection1  := TRSection():New( oReport, "RECDEP", {"cArqTmp"},, .F., .F. ) //"Previsão de Receitas"

TRCell():New( oSection1, "CONTA"    , , STR0003 /*Titulo*/,/*Picture*/,       75,/*lPixel*/,{||""}/*CodeBlock*/,"LEFT",.T.,"CENTER")  //"Especificação"
TRCell():New( oSection1, "VLRCORR1" , , STR0004 /*Titulo*/,"@E 999,999,999,999,999.99"/*Picture*/, TAM_VALOR,/*lPixel*/,{||1110.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"Valor Corrente"
TRCell():New( oSection1, "VLRCONS1" , , STR0005 /*Titulo*/,"@E 999,999,999,999,999.99"/*Picture*/, TAM_VALOR,/*lPixel*/,{||1110.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"Valor Constante"
TRCell():New( oSection1, "PIB1"     , , STR0006 /*Titulo*/,"@E 9,999,999.999"/*Picture*/, TAM_VALOR,/*lPixel*/,{||10.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"% PIB (a / PIB)" 

TRCell():New( oSection1, "VLRCORR2" , , STR0004 /*Titulo*/,"@E 999,999,999,999,999.99"/*Picture*/, TAM_VALOR,/*lPixel*/,{||1110.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"DIRETA"
TRCell():New( oSection1, "VLRCONS2" , , STR0005 /*Titulo*/,"@E 999,999,999,999,999.99"/*Picture*/, TAM_VALOR,/*lPixel*/,{||1110.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"INDIRETA" 
TRCell():New( oSection1, "PIB2"     , , STR0006 /*Titulo*/,"@E 9,999,999.999"/*Picture*/, TAM_VALOR,/*lPixel*/,{||10.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"INDIRETA" 

TRCell():New( oSection1, "VLRCORR3" , , STR0004	/*Titulo*/,"@E 999,999,999,999,999.99"/*Picture*/, TAM_VALOR,/*lPixel*/,{||1110.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"DIRETA"
TRCell():New( oSection1, "VLRCONS3" , , STR0005 /*Titulo*/,"@E 999,999,999,999,999.99"/*Picture*/, TAM_VALOR,/*lPixel*/,{||1110.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"INDIRETA" 
TRCell():New( oSection1, "PIB3"     , , STR0006 /*Titulo*/,"@E 9,999,999.999"/*Picture*/, TAM_VALOR,/*lPixel*/,{||10.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"INDIRETA" 

oSection1:SetTotalInLine(.F.)        

oSection1:SetTotalInLine(.F.)        

RestArea(aArea)
           
Return(oReport)

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   24/09/2020
@return  0
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint( oReport )
// Local oCabec1   := oReport:Section("CABEC_1")
// Local oCabec2   := oReport:Section("CABEC_2")
Local oSection1      := oReport:Section( "RECDEP") 
Local aDados := {}
Local cAno  := MV_PAR01
Local nX    := 0
local cAno1     := cValToChar(Val(cAno) + 1)
Local cAno2     := cValToChar(Val(cAno) + 2)
Local cAno3     := cValToChar(Val(cAno) + 3)

aDados := PR089QRY(cAno)

/*oCabec1:Init()
oCabec2:Init()
oCabec1:PrintLine()  
oCabec2:PrintLine()       
oCabec2:Finish()     
oCabec1:Finish()*/


oSection1:Init()
For nX:= 1 to Len(aDados)
    oSection1:Cell("CONTA"):SetBlock ( {||aDados[nX][DD_ESPEC]} )
    
    //Altera nome das colunas
	oSection1:Cell("VLRCORR1"):SetTitle (cAno1 + CRLF +STR0004)
    oSection1:Cell("VLRCONS1"):SetTitle (cAno1 + CRLF +STR0005)
    oSection1:Cell("PIB1"):SetTitle (cAno1 + CRLF +STR0006   )
    //Conteudo
    oSection1:Cell("VLRCORR1"):SetBlock ( {||aDados[nX][DD_VLCR1]} ) 
    oSection1:Cell("VLRCONS1"):SetBlock ( {||aDados[nX][DD_VLCS1]} ) 
    oSection1:Cell("PIB1"):SetBlock ( {||aDados[nX][DD_VLPB1]} ) 

    //Altera nome das colunas
	oSection1:Cell("VLRCORR2"):SetTitle (cAno2 + CRLF +STR0004)
    oSection1:Cell("VLRCONS2"):SetTitle (cAno2 + CRLF + STR0005)
    oSection1:Cell("PIB2"):SetTitle (cAno2 + CRLF +STR0006   )
    //Conteudo
    oSection1:Cell("VLRCORR2"):SetBlock ( {||aDados[nX][DD_VLCR2]} ) 
    oSection1:Cell("VLRCONS2"):SetBlock ( {||aDados[nX][DD_VLCS2]} ) 
    oSection1:Cell("PIB2"):SetBlock ( {||aDados[nX][DD_VLPB2]} ) 

    //Altera nome das colunas
	oSection1:Cell("VLRCORR3"):SetTitle (cAno3 + CRLF +STR0004)
    oSection1:Cell("VLRCONS3"):SetTitle (cAno3 + CRLF +STR0005)
    oSection1:Cell("PIB3"):SetTitle (cAno3 + CRLF +STR0006   )
    //Conteudo
    oSection1:Cell("VLRCORR3"):SetBlock ( {||aDados[nX][DD_VLCR3]} ) 
    oSection1:Cell("VLRCONS3"):SetBlock ( {||aDados[nX][DD_VLCS3]} ) 
    oSection1:Cell("PIB3"):SetBlock ( {||aDados[nX][DD_VLPB3]} ) 


    oSection1:PrintLine()       //impressao linha detalhe
Next nX
oSection1:Finish()

Return .T.



//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Query para trazer os valores de despesa, receita, divida publica e deduçãi da receita

@author Totvs
   
@version P12
@since   24/09/2020
@return  0
@obs	 
*/
//-------------------------------------------------------------------

Static Function PR089QRY(cAno)
Local cAlsA25 := GetNextAlias()
Local cQry := ""
Local aDados := {}
local cAno1     := cValToChar(Val(cAno) + 1)
Local cAno2     := cValToChar(Val(cAno) + 2)
Local cAno3     := cValToChar(Val(cAno) + 3)
Local nIndice1   := Posicione("A23",1,xFilial("A23")+cAno1,"A23_INFLA")
Local nIndice2   := Posicione("A23",1,xFilial("A23")+cAno2,"A23_INFLA")
Local nIndice3   := Posicione("A23",1,xFilial("A23")+cAno3,"A23_INFLA")
Local nPIB1      := Posicione("A24",1,xFilial("A24")+cAno1,"A24_PIB")
Local nPIB2      := Posicione("A24",1,xFilial("A24")+cAno2,"A24_PIB")
Local nPIB3      := Posicione("A24",1,xFilial("A24")+cAno3,"A24_PIB")
Local nJED1      := Posicione("A25",1,xFilial("A25")+"1"+cAno1+Padr("3",TAMSX3("A25_CTGECO")[1])+"2","A25_VLRPRE")//Juros e Encargos da Dívida
Local nJED2      := Posicione("A25",1,xFilial("A25")+"1"+cAno2+Padr("3",TAMSX3("A25_CTGECO")[1])+"2","A25_VLRPRE")//Juros e Encargos da Dívida
Local nJED3      := Posicione("A25",1,xFilial("A25")+"1"+cAno3+Padr("3",TAMSX3("A25_CTGECO")[1])+"2","A25_VLRPRE")//Juros e Encargos da Dívida
Local nJrsDesp  := MV_PAR03
Local nJrsResp  := MV_PAR02


//array com dados de impressão 
//A25_CATEGO - 1=Despesa;2=Receita

aAdd(aDados,{"Receita Total"                            ,0,0,0,0,0,0,0,0,0})
aAdd(aDados,{"Receitas Primárias (I)"                   ,0,0,0,0,0,0,0,0,0})
aAdd(aDados,{"Despesa Total"                            ,0,0,0,0,0,0,0,0,0})
aAdd(aDados,{"Despesas Primárias (II)"                  ,0,0,0,0,0,0,0,0,0})
aAdd(aDados,{"Resultado Primário (III = I – II)"        ,0,0,0,0,0,0,0,0,0})
aAdd(aDados,{"Resultado Nominal"                        ,0,0,0,0,0,0,0,0,0})
aAdd(aDados,{"Dívida Pública Consolidada"               ,0,0,0,0,0,0,0,0,0})
aAdd(aDados,{"Dívida Consolidada Líquida"               ,0,0,0,0,0,0,0,0,0})
aAdd(aDados,{ nil                                       ,nil,nil,nil,nil,nil,nil,nil,nil,nil})
aAdd(aDados,{"Receitas Primárias Advindas de PPP(IV)"   ,0,0,0,0,0,0,0,0,0})
aAdd(aDados,{"Despesas Primárias geradas por PPP(V)"    ,0,0,0,0,0,0,0,0,0})
aAdd(aDados,{"Impacto dos Saldos das PPP(VI)=(IV-V)"    ,0,0,0,0,0,0,0,0,0})


//QUERY PRA DESPESA CATEGORIA = 1
cQry := "SELECT A25_CATEGO , " +CRLF
cQry += "SUM(A25_VLRPRE1) A25_VLRPR1, SUM(A26_VALOR1) A26_VALOR1, " +CRLF
cQry += "SUM(A25_VLRPRE2) A25_VLRPR2, SUM(A26_VALOR2) A26_VALOR2, " +CRLF
cQry += "SUM(A25_VLRPRE3) A25_VLRPR3, SUM(A26_VALOR3) A26_VALOR3  " +CRLF
cQry += "FROM ( " +CRLF
cQry += "	SELECT A25_CATEGO, " +CRLF
cQry += "	SUM(A25_VLRPRE) A25_VLRPRE1, A26_VALOR A26_VALOR1, " +CRLF
cQry += "	0 A25_VLRPRE2, 0 A26_VALOR2, " +CRLF
cQry += "	0 A25_VLRPRE3, 0 A26_VALOR3 " +CRLF
cQry += "	FROM  " +RetSqlName("A25") +" A25" +CRLF
//	--DEDUÇAO DA RECEITA
cQry += "	LEFT JOIN  " +RetSqlName("A26") +" A26" +CRLF
cQry += "	ON A26_FILIAL = '" + FwxFilial("A26") + "'" +CRLF
cQry += "	WHERE A25_FILIAL = '" + FwxFilial("A25") + "'" +CRLF
cQry += "	AND A25_ANO =  '"+ cAno1 +"'" +CRLF
cQry += "	AND A26_ANO = A25_ANO" +CRLF
cQry += "	AND A25_CATEGO = '1'" +CRLF
cQry += "	AND A26_CATEGO = '1'" +CRLF
cQry += "	AND A25.D_E_L_E_T_ = ''" +CRLF
cQry += "	AND A26.D_E_L_E_T_ = ''" +CRLF
cQry += "	GROUP BY A25_CATEGO,A26_VALOR" +CRLF

cQry += "	UNION ALL " +CRLF

cQry += "	SELECT A25_CATEGO, " +CRLF
cQry += "	0 A25_VLRPRE1, 0 A26_VALOR1, " +CRLF
cQry += "	SUM(A25_VLRPRE) A25_VLRPRE2, A26_VALOR A26_VALOR2, " +CRLF
cQry += "	0 A25_VLRPRE3, 0 A26_VALOR3" +CRLF
cQry += "	FROM   " +RetSqlName("A25") +" A25" +CRLF
//	--DEDUÇAO DA RECEITA
cQry += "	LEFT JOIN   " +RetSqlName("A26") +" A26" +CRLF
cQry += "	ON A26_FILIAL = '" + FwxFilial("A26") + "'" +CRLF
cQry += "	WHERE A25_FILIAL = '" + FwxFilial("A25") + "'" +CRLF
cQry += "	AND A25_ANO = '"+ cAno2 +"'" +CRLF
cQry += "	AND A26_ANO = A25_ANO" +CRLF
cQry += "	AND A25_CATEGO = '1'" +CRLF
cQry += "	AND A26_CATEGO = '1'" +CRLF
cQry += "	AND A25.D_E_L_E_T_ = ''" +CRLF
cQry += "	AND A26.D_E_L_E_T_ = ''" +CRLF
cQry += "	GROUP BY A25_CATEGO,A26_VALOR " +CRLF

cQry += "	UNION ALL " +CRLF

cQry += "	SELECT A25_CATEGO, " +CRLF 
cQry += "	0 A25_VLRPRE1, 0 A26_VALOR1, " +CRLF
cQry += "	0 A25_VLRPRE2, 0 A26_VALOR2, " +CRLF
cQry += "	SUM(A25_VLRPRE) A25_VLRPRE3, A26_VALOR A26_VALOR3 " +CRLF
cQry += "	FROM   " +RetSqlName("A25") +" A25" +CRLF
//	--DEDUÇAO DA RECEITA
cQry += "	LEFT JOIN   " +RetSqlName("A26") +" A26" +CRLF
cQry += "	ON A26_FILIAL = '" + FwxFilial("A26") + "'" +CRLF
cQry += "	WHERE A25_FILIAL = '" + FwxFilial("A25") + "'" +CRLF
cQry += "	AND A25_ANO = '"+ cAno3 +"'" +CRLF
cQry += "	AND A26_ANO = A25_ANO" +CRLF
cQry += "	AND A25_CATEGO = '1'" +CRLF
cQry += "	AND A26_CATEGO  = '1'" +CRLF
cQry += "	AND A25.D_E_L_E_T_ = ''" +CRLF
cQry += "	AND A26.D_E_L_E_T_ = ''" +CRLF
cQry += "	GROUP BY A25_CATEGO,A26_VALOR) TAB" +CRLF
cQry += "GROUP BY A25_CATEGO" +CRLF
cQry += "ORDER BY A25_CATEGO" +CRLF


cQry := ChangeQuery(cQry)


dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlsA25,.T.,.F.)
(cAlsA25)->(dbGoTop())  
If ((cAlsA25)->(!EOF()))
  
        //DESPESA TOTAL
        //PRIMEIRO ANO
        aDados[DADOS_DT][DD_VLCR1] := (cAlsA25)->(A25_VLRPR1) + (cAlsA25)->(A26_VALOR1) //Valor Corrente (a)
        aDados[DADOS_DT][DD_VLCS1] := aDados[DADOS_DT][DD_VLCR1] / (1 + (nIndice1/100) ) //Valor Constante
        aDados[DADOS_DT][DD_VLPB1] := (aDados[DADOS_DT][DD_VLCR1] / nPIB1) * 100  //% PIB (a / PIB)

        //SEGUNDO ANO
        aDados[DADOS_DT][DD_VLCR2] := (cAlsA25)->(A25_VLRPR2) + (cAlsA25)->(A26_VALOR2) //Valor Corrente (a)
        aDados[DADOS_DT][DD_VLCS2] := aDados[DADOS_DT][DD_VLCR2] / (1 + (nIndice2/100) ) //Valor Constante
        aDados[DADOS_DT][DD_VLPB2] := (aDados[DADOS_DT][DD_VLCR2] / nPIB2) * 100  //% PIB (a / PIB)

        //TERCEIRO ANO
        aDados[DADOS_DT][DD_VLCR3] := (cAlsA25)->(A25_VLRPR3) + (cAlsA25)->(A26_VALOR3) //Valor Corrente (a)
        aDados[DADOS_DT][DD_VLCS3] := aDados[DADOS_DT][DD_VLCR3] / (1 + (nIndice3/100) ) //Valor Constante
        aDados[DADOS_DT][DD_VLPB3] := (aDados[DADOS_DT][DD_VLCR3] / nPIB3) * 100  //% PIB (a / PIB)

        //DESPESA PRIMARIA
        //PRIMEIRO ANO
        aDados[DADOS_DP][DD_VLCR1] :=  aDados[DADOS_DT][DD_VLCR1] - nJrsDesp //-JUROS MV_PARXX //Valor Corrente (a)
        aDados[DADOS_DP][DD_VLCS1] := aDados[DADOS_DP][DD_VLCR1]  / (1 + (nIndice1/100) ) //Valor Constante
        aDados[DADOS_DP][DD_VLPB1] := (aDados[DADOS_DP][DD_VLCR1]  / nPIB1) * 100  //% PIB (a / PIB)

        //SEGUNDO ANO
        aDados[DADOS_DP][DD_VLCR2] := aDados[DADOS_DT][DD_VLCR2] - nJrsDesp //-MV_PARXX //Valor Corrente (a)
        aDados[DADOS_DP][DD_VLCS2] := aDados[DADOS_DP][DD_VLCR2] / (1 + (nIndice2/100) ) //Valor Constante
        aDados[DADOS_DP][DD_VLPB2] := (aDados[DADOS_DP][DD_VLCR2] / nPIB2) * 100  //% PIB (a / PIB)

        //TERCEIRO ANO
        aDados[DADOS_DP][DD_VLCR3] := aDados[DADOS_DT][DD_VLCR3] - nJrsDesp //-MV_PARXX //Valor Corrente (a)
        aDados[DADOS_DP][DD_VLCS3] := aDados[DADOS_DP][DD_VLCR3] / (1 + (nIndice3/100) ) //Valor Constante
        aDados[DADOS_DP][DD_VLPB3] := aDados[DADOS_DP][DD_VLCR3] / (nPIB3 * 100 ) //% PIB (a / PIB)
    (cAlsA25)->(dbSkip())
EndIf

(cAlsA25)->( dbCloseArea() )

//QUERY PRA RECEITA CATEGORIA = 2
cQry := "SELECT A25_CATEGO , " +CRLF
cQry += "SUM(A25_VLRPRE1) A25_VLRPR1, SUM(A26_VALOR1) A26_VALOR1, " +CRLF
cQry += "SUM(A25_VLRPRE2) A25_VLRPR2, SUM(A26_VALOR2) A26_VALOR2, " +CRLF
cQry += "SUM(A25_VLRPRE3) A25_VLRPR3, SUM(A26_VALOR3) A26_VALOR3  " +CRLF
cQry += "FROM ( " +CRLF
cQry += "	SELECT A25_CATEGO, " +CRLF
cQry += "	SUM(A25_VLRPRE) A25_VLRPRE1, A26_VALOR A26_VALOR1, " +CRLF
cQry += "	0 A25_VLRPRE2, 0 A26_VALOR2, " +CRLF
cQry += "	0 A25_VLRPRE3, 0 A26_VALOR3 " +CRLF
cQry += "	FROM  " +RetSqlName("A25") +" A25" +CRLF
//	--DEDUÇAO DA RECEITA
cQry += "	LEFT JOIN  " +RetSqlName("A26") +" A26" +CRLF
cQry += "	ON A26_FILIAL = '" + FwxFilial("A26") + "'" +CRLF
cQry += "	WHERE A25_FILIAL = '" + FwxFilial("A25") + "'" +CRLF
cQry += "	AND A25_ANO =  '"+ cAno1 +"'" +CRLF
cQry += "	AND A26_ANO = A25_ANO" +CRLF
cQry += "	AND A25_CATEGO = '2'" +CRLF
cQry += "	AND A26_CATEGO = '2'" +CRLF
cQry += "	AND A25.D_E_L_E_T_ = ''" +CRLF
cQry += "	AND A26.D_E_L_E_T_ = ''" +CRLF
cQry += "	GROUP BY A25_CATEGO,A26_VALOR" +CRLF

cQry += "	UNION ALL " +CRLF

cQry += "	SELECT A25_CATEGO, " +CRLF
cQry += "	0 A25_VLRPRE1, 0 A26_VALOR1, " +CRLF
cQry += "	SUM(A25_VLRPRE) A25_VLRPRE2, A26_VALOR A26_VALOR2, " +CRLF
cQry += "	0 A25_VLRPRE3, 0 A26_VALOR3" +CRLF
cQry += "	FROM   " +RetSqlName("A25") +" A25" +CRLF
//	--DEDUÇAO DA RECEITA
cQry += "	LEFT JOIN   " +RetSqlName("A26") +" A26" +CRLF
cQry += "	ON A26_FILIAL = '" + FwxFilial("A26") + "'" +CRLF
cQry += "	WHERE A25_FILIAL = '" + FwxFilial("A25") + "'" +CRLF
cQry += "	AND A25_ANO = '"+ cAno2 +"'" +CRLF
cQry += "	AND A26_ANO = A25_ANO" +CRLF
cQry += "	AND A25_CATEGO = '2'" +CRLF
cQry += "	AND A26_CATEGO = '2'" +CRLF
cQry += "	AND A25.D_E_L_E_T_ = ''" +CRLF
cQry += "	AND A26.D_E_L_E_T_ = ''" +CRLF
cQry += "	GROUP BY A25_CATEGO,A26_VALOR " +CRLF

cQry += "	UNION ALL " +CRLF

cQry += "	SELECT A25_CATEGO, " +CRLF 
cQry += "	0 A25_VLRPRE1, 0 A26_VALOR1, " +CRLF
cQry += "	0 A25_VLRPRE2, 0 A26_VALOR2, " +CRLF
cQry += "	SUM(A25_VLRPRE) A25_VLRPRE3, A26_VALOR A26_VALOR3 " +CRLF
cQry += "	FROM   " +RetSqlName("A25") +" A25" +CRLF
//	--DEDUÇAO DA RECEITA
cQry += "	LEFT JOIN   " +RetSqlName("A26") +" A26" +CRLF
cQry += "	ON A26_FILIAL = '" + FwxFilial("A26") + "'" +CRLF
cQry += "	WHERE A25_FILIAL = '" + FwxFilial("A25") + "'" +CRLF
cQry += "	AND A25_ANO = '"+ cAno3 +"'" +CRLF
cQry += "	AND A26_ANO = A25_ANO" +CRLF
cQry += "	AND A25_CATEGO = '2'" +CRLF
cQry += "	AND A26_CATEGO  = '2'" +CRLF
cQry += "	AND A25.D_E_L_E_T_ = ''" +CRLF
cQry += "	AND A26.D_E_L_E_T_ = ''" +CRLF
cQry += "	GROUP BY A25_CATEGO,A26_VALOR) TAB" +CRLF
cQry += "GROUP BY A25_CATEGO" +CRLF
cQry += "ORDER BY A25_CATEGO" +CRLF

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlsA25,.T.,.F.)
(cAlsA25)->(dbGoTop())  
If ((cAlsA25)->(!EOF()))
    //RECEITA TOTAL
        //PRIMEIRO ANO
        aDados[DADOS_RT][DD_VLCR1] := (cAlsA25)->(A25_VLRPR1) + (cAlsA25)->(A26_VALOR1) //Valor Corrente (a)
        aDados[DADOS_RT][DD_VLCS1] := aDados[DADOS_RT][DD_VLCR1] / (1 + (nIndice1/100) ) //Valor Constante
        aDados[DADOS_RT][DD_VLPB1] := (aDados[DADOS_RT][DD_VLCR1] / nPIB1) * 100  //% PIB (a / PIB)

        //SEGUNDO ANO
        aDados[DADOS_RT][DD_VLCR2] := (cAlsA25)->(A25_VLRPR2) + (cAlsA25)->(A26_VALOR2) //Valor Corrente (a)
        aDados[DADOS_RT][DD_VLCS2] := aDados[DADOS_RT][DD_VLCR2] / (1 + (nIndice2/100) ) //Valor Constante
        aDados[DADOS_RT][DD_VLPB2] := (aDados[DADOS_RT][DD_VLCR2] / nPIB2) * 100  //% PIB (a / PIB)

        //TERCEIRO ANO
        aDados[DADOS_RT][DD_VLCR3] := (cAlsA25)->(A25_VLRPR3) + (cAlsA25)->(A26_VALOR3) //Valor Corrente (a)
        aDados[DADOS_RT][DD_VLCS3] := aDados[DADOS_RT][DD_VLCR3] / (1 + (nIndice3/100) ) //Valor Constante
        aDados[DADOS_RT][DD_VLPB3] := (aDados[DADOS_RT][DD_VLCR3] / nPIB3) * 100  //% PIB (a / PIB)
        
        //RECEITA PRIMARIA
        //PRIMEIRO ANO
        aDados[DADOS_RP][DD_VLCR1] := aDados[DADOS_RT][DD_VLCR1] - nJrsResp  //Valor Corrente (a)
        aDados[DADOS_RP][DD_VLCS1] := aDados[DADOS_RP][DD_VLCR1] / (1 + (nIndice1/100) ) //Valor Constante
        aDados[DADOS_RP][DD_VLPB1] := (aDados[DADOS_RP][DD_VLCR1] / nPIB1) * 100  //% PIB (a / PIB)

        //SEGUNDO ANO
        aDados[DADOS_RP][DD_VLCR2] := aDados[DADOS_RT][DD_VLCR2] - nJrsResp  //Valor Corrente (a)
        aDados[DADOS_RP][DD_VLCS2] := aDados[DADOS_RP][DD_VLCR2] / (1 + (nIndice2/100) ) //Valor Constante
        aDados[DADOS_RP][DD_VLPB2] := (aDados[DADOS_RP][DD_VLCR2] / nPIB2) * 100 //% PIB (a / PIB)
        //TERCEIRO ANO
        aDados[DADOS_RP][DD_VLCR3] := aDados[DADOS_RT][DD_VLCR3] - nJrsResp  //Valor Corrente (a)
        aDados[DADOS_RP][DD_VLCS3] := aDados[DADOS_RP][DD_VLCR3] / (1 + (nIndice3/100) ) //Valor Constante
        aDados[DADOS_RP][DD_VLPB3] := (aDados[DADOS_RP][DD_VLCR3] / nPIB3 )* 100  //% PIB (a / PIB)
    (cAlsA25)->(dbSkip())
EndIf


(cAlsA25)->( dbCloseArea() )

//query divida publica
cQry := "SELECT SUM(A27_VALOR1) A27_VALOR1 ,SUM(A27_VALOR2) A27_VALOR2, SUM(A27_VALOR3) A27_VALOR3, A27_CATEGO" +CRLF
cQry += "FROM (" +CRLF
cQry += "   SELECT SUM(A27_VALOR) A27_VALOR1, 0 A27_VALOR2, 0 A27_VALOR3, A27_CATEGO FROM  " +RetSqlName("A27") +" A27" +CRLF
cQry += "   WHERE A27_FILIAL = '" + FwxFilial("A27") + "'" +CRLF
cQry += "   AND A27_ANO =  '"+ cAno1 +"'" +CRLF
cQry += "   AND A27.D_E_L_E_T_ = ''" +CRLF
cQry += "	GROUP BY A27_CATEGO" +CRLF
cQry += "   UNION ALL" +CRLF
cQry += "   SELECT 0 A27_VALOR1, SUM(A27_VALOR)A27_VALOR2, 0 A27_VALOR3, A27_CATEGO FROM  " +RetSqlName("A27") +" A27" +CRLF
cQry += "   WHERE A27_FILIAL = '" + FwxFilial("A27") + "'" +CRLF
cQry += "   AND A27_ANO =  '"+ cAno2 +"'" +CRLF
cQry += "   AND A27.D_E_L_E_T_ = ''" +CRLF
cQry += "	GROUP BY A27_CATEGO" +CRLF
cQry += "   UNION ALL" +CRLF
cQry += "   SELECT 0 A27_VALOR1, 0 A27_VALOR2, SUM(A27_VALOR) A27_VALOR3, A27_CATEGO FROM  " +RetSqlName("A27") +" A27" +CRLF
cQry += "   WHERE A27_FILIAL = '" + FwxFilial("A27") + "'" +CRLF
cQry += "   AND A27_ANO =  '"+ cAno3 +"'" +CRLF
cQry += "   AND A27.D_E_L_E_T_ = ''
cQry += "	GROUP BY A27_CATEGO) TAB" +CRLF
cQry += "	GROUP BY A27_CATEGO" +CRLF


cQry := ChangeQuery(cQry)


dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlsA25,.T.,.F.)
(cAlsA25)->(dbGoTop())  
While ((cAlsA25)->(!EOF()))
    //DIVIDA CONSOLIDADA
    If (cAlsA25)->(A27_CATEGO) == '1'
        //PRIMEIRO ANO
        aDados[DADOS_DC][DD_VLCR1] := (cAlsA25)->(A27_VALOR1) //Valor Corrente (a)
        aDados[DADOS_DC][DD_VLCS1] := aDados[DADOS_DC][DD_VLCR1] / (1 + nIndice1 ) //Valor Constante
        aDados[DADOS_DC][DD_VLPB1] := (aDados[DADOS_DC][DD_VLCR1] / nPIB1) * 100  //% PIB (a / PIB)

        //SEGUNDO ANO
        aDados[DADOS_DC][DD_VLCR2] := (cAlsA25)->(A27_VALOR2)  //Valor Corrente (a)
        aDados[DADOS_DC][DD_VLCS2] := aDados[DADOS_DC][DD_VLCR2] / (1 + nIndice2 ) //Valor Constante
        aDados[DADOS_DC][DD_VLPB2] := (aDados[DADOS_DC][DD_VLCR2] / nPIB2) * 100  //% PIB (a / PIB)

        //TERCEIRO ANO
        aDados[DADOS_DC][DD_VLCR3] := (cAlsA25)->(A27_VALOR3) //Valor Corrente (a)
        aDados[DADOS_DC][DD_VLCS3] := aDados[DADOS_DC][DD_VLCR3] / (1 + nIndice3 ) //Valor Constante
        aDados[DADOS_DC][DD_VLPB3] := (aDados[DADOS_DC][DD_VLCR3] / nPIB3) * 100  //% PIB (a / PIB)
    EndIf   
    
    //DIVIDA PUBLICA
    IF (cAlsA25)->(A27_CATEGO) == '2'
        //PRIMEIRO ANO
        aDados[DADOS_DL][DD_VLCR1] := (cAlsA25)->(A27_VALOR1) //Valor Corrente (a)
        aDados[DADOS_DL][DD_VLCS1] := aDados[DADOS_DL][DD_VLCR1] / (1 + nIndice1 ) //Valor Constante
        aDados[DADOS_DL][DD_VLPB1] := (aDados[DADOS_DL][DD_VLCR1] / nPIB1) * 100  //% PIB (a / PIB)

        //SEGUNDO ANO
        aDados[DADOS_DL][DD_VLCR2] := (cAlsA25)->(A27_VALOR2)  //Valor Corrente (a)
        aDados[DADOS_DL][DD_VLCS2] := aDados[DADOS_DL][DD_VLCR2] / (1 + nIndice2 ) //Valor Constante
        aDados[DADOS_DL][DD_VLPB2] := (aDados[DADOS_DL][DD_VLCR2] / nPIB2) * 100  //% PIB (a / PIB)

        //TERCEIRO ANO
        aDados[DADOS_DL][DD_VLCR3] := (cAlsA25)->(A27_VALOR3) //Valor Corrente (a)
        aDados[DADOS_DL][DD_VLCS3] := aDados[DADOS_DL][DD_VLCR3] / (1 + nIndice3 ) //Valor Constante
        aDados[DADOS_DL][DD_VLPB3] := (aDados[DADOS_DL][DD_VLCR3] / nPIB3) * 100  //% PIB (a / PIB)
    EndIf
    (cAlsA25)->(dbSkip())    
End

        //RESULTADO PRIMARIO 
        //PRIMEIRO ANO
        aDados[DADOS_III][DD_VLCR1] := aDados[DADOS_RP][DD_VLCR1] - aDados[DADOS_DP][DD_VLCR1] //Valor Corrente (a)
        aDados[DADOS_III][DD_VLCS1] := aDados[DADOS_III][DD_VLCR1] / (1 + (nIndice1/100) ) //Valor Constante
        aDados[DADOS_III][DD_VLPB1] := (aDados[DADOS_III][DD_VLCR1] / nPIB1) * 100  //% PIB (a / PIB)

        //SEGUNDO ANO
        aDados[DADOS_III][DD_VLCR2] := aDados[DADOS_RP][DD_VLCR2] - aDados[DADOS_DP][DD_VLCR2] //Valor Corrente (a)
        aDados[DADOS_III][DD_VLCS2] := aDados[DADOS_III][DD_VLCR2] / (1 + (nIndice2/100) ) //Valor Constante
        aDados[DADOS_III][DD_VLPB2] := (aDados[DADOS_III][DD_VLCR2] / nPIB2) * 100  //% PIB (a / PIB)

        //TERCEIRO ANO
        aDados[DADOS_III][DD_VLCR3] := aDados[DADOS_RP][DD_VLCR3] - ABS(aDados[DADOS_DP][DD_VLCR3])//Valor Corrente (a)
        aDados[DADOS_III][DD_VLCS3] := aDados[DADOS_III][DD_VLCR3] / (1 + (nIndice3/100) ) //Valor Constante
        aDados[DADOS_III][DD_VLPB3] := (aDados[DADOS_III][DD_VLCR3] / nPIB3) * 100  //% PIB (a / PIB)
       
        //RESULTADO NOMINAL
        //PRIMEIRO ANO
        aDados[DADOS_RN][DD_VLCR1] := aDados[DADOS_III][DD_VLCR1] + nJED1//-Juros e Encargos da Dívida  //Valor Corrente (a)
        aDados[DADOS_RN][DD_VLCS1] := aDados[6][DD_VLCR1] / (1 + (nIndice1/100) ) //Valor Constante
        aDados[DADOS_RN][DD_VLPB1] := (aDados[6][DD_VLCR1] / nPIB1) * 100  //% PIB (a / PIB)

        //SEGUNDO ANO
        aDados[DADOS_RN][DD_VLCR2] := aDados[DADOS_III][DD_VLCR2] + nJED2 //-Juros e Encargos //Valor Corrente (a)
        aDados[DADOS_RN][DD_VLCS2] := aDados[6][DD_VLCR2] / (1 + (nIndice2/100) ) //Valor Constante
        aDados[DADOS_RN][DD_VLPB2] := (aDados[6][DD_VLCR2] / nPIB2) * 100  //% PIB (a / PIB)

        //TERCEIRO ANO
        aDados[DADOS_RN][DD_VLCR3] := aDados[DADOS_III][DD_VLCR3] + nJED3 //-Juros e Encargos//Valor Corrente (a)
        aDados[DADOS_RN][DD_VLCS3] := aDados[6][DD_VLCR3] / (1 + (nIndice3/100) ) //Valor Constante
        aDados[DADOS_RN][DD_VLPB3] := (aDados[6][DD_VLCR3] / nPIB3) * 100  //% PIB (a / PIB)
       
(cAlsA25)->( dbCloseArea() )


Return aDados 
