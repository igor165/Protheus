/* -----------------------------------------------------------------------------------
   CTB021a - CLocalización COL/PER - Zera Saldos - QL6, QL7
   ---------------------------------------------------------------------------------- */
##IF_001({|| cPaisLoc $ 'COL|PER' .And. CtbMovSaldo('CT0',,'05') })
##FIELDP01( 'QL6.QL6_FILIAL' )
Create procedure CTB021A_## (
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
                           @IN_EMPANT       - Empresa
                           @IN_FILANT       - Sucursal
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alberto Rodriguez	</r>
    Data        :     22/09/2021
    Obs: a variável @iTranCount = 0 será trocada por 'commit tran' no CFGX051 pro SQLSERVER
         e SYBASE
   -------------------------------------------------------------------------------------- */
declare @cFilial_CT2 char('CT2_FILIAL')
declare @cCT2FilDe   char('CT2_FILIAL')
declare @cFILCT2     char('CT2_FILIAL')
declare @cAux        char(03)
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
Declare @cDATACQ     Char(06)
Declare @cEC05       Char('CT2_EC05DB')
##IF_001({|| cPaisLoc $ 'COL|PER' .And. CtbMovSaldo("CT0",,"05") })
   Declare @cFilial_QL6 Char('QL6_FILIAL')
   Declare @cFilial_QL7 Char('QL7_FILIAL')
   Declare @cENT05      Char('QL6_ENT05')
##ELSE_001
   Declare @cFilial_QL6 Char('CT2_FILIAL')
   Declare @cFilial_QL7 Char('CT2_FILIAL')
   Declare @cENT05      Char('CT2_EC05DB')
##ENDIF_001

begin

    select @OUT_RESULTADO = '0'

    /* --------------------------------------------------------------------------------------------------------------
        Gravação QL7 - Diaria
        -------------------------------------------------------------------------------------------------------------- */
    select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
    Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut

    If @IN_FILIAL = ' ' select @cCT2FilDe = ' '
    else select @cCT2FilDe = @IN_FILIAL

    select @cAux = 'CT2'
    exec XFILIAL_## @cAux, @cCT2FilDe, @cFilial_CT2 OutPut

    Declare CUR_QL7 insensitive cursor for
    Select CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_CLVLDB, CT2_EC05DB, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '1'
        From CT2###
        Where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE
        and (CT2_DC = '1' or CT2_DC = '3')
        and CT2_EC05DB != ' '
        and CT2_TPSALD = @IN_TPSALDO
        and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
        and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
        and CT2_DEBITO != ' '
        and D_E_L_E_T_= ' '
        Group By CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_CLVLDB, CT2_EC05DB, CT2_MOEDLC, CT2_DATA, CT2_DTLP
    Union
    Select CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_CLVLCR, CT2_EC05CR, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), '2'
        From CT2###
        Where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE
        and (CT2_DC = '2' or CT2_DC = '3')
        and CT2_EC05CR != ' '
        and CT2_TPSALD = @IN_TPSALDO
        and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
        and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
        and CT2_CREDIT != ' '
        and D_E_L_E_T_ = ' '
        Group By CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_CLVLCR, CT2_EC05CR, CT2_MOEDLC, CT2_DATA, CT2_DTLP
    order by 1,2,3,4,5,6,7,8,9

    for read only
    Open CUR_QL7
    Fetch CUR_QL7 into  @cFILCT2, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cEC05, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO

    While (@@Fetch_status = 0 ) begin

        select @cAux = 'QL6'
        exec XFILIAL_## @cAux, @cFILCT2, @cFilial_QL6 OutPut
        select @cAux = 'QL7'
        exec XFILIAL_## @cAux, @cFILCT2, @cFilial_QL7 OutPut

        Exec LASTDAY_## @cDATA, @cDataF OutPut

        select @nCTX_DEBITO = 0
        select @nCTX_CREDIT = 0
        select @cCTX_STATUS = '1'
        select @cCTX_SLBASE = 'S'
        select @cCTX_DTLP = ' '
        /* Entidad 05: Ajusta la cantidad de caracteres a la longitud del campo en las tablas QL6/QL7 */
        select @cENT05 = @cEC05
        /*---------------------------------------------------------------
            Ajusta dados para GRAVAÇÃO DE SALDOS DO DIA  SQ3
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
            Verifica se a linha ja existe no QL7 - Dia
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
            -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0
        ##UNIQUEKEY_START
        select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
        From QL7###
        Where QL7_FILIAL = @cFilial_QL7
            and QL7_DATA   = @cDATA
            and QL7_CONTA  = @cCONTA
            and QL7_CCUSTO = @cCUSTO
            and QL7_ITEM   = @cITEM
            and QL7_CLVL   = @cCLVL
            and QL7_ENT05  = @cENT05
            and QL7_MOEDA  = @cMOEDA
            and QL7_TPSALD = @IN_TPSALDO
            and QL7_LP     = @cCTX_LP
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END

        If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM QL7###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
            Insert no QL7 - Saldos da Custo mes
            --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            Begin Tran
            Insert into QL7### ( QL7_FILIAL,  QL7_CONTA, QL7_CCUSTO, QL7_ITEM, QL7_CLVL, QL7_ENT05, QL7_MOEDA, QL7_DATA, QL7_TPSALD,  QL7_SLBASE,   QL7_DTLP,   QL7_LP, QL7_STATUS,   QL7_DEBITO, QL7_CREDIT, R_E_C_N_O_ )
                        values( @cFilial_QL7, @cCONTA,   @cCUSTO,    @cITEM,   @cCLVL,   @cENT05,   @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,        0,          0, @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /*---------------------------------------------------------------
          Update no QL7 - Saldos da Custo DIA
          --------------------------------------------------------------- */
        Begin Tran
        Update QL7###
           set QL7_DEBITO = QL7_DEBITO + @nCTX_DEBITO, QL7_CREDIT = QL7_CREDIT + @nCTX_CREDIT
         Where R_E_C_N_O_ = @iRecno
        commit tran
        /* ---------------------------------------------------------------
            CT190FLGLP - ATUALIZA FLAG DE LP custos Dia
            --------------------------------------------------------------- */
        if @cCT2_DTLP != ' ' begin
            select @cIdent  = ' '
            select @cTabela = 'QL7'
            Exec CTB025A_##  @cFilial_QL7, @cTabela, @cIdent, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cEC05, @cCT2_DTLP, @cMOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @OUT_RESULTADO OutPut
        end
        /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
            -------------------------------------------------------------------------------------------------------------- */
        SELECT @fim_CUR = 0
        Fetch CUR_QL7 into  @cFILCT2, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cEC05, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
    end
    close CUR_QL7
    deallocate CUR_QL7
    /* --------------------------------------------------------------------------------------------------------------
        Gravação QL6 - Mensal
        -------------------------------------------------------------------------------------------------------------- */
    select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
    Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut

    If @IN_FILIAL = ' ' select @cCT2FilDe = ' '
    else select @cCT2FilDe = @IN_FILIAL

    select @cAux = 'CT2'
    exec XFILIAL_## @cAux, @cCT2FilDe, @cFilial_CT2 OutPut

    Declare CUR_QL7 insensitive cursor for
        Select QL7_FILIAL, QL7_ENT05, QL7_CLVL, QL7_ITEM, QL7_CCUSTO, QL7_CONTA, QL7_MOEDA, Substring( QL7_DATA, 1, 6 ), QL7_DTLP, QL7_LP, SUM(QL7_DEBITO),SUM(QL7_CREDIT)
        From QL7###
        Where QL7_FILIAL between @cFilial_CT2 and @IN_FILIALATE
            and QL7_TPSALD = @IN_TPSALDO
            and ( ( QL7_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
            and (QL7_DATA between @cDataI and @cDataF)
            and D_E_L_E_T_= ' '
        Group By QL7_FILIAL, QL7_ENT05, QL7_CLVL, QL7_ITEM, QL7_CCUSTO, QL7_CONTA, QL7_MOEDA, Substring( QL7_DATA, 1, 6 ), QL7_DTLP, QL7_LP
        order by 1,2,3,4,5,6,7,8,9,10
        for read only
    Open CUR_QL7
    Fetch CUR_QL7 into  @cFILCT2, @cENT05, @cCLVL, @cITEM, @cCUSTO, @cCONTA, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred

    While (@@Fetch_status = 0 ) begin

        select @cAux = 'QL6'
        exec XFILIAL_## @cAux, @cFILCT2, @cFilial_QL6 OutPut
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
          From QL6###
         Where QL6_FILIAL = @cFilial_QL6
           and QL6_CONTA  = @cCONTA
           and QL6_CCUSTO = @cCUSTO
           and QL6_ITEM   = @cITEM
           and QL6_CLVL   = @cCLVL
           and QL6_ENT05  = @cENT05
           and QL6_MOEDA  = @cMOEDA
           and QL6_DATA   = @cDataF
           and QL6_TPSALD = @IN_TPSALDO
           and QL6_LP     = @cCTX_LP
           and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END

        If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM QL6###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
            Insert no CQ0 - Saldos da conta
            --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            Begin Tran
            Insert into QL6### ( QL6_FILIAL,  QL6_CONTA, QL6_CCUSTO, QL6_ITEM, QL6_CLVL, QL6_ENT05, QL6_MOEDA, QL6_DATA, QL6_TPSALD,  QL6_SLBASE,   QL6_DTLP,   QL6_LP, QL6_STATUS,   QL6_DEBITO, QL6_CREDIT, R_E_C_N_O_ )
                        values( @cFilial_QL6, @cCONTA,   @cCUSTO,    @cITEM,   @cCLVL,   @cENT05,   @cMOEDA,   @cDataF,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,       0,          0, @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /*---------------------------------------------------------------
        Update no QL6 -
        --------------------------------------------------------------- */
        begin tran
        Update QL6###
        set QL6_DTLP   = @cCTX_DTLP,
            QL6_DEBITO = QL6_DEBITO + @nCTX_DEBITO,
            QL6_CREDIT = QL6_CREDIT + @nCTX_CREDIT
        Where R_E_C_N_O_ = @iRecno
        commit tran
        /* --------------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
            -------------------------------------------------------------------------------------------------------------- */
        SELECT @fim_CUR = 0
        Fetch CUR_QL7 into  @cFILCT2, @cENT05, @cCLVL, @cITEM, @cCUSTO, @cCONTA, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
    end
    close CUR_QL7
    deallocate CUR_QL7

    /* ---------------------------------------------------------------
        ATUALIZAR ENTIDADES GERENCIAIS CQ8/CQ9
        --------------------------------------------------------------- */
    EXEC CTB232A_## @IN_FILIAL,  @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @IN_FILIALATE,  @IN_DATADE, @IN_DATAATE,  @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @OUT_RESULTADO Output
    /* ---------------------------------------------------------------
        Se a execucao foi OK retorna '1'
        --------------------------------------------------------------- */
    select @OUT_RESULTADO = '1'

end
##ENDFIELDP01
##ENDIF_001
