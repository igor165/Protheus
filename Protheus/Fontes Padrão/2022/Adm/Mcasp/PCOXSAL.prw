#INCLUDE "PROTHEUS.CH"
#Include "PCOXSAL.CH"

#DEFINE CO_DE       01
#DEFINE CO_ATE      02
#DEFINE CLORC_DE    03
#DEFINE CLORC_ATE   04
#DEFINE TIPO_SLD    05
#DEFINE CUSTO_DE    06
#DEFINE CUSTO_ATE   07
#DEFINE ITEM_DE     08
#DEFINE ITEM_ATE    09
#DEFINE CLVLR_DE    10
#DEFINE CLVLR_ATE   11

#DEFINE ENTAD_DE    01
#DEFINE ENTAD_ATE   02

STATIC _oTempTable
STATIC _nQtdEntida
STATIC _lUsaRegua
//---------------------------------------------------
/*/{Protheus.doc} PCOGerPlan
Monta arquivo temporário utilizando os filtros passados 
por parâmetro para utilização em relatórios gerenciais.

@author TOTVS

@param oMeter       Controle da regua
@param oText        Controle da regua
@param oDlg         Janela
@param lEnd         Controle da regua @param > finalizar
@param cArqTmp      Arquivo temporario
@param cMoeda       Moeda referencia para o relatóro
@param lPorVisao    Identifica se o relatório será por visão
@param cCodAgl      Código de aglutinação de Visão do PCO
@param dDataIni     Data Inicial de Processamento
@param dDataFim     Data Final de Processamento
@param aFiltros     Parâmetros para filtro (modo sem visão)
@param aFiltAd      Parâmetros para filtro entidades adicionais (modo sem visão)
@param nDivPor      Valor para divisão do campo AKD_VALOR1

// Fluxo de chamada das funções:
// 
//               | PCGerVis   | QryPorVis             | 
// PCOGerPlan -> |                                    |-> CriaObjTmp -> RetQryAKD -> PCInsertQry
//               | PCGerParam | QryPorPar | PCJoinEnt | 
//                                        | PCRetSele |
//                                        | PCRetJoin |
//                                        | PCRetWher |

@version P12
@since   31/03/2020
@return  cTblName  Nome da Tabela temporária com a estrutura AKD
/*/
//---------------------------------------------------
Function PCGerPlan(oMeter,oText,oDlg,lEnd,cArqtmp,cMoeda,lPorVisao,cCodAgl,dDataIni,dDataFim,aFiltros,aFiltAd,nDivPor,aCpsAdic,cCondSQL)
Local cTblName      := ""
Local cTextoAux     := ""
Local aCampos       := {}

Private nPCVlMeter  := 0

DEFAULT lEnd        := .F.
DEFAULT cArqtmp     := ""
DEFAULT cMoeda      := ""
DEFAULT lPorVisao   := .F.
DEFAULT cCodAgl     := ""
DEFAULT dDataIni    := StoD("")
DEFAULT dDataFim    := StoD("")
DEFAULT aFiltros    := {}
DEFAULT nDivPor     := 1

_lUsaRegua := ValType(oMeter) == "O"

If Type("_nQtdEntida") == "U"
    _nQtdEntida := CtbQtdEntd()
EndIf

If !Empty(dDataIni) .And. !Empty(dDataFim) .And. DateDiffYear(dDataIni,dDataFim) > 0
    
    aAdd(aCampos, {"AKD_FILIAL","C",TamSX3("AKD_FILIAL")[1],0})

    CriaObjTmp(cArqtmp,aCampos) //Somente para evitar error.log na rotina chamadora

    ConOut(STR0001) //"O período máximo permitido para consulta é de 1 ano"
    Return cTblName
EndIf

If _lUsaRegua    
    cTextoAux := oText:GetText()
    oMeter:SetTotal(500)
    oText:SetText(STR0002) //"Iniciando processamento...."
    PCAtuMeter(oMeter,@nPCVlMeter,100)
EndIf

If nDivPor < 1
    nDivPor := 1
EndIF

If lPorVisao
    cTblName := PCGerVis(oMeter,oText,oDlg,lEnd,cArqtmp,cMoeda,dDataIni,dDataFim,cCodAgl,nDivPor,aCpsAdic,cCondSQL)
Else
    cTblName := PCGerParam(oMeter,oText,oDlg,lEnd,cArqtmp,cMoeda,dDataIni,dDataFim,aFiltros,aFiltAd,nDivPor)    
EndIf

Return cTblName
//---------------------------------------------------
/*/{Protheus.doc} PCGerVis
Monta arquivo temporário utilizando a configuração de 
visão gerencial do PCO

@author TOTVS

@param oMeter       Controle da regua
@param oText        Controle da regua
@param oDlg         Janela
@param lEnd         Controle da regua @param > finalizar
@param cArqTmp      Arquivo temporario
@param cMoeda       Moeda referencia para o relatóro
@param dDataIni     Data Inicial de Processamento
@param dDataFim     Data Final de Processamento
@param cCodAgl      Código de aglutinação de Visão do PCO
@param nDivPor      Valor para divisão do campo AKD_VALOR1

@version P12
@since   31/03/2020
@return  cTblName   Nome da Tabela temporária com a estrutura AKD
/*/
//---------------------------------------------------
Function PCGerVis(oMeter,oText,oDlg,lEnd,cArqtmp,cMoeda,dDataIni,dDataFim,cCodAgl,nDivPor,aCpsAdic,cCondSQL)
Local aSaveArea     := GetArea()
Local aCtbMoeda     := {}
Local nDecimais     := 0
Local aCampos       := {}
Local cQueryAKD     := ""
Local cTblName      := ""
Local lRet          := .F.

DEFAULT lEnd        := .F.
DEFAULT cArqtmp     := GetNextAlias()
DEFAULT cMoeda      := ""
DEFAULT dDataIni    := StoD("")
DEFAULT dDataFim    := StoD("")
DEFAULT cCodAgl     := ""
DEFAULT nDivPor     := 1

aCtbMoeda := CTbMoeda(cMoeda)
nDecimais := aCtbMoeda[5]

lRet := QryPorVis(dDataIni,dDataFim,cArqTmp,cCodAgl,nDecimais,aCampos,@cQueryAKD,@cTblName,nDivPor,aCpsAdic,cCondSQL)

If lRet
    If _lUsaRegua   
        oText:SetText(STR0003) //"Inserindo dados na tabela temporária...."
        PCAtuMeter(oMeter,@nPCVlMeter,200)
    EndIf
   
    PCInsertQry(cTblName,cQueryAKD)

    If _lUsaRegua   
        oText:SetText(STR0004) //"Finalizando processo...."
        PCAtuMeter(oMeter,@nPCVlMeter,200)
    EndIf
EndIf

RestArea(aSaveArea)

If Select(cArqTmp) > 0
	(cArqTmp)->(dbGoTop())
EndIf

Return cTblName
//---------------------------------------------------
/*/{Protheus.doc} PCGerParam
Monta arquivo temporário utilizando os filtros passados 
por parâmetro para utilização em relatórios gerenciais.

@author TOTVS

@param oMeter       Controle da regua
@param oText        Controle da regua
@param oDlg         Janela
@param lEnd         Controle da regua @param > finalizar
@param cArqTmp      Arquivo temporario
@param cMoeda       Moeda referencia para o relatóro
@param dDataIni     Data Inicial de Processamento
@param dDataFim     Data Final de Processamento
@param aFiltros     Parâmetros para filtro (modo sem visão)
@param aFiltAd      Parâmetros para filtro entidades adicionais (modo sem visão)
@param nDivPor      Valor para divisão do campo AKD_VALOR1

@version P12
@since   31/03/2020
@return  cTblName   Nome da Tabela temporária com a estrutura AKD
/*/
//---------------------------------------------------
Function PCGerParam(oMeter,oText,oDlg,lEnd,cArqtmp,cMoeda,dDataIni,dDataFim,aFiltros,aFiltAd,nDivPor)
Local aSaveArea     := GetArea()
Local aCampos       := {}
Local cTblName      := ""

DEFAULT lEnd        := .F.
DEFAULT cArqtmp     := ""
DEFAULT cMoeda      := ""
DEFAULT dDataIni    := StoD("")
DEFAULT dDataFim    := StoD("")
DEFAULT aFiltros    := {}
DEFAULT aFiltAd     := {}
DEFAULT nDivPor     := 1

aCampos := PCRetCpos(cMoeda)

If _lUsaRegua   
    oText:SetText(STR0003) //"Inserindo dados na tabela temporária...."
    PCAtuMeter(oMeter,@nPCVlMeter,200)
EndIf

cQryAKD := QryPorPar(dDataIni,dDataFim,cArqTmp,aFiltros,aFiltAd,@cTblName,aCampos,nDivPor)

PCInsertQry(cTblName,cQryAKD)

If _lUsaRegua   
    oText:SetText(STR0004) //"Finalizando processo...."
    PCAtuMeter(oMeter,@nPCVlMeter,200)
EndIf

RestArea(aSaveArea)

If Select(cArqTmp) > 0
	(cArqTmp)->(dbGoTop())
EndIf

Return cTblName
//---------------------------------------------------
/*/{Protheus.doc} CriaObjTmp
Cria a tabela temporária para montagem da estrutura 
que será retornada para a função chamadora

@author TOTVS

@param cArqtmp      Alias aberto para montar a temprary table
@param aCampos      Estrutura de Campos 
@param aCpsAdic     Estrutura de Campos Adicionais para ArqTmp

@version P12
@since   31/03/2020
@return  cArqTmp
/*/
//---------------------------------------------------
Static Function CriaObjTmp(cArqtmp,aCampos)
Local cTblName  := ""

DEFAULT cArqtmp := ""
DEFAULT aCampos := {}

If Select(cArqTmp) > 0
	(cArqTmp)->(dbCloseArea())
Endif

If _oTempTable <> Nil .And. _oTempTable:GetAlias() == cArqtmp
	_oTempTable:Delete()
EndIf

_oTempTable := FWTemporaryTable():New(cArqtmp)
_oTempTable:SetFields( aCampos )
_oTempTable:Create()

cTblName := _oTempTable:GetRealName()

ConOut(cTblName)

Return cTblName
//---------------------------------------------------
/*/{Protheus.doc} PCRetCpos
Retorna os campos que serão utilizados para montar 
a estrutura da tabela.

@author TOTVS

@param cMoeda           Moeda referência par ao relatório

@version P12
@since   31/03/2020
@return aRet            Estrutura de campos para montar a tabela temporária
/*/
//---------------------------------------------------
Static Function PCRetCpos(cMoeda)
Local aRet          := {}
Local aCtbMoeda     := {}
Local nDecimais     := 0

DEFAULT cMoeda      := "01"

aCtbMoeda := CTbMoeda(cMoeda)
nDecimais := aCtbMoeda[5]

aRet := {   {"AKD_DATA"     , "D", 8                       , 0          },;
            {"AKD_CO"       , "C", TamSX3("AKD_CO")[1]     , 0          },;
            {"AK5_DESCRI"   , "C", TamSX3("AK5_DESCRI")[1] , 0          },;
            {"AKD_CLASSE"   , "C", TamSX3("AKD_CLASSE")[1] , 0          },;
            {"AK6_DESCRI"   , "C", TamSX3("AK6_DESCRI")[1] , 0          },;
            {"AKD_OPER"     , "C", TamSX3("AKD_OPER")[1]   , 0          },;
            {"AKF_DESCRI"   , "C", TamSX3("AKF_DESCRI")[1] , 0          },;
            {"AKD_TPSALD"   , "C", TamSX3("AKD_TPSALD")[1] , 0          },;
            {"AL2_DESCRI"   , "C", TamSX3("AL2_DESCRI")[1] , 0          },;
            {"AKD_UNIORC"   , "C", TamSX3("AKD_UNIORC")[1] , 0          },;
            {"AMF_DESCRI"   , "C", TamSX3("AMF_DESCRI")[1] , 0          },;
            {"AKD_CC"       , "C", TamSX3("AKD_CC")[1]     , 0          },;
            {"CTT_DESC01"   , "C", TamSX3("CTT_DESC01")[1] , 0          },;
            {"AKD_ITCTB"    , "C", TamSX3("AKD_ITCTB")[1]  , 0          },;
            {"CTD_DESC01"   , "C", TamSX3("CTD_DESC01")[1] , 0          },;
            {"AKD_CLVLR"    , "C", TamSX3("AKD_CLVLR")[1]  , 0          },;
            {"CTH_DESC01"   , "C", TamSX3("CTH_DESC01")[1] , 0          },;
            {"AKD_HIST"     , "C", TamSX3("AKD_HIST")[1]   , 0          },;
            {"AKD_PROCES"   , "C", TamSX3("AKD_PROCES")[1] , 0          },;
            {"AKD_TIPO"     , "C", TamSX3("AKD_TIPO")[1]   , 0          },;
            {"AKD_VALOR1"   , "N", TamSX3("AKD_VALOR1")[1] , nDecimais  };
        }

If _nQtdEntida > 4
    PCRetEntid(aRet)
EndIf

Return aRet
//---------------------------------------------------
/*/{Protheus.doc} QryPorPar
Monta a query com os parâmetros passados pela função chamadora

@author TOTVS

@param dDataIni     Data inicial para filtro na AKD
@param dDataFim     Data final para filtro na AKD
@param cArqTmp      Alias para montar a tabela temporária
@param aFiltros     Array com os filtros para a query
@param aFiltAd      Array com os filtros de entidade adicional
@param cTblName     Nome da tabela temporária para popular
@param aCampos      Estrutura de campos da tabela temporária
@param nDivPor      Valor para divisão do campo AKD_VALOR1

@version P12
@since   31/03/2020
@return  Nil
/*/
//---------------------------------------------------
Static Function QryPorPar(dDataIni,dDataFim,cArqTmp,aFiltros,aFiltAd,cTblName,aCampos,nDivPor)
Local cQryAKD   := ""
Local cSelect   := ""
Local cLeftJoin := ""
Local cWhere    := ""

DEFAULT dDataIni := StoD("")
DEFAULT dDataFim := StoD("")
DEFAULT aFiltros := {}
DEFAULT aFiltAd  := {}
DEFAULT cTblName := ""
DEFAULT aCampos  := {}
DEFAULT nDivPor  := 1

If _nQtdEntida > 4
    cLeftJoin := PCJoinEnt()        
Endif       
	
cSelect   := PCRetSele(aCampos,nDivPor)
cLeftJoin := PCRetJoin(cLeftJoin)
cWhere    := PCRetWher(aFiltros,aFiltAd)

cTblName := CriaObjTmp(cArqtmp,aCampos)

cQryAKD := RetQryAKD(cTblName,dDataIni,dDataFim,cSelect,cLeftJoin,cWhere)

Return cQryAKD
//---------------------------------------------------
/*/{Protheus.doc} PCJoinEnt
Retorna a query caso utilize entidades adicionais.

@author TOTVS

@version P12
@since   31/03/2020
@return  cLeftJoin          Left Join para usar na query principal
/*/
//---------------------------------------------------
Static Function PCJoinEnt()
Local aArea     :=  GetArea()
Local cLeftJoin := ""
Local cCpoDesc  := ""
Local cCpoEnt   := ""
Local cEntidade := ""
Local cAliasQry := ""
Local cTblName  := ""
Local cCodPlano := ""
Local nI        := 0

For nI := 5 to _nQtdEntida    
    
    cEntidade := StrZero(nI,2) 

    CT0->(dbSetOrder(1))
    If CT0->(MsSeek(xFilial("CT0")+cEntidade))                
    
        cCpoEnt := "AKD_ENT"+cEntidade
    
        If AKD->(ColumnPos(cCpoEnt)) > 0            
    
            cTblName  := CT0->CT0_ALIAS            
            cAliasQry := cTblName
            cCodPlano := CT0->CT0_ENTIDA
            cCpoDesc  := AllTrim(CT0->CT0_CPODSC)
            
            If cTblName=="CV0"
                cAliasQry := "E"+cCodPlano           
            EndIf
    
            SX3->(dbSetOrder(1))
            //Pega o campo Filial da Tabela 
            If SX3->(MsSeek(cTblName+"01"))                     
               
                cLeftJoin += " LEFT JOIN "  
                cLeftJoin += RetSqlName(cTblName) +" "+cAliasQry+" " + CRLF                 
                cLeftJoin += " ON  "+cAliasQry+"."+SX3->X3_CAMPO+" = '"+xFilial(cTblName)+"' " + CRLF    
                
                If cTblName == "CV0"
                    cLeftJoin += " AND "+cAliasQry+".CV0_PLANO = '"+cCodPlano+"' " + CRLF                
                    cLeftJoin += " AND "+cAliasQry+".CV0_CODIGO <> ' ' " + CRLF                
                EndIf

                cLeftJoin += " AND "+cAliasQry+"." + CT0->CT0_CPOCHV +" = AKD."+cCpoEnt+ " " + CRLF 
                cLeftJoin += " AND "+cAliasQry+".D_E_L_E_T_ = ' ' " + CRLF
            EndIf       

        EndIf    

    EndIf    
Next nI

RestArea(aArea)

Return cLeftJoin
//---------------------------------------------------
/*/{Protheus.doc} PCRetSele
Retorna a string contentdo o select da query

@author TOTVS

@param aCampos      Estrutura de campos da tabela temporária
@param nDivPor      Valor para divisão do campo AKD_VALOR1
@param lQryFull     Indica se é a query aglutinadora (por visão)

@version P12
@since   31/03/2020
@return cSelectAux          String contendo o Select da Query Principal
/*/
//---------------------------------------------------
Static Function PCRetSele(aCampos,nDivPor,lQryFull,aCpsAdic)
Local cSelectAux := ""
Local cCampoAux  := ""
Local nI         := 0
Local nPosCpAd   := 0

DEFAULT aCampos  := {}
DEFAULT nDivPor  := 1
DEFAULT lQryFull := .F.
DEFAULT aCpsAdic  := {}

//------------------------------------   
//  AK5 - Contas Orçamentárias          
//  AK6 - Classes Orçamentárias         
//  AKF - Operações Orçamentárias       
//  AL2 - Tipos de Saldos                
//  AMF - Unidades Orçamentárias
//  CTD - Item Contábil                 
//  CTH - Classes de Valores            
//  CTT - Centro de Custo               
//------------------------------------

For nI := 1 to Len(aCampos)
    cCampoAux := aCampos[nI,1]

    If !lQryFull .And. !Empty(aCpsAdic) .And. (nPosCpAd:= aScan(aCpsAdic,{|x|x[1]==cCampoAux}))>0
        cSelectAux += " '"+Space(aCpsAdic[nPosCpAd,3])+"' "+aCpsAdic[nPosCpAd,1]+" , "+CRLF 
        Loop
    EndIf

    If cCampoAux <> "AKD_TIPVIS"
        If lQryFull
            cSelectAux += " "+cCampoAux            
        ElseIf Left(cCampoAux,3) == "AKD"
            If cCampoAux == "AKD_VALOR1"

                cSelectAux += " CASE AKD_TIPO WHEN '1' THEN "+cCampoAux+"/"+cValToChar(nDivPor)+" WHEN '2' THEN "+cCampoAux+"/"+cValToChar(nDivPor)+"*-1 ELSE 0 END AKD_VALOR1 "  
            Else
                cSelectAux += " "+cCampoAux
            EndIf
        ElseIf Left(cCampoAux,3) == "CV0"   
            cEntidade := SubStr(cCampoAux,9,2)
            cSelectAux += " ISNULL( E"+cEntidade+".CV0_DESC,'') "+cCampoAux
        Else
            cSelectAux += " ISNULL("+cCampoAux+",'') "+cCampoAux
        EndIf

        cSelectAux += ", "+CRLF    
    EndIf
Next nI

If lQryFull
    For nI := 1 to Len(aCpsAdic)
        cSelectAux += " '"+Space(aCpsAdic[nI,3])+"' "+aCpsAdic[nI,1]+" , "+CRLF 
    Next
EndIf

Return cSelectAux
//---------------------------------------------------
/*/{Protheus.doc} PCRetJoin
Retorna a string contentdo o join da query

@author TOTVS

@param cLeftJoin            LeftJoin das entidades adicionais

@version P12
@since   31/03/2020
@return cJoinAux            LeftJoin completo para uso na query principal
/*/
//---------------------------------------------------
Static Function PCRetJoin(cLeftJoin)
Local cJoinAux := ""

DEFAULT cLeftJoin := ""

//------------------------------------   
//  AK5 - Contas Orçamentárias          
//  AK6 - Classes Orçamentárias         
//  AKF - Operações Orçamentárias       
//  AL2 - Tipos de Saldos                
//  AMF - Unidades Orçamentárias
//  CTD - Item Contábil                 
//  CTH - Classes de Valores            
//  CTT - Centro de Custo               
//------------------------------------

cJoinAux += " LEFT JOIN "+RetSQLName("AK5")+" AK5 " + CRLF 
cJoinAux += " ON  AK5_FILIAL = '"+xFilial("AK5")+"' " + CRLF 
cJoinAux += " AND AK5_CODIGO = AKD_CO "+ CRLF 
cJoinAux += " AND AK5.D_E_L_E_T_ = ' ' " + CRLF 

cJoinAux += " LEFT JOIN "+RetSQLName("AK6")+" AK6 " + CRLF 
cJoinAux += " ON  AK6_FILIAL = '"+xFilial("AK6")+"' " + CRLF 
cJoinAux += " AND AK6_CODIGO = AKD_CLASSE "+ CRLF 
cJoinAux += " AND AK6.D_E_L_E_T_ = ' ' " + CRLF 

cJoinAux += " LEFT JOIN "+RetSQLName("AKF")+" AKF " + CRLF 
cJoinAux += " ON  AKF_FILIAL = '"+xFilial("AKF")+"' " + CRLF 
cJoinAux += " AND AKF_CODIGO = AKD_OPER " + CRLF 
cJoinAux += " AND AKF.D_E_L_E_T_ = ' ' " + CRLF 

cJoinAux += " LEFT JOIN "+RetSQLName("AL2")+" AL2 " + CRLF 
cJoinAux += " ON  AL2_FILIAL = '"+xFilial("AL2")+"' " + CRLF 
cJoinAux += " AND AL2_TPSALD = AKD_TPSALD " + CRLF 
cJoinAux += " AND AL2.D_E_L_E_T_ = ' ' " + CRLF 

cJoinAux += " LEFT JOIN "+RetSQLName("CTT")+" CTT " + CRLF 
cJoinAux += " ON  CTT_FILIAL = '"+xFilial("CTT")+"' " + CRLF 
cJoinAux += " AND CTT_CUSTO  = AKD_CC " + CRLF 
cJoinAux += " AND CTT.D_E_L_E_T_ = ' ' " + CRLF 

cJoinAux += " LEFT JOIN "+RetSQLName("CTD")+" CTD " + CRLF 
cJoinAux += " ON  CTD_FILIAL = '"+xFilial("CTD")+"' " + CRLF 
cJoinAux += " AND CTD_ITEM   = AKD_ITCTB " + CRLF 
cJoinAux += " AND CTD.D_E_L_E_T_ = ' ' " + CRLF 

cJoinAux += " LEFT JOIN "+RetSQLName("CTH")+" CTH " + CRLF 
cJoinAux += " ON  CTH_FILIAL = '"+xFilial("CTH")+"' " + CRLF 
cJoinAux += " AND CTH_CLASSE = AKD_CLVLR " + CRLF 
cJoinAux += " AND CTH.D_E_L_E_T_ = ' ' " + CRLF 
            
cJoinAux += " LEFT JOIN "+RetSQLName("AMF")+" AMF " + CRLF 
cJoinAux += " ON  AMF_FILIAL = '"+xFilial("AMF")+"' " + CRLF 
cJoinAux += " AND AMF_CODIGO = AKD_UNIORC " + CRLF 
cJoinAux += " AND AMF.D_E_L_E_T_ = ' ' " + CRLF 

cJoinAux += cLeftJoin

Return cJoinAux
//---------------------------------------------------
/*/{Protheus.doc} PCRetWher
Retorna a string contentdo o Where da query

@author TOTVS

@aFiltros               Filtros para uso no where da query
@aFiltAd                Filtros das entidades adicionais

@version P12
@since   31/03/2020
@return cWhereAux       String contendo o Where da Query principal
/*/
//---------------------------------------------------
Static Function PCRetWher(aFiltros,aFiltAd)
Local cWhereAux := ""
Local cCoDe	    := ""
Local cCoAte    := ""
Local cClOrcDe  := ""
Local cClOrcAte := ""
Local cTipoSld  := ""
Local cCustoDe  := ""
Local cCustoAte := ""
Local cItemDe   := ""
Local cItemAte  := ""
Local cClVlrDe  := ""
Local cClVlrAte := ""
Local cEntDe    := ""
Local cEntAte   := ""

Local nI        := 0
Local nTamCO    := 0
Local nTamClass := 0
Local nTamTpSld := 0
Local nTamCC    := 0
Local nTamItCtb := 0
Local nTamClVlr := 0
Local nTamEnt   := 0

DEFAULT aFiltros := {}
DEFAULT aFiltAd  := {}

nTamCO    := TamSX3("AKD_CO")[1]
nTamClass := TamSX3("AKD_CLASSE")[1]
nTamTpSld := TamSX3("AKD_TPSALD")[1]
nTamCC    := TamSX3("AKD_CC")[1]
nTamItCtb := TamSX3("AKD_ITCTB")[1]
nTamClVlr := TamSX3("AKD_CLVLR")[1]

cCoDe := PadR(aFiltros[CO_DE],nTamCO)
If ValType(cCoDe)=="C"
    cWhereAux += " AND AKD_CO >= '"+cCoDe+"' " + CRLF 
EndIf

cCoAte := PadR(aFiltros[CO_ATE],nTamCO)
If ValType(cCoAte)=="C" .And. !Empty(cCoAte)
    cWhereAux += " AND AKD_CO <= '"+cCoAte+"' " + CRLF 
EndIf

cClOrcDe := PadR(aFiltros[CLORC_DE],nTamClass)
If ValType(cClOrcDe)=="C"
    cWhereAux += " AND AKD_CLASSE	>= '"+cClOrcDe+"' " + CRLF 
EndIf

cClOrcAte := PadR(aFiltros[CLORC_ATE],nTamClass)
If ValType(cClOrcAte)=="C" .And. !Empty(cClOrcAte)
    cWhereAux += " AND AKD_CLASSE	<= '"+cClOrcAte+"' " + CRLF 
EndIf

cTipoSld := PadR(aFiltros[TIPO_SLD],nTamTpSld)
If ValType(cTipoSld)=="C" .And. !Empty(cTipoSld)
    cWhereAux += " AND AKD_TPSALD	= '"+cTipoSld+"' " + CRLF 
EndIf

cCustoDe := PadR(aFiltros[CUSTO_DE],nTamCC)
If ValType(cCustoDe)=="C"
    cWhereAux += " AND AKD_CC	>= '"+cCustoDe+"' " + CRLF 
EndIf

cCustoAte := PadR(aFiltros[CUSTO_ATE],nTamCC)
If ValType(cClOrcAte)=="C" .And. !Empty(cCustoAte)
    cWhereAux += " AND AKD_CC	<= '"+cCustoAte+"' " + CRLF 
EndIf

cItemDe := PadR(aFiltros[ITEM_DE],nTamItCtb)
If ValType(cItemDe)=="C"
    cWhereAux += " AND AKD_ITCTB	>= '"+cItemDe+"' " + CRLF 
EndIf

cItemAte := PadR(aFiltros[ITEM_ATE],nTamItCtb)
If ValType(cItemAte)=="C" .And. !Empty(cItemAte)
    cWhereAux += " AND AKD_ITCTB	<= '"+cItemAte+"' " + CRLF 
EndIf

cClVlrDe := PadR(aFiltros[CLVLR_DE],nTamClVlr)
If ValType(cClVlrDe)=="C"
    cWhereAux += " AND AKD_CLVLR	>= '"+cClVlrDe+"' " + CRLF 
EndIf

cClVlrAte := PadR(aFiltros[CLVLR_ATE],nTamClVlr)
If ValType(cClVlrAte)=="C" .And. !Empty(cClVlrAte)
    cWhereAux += " AND AKD_CLVLR	<= '"+cClVlrAte+"' " + CRLF 
EndIf

//filtro de entidades adicionais
If Len(aFiltAd) > 1    
    For nI := 5 to _nQtdEntida    
        
        If Len(aFiltAd) < 2
            Exit
        EndIf

        cEntidade := StrZero(nI,2)         
        cCpoEnt := "AKD_ENT"+cEntidade
        
        If AKD->(ColumnPos(cCpoEnt)) > 0   
            nTamEnt := TamSX3(cCpoEnt)[1]

            cEntDe := PadR(aFiltAd[ENTAD_DE],nTamEnt)
            If ValType(cEntDe)=="C"
                cWhereAux += " AND "+cCpoEnt+" >= '"+cEntDe+"' " + CRLF 
            EndIf

            cEntAte := PadR(aFiltAd[ENTAD_ATE],nTamEnt)
            If ValType(cEntAte)=="C" .And. !Empty(cEntAte)
                cWhereAux += " AND "+cCpoEnt+" <= '"+cEntAte+"' " + CRLF 
            EndIf
            
        EndIf

        ADel( aFiltAd, 1 )
        ADel( aFiltAd, 1 )
        ASize( aFiltAd, Len(aFiltAd)-2 )     

    Next nI
EndIf

Return cWhereAux
//---------------------------------------------------
/*/{Protheus.doc} QryPorVis
Retorna a string contentdo o Where da query

@author TOTVS

@param dDataIni       Data inicial para filtro na query
@param dDataFim       Data final para filtro na query
@param cArqtmp        Alias para montar a tabela temporária
@param cCodAgl        Código de aglutinação de Visão do PCO
@param nDecimais      Número de decimais para campos numéricos
@param aCampos        Array com a estrutura de campos para a consulta
@param cQueryRet      Variável para retornar a query completa
@param cTblName       Variável para retornar o nome da tabela temporária
@param nDivPor        Valor para divisão do campo AKD_VALOR1
@param aCpsAdic       Campos adicionais a ser adicionada a estrutura do arqtmp
@param cCondSQL       Condicao Adicional SQL a ser adicionada na clausula Where

@version P12
@since   31/03/2020
@return lRet    Lógico - Se o processo deu certo
/*/
//---------------------------------------------------
Static Function QryPorVis(dDataIni,dDataFim,cArqtmp,cCodAgl,nDecimais,aCampos,cQueryRet,cTblName,nDivPor,aCpsAdic,cCondSQL)
Local aArea     := GetArea()
Local cAliasAKO := GetNextAlias()
Local cQuery    := ""
Local cTables   := ""
Local cSelect   := ""
Local cLeftJoin := ""
Local cWhere    := ""
Local cEntSis   := ""
Local cEntFil   := ""
Local cCpoRef   := ""
Local cCpoFil   := ""
Local cTipoCPO  := ""
Local cCpoDesc  := ""
Local cIniCpo   := ""
Local cDigCpo   := ""
Local cFilIni   := ""
Local cFilFim   := ""
Local cCpoJaAdd := ""
Local cFiltAKO  := ""
Local cCodAKPAux:= ""
Local lRet      := .F.
Local nTCpFil   := 0
Local nI        := 0
Local aWhere    := {}
Local aTipVis   := {}
Local nX        := 0

DEFAULT dDataIni  := StoD("")
DEFAULT dDataFim  := StoD("")
DEFAULT cCodAgl   := ""
DEFAULT cQueryRet := ""
DEFAULT cTblName  := ""
DEFAULT cArqTmp   := ""
DEFAULT nDecimais := 0
DEFAULT aCampos   := {}
DEFAULT lEnd      := .F.
DEFAULT nDivPor   := 1
DEFAULT aCpsAdic  := {}
DEFAULT cCondSQL  := ""

aCampos := {{"AKD_DATA"     , "D", 8                       , 0          },;
            {"AKD_HIST"     , "C", TamSX3("AKD_HIST")[1]   , 0          },;
            {"AKD_PROCES"   , "C", TamSX3("AKD_PROCES")[1] , 0          },;
            {"AKD_TIPO"     , "C", TamSX3("AKD_TIPO")[1]   , 0          },;            
            {"AKD_CO"       , "C", TamSX3("AKD_CO")[1]     , 0          },;                                    
            {"AKD_VALOR1"   , "N", TamSX3("AKD_VALOR1")[1] , nDecimais  }}   

lRet:= PCRetCodVis(cCodAgl,@cFiltAKO,aTipVis)

If !lRet 
    cTblName := CriaObjTmp(cArqtmp,aCampos)
    Return lRet
EndIf

cQuery := " SELECT AKP_CODIGO, AKP_CONFIG, AKP_CO, AKP_ITEM, AKP_ITECFG, AKP_TIPO, AKM_TIPOCP, "
cQuery += " AKM_ENTSIS, AKM_CPOREF, AKM_ENTFIL, AKM_CPOFIL, AKP_VALINI, AKP_VALFIM, "
cQuery += " AKM_INICPO, AKM_DIGCPO, AKM_CODTAB "
cQuery += " FROM "+RetSqlName("AKO")+" AKO "
cQuery += " INNER JOIN "+RetSQLName("AKP")+" AKP "
cQuery += " ON AKP_FILIAL = '"+xFilial("AKP")+"' AND "
cQuery += " AKP_CODIGO = AKO_CODIGO AND "
cQuery += " AKP_CO = AKO_CO AND "

cQuery += " AKP.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("AKM")+" AKM "
cQuery += " ON AKM_FILIAL = '"+xFilial("AKM")+"' AND "
cQuery += " AKM_CONFIG = AKP_CONFIG AND  "
cQuery += " AKM_ITEM = AKP_ITECFG AND "
cQuery += " AKM_ENTFIL = 'AKD' AND "
cQuery += " AKM.D_E_L_E_T_ = ' ' "
cQuery += " WHERE AKO_FILIAL = '"+xFilial("AKO")+"' AND "
cQuery += "("+cFiltAKO+") AND "
cQuery += " ( AKM.AKM_ENTSIS != 'A1H' OR (AKM.AKM_ENTSIS = 'A1H' AND AKP.AKP_FILTCL <> '2')  ) AND " 
cQuery += " AKO.D_E_L_E_T_ = ' ' "
cQUery += " ORDER BY AKP_CODIGO, AKP_CONFIG, AKP_ITEM, AKP_ITECFG "

cQuery := ChangeQuery(cQuery)

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasAKO )

While !(cAliasAKO)->(Eof())
   
    If AllTrim((cAliasAKO)->AKM_ENTFIL) == "AKD"

        If Empty(cCodAKPAux)
            cCodAKPAux := (cAliasAKO)->AKP_CODIGO + (cAliasAKO)->AKP_ITEM                
        EndIf
        
        cEntSis  := AllTrim((cAliasAKO)->AKM_ENTSIS)   
        cEntFil  := AllTrim((cAliasAKO)->AKM_ENTFIL)   
        
        cTipoCPO := "C" 
        nDeciAUx := 0       

        If (cAliasAKO)->AKM_TIPOCP == "2"
            cTipoCPO := "N"
            nDeciAUx := nDecimais
        ElseIf (cAliasAKO)->AKM_TIPOCP == "3"
            cTipoCPO := "D"
        EndIf

        SX3->(dbSetOrder(1))
        //Pega o campo Filial da Tabela 
        If SX3->(MsSeek(cEntSis+"01"))   
            
            nTCpFil := 30
            cCpoRef := AllTrim((cAliasAKO)->AKM_CPOREF)
            cCpoFil := AllTrim((cAliasAKO)->AKM_CPOFIL)           
            
            If !Empty(cCpoFil)
                nTCpFil := TamSX3(cCpoFil)[1]
            EndIf
                        
            If !(cEntSis$"A1H/CV0/AKE")                
                If !Empty(cEntSis) .And. !(cEntSis$cTables)        
                    cLeftJoin += " LEFT JOIN "+RetSQLName(cEntSis)+" "+cEntSis+" " + CRLF 
                    cLeftJoin += " ON "+SX3->X3_CAMPO+" = '"+xFilial(cEntSis)+"' AND " + CRLF                     
                    cLeftJoin += cCpoRef+" = "+cCpoFil+" AND " + CRLF 
                    cLeftJoin += cEntSis+".D_E_L_E_T_ = ' ' " + CRLF 
                    cTables += cEntSis+","
                EndIf

                If !Empty(cCpoFil) .And. !(cCpoFil$cCpoJaAdd)   
                    cCpoJaAdd += cCpoFil+","                 
                    aAdd(aCampos, {cCpoFil,cTipoCPO,nTCpFil,nDeciAUx})               
                EndIf
                
                cCpoDesc := PCRetDesc(cEntSis)            
                If !Empty(cCpoDesc) .And. !(cCpoDesc$cCpoJaAdd)  
                    cCpoJaAdd += cCpoDesc+","
                    aAdd(aCampos, {cCpoDesc,"C",TamSX3(cCpoDesc)[1],0})                    
                EndIf    
            EndIf

            If cEntSis == "A1H"
                cIniCpo := cValToChar((cAliasAKO)->AKM_INICPO)
                cDigCpo := cValToChar((cAliasAKO)->AKM_DIGCPO)   
                nTCpFil := (cAliasAKO)->AKM_DIGCPO  
            EndIf
          
            cFilIni := PadR((cAliasAKO)->AKP_VALINI,nTCpFil)
            cFilFim := PadR((cAliasAKO)->AKP_VALFIM,nTCpFil)          

            If cEntSis == "A1H"
                If (cAliasAKO)->AKP_TIPO = '1'                    
                    cWhere += " SUBSTRING(AKD_CO,"+cIniCpo+","+cDigCpo+") = "
                    cWhere += "'"+cFilIni+"' AND " + CRLF 
                Else
                    cWhere += " SUBSTRING(AKD_CO,"+cIniCpo+","+cDigCpo+") BETWEEN "
                    cWhere += "'"+cFilIni+"' AND '"+cFilFim+"' AND " + CRLF 
                EndIf
            Else 
                If (cAliasAKO)->AKP_TIPO = '1'
                    cWhere += " "+cCpoFil+" = '"+cFilIni+"' AND " + CRLF 
                Else
                    cWhere += " "+cCpoFil+" BETWEEN "
                    cWhere += "'"+cFilIni+"' AND '"+cFilFim+"' AND " + CRLF 
                EndIf    
            EndIf
        EndIf
    EndIf
    (cAliasAKO)->(dbSkip())

    If (cAliasAKO)->AKP_CODIGO+(cAliasAKO)->AKP_ITEM <> cCodAKPAux
        cTipVis := ""
        If (nPos:=aScan(aTipVis,{|x| x[1]==Left(cCodAKPAux,Len(AKP->AKP_CODIGO))})) > 0
            cTipVis := aTipVis[nPos,2]
        EndIf
        aAdd(aWhere, {cTipVis,Left(cWhere,Len(cWhere)-6)})         
        cWhere     := ""              
        cCodAKPAux := (cAliasAKO)->AKP_CODIGO  + (cAliasAKO)->AKP_ITEM  
    EndIf

EndDo
(cAliasAKO)->(dbCloseArea())

PCRetEntid(aCampos)
     
If _nQtdEntida > 4        
    cLeftJoin += PCJoinEnt()                       
EndIf

cSelect := PCRetSele(aCampos,nil,.T.,aCpsAdic)

For nX := 1 TO Len(aCpsAdic)
    aAdd(aCampos, aCpsAdic[nX])
Next

aAdd(aCampos,{"AKD_TIPVIS" , "C", 1, 0})
cTblName := CriaObjTmp(cArqtmp,aCampos)

cQueryRet := " SELECT " + cSelect + CRLF 
cQueryRet += " AKD_TIPVIS, "  + CRLF 
cQueryRet += " ' ' D_E_L_E_T_, "  + CRLF 
cQueryRet += " (SELECT (ISNULL(MAX(R_E_C_N_O_),0)+1) FROM "+cTblName+" ) R_E_C_N_O_ " + CRLF 
cQueryRet += " FROM ("

cSelect := PCRetSele(aCampos,nDivPor,,aCpsAdic)
cSelect := Left(cSelect, Len(cSelect)-4)

If Len(aWhere) > 0
    For nI := 1 to Len(aWhere)
        cQueryRet += " SELECT " + cSelect + ", " + CRLF 
        cQueryRet += " '"+aWhere[nI,1]+"' AKD_TIPVIS " + CRLF 
        cQueryRet += " FROM "  + RetSqlName("AKD") + " AKD " + CRLF 
        cQueryRet += cLeftJoin + CRLF   
    
        cQueryRet += " WHERE AKD.AKD_FILIAL = '"+xFilial("AKD")+"' " + CRLF 
        cQueryRet += " AND AKD.AKD_DATA BETWEEN '"+DtoS(dDataIni)+"' AND '"+DtoS(dDataFim)+"' " + CRLF 
        If !Empty(cCondSQL)
            cQueryRet += cCondSQL + CRLF
        EndIf
        cQueryRet += " AND " + aWhere[nI,2] + CRLF  
        cQueryRet += " AND AKD.AKD_STATUS = '1' " + CRLF 
        cQueryRet += " AND AKD.D_E_L_E_T_ = ' ' " + CRLF 

        If nI < Len(aWhere)
            cQueryRet += " UNION ALL " + CRLF 
        EndIf
    Next nI 

    cQueryRet += ") TABAKD "
Else
    lRet := .F. //RETORNAR FALSO QUANDO NAO EXISTIR AKP
EndIf

RestArea(aArea)

Return lRet
//---------------------------------------------------
/*/{Protheus.doc} PCRetDesc
Retorna a string contentdo o Where da query

@author TOTVS

@cEntSis              Alias para retornar o campo de descrição

@version P12
@since   31/03/2020
@return cRet		  String com campo de descrição correspondente ao alias recebido
/*/
//---------------------------------------------------
Static Function PCRetDesc(cEntSis)
Local cRet      := ""

DEFAULT cEntSis := ""

Do Case
    Case cEntSis == "AK1"
        cRet := "AK1_DESCRI"
    Case cEntSis == "AK5"
        cRet := "AK5_DESCRI"
    Case cEntSis == "AK6"
        cRet := "AK6_DESCRI"
    Case cEntSis == "AKF"
        cRet := "AKF_DESCRI"
    Case cEntSis == "AL2"
        cRet := "AL2_DESCRI"
    Case cEntSis == "AMF"
        cRet := "AMF_DESCRI"
    Case cEntSis == "CTT"
        cRet := "CTT_DESC01"
    Case cEntSis == "CTD"
        cRet := "CTD_DESC01"    
    Case cEntSis == "CTH"
        cRet := "CTH_DESC01"    
End Case   

Return cRet
//---------------------------------------------------
/*/{Protheus.doc} PCInsertQry
Faz a inserção dos dados na tabela de trabalho

@author TOTVS

@cQryAux       Query para fazer o SELECT do INSERT
@cTblName      Nome do arquivo de trabalho para o INSERT

@version P12
@since   31/03/2020
@return Nil
/*/
//---------------------------------------------------
Static Function PCInsertQry(cTblName,cQryAux)
DEFAULT cQryAux := ""

cQryAux := " INSERT INTO "+cTblName+ " "+cQryAux

If TcSqlExec(cQryAux) <> 0
    UserException( TCSqlError() )
EndIf

Return 
//---------------------------------------------------
/*/{Protheus.doc} PCAtuMeter
Atualiza a regua de processamento gradualmente 

@author TOTVS

@param oMeter		Objeto da régua
@param nPCVlMeter	Valor para iniciar a régua
@param nValor		Valor para incrementar a régua

@version P12
@since   31/03/2020
@return Nil
/*/
//---------------------------------------------------
Static Function PCAtuMeter(oMeter,nPCVlMeter,nValor)
DEFAULT nPCVlMeter:= 0
DEFAULT nValor    := 0

If nPCVlMeter == 0 
    nPCVlMeter := 1
EndIf

nValor += nPCVlMeter

While nPCVlMeter <= nValor
    oMeter:Set(nPCVlMeter)
    nPCVlMeter++
EndDo    

Return
//---------------------------------------------------
/*/{Protheus.doc} RetQryAKD
Atualiza a regua de processamento gradualmente 

@author TOTVS

@cTblName       Nome da tabela temporária (FWTemporaryTable)
@dDataIni       Data inicial para filtro da query
@dDataFim       Data final para filtro da query
@cSelect        String contendo o select da query
@cLeftJoin      String contendo o Left Join da query
@cWhere         String contendo o Where da query

@version P12
@since   31/03/2020
@return cQryAKD String contendo a consulta completa da AKD de acordo com os filtros do usuário
/*/
//---------------------------------------------------
Static Function RetQryAKD(cTblName,dDataIni,dDataFim,cSelect,cLeftJoin,cWhere)
Local cQryAKD := ""

DEFAULT cTblName  := ""
DEFAULT dDataIni  := StoD("")
DEFAULT dDataFim  := StoD("")
DEFAULT cSelect   := ""
DEFAULT cLeftJoin := ""
DEFAULT cWhere    := ""

cQryAKD := " SELECT " + cSelect + CRLF 
cQryAKD += " ' ' D_E_L_E_T_, " + CRLF 
cQryAKD += "  (SELECT (ISNULL(MAX(R_E_C_N_O_),0)+1) FROM "+cTblName+" ) R_E_C_N_O_ " + CRLF 
cQryAKD += " FROM "+RetSqlName("AKD")+" AKD " + CRLF 
cQryAKD += cLeftJoin
cQryAKD += " WHERE AKD.AKD_FILIAL = '"+xFilial("AKD")+"' " + CRLF 
cQryAKD += " AND AKD.AKD_DATA BETWEEN '"+DtoS(dDataIni)+"' AND '"+DtoS(dDataFim)+"' " + CRLF 
cQryAKD += cWhere
cQryAKD += " AND AKD.AKD_STATUS = '1' "
cQryAKD += " AND AKD.D_E_L_E_T_ = ' ' "

cQryAKD := ChangeQuery(cQryAKD)

Return cQryAKD
//---------------------------------------------------
/*/{Protheus.doc} PCRetEntid
Retorna os campos de entidades adicionais, caso utilize 

@author TOTVS

@aRet       Array contendo os campos para o arquivo temporário.


@version P12
@since   31/03/2020
@return 
/*/
//---------------------------------------------------
Static Function PCRetEntid(aRetAux)
Local nI         := 0
Local cEntidade  := ""
Local cCpoEntAKD := ""
Local cCpoDesCT0 := ""
Local cCpoDesAux := ""

DEFAULT aRetAux  := {}

For nI := 5 to _nQtdEntida        

    cEntidade   := StrZero(nI,2)     
    //Para buscar o campo de descrição no SX3 e obter o tamanho
    CT0->(dbSetOrder(1))
    If CT0->(MsSeek(xFilial("CT0")+cEntidade))    

        cCpoEntAKD := "AKD_ENT"+cEntidade
        cCpoDesCT0 := CT0->CT0_CPODSC        
        cCpoDesAux := cCpoDesCT0

        If CT0->CT0_ALIAS == "CV0"
            //Se for CV0 monto um campo de descrição para cada entidade            
            cCpoDesAux  := Left(cCpoDesCT0,8)+cEntidade
        EndIf

        aAdd(aRetAux, {cCpoEntAKD   , "C" , TamSX3(cCpoEntAKD)[1]  , 0 })
        aAdd(aRetAux, {cCpoDesAux   , "C" , TamSX3(cCpoDesCT0)[1]  , 0 })
    EndIf

Next nI

Return
//---------------------------------------------------
/*/{Protheus.doc} PCRetCodVis
Retorna os campos de entidades adicionais, caso utilize 

@author TOTVS

@param cCodAgl     Código de aglutinação da visão do PCO
@param cFiltAKO    String contendo a clausula Where da query que busca as visões gerenciais
@param aTipVis     Tipo da visão RECEITA ou DESPESA

@version P12
@since   31/03/2020
@return lRet Indica se a função processou corretamente
/*/
//---------------------------------------------------
Static Function PCRetCodVis(cCodAgl,cFiltAKO,aTipVis)
Local aArea    := GetArea()
Local lRet     := .F.

DEFAULT cCodAgl  := ""
DEFAULT cFiltAKO := ""
DEFAULT aTipVis  := {}

A1J->(dbSetOrder(1))
If A1J->(dbSeek(xFilial("A1J")+cCodAgl))
    While !A1J->(Eof()) .And. A1J->(A1J_FILIAL+A1J_CODAGL) == xFilial("A1J")+cCodAgl
        cFiltAKO += " AKO_CODIGO = '"+A1J->A1J_CODVIS+"' OR "
        aAdd(aTipVis,{A1J->A1J_CODVIS,IIf(A1J->A1J_RECDES=="1","R","D")})
        A1J->(dbSkip())
    EndDo    
EndIf

If !Empty(cFiltAKO)   
    cFiltAKO := Left(cFiltAKO,Len(cFiltAKO)-3)
    lRet := .T.
EndIf

RestArea(aArea)

Return lRet

/*
//-----------------------------------------
//
// SOMENTE PARA DEBUG
//
//-----------------------------------------
Function ChamaXSAL() 
Local cArqTmp   := GetNextAlias()
Local lPorVisao := .T.
Local cCodAgl   := "" //Informar aqui o código da algutinação para teste
Local cMoeda    := "01"
Local dDataIni  := STOD("")
Local dDataFim  := STOD("")
Local oMeter    
Local oText
Local oDlg
Local lEnd

aFiltros := {" ","ZZZZZZZ",;
             " ","ZZZZZZZ",;
             " ",; 
             " ","ZZZZZZZ",;
             " ","ZZZZZZZ",;      
             " ","ZZZZZZZ" }

aFiltAd  := {" ","ZZZZZZZ",;
             " ","ZZZZZZZ",;             
             " ","ZZZZZZZ",;
             " ","ZZZZZZZ",;      
             " ","ZZZZZZZ" }

If (Aviso("Atenção","Como quer executar a rotina?",{"Parâmetro","Visão"},1)==1)
    lPorVisao := .F.
    dDataIni  := STOD("20190101")
    dDataFim  := STOD("20190131")
    MsgMeter({|	oMeter, oText, oDlg, lEnd |;
    PCGerPlan(oMeter,oText,oDlg,lEnd,cArqtmp,cMoeda,lPorVisao,cCodAgl,dDataIni,dDataFim,aFiltros,aFiltAd,100);
    },"Processando dados...","Aguarde")
Else
    lPorVisao := .T.
    dDataIni  := STOD("20190101")
    dDataFim  := STOD("20190131")
    MsgMeter({|	oMeter, oText, oDlg, lEnd |;
    PCGerPlan(oMeter,oText,oDlg,lEnd,cArqtmp,cMoeda,lPorVisao,cCodAgl,dDataIni,dDataFim,aFiltros,aFiltAd,100);
    },"Processando dados...","Aguarde")
EndIf

If (cArqTmp)->(Select()) > 0    
    Aviso("Atenção",cValToChar((cArqTmp)->(RecCount()))+" registros inseridos na tabela temporária",{"Ok"},1)
    (cArqTmp)->(dbCloseArea())
EndIf

Return
*/