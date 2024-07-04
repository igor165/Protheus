Create procedure MAT036_##
(
 @IN_FILIALCOR    char('B1_FILIAL'),
 @IN_DATA         char(08),
 @IN_CODIGO       char('B1_COD'),
 @IN_LOCAL        char('B1_LOCPAD'),
 @IN_MV_RASTRO    char(01),
 @IN_MV_ULMES     char(08),
 @IN_300SALNEG    char(01),
 @IN_B2_QFIM      float,
 @IN_B2_QACLASS   float,
 @IN_CONSULTA     char(01),
 @IN_FILSEQ       integer,
 @IN_MV_WMSNEW    char(01),
 @OUT_SOMASB8     float OutPut
)

as


/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> BJAtuComB2 (mata280.prx) </s>
    Descricao   -  <d> Efetua a gravação no arquivo SBJ - Saldos Iniciais por Lote. </d>
    Assinatura  -  <a> 003 </a>
    Entrada     -  <ri> @IN_FILIALCOR  - Filial corrente
                   @IN_DATA       - Data de fechamento
                   @IN_CODIGO     - Codigo do produto
                   @IN_LOCAL      - Localizacao </ri>

    Saida       -  <ro> @OUT_SOMASB8 - Soma das Quantidades do SB8 </ro>

    Responsavel :  <r> Ricardo Gonçalves </r>
    Data        :  <dt> 04.10.2001 </dt>
--------------------------------------------------------------------------------------------------------------------- */

Declare @cFil_SB1       Char('B1_FILIAL')
Declare @cFil_SB2       Char('B2_FILIAL')
Declare @cFil_SB8       Char('B8_FILIAL')
Declare @cFil_SBJ       Char('BJ_FILIAL')

declare @cRastroL       char(01)

/* ---------------------------------------------------------------------------------------------------------------------
   Variáveis para cursor
--------------------------------------------------------------------------------------------------------------------- */
declare @cB8_PRODUTO    char('B8_PRODUTO')
declare @cB8_LOCAL      char('B8_LOCAL')
declare @cB8_LOTECTL    char('B8_LOTECTL')
declare @cB8_NUMLOTE    char('B8_NUMLOTE')
declare @dB8_DATA       char(08)
declare @dB8_DTVALID    char(08)
declare @nSaldoLote     float -- saldo do lote retornado pela rotina CalcEstL
declare @nSaldoLtUM     decimal( 'B9_QISEGUM' ) --float -- saldo do lote da segunda unidade de medida
declare @nSaldoAux      float
declare @dtFech         char(08)
declare @vRecno         integer
declare @cAux           Varchar(3)
declare @cAux1          Varchar(1)
declare @nAux           integer
declare @nDifSB2        float
declare @iRecno         integer
declare @cProduto       char('B8_PRODUTO')
declare @cLocal         char('B8_LOCAL')
declare @cData          char(8)

begin

   select @OUT_SOMASB8 = 0
   select @cAux1       = ' '
   select @nDifSB2     = 0

   /* -------------------------------------------------------------------------
    Evitando Parameter Sniffing
   ------------------------------------------------------------------------- */
   select @cProduto = @IN_CODIGO
   select @cLocal = @IN_LOCAL
   select @cData = @IN_DATA


   /* ------------------------------------------------------------------------------------------------------------------
       Verifica se o produto usa Rastreabilidade
   ------------------------------------------------------------------------------------------------------------------ */
   exec MAT011_## @IN_MV_RASTRO, @cProduto, @cAux1, @IN_FILIALCOR, @cRastroL output

   if (@cRastroL = '1') begin

      /* ---------------------------------------------------------------------------------------------------------------
          Recupera filiais das tabelas
      --------------------------------------------------------------------------------------------------------------- */
      select @cAux = 'SB1'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB1 OutPut
      select @cAux = 'SB2'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB2 OutPut
      select @cAux = 'SB8'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB8 OutPut
      select @cAux = 'SBJ'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBJ OutPut

      /* ---------------------------------------------------------------------------------------------------------------
         Adiciona um dia na data de fechamento
      --------------------------------------------------------------------------------------------------------------- */
      /* ----------------------------------------------------------------------------------
         Tratamento para o OpenEdge
      --------------------------------------------------------------------------------- */
      ##IF_001({|| AllTrim(Upper(TcGetDB())) <> "OPENEDGE" })
      select @dtFech = convert( char(08), dateadd( day, 1, @IN_DATA ), 112 )
      ##ELSE_001
      EXEC MSDATEADD 'DAY', 1, @IN_DATA, @dtFech OutPut
      ##ENDIF_001

      declare CUR_BJ insensitive cursor for
         select B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DATA, B8_DTVALID
           from SB2### SB2 (nolock), SB1### SB1 (nolock), SB8### SB8 (nolock)
          where B2_FILIAL      = @cFil_SB2
            and B2_COD         = @cProduto
            and B2_LOCAL       = @cLocal
            and B1_FILIAL      = @cFil_SB1
            and B1_COD         = B2_COD
            and B8_FILIAL      = @cFil_SB8
            and B8_PRODUTO     = B2_COD
            and B8_LOCAL       = B2_LOCAL
            and SB2.D_E_L_E_T_ = ' '
            and SB1.D_E_L_E_T_ = ' '
            and SB8.D_E_L_E_T_ = ' '
      for read only

      open CUR_BJ

      fetch CUR_BJ into @cB8_PRODUTO, @cB8_LOCAL, @cB8_LOTECTL, @cB8_NUMLOTE, @dB8_DATA, @dB8_DTVALID

      while (@@Fetch_Status = 0) begin
         /* ---------------------------------------------------------------------------------------------------------
            Zerando variáveis de saldo
         --------------------------------------------------------------------------------------------------------- */
         select @nSaldoLote = 0
         select @nSaldoLtUM = 0

         /* ---------------------------------------------------------------------------------------------------------
            CalcEstL
         --------------------------------------------------------------------------------------------------------- */
         select @cAux  = ' '
         select @cAux1 = '1'

         exec MAT029_## @IN_FILIALCOR, @cB8_PRODUTO, @cB8_LOCAL, @dtFech, @cB8_LOTECTL, @cB8_NUMLOTE,
                        @cAux, @cAux, @cAux1, @IN_MV_ULMES, @IN_300SALNEG,@IN_MV_WMSNEW, @cB8_PRODUTO,
                        @nSaldoLote output, @nSaldoLtUM output, @nSaldoLtUM output, @nSaldoLtUM output,
                        @nSaldoLtUM output, @nSaldoLtUM output, @nSaldoLtUM output

         if @dB8_DATA > @cData begin
            if @nSaldoLote = 0 begin
               /* ------------------------------------------------------------------------------------------------------
                  Tratamento para o DB2
               ------------------------------------------------------------------------------------------------------ */
               SELECT @fim_CUR = 0

               fetch CUR_BJ into @cB8_PRODUTO, @cB8_LOCAL, @cB8_LOTECTL, @cB8_NUMLOTE, @dB8_DATA, @dB8_DTVALID
               continue
            end else begin
                if @nSaldoLote < 0 and @IN_300SALNEG = '0' begin
                  select @nSaldoLote = 0
                  select @nSaldoLtUM = 0
                end
            end
         end

         /* ---------------------------------------------------------------------------------------------------------
             Obtendo saldo da segunda unidade de medida
         --------------------------------------------------------------------------------------------------------- */
         select @nAux = 2
         select @nSaldoAux = @nSaldoLtUM

         exec MAT018_## @cB8_PRODUTO, @IN_FILIALCOR, @nSaldoLote, @nSaldoAux, @nAux, @nSaldoLtUM output
         if ( @nSaldoLtUM = 0 and @nSaldoAux <> 0 ) select @nSaldoLtUM  = @nSaldoAux

         select @vRecno = null

         /* ------------------------------------------------------------------------------------------------------
            Verifica se existe algum lançamento no SBJ para decidir se faz inserção ou atualização
         ------------------------------------------------------------------------------------------------------ */
         if @IN_CONSULTA = '1' Begin
            select @vRecno = R_E_C_N_O_
              from TRJ### (nolock)
             where BJ_FILIAL     = @cFil_SBJ
               and BJ_COD        = @cB8_PRODUTO
               and BJ_LOCAL      = @cB8_LOCAL
               and BJ_LOTECTL    = @cB8_LOTECTL
               and BJ_NUMLOTE    = @cB8_NUMLOTE
               and BJ_DATA       = @dtFech
               and D_E_L_E_T_    = ' '
		   End Else Begin
            select @vRecno = R_E_C_N_O_
              from SBJ### (nolock)
             where BJ_FILIAL     = @cFil_SBJ
               and BJ_COD        = @cB8_PRODUTO
               and BJ_LOCAL      = @cB8_LOCAL
               and BJ_LOTECTL    = @cB8_LOTECTL
               and BJ_NUMLOTE    = @cB8_NUMLOTE
               and BJ_DATA       = @dtFech
               and D_E_L_E_T_    = ' '

		   End

         if @vRecno is null begin

            if @IN_CONSULTA = '1' Begin
               insert into TRJ### ( BJ_FILIAL,  BJ_COD,       BJ_LOCAL,    BJ_LOTECTL,   BJ_NUMLOTE,
                                    BJ_DATA,    BJ_QINI,      BJ_QISEGUM   )
                           values ( @cFil_SBJ,  @cB8_PRODUTO, @cB8_LOCAL,  @cB8_LOTECTL, @cB8_NUMLOTE,
                                    @cData,     @nSaldoLote,  @nSaldoLtUM  )
            End Else Begin

               /* ------------------------------------------------------------------------------------------------------
                  Obtendo Recno
               ------------------------------------------------------------------------------------------------------ */
               select @vRecno = isnull(max( R_E_C_N_O_ ),0) from SBJ### (nolock)

               if @vRecno is null select @vRecno = 1
               else               select @vRecno = @vRecno + 1

               If @dB8_DTVALID = ' ' Begin
                  ##TRATARECNO @vRecno\
                  insert into SBJ### ( BJ_FILIAL,  BJ_COD,       BJ_LOCAL,    BJ_LOTECTL, BJ_NUMLOTE,
                                       BJ_DATA,    BJ_QINI,      BJ_QISEGUM,  R_E_C_N_O_ )
                              values ( @cFil_SBJ,  @cB8_PRODUTO, @cB8_LOCAL,  @cB8_LOTECTL, @cB8_NUMLOTE,
                                       @cData,     @nSaldoLote,  @nSaldoLtUM, @vRecno )
                  ##FIMTRATARECNO

               End Else Begin
                  ##TRATARECNO @vRecno\
                  insert into SBJ### ( BJ_FILIAL, BJ_COD,       BJ_LOCAL,    BJ_LOTECTL,   BJ_NUMLOTE,
                                       BJ_DATA ,  BJ_QINI,      BJ_QISEGUM,  BJ_DTVALID,   R_E_C_N_O_ )
                              values ( @cFil_SBJ, @cB8_PRODUTO, @cB8_LOCAL,  @cB8_LOTECTL, @cB8_NUMLOTE,
                                       @cData,    @nSaldoLote,  @nSaldoLtUM, @dB8_DTVALID, @vRecno )
                  ##FIMTRATARECNO
               End
            End
         end else begin
            if @IN_CONSULTA = '1' Begin
               update TRJ###
                  set BJ_FILIAL  = @cFil_SBJ,    BJ_COD     = @cB8_PRODUTO, BJ_LOCAL = @cB8_LOCAL,
                      BJ_LOTECTL = @cB8_LOTECTL, BJ_NUMLOTE = @cB8_NUMLOTE, BJ_DATA  = @cData,
                      BJ_QINI    = @nSaldoLote,  BJ_QISEGUM = @nSaldoLtUM
                where R_E_C_N_O_ = @vRecno
            End Else Begin
               If @dB8_DTVALID = ' ' Begin
                  update SBJ###
                     set BJ_FILIAL  = @cFil_SBJ,    BJ_COD     = @cB8_PRODUTO, BJ_LOCAL   = @cB8_LOCAL,
                         BJ_LOTECTL = @cB8_LOTECTL, BJ_NUMLOTE = @cB8_NUMLOTE, BJ_DATA    = @cData,
                         BJ_QINI    = @nSaldoLote,  BJ_QISEGUM = @nSaldoLtUM
                     where R_E_C_N_O_ = @vRecno
               End Else Begin
                  update SBJ###
                     set BJ_FILIAL  = @cFil_SBJ,    BJ_COD     = @cB8_PRODUTO, BJ_LOCAL   = @cB8_LOCAL,
                         BJ_LOTECTL = @cB8_LOTECTL, BJ_NUMLOTE = @cB8_NUMLOTE, BJ_DATA    = @cData,
                         BJ_QINI    = @nSaldoLote,  BJ_QISEGUM = @nSaldoLtUM , BJ_DTVALID = @dB8_DTVALID
                     where R_E_C_N_O_ = @vRecno

               End
            End
         end

         select @OUT_SOMASB8 = @OUT_SOMASB8 + @nSaldoLote

         /* ------------------------------------------------------------------------------------------------------
            Soma os valores de SB8 para verificar se existe divergencia
         ------------------------------------------------------------------------------------------------------ */
         select @nDifSB2 = @nDifSB2 + @nSaldoLote

         /* ------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
         ------------------------------------------------------------------------------------------------------ */
         SELECT @fim_CUR = 0

         fetch CUR_BJ into @cB8_PRODUTO, @cB8_LOCAL, @cB8_LOTECTL, @cB8_NUMLOTE, @dB8_DATA, @dB8_DTVALID

      end -- end while

      -- Alimenta arquivo temporario referente as diferencas entre SB2 e SB8
      if @IN_CONSULTA <> '1' and ( Round(@IN_B2_QFIM,6)-@IN_B2_QACLASS ) <> Round(@nDifSB2,6) begin
         select @cAux = 'SB8'
         insert into TRC### (TRC_FILIAL, TRC_COD, TRC_LOCAL, TRC_ALIAS, TRC_QFIM, TRC_DIVERG )
         values ( @IN_FILIALCOR, @cProduto, @cLocal, @cAux, @IN_B2_QFIM, @nDifSB2 )
      End

      close CUR_BJ
      deallocate CUR_BJ
   end -- (@cRastroL = '1')

end
