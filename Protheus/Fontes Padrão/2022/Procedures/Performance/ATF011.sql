Create Procedure ATF011_##
(  
   @IN_FILIAL    Char( 'N3_FILIAL' ),
   @IN_CPAISLOC  Char( 03 ),
   @IN_CBASE     Char( 'N3_CBASE' ),
   @IN_ITEM      Char( 'N3_ITEM' ),
   @IN_CCDEPR    Char( 'N3_CCDEPR' ),
   @IN_CDEPREC   Char( 'N3_CDEPREC' ),
   @IN_CCORREC   Char( 'N3_CCORREC' ),
   @IN_CDESP     Char( 'N3_CDESP' ),
   @IN_DINDEPR   Char( 08 ),
   @IN_DATADEP   Char( 08 ),
   @IN_AQUISIC   Char( 08 ),
   @IN_DTBAIXA   Char( 08 ),  -- VER
   @IN_TXDEPR1   Float,
   @IN_TXDEPR2   Float,
   @IN_TXDEPR3   Float,
   @IN_TXDEPR4   Float,
   @IN_TXDEPR5   Float,
   @IN_RECNOSN3  integer,
   @IN_TPDEPR    Char( 01 ),
   @IN_YTD       integer,
   @IN_PRODMES   Float,
   @IN_PRODANC   Float,
   @IN_LFUNDADA  Char( 01 ),
   @IN_MOEDAATF  Char( 02 ), 
   @IN_LCORRECAO Char( 01 ),
   @IN_VCORRECAO Float,
   @IN_TXDEPOK   Float,
   @IN_LEYDL824  Char( 01 ),
   @IN_LMESCHEIO Char( 01 ),
   @IN_ATFMBLOQ  Char( 01 ), 
   @IN_CALCDEP   Char( 01 ),
   @IN_PERDEPR   Float,
   @IN_PRODANO   Float,
   @IN_DEPACM1   Float,
   @IN_VORIG1    Float,
   @IN_VLSALV    Float,
   @IN_ATFMDMX   Char( 02 ),
   @IN_CODIND    Char( 08 ),
   ##FIELDP04( 'SN3.N3_VORIG6' )
   @IN_TXDEPR6 Float,
   ##ENDFIELDP04
   ##FIELDP05( 'SN3.N3_VORIG7' )
   @IN_TXDEPR7 Float,
   ##ENDFIELDP05
   ##FIELDP06( 'SN3.N3_VORIG8' )
   @IN_TXDEPR8 Float,
    ##ENDFIELDP06
   ##FIELDP07( 'SN3.N3_VORIG9' )
   @IN_TXDEPR9 Float,
   ##ENDFIELDP07
   ##FIELDP08( 'SN3.N3_VORIG10' )
   @IN_TXDEPR10 Float,
   ##ENDFIELDP08
   ##FIELDP09( 'SN3.N3_VORIG11' )
   @IN_TXDEPR11 Float,
   ##ENDFIELDP09
   ##FIELDP10( 'SN3.N3_VORIG12' )
   @IN_TXDEPR12 Float,
   ##ENDFIELDP10
   ##FIELDP11( 'SN3.N3_VORIG13' )
   @IN_TXDEPR13 Float,
   ##ENDFIELDP11
   ##FIELDP12( 'SN3.N3_VORIG14' )
   @IN_TXDEPR14 Float,
   ##ENDFIELDP12
   ##FIELDP13( 'SN3.N3_VORIG15' )
   @IN_TXDEPR15 Float,
   ##ENDFIELDP13
   @OUT_VALDEP1  Float OutPut,
   @OUT_VALDEP2  Float OutPut,
   @OUT_VALDEP3  Float OutPut,
   @OUT_VALDEP4  Float OutPut,
   @OUT_VALDEP5  Float OutPut,
   @OUT_COR      Float OutPut,
   @OUT_CORDEP   Float OutPut,
   @OUT_TXMEDIA  Float OutPut,
   @OUT_TXDEP    Float OutPut
    ##FIELDP04( 'SN3.N3_VORIG6' )
    , @OUT_VALDEP6  Float OutPut
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG7' )
    , @OUT_VALDEP7  Float OutPut
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG8' )
    , @OUT_VALDEP8  Float OutPut
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG9' )
    , @OUT_VALDEP9  Float OutPut
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG10' )
    , @OUT_VALDEP10  Float OutPut
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG11' )
    , @OUT_VALDEP11  Float OutPut
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG12' )
    , @OUT_VALDEP12  Float OutPut
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG13' )
    , @OUT_VALDEP13  Float OutPut
    ##ENDFIELDP11
    ##FIELDP12( 'SN3.N3_VORIG14' )
    , @OUT_VALDEP14  Float OutPut
    ##ENDFIELDP12
    ##FIELDP13( 'SN3.N3_VORIG15' )
    , @OUT_VALDEP15  Float OutPut
    ##ENDFIELDP13
)
as
/*
 ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus 9.12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ATFA050.PRW </s>
    Descricao       - <d>  REtorna as depreciacoes para as moedas de 1 a 5 </d>
    Funcao do Siga  -      Atfa050()
    Entrada         - <ri> @IN_FILIAL    - Filial
                           @IN_CPAISLOC  - Localizacao
                           @IN_CBASE     - Codigo base do ativo
                           @IN_ITEM      - Item do Ativo
                           @IN_CCDEPR    - Conta de Correcao da Depreciação
                           @IN_CDEPREC   - Somente para lfundada
                           @IN_CCORREC   - Conta de Correção do Ativo
                           @IN_CDESP     - Conta de Despesa de Depreciação
                           @IN_DINDEPR   - Data de inicio de Depreciação
                           @IN_DATADEP   - Data do Cálculo de Deprecição
                           @IN_AQUISIC   - Data de Aquisição do Ativo
                           @IN_TXDEPR1   - Taxa de Depreciação do Ativo na Moeda 1
                           @IN_TXDEPR2   - Taxa de Depreciação do Ativo na Moeda 2
                           @IN_TXDEPR3   - Taxa de Depreciação do Ativo na Moeda 3
                           @IN_TXDEPR4   - Taxa de Depreciação do Ativo na Moeda 4
                           @IN_TXDEPR5   - Taxa de Depreciação do Ativo na Moeda 5
                           @IN_RECNOSN3  - Nro do Recno no SN3 a calcular a Deprecição
                           @IN_TPDEPR    - Tipo de depreciação 
                           @IN_YTD       - 
                           @IN_PRODMES   - Producao Mensal
                           @IN_PRODANC   -
                           @IN_LFUNDADA  - Safra Fundada
                           @IN_MOEDAATF  - Moeda do Ativo
                           @IN_LCORRECAO - '1' Calcula Correcao, '0' nao calcula
                           @IN_VCORRECAO - taxa utilizada no calculo de correcao se > que zero
                           @IN_TXDEPOK   - Mv_par05
                           @IN_LEYDL824  - CHILE
                           @IN_LMESCHEIO - Argentina
                           @IN_ATFMBLOQ  - '1' proporcional ao tempo que falta no mes, '0' bloqueio total
                           @IN_CALCDEP   - '0' Calc de Depr Mensal, '1' Calc de Deprec Anual
                           @IN_PERDEPR   - Nro de periodos a depreciar - Mensal ou anual
                           @IN_PRODANO   - Producao estimada em funcao da vida util
                           @IN_DEPACM1   - Valor da Depreciação Acumulada
                           @IN_VORIG1    - Valor original na moeda 1
                           @IN_VLSALV    - Valor de Salvamento
                           @IN_ATFMDMX   - Moeda do Valor Máximo de Depreciacao
                           @IN_CODIND    - Código do Indice de depreciacao
    Saida           - <o>  @OUT_VALDEP1  - Valor da depreciação na moeda 1
                           @OUT_VALDEP2  - Valor da depreciação na moeda 2
                           @OUT_VALDEP3  - Valor da depreciação na moeda 3
                           @OUT_VALDEP4  - Valor da depreciação na moeda 4
                           @OUT_VALDEP5  - Valor da depreciação na moeda 5
                           @OUT_COR      - Valor da correcao do bem
                           @OUT_CORDEP   - Valor da correcao da depreciacao
                           @OUT_TXMEDIA  - Taxa usada
                           @OUT_TXDEP    - Tx de depreciacao usada </ro>
    Responsavel :     <r>  Alice 	</r>
---------------------------------------------------------------------------------------------------------------- */
Declare @cAux        Char( 03 )
Declare @cFilial_SN1 Char( 'N1_FILIAL' )
Declare @cFilial_SNG Char( 'NG_FILIAL' )
Declare @cDTBLOQ     Char( 08 )
Declare @cN1_PATRIM  Char( 'N1_PATRIM' )
Declare @cN1_GRUPO   Char( 'N1_GRUPO' )
Declare @cN1_CONSAB  Char( 'N1_CONSAB' )
Declare @cNG_DTBLOQ  Char( 08 )
Declare @cNG_GRUPO   Char( 'N1_GRUPO' )
Declare @lCalcDep    Char( 01 )
Declare @cMescheio   Char( 01 )
Declare @cDataIniDep Char( 08 )
Declare @cDataF      Char( 08 )
Declare @lCalcCor    Char( 01 )
Declare @nValDepr1   Float
Declare @nValDepr2   Float
Declare @nValDepr3   Float
Declare @nValDepr4   Float
Declare @nValDepr5   Float
Declare @nTaxCor     Float
Declare @iRecnoSN1   integer
Declare @iRecnoSNG   integer
Declare @iNroDias    integer
Declare @nUltimoDia  integer
Declare @nTxDep      float
Declare @nTxDep1     float
Declare @nTxDep2     float
Declare @nTxDep3     float
Declare @nTxDep4     float
Declare @nTxDep5     float
Declare @nValCor     Float
Declare @nValCorDep  Float
Declare @nTxMedia    Float
Declare @nA30EMBRA   Float
Declare @lCalDep     char( 01 )
Declare @iPerTpr     Integer
Declare @iNroIPC     Integer
Declare @cN1_STATUS   Char( 01 ) 
##FIELDP04( 'SN3.N3_VORIG6' )
Declare @nValDepr6   Float
Declare @nTxDep6     float
##ENDFIELDP04
##FIELDP05( 'SN3.N3_VORIG7' )
Declare @nValDepr7   Float
Declare @nTxDep7     float
##ENDFIELDP05
##FIELDP06( 'SN3.N3_VORIG8' )
Declare @nValDepr8   Float
Declare @nTxDep8     float
##ENDFIELDP06
##FIELDP07( 'SN3.N3_VORIG9' )
Declare @nValDepr9   Float
Declare @nTxDep9     float
##ENDFIELDP07
##FIELDP08( 'SN3.N3_VORIG10' )
Declare @nValDepr10   Float
Declare @nTxDep10     float
##ENDFIELDP08
##FIELDP09( 'SN3.N3_VORIG11' )
Declare @nValDepr11   Float
Declare @nTxDep11     float
##ENDFIELDP09
##FIELDP10( 'SN3.N3_VORIG12' )
Declare @nValDepr12   Float
Declare @nTxDep12     float
##ENDFIELDP10
##FIELDP11( 'SN3.N3_VORIG13' )
Declare @nValDepr13   Float
Declare @nTxDep13     float
##ENDFIELDP11
##FIELDP12( 'SN3.N3_VORIG14' )
Declare @nValDepr14   Float
Declare @nTxDep14     float
##ENDFIELDP12
##FIELDP13( 'SN3.N3_VORIG15' )
Declare @nValDepr15   Float
Declare @nTxDep15     float
##ENDFIELDP13

Declare @cN3BAIXA Char(01)
Declare @cN3NOVO Char(01)

Begin
    select @cAux = 'SN1'
    exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_SN1 OutPut
    select @cAux = 'SNG'
    exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_SNG OutPut
   
    select @lCalcCor = '0' 
    select @lCalDep  = '1'
    select @iPerTpr  = 0
    select @iNroIPC  = 0
    select @nUltimoDia   = Convert( integer, Substring( @IN_DATADEP, 7, 2) )
    If (( @IN_LCORRECAO = '1' and @IN_VCORRECAO > 0 ) or (@IN_DATADEP < '19960101')) select @lCalcCor = '1' 
    If @IN_LMESCHEIO = '1' select @cMescheio = '1'
    else select @cMescheio = '0'
   
    select @nValDepr1 = 0
    select @nValDepr2 = 0
    select @nValDepr3 = 0
    select @nValDepr4 = 0
    select @nValDepr5 = 0
    select @iRecnoSN1 = 0
    select @iRecnoSNG = 0
    select @nTxDep    = 0
    select @nTxDep1   = 0
    select @nTxDep2   = 0
    select @nTxDep3   = 0
    select @nTxDep4   = 0
    select @nTxDep5   = 0
    select @nValCor   = 0
    select @nValCorDep= 0
    select @nTxMedia  = 0
    select @nA30EMBRA = 0
    select @lCalcDep  = '1'
    select @cDataIniDep = ' '
    select @cDataF      = ' '
    select @cN1_STATUS  = ' '
    ##FIELDP04( 'SN3.N3_VORIG6' )
    select @nValDepr6  = 0
    select @nTxDep6    = 0
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG7' )
    select @nValDepr7  = 0
    select @nTxDep7    = 0
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG8' )
    select @nValDepr8  = 0
    select @nTxDep8    = 0
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG9' )
    select @nValDepr9  = 0
    select @nTxDep9    = 0
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG10' )
    select @nValDepr10  = 0
    select @nTxDep10    = 0
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG11' )
    select @nValDepr11  = 0
    select @nTxDep11    = 0
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG12' )
    select @nValDepr12  = 0
    select @nTxDep12    = 0
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG13' )
    select @nValDepr13  = 0
    select @nTxDep13    = 0
    ##ENDFIELDP11
    ##FIELDP12( 'SN3.N3_VORIG14' )
    select @nValDepr14  = 0
    select @nTxDep14    = 0
    ##ENDFIELDP12
    ##FIELDP13( 'SN3.N3_VORIG15' )
    select @nValDepr15  = 0
    select @nTxDep15    = 0
    ##ENDFIELDP13
    
    Select @cN3BAIXA    = ' '
    Select @cN3NOVO     = ' '

    If @IN_LMESCHEIO = '2' and @IN_DTBAIXA != ' ' select @lCalcDep = '0'  -- Ripasa nao calc dep na baixa
   
    /* ---------------------------------------------------------------------------------
        Verifico se está no SN1 e atende aos requistos de cálculo ATFBLOQUEIO 
        ---------------------------------------------------------------------------------*/
    If @lCalDep = '1' begin
        Select @cDTBLOQ = N1_DTBLOQ, @cN1_PATRIM = N1_PATRIM,
                @cN1_GRUPO = N1_GRUPO, @iRecnoSN1 = R_E_C_N_O_
            ##FIELDP01( 'SN1.N1_CONSAB' )
                    , @cN1_CONSAB = N1_CONSAB
            ##ENDFIELDP01
            ##FIELDP03( 'SN1.N1_STATUS' )
                    , @cN1_STATUS = N1_STATUS
            ##ENDFIELDP03
        From SN1###
        Where N1_FILIAL   = @cFilial_SN1
            and N1_CBASE    = @IN_CBASE
            and N1_ITEM     = @IN_ITEM
            and N1_DTBLOQ   < @IN_DATADEP
            and D_E_L_E_T_  = ' '
      
        Select @cNG_DTBLOQ  = ' '
        Select @cNG_GRUPO   = ' '
        If @iRecnoSN1 is not null begin
            Select @iRecnoSNG   = null
         
            Select @iRecnoSNG = R_E_C_N_O_
            From SNG###
            Where NG_FILIAL  = @cFilial_SNG
            and NG_GRUPO   = @cN1_GRUPO
            and NG_DTBLOQ  < @IN_DATADEP
            and D_E_L_E_T_ = ' '
         
            If @iRecnoSNG is not null begin
            Select @cNG_DTBLOQ = NG_DTBLOQ, @cNG_GRUPO = NG_GRUPO
                From SNG###
                Where R_E_C_N_O_ = @iRecnoSNG
            End
        end else begin
            select @lCalcDep = '0'
        end
    End
   
    If ( @cN1_PATRIM !=  ' ' and @cN1_PATRIM NOT IN ('N','D','I','O','T','E') ) begin
        select @lCalcDep = '0'
    End
   
    If @lCalcDep = '1' and @cN1_STATUS NOT IN (' ' ,'1') begin
	    select @lCalcDep = '0'
    End
   
    If @lCalcDep = '1' begin
        If @cDTBLOQ = ' ' and ( @cN1_GRUPO = @cNG_GRUPO ) and @cNG_DTBLOQ != ' ' begin
            Select @cDTBLOQ = @cNG_DTBLOQ
        End
        /* --------------------------------------------------------------------------------------
            Se data de bloqueio = '' ou data de bloqueio != '' e data de bloqueio < Data de calculo
            @lCalcDep = '1'
            -------------------------------------------------------------------------------------- */
        If ( @cDTBLOQ = ' ' or ( @cDTBLOQ != ' ' and ( SubString(@cDTBLOQ, 1,6 ) <= SubString(@IN_DATADEP, 1,6 )) )) begin
            select @lCalcDep = '1'
        end else begin
            select @lCalcDep = '0'
        end
      
    End
    /* ----------------------------------------------------------------------------------
        Traz a data inicio de depreciacao -  mes cheio ou proporcional a data de aquisiçao
        01         dt IniDep       dt Bloqueio                        30/31-XX 
        |-------------|--------------|---------------------------------|  
        Se mescheio calculo desde o dia 1
        Se não é mes cheio -> considera a dta inicio de depr.
        ---------------------------------------------------------------------------------- */
    If @lCalcDep = '1' begin
        If @IN_CPAISLOC = 'ARG' and @cN1_CONSAB = '1'  select @cMescheio = '1'
            
        select @cDataIniDep = Substring( @IN_DATADEP, 1, 6 )||'01'
        Select @cDataF = @IN_DATADEP
      
        If @cMescheio = '0' begin
            /* ----------------------------------------------------------------------------------
      	    Verifica qual será a data inicio de depreciação qdo existir bx ou bloqueio no mes
                ---------------------------------------------------------------------------------- */
            If ( SubString(@IN_DINDEPR, 1,6 ) = SubString(@IN_DATADEP, 1,6 )) begin
            If @IN_DINDEPR > @cDataIniDep select @cDataIniDep = @IN_DINDEPR
            end
            If @cDTBLOQ != ' ' and ( SubString(@cDTBLOQ, 1,6 ) = SubString(@IN_DATADEP, 1,6 )) begin
            If @cDTBLOQ > @cDataIniDep select @cDataIniDep = @cDTBLOQ
            End
            If @IN_DTBAIXA != ' ' and ( SubString(@IN_DTBAIXA, 1,6 ) = SubString(@IN_DATADEP, 1,6 )) begin
            If @IN_DTBAIXA > @cDataIniDep select @cDataF = @IN_DTBAIXA
            End
        End
    End
    If @lCalcDep = '1' begin
        /* ----------------------------------------------------------------------------------
   	    Somente deprecia se TODAS as contas foram informadas
            ---------------------------------------------------------------------------------- */
        If @IN_CCDEPR = ' ' or @IN_CDEPREC = ' ' begin
            select @lCalcDep = '0'
        End
        /* ----------------------------------------------------------------------------------
            Tratamento para o OpenEdge
            --------------------------------------------------------------------------------- */
        ##IF_001({|| AllTrim(Upper(TcGetDB())) <> "OPENEDGE" })
        Select @iNroDias = ( DATEDIFF ( DAY , @cDataIniDep, @cDataF ) )
	    ##ELSE_001
	    EXEC MSDATEDIFF 'DAY', @cDataIniDep, @cDataF, @iNroDias OutPut
	    ##ENDIF_001
	  
        select @nValDepr1 = 0
        select @nValDepr2 = 0
        select @nValDepr3 = 0
        select @nValDepr4 = 0
        select @nValDepr5 = 0
        select @nTaxCor   = 0
	    select @iNroDias  = @iNroDias + 1
        ##FIELDP04( 'SN3.N3_VORIG6' )
        select @nValDepr6  = 0
        ##ENDFIELDP04
        ##FIELDP05( 'SN3.N3_VORIG7' )
        select @nValDepr7  = 0
        ##ENDFIELDP05
        ##FIELDP06( 'SN3.N3_VORIG8' )
        select @nValDepr8  = 0
        ##ENDFIELDP06
        ##FIELDP07( 'SN3.N3_VORIG9' )
        select @nValDepr9  = 0
        ##ENDFIELDP07
        ##FIELDP08( 'SN3.N3_VORIG10' )
        select @nValDepr10  = 0
        ##ENDFIELDP08
        ##FIELDP09( 'SN3.N3_VORIG11' )
        select @nValDepr11  = 0
        ##ENDFIELDP09
        ##FIELDP10( 'SN3.N3_VORIG12' )
        select @nValDepr12  = 0
        ##ENDFIELDP10
        ##FIELDP11( 'SN3.N3_VORIG13' )
        select @nValDepr13  = 0
        ##ENDFIELDP11
        ##FIELDP12( 'SN3.N3_VORIG14' )
        select @nValDepr14  = 0
        ##ENDFIELDP12
        ##FIELDP13( 'SN3.N3_VORIG15' )
        select @nValDepr15  = 0
        ##ENDFIELDP13

        Select @cN3BAIXA = N3_BAIXA, @cN3NOVO = N3_NOVO From SN3###
		Where D_E_L_E_T_ = ' ' and R_E_C_N_O_ = @IN_RECNOSN3

        If @cN3BAIXA = '1' and @cN3NOVO = '1' Begin        
            Select @lCalcDep = '0'
        End

        If @IN_CPAISLOC != 'CHI' begin
            /* --------------------------------------------------------------------------------------
            Calc de Depreciacoes e correcoes para paises diferentes de CHILE
            -------------------------------------------------------------------------------------- */
            If @lCalcDep = '1' begin
                /* ----------------------------------------------------------------------------------
                    Valor da taxa de depreciacao Mensal p/ as moedas @nTxDepr1,..5
                   ---------------------------------------------------------------------------------- */
                Exec ATF002_## @IN_CPAISLOC, @IN_DATADEP, @IN_TPDEPR,  @IN_DINDEPR, @IN_CDEPREC, @IN_LFUNDADA, @IN_CALCDEP,
                                @IN_PERDEPR,  @IN_TXDEPR1, @IN_TXDEPR2, @IN_TXDEPR3, @IN_TXDEPR4, @IN_TXDEPR5, @IN_YTD,
                                @IN_PRODMES,  @IN_PRODANC, @IN_PRODANO, @IN_DEPACM1, @IN_VORIG1,  @IN_VLSALV, @IN_CODIND
                                ##FIELDP04( 'SN3.N3_VORIG6' )
                                ,@IN_TXDEPR6
                                ##ENDFIELDP04
                                ##FIELDP05( 'SN3.N3_VORIG7' )
                                ,@IN_TXDEPR7
                                ##ENDFIELDP05
                                ##FIELDP06( 'SN3.N3_VORIG8' )
                                ,@IN_TXDEPR8
                                ##ENDFIELDP06
                                ##FIELDP07( 'SN3.N3_VORIG9' )
                                ,@IN_TXDEPR9
                                ##ENDFIELDP07
                                ##FIELDP08( 'SN3.N3_VORIG10' )
                                ,@IN_TXDEPR10
                                ##ENDFIELDP08
                                ##FIELDP09( 'SN3.N3_VORIG11' )
                                ,@IN_TXDEPR11
                                ##ENDFIELDP09
                                ##FIELDP10( 'SN3.N3_VORIG12' )
                                ,@IN_TXDEPR12
                                ##ENDFIELDP10
                                ##FIELDP11( 'SN3.N3_VORIG13' )
                                ,@IN_TXDEPR13
                                ##ENDFIELDP11
                                ##FIELDP12( 'SN3.N3_VORIG14' )
                                ,@IN_TXDEPR14
                                ##ENDFIELDP12
                                ##FIELDP13( 'SN3.N3_VORIG15' )
                                ,@IN_TXDEPR15
                                ##ENDFIELDP13
                                , @nTxDep1 OutPut,@nTxDep2 OutPut, @nTxDep3 OutPut, @nTxDep4 OutPut, @nTxDep5 OutPut, @iPerTpr OutPut
                                ##FIELDP04( 'SN3.N3_VORIG6' )
                                , @nTxDep6 OutPut
                                ##ENDFIELDP04
                                ##FIELDP05( 'SN3.N3_VORIG7' )
                                , @nTxDep7 OutPut
                                ##ENDFIELDP05
                                ##FIELDP06( 'SN3.N3_VORIG8' )
                                , @nTxDep8 OutPut
                                ##ENDFIELDP06
                                ##FIELDP07( 'SN3.N3_VORIG9' )
                                , @nTxDep9 OutPut
                                ##ENDFIELDP07
                                ##FIELDP08( 'SN3.N3_VORIG10' )
                                , @nTxDep10 OutPut
                                ##ENDFIELDP08
                                ##FIELDP09( 'SN3.N3_VORIG11' )
                                , @nTxDep11 OutPut
                                ##ENDFIELDP09
                                ##FIELDP10( 'SN3.N3_VORIG12' )
                                , @nTxDep12 OutPut
                                ##ENDFIELDP10
                                ##FIELDP11( 'SN3.N3_VORIG13' )
                                , @nTxDep13 OutPut
                                ##ENDFIELDP11
                                ##FIELDP12( 'SN3.N3_VORIG14' )
                                , @nTxDep14 OutPut
                                ##ENDFIELDP12
                                ##FIELDP13( 'SN3.N3_VORIG15' )
                                , @nTxDep15 OutPut
                                ##ENDFIELDP13
                select @iNroIPC = @iPerTpr
                /* ----------------------------------------------------------------------------------
                    Calcula e retorna os valores das depreciacoes nas Moedas 1,..,5
                    ---------------------------------------------------------------------------------- */
                Exec ATF006_## @nTxDep1, @nTxDep2, @nTxDep3, @nTxDep4, @nTxDep5, @cMescheio, @iNroDias, @nUltimoDia, @IN_RECNOSN3, @IN_ATFMDMX, @iNroIPC, @IN_CODIND
                                ##FIELDP04( 'SN3.N3_VORIG6' )
                                , @nTxDep6
                                ##ENDFIELDP04
                                ##FIELDP05( 'SN3.N3_VORIG7' )
                                , @nTxDep7
                                ##ENDFIELDP05
                                ##FIELDP06( 'SN3.N3_VORIG8' )
                                , @nTxDep8
                                ##ENDFIELDP06
                                ##FIELDP07( 'SN3.N3_VORIG9' )
                                , @nTxDep9
                                ##ENDFIELDP07
                                ##FIELDP08( 'SN3.N3_VORIG10' )
                                , @nTxDep10
                                ##ENDFIELDP08
                                ##FIELDP09( 'SN3.N3_VORIG11' )
                                , @nTxDep11
                                ##ENDFIELDP09
                                ##FIELDP10( 'SN3.N3_VORIG12' )
                                , @nTxDep12
                                ##ENDFIELDP10
                                ##FIELDP11( 'SN3.N3_VORIG13' )
                                , @nTxDep13
                                ##ENDFIELDP11
                                ##FIELDP12( 'SN3.N3_VORIG14' )
                                , @nTxDep14
                                ##ENDFIELDP12
                                ##FIELDP13( 'SN3.N3_VORIG15' )
                                , @nTxDep15
                                ##ENDFIELDP13                            
                                , @nValDepr1 OutPut, @nValDepr2 OutPut, @nValDepr3 OutPut, @nValDepr4 OutPut, @nValDepr5 OutPut
                                ##FIELDP04( 'SN3.N3_VORIG6' )
                                , @nValDepr6 OutPut
                                ##ENDFIELDP04
                                ##FIELDP05( 'SN3.N3_VORIG7' )
                                , @nValDepr7 OutPut
                                ##ENDFIELDP05
                                ##FIELDP06( 'SN3.N3_VORIG8' )
                                , @nValDepr8 OutPut
                                ##ENDFIELDP06
                                ##FIELDP07( 'SN3.N3_VORIG9' )
                                , @nValDepr9 OutPut
                                ##ENDFIELDP07
                                ##FIELDP08( 'SN3.N3_VORIG10' )
                                , @nValDepr10 OutPut
                                ##ENDFIELDP08
                                ##FIELDP09( 'SN3.N3_VORIG11' )
                                , @nValDepr11 OutPut
                                ##ENDFIELDP09
                                ##FIELDP10( 'SN3.N3_VORIG12' )
                                , @nValDepr12 OutPut
                                ##ENDFIELDP10
                                ##FIELDP11( 'SN3.N3_VORIG13' )
                                , @nValDepr13 OutPut
                                ##ENDFIELDP11
                                ##FIELDP12( 'SN3.N3_VORIG14' )
                                , @nValDepr14 OutPut
                                ##ENDFIELDP12
                                ##FIELDP13( 'SN3.N3_VORIG15' )
                                , @nValDepr15 OutPut
                                ##ENDFIELDP13
            End
            /* ----------------------------------------------------------------------------------
            Calculo da Tx de Correção - @nTaxCor
            ---------------------------------------------------------------------------------- */
            Select @nValCor     = 0
            Select @nValCorDep  = 0
            /* ----------------------------------------------------------------------------------
            Se @lCalcCor = '1' ( calc correcao) se @IN_LCORRECAO = '1' or @IN_DATADEP < '19960101'
            ---------------------------------------------------------------------------------- */
            If ( @lCalcCor = '1' and @IN_CCORREC != ' ' and  @IN_CDESP != ' ' ) begin
                /* ----------------------------------------------------------------------------------
                    Retorna o valor da Taxa de correcao
                    ---------------------------------------------------------------------------------- */
                Exec ATF007_## @IN_CPAISLOC, @IN_MOEDAATF, @IN_LCORRECAO, @IN_VCORRECAO, @IN_DATADEP,  @IN_AQUISIC, @cDataIniDep, @cDataF,
                                @IN_LEYDL824, @IN_FILIAL,   @iNroDias,     @IN_TXDEPOK,   @IN_RECNOSN3, @nTxMedia OutPut, @nTaxCor OutPut
                /* ----------------------------------------------------------------------------------
                    Ponto de entrada - A30EMBRA
                    ---------------------------------------------------------------------------------- */
                select @nA30EMBRA = @nTxMedia
                Exec A30EMBRA_## @nA30EMBRA, @nTxMedia OutPut
                If @nTaxCor != 0 begin
                    /* ----------------------------------------------------------------------------------
                        Retorna os valores das Correcoes da Depreciacao e do Ativo
                        ---------------------------------------------------------------------------------- */
                        Exec ATF008_## @IN_MOEDAATF, @nTaxCor, @IN_RECNOSN3, @nValDepr1, @nValDepr2, @nValDepr3, @nValDepr4, @nValDepr5
                                    ##FIELDP04( 'SN3.N3_VORIG6' )
                                    , @nValDepr6 
                                    ##ENDFIELDP04
                                    ##FIELDP05( 'SN3.N3_VORIG7' )
                                    , @nValDepr7
                                    ##ENDFIELDP05
                                    ##FIELDP06( 'SN3.N3_VORIG8' )
                                    , @nValDepr8
                                    ##ENDFIELDP06
                                    ##FIELDP07( 'SN3.N3_VORIG9' )
                                    , @nValDepr9
                                    ##ENDFIELDP07
                                    ##FIELDP08( 'SN3.N3_VORIG10' )
                                    , @nValDepr10
                                    ##ENDFIELDP08
                                    ##FIELDP09( 'SN3.N3_VORIG11' )
                                    , @nValDepr11
                                    ##ENDFIELDP09
                                    ##FIELDP10( 'SN3.N3_VORIG12' )
                                    , @nValDepr12
                                    ##ENDFIELDP10
                                    ##FIELDP11( 'SN3.N3_VORIG13' )
                                    , @nValDepr13
                                    ##ENDFIELDP11
                                    ##FIELDP12( 'SN3.N3_VORIG14' )
                                    , @nValDepr14
                                    ##ENDFIELDP12
                                    ##FIELDP13( 'SN3.N3_VORIG15' )
                                    , @nValDepr15
                                    ##ENDFIELDP13
                                , @IN_DATADEP,  @nValCor OutPut, @nValCorDep OutPut
                end
            end
        end
        If @IN_MOEDAATF = '01' select @nTxDep = @nTxDep1
        If @IN_MOEDAATF = '02' select @nTxDep = @nTxDep2
        If @IN_MOEDAATF = '03' select @nTxDep = @nTxDep3
        If @IN_MOEDAATF = '04' select @nTxDep = @nTxDep4
        If @IN_MOEDAATF = '05' select @nTxDep = @nTxDep5
        ##FIELDP04( 'SN3.N3_VORIG6' )
        If @IN_MOEDAATF = '06' select @nTxDep = @nTxDep6
        ##ENDFIELDP04
        ##FIELDP05( 'SN3.N3_VORIG7' )
        If @IN_MOEDAATF = '07' select @nTxDep = @nTxDep7
        ##ENDFIELDP05
        ##FIELDP06( 'SN3.N3_VORIG8' )
        If @IN_MOEDAATF = '08' select @nTxDep = @nTxDep8
        ##ENDFIELDP06
        ##FIELDP07( 'SN3.N3_VORIG9' )
        If @IN_MOEDAATF = '09' select @nTxDep = @nTxDep9
        ##ENDFIELDP07
        ##FIELDP08( 'SN3.N3_VORIG10' )
        If @IN_MOEDAATF = '10' select @nTxDep = @nTxDep10
        ##ENDFIELDP08
        ##FIELDP09( 'SN3.N3_VORIG11' )
        If @IN_MOEDAATF = '11' select @nTxDep = @nTxDep11
        ##ENDFIELDP09
        ##FIELDP10( 'SN3.N3_VORIG12' )
        If @IN_MOEDAATF = '12' select @nTxDep = @nTxDep12
        ##ENDFIELDP10
        ##FIELDP11( 'SN3.N3_VORIG13' )
        If @IN_MOEDAATF = '13' select @nTxDep = @nTxDep13
        ##ENDFIELDP11
        ##FIELDP12( 'SN3.N3_VORIG14' )
        If @IN_MOEDAATF = '14' select @nTxDep = @nTxDep14
        ##ENDFIELDP12
        ##FIELDP13( 'SN3.N3_VORIG15' )
        If @IN_MOEDAATF = '15' select @nTxDep = @nTxDep15
        ##ENDFIELDP13
    End

    select @OUT_VALDEP1  = @nValDepr1
    select @OUT_VALDEP2  = @nValDepr2
    select @OUT_VALDEP3  = @nValDepr3
    select @OUT_VALDEP4  = @nValDepr4
    select @OUT_VALDEP5  = @nValDepr5
    select @OUT_COR      = @nValCor
    select @OUT_CORDEP   = @nValCorDep
    select @OUT_TXMEDIA  = @nTxMedia
    select @OUT_TXDEP    = @nTxDep
    ##FIELDP04( 'SN3.N3_VORIG6' )
    select @OUT_VALDEP6  = @nValDepr6
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG7' )
    select @OUT_VALDEP7  = @nValDepr7
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG8' )
    select @OUT_VALDEP8  = @nValDepr8
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG9' )
    select @OUT_VALDEP9  = @nValDepr9
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG10' )
    select @OUT_VALDEP10  = @nValDepr10
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG11' )
    select @OUT_VALDEP11  = @nValDepr11
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG12' )
    select @OUT_VALDEP12  = @nValDepr12
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG13' )
    select @OUT_VALDEP13  = @nValDepr13
    ##ENDFIELDP11
    ##FIELDP12( 'SN3.N3_VORIG14' )
    select @OUT_VALDEP14  = @nValDepr14
    ##ENDFIELDP12
    ##FIELDP13( 'SN3.N3_VORIG15' )
    select @OUT_VALDEP15  = @nValDepr15
    ##ENDFIELDP13
End
