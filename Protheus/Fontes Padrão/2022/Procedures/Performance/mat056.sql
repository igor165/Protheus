Create procedure MAT056_##
(
   @IN_FILIALCOR    char('B1_FILIAL'),
   @IN_CCODDE       char('B1_COD'),
   @IN_CCODATE      char('B1_COD'),
   @IN_LOCALDE      char('B2_LOCAL'),
   @IN_LOCALATE     char('B2_LOCAL'),
   @IN_CTIPO        char('B1_TIPO'),
   @IN_MV_LOCPROC   char('B1_LOCPAD'),
   @IN_MV_CQ        char('B2_LOCAL'),
   @IN_MV_WMSNEW    char('B2_LOCAL'),
   @IN_DATAINI      char(08),
   @IN_DATAFIM      char(08),
   @IN_MV_PAR09     char(01),
   @IN_MV_PAR10     char(01),
   @IN_MV_PAR11     char(01),
   @IN_MV_D3SERVI   char(01),
   @IN_INTDL        char(01),
   @IN_MV_PAR12     char(01),
   @OUT_RESULTADO   char(01) Output,
   @OUT_NPASSOU     char(01) Output,
   @OUT_NSALANT     float Output,
   @OUT_NCOMPRAS    float Output,
   @OUT_NREQCONS    float Output,
   @OUT_NREQPROD    float Output,
   @OUT_NREQTRANS   float Output,
   @OUT_NPRODUCAO   float Output,
   @OUT_NVENDAS     float Output,
   @OUT_NREQOUTR    float Output,
   @OUT_NDEVVENDAS  float Output,
   @OUT_NDEVCOMPRS  float Output,
   @OUT_NENTRTERC   float Output,
   @OUT_NSAITERC    float Output,
   @OUT_NSALDOATU   float Output

)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> MATR320 (MATR320) </s>
    Assinatura  -  <a> 002 </a>
    Descricao   -  <d> Montagem dos dados para impressao do relatorio de entradas e saidas </d>
    Entrada     -  <ri>
                   @IN_FILIALCOR    - Filial Corrente
                  </ri>

    Saida          <ro> @OUT_RESULT      - Status da execucao do processo </ro>

    Responsavel :  <r> TOTVS </r>
    Data        :  <dt> 12/06/2013 </dt>

    Estrutura de chamadas
    ========= == ========

    0.MAT056 - Pega valores do inicio do periodo para serem reprocessados
        1.MAT006 - Retorna o Saldo do Produto/Local do arquivo SB9 - Saldos Iniciais

--------------------------------------------------------------------------------------------------------------------- */
declare @cFil_SB1      char('B1_FILIAL')
declare @cFil_SB2      char('B2_FILIAL')
declare @cFil_SD1      char('D1_FILIAL')
declare @cFil_SD2      char('D2_FILIAL')
declare @cFil_SD3      char('D3_FILIAL')
declare @cFil_SF4      char('F4_FILIAL')
declare @cB1Cod        char('B1_COD'   )
declare @cLocal        char('B1_LOCPAD')
declare @cB2Cod        char('B2_COD'   )
declare @cB2Local      char('B1_LOCPAD')
declare @cLocProc      char('B1_LOCPAD')
declare @cTipo         char('B1_TIPO'  )
declare @nVINIRP1      decimal( 'B2_VFIM1' )
declare @nVINIRP2      decimal( 'B2_VFIM2' )
declare @nVINIRP3      decimal( 'B2_VFIM3' )
declare @nVINIRP4      decimal( 'B2_VFIM4' )
declare @nVINIRP5      decimal( 'B2_VFIM5' )
declare @nCM1          decimal( 'B2_CM1' )
declare @nCM2          decimal( 'B2_CM2' )
declare @nCM3          decimal( 'B2_CM3' )
declare @nCM4          decimal( 'B2_CM4' )
declare @nCM5          decimal( 'B2_CM5' )
declare @nCMRP1        decimal( 'B2_CM1' )
declare @nCMRP2        decimal( 'B2_CM2' )
declare @nCMRP3        decimal( 'B2_CM3' )
declare @nCMRP4        decimal( 'B2_CM4' )
declare @nCMRP5        decimal( 'B2_CM5' )
declare @nB2VATU1      decimal( 'B2_VATU1' )
declare @nB2VATU2      decimal( 'B2_VATU2' )
declare @nB2VATU3      decimal( 'B2_VATU3' )
declare @nB2VATU4      decimal( 'B2_VATU4' )
declare @nB2VATU5      decimal( 'B2_VATU5' )
declare @nB2VFIM1      decimal( 'B2_VFIM1' )
declare @nB2VFIM2      decimal( 'B2_VFIM2' )
declare @nB2VFIM3      decimal( 'B2_VFIM3' )
declare @nB2VFIM4      decimal( 'B2_VFIM4' )
declare @nB2VFIM5      decimal( 'B2_VFIM5' )
declare @cAux          varchar(03)
declare @OutResult     varchar(01)
declare @nPassou       varchar(01)
declare @cB1_CC        char(01)
declare @nSaldoAtu     float
declare @nSaldo01      float
declare @nSaldo02      float
declare @nSaldo03      float
declare @nSaldo04      float
declare @nSaldo05      float
declare @nSaldo06      float
declare @nSaldo07      float
declare @nCompras      float
declare @nReqProd      float
declare @nReqCons      float
declare @nReqMNT       float
declare @nProducao     float
declare @nVendas       float
declare @nReqTrans     float
declare @nReqOutr      float
declare @nReqProc      float
declare @nDevProc      float
declare @nDevVendas    float
declare @nDevComprs    float
declare @nEntrTerc     float
declare @nSaiTerc      float
declare @nCusto1       float
declare @nCusto2       float
declare @nCusto3       float
declare @nCusto4       float
declare @nCusto5       float
declare @nCusReq1       float
declare @nCusReq2       float
declare @nCusReq3       float
declare @nCusReq4       float
declare @nCusReq5       float

begin
/* --------------------------------------------------------------------------------------------
   Define inicio do processo
  -------------------------------------------------------------------------------------------- */
   select @nSaldoAtu  = 0
   select @nSaldo01   = 0
   select @nSaldo02   = 0
   select @nSaldo03   = 0
   select @nSaldo04   = 0
   select @nSaldo05   = 0
   select @nSaldo06   = 0
   select @nSaldo07   = 0
   select @nCompras   = 0
   select @nReqProd   = 0
   select @nReqCons   = 0
   select @nProducao  = 0
   select @nVendas    = 0
   select @nReqTrans  = 0
   select @nReqOutr   = 0
   select @nReqProc	 = 0
   select @nDevProc   = 0
   select @nReqMNT    = 0
   select @nDevVendas = 0
   select @nDevComprs = 0
   select @nEntrTerc  = 0
   select @nSaiTerc   = 0
   select @cLocProc   = '0'
   select @nPassou    = '0'
   select @OUT_RESULTADO = '0'
   select @cB1_CC        = '0'
   select @cAux = 'SB1'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB1 OutPut
   select @cAux = 'SB2'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB2 OutPut
   select @cAux = 'SD1'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD1 OutPut
   select @cAux = 'SD2'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD2 OutPut
   select @cAux = 'SD3'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD3 OutPut
   select @cAux = 'SF4'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SF4 OutPut

   If @IN_MV_PAR10 = '1' begin

      select @nSaldo02 = isnull(SUM(B2_VATU1),0), @nSaldo03 = isnull(SUM(B2_VATU2),0), @nSaldo04 = isnull(SUM(B2_VATU3),0),
             @nSaldo05 = isnull(SUM(B2_VATU4),0), @nSaldo06 = isnull(SUM(B2_VATU5),0)
        from SB2### SB2, SB1### SB1
       where SB2.B2_FILIAL  = @cFil_SB2
         and SB2.B2_COD    >= @IN_CCODDE
         and SB2.B2_COD    <= @IN_CCODATE
         and SB2.B2_LOCAL  >= @IN_LOCALDE
         and SB2.B2_LOCAL  <= @IN_LOCALATE
         and SB2.D_E_L_E_T_ = ' '
         and SB1.B1_FILIAL  = @cFil_SB1
         and SB1.B1_COD     = SB2.B2_COD
         and SB1.B1_TIPO    = @IN_CTIPO
         and SB1.D_E_L_E_T_ = ' '

      select @nSaldo02 = isnull(@nSaldo02,0)
      select @nSaldo03 = isnull(@nSaldo03,0)
      select @nSaldo04 = isnull(@nSaldo04,0)
      select @nSaldo05 = isnull(@nSaldo05,0)
      select @nSaldo06 = isnull(@nSaldo06,0)

	  If @IN_MV_PAR09 = '1' begin
	     Select @nSaldoAtu = @nSaldoAtu + @nSaldo02
   	  end else If @IN_MV_PAR09 = '2' begin
	     Select @nSaldoAtu = @nSaldoAtu + @nSaldo03
	  end else If @IN_MV_PAR09 = '3' begin          
	     Select @nSaldoAtu = @nSaldoAtu + @nSaldo04
 	  end else If @IN_MV_PAR09 = '4' begin
	     Select @nSaldoAtu = @nSaldoAtu + @nSaldo05
	  end else If @IN_MV_PAR09 = '5' begin
	     Select @nSaldoAtu = @nSaldoAtu + @nSaldo06
	  end	

      If @IN_MV_LOCPROC >= @IN_LOCALDE and @IN_MV_LOCPROC <= @IN_LOCALATE begin
         Select @cLocProc = '1'
      End

      If @nSaldoAtu > 0 begin
         Select @nPassou = '1'
      End
         
   end else If @IN_MV_PAR10 = '2' begin
   
      select @nSaldo02 = isnull(SUM(B2_VFIM1),0), @nSaldo03 = isnull(SUM(B2_VFIM2),0), @nSaldo04 = isnull(SUM(B2_VFIM3),0),
             @nSaldo05 = isnull(SUM(B2_VFIM4),0), @nSaldo06 = isnull(SUM(B2_VFIM5),0)
        from SB2### SB2, SB1### SB1
       where SB2.B2_FILIAL  = @cFil_SB2
         and SB2.B2_COD    >= @IN_CCODDE
         and SB2.B2_COD    <= @IN_CCODATE
         and SB2.B2_LOCAL  >= @IN_LOCALDE
         and SB2.B2_LOCAL  <= @IN_LOCALATE
         and SB2.D_E_L_E_T_ = ' '
         and SB1.B1_FILIAL  = @cFil_SB1
         and SB2.B2_COD     = SB1.B1_COD
         and SB1.B1_TIPO    = @IN_CTIPO
         and SB1.D_E_L_E_T_ = ' '

      select @nSaldo02 = isnull(@nSaldo02,0)
      select @nSaldo03 = isnull(@nSaldo03,0)
      select @nSaldo04 = isnull(@nSaldo04,0)
      select @nSaldo05 = isnull(@nSaldo05,0)
      select @nSaldo06 = isnull(@nSaldo06,0)

	  If @IN_MV_PAR09 = '1' begin
	     Select @nSaldoAtu = @nSaldoAtu + @nSaldo02
   	  end else If @IN_MV_PAR09 = '2' begin
	     Select @nSaldoAtu = @nSaldoAtu + @nSaldo03
	  end else If @IN_MV_PAR09 = '3' begin          
	     Select @nSaldoAtu = @nSaldoAtu + @nSaldo04
 	  end else If @IN_MV_PAR09 = '4' begin
	     Select @nSaldoAtu = @nSaldoAtu + @nSaldo05
	  end else If @IN_MV_PAR09 = '5' begin
	     Select @nSaldoAtu = @nSaldoAtu + @nSaldo06
	  end	

      If @IN_MV_LOCPROC >= @IN_LOCALDE and @IN_MV_LOCPROC <= @IN_LOCALATE begin
         Select @cLocProc = '1'
      End

      If @nSaldoAtu > 0 begin
         Select @nPassou = '1'
      End

   end else If @IN_MV_PAR10 = '3' begin

   /* -------------------------------------------------------------------------
       Cursor no SB1 Selecionando todos produtos de acordo filial corrente
      ------------------------------------------------------------------------- */
      declare CUR_SB1 INSENSITIVE cursor for
       select B1_FILIAL, B1_COD, B1_TIPO
         from SB1###
        where B1_FILIAL   = @cFil_SB1
          and B1_COD     >= @IN_CCODDE
          and B1_COD     <= @IN_CCODATE
          and B1_TIPO     = @IN_CTIPO
          and D_E_L_E_T_  = ' '
       order by B1_TIPO, B1_COD
       for read only
       open  CUR_SB1
       fetch CUR_SB1 into @cFil_SB1,  @cB1Cod, @cTipo   

       while (@@fetch_status = 0) begin

          /* ------------------------------------------------------------------------------------------------------------
              Saldo final e inicial dos almoxarifados
             ------------------------------------------------------------------------------------------------------------- */
	         declare CUR_SB2 INSENSITIVE cursor for
	         select B2_FILIAL, B2_COD, B2_LOCAL, B2_VATU1, B2_VATU2, B2_VATU3, B2_VATU4, B2_VATU5, B2_VFIM1, B2_VFIM2, B2_VFIM3, B2_VFIM4, B2_VFIM5
	           from SB2###
	          where B2_FILIAL   = @cFil_SB2
	            and B2_COD      = @cB1Cod
	            and B2_LOCAL   >= @IN_LOCALDE
	            and B2_LOCAL   <= @IN_LOCALATE
	            and D_E_L_E_T_  = ' '
	         order by B2_FILIAL, B2_COD, B2_LOCAL
	         for read only
	         open  CUR_SB2
	         fetch CUR_SB2 into @cFil_SB2,  @cB2Cod, @cB2Local,@nB2VATU1,@nB2VATU2,@nB2VATU3,@nB2VATU4,@nB2VATU5,@nB2VFIM1,@nB2VFIM2,@nB2VFIM3,@nB2VFIM4,@nB2VFIM5
	         
	         while (@@fetch_status = 0) begin
	
               /* ---------------------------------------------------------------------------------------------------------------
	                 Verifica se utiliza mao-de-obra atraves do campo B1_CCCUSTO
	              --------------------------------------------------------------------------------------------------------------- */
	             select @cB1_CC = '0'
	    
	             select @cB1_CC = '1' 
	              from SB1### 
	             where B1_FILIAL   = @cFil_SB1 
	               and B1_COD      = @cB2Cod 
	               and D_E_L_E_T_  = ' '
	               and B1_CCCUSTO <> ' '
	
			     If	@IN_MV_PAR11 = '2' and ( substring(@cB2Cod, 1, 3) = 'MOD' or isnull(@cB1_CC, '0') = '1' ) begin
	
	                select @cB1_CC = '0'
	
				 end else begin
	
				   If @IN_MV_PAR10 = '3' begin
	
                     /* ------------------------------------------------------------------------------------------------------------
	                       Recupera Saldos Iniciais SB9, SD1 ,SD2 e SD3 pela funcao CalcEst() 
	                    ------------------------------------------------------------------------------------------------------------- */
	                    exec MAT006_## 	@cB2Cod,			@cB2Local,			@IN_DATAFIM,			'  ',
	                    				@IN_MV_LOCPROC,		@IN_FILIALCOR,		@IN_MV_D3SERVI,			@IN_INTDL,
	                    				@IN_MV_CQ,			@IN_MV_WMSNEW,      '0',		
										@nSaldo01    output, @nSaldo02    output, @nSaldo03    output, @nSaldo04    output, 
										@nSaldo05    output, @nSaldo06    output, @nSaldo07    output, @nCM1        output, 
										@nCM2        output, @nCM3        output, @nCM4        output, @nCM5        output,
										@nCMRP1      output, @nCMRP2      output, @nCMRP3      output, @nCMRP4      output,
										@nCMRP5      output, @nVINIRP1    output, @nVINIRP2    output, @nVINIRP3    output,
										@nVINIRP4    output, @nVINIRP5    output
						If @IN_MV_PAR09 = '1' begin
						   Select @nSaldoAtu = @nSaldoAtu + @nSaldo02
						end	else If @IN_MV_PAR09 = '2' begin
						   Select @nSaldoAtu = @nSaldoAtu + @nSaldo03
						end	else If @IN_MV_PAR09 = '3' begin          
						   Select @nSaldoAtu = @nSaldoAtu + @nSaldo04
						end	else If @IN_MV_PAR09 = '4' begin
						   Select @nSaldoAtu = @nSaldoAtu + @nSaldo05
						end	else If @IN_MV_PAR09 = '5' begin
						   Select @nSaldoAtu = @nSaldoAtu + @nSaldo06
						end	

                  If @cB2Local = @IN_MV_LOCPROC begin
                     Select @cLocProc = '1'
                  End

					end
					
			     end	
	
              /* --------------------------------------------------------------------------------------------------------------
	                Tratamento para o DB2
	             -------------------------------------------------------------------------------------------------------------- */
	             SELECT @fim_CUR = 0
	             fetch CUR_SB2 into @cFil_SB2,  @cB2Cod, @cB2Local,@nB2VATU1,@nB2VATU2,@nB2VATU3,@nB2VATU4,@nB2VATU5,@nB2VFIM1,@nB2VFIM2,@nB2VFIM3,@nB2VFIM4,@nB2VFIM5

	         end
	         close      CUR_SB2
	         deallocate CUR_SB2

			 select @cAux = 'SB2'
			 EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB2 OutPut

			 /* Tratamento para forçar fetch_status para zero em postgres */
			 declare CUR_RESET INSENSITIVE cursor for
	         select B2_COD from SB2###
	          where B2_FILIAL   = @cFil_SB2
	            and B2_COD      = @cB1Cod
	         for read only
	         open		CUR_RESET
	         close      CUR_RESET
	         deallocate CUR_RESET
			 	         
           /* --------------------------------------------------------------------------------------------------------------
                Tratamento para o DB2
             -------------------------------------------------------------------------------------------------------------- */
			 SELECT @fim_CUR = 0
	         fetch CUR_SB1 into @cFil_SB1,  @cB1Cod, @cTipo   
       end
      
       If @nSaldoAtu > 0 begin
          Select @nPassou = '1'
       End

      /* --------------------------------------------------------------------------------------------------------------
         Tratamento especifico na procedure MAT007 para os bancos ORACLE/DB2.
         Ajuste necessario devido a falha do CURSOR apos o termino do mesmo, ou seja,
         apos o termino a variavel do cursor mantem o seu conteudo.
        -------------------------------------------------------------------------------------------------------------- */
        ##IF_001({|| Trim(TcGetDb()) == "ORACLE" .Or. Trim(TcGetDb()) == "DB2"})
        if @@fetch_status = -1 select @cB1Cod = ' '
		##ENDIF_001

        close      CUR_SB1
        deallocate CUR_SB1

   end
   
   select @cAux = 'SB1'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB1 OutPut
   select @cAux = 'SB2'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB2 OutPut

/* --------------------------------------------------------------------------------------------------------------
      SD1 - Pesquisa as Entradas de um determinado produto
   -------------------------------------------------------------------------------------------------------------- */
 /* --------------------------------------------------------------------------------------------------------------
      Devolucao de Vendas
   -------------------------------------------------------------------------------------------------------------- */
   select @nCusto1 = isnull(SUM(D1_CUSTO) ,0), @nCusto2 = isnull(SUM(D1_CUSTO2),0), @nCusto3 = isnull(SUM(D1_CUSTO3),0),
          @nCusto4 = isnull(SUM(D1_CUSTO4),0), @nCusto5 = isnull(SUM(D1_CUSTO5),0)
     from SD1### SD1, SF4### SF4, SB1### SB1
    where SD1.D1_FILIAL  = @cFil_SD1
      and SD1.D1_COD    >= @IN_CCODDE
      and SD1.D1_COD    <= @IN_CCODATE
      and SD1.D1_LOCAL  >= @IN_LOCALDE
      and SD1.D1_LOCAL  <= @IN_LOCALATE
      and SD1.D1_DTDIGIT>= @IN_DATAINI
      and SD1.D1_DTDIGIT < @IN_DATAFIM
      and SF4.F4_FILIAL  = @cFil_SF4
      and SF4.F4_CODIGO  = SD1.D1_TES
      and SF4.F4_ESTOQUE = 'S'
      and SF4.F4_PODER3  IN (' ','N')
      and SF4.D_E_L_E_T_ = ' '
      and SD1.D1_TIPO    = 'D'
      and SD1.D1_ORIGLAN <> 'LF'
      and SD1.D1_REMITO  = '         '
      and SD1.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD1.D1_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

      select @nCusto1 = isnull(@nCusto1,0)
      select @nCusto2 = isnull(@nCusto2,0)
      select @nCusto3 = isnull(@nCusto3,0)
      select @nCusto4 = isnull(@nCusto4,0)
      select @nCusto5 = isnull(@nCusto5,0)

      If @IN_MV_PAR09 = '1' begin
         Select @nDevVendas = @nCusto1
	  end else If @IN_MV_PAR09 = '2' begin
	     Select @nDevVendas = @nCusto2
      end else If @IN_MV_PAR09 = '3' begin          
         Select @nDevVendas = @nCusto3
      end else If @IN_MV_PAR09 = '4' begin
         Select @nDevVendas = @nCusto4
      end else If @IN_MV_PAR09 = '5' begin
         Select @nDevVendas = @nCusto5
      end	

      If @nDevVendas <> 0 begin
         Select @nPassou = '1'
      End

/* --------------------------------------------------------------------------------------------------------------
      Compras
   -------------------------------------------------------------------------------------------------------------- */
   select @nCusto1 = isnull(SUM(D1_CUSTO) ,0), @nCusto2 = isnull(SUM(D1_CUSTO2),0), @nCusto3 = isnull(SUM(D1_CUSTO3),0),
          @nCusto4 = isnull(SUM(D1_CUSTO4),0), @nCusto5 = isnull(SUM(D1_CUSTO5),0)
     from SD1### SD1, SF4### SF4, SB1### SB1
    where SD1.D1_FILIAL  = @cFil_SD1
      and SD1.D1_COD    >= @IN_CCODDE
      and SD1.D1_COD    <= @IN_CCODATE
      and SD1.D1_LOCAL  >= @IN_LOCALDE
      and SD1.D1_LOCAL  <= @IN_LOCALATE
      and SD1.D1_DTDIGIT>= @IN_DATAINI
      and SD1.D1_DTDIGIT < @IN_DATAFIM
      and SF4.F4_FILIAL  = @cFil_SF4
      and SD1.D1_TES     = SF4.F4_CODIGO
      and SF4.F4_ESTOQUE = 'S'
      and SF4.F4_PODER3  IN (' ','N')
      and SD1.D1_TIPO    <> 'D'
      and SD1.D1_ORIGLAN <> 'LF'
      and SD1.D1_REMITO  = '         '
      and SD1.D_E_L_E_T_ = ' '
      and SF4.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD1.D1_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '
      
   select @nCusto1 = isnull(@nCusto1,0)
   select @nCusto2 = isnull(@nCusto2,0)
   select @nCusto3 = isnull(@nCusto3,0)
   select @nCusto4 = isnull(@nCusto4,0)
   select @nCusto5 = isnull(@nCusto5,0)

   If @IN_MV_PAR09 = '1' begin
      Select @nCompras = @nCusto1
   end else If @IN_MV_PAR09 = '2' begin
      Select @nCompras = @nCusto2
   end else If @IN_MV_PAR09 = '3' begin          
      Select @nCompras = @nCusto3
   end else If @IN_MV_PAR09 = '4' begin
      Select @nCompras = @nCusto4
   end else If @IN_MV_PAR09 = '5' begin
      Select @nCompras = @nCusto5
   end	

   If @nCompras <> 0 begin
      Select @nPassou = '1'
   End

 /* --------------------------------------------------------------------------------------------------------------
      Entrada de Terceiros
   -------------------------------------------------------------------------------------------------------------- */
   select @nCusto1 = isnull(SUM(D1_CUSTO) ,0), @nCusto2 = isnull(SUM(D1_CUSTO2),0), @nCusto3 = isnull(SUM(D1_CUSTO3),0),
          @nCusto4 = isnull(SUM(D1_CUSTO4),0), @nCusto5 = isnull(SUM(D1_CUSTO5),0)
     from SD1### SD1, SF4### SF4, SB1### SB1
    where SD1.D1_FILIAL  = @cFil_SD1
      and SD1.D1_COD    >= @IN_CCODDE
      and SD1.D1_COD    <= @IN_CCODATE
      and SD1.D1_LOCAL  >= @IN_LOCALDE
      and SD1.D1_LOCAL  <= @IN_LOCALATE
      and SD1.D1_DTDIGIT>= @IN_DATAINI
      and SD1.D1_DTDIGIT < @IN_DATAFIM
      and SF4.F4_FILIAL  = @cFil_SF4
      and SD1.D1_TES     = SF4.F4_CODIGO
      and SF4.F4_ESTOQUE = 'S'
      and SF4.F4_PODER3  IN ('D','R')
      and SD1.D1_ORIGLAN <> 'LF'
      and SD1.D1_REMITO  = '         '
      and SD1.D_E_L_E_T_ = ' '
      and SF4.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD1.D1_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusto1 = isnull(@nCusto1,0)
   select @nCusto2 = isnull(@nCusto2,0)
   select @nCusto3 = isnull(@nCusto3,0)
   select @nCusto4 = isnull(@nCusto4,0)
   select @nCusto5 = isnull(@nCusto5,0)

   If @IN_MV_PAR09 = '1' begin
      Select @nEntrTerc = @nCusto1
   end else If @IN_MV_PAR09 = '2' begin
      Select @nEntrTerc = @nCusto2
   end else If @IN_MV_PAR09 = '3' begin          
      Select @nEntrTerc = @nCusto3
   end else If @IN_MV_PAR09 = '4' begin
      Select @nEntrTerc = @nCusto4
   end else If @IN_MV_PAR09 = '5' begin
      Select @nEntrTerc = @nCusto5
   end	

   If @nEntrTerc <> 0 begin
      Select @nPassou = '1'
   End

/* --------------------------------------------------------------------------------------------------------------
      SD2 - Pesquisa Vendas
   -------------------------------------------------------------------------------------------------------------- */
/* --------------------------------------------------------------------------------------------------------------
      Devolucao de Compras
   -------------------------------------------------------------------------------------------------------------- */
   select @nCusto1 = isnull(SUM(D2_CUSTO1),0), @nCusto2 = isnull(SUM(D2_CUSTO2),0), @nCusto3 = isnull(SUM(D2_CUSTO3),0),
          @nCusto4 = isnull(SUM(D2_CUSTO4),0), @nCusto5 = isnull(SUM(D2_CUSTO5),0)
     from SD2### SD2, SF4### SF4, SB1### SB1
    where SD2.D2_FILIAL  = @cFil_SD2
      and SD2.D2_COD    >= @IN_CCODDE
      and SD2.D2_COD    <= @IN_CCODATE
      and SD2.D2_LOCAL  >= @IN_LOCALDE
      and SD2.D2_LOCAL  <= @IN_LOCALATE
      and SD2.D2_EMISSAO>= @IN_DATAINI
      and SD2.D2_EMISSAO < @IN_DATAFIM
      and SF4.F4_FILIAL  = @cFil_SF4
      and SD2.D2_TES     = SF4.F4_CODIGO
      and SF4.F4_ESTOQUE = 'S'
      and SF4.F4_PODER3  IN (' ','N')
      and SD2.D2_TIPO    = 'D'
      and SD2.D2_ORIGLAN <> 'LF'
      and SD2.D2_REMITO  = '         '
      and SD2.D_E_L_E_T_ = ' '
      and SF4.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD2.D2_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusto1 = isnull(@nCusto1,0)
   select @nCusto2 = isnull(@nCusto2,0)
   select @nCusto3 = isnull(@nCusto3,0)
   select @nCusto4 = isnull(@nCusto4,0)
   select @nCusto5 = isnull(@nCusto5,0)

   If @IN_MV_PAR09 = '1' begin
      Select @nDevComprs = @nCusto1
   end else If @IN_MV_PAR09 = '2' begin
      Select @nDevComprs = @nCusto2
   end else If @IN_MV_PAR09 = '3' begin          
      Select @nDevComprs = @nCusto3
   end else If @IN_MV_PAR09 = '4' begin
      Select @nDevComprs = @nCusto4
   end else If @IN_MV_PAR09 = '5' begin
      Select @nDevComprs = @nCusto5
   end	

   If @nDevComprs <> 0 begin
      Select @nPassou = '1'
   End

/* --------------------------------------------------------------------------------------------------------------
   Vendas
   -------------------------------------------------------------------------------------------------------------- */
   select @nCusto1 = isnull(SUM(D2_CUSTO1),0), @nCusto2 = isnull(SUM(D2_CUSTO2),0), @nCusto3 = isnull(SUM(D2_CUSTO3),0),
          @nCusto4 = isnull(SUM(D2_CUSTO4),0), @nCusto5 = isnull(SUM(D2_CUSTO5),0)
     from SD2### SD2, SF4### SF4, SB1### SB1
    where SD2.D2_FILIAL  = @cFil_SD2
      and SD2.D2_COD    >= @IN_CCODDE
      and SD2.D2_COD    <= @IN_CCODATE
      and SD2.D2_LOCAL  >= @IN_LOCALDE
      and SD2.D2_LOCAL  <= @IN_LOCALATE
      and SD2.D2_EMISSAO>= @IN_DATAINI
      and SD2.D2_EMISSAO < @IN_DATAFIM
      and SF4.F4_FILIAL  = @cFil_SF4
      and SD2.D2_TES     = SF4.F4_CODIGO
      and SF4.F4_ESTOQUE = 'S'
      and SF4.F4_PODER3  IN (' ','N')
      and SD2.D2_TIPO    <> 'D'
      and SD2.D2_ORIGLAN <> 'LF'
      and SD2.D2_REMITO  = '         '
      and SD2.D_E_L_E_T_ = ' '
      and SF4.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD2.D2_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusto1 = isnull(@nCusto1,0)
   select @nCusto2 = isnull(@nCusto2,0)
   select @nCusto3 = isnull(@nCusto3,0)
   select @nCusto4 = isnull(@nCusto4,0)
   select @nCusto5 = isnull(@nCusto5,0)

   If @IN_MV_PAR09 = '1' begin
      Select @nVendas = @nCusto1
   end else If @IN_MV_PAR09 = '2' begin
      Select @nVendas = @nCusto2
   end else If @IN_MV_PAR09 = '3' begin          
      Select @nVendas = @nCusto3
   end else If @IN_MV_PAR09 = '4' begin
      Select @nVendas = @nCusto4
   end else If @IN_MV_PAR09 = '5' begin
      Select @nVendas = @nCusto5
   end	

   If @nVendas <> 0 begin
      Select @nPassou = '1'
   End

/* --------------------------------------------------------------------------------------------------------------
      Entrada de Terceiros
   -------------------------------------------------------------------------------------------------------------- */
   select @nCusto1 = isnull(SUM(D2_CUSTO1),0), @nCusto2 = isnull(SUM(D2_CUSTO2),0), @nCusto3 = isnull(SUM(D2_CUSTO3),0),
          @nCusto4 = isnull(SUM(D2_CUSTO4),0), @nCusto5 = isnull(SUM(D2_CUSTO5),0)
     from SD2### SD2, SF4### SF4, SB1### SB1
    where SD2.D2_FILIAL  = @cFil_SD2
      and SD2.D2_COD    >= @IN_CCODDE
      and SD2.D2_COD    <= @IN_CCODATE
      and SD2.D2_LOCAL  >= @IN_LOCALDE
      and SD2.D2_LOCAL  <= @IN_LOCALATE
      and SD2.D2_EMISSAO>= @IN_DATAINI
      and SD2.D2_EMISSAO < @IN_DATAFIM
      and SF4.F4_FILIAL  = @cFil_SF4
      and SD2.D2_TES     = SF4.F4_CODIGO
      and SF4.F4_ESTOQUE = 'S'
      and SF4.F4_PODER3  IN ('D','R')
      and SD2.D2_ORIGLAN <> 'LF'
      and SD2.D2_REMITO  = '         '
      and SD2.D_E_L_E_T_ = ' '
      and SF4.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD2.D2_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusto1 = isnull(@nCusto1,0)
   select @nCusto2 = isnull(@nCusto2,0)
   select @nCusto3 = isnull(@nCusto3,0)
   select @nCusto4 = isnull(@nCusto4,0)
   select @nCusto5 = isnull(@nCusto5,0)

   If @IN_MV_PAR09 = '1' begin
      Select @nSaiTerc = @nCusto1
   end else If @IN_MV_PAR09 = '2' begin
      Select @nSaiTerc = @nCusto2
   end else If @IN_MV_PAR09 = '3' begin          
      Select @nSaiTerc = @nCusto3
   end else If @IN_MV_PAR09 = '4' begin
      Select @nSaiTerc = @nCusto4
   end else If @IN_MV_PAR09 = '5' begin
      Select @nSaiTerc = @nCusto5
   end	

   If @nSaiTerc <> 0 begin
      Select @nPassou = '1'
   End

/* --------------------------------------------------------------------------------------------------------------
      SD3 - Pesquisa requisicoes		
   -------------------------------------------------------------------------------------------------------------- */
/* --------------------------------------------------------------------------------------------------------------
      Movimentos Internos de Producao (PR0/PR1)
   -------------------------------------------------------------------------------------------------------------- */
   select @nCusto1 = isnull(SUM(D3_CUSTO1),0), @nCusto2 = isnull(SUM(D3_CUSTO2),0), @nCusto3 = isnull(SUM(D3_CUSTO3),0),
          @nCusto4 = isnull(SUM(D3_CUSTO4),0), @nCusto5 = isnull(SUM(D3_CUSTO5),0)
     from SD3### SD3, SB1### SB1
    where SD3.D3_FILIAL  = @cFil_SD3
      and SD3.D3_COD    >= @IN_CCODDE
      and SD3.D3_COD    <= @IN_CCODATE
      and SD3.D3_LOCAL  >= @IN_LOCALDE
      and SD3.D3_LOCAL  <= @IN_LOCALATE
      and SD3.D3_EMISSAO>= @IN_DATAINI
      and SD3.D3_EMISSAO < @IN_DATAFIM
      and SD3.D3_ESTORNO <> 'S'
      and SD3.D3_CF      IN ('PR0','PR1')
      and SD3.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD3.D3_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusto1 = isnull(@nCusto1,0)
   select @nCusto2 = isnull(@nCusto2,0)
   select @nCusto3 = isnull(@nCusto3,0)
   select @nCusto4 = isnull(@nCusto4,0)
   select @nCusto5 = isnull(@nCusto5,0)

   If @IN_MV_PAR09 = '1' begin
      Select @nProducao = @nCusto1
   end else If @IN_MV_PAR09 = '2' begin
      Select @nProducao = @nCusto2
   end else If @IN_MV_PAR09 = '3' begin          
      Select @nProducao = @nCusto3
   end else If @IN_MV_PAR09 = '4' begin
      Select @nProducao = @nCusto4
   end else If @IN_MV_PAR09 = '5' begin
      Select @nProducao = @nCusto5
   end	

   If @nProducao <> 0 begin
      Select @nPassou = '1'
   End

/* --------------------------------------------------------------------------------------------------------------
      Movimentos Internos de Transferencia (DE4)
   -------------------------------------------------------------------------------------------------------------- */
   select @nCusto1 = isnull(SUM(D3_CUSTO1),0), @nCusto2 = isnull(SUM(D3_CUSTO2),0), @nCusto3 = isnull(SUM(D3_CUSTO3),0),
          @nCusto4 = isnull(SUM(D3_CUSTO4),0), @nCusto5 = isnull(SUM(D3_CUSTO5),0)
     from SD3### SD3, SB1### SB1
    where SD3.D3_FILIAL  = @cFil_SD3
      and SD3.D3_COD    >= @IN_CCODDE
      and SD3.D3_COD    <= @IN_CCODATE
      and SD3.D3_LOCAL  >= @IN_LOCALDE
      and SD3.D3_LOCAL  <= @IN_LOCALATE
      and SD3.D3_EMISSAO>= @IN_DATAINI
      and SD3.D3_EMISSAO < @IN_DATAFIM
      and SD3.D3_ESTORNO <> 'S'
      and SD3.D3_CF      = 'DE4'
      and SD3.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD3.D3_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusto1 = isnull(@nCusto1,0)
   select @nCusto2 = isnull(@nCusto2,0)
   select @nCusto3 = isnull(@nCusto3,0)
   select @nCusto4 = isnull(@nCusto4,0)
   select @nCusto5 = isnull(@nCusto5,0)

   If @IN_MV_PAR09 = '1' begin
      Select @nReqTrans = @nCusto1
   end else If @IN_MV_PAR09 = '2' begin
      Select @nReqTrans = @nCusto2
   end else If @IN_MV_PAR09 = '3' begin          
      Select @nReqTrans = @nCusto3
   end else If @IN_MV_PAR09 = '4' begin
      Select @nReqTrans = @nCusto4
   end else If @IN_MV_PAR09 = '5' begin
      Select @nReqTrans = @nCusto5
   end	

   If @nReqTrans <> 0 begin
      Select @nPassou = '1'
   End

/* --------------------------------------------------------------------------------------------------------------
      Movimentos Internos de Transferencia (RE4)
   -------------------------------------------------------------------------------------------------------------- */
   select @nCusto1 = isnull(SUM(D3_CUSTO1),0), @nCusto2 = isnull(SUM(D3_CUSTO2),0), @nCusto3 = isnull(SUM(D3_CUSTO3),0),
          @nCusto4 = isnull(SUM(D3_CUSTO4),0), @nCusto5 = isnull(SUM(D3_CUSTO5),0)
     from SD3### SD3, SB1### SB1
    where SD3.D3_FILIAL  = @cFil_SD3
      and SD3.D3_COD    >= @IN_CCODDE
      and SD3.D3_COD    <= @IN_CCODATE
      and SD3.D3_LOCAL  >= @IN_LOCALDE
      and SD3.D3_LOCAL  <= @IN_LOCALATE
      and SD3.D3_EMISSAO>= @IN_DATAINI
      and SD3.D3_EMISSAO < @IN_DATAFIM
      and SD3.D3_ESTORNO <> 'S'
      and SD3.D3_CF      = 'RE4'
      and SD3.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD3.D3_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusto1 = isnull(@nCusto1,0)
   select @nCusto2 = isnull(@nCusto2,0)
   select @nCusto3 = isnull(@nCusto3,0)
   select @nCusto4 = isnull(@nCusto4,0)
   select @nCusto5 = isnull(@nCusto5,0)

   If @IN_MV_PAR09 = '1' begin
      Select @nReqTrans = @nReqTrans - @nCusto1
   end else If @IN_MV_PAR09 = '2' begin
      Select @nReqTrans = @nReqTrans - @nCusto2
   end else If @IN_MV_PAR09 = '3' begin          
      Select @nReqTrans = @nReqTrans - @nCusto3
   end else If @IN_MV_PAR09 = '4' begin
      Select @nReqTrans = @nReqTrans - @nCusto4
   end else If @IN_MV_PAR09 = '5' begin
      Select @nReqTrans = @nReqTrans - @nCusto5
   end	

   If @nReqTrans <> 0 begin
      Select @nPassou = '1'
   End

/* --------------------------------------------------------------------------------------------------------------
      Movimentos Internos de Requisicao para OP
   -------------------------------------------------------------------------------------------------------------- */
   /* Requisicoes */
   select @nCusto1 = isnull(SUM(D3_CUSTO1),0), @nCusto2 = isnull(SUM(D3_CUSTO2),0), @nCusto3 = isnull(SUM(D3_CUSTO3),0),
          @nCusto4 = isnull(SUM(D3_CUSTO4),0), @nCusto5 = isnull(SUM(D3_CUSTO5),0)
     from SD3### SD3, SB1### SB1
    where SD3.D3_FILIAL  = @cFil_SD3
      and SD3.D3_COD    >= @IN_CCODDE
      and SD3.D3_COD    <= @IN_CCODATE
      and SD3.D3_LOCAL  >= @IN_LOCALDE
      and SD3.D3_LOCAL  <= @IN_LOCALATE
      and SD3.D3_EMISSAO>= @IN_DATAINI
      and SD3.D3_EMISSAO < @IN_DATAFIM
      and SD3.D3_OP      <> '             '
      and Substring(D3_OP,7,2) <> 'OS'
      and SD3.D3_CF      <> '             '
      and SD3.D3_CF      <> 'PR0'
      and SD3.D3_CF      <> 'PR1'
      and SD3.D3_TM      > '500'
      and SD3.D3_ESTORNO <> 'S'
      and SD3.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD3.D3_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusto1 = isnull(@nCusto1,0)
   select @nCusto2 = isnull(@nCusto2,0)
   select @nCusto3 = isnull(@nCusto3,0)
   select @nCusto4 = isnull(@nCusto4,0)
   select @nCusto5 = isnull(@nCusto5,0)

   /* Devolucoes */	      
   select @nCusReq1 = isnull(SUM(D3_CUSTO1),0), @nCusReq2 = isnull(SUM(D3_CUSTO2),0), @nCusReq3 = isnull(SUM(D3_CUSTO3),0),
          @nCusReq4 = isnull(SUM(D3_CUSTO4),0), @nCusReq5 = isnull(SUM(D3_CUSTO5),0)
     from SD3### SD3, SB1### SB1
    where SD3.D3_FILIAL  = @cFil_SD3
      and SD3.D3_COD    >= @IN_CCODDE
      and SD3.D3_COD    <= @IN_CCODATE
      and SD3.D3_LOCAL  >= @IN_LOCALDE
      and SD3.D3_LOCAL  <= @IN_LOCALATE
      and SD3.D3_EMISSAO>= @IN_DATAINI
      and SD3.D3_EMISSAO < @IN_DATAFIM
      and SD3.D3_OP      <> '             '
      and Substring(D3_OP,7,2) <> 'OS'
      and SD3.D3_CF      <> '             '
      and SD3.D3_CF      <> 'PR0'
      and SD3.D3_CF      <> 'PR1'
      and SD3.D3_TM      < '501'
      and SD3.D3_ESTORNO <> 'S'
      and SD3.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD3.D3_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusReq1 = isnull(@nCusReq1,0)
   select @nCusReq2 = isnull(@nCusReq2,0)
   select @nCusReq3 = isnull(@nCusReq3,0)
   select @nCusReq4 = isnull(@nCusReq4,0)
   select @nCusReq5 = isnull(@nCusReq5,0)

   If @IN_MV_PAR09 = '1' begin
      Select @nReqProd = @nReqProd + (@nCusReq1 - @nCusto1)
   end else If @IN_MV_PAR09 = '2' begin
      Select @nReqProd = @nReqProd + (@nCusReq2 - @nCusto2)
   end else If @IN_MV_PAR09 = '3' begin          
      Select @nReqProd = @nReqProd + (@nCusReq3 - @nCusto3)
   end else If @IN_MV_PAR09 = '4' begin
      Select @nReqProd = @nReqProd + (@nCusReq4 - @nCusto4)
   end else If @IN_MV_PAR09 = '5' begin
      Select @nReqProd = @nReqProd + (@nCusReq5 - @nCusto5)
   end	

   If @nReqProd <> 0 begin
      Select @nPassou = '1'
   End

/* --------------------------------------------------------------------------------------------------------------
      Movimentos Internos de Requisicao para Consumo
   -------------------------------------------------------------------------------------------------------------- */
   /* Requisicoes */
   select @nCusto1 = isnull(SUM(D3_CUSTO1),0), @nCusto2 = isnull(SUM(D3_CUSTO2),0), @nCusto3 = isnull(SUM(D3_CUSTO3),0),
          @nCusto4 = isnull(SUM(D3_CUSTO4),0), @nCusto5 = isnull(SUM(D3_CUSTO5),0)
     from SD3### SD3, SB1### SB1
    where SD3.D3_FILIAL  = @cFil_SD3
      and SD3.D3_COD    >= @IN_CCODDE
      and SD3.D3_COD    <= @IN_CCODATE
      and SD3.D3_LOCAL  >= @IN_LOCALDE
      and SD3.D3_LOCAL  <= @IN_LOCALATE
      and SD3.D3_EMISSAO>= @IN_DATAINI
      and SD3.D3_EMISSAO < @IN_DATAFIM
      and SD3.D3_OP      = '             '
      and SD3.D3_CF      <> 'PR0'
      and SD3.D3_CF      <> 'PR1'
      and SD3.D3_CF      <> 'RE4'
      and SD3.D3_CF      <> 'DE4'
      and SD3.D3_TM      > '500'
      and Substring(D3_CF,3,1) <> '3'
      and SD3.D3_ESTORNO <> 'S'
      and SD3.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD3.D3_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusto1 = isnull(@nCusto1,0)
   select @nCusto2 = isnull(@nCusto2,0)
   select @nCusto3 = isnull(@nCusto3,0)
   select @nCusto4 = isnull(@nCusto4,0)
   select @nCusto5 = isnull(@nCusto5,0)

   /* Devolucoes */
   select @nCusReq1 = isnull(SUM(D3_CUSTO1),0), @nCusReq2 = isnull(SUM(D3_CUSTO2),0), @nCusReq3 = isnull(SUM(D3_CUSTO3),0),
          @nCusReq4 = isnull(SUM(D3_CUSTO4),0), @nCusReq5 = isnull(SUM(D3_CUSTO5),0)
     from SD3### SD3, SB1### SB1
    where SD3.D3_FILIAL  = @cFil_SD3
      and SD3.D3_COD    >= @IN_CCODDE
      and SD3.D3_COD    <= @IN_CCODATE
      and SD3.D3_LOCAL  >= @IN_LOCALDE
      and SD3.D3_LOCAL  <= @IN_LOCALATE
      and SD3.D3_EMISSAO>= @IN_DATAINI
      and SD3.D3_EMISSAO < @IN_DATAFIM
      and SD3.D3_OP      = '             '
      and SD3.D3_CF      <> 'PR0'
      and SD3.D3_CF      <> 'PR1'
      and SD3.D3_CF      <> 'RE4'
      and SD3.D3_CF      <> 'DE4'
      and SD3.D3_TM      < '501'
      and Substring(D3_CF,3,1) <> '3'
      and SD3.D3_ESTORNO <> 'S'
      and SD3.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD3.D3_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusReq1 = isnull(@nCusReq1,0)
   select @nCusReq2 = isnull(@nCusReq2,0)
   select @nCusReq3 = isnull(@nCusReq3,0)
   select @nCusReq4 = isnull(@nCusReq4,0)
   select @nCusReq5 = isnull(@nCusReq5,0)

   If @IN_MV_PAR09 = '1' begin
      Select @nReqCons = @nReqCons + (@nCusReq1 - @nCusto1)
   end else If @IN_MV_PAR09 = '2' begin
      Select @nReqCons = @nReqCons + (@nCusReq2 - @nCusto2)
   end else If @IN_MV_PAR09 = '3' begin          
      Select @nReqCons = @nReqCons + (@nCusReq3 - @nCusto3)
   end else If @IN_MV_PAR09 = '4' begin
      Select @nReqCons = @nReqCons + (@nCusReq4 - @nCusto4)
   end else If @IN_MV_PAR09 = '5' begin
      Select @nReqCons = @nReqCons + (@nCusReq5 - @nCusto5)
   end	

   If @nReqCons <> 0 begin
      Select @nPassou = '1'
   End

/* --------------------------------------------------------------------------------------------------------------
      Movimentos Internos de Requisicao para Processo
   -------------------------------------------------------------------------------------------------------------- */
   /* Requisicoes */
   select @nCusto1 = isnull(SUM(D3_CUSTO1),0), @nCusto2 = isnull(SUM(D3_CUSTO2),0), @nCusto3 = isnull(SUM(D3_CUSTO3),0),
          @nCusto4 = isnull(SUM(D3_CUSTO4),0), @nCusto5 = isnull(SUM(D3_CUSTO5),0)
     from SD3### SD3, SB1### SB1
    where SD3.D3_FILIAL  = @cFil_SD3
      and SD3.D3_COD    >= @IN_CCODDE
      and SD3.D3_COD    <= @IN_CCODATE
      and SD3.D3_LOCAL  >= @IN_LOCALDE
      and SD3.D3_LOCAL  <= @IN_LOCALATE
      and SD3.D3_EMISSAO>= @IN_DATAINI
      and SD3.D3_EMISSAO < @IN_DATAFIM
      and SD3.D3_OP      = '             '
      and SD3.D3_CF      = 'RE3'
      and SD3.D3_ESTORNO <> 'S'
      and SD3.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD3.D3_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusto1 = isnull(@nCusto1,0)
   select @nCusto2 = isnull(@nCusto2,0)
   select @nCusto3 = isnull(@nCusto3,0)
   select @nCusto4 = isnull(@nCusto4,0)
   select @nCusto5 = isnull(@nCusto5,0)

   /* Devolucoes */
   select @nCusReq1 = isnull(SUM(D3_CUSTO1),0), @nCusReq2 = isnull(SUM(D3_CUSTO2),0), @nCusReq3 = isnull(SUM(D3_CUSTO3),0),
          @nCusReq4 = isnull(SUM(D3_CUSTO4),0), @nCusReq5 = isnull(SUM(D3_CUSTO5),0)
     from SD3### SD3, SB1### SB1
    where SD3.D3_FILIAL  = @cFil_SD3
      and SD3.D3_COD    >= @IN_CCODDE
      and SD3.D3_COD    <= @IN_CCODATE
      and SD3.D3_LOCAL  >= @IN_LOCALDE
      and SD3.D3_LOCAL  <= @IN_LOCALATE
      and SD3.D3_EMISSAO>= @IN_DATAINI
      and SD3.D3_EMISSAO < @IN_DATAFIM
      and SD3.D3_OP      = '             '
      and SD3.D3_CF      = 'DE3'
      and SD3.D3_ESTORNO <> 'S'
      and SD3.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD3.D3_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusReq1 = isnull(@nCusReq1,0)
   select @nCusReq2 = isnull(@nCusReq2,0)
   select @nCusReq3 = isnull(@nCusReq3,0)
   select @nCusReq4 = isnull(@nCusReq4,0)
   select @nCusReq5 = isnull(@nCusReq5,0)

   If @IN_MV_PAR09 = '1' begin
      Select @nReqOutr = @nReqOutr + (@nCusReq1 - @nCusto1)
      If @cLocProc = '0' begin
         Select @nReqProc = @nCusto1
         Select @nDevProc = @nCusReq1
      End
   end else If @IN_MV_PAR09 = '2' begin
      Select @nReqOutr = @nReqOutr + (@nCusReq2 - @nCusto2)
      If @cLocProc = '0' begin
         Select @nReqProc = @nCusto2
         Select @nDevProc = @nCusReq2
      End
   end else If @IN_MV_PAR09 = '3' begin          
      Select @nReqOutr = @nReqOutr + (@nCusReq3 - @nCusto3)
      If @cLocProc = '0' begin
         Select @nReqProc = @nCusto3
         Select @nDevProc = @nCusReq3
      End
   end else If @IN_MV_PAR09 = '4' begin
      Select @nReqOutr = @nReqOutr + (@nCusReq4 - @nCusto4)
      If @cLocProc = '0' begin
         Select @nReqProc = @nCusto4
         Select @nDevProc = @nCusReq4
      End
   end else If @IN_MV_PAR09 = '5' begin
      Select @nReqOutr = @nReqOutr + (@nCusReq5 - @nCusto5)
      If @cLocProc = '0' begin
         Select @nReqProc = @nCusto5
         Select @nDevProc = @nCusReq5
      End
   end	

   If @nReqOutr <> 0 begin
      Select @nPassou = '1'
   End

/* --------------------------------------------------------------------------------------------------------------
      Movimentos Internos de Requisicao para MNT
   -------------------------------------------------------------------------------------------------------------- */
   /* Requisicoes */
   select @nCusto1 = isnull(SUM(D3_CUSTO1),0), @nCusto2 = isnull(SUM(D3_CUSTO2),0), @nCusto3 = isnull(SUM(D3_CUSTO3),0),
          @nCusto4 = isnull(SUM(D3_CUSTO4),0), @nCusto5 = isnull(SUM(D3_CUSTO5),0)
     from SD3### SD3, SB1### SB1
    where SD3.D3_FILIAL  = @cFil_SD3
      and SD3.D3_COD    >= @IN_CCODDE
      and SD3.D3_COD    <= @IN_CCODATE
      and SD3.D3_LOCAL  >= @IN_LOCALDE
      and SD3.D3_LOCAL  <= @IN_LOCALATE
      and SD3.D3_EMISSAO>= @IN_DATAINI
      and SD3.D3_EMISSAO < @IN_DATAFIM
      and Substring(D3_OP,7,2) = 'OS'
      and SD3.D3_TM      > '500'
      and SD3.D3_ESTORNO <> 'S'
      and SD3.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD3.D3_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusto1 = isnull(@nCusto1,0)
   select @nCusto2 = isnull(@nCusto2,0)
   select @nCusto3 = isnull(@nCusto3,0)
   select @nCusto4 = isnull(@nCusto4,0)
   select @nCusto5 = isnull(@nCusto5,0)

   /* Devolucoes */
   select @nCusReq1 = isnull(SUM(D3_CUSTO1),0), @nCusReq2 = isnull(SUM(D3_CUSTO2),0), @nCusReq3 = isnull(SUM(D3_CUSTO3),0),
          @nCusReq4 = isnull(SUM(D3_CUSTO4),0), @nCusReq5 = isnull(SUM(D3_CUSTO5),0)
     from SD3### SD3, SB1### SB1
    where SD3.D3_FILIAL  = @cFil_SD3
      and SD3.D3_COD    >= @IN_CCODDE
      and SD3.D3_COD    <= @IN_CCODATE
      and SD3.D3_LOCAL  >= @IN_LOCALDE
      and SD3.D3_LOCAL  <= @IN_LOCALATE
      and SD3.D3_EMISSAO>= @IN_DATAINI
      and SD3.D3_EMISSAO < @IN_DATAFIM
      and Substring(D3_OP,7,2) = 'OS'
      and SD3.D3_TM      < '501'
      and SD3.D3_ESTORNO <> 'S'
      and SD3.D_E_L_E_T_ = ' '
      and SB1.B1_FILIAL  = @cFil_SB1
      and SB1.B1_COD     = SD3.D3_COD
      and SB1.B1_TIPO    = @IN_CTIPO
      and SB1.D_E_L_E_T_ = ' '

   select @nCusReq1 = isnull(@nCusReq1,0)
   select @nCusReq2 = isnull(@nCusReq2,0)
   select @nCusReq3 = isnull(@nCusReq3,0)
   select @nCusReq4 = isnull(@nCusReq4,0)
   select @nCusReq5 = isnull(@nCusReq5,0)

   If @IN_MV_PAR09 = '1' begin
      Select @nReqMNT = @nReqMNT + (@nCusto1 -  @nCusReq1)
   end else If @IN_MV_PAR09 = '2' begin
      Select @nReqMNT = @nReqMNT + (@nCusto2 -  @nCusReq2)
   end else If @IN_MV_PAR09 = '3' begin          
      Select @nReqMNT = @nReqMNT + (@nCusto3 -  @nCusReq3)
   end else If @IN_MV_PAR09 = '4' begin
      Select @nReqMNT = @nReqMNT + (@nCusto4 -  @nCusReq4)
   end else If @IN_MV_PAR09 = '5' begin
      Select @nReqMNT = @nReqMNT + (@nCusto5 -  @nCusReq5)
   end	

   If @nReqMNT <> 0 begin
      Select @nPassou = '1'
   End

/* --------------------------------------------------------------------------------------------------------------
      Considera ou nao requisicoes para OPs geradas pelo MNT
   -------------------------------------------------------------------------------------------------------------- */
   If @IN_MV_PAR12 = '1' begin
      Select @nReqProd = @nReqProd - @nReqMNT
      Select @nReqMNT  = 0
   End 

 /* -------------------------------------------------------------------------
    Final do processo retornando '1' como processo  encerrado por completo
    ------------------------------------------------------------------------- */
   select @OUT_RESULTADO  = '1'
   select @OUT_NPASSOU    = @nPassou
   If @cLocProc = '1' begin
      select @OUT_NSALANT    = @nSaldoAtu-@nCompras-@nReqProd-@nReqCons-@nProducao+@nVendas-@nReqTrans-@nDevVendas+@nDevComprs-@nEntrTerc+@nSaiTerc
   end else begin
      select @OUT_NSALANT    = @nSaldoAtu-@nCompras-@nReqProd-@nReqCons-@nProducao+@nVendas-@nReqTrans+@nReqProc-@nDevProc-@nDevVendas+@nDevComprs-@nEntrTerc+@nSaiTerc
   End
   select @OUT_NCOMPRAS   = @nCompras
   select @OUT_NREQCONS   = @nReqCons
   select @OUT_NREQPROD   = @nReqProd
   select @OUT_NREQTRANS  = @nReqTrans
   select @OUT_NPRODUCAO  = @nProducao
   select @OUT_NVENDAS    = @nVendas
   select @OUT_NREQOUTR   = @nReqOutr
   select @OUT_NDEVVENDAS = @nDevVendas
   select @OUT_NDEVCOMPRS = @nDevComprs
   select @OUT_NENTRTERC  = @nEntrTerc
   select @OUT_NSAITERC   = @nSaiTerc
   select @OUT_NSALDOATU  = @nSaldoAtu
end