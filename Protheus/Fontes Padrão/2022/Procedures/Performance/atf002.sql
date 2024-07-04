Create Procedure ATF002_##(
   @IN_CPAISLOC Char( 03 ),
   @IN_DATADEP  Char( 08 ),
   @IN_TPDEPR   Char( 01 ),
   @IN_DINDEPR  Char( 08 ),
   @IN_DEPREC   Char( 40 ),
   @IN_LFUNDADA Char( 01 ), 
   @IN_CALCDEP  Char( 01 ), 
   @IN_PERDEPR  Float,
   @IN_TXDEPR1  Float,
   @IN_TXDEPR2  Float,
   @IN_TXDEPR3  Float,
   @IN_TXDEPR4  Float,
   @IN_TXDEPR5  Float,
   @IN_YTD      Float,
   @IN_PRODMES  Float,
   @IN_PRODANC  Float,
   @IN_PRODANO  Float,
   @IN_DEPACM1  Float,
   @IN_VORIG1   Float,   
   @IN_VLSALV   Float,
   @IN_CODIND   Char( 08 ),
    ##FIELDP02( 'SN3.N3_VORIG6' )
    @IN_TXDEPR6 Float,
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG7' )
    @IN_TXDEPR7 Float,
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG8' )
    @IN_TXDEPR8 Float,
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG9' )
    @IN_TXDEPR9 Float,
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG10' )
    @IN_TXDEPR10 Float,
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG11' )
    @IN_TXDEPR11 Float,
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG12' )
    @IN_TXDEPR12 Float,
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG13' )
    @IN_TXDEPR13 Float,
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG14' )
    @IN_TXDEPR14 Float,
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG15' )
    @IN_TXDEPR15 Float,
    ##ENDFIELDP11
   @OUT_TXDEP1  Float OutPut,
   @OUT_TXDEP2  Float OutPut, 
   @OUT_TXDEP3  Float OutPut, 
   @OUT_TXDEP4  Float OutPut, 
   @OUT_TXDEP5  Float OutPut,
   @OUT_IPC     Integer outPut
    ##FIELDP02( 'SN3.N3_VORIG6' )
    , @OUT_TXDEP6  Float OutPut
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG7' )
    , @OUT_TXDEP7  Float OutPut
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG8' )
    , @OUT_TXDEP8  Float OutPut
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG9' )
    , @OUT_TXDEP9  Float OutPut
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG10' )
    , @OUT_TXDEP10  Float OutPut
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG11' )
    , @OUT_TXDEP11  Float OutPut
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG12' )
    , @OUT_TXDEP12  Float OutPut
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG13' )
    , @OUT_TXDEP13  Float OutPut
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG14' )
    , @OUT_TXDEP14  Float OutPut
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG15' )
    , @OUT_TXDEP15  Float OutPut
    ##ENDFIELDP11
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ATFA050.PRW </s>
    Descricao       - <d>  Calculo das Taxas de depreciaçao  </d>
    Funcao do Siga  -      Atfa050()
    Entrada         - <ri> @IN_CPAISLOC   - Pais
                           @IN_DATADEP    - Data de Processamento
                           @IN_DINDEPR    - Data inicio de depreciacao
                           @IN_TPDEPR     - N3_TIPDEPR tipo de depreciao
                           @IN_DEPREC     - usada em cjto com @IN_LFUNDADA
                           @IN_LFUNDADA   - Safra fundada
                           @IN_CALCDEP    - '0' Mensal, '1' - anual
                           @IN_PERDEPR    - Vida util do ativo
                           @IN_TXDEPR1    - Taxa de Depreciacao ANUAL na moeda 1
                           @IN_TXDEPR2    - Taxa de Depreciacao ANUAL na moeda 2
                           @IN_TXDEPR3    - Taxa de Depreciacao ANUAL na moeda 3
                           @IN_TXDEPR4    - Taxa de Depreciacao ANUAL na moeda 4
                           @IN_TXDEPR5    - Taxa de Depreciacao ANUAL na moeda 5
                           @IN_YTD        - float
                           @IN_PRODMES    - Producao mensal / hs trabalhadas
                           @IN_PRODANC    - 
                           @IN_PRODANO    - Producao/Hs estimadas na vida util 
                           @IN_DEPACM1    - Vlr Depr Acumulada
                           @IN_VORIG1     - Valor original
                           @IN_VLSALV     - Valor de Salvamento
                           @IN_CODIND    - Código do Indice de depreciacao
    Saida           - <o>  @OUT_TXDEP1    - Taxa mensal de depreciacao na moeda 1
                           @OUT_TXDEP2    - Taxa mensal de depreciacao na moeda 2
                           @OUT_TXDEP3    - Taxa mensal de depreciacao na moeda 3
                           @OUT_TXDEP4    - Taxa mensal de depreciacao na moeda 4
                           @OUT_TXDEP5    - Taxa mensal de depreciacao na moeda 5
                           @OUT_IPC       - Periodo calculado qdo n3_tpdepr = '6' Soma digitos </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     01/09/2006
-------------------------------------------------------------------------------------- */
Declare @nTxDep1 float
Declare @nTxDep2 float
Declare @nTxDep3 float
Declare @nTxDep4 float
Declare @nTxDep5 float
Declare @nAno    integer
Declare @nTxAcum Float
Declare @iX      integer
Declare @iPc1    Float
Declare @iPc2    Float
Declare @iPC     Float
Declare @iSD     Float
Declare @cFNI_TIPO    Char( 01 )
Declare @cFilial_FNI  Char('N3_FILIAL') -- Campo novo (Ver 11.80) terá o mesmo tamanho do campo
Declare @cFilial_FNT  Char('N3_FILIAL') -- Campo novo (Ver 11.80) terá o mesmo tamanho do campo
Declare @cFNI_CURVFI Char( 08 ) 
Declare @cFNI_PERIOD Char( 01 )
Declare @cFNI_MSBLQL Char ( 01 )
Declare @nIndTot Float
Declare @nFNT_TAXA Float
Declare @cAux    Char( 03 )
Declare @cFilial_AUX2 Char('N3_FILIAL')
Declare @nDias integer
Declare @cMes  Char( 02 )
Declare @cAno  Char( 04 )
Declare @nFator integer
Declare @cDataIni Char( 08 )
Declare @cDataFim Char( 08 )
##FIELDP02( 'SN3.N3_VORIG6' )
Declare @nTxDep6 float
##ENDFIELDP02
##FIELDP03( 'SN3.N3_VORIG7' )
Declare @nTxDep7 float
##ENDFIELDP03
##FIELDP04( 'SN3.N3_VORIG8' )
Declare @nTxDep8 float
##ENDFIELDP04
##FIELDP05( 'SN3.N3_VORIG9' )
Declare @nTxDep9 float
##ENDFIELDP05
##FIELDP06( 'SN3.N3_VORIG10' )
Declare @nTxDep10 float
##ENDFIELDP06
##FIELDP07( 'SN3.N3_VORIG11' )
Declare @nTxDep11 float
##ENDFIELDP07
##FIELDP08( 'SN3.N3_VORIG12' )
Declare @nTxDep12 float
##ENDFIELDP08
##FIELDP09( 'SN3.N3_VORIG13' )
Declare @nTxDep13 float
##ENDFIELDP09
##FIELDP10( 'SN3.N3_VORIG14' )
Declare @nTxDep14 float
##ENDFIELDP10
##FIELDP11( 'SN3.N3_VORIG15' )
Declare @nTxDep15 float
##ENDFIELDP11

begin
    Select @nTxDep1 = 0
    Select @nTxDep2 = 0
    Select @nTxDep3 = 0
    Select @nTxDep4 = 0
    Select @nTxDep5 = 0
    Select @iPC     = 0
     ##FIELDP02( 'SN3.N3_VORIG6' )
    Select @nTxDep6 = 0
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG7' )
    Select @nTxDep7 = 0
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG8' )
    Select @nTxDep8 = 0
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG9' )
    Select @nTxDep9 = 0
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG10' )
    Select @nTxDep10 = 0
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG11' )
    Select @nTxDep11 = 0
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG12' )
    Select @nTxDep12 = 0
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG13' )
    Select @nTxDep13 = 0
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG14' )
    Select @nTxDep14 = 0
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG15' )
    Select @nTxDep15 = 0
    ##ENDFIELDP11

    If @IN_TPDEPR = '2' begin
        /* ---------------------------------------------------------------
            REDUCAO DE SALDOS
            taxa de depreciacao = 1 -( VS/VO )**1/N
                VS = Valor de Salvamento                   - N3_VLSALV
                VO = Valor original                        - N3_VORIG1
                N  = Numero de periodos ( mensal ou anual) - N3_PERDEPR
            --------------------------------------------------------------- */
        If ( @IN_PERDEPR > 0 and @IN_VLSALV > 0 ) begin
            If ( @IN_DEPACM1 + @IN_VLSALV  < @IN_VORIG1 ) select @nTxDep1 = ( 1 - power(( @IN_VLSALV/@IN_VORIG1 ), (1/@IN_PERDEPR) ))
         
            Select @nTxDep2 = @nTxDep1
            Select @nTxDep3 = @nTxDep1
            Select @nTxDep4 = @nTxDep1
            Select @nTxDep5 = @nTxDep1
            ##FIELDP02( 'SN3.N3_VORIG6' )
            Select @nTxDep6 = @nTxDep1
            ##ENDFIELDP02
            ##FIELDP03( 'SN3.N3_VORIG7' )
            Select @nTxDep7 = @nTxDep1
            ##ENDFIELDP03
            ##FIELDP04( 'SN3.N3_VORIG8' )
            Select @nTxDep8 = @nTxDep1
            ##ENDFIELDP04
            ##FIELDP05( 'SN3.N3_VORIG9' )
            Select @nTxDep9 = @nTxDep1
            ##ENDFIELDP05
            ##FIELDP06( 'SN3.N3_VORIG10' )
            Select @nTxDep10  = @nTxDep1
            ##ENDFIELDP06
            ##FIELDP07( 'SN3.N3_VORIG11' )
            Select @nTxDep11 = @nTxDep1
            ##ENDFIELDP07
            ##FIELDP08( 'SN3.N3_VORIG12' )
            Select @nTxDep12 = @nTxDep1
            ##ENDFIELDP08
            ##FIELDP09( 'SN3.N3_VORIG13' )
            Select @nTxDep13 = @nTxDep1
            ##ENDFIELDP09
            ##FIELDP10( 'SN3.N3_VORIG14' )
            Select @nTxDep14 = @nTxDep1
            ##ENDFIELDP10
            ##FIELDP11( 'SN3.N3_VORIG15' )
            Select @nTxDep15 = @nTxDep1
            ##ENDFIELDP11
        End
    end
   
    if @IN_TPDEPR = '3' begin
        /* ---------------------------------------------------------------
            @IN_TPDEPR = '3' - Soma dos Anos - Localizacoes POR|EUA|COL
            --------------------------------------------------------------- */
        select @nAno = Convert( int, Substring(@IN_DATADEP, 1, 4) ) - Convert( int, Substring(@IN_DINDEPR, 1, 4) )
        If Substring(@IN_DATADEP, 5, 2) < Substring(@IN_DINDEPR, 5, 2) Select @nAno = @nAno - 1
        If @IN_YTD > 0 Select @nTxDep1 = ( @IN_YTD - @nAno ) / (( @IN_YTD * (@IN_YTD + 1)) / 2)
      
        Select @nTxDep2 = @nTxDep1
        Select @nTxDep3 = @nTxDep1
        Select @nTxDep4 = @nTxDep1
        Select @nTxDep5 = @nTxDep1
        ##FIELDP02( 'SN3.N3_VORIG6' )
        Select @nTxDep6 = @nTxDep1
        ##ENDFIELDP02
        ##FIELDP03( 'SN3.N3_VORIG7' )
        Select @nTxDep7 = @nTxDep1
        ##ENDFIELDP03
        ##FIELDP04( 'SN3.N3_VORIG8' )
        Select @nTxDep8 = @nTxDep1
        ##ENDFIELDP04
        ##FIELDP05( 'SN3.N3_VORIG9' )
        Select @nTxDep9 = @nTxDep1
        ##ENDFIELDP05
        ##FIELDP06( 'SN3.N3_VORIG10' )
        Select @nTxDep10  = @nTxDep1
        ##ENDFIELDP06
        ##FIELDP07( 'SN3.N3_VORIG11' )
        Select @nTxDep11 = @nTxDep1
        ##ENDFIELDP07
        ##FIELDP08( 'SN3.N3_VORIG12' )
        Select @nTxDep12 = @nTxDep1
        ##ENDFIELDP08
        ##FIELDP09( 'SN3.N3_VORIG13' )
        Select @nTxDep13 = @nTxDep1
        ##ENDFIELDP09
        ##FIELDP10( 'SN3.N3_VORIG14' )
        Select @nTxDep14 = @nTxDep1
        ##ENDFIELDP10
        ##FIELDP11( 'SN3.N3_VORIG15' )
        Select @nTxDep15 = @nTxDep1
        ##ENDFIELDP11
    end
   
    if @IN_TPDEPR = '4' or @IN_TPDEPR = '5' begin
        /* -------------------------------------------------------------------------
            UNIDADES PRODUZIDAS or HORAS TRABALHADAS
            Tx Depr = Nro de uni//s produzidas no periodo /
                    nro de uni//s estimadas a serem prodzs na vida util
            Tx Depr = Hs trabs no periodo/ Hs uteis estimadas em funçaõ da vida util
            ------------------------------------------------------------------------- */
        If ( @IN_PRODMES > 0 and @IN_PRODANO > 0 ) select @nTxDep1 = @IN_PRODMES/@IN_PRODANO
      
        Select @nTxDep2 = @nTxDep1
        Select @nTxDep3 = @nTxDep1
        Select @nTxDep4 = @nTxDep1
        Select @nTxDep5 = @nTxDep1
        ##FIELDP02( 'SN3.N3_VORIG6' )
        Select @nTxDep6 = @nTxDep1
        ##ENDFIELDP02
        ##FIELDP03( 'SN3.N3_VORIG7' )
        Select @nTxDep7 = @nTxDep1
        ##ENDFIELDP03
        ##FIELDP04( 'SN3.N3_VORIG8' )
        Select @nTxDep8 = @nTxDep1
        ##ENDFIELDP04
        ##FIELDP05( 'SN3.N3_VORIG9' )
        Select @nTxDep9 = @nTxDep1
        ##ENDFIELDP05
        ##FIELDP06( 'SN3.N3_VORIG10' )
        Select @nTxDep10  = @nTxDep1
        ##ENDFIELDP06
        ##FIELDP07( 'SN3.N3_VORIG11' )
        Select @nTxDep11 = @nTxDep1
        ##ENDFIELDP07
        ##FIELDP08( 'SN3.N3_VORIG12' )
        Select @nTxDep12 = @nTxDep1
        ##ENDFIELDP08
        ##FIELDP09( 'SN3.N3_VORIG13' )
        Select @nTxDep13 = @nTxDep1
        ##ENDFIELDP09
        ##FIELDP10( 'SN3.N3_VORIG14' )
        Select @nTxDep14 = @nTxDep1
        ##ENDFIELDP10
        ##FIELDP11( 'SN3.N3_VORIG15' )
        Select @nTxDep15 = @nTxDep1
        ##ENDFIELDP11
    end
   
    if @IN_TPDEPR = '6' begin
        /* ------------------------------------------------------------------------------------------------------------------------------
            SOMA DOS DIGITOS
            ----------------
            MV_CALCDEP = '0'-> Mensal (DEFAULT), MV_CALCDEP = '1' -> /ANUAL
            TAXA DE DEPRECIACAO = ( n - pc + 1 ) / SD
                    n  -> nro total de periodos
                    pc -> periodo de cálculo ( n para primeira depreciacao, n-1 para segunda depreciacao,.., 1 para a ultima depreciação )
                                pc -> (Ano de calc *12 + mes de calc) - (Ano de inic depr *12 + mes inic depr)
                    SD -> Soma dos digitos = ( a1 + an ) * n / 2         
            ------------------------------------------------------------------------------------------------------------------------------ */
        If @IN_PERDEPR > 0 begin
            If @IN_CALCDEP = '0' begin
            Select @iPc1 = Convert( integer , Substring(@IN_DATADEP, 1, 4))*12 + Convert( integer, Substring(@IN_DATADEP, 5, 2 ))
            Select @iPc2 = Convert( integer , Substring(@IN_DINDEPR, 1, 4))*12 + Convert( integer, Substring(@IN_DINDEPR, 5, 2 ))
            end else begin
            Select @iPc1 = Convert( integer , Substring(@IN_DATADEP, 1, 4)) + Convert( integer, Substring(@IN_DATADEP, 5, 2 ))
            Select @iPc2 = Convert( integer , Substring(@IN_DINDEPR, 1, 4)) + Convert( integer, Substring(@IN_DINDEPR, 5, 2 ))
            End
            Select @iPC  = @IN_PERDEPR - ( @iPc1 - @iPc2 )
            select @iSD  = @IN_PERDEPR * ( @IN_PERDEPR + 1 ) / 2
         
            select @nTxDep1 = @iPC/ @iSD
         
            Select @nTxDep2 = @nTxDep1
            Select @nTxDep3 = @nTxDep1
            Select @nTxDep4 = @nTxDep1
            Select @nTxDep5 = @nTxDep1
            ##FIELDP02( 'SN3.N3_VORIG6' )
            Select @nTxDep6 = @nTxDep1
            ##ENDFIELDP02
            ##FIELDP03( 'SN3.N3_VORIG7' )
            Select @nTxDep7 = @nTxDep1
            ##ENDFIELDP03
            ##FIELDP04( 'SN3.N3_VORIG8' )
            Select @nTxDep8 = @nTxDep1
            ##ENDFIELDP04
            ##FIELDP05( 'SN3.N3_VORIG9' )
            Select @nTxDep9 = @nTxDep1
            ##ENDFIELDP05
            ##FIELDP06( 'SN3.N3_VORIG10' )
            Select @nTxDep10  = @nTxDep1
            ##ENDFIELDP06
            ##FIELDP07( 'SN3.N3_VORIG11' )
            Select @nTxDep11 = @nTxDep1
            ##ENDFIELDP07
            ##FIELDP08( 'SN3.N3_VORIG12' )
            Select @nTxDep12 = @nTxDep1
            ##ENDFIELDP08
            ##FIELDP09( 'SN3.N3_VORIG13' )
            Select @nTxDep13 = @nTxDep1
            ##ENDFIELDP09
            ##FIELDP10( 'SN3.N3_VORIG14' )
            Select @nTxDep14 = @nTxDep1
            ##ENDFIELDP10
            ##FIELDP11( 'SN3.N3_VORIG15' )
            Select @nTxDep15 = @nTxDep1
            ##ENDFIELDP11
        End
    end
    if @IN_TPDEPR = ' ' or @IN_TPDEPR = '1' or @IN_TPDEPR = '7' begin
        /* ---------------------------------------------------------------
            Valor Máximo de Depreciação ou Linear
            MV_CALCDEP = '0'-> Mensal (DEFAULT), MV_CALCDEP = '1' -> /ANUAL
            --------------------------------------------------------------- */
        Select @nTxDep1 = @IN_TXDEPR1 / 100
        Select @nTxDep2 = @IN_TXDEPR2 / 100
        Select @nTxDep3 = @IN_TXDEPR3 / 100
        Select @nTxDep4 = @IN_TXDEPR4 / 100
        Select @nTxDep5 = @IN_TXDEPR5 / 100
        ##FIELDP02( 'SN3.N3_VORIG6' )
        Select @nTxDep6 = @IN_TXDEPR6 / 100
        ##ENDFIELDP02
        ##FIELDP03( 'SN3.N3_VORIG7' )
        Select @nTxDep7 = @IN_TXDEPR7 / 100
        ##ENDFIELDP03
        ##FIELDP04( 'SN3.N3_VORIG8' )
        Select @nTxDep8 = @IN_TXDEPR8 / 100
        ##ENDFIELDP04
        ##FIELDP05( 'SN3.N3_VORIG9' )
        Select @nTxDep9 = @IN_TXDEPR9 / 100
        ##ENDFIELDP05
        ##FIELDP06( 'SN3.N3_VORIG10' )
        Select @nTxDep10  = @IN_TXDEPR10 / 100
        ##ENDFIELDP06
        ##FIELDP07( 'SN3.N3_VORIG11' )
        Select @nTxDep11 = @IN_TXDEPR11 / 100
        ##ENDFIELDP07
        ##FIELDP08( 'SN3.N3_VORIG12' )
        Select @nTxDep12 = @IN_TXDEPR12 / 100
        ##ENDFIELDP08
        ##FIELDP09( 'SN3.N3_VORIG13' )
        Select @nTxDep13 = @IN_TXDEPR13 / 100
        ##ENDFIELDP09
        ##FIELDP10( 'SN3.N3_VORIG14' )
        Select @nTxDep14 = @IN_TXDEPR14 / 100
        ##ENDFIELDP10
        ##FIELDP11( 'SN3.N3_VORIG15' )
        Select @nTxDep15 =  @IN_TXDEPR15 / 100
        ##ENDFIELDP11

        If @IN_CALCDEP = '0' begin
            Select @nTxDep1 = @nTxDep1 / 12
            Select @nTxDep2 = @nTxDep2 / 12
            Select @nTxDep3 = @nTxDep3 / 12
            Select @nTxDep4 = @nTxDep4 / 12
            Select @nTxDep5 = @nTxDep5 / 12
            ##FIELDP02( 'SN3.N3_VORIG6' )
            Select @nTxDep6 =  @nTxDep6 / 12
            ##ENDFIELDP02
            ##FIELDP03( 'SN3.N3_VORIG7' )
            Select @nTxDep7 =  @nTxDep7 / 12
            ##ENDFIELDP03
            ##FIELDP04( 'SN3.N3_VORIG8' )
            Select @nTxDep8 =  @nTxDep8 / 12
            ##ENDFIELDP04
            ##FIELDP05( 'SN3.N3_VORIG9' )
            Select @nTxDep9 =  @nTxDep9 / 12
            ##ENDFIELDP05
            ##FIELDP06( 'SN3.N3_VORIG10' )
            Select @nTxDep10  =  @nTxDep10 / 12
            ##ENDFIELDP06
            ##FIELDP07( 'SN3.N3_VORIG11' )
            Select @nTxDep11 =  @nTxDep11 / 12
            ##ENDFIELDP07
            ##FIELDP08( 'SN3.N3_VORIG12' )
            Select @nTxDep12 =  @nTxDep12 / 12
            ##ENDFIELDP08
            ##FIELDP09( 'SN3.N3_VORIG13' )
            Select @nTxDep13 =  @nTxDep13 / 12
            ##ENDFIELDP09
            ##FIELDP10( 'SN3.N3_VORIG14' )
            Select @nTxDep14 =  @nTxDep14 / 12
            ##ENDFIELDP10
            ##FIELDP11( 'SN3.N3_VORIG15' )
            Select @nTxDep15 =   @nTxDep15 / 12
            ##ENDFIELDP11 
        End
        
        If @IN_LFUNDADA = '1' and @IN_DEPREC != ' ' begin
            /* --------------------------------
            CalcTaxa - nao definido
            -------------------------------- */
            Select @nTxDep2 = @nTxDep1
            Select @nTxDep3 = @nTxDep1
            Select @nTxDep4 = @nTxDep1
            Select @nTxDep5 = @nTxDep1
            ##FIELDP02( 'SN3.N3_VORIG6' )
            Select @nTxDep6 = @nTxDep1
            ##ENDFIELDP02
            ##FIELDP03( 'SN3.N3_VORIG7' )
            Select @nTxDep7 = @nTxDep1
            ##ENDFIELDP03
            ##FIELDP04( 'SN3.N3_VORIG8' )
            Select @nTxDep8 = @nTxDep1
            ##ENDFIELDP04
            ##FIELDP05( 'SN3.N3_VORIG9' )
            Select @nTxDep9 = @nTxDep1
            ##ENDFIELDP05
            ##FIELDP06( 'SN3.N3_VORIG10' )
            Select @nTxDep10  = @nTxDep1
            ##ENDFIELDP06
            ##FIELDP07( 'SN3.N3_VORIG11' )
            Select @nTxDep11 = @nTxDep1
            ##ENDFIELDP07
            ##FIELDP08( 'SN3.N3_VORIG12' )
            Select @nTxDep12 = @nTxDep1
            ##ENDFIELDP08
            ##FIELDP09( 'SN3.N3_VORIG13' )
            Select @nTxDep13 = @nTxDep1
            ##ENDFIELDP09
            ##FIELDP10( 'SN3.N3_VORIG14' )
            Select @nTxDep14 = @nTxDep1
            ##ENDFIELDP10
            ##FIELDP11( 'SN3.N3_VORIG15' )
            Select @nTxDep15 = @nTxDep1
            ##ENDFIELDP11
        End
    end
   
    ##FIELDP01( 'SN3.N3_CODIND' )
   
    if @IN_TPDEPR = 'A' begin
        /* ------------------------------------------------------------------------------------------------------------------------------
            Calculo de Indice de depreciação
            ----------------
            Se o tipo do indice for igual a 1 = Informado, o calculo é feito aplicando a taxa do indice ( tabela FNT )
            Se o tipo de indice for igual a 2 = Calculado
            A taxa de depreciação do período será calculado pela seguinte fórmula:
		    T = a / b, onde:
		    a = Índice de depreciação do Período (FNT_TAXA)
            b= Soma dos índices de depreciação do período atual (ddatabase) até o final da curva de depreciação (FNI_CURVFI)
            ------------------------------------------------------------------------------------------------------------------------------ */
        select @cAux = 'FNI'
        select @cFilial_AUX2 = ' '
	    exec XFILIAL_## @cAux, @cFilial_AUX2, @cFilial_FNI OutPut
	  
	    select @cAux = 'FNT'
	    exec XFILIAL_## @cAux, @cFilial_AUX2, @cFilial_FNT OutPut
	  
	    Select @cFNI_TIPO = FNI_TIPO , @cFNI_CURVFI = FNI_CURVFI, @cFNI_PERIOD = FNI_PERIOD, @cFNI_MSBLQL = FNI_MSBLQL
			    From FNI###
			    Where FNI_FILIAL  = @cFilial_FNI
				    AND FNI_CODIND  = @IN_CODIND
				    AND FNI_STATUS  = '1'
				    AND D_E_L_E_T_ = ' '
      
        If @cFNI_MSBLQL != '1' begin
		    -- Indice do tipo Calculado
		    If @cFNI_TIPO = '2' begin
	    
		        Select @cMes  = Substring(@IN_DATADEP, 5, 2) 
		        Select @cAno  =  Substring(@IN_DATADEP, 1, 4)
	            Select @cDataIni = @cAno || @cMes || '01'
	         
		        -- Somatório total da curva de trafego
		        SELECT @nIndTot = SUM(FNT_TAXA) 
		        FROM FNT###
		        WHERE 
		        FNT_FILIAL = @cFilial_FNT AND 
		        FNT_CODIND = @IN_CODIND AND 
		        FNT_DATA  >= @cDataIni  AND 
		        FNT_DATA  <= @cFNI_CURVFI AND 
		        FNT_MSBLQL = '2' AND 
		        FNT_STATUS = '1'  AND  
		        D_E_L_E_T_ = ' '
			
		        SELECT 
		        @nFNT_TAXA = FNT_TAXA 
		        FROM FNT###
		        WHERE 
		        FNT_FILIAL = @cFilial_FNT AND 
		        FNT_CODIND = @IN_CODIND AND 
		        FNT_MSBLQL = '2' AND 
		        FNT_STATUS = '1'  AND 
		        FNT_DATA = @cDataIni  AND 
		        D_E_L_E_T_ = ' '  
	      
		        SELECT @nTxDep1 = @nFNT_TAXA / @nIndTot
			
		    End
	  
		        --Indice do tipo Informado
		    If @cFNI_TIPO IN ('1', ' ' ) begin
		        -- Diario
		        If @cFNI_PERIOD = '1' begin
			
			        Select @nDias = Convert( int, Substring(@IN_DATADEP, 7, 2) )  
			        Select @cMes  = Substring(@IN_DATADEP, 5, 2) 
			        Select @cAno  =  Substring(@IN_DATADEP, 1, 4) 
			        Select @cDataIni = @cAno || @cMes || '01' 
			        Select @nFator = @nDias
				
			        SELECT 
				        @nFNT_TAXA = Sum(FNT_TAXA)
			        FROM FNT###
			        WHERE 
				        FNT_FILIAL = @cFilial_FNT AND 
				        FNT_CODIND = @IN_CODIND AND 
				        FNT_MSBLQL = '2' AND 
				        FNT_STATUS = '1'  AND 
				        FNT_DATA >= @cDataIni  AND 
				        FNT_DATA <= @IN_DATADEP  AND 
				        D_E_L_E_T_ = ' '  
				
			        SELECT @nTxDep1 = ( @nFNT_TAXA / @nFator ) 	
		        end else begin
			
			        Select @cMes  = Substring(@IN_DATADEP, 5, 2) 
			        Select @cAno  =  Substring(@IN_DATADEP, 1, 4)
			        -- Mensal
			        If @cFNI_PERIOD = '2' begin			
				        Select @cDataIni = @cAno || @cMes || '01'
				        Select @cDataFim = @IN_DATADEP 
				        Select @nDias = 30
				        Select @nFator = 30
			        end 
				
			        --Trimestral
			        If @cFNI_PERIOD = '3' begin
				        If @cMes >= '01' and @cMes <= '03' begin	-- Primeiro Trimestre	
					        Select @cDataIni = @cAno || '01' || '01'
				        end
					
				        If @cMes >= '04' and @cMes <= '06' begin	-- Segundo Trimestre	
					        Select @cDataIni = @cAno || '04' || '01'
				        end
					
				        If @cMes >= '07' and @cMes <= '09' begin	-- Terceiro Trimestre	
					        Select @cDataIni = @cAno || '07' || '01'
				        end

				        If @cMes >= '10' and @cMes <= '12' begin	-- Quarto Trimestre	
					        Select @cDataIni = @cAno || '10' || '01'
				        end
					
				        Select @cDataFim = @IN_DATADEP 
				        Select @nDias = 90
				        Select @nFator = 30
			        end
				
			        --Semestral
			        If @cFNI_PERIOD = '4' begin
				
				        If @cMes >= '01' and @cMes <= '06' begin	-- Primeiro Semestre	
					        Select @cDataIni = @cAno || '01' || '01'
				        end

				        If @cMes >= '07' and @cMes <= '12' begin	-- Segundo Semestre	
					        Select @cDataIni = @cAno || '07' || '01'
				        end
					
				        Select @cDataFim = @IN_DATADEP 
				        Select @nDias = 180
				        Select @nFator = 30
			        end
				
			        --Semestral
			        If @cFNI_PERIOD = '5' begin
				        Select @cDataIni = @cAno || '01' || '01'
				        Select @cDataFim = @IN_DATADEP 
				        Select @nDias = 365
				        Select @nFator = 30
			        end   
				
			        SELECT 
				        @nFNT_TAXA = FNT_TAXA
			        FROM FNT###
			        WHERE 
				        FNT_FILIAL = @cFilial_FNT AND 
				        FNT_CODIND = @IN_CODIND AND 
				        FNT_MSBLQL = '2' AND 
				        FNT_STATUS = '1'  AND 
				        FNT_DATA = @cDataIni  AND 
				        D_E_L_E_T_ = ' '
					
			        SELECT @nTxDep1 = ( @nFNT_TAXA / @nDias  ) * @nFator
		        End
		    End
    end else begin
	    SELECT @nTxDep1 = 0 
    End

    Select @nTxDep2 = @nTxDep1
    Select @nTxDep3 = @nTxDep1
    Select @nTxDep4 = @nTxDep1
    Select @nTxDep5 = @nTxDep1
    ##FIELDP02( 'SN3.N3_VORIG6' )
    Select @nTxDep6 = @nTxDep1
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG7' )
    Select @nTxDep7 = @nTxDep1
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG8' )
    Select @nTxDep8 = @nTxDep1
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG9' )
    Select @nTxDep9 = @nTxDep1
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG10' )
    Select @nTxDep10  = @nTxDep1
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG11' )
    Select @nTxDep11 = @nTxDep1
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG12' )
    Select @nTxDep12 = @nTxDep1
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG13' )
    Select @nTxDep13 = @nTxDep1
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG14' )
    Select @nTxDep14 = @nTxDep1
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG15' )
    Select @nTxDep15 = @nTxDep1
    ##ENDFIELDP11
    end
    ##ENDFIELDP01
     
    Select @OUT_TXDEP1  = @nTxDep1
    Select @OUT_TXDEP2  = @nTxDep2
    Select @OUT_TXDEP3  = @nTxDep3
    Select @OUT_TXDEP4  = @nTxDep4
    Select @OUT_TXDEP5  = @nTxDep5
    Select @OUT_IPC     = @iPC
    ##FIELDP02( 'SN3.N3_VORIG6' )
    Select @OUT_TXDEP6 = @nTxDep6
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG7' )
    Select @OUT_TXDEP7 = @nTxDep7
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG8' )
    Select @OUT_TXDEP8 = @nTxDep8
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG9' )
    Select @OUT_TXDEP9 = @nTxDep9
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG10' )
    Select @OUT_TXDEP10 = @nTxDep10
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG11' )
    Select @OUT_TXDEP11 = @nTxDep11
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG12' )
    Select @OUT_TXDEP12 = @nTxDep12
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG13' )
    Select @OUT_TXDEP13 = @nTxDep13
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG14' )
    Select @OUT_TXDEP14 = @nTxDep14
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG15' )
    Select @OUT_TXDEP15 = @nTxDep15
    ##ENDFIELDP11
End
