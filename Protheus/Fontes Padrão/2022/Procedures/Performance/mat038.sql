Create Procedure MAT038_##
(
 @IN_FILIALLOGIN  char('B1_FILIAL'),
 @IN_FILIALCOR    char('B1_FILIAL'),
 @IN_THREAD       char(02),
 @IN_DATA         char(08),
 @IN_MV_RASTRO    char(01),
 @IN_MV_ULMES     char(08),
 @IN_MV_PAR02     integer,
 @IN_MV_CUSZERO   char(01),
 @IN_300SALNEG    char(01),
 @IN_MV_MOEDACM   char(05),
 @IN_MV_CUSMED    char(01),
 @IN_MV_CUSFIL    char(01),
 @IN_MV_CUSEMP    char(01),
 @IN_MV_PAR04     integer,
 @IN_FILSEQ       integer,
 @IN_MV_WMSNEW    char(01),
 @IN_MV_PRODMOD   char(01),
 @IN_MV_ARQPROD   char(03),
 @OUT_RESULTADO   char(01) OutPut
)
as

/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> mata280 </s>
    Assinatura  -  <a> 003 </a>
    Descricao   -  <d> Fechamento mensal do estoque </d>
    Entrada     -  <ri> @IN_FILIALLOGIN
                        @IN_FILIALCOR
                        @IN_THREAD
                        @IN_DATA
                        @IN_MV_RASTRO
                        @IN_MV_ULMES
                        @IN_MV_PAR02
                        @IN_MV_CUSZERO
                        @IN_300SALNEG
                        @IN_MV_MOEDACM
                        @IN_MV_CUSMED
                        @IN_MV_CUSFIL
                        @IN_MV_CUSEMP
                        @IN_MV_PAR04
                        @IN_FILSEQ
                        @IN_MV_WMSNEW
                        @IN_MV_PRODMOD
                        @IN_MV_ARQPROD    </ri>

    Saida       -  <ro> @OUT_RESULTADO - Virada de Saldo dos produtos  </ro>

    Responsavel :  <r> Ricardo Gonçalves </r>
    Data        :  <dt> 04.10.2001 </dt>

    Estrutura de chamadas
    ========= == ========

    0.MAT038 - Fechamento mensal do estoque
      1.XFILIAL - Busca codigo da filial
      1.MAT050 - Atualiza o saldo atual do SB2 (VATU) Unificado
         2.XFILIAL - Busca codigo da filial
         2.MAT051 - retorna os saldos unificados
      1.MA280CON - Ponto de Entrada
      1.MAT018 - Converte a Unidade de Medida
      1.MA280INB9CP - Ponto de Entrada
      1.M280SB9 - Ponto de Entrada
      1.MAT036 - Efetua a gravação no arquivo SBJ - Saldos Iniciais por Lote.
         2.XFILIAL - Busca codigo da filial
         2.MAT011 - Pesquisa no SB1 se produto corrente usa rastreabilidade
      1.MAT029 - Retorna o Saldo inicial por do Produto/Local do arquivo SD5
         2.XFILIAL - Busca codigo da filial
         2.MAT011 - Pesquisa no SB1 se produto corrente usa rastreabilidade
         2.MAT045 - Retorna o saldo da movimentacao do arquivo SD5
         2.MAT046 - Retorna o saldo da movimentacao do arquivo SDB
      1.MAT011 - Pesquisa no SB1 se produto corrente usa rastreabilidade
      1.MAT018 - Converte a Unidade de Medida
      1.MAT057 - Pesquisa no SB5 e SBZ se produto corrente controla o Novo Wms
      1.MAT058 - Efetua a gravação no arquivo D15 - Saldos Localização.
         2.MAT012 - Pesquisa no SB1 se produto corrente usa localizacao fisica
      1.MAT037 - Efetua a gravação no arquivo SBK - Saldos Iniciais por Localização.
         2.MAT012 - Pesquisa no SB1 se produto corrente usa localizacao fisica
         2.XFILIAL - Busca codigo da filial
         2.MAT018 - Converte a Unidade de Medida
         2.MAT029 - Retorna o Saldo inicial por do Produto/Local do arquivo SD5
            4.MAT011 - Pesquisa no SB1 se produto corrente usa rastreabilidade
         2.MAT018 - Converte a Unidade de Medida
--------------------------------------------------------------------------------------------------------------------- */

Declare @cFil_SB9       Char('B9_FILIAL')
Declare @lIntDl         char(01)

/* ---------------------------------------------------------------------------------------------------------------------
   Variáveis para cursor
--------------------------------------------------------------------------------------------------------------------- */
declare @cB2_COD        char('B2_COD')
declare @cB2_LOCAL      char('B2_LOCAL')
declare @SB2_RECNO      int
declare @vRecno         int
declare @nB2_QFIM       decimal( 'B2_QFIM' )
declare @nB2_QFIM2      decimal( 'B2_QFIM2' )
declare @nB2_VFIM1      decimal( 'B2_VFIM1' )
declare @nB2_VFIM2      decimal( 'B2_VFIM2' )
declare @nB2_VFIM3      decimal( 'B2_VFIM3' )
declare @nB2_VFIM4      decimal( 'B2_VFIM4' )
declare @nB2_VFIM5      decimal( 'B2_VFIM5' )
declare @nB2_VFIMFF1    decimal( 'B2_VFIMFF1' )
declare @nB2_VFIMFF2    decimal( 'B2_VFIMFF2' )
declare @nB2_VFIMFF3    decimal( 'B2_VFIMFF3' )
declare @nB2_VFIMFF4    decimal( 'B2_VFIMFF4' )
declare @nB2_VFIMFF5    decimal( 'B2_VFIMFF5' )
declare @nB2_QACLASS    decimal( 'B2_QACLASS' )
declare @nB1_CONV       decimal( 'B1_CONV' )
declare @nB1_CUSTD      decimal( 'B1_CUSTD' )
declare @cB1_MCUSTD     char('B1_MCUSTD')

declare @nB2_CMFIM1     decimal( 'B2_CM1' )
declare @nB2_CMFIM2     decimal( 'B2_CM2' )
declare @nB2_CMFIM3     decimal( 'B2_CM3' )
declare @nB2_CMFIM4     decimal( 'B2_CM4' )
declare @nB2_CMFIM5     decimal( 'B2_CM5' )

declare @nB2_CMRP1      decimal( 'B2_CM1' )
declare @nB2_CMRP2      decimal( 'B2_CM2' )
declare @nB2_CMRP3      decimal( 'B2_CM3' )
declare @nB2_CMRP4      decimal( 'B2_CM4' )
declare @nB2_CMRP5      decimal( 'B2_CM5' )

declare @nB2_VFRP1      decimal( 'B2_VFIM1' )
declare @nB2_VFRP2      decimal( 'B2_VFIM2' )
declare @nB2_VFRP3      decimal( 'B2_VFIM3' )
declare @nB2_VFRP4      decimal( 'B2_VFIM4' )
declare @nB2_VFRP5      decimal( 'B2_VFIM5' )

declare @nRetAtuComB2   float -- armazena o resultado das funções BJATUCOMB2 e BKATUCOMB2
declare @nSaldoLtUM     decimal( 'B9_QISEGUM' ) --float -- saldo do lote da segunda unidade de medida
declare @dtFech         char(08)

declare @lFatConv       char(01)
declare @cAux           Varchar(3)
declare @nAux           integer
declare @nAux1          integer
declare @cFatConvAux    char(01)
declare @nContador      integer
declare @iTranCount     integer --Var.de ajuste para SQLServer e Sybase. Será trocada por Commit no CFGX051 após passar pelo Parse
declare @cRastro        char(01)
declare @cLocaliza      char(01)
declare @nResult        char(01)
declare @nMod           integer
declare @cB1_CCCUSTO    char('B1_CCCUSTO')
declare @cB1_RASTRO     char('B1_RASTRO')
declare @cB1_LOCALIZ    char('B1_LOCALIZ')

declare @cFilialLogin   char('B1_FILIAL')
declare @cFilialCor     char('B1_FILIAL')
declare @cThread        char(02)

begin

   select @dtFech        = @IN_DATA
   select @lFatConv      = '0'
   select @OUT_RESULTADO = '0'

   /* -------------------------------------------------------------------------
    Evitando Parameter Sniffing
   ------------------------------------------------------------------------- */
   select @cFilialLogin = @IN_FILIALLOGIN
   select @cFilialCor = @IN_FILIALCOR
   select @cThread = @IN_THREAD

   /* ------------------------------------------------------------------------------------------------------------------
      Recupera filiais das tabelas
   ------------------------------------------------------------------------------------------------------------------ */
   select @cAux = 'SB9'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB9 OutPut

   select @nContador = 0

   declare CUR_M280 insensitive cursor for
      select B2_COD,     B2_LOCAL,   B2_SB2RECN, B2_QFIM,    B2_VFIM1,
             B2_VFIM2,   B2_VFIM3,   B2_VFIM4,   B2_VFIM5,   B2_VFIMFF1,
             B2_VFIMFF2, B2_VFIMFF3, B2_VFIMFF4, B2_VFIMFF5, B1_CONV,
             B1_CUSTD,   B1_MCUSTD,  B2_QFIM2,   B2_QACLASS
            ,B2_CMFIM1 , B2_CMFIM2, B2_CMFIM3, B2_CMFIM4, B2_CMFIM5
            ,B2_CMRP1 , B2_CMRP2, B2_CMRP3, B2_CMRP4, B2_CMRP5
            ,B2_VFRP1 , B2_VFRP2, B2_VFRP3, B2_VFRP4, B2_VFRP5
				,B1_CCCUSTO
				,B1_RASTRO
				,B1_LOCALIZ
      from TRB###MATA280 TRB
      where FILIAL = @cFilialCor
         and FILLOG = @cFilialLogin
         and THREAD = @cThread
   for read only

   open CUR_M280

   fetch CUR_M280 into @cB2_COD,     @cB2_LOCAL,   @SB2_RECNO,   @nB2_QFIM,    @nB2_VFIM1,
                       @nB2_VFIM2,   @nB2_VFIM3,   @nB2_VFIM4,   @nB2_VFIM5,   @nB2_VFIMFF1,
                       @nB2_VFIMFF2, @nB2_VFIMFF3, @nB2_VFIMFF4, @nB2_VFIMFF5, @nB1_CONV,
                       @nB1_CUSTD,   @cB1_MCUSTD,  @nB2_QFIM2,   @nB2_QACLASS
                     ,@nB2_CMFIM1, @nB2_CMFIM2, @nB2_CMFIM3, @nB2_CMFIM4, @nB2_CMFIM5
                     ,@nB2_CMRP1 , @nB2_CMRP2, @nB2_CMRP3, @nB2_CMRP4, @nB2_CMRP5
                     ,@nB2_VFRP1 , @nB2_VFRP2, @nB2_VFRP3, @nB2_VFRP4, @nB2_VFRP5
					      ,@cB1_CCCUSTO ,@cB1_RASTRO ,@cB1_LOCALIZ

/* ------------------------------------------------------------------------------------------------------------------
        Atualiza Saldos
   ------------------------------------------------------------------------------------------------------------------ */
   while (@@Fetch_Status = 0) begin
      select @nContador = @nContador + 1
      select @nSaldoLtUM = 0

      If @nContador = 1 begin
         Begin Tran
         select @nContador = @nContador
      End

		/* ------------------------------------------------------------------------------------------------------------------
		  Identifica se o produto é uma MOD (Mão de obra)
		------------------------------------------------------------------------------------------------------------------ */
		select @nMod = 0
		if substring( @cB2_COD,1,3) = 'MOD' begin
			select @nMod = 1
		end else begin
			If @IN_MV_PRODMOD = '1' begin
				if @cB1_CCCUSTO <> ' ' select @nMod = 1
			end
		end

		if @nMod=1 And @IN_MV_PAR04 = 1 begin
         update SB2###
            set B2_QATU  = (B2_QATU - B2_QFIM), B2_QFIM  = 0,
                B2_VATU1 = (B2_QATU * B2_CM1),  B2_VFIM1 = 0,
                B2_VATU2 = (B2_QATU * B2_CM2),  B2_VFIM2 = 0,
                B2_VATU3 = (B2_QATU * B2_CM3),  B2_VFIM3 = 0,
                B2_VATU4 = (B2_QATU * B2_CM4),  B2_VFIM4 = 0,
                B2_VATU5 = (B2_QATU * B2_CM5),  B2_VFIM5 = 0
               ,B2_CMFIM1 = 0, B2_CMFIM2 = 0, B2_CMFIM3 = 0,B2_CMFIM4 = 0, B2_CMFIM5 = 0
               ,B2_CMRP1 = 0 , B2_CMRP2 = 0 , B2_CMRP3 = 0, B2_CMRP4 = 0, B2_CMRP5 = 0
               ,B2_VFRP1 = 0 , B2_VFRP2 = 0, B2_VFRP3 = 0, B2_VFRP4 = 0, B2_VFRP5 = 0
		  where R_E_C_N_O_ = @SB2_RECNO

         /* ---------------------------------------------------------------------------------------------------------
            Atualiza o custo unificado ON-LINE ( B2AtuUnif )
            Parametros utilizados:
            MV_CUSMED - Parametro utilizado para verificar se devera utilizar o custo ON-LINE.
            MV_CUSFIL - Parametro utilizado para verificar se o sistema utiliza custo unificado por:
                       F = Custo Unificado por Filial
                       E = Custo Unificado por Empresa
                       A = Custo Unificado por Armazem
         --------------------------------------------------------------------------------------------------------- */
         if @IN_MV_CUSMED = '1' and ( @IN_MV_CUSFIL = '1' or @IN_MV_CUSEMP  = '1' ) begin
            exec MAT050_## @IN_FILIALCOR, @cB2_COD, @IN_MV_CUSFIL, @IN_MV_MOEDACM, @nResult output
         end

         /* ---------------------------------------------------------------------------------------------------------
            Zerar as variaveis que atualizarao a SB9 - Atualiza saldo atual da MOD
         --------------------------------------------------------------------------------------------------------- */
         select @nB2_QFIM  = 0
         select @nB2_QFIM2 = 0
         select @nB2_VFIM1 = 0
         select @nB2_VFIM2 = 0
         select @nB2_VFIM3 = 0
         select @nB2_VFIM4 = 0
         select @nB2_VFIM5 = 0
      End

		if @nMod=0 or @IN_MV_PAR02 = 1 begin

         select @vRecno = null

         select @vRecno = R_E_C_N_O_
				from SB9### (nolock)
				where B9_FILIAL  = @cFil_SB9
					and B9_COD     = @cB2_COD
					and B9_LOCAL   = @cB2_LOCAL
					and B9_DATA    = @dtFech
					and D_E_L_E_T_ = ' '

         select @lFatConv = '0'

         if @nB1_CONV <> 0 select @lFatConv = '1'

         /* ---------------------------------------------------------------------------------------------------------
            Executa P.E. para verificar se deve usar fator de conversao ou nao
         --------------------------------------------------------------------------------------------------------- */
         select @cFatConvAux = @lFatConv
         exec MA280CON_## @cB2_COD, @cFatConvAux, @lFatConv output
         select @nSaldoLtUM = @nB2_QFIM2

         if @lFatConv = '1' begin
            /* ------------------------------------------------------------------------------------------------------
               Convertendo para segunda unidade de medida
            ------------------------------------------------------------------------------------------------------ */
            select @nAux  = 0
            select @nAux1 = 2

            exec MAT018_## @cB2_COD, @IN_FILIALCOR, @nB2_QFIM, @nAux, @nAux1, @nSaldoLtUM output

            if ( @nSaldoLtUM = 0 and @nB2_QFIM2 <> 0 ) select @nSaldoLtUM = @nB2_QFIM2

         end

         /* ------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
         ------------------------------------------------------------------------------------------------------ */
         SELECT @fim_CUR = 0

         /* -------------------------------------------------------------------------
            Verifica se a rastreabilidade esta em uso
         ------------------------------------------------------------------------- */
         select @cRastro = ' '
         select @cAux = ' '

         select @cRastro = @cB1_RASTRO

         /* -------------------------------------------------------------------------
            Verifica se a localizacao esta em uso
         ------------------------------------------------------------------------- */
         select @cLocaliza = @cB1_LOCALIZ

         /* ------------------------------------------------------------------------------------
            Protecao para evitar divergencia entre saldo por lote/endereco e saldo em estoque
         ------------------------------------------------------------------------------------ */
         If ( @cRastro = '1' OR @cLocaliza = '1' ) AND @nB2_QFIM < 0 AND @IN_300SALNEG = '0' begin
            select @nB2_QFIM  = 0
            select @nB2_QFIM2 = 0
            select @nB2_VFIM1 = 0
            select @nB2_VFIM2 = 0
            select @nB2_VFIM3 = 0
            select @nB2_VFIM4 = 0
            select @nB2_VFIM5 = 0
         End

         if @vRecno is null begin
            /* ---------------------------------------------------------------------------------------------------------
               Obtendo RECNO
            --------------------------------------------------------------------------------------------------------- */
            select @vRecno = Max(R_E_C_N_O_) from SB9### (nolock)

            if @vRecno is null select @vRecno = 1
            else               select @vRecno = @vRecno + 1

            /* ---------------------------------------------------------------------------------------------------------
               Gravando SB9
            --------------------------------------------------------------------------------------------------------- */
            ##TRATARECNO @vRecno\
            insert into SB9### ( B9_FILIAL,    B9_COD,      B9_LOCAL,      B9_DATA,
                                 B9_QINI,      B9_QISEGUM,  B9_VINI1,      B9_VINI2,
                                 B9_VINI3,     B9_VINI4,    B9_VINI5,      B9_VINIFF1,
                                 B9_VINIFF2,   B9_VINIFF3,  B9_VINIFF4,    B9_VINIFF5,
                                 B9_CUSTD,     B9_MCUSTD
                                 ,B9_CM1 , B9_CM2, B9_CM3, B9_CM4, B9_CM5
                                 ,B9_CMRP1 , B9_CMRP2, B9_CMRP3, B9_CMRP4, B9_CMRP5
                                 ,B9_VINIRP1 , B9_VINIRP2, B9_VINIRP3, B9_VINIRP4, B9_VINIRP5
                                 , R_E_C_N_O_ )
                        values ( @cFil_SB9,    @cB2_COD,     @cB2_LOCAL,   @dtFech,
                                 @nB2_QFIM,    @nSaldoLtUM,  @nB2_VFIM1,   @nB2_VFIM2,
                                 @nB2_VFIM3,   @nB2_VFIM4,   @nB2_VFIM5,   @nB2_VFIMFF1,
                                 @nB2_VFIMFF2, @nB2_VFIMFF3, @nB2_VFIMFF4, @nB2_VFIMFF5,
                                 @nB1_CUSTD,   @cB1_MCUSTD
                                 ,@nB2_CMFIM1, @nB2_CMFIM2, @nB2_CMFIM3, @nB2_CMFIM4, @nB2_CMFIM5
                                 ,@nB2_CMRP1 , @nB2_CMRP2, @nB2_CMRP3, @nB2_CMRP4, @nB2_CMRP5
                                 ,@nB2_VFRP1 , @nB2_VFRP2, @nB2_VFRP3, @nB2_VFRP4, @nB2_VFRP5
                                 , @vRecno )
		   	##FIMTRATARECNO
         end else begin
            update SB9###
               set B9_QINI    = @nB2_QFIM ,   B9_QISEGUM = @nSaldoLtUM,  B9_VINI1   = @nB2_VFIM1,
                   B9_VINI2   = @nB2_VFIM2,   B9_VINI3   = @nB2_VFIM3,   B9_VINI4   = @nB2_VFIM4,
                   B9_VINI5   = @nB2_VFIM5,   B9_DATA    = @dtFech,      B9_VINIFF1 = @nB2_VFIMFF1,
                   B9_VINIFF2 = @nB2_VFIMFF2, B9_VINIFF3 = @nB2_VFIMFF3, B9_VINIFF4 = @nB2_VFIMFF4,
                   B9_VINIFF5 = @nB2_VFIMFF5, B9_CUSTD   = @nB1_CUSTD,   B9_MCUSTD  = @cB1_MCUSTD
                  ,B9_CM1 = @nB2_CMFIM1, B9_CM2 = @nB2_CMFIM2, B9_CM3 = @nB2_CMFIM3, B9_CM4 = @nB2_CMFIM4, B9_CM5 = @nB2_CMFIM5
                  ,B9_CMRP1 = @nB2_CMRP1, B9_CMRP2 = @nB2_CMRP2, B9_CMRP3 = @nB2_CMRP3, B9_CMRP4 = @nB2_CMRP4, B9_CMRP5 = @nB2_CMRP5
                  ,B9_VINIRP1 = @nB2_VFRP1, B9_VINIRP2 = @nB2_VFRP2, B9_VINIRP3 = @nB2_VFRP3, B9_VINIRP4 = @nB2_VFRP4, B9_VINIRP5 = @nB2_VFRP5

            where R_E_C_N_O_ = @vRecno
         end
         /* ---------------------------------------------------------------------------------------------------------------
            Gravar os Valores finais no SB2 com o CUSTO EM PARTES.
         --------------------------------------------------------------------------------------------------------------- */
         EXEC MA280INB9CP_## @IN_FILIALCOR , @cB2_COD , @IN_MV_CUSZERO , @vRecno , @SB2_RECNO , @nB2_QFIM , @nB2_VFIM1 ,
                             @nB2_VFIM2 , @nB2_VFIM3 , @nB2_VFIM4 , @nB2_VFIM5

         /* ---------------------------------------------------------------------------------------------------
            Ponto de Entrada para atualizacao do SB9
         --------------------------------------------------------------------------------------------------- */
         exec M280SB9_## @IN_FILIALCOR, @cB2_COD, @cB2_LOCAL

         /* ---------------------------------------------------------------------------------------------------------
            Efetua a gravação no arquivo SBJ - Saldos Iniciais por Lote. Função BJAtuComB2()
         --------------------------------------------------------------------------------------------------------- */
         exec MAT036_## @IN_FILIALCOR, @IN_DATA, @cB2_COD, @cB2_LOCAL, @IN_MV_RASTRO, @IN_MV_ULMES, @IN_300SALNEG, @nB2_QFIM, @nB2_QACLASS, '0', @IN_FILSEQ, @IN_MV_WMSNEW, @nRetAtuComB2 output

		   if @cLocaliza = '1'  begin
            If @IN_MV_WMSNEW = '1'
               begin
                  exec MAT057_## @cB2_COD, @IN_FILIALCOR, @lIntDl output
               end
            else select @lIntDl = '0'
         end
		   /* -------------------------------------------------------------------------------------------------------
			  Deleta movimentação negativa ou zerada
		   ------------------------------------------------------------------------------------------------------- */
         if (@IN_MV_WMSNEW = '1' and @lIntDl = '1') begin
            exec MAT058_## @IN_FILIALCOR, @IN_DATA, @cB2_COD, @cB2_LOCAL, @IN_MV_ULMES, @IN_300SALNEG, @nB2_QFIM, '0', @IN_FILSEQ,@IN_MV_WMSNEW, @IN_MV_ARQPROD, @nRetAtuComB2 output
         end else begin
            /* ---------------------------------------------------------------------------------------------------------
               Efetua a gravação no arquivo SBK - Saldos Iniciais por Localização. Função BKAtuComB2()
            --------------------------------------------------------------------------------------------------------- */
            exec MAT037_## @IN_FILIALCOR, @IN_DATA, @cB2_COD, @cB2_LOCAL, @IN_MV_ULMES, @IN_300SALNEG, @nB2_QFIM, '0', @IN_FILSEQ,@IN_MV_WMSNEW, @IN_MV_ARQPROD, @cRastro, @nRetAtuComB2 output
         end

         If @nContador > 1023 begin
            Commit Transaction
            select @nContador = 0
         End

      end

	   fetch CUR_M280 into @cB2_COD,     @cB2_LOCAL,   @SB2_RECNO,   @nB2_QFIM,    @nB2_VFIM1,
                           @nB2_VFIM2,   @nB2_VFIM3,   @nB2_VFIM4,   @nB2_VFIM5,   @nB2_VFIMFF1,
                           @nB2_VFIMFF2, @nB2_VFIMFF3, @nB2_VFIMFF4, @nB2_VFIMFF5, @nB1_CONV,
                           @nB1_CUSTD,   @cB1_MCUSTD,  @nB2_QFIM2,   @nB2_QACLASS
                           ,@nB2_CMFIM1, @nB2_CMFIM2, @nB2_CMFIM3, @nB2_CMFIM4, @nB2_CMFIM5
                           ,@nB2_CMRP1, @nB2_CMRP2 , @nB2_CMRP3 , @nB2_CMRP4 , @nB2_CMRP5
                           ,@nB2_VFRP1 , @nB2_VFRP2 , @nB2_VFRP3 , @nB2_VFRP4, @nB2_VFRP5
                           ,@cB1_CCCUSTO ,@cB1_RASTRO ,@cB1_LOCALIZ
   end -- end while

   close CUR_M280
   deallocate CUR_M280

   If @nContador > 0 begin
      Commit Tran
      select @iTranCount = 0
   End

   select @OUT_RESULTADO = '1'

end
