Create procedure CTB231_##
( 
   @IN_FILIAL       Char( 'CQ0_FILIAL' ),
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
    Procedure       -      Atualizacao de slds Bases - CQ4, CQ5, CQ6, CQ7, CQ7,  CTC
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL       - Filial do Processo
                           @IN_LITEM        - Item em uso
                           @IN_LCLVL        - Classe de Valor em uso
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_CONTA        - CONTA     
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada.  
                           @IN_EMPANT       - Grupo de Emp atual
                           @IN_MVCTB190D    - '1' exclui fisicamente, '0' marca como deletado</ri>
                           </ri>
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     13/06/07
    Obs: a variável @iTranCount = 0 será trocada por 'commit tran' no CFGX051 pro SQLSERVER 
         e SYBASE
   -------------------------------------------------------------------------------------- */
declare @cFilial_CT2 char( 'CT2_FILIAL' )
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
declare @iMaxRec     Integer
declare @iMinRec     Integer
declare @nCTX_DEBITO Float
declare @nCTX_CREDIT Float
declare @cCTX_DTLP   Char( 08 )
declare @cCTX_LP     Char( 'CQ0_LP' )
declare @cCTX_STATUS Char( 'CQ0_STATUS' )
declare @cCTX_SLBASE Char( 'CQ0_SLBASE' )
declare @cCT2_DTLP   Char( 08 )
declare @cTIPO       Char( 01 )
declare @cDATA       Char( 08 )
declare @cCONTA      Char( 'CQ0_CONTA' )
declare @cCUSTO      Char( 'CQ2_CCUSTO' )
declare @cITEM       Char( 'CQ4_ITEM' )
declare @cCLVL       Char( 'CQ6_CLVL' )
declare @cMOEDA      Char( 'CQ0_MOEDA' )
declare @nVALOR      Float
declare @cIdent      VarChar(03)
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
Declare @lExec       Char(01)
Declare @iTranCount  Integer --Var.de ajuste para SQLServer e Sybase.

begin
   select @cAux = 'CT2'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT2 OutPut
   
   /* ---------------------------------------------------------------
      ATUALIZAR ITEM CONTABIL - CQ4/CQ5
      --------------------------------------------------------------- */
   If @IN_LITEM = '1' begin
      select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
      Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
      
      Select @cFilAnt   = ' '
      Select @cContaAnt = ' '
      Select @cCustoAnt = ' '
      Select @cItemAnt  = ' '
      Select @cMoedaAnt = ' '
      Select @cDataAnt  = ' '
      Select @cDtLpAnt  = ' '
      select @cAnoMes   = ' '
      select @nDebMes = 0
      select @nCrdMes = 0
      select @lPrim  = '1'
      
      Declare CUR_CT4 insensitive cursor for
      Select CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '1'
        From CT2###
       Where CT2_FILIAL = @cFilial_CT2
         and (CT2_DC = '1' or CT2_DC = '3')
         and CT2_ITEMD != ' '
         and CT2_TPSALD = @IN_TPSALDO
         and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
         and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
         and CT2_DEBITO = @IN_CONTA
         and D_E_L_E_T_= ' '
       Group By CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_MOEDLC, CT2_DATA, CT2_DTLP
      Union
      Select CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '2'
        From CT2###
       Where CT2_FILIAL = @cFilial_CT2
         and (CT2_DC = '2' or CT2_DC = '3')
         and CT2_ITEMC != ' '
         and CT2_TPSALD = @IN_TPSALDO
         and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
         and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
         and CT2_CREDIT = @IN_CONTA
         and D_E_L_E_T_ = ' '
      Group By CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_MOEDLC, CT2_DATA, CT2_DTLP
      order by 1,2,3,4,5,6,7
      
      for read only
      Open CUR_CT4
      Fetch CUR_CT4 into  @cFILCT2, @cCONTA, @cCUSTO, @cITEM, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
      
      While (@@Fetch_status = 0 ) begin
         
         select @cAux = 'CQ4'
         exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ4 OutPut
         select @cAux = 'CQ5'
         exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ5 OutPut
         Exec LASTDAY_## @cDATA, @cDataF OutPut
         /*---------------------------------------------------------------
           Na primeira passagem alimenta as variaveis 
           --------------------------------------------------------------- */
         If @lPrim = '1' begin
            Select @cFilAnt   = @cFILCT2
            Select @cContaAnt = @cCONTA
            Select @cCustoAnt = @cCUSTO
            Select @cItemAnt  = @cITEM
            Select @cMoedaAnt = @cMOEDA
            Select @cDataAnt  = @cDATA
            Select @cDtLpAnt  = @cCT2_DTLP
            select @cAnoMes   = SUBSTRING( @cDATA, 1, 6 )
            
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
           Ajusta dados para GRAVAÇÃO DE SALDOS DO DIA  SQ5
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
           Verifica se a linha ja existe no CQ5
           --------------------------------------------------------------- */      
         select @iRecno = 0
            ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ5###
          Where CQ5_FILIAL = @cFilial_CQ5
            and CQ5_DATA   = @cDATA
            and CQ5_CONTA  = @cCONTA
            and CQ5_CCUSTO = @cCUSTO
            and CQ5_ITEM   = @cITEM
            and CQ5_MOEDA  = @cMOEDA
            and CQ5_TPSALD = @IN_TPSALDO
            and CQ5_LP     = @cCTX_LP
            and CQ5_DTLP   = @cCTX_DTLP
            and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
         
         
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ5###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ5 - Saldos da Conta
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            Begin Tran
            Insert into CQ5### ( CQ5_FILIAL,   CQ5_CONTA,CQ5_CCUSTO, CQ5_ITEM, CQ5_MOEDA, CQ5_DATA, CQ5_TPSALD,  CQ5_SLBASE,   CQ5_DTLP,   CQ5_LP, CQ5_STATUS,   CQ5_DEBITO,   CQ5_CREDIT, R_E_C_N_O_ )
							    values( @cFilial_CQ5, @cCONTA,  @cCUSTO,    @cITEM,   @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            Commit Tran
            ##FIMTRATARECNO
		    end
            /*---------------------------------------------------------------
              Update no CQ5 - Saldos da Conta
              --------------------------------------------------------------- */
            Begin Tran
            If @cTIPO = '1' begin
               Update CQ5###
                   set CQ5_DEBITO = CQ5_DEBITO + @nCTX_DEBITO
                 Where R_E_C_N_O_ = @iRecno
            End
            If @cTIPO = '2' begin
               Update CQ5###
                   set CQ5_CREDIT  = CQ5_CREDIT + @nCTX_CREDIT
                 Where R_E_C_N_O_ = @iRecno
            End
            commit tran
         /* ---------------------------------------------------------------
           CT190FLGLP - ATUALIZA FLAG DE LP Item DIA
           --------------------------------------------------------------- */
         if @cCT2_DTLP != ' ' begin
            select @cCLVL   = ' '
            select @cIdent  = ' '
            select @cTabela = 'CQ5'
            Exec CTB025_##  @cFilial_CQ5, @cTabela, @cIdent, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cCT2_DTLP, @cMOEDA, @IN_TPSALDO, @IN_EMPANT,@IN_FILIAL, @OUT_RESULTADO OutPut
            
         end
         /*---------------------------------------------------------------
            Atualiza Valor Mes de Contas - CQ4
           --------------------------------------------------------------- */
         Select @cFilAnt   = @cFILCT2
         Select @cContaAnt = @cCONTA
         Select @cCustoAnt = @cCUSTO
         Select @cItemAnt  = @cITEM
         Select @cMoedaAnt = @cMOEDA
         Select @cDataAnt  = @cDATA
         Select @cDtLpAnt  = @cCT2_DTLP
         select @cAnoMes   = SUBSTRING( @cDATA, 1, 6 )
         /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
            -------------------------------------------------------------------------------------------------------------- */
         SELECT @fim_CUR = 0
         Fetch CUR_CT4 into  @cFILCT2, @cCONTA, @cCUSTO, @cITEM, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
         /* --------------------------------------------------------------------------------------------------------------
            Ajuste necessario devido a falha do CURSOR apos o termino do mesmo, ou seja,
            apos o termino a variavel do cursor mantem o seu conteudo.
            -------------------------------------------------------------------------------------------------------------- */
         if @@fetch_status = -1 select @cCONTA = ' '
         /*-----------------------------------------------------------------
            Verifica se a chave anterior é igual para acumular o valor MES
            ATUALIZA SALDOS MES qdo necessario
           ----------------------------------------------------------------- */
         If @cFilAnt = @cFILCT2 and @cContaAnt = @cCONTA and @cCustoAnt = @cCUSTO and @cItemAnt = @cITEM and @cMoedaAnt = @cMOEDA and @cAnoMes = SUBSTRING( @cDATA, 1, 6 ) and @cDtLpAnt = @cCT2_DTLP  begin
            If @cTIPO = '1' begin
               select @nDebMes = @nDebMes + @nVALOR
            end
            If @cTIPO = '2' begin
               select @nCrdMes = @nCrdMes + @nVALOR
            end
         end else begin
            /*---------------------------------------------------------------
               Verifico se a Data Apur está preenchida
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
               INSERT ou UPDATE no VALOR MES de Contas - CQ4
              --------------------------------------------------------------- */      
            select @iRecno = 0
			    ##UNIQUEKEY_START	
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ4###
             Where CQ4_FILIAL = @cFilial_CQ4
               and CQ4_DATA   = @cDataF
               and CQ4_CONTA  = @cContaAnt
               and CQ4_CCUSTO = @cCustoAnt
               and CQ4_ITEM   = @cItemAnt
               and CQ4_MOEDA  = @cMoedaAnt
               and CQ4_TPSALD = @IN_TPSALDO
               and CQ4_LP     = @cCTX_LP
               and CQ4_DTLP   = @cCTX_DTLP
               and D_E_L_E_T_ = ' '
                ##UNIQUEKEY_END
            /*---------------------------------------------------------------
               Insert ou Update no Valor Mes da Conta - CQ4
              --------------------------------------------------------------- */         
            If @iRecno = 0 begin
               select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ4###
               select @iRecno = @iRecno + 1
               /*---------------------------------------------------------------
                 Insert no CQ4 - Saldos Mes da Conta
                 --------------------------------------------------------------- */
               ##TRATARECNO @iRecno\
               Begin Tran
               Insert into CQ4### ( CQ4_FILIAL,   CQ4_CONTA,  CQ4_CCUSTO, CQ4_ITEM,  CQ4_MOEDA,  CQ4_DATA, CQ4_TPSALD,  CQ4_SLBASE,   CQ4_DTLP,   CQ4_LP, CQ4_STATUS,   CQ4_DEBITO, CQ4_CREDIT, R_E_C_N_O_ )
							    values( @cFilial_CQ4, @cContaAnt, @cCustoAnt, @cItemAnt, @cMoedaAnt, @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0,   @iRecno )
               commit tran
               ##FIMTRATARECNO
                end
               /*---------------------------------------------------------------
                 Update no CQ4 - Saldos MES
                 --------------------------------------------------------------- */
               Begin Tran
               If @cTIPO = '1' begin
                  Update CQ4###
                     set CQ4_DEBITO = CQ4_DEBITO + @nDebMes
                    Where R_E_C_N_O_ = @iRecno
               End
               If @cTIPO = '2' begin
                  Update CQ4###
                     set CQ4_CREDIT  = CQ4_CREDIT + @nCrdMes
                    Where R_E_C_N_O_ = @iRecno
               End   
               commit tran
            /* ---------------------------------------------------------------
               Zero variaveis que atualizam o  Valor Mes de Contas - CQ4
               --------------------------------------------------------------- */               
            select @nDebMes = 0
            select @nCrdMes = 0
            select @lPrim   = '1'
            /* ---------------------------------------------------------------
              CT190FLGLP - ATUALIZA FLAG DE LP custos/Entidades- MES CTD
              --------------------------------------------------------------- */
            if @cCTX_DTLP != ' ' begin
               select @cCLVL   = ' '
               select @cIdent  = ' '
               select @cTabela = 'CQ4'
               Exec CTB025_##  @cFilial_CQ4, @cTabela, @cIdent, @cContaAnt, @cCustoAnt, @cItemAnt, @cCLVL, @cCTX_DTLP, @cMoedaAnt, @IN_TPSALDO, @IN_EMPANT,@IN_FILIAL, @OUT_RESULTADO OutPut
            End
         end
      end
      close CUR_CT4
      deallocate CUR_CT4
   End
    /* ---------------------------------------------------------------
      ATUALIZAR CLASSE DE VALOR - CQ6/CQ7
      --------------------------------------------------------------- */
   If @IN_LCLVL = '1' begin
      select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
      Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
      
      Select @cFilAnt   = ' '
      Select @cContaAnt = ' '
      Select @cCustoAnt = ' '
      Select @cItemAnt  = ' '
      Select @cClvlAnt  = ' '
      Select @cMoedaAnt = ' '
      Select @cDataAnt  = ' '
      Select @cDtLpAnt  = ' '
      select @cAnoMes   = ' '
      select @nDebMes   = 0
      select @nCrdMes   = 0
      select @lPrim     = '1'
      
      Declare CUR_CTI insensitive cursor for
      Select CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_CLVLDB, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '1'
        From CT2###
       Where CT2_FILIAL = @cFilial_CT2
         and (CT2_DC = '1' or CT2_DC = '3')
         and CT2_CLVLDB != ' '
         and CT2_TPSALD = @IN_TPSALDO
         and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
         and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
         and CT2_DEBITO = @IN_CONTA
         and D_E_L_E_T_= ' '
       Group By CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_CLVLDB, CT2_MOEDLC, CT2_DATA, CT2_DTLP
      Union
      Select CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_CLVLCR, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '2'
        From CT2###
       Where CT2_FILIAL = @cFilial_CT2
         and (CT2_DC = '2' or CT2_DC = '3')
         and CT2_CLVLCR != ' '
         and CT2_TPSALD = @IN_TPSALDO
         and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
         and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
         and CT2_CREDIT = @IN_CONTA
         and D_E_L_E_T_ = ' '
      Group By CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_CLVLCR, CT2_MOEDLC, CT2_DATA, CT2_DTLP
      order by 1,2,3,4,5,6,7,8
      
      for read only
      Open CUR_CTI
      Fetch CUR_CTI into  @cFILCT2, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
      
      While (@@Fetch_status = 0 ) begin
         select @cAux = 'CQ6'
         exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ6 OutPut
         select @cAux = 'CQ7'
         exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ7 OutPut
         /*---------------------------------------------------------------
           Na primeira passagem alimenta as variaveis 
           --------------------------------------------------------------- */
         If @lPrim = '1' begin
            Select @cFilAnt   = @cFILCT2
            Select @cContaAnt = @cCONTA
            Select @cCustoAnt = @cCUSTO
            Select @cItemAnt  = @cITEM
            Select @cClvlAnt  = @cCLVL
            Select @cMoedaAnt = @cMOEDA
            Select @cDataAnt  = @cDATA
            Select @cDtLpAnt  = @cCT2_DTLP
            select @cAnoMes   = SUBSTRING( @cDATA, 1, 6 )
            
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
           Ajusta dados para GRAVAÇÃO DE SALDOS DO DIA  SQ4
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
           Verifica se a linha ja existe no CQ7
           --------------------------------------------------------------- */      
         select @iRecno = 0
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
            and CQ7_TPSALD = @IN_TPSALDO
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
            Begin Tran
            Insert into CQ7### ( CQ7_FILIAL,   CQ7_CONTA,    CQ7_CCUSTO, CQ7_ITEM, CQ7_CLVL, CQ7_MOEDA, CQ7_DATA, CQ7_TPSALD,  CQ7_SLBASE,   CQ7_DTLP,   CQ7_LP, CQ7_STATUS,   CQ7_DEBITO,   CQ7_CREDIT, R_E_C_N_O_ )
							    values( @cFilial_CQ7, @cCONTA,      @cCUSTO,    @cITEM,   @cCLVL,   @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            commit tran
            ##FIMTRATARECNO
		    end
            /*---------------------------------------------------------------
              Update no CQ7 - Saldos da Conta
              --------------------------------------------------------------- */
            Begin Tran
            If @cTIPO = '1' begin
               Update CQ7###
                   set CQ7_DEBITO = CQ7_DEBITO + @nCTX_DEBITO
                 Where R_E_C_N_O_ = @iRecno
            End
            If @cTIPO = '2' begin
               Update CQ7###
                  set CQ7_CREDIT  = CQ7_CREDIT + @nCTX_CREDIT
                 Where R_E_C_N_O_ = @iRecno
            End
            commit tran
         /* ---------------------------------------------------------------
           CT190FLGLP - ATUALIZA FLAG DE LP Clvl dia
           --------------------------------------------------------------- */
         if @cCT2_DTLP != ' ' begin
            select @cAux = ' '
            select @cTabela = 'CQ7'
            select @cIdent  = ' '
            Exec CTB025_##  @cFilial_CQ7, @cTabela, @cIdent, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cCT2_DTLP, @cMOEDA, @IN_TPSALDO, @IN_EMPANT,@IN_FILIAL, @OUT_RESULTADO OutPut
         end
         /*---------------------------------------------------------------
            Atualiza Valor Mes de Contas - CQ6
           --------------------------------------------------------------- */      
         Select @cFilAnt   = @cFILCT2
         Select @cContaAnt = @cCONTA
         Select @cCustoAnt = @cCUSTO
         Select @cItemAnt  = @cITEM
         Select @cClvlAnt  = @cCLVL
         Select @cMoedaAnt = @cMOEDA
         Select @cDataAnt  = @cDATA
         Select @cDtLpAnt  = @cCT2_DTLP
         select @cAnoMes   = SUBSTRING( @cDATA, 1, 6 )
         /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
            -------------------------------------------------------------------------------------------------------------- */
         SELECT @fim_CUR = 0
         Fetch CUR_CTI into  @cFILCT2, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
         /* --------------------------------------------------------------------------------------------------------------
            Ajuste necessario devido a falha do CURSOR apos o termino do mesmo, ou seja,
            apos o termino a variavel do cursor mantem o seu conteudo.
            -------------------------------------------------------------------------------------------------------------- */
         if @@fetch_status = -1 select @cCONTA = ' '
         /*-----------------------------------------------------------------
            Verifica se a chave anterior é igual para aculumar o valor MES
            ATUALIZA SALDOS MES qdo necessario
           ----------------------------------------------------------------- */
         If @cFilAnt = @cFILCT2 and @cContaAnt = @cCONTA and @cCustoAnt = @cCUSTO and @cItemAnt = @cITEM and @cClvlAnt = @cCLVL and @cMoedaAnt = @cMOEDA and @cAnoMes = SUBSTRING( @cDATA, 1, 6 ) and @cDtLpAnt = @cCT2_DTLP  begin
            If @cTIPO = '1' begin
               select @nDebMes = @nDebMes + @nVALOR
            end
            If @cTIPO = '2' begin
               select @nCrdMes = @nCrdMes + @nVALOR
            end
         end else begin
            /*---------------------------------------------------------------
               Verifico se a Data Apur está preenchida
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
               INSERT ou UPDATE no VALOR MES de Contas - CQ6
              --------------------------------------------------------------- */      
            select @iRecno = 0
                ##UNIQUEKEY_START
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ6###
             Where CQ6_FILIAL = @cFilial_CQ6
               and CQ6_DATA   = @cDataF
               and CQ6_CONTA  = @cContaAnt
               and CQ6_CCUSTO = @cCustoAnt
               and CQ6_ITEM   = @cItemAnt
               and CQ6_CLVL   = @cClvlAnt
               and CQ6_MOEDA  = @cMoedaAnt
               and CQ6_TPSALD = @IN_TPSALDO
               and CQ6_LP     = @cCTX_LP
               and CQ6_DTLP   = @cCTX_DTLP
               and D_E_L_E_T_ = ' '
                ##UNIQUEKEY_END

            /*---------------------------------------------------------------
               Insert ou Update no Valor Mes da Conta - CQ6
              --------------------------------------------------------------- */
            If @iRecno = 0 begin
               select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ6###
               select @iRecno = @iRecno + 1
               /*---------------------------------------------------------------
                 Insert no CQ6 - Saldos Mes da Conta
                 --------------------------------------------------------------- */
               ##TRATARECNO @iRecno\
               Begin Tran
               Insert into CQ6### ( CQ6_FILIAL,   CQ6_CONTA,  CQ6_CCUSTO, CQ6_ITEM,  CQ6_CLVL,  CQ6_MOEDA,  CQ6_DATA, CQ6_TPSALD,  CQ6_SLBASE,   CQ6_DTLP,   CQ6_LP, CQ6_STATUS,   CQ6_DEBITO, CQ6_CREDIT,  R_E_C_N_O_ )
							    values( @cFilial_CQ6, @cContaAnt, @cCustoAnt, @cItemAnt, @cClvlAnt, @cMoedaAnt, @cDataF,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0,   0,    @iRecno )
               commit tran
               ##FIMTRATARECNO
                end
               /*---------------------------------------------------------------
                 Update no CQ6 - Saldos MES
                 --------------------------------------------------------------- */
               Begin Tran
               If @cTIPO = '1' begin
                  Update CQ6###
                     set CQ6_DEBITO = CQ6_DEBITO + @nDebMes
                    Where R_E_C_N_O_ = @iRecno
               End
               If @cTIPO = '2' begin
                  Update CQ6###
                     set CQ6_CREDIT  = CQ6_CREDIT + @nCrdMes
                    Where R_E_C_N_O_ = @iRecno
               End
               commit tran
            /* ---------------------------------------------------------------
               Zero variaveis que atualizam o  Valor Mes de Contas - CQ6
               --------------------------------------------------------------- */
            select @nDebMes = 0
            select @nCrdMes = 0
            select @lPrim   = '1'
            /* ---------------------------------------------------------------
              CT190FLGLP - ATUALIZA FLAG DE LP Contas MES
              --------------------------------------------------------------- */
            if @cCTX_DTLP != ' ' begin
               select @cTabela = 'CQ6'
               select @cIdent  = ' '
               Exec CTB025_##  @cFilial_CQ6, @cTabela, @cIdent, @cContaAnt, @cCustoAnt, @cItemAnt, @cClvlAnt, @cCTX_DTLP, @cMoedaAnt, @IN_TPSALDO, @IN_EMPANT, @IN_FILIAL, @OUT_RESULTADO OutPut
            end
         end
      end
      close CUR_CTI
      deallocate CUR_CTI
   End
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
   --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end
