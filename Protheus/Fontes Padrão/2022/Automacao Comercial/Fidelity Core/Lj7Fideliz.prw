#INCLUDE "TOTVS.CH"
#INCLUDE "Lj7FIDELIZ.CH"

Static nDesconto    := 0
Static lTelaVlDes   := .T.  //Controla a apresenta��o da tela de valida��o de desconto, para n�o ser apresentada mais de 1 vez
Static cPhone       := ""   //Armazena o numero do telefone do cliente

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7FidIni()
Inicia o processo de fideliza��o (Fidelity Core)

@type    function
@param   cCodVenda  , Caractere, C�digo da venda que ser� utilizado para iniciar o processo de fideliza��o
@param   cCodCli    , Caractere, C�digo do cliente que ser� utilizado para iniciar o processo de fideliza��o
@param   cLojCli    , Caractere, C�digo da loja do cliente que ser� utilizado para iniciar o processo de fideliza��o
@param   nTotVenda  , Numerico , Valor total da venda que ser� enviado para gerar mais bonus
@return  Numerico   , Valor do desconto aplicado pela fideliza��o
@author  Rafael Tenorio da Costa
@since   09/06/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function Lj7FidIni(cCodVenda, cCodCli, cLojCli, nTotVenda)

    Local oRaasInteg := LjxRaasGet()
    Local oFideCore  := Nil    
    Local oTelefone  := Nil
    Local oCliFidCor := Nil

    If oRaasInteg <> Nil .And. oRaasInteg:ServiceIsActive("TFC")

        oFideCore := oRaasInteg:GetFidelityCore()    

        SA1->( DbSetOrder(1) )  //A1_FILIAL + A1_COD + A1_LOJA
        If SA1->( DbSeek(xFilial("SA1") + cCodCli + cLojCli) )
            oTelefone  := LjPhone():New(SA1->A1_DDD, SA1->A1_TEL)
            oCliFidCor := LjCustomerFidelityCore():New(SA1->A1_NOME, SA1->A1_CGC, SA1->A1_EMAIL, oTelefone, SA1->A1_DTNASC)
        EndIf

        If oFideCore:Initiation(cCodVenda, nTotVenda, oCliFidCor)

            nDesconto := oFideCore:GetBonus()
            LJ7VldDesc( /*oPanVA3*/, /*nPercDesc*/, Lj7T_DescV(2) + nDesconto/*nValorDesc*/, .T./*lValida*/)
        Else

            nDesconto   := 0
        EndIf
    EndIf

Return nDesconto

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7FidDesc()
Retorna o valor de desconto da Fideliza��o

@type    function
@return  Numerico, Valor do desconto aplicado pela fideliza��o
@author  Rafael Tenorio da Costa
@since   09/06/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function Lj7FidDesc()
Return nDesconto

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7FidFin()
Finaliza processo de Fideliza��o

@type    function
@param   cCodEst    , Caractere, C�digo da esta��o
@param   cCodVenda  , Caractere, C�digo da venda
@param   nQtdItens  , Caractere, Quantidade de itens vendidos
@param   nTotVenda  , Numerico , Valor total da venda que ser� finalizada
@param   cNomeCli   , Caractere, Nome do cliente
@param   cNomeVend  , Caractere, Nome do vendedor
@param   cChaveNfe  , Caractere, Chave da nota fiscal eletr�nica
@author  Rafael Tenorio da Costa
@since   09/06/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function Lj7FidFin( cCodEst  , cCodVenda , nQtdItens, nTotVenda, cNomeCli,;
                    cNomeVend, cCodFiscal)

    Local oRaasInteg := LjxRaasGet()
    Local oFideCore  := Nil

    If oRaasInteg <> Nil .And. oRaasInteg:ServiceIsActive("TFC")

        oFideCore := oRaasInteg:GetFidelityCore()
    
        If Lj7FidAtv()
            oFideCore:Finalization(cEstacao, cNomeVend, cCodFiscal, nQtdItens, nTotVenda)
        EndIf

        If oRaasInteg:GetComponent("SendAllSales", "TFC")
            oFideCore:SendSale( /*cBusinessUnitId*/, cNomeCli , cNomeVend , cCodVenda, nTotVenda,;
                                cCodEst            , nQtdItens, cCodFiscal)
        EndIf
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7FidLimp()
Limpa processo de Fideliza��o para ficar preparado para proxima venda

@type    function
@param  lAtuDesc, L�gico, Define se deve atualizar o desconto na tela
        nValDescto  , numerico  , Informa valor do desconto, usado quando chamado fora da tela de atendimento
@author  Rafael Tenorio da Costa
@since   09/06/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function Lj7FidLimp(lAtuDesc,nValDescto)

    Local oRaasInteg := Nil
    Local oFideCore  := Nil
    Local nDecDescNF := TamSX3("L1_DESCNF")[2]

    Default nValDescto := 0

    If Lj7FidAtv() .OR. nValDescto > 0
        If nValDescto > 0
            nDesconto := nValDescto
        Else
            oRaasInteg := LjxRaasGet()
            oFideCore  := oRaasInteg:GetFidelityCore()
            oFideCore:Clean()
        EndIf

        If lAtuDesc .And. Lj7T_DescV( 2 ) >= nDesconto
            LJ7VldDesc( /*oPanVA3*/, /*nPercDesc*/, Lj7T_DescV( 2 ) - nDesconto/*nValorDesc*/, .T./*lValida*/)

            If SL1->(RLock())
                RecLock( "SL1", .F. )
                SL1->L1_FIDCORE := .F.
                SL1->L1_DESCFID := 0
                SL1->L1_DESCONT := SL1->L1_DESCONT - nDesconto // Valor
                SL1->L1_DESCNF  := SL1->L1_DESCNF - Round(nDesconto * 100 / (Lj7T_Total(2) + Lj7T_DescV(2)),nDecDescNF) // Porcentagem
                SL1->( MsUnlock() )
            EndIf           
        EndIf
    EndIf

    nDesconto   := 0
    lTelaVlDes  := .T.

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7FidCanc()
Cancela o bonus de uma venda cancelada

@type    function
@param   cCodVenda, Carectere, C�digo da venda
@author  Rafael Tenorio da Costa
@since   09/06/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function Lj7FidCanc(cCodVenda, cCodEst, cCel)

    Local oRaasInteg := LjxRaasGet(cCodEst)
    Local oFideCore  := Nil
    Local aRetorno   := {}

    Default cCel := "" 

    If oRaasInteg <> Nil .And. oRaasInteg:ServiceIsActive("TFC")

        LjGrvLog(cCodVenda, ProcName(1) + " - Executando o cancelamento da fideliza��o.", cCodEst, /*lCallStack*/)

        oFideCore := oRaasInteg:GetFidelityCore()
        FwMsgRun( , { || aRetorno  := oFideCore:CancelBonus(/*cBusinessUnitId*/, cCodVenda, cCodEst, cCel) }, STR0004, STR0005)     //"TOTVS Bonifica��es"    //"Efetuando o cancelamento da bonifica��o"

        If !aRetorno[1]
            LjxjMsgErr(STR0002, STR0003, STR0004)   //"N�o foi poss�vel cancelar o b�nus da venda."     //"Entre em contato com o parceiro de b�nus, para efetuar o cancelamento manual."   //"TOTVS Bonifica��es"
        EndIf
    EndIf

Return Nil

//FUN��O N�O UTILIZADA, PODE SER RETIRADA SE ISSO N�O MUDAR AT� SUBIR OS FONTES
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7FidVlDe()
Valida se � permitido aplicar outro desconto

@type    function
@return  L�gico, Define se � permitido efetuar o desconto
@author  Rafael Tenorio da Costa
@since   09/06/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function Lj7FidVlDe()

    Local lRetorno := .T.

    If Lj7FidDesc() > 0

        lRetorno := .F.

        If lTelaVlDes
            lTelaVlDes := .F.
            LjxjMsgErr(STR0001, /*cSolucao*/)   //"Desconto financeiro n�o ser� aplicado, porque j� foi aplicado o desconto de Fideliza��o."
        EndIf
    EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7FidAtv()
Verifica se a fideliza��o(TFC) esta ativa ou se esta ativa na venda em execu��o

@type    function
@param   lChoseToUse, L�gico, Define como ser� o retorno. Se ira verificar se a fideliza��o esta ativa ou se esta ativa na venda em execu��o.
@return  L�gico, Define que a fideliza��o esta ativa
@author  Rafael Tenorio da Costa
@since   09/06/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function Lj7FidAtv(lChoseToUse)

    Local lRetorno   := .F.
    Local oRaasInteg := LjxRaasGet()
    Local oFideCore  := Nil

    Default lChoseToUse := .T.

    If oRaasInteg <> Nil .And. oRaasInteg:ServiceIsActive("TFC")

        If lChoseToUse
            oFideCore := oRaasInteg:GetFidelityCore()
            lRetorno  := oFideCore:ChoseToUse()
        Else
            lRetorno  := .T.
        EndIf
    EndIf

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7SetPhone()
Seta a variavel static cPhone

@type    function
@param   cCelular, String, Recebe o numero do telefone do cliente
@return  Nil
@author  Bruno Almeida
@since   28/01/22
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function Lj7SetPhone(cCelular)

Default cCelular := ""

cPhone := cCelular

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7GetPhone()
Retorna o numero do celular do cliente

@type    function
@return  Nil
@author  Bruno Almeida
@since   28/01/22
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function Lj7GetPhone()
Return cPhone

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7GrvPhone()
Atualiza a venda gravando o numero do telefone no campo L1_TEL

@type    function
@return  Nil
@author  Bruno Almeida
@since   28/01/22
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function Lj7GrvPhone()

Local lL1Tel := SL1->(ColumnPos("L1_TEL")) > 0 //Variavel para verificar a existencia do campo L1_TEL

If lL1Tel
    RecLock("SL1",.F.)
    SL1->L1_TEL := Lj7GetPhone()
    SL1->( MsUnLock() )
EndIf

Lj7SetPhone()

Return Nil
