Create Procedure ATF012_##
(
   @IN_CPAISLOC  CHAR( 03 ),
   @IN_FILSN4    Char( 'N4_FILIAL' ),
   @IN_CBASE     Char( 'N3_CBASE' ),
   @IN_ITEM      Char( 'N3_ITEM' ),
   @IN_TIPO      Char( 'N3_TIPO' ),
   @IN_CCORREC   Char( 'N3_CCORREC' ),
   @IN_CCONTAB   Char( 'N3_CCONTAB' ),
   @IN_SUBCCON   Char( 'N3_SUBCCON' ),
   @IN_CCDEPR    Char( 'N3_CCDEPR' ),
   @IN_CCCDEP    Char( 'N3_CCCDEP' ),
   @IN_SUBCCDE   Char( 'N3_SUBCCDE' ),
   @IN_CDESP     Char( 'N3_CDESP' ),
   @IN_CDEPREC   Char( 'N3_CDEPREC' ),
   @IN_CCDESP    Char( 'N3_CCDESP' ),
   @IN_SUBCDEP   Char( 'N3_SUBCDEP' ),
   @IN_CCCDES    Char( 'N3_CCCDES' ),
   @IN_SUBCDES   Char( 'N3_SUBCDES' ),
   @IN_DATADEP   Char( 08 ),
   @IN_DINDEPR   Char( 08 ),
   @IN_CCCORR    Char( 'N3_CCCORR' ),
   @IN_SEQ       Char( 'N4_SEQ' ),
   @IN_SUBCCOR   Char( 'N3_SUBCCOR' ),
   @IN_SEQREAV   Char( 'N4_SEQREAV' ),
   @IN_TXMEDIA   float,
   @IN_TXDEP     float,
   @IN_VALCOR    float,
   @IN_VALCORDEP float,
   @IN_VALDEP1   float,
   @IN_VALDEP2   float,
   @IN_VALDEP3   float,
   @IN_VALDEP4   float,
   @IN_VALDEP5   float,
   @IN_TPSALDO   char( 01 ),
   @IN_QUANTPR   float,
   @IN_IDMOV     Char( 10 ),
   @IN_TPBEM     Char( 02 ) ,
   @IN_CASA1     Integer,
   @IN_CASA2     Integer,
   @IN_CASA3     Integer,
   @IN_CASA4     Integer,
   @IN_CASA5     Integer
   ##FIELDP01( 'SN1.N1_CALCPIS' )
   ,@IN_CALCPIS   Char( 'N1_CALCPIS' )
   ##ENDFIELDP01
    ##FIELDP02( 'SN3.N3_VORIG6' )
    ,@IN_VALDEP6   float
    ,@IN_CASA6     Integer
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG7' )
    ,@IN_VALDEP7   float
    ,@IN_CASA7     Integer
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG8' )
    ,@IN_VALDEP8   float
    ,@IN_CASA8     Integer
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG9' )
    ,@IN_VALDEP9   float
    ,@IN_CASA9     Integer
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG10' )
    ,@IN_VALDEP10   float
    ,@IN_CASA10     Integer
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG11' )
    ,@IN_VALDEP11   float
    ,@IN_CASA11     Integer
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG12' )
    ,@IN_VALDEP12   float
    ,@IN_CASA12     Integer
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG13' )
    ,@IN_VALDEP13   float
    ,@IN_CASA13     Integer
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG14' )
    ,@IN_VALDEP14   float
    ,@IN_CASA14     Integer
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG15' )
    ,@IN_VALDEP15   float
    ,@IN_CASA15     Integer
    ##ENDFIELDP11
)
as
/* -------------------------------------------------------------------------------------------
   Grava os diversos tipos de movimentos no SN4
   ------------------------------------------------------------------------------------------- */
Declare @cOcorrencia Char( 'N4_OCORR' )
Declare @cMotivo     Char( 'N4_MOTIVO' )
Declare @cTipoCnt    Char( 'N4_TIPOCNT' )
Declare @nQuant      Float
Declare @nVlRoc2     Float
Declare @nVlRoc3     Float
Declare @nVlRoc4     Float
Declare @nVlRoc5     Float
Declare @cSerie      Char( 'N4_SERIE' )
Declare @cNota       Char( 'N4_NOTA' )
Declare @nVenda      Float
Declare @cLocal      Char( 'N4_LOCAL' )
Declare @cCodBaixa   Char( 'N4_CODBAIX' )
Declare @cFilOrig    Char( 'N4_FILIAL' )
Declare @cClVl       Char( 'N4_CLVL' )
Declare @cDContab    Char( 'N4_DCONTAB' )
Declare @nTxMedia    Float
Declare @nTxDep      Float
Declare @nValCor     Float
Declare @nValCorDep  Float
Declare @nValDepr1   float
Declare @nValDepr2   float
Declare @nValDepr3   float
Declare @nValDepr4   float
Declare @nValDepr5   float
Declare @nValCorDAC  float
##FIELDP02( 'SN3.N3_VORIG6' )
Declare @nValDepr6   float
Declare @nVlRoc6     Float
##ENDFIELDP02
##FIELDP03( 'SN3.N3_VORIG7' )
Declare @nValDepr7   float
Declare @nVlRoc7     Float
##ENDFIELDP03
##FIELDP04( 'SN3.N3_VORIG8' )
Declare @nValDepr8   float
Declare @nVlRoc8     Float
##ENDFIELDP04
##FIELDP05( 'SN3.N3_VORIG9' )
Declare @nValDepr9   float
Declare @nVlRoc9     Float
##ENDFIELDP05
##FIELDP06( 'SN3.N3_VORIG10' )
Declare @nValDepr10   float
Declare @nVlRoc10     Float
##ENDFIELDP06
##FIELDP07( 'SN3.N3_VORIG11' )
Declare @nValDepr11   float
Declare @nVlRoc11     Float
##ENDFIELDP07
##FIELDP08( 'SN3.N3_VORIG12' )
Declare @nValDepr12   float
Declare @nVlRoc12     Float
##ENDFIELDP08
##FIELDP09( 'SN3.N3_VORIG13' )
Declare @nValDepr13   float
Declare @nVlRoc13     Float
##ENDFIELDP09
##FIELDP10( 'SN3.N3_VORIG14' )
Declare @nValDepr14   float
Declare @nVlRoc14     Float
##ENDFIELDP10
##FIELDP11( 'SN3.N3_VORIG15' )
Declare @nValDepr15   float
Declare @nVlRoc15     Float
##ENDFIELDP11

Begin
    select @nTxMedia    = @IN_TXMEDIA
    select @nTxDep      = @IN_TXDEP
    select @nValCor     = @IN_VALCOR
    select @nValCorDep  = @IN_VALCORDEP
    select @nValDepr1   = @IN_VALDEP1
    select @nValDepr2   = @IN_VALDEP2
    select @nValDepr3   = @IN_VALDEP3
    select @nValDepr4   = @IN_VALDEP4
    select @nValDepr5   = @IN_VALDEP5
    select @nValCorDAC  = 0
    select @nVlRoc2     = 0
    select @nVlRoc3     = 0
    select @nVlRoc4     = 0
    select @nVlRoc5     = 0
    select @cSerie      = ' '
    select @cNota       = ' '
    select @nVenda      = 0
    select @cLocal      = ' '
    select @cCodBaixa   = ' '
    select @cFilOrig    = ' '
    select @cClVl       = ' '
    select @cDContab    = ' '
    ##FIELDP02( 'SN3.N3_VORIG6' )
    select @nValDepr6   = @IN_VALDEP6
    select @nVlRoc6     = 0
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG7' )
    select @nValDepr7   = @IN_VALDEP7
    select @nVlRoc7     = 0
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG8' )
    select @nValDepr8   = @IN_VALDEP8
    select @nVlRoc8     = 0
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG9' )
    select @nValDepr9   = @IN_VALDEP9
    select @nVlRoc9     = 0
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG10' )
    select @nValDepr10   = @IN_VALDEP10
    select @nVlRoc10     = 0
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG11' )
    select @nValDepr11   = @IN_VALDEP11
    select @nVlRoc11     = 0
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG12' )
    select @nValDepr12   = @IN_VALDEP12
    select @nVlRoc12     = 0
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG13' )
    select @nValDepr13   = @IN_VALDEP13
    select @nVlRoc13     = 0
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG14' )
    select @nValDepr14   = @IN_VALDEP14
    select @nVlRoc14     = 0
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG15' )
    select @nValDepr15   = @IN_VALDEP15
    select @nVlRoc15     = 0
    ##ENDFIELDP11
    
    IF @IN_CCORREC != ' ' and @nValCor != 0 begin
        select @cOcorrencia = '07'
        select @cMotivo     = ' '
        select @cTipoCnt    = '2'
        select @nQuant      = 0
        exec  ATF003_## @IN_FILSN4,  @IN_CBASE,  @IN_ITEM,  @IN_TIPO,  @cOcorrencia, @cMotivo,    @cTipoCnt,   @IN_CCORREC,
                        @IN_DATADEP, @nQuant,    @nValCor,  @nVlRoc2,  @nVlRoc3,     @nVlRoc4,    @nVlRoc5,    @cSerie,
                        @cNota,      @nVenda,    @nTxMedia, @nTxDep,   @IN_CCCORR,   @cLocal,     @IN_SEQ,     @IN_SUBCCOR,
                        @IN_SEQREAV, @cCodBaixa, @cFilOrig, @cClVl,    @cDContab,    @IN_TPSALDO, @IN_QUANTPR,
                        @IN_IDMOV,   @IN_TPBEM,  @IN_CASA1, @IN_CASA2, @IN_CASA3,    @IN_CASA4,   @IN_CASA5
                        ##FIELDP01( 'SN1.N1_CALCPIS' )
                        , @IN_CALCPIS
                        ##ENDFIELDP01
                        ##FIELDP02( 'SN3.N3_VORIG6' )
                        ,    @nVlRoc6,   @IN_CASA6
                        ##ENDFIELDP02
                        ##FIELDP03( 'SN3.N3_VORIG7' )
                        ,    @nVlRoc7,   @IN_CASA7
                        ##ENDFIELDP03
                        ##FIELDP04( 'SN3.N3_VORIG8' )
                        ,    @nVlRoc8,   @IN_CASA8
                        ##ENDFIELDP04
                        ##FIELDP05( 'SN3.N3_VORIG9' )
                        ,    @nVlRoc9,   @IN_CASA9
                        ##ENDFIELDP05
                        ##FIELDP06( 'SN3.N3_VORIG10' )
                        ,    @nVlRoc10,   @IN_CASA10
                        ##ENDFIELDP06
                        ##FIELDP07( 'SN3.N3_VORIG11' )
                        ,    @nVlRoc11,   @IN_CASA11
                        ##ENDFIELDP07
                        ##FIELDP08( 'SN3.N3_VORIG12' )
                        ,    @nVlRoc12,   @IN_CASA12
                        ##ENDFIELDP08
                        ##FIELDP09( 'SN3.N3_VORIG13' )
                        ,    @nVlRoc13,   @IN_CASA13
                        ##ENDFIELDP09
                        ##FIELDP10( 'SN3.N3_VORIG14' )
                        ,    @nVlRoc14,   @IN_CASA14
                        ##ENDFIELDP10
                        ##FIELDP11( 'SN3.N3_VORIG15' )
                        ,    @nVlRoc15,   @IN_CASA15
                        ##ENDFIELDP11
    End
    /* ----------------------------------------------------------------------------------
        2 - Movimento Linha de correcao da Depreciacao NO SN4
        ---------------------------------------------------------------------------------- */         
    IF @IN_CCORREC != ' ' and @nValCor != 0 begin
        select @cOcorrencia = '07'
        select @cMotivo     = ' '
        select @cTipoCnt    = '1'
        select @nQuant      = 0
        exec  ATF003_## @IN_FILSN4,  @IN_CBASE,  @IN_ITEM,  @IN_TIPO, @cOcorrencia, @cMotivo,    @cTipoCnt,   @IN_CCONTAB,
                        @IN_DATADEP, @nQuant,    @nValCor,  @nVlRoc2, @nVlRoc3,     @nVlRoc4,    @nVlRoc5,    @cSerie,
                        @cNota,      @nVenda,    @nTxMedia, @nTxDep,  @cClVl,       @cLocal,     @IN_SEQ,     @IN_SUBCCON,
                        @IN_SEQREAV, @cCodBaixa, @cFilOrig, @cClVl,   @cDContab,    @IN_TPSALDO, @IN_QUANTPR, 
                        @IN_IDMOV,   @IN_TPBEM,  @IN_CASA1, @IN_CASA2, @IN_CASA3,   @IN_CASA4,   @IN_CASA5
                        ##FIELDP01( 'SN1.N1_CALCPIS' )
                        , @IN_CALCPIS
                        ##ENDFIELDP01
                        ##FIELDP02( 'SN3.N3_VORIG6' )
                        ,    @nVlRoc6,   @IN_CASA6
                        ##ENDFIELDP02
                        ##FIELDP03( 'SN3.N3_VORIG7' )
                        ,    @nVlRoc7,   @IN_CASA7
                        ##ENDFIELDP03
                        ##FIELDP04( 'SN3.N3_VORIG8' )
                        ,    @nVlRoc8,   @IN_CASA8
                        ##ENDFIELDP04
                        ##FIELDP05( 'SN3.N3_VORIG9' )
                        ,    @nVlRoc9,   @IN_CASA9
                        ##ENDFIELDP05
                        ##FIELDP06( 'SN3.N3_VORIG10' )
                        ,    @nVlRoc10,   @IN_CASA10
                        ##ENDFIELDP06
                        ##FIELDP07( 'SN3.N3_VORIG11' )
                        ,    @nVlRoc11,   @IN_CASA11
                        ##ENDFIELDP07
                        ##FIELDP08( 'SN3.N3_VORIG12' )
                        ,    @nVlRoc12,   @IN_CASA12
                        ##ENDFIELDP08
                        ##FIELDP09( 'SN3.N3_VORIG13' )
                        ,    @nVlRoc13,   @IN_CASA13
                        ##ENDFIELDP09
                        ##FIELDP10( 'SN3.N3_VORIG14' )
                        ,    @nVlRoc14,   @IN_CASA14
                        ##ENDFIELDP10
                        ##FIELDP11( 'SN3.N3_VORIG15' )
                        ,    @nVlRoc15,   @IN_CASA15
                        ##ENDFIELDP11
    End
    /* ----------------------------------------------------------------------------------
        4 - Atualiza tabela Movimentacoes NS4  - Depreciao Acumulada
        ---------------------------------------------------------------------------------- */         
    IF (( @nValDepr1 + @nValDepr2 + @nValDepr3 + @nValDepr4 + @nValDepr5
                        ##FIELDP02( 'SN3.N3_VORIG6' )
                        + @nValDepr6
                        ##ENDFIELDP02
                        ##FIELDP03( 'SN3.N3_VORIG7' )
                        + @nValDepr7
                        ##ENDFIELDP03
                        ##FIELDP04( 'SN3.N3_VORIG8' )
                        + @nValDepr8
                        ##ENDFIELDP04
                        ##FIELDP05( 'SN3.N3_VORIG9' )
                        + @nValDepr9
                        ##ENDFIELDP05
                        ##FIELDP06( 'SN3.N3_VORIG10' )
                        + @nValDepr10
                        ##ENDFIELDP06
                        ##FIELDP07( 'SN3.N3_VORIG11' )
                        + @nValDepr11
                        ##ENDFIELDP07
                        ##FIELDP08( 'SN3.N3_VORIG12' )
                        + @nValDepr12
                        ##ENDFIELDP08
                        ##FIELDP09( 'SN3.N3_VORIG13' )
                        + @nValDepr13
                        ##ENDFIELDP09
                        ##FIELDP10( 'SN3.N3_VORIG14' )
                        + @nValDepr14
                        ##ENDFIELDP10
                        ##FIELDP11( 'SN3.N3_VORIG15' )
                        + @nValDepr15
                        ##ENDFIELDP11 ) != 0 and @IN_DINDEPR <= @IN_DATADEP) begin
      
        select @cOcorrencia = '06'
        If @IN_TIPO = '07' begin
            select @cOcorrencia = '10'
        end
        If @IN_TIPO = '08' begin
            select @cOcorrencia = '12'
        end
        If @IN_TIPO = '09' begin
            select @cOcorrencia = '11'
        End
        If @IN_TIPO IN ( '10','12','14','15','50','51','52','53','54' ) begin
            select @cOcorrencia = '20'
        End
        select @cMotivo     = ' '
        select @cTipoCnt    = '4'
        select @nQuant      = 0
        select @cSerie      = ' '
        select @cNota       = ' '
        select @nVenda      = 0
        select @cLocal      = ' '
        select @cCodBaixa   = ' '
        select @cFilOrig    = ' '
        select @cClVl       = ' '
        select @cDContab    = ' '
      
        exec  ATF003_## @IN_FILSN4,  @IN_CBASE,  @IN_ITEM,   @IN_TIPO,   @cOcorrencia, @cMotivo,    @cTipoCnt,   @IN_CCDEPR,
                        @IN_DATADEP, @nQuant,    @nValDepr1, @nValDepr2, @nValDepr3,   @nValDepr4,  @nValDepr5,  @cSerie,
                        @cNota,      @nVenda,    @nTxMedia,  @nTxDep,    @IN_CCCDEP,   @cLocal,     @IN_SEQ,     @IN_SUBCCDE,
                        @IN_SEQREAV, @cCodBaixa, @cFilOrig,  @cClVl,     @cDContab,    @IN_TPSALDO, @IN_QUANTPR,
                        @IN_IDMOV,   @IN_TPBEM,  @IN_CASA1,  @IN_CASA2,  @IN_CASA3,    @IN_CASA4,   @IN_CASA5
                        ##FIELDP01( 'SN1.N1_CALCPIS' )
                        , @IN_CALCPIS
                        ##ENDFIELDP01
                        ##FIELDP02( 'SN3.N3_VORIG6' )
                        ,    @nValDepr6,   @IN_CASA6
                        ##ENDFIELDP02
                        ##FIELDP03( 'SN3.N3_VORIG7' )
                        ,    @nValDepr7,   @IN_CASA7
                        ##ENDFIELDP03
                        ##FIELDP04( 'SN3.N3_VORIG8' )
                        ,    @nValDepr8,   @IN_CASA8
                        ##ENDFIELDP04
                        ##FIELDP05( 'SN3.N3_VORIG9' )
                        ,    @nValDepr9,   @IN_CASA9
                        ##ENDFIELDP05
                        ##FIELDP06( 'SN3.N3_VORIG10' )
                        ,    @nValDepr10,   @IN_CASA10
                        ##ENDFIELDP06
                        ##FIELDP07( 'SN3.N3_VORIG11' )
                        ,    @nValDepr11,   @IN_CASA11
                        ##ENDFIELDP07
                        ##FIELDP08( 'SN3.N3_VORIG12' )
                        ,    @nValDepr12,   @IN_CASA12
                        ##ENDFIELDP08
                        ##FIELDP09( 'SN3.N3_VORIG13' )
                        ,    @nValDepr13,   @IN_CASA13
                        ##ENDFIELDP09
                        ##FIELDP10( 'SN3.N3_VORIG14' )
                        ,    @nValDepr14,   @IN_CASA14
                        ##ENDFIELDP10
                        ##FIELDP11( 'SN3.N3_VORIG15' )
                        ,    @nValDepr15,   @IN_CASA15
                        ##ENDFIELDP11
        /* ----------------------------------------------------------------------------------
            5 - Gera linha de correcao da depr acum no SN4
            ---------------------------------------------------------------------------------- */
        If @nValCorDep != 0 and @IN_CDESP != ' ' begin
            select @cOcorrencia = '08'
            select @cMotivo     = ' '
            select @cTipoCnt    = '4'
            select @nQuant      = 0
         
            exec  ATF003_## @IN_FILSN4,  @IN_CBASE,  @IN_ITEM,    @IN_TIPO,  @cOcorrencia, @cMotivo,    @cTipoCnt,   @IN_CCDEPR,
                            @IN_DATADEP, @nQuant,    @nValCorDep, @nVlRoc2,  @nVlRoc3,     @nVlRoc4,    @nVlRoc5,    @cSerie,
                            @cNota,      @nVenda,    @nTxMedia,   @nTxDep,   @IN_CCCDEP,   @cLocal,     @IN_SEQ,     @IN_SUBCCDE,
                            @IN_SEQREAV, @cCodBaixa, @cFilOrig,   @cClVl,    @cDContab,    @IN_TPSALDO, @IN_QUANTPR,
                            @IN_IDMOV,   @IN_TPBEM,  @IN_CASA1,   @IN_CASA2, @IN_CASA3,    @IN_CASA4,   @IN_CASA5
                            ##FIELDP01( 'SN1.N1_CALCPIS' )
                            , @IN_CALCPIS
                            ##ENDFIELDP01
                            ##FIELDP02( 'SN3.N3_VORIG6' )
                            ,    @nVlRoc6,   @IN_CASA6
                            ##ENDFIELDP02
                            ##FIELDP03( 'SN3.N3_VORIG7' )
                            ,    @nVlRoc7,   @IN_CASA7
                            ##ENDFIELDP03
                            ##FIELDP04( 'SN3.N3_VORIG8' )
                            ,    @nVlRoc8,   @IN_CASA8
                            ##ENDFIELDP04
                            ##FIELDP05( 'SN3.N3_VORIG9' )
                            ,    @nVlRoc9,   @IN_CASA9
                            ##ENDFIELDP05
                            ##FIELDP06( 'SN3.N3_VORIG10' )
                            ,    @nVlRoc10,   @IN_CASA10
                            ##ENDFIELDP06
                            ##FIELDP07( 'SN3.N3_VORIG11' )
                            ,    @nVlRoc11,   @IN_CASA11
                            ##ENDFIELDP07
                            ##FIELDP08( 'SN3.N3_VORIG12' )
                            ,    @nVlRoc12,   @IN_CASA12
                            ##ENDFIELDP08
                            ##FIELDP09( 'SN3.N3_VORIG13' )
                            ,    @nVlRoc13,   @IN_CASA13
                            ##ENDFIELDP09
                            ##FIELDP10( 'SN3.N3_VORIG14' )
                            ,    @nVlRoc14,   @IN_CASA14
                            ##ENDFIELDP10
                            ##FIELDP11( 'SN3.N3_VORIG15' )
                            ,    @nVlRoc15,   @IN_CASA15
                            ##ENDFIELDP11        
        End
        /* ----------------------------------------------------------------------------------
            6 - CHILE - Gera linha de correcao da depr acum de exercicio anterior no SN4
            ---------------------------------------------------------------------------------- */
        If @IN_CPAISLOC = 'CHI' and @nValCorDAC != 0 and @IN_CDESP != ' ' begin
            select @cOcorrencia = '08'
            select @cMotivo     = ' '
            select @cTipoCnt    = '8'
            select @nQuant      = 0
         
            exec  ATF003_## @IN_FILSN4,  @IN_CBASE,  @IN_ITEM,    @IN_TIPO,  @cOcorrencia, @cMotivo,    @cTipoCnt,   @IN_CDEPREC,
                            @IN_DATADEP, @nQuant,    @nValCorDAC, @nVlRoc2,  @nVlRoc3,     @nVlRoc4,    @nVlRoc5,    @cSerie,
                            @cNota,      @nVenda,    @nTxMedia,   @nTxDep,   @IN_CCCDEP,   @cLocal,     @IN_SEQ,     @IN_SUBCCDE,
                            @IN_SEQREAV, @cCodBaixa, @cFilOrig,   @cClVl,    @cDContab,    @IN_TPSALDO, @IN_QUANTPR,
                            @IN_IDMOV,   @IN_TPBEM,  @IN_CASA1,   @IN_CASA2, @IN_CASA3,    @IN_CASA4,   @IN_CASA5
                            ##FIELDP01( 'SN1.N1_CALCPIS' )
                            , @IN_CALCPIS
                            ##ENDFIELDP01
                            ##FIELDP02( 'SN3.N3_VORIG6' )
                            ,    @nVlRoc6,   @IN_CASA6
                            ##ENDFIELDP02
                            ##FIELDP03( 'SN3.N3_VORIG7' )
                            ,    @nVlRoc7,   @IN_CASA7
                            ##ENDFIELDP03
                            ##FIELDP04( 'SN3.N3_VORIG8' )
                            ,    @nVlRoc8,   @IN_CASA8
                            ##ENDFIELDP04
                            ##FIELDP05( 'SN3.N3_VORIG9' )
                            ,    @nVlRoc9,   @IN_CASA9
                            ##ENDFIELDP05
                            ##FIELDP06( 'SN3.N3_VORIG10' )
                            ,    @nVlRoc10,   @IN_CASA10
                            ##ENDFIELDP06
                            ##FIELDP07( 'SN3.N3_VORIG11' )
                            ,    @nVlRoc11,   @IN_CASA11
                            ##ENDFIELDP07
                            ##FIELDP08( 'SN3.N3_VORIG12' )
                            ,    @nVlRoc12,   @IN_CASA12
                            ##ENDFIELDP08
                            ##FIELDP09( 'SN3.N3_VORIG13' )
                            ,    @nVlRoc13,   @IN_CASA13
                            ##ENDFIELDP09
                            ##FIELDP10( 'SN3.N3_VORIG14' )
                            ,    @nVlRoc14,   @IN_CASA14
                            ##ENDFIELDP10
                            ##FIELDP11( 'SN3.N3_VORIG15' )
                            ,    @nVlRoc15,   @IN_CASA15
                            ##ENDFIELDP11
        End
    End
    /* ----------------------------------------------------------------------------------
        7 - Atualiza tabela Movimentacoes SN4  - Depreciao 
        ---------------------------------------------------------------------------------- */         
    IF (( @nValDepr1 + @nValDepr2 + @nValDepr3 + @nValDepr4 + @nValDepr5 
            ##FIELDP02( 'SN3.N3_VORIG6' )
            + @nValDepr6
            ##ENDFIELDP02
            ##FIELDP03( 'SN3.N3_VORIG7' )
            + @nValDepr7
            ##ENDFIELDP03
            ##FIELDP04( 'SN3.N3_VORIG8' )
            + @nValDepr8
            ##ENDFIELDP04
            ##FIELDP05( 'SN3.N3_VORIG9' )
            + @nValDepr9
            ##ENDFIELDP05
            ##FIELDP06( 'SN3.N3_VORIG10' )
            + @nValDepr10
            ##ENDFIELDP06
            ##FIELDP07( 'SN3.N3_VORIG11' )
            + @nValDepr11
            ##ENDFIELDP07
            ##FIELDP08( 'SN3.N3_VORIG12' )
            + @nValDepr12
            ##ENDFIELDP08
            ##FIELDP09( 'SN3.N3_VORIG13' )
            + @nValDepr13
            ##ENDFIELDP09
            ##FIELDP10( 'SN3.N3_VORIG14' )
            + @nValDepr14
            ##ENDFIELDP10
            ##FIELDP11( 'SN3.N3_VORIG15' )
            + @nValDepr15
            ##ENDFIELDP11  ) != 0 ) and @IN_DINDEPR <= @IN_DATADEP begin
      
        select @cOcorrencia = '06'
        If @IN_TIPO = '07' begin
            select @cOcorrencia = '10'
        end
        If @IN_TIPO = '08' begin
            select @cOcorrencia = '12'
        end
        If @IN_TIPO = '09' begin
            select @cOcorrencia = '11'
        End
        If @IN_TIPO IN ( '10','12','14','15','50','51','52','53','54' ) begin
            select @cOcorrencia = '20'
        End
        select @cMotivo     = ' '
        select @cTipoCnt    = '3'
        select @nQuant      = 0
        select @cSerie      = ' '
        select @cNota       = ' '
        select @nVenda      = 0
        select @cLocal      = ' '
        select @cCodBaixa   = ' '
        select @cFilOrig    = ' '
        select @cClVl       = ' '
        select @cDContab    = ' '
      
        exec  ATF003_## @IN_FILSN4,  @IN_CBASE,  @IN_ITEM,   @IN_TIPO,   @cOcorrencia, @cMotivo,    @cTipoCnt,  @IN_CDEPREC,
                        @IN_DATADEP, @nQuant,    @nValDepr1, @nValDepr2, @nValDepr3,   @nValDepr4,  @nValDepr5, @cSerie,
                        @cNota,      @nVenda,    @nTxMedia,  @nTxDep,    @IN_CCDESP,   @cLocal,     @IN_SEQ,    @IN_SUBCDEP,
                        @IN_SEQREAV, @cCodBaixa, @cFilOrig,  @cClVl,     @cDContab,    @IN_TPSALDO, @IN_QUANTPR,
                        @IN_IDMOV,   @IN_TPBEM,  @IN_CASA1,  @IN_CASA2,  @IN_CASA3,    @IN_CASA4,   @IN_CASA5
                        ##FIELDP01( 'SN1.N1_CALCPIS' )
                        , @IN_CALCPIS
                        ##ENDFIELDP01
                       ##FIELDP02( 'SN3.N3_VORIG6' )
                        ,    @nValDepr6,   @IN_CASA6
                        ##ENDFIELDP02
                        ##FIELDP03( 'SN3.N3_VORIG7' )
                        ,    @nValDepr7,   @IN_CASA7
                        ##ENDFIELDP03
                        ##FIELDP04( 'SN3.N3_VORIG8' )
                        ,    @nValDepr8,   @IN_CASA8
                        ##ENDFIELDP04
                        ##FIELDP05( 'SN3.N3_VORIG9' )
                        ,    @nValDepr9,   @IN_CASA9
                        ##ENDFIELDP05
                        ##FIELDP06( 'SN3.N3_VORIG10' )
                        ,    @nValDepr10,   @IN_CASA10
                        ##ENDFIELDP06
                        ##FIELDP07( 'SN3.N3_VORIG11' )
                        ,    @nValDepr11,   @IN_CASA11
                        ##ENDFIELDP07
                        ##FIELDP08( 'SN3.N3_VORIG12' )
                        ,    @nValDepr12,   @IN_CASA12
                        ##ENDFIELDP08
                        ##FIELDP09( 'SN3.N3_VORIG13' )
                        ,    @nValDepr13,   @IN_CASA13
                        ##ENDFIELDP09
                        ##FIELDP10( 'SN3.N3_VORIG14' )
                        ,    @nValDepr14,   @IN_CASA14
                        ##ENDFIELDP10
                        ##FIELDP11( 'SN3.N3_VORIG15' )
                        ,    @nValDepr15,   @IN_CASA15
                        ##ENDFIELDP11

    End
    /* ----------------------------------------------------------------------------------
        8 - sAtualiza tabela Movimentacoes SN4  - Correcao da Depreciao 
        ---------------------------------------------------------------------------------- */         
    IF @nValCorDep != 0 and (@IN_DINDEPR <= @IN_DATADEP) begin
      
        select @cOcorrencia = '08'
        select @cMotivo     = ' '
        select @cTipoCnt    = '5'
        select @nQuant      = 0
      
        exec  ATF003_## @IN_FILSN4,  @IN_CBASE,  @IN_ITEM,    @IN_TIPO,   @cOcorrencia, @cMotivo,    @cTipoCnt,  @IN_CDESP,
                        @IN_DATADEP, @nQuant,    @nValCorDep, @nVlRoc2,   @nVlRoc3,     @nVlRoc4,    @nVlRoc5,   @cSerie,
                        @cNota,      @nVenda,    @nTxMedia,   @nTxDep,    @IN_CCCDES,   @cLocal,     @IN_SEQ,    @IN_SUBCDES,
                        @IN_SEQREAV, @cCodBaixa, @cFilOrig,   @cClVl,     @cDContab,    @IN_TPSALDO, @IN_QUANTPR,
                        @IN_IDMOV,   @IN_TPBEM,  @IN_CASA1,   @IN_CASA2,  @IN_CASA3,    @IN_CASA4,   @IN_CASA5
                        ##FIELDP01( 'SN1.N1_CALCPIS' )
                        , @IN_CALCPIS
                        ##ENDFIELDP01
                        ##FIELDP02( 'SN3.N3_VORIG6' )
                        ,    @nVlRoc6,   @IN_CASA6
                        ##ENDFIELDP02
                        ##FIELDP03( 'SN3.N3_VORIG7' )
                        ,    @nVlRoc7,   @IN_CASA7
                        ##ENDFIELDP03
                        ##FIELDP04( 'SN3.N3_VORIG8' )
                        ,    @nVlRoc8,   @IN_CASA8
                        ##ENDFIELDP04
                        ##FIELDP05( 'SN3.N3_VORIG9' )
                        ,    @nVlRoc9,   @IN_CASA9
                        ##ENDFIELDP05
                        ##FIELDP06( 'SN3.N3_VORIG10' )
                        ,    @nVlRoc10,   @IN_CASA10
                        ##ENDFIELDP06
                        ##FIELDP07( 'SN3.N3_VORIG11' )
                        ,    @nVlRoc11,   @IN_CASA11
                        ##ENDFIELDP07
                        ##FIELDP08( 'SN3.N3_VORIG12' )
                        ,    @nVlRoc12,   @IN_CASA12
                        ##ENDFIELDP08
                        ##FIELDP09( 'SN3.N3_VORIG13' )
                        ,    @nVlRoc13,   @IN_CASA13
                        ##ENDFIELDP09
                        ##FIELDP10( 'SN3.N3_VORIG14' )
                        ,    @nVlRoc14,   @IN_CASA14
                        ##ENDFIELDP10
                        ##FIELDP11( 'SN3.N3_VORIG15' )
                        ,    @nVlRoc15,   @IN_CASA15
                        ##ENDFIELDP11
    End
    /* ----------------------------------------------------------------------------------
        9 - sAtualiza tabela Movimentacoes SN4  - Correcao da Depreciao 
        ---------------------------------------------------------------------------------- */
    If @IN_CPAISLOC = 'CHI' and @nValCorDAC != 0 and (@IN_DINDEPR <= @IN_DATADEP) begin
      
        select @cOcorrencia = '08'
        select @cMotivo     = ' '
        select @cTipoCnt    = '9'
        select @nQuant      = 0
      
        exec  ATF003_## @IN_FILSN4,  @IN_CBASE,  @IN_ITEM,    @IN_TIPO,  @cOcorrencia, @cMotivo,    @cTipoCnt,   @IN_CDEPREC,
                        @IN_DATADEP, @nQuant,    @nValCorDAC, @nVlRoc2,  @nVlRoc3,     @nVlRoc4,    @nVlRoc5,    @cSerie,
                        @cNota,      @nVenda,    @nTxMedia,   @nTxDep,   @IN_CCCDES,   @cLocal,     @IN_SEQ,     @IN_SUBCDES,
                        @IN_SEQREAV, @cCodBaixa, @cFilOrig,   @cClVl,    @cDContab,    @IN_TPSALDO, @IN_QUANTPR,
                        @IN_IDMOV,   @IN_TPBEM,  @IN_CASA1,   @IN_CASA2, @IN_CASA3,    @IN_CASA4,   @IN_CASA5
                        ##FIELDP01( 'SN1.N1_CALCPIS' )
                        , @IN_CALCPIS
                        ##ENDFIELDP01
                        ##FIELDP02( 'SN3.N3_VORIG6' )
                        ,    @nVlRoc6,   @IN_CASA6
                        ##ENDFIELDP02
                        ##FIELDP03( 'SN3.N3_VORIG7' )
                        ,    @nVlRoc7,   @IN_CASA7
                        ##ENDFIELDP03
                        ##FIELDP04( 'SN3.N3_VORIG8' )
                        ,    @nVlRoc8,   @IN_CASA8
                        ##ENDFIELDP04
                        ##FIELDP05( 'SN3.N3_VORIG9' )
                        ,    @nVlRoc9,   @IN_CASA9
                        ##ENDFIELDP05
                        ##FIELDP06( 'SN3.N3_VORIG10' )
                        ,    @nVlRoc10,   @IN_CASA10
                        ##ENDFIELDP06
                        ##FIELDP07( 'SN3.N3_VORIG11' )
                        ,    @nVlRoc11,   @IN_CASA11
                        ##ENDFIELDP07
                        ##FIELDP08( 'SN3.N3_VORIG12' )
                        ,    @nVlRoc12,   @IN_CASA12
                        ##ENDFIELDP08
                        ##FIELDP09( 'SN3.N3_VORIG13' )
                        ,    @nVlRoc13,   @IN_CASA13
                        ##ENDFIELDP09
                        ##FIELDP10( 'SN3.N3_VORIG14' )
                        ,    @nVlRoc14,   @IN_CASA14
                        ##ENDFIELDP10
                        ##FIELDP11( 'SN3.N3_VORIG15' )
                        ,    @nVlRoc15,   @IN_CASA15
                        ##ENDFIELDP11
    End
End
