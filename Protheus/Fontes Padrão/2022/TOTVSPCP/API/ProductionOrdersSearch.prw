#INCLUDE "TOTVS.CH" 
#INCLUDE "RESTFUL.CH"
#INCLUDE "PRODUCTIONORDERSSEARCH.CH"

WSRESTFUL productionordersearch DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Consulta Ordem de Produção"
    
    WSDATA Action                AS STRING  OPTIONAL    
    WSDATA AppointmentType       AS STRING  OPTIONAL
    WSDATA Count                 AS INTEGER OPTIONAL
    WSDATA FilterSearch          AS STRING  OPTIONAL
    WSDATA NumberOfReturnOrders  AS INTEGER OPTIONAL
    WSDATA OrderType             AS INTEGER OPTIONAL
    WSDATA Page    	             AS INTEGER OPTIONAL
    WSDATA PageSize              AS INTEGER OPTIONAL
    WSDATA SearchId              AS STRING  OPTIONAL
    WSDATA StartIndex            AS INTEGER OPTIONAL
    WSDATA User                  AS STRING  OPTIONAL
    WSDATA formCode              AS STRING  OPTIONAL

    WSDATA productCode        AS STRING  OPTIONAL
    WSDATA startDateRange     AS DATE    OPTIONAL
    WSDATA endDateRange       AS DATE    OPTIONAL
    WSDATA activityCode       AS STRING  OPTIONAL
    WSDATA warehouseCode      AS STRING  OPTIONAL
    WSDATA customerCode       AS STRING  OPTIONAL
    WSDATA customerOrderCode  AS STRING  OPTIONAL
    WSDATA machineCode        AS STRING  OPTIONAL
    WSDATA workCenterCode     AS STRING  OPTIONAL
    WSDATA isPlanned          AS BOOLEAN OPTIONAL
    WSDATA isOpened           AS BOOLEAN OPTIONAL
    WSDATA isStarted          AS BOOLEAN OPTIONAL
    WSDATA isIdle             AS BOOLEAN OPTIONAL
    WSDATA isPartiallyClosed  AS BOOLEAN OPTIONAL
    WSDATA isTotallyClosed    AS BOOLEAN OPTIONAL


    WSMETHOD GET lastappointments ;
		DESCRIPTION STR0002; //"Retorna as últimas ordens de produção apontadas por usuário"
		WSSYNTAX "/api/pcp/v1/lastappointments/{User}/{AppointmentType}/{NumberOfReturnOrders}" ;
		PATH "/api/pcp/v1/lastappointments" 
    
    WSMETHOD GET productionordermaster ;
		DESCRIPTION STR0009; //"Retorna lista de ordens de produção - consulta geral"
		WSSYNTAX "/api/pcp/v1/productionordermaster/{SearchId}/{AppointmentType}/{FilterSearch}/{OrderType}/{Action}/{Page}/{PageSize}/{User}/{formCode}" ;
		PATH "/api/pcp/v1/productionordermaster" 

    WSMETHOD GET searchid ;
		DESCRIPTION STR0010; //"Retorna ID para realizar a consulta das ordens produção"
		WSSYNTAX "/api/pcp/v1/searchid/{User}" ;
		PATH "/api/pcp/v1/searchid"
    
    WSMETHOD GET filtervalidation ;
		DESCRIPTION STR0011; //"Valida se é possível realizar a consulta com o filtro informado"
		WSSYNTAX "/api/pcp/v1/filtervalidation/{FilterSearch},{NumberOfReturnOrders}" ;
		PATH "/api/pcp/v1/filtervalidation" 

ENDWSRESTFUL

/*/{Protheus.doc} GET lastappointments /api/pcp/v1/lastappointments
Retorna as últimas ordens de produção apontadas
@type  WSMETHOD
@author michele.girardi
@since 30/08/2021
@version P12.1.33
@param User - Usuário que realizou o apontamento
@param AppointmentType - Tipo do apontamento (1 - Simples, 3 - MOD 2, 4 - SFC, 'BRANCO' - Todos Tipos, 9 - Automação estrutural SFC)
@param NumberOfReturnOrders - Quantidade de ordens a serem retornadas
@param machineCode - Código da máquina SFC
@return .T. ou .F.
/*/
WSMETHOD GET lastappointments WSRECEIVE User,AppointmentType,NumberOfReturnOrders,machineCode  WSSERVICE productionordersearch
	
    Local aOPs  := {}
    Local nI    := 0

	// define o tipo de retorno do método
    ::SetContentType("application/json")

    // define o tipo de retorno do método
    oJson := JsonObject():New()

    If Empty(::User)
	   SetRestFault(400, EncodeUTF8(STR0003)) //"Usuário não informado."
	   Return .F.
    EndIf
    
	If Empty(::NumberOfReturnOrders)
	   SetRestFault(400, EncodeUTF8(STR0004)) //"Quantidade de ordens a serem retornadas não informada."
	   Return .F.
	EndIf
    
    If !Empty(::AppointmentType)
        If  ::AppointmentType <> '0'  .And.; 
            ::AppointmentType <> '1'  .And.;
            ::AppointmentType <> '3' .And.;
            ::AppointmentType <> '4' .And.;
            ::AppointmentType <> '9' //Automação estrutural SFC
            SetRestFault(400, EncodeUTF8(STR0005)) 	//"Tipo do Apontamento inválido. Valores aceitos: 1 - Produção Simples | 3 - Produção Mod 2 | 4 - Produção Chão de Fábrica."
            Return .F.
        EndIf
    EndIf

    Default ::StartIndex := 1, ::PageSize := 20, ::Page := 1
    aOPs := {}        
    fCargaLast(::User, ::AppointmentType, ::NumberOfReturnOrders, @aOPs, ::machineCode)
    
    If Len(aOPs) > 0
        ::SetResponse('[')
        For nI := 1 To Len(aOPs)
            If nI > ::StartIndex
                ::SetResponse(',')
            EndIf
				
            oJson['ProductionOrderNumber'] := aOPs[nI,1]
			oJson['ItemCode'] := aOPs[nI,2]
             
            ::SetResponse(EncodeUTF8(oJson:toJson()))
        Next nI
        ::SetResponse(']') 
    Else
        SetRestFault(400, EncodeUTF8(STR0006)) 	//"Usuário não possui ordem de produção apontada."
        Return .F.
    EndIf
	
Return .T.

/*/{Protheus.doc} GET productionordermaster /api/pcp/v1/productionordermaster
Retorna lista de ordens de produção - consulta geral
@type  WSMETHOD
@author michele.girardi
@since 04/10/2021
@version P12.1.33
@param SearchId        - ID gerado para consulta
@param AppointmentType - Tipo do apontamento (1 - Simples, 3 - MOD 2, 4 - SFC, 'BRANCO' - Simples)
@param FilterSearch    - Filtro para consulta - Pode receber o Número da OP ou o Código do item
@param OrderType       - Ordenação da consulta - 1-OP, 2-Data de início ou 3-Produto
@param Action          - R - Reordenar | B - Buscar | P - Próxima página
@param Page            - Número da página para retornar a consulta
@param PageSize        - Tamanho da página para retornar a consulta
@param User            - Usuário que está realizando a consulta
@param formCode        - Código do formulário utilizado para chamar a API
@return .T. ou .F.
/*/
WSMETHOD GET productionordermaster;
QUERYPARAM productCode,startDateRange,endDateRange,activityCode,warehouseCode,customerCode,;
           customerOrderCode,machineCode,workCenterCode,isPlanned,isOpened,isStarted,isIdle,isPartiallyClosed,isTotallyClosed;
WSRECEIVE SearchId,AppointmentType,FilterSearch,OrderType,Action,Page,PageSize,User,formCode; 
WSSERVICE productionordersearch

    Local aOPs             := {}
    Local cAction          := ""
    Local cAppointmentType := ""    
    Local cFormCode        := ""
    Local cSearchId        := ""
    Local cUsersId         := ""
    Local lRet             := .T.
    Local nI               := 0
    Local nOrder           := 0
    Local nPage            := 1
    Local nPageSize        := 10

    Set(_SET_DATEFORMAT, 'dd/mm/yyyy') // Data com QUATRO digitos para Ano

	// define o tipo de retorno do método
    ::SetContentType("application/json")

    // define o tipo de retorno do método
    oJson := JsonObject():New()

    cAppointmentType := ::AppointmentType
    If Empty(cAppointmentType)
	   cAppointmentType := '1'
    EndIf

    nOrder := ::OrderType
    If Empty(nOrder) .Or. nOrder == 0
	   nOrder := 1
    EndIf

    nPage := ::Page
    If Empty(nPage) .Or. nPage == 0
	   nPage := 1
    EndIf

    nPageSize := ::PageSize
    If Empty(nPageSize) .Or. nPageSize == 0
	   nPageSize := 10
    EndIf

    cAction:= ::Action
    If Empty(cAction) 
	   cAction := "B"
    EndIf

    If cAppointmentType <> '0' .And.;
       cAppointmentType <> '1' .And.;
       cAppointmentType <> '3' .And.;
       cAppointmentType <> '4' .And.;
       cAppointmentType <> '9' //Automação estrutural SFC
        SetRestFault(400, EncodeUTF8(STR0005)) 	//"Tipo do Apontamento inválido. Valores aceitos: 1 - Produção Simples | 3 - Produção Mod 2 | 4 - Produção Chão de Fábrica."
        Return .F.
    EndIf

    If Empty(::FilterSearch) .And. cAction == "B"
	   SetRestFault(400, EncodeUTF8(STR0007)) //"Filtro da consulta não informado."
	   Return .F.
    EndIf

    If Empty(::SearchId)
	   SetRestFault(400, EncodeUTF8(STR0012)) //"ID da consulta não informado."
	   Return .F.
    EndIf

    If Empty(::User)
	   SetRestFault(400, EncodeUTF8(STR0003)) //"Usuário não informado."
	   Return .F.
    EndIf

    cUsersId := PCPCodUsr(::User)

    cSearchId := ::SearchId
    
    aOPs := {} 
    lUltimo := .F.

    //Verifica se a tabela enviada pelo cSearchId existe
    lRet := TCCanOpen(cSearchId)
    If !lRet
        SetRestFault(400, EncodeUTF8(STR0015)) //"ID da consulta inválida. Deve executar primeiramente o método searchid."
	    Return .F.
    EndIf

    If (cAction = 'B' .Or. cAction = 'A') .Or. !fExitReg(cSearchId)  //Carrega tabela se for Busca ou não existir registro na tabela
        cFormCode := ::formCode

        fDelTabAnt(cUsersId) //Apaga tabelas de processamento anteriores
        fDelTab(cSearchId) // Deleta registros existentes
        fCargaListOp(cAppointmentType, ::FilterSearch, cSearchId, cFormCode, cAction, ::productCode,::startDateRange,::endDateRange,::warehouseCode,::customerCode,::customerOrderCode,::activityCode,::machineCode,::workCenterCode,::isPlanned,::isOpened,::isStarted,::isIdle,::isPartiallyClosed,::isTotallyClosed) // Insere tabela
    EndIf

    If !fExitReg(cSearchId)
        SetRestFault(400, EncodeUTF8(STR0008)) 	//"Não existe ordem de produção cadastrada para o filtro informado."
        Return .F.
    EndIf

    fProcTab(cAppointmentType, cSearchId, nOrder, nPage, nPageSize, @aOps, @lUltimo) //Le tabela conforme paginação
 
    If Len(aOPs) > 0

        oJson['Items'] := {}
        
        For nI := 1 To Len(aOPs)            
            Aadd(oJson['Items'], JsonObject():New())
            oJson['Items'][nI]['ProductionOrderNumber'] := aOPs[nI,1]       //Ordem de Produção
			oJson['Items'][nI]['ItemCode']              := aOPs[nI,2]       //Produto
            oJson['Items'][nI]['ItemDescription']       := aOPs[nI,3]       //Decrição Produto
            oJson['Items'][nI]['Quantity']              := aOPs[nI,4]       //Qtd Prevista da Ordem de Produção
            oJson['Items'][nI]['ProductionQuantity']    := aOPs[nI,5]       //Qtd Produzida Ordem de Produção
            oJson['Items'][nI]['StartOrderCPDate']      := aOPs[nI,6]       //Data Início da Ordem de Produção - Previsto
            oJson['Items'][nI]['EndOrderCPDate']        := aOPs[nI,7]       //Dt Término da Ordem de Produção  - Previsto
            oJson['Items'][nI]['StartOrderDate']        := aOPs[nI,8]       //Dt Início da Ordem de Produção   - Real
            oJson['Items'][nI]['EndOrderDate']          := aOPs[nI,9]       //Dt Término da Ordem de Produção  - Real
            oJson['Items'][nI]['StatusOrderType']       := aOPs[nI,10]      //Status da Ordem de Produção
            oJson['Items'][nI]['Split']                 := aOPs[nI,11]      //Split
            oJson['Items'][nI]['ActivityCode']          := aOPs[nI,12]      //Código da operação
            oJson['Items'][nI]['ActivityDescription']   := aOPs[nI,13]      //Descrição da operação
            oJson['Items'][nI]['ActivityQuantity']      := aOPs[nI,14]      //Quantidade prevista do split/operação
            oJson['Items'][nI]['ReportQuantity']        := aOPs[nI,15]      //Quantidade Produzida do split/operação
            oJson['Items'][nI]['StartActivityDate']     := aOPs[nI,16]      //Data inicio do split/operação
            oJson['Items'][nI]['EndActivityDate']       := aOPs[nI,17]      //Data fim do split/operação
            oJson['Items'][nI]['ActivityID']            := aOPs[nI,18]      //ID da operação
            oJson['Items'][nI]['ScrappedQuantity']      := aOPs[nI,19]      //Quantidade perda
            oJson['Items'][nI]['WarehouseCode']         := aOPs[nI,20]      //Armazém
            oJson['Items'][nI]['UnitOfMeasureCode']     := aOPs[nI,21]      //Unidade de medida
            oJson['Items'][nI]['CustomerOrder']         := aOPs[nI,22]      //Número do pedido
            oJson['Items'][nI]['CustomerCode']          := aOPs[nI,23]      //Código do cliente
            oJson['Items'][nI]['CustomerShortName']     := aOPs[nI,24]      //Nome do cliente
                                                   
        Next nI

        oJson['hasNext'] := !lUltimo
        ::SetResponse(EncodeUTF8(oJson:toJson()))
    Else
        SetRestFault(400, EncodeUTF8(STR0008)) 	//"Não existe ordem de produção cadastrada para o filtro informado."
        Return .F.
    EndIf

Return .T.

/*/{Protheus.doc} GET productionorderid /api/pcp/v1/productionorderid
Retorna ID para realizar a consulta das ordens produção
@type  WSMETHOD
@author michele.girardi
@since 28/10/2021
@version P12.1.33
@param nil
@return .T. ou .F.
/*/
WSMETHOD GET searchid WSRECEIVE User WSSERVICE productionordersearch

    Local cId      := ''
    Local cUsersId := ''
    Local nId      := ThreadID()

    If Empty(::User)
	   SetRestFault(400, EncodeUTF8(STR0003)) //"Usuário não informado."
	   Return .F.
    EndIf

    cUsersId := PCPCodUsr(::User)

    cId := 'TC' + cValToChar(nId)
    fCriaTab(cId, cUsersId)
   
    // define o tipo de retorno do método
    ::SetContentType("application/json")
    oJson := JsonObject():New()

    ::SetResponse('[')
        
        oJson['SearchId'] := cId
        ::SetResponse(oJson:toJson())
    
    ::SetResponse(']') 

Return .T.

/*/{Protheus.doc} GET filtervalidation /api/pcp/v1/filtervalidation
Valida se é possível realizar a consulta com o filtro informado
@type  WSMETHOD
@author michele.girardi
@since 01/11/2021
@version P12.1.33
@param FilterSearch - Filtro de pesquisa
@param NumberOfReturnOrders - Limite da quantidade de Ordens de Produção
@return .T. ou .F.
/*/
WSMETHOD GET filtervalidation WSRECEIVE FilterSearch, NumberOfReturnOrders WSSERVICE productionordersearch

    Local nCount    := 0

    If Empty(::FilterSearch)
	   SetRestFault(400, EncodeUTF8(STR0007)) //"Filtro da consulta não informado."
	   Return .F.
    EndIf

    If Empty(::NumberOfReturnOrders)
	   SetRestFault(400, EncodeUTF8(STR0013)) //"Limite da quantidade de Ordens de Produção não informado."
	   Return .F.
    EndIf

    fValidSearch(::FilterSearch, @nCount)

    If nCount > 0 
        If nCount > ::NumberOfReturnOrders
            SetRestFault(400, EncodeUTF8(STR0014)) 	//"Filtro da consulta retornou muitas Ordens de Produção. Rever filtro para refinar a busca." 
            Return .F.
        Else
            // define o tipo de retorno do método
            ::SetContentType("application/json")
            oJson := JsonObject():New()

            ::SetResponse('[')
        
            oJson['Status'] := .T.
            ::SetResponse(oJson:toJson())
    
            ::SetResponse(']') 
        EndIf
    Else
        SetRestFault(400, EncodeUTF8(STR0008)) 	//"Não existe ordem de produção cadastrada para o filtro informado."
        Return .F.
    EndIf
    
Return .T.

/*/{Protheus.doc} Static Function fValidSearch
Valida consulta da OP para o filtro informado
@type  WSMETHOD
@author michele.girardi
@since 04/10/2021
@version P12.1.33
@param cFilterSearch - Filtro para consulta - Pode receber o Número da OP ou o Código do item
@param nCount - Quantidade de Ordens existentes para o Filtro informado
@return Nil
/*/
Static Function fValidSearch(cFilterSearch, nCount)
        
    Local cAliasValid := GetNextAlias()
    Local cCharSoma   := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ")
    Local cQuery      := ""    
    Local lExistItTo  := .F.
    Local lExistItPa  := .F.
    Local lExistOpCo  := .F.
    Local lExistOpPa  := .F.
    Local lEntrou     := .F.   
    
    Default nCount    := 0 

    If !Empty(cFilterSearch)
        lExistOpCo := fExistOp(cFilterSearch, 'OP', 'C') //Consula número OP completo
        
        If !lExistOpCo
            lExistOpPa := fExistOp(cFilterSearch, 'OP', 'P')  //Consulta número OP parcial - C2_NUM
        EndIf
    
        lExistItTo := fExistOp(cFilterSearch, 'IT', 'C') //Consulta código do item completo

        If !lExistItTo
            lExistItPa := fExistOp(cFilterSearch, 'IT', 'P') //Consulta código do item parcial
        EndIf
    EndIf

    If !lExistOpCo .And. !lExistOpPa .And. !lExistItTo .And. !lExistItPa
        nCount := 0 
        Return .T.
    EndIf

    cQuery := "  SELECT COUNT(*) COUNT "
	cQuery += "    FROM " + RetSqlName("SC2") + " SC2 " + "," + RetSqlName("SB1") + " SB1 " 
	cQuery += "   WHERE SC2.C2_FILIAL   = '" + xFilial( "SC2" ) + "'"
    cQuery += "     AND SB1.B1_FILIAL   = '" + xFilial( "SB1" ) + "'"
    cQuery += "     AND SC2.C2_PRODUTO  = SB1.B1_COD "
    cQuery += "     AND SC2.D_E_L_E_T_  = ' ' "
    cQuery += "     AND SB1.D_E_L_E_T_  = ' ' "

    If lExistOpCo .Or. lExistOpPa .Or. lExistItTo .Or. lExistItPa
        lEntrou := .F.
        cQuery += " AND ( "
    EndIf
    
    If lExistOpCo //Existe OP completa com o filtro da pesquisa    
        cQuery += " SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD  =  '" +cFilterSearch+ "'"	
        lEntrou := .T.
    Else
        If lExistOpPa //Existe OP parcial com o filtro da pesquisa
            If lEntrou
                cQuery += " OR "
            EndIf 
            cQuery += " SC2.C2_NUM = '" +cFilterSearch+ "'"
            lEntrou := .T.
        EndIf
    EndIf

    If lExistItTo //Existe Item completo com o filtro da pesquisa
        If lEntrou
            cQuery += " OR "
        EndIf 
        cQuery += " SC2.C2_PRODUTO = '" +cFilterSearch+ "'"
        lEntrou := .T.
    Else
        If lExistItPa
            If lEntrou
                cQuery += " OR "
            EndIf 
            cQuery += " SC2.C2_PRODUTO LIKE ( '%" + TRIM(cFilterSearch)+ "%' )"
            lEntrou := .T.
        EndIf
    EndIf

    If lExistOpCo .Or. lExistOpPa .Or. lExistItTo .Or. lExistItPa
        cQuery += " ) "
    EndIf
   
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasValid,.T.,.T.)
    If (cAliasValid)->(!Eof())		
		nCount :=  (cAliasValid)->COUNT
	EndIf
	(cAliasValid)->(DBCloseArea())

Return .T.

/*/{Protheus.doc} Static Function fProcTab
Processa registros da tabela para paginar e incluir no array aOps
@type  WSMETHOD
@author michele.girardi
@since 28/10/2021
@version P12.1.33
@param cSearchId  - Id da consulta
@param nOrder     - Ordenação da consulta - 1-OP, 2-Data de início ou 3-Produto
@param nPage      - Número da página para retornar a consulta
@param nPageSize  - Tamanho da página para retornar a consulta
@param aOps       - Array contendo os registros da consulta
@param lUltimo    - Indica existe mais registros para paginar
@return lRet
/*/
Static Function fProcTab(cAppointmentType, cSearchId, nOrder, nPage, nPageSize, aOps, lUltimo)
    
    Local cAliasJson  := GetNextAlias()
    Local cQuery      := ""
    Local nCount      := 0
    Local nStart      := 0
            
   //Varre tabela para paginar
    cQuery := "  SELECT TC_OP, "           
    cQuery += "         TC_COD, "    
    cQuery += "         TC_DESC, "   
    cQuery += "         TC_QUANT, "  
    cQuery += "         TC_QUJE, "   
    cQuery += "         TC_DATPRI, " 
    cQuery += "         TC_DATPRF, " 
    cQuery += "         TC_DATINI, " 
    cQuery += "         TC_DATRF, "  
    cQuery += "         TC_SITOP, "  
    cQuery += "         TC_SPLIT, "  
    cQuery += "         TC_OPER, "   
    cQuery += "         TC_DESCOPE, "
    cQuery += "         TC_QTPVOPE, "
    cQuery += "         TC_QTPDOPE, "
    cQuery += "         TC_DTINOPE, "
    cQuery += "         TC_DTFIOPE, "
    cQuery += "         TC_IDOPER, "
    cQuery += "         TC_PERDA, "
    cQuery += "         TC_ARMZ, "
    cQuery += "         TC_UM, "
    cQuery += "         TC_PEDIDO, "
    cQuery += "         TC_CODCLI, "
    cQuery += "         TC_NOMCLI, "
    cQuery += "         TC_MAQUINA, "
    cQuery += "         TC_CNTRTRB "
	cQuery += "    FROM " +cSearchId 

    If cAppointmentType $'3 | 4 | 9' //9 - Automação estrutural SFC 
        If nOrder == 1 //Ordenar por OP - ASC
            cQuery += " ORDER BY TC_OP, TC_SPLIT, TC_OPER "
        ElseIf nOrder == 51 //Ordenar por OP - DESC
            cQuery += " ORDER BY TC_OP DESC, TC_SPLIT DESC, TC_OPER DESC "
        ElseIf nOrder == 2 //Ordenar por Data de inicio REAL da Operação
            cQuery += " ORDER BY TC_DTINOPE, TC_OP, TC_SPLIT, TC_OPER "
        ElseIf nOrder == 52 //Ordenar por Data de inicio REAL da Operação - DESC
            cQuery += " ORDER BY TC_DTINOPE DESC, TC_OP DESC, TC_SPLIT DESC, TC_OPER DESC "
        ElseIf nOrder == 3 //Ordenar por Produto
            cQuery += " ORDER BY TC_COD, TC_OP, TC_SPLIT, TC_OPER "
        ElseIf nOrder == 53 //Ordenar por Produto - DESC
            cQuery += " ORDER BY TC_COD DESC, TC_OP DESC, TC_SPLIT DESC, TC_OPER DESC "
        EndIf
    Else
        If nOrder == 1 //Ordenar por OP
            cQuery += " ORDER BY TC_OP, TC_SPLIT, TC_OPER "
        ElseIf nOrder == 51 //Ordenar por OP - DESC
            cQuery += " ORDER BY TC_OP DESC, TC_SPLIT DESC, TC_OPER DESC "
        ElseIf nOrder == 2 //Ordenar por Data de inicio Prevista da OP
            cQuery += " ORDER BY TC_DATPRI, TC_OP, TC_SPLIT, TC_OPER "
        ElseIf nOrder == 52 //Ordenar por Data de inicio Prevista da OP - DESC
            cQuery += " ORDER BY TC_DATPRI DESC, TC_OP DESC, TC_SPLIT DESC, TC_OPER DESC "
        ElseIf nOrder == 3 //Ordenar por Produto
            cQuery += " ORDER BY TC_COD, TC_OP, TC_SPLIT, TC_OPER "
        ElseIf nOrder == 53 //Ordenar por Produto - DESC
            cQuery += " ORDER BY TC_COD DESC, TC_OP DESC, TC_SPLIT DESC, TC_OPER DESC "
        EndIf
    EndIf

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasJson,.T.,.T.)

    If nPage > 1 
       nStart := ( (nPage-1) * nPageSize )
       If nStart > 0
            (cAliasJson)->(DbSkip(nStart))
        EndIf
    EndIf

    While (cAliasJson)->(!Eof())

        nCount += 1

        aAdd(aOPs,{(cAliasJson)->TC_OP,;       //OP
                   (cAliasJson)->TC_COD,;      //Produto
                   (cAliasJson)->TC_DESC,;     //Descrição
                   (cAliasJson)->TC_QUANT,;    //Quantidade
                   (cAliasJson)->TC_QUJE,;     //Qtd Produzida
                   (cAliasJson)->TC_DATPRI,;   //Data Previsão INI
                   (cAliasJson)->TC_DATPRF,;   //Data Previsão FIM
                   (cAliasJson)->TC_DATINI,;   //Data INI Real
                   (cAliasJson)->TC_DATRF,;    //Data FIM Real
                   (cAliasJson)->TC_SITOP,;    //Situação OP
                   (cAliasJson)->TC_SPLIT,;    //SPLIT
                   (cAliasJson)->TC_OPER,;     //Operação
                   (cAliasJson)->TC_DESCOPE,;  //Descrição da Operação
                   (cAliasJson)->TC_QTPVOPE,;  //Quantidade Prevista da Operação
                   (cAliasJson)->TC_QTPDOPE,;  //Quantidade Produzida da Operação
                   (cAliasJson)->TC_DTINOPE,;  //Data INI Operação
                   (cAliasJson)->TC_DTFIOPE,;  //Data FIM Operação
                   (cAliasJson)->TC_IDOPER,;   //ID da operação
                   (cAliasJson)->TC_PERDA,;    //Quantidade perda
                   (cAliasJson)->TC_ARMZ,;     //Armazém
                   (cAliasJson)->TC_UM,;       //Unidade de medida
                   (cAliasJson)->TC_PEDIDO,;   //Número do pedido
                   (cAliasJson)->TC_CODCLI,;   //Código do cliente
                   (cAliasJson)->TC_NOMCLI;    //Nome do cliente
                   })   

    	(cAliasJson)->(dbSkip())
        
        If nCount >= nPageSize
            Exit
        EndIf
	End

    If (cAliasJson)->(!Eof())
		lUltimo := .F.
    Else
        lUltimo := .T.
	EndIf

	(cAliasJson)->(DBCloseArea())

Return

/*/{Protheus.doc} Static Function fExitReg
Verifica se existe registo na tabela de consulta
@type  WSMETHOD
@author michele.girardi
@since 28/10/2021
@version P12.1.33
@param cSearchId - Id da consulta
@return lRet
/*/
Static Function fExitReg(cSearchId)

    Local cAlias := GetNextAlias()
    Local cQuery := ''
    Local lRet   := .F.
    Local nCount := 0
    
    cQuery := "  SELECT COUNT(*) COUNT "           
	cQuery += "    FROM " +cSearchId 

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
    If (cAlias)->(!Eof())		
		nCount :=  (cAlias)->COUNT
	EndIf
	(cAlias)->(DBCloseArea())

    If nCount > 0
        lRet := .T.
    EndIf

Return lRet

/*/{Protheus.doc} Static Function fCriaTab
Cria tabela física para gravar a consulta da OP
@type  WSMETHOD
@author michele.girardi
@since 28/10/2021
@version P12.1.33
@param cId - Id da consulta
@param cUsuario - Usuário que realizou a consulta
@return Nil
/*/
Static Function fCriaTab(cId, cUsuario)

    Local aFields  := {}
    Local cCampo   := ''
    Local cData    := ''
    Local cNCampo  := ''
    Local nI       := 0

    If Empty(cId)
        Return 
    EndIf

    For nI := 1 to 26

        Do Case
		    Case nI == 1
		    	cCampo   := 'D4_OP'
		    	cNCampo  := 'TC_OP'
            
            Case nI == 2
		    	cCampo   := 'D4_COD'
		    	cNCampo  := 'TC_COD'

            Case nI == 3
		    	cCampo   := 'B1_DESC'
		    	cNCampo  := 'TC_DESC'
            
            Case nI == 4
		    	cCampo   := 'C2_QUANT'
		    	cNCampo  := 'TC_QUANT'

            Case nI == 5
		    	cCampo   := 'C2_QUJE'
		    	cNCampo  := 'TC_QUJE'

            Case nI == 6
		    	cCampo   := 'C2_DATPRI'
		    	cNCampo  := 'TC_DATPRI'
            
            Case nI == 7
		    	cCampo   := 'C2_DATPRF'
		    	cNCampo  := 'TC_DATPRF'
            
            Case nI == 8
		    	cCampo   := 'D3_EMISSAO'
		    	cNCampo  := 'TC_DATINI'
            
            Case nI == 9
		    	cCampo   := 'C2_DATRF'
		    	cNCampo  := 'TC_DATRF'
            
            Case nI == 10
		    	cNCampo  := 'TC_SITOP'
            
            Case nI == 11
		    	cCampo   := 'CYY_IDATQO'
		    	cNCampo  := 'TC_SPLIT'
            
            Case nI == 12
		    	cCampo   := 'G2_OPERAC'
		    	cNCampo  := 'TC_OPER'
            
            Case nI == 13
		    	cCampo   := 'G2_DESCRI'
		    	cNCampo  := 'TC_DESCOPE'
            
            Case nI == 14
		    	cCampo   := 'C2_QUANT'
		    	cNCampo  := 'TC_QTPVOPE'
            
            Case nI == 15
		    	cCampo   := 'H6_QTDPROD'
		    	cNCampo  := 'TC_QTPDOPE'
            
            Case nI == 16
		    	cCampo   := 'H6_DTAPONT'
		    	cNCampo  := 'TC_DTINOPE'
            
            Case nI == 17
		    	cCampo   := 'H6_DTAPONT'
		    	cNCampo  := 'TC_DTFIOPE'
            
            Case nI == 18
		    	cCampo   := 'CYV_IDAT'
		    	cNCampo  := 'TC_IDOPER'

            Case nI == 19
		    	cCampo   := 'C2_PERDA'
		    	cNCampo  := 'TC_PERDA'

            Case nI == 20
		    	cCampo   := 'C2_LOCAL'
		    	cNCampo  := 'TC_ARMZ'

            Case nI == 21
		    	cCampo   := 'C2_UM'
		    	cNCampo  := 'TC_UM'

            Case nI == 22
		    	cCampo   := 'C2_PEDIDO'
		    	cNCampo  := 'TC_PEDIDO'

            Case nI == 23
		    	cCampo   := 'C6_CLI'
		    	cNCampo  := 'TC_CODCLI'

            Case nI == 24
		    	cCampo   := 'A1_NREDUZ'
		    	cNCampo  := 'TC_NOMCLI'

            Case nI == 25
		    	cCampo   := 'CYY_CDMQ'
		    	cNCampo  := 'TC_MAQUINA'

            Case nI == 26
		    	cCampo   := 'CY9_CDCETR'
		    	cNCampo  := 'TC_CNTRTRB'

        End Case

        If nI == 10
            aAdd(aFields, {cNCampo,"C",1,0})
        Else
            aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
        EndIF
    Next nI

    //Deleta Tabela no Banco, caso exista
    lOk := TCDelFile(cId)

    //Cria Tabela no Banco
    dbCreate(cId, aFields, "TOPCONN")

    cData    := DTOC(DATE())

    If AliasInDic("SMP")
        fDelSMP(cId, cUsuario)

        SMP->(dbSetOrder(1))
        dbselectarea("SMP")
        RecLock("SMP",.T.)
	        Replace SMP->MP_FILIAL   With xFilial( "SMP" ),;
		            SMP->MP_TABELA   With cId,;
                    SMP->MP_USUARIO  With cUsuario,;
				    SMP->MP_DTCONS   With dDataBase
	        SMP->(MsUnLock())
    EndIf

Return 

/*/{Protheus.doc} Static Function fDelTabAnt
Exclui tabelas criadas em processamentos anteriores 
@type  WSMETHOD
@author michele.girardi
@since 28/10/2021
@version P12.1.33
@param cUsuario - Usuário que realizou a consulta
@return Nil
/*/
Static Function fDelTabAnt(cUsuario)
    
    Local cAliasDel := GetNextAlias()
    Local cQuery    := "" 
    Local dData     := DATE()

    If !AliasInDic("SMP")
        Return
    EndIf

    cQuery := "  SELECT MP_TABELA, MP_DTCONS "
    cQuery += "    FROM " + RetSqlName("SMP") + " SMP "
    cQuery += "   WHERE SMP.MP_FILIAL   = '" + xFilial( "SMP" ) + "'"
    cQuery += "     AND SMP.MP_USUARIO  = '"+ cUsuario +"' "
    cQuery += "     AND SMP.MP_DTCONS   < '"+ DTOS(dData) +"' "
    cQuery += "     AND SMP.D_E_L_E_T_  = ' ' "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDel,.T.,.T.)
    While (cAliasDel)->(!Eof())

        TCDelFile((cAliasDel)->MP_TABELA)
        fDelSMP((cAliasDel)->MP_TABELA, cUsuario)

    	(cAliasDel)->(dbSkip())    
	End
	(cAliasDel)->(DBCloseArea())

Return 

/*/{Protheus.doc} Static Function fDelSMP
Deleta registros na tabela de consulta
@type  WSMETHOD
@author michele.girardi
@since 13/10/2021
@version P12.1.33
@param cTabela - Tabela
@param cUsuario - Usuario
@return nil
/*/
Static Function fDelSMP(cTabela, cUsuario)

    Local cDelete := ''

     cDelete := " DELETE FROM " + RetSqlName("SMP") 
     cDelete += "  WHERE MP_FILIAL   = '" + xFilial( "SMP" ) + "' " 
     cDelete += "    AND MP_USUARIO  = '"+ cUsuario +"' "
     cDelete += "    AND MP_TABELA   = '"+ cTabela +"' "
     cDelete += "    AND D_E_L_E_T_  = ' ' "

     If TcSqlExec(cDelete) < 0
        Return .F.
    EndIf

Return .T.

/*/{Protheus.doc} Static Function fCargaListOp
Carrega lista de OPs conforme filtro informado 
@type  WSMETHOD
@author michele.girardi
@since 04/10/2021
@version P12.1.33
@param cAppointmentType - Tipo do apontamento (1 - Simples, 3 - MOD 2, 4 - SFC, 9 - Automação estrutural SFC)
@param cFilterSearch - Filtro para consulta - Pode receber o Número da OP ou o Código do item
@param cSearchId - ID gerada para consultas
@param cformCode - Código do formulário utilizado para chamar a API
@param cAction - ação do formulário
@return Nil
/*/
Static Function fCargaListOp(cAppointmentType, cFilterSearch, cSearchId, cFormCode, cAction, cPrdCode, dStartRng,dEnDRng,cWhCode,cCustCode,cCustOrdCd,cOpCode,cMchCode,cWrkCntCd,lPlanned,lOpened,lStarted,lIdle,lPtClosed,lTtClosed)
        
    Local aRetOper    := {}
    Local cAliasList  := GetNextAlias()
    Local cCharSoma   := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ")
    Local cDtIniReal  := ""
    Local cOp         := ""
    Local cQuery      := ""    
    Local cStatusOp   := ""
    Local cFltSchCnd  := ""
    Local lPOSFilOp   := ExistBlock("POSFilOp")
    Local lConsOp     := .T.
    Local lExistItTo  := .F.
    Local lExistItPa  := .F.
    Local lExistOpCo  := .F.
    Local lExistOpPa  := .F.
    Local lExistBcTo  := .F.
    Local lExistBcPa  := .F.
    Local lEntrou     := .F.   
    Local n1I         := 0 

    Private nIRecno   := 0

    Default cAppointmentType := ""
    Default cFilterSearch := ""
    Default cSearchId := ""
    Default cFormCode := ""

    If cAction == "B"
        lExistOpCo := fExistOp(cFilterSearch, 'OP', 'C') //Consulta número OP completo
        
        If !lExistOpCo
            lExistOpPa := fExistOp(cFilterSearch, 'OP', 'P')  //Consulta número OP parcial - C2_NUM
        EndIf
    
        lExistItTo := fExistOp(cFilterSearch, 'IT', 'C') //Consulta código do item completo

        If !lExistItTo
            lExistItPa := fExistOp(cFilterSearch, 'IT', 'P') //Consulta código do item parcial
        EndIf

        lExistBcTo := fExistOp(cFilterSearch, 'BC', 'C') //Consulta código de barra completo

        If !lExistBcTo
            lExistBcPa := fExistOp(cFilterSearch, 'BC', 'P') //Consulta código de barra parcial
        EndIf

        If !lExistOpCo .And. !lExistOpPa .And. !lExistItTo .And. !lExistItPa .And. !lExistBcTo .And. !lExistBcPa
            Return 
        EndIf
        
        lEntrou := .F.
        cFltSchCnd += " AND ( "
        
        If lExistOpCo //Existe OP completa com o filtro da pesquisa    
            cFltSchCnd += " SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD  =  '" +cFilterSearch+ "'"
            lEntrou := .T.
        Else
            If lExistOpPa //Existe OP parcial com o filtro da pesquisa
                cFltSchCnd += " SC2.C2_NUM = '" +cFilterSearch+ "'"
                lEntrou := .T.
            EndIf
        EndIf

        If lExistItTo //Existe Item completo com o filtro da pesquisa
            If lEntrou
                cFltSchCnd += " OR "
            EndIf 
            cFltSchCnd += " SC2.C2_PRODUTO = '" +cFilterSearch+ "'"
            lEntrou := .T.
        Else
            If lExistItPa
                If lEntrou
                    cFltSchCnd += " OR "
                EndIf 
                cFltSchCnd += " SC2.C2_PRODUTO LIKE ( '%" + TRIM(cFilterSearch)+ "%' )"
                lEntrou := .T.
            EndIf
        EndIf

        If lExistBcTo //Existe código de barra completo com o filtro da pesquisa
            If lEntrou
                cFltSchCnd += " OR "
            EndIf 
            cFltSchCnd += " SB1.B1_CODBAR = '" +cFilterSearch+ "'"
            lEntrou := .T.
        Else
            If lExistBcPa
                If lEntrou
                    cFltSchCnd += " OR "
                EndIf 
                cFltSchCnd += " SB1.B1_CODBAR LIKE ( '%" + TRIM(cFilterSearch)+ "%' )"
                lEntrou := .T.
            EndIf
        EndIf

        cFltSchCnd += " ) "

    Else
        If !Empty(cPrdCode)
            cFltSchCnd += " AND (SB1.B1_COD LIKE '%"+cPrdCode+"%' OR SB1.B1_DESC LIKE '%"+cPrdCode+"%' OR SB1.B1_CODBAR LIKE '%"+cPrdCode+"%') "
        EndIf
        
        If !Empty(dStartRng)
           cFltSchCnd += " AND SC2.C2_DATPRI >= '"+dToS(dStartRng)+"' "
        EndIf

        If !Empty(dEndRng)
           cFltSchCnd += " AND SC2.C2_DATPRI <= '"+dToS(dEndRng)+"' "
        EndIf
        
        If !Empty(cWhCode)
            cFltSchCnd += " AND (SC2.C2_LOCAL LIKE '%"+cWhCode+"%' OR NNR.NNR_DESCRI LIKE '%"+cWhCode+"%') "
        Endif

        If !Empty(cCustCode)
            cFltSchCnd += " AND (SA1.A1_COD LIKE '%"+cCustCode+"%' OR SA1.A1_NREDUZ LIKE '%"+cCustCode+"%' OR SA1.A1_NOME LIKE '%"+cCustCode+"%') "
        EndIf

        If !Empty(cCustOrdCd)
            cFltSchCnd += " AND SC6.C6_NUM LIKE '%"+cCustOrdCd+"%' "
        EndIf
    EndIf

    cQuery := "  SELECT SC2.C2_NUM     NUMOP, "
    cQuery += "         SC2.C2_ITEM    ITEMOP, "
    cQuery += "         SC2.C2_SEQUEN  SEQOP, "
    cQuery += "         SC2.C2_ITEMGRD GRDOP, "
    cQuery += "         SC2.C2_PRODUTO PRODUTOOP, "
    cQuery += "         SB1.B1_DESC    DESCPROD, "
    cQuery += "         SC2.C2_QUANT   QTDPREV, "
    cQuery += "         SC2.C2_QUJE    QTDAPON, "
    cQuery += "         SC2.C2_DATPRI  DTINI, "
    cQuery += "         SC2.C2_DATPRF  DTFIM, "  
    cQuery += "         SC2.C2_DATRF   DTRF, "
    cQuery += "         SC2.C2_DIASOCI DIASOCI, "
    cQuery += "         SC2.C2_TPOP    TPO, "
    cQuery += "         SC2.C2_PERDA   PERDA, "
    cQuery += "         SC2.C2_LOCAL   ARMZ, "
    cQuery += "         SC2.C2_UM      UM, "
    cQuery += "         SC2.C2_PEDIDO  PEDIDO, "
    cQuery += "         SC6.C6_CLI     CODCLI, "
    cQuery += "         SA1.A1_NREDUZ  NOMCLI "
    cQuery += "    FROM " + RetSqlName("SC2") + " SC2 "
    cQuery += "    INNER JOIN  "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SC2.C2_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += "    LEFT OUTER JOIN "+RetSqlName("NNR")+" NNR ON NNR.NNR_FILIAL = '"+xFilial("NNR")+"' AND NNR.NNR_CODIGO = SC2.C2_LOCAL AND NNR.D_E_L_E_T_ = ' ' "
    cQuery += "    LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 ON SC6.C6_FILIAL = '"+xFilial("SC6")+"' AND SC6.C6_NUM = SC2.C2_PEDIDO AND SC6.C6_ITEM = SC2.C2_ITEMPV AND SC6.D_E_L_E_T_ = ' ' "
    cQuery += "    LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = SC6.C6_CLI AND SA1.D_E_L_E_T_ = ' ' "
    cQuery += "   WHERE SC2.C2_FILIAL   = '" + xFilial( "SC2" ) + "'"
    cQuery += "     AND SC2.D_E_L_E_T_  = ' ' "
   
    cQuery += cFltSchCnd

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasList,.T.,.T.)
    While (cAliasList)->(!Eof())

        cOp := (cAliasList)->NUMOP+(cAliasList)->ITEMOP+(cAliasList)->SEQOP+(cAliasList)->GRDOP

        cStatusOp := fStatusOp(cOp, (cAliasList)->TPO, (cAliasList)->DTRF, (cAliasList)->QTDAPON, (cAliasList)->QTDPREV, (cAliasList)->DIASOCI, (cAliasList)->DTINI)

        If cAction = "A" .And. !fValStatus(cStatusOp,lPlanned,lOpened,lStarted,lIdle,lPtClosed,lTtClosed)
            (cAliasList)->(dbSkip())
            Loop        
        EndIf

        cDtIniReal := fDtIniReal(cAppointmentType, cOp)

        lExistApon := fExistApon(cOp)

        If lExistApon
            lRet := .T.
            lRet := fValidTipo(cOp, cAppointmentType,'AP')

            If !lRet
                (cAliasList)->(dbSkip())
                Loop
            EndIf 
        Else
            lRet := .T.
            lRet := fValidTipo(cOp, cAppointmentType,'OP')

            If !lRet
                (cAliasList)->(dbSkip())
                Loop
            EndIf 
        EndIf

        If lPOSFilOp
			lConsOp:= ExecBlock("POSFilOp",.F.,.F.,{cAppointmentType,cOp,cStatusOp,Nil,Nil,cFormCode})
			If !(ValType(lConsOp) == "L")
				lConsOp := .T.
			EndIf
		EndIf

        If lConsOp == .F.
            (cAliasList)->(dbSkip())    
            Loop 
        EndIf

        aRetOper := {} //Operações
        If cAppointmentType $'3 | 4 | 9' //9 - Automação estrutural SFC
            fRetOperOp(cAppointmentType, cOp, @aRetOper, cStatusOp, lPOSFilOp, cFormCode,cOpCode,cMchCode,cWrkCntCd,cAction)

            If Len(aRetOper) > 0            					
				For n1I := 1 To Len(aRetOper)

                    fInsertTab(cSearchId,;
                               cOp,;
                              (cAliasList)->PRODUTOOP,;
                              (cAliasList)->DESCPROD,;
                              (cAliasList)->QTDPREV,; 
                              (cAliasList)->QTDAPON,;
                              (cAliasList)->DTINI,;
                              (cAliasList)->DTFIM,;
                              cDtIniReal,;
                              (cAliasList)->DTRF,;
                              cStatusOp,;
                              aRetOper[n1I,1] ,;
                              aRetOper[n1I,2] ,;
                              aRetOper[n1I,3] ,;
                              aRetOper[n1I,4] ,;
                              aRetOper[n1I,5] ,;
                              aRetOper[n1I,6] ,; 
                              aRetOper[n1I,7],;
                              aRetOper[n1I,8],;
                              (cAliasList)->PERDA,;
                              (cAliasList)->ARMZ,;
                              (cAliasList)->UM,;
                              (cAliasList)->PEDIDO,;
                              (cAliasList)->CODCLI,;
                              (cAliasList)->NOMCLI,;
                              aRetOper[n1I,9],;
                              aRetOper[n1I,10])
                Next n1I
            EndIf
        Else
            fInsertTab(cSearchId,;
                       cOp,;
                       (cAliasList)->PRODUTOOP,;
                       (cAliasList)->DESCPROD,;
                       (cAliasList)->QTDPREV,; 
                       (cAliasList)->QTDAPON,;
                       (cAliasList)->DTINI,;
                       (cAliasList)->DTFIM,;
                       cDtIniReal,;
                       (cAliasList)->DTRF,;
                       cStatusOp,;
                       ' ' ,;
                       ' ' ,;
                       ' ' ,;
                       ' ' ,;
                       ' ' ,;
                       ' ' ,; 
                       ' ',;
                       ' ',;
                       (cAliasList)->PERDA,;
                       (cAliasList)->ARMZ,;
                       (cAliasList)->UM,;
                       (cAliasList)->PEDIDO,;
                       (cAliasList)->CODCLI,;
                       (cAliasList)->NOMCLI,;
                       ' ',;
                       ' ')
        EndIf     
		(cAliasList)->(dbSkip())    
	End
	(cAliasList)->(DBCloseArea())

Return


/*/{Protheus.doc} Static Function fValStatus
Valida se o status da op corrente entra no filtro avançado
@type  Static Function
@author renan.roeder
@since 25/07/2022
@version P12
@param cStatusOp - Status real da OP que será verificado
@param lPlanned - Ordem planejada
@param lOpened - Ordem aberta
@param lStarted - Ordem iniciada
@param lIdle - Ordem ociosa
@param lPtClosed - Ordem parcialmente fechada
@param lTtClosed - Orderm totalmente fechada
@return lRet
/*/
Static Function fValStatus(cStatusOp,lPlanned,lOpened,lStarted,lIdle,lPtClosed,lTtClosed)
    Local lRet := .T.

        
    If (cStatusOp == "1" .And. !lPlanned) .Or. (cStatusOp == "2" .And. !lOpened) .Or.; 
       (cStatusOp == "3" .And. !lStarted) .Or. (cStatusOp == "4" .And. !lIdle) .Or.; 
       (cStatusOp == "5" .And. !lPtClosed) .Or. (cStatusOp == "6" .And. !lTtClosed)
        lRet := .F.
    EndIf

Return lRet

/*/{Protheus.doc} Static Function fDelTab
Deleta registros na tabela de consulta
@type  WSMETHOD
@author michele.girardi
@since 13/10/2021
@version P12.1.33
@param cSearchId - Tabela
@return nil
/*/
Static Function fDelTab(cSearchId)

    Local cDelete := ''

     cDelete := " DELETE FROM " + cSearchId

     If TcSqlExec(cDelete) < 0
        Return .F.
    EndIf

Return .T.

/*/{Protheus.doc} Static Function fInsertTab
Insere registros na tabela de consulta
@type  WSMETHOD
@author michele.girardi
@since 13/10/2021
@version P12.1.33
@param cSearchId - Tabela
@return nil
/*/
Static Function fInsertTab(cSearchId,cOP,cCOD,cDESC,nQUANT,nQUJE,cDATPRI,cDATPRF,cDATINI,cDATRF,cSITOP,;
                           cSPLIT,cOPER,cDESCOPE,nQTPVOPE,nQTPDOPE,cDTINOPE,cDTFIOPE,cIDOPER,nPerda,cArmz,cUM,cPedido,cCodCli,cNomCli,cMaquina,cCentroTrb)

    Local cInsert   := ""

    Default nIRecno := 0

    nIRecno += 1

    cInsert := " INSERT INTO " + (cSearchId) 
    cInsert += "              ( TC_OP, "
    cInsert += "                TC_COD, "    
    cInsert += "                TC_DESC, "   
    cInsert += "                TC_QUANT, "  
    cInsert += "                TC_QUJE, "   
    cInsert += "                TC_DATPRI, " 
    cInsert += "                TC_DATPRF, " 
    cInsert += "                TC_DATINI, " 
    cInsert += "                TC_DATRF, "  
    cInsert += "                TC_SITOP, "  
    cInsert += "                TC_SPLIT, "  
    cInsert += "                TC_OPER, "   
    cInsert += "                TC_DESCOPE, "
    cInsert += "                TC_QTPVOPE, "
    cInsert += "                TC_QTPDOPE, "
    cInsert += "                TC_DTINOPE, "
    cInsert += "                TC_DTFIOPE, "
    cInsert += "                TC_IDOPER, "
    
    cInsert += "                TC_PERDA, "
    cInsert += "                TC_ARMZ, "
    cInsert += "                TC_UM, "
    cInsert += "                TC_PEDIDO, "
    cInsert += "                TC_CODCLI, "
    cInsert += "                TC_NOMCLI, "
    cInsert += "                TC_MAQUINA, "
    cInsert += "                TC_CNTRTRB, "
    
    cInsert += "                R_E_C_N_O_) "
    cInsert += "       VALUES ( '" + cOP + "' ,"
    cInsert += "                '" + cCOD + "' ,"
    cInsert += "                '" + cDESC + "' ,"
    cInsert += "                '" + cValToChar(nQUANT) + "' ," 
    cInsert += "                '" + cValToChar(nQUJE) + "',"
    cInsert += "                '" + cDATPRI + "' ,"
    cInsert += "                '" + cDATPRF + "' ,"
    cInsert += "                '" + cDATINI + "' ,"
    cInsert += "                '" + cDATRF + "' ,"
    cInsert += "                '" + cSITOP + "' ,"
    cInsert += "                '" + cSPLIT + "' ,"
    cInsert += "                '" + cOPER + "' ,"
    cInsert += "                '" + cDESCOPE + "' ,"
    cInsert += "                '" + cValToChar(nQTPVOPE) + "' ,"
    cInsert += "                '" + cValToChar(nQTPDOPE) + "' ,"
    cInsert += "                '" + cDTINOPE + "' ,"
    cInsert += "                '" + cDTFIOPE + "' , "
    cInsert += "                '" + cIDOPER + "' , "

    cInsert += "                '" + cValToChar(nPerda) + "' , "
    cInsert += "                '" + cArmz + "' , "
    cInsert += "                '" + cUM + "' , "
    cInsert += "                '" + cPedido + "' , "
    cInsert += "                '" + cCodCli + "' , "
    cInsert += "                '" + cNomCli + "' , "
    cInsert += "                '" + cMaquina + "' , "
    cInsert += "                '" + cCentroTrb + "' , "

    cInsert += "                '" + cValToChar(nIRecno) + "' ) " 

    If TcSqlExec(cInsert) < 0
        Return .F.
    EndIf

Return .T.

/*/{Protheus.doc} Static Function fExistApon
Retorna se existe apontamento para a OP (Validando somente a SD3)
@type  WSMETHOD
@author michele.girardi
@since 13/10/2021
@version P12.1.33
@param cOP - Ordem de Produção
@return lExistApon - Data Início da OP
/*/
Static Function fExistApon(cOp)

    Local cAliasApo  := GetNextAlias()
    Local cQuery 	 := ""
    Local lExistApon := .F.
    Local nCount     := 0

    Default cOp := ""

    cQuery	  := "  SELECT COUNT(*) COUNT "
	cQuery	  += "    FROM " + RetSqlName('SD3') + " SD3 " 
	cQuery	  += "   WHERE SD3.D3_FILIAL   = '" + xFilial( "SD3" ) + "'"
    cQuery	  += "     AND SD3.D3_OP 	   = '" + cOp + "'"    
    cQuery	  += "     AND SD3.D3_ESTORNO  = ' ' "    
    cQuery	  += "     AND SD3.D_E_L_E_T_  = ' '"    

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasApo,.T.,.T.)    
	If (cAliasApo)->(!Eof())		
		nCount :=  (cAliasApo)->COUNT
	EndIf
	(cAliasApo)->(DBCloseArea())

    If nCount > 0
        lExistApon := .T.
    EndIf

Return lExistApon

/*/{Protheus.doc} Static Function fDtIniReal
Retorna a data de inicio real da OP
@type  WSMETHOD
@author michele.girardi
@since 13/10/2021
@version P12.1.33
@param appointmentType - Tipo do apontamento (1 - Simples, 3 - MOD 2, 4 - SFC, 9 - Automação estrutural SFC)
@param cOP - Ordem de Produção
@return cDtIniOP - Data Início da OP
/*/
Static Function fDtIniReal(cAppointmentType, cOp)

    Local cAliasIni  := GetNextAlias()
    Local cDtIniOP   := ""
    Local cQuery 	 := ""

    Default cAppointmentType := ""
    Default cOp := ""

    If cAppointmentType == '1'
        cQuery	  := "  SELECT MIN(D3_EMISSAO) DTINI"
	    cQuery	  += "    FROM " + RetSqlName('SD3') + " SD3 " 
	    cQuery	  += "   WHERE SD3.D3_FILIAL   = '" + xFilial( "SD3" ) + "'"
        cQuery	  += "     AND SD3.D3_OP 	   = '" + cOp + "'"    
        cQuery	  += "     AND SD3.D3_ESTORNO  = ' ' "    
        cQuery	  += "     AND SD3.D_E_L_E_T_  = ' '"
    ElseIf cAppointmentType == '3'
        cQuery	  := "  SELECT MIN(H6_DTAPONT) DTINI"
	    cQuery	  += "    FROM " + RetSqlName('SH6') + " SH6 " 
	    cQuery	  += "   WHERE SH6.H6_FILIAL   = '" + xFilial( "SH6" ) + "'"
        cQuery	  += "     AND SH6.H6_OP 	   = '" + cOp + "'"    
        cQuery	  += "     AND SH6.D_E_L_E_T_  = ' '"
    ElseIf cAppointmentType $ '4 | 9' //9 - Automação estrutural SFC
        cQuery	  := "  SELECT MIN(CYV_DTRP) DTINI"
	    cQuery	  += "    FROM " + RetSqlName('CYV') + " CYV " 
	    cQuery	  += "   WHERE CYV.CYV_FILIAL   = '" + xFilial( "CYV" ) + "'"
        cQuery	  += "     AND CYV.CYV_NRORPO   = '" + cOp + "'"    
        cQuery	  += "     AND CYV.CYV_DTEO     = ' ' "    
        cQuery	  += "     AND CYV.D_E_L_E_T_   = ' ' "
    EndIf

    If !Empty(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasIni,.T.,.T.)
	    If (cAliasIni)->(!Eof())		
		    cDtIniOP :=  (cAliasIni)->DTINI
	    EndIf
	    (cAliasIni)->(DBCloseArea())
    EndIf

Return cDtIniOP

/*/{Protheus.doc} Static Function fRetOperOp
Retorna as informações das operações da ordem pelo array aRetOper
@type  WSMETHOD
@author michele.girardi
@since 07/10/2021
@version P12.1.33
@param cAppointmentType - Tipo do apontamento (1 - Simples, 3 - MOD 2, 4 - SFC, 9 - Automação estrutural SFC)
@param cOP - Ordem de Produção
@param aRetOper - Array com as informações das Operações 
@param cStatusOp - Status da OP
@param lPOSFilOp - Indicador da existência do Ponto de Entrada POSFilOP
@param cformCode - Código do formulário utilizado para chamar a API
@return nil
/*/
Static Function fRetOperOp(cAppointmentType, cOp, aRetOper, cStatusOp, lPOSFilOp, cFormCode, cOpCode, cMchCode, cWrkCntCd, cAction)
   
    Local aAreaSC2   := SC2->(GetArea())
    Local cAliasOper := GetNextAlias()
    Local cDtIni     := ""
    Local cDtFim     := ""
    Local cQuery 	 := ""
    Local cRoteiro   := ""        
    Local lConsOp    := .T.
    Local lShy       := SuperGetMV("MV_APS",.F.,"") == "TOTVS" .OR. SuperGetMV("MV_PCPATOR",.F.,.F.) == .T.
    Local nQtdPrev   := 0
    Local nQtdProd   := 0
    
    Default aRetOper := {}
    Default cAppointmentType := ""
    Default cFormCode := ""
    Default cOp := ""
    Default cProd := ""
    Default cStatusOp := ""
    Default lPOSFilOp := .F.

    If cAppointmentType == '3'
        SC2->(dbSetOrder(1))
		SC2->(dbSeek(xFilial("SC2")+cOP))

        If lShy
            aRetOper := {}

            cQuery	  := "  SELECT SHY.HY_OPERAC   OPERACAO, "  //Código da operação
            cQuery	  += "         SHY.HY_DESCRI   DESCOPER, "  //Descrição da operação
            cQuery	  += "         ' '             DTINI,    "  //Data validade inicial
            cQuery	  += "         ' '             DTFIM     "  //Data validade final
            cQuery    += "    FROM " + RetSqlName("SHY") + " SHY "
            cQuery    += "   WHERE SHY.HY_FILIAL  = '" + xFilial( "SHY" ) + "'"  
            cQuery    += "     AND SHY.HY_OP      = '" + cOp + "'"

            If !Empty(cOpCode)
                cQuery    += " AND (SHY.HY_OPERAC LIKE '%" + cOpCode + "%' OR SHY.HY_DESCRI LIKE '%" + cOpCode + "%') "
            EndIf

            cQuery    += "     AND SHY.D_E_L_E_T_ = ' ' " 
            cQuery    += "   ORDER BY OPERACAO "
        Else
            If Empty(cRoteiro := SC2->C2_ROTEIRO)
		        If Empty(cRoteiro := Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_OPERPAD"))
			        cRoteiro := StrZero(1,TamSX3("G2_CODIGO")[1])
		        EndIf
	        EndIf

            cQuery	  := "  SELECT SG2.G2_OPERAC   OPERACAO, "  //Código da operação
            cQuery	  += "         SG2.G2_DESCRI   DESCOPER, "  //Descrição da operação
            cQuery	  += "         SG2.G2_DTINI    DTINI,    "  //Data validade inicial
            cQuery	  += "         SG2.G2_DTFIM    DTFIM     "  //Data validade final
            cQuery    += "    FROM " + RetSqlName("SG2") + " SG2 "
            cQuery    += "   WHERE SG2.G2_FILIAL  = '" + xFilial( "SG2" ) + "'"  
            cQuery    += "     AND SG2.G2_CODIGO  = '" + cRoteiro + "'"
            cQuery    += "     AND SG2.G2_PRODUTO = '" + SC2->C2_PRODUTO + "'"

            If !Empty(cOpCode)
                cQuery    += " AND (SG2.G2_OPERAC LIKE '%"+cOpCode+"%' OR SG2.G2_DESCRI LIKE '%"+cOpCode+"%') "
            EndIf

            cQuery    += "     AND SG2.D_E_L_E_T_ = ' ' "
            cQuery    += "   ORDER BY OPERACAO "
        EndIf
        
        cQuery    := ChangeQuery(cQuery)	    
        dbUseArea (.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasOper, .F., .T.)
        While (cAliasOper)->(!Eof())
            
            If !Empty((cAliasOper)->DTINI)
                If (cAliasOper)->DTINI > SC2->C2_DATPRI
					(cAliasOper)->(dbSkip())
					Loop
				EndIf
            EndIf

            If !Empty((cAliasOper)->DTFIM)
				If (cAliasOper)->DTFIM < SC2->C2_DATPRI
					(cAliasOper)->(dbSkip())
					Loop
				EndIf
			EndIf

            nQtdPrev := SC2->C2_QUANT
            nQtdProd := fRetQtdProd(cOp,(cAliasOper)->OPERACAO)
                
            If nQtdProd > 0
                fRetDatProd(cOp,(cAliasOper)->OPERACAO,@cDtIni,@cDtFim)
            Else
                cDtIni   := ""
                cDtFim   := ""
            EndIf

            If lPOSFilOp
                lConsOp:= ExecBlock("POSFilOp",.F.,.F.,{cAppointmentType,cOp,cStatusOp,Nil,(cAliasOper)->OPERACAO,cFormCode})
                If !(ValType(lConsOp) == "L")
                    lConsOp := .T.
                EndIf
            EndIf

            If lConsOp == .F.
                (cAliasOper)->(dbSkip())    
                Loop 
            EndIf

            aAdd(aRetOper,{ ' ',;
                            (cAliasOper)->OPERACAO,;
                            (cAliasOper)->DESCOPER,;
                             nQtdPrev,;
                             nQtdProd,;
                             cDtIni,;
                             cDtFim,;
                             ' ',;
                             ' ',;
                             ' ' })

            (cAliasOper)->(dbSkip())
	    End
	    (cAliasOper)->(DBCloseArea())                    
    EndIf

    If cAppointmentType $ '4 | 9' //9 - Automação estrutural SFC       
        aRetOper := {}

        cQuery	  := "  SELECT CYY.CYY_IDATQO SPLIT, "     //Split
        cQuery	  += "         CYY.CYY_IDAT   IDOPER, "    //ID operação
        cQuery	  += "         CY9.CY9_CDAT   OPERACAO, "  //Código da operação
        cQuery	  += "         CY9.CY9_DSAT   DESCOPER, "  //Descrição da operação
        cQuery	  += "         CYY.CYY_QTAT   QTDPREV, "   //Quantidade prevista do split
        cQuery	  += "         CYY.CYY_QTATAP QTDAPROV, "  //Quantidade aprovada do split
        cQuery	  += "         CYY.CYY_QTATRF QTDREFUG, "  //Quantidade refugada do split
        cQuery	  += "         CYY.CYY_DTBGAT DTINI, "     //Data inicio do split
        cQuery	  += "         (CASE WHEN CYY.CYY_TPSTAT > 4 THEN CYY.CYY_DTEDAT ELSE ' ' END) DTFIM, " //Data fim do split
        cQuery	  += "         CYY.CYY_IDAT   IDOPER1, "     //ID da Operação
        cQuery    += "         CYY.CYY_CDMQ   MAQUINA, "
        cQuery    += "         CY9.CY9_CDCETR CENTRO_TRAB "
        cQuery    += "    FROM " + RetSqlName("CYY") + " CYY " + "," + RetSqlName("CY9") + " CY9 " 
	    cQuery	  += "   WHERE CYY.CYY_FILIAL   = '" + xFilial( "CYY" ) + "'"        
	    cQuery	  += "     AND CYY.CYY_NRORPO   = '" + cOp + "'"

        If !Empty(cMchCode)
            cQuery    += "     AND (CYY.CYY_CDMQ    = '" + cMchCode + "' OR "
            cQuery    += "          (CYY.CYY_CDMQ   = ' ' AND CY9.CY9_CDCETR = "
            cQuery    += "          (SELECT CYB_CDCETR FROM " + RetSqlName("CYB") + " "
            cQuery    += "            WHERE CYB_FILIAL = '" + xFilial( "CYB" ) + "' "
            cQuery    += "              AND CYB_CDMQ = '" + cMchCode + "'))) "
        EndIf

        If cAction = "A" .And. !Empty(cOpCode)
            cQuery    += " AND (CY9.CY9_CDAT LIKE '%"+cOpCode+"%' OR CY9.CY9_IDAT LIKE '%"+cOpCode+"%' OR CY9.CY9_DSAT LIKE '%"+cOpCode+"%') "
        EndIf

        cQuery	  += "     AND CY9.CY9_FILIAL 	= '" + xFilial( "CY9" ) + "'"
	    cQuery	  += "     AND CY9.CY9_NRORPO 	= CYY.CYY_NRORPO "
        cQuery	  += "     AND CY9.CY9_IDAT 	= CYY.CYY_IDAT "
	    cQuery	  += "     AND CYY.D_E_L_E_T_  = ' ' "
        cQuery	  += "     AND CY9.D_E_L_E_T_  = ' ' "
        cQuery	  += "    ORDER BY IDOPER, SPLIT "
	    cQuery    := ChangeQuery(cQuery)
	    
        dbUseArea (.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasOper, .F., .T.)
        While (cAliasOper)->(!Eof())

            If lPOSFilOp
                lConsOp:= ExecBlock("POSFilOp",.F.,.F.,{cAppointmentType,cOp,cStatusOp,(cAliasOper)->SPLIT,(cAliasOper)->OPERACAO,cFormCode})
                If !(ValType(lConsOp) == "L")
                    lConsOp := .T.
                EndIf
            EndIf

            If lConsOp == .F.
                (cAliasOper)->(dbSkip())    
                Loop 
            EndIf

            aAdd(aRetOper,{ (cAliasOper)->SPLIT,;
                            Alltrim((cAliasOper)->OPERACAO),;
                            Alltrim((cAliasOper)->DESCOPER),;
                            (cAliasOper)->QTDPREV,;
                            ((cAliasOper)->QTDAPROV + (cAliasOper)->QTDREFUG),;
                            (cAliasOper)->DTINI,;
                            (cAliasOper)->DTFIM,;
                            (cAliasOper)->IDOPER1,;
                            (cAliasOper)->MAQUINA,;
                            (cAliasOper)->CENTRO_TRAB})
			
            (cAliasOper)->(dbSkip())
	    End
	    (cAliasOper)->(DBCloseArea())
    EndIf

    SC2->(RestArea(aAreaSC2))
Return 

/*/{Protheus.doc} Static Function fRetDatProd
Retorna a data de inicio e fim da operação
@type  WSMETHOD
@author michele.girardi
@since 08/10/2021
@version P12.1.33
@param cOP - Ordem de Produção
@param cOperac - Código da Operação
@param cDtIni - Data Início da Operação
@param cDtFim - Data Fim da Operação
@return nil
/*/
Static Function fRetDatProd(cOp, cOperac,cDtIni,cDtFim)

    Local cAliasDatI  := GetNextAlias()
    Local cAliasDatF  := GetNextAlias()
    Local cQuery 	 := ""

    Default cOp      := ""
    Default cOperac  := ""
    Default cDtIni   := ""
    Default cDtFim   := ""

    cQuery	  := "  SELECT MIN(H6_DTAPONT) DTINI"
	cQuery	  += "    FROM " + RetSqlName('SH6') + " SH6 " 
	cQuery	  += "   WHERE SH6.H6_FILIAL   = '" + xFilial( "SH6" ) + "'"
    cQuery	  += "     AND SH6.H6_OP 	   = '" + cOp + "'"
    cQuery	  += "     AND SH6.H6_OPERAC   = '" + cOperac + "'"
    cQuery	  += "     AND SH6.D_E_L_E_T_  = ' '"
    
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDatI,.T.,.T.)
	If (cAliasDatI)->(!Eof())		
		cDtIni :=  (cAliasDatI)->DTINI
	EndIf
	(cAliasDatI)->(DBCloseArea())

    cQuery	  := "  SELECT MAX(H6_DTAPONT) DTFIM"
	cQuery	  += "    FROM " + RetSqlName('SH6') + " SH6 " 
	cQuery	  += "   WHERE SH6.H6_FILIAL   = '" + xFilial( "SH6" ) + "'"
    cQuery	  += "     AND SH6.H6_OP 	   = '" + cOp + "'"
    cQuery	  += "     AND SH6.H6_OPERAC   = '" + cOperac + "'"
    cQuery	  += "     AND SH6.H6_PT       = 'T'"
    cQuery	  += "     AND SH6.D_E_L_E_T_  = ' '"
    
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDatF,.T.,.T.)
	If (cAliasDatF)->(!Eof())		
		cDtFim :=  (cAliasDatF)->DTFIM
	EndIf
	(cAliasDatF)->(DBCloseArea())

Return 

/*/{Protheus.doc} Static Function fRetQtdProd
Retorna a quantidade produção da operação
@type  WSMETHOD
@author michele.girardi
@since 08/10/2021
@version P12.1.33
@param cOP - Ordem de Produção
@param cOperac - Código da Operação
@return nQtdProd
/*/
Static Function fRetQtdProd(cOp, cOperac)

    Local cAliasProd := GetNextAlias()
    Local cQuery 	 := ""
    Local lPerdInf   := SuperGetMV("MV_PERDINF",.F.,.F.)
    Local nQtdProd := 0    

    Default cOp := ""
    Default cOperac := ""

    cQuery	  := "  SELECT SUM(H6_QTDPROD) QTDPRD, SUM(H6_QTDPERD) QTDPER"
	cQuery	  += "    FROM " + RetSqlName('SH6') + " SH6 " 
	cQuery	  += "   WHERE SH6.H6_FILIAL   = '" + xFilial( "SH6" ) + "'"
    cQuery	  += "     AND SH6.H6_OP 	   = '" + cOp + "'"
    cQuery	  += "     AND SH6.H6_OPERAC   = '" + cOperac + "'"
    cQuery	  += "     AND SH6.D_E_L_E_T_  = ' '"
    
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasProd,.T.,.T.)
	If (cAliasProd)->(!Eof())		
		nQtdProd :=  (cAliasProd)->QTDPRD + If(lPerdInf, 0, (cAliasProd)->QTDPER)
	EndIf

	(cAliasProd)->(DBCloseArea())

Return nQtdProd

/*/{Protheus.doc} Static Function fStatusOp
Retorna o Status da Ordem de Produção
 1 - Prevista
 2 - Em aberto
 3 - Iniciada
 4 - Ociosa -- não está gravando 4 no momento
 5 - Enc.Parcialmente
 6 - Enc.Totalmente
@type  WSMETHOD
@author michele.girardi
@since 06/10/2021
@version P12.1.33
@param cOP - Ordem de Produção
@param cTpo - Tipo da Ordem de Produção / Firme ou Prevista
@param cDatrf - Data de Encerramento
@param nQuje - Quantidade Apontada
@param nQuant - Quantidade Prevista
@return cStatusOp - Status da OP
/*/
Static Function fStatusOp(cOp, cTpo, cDatrf, nQuje, nQuant, cDatOci, cDTINI)

    Local cAliasTemp  := ""
    Local cQuery 	  := ""
    Local cStatusOp   := 0
    Local dEmissao	  := dDatabase
    Local lAchou      := .F.
    Local nRegSD3	  := 0
    Local nRegSH6	  := 0

    Default cOp       := ""
    Default cTpo      := ""
    Default cDatrf    := ""
    Default nQuant    := 0
    Default nQuje     := 0
    
    cDTINI := STOD(cDTINI)

    If cTpo == "P" //1-Prevista
        cStatusOp := '1'
        lAchou := .T.
    EndIf

    If !lAchou
        If cTpo == "F" .And. !Empty(cDatrf) .And. (nQuje < nQuant)  //5-Enc.Parcialmente
            cStatusOp := '5'
            lAchou := .T.
        EndIf
    End If 

    If !lAchou
        If cTpo == "F" .And. !Empty(cDatrf) .And. (nQuje >= nQuant) //6-Enc.Totalmente
            cStatusOp := '6'
            lAchou := .T.
        EndIf
    EndIf

    If !lAchou
        cAliasTemp:= "SD3TMP"
	    cQuery	  := "  SELECT COUNT(*) AS RegSD3, MAX(D3_EMISSAO) AS EMISSAO "
	    cQuery	  += "   FROM " + RetSqlName('SD3')
	    cQuery	  += "   WHERE D3_FILIAL   = '" + xFilial( "SC2" ) + "'"
	    cQuery	  += "     AND D3_OP 	   = '" + cOp + "'"
	    cQuery	  += "     AND D3_ESTORNO <> 'S' "
	    cQuery	  += "     AND D_E_L_E_T_  = ' '"
	    cQuery    += " 	   GROUP BY D3_EMISSAO "
	    cQuery    := ChangeQuery(cQuery)
	    dbUseArea (.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

	    If !SD3TMP->(Eof())
            dEmissao := STOD(SD3TMP->EMISSAO)
		    nRegSD3 := SD3TMP->RegSD3
        EndIf

	    cAliasTemp:= "SH6TMP"
	    cQuery	  := "  SELECT COUNT(*) AS RegSH6 "
	    cQuery	  += "   FROM " + RetSqlName('SH6')
	    cQuery	  += "   WHERE H6_FILIAL   = '" + xFilial('SH6')+ "'"
	    cQuery	  += "     AND H6_OP 	   = '" + cOp + "'"
	    cQuery	  += "     AND D_E_L_E_T_  = ' '"
	    cQuery    := ChangeQuery(cQuery)
	    dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

	    If !SH6TMP->(Eof())
	    	nRegSH6 := SH6TMP->RegSH6
	    EndIf

        SD3TMP->(DbCloseArea())
	    SH6TMP->(DbCloseArea())
    EndIf

    If !lAchou
        If cTpo == "F" .And. Empty(cDatrf) .And. (nRegSD3 < 1 .And. nRegSH6 < 1) .And. (Max(dDataBase - cDTINI,0) < If(cDatOci==0,1,cDatOci)) //2-Em aberto            
            cStatusOp := '2'
            lAchou := .T.
        EndIf
    EndIf

    If !lAchou
        If cTpo == "F" .And. Empty(cDatrf) .And. (nRegSD3 > 0 .Or. nRegSH6 > 0) .And. (Max((ddatabase - dEmissao),0) > If(cDatOci >= 0,-1,cDatOci)) //3-Iniciada
            cStatusOp := '3'
            lAchou := .T.
        EndIf
    EndIf

    If !lAchou
        If cTpo == "F" .And. Empty(cDatrf) .And. (Max((ddatabase - dEmissao),0) > cDatOci .Or. Max((ddatabase - cDTINI),0) >= cDatOci)  //4-Ociosa
            cStatusOp := '4'
            lAchou := .T.
        EndIf
    EndIf
    
Return cStatusOp


/*/{Protheus.doc} Static Function fExistOp
Retorna se existe ordem de produção para a pesquisa efetuada - código completo ou parcial
@type  WSMETHOD
@author michele.girardi
@since 04/10/2021
@version P12.1.33
@param cFilterSearch - Ordem de produção ou Item - conforme cTipo
@param cTipo - Pesquisar pela OP ou por item (OP - IT)
@param cCP - Pesquisa completa ou parcial (C - P)
@return lExistOp - Existe ordem de produção com o filtro informado
/*/
Static Function fExistOp(cFilterSearch, cTipo, cCP)
    
    Local cAliasOp   := GetNextAlias()
    Local cCharSoma  := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ")
    Local cQuery     := ""
    Local lExistOp   := .F.
    Local nCount     := 0
        
    Default cCP := ""
    Default cFilterSearch := ""
    Default cTipo := ""

    cQuery := "  SELECT COUNT(*) COUNT "
    cQuery += "    FROM " + RetSqlName("SC2") + " SC2 "
    cQuery += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1")+ "' AND SB1.B1_COD = SC2.C2_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += "   WHERE SC2.C2_FILIAL  = '" + xFilial( "SC2" ) + "'"	
    
    If cTipo = 'OP' //Pesquisa por OP
        If cCP = 'C' //OP Completa
            cQuery += " AND SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD  =  '" +cFilterSearch+ "'"	
        Else
            cQuery += " AND SC2.C2_NUM = '" +cFilterSearch+ "'"	
        EndIf
    EndIf

    If cTipo = 'IT' //Pesquisa por Item
        If cCP = 'C' //Item Completo
             cQuery += " AND SC2.C2_PRODUTO = '" +cFilterSearch+ "'"
        Else
            cQuery += " AND SC2.C2_PRODUTO LIKE ( '%" + TRIM(cFilterSearch)+ "%' )"
        EndIf
    EndIf
    
    If cTipo = 'BC' //Pesquisa por código de barra
        If cCP = 'C' //código de barra Completo
             cQuery += " AND SB1.B1_CODBAR = '" +cFilterSearch+ "'"
        Else
            cQuery += " AND SB1.B1_CODBAR LIKE ( '%" + TRIM(cFilterSearch)+ "%' )"
        EndIf
    EndIf

    cQuery += "    AND SC2.D_E_L_E_T_  = ' ' "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasOp,.T.,.T.)
	If (cAliasOp)->(!Eof())		
		nCount := (cAliasOp)->COUNT
	EndIf

	(cAliasOp)->(DBCloseArea())

    If nCount > 0
        lExistOp := .T.
    EndIf

Return lExistOp

/*/{Protheus.doc} Static Function fCargaLast
Carrega as OPs que foram apontadas
@type  WSMETHOD
@author michele.girardi
@since 31/08/2021
@version P12.1.33
@param cUser - Usuário que realizou o apontamento
@param cAppointmentType - Tipo do apontamento (1 - Simples, 3 - MOD 2, 4 - SFC, 'BRANCO' - Todos Tipos, 9 - Automação estrutural SFC)
@param nTotReg - Quantidade de ordens a serem retornadas
@param aOPs - Array com as OPs da consulta
@param cMachineCode - Código da máquina SFC
@return Nil
/*/
Static Function fCargaLast(cUser, cAppointmentType, nTotReg, aOPs, cMachineCode)
     
    Local cAliasLast := GetNextAlias()
    Local cOp        := ""
    Local cProd      := ""
    Local cQuery     := ""
    Local cUsersId   := ""
    Local dData      := ""  
    Local lExistSMO  := .F.
    Local lRet       := .T.
    Local nAchou     := 0
    Local nCont      := 0

    Default aOPs     := {}
    Default cUser    := ""
    Default cAppointmentType := ""
    Default nTotReg  := 0

    If AliasInDic("SMO")
        lExistSMO  := .T.
    EndIf

    cUsersId := PCPCodUsr(cUser)

    cQuery := " "

	If Empty(cAppointmentType) .Or. cAppointmentType == '1' .Or. cAppointmentType == '0'
        cQuery += "  SELECT DISTINCT D3_OP ORDEM_PRODUCAO, D3_COD PRODUTO, D3_EMISSAO DATA_EMISSAO"
	    cQuery += "    FROM " + RetSqlName("SD3") + " SD3 " 

        If lExistSMO
           cQuery +=  " , " + RetSqlName("SMO") + " SMO " "
        EndIf

	    cQuery += "   WHERE SD3.D3_FILIAL  = '" + xFilial( "SD3" ) + "'"
	    cQuery += "     AND SD3.D3_CF      = 'PR0' "
	    cQuery += "     AND SD3.D3_ESTORNO = ' ' "
	    cQuery += "     AND SD3.D_E_L_E_T_  = ' ' "

        If lExistSMO
            cQuery += "     AND SMO.MO_FILIAL   = '" + xFilial( "SMO" ) + "'"
	        cQuery += "     AND SMO.MO_TIPO     = '1' " //Apontamento Simples
            cQuery += "     AND SMO.MO_IDAPON   =  SD3.D3_NUMSEQ "
            cQuery += "     AND SMO.MO_CODUSU   =  '"+ cUsersId + "' "
	        cQuery += "     AND SMO.D_E_L_E_T_  = ' ' "
        EndIf
    EndIf

    If Empty(cAppointmentType) .Or. cAppointmentType == '3' .Or. cAppointmentType == '0'          
        If Empty(cAppointmentType) .Or. cAppointmentType == '0'
            cQuery += " UNION "   
        EndIf

        cQuery += "  SELECT DISTINCT H6_OP ORDEM_PRODUCAO, H6_PRODUTO PRODUTO, H6_DTPROD DATA_EMISSAO"
        cQuery += "    FROM " + RetSqlName("SH6") + " SH6 " 

        If lExistSMO
            cQuery += " , " + RetSqlName("SMO") + " SMO " "
        EndIf

        cQuery += "   WHERE SH6.H6_FILIAL  = '" + xFilial( "SH6" ) + "'"
        cQuery += "     AND SH6.H6_OP  <> ' ' "
        cQuery += "     AND SH6.D_E_L_E_T_  = ' ' "

        If lExistSMO
            cQuery += "     AND SMO.MO_FILIAL   = '" + xFilial( "SMO" ) + "'"
	        cQuery += "     AND SMO.MO_TIPO     = '3' " //Apontamento Modelo 2
            cQuery += "     AND SMO.MO_IDAPON   =  SH6.H6_IDENT  "
            cQuery += "     AND SMO.MO_CODUSU   =  '"+ cUsersId + "' "
	        cQuery += "     AND SMO.D_E_L_E_T_  = ' ' "
        EndIf
    EndIf

    If Empty(cAppointmentType) .Or. cAppointmentType == '4' .Or. cAppointmentType == '9' .Or. cAppointmentType == '0'
        If Empty(cAppointmentType) .Or. cAppointmentType == '0'
            cQuery += " UNION " 
        EndIf

        cQuery += "  SELECT DISTINCT CYV_NRORPO ORDEM_PRODUCAO, CYV_CDACRP PRODUTO, CYV_DTRP DATA_EMISSAO"
        cQuery += "    FROM " + RetSqlName("CYV") + " CYV " 

        If lExistSMO
           cQuery += " , " + RetSqlName("SMO") + " SMO " "
        EndIf

        cQuery += "   WHERE CYV.CYV_FILIAL  = '" + xFilial( "SH6" ) + "'"
        cQuery += "     AND CYV.CYV_NRORPO  <> ' ' "
        cQuery += "     AND CYV.CYV_LGRPEO  = 'F' "
        If !Empty(cMachineCode)
            cQuery += "     AND CYV.CYV_CDMQ = '"+cMachineCode+"' "
        EndIf
        cQuery += "     AND CYV.D_E_L_E_T_  = ' ' "

         If lExistSMO
            cQuery += "     AND SMO.MO_FILIAL   = '" + xFilial( "SMO" ) + "'"
	        cQuery += "     AND SMO.MO_TIPO     = '4' " //Apontamento SFC
            cQuery += "     AND SMO.MO_IDAPON   =  CYV.CYV_NRSQRP  "
            cQuery += "     AND SMO.MO_CODUSU   =  '"+ cUsersId + "' "
	        cQuery += "     AND SMO.D_E_L_E_T_  = ' ' "
        EndIf
    EndIf

    cQuery += "     ORDER BY 3 DESC "
        
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasLast,.T.,.T.)
	While (cAliasLast)->(!Eof())
		
		cOp   := (cAliasLast)->ORDEM_PRODUCAO
        cProd := (cAliasLast)->PRODUTO
        dData := (cAliasLast)->DATA_EMISSAO

        If !Empty(cAppointmentType) .And. cAppointmentType <> '0'
            lRet := fValidTipo(cOp, cAppointmentType,'AP')

            If !lRet
                (cAliasLast)->(dbSkip())
                Loop
            EndIf 
        EndIf
        
        nAchou := 0
        If len(aOPs) > 0
            nAchou := aScan(aOPs,{|x| x[1]==cOp .And. x[2]==cProd})
        EndIF
        
        If nAchou == 0
            AAdd(aOPs,{cOp, cProd} )
            nCont += 1
        EndIF

        If nCont == nTotReg
            Exit
        EndIF		

        (cAliasLast)->(dbSkip())
	End

	(cAliasLast)->(DBCloseArea())

Return

/*/{Protheus.doc} Static Function fValidTipo
Valida se a OP apontada é referente ao tipo do apontamento selecionado
@type  WSMETHOD
@author michele.girardi
@since 31/08/2021
@version P12.1.33
@param cOP - Ordem de Produção
@param cAppointmentType - Tipo do Apontamento - Formulário
@param cTipoVal - Tipo da validação - OP (ordem) ou AP (apontamento)

@return lRet - T ou F
/*/
Static Function fValidTipo(cOp, cAppointmentType,cTipoVal)

    Local aAreaSH6  := SH6->(GetArea())
    Local aAreaCYV  := CYV->(GetArea())
    Local aAreaCYQ  := CYQ->(GetArea())
    Local lRet      := .T.
    
    Default cAppointmentType := ""
    Default cOp              := ""
    Default cTipoVal         := ""

    If cAppointmentType == '1' //Produção Simples - MATA250
        
        If cTipoVal == 'OP'
            //Não pode existir OP na CYQ
            dbSelectArea("CYQ")
            CYQ->(dbSetOrder(1))
            If CYQ->(dbSeek(xFilial("CYQ")+cOp))
                lRet := .F.
            EndIf
        Else
            //Não pode possuir apontamento na SH6 e CYV
            SH6->(dbSetOrder(1))
	        If SH6->(dbSeek(xFilial("SH6")+cOp))
                lRet := .F.
            EndIf

            If lRet
                CYV->(dbSetOrder(2))
	            If CYV->(dbSeek(xFilial("CYV")+cOp))
                    lRet := .F.
                EndIf
            EndIf
        EndIf         
    EndIf
    
    If cAppointmentType == '3' //Produção MOD 2 - MATA681
        
        If cTipoVal == 'OP'
            //Não pode existir OP na CYQ
            dbSelectArea("CYQ")
            CYQ->(dbSetOrder(1))
            If CYQ->(dbSeek(xFilial("CYQ")+cOp))
                lRet := .F.
            EndIf
        Else                       
            //Deve possuir apontamento na SH6        
            SH6->(dbSetOrder(1))
	        If !(SH6->(dbSeek(xFilial("SH6")+cOp)))
                lRet := .F.
            EndIf
        
            //Não pode possuir apontamento na CYV
            If lRet
                CYV->(dbSetOrder(2))
	            If CYV->(dbSeek(xFilial("CYV")+cOp))
                    lRet := .F.
                EndIf
            EndIf
        EndIf
    EndIf

    If cAppointmentType == '4' //Produção CYV

        If cTipoVal == 'OP'
            //Deve existir OP na CYQ
            dbSelectArea("CYQ")
            CYQ->(dbSetOrder(1))
            If !(CYQ->(dbSeek(xFilial("CYQ")+cOp)))
                lRet := .F.
            EndIf
        Else
            //Deve possuir apontamento na CYV
            CYV->(dbSetOrder(2))
	        If !(CYV->(dbSeek(xFilial("CYV")+cOp)))
                lRet := .F.
            EndIf
        EndIf        
    EndIf

    SH6->(RestArea(aAreaSH6))
    CYV->(RestArea(aAreaCYV))
    CYQ->(RestArea(aAreaCYQ))

Return lRet

