#Include "PCOR074.ch"
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

Static __nFunOpc := 1
Static __cCpoValor := "AKD_VALOR1"
Static __aTabFC    := {}
Static __aTabSB    := {}

Static __aTotFun   := {"","","", { 0, 0, 0, 0} }     //SubArray 1-Oper.Espec 2-Projeto 3-Atividades 4-Total
Static __aTotSbF   := {"","","","", { 0, 0, 0, 0} }  //SubArray 1-Oper.Espec 2-Projeto 3-Atividades 4-Total
Static __aTotPrg   := {"","","","","", { 0, 0, 0, 0} }  //SubArray 1-Oper.Espec 2-Projeto 3-Atividades 4-Total

Static __aTotUnFun := { 0, 0, 0, 0 } 
Static __aTotGerUn := { 0, 0, 0, 0 }                //1-Oper.Espec 2-Projeto 3-Atividades 4-Total

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR074
Relatorio Demonstrativo Programa de Trabalho de Governo – Por Unidade Orçamentária					

@author Totvs
   
@version P12
@since   18/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR074()

Local oReport
Local cPerg    := "PCOR074"
Local cFindSX1 := Padr("PCOR074", Len(SX1->X1_GRUPO), " ")

/*trecho somente para testes internos - nao retirar - as funcoes chamadas estao no final do fonte comentadas tb
MyAK5()
MyALE()
MyAL0()
*/

//=================================================================================================================================================
// mv_par01    Unidade Orçamentária de:           									
// mv_par02    Unidade Orçamentária Ate:       
// mv_par03    Periodo de:           									
// mv_par04    Periodo Ate:                							
// mv_par05    Aglutinador de Visoes:          						
// mv_par06    Moeda:    							                    
// mv_par07    Divide por:    						                    
//=================================================================================================================================================
SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.025"
    Help(,, "VER_RELEASE",, OemToAnsi(STR0001), 1, 0) //"Relatório Demonstrativo Programa de Trabalho de Governo – Por Unidade Orçamentária disponí­vel a partir da versao 12.1.31"
ElseIf !SX1->(dbSeek(cFindSX1))
    Help(,, "NO_PERG",, OemToAnsi(STR0002), 1, 0)       //"Para utilização do Relatorio Demonstrativo Programa de Trabalho de Governo – Por Unidade Orçamentária é necessário aplicar o pacote acumulado da controladoria."
Else                 
    oReport := ReportDef(cPerg)

    If ValType(oReport) == "O"    
        oReport:PrintDialog()
    EndIf

    oReport := Nil    
EndIf
	
//CLEAR VAR STATIC
__nFunOpc := 1

__aTabFC    := {}
__aTabSB    := {}
                                            //1-orgao 2-unid.orc. 3-funcao
__aTotFun   := {"","","", { 0, 0, 0, 0} }  //SubArray 1-Oper.Espec 2-Projeto 3-Atividades 4-Total
                                               //1-orgao 2-unid.orc. 3-funcao 4-SubFuncao
__aTotSbF   := {"","","","", { 0, 0, 0, 0} }  //SubArray 1-Oper.Espec 2-Projeto 3-Atividades 4-Total

                                                  //1-orgao 2-unid.orc. 3-funcao 4-SubFuncao 5-Programa
__aTotPrg   := {"","","","","", { 0, 0, 0, 0} }  //SubArray 1-Oper.Espec 2-Projeto 3-Atividades 4-Total

__aTotUnFun := { 0, 0, 0, 0 }              //1-Oper.Espec 2-Projeto 3-Atividades 4-Total
__aTotGerUn := { 0, 0, 0, 0 }              //1-Oper.Espec 2-Projeto 3-Atividades 4-Total

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   18/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oCabec, oOrgao, oUnidad, oDespesas, oBorder
Local cNomeProg := "PCOR074"
Local cTitulo   := Capital(STR0003)  //"Relatório Demonstrativo Programa de Trabalho de Governo – Por Unidade Orçamentária"
Local cDescri 	:= OemToAnsi(STR0004)  //"Este programa irá imprimir o Relatório Demonstrativo Programa de Trabalho de Governo – Por Unidade Orçamentária."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                                  {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:nFontBody := 7          //Define o tamanho da fonte

oBorder := TRBorder():New(oReport, 5,, 0)

//Criacao da Secao Cabecalho
oCabec := TRSection():New(oReport, STR0005, {}, /*aOrdem*/)  //"Exercício"
TRCell():New(oCabec, "EXERCICIO",, "",, 80, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder   //Remove a borda do cabecalho
oCabec:SetLinesBefore(0)

//Colunas referentes orgao e unidade orcamentarias
//1a. sintetica da ALD XX0000 ONDE XX é o codigo do orgao
oOrgao := TRSection():New(oReport, STR0006, {"cArqTmp"},, .F., .F.) //"Orgao"
TRCell():New(oOrgao, "ORGAO",,STR0007 /*Titulo*/, PesqPict("ALD", "ALD_CODIGO"), TamSx3("ALD_CODIGO")[1] /*Tamanho*/, /*lPixel*/, {||Cod_Orgao()}/*CodeBlock*/, "LEFT" , .T., "LEFT",,,.T.,,,.T.)  //"Orgão"
TRCell():New(oOrgao, "DESORG",,STR0008 /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), TamSx3("ALD_DESCRI")[1] /*Tamanho*/, /*lPixel*/, {||Des_Orgao()}/*CodeBlock*/, "LEFT" , .T., "LEFT",,,.T.,,,.T.)   //"Descrição"
oOrgao:SetLineStyle( .T. )
oOrgao:SetLinesBefore(0)

//Colunas referentes orgao e unidade orcamentarias
//2a. sintetica da ALD XXYY00 ONDE XX é o codigo do orgao e YY é o código da Unidade Orçamentária
oUnidad := TRSection():New(oReport, STR0009, {"cArqTmp"},, .F., .F.) //"Unidade"
TRCell():New(oUnidad, "UNIDAD",,STR0010 /*Titulo*/, PesqPict("ALD", "ALD_CODIGO"), TamSx3("ALD_CODIGO")[1] /*Tamanho*/, /*lPixel*/, {||Cod_Unid()}/*CodeBlock*/, "LEFT" , .T., "LEFT",,,.T.,,,.T.)  //"Un. Orçamentária"
TRCell():New(oUnidad, "DESUNI",,STR0008 /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), TamSx3("ALD_DESCRI")[1] /*Tamanho*/, /*lPixel*/, {||Des_Unid()}/*CodeBlock*/, "LEFT" , .T., "LEFT",,,.T.,,,.T.)   //"Descrição"
oUnidad:SetLineStyle( .T. )
oUnidad:SetLinesBefore(0)

//Criacao da Secao Despesas por Unidade Orçamentária
oDespesas := TRSection():New(oReport, STR0011, {"cArqTmp"},, .F., .F.) //"Despesas"
//Colunas referentes as Despesas por Unidade Orçamentária
TRCell():New(oDespesas, "FUNCIONAL" ,, STR0012 /*Titulo*/, "@!"                   ,  15           /*Tamanho*/, /*lPixel*/, {||Funcional()}  /*CodeBlock*/, "LEFT" , .T., "LEFT" ,,,.T.) //"Funcional"
TRCell():New(oDespesas, "DESCRICAO" ,, STR0008 /*Titulo*/, "@!"                   , TAMDESCRI    /*Tamanho*/, /*lPixel*/, {||DescFunc()}    /*CodeBlock*/, "LEFT" , .T., "LEFT" ,,,.T.) //"Descrição"
TRCell():New(oDespesas, "OPE_ESPEC" ,, STR0013 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValOpeEspec()}  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Op.Especial."
TRCell():New(oDespesas, "PROJETOS"  ,, STR0014 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValProjetos()} /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Projetos."
TRCell():New(oDespesas, "ATIVIDAD"  ,, STR0015 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValAtividade()} /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Atividades."
TRCell():New(oDespesas, "TOTAL"     ,, STR0016 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValTotal()} /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Total."
oDespesas:SetLinesBefore(0)

Return oReport


//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao  
utilizadas

@author Totvs
   
@version P12
@since   18/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport) 

Local oCabec     := oReport:Section(1)
Local oOrgao     := oReport:Section(2)
Local oUnidad    := oReport:Section(3)
Local oDespesa   := oReport:Section(4) 
Local cUnidIni   := MV_PAR01
Local cUnidFim   := MV_PAR02
Local dDataIni   := MV_PAR03
Local dDataFim   := MV_PAR04
Local cArqTmp    := GetNextAlias()
Local cCodAgl    := MV_PAR05
Local cMoeda     := MV_PAR06 

Local cTitulo    := STR0017 //"Demonstrativo Programa de Trabalho de Governo – Por Unidade Orçamentária"
Local aMoedas    := CtbMoeda(cMoeda) 

Local nDivide    := 1

Local aCpsAdic  := {}
Local cCondSQL  := ""
Local cNomReal  := ""
Local cQryUpdt  := ""
Local cQryAux   := ""
Local cArqTmpA  := cArqTmp+"_A"
Local cArqTmpB  := cArqTmp+"_B"
Local cArqTmpD  := cArqTmp+"_D"
Local cArqTmpC  := cArqTmp+"_C"
Local lNewGrp   := .F.
Local nX

//Tabela de Cadastro de Programas -> AL0
dbSelectArea("AL0")
DBSetOrder(1)
//Tabela de Cadastro de Ação -> ALE
dbSelectArea("ALE")
DBSetOrder(1)
//Tabela de Cadastro de Orgao -> ALD
dbSelectArea("ALD")
DBSetOrder(1)

__cCpoValor := "AKD_VALOR"+Alltrim(Str(Val(cMoeda)))

oReport:OnPageBreak( {|| ImpCabec( oReport, oCabec, aMoedas, MV_PAR07 /*divide por*/) } )

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

Neste Relatorio vamos utilizar 
Orgao -> Substr(AKD_CO, 1, 2)   
Unidade Orçamentária -> Substr(AKD_CO, 3, 2)
Funcao + SubFuncao + Programa + Ação -> Substr(AKD_CO, 7, 13)
Tabela FC-FC - Funcao
Tabela SB-SB - SubFuncao
Tabela de Cadastro de Programas -> AL0
Tabela de Cadastro de Ação -> ALE
Tabela de Cadastro de Orgao -> ALD
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
aAdd(aCpsAdic, {"AKD_ORGAO" ,"C",2,0})
aAdd(aCpsAdic, {"AKD_UNIDAD","C",2,0})
aAdd(aCpsAdic, {"AKD_FUNCAO","C",2,0})
aAdd(aCpsAdic, {"AKD_SBFUNC","C",3,0})
aAdd(aCpsAdic, {"AKD_PROGRA","C",4,0})
aAdd(aCpsAdic, {"AKD_ACAO"  ,"C",4,0})
aAdd(aCpsAdic, {"AKD_TPCAO" ,"C",1,0})
//VALORES SEPARADOS POR TIPO DE ACAO
aAdd(aCpsAdic, {"AKD_OPESPE" ,"N",18,2})
aAdd(aCpsAdic, {"AKD_PROJET" ,"N",18,2})
aAdd(aCpsAdic, {"AKD_ATIVID" ,"N",18,2})
aAdd(aCpsAdic, {"AKD_TOTAL" ,"N",18,2})

//Condicao a ser adicionada a clausula where da query
cCondSQL := " AND Substring(AKD_CO,1,4) >= '"+Substr(cUnidIni,1,4)+"' AND "
cCondSQL += "     Substring(AKD_CO,1,4) <= '"+Substr(cUnidFim,1,4)+"'     "

//Monta Arquivo Temporario para Impressao
MsgMeter({|oMeter, oText, oDlg, lEnd| ;
			cNomReal := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp,;
					  cMoeda, .T., cCodAgl, dDataIni, dDataFim,;
                      nil,nil,nDivide,aCpsAdic,cCondSQL)},;
			          STR0018, cTitulo) //"Criando Arquivo Temporario..."

If (cArqTmp)->(!Eof())

    __aTabFC := CargaTab( "FC"/*cTabela*/, "FC"/*cRadical*/)  //Funcao
    __aTabSB := CargaTab( "SB"/*cTabela*/, "SB"/*cRadical*/)  //SubFuncao

    cQryUpdt := " UPDATE "+cNomReal 
    cQryUpdt += " SET AKD_ORGAO   = Substring(AKD_CO,1,2), "
    cQryUpdt += "     AKD_UNIDAD  = Substring(AKD_CO,3,2), "
    cQryUpdt += "     AKD_FUNCAO  = Substring("+Alltrim(__aTabFC[CPOMOV])+", "+Alltrim(Str(__aTabFC[POSINI]))+", "+Alltrim(Str(__aTabFC[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_SBFUNC  = Substring("+Alltrim(__aTabSB[CPOMOV])+", "+Alltrim(Str(__aTabSB[POSINI]))+", "+Alltrim(Str(__aTabSB[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_PROGRA  = Substring( AKD_CO, 12, 4 ), "
    cQryUpdt += "     AKD_ACAO    = Substring( AKD_CO, 16, 4 ),  "
    cQryUpdt += "     AKD_OPESPE  = 0.00, "
    cQryUpdt += "     AKD_PROJET  = 0.00, "
    cQryUpdt += "     AKD_ATIVID  = 0.00, "
    cQryUpdt += "     AKD_TOTAL   = 0.00 "

    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf
    //ACAO TIPO OPERACAO ESPECIAL
    cQryUpdt := " UPDATE "+cNomReal 
    cQryUpdt += " SET AKD_OPESPE  = AKD_VALOR"+Alltrim(Str(Val(cMoeda)))
     cQryUpdt += " WHERE R_E_C_N_O_ IN ( "
    cQryUpdt += "                        SELECT ARQTMP.R_E_C_N_O_ FROM "+cNomReal+" ARQTMP, " + RetSqlName("ALE")+ " ALE "
    cQryUpdt += "                               WHERE ARQTMP.AKD_ACAO = ALE.ALE_CODACA AND ALE_TPACAO = '3' AND ALE.D_E_L_E_T_ = ' '  "
    cQryUpdt += "                       ) "
    
    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf
    
    //ACAO TIPO ATIVIDADE
    cQryUpdt := " UPDATE "+cNomReal 
    cQryUpdt += " SET AKD_ATIVID  = AKD_VALOR"+Alltrim(Str(Val(cMoeda)))
     cQryUpdt += " WHERE R_E_C_N_O_ IN ( "
    cQryUpdt += "                        SELECT ARQTMP.R_E_C_N_O_ FROM "+cNomReal+" ARQTMP, " + RetSqlName("ALE")+ " ALE "
    cQryUpdt += "                               WHERE ARQTMP.AKD_ACAO = ALE.ALE_CODACA AND ALE_TPACAO = '2' AND ALE.D_E_L_E_T_ = ' '  "
    cQryUpdt += "                       ) "
    
    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf
    
    //ACAO TIPO PROJETO
    cQryUpdt := " UPDATE "+cNomReal 
    cQryUpdt += " SET AKD_PROJET  = AKD_VALOR"+Alltrim(Str(Val(cMoeda)))
     cQryUpdt += " WHERE R_E_C_N_O_ IN ( "
    cQryUpdt += "                        SELECT ARQTMP.R_E_C_N_O_ FROM "+cNomReal+" ARQTMP, " + RetSqlName("ALE")+ " ALE "
    cQryUpdt += "                               WHERE ARQTMP.AKD_ACAO = ALE.ALE_CODACA AND ALE_TPACAO = '1' AND ALE.D_E_L_E_T_ = ' '  "
    cQryUpdt += "                       ) "
    
    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf
    
    //COLUNA TOTAL
    cQryUpdt := " UPDATE "+cNomReal 
    cQryUpdt += " SET AKD_TOTAL  = AKD_VALOR"+Alltrim(Str(Val(cMoeda)))
    
    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf
        
    //totalizador para impressao da coluna Funcional - Quebra por funcao
    cQryAux := " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_FUNCAO, SUM(AKD_OPESPE) AKD_OPESPE,  "
    cQryAux += " SUM(AKD_PROJET) AKD_PROJET,  SUM(AKD_ATIVID) AKD_ATIVID,  SUM(AKD_TOTAL) AKD_TOTAL FROM "+cNomReal 
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_FUNCAO "
    cQryAux += " ORDER BY AKD_ORGAO, AKD_UNIDAD, AKD_FUNCAO "
    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpA )

    __aTotFun := {}
    //Percorre arquivo e armazena os totalizadores no array __aTotFun
    While (cArqTmpA)->( !Eof() )
        aAdd( __aTotFun, { (cArqTmpA)->AKD_ORGAO, (cArqTmpA)->AKD_UNIDAD, (cArqTmpA)->AKD_FUNCAO, {} })
        aAdd( __aTotFun[Len(__aTotFun)][4], (cArqTmpA)->AKD_OPESPE )
        aAdd( __aTotFun[Len(__aTotFun)][4], (cArqTmpA)->AKD_PROJET )
        aAdd( __aTotFun[Len(__aTotFun)][4], (cArqTmpA)->AKD_ATIVID )
        aAdd( __aTotFun[Len(__aTotFun)][4], (cArqTmpA)->AKD_TOTAL )
        (cArqTmpA)->(dbSkip())
    EndDo


    //totalizador para impressao da coluna Funcional - Quebra por funcao+subfuncao
    cQryAux := " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_FUNCAO, AKD_SBFUNC, SUM(AKD_OPESPE) AKD_OPESPE,  "
    cQryAux += " SUM(AKD_PROJET) AKD_PROJET,  SUM(AKD_ATIVID) AKD_ATIVID,  SUM(AKD_TOTAL) AKD_TOTAL FROM "+cNomReal
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_FUNCAO, AKD_SBFUNC "
    cQryAux += " ORDER BY AKD_ORGAO, AKD_UNIDAD, AKD_FUNCAO, AKD_SBFUNC "
    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpB )

    __aTotSbF := {}
    //Percorre arquivo e armazena os totalizadores no array __aTotSbF
    While (cArqTmpB)->( !Eof() )
        aAdd(__aTotSbF, { (cArqTmpB)->AKD_ORGAO, (cArqTmpB)->AKD_UNIDAD, (cArqTmpB)->AKD_FUNCAO, (cArqTmpB)->AKD_SBFUNC, {} })
        aAdd( __aTotSbF[Len(__aTotSbF)][5], (cArqTmpB)->AKD_OPESPE )
        aAdd( __aTotSbF[Len(__aTotSbF)][5], (cArqTmpB)->AKD_PROJET )
        aAdd( __aTotSbF[Len(__aTotSbF)][5], (cArqTmpB)->AKD_ATIVID )
        aAdd( __aTotSbF[Len(__aTotSbF)][5], (cArqTmpB)->AKD_TOTAL )
        (cArqTmpB)->(dbSkip())
    EndDo

    //totalizador para impressao da coluna Funcional - Quebra por funcao+subfuncao+Programa
    cQryAux := " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_FUNCAO, AKD_SBFUNC, AKD_PROGRA, SUM(AKD_OPESPE) AKD_OPESPE,  "
    cQryAux += " SUM(AKD_PROJET) AKD_PROJET,  SUM(AKD_ATIVID) AKD_ATIVID,  SUM(AKD_TOTAL) AKD_TOTAL FROM "+cNomReal
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_FUNCAO, AKD_SBFUNC, AKD_PROGRA "
    cQryAux += " ORDER BY AKD_ORGAO, AKD_UNIDAD, AKD_FUNCAO, AKD_SBFUNC, AKD_PROGRA "
    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpD )

    __aTotPrg := {}
    //Percorre arquivo e armazena os totalizadores no array __aTotPrg
    While (cArqTmpD)->( !Eof() )
        aAdd(__aTotPrg, { (cArqTmpD)->AKD_ORGAO, (cArqTmpD)->AKD_UNIDAD, (cArqTmpD)->AKD_FUNCAO, (cArqTmpD)->AKD_SBFUNC, (cArqTmpD)->AKD_PROGRA, {} })
        aAdd( __aTotPrg[Len(__aTotPrg)][6], (cArqTmpD)->AKD_OPESPE )
        aAdd( __aTotPrg[Len(__aTotPrg)][6], (cArqTmpD)->AKD_PROJET )
        aAdd( __aTotPrg[Len(__aTotPrg)][6], (cArqTmpD)->AKD_ATIVID )
        aAdd( __aTotPrg[Len(__aTotPrg)][6], (cArqTmpD)->AKD_TOTAL )
        (cArqTmpD)->(dbSkip())
    EndDo


    //appenda os registros totalizadores na tabela temporaria (orgao+unidade+funcao)
    dbSelectArea( cArqTmp )
    For nX := 1 TO Len( __aTotFun )
        RecLock(cArqTmp,.T.)
        (cArqTmp)->AKD_ORGAO  := __aTotFun[nX,1]
        (cArqTmp)->AKD_UNIDAD := __aTotFun[nX,2]
        (cArqTmp)->AKD_FUNCAO := __aTotFun[nX,3]
        (cArqTmp)->AKD_SBFUNC := " "
        (cArqTmp)->AKD_PROGRA := " "       
        (cArqTmp)->AKD_OPESPE := __aTotFun[nX,4,1]
        (cArqTmp)->AKD_PROJET := __aTotFun[nX,4,2]
        (cArqTmp)->AKD_ATIVID := __aTotFun[nX,4,3]
        (cArqTmp)->AKD_TOTAL  := __aTotFun[nX,4,4]
        MsUnlock()
    Next

    //appenda os registros totalizadores na tabela temporaria (orgao+unidade+funcao+subfuncao)
    dbSelectArea( cArqTmp )
    For nX := 1 TO Len( __aTotSbF )
        RecLock(cArqTmp,.T.)
        (cArqTmp)->AKD_ORGAO  := __aTotSbF[nX,1]
        (cArqTmp)->AKD_UNIDAD := __aTotSbF[nX,2]
        (cArqTmp)->AKD_FUNCAO := __aTotSbF[nX,3]
        (cArqTmp)->AKD_SBFUNC := __aTotSbF[nX,4]
        (cArqTmp)->AKD_PROGRA := " "       
        (cArqTmp)->AKD_OPESPE := __aTotSbF[nX,5,1]
        (cArqTmp)->AKD_PROJET := __aTotSbF[nX,5,2]
        (cArqTmp)->AKD_ATIVID := __aTotSbF[nX,5,3]
        (cArqTmp)->AKD_TOTAL  := __aTotSbF[nX,5,4]
        MsUnlock()
    Next

    //appenda os registros totalizadores na tabela temporaria (orgao+unidade+funcao+SubFuncao+Programa)
    dbSelectArea( cArqTmp )
    For nX := 1 TO Len( __aTotPrg )
        RecLock(cArqTmp,.T.)
        (cArqTmp)->AKD_ORGAO  := __aTotPrg[nX,1]
        (cArqTmp)->AKD_UNIDAD := __aTotPrg[nX,2]
        (cArqTmp)->AKD_FUNCAO := __aTotPrg[nX,3]
        (cArqTmp)->AKD_SBFUNC := __aTotPrg[nX,4]
        (cArqTmp)->AKD_PROGRA := __aTotPrg[nX,5]
        (cArqTmp)->AKD_OPESPE := __aTotPrg[nX,6,1]
        (cArqTmp)->AKD_PROJET := __aTotPrg[nX,6,2]
        (cArqTmp)->AKD_ATIVID := __aTotPrg[nX,6,3]
        (cArqTmp)->AKD_TOTAL  := __aTotPrg[nX,6,4]
        MsUnlock()
    Next


    cQryAux := " SELECT * FROM "+cNomReal
    cQryAux += " ORDER BY AKD_ORGAO, AKD_UNIDAD, AKD_FUNCAO, AKD_SBFUNC, AKD_PROGRA, AKD_ACAO"

    //abre novamente a query para impressao
    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpC )
    dbSelectArea(cArqTmpC)
    oDespesa:Init()

    //Todo o arquivo 
    While (cArqTmpC)->(!Eof())

        If oReport:Cancel()
            Exit
        EndIf

        cOrgao := (cArqTmpC)->AKD_ORGAO        

        oReport:SkipLine()
        lNewGrp := .T.
        
        oOrgao:Init()
        oOrgao:PrintLine()

        //Laço quebrando por orgao
        While (cArqTmpC)->( !Eof() .And. AKD_ORGAO == cOrgao )            
            
            cUnidade := (cArqTmpC)->AKD_UNIDAD
            __aTotGerUn := { 0, 0, 0, 0 } 
                     
            If !lNewGrp // Só pulo a linha se estou no mesmo grupo
                oReport:SkipLine()
            EndIf
            lNewGrp := .F.

            oUnidad:Init()
            oUnidad:PrintLine()
           
            oDespesa:Finish()
            oDespesa:Init()
            
            //Laço quebrando por Unidade Orçamentária            
            While (cArqTmpC)->( !Eof() .And.;
                AKD_ORGAO == cOrgao .And.;
                AKD_UNIDAD == cUnidade )

                __nFunOpc := 1
                cFuncao := (cArqTmpC)->AKD_FUNCAO
                __aTotUnFun := { (cArqTmpC)->AKD_OPESPE, (cArqTmpC)->AKD_PROJET, (cArqTmpC)->AKD_ATIVID, (cArqTmpC)->AKD_TOTAL }
                
                oDespesa:PrintLine()   //Total por funcao
                (cArqTmpC)->( dbSkip() )
                
                //Laço quebrando por orgao+unidade orcamentaria+funcao
                While (cArqTmpC)->( !Eof() .And.; 
                    AKD_ORGAO == cOrgao .And.;
                    AKD_UNIDAD == cUnidade .And.;
                    AKD_FUNCAO == cFuncao)

                    cSubFuncao := (cArqTmpC)->AKD_SBFUNC
                    __nFunOpc := 2
             
                    oDespesa:PrintLine()   //Total por funcao+SubFuncao
                    (cArqTmpC)->( dbSkip() )

                    //Laço quebrando por orgao+Categoria+grupo despesa
                    While (cArqTmpC)->( !Eof() .And.;
                        AKD_ORGAO == cOrgao .And.;
                        AKD_UNIDAD == cUnidade  .And.;
                        AKD_FUNCAO == cFuncao .And.;
                        AKD_SBFUNC == cSubFuncao )

                        cPrograma := (cArqTmpC)->AKD_PROGRA
                        __nFunOpc := 3

                        oDespesa:PrintLine()  //Total por funcao+SubFuncao+programa
                         (cArqTmpC)->( dbSkip() )

                        __nFunOpc := 4

                        //Laço quebrando por orgao+unidade+funcao+sbuncao+programa para gerar total por funcao
                        While (cArqTmpC)->( !Eof() .And.;
                            AKD_ORGAO == cOrgao .And.;
                            AKD_UNIDAD == cUnidade  .And.;
                            AKD_FUNCAO == cFuncao .And.;
                            AKD_SBFUNC == cSubFuncao .And.;
                            AKD_PROGRA == cPrograma )
                            
                            __aTotGerUn[OPESPE] += AKD_OPESPE
                            __aTotGerUn[PROJET] += AKD_PROJET
                            __aTotGerUn[ATIVID] += AKD_ATIVID
                            __aTotGerUn[TOTAL ] += AKD_TOTAL
                            (cArqTmpC)->(dbSkip())

                        EndDo

                    EndDo
                EndDo
                 oDespesa:PrintLine()
                oReport:SkipLine()
                
            EndDo
        
            //Total Geral por Unidade Orçamentária
            __nFunOpc := 5
            oReport:SkipLine()
            oDespesa:PrintLine()
            oReport:EndPage()

        EndDo

        //Total por Orgao
        __nFunOpc := 6

        oOrgao:Finish()

    EndDo

    //Final do relatorio
    __nFunOpc := 7

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

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} Cod_Orgao()
Codigo do Orgao

@author Totvs
   
@version P12
@since   18/08/2020
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
@since   18/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function Des_Orgao()
Local cDescOrgao := ""
Local cOrgao := (ALIAS())->AKD_ORGAO  //alias tem q estar posicionado na query
ALD->( dbSeek( xFilial("ALD")+cOrgao+"0000"))
cDescOrgao := ALD->ALD_DESCRI
Return cDescOrgao
//-------------------------------------------------------------------
/*{Protheus.doc} Cod_Unid()
Codigo da Unidade Orçamentária

@author Totvs
   
@version P12
@since   18/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function Cod_Unid()
Return (ALIAS())->AKD_UNIDAD
//-------------------------------------------------------------------
/*{Protheus.doc} Des_Unid()
Descricao da Unidade Orçamentária

@author Totvs
   
@version P12
@since   18/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function Des_Unid()
Local cDescUnid := ""
Local cUnidade  := (ALIAS())->(AKD_ORGAO+AKD_UNIDAD)  //alias tem q estar posicionado na query
ALD->( dbSeek( xFilial("ALD")+cUnidade+"00"))
cDescUnid := ALD->ALD_DESCRI
Return cDescUnid
//-------------------------------------------------------------------
/*{Protheus.doc} FUNCIONAL()
1=Retorna a Funcao
2=Retorna funcao + SubFuncao
3=Retorna funcao + SubFuncao + Programa


@author Totvs
   
@version P12
@since   18/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function Funcional()
Local cFuncao := ""
If     __nFunOpc == 1
    cFuncao := (ALIAS())->( AKD_FUNCAO ) 
ElseIf __nFunOpc == 2
    cFuncao := (ALIAS())->( AKD_FUNCAO+"."+AKD_SBFUNC )
ElseIf __nFunOpc == 3
    cFuncao := (ALIAS())->( AKD_FUNCAO+"."+AKD_SBFUNC+"."+AKD_PROGRA )
EndIf
Return cFuncao

//-------------------------------------------------------------------
/*{Protheus.doc} DescFunc()
1=Retorna a descricao Funcao
2=Retorna a descricao  funcao + SubFuncao
3=Retorna a descricao  funcao + SubFuncao + Programa
@author Totvs
   
@version P12
@since   18/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function DescFunc()
Local cFuncao := (ALIAS())->AKD_FUNCAO  //tem que estar posicionado no alias da query no laco principal
Local cSbFunc := (ALIAS())->AKD_SBFUNC
Local cProgra := (ALIAS())->AKD_PROGRA

Local nPosEle := 0
Local cDescri := Space(TAMDESCRI)
Local nTamChv := Len(A1H->A1H_ITECHV)

//array static carregado na funcao ReportPrint onde cada array tem a tabela correspondente
// __aTabFC    := {} -> Tabela FC - Funcao
// __aTabSB    := {} -> Tabela SB - SubFuncao


If     __nFunOpc == 1

    If (nPosEle := aScan(__aTabFC[ITETAB], {|x| x[ITECHV]==PadR(cFuncao, nTamChv)}) )>0
        cDescri := PadR( __aTabFC[ITETAB][nPosEle][ITEDES],TAMDESCRI)
    EndIf
    
ElseIf __nFunOpc == 2

    If (nPosEle := aScan(__aTabSB[ITETAB], {|x| x[ITECHV]==PadR(cSbFunc, nTamChv)}) )>0
        cDescri := PadR( __aTabSB[ITETAB][nPosEle][ITEDES],TAMDESCRI)
    EndIf
    
ElseIf __nFunOpc == 3

    If AL0->( dbSeek(xFilial("AL0")+cProgra) )
        cDescri := PadR( AL0->AL0_DESCRI,TAMDESCRI)
    EndIf

ElseIf __nFunOpc == 4

    cDescri := PadL( STR0016,TAMDESCRI-5,"-")+":" //Total  :  "
    
ElseIf __nFunOpc == 5

    cDescri := PadL( STR0019,TAMDESCRI-5,"-")+":" //"Total Geral:  "

ElseIf __nFunOpc == 6



ElseIf __nFunOpc == 7


EndIf

Return cDescri


//-------------------------------------------------------------------
/*{Protheus.doc} ValOpeEspec()
Coluna Valor Oper.Especiais.

@author Totvs
   
@version P12
@since   18/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function ValOpeEspec()
Local nValor := 0  

If __nFunOpc == 4
    
    nValor := __aTotUnFun[ OPESPE ]

ElseIf __nFunOpc == 5

    nValor :=  __aTotGerUn[ OPESPE ]

Else

    nValor := (ALIAS())->AKD_OPESPE  //sempre deve estar posicionado na area da query do laco principal

EndIf

Return nValor  


//-------------------------------------------------------------------
/*{Protheus.doc} ValProjetos()
Coluna Valor de Projetos

@author Totvs
   
@version P12
@since   18/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function ValProjetos()
Local nValor := 0  

If __nFunOpc == 4
    
    nValor := __aTotUnFun[ PROJET ]

ElseIf __nFunOpc == 5

    nValor :=  __aTotGerUn[ PROJET ]

Else

    nValor := (ALIAS())->AKD_PROJET  //sempre deve estar posicionado na area da query do laco principal

EndIf

Return nValor

//-------------------------------------------------------------------
/*{Protheus.doc} ValAtividade()
Coluna Valor de Atividades

@author Totvs
   
@version P12
@since   18/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function ValAtividade()
Local nValor := 0  

If __nFunOpc == 4
    
    nValor := __aTotUnFun[ ATIVID ]

ElseIf __nFunOpc == 5

    nValor :=  __aTotGerUn[ ATIVID ]

Else

    nValor := (ALIAS())->AKD_ATIVID  //sempre deve estar posicionado na area da query do laco principal

EndIf

Return nValor
//-------------------------------------------------------------------
/*{Protheus.doc} ValTotal()
Coluna Valor Total = Somatoria (Oper.Espec.+Projetos+Atividades)

@author Totvs
   
@version P12
@since   18/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function ValTotal()
Local nValor := 0  

If __nFunOpc == 4
    
    nValor := __aTotUnFun[ TOTAL ]

ElseIf __nFunOpc == 5

    nValor :=  __aTotGerUn[ TOTAL ]

Else

    nValor := (ALIAS())->AKD_TOTAL  //sempre deve estar posicionado na area da query do laco principal

EndIf


Return nValor

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCabec
Cabecalho do relatorio - imprimir em todas as paginas

@author Totvs
   
@version P12
@since   18/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function ImpCabec( oReport, oCabec, aMoedas, nDivPor )
Local cUnidMoed := ""

If     nDivPor == 2
    cUnidMoed := STR0020 //"Centena de "
ElseIf nDivPor == 3
    cUnidMoed := STR0021 //"Milhares de "
ElseIf nDivPor == 4
    cUnidMoed := STR0022 //"Milhoes de "
EndIf

//Imprime cabecalho
oCabec:Init()
oCabec:Cell("EXERCICIO"):SetBlock({|| STR0024+ SubStr(DToS(MV_PAR03), 1, 4) + "            ("+STR0023+AllTrim(cUnidMoed)+": " + AllTrim(aMoedas[3]) +  ")"})  //"em " //"Exercício: "
oCabec:PrintLine()
oCabec:Finish()

//Pula linha
oReport:SkipLine()

Return

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
@since   18/08/2020
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

/*
Static Function MyAK5()
Local arrayAK5 := {}
Local nX
aAdd(arrayAK5,{"0101010103102010003","PROCESSO LEGISLATIVO"})
aAdd(arrayAK5,{"0101010103202020003","ADMINISTRAÇÃO LEGISLATIVA"})
aAdd(arrayAK5,{"0101010103202020002","ADMINISTRAÇÃO LEGISLATIVA"})
aAdd(arrayAK5,{"0101010103202030003","AÇÕES DE COMUNICAÇÃO SOCIAL DA CÂMARA"})
aAdd(arrayAK5,{"0101010412200020003","COORDENAÇAO SUPERIOR"})
aAdd(arrayAK5,{"0101010412200110003","CONTROLE ADMINISTRATIVO"})
aAdd(arrayAK5,{"0101010412390000001","PROGRAMA DE OPERAÇÕES ESPECIAIS"})
aAdd(arrayAK5,{"0101010412700080003","GUARDA CIVIL MUNICIPAL"})
aAdd(arrayAK5,{"0101010413100720003","AÇÕES COMUNICAÇÃO SOCIAL DA PREFEITURA"})
aAdd(arrayAK5,{"0101010427290000001","PROGRAMA DE OPERAÇÕES ESPECIAIS"})
aAdd(arrayAK5,{"0101010812200330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0101010824200580003","CONVÊNIO COM A APAE"})
aAdd(arrayAK5,{"0101010824300070003","ASSISTÊNCIA AO MENOR"})
aAdd(arrayAK5,{"0101010824300280003","MERENDA ESCOLAR"})
aAdd(arrayAK5,{"0101010824300330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0101010824300710003","PROTEÇÃO DA INFÂNCIA E JUVENTUDE"})
aAdd(arrayAK5,{"0101010824400120003","FUNDO SOCIAL DE SOLIDARIEDADE"})
aAdd(arrayAK5,{"0101010824400330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0201010103102010003","PROCESSO LEGISLATIVO"})
aAdd(arrayAK5,{"0201010103202020003","ADMINISTRAÇÃO LEGISLATIVA"})
aAdd(arrayAK5,{"0201010103202020002","ADMINISTRAÇÃO LEGISLATIVA"})
aAdd(arrayAK5,{"0201010103202030003","AÇÕES DE COMUNICAÇÃO SOCIAL DA CÂMARA"})
aAdd(arrayAK5,{"0201010412200020003","COORDENAÇAO SUPERIOR"})
aAdd(arrayAK5,{"0201010412200110003","CONTROLE ADMINISTRATIVO"})
aAdd(arrayAK5,{"0201010412390000001","PROGRAMA DE OPERAÇÕES ESPECIAIS"})
aAdd(arrayAK5,{"0201010412700080003","GUARDA CIVIL MUNICIPAL"})
aAdd(arrayAK5,{"0201010413100720003","AÇÕES COMUNICAÇÃO SOCIAL DA PREFEITURA"})
aAdd(arrayAK5,{"0201010427290000001","PROGRAMA DE OPERAÇÕES ESPECIAIS"})
aAdd(arrayAK5,{"0201010812200330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0201010824200580003","CONVÊNIO COM A APAE"})
aAdd(arrayAK5,{"0201010824300070003","ASSISTÊNCIA AO MENOR"})
aAdd(arrayAK5,{"0201010824300280003","MERENDA ESCOLAR"})
aAdd(arrayAK5,{"0201010824300330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0201010824300710003","PROTEÇÃO DA INFÂNCIA E JUVENTUDE"})
aAdd(arrayAK5,{"0201010824400120003","FUNDO SOCIAL DE SOLIDARIEDADE"})
aAdd(arrayAK5,{"0201010824400330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0301010103102010003","PROCESSO LEGISLATIVO"})
aAdd(arrayAK5,{"0301010103202020003","ADMINISTRAÇÃO LEGISLATIVA"})
aAdd(arrayAK5,{"0301010103202020002","ADMINISTRAÇÃO LEGISLATIVA"})
aAdd(arrayAK5,{"0301010103202030003","AÇÕES DE COMUNICAÇÃO SOCIAL DA CÂMARA"})
aAdd(arrayAK5,{"0301010412200020003","COORDENAÇAO SUPERIOR"})
aAdd(arrayAK5,{"0301010412200110003","CONTROLE ADMINISTRATIVO"})
aAdd(arrayAK5,{"0301010412390000001","PROGRAMA DE OPERAÇÕES ESPECIAIS"})
aAdd(arrayAK5,{"0301010412700080003","GUARDA CIVIL MUNICIPAL"})
aAdd(arrayAK5,{"0301010413100720003","AÇÕES COMUNICAÇÃO SOCIAL DA PREFEITURA"})
aAdd(arrayAK5,{"0301010427290000001","PROGRAMA DE OPERAÇÕES ESPECIAIS"})
aAdd(arrayAK5,{"0301010812200330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0301010824200580003","CONVÊNIO COM A APAE"})
aAdd(arrayAK5,{"0301010824300070003","ASSISTÊNCIA AO MENOR"})
aAdd(arrayAK5,{"0301010824300280003","MERENDA ESCOLAR"})
aAdd(arrayAK5,{"0301010824300330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0301010824300710003","PROTEÇÃO DA INFÂNCIA E JUVENTUDE"})
aAdd(arrayAK5,{"0301010824400120003","FUNDO SOCIAL DE SOLIDARIEDADE"})
aAdd(arrayAK5,{"0301010824400330003","ASSISTÊNCIA SOCIAL GERAL"})


dbSelectArea('AK5')
dbSetOrder(1)

For nX := 1 TO Len(arrayAK5)

    If !dbSeek(XFILIAL("AK5")+arrayAK5[nX,1])

        AK5->(Reclock("AK5",.T.))
        AK5->AK5_FILIAL := XFILIAL("AK5")
        AK5->AK5_CODIGO := arrayAK5[nX,1]
        AK5_DESCRI :=arrayAK5[nX,2]
        AK5->AK5_TIPO   := "2"
        AK5->AK5_DEBCRE := "2"
        AK5->AK5_DTINC := CTOD("01/01/20")
        AK5->AK5_DTINI := CTOD("01/01/80")
        AK5->AK5_COSUP := Left(arrayAK5[nX,1],6)
        AK5->AK5_MSBLQL := "2"
        AK5->(MsUnLock())

    EndIf

Next

Return


Static Function MyALE()
Local arrayALE := {}
Local nX

DBSelectArea("ALE")
DBSetOrder(1)

aAdd(arrayALE,{"0001","OPERACAO ESPECIAL ","3"})
aAdd(arrayALE,{"0002","PROJETO","1"})
aAdd(arrayALE,{"0003","ATIVIDADE","2"})

For nX := 1 TO Len(arrayALE)

    If !dbSeek(XFILIAL("ALE")+arrayALE[nX,1])

        ALE->(Reclock("ALE",.T.))
        ALE->ALE_FILIAL := XFILIAL("ALE")
        ALE->ALE_CODACA := arrayALE[nX,1]
        ALE->ALE_DESACA :=arrayALE[nX,2]
        ALE->ALE_TPACAO := arrayALE[nX,3]
        ALE->ALE_TPRECT := "1"
        ALE->ALE_TPRCRS := "1"
        ALE->(MsUnLock())

    EndIf

Next

Return

Static Function MyAL0()
Local arrayAL0 := {}
Local nX

DBSelectArea("AL0")
DBSetOrder(1)

aAdd(arrayAL0,{"0201","PROCESSO LEGISLATIVO"})
aAdd(arrayAL0,{"0202","ADMINISTRAÇÃO LEGISLATIVA"})
aAdd(arrayAL0,{"0202","ADMINISTRAÇÃO LEGISLATIVA"})
aAdd(arrayAL0,{"0203","AÇÕES DE COMUNICAÇÃO SOCIAL DA CÂMARA"})
aAdd(arrayAL0,{"0002","COORDENAÇAO SUPERIOR"})
aAdd(arrayAL0,{"0011","CONTROLE ADMINISTRATIVO"})
aAdd(arrayAL0,{"9000","PROGRAMA DE OPERAÇÕES ESPECIAIS"})
aAdd(arrayAL0,{"0008","GUARDA CIVIL MUNICIPAL"})
aAdd(arrayAL0,{"0072","AÇÕES COMUNICAÇÃO SOCIAL DA PREFEITURA"})
aAdd(arrayAL0,{"9000","PROGRAMA DE OPERAÇÕES ESPECIAIS"})
aAdd(arrayAL0,{"0033","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAL0,{"0058","CONVÊNIO COM A APAE"})
aAdd(arrayAL0,{"0007","ASSISTÊNCIA AO MENOR"})
aAdd(arrayAL0,{"0028","MERENDA ESCOLAR"})
aAdd(arrayAL0,{"0033","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAL0,{"0071","PROTEÇÃO DA INFÂNCIA E JUVENTUDE"})
aAdd(arrayAL0,{"0012","FUNDO SOCIAL DE SOLIDARIEDADE"})
aAdd(arrayAL0,{"0033","ASSISTÊNCIA SOCIAL GERAL"})

For nX := 1 TO Len(arrayAL0)

    If !dbSeek(XFILIAL("AL0")+arrayAL0[nX,1])

        AL0->(Reclock("AL0",.T.))
        AL0->AL0_FILIAL := XFILIAL("AL0")
        AL0->AL0_CODIGO := arrayAL0[nX,1]
        AL0->AL0_DESCRI :=arrayAL0[nX,2]
        AL0->AL0_TIPO := "1"
        AL0->AL0_STATUS := "1"
        AL0->(MsUnLock())

    EndIf

Next

Return

*/