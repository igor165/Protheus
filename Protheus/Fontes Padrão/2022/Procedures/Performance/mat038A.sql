Create Procedure MAT038A_##
(
 @IN_FILIALCOR    char('B1_FILIAL'),
 @IN_DATA         char(08),
 @IN_MV_CUSFIFO   char(01),
 @IN_MV_MOEDACM   char(05),
 @IN_CFECHFIFO    char(01),
 @OUT_RESULTADO   char(01) OutPut
)
as

/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> mata280 </s>
    Assinatura  -  <a> 003 </a>
    Descricao   -  <d> Virada de Saldos FIFO/LIFO </d>
    Entrada     -  <ri> @IN_FILIALCOR
                        @IN_DATA
                        @IN_MV_CUSFIFO
                        @IN_MV_MOEDACM
                        @IN_CFECHFIFO
                        @OUT_RESULTADO </ri>

    Saida       -  <ro> @OUT_RESULTADO - Houve sucesso ou não </ro>

    Responsavel :  <r> reynaldo </r>
    Data        :  <dt> 30.10.2020 </dt>

    Estrutura de chamadas
    ========= == ========

    0.MAT038A - Virada de Saldos FIFO/LIFO e Ordens de Produção
      1.XFILIAL - Codigo da Filial do sistema
      1.MAT018 - Converte a Unidade de Medida.

--------------------------------------------------------------------------------------------------------------------- */

Declare @cFil_SBD       Char('BD_FILIAL')
Declare @cFil_SCC       Char('CC_FILIAL')
Declare @cFil_SD8       char('D8_FILIAL')

/* ---------------------------------------------------------------------------------------------------------------------
   Variáveis para cursor
--------------------------------------------------------------------------------------------------------------------- */
declare @vRecno         int

declare @nBD_QFIM       decimal( 'BD_QFIM' )
declare @nBD_QFIM2UM    decimal( 'BD_QFIM2UM' )
declare @nBD_CUSFIM1    decimal( 'BD_CUSFIM1' )
declare @nBD_CUSFIM2    decimal( 'BD_CUSFIM2' )
declare @nBD_CUSFIM3    decimal( 'BD_CUSFIM3' )
declare @nBD_CUSFIM4    decimal( 'BD_CUSFIM4' )
declare @nBD_CUSFIM5    decimal( 'BD_CUSFIM5' )
declare @cBD_PRODUTO    char('BD_PRODUTO')
declare @cBD_LOCAL      char('BD_LOCAL')
declare @cBD_SEQ        char('BD_SEQ')
declare @vBD_QINI       decimal( 'BD_QINI' )
declare @vBD_QINI2UM    decimal( 'BD_QINI2UM' )
declare @vBD_CUSINI1    decimal( 'BD_CUSINI1' )
declare @vBD_CUSINI2    decimal( 'BD_CUSINI2' )
declare @vBD_CUSINI3    decimal( 'BD_CUSINI3' )
declare @vBD_CUSINI4    decimal( 'BD_CUSINI4' )
declare @vBD_CUSINI5    decimal( 'BD_CUSINI5' )
declare @vBD_QFIM       decimal( 'BD_QFIM' )
declare @vBD_QFIM2UM    decimal( 'BD_QFIM2UM' )
declare @vBD_CUSFIM1    decimal( 'BD_CUSFIM1' )
declare @vBD_CUSFIM2    decimal( 'BD_CUSFIM2' )
declare @vBD_CUSFIM3    decimal( 'BD_CUSFIM3' )
declare @vBD_CUSFIM4    decimal( 'BD_CUSFIM4' )
declare @vBD_CUSFIM5    decimal( 'BD_CUSFIM5' )
declare @cBD_DATA       char('BD_DATA')
declare @cBD_OP         char('BD_OP')

declare @vXXBD_CUSINI2  decimal( 'BD_CUSINI2' )
declare @vXXBD_CUSINI3  decimal( 'BD_CUSINI3' )
declare @vXXBD_CUSINI4  decimal( 'BD_CUSINI4' )
declare @vXXBD_CUSINI5  decimal( 'BD_CUSINI5' )
declare @vXXBD_CUSFIM2  decimal( 'BD_CUSFIM2' )
declare @vXXBD_CUSFIM3  decimal( 'BD_CUSFIM3' )
declare @vXXBD_CUSFIM4  decimal( 'BD_CUSFIM4' )
declare @vXXBD_CUSFIM5  decimal( 'BD_CUSFIM5' )

declare @nSaldoLtUM     decimal( 'B9_QISEGUM' ) --float -- saldo do lote da segunda unidade de medida

declare @cAux           Varchar(3)
declare @nAux           integer
declare @nContador      integer
declare @iTranCount     integer --Var.de ajuste para SQLServer e Sybase. Será trocada por Commit no CFGX051 após passar pelo Parse
declare @iPos           integer

begin

   select @OUT_RESULTADO = '0'

   /* -------------------------------------------------------------------------
    Evitando Parameter Sniffing
   ------------------------------------------------------------------------- */

   /* ------------------------------------------------------------------------------------------------------------------
      Recupera filiais das tabelas
   ------------------------------------------------------------------------------------------------------------------ */
   select @cAux = 'SBD'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBD OutPut

   ##FIELDP01( 'SCC.CC_SEQ' )
   select @cAux = 'SD8'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD8 OutPut
   select @cAux = 'SCC'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SCC OutPut
   ##ENDFIELDP01

   select @nContador = 0

   ##FIELDP23( 'SCC.CC_SEQ' )
   If @IN_MV_CUSFIFO = '1' begin
      /* ------------------------------------------------------------------------------------------------------------------
         FechFifo - Nova rotina de Fechamento Fifo
      ------------------------------------------------------------------------------------------------------------------ */
      If @IN_CFECHFIFO = '1' begin
         /* ---------------------------------------------------------------------------------------------------------------
            Atualiza Saldos Iniciais Fifo / Lifo
         --------------------------------------------------------------------------------------------------------------- */
         update SCC###
            set CC_STATUS = 'E'
         where CC_FILIAL = @cFil_SCC
            and CC_STATUS = 'A'
            and D_E_L_E_T_ = ' '

         /* ---------------------------------------------------------------------------------------------------------------
            Ajusta a quantidade do campo D8_QFIMDEV
         --------------------------------------------------------------------------------------------------------------- */
         update SD8###
            set D8_QFIMDEV = 0
         where D8_FILIAL  = @cFil_SD8
            and D8_TM      > '500'
            and D8_ITEM   <> ' '
            and D8_QFIMDEV > 0
            and D_E_L_E_T_ = ' '

         /* ---------------------------------------------------------------------------------------------------------------
            Gera Saldos Iniciais Fifo/Lifo Baseado nos Lotes em aberto
         --------------------------------------------------------------------------------------------------------------- */
         declare CUR_M280SBD insensitive cursor for
            select BD_PRODUTO , BD_LOCAL   , BD_SEQ     , BD_QINI    , BD_QINI2UM , BD_CUSINI1 , BD_CUSINI2 , BD_CUSINI3 , BD_CUSINI4 , BD_CUSINI5 ,
                  BD_QFIM    , BD_QFIM2UM , BD_CUSFIM1 , BD_CUSFIM2 , BD_CUSFIM3 , BD_CUSFIM4 , BD_CUSFIM5 , BD_DATA    , BD_OP
            from SBD### (nolock)
            where BD_FILIAL  = @cFil_SBD
               and BD_STATUS <> 'Z'
               and D_E_L_E_T_ = ' '
         for read only

         open CUR_M280SBD

         fetch CUR_M280SBD into @cBD_PRODUTO , @cBD_LOCAL   , @cBD_SEQ  , @vBD_QINI    , @vBD_QINI2UM , @vBD_CUSINI1 , @vBD_CUSINI2 , @vBD_CUSINI3 ,
                                @vBD_CUSINI4 , @vBD_CUSINI5 , @vBD_QFIM , @vBD_QFIM2UM , @vBD_CUSFIM1 , @vBD_CUSFIM2 , @vBD_CUSFIM3 , @vBD_CUSFIM4 ,
                                @vBD_CUSFIM5 , @cBD_DATA    , @cBD_OP

         while (@@fetch_status = 0) begin

            /* ---------------------------------------------------------------------------------------------------------
               Grava SCC
            --------------------------------------------------------------------------------------------------------- */
            select @vXXBD_CUSINI2 = 0
            select @vXXBD_CUSINI3 = 0
            select @vXXBD_CUSINI4 = 0
            select @vXXBD_CUSINI5 = 0
            select @vXXBD_CUSFIM2 = 0
            select @vXXBD_CUSFIM3 = 0
            select @vXXBD_CUSFIM4 = 0
            select @vXXBD_CUSFIM5 = 0
            select @iPos = Charindex( '2', @IN_MV_MOEDACM )
            If @iPos > 0 begin    --Moeda 2
               select @vXXBD_CUSINI2 = @vBD_CUSINI2
               select @vXXBD_CUSFIM2 = @vBD_CUSFIM2
            End
            select @iPos = Charindex( '3', @IN_MV_MOEDACM )
            If @iPos > 0 begin    --Moeda 3
               select @vXXBD_CUSINI3 = @vBD_CUSINI3
               select @vXXBD_CUSFIM3 = @vBD_CUSFIM3
            End
            select @iPos = Charindex( '4', @IN_MV_MOEDACM )
            If @iPos > 0 begin    --Moeda 4
               select @vXXBD_CUSINI4 = @vBD_CUSINI4
               select @vXXBD_CUSFIM4 = @vBD_CUSFIM4
            End
            select @iPos = Charindex( '5', @IN_MV_MOEDACM )
            If @iPos > 0 begin    --Moeda 5
               select @vXXBD_CUSINI5 = @vBD_CUSINI5
               select @vXXBD_CUSFIM5 = @vBD_CUSFIM5
            End

            /* ---------------------------------------------------------------------------------------------------------------
               Obtem RECNO na tabela SCC
            --------------------------------------------------------------------------------------------------------------- */
            select @vRecno = Max(R_E_C_N_O_) from SCC### (nolock)
            if @vRecno is null select @vRecno = 1
            else               select @vRecno = @vRecno + 1

            ##TRATARECNO @vRecno\
            insert into SCC### ( CC_FILIAL      , CC_PRODUTO     , CC_LOCAL       , CC_DATA        , CC_QINI    , CC_QINI2UM   , CC_VINIFF1   ,
                                 CC_VINIFF2     , CC_VINIFF3     , CC_VINIFF4     , CC_VINIFF5     , CC_QFIM    , CC_QFIM2UM   , CC_VFIMFF1   ,
                                 CC_VFIMFF2     , CC_VFIMFF3     , CC_VFIMFF4     , CC_VFIMFF5     , CC_DTORIG  , CC_OP        , CC_SEQ       ,
                                 CC_STATUS      , R_E_C_N_O_ )
                        values ( @cFil_SCC      , @cBD_PRODUTO   , @cBD_LOCAL     , @IN_DATA       , @vBD_QINI  , @vBD_CUSINI2 , @vBD_CUSINI1 ,
                                 @vXXBD_CUSINI2 , @vXXBD_CUSINI3 , @vXXBD_CUSINI4 , @vXXBD_CUSINI5 , @vBD_QFIM  , @vBD_QFIM2UM , @vBD_CUSFIM1 ,
                                 @vXXBD_CUSFIM2 , @vXXBD_CUSFIM3 , @vXXBD_CUSFIM4 , @vXXBD_CUSFIM5 , @cBD_DATA  , @cBD_OP      , @cBD_SEQ     ,
                                 'A'            , @vRecno    )

            fetch CUR_M280SBD into @cBD_PRODUTO , @cBD_LOCAL   , @cBD_SEQ  , @vBD_QINI    , @vBD_QINI2UM , @vBD_CUSINI1 , @vBD_CUSINI2 , @vBD_CUSINI3 ,
                                   @vBD_CUSINI4 , @vBD_CUSINI5 , @vBD_QFIM , @vBD_QFIM2UM , @vBD_CUSFIM1 , @vBD_CUSFIM2 , @vBD_CUSFIM3 , @vBD_CUSFIM4 ,
                                   @vBD_CUSFIM5 , @cBD_DATA    , @cBD_OP
		      ##FIMTRATARECNO
         end  --End While
         close CUR_M280SBD
         deallocate CUR_M280SBD

      end else begin
   ##ENDFIELDP23
         /* ------------------------------------------------------------------------------------------------------------------
            Transfere os saldos dos Lotes FIFO
         ------------------------------------------------------------------------------------------------------------------ */
         select @nContador = 0
         declare CUR_M280SBD2 insensitive cursor for
            select BD_PRODUTO, BD_QFIM,    BD_QFIM2UM, BD_CUSFIM1, BD_CUSFIM2,
                   BD_CUSFIM3, BD_CUSFIM4, BD_CUSFIM5, R_E_C_N_O_
            from SBD### (nolock)
            where BD_FILIAL  = @cFil_SBD
            and D_E_L_E_T_ = ' '
         for read only

         open CUR_M280SBD2

         fetch CUR_M280SBD2 into @cBD_PRODUTO, @nBD_QFIM,    @nBD_QFIM2UM, @nBD_CUSFIM1, @nBD_CUSFIM2,
                              @nBD_CUSFIM3, @nBD_CUSFIM4, @nBD_CUSFIM5, @vRecno
         while (@@fetch_status = 0) begin

            select @nContador = @nContador + 1
            /* ---------------------------------------------------------------------------------------------------------------
                Obtendo saldo da segunda unidade de medida
            --------------------------------------------------------------------------------------------------------------- */
            select @nAux = 2

            exec MAT018_## @cBD_PRODUTO, @IN_FILIALCOR, @nBD_QFIM, @nBD_QFIM2UM, @nAux, @nSaldoLtUM output

            If @nContador = 1 begin
               begin Tran
               select @nContador = @nContador
            End
            update SBD###
						set BD_QINI    = @nBD_QFIM,    BD_QINI2UM = @nSaldoLtUM,  BD_CUSINI1 = @nBD_CUSFIM1,
	                  BD_CUSINI2 = @nBD_CUSFIM2, BD_CUSINI3 = @nBD_CUSFIM3, BD_CUSINI4 = @nBD_CUSFIM4,
	                  BD_CUSINI5 = @nBD_CUSFIM5
               where R_E_C_N_O_ = @vRecno
            fetch CUR_M280SBD2 into @cBD_PRODUTO, @nBD_QFIM,    @nBD_QFIM2UM, @nBD_CUSFIM1, @nBD_CUSFIM2,
                                    @nBD_CUSFIM3, @nBD_CUSFIM4, @nBD_CUSFIM5, @vRecno
            If @nContador > 1023 begin
               commit Tran
               select @nContador = 0
            End
         end  --End While
         close CUR_M280SBD2
         deallocate CUR_M280SBD2
         If @nContador > 0 begin
            Commit Tran
            select @iTranCount = 0
         End
   ##FIELDP24( 'SCC.CC_SEQ' )
      end  -- End If cFechFifo
   end -- End If @IN_MV_CUSFIFO
   ##ENDFIELDP24

   If @nContador > 0 begin
      Commit Tran
      select @iTranCount = 0
   End
   select @OUT_RESULTADO = '1'

end
