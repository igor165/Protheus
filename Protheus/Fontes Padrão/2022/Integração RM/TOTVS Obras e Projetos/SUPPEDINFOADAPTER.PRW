#include 'totvs.ch'
#include 'parmtype.ch'

//-------------------------------------------------------------------
/*/
    Baseado na documentação em: https://tdn.totvs.com/display/framework/09.+FWAdapterBaseV2
/*/
//-------------------------------------------------------------------
CLASS OrderAdapter FROM FWAdapterBaseV2
    METHOD New()
    METHOD GetListOrders()
EndClass
 
Method New( cVerb ) CLASS OrderAdapter
    _Super:New( cVerb, .T. )
return
 
Method GetListOrders( cFilter, cType) CLASS OrderAdapter
    Local aArea     AS ARRAY
    Local cWhere    AS CHAR
    aArea   := FwGetArea()
    
    AddMapFields( self, cType )
    
    ::SetQuery( GetQuery(cType) )

    if cType == "1"
        cWhere := " SC7.C7_FILIAL = '"+ FWxFilial('SC7') +"' AND SC7.D_E_L_E_T_ = ' '" 
        cWhere += " AND SC7.C7_NUM IN ("+ cFilter +")" 
        
        ::SetOrder( "C7_NUM" )
    Else
        cWhere := " SC5.C5_FILIAL = '"+ FWxFilial('SC5') +"' AND SC5.D_E_L_E_T_ = ' '" 
        cWhere += " AND SC5.C5_NUM IN ("+ cFilter +")" 
        
        ::SetOrder( "C5_NUM" )
    EndIF

    ::SetWhere( cWhere )
   
    //Executa a consulta, se retornar .T. tudo ocorreu conforme esperado
    If ::Execute()
        // Gera o arquivo Json com o retorno da Query
        ::FillGetResponse()
    EndIf

    FwrestArea(aArea)
Return
 
Static Function AddMapFields( oSelf, cType )
    If cType == "1"
        oSelf:AddMapFields( 'ORDERNUMBER', 'C7_NUM', .T., .T., {'C7_NUM', TamSX3( 'C7_NUM' )[3], TamSX3( 'C7_NUM' )[1], TamSX3( 'C7_NUM' )[2] })
        oSelf:AddMapFields( 'ORDERITEM', 'C7_ITEM' , .T., .F., {'C7_ITEM', TamSX3( 'C7_ITEM' )[3], TamSX3( 'C7_ITEM' )[1], TamSX3( 'C7_ITEM' )[2] })		
        oSelf:AddMapFields( 'ITEMCODE', 'C7_PRODUTO', .T., .F., {'C7_PRODUTO',TamSX3( 'C7_PRODUTO' )[3],TamSX3( 'C7_PRODUTO' )[1],TamSX3( 'C7_PRODUTO' )[2] })	
        oSelf:AddMapFields( 'ITEMUNITOFMEASURE', 'C7_UM', .T., .F., {'C7_UM', TamSX3( 'C7_UM' )[3], TamSX3( 'C7_UM' )[1], TamSX3( 'C7_UM' )[2] })
        oSelf:AddMapFields( 'REGISTERDATE', 'C7_EMISSAO', .T., .F., {'C7_EMISSAO',TamSX3( 'C7_EMISSAO' )[3],TamSX3( 'C7_EMISSAO' )[1],TamSX3( 'C7_EMISSAO' )[2] })
        oSelf:AddMapFields( 'ORDERQUANTITY', 'C7_QUANT', .T., .F., {'C7_QUANT', TamSX3( 'C7_QUANT' )[3], TamSX3( 'C7_QUANT' )[1], TamSX3( 'C7_QUANT' )[2] })
        oSelf:AddMapFields( 'ORDERUNITPRICE', 'C7_PRECO', .T., .F., {'C7_PRECO', TamSX3( 'C7_PRECO' )[3], TamSX3( 'C7_PRECO' )[1], TamSX3( 'C7_PRECO' )[2] })
        oSelf:AddMapFields( 'ORDERTOTALPRICE', 'C7_TOTAL', .T., .F., {'C7_TOTAL', TamSX3( 'C7_TOTAL' )[3], TamSX3( 'C7_TOTAL' )[1], TamSX3( 'C7_TOTAL' )[2] })
        oSelf:AddMapFields( 'QUANTITYDELIVERED', 'C7_QUJE' , .T., .F., {'C7_QUJE', TamSX3( 'C7_QUJE' )[3], TamSX3( 'C7_QUJE' )[1], TamSX3( 'C7_QUJE' )[2] })
        oSelf:AddMapFields( 'CLOSED', 'C7_ENCER', .T., .F., {'C7_ENCER', TamSX3( 'C7_ENCER' )[3], TamSX3( 'C7_ENCER' )[1], TamSX3( 'C7_ENCER' )[2] })
        oSelf:AddMapFields( 'WASTEELIMINATED', 'C7_RESIDUO', .T., .F., {'C7_RESIDUO',TamSX3( 'C7_RESIDUO' )[3],TamSX3( 'C7_RESIDUO' )[1],TamSX3( 'C7_RESIDUO' )[2] })
        oSelf:AddMapFields( 'INVOICENUMBER', 'D1_DOC', .T., .F., {'D1_DOC', TamSX3( 'D1_DOC' )[3], TamSX3( 'D1_DOC' )[1], TamSX3( 'D1_DOC' )[2] })		
        oSelf:AddMapFields( 'INVOICEITEM', 'D1_ITEM' , .T., .F., {'D1_ITEM', TamSX3( 'D1_ITEM' )[3], TamSX3( 'D1_ITEM' )[1], TamSX3( 'D1_ITEM' )[2] })
        oSelf:AddMapFields( 'INVOICEQUANTITY', 'D1_QUANT', .T., .F., {'D1_QUANT', TamSX3( 'D1_QUANT' )[3], TamSX3( 'D1_QUANT' )[1], TamSX3( 'D1_QUANT' )[2] })
        oSelf:AddMapFields( 'INVOICEUNITPRICE', 'D1_VUNIT', .T., .F., {'D1_VUNIT', TamSX3( 'D1_VUNIT' )[3], TamSX3( 'D1_VUNIT' )[1], TamSX3( 'D1_VUNIT' )[2] })
        oSelf:AddMapFields( 'INVOICETOTALPRICE', 'D1_TOTAL', .T., .F., {'D1_TOTAL', TamSX3( 'D1_TOTAL' )[3], TamSX3( 'D1_TOTAL' )[1], TamSX3( 'D1_TOTAL' )[2] })
        oSelf:AddMapFields( 'INVOICEREGISTERDATE', 'D1_EMISSAO', .T., .F., {'D1_EMISSAO',TamSX3( 'D1_EMISSAO' )[3],TamSX3( 'D1_EMISSAO' )[1],TamSX3( 'D1_EMISSAO' )[2] })
    Else
        oSelf:AddMapFields( 'ORDERNUMBER', 'C5_NUM', .T., .T., {'C5_NUM', TamSX3( 'C5_NUM' )[3], TamSX3( 'C5_NUM' )[1], TamSX3( 'C5_NUM' )[2] })
        oSelf:AddMapFields( 'ORDERITEM', 'C6_ITEM' , .T., .F., {'C6_ITEM', TamSX3( 'C6_ITEM' )[3], TamSX3( 'C6_ITEM' )[1], TamSX3( 'C6_ITEM' )[2] })		
        oSelf:AddMapFields( 'ITEMCODE', 'C6_PRODUTO', .T., .F., {'C6_PRODUTO',TamSX3( 'C6_PRODUTO' )[3],TamSX3( 'C6_PRODUTO' )[1],TamSX3( 'C6_PRODUTO' )[2] })	
        oSelf:AddMapFields( 'ITEMUNITOFMEASURE', 'C6_UM', .T., .F., {'C6_UM', TamSX3( 'C6_UM' )[3], TamSX3( 'C6_UM' )[1], TamSX3( 'C6_UM' )[2] })
        oSelf:AddMapFields( 'REGISTERDATE', 'C5_EMISSAO', .T., .F., {'C5_EMISSAO',TamSX3( 'C5_EMISSAO' )[3],TamSX3( 'C5_EMISSAO' )[1],TamSX3( 'C5_EMISSAO' )[2] })
        oSelf:AddMapFields( 'ORDERQUANTITY', 'C6_QTDVEN', .T., .F., {'C6_QTDVEN', TamSX3( 'C6_QTDVEN' )[3], TamSX3( 'C6_QTDVEN' )[1], TamSX3( 'C6_QTDVEN' )[2] })
        oSelf:AddMapFields( 'ORDERUNITPRICE', 'C6_PRCVEN', .T., .F., {'C6_PRCVEN', TamSX3( 'C6_PRCVEN' )[3], TamSX3( 'C6_PRCVEN' )[1], TamSX3( 'C6_PRCVEN' )[2] })
        oSelf:AddMapFields( 'ORDERTOTALPRICE', 'C6_VALOR', .T., .F., {'C6_VALOR', TamSX3( 'C6_VALOR' )[3], TamSX3( 'C6_VALOR' )[1], TamSX3( 'C6_VALOR' )[2] })
        oSelf:AddMapFields( 'INVOICENUMBER', 'D2_DOC', .T., .F., {'D2_DOC', TamSX3( 'D2_DOC' )[3], TamSX3( 'D2_DOC' )[1], TamSX3( 'D2_DOC' )[2] })		
        oSelf:AddMapFields( 'INVOICEITEM', 'D2_ITEM' , .T., .F., {'D2_ITEM', TamSX3( 'D2_ITEM' )[3], TamSX3( 'D2_ITEM' )[1], TamSX3( 'D2_ITEM' )[2] })
        oSelf:AddMapFields( 'INVOICEQUANTITY', 'D2_QUANT', .T., .F., {'D2_QUANT', TamSX3( 'D2_QUANT' )[3], TamSX3( 'D2_QUANT' )[1], TamSX3( 'D2_QUANT' )[2] })
        oSelf:AddMapFields( 'INVOICEUNITPRICE', 'D2_PRCVEN', .T., .F., {'D2_PRCVEN', TamSX3( 'D2_PRCVEN' )[3], TamSX3( 'D2_PRCVEN' )[1], TamSX3( 'D2_PRCVEN' )[2] })
        oSelf:AddMapFields( 'INVOICETOTALPRICE', 'D2_TOTAL', .T., .F., {'D2_TOTAL', TamSX3( 'D2_TOTAL' )[3], TamSX3( 'D2_TOTAL' )[1], TamSX3( 'D2_TOTAL' )[2] })
        oSelf:AddMapFields( 'INVOICEREGISTERDATE', 'D2_EMISSAO', .T., .F., {'D2_EMISSAO',TamSX3( 'D2_EMISSAO' )[3],TamSX3( 'D2_EMISSAO' )[1],TamSX3( 'D2_EMISSAO' )[2] })
    EndIf            
return 

Static Function GetQuery( cType )
    Local cQuery AS CHARACTER

    If cType == "1"
        cQuery := " SELECT #QueryFields# "
        cQuery += "   FROM " + RetSqlName( 'SC7' ) + " SC7 "
        cQuery += "         LEFT JOIN " + RetSqlName( 'SD1' ) + " SD1 "
        cQuery += "   	      ON SD1.D1_PEDIDO = SC7.C7_NUM "
        cQuery += "   	     AND SD1.D1_ITEMPC = SC7.C7_ITEM "
        cQuery += "  WHERE #QueryWhere# "
    Else
        cQuery := " SELECT #QueryFields# "
        cQuery += "   FROM " + RetSqlName( 'SC5' ) + " SC5 "
        cQuery += "         JOIN " + RetSqlName( 'SC6' ) + " SC6 "
        cQuery += "   			  LEFT JOIN " + RetSqlName( 'SD2' ) + " SD2 "
        cQuery += "   				ON SD2.D2_FILIAL = SC6.C6_FILIAL "
        cQuery += "   			   AND SD2.D2_PEDIDO = SC6.C6_NUM "
        cQuery += "   			   AND SD2.D2_ITEMPV = SC6.C6_ITEM "
        cQuery += "   			   AND SD2.D_E_L_E_T_ = ' ' "
        cQuery += "   	      ON SC6.C6_FILIAL = SC5.C5_FILIAL "
        cQuery += "          AND SC6.C6_NUM = SC5.C5_NUM "
        cQuery += "  WHERE #QueryWhere# "
    EndIf
Return cQuery
