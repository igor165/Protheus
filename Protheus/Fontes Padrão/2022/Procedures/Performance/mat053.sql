Create procedure MAT053_##
( 
	@IN_FILIALCOR	Char('B1_FILIAL'),
	@IN_DELOCAL     Char('B1_LOCPAD'),
	@IN_ATELOCAL	Char('B1_LOCPAD'), 
	@IN_MV_PAR03	Char('B1_COD'),
	@IN_MV_PAR04	Char('B1_COD'),
    @IN_L300SALNEG  Char(01),
	@IN_MV_WMSNEW   Char(01),
	@IN_MV_NEGATBF  Char(01),
	@IN_MV_ARQPROD  Char(03),
	@OUT_RESULTADO  Char(01) OutPut
)

as


/* ---------------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Protheus P12 </v>
    -----------------------------------------------------------------------------------------------------------------    
    Programa    :   <s> mata300.prx  </s>
    -----------------------------------------------------------------------------------------------------------------    
    Assinatura  :   <a> 002 </a>
    -----------------------------------------------------------------------------------------------------------------    
    Descricao   :   <d> Realiza ajustes no campo de status BE_STATUS </d>
    -----------------------------------------------------------------------------------------------------------------
    Entrada     :  <ri> @IN_FILIALCOR  - Filial corrente
                        @IN_DELOCAL    - Local de Processamento (Almoxarifado) : DE
                        @IN_ATELOCAL   - Local de Processamento (Almoxarifado) : ATE
                        @IN_MV_PAR03   - Produto Inicial
                        @IN_MV_PAR04   - Produto Final
    -----------------------------------------------------------------------------------------------------------------
    Saida       :  <ro> @OUT_RESULTADO - Retorno de processamento </ro>
    -----------------------------------------------------------------------------------------------------------------
    Observações :   <o>   </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Marcos V. Ferreira </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 12/03/2008 </dt>

    Estrutura de chamadas
    ========= == ========

     0. MAT053 - Atualiza status do campo BE_STATUS

    -----------------------------------------------------------------------------------------------------------------
    Obs.: Não remova os tags acima. Os tags são a base para a geração automática, de documentação, pelo Parse.
--------------------------------------------------------------------------------------------------------------------- */

Declare @cFil_SB1        Char('B1_FILIAL')
Declare @cFil_SBF        Char('BF_FILIAL')
Declare @cFil_SBE        Char('BE_FILIAL')
Declare @cFil_D14        Char('BE_FILIAL')
Declare @iRecnoSBE       integer

Declare @cProduto        char('B1_COD') 	
Declare @lLocaliz        char(01)
Declare @lIntDl			 char(01)
Declare @cAux            Varchar(3)
Declare @BF_LOCAL        char('B1_LOCPAD')
Declare @BF_LOCALIZ      char(15)

Declare @nResult	     char(01)

begin
   select @OUT_RESULTADO = '0'
   /* ------------------------------------------------------------------------------------------------------------------
      Recuperando Filiais
   ------------------------------------------------------------------------------------------------------------------ */
   select @cAux = 'SB1'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB1 OutPut
   select @cAux = 'SBF'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBF OutPut
   select @cAux = 'SBE'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBE OutPut
   select @cAux = 'D14'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_D14 OutPut
   
   /* ------------------------------------------------------------------------------------------------------------------
      Declara cursor para a Select de Produtos a Serem calculados 
   ------------------------------------------------------------------------------------------------------------------ */
   declare LISTA_DE_PROD insensitive cursor for
       select B1_COD 
          from SB1### (NoLock) 
          Where B1_FILIAL   = @cFil_SB1
			and B1_COD between @IN_MV_PAR03 and @IN_MV_PAR04
            and D_E_L_E_T_  = ' '
   for read only
   
   open LISTA_DE_PROD
   fetch LISTA_DE_PROD into @cProduto
   
   while (@@Fetch_Status = 0) begin
      
       /* ---------------------------------------------------------------------------------------------------------
          Processar arquivos de endereçamento
       --------------------------------------------------------------------------------------------------------- */
       exec MAT012_## @cProduto, @IN_FILIALCOR, @IN_MV_WMSNEW, @IN_MV_ARQPROD, @lLocaliz output
            
		if @lLocaliz = '1'  begin
			if @IN_MV_WMSNEW = '1'
				exec MAT057_## @cProduto, @IN_FILIALCOR, @lIntDl output
			else select @lIntDl = '0'

		   /* -------------------------------------------------------------------------------------------------------
			  Deleta movimentação negativa ou zerada
		   ------------------------------------------------------------------------------------------------------- */
		   if Not (@IN_MV_WMSNEW = '1' and @lIntDl = '1') and @IN_MV_NEGATBF = '0' begin
			   if ( @IN_L300SALNEG = '1' ) begin
				  begin tran
				  delete 
					from SBF###
				   where BF_FILIAL   =  @cFil_SBF
					 and BF_PRODUTO  =  @cProduto
					 and BF_LOCAL    >= @IN_DELOCAL
					 and BF_LOCAL    <= @IN_ATELOCAL
					 and BF_QUANT    = 0
				  commit tran
			   end Else begin 
				  begin tran
				  delete
					from SBF###
				   where BF_FILIAL    = @cFil_SBF
					 and BF_PRODUTO   = @cProduto
					 and BF_LOCAL    >= @IN_DELOCAL
					 and BF_LOCAL    <= @IN_ATELOCAL
					 and BF_QUANT    <= 0
				  commit tran
			   end
		   end

          /* ------------------------------------------------------------------------------------------------------
             Altera o Status do Endereco no SBE para Livre caso este NAO possua saldo no SBF
           ------------------------------------------------------------------------------------------------------ */
           -- Declaracao do cursor CUR_SBF1
		   if @IN_MV_WMSNEW = '0' begin	

				declare CUR_SBF1 insensitive  cursor for
				Select BF_LOCAL, BF_LOCALIZ
					from SBF### (nolock)
					where BF_FILIAL   = @cFil_SBF
					and BF_PRODUTO  = @cProduto
					and BF_LOCAL   >= @IN_DELOCAL
					and BF_LOCAL   <= @IN_ATELOCAL
					and BF_QUANT   <= 0
					and D_E_L_E_T_  = ' '
               
				open CUR_SBF1
				fetch CUR_SBF1 into @BF_LOCAL, @BF_LOCALIZ
				while ( @@fetch_status = 0 ) begin
					Select @iRecnoSBE = null
					Select @iRecnoSBE = Isnull(SBE.R_E_C_N_O_,0)
                    from SBE### SBE
                    where BE_FILIAL  = @cFil_SBE
                      and BE_LOCAL   = @BF_LOCAL
                      and BE_LOCALIZ = @BF_LOCALIZ
                      and BE_STATUS NOT IN ( '1','3','4','5','6' )
                      and SBE.D_E_L_E_T_ = ' '
                   /* --------------------------------------------------------------------------------------------------
                      Altera o Status do Endereco no SBE para Livre caso este NAO possua saldo no SBF
                   --------------------------------------------------------------------------------------------------- */
                   if @iRecnoSBE  > 0 begin
                     update SBE###
                        set BE_STATUS  = '1'
                        where R_E_C_N_O_ = @iRecnoSBE
                   end
                   /* --------------------------------------------------------------------------------------------------------------
                     Tratamento para o DB2
                   -------------------------------------------------------------------------------------------------------------- */
					SELECT @fim_CUR = 0
					fetch CUR_SBF1 into @BF_LOCAL, @BF_LOCALIZ
				end
				close CUR_SBF1
				deallocate CUR_SBF1

			end else begin

				declare CUR_SBFD14 insensitive  cursor for
				Select BF_LOCAL, BF_LOCALIZ
					from SBF### (nolock)
					where BF_FILIAL   = @cFil_SBF
					and BF_PRODUTO  = @cProduto
					and BF_LOCAL   >= @IN_DELOCAL
					and BF_LOCAL   <= @IN_ATELOCAL
					and BF_QUANT   <= 0
					and D_E_L_E_T_  = ' '
						Union
							Select D14_LOCAL, D14_ENDER
							from D14### (nolock)
							where D14_FILIAL   = @cFil_D14
								and D14_PRODUT  = @cProduto
								and D14_LOCAL   >= @IN_DELOCAL
								and D14_LOCAL   <= @IN_ATELOCAL
								and D14_QTDEST  <= 0
								and D_E_L_E_T_  = ' '
					open CUR_SBFD14
					fetch CUR_SBFD14 into @BF_LOCAL, @BF_LOCALIZ
              while ( @@fetch_status = 0 ) begin
                   Select @iRecnoSBE = null
                   Select @iRecnoSBE = Isnull(SBE.R_E_C_N_O_,0)
                     from SBE### SBE
                     where BE_FILIAL  = @cFil_SBE
                       and BE_LOCAL   = @BF_LOCAL
                       and BE_LOCALIZ = @BF_LOCALIZ
                       and BE_STATUS NOT IN ( '1','3','4','5','6' )
                       and SBE.D_E_L_E_T_ = ' '
                   /* --------------------------------------------------------------------------------------------------
                      Altera o Status do Endereco no SBE para Livre caso este NAO possua saldo no SBF
                   --------------------------------------------------------------------------------------------------- */
                   if @iRecnoSBE  > 0 begin
                     update SBE###
                        set BE_STATUS  = '1'
                        where R_E_C_N_O_ = @iRecnoSBE
                   end
                   /* --------------------------------------------------------------------------------------------------------------
                     Tratamento para o DB2
                   -------------------------------------------------------------------------------------------------------------- */
                   SELECT @fim_CUR = 0
						fetch CUR_SBFD14 into @BF_LOCAL, @BF_LOCALIZ
					end
				close CUR_SBFD14
				deallocate CUR_SBFD14
			end

          /* ------------------------------------------------------------------------------------------------------
             Altera o Status do Endereco no SBE para Ocupado caso este possua saldo no SBF
           ------------------------------------------------------------------------------------------------------ */
           -- Declaracao do cursor CUR_SBF2
			if @IN_MV_WMSNEW = '0' begin

				declare CUR_SBF2 insensitive  cursor for
				Select BF_LOCAL, BF_LOCALIZ
					from SBF### (nolock)
					where BF_FILIAL   = @cFil_SBF
					and BF_PRODUTO  = @cProduto
					and BF_LOCAL   >= @IN_DELOCAL
					and BF_LOCAL   <= @IN_ATELOCAL
					and BF_QUANT   >  0
					and D_E_L_E_T_  = ' '
					open CUR_SBF2
					fetch CUR_SBF2 into @BF_LOCAL, @BF_LOCALIZ
				while ( @@fetch_status = 0 ) begin
					Select @iRecnoSBE = null
					Select @iRecnoSBE = Isnull(SBE.R_E_C_N_O_,0)
					from SBE### SBE
					where BE_FILIAL  = @cFil_SBE
					and BE_LOCAL   = @BF_LOCAL
					and BE_LOCALIZ = @BF_LOCALIZ
					and BE_STATUS  NOT IN ( '2','3','4','5','6')
					and SBE.D_E_L_E_T_  = ' '
					/* --------------------------------------------------------------------------------------------------
					Altera o Status do Endereco no SBE para Ocupado caso este possua saldo no SBF
					--------------------------------------------------------------------------------------------------- */
					if @iRecnoSBE  > 0 begin
						update SBE###
						set BE_STATUS  = '2'
						where R_E_C_N_O_ = @iRecnoSBE
					end

					/* --------------------------------------------------------------------------------------------------------------
						Tratamento para o DB2
					-------------------------------------------------------------------------------------------------------------- */
					SELECT @fim_CUR = 0
					fetch CUR_SBF2 into @BF_LOCAL, @BF_LOCALIZ
				end
				close CUR_SBF2
				deallocate CUR_SBF2 

			end else begin

				declare CUR_SBF2D14 insensitive  cursor for
				Select BF_LOCAL, BF_LOCALIZ
					from SBF### (nolock)
				where BF_FILIAL   = @cFil_SBF
					and BF_PRODUTO  = @cProduto
					and BF_LOCAL   >= @IN_DELOCAL
					and BF_LOCAL   <= @IN_ATELOCAL
					and BF_QUANT   >  0
					and D_E_L_E_T_  = ' '
				Union
				Select D14_LOCAL, D14_ENDER
					from D14### (nolock)
				where D14_FILIAL    = @cFil_D14
					and D14_PRODUT  = @cProduto
					and D14_LOCAL   >= @IN_DELOCAL
					and D14_LOCAL   <= @IN_ATELOCAL
					and D14_QTDEST  >  0
					and D_E_L_E_T_  = ' '
				open CUR_SBF2D14
				fetch CUR_SBF2D14 into @BF_LOCAL, @BF_LOCALIZ

              while ( @@fetch_status = 0 ) begin
                   Select @iRecnoSBE = null
                   Select @iRecnoSBE = Isnull(SBE.R_E_C_N_O_,0)
                     from SBE### SBE
                     where BE_FILIAL  = @cFil_SBE
                       and BE_LOCAL   = @BF_LOCAL
                       and BE_LOCALIZ = @BF_LOCALIZ
                       and BE_STATUS  NOT IN ( '2','3','4','5','6')
                       and SBE.D_E_L_E_T_  = ' '
                   /* --------------------------------------------------------------------------------------------------
                      Altera o Status do Endereco no SBE para Ocupado caso este possua saldo no SBF
                   --------------------------------------------------------------------------------------------------- */
                   if @iRecnoSBE  > 0 begin
                     update SBE###
                        set BE_STATUS  = '2'
                        where R_E_C_N_O_ = @iRecnoSBE
                   end

                   /* --------------------------------------------------------------------------------------------------------------
                     Tratamento para o DB2
                   -------------------------------------------------------------------------------------------------------------- */
                   SELECT @fim_CUR = 0
                  
					fetch CUR_SBF2D14 into @BF_LOCAL, @BF_LOCALIZ
				end 
			close CUR_SBF2D14
			deallocate CUR_SBF2D14
		end    

       end
      /* -------------------------------------------------------------------------------------------------------------
         Tratamento para o DB2
      -------------------------------------------------------------------------------------------------------------- */
      SELECT @fim_CUR = 0
      fetch LISTA_DE_PROD into @cProduto
   end

   close LISTA_DE_PROD
   deallocate LISTA_DE_PROD

   /* -------------------------------------------------------------------------------------------------------
      Atualiza o BE_STATUS com "1" se existir SBE que nao tem no SBF
   ------------------------------------------------------------------------------------------------------- */
   If @IN_MV_WMSNEW = '0' begin
        ##IF_001({|| Trim(TcGetDb()) <> "SYBASE" })
		Update SBE###
		set BE_STATUS = '1' 
		where BE_FILIAL = @cFil_SBE
			and not exists ( select 1
								from SBF### SBF
								where SBF.BF_FILIAL  = @cFil_SBF
									and SBF.BF_LOCAL   = BE_LOCAL  
									and SBF.BF_LOCALIZ = BE_LOCALIZ  
									and SBF.D_E_L_E_T_ = ' ') 

			and BE_STATUS   = '2'
			and D_E_L_E_T_  = ' '
			
		##ELSE_001
		Update SBE###
		set BE_STATUS = '1' From SBE### SBE
		where BE_FILIAL = @cFil_SBE
			and not exists ( select 1
								from SBF### SBF
								where SBF.BF_FILIAL  = @cFil_SBF
									and SBF.BF_LOCAL   = SBE.BE_LOCAL 
									and SBF.BF_LOCALIZ = SBE.BE_LOCALIZ 
									and SBF.D_E_L_E_T_ = ' ') 

			and BE_STATUS   = '2'
			and D_E_L_E_T_  = ' '
		##ENDIF_001

		Select @OUT_RESULTADO = '1' 

	end else begin
        ##IF_002({|| Trim(TcGetDb()) <> "SYBASE" })
		Update SBE###
		set BE_STATUS = '1' 
		where BE_FILIAL = @cFil_SBE
		and not exists ( select 1
							from SBF### SBF
							where SBF.BF_FILIAL    = @cFil_SBF
								and SBF.BF_LOCAL   = BE_LOCAL  
								and SBF.BF_LOCALIZ = BE_LOCALIZ  
								and SBF.D_E_L_E_T_ = ' ' 
						union
							select 1
								from D14### D14  
								where D14.D14_FILIAL   = @cFil_D14
									and D14.D14_LOCAL  = BE_LOCAL  
									and D14.D14_ENDER  = BE_LOCALIZ  
									and D14.D_E_L_E_T_ = ' ') 

		and BE_STATUS   = '2'
		and D_E_L_E_T_  = ' '
		##ELSE_002
		Update SBE###
		set BE_STATUS = '1' From SBE### SBE 
		where BE_FILIAL = @cFil_SBE
		and not exists ( select 1
							from SBF### SBF
							where SBF.BF_FILIAL    = @cFil_SBF
								and SBF.BF_LOCAL   = SBE.BE_LOCAL 
								and SBF.BF_LOCALIZ = SBE.BE_LOCALIZ 
								and SBF.D_E_L_E_T_ = ' ' 
						union
							select 1
								from D14### D14  
								where D14.D14_FILIAL   = @cFil_D14
									and D14.D14_LOCAL  = SBE.BE_LOCAL 
									and D14.D14_ENDER  = SBE.BE_LOCALIZ 
									and D14.D_E_L_E_T_ = ' ') 

		and BE_STATUS   = '2'
		and D_E_L_E_T_  = ' '
		##ENDIF_002

		Select @OUT_RESULTADO = '1' 
	end
end
