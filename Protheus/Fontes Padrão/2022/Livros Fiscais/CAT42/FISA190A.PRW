#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA190A
  
Definição da Estrutura de Classes para a Apuração do Ressarcimento ou Complemento do ICMS Retido por 
Substituição Tributária ou Antecipado.
Para o Estado de São Paulo, o método de apuração é determinado pela portaria CAT 42/2018.

@author Ulisses P. Oliveira
@since 19/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA190APURACAO

Classe responsável pela apuração de cada movimento da query principal, controlando: 
Atualização de saldos / Enquadramento Legal / Valor de Confronto / Valor a Ressarcir ou Complementar 
(Colunas 11 a 27 da Ficha 3).
  
@author Ulisses P. Oliveira
@since 19/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA190APURACAO FROM LongClassName

Data cIdApur     As Character //---Identificador da Apuração                                  ---//
Data cFilApur    As Character //---Código da Filial apurada                                   ---//
Data cAnoMes     As Character //---Período da Apuração                                        ---//
Data aTotApur    As Array     //---Totais da Apuração                                         ---//
Data oSaldoProd  As Object    //---Objeto que controla o saldo físico e finaneceiro do produto---//
Data oMovimento  As Object    //---Objeto que controla o movimento analisado                  ---//
Data oMovimApur  As Object    //---Objeto que controla os valores apurados para o movimento   ---//

Method New(cIdApur,cAnoMes) CONSTRUCTOR
Method SetaSldIni(cCodProd,nQtdade,nVlSldUnit,nVlSldTotal)
Method SetaMovim(dDataMov,cTipoMov,cNumDoc,cItemDoc,cSerieDoc,cEspecDoc,cChaveDoc,cNumSerECF,cTipoDoc,cCodProd,cCodPart,cTipoPart,nAliqInt,cCFOP,cCST,cFGerNReal,nQtdade,nVlrTotPrd,nVlrFrete,nVlrSeguro,nVlrDesp,nVlrDesc,nVlrBICMS,nVlrICMS,nVlrICMSST,nVlrICMSAn,nVlrBICMND,nVlrICMSND,lEntProt,nVlrICMSEn,aDocOriApu,nVlrPauta,cSerOri,cNFOri,cItemOri)
Method ApuraMovim()

//---Getters e Setters---//
Method GetIdApur()
Method GetAnoMes()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA190APURACAO

@author Ulisses P. Oliveira
@since 19/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New(cIdApur,cAnoMes) Class FISA190APURACAO
	Self:cIdApur    := cIdApur
	Self:cFilApur   := ""
	Self:cAnoMes    := cAnoMes
    Self:aTotApur   := {{'1',0,0,0},{'2',0,0,0},{'3',0,0,0},{'4',0,0,0}} //---{cCodEnquad,nApurVlrR,nApurVlrC,nApurVlrCO}---//
    Self:oSaldoProd := FISA190SALDOPRODUTO():New()
    Self:oMovimento := FISA190MOVIMENTO():New()
    Self:oMovimApur := FISA190MOVIMENTOAPURACAO():New()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetaSldIni()
  
Método que carrega no objeto o saldo inicial do período para o produto analisado. 
Deve ser chamado a cada produto analisado, antes de sua movimentação.

@author Ulisses P. Oliveira
@since 19/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetaSldIni(cCodProd,nQtdade,nVlSldUnit,nVlSldTotal) Class FISA190APURACAO
    Self:oSaldoProd:SetCodProd(cCodProd)    
    Self:oSaldoProd:SetQtdade(nQtdade)
    Self:oSaldoProd:SetVlrUnit(nVlSldUnit)
    Self:oSaldoProd:SetVlrTot(nVlSldTotal)
    Self:oSaldoProd:SetUltDif0(nVlSldUnit)
    Self:oSaldoProd:SetOrdMov(0)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetaMovim()
  
Método que carrega no objeto o movimento a ser analisado. 
Deve ser chamado a cada movimento encontrado para o produto em questão.

@author Ulisses P. Oliveira
@since 19/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetaMovim(dDataMov,cTipoMov,cNumDoc,cItemDoc,cSerieDoc,cEspecDoc,cChaveDoc,cNumSerECF,cTipoDoc,cCodProd,cCodPart,cTipoPart,nAliqInt,cCFOP,cCST,cFGerNReal,nQtdade,nVlrTotPrd,nVlrFrete,nVlrSeguro,nVlrDesp,nVlrDesc,nVlrBICMS,nVlrICMS,nVlrICMSST,nVlrICMSAn,nVlrBICMND,nVlrICMSND,lEntProt,nVlrICMSEn,aDocOriApu,nVlrPauta,cSerOri,cNFOri,cItemOri) Class FISA190APURACAO
    Self:oMovimento:ClearMov()
    Self:oMovimento:SetDataMov(dDataMov)
    Self:oMovimento:SetTipoMov(cTipoMov)
    Self:oMovimento:SetNumDoc(cNumDoc)
    Self:oMovimento:SetItemDoc(cItemDoc)
    Self:oMovimento:SetSerDoc(cSerieDoc)
    Self:oMovimento:SetEspDoc(cEspecDoc)
    Self:oMovimento:SetChvDoc(cChaveDoc)
    Self:oMovimento:SetNSerECF(cNumSerECF)
    Self:oMovimento:SetTipoDoc(cTipoDoc)
    Self:oMovimento:SetCodProd(cCodProd)
    Self:oMovimento:SetCodPart(cCodPart)
    Self:oMovimento:SetTipoPar(cTipoPart)
    Self:oMovimento:SetAliqInt(nAliqInt)
    Self:oMovimento:SetCFOP(cCFOP)
    Self:oMovimento:SetCST(cCST)
    Self:oMovimento:SetFGerNR(cFGerNReal)
    Self:oMovimento:SetQtdade(nQtdade)
    Self:oMovimento:SetTotPrd(nVlrTotPrd)
    Self:oMovimento:SetFrete(nVlrFrete)
    Self:oMovimento:SetSeguro(nVlrSeguro)
    Self:oMovimento:SetDespesa(nVlrDesp)
    Self:oMovimento:SetDescont(nVlrDesc)
    Self:oMovimento:SetBICMS(nVlrBICMS)
    Self:oMovimento:SetVICMS(nVlrICMS)
    Self:oMovimento:SetVICMSST(nVlrICMSST)
    Self:oMovimento:SetVICMSAn(nVlrICMSAn)
    Self:oMovimento:SetVBICMND(nVlrBICMND)
    Self:oMovimento:SetVICMSND(nVlrICMSND)
    Self:oMovimento:SetEntProt(lEntProt)
    Self:oMovimento:SetVICMSEn(nVlrICMSEn)
    Self:oMovimento:SetDocOrig(aDocOriApu)
    Self:oMovimento:SetVlrPauta(nVlrPauta)
    Self:oMovimento:SetSerOri(cSerOri)
    Self:oMovimento:SetNFOri(cNFOri)
    Self:oMovimento:SetItemOri(cItemOri)

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ApuraMovim()
  
Método responsável por controlar, para cada movimento: 
Atualização de saldos / Enquadramento Legal / Valor de Confronto / Valor a Ressarcir ou Complementar 
(Colunas 11 a 27 da Ficha 3).

@author Ulisses P. Oliveira
@since 19/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ApuraMovim() Class FISA190APURACAO
    Local cTipoMov    := Self:oMovimento:GetTipoMov()
    Local cCodProd    := Self:oMovimento:GetCodProd()
    Local nQtdade     := Self:oMovimento:GetQtdade()
    Local cTipoDoc    := Self:oMovimento:GetTipoDoc()
    Local nAliqInt    := Self:oMovimento:GetAliqInt()
    Local nVlrICMS    := Self:oMovimento:GetVICMS()
    Local nVlrICMSST  := Self:oMovimento:GetVICMSST()
    Local nVlrICMSAn  := Self:oMovimento:GetVICMSAn()
    Local nVlrBICMND  := Self:oMovimento:GetVBICMND()
    Local nVlrICMSND  := Self:oMovimento:GetVICMSND()
    Local aDocOriApu  := Self:oMovimento:GetDocOrig()
    Local nVlSldUnit  := 0
    Local nVlrICMSSu  := 0
    Local nVlrICMSCo  := 0
    Local nVlrICMSOp  := 0
    Local cCodEnquad  := ''
    Local aVlrRC      := {}
    Local nPos        := 0

    If (cTipoMov=='E' .And. cTipoDoc != 'D') .Or. (cTipoMov=='S' .And. cTipoDoc == 'D') //---Para Entradas / Devoluções de Entradas: Define Total de ICMS Suportado / Atualiza o saldo do produto---//

        //---Define Total de ICMS Suportado---//
        If cTipoDoc != 'D' .Or. (cTipoDoc == 'D' .And.  aDocOriApu[9] = 0)

            //------------------------------------------------------------------------------------------------------------------------------------------------------//
            /* Manual do Sistema de Apuração do Ressarcimento ou Complemento do ICMS Retido por Substituição Tributária ou Antecipado:
               
               "Coluna 12 - Valor total do imposto suportado pelo contribuinte substituído (Entrada):
                O valor total do imposto suportado pelo contribuinte substituído, abrangendo o incidente na operação própria do substituto e o retido, ou o cobrado na 
                operação interestadual anterior e o antecipado pelo destinatário paulista, nas operações de entrada.
               
                O ICMS suportado pelo contribuinte substituído, abrangendo o incidente na operação própria do substituto e o retido, ou o cobrado na operação interestadual 
                anterior e o pago por antecipação pelo destinatário paulista, é a soma dessas duas parcelas, ou seja, a soma do cobrado na operação própria do substituto com 
                o retido por substituição tributária, ou a soma do cobrado na operação interestadual anterior com o pago por antecipação pelo destinatário paulista. 
                Visto ainda de outra forma, o ICMS suportado é o valor resultante da multiplicação da base de cálculo da sujeição passiva por substituição pela alíquota interna 
                aplicável à saída ao consumidor final."

                Ou seja, em aquisições diretas de substituto, o ICMS Suportado é composto pelo ICMS Próprio + ICMS Retido ou Antecipado. Já em aquisições de substituído (CST 60), 
                no Protheus, possuímos apenas a informação do que foi recolhido anteriormente (na primeira operação) por Substituição Tributária (informado nos campos BASNDES e 
                ICMNDES). Não temos, nesse caso, um ICMS Próprio para a composição do ICMS Suportado. 

                Contudo, o Manual sugere que o ICMS Suportado pode também ser composto através da multiplicação da base de cálculo da sujeição passiva por substituição (BASNDES) 
                pela alíquota interna aplicável à saída ao consumidor final (nAliqInt).
            */
            //------------------------------------------------------------------------------------------------------------------------------------------------------//
            If (nVlrICMS + nVlrICMSST + nVlrICMSAn) = 0
                nVlrICMSND := Iif(nVlrBICMND > 0 .And. nAliqInt > 0, Round(((nVlrBICMND*nAliqInt)/100),2), nVlrICMSND)
            EndIf

            nVlrICMSSu := Iif((nVlrICMS + nVlrICMSST + nVlrICMSAn) > 0 .And. nVlrICMSND == 0, nVlrICMS + Iif(nVlrICMSAn > 0, nVlrICMSAn, nVlrICMSST), nVlrICMSND)
        Else
            nVlrICMSSu := (aDocOriApu[9]/aDocOriApu[1])*nQtdade
        EndIf

        //---Atualiza o saldo do produto---//
        Self:oSaldoProd:AtuSaldo(cTipoMov,cCodProd,nQtdade,nVlrICMSSu)

    ElseIf cTipoMov=='S' .And. cTipoDoc != 'D' //---Para Saídas : Define Total de ICMS Suportado / Atualiza o saldo do produto / Enquadra o Movimento / Define Valor de Confronto / Define Valor a Ressarcir ou Complementar / Define Valor do Crédito da Operação Própria---//

        //---Define Total de ICMS Suportado---//
        nVlSldUnit := Self:oSaldoProd:GetVlrUnit()
        If Self:oSaldoProd:GetQtdade() == nQtdade // DSERFIS1-15944 - Evitar erro de arredondamento, o ideal seria aumentar as casas decimai do campos F2V_VUNSLD, F2V_VTOSLD, F2V_VUNFIM e F2V_VTOFIM
            nVlrICMSSu := Self:oSaldoProd:GetVlrTot()
        Else
            nVlrICMSSu := nVlSldUnit*nQtdade
        EndIf    

        //---Atualiza o saldo do produto---//
        Self:oSaldoProd:AtuSaldo(cTipoMov,cCodProd,nQtdade,nVlrICMSSu)

        //---Enquadra o Movimento / Define Valor de Confronto / Define Valor a Ressarcir ou Complementar / Define Valor do Crédito da Operação Própria---//
        cCodEnquad := Self:oMovimento:EnquadMov()
        If cCodEnquad != '0'
            nVlrICMSCo := Self:oMovimento:DefVlrConf(cCodEnquad)
            aVlrRC     := Self:oMovimento:DefVlrRC(cCodEnquad,nVlrICMSSu,nVlrICMSCo)
            If cCodEnquad == '4'
                nVlrICMSOp := nVlrICMSCo
            EndIf
        EndIf

    Else //---Para Devoluções de Saídas : Define Total de ICMS Suportado (De acordo com mov. apurado original) / Atualiza o saldo do produto / Enquadra o Movimento (De acordo com mov. apurado original) / Define Valor de Confronto (De acordo com mov. apurado original) / Define Valor a Ressarcir ou Complementar (De acordo com mov. apurado original) / Define Valor do Crédito da Operação Própria (De acordo com mov. apurado original)---//

        If !Empty(aDocOriApu[3]) //---Encontrou mov. apurado original (tabela F2U)---//

            //--- Define Total de ICMS Suportado (De acordo com mov. apurado original)---//
            nVlSldUnit := aDocOriApu[2]
            nVlrICMSSu := nVlSldUnit*nQtdade

            //---Atualiza o saldo do produto---//
            Self:oSaldoProd:AtuSaldo(cTipoMov,cCodProd,nQtdade,nVlrICMSSu)

            //---Enquadra o Movimento (De acordo com mov. apurado original) / Define Valor de Confronto (De acordo com mov. apurado original) / Define Valor a Ressarcir ou Complementar (De acordo com mov. apurado original) / Define Valor do Crédito da Operação Própria (De acordo com mov. apurado original)---//
            cCodEnquad := AllTrim(aDocOriApu[3])
            If cCodEnquad != '0'
                nVlrICMSCo := ((Iif(!Empty(aDocOriApu[4]),aDocOriApu[4],aDocOriApu[5]))/aDocOriApu[1])*nQtdade
                aVlrRC     := Self:oMovimento:DefVlrRC(cCodEnquad,nVlrICMSSu,nVlrICMSCo)
                If cCodEnquad == '4'
                    nVlrICMSOp := (aDocOriApu[8]/aDocOriApu[1])*nQtdade
                EndIf
            EndIf

        Else //---Não encontrou mov. apurado original (tabela F2U)---//

            //---Nesse caso, é impossível determinar o Total de ICMS Suportado (obrigatório nas devoluções) e outros valores informados na apuração do movimento original---//
            //---Partindo do princípio de que a devolução tem como objetivo anular os efeitos do movimento original, devemos então estornar um valor a ressarcir ou complementar. Partimos, portanto, desse campo---//
            //---Solução: Estornar valor a ressarcir encontrado na tabela CDA (gerado via portaria CAT158). Dessa forma, Total de ICMS Suportado deverá ser a soma do Valor de Confronto e do Valor a Ressarcir, logo: nVlrICMSSu = nVlrICMSCo + aDocOriApu[6]---//
            //---Atenção: A solução acima será usada apenas para movimentos de devolução com Enquadramento Legal <> 0. Caso seja 0 (saídas sem direito à ressarcimento), o Total de ICMS Suportado será composto utilizando o Unitário do ICMS Suportado atual, para atualizar saldos em estoque sem alteração de seu custo. Entende-se que, nesse caso, não há como usar o Valor de Confronto para compor Total de ICMS Suportado, uma vez que o Valor de Confronto não é preenchido para Enquadramento 0---//

            //---Enquadra o Movimento---//
            cCodEnquad := Self:oMovimento:EnquadMov()

            //---Define Total de ICMS Suportado---//
            If cCodEnquad == '0'
                nVlSldUnit := Self:oSaldoProd:GetVlrUnit()
                nVlSldUnit := Iif(nVlSldUnit>0,nVlSldUnit,Self:oSaldoProd:GetUltDif0())
                nVlrICMSSu := nVlSldUnit*nQtdade
            Else
                nVlrICMSSu := Iif(cCodEnquad != '4', Self:oMovimento:DefVlrConf(), (aDocOriApu[8]/aDocOriApu[1])*nQtdade) + ((aDocOriApu[6]/aDocOriApu[1])*nQtdade)
                nVlSldUnit := nVlrICMSSu/nQtdade
            EndIf

            //---Atualiza o saldo do produto---//
            Self:oSaldoProd:AtuSaldo(cTipoMov,cCodProd,nQtdade,nVlrICMSSu)

            //---Define Valor de Confronto / Define Valor a Ressarcir ou Complementar / Define Valor do Crédito da Operação Própria---//
            If cCodEnquad != '0'
                nVlrICMSCo := nVlrICMSSu - ((aDocOriApu[6]/aDocOriApu[1])*nQtdade)
                aVlrRC     := Self:oMovimento:DefVlrRC(cCodEnquad,nVlrICMSSu,nVlrICMSCo)
                If cCodEnquad == '4'
                    nVlrICMSOp := (aDocOriApu[8]/aDocOriApu[1])*nQtdade
                EndIf
            EndIf

        EndIf

    EndIf

    //---Carrega os valores apurados no atributo oMovimApur---//
    Self:oMovimApur:ClearMovAp()
    Self:oMovimApur:SetQtdade(nQtdade)
    If (cTipoMov=='E' .And. cTipoDoc != 'D') .Or. (cTipoMov=='S' .And. cTipoDoc == 'D')
        Self:oMovimApur:SetSupTot(nVlrICMSSu)
    Else
        Self:oMovimApur:SetSupUni(nVlSldUnit)
        Self:oMovimApur:SetEnquad(cCodEnquad)
        Self:oMovimApur:SetSupTot(nVlrICMSSu)

        If cCodEnquad == '4'
            Self:oMovimApur:SetConfEnt(nVlrICMSCo)
            Self:oMovimApur:SetApurCop(nVlrICMSOp)
        ElseIf cCodEnquad == '2'
            Self:oMovimApur:SetConfEnt(nVlrICMSCo)
        Else
            Self:oMovimApur:SetConfSai(nVlrICMSCo)
        EndIf
        If Len(aVlrRC)>0 
            If aVlrRC[1] == 'R'
                Self:oMovimApur:SetApurRes(aVlrRC[2])
            Else 
                Self:oMovimApur:SetApurCom(aVlrRC[2])
            EndIf
        EndIf

        //---Atualiza o atributo totalizador da apuração---//
        nPos := Ascan(Self:aTotApur,{|a|a[1] == cCodEnquad})
        If nPos > 0
            If (cTipoMov=='S' .And. cTipoDoc != 'D')
                Self:aTotApur[nPos][2] += Self:oMovimApur:GetApurRes()
                Self:aTotApur[nPos][3] += Self:oMovimApur:GetApurCom()
                Self:aTotApur[nPos][4] += Self:oMovimApur:GetApurCop()
            Else
                Self:aTotApur[nPos][2] -= Self:oMovimApur:GetApurRes()
                Self:aTotApur[nPos][3] -= Self:oMovimApur:GetApurCom()
                Self:aTotApur[nPos][4] -= Self:oMovimApur:GetApurCop()
            EndIf
        EndIf
        //---FIM Atualiza o atributo totalizador da apuração---//

    EndIf
    Self:oMovimApur:SetSldQtd(Self:oSaldoProd:GetQtdade())
    Self:oMovimApur:SetSldUni(Self:oSaldoProd:GetVlrUnit())
    Self:oMovimApur:SetSldTot(Self:oSaldoProd:GetVlrTot())
    //---FIM Carrega objeto de retorno com valores apurados para o movimento---//

Return 


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 12/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method GetIdApur() Class FISA190APURACAO
Return Self:cIdApur

Method GetAnoMes() Class FISA190APURACAO
Return Self:cAnoMes


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA190SALDOPRODUTO

Classe responsável por controlar saldos físicos e financeiros do produto analisado.
  
@author Ulisses P. Oliveira
@since 19/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA190SALDOPRODUTO FROM LongClassName

Data cCodProd    As Character //---Código do Produto                                  ---//
Data nQtdade     As Numeric   //---Saldo Físico do Produto                            ---//
Data nVlSldUnit  As Numeric   //---Valor Unitário do Saldo                            ---//
Data nVlSldTotal As Numeric   //---Valor Total do Saldo                               ---//
Data nUltUnDif0  As Numeric   //---Valor do Último Unitário do Saldo Diferente de Zero---//
Data nOrdMovAtu  As Numeric   //---Ordenação do Movimento Atual do Produto            ---//

Method New() CONSTRUCTOR
Method AtuSaldo(cTipoMov,cCodProd,nQtdade,nVlSldTotal)

//---Getters e Setters---//
Method SetCodProd(cCodProd)
Method SetQtdade(nQtdade)
Method SetVlrUnit(nVlSldUnit)
Method SetVlrTot(nVlSldTotal)
Method SetUltDif0(nUltUnDif0)
Method SetOrdMov(nOrdMovAtu)
Method GetCodProd()
Method GetQtdade()
Method GetVlrUnit()
Method GetVlrTot()
Method GetUltDif0()
Method GetOrdMov()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA190SALDOPRODUTO

@author Ulisses P. Oliveira
@since 19/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA190SALDOPRODUTO
    Self:cCodProd    := ""
	Self:nQtdade     := 0
	Self:nVlSldUnit  := 0
    Self:nVlSldTotal := 0
    Self:nUltUnDif0  := 0
    Self:nOrdMovAtu  := 0
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuSaldo()
  
Método que atualiza o saldo atual do produto analisado. É disparado a cada movimento analisado.

@author Ulisses P. Oliveira
@since 19/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method AtuSaldo(cTipoMov,cCodProd,nQtdade,nVlSldTotal) Class FISA190SALDOPRODUTO
    Local cProdAtual  := Self:GetCodProd()
    Local nQtdAtual   := Self:GetQtdade()
    Local nTotAtual   := Self:GetVlrTot()
    Local nUnitAtual  := 0

    If cCodProd == cProdAtual
        If cTipoMov=='E'
            nQtdAtual  += nQtdade
            nTotAtual  += nVlSldTotal
        Else
            nQtdAtual  -= nQtdade
            nTotAtual  -= nVlSldTotal
        EndIf
        If nQtdAtual > 0
            nUnitAtual := nTotAtual/nQtdAtual
        Else
            nUnitAtual := 0
        EndIf

        If nUnitAtual>0
            Self:SetUltDif0(nUnitAtual)
        EndIf
        Self:SetQtdade(nQtdAtual)
        Self:SetVlrUnit(nUnitAtual)
        Self:SetVlrTot(nTotAtual)
        Self:SetOrdMov(Self:GetOrdMov()+1)
    EndIf
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 19/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetCodProd(cCodProd) Class FISA190SALDOPRODUTO
    Self:cCodProd := cCodProd
Return

Method SetQtdade(nQtdade) Class FISA190SALDOPRODUTO
    Self:nQtdade := nQtdade
Return

Method SetVlrUnit(nVlSldUnit) Class FISA190SALDOPRODUTO
    Self:nVlSldUnit := nVlSldUnit
Return

Method SetVlrTot(nVlSldTotal) Class FISA190SALDOPRODUTO
    Self:nVlSldTotal := nVlSldTotal
Return

Method SetUltDif0(nUltUnDif0) Class FISA190SALDOPRODUTO
    Self:nUltUnDif0 := nUltUnDif0
Return

Method SetOrdMov(nOrdMovAtu) Class FISA190SALDOPRODUTO
    Self:nOrdMovAtu := nOrdMovAtu
Return

Method GetCodProd() Class FISA190SALDOPRODUTO
Return Self:cCodProd

Method GetQtdade() Class FISA190SALDOPRODUTO
Return Self:nQtdade

Method GetVlrUnit() Class FISA190SALDOPRODUTO
Return Self:nVlSldUnit

Method GetVlrTot() Class FISA190SALDOPRODUTO
Return Self:nVlSldTotal

Method GetUltDif0() Class FISA190SALDOPRODUTO
Return Self:nUltUnDif0

Method GetOrdMov() Class FISA190SALDOPRODUTO
Return Self:nOrdMovAtu


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA190MOVIMENTO

Classe responsável por controlar todas as colunas da Ficha 3, além de definir: 
Enquadramento Legal / Valor de Confronto / Valor a Ressarcir ou Complementar 
  
@author Ulisses P. Oliveira
@since 23/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA190MOVIMENTO FROM LongClassName

Data dDataMov     As Date      //---Data do Movimento
Data cTipoMov     As Character //---Tipo do Movimento (E-Entrada / S-Saída)
Data cNumDoc      As Character //---Número do Documento Fiscal
Data cItemDoc     As Character //---Item do Documento Fiscal
Data cSerieDoc    As Character //---Série do Documento Fiscal
Data cEspecDoc    As Character //---Espécie do Documento Fiscal
Data cChaveDoc    As Character //---Chave do Documento Fiscal
Data cNumSerECF   As Character //---Número de Série de Fabricação do ECF
Data cTipoDoc     As Character //---Tipo do Documento (Normal / Devolução / Complemento)
Data cCodProd     As Character //---Código do Produto
Data cCodPart     As Character //---Código do Participante
Data cTipoPart    As Character //---Tipo do Participante (Cliente Final / Revendedor)
Data nAliqInt     As Numeric   //---Alíquota Interna do Produto
Data cCFOP        As Character //---CFOP
Data cCST         As Character //---CST ICMS
Data cFGerNReal   As Character //---Indica se a operação (CFOP) deve ser enquadrada como 2-Fato Gerador não realizado
Data nQtdade      As Numeric   //---Quantidade
Data nVlrTotPrd   As Numeric   //---Valor Total do Produto
Data nVlrFrete    As Numeric   //---Valor do Frete
Data nVlrSeguro   As Numeric   //---Valor do Seguro
Data nVlrDesp     As Numeric   //---Valor das Despesas
Data nVlrDesc     As Numeric   //---Valor do Desconto
Data nVlrBICMS    As Numeric   //---Base de Cálculo do ICMS
Data nVlrICMS     As Numeric   //---Valor do ICMS
Data nVlrICMSST   As Numeric   //---Valor do ICMS Retido por ST
Data nVlrICMSAn   As Numeric   //---Valor do ICMS Antecipado
Data nVlrBICMND   As Numeric   //---Base de Cálculo do ICMS Recolhido Anteriormente por ST em entradas CST 60
Data nVlrICMSND   As Numeric   //---Valor do ICMS do ICMS Recolhido Anteriormente por ST em entradas CST 60
Data lEntProt                  //---Define comportamento adotado para a composição do Valor de Confronto, em saídas interestaduais: .T. ->  busca ICMS Próprio da op. entrada através das últimas entradas da tabela SFT. Caso não encontre, utiliza valor do atributo nVlrICMSEn / .F. -> Não busca ICMS próprio da op. entrada através das últimas entradas da tabela SFT. Usa o valor do atributo nVlrICMSEn.
Data nVlrICMSEn   As Numeric   //---Valor Unitário do ICMS Próprio da op. entrada, usado como Valor de Confronto apenas para saídas interestaduais
Data aDocOriApu   As Array     //---Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução
Data nVlrPauta    As Numeric   //---Valor da pauta informado no cadastro do produto no campo B1_VLR_ICM
Data cSerOri      As Character // Serie da NF de origem, quando informada.
Data cNFOri       As Character // Numeração da NF de origem, quando informada.
Data cItemOri     As Character // Item da NF de origem, quando informada.

Method New() CONSTRUCTOR
Method EnquadMov()
Method DefVlrConf(cCodEnquad)
Method DefVlrRC(cCodEnquad,nVlrICMSSu,nVlrICMSCo)
Method DefBaseICM()
Method ClearMov()

//---Getters e Setters---//
Method SetDataMov(dDataMov)
Method SetTipoMov(cTipoMov)
Method SetNumDoc(cNumDoc)
Method SetItemDoc(cItemDoc)
Method SetSerDoc(cSerieDoc)
Method SetEspDoc(cEspecDoc)
Method SetChvDoc(cChaveDoc)
Method SetNSerECF(cNumSerECF)
Method SetTipoDoc(cTipoDoc)
Method SetCodProd(cCodProd)
Method SetCodPart(cCodPart)
Method SetTipoPar(cTipoPart)
Method SetAliqInt(nAliqInt)
Method SetCFOP(cCFOP)
Method SetCST(cCST)
Method SetFGerNR(cFGerNReal)
Method SetQtdade(nQtdade)
Method SetTotPrd(nVlrTotPrd)
Method SetFrete(nVlrFrete)
Method SetSeguro(nVlrSeguro)
Method SetDespesa(nVlrDesp)
Method SetDescont(nVlrDesc)
Method SetBICMS(nVlrBICMS)
Method SetVICMS(nVlrICMS)
Method SetVICMSST(nVlrICMSST)
Method SetVICMSAn(nVlrICMSAn)
Method SetVBICMND(nVlrBICMND)
Method SetVICMSND(nVlrICMSND)
Method SetEntProt(lEntProt)
Method SetVICMSEn(nVlrICMSEn)
Method SetDocOrig(aDocOriApu)
Method SetVlrPauta(nVlrPauta)
Method SetSerOri(cSerOri)
Method SetNFOri(cNFOri)
Method SetItemOri(cItemOri)
Method GetDataMov()
Method GetTipoMov()
Method GetNumDoc()
Method GetItemDoc()
Method GetSerDoc()
Method GetEspDoc()
Method GetChvDoc()
Method GetNSerECF()
Method GetTipoDoc()
Method GetCodProd()
Method GetCodPart()
Method GetTipoPar()
Method GetAliqInt()
Method GetCFOP()
Method GetCST()
Method GetFGerNR()
Method GetQtdade()
Method GetTotPrd()
Method GetFrete()
Method GetSeguro()
Method GetDespesa()
Method GetDescont()
Method GetBICMS()
Method GetVICMS()
Method GetVICMSST()
Method GetVICMSAn()
Method GetVBICMND()
Method GetVICMSND()
Method GetEntProt()
Method GetVICMSEn()
Method GetDocOrig()
Method GetVlrPauta()
Method GetSerOri()
Method GetNFOri()
Method GetItemOri()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA190MOVIMENTO

@author Ulisses P. Oliveira
@since 23/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA190MOVIMENTO
    Self:ClearMov()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EnquadMov()
  
Método que define o Enquadramento Legal da operção de saída, retornando:
0-Saída para comercialização subsequente e todas demais saídas escrituradas no controle de estoque não elencadas nesta tabela. 
1-Saída a consumidor ou usuário final, conforme artigo 269 inciso I do RICMS/00. 
2-Fato gerador não realizado, conforme artigo 269 inciso II do RICMS/00. 
3-Saída ou saída subsequente amparada com isenção ou não incidência, conforme artigo 269 inciso III do RICMS/00.
4-Saída para outro estado, conforme artigo 269 inciso IV do RICMS/00.

"Nos casos de mercadoria recebida para comercialização vier a perecer, deteriorar-se ou for objeto de roubo, furto ou extravio, deverá emitir 
 nota fiscal de saída para baixa do estoque, sem destaque dos impostos com o CFOP 5.927. Deverá utilizar o código de enquadramento 2. 
 Preferencialmente deverá emitir uma única nota fiscal por período de referência, com todas as baixas ocorridas no período.""

@author Ulisses P. Oliveira
@since 23/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method EnquadMov() Class FISA190MOVIMENTO
    Local cCFOP      := Self:GetCFOP()
    Local cCST       := Self:GetCST()
    Local cFGerNReal := Self:GetFGerNR()
    Local cTipoPart  := Self:GetTipoPar()
    Local cTipoMov   := Self:GetTipoMov()
    Local nVlrPauta  := Self:GetVlrPauta()
    Local nQtdade    := Self:GetQtdade()
    Local nVlrTotPrd := Self:GetTotPrd()
    Local cRetorno   := '0'
    Local nVldPauta  := IIf(ValType(MV_PAR02) = "N", MV_PAR02, 1)   

    If (cTipoMov == 'S' .And. Left(cCFOP,1) == '6') .Or. (cTipoMov == 'E' .And. Left(cCFOP,1) == '2')
        If cCST $ '30/40/41'
            cRetorno := '3'      //--- 3-Saída ou saída subsequente com isenção ou não incidência ---//
        Else
            cRetorno := '4'      //--- 4-Saída para outro Estado ---//
        EndIf
    Else
        If cFGerNReal == '1'
            cRetorno := '2'      //--- 2-Fato Gerador não realizado ---//
        ElseIf (cTipoPart = 'F' .And. nVlrPauta > 0 .And. nVlrTotPrd <= (nQtdade*nVlrPauta) .And. nVldPauta == 1);
           .Or. (cTipoPart = 'F' .And. nVldPauta == 2) 
            cRetorno := '1'      //--- 1-Consumidor ou Usuário Final ---//
        ElseIf cCST $ '30/40/41' //--- 3-Saída ou saída subsequente com isenção ou não incidência ---//
            cRetorno := '3'
        EndIf
    EndIf

Return cRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DefVlrConf()
  
Método que define, para cada movimento analisado, o Valor de Confronto (Colunas 20 e 21 da Ficha 3).

@author Ulisses P. Oliveira
@since 23/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method DefVlrConf(cCodEnquad) Class FISA190MOVIMENTO
    Local   nRetorno   := 0
    Local   cCodProd   := Self:GetCodProd()
    Local   nQtdade    := Self:GetQtdade()
    Local   dDataMov   := Self:GetDataMov()
    Local   nAliqInt   := Self:GetAliqInt()
    Local   nVlrBICMS  := Self:GetBICMS()
    Local   lEntProt   := Self:GetEntProt()
    Local   nVlrICMSEn := Self:GetVICMSEn()
    Local   cSerOri    := Self:GetSerOri()
    Local   cNFOri     := Self:GetNFOri()
    Local   cItemOri   := Self:GetItemOri()
    Local   oMovEnProt := Nil
    Default cCodEnquad := ''

    If cCodEnquad != '0'
        If cCodEnquad == '2' .Or.  cCodEnquad == '4'
            If lEntProt
                oMovEnProt := FISA190MOVIMENTOENTPROTHEUS():New()
                oMovEnProt:cTipoRet := 'V' //--- 'V'-Valor de Confronto ---//
                oMovEnProt:cCodProd := cCodProd
                oMovEnProt:nQtdade  := nQtdade
                oMovEnProt:dDataMov := dDataMov
                oMovEnProt:nAliqInt := nAliqInt
                oMovEnProt:cSerOri  := cSerOri
                oMovEnProt:cNFOri   := cNFOri
                oMovEnProt:cItemOri := cItemOri
                oMovEnProt:DefICMSEnt()
                nRetorno := oMovEnProt:nVlrICMSCo
                nRetorno := Iif(nRetorno > 0, nRetorno, Round((nVlrICMSEn * nQtdade), 2))
            Else
                nRetorno := Round((nVlrICMSEn * nQtdade), 2)
            EndIf
        Else
            If nVlrBICMS = 0
                nVlrBICMS := Self:DefBaseICM()
            EndIf
            nRetorno := Round(((nVlrBICMS*nAliqInt)/100),2)
        EndIf
    EndIf

Return nRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DefVlrRC()

Método que define, para cada movimento analisado, o Valor de Ressarcimento ou Complemento
(Colunas 25 a 27 da Ficha 3).

@author Ulisses P. Oliveira
@since 03/12/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method DefVlrRC(cCodEnquad,nVlrICMSSu,nVlrICMSCo) Class FISA190MOVIMENTO
    Local aRetorno := {}

    If nVlrICMSSu >= nVlrICMSCo
        aRetorno := {'R',nVlrICMSSu-nVlrICMSCo}
    Else
        If cCodEnquad == '1'
            aRetorno := {'C',nVlrICMSCo-nVlrICMSSu}
        EndIf
    EndIf

Return aRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DefBaseICM()
  
Método que define a correspondente Base de ICMS da operação.

@author Ulisses P. Oliveira
@since 27/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method DefBaseICM() Class FISA190MOVIMENTO
    Local nRetorno   := 0
    Local nVlrTotPrd := Self:GetTotPrd()
    Local nVlrFrete  := Self:GetFrete()
    Local nVlrSeguro := Self:GetSeguro()
    Local nVlrDesp   := Self:GetDespesa()
    Local nVlrDesc   := Self:GetDescont()
    Local nQtdade    := Self:GetQtdade()
    Local nVlrPauta  := Self:GetVlrPauta()

    If nVlrPauta > 0
        nRetorno := (nQtdade * nVlrPauta) + nVlrFrete + nVlrSeguro + nVlrDesp - nVlrDesc
    Else
        nRetorno := nVlrTotPrd + nVlrFrete + nVlrSeguro + nVlrDesp - nVlrDesc
    EndIf

Return nRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClearMov
  
Método que limpa os valores do movimento.

@author Ulisses P. Oliveira
@since 12/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ClearMov() Class FISA190MOVIMENTO
    Self:dDataMov   := CToD("  /  /    ")
    Self:cTipoMov   := ""
    Self:cNumDoc    := ""
    Self:cItemDoc   := ""
    Self:cSerieDoc  := ""
    Self:cEspecDoc  := ""
    Self:cChaveDoc  := ""
    Self:cNumSerECF := ""
    Self:cTipoDoc   := ""
    Self:cCodProd   := ""
    Self:cCodPart   := ""
    Self:cTipoPart  := ""
    Self:nAliqInt   := 0
    Self:cCFOP      := ""
    Self:cCST       := ""
    Self:cFGerNReal := ""
    Self:nQtdade    := 0
    Self:nVlrTotPrd := 0
    Self:nVlrFrete  := 0
    Self:nVlrSeguro := 0
    Self:nVlrDesp   := 0
    Self:nVlrDesc   := 0
    Self:nVlrBICMS  := 0
    Self:nVlrICMS   := 0
    Self:nVlrICMSST := 0
    Self:nVlrICMSAn := 0
    Self:nVlrBICMND := 0
    Self:nVlrICMSND := 0
    Self:lEntProt   := .F.
    Self:nVlrICMSEn := 0
    Self:aDocOriApu := {}
    Self:nVlrPauta  := 0
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 23/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetDataMov(dDataMov) Class FISA190MOVIMENTO
    Self:dDataMov := dDataMov
Return

Method SetTipoMov(cTipoMov) Class FISA190MOVIMENTO
    Self:cTipoMov := cTipoMov
Return

Method SetNumDoc(cNumDoc) Class FISA190MOVIMENTO
    Self:cNumDoc := cNumDoc
Return

Method SetItemDoc(cItemDoc) Class FISA190MOVIMENTO
    Self:cItemDoc := cItemDoc
Return

Method SetSerDoc(cSerieDoc) Class FISA190MOVIMENTO
    Self:cSerieDoc := cSerieDoc
Return

Method SetEspDoc(cEspecDoc) Class FISA190MOVIMENTO
    Self:cEspecDoc := cEspecDoc
Return

Method SetChvDoc(cChaveDoc) Class FISA190MOVIMENTO
    Self:cChaveDoc := cChaveDoc
Return

Method SetNSerECF(cNumSerECF) Class FISA190MOVIMENTO
    Self:cNumSerECF := cNumSerECF
Return

Method SetTipoDoc(cTipoDoc) Class FISA190MOVIMENTO
    Self:cTipoDoc := cTipoDoc
Return

Method SetCodProd(cCodProd) Class FISA190MOVIMENTO
    Self:cCodProd := cCodProd
Return

Method SetCodPart(cCodPart) Class FISA190MOVIMENTO
    Self:cCodPart := cCodPart
Return

Method SetTipoPar(cTipoPart) Class FISA190MOVIMENTO
    Self:cTipoPart := cTipoPart
Return

Method SetAliqInt(nAliqInt) Class FISA190MOVIMENTO
    Self:nAliqInt := nAliqInt
Return

Method SetCFOP(cCFOP) Class FISA190MOVIMENTO
    Self:cCFOP := cCFOP
Return

Method SetCST(cCST) Class FISA190MOVIMENTO
    Self:cCST := cCST
Return

Method SetFGerNR(cFGerNReal) Class FISA190MOVIMENTO
    Self:cFGerNReal := cFGerNReal
Return

Method SetQtdade(nQtdade) Class FISA190MOVIMENTO
    Self:nQtdade := nQtdade
Return

Method SetTotPrd(nVlrTotPrd) Class FISA190MOVIMENTO
    Self:nVlrTotPrd := nVlrTotPrd
Return

Method SetFrete(nVlrFrete) Class FISA190MOVIMENTO
    Self:nVlrFrete := nVlrFrete
Return

Method SetSeguro(nVlrSeguro) Class FISA190MOVIMENTO
    Self:nVlrSeguro := nVlrSeguro
Return

Method SetDespesa(nVlrDesp) Class FISA190MOVIMENTO
    Self:nVlrDesp := nVlrDesp
Return

Method SetDescont(nVlrDesc) Class FISA190MOVIMENTO
    Self:nVlrDesc := nVlrDesc
Return

Method SetBICMS(nVlrBICMS) Class FISA190MOVIMENTO
    Self:nVlrBICMS := nVlrBICMS
Return

Method SetVICMS(nVlrICMS) Class FISA190MOVIMENTO
    Self:nVlrICMS := nVlrICMS
Return

Method SetVICMSST(nVlrICMSST) Class FISA190MOVIMENTO
    Self:nVlrICMSST := nVlrICMSST
Return

Method SetVICMSAn(nVlrICMSAn) Class FISA190MOVIMENTO
    Self:nVlrICMSAn := nVlrICMSAn
Return

Method SetVBICMND(nVlrBICMND) Class FISA190MOVIMENTO
    Self:nVlrBICMND := nVlrBICMND
Return

Method SetVICMSND(nVlrICMSND) Class FISA190MOVIMENTO
    Self:nVlrICMSND := nVlrICMSND
Return

Method SetEntProt(lEntProt) Class FISA190MOVIMENTO
    Self:lEntProt := lEntProt
Return

Method SetVICMSEn(nVlrICMSEn) Class FISA190MOVIMENTO
    Self:nVlrICMSEn := nVlrICMSEn
Return

Method SetDocOrig(aDocOriApu) Class FISA190MOVIMENTO
    Self:aDocOriApu := aDocOriApu
Return

Method SetVlrPauta(nVlrPauta) Class FISA190MOVIMENTO
    Self:nVlrPauta := nVlrPauta
Return

Method SetSerOri(cSerOri) Class FISA190MOVIMENTO
    Self:cSerOri := cSerOri
Return

Method SetNFOri(cNFOri) Class FISA190MOVIMENTO
    Self:cNFOri := cNFOri
Return

Method SetItemOri(cItemOri) Class FISA190MOVIMENTO
    Self:cItemOri := cItemOri
Return

Method GetDataMov() Class FISA190MOVIMENTO
Return Self:dDataMov

Method GetTipoMov() Class FISA190MOVIMENTO
Return Self:cTipoMov

Method GetNumDoc()  Class FISA190MOVIMENTO
Return Self:cNumDoc

Method GetItemDoc()  Class FISA190MOVIMENTO
Return Self:cItemDoc

Method GetSerDoc()  Class FISA190MOVIMENTO
Return Self:cSerieDoc

Method GetEspDoc()  Class FISA190MOVIMENTO
Return Self:cEspecDoc

Method GetChvDoc()  Class FISA190MOVIMENTO
Return Self:cChaveDoc

Method GetNSerECF() Class FISA190MOVIMENTO
Return Self:cNumSerECF

Method GetTipoDoc()  Class FISA190MOVIMENTO
Return Self:cTipoDoc

Method GetCodProd() Class FISA190MOVIMENTO
Return Self:cCodProd

Method GetCodPart() Class FISA190MOVIMENTO
Return Self:cCodPart

Method GetTipoPar() Class FISA190MOVIMENTO
Return Self:cTipoPart

Method GetAliqInt()  Class FISA190MOVIMENTO
Return Self:nAliqInt

Method GetCFOP() Class FISA190MOVIMENTO
Return Self:cCFOP

Method GetCST() Class FISA190MOVIMENTO
Return Self:cCST

Method GetFGerNR() Class FISA190MOVIMENTO
Return Self:cFGerNReal

Method GetQtdade() Class FISA190MOVIMENTO
Return Self:nQtdade

Method GetTotPrd() Class FISA190MOVIMENTO
Return Self:nVlrTotPrd

Method GetFrete() Class FISA190MOVIMENTO
Return Self:nVlrFrete

Method GetSeguro() Class FISA190MOVIMENTO
Return Self:nVlrSeguro

Method GetDespesa() Class FISA190MOVIMENTO
Return Self:nVlrDesp

Method GetDescont() Class FISA190MOVIMENTO
Return Self:nVlrDesc

Method GetBICMS() Class FISA190MOVIMENTO
Return Self:nVlrBICMS

Method GetVICMS() Class FISA190MOVIMENTO
Return Self:nVlrICMS

Method GetVICMSST() Class FISA190MOVIMENTO
Return Self:nVlrICMSST

Method GetVICMSAn() Class FISA190MOVIMENTO
Return Self:nVlrICMSAn

Method GetVBICMND() Class FISA190MOVIMENTO
Return Self:nVlrBICMND

Method GetVICMSND() Class FISA190MOVIMENTO
Return Self:nVlrICMSND

Method GetEntProt() Class FISA190MOVIMENTO
Return Self:lEntProt

Method GetVICMSEn() Class FISA190MOVIMENTO
Return Self:nVlrICMSEn

Method GetDocOrig() Class FISA190MOVIMENTO
Return Self:aDocOriApu

Method GetVlrPauta() Class FISA190MOVIMENTO
Return Self:nVlrPauta

Method GetSerOri() Class FISA190MOVIMENTO
Return Self:cSerOri

Method GetNFOri() Class FISA190MOVIMENTO
Return Self:cNFOri

Method GetItemOri() Class FISA190MOVIMENTO
Return Self:cItemOri


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA190MOVIMENTOAPURACAO

Classe reponsável por controlar os valores já apurados para o movimento.
  
@author Ulisses P. Oliveira
@since 24/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA190MOVIMENTOAPURACAO FROM LongClassName

Data nQtdade    As Numeric    //--- ---//
Data nVlrSupTot As Numeric    //--- ---//
Data nVlrSupUni As Numeric    //--- ---//
Data cCodEnquad As Character  //--- ---//
Data nConfSaida As Numeric    //--- ---//
Data nConfEnt   As Numeric    //--- ---//
Data nApurVlrR  As Numeric    //--- ---//
Data nApurVlrC  As Numeric    //--- ---//
Data nApurVlrCO As Numeric    //--- ---//
Data nSldQtdade As Numeric    //--- ---//
Data nSldVlrUni As Numeric    //--- ---//
Data nSldVlrTot As Numeric    //--- ---//

Method New() CONSTRUCTOR
Method ClearMovAp()

//---Getters e Setters---//
Method SetQtdade(nQtdade)
Method SetSupTot(nVlrSupTot)
Method SetSupUni(nVlrSupUni)
Method SetEnquad(cCodEnquad)
Method SetConfSai(nConfSaida)
Method SetConfEnt(nConfEnt)
Method SetApurRes(nApurVlrR)
Method SetApurCom(nApurVlrC)
Method SetApurCop(nApurVlrCO)
Method SetSldQtd(nSldQtdade)
Method SetSldUni(nSldVlrUni)
Method SetSldTot(nSldVlrTot)
Method GetQtdade()
Method GetSupTot()
Method GetSupUni()
Method GetEnquad()
Method GetConfSai()
Method GetConfEnt()
Method GetApurRes()
Method GetApurCom()
Method GetApurCop()
Method GetSldQtd()
Method GetSldUni()
Method GetSldTot()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA190MOVIMENTOAPURACAO

@author Ulisses P. Oliveira
@since 24/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA190MOVIMENTOAPURACAO
    Self:ClearMovAp()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Method ClearMovAp()
  
Método que limpa os valores apurados do movimento.

@author Ulisses P. Oliveira
@since 12/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ClearMovAp() Class FISA190MOVIMENTOAPURACAO
    Self:nQtdade    := 0
    Self:nVlrSupTot := 0
    Self:nVlrSupUni := 0
    Self:cCodEnquad := ""
    Self:nConfSaida := 0
    Self:nConfEnt   := 0
    Self:nApurVlrR  := 0
    Self:nApurVlrC  := 0
    Self:nApurVlrCO := 0
    Self:nSldQtdade := 0
    Self:nSldVlrUni := 0
    Self:nSldVlrTot := 0
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 24/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetQtdade(nQtdade) Class FISA190MOVIMENTOAPURACAO
    Self:nQtdade := nQtdade
Return

Method SetSupTot(nVlrSupTot) Class FISA190MOVIMENTOAPURACAO
    Self:nVlrSupTot := nVlrSupTot
Return

Method SetSupUni(nVlrSupUni) Class FISA190MOVIMENTOAPURACAO
    Self:nVlrSupUni := nVlrSupUni
Return

Method SetEnquad(cCodEnquad) Class FISA190MOVIMENTOAPURACAO
    Self:cCodEnquad := cCodEnquad
Return

Method SetConfSai(nConfSaida) Class FISA190MOVIMENTOAPURACAO
    Self:nConfSaida := nConfSaida
Return

Method SetConfEnt(nConfEnt) Class FISA190MOVIMENTOAPURACAO
    Self:nConfEnt := nConfEnt
Return

Method SetApurRes(nApurVlrR) Class FISA190MOVIMENTOAPURACAO
    Self:nApurVlrR := nApurVlrR
Return

Method SetApurCom(nApurVlrC) Class FISA190MOVIMENTOAPURACAO
    Self:nApurVlrC := nApurVlrC
Return

Method SetApurCop(nApurVlrCO) Class FISA190MOVIMENTOAPURACAO
    Self:nApurVlrCO := nApurVlrCO
Return

Method SetSldQtd(nSldQtdade) Class FISA190MOVIMENTOAPURACAO
    Self:nSldQtdade := nSldQtdade
Return

Method SetSldUni(nSldVlrUni) Class FISA190MOVIMENTOAPURACAO
    Self:nSldVlrUni := nSldVlrUni
Return

Method SetSldTot(nSldVlrTot) Class FISA190MOVIMENTOAPURACAO
    Self:nSldVlrTot := nSldVlrTot
Return

Method GetQtdade() Class FISA190MOVIMENTOAPURACAO
Return Self:nQtdade

Method GetSupTot() Class FISA190MOVIMENTOAPURACAO
Return Self:nVlrSupTot

Method GetSupUni() Class FISA190MOVIMENTOAPURACAO
Return Self:nVlrSupUni

Method GetEnquad() Class FISA190MOVIMENTOAPURACAO
Return Self:cCodEnquad

Method GetConfSai() Class FISA190MOVIMENTOAPURACAO
Return Self:nConfSaida

Method GetConfEnt() Class FISA190MOVIMENTOAPURACAO
Return Self:nConfEnt

Method GetApurRes() Class FISA190MOVIMENTOAPURACAO
Return Self:nApurVlrR

Method GetApurCom() Class FISA190MOVIMENTOAPURACAO
Return Self:nApurVlrC

Method GetApurCop() Class FISA190MOVIMENTOAPURACAO
Return Self:nApurVlrCO

Method GetSldQtd() Class FISA190MOVIMENTOAPURACAO
Return Self:nSldQtdade

Method GetSldUni() Class FISA190MOVIMENTOAPURACAO
Return Self:nSldVlrUni

Method GetSldTot() Class FISA190MOVIMENTOAPURACAO
Return Self:nSldVlrTot


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA190MOVIMENTOENTPROTHEUS
  
@author Ulisses P. Oliveira
@since 30/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA190MOVIMENTOENTPROTHEUS FROM LongClassName

Data cTipoRet   As Character //---C: Carga Inicial | V: Valor de Confronto---//
Data cCodProd   As Character //------//
Data nQtdade    As Numeric   //------//
Data dDataMov   As Date      //------//
Data nAliqInt   As Numeric   //------//
Data nVlrICMSCo As Numeric   //------//
Data nVlrICMSSu As Numeric   //------//
Data aSldVlrDet As Array     //------//
Data cSerOri    As Character //------//
Data cNFOri     As Character //------//
Data cItemOri   As Character //------//

Method New() CONSTRUCTOR
Method DefICMSEnt()

//---Getters e Setters---//

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA190MOVIMENTOENTPROTHEUS

@author Ulisses P. Oliveira
@since 30/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA190MOVIMENTOENTPROTHEUS
    Self:cTipoRet   := ""
    Self:cCodProd   := ""
    Self:nQtdade    := 0
    Self:dDataMov   := CToD("  /  /    ")
    Self:nAliqInt   := 0
    Self:nVlrICMSCo := 0
    Self:nVlrICMSSu := 0
    Self:aSldVlrDet := {}
    Self:cSerOri    := ""
    Self:cNFOri     := ""
    Self:cItemOri   := ""
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DefICMSEnt()
  
Método que define o Valor de Confronto à partir das Entradas. É também acionado para compor a Carga 
Inicial de Saldos.

@author Ulisses P. Oliveira
@since 30/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method DefICMSEnt() Class FISA190MOVIMENTOENTPROTHEUS
    Local cTipoRet    := Self:cTipoRet
    Local cCodProd    := Self:cCodProd
    Local nQtdade     := Self:nQtdade
    Local dDataMov    := Self:dDataMov
    Local nAliqInt    := Self:nAliqInt
    Local cSerOri     := Self:cSerOri
    Local cNFOri      := Self:cNFOri
    Local cItemOri    := Self:cItemOri
    Local aArea  	  := GetArea()
    Local cAlias 	  := GetNextAlias()
    Local cAliasSFT   := ''
    Local dDataDe     := FirstDay(dDataMov)
    Local dDataAte    := dDataMov
    Local lAchouFT	  := .F.
    Local aSldVlrDet  := {}
    Local nRetorno    := 0
    Local nQtdadePro  := 0
    Local nValorPro   := 0
    Local nVlrICMS    := 0
    Local cSGBD       := TCGetDB()
    Local cSubStrBD   := ''
    Local lNfEntOri   := !Empty(cNFOri) .And. !Empty(cSerOri) .And. !Empty(cItemOri)
    Local cSelect     := ''
    Local cWhere      := ''

    //---Verifica se existe quantidade suficiente na movimentação de entrada para compor valores para o produto---//
    If cSGBD = 'ORACLE'
        cSubStrBD := 'SUBSTR(SFT.FT_CLASFIS,2,2)'
    Else
        cSubStrBD := 'RIGHT(SFT.FT_CLASFIS,2)'
    EndIf
    cSubStrBD := "%" + cSubStrBD + "%"

    cSelect := "%"
    cSelect += "SUM(SFT.FT_QUANT) QUANT"
    If lNfEntOri 
        //------------------------------------------------------------------------------------------------------------------------------------------------------//
        /* Caso o Documento da Entrada Efetiva seja identificado (aquele que ensejou a saída), devem ser ser setados os atributos cNFOri / cSerOri / cItemOri. 
           Neste caso, a query deve trazer também a quantidade desse documento e, se essa quantidade suportar a quantidade requisitada através do atributo nQtdade, 
           essa entrada será utilizada para a composição do Valor de Confronto. Caso o Documento de Entrada não seja identificado, ou sua quantidade seja insuficiente, 
           a rotina seguirá com cálculo padrão, que é a composição de valores via média ponderada das últimas entradas, até atingir a quantidade definida em nQtdade. 
           Dessa forma, seguimos o disposto no item 3.3.8 do Manual do Sistema de Apuração do Ressarcimento ou Complemento do ICMS Retido por Substituição Tributária 
           ou Antecipado.
        */
        //------------------------------------------------------------------------------------------------------------------------------------------------------//        
        cSelect += " , SUM(CASE WHEN "
        cSelect += " SFT.FT_NFISCAL = '" + cNFOri         + "' AND "
        cSelect += " SFT.FT_SERIE   = '" + cSerOri        + "' AND "
        cSelect += " SFT.FT_ITEM    = '" + cItemOri       + "' "
	    cSelect += " THEN SFT.FT_QUANT "
	    cSelect += " ELSE 0 "
	    cSelect += " END) QUANT2 "
    Else
        cSelect += ", 0 AS QUANT2 "
    Endif
    cSelect += "%"

    BeginSql Alias cAlias
        SELECT %Exp:cSelect%
        FROM %TABLE:SFT% SFT
        INNER JOIN %TABLE:F2W% F2W ON (F2W.F2W_FILIAL = %XFILIAL:F2W% AND F2W.F2W_CFOP  = SFT.FT_CFOP    AND F2W.%NOTDEL%)
        INNER JOIN %TABLE:F3M% F3M ON (F3M.F3M_FILIAL = %XFILIAL:F3M% AND F3M.F3M_IDF2W = F2W.F2W_IDTAB  AND F3M.F3M_CSTICM = %Exp:cSubStrBD% AND F3M.%NOTDEL%)
        WHERE  SFT.FT_FILIAL=%XFILIAL:SFT%                  AND
               SFT.FT_PRODUTO = %EXP:cCodProd%              AND
               SFT.FT_TIPO NOT IN ('D','B','S','P','I','C') AND
               SFT.FT_TIPOMOV  = 'E'                        AND
               SFT.FT_DTCANC   = ''                         AND
               SFT.FT_ENTRADA  <=  %EXP:dDataAte%           AND
               SFT.FT_NFORI    = ' '                        AND
               SFT.FT_SERORI   = ' '                        AND
               SFT.FT_ITEMORI  = ' '                        AND
               SFT.%NOTDEL%	
    EndSql

    DbSelectArea(cAlias)
    If (cAlias)->QUANT >= nQtdade
    	lAchouFT := .T.
        If lNfEntOri .And. (cAlias)->QUANT2 >= nQtdade
            cWhere := " AND "
            cWhere += " SFT.FT_NFISCAL = '" + cNFOri   + "' AND "
            cWhere += " SFT.FT_SERIE   = '" + cSerOri  + "' AND "
            cWhere += " SFT.FT_ITEM    = '" + cItemOri + "'"
        EndIf
        cWhere := "%" + cWhere + "%"
    EndIf
    (cAlias)->(DbCloseArea()) 

    If lAchouFT

    	While nQtdade > 0
            cAliasSFT := GetNextAlias()

            BeginSql Alias cAliasSFT
                SELECT  SFT.FT_NFISCAL, 
                        SFT.FT_SERIE, 
                        SFT.FT_CLIEFOR, 
                        SFT.FT_LOJA, 
                        SFT.FT_ITEM, 
                        SFT.FT_PRODUTO, 
                        SFT.FT_CFOP, 
                        CASE 
                            WHEN %Exp:cSubStrBD% = '60' AND (SFT.FT_ICMSRET+SFT.FT_VALANTI) = 0
                            THEN 0
                            ELSE CASE 
                                     WHEN SFT.FT_VALICM = 0 AND (SFT.FT_BASEICM+SFT.FT_OUTRICM) > 0
                                     THEN SD1.D1_VALICM 
                                     ELSE SFT.FT_VALICM
                                 END
                        END                                                                      AS VALORICMS,
                        CASE
                            WHEN SFT.FT_VALANTI > 0
                            THEN SFT.FT_VALANTI                                   
                            ELSE SFT.FT_ICMSRET 
                        END                                                                      AS VALORST,
                        CASE 
                            WHEN %Exp:cSubStrBD% = '60' AND (SFT.FT_ICMSRET+SFT.FT_VALANTI) = 0
                            THEN SFT.FT_BASNDES
                            ELSE 0
                        END                                                                      AS BASEANT,
                        CASE 
                            WHEN %Exp:cSubStrBD% = '60' AND (SFT.FT_ICMSRET+SFT.FT_VALANTI) = 0
                            THEN SFT.FT_ICMNDES
                            ELSE 0
                        END                                                                      AS VALORANT,
                        (SFT.FT_TOTAL+SFT.FT_FRETE+SFT.FT_SEGURO+SFT.FT_DESPESA-SFT.FT_DESCONT)  AS BASE, 
                        SFT.FT_QUANT                                                             AS QUANT
                FROM  %TABLE:SFT% SFT INNER JOIN %TABLE:SD1% SD1 ON (SD1.D1_FILIAL  = %XFILIAL:SD1% AND SD1.D1_DOC    = SFT.FT_NFISCAL AND SD1.D1_SERIE = SFT.FT_SERIE AND SD1.D1_FORNECE = SFT.FT_CLIEFOR AND SD1.D1_LOJA = SFT.FT_LOJA AND SD1.D1_COD = SFT.FT_PRODUTO AND SD1.D1_ITEM = SFT.FT_ITEM AND SD1.%NOTDEL%)
                                      INNER JOIN %TABLE:F2W% F2W ON (F2W.F2W_FILIAL = %XFILIAL:F2W% AND F2W.F2W_CFOP  = SFT.FT_CFOP    AND F2W.%NOTDEL%)
                                      INNER JOIN %TABLE:F3M% F3M ON (F3M.F3M_FILIAL = %XFILIAL:F3M% AND F3M.F3M_IDF2W = F2W.F2W_IDTAB  AND F3M.F3M_CSTICM = %Exp:cSubStrBD% AND F3M.%NOTDEL%)
                WHERE  SFT.FT_FILIAL=%XFILIAL:SFT%                       AND
                       SFT.FT_PRODUTO = %EXP:cCodProd%                   AND
                       SFT.FT_TIPO NOT IN ('D','B','S','P','I','C')      AND
                       SFT.FT_TIPOMOV  = 'E'                             AND
                       SFT.FT_DTCANC   = ''		                         AND
                       SFT.FT_ENTRADA >=  %EXP:dDataDe%                  AND
                       SFT.FT_ENTRADA <=  %EXP:dDataAte%                 AND
                       SFT.FT_NFORI    = ' '                             AND
                       SFT.FT_SERORI   = ' '                             AND
                       SFT.FT_ITEMORI  = ' '                             AND
                       SFT.%NOTDEL%
                       %Exp:cWhere%
                ORDER BY SFT.FT_ENTRADA DESC, SD1.D1_NUMSEQ DESC
            EndSql 

            DbSelectArea(cAliasSFT)
            While !(cAliasSFT)->(Eof()) .And. nQtdade > 0

                If cTipoRet == 'C'
                    If ((cAliasSFT)->VALORICMS + (cAliasSFT)->VALORST) > 0 .And. (cAliasSFT)->VALORANT = 0
                        nVlrICMS := (cAliasSFT)->VALORICMS + (cAliasSFT)->VALORST
                    Else
                        nVlrICMS := Iif((cAliasSFT)->BASEANT > 0 .And. nAliqInt > 0, Round((((cAliasSFT)->BASEANT*nAliqInt)/100),2), (cAliasSFT)->VALORANT)
                    EndIf
                Else
                    nVlrICMS := Iif((cAliasSFT)->VALORICMS > 0, (cAliasSFT)->VALORICMS, (((cAliasSFT)->BASE * nAliqInt) / 100))
                EndIf

                If (cAliasSFT)->QUANT <= nQtdade
                    nValorPro  := nVlrICMS
                    nQtdadePro := (cAliasSFT)->QUANT
                Else
                    nValorPro  := (nVlrICMS / (cAliasSFT)->QUANT) * nQtdade
                    nQtdadePro := nQtdade
                EndIf
                nRetorno += nValorPro
                nQtdade  -= nQtdadePro

                If cTipoRet == 'C'
                    aAdd(aSldVlrDet,{(cAliasSFT)->FT_NFISCAL,;
                                     (cAliasSFT)->FT_SERIE,;
                                     (cAliasSFT)->FT_CLIEFOR,;
                                     (cAliasSFT)->FT_LOJA,;
                                     (cAliasSFT)->FT_ITEM,;
                                     (cAliasSFT)->FT_PRODUTO,; 
                                     (cAliasSFT)->FT_CFOP,; 
                                     nQtdadePro,; 
                                     Round((nValorPro/nQtdadePro),2),;
                                     nValorPro})
                EndIf

                (cAliasSFT)->(DbSkip())
            EndDo
            (cAliasSFT)->(DbCloseArea()) 

            //---Período Anterior---//
            dDataDe	 := FirstDay(dDataDe-1)
            dDataAte := LastDay(dDataDe)
    	EndDo

        If cTipoRet == 'C'
            Self:nVlrICMSSu := nRetorno
            Self:aSldVlrDet := aSldVlrDet
        Else
            Self:nVlrICMSCo := nRetorno
        EndIf
    
    EndIf

    RestArea(aArea)

Return