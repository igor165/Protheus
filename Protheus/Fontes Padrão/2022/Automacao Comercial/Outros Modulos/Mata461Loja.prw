#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} LjxjPvlSd2
Rotina para atualizar os valores de impostos a partir dos valores gerados pelo loja.
Utilizada na emisão de documento de saída.
Uso MaPvl2Sd2 - Trecho retirado do fonte MATA461

@author	 Rafael Tenorio da Costa
@since 	 12/04/19
@version 1.0
/*/
//------------------------------------------------------------------
Function LjxjPvlSd2(nItem, aRateio)

    Local aArea         := GetArea()
    Local aAreaSL2      := SL2->( GetArea() )
    Local lERakuten     := SuperGetMV("MV_LJECOMM", , .F.)      //Integração E-commerce Rakuten Antiga
    Local lECCia        := SuperGetMv("MV_LJECOMO", , .F.)      //Integração E-commerce CiaShop Antiga
    Local lLJTDESI      := SuperGetMv("MV_LJTDESI", , 0) == 1        //Parametro para controlar o tipo de desconto na integração 0 = desligado padrao, 1 = desconto no valor bruto IPI(cabeçalho) 
    Local lTesBruto     := Iif(GetAdvFVal("SF4","F4_TPIPI",xFilial("SF4")+SF4->F4_CODIGO,1,"") == "B",.T.,.F. )
    Local nTamSL2Ite    := TamSx3("L2_ITEM")[1]                 //Tamanho do campo L2_ITEM
    Local nTamSL2Pro    := TamSx3("L2_PRODUTO")[1]              //Tamanho do campo L2_PRODUTO
    Local nTamSD2Des    := TamSx3("D2_DESCON")[2]               //Quantidade decimal D2_DESCON
    Local cChaveSL2     := ""
    Local cFiltroSL1    := ""   //Filtro da SL1
    Local nECBaseIPI    := 0    //Base do IPI
    Local nECVlrIPI     := 0    //Valor do IPI
    Local nECVlIPI2     := 0    //Valor do IPi alterado
    Local nECVlMerc     := 0    //Valor da Mercadoria
    Local nEcValor      := 0    //Valor do Item do e-commerce
    Local cAliSL2       := ""   //Alias da SL2

    //aRateio - Utilizado no MATA461
    #DEFINE RT_DESCONT  08
    #DEFINE RT_PRECOIT  09
    #DEFINE RT_PDESCON  10

    //Integrações e-commerce Rakuten e CiaShop Antigas Victorinox
    If lERakuten .Or. lECCia .or. (lTesBruto .and. lLJTDESI)

        //---Trecho retirado o fonte MATA461
        If !Empty(SC5->C5_PEDECOM)

            //Verifica se Existe alteração no valor do IPI
            nECBaseIPI  := MaFisRet(nItem, "IT_BASEIPI")    //Base do IPI
            nECVlrIPI   := MaFisRet(nItem, "IT_VALIPI" )    //Valor do IPI
            nECVlMerc   := MaFisRet(nItem, "IT_VALMERC") -  MaFisRet(nItem,"IT_DESCONTO") + Round(aRateio[RT_DESCONT] + aRateio[RT_PDESCON], nTamSD2Des)    //Valor da mercadoria, exceto o desconto na condição

            If nECBaseIPI > 0 .And. nECVlrIPI > 0
            
                cAliSL2    := GetNextAlias()

                cFiltroSL1 := " SELECT (L2_ECVALOR / L2_QUANT) ECUNIT  "
                cFiltroSL1 +=   " FROM "  + RetSqlName("SL2") + " SL2,  "+ RetSqlName("SL1") + " SL1 "
                cFiltroSL1 += " WHERE 	SL2.L2_ITEM  = '" + PadR(SC6->C6_ITEM, nTamSL2Ite) +  "' AND SL1.L1_NUM = SL2.L2_NUM "
                cFiltroSL1 +=   " AND  SL2.D_E_L_E_T_ = ' ' AND SL2.L2_FILIAL = '" + xFilial("SL2") + "' "
                cFiltroSL1 +=   " AND  SL1.L1_PEDRES = '" + Alltrim(SC5->C5_NUM) + "' AND  SL1.D_E_L_E_T_  = ' ' AND SL1.L1_FILIAL = '" + xFilial("SL1") + "' "

                dbUseArea(.T., "TOPCONN", TCGENQRY(,,cFiltroSL1),cAliSl2, .F., .T.)

                nEcValor := (cAliSl2)->ECUNIT * SC9->C9_QTDLIB 

                If (cAliSl2)->(!Eof()) .AND. nEcValor > 0 
                    //O campo L2_ECVALOR Somente é gravado pela integração e-commerce CiaShop e caso a funcionalidade de ajuste de IPI esteja habilitada MV_LJECMMA
                    //e somente eh ajustado em itens tributados pelo IPI
                    If (nECVlMerc + nECVlrIPI) <> nEcValor 
                        
                        nECVlIPI2 := NoRound(nEcValor - nECVlMerc,2)

                        If nECVlIPI2 <> nECVlrIPI .AND. nECVlIPI2 > 0
                            MaFisAlt("IT_VALIPI", nECVlIPI2, nItem, .T.)    //Força a atualização da Base do IPI
                        EndIf
                    EndIf

                EndIf
                (cAliSl2)->(DbCloseArea())
            EndIf

        EndIf
    EndIf

    RestArea(aAreaSL2)
    RestArea(aArea)

Return Nil
