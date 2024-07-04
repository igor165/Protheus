Create procedure CTB195_## ( 
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
    Procedure       -      Atualizacao de slds Bases CQ4,CQ5,CQ6,CQ7
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
declare @cFilial_CT2 char('CT2_FILIAL')
declare @cFILCT2     char('CT2_FILIAL')
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
Declare @cAnoMes     Char( 06 )
Declare @lPrim       Char( 01 )
declare @RecMin      integer
declare @RecMax      integer
declare @cTPSALD     Char('CT2_TPSALD')
Declare @iTranCount  Integer --Var.de ajuste para SQLServer e Sybase.-- Será trocada por Commit no CFGX051 após passar pelo Parse

begin
   select @OUT_RESULTADO = '0'
   select @RecMin = @IN_RECMIN 
   select @RecMax = @IN_RECMAX
   select @cFilial_CQA = @IN_FILCQA
   /* ---------------------------------------------------------------
      ATUALIZAR ITEM CONTABIL - CQ4/CQ5
      --------------------------------------------------------------- */
   If @IN_LITEM = '1' begin
      
      select @iRecno  = 0

      Declare CUR_CT4 insensitive cursor for
      Select CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '1',CT2_TPSALD
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
         and CT2_ITEMD != ' '
         and CT2_DEBITO != ' '
         and CT2.D_E_L_E_T_ = ' '
       Group By CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_MOEDLC, CT2_DATA, CT2_DTLP,CT2_TPSALD
      Union
      Select CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '2',CT2_TPSALD
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
         AND (CT2_DC = '2' or CT2_DC = '3')
         and CT2_ITEMC != ' '
         and CT2_CREDIT != ' '
         and CT2.D_E_L_E_T_ = ' '
      Group By CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_MOEDLC, CT2_DATA, CT2_DTLP,CT2_TPSALD
      order by 1,2,3,4,5,6,7,10
      for read only
      Open CUR_CT4
      Fetch CUR_CT4 into  @cFILCT2, @cCONTA, @cCUSTO, @cITEM, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO,@cTPSALD
      
      While (@@Fetch_status = 0 ) begin
                 
         select @cAux = 'CQ4'
         exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ4 OutPut
         select @cAux = 'CQ5'
         exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ5 OutPut
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
           Ajusta dados para GRAVAÇÃO DE SALDOS DO DIA  SQ5
           --------------------------------------------------------------- */
         if @cTIPO = '1' begin
            select @nCTX_DEBITO = Round(@nVALOR, 2) -- Já formata o conteúdo da variável neste momento
            select @nCTX_CREDIT = 0
         end
         if @cTIPO = '2' begin
            select @nCTX_CREDIT = Round(@nVALOR, 2) -- Já formata o conteúdo da variável neste momento
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
           Verifica se a linha ja existe no CQ5
           --------------------------------------------------------------- */ 
         select @iRecno  = 0
    		 /* --------------------------------------------------------------------------------------------------------------
    		  As chaves UNIQUEKEY serão utilizadas para que seja possível tratar o erro quando houver violação da chave única
    		  O bloco de código para isso será inserido no parser da Engenharia, logo após a MsParse() devolver o código na
    		  linguagem do banco em uso.
    		 -------------------------------------------------------------------------------------------------------------- */
         ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ5###
          Where CQ5_FILIAL = @cFilial_CQ5
            and CQ5_DATA   = @cDATA
            and CQ5_CONTA  = @cCONTA
            and CQ5_CCUSTO = @cCUSTO
            and CQ5_ITEM   = @cITEM
            and CQ5_MOEDA  = @cMOEDA
            and CQ5_TPSALD = @cTPSALD
            and CQ5_LP     = @cCTX_LP
            and CQ5_DTLP   = @cCTX_DTLP
            and D_E_L_E_T_ = ' '
         ##UNIQUEKEY_END
         
         If @iRecno = 0 begin -- O comando IF foi modificado para não possuir ELSE. De qualquer modo o registro será sempre atualizado.
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ5###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ5 - Saldos da Conta
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            
            Insert into CQ5### ( CQ5_FILIAL, CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM, CQ5_MOEDA, CQ5_DATA, CQ5_TPSALD, CQ5_SLBASE, CQ5_DTLP, CQ5_LP, CQ5_STATUS, CQ5_DEBITO, CQ5_CREDIT, R_E_C_N_O_ )
                         values( @cFilial_CQ5, @cCONTA, @cCUSTO, @cITEM, @cMOEDA, @cDATA, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            
            ##FIMTRATARECNO
         end
         /*---------------------------------------------------------------
           Update no CQ5 - Saldos da Conta
		       --------------------------------------------------------------- */
         
            Update CQ5###
               set CQ5_DEBITO = CQ5_DEBITO + @nCTX_DEBITO, CQ5_CREDIT  = CQ5_CREDIT + @nCTX_CREDIT
             Where R_E_C_N_O_ = @iRecno
         

		     /* -----------------------------------------------------------------
		        Verifica se a linha ja existe no CQ4  MES
		     ----------------------------------------------------------------- */  
         Exec LASTDAY_## @cDATA, @cDataF OutPut
      
         select @iRecno  = 0
         ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ4###
          Where CQ4_FILIAL = @cFilial_CQ4
            and CQ4_DATA   = @cDataF
            and CQ4_CONTA  = @cCONTA
            and CQ4_CCUSTO = @cCUSTO
            and CQ4_ITEM   = @cITEM
            and CQ4_MOEDA  = @cMOEDA
            and CQ4_TPSALD = @cTPSALD
            and CQ4_LP     = @cCTX_LP
            and CQ4_DTLP   = @cCTX_DTLP
            and D_E_L_E_T_ = ' '
         ##UNIQUEKEY_END
         
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ4###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ4 - Saldos Item
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            
             Insert into CQ4### ( CQ4_FILIAL, CQ4_CONTA, CQ4_CCUSTO, CQ4_ITEM, CQ4_MOEDA, CQ4_DATA, CQ4_TPSALD, CQ4_SLBASE, CQ4_DTLP, CQ4_LP, CQ4_STATUS, CQ4_DEBITO, CQ4_CREDIT, R_E_C_N_O_ )
                         values( @cFilial_CQ5, @cCONTA, @cCUSTO, @cITEM, @cMOEDA, @cDataF, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
 
            
            ##FIMTRATARECNO
         end
         /*---------------------------------------------------------------
          Update no CQ4 - Saldos Item
          --------------------------------------------------------------- */
         
            Update CQ4###
               set CQ4_DEBITO = CQ4_DEBITO + @nCTX_DEBITO, CQ4_CREDIT  = CQ4_CREDIT + @nCTX_CREDIT
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
            and CQ9_IDENT  = 'CTD'
            and CQ9_CODIGO = @cITEM
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
                         values( @cFilial_CQ9, 'CTD', @cITEM, @cMOEDA, @cDATA, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            
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
            and CQ8_IDENT  = 'CTD'
            and CQ8_CODIGO = @cITEM
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
              Insert no CQ8 - Saldos poe entidades MESS
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            
            Insert into CQ8### ( CQ8_FILIAL, CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA, CQ8_TPSALD, CQ8_SLBASE, CQ8_DTLP, CQ8_LP, CQ8_STATUS, CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
                         values( @cFilial_CQ8, 'CTD', @cITEM, @cMOEDA, @cDataF, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            
            ##FIMTRATARECNO
         end
         /*---------------------------------------------------------------
           Update no CQ8 - Saldos por entidade MES
           --------------------------------------------------------------- */
         
            Update CQ8###
               set CQ8_DEBITO = CQ8_DEBITO + @nCTX_DEBITO, CQ8_CREDIT  = CQ8_CREDIT + @nCTX_CREDIT
                 Where R_E_C_N_O_ = @iRecno
         
     
         /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
            -------------------------------------------------------------------------------------------------------------- */
         SELECT @fim_CUR = 0
         Fetch CUR_CT4 into  @cFILCT2, @cCONTA, @cCUSTO, @cITEM, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO,@cTPSALD
      end
      close CUR_CT4
      deallocate CUR_CT4
   End
   
   /* ---------------------------------------------------------------
      ATUALIZAR CLASSE DE VALOR - CQ6/CQ7
      --------------------------------------------------------------- */
   If @IN_LCLVL = '1' begin
     
      select @iRecno  = 0
      
      Declare CUR_CTI insensitive cursor for
      Select CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_CLVLDB, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '1',CT2_TPSALD
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
         and CT2_CLVLDB != ' '
         and CT2_DEBITO != ' '
         and CT2.D_E_L_E_T_ = ' '
       Group By CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_CLVLDB, CT2_MOEDLC, CT2_DATA, CT2_DTLP,CT2_TPSALD
      Union
      Select CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_CLVLCR, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '2',CT2_TPSALD
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
         and CT2_CLVLCR != ' '
         and CT2_CREDIT != ' '
         and CT2.D_E_L_E_T_ = ' '
       Group By CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_CLVLCR, CT2_MOEDLC, CT2_DATA, CT2_DTLP,CT2_TPSALD
       order by 1,2,3,4,5,6,7,8,11
      
      for read only
      Open CUR_CTI
      Fetch CUR_CTI into  @cFILCT2, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO,@cTPSALD
      
      While (@@Fetch_status = 0 ) begin
         
         select @cAux = 'CQ6'
         exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ6 OutPut
         select @cAux = 'CQ7'
         exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ7 OutPut
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
           Ajusta dados para GRAVAÇÃO DE SALDOS DO DIA  SQ4
           --------------------------------------------------------------- */
         if @cTIPO = '1' begin
            select @nCTX_DEBITO = Round(@nVALOR, 2) -- Já formata o conteúdo da variável neste momento
            select @nCTX_CREDIT = 0
         end
         if @cTIPO = '2' begin
            select @nCTX_CREDIT = Round(@nVALOR, 2) -- Já formata o conteúdo da variável neste momento
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
           Verifica se a linha ja existe no CQ7
           --------------------------------------------------------------- */ 
         select @iRecno  = 0     
         ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ7###
          Where CQ7_FILIAL = @cFilial_CQ7
            and CQ7_DATA   = @cDATA
            and CQ7_CONTA  = @cCONTA
            and CQ7_CCUSTO = @cCUSTO
            and CQ7_ITEM   = @cITEM
            and CQ7_CLVL   = @cCLVL
            and CQ7_MOEDA  = @cMOEDA
            and CQ7_TPSALD = @cTPSALD
            and CQ7_LP     = @cCTX_LP
            and CQ7_DTLP   = @cCTX_DTLP
            and D_E_L_E_T_ = ' '
         ##UNIQUEKEY_END
         
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ7###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ7 - Saldos da Conta
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            
            Insert into CQ7### ( CQ7_FILIAL, CQ7_CONTA, CQ7_CCUSTO, CQ7_ITEM, CQ7_CLVL, CQ7_MOEDA, CQ7_DATA, CQ7_TPSALD, CQ7_SLBASE, CQ7_DTLP, CQ7_LP, CQ7_STATUS, CQ7_DEBITO, CQ7_CREDIT, R_E_C_N_O_ )
                         values( @cFilial_CQ7, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cMOEDA, @cDATA, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            
            ##FIMTRATARECNO
         end
         /*---------------------------------------------------------------
           Update no CQ7 - Saldos da Conta
           --------------------------------------------------------------- */
         
            Update CQ7###
               set CQ7_DEBITO = CQ7_DEBITO + @nCTX_DEBITO, CQ7_CREDIT  = CQ7_CREDIT + @nCTX_CREDIT
             Where R_E_C_N_O_ = @iRecno
         
         
         /*-----------------------------------------------------------------
		       Verifica se a linha ja existe no CQ6  MES
          ----------------------------------------------------------------- */  
         Exec LASTDAY_## @cDATA, @cDataF OutPut
      
         select @iRecno  = 0
         ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ6###
          Where CQ6_FILIAL = @cFilial_CQ6
            and CQ6_DATA   = @cDataF
            and CQ6_CONTA  = @cCONTA
            and CQ6_CCUSTO = @cCUSTO
            and CQ6_ITEM   = @cITEM
            and CQ6_CLVL   = @cCLVL
            and CQ6_MOEDA  = @cMOEDA
            and CQ6_TPSALD = @cTPSALD
            and CQ6_LP     = @cCTX_LP
            and CQ6_DTLP   = @cCTX_DTLP
            and D_E_L_E_T_ = ' '
         ##UNIQUEKEY_END
         
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ6###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ6 - Classe de Valor
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            
     	      Insert into CQ6### ( CQ6_FILIAL, CQ6_CONTA, CQ6_CCUSTO, CQ6_ITEM, CQ6_CLVL, CQ6_MOEDA, CQ6_DATA, CQ6_TPSALD, CQ6_SLBASE, CQ6_DTLP, CQ6_LP, CQ6_STATUS, CQ6_DEBITO, CQ6_CREDIT, R_E_C_N_O_ )
                         values( @cFilial_CQ7, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cMOEDA, @cDataF, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno ) 
            
            ##FIMTRATARECNO
         end
         /*---------------------------------------------------------------
           Insert no CQ6 - Classe de Valor
           --------------------------------------------------------------- */
         
            Update CQ6###
               set CQ6_DEBITO = CQ6_DEBITO + @nCTX_DEBITO, CQ6_CREDIT  = CQ6_CREDIT + @nCTX_CREDIT
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
            and CQ9_IDENT  = 'CTH'
            and CQ9_CODIGO = @cCLVL
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
                         values( @cFilial_CQ9, 'CTH', @cCLVL, @cMOEDA, @cDATA, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            
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
            and CQ8_IDENT  = 'CTH'
            and CQ8_CODIGO = @cCLVL
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
              Insert no CQ8 - Saldos dpoe entidade MES
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            
            Insert into CQ8### ( CQ8_FILIAL, CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA, CQ8_TPSALD, CQ8_SLBASE, CQ8_DTLP, CQ8_LP, CQ8_STATUS, CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
                         values( @cFilial_CQ8, 'CTH', @cCLVL, @cMOEDA, @cDataF, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            
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
         Fetch CUR_CTI into  @cFILCT2, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO,@cTPSALD
         
      end
      close CUR_CTI
      deallocate CUR_CTI
   End
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
   --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end
