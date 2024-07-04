#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'TOTVS.CH'
#include 'topconn.ch'
#include 'ru09xfun.ch'

/*/{Protheus.doc} RU09XTIOSQFilter
Filter for the Standard Query for Smart TIO.
@author Konstantin Cherchik
@since 04/11/2018
@version P12.1.20
@type function
/*/
Function  RU09XTIOSQFilter() 

Local aAreaSA1          as Array
Local aAreaSA2          as Array
Local aAreaSB1          as Array
Local aAreaSBM          as Array
Local aAreaF51          as Array
Local aAreaF50          as Array
Local cSupplierID       as Character
Local cClientID         as Character
Local cProductID        as Character
Local cLoja             as Character
Local cProdTaxGroup     as Character 
Local cProdGrpType      as Character
Local cSupTaxGrp        as Character
Local cCusTaxGrp        as Character
Local cB1Grupo          as Character
Local cRulesKey         as Character
Local cNFTipoNF         as Character
Local cNFOperNF         as Character
Local cNFEspecie        as Character
Local ldbSeekHandler    as Logical
Local lCompra           as Logical
Local oModel            as Object


cProdTaxGroup   :=  Space(TamSX3("F51_PRDGRP")[1])
cSupTaxGrp      :=  Space(TamSX3("F51_GRPSUP")[1])
cCusTaxGrp      :=  Space(TamSX3("F51_GRPCUS")[1])
cProdGrpType    :=  Space(TamSX3("F51_TPPRD ")[1])

cNFTipoNF := Iif(MaFisFound(), MaFisRet(, "NF_TIPONF"), "")
cNFOperNF := Iif(MaFisFound(), MaFisRet(, "NF_OPERNF"), "")
cNFEspecie:= Iif(MaFisFound(), MaFisRet(, "NF_ESPECIE"), "")

ldbSeekHandler  := .F.
oModel      := FWModelActive()

/* Get the necessary information to determine the Smart TIO code, depending on the source. */ 

If (IsInCallStack("MATA121"))

    cSupplierID := M->CA120FORN
    cLoja       := M->CA120LOJ
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C7_PRODUTO')} )]

ElseIf (IsInCallStack("A410INCLUI") .Or. IsInCallStack("A410ALTERA") .Or. IsInCallStack("A410COPIA"))

    If !EMPTY(AllTrim(M->C5_TIPO)) .And. AllTrim(M->C5_TIPO)=='B'
        cSupplierID := M->C5_CLIENTE
    Else
        cClientID   := M->C5_CLIENTE
    EndIf
    cLoja       := M->C5_LOJACLI
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C6_PRODUTO')} )]

ElseIf (IsInCallStack("CNTA300RUS"))

    If (IsInCallStack("CN300ALTER"))

        oModel      := FWModelActive()
        lCompra	    := CN300RetSt("COMPRA",0,oModel:GetModel('CNADETAIL'):GetValue('CNA_NUMERO'),oModel:GetModel('CN9MASTER'):GetValue('CN9_NUMERO'))

        If lCompra
            cSupplierID := AllTrim(oModel:GetValue('CNADETAIL','CNA_FORNEC'))
            cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LJFORN'))
            cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))
        Else
            cClientID   := AllTrim(oModel:GetValue('CNADETAIL','CNA_CLIENT'))
            cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LOJACL'))
            cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))
        EndIf

    ElseIf (IsInCallStack("CN300InCOM")) 

        oModel      := FWModelActive()

        cSupplierID := AllTrim(oModel:GetValue('CNADETAIL','CNA_FORNEC'))
        cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LJFORN'))
        cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))

    ElseIf (IsInCallStack("CN300InVEN")) 

        oModel      := FWModelActive()

        cClientID   := AllTrim(oModel:GetValue('CNADETAIL','CNA_CLIENT'))
        cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LOJACL'))
        cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))

    Endif

ElseIf (IsInCallStack("CNTA121RUS")) 

    oModel      := FWModelActive()
    lCompra	    := CN300RetSt("COMPRA",0,oModel:GetModel('CXNDETAIL'):GetValue('CXN_NUMPLA'),oModel:GetModel("CNDMASTER"):GetValue("CND_CONTRA"))

    If lCompra
        cSupplierID   := AllTrim(oModel:GetValue('CXNDETAIL','CXN_FORCLI'))
        cLoja       := AllTrim(oModel:GetValue('CXNDETAIL','CXN_LOJA')) 
        cProductID  := AllTrim(oModel:GetValue('CNEDETAIL','CNE_PRODUT'))
    Else
        cClientID := AllTrim(oModel:GetValue('CXNDETAIL','CXN_FORCLI'))
        cLoja       := AllTrim(oModel:GetValue('CXNDETAIL','CXN_LOJA'))
        cProductID  := AllTrim(oModel:GetValue('CNEDETAIL','CNE_PRODUT'))
    EndIf

ElseIf (cNFOperNF == "E")//(IsInCallStack("MATA101N") .or. IsInCallStack("MATA102N")  .OR. cNFEspecie == 'NCC')

    cSupplierID := M->F1_FORNECE
    cLoja       := M->F1_LOJA
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_COD')} )]


ElseIf (cNFOperNF == "S")//(IsInCallStack("MATA467N") .OR. IsInCallStack("MATA462N") .OR. cNFEspecie == 'NDC') 

    cClientID   := M->F2_CLIENTE
    cLoja       := M->F2_LOJA
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_COD')} )]

ElseIf (RU05XFN010_CheckModel(oModel, "RU05D01"))
    cClientID   := AllTrim(oModel:GetValue('F5YMASTER','F5Y_CLIENT'))
    cLoja       := AllTrim(oModel:GetValue('F5YMASTER','F5Y_BRANCH'))
    cProductID  := AllTrim(oModel:GetValue('F5ZDETAIL_AFTER','F5Z_ITMCOD'))
EndIf

If (!empty(AllTrim(cClientID)))

    aAreaSA1	:= SA1->(GetArea())
    dbSelectArea("SA1")
    dbSetOrder(1)

    If MsSeek(xFilial("SA1")+cClientID+cLoja)
        cCusTaxGrp      := SA1->A1_GRPTRIB
    EndIf

    RestArea(aAreaSA1)

EndIf

If (!empty(AllTrim(cSupplierID)))

    aAreaSA2	:= SA2->(GetArea())
    dbSelectArea("SA2")
    dbSetOrder(1)

    If MsSeek(xFilial("SA2")+cSupplierID+cLoja)
        cSupTaxGrp      := SA2->A2_GRPTRIB
    EndIf

    RestArea(aAreaSA2)

EndIf

If (!empty(AllTrim(cProductID)))

    aAreaSB1	:= SB1->(GetArea())
    dbSelectArea("SB1")
	dbSetOrder(1)

	If dbSeek(xFilial("SB1") + cProductID)
        cProdTaxGroup   := SB1->B1_GRTRIB
        cB1Grupo        := SB1->B1_GRUPO
    EndIf

    aAreaSBM	:= SBM->(GetArea())
    dbSelectArea("SBM")
	dbSetOrder(1)

    If dbSeek(xFilial("SBM") + cB1Grupo)
        cProdGrpType    := SBM->BM_TIPGRU
    EndIf

    RestArea(aAreaSB1)
    RestArea(aAreaSBM)

EndIf

/*  Search for a Smart TIO code that matches the conditions. 
    First we look for the code that fits in three parameters.
    If search did not find by the three parameters,
    look for matches by the two different parameters. 
*/

If  (!empty(AllTrim(cProdTaxGroup))    .and.;
    !empty(AllTrim(cProdGrpType))      .and.;
    (!empty(AllTrim(cSupTaxGrp))        .or.;
    !empty(AllTrim(cCusTaxGrp)) ))

    aAreaF51	:= F51->(GetArea())
    aAreaF50	:= F50->(GetArea())

    dbSelectArea("F51") 
    dbSetOrder(6)
    
    If dbSeek(xFilial("F51")+F50->F50_KEY+cProdTaxGroup+cProdGrpType+cSupTaxGrp+cCusTaxGrp)
        cRulesKey   := F51->F51_KEY
        ldbSeekHandler        := .T.
    EndIf

    If  !ldbSeekHandler
        dbSetOrder(7) 
        If dbSeek(xFilial("F51")+F50->F50_KEY+cProdGrpType+cSupTaxGrp+cCusTaxGrp)
            If (empty(AllTrim(F51->F51_PRDGRP)))
                cRulesKey   := F51->F51_KEY
                ldbSeekHandler        := .T.
            EndIf
        EndIf
    EndIf

    If  !ldbSeekHandler
        dbSetOrder(6)           
        If dbSeek(xFilial("F51")+F50->F50_KEY+cProdTaxGroup+cProdGrpType)
            If (empty(AllTrim(F51->F51_GRPSUP)) .and. empty(AllTrim(F51->F51_GRPCUS)) .and. empty(AllTrim(cSupTaxGrp)) .and. empty(AllTrim(F50->F50_TI)))
                cRulesKey   := F51->F51_KEY
                ldbSeekHandler        := .T.
            ElseIf (empty(AllTrim(F51->F51_GRPSUP)) .and. empty(AllTrim(F51->F51_GRPCUS)) .and. empty(AllTrim(cCusTaxGrp)) .and. empty(AllTrim(F50->F50_TO)))
                cRulesKey   := F51->F51_KEY
                ldbSeekHandler        := .T.
            EndIf
        EndIf
    EndIf

    RestArea(aAreaF51)
    RestArea(aAreaF50)

EndIf 

If (!empty(AllTrim(cRulesKey)))
    Return (.T.)
Else
    Return (.F.)
EndIf


/*/{Protheus.doc} RU09XTIOTrigger
Filter for the Standard Query for Smart TIO
@author Konstantin Cherchik
@since 04/11/2018
@version P12.1.20
@type function
/*/
Function RU09XTIOTrigger(nCaller as Numeric) 

Local aAreaSA1          as Array
Local aAreaSA2          as Array
Local aAreaSB1          as Array
Local aAreaSBM          as Array
Local aAreaF51          as Array
Local aAreaF50          as Array
Local cAliasF51         as Character
Local cQuery            as Character
Local cSupplierID       as Character
Local cClientID         as Character
Local cProductID        as Character
Local cLoja             as Character
Local cProdTaxGroup     as Character 
Local cProdGrpType      as Character
Local cSupTaxGrp        as Character
Local cCusTaxGrp        as Character
Local cB1Grupo          as Character
Local cRulesKey         as Character
Local cCurField         as Character 
Local cCNBOper          as Character
Local cNFTipoNF         as Character
Local cNFOperNF         as Character
Local cNFEspecie        as Character
Local ldbSeekHandler    as Logical 
Local lTriggerHandler   as Logical
Local lCompra           as Logical
Local nTotal            as Numeric
Local nHOper            as Numeric
Local oModel            as Object


cProdTaxGroup   :=  Space(TamSX3("F51_PRDGRP")[1])
cSupTaxGrp      :=  Space(TamSX3("F51_GRPSUP")[1])
cCusTaxGrp      :=  Space(TamSX3("F51_GRPCUS")[1])
cProdGrpType    :=  Space(TamSX3("F51_TPPRD ")[1])

cNFTipoNF  := Iif(MaFisFound(), MaFisRet(, "NF_TIPONF"), "")
cNFOperNF  := Iif(MaFisFound(), MaFisRet(, "NF_OPERNF"), "")
cNFEspecie := Iif(MaFisFound(), MaFisRet(, "NF_ESPECIE"), "")

ldbSeekHandler  := .F.
lTriggerHandler := .F. 

/* Get the necessary information to determine the Smart TIO code, depending on the source. */ 

If (IsInCallStack("MATA121"))

    If !(empty(aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C7_OPER')} )]))
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C7_TES')} )] := Space(TamSX3("C7_TES")[1])
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C7_CF')} )] := Space(TamSX3("C7_CF")[1])
    EndIf 

    cSupplierID := M->CA120FORN
    cLoja       := M->CA120LOJ
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C7_PRODUTO')} )]

ElseIf (IsInCallStack("CNTA300RUS"))

    If (IsInCallStack("CN300ALTER"))

        oModel      := FWModelActive()
        lCompra	    := CN300RetSt("COMPRA",0,oModel:GetModel('CNADETAIL'):GetValue('CNA_NUMERO'),oModel:GetModel('CN9MASTER'):GetValue('CN9_NUMERO'))

        If lCompra
            cCNBOper    := AllTrim(oModel:GetValue('CNBDETAIL','CNB_OPER'))

            If !(empty(cCNBOper))
                oModel:GetModel("CNBDETAIL"):LoadValue("CNB_TE",Space(TamSX3("CNB_TE")[1]))
                oModel:GetModel("CNBDETAIL"):LoadValue("CNB_CF",Space(TamSX3("CNB_CF")[1]))
            EndIf

            cSupplierID := AllTrim(oModel:GetValue('CNADETAIL','CNA_FORNEC'))
            cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LJFORN'))
            cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))
        Else
            cCNBOper    := AllTrim(oModel:GetValue('CNBDETAIL','CNB_OPER'))

            If !(empty(cCNBOper))
                oModel:GetModel("CNBDETAIL"):LoadValue("CNB_TS",Space(TamSX3("CNB_TS")[1]))
                oModel:GetModel("CNBDETAIL"):LoadValue("CNB_CF",Space(TamSX3("CNB_CF")[1]))
            EndIf

            cClientID   := AllTrim(oModel:GetValue('CNADETAIL','CNA_CLIENT'))
            cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LOJACL'))
            cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))
        EndIf

    ElseIF (IsInCallStack("CN300InCOM"))

        oModel      := FWModelActive()
        cCNBOper    := AllTrim(oModel:GetValue('CNBDETAIL','CNB_OPER'))

        If !(empty(cCNBOper))
            oModel:GetModel("CNBDETAIL"):LoadValue("CNB_TE",Space(TamSX3("CNB_TE")[1]))
            oModel:GetModel("CNBDETAIL"):LoadValue("CNB_CF",Space(TamSX3("CNB_CF")[1]))
        EndIf

        cSupplierID := AllTrim(oModel:GetValue('CNADETAIL','CNA_FORNEC'))
        cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LJFORN'))
        cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))

    ElseIF (IsInCallStack("CN300InVEN"))

        oModel      := FWModelActive()
        cCNBOper    := AllTrim(oModel:GetValue('CNBDETAIL','CNB_OPER'))

        If !(empty(cCNBOper))
            oModel:GetModel("CNBDETAIL"):LoadValue("CNB_TS",Space(TamSX3("CNB_TS")[1]))
            oModel:GetModel("CNBDETAIL"):LoadValue("CNB_CF",Space(TamSX3("CNB_CF")[1]))
        EndIf

        cClientID   := AllTrim(oModel:GetValue('CNADETAIL','CNA_CLIENT'))
        cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LOJACL'))
        cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))

    EndIf

ElseIf (IsInCallStack("CNTA121RUS")) 

    oModel      := FWModelActive()
    lCompra	    := CN300RetSt("COMPRA",0,oModel:GetModel('CXNDETAIL'):GetValue('CXN_NUMPLA'),oModel:GetModel("CNDMASTER"):GetValue("CND_CONTRA"))

    cCNBOper    := AllTrim(oModel:GetValue('CNEDETAIL','CNE_OPER'))

    If !(empty(cCNBOper))
        oModel:GetModel("CNEDETAIL"):LoadValue("CNE_TES",Space(Max(TamSX3("CNE_TE")[1],TamSX3("CNE_TS")[1])))
        oModel:GetModel("CNEDETAIL"):LoadValue("CNE_CF",Space(TamSX3("CNB_CF")[1]))
    EndIf

    If lCompra
        cSupplierID   := AllTrim(oModel:GetValue('CXNDETAIL','CXN_FORCLI'))
        cLoja       := AllTrim(oModel:GetValue('CXNDETAIL','CXN_LOJA')) 
        cProductID  := AllTrim(oModel:GetValue('CNEDETAIL','CNE_PRODUT'))
    Else
        cClientID := AllTrim(oModel:GetValue('CXNDETAIL','CXN_FORCLI'))
        cLoja       := AllTrim(oModel:GetValue('CXNDETAIL','CXN_LOJA'))
        cProductID  := AllTrim(oModel:GetValue('CNEDETAIL','CNE_PRODUT'))
    EndIf

ElseIf (IsInCallStack("A410INCLUI") .Or. IsInCallStack("A410ALTERA") .Or. IsInCallStack("A410COPIA")) .And. ! IsInCallStack("CN130MANUT")

    If !(empty(aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C6_OPER')} )]))
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C6_TES')} )] := Space(TamSX3("C6_TES")[1])
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C6_CF')} )] := Space(TamSX3("C6_CF")[1])
    EndIf

    If !EMPTY(AllTrim(M->C5_TIPO)) .And. AllTrim(M->C5_TIPO)=='B'
        cSupplierID := M->C5_CLIENTE
    Else
        cClientID   := M->C5_CLIENTE
    EndIf
    cLoja       := M->C5_LOJACLI
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C6_PRODUTO')} )]

ElseIf (cNFOperNF == "E") .And. ! IsInCallStack("CN130MANUT")

    If !(empty(aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_OPER')} )]))
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_TES')} )] := Space(TamSX3("D1_TES")[1])
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_CF')} )] := Space(TamSX3("D1_CF")[1])
    EndIf

    cSupplierID := M->F1_FORNECE
    cLoja       := M->F1_LOJA
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_COD')} )]


ElseIf (cNFOperNF == "S") .And. ! IsInCallStack("CN130MANUT")

    If !(empty(aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_OPER')} )]))
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_TES')} )] := Space(TamSX3("D2_TES")[1])
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_CF')} )] := Space(TamSX3("D2_CF")[1])
    EndIf

    cClientID   := M->F2_CLIENTE
    cLoja       := M->F2_LOJA 
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_COD')} )]

EndIf

If (!empty(AllTrim(cClientID)))

    aAreaSA1	:= SA1->(GetArea())
    dbSelectArea("SA1")
    dbSetOrder(1)

    If MsSeek(xFilial("SA1")+cClientID+cLoja)
        cCusTaxGrp      := SA1->A1_GRPTRIB
    EndIf

    RestArea(aAreaSA1)

EndIf

If (!empty(AllTrim(cSupplierID)))

    aAreaSA2	:= SA2->(GetArea())
    dbSelectArea("SA2")
    dbSetOrder(1)

    If MsSeek(xFilial("SA2")+cSupplierID+cLoja)
        cSupTaxGrp      := SA2->A2_GRPTRIB
    EndIf

    RestArea(aAreaSA2)

EndIf 

If (!empty(AllTrim(cProductID)))

    aAreaSB1	:= SB1->(GetArea())
    dbSelectArea("SB1")
	dbSetOrder(1)

	If dbSeek(xFilial("SB1") + cProductID)
        cProdTaxGroup   := SB1->B1_GRTRIB
        cB1Grupo        := SB1->B1_GRUPO
    EndIf

    aAreaSBM	:= SBM->(GetArea())
    dbSelectArea("SBM")
	dbSetOrder(1)

    If dbSeek(xFilial("SBM") + cB1Grupo)
        cProdGrpType    := SBM->BM_TIPGRU
    EndIf

    RestArea(aAreaSB1)
    RestArea(aAreaSBM)

EndIf

/*  
    Search for a Smart TIO code that matches the conditions. 
    First we look for the code that fits in three parameters.
    If search did not find by the three parameters,
    look for matches by the two different parameters. 
    We set the value of the Smart TIO code only if we found one suitable Smart TIO code.
*/

If  (!empty(AllTrim(cProdTaxGroup))    .and.;
    !empty(AllTrim(cProdGrpType))      .and.;
    (!empty(AllTrim(cSupTaxGrp))        .or.;
    !empty(AllTrim(cCusTaxGrp)) ))      .And.;
    !IsBlind()

    aAreaF50	:= F50->(GetArea())
    cAliasF51   := GetNextAlias()
    cQuery      := "SELECT * FROM " + RetSqlName("F51") + " "
    cQuery      += "WHERE F51_FILIAL = '" + xFilial("F51") + "' "
    cQuery      += "AND F51_PRDGRP = '" + cProdTaxGroup + "' "
    cQuery      += "AND F51_TPPRD = '" + cProdGrpType + "' "
    cQuery      += "AND F51_GRPSUP = '" + cSupTaxGrp + "' "
    cQuery      += "AND F51_GRPCUS = '" + cCusTaxGrp + "' "
    cQuery      += "AND D_E_L_E_T_ = ' '"

    If select(cAliasF51) > 0
        cAliasF51->(DbCloseArea())
    Endif

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasF51,.T.,.T.)
    dbSelectArea(cAliasF51)
    If !((cAliasF51)->(Eof()))
            COUNT to nTotal
            dbGoTop()
            If (nTotal == 1)
                dbSelectArea("F50")
                dbSetOrder(1)
                If dbSeek(xFilial("F50")+((cAliasF51)->F51_KEY))
                    cRulesKey           := F50->F50_CODE
                    ldbSeekHandler      := .T.
                EndIf

            EndIf
    EndIf

    If !ldbSeekHandler
        cAliasF51   := GetNextAlias()
        cQuery      := "SELECT * FROM " + RetSqlName("F51") + " "
        cQuery      += "WHERE F51_FILIAL = '" + xFilial("F51") + "' "
        cQuery      += "AND F51_PRDGRP = '" + Space(TamSX3("C6_CF")[1]) + "' "
        cQuery      += "AND F51_TPPRD = '" + cProdGrpType + "' "
        cQuery      += "AND F51_GRPSUP = '" + cSupTaxGrp + "' "
        cQuery      += "AND F51_GRPCUS = '" + cCusTaxGrp + "' "
        cQuery      += "AND D_E_L_E_T_ = ' '"

        If select(cAliasF51) > 0
            cAliasF51->(DbCloseArea())
        Endif

        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasF51,.T.,.T.)
        dbSelectArea(cAliasF51)
        If !((cAliasF51)->(Eof()))
            COUNT to nTotal
            dbGoTop()
            If (nTotal == 1)
                dbSelectArea("F50")
                dbSetOrder(1)
                If dbSeek(xFilial("F50")+((cAliasF51)->F51_KEY))
                    cRulesKey           := F50->F50_CODE
                    ldbSeekHandler      := .T.
                EndIf

            EndIf
        EndIf
    EndIf

    If !ldbSeekHandler
        cAliasF51   := GetNextAlias()
        cQuery      := "SELECT * FROM " + RetSqlName("F51") + " "
        cQuery      += "WHERE F51_FILIAL = '" + xFilial("F51") + "' "
        cQuery      += "AND F51_PRDGRP = '" + cProdTaxGroup + "' "
        cQuery      += "AND F51_TPPRD = '" + cProdGrpType + "' "
        cQuery      += "AND D_E_L_E_T_ = ' ' "
        cQuery      += "AND F51_KEY IN (SELECT F50_KEY FROM " + RetSqlName("F50") + " "
        cQuery      += "WHERE " + If(empty(AllTrim(cSupTaxGrp)),"F50_TI = '   ' ","F50_TO = '   ' ")
        cQuery      += "AND D_E_L_E_T_ = ' ')"

        If select(cAliasF51) > 0
            cAliasF51->(DbCloseArea())
        Endif

        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasF51,.T.,.T.)
        dbSelectArea(cAliasF51)
        If !((cAliasF51)->(Eof()))
            COUNT to nTotal
            dbGoTop()
            If (nTotal == 1)
                dbSelectArea("F50")
                dbSetOrder(1)
                If dbSeek(xFilial("F50")+((cAliasF51)->F51_KEY))
                    cRulesKey           := F50->F50_CODE
                    ldbSeekHandler      := .T. 
                EndIf

            EndIf
        EndIf
    EndIf

    If !ldbSeekHandler
        cRulesKey := ''
    EndIf

    RestArea(aAreaF50)
    If select(cAliasF51) > 0
        (cAliasF51)->(DbCloseArea())
    Endif
EndIf

/*
    Call the field validation functions manually, 
    because when values put into the field by trigger, 
    validation doesn't start automatically.
*/
If (.T. .and. !(empty(AllTrim(cRulesKey))))

    If (IsInCallStack("MATA121"))
        M->C7_OPER   := cRulesKey
        RUSmtCd(1,cRulesKey)
        RUSmtTio(1,cRulesKey)
    ElseIf (IsInCallStack("A410INCLUI") .Or. IsInCallStack("A410ALTERA") .Or. IsInCallStack("A410COPIA"))
        M->C6_OPER   := cRulesKey
    ElseIf (IsInCallStack("CNTA300RUS")) 
        If (IsInCallStack("CN300ALTER"))
            lCompra	    := CN300RetSt("COMPRA",0,oModel:GetModel('CNADETAIL'):GetValue('CNA_NUMERO'),oModel:GetModel('CN9MASTER'):GetValue('CN9_NUMERO'))
            oModel:GetModel("CNBDETAIL"):SetValue("CNB_OPER",cRulesKey)
            If lCompra
                RUSmtCd(1,cRulesKey)
                RUSmtTio(1,cRulesKey)  
            Else
                RUSmtCd(2,cRulesKey)
                RUSmtTio(2,cRulesKey)  
            EndIf
        ElseIf (IsInCallStack("CN300InCOM")) 
            oModel:GetModel("CNBDETAIL"):SetValue("CNB_OPER",cRulesKey)
            RUSmtCd(1,cRulesKey)
            RUSmtTio(1,cRulesKey)  
        ElseIf (IsInCallStack("CN300InVEN")) 
            oModel:GetModel("CNBDETAIL"):SetValue("CNB_OPER",cRulesKey)
        EndIf
    ElseIf (IsInCallStack("CNTA121RUS")) 
        oModel:GetModel("CNEDETAIL"):SetValue("CNE_OPER",cRulesKey)
        RUSmtTio(Iif(CN300RetSt("COMPRA",0,oModel:GetModel('CXNDETAIL'):GetValue('CXN_NUMPLA'),oModel:GetModel("CNDMASTER"):GetValue("CND_CONTRA")),1,2),cRulesKey)
        RUSmtCd(Iif(CN300RetSt("COMPRA",0,oModel:GetModel('CXNDETAIL'):GetValue('CXN_NUMPLA'),oModel:GetModel("CNDMASTER"):GetValue("CND_CONTRA")),1,2),cRulesKey)
    ElseIf (cNFOperNF == "E")//(IsInCallStack("MATA101N") .or. IsInCallStack("MATA102N") .OR. cNFEspecie == "NCC")
        M->D1_OPER   := cRulesKey
        RUSmtCd(1,cRulesKey)
        RUSmtTio(1,cRulesKey)
    ElseIf (cNFOperNF == "S")//(IsInCallStack("MATA467N") .OR. IsInCallStack("MATA462N") .OR. cNFEspecie == "NDC")
        M->D2_OPER   := cRulesKey 
        RUSmtCd(2,cRulesKey)
        RUSmtTio(2,cRulesKey)
    EndIf
ElseIf IsBlind()
        RUSmtCd(Iif(cNFOperNF == "E",1,2),cRulesKey)
        RUSmtTio(Iif(cNFOperNF == "E",1,2),cRulesKey)
Else
    If (IsInCallStack("MATA121"))
        MaFisRef("IT_TES","MT120",CriaVar("C7_TES"))
    ElseIf (IsInCallStack("MATA101N") .or. IsInCallStack("MATA102N"))
        MaFisRef("IT_TES","MT100",CriaVar("D1_TES")) 
    EndIf
EndIf

If cRulesKey == NIL 
    cRulesKey := " "
EndIf

Return cRulesKey


/*/{Protheus.doc} RUSmtTio
Function to return TIO Code
@author Konstantin Cherchik
@since 04/16/2018
@version P12.1.20
@type function
/*/
Function RUSmtTio(nOperType,cSmartCode)
Local cCurField     as Character
Local cCodeTIO      as Character
Local cCNBOper      as Character
Local cCNEOper      as Character
Local cNFTipoNF     as Character
Local cNFOperNF     as Character
Local cNFEspecie    as Character
Local aAreaF50	    as Array
Local lRet          as Logical
Local lCompra       as Logical
Local oModel        as Object
Local nPos          as Numeric

DEFAULT nOperType   := 0
DEFAULT cCodeTIO    :=  Space(TamSX3("F50_TI")[1])

aAreaF50	    := F50->(GetArea())
lRet            := .T.

cNFTipoNF := Iif(MaFisFound(), MaFisRet(, "NF_TIPONF"), "")
cNFOperNF := Iif(MaFisFound(), MaFisRet(, "NF_OPERNF"), "")
cNFEspecie:= Iif(MaFisFound(), MaFisRet(, "NF_ESPECIE"), "")

/* If validation function was called automatically, we need to store Operation tipe value. */

If (empty(AllTrim(cSmartCode)) .and. (!empty(M->C7_OPER)))
    cSmartCode := M->C7_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. (!empty(M->D1_OPER)))
    cSmartCode := M->D1_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. (!empty(M->C6_OPER)))
    cSmartCode := M->C6_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. (!empty(M->D2_OPER)))
    cSmartCode := M->D2_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. ((IsInCallStack("CN300InCOM")) .Or. (IsInCallStack("CN300InVEN")) .Or. (IsInCallStack("CN300ALTER"))))

    oModel      := FWModelActive()
    cCNBOper    := AllTrim(oModel:GetValue('CNBDETAIL','CNB_OPER'))

    If (!empty(cCNBOper) .and. !empty(M->CNB_OPER))
        cSmartCode := M->CNB_OPER 
    EndIf

ElseIf (empty(AllTrim(cSmartCode)) .and. (IsInCallStack("CNTA121RUS")))

    oModel      := FWModelActive()
    cCNEOper    := AllTrim(oModel:GetValue('CNEDETAIL','CNE_OPER'))

    If (!empty(cCNEOper) .and. !empty(M->CNE_OPER))
        cSmartCode := M->CNE_OPER 
    EndIf

EndIf 

If (!empty(AllTrim(cSmartCode)))

    dbSelectArea("F50")
    dbSetOrder(2)
    dbSeek(xFilial("F50")+cSmartCode)
    While(F50->(!Eof()) .And. xFilial("F50")+cSmartCode=xFilial("F50")+F50->F50_CODE)  
        If (nOperType == 1)
            cCodeTIO := F50->F50_TI
        ElseIf (nOperType == 2)
            cCodeTIO := F50->F50_TO
        EndIf
        If(!Empty(cCodeTIO))
            Exit
        EndIf
        F50->(DbSkip())
    EndDo
EndIf 

/*
    Because the validation function puts value of cCodeTIO in the fields automatically,
    it is need to simulate entering these values, as if they were inserted manually.
    To run validation of these fields.
*/
If lRet

    cCurField := __ReadVar
    SX3->(dbSetOrder(2))

    If (IsInCallStack("MATA121"))
        __ReadVar := "C7_OPER"
        If SX3->(dbSeek("C7_TES "))
            cCurField   := "M->C7_TES"
            M->C7_TES   := cCodeTIO
            __ReadVar   := cCurField
            &(SX3->X3_VALID)    
            MaFisAlt("IT_TES", cCodeTIO, N)
        EndIf

        __ReadVar   := "C7_PRODUTO"
    ElseIf (IsInCallStack("A410INCLUI") .Or. IsInCallStack("A410ALTERA") .Or. IsInCallStack("A410COPIA"))
        __ReadVar := "C6_OPER"
        If SX3->(dbSeek("C6_TES "))
            cCurField   := "M->C6_TES"
            M->C6_TES   := cCodeTIO
             __ReadVar   := cCurField
            &(SX3->X3_VALID)
            MaFisAlt("IT_TES", cCodeTIO, N)
        
        EndIf

        __ReadVar   := "C6_PRODUTO"
    ElseIf (IsInCallStack("CNTA300RUS"))

        If (IsInCallStack("CN300ALTER"))
            oModel      := FWModelActive()
            lCompra	    := CN300RetSt("COMPRA",0,oModel:GetModel('CNADETAIL'):GetValue('CNA_NUMERO'),oModel:GetModel('CN9MASTER'):GetValue('CN9_NUMERO'))
            
            If lCompra
                oModel:GetModel("CNBDETAIL"):SetValue("CNB_TE",cCodeTIO)
            Else
                oModel:GetModel("CNBDETAIL"):SetValue("CNB_TS",cCodeTIO)
            EndIf

        ElseIf (IsInCallStack("CN300InCOM")) 

            oModel      := FWModelActive()
            oModel:GetModel("CNBDETAIL"):SetValue("CNB_TE",cCodeTIO)

        ElseIf (IsInCallStack("CN300InVEN")) 

            oModel      := FWModelActive()
            oModel:GetModel("CNBDETAIL"):SetValue("CNB_TS",cCodeTIO)

        EndIf
    ElseIf (IsInCallStack("CNTA121RUS")) 

        oModel      := FWModelActive()
        oModel:GetModel("CNEDETAIL"):SetValue("CNE_TES",cCodeTIO)
        oModel:GetModel("CNEDETAIL"):LoadValue("CNE_TES",cCodeTIO)

    ElseIf (cNFOperNF == "E")//(IsInCallStack("MATA101N") .or. IsInCallStack("MATA102N") .OR. cNFEspecie == "NCC")
        If !IsBlind()
            __ReadVar := "D1_OPER"
            If SX3->(dbSeek("D1_TES "))
                cCurField   := "M->D1_TES"
                M->D1_TES   := cCodeTIO
                __ReadVar   := cCurField
                &(SX3->X3_VALID)    
                MaFisAlt("IT_TES", cCodeTIO, N)
            __ReadVar   := "D1_COD"
            EndIf
        Else    // (02/10/19): Seek value in autogeneration array  
            cCodeTIO := RU09XFUN01_ValueByField("D1_TES")
            MaFisAlt("IT_TES", cCodeTIO, N)
        EndIf
    
    ElseIf (cNFOperNF == "S")//(IsInCallStack("MATA467N") .OR. IsInCallStack("MATA462N") .OR. cNFEspecie == "NDC")
        If !IsBlind()
            __ReadVar := "D2_OPER"
            If SX3->(dbSeek("D2_TES "))
                cCurField   := "M->D2_TES"
                M->D2_TES   := cCodeTIO
                __ReadVar   := cCurField
                &(SX3->X3_VALID)
                MaFisAlt("IT_TES", cCodeTIO, N)
            EndIf
            __ReadVar   := "D2_COD"
        Else    // (02/10/19): Seek value in autogeneration array
            cCodeTIO := RU09XFUN01_ValueByField("D2_TES")
            MaFisAlt("IT_TES", cCodeTIO, N)
        EndIf
    EndIf

EndIf

RestArea(aAreaF50)

Return (cCodeTIO)


/*/{Protheus.doc} RUSmtCd
Function to return VAT Code 
@author Konstantin Cherchik
@since 04/16/2018
@version P12.1.20
@type function
/*/ 
Function RUSmtCd(nOperType,cSmartCode)
Local cCurField     as Character                                
Local cCodeVAT      as Character
Local cCNBOper      as Character
Local cCNEOper      as Character
Local cNFTipoNF     as Character
Local cNFOperNF     as Character
Local cNFEspecie    as Character
Local lRet          as Logical
Local lCompra       as Logical
Local aAreaF50      as Array
Local oModel        as Object

DEFAULT nOperType   := 0 
DEFAULT cCodeVAT    :=  Space(TamSX3("F50_VCI")[1])

aAreaF50	    := F50->(GetArea())
lRet            := .T.

cNFTipoNF := Iif(MaFisFound(), MaFisRet(, "NF_TIPONF"), "")
cNFOperNF := Iif(MaFisFound(), MaFisRet(, "NF_OPERNF"), "")
cNFEspecie:= Iif(MaFisFound(), MaFisRet(, "NF_ESPECIE"), "")

If (empty(AllTrim(cSmartCode)) .and. (!empty(M->C7_OPER))) 
    cSmartCode := M->C7_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. (!empty(M->D1_OPER)))
    cSmartCode := M->D1_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. (!empty(M->C6_OPER)))
    cSmartCode := M->C6_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. (!empty(M->D2_OPER)))
    cSmartCode := M->D2_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. ((IsInCallStack("CN300InCOM")) .Or. (IsInCallStack("CN300InVEN")) .Or. (IsInCallStack("CN300ALTER"))))

    oModel      := FWModelActive()
    cCNBOper    := AllTrim(oModel:GetValue('CNBDETAIL','CNB_OPER'))

    If (!empty(cCNBOper) .and. !empty(M->CNB_OPER))
        cSmartCode := M->CNB_OPER
    EndIf
ElseIf (empty(AllTrim(cSmartCode)) .and. (IsInCallStack("CNTA121RUS")))

    oModel      := FWModelActive()
    cCNEOper    := AllTrim(oModel:GetValue('CNEDETAIL','CNE_OPER'))

    If (!empty(cCNEOper) .and. !empty(M->CNE_OPER))
        cSmartCode := M->CNE_OPER 
    EndIf
EndIf

If (!empty(AllTrim(cSmartCode)))

    dbSelectArea("F50")
    dbSetOrder(2)    
    dbSeek(xFilial("F50")+cSmartCode)
    While(F50->(!Eof()) .And. xFilial("F50")+cSmartCode=xFilial("F50")+F50->F50_CODE)
        If (nOperType == 1) 
            cCodeVAT := F50->F50_VCI 
        ElseIf (nOperType == 2)
            cCodeVAT := F50->F50_VCO
        EndIf
        If(!Empty(cCodeVAT))
            Exit
        EndIf
        F50->(DbSkip())
    EndDo
EndIf

/*
    Because the validation function puts value of cCodeTIO in the fields automatically,
    it is need to simulate entering these values, as if they were inserted manually.
    To run validation of these fields.
*/
If lRet

    cCurField   := __ReadVar
    SX3->(dbSetOrder(2))    

    If (IsInCallStack("MATA121"))
        __ReadVar := "C7_OPER"
        If SX3->(dbSeek("C7_CF "))
            cCurField   := "M->C7_CF"
            M->C7_CF   := cCodeVAT
            __ReadVar   := cCurField           
            &(SX3->X3_VALID)   
            MaFisAlt("IT_CF", cCodeVAT, N) 
        EndIf

        __ReadVar   := "C7_PRODUTO"
    ElseIf (IsInCallStack("A410INCLUI") .Or. IsInCallStack("A410ALTERA") .Or. IsInCallStack("A410COPIA"))
        __ReadVar := "C6_OPER"
        If SX3->(dbSeek("C6_CF "))
            cCurField   := "M->C6_CF"
            M->C6_CF   := cCodeVAT
            __ReadVar   := cCurField
            &(SX3->X3_VALID)
            MaFisAlt("IT_CF", cCodeVAT, N)
        EndIf

        __ReadVar   := "C6_PRODUTO"
    ElseIf ((IsInCallStack("CN300InCOM")) .Or. (IsInCallStack("CN300InVEN")) .Or. (IsInCallStack("CN300ALTER")))

        oModel := FWModelActive()
        oModel:GetModel("CNBDETAIL"):SetValue("CNB_CF",cCodeVAT)

    ElseIf (IsInCallStack("CNTA121RUS"))

        oModel := FWModelActive()
        oModel:GetModel("CNEDETAIL"):SetValue("CNE_CF",cCodeVAT)
    ElseIf (cNFOperNF == "E")//(IsInCallStack("MATA101N") .or. IsInCallStack("MATA102N") .OR. cNFEspecie == "NCC")
        If !IsBlind()
            __ReadVar := "D1_OPER"
            If SX3->(dbSeek("D1_CF "))
                cCurField   := "M->D1_CF"
                M->D1_CF   := cCodeVAT
                __ReadVar   := cCurField
                &(SX3->X3_VALID)    
                MaFisAlt("IT_CF", cCodeVAT, N)
            EndIf
            __ReadVar   := "D1_COD"
        Else
            cCodeVAT := RU09XFUN01_ValueByField("D1_CF")
            MaFisAlt("IT_CF", cCodeVAT, N)
        EndIf
    ElseIf (cNFOperNF == "S")//(IsInCallStack("MATA467N") .OR. IsInCallStack("MATA462N") .OR. cNFEspecie == "NDC")
        If !IsBlind()
            __ReadVar := "D2_OPER"
            If SX3->(dbSeek("D2_CF "))
                cCurField   := "M->D2_CF"
                M->D2_CF   := cCodeVAT
                __ReadVar   := cCurField
                &(SX3->X3_VALID)
                MaFisAlt("IT_CF", cCodeVAT, N) 
            EndIF
            __ReadVar   := "D2_COD"
        Else
            cCodeVAT := RU09XFUN01_ValueByField("D2_CF")
            MaFisAlt("IT_CF", cCodeVAT, N)
        EndIf
    EndIf
EndIf

RestArea(aAreaF50)

Return (cCodeVAT)


/*/{Protheus.doc} RU09XFUNCFValid
Function for validation of C6_CF field in MATA410 
@author Konstantin Cherchik
@since 04/26/2018
@version P12.1.20
@type function
/*/ 
Function RU09XFUNCFValid(cFiscalCode)
Local nHOper    as Numeric
Local lRet      as Logical
Local cOperType as Character
Local cCurField as Character

DEFAULT lRet        := .F.
DEFAULT cOperType   := Space(TamSX3("F50_CODE")[1])

cOperType   := M->C6_OPER
If Empty(cOperType) .And. Type("aHeader") == "A" .And. Type("aCols") == "A"
    nHOper      := AScan(aHeader, {|x| AllTrim(x[2]) == "C6_OPER"})
    If !Empty(nHOper)
        cOperType   := aCols[N, nHOper] 
        M->C6_OPER  := cOperType
    EndIf
EndIf

If ((!(empty(AllTrim(cOperType))) .And. !(empty(AllTrim(cFiscalCode)))) .Or. ((empty(AllTrim(cOperType))) .And. (empty(AllTrim(cFiscalCode)))))
    lRet := .T.
EndIf

Return lRet


/*/{Protheus.doc} RU09XFUNHelp
The function of notifying the user,
to do not forget to check the tax codes after
he changed the supplier or the customer
@author Konstantin Cherchik
@since 04/26/2018
@version P12.1.20
@type function
/*/ 
Function RU09XFUNHelp() 
Local lRet          as Logical
Local cProductCode  as Character
Local cNFTipoNF     as Character
Local cNFOperNF     as Character
Local cNFEspecie    as Character
Local oModel        as Object

DEFAULT lRet           := .T.

cNFTipoNF := Iif(MaFisFound(), MaFisRet(, "NF_TIPONF"), "")
cNFOperNF := Iif(MaFisFound(), MaFisRet(, "NF_OPERNF"), "")
cNFEspecie:= Iif(MaFisFound(), MaFisRet(, "NF_ESPECIE"), "")

cProductCode := ""

If (IsInCallStack("MATA121"))

    cProductCode  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C7_PRODUTO')} )]


ElseIf (IsInCallStack("A410INCLUI") .Or. IsInCallStack("A410ALTERA") .Or. IsInCallStack("A410COPIA"))

    cProductCode  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C6_PRODUTO')} )]

ElseIf (IsInCallStack("CNTA121RUS"))

    oModel  := FWModelActive() 

    cProductCode  := AllTrim(oModel:GetValue('CNEDETAIL','CNE_PRODUT'))    


ElseIf ((IsInCallStack("CN300InCOM")) .Or. (IsInCallStack("CN300InVEN"))  .Or. (IsInCallStack("CN300ALTER")))

    oModel  := FWModelActive() 

    cProductCode  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))
ElseIF (cNFOperNF == "E")//(IsInCallStack("MATA101N") .or. IsInCallStack("MATA102N") .OR. cNFEspecie == "NCC")

    cProductCode  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_COD')} )]

ElseIf (cNFOperNF == "S")//(IsInCallStack("MATA467N") .OR. IsInCallStack("MATA462N") .OR. cNFEspecie == "NDC")

    cProductCode  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_COD')} )]

EndIf

If (!(empty(AllTrim(cProductCode))))

    MsgInfo(" " + STR0001  + " ")

EndIf

Return lRet


/*/{Protheus.doc} RU09XFUNCntType
The function to determine which
type of contract, purchase or sales contract.
    True  - Purchase
    False - Sales
Used in CNTA300, trigger for CNB_OPER.
@author Konstantin Cherchik
@since 08/27/2018
@version P12.1.21
@type function
@return Boolean
/*/ 

Function RU09XFUNCntType (cCNANumero, cCN9Numero)
Local lRet  as Logical
Local cType as Character
Local nMode as Numeric

DEFAULT lRet := .T.

cType := "COMPRA"
nMode := 0

lRet	    := CN300RetSt(cType,nMode,cCNANumero,cCN9Numero)

Return lRet


/*/{Protheus.doc} RU09XFUNWrapCntType
The support function for RU09XFUNCntType
to avoid the problem with 40 symbols
of x7_condic parameter in triggers.
Used in CNTA300, trigger for CNB_OPER.
@author Konstantin Cherchik
@since 08/27/2018
@version P12.1.21
@type function
@return RU09XFUNCntType()
/*/ 

Function RU09XFUNWrapCntType()

Return RU09XFUNCntType(FwFldGet("CNA_NUMERO"),FwFldGet("CN9_NUMERO"))


/*/{Protheus.doc} RU09XFUN01_ValueByField
Function returns value of filds from autogeneration array
@author Velmozhnya Alexandra
@since 03/10/2019
@version P12.1.27
@type function
@return Value of cField
/*/ 
Function RU09XFUN01_ValueByField(cField)
Local cRet      as Character    // Returned value 
Local nPos      as Numeric      // Position in aAutoItens

cRet := ''

If !Empty(cField)
    If ValType(aAutoItens) == "A" .and. !Empty(aAutoItens[1])
        nPos := aScan(aAutoItens[1],{|x| AllTrim(x[1]) == (cField) } )
        cRet := Iif(nPos > 0 ,aAutoItens[n][nPos][2] , Space(TamSX3(cField)[1]))
    Else
        cRet := Space(TamSX3(cField)[1])
    EndIf
EndIf

Return cRet


Function RU09XFUN02_OpenCommercialinvoice(oView As Object, cType As Character)
Local lRet      as Logical
Local aArea     as Array
Local aAreaHead as Array
Local aAreaDet  as Array
Local aTmpMenu  as Array
Local oRootModel    as Object
Local oMdlHead  as Object
Local cDocSer   as Character

Private aRotina as Array

aArea := GetArea()
lRet := .T.

If (ValType(oView) != "O")
	lRet := .F.
End

If (lRet)
    oRootModel := oView:GetModel():oFormModel
    lRet := lRet .and. RU05XFN010_CheckModel(oRootModel, "RU05D01")
EndIf

If (lRet)
oMdlHead := oRootModel:getModel("F5YMASTER")
Do Case
    Case cType == "B"
        cDocSer := oMdlHead:GetValue("F5Y_DOCORI") + oMdlHead:GetValue("F5Y_SERORI")
    Case cType == "I"
        cDocSer := oMdlHead:GetValue("F5Y_DOCDEB") + oMdlHead:GetValue("F5Y_SERDEB")
        lRet := lRet .and. !Empty(oMdlHead:GetValue("F5Y_DOCDEB"))
    Case cType == "D"
        cDocSer := oMdlHead:GetValue("F5Y_DOCCRD") + oMdlHead:GetValue("F5Y_SERCRD")
        lRet := lRet .and. !Empty(oMdlHead:GetValue("F5Y_DOCCRD"))
EndCase
EndIf

If (lRet)
    //if click was on before model record it is necessary to identify type of original document
    cType := Iif(oMdlHead:GetValue("F5Y_ORIGIN") == "2" .And. cType == "B","U",cType)

    aTmpMenu := AClone(aRotina)
    aRotina	:=	{{"","",0,2,0,Nil},;
                {"","",0,2,0,Nil},;
                {"","",0,2,0,Nil},;
                {"","",0,2,0,Nil}}

    Do Case
        Case cType $ "BI"
            aAreaHead := SF2->(GetArea())
            aAreaDet:= SD2->(GetArea())

            DbSelectArea("SF2")
            SF2->(DbSetOrder(1))
            
            If (SF2->(DbSeek(xFilial('SF2') + cDocSer + oMdlHead:GetValue("F5Y_CLIENT") + oMdlHead:GetValue("F5Y_BRANCH"))))
                CtbDocSaida()	// open View SF2/SD2
            EndIf
        Case cType == "D"
            aAreaHead := SF1->(GetArea())
            aAreaDet:= SD1->(GetArea())
            DbSelectArea("SF1")
            SF1->(DbSetOrder(1))
            
            If (SF1->(DbSeek(xFilial('SF1')+ cDocSer + oMdlHead:GetValue("F5Y_CLIENT") + oMdlHead:GetValue("F5Y_BRANCH"))))
                CtbDocEnt()	//open View of SF1/SD1
            EndIf
        Case cType == "U"
            aAreaHead := F5Y->(GetArea())
            aAreaDet:= F5Z->(GetArea())
            DBSelectArea("F5Y")
            DBSetOrder(2)
            If (F5Y->(DBSeek(FWxFilial("F5Y") + oMdlHead:GetValue("F5Y_CLIENT") + oMdlHead:GetValue("F5Y_BRANCH") +cDocSer)))
                FWExecView(STR0002,"RU05D01",MODEL_OPERATION_VIEW) //"Unified Logistics Correction Document"
            EndIf
    EndCase
    RestArea(aAreaDet)
    RestArea(aAreaHead)

    aRotina := AClone(aTmpMenu)
EndIf
RestArea(aArea)
Return Nil


/*/{Protheus.doc} RU09XFUN03_F35_TYPE_ComboBox
Returns combobox for F35_TYPE field
@author Ivanov Alexander
@since 05/02/2019
@version P12.1.27
@type function
@return combobox
/*/ 
Function RU09XFUN03_F35_TYPE_ComboBox()
    Local aItems as Array
	aItems := {STR0003, STR0004, STR0005, STR0006, STR0007}
Return RU99XFUN04_MakeCombo(aItems)

/*/{Protheus.doc} RU09XFUN05_ViewCanActivate
Make common changes for oView object for VAT routines.
@author artem.kostin
@since 30.03.2020
@version P12.1.30
@type	function
@return	lRet, process flow control
/*/ 
Function RU09XFUN05_ViewCanActivate(oView as Object)
// Process control
Local lRet			as logical
// Operation number
Local nOperation	as Numeric
// model object
Local oModel		as Object
Local cModelId		as Character
// view structures
Local oStructF35	as Object
Local oStructF36	as Object
Local oStructF5P	as Object
// arrays of removed fields
Local aRmF35		as Array
Local aRmF36		as Array
Local aRmF5P		as Array

lRet		:= .T.
nOperation	:= oView:GetOperation()
oStructF35	:= oView:GetViewStruct("F35_M")
oStructF36	:= oView:GetViewStruct("F36_D")
oStructF5P	:= oView:GetViewStruct("F5P_D")

aRmF35		:= {"F35_IDATE ", "F35_CURR  ", "F35_VATVL ", "F35_VALGR ", "F35_VATBS ", "F35_VATCOD", "F35_VATVL1", "F35_VATBS1", "F35_BOOKEY", "F35_CONTRA"}
aRmF36		:= {"F36_FILIAL", "F36_KEY   ", "F36_DOCKEY", "F36_TYPE  ", "F36_DOC   ", "F36_EXC_V1", "F36_VATVS1", "F36_EXC_V1", "F36_DTLA  ", "F36_INVCUR", "F36_CLIENT", "F36_BRANCH"} //F36_INVDOC;F36_INVSER;F36_DESC"
aRmF5P		:= {"F5P_KEY   "}

RU09XFUN06_RemoveFields(oStructF35, aRmF35)
RU09XFUN06_RemoveFields(oStructF36, aRmF36)
RU09XFUN06_RemoveFields(oStructF5P, aRmF5P)

oModel := oView:GetModel()
lRet := lRet .and. RU05XFN010_CheckModel(oModel, oModel:GetId())
If (lRet .and. !(cModelId $ "RU09T07"))
	RU09XFUN06_RemoveFields(oStructF35, {"F35_VTCD2D", "F35_SAVEPB"})
EndIf

If (nOperation == MODEL_OPERATION_INSERT)
	// removes fields from F35 structure
	oStructF35:RemoveField("F35_DOC")
	oStructF35:RemoveField("F35_BOOK")
	// removes fields from F36 structure
	oStructF36:RemoveField("F36_DOC")
EndIf
Return lRet

/*/{Protheus.doc} RU09XFUN06_RemoveFields
Removes fields by name from array from the given structure.
@author artem.kostin
@since 30.03.2020
@version P12.1.30
@type	function
@return	lRet, process flow control
/*/ 
Function RU09XFUN06_RemoveFields(oStruct as Object, aFields as Array)
// iterators
Local nI	as Numeric

If (ValType(oStruct) == "O")
	For nI := 1 to len(aFields)
		oStruct:RemoveField(aFields[nI])
	Next nI
EndIf
Return

/*{Protheus.doc} RU09XFUN07_F35_CONUNI_ComboBox
@description Use conventional units (Yes\No) combobox creation
@author alexander.ivanov
@since 26/05/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09XFUN07_F35_CONUNI_ComboBox()
    Local aItems as Array
	aItems := {STR0008, STR0009}
Return RU99XFUN04_MakeCombo(aItems)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09XFUN08_ClsTaxRate 
    old RUXXNF201_ClsTaxRate
Function takes TaxAmount, TaxBase, calculates:
CalcTaxRate = (TaxAmount/TaxBase)*100 and look for closest Tax rate 
to CalcTaxRate in F30 table, and returns Tax rate from F30 table.
TaxRates with  "/" like 18/118 or 10/110 will be passed during search
process
Function returns 0 in next cases:
1) We found closest tax rate equls to 0
2) nTaxBase == 0 or input parameters are not NUMERIC
3) F30_RATE field doesn't contain a value which we can convert to NUMERIC
4) F30 table is empty

@param       NUMERIC nTaxAmnt {0..max}
             NUMERIC nTaxBase {0..max}
@return      NUMERIC nRet     {0..max}
@example     
@author      astepanov
@since       November/15/2018
@version     1.0
@project     MA3
@see         FI-CF-23-5 (3.2.3)
/*/
//-----------------------------------------------------------------------
Function RU09XFUN08_ClsTaxRate(nTaxAmnt,nTaxBase)

	Local   nRet     AS NUMERIC
	Local   CalTxRat AS NUMERIC
	Local   TaxRate  AS NUMERIC
	Local   aAreaF30 AS ARRAY
	Local   Differ   AS NUMERIC
	Default nTaxAmnt := 0
	Default nTaxBase := 1

	If VALTYPE(nTaxAmnt) == "N" .and.;
	VALTYPE(nTaxBase) == "N" .and.;
	nTaxBase          != 0

		CalTxRat := (nTaxAmnt / nTaxBase) * 100
		nRet := 0
		Differ := 99999999 //8 characters

		aAreaF30 := F30->(GetArea())
		DbSelectArea("F30")
		F30->(DbSetOrder(1))
		F30->(DbGoTop())

		While ! F30->(EoF())
			If "/" $ F30->F30_RATE 
				F30->(DbSkip())
				Loop
			Else
				TaxRate := VAL(F30->F30_RATE)
				If Abs(TaxRate - CalTxRat) < Differ
					Differ := Abs(TaxRate - CalTxRat)
					nRet   := TaxRate
				EndIf
			EndIf
		F30->(DbSkip())
		EndDo

		RestArea(aAreaF30)
	Else
		nRet := 0
	EndIf

Return nRet




//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09XFUN09_Aux_mata461TaxSC6_TO_SD2 
Auxiliary function responsible for transporting values from tax fields positioned in table SC6 to table SD2 in Russian font due to the request of the product owner

@param       
             
@return      
@example     
@author      eduardo.Flima
@since       14/12/2020
@version     1.0
@project     MA3
/*/
//-----------------------------------------------------------------------
Function RU09XFUN09_Aux_mata461TaxSC6_TO_SD2()
	SD2->D2_ALQIMP1  := SC6->C6_ALQIMP1
	SD2->D2_BASIMP1  := SC6->C6_BASIMP1
	SD2->D2_VALIMP1  := SC6->C6_VALIMP1
Return .T.
