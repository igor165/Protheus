#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "SPEDNFE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWBROWSE.CH"
#include "fwmvcdef.ch"
#include "GTPA805.ch"


/*/{Protheus.doc} GTPA805
(long_description)
@type  Static Function
@author henrique.toyada
@since 11/10/2019
@version 1.0
@param , param_type, param_descr
@return , return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA805()
/* 
"0=CTe Não Transmitido",
"1=CTe Aguardando",
"2=CTe Autorizado",
"3=CTe Nao Autorizado",
"4=CTe em Contingencia",
"5=CTe com Falha na Comunicacao",
"9=Documento não preparado para transmissão" 
*/      
Local lRet := .T.

Private cChave := G99->G99_CODIGO

lRet := GA805Valid()

If lRet
    If G99->G99_STATRA == '2' .AND. G99->G99_TIPCTE $ '0|3'
        G804Comple()	
    Else
        FwAlertHelp(STR0002,STR0001)//"Apenas CTE autorizado poderá ser feito o complementar." //"STATUS"
    Endif
EndIf 

Return 

/*/{Protheus.doc} G804Comple
(long_description)
@type  Static Function
@author henrique.toyada
@since 11/10/2019
@version 1.0
@param , param_type, param_descr
@return , return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G804Comple()
Local aArea        := GetArea()
Local cTitulo      := STR0003 //"CTE Complementar"
Local cAliaVisu    := "VIEWDEF.GTPA805"
Local nOperation   := MODEL_OPERATION_INSERT
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,STR0005},{.T.,STR0004},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}} //STR0005 //STR0004 //"Cancelar" //"Confirmar"

Private aValG99 := ValG99()
//Caso precise testar em algum lugar
__lCopia     := .T.
 
//Executando a visualização dos dados para manipulação
nRet     := FWExecView( cTitulo , cAliaVisu, nOperation, , { || .T. }, , ,aButtons )
__lCopia := .F.
 
//Se a cópia for confirmada
If nRet == 0
    MsgInfo(STR0007, STR0006) //"Atenção" //"Complemento gerado!"
EndIf
 
RestArea(aArea)
Return 

/*/{Protheus.doc} ValG99
(long_description)
@type  Static Function
@author user
@since 17/10/2019
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ValG99()
Local aCampos := {}
Local cChvNF  := ""
Local cFilDoc   := ""

If G99->(FieldPos('G99_FILDOC')) > 0
    cFilDoc := G99->G99_FILDOC
Else
    cFilDoc := Posicione('GI6',1,xFilial('GI6')+G99->G99_CODEMI,"GI6_FILRES")
Endif

cChvNF  :=  cFilDoc + G99->G99_NUMDOC + G99->G99_SERIE

If G99->G99_TOMADO == "0"
    cChvNF += G99->G99_CLIREM + G99->G99_LOJREM
Else
    cChvNF += G99->G99_CLIDES + G99->G99_LOJDES
Endif

AADD(aCampos,{"G99_CHVFIS", cChvNF            })
AADD(aCampos,{"G99_CLIREM", G99->G99_CLIREM   })
AADD(aCampos,{"G99_LOJREM", G99->G99_LOJREM   })
AADD(aCampos,{"G99_CLIDES", G99->G99_CLIDES   })
AADD(aCampos,{"G99_LOJDES", G99->G99_LOJDES   })
AADD(aCampos,{"G99_TOMADO", G99->G99_TOMADO   })
AADD(aCampos,{"G99_CODEMI", G99->G99_CODEMI   })
AADD(aCampos,{"G99_CODREC", G99->G99_CODREC   })
AADD(aCampos,{"G99_CODPRO", G99->G99_CODPRO   })
AADD(aCampos,{"G99_TABFRE", G99->G99_TABFRE   })
AADD(aCampos,{"G99_TS"    , G99->G99_TS       })
AADD(aCampos,{"G99_CFOP"  , G99->G99_CFOP     })
AADD(aCampos,{"G99_PESO"  , G99->G99_PESO     })
AADD(aCampos,{"G99_PESCUB", G99->G99_PESCUB   })
AADD(aCampos,{"G99_METRO3", G99->G99_METRO3   })
AADD(aCampos,{"G99_QTDVO" , G99->G99_QTDVO    })
AADD(aCampos,{"G99_KMFRET", G99->G99_KMFRET   })
AADD(aCampos,{"G99_VALOR" , G99->G99_VALOR    })
AADD(aCampos,{"G99_DTPREV", G99->G99_DTPREV   })
AADD(aCampos,{"G99_HRPREV", G99->G99_HRPREV   })
AADD(aCampos,{"G99_SERIE" , G99->G99_SERIE    })
AADD(aCampos,{"G99_NUMDOC", G99->G99_NUMDOC   })
AADD(aCampos,{"G99_TIPCTE", "1"               })
AADD(aCampos,{"G99_CHVCTE", ""                })
AADD(aCampos,{"G99_CHVANT", G99->G99_CHVCTE   })
AADD(aCampos,{"G99_CHVSUB", G99->G99_CHVSUB   })
AADD(aCampos,{"G99_CHVANU", G99->G99_CHVANU   })
AADD(aCampos,{"G99_DTEMIS", dDataBase         })
AADD(aCampos,{"G99_HREMIS", SUBSTR(Time(),1,5)})
AADD(aCampos,{"G99_STAENC", G99->G99_STAENC   })
AADD(aCampos,{"G99_STATRA", G99->G99_STATRA   })
AADD(aCampos,{"G99_TIPSER", G99->G99_TIPSER   })
AADD(aCampos,{"G99_TPIMPR", G99->G99_TPIMPR   })
AADD(aCampos,{"G99_TPEMIS", G99->G99_TPEMIS   })
AADD(aCampos,{"G99_USUINC", G99->G99_USUINC   })
AADD(aCampos,{"G99_USUENC", G99->G99_USUENC   })
AADD(aCampos,{"G99_OBSERV", G99->G99_OBSERV   })
AADD(aCampos,{"G99_XMLENV", G99->G99_XMLENV   })
AADD(aCampos,{"G99_XMLRET", G99->G99_XMLRET   })
AADD(aCampos,{"G99_MOTREJ", G99->G99_MOTREJ   })
AADD(aCampos,{"G99_PROTCA", G99->G99_PROTCA   })    

If G99->(FieldPos('G99_FILDOC')) > 0
    AADD(aCampos,{"G99_FILDOC", G99->G99_FILDOC })    
Endif

Return aCampos


/*/{Protheus.doc} PrenchG9R
(long_description)
@type  Static Function
@author user
@since 14/10/2019
@version version
@param cCodG9r, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function PrenchG9R(cCodG9r)

Local cAliasQry   := GetNextAlias()
Local aCampos     := {}

Default cCodG9r := ""

BeginSQL Alias cAliasQry
    SELECT R_E_C_N_O_ AS RECNOG9R 
    FROM %Table:G9R % G9R 
    WHERE G9R.%NotDel%
        AND G9R.G9R_FILIAL = %xFilial:G9R%
        AND G9R.G9R_CODIGO = %Exp:cCodG9r%
EndSQL

While (cAliasQry)->(!Eof())	
    G9R->(DBGoTo((cAliasQry)->RECNOG9R))
    AADD(aCampos,{{"G9R_ITEM"  ,G9R->G9R_ITEM},{"G9R_DESCRI",G9R->G9R_DESCRI}})
    (cAliasQry)->(DbSkip())    
End
(cAliasQry)->(DbCloseArea())

Return aCampos

/*/{Protheus.doc} PrenchG9P
(long_description)
@type  Static Function
@author user
@since 14/10/2019
@version version
@param cCodG9r, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function PrenchG9P(cCodG9r)

Local cAliasQry   := GetNextAlias()
Local aCampos     := {}

Default cCodG9r := ""

BeginSQL Alias cAliasQry
    SELECT R_E_C_N_O_ AS RECNOG9R 
    FROM %Table:G9P % G9P 
    WHERE G9P.%NotDel%
        AND G9P.G9P_FILIAL = %xFilial:G9P%
        AND G9P.G9P_CODIGO = %Exp:cCodG9r%
EndSQL

While (cAliasQry)->(!Eof())	
    G9P->(DBGoTo((cAliasQry)->RECNOG9R))
    AADD(aCampos,{{"G9P_ITEM",G9P->G9P_ITEM  },{"G9P_ESTADO",G9P->G9P_ESTADO}})
    (cAliasQry)->(DbSkip())    
End
(cAliasQry)->(DbCloseArea())

Return aCampos

/*/{Protheus.doc} PrenchG9Q
(long_description)
@type  Static Function
@author user
@since 14/10/2019
@version version
@param cCodG9r, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function PrenchG9Q(cCodG99)

Local cAliasQry   := GetNextAlias()
Local aCampos     := {}

Default cCodG99 := ""

BeginSQL Alias cAliasQry
    SELECT R_E_C_N_O_ AS RECNOG9Q
    FROM %Table:G9Q % G9Q 
    WHERE G9Q.%NotDel%
        AND G9Q.G9Q_FILIAL = %xFilial:G9Q%
        AND G9Q.G9Q_CODIGO = %Exp:cCodG99%
EndSQL

While (cAliasQry)->(!Eof())	
    G9Q->(DBGoTo((cAliasQry)->RECNOG9Q))
    AADD(aCampos,{  {"G9Q_ITEM"  ,G9Q->G9Q_ITEM},;
                    {"G9Q_CODLIN",G9Q->G9Q_CODLIN},;
                    {"G9Q_SERVIC",G9Q->G9Q_SERVIC},;
                    {"G9Q_LOCINI",G9Q->G9Q_LOCINI},;
                    {"G9Q_LOCFIM",G9Q->G9Q_LOCFIM},;
                    {"G9Q_AGEORI",G9Q->G9Q_AGEORI},;
                    {"G9Q_AGEDES",G9Q->G9Q_AGEDES},;
                    {"G9Q_KILOME",G9Q->G9Q_KILOME},;
                    {"G9Q_STAENC",G9Q->G9Q_STAENC},;
                    {"G9Q_USUREC",G9Q->G9Q_USUREC};
                })
    (cAliasQry)->(DbSkip())    
End
(cAliasQry)->(DbCloseArea())

Return aCampos

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author user
@since 14/10/2019
@version version
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel    := nil
Local oStrG99   := FWFormStruct(1, "G99") //Entrada de Encomendas
Local oStrG9R   := FWFormStruct(1, "G9R") //Declaração
Local oStrG9Q   := FWFormStruct(1, "G9Q") //Serviços
Local oStrG9P   := FWFormStruct(1, "G9P") //Estados

Local bPosValid := {|oModel| PosValid(oModel)}

SetModelStruct(oStrG99,oStrG9R,oStrG9Q,oStrG9P)

oModel := MPFormModel():New("GTPA805",/*PREVALID*/, bPosValid/*POSVALID*/, /*COMMIT*/)
oModel:SetDescription(STR0008) //"Entrada de Encomendas"

//Cabeçalho G99 -- Entrada de Encomendas
oModel:AddFields("MASTERG99",/*oOwner*/, oStrG99,,,)
oModel:GetModel("MASTERG99"):SetDescription(STR0008) //"Entrada de Encomendas"

//Grid - G9R -- Declaração
oModel:AddGrid("DETAILG9R", "MASTERG99", oStrG9R)
oModel:SetRelation("DETAILG9R", {{"G9R_FILIAL", "xFilial('G9R')"}, {"G9R_CODIGO", "G99_CODIGO"}}, G9R->(IndexKey(1)))
oModel:GetModel("DETAILG9R"):SetUniqueLine({"G9R_DESCRI"})
oModel:GetModel("DETAILG9R"):SetDescription(STR0009) //"Declaração de Encomendas"
oModel:GetModel('DETAILG9R'):SetOptional(.T.)

//Grid - G9Q -- Serviços de transporte
oModel:AddGrid("DETAILG9Q", "MASTERG99", oStrG9Q, )
oModel:SetRelation("DETAILG9Q", {{"G9Q_FILIAL", "xFilial('G9Q')"}, {"G9Q_CODIGO", "G99_CODIGO"}}, G9Q->(IndexKey(1)))
oModel:GetModel("DETAILG9Q"):SetUniqueLine({'G9Q_CODLIN', 'G9Q_SERVIC','G9Q_LOCINI','G9Q_LOCFIM'})
oModel:GetModel("DETAILG9Q"):SetDescription(STR0010) //"Serviços de transporte"
oModel:GetModel('DETAILG9Q'):SetOptional(.T.)

//Grid - G9P -- Lista de Estados
oModel:AddGrid("DETAILG9P", "MASTERG99", oStrG9P)
oModel:SetRelation("DETAILG9P", {{"G9P_FILIAL", "xFilial('G9P')"}, {"G9P_CODIGO", "G99_CODIGO"}}, G9P->(IndexKey(1)))
oModel:GetModel("DETAILG9P"):SetUniqueLine({'G9P_ESTADO'})
oModel:GetModel("DETAILG9P"):SetDescription(STR0011) //"Lista de Estados"
oModel:GetModel('DETAILG9P'):SetOptional(.T.)

oModel:SetPrimarykey({"G99_FILIAL", "G99_CODIGO"})

oModel:SetActivate( {|oModel| PrenchG99(oModel) } )

Return oModel


/*/{Protheus.doc} PrenchG99
(long_description)
@type  Static Function
@author user
@since 14/10/2019
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function PrenchG99(oModel)

Local nCnt         := 0
Local nX           := 0
Local aCampoG9R    := {}
Local aCampoG9Q    := {}
Local aCampoG9P    := {}
Local oMdlG99	
Local oMdlG9R   
Local oMdlG9Q
Local oMdlG9P

If oModel:getoperation() == 3
    oMdlG99	:= oModel:GetModel('MASTERG99')
    oMdlG9R	:= oModel:GetModel('DETAILG9R')
    oMdlG9P	:= oModel:GetModel('DETAILG9P')
    oMdlG9Q	:= oModel:GetModel('DETAILG9Q')

    For nCnt := 1 To len(aValG99)
        oMdlG99:SetValue(aValG99[nCnt,1], aValG99[nCnt,2])
    Next 

    aCampoG9R := PrenchG9R(cChave)

    For nCnt := 1 To len(aCampoG9R)
        If nCnt > 1
            oMdlG9R:AddLine()
        EndIf
        For nX := 1 To len(aCampoG9R[nCnt])
            oMdlG9R:SetValue(aCampoG9R[nCnt,nX,1], aCampoG9R[nCnt,nX,2])
        Next
    Next

    aCampoG9Q := PrenchG9Q(cChave)

    For nCnt := 1 To len(aCampoG9Q)
        If nCnt > 1
            oMdlG9Q:AddLine()
        EndIf
        For nX := 1 To len(aCampoG9Q[nCnt])
            oMdlG9Q:SetValue(aCampoG9Q[nCnt,nX,1], aCampoG9Q[nCnt,nX,2])
        Next
    Next

    aCampoG9P := PrenchG9P(cChave)

    For nCnt := 1 To len(aCampoG9P)
        If nCnt > 1
            oMdlG9P:AddLine()
        EndIf
        For nX := 1 To len(aCampoG9P[nCnt])
            oMdlG9P:SetValue(aCampoG9P[nCnt,nX,1], aCampoG9P[nCnt,nX,2])
        Next
    Next
EndIf

Return 

/*/
 * {Protheus.doc} SetModelStruct()
 * Estrutura do Model
 * type    Static Function
 * author  henrique.toyada
 * since   17/10/2019
 * version 12.25
 * param   oStrG99, oStrG9R, oStrG9Q, oStrG9P
 * return  Não há
/*/
Static Function SetModelStruct(oStrG99, oStrG9R, oStrG9Q, oStrG9P)
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

    If ValType(oStrG99) == "O"
        
        oStrG99:SetProperty("G99_DTPREV" , MODEL_FIELD_OBRIGAT, .F.)
        oStrG99:SetProperty("G99_HRPREV" , MODEL_FIELD_OBRIGAT, .F.)

        oStrG99:AddTrigger("G99_CLIREM" , "G99_CLIREM"  ,  {||.T.}, bTrig)
        oStrG99:AddTrigger("G99_LOJREM" , "G99_LOJREM"  ,  {||.T.}, bTrig)
        oStrG99:AddTrigger("G99_CLIDES" , "G99_CLIDES"  ,  {||.T.}, bTrig)
        oStrG99:AddTrigger("G99_LOJDES" , "G99_LOJDES"  ,  {||.T.}, bTrig)
        oStrG99:AddTrigger("G99_CODEMI" , "G99_CODEMI"  ,  {||.T.}, bTrig)
        oStrG99:AddTrigger("G99_CODREC" , "G99_CODREC"  ,  {||.T.}, bTrig)
        oStrG99:AddTrigger("G99_CODPRO" , "G99_CODPRO"  ,  {||.T.}, bTrig)
        oStrG99:AddTrigger("G99_TABFRE" , "G99_TABFRE"  ,  {||.T.}, bTrig)
        oStrG99:AddTrigger("G99_TS"     , "G99_TS"      ,  {||.T.}, bTrig)
        oStrG99:AddTrigger("G99_CFOP"   , "G99_CFOP"    ,  {||.T.}, bTrig)
        oStrG99:AddTrigger("G99_KMFRET" , "G99_KMFRET"  ,  {||.T.}, bTrig)
        oStrG9Q:AddTrigger("G9Q_CODLIN", "G9Q_CODLIN",  {||.T.}, bTrig)
        oStrG9Q:AddTrigger("G9Q_SERVIC", "G9Q_SERVIC",  {||.T.}, bTrig)
        oStrG9Q:AddTrigger("G9Q_LOCINI", "G9Q_LOCINI",  {||.T.}, bTrig)
        oStrG9Q:AddTrigger("G9Q_LOCFIM", "G9Q_LOCFIM",  {||.T.}, bTrig)
        oStrG9Q:AddTrigger("G9Q_AGEORI", "G9Q_AGEORI",  {||.T.}, bTrig)
        oStrG9Q:AddTrigger("G9Q_AGEDES", "G9Q_AGEDES",  {||.T.}, bTrig)
        oStrG9Q:AddTrigger("G9Q_KILOME", "G9Q_KILOME",  {||.T.}, bTrig)

    Endif

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldTrigger

@type Function
@author 
@since 27/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)
Local aArea     := GetArea()
Local aAreaSB1  := nil

Do Case 
//G99
    Case cField == 'G99_LOJREM'
        oMdl:SetValue("G99_NOMREM", Posicione('SA1',1,xFilial('SA1')+oMdl:GetValue('G99_CLIREM')+uVal,'A1_NOME'))
    Case cField == 'G99_LOJDES'
        oMdl:SetValue("G99_NOMDES", Posicione('SA1',1,xFilial('SA1')+oMdl:GetValue('G99_CLIDES')+uVal,'A1_NOME'))
    Case cField == 'G99_CODEMI'
        oMdl:SetValue("G99_DESEMI", Posicione('GI6',1,xFilial('GI6')+uVal,'GI6_DESCRI'))
    Case cField == 'G99_CODREC'
        oMdl:SetValue("G99_DESREC", Posicione('GI6',1,xFilial('GI6')+uVal,'GI6_DESCRI'))    
    Case cField == 'G99_CODPRO'
        aAreaSB1 := SB1->(GetArea())
        
        SB1->(DbSetOrder(1))
        If !Empty(uVal) .and. SB1->(DbSeek(xFilial('SB1')+uVal))
            oMdl:SetValue("G99_DESPRO"  , SB1->B1_DESC)
            oMdl:SetValue("G99_TS"    , SB1->B1_TS )    
        Else
            oMdl:SetValue("G99_DESPRO"  ,"")
            oMdl:SetValue("G99_TS"    ,"")
        Endif
        RestArea(aAreaSB1)
        
    Case cField == 'G99_TABFRE'
        oMdl:SetValue("G99_NTBFRE", Posicione('G5J',1,xFilial('G5J')+uVal,'G5J_DESCRI'))

    Case cField == 'G99_CFOP'
        oMdl:SetValue("G99_NTCFOP", Posicione('SX5',1,xFilial('SX5')+'13'+uVal,'X5_DESCRI'))

//G9Q
    Case cField == 'G9Q_LOCINI'
        oMdl:SetValue("G9Q_DLOCIN", Posicione('GI1',1,xFilial('GI1')+uVal,'GI1_DESCRI'))
        oMdl:SetValue("G9Q_AGEORI", Posicione('GI6',3,xFilial('GI6')+uVal,'GI6_CODIGO'))
        oMdl:SetValue("G9Q_LOCFIM","")
        
    Case cField == 'G9Q_LOCFIM'
        oMdl:SetValue("G9Q_DLOCFI", Posicione('GI1',1,xFilial('GI1')+uVal,'GI1_DESCRI'))
        oMdl:SetValue("G9Q_AGEDES", Posicione('GI6',3,xFilial('GI6')+uVal,'GI6_CODIGO'))
        oMdl:SetValue("G9Q_KILOME", Posicione('GI4',/*nOrd*/,xFilial('GI4')+oMdl:GetValue('G9Q_CODLIN')+oMdl:GetValue('G9Q_LOCINI')+uVal+'2','GI4_KM','GI4LOCHIST' ))
       
   
    Case cField == 'G9Q_AGEORI'
        oMdl:SetValue("G9Q_DAGORI", Posicione('GI6',1,xFilial('GI6')+uVal,'GI6_DESCRI'))

    Case cField == 'G9Q_AGEDES'
        oMdl:SetValue("G9Q_DAGDES", Posicione('GI6',1,xFilial('GI6')+uVal,'GI6_DESCRI'))
    
EndCase 

RestArea(aArea)

GtpDestroy(aArea)
GtpDestroy(aAreaSb1)

Return uVal

/* /{Protheus.doc} ViewDef

@type Function
@author 
@since 17/10/2019
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oModel    := ModelDef()
Local oStG99E   := FWFormStruct(2, "G99")
Local oStG99C   := FWFormStruct(2, "G99")
Local oStG99O   := FWFormStruct(2, "G99")
Local oStrG9R   := FWFormStruct(2, "G9R")
Local oStrG9Q   := FWFormStruct(2, "G9Q")
Local oStrG9P   := FWFormStruct(2, "G9P")
Local oView     := nil
Local bVisuDoc  := {|oView| GTPDocFis()}

SetViewStruct(oStG99E, oStG99C,oStG99O,oStrG9R, oStrG9Q, oStrG9P)

oView := FwFormView():New()
oView:SetModel(oModel)

//Cabeçalho - G99
oView:AddField("FILD_VIEWG99E", oStG99E, "MASTERG99")
oView:AddField("FILD_VIEWG99O", oStG99C, "MASTERG99")
oView:AddField("FILD_VIEWG99C", oStG99O, "MASTERG99")
oView:AddGrid("GRID_VIEWG9R" , oStrG9R, "DETAILG9R")
oView:AddGrid("GRID_VIEWG9Q" , oStrG9Q, "DETAILG9Q")
oView:AddGrid("GRID_VIEWG9P" , oStrG9P, "DETAILG9P")

oView:CreateFolder("FOLDER")

oView:AddSheet( "FOLDER", "ABA01", "Encomendas") // "Trechos/Recursos"
oView:CreateHorizontalBox( 'BOX_ENCOMENDAS' , 60, /*owner*/,/*lUsePixel*/, 'FOLDER', 'ABA01' ) 
oView:CreateHorizontalBox( 'BOX_BAIXO' , 40, /*owner*/,/*lUsePixel*/, 'FOLDER', 'ABA01' ) 

oView:CreateFolder("FOLDER_BAIXO", "BOX_BAIXO")
oView:AddSheet("FOLDER_BAIXO",'SHEET_DECLARACOES', "Declarações")
oView:AddSheet("FOLDER_BAIXO",'SHEET_SERVICOS', "Serviços")

oVIew:CreateHorizontalBox('BOX_DECLARACOES', 100,,,'FOLDER_BAIXO', 'SHEET_DECLARACOES' )

oView:CreateVerticalBox( 'BOX_SERVICO', 80, , , 'FOLDER_BAIXO', 'SHEET_SERVICOS')
oView:CreateVerticalBox( 'BOX_ESTADOS', 20, , , 'FOLDER_BAIXO', 'SHEET_SERVICOS')

oView:AddSheet( "FOLDER", "ABA02", "Conhecimento") // "Trechos/Recursos"
oView:CreateHorizontalBox( 'BOX_CONHECIMENTO' , 100, /*owner*/,/*lUsePixel*/, 'FOLDER', 'ABA02' ) 

oView:AddSheet( "FOLDER", "ABA03", "Outros") // "Trechos/Recursos"
oView:CreateHorizontalBox( 'BOX_OUTROS' , 100, /*owner*/,/*lUsePixel*/, 'FOLDER', 'ABA03' ) 

oView:SetOwnerView("FILD_VIEWG99E", "BOX_ENCOMENDAS")
oView:SetOwnerView("FILD_VIEWG99O", "BOX_CONHECIMENTO")
oView:SetOwnerView("FILD_VIEWG99C", "BOX_OUTROS")
oView:SetOwnerView("GRID_VIEWG9R", "BOX_DECLARACOES")
oView:SetOwnerView("GRID_VIEWG9Q", "BOX_SERVICO")
oView:SetOwnerView("GRID_VIEWG9P", "BOX_ESTADOS")

oView:addIncrementField("GRID_VIEWG9R", "G9R_ITEM")
oView:addIncrementField("GRID_VIEWG9Q", "G9Q_ITEM")
oView:addIncrementField("GRID_VIEWG9P", "G9P_ITEM")

If oModel:GetOperation()==MODEL_OPERATION_VIEW
	oView:AddUserButton("Visualiza Doc.", "MAGIC_BMP",bVisuDoc, "Visualiza Doc.") 
EndIf

Return oView

/* /{Protheus.doc} SetViewStruct

@type Function
@author 
@since 17/10/2019
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStruct(oStG99E, oStG99C, oStG99O, oStrG9R, oStrG9Q, oStrG9P)

oStG99E:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
oStG99C:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
oStG99O:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)

oStG99C:SetProperty("G99_TS"  , MVC_VIEW_CANCHANGE, .T.)
oStG99C:SetProperty("G99_CFOP", MVC_VIEW_CANCHANGE, .T.)
oStG99E:SetProperty("G99_COMPVL", MVC_VIEW_CANCHANGE, .T.)
oStG99E:SetProperty("G99_COMPLM", MVC_VIEW_CANCHANGE, .T.)

oStrG9R:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
oStrG9Q:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
oStrG9P:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)

oStG99E:RemoveField("G99_FILIAL")
oStG99E:RemoveField("G99_TS"    )
oStG99E:RemoveField("G99_CFOP"  )
oStG99E:RemoveField("G99_NTCFOP")
oStG99E:RemoveField("G99_SERIE" )
oStG99E:RemoveField("G99_NUMDOC")
oStG99E:RemoveField("G99_TIPCTE")
oStG99E:RemoveField("G99_CHVCTE")
oStG99E:RemoveField("G99_CHVSUB")
oStG99E:RemoveField("G99_CHVANU")
oStG99E:RemoveField("G99_TIPSER")
oStG99E:RemoveField("G99_TPIMPR")
oStG99E:RemoveField("G99_TPEMIS")
oStG99E:RemoveField("G99_USUINC")
oStG99E:RemoveField("G99_USUENC")
oStG99E:RemoveField("G99_OBSERV")
oStG99E:RemoveField("G99_XMLENV")
oStG99E:RemoveField("G99_XMLRET")
oStG99E:RemoveField("G99_MOTREJ")
oStG99E:RemoveField("G99_CODREF")
oStG99E:RemoveField("G99_PROTCA")
oStG99E:RemoveField("G99_PROTOC")
oStG99E:RemoveField("G99_CHVANT")
oStG99E:RemoveField("G99_CHVFIS")
oStG99E:RemoveField("G99_NUMFCH")
oStG99E:RemoveField("G99_CONFER")
oStG99E:RemoveField("G99_VALACE")

oStG99C:RemoveField("G99_CODIGO")
oStG99C:RemoveField("G99_CLIREM")
oStG99C:RemoveField("G99_LOJREM")
oStG99C:RemoveField("G99_CLIDES")
oStG99C:RemoveField("G99_LOJDES")
oStG99C:RemoveField("G99_TOMADO")
oStG99C:RemoveField("G99_CODEMI")
oStG99C:RemoveField("G99_CODREC")
oStG99C:RemoveField("G99_CODPRO")
oStG99C:RemoveField("G99_TABFRE")
oStG99C:RemoveField("G99_PESO")
oStG99C:RemoveField("G99_PESCUB") 
oStG99C:RemoveField("G99_METRO3")
oStG99C:RemoveField("G99_QTDVO")
oStG99C:RemoveField("G99_KMFRET")
oStG99C:RemoveField("G99_VALOR")
oStG99C:RemoveField("G99_DTPREV")
oStG99C:RemoveField("G99_HRPREV")
oStG99C:RemoveField("G99_USUENC")
oStG99C:RemoveField("G99_USUINC")
oStG99C:RemoveField("G99_NOMREM")
oStG99C:RemoveField("G99_NOMDES")
oStG99C:RemoveField("G99_STAENC")
oStG99C:RemoveField("G99_STATRA")
oStG99C:RemoveField("G99_NTBFRE")
oStG99C:RemoveField("G99_DESPRO")
oStG99C:RemoveField("G99_TPIMPR")
oStG99C:RemoveField("G99_COMPLM")
oStG99C:RemoveField("G99_COMPVL")
oStG99C:RemoveField("G99_NUMFCH")
oStG99C:RemoveField("G99_DESEMI")
oStG99C:RemoveField("G99_DESREC")
oStG99C:RemoveField("G99_CHVANT")
oStG99C:RemoveField("G99_CHVFIS")
oStG99C:RemoveField("G99_TIPSER")
oStG99C:RemoveField("G99_TPEMIS")
oStG99C:RemoveField("G99_HREMIS")
oStG99C:RemoveField("G99_DTEMIS")
oStG99C:RemoveField("G99_CONFER")
oStG99C:RemoveField("G99_VALACE")
    
oStG99O:RemoveField("G99_FILIAL")
oStG99O:RemoveField("G99_CODIGO")
oStG99O:RemoveField("G99_CLIREM")
oStG99O:RemoveField("G99_LOJREM")
oStG99O:RemoveField("G99_NOMREM")
oStG99O:RemoveField("G99_CLIDES")
oStG99O:RemoveField("G99_LOJDES")
oStG99O:RemoveField("G99_NOMDES")
oStG99O:RemoveField("G99_TOMADO")
oStG99O:RemoveField("G99_CODEMI")
oStG99O:RemoveField("G99_DESEMI")
oStG99O:RemoveField("G99_CODREC")
oStG99O:RemoveField("G99_DESREC")
oStG99O:RemoveField("G99_CODPRO")
oStG99O:RemoveField("G99_DESPRO")
oStG99O:RemoveField("G99_TABFRE")
oStG99O:RemoveField("G99_NTBFRE")
oStG99O:RemoveField("G99_TS"    )
oStG99O:RemoveField("G99_NTCFOP")
oStG99O:RemoveField("G99_PESCUB")
oStG99O:RemoveField("G99_METRO3")
oStG99O:RemoveField("G99_KMFRET")
oStG99O:RemoveField("G99_DTPREV")
oStG99O:RemoveField("G99_HRPREV")
oStG99O:RemoveField("G99_NUMDOC")
oStG99O:RemoveField("G99_TIPCTE")
oStG99O:RemoveField("G99_CHVCTE")
oStG99O:RemoveField("G99_CHVSUB")
oStG99O:RemoveField("G99_CHVANU")
oStG99O:RemoveField("G99_DTEMIS")
oStG99O:RemoveField("G99_HREMIS")
oStG99O:RemoveField("G99_STAENC")
oStG99O:RemoveField("G99_STATRA")
oStG99O:RemoveField("G99_OBSERV")
oStG99O:RemoveField("G99_XMLENV")
oStG99O:RemoveField("G99_XMLRET")
oStG99O:RemoveField("G99_MOTREJ")
oStG99O:RemoveField("G99_PROTCA")
oStG99O:RemoveField("G99_PROTOC")
oStG99O:RemoveField("G99_CFOP"  )
oStG99O:RemoveField("G99_PESO"  )
oStG99O:RemoveField("G99_QTDVO" )
oStG99O:RemoveField("G99_VALOR" )
oStG99O:RemoveField("G99_SERIE ")
oStG99O:RemoveField("G99_TIPSER")
oStG99O:RemoveField("G99_TPIMPR")
oStG99O:RemoveField("G99_TPEMIS")
oStG99O:RemoveField("G99_CHVANT")
oStG99O:RemoveField("G99_CHVFIS")
oStG99O:RemoveField("G99_COMPLM")
oStG99O:RemoveField("G99_COMPVL")
oStG99O:RemoveField("G99_NUMFCH")
oStG99O:RemoveField("G99_SERIE")
oStG99O:RemoveField("G99_CONFER")
oStG99O:RemoveField("G99_VALACE")

oStG99C:AddGroup( "GRUPO_TES", "", "" , 1 )
oStG99C:AddGroup( "GRUPO_DOCUMENTO", "", "" , 1 )
oStG99C:AddGroup( "GRUPO_CHAVE", "", "" , 1 )
oStG99C:AddGroup( "GRUPO_PROTOCOLOS", "", "" , 1 )
oStG99C:AddGroup( "GRUPO_OBS", "", "" , 1 )
oStG99C:AddGroup( "GRUPO_XML", "", "" , 1 )
oStG99C:AddGroup( "GRUPO_XMLRET", "", "" , 1 )
oStG99C:AddGroup( "GRUPO_MOTIVO", "", "" , 1 )

oStG99E:AddGroup("GRUPO_REGISTRO"           , ""                                , "FOLDER_ENCOMENDA" , 2)
oStG99E:AddGroup("GRUPO_REMETENTE"          , ""                                , "FOLDER_ENCOMENDA" , 2)
oStG99E:AddGroup("GRUPO_DESTINATARIO"       , ""                                , "FOLDER_ENCOMENDA" , 2)
oStG99E:AddGroup("GRUPO_EMITENTE"           , ""                                , "FOLDER_ENCOMENDA" , 2)
oStG99E:AddGroup("GRUPO_RECEBEDOR"          , ""                                , "FOLDER_ENCOMENDA" , 2)
oStG99E:AddGroup("GRUPO_TOMADOR"            , ""                                , "FOLDER_ENCOMENDA" , 2)
oStG99E:AddGroup("GRUPO_PRODUTO"            , "Dados do Produto"                , "FOLDER_ENCOMENDA" , 2)
oStG99E:AddGroup("GRUPO_TABELA_FRETE"       , ""                                , "FOLDER_ENCOMENDA" , 2)
oStG99E:AddGroup("GRUPO_METRAGEM_SERVICO"   , "Dados Prestação de Serviço"      , "FOLDER_ENCOMENDA" , 2)
oStG99E:AddGroup("GRUPO_VALOR_SERVICO"      , ""                                , "FOLDER_ENCOMENDA" , 2)
oStG99E:AddGroup("GRUPO_DTHR_PREVISTA"      , "Data/Hora prevista de entrega"   , "FOLDER_ENCOMENDA" , 2)
oStG99E:AddGroup("GRUPO_STATUS"             , "Status"                          , "FOLDER_ENCOMENDA" , 2)

oStG99C:SetProperty("G99_TS"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_TES" )
oStG99C:SetProperty("G99_CFOP"   , MVC_VIEW_GROUP_NUMBER, "GRUPO_TES" )
oStG99C:SetProperty("G99_NTCFOP" , MVC_VIEW_GROUP_NUMBER, "GRUPO_TES" )
oStG99C:SetProperty("G99_SERIE"  , MVC_VIEW_GROUP_NUMBER, "GRUPO_TES" )
oStG99C:SetProperty("G99_NUMDOC" , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
oStG99C:SetProperty("G99_TIPCTE" , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
oStG99C:SetProperty("G99_CHVCTE" , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
oStG99C:SetProperty("G99_CHVANU" , MVC_VIEW_GROUP_NUMBER, "GRUPO_CHAVE" )
oStG99C:SetProperty("G99_CHVSUB" , MVC_VIEW_GROUP_NUMBER, "GRUPO_CHAVE" )
oStG99C:SetProperty("G99_PROTOC" , MVC_VIEW_GROUP_NUMBER, "GRUPO_PROTOCOLOS" )
oStG99C:SetProperty("G99_PROTCA" , MVC_VIEW_GROUP_NUMBER, "GRUPO_PROTOCOLOS" )
oStG99C:SetProperty("G99_OBSERV" , MVC_VIEW_GROUP_NUMBER, "GRUPO_OBS" )
oStG99C:SetProperty("G99_XMLENV" , MVC_VIEW_GROUP_NUMBER, "GRUPO_XML" )
oStG99C:SetProperty("G99_XMLRET" , MVC_VIEW_GROUP_NUMBER, "GRUPO_XMLRET" )
oStG99C:SetProperty("G99_MOTREJ" , MVC_VIEW_GROUP_NUMBER, "GRUPO_MOTIVO" )

If G99->(FieldPos('G99_FILDOC')) > 0
    oStG99C:RemoveField("G99_FILDOC")
    oStG99E:RemoveField("G99_FILDOC")
    oStG99O:RemoveField("G99_FILDOC")
Endif

oStG99E:SetProperty("G99_CODIGO"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_REGISTRO")
oStG99E:SetProperty("G99_DTEMIS"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_REGISTRO")
oStG99E:SetProperty("G99_HREMIS"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_REGISTRO")
oStG99E:SetProperty("G99_CLIREM"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_REMETENTE")
oStG99E:SetProperty("G99_LOJREM"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_REMETENTE")
oStG99E:SetProperty("G99_NOMREM"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_REMETENTE")
oStG99E:SetProperty("G99_CLIDES"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_DESTINATARIO")
oStG99E:SetProperty("G99_LOJDES"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_DESTINATARIO")
oStG99E:SetProperty("G99_NOMDES"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_DESTINATARIO")
oStG99E:SetProperty("G99_CODEMI"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_EMITENTE")
oStG99E:SetProperty("G99_DESEMI"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_EMITENTE")
oStG99E:SetProperty("G99_CODREC"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_RECEBEDOR")
oStG99E:SetProperty("G99_DESREC"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_RECEBEDOR")
oStG99E:SetProperty("G99_TOMADO"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_TOMADOR")
oStG99E:SetProperty("G99_CODPRO"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_PRODUTO")
oStG99E:SetProperty("G99_DESPRO"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_PRODUTO")
oStG99E:SetProperty("G99_TABFRE"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_TABELA_FRETE")
oStG99E:SetProperty("G99_NTBFRE"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_TABELA_FRETE")
oStG99E:SetProperty("G99_PESO"      , MVC_VIEW_GROUP_NUMBER, "GRUPO_METRAGEM_SERVICO")
oStG99E:SetProperty("G99_PESCUB"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_METRAGEM_SERVICO")
oStG99E:SetProperty("G99_METRO3"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_METRAGEM_SERVICO")
oStG99E:SetProperty("G99_QTDVO"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_METRAGEM_SERVICO")
oStG99E:SetProperty("G99_KMFRET"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR_SERVICO")
oStG99E:SetProperty("G99_VALOR"     , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR_SERVICO")
oStG99E:SetProperty("G99_COMPLM"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR_SERVICO")
oStG99E:SetProperty("G99_COMPVL"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR_SERVICO")

oStG99E:SetProperty("G99_DTPREV"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_DTHR_PREVISTA")
oStG99E:SetProperty("G99_HRPREV"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_DTHR_PREVISTA")
oStG99E:SetProperty("G99_STAENC"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_STATUS")
oStG99E:SetProperty("G99_STATRA"    , MVC_VIEW_GROUP_NUMBER, "GRUPO_STATUS")
   
oStG99C:SetProperty("G99_TIPCTE"      , MVC_VIEW_COMBOBOX, {STR0024,STR0023,STR0021,STR0022 }) //"2=Anulação" //"3=Substituição" //"1=Complemento" //"0=Normal"
oStG99E:SetProperty("G99_STAENC"      , MVC_VIEW_COMBOBOX, {STR0027,STR0025,STR0026,STR0029,STR0028}) //"2=Em Transporte" //"3=Em Transbordo" //"1=Aguardando" //"5=Retirado" //"4=Recebido"
oStG99E:SetProperty("G99_STATRA"      , MVC_VIEW_COMBOBOX, {STR0036,STR0037,STR0039,STR0038,STR0035,STR0031,STR0030,STR0032,STR0034,STR0033}) //"6=Doc. de Saída Excluído" //"5=CTe com Falha na Comunicacao" //"7=Cancelamento Rejeitado" //"9=Documento não preparado para transmissão" //"8=CTe Cancelado" //"4=CTe em Contingencia" //"0=CTe Não Transmitido" //"1=CTe Aguardando" //"3=CTe Nao Autorizado" //"2=CTe Autorizado"

oStG99C:SetProperty("G99_PROTOC", MVC_VIEW_ORDEM, '37')
oStG99C:SetProperty("G99_PROTCA", MVC_VIEW_ORDEM, '38')

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} PosValid

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function PosValid(oModel)
Local lRet      := .T.
Local cMdlId	:= oModel:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

If lRet .and. !VldNF(oModel,@cMsgErro,@cMsgSol)
    lRet := .F.
Endif

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,,cMdlId,,"PosValid",cMsgErro,cMsgSol)
Endif


Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} VldNF

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldNF(oModel,cMsgErro,cMsgSol)
Local lRet  := .T.
Local nOpc  := oModel:GetOperation()

Begin Transaction

    If nOpc == MODEL_OPERATION_UPDATE .or. nOpc == MODEL_OPERATION_DELETE
        lRet := DeletaNF(oModel,@cMsgErro,@cMsgSol)
    Endif

    If lRet .and. (nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE)
        lRet := GeraNf(oModel,@cMsgErro,@cMsgSol)
    Endif

    If !lRet 
        DisarmTransaction()
        Break		
    Endif

End Transaction

Return lRet 

//------------------------------------------------------------------------------
/* /{Protheus.doc} GeraNf

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GeraNf(oModel,cMsgErro,cMsgSol)
Local lRet          := .T.
Local aDadosCab     := {}
Local aItem         := {}
Local aDadosItem    := {}
Local bFiscalSF2    := nil
Local cNumero       := ""
Local oMdlG99       := oModel:GetModel('MASTERG99')
Local cSerie        := oMdlG99:GetValue('G99_SERIE')
Local cEspecie      := "CTE"
Local cEstDev       := ""
Local cTipoCli      := ""
Local cSitTrib      := ""
Local aMunIni       := GxGetMunAg(oMdlG99:GetValue('G99_CODEMI'))
Local aMunFim       := GxGetMunAg(oMdlG99:GetValue('G99_CODREC'))

//-------------------------------------------------------------------------------
//Criação dos Dados de Cabeçalho
//-------------------------------------------------------------------------------
DbSelectArea( "SB0" )

SA1->(DbSetOrder(1))//
SF4->(DbSetOrder(1))
SB1->(DbSetOrder(1))
SBZ->(DbSetOrder(1))
SB0->(DbSetOrder(1))

aAdd(aDadosCab,{"F2_FILIAL"     ,xFilial("SF2")                 })
aAdd(aDadosCab,{"F2_TIPO"       ,oMdlG99:GetValue('G99_COMPLM')})
aAdd(aDadosCab,{"F2_SERIE"      ,cSerie                         })
aAdd(aDadosCab,{"F2_EMISSAO"    ,oMdlG99:GetValue('G99_DTEMIS') })

If oMdlG99:GetValue('G99_TOMADO') == "0"  //Remetente
    SA1->(DbSeek(xFilial('SA1')+oMdlG99:GetValue('G99_CLIREM')+oMdlG99:GetValue('G99_LOJREM') ))
Else
    SA1->(DbSeek(xFilial('SA1')+oMdlG99:GetValue('G99_CLIDES')+oMdlG99:GetValue('G99_LOJDES') ))
Endif

aAdd(aDadosCab,{"F2_CLIENTE"    ,SA1->A1_COD })
aAdd(aDadosCab,{"F2_LOJA"       ,SA1->A1_LOJA })

cEstDev     := SA1->A1_EST
cTipoCli    := SA1->A1_TIPO

aAdd(aDadosCab,{"F2_TIPOCLI"    ,cTipoCli})
aAdd(aDadosCab,{"F2_ESPECIE"    ,cEspecie})
aAdd(aDadosCab,{"F2_COND"       ,'001'})
aAdd(aDadosCab,{"F2_DTDIGIT"    ,oMdlG99:GetValue('G99_DTEMIS') })
aAdd(aDadosCab,{"F2_EST"        ,aMunIni[1]})
aAdd(aDadosCab,{"F2_VALMERC"    ,oMdlG99:GetValue('G99_COMPVL') })
aAdd(aDadosCab,{"F2_MOEDA"      ,CriaVar( 'F2_MOEDA' )})
aAdd(aDadosCab,{"F2_UFORIG"     ,aMunIni[1]})
aAdd(aDadosCab,{"F2_CMUNOR"     ,aMunIni[2]})
aAdd(aDadosCab,{"F2_UFDEST"     ,aMunFim[1]})
aAdd(aDadosCab,{"F2_CMUNDE"     ,aMunFim[2]})

//-------------------------------------------------------------------------------
//Criação dos Dados de Item
//-------------------------------------------------------------------------------
aAdd(aItem,{"D2_FILIAL"     ,xFilial("SF2")     })
aAdd(aItem,{"D2_ITEM"       ,StrZero(1,TamSx3("D2_ITEM")[1])     })
aAdd(aItem,{"D2_SERIE"      ,cSerie             })
aAdd(aItem,{"D2_CLIENTE"    ,SA1->A1_COD        })
aAdd(aItem,{"D2_LOJA"       ,SA1->A1_LOJA       })
aAdd(aItem,{"D2_EMISSAO"    ,oMdlG99:GetValue('G99_DTEMIS')            })
aAdd(aItem,{"D2_TIPO"       ,oMdlG99:GetValue('G99_COMPLM')})
aAdd(aItem,{"D2_UM"         ,"UN"               })
aAdd(aItem,{"D2_QUANT"      ,0                  })
aAdd(aItem,{"D2_PRUNIT"     ,oMdlG99:GetValue('G99_COMPVL')    })
aAdd(aItem,{"D2_PRCVEN"     ,oMdlG99:GetValue('G99_COMPVL')    })
aAdd(aItem,{"D2_TOTAL"      ,oMdlG99:GetValue('G99_COMPVL')    })
aAdd(aItem,{"D2_EST"        ,aMunIni[1]            })
aAdd(aItem,{"D2_ESPECIE"    ,cEspecie	        })

If SB1->(DbSeek(xFilial('SB1')+oMdlG99:GetValue('G99_CODPRO') ))
            
    aAdd(aItem,{"D2_LOCAL"      ,SB1->B1_LOCPAD     })
    aAdd(aItem,{"D2_COD"        ,SB1->B1_COD        })
    aAdd(aItem,{"D2_TP"         ,SB1->B1_TIPO       })
    aAdd(aItem,{"D2_CONTA"      ,SB1->B1_CONTA      })

    If !Empty( SB1->B1_CODISS )
        aAdd(aItem,{"D2_CODISS"     ,SB1->B1_CODISS     })
    ElseIf SBZ->( dbSeek( xFilial("SBZ") + oMdlG99:GetValue('G99_CODPRO') ) ) .And. !Empty( SBZ->BZ_CODISS )
        aAdd(aItem,{"D2_CODISS"     ,SBZ->BZ_CODISS     })
    EndIf

    aAdd(aItem,{"D2_TES"        ,oMdlG99:GetValue('G99_TS')     })
    aAdd(aItem,{"D2_CF"         ,oMdlG99:GetValue('G99_CFOP')         })
    aAdd(aItem,{"D2_ESTOQUE"    ,Posicione('SF4',1,xFilial('SF4')+oMdlG99:GetValue('G99_TS'),'F4_ESTOQUE')    })

    SB0->(DbSeek(xFilial("SB0")+SB1->B1_COD))
    
    //Executa funções padrões do LOJA para retornar a situação tributária a ser gravada na SD2
    Lj7Strib(@cSitTrib ) 
    Lj7AjustSt(@cSitTrib)

    aAdd(aItem,{"D2_SITTRIB"    ,cSitTrib           })

Endif

SF2->(DbSetOrder(1))
If SF2->(DBSEEK(ALLTRIM(oMdlG99:GetValue('G99_CHVFIS'))))
    aAdd(aItem,{"D2_NFORI"  ,SF2->F2_DOC})
    aAdd(aItem,{"D2_SERIORI",SF2->F2_SERIE})
EndIf

aAdd(aDadosItem,aItem)

bFiscalSF2 := {||;
                    MaFisAlt( "NF_UFORIGEM"     , aMunIni[1]   , , , , , , .F./*lRecal*/   ),;
                    MaFisAlt( "NF_UFDEST"       , aMunFim[1]   , , , , , , .F./*lRecal*/   ),;
                    MaFisAlt( "NF_PNF_UF"       , cEstDev      , , , , , , .F./*lRecal*/   ),;
                    MaFisAlt( "NF_ESPECIE"      , cEspecie     , , , , , , .F./*lRecal*/   ),;
                    MaFisAlt( "NF_PNF_TPCLIFOR" , cTipoCli );
                }

cNumero := GTPxNFS(cSerie,aDadosCab,aDadosItem,bFiscalSF2)

If !Empty(cNumero)
    oMdlG99:SetValue('G99_NUMDOC',cNumero)
    oMdlG99:SetValue('G99_STATRA',"0")

    If G99->(FieldPos('G99_FILDOC')) > 0
        oMdlG99:SetValue('G99_FILDOC', xFilial('SF2'))
    Endif

Else
    lRet := .F.
    cMsgErro    := STR0040 //"Não foi possivel gerar o documento de Saida"
    cMsgSol     := STR0041 //"Verifique se o cliente, produto, tipo de Saída ou o CFOP estão cadastrados corretamente"
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} DeletaNF

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function DeletaNF(oModel,cMsgErro,cMsgSol)
Local lRet      := .T.
Local nOpc      := oModel:GetOperation()
Local oMdlG99   := oModel:GetModel('MASTERG99')
Local dDtdigit  := Stod('')
Local cChvNF    := ""
Local aRegSD2   := {}
Local aRegSE1   := {}
Local aRegSE2   := {}
Local cFilOld   := ""
Local cFilDoc   := ""

If G99->(FieldPos('G99_FILDOC')) > 0
    cFilDoc := oMdlG99:GetValue('G99_FILDOC')
Else
    cFilDoc := Posicione('GI6',1,xFilial('GI6')+oMdlG99:GetValue('G99_CODEMI'),"GI6_FILRES")
Endif

SF2->(DbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
If !Empty(oMdlG99:GetValue('G99_NUMDOC')) 
    cChvNF  :=  cFilDoc+oMdlG99:GetValue('G99_NUMDOC')+oMdlG99:GetValue('G99_SERIE')

    If oMdlG99:GetValue('G99_TOMADO') == "0"
        cChvNF += oMdlG99:GetValue('G99_CLIREM')+oMdlG99:GetValue('G99_LOJREM')
    Else
        cChvNF += oMdlG99:GetValue('G99_CLIDES')+oMdlG99:GetValue('G99_LOJDES')
    Endif

    If SF2->(DbSeek(cChvNF))
        // Exclui a nota
        dDtdigit 	:= IIf(!Empty(SF2->F2_DTDIGIT),SF2->F2_DTDIGIT,SF2->F2_EMISSAO)
        IF dDtDigit >= MVUlmes()
            If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
                SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.T.,.F.))
                If nOpc <> MODEL_OPERATION_DELETE
                    oMdlG99:SetValue('G99_NUMDOC',"")
                    oMdlG99:SetValue('G99_STATRA',"9")

                    If G99->(FieldPos('G99_FILDOC')) > 0
                        oMdlG99:SetValue('G99_FILDOC',"")
                    Endif

                Endif
            Else
                lRet        := .F.
                cMsgErro    := STR0042 //"Não foi possivel excluir a nota"
                cMsgSol     := ""
            Endif
                
        EndIf
    Endif
EndIf

Return lRet 


/*/
 * {Protheus.doc} GA804Valid
 * View
 * type    Static Function
 * author  Flavio Martins
 * since   22/10/2019
 * version 12.25
 * param   
 * return  lRet
/*/
Static Function GA805Valid()
Local cAliasG99 := GetNextAlias()
Local cChave	:= G99->G99_CHVCTE
Local cStaTrans	:= G99->G99_STATRA	
Local cTipCte	:= G99->G99_TIPCTE
Local lRet 		:= .T.
    
If lRet .And. cStaTrans <> '2'
    FwAlertHelp('CT-e não Autorizado, Complementar não permitida')
    lRet := .F.
Endif

If lRet .And. cStaTrans == '2' .And. cTipCte == '1'
    FwAlertHelp('CT-e complementado, Complementar não permitida')
    lRet := .F.
Endif

If lRet .And. cStaTrans == '2' .And. cTipCte == '2'
    FwAlertHelp('CT-e Anulado, Complementar não permitida')
    lRet := .F.
Endif

If lRet
    BeginSql Alias cAliasG99

        SELECT G99_TIPCTE FROM %Table:G99% G99
        WHERE
        G99.G99_FILIAL = %xFilial:G99% 
        AND	G99.G99_CHVANT = %Exp:cChave% OR G99.G99_CHVANT = %Exp:cChave%
        AND	G99.G99_TIPCTE <> '0' 
        AND G99.%NotDel%
        
    EndSql
    
    If (cAliasG99)->(!Eof())
    
        While (cAliasG99)->(!Eof())
        
            If (cAliasG99)->G99_TIPCTE == '2' .And. cTipCte <> '3'
                FwAlertHelp('CT-e Anulado, Complementar não permitida')
                lRet := .F.
                Exit
            Endif
            
            (cAliasG99)->(dbSkip())
        End
        
    Endif	
    
    (cAliasG99)->(dbCloseArea())
Endif

Return lRet
