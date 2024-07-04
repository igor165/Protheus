Create procedure CTB232_## ( 
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
   @OUT_RESULTADO   Char(01) OutPut )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P.12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Descricao       - <d>  Reprocessamento SigaCTB </d>
    Procedure       -      Atualizacao de slds Bases - CTU - CQ8/CQ9
    Funcao do Siga  -      Ct190SlBse()
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente
						   @@IN_LCUSTO      - Centro de Custo em Uso
                           @IN_LITEM        - Item em uso
                           @IN_LCLVL        - Classe de Valor em uso
                           @IN_FILIALATE    - Filial final do processamento
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alvaro Camillo Neto	</r>
    Data        :     22/04/2014
    Obs: a variável @iTranCount = 0 será trocada por 'commit tran' no CFGX051 pro SQLSERVER 
         e SYBASE
   -------------------------------------------------------------------------------------- */
declare @cFilial_CT2 char('CT2_FILIAL')
declare @cCT2FilDe   char('CT2_FILIAL')
declare @cFILCT2     char('CT2_FILIAL')
declare @cFilial_CQ2 char('CQ4_FILIAL')
declare @cFilial_CQ3 char('CQ5_FILIAL')
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
declare @cCODIGO     Char('CQ8_CODIGO')
declare @nVALORDeb   Float
declare @nVALORCred  Float
declare @cIdent      VarChar(03)
declare @cDataI      Char(08)
declare @cDataF      Char(08)
Declare @iTranCount  Integer --Var.de ajuste para SQLServer e Sybase.-- Será trocada por Commit no CFGX051 após passar pelo Parse
Declare @cDATACQ     Char(06)

begin
    select @OUT_RESULTADO = '0'
    select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'   
    Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
   
    If @IN_FILIAL = ' ' select @cCT2FilDe = ' '
    else select @cCT2FilDe = @IN_FILIAL
    
    select @cAux = 'CT2'
    exec XFILIAL_## @cAux, @cCT2FilDe, @cFilial_CT2 OutPut
    /* ---------------------------------------------------------------
        ATUALIZAR Centro de CustO
        --------------------------------------------------------------- */
    If @IN_LCUSTO = '1' begin
        select @cIdent = 'CTT'
        select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'   
        Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
        select @iRecno  = 0
      
        Declare CUR_CQ3 insensitive cursor for
         Select CQ3_FILIAL, CQ3_CCUSTO, CQ3_MOEDA, CQ3_DATA, CQ3_DTLP, CQ3_LP, SUM(CQ3_DEBITO), SUM(CQ3_CREDIT)
           From CQ3###
          Where CQ3_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
            and CQ3_TPSALD = @IN_TPSALDO
            and ( ( CQ3_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
            and (CQ3_DATA between @IN_DATADE and @IN_DATAATE)
            and D_E_L_E_T_= ' '
         Group By CQ3_FILIAL, CQ3_CCUSTO, CQ3_MOEDA, CQ3_DATA, CQ3_DTLP, CQ3_LP
        order by 1, 2, 3, 4, 6
        for read only
        Open CUR_CQ3
        Fetch CUR_CQ3 into  @cFILCT2, @cCUSTO, @cMOEDA, @cDATA, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        
        While (@@Fetch_status = 0 ) begin
            select @cAux = 'CQ9'
            exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ9 OutPut
            
            select @nCTX_DEBITO = 0
            select @nCTX_CREDIT = 0
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'
            
            select @nCTX_DEBITO = @nVALORDeb
            select @nCTX_CREDIT = @nVALORCred
            /* -----------------------------------------------------------------
               Verifica se a linha ja existe no CQ9 (Saldo por entidade ) - DIA
               ----------------------------------------------------------------- */      
            /* ---------------------------------------------------------------
               As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
               houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
               após a MsParse() devolver o código na linguagem do banco em uso.
               -------------------------------------------------------------------------------------------------------------- */
            select @iRecno  = 0
            ##UNIQUEKEY_START 
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ9###
             Where CQ9_FILIAL = @cFilial_CQ9
               and CQ9_DATA   = @cDATA
               and CQ9_IDENT  = @cIdent
               and CQ9_CODIGO = @cCUSTO
               and CQ9_MOEDA  = @cMOEDA
               and CQ9_TPSALD = @IN_TPSALDO
               and CQ9_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ9###
                select @iRecno = @iRecno + 1
                /*---------------------------------------------------------------
                    Insert no CQ9 - Saldos poe entidades Dia
                    --------------------------------------------------------------- */
                ##TRATARECNO @iRecno\    
                begin tran
                Insert into CQ9### ( CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA, CQ9_TPSALD,  CQ9_SLBASE,   CQ9_DTLP,   CQ9_LP,   CQ9_STATUS,   CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
                             values( @cFilial_CQ9, @cIdent,   @cCUSTO,    @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,          0,          0, @iRecno )
                commit tran 
                ##FIMTRATARECNO
            end
            /*---------------------------------------------------------------
                Update no CQ9 - Saldos por entidade DIA
                --------------------------------------------------------------- */
            Begin tran
            Update CQ9###
               set CQ9_DEBITO = CQ9_DEBITO + @nVALORDeb,
                   CQ9_CREDIT = CQ9_CREDIT + @nVALORCred
             Where R_E_C_N_O_ = @iRecno
            Commit Tran
           /* -----------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CQ3 into  @cFILCT2, @cCUSTO, @cMOEDA, @cDATA, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CQ3
        deallocate CUR_CQ3
        /* --------------------------------------------------------------------------------------------------------------
	        Gravação CQ8 - Mensal
	        -------------------------------------------------------------------------------------------------------------- */
        select @cIdent = 'CTT'
        select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'   
        Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut	   
      
        Declare CUR_CTT insensitive cursor for
	     Select CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, Substring( CQ9_DATA, 1, 6 ), CQ9_DTLP, CQ9_LP, SUM(CQ9_DEBITO), SUM(CQ9_CREDIT)
	       From CQ9###
          Where CQ9_FILIAL between @cFilial_CT2 and @IN_FILIALATE
            and CQ9_IDENT  = @cIdent
		    and CQ9_TPSALD = @IN_TPSALDO
		    and ( ( CQ9_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
		    and (CQ9_DATA between @cDataI and @cDataF)
		    and D_E_L_E_T_= ' '
	     Group By CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, Substring( CQ9_DATA, 1, 6 ), CQ9_DTLP, CQ9_LP
	     order by 1,2,3,4,5,7
	    for read only
        Open CUR_CTT
        Fetch CUR_CTT into  @cFILCT2, @cIdent, @cCODIGO, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
	   
        While (@@Fetch_status = 0 ) begin
           
	        select @cAux = 'CQ8'
	        exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ8 OutPut
	        select @cDataI = @cDATACQ||'01'
	        Exec LASTDAY_## @cDataI, @cDataF OutPut
	      
	        select @nCTX_DEBITO = @nVALORDeb
	        select @nCTX_CREDIT = @nVALORCred
	        select @cCTX_STATUS = '1'
	        select @cCTX_SLBASE = 'S'
	        /*---------------------------------------------------------------
	        Verifica se a linha ja existe no CQ86
	        --------------------------------------------------------------- */           
            /* ---------------------------------------------------------------
               As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
               houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
               após a MsParse() devolver o código na linguagem do banco em uso.
               -------------------------------------------------------------------------------------------------------------- */
            select @iRecno  = 0
            ##UNIQUEKEY_START
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ8###
             Where CQ8_FILIAL = @cFilial_CQ8
               and CQ8_IDENT  = @cIdent
               and CQ8_CODIGO = @cCODIGO
               and CQ8_MOEDA  = @cMOEDA
               and CQ8_DATA   = @cDataF
               and CQ8_TPSALD = @IN_TPSALDO
               and CQ8_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
	            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ8###
	            select @iRecno = @iRecno + 1
	            /*---------------------------------------------------------------
	            Insert no CQ8 
	            --------------------------------------------------------------- */
	            select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
	            select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)
	            ##TRATARECNO @iRecno\
                begin tran
	            Insert into CQ8### ( CQ8_FILIAL, CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA, CQ8_TPSALD,  CQ8_SLBASE,   CQ8_DTLP,   CQ8_LP, CQ8_STATUS,   CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
                           values( @cFilial_CQ8, @cIdent,   @cCODIGO,   @cMOEDA,   @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,        0,          0, @iRecno )
 		        commit tran
	            ##FIMTRATARECNO
            end
	        /*---------------------------------------------------------------
	        Update no CQ8
	        --------------------------------------------------------------- */
	        select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
	        select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)
            Begin tran
	        Update CQ8###
		       set CQ8_DTLP    = @cCTX_DTLP,
                   CQ8_DEBITO  = CQ8_DEBITO + @nCTX_DEBITO,
		           CQ8_CREDIT  = CQ8_CREDIT + @nCTX_CREDIT
             where R_E_C_N_O_ = @iRecno
            commit tran
            /* --------------------------------------------------------------------------------------------------------------
		        Tratamento para o DB2
	        -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CTT into  @cFILCT2, @cIdent, @cCODIGO, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CTT
        deallocate CUR_CTT
    End
    /* ---------------------------------------------------------------
        ATUALIZAR Item
        --------------------------------------------------------------- */
    If @IN_LITEM = '1' begin
        select @cIdent = 'CTD'
        select @iRecno  = 0
        select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'   
        Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut	   
      
        Declare CUR_CQ5 insensitive cursor for
         Select CQ5_FILIAL, CQ5_ITEM, CQ5_MOEDA, CQ5_DATA, CQ5_DTLP, CQ5_LP, SUM(CQ5_DEBITO), SUM(CQ5_CREDIT)
           From CQ5###
          Where CQ5_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
            and CQ5_TPSALD = @IN_TPSALDO
            and ( ( CQ5_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
            and (CQ5_DATA between @IN_DATADE and @IN_DATAATE )
            and D_E_L_E_T_= ' '
         Group By CQ5_FILIAL, CQ5_ITEM, CQ5_MOEDA, CQ5_DATA, CQ5_DTLP, CQ5_LP
         order by 1, 2, 3, 4, 6
        for read only
        Open CUR_CQ5
        Fetch CUR_CQ5 into  @cFILCT2, @cITEM, @cMOEDA, @cDATA, @cCT2_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        
        While (@@Fetch_status = 0 ) begin
            select @cAux = 'CQ9'
            exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ9 OutPut
               
            select @nCTX_DEBITO = 0
            select @nCTX_CREDIT = 0
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'
            select @cCTX_DTLP   = @cCT2_DTLP

            select @nCTX_DEBITO = @nVALORDeb
            select @nCTX_CREDIT = @nVALORCred
            /* -----------------------------------------------------------------
               Verifica se a linha ja existe no CQ9 (Saldo por entidade ) - DIA
               ----------------------------------------------------------------- */      
            /* ---------------------------------------------------------------
               As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
               houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
               após a MsParse() devolver o código na linguagem do banco em uso.
               -------------------------------------------------------------------------------------------------------------- */
            select @iRecno  = 0
            ##UNIQUEKEY_START
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ9###
             Where CQ9_FILIAL = @cFilial_CQ9
               and CQ9_DATA   = @cDATA
               and CQ9_IDENT  = @cIdent
               and CQ9_CODIGO = @cITEM
               and CQ9_MOEDA  = @cMOEDA
               and CQ9_TPSALD = @IN_TPSALDO
               and CQ9_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
		    
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ9###
                select @iRecno = @iRecno + 1
                /*---------------------------------------------------------------
                    Insert no CQ9 - Saldos poe entidades Dia
                    --------------------------------------------------------------- */
                ##TRATARECNO @iRecno\
                begin tran
                Insert into CQ9### ( CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA, CQ9_TPSALD,  CQ9_SLBASE,   CQ9_DTLP,   CQ9_LP,   CQ9_STATUS,   CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
                             values( @cFilial_CQ9, @cIdent,   @cITEM,     @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,          0,          0, @iRecno )
                commit tran
                ##FIMTRATARECNO
            end
            /*---------------------------------------------------------------
                Update no CQ9 - Saldos por entidade DIA
                --------------------------------------------------------------- */
            Begin tran
            Update CQ9###
                set CQ9_DEBITO = CQ9_DEBITO + @nVALORDeb ,
                    CQ9_CREDIT = CQ9_CREDIT + @nVALORCred
                Where R_E_C_N_O_ = @iRecno
            Commit Tran
            /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CQ5 into  @cFILCT2, @cITEM, @cMOEDA, @cDATA, @cCT2_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CQ5
        deallocate CUR_CQ5
	    /* --------------------------------------------------------------------------------------------------------------
		    Gravação CQ8 - Mensal
	    -------------------------------------------------------------------------------------------------------------- */
 	    select @cIdent = 'CTD'
	    select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
	    Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut   
	    
	    If @IN_FILIAL = ' ' select @cCT2FilDe = ' '
	    else select @cCT2FilDe = @IN_FILIAL
	    
	    select @cAux = 'CT2'
	    exec XFILIAL_## @cAux, @cCT2FilDe, @cFilial_CT2 OutPut
	    
	    Declare CUR_CTD insensitive cursor for
		 Select CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, Substring( CQ9_DATA, 1, 6 ), CQ9_DTLP, CQ9_LP, SUM(CQ9_DEBITO), SUM(CQ9_CREDIT)
		   From CQ9###
          Where CQ9_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
            and CQ9_IDENT = @cIdent
		    and CQ9_TPSALD = @IN_TPSALDO
		    and ( ( CQ9_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
		    and (CQ9_DATA between @cDataI and @cDataF)
		    and D_E_L_E_T_= ' '
		 Group By CQ9_FILIAL, CQ9_IDENT ,CQ9_CODIGO , CQ9_MOEDA, Substring( CQ9_DATA, 1, 6 ), CQ9_DTLP, CQ9_LP
		 order by 1,2,3,4,5,7
		for read only
	    Open CUR_CTD
	    Fetch CUR_CTD into  @cFILCT2, @cIdent, @cCODIGO, @cMOEDA, @cDATACQ, @cCT2_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
	    
        While (@@Fetch_status = 0 ) begin
	        
            select @cAux = 'CQ8'
            exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ8 OutPut
            
            select @cDataI = @cDATACQ||'01'
            Exec LASTDAY_## @cDataI, @cDataF OutPut
	        
            select @nCTX_DEBITO = @nVALORDeb
            select @nCTX_CREDIT = @nVALORCred
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'
            select @cCTX_DTLP   = @cCT2_DTLP
		    /* ---------------------------------------------------------------
			    Verifica se a linha ja existe no CQ8
			    --------------------------------------------------------------- */
            /* ---------------------------------------------------------------
               As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
               houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
               após a MsParse() devolver o código na linguagem do banco em uso.
               -------------------------------------------------------------------------------------------------------------- */
            select @iRecno  = 0
            ##UNIQUEKEY_START
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ8###
             Where CQ8_FILIAL = @cFilial_CQ8
               and CQ8_IDENT  = @cIdent
               and CQ8_CODIGO = @cCODIGO
               and CQ8_MOEDA  = @cMOEDA
               and CQ8_DATA   = @cDataF
               and CQ8_TPSALD = @IN_TPSALDO
               and CQ8_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
                        
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ8###
                select @iRecno = @iRecno + 1
                /*---------------------------------------------------------------
                Insert no CQ8 
                --------------------------------------------------------------- */
                select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
                select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)
                ##TRATARECNO @iRecno\
                begin tran
                Insert into CQ8### ( CQ8_FILIAL,   CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA, CQ8_TPSALD,  CQ8_SLBASE,   CQ8_DTLP,   CQ8_LP,   CQ8_STATUS,   CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
                             values( @cFilial_CQ8, @cIdent,   @cCODIGO,   @cMOEDA,   @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,          0,          0, @iRecno )
 		        commit tran
                ##FIMTRATARECNO
            end
            /* ---------------------------------------------------------------
                Update no CQ8
                --------------------------------------------------------------- */
            select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
            select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)
            begin tran
		    Update CQ8###
               set CQ8_DTLP    = @cCTX_DTLP,
                   CQ8_DEBITO  = CQ8_DEBITO + @nCTX_DEBITO,
                   CQ8_CREDIT  = CQ8_CREDIT + @nCTX_CREDIT
             Where R_E_C_N_O_ = @iRecno
            commit tran
		    /* --------------------------------------------------------------------------------------------------------------
			    Tratamento para o DB2
		        -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CTD into  @cFILCT2,@cIdent, @cCODIGO, @cMOEDA, @cDATACQ, @cCT2_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
	    close CUR_CTD
	    deallocate CUR_CTD
    End
    /* ---------------------------------------------------------------
        ATUALIZAR Classe de Valor
        --------------------------------------------------------------- */
    If @IN_LCLVL = '1' begin
        select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
        
        select @cIdent = 'CTH'
        Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
        
        Declare CUR_CQ7 insensitive cursor for
        Select CQ7_FILIAL, CQ7_CLVL , CQ7_MOEDA, CQ7_DATA, CQ7_LP, CQ7_DTLP, SUM(CQ7_DEBITO), SUM(CQ7_CREDIT)
        From CQ7###
        Where CQ7_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
            and CQ7_TPSALD = @IN_TPSALDO
            and ( ( CQ7_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
            and (CQ7_DATA between @IN_DATADE and @IN_DATAATE )
            and D_E_L_E_T_= ' '
        Group By CQ7_FILIAL, CQ7_CLVL , CQ7_MOEDA, CQ7_DATA, CQ7_LP, CQ7_DTLP
        order by 1, 2, 3, 4, 5
        for read only
        Open CUR_CQ7
        Fetch CUR_CQ7 into  @cFILCT2, @cCLVL, @cMOEDA, @cDATA, @cCTX_LP, @cCT2_DTLP,@nVALORDeb, @nVALORCred
      
        While (@@Fetch_status = 0 ) begin
            select @cAux = 'CQ9'
            exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ9 OutPut
               
            select @nCTX_DEBITO = 0
            select @nCTX_CREDIT = 0
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'
            select @cCTX_DTLP   = @cCT2_DTLP
         
            select @nCTX_DEBITO = @nVALORDeb
            select @nCTX_CREDIT = @nVALORCred
            /* -----------------------------------------------------------------
            Verifica se a linha ja existe no CQ9 (Saldo por entidade ) - DIA
            ----------------------------------------------------------------- */      
            /* ---------------------------------------------------------------
               As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
               houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
               após a MsParse() devolver o código na linguagem do banco em uso.
               -------------------------------------------------------------------------------------------------------------- */
            select @iRecno  = 0
            ##UNIQUEKEY_START
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ9###
             Where CQ9_FILIAL = @cFilial_CQ9
               and CQ9_DATA   = @cDATA
               and CQ9_IDENT  = @cIdent
               and CQ9_CODIGO = @cCLVL
               and CQ9_MOEDA  = @cMOEDA
               and CQ9_TPSALD = @IN_TPSALDO
               and CQ9_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
         
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ9###
                select @iRecno = @iRecno + 1
                /*---------------------------------------------------------------
                    Insert no CQ9 - Saldos poe entidades Dia
                    --------------------------------------------------------------- */
                ##TRATARECNO @iRecno\
                begin tran
                Insert into CQ9### ( CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA, CQ9_TPSALD,  CQ9_SLBASE,   CQ9_DTLP,   CQ9_LP,   CQ9_STATUS,   CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
                             values( @cFilial_CQ9, @cIdent,   @cCLVL,     @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,          0,          0, @iRecno )
                commit tran
                ##FIMTRATARECNO
            end
            /*---------------------------------------------------------------
                Update no CQ9 - Saldos por entidade DIA
                --------------------------------------------------------------- */
            begin tran
            Update CQ9###
                set CQ9_DEBITO = CQ9_DEBITO + @nVALORDeb ,
                    CQ9_CREDIT = CQ9_CREDIT + @nVALORCred
                Where R_E_C_N_O_ = @iRecno
            commit tran
            /* --------------------------------------------------------------------------------------------------------------
               Tratamento para o DB2
               -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CQ7 into  @cFILCT2, @cCLVL, @cMOEDA, @cDATA, @cCTX_LP, @cCT2_DTLP, @nVALORDeb, @nVALORCred
        end
        close CUR_CQ7
        deallocate CUR_CQ7
        /* --------------------------------------------------------------------------------------------------------------
		    Gravação CQ8 - Mensal
	        -------------------------------------------------------------------------------------------------------------- */
	    select @cIdent = 'CTH'
	    select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
	    Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut   
	   
	    If @IN_FILIAL = ' ' select @cCT2FilDe = ' '
	    else select @cCT2FilDe = @IN_FILIAL
	   
	    select @cAux = 'CT2'
	    exec XFILIAL_## @cAux, @cCT2FilDe, @cFilial_CT2 OutPut
	    
	    Declare CUR_CTH insensitive cursor for
         Select CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, Substring( CQ9_DATA, 1, 6 ), CQ9_DTLP, CQ9_LP, SUM(CQ9_DEBITO), SUM(CQ9_CREDIT)
           From CQ9###
          Where CQ9_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
            and CQ9_IDENT = @cIdent
            and CQ9_TPSALD = @IN_TPSALDO
            and ( ( CQ9_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
            and (CQ9_DATA between @IN_DATADE and @IN_DATAATE)
            and D_E_L_E_T_= ' '
		 Group By CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, Substring( CQ9_DATA, 1, 6 ), CQ9_DTLP, CQ9_LP
		 order by 1,2,3,4,5,7
		for read only
	    Open CUR_CTH
	    Fetch CUR_CTH into @cFILCT2, @cIdent, @cCODIGO, @cMOEDA, @cDATACQ, @cCT2_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        
	    While (@@Fetch_status = 0 ) begin
            
            select @cAux = 'CQ8'
            exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ8 OutPut
            
            select @cDataI = @cDATACQ||'01'
            Exec LASTDAY_## @cDataI, @cDataF OutPut
	        
            select @nCTX_DEBITO = @nVALORDeb
            select @nCTX_CREDIT = @nVALORCred
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'
            select @cCTX_DTLP   = @cCT2_DTLP
		    /* ---------------------------------------------------------------
               Verifica se a linha ja existe no CQ8                           
		       --------------------------------------------------------------- */
            /* ---------------------------------------------------------------
               As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
               houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
               após a MsParse() devolver o código na linguagem do banco em uso.
               -------------------------------------------------------------------------------------------------------------- */
            select @iRecno  = 0
            ##UNIQUEKEY_START
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ8###
             Where CQ8_FILIAL = @cFilial_CQ8
               and CQ8_IDENT  = @cIdent
               and CQ8_CODIGO = @cCODIGO
               and CQ8_MOEDA  = @cMOEDA
               and CQ8_DATA   = @cDataF
               and CQ8_TPSALD = @IN_TPSALDO
               and CQ8_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
	            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ8###
	            select @iRecno = @iRecno + 1
	            /*---------------------------------------------------------------
	            Insert no CQ8 
	            --------------------------------------------------------------- */
	            select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
	            select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)
	            ##TRATARECNO @iRecno\
                begin tran
	            Insert into CQ8### ( CQ8_FILIAL,  CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA, CQ8_TPSALD,  CQ8_SLBASE,   CQ8_DTLP,   CQ8_LP,   CQ8_STATUS,   CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
                            values( @cFilial_CQ8, @cIdent,   @cCODIGO,   @cMOEDA,   @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,           0,          0, @iRecno )
 		        commit tran
	            ##FIMTRATARECNO
            end
            /* ---------------------------------------------------------------
	            Update no CQ8
	            --------------------------------------------------------------- */
            select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
	        select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)
            begin tran
	        Update CQ8###
		        set CQ8_DTLP    = @cCTX_DTLP,
                    CQ8_DEBITO  = CQ8_DEBITO + @nCTX_DEBITO,
                    CQ8_CREDIT  = CQ8_CREDIT + @nCTX_CREDIT
		        Where R_E_C_N_O_ = @iRecno
            commit tran
            /* --------------------------------------------------------------------------------------------------------------
	            Tratamento para o DB2
               -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CTH into @cFILCT2, @cIdent, @cCODIGO, @cMOEDA, @cDATACQ, @cCT2_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
	    close CUR_CTH
        deallocate CUR_CTH 
    End
    /* ---------------------------------------------------------------
        Se a execucao foi OK retorna '1'
        --------------------------------------------------------------- */
    select @OUT_RESULTADO = '1'
end
