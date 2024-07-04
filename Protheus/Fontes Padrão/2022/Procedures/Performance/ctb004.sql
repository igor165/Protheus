Create procedure CTB004_##
 ( 
   @IN_FILIALCOR  Char('CV1_FILIAL'),
   @IN_CV1_CTDINI Char('CV1_CTDINI'),
   @IN_CV1_CTDFIM Char('CV1_CTDFIM'),
   @IN_CV1_CTTINI Char('CV1_CTTINI'),
   @IN_CV1_CTTFIM Char('CV1_CTTFIM'),
   @IN_CV1_CT1INI Char('CV1_CT1INI'),
   @IN_CV1_CT1FIM Char('CV1_CT1FIM'),
   @IN_CT1        Char(01),
   @IN_CTT        Char(01),
   @IN_CV1_MOEDA  Char('CV1_MOEDA'),
   @IN_CV1_DTFIM  Char('CV1_DTFIM'),
   @IN_CV1_VALOR  Float,
   @IN_COPERACAO  Char(01),
   @IN_FATORCTH   Integer,
   @OUT_RESULTADO Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Grava os saldos do arquivo CQ5. </d>
    Funcao do Siga  -     Ctb390CTD()  - Grava os saldos do arquivo CQ5
    Fonte Microsiga - <s> CTBA390.PRW </s>
    Entrada         - <ri> @IN_FILIALCOR  - Filial
                           @IN_CV1_CTDINI - Item Inicial
                           @IN_CV1_CTDFIM - Item Final
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
    Saida           - <ro> @OUT_RESULTADO - Indica o termino OK da procedure </ro>
    Responsavel :     <r> Marco Norbiato	</r>
    Data        :     19/09/2003
-------------------------------------------------------------------------------------- */
declare @cFilial_CT1   char('CT1_FILIAL')
declare @cFilial_CTT   char('CTT_FILIAL')
declare @cFilial_CTD   char('CTD_FILIAL')
declare @cFilial_CQ4   char('CQ4_FILIAL')
declare @cFilial_CQ5   char('CQ5_FILIAL')
declare @cFilial_CQ8   char('CQ8_FILIAL')
declare @cFilial_CQ9   char('CQ9_FILIAL')
declare @cAux          char(03)
declare @iRecno        int
declare @cCTXX_CONTA   char('CT1_CONTA')
declare @cCTXX_NORMAL  char('CT1_NORMAL')
declare @cCTXX_CUSTO   char('CTT_CUSTO')
declare @cCTXX_ITEM    char('CTD_ITEM')
declare @cCTXX_CLVL    char('CTH_CLVL')
declare @nCTXX_DEBITO  Float
declare @nCTXX_CREDIT  Float
declare @nCQX_DEBITO  Float
declare @nCQX_CREDIT  Float
declare @cTpSaldo      Char('CQ4_TPSALD')
declare @cStatus       Char('CQ4_STATUS')
declare @cSlBase       Char('CQ4_SLBASE')
declare @cDtLp         Char(08)
declare @cDataF        Char(08)
declare @cLp           Char('CQ4_LP')
declare @iRepete       Integer

begin
   
   select @cAux = 'CT1'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CT1 OutPut
   select @cAux = 'CTT'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTT OutPut
   select @cAux = 'CTD'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTD OutPut
   select @cAux = 'CQ4'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ4 OutPut
   select @cAux = 'CQ5'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ5 OutPut
   select @cAux = 'CQ8'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ8 OutPut
   select @cAux = 'CQ9'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ9 OutPut
   
   Exec LASTDAY_## @IN_CV1_DTFIM, @cDataF OutPut
   
   select @OUT_RESULTADO = '0'
   Select @cCTXX_NORMAL = ' '
   Select @nCTXX_DEBITO = 0
   Select @nCTXX_CREDIT = 0
   Select @nCQX_DEBITO  = 0
   Select @nCQX_CREDIT  = 0
   select @cTpSaldo = '0'
   select @cStatus  = '1'
   select @cSlBase  = 'S'
   select @cDtLp    = ' '
   select @cLp      = 'N'
   /* ------------------------------------------------------------
      Gera Saldo quando todas as entidades são iguais
      ------------------------------------------------------------*/      
   If ( ( @IN_CV1_CT1INI = @IN_CV1_CT1FIM ) and ( @IN_CV1_CTTINI = @IN_CV1_CTTFIM ) and ( @IN_CV1_CTDINI = @IN_CV1_CTDFIM ) )  begin
      /* ------------------------------------------------------------
         Gera Saldo quando todas as entidades são iguais
         ------------------------------------------------------------*/      
      Exec CTB245_##  @IN_FILIALCOR, @IN_CV1_CTDINI, @IN_CV1_CTTINI, @IN_CV1_CT1INI, @IN_CT1,
                      @IN_CTT,       @IN_CV1_MOEDA,  @IN_CV1_DTFIM,  @IN_CV1_VALOR,
                      @IN_COPERACAO, @IN_FATORCTH,   @OUT_RESULTADO  OutPut
   end else begin
      /* ------------------------------------------------------------
      SE AS ENTIDADES INICIO E FIM SÃO DIFERENTES
      ------------------------------------------------------------*/
      select @iRepete = 1
      
      While @iRepete <= 2 begin
         If @iRepete = 1 begin
            If @IN_CTT = '0' and @IN_CT1 = '0' begin
               declare Ctb390CQ5_A Insensitive cursor for
               Select CTD_ITEM
                 From CTD### CTD
                Where CTD.CTD_FILIAL = @cFilial_CTD
                  and CTD.CTD_ITEM  between @IN_CV1_CTDINI and @IN_CV1_CTDFIM
                  and CTD.CTD_CLASSE = '2'
                  and CTD.D_E_L_E_T_ = ' '
                  and 0 = ( Select Count(*)
                              From CQ5### CQ5
                             Where CQ5.CQ5_FILIAL = @cFilial_CQ5
                               and CQ5.CQ5_ITEM   = CTD.CTD_ITEM
                               and CQ5.CQ5_CCUSTO  = ' '
                               and CQ5.CQ5_CONTA  = ' '
                               and CQ5.CQ5_DATA   = @IN_CV1_DTFIM
                               and CQ5.CQ5_MOEDA  = @IN_CV1_MOEDA
                               and CQ5.CQ5_TPSALD = '0'
                               and CQ5.D_E_L_E_T_ = ' ' ) 
               for read only
               open Ctb390CQ5_A
               fetch Ctb390CQ5_A into @cCTXX_ITEM
               
               while ( @@fetch_status = 0 ) begin
                  
                  select @nCTXX_DEBITO = 0
                  select @nCTXX_CREDIT = 0
                  select @cCTXX_CUSTO  = ' '
                  select @cCTXX_CONTA  = ' '
                  
                  select @iRecno = 0
				  
				  ##UNIQUEKEY_START
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) 
				  from CQ5###
				  where CQ5_FILIAL		= @cFilial_CQ5
					    and CQ5_DATA	= @IN_CV1_DTFIM
						and CQ5_ITEM	= @cCTXX_ITEM
						and CQ5_CCUSTO	= @cCTXX_CUSTO
						and CQ5_CONTA	= @cCTXX_CONTA
						and CQ5_MOEDA	= @IN_CV1_MOEDA
						and CQ5_TPSALD	= @cTpSaldo
						and CQ5_LP		= @cLp
						and D_E_L_E_T_	= ' '
				  ##UNIQUEKEY_END		
                  
                  If @iRecno = 0 Begin

					select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ5###					
					select @iRecno = @iRecno + 1
					  /* ------------------------------------------------------------
						 Insert no CQ5
						 ------------------------------------------------------------*/
					  ##TRATARECNO @iRecno\
					  begin tran
					  Insert into CQ5### ( CQ5_FILIAL,   CQ5_CONTA,    CQ5_CCUSTO,   CQ5_ITEM,      CQ5_MOEDA,     CQ5_DATA,     CQ5_TPSALD, CQ5_SLBASE,
										   CQ5_DTLP,     CQ5_LP,       CQ5_STATUS,   CQ5_DEBITO,    CQ5_CREDIT,    R_E_C_N_O_ )
								   values( @cFilial_CQ5, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,   @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
										   @cDtLp,       @cLp,         @cStatus,     0, 0, @iRecno )
					  commit tran
					  ##FIMTRATARECNO
				  end
				  
					/* ------------------------------------------------------------
					UPDATE no CQ5
					------------------------------------------------------------*/
					begin tran
						update CQ5### 
							set CQ5_DEBITO = CQ5_DEBITO + @nCTXX_DEBITO, CQ5_CREDIT = CQ5_CREDIT + @nCTXX_CREDIT
						where R_E_C_N_O_ =  @iRecno 
					commit tran					  
									  
                  /* ------------------------------------------------------------
                     Insert no CQ4
                     ------------------------------------------------------------*/
                  select @iRecno = 0
				  
				  ##UNIQUEKEY_START
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) 
				  from CQ4###
				  where CQ4_FILIAL		= @cFilial_CQ4
						and CQ4_DATA	= @cDataF
						and CQ4_ITEM	= @cCTXX_ITEM
						and CQ4_CCUSTO	= @cCTXX_CUSTO
						and CQ4_CONTA	= @cCTXX_CONTA
						and CQ4_MOEDA	= @IN_CV1_MOEDA
						and CQ4_TPSALD	= @cTpSaldo
						and CQ4_LP		= @cLp
						and D_E_L_E_T_	= ' '
                  ##UNIQUEKEY_END
				  
                  If @iRecno = 0 Begin

					select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ4###					
					select @iRecno = @iRecno + 1
					
					  ##TRATARECNO @iRecno\
					  begin tran
					  Insert into CQ4### ( CQ4_FILIAL,   CQ4_CONTA,    CQ4_CCUSTO,   CQ4_ITEM,     CQ4_MOEDA,     CQ4_DATA,      CQ4_TPSALD, CQ4_SLBASE,
										   CQ4_DTLP,     CQ4_LP,       CQ4_STATUS,   CQ4_DEBITO,   CQ4_CREDIT,    R_E_C_N_O_ )
								   values( @cFilial_CQ4, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,  @IN_CV1_MOEDA, @cDataF, @cTpSaldo,  @cSlBase,
										   @cDtLp,       @cLp,         @cStatus,     0,0, @iRecno )
					  commit tran
					  ##FIMTRATARECNO
                  
				  end
				  
				/* ------------------------------------------------------------
				UPDATE no CQ4
				------------------------------------------------------------*/
				begin tran
					update CQ4### 
						set CQ4_DEBITO = CQ4_DEBITO + @nCTXX_DEBITO, CQ4_CREDIT = CQ4_CREDIT + @nCTXX_CREDIT
					where R_E_C_N_O_ =  @iRecno 
				commit tran					  
				  
                  SELECT @fim_CUR = 0   
                  fetch Ctb390CQ5_A into @cCTXX_ITEM
               end
               close      Ctb390CQ5_A
               deallocate Ctb390CQ5_A
               
            End
            
            If @IN_CTT = '1' and @IN_CT1 = '0' begin
               declare Ctb390CQ5_B Insensitive cursor for
               Select CTD_ITEM, CTT_CUSTO
                 From CTD### CTD,CTT### CTT
                Where CTD.CTD_FILIAL = @cFilial_CTD
                  and CTD.CTD_ITEM  between @IN_CV1_CTDINI and @IN_CV1_CTDFIM
                  and CTD.CTD_CLASSE = '2'
                  and CTD.D_E_L_E_T_ = ' '
                  and CTT.CTT_FILIAL = @cFilial_CTT
                  and CTT.CTT_CUSTO between @IN_CV1_CTTINI and  @IN_CV1_CTTFIM
                  and CTT.CTT_CLASSE = '2'
                  and CTT.D_E_L_E_T_ = ' '
                  and 0 = ( Select Count(*)
                              From CQ5### CQ5
                             Where CQ5.CQ5_FILIAL = @cFilial_CQ5
                               and CQ5.CQ5_ITEM   = CTD.CTD_ITEM
                               and CQ5.CQ5_CCUSTO  = CTT.CTT_CUSTO
                               and CQ5.CQ5_CONTA  = ' '
                               and CQ5.CQ5_DATA   = @IN_CV1_DTFIM
                               and CQ5.CQ5_MOEDA  = @IN_CV1_MOEDA
                               and CQ5.CQ5_TPSALD = '0'
                               and CQ5.D_E_L_E_T_ = ' ' )
               for read only
               open Ctb390CQ5_B
               fetch Ctb390CQ5_B into @cCTXX_ITEM, @cCTXX_CUSTO
               
               while ( @@fetch_status = 0 ) begin
                  
                  select @nCTXX_DEBITO = 0
                  select @nCTXX_CREDIT = 0
                  select @cCTXX_CONTA  = ' '
                  
                  select @iRecno = 0
				  
				  ##UNIQUEKEY_START
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) 
				  from CQ5###
				  where CQ5_FILIAL		= @cFilial_CQ5
						and CQ5_DATA	= @IN_CV1_DTFIM
						and CQ5_ITEM	= @cCTXX_ITEM
						and CQ5_CCUSTO	= @cCTXX_CUSTO
						and CQ5_CONTA	= @cCTXX_CONTA
						and CQ5_MOEDA	= @IN_CV1_MOEDA
						and CQ5_TPSALD	= @cTpSaldo
						and CQ5_LP		= @cLp
						and D_E_L_E_T_	= ' '
                  ##UNIQUEKEY_END
				  
                  If @iRecno = 0 Begin

					select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ5###					
					select @iRecno = @iRecno + 1
					  /* ------------------------------------------------------------
						 Insert no CQ5
						 ------------------------------------------------------------*/
					  ##TRATARECNO @iRecno\
					  begin tran
					  Insert into CQ5### ( CQ5_FILIAL,   CQ5_CONTA,    CQ5_CCUSTO,   CQ5_ITEM,      CQ5_MOEDA,     CQ5_DATA,      CQ5_TPSALD, CQ5_SLBASE,
										   CQ5_DTLP,     CQ5_LP,       CQ5_STATUS,   CQ5_DEBITO,    CQ5_CREDIT,    R_E_C_N_O_ )
								   values( @cFilial_CQ5, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,   @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
										   @cDtLp,       @cLp,         @cStatus,     0, 0, @iRecno )
					  commit tran
					  ##FIMTRATARECNO
				  end
				  
					/* ------------------------------------------------------------
					UPDATE no CQ5
					------------------------------------------------------------*/
					begin tran
						update CQ5### 
							set CQ5_DEBITO = CQ5_DEBITO + @nCTXX_DEBITO, CQ5_CREDIT = CQ5_CREDIT + @nCTXX_CREDIT
						where R_E_C_N_O_ =  @iRecno 
					commit tran	
				  
                  /* ------------------------------------------------------------
                     Insert no CQ4
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  ##UNIQUEKEY_START
				  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) 
				  from CQ4###
				  where CQ4_FILIAL		= @cFilial_CQ4
						and CQ4_DATA	= @cDataF
						and CQ4_ITEM	= @cCTXX_ITEM
						and CQ4_CCUSTO	= @cCTXX_CUSTO
						and CQ4_CONTA	= @cCTXX_CONTA
						and CQ4_MOEDA	= @IN_CV1_MOEDA
						and CQ4_TPSALD	= @cTpSaldo
						and CQ4_LP		= @cLp
						and D_E_L_E_T_	= ' '
                  ##UNIQUEKEY_END
				  
                  If @iRecno = 0 Begin

					select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ4###					
					select @iRecno = @iRecno + 1
					
					  ##TRATARECNO @iRecno\
					  begin tran
					  Insert into CQ4### ( CQ4_FILIAL,   CQ4_CONTA,    CQ4_CCUSTO,   CQ4_ITEM,     CQ4_MOEDA,     CQ4_DATA, CQ4_TPSALD, CQ4_SLBASE,
										   CQ4_DTLP,     CQ4_LP,       CQ4_STATUS,   CQ4_DEBITO,   CQ4_CREDIT,    R_E_C_N_O_ )
								   values( @cFilial_CQ4, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,  @IN_CV1_MOEDA, @cDataF,  @cTpSaldo,  @cSlBase,
										   @cDtLp,       @cLp,         @cStatus,     0,0, @iRecno )
					  commit tran
					  ##FIMTRATARECNO
                  end
				  
					/* ------------------------------------------------------------
					UPDATE no CQ4
					------------------------------------------------------------*/
					begin tran
						update CQ4### 
							set CQ4_DEBITO = CQ4_DEBITO + @nCTXX_DEBITO, CQ4_CREDIT = CQ4_CREDIT + @nCTXX_CREDIT
						where R_E_C_N_O_ =  @iRecno 
					commit tran					  
				  
                  SELECT @fim_CUR = 0   
                  fetch Ctb390CQ5_B into @cCTXX_ITEM, @cCTXX_CUSTO
               end
               close      Ctb390CQ5_B
               deallocate Ctb390CQ5_B
               
            End
            
            If @IN_CTT = '0' and @IN_CT1 = '1' begin
               declare Ctb390CQ5_C Insensitive cursor for
               Select CTD_ITEM, CT1_NORMAL, CT1_CONTA
                 From CTD### CTD, CT1### CT1
                Where CTD.CTD_FILIAL = @cFilial_CTD
                  and CTD.CTD_ITEM  between @IN_CV1_CTDINI and @IN_CV1_CTDFIM
                  and CTD.CTD_CLASSE = '2'
                  and CTD.D_E_L_E_T_ = ' '
                  and CT1.CT1_FILIAL = @cFilial_CT1
                  and CT1.CT1_CONTA between @IN_CV1_CT1INI and @IN_CV1_CT1FIM
                  and CT1.CT1_CLASSE = '2'
                  and CT1.D_E_L_E_T_ = ' '
                  and 0 = ( Select Count(*)
                              From CQ5### CQ5
                             Where CQ5.CQ5_FILIAL = @cFilial_CQ5
                               and CQ5.CQ5_ITEM   = CTD.CTD_ITEM
                               and CQ5.CQ5_CCUSTO  = ' '
                               and CQ5.CQ5_CONTA  = CT1.CT1_CONTA
                               and CQ5.CQ5_DATA   = @IN_CV1_DTFIM
                               and CQ5.CQ5_MOEDA  = @IN_CV1_MOEDA
                               and CQ5.CQ5_TPSALD = '0'
                               and CQ5.D_E_L_E_T_ = ' ' )
               for read only
               open Ctb390CQ5_C
               fetch Ctb390CQ5_C into @cCTXX_ITEM, @cCTXX_NORMAL, @cCTXX_CONTA
               
               while ( @@fetch_status = 0 ) begin
                  
                  select @nCTXX_DEBITO = 0
                  select @nCTXX_CREDIT = 0
                  select @cCTXX_CUSTO  = ' '
                  
                  select @iRecno = 0
                  
				  ##UNIQUEKEY_START
				  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) 
				  from CQ5###
                  where CQ5_FILIAL		= @cFilial_CQ5
						and CQ5_DATA	= @IN_CV1_DTFIM
						and CQ5_ITEM	= @cCTXX_ITEM
						and CQ5_CCUSTO	= @cCTXX_CUSTO
						and CQ5_CONTA	= @cCTXX_CONTA
						and CQ5_MOEDA	= @IN_CV1_MOEDA
						and CQ5_TPSALD	= @cTpSaldo
						and CQ5_LP		= @cLp
						and D_E_L_E_T_	= ' '
				  ##UNIQUEKEY_END
				  
                  If @iRecno = 0 Begin

					select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ5###					
					select @iRecno = @iRecno + 1
					  /* ------------------------------------------------------------
						 Insert no CQ5
						 ------------------------------------------------------------*/
					  ##TRATARECNO @iRecno\
					  begin tran
					  Insert into CQ5### ( CQ5_FILIAL,   CQ5_CONTA,    CQ5_CCUSTO,   CQ5_ITEM,      CQ5_MOEDA,     CQ5_DATA,      CQ5_TPSALD, CQ5_SLBASE,
										   CQ5_DTLP,     CQ5_LP,       CQ5_STATUS,   CQ5_DEBITO,    CQ5_CREDIT,    R_E_C_N_O_ )
								   values( @cFilial_CQ5, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,   @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
										   @cDtLp,       @cLp,         @cStatus,     0, 0, @iRecno )
					  commit tran
					  ##FIMTRATARECNO
				  end

					/* ------------------------------------------------------------
					UPDATE no CQ5
					------------------------------------------------------------*/
					begin tran
						update CQ5### 
							set CQ5_DEBITO = CQ5_DEBITO + @nCTXX_DEBITO, CQ5_CREDIT = CQ5_CREDIT + @nCTXX_CREDIT
						where R_E_C_N_O_ =  @iRecno 
					commit tran					
				  
                  /* ------------------------------------------------------------
                     Insert no CQ4
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  
				  ##UNIQUEKEY_START
				  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) 
				  from CQ4###
				  where CQ4_FILIAL		= @cFilial_CQ4
						and CQ4_DATA	= @cDataF
						and CQ4_ITEM	= @cCTXX_ITEM
						and CQ4_CCUSTO	= @cCTXX_CUSTO
						and CQ4_CONTA	= @cCTXX_CONTA
						and CQ4_MOEDA	= @IN_CV1_MOEDA
						and CQ4_TPSALD	= @cTpSaldo
						and CQ4_LP		= @cLp
						and D_E_L_E_T_	= ' '
                  ##UNIQUEKEY_END	
				  
                  If @iRecno = 0 Begin

					select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ4###					
					select @iRecno = @iRecno + 1
					
					  ##TRATARECNO @iRecno\
					  begin tran
					  Insert into CQ4### ( CQ4_FILIAL,   CQ4_CONTA,    CQ4_CCUSTO,   CQ4_ITEM,     CQ4_MOEDA,     CQ4_DATA, CQ4_TPSALD, CQ4_SLBASE,
										   CQ4_DTLP,     CQ4_LP,       CQ4_STATUS,   CQ4_DEBITO,   CQ4_CREDIT,    R_E_C_N_O_ )
								   values( @cFilial_CQ4, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,  @IN_CV1_MOEDA, @cDataF,  @cTpSaldo,  @cSlBase,
										   @cDtLp,       @cLp,         @cStatus,     0,0, @iRecno )
					  commit tran
					  ##FIMTRATARECNO                  
                  end
				  
					/* ------------------------------------------------------------
					UPDATE no CQ4
					------------------------------------------------------------*/
					begin tran
						update CQ4### 
							set CQ4_DEBITO = CQ4_DEBITO + @nCTXX_DEBITO, CQ4_CREDIT = CQ4_CREDIT + @nCTXX_CREDIT
						where R_E_C_N_O_ =  @iRecno 
					commit tran					  
				  
                  SELECT @fim_CUR = 0   
                  fetch Ctb390CQ5_C into @cCTXX_ITEM, @cCTXX_NORMAL, @cCTXX_CONTA
               end
               close      Ctb390CQ5_C
               deallocate Ctb390CQ5_C
               
            End
            
            If @IN_CTT = '1' and @IN_CT1 = '1' begin
               declare Ctb390CQ5_D Insensitive cursor for
               Select CTD_ITEM, CT1_NORMAL, CTT_CUSTO, CT1_CONTA
                 From CTD### CTD, CTT### CTT, CT1### CT1
                Where CTD.CTD_FILIAL = @cFilial_CTD
                  and CTD.CTD_ITEM  between @IN_CV1_CTDINI and @IN_CV1_CTDFIM
                  and CTD.CTD_CLASSE = '2'
                  and CTD.D_E_L_E_T_ = ' '
                  and CTT.CTT_FILIAL = @cFilial_CTT
                  and CTT.CTT_CUSTO between @IN_CV1_CTTINI and @IN_CV1_CTTFIM
                  and CTT.CTT_CLASSE = '2'
                  and CTT.D_E_L_E_T_ = ' '
                  and CT1.CT1_FILIAL = @cFilial_CT1
                  and CT1.CT1_CONTA between @IN_CV1_CT1INI and @IN_CV1_CT1FIM
                  and CT1.CT1_CLASSE = '2'
                  and CT1.D_E_L_E_T_ = ' '
                  and 0 = ( Select Count(*)
                                     From CQ5### CQ5
                                    Where CQ5.CQ5_FILIAL = @cFilial_CQ5
                                      and CQ5.CQ5_ITEM   = CTD.CTD_ITEM
                                      and CQ5.CQ5_CCUSTO  = CTT.CTT_CUSTO
                                      and CQ5.CQ5_CONTA  = CT1.CT1_CONTA
                                      and CQ5.CQ5_DATA   = @IN_CV1_DTFIM
                                      and CQ5.CQ5_MOEDA  = @IN_CV1_MOEDA
                                      and CQ5.CQ5_TPSALD = '0'
                                      and CQ5.D_E_L_E_T_ = ' ' )
               for read only
               open Ctb390CQ5_D
               fetch Ctb390CQ5_D into @cCTXX_ITEM, @cCTXX_NORMAL, @cCTXX_CUSTO, @cCTXX_CONTA
               
               while ( @@fetch_status = 0 ) begin
                  
                  select @nCTXX_DEBITO = 0
                  select @nCTXX_CREDIT = 0
                  
                  select @iRecno = 0
                 
				 ##UNIQUEKEY_START
				  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) 
				  from CQ5###
				  where CQ5_FILIAL		= @cFilial_CQ5
						and CQ5_DATA	= @IN_CV1_DTFIM
						and CQ5_ITEM	= @cCTXX_ITEM
						and CQ5_CCUSTO	= @cCTXX_CUSTO
						and CQ5_CONTA	= @cCTXX_CONTA
						and CQ5_MOEDA	= @IN_CV1_MOEDA
						and CQ5_TPSALD	= @cTpSaldo
						and CQ5_LP		= @cLp
						and D_E_L_E_T_ 	= ' '
                 ##UNIQUEKEY_END
				 
                  If @iRecno = 0 Begin

					select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ5###					
					select @iRecno = @iRecno + 1
					  /* ------------------------------------------------------------
						 Insert no CQ5
						 ------------------------------------------------------------*/
					  ##TRATARECNO @iRecno\
					  begin tran
					  Insert into CQ5### ( CQ5_FILIAL,   CQ5_CONTA,    CQ5_CCUSTO,   CQ5_ITEM,      CQ5_MOEDA,     CQ5_DATA,      CQ5_TPSALD, CQ5_SLBASE,
										   CQ5_DTLP,     CQ5_LP,       CQ5_STATUS,   CQ5_DEBITO,    CQ5_CREDIT,    R_E_C_N_O_ )
								   values( @cFilial_CQ5, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,   @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
										   @cDtLp,       @cLp,         @cStatus,     0, 0, @iRecno )
					  commit tran
					  ##FIMTRATARECNO
				  end
				  
				/* ------------------------------------------------------------
				UPDATE no CQ5
				------------------------------------------------------------*/
				begin tran
					update CQ5### 
						set CQ5_DEBITO = CQ5_DEBITO + @nCTXX_DEBITO, CQ5_CREDIT = CQ5_CREDIT + @nCTXX_CREDIT
					where R_E_C_N_O_ =  @iRecno 
				commit tran					  
				  
                  /* ------------------------------------------------------------
                     Insert no CQ4
                     ------------------------------------------------------------*/
                  select @iRecno = 0
				  
				  ##UNIQUEKEY_START
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) 
				  from CQ4###
				  where CQ4_FILIAL		= @cFilial_CQ4
						and CQ4_DATA	= @cDataF
						and CQ4_ITEM	= @cCTXX_ITEM
						and CQ4_CCUSTO	= @cCTXX_CUSTO
						and CQ4_CONTA	= @cCTXX_CONTA
						and CQ4_MOEDA	= @IN_CV1_MOEDA
						and CQ4_TPSALD	= @cTpSaldo
						and CQ4_LP		= @cLp	
						and	D_E_L_E_T_	= ' '
                  ##UNIQUEKEY_END
				  
                  If @iRecno = 0 Begin

					select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ4###					
					select @iRecno = @iRecno + 1
					
					  ##TRATARECNO @iRecno\
					  begin tran
					  Insert into CQ4### ( CQ4_FILIAL,   CQ4_CONTA,    CQ4_CCUSTO,   CQ4_ITEM,     CQ4_MOEDA,     CQ4_DATA, CQ4_TPSALD, CQ4_SLBASE,
										   CQ4_DTLP,     CQ4_LP,       CQ4_STATUS,   CQ4_DEBITO,   CQ4_CREDIT,    R_E_C_N_O_ )
								   values( @cFilial_CQ4, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,  @IN_CV1_MOEDA, @cDataF,  @cTpSaldo,  @cSlBase,
										   @cDtLp,       @cLp,         @cStatus,     0,0, @iRecno )
					  commit tran
					  ##FIMTRATARECNO
                  end
				  
					  /* ------------------------------------------------------------
						UPDATE no CQ4
						------------------------------------------------------------*/
						begin tran
							update CQ4### 
								set CQ4_DEBITO = CQ4_DEBITO + @nCTXX_DEBITO, CQ4_CREDIT = CQ4_CREDIT + @nCTXX_CREDIT
							where R_E_C_N_O_ =  @iRecno 
						commit tran	
				  
                  SELECT @fim_CUR = 0                    
                  fetch Ctb390CQ5_D into @cCTXX_ITEM, @cCTXX_NORMAL, @cCTXX_CUSTO, @cCTXX_CONTA
               end
               close      Ctb390CQ5_D
               deallocate Ctb390CQ5_D
               
            End
            
         end else begin
            /* ------------------------------------------------------------
               @iRepete = 2
               ------------------------------------------------------------*/
            declare Ctb390CQ5_2 Insensitive cursor for
               select R_E_C_N_O_ , IsNull(CQ5_CONTA,' '), IsNull(CQ5_CCUSTO,' '), IsNull(CQ5_ITEM,' '), CQ5_DEBITO, CQ5_CREDIT
                 from CQ5###
                where CQ5_FILIAL = @cFilial_CQ5
                  and CQ5_ITEM  Between @IN_CV1_CTDINI and @IN_CV1_CTDFIM
                  and CQ5_CCUSTO Between @IN_CV1_CTTINI and @IN_CV1_CTTFIM
                  and CQ5_CONTA Between @IN_CV1_CT1INI and @IN_CV1_CT1FIM
                  and CQ5_DATA   = @IN_CV1_DTFIM
                  and CQ5_MOEDA  = @IN_CV1_MOEDA
                  and CQ5_TPSALD = '0'
                  and D_E_L_E_T_ = ' '
            for read only
            open Ctb390CQ5_2
            
            fetch Ctb390CQ5_2 into @iRecno, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM, @nCTXX_DEBITO, @nCTXX_CREDIT
            
            while ( @@fetch_status = 0 ) begin
               
               select @cCTXX_NORMAL = ' '
               If @cCTXX_CONTA != ' ' begin
                  Select @cCTXX_NORMAL = IsNull(CT1_NORMAL, ' ')
                    From CT1###
                   Where CT1_FILIAL = @cFilial_CT1
                     and CT1_CONTA  = @cCTXX_CONTA
                     and CT1_CLASSE = '2'
                     and D_E_L_E_T_ = ' '
               End
               
               select @cCTXX_CLVL = ' '
               if ( @IN_CT1 = '1' ) begin  --Se tiver conta, verificar a natureza da conta.
                  If ( @cCTXX_NORMAL = '1' ) begin
                     If ( @IN_CV1_VALOR < 0 ) begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT  + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                        End
                     end else begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                        End
                     end
      		      end else begin
                     If ( @IN_CV1_VALOR < 0 ) begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + Abs(@IN_CV1_VALOR) * @IN_FATORCTH, 2 )
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                        End
                     end else begin
                        If @IN_COPERACAO = '1' begin
                           select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
                           select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                        End
                     end
                  end
               end else begin  --Se nao tiver conta no orcamento, considerar como devedor
                  
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end
               end
               /* ------------------------------------------------------------
                  Update no CQ5
                  ------------------------------------------------------------*/
               begin tran
               update CQ5###
                  set CQ5_DEBITO = @nCTXX_DEBITO, CQ5_CREDIT = @nCTXX_CREDIT
                where R_E_C_N_O_ = @iRecno               
               commit tran
               /* ------------------------------------------------------------
                  Atualiza CQ4
                  ------------------------------------------------------------*/
               select @nCTXX_DEBITO = 0 
               select @nCTXX_CREDIT = 0 
               select @iRecno = 0
               
			   ##UNIQUEKEY_START
               select @iRecno = IsNull(R_E_C_N_O_, 0), @nCTXX_DEBITO = CQ4_DEBITO, @nCTXX_CREDIT = CQ4_CREDIT
                 from CQ4###
                where CQ4_FILIAL = @cFilial_CQ4
                  and CQ4_ITEM   = @cCTXX_ITEM
                  and CQ4_CCUSTO = @cCTXX_CUSTO
                  and CQ4_CONTA  = @cCTXX_CONTA
                  and CQ4_DATA   = @cDataF
                  and CQ4_MOEDA  = @IN_CV1_MOEDA
                  and CQ4_TPSALD = '0'
                  and D_E_L_E_T_ = ' '
			    ##UNIQUEKEY_END  
				
               /* ------------------------------------------------------------
                  Verifica se a debito ou credito
                  ------------------------------------------------------------*/
               If ( @cCTXX_NORMAL = '1' ) begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT  + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end
   		      end else begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + Abs(@IN_CV1_VALOR) * @IN_FATORCTH, 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end
               end
                  
               If @iRecno is null or @iRecno = 0  begin
                  select @iRecno = 1
                  
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ4### ( CQ4_FILIAL,   CQ4_CONTA,    CQ4_CCUSTO,   CQ4_ITEM,      CQ4_MOEDA,     CQ4_DATA, CQ4_TPSALD, CQ4_SLBASE,
                                       CQ4_DTLP,     CQ4_LP,       CQ4_STATUS,   CQ4_DEBITO,    CQ4_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ4, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,   @IN_CV1_MOEDA, @cDataF,   @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,         @cStatus,     0, 0, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
               end
                  /* ------------------------------------------------------------
                     Update no CQ4
                     ------------------------------------------------------------*/
                  begin tran
                  update CQ4###
                     set CQ4_DEBITO = CQ4_DEBITO + @nCTXX_DEBITO, CQ4_CREDIT = CQ4_CREDIT + @nCTXX_CREDIT
                   where R_E_C_N_O_ = @iRecno
                  commit tran
               
               /* ------------------------------------------------------------
                  Atualiza CQ8
                  ------------------------------------------------------------*/
               select @nCTXX_DEBITO = 0 
               select @nCTXX_CREDIT = 0 
               select @iRecno = 0
			   
			   ##UNIQUEKEY_START
               select @iRecno = IsNull(R_E_C_N_O_ , 0), @nCTXX_DEBITO = CQ8_DEBITO, @nCTXX_CREDIT = CQ8_CREDIT
                 from CQ8###
                where CQ8_FILIAL = @cFilial_CQ8
                  and CQ8_IDENT  = 'CTD'
                  and CQ8_CODIGO = @cCTXX_ITEM
                  and CQ8_DATA   = @cDataF
                  and CQ8_MOEDA  = @IN_CV1_MOEDA
                  and CQ8_TPSALD = '0'
                  and CQ8_LP     = @cLp
                  and D_E_L_E_T_ = ' '
			    ##UNIQUEKEY_END	  
               /* ------------------------------------------------------------
                  Verifica se a debito ou credito
                  ------------------------------------------------------------*/
               If ( @cCTXX_NORMAL = '1' ) begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT  + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end
   		      end else begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + Abs(@IN_CV1_VALOR) * @IN_FATORCTH, 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end
               end
               
               If @iRecno is null or @iRecno = 0  begin
                  select @iRecno = Max(R_E_C_N_O_) from CQ8###
                  select @iRecno = @iRecno + 1
                  
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ8### ( CQ8_FILIAL,   CQ8_IDENT, CQ8_CODIGO,  CQ8_MOEDA,     CQ8_DATA, CQ8_TPSALD, CQ8_SLBASE, CQ8_DTLP, CQ8_LP, CQ8_STATUS, CQ8_DEBITO,   CQ8_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ8, 'CTD',     @cCTXX_ITEM, @IN_CV1_MOEDA, @cDataF,  @cTpSaldo,  @cSlBase,   @cDtLp,   @cLp,   @cStatus,   0,0, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
               end 
                  /* ------------------------------------------------------------
                     Update no CQ8
                     ------------------------------------------------------------*/
                  begin tran
                  update CQ8###
                     set CQ8_DEBITO = CQ8_DEBITO + @nCTXX_DEBITO, CQ8_CREDIT = CQ8_CREDIT + @nCTXX_CREDIT
                   where R_E_C_N_O_ = @iRecno
                  commit tran
               
               /* ------------------------------------------------------------
                  Atualiza CQ9
                  ------------------------------------------------------------*/
               select @nCTXX_DEBITO = 0
               select @nCTXX_CREDIT = 0
               select @iRecno = 0
               ##UNIQUEKEY_START
			   select @iRecno = IsNull(R_E_C_N_O_, 0), @nCTXX_DEBITO = CQ9_DEBITO, @nCTXX_CREDIT = CQ9_CREDIT
                 from CQ9###
                where CQ9_FILIAL = @cFilial_CQ9
                  and CQ9_IDENT  = 'CTD'
                  and CQ9_CODIGO = @cCTXX_ITEM
                  and CQ9_DATA   = @IN_CV1_DTFIM
                  and CQ9_MOEDA  = @IN_CV1_MOEDA
                  and CQ9_TPSALD = '0'
                  and CQ9_LP     = @cLp
                  and D_E_L_E_T_ = ' '
				##UNIQUEKEY_END  
               /* ------------------------------------------------------------
                  Verifica se a debito ou credito
                  ------------------------------------------------------------*/
               If ( @cCTXX_NORMAL = '1' ) begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT  + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end
   		      end else begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO + Abs(@IN_CV1_VALOR) * @IN_FATORCTH, 2 )
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT, 2 )
                     End
                  end else begin
                     If @IN_COPERACAO = '1' begin
                        select @nCTXX_CREDIT = Round( @nCTXX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
                        select @nCTXX_DEBITO = Round( @nCTXX_DEBITO, 2 )
                     End
                  end
               end
               
               If @iRecno is null or @iRecno = 0  begin
                  select @iRecno = Max(R_E_C_N_O_) from CQ9###
                  select @iRecno = @iRecno + 1
                  
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ9### ( CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO,  CQ9_MOEDA,     CQ9_DATA,      CQ9_TPSALD, CQ9_SLBASE, CQ9_DTLP, CQ9_LP, CQ9_STATUS, CQ9_DEBITO,    CQ9_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ9, 'CTD',     @cCTXX_ITEM, @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,   @cDtLp,   @cLp,   @cStatus,   @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
               end 
                  /* ------------------------------------------------------------
                     Update no CQ9
                     ------------------------------------------------------------*/
                  begin tran
                  update CQ9###
                     set CQ9_DEBITO = CQ9_DEBITO + @nCTXX_DEBITO, CQ9_CREDIT = CQ9_CREDIT + @nCTXX_CREDIT
                   where R_E_C_N_O_ = @iRecno
                  commit tran
               
               
               SELECT @fim_CUR = 0   
               fetch Ctb390CQ5_2 into @iRecno, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM, @nCTXX_DEBITO, @nCTXX_CREDIT
               
            end
            close      Ctb390CQ5_2
            deallocate Ctb390CQ5_2
         end
         Select @iRepete = @iRepete + 1
      end
   end
   select @OUT_RESULTADO = '1'
end

