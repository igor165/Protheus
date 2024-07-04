Create procedure CTB006_##
 ( 
   @IN_FILIALCOR  Char('CV1_FILIAL'),
   @IN_CV1_CT1INI Char('CV1_CT1INI'),
   @IN_CV1_CT1FIM Char('CV1_CT1FIM'),
   @IN_CT1        Char(01),
   @IN_CV1_MOEDA  Char('CV1_MOEDA'),
   @IN_CV1_DTFIM  Char('CV1_DTFIM'),
   @IN_CV1_VALOR  Float,
   @IN_COPERACAO  Char(01),
   @IN_FATORCTH   Integer,
   @IN_FATORCTD   Integer,
   @IN_FATORCTT   Integer,
   @OUT_RESULTADO Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Grava os saldos do arquivo CQ1/d>
    Funcao do Siga  -     Ctb390CTT() - Grava os saldos o arquivo CQ1
    Fonte Microsiga - <s> CTBA390.PRW </s>
    Entrada         - <ri> @IN_FILIALCOR  - Filial
                           @IN_CV1_CT1INI - Conta Inicial
                           @IN_CV1_CT1FIM - Conta Final
                           @IN_CT1        - Flag Conta Orcada
                           @IN_CV1_MOEDA  - Moeda
                           @IN_CV1_DTFIM  - Data
                           @IN_CV1_VALOR  - Valor
                           @IN_COPERACAO  - Operacao
                           @IN_FATORCTH   - Fator de Multiplicacao para o CONTA
                           @IN_FATORCTD   - Fator de Multiplicacao para o CONTA
                           @IN_FATORCTT   - Fator de Multiplicacao para o CONTA
    Saida           - <ro> @OUT_RESULTADO - Indica o termino OK da procedure </ro>
    Responsavel :     <r> Marco Norbiato	</r>
    Data        :     19/09/2003
-------------------------------------------------------------------------------------- */
declare @cFilial_CT1   char('CT1_FILIAL')
declare @cFilial_CQ0   char('CQ0_FILIAL')
declare @cFilial_CQ1   char('CQ1_FILIAL')
declare @cAux          varchar(03)
declare @iRecno        int
declare @cTab          Char(03)
declare @cCTXX_CONTA   char('CT1_CONTA')
declare @cCTXX_NORMAL  char('CT1_NORMAL')
declare @cCTXX_CUSTO   char('CTT_CUSTO')
declare @cCTXX_ITEM    char('CTD_ITEM')
declare @nCTXX_DEBITO  float
declare @nCTXX_CREDIT  float
declare @cTpSaldo      Char('CQ0_TPSALD')
declare @cStatus       Char('CQ0_STATUS')
declare @cSlBase       Char('CQ0_SLBASE')
declare @cDtLp         Char(08)
declare @cDataF        Char(08)
declare @cLp           Char('CQ0_LP')
declare @iRepete       Integer

begin
   
   select @cAux = 'CT1'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CT1 OutPut
   select @cAux = 'CQ0'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ0 OutPut
   select @cAux = 'CQ1'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ1 OutPut

   Exec LASTDAY_## @IN_CV1_DTFIM, @cDataF OutPut
   
   Select @OUT_RESULTADO = '0'
   Select @cCTXX_NORMAL = ' '
   Select @nCTXX_DEBITO = 0
   Select @nCTXX_CREDIT = 0
   select @cTpSaldo = '0'
   select @cStatus  = '1'
   select @cSlBase  = 'S'
   select @cDtLp    = ' '
   select @cLp      = 'N'

   
   If ( ( @IN_CV1_CT1INI = @IN_CV1_CT1FIM )  )  begin
      
      select @cCTXX_CONTA = @IN_CV1_CT1INI
      
      select @cCTXX_NORMAL = CT1_NORMAL
        from CT1###
       where CT1_FILIAL = @cFilial_CT1
         and CT1_CONTA  = @cCTXX_CONTA
         and D_E_L_E_T_ = ' '
      /* ------------------------------------------------------------
         ATUALIZAÇÃO DO CQ1 - DIA
         ------------------------------------------------------------*/            
      select @iRecno   = IsNull(R_E_C_N_O_, 0), @nCTXX_CREDIT = CQ1_CREDIT, @nCTXX_DEBITO = CQ1_DEBITO
        from CQ1###
       where CQ1_FILIAL = @cFilial_CQ1
         and CQ1_MOEDA  = @IN_CV1_MOEDA
         and CQ1_TPSALD = '0'
         and CQ1_CONTA  = @cCTXX_CONTA
         and CQ1_DATA   = @IN_CV1_DTFIM
         and D_E_L_E_T_ = ' '
      /* ------------------------------------------------------------
         Verifica se a debito ou credito
         ------------------------------------------------------------*/
      if ( @IN_COPERACAO = '1' ) begin
         if ( @IN_CT1 = '1' ) begin --Se tiver conta, verificar a natureza da conta.
            If ( @cCTXX_NORMAL = '1' ) begin
               If ( @IN_CV1_VALOR < 0 ) begin
                  select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + ( Abs( @IN_CV1_VALOR ) * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT ), 2 )
               end else begin
                  select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT, 2 )
               end
		      end else begin
               If ( @IN_CV1_VALOR < 0 ) begin
                  select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + (Abs(@IN_CV1_VALOR) * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT), 2 )
               end else begin
                  select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT, 2 )
               end
            end
         end else begin  --Se nao tiver conta no orcamento, considerar como devedor
            If ( @IN_CV1_VALOR < 0 ) begin
               select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + ( Abs( @IN_CV1_VALOR ) * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT ), 2 )
            end else begin
               select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT, 2 )
            end
         end
      end
      
      if ( @iRecno is Null or @iRecno = 0 ) begin
            /* ------------------------------------------------------------
               Insert no CQ1
               ------------------------------------------------------------*/
            select @iRecno = 0
			
			##UNIQUEKEY_START
            select @iRecno = isnull( max( R_E_C_N_O_ ), 0 ) 
			from CQ1###
			where CQ1_FILIAL		= @cFilial_CQ1
				  and CQ1_DATA		= @IN_CV1_DTFIM
				  and CQ1_CONTA		= @cCTXX_CONTA
				  and CQ1_MOEDA		= @IN_CV1_MOEDA
				  and CQ1_TPSALD	= @cTpSaldo
				  and CQ1_LP		= @cLp
				  and D_E_L_E_T_	= ' '
			##UNIQUEKEY_END		  
            
            If @iRecno = 0 Begin
				
				select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ1###					
				select @iRecno = @iRecno + 1
				
				##TRATARECNO @iRecno\
				begin tran
				Insert into CQ1### ( CQ1_FILIAL,   CQ1_CONTA,    CQ1_MOEDA,     CQ1_DATA,      CQ1_TPSALD, CQ1_SLBASE,
									 CQ1_DTLP,     CQ1_LP,       CQ1_STATUS,    CQ1_DEBITO,    CQ1_CREDIT,    R_E_C_N_O_ )
							 values( @cFilial_CQ1, @cCTXX_CONTA, @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
									 @cDtLp,       @cLp,         @cStatus,      0, 0, @iRecno )
				commit tran
				##FIMTRATARECNO
			end
	   end
		
		/* ------------------------------------------------------------
		UPDATE no CQ1
		------------------------------------------------------------*/
		begin tran
			update CQ1### 
				set CQ1_DEBITO = CQ1_DEBITO + @nCTXX_DEBITO, CQ1_CREDIT = CQ1_CREDIT + @nCTXX_CREDIT
			where R_E_C_N_O_ =  @iRecno 
		commit tran				
			
      /* ------------------------------------------------------------
         ATUALIZAÇÃO DO CQ0 - MES
         ------------------------------------------------------------*/            
      select @iRecno   = IsNull(R_E_C_N_O_, 0), @nCTXX_CREDIT = CQ0_CREDIT, @nCTXX_DEBITO = CQ0_DEBITO
        from CQ0###
       where CQ0_FILIAL = @cFilial_CQ0
         and CQ0_MOEDA  = @IN_CV1_MOEDA
         and CQ0_TPSALD = '0'
         and CQ0_CONTA  = @cCTXX_CONTA
         and CQ0_DATA   = @cDataF
         and D_E_L_E_T_ = ' '
      /* ------------------------------------------------------------
         Verifica se a debito ou credito
         ------------------------------------------------------------*/
      if ( @IN_COPERACAO = '1' ) begin
         if ( @IN_CT1 = '1' ) begin --Se tiver conta, verificar a natureza da conta.
            If ( @cCTXX_NORMAL = '1' ) begin
               If ( @IN_CV1_VALOR < 0 ) begin
                  select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + ( Abs( @IN_CV1_VALOR ) * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT ), 2 )
               end else begin
                  select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT, 2 )
               end
		      end else begin
               If ( @IN_CV1_VALOR < 0 ) begin
                  select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + (Abs(@IN_CV1_VALOR) * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT), 2 )
               end else begin
                  select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT, 2 )
               end
            end
         end else begin  --Se nao tiver conta no orcamento, considerar como devedor
            If ( @IN_CV1_VALOR < 0 ) begin
               select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + ( Abs( @IN_CV1_VALOR ) * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT ), 2 )
            end else begin
               select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT, 2 )
            end
         end
      end
      
      if ( @iRecno is Null or @iRecno = 0 ) begin
            /* ------------------------------------------------------------
               Insert no CQ0
               ------------------------------------------------------------*/
			   
            select @iRecno = 0
			
			##UNIQUEKEY_START
            select @iRecno = isnull( max( R_E_C_N_O_ ), 0 ) 
			from CQ0###
			where CQ0_FILIAL		= @cFilial_CQ0
				  and CQ0_DATA		= @cDataF
				  and CQ0_CONTA		= @cCTXX_CONTA
				  and CQ0_MOEDA		= @IN_CV1_MOEDA
				  and CQ0_TPSALD	= @cTpSaldo
				  and CQ0_LP		= @cLp
				  and D_E_L_E_T_	= ' '
            ##UNIQUEKEY_END
			
            If @iRecno = 0 Begin

				select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ0###					
				select @iRecno = @iRecno + 1			

				##TRATARECNO @iRecno\
				begin tran
				Insert into CQ0### ( CQ0_FILIAL,   CQ0_CONTA,    CQ0_MOEDA,     CQ0_DATA,      CQ0_TPSALD, CQ0_SLBASE,
									 CQ0_DTLP,     CQ0_LP,       CQ0_STATUS,    CQ0_DEBITO,    CQ0_CREDIT,    R_E_C_N_O_ )
							 values( @cFilial_CQ0, @cCTXX_CONTA, @IN_CV1_MOEDA, @cDataF,       @cTpSaldo,  @cSlBase,
									 @cDtLp,       @cLp,         @cStatus,      0, 0, @iRecno )
				commit tran
				##FIMTRATARECNO
			end
				
			
	  end	
	  
	  /* ------------------------------------------------------------
		UPDATE no CQ0
		------------------------------------------------------------*/
		begin tran
			update CQ0### 
				set CQ0_DEBITO = CQ0_DEBITO + @nCTXX_DEBITO, CQ0_CREDIT = CQ0_CREDIT + @nCTXX_CREDIT
			where R_E_C_N_O_ =  @iRecno 
		commit tran	
		
   end else begin
      select @iRepete = 1
      
      While @iRepete <= 2 begin
         If @iRepete = 1 begin
            
            declare Ctb390CQ1_1 Insensitive cursor for
            Select CT1_CONTA, CT1_NORMAL
              From CT1### CT1
             Where CT1.CT1_FILIAL = @cFilial_CT1
               and CT1.CT1_CONTA between @IN_CV1_CT1INI and @IN_CV1_CT1FIM
               and CT1.CT1_CLASSE = '2'
               and CT1.D_E_L_E_T_ = ' '
               and 0 = ( Select Count(*)
                           From CQ1### CQ1
                          Where CQ1.CQ1_FILIAL = @cFilial_CQ1
                            and CQ1.CQ1_CONTA  = CT1.CT1_CONTA
                            and CQ1.CQ1_DATA   = @IN_CV1_DTFIM
                            and CQ1.CQ1_MOEDA  = @IN_CV1_MOEDA
                            and CQ1.CQ1_TPSALD = '0'
                            and CQ1.D_E_L_E_T_ = ' ' ) 
            for read only
            open Ctb390CQ1_1
            fetch Ctb390CQ1_1 into @cCTXX_CONTA, @cCTXX_NORMAL
            
            while ( @@fetch_status = 0 ) begin
               
               select @nCTXX_DEBITO = 0
               select @nCTXX_CREDIT = 0
               /* ------------------------------------------------------------
                  Insert no CQ1
                  ------------------------------------------------------------*/
               select @iRecno = 0               
               
			   ##UNIQUEKEY_START
			   select @iRecno = isnull( max( R_E_C_N_O_ ), 0 ) 
			   from CQ1###
			   where CQ1_FILIAL		= @cFilial_CQ1
					 and CQ1_DATA	= @cDataF
					 and CQ1_CONTA	= @cCTXX_CONTA
					 and CQ1_MOEDA	= @IN_CV1_MOEDA
					 and CQ1_TPSALD	= @cTpSaldo
					 and CQ1_LP		= @cLp
					 and D_E_L_E_T_	= ' '
			   ##UNIQUEKEY_END	
			   
               If @iRecno = 0 Begin
			   
					select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ1###										
					select @iRecno = @iRecno + 1					
					
				   ##TRATARECNO @iRecno\
				   begin tran
				   Insert into CQ1### ( CQ1_FILIAL,   CQ1_CONTA,    CQ1_MOEDA,     CQ1_DATA,      CQ1_TPSALD, CQ1_SLBASE,
										CQ1_DTLP,     CQ1_LP,       CQ1_STATUS,    CQ1_DEBITO,    CQ1_CREDIT,  R_E_C_N_O_ )
								values( @cFilial_CQ1, @cCTXX_CONTA, @IN_CV1_MOEDA, @cDataF,       @cTpSaldo,  @cSlBase,
										@cDtLp,       @cLp,         @cStatus,      0, 0, @iRecno )
				   commit tran
				   ##FIMTRATARECNO
				   
			   end
			   
				/* ------------------------------------------------------------
				UPDATE no CQ1
				------------------------------------------------------------*/
				begin tran
					update CQ1### 
						set CQ1_DEBITO = CQ1_DEBITO + @nCTXX_DEBITO, CQ1_CREDIT = CQ1_CREDIT + @nCTXX_CREDIT
					where R_E_C_N_O_ =  @iRecno 
				commit tran				   
			   
               /* ------------------------------------------------------------
                  Insert no CQ0
                  ------------------------------------------------------------*/
               select @iRecno = 0  
			   
			   ##UNIQUEKEY_START			   
               select @iRecno = isnull( max( R_E_C_N_O_ ), 0 ) 
			   from CQ0###
			   where CQ0_FILIAL		= @cFilial_CQ0
					 and CQ0_DATA	= @cDataF
					 and CQ0_CONTA	= @cCTXX_CONTA
					 and CQ0_MOEDA	= @IN_CV1_MOEDA
					 and CQ0_TPSALD	= @cTpSaldo
					 and CQ0_LP		= @cLp
					 and D_E_L_E_T_	= ' '
			   ##UNIQUEKEY_END			 
			   
               If @iRecno = 0 Begin
					
					select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ0###					
					select @iRecno = @iRecno + 1					
					
				   ##TRATARECNO @iRecno\
				   begin tran
				   Insert into CQ0### ( CQ0_FILIAL,   CQ0_CONTA,    CQ0_MOEDA,     CQ0_DATA,      CQ0_TPSALD, CQ0_SLBASE,
										CQ0_DTLP,     CQ0_LP,       CQ0_STATUS,    CQ0_DEBITO,    CQ0_CREDIT,  R_E_C_N_O_ )
								values( @cFilial_CQ0, @cCTXX_CONTA, @IN_CV1_MOEDA, @cDataF,       @cTpSaldo,  @cSlBase,
										@cDtLp,       @cLp,         @cStatus,      0, 0, @iRecno )
				   commit tran
				   ##FIMTRATARECNO
               end
			   
			/* ------------------------------------------------------------
			UPDATE no CQ0
			------------------------------------------------------------*/
			begin tran
				update CQ0### 
					set CQ0_DEBITO = CQ0_DEBITO + @nCTXX_DEBITO, CQ0_CREDIT = CQ0_CREDIT + @nCTXX_CREDIT
				where R_E_C_N_O_ =  @iRecno 
			commit tran				   
			   
               SELECT @fim_CUR = 0   
               fetch Ctb390CQ1_1 into @cCTXX_CONTA, @cCTXX_NORMAL
            end
            close      Ctb390CQ1_1
            deallocate Ctb390CQ1_1
            
         end else begin
            /* ------------------------------------------------------------
               @iRepete = 2
               Update no CQ1
               ------------------------------------------------------------*/
            declare Ctb390CQ1_2 Insensitive cursor for
               select R_E_C_N_O_ , IsNull(CQ1_CONTA,' '), CQ1_DEBITO, CQ1_CREDIT
                 from CQ1###
                where CQ1_FILIAL = @cFilial_CQ1
                  and CQ1_CONTA  between @IN_CV1_CT1INI and @IN_CV1_CT1FIM
                  and CQ1_DATA   = @IN_CV1_DTFIM
                  and CQ1_MOEDA  = @IN_CV1_MOEDA
                  and CQ1_TPSALD = '0'
                  and D_E_L_E_T_ = ' '
            for read only
            open Ctb390CQ1_2
            
            fetch Ctb390CQ1_2 into @iRecno, @cCTXX_CONTA, @nCTXX_DEBITO, @nCTXX_CREDIT
            
            while ( @@fetch_status = 0 ) begin
               
               Select @cCTXX_NORMAL = IsNull(CT1_NORMAL, ' ')
                 From CT1###
                Where CT1_FILIAL = @cFilial_CT1
                  and CT1_CONTA  = @cCTXX_CONTA
                  and CT1_CLASSE = '2'
                  and D_E_L_E_T_ = ' '
               
               If ( @cCTXX_NORMAL = '1' ) begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT, 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + (@IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT ), 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end
   		      end else begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + (Abs(@IN_CV1_VALOR) * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT ), 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + ( @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT), 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end
               end
               /* ------------------------------------------------------------
                  Update no CQ1
                  ------------------------------------------------------------*/
               begin tran
               update CQ1###
                  set CQ1_DEBITO = @nCTXX_DEBITO, CQ1_CREDIT = @nCTXX_CREDIT
                where R_E_C_N_O_ = @iRecno
               commit tran
               /* ------------------------------------------------------------
                  ATUALIZA DEBITO/CERDITO CQ0 MES
                  ------------------------------------------------------------*/
               select @nCTXX_DEBITO = 0 
               select @nCTXX_CREDIT = 0 
               
               select @iRecno = 0
               select @iRecno = IsNull(R_E_C_N_O_, 0), @nCTXX_DEBITO = CQ0_DEBITO, @nCTXX_CREDIT = CQ0_CREDIT
                 from CQ0###
                where CQ0_FILIAL = @cFilial_CQ0
                  and CQ0_CONTA  = @cCTXX_CONTA
                  and CQ0_DATA   = @cDataF
                  and CQ0_MOEDA  = @IN_CV1_MOEDA
                  and CQ0_TPSALD = '0'
                  and D_E_L_E_T_ = ' '
               /* ------------------------------------------------------------
                  Verifica se a debito ou credito
                  ------------------------------------------------------------*/
               If ( @cCTXX_NORMAL = '1' ) begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT, 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + (@IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT ), 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end
   		      end else begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + (Abs(@IN_CV1_VALOR) * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT ), 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + ( @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD * @IN_FATORCTT), 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end
               end
               if ( @iRecno is Null or @iRecno = 0 ) begin
                     /* ------------------------------------------------------------
                        Insert no CQ0
                        ------------------------------------------------------------*/
                     select @iRecno = 0
					 ##UNIQUEKEY_START
                     select @iRecno = isnull( max( R_E_C_N_O_ ), 0 ) 
					 from CQ0###
					 where CQ0_FILIAL		= @cFilial_CQ0
						   and CQ0_DATA		= @cDataF
						   and CQ0_CONTA	= @cCTXX_CONTA
						   and CQ0_MOEDA	= @IN_CV1_MOEDA
						   and CQ0_TPSALD	= @cTpSaldo
						   and CQ0_LP		= @cLp
						   and D_E_L_E_T_	= ' '
					 ##UNIQUEKEY_END	
                     
                     If @iRecno = 0 Begin
						select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ0###					
						select @iRecno = @iRecno + 1					 
						
						##TRATARECNO @iRecno\
						 begin tran
						 Insert into CQ0### ( CQ0_FILIAL,   CQ0_CONTA,    CQ0_MOEDA,     CQ0_DATA,      CQ0_TPSALD, CQ0_SLBASE,
											  CQ0_DTLP,     CQ0_LP,       CQ0_STATUS,    CQ0_DEBITO,    CQ0_CREDIT,    R_E_C_N_O_ )
									  values( @cFilial_CQ0, @cCTXX_CONTA, @IN_CV1_MOEDA, @cDataF,       @cTpSaldo,  @cSlBase,
											  @cDtLp,       @cLp,         @cStatus,      0, 0, @iRecno )
						 commit tran
						 ##FIMTRATARECNO
					 end
					 
					 /* ------------------------------------------------------------
					UPDATE no CQ0
					------------------------------------------------------------*/
					begin tran
						update CQ0### 
							set CQ0_DEBITO = CQ0_DEBITO + @nCTXX_DEBITO, CQ0_CREDIT = CQ0_CREDIT + @nCTXX_CREDIT
						where R_E_C_N_O_ =  @iRecno 
					commit tran	
					
               end
               
               SELECT @fim_CUR = 0   
               fetch Ctb390CQ1_2 into @iRecno, @cCTXX_CONTA, @nCTXX_DEBITO, @nCTXX_CREDIT
            end
            close      Ctb390CQ1_2
            deallocate Ctb390CQ1_2
         end
         Select @iRepete = @iRepete + 1
      end
   end
   Select @OUT_RESULTADO = '1'
end
