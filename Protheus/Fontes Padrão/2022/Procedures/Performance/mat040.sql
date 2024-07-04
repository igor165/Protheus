Create procedure MAT040_##
( 
	@IN_FILIALCOR	   Char('B1_FILIAL'),
	@IN_DELOCAL       Char('B1_LOCPAD'),
	@IN_ATELOCAL	   Char('B1_LOCPAD'), 
	@IN_MV_LOCPROC	   Char('B1_LOCPAD'),
	@IN_MV_ULMES	   Char(08),
	@IN_MV_RASTRO	   Char(01),
	@IN_MV_PAR03	   Char('B1_COD'),
	@IN_MV_PAR04	   Char('B1_COD'),
	@IN_MV_PAR05	   Integer,
	@IN_MV_PAR06      Integer,
	@IN_L300SALNEG    Char(01),
	@IN_MV_CUSMED     Char(01),
	@IN_MV_CUSFIL     Char(01),
	@IN_MV_CUSEMP     Char(01),
	@IN_MV_MOEDACM    Char(5),
   @IN_MV_D3SERVI    Char(01),
   @IN_INTDL         Char(01),
   @IN_MV_CQ         Char('B1_LOCPAD'),
	@IN_MV_WMSNEW     Char(01),
   @IN_MV_ARQPROD    Char(03),
   @IN_MV_CUSTNEG    Char(01),
   @l300pri          Char(01),
	@OUT_RESULTADO    Char(01) OutPut
)

as


/* ---------------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Protheus P12 </v>
    -----------------------------------------------------------------------------------------------------------------    
    Programa    :   <s> mata300.prx  </s>
    -----------------------------------------------------------------------------------------------------------------    
    Assinatura  :   <a> 003 </a>
    -----------------------------------------------------------------------------------------------------------------    
    Descricao   :   <d> Recalcula o Saldo Atual de Estoques dos Produtos </d>
    -----------------------------------------------------------------------------------------------------------------
    Entrada     :  <ri> @IN_FILIALCOR  - Filial corrente 
                        @IN_DELOCAL    - Local de Processamento (Almoxarifado) : DE
                        @IN_ATELOCAL   - Local de Processamento (Almoxarifado) : ATE
                        @IN_MV_ULMES   - Data do último fechamento do estoque
                        @IN_MV_RASTRO  - Prametro MV_RASTRO
                        @IN_MV_PAR03	- Produto Inicial
                        @IN_MV_PAR04	- Produto Final
                        @IN_MV_PAR05	- Zera o Saldo da MOD?  Sim(1)/Nao(2) </ri>                   
                        @IN_MV_PAR06   - Zera o CM da MOD?  Sim(1)/Nao(2) </ri>                   
    -----------------------------------------------------------------------------------------------------------------
    Saida       :  <ro> @OUT_RESULTADO - Retorno de processamento </ro>
    -----------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Advanced Protheus </v>
    -----------------------------------------------------------------------------------------------------------------
    Observações :   <o>   </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Ricardo Gonçalves </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 01/02/2002 </dt>

    Estrutura de chamadas
    ========= == ========

    0.MAT040 - Recalcula o Saldo Atual de Estoques dos Produtos
      1.MAT006 - Retorna o Saldo do Produto/Local do arquivo SB9 - Saldos Iniciais
      1.MAT011 - Pesquisa no SB1 se produto corrente usa rastreabilidade
      1.M300SB8 - Ponto de entrada para gravar campos especificos do SB8
      1.MAT012 - Pesquisa no SB1 se produto corrente usa localizacao fisica
      1.MAT044 - Atualiza saldos por endereçamento

    -----------------------------------------------------------------------------------------------------------------
    Obs.: Não remova os tags acima. Os tags são a base para a geração automática, de documentação, pelo Parse.
--------------------------------------------------------------------------------------------------------------------- */

Declare @cFil_SB1        Char('B1_FILIAL')
Declare @cFil_SB2        Char('B2_FILIAL')
Declare @cFil_SB8        Char('B8_FILIAL')
Declare @cFil_SB9        Char('B9_FILIAL')
Declare @cFil_SBF        Char('BF_FILIAL')
Declare @cFil_SBJ        Char('BJ_FILIAL')
Declare @cFil_SBK        Char('BK_FILIAL')
Declare @cFil_SD1        Char('D1_FILIAL')
Declare @cFil_SD2        Char('D2_FILIAL')
Declare @cFil_SD3        Char('D3_FILIAL')
Declare @cFil_SD5        Char('D5_FILIAL')
Declare @cFil_SDB        Char('DB_FILIAL')
Declare @cFil_SF4        Char('F4_FILIAL')
Declare @cFil_SBE        Char('BE_FILIAL')

Declare @cProduto        char('B1_COD') 	
Declare @cB1_CCCUSTO     char('B1_CCCUSTO')
Declare @cLocal          char('B1_LOCPAD') 
Declare @lLocaliz        char(01)
Declare @lRastro         char(01)
Declare @lIntDl			 char(01)
Declare @dUltSaiSD3      char(08) 
Declare @dUltSaiSD2      char(08) 
Declare @dUltSai         char(08) 
Declare @dBJ_DATA        char( 'BJ_DATA' )
Declare @dBJ_DTVALID     char( 'BJ_DTVALID' )
Declare @cBJ_LOTECTL     char( 'BJ_LOTECTL' )
Declare @cBJ_NUMLOTE     char( 'BJ_NUMLOTE' )

Declare @dB8_DTVALID     char( 'B8_DTVALID' )

Declare @cD5_PRODUTO     char( 'D5_PRODUTO' )
Declare @cD5_LOCAL       char( 'D5_LOCAL' )
Declare @cD5_LOTECTL     char( 'D5_LOTECTL' )
Declare @cD5_NUMLOTE     char( 'D5_NUMLOTE' )
Declare @dD5_DATA        char( 'D5_DATA' )
Declare @dD5_DTVALID     char( 'D5_DTVALID' )

Declare @dBK_DATA        char( 'BK_DATA' )
Declare @cBK_LOTECTL     char( 'BK_LOTECTL' )
Declare @cBK_NUMLOTE     char( 'BK_NUMLOTE' )
Declare @cBK_LOCALIZ     char( 'BK_LOCALIZ' )
Declare @cBK_NUMSERI     char( 'BK_NUMSERI' )
Declare @cBK_COD         char( 'BK_COD' )
Declare @cBK_LOCAL       char( 'BK_LOCAL' )
Declare @nBK_QINI        decimal( 'BK_QINI' )
Declare @nBK_QISEGUM     decimal( 'BK_QISEGUM' )
Declare @cBK_PRIOR       char( 'BK_PRIOR' )

Declare @nOUT_QSALDOATU  float 
Declare	@nOUT_CUSTOATU   float   
Declare	@nOUT_CUSTOATU2  float   
Declare	@nOUT_CUSTOATU3  float   
Declare	@nOUT_CUSTOATU4  float   
Declare	@nOUT_CUSTOATU5  float   
Declare	@nOUT_QTSEGUM    decimal( 'B2_QTSEGUM' )
Declare @nIN_QTSEGUM     decimal( 'B2_QTSEGUM' )

Declare @nB2_CM1         decimal( 'B2_CM1' )
Declare @nB2_CM2         decimal( 'B2_CM2' )
Declare @nB2_CM3         decimal( 'B2_CM3' )
Declare @nB2_CM4         decimal( 'B2_CM4' )
Declare @nB2_CM5         decimal( 'B2_CM5' )

Declare @nB9_CM1         decimal( 'B2_CM1' )
Declare @nB9_CM2         decimal( 'B2_CM2' )
Declare @nB9_CM3         decimal( 'B2_CM3' )
Declare @nB9_CM4         decimal( 'B2_CM4' )
Declare @nB9_CM5         decimal( 'B2_CM5' )

Declare @nB9_CMRP1       decimal( 'B2_CM1' )
Declare @nB9_CMRP2       decimal( 'B2_CM2' )
Declare @nB9_CMRP3       decimal( 'B2_CM3' )
Declare @nB9_CMRP4       decimal( 'B2_CM4' )
Declare @nB9_CMRP5       decimal( 'B2_CM5' )

Declare @nB9_VINIRP1     decimal( 'B2_VFIM1' )
Declare @nB9_VINIRP2     decimal( 'B2_VFIM2' )
Declare @nB9_VINIRP3     decimal( 'B2_VFIM3' )
Declare @nB9_VINIRP4     decimal( 'B2_VFIM4' )
Declare @nB9_VINIRP5     decimal( 'B2_VFIM5' )

Declare @nBJ_QINI        decimal( 'BJ_QINI' )
Declare @nBJ_QISEGUM     decimal( 'BJ_QISEGUM' )

Declare @nB8_QTDORI      decimal( 'B8_QTDORI' )
Declare @nB8_QTDORI2     decimal( 'B8_QTDORI2' )
Declare @nB8_SALDO       decimal( 'B8_SALDO' )
Declare @nB8_SALDO2      decimal( 'B8_SALDO2' )

Declare @nED5_QUANT      decimal( 'D5_QUANT' )   -- quantidades de entrada
Declare @nED5_QTSEGUM    decimal( 'D5_QTSEGUM' ) -- quantidades de entrada para segunda unidade de medida
Declare @nSD5_QUANT      decimal( 'D5_QUANT' )   -- quantidades de saída
Declare @nSD5_QTSEGUM    decimal( 'D5_QTSEGUM' ) -- quantidades de saída para segunda unidade de medida

Declare @nQuant          decimal( 'D5_QUANT;B8_SALDO;B8_QTDORI' )
Declare @nQuant2         decimal( 'D5_QTSEGUM;B8_SALDO2;B8_QTDORI2' )

Declare @iRecno          Integer
Declare @iRecCount       Integer
Declare @iRec            integer
Declare @iMaxRecno       integer
Declare @iRecAnt         integer
Declare @cAux            Varchar(6)
Declare @dAux            char(8)
Declare @nMinRecno	 	 integer
Declare @nMaxRecno	 	 integer
Declare @lSaldoIni       Varchar(1)
Declare @dData           char(08)
Declare @cEstFis         char( 'BE_ESTFIS' )
Declare @cPrior          char( 'BE_PRIOR' )
Declare @BF_LOCAL        char('BF_LOCAL')
Declare @BF_LOCALIZ      char(15)
Declare @nValorMax       decimal( 'B8_QTDORI' )
Declare @nValorMax2      decimal( 'B8_QTDORI2' )
Declare @nResult	     char(01)
Declare @cFilialAux		 VarChar('B1_FILIAL')
Declare @cTipo			 VarChar('B1_TIPO')
Declare @ccCusto		 VarChar('B1_CCCUSTO')

begin
   select @OUT_RESULTADO = '0'
	select @lSaldoIni = '0'
   /* ------------------------------------------------------------------------------------------------------------------
      Recuperando Filiais
   ------------------------------------------------------------------------------------------------------------------ */
   select @cAux = 'SB1'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB1 OutPut
   select @cAux = 'SB2'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB2 OutPut
   select @cAux = 'SB8'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB8 OutPut
   select @cAux = 'SB9'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB9 OutPut
   select @cAux = 'SBF'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBF OutPut
   select @cAux = 'SBJ'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBJ OutPut
   select @cAux = 'SBK'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBK OutPut   
   select @cAux = 'SD1'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD1 OutPut
   select @cAux = 'SD2'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD2 OutPut
   select @cAux = 'SD3'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD3 OutPut
   select @cAux = 'SD5'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD5 OutPut
   select @cAux = 'SDB'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SDB OutPut
   select @cAux = 'SF4'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SF4 OutPut
   select @cAux = 'SBE'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBE OutPut
   
   select @cFilialAux = ##TAMSX3DIC_001('B1_FILIAL')##ENDTAMSX3DIC_001
   select @cTipo      = ##TAMSX3DIC_001('B1_TIPO')##ENDTAMSX3DIC_001
   select @cPrior     = ##TAMSX3DIC_001('BE_PRIOR')##ENDTAMSX3DIC_001
   select @cEstFis    = ##TAMSX3DIC_001('BE_ESTFIS')##ENDTAMSX3DIC_001
   select @ccCusto	  = ##TAMSX3DIC_001('B1_CCCUSTO')##ENDTAMSX3DIC_001
   
   /* ------------------------------------------------------------------------------------------------------------------
      Declara cursor para a Select de Produtos a Serem calculados 
   ------------------------------------------------------------------------------------------------------------------ */
   declare LISTA_DE_PROD insensitive cursor for
      select B1_COD, B1_CCCUSTO
        from SB1### (NoLock) 
       Where B1_FILIAL   = @cFil_SB1
			and B1_COD between @IN_MV_PAR03 and @IN_MV_PAR04         
		 and ( ( @IN_MV_PAR05 = 1 or @IN_MV_PAR06 = 1 or @IN_MV_PAR05 = 3 or @IN_MV_PAR06 = 3) or ( (B1_COD not LIKE 'MOD%' AND B1_CCCUSTO = @ccCusto) and @IN_MV_PAR05 = 2 and @IN_MV_PAR06 = 2 ) )
         and D_E_L_E_T_  = ' '
   for read only
   
   open LISTA_DE_PROD
   
   fetch LISTA_DE_PROD into @cProduto, @cB1_CCCUSTO
   
   while (@@Fetch_Status = 0) begin
      /* ---------------------------------------------------------------------------------------------------------------
         Processando locais em ordem crescente
      --------------------------------------------------------------------------------------------------------------- */
      Select @cLocal = null
      
      declare CUR_LOCAL insensitive cursor for
         select B2_LOCAL  as xLOCAL
           from SB2### (NoLock) 
          where B2_FILIAL     = @cFil_SB2 
            and B2_COD        = @cProduto 
            and ( ( B2_LOCAL >= @IN_DELOCAL and B2_LOCAL <= @IN_ATELOCAL ) or B2_LOCAL = @IN_MV_LOCPROC )
            and D_E_L_E_T_    = ' '
       union
         select B9_LOCAL as xLOCAL
           from SB9### (NoLock) 
          where B9_FILIAL     = @cFil_SB9 
            and B9_COD        = @cProduto 
            and ( ( B9_LOCAL >= @IN_DELOCAL and B9_LOCAL <= @IN_ATELOCAL ) or B9_LOCAL = @IN_MV_LOCPROC )
            and D_E_L_E_T_    = ' '
       union
         select D1_LOCAL  as xLOCAL
           from SD1### (NoLock) 
          where D1_FILIAL     = @cFil_SD1 
            and D1_COD        = @cProduto 
            and ( ( D1_LOCAL >= @IN_DELOCAL and D1_LOCAL <= @IN_ATELOCAL ) or D1_LOCAL = @IN_MV_LOCPROC )
            and D_E_L_E_T_    = ' '
       union
         select D2_LOCAL  as xLOCAL
           from SD2### (NoLock) 
          where D2_FILIAL     = @cFil_SD2 
            and D2_COD        = @cProduto 
            and ( ( D2_LOCAL >= @IN_DELOCAL and D2_LOCAL <= @IN_ATELOCAL ) or D2_LOCAL = @IN_MV_LOCPROC )
            and D_E_L_E_T_    = ' '
       union
         select D3_LOCAL as xLOCAL
           from SD3### (NoLock) 
          where D3_FILIAL     = @cFil_SD3 
            and D3_COD        = @cProduto 
            and ( ( D3_LOCAL >= @IN_DELOCAL and D3_LOCAL <= @IN_ATELOCAL ) or D3_LOCAL = @IN_MV_LOCPROC )
            and D_E_L_E_T_    = ' '
          order by 1
      for read only
      
      open CUR_LOCAL
      
      fetch CUR_LOCAL into @cLocal
      
      while ( @@Fetch_Status = 0 ) begin
         /* ---------------------------------------------------------------------------------------------------------
            Zera as variaveis de movimentacao
         --------------------------------------------------------------------------------------------------------- */
         select @nB2_CM1 = 0
         select @nB2_CM2 = 0
         select @nB2_CM3 = 0
         select @nB2_CM4 = 0
         select @nB2_CM5 = 0
         
         if (@cLocal is not null) begin
            begin tran
            /* ---------------------------------------------------------------------------------------------------------
               Obtem saldo do arquivo SB9 (CalcEst)
            --------------------------------------------------------------------------------------------------------- */
            select @dAux = '20491231'
            exec MAT006_## @cProduto,				@cLocal,				@dAux,
                           @cFilialAux,				@IN_MV_LOCPROC,			@IN_FILIALCOR,          
                           @IN_MV_D3SERVI,			@IN_INTDL,				@IN_MV_CQ,
                           @IN_MV_WMSNEW,			'0',                   
                           @nOUT_QSALDOATU OutPut,	@nOUT_CUSTOATU  OutPut, @nOUT_CUSTOATU2 OutPut, 
                           @nOUT_CUSTOATU3 OutPut,	@nOUT_CUSTOATU4 OutPut, @nOUT_CUSTOATU5 OutPut,
                           @nOUT_QTSEGUM   OutPut,	@nB9_CM1        Output, @nB9_CM2        Output,
                           @nB9_CM3        Output,	@nB9_CM4        Output, @nB9_CM5        Output, 
                           @nB9_CMRP1      OutPut,	@nB9_CMRP2      Output, @nB9_CMRP3      Output,
                           @nB9_CMRP4      Output,	@nB9_CMRP5      Output, @nB9_VINIRP1    Output,
                           @nB9_VINIRP2    Output,	@nB9_VINIRP3    Output,	@nB9_VINIRP4    Output,
                           @nB9_VINIRP5    Output
            /* ---------------------------------------------------------------------------------------------------------
            Verifica duplicações no arquivo SB2
            --------------------------------------------------------------------------------------------------------- */
            select @iRecCount = Isnull( Count(*), 0 )
              from SB2### (nolock)
             where B2_FILIAL   = @cFil_SB2
               and B2_COD      = @cProduto
               and B2_LOCAL    = @cLocal
               and D_E_L_E_T_  = ' '

			/* ---------------------------------------------------------------------------------------------------------
            Altera custo se negativo e MV_CUSTNEG='N'
            --------------------------------------------------------------------------------------------------------- */
            if @IN_MV_CUSTNEG = '0' begin
               if @nOUT_CUSTOATU < 0 select @nOUT_CUSTOATU = 0
               if @nOUT_CUSTOATU2 < 0 select @nOUT_CUSTOATU2 = 0
               if @nOUT_CUSTOATU3 < 0 select @nOUT_CUSTOATU3 = 0
               if @nOUT_CUSTOATU4 < 0 select @nOUT_CUSTOATU4 = 0
               if @nOUT_CUSTOATU5 < 0 select @nOUT_CUSTOATU5 = 0
            end
            
            
            if @iRecCount > 0 begin
               select @iRecCount = min( R_E_C_N_O_ )
                 from SB2###
                where B2_FILIAL   = @cFil_SB2
                  and B2_COD      = @cProduto
                  and B2_LOCAL    = @cLocal
                  and D_E_L_E_T_  = ' '
               
               delete
                 from SB2###
                where B2_FILIAL   = @cFil_SB2
                  and B2_COD      = @cProduto
                  and B2_LOCAL    = @cLocal
                  and R_E_C_N_O_ <> @iRecCount
                  and D_E_L_E_T_  = ' '
            end else begin
               select @iRecno = isnull( max( R_E_C_N_O_ ), 0) from SB2###
               select @iRecno = @iRecno + 1
               ##TRATARECNO @iRecno\               
               insert into SB2### ( B2_FILIAL, B2_COD,    B2_LOCAL, R_E_C_N_O_ )
                    values        ( @cFil_SB2, @cProduto, @cLocal,  @iRecno )
               ##FIMTRATARECNO
            end
            
            /* ---------------------------------------------------------------------------------------------------------
               Obtendo data da ultima saida desse almoxerifado no arquivo SD3
            --------------------------------------------------------------------------------------------------------- */
            select @dUltSaiSD3 = Max( substring(D3_EMISSAO,1,8) )
              from SD3### (nolock)
             where D3_FILIAL   = @cFil_SD3
               and D3_COD      = @cProduto
               and D3_LOCAL    = @cLocal
               and D3_TM       > '500'
               and D_E_L_E_T_  = ' '
            
            select @dUltSaiSD3 = isnull( @dUltSaiSD3, '19800101' )            
            
            /* ---------------------------------------------------------------------------------------------------------
               Obtendo data da ultima saida no arquivo SD2
            --------------------------------------------------------------------------------------------------------- */
            select @dUltSaiSD2 = Max( substring(D2_EMISSAO,1,8) )
              from SD2### SD2 (nolock), SF4### SF4 (nolock)
             where D2_FILIAL      = @cFil_SD2
               and D2_COD         = @cProduto
               and D2_LOCAL       = @cLocal
               and F4_FILIAL      = @cFil_SF4
               and F4_CODIGO      = D2_TES
               and F4_ESTOQUE     = 'S'
               and SD2.D_E_L_E_T_ = ' '
               and SF4.D_E_L_E_T_ = ' '
            select @dUltSaiSD2 = isnull( @dUltSaiSD2, '19800101' )
            
            select @dUltSai = @dUltSaiSD3
            
            if @dUltSaiSD3 < @dUltSaiSD2 select @dUltSai = @dUltSaiSD2
            
            /* ---------------------------------------------------------------------------------------------------------
               Atualiza data da última saída do SB2 (Saldos em Estoque)
            --------------------------------------------------------------------------------------------------------- */
            if @dUltSai <> '19800101' begin
               
               Update SB2### 
                  Set B2_USAI    = @dUltSai 
                Where B2_FILIAL  = @cFil_SB2
                  and B2_COD     = @cProduto
                  and B2_LOCAL   = @cLocal
                  and D_E_L_E_T_ = ' '
               
            end
            Select @nMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @nMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
              from SB2###
             Where B2_FILIAL  = @cFil_SB2
               and B2_COD     = @cProduto
               and B2_LOCAL   = @cLocal
               and D_E_L_E_T_ = ' '
            select @nMinRecno = isnull( @nMinRecno, 0 )
            select @nMaxRecno = isnull( @nMaxRecno, 0 )
            /* ---------------------------------------------------------------------------------------------------------
            Zerando Saldo MOD no B2 com a condicao MV_PAR05 = 1 (Sim), pois MV_PAR05 = 2(Nao) e MOD nao veio no select.
            Zerando CM MOD no B2 com a condicao MV_PAR06 = 1 (Sim), pois MV_PAR06 = 2(Nao) e MOD nao veio no select.
            --------------------------------------------------------------------------------------------------------- */
            if ( Upper( substring( @cProduto, 1, 3 ) ) = 'MOD' Or @cB1_CCCUSTO <> ' ' ) and ( @IN_MV_PAR05  <> 3 and  @IN_MV_PAR06 <> 3 ) begin
               if (@IN_MV_PAR05  = 1 ) begin
                  if ( @IN_MV_PAR06  = 1 ) begin
                     while ( @nMinRecno <= @nMaxRecno ) begin
                      
                        update SB2###
                           set B2_VATU1   = 0, B2_VATU2 = 0, B2_VATU3 = 0, B2_VATU4 = 0, B2_VATU5 = 0, B2_QATU = 0,
                               B2_QTSEGUM = 0, B2_CM1   = 0, B2_CM2   = 0, B2_CM3   = 0, B2_CM4   = 0, B2_CM5  = 0 
                         where R_E_C_N_O_ between @nMinRecno and ( @nMinRecno  + 4095 )
                           and B2_FILIAL  = @cFil_SB2
                           and B2_COD     = @cProduto
                           and B2_LOCAL   = @cLocal
                           and D_E_L_E_T_ = ' ' 
                     
                        select @nMinRecno = @nMinRecno +  4096
                     end
                  end else begin 
                     while ( @nMinRecno <= @nMaxRecno ) begin
                       
                        update SB2###
                           set B2_VATU1   = 0 , B2_VATU2  = 0 , B2_VATU3  = 0 , B2_VATU4  = 0 , B2_VATU5  = 0 , B2_QATU  = 0 , B2_QTSEGUM  = 0 
                         where R_E_C_N_O_ between @nMinRecno and ( @nMinRecno + 4095 )
                           and B2_FILIAL  = @cFil_SB2
                           and B2_COD     = @cProduto 
                           and B2_LOCAL   = @cLocal
                           and D_E_L_E_T_ = ' ' 
                     
                        select @nMinRecno = @nMinRecno +  4096
                     end
                  end 
               end else begin
                  if ( @IN_MV_PAR06  = 1 ) begin
                     while ( @nMinRecno <= @nMaxRecno ) begin
                        
                        update SB2###
                           set B2_CM1     = 0, B2_CM2 = 0, B2_CM3 = 0, B2_CM4 = 0, B2_CM5 = 0 
                         where R_E_C_N_O_  between @nMinRecno and  ( @nMinRecno + 4095 )
                           and B2_FILIAL  = @cFil_SB2
                           and B2_COD     = @cProduto 
                           and B2_LOCAL   = @cLocal
                           and D_E_L_E_T_ = ' ' 
                        
                        select @nMinRecno = @nMinRecno +  4096
                     end
                  end
               end
            end else begin
               /* ---------------------------------------------------------------------------------------------------------
                  Atualiza saldo do arquivo SB2
               --------------------------------------------------------------------------------------------------------- */
               select @nOUT_QSALDOATU = Round( @nOUT_QSALDOATU, 8 )
               if @nOUT_QSALDOATU > 0.00000001 begin
                  select @nB2_CM1 = @nOUT_CUSTOATU  / @nOUT_QSALDOATU
                  select @nB2_CM2 = @nOUT_CUSTOATU2 / @nOUT_QSALDOATU
                  select @nB2_CM3 = @nOUT_CUSTOATU3 / @nOUT_QSALDOATU
                  select @nB2_CM4 = @nOUT_CUSTOATU4 / @nOUT_QSALDOATU
                  select @nB2_CM5 = @nOUT_CUSTOATU5 / @nOUT_QSALDOATU
               end else begin
                  select @nB2_CM1 = isnull( B2_CM1 , 0 ) , @nB2_CM2 = isnull( B2_CM2 , 0 ),
                         @nB2_CM3 = isnull( B2_CM3 , 0 ) , @nB2_CM4 = isnull( B2_CM4 , 0 ),
                         @nB2_CM5 = isnull( B2_CM5 , 0 )
                    from SB2###
                   where B2_FILIAL  = @cFil_SB2
                     and B2_COD     = @cProduto
                     and B2_LOCAL   = @cLocal
                    and D_E_L_E_T_ = ' '
               end
			   
			   select @nIN_QTSEGUM = @nOUT_QTSEGUM
			   EXEC MAT018_## @cProduto, @IN_FILIALCOR, @nOUT_QSALDOATU, @nIN_QTSEGUM, 2, @nOUT_QTSEGUM OUTPUT 

               while ( @nMinRecno <= @nMaxRecno ) begin
                  if @l300pri = 1 begin
					  Update SB2###
						 set B2_QATU  = @nOUT_QSALDOATU, B2_VATU1   = @nOUT_CUSTOATU,
							 B2_VATU2 = @nOUT_CUSTOATU2, B2_VATU3   = @nOUT_CUSTOATU3,
							 B2_VATU4 = @nOUT_CUSTOATU4, B2_VATU5   = @nOUT_CUSTOATU5,
							 B2_CM1   = @nB2_CM1,        B2_CM2     = @nB2_CM2,
							 B2_CM3   = @nB2_CM3,        B2_CM4     = @nB2_CM4,
							 B2_CM5   = @nB2_CM5,        B2_QTSEGUM = @nOUT_QTSEGUM
					   where R_E_C_N_O_ between @nMinRecno and ( @nMinRecno + 4095 )
						 and B2_FILIAL  = @cFil_SB2
						 and B2_COD     = @cProduto
						 and B2_LOCAL   = @cLocal
						 and D_E_L_E_T_ = ' '
				  end else begin
					  Update SB2###
						 set B2_QATU  = B2_QATU + @nOUT_QSALDOATU, B2_VATU1   = B2_VATU1 + @nOUT_CUSTOATU,
							 B2_VATU2 = B2_VATU2 + @nOUT_CUSTOATU2, B2_VATU3   = B2_VATU3 + @nOUT_CUSTOATU3,
							 B2_VATU4 = B2_VATU4 + @nOUT_CUSTOATU4, B2_VATU5   = B2_VATU5 + @nOUT_CUSTOATU5,
							 B2_CM1 = cast((B2_VATU1 + @nOUT_CUSTOATU) / (B2_QATU + @nOUT_QSALDOATU) as decimal( 'B2_CM1' )),
							 B2_CM2 = cast((B2_VATU2 + @nOUT_CUSTOATU) / (B2_QATU + @nOUT_QSALDOATU) as decimal( 'B2_CM2' )),
							 B2_CM3 = cast((B2_VATU3 + @nOUT_CUSTOATU) / (B2_QATU + @nOUT_QSALDOATU) as decimal( 'B2_CM3' )),
							 B2_CM4 = cast((B2_VATU4 + @nOUT_CUSTOATU) / (B2_QATU + @nOUT_QSALDOATU) as decimal( 'B2_CM4' )),
							 B2_CM5 = cast((B2_VATU5 + @nOUT_CUSTOATU) / (B2_QATU + @nOUT_QSALDOATU) as decimal( 'B2_CM5' )),
							 B2_QTSEGUM = @nOUT_QTSEGUM
					   where R_E_C_N_O_ between @nMinRecno and ( @nMinRecno + 4095 )
						 and B2_FILIAL  = @cFil_SB2
						 and B2_COD     = @cProduto
						 and B2_LOCAL   = @cLocal
						 and D_E_L_E_T_ = ' '
				  end						
                  select @nMinRecno = @nMinRecno +  4096
                  
               end
            end
            /*
            Ignorado parte do codigo original pois no select do B1 já é filtrada a MOD e a opcao de zerar o saldo de MOD
            e pelo UNION já estaremos no menor local, dispensando a chamada da CalcEst ( MAT006_## ) passando o @IN_MV_LOCPROC
            como parametro.
            */
            /* ---------------------------------------------------------------------------------------------------------
               Processamento de arquivos de rastreabilidade
            --------------------------------------------------------------------------------------------------------- */
            select @lSaldoIni = '0'
            select @cAux = @cTipo
            exec MAT011_## @IN_MV_RASTRO, @cProduto, @cAux, @IN_FILIALCOR, @lRastro OutPut           
            
            if (@lRastro = '1') begin 
               /* ------------------------------------------------------------------------------------------------------
                  Zera os Valores do Produto no SB8
               ------------------------------------------------------------------------------------------------------ */
               select @iMaxRecno = isnull( max( R_E_C_N_O_ ), 0 )
                 from SB8### (nolock)
                where B8_FILIAL  = @cFil_SB8
                  and B8_FILIAL   = @cFil_SB8
                  and B8_PRODUTO  = @cProduto
                  and B8_LOCAL    = @cLocal
                  and D_E_L_E_T_  = ' '                      
               select @iRec = 0
               select @iMaxRecno = isnull( @iMaxRecno, 0 )
               while ( @iRec <= @iMaxRecno ) begin
                  select @iRecAnt = @iRec 
                  select @iRec = @iRec + 50000  --1024
                  
                  update SB8### 
                     set B8_SALDO = 0, B8_SALDO2 = 0
                   where R_E_C_N_O_  between @iRecAnt and @iRec 
                     and B8_FILIAL   = @cFil_SB8
                     and B8_PRODUTO  = @cProduto
                     and B8_LOCAL    = @cLocal
                     and D_E_L_E_T_  = ' '
                  
               end
               
               /* ------------------------------------------------------------------------------------------------------ 
                  Pega Saldo Inicial de Rastreabilidade no SBJ
               ------------------------------------------------------------------------------------------------------ */
               declare CUR_SBJ insensitive cursor for
               select BJ_DATA, BJ_DTVALID, BJ_LOTECTL, BJ_NUMLOTE, BJ_QINI, BJ_QISEGUM
                 from SBJ### SBJ (nolock)
                where BJ_FILIAL  = @cFil_SBJ
                  and BJ_COD     = @cProduto
                  and BJ_LOCAL   = @cLocal
                  and BJ_DATA    = ( Select max( substring(BJ_DATA,1,8) )
                                       from SBJ### SBJ (nolock)
                                      where BJ_FILIAL  = @cFil_SBJ
                                        and BJ_COD     = @cProduto
                                        and BJ_LOCAL   = @cLocal
                                        and D_E_L_E_T_ = ' ' )
                  and D_E_L_E_T_ = ' '
               open CUR_SBJ
               fetch CUR_SBJ into @dBJ_DATA, @dBJ_DTVALID, @cBJ_LOTECTL, @cBJ_NUMLOTE, @nBJ_QINI, @nBJ_QISEGUM
               
               while ( @@fetch_status = 0 ) begin
                  if @dBJ_DATA <= @IN_MV_ULMES begin
                     select @lSaldoIni = '1'
                     select @iRecno = null
                     select @iRecno      = R_E_C_N_O_, @dB8_DTVALID = B8_DTVALID, @nB8_QTDORI = B8_QTDORI, 
                            @nB8_QTDORI2 = B8_QTDORI2
                       from SB8### (nolock)
                      where B8_FILIAL   = @cFil_SB8
                        and B8_PRODUTO  = @cProduto
                        and B8_LOCAL    = @cLocal
                        and B8_LOTECTL  = @cBJ_LOTECTL
                        and B8_NUMLOTE  = @cBJ_NUMLOTE
                        and D_E_L_E_T_  =  ' '
	             
				 select @nIN_QTSEGUM = @nBJ_QISEGUM
				 EXEC MAT018_## @cProduto, @IN_FILIALCOR, @nBJ_QINI, @nIN_QTSEGUM, 2, @nBJ_QISEGUM OUTPUT
				 
	             if @iRecno is null begin
                        select @iRecno = IsNull( max(R_E_C_N_O_), 0 ) from SB8###
                        select @iRecno = @iRecno + 1
                        ##TRATARECNO @iRecno\
                        insert into SB8### ( B8_FILIAL,  B8_PRODUTO, B8_LOCAL,     B8_LOTECTL,   B8_NUMLOTE,   B8_DATA,
                                             B8_ORIGLAN, B8_SALDO,   B8_SALDO2,    B8_QTDORI,    B8_QTDORI2,   B8_DTVALID,
                 	                           R_E_C_N_O_ )                                                           
                               values      ( @cFil_SB8,  @cProduto,  @cLocal,      @cBJ_LOTECTL, @cBJ_NUMLOTE, @dBJ_DATA,
                                             ' ',        @nBJ_QINI,  @nBJ_QISEGUM, @nBJ_QINI,    @nBJ_QISEGUM, @dBJ_DTVALID,
                                             @iRecno )
                        ##FIMTRATARECNO
                     end else begin
                       if (@nBJ_QINI    > @nB8_QTDORI)  select @nB8_QTDORI  = @nBJ_QINI
                       if (@nBJ_QISEGUM > @nB8_QTDORI2) select @nB8_QTDORI2 = @nBJ_QISEGUM
                       update SB8### 
                          set B8_ORIGLAN = ' ',         B8_SALDO   = @nBJ_QINI,    B8_SALDO2  = @nBJ_QISEGUM, 
                              B8_QTDORI  = @nB8_QTDORI, B8_QTDORI2 = @nB8_QTDORI2
                        where R_E_C_N_O_ = @iRecno
                     end
                  end
                  /* --------------------------------------------------------------------------------------------------------------
                     Tratamento para o DB2
                  -------------------------------------------------------------------------------------------------------------- */
                  SELECT @fim_CUR = 0

                  fetch CUR_SBJ into @dBJ_DATA, @dBJ_DTVALID, @cBJ_LOTECTL, @cBJ_NUMLOTE, @nBJ_QINI, @nBJ_QISEGUM
               end 
               close      CUR_SBJ
               deallocate CUR_SBJ
               /* ------------------------------------------------------------------------------------------------------
                  Processa movimentacoes de estoque ( SD5 - Entradas e Saidas ) e grava saldo no arquivo SB8
               ------------------------------------------------------------------------------------------------------ */                              
               declare CUR_SD5 insensitive cursor for
                  select D5_PRODUTO, D5_LOCAL, D5_LOTECTL, D5_NUMLOTE
                    from SD5### SD5 (nolock)
                   where D5_FILIAL   = @cFil_SD5
                     and D5_PRODUTO  = @cProduto
                     and D5_LOCAL    = @cLocal
                     and D5_ESTORNO <> 'S'
                     and ( ( D5_DATA  > @IN_MV_ULMES  ) or ( @lSaldoIni = '0' )  )--Variavel @lSaldoIni altrerada valor qdo processando rastreabilidade SBJ encontra-se BJ_DATA = @IN_MV_ULMES
                     and D_E_L_E_T_  = ' '
                   group by D5_PRODUTO, D5_LOCAL, D5_LOTECTL, D5_NUMLOTE 
               open CUR_SD5
               fetch CUR_SD5 into @cD5_PRODUTO, @cD5_LOCAL, @cD5_LOTECTL, @cD5_NUMLOTE
               while @@fetch_status = 0 begin
                  select @nSD5_QUANT = 0
                  select @nED5_QUANT = 0
                  select @nED5_QTSEGUM = 0
                  select @nSD5_QTSEGUM = 0
                  
                  select @dD5_DATA = min(substring(D5_DATA,1,8)), @dD5_DTVALID = max(substring(D5_DTVALID,1,8))
                    from SD5### SD5 (nolock)
                   where D5_FILIAL  = @cFil_SD5
                     and D5_PRODUTO = @cD5_PRODUTO
                     and D5_LOCAL   = @cD5_LOCAL
                     and D5_LOTECTL = @cD5_LOTECTL
                     and D5_NUMLOTE = @cD5_NUMLOTE
                     and ( ( D5_DATA  > @IN_MV_ULMES  ) or ( @lSaldoIni = '0' )  )--Variavel @lSaldoIni altrerada valor qdo processando rastreabilidade SBJ encontra-se BJ_DATA = @IN_MV_ULMES
                     and D_E_L_E_T_ = ' '
                  /* ---------------------------------------------------------------------------------------------------
                     Totalizando movimentos de entrada
                  --------------------------------------------------------------------------------------------------- */
                  select @nED5_QUANT = Isnull( sum( D5_QUANT ), 0 ), @nED5_QTSEGUM = isnull( sum( D5_QTSEGUM ), 0 )
                    from SD5### SD5 (nolock)
                   where D5_FILIAL  = @cFil_SD5
                     and D5_PRODUTO = @cProduto
                     and D5_LOCAL   = @cLocal
                     and D5_LOTECTL = @cD5_LOTECTL
                     and D5_NUMLOTE = @cD5_NUMLOTE
                     and ( ( D5_DATA  > @IN_MV_ULMES  ) or ( @lSaldoIni = '0' )  )--Variavel @lSaldoIni altrerada valor qdo processando rastreabilidade SBJ encontra-se BJ_DATA = @IN_MV_ULMES
                     and ( ( D5_ORIGLAN <= '500' ) or ( substring( D5_ORIGLAN, 1, 2 ) in ( 'DE', 'PR' ) ) or ( D5_ORIGLAN = 'MAN' ) )
                     and D_E_L_E_T_ = ' '
                  group by D5_PRODUTO, D5_LOCAL, D5_LOTECTL, D5_NUMLOTE
                  select @nED5_QUANT = isnull( @nED5_QUANT, 0 )
                  select @nED5_QTSEGUM = isnull( @nED5_QTSEGUM, 0 )
                  /* ---------------------------------------------------------------------------------------------------
                     Totalizando movimentos de saída
                  --------------------------------------------------------------------------------------------------- */
                  select @nSD5_QUANT = isnull( sum( D5_QUANT ), 0 ), @nSD5_QTSEGUM = isnull( sum( D5_QTSEGUM ), 0 )
                    from SD5### SD5 (nolock)
                   where D5_FILIAL  = @cFil_SD5
                     and D5_PRODUTO = @cProduto
                     and D5_LOCAL   = @cLocal
                     and D5_LOTECTL = @cD5_LOTECTL
                     and D5_NUMLOTE = @cD5_NUMLOTE
                     and ( ( D5_DATA  > @IN_MV_ULMES  ) or ( @lSaldoIni = '0' )  )--Variavel @lSaldoIni altrerada valor qdo processando rastreabilidade SBJ encontra-se BJ_DATA = @IN_MV_ULMES
                     and D5_ORIGLAN > '500' AND ( substring( D5_ORIGLAN, 1, 2 ) NOT IN ( 'DE', 'PR' ) ) AND ( D5_ORIGLAN <> 'MAN' )
                     and D_E_L_E_T_ = ' '
                  group by D5_PRODUTO, D5_LOCAL, D5_LOTECTL, D5_NUMLOTE
                  select @nSD5_QUANT = isnull( @nSD5_QUANT, 0 )
                  select @nSD5_QTSEGUM = isnull( @nSD5_QTSEGUM, 0 )
                                                      
                  select @nQuant  = @nED5_QUANT   - @nSD5_QUANT
                  select @nQuant2 = @nED5_QTSEGUM - @nSD5_QTSEGUM
                  /* --------------------------------------------------------------------------------------------------
                     Atualizando arquivo SB8
                  -------------------------------------------------------------------------------------------------- */
                  select @iRecno = null
                  
                  select @iRecno      = R_E_C_N_O_, @dB8_DTVALID = B8_DTVALID, @nB8_QTDORI = B8_QTDORI, 
                         @nB8_QTDORI2 = B8_QTDORI2, @nB8_SALDO   = B8_SALDO,   @nB8_SALDO2 = B8_SALDO2
                    from SB8### (nolock)
                   where B8_FILIAL   = @cFil_SB8
                     and B8_PRODUTO  = @cProduto
                     and B8_LOCAL    = @cLocal
                     and B8_LOTECTL  = @cD5_LOTECTL
                     and B8_NUMLOTE  = @cD5_NUMLOTE
                     and D_E_L_E_T_  = ' '
                  
                  if @iRecno is null begin
                     if (@nQuant  < 0) select @nQuant  = 0
                     if (@nQuant2 < 0) select @nQuant2 = 0
                     
					 select @nIN_QTSEGUM = @nQuant2
                     EXEC MAT018_## @cProduto, @IN_FILIALCOR, @nQuant, @nIN_QTSEGUM, 2, @nQuant2 OUTPUT
				  
                     select @iRecno = IsNull( max(R_E_C_N_O_), 0 ) from SB8###
                     select @iRecno = isnull( @iRecno, 0 )
                     select @iRecno = @iRecno + 1
                     ##TRATARECNO @iRecno\
                     insert into SB8### ( B8_FILIAL,  B8_PRODUTO, B8_LOCAL,     B8_LOTECTL,   B8_NUMLOTE,   B8_DATA,
                                          B8_ORIGLAN, B8_SALDO,   B8_SALDO2,    B8_QTDORI,    B8_QTDORI2,   B8_DTVALID,
                                          R_E_C_N_O_ )                                                           
                          values        ( @cFil_SB8,  @cProduto,  @cLocal,      @cD5_LOTECTL, @cD5_NUMLOTE, @dD5_DATA,
                                          ' ',        @nQuant,    @nQuant2,     @nQuant,      @nQuant2,     @dD5_DTVALID,
                                          @iRecno )
                     ##FIMTRATARECNO
                  end else begin
                     if (@nB8_SALDO  + @nQuant  > 0) OR ( @IN_L300SALNEG = '1' ) select @nB8_SALDO  = @nB8_SALDO  + @nQuant
                     else                             select @nB8_SALDO  = 0
                         
                     if (@nB8_SALDO2 + @nQuant2 > 0) OR ( @IN_L300SALNEG = '1' ) select @nB8_SALDO2 = @nB8_SALDO2 + @nQuant2
                     else                             select @nB8_SALDO2 = 0

                     select @nValorMax = 0

                     if @nB8_SALDO  > @nB8_QTDORI select @nValorMax = @nB8_SALDO 
                     else select @nValorMax = @nB8_QTDORI

                     if @nValorMax > 0 OR @IN_L300SALNEG = '1' select @nB8_QTDORI  = @nValorMax

                     if @nB8_SALDO2  > @nB8_QTDORI2 select @nValorMax2 = @nB8_SALDO2 
                     else select @nValorMax2 = @nB8_QTDORI2

                     if @nValorMax2 > 0 OR @IN_L300SALNEG = '1' select @nB8_QTDORI2  = @nValorMax2
                     
					 select @nIN_QTSEGUM = @nB8_SALDO2
                     EXEC MAT018_## @cProduto, @IN_FILIALCOR, @nB8_SALDO, @nIN_QTSEGUM, 2, @nB8_SALDO2 OUTPUT

                     update SB8### 
                        set B8_SALDO   = @nB8_SALDO,   B8_SALDO2  = @nB8_SALDO2, 
                            B8_QTDORI  = @nB8_QTDORI, B8_QTDORI2 = @nB8_QTDORI2
                      where R_E_C_N_O_ = @iRecno
                  end
                  
                  /* ---------------------------------------------------------------------------------------------------
                     Ponto de entrada usado em localizações
                  --------------------------------------------------------------------------------------------------- */
                  exec M300SB8_## @IN_FILIALCOR, @cProduto, @cLocal, @cD5_LOTECTL, @cD5_NUMLOTE

                  /* ---------------------------------------------------------------------------------------------------
                     Tratamento para o DB2
                  --------------------------------------------------------------------------------------------------- */
                  SELECT @fim_CUR = 0

                  fetch CUR_SD5 into @cD5_PRODUTO, @cD5_LOCAL, @cD5_LOTECTL, @cD5_NUMLOTE
					end
					close CUR_SD5
					deallocate CUR_SD5            
				end -- if rastro = '1'
            /* ---------------------------------------------------------------------------------------------------------
               Processar arquivos de endereçamento
            --------------------------------------------------------------------------------------------------------- */
         	select @lSaldoIni = '0'
            exec MAT012_## @cProduto, @IN_FILIALCOR, @IN_MV_WMSNEW, @IN_MV_ARQPROD, @lLocaliz output 
            
            If @IN_MV_WMSNEW = '1'
				exec MAT057_## @cProduto, @IN_FILIALCOR, @lIntDl output
			else select @lIntDl = '0'

            if @lLocaliz = '1' and Not (@IN_MV_WMSNEW = '1' and @lIntDl = '1' ) begin
              
               
               /* ------------------------------------------------------------------------------------------------------
                  Zerando saldos no arquivo SBF
               ------------------------------------------------------------------------------------------------------ */               
               update SBF### 
                  set BF_QUANT = 0, BF_QTSEGUM = 0
                where BF_FILIAL  = @cFil_SBF
                  and BF_PRODUTO = @cProduto
                  and BF_LOCAL   = @cLocal
                  and D_E_L_E_T_ = ' '
               
               /* ------------------------------------------------------------------------------------------------------ 
                  Pega Saldo Inicial de Endereçamento no SBK
               ------------------------------------------------------------------------------------------------------ */
               declare CUR_SBK insensitive cursor for
                select BK_LOCAL, BK_LOCALIZ, BK_COD, BK_NUMSERI, BK_LOTECTL, BK_NUMLOTE, BK_DATA, BK_QINI, BK_QISEGUM, BK_PRIOR
                  from SBK### SBK (nolock)
                 where BK_FILIAL   = @cFil_SBK
                   and BK_COD      = @cProduto
                   and BK_LOCAL    = @cLocal
                   and BK_DATA     = ( Select max(substring(BK_DATA,1,8) )
                                         from SBK### SBKSUB (nolock)
                                        where SBKSUB.BK_FILIAL   = @cFil_SBK
                                          and SBKSUB.BK_COD      = @cProduto
                                          and SBKSUB.BK_LOCAL    = @cLocal
                                          and SBKSUB.BK_LOTECTL  = SBK.BK_LOTECTL
                                          and SBKSUB.BK_NUMLOTE  = SBK.BK_NUMLOTE
                                          and SBKSUB.BK_LOCALIZ  = SBK.BK_LOCALIZ
                                          and SBKSUB.BK_NUMSERI  = SBK.BK_NUMSERI
										  and SBKSUB.BK_DATA	>= @IN_MV_ULMES
                                          and SBKSUB.D_E_L_E_T_  = ' ' )                                   
                   and D_E_L_E_T_  = ' '
                 Order by BK_LOCAL, BK_LOCALIZ, BK_COD, BK_NUMSERI, BK_LOTECTL, BK_NUMLOTE, BK_DATA
                    
               open CUR_SBK
               fetch CUR_SBK into @cBK_LOCAL, @cBK_LOCALIZ, @cBK_COD, @cBK_NUMSERI, @cBK_LOTECTL, @cBK_NUMLOTE, @dBK_DATA, @nBK_QINI,  @nBK_QISEGUM, @cBK_PRIOR
               
               while @@fetch_status = 0 begin
                  select @iRecCount = null
                  select @iRecCount = Isnull( Count(*), 0 )
                    from SBK### SBK (nolock)
                   where BK_FILIAL   = @cFil_SBK
                     and BK_COD      = @cProduto
                     and BK_LOCAL    = @cLocal
                     and BK_LOTECTL  = @cBK_LOTECTL
                     and BK_NUMLOTE  = @cBK_NUMLOTE
                     and BK_LOCALIZ  = @cBK_LOCALIZ
                     and BK_NUMSERI  = @cBK_NUMSERI
                     and BK_DATA     = ( Select max(substring(BK_DATA,1,8) )
                                           from SBK### SBK (nolock)
                                          where BK_FILIAL   = @cFil_SBK
                                            and BK_COD      = @cProduto
                                            and BK_LOCAL    = @cLocal
                                            and BK_LOTECTL  = @cBK_LOTECTL
                                            and BK_NUMLOTE  = @cBK_NUMLOTE
                                            and BK_LOCALIZ  = @cBK_LOCALIZ
                                            and BK_NUMSERI  = @cBK_NUMSERI
                                            and D_E_L_E_T_  = ' ' )
                     and BK_DATA      > @IN_MV_ULMES
                     and D_E_L_E_T_   = ' '
                  if @iRecCount = 0 begin
                     /* ---------------------------------------------------------------------------------------------------------
                        Obtendo a Estrutura Fisica / Prioridade do Cadastro de Enderecos
                     --------------------------------------------------------------------------------------------------------- */

						 select @cEstFis     = BE_ESTFIS, @cPrior  =  BE_PRIOR
						   from SBE### (nolock)
						  where BE_FILIAL    = @cFil_SBE
							and BE_LOCAL     = @cLocal
							and BE_LOCALIZ   = @cBK_LOCALIZ
							and D_E_L_E_T_   = ' '

                     If @IN_INTDL = '0' begin
						 select @cEstFis = ' '
                     end
                      if @cPrior  is null select @cPrior  = ' '
                      if @cEstFis is null select @cEstFis = ' '
                        
                      select @lSaldoIni  = '1'
                      select @iRecno     = null
                      select @iRecno     = R_E_C_N_O_
                        from SBF### (nolock)
                       where BF_FILIAL   = @cFil_SBF
                         and BF_LOCAL    = @cLocal
                         and BF_LOCALIZ  = @cBK_LOCALIZ
                         and BF_ESTFIS   = @cEstFis
                         and BF_PRODUTO  = @cProduto
                         and BF_NUMSERI  = @cBK_NUMSERI
                         and BF_LOTECTL  = @cBK_LOTECTL
                         and BF_NUMLOTE  = @cBK_NUMLOTE
                         and D_E_L_E_T_  = ' '
                     
					  select @nIN_QTSEGUM = @nBK_QISEGUM
                      EXEC MAT018_## @cProduto, @IN_FILIALCOR, @nBK_QINI, @nIN_QTSEGUM, 2, @nBK_QISEGUM OUTPUT 
						 
                      if @iRecno is null begin
                         select @iRecno = IsNull( max(R_E_C_N_O_), 0 ) from SBF###
                         select @iRecno = isnull( @iRecno, 0 )
                         select @iRecno = @iRecno + 1
						 select @cEstFis = IsNull(@cEstFis,' ')
                         ##TRATARECNO @iRecno\
                         insert into SBF### ( BF_FILIAL,    BF_PRODUTO, BF_LOCAL,     BF_LOTECTL,   BF_NUMLOTE,   BF_LOCALIZ,
                                              BF_NUMSERI,   BF_QUANT,   BF_QTSEGUM,   BF_PRIOR,     BF_ESTFIS,    BF_EMPENHO, BF_EMPEN2,   R_E_C_N_O_ )
                                
                              values        ( @cFil_SBF,    @cProduto,  @cLocal,      @cBK_LOTECTL, @cBK_NUMLOTE, @cBK_LOCALIZ,
                                              @cBK_NUMSERI, @nBK_QINI,  @nBK_QISEGUM, @cPrior,      @cEstFis,     0,  0, @iRecno )
                         ##FIMTRATARECNO
                      end else begin
                         update SBF### 
                            set BF_QUANT = @nBK_QINI, BF_QTSEGUM = @nBK_QISEGUM
                          where R_E_C_N_O_ = @iRecno
                      end
                      
                  end

                  /* --------------------------------------------------------------------------------------------------------------
                     Tratamento para o DB2
                  -------------------------------------------------------------------------------------------------------------- */
                  SELECT @fim_CUR = 0
                  select @lSaldoIni  = '1'

                  fetch CUR_SBK into @cBK_LOCAL, @cBK_LOCALIZ, @cBK_COD, @cBK_NUMSERI, @cBK_LOTECTL, @cBK_NUMLOTE, @dBK_DATA, @nBK_QINI,  @nBK_QISEGUM, @cBK_PRIOR
               end
               
               close CUR_SBK
               deallocate CUR_SBK
               /* ------------------------------------------------------------------------------------------------------
                  Atualiza saldos por endereçamento
               ------------------------------------------------------------------------------------------------------ */
               exec MAT044_## @IN_FILIALCOR, @cProduto, @cLocal, @lSaldoIni, @IN_MV_ULMES, @IN_MV_RASTRO, @IN_INTDL
            end
            Commit transaction
         end -- if local is not null

         /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
         -------------------------------------------------------------------------------------------------------------- */
         SELECT @fim_CUR = 0

         fetch CUR_LOCAL into @cLocal
      end
      close CUR_LOCAL
      deallocate CUR_LOCAL

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
         exec MAT050_## @IN_FILIALCOR, @cProduto, @IN_MV_CUSFIL, @IN_MV_MOEDACM, @nResult output
      end

      /* --------------------------------------------------------------------------------------------------------------
         Tratamento para o DB2
      -------------------------------------------------------------------------------------------------------------- */
      SELECT @fim_CUR = 0

      fetch LISTA_DE_PROD into @cProduto, @cB1_CCCUSTO
   end

   close LISTA_DE_PROD
   deallocate LISTA_DE_PROD

   Select @OUT_RESULTADO = '1' 

end
