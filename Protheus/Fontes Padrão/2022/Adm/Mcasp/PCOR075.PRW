#Include "PCOR075.CH"
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

#DEFINE OPESPE 1
#DEFINE PROJET 2
#DEFINE ATIVID 3
#DEFINE TOTAL  4

Static __nFunOpc  := 0
Static __aTabFunc := {}
Static __aTabSub  := {}

Static __aTotFun := {"", "", "", {0, 0, 0, 0}}         //SubArray 1-Oper.Espec 2-Projeto 3-Atividades 4-Total
Static __aTotSbF := {"", "", "", "", {0, 0, 0, 0}}     //SubArray 1-Oper.Espec 2-Projeto 3-Atividades 4-Total
Static __aTotPrg := {"", "", "", "", "", {0, 0, 0, 0}} //SubArray 1-Oper.Espec 2-Projeto 3-Atividades 4-Total

Static __aTotUnFun := {0, 0, 0, 0}  //1-Oper.Espec 2-Projeto 3-Atividades 4-Total
Static __aTotGerUn := {0, 0, 0, 0}  //1-Oper.Espec 2-Projeto 3-Atividades 4-Total
Static __aTotGeral := {0, 0, 0, 0}  //1-Oper.Espec 2-Projeto 3-Atividades 4-Total

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR075
Relatorio Programa de Trabalho de Governo por Orgao - LOA
EconÃ´micas

@author Totvs
   
@version P12
@since   19/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR075()

Local oReport := Nil
Local cPerg   := Padr("PCOR075", Len(SX1->X1_GRUPO), " ")

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
    Help(,, "VER_RELEASE",, OemToAnsi(STR0001), 1, 0) //"Relatório Programa de Trabalho de Governo por Orgao disponí­vel a partir da versao 12.1.31"
ElseIf !SX1->(dbSeek(cPerg))
    Help(,, "NO_PERG",, OemToAnsi(STR0002), 1, 0) //"Para utilizacao do Relatorio Programa de Trabalho de Governo por Orgao é necessário aplicar o pacote acumulado da controladoria."
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

//1-orgao 2-unid.orc. 3-funcao 4-SubFuncao
//SubArray 1-Oper.Espec 2-Projeto 3-Atividades 4-Total
__aTotFun := {"","","", {0, 0, 0, 0}}                                                
__aTotSbF := {"","","","", {0, 0, 0, 0}}                                                
__aTotPrg := {"","","","","", {0, 0, 0, 0}} 

__aTotUnFun := {0, 0, 0, 0} //1-Oper.Espec 2-Projeto 3-Atividades 4-Total
__aTotGerUn := {0, 0, 0, 0} //1-Oper.Espec 2-Projeto 3-Atividades 4-Total
__aTotGeral := {0, 0, 0, 0} //1-Oper.Espec 2-Projeto 3-Atividades 4-Total

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   19/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oCabec, oOrgao, oOrcamen, oExecutor, oDespesas, oBorder
Local cNomeProg := "PCOR075"
Local cTitulo   := Capital(STR0003)   //"Programa de Trabalho de Governo por Orgao"
Local cDescri 	:= OemToAnsi(STR0004) //"Este programa irá imprimir o Relatório Programa de Trabalho de Governo por Orgao."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                            {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:nFontBody := 7 //Define o tamanho da fonte

oBorder := TRBorder():New(oReport, 5,, 0)

//Secao Cabecalho
oCabec := TRSection():New(oReport, STR0016, {}, /*aOrdem*/) //"EXERCICIO"
TRCell():New(oCabec, "EXERCICIO",, "",, 80, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder //Remove a borda do cabecalho
oCabec:SetLinesBefore(0)

//Secao Orgao
oOrgao := TRSection():New(oReport, STR0005, {"cArqTmp"},, .F., .F.) //"ORGAO"
TRCell():New(oOrgao, "ORGAO" ,, STR0006 + Replicate("-", 14) /*Titulo*/, PesqPict("ALD", "ALD_CODIGO"), TamSx3("ALD_CODIGO")[1] /*Tamanho*/, /*lPixel*/, {||Cod_Orgao()} /*CodeBlock*/, "LEFT" , .T., "LEFT",,, .T.,,, .T.) //"Orgao "
TRCell():New(oOrgao, "DESORG",, STR0007                      /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), TamSx3("ALD_DESCRI")[1] /*Tamanho*/, /*lPixel*/, {||Des_Orgao()} /*CodeBlock*/, "LEFT" , .T., "LEFT",,, .T.,,, .T.) //"Descricao"
oOrgao:SetLineStyle(.T.)
oOrgao:SetLinesBefore(0)

//Secao Unidade Orcamentaria
oOrcamen := TRSection():New(oReport, STR0017, {"cArqTmp"},, .F., .F.) //"ORCAMENTO"
TRCell():New(oOrcamen, "UNIDAD",, STR0008 /*Titulo*/, PesqPict("ALD", "ALD_CODIGO"), TamSx3("ALD_CODIGO")[1] /*Tamanho*/, /*lPixel*/, {||Cod_Unid(1)} /*CodeBlock*/, "LEFT" , .T., "LEFT",,, .T.,,, .T.) //"Unidade Orcamentária"
TRCell():New(oOrcamen, "DESUNI",, STR0007 /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), TamSx3("ALD_DESCRI")[1] /*Tamanho*/, /*lPixel*/, {||Des_Unid(1)} /*CodeBlock*/, "LEFT" , .T., "LEFT",,, .T.,,, .T.) //"Descricao"
oOrcamen:SetLineStyle(.T.)
oOrcamen:SetLinesBefore(0)

//Secao Unidade Executora
oExecutor := TRSection():New(oReport, STR0019, {"cArqTmp"},, .F., .F.) //"EXECUTOR"
TRCell():New(oExecutor, "UNIDAD",, STR0009 + Replicate("-", 2) /*Titulo*/, PesqPict("ALD", "ALD_CODIGO"), TamSx3("ALD_CODIGO")[1] /*Tamanho*/, /*lPixel*/, {||Cod_Unid(2)} /*CodeBlock*/, "LEFT" , .T., "LEFT",,, .T.,,, .T.) //"Unidade Executora"
TRCell():New(oExecutor, "DESUNI",, STR0007 /*Titulo*/                    , PesqPict("ALD", "ALD_DESCRI"), TamSx3("ALD_DESCRI")[1] /*Tamanho*/, /*lPixel*/, {||Des_Unid(2)} /*CodeBlock*/, "LEFT" , .T., "LEFT",,, .T.,,, .T.) //"Descricao"
oExecutor:SetLineStyle(.T.)
oExecutor:SetLinesBefore(0)

//Secao Despesas Funcionais
oDespesas := TRSection():New(oReport, STR0018, {"cArqTmp"},, .F., .F.) //"DESPESA"

TRCell():New(oDespesas, "FUNCIONAL" ,, STR0010 /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), TamSx3("AK5_CODIGO")[1] + 3 /*Tamanho*/, /*lPixel*/, {||Funcional()} /*CodeBlock*/, "LEFT" , .T., "LEFT" ,,,.T.) //"Funcional"
TRCell():New(oDespesas, "DESCRICAO" ,, STR0007 /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), TAMDESCRI    /*Tamanho*/               , /*lPixel*/, {||DescFunc()}  /*CodeBlock*/, "LEFT" , .T., "LEFT" ,,,.T.) //"Descricao"
TRCell():New(oDespesas, "ESPECIAIS" ,, STR0011 /*Titulo*/, PesqPict("AKT", "AKT_MVCRD1"), 20           /*Tamanho*/               , /*lPixel*/, {|| ValFunc(1)} /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Op. Especiais"
TRCell():New(oDespesas, "PROJETOS"  ,, STR0012 /*Titulo*/, PesqPict("AKT", "AKT_MVCRD1"), 20           /*Tamanho*/               , /*lPixel*/, {|| ValFunc(2)} /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Projetos"
TRCell():New(oDespesas, "ATIVIDADES",, STR0013 /*Titulo*/, PesqPict("AKT", "AKT_MVCRD1"), 20           /*Tamanho*/               , /*lPixel*/, {|| ValFunc(3)} /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Atividades"
TRCell():New(oDespesas, "TOTAL"     ,, STR0014 /*Titulo*/, PesqPict("AKT", "AKT_MVCRD1"), 20           /*Tamanho*/               , /*lPixel*/, {|| ValFunc()}  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Total"
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

Local oCabec     := oReport:Section(STR0016) //"EXERCICIO"
Local oOrgao     := oReport:Section(STR0005) //"ORGAO"
Local oOrcamen   := oReport:Section(STR0017) //"ORCAMENTO"
Local oExecutor  := oReport:Section(STR0019) //"EXECUTOR"
Local oDespesa   := oReport:Section(STR0018) //"DESPESA"
Local cNomReal   := ""
Local cCondSQL   := ""
Local cQryUpdt   := ""
Local cQryAux    := ""
Local cOrcamen   := ""
Local cExecutor  := ""
Local cFuncao    := ""
Local cSubFuncao := ""
Local cPrograma  := ""
Local cTitulo    := STR0003 //"Programa de Trabalho de Governo por Orgao"
Local cOrgaoIni  := MV_PAR01
Local cOrgaoFim  := MV_PAR02
Local dDataIni   := MV_PAR03
Local dDataFim   := MV_PAR04
Local cCodAgl    := MV_PAR05
Local cMoeda     := MV_PAR06 
Local cArqTmp    := GetNextAlias()
Local cArqTmpA   := cArqTmp + "_A"
Local cArqTmpB   := cArqTmp + "_B"
Local cArqTmpC   := cArqTmp + "_C"
Local cArqTmpD   := cArqTmp + "_D"
Local cCpoValor  := "AKD_VALOR1"
Local nDivide    := 1
Local nProgIni   := 0
Local nProgQtd   := 0
Local nAcaoIni   := 0
Local nAcaoQtd   := 0
Local nX         := 0
Local aMoedas    := CtbMoeda(cMoeda) 
Local aCpsAdic   := {}
Local lRet       := .T.
Local lNewGrp    := .F.

//Validacoes para datas
If dDataIni >  dDataFim
    Alert(STR0015) //"A data Inicial nao pode ser maior que a data final!"
    lRet := .F.
ElseIf DateDiffDay(dDataIni, dDataFim) > 365 //Verifica periodo
    lRet := MsgYesNo(STR0020, STR0021) //"O período máximo recomendado para emissao do relatório é de um ano, deseja continuar?" #"Atencao")
EndIf

If lRet
    //Tabela de Cadastro de Programas -> AL0
    AL0->(DBSetOrder(1))

    //Tabela de Cadastro de Ação -> ALE
    ALE->(DBSetOrder(1))

    //Tabela de Cadastro de Orgao -> ALD
    ALD->(DBSetOrder(1))

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
    Unidade Orçamentária -> Substr(AKD_CO, 3, 2)
    Unidade Executora -> Substr(AKD_CO, 5, 2)
    Funçao -> Substr(AKD_CO, 7, 2)
    Sub Funçao -> Substr(AKD_CO, 9, 3)
    Programas -> Substr(AKD_CO, 12, 4)
    Açao -> Substr(AKD_CO, 16, 4)
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
    aAdd(aCpsAdic, {"AKD_ORCAM" , "C", 2, 0})
    aAdd(aCpsAdic, {"AKD_EXEC"  , "C", 2, 0})
    aAdd(aCpsAdic, {"AKD_FUNCAO", "C", 2, 0})
    aAdd(aCpsAdic, {"AKD_SBFUNC", "C", 3, 0})
    aAdd(aCpsAdic, {"AKD_PROGRA", "C", 4, 0})
    aAdd(aCpsAdic, {"AKD_ACAO"  , "C", 4, 0})

    //Valores separados por tipo de acao
    aAdd(aCpsAdic, {"AKD_OPESPE" ,"N", 18, 2})
    aAdd(aCpsAdic, {"AKD_PROJET" ,"N", 18, 2})
    aAdd(aCpsAdic, {"AKD_ATIVID" ,"N", 18, 2})
    aAdd(aCpsAdic, {"AKD_TOTAL"  ,"N", 18, 2})

    //Condicao a ser adicionada a clausula where da query
    cCondSQL := " AND Substring(AKD_CO,1,2) >= '" + Substr(cOrgaoIni, 1, 2) + "' AND "
    cCondSQL += "     Substring(AKD_CO,1,2) <= '" + Substr(cOrgaoFim, 1, 2) + "'     "

    //Monta Arquivo Temporario para Impressao
    MsgMeter({|oMeter, oText, oDlg, lEnd| ;
                cNomReal := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp,;
                        cMoeda, .T., cCodAgl, dDataIni, dDataFim,;
                        Nil, Nil, nDivide, aCpsAdic, cCondSQL)},;
                        STR0022, cTitulo) //"Criando Arquivo Temporario..."

    If (cArqTmp)->(!Eof())
        __aTabFunc := CargaTab("FC"/*cTabela*/, "FC"/*cRadical*/)  //Funcoes
        __aTabSub  := CargaTab("SB"/*cTabela*/, "SB"/*cRadical*/)  //Sub-Funcoes

        //Posicoes Programa e Acao
        nProgIni := __aTabSub[POSINI] + __aTabSub[QTDDIG]
        nProgQtd := TamSx3("AL0_CODIGO")[1]
        nAcaoIni := nProgIni + nProgQtd
        nAcaoQtd := TamSx3("ALE_CODACA")[1]

        cQryUpdt := " UPDATE " + cNomReal 
        cQryUpdt += " SET AKD_ORGAO   = Substring(AKD_CO,1,2), "
        cQryUpdt += "     AKD_ORCAM   = Substring(AKD_CO,3,2), "
        cQryUpdt += "     AKD_EXEC    = Substring(AKD_CO,5,2), "
        cQryUpdt += "     AKD_FUNCAO  = Substring(" + Alltrim(__aTabFunc[CPOMOV]) + ", " + cValToChar(__aTabFunc[POSINI]) + ", " + cValToChar(__aTabFunc[QTDDIG]) + " ), "
        cQryUpdt += "     AKD_SBFUNC  = Substring(" + Alltrim(__aTabSub[CPOMOV])  + ", " + cValToChar(__aTabSub[POSINI]) + ", " + cValToChar(__aTabSub[QTDDIG]) + " ), "
        cQryUpdt += "     AKD_PROGRA  = Substring(AKD_CO," + cValToChar(nProgIni) + ", " + cValToChar(nProgQtd) + " ), "
        cQryUpdt += "     AKD_ACAO    = Substring(AKD_CO," + cValToChar(nAcaoIni) + ", " + cValToChar(nAcaoQtd) + " ), "
        cQryUpdt += "     AKD_OPESPE  = 0.00, "
        cQryUpdt += "     AKD_PROJET  = 0.00, "
        cQryUpdt += "     AKD_ATIVID  = 0.00, "
        cQryUpdt += "     AKD_TOTAL   = 0.00 "

        If TcSqlExec(cQryUpdt) <> 0
            UserException(TCSqlError())
            lRet := .F.
        EndIf

        If lRet
            //Acao tipo operacao especial
            cQryUpdt := " UPDATE " + cNomReal 
            cQryUpdt += " SET AKD_OPESPE  = AKD_VALOR" + CValToChar(Val(cMoeda))
            cQryUpdt += " WHERE R_E_C_N_O_ IN ( "
            cQryUpdt += "                        SELECT ARQTMP.R_E_C_N_O_ FROM " + cNomReal + " ARQTMP, " + RetSqlName("ALE") + " ALE "
            cQryUpdt += "                               WHERE ARQTMP.AKD_ACAO = ALE.ALE_CODACA AND ALE_TPACAO = '3' AND ALE.D_E_L_E_T_ = '' "
            cQryUpdt += "                       ) "

            If TcSqlExec(cQryUpdt) <> 0
                UserException( TCSqlError() )
                lRet := .F.
            EndIf

            If lRet
                //Acao tipo atividade
                cQryUpdt := " UPDATE " + cNomReal 
                cQryUpdt += " SET AKD_ATIVID  = AKD_VALOR" + CValToChar(Val(cMoeda))
                cQryUpdt += " WHERE R_E_C_N_O_ IN ( "
                cQryUpdt += "                        SELECT ARQTMP.R_E_C_N_O_ FROM " + cNomReal + " ARQTMP, " + RetSqlName("ALE") + " ALE "
                cQryUpdt += "                               WHERE ARQTMP.AKD_ACAO = ALE.ALE_CODACA AND ALE_TPACAO = '2' AND ALE.D_E_L_E_T_ = '' "
                cQryUpdt += "                       ) "
                
                If TcSqlExec(cQryUpdt) <> 0
                    UserException( TCSqlError() )
                    lRet := .F.
                EndIf

                If lRet
                    //Acao tipo projeto
                    cQryUpdt := " UPDATE " + cNomReal 
                    cQryUpdt += " SET AKD_PROJET  = AKD_VALOR" + CValToChar(Val(cMoeda))
                    cQryUpdt += " WHERE R_E_C_N_O_ IN ( "
                    cQryUpdt += "                        SELECT ARQTMP.R_E_C_N_O_ FROM " + cNomReal + " ARQTMP, " + RetSqlName("ALE") + " ALE "
                    cQryUpdt += "                               WHERE ARQTMP.AKD_ACAO = ALE.ALE_CODACA AND ALE_TPACAO = '1' AND ALE.D_E_L_E_T_ = '' "
                    cQryUpdt += "                       ) "
                    
                    If TcSqlExec(cQryUpdt) <> 0
                        UserException( TCSqlError() )
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
                            //Totalizador para impressao da coluna Funcional - Quebra por funcao
                            cQryAux := " SELECT AKD_ORGAO, AKD_ORCAM, AKD_EXEC, AKD_FUNCAO, SUM(AKD_OPESPE) AKD_OPESPE, "
                            cQryAux += " SUM(AKD_PROJET) AKD_PROJET,  SUM(AKD_ATIVID) AKD_ATIVID,  SUM(AKD_TOTAL) AKD_TOTAL FROM " + cNomReal 
                            cQryAux += " GROUP BY AKD_ORGAO, AKD_ORCAM, AKD_EXEC, AKD_FUNCAO "
                            cQryAux += " ORDER BY AKD_ORGAO, AKD_ORCAM, AKD_EXEC, AKD_FUNCAO "
                            dbUseArea(.T., "TOPCONN", TcGenQry(,, cQryAux), cArqTmpA)

                             __aTotFun := {}

                            //Percorre arquivo e armazena os totalizadores no array __aTotFun
                            While (cArqTmpA)->(!Eof())
                                aAdd(__aTotFun, {(cArqTmpA)->AKD_ORGAO, (cArqTmpA)->AKD_ORCAM, (cArqTmpA)->AKD_EXEC, (cArqTmpA)->AKD_FUNCAO, {}})
                                aAdd(__aTotFun[Len(__aTotFun)][5], (cArqTmpA)->AKD_OPESPE)
                                aAdd(__aTotFun[Len(__aTotFun)][5], (cArqTmpA)->AKD_PROJET)
                                aAdd(__aTotFun[Len(__aTotFun)][5], (cArqTmpA)->AKD_ATIVID)
                                aAdd(__aTotFun[Len(__aTotFun)][5], (cArqTmpA)->AKD_TOTAL)
                                
                                (cArqTmpA)->(dbSkip())
                            EndDo

                            //Totalizador para impressao da coluna Funcional - Quebra por funcao + subfuncao
                            cQryAux := " SELECT AKD_ORGAO, AKD_ORCAM, AKD_EXEC, AKD_FUNCAO, AKD_SBFUNC, SUM(AKD_OPESPE) AKD_OPESPE, "
                            cQryAux += " SUM(AKD_PROJET) AKD_PROJET,  SUM(AKD_ATIVID) AKD_ATIVID,  SUM(AKD_TOTAL) AKD_TOTAL FROM " + cNomReal
                            cQryAux += " GROUP BY AKD_ORGAO, AKD_ORCAM, AKD_EXEC, AKD_FUNCAO, AKD_SBFUNC "
                            cQryAux += " ORDER BY AKD_ORGAO, AKD_ORCAM, AKD_EXEC, AKD_FUNCAO, AKD_SBFUNC "
                            dbUseArea(.T., "TOPCONN", TcGenQry(,,cQryAux), cArqTmpB)

                            __aTotSbF := {}
                            
                            //Percorre arquivo e armazena os totalizadores no array __aTotSbF
                            While (cArqTmpB)->( !Eof() )
                                aAdd(__aTotSbF, {(cArqTmpB)->AKD_ORGAO, (cArqTmpB)->AKD_ORCAM, (cArqTmpB)->AKD_EXEC, (cArqTmpB)->AKD_FUNCAO, (cArqTmpB)->AKD_SBFUNC, {}})
                                aAdd(__aTotSbF[Len(__aTotSbF)][6], (cArqTmpB)->AKD_OPESPE)
                                aAdd(__aTotSbF[Len(__aTotSbF)][6], (cArqTmpB)->AKD_PROJET)
                                aAdd(__aTotSbF[Len(__aTotSbF)][6], (cArqTmpB)->AKD_ATIVID)
                                aAdd(__aTotSbF[Len(__aTotSbF)][6], (cArqTmpB)->AKD_TOTAL)
                                
                                (cArqTmpB)->(dbSkip())
                            EndDo

                            //Totalizador para impressao da coluna Funcional - Quebra por funcao + subfuncao + programa
                            cQryAux := " SELECT AKD_ORGAO, AKD_ORCAM, AKD_EXEC, AKD_FUNCAO, AKD_SBFUNC, AKD_PROGRA, SUM(AKD_OPESPE) AKD_OPESPE,  "
                            cQryAux += " SUM(AKD_PROJET) AKD_PROJET,  SUM(AKD_ATIVID) AKD_ATIVID,  SUM(AKD_TOTAL) AKD_TOTAL FROM " + cNomReal
                            cQryAux += " GROUP BY AKD_ORGAO, AKD_ORCAM, AKD_EXEC, AKD_FUNCAO, AKD_SBFUNC, AKD_PROGRA "
                            cQryAux += " ORDER BY AKD_ORGAO, AKD_ORCAM, AKD_EXEC, AKD_FUNCAO, AKD_SBFUNC, AKD_PROGRA "
                            dbUseArea(.T., "TOPCONN", TcGenQry(,,cQryAux), cArqTmpD)

                            __aTotPrg := {}

                            //Percorre arquivo e armazena os totalizadores no array __aTotPrg
                            While (cArqTmpD)->( !Eof())
                                aAdd(__aTotPrg, {(cArqTmpD)->AKD_ORGAO, (cArqTmpD)->AKD_ORCAM, (cArqTmpD)->AKD_EXEC, (cArqTmpD)->AKD_FUNCAO, (cArqTmpD)->AKD_SBFUNC, (cArqTmpD)->AKD_PROGRA, {}})
                                aAdd(__aTotPrg[Len(__aTotPrg)][7], (cArqTmpD)->AKD_OPESPE)
                                aAdd(__aTotPrg[Len(__aTotPrg)][7], (cArqTmpD)->AKD_PROJET)
                                aAdd(__aTotPrg[Len(__aTotPrg)][7], (cArqTmpD)->AKD_ATIVID)
                                aAdd(__aTotPrg[Len(__aTotPrg)][7], (cArqTmpD)->AKD_TOTAL)
                                
                                (cArqTmpD)->(dbSkip())
                            EndDo

                            //Appenda os registros totalizadores na tabela temporaria (orgao + unidade + funcao)
                            dbSelectArea(cArqTmp)
                            
                            For nX := 1 To Len(__aTotFun)
                                RecLock(cArqTmp,.T.)
                                (cArqTmp)->AKD_ORGAO  := __aTotFun[nX, 1]
                                (cArqTmp)->AKD_ORCAM  := __aTotFun[nX, 2]
                                (cArqTmp)->AKD_EXEC   := __aTotFun[nX, 3]
                                (cArqTmp)->AKD_FUNCAO := __aTotFun[nX, 4]
                                (cArqTmp)->AKD_SBFUNC := " "
                                (cArqTmp)->AKD_PROGRA := " "       
                                (cArqTmp)->AKD_OPESPE := __aTotFun[nX, 5, 1]
                                (cArqTmp)->AKD_PROJET := __aTotFun[nX, 5, 2]
                                (cArqTmp)->AKD_ATIVID := __aTotFun[nX, 5, 3]
                                (cArqTmp)->AKD_TOTAL  := __aTotFun[nX, 5, 4]
                                MsUnlock()
                            Next nX

                            //Appenda os registros totalizadores na tabela temporaria (orgao+unidade+funcao+subfuncao)
                            dbSelectArea(cArqTmp)
                            
                            For nX := 1 To Len(__aTotSbF)
                                RecLock(cArqTmp,.T.)
                                (cArqTmp)->AKD_ORGAO  := __aTotSbF[nX, 1]
                                (cArqTmp)->AKD_ORCAM  := __aTotSbF[nX, 2]
                                (cArqTmp)->AKD_EXEC   := __aTotSbF[nX, 3]
                                (cArqTmp)->AKD_FUNCAO := __aTotSbF[nX, 4]
                                (cArqTmp)->AKD_SBFUNC := __aTotSbF[nX, 5]
                                (cArqTmp)->AKD_PROGRA := " "       
                                (cArqTmp)->AKD_OPESPE := __aTotSbF[nX, 6, 1]
                                (cArqTmp)->AKD_PROJET := __aTotSbF[nX, 6, 2]
                                (cArqTmp)->AKD_ATIVID := __aTotSbF[nX, 6, 3]
                                (cArqTmp)->AKD_TOTAL  := __aTotSbF[nX, 6, 4]
                                MsUnlock()
                            Next nX

                            //Appenda os registros totalizadores na tabela temporaria (orgao + unidade + funcao + subfuncao + programa)
                            dbSelectArea(cArqTmp)
                            
                            For nX := 1 To Len(__aTotPrg)
                                RecLock(cArqTmp,.T.)
                                (cArqTmp)->AKD_ORGAO  := __aTotPrg[nX, 1]
                                (cArqTmp)->AKD_ORCAM  := __aTotPrg[nX, 2]
                                (cArqTmp)->AKD_EXEC   := __aTotPrg[nX, 3]
                                (cArqTmp)->AKD_FUNCAO := __aTotPrg[nX, 4]
                                (cArqTmp)->AKD_SBFUNC := __aTotPrg[nX, 5]
                                (cArqTmp)->AKD_PROGRA := __aTotPrg[nX, 6]
                                (cArqTmp)->AKD_OPESPE := __aTotPrg[nX, 7, 1]
                                (cArqTmp)->AKD_PROJET := __aTotPrg[nX, 7, 2]
                                (cArqTmp)->AKD_ATIVID := __aTotPrg[nX, 7, 3]
                                (cArqTmp)->AKD_TOTAL  := __aTotPrg[nX, 7, 4]
                                MsUnlock()
                            Next nX

                            cQryAux := " SELECT * FROM " + cNomReal 
                            cQryAux += " ORDER BY AKD_ORGAO, AKD_ORCAM, AKD_EXEC, AKD_FUNCAO, AKD_SBFUNC, AKD_PROGRA, AKD_ACAO "

                            //Abre novamente a query para impressao
                            dbUseArea(.T., "TOPCONN", TcGenQry(,,cQryAux), cArqTmpC)
                            dbSelectArea(cArqTmpC)
                            oDespesa:Init()

                            //Todo o arquivo 
                            While (cArqTmpC)->(!Eof())
                                If oReport:Cancel()
                                    Exit
                                EndIf

                                cOrgao := (cArqTmpC)->AKD_ORGAO
                                cOrcamen := (cArqTmpC)->AKD_ORCAM
                                cExecutor := (cArqTmpC)->AKD_EXEC     

                                oReport:SkipLine()
                                lNewGrp := .T.
                                
                                oOrgao:Init()
                                oOrgao:PrintLine()

                                oOrcamen:Init()
                                oOrcamen:PrintLine()

                                oExecutor:Init()
                                oExecutor:PrintLine() 

                                __aTotGerUn := {0, 0, 0, 0} 

                                //Laço quebrando por Orgao, Unidade Orçamentária e Executora         
                                While (cArqTmpC)->( !Eof() .And.;
                                    AKD_ORGAO == cOrgao .And.;
                                    AKD_ORCAM == cOrcamen .And.;
                                    AKD_EXEC == cExecutor)

                                    If oReport:Cancel()
                                        Exit
                                    EndIf

                                    If !lNewGrp //Só pulo a linha se estou no mesmo grupo
                                        oReport:SkipLine()
                                    EndIf
                                    lNewGrp := .F.
                                    
                                    __nFunOpc := 1
                                    cFuncao := (cArqTmpC)->AKD_FUNCAO
                                    __aTotUnFun := {(cArqTmpC)->AKD_OPESPE, (cArqTmpC)->AKD_PROJET, (cArqTmpC)->AKD_ATIVID, (cArqTmpC)->AKD_TOTAL}

                                    oDespesa:Finish()
                                    oDespesa:Init()

                                    oDespesa:PrintLine() //Total por funcao
                                    (cArqTmpC)->(dbSkip())

                                    While (cArqTmpC)->( !Eof() .And.;
                                        AKD_ORGAO  == cOrgao .And.;
                                        AKD_ORCAM  == cOrcamen .And.;
                                        AKD_EXEC   == cExecutor .And.;
                                        AKD_FUNCAO == cFuncao)

                                        If oReport:Cancel()
                                            Exit
                                        EndIf

                                         __nFunOpc := 2
                                        cSubFuncao := (cArqTmpC)->AKD_SBFUNC
                                       
                                        oDespesa:PrintLine()   //Total por funcao+SubFuncao
                                        (cArqTmpC)->(dbSkip())

                                        While (cArqTmpC)->( !Eof() .And.;
                                            AKD_ORGAO  == cOrgao .And.;
                                            AKD_ORCAM  == cOrcamen .And.;
                                            AKD_EXEC   == cExecutor .And.;
                                            AKD_FUNCAO == cFuncao .And.;
                                            AKD_SBFUNC == cSubFuncao)

                                            If oReport:Cancel()
                                                Exit
                                            EndIf
                                            
                                            __nFunOpc := 3
                                            cPrograma := AKD_PROGRA
                                           
                                            oDespesa:PrintLine()  //Total por funcao+SubFuncao+programa
                                            (cArqTmpC)->(dbSkip())

                                            __nFunOpc := 4
                                            
                                            While (cArqTmpC)->( !Eof() .And.;
                                                AKD_ORGAO  == cOrgao .And.;
                                                AKD_ORCAM  == cOrcamen .And.;
                                                AKD_EXEC   == cExecutor .And.;
                                                AKD_FUNCAO == cFuncao .And.;
                                                AKD_SBFUNC == cSubFuncao .And.;
                                                AKD_PROGRA == cPrograma) 

                                                If oReport:Cancel()
                                                    Exit
                                                EndIf

                                                //Total do Orgao
                                                __aTotGerUn[OPESPE] += AKD_OPESPE
                                                __aTotGerUn[PROJET] += AKD_PROJET
                                                __aTotGerUn[ATIVID] += AKD_ATIVID
                                                __aTotGerUn[TOTAL]  += AKD_TOTAL

                                                //Total Geral
                                                __aTotGeral[OPESPE] += AKD_OPESPE
                                                __aTotGeral[PROJET] += AKD_PROJET
                                                __aTotGeral[ATIVID] += AKD_ATIVID
                                                __aTotGeral[TOTAL]  += AKD_TOTAL

                                                oDespesa:PrintLine()  //Total por funcao+SubFuncao+programa
                                                (cArqTmpC)->(dbSkip()) 
                                            EndDo
                                        EndDo                           
                                    EndDo
                                EndDo

                                //Total por Orgao
                                __nFunOpc := 5

                                oReport:SkipLine()
                                oDespesa:PrintLine()
                                
                                If (cArqTmpC)->(!Eof())
                                    oReport:EndPage() 
                                EndIf                             
                            EndDo

                            //Total Geral
                            If Len(__aTabFunc) > 0
                                __nFunOpc := 6
                                oReport:SkipLine()
                                oReport:ThinLine()
                                oReport:SkipLine()
                                oDespesa:PrintLine()
                            EndIf

                            //Final do relatorio
                            __nFunOpc := 7

                            oOrgao:Finish()
                            oOrcamen:Finish()
                            oExecutor:Finish()
                            oDespesa:Finish()    
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf  

    //Fecha arquivo temporario
    If Select("cArqTmpD") > 0
        (cArqTmpD)->(dbCloseArea()) 
    EndIf

    //Fecha arquivo temporario
    If Select("cArqTmpA") > 0
        (cArqTmpA)->(dbCloseArea()) 
    EndIf

    //Fecha arquivo temporario
    If Select("cArqTmpB") > 0
        (cArqTmpB)->(dbCloseArea()) 
    EndIf

    //Fecha arquivo temporario
    If Select("cArqTmpC") > 0
        (cArqTmpC)->(dbCloseArea()) 
    EndIf

    //Fecha arquivo temporario
    If Select("cArqTmp") > 0
        (cArqTmp)->(dbCloseArea()) 
    EndIf
EndIf

//Limpa arrays
aSize(__aTabFunc, 0)
aSize(__aTabSub, 0)
aSize(__aTotFun, 0)
aSize(__aTotSbF, 0)
aSize(__aTotPrg, 0)
aSize(__aTotUnFun, 0)
aSize(__aTotGerUn, 0)
aSize(__aTotGeral, 0)
    
__aTabFunc  := Nil
__aTabSub   := Nil
__aTotFun   := Nil
__aTotSbF   := Nil
__aTotPrg   := Nil
__aTotUnFun := Nil
__aTotGerUn := Nil
__aTotGeral := Nil

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} Cod_Orgao()
Codigo do Orgao

@author Totvs
   
@version P12
@since   20/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Cod_Orgao()
Return (ALIAS())->AKD_ORGAO

//-------------------------------------------------------------------
/*{Protheus.doc} Des_Orgao()
Descricao do Orgao

@author Totvs
   
@version P12
@since   20/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Des_Orgao()
Return Posicione("ALD", 1, xFilial("ALD") + (ALIAS())->AKD_ORGAO + "0000", "ALD_DESCRI")

//-------------------------------------------------------------------
/*{Protheus.doc} Cod_Unid()
Codigo da Unidade Orçamentária/Executora

@author Totvs
   
@version P12
@since   20/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Cod_Unid(nTipo)
Return IIF(nTipo == 1, (ALIAS())->AKD_ORCAM, (ALIAS())->AKD_EXEC)

//-------------------------------------------------------------------
/*{Protheus.doc} Des_Unid()
Descricao da Unidade Orçamentária/Executora

@author Totvs
   
@version P12
@since   20/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Des_Unid(nTipo)

Local cUnidade := ""

If nTipo == 1 //Unidade Orcamentaria
    cUnidade := (ALIAS())->AKD_ORGAO + (ALIAS())->AKD_ORCAM + "00"
Else //Unidade Executora
    cUnidade := (ALIAS())->AKD_ORGAO + (ALIAS())->AKD_ORCAM + (ALIAS())->AKD_EXEC
EndIf

Return Posicione("ALD", 1, xFilial("ALD") + cUnidade, "ALD_DESCRI")

//-------------------------------------------------------------------
/*{Protheus.doc} Funcional()
Localiza o Codigo da Funcional a ser impressa
1=Funcao
2=SubFuncao
3=Programa
4=Acao

@author Totvs
   
@version P12
@since   21/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Funcional()

Local cFuncional := ""

If __nFunOpc == 1
    cFuncional := (ALIAS())->(AKD_FUNCAO) 
ElseIf __nFunOpc == 2
    cFuncional := (ALIAS())->(AKD_FUNCAO + "." + AKD_SBFUNC)
ElseIf __nFunOpc == 3
    cFuncional := (ALIAS())->(AKD_FUNCAO + "." + AKD_SBFUNC + "." + AKD_PROGRA)
ElseIf __nFunOpc == 4
    cFuncional := (ALIAS())->(AKD_FUNCAO + "." + AKD_SBFUNC + "." + AKD_PROGRA + "." + AKD_ACAO)
EndIf

Return cFuncional

//-------------------------------------------------------------------
/*{Protheus.doc} DescFunc()
1=Funcao
2=SubFuncao
3=Programa
4=Acao
Localiza a Descricao da Funcional a ser impressa
@author Totvs
   
@version P12
@since   21/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function DescFunc()

Local cFunc   := (ALIAS())->AKD_FUNCAO  //tem que estar posicionado no alias da query no laco principal
Local cSunFun := (ALIAS())->AKD_SBFUNC
Local cProg   := (ALIAS())->AKD_PROGRA
Local cAcao   := (ALIAS())->AKD_ACAO
Local cDescri := Space(TAMDESCRI)
Local nPosEle := 0
Local nTamChv := Len(A1H->A1H_ITECHV)

//array static carregado na funcao ReportPrint onde cada array tem a tabela correspondente
// __aTabFunc := {} -> Tabela FC - Funcoes
// __aTabSub  := {} -> Tabela SB - Sub-Funcoes

If __nFunOpc == 1 .And. (nPosEle := aScan(__aTabFunc[ITETAB], {|x| x[ITECHV] == PadR(cFunc, nTamChv)})) > 0
    cDescri := PadR(__aTabFunc[ITETAB][nPosEle][ITEDES], TAMDESCRI)
ElseIf __nFunOpc == 2 .And. (nPosEle := aScan(__aTabSub[ITETAB], {|x| x[ITECHV] == PadR(cSunFun, nTamChv)})) > 0
    cDescri := PadR(__aTabSub[ITETAB][nPosEle][ITEDES], TAMDESCRI)
ElseIf __nFunOpc == 3
    cDescri := PadR(Posicione("AL0", 1, xFilial("AL0") + cProg, "AL0_DESCRI"), TAMDESCRI) 
ElseIf __nFunOpc == 4
    cDescri := PadR(Posicione("ALE", 1, xFilial("ALE") + cAcao, "ALE_DESACA"), TAMDESCRI) 
ElseIf __nFunOpc == 5
    cDescri := PadL(STR0023, TAMDESCRI-5, "-") //"Total  :  "
ElseIf __nFunOpc == 6
    cDescri := PadL(STR0024, TAMDESCRI-5, "-") //"Total Geral:  "
EndIf

Return cDescri

//-------------------------------------------------------------------
/*{Protheus.doc} ValFunc()
Coluna Valor das funcionais

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function ValFunc(nOpcFunc)

Local nValor := 0

Default nOpcFunc := 0

If nOpcFunc == 1 //Operacoes Especiais
    If __nFunOpc == 5
        nValor :=  __aTotGerUn[OPESPE]
    ElseIf __nFunOpc == 6
        nValor := __aTotGeral[OPESPE]
    Else
        nValor := (ALIAS())->AKD_OPESPE //Sempre deve estar posicionado na area da query do laco principal
    EndIf
ElseIf nOpcFunc == 2 //Projetos
    If __nFunOpc == 5
        nValor :=  __aTotGerUn[PROJET]
    ElseIf __nFunOpc == 6
        nValor := __aTotGeral[PROJET]
    Else
        nValor := (ALIAS())->AKD_PROJET //Sempre deve estar posicionado na area da query do laco principal
    EndIf
ElseIf nOpcFunc == 3 //Atividades
    If __nFunOpc == 5
        nValor :=  __aTotGerUn[ATIVID]
    ElseIf __nFunOpc == 6
        nValor := __aTotGeral[ATIVID]
    Else
        nValor := (ALIAS())->AKD_ATIVID //Sempre deve estar posicionado na area da query do laco principal
    EndIf
Else //Total
    If __nFunOpc == 5
        nValor := __aTotGerUn[TOTAL]
    ElseIf __nFunOpc == 6
        nValor := __aTotGeral[TOTAL]
    Else
        nValor := (ALIAS())->AKD_OPESPE + (ALIAS())->AKD_PROJET + (ALIAS())->AKD_ATIVID
    EndIf
EndIf

Return nValor  

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCabec
Cabecalho do relatorio - imprimir em todas as paginas

@author Totvs
   
@version P12
@since   19/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ImpCabec(oReport, oCabec, aMoedas)

Local cUnidMoed := ""

If MV_PAR07 == 2
    cUnidMoed := STR0025 //"Centena de "
ElseIf MV_PAR07 == 3
    cUnidMoed := STR0026 //"Milhares de "
ElseIf MV_PAR07 == 4
    cUnidMoed := STR0027 //"Milhoes de "
EndIf

//Imprime cabecalho
oCabec:Init()
oCabec:Cell("EXERCICIO"):SetBlock({|| STR0028 + SubStr(DToS(MV_PAR03), 1, 4) + " (" + STR0029 + AllTrim(cUnidMoed) + AllTrim(aMoedas[3]) + ")"})  //"Exercício: " #"Moeda: "
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