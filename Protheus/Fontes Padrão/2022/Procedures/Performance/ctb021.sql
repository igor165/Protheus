Create procedure CTB021_## ( 
   @IN_FILIAL       Char('CT2_FILIAL'),
   @IN_LCUSTO       Char(01),
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
    Procedure       -      Atualizacao de slds Bases - CT3, CT4, CT7, CTI
    Funcao do Siga  -      Ct190SlBse()
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente
                           @IN_LCUSTO       - Centro de Custo em uso
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
declare @cFilial_CQ0 char('CQ0_FILIAL')
declare @cFilial_CQ1 char('CQ1_FILIAL')
declare @cFilial_CQ2 char('CQ2_FILIAL')
declare @cFilial_CQ3 char('CQ3_FILIAL')
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
Declare @cAnoMes     Char(06)
Declare @lPrim       Char(01)
Declare @iTranCount  Integer --Var.de ajuste para SQLServer e Sybase.-- Será trocada por Commit no CFGX051 após passar pelo Parse
Declare @cDATACQ    Char(06)

begin
    
    select @OUT_RESULTADO = '0'
        
    select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
    Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut   
    
    If @IN_FILIAL = ' ' select @cCT2FilDe = ' '
    else select @cCT2FilDe = @IN_FILIAL
    
    select @cAux = 'CT2'
    exec XFILIAL_## @cAux, @cCT2FilDe, @cFilial_CT2 OutPut
    
    Declare CUR_CTB190 insensitive cursor for
    Select CT2_FILIAL, CT2_DEBITO, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '1'
        From CT2###
        Where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
        and (CT2_DC = '1' or CT2_DC = '3')
        and CT2_TPSALD = @IN_TPSALDO
        and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
        and ( CT2_DATA between @IN_DATADE and @IN_DATAATE)
        and CT2_DEBITO != ' '
        and D_E_L_E_T_= ' '
        Group By CT2_FILIAL, CT2_DEBITO, CT2_MOEDLC, CT2_DATA, CT2_DTLP
        Union
    Select CT2_FILIAL, CT2_CREDIT, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '2'
        From CT2###
        Where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
        and (CT2_DC = '2' or CT2_DC = '3')
        and CT2_TPSALD = @IN_TPSALDO
        and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
        and ( CT2_DATA between @IN_DATADE and @IN_DATAATE )
        and CT2_CREDIT != ' '
        and D_E_L_E_T_ = ' '
    Group By CT2_FILIAL, CT2_CREDIT, CT2_MOEDLC, CT2_DATA, CT2_DTLP
    order by 1, 2, 3, 4, 5
    for read only
    Open CUR_CTB190
    Fetch CUR_CTB190 into  @cFILCT2, @cCONTA, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
      
    While (@@Fetch_status = 0 ) begin
      
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
        /* ---------------------------------------------------------------
           As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
           houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
           após a MsParse() devolver o código na linguagem do banco em uso.
    		 -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0
        ##UNIQUEKEY_START
        select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
          From CQ1###
         Where CQ1_FILIAL = @cFilial_CQ1
           and CQ1_DATA   = @cDATA
           and CQ1_CONTA  = @cCONTA
           and CQ1_MOEDA  = @cMOEDA
           and CQ1_TPSALD = @IN_TPSALDO
           and CQ1_LP     = @cCTX_LP   
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
            Insert into CQ1### ( CQ1_FILIAL,  CQ1_CONTA, CQ1_MOEDA, CQ1_DATA, CQ1_TPSALD,  CQ1_SLBASE,   CQ1_DTLP,   CQ1_LP, CQ1_STATUS,   CQ1_DEBITO, CQ1_CREDIT, R_E_C_N_O_ )
                        values( @cFilial_CQ1, @cCONTA,   @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,          0, @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /*---------------------------------------------------------------
          Update no CQ1 - Saldos da Conta
          --------------------------------------------------------------- */
        begin tran
        Update CQ1###
           set CQ1_DEBITO = CQ1_DEBITO + @nCTX_DEBITO, CQ1_CREDIT  = CQ1_CREDIT + @nCTX_CREDIT
	      Where R_E_C_N_O_ = @iRecno
        commit tran
        /* ---------------------------------------------------------------
            CT190FLGLP - ATUALIZA FLAG DE LP Contas DIA
            --------------------------------------------------------------- */
        if @cCT2_DTLP != ' ' begin
            select @cCUSTO = ' '
            select @cITEM  = ' '
            select @cCLVL  = ' '
            select @cIdent  = ' '
            select @cTabela = 'CQ1'
            Exec CTB025_##  @cFilial_CQ1, @cTabela, @cIdent, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cCT2_DTLP, @cMOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @OUT_RESULTADO OutPut
        end
        /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
        -------------------------------------------------------------------------------------------------------------- */
        SELECT @fim_CUR = 0
        Fetch CUR_CTB190 into  @cFILCT2, @cCONTA, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
    end
    close CUR_CTB190
    deallocate CUR_CTB190
    /* --------------------------------------------------------------------------------------------------------------
        Gravação CQ0 - Mensal
        -------------------------------------------------------------------------------------------------------------- */
    select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
    Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut   
    
    If @IN_FILIAL = ' ' select @cCT2FilDe = ' '
    else select @cCT2FilDe = @IN_FILIAL
    
    select @cAux = 'CT2'
    exec XFILIAL_## @cAux, @cCT2FilDe, @cFilial_CT2 OutPut
    
    select @cDATACQ   = ' '
    Declare CUR_CQ1 insensitive cursor for
    Select CQ1_FILIAL, CQ1_CONTA , CQ1_MOEDA, Substring( CQ1_DATA, 1, 6 ), CQ1_DTLP, CQ1_LP, SUM(CQ1_DEBITO), SUM(CQ1_CREDIT)
     From CQ1###
    Where CQ1_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
      and CQ1_TPSALD = @IN_TPSALDO
      and ( ( CQ1_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
      and (CQ1_DATA between @cDataI and @cDataF)
      and D_E_L_E_T_= ' '
    Group By CQ1_FILIAL, CQ1_CONTA , CQ1_MOEDA, Substring( CQ1_DATA, 1, 6 ), CQ1_DTLP, CQ1_LP
    order by 1,2,3,4, 5, 6
    for read only
    Open CUR_CQ1
    Fetch CUR_CQ1 into  @cFILCT2, @cCONTA, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
    
    While (@@Fetch_status = 0 ) begin
        
        select @cAux = 'CQ0'
        exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ0 OutPut

         select @cDataI = @cDATACQ||'01'
         Exec LASTDAY_## @cDataI, @cDataF OutPut

         select @nCTX_DEBITO = Round(@nVALORDeb, 2)
         select @nCTX_CREDIT = Round(@nVALORCred, 2)
         select @cCTX_STATUS = '1'
         select @cCTX_SLBASE = 'S'
         /* -------------------------------------------------------------------------------------
	         Verifica se a linha ja existe no CQ0- Abaixo Result set da query no CQ1
            CQ1_FILIAL CQ1_CONTA         CQ1_MOEDA DATAL  DATALP   LP   VALORD    VALORC
            ---------- ----------------- --------- ------ -------- ---- --------- ------------
            D MG 01    1100101           01        201901          N    7          0
            D MG 01    1100102           01        201901          N    0          7
            D MG 01    1100103           01        201901          N    7          0
            D MG 01    1100104           01        201901          N    7          7
            D MG 01    1100105           01        201901          N    0          7
            D MG 01    3100100           01        201901          N    0          3
            D MG 01    3100100           01        201901 20190105 S    0          2
            D MG 01    3100100           01        201901 20190115 S    1          5
            D MG 01    3100100           01        201901 20190105 Z    2          0
            D MG 01    3100100           01        201901 20190115 Z    5          1
            D MG 01    3100101           01        201901          N    3          0
            D MG 01    3100101           01        201901 20190105 S    2          0
            D MG 01    3100101           01        201901 20190115 S    5          1
            D MG 01    3100101           01        201901 20190105 Z    0          2
            D MG 01    3100101           01        201901 20190115 Z    1          5
	         ------------------------------------------------------------------------------------- */     
         select @iRecno  = 0
         /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
            -------------------------------------------------------------------------------------------------------------- */
         ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ0###
          Where CQ0_FILIAL  = @cFilial_CQ0
            and CQ0_CONTA  = @cCONTA
            and CQ0_MOEDA  = @cMOEDA
            and CQ0_DATA   = @cDataF
            and CQ0_TPSALD = @IN_TPSALDO
            and CQ0_LP     = @cCTX_LP
            and D_E_L_E_T_ = ' '
         ##UNIQUEKEY_END
		 
         If @iRecno = 0 begin
             select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ0###
	         select @iRecno = @iRecno + 1
	         /*---------------------------------------------------------------
	         Insert no CQ0 - Saldos da conta
	         --------------------------------------------------------------- */
	         ##TRATARECNO @iRecno\
            Begin Tran
	         Insert into CQ0### ( CQ0_FILIAL, CQ0_CONTA, CQ0_MOEDA, CQ0_DATA, CQ0_TPSALD,  CQ0_SLBASE,   CQ0_DTLP,   CQ0_LP,   CQ0_STATUS,   CQ0_DEBITO, CQ0_CREDIT, R_E_C_N_O_ )
                        values( @cFilial_CQ0, @cCONTA,   @cMOEDA,   @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,          0, @iRecno )
	         commit tran
	         ##FIMTRATARECNO
         end 
         /* -------------------------------------------------------------------------------------------------------
	         Update no CQ0 - Saldos do Item e- Dt Ultima apuração Quando houver mais de uma no Mesmo Periodo- legado
	         ------------------------------------------------------------------------------------------------------- */
         begin tran
         Update CQ0###
         set CQ0_DTLP   = @cCTX_DTLP,
             CQ0_DEBITO = CQ0_DEBITO + @nCTX_DEBITO,
	          CQ0_CREDIT = CQ0_CREDIT + @nCTX_CREDIT
         Where R_E_C_N_O_ = @iRecno
         commit tran
         /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
         -------------------------------------------------------------------------------------------------------------- */
         SELECT @fim_CUR = 0
         Fetch CUR_CQ1 into  @cFILCT2, @cCONTA, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
    end
    close CUR_CQ1
    deallocate CUR_CQ1
    /* ---------------------------------------------------------------
        ATUALIZAR CENTRO DE CUSTOS - CQ2/CQ3
        --------------------------------------------------------------- */
    If @IN_LCUSTO = '1' begin
        select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
        Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut

        select @cAux = 'CT2'
        exec XFILIAL_## @cAux, @cCT2FilDe, @cFilial_CT2 OutPut
           
        Declare CUR_CT3 insensitive cursor for
        Select CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '1'
            From CT2###
            Where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
            and (CT2_DC = '1' or CT2_DC = '3')
            and CT2_CCD != ' '
            and CT2_TPSALD = @IN_TPSALDO
            and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
            and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
            and CT2_DEBITO != ' '
            and D_E_L_E_T_= ' '
        Group By CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_MOEDLC, CT2_DATA, CT2_DTLP
        Union
        Select CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '2'
            From CT2###
            Where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
            and (CT2_DC = '2' or CT2_DC = '3')
            and CT2_CCC != ' '
            and CT2_TPSALD = @IN_TPSALDO
            and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
            and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
            and CT2_CREDIT != ' '
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
         
            select @nCTX_DEBITO = 0
            select @nCTX_CREDIT = 0
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'
            select @cCTX_DTLP = ' '
            /*---------------------------------------------------------------
            Ajusta dados para GRAVAÇÃO DE SALDOS DO DIA  SQ3
            --------------------------------------------------------------- */
            if @cTIPO = '1' begin
                select @nCTX_DEBITO = @nVALOR
                select @nCTX_CREDIT = 0
            end
            if @cTIPO = '2' begin
                select @nCTX_CREDIT = @nVALOR
                select @nCTX_DEBITO = 0
            end
            select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
            select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)            
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
            /* ---------------------------------------------------------------
               As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
               houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
               após a MsParse() devolver o código na linguagem do banco em uso.
    		     -------------------------------------------------------------------------------------------------------------- */
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
                Insert into CQ3### ( CQ3_FILIAL,  CQ3_CONTA, CQ3_CCUSTO, CQ3_MOEDA, CQ3_DATA, CQ3_TPSALD,  CQ3_SLBASE,   CQ3_DTLP,   CQ3_LP,   CQ3_STATUS,  CQ3_DEBITO, CQ3_CREDIT, R_E_C_N_O_ )
                            values( @cFilial_CQ3, @cCONTA,   @cCUSTO,    @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,          0, @iRecno )
                commit tran
                ##FIMTRATARECNO   
            end
            /*---------------------------------------------------------------
               Update no CQ3 - Saldos da Custo DIA
            --------------------------------------------------------------- */
            Begin Tran
            Update CQ3###
               set CQ3_DEBITO = CQ3_DEBITO + @nCTX_DEBITO, CQ3_CREDIT = CQ3_CREDIT + @nCTX_CREDIT
             Where R_E_C_N_O_ = @iRecno
            commit tran
            /* ---------------------------------------------------------------
                CT190FLGLP - ATUALIZA FLAG DE LP custos Dia
                --------------------------------------------------------------- */
            if @cCT2_DTLP != ' ' begin
                select @cITEM  = ' '
                select @cCLVL  = ' '
                select @cIdent  = ' '
                select @cTabela = 'CQ3'
                Exec CTB025_##  @cFilial_CQ3, @cTabela, @cIdent, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cCT2_DTLP, @cMOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @OUT_RESULTADO OutPut
            end
            /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0         
            Fetch CUR_CT3 into  @cFILCT2, @cCONTA, @cCUSTO, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
        end
        close CUR_CT3
        deallocate CUR_CT3
	    /* --------------------------------------------------------------------------------------------------------------
		    Gravação CQ2 - Mensal
	        -------------------------------------------------------------------------------------------------------------- */
        select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
        Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut   
	    	   
        If @IN_FILIAL = ' ' select @cCT2FilDe = ' '
        else select @cCT2FilDe = @IN_FILIAL
   
        select @cAux = 'CT2'
        exec XFILIAL_## @cAux, @cCT2FilDe, @cFilial_CT2 OutPut
        
        Declare CUR_CQ3 insensitive cursor for
		    Select CQ3_FILIAL, CQ3_CCUSTO, CQ3_CONTA, CQ3_MOEDA, Substring( CQ3_DATA, 1, 6 ), CQ3_DTLP, CQ3_LP, SUM(CQ3_DEBITO),SUM(CQ3_CREDIT)
		    From CQ3###
		    Where CQ3_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
			    and CQ3_TPSALD = @IN_TPSALDO
			    and ( ( CQ3_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
			    and (CQ3_DATA between @cDataI and @cDataF)
			    and D_E_L_E_T_= ' '
		    Group By CQ3_FILIAL, CQ3_CONTA ,CQ3_CCUSTO, CQ3_MOEDA, Substring( CQ3_DATA, 1, 6 ), CQ3_DTLP, CQ3_LP
		    order by 1,2,3,4,5,6,7
		    for read only
        Open CUR_CQ3
        Fetch CUR_CQ3 into  @cFILCT2, @cCUSTO, @cCONTA, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
	   
        While (@@Fetch_status = 0 ) begin
            select @cAux = 'CQ2'
            exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ2 OutPut

            select @cDataI = @cDATACQ||'01'
            Exec LASTDAY_## @cDataI, @cDataF OutPut
	        
            select @nCTX_DEBITO = @nVALORDeb
            select @nCTX_CREDIT = @nVALORCred
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
	            From CQ2###
                Where CQ2_FILIAL = @cFilial_CQ2
                and CQ2_CONTA  = @cCONTA
                and CQ2_CCUSTO = @cCUSTO
                and CQ2_MOEDA  = @cMOEDA
                and CQ2_DATA   = @cDataF
                and CQ2_TPSALD = @IN_TPSALDO
                and CQ2_LP     = @cCTX_LP
                and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
	            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ2###
	            select @iRecno = @iRecno + 1
	            /*---------------------------------------------------------------
	            Insert no CQ0 - Saldos da conta
	            --------------------------------------------------------------- */
	            select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
	            select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)
	            ##TRATARECNO @iRecno\
                Begin Tran
                Insert into CQ2### ( CQ2_FILIAL, CQ2_CONTA, CQ2_CCUSTO, CQ2_MOEDA, CQ2_DATA, CQ2_TPSALD,  CQ2_SLBASE,   CQ2_DTLP,   CQ2_LP,   CQ2_STATUS,   CQ2_DEBITO,   CQ2_CREDIT,   R_E_C_N_O_ )
                            values( @cFilial_CQ2, @cCONTA,   @cCUSTO,    @cMOEDA,   @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,             0, @iRecno )
	            commit tran
	            ##FIMTRATARECNO
            end
	         /* ---------------------------------------------------------------
	            Update no CQ2 - a partir do CQ3
	            --------------------------------------------------------------- */
            select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
            select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)

            begin tran
			   Update CQ2###
			      set CQ2_DTLP = @cCTX_DTLP,
                   CQ2_DEBITO = CQ2_DEBITO + @nCTX_DEBITO,
			          CQ2_CREDIT = CQ2_CREDIT + @nCTX_CREDIT
             Where R_E_C_N_O_  = @iRecno
            commit tran
            /* --------------------------------------------------------------------------------------------------------------
			    Tratamento para o DB2
		        -------------------------------------------------------------------------------------------------------------- */
		      SELECT @fim_CUR = 0
            Fetch CUR_CQ3 into @cFILCT2, @cCUSTO, @cCONTA, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CQ3
        deallocate CUR_CQ3
    End
    /* ---------------------------------------------------------------
        ATUALIZAR ITEM CONTABIL - CQ4/CQ5 e/ou CLASSE DE VALOR - CQ6/CQ7
        --------------------------------------------------------------- */
    If @IN_LITEM = '1' OR @IN_LCLVL = '1' begin
        EXEC CTB230_## @IN_FILIAL,  @IN_LITEM, @IN_LCLVL, @IN_FILIALATE,  @IN_DATADE, @IN_DATAATE,  @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @OUT_RESULTADO Output
    End
    /* ---------------------------------------------------------------
    ATUALIZAR ENTIDADES GERENCIAIS CQ8/CQ9
    --------------------------------------------------------------- */
    If @IN_LITEM = '1' OR @IN_LCLVL = '1' OR @IN_LCUSTO = '1' begin
        EXEC CTB232_## @IN_FILIAL,  @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @IN_FILIALATE,  @IN_DATADE, @IN_DATAATE,  @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @OUT_RESULTADO Output
    End
    /*---------------------------------------------------------------
        Se a execucao foi OK retorna '1'
        --------------------------------------------------------------- */
    select @OUT_RESULTADO = '1'
end
