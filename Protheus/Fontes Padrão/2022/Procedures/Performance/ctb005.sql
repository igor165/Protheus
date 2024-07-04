Create procedure CTB005_##
 ( 
   @IN_FILIALCOR  Char('CV1_FILIAL'),
   @IN_CV1_CTTINI Char('CV1_CTTINI'),
   @IN_CV1_CTTFIM Char('CV1_CTTFIM'),
   @IN_CV1_CT1INI Char('CV1_CT1INI'),
   @IN_CV1_CT1FIM Char('CV1_CT1FIM'),
   @IN_CT1        Char(01),
   @IN_CV1_MOEDA  Char('CV1_MOEDA'),
   @IN_CV1_DTFIM  Char('CV1_DTFIM'),
   @IN_CV1_VALOR  Float,
   @IN_COPERACAO  Char(01),
   @IN_FATORCTH   Integer,
   @IN_FATORCTD   Integer,
   @OUT_RESULTADO Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Grava os saldos do arquivo CQ3</d>
    Funcao do Siga  -     Ctb390CT3() - Grava os saldos do arquivo CT3
    Fonte Microsiga - <s> CTBA390.PRW </s>
    Entrada         - <ri> @IN_FILIALCOR  - Filial
                           @IN_CV1_CTTINI - CCusto Inicial
                           @IN_CV1_CTTFIM - CCutso Final
                           @IN_CV1_CT1INI - Conta Inicial
                           @IN_CV1_CT1FIM - Conta Final
                           @IN_CT1        - Flag Conta Orcada
                           @IN_CTT        - Flag CCusto Orcado
                           @IN_CV1_MOEDA  - Moeda
                           @IN_CV1_DTFIM  - Data
                           @IN_CV1_VALOR  - Valor
                           @IN_COPERACAO  - Operacao
                           @IN_FATORCTH   - Fator de Multiplicacao para o Item
                           @IN_FATORCTD   - Fator de Multiplicacao para o Item
    Saida           - <ro> @OUT_RESULTADO - Indica o termino OK da procedure </ro>
    Responsavel :     <r> Marco Norbiato	</r>
    Data        :     19/09/2003
-------------------------------------------------------------------------------------- */
declare @cFilial_CT1   char('CT1_FILIAL')
declare @cFilial_CTT   char('CTT_FILIAL')
declare @cFilial_CQ2   char('CQ2_FILIAL')
declare @cFilial_CQ3   char('CQ3_FILIAL')
declare @cFilial_CQ8   char('CQ8_FILIAL')
declare @cFilial_CQ9   char('CQ9_FILIAL')
declare @cAux          varchar(03)
declare @iRecno        int
declare @cCTXX_CONTA   char('CT1_CONTA')
declare @cCTXX_NORMAL  char('CT1_NORMAL')
declare @cCTXX_CUSTO   char('CTT_CUSTO')
declare @nCTXX_DEBITO  float
declare @nCTXX_CREDIT  float
declare @cTpSaldo      Char('CQ2_TPSALD')
declare @cStatus       Char('CQ2_STATUS')
declare @cSlBase       Char('CQ2_SLBASE')
declare @cDtLp         Char(08)
declare @cDataF        Char(08)
declare @cLp           Char('CQ2_LP')
declare @iRepete       Integer

begin
   
   select @cAux = 'CT1'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CT1 OutPut
   select @cAux = 'CTT'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTT OutPut
   select @cAux = 'CQ2'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ2 OutPut
   select @cAux = 'CQ3'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ3 OutPut
   select @cAux = 'CQ8'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ8 OutPut
   select @cAux = 'CQ9'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ9 OutPut
   
   Exec LASTDAY_## @IN_CV1_DTFIM, @cDataF OutPut
   
   Select @OUT_RESULTADO = '0'
   select @cTpSaldo = '0'
   select @cStatus  = '1'
   select @cSlBase  = 'S'
   select @cDtLp    = ' '
   select @cLp      = 'N'
   
   Select @cCTXX_NORMAL = ' '
   Select @nCTXX_DEBITO = 0
   Select @nCTXX_CREDIT = 0
   
   If ( ( @IN_CV1_CT1INI = @IN_CV1_CT1FIM ) and ( @IN_CV1_CTTINI = @IN_CV1_CTTFIM ) )  begin
      /* ------------------------------------------------------------
         Gera Saldo quando todas as entidades são iguais
         ------------------------------------------------------------*/      
         Exec CTB246_##  @IN_FILIALCOR, @IN_CV1_CTTINI, @IN_CV1_CT1INI, @IN_CT1, @IN_CV1_MOEDA,  @IN_CV1_DTFIM,  @IN_CV1_VALOR, @IN_COPERACAO, 
                         @IN_FATORCTH,  @IN_FATORCTD,   @OUT_RESULTADO OutPut
   end else begin
      
      select @iRepete = 1
      While @iRepete <= 2 begin
         If @iRepete = 1 begin
            If @IN_CT1 = '0' begin
               declare Ctb390CQ3_A Insensitive cursor for
               Select CTT_CUSTO
                 From CTT### CTT
                Where CTT.CTT_FILIAL = @cFilial_CTT
                  and CTT.CTT_CUSTO between @IN_CV1_CTTINI and @IN_CV1_CTTFIM
                  and CTT.CTT_CLASSE = '2'
                  and CTT.D_E_L_E_T_ = ' '
                  and 0 = ( Select Count(*)
                              From CQ3### CQ3
                             Where CQ3.CQ3_FILIAL = @cFilial_CQ3
                               and CQ3.CQ3_CCUSTO  = CTT.CTT_CUSTO
                               and CQ3.CQ3_CONTA  = ' '
                               and CQ3.CQ3_DATA   = @IN_CV1_DTFIM
                               and CQ3.CQ3_MOEDA  = @IN_CV1_MOEDA
                               and CQ3.CQ3_TPSALD = '0'
                               and CQ3.D_E_L_E_T_ = ' ' ) 
               for read only
               open Ctb390CQ3_A
               fetch Ctb390CQ3_A into @cCTXX_CUSTO
               
               while ( @@fetch_status = 0 ) begin
                  
                  select @nCTXX_DEBITO = 0
                  select @nCTXX_CREDIT = 0
                  select @cCTXX_CONTA  = ' '                  
                  /* ------------------------------------------------------------
                     Insert no CQ3
                     ------------------------------------------------------------*/					 
                  select @iRecno = 0
				  
				  ##UNIQUEKEY_START
                  select @iRecno = isnull( max( R_E_C_N_O_ ), 0 ) 
				  from CQ3###
				  where CQ3_FILIAL		= @cFilial_CQ3
					    and CQ3_DATA	= @IN_CV1_DTFIM
						and CQ3_CCUSTO	= @cCTXX_CUSTO
						and CQ3_CONTA	= @cCTXX_CONTA
						and CQ3_MOEDA	= @IN_CV1_MOEDA
						and CQ3_TPSALD	= @cTpSaldo
						and CQ3_LP		= @cLp
						and D_E_L_E_T_	= ' '
                  ##UNIQUEKEY_END
                  
				  If @iRecno = 0 Begin
				  
						select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ3###					
						select @iRecno = @iRecno + 1	
						
					  ##TRATARECNO @iRecno\
					  begin tran
					  Insert into CQ3### ( CQ3_FILIAL,   CQ3_CONTA,    CQ3_CCUSTO,   CQ3_MOEDA,     CQ3_DATA,      CQ3_TPSALD, CQ3_SLBASE,
										   CQ3_DTLP,     CQ3_LP,       CQ3_STATUS,   CQ3_DEBITO,    CQ3_CREDIT,    R_E_C_N_O_ )
								   values( @cFilial_CQ3, @cCTXX_CONTA, @cCTXX_CUSTO, @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
										   @cDtLp,       @cLp,         @cStatus,     0, 0, @iRecno )
					  commit tran
					  ##FIMTRATARECNO
                  end
				  
				/* ------------------------------------------------------------
				UPDATE no CQ3
				------------------------------------------------------------*/
				begin tran
					update CQ3### 
						set CQ3_DEBITO = CQ3_DEBITO + @nCTXX_DEBITO, CQ3_CREDIT = CQ3_CREDIT + @nCTXX_CREDIT
					where R_E_C_N_O_ =  @iRecno 
				commit tran					  
				  
				  /* ------------------------------------------------------------
                     Insert no CQ2
                     ------------------------------------------------------------*/
                  select @iRecno = 0
				  
				  ##UNIQUEKEY_START
                  select @iRecno = isnull( max( R_E_C_N_O_ ), 0 ) 
				  from CQ2###
				  where CQ2_FILIAL		= @cFilial_CQ2
					    and CQ2_DATA	= @cDataF
						and CQ2_CCUSTO	= @cCTXX_CUSTO
						and CQ2_CONTA	= @cCTXX_CONTA
						and CQ2_MOEDA	= @IN_CV1_MOEDA
						and CQ2_TPSALD	= @cTpSaldo
						and CQ2_LP		= @cLp
						and D_E_L_E_T_	= ' '
				  ##UNIQUEKEY_END			
                  
                  If @iRecno = 0 Begin
						
						select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ2###					
						select @iRecno = @iRecno + 1				  
						
					  ##TRATARECNO @iRecno\
					  begin tran
					  Insert into CQ2### ( CQ2_FILIAL,   CQ2_CONTA,    CQ2_CCUSTO,   CQ2_MOEDA,     CQ2_DATA,      CQ2_TPSALD, CQ2_SLBASE,
										   CQ2_DTLP,     CQ2_LP,       CQ2_STATUS,   CQ2_DEBITO,    CQ2_CREDIT,    R_E_C_N_O_ )
								   values( @cFilial_CQ2, @cCTXX_CONTA, @cCTXX_CUSTO, @IN_CV1_MOEDA, @cDataF,       @cTpSaldo,  @cSlBase,
										   @cDtLp,       @cLp,         @cStatus,     0, 0, @iRecno )
					  commit tran
					  ##FIMTRATARECNO
				  end
                  
				/* ------------------------------------------------------------
				UPDATE no CQ2
				------------------------------------------------------------*/
				begin tran
					update CQ2### 
						set CQ2_DEBITO = CQ2_DEBITO + @nCTXX_DEBITO, CQ2_CREDIT = CQ2_CREDIT + @nCTXX_CREDIT
					where R_E_C_N_O_ =  @iRecno 
				commit tran					  
				  
                  SELECT @fim_CUR = 0   
                  fetch Ctb390CQ3_A into @cCTXX_CUSTO
               end
               close      Ctb390CQ3_A
               deallocate Ctb390CQ3_A
            End
            
            If @IN_CT1 = '1' begin
               declare Ctb390CQ3_B Insensitive cursor for
               Select CTT_CUSTO, CT1_NORMAL, CT1_CONTA
                 From CT1### CT1, CTT### CTT
                Where CTT.CTT_FILIAL = @cFilial_CTT
                  and CTT.CTT_CUSTO between @IN_CV1_CTTINI and @IN_CV1_CTTFIM
                  and CTT.CTT_CLASSE = '2'
                  and CTT.D_E_L_E_T_ = ' '
                  and CT1.CT1_FILIAL = @cFilial_CT1
                  and CT1.CT1_CONTA between @IN_CV1_CT1INI and @IN_CV1_CT1FIM
                  and CT1.CT1_CLASSE = '2'
                  and CT1.D_E_L_E_T_ = ' '
                  and 0 = ( Select Count(*)
                              From CQ3### CQ3
                             Where CQ3.CQ3_FILIAL = @cFilial_CQ3
                               and CQ3.CQ3_CCUSTO  = CTT.CTT_CUSTO
                               and CQ3.CQ3_CONTA  = CT1.CT1_CONTA
                               and CQ3.CQ3_DATA   = @IN_CV1_DTFIM
                               and CQ3.CQ3_MOEDA  = @IN_CV1_MOEDA
                               and CQ3.CQ3_TPSALD = '0'
                               and CQ3.D_E_L_E_T_ = ' ' )
               for read only
               open Ctb390CQ3_B
               fetch Ctb390CQ3_B into @cCTXX_CUSTO, @cCTXX_NORMAL, @cCTXX_CONTA
               
               while ( @@fetch_status = 0 ) begin
                  
                  select @nCTXX_DEBITO = 0
                  select @nCTXX_CREDIT = 0
                  
                  /* ------------------------------------------------------------
                     Insert no CQ3
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  
				  ##UNIQUEKEY_START
				  select @iRecno = isnull( max( R_E_C_N_O_ ), 0 ) 
				  from CQ3###
				  where CQ3_FILIAL		= @cFilial_CQ3
					    and CQ3_DATA	= @IN_CV1_DTFIM
						and CQ3_CCUSTO	= @cCTXX_CUSTO
						and CQ3_CONTA	= @cCTXX_CONTA
						and CQ3_MOEDA	= @IN_CV1_MOEDA
						and CQ3_TPSALD	= @cTpSaldo
						and CQ3_LP		= @cLp
						and D_E_L_E_T_	= ' '
                  ##UNIQUEKEY_END
				  
                  If @iRecno = 0 Begin

					select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ3###					
					select @iRecno = @iRecno + 1
					
					  ##TRATARECNO @iRecno\
					  begin tran
					  Insert into CQ3### ( CQ3_FILIAL,   CQ3_CONTA,    CQ3_CCUSTO,   CQ3_MOEDA,     CQ3_DATA,      CQ3_TPSALD, CQ3_SLBASE,
										   CQ3_DTLP,     CQ3_LP,       CQ3_STATUS,   CQ3_DEBITO,    CQ3_CREDIT,    R_E_C_N_O_ )
								   values( @cFilial_CQ3, @cCTXX_CONTA, @cCTXX_CUSTO, @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
										   @cDtLp,       @cLp,         @cStatus,     0, 0, @iRecno )
					  commit tran
					  ##FIMTRATARECNO
				  end

					/* ------------------------------------------------------------
					UPDATE no CQ3
					------------------------------------------------------------*/
					begin tran
						update CQ3### 
							set CQ3_DEBITO = CQ3_DEBITO + @nCTXX_DEBITO, CQ3_CREDIT = CQ3_CREDIT + @nCTXX_CREDIT
						where R_E_C_N_O_ =  @iRecno 
					commit tran	
				  
                  /* ------------------------------------------------------------
                     Insert no CQ2
                     ------------------------------------------------------------*/
                  select @iRecno = 0
				  
				  ##UNIQUEKEY_START
                  select @iRecno = isnull( max( R_E_C_N_O_ ), 0 ) 
				  from CQ2###
				  where CQ2_FILIAL		= @cFilial_CQ2
						and CQ2_DATA	= @cDataF
						and CQ2_CCUSTO	= @cCTXX_CUSTO
						and CQ2_CONTA	= @cCTXX_CONTA
						and CQ2_MOEDA	= @IN_CV1_MOEDA
						and CQ2_TPSALD	= @cTpSaldo
						and CQ2_LP		= @cLp 
						and D_E_L_E_T_	= ' '
				  ##UNIQUEKEY_END		
                  
                  If @iRecno = 0 Begin

					select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ2###					
					select @iRecno = @iRecno + 1
					
					  ##TRATARECNO @iRecno\
					  begin tran
					  Insert into CQ2### ( CQ2_FILIAL,   CQ2_CONTA,    CQ2_CCUSTO,   CQ2_MOEDA,     CQ2_DATA,      CQ2_TPSALD, CQ2_SLBASE,
										   CQ2_DTLP,     CQ2_LP,       CQ2_STATUS,   CQ2_DEBITO,    CQ2_CREDIT,    R_E_C_N_O_ )
								   values( @cFilial_CQ2, @cCTXX_CONTA, @cCTXX_CUSTO, @IN_CV1_MOEDA, @cDataF,       @cTpSaldo,  @cSlBase,
										   @cDtLp,       @cLp,         @cStatus,     0, 0, @iRecno )
					  commit tran
					  ##FIMTRATARECNO
				  end

				/* ------------------------------------------------------------
				UPDATE no CQ3
				------------------------------------------------------------*/
				begin tran
					update CQ2### 
						set CQ2_DEBITO = CQ2_DEBITO + @nCTXX_DEBITO, CQ2_CREDIT = CQ2_CREDIT + @nCTXX_CREDIT
					where R_E_C_N_O_ =  @iRecno 
				commit tran					  
                  
                  SELECT @fim_CUR = 0   
                  fetch Ctb390CQ3_B into @cCTXX_CUSTO, @cCTXX_NORMAL, @cCTXX_CONTA
               end
               close      Ctb390CQ3_B
               deallocate Ctb390CQ3_B
            End
            
         end else begin
            /* ------------------------------------------------------------
               @iRepete = 2
               Update no CQ3
               ------------------------------------------------------------*/
            declare Ctb390CQ3_2 Insensitive cursor for
               select R_E_C_N_O_ , IsNull(CQ3_CONTA,' '), IsNull(CQ3_CCUSTO,' '), CQ3_DEBITO, CQ3_CREDIT
                 from CQ3###
                where CQ3_FILIAL = @cFilial_CQ3
                  and CQ3_CCUSTO between @IN_CV1_CTTINI and @IN_CV1_CTTFIM
                  and CQ3_CONTA between @IN_CV1_CT1INI and @IN_CV1_CT1FIM
                  and CQ3_DATA   = @IN_CV1_DTFIM
                  and CQ3_MOEDA  = @IN_CV1_MOEDA
                  and CQ3_TPSALD = '0'
                  and D_E_L_E_T_ = ' '
            for read only
            open Ctb390CQ3_2
            
            fetch Ctb390CQ3_2 into @iRecno, @cCTXX_CONTA, @cCTXX_CUSTO, @nCTXX_DEBITO, @nCTXX_CREDIT
            
            while ( @@fetch_status = 0 ) begin
               
               select @cCTXX_NORMAL = ' '
               
               if @cCTXX_CONTA <> ' ' begin
                  Select @cCTXX_NORMAL = IsNull(CT1_NORMAL, ' ')
                    From CT1###
                   Where CT1_FILIAL = @cFilial_CT1
                     and CT1_CONTA  = @cCTXX_CONTA
                     and CT1_CLASSE = '2'
                     and D_E_L_E_T_ = ' '
               End
               /* ------------------------------------------------------------
                  ATUALIZA DEBITO/CERDITO CQ3 DIA
                  ------------------------------------------------------------*/
               if ( @IN_CT1 = '1' ) begin  --Se tiver conta, verificar a natureza da conta.
                  If ( @cCTXX_NORMAL = '1' ) begin
                     If ( @IN_CV1_VALOR < 0 ) begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + (Abs( @IN_CV1_VALOR ) * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                        End
                     end else begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + (@IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                        End
                     end
      		      end else begin
                     If ( @IN_CV1_VALOR < 0 ) begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + (Abs(@IN_CV1_VALOR) * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                        End
                     end else begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD, 2 )
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                        End
                     end
                  end
               end else begin  --Se nao tiver conta no orcamento, considerar como devedor
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + (Abs( @IN_CV1_VALOR ) * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD , 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end
               end
               /* ------------------------------------------------------------
                  Update no CQ3
                  ------------------------------------------------------------*/
               begin tran
               update CQ3###
                  set CQ3_DEBITO = @nCTXX_DEBITO, CQ3_CREDIT = @nCTXX_CREDIT
                where R_E_C_N_O_ = @iRecno
               commit tran
               /* ------------------------------------------------------------
                  ATUALIZA DEBITO/CERDITO CQ2 MES
                  ------------------------------------------------------------*/
               select @nCTXX_DEBITO = 0 
               select @nCTXX_CREDIT = 0 
               select @iRecno = 0
               select @iRecno = IsNull(R_E_C_N_O_, 0), @nCTXX_DEBITO = CQ2_DEBITO, @nCTXX_CREDIT = CQ2_CREDIT
                 from CQ2###
                where CQ2_FILIAL = @cFilial_CQ2
                  and CQ2_CCUSTO = @cCTXX_CUSTO
                  and CQ2_CONTA  = @cCTXX_CONTA
                  and CQ2_DATA   = @cDataF
                  and CQ2_MOEDA  = @IN_CV1_MOEDA
                  and CQ2_TPSALD = '0'
                  and D_E_L_E_T_ = ' '
               
               if ( @IN_CT1 = '1' ) begin  --Se tiver conta, verificar a natureza da conta.
                  If ( @cCTXX_NORMAL = '1' ) begin
                     If ( @IN_CV1_VALOR < 0 ) begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + (Abs( @IN_CV1_VALOR ) * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                        End
                     end else begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + (@IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                        End
                     end
      		      end else begin
                     If ( @IN_CV1_VALOR < 0 ) begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + (Abs(@IN_CV1_VALOR) * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                        End
                     end else begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD, 2 )
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                        End
                     end
                  end
               end else begin  --Se nao tiver conta no orcamento, considerar como devedor
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + (Abs( @IN_CV1_VALOR ) * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD , 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end
               end
               
               If @iRecno is null or @iRecno = 0  begin
                  select @iRecno = 1
                  
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ2### ( CQ2_FILIAL,   CQ2_CONTA,    CQ2_CCUSTO,   CQ2_MOEDA,     CQ2_DATA, CQ2_TPSALD, CQ2_SLBASE,
                                       CQ2_DTLP,     CQ2_LP,       CQ2_STATUS,   CQ2_DEBITO,    CQ2_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ2, @cCTXX_CONTA, @cCTXX_CUSTO, @IN_CV1_MOEDA, @cDataF,   @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,         @cStatus,     @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
               end else begin
                  /* ------------------------------------------------------------
                     Update no CQ2
                     ------------------------------------------------------------*/
                  begin tran
                  update CQ2###
                     set CQ2_DEBITO = @nCTXX_DEBITO, CQ2_CREDIT = @nCTXX_CREDIT
                   where R_E_C_N_O_ = @iRecno
                  commit tran 
               end
               /* ------------------------------------------------------------
                  Atualiza CQ8
                  ------------------------------------------------------------*/
               select @nCTXX_DEBITO = 0 
               select @nCTXX_CREDIT = 0 
               select @iRecno = 0
               select @iRecno = IsNull(R_E_C_N_O_ , 0), @nCTXX_DEBITO = CQ8_DEBITO, @nCTXX_CREDIT = CQ8_CREDIT
                 from CQ8###
                where CQ8_FILIAL = @cFilial_CQ8
                  and CQ8_IDENT  = 'CTT'
                  and CQ8_CODIGO = @cCTXX_CUSTO
                  and CQ8_DATA   = @cDataF
                  and CQ8_MOEDA  = @IN_CV1_MOEDA
                  and CQ8_TPSALD = '0'
                  and CQ8_LP     = @cLp
                  and D_E_L_E_T_ = ' '
               
               if ( @IN_CT1 = '1' ) begin  --Se tiver conta, verificar a natureza da conta.
                  If ( @cCTXX_NORMAL = '1' ) begin
                     If ( @IN_CV1_VALOR < 0 ) begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + (Abs( @IN_CV1_VALOR ) * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                        End
                     end else begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + (@IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                        End
                     end
      		      end else begin
                     If ( @IN_CV1_VALOR < 0 ) begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + (Abs(@IN_CV1_VALOR) * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                        End
                     end else begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD, 2 )
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                        End
                     end
                  end
               end else begin  --Se nao tiver conta no orcamento, considerar como devedor
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + (Abs( @IN_CV1_VALOR ) * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD , 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end
               end
               
               If @iRecno is null or @iRecno = 0  begin
                  select @iRecno = Max(R_E_C_N_O_) from CQ8###
                  select @iRecno = @iRecno + 1
                  
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ8### ( CQ8_FILIAL,   CQ8_IDENT, CQ8_CODIGO,   CQ8_MOEDA,     CQ8_DATA, CQ8_TPSALD, CQ8_SLBASE, CQ8_DTLP, CQ8_LP, CQ8_STATUS, CQ8_DEBITO,   CQ8_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ8, 'CTT',     @cCTXX_CUSTO, @IN_CV1_MOEDA, @cDataF,  @cTpSaldo,  @cSlBase,   @cDtLp,   @cLp,   @cStatus,   @nCTXX_DEBITO,@nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
               end else begin
                  /* ------------------------------------------------------------
                     Update no CQ8
                     ------------------------------------------------------------*/
                  begin tran
                  update CQ8###
                     set CQ8_DEBITO = @nCTXX_DEBITO, CQ8_CREDIT = @nCTXX_CREDIT
                   where R_E_C_N_O_ = @iRecno
                  commit tran
               end
               /* ------------------------------------------------------------
                  Atualiza CQ9
                  ------------------------------------------------------------*/
               select @nCTXX_DEBITO = 0
               select @nCTXX_CREDIT = 0
               select @iRecno = 0
               select @iRecno = IsNull(R_E_C_N_O_, 0), @nCTXX_DEBITO = CQ9_DEBITO, @nCTXX_CREDIT = CQ9_CREDIT
                 from CQ9###
                where CQ9_FILIAL = @cFilial_CQ9
                  and CQ9_IDENT  = 'CTT'
                  and CQ9_CODIGO = @cCTXX_CUSTO
                  and CQ9_DATA   = @IN_CV1_DTFIM
                  and CQ9_MOEDA  = @IN_CV1_MOEDA
                  and CQ9_TPSALD = '0'
                  and CQ9_LP     = @cLp
                  and D_E_L_E_T_ = ' '
               /* ------------------------------------------------------------
                  Verifica se a debito ou credito
                  ------------------------------------------------------------*/
               if ( @IN_CT1 = '1' ) begin  --Se tiver conta, verificar a natureza da conta.
                  If ( @cCTXX_NORMAL = '1' ) begin
                     If ( @IN_CV1_VALOR < 0 ) begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + (Abs( @IN_CV1_VALOR ) * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                        End
                     end else begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + (@IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                        End
                     end
      		      end else begin
                     If ( @IN_CV1_VALOR < 0 ) begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + (Abs(@IN_CV1_VALOR) * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                        End
                     end else begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD, 2 )
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                        End
                     end
                  end
               end else begin  --Se nao tiver conta no orcamento, considerar como devedor
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + (Abs( @IN_CV1_VALOR ) * @IN_FATORCTH * @IN_FATORCTD ), 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH * @IN_FATORCTD , 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end
               end
               
               If @iRecno is null or @iRecno = 0  begin
                  select @iRecno = Max(R_E_C_N_O_) from CQ9###
                  select @iRecno = @iRecno + 1
                  
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ9### ( CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO,   CQ9_MOEDA,     CQ9_DATA,      CQ9_TPSALD, CQ9_SLBASE, CQ9_DTLP, CQ9_LP, CQ9_STATUS, CQ9_DEBITO,    CQ9_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ9, 'CTT',     @cCTXX_CUSTO, @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,   @cDtLp,   @cLp,   @cStatus,   @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
               end else begin
                  /* ------------------------------------------------------------
                     Update no CQ9
                     ------------------------------------------------------------*/
                  begin tran
                  update CQ9###
                     set CQ9_DEBITO = @nCTXX_DEBITO, CQ9_CREDIT = @nCTXX_CREDIT
                   where R_E_C_N_O_ = @iRecno
                  commit tran
               end
               
               SELECT @fim_CUR = 0   
               fetch Ctb390CQ3_2 into @iRecno, @cCTXX_CONTA, @cCTXX_CUSTO, @nCTXX_DEBITO, @nCTXX_CREDIT
            end
            close      Ctb390CQ3_2
            deallocate Ctb390CQ3_2
         end
         Select @iRepete = @iRepete + 1
      end
   end
   Select @OUT_RESULTADO = '1'
end
