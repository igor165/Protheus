Create procedure CTB194_## ( 
   @IN_FILCQA       char('CQA_FILIAL'),
   @IN_RECMIN       Integer ,
   @IN_RECMAX       Integer ,
   @IN_LCUSTO       Char(01),
   @IN_LITEM        Char(01),
   @IN_LCLVL        Char(01),
   @OUT_RESULTADO   Char(01) OutPut )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P.12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA193.PRW </s>
    Descricao       - <d>  Reprocessamento de saldo em fila </d>
    Procedure       -      Atualizacao de slds Bases CQ0,CQ1,CQ2,CQ3
    Funcao do Siga  -      Ct190SlBse()
    Entrada         - <ri> @IN_RECMIN       - Recno Inicial da CQA
    					   @IN_RECMAX       - Recno Final da CQA 
    				  </ri>
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alvaro Camillo Neto	</r>
    Data        :     03/11/2003
    Obs: a variável @iTranCount = 0 será trocada por 'commit tran' no CFGX051 pro SQLSERVER 
         e SYBASE
   -------------------------------------------------------------------------------------- */
declare @cFilial_CQA char('CQA_FILIAL')
declare @cFILCT2     char('CT2_FILIAL')
declare @cFilial_CQ0 char('CQ0_FILIAL')
declare @cFilial_CQ1 char('CQ1_FILIAL')
declare @cFilial_CQ2 char('CQ2_FILIAL')
declare @cFilial_CQ3 char('CQ3_FILIAL')
declare @cFilial_CQ4 char('CQ4_FILIAL')
declare @cFilial_CQ5 char('CQ5_FILIAL')
declare @cFilial_CQ6 char('CQ6_FILIAL')
declare @cFilial_CQ7 char('CQ7_FILIAL')
declare @cFilial_CQ8 char('CQ8_FILIAL')
declare @cFilial_CQ9 char('CQ9_FILIAL')
declare @cAux        char(03)
declare @nDebMes     Float
declare @nCrdMes     Float
declare @cTabela     Char(03)
declare @iRecno      Integer
declare @nCTX_DEBITO Float
declare @nCTX_CREDIT Float
declare @cCTX_DTLP   Char(08)
declare @cCTX_LP     Char('CQ0_LP')
declare @cCTX_STATUS Char('CQ0_STATUS')
declare @cCTX_SLBASE Char('CQ0_SLBASE')
declare @cCT2_DTLP   Char(08)
declare @cTIPO       Char(01)


declare @cDATA       Char(08)
declare @cCONTA      Char('CQ0_CONTA')
declare @cCUSTO      Char('CQ2_CCUSTO')
declare @cITEM       Char('CQ4_ITEM')
declare @cCLVL       Char('CQ6_CLVL')
declare @cMOEDA      Char('CQ0_MOEDA')
declare @nVALOR      Float
declare @cIdent      VarChar(03)
declare @cDataI      Char(08)
declare @cDataF      Char(08)
declare @RecMin      integer
declare @RecMax      integer
declare @cTPSALD     Char('CT2_TPSALD')

declare @iTranCount  Integer --Var.de ajuste para SQLServer e Sybase.-- Será trocada por Commit no CFGX051 após passar pelo Parse

begin
   
   select @OUT_RESULTADO = '0'
   select @RecMin = @IN_RECMIN 
   select @RecMax = @IN_RECMAX
   select @cFilial_CQA = @IN_FILCQA
   
   Declare CUR_CTB190 insensitive cursor for
      Select CT2_FILIAL, CT2_DEBITO, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '1',CT2_TPSALD
        From CQA### CQA, CT2### CT2 
       Where CQA_FILIAL = @cFilial_CQA
		   and CQA.R_E_C_N_O_  between @RecMin and @RecMax 
         and CQA.D_E_L_E_T_ = ' '
		   and CT2_FILIAL = CQA_FILCT2
		   and CT2_DATA   = CQA_DATA
		   and CT2_LOTE   = CQA_LOTE
		   and CT2_SBLOTE = CQA_SBLOTE
		   and CT2_DOC    = CQA_DOC
		   and CT2_LINHA  = CQA_LINHA
		   and CT2_TPSALD = CQA_TPSALD
		   and CT2_EMPORI = CQA_EMPORI
		   and CT2_FILORI = CQA_FILORI
		   and CT2_MOEDLC = CQA_MOEDLC
         and (CT2_DC = '1' or CT2_DC = '3')
         and CT2_DEBITO != ' '
		   and CT2.D_E_L_E_T_ = ' '
       Group By CT2_FILIAL, CT2_DEBITO, CT2_MOEDLC, CT2_DATA, CT2_DTLP,CT2_TPSALD
       Union
      Select CT2_FILIAL, CT2_CREDIT, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '2',CT2_TPSALD
        From CQA### CQA, CT2### CT2
       Where CQA_FILIAL = @cFilial_CQA
		   and CQA.R_E_C_N_O_  between @RecMin and @RecMax 
         and CQA.D_E_L_E_T_ = ' '
		   and CT2_FILIAL = CQA_FILCT2
		   and CT2_DATA   = CQA_DATA
		   and CT2_LOTE   = CQA_LOTE
		   and CT2_SBLOTE = CQA_SBLOTE
		   and CT2_DOC    = CQA_DOC
		   and CT2_LINHA  = CQA_LINHA
		   and CT2_TPSALD = CQA_TPSALD
		   and CT2_EMPORI = CQA_EMPORI
		   and CT2_FILORI = CQA_FILORI
		   and CT2_MOEDLC = CQA_MOEDLC 
         and (CT2_DC = '2' or CT2_DC = '3')
         and CT2_CREDIT != ' '
		   and CT2.D_E_L_E_T_ = ' '
      Group By CT2_FILIAL, CT2_CREDIT, CT2_MOEDLC, CT2_DATA, CT2_DTLP,CT2_TPSALD
      order by 1, 2, 3, 4, 5, 6, 8
   for read only
   Open CUR_CTB190
   Fetch CUR_CTB190 into  @cFILCT2, @cCONTA, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO,@cTPSALD
   
   While (@@Fetch_status = 0 ) begin
      /*---------------------------------------------------------------
        Qdo muda a chave inicilalizo as variaveis pa atualuzar o MES
        --------------------------------------------------------------- */
      select @cAux = 'CQ0'
      exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ0 OutPut
      select @cAux = 'CQ1'
      exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ1 OutPut
      
      select @nCTX_DEBITO = 0
      select @nCTX_CREDIT = 0
      select @cCTX_STATUS = '1'
      select @cCTX_SLBASE = 'S'
      select @cCTX_DTLP = ' '
      /*---------------------------------------------------------------
        Ajusta dados para GRAVAÇÃO DE SALDOS DO DIA  SQ1
        --------------------------------------------------------------- */
      if @cTIPO = '1' begin
         select @nCTX_DEBITO = Round(@nVALOR, 2)
         select @nCTX_CREDIT = 0
      end
      if @cTIPO = '2' begin
         select @nCTX_CREDIT = Round(@nVALOR, 2)
         select @nCTX_DEBITO = 0
      end
      if @cCT2_DTLP = ' ' begin
         select @cCTX_LP = 'N'
         select @cCTX_DTLP = ' '
      end else begin
         select @cCTX_LP = 'Z'
         select @cCTX_DTLP = @cCT2_DTLP
      end
      /*---------------------------------------------------------------
        Verifica se a linha ja existe no CQ1
        --------------------------------------------------------------- */      
      select @iRecno = 0
      ##UNIQUEKEY_START
      select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
        From CQ1###
       Where CQ1_FILIAL = @cFilial_CQ1
         and CQ1_CONTA  = @cCONTA
         and CQ1_MOEDA  = @cMOEDA
         and CQ1_DATA   = @cDATA
         and CQ1_TPSALD = @cTPSALD
         and CQ1_LP     = @cCTX_LP
         and CQ1_DTLP   = @cCTX_DTLP
         and D_E_L_E_T_ = ' '
      ##UNIQUEKEY_END

      If @iRecno = 0 begin
         select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ1###
         select @iRecno = @iRecno + 1
         /*---------------------------------------------------------------
           Insert no CQ1 - Saldos da Conta
           --------------------------------------------------------------- */
         ##TRATARECNO @iRecno\
         
           Insert into CQ1### ( CQ1_FILIAL, CQ1_CONTA, CQ1_MOEDA, CQ1_DATA, CQ1_TPSALD, CQ1_SLBASE, CQ1_DTLP, CQ1_LP, CQ1_STATUS, CQ1_DEBITO, CQ1_CREDIT, R_E_C_N_O_ )
                        values( @cFilial_CQ1, @cCONTA, @cMOEDA, @cDATA, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
         
         ##FIMTRATARECNO
      end
      /*---------------------------------------------------------------
        Update no CQ1 - Saldos da Conta
        --------------------------------------------------------------- */
      
         Update CQ1###
            set CQ1_DEBITO = CQ1_DEBITO + @nCTX_DEBITO, CQ1_CREDIT  = CQ1_CREDIT + @nCTX_CREDIT
           Where R_E_C_N_O_ = @iRecno
        
 
     /* -----------------------------------------------------------------
    	Verifica se a linha ja existe no CQ0
    ----------------------------------------------------------------- */  
     Exec LASTDAY_## @cDATA, @cDataF OutPut
  
     select @iRecno = 0
     ##UNIQUEKEY_START
     select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
       From CQ0###
      Where CQ0_FILIAL = @cFilial_CQ0
        and CQ0_DATA   = @cDataF
        and CQ0_CONTA  = @cCONTA
        and CQ0_MOEDA  = @cMOEDA
        and CQ0_TPSALD = @cTPSALD
        and CQ0_LP     = @cCTX_LP
        and CQ0_DTLP   = @cCTX_DTLP
        and D_E_L_E_T_ = ' '
     ##UNIQUEKEY_END
     
     If @iRecno = 0 begin
        select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ0###
        select @iRecno = @iRecno + 1
        /*---------------------------------------------------------------
          Insert no CQ0 - Conta Contabil
          --------------------------------------------------------------- */
        ##TRATARECNO @iRecno\
        
          Insert into CQ0### ( CQ0_FILIAL, CQ0_CONTA, CQ0_MOEDA, CQ0_DATA, CQ0_TPSALD, CQ0_SLBASE, CQ0_DTLP, CQ0_LP, CQ0_STATUS, CQ0_DEBITO, CQ0_CREDIT, R_E_C_N_O_ )
                      values( @cFilial_CQ0, @cCONTA, @cMOEDA, @cDataF, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
        
        ##FIMTRATARECNO
     end
     /*---------------------------------------------------------------
       Update no CQ0 - Conta Contabil
       --------------------------------------------------------------- */
     
        Update CQ0###
           set CQ0_DEBITO = CQ0_DEBITO + @nCTX_DEBITO, CQ0_CREDIT  = CQ0_CREDIT + @nCTX_CREDIT
          Where R_E_C_N_O_ = @iRecno
     
      
      /* --------------------------------------------------------------------------------------------------------------
         Tratamento para o DB2
      -------------------------------------------------------------------------------------------------------------- */
      SELECT @fim_CUR = 0
      Fetch CUR_CTB190 into  @cFILCT2, @cCONTA, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO,@cTPSALD

   end
   close CUR_CTB190
   deallocate CUR_CTB190

   /* ---------------------------------------------------------------
      ATUALIZAR CENTRO DE CUSTOS - CQ2/CQ3
   --------------------------------------------------------------- */
   If @IN_LCUSTO = '1' begin
      
      select @iRecno  = 0  
      Declare CUR_CT3 insensitive cursor for
      Select CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '1',CT2_TPSALD
        From CQA### CQA, CT2### CT2 
       Where CQA_FILIAL = @cFilial_CQA
         and CQA.R_E_C_N_O_  between @RecMin and @RecMax 
         and CQA.D_E_L_E_T_ = ' '
		     and CT2_FILIAL = CQA_FILCT2
		     and CT2_DATA   = CQA_DATA
		     and CT2_LOTE   = CQA_LOTE
		     and CT2_SBLOTE = CQA_SBLOTE
		     and CT2_DOC    = CQA_DOC
		     and CT2_LINHA  = CQA_LINHA
		     and CT2_TPSALD = CQA_TPSALD
		     and CT2_EMPORI = CQA_EMPORI
		     and CT2_FILORI = CQA_FILORI
		     and CT2_MOEDLC = CQA_MOEDLC 
         and (CT2_DC = '1' or CT2_DC = '3')
         and CT2_CCD != ' '
         and CT2_DEBITO != ' '
         and CT2.D_E_L_E_T_ = ' '
       Group By CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_MOEDLC, CT2_DATA, CT2_DTLP,CT2_TPSALD
       Union
       Select CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '2',CT2_TPSALD
        From CQA### CQA, CT2### CT2
       Where CQA_FILIAL = @cFilial_CQA 
         and CQA.R_E_C_N_O_  between @RecMin and @RecMax 
          and CQA.D_E_L_E_T_ = ' '
		      and CT2_FILIAL = CQA_FILCT2
		      and CT2_DATA   = CQA_DATA
		      and CT2_LOTE   = CQA_LOTE
		      and CT2_SBLOTE = CQA_SBLOTE
		      and CT2_DOC    = CQA_DOC
		      and CT2_LINHA  = CQA_LINHA
		      and CT2_TPSALD = CQA_TPSALD
		      and CT2_EMPORI = CQA_EMPORI
		      and CT2_FILORI = CQA_FILORI
		      and CT2_MOEDLC = CQA_MOEDLC 
         and (CT2_DC = '2' or CT2_DC = '3')
         and CT2_CCC != ' '
         and CT2_CREDIT != ' '
         and CT2.D_E_L_E_T_ = ' '
      Group By CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_MOEDLC, CT2_DATA, CT2_DTLP,CT2_TPSALD
      order by 1,2,3,4,5,6,9
      
      for read only
      Open CUR_CT3
      Fetch CUR_CT3 into  @cFILCT2, @cCONTA, @cCUSTO, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO,@cTPSALD
      
      While (@@Fetch_status = 0 ) begin
         
         select @cAux = 'CQ2'
         exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ2 OutPut
         select @cAux = 'CQ3'
         exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ3 OutPut
         select @cAux = 'CQ8'
         exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ8 OutPut
         select @cAux = 'CQ9'
         exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ9 OutPut
         
         select @nCTX_DEBITO = 0
         select @nCTX_CREDIT = 0
         select @cCTX_STATUS = '1'
         select @cCTX_SLBASE = 'S'
         select @cCTX_DTLP = ' '
         /*---------------------------------------------------------------
           Ajusta dados para GRAVAÇÃO DE SALDOS DO DIA  CQ3
           --------------------------------------------------------------- */
         if @cTIPO = '1' begin
            select @nCTX_DEBITO = Round(@nVALOR, 2)
            select @nCTX_CREDIT = 0
         end
         if @cTIPO = '2' begin
            select @nCTX_CREDIT = Round(@nVALOR, 2)
            select @nCTX_DEBITO = 0
         end
         
         if @cCT2_DTLP = ' ' begin
            select @cCTX_LP = 'N'
            select @cCTX_DTLP = ' '
         end else begin
            select @cCTX_LP = 'Z'
            select @cCTX_DTLP = @cCT2_DTLP
         end
         /*---------------------------------------------------------------
           Verifica se a linha ja existe no CQ3 - Dia
           --------------------------------------------------------------- */      
         select @iRecno  = 0
         ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ3###
          Where CQ3_FILIAL = @cFilial_CQ3
            and CQ3_DATA   = @cDATA
            and CQ3_CONTA  = @cCONTA
            and CQ3_CCUSTO = @cCUSTO
            and CQ3_MOEDA  = @cMOEDA
            and CQ3_TPSALD = @cTPSALD
            and CQ3_LP     = @cCTX_LP
            and CQ3_DTLP   = @cCTX_DTLP
            and D_E_L_E_T_ = ' '
         ##UNIQUEKEY_END
         
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ3###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ3 - Saldos da Custo mes
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            
              Insert into CQ3### ( CQ3_FILIAL, CQ3_CONTA, CQ3_CCUSTO, CQ3_MOEDA, CQ3_DATA, CQ3_TPSALD, CQ3_SLBASE, CQ3_DTLP, CQ3_LP, CQ3_STATUS, CQ3_DEBITO, CQ3_CREDIT, R_E_C_N_O_ )
                           values( @cFilial_CQ3, @cCONTA, @cCUSTO, @cMOEDA, @cDATA, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            
            ##FIMTRATARECNO         
         end
         /*---------------------------------------------------------------
           Update no CQ3 - Saldos da Custo DIA
           --------------------------------------------------------------- */
         
            Update CQ3###
               set CQ3_DEBITO = CQ3_DEBITO + @nCTX_DEBITO, CQ3_CREDIT = CQ3_CREDIT + @nCTX_CREDIT
              Where R_E_C_N_O_ = @iRecno
         

        /* -----------------------------------------------------------------
        Verifica se a linha ja existe no CQ2  MES
        ----------------------------------------------------------------- */  
         Exec LASTDAY_## @cDATA, @cDataF OutPut
      
         select @iRecno  = 0
         ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ2###
          Where CQ2_FILIAL = @cFilial_CQ2
            and CQ2_DATA   = @cDataF
            and CQ2_CONTA  = @cCONTA
            and CQ2_CCUSTO = @cCUSTO
            and CQ2_MOEDA  = @cMOEDA
            and CQ2_TPSALD = @cTPSALD
            and CQ2_LP     = @cCTX_LP
            and CQ2_DTLP   = @cCTX_DTLP
            and D_E_L_E_T_ = ' '
         ##UNIQUEKEY_END
         
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ2###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ2 - Saldos Centro de Custo
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            
            Insert into CQ2### ( CQ2_FILIAL, CQ2_CONTA, CQ2_CCUSTO, CQ2_MOEDA, CQ2_DATA, CQ2_TPSALD, CQ2_SLBASE, CQ2_DTLP, CQ2_LP, CQ2_STATUS, CQ2_DEBITO, CQ2_CREDIT, R_E_C_N_O_ )
                         values( @cFilial_CQ2, @cCONTA, @cCUSTO, @cMOEDA, @cDataF, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            
            ##FIMTRATARECNO
         end
         /*---------------------------------------------------------------
           Update no CQ2 - Saldos Centro de Custo
           --------------------------------------------------------------- */
         
            Update CQ2###
               set CQ2_DEBITO = CQ2_DEBITO + @nCTX_DEBITO, CQ2_CREDIT = CQ2_CREDIT + @nCTX_CREDIT
              Where R_E_C_N_O_ = @iRecno
         
         
         /* -----------------------------------------------------------------
            Verifica se a linha ja existe no CQ9 (Saldo por entidade ) - DIA
            ----------------------------------------------------------------- */      
         select @iRecno  = 0
         ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ9###
          Where CQ9_FILIAL = @cFilial_CQ9
            and CQ9_DATA   = @cDATA
            and CQ9_IDENT  = 'CTT'
            and CQ9_CODIGO = @cCUSTO
            and CQ9_MOEDA  = @cMOEDA
            and CQ9_TPSALD = @cTPSALD
            and CQ9_LP     = @cCTX_LP
            and CQ9_DTLP   = @cCTX_DTLP
            and D_E_L_E_T_ = ' '
         ##UNIQUEKEY_END

         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ9###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ9 - Saldos poe entidades Dia
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            
              Insert into CQ9### ( CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA, CQ9_TPSALD, CQ9_SLBASE, CQ9_DTLP, CQ9_LP, CQ9_STATUS, CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
                           values( @cFilial_CQ9, 'CTT', @cCUSTO, @cMOEDA, @cDATA, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            
            ##FIMTRATARECNO
         end
         /*---------------------------------------------------------------
           Update no CQ9 - Saldos por entidade DIA
           --------------------------------------------------------------- */
         
            Update CQ9###
               set CQ9_DEBITO = CQ9_DEBITO + @nCTX_DEBITO, CQ9_CREDIT  = CQ9_CREDIT + @nCTX_CREDIT
              Where R_E_C_N_O_ = @iRecno
         
         
         /* -----------------------------------------------------------------
            Verifica se a linha ja existe no CQ8 (Saldo por entidade ) - MES
            ----------------------------------------------------------------- */  
         Exec LASTDAY_## @cDATA, @cDataF OutPut
      
         select @iRecno  = 0
         ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ8###
          Where CQ8_FILIAL = @cFilial_CQ8
            and CQ8_DATA   = @cDataF
            and CQ8_IDENT  = 'CTT'
            and CQ8_CODIGO = @cCUSTO
            and CQ8_MOEDA  = @cMOEDA
            and CQ8_TPSALD = @cTPSALD
            and CQ8_LP     = @cCTX_LP
            and CQ8_DTLP   = @cCTX_DTLP
            and D_E_L_E_T_ = ' '
         ##UNIQUEKEY_END
         
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ8###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ8 - Saldos poR entidade MES
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            
            Insert into CQ8### ( CQ8_FILIAL, CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA, CQ8_TPSALD, CQ8_SLBASE, CQ8_DTLP, CQ8_LP, CQ8_STATUS, CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
                         values( @cFilial_CQ8, 'CTT', @cCUSTO, @cMOEDA, @cDataF, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            
            ##FIMTRATARECNO
         end
         /*---------------------------------------------------------------
           Update no CQ8 - Saldos da Conta
           --------------------------------------------------------------- */
         
            Update CQ8###
               set CQ8_DEBITO = CQ8_DEBITO + @nCTX_DEBITO, CQ8_CREDIT  = CQ8_CREDIT + @nCTX_CREDIT
              Where R_E_C_N_O_ = @iRecno
         
       
         /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
            -------------------------------------------------------------------------------------------------------------- */
         SELECT @fim_CUR = 0         
         Fetch CUR_CT3 into  @cFILCT2, @cCONTA, @cCUSTO, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO,@cTPSALD
         
      end
      close CUR_CT3
      deallocate CUR_CT3
   End
   /* ---------------------------------------------------------------
      ATUALIZAR ITEM CONTABIL - CQ4/CQ5 e/ou CLASSE DE VALOR - CQ6/CQ7
      --------------------------------------------------------------- */
   If @IN_LITEM = '1' OR @IN_LCLVL = '1' begin
      EXEC CTB195_##  @cFilial_CQA, @RecMin,  @RecMax , @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @OUT_RESULTADO Output
   End
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
     --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end
