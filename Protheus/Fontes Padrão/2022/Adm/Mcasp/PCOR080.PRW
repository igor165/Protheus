#Include "PCOR080.CH"
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


#DEFINE ORDIN 1
#DEFINE VINCU 2
#DEFINE TOTAL 3

Static __nFunOpc  := 0
Static __aTabFunc := {}
Static __aTabSub  := {}
Static __aTabFon  := {}

Static __aTotFun := {"","", {0}}         //{Fonte de Recurso, Funcao, {Total}}
Static __aTotSbF := {"","", "", {0}}     //{Fonte de Recurso, Funcao, SubFunção {Total}}
Static __aTotPrg := {"","", "", "", {0}} //{Fonte de Recurso, Funcao, SubFunção, Programa {Total}}

Static __aTotGeral := {0, 0, 0}  //1-Ordinario 2-Vinculado 3-Total

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR080
LOA - Desens. Rel.Demonstrativo de Funções e Subfunção e Programas

@author Totvs
   
@version P12
@since   21/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR080()

Local oReport := Nil
Local cPerg   := Padr("PCOR080", Len(SX1->X1_GRUPO), " ")

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
    Help(,, "VER_RELEASE",, STR0001, 1, 0) //"Relatório Deminstrativo de Funções e SubFunções e Programas disponí­vel a partir da versao 12.1.31"                                                                                                                                                                                                                                                                                                                                                                                                                
ElseIf !SX1->(dbSeek(cPerg))
    Help(,, "NO_PERG",, STR0002, 1, 0) //"Para utilizacao do Relatorio é necessário aplicar o pacote acumulado da controladoria."                                                                                                                                                                                                                                                                                                                                                                                                                            
Else                 
    oReport := ReportDef(cPerg)

    If ValType(oReport) == "O"    
        oReport:PrintDialog()
    EndIf

    oReport := Nil    
EndIf
	
//CLEAR VAR STATIC
__nFunOpc  := 0
__aTabFunc := {}
__aTabSub  := {}
__aTabFon  := {}

//1-Fonte de Recurso 2-Função 3-Subfunção 4-prograna
//SubArray 1-Valor
__aTotFun := {"","", {0, 0, 0, 0}}                                                
__aTotSbF := {"","","", {0, 0, 0, 0}}                                                
__aTotPrg := {"","","","", {0, 0, 0, 0}} 

__aTotGeral := {0, 0, 0} 

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   21/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oDespesas, oBorder
Local cNomeProg := "PCOR080"
Local cTitulo   := Capital(STR0003)   //Demonstrativo de Funções e Subfunção e Programas – Com Vinculo de Recursos
Local cDescri 	:= OemToAnsi(STR0004) //"Este programa irá imprimir o Relatório Programa de Trabalho de Governo por Orgao."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                            {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:nFontBody := 7 //Define o tamanho da fonte

oBorder := TRBorder():New(oReport, 5,, 0)

//Secao Despesas Funcionais
oDespesas := TRSection():New(oReport, STR0005, {"cArqTmp"},, .F., .F.) //"DESPESA"

TRCell():New(oDespesas, "FUNCAO"    ,, STR0006  /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), 2    /*Tamanho*/, /*lPixel*/, {||(ALIAS())->(AKD_FUNCAO) }   /*CodeBlock*/, "LEFT" , .T., "LEFT" ,,,.T.) //"Função"
TRCell():New(oDespesas, "SBFUNCAO"  ,, STR0007  /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), 3    /*Tamanho*/, /*lPixel*/, {||(ALIAS())->(AKD_SBFUNC) }   /*CodeBlock*/, "LEFT" , .T., "LEFT" ,,,.T.) //"Subfunção" 
TRCell():New(oDespesas, "PROGRAMA"  ,, STR0008  /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), 5    /*Tamanho*/, /*lPixel*/, {||(ALIAS())->(AKD_PROGRA) }   /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Programa"
TRCell():New(oDespesas, "ESPECIF"   ,, STR0009  /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), 25   /*Tamanho*/, /*lPixel*/, {|| P080Desc(.F.)}             /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Especificação"
TRCell():New(oDespesas, "ORDINARIO" ,, STR0010  /*Titulo*/, PesqPict("AKT", "AKT_MVCRD1"), 20   /*Tamanho*/, /*lPixel*/, {|| ValFunc(1) }               /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Ordinário"
TRCell():New(oDespesas, "VINCULADO" ,, STR0011  /*Titulo*/, PesqPict("AKT", "AKT_MVCRD1"), 20   /*Tamanho*/, /*lPixel*/, {|| ValFunc(2) }               /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Vinculado" 
TRCell():New(oDespesas, "TOTAL"     ,, STR0012  /*Titulo*/, PesqPict("AKT", "AKT_MVCRD1"), 20   /*Tamanho*/, /*lPixel*/, {|| ValFunc(3) }               /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Total"
oDespesas:SetLinesBefore(0)



Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao  
utilizadas

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport) 
Local oDespesa      := oReport:Section(STR0005) //"DESPESA"
Local lRet          := .T.
Local oMeter, oText, oDlg 
Local lEnd          := .F.
Local cArqTmp       := GetNextAlias()
Local cArqTmpA   := cArqTmp + "_A"
Local cArqTmpB   := cArqTmp + "_B"
Local cArqTmpC   := cArqTmp + "_C"
Local cArqTmpD   := cArqTmp + "_D"
Local cOrgaoIni     := mv_par01
Local cOrgaoFim     := mv_par02
Local dDataIni      := mv_par03
Local dDataFim      := mv_par04
Local cCodAgl       := mv_par05
Local cMoeda        := mv_par06
Local nDivide       := mv_par07
Local aCpsAdic      := {}
Local cCondSQL      := ""
Local cTitulo       := STR0003 //"Demonstrativo de Funções e Subfunção e Programas – Com Vinculo de Recursos"
Local nX            := 0
Local cNomReal      := ""

//Validacoes para datas
If dDataIni >  dDataFim
    Alert(STR0013) //"A data Inicial nao pode ser maior que a data final!"
    lRet := .F.
ElseIf DateDiffDay(dDataIni, dDataFim) > 365 //Verifica periodo
    Alert(STR0015) //"O período máximo para emissao do relatório é de um ano, favor verificar Data Inicial e Data Final."
    lRet := .F.
EndIf

If lRet
    //Tabela de Cadastro de Programas -> AL0
    AL0->(DBSetOrder(1))

    //Tabela de Cadastro de Ação -> ALE
    ALE->(DBSetOrder(1))

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
    10 – Sub Elemento da Despesa - Específico   (8 dígitos - tabela AIG)                                                         Substr(AKD_CO,23,x)//nao definido
    11 – Fonte de Recurso (2 - digitos) - Específico                                                     Substr(AKD_CO, y,z)//nao definido
    12 – Código de Aplicação (4 - digitos) - Específico                                                  Substr(AKD_CO, s,t)//nao definido

    Neste Relatorio vamos utilizar: 
    Funçao -> Substr(AKD_CO, 7, 2)
    Sub Funçao -> Substr(AKD_CO, 9, 3)
    Programas -> Substr(AKD_CO, 12, 4)
    Fonte de Recurso -> Substr(AKD_CO, 16, 2) (Ajustado na A1G)
    */

    //Divide por
    If nDivide == 2        //Divide por cem
        nDivide := 100
    ElseIf nDivide == 3    //Divide por mil
        nDivide := 1000
    ElseIf nDivide == 4	    //Divide por milhao
        nDivide := 1000000
    EndIf

    //Estrutura a ser adicionada na tabela de saida para group by posterior a PCGERPLAN
    aAdd(aCpsAdic, {"AKD_FUNCAO", "C", 2, 0})
    aAdd(aCpsAdic, {"AKD_SBFUNC", "C", 3, 0})
    aAdd(aCpsAdic, {"AKD_PROGRA", "C", 4, 0})
    aAdd(aCpsAdic, {"AKD_FNTREC", "C", 2, 0})
    aAdd(aCpsAdic, {"AKD_TOTAL" ,"N", 18, 2})

    //Condicao a ser adicionada a clausula where da query
    cCondSQL := " AND Substring(AKD_CO,1,2) >= '" + Substr(cOrgaoIni, 1, 2) + "' AND "
    cCondSQL += "     Substring(AKD_CO,1,2) <= '" + Substr(cOrgaoFim, 1, 2) + "'     "


    //Monta Arquivo Temporario para Impressao
    MsgMeter({|oMeter, oText, oDlg, lEnd| ;
                cNomReal := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp,;
                        cMoeda, .T., cCodAgl, dDataIni, dDataFim,;
                        Nil, Nil, nDivide, aCpsAdic, cCondSQL)},;
                        STR0016, cTitulo) //"Criando Arquivo Temporario..."

    If (cArqTmp)->(!Eof())
        __aTabFunc := CargaTab("FC"/*cTabela*/, "FC"/*cRadical*/)  //Funcoes
        __aTabSub  := CargaTab("SB"/*cTabela*/, "SB"/*cRadical*/)  //Sub-Funcoes
        __aTabFon  := CargaTab("FR"/*cTabela*/, "FR"/*cRadical*/)  //Fonte de Recurso

        //Posicoes Programa e Acao
        nProgIni := __aTabSub[POSINI] + __aTabSub[QTDDIG]
        nProgQtd := TamSx3("AL0_CODIGO")[1]

        cQryUpdt := " UPDATE " + cNomReal 
        cQryUpdt += " SET AKD_FUNCAO  = Substring(" + Alltrim(__aTabFunc[CPOMOV]) + ", " + cValToChar(__aTabFunc[POSINI]) + ", " + cValToChar(__aTabFunc[QTDDIG]) + " ), "
        cQryUpdt += "     AKD_SBFUNC  = Substring(" + Alltrim(__aTabSub[CPOMOV])  + ", " + cValToChar(__aTabSub[POSINI]) + ", " + cValToChar(__aTabSub[QTDDIG]) + " ), "
        cQryUpdt += "     AKD_PROGRA  = Substring(AKD_CO," + cValToChar(nProgIni) + ", " + cValToChar(nProgQtd) + " ), "
        cQryUpdt += "     AKD_FNTREC  = Substring(" + Alltrim(__aTabFon[CPOMOV]) + ", " + cValToChar(__aTabFon[POSINI]) + ", " + cValToChar(__aTabFon[QTDDIG]) + " ), "
        cQryUpdt += "     AKD_TOTAL  = 0.00 "

        If TcSqlExec(cQryUpdt) <> 0
            UserException(TCSqlError())
            lRet := .F.
        EndIf

        If lRet
            //Coluna total
            cQryUpdt := " UPDATE " + cNomReal 
            cQryUpdt += " SET AKD_TOTAL = AKD_VALOR" + CValToChar(Val(cMoeda))
                        
            If TcSqlExec(cQryUpdt) <> 0
                UserException( TCSqlError() )
                lRet := .F.
            EndIf

            If lRet

                cQryAux := " SELECT AKD_FUNCAO, AKD_FNTREC,  "
                cQryAux += " SUM(AKD_TOTAL) AKD_TOTAL FROM " + cNomReal 
                cQryAux += " GROUP BY AKD_FUNCAO, AKD_FNTREC "
                cQryAux += " ORDER BY AKD_FUNCAO, AKD_FNTREC "
                dbUseArea(.T., "TOPCONN", TcGenQry(,, cQryAux), cArqTmpA)

                __aTotFun := {}

                //Percorre arquivo e armazena os totalizadores no array __aTotFun
                While (cArqTmpA)->(!Eof())
                    
                    aAdd(__aTotFun, { (cArqTmpA)->AKD_FNTREC, (cArqTmpA)->AKD_FUNCAO, {}})
                    aAdd(__aTotFun[Len(__aTotFun)][3], (cArqTmpA)->AKD_TOTAL)
                                
                    (cArqTmpA)->(dbSkip())
                EndDo

                //Totalizador para impressao da coluna Funcional - Quebra por funcao + subfuncao
                cQryAux := " SELECT AKD_FUNCAO, AKD_SBFUNC, AKD_FNTREC,"
                cQryAux += " SUM(AKD_TOTAL) AKD_TOTAL FROM " + cNomReal
                cQryAux += " GROUP BY AKD_FUNCAO, AKD_SBFUNC, AKD_FNTREC "
                cQryAux += " ORDER BY AKD_FUNCAO, AKD_SBFUNC, AKD_FNTREC "
                dbUseArea(.T., "TOPCONN", TcGenQry(,,cQryAux), cArqTmpB)

                __aTotSbF := {}
                            
                //Percorre arquivo e armazena os totalizadores no array __aTotSbF
                While (cArqTmpB)->( !Eof() )
                    aAdd(__aTotSbF, { (cArqTmpB)->AKD_FNTREC,(cArqTmpB)->AKD_FUNCAO, (cArqTmpB)->AKD_SBFUNC, {}})
                    aAdd(__aTotSbF[Len(__aTotSbF)][4], (cArqTmpB)->AKD_TOTAL)
                                
                    (cArqTmpB)->(dbSkip())
                EndDo

                //Totalizador para impressao da coluna Funcional - Quebra por funcao + subfuncao + programa
                cQryAux := " SELECT AKD_FUNCAO, AKD_SBFUNC, AKD_PROGRA, AKD_FNTREC, "
                cQryAux += " SUM(AKD_TOTAL) AKD_TOTAL FROM " + cNomReal
                cQryAux += " GROUP BY AKD_FUNCAO, AKD_SBFUNC, AKD_PROGRA, AKD_FNTREC "
                cQryAux += " ORDER BY AKD_FUNCAO, AKD_SBFUNC, AKD_PROGRA, AKD_FNTREC "
                dbUseArea(.T., "TOPCONN", TcGenQry(,,cQryAux), cArqTmpD)

                __aTotPrg := {}

                //Percorre arquivo e armazena os totalizadores no array __aTotPrg
                While (cArqTmpD)->( !Eof())
                    aAdd(__aTotPrg, {(cArqTmpD)->AKD_FNTREC,(cArqTmpD)->AKD_FUNCAO, (cArqTmpD)->AKD_SBFUNC, (cArqTmpD)->AKD_PROGRA, {}})
                    aAdd(__aTotPrg[Len(__aTotPrg)][5], (cArqTmpD)->AKD_TOTAL)
                                
                    (cArqTmpD)->(dbSkip())
                EndDo

                //Appenda os registros totalizadores na tabela temporaria (orgao + unidade + funcao)
                dbSelectArea(cArqTmp)
                            
                For nX := 1 To Len(__aTotFun)
                    RecLock(cArqTmp,.T.)
                    (cArqTmp)->AKD_FUNCAO   := __aTotFun[nX, 2]
                    (cArqTmp)->AKD_SBFUNC   := " "
                    (cArqTmp)->AKD_PROGRA   := " " 
                    (cArqTmp)->AKD_FNTREC   := __aTotFun[nX, 1] 
                    (cArqTmp)->AKD_TOTAL    := __aTotFun[nX, 3, 1]
                    MsUnlock()
                Next nX

                //Appenda os registros totalizadores na tabela temporaria (orgao+unidade+funcao+subfuncao)
                dbSelectArea(cArqTmp)
                            
                For nX := 1 To Len(__aTotSbF)
                    RecLock(cArqTmp,.T.)
                    (cArqTmp)->AKD_FUNCAO := __aTotSbF[nX, 2]
                    (cArqTmp)->AKD_SBFUNC := __aTotSbF[nX, 3]
                    (cArqTmp)->AKD_PROGRA := " "       
                    (cArqTmp)->AKD_FNTREC := __aTotSbF[nX, 1] 
                    (cArqTmp)->AKD_TOTAL  := __aTotSbF[nX, 4, 1]
                    MsUnlock()
                Next nX

                //Appenda os registros totalizadores na tabela temporaria (orgao + unidade + funcao + subfuncao + programa)
                dbSelectArea(cArqTmp)
                            
                For nX := 1 To Len(__aTotPrg)
                    RecLock(cArqTmp,.T.)
                    (cArqTmp)->AKD_FUNCAO := __aTotPrg[nX, 2]
                    (cArqTmp)->AKD_SBFUNC := __aTotPrg[nX, 3]
                    (cArqTmp)->AKD_PROGRA := __aTotPrg[nX, 4]
                    (cArqTmp)->AKD_FNTREC := __aTotPrg[nX, 1] 
                    (cArqTmp)->AKD_TOTAL  := __aTotPrg[nX, 5, 1]
                    MsUnlock()
                Next nX

                cQryAux := " SELECT * FROM " + cNomReal 
                cQryAux += " ORDER BY AKD_FUNCAO, AKD_SBFUNC, AKD_PROGRA, AKD_FNTREC "

                //Abre novamente a query para impressao
                dbUseArea(.T., "TOPCONN", TcGenQry(,,cQryAux), cArqTmpC)
                dbSelectArea(cArqTmpC)
                oDespesa:Init()

                //Todo o arquivo 
                While (cArqTmpC)->(!Eof())
                    If oReport:Cancel()
                        Exit
                    EndIf    

                    //Total Geral
                    __aTotGeral[ORDIN] += Iif((cArqTmpC)->AKD_FNTREC == '01',AKD_TOTAL,0)
                    __aTotGeral[VINCU] += Iif((cArqTmpC)->AKD_FNTREC == '02',AKD_TOTAL,0)
                    __aTotGeral[TOTAL] += AKD_TOTAL

                    oDespesa:PrintLine()  //Total por funcao+SubFuncao+programa
                    (cArqTmpC)->(dbSkip()) 
                           
                EndDo

                 //Total Geral
                If Len(__aTabFunc) > 0
                    __nFunOpc := 2
                    oReport:SkipLine()
                    oReport:ThinLine()
                    oReport:SkipLine()
                    oDespesa:PrintLine()
                EndIf

 
                oDespesa:Finish()    
            EndIf
        EndIf
    EndIf
EndIf


Return lRet

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
@since   06/08/2020
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


//-------------------------------------------------------------------
/*{Protheus.doc} P080Desc()
1=Funcao
2=SubFuncao
3=Programa
Localiza a Descricao da Funcional a ser impressa
@author Totvs
   
@version P12
@since   22/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function P080Desc(ltotal)

Local cFunc   := (ALIAS())->AKD_FUNCAO  //tem que estar posicionado no alias da query no laco principal
Local cSbFun := (ALIAS())->AKD_SBFUNC
Local cProg   := (ALIAS())->AKD_PROGRA
Local cDescri := Space(TAMDESCRI)
Local nTamChv := Len(A1H->A1H_ITECHV)
Local nPosEle := 0

Default lTotal := .F.

//array static carregado na funcao ReportPrint onde cada array tem a tabela correspondente
// __aTabFunc := {} -> Tabela FC - Funcoes
// __aTabSub  := {} -> Tabela SB - Sub-Funcoes

If !Empty(cProg) .And. !Empty(cSbFun) .And. !Empty(cFunc)
    //DESCRICAO DO PROGRAMA
    If AL0->( dbSeek(xFilial("AL0")+cProg) )
        cDescri := PadR( AL0->AL0_DESCRI,TAMDESCRI)
    EndIf

ElseIf !Empty(cSbFun) .And. !Empty(cFunc)
    //DESCRICAO DA SUBFUNCAO
    If (nPosEle := aScan(__aTabSub[ITETAB], {|x| x[ITECHV]==PadR(cSbFun, nTamChv)}) )>0
        cDescri := PadR( __aTabSub[ITETAB][nPosEle][ITEDES],TAMDESCRI)
    EndIf
ElseIf !Empty(cFunc)
    //DESCRICAO DA FUNCAO
    If (nPosEle := aScan(__aTabFunc[ITETAB], {|x| x[ITECHV]==PadR(cFunc, nTamChv)}) )>0
        cDescri := PadR( __aTabFunc[ITETAB][nPosEle][ITEDES],TAMDESCRI)
    EndIf
ElseIf __nFunOpc == 2
    cDescri := "Total Geral:" //"Total Geral:  "
EndIf

Return cDescri

//-------------------------------------------------------------------
/*{Protheus.doc} ValFunc()
Coluna Valor das funcionais

@author Totvs
   
@version P12
@since   22/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function ValFunc(nOpcFunc)

Local nValor := 0
Local lFunc     := .F.
Local lSbFunc   := .F.
Local lProg     := .F.
Local cFunc   := (ALIAS())->AKD_FUNCAO  //tem que estar posicionado no alias da query no laco principal
Local cSbFun := (ALIAS())->AKD_SBFUNC
Local cProg   := (ALIAS())->AKD_PROGRA

Default nOpcFunc := 0

If !Empty(cProg) .And. !Empty(cSbFun) .And. !Empty(cFunc)
    lProg := .T.
ElseIf !Empty(cSbFun) .And. !Empty(cFunc)
    lSbFunc := .T.
ElseIf !Empty(cFunc)
    lFunc := .T.
EndIf

If nOpcFunc == 1 .And. ((ALIAS())->AKD_FNTREC == '01' .OR.__nFunOpc == 2) //Ordinario
    If __nFunOpc == 2
        nValor := __aTotGeral[ORDIN]
    Else
        nValor := (ALIAS())->AKD_TOTAL //Sempre deve estar posicionado na area da query do laco principal
    EndIf
ElseIf nOpcFunc == 2 .And. ((ALIAS())->AKD_FNTREC == '02' .OR.__nFunOpc == 2)//Vinculado
     If __nFunOpc == 2
        nValor := __aTotGeral[VINCU]
    Else
        nValor := (ALIAS())->AKD_TOTAL //Sempre deve estar posicionado na area da query do laco principal
    EndIf
Elseif nOpcFunc == 3 //Total
     If __nFunOpc == 2
        nValor := __aTotGeral[TOTAL]
    Else
        nValor := (ALIAS())->AKD_TOTAL
    EndIf
EndIf

Return nValor  