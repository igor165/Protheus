#Include "PCOR087.ch"
#Include "PROTHEUS.CH"

#DEFINE CODTAB 1
#DEFINE DESTAB 2
#DEFINE CPOMOV 3
#DEFINE POSINI 4
#DEFINE QTDDIG 5
#DEFINE ITETAB 6
#DEFINE ITECHV 1
#DEFINE ITEDES 2

#DEFINE TAMDESCRI 60

Static __nCatOpc := 1
Static __cCpoValor := "AKD_VALOR1"
Static __aTabDE    := {}
Static __aTabGD    := {}
Static __aTabCE    := {}
STATIC __aTotGeral := { {0,0,0}, {0,0,0}}

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR087
Relatorio Demonstrativo das Receitas de Operações de Crédito e Despesas de Capital

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR087()

Local oReport
Local cPerg    := "PCOR087"
Local cFindSX1 := Padr("PCOR087", Len(SX1->X1_GRUPO), " ")

//=================================================================================================================================================
//Pergunta 01 : Exercicio ?	                    2020
//Pergunta 02 : Bimestre ?	                    1
//Pergunta 03 : Aglut.Rec.Prev.Atualiz. ?	    001
//Pergunta 04 : Aglut.Receitas Realiz. ?	    002
//Pergunta 05 : Aglut.Desp.Dot.Atualizada ?	    003
//Pergunta 06 : Aglut.Desp.Empenhadas ?	        004
//Pergunta 07 : Moeda ?	                        01
//Pergunta 08 : Divide Por ?	                Nao se Aplica
//=================================================================================================================================================

SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.025"
    Help(,, "VER_RELEASE",, OemToAnsi(STR0001), 1, 0) //"Relatorio Demonstrativo das Receitas de Operações de Crédito e Despesas de Capital disponí­vel a partir da versao 12.1.31"
ElseIf !SX1->(dbSeek(cFindSX1))
    Help(,, "NO_PERG",, OemToAnsi(STR0002), 1, 0)       //"Para utilização do Relatorio Demonstrativo das Receitas de Operações de Crédito e Despesas de Capital é necessário aplicar o pacote acumulado da controladoria."
Else                 
    oReport := ReportDef(cPerg)

    If ValType(oReport) == "O"    
        oReport:PrintDialog()
    EndIf

    oReport := Nil    
EndIf
	
//CLEAR VAR STATIC
__nCatOpc := 1

__aTabDE    := {}
__aTabGD    := {}
__aTabCE    := {}
__aTotGeral := { {0,0,0}, {0,0,0}}

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oCabec, oReceitas, oDespesas, oQuadro1, oQuadro2, oBorder
Local cNomeProg := "PCOR087"
Local cTitulo   := Capital(STR0003)  //"Relatorio Demonstrativo das Receitas de Operações de Crédito e Despesas de Capital ""
Local cDescri 	:= OemToAnsi(STR0004)  //"Este programa irá imprimir o Relatorio Demonstrativo das Receitas de Operações de Crédito e Despesas de Capital "."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                                  {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:nFontBody := 7          //Define o tamanho da fonte
oReport:SetLandScape(.T.)       //define q relatorio sera sempre em paisagem
oReport:DisableOrientation()

//Criacao da Secao Receitas 
oReceitas := TRSection():New(oReport, STR0005, {"cArqTmp"},, .F., .F.) //"Receitas"
//Colunas referentes as Despesas por Unidade Orçamentária
TRCell():New(oReceitas, "DESCRICAO",, STR0005                           /*Titulo*/, "@!"                   , TAMDESCRI    /*Tamanho*/, /*lPixel*/, {||DescCatRec()      }  /*CodeBlock*/, "LEFT" , .T., "LEFT" ,,,.T.) //"Receitas"
TRCell():New(oReceitas, "VALOR_PRV",, STR0006+CRLF+STR0007              /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValRecPrevisto()  }  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"PREVISÃO"##"ATUALIZADA (a)"
TRCell():New(oReceitas, "VALOR_REA",, STR0008+CRLF+STR0009              /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValRecRealiz()    }  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"RECEITAS"##"REALIZADAS (b)" 
TRCell():New(oReceitas, "VALOR_DIF",, STR0010+CRLF+STR0011+CRLF+STR0012 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValRecDifer()     }  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"SALDO"##"NÃO REALIZADO"##"(c) = (a - b)"
oReceitas:SetLinesBefore(0)


//Criacao da Secao Despesas 
oDespesas := TRSection():New(oReport, STR0013, {"cArqTmp"},, .F., .F.) //"Despesas"
//Colunas referentes as Despesas por Unidade Orçamentária
TRCell():New(oDespesas, "DESCRICAO",, STR0013                           /*Titulo*/, "@!"                   , TAMDESCRI    /*Tamanho*/, /*lPixel*/, {||DescCatDsp()      }   /*CodeBlock*/, "LEFT" , .T., "LEFT" ,,,.T.) //"Despesas"
TRCell():New(oDespesas, "VALOR_ORC",, STR0015+CRLF+STR0016              /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValDspOrcado()    }  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"DOTAÇÃO"##"ATUALIZADA (d) "
TRCell():New(oDespesas, "VALOR_EMP",, STR0017+CRLF+STR0018              /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValDspEmpenho()   }  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"DESPESAS"##EMPENHADAS (e) "
TRCell():New(oDespesas, "VALOR_DIF",, STR0019+CRLF+STR0020+CRLF+STR0021 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValDspDifer()     }  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"SALDO"##"NÃO EXECUTADO"##" (f) = (d - e) "
oDespesas:SetLinesBefore(0)

//Criacao da Secao Despesas 
oApuracao := TRSection():New(oReport, STR0041, {"cArqTmp"},, .F., .F.) //"Apuração"
//Colunas referentes as Despesas por Unidade Orçamentária
TRCell():New(oApuracao, "DESCRICAO" ,, STR0042                                    /*Titulo*/, "@!"                   , TAMDESCRI   /*Tamanho*/, /*lPixel*/, {|| STR0042                              }   /*CodeBlock*/, "LEFT" , .T., "LEFT" ,,,.T.) //"Resultado para Apuração da Regra de Ouro "
TRCell():New(oApuracao, "VAL_D_A"   ,, "(    d - a    )"+CRLF+"_"                /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {|| __aTotGeral[2,1] - __aTotGeral[1,1]  }  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) 
TRCell():New(oApuracao, "VAL_E_B"   ,, "(    e - b    )"+CRLF+"_"                /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {|| __aTotGeral[2,2] - __aTotGeral[1,2]  }  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) 
TRCell():New(oApuracao, "VAL_F_C"   ,, "(    f - c    )"+CRLF+"_"                /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {|| __aTotGeral[2,3] - __aTotGeral[1,3]  }  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) 
oApuracao:SetLinesBefore(0)


oBorder := TRBorder():New(oReport, 5,, 0)
//Criacao da Secao Cabecalho
oCabec := TRSection():New(oReport, STR0022, {}, /*aOrdem*/)  //"Exercício"
TRCell():New(oCabec, "EXERCICIO",, "",, 120, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder   //Remove a borda do cabecalho
oCabec:SetLinesBefore(0)

//Criacao da Secao Quadro I
//Grupo: Tabela 9.0 - Demonstrativo das Receitas de Operações de Crédito e Despesas de Capital 
//Período: 6º bimestre
//Quadro: Receitas 
//Rótulo: Padrão 
oQuadro1 := TRSection():New(oReport, STR0023, {}, /*aOrdem*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , /*<lLineBreak>*/ , /*<nLeftMargin>*/ , .T./*<lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 0 /*<nLinesBefore>*/ , 1/*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ ) //"Quadro I"
TRCell():New(oQuadro1, "GRUPO_I"	,, STR0024	,,120, /*lPixel*/, {||STR0025 }							/*CodeBlock*/,,,,,,,,, .T.)  //"Grupo"## "Tabela 9.0 - Demonstrativo das Receitas de Operações de Crédito e Despesas de Capital "
TRCell():New(oQuadro1, "PERIODO"	,, STR0026	,, 80, /*lPixel*/, {||Alltrim(MV_PAR02)+STR0027}	    /*CodeBlock*/,,,,,,,,, .T.)  //Período" ##"o. Bimestre"
TRCell():New(oQuadro1, "QUADRO_I"	,, STR0028	,, 80, /*lPixel*/, {||STR0005}							/*CodeBlock*/,,,,,,,,, .T.)  //"Quadro"##"Receitas"  
TRCell():New(oQuadro1, "ROTULO"	    ,, STR0029	,, 80, /*lPixel*/, {||STR0030}	                        /*CodeBlock*/,,,,,,,,, .T.)  //"Rotulo" ##"Padrão"

oQuadro2 := TRSection():New(oReport, STR0031, {}, /*aOrdem*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , /*<lLineBreak>*/ , /*<nLeftMargin>*/ , .T./*<lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 0 /*<nLinesBefore>*/ , 1/*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ ) //"Quadro II"
TRCell():New(oQuadro2, "TITREL"		,, ""	,, 190, /*lPixel*/, {||Space(150)+STR0032}                  /*CodeBlock*/,,,,,,,,, .T.)  //"Receitas de Operações de Crédito"

Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao  
utilizadas

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport) 

Local oReceita   := oReport:Section(1) 
Local oDespesa   := oReport:Section(2) 
Local oApuracao  := oReport:Section(3)
Local oCabec     := oReport:Section(4)
Local oQuadroI   := oReport:Section(5)
Local oQuadroII  := oReport:Section(6)

//=================================================================================================================================================
//Pergunta 01 : Exercicio ?	                    2020
//Pergunta 02 : Bimestre ?	                    1
//Pergunta 03 : Aglut.Rec.Prev.Atualiz. ?	    001
//Pergunta 04 : Aglut.Receitas Realiz. ?	    002
//Pergunta 05 : Aglut.Desp.Dot.Atualizada ?	    003
//Pergunta 06 : Aglut.Desp.Empenhadas ?	        004
//Pergunta 07 : Moeda ?	                        01
//Pergunta 08 : Divide Por ?	                Nao se Aplica
//=================================================================================================================================================

Local cAnoExerc  := MV_PAR01
Local cBimestre  := MV_PAR02
Local cAglRecPrv := MV_PAR03
Local cAglRcReal := MV_PAR04
Local cAglDspOrc := MV_PAR05
Local cAglDspEmp := MV_PAR06
Local cMoeda     := MV_PAR07
Local nDivide    := 1

Local dDataIni   := CtoD("01/01/"+cAnoExerc)
Local dDataFim   := CtoD("31/12/"+cAnoExerc)

Local cTitulo    := STR0003 //"Demonstrativo das Receitas de Operações de Crédito e Despesas de Capital"
Local aMoedas    := CtbMoeda(cMoeda) 

Local cArqTmp1    := GetNextAlias()
Local cArqTmp2    := GetNextAlias()
Local cArqTmp3    := GetNextAlias()
Local cArqTmp4    := GetNextAlias()



Local aCpsAdic  := {}
Local cCondSQL  := ""
//retorno da tabela tmp real criada na PcoGerPlan
Local cTbReal1  := ""
Local cTbReal2  := ""
Local cTbReal3  := ""
Local cTbReal4  := ""

Local cQryUpdt  := ""
Local cQryReceita := ""
Local cQryDespesa := ""

Local cArqTmpA  := cArqTmp1+"_A"   //receitas
Local cArqTmpB  := cArqTmp1+"_B"   //despesas

__cCpoValor := "AKD_VALOR"+Alltrim(Str(Val(cMoeda)))

If      cBimestre == "1"
    dDataFim   := LastDay( CtoD("01/02/"+cAnoExerc) )
ElseIf  cBimestre == "2"
    dDataFim   := LastDay( CtoD("01/04/"+cAnoExerc) )
ElseIf  cBimestre == "3"
    dDataFim   := LastDay( CtoD("01/06/"+cAnoExerc) )
ElseIf  cBimestre == "4"
    dDataFim   := LastDay( CtoD("01/08/"+cAnoExerc) )
ElseIf  cBimestre == "5"
    dDataFim   := LastDay( CtoD("01/10/"+cAnoExerc) )
ElseIf  cBimestre == "6"
    dDataFim   := LastDay( CtoD("01/12/"+cAnoExerc) )
EndIf

oReport:OnPageBreak( {|| ImpCabec( oReport, oCabec, aMoedas, MV_PAR08 /*divide por*/, dDataFim) } )

/*
RECEITAS
--------
1 – Categoria Econômica: (1 dígito) – Portaria 387/2019
2 – Origem: (1 dígito) – Portaria 387/2019
3 – Espécie: (1 dígito) – Portaria §§387/2019
4 – Desdobramento para identificação de peculiaridades da recei: (4 dígitos) – Portaria 387/2019
5 – Tipo: (1 dígito) – Portaria 387/2019
6 - Fonte de Recurso (2 - digitos)- Específico(Adicionado após)
7 - Código de Aplicação (4 - digitos) - Específico(Adicionado após)


DESPESAS
----------
1 – Órgão: Unidade Orçamentária + Unidade Executora (6 dígitos) – Campos distintos - Específico      Substr(AKD_CO, 1,6)
2 – Função: (2 dígitos) – Portaria 42/1999                                                           Substr(AKD_CO, 7,2)   
3 – Sub Função: (3 dígitos) – Portaria 42/1999                                                       Substr(AKD_CO, 9,3)
4 – Programas: (4 dígitos) - Específico                                                              Substr(AKD_CO,12,4)
5 – Ação (4 dígitos) - Específico                                                                    Substr(AKD_CO,16,4)
6 – Categoria Econômica ( 1 dígito) – Lei 4.320/64                                                   Substr(AKD_CO,17,1)
7 – Grupo da Despesa ( 1 dígito) – Lei 4.320/64                                                      Substr(AKD_CO,18,1)
8 – Modalidade de Aplicação (2 dígitos) – Lei 4.320/64                                               Substr(AKD_CO,19,2) 
9 – Elemento da despesa (2 dígitos) – Lei 4.320/64                                                   Substr(AKD_CO,21,2)
10 – Sub Elemento da Despesa - Específico                                                            Substr(AKD_CO,23,x)//nao definido
11 – Fonte de Recurso (2 - digitos) - Específico                                                     Substr(AKD_CO, y,z)//nao definido
12 – Código de Aplicação (4 - digitos) - Específico                                                  Substr(AKD_CO, s,t)//nao definido

Neste Relatorio vamos utilizar 
Orgao -> Substr(AKD_CO, 1, 2)
Unidade Orçamentária -> Substr(AKD_CO, 3, 2)
Cat.Economica/Grupo Despesa/Mod Aplicacao/Elemento da Despesa -> Substr(AKD_CO, 17, 6)
Tabela DE-DE - Categ. Economica da Despesa
Tabela GD-GD - Grupo da Despesas
Tabela MA-MA - Modalidade da Aplicação
Tabela ED-ED - Elemento da Despesa
*/
//Divide por
If MV_PAR08 == 2        //Divide por cem
	nDivide := 100
ElseIf MV_PAR08 == 3    //Divide por mil
	nDivide := 1000
ElseIf MV_PAR08 == 4	//Divide por milhao
	nDivide := 1000000
EndIf

//carrega as tabelas A1H
__aTabDE := CargaTab( "DE"/*cTabela*/, "DE"/*cRadical*/)  //Categoria Economica da Despesa
__aTabGD := CargaTab( "GD"/*cTabela*/, "GD"/*cRadical*/)  //Grupo da Despesa
__aTabCE := CargaTab( "CE"/*cTabela*/, "CE"/*cRadical*/)  //Categoria Economica Receita

//RECEITAS
aCpsAdic := {}
//Estrutura a ser adicionada na tabela de saida para group by posterior a PCGERPLAN
aAdd(aCpsAdic, {"AKD_CATEG" ,"C",1,0})

//COLUNAS DO RELATORIO
aAdd(aCpsAdic, {"AKD_VALPRV","N",18,2})
aAdd(aCpsAdic, {"AKD_VALREA","N",18,2})
aAdd(aCpsAdic, {"AKD_VALDIF","N",18,2})


//Condicao a ser adicionada a clausula where da query
cCampo := __aTabCE[CPOMOV]
nPosIni := __aTabCE[POSINI]
nQtDigito := __aTabCE[QTDDIG]

cCondSQL := " AND Substring("+Alltrim(cCampo)+" , "+Alltrim(Str(nPosIni))+" ,"+Alltrim(Str(nQtDigito))+" ) IN ( '2', '8' ) AND "  //2=RECEITAS DE CAPITAL   || 8=RECEITAS DE CAPITAL INTRA ORÇAMENTARIAS 
cCondSQL += "    AKD_CO IN ( SELECT AK5_CODIGO FROM "+RetSqlName("AK5")+ " AK5 "
cCondSQL += "                 WHERE AK5_FILIAL     = '"+xFilial("AK5")+"' AND " 
cCondSQL += "                       AK5_CODIGO     = AKD_CO AND "
cCondSQL += "                       AK5_DEBCRE     = '1' AND "    //CONTAS ORCAMENTARIAS DE RECEITAS
cCondSQL += "                       AK5.D_E_L_E_T_ = ' '  "
cCondSQL += "                )  "

//Monta Arquivo Temporario para Impressao - ORCADO
MsgMeter({|oMeter, oText, oDlg, lEnd| ;
			cTbReal1 := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp1,;
					  cMoeda, .T., cAglRecPrv, dDataIni, dDataFim,;
                      nil,nil,nDivide,aCpsAdic,cCondSQL)},;
			          STR0033, cTitulo) //"Criando Arquivo Temporario..."

//Monta Arquivo Temporario para Impressao - EMPENHADO
MsgMeter({|oMeter, oText, oDlg, lEnd| ;
			cTbReal2 := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp2,;
					  cMoeda, .T., cAglRcReal, dDataIni, dDataFim,;
                      nil,nil,nDivide,aCpsAdic,cCondSQL)},;
			          STR0033, cTitulo) //"Criando Arquivo Temporario..."

If (cArqTmp1)->(!Eof()) .OR. (cArqTmp2)->(!Eof())

   //VALORES PREVISTOS - RECEITAS
    cQryUpdt := " UPDATE "+cTbReal1 
    cQryUpdt += " SET AKD_CATEG  = '2' , "
    cQryUpdt += "     AKD_VALPRV = "+__cCpoValor+" , "
    cQryUpdt += "     AKD_VALDIF = "+__cCpoValor+" , "
    cQryUpdt += "     AKD_VALREA = 0  "

    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf

    //VALORES REALIZADOS - RECEITAS
    cQryUpdt := " UPDATE "+cTbReal2 
    //cQryUpdt += " SET AKD_CATEG  = Substring("+Alltrim(__aTabCE[CPOMOV])+", "+Alltrim(Str(__aTabCE[POSINI]))+", "+Alltrim(Str(__aTabCE[QTDDIG]))+" ), "
    cQryUpdt += " SET AKD_CATEG  = '2' , "
    cQryUpdt += "     AKD_VALPRV = 0 , "
    cQryUpdt += "     AKD_VALDIF = "+__cCpoValor+"*-1 , " //PARA FICAR VALOR NEGATIVO PARA CLAUSULA SUM
    cQryUpdt += "     AKD_VALREA = "+__cCpoValor+" "

    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf
 
    //totalizador para impressao da linha de valores de receitas  
    cQryReceita := " SELECT AKD_CATEG, SUM(AKD_VALPRV) AKD_VALPRV, SUM(AKD_VALREA) AKD_VALREA, SUM(AKD_VALDIF) AKD_VALDIF "
    cQryReceita += " FROM "
    cQryReceita += " ( "
    cQryReceita += " SELECT AKD_CATEG, SUM(AKD_VALPRV) AKD_VALPRV, SUM(AKD_VALREA) AKD_VALREA, SUM(AKD_VALDIF) AKD_VALDIF FROM "+cTbReal1
    cQryReceita += " GROUP BY AKD_CATEG "
    cQryReceita += " UNION ALL " 
    cQryReceita += " SELECT AKD_CATEG, SUM(AKD_VALPRV) AKD_VALPRV, SUM(AKD_VALREA) AKD_VALREA, SUM(AKD_VALDIF) AKD_VALDIF FROM "+cTbReal2
    cQryReceita += " GROUP BY AKD_CATEG "
    cQryReceita += " ) REC_SUM "
    cQryReceita += " GROUP BY AKD_CATEG "
    cQryReceita += " ORDER BY AKD_CATEG "

EndIf

//DESPESAS
aCpsAdic := {}
//Estrutura a ser adicionada na tabela de saida para group by posterior a PCGERPLAN
aAdd(aCpsAdic, {"AKD_CATEG" ,"C",1,0})
aAdd(aCpsAdic, {"AKD_GRPDSP","C",1,0})

//COLUNAS DO RELATORIO
aAdd(aCpsAdic, {"AKD_VALORC","N",18,2})
aAdd(aCpsAdic, {"AKD_VALEMP","N",18,2})
aAdd(aCpsAdic, {"AKD_VALDIF","N",18,2})


//Condicao a ser adicionada a clausula where da query
cCampo := __aTabDE[CPOMOV]
nPosIni := __aTabDE[POSINI]
nQtDigito := __aTabDE[QTDDIG]

cCondSQL := " AND Substring("+Alltrim(cCampo)+" , "+Alltrim(Str(nPosIni))+" , "+Alltrim(Str(nQtDigito))+" ) = '4' AND "  //Despesas de Capitais
cCondSQL += "    AKD_CO IN ( SELECT AK5_CODIGO FROM "+RetSqlName("AK5")+ " AK5 "
cCondSQL += "                 WHERE AK5_FILIAL     = '"+xFilial("AK5")+"' AND "
cCondSQL += "                       AK5_CODIGO     = AKD_CO AND "
cCondSQL += "                       AK5_DEBCRE     = '2' AND "    //CONTAS ORCAMENTARIAS DE DESPESAS
cCondSQL += "                       AK5.D_E_L_E_T_ = ' '  "
cCondSQL += "                )  "

//Monta Arquivo Temporario para Impressao - ORCADO
MsgMeter({|oMeter, oText, oDlg, lEnd| ;
			cTbReal3 := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp3,;
					  cMoeda, .T., cAglDspOrc, dDataIni, dDataFim,;
                      nil,nil,nDivide,aCpsAdic,cCondSQL)},;
			          STR0033, cTitulo) //"Criando Arquivo Temporario..."

//Monta Arquivo Temporario para Impressao - EMPENHADO
MsgMeter({|oMeter, oText, oDlg, lEnd| ;
			cTbReal4 := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp4,;
					  cMoeda, .T., cAglDspEmp, dDataIni, dDataFim,;
                      nil,nil,nDivide,aCpsAdic,cCondSQL)},;
			          STR0033, cTitulo) //"Criando Arquivo Temporario..."


If (cArqTmp3)->(!Eof()) .OR. (cArqTmp4)->(!Eof())

    //VALORES ORCADOS
    cQryUpdt := " UPDATE "+cTbReal3 
    cQryUpdt += " SET AKD_CATEG  = Substring("+Alltrim(__aTabDE[CPOMOV])+", "+Alltrim(Str(__aTabDE[POSINI]))+", "+Alltrim(Str(__aTabDE[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_GRPDSP = Substring("+Alltrim(__aTabGD[CPOMOV])+", "+Alltrim(Str(__aTabGD[POSINI]))+", "+Alltrim(Str(__aTabGD[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_VALORC = "+__cCpoValor+" , "
    cQryUpdt += "     AKD_VALDIF = "+__cCpoValor+" , "
    cQryUpdt += "     AKD_VALEMP = 0  "

    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf

    //VALORES EMPENHADOS
    cQryUpdt := " UPDATE "+cTbReal4
    cQryUpdt += " SET AKD_CATEG  = Substring("+Alltrim(__aTabDE[CPOMOV])+", "+Alltrim(Str(__aTabDE[POSINI]))+", "+Alltrim(Str(__aTabDE[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_GRPDSP = Substring("+Alltrim(__aTabGD[CPOMOV])+", "+Alltrim(Str(__aTabGD[POSINI]))+", "+Alltrim(Str(__aTabGD[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_VALORC = 0 , "
    cQryUpdt += "     AKD_VALEMP = "+__cCpoValor+" , "
    cQryUpdt += "     AKD_VALDIF =  "+__cCpoValor+"*-1  "

    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf

    //--------------------------------------------// 
    //totalizador para impressao das linhas de despesas agrupadas por categoria economica e grupo da despesa 
    cQryDespesa := " SELECT AKD_CATEG, AKD_GRPDSP, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEMP) AKD_VALEMP, SUM(AKD_VALDIF) AKD_VALDIF "
    cQryDespesa += " FROM "
    cQryDespesa += " ( "
    cQryDespesa += " SELECT AKD_CATEG, AKD_GRPDSP, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEMP) AKD_VALEMP, SUM(AKD_VALDIF) AKD_VALDIF FROM "+cTbReal3
    cQryDespesa += " GROUP BY AKD_CATEG, AKD_GRPDSP "
    cQryDespesa += " UNION ALL " 
    cQryDespesa += " SELECT AKD_CATEG, AKD_GRPDSP, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEMP) AKD_VALEMP, SUM(AKD_VALDIF) AKD_VALDIF FROM "+cTbReal4
    cQryDespesa += " GROUP BY AKD_CATEG, AKD_GRPDSP " 

    cQryDespesa += " ) DSP_SUM
    cQryDespesa += " GROUP BY AKD_CATEG, AKD_GRPDSP "
    cQryDespesa += " ORDER BY AKD_CATEG, AKD_GRPDSP "

EndIf  

__aTotGeral := {    {0,0,0},;  //posicao 1 = receitas
                    {0,0,0} }  //posicao 2 = despesas
                        
//--------------------------------------------//
//Receitas
If !Empty(cQryReceita)

    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryReceita) , cArqTmpA )

    dbSelectArea(cArqTmpA)

    oQuadroI:Init()
    oQuadroI:PrintLine()
    oQuadroI:Finish()

    oQuadroII:Init()
    oQuadroII:PrintLine()
    oQuadroII:Finish()

    oReceita:Init()
    __nCatOpc := 1   // 1-Receitas 2-Despesas 3-Regra de Ouro

    oReceita:Cell("VALOR_PRV"):Hide()
    oReceita:Cell("VALOR_REA"):Hide() 
    oReceita:Cell("VALOR_DIF"):Hide()

    oReceita:PrintLine()
    oReport:SkipLine()
    oReport:ThinLine()

    oReceita:Cell("VALOR_PRV"):Show()
    oReceita:Cell("VALOR_REA"):Show() 
    oReceita:Cell("VALOR_DIF"):Show() 

    //Todo o arquivo 
    While (cArqTmpA)->(!Eof())

        If oReport:Cancel()
            Exit
        EndIf

        __nCatOpc := 0   //DESCRICAO DA RECEITA
        oReceita:PrintLine()

        __aTotGeral[1,1] += (cArqTmpA)->( AKD_VALPRV )
        __aTotGeral[1,2] += (cArqTmpA)->( AKD_VALREA )
        __aTotGeral[1,3] += (cArqTmpA)->( AKD_VALDIF )

        (cArqTmpA)->( dbSkip())

    EndDo
    oReceita:Finish()

    oReport:SkipLine()
    oReport:ThinLine()
    oReport:SkipLine()  //pular 2 linhas apos fechamento do quadro receitas  
    oReport:SkipLine()
    //Fecha arquivo temporario
    If Select("cArqTmpA") > 0
        (cArqTmpA)->(dbCloseArea()) 
    EndIf

EndIf


//--------------------------------------------//
//Despesas
If !Empty(cQryDespesa)
    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryDespesa) , cArqTmpB )

    dbSelectArea(cArqTmpB)

    oQuadroI:Cell("QUADRO_I"):SetBlock({|| STR0013 }) //"Despesas"

    oQuadroI:Init()
    oQuadroI:PrintLine()
    oQuadroI:Finish()

    oQuadroII:Cell("TITREL"):SetBlock({|| Space(160)+STR0014 })  //"Despesas de Capital "

    oQuadroII:Init()
    oQuadroII:PrintLine()
    oQuadroII:Finish()

    oDespesa:Init()
    oDespesa:Cell("VALOR_ORC"):Hide()
    oDespesa:Cell("VALOR_EMP"):Hide()
    oDespesa:Cell("VALOR_DIF"):Hide()

    __nCatOpc := 2   // 1-Receitas 2-Despesas 3-Grp Despesas 4-Regra de Ouro
    oDespesa:PrintLine()
    oReport:SkipLine()
    oReport:ThinLine()

    oDespesa:Cell("VALOR_ORC"):Show()
    oDespesa:Cell("VALOR_EMP"):Show()
    oDespesa:Cell("VALOR_DIF"):Show()
    //Todo o arquivo 
    While (cArqTmpB)->(!Eof())

        If oReport:Cancel()
            Exit
        EndIf

        __nCatOpc := 3   // 1-Receitas 2-Despesas 3-Grp Despesas 4-Regra de Ouro
        oDespesa:PrintLine()

        __aTotGeral[2,1] += (cArqTmpB)->( AKD_VALORC )
        __aTotGeral[2,2] += (cArqTmpB)->( AKD_VALEMP )
        __aTotGeral[2,3] += (cArqTmpB)->( AKD_VALDIF )

        (cArqTmpB)->( dbSkip())

    EndDo

    oReport:SkipLine()
    oReport:ThinLine()
    //IMPRIME TOTAL DA DESPESAS   //  DESPESA DE CAPITAL  (II) ]
    oDespesa:Cell("DESCRICAO"):SetBlock({|| Replicate(".",3)+"  DESPESA DE CAPITAL  (II) " })
    oDespesa:Cell("VALOR_ORC"):SetBlock({|| __aTotGeral[2,1] })
    oDespesa:Cell("VALOR_EMP"):SetBlock({|| __aTotGeral[2,2] })
    oDespesa:Cell("VALOR_DIF"):SetBlock({|| __aTotGeral[2,3] })
    oDespesa:PrintLine()  //impresssao da linha
    oReport:ThinLine()
    oReport:SkipLine()

    //Fecha arquivo temporario
    If Select("cArqTmpB") > 0
        (cArqTmpB)->(dbCloseArea()) 
    EndIf

EndIf

//--------------------------------------------//
//Regra de Ouro
//-------------------------------------------//
If !Empty(cQryDespesa) .And. !Empty(cQryReceita)

    oReport:SkipLine()

    oQuadroI:Cell("QUADRO_I"):SetBlock({|| STR0042 }) //"Resultado para Apuração da Regra de Ouro"

    oQuadroI:Init()
    oQuadroI:PrintLine()
    oQuadroI:Finish()

    oQuadroII:Cell("TITREL"):SetBlock({|| Space(150)+STR0042 })  //Resultado para Apuração da Regra de Ouro"

    oQuadroII:Init()
    oQuadroII:PrintLine()
    oQuadroII:Finish()

    oApuracao:Init()
    oApuracao:Cell("VAL_D_A"):Hide()
    oApuracao:Cell("VAL_E_B"):Hide()
    oApuracao:Cell("VAL_F_C"):Hide()

    __nCatOpc := 4   // 1-Receitas 2-Despesas 3-Grp Despesas 4-Regra de Ouro
    oApuracao:PrintLine()
    oReport:SkipLine()
    oReport:ThinLine()

    oApuracao:Cell("VAL_D_A"):Show()
    oApuracao:Cell("VAL_E_B"):Show()
    oApuracao:Cell("VAL_F_C"):Show()

    oApuracao:Cell("DESCRICAO"):SetBlock( {|| Replicate(".",3)+STR0043  } ) //"RESULTADO PARA APURAÇÃO DA REGRA DE OURO (III) = (II - I)"

    oApuracao:PrintLine()
    oReport:SkipLine()
    oReport:ThinLine()

EndIf
//-----------------------------------------------------//

//Fecha arquivo temporario
If Select("cArqTmp1") > 0
    (cArqTmp1)->(dbCloseArea()) 
EndIf

If Select("cArqTmp2") > 0
    (cArqTmp2)->(dbCloseArea()) 
EndIf
If Select("cArqTmp3") > 0
    (cArqTmp3)->(dbCloseArea()) 
EndIf
If Select("cArqTmp4") > 0
    (cArqTmp4)->(dbCloseArea()) 
EndIf

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCabec
Cabecalho do relatorio - imprimir em todas as paginas

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function ImpCabec( oReport, oCabec, aMoedas, nDivPor, dDataFim )
Local cUnidMoed := ""

If     nDivPor == 2
    cUnidMoed := STR0035 //"Centena de "
ElseIf nDivPor == 3
    cUnidMoed := STR0036 //"Milhares de "
ElseIf nDivPor == 4
    cUnidMoed := STR0037 //"Milhoes de "
EndIf

//Imprime cabecalho
oCabec:Init()
oCabec:Cell("EXERCICIO"):SetBlock({|| STR0038+ SubStr(DToS(dDataFim), 1, 4) + "            ("+STR0039+AllTrim(cUnidMoed)+": " + AllTrim(aMoedas[3]) +  ")"+space(25)+STR0040 })  //"Valores expressos em " //"Exercício: "##"Periodicidade: BIMESTRAL"
oCabec:PrintLine()
oCabec:Finish()

//Pula linha
oReport:SkipLine()

Return


//-------------------------------------------------------------------
/*{Protheus.doc} DescCatRec()
1=Categoria Economica da Receita

Descricao sempre do ultimo segmento listado acima, onde 1 é somente Categoria Economica e por exemplo o 4 é Elemento da Despesa
@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function DescCatRec()
Local cCateg := (ALIAS())->AKD_CATEG  //tem que estar posicionado no alias da query no laco principal

Local nPosEle := 0
Local cDescri := Space(TAMDESCRI)
Local nTamChv := Len(A1H->A1H_ITECHV)

//array static carregado na funcao ReportPrint onde cada array tem a tabela correspondente
// __aTabCE    := {} -> Tabela DE - Categoria Economica da Receita


If     __nCatOpc == 1

    If (nPosEle := aScan(__aTabCE[ITETAB], {|x| x[ITECHV]==PadR(cCateg, nTamChv)}) )>0
        cDescri := PadR( __aTabCE[ITETAB][nPosEle][ITEDES],TAMDESCRI)
    EndIf
    
Else

    cDescri := Replicate(".",3)+STR0034 //"  RECEITAS DE OPERAÇÕES DE CRÉDITO (I) "

EndIf

Return cDescri

//-------------------------------------------------------------------
/*{Protheus.doc} ValRecPrevisto()

Valor da Receita Prevista 

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function ValRecPrevisto()

Return( (ALIAS())->AKD_VALPRV )


//-------------------------------------------------------------------
/*{Protheus.doc} ValRecRealiz()

Valor da Receita Realizada

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function ValRecRealiz()

Return( (ALIAS())->AKD_VALREA )

 
//-------------------------------------------------------------------
/*{Protheus.doc} ValRecDifer()

Valor da Receita Prevista - Receita Realizada

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function ValRecDifer()

Return( (ALIAS())->AKD_VALDIF )

//-------------------------------------------------------------------
/*{Protheus.doc} DescCatDsp()
1=Categoria Economica da Despesa
2=Categoria Economica da Despesa+Grupo da Despesa

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function DescCatDsp()
Local cCateg := (ALIAS())->AKD_CATEG  //tem que estar posicionado no alias da query no laco principal
Local cGrpDsp := (ALIAS())->AKD_GRPDSP

Local nPosEle := 0
Local cDescri := Space(TAMDESCRI)
Local nTamChv := Len(A1H->A1H_ITECHV)

//array static carregado na funcao ReportPrint onde cada array tem a tabela correspondente
// __aTabDE    := {} -> Tabela DE - Categoria Economica da Despesa
// __aTabGD    := {} -> Tabela GD - Grupo da Despesa


If     __nCatOpc == 2

    If (nPosEle := aScan(__aTabDE[ITETAB], {|x| x[ITECHV]==PadR(cCateg, nTamChv)}) )>0
        cDescri := PadR( __aTabDE[ITETAB][nPosEle][ITEDES],TAMDESCRI)
    EndIf
    
ElseIf __nCatOpc == 3

    If (nPosEle := aScan(__aTabGD[ITETAB], {|x| x[ITECHV]==PadR(cGrpDsp, nTamChv)}) )>0
        cDescri := Replicate(".",3)+PadR( __aTabGD[ITETAB][nPosEle][ITEDES],TAMDESCRI)
    EndIf
    
EndIf

Return cDescri

//-------------------------------------------------------------------
/*{Protheus.doc} ValDspOrcado()
Coluna Valor Dotaçao Atualizada (orcado atual)

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function ValDspOrcado()
Local nValor := 0  
  
nValor := (ALIAS())->AKD_VALORC

Return nValor  

//-------------------------------------------------------------------
/*{Protheus.doc} ValDspEmpenho()
Coluna Valor Empenhado

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function ValDspEmpenho()
Local nValor := 0  
  
nValor := (ALIAS())->AKD_VALEMP

Return nValor 

//-------------------------------------------------------------------
/*{Protheus.doc} ValDspDifer() 
Coluna Valor Dotaçao Atualizada (orcado atual) - Valor Empenhado

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function ValDspDifer() 
Local nValor := 0  
  
nValor := (ALIAS())->AKD_VALDIF

Return nValor 

//-------------------------------------------------------------------
/*{Protheus.doc} CargaTab
Carrega tabela / radical informado e retorna um array aTab

Estrutura aTab: 
Elemento 1 - Codigo da Tabela                        [CODTAB]
Elemento 2 - Descricao da Tabela                     [DESTAB]
Elemento 3 - Campo Tab.Movimentos                    [CPOMOV]
Elemento 4 - Pos.Inicial no Campo                    [POSINI]
Elemento 5 - Quantidade de digitos                   [QTDDIG]
Elemento 6 - SubArray com seguinte Estrutura         [ITETAB]
              [6][n][1] - Chave                         [ITECHV]
              [6][n][2] - Descricao                     [ITEDES]

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function CargaTab(cTabela, cRadical)
Local aTab := {}
Local aArea
Local aAreaA1G
Local aAreaA1H

Default cTabela := ""
Default cRadical := ""
/*
Local aTab := {}
Estrutura aTab: 
Elemento 1 - Codigo da Tabela                        [CODTAB]
Elemento 2 - Descricao da Tabela                     [DESTAB]
Elemento 3 - Campo Tab.Movimentos                    [CPOMOV]
Elemento 4 - Pos.Inicial no Campo                    [POSINI]
Elemento 5 - Quantidade de digitos                   [QTDDIG]
Elemento 6 - SubArray com seguinte Estrutura         [ITETAB]
              [6][1] - Chave                         [ITECHV]
              [6][2] - Descricao                     [ITEDES]
*/

If !Empty(cTabela) .And. !Empty(cRadical)
    aArea   := GetArea()
    aAreaA1G := A1G->(GetArea())
    aAreaA1H := A1H->(GetArea())
    cTabela := PadR( cTabela, Len(A1G->A1G_CODTAB) )
    cRadical := PadR( cRadical, Len(A1H->A1H_RADCHV) )

    A1G->(dbSetOrder(1)) //A1G_FILIAL+A1G_CODTAB
    A1H->(dbSetOrder(2)) //A1H_FILIAL+A1H_CODTAB+A1H_RADCHV+A1H_ITECHV

    If A1G->( dbSeek( xFilial("A1G")+cTabela ) ) 
        aTab := Array(6)  //6 ELEMENTOS
        aTab[CODTAB] := A1G->A1G_CODTAB
        aTab[DESTAB] := A1G->A1G_DESTAB
        aTab[CPOMOV] := A1G->A1G_CAMPO     
        aTab[POSINI] := A1G->A1G_INICPO
        aTab[QTDDIG] := A1G->A1G_DIGCPO
        aTab[ITETAB] := {}  

        If A1H->(dbSeek(xFilial("A1H")+cTabela)) 
            While A1H->( !EOF() .And. A1H_FILIAL == xFilial("A1H") .And. A1H_CODTAB == cTabela .And. A1H_RADCHV == cRadical )
               
                aAdd( aTab[ITETAB], Array(2) )   //2 ELEMENTOS NO SUB ARRAY ITECHV DESCHV
            
                aTab[ITETAB][Len(aTab[ITETAB])][ITECHV] := A1H->A1H_ITECHV
                aTab[ITETAB][Len(aTab[ITETAB])][ITEDES] := A1H->A1H_CHVCNT

                A1H->( dbSkip() ) 
            EndDo
        EndIf

    EndIf

    RestArea(aAreaA1H)
    RestArea(aAreaA1G)
    RestArea(aArea)
    
EndIf

Return(aTab)
