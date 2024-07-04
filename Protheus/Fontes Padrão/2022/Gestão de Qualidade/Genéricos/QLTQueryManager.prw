#INCLUDE "TOTVS.CH"
#include 'Fileio.CH'
#INCLUDE "QLTQueryManager.CH"

#DEFINE _CRLF CHR(13)+CHR(10)
/*/{Protheus.doc} QLTQCmpFil

Retorna Query de Comparação das Filiais para Utilização em Query SQL

*** CUIDADO - UTILIZE APENAS EM CONDIÇÃO ESPECÍFICA ONDE EXISTEM RELACIONAMENTOS LEGADO QUE IMPEDEM A UTILIZAÇÃO DE OUTRA FORMA - CUIDADO ***
*** CUIDADO -                                                         E                                                         - CUIDADO ***
*** CUIDADO - EM LOCAL ONDE JÁ POSSUA O MENOR NÚMERO DE REGISTROS POSSÍVEIS POR FILTRAGEM PARA REDUZIR O IMPACTO DE PERFORMANCE - CUIDADO ***

*** A MÁ UTILIZAÇÃO DESTE MÉTODO EM QUERY'S NÃO OTIMIZADAS OU EM TABELAS COM MUITOS REGISTROS PODERÃO OCASIONAR LENTIDÃO
*** A MÁ UTILIZAÇÃO DESTE MÉTODO EM QUERY'S NÃO OTIMIZADAS OU EM TABELAS COM MUITOS REGISTROS PODERÃO OCASIONAR LENTIDÃO
*** A MÁ UTILIZAÇÃO DESTE MÉTODO EM QUERY'S NÃO OTIMIZADAS OU EM TABELAS COM MUITOS REGISTROS PODERÃO OCASIONAR LENTIDÃO

EXEMPLO:
    cQuery += " SELECT ALIAS_A.*, ALIAS_B.* "
    cQuery += " FROM  "
    cQuery +=      "(SELECT CAMPO_A, CAMPO_B "
    cQuery +=     " FROM TABELA_A "
    cQuery +=     " WHERE   D_E_L_E_T_ = ' ' "
    cQuery +=         " AND CONDICAO1 "
    cQuery +=         " AND CONDICAO2 "
    cQuery +=         " AND TABELA_A_FILIAL = '" + xFilial("TABELA_A") + "') AS ALIAS_A, "
    cQuery +=      "(SELECT CAMPO_C, CAMPO_D "
    cQuery +=     " FROM TABELA_B "
    cQuery +=     " WHERE   D_E_L_E_T_=' ' "
    cQuery +=         " AND CONDICAO3 "
    cQuery +=         " AND CONDICAO4) AS ALIAS_B "
    cQuery += " WHERE " + QLTQCmpFil("TABELA_A", "TABELA_B", "ALIAS_A", "ALIAS_B")

@type  Function
@author brunno.costa
@since 15/09/2021
@version P12.1.33

@param 01 - cAliasA  , caracter, primeiro Alias para formação da comparação do campo de FILIAL 
@param 02 - cAliasB  , caracter, segundo  Alias para formação da comparação do campo de FILIAL 
@param 03 - cPrefAliA, caracter, primeiro prefixo de alias para análise do campo filial, por exemplo 'SB1' para considera SB1.B1_FILIAL
@param 04 - cPrefAliB, caracter, SEGUNDO  prefixo de alias para análise do campo filial, por exemplo 'SB1' para considera SB1.B1_FILIAL
@param 05 - cBanco, caracter, retorna o banco para consideração na utilização do processo
@return cWhere, caracter, string contendo a compararação para filtro das filiais
/*/
Function QLTQCmpFil(cAliasA, cAliasB, cPrefAliA, cPrefAliB, cBanco)
    Local oManager := QLTQueryManager():New(cBanco)
Return oManager:MontaQueryComparacaoFiliais(cAliasA, cAliasB, cPrefAliA, cPrefAliB)

/*/{Protheus.doc} QLTQCmpFiE

Retorna Query de Comparação das Filiais para Utilização em Query SQL

*** CUIDADO - UTILIZE APENAS EM CONDIÇÃO ESPECÍFICA ONDE EXISTEM RELACIONAMENTOS LEGADO QUE IMPEDEM A UTILIZAÇÃO DE OUTRA FORMA - CUIDADO ***
*** CUIDADO -                                                         E                                                         - CUIDADO ***
*** CUIDADO - EM LOCAL ONDE JÁ POSSUA O MENOR NÚMERO DE REGISTROS POSSÍVEIS POR FILTRAGEM PARA REDUZIR O IMPACTO DE PERFORMANCE - CUIDADO ***

*** A MÁ UTILIZAÇÃO DESTE MÉTODO EM QUERY'S NÃO OTIMIZADAS OU EM TABELAS COM MUITOS REGISTROS PODERÃO OCASIONAR LENTIDÃO
*** A MÁ UTILIZAÇÃO DESTE MÉTODO EM QUERY'S NÃO OTIMIZADAS OU EM TABELAS COM MUITOS REGISTROS PODERÃO OCASIONAR LENTIDÃO
*** A MÁ UTILIZAÇÃO DESTE MÉTODO EM QUERY'S NÃO OTIMIZADAS OU EM TABELAS COM MUITOS REGISTROS PODERÃO OCASIONAR LENTIDÃO

*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***
*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***
*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***

EXEMPLO:
    cQuery += " SELECT ALIAS_A.*, ALIAS_B.* "
    cQuery += " FROM  "
    cQuery +=      "(SELECT CAMPO_A, CAMPO_B "
    cQuery +=     " FROM TABELA_A "
    cQuery +=     " WHERE   D_E_L_E_T_ = ' ' "
    cQuery +=         " AND CONDICAO1 "
    cQuery +=         " AND CONDICAO2 "
    cQuery +=         " AND TABELA_A_FILIAL = '" + xFilial("TABELA_A") + "') AS ALIAS_A, "
    cQuery +=      "(SELECT CAMPO_C, CAMPO_D "
    cQuery +=     " FROM TABELA_B "
    cQuery +=     " WHERE   D_E_L_E_T_=' ' "
    cQuery +=         " AND CONDICAO3 "
    cQuery +=         " AND CONDICAO4) AS ALIAS_B "
    cQuery += " WHERE " + QLTQCmpFiE("TABELA_A", "TABELA_B", "ALIAS_A.CAMPO_A", "ALIAS_B.CAMPO_C")

@type  Function
@author brunno.costa
@since 15/09/2021
@version P12.1.33

@param 01 - cAliasA, caracter, primeiro Alias para formação da comparação do campo de FILIAL 
@param 02 - cCampoA, caracter, primeiro campo para comparação (já com prefixo de alias)
@param 03 - cAliasB, caracter, segundo  Alias para formação da comparação do campo de FILIAL 
@param 04 - cCampoB, caracter, segundo  campo para comparação (já com prefixo de alias)
@param 05 - cBanco, caracter, retorna o banco para consideração na utilização do processo
@return cWhere, caracter, string contendo a compararação para filtro das filiais
/*/
Function QLTQCmpFiE(cAliasA, cCampoA, cAliasB, cCampoB, cBanco)
    Local oManager := QLTQueryManager():New(cBanco)
Return oManager:MontaQueryComparacaoFiliaisComCamposEspecificos(cAliasA, cCampoA, cAliasB, cCampoB)

Main Function QLTQueryMa()
Return MIL

/*/{Protheus.doc} QLTQueryManager
@type  Classe
@author brunno.costa
@since 22/02/2022
@version P12.1.37
/*/
CLASS QLTQueryManager FROM LongNameClass

    DATA aMsgErro as Array
    DATA cBanco   as String
    
    METHOD AutoCobertura()
    METHOD ChangeQuery(cWhere)
    METHOD ConfirmaNecessidadeDeExecucaoMensalViaSemaforo(cVersao, cModulo)
    METHOD MontaQueryComparacaoFiliais(cAliasA, cAliasB, cPrefAliA, cPrefAliB)
    METHOD MontaQueryComparacaoFiliaisComCamposEspecificos(cAliasA, cCampoA, cAliasB, cCampoB)
    METHOD MontaQueryComparacaoFiliaisComValorReferencia(cAliasA, cCampoA, cAliasB, cFilialB)
    METHOD new(cBanco) Constructor
    METHOD RetornaCampoFilial(cAlias)
    METHOD RetornaTamanhosLayout(nTamEmp, nTamUnid, nTamFil)
    METHOD ValidaCompartilhamentoEspecifico(cTabela, cModoEmp, cModoUnid, cModoFil, lExibeHelp)
    METHOD ValidaDadosDaFilial(cAliasRef, cAliasCpo, cCampo, lExibeHelp, aRecnos)
    METHOD ValidaMesmosCompartilhamentos(aTabelas, cModelo, lExibeHelp)

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@since 22/02/2022
@version P12.1.37
@param 01 - cBanco, caracter, retorna o banco para consideração na utilização do processo
@return Self, objeto, instancia da Classe QLTQueryManager
/*/
METHOD new(cBanco) CLASS QLTQueryManager
   Default cBanco := TCGetDB()
   Self:cBanco   := cBanco
   Self:aMsgErro := {}
Return Self

/*/{Protheus.doc} AutoCobertura
Função de Auto Cobertura da Classe - Necessário fazer alterações no modo de compartilhamento das tabelas para os desvios padrões
@since 22/02/2022
@version P12.1.37

Dicas:
- Corrompa a filial de um registro no campo QDH_FILIAL com base no padrão de compartilhamento da QDH;
- Corrompa a filial de um registro no campo QDH_FILMAT com base no padrão de compartilhamento da QAA;
- Deixe o modo de compartilhamento da QD0 diferente da QDH;
- Deixe o modo de compartilhamento da QAB diferente de EEE;
/*/
METHOD AutoCobertura() CLASS QLTQueryManager

    Local oCobertura := QLTQueryManager():New()
    Local oMSSQL     := QLTQueryManager():New("MSSQL")
    Local oOracle    := QLTQueryManager():New("ORACLE")
    Local oPostgres  := QLTQueryManager():New("POSTGRES")

    oMSSQL:ChangeQuery("")
	oOracle:ChangeQuery("")
	oPostgres:ChangeQuery("")

	oCobertura:ValidaMesmosCompartilhamentos({'QDH','QD0','QD1','QD2','QD4','QD5','QD6','QD7','QD8','QD9','QDA','QDB','QDD','QDE','QDF','QDG','QDJ','QDL','QDM','QDN','QDP','QDR','QDS','QDU','QDZ','QAG','QAH','QAI'}, "QDH", .T.)
    oCobertura:MontaQueryComparacaoFiliaisComCamposEspecificos("QAA", "QAA_FILIAL", "QAA", "QDH_FILMAT")
    oCobertura:ValidaDadosDaFilial("QAA", "QDH", "QDH_FILMAT", .T.)
    oCobertura:ValidaDadosDaFilial("QAA")
    oCobertura:ValidaDadosDaFilial("SB1")
    QLTQCmpFil("QAA", "QDH", "", "", "MSSQL")
    QLTQCmpFiE("QAA", "QAA_FILIAL", "QAA", "QDH_FILMAT", "MSSQL")
	
    //Msg de Help
    oCobertura:ValidaMesmosCompartilhamentos({'QDH','QAA','QAB'}, "QDH", .T.)
    oCobertura:ValidaCompartilhamentoEspecifico("QAB", "C", "C", "C", .T.)
    oCobertura:ValidaDadosDaFilial("SA1", "SA1", "A1_NOME", .T.)

    oCobertura:ConfirmaNecessidadeDeExecucaoMensalViaSemaforo("001", "teste")
    oCobertura:ConfirmaNecessidadeDeExecucaoMensalViaSemaforo("001", "teste")
    oCobertura:ConfirmaNecessidadeDeExecucaoMensalViaSemaforo("001", "teste", oCobertura:aMsgErro)

Return

/*/{Protheus.doc} MontaQueryComparacaoFiliais
Retorna Query de Comparação das Filiais para Utilização em Query SQL
@since 22/02/2022
@version P12.1.37
@param 01 - cAliasA  , caracter, primeiro Alias para formação da comparação do campo de FILIAL 
@param 02 - cAliasB  , caracter, segundo  Alias para formação da comparação do campo de FILIAL 
@param 03 - cPrefAliA, caracter, primeiro prefixo de alias para análise do campo filial, por exemplo 'SB1' para considera SB1.B1_FILIAL
@param 04 - cPrefAliB, caracter, SEGUNDO  prefixo de alias para análise do campo filial, por exemplo 'SB1' para considera SB1.B1_FILIAL
@return cWhere, caracter, string contendo a compararação para filtro das filiais
/*/
METHOD MontaQueryComparacaoFiliais(cAliasA, cAliasB, cPrefAliA, cPrefAliB) CLASS QLTQueryManager

    Local cCompEmpA := ""
    Local cCompEmpB := ""
    Local cCompFilA := ""
    Local cCompFilB := ""
    Local cCompUniA := ""
    Local cCompUniB := ""
    Local cCpoFilA  := ""
    Local cCpoFilB  := ""
    Local cModFullC := ""
    Local cModoA    := ""
    Local cModoB    := ""
    Local cWhere    := ""
    Local nLeft     := 0
    Local nTamEmp   := 0
    Local nTamFil   := 0
    Local nTamUnid  := 0

    Default cPrefAliA := ""
    Default cPrefAliB := ""

    If !Empty(cAliasA) .AND. !Empty(cAliasB)
        cCompEmpA := AllTrim(FWModeAccess(cAliasA, 1))
        cCompEmpB := AllTrim(FWModeAccess(cAliasB, 1))
        cCompUniA := AllTrim(FWModeAccess(cAliasA, 2))
        cCompUniB := AllTrim(FWModeAccess(cAliasB, 2))
        cCompFilA := AllTrim(FWModeAccess(cAliasA, 3))
        cCompFilB := AllTrim(FWModeAccess(cAliasB, 3))

        cModoA := cCompEmpA + cCompUniA + cCompFilA
        cModoB := cCompEmpB + cCompUniB + cCompFilB

        If cModoA == "CCC" .OR. cModoB == "CCC"
            cWhere := " 1 = 1 " //Quando uma das tabelas está totalmente compartilhada, não há necessidade do RELATION

        ElseIf cModoA == cModoB
            cCpoFilA := Iif(!Empty(cPrefAliA), cPrefAliA + ".", "") + Self:RetornaCampoFilial(cAliasA)
            cCpoFilB := Iif(!Empty(cPrefAliB), cPrefAliB + ".", "") + Self:RetornaCampoFilial(cAliasB)

            cWhere := cCpoFilA + " = " + cCpoFilB

        Else
            
            Self:RetornaTamanhosLayout(@nTamEmp, @nTamUnid, @nTamFil)

            cModFullC := ""
            cModoA    := ""
            cModoB    := ""

            If nTamEmp  != 0 
                cModFullC += "C"
                cModoA    += cCompEmpA
                cModoB    += cCompEmpB
                If cCompEmpA == "E" .AND. cCompEmpB == "E"
                    nLeft += nTamEmp //Trunca comparação sempre pela menor exclusividade
                EndIf
            EndIf

            If nTamUnid != 0 
                cModFullC += "C"
                cModoA    += cCompUniA
                cModoB    += cCompUniB
                If cCompUniA == "E" .AND. cCompUniB == "E"
                    nLeft += nTamUnid //Trunca comparação sempre pela menor exclusividade
                EndIf
            EndIf
            
            If nTamFil  != 0 
                cModFullC += "C"
                cModoA    += cCompFilA
                cModoB    += cCompFilB
                If cCompFilA == "E" .AND. cCompFilB == "E"
                    nLeft += nTamFil //Trunca comparação sempre pela menor exclusividade
                EndIf
            EndIf

            If cModoA == cModFullC .OR. cModoB == cModFullC
                cWhere := " 1 = 1 " //Quando uma das tabelas está totalmente compartilhada, não há necessidade do RELATION

            Else
                cCpoFilA := Iif(!Empty(cPrefAliA), cPrefAliA + ".", "") + Self:RetornaCampoFilial(cAliasA)
                cCpoFilB := Iif(!Empty(cPrefAliB), cPrefAliB + ".", "") + Self:RetornaCampoFilial(cAliasB)

                cWhere   :=    "SUBSTRING("+ cCpoFilA + ", 1, " + cValToChar(nLeft) + " ) "
                cWhere   += " = SUBSTRING("+ cCpoFilB + ", 1, " + cValToChar(nLeft) + " ) "

            EndIf
        EndIf
    EndIf

    cWhere := Self:ChangeQuery(cWhere)

Return cWhere

/*/{Protheus.doc} RetornaCampoFilial
Retorna o Campo de Filial Padrão Correspondente ao Alias
@since 22/02/2022
@version P12.1.37
@param 01 - cAlias, caracter, alias para análise
@return cCpoFilial, caracter, nome do campo de filial padrão do registro no cAlias
/*/
METHOD RetornaCampoFilial(cAlias) CLASS QLTQueryManager
    Local cCpoFilial := ""
    If Left(cAlias, 1) == "S"
        cCpoFilial := Right(cAlias, 2) + "_FILIAL"
    Else
        cCpoFilial := cAlias + "_FILIAL"
    EndIf
Return cCpoFilial

/*/{Protheus.doc} RetornaTamanhosLayout
Retorna por Referência o Tamanho das Entidades do Layout da Filial
@since 22/02/2022
@version P12.1.37
@param 01 - nTamEmp , número, retorna por referência o tamanho da Empresa no Layout do Grupo de Empresas 
@param 02 - nTamUnid, número, retorna por referência o tamanho da Unidade de Negócios no Layout do Grupo de Empresas 
@param 03 - nTamFil , número, retorna por referência o tamanho da Filial no Layout do Grupo de Empresas
/*/
METHOD RetornaTamanhosLayout(nTamEmp, nTamUnid, nTamFil) CLASS QLTQueryManager
    Local cLayout := FWSM0Layout()
    Local nCont   := 0
    Local nTotal  := Len(cLayout)
	For nCont := 1 To nTotal
		If     SubStr(cLayout, nCont, 1) == "E"
			nTamEmp++
		ElseIf SubStr(cLayout, nCont, 1) == "U"
			nTamUnid++
		ElseIf SubStr(cLayout, nCont, 1) == "F"
			nTamFil++
		EndIf
	Next nCont
Return

/*/{Protheus.doc} ChangeQuery
Realiza Adequações na Query para Os Bancos Oracle e Postgres
@since 22/02/2022
@version P12.1.37
@param 01 - cWhere, caracter, string com a query SQL para ajuste
@return cWhere, caracter, string com a query SQL ajustada para o banco
/*/
METHOD ChangeQuery(cWhere) CLASS QLTQueryManager
    If Self:cBanco == "POSTGRES"
        cWhere := StrTran(cWhere, "+", "||")
    ElseIf Self:cBanco == "ORACLE"
        cWhere := StrTran(cWhere, "+", "||")
        cWhere := StrTran(cWhere, "SUBSTRING", "SUBSTR")
    ElseIf Self:cBanco == "MSSQL"
        cWhere := StrTran(cWhere, "LENGTH(", "LEN(")
    EndIf
Return cWhere

/*/{Protheus.doc} MontaQueryComparacaoFiliaisComCamposEspecificos
Retorna Query de Comparação das Filiais Com Campos Específicos para Utilização em Query SQL
@since 22/02/2022
@version P12.1.37
@param 01 - cAliasA, caracter, primeiro Alias para formação da comparação do campo de FILIAL 
@param 02 - cCampoA, caracter, primeiro campo para comparação (já com prefixo de alias)
@param 03 - cAliasB, caracter, segundo  Alias para formação da comparação do campo de FILIAL 
@param 04 - cCampoB, caracter, segundo  campo para comparação (já com prefixo de alias)
@return cQuery, caracter, string contendo a compararação para filtro das filiais

*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***
*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***
*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***

/*/
METHOD MontaQueryComparacaoFiliaisComCamposEspecificos(cAliasA, cCampoA, cAliasB, cCampoB) CLASS QLTQueryManager
    Local cCpoDefA := Self:RetornaCampoFilial(cAliasA)
    Local cCpoDefB := Self:RetornaCampoFilial(cAliasB)
    Local cQuery   := Self:MontaQueryComparacaoFiliais(cAliasA, cAliasB, "", "")

    cQuery := StrTran(cQuery, cCpoDefA, cCampoA)
    cQuery := StrTran(cQuery, cCpoDefB, cCampoB)
Return cQuery

/*/{Protheus.doc} MontaQueryComparacaoFiliaisComValorReferencia
Retorna Query de Comparação das Filiais Campo Específico x Valor para Utilização em Query SQL
@since 22/02/2022
@version P12.1.37
@param 01 - cAliasA , caracter, primeiro Alias para formação da comparação do campo de FILIAL 
@param 02 - cCampoA , caracter, primeiro campo para comparação (já com prefixo de alias)
@param 03 - cAliasB , caracter, segundo  Alias para formação da comparação do campo de FILIAL 
@param 04 - cFilialB, caracter, valor da filial no alias B para filtro
@return cQuery, caracter, string contendo a compararação para filtro das filiais

*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***
*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***
*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***

/*/
METHOD MontaQueryComparacaoFiliaisComValorReferencia(cAliasA, cCampoA, cAliasB, cFilialB) CLASS QLTQueryManager
    Local cCpoDefA := Self:RetornaCampoFilial(cAliasA)
    Local cCpoDefB := Self:RetornaCampoFilial(cAliasB)
    Local cQuery   := Self:MontaQueryComparacaoFiliais(cAliasA, cAliasB, "", "")
    Local nPosComp := 0
    Local cLeft    := ""
    Local cRight   := ""

    cQuery   := StrTran(cQuery, cCpoDefA, cCampoA)
    nPosComp := At("=", cQuery)
    cLeft    := Left(cQuery, nPosComp)
    cRight   := Substring(cQuery, nPosComp + 1, Len(cQuery))
    cRight   := StrTran(cRight, cCpoDefB, "'" + cFilialB + "'")
    cQuery   := cLeft + cRight

Return cQuery

/*/{Protheus.doc} ValidaDadosDaFilial
Valida Dados da Filial em Campos Específicos
@since 22/02/2022
@version P12.1.37
@param 01 - cAliasRef , caracter, alias referência para verificação do modo de compartilhamento da tabela
@param 02 - cAliasCpo , caracter, alias do campo que será validado - referência de chave estrangeira em outra tabela
@param 03 - cCampo    , caracter, nome do campo que contém a filial que será validado - referência de chave estrangeira em outra tabela
@param 04 - lExibeHelp, lógico  , indica se deve exibir o help de falha
@param 05 - aRecnos   , array   , retorna por referência a relação de arrays com problema
@return lReturn, lógico, indica que os dados da tabela estão íntegros
/*/
METHOD ValidaDadosDaFilial(cAliasRef, cAliasCpo, cCampo, lExibeHelp, aRecnos) CLASS QLTQueryManager

    Local cAliasQry  := GetNextAlias()
    Local cCompEmp   := AllTrim(FWModeAccess(cAliasRef, 1))
    Local cCompFil   := AllTrim(FWModeAccess(cAliasRef, 3))
    Local cCompUni   := AllTrim(FWModeAccess(cAliasRef, 2))
    Local cFilAux    := ""
    Local cFilDef    := ""
    Local cQuery     := ""
    Local cRECNOs    := ""
    Local nTamEmp    := 0
    Local nTamFil    := 0
    Local nTamFilial := 0
    Local nTamUnid   := 0

    Default aRecnos    := {}
    Default cAliasCpo  := cAliasRef
    Default cCampo     := Self:RetornaCampoFilial(cAliasRef)
    Default lExibeHelp := .T.

    cFilDef    := xFilial(cAliasCpo)

    DbSelectArea(cAliasRef)
    DBSelectArea(cAliasCpo)
    If Select(cAliasRef)>0
        (cAliasRef)->(DbCloseArea())
    EndIf
    If Select(cAliasCpo)>0
        (cAliasCpo)->(DbCloseArea())
    EndIf

    Self:RetornaTamanhosLayout(@nTamEmp, @nTamUnid, @nTamFil)

    If nTamEmp  != 0 .AND. cCompEmp == "E"
        nTamFilial += nTamEmp
    EndIf

    If nTamUnid != 0 .AND. cCompUni == "E"
        nTamFilial += nTamUnid
    EndIf
    
    If nTamFil  != 0 .AND. cCompFil == "E"
        nTamFilial += nTamFil
    EndIf

    cQuery += " SELECT " + cCampo + ", R_E_C_N_O_ "
    cQuery += " FROM " + RetSQLName(cAliasCpo)
    cQuery += " WHERE D_E_L_E_T_=' ' AND "

    If nTamFilial > 0
        cQuery += " LENGTH(RTRIM(" + cCampo + ")) <> " + cValToChar(nTamFilial)
    Else
        cQuery += cCampo + " <> ' ' "
    EndIf

    cQuery += " ORDER BY R_E_C_N_O_ "

    cQuery := Self:ChangeQuery(cQuery)

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    (cAliasQry)->(DBGotop())
	While (cAliasQry)->(!EOF())
        cFilAux := (cAliasQry)->&(cCampo)
        If     (Len(Rtrim(cFilAux)) > nTamFilial);
          .OR. (!Empty(AllTrim(cFilAux)) .AND. AllTrim(xFilial(cAliasRef, cFilAux)) != AllTrim(cFilAux));
          .OR. ( Empty(AllTrim(cFilAux)) .AND. AllTrim(cFilDef)                     != AllTrim(cFilAux))

            If Empty(cRECNOs)
                cRECNOs += cValToChar((cAliasQry)->(R_E_C_N_O_))
            Else
                cRECNOs += ", " + cValToChar((cAliasQry)->(R_E_C_N_O_))
            EndIf
            aAdd(aRecnos, (cAliasQry)->(R_E_C_N_O_))
        EndIf
         (cAliasQry)->(DbSkip())
    EndDo
    (cAliasQry)->(DbCloseArea())

    If lExibeHelp .AND. !Empty(cRECNOs)
        //#STR0001 - "Atenção"
        //#STR0002 - "O sistema identificou falhas nos dados de filial no campo"
        //#STR0003 - "que proporcionarão mal comportamento de algumas rotinas do módulo."
        //#STR0004 - "Entre em contato com o departamento de TI e solicite a compatibilização dos dados de RECNO a seguir conforme modo de compartilhamento da tabela"
        Help(NIL, NIL, STR0001, NIL, STR0002 + " '" + cCampo + "' " + STR0003, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0004 + " '" + cAliasRef + "': " + cRECNOs})
        aAdd(Self:aMsgErro, {STR0002 + " '" + cCampo + "' " + STR0003, STR0004 + " '" + cAliasRef + "': " + cRECNOs} )
    EndIf
    
Return Empty(cRECNOs)

/*/{Protheus.doc} ValidaMesmosCompartilhamentos
Valida se As Tabelas Possuem os Mesmos Compartilhamentos
@since 22/02/2022
@version P12.1.37
@param 01 - aTabelas  , array   , array com as tabelas que devem possuir os mesmos compartilhamentos
@param 02 - cModelo   , caracter, chave da tabela de modelo referência para os compartilhamentos
@param 03 - lExibeHelp, lógico  , indica se deve exibir o help de falha
@return lReturn, lógico, indica se todas as tabelas possuem os mesmos compartilhamentos
/*/
METHOD ValidaMesmosCompartilhamentos(aTabelas, cModelo, lExibeHelp) CLASS QLTQueryManager

    Local cModE    := ""
    Local cModF    := ""
    Local cModos   := ""
    Local cModU    := ""
    Local cTabE    := ""
    Local cTabelas := ""
    Local cTabF    := ""
    Local cTabU    := ""
    Local lReturn  := .T.
    Local lTabOk   := .T.
    Local nInd     := 0
    Local nTamEmp  := 0
    Local nTamFil  := 0
    Local nTamUnid := 0
	Local nTotal   := 0

    Default aTabelas   := {}
    Default lExibeHelp := .T.

    If aScan(aTabelas, {|x| x == cModelo}) <= 0
        aAdd(aTabelas, cModelo)
    EndIf

    Self:RetornaTamanhosLayout(@nTamEmp, @nTamUnid, @nTamFil)
    If nTamEmp  != 0
        cModE := AllTrim(FWModeAccess(cModelo, 1))    // Empresas
        cModos += "-> " + STR0007 + " (" + Iif(cModE == "C", STR0008, STR0009) + ")" + _CRLF //Empresa - "Compartilhado" - "Exclusivo"
    EndIf
    If nTamUnid != 0
        cModU := AllTrim(FWModeAccess(cModelo, 2))    // Unidades
        cModos += "-> " + STR0010 + " (" + Iif(cModU == "C", STR0008, STR0009) + ")" + _CRLF //Unidade de Negócio - "Compartilhado" - "Exclusivo"
    EndIf
    If nTamFil  != 0
        cModF := AllTrim(FWModeAccess(cModelo, 3))    // Filiais
        cModos += "-> " + STR0011 + " (" + Iif(cModF == "C", STR0008, STR0009) + ")" + _CRLF //Filial - "Compartilhado" - "Exclusivo"
    EndIf

    nTotal := Len(aTabelas)
    For nInd := 1 to nTotal
    
        If !Empty(aTabelas[nInd])
   
            lTabOk := .T.
            If nTamEmp != 0
                cTabE := AllTrim(FWModeAccess(aTabelas[nInd], 1))    // Empresas
                If cTabE <> cModE
                    lReturn := .F.
					lTabOk := .F.
                EndIf 
            EndIf 
            If nTamUnid != 0 .and. lTabOk
                cTabU := AllTrim(FWModeAccess(aTabelas[nInd], 2))    // Unidade
                If cTabU <> cModU
                    lReturn := .F.
					lTabOk := .F.
                EndIf 
            EndIf 
            If nTamFil != 0 .and. lTabOk
                cTabF := AllTrim(FWModeAccess(aTabelas[nInd], 3))    // Filial
                If cTabF <> cModF
                    lReturn := .F.
					lTabOk  := .F.
                EndIf 
            EndIf 
            If !lReturn                
                If!Empty(cTabelas)
                    cTabelas += ","
                EndIf
                cTabelas += "'" + aTabelas[nInd] + "' "
            EndIf 

        EndIf 
            
    Next 
    
    If !lReturn .and. lExibeHelp
        //STR0001 - "Atenção"
        //STR0005 - "O sistema identificou falha no compartilhamento das tabelas"
        //STR0006 - "Solicite apoio do departamento de TI e ajuste a configuração para que todas as tabelas possuam o mesmo modo de compartilhamento da tabela"
        cTabelas := StrTran(cTabelas, "'", "")
        Help(NIL, NIL, STR0001, NIL, STR0005 + ": " + cTabelas + ".", 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0006 + " '" + cModelo + "':" + _CRLF + cModos})
        aAdd(Self:aMsgErro, {STR0005 + ": " + cTabelas + ".", STR0006 + " '" + cModelo + "':" + _CRLF + cModos} )
    EndIf 

Return lReturn

/*/{Protheus.doc} ValidaCompartilhamentoEspecifico
Valida Se a Tabela Possui um Compartilhamento Específico
@since 22/02/2022
@version P12.1.37
@param 01 - cTabela   , caracter, chave da tabela para análise 
@param 02 - cModoEmp  , caracter, modo de compartilhamento por empresa desejado
@param 03 - cModoUnid , caracter, modo de compartilhamento por unidade desejado
@param 04 - cModoFil  , caracter, modo de compartilhamento por filial desejado
@param 05 - lExibeHelp, lógico  , indica se deve exibir o help de falha
@return lReturn, lógico, indica se a tabela está atendendo o modo de compartilhamento específico
/*/
METHOD ValidaCompartilhamentoEspecifico(cTabela, cModoEmp, cModoUnid, cModoFil, lExibeHelp) CLASS QLTQueryManager

    Local cCompEmp  := ""
    Local cCompFil  := ""
    Local cCompUni  := ""
    Local cModosNOK := ""
    Local cModosOK  := ""
    Local lReturn   := .T.
    Local nTamEmp   := 0
    Local nTamFil   := 0
    Local nTamUnid  := 0

    Default aTabelas   := {}
    Default lExibeHelp := .T.

    Self:RetornaTamanhosLayout(@nTamEmp, @nTamUnid, @nTamFil)

    If nTamEmp  != 0
        cCompEmp := AllTrim(FWModeAccess(cTabela, 1))
        If cModoEmp != cCompEmp
            lReturn := .F.
            cModosOk  += "-> " + STR0007 + " (" + Iif(cModoEmp == "C", STR0008, STR0009) + ")" + _CRLF //Empresa - Compartilhado - Exclusivo
            cModosNOK += "-> " + STR0007 + " (" + Iif(cCompEmp == "C", STR0008, STR0009) + ")" + _CRLF //Empresa - Compartilhado - Exclusivo
        EndIf
    EndIf

    If nTamUnid != 0
        cCompUni := AllTrim(FWModeAccess(cTabela, 2))
        If cModoUnid != cCompUni
            lReturn := .F.
            cModosOk  += "-> " + STR0010 + " (" + Iif(cModoUnid == "C", STR0008, STR0009) + ")" + _CRLF //Unidade de Negócio - Compartilhado - Exclusivo
            cModosNOK += "-> " + STR0010 + " (" + Iif(cCompUni  == "C", STR0008, STR0009) + ")" + _CRLF //Unidade de Negócio - Compartilhado - Exclusivo
        EndIf
    EndIf
    
    If nTamFil  != 0
        cCompFil := AllTrim(FWModeAccess(cTabela, 3))
        If cModoFil != cCompFil
            lReturn := .F.
            cModosOk  += "-> " + STR0011 + " (" + Iif(cModoFil == "C", STR0008, STR0009) + ")" + _CRLF //Filial - Compartilhado - Exclusivo
            cModosNOK += "-> " + STR0011 + " (" + Iif(cCompFil == "C", STR0008, STR0009) + ")" + _CRLF //Filial - Compartilhado - Exclusivo
        EndIf
    EndIf

    If lExibeHelp .AND. !lReturn
        //STR0001 - Atenção
        //STR0012 - "O sistema identificou falha no compartilhamento da tabela"
        //STR0013 - "Solicite apoio do departamento de TI e ajuste a configuração de compartilhamento da tabela"
        Help(NIL, NIL, STR0001, NIL, STR0012 + " '" + cTabela + "': " + _CRLF + cModosNOK, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0013 + ": " + _CRLF + cModosOk})
        aAdd(Self:aMsgErro, {STR0012 + " '" + cTabela + "': " + _CRLF + cModosNOK, STR0013 + ": " + _CRLF + cModosOk} )
    EndIf
    
Return lReturn

/*/{Protheus.doc} ConfirmaNecessidadeDeExecucaoMensalViaSemaforo
Confirma a Necessidade de Execução Mensal Via Semaforo
@since 22/02/2022
@version P12.1.37
@param 01 - cVersao , caracter, controla a versão de controle de execucao
@param 02 - cModulo , caracter, controla a chave de controle de execução por módulo
@param 03 - aMsgErro, array   , array com as mensagens de erro para arquivamento no log
@return lReturn, lógico, indica se deve executar
/*/
METHOD ConfirmaNecessidadeDeExecucaoMensalViaSemaforo(cVersao, cModulo, aMsgErro) CLASS QLTQueryManager
    Local bErrorBlock := Nil
	Local cFileName   := ""
    Local lExecutar   := .F.
	Local lReturn     := .F.
	Local nHandle     := Nil
    Local oMensagem   := JsonObject():New()

    Default aMsgErro := {}
    Default cModulo  := "QLT"
	Default cVersao  := '001'

	cFileName := Lower(GetPathSemaforo() + "Quality_" + FWGrpCompany() + "_" + AllTrim(cVersao) + "_" + AllTrim(cModulo))

	If LockByName(cFileName, .F., .F., .T.) //Conseguiu bloquear
		If File(cFileName + ".vldlog", 0 ,.T.)
            bErrorBlock := ErrorBlock({|| lExecutar := .T. })
            oMensagem:fromJson(MemoRead( cFileName + ".vldlog"))
            If oMensagem == Nil .OR. Len(aMsgErro) > 0 .OR. (oMensagem[ 'data' ] != Nil .AND. StoD(oMensagem[ 'data' ]) < MonthSub( Date() , 1 ))
                lExecutar := .T.
                fErase(cFileName + ".vldlog")
            EndIf
            ErrorBlock(bErrorBlock)
        Else
            lExecutar := .T.
		EndIf

        If lExecutar
            nHandle := fCreate(cFileName + ".vldlog", FC_NORMAL)

			If nHandle != -1
                oMensagem[ 'usuarioProtheus' ]           := RetCodUsr()
                oMensagem[ 'nomeUsuarioProtheus' ]       := UsrRetName(RetCodUsr())
                oMensagem[ 'usuarioSistemaOperacional' ] := LogUserName()
                oMensagem[ 'nomeComputador' ]            := GetComputerName()
                oMensagem[ 'rotinaProtheus' ]            := FunName()
                oMensagem[ 'ipServerProtheus' ]          := GetServerIP()
                oMensagem[ 'portaServerProtheus' ]       := GetPvProfString( "tcp", "port", "1234", "appserver.ini")
                oMensagem[ 'data' ]                      := DtoS(Date())
                oMensagem[ 'hora' ]                      := Time()
                oMensagem[ 'mensagemErro' ]              := aMsgErro

				fWrite(nHandle, oMensagem:toJson())
				If fError() == 0
                    lReturn := .T.
				EndIf
			EndIf
			fClose(nHandle)

			If !lReturn
				// - Help
				//STR0016 - Falha na criação do arquivo '\RootPath\Semaforo\
				//STR0017 - Contate o departamento de TI e verifique as configurações de acesso do AppServer ao diretório '\RootPath\SEMAFORO\.'
				Help( ,  , STR0001, ,  STR0016 + cFileName + ".vldlog': " + Str(fError()) + " (" + ProcName() + " - " + cValToChar(ProcLine()) + ")";
					, 1, 0, , , , , , {STR0017})
			EndIf
        EndIf
	EndIf

    If Len(aMsgErro) > 0
        lReturn := .F.
    EndIf

Return lReturn
