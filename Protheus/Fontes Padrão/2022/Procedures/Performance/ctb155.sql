Create Procedure CTB155_##(
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
    Vers�o          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA102.PRW </s>
    Descricao       - <d>  Faz a chamada da operacao ALTERACAO </d>
    Funcao do Siga  -      CTB102Proc()
    Entrada         - <ri> @IN_FILIAL       - Filial corrente da manutencao do arquivo de lanctos
                           @IN_CONTADANT    - Conta Anterior a D�bito
                           @IN_CONTAD       - Conta a D�bito
                           @IN_CONTACANT    - Conta Anterior a Cr�bito
                           @IN_CONTAC       - Conta Cr�bito
                           @IN_CUSTODANT    - CCusto Anterior a D�bito
                           @IN_CUSTOD       - CCusto a D�bito
                           @IN_CUSTOCANT    - CCusto Anterior a Cr�bito
                           @IN_CUSTOC       - CCusto Cr�bito
                           @IN_ITEMDANT     - Item Anterior a D�bito
                           @IN_ITEMD        - Item D�bito
                           @IN_ITEMCANT     - Item Anterior a Cr�bito
                           @IN_ITEMC        - Item Cr�bito
                           @IN_CLVLDANT     - ClVl Anterior a D�bito
                           @IN_CLVLD        - ClVl D�bito
                           @IN_CLVLCANT     - ClVl Anterior a Cr�bito
                           @IN_CLVLC        - ClVl Cr�bito
                           @IN_MOEDA        - Moeda do Lancto
                           @IN_DCA          - Natureza Anterior do Lancto (1-D�bito, 2-Cr�dito, 3-Partida Dobrada)
                           @IN_DC           - Natureza do Lancto (1-D�bito, 2-Cr�dito, 3-Partida Dobrada)
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
    Data        :     29/09/2005
-------------------------------------------------------------------------------------- */
declare @cResult     Char(01)

begin
   select @cResult = '0'
   
   If ( @IN_DCA ='1' or @IN_DCA ='3') and  @IN_CONTADANT <> ' ' begin
      EXEC  CTB159_##  @IN_FILIAL,   @IN_CONTADANT, @IN_CUSTODANT, @IN_ITEMDANT, @IN_CLVLDANT, @IN_MOEDA,  @IN_DCA,
                       @IN_DATA,     @IN_TPSALDOA,  @IN_DTLP,      @IN_MVSOMA,   @IN_LOTE,     @IN_SBLOTE, @IN_DOC,
                       @IN_VALORANT, @cResult OutPut
   end
   If ( @IN_DCA ='2' or @IN_DCA ='3') and  @IN_CONTACANT <> ' ' begin
      EXEC  CTB160_##  @IN_FILIAL,   @IN_CONTACANT, @IN_CUSTOCANT, @IN_ITEMCANT, @IN_CLVLCANT, @IN_MOEDA,  @IN_DC,
                       @IN_DATA,     @IN_TPSALDOA,  @IN_DTLP,      @IN_MVSOMA,   @IN_LOTE,     @IN_SBLOTE, @IN_DOC,
                       @IN_VALORANT, @cResult OutPut
   end
   If ( @IN_DC ='1' or @IN_DC ='3' ) and @IN_CONTAD <> ' ' begin
      Exec CTB157_## @IN_FILIAL, @IN_CONTAD,  @IN_CUSTOD, @IN_ITEMD,  @IN_CLVLD, @IN_MOEDA,  @IN_DC,
                     @IN_DATA,   @IN_TPSALDO, @IN_DTLP,   @IN_MVSOMA, @IN_LOTE,  @IN_SBLOTE, @IN_DOC,
                     @IN_VALOR,  @cResult OutPut
   end
   If ( @IN_DC ='2' or @IN_DC ='3' ) and @IN_CONTAC <> ' ' begin
      Exec CTB158_## @IN_FILIAL, @IN_CONTAC,  @IN_CUSTOC, @IN_ITEMC,  @IN_CLVLC, @IN_MOEDA,  @IN_DC,
                     @IN_DATA,   @IN_TPSALDO, @IN_DTLP,   @IN_MVSOMA, @IN_LOTE,  @IN_SBLOTE, @IN_DOC,
                     @IN_VALOR, @cResult OutPut
   end
   select @OUT_RESULT = @cResult
End

