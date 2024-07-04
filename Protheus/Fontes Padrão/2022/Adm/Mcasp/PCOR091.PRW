#Include "PCOR091.CH"
#Include "PROTHEUS.CH"

Static aAnoRef := {}

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR091
    Relatorio de Metas Fiscais Atuais Comparadas com as Metas Fiscais Fixadas nos Tres Exercícios Anteriores

    @author Totvs
    
    @version P12
    @since   04/12/2020
    @return  0
    @obs	 
*/
//-------------------------------------------------------------------

Function PCOR091()

Local oReport := 0
Local cPerg   := Padr("PCOR091", Len(SX1->X1_GRUPO), " ")
Local nProjeta:= 0

aAnoRef := {}

//=================================================================================================================================================
//	MV_PAR01 - Exercicio  ?
//	MV_PAR02 - Divide Por ?
//=================================================================================================================================================

SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.023"
    Help(,, "Help",, OemToAnsi(STR0001), 1, 0) // "Metas Fiscais Atuais Comparadas com as Metas Fiscais Fixadas nos Tres Exercícios Anteriores a partir da versao 12.1.23"
    lRet := .F.
ElseIf !SX1->(dbSeek(Padr(cPerg, Len(SX1->X1_GRUPO), " ")))
    Help(,, "Help",, OemToAnsi(STR0002), 1, 0) // "Para utilizaçao do relatorio de Metas Fiscaisé necessário aplicar o pacote acumulado da controladoria."
    lRet := .F.
Else 
    //Perguntas do Relatório
    lRet := Pergunte(cPerg, .T.) 
EndIf  

// -3 -2, -1 , Ano atual , +1 +2 ( total de 6 anos )
For nProjeta := -3 to 2
    aAdd( aAnoRef, { StrZero( val(MV_PAR01) + nProjeta, 4 ), 1,  0, 0 })
Next

A23->( DbSetOrder(1) )
A25->( DbSetOrder(1) )

For nProjeta := 1 to 6
    DbSelectArea("A23")
	If DbSeek( xFilial("A23") + aAnoRef[ nProjeta,1 ])
        aAnoRef[ nProjeta,2 ]   := A23->A23_INFLA
    Else
		MsgStop( STR0017 + aAnoRef[ nProjeta, 1 ], STR0018 )  //"Nao encontrou o indice do ano de "##"Bloqueio"
		Return
	Endif
    DbSelectArea("A25")
	If ! DbSeek( xFilial("A25") + "1" + aAnoRef[ nProjeta, 1 ])
		MsgStop( STR0019 + aAnoRef[ nProjeta,1 ], STR0018 )  //"Nao encontrou a projecao primaria do ano de "##"Bloqueio"
		Return
	Endif
	If ! DbSeek( xFilial("A25") + "2" + aAnoRef[ nProjeta,1 ])
		MsgStop( STR0020 + aAnoRef[ nProjeta,1 ], STR0018 )   //"Nao encontrou a projecao nao-financeira do ano de "##"Bloqueio"
		Return
	Endif
    DbSelectArea("A28")
	If DbSeek( xFilial("A28") + "1" + aAnoRef[ nProjeta, 1 ])
        aAnoRef[ nProjeta,3 ]   := A28->A28_VALOR
    Else
		MsgStop( STR0021 + aAnoRef[ nProjeta,1 ], STR0018 )  //"Nao encontrou o Juros de Despesas do ano de "##"Bloqueio"
		Return
	Endif
	If DbSeek( xFilial("A28") + "2" + aAnoRef[ nProjeta,1 ])
        aAnoRef[ nProjeta,4 ]   := A28->A28_VALOR
    Else
		MsgStop( STR0022 + aAnoRef[ nProjeta,1 ], STR0018 )  //"Nao encontrou o Juros de Receita do ano de "##"Bloqueio"
		Return
	Endif
Next

oReport := ReportDef(cPerg)
If ValType(oReport) == "O"    
    oReport:PrintDialog()
EndIf
oReport := 0
//EndIf

aAnoRef := {}

Return 0

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
    Definicao do objeto do relatorio personalizavel e das secoes que 
    serao utilizadas.

    @author Totvs
    
    @version P12
    @since   04/12/2020
    @return  0
    @obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oCabec1, oCabec2, oBorder
Local cNomeProg := "PCOR091"
Local cTitulo   := Capital(STR0003) +  Capital(STR0004) // "Tabela 3 - Relatorio de Avaliação do Cumprimento das Metas Fiscais do Exercício Anterior"
Local cDescri 	:= OemToAnsi(STR0005)                   // "Este programa irá imprimir o Relatorio de Avaliação do Cumprimento das Metas Fiscais do Exercício Anterior."
Local nProjeta  := 0

aAnoRef := {}

// -3 -2, -1 , Ano atual , +1 +2 ( total de 6 anos )
For nProjeta := -3 to 2
    aAdd( aAnoRef, { StrZero( val(MV_PAR01) + nProjeta, 4 ), 1,  0, 0 })
Next

A23->( DbSetOrder(1) )
A25->( DbSetOrder(1) )

For nProjeta := 1 to 6
    DbSelectArea("A23")
	If DbSeek( xFilial("A23") + aAnoRef[ nProjeta,1 ])
        aAnoRef[ nProjeta,2 ]   := A23->A23_INFLA
	Endif
    DbSelectArea("A28")
	If DbSeek( xFilial("A28") + "1" + aAnoRef[ nProjeta, 1 ])
        aAnoRef[ nProjeta,3 ]   := A28->A28_VALOR
	Endif
	If DbSeek( xFilial("A28") + "2" + aAnoRef[ nProjeta,1 ])
        aAnoRef[ nProjeta,4 ]   := A28->A28_VALOR
	Endif
Next
//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                                  {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

//oReport:nFontBody := 7 //Define o tamanho da fonte
oReport:SetLandScape(.T.)       //define q relatorio sera sempre em paisagem
oReport:DisableOrientation()

oBorder := TRBorder():New(oReport, 5,, 0)

oCabecL := TRSection():New(oReport, "CABEC_M", {}, /*aOrdem*/) 
TRCell():New(oCabecL, "CABEC_LINE",,"",, 300, /*lPixel*/, /*CodeBlock*/, "CENTER",, "CENTER",,,,,, .T.) //" Avaliacão do Cumprimento das Metas Fiscais do ExercÃ­cio Anterior"
//oCabec1:oHBrdBottom := oBorder //Remove a borda do cabecalho 1

//Criacao da Secao Cabecalho 1
oCabec1 := TRSection():New(oReport, "CABEC_1", {}, /*aOrdem*/) 
TRCell():New(oCabec1, "CABEC_1",, STR0004,, 300, /*lPixel*/, /*CodeBlock*/, "CENTER",, "CENTER",,,,,, .T.) //" Avaliação do Cumprimento das Metas Fiscais do Exercício Anterior"
//oCabec1:oHBrdBottom := oBorder //Remove a borda do cabecalho 1
oCabec1:setLinesBefore(0)

//Criacao da Secao Cabecalho 1
oCabec2 := TRSection():New(oReport, "CABEC_2", {}, /*aOrdem*/)  // "EXERCICIO "
TRCell():New(oCabec2, "CABEC_2",, "",, 300, /*lPixel*/, /*CodeBlock*/, "CENTER",, "CENTER",,,,,, .T.) 
//oCabec2:oHBrdBottom := oBorder //Remove a borda do cabecalho 2
oCabec2:setLinesBefore(0)

//Criacao da Secao Receitas e Despesas
oRecDesp := TRSection():New(oReport, "RECDESP", {"cArqTmp"},, .F., .F.)
oRecCons := TRSection():New(oReport, "RECCONS", {"cArqTmp"},, .F., .F.)

//Colunas da Estrutura - Orgaos e Unidades
TRCell():New(oRecDesp, "ESPECIFICACAO" ,, STR0010      /*Titulo*/ , PesqPict("A25", "A25_DESCCE") , TamSx3("A25_DESCCE")[1] /*Tamanho*/, /*lPixel*/, {|| Cod_Receit()}  /*CodeBlock*/, "LEFT",  .T.,"LEFT")        //"ESPECIFICAÇÃO"
TRCell():New(oRecDesp, "ANO0"          ,, aAnoRef[1,1] /*Titulo*/ , PesqPict("A25", "A25_VLRPRE") , TamSx3("A25_VLRPRE")[1] /*Tamanho*/, /*lPixel*/, {|| Des_Receit()}  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"2018"
TRCell():New(oRecDesp, "ANO1"          ,, aAnoRef[2,1] /*Titulo*/ , PesqPict("A25", "A25_VLRPRE") , TamSx3("A25_VLRPRE")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"2019"
TRCell():New(oRecDesp, "VARIA1"        ,, "%"          /*Titulo*/ , "@E 999,999.99"               , 9                       /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"%"
TRCell():New(oRecDesp, "ANO2"          ,, aAnoRef[3,1] /*Titulo*/ , PesqPict("A25", "A25_VLRPRE") , TamSx3("A25_VLRPRE")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"2020"
TRCell():New(oRecDesp, "VARIA2"        ,, "%"          /*Titulo*/ , "@E 999,999.99"               , 9                       /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"%"
TRCell():New(oRecDesp, "ANO3"          ,, aAnoRef[4,1] /*Titulo*/ , PesqPict("A25", "A25_VLRPRE") , TamSx3("A25_VLRPRE")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"2021"
TRCell():New(oRecDesp, "VARIA3"        ,, "%"          /*Titulo*/ , "@E 999,999.99"               , 9                       /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"%"
TRCell():New(oRecDesp, "ANO4"          ,, aAnoRef[5,1] /*Titulo*/ , PesqPict("A25", "A25_VLRPRE") , TamSx3("A25_VLRPRE")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"2022"
TRCell():New(oRecDesp, "VARIA4"        ,, "%"          /*Titulo*/ , "@E 999,999.99"               , 9                       /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"%"
TRCell():New(oRecDesp, "ANO5"          ,, aAnoRef[6,1] /*Titulo*/ , PesqPict("A25", "A25_VLRPRE") , TamSx3("A25_VLRPRE")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"2023"
TRCell():New(oRecDesp, "VARIA5"        ,, "%"          /*Titulo*/ , "@E 999,999.99"               , 9                       /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"%"

oRecDesp:SetLinesBefore(0)

//Colunas da Estrutura - Orgaos e Unidades
TRCell():New(oRecCons, "ESPECIFICACAO" ,, STR0010      /*Titulo*/ , PesqPict("A25", "A25_DESCCE") , TamSx3("A25_DESCCE")[1] /*Tamanho*/, /*lPixel*/, {|| Cod_Receit()}  /*CodeBlock*/, "LEFT",  .T.,"LEFT")        //"ESPECIFICAÇÃO"
TRCell():New(oRecCons, "ANO0"          ,, aAnoRef[1,1] /*Titulo*/ , PesqPict("A25", "A25_VLRPRE") , TamSx3("A25_VLRPRE")[1] /*Tamanho*/, /*lPixel*/, {|| Des_Receit()}  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"2018"
TRCell():New(oRecCons, "ANO1"          ,, aAnoRef[2,1] /*Titulo*/ , PesqPict("A25", "A25_VLRPRE") , TamSx3("A25_VLRPRE")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"2019"
TRCell():New(oRecCons, "VARIA1"        ,, "%"          /*Titulo*/ , "@E 999,999.99"               , 9                       /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"%"
TRCell():New(oRecCOns, "ANO2"          ,, aAnoRef[3,1] /*Titulo*/ , PesqPict("A25", "A25_VLRPRE") , TamSx3("A25_VLRPRE")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"2020"
TRCell():New(oRecCons, "VARIA2"        ,, "%"          /*Titulo*/ , "@E 999,999.99"               , 9                       /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"%"
TRCell():New(oRecCons, "ANO3"          ,, aAnoRef[4,1] /*Titulo*/ , PesqPict("A25", "A25_VLRPRE") , TamSx3("A25_VLRPRE")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"2021"
TRCell():New(oRecCOns, "VARIA3"        ,, "%"          /*Titulo*/ , "@E 999,999.99"               , 9                       /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"%"
TRCell():New(oRecCons, "ANO4"          ,, aAnoRef[5,1] /*Titulo*/ , PesqPict("A25", "A25_VLRPRE") , TamSx3("A25_VLRPRE")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"2022"
TRCell():New(oRecCOns, "VARIA4"        ,, "%"          /*Titulo*/ , "@E 999,999.99"               , 9                       /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"%"
TRCell():New(oRecCOns, "ANO5"          ,, aAnoRef[6,1] /*Titulo*/ , PesqPict("A25", "A25_VLRPRE") , TamSx3("A25_VLRPRE")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"2023"
TRCell():New(oRecCons, "VARIA5"        ,, "%"          /*Titulo*/ , "@E 999,999.99"               , 9                       /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"%"

oRecCons:SetLinesBefore(0)


Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
    Definicao do objeto do relatorio personalizavel e das secoes que serao  
    utilizadas

    @author Totvs
    
    @version P12
    @since   04/12/2020
    @return  0
    @obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport) 

Local oCabec1   := oReport:Section("CABEC_1")
Local oCabec2   := oReport:Section("CABEC_2")
Local oCabecL   := oReport:Section("CABEC_M")
Local oSection1 := oReport:Section("RECDESP")
Local oSecTion2 := oReport:Section("RECCONS")
Local cExerAtu  := Str(Val(MV_PAR01),4)  // Exercicio Referencia
Local aDados    := {}
Local nX        := 0
Local nCount    := 0 
/*
MV_PAR01 - Exercício ?                   	¿Ejercicio ?                  	 ?                            	MV_CH1	C	4	0
MV_PAR02 - Divide por ?                  	¿Divide entre ?               	 ?                            	MV_CH5	N	1	0
*/
/*             ESPECIFICAÇÃO                    , VALORES A PRECOS CORRENTES        
                                                  2017    2018    %       2019    %       2020       %       2021       %       2022       %
aAdd(aDados,{"Receita Total"                     ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Receitas Primárias (I)"            ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Despesa Total"                     ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Despesas Primárias (II)"           ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Resultado Primário (III = I – II)" ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Resultado Nominal"                 ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Dívida Pública Consolidada"        ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Dívida Consolidada Líquida"        ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })

aAdd(aDados,{"Receita Total "                    ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Receitas Não-Financeiras (I)"      ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Despesa Total"                     ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Despesas Não-Financeiras (II)"     ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Resultado Primário (I – II)"       ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Resultado Nominal "                ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Dívida Pública Consolidada"        ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Dívida Consolidada Líquida"        ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })

/* Monta array para impressao */
Pr88Dados(aDados)

oCabecL:IniT()

oCabecl:Cell("CABEC_LINE"):SetBlock ( {||OemToAnsi(STR0014) } )
oCabecl:PrintLine()
oCabecl:Cell("CABEC_LINE"):SetBlock ( {||OemToAnsi(STR0015) } )
oCabecl:PrintLine()
oCabecl:Cell("CABEC_LINE"):SetBlock ( {||Alltrim(cExerAtu) } )
oCabecl:PrintLine()

oCabecl:Finish()
 
oCabec1:Init() // Ta dando Ruim no Objeto 
oCabec1:Cell("CABEC_1"):SetBlock ( {||OemToAnsi(STR0012) } )
oCabec1:PrintLine()
oCabec1:Finish()
 

oSection1:Init()
For nX := 1 to Len(aDados)

    oSection1:Cell("ESPECIFICACAO"):SetBlock ( {||aDados[nX][1]} )
    oSection1:Cell("ANO0")  :SetBlock ( {||aDados[nX][ 2]} ) 
    oSection1:Cell("ANO1")  :SetBlock ( {||aDados[nX][ 3]} ) 
    oSection1:Cell("VARIA1"):SetBlock ( {||aDados[nX][ 4]} ) 
    oSection1:Cell("ANO2")  :SetBlock ( {||aDados[nX][ 5]} ) 
    oSection1:Cell("VARIA2"):SetBlock ( {||aDados[nX][ 6]} ) 
    oSection1:Cell("ANO3")  :SetBlock ( {||aDados[nX][ 7]} ) 
    oSection1:Cell("VARIA3"):SetBlock ( {||aDados[nX][ 8]} ) 
    oSection1:Cell("ANO4")  :SetBlock ( {||aDados[nX][ 9]} ) 
    oSection1:Cell("VARIA4"):SetBlock ( {||aDados[nX][10]} ) 
    oSection1:Cell("ANO5")  :SetBlock ( {||aDados[nX][11]} ) 
    oSection1:Cell("VARIA5"):SetBlock ( {||aDados[nX][12]} ) 

    oSection1:PrintLine()


    if aDados[nX][ 2] == Nil
        Exit
        ncount := nx
    endif 

Next nX
oSection1:Finish()

oCabec2:Init() // Ta dando Ruim no Objeto 
oCabec2:Cell("CABEC_2"):SetBlock ( {||OemToAnsi(STR0011) } )
oCabec2:PrintLine()
oCabec2:Finish()

oSection2:Init()
For nx := nx to Len(aDados)

    oSection2:Cell("ESPECIFICACAO"):SetBlock ( {||aDados[nX][1]} )
    oSection2:Cell("ANO0")  :SetBlock ( {||aDados[nX][ 2]} ) 
    oSection2:Cell("ANO1")  :SetBlock ( {||aDados[nX][ 3]} ) 
    oSection2:Cell("VARIA1"):SetBlock ( {||aDados[nX][ 4]} ) 
    oSection2:Cell("ANO2")  :SetBlock ( {||aDados[nX][ 5]} ) 
    oSection2:Cell("VARIA2"):SetBlock ( {||aDados[nX][ 6]} ) 
    oSection2:Cell("ANO3")  :SetBlock ( {||aDados[nX][ 7]} ) 
    oSection2:Cell("VARIA3"):SetBlock ( {||aDados[nX][ 8]} ) 
    oSection2:Cell("ANO4")  :SetBlock ( {||aDados[nX][ 9]} ) 
    oSection2:Cell("VARIA4"):SetBlock ( {||aDados[nX][10]} ) 
    oSection2:Cell("ANO5")  :SetBlock ( {||aDados[nX][11]} ) 
    oSection2:Cell("VARIA5"):SetBlock ( {||aDados[nX][12]} ) 


    oSection2:PrintLine()

Next nX
oSection2:Finish()

//Fecha arquivo temporario
/*If Select("cArqTmp") > 0
    (cArqTmp)->(dbCloseArea()) 
EndIf
*/
Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} Pr88Dados
   Monta Array para impressao
@author Totvs
   
@version P12
@since   04/12/2020
@return  0
@obs	 
*/
//-------------------------------------------------------------------

Static Function Pr88Dados(aDados)
Local cQuery    := ""
Local cArqTmp   := GetNextAlias()
Local iX        := 1
Local nVariac1  := 0
Local nVariac2  := 0
Local nVariac3  := 0
Local nVariac4  := 0
Local nVariac5  := 0
Local nFator    := 1
Local nLinha    := 0

nFator := 1             // MV_PAR01 = Nao se aplica
If      MV_PAR02 == 2   // Cem
    nFator := 1000
ElseIf  MV_PAR02 == 3   // Mil
    nFator := 100
ElseIf  MV_PAR02 == 4   // Milhao
    nFator := 1
Endif

/*             ESPECIFICAÇÃO                    , VALORES A PRECOS CORRENTES        
                                                  2018    2019    %       2020    %       2021       %       2022       %       2023       %     
*/      
aAdd(aDados,{ STR0023 /*"Receita Total"                     */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })
aAdd(aDados,{ STR0024 /*"Receitas Primárias (I)"            */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })
aAdd(aDados,{ STR0025 /*"Despesa Total"                     */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })
aAdd(aDados,{ STR0026 /*"Despesas Primárias (II)"           */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })
aAdd(aDados,{ STR0027 /*"Resultado Primário (III = I – II)" */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })
aAdd(aDados,{ STR0028 /*"Resultado Nominal"                 */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })
aAdd(aDados,{ STR0029 /*"Dívida Pública Consolidada"        */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })
aAdd(aDados,{ STR0030 /* /*"Dívida Consolidada Líquida"     */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })

aAdd(aDados,{ nil                                ,nil    ,nil   ,nil     ,nil    ,nil    ,nil        ,nil   ,nil       ,nil    ,nil        ,nil  })

aAdd(aDados,{ STR0031 /*"Receita Total "                    */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })
aAdd(aDados,{ STR0032 /*"Receitas Não-Financeiras (I)"      */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })
aAdd(aDados,{ STR0033 /*"Despesa Total"                     */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })
aAdd(aDados,{ STR0034 /*"Despesas Não-Financeiras (II)"     */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })
aAdd(aDados,{ STR0035 /*"Resultado Primário (I – II)"       */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })
aAdd(aDados,{ STR0036 /*"Resultado Nominal "                */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })
aAdd(aDados,{ STR0037 /*"Dívida Pública Consolidada"        */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })
aAdd(aDados,{ STR0038 /*"Dívida Consolidada Líquida"        */,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0          ,0    })

/*
    Linha 1 - Receita Total 
    Linha 2 - Receitas Primárias  
*/

cQuery := "  SELECT  A25A.A25_FILIAL     FILIAL,  "               + CRLF   
cQuery += "          A25A.A25_CATEGO     CATEGORIA, "             + CRLF 
cQuery += "         'CONTA'			     CONTA, "                 + CRLF 
cQuery += "         'LINHA 1 e 2'		 DESCRICAO , "            + CRLF 
cQuery += "         SUM(A25A.A25_VLRPRE) PREV1,"                  + CRLF 	// 2018  
cQuery += "         SUM(A25B.A25_VLRPRE) PREV2,	"                 + CRLF    // 2019    
cQuery += "         SUM(A25C.A25_VLRPRE) PREV3, "                 + CRLF    // 2020
cQuery += "         SUM(A25D.A25_VLRPRE) PREV4, "                 + CRLF   	// 2021
cQuery += "         SUM(A25E.A25_VLRPRE) PREV5,  "                + CRLF  	// 2022
cQuery += "         SUM(A25F.A25_VLRPRE) PREV6, "                 + CRLF   	// 2023
cQuery += "         SUM(A25A.A25_VLRREA) REAL1,	"                 + CRLF    // 2018  
cQuery += "         SUM(A25B.A25_VLRREA) REAL2,	"                 + CRLF    // 2019  
cQuery += "         SUM(A25C.A25_VLRREA) REAL3,	"                 + CRLF    // 2020     
cQuery += "         SUM(A25E.A25_VLRREA) REAL4,	"                 + CRLF    // 2021     
cQuery += "         SUM(A25E.A25_VLRREA) REAL5,	"                 + CRLF    // 2022     
cQuery += "         SUM(A25F.A25_VLRREA) REAL6,	"                 + CRLF    // 2023     
cQuery += "         '1-Receitas'         TIPO"                    + CRLF 
cQuery += "  FROM " + RetSqlName("A25")  + ' A25A'                + CRLF
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25B ON A25B.A25_FILIAL + A25B.A25_CATEGO + A25B.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25B.A25_ANO = '"+ aAnoRef[2,1] +"' AND A25B.D_E_L_E_T_ =' '"  + CRLF 
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25C ON A25C.A25_FILIAL + A25C.A25_CATEGO + A25C.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25C.A25_ANO = '"+ aAnoRef[3,1] +"' AND A25C.D_E_L_E_T_ =' '"  + CRLF 
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25D ON A25D.A25_FILIAL + A25D.A25_CATEGO + A25D.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25D.A25_ANO = '"+ aAnoRef[4,1] +"' AND A25D.D_E_L_E_T_ =' '"  + CRLF 
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25E ON A25E.A25_FILIAL + A25E.A25_CATEGO + A25E.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25E.A25_ANO = '"+ aAnoRef[5,1] +"' AND A25E.D_E_L_E_T_ =' '"  + CRLF 
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25F ON A25F.A25_FILIAL + A25F.A25_CATEGO + A25F.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25F.A25_ANO = '"+ aAnoRef[6,1] +"' AND A25F.D_E_L_E_T_ =' '"  + CRLF 
cQuery += "  WHERE A25A.D_E_L_E_T_ = ' ' "                       + CRLF 
cQuery += "    AND A25A.A25_FILIAL =  '"+ xFilial("A25")+"'"     + CRLF 
cQuery += "    AND A25A.A25_CATEGO = '2' "                       + CRLF     // Receitas
cQuery += "    AND A25A.A25_ANO = '"+ aAnoRef[1,1] +"'"          + CRLF 
cQuery += " GROUP BY  A25A.A25_FILIAL, A25A.A25_CATEGO "         + CRLF 

cQuery += " UNION "                                              + CRLF

/*
    Linha 3 - Despesa Total 
    Linha 4 - Despesas Primárias (II) 
    Linha 5 - Resultado Primário (I – II) 
*/

cQuery += " SELECT  A25A.A25_FILIAL       FILIAL,"               + CRLF 
cQuery += "         A25A.A25_CATEGO       CATEGORIA, "           + CRLF 
cQuery += "         'CONTA'               CONTA,  "              + CRLF
cQuery += "         'LINHA 3 4 e 5'       DESCRICAO, "           + CRLF
cQuery += "         SUM(A25A.A25_VLRPRE)  PREV1, "               + CRLF	// 2018   
cQuery += "         SUM(A25B.A25_VLRPRE)  PREV2, "               + CRLF	// 2019   
cQuery += "         SUM(A25C.A25_VLRPRE)  PREV3, "               + CRLF	// 2020   
cQuery += "         SUM(A25D.A25_VLRPRE)  PREV4, "               + CRLF	// 2021   
cQuery += "         SUM(A25E.A25_VLRPRE)  PREV5, "               + CRLF	// 2022   
cQuery += "         SUM(A25F.A25_VLRPRE)  PREV6, "               + CRLF	// 2023   
cQuery += "         SUM(A25A.A25_VLRREA)  REAL1, "               + CRLF	// 2018   
cQuery += "         SUM(A25A.A25_VLRREA)  REAL2, "               + CRLF	// 2019   
cQuery += "         SUM(A25A.A25_VLRREA)  REAL3, "               + CRLF	// 2020   
cQuery += "         SUM(A25A.A25_VLRREA)  REAL4, "               + CRLF	// 2021   
cQuery += "         SUM(A25A.A25_VLRREA)  REAL5, "               + CRLF	// 2022   
cQuery += "         SUM(A25A.A25_VLRREA)  REAL6, "               + CRLF	// 2023   
cQuery += "         '2-Despesas'		   TIPO "                + CRLF
cQuery += " FROM " + RetSqlName("A25") + " A25A"                 + CRLF
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25B ON A25B.A25_FILIAL + A25B.A25_CATEGO + A25B.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25B.A25_ANO = '"+ aAnoRef[2,1] +"' AND A25B.D_E_L_E_T_ =' '"  + CRLF 
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25C ON A25C.A25_FILIAL + A25C.A25_CATEGO + A25C.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25C.A25_ANO = '"+ aAnoRef[3,1] +"' AND A25C.D_E_L_E_T_ =' '"  + CRLF
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25D ON A25D.A25_FILIAL + A25D.A25_CATEGO + A25D.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25D.A25_ANO = '"+ aAnoRef[4,1] +"' AND A25D.D_E_L_E_T_ =' '"  + CRLF
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25E ON A25E.A25_FILIAL + A25E.A25_CATEGO + A25E.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25E.A25_ANO = '"+ aAnoRef[5,1] +"' AND A25E.D_E_L_E_T_ =' '"  + CRLF
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25F ON A25F.A25_FILIAL + A25F.A25_CATEGO + A25F.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25F.A25_ANO = '"+ aAnoRef[6,1] +"' AND A25F.D_E_L_E_T_ =' '"  + CRLF
cQuery += " WHERE A25A.D_E_L_E_T_ = ' '  "                      + CRLF
cQuery += "   AND A25A.A25_FILIAL =  '"+ xFilial("A25")+"' "    + CRLF
cQuery += "   AND A25A.A25_CATEGO = '1' "                       + CRLF     // Despesas
//cQuery += "   AND A25A.A25_ORIGP IN ('1','2','3','4','5','6') " + CRLF
cQuery += "   AND A25A.A25_ANO =  '"+ aAnoRef[1,1] +"' "        + CRLF
cQuery += " GROUP BY  A25A.A25_FILIAL, A25A.A25_CATEGO  "       + CRLF

cQuery += " UNION "                                             + CRLF

/*
    Linha 6 - Resultado Nominal
*/

cQuery += " SELECT  A25A.A25_FILIAL       FILIAL,"               + CRLF
cQuery += "         A25A.A25_CATEGO       CATEGORIA,"            + CRLF
cQuery += "         'CONTA'               CONTA,"                + CRLF 
cQuery += "         'LINHA 6'             DESCRICAO,"            + CRLF
cQuery += "         SUM(A25A.A25_VLRPRE)  PREV1,"                + CRLF	// 2018   
cQuery += "         SUM(A25B.A25_VLRPRE)  PREV2,"                + CRLF	// 2019   
cQuery += "         SUM(A25C.A25_VLRPRE)  PREV3,"                + CRLF	// 2020   
cQuery += "         SUM(A25D.A25_VLRPRE)  PREV4,"                + CRLF	// 2021   
cQuery += "         SUM(A25E.A25_VLRPRE)  PREV5,"                + CRLF	// 2022   
cQuery += "         SUM(A25F.A25_VLRPRE)  PREV6,"                + CRLF	// 2023   
cQuery += "         SUM(A25A.A25_VLRREA)  REAL1,"                + CRLF	// 2018   
cQuery += "         SUM(A25A.A25_VLRREA)  REAL2,"                + CRLF	// 2019   
cQuery += "         SUM(A25A.A25_VLRREA)  REAL3,"                + CRLF	// 2020   
cQuery += "         SUM(A25A.A25_VLRREA)  REAL4,"                + CRLF	// 2021   
cQuery += "         SUM(A25A.A25_VLRREA)  REAL5,"                + CRLF	// 2022   
cQuery += "         SUM(A25A.A25_VLRREA)  REAL6,"                + CRLF	// 2023   
cQuery += "         '3-Juros e Encargos'  TIPO"                  + CRLF
cQuery += " FROM " + RetSqlName("A25") + " A25A "                + CRLF
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25B ON A25B.A25_FILIAL + A25B.A25_CATEGO + A25B.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25B.A25_ANO = '"+ aAnoRef[2,1] +"' AND A25B.D_E_L_E_T_ =' '"  + CRLF
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25C ON A25C.A25_FILIAL + A25C.A25_CATEGO + A25C.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25C.A25_ANO = '"+ aAnoRef[3,1] +"' AND A25C.D_E_L_E_T_ =' '"  + CRLF
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25D ON A25D.A25_FILIAL + A25D.A25_CATEGO + A25D.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25D.A25_ANO = '"+ aAnoRef[4,1] +"' AND A25D.D_E_L_E_T_ =' '"  + CRLF
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25E ON A25E.A25_FILIAL + A25E.A25_CATEGO + A25E.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25E.A25_ANO = '"+ aAnoRef[5,1] +"' AND A25E.D_E_L_E_T_ =' '"  + CRLF
cQuery += "  LEFT JOIN  " + RetSqlName("A25") + " A25F ON A25F.A25_FILIAL + A25F.A25_CATEGO + A25F.A25_ORIGP = A25A.A25_FILIAL + A25A.A25_CATEGO + A25A.A25_ORIGP  AND A25F.A25_ANO = '"+ aAnoRef[6,1] +"' AND A25F.D_E_L_E_T_ =' '"  + CRLF
cQuery += " WHERE A25A.D_E_L_E_T_ = ' ' "                       + CRLF
cQuery += "   AND A25A.A25_FILIAL =  '"+ xFilial("A25")+"'"     + CRLF
cQuery += "   AND A25A.A25_CATEGO = '1'"                        + CRLF     // Despesas
cQuery += "   AND A25A.A25_ORIGP IN ('2')"                      + CRLF
cQuery += "   AND A25A.A25_ANO =  '"+ aAnoRef[1,1] +"'"           + CRLF
cQuery += " GROUP BY  A25A.A25_FILIAL, A25A.A25_CATEGO "        + CRLF

cQuery += " UNION "                                             + CRLF

/* 
    Linha 7 - Dívida Pública Consolidada
    Linha 8 - Dívida Consolidada Líquida
*/

cQuery += "  SELECT  A27A.A27_FILIAL	FILIAL, "                   + CRLF
cQuery += "          A27A.A27_CATEGO	CATEGORIA, "                + CRLF
cQuery += "          A27A.A27_CONTA		CONTA, "                    + CRLF
cQuery += "          A27A.A27_DESC		DESCRICAO, "                + CRLF
cQuery += "          A27A.A27_VALOR		PREV1,	"                   + CRLF  // 2018   
cQuery += "          A27B.A27_VALOR		PREV2,	"                   + CRLF  // 2019   
cQuery += "          A27C.A27_VALOR		PREV3,	"                   + CRLF  // 2020   
cQuery += "          A27D.A27_VALOR		PREV4,	"                   + CRLF  // 2021   
cQuery += "          A27E.A27_VALOR		PREV5,	"                   + CRLF  // 2022   
cQuery += "          A27F.A27_VALOR		PREV6,	"                   + CRLF  // 2023   
cQuery += "          A27A.A27_VALOR		REAL1,	"                   + CRLF  // 2018   
cQuery += "          A27B.A27_VALOR		REAL2,	"                   + CRLF  // 2019   
cQuery += "          A27C.A27_VALOR		REAL3,	"                   + CRLF  // 2020   
cQuery += "          A27D.A27_VALOR		REAL4,	"                   + CRLF  // 2021   
cQuery += "          A27E.A27_VALOR		REAL5,	"                   + CRLF  // 2022   
cQuery += "          A27F.A27_VALOR		REAL6,	"                   + CRLF  // 2023   
cQuery += "          '4-Divida Publica'	TIPO"                       + CRLF
cQuery += "   FROM " + RetSqlName("A27") + " A27A"                    + CRLF
cQuery += "   LEFT JOIN  " + RetSqlName("A27") + " A27B ON A27B.A27_FILIAL + A27B.A27_CATEGO = A27A.A27_FILIAL + A27A.A27_CATEGO AND A27B.A27_ANO = '"+ aAnoRef[2,1] +"' AND A27B.D_E_L_E_T_ =' '"   + CRLF
cQuery += "   LEFT JOIN  " + RetSqlName("A27") + " A27C ON A27C.A27_FILIAL + A27C.A27_CATEGO = A27A.A27_FILIAL + A27A.A27_CATEGO AND A27C.A27_ANO = '"+ aAnoRef[3,1] +"' AND A27C.D_E_L_E_T_ =' '"   + CRLF
cQuery += "   LEFT JOIN  " + RetSqlName("A27") + " A27D ON A27D.A27_FILIAL + A27D.A27_CATEGO = A27A.A27_FILIAL + A27A.A27_CATEGO AND A27D.A27_ANO = '"+ aAnoRef[4,1] +"' AND A27D.D_E_L_E_T_ =' '"   + CRLF
cQuery += "   LEFT JOIN  " + RetSqlName("A27") + " A27E ON A27E.A27_FILIAL + A27E.A27_CATEGO = A27A.A27_FILIAL + A27A.A27_CATEGO AND A27E.A27_ANO = '"+ aAnoRef[5,1] +"' AND A27E.D_E_L_E_T_ =' '"   + CRLF
cQuery += "   LEFT JOIN  " + RetSqlName("A27") + " A27F ON A27F.A27_FILIAL + A27F.A27_CATEGO = A27A.A27_FILIAL + A27A.A27_CATEGO AND A27F.A27_ANO = '"+ aAnoRef[6,1] +"' AND A27F.D_E_L_E_T_ =' '"   + CRLF
cQuery += "   WHERE A27A.D_E_L_E_T_ = ' ' "                         + CRLF
cQuery += "     AND A27A.A27_FILIAL =  '"+ xFilial("A27")+"'"       + CRLF
cQuery += "     AND A27A.A27_ANO = '"+ aAnoRef[1,1] +"'"            + CRLF
cQuery += "     AND A27A.A27_CATEGO IN ( '1', '2') "                + CRLF
cQuery += "  ORDER BY TIPO, CATEGORIA, CONTA"                       + CRLF


dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cArqTmp)

MEMOWRITE( "PCOR091.SQL", cQuery )

If (cArqtmp)->(!Eof())
    iX := 0
    While (cArqtmp)->(!Eof())
        iX++
        nPrevisto   := 0 ; nRealizado  := 0
        nVariac1 := 0; nVariac2 := 0; nVariac3 := 0; nVariac4 := 0; nVariac5 := 0

        If ix == 1 .Or. iX == 3 .Or. iX == 6 .Or. iX == 7 .Or. iX == 8  
            /*  ESPECIFICAÇÃO                    , VALORES A PRECOS CORRENTES                                                                 */
            /*                                      2018    2019    %       2020    %       2021       %       2022       %       2023       % */
            // Registro 1 da tabela temporaria
            If iX == 1   // Preenchimento da Linha 1 e 2

                // Linha 1 - Receita Total

                aDados[iX][ 2] := (cArqTmp)->(REAL1) / nFator 
                aDados[iX][ 3] := (cArqTmp)->(REAL2) / nFator
                aDados[iX][ 5] := (cArqTmp)->(PREV3) / nFator 
                aDados[iX][ 7] := (cArqTmp)->(PREV4) / nFator 
                aDados[iX][ 9] := (cArqTmp)->(PREV5) / nFator
                aDados[iX][11] := (cArqTmp)->(PREV6) / nFator

                aDados[iX][ 4] := ((aDados[iX][ 3] / aDados[iX][ 2] ) - 1 ) * 100 
                aDados[iX][ 6] := ((aDados[iX][ 5] / aDados[iX][ 3] ) - 1 ) * 100
                aDados[iX][ 8] := ((aDados[iX][ 7] / aDados[iX][ 5] ) - 1 ) * 100
                aDados[iX][10] := ((aDados[iX][ 9] / aDados[iX][ 7] ) - 1 ) * 100 
                aDados[iX][12] := ((aDados[iX][11] / aDados[iX][ 9] ) - 1 ) * 100

                // Linha 2 - Receitas Primárias (I)
                iX := 2

                aDados[iX][ 2]  := ( (cArqTmp)->(REAL1) - aAnoRef[1,4] ) / nFator      // Receita - Juros Receita
                aDados[iX][ 3]  := ( (cArqTmp)->(REAL2) - aAnoRef[2,4] ) / nFator      // Receita - Juros Receita
                aDados[iX][ 5]  := ( (cArqTmp)->(PREV3) - aAnoRef[3,4] ) / nFator      // Receita - Juros Receita
                aDados[iX][ 7]  := ( (cArqTmp)->(PREV4) - aAnoRef[4,4] ) / nFator      // Receita - Juros Receita
                aDados[iX][ 9]  := ( (cArqTmp)->(PREV5) - aAnoRef[5,4] ) / nFator      // Receita - Juros Receita
                aDados[iX][11]  := ( (cArqTmp)->(PREV6) - aAnoRef[6,4] ) / nFator      // Receita - Juros Receita

                aDados[iX][ 4]  := ((aDados[iX][ 3] / aDados[iX][ 2] ) - 1 ) * 100 
                aDados[iX][ 6]  := ((aDados[iX][ 5] / aDados[iX][ 3] ) - 1 ) * 100 
                aDados[iX][ 8]  := ((aDados[iX][ 7] / aDados[iX][ 5] ) - 1 ) * 100 
                aDados[iX][10]  := ((aDados[iX][ 9] / aDados[iX][ 7] ) - 1 ) * 100 
                aDados[iX][12]  := ((aDados[iX][11] / aDados[iX][ 9] ) - 1 ) * 100

            Endif

            // Registro 2 da tabela temporaria
            If iX == 3  // Preencho as linhas 3 e 4 e 5

                // Linha 3 - Despesa Total
                aDados[iX][ 2] := ( (cArqTmp)->(REAL1) / nFator ) 
                aDados[iX][ 3] := ( (cArqTmp)->(REAL2) / nFator )
                aDados[iX][ 5] := ( (cArqTmp)->(PREV3) / nFator ) 
                aDados[iX][ 7] := ( (cArqTmp)->(PREV4) / nFator ) 
                aDados[iX][ 9] := ( (cArqTmp)->(PREV5) / nFator )
                aDados[iX][11] := ( (cArqTmp)->(PREV6) / nFator )

                aDados[iX][ 4] := ((aDados[iX][ 3] / aDados[iX][ 2] ) - 1 ) * 100
                aDados[iX][ 6] := ((aDados[iX][ 3] / aDados[iX][ 2] ) - 1 ) * 100 
                aDados[iX][ 8] := ((aDados[iX][ 3] / aDados[iX][ 2] ) - 1 ) * 100 
                aDados[iX][10] := ((aDados[iX][ 3] / aDados[iX][ 2] ) - 1 ) * 100 
                aDados[iX][12] := ((aDados[iX][ 3] / aDados[iX][ 2] ) - 1 ) * 100

                iX := 4

                // Linha 4 - Receitas Primárias (I)
                aDados[iX][ 2] := ( (cArqTmp)->(REAL1) - aAnoRef[1,3] ) / nFator      // Despesa - Juros Despesa
                aDados[iX][ 3] := ( (cArqTmp)->(REAL2) - aAnoRef[2,3] ) / nFator      // Despesa - Juros Despesa
                aDados[iX][ 5] := ( (cArqTmp)->(PREV3) - aAnoRef[3,3] ) / nFator      // Despesa - Juros Despesa
                aDados[iX][ 7] := ( (cArqTmp)->(PREV4) - aAnoRef[4,3] ) / nFator      // Despesa - Juros Despesa
                aDados[iX][ 9] := ( (cArqTmp)->(PREV5) - aAnoRef[5,3] ) / nFator      // Despesa - Juros Despesa
                aDados[iX][11] := ( (cArqTmp)->(PREV6) - aAnoRef[6,3] ) / nFator      // Despesa - Juros Despesa

                aDados[iX][ 4] := ((aDados[iX][ 3] / aDados[iX][ 2] ) - 1 ) * 100 
                aDados[iX][ 6] := ((aDados[iX][ 5] / aDados[iX][ 3] ) - 1 ) * 100 
                aDados[iX][ 8] := ((aDados[iX][ 7] / aDados[iX][ 5] ) - 1 ) * 100 
                aDados[iX][10] := ((aDados[iX][ 9] / aDados[iX][ 7] ) - 1 ) * 100 
                aDados[iX][12] := ((aDados[iX][11] / aDados[iX][ 9] ) - 1 ) * 100 

                // Linha 5 - Resultado Primário ( I – II)
                iX := 5

                aDados[iX][ 2] := aDados[2][ 2] -aDados[ 4][ 2] 
                aDados[iX][ 3] := aDados[2][ 3] -aDados[ 4][ 3] 
                aDados[iX][ 5] := aDados[2][ 5] -aDados[ 4][ 5] 
                aDados[iX][ 7] := aDados[2][ 7] -aDados[ 4][ 7] 
                aDados[iX][ 9] := aDados[2][ 9] -aDados[ 4][ 9] 
                aDados[iX][11] := aDados[2][11] -aDados[ 4][11] 

                aDados[iX][ 4] := ((aDados[iX][ 3] / aDados[iX][ 2] ) - 1 ) * 100 
                aDados[iX][ 6] := ((aDados[iX][ 5] / aDados[iX][ 3] ) - 1 ) * 100  
                aDados[iX][ 8] := ((aDados[iX][ 7] / aDados[iX][ 5] ) - 1 ) * 100  
                aDados[iX][10] := ((aDados[iX][ 9] / aDados[iX][ 7] ) - 1 ) * 100  
                aDados[iX][12] := ((aDados[iX][11] / aDados[iX][ 9] ) - 1 ) * 100 

            Endif
            // Registro 3 da tabela temporaria
            If iX == 6  // Preencho as linhas 6 
                // Linha 6 - Resultado Nominal

                aDados[iX][ 2] := (  aDados[5][ 2] + (cArqTmp)->(REAL1) ) / nFator 
                aDados[iX][ 3] := (  aDados[5][ 3] + (cArqTmp)->(REAL2) ) / nFator
                aDados[iX][ 5] := (  aDados[5][ 5] + (cArqTmp)->(PREV3) ) / nFator 
                aDados[iX][ 7] := (  aDados[5][ 7] + (cArqTmp)->(PREV4) ) / nFator
                aDados[iX][ 9] := (  aDados[5][ 9] + (cArqTmp)->(PREV5) ) / nFator
                aDados[iX][11] := (  aDados[5][11] + (cArqTmp)->(PREV6) ) / nFator

                aDados[iX][ 4] := ((aDados[iX][ 3] / aDados[iX][ 2] ) - 1 ) * 100 
                aDados[iX][ 6] := ((aDados[iX][ 5] / aDados[iX][ 3] ) - 1 ) * 100 
                aDados[iX][ 8] := ((aDados[iX][ 7] / aDados[iX][ 5] ) - 1 ) * 100 
                aDados[iX][10] := ((aDados[iX][ 9] / aDados[iX][ 7] ) - 1 ) * 100 
                aDados[iX][12] := ((aDados[iX][11] / aDados[iX][ 9] ) - 1 ) * 100

            Endif
            // Registro 4 da tabela temporaria
            If iX == 7  // Preencho as linhas 7 e 8 
                // Linha 7 -Dívida Pública Consolidada

                aDados[iX][ 2] := ( (cArqTmp)->(REAL1) / nFator )
                aDados[iX][ 3] := ( (cArqTmp)->(REAL2) / nFator )
                aDados[iX][ 5] := ( (cArqTmp)->(PREV3) / nFator )
                aDados[iX][ 7] := ( (cArqTmp)->(PREV4) / nFator )
                aDados[iX][ 9] := ( (cArqTmp)->(PREV5) / nFator )
                aDados[iX][11] := ( (cArqTmp)->(PREV6) / nFator )

                aDados[iX][ 4] := ((aDados[iX][ 3] / aDados[iX][ 2] ) - 1 ) * 100 
                aDados[iX][ 6] := ((aDados[iX][ 5] / aDados[iX][ 3] ) - 1 ) * 100  
                aDados[iX][ 8] := ((aDados[iX][ 7] / aDados[iX][ 5] ) - 1 ) * 100  
                aDados[iX][10] := ((aDados[iX][ 9] / aDados[iX][ 7] ) - 1 ) * 100  
                aDados[iX][12] := ((aDados[iX][11] / aDados[iX][ 9] ) - 1 ) * 100 
            Endif
            // Registro 5 da tabela temporaria
            If iX == 8  // Preencho as linhas 7 e 8 
                // Linha 8 - Dívida Consolidada Líquida

                aDados[iX][ 2] := ( (cArqTmp)->(REAL1) / nFator )
                aDados[iX][ 3] := ( (cArqTmp)->(REAL2) / nFator )
                aDados[iX][ 5] := ( (cArqTmp)->(PREV3) / nFator )
                aDados[iX][ 7] := ( (cArqTmp)->(PREV4) / nFator )
                aDados[iX][ 9] := ( (cArqTmp)->(PREV5) / nFator )
                aDados[iX][11] := ( (cArqTmp)->(PREV6) / nFator )

                aDados[iX][ 4] := ((aDados[iX][ 3] / aDados[iX][ 2] ) - 1 ) * 100 
                aDados[iX][ 6] := ((aDados[iX][ 5] / aDados[iX][ 3] ) - 1 ) * 100 
                aDados[iX][ 8] := ((aDados[iX][ 7] / aDados[iX][ 5] ) - 1 ) * 100 
                aDados[iX][10] := ((aDados[iX][ 8] / aDados[iX][ 7] ) - 1 ) * 100 
                aDados[iX][12] := ((aDados[iX][11] / aDados[iX][ 9] ) - 1 ) * 100
            Endif
        EndIf

        (cArqTmp)->(dbSkip())    
    End
EndIf
(cArqTmp)->(dbCloseArea())

/*
              ESPECIFICAÇÃO                    , VALORES A PRECOS CORRENTES        
                                                  2018    2019   %        2020    %       2021        %      2022       %       2023       %
              1                                   2       3      4        5       6       7           8      9          10      11         12
aAdd(aDados,{"Receita Total"                     ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Receitas Primárias (I)"            ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Despesa Total"                     ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Despesas Primárias (II)"           ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Resultado Primário (III = I – II)" ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Resultado Nominal"                 ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Dívida Pública Consolidada"        ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Dívida Consolidada Líquida"        ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })

aAdd(aDados,{"Receita Total "                    ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Receitas Não-Financeiras (I)"      ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Despesa Total"                     ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Despesas Não-Financeiras (II)"     ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Resultado Primário (I – II)"       ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Resultado Nominal "                ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Dívida Pública Consolidada"        ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })
aAdd(aDados,{"Dívida Consolidada Líquida"        ,0      ,0     ,0       ,0      ,0      ,0          ,0     ,0         ,0      ,0         ,0  })

*/

For nLinha := 1 to 8
    aDados[ nLinha + 9 ][ 2] := aDados[ nLinha ][ 2] * ( 1 + ( aAnoRef[1,2] / 100 ))
    aDados[ nLinha + 9 ][ 3] := aDados[ nLinha ][ 3] * ( 1 + ( aAnoRef[2,2] / 100 ))
    aDados[ nLinha + 9 ][ 5] := aDados[ nLinha ][ 5] * ( 1 + ( aAnoRef[3,2] / 100 ))
    aDados[ nLinha + 9 ][ 7] := aDados[ nLinha ][ 7] * ( 1 + ( aAnoRef[4,2] / 100 ))
    aDados[ nLinha + 9 ][ 9] := aDados[ nLinha ][ 9] * ( 1 + ( aAnoRef[5,2] / 100 ))
    aDados[ nLinha + 9 ][11] := aDados[ nLinha ][11] * ( 1 + ( aAnoRef[6,2] / 100 ))

    aDados[ nLinha + 9 ][ 4] := (( aDados[ nLinha ][ 3] / aDados[ nLinha ][ 2] )  - 1 ) * 100
    aDados[ nLinha + 9 ][ 6] := (( aDados[ nLinha ][ 5] / aDados[ nLinha ][ 3] )  - 1 ) * 100
    aDados[ nLinha + 9 ][ 8] := (( aDados[ nLinha ][ 7] / aDados[ nLinha ][ 5] )  - 1 ) * 100
    aDados[ nLinha + 9 ][10] := (( aDados[ nLinha ][ 9] / aDados[ nLinha ][ 7] )  - 1 ) * 100
    aDados[ nLinha + 9 ][12] := (( aDados[ nLinha ][11] / aDados[ nLinha ][ 9] )  - 1 ) * 100
Next

Return(aDados)
