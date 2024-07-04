Create Procedure CTB151_##(
   @IN_FILIAL     Char( 'CT7_FILIAL' ),
   @IN_CONTADANT  Char( 'CT7_CONTA' ),
   @IN_CONTAD     Char( 'CT7_CONTA' ),
   @IN_CONTACANT  Char( 'CT7_CONTA' ),
   @IN_CONTAC     Char( 'CT7_CONTA' ),
   @IN_CUSTODANT  Char( 'CT3_CUSTO' ),
   @IN_CUSTOD     Char( 'CT3_CUSTO' ),
   @IN_CUSTOCANT  Char( 'CT3_CUSTO' ),
   @IN_CUSTOC     Char( 'CT3_CUSTO' ),
   @IN_ITEMDANT   Char( 'CT4_ITEM' ),
   @IN_ITEMD      Char( 'CT4_ITEM' ),
   @IN_ITEMCANT   Char( 'CT4_ITEM' ),
   @IN_ITEMC      Char( 'CT4_ITEM' ),
   @IN_CLVLDANT   Char( 'CTI_CLVL' ),
   @IN_CLVLD      Char( 'CTI_CLVL' ),
   @IN_CLVLCANT   Char( 'CTI_CLVL' ),
   @IN_CLVLC      Char( 'CTI_CLVL' ),
   @IN_MOEDA      Char( 'CT7_MOEDA' ),
   @IN_DCA        Char( 'CT2_DC' ),
   @IN_DC         Char( 'CT2_DC' ),
   @IN_DATA       Char( 08 ),
   @IN_TPSALDOA   Char( 'CT7_TPSALD' ),
   @IN_TPSALDO    Char( 'CT7_TPSALD' ),
   @IN_OPERACAO   Char( 01 ),
   @IN_MVSOMA     Char( 01 ),
   @IN_LOTE       Char( 'CT2_LOTE' ),
   @IN_SBLOTE     Char( 'CT2_SBLOTE' ),
   @IN_DOC        Char( 'CT2_DOC' ),
   @IN_DTLP       Char( 08 ),
   @IN_VALORANT   Float,
   @IN_VALOR      Float,
   @OUT_RESULT    Char( 01) OutPut

)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA102.PRW </s>
    Descricao       - <d>  Faz a chamada da operacao ( Inclusao/Alteracao/Exclusao) </d>
    Funcao do Siga  -      CTB102Proc()
    Entrada         - <ri> @IN_FILIAL       - Filial corrente da manutencao do arquivo de lanctos
                           @IN_CONTADANT    - Conta Anterior a Débito
                           @IN_CONTAD       - Conta a Débito
                           @IN_CONTACANT    - Conta Anterior a Crébito
                           @IN_CONTAC       - Conta Crébito
                           @IN_CUSTODANT    - CCusto Anterior a Débito
                           @IN_CUSTOD       - CCusto a Débito
                           @IN_CUSTOCANT    - CCusto Anterior a Crébito
                           @IN_CUSTOC       - CCusto Crébito
                           @IN_ITEMDANT     - Item Anterior a Débito
                           @IN_ITEMD        - Item Débito
                           @IN_ITEMCANT     - Item Anterior a Crébito
                           @IN_ITEMC        - Item Crébito
                           @IN_CLVLDANT     - ClVl Anterior a Débito
                           @IN_CLVLD        - ClVl Débito
                           @IN_CLVLCANT     - ClVl Anterior a Crébito
                           @IN_CLVLC        - ClVl Crébito
                           @IN_MOEDA        - Moeda do Lancto
                           @IN_DCA          - Natureza Anterior do Lancto (1-Débito, 2-Crédito, 3-Partida Dobrada)
                           @IN_DC           - Natureza do Lancto (1-Débito, 2-Crédito, 3-Partida Dobrada)
                           @IN_DATA         - Data do Lancto
                           @IN_TPSALDOA     - Tipo de Saldo Anterior
                           @IN_TPSALDO      - Tipo de Saldo
                           @IN_OPERACAO     - Operacao
                           @IN_MVSOMA       - Se 1, soma uma vez, se 2 dua vezes
                           @IN_LOTE         - Nro Lote do Lancto
                           @IN_SBLOTE       - Nro do SubLote 
                           @IN_DOC          - Nro do Documento
                           @IN_DTLP         - Data do Lancto
                           @IN_VALORANT     - Valor Anterior
                           @IN_VALOR        - Valor Atual
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     20/05/2005
-------------------------------------------------------------------------------------- */
declare @cResult Char( 01 )

begin
   
   select @OUT_RESULT = '0'
   select @cResult = '0'
   
   /*--------------------------
      Inclusao de Lanctos
     -------------------------- */   
   If @IN_OPERACAO = '3' begin
      Exec CTB154_## @IN_FILIAL, @IN_CONTAD, @IN_CONTAC, @IN_CUSTOD, @IN_CUSTOC, @IN_ITEMD,   @IN_ITEMC,
                     @IN_CLVLD,  @IN_CLVLC,  @IN_MOEDA,  @IN_DC,     @IN_DATA,   @IN_TPSALDO, @IN_DTLP,
                     @IN_MVSOMA, @IN_LOTE,   @IN_SBLOTE, @IN_DOC,    @IN_VALOR,  @cResult OutPut
   End
   /*--------------------------
      Alteracao de Lanctos
     -------------------------- */   
   If @IN_OPERACAO = '4' begin
      
      Exec CTB155_## @IN_FILIAL,    @IN_CONTADANT, @IN_CONTAD,   @IN_CONTACANT, @IN_CONTAC,   @IN_CUSTODANT, @IN_CUSTOD,
                     @IN_CUSTOCANT, @IN_CUSTOC,    @IN_ITEMDANT, @IN_ITEMD,     @IN_ITEMCANT, @IN_ITEMC,     @IN_CLVLDANT,
                     @IN_CLVLD,     @IN_CLVLCANT,  @IN_CLVLC,    @IN_MOEDA,     @IN_DCA,      @IN_DC,        @IN_DATA,
                     @IN_TPSALDOA,  @IN_TPSALDO,   @IN_OPERACAO, @IN_MVSOMA,    @IN_LOTE,     @IN_SBLOTE,    @IN_DOC,
                     @IN_DTLP,      @IN_VALORANT,  @IN_VALOR,    @cResult OutPut
   End
   /*--------------------------
      Exclusao de Lanctos
     -------------------------- */   
   If @IN_OPERACAO = '5' begin
      Exec CTB152_## @IN_FILIAL,   @IN_CONTADANT, @IN_CONTACANT, @IN_CUSTODANT, @IN_CUSTOCANT, @IN_ITEMDANT,
                     @IN_ITEMCANT, @IN_CLVLDANT,  @IN_CLVLCANT,  @IN_MOEDA,     @IN_DCA,       @IN_DATA,
                     @IN_TPSALDOA, @IN_DTLP,      @IN_MVSOMA,    @IN_LOTE,      @IN_SBLOTE,    @IN_DOC,
                     @IN_VALORANT, @cResult OutPut
   End
   select @OUT_RESULT = @cResult   
End
