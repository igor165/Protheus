#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA192.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA192
  
Rotina de Apuração do Ressarcimento ou Complemento do ICMS Retido por Substituição Tributária ou Antecipado.
Para o Estado de São Paulo, o método de apuração é determinado pela portaria CAT 42/2018.

@author Ulisses P. Oliveira
@since 05/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA192()
    Local aArea     := GetArea()
    Local cIdApur   := ''
    Local cPerApur  := ''
    Local lProcess  := .T.

    If Pergunte("FSA192",.T.)
        cPerApur := MV_PAR01

        //---Verifica a existência de apuração no período selecionado---//
        cIdApur := CheckApur(cPerApur)        

        If !Empty(cIdApur)
		    If (ApMsgNoYes(STR0002 + CHR(10) + CHR(13) + STR0001 ) ) //"Apuração já realizada no período selecionado." "Deseja fazer o reprocessamento?"
                DeletApur(cIdApur,cPerApur)
            Else
                lProcess := .F.
            EndIf
        EndIf

        If lProcess
            FwMsgRun(,{|oSay| FISA192A(oSay,cPerApur)},STR0003,"") //"Apuração do Ressarcimento do ICMS Retido por ST"
        EndIf

    EndIf

    RestArea(aArea)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
  
Rotina de Processamento da Apuração.

@author Ulisses P. Oliveira
@since 05/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA192A(oSay,cPerApur)
    Local cAlias      := GetNextAlias()
    Local aCodRes     := Iif(Empty(SuperGetMv("MV_CODRESS",,"")),{"SP10090719","SP10090721"},&(SuperGetMv("MV_CODRESS",,{"SP10090719","SP10090721"}))) //---Códigos de Lançamento de Ressarcimento---//
    Local cIdApur     := ''
    Local cPerSld     := ''
    Local dDataDe     := CtoD('  /  /    ')
    Local dDataAte    := CtoD('  /  /    ')
    Local cProduto    := ''
    Local nMVICMPAD   := SuperGetMV('MV_ICMPAD')
    Local nAliqInt    := 0
    Local cTipoPart   := ''
    Local aDocOriApu  := {}
    Local oApuracao   := Nil
    Local cSGBD       := TCGetDB()
    Local cSubStrBD   := ''
    Local lF2VICMSEN  := F2V->(FieldPos("F2V_ICMSEN")) > 0
    Local cF2VICMSEN  := ''
    Local oModel      := FWLoadModel('FISA191') //---Model da rotina FISA191---//

    Private lAutomato := IiF(IsBlind(),.T.,.F.)

    AtualizaMsg(oSay,STR0004) //"Iniciando processamento..."

    cIdApur   := FWUUID("F2U")
    dDataDe   := StoD(MV_PAR01+'01')
    dDataAte  := LastDay(dDataDe)

    //---Classe responsável pela apuração do movimento---//
    oApuracao := FISA190APURACAO():New(cIdApur,cPerApur)

    AtualizaMsg(oSay,STR0005) //"Verificando movimento no período..."

    //---Query Principal---//
    If cSGBD = 'ORACLE'
        cSubStrBD := 'SUBSTR(SFT.FT_CLASFIS,2,2)'
    Else
        cSubStrBD := 'RIGHT(SFT.FT_CLASFIS,2)'
    EndIf
    cSubStrBD := "%" + cSubStrBD + "%"

    If lF2VICMSEN
        cF2VICMSEN := "ISNULL(F2V.F2V_ICMSEN,0)"
    Else
        cF2VICMSEN := "0"
    EndIf
    cF2VICMSEN := "%" + cF2VICMSEN + "%"
    
    BeginSql Alias cAlias
	    COLUMN FT_EMISSAO AS DATE
	    COLUMN FT_ENTRADA AS DATE
        COLUMN FT_DATAMOV AS DATE

        SELECT SFT.FT_PRODUTO             FT_PRODUTO,
	           SB1.B1_CRICMS              B1_CRICMS,
	           SB1.B1_PICM                B1_PICM,
	           ISNULL(F2V.F2V_ANOMES,'')  F2V_ANOMES,
	           ISNULL(F2V.F2V_QTDSLD,0)   F2V_QTDSLD,
	           ISNULL(F2V.F2V_VUNSLD,0)   F2V_VUNSLD, 
	           ISNULL(F2V.F2V_VTOSLD,0)   F2V_VTOSLD,
               %Exp:cF2VICMSEN%           F2V_ICMSEN,
	           CASE SFT.FT_TIPOMOV
                   WHEN 'E' THEN          FT_ENTRADA
		           ELSE                   FT_EMISSAO
               END                        FT_DATAMOV,
	           SFT.FT_TIPOMOV             FT_TIPOMOV,
	           SFT.FT_TIPO                FT_TIPO,
	           CASE SFT.FT_TIPOMOV
                   WHEN 'E' THEN 
                        CASE SFT.FT_TIPO 
                            WHEN 'D' THEN 
                                CASE 
                                    WHEN SFT.FT_ENTRADA = SF22.F2_EMISSAO THEN '5'
                                    ELSE				                       '2'
                                END
                            ELSE '1' 
                        END 
                    ELSE 
                        CASE SFT.FT_TIPO 
                            WHEN 'D' THEN '3' 
                            ELSE          '4' 
                        END 
               END                        FT_ORDEM,
               SFT.FT_NFISCAL             FT_NFISCAL,
               SFT.FT_SERIE               FT_SERIE,
               SFT.FT_ITEM                FT_ITEM,
               SFT.FT_ESPECIE             FT_ESPECIE,
	           SFT.FT_CHVNFE              FT_CHVNFE,
               SFT.FT_CLIEFOR             FT_CLIEFOR,
               SFT.FT_LOJA                FT_LOJA,
	           SFT.FT_CFOP                FT_CFOP,
               SFT.FT_CLASFIS             FT_CLASFIS,
	           SFT.FT_QUANT               FT_QUANT,
	           SFT.FT_TOTAL               FT_TOTAL,
	           SFT.FT_FRETE               FT_FRETE,
	           SFT.FT_SEGURO              FT_SEGURO,
	           SFT.FT_DESPESA             FT_DESPESA,
	           SFT.FT_DESCONT             FT_DESCONT,
	           SFT.FT_BASEICM             FT_BASEICM,
               SFT.FT_ESTOQUE             FT_ESTOQUE,
	           CASE 
	               WHEN %Exp:cSubStrBD% = '60' AND (SFT.FT_ICMSRET+SFT.FT_VALANTI) = 0
	               THEN 0
	               ELSE CASE 
	                        WHEN SFT.FT_BASEICM = 0 AND SFT.FT_OUTRICM > 0
	                        THEN CASE SFT.FT_TIPOMOV
	                                 WHEN 'E' 
	                                 THEN SD1.D1_VALICM
	                                 ELSE SD2.D2_VALICM
	                             END
	                        ELSE SFT.FT_VALICM 
	                    END
	           END                        FT_VALICM,
	           SFT.FT_ICMSRET             FT_ICMSRET,
	           SFT.FT_VALANTI             FT_VALANTI,
               CASE 
                    WHEN %Exp:cSubStrBD% = '60' AND (SFT.FT_ICMSRET+SFT.FT_VALANTI) = 0
                    THEN SFT.FT_BASNDES
                    ELSE 0
               END                        FT_BASNDES,
               CASE 
                    WHEN %Exp:cSubStrBD% = '60' AND (SFT.FT_ICMSRET+SFT.FT_VALANTI) = 0
                    THEN SFT.FT_ICMNDES
                    ELSE 0
               END                        FT_ICMNDES,
               ISNULL(SA1.A1_TIPO,'')     A1_TIPO, 
               ISNULL(SF21.F2_TIPOCLI,'') F21_TIPOCLI, 
               ISNULL(SF22.F2_TIPOCLI,'') F22_TIPOCLI,  
	           F2W.F2W_FATGER             F2W_FATGER,
	           ISNULL(SFI.FI_SERPDV,'')   FI_SERPDV,
	           SFT.FT_NFORI               FT_NFORI, 
	           SFT.FT_SERORI              FT_SERORI,
               CASE
                    WHEN SD2.D2_ITEMORI <> ''
                    THEN SD2.D2_ITEMORI
                    ELSE SFT.FT_ITEMORI
               END                        FT_ITEMORI,

               SFT.FT_PAUTST              FT_PAUTST
        FROM  %table:SFT% SFT INNER JOIN      %table:SB1% SB1  ON (SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.B1_COD     = SFT.FT_PRODUTO  AND SB1.%NotDel%)
                              INNER JOIN      %table:F2W% F2W  ON (F2W.F2W_FILIAL = %xFilial:F2W% AND F2W.F2W_CFOP   = SFT.FT_CFOP     AND F2W.%NotDel%)
                              INNER JOIN      %table:F3M% F3M  ON (F3M.F3M_FILIAL = %xFilial:F3M% AND F3M.F3M_IDF2W  = F2W.F2W_IDTAB   AND F3M.F3M_CSTICM = %Exp:cSubStrBD%         AND F3M.%NotDel%)
                              LEFT OUTER JOIN %table:F2V% F2V  ON (F2V.F2V_FILIAL = %xFilial:F2V% AND F2V.F2V_ANOMES = %Exp:cPerApur%  AND F2V.F2V_PRODUT = SB1.B1_COD              AND F2V.%NotDel%)
                              LEFT OUTER JOIN %table:SA1% SA1  ON (SA1.A1_FILIAL  = %xFilial:SA1% AND SA1.A1_COD     = SFT.FT_CLIEFOR  AND SA1.A1_LOJA    = SFT.FT_LOJA             AND ((SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO NOT IN ('D','B')) OR (SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO IN ('D','B')))              AND  SA1.%NotDel%)
				              LEFT OUTER JOIN %table:SF2% SF21 ON (SF21.F2_FILIAL = %xFilial:SF2% AND SF21.F2_DOC    = SFT.FT_NFISCAL  AND SF21.F2_SERIE  = SFT.FT_SERIE            AND SF21.F2_CLIENTE = SFT.FT_CLIEFOR AND SF21.F2_LOJA = SFT.FT_LOJA AND (SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO NOT IN ('D','B')) AND SF21.%NotDel%)
				              LEFT OUTER JOIN %table:SF2% SF22 ON (SF22.F2_FILIAL = %xFilial:SF2% AND SF22.F2_DOC    = SFT.FT_NFORI    AND SF22.F2_SERIE  = SFT.FT_SERORI           AND SF22.F2_CLIENTE = SFT.FT_CLIEFOR AND SF22.F2_LOJA = SFT.FT_LOJA AND (SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO='D')              AND SF22.%NotDel%)
                              LEFT OUTER JOIN %table:SFI% SFI  ON (SFI.FI_FILIAL  = %xFilial:SFI% AND SFI.FI_DTMOVTO = SFT.FT_EMISSAO  AND SFI.FI_PDV     = SFT.FT_PDV              AND SFI.%NotDel%)
                              LEFT OUTER JOIN %table:SD1% SD1  ON (SD1.D1_FILIAL  = %xFilial:SD1% AND SD1.D1_DOC     = SFT.FT_NFISCAL  AND SD1.D1_SERIE   = SFT.FT_SERIE            AND SD1.D1_FORNECE = SFT.FT_CLIEFOR AND SD1.D1_LOJA = SFT.FT_LOJA AND SD1.D1_COD = SFT.FT_PRODUTO AND SD1.D1_ITEM = SFT.FT_ITEM AND SFT.FT_TIPOMOV = 'E' AND SD1.%NotDel%)
                              LEFT OUTER JOIN %table:SD2% SD2  ON (SD2.D2_FILIAL  = %xFilial:SD2% AND SD2.D2_DOC     = SFT.FT_NFISCAL  AND SD2.D2_SERIE   = SFT.FT_SERIE            AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND SD2.D2_LOJA = SFT.FT_LOJA AND SD2.D2_COD = SFT.FT_PRODUTO AND SD2.D2_ITEM = SFT.FT_ITEM AND SFT.FT_TIPOMOV = 'S' AND SD2.%NotDel%)
        WHERE SFT.FT_FILIAL   = %xFilial:SFT%  AND 
        	  SFT.FT_ENTRADA >= %Exp:dDataDe%  AND 
        	  SFT.FT_ENTRADA <= %Exp:dDataAte% AND
        	  SFT.FT_TIPO    <> 'S'            AND
        	  SFT.FT_DTCANC   = ''             AND
              SFT.%NOTDEL%                     AND
              SB1.B1_CRICMS   = '1'
        ORDER BY SFT.FT_PRODUTO, FT_DATAMOV, FT_ORDEM, FT_CLIEFOR, FT_LOJA, FT_NFISCAL, FT_ITEM, FT_SERIE
    EndSql

    // FOI RETIRADO O TRANSACTION POIS ESTAVA DANDO IMPACTO QUANDO SE RODAVA PARA UMA QUANTIDADE GRADE DE REGISTROS.
    // A PROPRIA ROTINA FOI CRIADA JA COM UM CONTROLE DE SEGURANÇA CASO UM APURAÇÃO DE PROBLEMA DURANTE O PROCESSO.
    //Begin Transaction

        //---Grava registro cabeçalho da apuração (Tabela F2X)---//        
        GravaF2XT(oApuracao,1)

        AtualizaMsg(oSay,STR0006) //"Processando movimento..."

        DbSelectArea(cAlias)
        While !(cAlias)->(Eof())

            //DSERFIS1-16149 - Caso a TES utilizada seja Entrada para teste, CFOP 1949, CST 00 que NÃO atualiza estoque
            If !(Alltrim((cAlias)->FT_CFOP) == '1949' .And. Right((cAlias)->FT_CLASFIS,2) == '00' .And. (cAlias)->FT_ESTOQUE  != 'S' .And. (cAlias)->FT_TIPOMOV == 'E')

                If cProduto != (cAlias)->FT_PRODUTO

                    //---Atualiza o saldo final do produto (Tabela F2V)---//
                    If !Empty(cProduto)
                        GravaF2V('1',oApuracao,Iif(Empty(cPerSld),.T.,.F.),,oModel)
                    EndIf

                    //---Método SetaSldIni: Carrega o saldo inicial do produto (Tabela F2V)---//
                    oApuracao:SetaSldIni((cAlias)->FT_PRODUTO,(cAlias)->F2V_QTDSLD,(cAlias)->F2V_VUNSLD,(cAlias)->F2V_VTOSLD)

                    //---Define a alíquota interna do ICMS para o produto---//
                    nAliqInt := Iif((cAlias)->B1_PICM>0, (cAlias)->B1_PICM, nMVICMPAD)

                EndIf

                //---Define Tipo do Participante (Cliente Final / Revendedor)---//
                If !Empty((cAlias)->F21_TIPOCLI)
                    cTipoPart := (cAlias)->F21_TIPOCLI
                ElseIf !Empty((cAlias)->F22_TIPOCLI)
                    cTipoPart := (cAlias)->F22_TIPOCLI            
                Else
                    cTipoPart := (cAlias)->A1_TIPO
                EndIf

                //---Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução---//
                aDocOriApu := aSize(aDocOriApu,0)
                If (cAlias)->FT_TIPO == 'D'
                    aDocOriApu := PesqApur((cAlias)->FT_TIPOMOV, (cAlias)->FT_NFORI, (cAlias)->FT_SERORI, (cAlias)->FT_ITEMORI, (cAlias)->FT_CLIEFOR, (cAlias)->FT_LOJA, (cAlias)->FT_PRODUTO, aCodRes)
                EndIf

                //---Método SetaMovim: Carrega os dados do movimento para que seja feita sua apuração---//
                oApuracao:SetaMovim((cAlias)->FT_DATAMOV,;           //---dDataMov   - Data do Movimento
                                    (cAlias)->FT_TIPOMOV,;           //---cTipoMov   - Tipo do Movimento (E-Entrada / S-Saída)
                                    (cAlias)->FT_NFISCAL,;           //---cNumDoc    - Número do Documento Fiscal
                                    (cAlias)->FT_ITEM,;              //---cItemDoc   - Item do Documento Fiscal
                                    (cAlias)->FT_SERIE,;             //---cSerieDoc  - Série do Documento Fiscal
                                    (cAlias)->FT_ESPECIE,;           //---cEspecDoc  - Espécie do Documento Fiscal
                                    (cAlias)->FT_CHVNFE,;            //---cChaveDoc  - Chave do Documento Fiscal
                                    (cAlias)->FI_SERPDV,;            //---cNumSerECF - Número de Série de Fabricação do ECF
                                    (cAlias)->FT_TIPO,;              //---cTipoDoc   - Tipo do Documento (Normal / Devolução / Complemento)
                                    (cAlias)->FT_PRODUTO,;           //---cCodProd   - Código do Produto
                                    (cAlias)->(FT_CLIEFOR+FT_LOJA),; //---cCodPart   - Código do Participante
                                    cTipoPart,;                      //---cTipoPart  - Tipo do Participante (Cliente Final / Revendedor)
                                    nAliqInt,;                       //---nAliqInt   - Alíquota Interna do Produto
                                    (cAlias)->FT_CFOP,;              //---cCFOP      - CFOP
                                    Right((cAlias)->FT_CLASFIS,2),;  //---cCST       - CST ICMS
                                    (cAlias)->F2W_FATGER,;           //---cFGerNReal - Indica se a operação (CFOP) deve ser enquadrada como 2-Fato Gerador não realizado
                                    (cAlias)->FT_QUANT,;             //---nQtdade    - Quantidade
                                    (cAlias)->FT_TOTAL,;             //---nVlrTotPrd - Valor Total do Produto
                                    (cAlias)->FT_FRETE,;             //---nVlrFrete  - Valor do Frete
                                    (cAlias)->FT_SEGURO,;            //---nVlrSeguro - Valor do Seguro
                                    (cAlias)->FT_DESPESA,;           //---nVlrDesp   - Valor das Despesas
                                    (cAlias)->FT_DESCONT,;           //---nVlrDesc   - Valor do Desconto
                                    (cAlias)->FT_BASEICM,;           //---nVlrBICMS  - Base de Cálculo do ICMS
                                    (cAlias)->FT_VALICM,;            //---nVlrICMS   - Valor do ICMS
                                    (cAlias)->FT_ICMSRET,;           //---nVlrICMSST - Valor do ICMS Retido por ST
                                    (cAlias)->FT_VALANTI,;           //---nVlrICMSAn - Valor do ICMS Antecipado
                                    (cAlias)->FT_BASNDES,;           //---nVlrBICMND - Base de Cálculo do ICMS Recolhido Anteriormente por ST em entradas CST 60
                                    (cAlias)->FT_ICMNDES,;           //---nVlrICMSND - Valor do ICMS do ICMS Recolhido Anteriormente por ST em entradas CST 60
                                    .T.,;                            //---lEntProt   - Define comportamento adotado para a composição do Valor de Confronto, em saídas interestaduais: .T. ->  busca ICMS Próprio da op. entrada através das últimas entradas da tabela SFT. Caso não encontre, utiliza valor do atributo nVlrICMSEn / .F. -> Não busca ICMS próprio da op. entrada através das últimas entradas da tabela SFT. Usa o valor do atributo nVlrICMSEn.
                                    (cAlias)->F2V_ICMSEN,;           //---nVlrICMSEn - Valor Unitário do ICMS Próprio da op. entrada, usado como Valor de Confronto apenas para saídas interestaduais
                                    aDocOriApu,;                     //---aDocOriApu - Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução
                                    (cAlias)->FT_PAUTST,;            //---nVlrPauta  - Valor da pauta informado no cadastro do produto no campo B1_VLR_ICM
                                    (cAlias)->FT_SERORI,;            //---cSerOri    - Serie da nota de origem
                                    (cAlias)->FT_NFORI ,;            //---cNFOri     - Numeração da nota de origem
                                    (cAlias)->FT_ITEMORI)            //---cItemOri   - Item da nota de origem

                //---Método ApuraMovim: Para Entradas / Devoluções de Entradas.: Define Total de ICMS Suportado / Atualiza o saldo do produto---//
                //---                   Para Saídas............................: Define Total de ICMS Suportado / Atualiza o saldo do produto / Enquadra o Movimento / Define Valor de Confronto / Define Valor a Ressarcir ou Complementar---//
                //---                   Para Devoluções de Saídas..............: Define Total de ICMS Suportado (De acordo com mov. apurado original) / Atualiza o saldo do produto / Enquadra o Movimento (De acordo com mov. apurado original) / Define Valor de Confronto (De acordo com mov. apurado original) / Define Valor a Ressarcir ou Complementar (De acordo com mov. apurado original)---//
                //---                   Carrega os valores apurados no atributo oMovimApur---//
                oApuracao:ApuraMovim()

                //---Grava o movimento apurado (Tabela F2U)---//
                GravaF2U(oApuracao)

                cProduto := (cAlias)->FT_PRODUTO
                cPerSld  := (cAlias)->F2V_ANOMES
            EndIf

            (cAlias)->(DbSkip())
        EndDo
        (cAlias)->(DbCloseArea()) 
        //---FIM Query Principal---//

        AtualizaMsg(oSay,STR0007) //"Atualizando saldos..."

        //---Atualiza o saldo final do produto (Tabela F2V)---//
        GravaF2V('1',oApuracao,Iif(Empty(cPerSld),.T.,.F.),,oModel)

        //---Atualiza o saldo final dos produtos para os quais não houve movimento no período apurado (Tabela F2V)---//
        GravaF2V('2',,,cPerApur,oModel)
        
        AtualizaMsg(oSay,STR0008) //"Gravando apuração..."

        //---Grava totalizadores da apuração (Tabelas F2X e F2T)---//        
        GravaF2XT(oApuracao,2)

    //End Transaction

    oModel:Destroy()
    AtualizaMsg(oSay,STR0009) //"Processamento concluído."
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaF2V
  
Função que atualiza, na tabela F2V, o saldo final dos produtos no período analisado, além de transferir esse saldo final para o saldo inicial do próximo período.
É chamada em duas situações (parâmetro cTipo):

1-De dentro do laço da query de movimento (informando o parâmetro oApuracao): Deve, nesse caso, atualizar saldos do produto setado no objeto oApuracao com o resultado da apuração;
2-Após o laço da query de movimento (informando o parâmetro cPerApur).......: Deve, nesse caso, atualizar saldos dos produtos que não tiveram movimento no período atual, e, portanto, não entraram na query de movimento.

@author Ulisses P. Oliveira
@since 08/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaF2V(cTipo,oApuracao,lInsSldIni,cPerApur,oModel)
    Local aArea     := GetArea()
    Local cAlias    := GetNextAlias()
    Local cProxPer  := ''
    Local aDadosF2V := {}
    Local nCount    := 0
    Local nCount2   := 0
    Local nPos      := 0
    Local nPos2     := 0
    Local lF2VOk    := .T.

    If cTipo == '1'
        If lInsSldIni
            //---Caso não exista saldo inicial do produto no período analisado, cria registro com saldo inical 0 e atualiza o saldo final (tabela F2V)---//
            Aadd(aDadosF2V,{3,                                                ;
                            {{'F2V_ANOMES',oApuracao:GetAnoMes()            },;
                             {'F2V_PRODUT',oApuracao:oSaldoProd:GetCodProd()},;
                             {'F2V_QTDFIM',oApuracao:oSaldoProd:GetQtdade() },;
                             {'F2V_VUNFIM',oApuracao:oSaldoProd:GetVlrUnit()},;
                             {'F2V_VTOFIM',oApuracao:oSaldoProd:GetVlrTot() },;
                             {'F2V_TPREG' ,'3'                              }}})
        Else
            //---Atualiza o saldo final do produto no período analisado (tabela F2V)---//
            Aadd(aDadosF2V,{4,                                                ;
                            {{'F2V_ANOMES',oApuracao:GetAnoMes()            },;
                             {'F2V_PRODUT',oApuracao:oSaldoProd:GetCodProd()},;
                             {'F2V_QTDFIM',oApuracao:oSaldoProd:GetQtdade() },;
                             {'F2V_VUNFIM',oApuracao:oSaldoProd:GetVlrUnit()},;
                             {'F2V_VTOFIM',oApuracao:oSaldoProd:GetVlrTot() }}})
        EndIf

        //---Cria/Atualiza o saldo inicial do produto para o próximo período (tabela F2V)---//
        cProxPer := ProxPer(oApuracao:GetAnoMes())
        F2V->(DbSetOrder(1))
        If !F2V->(DbSeek(xFilial("F2V")+cProxPer+oApuracao:oSaldoProd:GetCodProd()))
            Aadd(aDadosF2V,{3,                                                ;
                            {{'F2V_ANOMES',cProxPer                         },;
                             {'F2V_PRODUT',oApuracao:oSaldoProd:GetCodProd()},;
                             {'F2V_QTDSLD',oApuracao:oSaldoProd:GetQtdade() },;
                             {'F2V_VUNSLD',oApuracao:oSaldoProd:GetVlrUnit()},;
                             {'F2V_VTOSLD',oApuracao:oSaldoProd:GetVlrTot() },;
                             {'F2V_TPREG' ,'3'                              }}})
        Else
            Aadd(aDadosF2V,{4,                                                ;
                            {{'F2V_ANOMES',cProxPer                         },;
                             {'F2V_PRODUT',oApuracao:oSaldoProd:GetCodProd()},;
                             {'F2V_QTDSLD',oApuracao:oSaldoProd:GetQtdade() },;
                             {'F2V_VUNSLD',oApuracao:oSaldoProd:GetVlrUnit()},;
                             {'F2V_VTOSLD',oApuracao:oSaldoProd:GetVlrTot() }}})
        EndIf
    Else
        BeginSql Alias cAlias
            SELECT F2V.F2V_PRODUT, F2V.F2V_QTDSLD, F2V.F2V_VUNSLD, F2V.F2V_VTOSLD
            FROM %Table:F2V% F2V LEFT OUTER JOIN (SELECT F2U.F2U_FILIAL, F2U.F2U_ANOMES, F2U.F2U_PRODUT, MAX(F2U.F2U_ORDEM) F2U_ORDEM
                                                  FROM %Table:F2U% F2U
                                                  WHERE F2U.F2U_FILIAL = %xFilial:F2U%  AND 
                                                        F2U.F2U_ANOMES = %Exp:cPerApur% AND
                                                        F2U_TPREG      = ' '            AND
                                                        F2U.%NotDel%
                                                  GROUP BY F2U.F2U_FILIAL, F2U.F2U_ANOMES, F2U.F2U_PRODUT) F2U_ ON (F2U_.F2U_FILIAL = %xFilial:F2U% AND F2U_.F2U_ANOMES = %Exp:cPerApur% AND F2U_.F2U_PRODUT = F2V.F2V_PRODUT)
            WHERE F2V.F2V_FILIAL = %xFilial:F2V%  AND 
                  F2V.F2V_ANOMES = %Exp:cPerApur% AND
            	  F2V.%NotDel%                    AND
            	  ISNULL(F2U_.F2U_ORDEM,'') = ''
        EndSql

        DbSelectArea(cAlias)
        While !(cAlias)->(Eof())

            //---Atualiza o saldo final do produto no período analisado (tabela F2V)---//
            Aadd(aDadosF2V,{4,                                   ;
                            {{'F2V_ANOMES',cPerApur            },;
                             {'F2V_PRODUT',(cAlias)->F2V_PRODUT},;
                             {'F2V_QTDFIM',(cAlias)->F2V_QTDSLD},;
                             {'F2V_VUNFIM',(cAlias)->F2V_VUNSLD},;
                             {'F2V_VTOFIM',(cAlias)->F2V_VTOSLD}}})

            //---Cria/Atualiza o saldo inicial do produto para o próximo período (tabela F2V)---//
            cProxPer := ProxPer(cPerApur)
            F2V->(DbSetOrder(1))
            If !F2V->(DbSeek(xFilial("F2V")+cProxPer+(cAlias)->F2V_PRODUT))
                Aadd(aDadosF2V,{3,                                   ;
                                {{'F2V_ANOMES',cProxPer            },;
                                 {'F2V_PRODUT',(cAlias)->F2V_PRODUT},;
                                 {'F2V_QTDSLD',(cAlias)->F2V_QTDSLD},;
                                 {'F2V_VUNSLD',(cAlias)->F2V_VUNSLD},;
                                 {'F2V_VTOSLD',(cAlias)->F2V_VTOSLD},;
                                 {'F2V_TPREG' ,'3'                 }}})
            Else
                Aadd(aDadosF2V,{4,                                   ;
                                {{'F2V_ANOMES',cProxPer            },;
                                 {'F2V_PRODUT',(cAlias)->F2V_PRODUT},;
                                 {'F2V_QTDSLD',(cAlias)->F2V_QTDSLD},;
                                 {'F2V_VUNSLD',(cAlias)->F2V_VUNSLD},;
                                 {'F2V_VTOSLD',(cAlias)->F2V_VTOSLD}}})
            EndIf
        
            (cAlias)->(DbSkip())
        EndDo
        (cAlias)->(DbCloseArea())
    EndIf

    //---Grava a tabela F2V---//
    For nCount := 1 To Len(aDadosF2V)
        lF2VOk := .T.
        If aDadosF2V[nCount][1] = 4
            nPos  := Ascan(aDadosF2V[nCount][2],{|a| a[1] == 'F2V_ANOMES'})
            nPos2 := Ascan(aDadosF2V[nCount][2],{|a| a[1] == 'F2V_PRODUT'})

            F2V->(DbSetOrder(1))
            If !F2V->(DbSeek(xFilial("F2V")+aDadosF2V[nCount][2][nPos][2]+aDadosF2V[nCount][2][nPos2][2]))
                lF2VOk := .F.
            EndIf
        EndIf

        If lF2VOk
            oModel:SetOperation(aDadosF2V[nCount][1])
            oModel:Activate()
            oModel:SetPre({||.T.})  //---Retirada da validação do Model para que a rotina de apuração possa atualizar registros tipo 3-Saldo da Apuração---//
            oModel:SetPost({||.T.}) //---Retirada da validação do Model para que a rotina de apuração possa atualizar registros tipo 3-Saldo da Apuração---//

            For nCount2 := 1 To Len(aDadosF2V[nCount][2])
                oModel:SetValue('FISA191',aDadosF2V[nCount][2][nCount2][1],aDadosF2V[nCount][2][nCount2][2])
            Next nCount2

            If oModel:VldData()
                oModel:CommitData()
            EndIf

            oModel:DeActivate()
        EndIf
    Next nCount
    //---FIM Grava a tabela F2V---//

    RestArea(aArea)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaF2U
  
Função que insere, na tabela F2U, os dados do movimento apurado.

@author Ulisses P. Oliveira
@since 08/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaF2U(oApuracao)

    RecLock('F2U',.T.)
    F2U->F2U_FILIAL := xFilial("F2U")
    F2U->F2U_IDAPUR := oApuracao:GetIdApur()
    F2U->F2U_ANOMES := oApuracao:GetAnoMes()

    //---Dados do Movimento---//
    F2U->F2U_PRODUT := oApuracao:oMovimento:GetCodProd()
    F2U->F2U_ORDEM  := StrZero(oApuracao:oSaldoProd:GetOrdMov(),9)
    F2U->F2U_DTMOV  := oApuracao:oMovimento:GetDataMov()
    F2U->F2U_CHVDOC := oApuracao:oMovimento:GetChvDoc()
    F2U->F2U_SERECF := oApuracao:oMovimento:GetNSerECF()
    F2U->F2U_TPMOV  := oApuracao:oMovimento:GetTipoMov()
    F2U->F2U_SERIE  := oApuracao:oMovimento:GetSerDoc()
    F2U->F2U_NFISCA := oApuracao:oMovimento:GetNumDoc()
    F2U->F2U_PARTIC := Left(oApuracao:oMovimento:GetCodPart(),TamSx3("A1_COD")[1])
    F2U->F2U_LOJA   := Right(oApuracao:oMovimento:GetCodPart(),TamSx3("A1_LOJA")[1])
    F2U->F2U_CFOP   := oApuracao:oMovimento:GetCFOP()
    F2U->F2U_ITEM   := oApuracao:oMovimento:GetItemDoc()
    F2U->F2U_TIPO   := oApuracao:oMovimento:GetTipoDoc()
    F2U->F2U_ESPECI := oApuracao:oMovimento:GetEspDoc()

    //---Valores apurados para o movimento---//
    F2U->F2U_QTDMOV := oApuracao:oMovimApur:GetQtdade()
    F2U->F2U_VUISUP := oApuracao:oMovimApur:GetSupUni()
    F2U->F2U_VTISUP := oApuracao:oMovimApur:GetSupTot()
    F2U->F2U_ENQLEG := oApuracao:oMovimApur:GetEnquad()
    F2U->F2U_ICMEFS := oApuracao:oMovimApur:GetConfSai()
    F2U->F2U_ICMEFE := oApuracao:oMovimApur:GetConfEnt()
    F2U->F2U_QTDSLD := oApuracao:oMovimApur:GetSldQtd()
    F2U->F2U_VUNSLD := oApuracao:oMovimApur:GetSldUni()
    F2U->F2U_VTOSLD := oApuracao:oMovimApur:GetSldTot()
    F2U->F2U_VRESSA := oApuracao:oMovimApur:GetApurRes()
    F2U->F2U_VCOMPL := oApuracao:oMovimApur:GetApurCom()
    F2U->F2U_VCREDI := oApuracao:oMovimApur:GetApurCop()

    //---Outros Valores---//
    F2U->F2U_ALIQIC := oApuracao:oMovimento:GetAliqInt()
    F2U->F2U_TPREG  := ' '

	F2U->(MsUnlock())

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaF2XT
  
Função que grava, nas tabelas F2X e F2T, os totalizadores da apuração.

@author Ulisses P. Oliveira
@since 16/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaF2XT(oApuracao,cTipoGrv)
    Local nVlrTotRes := 0
    Local nVlrTotCom := 0
    Local nVlrTotCop := 0
    Local nCount     := 0

    If cTipoGrv = 1     //--- Parâmetro cTipoGrv = 1 -> Chamada no início do processamento. Insere registro na tabala F2X ---//
        RecLock('F2X',.T.)
        F2X->F2X_FILIAL := xFilial("F2X")
        F2X->F2X_IDAPUR := oApuracao:GetIdApur()
        F2X->F2X_ANOMES := oApuracao:GetAnoMes()
        F2X->(MsUnlock())
    ElseIf cTipoGrv = 2 //--- Parâmetro cTipoGrv = 2 -> Chamada ao fim do processamento. Insere registros na tabala F2T e atualiza totais da tabela F2X ---//
        For nCount := 1 To Len(oApuracao:aTotApur)
            If oApuracao:aTotApur[nCount][1] != '0'
                RecLock('F2T',.T.)
                F2T->F2T_FILIAL := xFilial("F2T")
                F2T->F2T_IDAPUR := oApuracao:GetIdApur()
                F2T->F2T_ANOMES := oApuracao:GetAnoMes()
                F2T->F2T_ENQLEG := oApuracao:aTotApur[nCount][1]
                F2T->F2T_VRESSA := oApuracao:aTotApur[nCount][2]
                F2T->F2T_VCOMPL := oApuracao:aTotApur[nCount][3]
                F2T->F2T_VCREDI := oApuracao:aTotApur[nCount][4]
                F2T->(MsUnlock())

                nVlrTotRes += oApuracao:aTotApur[nCount][2]
                nVlrTotCom += oApuracao:aTotApur[nCount][3]
                nVlrTotCop += oApuracao:aTotApur[nCount][4]
            EndIf
        Next nCount

        F2X->(DbSetOrder(2))
        If F2X->(DbSeek(xFilial("F2X")+oApuracao:GetIdApur()))
            RecLock('F2X',.F.)
                F2X->F2X_VRESSA := nVlrTotRes
                F2X->F2X_VCOMPL := nVlrTotCom
                F2X->F2X_VCREDI := nVlrTotCop
            MsUnLock()
        EndIf
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckApur
  
Função que verifica a existência de apuração no período selecionado.

@author Ulisses P. Oliveira
@since 22/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function CheckApur(cPerApur)
    Local cIdApur := ''

    F2X->(DbSetOrder(1))
    If F2X->(DbSeek(xFilial("F2X")+cPerApur))
        cIdApur := F2X->F2X_IDAPUR
    EndIf

Return cIdApur


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DeletApur
  
Função de exclusão da apuração.

@author Ulisses P. Oliveira
@since 22/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function DeletApur(cIdApur,cPerApur)
    Local cQuery     := ''
    Local cProxPer   := ''
    Local cIdApuProx := ''

    //---Tabela F2X [Apuração]---//
    F2X->(DbSetOrder(2))
    If F2X->(DbSeek(xFilial("F2X")+cIdApur))
		RecLock('F2X',.F.)
		    F2X->(DbDelete())
		MsUnLock()
    EndIf

    //---Tabela F2T [Apuração por Enquadramento Legal]---//
    F2T->(DbSetOrder(2))
    F2T->(DbSeek(xFilial("F2T")+cIdApur))
    While !F2T->(Eof()) .And. F2T->F2T_IDAPUR == cIdApur
		RecLock('F2T',.F.)
		    F2T->(DbDelete())
		MsUnLock()
        F2T->(DbSkip())
    EndDo

    //---Tabela F2V [Saldos Iniciais]---//
    cQuery := "UPDATE " +  RetSqlName('F2V') + " SET F2V_QTDFIM = 0, F2V_VUNFIM = 0, F2V_VTOFIM = 0 WHERE F2V_FILIAL = " + ValToSql(xFilial('F2V')) + " AND F2V_ANOMES = " + ValToSql(cPerApur)
    If !Empty(AllTrim(cQuery))
        TcSqlExec(cQuery)
    EndIf

    cProxPer := cPerApur
    cProxPer := LastDay(CtoD('01/'+Right(cProxPer,2)+'/'+Left(cProxPer,4)))+1
    cProxPer := Left(DToS(cProxPer),6)

    //---Verifica a existência de apuração no próximo período. Caso exista, não exclui registro da F2V---//
    cIdApuProx := CheckApur(cProxPer)
    If Empty(cIdApuProx)
        F2V->(DbSetOrder(1))
        F2V->(DbSeek(xFilial("F2V")+cProxPer))
        While !F2V->(Eof()) .And. F2V->F2V_ANOMES == cProxPer
            RecLock('F2V',.F.)
                F2V->(DbDelete())
            MsUnLock()
            F2V->(DbSkip())
        EndDo
    EndIf

    //---Tabela F2U [Apuração Detalhada por Movimento]---//
    cQuery := "DELETE FROM " +  RetSqlName('F2U')  + " WHERE F2U_FILIAL = " + ValToSql(xFilial('F2U')) + " AND F2U_IDAPUR = " + ValToSql(cIdApur)
    If !Empty(AllTrim(cQuery))
        TcSqlExec(cQuery)
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PesqApur
  
Função que pesquisa, no movimento já apurado (tabela F2U), o movimento de saída original, em casos de devoluções de saídas.
Retorna um vetor contendo os seguintes valores:

[1]-Quantidade do movimento original
[2]-Valor unitário do ICMS suportado no movimento original
[3]-Código do Enquadramento Legal do movimento original
[4]-Valor do ICMS Efeitivo na Saída do movimento original
[5]-Valor do ICMS Efeitivo na Entrada do movimento original
[6]-Valor do Ressarcimento do movimento original
[7]-Valor do Complemento do movimento original
[8]-Valor do Crédito da Operação Própria
[9]-Valor total do ICMS suportado no movimento original

@author Ulisses P. Oliveira
@since 03/12/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function PesqApur(cTipoMov, cDocOri, cSerOri, cItemOri, cCliOri, cLojaOri, cProdOri, aCodRes)
    Local aArea    := GetArea()
    Local cAlias   := GetNextAlias()
    Local lApurAnt := .F.
    Local nPos     := 0
    Local nVlrRes  := 0
    Local nVlrCred := 0
    Local nQtdade  := 0
    Local aRetorno := {0,0,'',0,0,0,0,0,0}

    cTipoMov := Iif(cTipoMov == 'E','S','E')

    //--Localiza saída original apurada na tabela F2U, para utilizar os valores informados anteriormente---//
    BeginSql Alias cAlias
        SELECT F2U_QTDMOV, F2U_VUISUP, F2U_VTISUP, F2U_ENQLEG, F2U_ICMEFS, F2U_ICMEFE, F2U_VRESSA, F2U_VCOMPL, F2U_VCREDI
        FROM  %TABLE:F2U% F2U
        WHERE F2U.F2U_FILIAL = %XFILIAL:F2U%  AND 
              F2U.F2U_TPMOV  = %EXP:cTipoMov% AND
        	  F2U.F2U_SERIE  = %EXP:cSerOri%  AND
        	  F2U.F2U_NFISCA = %EXP:cDocOri%  AND
        	  F2U.F2U_PARTIC = %EXP:cCliOri%  AND
        	  F2U.F2U_LOJA   = %EXP:cLojaOri% AND
        	  F2U.F2U_ITEM   = %EXP:cItemOri% AND
        	  F2U.F2U_PRODUT = %EXP:cProdOri% AND
        	  F2U.%NOTDEL%	
    EndSql

    DbSelectArea(cAlias)
    If !(cAlias)->(Eof())
        aRetorno := {(cAlias)->F2U_QTDMOV, (cAlias)->F2U_VUISUP, (cAlias)->F2U_ENQLEG, (cAlias)->F2U_ICMEFS, (cAlias)->F2U_ICMEFE, (cAlias)->F2U_VRESSA, (cAlias)->F2U_VCOMPL, (cAlias)->F2U_VCREDI, (cAlias)->F2U_VTISUP}
        lApurAnt := .T.
    EndIf
    (cAlias)->(DbCloseArea())

    //---Caso não encontre saída original apurada na tabela F2U, tenta localizar valor ressarcido através da tabela CDA, gerado via portaria CAT158---//
    If !lApurAnt .And. cTipoMov == 'S'

        BeginSql Alias cAlias
            SELECT SFT.FT_QUANT, CDA.CDA_CODLAN, CDA_VALOR
            FROM %Table:SFT% SFT INNER JOIN %Table:CDA% CDA ON (CDA_FILIAL = %xFilial:CDA% AND CDA_TPMOVI = SFT.FT_TIPOMOV AND CDA_ESPECI = SFT.FT_ESPECIE AND CDA_NUMERO = SFT.FT_NFISCAL AND CDA_SERIE = SFT.FT_SERIE AND CDA_CLIFOR = SFT.FT_CLIEFOR AND CDA_LOJA = SFT.FT_LOJA AND CDA_NUMITE = SFT.FT_ITEM AND CDA.%NotDel%)
            WHERE SFT.FT_FILIAL  = %xFilial:SFT%  AND
                  SFT.FT_TIPOMOV = 'S'            AND
            	  SFT.FT_SERIE   = %Exp:cSerOri%  AND
            	  SFT.FT_NFISCAL = %Exp:cDocOri%  AND
            	  SFT.FT_CLIEFOR = %Exp:cCliOri%  AND
             	  SFT.FT_LOJA    = %Exp:cLojaOri% AND
            	  SFT.FT_ITEM    = %Exp:cItemOri% AND
            	  SFT.FT_PRODUTO = %Exp:cProdOri% AND
            	  SFT.%NotDel%
        EndSql

        DbSelectArea(cAlias)
        While !(cAlias)->(Eof())
            nPos := Ascan(aCodRes,AllTrim((cAlias)->CDA_CODLAN))
            If nPos = 1
                nVlrRes  += (cAlias)->CDA_VALOR
            ElseIf nPos = 2
                nVlrCred += (cAlias)->CDA_VALOR
            EndIf
            nQtdade := (cAlias)->FT_QUANT
            (cAlias)->(DbSkip())
        EndDo
        (cAlias)->(DbCloseArea())
        aRetorno := {nQtdade,0,'',0,0,nVlrRes,0,nVlrCred,0}

    EndIf

    RestArea(aArea)
Return aRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProxPer
Função que calcula o próximo período

@author Ulisses P. Oliveira
@since 27/12/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ProxPer(cPerApur)
    Local cProxPer := ''

    cProxPer := LastDay(CtoD('01/'+Right(cPerApur,2)+'/'+Left(cPerApur,4)))+1
    cProxPer := Left(DToS(cProxPer),6)
Return cProxPer


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaMsg

Função que será chamada para atualizar descrição da barra de status

@author Ulisses P. Oliveira
@since 22/11/2018
@version 12.1.17
/*/
//--------------------------------------------------------------------------------------------------
Static Function AtualizaMsg(oSay,cMsg)
    If !lAutomato
        oSay:cCaption := (cMsg)
        ProcessMessages()
    EndIf
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA192EXC
Função de exclusão da apuração selecionada, a partir da rotina FISA193.

@author Ulisses P. Oliveira
@since 22/11/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA192EXC()
    FWExecView(STR0010,"FISA193",MODEL_OPERATION_DELETE,,{|| DeletApur(F2X->F2X_IDAPUR,F2X->F2X_ANOMES) },,,) //"Exclusão"
Return