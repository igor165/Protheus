Create procedure MAT044_##
 ( 
   @IN_FILIALCOR  Char('B1_FILIAL'),
   @IN_PRODUTO    Char('B1_COD'),
   @IN_LOCAL      Char('B1_LOCPAD'), 
   @IN_SALDOINI   Varchar(1),
   @IN_MV_ULMES   Char(08),
   @IN_MV_RASTRO  Char(01),
   @IN_INTDL      Char(1)
 )
as

/* ---------------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Protheus P12 </v>
    -----------------------------------------------------------------------------------------------------------------    
    Programa    :   <s> mata300.prx  </s>
    -----------------------------------------------------------------------------------------------------------------    
    Assinatura  :   <a> 002 </a>
    -----------------------------------------------------------------------------------------------------------------    
    Descricao   :   <d> Atualiza saldos por endereçamento </d>
    -----------------------------------------------------------------------------------------------------------------
    Entrada     :  <ri> @IN_FILIALCOR  - Filial corrente 
                        @IN_PRODUTO    - Codigo Produto
                        @IN_LOCAL      - Local de Processamento
                        @IN_SALDOINI   - Flag que identifica se houve saldo inicial ou nao
                        @IN_MV_ULMES   - Data do último fechamento do estoque
    -----------------------------------------------------------------------------------------------------------------
    Observações :   <o>  BE_STATUS - 1 (desocupado) - 2 (ocupado) - 3 (bloqueado) </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Marcelo Pimentel </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 08/05/2003 </dt>
--------------------------------------------------------------------------------------------------------------------- */
declare @cFil_SDB        Char('DB_FILIAL')
Declare @cFil_SBE        Char('BE_FILIAL')
Declare @cFil_SB1        Char('B1_FILIAL')
Declare @cFil_SBK        Char('BK_FILIAL')
Declare @cAux            Varchar(3) 
Declare @cDtVai          Varchar(08)
Declare @cDB_PRODUTO     char( 'DB_PRODUTO' )
Declare @cDB_LOCAL       char( 'DB_LOCAL' )
Declare @cDB_LOTECTL     char( 'DB_LOTECTL' )
Declare @cDB_NUMLOTE     char( 'DB_NUMLOTE' )
Declare @cDB_LOCALIZ     char( 'DB_LOCALIZ' )
Declare @cDB_NUMSERI     char( 'DB_NUMSERI' )
Declare @nDB_QUANT       decimal( 'DB_QUANT' )   -- quantidades de entrada
Declare @nDB_QTSEGUM     decimal( 'DB_QTSEGUM' ) -- quantidades de entrada para segunda unidade de medida
Declare @cDB_TM          char( 'DB_TM' )
Declare @nEDB_QUANT      decimal( 'DB_QUANT' )   -- quantidades de entrada
Declare @nEDB_QTSEGUM    decimal( 'DB_QTSEGUM' ) -- quantidades de entrada para segunda unidade de medida
Declare @nEDB_EMPENHO    decimal( 'DB_EMPENHO' ) -- quantidades de entrada empenhadas
Declare @nEDB_EMPENHO2   decimal( 'DB_EMP2' )    -- quantidades de entrada empenhadas na segunda unidade de medida
Declare @nSDB_QUANT      decimal( 'DB_QUANT' )   -- quantidades de saída
Declare @nSDB_QTSEGUM    decimal( 'DB_QTSEGUM' ) -- quantidades de saída para segunda unidade de medida
Declare @nSDB_EMPENHO    decimal( 'DB_EMPENHO' ) -- quantidades de saída empenhadas
Declare @nSDB_EMPENHO2   decimal( 'DB_EMP2' )    -- quantidades de saída empenhada na segunda unidade de medida
Declare @iRecno          Integer
Declare @cFil_SBF        Char('BF_FILIAL')
Declare @nQuant          decimal( 'DB_QUANT;BF_QUANT' )
Declare @nQuant2         decimal( 'DB_QTSEGUM;BF_QTSEGUM' )
Declare @nEmpenho        decimal( 'DB_EMPENHO' )
Declare @nEmpenho2       decimal( 'DB_EMP2' )
Declare @cEstFis         char( 'BE_ESTFIS' )
Declare @cPrior          char( 'BE_PRIOR' )
Declare @nContador       integer
Declare @iTranCount      integer  --Var.de ajuste para SQLServer e Sybase.
                                  -- Será trocada por Commit no CFGX051 após passar pelo Parse
Declare @BF_LOCAL        char('BF_LOCAL')
Declare @BF_LOCALIZ      char(15)
Declare @BF_ESTFIS       char(06)
Declare @B1_RASTRO       char('B1_RASTRO')
Declare @BE_LOCAL        char('BE_LOCAL')
Declare @BE_LOCALIZ      char('BE_LOCALIZ')
Declare @iRecnoSBF       Integer
Declare @nIN_QTSEGUM     decimal( 'B2_QTSEGUM' )

begin
    select @cAux = 'SBK'
    EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBK OutPut   
    select @cAux = 'SDB'
    EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SDB OutPut
    select @cAux = 'SBF'
    EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBF OutPut
    select @cAux = 'SBE'
    EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBE OutPut
    select @cAux = 'SB1'
    EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB1 OutPut
    
    select @nContador = 0
    declare CUR_SDB insensitive cursor for
     select DB_PRODUTO, DB_LOCAL, DB_LOTECTL, DB_NUMLOTE, DB_NUMSERI,DB_LOCALIZ
       from SDB### SDB (nolock)
      where DB_FILIAL  = @cFil_SDB
        and DB_PRODUTO = @IN_PRODUTO
        and DB_LOCAL   = @IN_LOCAL
        and DB_ESTORNO <> 'S'
        and DB_ATUEST  <> 'N'
        and ( ( DB_DATA > (
							select ISNULL( MAX(SUBSTRING(BK_DATA, 1, 8)),@IN_MV_ULMES)
							from SBK### SBKSUB (nolock)
							where SBKSUB.BK_FILIAL = @cFil_SBK
								and SBKSUB.BK_COD = SDB.DB_PRODUTO
								and SBKSUB.BK_LOCAL = SDB.DB_LOCAL
								and SBKSUB.BK_LOTECTL = SDB.DB_LOTECTL
								and SBKSUB.BK_NUMLOTE = SDB.DB_NUMLOTE
								and SBKSUB.BK_LOCALIZ = SDB.DB_LOCALIZ
								and SBKSUB.BK_NUMSERI = SDB.DB_NUMSERI
                and SBKSUB.BK_DATA >= @IN_MV_ULMES
								and SBKSUB.D_E_L_E_T_ = ' '
							)
						) 
					or ( @IN_SALDOINI = '0' )  
				)
        and D_E_L_E_T_ = ' '
      group by DB_PRODUTO, DB_LOCAL, DB_LOTECTL, DB_NUMLOTE, DB_NUMSERI,DB_LOCALIZ
    
    open CUR_SDB
    fetch CUR_SDB into @cDB_PRODUTO, @cDB_LOCAL, @cDB_LOTECTL, @cDB_NUMLOTE, @cDB_NUMSERI,@cDB_LOCALIZ
    
    while @@fetch_status = 0 begin
      
      select @nContador     = @nContador + 1
      select @nEDB_QUANT    = 0
      select @nSDB_QUANT    = 0
      select @nEDB_QTSEGUM  = 0
      select @nSDB_QTSEGUM  = 0
      select @nEDB_EMPENHO  = 0
      select @nEDB_EMPENHO2 = 0
      select @nSDB_EMPENHO  = 0
      select @nSDB_EMPENHO2 = 0

      /* ---------------------------------------------------------------------------------------------------
         Recupera a ultima data de fechamento da tabela SBK
      --------------------------------------------------------------------------------------------------- */
      select @cDtVai = max(substring(BK_DATA,1,8) )
        from SBK### SBK (nolock)
       where BK_FILIAL   = @cFil_SBK
         and BK_COD      = @cDB_PRODUTO
         and BK_LOCAL    = @cDB_LOCAL
         and BK_LOTECTL  = @cDB_LOTECTL
         and BK_NUMLOTE  = @cDB_NUMLOTE
         and BK_LOCALIZ  = @cDB_LOCALIZ
         and BK_NUMSERI  = @cDB_NUMSERI
         and BK_DATA    >= @IN_MV_ULMES
         and D_E_L_E_T_  = ' '

         if @cDtVai is null select @cDtVai = '19809901'

      /* ---------------------------------------------------------------------------------------------------
         Totalizando movimentos de entrada
      --------------------------------------------------------------------------------------------------- */
      select @nEDB_QUANT = sum( DB_QUANT ), @nEDB_QTSEGUM = sum( DB_QTSEGUM ), @nEDB_EMPENHO = sum(DB_EMPENHO), @nEDB_EMPENHO2 = sum(DB_EMP2)
        from SDB### SDB (nolock)
       where DB_FILIAL   = @cFil_SDB
         and DB_PRODUTO  = @cDB_PRODUTO
         and DB_LOCAL    = @cDB_LOCAL
         and DB_LOTECTL  = @cDB_LOTECTL
         and DB_NUMLOTE  = @cDB_NUMLOTE
         and DB_NUMSERI  = @cDB_NUMSERI
         and DB_LOCALIZ  = @cDB_LOCALIZ
         and DB_TM      <= '500'
         and DB_ESTORNO <> 'S'
         and DB_ATUEST  <> 'N'
         and ( ( DB_DATA > @cDtVai  ) or ( @IN_SALDOINI = '0' )  )
         and D_E_L_E_T_ = ' '
       
       group by DB_PRODUTO, DB_LOCAL, DB_LOTECTL, DB_NUMLOTE, DB_NUMSERI,DB_LOCALIZ
       /* ---------------------------------------------------------------------------------------------------
          Totalizando movimentos de saida
       --------------------------------------------------------------------------------------------------- */
       select @nSDB_QUANT = sum( DB_QUANT ), @nSDB_QTSEGUM = sum( DB_QTSEGUM ), @nSDB_EMPENHO = sum(DB_EMPENHO), @nSDB_EMPENHO2 = sum(DB_EMP2)
         from SDB### SDB (nolock)
        where DB_FILIAL   = @cFil_SDB
          and DB_PRODUTO  = @cDB_PRODUTO
          and DB_LOCAL    = @cDB_LOCAL
          and DB_LOTECTL  = @cDB_LOTECTL
          and DB_NUMLOTE  = @cDB_NUMLOTE
          and DB_NUMSERI  = @cDB_NUMSERI
          and DB_LOCALIZ  = @cDB_LOCALIZ
          and DB_TM       > '500'
          and DB_ESTORNO <> 'S'
          and DB_ATUEST  <> 'N'
          and ( ( DB_DATA > @cDtVai  ) or ( @IN_SALDOINI = '0' )  )
          and D_E_L_E_T_ =  ' '
        group by DB_PRODUTO, DB_LOCAL, DB_LOTECTL, DB_NUMLOTE, DB_NUMSERI,DB_LOCALIZ
       
       if (@nEDB_QUANT  is null) or (@nEDB_QUANT  < 0) select @nEDB_QUANT  = 0
       if (@nSDB_QUANT  is null) or (@nSDB_QUANT  < 0) select @nSDB_QUANT  = 0
       
       if (@nEDB_QTSEGUM  is null) or (@nEDB_QTSEGUM  < 0) select @nEDB_QTSEGUM  = 0
       if (@nSDB_QTSEGUM  is null) or (@nSDB_QTSEGUM  < 0) select @nSDB_QTSEGUM  = 0

       if (@nEDB_EMPENHO  is null) or (@nEDB_EMPENHO  < 0) select @nEDB_EMPENHO  = 0
       if (@nSDB_EMPENHO  is null) or (@nSDB_EMPENHO  < 0) select @nSDB_EMPENHO  = 0
       
       if (@nEDB_EMPENHO2  is null) or (@nEDB_EMPENHO2  < 0) select @nEDB_EMPENHO2  = 0
       if (@nSDB_EMPENHO2  is null) or (@nSDB_EMPENHO2  < 0) select @nSDB_EMPENHO2  = 0

       select @nQuant  = @nEDB_QUANT   - @nSDB_QUANT
       select @nQuant2 = @nEDB_QTSEGUM - @nSDB_QTSEGUM
       select @nEmpenho = @nEDB_EMPENHO - @nSDB_EMPENHO
       select @nEmpenho2 = @nEDB_EMPENHO2 - @nSDB_EMPENHO2
       
       /* ---------------------------------------------------------------------------------------------------------
          Obtendo a Estrutura Fisica / Prioridade do Cadastro de Enderecos
       --------------------------------------------------------------------------------------------------------- */
       select @cEstFis   = ' '
       select @cPrior    = ' '

	       select @cEstFis   = BE_ESTFIS, @cPrior  =  BE_PRIOR
	         from SBE### (nolock)
	        where BE_FILIAL  = @cFil_SBE
	          and BE_LOCAL   = @cDB_LOCAL
	          and BE_LOCALIZ = @cDB_LOCALIZ
	          and D_E_L_E_T_ = ' '
	         
	       if @cPrior is null select @cPrior  = ' '

       If @IN_INTDL = '0' begin
	       select @cEstFis   = ' '
       End
       /* --------------------------------------------------------------------------------------------------
          Atualizando arquivo SBF
       -------------------------------------------------------------------------------------------------- */
       select @iRecno     = null
       select @iRecno     = R_E_C_N_O_
         from SBF### (nolock)
        where BF_FILIAL   = @cFil_SBF
          and BF_LOCAL    = @cDB_LOCAL
          and BF_LOCALIZ  = @cDB_LOCALIZ
          and BF_ESTFIS   = @cEstFis
          and BF_PRODUTO  = @cDB_PRODUTO
          and BF_NUMSERI  = @cDB_NUMSERI
          and BF_LOTECTL  = @cDB_LOTECTL
          and BF_NUMLOTE  = @cDB_NUMLOTE
          and D_E_L_E_T_  = ' '
         
      If @nContador = 1 begin
         begin tran
         select @nContador = @nContador
      End
	  select @nIN_QTSEGUM = @nQuant2
      EXEC MAT018_## @cDB_PRODUTO, @IN_FILIALCOR, @nQuant, @nIN_QTSEGUM, 2, @nQuant2 OUTPUT

      if @iRecno is null begin
         select @iRecno = IsNull( max(R_E_C_N_O_), 0 ) from SBF###
         select @iRecno = @iRecno + 1
		 select @cEstFis = IsNull (@cEstFis, ' ')
         ##TRATARECNO @iRecno\
         insert into SBF### ( BF_FILIAL,       BF_LOCAL,        BF_LOCALIZ,      BF_PRODUTO,      BF_NUMSERI,
                            BF_LOTECTL,      BF_NUMLOTE,      BF_QUANT,        BF_QTSEGUM,      BF_ESTFIS,
                            BF_PRIOR,        BF_EMPENHO,      BF_EMPEN2,       R_E_C_N_O_ )
            values        ( @cFil_SBF,       @cDB_LOCAL,      @cDB_LOCALIZ,    @cDB_PRODUTO,    @cDB_NUMSERI,
                            @cDB_LOTECTL,    @cDB_NUMLOTE,    @nQuant,         @nQuant2,        @cEstFis,
                            @cPrior,         @nEmpenho,       @nEmpenho2,        @iRecno )      
         ##FIMTRATARECNO
      end else begin
         update SBF###
            set BF_QUANT = BF_QUANT + @nQuant, BF_QTSEGUM = BF_QTSEGUM + @nQuant2, BF_ESTFIS = @cEstFis, 
                BF_EMPENHO = BF_EMPENHO + @nEmpenho, BF_EMPEN2 = BF_EMPEN2 + @nEmpenho2
          where R_E_C_N_O_ = @iRecno
      end
      
	  /* --------------------------------------------------------------------------------------------------------------
		  Tratamento para o DB2 / MySQL
	  -------------------------------------------------------------------------------------------------------------- */
	  ##IF_001({|| AllTrim(Upper(TcGetDB())) == "DB2" .or. AllTrim(Upper(TcGetDB())) == "MYSQL" })
	  SELECT @fim_CUR = 0
	  ##ENDIF_001
      
      fetch CUR_SDB into @cDB_PRODUTO, @cDB_LOCAL, @cDB_LOTECTL, @cDB_NUMLOTE, @cDB_NUMSERI,@cDB_LOCALIZ
      
      If @nContador > 1023 begin
         Commit Tran
         select @nContador = 0
      End
      
   end               
   close CUR_SDB
   deallocate CUR_SDB
   If @nContador > 0 begin
      Commit Tran
      select @iTranCount = 0
   End

end
