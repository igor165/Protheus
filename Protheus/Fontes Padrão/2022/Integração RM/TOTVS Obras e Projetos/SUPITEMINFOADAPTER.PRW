#include 'totvs.ch'
#include 'parmtype.ch'

//-------------------------------------------------------------------
/*/
    Criado com base na documentação em: https://tdn.totvs.com/display/framework/09.+FWAdapterBaseV2
/*/
//-------------------------------------------------------------------
CLASS ItemAdapter FROM FWAdapterBaseV2
    METHOD New()
    METHOD GetListItem()
EndClass
 
Method New( cVerb ) CLASS ItemAdapter
    _Super:New( cVerb, .T. )
return
 
Method GetListItem( cIniCod, cFimCod, iCampoMoeda) CLASS ItemAdapter
    Local aArea     AS ARRAY
    Local cWhere    AS CHAR
    aArea   := FwGetArea()
   
    //Adiciona o mapa de campos Json/ResultSet
    AddMapFields( self )
    FieldsCustoMedio( self, iCampoMoeda)

    //Informa a Query a ser utilizada pela API
    ::SetQuery( GetQuery() )
   
    //Informa a clausula Where da Query
    cWhere := " B1_FILIAL = '"+ FWxFilial('SB1') +"' AND SB1.D_E_L_E_T_ = ' '" 
    cWhere += " AND B1_COD >= '"+ cIniCod +"' AND B1_COD <= '"+ cFimCod +"'" 
    ::SetWhere( cWhere )
   
    //Informa a ordenação padrão a ser Utilizada pela Query
    ::SetOrder( "B1_COD" )
   
    //Executa a consulta, se retornar .T. tudo ocorreu conforme esperado
    If ::Execute()
        // Gera o arquivo Json com o retorno da Query
        ::FillGetResponse()
    EndIf

    FwrestArea(aArea)
Return
 
Static Function AddMapFields( oSelf)
    oSelf:AddMapFields( 'CODE'              , 'B1_COD'  , .T., .T., { 'B1_COD', 'C', TamSX3( 'B1_COD' )[1], 0 } )
    oSelf:AddMapFields( 'DESCRIPTION'       , 'B1_DESC' , .T., .F., { 'B1_DESC', 'C', TamSX3( 'B1_DESC' )[1], 0 } )
    oSelf:AddMapFields( 'UNITOFMEASURE'     , 'B1_UM',    .T., .F., { 'B1_UM', 'C', TamSX3( 'B1_UM' )[1], 0 } )
    oSelf:AddMapFields( 'GROUP'             , 'B1_GRUPO', .T., .F., { 'B1_GRUPO', 'C', TamSX3( 'B1_GRUPO' )[1], 0 } )
    oSelf:AddMapFields( 'GROUPDESCRIPTION'  , 'BM_DESC' , .T., .F., { 'BM_DESC', 'C', TamSX3( 'BM_DESC' )[1], 0 } )      
    oSelf:AddMapFields( 'PRICEONE'          , 'B1_PRV1' , .T., .F., { 'B1_PRV1',  TamSX3( 'B1_PRV1' )[3],  TamSX3( 'B1_PRV1' )[1],  TamSX3( 'B1_PRV1' )[2] } )
    oSelf:AddMapFields( 'PRICETWO'          , 'BZ_UPRC' , .T., .F., { 'BZ_UPRC',  TamSX3( 'BZ_UPRC' )[3],  TamSX3( 'BZ_UPRC' )[1],  TamSX3( 'BZ_UPRC' )[2] } )   
    oSelf:AddMapFields( 'COSTUNIT'          , 'BZ_CUSTD', .T., .F., { 'BZ_CUSTD', TamSX3( 'BZ_CUSTD' )[3], TamSX3( 'BZ_CUSTD' )[1], TamSX3( 'BZ_CUSTD' )[2]} )
return 

Static Function FieldsCustoMedio ( oSelf, iCampoMoeda)

    if iCampoMoeda == 1
        oSelf:AddMapFields( 'COSTAVERAGE', 'B2_CM1'  , .T., .F., { 'B2_CM1',   TamSX3( 'B2_CM1' )[3],   TamSX3( 'B2_CM1' )[1],   TamSX3( 'B2_CM1' )[2]  } ) 
    elseif iCampoMoeda == 2
        oSelf:AddMapFields( 'COSTAVERAGE', 'B2_CM2'  , .T., .F., { 'B2_CM2',   TamSX3( 'B2_CM2' )[3],   TamSX3( 'B2_CM2' )[1],   TamSX3( 'B2_CM2' )[2]  } ) 
    elseif iCampoMoeda == 3
        oSelf:AddMapFields( 'COSTAVERAGE', 'B2_CM3'  , .T., .F., { 'B2_CM3',   TamSX3( 'B2_CM3' )[3],   TamSX3( 'B2_CM3' )[1],   TamSX3( 'B2_CM3' )[2]  } ) 
    elseif iCampoMoeda == 4
        oSelf:AddMapFields( 'COSTAVERAGE', 'B2_CM4'  , .T., .F., { 'B2_CM4',   TamSX3( 'B2_CM4' )[3],   TamSX3( 'B2_CM4' )[1],   TamSX3( 'B2_CM4' )[2]  } ) 
    elseif iCampoMoeda == 5
        oSelf:AddMapFields( 'COSTAVERAGE', 'B2_CM5'  , .T., .F., { 'B2_CM5',   TamSX3( 'B2_CM5' )[3],   TamSX3( 'B2_CM5' )[1],   TamSX3( 'B2_CM5' )[2]  } )     
    endif
Return
 
Static Function GetQuery()
    Local cQuery AS CHARACTER

    cQuery := " SELECT #QueryFields# "
    cQuery += "   FROM " + RetSqlName( 'SB1' ) + " SB1 "
    cQuery += "           LEFT JOIN " + RetSqlName( 'SBM' ) + " SBM "
    cQuery += "             ON B1_GRUPO = BM_GRUPO "
    cQuery += "            AND BM_FILIAL = '"+ FWxFilial( 'SBM' ) +"'" 
    cQuery += "            AND SBM.D_E_L_E_T_ <> '*' "
    cQuery += "           LEFT JOIN " + RetSqlName( 'SBZ' ) + " SBZ "
    cQuery += "             ON SBZ.BZ_COD = SB1.B1_COD "
    cQuery += "           LEFT JOIN " + RetSqlName( 'SB2' ) + " SB2 "
    cQuery += "             ON SB2.B2_FILIAL = '"+ FWxFilial( 'SB2' ) +"'" 
    cQuery += "            AND SB2.B2_COD = SB1.B1_COD "
    cQuery += "            AND SB2.B2_LOCAL =SB1.B1_LOCPAD "
    cQuery += " WHERE #QueryWhere# "
 
Return cQuery
