Create procedure CTB167_##
( 
   @IN_FILIAL       Char( 'CQ0_FILIAL' ),
   @IN_LCUSTO       Char( 01 ),
   @IN_LITEM        Char( 01 ),
   @IN_LCLVL        Char( 01 ),
   @IN_DATADE       Char( 08 ),
   @IN_DATAATE      Char( 08 ),
   @IN_LMOEDAESP    Char( 01 ),
   @IN_MOEDA        Char( 'CQ0_MOEDA' ),
   @IN_TPSALDO      Char( 'CT2_TPSALD' ),
   @IN_CONTA        Char( 'CT1_CONTA' ),
   @IN_INTEGRIDADE  Char( 01 ),
   @IN_MVCTB190D    Char( 01 ),
   @IN_EMPANT       Char(02),
   @OUT_RESULTADO   Char( 01 ) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  000 </a>
    Fonte Microsiga - <s>  CTBA192.PRW </s>
    Descricao       - <d>  Reprocessamento SigaCTB </d>
    Procedure       -      Atualizacao de slds Bases - CQ0, CQ1, CQ2, CQ3, CQ7
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL       - Filial do Processo
                           @IN_LCUSTO       - Centro de Custo em uso
                           @IN_LITEM        - Item em uso
                           @IN_LCLVL        - Classe de Valor em uso
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_CONTA        - CONTA
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada.  
                           @IN_MVCTB190D    - '1' exclui fisicamente, '0' marca como deletado
                           @IN_EMPANT       - Grupo de Emp atual
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     13/06/07
    Obs: a variável @iTranCount = 0 será trocada por 'commit tran' no CFGX051 pro SQLSERVER 
         e SYBASE
   -------------------------------------------------------------------------------------- */
declare @cFilial_CT2 char( 'CT2_FILIAL' )
declare @cFilial_CQ0 char( 'CQ0_FILIAL' )
declare @cFilial_CQ1 char( 'CQ1_FILIAL' )
declare @cFilial_CQ2 char( 'CQ2_FILIAL' )
declare @cFilial_CQ3 char( 'CQ3_FILIAL' )
declare @cFilial_CQ4 char( 'CQ4_FILIAL' )
declare @cFilial_CQ5 char( 'CQ5_FILIAL' )
declare @cFilial_CQ6 char( 'CQ6_FILIAL' )
declare @cFilial_CQ7 char( 'CQ7_FILIAL' )
declare @cFILCT2     char( 'CT2_FILIAL' )
declare @cAux        char( 03 )
declare @nDebMes     Float
declare @nCrdMes     Float
declare @cTabela     Char( 03 )
declare @iRecno      Integer
declare @nCTX_DEBITO Float
declare @nCTX_CREDIT Float
declare @cCTX_DTLP   Char( 08 )
declare @cCTX_LP     Char( 'CQ0_LP' )
declare @cCTX_STATUS Char( 'CQ0_STATUS' )
declare @cCTX_SLBASE Char( 'CQ0_SLBASE' )
declare @cCT2_DTLP   Char( 08 )
declare @cTIPO       Char( 01 )
declare @cTipoAnt    Char( 01 )
declare @cDATA       Char( 08 )
declare @cCONTA      Char( 'CQ0_CONTA' )
declare @cCUSTO      Char( 'CQ2_CCUSTO' )
declare @cITEM       Char( 'CQ4_ITEM' )
declare @cCLVL       Char( 'CQ6_CLVL' )
declare @cMOEDA      Char( 'CQ0_MOEDA' )
declare @nVALOR      Float
declare @cIdent      VarChar( 03 )
Declare @cFilAnt     Char( 'CQ0_FILIAL' )
Declare @cContaAnt   Char( 'CQ0_CONTA' )
Declare @cCustoAnt   Char( 'CQ2_CCUSTO' )
Declare @cItemAnt    Char( 'CQ4_ITEM' )
Declare @cClvlAnt    Char( 'CQ6_CLVL' )
Declare @cMoedaAnt   Char( 'CQ0_MOEDA' )
declare @cDataI      Char( 08 )
declare @cDataF      Char( 08 )
declare @cDataAnt    Char( 08 )
declare @cDtLpAnt    Char( 08 )
Declare @cAnoMes     Char( 06 )
Declare @lPrim       Char( 01 )
Declare @lPrimDel    Char( 01 )
Declare @lExec       Char(01)
Declare @iTranCount  Integer --Var.de ajuste para SQLServer e Sybase.

begin
   
   select @OUT_RESULTADO = '0'
   select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
   Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut   
   
   Select @cFilAnt = ' '
   Select @cContaAnt = ' '
   Select @cMoedaAnt = ' '
   Select @cDataAnt  = ' '
   Select @cDtLpAnt  = ' '
   Select @cTipoAnt  = ' '
   select @cAnoMes   = ' '
   select @nDebMes = 0
   select @nCrdMes = 0
   select @lPrim = '1'
   select @lPrimDel = '1'
   
   select @cAux = 'CT2'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT2 OutPut
   
   Declare CUR_CTB190 insensitive cursor for
      Select CT2_FILIAL, CT2_DEBITO, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '1'
        From CT2###
       Where CT2_FILIAL = @cFilial_CT2
         and (CT2_DC = '1' or CT2_DC = '3')
         and CT2_TPSALD = @IN_TPSALDO
         and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
         and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
         and  CT2_DEBITO = @IN_CONTA
         and D_E_L_E_T_= ' '
       Group By CT2_FILIAL, CT2_DEBITO, CT2_MOEDLC, CT2_DATA, CT2_DTLP
       Union
      Select CT2_FILIAL, CT2_CREDIT, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '2'
        From CT2###
       Where CT2_FILIAL = @cFilial_CT2
         and (CT2_DC = '2' or CT2_DC = '3')
         and CT2_TPSALD = @IN_TPSALDO
         and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
         and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
         and CT2_CREDIT = @IN_CONTA
         and D_E_L_E_T_ = ' '
      Group By CT2_FILIAL, CT2_CREDIT, CT2_MOEDLC, CT2_DATA, CT2_DTLP
      order by 1, 2, 3, 4, 5
   for read only
   Open CUR_CTB190
   Fetch CUR_CTB190 into  @cFILCT2, @cCONTA, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
   
   While (@@Fetch_status = 0 ) begin         
      /*---------------------------------------------------------------
        Qdo muda a chave inicilalizo as variaveis pa atualuzar o MES
        --------------------------------------------------------------- */
      If @lPrim = '1' begin
         Select @cFilAnt   = @cFILCT2
         Select @cContaAnt = @cCONTA
         Select @cMoedaAnt = @cMOEDA
         Select @cDataAnt  = @cDATA
         Select @cDtLpAnt  = @cCT2_DTLP
         select @cAnoMes   = SUBSTRING( @cDATA, 1, 6 )
         select @cTipoAnt  = @cTIPO
         If @cTIPO = '1' begin
            select @nDebMes = @nDebMes + @nVALOR
         end
         If @cTIPO = '2' begin
            select @nCrdMes = @nCrdMes + @nVALOR
         end
         select @lPrim = '0'
      End
      select @cAux = 'CQ0'
      exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ0 OutPut
      select @cAux = 'CQ1'
      exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ1 OutPut
      Exec LASTDAY_## @cDATA, @cDataF OutPut
      
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
         and CQ1_TPSALD = @IN_TPSALDO
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
         Begin Tran
         Insert into CQ1### ( CQ1_FILIAL,   CQ1_CONTA, CQ1_MOEDA, CQ1_DATA, CQ1_TPSALD,  CQ1_SLBASE,   CQ1_DTLP,   CQ1_LP, CQ1_STATUS,   CQ1_DEBITO,   CQ1_CREDIT,   R_E_C_N_O_ )
						values( @cFilial_CQ1, @cCONTA,   @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
         Commit Tran
         ##FIMTRATARECNO
	    end
         /*---------------------------------------------------------------
           Update no CQ1 - Saldos da Conta
           --------------------------------------------------------------- */
         Begin Tran
         If @cTIPO = '1' begin
            Update CQ1###
                set CQ1_DEBITO = CQ1_DEBITO + @nCTX_DEBITO
              Where R_E_C_N_O_ = @iRecno
         End
         If @cTIPO = '2' begin
            Update CQ1###
              set CQ1_CREDIT  = CQ1_CREDIT + @nCTX_CREDIT
              Where R_E_C_N_O_ = @iRecno
         End
         Commit tran
      /* ---------------------------------------------------------------
        CT190FLGLP - ATUALIZA FLAG DE LP Contas DIA
        --------------------------------------------------------------- */
      if @cCT2_DTLP != ' ' begin
         select @cCUSTO = ' '
         select @cITEM  = ' '
         select @cCLVL  = ' '
         select @cTabela = 'CQ0'
         select @cIdent  = ' '
         Exec CTB025_##  @cFilial_CQ0, @cTabela, @cIdent, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cCT2_DTLP, @cMOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILIAL, @OUT_RESULTADO OutPut
      end
      /*---------------------------------------------------------------
         Atualiza Valor Mes de Contas - CQ0
        --------------------------------------------------------------- */      
      Select @cFilAnt   = @cFILCT2
      Select @cContaAnt = @cCONTA
      Select @cMoedaAnt = @cMOEDA
      select @cDataAnt  = @cDATA
      Select @cDtLpAnt  = @cCT2_DTLP
      select @cAnoMes   = SUBSTRING( @cDATA, 1, 6 )
      select @cTipoAnt = @cTIPO
      
      /* --------------------------------------------------------------------------------------------------------------
         Tratamento para o DB2
      -------------------------------------------------------------------------------------------------------------- */
      SELECT @fim_CUR = 0
      Fetch CUR_CTB190 into  @cFILCT2, @cCONTA, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
      /* --------------------------------------------------------------------------------------------------------------
         Ajuste necessario devido a falha do CURSOR apos o termino do mesmo, ou seja,
         apos o termino a variavel do cursor mantem o seu conteudo.
         -------------------------------------------------------------------------------------------------------------- */
      if @@fetch_status = -1 select @cCONTA = ' '
      /*-----------------------------------------------------------------
         Verifica se a chave anterior é igual para aculumar o valor MES
         ATUALIZA SALDOS MES qdo necessario
        ----------------------------------------------------------------- */
      If @cFilAnt = @cFILCT2 and @cContaAnt = @cCONTA and @cMoedaAnt = @cMOEDA and @cAnoMes = SUBSTRING( @cDATA, 1, 6 ) and @cDtLpAnt = @cCT2_DTLP and @cTipoAnt = @cTIPO begin
         If @cTIPO = '1' begin
            select @nDebMes = @nDebMes + @nVALOR
         end
         If @cTIPO = '2' begin
            select @nCrdMes = @nCrdMes + @nVALOR
         end
      end else begin
         if @cDtLpAnt = ' ' begin
            select @cCTX_LP = 'N'
            select @cCTX_DTLP = ' '
         end else begin
            select @cCTX_LP = 'Z'
            select @cCTX_DTLP = @cDtLpAnt
         end
         
         Exec LASTDAY_## @cDataAnt, @cDataF OutPut
         
         select @nDebMes  =  Round(@nDebMes, 2)
         select @nCrdMes  =  Round(@nCrdMes, 2)
         /*---------------------------------------------------------------
            INSERT ou UPDATE no VALOR MES de Contas - CQ0
           --------------------------------------------------------------- */      
         select @iRecno = 0
		    ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ0###
          Where CQ0_FILIAL = @cFilial_CQ0
            and CQ0_CONTA  = @cContaAnt
            and CQ0_MOEDA  = @cMoedaAnt
            and CQ0_DATA   = @cDataF
            and CQ0_TPSALD = @IN_TPSALDO
            and CQ0_LP     = @cCTX_LP
            and CQ0_DTLP   = @cCTX_DTLP
            and D_E_L_E_T_ = ' '
		    ##UNIQUEKEY_END
            
         If @iRecno = 0 begin
                /*---------------------------------------------------------------
                   Insert no CQ0 - Saldos Mes da Conta
                  --------------------------------------------------------------- */
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ0###
            select @iRecno = @iRecno + 1
				
            ##TRATARECNO @iRecno\
            Begin Tran
            Insert into CQ0### ( CQ0_FILIAL,   CQ0_CONTA,  CQ0_MOEDA,  CQ0_DATA, CQ0_TPSALD,  CQ0_SLBASE,   CQ0_DTLP,  CQ0_LP, CQ0_STATUS,   CQ0_DEBITO, CQ0_CREDIT, R_E_C_N_O_ )
							    values( @cFilAnt,    @cContaAnt,  @cMoedaAnt, @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0,   0,   @iRecno )
            commit tran
            ##FIMTRATARECNO
		    end
            /*---------------------------------------------------------------
              Update no CQ0 - Saldos MES
              --------------------------------------------------------------- */
            Begin Tran
            If @cTipoAnt = '1' begin
               Update CQ0###
                  set CQ0_DEBITO = CQ0_DEBITO + @nDebMes
                 Where R_E_C_N_O_ = @iRecno
            End
            If @cTipoAnt = '2' begin
               Update CQ0###
                  set CQ0_CREDIT  = CQ0_CREDIT + @nCrdMes
                 Where R_E_C_N_O_ = @iRecno
            End
            commit tran
         /* ---------------------------------------------------------------
            Zero variaveis que atualizam o  Valor Mes de Contas - CQ0
            --------------------------------------------------------------- */               
         select @nDebMes = 0
         select @nCrdMes = 0select @lPrim   = '1'
         /* ---------------------------------------------------------------
           CT190FLGLP - ATUALIZA FLAG DE LP Contas MES
           --------------------------------------------------------------- */
         if @cCTX_DTLP != ' ' begin
            select @cCUSTO = ' '
            select @cITEM  = ' '
            select @cCLVL  = ' '
            select @cTabela = 'CQ1'
            select @cIdent  = ' '
            Exec CTB025_##  @cFilial_CQ1, @cTabela, @cIdent, @cContaAnt, @cCUSTO, @cITEM, @cCLVL,  @cCTX_DTLP, @cMoedaAnt, @IN_TPSALDO, @IN_EMPANT, @IN_FILIAL, @OUT_RESULTADO OutPut
         end
      end
   end
   close CUR_CTB190
   deallocate CUR_CTB190
   /* ---------------------------------------------------------------
      ATUALIZAR CENTRO DE CUSTOS - CQ2/CQ3
      --------------------------------------------------------------- */      
   If @IN_LCUSTO = '1' begin
      
      select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
      Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
      
      Select @cFilAnt = ' '
      Select @cContaAnt = ' '
      Select @cCustoAnt = ' '
      Select @cMoedaAnt = ' '
      Select @cDataAnt  = ' '
      Select @cDtLpAnt  = ' '
      select @cTipoAnt  = ' '
      select @cAnoMes   = ' '
      select @nDebMes = 0
      select @nCrdMes = 0
      select @lPrim   = '1'
      select @lPrimDel= '1'
      
      Declare CUR_CT3 insensitive cursor for
      Select CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '1'
        From CT2###
       Where CT2_FILIAL = @cFilial_CT2
         and (CT2_DC = '1' or CT2_DC = '3')
         and CT2_CCD != ' '
         and CT2_TPSALD = @IN_TPSALDO
         and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
         and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
         and CT2_DEBITO = @IN_CONTA
         and D_E_L_E_T_= ' '
       Group By CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_MOEDLC, CT2_DATA, CT2_DTLP
       Union
       Select CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '2'
        From CT2###
        Where CT2_FILIAL = @cFilial_CT2
          and (CT2_DC = '2' or CT2_DC = '3')
          and CT2_CCC != ' '
          and CT2_TPSALD = @IN_TPSALDO
          and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
          and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
          and CT2_CREDIT = @IN_CONTA
          and D_E_L_E_T_ = ' '
      Group By CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_MOEDLC, CT2_DATA, CT2_DTLP
      order by 1,2,3,4,5,6
      
      for read only
      Open CUR_CT3
      Fetch CUR_CT3 into  @cFILCT2, @cCONTA, @cCUSTO, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
      
      While (@@Fetch_status = 0 ) begin 
        
         select @cAux = 'CQ2'
         exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ2 OutPut
         select @cAux = 'CQ3'
         exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ3 OutPut
         Exec LASTDAY_## @cDATA, @cDataF OutPut   
         /*---------------------------------------------------------------
           Na primeira passagem alimenta as variaveis 
           --------------------------------------------------------------- */
         If @lPrim = '1' begin
            Select @cFilAnt   = @cFILCT2
            Select @cContaAnt = @cCONTA
            Select @cCustoAnt = @cCUSTO
            Select @cMoedaAnt = @cMOEDA
            Select @cDataAnt  = @cDATA
            Select @cDtLpAnt  = @cCT2_DTLP            
            select @cAnoMes   = SUBSTRING( @cDATA, 1, 6 )
            select @cTipoAnt  = @cTIPO
            
            If @cTIPO = '1' begin
               select @nDebMes = @nDebMes + @nVALOR
            end
            If @cTIPO = '2' begin
               select @nCrdMes = @nCrdMes + @nVALOR
            end
            select @lPrim = '0'
         End
         
         select @nCTX_DEBITO = 0
         select @nCTX_CREDIT = 0
         select @cCTX_STATUS = '1'
         select @cCTX_SLBASE = 'S'
         select @cCTX_DTLP = ' '
         /*---------------------------------------------------------------
           Ajusta dados para GRAVAÇÃO DE SALDOS DO DIA  SQ3
           --------------------------------------------------------------- */
         if @cTIPO = '1' begin
                select @nCTX_DEBITO = Round(@nVALOR,2)
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
         select @iRecno = 0
            ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ3###
          Where CQ3_FILIAL = @cFilial_CQ3
            and CQ3_DATA   = @cDATA
            and CQ3_CONTA  = @cCONTA
            and CQ3_CCUSTO = @cCUSTO
            and CQ3_MOEDA  = @cMOEDA
            and CQ3_TPSALD = @IN_TPSALDO
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
            Begin Tran
            Insert into CQ3### ( CQ3_FILIAL,   CQ3_CONTA,    CQ3_CCUSTO, CQ3_MOEDA, CQ3_DATA, CQ3_TPSALD,  CQ3_SLBASE,   CQ3_DTLP,   CQ3_LP, CQ3_STATUS,   CQ3_DEBITO,   CQ3_CREDIT,   R_E_C_N_O_ )
					         values( @cFilial_CQ3, @cCONTA,      @cCUSTO,  @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            commit tran
            ##FIMTRATARECNO         

		    end
            /*---------------------------------------------------------------
              Update no CQ3 - Saldos da Custo DIA
              --------------------------------------------------------------- */
            Begin Tran
            If @cTIPO = '1' begin
               Update CQ3###
                   set CQ3_DEBITO = CQ3_DEBITO + @nCTX_DEBITO
                 Where R_E_C_N_O_ = @iRecno
            End
            If @cTIPO = '2' begin
               Update CQ3###
                   set CQ3_CREDIT  = CQ3_CREDIT + @nCTX_CREDIT
                 Where R_E_C_N_O_ = @iRecno
            End
            commit tran
         /* ---------------------------------------------------------------
           CT190FLGLP - ATUALIZA FLAG DE LP custos Dia
           --------------------------------------------------------------- */
         if @cCT2_DTLP != ' ' begin
            select @cITEM  = ' '
            select @cCLVL  = ' '
            select @cIdent  = ' '
            select @cTabela = 'CQ3'
            Exec CTB025_##  @cFilial_CQ3, @cTabela, @cIdent, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cCT2_DTLP, @cMOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILIAL, @OUT_RESULTADO OutPut
            
         end
         /*---------------------------------------------------------------
            Atualiza Variaveis Mes
           --------------------------------------------------------------- */      
         Select @cFilAnt   = @cFILCT2
         Select @cContaAnt = @cCONTA
         Select @cCustoAnt = @cCUSTO
         Select @cMoedaAnt = @cMOEDA
         Select @cDataAnt  = @cDATA
         Select @cDtLpAnt  = @cCT2_DTLP
         select @cAnoMes   = SUBSTRING( @cDATA, 1, 6 )
         select @cTipoAnt  = @cTIPO
         /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
            -------------------------------------------------------------------------------------------------------------- */
         SELECT @fim_CUR = 0         
         Fetch CUR_CT3 into  @cFILCT2, @cCONTA, @cCUSTO, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
         /* --------------------------------------------------------------------------------------------------------------
            Ajuste necessario devido a falha do CURSOR apos o termino do mesmo, ou seja,
            apos o termino a variavel do cursor mantem o seu conteudo.
            -------------------------------------------------------------------------------------------------------------- */
         if @@fetch_status = -1 select @cCONTA = ' '
            /* -----------------------------------------------------------------
            Verifica se a chave anterior é igual para aculumar o valor MES
            ATUALIZA SALDOS MES qdo necessario
           ----------------------------------------------------------------- */
         If @cFilAnt = @cFILCT2 and @cContaAnt = @cCONTA and @cCustoAnt = @cCUSTO and @cMoedaAnt = @cMOEDA and @cAnoMes = SUBSTRING( @cDATA, 1, 6 )  and @cDtLpAnt = @cCT2_DTLP  and @cTipoAnt = @cTIPO begin
            If @cTIPO = '1' begin
               select @nDebMes = @nDebMes + @nVALOR
            end
            If @cTIPO = '2' begin
               select @nCrdMes = @nCrdMes + @nVALOR
            end
         end else begin
            /*---------------------------------------------------------------
               Verifico se a DT Apur está preenchida
              --------------------------------------------------------------- */         
            if @cDtLpAnt = ' ' begin
               select @cCTX_LP = 'N'
               select @cCTX_DTLP = ' '
            end else begin
               select @cCTX_LP = 'Z'
               select @cCTX_DTLP = @cDtLpAnt
            end
            
            Exec LASTDAY_## @cDataAnt, @cDataF OutPut
            
            select @nDebMes  =  Round(@nDebMes, 2)
            select @nCrdMes  =  Round(@nCrdMes, 2)
            /*---------------------------------------------------------------
               INSERT ou UPDATE no VALOR MES de Custos - CQ2
              --------------------------------------------------------------- */
            select @iRecno = 0
			    ##UNIQUEKEY_START 
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ2###
             Where CQ2_FILIAL = @cFilial_CQ2
               and CQ2_DATA   = @cDataF
               and CQ2_CONTA  = @cContaAnt
               and CQ2_CCUSTO = @cCustoAnt
               and CQ2_MOEDA  = @cMoedaAnt
               and CQ2_TPSALD = @IN_TPSALDO
               and CQ2_LP     = @cCTX_LP
               and CQ2_DTLP   = @cCTX_DTLP
               and D_E_L_E_T_ = ' '
                ##UNIQUEKEY_END
            /*---------------------------------------------------------------
               Insert ou Update no Valor Mes da Custo - CQ2
              --------------------------------------------------------------- */         
            If @iRecno = 0 begin
               select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ2###
               select @iRecno = @iRecno + 1
               /*---------------------------------------------------------------
                 Insert no CQ2 - Saldos Mes da Custo
                 --------------------------------------------------------------- */
               ##TRATARECNO @iRecno\
               Begin Tran
               Insert into CQ2### ( CQ2_FILIAL,   CQ2_CONTA,  CQ2_CCUSTO, CQ2_MOEDA,  CQ2_DATA, CQ2_TPSALD,  CQ2_SLBASE,   CQ2_DTLP,   CQ2_LP,CQ2_STATUS,   CQ2_DEBITO, CQ2_CREDIT, R_E_C_N_O_ )
			                    values( @cFilial_CQ2, @cContaAnt, @cCustoAnt, @cMoedaAnt, @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0,   0,   @iRecno )
               commit tran
               ##FIMTRATARECNO
                end
               /*---------------------------------------------------------------
                 Update no CQ2 - Saldos MES
                 --------------------------------------------------------------- */
               Begin Tran
               If @cTipoAnt = '1' begin
                  Update CQ2###
                     set CQ2_DEBITO = CQ2_DEBITO + @nDebMes
                    Where R_E_C_N_O_ = @iRecno
               End
               If @cTipoAnt = '2' begin
                  Update CQ2###
                     set CQ2_CREDIT  = CQ2_CREDIT + @nCrdMes
                    Where R_E_C_N_O_ = @iRecno
               End
               commit tran
            /* ---------------------------------------------------------------
               Zero variaveis que atualizam o  Valor Mes de Custos - CQ2
               --------------------------------------------------------------- */               
            select @nDebMes = 0
            select @nCrdMes = 0
            select @lPrim   = '1'
            /* ---------------------------------------------------------------
              CT190FLGLP - ATUALIZA FLAG DE LP custos/Entidades- MES
              --------------------------------------------------------------- */
            if @cCTX_DTLP != ' ' begin
               select @cITEM  = ' '
               select @cCLVL  = ' '
               select @cIdent  = ' '
               select @cTabela = 'CQ2'
               Exec CTB025_##  @cFilial_CQ2, @cTabela, @cIdent, @cContaAnt, @cCustoAnt, @cITEM, @cCLVL, @cCTX_DTLP, @cMoedaAnt, @IN_TPSALDO, @IN_EMPANT, @IN_FILIAL, @OUT_RESULTADO OutPut
            end
         end
      end
      close CUR_CT3
      deallocate CUR_CT3
   End
   /* ---------------------------------------------------------------
      ATUALIZAR ITEM CONTABIL - CQ4/CQ5 e/ou CLASSE DE VALOR - CQ6/CQ7
      --------------------------------------------------------------- */
   If @IN_LITEM = '1' OR @IN_LCLVL = '1' begin
      EXEC CTB231_## @IN_FILIAL,  @IN_LITEM, @IN_LCLVL, @IN_DATADE, @IN_DATAATE,  @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_CONTA, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_EMPANT, @OUT_RESULTADO Output
   End
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
   --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end
