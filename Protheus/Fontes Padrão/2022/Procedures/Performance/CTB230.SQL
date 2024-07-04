Create procedure CTB230_## ( 
   @IN_FILIAL       Char('CT2_FILIAL'),
   @IN_LITEM        Char(01),
   @IN_LCLVL        Char(01),
   @IN_FILIALATE    Char('CT2_FILIAL'),
   @IN_DATADE       Char(08),
   @IN_DATAATE      Char(08),
   @IN_LMOEDAESP    Char(01),
   @IN_MOEDA        Char('CQ0_MOEDA'),
   @IN_TPSALDO      Char('CT2_TPSALD'),
   @IN_EMPANT       Char(02),
   @IN_FILANT       Char('CT2_FILIAL'), 
   @OUT_RESULTADO   Char(01) OutPut )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P.12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Descricao       - <d>  Reprocessamento SigaCTB </d>
    Procedure       -      Atualizacao de slds Bases - CQ4, CQ5, CQ6, CQ7
    Funcao do Siga  -      Ct190SlBse()
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente
                           @IN_LITEM        - Item em uso
                           @IN_LCLVL        - Classe de Valor em uso
                           @IN_FILIALATE    - Filial final do processamento
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     03/11/2003
    Obs: a variável @iTranCount = 0 será trocada por 'commit tran' no CFGX051 pro SQLSERVER 
         e SYBASE
   -------------------------------------------------------------------------------------- */
declare @cFilial_CT2 char('CT2_FILIAL')
declare @cCT2FilDe   char('CT2_FILIAL')
declare @cFILCT2     char('CT2_FILIAL')
declare @cFilial_CQ4 char('CQ4_FILIAL')
declare @cFilial_CQ5 char('CQ5_FILIAL')
declare @cFilial_CQ6 char('CQ6_FILIAL')
declare @cFilial_CQ7 char('CQ7_FILIAL')
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
declare @nVALORDeb   Float
declare @nVALORCred  Float
declare @cIdent      VarChar(03)
declare @cDataI      Char(08)
declare @cDataF      Char(08)
Declare @iTranCount  Integer --Var.de ajuste para SQLServer e Sybase.-- Será trocada por Commit no CFGX051 após passar pelo Parse
declare @lPrim       char(01)
declare @cFilAnt     char('CQ1_FILIAL')
declare @cContaAnt   char('CQ1_CONTA')
declare @cCustoAnt   char('CQ2_CCUSTO')
declare @cItemAnt    char('CQ4_ITEM')
declare @cClvlAnt    char('CQ6_CLVL')
declare @cMoedaAnt   char('CQ1_MOEDA')
Declare @cDtLPAnt    char('CQ1_DATA')
declare @cDATACQ     char(06)
declare @cDataAnt    char(06)
declare @cLPAnt      char('CQ1_LP')
declare @cChaveCQAtu Varchar(100)
declare @cChaveCQAnt Varchar(100)
                             
begin
    select @OUT_RESULTADO = '0'
    select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
   
    Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
   
    If @IN_FILIAL = ' ' select @cCT2FilDe = ' '
    else select @cCT2FilDe = @IN_FILIAL
 
    select @cAux = 'CT2'
    exec XFILIAL_## @cAux, @cCT2FilDe, @cFilial_CT2 OutPut
    /* ---------------------------------------------------------------
       ATUALIZAR ITEM CONTABIL - CQ4/CQ5
       --------------------------------------------------------------- */
    If @IN_LITEM = '1' begin
        select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
        Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
        
        Declare CUR_CT4 insensitive cursor for
        Select CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '1'
          From CT2###
         Where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
           and (CT2_DC = '1' or CT2_DC = '3')
           and CT2_ITEMD != ' '
           and CT2_TPSALD = @IN_TPSALDO
           and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
           and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
           and CT2_DEBITO != ' '
           and D_E_L_E_T_= ' '
        Group By CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_MOEDLC, CT2_DATA, CT2_DTLP
        Union
        Select CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '2'
          From CT2###
         Where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
           and (CT2_DC = '2' or CT2_DC = '3')
           and CT2_ITEMC != ' '
           and CT2_TPSALD = @IN_TPSALDO
           and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
           and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
           and CT2_CREDIT != ' '
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
            /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
            -------------------------------------------------------------------------------------------------------------- */
            select @iRecno  = 0
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
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
         
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ5###
                select @iRecno = @iRecno + 1
                /*---------------------------------------------------------------
                    Insert no CQ5 - Saldos da Conta
                    --------------------------------------------------------------- */
                ##TRATARECNO @iRecno\
                begin tran
                Insert into CQ5### ( CQ5_FILIAL,   CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM, CQ5_MOEDA, CQ5_DATA, CQ5_TPSALD,  CQ5_SLBASE,   CQ5_DTLP,   CQ5_LP,   CQ5_STATUS,  CQ5_DEBITO, CQ5_CREDIT, R_E_C_N_O_ )
                            values( @cFilial_CQ5, @cCONTA,   @cCUSTO,    @cITEM,   @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,           0, @iRecno )
                commit tran
                ##FIMTRATARECNO
            end
            /*---------------------------------------------------------------
                Update no CQ5 - Saldos da Conta
                --------------------------------------------------------------- */
            Begin Tran
            Update CQ5###
               set CQ5_DEBITO = CQ5_DEBITO + @nCTX_DEBITO, CQ5_CREDIT = CQ5_CREDIT + @nCTX_CREDIT
             Where R_E_C_N_O_ = @iRecno
            commit tran
            /* ---------------------------------------------------------------
            CT190FLGLP - ATUALIZA FLAG DE LP Item DIA e Mes
            --------------------------------------------------------------- */
            if @cCT2_DTLP != ' ' begin
                select @cCLVL   = ' '
                select @cIdent  = ' '
                select @cTabela = 'CQ5'
                Exec CTB025_##  @cFilial_CQ5, @cTabela, @cIdent, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cCT2_DTLP, @cMOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @OUT_RESULTADO OutPut
            end
            /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CT4 into  @cFILCT2, @cCONTA, @cCUSTO, @cITEM, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
        end
        close CUR_CT4
        deallocate CUR_CT4
	    /* --------------------------------------------------------------------------------------------------------------
		   Gravação CQ4 - Item Menssal 
	       -------------------------------------------------------------------------------------------------------------- */
        select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
        Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut   
	   
        If @IN_FILIAL = ' ' select @cCT2FilDe = ' '
        else select @cCT2FilDe = @IN_FILIAL
	    
        select @cAux = 'CT2'
        exec XFILIAL_## @cAux, @cCT2FilDe, @cFilial_CT2 OutPut
        
        Declare CUR_CQ5 insensitive cursor for
         Select CQ5_FILIAL, CQ5_ITEM, CQ5_CCUSTO, CQ5_CONTA, CQ5_MOEDA, Substring( CQ5_DATA, 1, 6 ), CQ5_DTLP, CQ5_LP, SUM(CQ5_DEBITO), SUM(CQ5_CREDIT)
		   From CQ5###
		  Where CQ5_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
            and CQ5_TPSALD = @IN_TPSALDO
            and ( ( CQ5_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
            and (CQ5_DATA between @cDataI and @cDataF)
            and D_E_L_E_T_= ' '
        Group By CQ5_FILIAL, CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM, CQ5_MOEDA, Substring( CQ5_DATA, 1, 6 ), CQ5_DTLP, CQ5_LP
        order by 1,2,3,4,5,6, 7, 8
        for read only
        Open CUR_CQ5
        Fetch CUR_CQ5 into  @cFILCT2, @cITEM, @cCUSTO, @cCONTA, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
	   
        While (@@Fetch_status = 0 ) begin
            
            select @cAux = 'CQ4'
            exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ4 OutPut
            select @cDataI = @cDATACQ||'01'
            Exec LASTDAY_## @cDataI, @cDataF OutPut
	      
            select @nCTX_DEBITO = Round(@nVALORDeb, 2)
            select @nCTX_CREDIT = Round(@nVALORCred, 2)
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'
            
            /* ----------------------------------------------------------------------------------------------------
               As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
               houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
               após a MsParse() devolver o código na linguagem do banco em uso.
               -------------------------------------------------------------------------------------------------------------- */
            select @iRecno  = 0
            ##UNIQUEKEY_START 
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ4###
             Where CQ4_FILIAL = @cFilial_CQ4
               and CQ4_CONTA  = @cCONTA
               and CQ4_CCUSTO = @cCUSTO
               and CQ4_ITEM   = @cITEM
               and CQ4_MOEDA  = @cMOEDA
               and CQ4_DATA   = @cDataF
               and CQ4_TPSALD = @IN_TPSALDO
               and CQ4_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END

            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ4###
                select @iRecno = @iRecno + 1
                /*---------------------------------------------------------------
                Insert no CQ4 - Saldos da conta
                --------------------------------------------------------------- */
                ##TRATARECNO @iRecno\
                begin tran
                Insert into CQ4### ( CQ4_FILIAL, CQ4_CONTA, CQ4_CCUSTO, CQ4_ITEM, CQ4_MOEDA, CQ4_DATA, CQ4_TPSALD,  CQ4_SLBASE,   CQ4_DTLP,   CQ4_LP,   CQ4_STATUS,  CQ4_DEBITO, CQ4_CREDIT, R_E_C_N_O_ )
                            values( @cFilial_CQ4, @cCONTA,  @cCUSTO,    @cITEM,   @cMOEDA,   @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,          0, @iRecno )
                commit tran
                ##FIMTRATARECNO
            end
            /* ---------------------------------------------------------------
                Update no CQ4
                --------------------------------------------------------------- */
            begin tran
            Update CQ4###
                set CQ4_DTLP   = @cCTX_DTLP,
	                CQ4_DEBITO = CQ4_DEBITO + @nCTX_DEBITO,
                    CQ4_CREDIT = CQ4_CREDIT + @nCTX_CREDIT
            Where R_E_C_N_O_ = @iRecno
            commit tran
            /* --------------------------------------------------------------------------------------------------------------
	            Tratamento para o DB2
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CQ5 into @cFILCT2, @cITEM, @cCUSTO, @cCONTA, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CQ5
        deallocate CUR_CQ5   
    End
    /* ---------------------------------------------------------------
      ATUALIZAR CLASSE DE VALOR - CQ6/CQ7
      --------------------------------------------------------------- */
    If @IN_LCLVL = '1' begin
        Select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
        Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
        
        Declare CUR_CTI insensitive cursor for
        Select CT2_FILIAL, CT2_CLVLDB, CT2_ITEMD, CT2_CCD, CT2_DEBITO, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '1'
          From CT2###
         Where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
           and (CT2_DC = '1' or CT2_DC = '3')
           and CT2_CLVLDB != ' '
           and CT2_TPSALD = @IN_TPSALDO
           and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
           and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
           and CT2_DEBITO != ' '
           and D_E_L_E_T_= ' '
        Group By CT2_FILIAL, CT2_CLVLDB, CT2_ITEMD, CT2_CCD, CT2_DEBITO, CT2_MOEDLC, CT2_DATA, CT2_DTLP
        Union
        Select CT2_FILIAL, CT2_CLVLCR, CT2_ITEMC, CT2_CCC, CT2_CREDIT, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '2'
          From CT2###
         Where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
           and (CT2_DC = '2' or CT2_DC = '3')
           and CT2_CLVLCR != ' '
           and CT2_TPSALD = @IN_TPSALDO
           and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
           and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
           and CT2_CREDIT != ' '
           and D_E_L_E_T_ = ' '
        Group By CT2_FILIAL, CT2_CLVLCR, CT2_ITEMC, CT2_CCC, CT2_CREDIT, CT2_MOEDLC, CT2_DATA, CT2_DTLP
        order by 1,2,3,4,5,6,7,8
      
        for read only
        Open CUR_CTI
        Fetch CUR_CTI into  @cFILCT2, @cCLVL, @cITEM, @cCUSTO, @cCONTA, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
      
        While (@@Fetch_status = 0 ) begin
              
            select @cAux = 'CQ6'
            exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ6 OutPut
            select @cAux = 'CQ7'
            exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ7 OutPut

            Exec LASTDAY_## @cDATA, @cDataF OutPut
         
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
            /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
            -------------------------------------------------------------------------------------------------------------- */
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
                and CQ7_TPSALD = @IN_TPSALDO
                and CQ7_LP     = @cCTX_LP
                and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
         
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ7###
                select @iRecno = @iRecno + 1
                /*---------------------------------------------------------------
                    Insert no CQ7 - Saldos da Conta
                    --------------------------------------------------------------- */
                ##TRATARECNO @iRecno\
                begin tran
                Insert into CQ7### ( CQ7_FILIAL,  CQ7_CONTA, CQ7_CCUSTO, CQ7_ITEM, CQ7_CLVL, CQ7_MOEDA, CQ7_DATA, CQ7_TPSALD,  CQ7_SLBASE,   CQ7_DTLP,   CQ7_LP, CQ7_STATUS,   CQ7_DEBITO, CQ7_CREDIT, R_E_C_N_O_ )
                            values( @cFilial_CQ7, @cCONTA,   @cCUSTO,    @cITEM,   @cCLVL,   @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,        0,          0, @iRecno )
                commit tran
                ##FIMTRATARECNO
            end
            /*---------------------------------------------------------------
                Update no CQ7 - Saldos da Conta
                --------------------------------------------------------------- */
            Begin Tran
            Update CQ7###
                set CQ7_DEBITO = CQ7_DEBITO + @nCTX_DEBITO, CQ7_CREDIT = CQ7_CREDIT + @nCTX_CREDIT
            Where R_E_C_N_O_ = @iRecno
            commit tran
            /* ---------------------------------------------------------------
            CT190FLGLP - ATUALIZA FLAG DE LP Clvl dia 
            --------------------------------------------------------------- */
            if @cCT2_DTLP != ' ' begin
                select @cTabela = 'CQ7'
                select @cIdent  = ' '
                Exec CTB025_##  @cFilial_CQ7, @cTabela, @cIdent, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cCT2_DTLP, @cMOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @OUT_RESULTADO OutPut
            end
            /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CTI into  @cFILCT2, @cCLVL, @cITEM, @cCUSTO, @cCONTA, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
        end
        close CUR_CTI
        deallocate CUR_CTI
	    /* --------------------------------------------------------------------------------------------------------------
		   Gravação CQ6 - CLVL Mensal
	      -------------------------------------------------------------------------------------------------------------- */
        select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
        Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut   
	   
        If @IN_FILIAL = ' ' select @cCT2FilDe = ' '
        else select @cCT2FilDe = @IN_FILIAL
	   
        select @cAux = 'CT2'
        exec XFILIAL_## @cAux, @cCT2FilDe, @cFilial_CT2 OutPut
      
        Declare CUR_CQ7 insensitive cursor for
        Select CQ7_FILIAL, CQ7_CONTA, CQ7_CCUSTO, CQ7_ITEM, CQ7_CLVL, CQ7_MOEDA, Substring( CQ7_DATA, 1, 6 ), CQ7_DTLP, CQ7_LP, SUM(CQ7_DEBITO), SUM(CQ7_CREDIT)
          From CQ7###
         Where CQ7_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
	       and CQ7_TPSALD = @IN_TPSALDO
	       and ( ( CQ7_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
	       and (CQ7_DATA between @cDataI and @cDataF)
	       and D_E_L_E_T_= ' '
        Group By CQ7_FILIAL, CQ7_CONTA, CQ7_CCUSTO, CQ7_ITEM, CQ7_CLVL, CQ7_MOEDA, Substring( CQ7_DATA, 1, 6 ), CQ7_DTLP, CQ7_LP
        order by 1,2,3,4,5,6,7,9
        for read only
        Open CUR_CQ7
        Fetch CUR_CQ7 into @cFILCT2,  @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cMOEDA, @cDATACQ, @cCTX_DTLP,@cCTX_LP, @nVALORDeb, @nVALORCred
	   
        While (@@Fetch_status = 0 ) begin
            select @cAux = 'CQ6'
            exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ6 OutPut
            select @cDataI = @cDATACQ||'01'
            Exec LASTDAY_## @cDataI, @cDataF OutPut
	      
            select @nCTX_DEBITO = Round(@nVALORDeb, 2)
            select @nCTX_CREDIT = Round(@nVALORCred, 2)
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'
            /* ---------------------------------------------------------------
               As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
               houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
               após a MsParse() devolver o código na linguagem do banco em uso.
               -------------------------------------------------------------------------------------------------------------- */
            select @iRecno  = 0

            ##UNIQUEKEY_START 
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ6###
             Where CQ6_FILIAL = @cFilial_CQ6
               and CQ6_CONTA  = @cCONTA
               and CQ6_CCUSTO = @cCUSTO
               and CQ6_ITEM   = @cITEM
               and CQ6_CLVL   = @cCLVL
               and CQ6_MOEDA  = @cMOEDA
               and CQ6_DATA   = @cDataF
               and CQ6_TPSALD = @IN_TPSALDO
               and CQ6_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
                        
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ6###
                select @iRecno = @iRecno + 1
                /*---------------------------------------------------------------
                Insert no CQ6 - Saldos da conta
                --------------------------------------------------------------- */
                ##TRATARECNO @iRecno\			 
                begin tran
                Insert into CQ6### ( CQ6_FILIAL,   CQ6_CONTA, CQ6_CCUSTO, CQ6_ITEM, CQ6_CLVL, CQ6_MOEDA, CQ6_DATA, CQ6_TPSALD,  CQ6_SLBASE,   CQ6_DTLP,   CQ6_LP, CQ6_STATUS,   CQ6_DEBITO, CQ6_CREDIT, R_E_C_N_O_ )
                            values( @cFilial_CQ6, @cCONTA,   @cCUSTO,    @cITEM,   @cCLVL,   @cMOEDA,   @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,          0, @iRecno )
                commit tran
                ##FIMTRATARECNO
            end
	        /*---------------------------------------------------------------
	          Update no CQ6
	          --------------------------------------------------------------- */
            begin tran
	        Update CQ6###
		       set CQ6_DTLP    = @cCTX_DTLP, 
		           CQ6_DEBITO  = CQ6_DEBITO + @nCTX_DEBITO,
		           CQ6_CREDIT  = CQ6_CREDIT + @nCTX_CREDIT
		     Where R_E_C_N_O_ = @iRecno
            commit tran
            /* --------------------------------------------------------------------------------------------------------------
			   Tratamento para o DB2
		       -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CQ7 into @cFILCT2,  @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cMOEDA, @cDATACQ, @cCTX_DTLP,@cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CQ7
        deallocate CUR_CQ7
    End
    /*---------------------------------------------------------------
       Se a execucao foi OK retorna '1'
      --------------------------------------------------------------- */
    select @OUT_RESULTADO = '1'
end
