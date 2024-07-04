Create procedure MAT037_##
(
 @IN_FILIALCOR    char('B1_FILIAL'),
 @IN_DATA         char(08),
 @IN_CODIGO       char('B1_COD'),
 @IN_LOCAL        char('B1_LOCPAD'),
 @IN_MV_ULMES     char(08),
 @IN_300SALNEG    char(01),
 @IN_B2_QFIM      float,
 @IN_CONSULTA     char(01),
 @IN_FILSEQ       integer,
 @IN_MV_WMSNEW    char(01),
 @IN_MV_ARQPROD   char(03),
 @IN_cRASTRO	   char(01),
 @OUT_SOMASBF     float OutPut
)

as


/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> mata280.prx -> BKAtuComB2 </s>
    Assinatura  -  <a> 003 </a>
    Descricao   -  <d> Efetua a gravação no arquivo SBK - Saldos Iniciais por Localização. </d>
    Entrada     -  <ri> @IN_FILIALCOR  - Filial corrente
                   @IN_DATA       - Data de fechamento
                   @IN_CODIGO     - Codigo do produto
                   @IN_LOCAL      - Localizacao </ri>

    Saida       -  <ro> @OUT_SOMASBF - Soma das Quantidades do SBF </ro>

    Responsavel :  <r> Ricardo Gonçalves </r>
    Data        :  <dt> 04.10.2001 </dt>
--------------------------------------------------------------------------------------------------------------------- */

Declare @cFil_SB1       Char('B1_FILIAL')
Declare @cFil_SB2       Char('B2_FILIAL')
Declare @cFil_SBF       Char('BF_FILIAL')
Declare @cFil_SBK       Char('BK_FILIAL')
Declare @cFil_SDB       Char('DB_FILIAL')

declare @lLocaliz       char(01)

/* ---------------------------------------------------------------------------------------------------------------------
   Variáveis para cursor
--------------------------------------------------------------------------------------------------------------------- */
declare @cXX_PRODUTO    char('BF_PRODUTO')
declare @cXX_LOCAL      char('BF_LOCAL')
declare @cXX_LOTECTL    char('BF_LOTECTL')
declare @cXX_NUMLOTE    char('BF_NUMLOTE')
declare @cXX_LOCALIZ    char('BF_LOCALIZ')
declare @cXX_NUMSERI    char('BF_NUMSERI')

declare @nSaldoLote     float -- saldo do lote retornado pela rotina CalcEstL
declare @nSaldoLtUM     decimal( 'B9_QISEGUM' ) --float -- saldo do lote da segunda unidade de medida
declare @nSaldoAux      float
declare @nSaldo2        float
declare @nSaldo3        float
declare @nSaldo4        float
declare @nSaldo5        float
declare @nSaldo6        float
declare @dtFech         char(08)

declare @vRecno         int
declare @cAux           Varchar(3)
declare @nAux           integer
declare @nDifSB2        float
declare @iRecno         integer
declare @cProduto       char('BF_PRODUTO')
declare @cLocal         char('BF_LOCAL')
declare @cData          char(8)
declare @cMV_ULMES      char(8)

begin

   select @OUT_SOMASBF = 0
   select @nDifSB2     = 0

   /* -------------------------------------------------------------------------
    Evitando Parameter Sniffing
   ------------------------------------------------------------------------- */
   select @cProduto = @IN_CODIGO
   select @cLocal = @IN_LOCAL
   select @cData = @IN_DATA
   select @cMV_ULMES = @IN_MV_ULMES


   /* ------------------------------------------------------------------------------------------------------------------
       Verifica se o produto usa controle de lote
   ------------------------------------------------------------------------------------------------------------------ */

   exec MAT012_## @cProduto, @IN_FILIALCOR,@IN_MV_WMSNEW, @IN_MV_ARQPROD, @lLocaliz output

   if @lLocaliz = '1' begin

      /* ---------------------------------------------------------------------------------------------------------------
          Recupera filiais das tabelas
      --------------------------------------------------------------------------------------------------------------- */
      select @cAux = 'SB1'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB1 OutPut
      select @cAux = 'SB2'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB2 OutPut
      select @cAux = 'SBF'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBF OutPut
      select @cAux = 'SBK'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBK OutPut
      select @cAux = 'SDB'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SDB OutPut

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

      declare CUR_BK1 insensitive cursor for
         select BF_PRODUTO, BF_LOCAL,   BF_LOTECTL, BF_NUMLOTE,
                BF_LOCALIZ, BF_NUMSERI
           from SB2### SB2 (nolock), SB1### SB1 (nolock), SBF### SBF (nolock)
          where B2_FILIAL      = @cFil_SB2
            and B2_COD         = @cProduto
            and B2_LOCAL       = @cLocal
            and B1_FILIAL      = @cFil_SB1
            and B1_COD         = B2_COD
            and BF_FILIAL      = @cFil_SBF
            and BF_PRODUTO     = B2_COD
            and BF_LOCAL       = B2_LOCAL
            and ( BF_QUANT     > 0 AND @IN_300SALNEG = '0' )
            and SB2.D_E_L_E_T_ = ' '
            and SB1.D_E_L_E_T_ = ' '
            and SBF.D_E_L_E_T_ = ' '
      union
         select DB_PRODUTO, DB_LOCAL, DB_LOTECTL, DB_NUMLOTE,
                DB_LOCALIZ, DB_NUMSERI
           from SB2### SB2 (nolock), SB1### SB1 (nolock), SDB### SDB (nolock)
          where B2_FILIAL      = @cFil_SB2
            and B2_COD         = @cProduto
            and B2_LOCAL       = @cLocal
            and B1_FILIAL      = @cFil_SB1
            and B1_COD         = B2_COD
            and DB_FILIAL      = @cFil_SDB
            and DB_PRODUTO     = B2_COD
            and DB_LOCAL       = B2_LOCAL
			   and ((@IN_cRASTRO = '1' and DB_LOTECTL <> ' ') or (@IN_cRASTRO <> '1' and DB_LOTECTL = ' '))
            and DB_DATA        between @cMV_ULMES and @cData
			   and DB_ESTORNO     = ' '
            and SB2.D_E_L_E_T_ = ' '
            and SB1.D_E_L_E_T_ = ' '
            and SDB.D_E_L_E_T_ = ' '
      union
         select BK_COD,     BK_LOCAL,   BK_LOTECTL, BK_NUMLOTE,
                BK_LOCALIZ, BK_NUMSERI
           from SB2### SB2 (nolock), SB1### SB1 (nolock), SBK### SBK (nolock)
          where B2_FILIAL      = @cFil_SB2
            and B2_COD         = @cProduto
            and B2_LOCAL       = @cLocal
            and B1_FILIAL      = @cFil_SB1
            and B1_COD         = B2_COD
            and BK_FILIAL      = @cFil_SBK
            and BK_COD         = B2_COD
            and BK_LOCAL       = B2_LOCAL
			   and ((@IN_cRASTRO = '1' and BK_LOTECTL <> ' ') or (@IN_cRASTRO <> '1' and BK_LOTECTL = ' '))
            and BK_DATA       >= @cMV_ULMES
            and BK_DATA        < @cData
            and SB2.D_E_L_E_T_ = ' '
            and SB1.D_E_L_E_T_ = ' '
            and SBK.D_E_L_E_T_ = ' '
       order by 1,2,3,4,5,6
      for read only

      open CUR_BK1

      fetch CUR_BK1 into @cXX_PRODUTO, @cXX_LOCAL, @cXX_LOTECTL, @cXX_NUMLOTE, @cXX_LOCALIZ, @cXX_NUMSERI

      while (@@Fetch_Status = 0) begin

         /* ------------------------------------------------------------------------------------------------------------
            Zerando variáveis de saldo
         ------------------------------------------------------------------------------------------------------------ */
         select @nSaldoLote = 0
         select @nSaldoLtUM = 0

         /* ------------------------------------------------------------------------------------------------------------
            CalcEstL
         ------------------------------------------------------------------------------------------------------------ */
         select @cAux = '1'
         exec MAT029_## @IN_FILIALCOR, @cXX_PRODUTO, @cXX_LOCAL, @dtFech, @cXX_LOTECTL, @cXX_NUMLOTE,
                        @cXX_LOCALIZ,  @cXX_NUMSERI, @cAux, @IN_MV_ULMES, @IN_300SALNEG,@IN_MV_WMSNEW,
                        @cXX_PRODUTO,
                        @nSaldoLote output, @nSaldo2 output, @nSaldo3 output,
                        @nSaldo4 output, @nSaldo5 output, @nSaldo6 output, @nSaldoLtUM output

         /* ------------------------------------------------------------------------------------------------------------
             Obtendo saldo da segunda unidade de medida
         ------------------------------------------------------------------------------------------------------------ */
         select @nAux = 2
         select @nSaldoAux = @nSaldoLtUM
         exec MAT018_## @cXX_PRODUTO, @IN_FILIALCOR, @nSaldoLote, @nSaldoAux, @nAux, @nSaldoLtUM output
         if ( @nSaldoLtUM = 0 and @nSaldoAux <> 0 ) select @nSaldoLtUM = @nSaldoAux

         select @vRecno = null

         /* ---------------------------------------------------------------------------------------------------------
            Verifica se existe algum lançamento no SBK para decidir se faz inserção ou atualização
         --------------------------------------------------------------------------------------------------------- */
         if @IN_CONSULTA = '1' Begin
           select @vRecno = R_E_C_N_O_
             from TRK###
            where BK_FILIAL     = @cFil_SBK
              and BK_COD        = @cXX_PRODUTO
              and BK_LOCAL      = @cXX_LOCAL
              and BK_LOTECTL    = @cXX_LOTECTL
              and BK_NUMLOTE    = @cXX_NUMLOTE
              and BK_LOCALIZ    = @cXX_LOCALIZ
              and BK_NUMSERI    = @cXX_NUMSERI
              and BK_DATA       = @cData
              and D_E_L_E_T_    = ' '
         End Else Begin
           select @vRecno = R_E_C_N_O_
             from SBK###
            where BK_FILIAL     = @cFil_SBK
              and BK_COD        = @cXX_PRODUTO
              and BK_LOCAL      = @cXX_LOCAL
              and BK_LOTECTL    = @cXX_LOTECTL
              and BK_NUMLOTE    = @cXX_NUMLOTE
              and BK_LOCALIZ    = @cXX_LOCALIZ
              and BK_NUMSERI    = @cXX_NUMSERI
              and BK_DATA       = @cData
              and D_E_L_E_T_    = ' '
         End
         if @nSaldoLtUM is null select @nSaldoLtUM = 0

         if @vRecno is null begin
            if @IN_CONSULTA = '1' Begin
               insert into TRK### ( BK_FILIAL,    BK_COD,       BK_LOCAL,   BK_LOTECTL,   BK_NUMLOTE,
                                    BK_LOCALIZ,   BK_NUMSERI,   BK_DATA,    BK_QINI,
                                    BK_QISEGUM    )
                           values ( @cFil_SBK,    @cXX_PRODUTO, @cXX_LOCAL, @cXX_LOTECTL, @cXX_NUMLOTE,
                                    @cXX_LOCALIZ, @cXX_NUMSERI, @cData,     @nSaldoLote,
                                    @nSaldoLtUM   )
            End Else Begin
               /* ------------------------------------------------------------------------------------------------------
                  Obtendo Recno
               ------------------------------------------------------------------------------------------------------ */
               select @vRecno = isnull(max( R_E_C_N_O_ ),0) from SBK###

               if @vRecno is null select @vRecno = 1
               else               select @vRecno = @vRecno + 1

               ##TRATARECNO @vRecno\
               insert into SBK### ( BK_FILIAL,    BK_COD,       BK_LOCAL,   BK_LOTECTL,   BK_NUMLOTE,
                                    BK_LOCALIZ,   BK_NUMSERI,   BK_DATA,    BK_QINI,
                                    BK_QISEGUM,   R_E_C_N_O_ )
                           values ( @cFil_SBK,    @cXX_PRODUTO, @cXX_LOCAL, @cXX_LOTECTL, @cXX_NUMLOTE,
                                    @cXX_LOCALIZ, @cXX_NUMSERI, @cData,     @nSaldoLote,
                                    @nSaldoLtUM,  @vRecno )
		         ##FIMTRATARECNO

            End
         end else begin
			if @IN_CONSULTA = '1' Begin
               update TRK###
                  set BK_FILIAL     = @cFil_SBK,    BK_COD     = @cXX_PRODUTO, BK_LOCAL    = @cXX_LOCAL,
                      BK_LOTECTL    = @cXX_LOTECTL, BK_NUMLOTE = @cXX_NUMLOTE, BK_LOCALIZ  = @cXX_LOCALIZ,
                      BK_NUMSERI    = @cXX_NUMSERI, BK_DATA    = @cData,       BK_QINI     = @nSaldoLote,
                      BK_QISEGUM    = @nSaldoLtUM
                where R_E_C_N_O_    = @vRecno
            End Else Begin
               update SBK###
                  set BK_FILIAL     = @cFil_SBK,    BK_COD     = @cXX_PRODUTO, BK_LOCAL    = @cXX_LOCAL,
                      BK_LOTECTL    = @cXX_LOTECTL, BK_NUMLOTE = @cXX_NUMLOTE, BK_LOCALIZ  = @cXX_LOCALIZ,
                      BK_NUMSERI    = @cXX_NUMSERI, BK_DATA    = @cData,       BK_QINI     = @nSaldoLote,
                      BK_QISEGUM    = @nSaldoLtUM
                where R_E_C_N_O_    = @vRecno
            End
         end

         select @OUT_SOMASBF = @OUT_SOMASBF + @nSaldoLote

         /* ------------------------------------------------------------------------------------------------------
            Soma os valores de SBK para verificar se existe divergencia
         ------------------------------------------------------------------------------------------------------ */
         select @nDifSB2 = @nDifSB2 + @nSaldoLote

         /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
         -------------------------------------------------------------------------------------------------------------- */
         SELECT @fim_CUR = 0

         fetch CUR_BK1 into @cXX_PRODUTO, @cXX_LOCAL, @cXX_LOTECTL, @cXX_NUMLOTE, @cXX_LOCALIZ, @cXX_NUMSERI

      end

      -- Alimenta arquivo temporario referente as diferencas entre SB2 e SBJ
      if @IN_CONSULTA <> '1' and Round(@nDifSB2,6) > Round(@IN_B2_QFIM,6) begin
         select @cAux = 'SBF'
         insert into TRC### (TRC_FILIAL, TRC_COD, TRC_LOCAL, TRC_ALIAS, TRC_QFIM, TRC_DIVERG )
         values ( @IN_FILIALCOR, @cProduto, @cLocal, @cAux, @IN_B2_QFIM, @nDifSB2 )
      End

      close CUR_BK1
      deallocate CUR_BK1

   end

end
