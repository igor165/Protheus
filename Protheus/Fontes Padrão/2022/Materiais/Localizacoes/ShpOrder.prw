#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"
#INCLUDE "TOPCONN.CH"
#xcommand XCONOUT [<message>] => conout( '[ShpInt001] [Thread ' + cValtoChar( threadId() ) + '] [' + dtoc( date()) + ' ' + time() + '] ' + alltrim( <message> ) )


/*/{Protheus.doc} ShpOrder
    (long_description)
    @author Izo Cristiano
    @since 25/03/2020
    @version version
    
/*/
Class ShpOrder From ShpBase
    Data aOrders    As Array
    Data cSerie 	as String  //TODO - Criar parametro para serie de venda
    Data cCondPgto 	as String  //TODO - Veriricar como será tratado a condicao de pagamento
    Data cEstInvoic as String  //TODO - Verificar como será tratado o estado
    Data cTes     	as String  //TODO - Verifica com vai funcionar provavelment um calcula imposto e outro nao
    Data cArmazen 	as String  //TOD - Parametro para armazenar o armazem do Shopyfy.
    Data cBancoBX 	as String  //TOD - Parametro para armazenar o banco de baixa do Shopify.
    Data PatchPesq  as String
    Data cMsgError  as String 
    Data cTesFret   as String   //TES Padrao do Produto Frete no Refunds
    Data cPrdFre    as String   //Codigo do Produto Frete no Refundas
 
    Method new() Constructor
    Method setRequestBody()//Provavelmente será vazio
    Method setVerb()//Sobrescrever para setar GET
    Method setPath()//Sobrescrever para setar GET
    Method procResponse(oResponse,cResponse)
    Method procOrders() //processa todas as Orders do Shopfy
    Method geraOrder(aOrder) //geracao de Sales Orders e invoices
    Method getLineTax(aTaxes) //pega o valor do imposto no lineitens
    Method excTaxItens(cOrder) //apaga as taxas na tabela A1L caso de algum erro de processamento
    Method ReceivPost() //responsavel para dar baixa a receber nos titulos
    Method GeraInvoice(cNumPed) //metodo que serve para gerar a invoice
    Method ValidOrder(aOrder) //validacao da order que vem do shopify
    Method geraOrderInvoice(aOrder) //metodo que está por enquanto inativo NAO UTILIZAR
    Method getOrderId(id) //metodo que serve para processar somente uma order especifica
    Method getOrders() //metodo que server para processar varias ordes ao mesmo tempo
    Method getMsgError()
    Method getRefunds(aOrder) //metodo que server para verificar se tem refunds
    Method addNCCFrete(aDados)

EndClass


/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
Method new() Class ShpOrder
    ::cIntegration := ID_INT_ORDER
    ::PatchPesq    := ""
    ::cMsgError    := ""
    _Super:new()
Return


/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
Method getOrderId(id) class ShpOrder
    ::PatchPesq := "?ids=" + Alltrim(id)
Return 

/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
Method getOrders() class ShpOrder

    Local dLastUpd  := ""
    local aArea 	:= getArea()
    Local cQuery    := ""
    Local cAlias    := GetNextAlias()

    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    EndIf

    cQuery := "SELECT TOP 1 A1D_LASTUP FROM " + retSQLName("A1D") + " "  + CRLF
    cQuery += "WHERE A1D_ALIAS IN ('SC5','SF1','SE1') AND D_E_L_E_T_ = ' ' "  + CRLF
    cQuery += "ORDER BY A1D_LASTUP DESC " + CRLF

    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias)

    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    If !(cAlias)->(Eof())
        dLastUpd := "?updated_at_min=" + Alltrim((cAlias)->A1D_LASTUP)
    EndIf 

    (cAlias)->(DbCloseArea())

    restArea(aArea)

    ::PatchPesq := dLastUpd
Return


/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
Method setPath() Class ShpOrder
    Local lRet := .T.
    _Super:setPath()
    ::path += ::PatchPesq
Return lRet



/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
Method getMsgError() Class ShpOrder

Return ::cMsgError


/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
Method setVerb() class ShpOrder
    ::verb := REST_METHOD_GET
Return .T.


/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
Method setRequestBody()class ShpOrder
    ::body := ""
Return .T.


/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
Method  procResponse(oResponse,cResponse) class ShpOrder
    Local lRet := .T.
    
    ::aOrders := aClone(oResponse:orders)
    lRet := ::procOrders() //caso de erro na hora de processar retorna false

return lRet


/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
Method procOrders() Class ShpOrder

    local lErro := .F.
    local lRet  := .T.
    local i
    ::cMsgError := ""

    ::cSerie    := ShpGetPar("SERIEPAD","B  ",STR0025)//"Serie padrão utilizado para o faturamento
    ::cCondPgto := ShpGetPar("CONPAD","001",STR0026)//"Condição padrão utilizado para o faturamento
    ::cEstInvoic:= "FL"//TODO - Verificar como será tratado o estado
    ::cTes      := ShpGetPar("TESTAXA","510",STR0027)//TES PADRAO QUE COBRA TAXA
    ::cArmazen  := ShpGetPar("LOCPAD","01",STR0024,)//ARMAZEM PADRAO DE ARMAZENAMENTO
    ::cBancoBX  := ShpGetPar("BANCOBX","BOA063100277229056541158        ",STR0028) //Banco padrao para dar baixa nos titulos

    ::cTesFret  := ShpGetPar("TESFRETE" ,"",STR0165 )//"Tes use from freight refunds"
    ::cPrdFre   := ShpGetPar("PRODFRETE","" ,STR0166,)//"Product code use to freight refunds"


    If !Existcpo("SX5","01" + ::cSerie ) //Verifica se tem cadastrado a Serie da Nota Fiscal
        lErro := .T.
        //::cMsgError += "Error - Serie number: " + ::cSerie + ", dint find in SX5 Table"   + CRLF 
        ::cMsgError += STR0039 + ::cSerie + STR0040   + CRLF 
    EndIf

    If !ExistCpo("SE4",::cCondPgto)    //Verifica se tem cadastrado a Condicao de pagamento padrao
        lErro := .T.
        //::cMsgError += "Error - Paymente condiction: " + ::cCondPgto+ ", dint find in SE4 Table"   + CRLF        
       ::cMsgError += STR0041 + ::cCondPgto+ STR0042   + CRLF         
    EndIf

    If !ExistCpo("SF4",::cTes)          //Verifica se tem cadastrado o TES
        lErro := .T.
        //::cMsgError += "Error - TES: " + ::cTes + ", dint find in SF4 Table"   + CRLF 
        ::cMsgError += STR0043 + ::cTes + STR0044   + CRLF                   
    EndIf

    //checa se foi configurado o TES corretamente com a funcao EUATAX, caso nao deixa gera order
    SFC->(dbSetOrder(2))
    If !SFC->( dbSeek( xFilial("SFC") + substring(::cTes,1,3) + "EUA" ) )
        lErro := .T.
        ::cMsgError += STR0121  + ::cTes + STR0122    + CRLF  //"EUA TAX from TES:" //"didnt not find in SFC TABLE, need to configure the TES"             
    EndIf


    If !ExistCpo("NNR",::cArmazen)    //Verifica se tem cadastrado o Armazem
        lErro := .T.
        //::cMsgError += "Error - Warehouse: " + ::cArmazen + ", dint find in NNR Table"   + CRLF   
        ::cMsgError += STR0045  + ::cArmazen + STR0046    + CRLF              
    EndIf

    If !ExistCpo("SA6",::cBancoBX)  //Verifica se tem cadastrado o Banco
        lErro := .T.
        //::cMsgError += "Error - Bank Acoutant: " + ::cBancoBX + ", dint find in SA6 Table"   + CRLF   
        ::cMsgError += STR0047 + ::cBancoBX + STR0048   + CRLF                
    EndIf

    If lErro
        //aqui eu gravo o Log de Erro
        ShpSaveErr("0000000000", "", ID_INT_INTERNAL_ERROR , ::cMsgError, ::path, ::apiVer, "000000", ::verb) 
    Else
        For i := 1 to len(::aOrders)


           //aqui eu verifico se já existe a order gravada caso sim verifico se tem refundas ou return
            If !ShpExistId("SC5",cValToChar(::aOrders[i]:ORDER_NUMBER),,,.T.) //TODO - verificar se usamos o order number ou o id (ACHO QUE FICA MELHOR COM O ORDER NUMBER)
                If ::ValidOrder(::aOrders[i]) //aqui eu valido a order para verificar se está faltando alguma informação importante
                    lErro := ::geraOrder(::aOrders[i])
                Else 
                    lErro := .T. 
                EndIf 
            else //caso já exista eu verifico se tem refunds ou return
                lErro := ::getRefunds(::aOrders[i]) 
            endif 
           
        Next i

    EndIf 


    //Caso tenha dado algum erro retorna False
    If lErro
        lRet := .F. 
    EndIf 

Return lRet


/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
Method geraOrder(aOrder) Class ShpOrder

    Local cNumOrder
	local aArea 	:= getArea()
    local aCabec   :=  {}
    local aItem     :=  {}
    local aItens    :=  {}
 
    //variaveis usadas para dados do produto
    local nQuant      
    local nPrcVen     
    local nPrcTotal   
    local nDescont 

    //variaveis usada para utilizar parametros
    local cCliente  := "" //TODO - Verificar com eu vou trazer o cliente e loja
    local cLoja     := "" //TODO - Verificar com eu vou trazer o cliente e loja
    local cCliShip  := "" 
    local cLojaShip := "" 
    local i   
    local nVlFrete  

    //variavel de busca de clientes
    local nRecCli     := 0
    local nRecCliShip := 0
	local cErrCli     := ""
    local lErro       := .F. 

    local cVendPad := ShpGetPar("VENDEDOR","",STR0117) //"Vendedor Padrao"
    local cTranPad := ShpGetPar("TRANSPORT","",STR0118) //"Transportadora Padrao"    
    local cTabPad  := ShpGetPar("TABPRECO" , "" , STR0019, "1")//"Tabela de Preco Padrao"

    Private oOrder := aOrder
 
    ::cMsgError := " "

    //aqui eu verifico se tem algum problema nos itens antes de continuar com o processo
    XCONOUT  STR0123  + cValToChar(aOrder:ORDER_NUMBER)  + STR0124 //'ORDER NUMBER: ' //[START OF INTEGRATION]

    If Type("oOrder:customer") == "U" //que dizer que não existe dados de cliente entao eu pego cliente padrao
        cCliente  := "000001" //TODO - Verificar com eu vou trazer o cliente e loja
        cLoja     := "0001" //TODO - Verificar com eu vou trazer o cliente e loja
    EndIf

    //todo - verificar endereco correto e tambem caso nao tenha cliente pegar um padrao
	If !Empty(cCliente) .OR. ShpUpdCust(aorder:customer, aorder:billing_address, @nRecCli, @cErrCli, aorder:SHIPPING_ADDRESS, @nRecCliShip)

        XCONOUT  STR0123   + cValToChar(aOrder:ORDER_NUMBER)  + STR0125 //'ORDER NUMBER: ' //'[CUSTOMER FOUND OR SUCCESSFULLY ADDED]'

        //Busco o Cliente
        SA1->(DbGoTo(nRecCli))

        cCliente  := SA1->A1_COD
        cLoja     := SA1->A1_LOJA

        //Cliente de entrega
        If nRecCli == nRecCliShip
            cCliShip  := cCliente
            cLojaShip := cLoja
        Else
            If nRecCliShip > 0
                SA1->(DbGoTo(nRecCliShip))
                cCliShip  := SA1->A1_COD
                cLojaShip := SA1->A1_LOJA
            EndIf
        EndIf

        aAdd( aCabec, { "C5_FILIAL"    , xFilial("SC5") , Nil } )	
        aAdd( aCabec, { "C5_TIPO"    , "N"       		, Nil } )
        aAdd( aCabec, { "C5_CLIENTE" , cCliente		    , Nil } )
        aAdd( aCabec, { "C5_LOJACLI" , cLoja        	, Nil } )
        aAdd( aCabec, { "C5_CLIENT"  , cCliShip		    , Nil } )
        aAdd( aCabec, { "C5_LOJAENT" , cLojaShip      	, Nil } )
        aAdd( aCabec, { "C5_FMAPAGT" , "CC"       		, Nil } )
        aAdd( aCabec, { "C5_CONDPAG" , ::cCondPgto	    , Nil } )

        aAdd( aCabec, { "C5_CODMUN" , SA1->A1_COD_MUN	    , Nil } )
        aAdd( aCabec, { "C5_PROVENT" , SA1->A1_COD_MUN	    , Nil } )
        
        //TODO: Definir se nao houver atividade no cliente.
        If Empty(SA1->A1_ATIVIDA)
            aAdd( aCabec, { "C5_TPACTIV" , "0001"	    , Nil } )
        Else
            aAdd( aCabec, { "C5_TPACTIV" , SA1->A1_ATIVIDA    , Nil } )
        EndIf

        //aqui eu crie variavel frete para ficar melhor entendivel
        nVlFrete := Val(StrTran(StrTran(aOrder:TOTAL_SHIPPING_PRICE_SET:PRESENTMENT_MONEY:AMOUNT,",",""),",",".")) 
        If  nVlFrete > 0  //quer dizer que esta cobrando frete
            XCONOUT  STR0123  + cValToChar(aOrder:ORDER_NUMBER)  + '['+ STR0167  +']' // 'ORDER NUMBER: ' // FRETE EXISTS
            aAdd( aCabec, { "C5_TPFRETE", "F"       	, Nil } )
            aAdd( aCabec, { "C5_FRETE"  , nVlFrete	    , Nil } )
        else
            aAdd( aCabec, { "C5_TPFRETE", "C"       	, Nil } )            
        endif    

        //TODO VERIFICAR SE CRIA PARAMETROS PARA ESTES CAMPOS
        aAdd( aCabec, { "C5_TRANSP", cTranPad      	, Nil } )            
        aAdd( aCabec, { "C5_TABELA", cTabPad       	, Nil } )  
        aAdd( aCabec, { "C5_VEND1",  cVendPad      	, Nil } )          
                         
        For i:= 1 to len(aOrder:LINE_ITEMS)

            aSize(aItem, 0)//zerando o array de item

            nQuant      := aOrder:LINE_ITEMS[i]:QUANTITY	
            nPrcVen     := Val(StrTran(StrTran(aOrder:LINE_ITEMS[i]:PRICE,",",""),",","."))
            nPrcTotal   := nPrcVen * nQuant
            nDescont    := Val(StrTran(StrTran(aOrder:LINE_ITEMS[i]:TOTAL_DISCOUNT,",",""),",","."))  

            aAdd( aItem, { "C6_ITEM" 	, strzero(i, tamSX3("D2_ITEM")[1])	, Nil } )
            aAdd( aItem, { "C6_PRODUTO" , aOrder:LINE_ITEMS[i]:SKU			, Nil } )
            aAdd( aItem, { "C6_QTDVEN"	, nQuant						    , Nil } )
            aAdd( aItem, { "C6_PRCVEN"	, nPrcVen				        	, Nil } )
            aAdd( aItem, { "C6_PRUNIT"	, nPrcVen				        	, Nil } )
            aAdd( aItem, { "C6_VALOR"	, nPrcTotal				        	, Nil } )
            aAdd( aItem, { "C6_QTDLIB"	, nQuant 							, Nil } )
            aAdd( aItem, { "C6_TES"		, ::cTes							, Nil } )
            aadd( aItem, { "C6_DESCONT"	, nDescont                        	, nil } )
            aadd( aItem, { "C6_LOCAL"   , ::cArmazen                       	, nil } )
            aadd( aItens, AClone(aItem))

        Next i 

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //| Inicio da Transaction |
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        BEGIN TRANSACTION
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //| Grava Pedido de Vendas		|
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            lMsErroAuto     := .F.
            lMsHelpAuto     := .F.
	        lAutoErrNoFile  := .T.            

            MSExecAuto( {|x, y, z| MATA410( x, y, z )}, aCabec, aItens, 3 )
        
            If lMsErroAuto
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //| Abandona caso haja erros    |
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                ::cMsgError += STR0049 + ShpDetErr() //"ERRO na geração da Sales Order MATA410: "
                lErro  := .T.                 
                XCONOUT  STR0123  + cValToChar(aOrder:ORDER_NUMBER)  + STR0126+ ::cMsgError //'ORDER NUMBER: '//"[MATA410 INTEGRATION ERROR CHECK LOG]"
            Else
                RecLock("SC5", .F.)
                SC5->C5_MENNOTA := STR0168 + cValToChar(aOrder:ORDER_NUMBER) //"Shopify Order N: "
                //SC5->C5_PEDCLI  := Substr( cValToChar(aOrder:ORDER_NUMBER) ,1,9 )
                SC5->(MsUnLock())
                cNumOrder := SC5->C5_NUM

                XCONOUT  STR0123  + cValToChar(aOrder:ORDER_NUMBER)  + '[' + STR0127 + cNumOrder + ' ]' //'ORDER NUMBER: ' //"SUCCESSFULLY GENERATED SALES ORDER NUMERO :" 

                //por seguranca eu deleto todas as taxas que estiverem na A1L da order para serem criadas novamentes com isto evita duplicdade de impostos por algum erro
                 ::excTaxItens(cValToChar(aOrder:ORDER_NUMBER))	

                //aqui vou gravar os dados dos impostos
                For i:= 1 to len(aOrder:LINE_ITEMS)
                    cItem := strzero(i, tamSX3("D2_ITEM")[1])
                    //aqui eu gero as taxas do item na tabela A1L
                    ::getLineTax(cValToChar(aOrder:ORDER_NUMBER),aOrder:LINE_ITEMS[i]:TAX_LINES,aOrder:LINE_ITEMS[i],cNumOrder,::cSerie,cCliente,cLoja,,cItem)
                Next i 

                //aqui vou gravar os dados de frete com impostos
                If nVlFrete > 0 
                    //gera os impostos do frete na tabela temporaria A1L
                    ::getLineTax(cValToChar(aOrder:ORDER_NUMBER),aOrder:SHIPPING_LINES[1]:TAX_LINES,aOrder:SHIPPING_LINES[1],cNumOrder,::cSerie,cCliente,cLoja,.T.)
                EndIf

                //aqui eu faturo o Pedido de venda
                If !::GeraInvoice(cNumOrder,aOrder)
                    XCONOUT  STR0123  + cValToChar(aOrder:ORDER_NUMBER)  + '[###' + STR0128 + cNumOrder + ' ]' //'ORDER NUMBER: '// "INVOICE GENERATION ERROR"
                    lErro  := .T.
                    //caso tenha dado erro eu preciso deletar as taxas na tabela A1L
                    ::excTaxItens(cValToChar(aOrder:ORDER_NUMBER))
                Else
                    ShpSaveId( "SC5",SC5->(RECNO()),cValToChar(aOrder:ORDER_NUMBER),"","",aOrder:UPDATED_AT)
                    XCONOUT  STR0123  + cValToChar(aOrder:ORDER_NUMBER)  + '[' + STR0129 + '!!!!!!!!!!!!!]' //'ORDER NUMBER: '//"PROCESS HAS BEEN SUCCESSFULLY COMPLETED"

                EndIf
               
            EndIf

            If lErro 
                DisarmTransaction()
                //aqui eu gravo o Log de Erro
                //TODO verificar melhor como transformar o aOrder em um json
                ShpSaveErr("", cValToChar(aOrder:ID), ::cIntegration, ::cMsgError, ::path, ::apiVer, oOrder, ::verb) 
            EndIf

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //| Fim da Transaction |
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        END TRANSACTION

    Else 
        //grava erro do cliente
    	//ShpSaveErr(cValToChar(nRecCli), cIdExt, ::cIntegration, cErrCli, oInt:path, oInt:apiVer, oInt:body, oInt:verb)
        //grava erro da order
        ShpSaveErr("",cValToChar(aOrder:ID), ::cIntegration, cErrCli, ::path, ::apiVer, aOrder, ::verb)         
        XCONOUT  STR0123  + cValToChar(aOrder:ORDER_NUMBER)  + '[###' + STR0130 + ' ]' // 'ORDER NUMBER: '//"CUSTOMER CREATION ERROR"
        lErro  := .T.
    EndIf    

    restArea(aArea)

Return lErro

/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
Method getLineTax(cOrder,aTaxes,aItem,cInvoice,cSerie,cClient,cLoja,lFrete,cItem) Class ShpOrder

	local aArea 	:= getArea()
    local i 
    
    Default lFrete := .F. 
    Default cItem := strzero(1, tamSX3("D2_ITEM")[1])
    
    for i:=1 to len(aTaxes)

        If lFrete
            cCodProd := "FRETE"
            nBaseImp    := Val(StrTran(StrTran(aItem:PRICE,",",""),",",".")) 
        else
            cCodProd := aItem:SKU                
            nBaseImp := Val(StrTran(StrTran(aItem:PRICE,",",""),",",".")) * aItem:QUANTITY
        EndIf 

        nValImp     := Val(StrTran(StrTran(aTaxes[i]:PRICE ,",",""),",",".")) 
        nAliqImp    := aTaxes[i]:RATE * 100
        cTaxCode    := aTaxes[i]:TITLE

        dbSelectArea("A1L")
        RecLock("A1L", .T. )
        A1L->A1L_FILIAL := xFilial("A1L")
        A1L->A1L_ID     := cValToChar(aItem:ID)
        A1L->A1L_SKU    := cCodProd
        A1L->A1L_ITEM   := cItem//cValToChar(aItem:ID)
        A1L->A1L_ORDER  := cOrder
        A1L->A1L_VALIMP := nValImp
        A1L->A1L_BASIMP := nBaseImp 
        A1L->A1L_ALIIMP := nAliqImp  
        A1L->A1L_TAXCOD := cTaxCode
        A1L->A1L_INVOIC := cInvoice
        A1L->A1L_SERIE  := cSerie
        A1L->A1L_CLIENT := cClient
        A1L->A1L_LOJA   := cLoja
        A1L->(MsUnlock())
    next i 

 	restArea(aArea)

Return 

/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
Method excTaxItens(cOrder) Class ShpOrder

    If A1L->( dbSeek( xFilial("A1L") + cOrder   ))
        While A1L->(!Eof()) .AND. Alltrim(A1L->A1L_ORDER) == Alltrim(cOrder) 
            RecLock("A1L")
            A1L->(dbDelete())
            A1L->(dbSkip())
        End 
    EndIf

Return


/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
method ReceivPost(xFilial,cCliente,cLoja,cSerie,cNumDoc,aOrder,cMsgPost) class ShpOrder
	
	local aArea		    := getArea()
    local cMsgHistor    := STR0029 + cValToChar(aOrder:ORDER_NUMBER) //TODO - MELHORA MENSAGEM A SER GERADO NA HORA DA BAIA
    local lBaixou       := .F.

    Default cMsgPost := ""
    Private MV_PAR08 := 2

    if Empty(cMsgPost)
        cMsgHistor    := STR0029 + cValToChar(aOrder:ORDER_NUMBER) //TODO - MELHORA MENSAGEM A SER GERADO NA HORA DA BAIA
    else
        cMsgHistor    := cMsgPost
    endif 

    //aqui eu vejo se existe o banco cadastrado para dar baixa
    SA6->( DbSetOrder(1) ) //A6_FILIAL+A6_NOME
    If SA6->( dbSeek(xFilial('SA6') + ::cBancoBX ))

        //aqui eu posiciono no registro do SE1
        SE1->(dbSetOrder(2)) //E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO
        If SE1->(dbSeek( xFilial + cCliente + cLoja + cSerie + cNumDoc ) )

            // XCONOUT 'Integrando Order Numero: '

            While SE1->(!Eof()) .AND. xFilial + cCliente + cLoja + cSerie + cNumDoc == SE1->E1_FILIAL + SE1->E1_CLIENTE + SE1->E1_LOJA + SE1->E1_PREFIXO + SE1->E1_NUM

                lMsErroAuto := .F.
                lMsHelpAuto := .F.

                _aTiBaixa := {}

                AADD(_aTiBaixa , {"E1_PREFIXO"  ,SE1->E1_PREFIXO    ,NIL})
                AADD(_aTiBaixa , {"E1_NUM"	 	,SE1->E1_NUM        ,NIL})
                AADD(_aTiBaixa , {"E1_PARCELA" 	,SE1->E1_PARCELA    ,NIL})
                AADD(_aTiBaixa , {"E1_TIPO"    	,SE1->E1_TIPO       ,NIL})
                AADD(_aTiBaixa , {"E1_CLIENTE" 	,SE1->E1_CLIENTE    ,NIL})
                AADD(_aTiBaixa , {"E1_LOJA"    	,SE1->E1_LOJA       ,NIL})
                AADD(_aTiBaixa , {"AUTMOTBX"    ,"NOR"              ,Nil})
                AADD(_aTiBaixa , {"AUTBANCO"    ,SA6->A6_COD        ,Nil})
                AADD(_aTiBaixa , {"AUTAGENCIA"  ,SA6->A6_AGENCIA    ,Nil})
                AADD(_aTiBaixa , {"AUTCONTA"    ,SA6->A6_NUMCON     ,Nil})
                AADD(_aTiBaixa , {"AUTDTBAIXA"  ,dDatabase          ,Nil})
                AADD(_aTiBaixa , {"AUTDTCREDITO",dDatabase          ,Nil})
                AADD(_aTiBaixa , {"AUTHIST"     ,cMsgHistor         ,Nil})
                AADD(_aTiBaixa , {"AUTDESCONT"	,0              	,Nil})  //Valores de desconto
                AADD(_aTiBaixa , {"AUTACRESC"	,0 	               	,Nil})  //Valores de acrescimo - deve estar cadastrado no titulo previamente
                AADD(_aTiBaixa , {"AUTDECRESC"	,0                  ,Nil})  //Valore de decrescimo - deve estar cadastrado no titulo previamente
                AADD(_aTiBaixa , {"AUTMULTA"	,0   	        	,Nil})  //Valores de multa
                AADD(_aTiBaixa , {"AUTJUROS"	,0       	       	,Nil})  //Valores de Juros
                AADD(_aTiBaixa , {"AUTVALREC"	,SE1->E1_VALOR	    ,Nil})  //Valor recebido
                MV_PAR08 := 1
                MSExecAuto({|x, y| FINA070(x, y)}, _aTiBaixa, 3)

                If lMsErroAuto
                    ::cMsgError += ShpDetErr()
                    lBaixou := .F. 

                    XCONOUT  STR0123  + cValToChar(aOrder:ORDER_NUMBER)  +  '[###'+ STR0145 +']' + ::cMsgError // 'ORDER NUMBER: '//"ERROR IN TITLE CANCELLATION. CHECK LOG"
                    //aqui eu gravo o Log de Erro
                    //TODO verificar melhor como transformar o aOrder em um json
                    //ShpSaveErr(cValToChar(aOrder:ID), "", ::cIntegration, ::cMsgError, ::path, ::apiVer, aOrder, ::verb) 
                Else
                    // XCONOUT 'Integrando Order Numero: '
                    XCONOUT STR0123   + cValToChar(aOrder:ORDER_NUMBER)  +  '[' + STR0146 +']' // 'ORDER NUMBER: ' //TITLE CANCELLATION HAS BEEN SUCCESSFULLY COMPLETED
                    lBaixou := .T.

                    if SE5->E5_TIPODOC <> 'VL'
                        RecLock("SE5", .F. )
                        SE5->E5_TIPODOC := 'VL'
                        SE5->(MsUnlock())
                    endif
                EndIf
                SE1->(dbSkip())
            EndDo
        Else 
            //aqui eu crio log caso nao encontre os titulos a baixa   
            //::cMsgError += "Titulo " + xFilial + cCliente + cLoja + cSerie + cNumDoc + ", não encontrado."
            ::cMsgError += STR0050 + xFilial + cCliente + cLoja + cSerie + cNumDoc + STR0051
            lBaixou := .F.          
        EndIf 
    Else
        //crio o log caso não ache o banco para dar baixa 
        //aqui eu crio log caso nao encontre os titulos a baixa  
        //::cMsgError += "Banco " + ::cBancoBX + ", não encontrado."
        ::cMsgError += STR0052 + ::cBancoBX + STR0051
        lBaixou := .F.            
    EndIf 

	restArea(aArea)
	
return lBaixou


/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
method GeraInvoice(cNumPed,aOrder) class ShpOrder

    Local lFaturou  := .F.
    local aArea     := getArea()

    aParams := {}
    aReg := {}
    aNotas := {}
    lMSAuto := .T. 


    If SC5->( dbSeek(xFilial("SC5") + cNumPed ) )

        aadd(aParams,SC5->C5_NUM)//Pedido de - ate
        aadd(aParams,SC5->C5_NUM)//Pedido de - ate
        aadd(aParams,SC5->C5_CLIENTE)//Cliente de
        aadd(aParams,SC5->C5_CLIENTE)//Cliente Ate
        aadd(aParams,SC5->C5_LOJACLI) //Loja de 
        aadd(aParams,SC5->C5_LOJACLI) //Loja ate
        aadd(aParams,"    ") //grupo de 
        aadd(aParams,"zzzz") //grupo ate
        aadd(aParams,"    ") //agregador de 
        aadd(aParams,"zzzz") //agregador ate
        aadd(aParams,2)
        aadd(aParams,2)
        aadd(aParams,2)
        aadd(aParams,2)
        aadd(aParams,2)
        aadd(aParams,5)
        aadd(aParams,0)
        aadd(aParams,2)
        aadd(aParams,"      ")
        aadd(aParams,"zzzzzz")
        aadd(aParams,2)
        aadd(aParams,1)
        aadd(aParams,1)
        aadd(aParams,1)
        aadd(aParams,1)
        aadd(aParams,"")


        //aqui eu busco If(lQuery,(cAliasSC9)->SC9RECNO,SC9->(RecNo()))
        If SC9->(dbSeek(XFilial("SC9") + SC5->C5_NUM  ))
            While SC9->(!Eof()) .AND. SC9->C9_PEDIDO == SC5->C5_NUM
               aadd(aReg,SC9->(RecNo()))
                SC9->(dbSkip())
            EndDo
        EndIf

        //aqui eu vou buscar o proximo numero da nota fiscal a ser gerada
        ::cSerie  := PADR( ::cSerie, tamSX3('F2_SERIE')[1] )
        cNumDoc := PADR( NxtSX5Nota( ::cSerie , .T. ) , tamSX3('F2_DOC')[1] )  
        c310Ser := ::cSerie
        c310Num := cNumDoc
        Aadd(aNotas,{c310Ser,c310Num})

        aRetorno := a468nFatura("SC9",aParams,aReg,,,.T.,aNotas,.T.,c310Ser,c310Num)  

        If len(aRetorno) > 0 

            XCONOUT  STR0123  + cValToChar(aOrder:ORDER_NUMBER)  + '[' + STR0147 + cNumDoc + ' ]'   //'ORDER NUMBER: ' //SUCCESSFULLY BILLED. INVOICE:      

            //aqui eu vou baixar os titulos que foram gerados pela invoice
            //aqui eu posiciono no registro SF2
            SF2->( dbSetOrder(1) )
            SF2->( dbSeek( xFilial("SF2") + cNumDoc + ::cSerie + SC5->C5_CLIENTE + SC5->C5_LOJACLI  ) )
            If ::ReceivPost(SF2->F2_FILIAL,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_SERIE,SF2->F2_DOC,aOrder)
                lFaturou := .T.
            else
                lFaturou := .F. 
            EndIf
        Else
            lFaturou := .F. 
        EndIf

    Else
        lFaturou := .F.         
    EndIf 

    restArea(aArea)

Return lFaturou


/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
method validOrder(aOrder) class ShpOrder

    Local lErro := .F. 
    Local iSValid := .T. 
    Local i
    local aArea 	:= getArea()

    For i:= 1 to len(aOrder:LINE_ITEMS)

        nQuant      := aOrder:LINE_ITEMS[i]:QUANTITY	
        nPrcVen     := Val(StrTran(StrTran(aOrder:LINE_ITEMS[i]:PRICE,",",""),",","."))

        If nPrcVen <= 0 
            lErro := .T.
            ::cMsgError += "SKU " + Alltrim(aOrder:LINE_ITEMS[i]:SKU) + STR0053  + CRLF            
        EndIf

        If nQuant <= 0 
            lErro := .T.
            ::cMsgError += "SKU " + Alltrim(aOrder:LINE_ITEMS[i]:SKU) + STR0054  + CRLF            
        EndIf

        If  Empty(aOrder:LINE_ITEMS[i]:SKU) //todo tratar erros de falta de SKU E precos
            ::cMsgError += "SKU " + cValtoChar(aOrder:LINE_ITEMS[1]:ID) +" - " + aOrder:LINE_ITEMS[1]:NAME + STR0055  + CRLF            
            lErro := .T. 
        EndIf  

        If !SB1->(dbSeek(xFilial("SB1") + Alltrim(aOrder:LINE_ITEMS[i]:SKU) ))
            ::cMsgError += "SKU " + Alltrim(aOrder:LINE_ITEMS[i]:SKU) + STR0056  + CRLF            
            lErro := .T. 
        EndIf 

    Next i

    If lErro
        //aqui eu gravo o Log de Erro
        //TODO verificar melhor como transformar o aOrder em um json
        ShpSaveErr("", cValToChar(aOrder:ID), ::cIntegration, ::cMsgError, ::path, ::apiVer, aOrder, ::verb) 
        IsValid := .F. 
    EndIf 

    restArea(aArea)
Return IsValid



/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
//deixar guaradado para caso precise
method geraOrderInvoice(aOrder) class ShpOrder

	local aArea 	:= getArea()
    local lRet		:= .T.
    local aHeader   :=  {}
    local aItem     :=  {}
    local aItens    :=  {}

    //variaveis usadas para dados do produto
    local nQuant      
    local nPrcVen     
    local nPrcTotal   
    local nDescont 

    //variaveis usada para utilizar parametros
    local cNumDoc   := " " 
    local cCliente  := "000001" //TODO - Verificar com eu vou trazer o cliente e loja
    local cLoja     := "0001" //TODO - Verificar com eu vou trazer o cliente e loja
    local i 
    Local cItem     := ""

 	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

    //aqui eu verifico se tem algum problema nos itens antes de continuar com o processo
    XCONOUT  STR0148 + cValToChar(aOrder:ORDER_NUMBER) //"Integrating Order Number:"

    //Busco o Cliente
    SA1->(dbSeek( xFilial("SA1") + cCliente + cLoja ))
    
    //aqui eu vou buscar o proximo numero da nota fiscal a ser gerada
    ::cSerie  := PADR( ::cSerie, tamSX3('F2_SERIE')[1] )
    cNumDoc := PADR( NxtSX5Nota( ::cSerie , .T. ) , tamSX3('F2_DOC')[1] )
 
    //Preencho o Aheadr
 	aadd(aHeader, {'F2_TIPO'	, 'N'		    , nil})
	aadd(aHeader, {'F2_FORMUL'	, 'S'		    , nil})
    aadd(aHeader, {'F2_DOC'		, cNumDoc		, nil})
    aadd(aHeader, {'F2_SERIE'	, ::cSerie		, nil})
    aadd(aHeader, {'F2_CLIENTE'	, SA1->A1_COD	, nil})
    aadd(aHeader, {'F2_LOJA'	, SA1->A1_LOJA	, nil})
    aadd(aHeader, {'F2_TIPOCLI'	, SA1->A1_TIPO	, nil})
    aadd(aHeader, {'F2_ESPECIE'	, padR("NF", tamSX3("F2_ESPECIE")[1]), nil})
    aadd(aHeader, {'F2_EMISSAO'	, dDataBase		, nil})
    aadd(aHeader, {'F2_COND'	, ::cCondPgto	    , nil})
    aadd(aHeader, {'F2_EST'		, ::cEstInvoic	, nil})
    aadd(aHeader, {'F2_PREFIXO'	, ::cSerie		, nil})
    aadd(aHeader, {'F2_MOEDA'	, 1				, nil})
    aadd(aHeader, {'F2_TXMOEDA'	, 1				, nil})
    aadd(aHeader, {'F2_TIPODOC'	, '01'      	, nil})
    aadd(aHeader, {'F2_CODMUN'	, SA1->A1_COD_MUN, nil}) //TODO - Verificar como será tratado 
 
    aSize(aItem, 0)//zerando o array de item

    For i:= 1 to len(aOrder:LINE_ITEMS)
        cItem       := strzero(i, tamSX3("D2_ITEM")[1])
        nQuant      := aOrder:LINE_ITEMS[i]:QUANTITY	
        nPrcVen     := Val(StrTran(StrTran(aOrder:LINE_ITEMS[i]:PRICE,",",""),",","."))
        nPrcTotal   := nPrcVen * nQuant
        nDescont    := Val(StrTran(StrTran(aOrder:LINE_ITEMS[i]:TOTAL_DISCOUNT,",",""),",","."))  

        If nPrcVen > 0 .AND. !Empty(aOrder:LINE_ITEMS[i]:SKU) //todo tratar erros de falta de SKU E precos
            aadd(aItem, {'D2_ITEM'		, cItem                         		, nil})
            aadd(aItem, {'D2_COD'		, aOrder:LINE_ITEMS[i]:SKU	       		, nil})
            aadd(aItem, {'D2_QUANT'		, nQuant 		                    	, nil})
            aadd(aItem, {'D2_PRCVEN'	, nPrcVen		                    	, nil})
            aadd(aItem, {'D2_TOTAL'		, nPrcTotal                             , nil})
            aadd(aItem, {'D2_TES'		, ::cTes									, nil})  
            aadd(aItem, {'D2_DESCON'	, nDescont                          	, nil})
            aadd(aItem, {'D2_LOCAL'	    , ::cArmazen                          	, nil})
            aadd(aItens, AClone(aItem))

            //aqui eu gero as taxas do item na tabela A1L
            ::getLineTax(cValToChar(aOrder:ORDER_NUMBER),aOrder:LINE_ITEMS[i]:TAX_LINES,aOrder:LINE_ITEMS[i],cNumDoc,::cSerie,cCliente,cLoja,,cItem)
        Else
            lErro := .T. 
        EndIf              

    Next i
	
	MSExecAuto( { |x,y,z| Mata467n(x,y,z) }, aHeader, aItens, 3 ) 


	If lMsErroAuto

		::cMsgError := ShpDetErr()
        XCONOUT STR0148 + cValToChar(aOrder:ORDER_NUMBER) + ' (' +STR0149 + ')' + ::cMsgError //Integrating Order Number: //"Integration Error. Check Log"

        //caso tenha dado erro eu preciso deletar as taxas na tabela A1L
        ::excTaxItens(cValToChar(aOrder:ORDER_NUMBER))

        //aqui eu gravo o Log de Erro
        //TODO verificar melhor como transformar o aOrder em um json
        ShpSaveErr("",cValToChar(aOrder:ID), ::cIntegration, ::cMsgError, ::path, ::apiVer, aOrder, ::verb) 


	Else 

        //aqui eu vou baixar os titulos que foram gerados pela invoice
        //aqui eu posiciono no registro SF2
        SF2->( dbSetOrder(1) )
        SF2->( dbSeek( xFilial("SF2") + cNumDoc + ::cSerie + SA1->A1_COD + SA1->A1_LOJA  ) )
        ::ReceivPost(SF2->F2_FILIAL,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_SERIE,SF2->F2_DOC)

        ShpSaveId( "SF2",cValToChar(aOrder:ORDER_NUMBER),"","","",aOrder:UPDATED_AT)
        XCONOUT STR0148 + cValToChar(aOrder:ORDER_NUMBER) + STR0150 + '(' + cNumDoc + ')' //"Integrating Order Number:" // SUCCESS in integration. Invoice number:
    EndIf 

 	restArea(aArea)


Return lRet

/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
method getRefunds (aOrder) class ShpOrder
	local aArea 	:= getArea()
    local lRet		:= .T.
    local aRefunds
    local i
    local j
    local _i
    local cIdRefunds
    local aProdRef := {}
    local aItemsRef
    local nVlFreteRef := 0 
    local nVlTaxFret  := 0 
    local nRecSC5
    local nB
    local dLatUpdate
    local lRefFrete := .F. 

    local aCab := {}
    local aLinha := {}
    local aItens := {}

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.


    aRefunds := aOrder:Refunds

    If Len(aRefunds) > 0 //quer dizer que houve refunds

        for i := 1 to len(aRefunds)
            cIdRefunds := cValToChar(aRefunds[i]:id) //chave unida do refunds
            dLatUpdate := aRefunds[i]:PROCESSED_AT
            aProdRef   := {}

            //checa se já foi feito o refunds de nota fiscal de entrada
            if !ShpExistId("SF1",cIdRefunds,,,.T.)

                //aqui eu pego os dados do frete e impostos do frete
                if len(aRefunds[i]:ORDER_ADJUSTMENTS) > 0 .and. aRefunds[i]:ORDER_ADJUSTMENTS[1]:KIND == "shipping_refund" //quer dizer que teve refund de frete
                    nVlFreteRef := - Val(StrTran(StrTran(aRefunds[i]:ORDER_ADJUSTMENTS[1]:AMOUNT,",",""),",","."))
                    nVlTaxFret  := - Val(StrTran(StrTran(aRefunds[i]:ORDER_ADJUSTMENTS[1]:TAX_AMOUNT,",",""),",","."))
                endif

                //pego os dados dos produtos quantidae preco e impostos
                aItemsRef := aRefunds[i]:REFUND_LINE_ITEMS

                //verificar com será tratado casos que somente e refund de frete
                if Empty(aItemsRef) 

                    If  nVlFreteRef > 0
                        aadd(aProdRef, { ::cPrdFre, 1, nVlFreteRef, nVlTaxFret,"","","",::cTesFret ,0,0} )      
                        lRefFrete := .T. 
                    endif 
                    /*/
                    If  nVlFreteRef > 0 .AND. !ShpExistId("SE1",cIdRefunds,,,.T.) //caso seja somente frete verifica se já foi feiot o refunds do titulo a receber
                        //quando nao tem itens é é somente refunds de fretes
                        ::addNCCFrete(aOrder:ORDER_NUMBER,nVlFreteRef,nVlTaxFret,cIdRefunds,dLatUpdate,aOrder)
                    else 
                        XCONOUT 'Refunds Freight: ' + cIdRefunds + ' já foi integrado anteriormente!!' 
                    endif
                    /*/

                endif 

                if 1 == 1  

                    if !lRefFrete                    
                        for j := 1 to len(aItemsRef)
                            aadd(aProdRef, { aItemsRef[j]:LINE_ITEM:SKU, aItemsRef[j]:QUANTITY, aItemsRef[j]:SUBTOTAL, aItemsRef[j]:TOTAL_TAX,"","","","",0,0,Val(aItemsRef[j]:LINE_ITEM:PRICE)} )
                        next j

                        aProdRef := getDadosOrder(aOrder:ORDER_NUMBER,aProdRef,nVlFreteRef,nVlTaxFret) //esta funcao é para pegar dados da nota fiscal original
                    endif 

                    //busco o pedido de venda pra verificar a nota fiscal
                    nRecSC5 := Val(ShpGetId("SC5", cValtoChar(aOrder:ORDER_NUMBER),,, .T. ))
                    SC5->(DbGoTo(nRecSC5))
                    SF2->(DBSetOrder(1))
                    If SF2->(dbSeek(  xFilial("SF2") + SC5->C5_NOTA + SC5->C5_SERIE + SC5->C5_CLIENTE + SC5->C5_LOJACLI ))
                        
                        cNumDoc 	:= NxtSX5Nota( SF2->F2_SERIE , .T. )//verificando o proximo numero da nota de credito.
                        aCab := {}
                        aItens := {}

                        aadd( aCab, { "F1_FORNECE" 	, SF2->F2_CLIENTE 	, Nil } )
                        aadd( aCab, { "F1_LOJA" 	, SF2->F2_LOJA		, Nil } )
                        aadd( aCab, { "F1_SERIE" 	, SF2->F2_SERIE 	, Nil } )
                        aadd( aCab, { "F1_DOC" 		, cNumDoc 		    , Nil } )
                        aadd( aCab, { "F1_COND" 	, ::cCondPgto 		, Nil } )
                        aadd( aCab, { "F1_EMISSAO" 	, dDataBase 		, Nil } )
                        aadd( aCab, { "F1_EST"   	, SF2->F2_EST   	, Nil } )
                        aadd( aCab, { "F1_TIPO" 	, "D" 			    , Nil } )
                        aadd( aCab, { "F1_ESPECIE" 	, "NCC" 			, Nil } )
                        aadd( aCab, { "F1_PREFIXO" 	, SF2->F2_PREFIXO 	, Nil } )
                        aadd( aCab, { "F1_MOEDA" 	, SF2->F2_MOEDA 	, Nil } )
                        aadd( aCab, { "F1_TXMOEDA" 	, SF2->F2_TXMOEDA	, Nil } )
                        aadd( aCab, { "F1_FORMUL" 	, "S" 			    , Nil } )
                        aadd( aCab, { "F1_TIPODOC" 	, "04" 			    , Nil } )
                        aadd( aCab, { "F1_CODMUN" 	, SF2->F2_CODMUN 	, Nil } )
                        aadd( aCab, { "F1_TPACTIV" 	, SF2->F2_TPACTIV 	, Nil } )


                        if lRefFrete
                            cMsgNota := STR0169 //"Order Shipping:"
                        else
                            cMsgNota := STR0170 //"Order :"// + cValtoChar(aOrder:ORDER_NUMBER) + iif( !empty(aRefunds[i]:NOTE) , ", Reason: " + Substring(aRefunds[i]:NOTE,1,30) ,"")
                        endif 


                        cMsgNota +=  cValtoChar(aOrder:ORDER_NUMBER) + iif( !empty(aRefunds[i]:NOTE) , ","+ STR0171	 + Substring(aRefunds[i]:NOTE,1,30) ,"") //"Reason: "

                        aadd( aCab, { "F1_MENNOTA" 	, cMsgNota	, Nil } )

                        nB:= 1

                        For _i:=1 to len(aProdRef)

                            //TODO VERIFICAR SE TES DE DEVOLUCAO EXISTE SENAO DARA ERRO

                            if !lRefFrete                               
                                cTes := posicione("SF4",1,xFilial("SF4")+padR(aProdRef[_i][8],tamSX3("F4_CODIGO")[1]),"F4_TESDV")		
                            else 
                                cTes :=	Alltrim(::cTesFret)   
                                aProdRef[1][5] := SF2->F2_DOC
                                aProdRef[1][6] := SF2->F2_SERIE                               
                            endif 

                            aadd( aLinha, { "D1_ITEM"	, strZero(nB,tamSX3("D1_ITEM")[1])          	,Nil } )
                            aadd( aLinha, { "D1_COD" 	, padR(aProdRef[_i][1],tamSX3("D1_COD")[1])		,Nil } )
                            aadd( aLinha, { "D1_QUANT" 	, aProdRef[_i][2]				                ,Nil } ) 
                            aadd( aLinha, { "D1_VUNIT" 	, aProdRef[_i][11]					            ,Nil } ) 
                            aadd( aLinha, { "D1_TOTAL" 	, aProdRef[_i][3]	 				            ,Nil } )
                            aadd( aLinha, { "D1_TES" 	, cTES 							                ,Nil } )

                            if !lRefFrete 
                                aadd( aLinha, { "D1_NFORI" 	, padR(aProdRef[_i][5],tamSX3("D1_NFORI")[1]) 	,Nil } )
                                aadd( aLinha, { "D1_SERIORI", padR(aProdRef[_i][6],tamSX3("D1_SERIORI")[1])	,Nil } )
                                aadd( aLinha, { "D1_ITEMORI", padR(aProdRef[_i][7],tamSX3("D1_ITEMORI")[1])	,Nil } )
                            endif 
                            aadd( aLinha, { "D1_VALFRE" , aProdRef[_i][9]                               	,Nil } )
                            aadd( aLinha, { "D1_BASIMP1", (aProdRef[_i][3] + aProdRef[_i][9] ) 	            ,Nil } )
                            aadd( aLinha, { "D1_VALIMP1", (aProdRef[_i][4] + aProdRef[_i][10] )	            ,Nil } )

                            aadd( aItens, AClone(aLinha))
                            aLinha := {}
                            nB++
                        next _i 

                        //executando a rotina automatica de inclusao de doc de credito - nota de entrada de devolucao.	
                        MSExecAuto( { |x,y| Mata465n(x,y) }, aCab, aItens ) 

                        If lMsErroAuto
                            ::cMsgError := ShpDetErr()
                            XCONOUT STR0148  + cValToChar(aOrder:ORDER_NUMBER) + ' ('+STR0149+')' + ::cMsgError //"Integrating Order Number:" // "Integration Error. Check Log"

                            //aqui eu gravo o Log de Erro
                            ShpSaveErr("",cValToChar(aOrder:ID), ::cIntegration, ::cMsgError, ::path, ::apiVer, aOrder, ::verb) 
                        Else 
                            //aqui eu posiciono no registro SF1
                            SF1->( dbSetOrder(1) )
                            SF1->( dbSeek( xFilial("SF1") + cNumDoc + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA  ) )
                            cMsgPost := STR0172  + cValToChar(aOrder:ORDER_NUMBER) //"Refund Shopify Order: "
                            //aqui eu vou baixar os titulos que foram gerados pela invoice
                            ::ReceivPost(SF1->F1_FILIAL,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_SERIE,SF1->F1_DOC,aOrder,cMsgPost)

                            If Empty(SF1->F1_MENNOTA)
                                RecLock("SF1", .F.)
                                SF1->F1_MENNOTA := cMsgNota
                                SF1->(MsUnLock())
                            endif 

                            ShpSaveId( "SF1",SF1->(RECNO()),cIdRefunds,"","",aRefunds[i]:PROCESSED_AT)                        
                            XCONOUT STR0173	+ cIdRefunds + STR0150 + '(' + cNumDoc + ')' //"Integrando Refunds: "//"SUCCESS in integration. Invoice number: "
                        EndIf 

                    else 
                        //todo
                    endif 


                endif 

		    else  
                //todo
                lRet := .F. //quer dizer que já foi feito o refundas
                XCONOUT STR0174	 + cIdRefunds + STR0175 //"Refunds: "//" was previously integrated" 
            endif 

        next i

    else
        lRet := .F.         
    endif

	restArea(aArea)

Return lRet

/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method
/*/
Static Function getDadosOrder(cOrder,aItens,nVlFrete,nVlTaxFret,cIdRefunds)
    local nRecSC5
    local i
    local nRateioFre  := 0
    local nRateioTax  := 0     

    Default   nVlFrete := 0 
    Default   nVlTaxFret := 0 

    nRecSC5 := Val(ShpGetId("SC5", cValtoChar(cOrder),,, .T. ))

    //Busco o Cliente
    SC5->(DbGoTo(nRecSC5))

    For i := 1 to Len(aItens)

        SD2->(DBSetOrder(3))
        If SD2->(dbSeek(  xFilial("SD2") + SC5->C5_NOTA + SC5->C5_SERIE + SC5->C5_CLIENTE + SC5->C5_LOJACLI + padR( aItens[i][1],tamSX3("D2_COD")[1]) ))
            aItens[i][5] := SD2->D2_DOC
            aItens[i][6] := SD2->D2_SERIE
            aItens[i][7] := SD2->D2_ITEM
            aItens[i][8] := SD2->D2_TES            
        EndIf

    Next i

    //aqui eu rateio o frete pelos itens que vao ser devolvidos
    nVlTotItens := 0

    If nVlFrete > 0

        //aqui eu somo o total de itens do Refunds para ratear o frete e impostos do frete
        For i := 1 to Len(aItens)
            nVlTotItens += aItens[i][3] //total por item           
        Next i

        For i := 1 to Len(aItens)
            nFretRat := (aItens[i][3] / nVlTotItens) * nVlFrete
            nTaxRat  := (aItens[i][3] / nVlTotItens) * nVlTaxFret
            aItens[i][9]  := Round(nFretRat,2) //valor do frete rateado
            aItens[i][10] := Round(nTaxRat ,2) //valor do imposto rateado

            nRateioFre    += aItens[i][9]
            nRateioTax    += aItens[i][10]        

            if i == Len(aItens) //quer dizer que é o ultimo item e vou arredondar os valores aqui
                If nRateioFre <> nVlFrete
                    aItens[i][9]  :=  aItens[i][9] + (nVlFrete - nRateioFre )
                EndIf 

                If nRateioTax <> nVlTaxFret
                    aItens[i][10]  :=  aItens[i][10] + (nVlTaxFret - nRateioTax)
                EndIf 
            endif 

        Next i

    EndIf 

Return aItens


/*/{Protheus.doc} new
This method sets the constructor
@author Izo Cristiano Montebugnoli
@since 26/02/2020
@type method somente eu incluo uma ncc caso seja devolucao de frete
/*/
method addNCCFrete(cOrder,nVlFrete,nVlTaxFret,cIdRefunds,dLatUpdate,aOrder) class ShpOrder


    local aFin040 := {}

    lMsErroAuto := .F.
    lMsHelpAuto := .T.
 

    //PREENCHO AS INFORMACOES PARA O EXECAUTO
    nRecSC5 := Val(ShpGetId("SC5", cValtoChar(cOrder),,, .T. ))
    //Busco o Cliente
    SC5->(DbGoTo(nRecSC5))
    SF2->(DBSetOrder(1))

    If SF2->(dbSeek(  xFilial("SF2") + SC5->C5_NOTA + SC5->C5_SERIE + SC5->C5_CLIENTE + SC5->C5_LOJACLI ))

        cMsgSE1 := STR0176 + cValtoChar(cOrder) //"Refunds Freigth Shopify order: "

        AADD( aFin040, {"E1_PREFIXO"    ,"SHP"                                 ,Nil})
        AADD( aFin040, {"E1_NUM"        ,SF2->F2_DOC                           ,Nil})
        AADD( aFin040, {"E1_PARCELA"    ," "                                   ,Nil})
        AADD( aFin040, {"E1_TIPO"       ,"NCC"                                 ,Nil})
        AADD( aFin040, {"E1_NATUREZ"    ,"10101001"                            ,Nil}) //ajustar este parametro
        AADD( aFin040, {"E1_CLIENTE"    ,SC5->C5_CLIENTE                       ,Nil})
        AADD( aFin040, {"E1_LOJA"       ,SC5->C5_LOJACLI                       ,Nil})
        AADD( aFin040, {"E1_EMISSAO"    ,dDataBase                             ,Nil})
        AADD( aFin040, {"E1_VENCTO"     ,dDataBase                             ,Nil})
        AADD( aFin040, {"E1_VENCREA"    ,DataValida(dDataBase)                 ,Nil})
        AADD( aFin040, {"E1_FLUXO"      ,"S"                                   ,Nil})
        AADD( aFin040, {"E1_MOEDA"      ,1                                     ,Nil})
        AADD( aFin040, {"E1_VALOR"      ,nVlFrete+nVlTaxFret                   ,Nil})
        AADD( aFin040, {"E1_HIST"       ,cMsgSE1                               ,Nil})
        AADD( aFin040, {"E1_ORIGEM"     ,"SHPORDER"                            ,Nil})
        AADD( aFin040, {"E1_PEDIDO"     ,SC5->C5_NUM                           ,Nil})
                
        MSExecAuto({|x,y| Fina040(x,y)}, aFin040, 3)
                
        If lMsErroAuto
            MostraErro()
        else

            cMsgPost :=STR0176 + cValtoChar(cOrder) //"Refund Freight Shopify Order: "
            ::ReceivPost(SE1->E1_FILIAL,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_PREFIXO,SE1->E1_NUM,aOrder,cMsgPost)            
            ShpSaveId( "SE1",SE1->(RECNO()),cIdRefunds,"","",dLatUpdate)                        
            XCONOUT STR0177  + cIdRefunds + STR0150 +'(' + SF2->F2_DOC + ')' //"integrating frete refunds: "// "SUCCESS in integration. Invoice number: "

        endif 

    else
        //deu algum problea precisa tratar
    endif 

Return 




