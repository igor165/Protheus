#include 'totvs.ch'
#include 'parmtype.ch'

//-------------------------------------------------------------------
/*/
    Baseado na documentação em: https://tdn.totvs.com/display/framework/09.+FWAdapterBaseV2
/*/
//-------------------------------------------------------------------
CLASS ProductionOrderAdapter FROM FWAdapterBaseV2
    METHOD New()
    METHOD GetListProductionOrders()
EndClass
 
Method New( cVerb ) CLASS ProductionOrderAdapter
    _Super:New( cVerb, .T. )
return
 
Method GetListProductionOrders( cFilter) CLASS ProductionOrderAdapter
    Local aArea     AS ARRAY
    Local cWhere    AS CHAR
    aArea   := FwGetArea()
   
    //Adiciona o mapa de campos Json/ResultSet
    AddMapFields( self )

    //Informa a Query a ser utilizada pela API
    ::SetQuery( GetQuery() )
   
    //Informa a clausula Where da Query '000001','000002'
    cWhere := " SC2.C2_FILIAL = '"+ FWxFilial('SC2') +"' AND SC2.D_E_L_E_T_ = ' '" 
    cWhere += " AND SC2.C2_NUM IN ("+ cFilter +")" 
    ::SetWhere( cWhere )
   
    //Informa a ordenação padrão a ser Utilizada pela Query
    ::SetOrder( "C2_NUM" )
   
    //Executa a consulta, se retornar .T. tudo ocorreu conforme esperado
    If ::Execute()
        // Gera o arquivo Json com o retorno da Query
        ::FillGetResponse()
    EndIf

    FwrestArea(aArea)
Return
 
Static Function AddMapFields( oSelf)
  oSelf:AddMapFields( 'ORDERNUMBER'         , 'C2_NUM'    , .T., .T.,  {'C2_NUM',  TamSX3( 'C2_NUM' )[3],  TamSX3( 'C2_NUM' )[1], TamSX3( 'C2_NUM' )[2] })
  oSelf:AddMapFields( 'BRANCHID'           ,  'C2_FILIAL'   , .T., .T.,  {'C2_FILIAL',TamSX3( 'C2_FILIAL' )[3],  TamSX3( 'C2_FILIAL' )[1],  TamSX3( 'C2_FILIAL' )[2] })		
  oSelf:AddMapFields( 'ORDERITEM'           , 'C2_ITEM'   , .T., .T.,  {'C2_ITEM',TamSX3( 'C2_ITEM' )[3],  TamSX3( 'C2_ITEM' )[1],  TamSX3( 'C2_ITEM' )[2] })		
  oSelf:AddMapFields( 'SEQUENCE'            , 'C2_SEQUEN' , .T., .T.,  {'C2_SEQUEN',TamSX3( 'C2_SEQUEN' )[3],  TamSX3( 'C2_SEQUEN' )[1],  TamSX3( 'C2_SEQUEN' )[2] })	
  oSelf:AddMapFields( 'EXPECTEDSTARTDATE'   , 'C2_DATPRI' , .T., .F.,  {'C2_DATPRI', TamSX3( 'C2_DATPRI' )[3],  TamSX3( 'C2_DATPRI' )[1],  TamSX3( 'C2_DATPRI' )[2] })
  oSelf:AddMapFields( 'INTENDEDDELIVERYDATE', 'C2_DATPRF' , .T., .T.,  {'C2_DATPRF', TamSX3( 'C2_DATPRF' )[3],  TamSX3( 'C2_DATPRF' )[1],  TamSX3( 'C2_DATPRF' )[2] })
  oSelf:AddMapFields( 'PRIORITY'            , 'C2_PRIOR'  , .T., .F.,  {'C2_PRIOR', TamSX3( 'C2_PRIOR' )[3],  TamSX3( 'C2_PRIOR' )[1],  TamSX3( 'C2_PRIOR' )[2] })
  oSelf:AddMapFields( 'STATUS'              , 'C2_STATUS' , .T., .T.,  {'C2_STATUS', TamSX3( 'C2_STATUS' )[3],  TamSX3( 'C2_STATUS' )[1],  TamSX3( 'C2_STATUS' )[2] })
  oSelf:AddMapFields( 'INITIALADJUSTEDDATE' , 'C2_DATAJI' , .T., .F.,  {'C2_DATAJI', TamSX3( 'C2_DATAJI' )[3],  TamSX3( 'C2_DATAJI' )[1],  TamSX3( 'C2_DATAJI' )[2] })
  oSelf:AddMapFields( 'FINALADJUSTEDDATE'   , 'C2_DATAJF' , .T., .F.,  {'C2_DATAJF', TamSX3( 'C2_DATAJF' )[3],  TamSX3( 'C2_DATAJF' )[1],  TamSX3( 'C2_DATAJF' )[2] })
  oSelf:AddMapFields( 'OK'                  , 'C2_OK'     , .T., .F.,  {'C2_OK', TamSX3( 'C2_OK' )[3],  TamSX3( 'C2_OK' )[1],  TamSX3( 'C2_OK' )[2] })
return 
 
Static Function GetQuery()
    Local cQuery AS CHARACTER

    cQuery := " SELECT #QueryFields# "
    cQuery += "   FROM " + RetSqlName( 'SC2' ) + " SC2 "
    cQuery += "  WHERE #QueryWhere# "
 
Return cQuery
