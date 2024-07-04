Create procedure CTB245_##
 ( 
   @IN_FILIALCOR  Char('CV1_FILIAL'),
   @IN_CV1_CTDINI Char('CV1_CTDINI'),
   @IN_CV1_CTTINI Char('CV1_CTTINI'),
   @IN_CV1_CT1INI Char('CV1_CT1INI'),
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
    Funcao do Siga  -     Ctb390CTD()  - Grava os saldos do arquivo CQ5 qdo as entidades ini e fin forem as mesmas
    Fonte Microsiga - <s> CTBA390.PRW </s>
    Entrada         - <ri> @IN_FILIALCOR  - Filial
                           @IN_CV1_CTDINI - Item Inicial
                           @IN_CV1_CTTINI - CCusto Inicial
                           @IN_CV1_CT1INI - Conta Inicial
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
declare @cFilial_CQ4   char('CQ4_FILIAL')
declare @cFilial_CQ5   char('CQ7_FILIAL')
declare @cFilial_CQ8   char('CQ8_FILIAL')
declare @cFilial_CQ9   char('CQ9_FILIAL')
declare @cFilial_CT1   char('CT1_FILIAL')
declare @cFilial_CTT   char('CTT_FILIAL')
declare @cFilial_CTD   char('CTD_FILIAL')
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
   if ( @IN_CT1 = '1' ) select @cCTXX_CONTA = @IN_CV1_CT1INI
   else            select @cCTXX_CONTA = ' '
   
   if ( @IN_CTT = '1' ) select @cCTXX_CUSTO = @IN_CV1_CTTINI
   else            select @cCTXX_CUSTO = ' '
   
   select @cCTXX_ITEM = @IN_CV1_CTDINI
   
   If @cCTXX_CONTA != ' ' begin
      select @cCTXX_NORMAL = IsNull(CT1_NORMAL, ' ')
        from CT1###
       where CT1_FILIAL = @cFilial_CT1
         and CT1_CONTA  = @cCTXX_CONTA
         and D_E_L_E_T_ = ' '
   End
   
   select @cCTXX_CLVL = ' '
   /* ------------------------------------------------------------
      Atualiza CQ4 - MES
      ------------------------------------------------------------*/
   Select @nCQX_DEBITO  = 0
   Select @nCQX_CREDIT  = 0
   select @iRecno = 0
   select @iRecno = IsNull( R_E_C_N_O_, 0), @nCQX_CREDIT = CQ4_CREDIT, @nCQX_DEBITO = CQ4_DEBITO
     from CQ4###
    where CQ4_FILIAL = @cFilial_CQ4
      and CQ4_MOEDA  = @IN_CV1_MOEDA
      and CQ4_TPSALD = '0'
      and CQ4_CONTA  = @cCTXX_CONTA
      and CQ4_CCUSTO = @cCTXX_CUSTO
      and CQ4_ITEM   = @cCTXX_ITEM
      and CQ4_DATA   = @cDataF
      and D_E_L_E_T_ = ' '
   
   if ( @iRecno is null or @iRecno = 0 ) begin
      if ( @IN_COPERACAO = '1' ) begin
         if ( @IN_CT1 = '1' ) begin --Se tiver conta, verificar a natureza da conta.
            If ( @cCTXX_NORMAL = '1' ) begin
               If ( @IN_CV1_VALOR < 0 ) begin
                  select @nCTXX_CREDIT = Round( @nCQX_CREDIT + ( Abs( @IN_CV1_VALOR ) * @IN_FATORCTH ), 2 )
               end else begin
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               end
		      end else begin
               If ( @IN_CV1_VALOR < 0 ) begin
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               end else begin
                  select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               end
            end
         end else begin  --Se nao tiver conta no orcamento, considerar como devedor   
            If ( @IN_CV1_VALOR < 0 ) begin
               select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
            end else begin
               select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
            end
         end
         /* ------------------------------------------------------------
            Insert no CQ4
            ------------------------------------------------------------*/
         select @iRecno = 0
         
		 ##UNIQUEKEY_START
		 select @iRecno = isnull( max( R_E_C_N_O_ ), 0 )
           from CQ4###
         where CQ4_FILIAL		= @cFilial_CQ4
			   and CQ4_DATA		= @cDataF
			   and CQ4_ITEM		= @cCTXX_ITEM
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
			 Insert into CQ4### ( CQ4_FILIAL,   CQ4_CONTA,    CQ4_CCUSTO,   CQ4_ITEM,      CQ4_MOEDA,     CQ4_DATA,  CQ4_TPSALD, CQ4_SLBASE,
								  CQ4_DTLP,     CQ4_LP,       CQ4_STATUS,   CQ4_DEBITO,    CQ4_CREDIT,    R_E_C_N_O_ )
						  values( @cFilial_CQ4, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,   @IN_CV1_MOEDA, @cDataF,   @cTpSaldo,  @cSlBase,
								  @cDtLp,       @cLp,         @cStatus,     0, 0, @iRecno )
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
		 
		 
      end
   end else begin
      /* ------------------------------------------------------------
         Se a conta existir
         ------------------------------------------------------------*/
      if ( @IN_CT1 = '1' ) begin
         if ( @cCTXX_NORMAL = '1' ) begin
            if ( @IN_CV1_VALOR < 0 ) begin
               if ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
               select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
            end else begin
               If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO + (@IN_CV1_VALOR * @IN_FATORCTH), 2 )
               select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
            end
         end else begin
            if ( @IN_CV1_VALOR < 0 ) begin
               If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO	= Round( @nCQX_DEBITO + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
               select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
            end else begin
               If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
            end
         end
      end else begin --Se nao tiver conta no orcamento, considerar como devedor
         if ( @IN_CV1_VALOR < 0 ) begin
            if ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
            select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
         end else begin
            If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
            select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
         end
      end
      /* ------------------------------------------------------------
         Update no CQ4
         ------------------------------------------------------------*/
      begin tran
      update CQ4###
         set CQ4_DEBITO = @nCTXX_DEBITO, CQ4_CREDIT = @nCTXX_CREDIT
       where R_E_C_N_O_ = @iRecno
     commit tran
   end
   /* ------------------------------------------------------------
      Atualiza CQ5 - DIA
      ------------------------------------------------------------*/
   select @nCQX_CREDIT = 0
   select @nCQX_DEBITO = 0
   select @iRecno = 0
   select @iRecno = IsNull( R_E_C_N_O_, 0), @nCQX_CREDIT = CQ5_CREDIT, @nCQX_DEBITO = CQ5_DEBITO
     from CQ5###
    where CQ5_FILIAL = @cFilial_CQ5
      and CQ5_MOEDA  = @IN_CV1_MOEDA
      and CQ5_TPSALD = '0'
      and CQ5_CONTA  = @cCTXX_CONTA
      and CQ5_CCUSTO = @cCTXX_CUSTO
      and CQ5_ITEM   = @cCTXX_ITEM
      and CQ5_DATA   = @IN_CV1_DTFIM
      and D_E_L_E_T_ = ' '
   
   if ( @iRecno is null or @iRecno = 0 ) begin
      if ( @IN_COPERACAO = '1' ) begin
         if ( @IN_CT1 = '1' ) begin --Se tiver conta, verificar a natureza da conta.
            If ( @cCTXX_NORMAL = '1' ) begin
               If ( @IN_CV1_VALOR < 0 ) begin
                  select @nCTXX_CREDIT = Round( @nCQX_CREDIT + ( Abs( @IN_CV1_VALOR ) * @IN_FATORCTH ), 2 )
               end else begin
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               end
		      end else begin
               If ( @IN_CV1_VALOR < 0 ) begin
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               end else begin
                  select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               end
            end
         end else begin  --Se nao tiver conta no orcamento, considerar como devedor   
            If ( @IN_CV1_VALOR < 0 ) begin
               select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
            end else begin
               select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
            end
         end
         /* ------------------------------------------------------------
            Insert no CQ5
            ------------------------------------------------------------*/
         select @iRecno = 0
		 
		 ##UNIQUEKEY_START
         select @iRecno = isnull( max( R_E_C_N_O_ ), 0 )
           from CQ5###
         where CQ5_FILIAL		= @cFilial_CQ5
			   and CQ5_DATA		= @IN_CV1_DTFIM
			   and CQ5_ITEM		= @cCTXX_ITEM
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
		 
      end
   end else begin
      /* ------------------------------------------------------------
         Se a conta existir
         ------------------------------------------------------------*/
      if ( @IN_CT1 = '1' ) begin
         if ( @cCTXX_NORMAL = '1' ) begin
            if ( @IN_CV1_VALOR < 0 ) begin
               if ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
               select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
            end else begin
               If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO + (@IN_CV1_VALOR * @IN_FATORCTH), 2 )
               select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
            end
         end else begin
            if ( @IN_CV1_VALOR < 0 ) begin
               If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO	= Round( @nCQX_DEBITO + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
               select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
            end else begin
               If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
            end
         end
      end else begin --Se nao tiver conta no orcamento, considerar como devedor
         if ( @IN_CV1_VALOR < 0 ) begin
            if ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
            select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
         end else begin
            If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
            select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
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
   end
   /* ------------------------------------------------------------
      ATUALIZA DEBITO/CREDITO ENTIDADES CQ8/CQ9 
      ------------------------------------------------------------*/
--   If  @IN_CTT = '1' or @IN_CTD = '1' begin
--         /* ------------------------------------------------------------
--             CTT - CCustos - ATUALIZA DEBITO/CREDITO ENTIDADES CQ8/CQ9 
--            ------------------------------------------------------------*/
--/*         If @IN_CTT = '1' begin
--            /* ------------------------------------------------------------
--                CQ8 - ATUALIZA DEBITO/CREDITO ENTIDADES CQ8
--               ------------------------------------------------------------*/
--            select @cTpSaldo = '0'
--            select @cStatus  = '1'
--            select @cSlBase  = 'S'
--            select @cDtLp    = ' '
--            select @cLp      = 'N'
--            select @iRecno      = 0 
--            select @nCQX_CREDIT = 0
--            select @nCQX_DEBITO = 0
         
--            select @iRecno   = IsNull(R_E_C_N_O_, 0) , @nCQX_CREDIT = IsNull(CQ8_CREDIT, 0), @nCQX_DEBITO = IsNull(CQ8_DEBITO, 0)
--              from CQ8### CQ8
--             where CQ8_FILIAL = @cFilial_CQ8
--               and CQ8_MOEDA  = @IN_CV1_MOEDA
--               and CQ8_TPSALD = '0'
--               and CQ8_IDENT  = 'CTT'
--               and CQ8_CODIGO = @cCTXX_CUSTO
--               and CQ8_DATA   = @cDataF
--               and D_E_L_E_T_ = ' '
--            /* ------------------------------------------------------------
--               Se não existe
--               ------------------------------------------------------------*/
--            if ( @iRecno is Null or @iRecno = 0 ) begin
--               if ( @IN_COPERACAO = '1' ) begin
--                  if ( @IN_CT1 = '1' ) begin --Se tiver conta, verificar a natureza da conta.
--                     If ( @cCTXX_NORMAL = '1' ) begin
--                        If ( @IN_CV1_VALOR < 0 ) begin
--                           select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
--                        end else begin
--                           select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR, 2 )
--                        end
--			            end else begin
--                        If ( @IN_CV1_VALOR < 0 ) begin
--                           select @nCTXX_DEBITO = Round( @nCQX_DEBITO + Abs(@IN_CV1_VALOR), 2 )
--                        end else begin
--                           select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR, 2 )
--                        end
--                     end
--                  end else begin  --Se nao tiver conta no orcamento, considerar como devedor
--                     If ( @IN_CV1_VALOR < 0 ) begin
--                        select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
--                     end else begin
--                        select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR, 2 )
--                     end
--                  end
--                  /* ------------------------------------------------------------
--                     Insert no CQ8
--                     ------------------------------------------------------------*/
--                  select @iRecno = 0
--                  select @iRecno = isnull( max( R_E_C_N_O_ ), 0 )
--                    from CQ8###
--                  select @iRecno = @iRecno + 1
--                  ##TRATARECNO @iRecno\
--                  begin tran
--                  Insert into CQ8### (CQ8_FILIAL,   CQ8_IDENT, CQ8_CODIGO,   CQ8_MOEDA,     CQ8_DATA, CQ8_TPSALD, CQ8_SLBASE, CQ8_DTLP, CQ8_LP, CQ8_STATUS, CQ8_DEBITO,    CQ8_CREDIT,    R_E_C_N_O_ )
--                              values (@cFilial_CQ8, 'CTT',     @cCTXX_CUSTO, @IN_CV1_MOEDA, @cDataF,  @cTpSaldo,  @cSlBase,   @cDtLp,   @cLp,   @cStatus,   @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
--                  commit tran
--                  ##FIMTRATARECNO
--               end
--            end else begin
--               /* ------------------------------------------------------------
--                  Se a conta existir
--                  ------------------------------------------------------------*/
--               if ( @IN_CT1 = '1' ) begin
--                  if ( @cCTXX_NORMAL = '1' ) begin
--                     if ( @IN_CV1_VALOR < 0 ) begin                  
--                        If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
--                        select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
--                     end else begin
--                        If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO+ @IN_CV1_VALOR, 2 )
--                        select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
--                     end
--                  end else begin
--                     if ( @IN_CV1_VALOR < 0 ) begin
--                        If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO	= Round( @nCQX_DEBITO+ Abs( @IN_CV1_VALOR ), 2 )
--                        select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
--                     end else begin
--                        If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR, 2 )
--                        select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
--                     end
--                  end
--               end else begin --Se nao tiver conta no orcamento, considerar como devedor
--                  if ( @IN_CV1_VALOR < 0 ) begin
--                     if ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
--                     select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
--                  end else begin
--                     If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO+ @IN_CV1_VALOR, 2 )
--                     select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
--                  end
--               end
--               /* ------------------------------------------------------------
--                  Update no CQ8
--                  ------------------------------------------------------------*/
--               begin tran
--               update CQ8###
--                  set CQ8_DEBITO = @nCTXX_DEBITO, CQ8_CREDIT = @nCTXX_CREDIT
--                where R_E_C_N_O_ = @iRecno
--               commit tran
--            end
--            /* ------------------------------------------------------------
--                CQ9 - ATUALIZA DEBITO/CREDITO ENTIDADES CQ9
--               ------------------------------------------------------------*/
--            select @iRecno      = 0 
--            select @nCQX_CREDIT = 0
--            select @nCQX_DEBITO = 0
         
--            select @iRecno   = IsNull(R_E_C_N_O_, 0) , @nCQX_CREDIT = IsNull(CQ9_CREDIT, 0), @nCQX_DEBITO = IsNull(CQ9_DEBITO, 0)
--              from CQ9### CQ9
--             where CQ9_FILIAL = @cFilial_CQ9
--               and CQ9_MOEDA  = @IN_CV1_MOEDA
--               and CQ9_TPSALD = '0'
--               and CQ9_IDENT  = 'CTT'
--               and CQ9_CODIGO = @cCTXX_CUSTO
--               and CQ9_DATA   = @IN_CV1_DTFIM
--               and D_E_L_E_T_ = ' '
--            /* ------------------------------------------------------------
--               Se não existe
--               ------------------------------------------------------------*/
--            if ( @iRecno is Null or @iRecno = 0 ) begin
--               if ( @IN_COPERACAO = '1' ) begin
--                  if ( @IN_CT1 = '1' ) begin --Se tiver conta, verificar a natureza da conta.
--                     If ( @cCTXX_NORMAL = '1' ) begin
--                        If ( @IN_CV1_VALOR < 0 ) begin
--                           select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
--                        end else begin
--                           select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR, 2 )
--                        end
--			            end else begin
--                        If ( @IN_CV1_VALOR < 0 ) begin
--                           select @nCTXX_DEBITO = Round( @nCQX_DEBITO + Abs(@IN_CV1_VALOR), 2 )
--                        end else begin
--                           select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR, 2 )
--                        end
--                     end
--                  end else begin  --Se nao tiver conta no orcamento, considerar como devedor
--                     If ( @IN_CV1_VALOR < 0 ) begin
--                        select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
--                     end else begin
--                        select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR, 2 )
--                     end
--                  end
--                  /* ------------------------------------------------------------
--                     Insert no CQ9
--                     ------------------------------------------------------------*/
--                  select @iRecno = 0
--                  select @iRecno = isnull( max( R_E_C_N_O_ ), 0 )
--                    from CQ9###
--                  select @iRecno = @iRecno + 1
--                  ##TRATARECNO @iRecno\
--                  begin tran
--                  Insert into CQ9### (CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO,   CQ9_MOEDA,     CQ9_DATA,      CQ9_TPSALD, CQ9_SLBASE, CQ9_DTLP, CQ9_LP, CQ9_STATUS, CQ9_DEBITO,    CQ9_CREDIT,    R_E_C_N_O_ )
--                              values (@cFilial_CQ9, 'CTT',     @cCTXX_CUSTO, @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,   @cDtLp,   @cLp,   @cStatus,   @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
--                  commit tran
--                  ##FIMTRATARECNO
--               end
--            end else begin
--               /* ------------------------------------------------------------
--                  Se a conta existir
--                  ------------------------------------------------------------*/
--               if ( @IN_CT1 = '1' ) begin
--                  if ( @cCTXX_NORMAL = '1' ) begin
--                     if ( @IN_CV1_VALOR < 0 ) begin                  
--                        If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
--                        select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
--                     end else begin
--                        If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO+ @IN_CV1_VALOR, 2 )
--                        select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
--                     end
--                  end else begin
--                     if ( @IN_CV1_VALOR < 0 ) begin
--                        If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO	= Round( @nCQX_DEBITO+ Abs( @IN_CV1_VALOR ), 2 )
--                        select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
--                     end else begin
--                        If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR, 2 )
--                        select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
--                     end
--                  end
--               end else begin --Se nao tiver conta no orcamento, considerar como devedor
--                  if ( @IN_CV1_VALOR < 0 ) begin
--                     if ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
--                     select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
--                  end else begin
--                     If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO+ @IN_CV1_VALOR, 2 )
--                     select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
--                  end
--               end
--               /* ------------------------------------------------------------
--                  Update no CQ9
--                  ------------------------------------------------------------*/
--               begin tran
--               update CQ9###
--                  set CQ9_DEBITO = @nCTXX_DEBITO, CQ9_CREDIT = @nCTXX_CREDIT
--                where R_E_C_N_O_ = @iRecno
--               commit tran
--            end
--         End*/
      /* ------------------------------------------------------------
          CTD - Itens - ATUALIZA DEBITO/CREDITO ENTIDADES CQ8/CQ9 
         ------------------------------------------------------------*/
      /* ------------------------------------------------------------
          CQ8 - ATUALIZA DEBITO/CREDITO ENTIDADES CQ8 - item
         ------------------------------------------------------------*/
   select @cTpSaldo = '0'
   select @cStatus  = '1'
   select @cSlBase  = 'S'
   select @cDtLp    = ' '
   select @cLp      = 'N'
   select @iRecno      = 0 
   select @nCQX_CREDIT = 0
   select @nCQX_DEBITO = 0
   
   select @iRecno   = IsNull(R_E_C_N_O_, 0) , @nCQX_CREDIT = IsNull(CQ8_CREDIT, 0), @nCQX_DEBITO = IsNull(CQ8_DEBITO, 0)
     from CQ8### CQ8
    where CQ8_FILIAL = @cFilial_CQ8
      and CQ8_MOEDA  = @IN_CV1_MOEDA
      and CQ8_TPSALD = '0'
      and CQ8_IDENT  = 'CTD'
      and CQ8_CODIGO = @cCTXX_ITEM
      and CQ8_DATA   = @cDataF
      and D_E_L_E_T_ = ' '
   /* ------------------------------------------------------------
      Se não existe
      ------------------------------------------------------------*/
   if ( @iRecno is Null or @iRecno = 0 ) begin
      if ( @IN_COPERACAO = '1' ) begin
         if ( @IN_CT1 = '1' ) begin --Se tiver conta, verificar a natureza da conta.
            If ( @cCTXX_NORMAL = '1' ) begin
               If ( @IN_CV1_VALOR < 0 ) begin
                  select @nCTXX_CREDIT = Round( @nCQX_CREDIT + ( Abs( @IN_CV1_VALOR ) * @IN_FATORCTH ), 2 )
               end else begin
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               end
            end else begin
               If ( @IN_CV1_VALOR < 0 ) begin
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               end else begin
                  select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               end
            end
         end else begin  --Se nao tiver conta no orcamento, considerar como devedor   
            If ( @IN_CV1_VALOR < 0 ) begin
               select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
            end else begin
               select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
            end
         end
         /* ------------------------------------------------------------
            Insert no CQ8
            ------------------------------------------------------------*/
         select @iRecno = 0
		 
         ##UNIQUEKEY_START
		 select @iRecno = isnull( max( R_E_C_N_O_ ), 0 )
           from CQ8###
		 where CQ8_FILIAL		= @cFilial_CQ8
			   and CQ8_DATA		= @cDataF
			   and CQ8_IDENT	= 'CTD'
			   and CQ8_CODIGO	= @cCTXX_ITEM
			   and CQ8_MOEDA	= @IN_CV1_MOEDA
			   and CQ8_TPSALD	= @cTpSaldo
			   and CQ8_LP		= @cLp 
			   and D_E_L_E_T_	= ' '
		 ##UNIQUEKEY_END
		 
         If @iRecno = 0 Begin

			select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ8###					
			select @iRecno = @iRecno + 1
			
			 ##TRATARECNO @iRecno\
			 begin tran
			 Insert into CQ8### (CQ8_FILIAL,   CQ8_IDENT, CQ8_CODIGO,  CQ8_MOEDA,     CQ8_DATA, CQ8_TPSALD, CQ8_SLBASE, CQ8_DTLP, CQ8_LP, CQ8_STATUS, CQ8_DEBITO,    CQ8_CREDIT,    R_E_C_N_O_ )
						 values (@cFilial_CQ8, 'CTD',     @cCTXX_ITEM, @IN_CV1_MOEDA, @cDataF,  @cTpSaldo,  @cSlBase,   @cDtLp,   @cLp,   @cStatus,   0, 0, @iRecno )
			 commit tran
			 ##FIMTRATARECNO
		 end

		/* ------------------------------------------------------------
		UPDATE no CQ8
		------------------------------------------------------------*/
		begin tran
			update CQ8### 
				set CQ8_DEBITO = CQ8_DEBITO + @nCTXX_DEBITO, CQ8_CREDIT = CQ8_CREDIT + @nCTXX_CREDIT
			where R_E_C_N_O_ =  @iRecno 
		commit tran			 
		 
		 
      end
   end else begin
      /* ------------------------------------------------------------
         Se a conta existir
         ------------------------------------------------------------*/
      if ( @IN_CT1 = '1' ) begin
         if ( @cCTXX_NORMAL = '1' ) begin
            if ( @IN_CV1_VALOR < 0 ) begin
               if ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
               select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
            end else begin
               If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO + (@IN_CV1_VALOR * @IN_FATORCTH), 2 )
               select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
            end
         end else begin
            if ( @IN_CV1_VALOR < 0 ) begin
               If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO	= Round( @nCQX_DEBITO + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
               select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
            end else begin
               If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
            end
         end
      end else begin --Se nao tiver conta no orcamento, considerar como devedor
         if ( @IN_CV1_VALOR < 0 ) begin
            if ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
            select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
         end else begin
            If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
            select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
         end
      end
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
       CQ9 - Item - ATUALIZA DEBITO/CREDITO ENTIDADES CQ9
      ------------------------------------------------------------*/
   select @iRecno      = 0 
   select @nCQX_CREDIT = 0
   select @nCQX_DEBITO = 0
   
   select @iRecno   = IsNull(R_E_C_N_O_, 0) , @nCQX_CREDIT = IsNull(CQ9_CREDIT, 0), @nCQX_DEBITO = IsNull(CQ9_DEBITO, 0)
     from CQ9### CQ9
    where CQ9_FILIAL = @cFilial_CQ9
      and CQ9_MOEDA  = @IN_CV1_MOEDA
      and CQ9_TPSALD = '0'
      and CQ9_IDENT  = 'CTD'
      and CQ9_CODIGO = @cCTXX_ITEM
      and CQ9_DATA   = @IN_CV1_DTFIM
      and D_E_L_E_T_ = ' '
   /* ------------------------------------------------------------
      Se não existe
      ------------------------------------------------------------*/
   if ( @iRecno is Null or @iRecno = 0 ) begin
      if ( @IN_COPERACAO = '1' ) begin
         if ( @IN_CT1 = '1' ) begin --Se tiver conta, verificar a natureza da conta.
            If ( @cCTXX_NORMAL = '1' ) begin
               If ( @IN_CV1_VALOR < 0 ) begin
                  select @nCTXX_CREDIT = Round( @nCQX_CREDIT + ( Abs( @IN_CV1_VALOR ) * @IN_FATORCTH ), 2 )
               end else begin
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               end
            end else begin
               If ( @IN_CV1_VALOR < 0 ) begin
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               end else begin
                  select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               end
            end
         end else begin  --Se nao tiver conta no orcamento, considerar como devedor   
            If ( @IN_CV1_VALOR < 0 ) begin
               select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
            end else begin
               select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
            end
         end
         /* ------------------------------------------------------------
            Insert no CQ9
            ------------------------------------------------------------*/
         select @iRecno = 0
		 
		 ##UNIQUEKEY_START
         select @iRecno = isnull( max( R_E_C_N_O_ ), 0 )
           from CQ9###
		 where CQ9_FILIAL		= @cFilial_CQ9 
			   and CQ9_DATA		= @IN_CV1_DTFIM
			   and CQ9_IDENT	= 'CTD'
			   and CQ9_CODIGO	= @cCTXX_ITEM
			   and CQ9_MOEDA	= @IN_CV1_MOEDA
			   and CQ9_TPSALD	= @cTpSaldo
			   and CQ9_LP		= @cLp
			   and D_E_L_E_T_  	= ' '
		 ##UNIQUEKEY_END
		 
         If @iRecno = 0 Begin

			select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ9###					
			select @iRecno = @iRecno + 1
			
			 ##TRATARECNO @iRecno\
			 begin tran
			 Insert into CQ9### (CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO,  CQ9_MOEDA,     CQ9_DATA,      CQ9_TPSALD, CQ9_SLBASE, CQ9_DTLP, CQ9_LP, CQ9_STATUS, CQ9_DEBITO,    CQ9_CREDIT,    R_E_C_N_O_ )
						 values (@cFilial_CQ9, 'CTD',     @cCTXX_ITEM, @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,   @cDtLp,   @cLp,   @cStatus,   0, 0, @iRecno )
			 commit tran
			 ##FIMTRATARECNO
		 end
		 
		 /* ------------------------------------------------------------
		UPDATE no CQ9
		------------------------------------------------------------*/
		begin tran
			update CQ9### 
				set CQ9_DEBITO = CQ9_DEBITO + @nCTXX_DEBITO, CQ9_CREDIT = CQ9_CREDIT + @nCTXX_CREDIT
			where R_E_C_N_O_ =  @iRecno 
		commit tran	
				 
      end
   end else begin
      /* ------------------------------------------------------------
         Se a conta existir
         ------------------------------------------------------------*/
      if ( @IN_CT1 = '1' ) begin
         if ( @cCTXX_NORMAL = '1' ) begin
            if ( @IN_CV1_VALOR < 0 ) begin
               if ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
               select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
            end else begin
               If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO + (@IN_CV1_VALOR * @IN_FATORCTH), 2 )
               select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
            end
         end else begin
            if ( @IN_CV1_VALOR < 0 ) begin
               If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO	= Round( @nCQX_DEBITO + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
               select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
            end else begin
               If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
               select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
            end
         end
      end else begin --Se nao tiver conta no orcamento, considerar como devedor
         if ( @IN_CV1_VALOR < 0 ) begin
            if ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ) * @IN_FATORCTH, 2 )
            select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
         end else begin
            If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR * @IN_FATORCTH, 2 )
            select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
         end
      end
      /* ------------------------------------------------------------
         Update no CQ9
         ------------------------------------------------------------*/
      begin tran
      update CQ9###
         set CQ9_DEBITO = @nCTXX_DEBITO, CQ9_CREDIT = @nCTXX_CREDIT
       where R_E_C_N_O_ = @iRecno
      commit tran
   end
   select @OUT_RESULTADO = '1'
end

