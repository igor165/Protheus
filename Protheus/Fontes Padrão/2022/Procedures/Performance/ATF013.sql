Create Procedure ATF013_##
(  
   @IN_FILIAL     Char( 'N3_FILIAL' ),
   @IN_CBASE      Char( 'N3_CBASE' ),
   @IN_ITEM       Char( 'N3_ITEM' ),
   @IN_TIPO       Char( 'N3_TIPO' ),
   @IN_LCUSTO     Char( 01 ),
   @IN_LITEM      Char( 01 ),
   @IN_LCLVL      Char( 01 ),
   @IN_DATADEP    Char( 08 ),
   @IN_CCORREC    Char( 'N3_CCORREC' ),
   @IN_SUBCCOR    Char( 'N3_SUBCCOR' ),
   @IN_CLVLCOR    Char( 'N3_CLVLCOR' ),
   @IN_CCCORR     Char( 'N3_CCCORR' ),
   @IN_CCONTAB    Char( 'N3_CCONTAB' ),
   @IN_SUBCCON    Char( 'N3_SUBCCON' ),
   @IN_CLVLCON    Char( 'N3_CLVLCON' ),
   @IN_CUSTBEM    Char( 'N3_CUSTBEM' ),
   @IN_CDEPREC    Char( 'N3_CDEPREC' ),
   @IN_SUBCDEP    Char( 'N3_SUBCDEP' ),
   @IN_CLVLDEP    Char( 'N3_CLVLDEP' ),
   @IN_CCDESP     Char( 'N3_CCDESP' ),
   @IN_CCDEPR     Char( 'N3_CCDEPR' ),
   @IN_SUBCCDE    Char( 'N3_SUBCCDE' ),
   @IN_CLVLCDE    Char( 'N3_CLVLCDE' ),
   @IN_CCCDEP     Char( 'N3_CCCDEP' ),
   @IN_CDESP      Char( 'N3_CDESP' ),
   @IN_SUBCDES    Char( 'N3_SUBCDES' ),
   @IN_CLVLDES    Char( 'N3_CLVLDES' ),
   @IN_CCCDES     Char( 'N3_CCCDES' ),
   @IN_TXMEDIA    Float,
   @IN_VALCOR     Float,
   @IN_VALCORDEP  Float,
   @IN_VALDEP1    Float,
   @IN_VALDEP2    Float,
   @IN_VALDEP3    Float,
   @IN_VALDEP4    Float,
   @IN_VALDEP5    Float,
   @IN_TPSALDO    Char( 01 ),
   @IN_CASA1      Integer,
   @IN_CASA2      Integer,
   @IN_CASA3      Integer,
   @IN_CASA4      Integer,
   @IN_CASA5      Integer
    ##FIELDP01( 'SN3.N3_VORIG6' )
    , @IN_VALDEP6    Float
    , @IN_CASA6      Integer
    ##ENDFIELDP01
    ##FIELDP02( 'SN3.N3_VORIG7' )
    , @IN_VALDEP7    Float
    , @IN_CASA7      Integer
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG8' )
    , @IN_VALDEP8    Float
    , @IN_CASA8      Integer
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG9' )
    , @IN_VALDEP9    Float
    , @IN_CASA9      Integer
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG10' )
    , @IN_VALDEP10    Float
    , @IN_CASA10      Integer
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG11' )
    , @IN_VALDEP11    Float
    , @IN_CASA11      Integer
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG12' )
    , @IN_VALDEP12    Float
    , @IN_CASA12      Integer
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG13' )
    , @IN_VALDEP13    Float
    , @IN_CASA13      Integer
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG14' )
    , @IN_VALDEP14    Float
    , @IN_CASA14      Integer
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG15' )
    , @IN_VALDEP15    Float
    , @IN_CASA15      Integer
    ##ENDFIELDP10
)
as

Declare @cAux       Char( 03 )
Declare @cFil_SN1   Char( 'N1_FILIAL' )
Declare @cN1_PATRIM Char( 'N1_PATRIM' )
Declare @cTipoSal   Char( 'N5_TIPO' )
Declare @cTipoCnt   Char( 'N4_TIPOCNT' )
Declare @cSinal     Char( 01 )
Declare @cPrograma  Char( 10 )
Declare @nVlRoc2    Float
Declare @nVlRoc3    Float
Declare @nVlRoc4    Float
Declare @nVlRoc5    Float
Declare @nTxMedia   Float
Declare @nValCor    Float
Declare @nValCorDep Float
Declare @nValDepr1  Float
Declare @nValDepr2  Float
Declare @nValDepr3  Float
Declare @nValDepr4  Float
Declare @nValDepr5  Float
##FIELDP01( 'SN3.N3_VORIG6' )
Declare @nVlRoc6    Float
Declare @nValDepr6  Float
##ENDFIELDP01
##FIELDP02( 'SN3.N3_VORIG7' )
Declare @nVlRoc7    Float
Declare @nValDepr7  Float
##ENDFIELDP02
##FIELDP03( 'SN3.N3_VORIG8' )
Declare @nVlRoc8    Float
Declare @nValDepr8  Float
##ENDFIELDP03
##FIELDP04( 'SN3.N3_VORIG9' )
Declare @nVlRoc9    Float
Declare @nValDepr9  Float
##ENDFIELDP04
##FIELDP05( 'SN3.N3_VORIG10' )
Declare @nVlRoc10    Float
Declare @nValDepr10  Float
##ENDFIELDP05
##FIELDP06( 'SN3.N3_VORIG11' )
Declare @nVlRoc11    Float
Declare @nValDepr11  Float
##ENDFIELDP06
##FIELDP07( 'SN3.N3_VORIG12' )
Declare @nVlRoc12    Float
Declare @nValDepr12  Float
##ENDFIELDP07
##FIELDP08( 'SN3.N3_VORIG13' )
Declare @nVlRoc13    Float
Declare @nValDepr13  Float
##ENDFIELDP08
##FIELDP09( 'SN3.N3_VORIG14' )
Declare @nVlRoc14    Float
Declare @nValDepr14  Float
##ENDFIELDP09
##FIELDP10( 'SN3.N3_VORIG15' )
Declare @nVlRoc15    Float
Declare @nValDepr15  Float
##ENDFIELDP10

Begin
    /* ----------------------------------------------------------------------------------
        Atualiza saldos
		    Tratamento de correcao do bem. Criado N5_TIPO = "P" para tratar as  
		    correcoes de bens com N1_PATRIM $ "SCA". Nao ha necessidade de tipo 
		    novo p/ a corr da depr., porque bens com N1_PATRIM $ "SCA" n∆o so-  
		    frem depreciacao.                                                   
        -------------------------------------------------------------------------- */
    select @cAux = 'SN1'
    exec XFILIAL_## @cAux, @IN_FILIAL, @cFil_SN1 OutPut
    Select @nTxMedia = @IN_TXMEDIA
    Select @nValCor  = @IN_VALCOR
    Select @nValCorDep = @IN_VALCORDEP
    Select @nValDepr1  = @IN_VALDEP1
    Select @nValDepr2  = @IN_VALDEP2
    Select @nValDepr3  = @IN_VALDEP3
    Select @nValDepr4  = @IN_VALDEP4
    Select @nValDepr5  = @IN_VALDEP5
    ##FIELDP01( 'SN3.N3_VORIG6' )
    Select @nValDepr6  = @IN_VALDEP6
    ##ENDFIELDP01
    ##FIELDP02( 'SN3.N3_VORIG7' )
    Select @nValDepr7  = @IN_VALDEP7
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG8' )
    Select @nValDepr8  = @IN_VALDEP8
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG9' )
    Select @nValDepr9  = @IN_VALDEP9
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG10' )
    Select @nValDepr10  = @IN_VALDEP10
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG11' )
    Select @nValDepr11  = @IN_VALDEP11
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG12' )
    Select @nValDepr12  = @IN_VALDEP12
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG13' )
    Select @nValDepr13  = @IN_VALDEP13
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG14' )
    Select @nValDepr14  = @IN_VALDEP14
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG15' )
    Select @nValDepr15  = @IN_VALDEP15
    ##ENDFIELDP10
   
    Select @cN1_PATRIM = N1_PATRIM
        From SN1###
    Where N1_FILIAL  = @cFil_SN1
        and N1_CBASE   = @IN_CBASE
        and N1_ITEM    = @IN_ITEM
        and D_E_L_E_T_ = ' '
   
    If @cN1_PATRIM IN( ' ', 'N', 'P', 'D','I','O','T' ) begin
        select @cTipoSal = '6'
    end else begin
        select @cTipoSal = 'O'
    End
    select @nVlRoc2     = 0
    select @nVlRoc3     = 0
    select @nVlRoc4     = 0
    select @nVlRoc5     = 0
    select @cSinal      = '+'
    select @cTipoCnt    = '2'
    select @cPrograma = 'ATF050'

    ##FIELDP01( 'SN3.N3_VORIG6' )
    select @nVlRoc6     = 0
    ##ENDFIELDP01
    ##FIELDP02( 'SN3.N3_VORIG7' )
    select @nVlRoc7     = 0
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG8' )
    select @nVlRoc8     = 0
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG9' )
    select @nVlRoc9     = 0
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG10' )
    select @nVlRoc10     = 0
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG11' )
    select @nVlRoc11     = 0
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG12' )
    select @nVlRoc12     = 0
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG13' )
    select @nVlRoc13     = 0
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG14' )
    select @nVlRoc14     = 0
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG15' )
    select @nVlRoc15     = 0
    ##ENDFIELDP10

    Exec ATF004_## @IN_FILIAL,  @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @IN_CCORREC, @IN_DATADEP, @cTipoSal,  @nValCor,  @nVlRoc2,   @nVlRoc3,
                    @nVlRoc4,    @nVlRoc5,   @cSinal,   @nTxMedia, @IN_SUBCCOR, @IN_CLVLCOR, @IN_CCCORR, @cTipoCnt, @cPrograma, @IN_TIPO,
                    @IN_TPSALDO, @IN_CASA1,  @IN_CASA2, @IN_CASA3, @IN_CASA4,   @IN_CASA5
                    ##FIELDP01( 'SN3.N3_VORIG6' )
                    , @nVlRoc6,   @IN_CASA6
                    ##ENDFIELDP01
                    ##FIELDP02( 'SN3.N3_VORIG7' )
                   , @nVlRoc7,   @IN_CASA7
                    ##ENDFIELDP02
                    ##FIELDP03( 'SN3.N3_VORIG8' )
                    , @nVlRoc8,   @IN_CASA8
                    ##ENDFIELDP03
                    ##FIELDP04( 'SN3.N3_VORIG9' )
                    , @nVlRoc9,   @IN_CASA9
                    ##ENDFIELDP04
                    ##FIELDP05( 'SN3.N3_VORIG10' )
                    , @nVlRoc10,   @IN_CASA10
                    ##ENDFIELDP05
                    ##FIELDP06( 'SN3.N3_VORIG11' )
                    , @nVlRoc11,   @IN_CASA11
                    ##ENDFIELDP06
                    ##FIELDP07( 'SN3.N3_VORIG12' )
                    , @nVlRoc12,   @IN_CASA12
                    ##ENDFIELDP07
                    ##FIELDP08( 'SN3.N3_VORIG13' )
                    , @nVlRoc13,   @IN_CASA13
                    ##ENDFIELDP08
                    ##FIELDP09( 'SN3.N3_VORIG14' )
                    , @nVlRoc14,   @IN_CASA14
                    ##ENDFIELDP09
                    ##FIELDP10( 'SN3.N3_VORIG15' )
                    , @nVlRoc15,   @IN_CASA15
                    ##ENDFIELDP10

    select @cTipoCnt    = '1'
    Exec ATF004_## @IN_FILIAL,  @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @IN_CCONTAB, @IN_DATADEP, @cTipoSal,    @nValCor, @nVlRoc2, @nVlRoc3,
                    @nVlRoc4,    @nVlRoc5,   @cSinal,   @nTxMedia, @IN_SUBCCON, @IN_CLVLCON, @IN_CUSTBEM, @cTipoCnt, @cPrograma, @IN_TIPO,
                    @IN_TPSALDO, @IN_CASA1,  @IN_CASA2, @IN_CASA3, @IN_CASA4,   @IN_CASA5
                    ##FIELDP01( 'SN3.N3_VORIG6' )
                    , @nVlRoc6,   @IN_CASA6
                    ##ENDFIELDP01
                    ##FIELDP02( 'SN3.N3_VORIG7' )
                   , @nVlRoc7,   @IN_CASA7
                    ##ENDFIELDP02
                    ##FIELDP03( 'SN3.N3_VORIG8' )
                    , @nVlRoc8,   @IN_CASA8
                    ##ENDFIELDP03
                    ##FIELDP04( 'SN3.N3_VORIG9' )
                    , @nVlRoc9,   @IN_CASA9
                    ##ENDFIELDP04
                    ##FIELDP05( 'SN3.N3_VORIG10' )
                    , @nVlRoc10,   @IN_CASA10
                    ##ENDFIELDP05
                    ##FIELDP06( 'SN3.N3_VORIG11' )
                    , @nVlRoc11,   @IN_CASA11
                    ##ENDFIELDP06
                    ##FIELDP07( 'SN3.N3_VORIG12' )
                    , @nVlRoc12,   @IN_CASA12
                    ##ENDFIELDP07
                    ##FIELDP08( 'SN3.N3_VORIG13' )
                    , @nVlRoc13,   @IN_CASA13
                    ##ENDFIELDP08
                    ##FIELDP09( 'SN3.N3_VORIG14' )
                    , @nVlRoc14,   @IN_CASA14
                    ##ENDFIELDP09
                    ##FIELDP10( 'SN3.N3_VORIG15' )
                    , @nVlRoc15,   @IN_CASA15
                    ##ENDFIELDP10

    If @IN_TIPO NOT IN( '08', '09' ) begin
        select @cTipoSal = '4'
    end else begin
        if @IN_TIPO = '09' select @cTipoSal = 'L'
        else select @cTipoSal = 'K'
    End
   
    If @IN_TIPO  IN('10','12','14','15','50','51','52','53','54') begin
        select @cTipoSal = 'Y' -- Depreciacao Gerencial
    end
   
    select @cTipoCnt    = '3'
   
    Exec ATF004_## @IN_FILIAL,  @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @IN_CDEPREC, @IN_DATADEP, @cTipoSal,  @nValDepr1, @nValDepr2, @nValDepr3,
                    @nValDepr4,  @nValDepr5, @cSinal,   @nTxMedia, @IN_SUBCDEP, @IN_CLVLDEP, @IN_CCDESP, @cTipoCnt, @cPrograma, @IN_TIPO,
                    @IN_TPSALDO, @IN_CASA1,  @IN_CASA2, @IN_CASA3, @IN_CASA4,   @IN_CASA5
                    ##FIELDP01( 'SN3.N3_VORIG6' )
                    , @nValDepr6,   @IN_CASA6
                    ##ENDFIELDP01
                    ##FIELDP02( 'SN3.N3_VORIG7' )
                   , @nValDepr7,   @IN_CASA7
                    ##ENDFIELDP02
                    ##FIELDP03( 'SN3.N3_VORIG8' )
                    , @nValDepr8,   @IN_CASA8
                    ##ENDFIELDP03
                    ##FIELDP04( 'SN3.N3_VORIG9' )
                    , @nValDepr9,   @IN_CASA9
                    ##ENDFIELDP04
                    ##FIELDP05( 'SN3.N3_VORIG10' )
                    , @nValDepr10,   @IN_CASA10
                    ##ENDFIELDP05
                    ##FIELDP06( 'SN3.N3_VORIG11' )
                    , @nValDepr11,   @IN_CASA11
                    ##ENDFIELDP06
                    ##FIELDP07( 'SN3.N3_VORIG12' )
                    , @nValDepr12,   @IN_CASA12
                    ##ENDFIELDP07
                    ##FIELDP08( 'SN3.N3_VORIG13' )
                    , @nValDepr13,   @IN_CASA13
                    ##ENDFIELDP08
                    ##FIELDP09( 'SN3.N3_VORIG14' )
                    , @nValDepr14,   @IN_CASA14
                    ##ENDFIELDP09
                    ##FIELDP10( 'SN3.N3_VORIG15' )
                    , @nValDepr15,   @IN_CASA15
                    ##ENDFIELDP10
    select @cTipoCnt    = '4'
    Exec ATF004_## @IN_FILIAL,  @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @IN_CCDEPR,  @IN_DATADEP, @cTipoSal,  @nValDepr1, @nValDepr2, @nValDepr3,
                    @nValDepr4,  @nValDepr5, @cSinal,   @nTxMedia, @IN_SUBCCDE, @IN_CLVLCDE, @IN_CCCDEP, @cTipoCnt, @cPrograma, @IN_TIPO,
                    @IN_TPSALDO, @IN_CASA1,  @IN_CASA2, @IN_CASA3, @IN_CASA4,   @IN_CASA5
                    ##FIELDP01( 'SN3.N3_VORIG6' )
                    , @nValDepr6,   @IN_CASA6
                    ##ENDFIELDP01
                    ##FIELDP02( 'SN3.N3_VORIG7' )
                   , @nValDepr7,   @IN_CASA7
                    ##ENDFIELDP02
                    ##FIELDP03( 'SN3.N3_VORIG8' )
                    , @nValDepr8,   @IN_CASA8
                    ##ENDFIELDP03
                    ##FIELDP04( 'SN3.N3_VORIG9' )
                    , @nValDepr9,   @IN_CASA9
                    ##ENDFIELDP04
                    ##FIELDP05( 'SN3.N3_VORIG10' )
                    , @nValDepr10,   @IN_CASA10
                    ##ENDFIELDP05
                    ##FIELDP06( 'SN3.N3_VORIG11' )
                    , @nValDepr11,   @IN_CASA11
                    ##ENDFIELDP06
                    ##FIELDP07( 'SN3.N3_VORIG12' )
                    , @nValDepr12,   @IN_CASA12
                    ##ENDFIELDP07
                    ##FIELDP08( 'SN3.N3_VORIG13' )
                    , @nValDepr13,   @IN_CASA13
                    ##ENDFIELDP08
                    ##FIELDP09( 'SN3.N3_VORIG14' )
                    , @nValDepr14,   @IN_CASA14
                    ##ENDFIELDP09
                    ##FIELDP10( 'SN3.N3_VORIG15' )
                    , @nValDepr15,   @IN_CASA15
                    ##ENDFIELDP10
    select @cTipoCnt = '5'
    select @cTipoSal = '7'
    Exec ATF004_## @IN_FILIAL,  @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @IN_CDESP,   @IN_DATADEP, @cTipoSal,  @nValCorDep, @nVlRoc2, @nVlRoc3,
                    @nVlRoc4,    @nVlRoc5,   @cSinal,   @nTxMedia, @IN_SUBCDES, @IN_CLVLDES, @IN_CCCDES, @cTipoCnt, @cPrograma, @IN_TIPO,
                    @IN_TPSALDO, @IN_CASA1,  @IN_CASA2, @IN_CASA3, @IN_CASA4,   @IN_CASA5
                    ##FIELDP01( 'SN3.N3_VORIG6' )
                    , @nVlRoc6,   @IN_CASA6
                    ##ENDFIELDP01
                    ##FIELDP02( 'SN3.N3_VORIG7' )
                   , @nVlRoc7,   @IN_CASA7
                    ##ENDFIELDP02
                    ##FIELDP03( 'SN3.N3_VORIG8' )
                    , @nVlRoc8,   @IN_CASA8
                    ##ENDFIELDP03
                    ##FIELDP04( 'SN3.N3_VORIG9' )
                    , @nVlRoc9,   @IN_CASA9
                    ##ENDFIELDP04
                    ##FIELDP05( 'SN3.N3_VORIG10' )
                    , @nVlRoc10,   @IN_CASA10
                    ##ENDFIELDP05
                    ##FIELDP06( 'SN3.N3_VORIG11' )
                    , @nVlRoc11,   @IN_CASA11
                    ##ENDFIELDP06
                    ##FIELDP07( 'SN3.N3_VORIG12' )
                    , @nVlRoc12,   @IN_CASA12
                    ##ENDFIELDP07
                    ##FIELDP08( 'SN3.N3_VORIG13' )
                    , @nVlRoc13,   @IN_CASA13
                    ##ENDFIELDP08
                    ##FIELDP09( 'SN3.N3_VORIG14' )
                    , @nVlRoc14,   @IN_CASA14
                    ##ENDFIELDP09
                    ##FIELDP10( 'SN3.N3_VORIG15' )
                    , @nVlRoc15,   @IN_CASA15
                    ##ENDFIELDP10
    select @cTipoCnt = '4'
    Exec ATF004_## @IN_FILIAL,  @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @IN_CCDEPR,  @IN_DATADEP, @cTipoSal,  @nValCorDep, @nVlRoc2, @nVlRoc3,
                    @nVlRoc4,    @nVlRoc5,   @cSinal,   @nTxMedia, @IN_SUBCCDE, @IN_CLVLCDE, @IN_CCCDEP, @cTipoCnt, @cPrograma, @IN_TIPO,
                    @IN_TPSALDO, @IN_CASA1,  @IN_CASA2, @IN_CASA3, @IN_CASA4,   @IN_CASA5
                    ##FIELDP01( 'SN3.N3_VORIG6' )
                    , @nVlRoc6,   @IN_CASA6
                    ##ENDFIELDP01
                    ##FIELDP02( 'SN3.N3_VORIG7' )
                   , @nVlRoc7,   @IN_CASA7
                    ##ENDFIELDP02
                    ##FIELDP03( 'SN3.N3_VORIG8' )
                    , @nVlRoc8,   @IN_CASA8
                    ##ENDFIELDP03
                    ##FIELDP04( 'SN3.N3_VORIG9' )
                    , @nVlRoc9,   @IN_CASA9
                    ##ENDFIELDP04
                    ##FIELDP05( 'SN3.N3_VORIG10' )
                    , @nVlRoc10,   @IN_CASA10
                    ##ENDFIELDP05
                    ##FIELDP06( 'SN3.N3_VORIG11' )
                    , @nVlRoc11,   @IN_CASA11
                    ##ENDFIELDP06
                    ##FIELDP07( 'SN3.N3_VORIG12' )
                    , @nVlRoc12,   @IN_CASA12
                    ##ENDFIELDP07
                    ##FIELDP08( 'SN3.N3_VORIG13' )
                    , @nVlRoc13,   @IN_CASA13
                    ##ENDFIELDP08
                    ##FIELDP09( 'SN3.N3_VORIG14' )
                    , @nVlRoc14,   @IN_CASA14
                    ##ENDFIELDP09
                    ##FIELDP10( 'SN3.N3_VORIG15' )
                    , @nVlRoc15,   @IN_CASA15
                    ##ENDFIELDP10
End
