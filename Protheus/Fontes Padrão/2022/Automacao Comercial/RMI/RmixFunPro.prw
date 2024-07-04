#INCLUDE "TOTVS.CH"

Static aFuncoes     := {}
#DEFINE PROCESSO    1
#DEFINE FUNCOES     2
#DEFINE ETAPA       1
#DEFINE FUNCAO      2

Static aParExeGat   := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiFunExEt
Executa todas as fun��es(tabela MIM) de um determinado processo e determinada etapa.

@type    Function
@param   cProcesso, Caractere, C�digo do processo que ter� as fun��es executadas
@param   cEtapa, Caractere, Defini��o da etapa de execu��o da fun��o
@param   xRetPadrao, Indefinido, Retorno padr�o caso n�o seja executada a fun��o
@return  Indefinido, O retorno ira depender da etapa
@author  Rafael Tenorio da Costa
@since   11/04/22
@version 12.1.33
@obs     
/*/
//-------------------------------------------------------------------
Function RmiFunExEt(cProcesso, cEtapa, xRetPadrao)

    Local aArea	        := GetArea()
    Local xAux          := xRetPadrao
    Local xRetorno      := xRetPadrao
    Local bErrorBlock   := Nil
    Local cErrorBlock   := ""
    Local nPro          := 0
    Local nFun          := 0

    //Desconsidera os registros deletados
    SET DELETED ON
    
    //Localiza fun��es do processo
    nPro := aScan(aFuncoes, {|x| AllTrim(x[1]) == AllTrim(cProcesso)} )

    //Carrega as fun��es para o processo
    If nPro == 0

        Aadd(aFuncoes, {cProcesso, } )
        nPro := Len(aFuncoes)

        aFuncoes[nPro][FUNCOES] := GetFuncoes(cProcesso)
    EndIf

    //Salva tratamento de erro anterior e atualiza tratamento de erro
    bErrorBlock := ErrorBlock( {|oErro| RmiErroBlock(oErro, /*@lErrorBlock*/, @cErrorBlock)} )

    //Condi��o que pode dar erro
    Begin Sequence

        For nFun:=1 To Len( aFuncoes[nPro][FUNCOES] )

            If aFuncoes[nPro][FUNCOES][nFun][ETAPA] == cEtapa

                xAux := &( aFuncoes[nPro][FUNCOES][nFun][FUNCAO] )

                IIF( cEtapa == "2", xRetorno += xAux, xRetorno := xAux )
            EndIf

        Next nFun

    //Tratamento para o erro
    Recover

        LjxjMsgErr( I18n("Erro ao executar fun��es do processo - Processo #1, Etapa #2: ", {AllTrim(cProcesso), AllTrim(cEtapa)} ) + CRLF + cErrorBlock )

    End Sequence

    //Restaura tratamento de erro anterior
    ErrorBlock(bErrorBlock)

    //Considera os registros deletados
    SET DELETED OFF

    RestArea(aArea)

Return xRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFuncoes
Retorna todas as fun��es de um determinado processoprocesso

@type    Function
@param   cProcesso, Caractere, C�digo do processo utilizado no filtro
@return  Array, Array com todas as fun��es daquela processo. {MIM_ETAPA, MIM_FUNCAO}
@author  Rafael Tenorio da Costa
@since   11/04/22
@version 12.1.33
@obs     
/*/
//-------------------------------------------------------------------
Static Function GetFuncoes(cProcesso)

    Local aArea     := GetArea()
    Local aRetorno  := {}
    Local cQuery    := ""
    Local cTabela   := GetNextAlias()
    Local cFiltro   := IIF(MIM->(ColumnPos("MIM_ATIVO")) > 0," AND MIM_ATIVO = '1'","")

    If FwAliasInDic("MIM")
    
        cQuery := " SELECT MIM_ETAPA, MIM_FUNCAO"
        cQuery += " FROM " + RetSqlName("MIM")
        cQuery += " WHERE MIM_FILIAL = '" + xFilial("MIM") + "'"
        cQuery +=   " AND MIM_CPROCE = '" + cProcesso + "'"
        cQuery += cFiltro
        cQuery +=   " AND D_E_L_E_T_ = ' '"
        cQuery += " ORDER BY MIM_ETAPA"

        cQuery := ChangeQuery(cQuery)
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)

        While !(cTabela)->( Eof() )

            Aadd(aRetorno, {(cTabela)->MIM_ETAPA, ALLTRIM((cTabela)->MIM_FUNCAO) + "()"})

            (cTabela)->( DbSkip() )
        EndDo

        (cTabela)->( DbCloseArea() )
    EndIf

    RestArea(aArea)

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPubGrad
Gera a tag GRADE para o processo PRODUTO (SB1), essa tag ira conter a varia��o do produto grade que esta sendo enviado.
A grade do produto foi desenvolvida seguindo o mesmo padrao da mensagem padronizada MATI010, inclusive utilizando a fun��o Lj900ARGrd que a
mensagem padronizada tamb�m utiliza.

@return  cJson, Json com a variacao de um determinado produto
@author  Bruno Almeida
@since   22/02/2022 
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiPubGrad()

    Local aArea	    := GetArea()
    Local cCodProd  := SB1->B1_COD
    Local cMascara	:= SuperGetMv("MV_MASCGRD")
    Local nTamRef   := Val( Substr(cMascara, 1, 2) )
    Local oJson     := Nil
    Local cJson     := ""    

    //Tratamento necess�rio porque esta rotina esta sendo chamada no RmiPublica e l� considera registros deletados
    //Desconsidera os registros deletados
    SET DELETED ON

    SB4->( DbSetOrder(1) )  //B4_FILIAL+B4_COD
    If SB4->(DbSeek(xFilial("SB4") + SubStr(cCodProd,1,nTamRef)))

        oJson := JsonObject():New()
        oJson := JsonObject():New()
        oJson["PRODUTOGRADE"] := JsonObject():New()
        oJson["PRODUTOGRADE"]["B4_COD"]    := AllTrim(SB4->B4_COD)
        oJson["PRODUTOGRADE"]["B4_DESC"]   := AllTrim(SB4->B4_DESC)

        oJson["GRADE"] := {}
        Aadd( oJson["GRADE"], JsonObject():New() )
        oJson["GRADE"][1]["BV_DESCTAB"]   := Lj900ARGrd( cMascara, cCodProd, 1, 1, "", .T. )
        oJson["GRADE"][1]["BV_DESCRI"]    := Lj900ARGrd( cMascara, cCodProd, 2, 1, "", .T. )
        oJson["GRADE"][1]["BV_TABELA"]    := Lj900ARGrd( cMascara, cCodProd, 3, 1, "", .T. )

        Aadd( oJson["GRADE"], JsonObject():New() )
        oJson["GRADE"][2]["BV_DESCTAB"]   := Lj900ARGrd( cMascara, cCodProd, 1, 2, "", .T. )
        oJson["GRADE"][2]["BV_DESCRI"]    := Lj900ARGrd( cMascara, cCodProd, 2, 2, "", .T. ) 
        oJson["GRADE"][2]["BV_TABELA"]    := Lj900ARGrd( cMascara, cCodProd, 3, 2, "", .T. )

        cJson := oJson:ToJson()
        cJson := SubStr(cJson, 2, Len(cJson) - 2) + ","

        FwFreeObj(oJson)
    EndIf

    //Considera os registros deletados
    SET DELETED OFF    

    RestArea(aArea)

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiExeGat
Executa todas os processos que de um terminado gatilho

@type    Function
@param   cGatilho - Nome do gatilho relacionado que ser� executado
@param   cEtapa   - Define a etapa que ser� utilizada para localizar a fun��o na tabela MIM 
@param   aParams  - Que ser�o utilizados pela fun��o que ser� macro executada
@author  Rafael Tenorio da Costa
@since   11/04/22
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function RmiExeGat(cGatilho, cEtapa, aParams)

    Local aArea     := GetArea()
    Local cQuery    := ""
    Local cTabela   := GetNextAlias()

    Default aParams := {}

    aParExeGat := aParams
    LjGrvLog("RmiExeGat", "Par�metros recebidos aParExeGat:", aParExeGat)    

    If FwAliasInDic("MIM") .And. MHN->( ColumnPos("MHN_GATILH") )

        cQuery := " SELECT MIM_CPROCE"
        cQuery += " FROM " + RetSqlName("MHN") + " MHN INNER JOIN " + RetSqlName("MHP") + " MHP"
        cQuery +=     " ON MHN_FILIAL = MHP_FILIAL AND MHN_COD = MHP_CPROCE AND MHP_ATIVO = '1' AND MHP.D_E_L_E_T_ = ' '"                   //Filtra Processo que esta ativo para algum Assinante
        cQuery += " INNER JOIN " + RetSqlName("MIM") + " MIM"
        cQuery +=     " ON MHN_FILIAL = MIM_FILIAL AND MHN_COD = MIM_CPROCE AND MIM_ETAPA = '" + cEtapa + "' AND MIM.D_E_L_E_T_ = ' '"      //Filtra Fun��es de uma determinada Etapa
        cQuery += " WHERE MHN_FILIAL = '" + xFilial("MHN") + "' AND MHN_GATILH = '" + PadR(cGatilho, TamSx3("MHN_GATILH")[1]) + "' AND MHN.D_E_L_E_T_ = ' '"
        
        cQuery := ChangeQuery(cQuery)
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)

        While !(cTabela)->( Eof() )

            //Executa todas as fun��es(tabela MIM) de um determinado processo e determinada etapa.
            RmiFunExEt( (cTabela)->MIM_CPROCE, cEtapa, "")

            (cTabela)->( DbSkip() )
        EndDo

        (cTabela)->( DbCloseArea() )
    Else

        LjxjMsgErr( I18n("Gatilho n�o ser� executado, � necess�rio efetuar atualiza��o do dicion�rio de dados com a tabela #1 e campo #2.", {"MIM", "MHN_GATILH"}) )
    EndIf

    FwFreeArray(aParExeGat)
    aParExeGat := {}

    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPubStPe
Fun��o que publica o Status do Pedido, ser� inclu�da na tabela Fun��es do Processo(MIM) 
para o processo Status Pedido.

@type    Function
@author  Rafael Tenorio da Costa
@since   11/04/22
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function RmiPubStPe()

    Local aArea     := GetArea()
    Local cRetorno  := ""
    Local cOrigem   := "PROTHEUS"
    Local cProcesso := "STATUS PEDIDO"
    Local oJson     := Nil

    //aParExeGat - Deve conter Json na 1� posi��o
    If Empty(aParExeGat) .Or. ValType( aParExeGat[1] ) <> "J"

        LjxjMsgErr("N�o foi poss�vel gerar a publica��o de Status do Pedido, par�metros recebidos s�o inv�lidos.")
    Else

        oJson := aParExeGat[1]

        Begin Transaction        
            RecLock("MHQ", .T.)
                MHQ->MHQ_FILIAL := xFilial("MHQ")
                MHQ->MHQ_ORIGEM := cOrigem
                MHQ->MHQ_CPROCE := cProcesso
                MHQ->MHQ_EVENTO := "1"              //1=Atualiza��o;2=Exclus�o
                MHQ->MHQ_CHVUNI := oJson["filial"] +"|"+ oJson["pedidoOrigem"] +"|"+ oJson["status"]
                MHQ->MHQ_MENSAG := oJson:ToJson()
                MHQ->MHQ_DATGER := Date()
                MHQ->MHQ_HORGER := Time()
                MHQ->MHQ_STATUS := "1"              //1=A Processar;2=Processada;3=Erro
                MHQ->MHQ_UUID   := FwUUID("RMIPUBSTPE" + cProcesso)
            MHQ->( MsUnLock() )
        End Transaction

    EndIf

    FwFreeObj(oJson)
    RestArea(aArea)

Return cRetorno

//--------------------------------------------------------
/*/{Protheus.doc} RmiImpPro
Executado via Tabela MIM para criar os impostos por produto.

@author Totvs
@since  20/06/2022
/*/
//--------------------------------------------------------
Function RmiImpPro()
   
    Local oCadAux := Nil

    oCadAux := RmiCadAuxiliaresObj():New()

    oCadAux:ImpPorProd(SB1->B1_COD)

    FwFreeObj(oCadAux)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPubCnPg
Publica a Condi��o de Pagamento sem altear o AE_MSEXP

@type    Function

@author  Rafael Tenorio da Costa
@since   21/07/22
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function RmiPubCnPg()
    
    Local aArea     := GetArea()
    Local aProcesso := {"CONDICAO PAGTO", "SAE", {}, /*MHN_FILTRO*/, /*MHP_CASSIN*/, "2", /*MHS_TIPO*/, "AE_FILIAL + AE_COD", /*MHP_FILPRO*/}

    RmiPubGrv(aProcesso, SAE->( Recno() ), "", .F.)

    RestArea(aArea)

Return Nil