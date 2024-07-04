Create procedure CTB242_##
( 
   @IN_FILDE        Char( 'CT2_FILIAL' ),
   @IN_FILATE       Char( 'CT2_FILIAL' ),
   @IN_DATADE       Char( 08 ),
   @IN_DATAATE      Char( 08 ),
   @IN_LMOEDAESP    Char( 01 ),
   @IN_MOEDA        Char( 'CT7_MOEDA' ),
   @IN_TPSALDO      Char( 'CT2_TPSALD' ),
   @IN_MVSOMA       Char( 01 ),
   @IN_LCUSTO       Char( 01 ),
   @IN_LITEM        Char( 01 ),
   @IN_LCLVL        Char( 01 ),
   @IN_CONTADE      Char( 'CQ0_CONTA' ),
   @IN_CONTAATE     Char( 'CQ0_CONTA' ),
   @OUT_RESULTADO   Char( 01 ) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Refaz saldos CQ8 CQ9/d>
    Funcao do Siga  -      Ct190DOC() - Refaz saldos de documento não trata total informado
    Entrada         - <ri> @IN_FILIALCOR    - Filial Corrente
                           @IN_FILIALATE    - Filial final do processamento
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_MVSOMA       - Soma 2 vezes
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     31/03/2014

      +--> CTB242 - Atualiza CQ8, CQ9   
      
   Obs: esta procedure CTB240, faz as atualizações dos documentos e dos CQ8/CQ9  ests não podem
      ser atualizadas em threads. E chamada após a execução CTB165
  -------------------------------------------------------------------------------------- */
declare @cDataI  Char( 08 )
declare @cDataF  Char( 08 )
Declare @cAux    Char( 03 )
Declare @cFilial_CQ3 char( 'CQ3_FILIAL' )
Declare @cFilial_CQ5 char( 'CQ5_FILIAL' )
Declare @cFilial_CQ7 char( 'CQ7_FILIAL' )
Declare @cFilial_CQ8 char( 'CQ8_FILIAL' )
Declare @cFilial_CQ9 char( 'CQ9_FILIAL' )
Declare @cFILCQX     char( 'CQ3_FILIAL' )
Declare @cCUSTO      char( 'CQ3_CCUSTO' )
Declare @cITEM       char( 'CQ4_ITEM' )
Declare @cCLVL       char( 'CQ6_CLVL' )
Declare @cMOEDA      char( 'CQ3_MOEDA' )
Declare @cDATA       char( 'CQ3_DATA' )
Declare @cCQX_DTLP   char( 08 )
Declare @cCQX_LP     char( 01 )
Declare @cSLBASE     char( 01 )
Declare @cSTATUS     char( 01 )
Declare @nDEBITO     float
Declare @nCREDIT     float
declare @iRecno      integer

begin
   
   select @OUT_RESULTADO = '0'
   
   select @cDataI  = SUBSTRING( @IN_DATADE, 1, 6)||'01'
   /* ----------------------------------------------------------------
      Retorna ultimo dia do mes
      ----------------------------------------------------------------- */
   Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
   
   select @cSLBASE = 'S'
   select @cSTATUS = '1'
   
   If @IN_LCUSTO = '1' begin
      /* ----------------------------------------------------------------
         Retorna Filial
         ----------------------------------------------------------------- */      
      select @cAux = 'CQ3'
      exec XFILIAL_## @cAux, @IN_FILDE, @cFilial_CQ3 OutPut
      
      Declare CUR_CQ3 insensitive cursor for
      select CQ3_FILIAL, CQ3_CCUSTO, CQ3_MOEDA, CQ3_DATA, CQ3_DTLP, CQ3_LP, Sum( CQ3_DEBITO ), sum( CQ3_CREDIT )
        From CQ3###
       Where CQ3_FILIAL  between @cFilial_CQ3 and @IN_FILATE
         and CQ3_CONTA   between @IN_CONTADE and @IN_CONTAATE
         and CQ3_DATA    between @cDataI and @cDataF
         and CQ3_TPSALD  = @IN_TPSALDO
         and (( CQ3_MOEDA  = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0' )
         and D_E_L_E_T_ = ' '
      GROUP BY CQ3_FILIAL, CQ3_CCUSTO, CQ3_MOEDA, CQ3_DATA, CQ3_DTLP, CQ3_LP
      order by 1, 2,3,4,5
     for read only
      Open CUR_CQ3
      Fetch CUR_CQ3 into @cFILCQX, @cCUSTO, @cMOEDA, @cDATA, @cCQX_DTLP, @cCQX_LP, @nDEBITO, @nCREDIT
      
      While (@@Fetch_status = 0 ) begin
         /* ----------------------------------------------------------------
            Retorna Filial
            ----------------------------------------------------------------- */
         select @cAux = 'CQ9'
         exec XFILIAL_## @cAux, @cFILCQX, @cFilial_CQ9 OutPut
         select @cAux = 'CQ8'
         exec XFILIAL_## @cAux, @cFILCQX, @cFilial_CQ8 OutPut
         Exec LASTDAY_## @cDATA, @cDataF OutPut
         /* ----------------------------------------------------------------
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
            and CQ9_TPSALD = @IN_TPSALDO
            and CQ9_LP     = @cCQX_LP
            and CQ9_DTLP   = @cCQX_DTLP
  	           and D_E_L_E_T_ 	= ' '
            ##UNIQUEKEY_END            
            
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ9###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ9 - Saldos poe entidades Dia
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            Begin Tran
            Insert into CQ9### ( CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA, CQ9_TPSALD,  CQ9_SLBASE, CQ9_DTLP,   CQ9_LP,   CQ9_STATUS, CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
							    values( @cFilial_CQ9, 'CTT',     @cCUSTO,    @cMOEDA,   @cDATA,   @IN_TPSALDO, @cSLBASE,   @cCQX_DTLP, @cCQX_LP, @cSTATUS,   0,   0,   @iRecno )
            commit tran
            ##FIMTRATARECNO
		    end
            /*---------------------------------------------------------------
              Update no CQ9 - Saldos por entidade DIA
              --------------------------------------------------------------- */
            Begin Tran
            Update CQ9###
               set CQ9_DEBITO = CQ9_DEBITO + @nDEBITO, CQ9_CREDIT  = CQ9_CREDIT + @nCREDIT
             Where R_E_C_N_O_ = @iRecno
            commit tran
         /* ----------------------------------------------------------------
            Verifica se a linha ja existe no CQ8 (Saldo por entidade ) - MES
            ----------------------------------------------------------------- */      
         select @iRecno  = 0
            ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ8###
          Where CQ8_FILIAL = @cFilial_CQ8
            and CQ8_DATA   = @cDataF
            and CQ8_IDENT  = 'CTT'
            and CQ8_CODIGO = @cCUSTO
            and CQ8_MOEDA  = @cMOEDA
            and CQ8_TPSALD = @IN_TPSALDO
            and CQ8_LP     = @cCQX_LP
            and CQ8_DTLP   = @cCQX_DTLP
               and D_E_L_E_T_ 	= ' '
		    ##UNIQUEKEY_END
            
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ8###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ9 - Saldos poe entidades Dia
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            Begin Tran
            Insert into CQ8### ( CQ8_FILIAL,   CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA, CQ8_TPSALD,  CQ8_SLBASE, CQ8_DTLP,   CQ8_LP,   CQ8_STATUS, CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
							    values( @cFilial_CQ8, 'CTT',     @cCUSTO,    @cMOEDA,   @cDataF,  @IN_TPSALDO, @cSLBASE,   @cCQX_DTLP, @cCQX_LP, @cSTATUS,   0,   0,   @iRecno )
            commit tran
            ##FIMTRATARECNO
			
		    end

		    /* ------------------------------------------------------------
		    UPDATE no CQ8
		    ------------------------------------------------------------*/
            Begin Tran
            Update CQ8###
				    set CQ8_DEBITO = CQ8_DEBITO + @nDEBITO, CQ8_CREDIT = CQ8_CREDIT + @nCREDIT
			    where R_E_C_N_O_ =  @iRecno 
            commit tran
            
         Fetch CUR_CQ3 into  @cFILCQX, @cCUSTO, @cMOEDA, @cDATA, @cCQX_DTLP, @cCQX_LP, @nDEBITO, @nCREDIT
      End
      close CUR_CQ3
      deallocate CUR_CQ3 
   End
   /* ----------------------------------------------------------------
      ITEM - Atualiza saldos de entidades ITEM
      ----------------------------------------------------------------- */
   If @IN_LITEM = '1' begin
      Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
      /* ----------------------------------------------------------------
         Retorna Filial
         ----------------------------------------------------------------- */      
      select @cAux = 'CQ5'
      exec XFILIAL_## @cAux, @IN_FILDE, @cFilial_CQ5 OutPut
      
      Declare CUR_CQ5 insensitive cursor for
      select CQ5_FILIAL, CQ5_ITEM, CQ5_MOEDA, CQ5_DATA, CQ5_DTLP, CQ5_LP, Sum( CQ5_DEBITO ), sum( CQ5_CREDIT )
        From CQ5###
       Where CQ5_FILIAL  between  @cFilial_CQ5 and @IN_FILATE
         and CQ5_CONTA   between @IN_CONTADE and @IN_CONTAATE
         and CQ5_DATA    between @cDataI and @cDataF
         and CQ5_TPSALD = @IN_TPSALDO
         and (( CQ5_MOEDA  = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0' )
         and D_E_L_E_T_ = ' '
      GROUP BY CQ5_FILIAL, CQ5_ITEM, CQ5_MOEDA, CQ5_DATA, CQ5_DTLP, CQ5_LP
      order by 1, 2,3,4,5,6
     for read only
      Open CUR_CQ5
      Fetch CUR_CQ5 into @cFILCQX, @cITEM, @cMOEDA, @cDATA, @cCQX_DTLP, @cCQX_LP, @nDEBITO, @nCREDIT
      
      While (@@Fetch_status = 0 ) begin
         /* ----------------------------------------------------------------
            Retorna Filial
            ----------------------------------------------------------------- */
         select @cAux = 'CQ9'
         exec XFILIAL_## @cAux, @cFILCQX, @cFilial_CQ9 OutPut
         select @cAux = 'CQ8'
         exec XFILIAL_## @cAux, @cFILCQX, @cFilial_CQ8 OutPut
         Exec LASTDAY_## @cDATA, @cDataF OutPut
         /* ----------------------------------------------------------------
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
            and CQ9_TPSALD = @IN_TPSALDO
            and CQ9_LP     = @cCQX_LP
            and CQ9_DTLP   = @cCQX_DTLP
               and D_E_L_E_T_ 	= ' '
            ##UNIQUEKEY_END
            
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ9###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ9 - Saldos poe entidades Dia
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            Begin Tran
			    Insert into CQ9### ( CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA, CQ9_TPSALD,  CQ9_SLBASE, CQ9_DTLP,   CQ9_LP,   CQ9_STATUS, CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
							    values( @cFilial_CQ9, 'CTD',     @cITEM,    @cMOEDA,   @cDATA,   @IN_TPSALDO, @cSLBASE,   @cCQX_DTLP, @cCQX_LP, @cSTATUS,   0,   0,   @iRecno )
            commit tran
            ##FIMTRATARECNO
		    end
            /*---------------------------------------------------------------
              Update no CQ9 - Saldos por entidade DIA
              --------------------------------------------------------------- */
            Begin Tran
            Update CQ9###
               set CQ9_DEBITO = CQ9_DEBITO + @nDEBITO, CQ9_CREDIT  = CQ9_CREDIT + @nCREDIT
             Where R_E_C_N_O_ = @iRecno
            commit tran
         /* ----------------------------------------------------------------
            Verifica se a linha ja existe no CQ8 (Saldo por entidade ) - MES
            ----------------------------------------------------------------- */      
         select @iRecno  = 0
            ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ8###
          Where CQ8_FILIAL = @cFilial_CQ8
            and CQ8_DATA   = @cDataF
            and CQ8_IDENT  = 'CTD'
            and CQ8_CODIGO = @cITEM
            and CQ8_MOEDA  = @cMOEDA
            and CQ8_TPSALD = @IN_TPSALDO
            and CQ8_LP     = @cCQX_LP
            and CQ8_DTLP   = @cCQX_DTLP
	        and D_E_L_E_T_ 	= ' '
		    ##UNIQUEKEY_END
            
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ8###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ9 - Saldos poe entidades Dia
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            Begin Tran
            Insert into CQ8### ( CQ8_FILIAL,   CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA, CQ8_TPSALD,  CQ8_SLBASE, CQ8_DTLP,   CQ8_LP,   CQ8_STATUS, CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
							    values( @cFilial_CQ8, 'CTD',     @cITEM,    @cMOEDA,   @cDataF,  @IN_TPSALDO, @cSLBASE,   @cCQX_DTLP, @cCQX_LP, @cSTATUS,   0,   0,   @iRecno )
            commit tran
            ##FIMTRATARECNO
			
		    end
            /*---------------------------------------------------------------
              Update no CQ8 - Saldos por entidade DIA
              --------------------------------------------------------------- */
            Begin Tran
            Update CQ8###
               set CQ8_DEBITO = CQ8_DEBITO + @nDEBITO, CQ8_CREDIT  = CQ8_CREDIT + @nCREDIT
             Where R_E_C_N_O_ = @iRecno
            commit tran

         Fetch CUR_CQ5 into  @cFILCQX, @cITEM, @cMOEDA, @cDATA, @cCQX_DTLP, @cCQX_LP, @nDEBITO, @nCREDIT
      End
      close CUR_CQ5
      deallocate CUR_CQ5
   End
   /* ----------------------------------------------------------------
      CLVL - Atualiza saldos de entidades CLVL
      ----------------------------------------------------------------- */
   If @IN_LCLVL = '1' begin
      Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
      /* ----------------------------------------------------------------
         Retorna Filial
         ----------------------------------------------------------------- */      
      select @cAux = 'CQ7'
      exec XFILIAL_## @cAux, @IN_FILDE, @cFilial_CQ7 OutPut
      
      Declare CUR_CQ7 insensitive cursor for
      select CQ7_FILIAL, CQ7_CLVL, CQ7_MOEDA, CQ7_DATA, CQ7_DTLP, CQ7_LP, Sum( CQ7_DEBITO ), sum( CQ7_CREDIT )
        From CQ7###
       Where CQ7_FILIAL  between  @cFilial_CQ7 and @IN_FILATE
         and CQ7_CONTA   between @IN_CONTADE and @IN_CONTAATE
         and CQ7_DATA    between @cDataI and @cDataF
         and CQ7_TPSALD = @IN_TPSALDO
         and (( CQ7_MOEDA  = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0' )
         and D_E_L_E_T_ = ' '
      GROUP BY CQ7_FILIAL, CQ7_CLVL, CQ7_MOEDA, CQ7_DATA, CQ7_DTLP, CQ7_LP
      order by 1, 2,3,4,5,6
     for read only
      Open CUR_CQ7
      Fetch CUR_CQ7 into @cFILCQX, @cCLVL, @cMOEDA, @cDATA, @cCQX_DTLP, @cCQX_LP, @nDEBITO, @nCREDIT
      
      While (@@Fetch_status = 0 ) begin
         /* ----------------------------------------------------------------
            Retorna Filial
            ----------------------------------------------------------------- */
         select @cAux = 'CQ9'
         exec XFILIAL_## @cAux, @cFILCQX, @cFilial_CQ9 OutPut
         select @cAux = 'CQ8'
         exec XFILIAL_## @cAux, @cFILCQX, @cFilial_CQ8 OutPut
         Exec LASTDAY_## @cDATA, @cDataF OutPut
         /* ----------------------------------------------------------------
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
            and CQ9_TPSALD = @IN_TPSALDO
            and CQ9_LP     = @cCQX_LP
            and CQ9_DTLP   = @cCQX_DTLP
               and D_E_L_E_T_ 	= ' '
            ##UNIQUEKEY_END
            
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ9###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ9 - Saldos poe entidades Dia
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            Begin Tran
			    Insert into CQ9### ( CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA, CQ9_TPSALD,  CQ9_SLBASE, CQ9_DTLP,   CQ9_LP,   CQ9_STATUS, CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
							    values( @cFilial_CQ9, 'CTH',     @cCLVL,    @cMOEDA,   @cDATA,   @IN_TPSALDO, @cSLBASE,   @cCQX_DTLP, @cCQX_LP, @cSTATUS,   0,   0,   @iRecno )
            commit tran
            ##FIMTRATARECNO
		    end
            /*---------------------------------------------------------------
              Update no CQ9 - Saldos por entidade DIA
              --------------------------------------------------------------- */
            Begin Tran
            Update CQ9###
               set CQ9_DEBITO = CQ9_DEBITO + @nDEBITO, CQ9_CREDIT  = CQ9_CREDIT + @nCREDIT
             Where R_E_C_N_O_ = @iRecno
            commit tran
         /* ----------------------------------------------------------------
            Verifica se a linha ja existe no CQ8 (Saldo por entidade ) - MES
            ----------------------------------------------------------------- */      
         select @iRecno  = 0
            ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ8###
          Where CQ8_FILIAL = @cFilial_CQ8
            and CQ8_DATA   = @cDataF
            and CQ8_IDENT  = 'CTH'
            and CQ8_CODIGO = @cCLVL
            and CQ8_MOEDA  = @cMOEDA
            and CQ8_TPSALD = @IN_TPSALDO
            and CQ8_LP     = @cCQX_LP
            and CQ8_DTLP   = @cCQX_DTLP
               and D_E_L_E_T_ 	= ' '
		    ##UNIQUEKEY_END
            
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ8###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ9 - Saldos poe entidades Dia
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            Begin Tran
            Insert into CQ8### ( CQ8_FILIAL,   CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA, CQ8_TPSALD,  CQ8_SLBASE, CQ8_DTLP,   CQ8_LP,   CQ8_STATUS, CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
							    values( @cFilial_CQ8, 'CTH',     @cCLVL,    @cMOEDA,   @cDataF,  @IN_TPSALDO, @cSLBASE,   @cCQX_DTLP, @cCQX_LP, @cSTATUS,   0,   0,   @iRecno )
            commit tran
            ##FIMTRATARECNO
		    end
            /*---------------------------------------------------------------
              Update no CQ8 - Saldos por entidade DIA
              --------------------------------------------------------------- */
            Begin Tran
            Update CQ8###
               set CQ8_DEBITO = CQ8_DEBITO + @nDEBITO, CQ8_CREDIT  = CQ8_CREDIT + @nCREDIT
             Where R_E_C_N_O_ = @iRecno
            commit tran
         Fetch CUR_CQ7 into  @cFILCQX, @cCLVL, @cMOEDA, @cDATA, @cCQX_DTLP, @cCQX_LP, @nDEBITO, @nCREDIT
      End
      close CUR_CQ7
      deallocate CUR_CQ7
   End   
   select @OUT_RESULTADO = '1'
end
