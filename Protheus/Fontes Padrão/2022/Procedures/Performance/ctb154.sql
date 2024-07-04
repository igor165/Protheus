Create Procedure CTB154_##(
   @IN_FILIAL     Char( 'CT7_FILIAL' ),
   @IN_CONTAD     Char( 'CT7_CONTA' ),
   @IN_CONTAC     Char( 'CT7_CONTA' ),
   @IN_CUSTOD     Char( 'CT3_CUSTO' ),
   @IN_CUSTOC     Char( 'CT3_CUSTO' ),
   @IN_ITEMD      Char( 'CT4_ITEM' ),
   @IN_ITEMC      Char( 'CT4_ITEM' ),
   @IN_CLVLD      Char( 'CTI_CLVL' ),
   @IN_CLVLC      Char( 'CTI_CLVL' ),
   @IN_MOEDA      Char( 'CT7_MOEDA' ),
   @IN_DC         Char( 'CT2_DC' ),
   @IN_DATA       Char( 08 ),
   @IN_TPSALDO    Char( 'CT7_TPSALD' ),
   @IN_DTLP       Char( 08 ),
   @IN_MVSOMA     Char( 01 ),
   @IN_LOTE       Char( 'CT2_LOTE' ),
   @IN_SBLOTE     Char( 'CT2_SBLOTE' ),
   @IN_DOC        Char( 'CT2_DOC' ),
   @IN_VALOR      Float,
   @OUT_RESULT    Char( 01) OutPut

)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA102.PRW </s>
    Descricao       - <d>  Faz a chamada da operacao de INCLUSAO </d>
    Funcao do Siga  -      CTB102Proc()
    Entrada         - <ri> @IN_FILIAL       - Filial corrente da manutencao do arquivo de lanctos
                           @IN_CONTAD       - Conta a Débito
                           @IN_CONTAC       - Conta Crébito
                           @IN_CUSTOD       - CCusto a Débito
                           @IN_CUSTOC       - CCusto Crébito
                           @IN_ITEMD        - Item Débito
                           @IN_ITEMC        - Item Crébito
                           @IN_CLVLD        - ClVl Débito
                           @IN_CLVLC        - ClVl Crébito
                           @IN_MOEDA        - Moeda do Lancto
                           @IN_DC           - Natureza do Lancto (1-Débito, 2-Crédito, 3-Partida Dobrada)
                           @IN_DATA         - Data do Lancto
                           @IN_TPSALDO      - Tipo de Saldo
                           @IN_DTLP         - Data de Apuracao de Lp
                           @IN_MVSOMA       - Se 1, soma uma vez, se 2 dua vezes
                           @IN_LOTE         - Nro Lote do Lancto
                           @IN_SBLOTE       - Nro do SubLote 
                           @IN_DOC          - Nro do Documento
                           @IN_VALOR        - Valor Atual
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     29/09/2005
    
-------------------------------------------------------------------------------------- */
declare @cEntidadeD  Varchar( 200 )
declare @cEntidadeC  Varchar( 200 )
declare @cResult     Char( 01 )
Declare @cDc         Char( 'CT2_DC' )
declare @iRecno      integer
declare @iRecnoOut   integer
declare @cExecC      Char( 01 )
declare @cExecD      Char( 01 )

begin
   
   select @iRecno = 0
   select @iRecnoOut = 0
   select @cResult = '0'
   select @cEntidadeD = @IN_CONTAD || @IN_CUSTOD || @IN_ITEMD || @IN_CLVLD
   select @cEntidadeC = @IN_CONTAC || @IN_CUSTOC || @IN_ITEMC || @IN_CLVLC
   select @cExecC   = '1'
   select @cExecD   = '1'
   If @IN_DC = '1' or @IN_CONTAC = ' ' begin
      select @cExecC = '0'
   End
   If @IN_DC = '2' or @IN_CONTAD = ' ' begin
      select @cExecD = '0'
   End   
   select @cDc = @IN_DC
   /* ---------------------------------------------------------------------
      Executa a Menor entidade primeiro
      --------------------------------------------------------------------- */
   If @cEntidadeD < @cEntidadeC begin
      If @cExecD = '1' begin
         select @cDc = '1'
         Exec CTB157_## @IN_FILIAL, @IN_CONTAD, @IN_CUSTOD, @IN_ITEMD,  @IN_CLVLD, @IN_MOEDA, @cDc, @IN_DATA, @IN_TPSALDO,
                        @IN_DTLP,   @IN_MVSOMA, @IN_LOTE,   @IN_SBLOTE, @IN_DOC,   @IN_VALOR, @cResult OutPut
      End
      If @cExecC = '1' begin
         If @IN_DC = '3' select @cDc = '3'
         Exec CTB158_## @IN_FILIAL, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC,  @IN_CLVLC, @IN_MOEDA, @cDc, @IN_DATA, @IN_TPSALDO,
                           @IN_DTLP,   @IN_MVSOMA, @IN_LOTE,   @IN_SBLOTE, @IN_DOC,   @IN_VALOR, @cResult OutPut
      End
   end else begin
      If @cExecC = '1' begin
         select @cDc = '1'
         Exec CTB158_## @IN_FILIAL, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC,  @IN_CLVLC, @IN_MOEDA, @cDc, @IN_DATA, @IN_TPSALDO,
                        @IN_DTLP,   @IN_MVSOMA, @IN_LOTE,   @IN_SBLOTE, @IN_DOC,   @IN_VALOR, @cResult OutPut
      End
      If @cExecD = '1' begin
         If @IN_DC = '3' select @cDc = '3'
         Exec CTB157_## @IN_FILIAL, @IN_CONTAD, @IN_CUSTOD, @IN_ITEMD,  @IN_CLVLD, @IN_MOEDA, @cDc, @IN_DATA, @IN_TPSALDO,
                        @IN_DTLP,   @IN_MVSOMA, @IN_LOTE,   @IN_SBLOTE, @IN_DOC,   @IN_VALOR, @cResult OutPut
      end
   End
   select @OUT_RESULT = @cResult
End
