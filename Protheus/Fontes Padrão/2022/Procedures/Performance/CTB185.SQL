Create Procedure CTB185_##(
   @IN_FILIAL    Char( 'CT2_FILIAL' ),
   @IN_DATA      Char( 08 ),
   @IN_LOTE      Char( 'CT2_LOTE' ),
   @IN_SBLOTE    Char( 'CT2_SBLOTE' ),
   @IN_DOC       Char( 'CT2_DOC' ),
   @IN_OPC       Char( 01 ),
   @IN_ATIVDE    Char( 'CT2_ATIVDE' ),   
   @IN_INTEGRID  Char( 01 ),
   @IN_MVSOMA    Char( 01 ),
   @OUT_RESULT   Char( 01 ) OutPut
)

as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  010 </a>
    Fonte Microsiga - <s>  ctbxatu.prx </s>
    Descricao       - <d>  Atualizar Saldos do Lote ## </d>
    Funcao do Siga  -      ctbxfun
    Entrada         - <ri> @IN_FILIAL   - Filial onde a manutencao sera feita
                           @IN_DATA     - Data do Lote
                           @IN_LOTE     - Nro do Lote a ser alterado ou excluido
                           @IN_SBLOTE   - Nro do Sublote a ser alterado ou excluido
                           @IN_DOC      - Nro do Documento a ser alterado ou excluido
                           @IN_OPC      - 3 - Incluir, 4- alterar, 5 - Exclusao
                           @IN_ATIVDEB  - Identifica os lancamentos a serem atualizados na INCLUSÃO
                           @IN_INTEGRID - '1' Integridade referencial ligada, '0' desligada
                           @IN_MVSOMA   -  '1' soma uma vez ,'2' soma duas vezes na atualização do CTC
    Saida           - <o>  @OUT_RESULT  - Indica o termino OK da procedure </ro>
    Data        :     19/10/2009
   
   1.CTB185 - Chama o processo de atualizacao de Saldos
      2. CTB187 - Exclusão de Saldos
            3. CTB189 - Efetiva a atualizacao dos saldos na CQ0/CQ1, CQ2/CQ3, CQ4/CQ5, CQ6/CQ7, CQ8/CQ9
                  4. CTB180 - Atualização de Saldos do CQ0/CQ1
                  4. CTB181 - Atualização de Saldos do CQ2/CQ3, CQ8/CQ9
                  4. CTB182 - Atualização de Saldos do CQ4/CQ5, CQ8/CQ9
                  4. CTB183 - Atualização de Saldos do CQ6/CQ7, CQ8/CQ9
            3. CTB233 - Atualiza CTC 
            3. CTB156 - ATUALIZACAO DE CUBOS - SE ATIVO
                  4. CTB200 - Atualizacao do CUBO 01 - PLANO CONTAS
                  4. CTB201 - Atualizacao do CUBO 02 - CENTRO DE CUSTO
                  4. CTB202 - Atualizacao do CUBO 03 - ITEM 
                  4. CTB203 - Atualizacao do CUBO 04 - CLASSE DE VALOR
                  4. CTB204 - Atualizacao do CUBO 05 - ENTIDADE NIV05
                  4. CTB205 - Atualizacao do CUBO 06 - ENTIDADE NIV06
                  4. CTB206 - Atualizacao do CUBO 07 - ENTIDADE NIV07
                  4. CTB207 - Atualizacao do CUBO 08 - ENTIDADE NIV08
                  4. CTB208 - Atualizacao do CUBO 09 - ENTIDADE NIV09
      2. CTB188 - ALteracao Saldos
            3. CTB189 - Efetiva a atualizacao dos saldos na CT7, CT3, CT4, CTI
                  4. CTB180 - Atualização de Saldos do CT7
                  4. CTB181 - Atualização de Saldos do CT3
                  4. CTB182 - Atualização de Saldos do CT4
                  4. CTB183 - Atualização de Saldos do CTI
            3. CTB233 - Atualiza CTC
      2. CTB190 - INCLUSÃO de Saldos
            3. CTB189 - Efetiva a atualizacao dos saldos na CT7, CT3, CT4, CTI
                  4. CTB180 - Atualização de Saldos do CT7
                  4. CTB181 - Atualização de Saldos do CT3
                  4. CTB182 - Atualização de Saldos do CT4
                  4. CTB183 - Atualização de Saldos do CTI
            3. CTB233 - Atualiza CTC
Obs: TRW criado na instalacao de procedures
      Na ALTERAÇÃO e/ou EXCLUSÃO a tabela TRW é populada pela procedure CTB153
      Na inclusão, o TRW e populado via ADVPL. O identificador, CT2_ATIVDEB, que contém o codigo da conexao, determina os documentos
      a serem atualizados na INCLUSÃO.
---------------------------------------------------------------------------------------------------------------------------- */
declare @cResult     Char( 01 )

begin
   Select @OUT_RESULT = '0'
   Select @cResult    = '0'
   /*---------------------------------------------------------------
     Exclusao de Lote/doc
     --------------------------------------------------------------- */
   If @IN_OPC = '5' begin
      Exec CTB187_## @IN_FILIAL, @IN_DATA, @IN_LOTE, @IN_SBLOTE, @IN_DOC, @IN_INTEGRID, @IN_MVSOMA, @cResult OutPut
   End
   /*---------------------------------------------------------------
     Alteracao de Lote/Doc
     --------------------------------------------------------------- */
   If @IN_OPC = '4' begin
      Exec CTB188_## @IN_FILIAL, @IN_DATA, @IN_LOTE, @IN_SBLOTE, @IN_DOC, @IN_INTEGRID, @IN_MVSOMA, @cResult OutPut
   End
   /*---------------------------------------------------------------
     Inclusaoo de Lote/Doc
     --------------------------------------------------------------- */
   If @IN_OPC = '3' begin
      Exec CTB190_## @IN_FILIAL, @IN_DATA, @IN_LOTE, @IN_SBLOTE, @IN_DOC, @IN_ATIVDE, @IN_INTEGRID, @IN_MVSOMA, @cResult OutPut
   End
   /*---------------------------------------------------------------
     Inclusao de Lote
     --------------------------------------------------------------- */
   Select @OUT_RESULT = '1'
End
