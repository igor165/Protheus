#Include "PCOR077.CH"
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

Static __nFunOpc   := 0
Static __nTotFunc  := 0
Static __nTotGeral := 0
Static __aTabFunc  := {}

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR077
Relatorio Demonstrativo da Despesa - Por Orgaos e Funcoes - LOA

@author Totvs
   
@version P12
@since   03/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR077()

Local oReport := Nil
Local cPerg   := Padr("PCOR077", Len(SX1->X1_GRUPO), " ")

//=================================================================================================================================================
// mv_par01    Orgao De:           									
// mv_par02    Orgao Ate:       
// mv_par03    Periodo de:           									
// mv_par04    Periodo Ate:                							
// mv_par05    Aglutinador de Visoes:          						
// mv_par06    Moeda:    							                    
// mv_par07    Divide por:    						                    
//=================================================================================================================================================

SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.025"
    Help(,, "VER_RELEASE",, OemToAnsi(STR0001), 1, 0) //"Relatório Demonstrativo da Despesa - Por Orgaos e Funcoes disponí­vel a partir da versao 12.1.31"
ElseIf !SX1->(dbSeek(cPerg))
    Help(,, "NO_PERG",, OemToAnsi(STR0002), 1, 0) //"Para utilizacao do Relatorio Demonstrativo da Despesa - Por Orgaos e Funcoes é necessário aplicar o pacote acumulado da controladoria."
Else                 
    oReport := ReportDef(cPerg)

    If ValType(oReport) == "O"    
        oReport:PrintDialog()
    EndIf

    oReport := Nil    
EndIf
	
//CLEAR VAR STATIC
__nFunOpc   := 0
__nTotFunc  := 0
__nTotGeral := 0
__aTabFunc  := {}
                                        
Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   03/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oCabec, oFuncao, oOrgaos, oBorder
Local cNomeProg := "PCOR077"
Local cTitulo   := Capital(STR0003)   //"Demonstrativo da Despesa - Por Orgaos e Funcoes"
Local cDescri 	:= OemToAnsi(STR0004) //"Este programa irá imprimir o Relatório Demonstrativo da Despesa - Por Orgaos e Funcoes."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                            {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:nFontBody := 7 //Define o tamanho da fonte

oBorder := TRBorder():New(oReport, 5,, 0)

//Secao Cabecalho
oCabec := TRSection():New(oReport, STR0005, {}, /*aOrdem*/) //"EXERCICIO"
TRCell():New(oCabec, "EXERCICIO",, "",, 80, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder //Remove a borda do cabecalho
oCabec:SetLinesBefore(0)

//Secao Funcao
oFuncao := TRSection():New(oReport, STR0006, {"cArqTmp"},, .F., .F.) //"FUNCAO"
TRCell():New(oFuncao, "FUNCAO",, STR0007 /*Titulo*/, PesqPict("ALD", "ALD_CODIGO"), 2         /*Tamanho*/, /*lPixel*/, {|| Cod_Func()} /*CodeBlock*/ , "LEFT" , .T., "LEFT",, 3) //"Funcao "
TRCell():New(oFuncao, "DESFUN",, STR0008 /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), TAMDESCRI /*Tamanho*/, /*lPixel*/, {|| Desc_Func()} /*CodeBlock*/, "LEFT" , .T., "LEFT")     //"Descricao"
oFuncao:SetLineStyle(.T.)
oFuncao:SetLinesBefore(0)

//Secao Orgaos
oOrgaos := TRSection():New(oReport, "ORGAO", {"cArqTmp"},, .F., .F.) //"ORGAO"

TRCell():New(oOrgaos, "ORGAO"    ,, STR0009 /*Titulo*/, PesqPict("ALD", "ALD_CODIGO"), TamSx3("ALD_CODIGO")[1] /*Tamanho*/, /*lPixel*/, {|| Cod_Orgao()}  /*CodeBlock*/, "LEFT" , .T., "LEFT",, 3)  //"Orgao"
TRCell():New(oOrgaos, "DESCRICAO",, STR0008 /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), TamSx3("ALD_DESCRI")[1] /*Tamanho*/, /*lPixel*/, {|| Desc_Orgao()} /*CodeBlock*/, "LEFT" , .T., "LEFT",, 20) //"Descricao"
TRCell():New(oOrgaos, "VALOR"    ,, STR0010 /*Titulo*/, PesqPict("AKT", "AKT_MVCRD1"), TamSx3("AKT_MVCRD1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Orgao()}  /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Valor Orcado"
oOrgaos:SetLinesBefore(0)

Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao  
utilizadas

@author Totvs
   
@version P12
@since   03/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport) 

Local oCabec     := oReport:Section("EXERCICIO") 
Local oFuncao    := oReport:Section("FUNCAO")
Local oOrgaos    := oReport:Section("ORGAO")
Local cNomReal   := ""
Local cCondSQL   := ""
Local cQryUpdt   := ""
Local cQryAux    := ""
Local cFuncao    := ""
Local cOrgao     := ""
Local cTitulo    := STR0003 //"Demonstrativo da Despesa - Por Orgaos e Funcoes"
Local cOrgaoIni  := MV_PAR01
Local cOrgaoFim  := MV_PAR02
Local dDataIni   := MV_PAR03
Local dDataFim   := MV_PAR04
Local cCodAgl    := MV_PAR05
Local cMoeda     := MV_PAR06 
Local cArqTmp    := GetNextAlias()
Local cArqTmpA   := cArqTmp + "_A"
Local cCpoValor  := "AKD_VALOR1"
Local nDivide    := 1
Local aMoedas    := CtbMoeda(cMoeda) 
Local aCpsAdic   := {}
Local lNewFunc   := .T. 
Local lRet       := .T.

//Validacoes para datas
If dDataIni >  dDataFim
    Alert(STR0011) //"A data Inicial nao pode ser maior que a data final!"
    lRet := .F.
ElseIf DateDiffDay(dDataIni, dDataFim) > 365 //Verifica periodo
    lRet := MsgYesNo(STR0012, STR0013) //"O período máximo recomendado para emissao do relatório é de um ano, deseja continuar?" #"Atencao"
EndIf

If lRet
    cCpoValor := "AKD_VALOR" + CValToChar(Val(cMoeda))

    oReport:OnPageBreak({|| ImpCabec(oReport, oCabec, aMoedas)})

    /*
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

    Neste Relatorio vamos utilizar: 
    Orgao -> Substr(AKD_CO, 1, 2)
    Funçao -> Substr(AKD_CO, 7, 2)
    */

    //Divide por
    If MV_PAR07 == 2        //Divide por cem
        nDivide := 100
    ElseIf MV_PAR07 == 3    //Divide por mil
        nDivide := 1000
    ElseIf MV_PAR07 == 4	//Divide por milhao
        nDivide := 1000000
    EndIf

    //Estrutura a ser adicionada na tabela de saida para group by posterior a PCGERPLAN
    aAdd(aCpsAdic, {"AKD_ORGAO" , "C", 2, 0})
    aAdd(aCpsAdic, {"AKD_FUNCAO", "C", 2, 0})
    aAdd(aCpsAdic, {"AKD_TOTAL" , "N", 18, 2})

    //Condicao a ser adicionada a clausula where da query
    cCondSQL := " AND Substring(AKD_CO,1,2) >= '" + Substr(cOrgaoIni, 1, 2) + "' AND "
    cCondSQL += "     Substring(AKD_CO,1,2) <= '" + Substr(cOrgaoFim, 1, 2) + "'     "

    //Monta Arquivo Temporario para Impressao
    MsgMeter({|oMeter, oText, oDlg, lEnd| ;
                cNomReal := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp, cMoeda, .T., cCodAgl, dDataIni, dDataFim,;
                                        Nil, Nil, nDivide, aCpsAdic, cCondSQL)}, STR0014, cTitulo) //"Criando Arquivo Temporario..."

    If (cArqTmp)->(!Eof())
        __aTabFunc := CargaTab("FC" /*cTabela*/, "FC" /*cRadical*/)  //Funcoes

        cQryUpdt := " UPDATE " + cNomReal 
        cQryUpdt += " SET AKD_ORGAO   = Substring(AKD_CO,1,2), "
        cQryUpdt += "     AKD_FUNCAO  = Substring(" + Alltrim(__aTabFunc[CPOMOV]) + ", " + cValToChar(__aTabFunc[POSINI]) + ", " + cValToChar(__aTabFunc[QTDDIG]) + " ) "

        If TcSqlExec(cQryUpdt) <> 0
            UserException(TCSqlError())
            lRet := .F.
        EndIf
           
        If lRet
            //Coluna total
            cQryUpdt := " UPDATE " + cNomReal 
            cQryUpdt += " SET AKD_TOTAL = AKD_VALOR" + CValToChar(Val(cMoeda))
            
            If TcSqlExec(cQryUpdt) <> 0
                UserException(TCSqlError())
                lRet := .F.
            EndIf

            If lRet
                //Totalizador para impressao - Quebra por funcao
                cQryAux := " SELECT AKD_ORGAO, AKD_FUNCAO, "
                cQryAux += "  SUM(AKD_TOTAL) AKD_TOTAL FROM " + cNomReal 
                cQryAux += "    GROUP BY AKD_ORGAO, AKD_FUNCAO "
                cQryAux += "    ORDER BY AKD_FUNCAO, AKD_ORGAO "
                dbUseArea(.T., "TOPCONN", TcGenQry(,, cQryAux), cArqTmpA)

                oOrgaos:Init()

                __nTotGeral := 0

                //Todo o arquivo 
                While (cArqTmpA)->(!Eof())
                    If oReport:Cancel()
                        Exit
                    EndIf

                    cFuncao := (cArqTmpA)->AKD_FUNCAO 

                    oReport:SkipLine()
                    oFuncao:Init()
                    oFuncao:PrintLine()

                    __nTotFunc := 0
                    lNewFunc   := .T. 

                    //Laço quebrando por Funcao      
                    While (cArqTmpA)->(!Eof()) .And.; 
                        (cArqTmpA)->AKD_FUNCAO == cFuncao
                        
                        If oReport:Cancel()
                            Exit
                        EndIf

                        cOrgao := (cArqTmpA)->AKD_ORGAO

                        //Laço quebrando por Funcao      
                        While (cArqTmpA)->(!Eof()) .And.; 
                            (cArqTmpA)->AKD_FUNCAO == cFuncao .And.;
                            (cArqTmpA)->AKD_ORGAO == cOrgao
                        
                            If oReport:Cancel()
                                Exit
                            EndIf

                            If lNewFunc
                                oOrgaos:Finish()
                                oOrgaos:Init()
                            EndIf

                            __nFunOpc := 1
                            oOrgaos:PrintLine() //Imprime Orgao

                            __nTotFunc  += (cArqTmpA)->AKD_TOTAL //Total Funcao
                            __nTotGeral += (cArqTmpA)->AKD_TOTAL //Total Geral

                            lNewFunc  := .F.

                            (cArqTmpA)->(dbSkip())
                        EndDo                              
                    EndDo

                    __nFunOpc := 2                        
                    oReport:SkipLine()
                    oOrgaos:PrintLine() //Imprime Total Funcao
                    oReport:ThinLine()                         
                EndDo

                //Imprime Total Geral
                __nFunOpc := 3
                oReport:SkipLine()
                oOrgaos:PrintLine()

                //Final do relatorio
                __nFunOpc := 4

                oOrgaos:Finish()
                oFuncao:Finish()
            EndIf
        EndIf
    EndIf  

    //Fecha arquivos temporarios
    If Select("cArqTmpA") > 0
        (cArqTmpA)->(dbCloseArea()) 
    EndIf

    If Select("cArqTmp") > 0
        (cArqTmp)->(dbCloseArea()) 
    EndIf
EndIf

//Limpa arrays
aSize(__aTabFunc, 0)
    
__aTabFunc := Nil

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} Cod_Func()
Retorna o Codigo da Funcao a ser impressa

@author Totvs
   
@version P12
@since   04/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Cod_Func()
Return (ALIAS())->(AKD_FUNCAO) 

//-------------------------------------------------------------------
/*{Protheus.doc} Desc_Func()

Retorna a Descricao da Funcao a ser impressa
@author Totvs
   
@version P12
@since   04/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Desc_Func()

Local cDescri  := Space(TamSx3("ALD_DESCRI")[1])
Local nPosEle  := 0
Local nTamDesc := TamSx3("ALD_DESCRI")[1]
Local nTamChv  := Len(A1H->A1H_ITECHV)

//Array static carregado na funcao ReportPrint onde cada array tem a tabela correspondente
//__aTabFunc := {} -> Tabela FC - Funcoes

If (nPosEle := aScan(__aTabFunc[ITETAB], {|x| x[ITECHV] == PadR((ALIAS())->AKD_FUNCAO, nTamChv)})) > 0 //Tem que estar posicionado no alias da query no laco principal
    cDescri := PadR(__aTabFunc[ITETAB][nPosEle][ITEDES], nTamDesc)
EndIf

Return cDescri

//-------------------------------------------------------------------
/*{Protheus.doc} Cod_Orgao()
Codigo do Orgao

@author Totvs
   
@version P12
@since   04/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Cod_Orgao()

Local cCodOrgao := ""

If __nFunOpc == 1
    cCodOrgao := (ALIAS())->AKD_ORGAO + "0000"
EndIf

Return cCodOrgao

//-------------------------------------------------------------------
/*{Protheus.doc} Desc_Orgao()
Descricao do Orgao

@author Totvs
   
@version P12
@since   04/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Desc_Orgao()

Local cDescri  := ""
Local nTamDesc := TamSx3("ALD_DESCRI")[1]

If __nFunOpc == 1
    cDescri := Posicione("ALD", 1, xFilial("ALD") + (ALIAS())->AKD_ORGAO + "0000", "ALD_DESCRI")
ElseIf __nFunOpc == 2
    cDescri := PadL(STR0015, nTamDesc, "-") //" Total Funcao: "
ElseIf __nFunOpc == 3
    cDescri := PadL(STR0016, nTamDesc, "-") //" Total Geral : "
EndIf

Return cDescri

//-------------------------------------------------------------------
/*{Protheus.doc} Val_Orgao()
Coluna Valor Total dos Orgaos

@author Totvs
   
@version P12
@since   04/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Val_Orgao()

Local nValor := 0

If __nFunOpc == 1
    nValor := (ALIAS())->(AKD_TOTAL)
ElseIf __nFunOpc == 2
    nValor := __nTotFunc
ElseIf __nFunOpc == 3
    nValor := __nTotGeral
EndIf

Return nValor  

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCabec
Cabecalho do relatorio - Imprimir em todas as paginas

@author Totvs
   
@version P12
@since   03/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ImpCabec(oReport, oCabec, aMoedas)

Local cUnidMoed := ""

If MV_PAR07 == 2
    cUnidMoed := STR0017 //"Centena de "
ElseIf MV_PAR07 == 3
    cUnidMoed := STR0018 //"Milhares de "
ElseIf MV_PAR07 == 4
    cUnidMoed := STR0019 //"Milhoes de "
EndIf

//Imprime cabecalho
oCabec:Init()
oCabec:Cell("EXERCICIO"):SetBlock({|| STR0020 + SubStr(DToS(MV_PAR03), 1, 4) + " (" + STR0021 + AllTrim(cUnidMoed) + AllTrim(aMoedas[3]) + ")"}) //"Exercício: " #"Moeda: "
oCabec:PrintLine()
oCabec:Finish()

oReport:ThinLine()

//Pula linha
oReport:SkipLine()

Return Nil

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
@since   03/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function CargaTab(cTabela, cRadical)

Local aArea    := GetArea()
Local aAreaA1G := A1G->(GetArea())
Local aAreaA1H := A1H->(GetArea())
Local aTab     := {}

Default cTabela  := ""
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
    cTabela  := PadR(cTabela, Len(A1G->A1G_CODTAB))
    cRadical := PadR(cRadical, Len(A1H->A1H_RADCHV))

    A1G->(dbSetOrder(1)) //A1G_FILIAL+A1G_CODTAB
    A1H->(dbSetOrder(2)) //A1H_FILIAL+A1H_CODTAB+A1H_RADCHV+A1H_ITECHV

    If A1G->(dbSeek(xFilial("A1G")+cTabela)) 
        aTab := Array(6)  //6 ELEMENTOS
        aTab[CODTAB] := A1G->A1G_CODTAB
        aTab[DESTAB] := A1G->A1G_DESTAB
        aTab[CPOMOV] := A1G->A1G_CAMPO     
        aTab[POSINI] := A1G->A1G_INICPO
        aTab[QTDDIG] := A1G->A1G_DIGCPO
        aTab[ITETAB] := {}  

        If A1H->(dbSeek(xFilial("A1H") + cTabela)) 
            While A1H->(!EOF() .And. A1H_FILIAL == xFilial("A1H") .And. A1H_CODTAB == cTabela .And. A1H_RADCHV == cRadical)
                aAdd(aTab[ITETAB], Array(2)) //2 ELEMENTOS NO SUB ARRAY ITECHV DESCHV
            
                aTab[ITETAB][Len(aTab[ITETAB])][ITECHV] := A1H->A1H_ITECHV
                aTab[ITETAB][Len(aTab[ITETAB])][ITEDES] := A1H->A1H_CHVCNT

                A1H->(dbSkip()) 
            EndDo
        EndIf
    EndIf
EndIf

//Restaura areas
RestArea(aAreaA1H)
RestArea(aAreaA1G)
RestArea(aArea)

Return aTab