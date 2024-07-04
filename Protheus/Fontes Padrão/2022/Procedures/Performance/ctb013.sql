Create procedure CTB013_##
 ( 
   @IN_FILIALCOR  Char('CV1_FILIAL'),
   @IN_CV1_CTHINI Char('CV1_CTHINI'),
   @IN_CV1_CTDINI Char('CV1_CTDINI'),
   @IN_CV1_CTTINI Char('CV1_CTTINI'),
   @IN_CV1_CT1INI Char('CV1_CT1INI'),
   @IN_CT1        Char(01),
   @IN_CTT        Char(01),
   @IN_CTD        Char(01),
   @IN_CTH        Char(01),
   @IN_CV1_MOEDA  Char('CV1_MOEDA'),
   @IN_CV1_DTFIM  Char('CV1_DTFIM'),
   @IN_CV1_VALOR  Float,
   @IN_COPERACAO  Char(01),
   @OUT_RESULTADO Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Grava os saldos do arquivo CQ6. </d>
    Funcao do Siga  -     Ctb390CTI()  - Grava os saldos do arquivo CTI.
    Fonte Microsiga - <s> CTBA390.PRW </s>
    Entrada         - <ri> @IN_FILIALCOR  - Filial
                           @IN_CV1_CTHINI - ClVl Inicial
                           @IN_CV1_CTDINI - Item Inicial
                           @IN_CV1_CTTINI - CCusto Inicial
                           @IN_CV1_CT1INI - Conta Inicial
                           @IN_CT1        - Flag Conta Orcada
                           @IN_CTT        - Flag CCusto Orcado
                           @IN_CTD        - Flag Item Orcado
                           @IN_CTH        - Flag ClVl Orcado
                           @IN_CV1_MOEDA  - Moeda
                           @IN_CV1_DTFIM  - Data
                           @IN_CV1_VALOR  - Valor
                           @IN_COPERACAO  - Operacao
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r> Alice Y Yamamoto </r>
    Data        :     19/09/2003
-------------------------------------------------------------------------------------- */
declare @cFilial_CQ6   char('CQ6_FILIAL')
declare @cFilial_CQ7   char('CQ7_FILIAL')
declare @cFilial_CQ8   char('CQ8_FILIAL')
declare @cFilial_CQ9   char('CQ9_FILIAL')
declare @cFilial_CT1   char('CT1_FILIAL')
declare @cAux          char(03)
declare @cAux1         char(01)
declare @nCQX_CREDIT   Float
declare @nCQX_DEBITO  Float
declare @iRecno        integer
declare @cTab          Char(03)
declare @cCTXX_CONTA   char('CT1_CONTA')
declare @cCTXX_NORMAL  char('CT1_NORMAL')
declare @cCTXX_CUSTO   char('CTT_CUSTO')
declare @cCTXX_ITEM    char('CTD_ITEM')
declare @cCTXX_CLVL    char('CTH_CLVL')
declare @nCTXX_DEBITO  Float
declare @nCTXX_CREDIT  Float
declare @cTpSaldo      Char('CQ6_TPSALD')
declare @cStatus       Char('CQ6_STATUS')
declare @cSlBase       Char('CQ6_SLBASE')
declare @cDtLp         Char(08)
declare @cLp           Char('CQ6_LP')
declare @cDataF        Char( 08 )

begin
   
   select @cAux = 'CQ6'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ6 OutPut
   select @cAux = 'CQ7'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ7 OutPut
   select @cAux = 'CQ8'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ8 OutPut
   select @cAux = 'CQ9'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ9 OutPut
   select @cAux = 'CT1'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CT1 OutPut
   Exec LASTDAY_## @IN_CV1_DTFIM, @cDataF OutPut
   
   select @OUT_RESULTADO = '0'
   Select @cCTXX_NORMAL = ' '
   Select @nCTXX_DEBITO = 0
   Select @nCTXX_CREDIT = 0
   
   Select @nCQX_DEBITO= 0
   Select @nCQX_CREDIT = 0
   
   if ( @IN_CT1 = '1' ) select @cCTXX_CONTA = @IN_CV1_CT1INI
   else            select @cCTXX_CONTA = ' '
   
   if ( @IN_CTT = '1' ) select @cCTXX_CUSTO = @IN_CV1_CTTINI
   else            select @cCTXX_CUSTO = ' '
   
   if ( @IN_CTD = '1' ) select @cCTXX_ITEM = @IN_CV1_CTDINI
   else            select @cCTXX_ITEM = ' '
   
   if ( @IN_CTH = '1' ) select @cCTXX_CLVL = @IN_CV1_CTHINI
   else            select @cCTXX_CLVL = ' '
   
   if ( @IN_CTH = '1' ) begin
      
      If @cCTXX_CONTA != ' ' begin
         select @cCTXX_NORMAL = IsNull(CT1_NORMAL,' ')
           from CT1###
          where CT1_FILIAL = @cFilial_CT1
            and CT1_CONTA  = @cCTXX_CONTA
            and D_E_L_E_T_ = ' '
      End
      /* ------------------------------------------------------------
         Debito/Cerdito CQ6
         ------------------------------------------------------------*/
      select @cTpSaldo = '0'
      select @cStatus  = '1'
      select @cSlBase  = 'S'
      select @cDtLp    = ' '
      select @cLp      = 'N'
      select @iRecno      = 0 
      select @nCQX_CREDIT = 0
      select @nCQX_DEBITO = 0
      
      select @iRecno   = IsNull(R_E_C_N_O_, 0) , @nCQX_CREDIT = IsNull(CQ6_CREDIT, 0), @nCQX_DEBITO= IsNull(CQ6_DEBITO, 0)
        from CQ6### CQ6
       where CQ6_FILIAL = @cFilial_CQ6
         and CQ6_MOEDA  = @IN_CV1_MOEDA
         and CQ6_TPSALD = '0'
         and CQ6_CONTA  = @cCTXX_CONTA
         and CQ6_CCUSTO  = @cCTXX_CUSTO
         and CQ6_ITEM   = @cCTXX_ITEM
         and CQ6_CLVL   = @cCTXX_CLVL
         and CQ6_DATA   = @cDataF
         and D_E_L_E_T_ = ' '
      
      if ( @iRecno is Null or @iRecno = 0 ) begin
         if ( @IN_COPERACAO = '1' ) begin
            if ( @IN_CT1 = '1' ) begin --Se tiver conta, verificar a natureza da conta.
               If ( @cCTXX_NORMAL = '1' ) begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
                  end else begin
                     select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR, 2 )
                  end
			      end else begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     select @nCTXX_DEBITO = Round( @nCQX_DEBITO + Abs(@IN_CV1_VALOR), 2 )
                  end else begin
                     select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR, 2 )
                  end
               end
            end else begin  --Se nao tiver conta no orcamento, considerar como devedor
               
               If ( @IN_CV1_VALOR < 0 ) begin
                  select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
               end else begin
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR, 2 )
               end
            end
            /* ------------------------------------------------------------
               Insert no CQ6
               ------------------------------------------------------------*/
            select @iRecno = 0
            
			##UNIQUEKEY_START
			select @iRecno = isnull( max( R_E_C_N_O_ ), 0 )
              from CQ6###
			where CQ6_FILIAL		= @cFilial_CQ6
				  and CQ6_DATA		= @cDataF
				  and CQ6_CLVL		= @cCTXX_CLVL
				  and CQ6_ITEM		= @cCTXX_ITEM
				  and CQ6_CCUSTO	= @cCTXX_CUSTO
				  and CQ6_CONTA		= @cCTXX_CONTA
				  and CQ6_MOEDA		= @IN_CV1_MOEDA
				  and CQ6_TPSALD	= @cTpSaldo	 
				  and CQ6_LP		= @cLp
				  and D_E_L_E_T_	= ' '
			##UNIQUEKEY_END
			
            If @iRecno = 0 Begin

				select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ6###					
				select @iRecno = @iRecno + 1
				
				##TRATARECNO @iRecno\
				begin tran
				Insert into CQ6### ( CQ6_FILIAL,   CQ6_CONTA,    CQ6_CCUSTO,    CQ6_ITEM,    CQ6_CLVL,    CQ6_MOEDA,     CQ6_DATA, CQ6_TPSALD, CQ6_SLBASE,
									 CQ6_DTLP,     CQ6_LP,      CQ6_STATUS,  CQ6_DEBITO,    CQ6_CREDIT,   R_E_C_N_O_ )
							 values( @cFilial_CQ6, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM, @cCTXX_CLVL,  @IN_CV1_MOEDA, @cDataF,   @cTpSaldo,  @cSlBase,
									 @cDtLp,       @cLp,        @cStatus,    0, 0,@iRecno )
				commit tran
				##FIMTRATARECNO

			end
			
			/* ------------------------------------------------------------
			UPDATE no CQ6
			------------------------------------------------------------*/
			begin tran
				update CQ6### 
					set CQ6_DEBITO = CQ6_DEBITO + @nCTXX_DEBITO, CQ6_CREDIT = CQ6_CREDIT + @nCTXX_CREDIT
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
                  If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
               end else begin
                  If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO+ @IN_CV1_VALOR, 2 )
                  select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
               end
            end else begin
               if ( @IN_CV1_VALOR < 0 ) begin
                  If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO	= Round( @nCQX_DEBITO+ Abs( @IN_CV1_VALOR ), 2 )
                  select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
               end else begin
                  If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR, 2 )
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
               end
            end
         end else begin --Se nao tiver conta no orcamento, considerar como devedor
            if ( @IN_CV1_VALOR < 0 ) begin
               if ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
               select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
            end else begin
               If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO+ @IN_CV1_VALOR, 2 )
               select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
            end
         end
         /* ------------------------------------------------------------
            Update no CQ6
            ------------------------------------------------------------*/
         begin tran
         update CQ6###
            set CQ6_DEBITO = @nCTXX_DEBITO, CQ6_CREDIT = @nCTXX_CREDIT
          where R_E_C_N_O_ = @iRecno
         commit tran
      end
      /* ------------------------------------------------------------
         ATUALIZA DEBITO/CERDITO CQ7 DIA
         ------------------------------------------------------------*/
      select @iRecno      = 0 
      select @nCQX_CREDIT = 0
      select @nCQX_DEBITO = 0
      
      select @iRecno   = IsNull(R_E_C_N_O_, 0) , @nCQX_CREDIT = IsNull(CQ7_CREDIT, 0), @nCQX_DEBITO = IsNull(CQ7_DEBITO, 0)
        from CQ7### CQ7
       where CQ7_FILIAL = @cFilial_CQ7
         and CQ7_MOEDA  = @IN_CV1_MOEDA
         and CQ7_TPSALD = '0'
         and CQ7_CONTA  = @cCTXX_CONTA
         and CQ7_CCUSTO  = @cCTXX_CUSTO
         and CQ7_ITEM   = @cCTXX_ITEM
         and CQ7_CLVL   = @cCTXX_CLVL
         and CQ7_DATA   = @IN_CV1_DTFIM
         and D_E_L_E_T_ = ' '
      
      if ( @iRecno is Null or @iRecno = 0 ) begin
         if ( @IN_COPERACAO = '1' ) begin
            if ( @IN_CT1 = '1' ) begin --Se tiver conta, verificar a natureza da conta.
               If ( @cCTXX_NORMAL = '1' ) begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
                  end else begin
                     select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR, 2 )
                  end
			      end else begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     select @nCTXX_DEBITO = Round( @nCQX_DEBITO + Abs(@IN_CV1_VALOR), 2 )
                  end else begin
                     select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR, 2 )
                  end
               end
            end else begin  --Se nao tiver conta no orcamento, considerar como devedor
               
               If ( @IN_CV1_VALOR < 0 ) begin
                  select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
               end else begin
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR, 2 )
               end
            end
            select @cTpSaldo = '0'
            select @cStatus  = '1'
            select @cSlBase  = 'S'
            select @cDtLp    = ' '
            select @cLp      = 'N'
            /* ------------------------------------------------------------
               Insert no CQ7
               ------------------------------------------------------------*/
            select @iRecno = 0
            
			##UNIQUEKEY_START
			select @iRecno = isnull( max( R_E_C_N_O_ ), 0 )
              from CQ7###
			where CQ7_FILIAL		= @cFilial_CQ7
				  and CQ7_DATA		= @IN_CV1_DTFIM
				  and CQ7_CLVL		= @cCTXX_CLVL
				  and CQ7_ITEM		= @cCTXX_ITEM
				  and CQ7_CCUSTO	= @cCTXX_CUSTO
				  and CQ7_CONTA		= @cCTXX_CONTA
				  and CQ7_MOEDA		= @IN_CV1_MOEDA
				  and CQ7_TPSALD	= @cTpSaldo	 
				  and CQ7_LP		= @cLp
				  and D_E_L_E_T_	= ' '
			##UNIQUEKEY_END	  
				  
            If @iRecno = 0 Begin

				select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ7###					
				select @iRecno = @iRecno + 1
				
				##TRATARECNO @iRecno\
				begin tran
				Insert into CQ7### ( CQ7_FILIAL,   CQ7_CONTA,    CQ7_CCUSTO,   CQ7_ITEM,      CQ7_CLVL,      CQ7_MOEDA,     CQ7_DATA,      CQ7_TPSALD, CQ7_SLBASE,
									 CQ7_DTLP,     CQ7_LP,       CQ7_STATUS,   CQ7_DEBITO,    CQ7_CREDIT,    R_E_C_N_O_ )
							 values( @cFilial_CQ7, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,   @cCTXX_CLVL,   @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
									 @cDtLp,       @cLp,         @cStatus,     0, 0, @iRecno )
				commit tran
				##FIMTRATARECNO
			end
			
			/* ------------------------------------------------------------
			UPDATE no CQ7
			------------------------------------------------------------*/
			begin tran
				update CQ7### 
					set CQ7_DEBITO = CQ7_DEBITO + @nCTXX_DEBITO, CQ7_CREDIT = CQ7_CREDIT + @nCTXX_CREDIT
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
                  If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
               end else begin
                  If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO+ @IN_CV1_VALOR, 2 )
                  select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
               end
            end else begin
               if ( @IN_CV1_VALOR < 0 ) begin
                  If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO	= Round( @nCQX_DEBITO+ Abs( @IN_CV1_VALOR ), 2 )
                  select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
               end else begin
                  If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR, 2 )
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
               end
            end
         end else begin --Se nao tiver conta no orcamento, considerar como devedor
            if ( @IN_CV1_VALOR < 0 ) begin
               if ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
               select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
            end else begin
               If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO+ @IN_CV1_VALOR, 2 )
               select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
            end
         end
         select @cTpSaldo = '0'
         select @cSlBase  = 'S'
         select @cLp      = 'N'
         /* ------------------------------------------------------------
            Update no CQ7
            ------------------------------------------------------------*/
         begin tran
         update CQ7###
            set CQ7_DEBITO = @nCTXX_DEBITO, CQ7_CREDIT = @nCTXX_CREDIT
          where R_E_C_N_O_ = @iRecno
         commit tran
      end
      /* ------------------------------------------------------------
          CTH - CLASSE VALOR - ATUALIZA DEBITO/CREDITO ENTIDADES CQ8/CQ9 
         ------------------------------------------------------------*/
      If @IN_CTH = '1' begin
         /* ------------------------------------------------------------
             CQ8 - ATUALIZA DEBITO/CREDITO ENTIDADES CQ8 - CLVL
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
            and CQ8_IDENT  = 'CTH'
            and CQ8_CODIGO = @cCTXX_CLVL
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
                        select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
                     end else begin
                        select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR, 2 )
                     end
		            end else begin
                     If ( @IN_CV1_VALOR < 0 ) begin
                        select @nCTXX_DEBITO = Round( @nCQX_DEBITO + Abs(@IN_CV1_VALOR), 2 )
                     end else begin
                        select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR, 2 )
                     end
                  end
               end else begin  --Se nao tiver conta no orcamento, considerar como devedor
                  If ( @IN_CV1_VALOR < 0 ) begin
                     select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
                  end else begin
                     select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR, 2 )
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
					 and CQ8_DATA	= @cDataF
					 and CQ8_IDENT	= 'CTH'
					 and CQ8_CODIGO	= @cCTXX_CLVL
					 and CQ8_MOEDA	= @IN_CV1_MOEDA
					 and CQ8_TPSALD	= @cTpSaldo
					 and CQ8_LP		= @cLp
					 and D_E_L_E_T_ = ' '
			   ##UNIQUEKEY_END
			   
               If @iRecno = 0 Begin

					select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ8###					
					select @iRecno = @iRecno + 1
			   
				   ##TRATARECNO @iRecno\
				   begin tran
				   Insert into CQ8### (CQ8_FILIAL,   CQ8_IDENT, CQ8_CODIGO,  CQ8_MOEDA,     CQ8_DATA, CQ8_TPSALD, CQ8_SLBASE, CQ8_DTLP, CQ8_LP, CQ8_STATUS, CQ8_DEBITO,    CQ8_CREDIT,    R_E_C_N_O_ )
							   values (@cFilial_CQ8, 'CTH',     @cCTXX_CLVL, @IN_CV1_MOEDA, @cDataF,  @cTpSaldo,  @cSlBase,   @cDtLp,   @cLp,   @cStatus,   0, 0, @iRecno )
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
                     If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
                     select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
                  end else begin
                     If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO+ @IN_CV1_VALOR, 2 )
                     select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
                  end
               end else begin
                  if ( @IN_CV1_VALOR < 0 ) begin
                     If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO	= Round( @nCQX_DEBITO+ Abs( @IN_CV1_VALOR ), 2 )
                     select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
                  end else begin
                     If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR, 2 )
                     select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
                  end
               end
            end else begin --Se nao tiver conta no orcamento, considerar como devedor
               if ( @IN_CV1_VALOR < 0 ) begin
                  if ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
               end else begin
                  If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO+ @IN_CV1_VALOR, 2 )
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
            and CQ9_IDENT  = 'CTH'
            and CQ9_CODIGO = @cCTXX_CLVL
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
                        select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
                     end else begin
                        select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR, 2 )
                     end
		            end else begin
                     If ( @IN_CV1_VALOR < 0 ) begin
                        select @nCTXX_DEBITO = Round( @nCQX_DEBITO + Abs(@IN_CV1_VALOR), 2 )
                     end else begin
                        select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR, 2 )
                     end
                  end
               end else begin  --Se nao tiver conta no orcamento, considerar como devedor
                  If ( @IN_CV1_VALOR < 0 ) begin
                     select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
                  end else begin
                     select @nCTXX_DEBITO = Round( @nCQX_DEBITO + @IN_CV1_VALOR, 2 )
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
					 and CQ9_DATA	= @IN_CV1_DTFIM
					 and CQ9_IDENT	= 'CTH'	
					 and CQ9_CODIGO	= @cCTXX_CLVL
					 and CQ9_MOEDA	= @IN_CV1_MOEDA
					 and CQ9_TPSALD	= @cTpSaldo	
					 and CQ9_LP		= @cLp
					 and D_E_L_E_T_	= ' '
			   ##UNIQUEKEY_END
			   
               If @iRecno = 0 Begin

					select @iRecno = ISNULL(Max(R_E_C_N_O_), 0) FROM CQ9###					
					select @iRecno = @iRecno + 1
				   ##TRATARECNO @iRecno\
				   begin tran
				   Insert into CQ9### (CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO,  CQ9_MOEDA,     CQ9_DATA,      CQ9_TPSALD, CQ9_SLBASE, CQ9_DTLP, CQ9_LP, CQ9_STATUS, CQ9_DEBITO,    CQ9_CREDIT,    R_E_C_N_O_ )
							   values (@cFilial_CQ9, 'CTH',     @cCTXX_CLVL, @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,   @cDtLp,   @cLp,   @cStatus,   0, 0, @iRecno )
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
                     If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
                     select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
                  end else begin
                     If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO+ @IN_CV1_VALOR, 2 )
                     select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
                  end
               end else begin
                  if ( @IN_CV1_VALOR < 0 ) begin
                     If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO	= Round( @nCQX_DEBITO+ Abs( @IN_CV1_VALOR ), 2 )
                     select @nCTXX_CREDIT = Round( @nCQX_CREDIT, 2 )
                  end else begin
                     If ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + @IN_CV1_VALOR, 2 )
                     select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
                  end
               end
            end else begin --Se nao tiver conta no orcamento, considerar como devedor
               if ( @IN_CV1_VALOR < 0 ) begin
                  if ( @IN_COPERACAO = '1' ) select @nCTXX_CREDIT = Round( @nCQX_CREDIT + Abs( @IN_CV1_VALOR ), 2 )
                  select @nCTXX_DEBITO = Round( @nCQX_DEBITO, 2 )
               end else begin
                  If ( @IN_COPERACAO = '1' ) select @nCTXX_DEBITO = Round( @nCQX_DEBITO+ @IN_CV1_VALOR, 2 )
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
      End
   End
   select @OUT_RESULTADO = '1'
end
