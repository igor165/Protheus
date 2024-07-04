#Include "PCOR088.CH"
#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR088
Relatorio de Avaliação do Cumprimento das Metas Fiscais do Exercício Anterior

@author Totvs
   
@version P12
@since   24/11/2020
@return  0
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR088()

Local oReport := 0
Local cPerg   := Padr("PCOR088", Len(SX1->X1_GRUPO), " ")

//=================================================================================================================================================
//	MV_PAR01 - Exercicio  ?
//	MV_PAR02 - moeda      ?
//	MV_PAR03 - Valor dos Juros para Receita ?
//	MV_PAR04 - Valor dos Juros para Desepsa ?
//	MV_PAR05 - Divide Por  ?
//=================================================================================================================================================

SX1->(dbSetOrder(1))

/*If GetRpoRelease() < "12.1.031"
    Help(,, "VER_RELEASE",, OemToAnsi(STR0001), 1, 0) //"Relatorio de Avaliação do Cumprimento das Metas Fiscais do Exercício Anterior " //" disponí­vel a partir da versao 12.1.31"
ElseIf !SX1->(dbSeek(cPerg))
    Help(,, "NO_PERG",, OemToAnsi(STR0002), 1, 0) //"Para Relatorio de Avaliação do Cumprimento das Metas Fiscais do Exercício Anterior é necessário aplicar o pacote acumulado da controladoria." 
Else */                
    oReport := ReportDef(cPerg)

    If ValType(oReport) == "O"    
        oReport:PrintDialog()
    EndIf

    oReport := 0
//EndIf
	
Return 0

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   26/11/2020
@return  0
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oCabec1, oCabec2, oBorder
Local cNomeProg := "PCOR088"
Local cTitulo   := Capital(STR0001)  //"Relatorio de Avaliação do Cumprimento das Metas Fiscais do Exercício Anterior"
Local cDescri 	:= OemToAnsi(STR0003) //"Este programa irá imprimir o Relatorio de Avaliação do Cumprimento das Metas Fiscais do Exercício Anterior."
//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                                  {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

//oReport:nFontBody := 7 //Define o tamanho da fonte

oBorder := TRBorder():New(oReport, 5,, 0)

//Criacao da Secao Cabecalho 1
oCabec1 := TRSection():New(oReport, "CABEC_1", {}, /*aOrdem*/) 
TRCell():New(oCabec1, "CABEC_1",, STR0004,, 60, /*lPixel*/, /*CodeBlock*/, "CENTER",, "CENTER",,,,,, .T.) //" Avaliação do Cumprimento das Metas Fiscais do Exercício Anterior"
oCabec1:oHBrdBottom := oBorder //Remove a borda do cabecalho 1
oCabec1:setLinesBefore(0)

//Criacao da Secao Cabecalho 1
oCabec2 := TRSection():New(oReport, STR0005, {}, /*aOrdem*/)  // "EXERCICIO "
TRCell():New(oCabec2, "EXERCICIO",, "",, 60, /*lPixel*/, /*CodeBlock*/, "CENTER",, "CENTER",,,,,, .T.) 
oCabec2:oHBrdBottom := oBorder //Remove a borda do cabecalho 2
oCabec2:setLinesBefore(0)

//Criacao da Secao Receitas e Despesas
oRecDesp := TRSection():New(oReport, "RECDESP", {"cArqTmp"},, .F., .F.)

//Colunas da Estrutura - Orgaos e Unidades
TRCell():New(oRecDesp, "ESPECIFICACAO" ,, STR0006 /*Titulo*/, PesqPict("A25", "A25_DESCCE"), TamSx3("A25_DESCCE")[1] /*Tamanho*/, /*lPixel*/, {|| Cod_Receit()}           /*CodeBlock*/, "LEFT",  .T.,"CENTER")  //"ESPECIFICAÇÃO"
TRCell():New(oRecDesp, "METAPREV"      ,, STR0007 /*Titulo*/, PesqPict("A25", "A25_VLRPRE"), TamSx3("A25_VLRPRE")[1] /*Tamanho*/, /*lPixel*/, {|| Des_Receit()}           /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"Metas Previstas em "
TRCell():New(oRecDesp, "PIB1"          ,, STR0008 /*Titulo*/, "@E 9,999,999.999",                                           /*Tamanho*/, /*lPixel*/, {|| Val_Receit(oReport, 1)} /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"% PIB"
TRCell():New(oRecDesp, "METAREA"       ,, STR0009 /*Titulo*/, PesqPict("A25", "A25_VLRREA"), TamSx3("A25_VLRREA")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Receit(oReport, 2)} /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"Metas Realizadas em "
TRCell():New(oRecDesp, "PIB2"          ,, STR0010 /*Titulo*/, "@E 9,999,999.999",                                          /*Tamanho*/, /*lPixel*/, {|| Val_Receit(oReport)}    /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"% PIB "
TRCell():New(oRecDesp, "VARIA1"        ,, STR0011 /*Titulo*/, PesqPict("A25", "A25_VLRREA"), TamSx3("A25_VLRREA")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Receit(oReport)}    /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"Variação"
TRCell():New(oRecDesp, "VARIA2"        ,, STR0011 /*Titulo*/, PesqPict("A25", "A25_VLRREA"), TamSx3("A25_VLRREA")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Receit(oReport)}    /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"Variação"

oRecDesp:SetLinesBefore(0)


Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao  
utilizadas

@author Totvs
   
@version P12
@since   15/10/2020
@return  0
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport) 

Local oSection1 := oReport:Section("RECDESP")
// Local cArqTmp   := GetNextAlias()
Local aDados    := {}
Local nX        := 0
/*
MV_PAR01 - Exercício ?                   	¿Ejercicio ?                  	 ?                            	MV_CH1	C	4	0
MV_PAR02 - Qual Moeda ?                  	¿Qué moneda ?                 	 ?                            	MV_CH2	C	2	0
MV_PAR03 - Qual Vlr deJuros p Receita ?  	¿Qué Val de Interés p/Ingreso 	 ?                            	MV_CH3	N	12	2
MV_PAR04 - Qual Vlr de Juros p Despesa ? 	¿Qué Val de Interés p/Gastos ?	 ?                            	MV_CH4	N	12	2
MV_PAR05 - Divide por ?                  	¿Divide entre ?               	 ?                            	MV_CH5	N	1	0
*/

/*             ESPECIFICAÇÃO                    , Metas Previstas , %PIB , Metas Realizadas,   %PIB        ,Varicao1   , VAriacao2        
                                                  em 2019(a)               em 2019 (b)                                             
      
aAdd(aDados,{"Receita Total"                     ,0               ,0     ,0                 ,0              ,0          ,  0})
aAdd(aDados,{"Receitas Primárias (I)"            ,0               ,0     ,0                 ,0              ,0          ,  0})
aAdd(aDados,{"Despesa Total"                     ,0               ,0     ,0                 ,0              ,0          ,  0})
aAdd(aDados,{"Despesas Primárias (II)"           ,0               ,0     ,0                 ,0              ,0          ,  0})
aAdd(aDados,{"Resultado Primário (III = I – II)" ,0               ,0     ,0                 ,0              ,0          ,  0})
aAdd(aDados,{"Resultado Nominal"                 ,0               ,0     ,0                 ,0              ,0          ,  0})
aAdd(aDados,{"Dívida Pública Consolidada"        ,0               ,0     ,0                 ,0              ,0          ,  0})
aAdd(aDados,{"Dívida Consolidada Líquida"        ,0               ,0     ,0                 ,0              ,0          ,  0})*/
/* Monta array para impressao */
Pr88Dados(aDados)

oSection1:Init()
For nX := 1 to Len(aDados)

    oSection1:Cell("ESPECIFICACAO"):SetBlock ( {||aDados[nX][1]} )
    oSection1:Cell("METAPREV"):SetBlock ( {||aDados[nX][2]} ) 
    oSection1:Cell("PIB1"):SetBlock ( {||aDados[nX][3]} ) 
    oSection1:Cell("METAREA"):SetBlock ( {||aDados[nX][4]} ) 
    oSection1:Cell("PIB2"):SetBlock ( {||aDados[nX][5]} ) 
    oSection1:Cell("VARIA1"):SetBlock ( {||aDados[nX][6]} ) 
    oSection1:Cell("VARIA2"):SetBlock ( {||aDados[nX][7]} ) 

    oSection1:PrintLine()
Next nX
oSection1:Finish()

//Fecha arquivo temporario
/*If Select("cArqTmp") > 0
    (cArqTmp)->(dbCloseArea()) 
EndIf
*/
Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCabec
Cabecalho do relatorio - imprimir em todas as paginas

@author Totvs
   
@version P12
@since   15/10/2020
@return  0
@obs	 
*/
//-------------------------------------------------------------------

Static Function ImpCabec(oReport, oCabec1, oCabec2)

//Imprime cabecalho
oCabec1:Init()
oCabec2:Init()

oCabec1:PrintLine()
oCabec2:PrintLine()

oCabec1:Finish()
oCabec2:Finish()

//Pula linha
oReport:SkipLine()

Return 0
//-------------------------------------------------------------------
/*{Protheus.doc} Pr88Dados
   Monta Array para impressao
@author Totvs
   
@version P12
@since   15/10/2020
@return  0
@obs	 
*/
//-------------------------------------------------------------------

Static Function Pr88Dados(aDados)
Local cQuery    := ""
// Local cQryPIB   := ""
Local cArqTmp   := GetNextAlias()
// Local cArqPIB   := GetNextAlias()
Local cExercAnt := Str(Val(mv_par01)-1,4)  // ano anterior
Local nValPIB   := 2422491210
Local nValPIB1  := 0
Local nValPIB2  := 0
Local iX        := 1
Local nPrevisto := 0
Local nRealizado := 0
Local nVariac1 := 0
Local nVariac2 := 0
Local nJUroDivP:= 0
Local nJUroDivR:= 0

dbSelectArea("A25")
dbSetOrder(1)
If MsSeek(xFilial("A25")+"1"+"GD"+"2         "+"2019")
    nJUroDivP:= A25->A25_VLRPRE
    nJUroDivR:= A25->A25_VLRREA
 Endif

/*
cQryPIB := " SELECT A24_PIB VALPIB "+CRLF
cQryPIB := "   FROM "+RetSqlName("A24") +CRLF
cQryPIB += "  WHERE A24_FILIAL = '"+xFilial("A24")+"'" +CRLF
cQryPIB += "    AND D_E_L_E_T_ = ' ' " +CRLF
cQryPIB += "    AND A24_ANO = '"+cExercAnt+"'"+CRLF

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQryPIB), cArqPIB)
If (cArqPIB)->(!Eof())
    nValPIB := (cArqPIB)->(VALPIB)
Endif
(cArqPIB)->(dbCloseArea())*/
/*             ESPECIFICAÇÃO                    , Metas Previstas , %PIB , Metas Realizadas,   %PIB        ,Varicao1   , VAriacao2        
                                                  em 2019(a)               em 2019 (b)                                              */
      
aAdd(aDados,{"Receita Total"                     ,0               ,0     ,0                 ,0              ,0          ,  0})
aAdd(aDados,{"Receitas Primárias (I)"            ,0               ,0     ,0                 ,0              ,0          ,  0})
aAdd(aDados,{"Despesa Total"                     ,0               ,0     ,0                 ,0              ,0          ,  0})
aAdd(aDados,{"Despesas Primárias (II)"           ,0               ,0     ,0                 ,0              ,0          ,  0})
aAdd(aDados,{"Resultado Primário (III = I – II)" ,0               ,0     ,0                 ,0              ,0          ,  0})
aAdd(aDados,{"Resultado Nominal"                 ,0               ,0     ,0                 ,0              ,0          ,  0})
aAdd(aDados,{"Dívida Pública Consolidada"        ,0               ,0     ,0                 ,0              ,0          ,  0})
aAdd(aDados,{"Dívida Consolidada Líquida"        ,0               ,0     ,0                 ,0              ,0          ,  0})

/* Linha 1 - Receita Total */
cQuery := " select A25_FILIAL, A25_CATEGO, 'CONTA', 'DESC' , SUM(A25_VLRPRE) PREVISTO, SUM(A25_VLRREA) REALIZADO, (SUM(A25_VLRREA)-SUM( A25_VLRPRE)) VAR_1, '1-REC' " + CRLF //(SUM(A25_VLRREA)-SUM( A25_VLRPRE))/(SUM( A25_VLRPRE)) PERC, 
cQuery += "   from "+RetSqlName("A25") + CRLF
cQuery += "  WHERE D_E_L_E_T_ = ' ' "  + CRLF
cQuery += "    AND A25_FILIAL =  '"+ xFilial("A25")+"'"+ CRLF
cQuery += "    AND A25_CATEGO = '2' "+ CRLF
cQuery += "    AND A25_CTGECO IN ('O1','O2', 'CE') "+ CRLF
cQuery += "    AND A25_ANO = '"+ cExercAnt +"'" +CRLF ///2019'
cQuery += " GROUP BY  A25_FILIAL, A25_CATEGO "+CRLF  //2	545514731,12	545514731,12
cQuery += " UNION "+ CRLF
/* Linha 2 - Receitas Primárias  */
/* (PREViSTO ACIMA - jUROS do mv_par03) e (REALIZADO - JUROS DO mv_par04) */
/* Linha 3 - Despesa Total */
cQuery += " Select A25_FILIAL, A25_CATEGO, 'CONTA', 'DESC', SUM( A25_VLRPRE) PREVISTO, SUM(A25_VLRREA) REALIZADO,(SUM(A25_VLRREA)-SUM( A25_VLRPRE)) VAR_1, '2-DES' "+ CRLF  //, (SUM(A25_VLRREA)-SUM( A25_VLRPRE))/(SUM( A25_VLRPRE)) PERC
cQuery += "  from "+RetSqlName("A25")+ CRLF
cQuery += " WHERE D_E_L_E_T_ = ' ' "+ CRLF
cQuery += "   AND A25_FILIAL =  '"+ xFilial("A25")+"'"+ CRLF
cQuery += "   AND A25_CATEGO = '1'"+ CRLF
cQuery += "   AND A25_ORIGP IN ('1', '2','3')"+ CRLF
cQuery += "   AND A25_ANO =  '"+ cExercAnt +"'"+ CRLF ///2019' --PARÂMETRO
cQuery += "  GROUP BY  A25_FILIAL, A25_CATEGO "+ CRLF
cQuery += " UNION "+ CRLF
/* linha -7- Dívida Pública Consolidada
   linha -8- Dívida Consolidada Líquida   */
cQuery += " SELECT A27_FILIAL, A27_CATEGO, A27_CONTA, A27_DESC, A27_VALOR, 0, 0, '3-DIV' "+ CRLF
cQuery += "   FROM "+RetSqlName("A27") + CRLF
cQuery += "  WHERE D_E_L_E_T_ = ' ' "+ CRLF
cQuery += "    AND A27_FILIAL =  '"+ xFilial("A27")+"'"+ CRLF
cQuery += "    AND A27_ANO = '"+ cExercAnt +"'"+ CRLF    ///'2019'           ----//pergunta
cQuery += "    AND A27_CATEGO IN ( '1', '2') "+ CRLF
cQuery += " ORDER BY 8, 1, 2"+ CRLF

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cArqTmp)

If (cArqtmp)->(!Eof())
    iX := 0
    While (cArqtmp)->(!Eof())
        iX := iX+1
        // linhas 1 e 2 de aDados
        If ix == 1 .Or. iX == 3 .Or. iX == 7 .Or.  iX == 8  
            nValPIB1 := Iif(nValPIB > 0, (cArqTmp)->(PREVISTO)/nValPIB*100, 0 )
            nValPIB2 := Iif(nValPIB > 0, (cArqTmp)->(REALIZADO)/nValPIB*100, 0)
            nVariac1 := (cArqTmp)->(REALIZADO)-(cArqTmp)->(PREVISTO)
            nVariac2 := Iif((cArqTmp)->(PREVISTO) > 0, nVariac1/(cArqTmp)->(PREVISTO)*100,0)
            /*            ESPECIFICACAO                PREVISTO               PIB1         REALIZADO             PIB2        VAR1    VAR2 
            //linha 1                                                                       */
            //aDados[1][ix],{"Receita Total"             ,(cArqTmp)->(PREVISTO), nValPIB1, (cArqTmp)->(REALIZADO), nValPIB2, nVariac1,nVariac2})              
            aDados[iX][2]:=(cArqTmp)->(PREVISTO); aDados[iX][3]:=nValPIB1; aDados[iX][4]:=(cArqTmp)->(REALIZADO); aDados[iX][5]:=nValPIB2; aDados[iX][6]:=nVariac1; aDados[iX][7]:=nVariac2
            If iX == 1   // preencho a 1 a 2
                iX := 2
                nPrevisto := 0 ;nRealizado := 0; nValPIB1 := 0; nValPIB2 := 0; nVariac1 := 0; nVariac2 := 0
                nPrevisto := aDados[iX-1][2] - mv_par03 - MV_PAR04
                nRealizado:= aDados[iX-1][4] - mv_par03 - MV_PAR04   // mais 2 perg
                nValPIB1 := Iif(nValPIB > 0, nPrevisto/nValPIB*100, 0 )
                nValPIB2 := Iif(nValPIB > 0, nRealizado/nValPIB*100, 0)
                nVariac1 := nRealizado-nPrevisto
                nVariac2 := Iif(nPrevisto > 0, nVariac1/nPrevisto*100, 0)
                //linha 2
                //aAdd(aDados,{"Receitas Primárias (I)"            ,0               ,0     ,0                 ,0              ,0          ,  0})
                aDados[iX][2]:=nPrevisto; aDados[iX][3]:=nValPIB1; aDados[iX][4]:=nRealizado; aDados[iX][5]:=nValPIB2; aDados[iX][6]:=nVariac1; aDados[iX][7]:=nVariac2
            Endif
            If iX == 3  // preencho a linha 3 e 4 e 5
                iX := 4
                nPrevisto := 0 ;nRealizado := 0; nValPIB1 := 0; nValPIB2 := 0; nVariac1 := 0; nVariac2 := 0
                nPrevisto := aDados[iX-1][2] - mv_par03 - MV_PAR04
                nRealizado:= aDados[iX-1][4] - mv_par03 - MV_PAR04   // mais 2 perg
                nValPIB1 := Iif(nValPIB > 0, nPrevisto/nValPIB*100, 0 )
                nValPIB2 := Iif(nValPIB > 0, nRealizado/nValPIB*100, 0)
                nVariac1 := nRealizado-nPrevisto
                nVariac2 := Iif(nPrevisto > 0, nVariac1/nPrevisto*100, 0)
                //linha 2
                //aAdd(aDados,{"Receitas Primárias (I)"            ,0               ,0     ,0                 ,0              ,0          ,  0})
                aDados[iX][2]:=nPrevisto; aDados[iX][3]:=nValPIB1; aDados[iX][4]:=nRealizado; aDados[iX][5]:=nValPIB2; aDados[iX][6]:=nVariac1; aDados[iX][7]:=nVariac2
                iX := 5
                nPrevisto := 0 ;nRealizado := 0; nValPIB1 := 0; nValPIB2 := 0; nVariac1 := 0; nVariac2 := 0
                nPrevisto := aDados[2][2] -aDados[4][2]
                nRealizado:= aDados[4][2] -aDados[4][4]
                nValPIB1 := Iif(nValPIB > 0, nPrevisto/nValPIB*100, 0 )
                nValPIB2 := Iif(nValPIB > 0, nRealizado/nValPIB*100, 0)
                nVariac1 := nRealizado-nPrevisto
                nVariac2 := Iif(nPrevisto > 0, nVariac1/nPrevisto*100, 0)
                //linha5
                //aAdd(aDados,{"Resultado Primário ( I – II)" ,0               ,0     ,0                 ,0              ,0          ,  0})
                aDados[iX][2]:=nPrevisto; aDados[iX][3]:=nValPIB1; aDados[iX][4]:=nRealizado; aDados[iX][5]:=nValPIB2; aDados[iX][6]:=nVariac1; aDados[iX][7]:=nVariac2
                iX := 6
                nPrevisto := 0 ;nRealizado := 0; nValPIB1 := 0; nValPIB2 := 0; nVariac1 := 0; nVariac2 := 0
                nPrevisto := aDados[6][2] + nJUroDivP
                nRealizado:= aDados[4][2] + nJUroDivR
                nValPIB1 := Iif(nValPIB > 0, nPrevisto/nValPIB*100, 0 )
                nValPIB2 := Iif(nValPIB > 0, nRealizado/nValPIB*100, 0)
                nVariac1 := nRealizado-nPrevisto
                nVariac2 := Iif(nPrevisto > 0, nVariac1/nPrevisto*100, 0)
                //linha5
                //aAdd(aDados,{"Resultado Primário ( I – II)" ,0               ,0     ,0                 ,0              ,0          ,  0})
                aDados[iX][2]:=nPrevisto; aDados[iX][3]:=nValPIB1; aDados[iX][4]:=nRealizado; aDados[iX][5]:=nValPIB2; aDados[iX][6]:=nVariac1; aDados[iX][7]:=nVariac2
            Endif
        EndIf
        /* 1-({"Receita Total"             ,(cArqTmp)->(PREVISTO),0     ,(cArqTmp)->(REALIZADO)                 ,0              ,0          ,  0})
            2-({"Receitas Primárias (I)"            ,0               ,0     ,0                 ,0              ,0          ,  0})
            3-({"Despesa Total"                     ,0               ,0     ,0                 ,0              ,0          ,  0})
            4-({"Despesas Primárias (II)"           ,0               ,0     ,0                 ,0              ,0          ,  0})
            5-({"Resultado Primário (III = I – II)" ,0               ,0     ,0                 ,0              ,0          ,  0})
            6-({"Resultado Nominal"                 ,0               ,0     ,0                 ,0              ,0          ,  0})
            7-({"Dívida Pública Consolidada"        ,0               ,0     ,0                 ,0              ,0          ,  0})
            8-({"Dívida Consolidada Líquida"        ,0               ,0     ,0                 ,0              ,0          ,  0})
            */               
        (cArqTmp)->(dbSkip())    
    End
EndIf
(cArqTmp)->(dbCloseArea())
Return(aDados)