/* -----------------------------------------------------------------------------------
   CTB0232a - - Atualizar Saldos base - CQ8, CQ9
   ---------------------------------------------------------------------------------- */
##IF_001({|| cPaisLoc $ 'COL|PER' .And. CtbMovSaldo('CT0',,'05') })
##FIELDP01( 'QL6.QL6_FILIAL' )
Create procedure CTB232A_## (
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
    Procedure       -      Atualizacao de slds Bases - CTU - CQ8/CQ9 desde QL7
    Funcao do Siga  -      Ct190SlBse()
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente
                           @IN_LCUSTO       - Centro de Custo em Uso
                           @IN_LITEM        - Item em uso
                           @IN_LCLVL        - Classe de Valor em uso
                           @IN_FILIALATE    - Filial final do processamento
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alberto Rodriguez	</r>
    Data        :     21/09/2021
    Obs: a variável @iTranCount = 0 será trocada por 'commit tran' no CFGX051 pro SQLSERVER
         e SYBASE
   -------------------------------------------------------------------------------------- */
declare @cFilial_CT2 char('CT2_FILIAL')
declare @cCT2FilDe   char('CT2_FILIAL')
declare @cFILCT2     char('CT2_FILIAL')
declare @cFilial_CQ8 char('CQ8_FILIAL')
declare @cFilial_CQ9 char('CQ9_FILIAL')
declare @cAux        char(03)
declare @iRecno      Integer
declare @nCTX_DEBITO Float
declare @nCTX_CREDIT Float
declare @cCTX_DTLP   Char(08)
declare @cCTX_LP     Char('CQ0_LP')
declare @cCTX_STATUS Char('CQ0_STATUS')
declare @cCTX_SLBASE Char('CQ0_SLBASE')
declare @cDATA       Char(08)
declare @cMOEDA      Char('CQ0_MOEDA')
declare @cCODIGO     Char('CQ8_CODIGO')
declare @nVALORDeb   Float
declare @nVALORCred  Float
declare @cIdent      VarChar(03)
declare @cDataI      Char(08)
declare @cDataF      Char(08)
Declare @iTranCount  Integer --Var.de ajuste para SQLServer e Sybase.-- Será trocada por Commit no CFGX051 após passar pelo Parse
declare @cDATACQ     Char(06)
##IF_001({|| cPaisLoc $ 'COL|PER' .And. CtbMovSaldo("CT0",,"05") })
   Declare @cFilial_QL7 Char('QL7_FILIAL')
   Declare @cENT05      Char('QL6_ENT05')
##ELSE_001
   Declare @cFilial_QL7 Char('CT2_FILIAL')
   Declare @cENT05      Char('CT2_EC05DB')
##ENDIF_001

begin
    select @OUT_RESULTADO = '0'
    If @IN_FILIAL = ' ' select @cCT2FilDe = ' '
    else select @cCT2FilDe = @IN_FILIAL

    select @cAux = 'CT2'
    exec XFILIAL_## @cAux, @cCT2FilDe, @cFilial_CT2 OutPut
    /* ---------------------------------------------------------------
        ATUALIZAR Entidad 05
        --------------------------------------------------------------- */
    select @cIdent = 'CV0'
    select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
    Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
    select @iRecno  = 0

    Declare CUR_QL7 insensitive cursor for
    Select QL7_FILIAL, QL7_ENT05, QL7_MOEDA, QL7_DATA, QL7_DTLP,QL7_LP, SUM(QL7_DEBITO),SUM(QL7_CREDIT)
        From QL7###
    Where QL7_FILIAL between @cFilial_CT2 and @IN_FILIALATE
        and QL7_TPSALD = @IN_TPSALDO
        and ( ( QL7_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
        and (QL7_DATA between @IN_DATADE and @IN_DATAATE )
        and D_E_L_E_T_= ' '
    Group By QL7_FILIAL, QL7_ENT05, QL7_MOEDA, QL7_DATA, QL7_DTLP,QL7_LP
    order by 1, 2, 3, 4, 6
    for read only
    Open CUR_QL7
    Fetch CUR_QL7 into  @cFILCT2, @cENT05, @cMOEDA, @cDATA, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred

    While (@@Fetch_status = 0 ) begin
        select @cAux = 'CQ9'
        exec XFILIAL_## @cAux, @cFILCT2, @cFilial_QL7 OutPut

        select @nCTX_DEBITO = 0
        select @nCTX_CREDIT = 0
        select @cCTX_STATUS = '1'
        select @cCTX_SLBASE = 'S'

        select @nCTX_DEBITO = @nVALORDeb
        select @nCTX_CREDIT = @nVALORCred
        select @cCODIGO = @cENT05

        /* -----------------------------------------------------------------
            Verifica se a linha ja existe no CQ9 (Saldo por entidade ) - DIA
            ----------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
            -------------------------------------------------------------------------------------------------------------- */
        select @iRecno = 0
        ##UNIQUEKEY_START   
        select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
        From CQ9###
        Where CQ9_FILIAL = @cFilial_QL7
            and CQ9_DATA   = @cDATA
            and CQ9_IDENT  = @cIdent
            and CQ9_CODIGO = @cCODIGO
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
            Insert into CQ9### ( CQ9_FILIAL,  CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA, CQ9_TPSALD,  CQ9_SLBASE,   CQ9_DTLP,   CQ9_LP,  CQ9_STATUS,   CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
                        values( @cFilial_QL7, @cIdent,   @cCODIGO,   @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,          0, @iRecno )
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
        Fetch CUR_QL7 into  @cFILCT2, @cENT05, @cMOEDA, @cDATA, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
    end
    close CUR_QL7
    deallocate CUR_QL7
    /* --------------------------------------------------------------------------------------------------------------
        Gravação CQ8 - Mensal
        -------------------------------------------------------------------------------------------------------------- */
    select @cIdent = 'CV0'
    select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
    Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut

    Declare CUR_CV0 insensitive cursor for
        Select CQ9_FILIAL, CQ9_IDENT ,CQ9_CODIGO , CQ9_MOEDA, Substring( CQ9_DATA, 1, 6 ), CQ9_DTLP,CQ9_LP , SUM(CQ9_DEBITO),SUM(CQ9_CREDIT)
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
    Open CUR_CV0
    Fetch CUR_CV0 into  @cFILCT2, @cIdent, @cCODIGO, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred

    While (@@Fetch_status = 0 ) begin
        select @cAux = 'CQ8'
        exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ8 OutPut

        select @cDataI = @cDATACQ||'01'
        Exec LASTDAY_## @cDataI, @cDataF OutPut

        select @nCTX_DEBITO = @nVALORDeb
        select @nCTX_CREDIT = @nVALORCred
        select @cCTX_STATUS = '1'
        select @cCTX_SLBASE = 'S'
        /* ---------------------------------------------------------------
        Verifica se a linha ja existe no CQ8
        --------------------------------------------------------------- */
      /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
            -------------------------------------------------------------------------------------------------------------- */
        select @iRecno = 0
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
            Insert into CQ8### ( CQ8_FILIAL,   CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA, CQ8_TPSALD,  CQ8_SLBASE,  CQ8_DTLP,   CQ8_LP,   CQ8_STATUS,   CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
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
        Fetch CUR_CV0 into  @cFILCT2,@cIdent, @cCODIGO, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
    end
    close CUR_CV0
    deallocate CUR_CV0

    /* ---------------------------------------------------------------
        Se a execucao foi OK retorna '1'
        --------------------------------------------------------------- */
    select @OUT_RESULTADO = '1'
end
##ENDFIELDP01
##ENDIF_001
