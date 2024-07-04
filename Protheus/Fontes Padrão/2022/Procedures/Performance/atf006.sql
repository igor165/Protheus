Create Procedure ATF006_##
 (
   @IN_TXDEP1    float, 
   @IN_TXDEP2    float, 
   @IN_TXDEP3    float, 
   @IN_TXDEP4    float, 
   @IN_TXDEP5    float, 
   @IN_LMESCHEIO Char( 01 ),
   @IN_NRODIAS   Integer,
   @IN_ULTDIA    Integer,
   @IN_RECNO     integer,
   @IN_ATFMDMX   Char( 02 ),
   @IN_IPC       Integer,
   @IN_CODIND    Char( 08 ),
    ##FIELDP02( 'SN3.N3_VORIG6' )
    @IN_TXDEP6    float,
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG7' )
    @IN_TXDEP7    float ,
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG8' )
    @IN_TXDEP8    float ,
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG9' )
    @IN_TXDEP9    float ,
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG10' )
    @IN_TXDEP10    float, 
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG11' )
    @IN_TXDEP11    float ,
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG12' )
    @IN_TXDEP12    float ,
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG13' )
    @IN_TXDEP13    float ,
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG14' )
    @IN_TXDEP14    float ,
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG15' )
    @IN_TXDEP15    float ,
    ##ENDFIELDP11
   @OUT_DEP1     float OutPut,
   @OUT_DEP2     float OutPut,
   @OUT_DEP3     float OutPut,
   @OUT_DEP4     float OutPut,
   @OUT_DEP5     float OutPut
    ##FIELDP02( 'SN3.N3_VORIG6' )
    , @OUT_DEP6  Float OutPut
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG7' )
    , @OUT_DEP7  Float OutPut
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG8' )
    , @OUT_DEP8  Float OutPut
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG9' )
    , @OUT_DEP9  Float OutPut
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG10' )
    , @OUT_DEP10  Float OutPut
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG11' )
    , @OUT_DEP11  Float OutPut
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG12' )
    , @OUT_DEP12  Float OutPut
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG13' )
    , @OUT_DEP13  Float OutPut
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG14' )
    , @OUT_DEP14  Float OutPut
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG15' )
    , @OUT_DEP15  Float OutPut
    ##ENDFIELDP11
)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ATFA050.PRW </s>
    Descricao       - <d>  Calculo de Depreciação </d>
    Funcao do Siga  -      Atfa050()
    Entrada         - <ri> @IN_TXDEP1    - Taxa mensal de depreciacao na moeda 1
                           @IN_TXDEP2    - Taxa mensal de depreciacao na moeda 2
                           @IN_TXDEP3    - Taxa mensal de depreciacao na moeda 3
                           @IN_TXDEP4    - Taxa mensal de depreciacao na moeda 4
                           @IN_TXDEP5    - Taxa mensal de depreciacao na moeda 5s
                           @IN_LMESCHEIO - Se 1 mes cheio, 0 proporcional
                           @IN_NRODIAS   - Nro de dias a Depreciar
                           @IN_ULTDIA    - Nro de dias no mes
                           @IN_RECNO     - Recno o ativo no SN3
                           @IN_IPC       - periodo calculado qdo N3_TPDEPR = '6' reducao saldos, se '1' ultimo periodo de calculo
                           @IN_ATFMDMX   - Define a moeda de referencia para o valor maximo de depreciacao
                           @IN_CODIND    - Código do Indice de depreciacao
    Saida           - <o>  @OUT_DEP1     - Valor da depreciacao na moeda 1
                           @OUT_DEP2     - Valor da depreciacao na moeda 2
                           @OUT_DEP3     - Valor da depreciacao na moeda 3
                           @OUT_DEP4     - Valor da depreciacao na moeda 4
                           @OUT_DEP5     - Valor da depreciacao na moeda 5  </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     04/10/2006
-------------------------------------------------------------------------------------- */
Declare @nValDepr1   float
Declare @nValDepr2   float
Declare @nValDepr3   float
Declare @nValDepr4   float
Declare @nValDepr5   float
Declare @nTxDep1     float
Declare @nTxDep2     float
Declare @nTxDep3     float
Declare @nTxDep4     float
Declare @nTxDep5     float
Declare @nDiferenca  Float
Declare @nN3_VORIG1  float
Declare @nN3_VORIG2  float
Declare @nN3_VORIG3  float
Declare @nN3_VORIG4  float
Declare @nN3_VORIG5  float
Declare @nN3_AMPLIA1 float
Declare @nN3_AMPLIA2 float
Declare @nN3_AMPLIA3 float
Declare @nN3_AMPLIA4 float
Declare @nN3_AMPLIA5 float
Declare @nN3_VRDACM1 float
Declare @nN3_VRDACM2 float
Declare @nN3_VRDACM3 float
Declare @nN3_VRDACM4 float
Declare @nN3_VRDACM5 float
Declare @nN3_VRCACM1 float
Declare @nN3_VRCDA1  float
Declare @nN3_VMXDEPR float
Declare @nN3_VLSALV1 float
Declare @nSalvAux    float
Declare @nVmxDepr    float
Declare @nPercent    float
Declare @cN3_TPDEPR  Char( 'N3_TPDEPR' )
Declare @cFNI_TIPO   Char( 01 )
Declare @cFilial_FNI Char('N3_FILIAL') -- Campo novo (Ver 11.80) terá o mesmo tamanho do campo
Declare @cAux        Char( 03 )
Declare @cFilial_AUX Char( 'N3_FILIAL' )

##FIELDP02( 'SN3.N3_VORIG6' )
Declare @nValDepr6   float
Declare @nTxDep6     float
Declare @nN3_VORIG6  float
Declare @nN3_AMPLIA6 float
Declare @nN3_VRDACM6 float
##ENDFIELDP02

##FIELDP03( 'SN3.N3_VORIG7' )
Declare @nValDepr7  float
Declare @nTxDep7     float
Declare @nN3_VORIG7 float
Declare @nN3_AMPLIA7 float
Declare @nN3_VRDACM7 float
##ENDFIELDP03

##FIELDP04( 'SN3.N3_VORIG8' )
Declare @nValDepr8   float
Declare @nTxDep8     float
Declare @nN3_VORIG8  float
Declare @nN3_AMPLIA8 float
Declare @nN3_VRDACM8 float
##ENDFIELDP04

##FIELDP05( 'SN3.N3_VORIG9' )
Declare @nValDepr9   float
Declare @nTxDep9     float
Declare @nN3_VORIG9  float
Declare @nN3_AMPLIA9 float
Declare @nN3_VRDACM9 float
##ENDFIELDP05

##FIELDP06( 'SN3.N3_VORIG10' )
Declare @nValDepr10   float
Declare @nTxDep10     float
Declare @nN3_VORIG10  float
Declare @nN3_AMPLIA10 float
Declare @nN3_VRDACM10 float
##ENDFIELDP06

##FIELDP07( 'SN3.N3_VORIG11' )
Declare @nValDepr11   float
Declare @nTxDep11     float
Declare @nN3_VORIG11  float
Declare @nN3_AMPLIA11 float
Declare @nN3_VRDACM11 float
##ENDFIELDP07

##FIELDP08( 'SN3.N3_VORIG12' )
Declare @nValDepr12   float
Declare @nTxDep12     float
Declare @nN3_VORIG12  float
Declare @nN3_AMPLIA12 float
Declare @nN3_VRDACM12 float
##ENDFIELDP08

##FIELDP09( 'SN3.N3_VORIG13' )
Declare @nValDepr13   float
Declare @nTxDep13     float
Declare @nN3_VORIG13  float
Declare @nN3_AMPLIA13 float
Declare @nN3_VRDACM13 float
##ENDFIELDP09

##FIELDP10( 'SN3.N3_VORIG14' )
Declare @nValDepr14   float
Declare @nTxDep14     float
Declare @nN3_VORIG14  float
Declare @nN3_AMPLIA14 float
Declare @nN3_VRDACM14 float
##ENDFIELDP10

##FIELDP11( 'SN3.N3_VORIG15' )
Declare @nValDepr15   float
Declare @nTxDep15     float
Declare @nN3_VORIG15  float
Declare @nN3_AMPLIA15 float
Declare @nN3_VRDACM15 float
##ENDFIELDP11

begin
    select @nValDepr1 = 0
    select @nValDepr2 = 0
    select @nValDepr3 = 0
    select @nValDepr4 = 0
    select @nValDepr5 = 0
    select @nSalvAux  = 0
    select @nVmxDepr  = 0
    select @nTxDep1 = @IN_TXDEP1
    select @nTxDep2 = @IN_TXDEP2
    select @nTxDep3 = @IN_TXDEP3
    select @nTxDep4 = @IN_TXDEP4
    select @nTxDep5 = @IN_TXDEP5
    select @nN3_VMXDEPR = 0
    select @nN3_VLSALV1 = 0

    ##FIELDP02( 'SN3.N3_VORIG6' )
    select @nValDepr6    = 0
    select @nTxDep6      = @IN_TXDEP6
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG7' )
    select @nValDepr7    = 0
    select @nTxDep7      = @IN_TXDEP7
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG8' )
    select @nValDepr8    = 0
    select @nTxDep8      = @IN_TXDEP8
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG9' )
    select @nValDepr9    = 0
    select @nTxDep9      = @IN_TXDEP9
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG10' )
    select @nValDepr10    = 0
    select @nTxDep10      = @IN_TXDEP10
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG11' )
    select @nValDepr11   = 0
    select @nTxDep11      = @IN_TXDEP11
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG12' )
    select @nValDepr12    = 0
    select @nTxDep12      = @IN_TXDEP12
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG13' )
    select @nValDepr13    = 0
    select @nTxDep13      = @IN_TXDEP13
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG14' )
    select @nValDepr14    = 0
    select @nTxDep14      = @IN_TXDEP14
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG15' )
    select @nValDepr15    = 0
    select @nTxDep15      = @IN_TXDEP15
    ##ENDFIELDP11
   
    Select @nN3_VORIG1  = N3_VORIG1,  @nN3_VORIG2  = N3_VORIG2,  @nN3_VORIG3  = N3_VORIG3,  @nN3_VORIG4  = N3_VORIG4,  @nN3_VORIG5  = N3_VORIG5,
        @nN3_AMPLIA1 = N3_AMPLIA1, @nN3_AMPLIA2 = N3_AMPLIA2, @nN3_AMPLIA3 = N3_AMPLIA3, @nN3_AMPLIA4 = N3_AMPLIA4, @nN3_AMPLIA5 = N3_AMPLIA5,
        @nN3_VRDACM1 = N3_VRDACM1, @nN3_VRDACM2 = N3_VRDACM2, @nN3_VRDACM3 = N3_VRDACM3, @nN3_VRDACM4 = N3_VRDACM4, @nN3_VRDACM5 = N3_VRDACM5,
        @nN3_VRCACM1 = N3_VRCACM1, @nN3_VRCDA1  = N3_VRCDA1,  @cN3_TPDEPR  = N3_TPDEPR
        ##FIELDP01( 'SN3.N3_VMXDEPR;N3_VLSALV1' )
        ,@nN3_VMXDEPR = N3_VMXDEPR, @nN3_VLSALV1 = N3_VLSALV1
        ##ENDFIELDP01
        ##FIELDP02( 'SN3.N3_VORIG6' )
        ,  @nN3_VORIG6  = N3_VORIG6,  @nN3_AMPLIA6 = N3_AMPLIA6,  @nN3_VRDACM6 = N3_VRDACM6
        ##ENDFIELDP02
        ##FIELDP03( 'SN3.N3_VORIG7' )
        ,  @nN3_VORIG7  = N3_VORIG7,  @nN3_AMPLIA7 = N3_AMPLIA7,  @nN3_VRDACM7 = N3_VRDACM7
        ##ENDFIELDP03
        ##FIELDP04( 'SN3.N3_VORIG8' )
        ,  @nN3_VORIG8  = N3_VORIG8,  @nN3_AMPLIA8 = N3_AMPLIA8,  @nN3_VRDACM8 = N3_VRDACM8
        ##ENDFIELDP04
        ##FIELDP05( 'SN3.N3_VORIG9' )
        ,  @nN3_VORIG9  = N3_VORIG9,  @nN3_AMPLIA9 = N3_AMPLIA9,  @nN3_VRDACM9 = N3_VRDACM9
        ##ENDFIELDP05
        ##FIELDP06( 'SN3.N3_VORIG10' )
        ,  @nN3_VORIG10  = N3_VORIG10,  @nN3_AMPLIA10 = N3_AMPLI10,  @nN3_VRDACM10 = N3_VRDAC10
        ##ENDFIELDP06
        ##FIELDP07( 'SN3.N3_VORIG11' )
        ,  @nN3_VORIG11  = N3_VORIG11,  @nN3_AMPLIA11 = N3_AMPLI11,  @nN3_VRDACM11 = N3_VRDAC11
        ##ENDFIELDP07
        ##FIELDP08( 'SN3.N3_VORIG12' )
        ,  @nN3_VORIG12  = N3_VORIG12,  @nN3_AMPLIA12 = N3_AMPLI12,  @nN3_VRDACM12 = N3_VRDAC12
        ##ENDFIELDP08
        ##FIELDP09( 'SN3.N3_VORIG13' )
        ,  @nN3_VORIG13  = N3_VORIG13,  @nN3_AMPLIA13 = N3_AMPLI13,  @nN3_VRDACM13 = N3_VRDAC13
        ##ENDFIELDP09
        ##FIELDP10( 'SN3.N3_VORIG14' )
        ,  @nN3_VORIG14  = N3_VORIG14,  @nN3_AMPLIA14 = N3_AMPLI14,  @nN3_VRDACM14 = N3_VRDAC14
        ##ENDFIELDP10
        ##FIELDP11( 'SN3.N3_VORIG15' )
        ,  @nN3_VORIG15  = N3_VORIG15,  @nN3_AMPLIA15 = N3_AMPLI15,  @nN3_VRDACM15 = N3_VRDAC15
        ##ENDFIELDP11
      From SN3###
    Where R_E_C_N_O_ = @IN_RECNO
    /* ----------------------------------------------------------------------------------
    Soma dos digitos
    ---------------------------------------------------------------------------------- */
    If @cN3_TPDEPR = '6' begin
        If @nTxDep1 != 0 begin         
            If Abs(@nN3_VRDACM1 + @nN3_VRCDA1) < Abs(@nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1) begin
                Select @nValDepr1 = ( ( @nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1) * @nTxDep1 )
                Select @nDiferenca = Abs(@nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1) - (Abs(@nValDepr1) + Abs(@nN3_VRDACM1 + @nN3_VRCDA1))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr1  = ( @nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1)- (@nN3_VRDACM1 + @nN3_VRCDA1)
                End
            End
            /* ----------------------------------------------------------------------------------
                Ultimo periodo a calcular
                ---------------------------------------------------------------------------------- */
            If @IN_IPC = 1 begin
                Select @nValDepr1  = ( @nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1)- (@nN3_VRDACM1 + @nN3_VRCDA1)
            end
        End
        If @nTxDep2 != 0 begin
            If Abs(@nN3_VRDACM2 ) < Abs( @nN3_VORIG2 + @nN3_AMPLIA2 ) begin
            Select @nValDepr2 = ( ( @nN3_VORIG2 + @nN3_AMPLIA2) * @nTxDep2 )
            Select @nDiferenca = Abs(@nN3_VORIG2 + @nN3_AMPLIA2) - (Abs(@nValDepr2) + Abs(@nN3_VRDACM2))
            If ( @nDiferenca ) <= 0 begin
                Select @nValDepr2  = ( @nN3_VORIG2 + @nN3_AMPLIA2)- (@nN3_VRDACM2)
            end
            End
            If @IN_IPC = 1 begin
            Select @nValDepr2  = ( @nN3_VORIG2 + @nN3_AMPLIA2)- (@nN3_VRDACM2)
            end
        End
        If @nTxDep3 != 0 begin
            If Abs(@nN3_VRDACM3 ) < Abs( @nN3_VORIG3 + @nN3_AMPLIA3 ) begin
            Select @nValDepr3 = ( ( @nN3_VORIG3 + @nN3_AMPLIA3) * @nTxDep3 )
            Select @nDiferenca = Abs(@nN3_VORIG3 + @nN3_AMPLIA3) - (Abs(@nValDepr3) + Abs(@nN3_VRDACM3))
            If ( @nDiferenca ) <= 0 begin
                Select @nValDepr3  = ( @nN3_VORIG3 + @nN3_AMPLIA3)- (@nN3_VRDACM3)
            end
            End
            If @IN_IPC = 1 begin
            Select @nValDepr3  = ( @nN3_VORIG3 + @nN3_AMPLIA3)- (@nN3_VRDACM3)
            end
        End
        If @nTxDep4 != 0 begin
            If Abs(@nN3_VRDACM4 ) < Abs( @nN3_VORIG4 + @nN3_AMPLIA4 ) begin
            Select @nValDepr4 = ( ( @nN3_VORIG4 + @nN3_AMPLIA4) * @nTxDep4 )
            Select @nDiferenca = Abs(@nN3_VORIG4 + @nN3_AMPLIA4) - (Abs(@nValDepr4) + Abs(@nN3_VRDACM4))
            If ( @nDiferenca ) <= 0 begin
                Select @nValDepr4  = ( @nN3_VORIG4 + @nN3_AMPLIA4)- (@nN3_VRDACM4)
            end
            End
            If @IN_IPC = 1 begin
            Select @nValDepr4  = ( @nN3_VORIG4 + @nN3_AMPLIA4)- (@nN3_VRDACM4)
            end
        End
        If @nTxDep5 != 0 begin
            If Abs(@nN3_VRDACM5 ) < Abs( @nN3_VORIG5 + @nN3_AMPLIA5 ) begin
            Select @nValDepr5 = ( ( @nN3_VORIG5 + @nN3_AMPLIA5) * @nTxDep5 )
            Select @nDiferenca = Abs(@nN3_VORIG5 + @nN3_AMPLIA5) - (Abs(@nValDepr5) + Abs(@nN3_VRDACM5))
            If ( @nDiferenca ) <= 0 begin
                Select @nValDepr5  = ( @nN3_VORIG5 + @nN3_AMPLIA5)- (@nN3_VRDACM5)
            End
            End
            If @IN_IPC = 1 begin
            Select @nValDepr5  = ( @nN3_VORIG5 + @nN3_AMPLIA5)- (@nN3_VRDACM5)
            end
        End

        ##FIELDP02( 'SN3.N3_VORIG6' )
        If @nTxDep6 != 0 begin
            If Abs(@nN3_VRDACM6 ) < Abs( @nN3_VORIG6 + @nN3_AMPLIA6 ) begin
                Select @nValDepr6 = ( ( @nN3_VORIG6 + @nN3_AMPLIA6) * @nTxDep6 )
                Select @nDiferenca = Abs(@nN3_VORIG6 + @nN3_AMPLIA6) - (Abs(@nValDepr6) + Abs(@nN3_VRDACM6))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr6  = ( @nN3_VORIG6 + @nN3_AMPLIA6)- (@nN3_VRDACM6)
                End
            End
            If @IN_IPC = 1 begin
                Select @nValDepr6  = ( @nN3_VORIG6 + @nN3_AMPLIA6)- (@nN3_VRDACM6)
            end
        End
        ##ENDFIELDP02

        ##FIELDP03( 'SN3.N3_VORIG7' )
        If @nTxDep7 != 0 begin
            If Abs(@nN3_VRDACM7 ) < Abs( @nN3_VORIG7 + @nN3_AMPLIA7 ) begin
                Select @nValDepr7 = ( ( @nN3_VORIG7 + @nN3_AMPLIA7) * @nTxDep7 )
                Select @nDiferenca = Abs(@nN3_VORIG7 + @nN3_AMPLIA7) - (Abs(@nValDepr7) + Abs(@nN3_VRDACM7))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr7  = ( @nN3_VORIG7 + @nN3_AMPLIA7)- (@nN3_VRDACM7)
                End
            End
            If @IN_IPC = 1 begin
                Select @nValDepr7  = ( @nN3_VORIG7 + @nN3_AMPLIA7)- (@nN3_VRDACM7)
            end
        End 
        ##ENDFIELDP03

        ##FIELDP04( 'SN3.N3_VORIG8' )
        If @nTxDep8 != 0 begin
            If Abs(@nN3_VRDACM8 ) < Abs( @nN3_VORIG8 + @nN3_AMPLIA8 ) begin
                Select @nValDepr8 = ( ( @nN3_VORIG8 + @nN3_AMPLIA8) * @nTxDep8 )
                Select @nDiferenca = Abs(@nN3_VORIG8 + @nN3_AMPLIA8) - (Abs(@nValDepr8) + Abs(@nN3_VRDACM8))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr8  = ( @nN3_VORIG8 + @nN3_AMPLIA8)- (@nN3_VRDACM8)
                End
            End
            If @IN_IPC = 1 begin
                Select @nValDepr8  = ( @nN3_VORIG8 + @nN3_AMPLIA8)- (@nN3_VRDACM8)
            end
        End 
        ##ENDFIELDP04
        
        ##FIELDP05( 'SN3.N3_VORIG9' )
        If @nTxDep9 != 0 begin
            If Abs(@nN3_VRDACM9 ) < Abs( @nN3_VORIG9 + @nN3_AMPLIA9 ) begin
                Select @nValDepr9 = ( ( @nN3_VORIG9 + @nN3_AMPLIA9) * @nTxDep9 )
                Select @nDiferenca = Abs(@nN3_VORIG9 + @nN3_AMPLIA9) - (Abs(@nValDepr9) + Abs(@nN3_VRDACM9))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr9  = ( @nN3_VORIG9 + @nN3_AMPLIA9)- (@nN3_VRDACM9)
                End
            End
            If @IN_IPC = 1 begin
                Select @nValDepr9  = ( @nN3_VORIG9 + @nN3_AMPLIA9)- (@nN3_VRDACM9)
            end
        End 
        ##ENDFIELDP05

        ##FIELDP06( 'SN3.N3_VORIG10' )
        If @nTxDep10 != 0 begin
            If Abs(@nN3_VRDACM10 ) < Abs( @nN3_VORIG10 + @nN3_AMPLIA10 ) begin
                Select @nValDepr10 = ( ( @nN3_VORIG10 + @nN3_AMPLIA10) * @nTxDep10 )
                Select @nDiferenca = Abs(@nN3_VORIG10 + @nN3_AMPLIA10) - (Abs(@nValDepr10) + Abs(@nN3_VRDACM10))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr10  = ( @nN3_VORIG10 + @nN3_AMPLIA10)- (@nN3_VRDACM10)
                End
            End
            If @IN_IPC = 1 begin
                Select @nValDepr10  = ( @nN3_VORIG10 + @nN3_AMPLIA10)- (@nN3_VRDACM10)
            end
        End 
        ##ENDFIELDP06

        ##FIELDP07( 'SN3.N3_VORIG11' )
        If @nTxDep11 != 0 begin
            If Abs(@nN3_VRDACM11 ) < Abs( @nN3_VORIG11 + @nN3_AMPLIA11 ) begin
                Select @nValDepr11 = ( ( @nN3_VORIG11 + @nN3_AMPLIA11) * @nTxDep11 )
                Select @nDiferenca = Abs(@nN3_VORIG11 + @nN3_AMPLIA11) - (Abs(@nValDepr11) + Abs(@nN3_VRDACM11))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr11  = ( @nN3_VORIG11 + @nN3_AMPLIA11)- (@nN3_VRDACM11)
                End
            End
            If @IN_IPC = 1 begin
                Select @nValDepr11  = ( @nN3_VORIG11 + @nN3_AMPLIA11)- (@nN3_VRDACM11)
            end
        End 
        ##ENDFIELDP07

        ##FIELDP08( 'SN3.N3_VORIG12' )
        If @nTxDep12 != 0 begin
            If Abs(@nN3_VRDACM12 ) < Abs( @nN3_VORIG12 + @nN3_AMPLIA12 ) begin
                Select @nValDepr12 = ( ( @nN3_VORIG12 + @nN3_AMPLIA12) * @nTxDep12 )
                Select @nDiferenca = Abs(@nN3_VORIG12 + @nN3_AMPLIA12) - (Abs(@nValDepr12) + Abs(@nN3_VRDACM12))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr12  = ( @nN3_VORIG12 + @nN3_AMPLIA12)- (@nN3_VRDACM12)
                End
            End
            If @IN_IPC = 1 begin
                Select @nValDepr12  = ( @nN3_VORIG12 + @nN3_AMPLIA12)- (@nN3_VRDACM12)
            end
        End 
        ##ENDFIELDP08

        ##FIELDP09( 'SN3.N3_VORIG13' )
        If @nTxDep13 != 0 begin
            If Abs(@nN3_VRDACM13 ) < Abs( @nN3_VORIG13 + @nN3_AMPLIA13 ) begin
                Select @nValDepr13 = ( ( @nN3_VORIG13 + @nN3_AMPLIA13) * @nTxDep13 )
                Select @nDiferenca = Abs(@nN3_VORIG13 + @nN3_AMPLIA13) - (Abs(@nValDepr13) + Abs(@nN3_VRDACM13) )
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr13 = ( @nN3_VORIG13 + @nN3_AMPLIA13)- (@nN3_VRDACM13)
                End
            End
            If @IN_IPC = 1 begin
                Select @nValDepr13  = ( @nN3_VORIG13 + @nN3_AMPLIA13)- (@nN3_VRDACM13)
            end
        End 
        ##ENDFIELDP09

        ##FIELDP10( 'SN3.N3_VORIG14' )
        If @nTxDep14 != 0 begin
            If Abs(@nN3_VRDACM14 ) < Abs( @nN3_VORIG14 + @nN3_AMPLIA14 ) begin
                Select @nValDepr14 = ( ( @nN3_VORIG14 + @nN3_AMPLIA14) * @nTxDep14 )
                Select @nDiferenca = Abs(@nN3_VORIG14 + @nN3_AMPLIA14) - (Abs(@nValDepr14) + Abs(@nN3_VRDACM14))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr14  = ( @nN3_VORIG14 + @nN3_AMPLIA14)- (@nN3_VRDACM14)
                End
            End
            If @IN_IPC = 1 begin
                Select @nValDepr14  = ( @nN3_VORIG14 + @nN3_AMPLIA14)- (@nN3_VRDACM14)
            end
        End 
        ##ENDFIELDP10

        ##FIELDP11( 'SN3.N3_VORIG15' )
        If @nTxDep15 != 0 begin
            If Abs(@nN3_VRDACM15 ) < Abs( @nN3_VORIG15 + @nN3_AMPLIA15 ) begin
                Select @nValDepr15 = ( ( @nN3_VORIG15 + @nN3_AMPLIA15) * @nTxDep15 )
                Select @nDiferenca = Abs(@nN3_VORIG15 + @nN3_AMPLIA15) - (Abs(@nValDepr15) + Abs(@nN3_VRDACM15))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr15  = ( @nN3_VORIG15 + @nN3_AMPLIA15)- (@nN3_VRDACM15)
                End
            End
            If @IN_IPC = 1 begin
                Select @nValDepr15  = ( @nN3_VORIG15 + @nN3_AMPLIA15)- (@nN3_VRDACM15)
            end
        End 
        ##ENDFIELDP11
    End
    /* ----------------------------------------------------------------------------------
	    Linear com Valor Máximo de depreciacao
        ---------------------------------------------------------------------------------- */
    If @cN3_TPDEPR = '7' begin
        /* ----------------------------------------------------------------------------------
        @nPercent -> percent Vlr Máximo de deprec em relação ao Vlr original 
            ---------------------------------------------------------------------------------- */
        If @IN_ATFMDMX = '01' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG1+@nN3_AMPLIA1)
        End
        If @IN_ATFMDMX = '02' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG2+@nN3_AMPLIA2)
        End
        If @IN_ATFMDMX = '03' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG3+@nN3_AMPLIA3)
        End
        If @IN_ATFMDMX = '04' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG4+@nN3_AMPLIA4)
        End
        If @IN_ATFMDMX = '05' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG5+@nN3_AMPLIA5)
        End
                
        ##FIELDP02( 'SN3.N3_VORIG6' )
        If @IN_ATFMDMX = '06' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG6+@nN3_AMPLIA6)
        End
        ##ENDFIELDP02

        ##FIELDP03( 'SN3.N3_VORIG7' )
        If @IN_ATFMDMX = '07' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG7+@nN3_AMPLIA7)
        End
        ##ENDFIELDP03

        ##FIELDP04( 'SN3.N3_VORIG8' )
        If @IN_ATFMDMX = '08' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG8+@nN3_AMPLIA8)
        End
        ##ENDFIELDP04

        ##FIELDP05( 'SN3.N3_VORIG9' )
        If @IN_ATFMDMX = '09' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG9+@nN3_AMPLIA9)
        End
        ##ENDFIELDP05

        ##FIELDP06( 'SN3.N3_VORIG10' )
        If @IN_ATFMDMX = '10' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG10+@nN3_AMPLIA10)
        End
        ##ENDFIELDP06

        ##FIELDP07( 'SN3.N3_VORIG11' )
        If @IN_ATFMDMX = '11' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG11+@nN3_AMPLIA11)
        End
        ##ENDFIELDP07

        ##FIELDP08( 'SN3.N3_VORIG12' )
        If @IN_ATFMDMX = '12' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG12+@nN3_AMPLIA12)
        End
        ##ENDFIELDP08

        ##FIELDP09( 'SN3.N3_VORIG13' )
        If @IN_ATFMDMX = '13' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG13+@nN3_AMPLIA13)
        End
        ##ENDFIELDP09

        ##FIELDP10( 'SN3.N3_VORIG14' )
        If @IN_ATFMDMX = '14' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG14+@nN3_AMPLIA14)
        End
        ##ENDFIELDP10

        ##FIELDP11( 'SN3.N3_VORIG15' )
        If @IN_ATFMDMX = '15' begin
            select @nPercent = @nN3_VMXDEPR/(@nN3_VORIG15+@nN3_AMPLIA15)
        End
        ##ENDFIELDP11
        
        If @nTxDep1 != 0  begin
            If @IN_ATFMDMX = '01' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG1 * @nPercent
         
            If Abs(@nN3_VRDACM1 + @nN3_VRCDA1) < Abs( @nVmxDepr ) begin
                Select @nValDepr1 = ( @nVmxDepr * @nTxDep1 )
                Select @nDiferenca = Abs( @nVmxDepr ) - ( Abs(@nValDepr1) + Abs(@nN3_VRDACM1 + @nN3_VRCDA1) )
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr1  = ( @nVmxDepr )- (@nN3_VRDACM1 + @nN3_VRCDA1)
                End
            End
        End
        If @nTxDep2 != 0 begin          
            If @IN_ATFMDMX = '02' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG2 * @nPercent
         
            If Abs(@nN3_VRDACM2 ) < Abs( @nVmxDepr ) begin
                Select @nValDepr2 = ( @nVmxDepr * @nTxDep2 )
                Select @nDiferenca = Abs( @nVmxDepr ) - (Abs(@nValDepr2) + Abs(@nN3_VRDACM2))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr2  = ( @nVmxDepr )- (@nN3_VRDACM2)
                end
            End
        End
        If @nTxDep3 != 0 begin
            If @IN_ATFMDMX = '03' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG3 * @nPercent
         
            If Abs(@nN3_VRDACM3 ) < Abs( @nVmxDepr ) begin
                Select @nValDepr3 = ( @nVmxDepr * @nTxDep3 )
                Select @nDiferenca = Abs( @nVmxDepr ) - (Abs(@nValDepr3) + Abs(@nN3_VRDACM3))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr3  = ( @nVmxDepr )- (@nN3_VRDACM3)
                end
            End
        End
        If @nTxDep4 != 0 begin
            If @IN_ATFMDMX = '04' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG4 * @nPercent
         
            If Abs(@nN3_VRDACM4 ) < Abs( @nVmxDepr ) begin
                Select @nValDepr4 = ( ( @nVmxDepr ) * @nTxDep4 )
                Select @nDiferenca = Abs( @nVmxDepr ) - (Abs(@nValDepr4) + Abs(@nN3_VRDACM4))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr4  = ( @nVmxDepr )- (@nN3_VRDACM4)
                end
            End
        End
        If @nTxDep5 != 0 begin
            If @IN_ATFMDMX = '05' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG5 * @nPercent
         
            If Abs(@nN3_VRDACM5 ) < Abs( @nVmxDepr ) begin
                Select @nValDepr5 = ( ( @nVmxDepr ) * @nTxDep5 )
                Select @nDiferenca = Abs( @nVmxDepr ) - (Abs(@nValDepr5) + Abs(@nN3_VRDACM5))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr5  = ( @nVmxDepr )- (@nN3_VRDACM5)
                End
            End
        End
        ##FIELDP02( 'SN3.N3_VORIG6' )
        If @nTxDep6 != 0 begin
            If @IN_ATFMDMX = '06' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG6 * @nPercent
         
            If Abs(@nN3_VRDACM6 ) < Abs( @nVmxDepr ) begin
                Select @nValDepr6 = ( ( @nVmxDepr ) * @nTxDep6 )
                Select @nDiferenca = Abs( @nVmxDepr ) - (Abs(@nValDepr6) + Abs(@nN3_VRDACM6))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr6  = ( @nVmxDepr )- (@nN3_VRDACM6)
                End
            End
        End
        ##ENDFIELDP02

        ##FIELDP03( 'SN3.N3_VORIG7' )
        If @nTxDep7 != 0 begin
            If @IN_ATFMDMX = '07' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG7 * @nPercent
         
            If Abs(@nN3_VRDACM7 ) < Abs( @nVmxDepr ) begin
                Select @nValDepr7 = ( ( @nVmxDepr ) * @nTxDep7 )
                Select @nDiferenca = Abs( @nVmxDepr ) - (Abs(@nValDepr7) + Abs(@nN3_VRDACM7))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr7  = ( @nVmxDepr )- (@nN3_VRDACM7)
                End
            End
        End
        ##ENDFIELDP03

        ##FIELDP04( 'SN3.N3_VORIG8' )
        If @nTxDep8 != 0 begin
            If @IN_ATFMDMX = '08' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG8 * @nPercent
         
            If Abs(@nN3_VRDACM8 ) < Abs( @nVmxDepr ) begin
                Select @nValDepr8 = ( ( @nVmxDepr ) * @nTxDep8 )
                Select @nDiferenca = Abs( @nVmxDepr ) - (Abs(@nValDepr8) + Abs(@nN3_VRDACM8))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr8  = ( @nVmxDepr )- (@nN3_VRDACM8)
                End
            End
        End
        ##ENDFIELDP04

        ##FIELDP05( 'SN3.N3_VORIG9' )
        If @nTxDep9 != 0 begin
            If @IN_ATFMDMX = '09' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG9 * @nPercent
         
            If Abs(@nN3_VRDACM9 ) < Abs( @nVmxDepr ) begin
                Select @nValDepr9 = ( ( @nVmxDepr ) * @nTxDep9 )
                Select @nDiferenca = Abs( @nVmxDepr ) - (Abs(@nValDepr9) + Abs(@nN3_VRDACM9))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr9  = ( @nVmxDepr )- (@nN3_VRDACM9)
                End
            End
        End
        ##ENDFIELDP05

        ##FIELDP06( 'SN3.N3_VORIG10' )
        If @nTxDep10 != 0 begin
            If @IN_ATFMDMX = '10' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG10 * @nPercent
         
            If Abs(@nN3_VRDACM10 ) < Abs( @nVmxDepr ) begin
                Select @nValDepr10 = ( ( @nVmxDepr ) * @nTxDep10 )
                Select @nDiferenca = Abs( @nVmxDepr ) - (Abs(@nValDepr10) + Abs(@nN3_VRDACM10))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr10  = ( @nVmxDepr )- (@nN3_VRDACM10)
                End
            End
        End
        ##ENDFIELDP06

        ##FIELDP07( 'SN3.N3_VORIG11' )
        If @nTxDep11 != 0 begin
            If @IN_ATFMDMX = '11' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG11 * @nPercent
         
            If Abs(@nN3_VRDACM11 ) < Abs( @nVmxDepr ) begin
                Select @nValDepr11 = ( ( @nVmxDepr ) * @nTxDep11 )
                Select @nDiferenca = Abs( @nVmxDepr ) - (Abs(@nValDepr11) + Abs(@nN3_VRDACM11))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr11  = ( @nVmxDepr )- (@nN3_VRDACM11)
                End
            End
        End
        ##ENDFIELDP07

        ##FIELDP08( 'SN3.N3_VORIG12' )
        If @nTxDep12 != 0 begin
            If @IN_ATFMDMX = '12' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG12 * @nPercent
         
            If Abs(@nN3_VRDACM12 ) < Abs( @nVmxDepr ) begin
                Select @nValDepr12 = ( ( @nVmxDepr ) * @nTxDep12 )
                Select @nDiferenca = Abs( @nVmxDepr ) - (Abs(@nValDepr12) + Abs(@nN3_VRDACM12))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr12  = ( @nVmxDepr )- (@nN3_VRDACM12)
                End
            End
        End
        ##ENDFIELDP08

        ##FIELDP09( 'SN3.N3_VORIG13' )
        If @nTxDep13 != 0 begin
            If @IN_ATFMDMX = '13' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG13 * @nPercent
         
            If Abs(@nN3_VRDACM13 ) < Abs( @nVmxDepr ) begin
                Select @nValDepr13 = ( ( @nVmxDepr ) * @nTxDep13 )
                Select @nDiferenca = Abs( @nVmxDepr ) - (Abs(@nValDepr13) + Abs(@nN3_VRDACM13))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr13  = ( @nVmxDepr )- (@nN3_VRDACM13)
                End
            End
        End
        ##ENDFIELDP09

        ##FIELDP10( 'SN3.N3_VORIG14' )
        If @nTxDep14 != 0 begin
            If @IN_ATFMDMX = '14' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG14 * @nPercent
         
            If Abs(@nN3_VRDACM14 ) < Abs( @nVmxDepr ) begin
                Select @nValDepr14 = ( ( @nVmxDepr ) * @nTxDep14 )
                Select @nDiferenca = Abs( @nVmxDepr ) - (Abs(@nValDepr14) + Abs(@nN3_VRDACM14))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr14  = ( @nVmxDepr )- (@nN3_VRDACM14)
                End
            End
        End
        ##ENDFIELDP10

        ##FIELDP11( 'SN3.N3_VORIG15' )
        If @nTxDep15 != 0 begin
            If @IN_ATFMDMX = '15' select @nVmxDepr = @nN3_VMXDEPR
            else select @nVmxDepr = @nN3_VORIG15 * @nPercent
         
            If Abs(@nN3_VRDACM15 ) < Abs( @nVmxDepr ) begin
                Select @nValDepr15 = ( ( @nVmxDepr ) * @nTxDep15 )
                Select @nDiferenca = Abs( @nVmxDepr ) - (Abs(@nValDepr15) + Abs(@nN3_VRDACM15))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr15  = ( @nVmxDepr )- (@nN3_VRDACM15)
                End
            End
        End
        ##ENDFIELDP11
    End
    /* ----------------------------------------------------------------------------------
    @cN3_TPDEPR = '2'  Reducao de saldos Valor de Salvamento
    ---------------------------------------------------------------------------------- */
    If @cN3_TPDEPR = '2' begin
        If @nTxDep1 != 0 begin
            If @nN3_VLSALV1 < ( Abs(@nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1) - Abs(@nN3_VRDACM1 + @nN3_VRCDA1)) begin
                Select @nValDepr1 = ( ( @nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1 - Abs(@nN3_VRDACM1 + @nN3_VRCDA1)) * @nTxDep1 )
                Select @nDiferenca = Abs(@nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1) - (Abs(@nValDepr1) + Abs(@nN3_VRDACM1 + @nN3_VRCDA1)) - @nN3_VLSALV1
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr1  = ( @nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1)- (@nN3_VRDACM1 + @nN3_VRCDA1) - @nN3_VLSALV1
                End
            End
        End
        /* ----------------------------------------------------------------------------------
            @nPercent = percentual do vlr de salv em relacao ao vlr total
            @nSalvAux = Valor do Salvamento para as outras moedas
            ---------------------------------------------------------------------------------- */
        Select @nPercent = @nN3_VLSALV1/@nN3_VORIG1+@nN3_AMPLIA1
      
        If @nTxDep2 != 0 begin
            Select @nSalvAux = 0
            Select @nSalvAux = @nN3_VORIG2 * @nPercent
            If Abs(@nSalvAux) < ( Abs( @nN3_VORIG2 + @nN3_AMPLIA2 ) - Abs(@nN3_VRDACM2) ) begin
                Select @nValDepr2 = ( ( @nN3_VORIG2 + @nN3_AMPLIA2 - Abs(@nN3_VRDACM2) ) * @nTxDep2 )
                Select @nDiferenca = Abs(@nN3_VORIG2 + @nN3_AMPLIA2) - (Abs(@nValDepr2) + Abs(@nN3_VRDACM2)) - @nSalvAux
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr2  = ( @nN3_VORIG2 + @nN3_AMPLIA2)- (@nN3_VRDACM2) - @nSalvAux
                end
            End
        End
      
        If @nTxDep3 != 0 begin
            Select @nSalvAux = 0
            Select @nSalvAux = @nN3_VORIG3 * @nPercent
            If Abs(@nSalvAux) < ( Abs( @nN3_VORIG3 + @nN3_AMPLIA3 ) - Abs(@nN3_VRDACM3) ) begin
                Select @nValDepr3 = ( ( @nN3_VORIG3 + @nN3_AMPLIA3 - Abs(@nN3_VRDACM3) ) * @nTxDep3 )
                Select @nDiferenca = Abs(@nN3_VORIG3 + @nN3_AMPLIA3) - (Abs(@nValDepr3) + Abs(@nN3_VRDACM3)) - @nSalvAux
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr3  = ( @nN3_VORIG3 + @nN3_AMPLIA3)- (@nN3_VRDACM3) - @nSalvAux
                end
            End
        End
      
        If @nTxDep4 != 0 begin
            Select @nSalvAux = 0
            Select @nSalvAux = @nN3_VORIG4 * @nPercent
            If Abs(@nSalvAux) < ( Abs( @nN3_VORIG4 + @nN3_AMPLIA4 ) - Abs(@nN3_VRDACM4) ) begin
                Select @nValDepr4 = ( ( @nN3_VORIG4 + @nN3_AMPLIA4 - Abs(@nN3_VRDACM4) ) * @nTxDep4 )
                Select @nDiferenca = Abs(@nN3_VORIG4 + @nN3_AMPLIA4) - (Abs(@nValDepr4) + Abs(@nN3_VRDACM4)) - @nSalvAux
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr4  = ( @nN3_VORIG4 + @nN3_AMPLIA4)- (@nN3_VRDACM4) - @nSalvAux
                end
            End
        End
      
        If @nTxDep5 != 0 begin
            Select @nSalvAux = 0
            Select @nSalvAux = @nN3_VORIG5 * @nPercent
            If Abs(@nSalvAux) < ( Abs( @nN3_VORIG5 + @nN3_AMPLIA5 )  - Abs(@nN3_VRDACM5) ) begin
                Select @nValDepr5 = ( ( @nN3_VORIG5 + @nN3_AMPLIA5 - Abs(@nN3_VRDACM5) ) * @nTxDep5 )
                Select @nDiferenca = Abs(@nN3_VORIG5 + @nN3_AMPLIA5) - (Abs(@nValDepr5) + Abs(@nN3_VRDACM5)) - @nSalvAux
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr5  = ( @nN3_VORIG5 + @nN3_AMPLIA5)- (@nN3_VRDACM5) - @nSalvAux
                End
            End
        End
        ##FIELDP02( 'SN3.N3_VORIG6' )
        If @nTxDep6 != 0 begin
            Select @nSalvAux = 0
            Select @nSalvAux = @nN3_VORIG6 * @nPercent
            If Abs(@nSalvAux) < ( Abs( @nN3_VORIG6 + @nN3_AMPLIA6 )  - Abs(@nN3_VRDACM6) ) begin
                Select @nValDepr6 = ( ( @nN3_VORIG6 + @nN3_AMPLIA6 - Abs(@nN3_VRDACM6) ) * @nTxDep6 )
                Select @nDiferenca = Abs(@nN3_VORIG6 + @nN3_AMPLIA6) - (Abs(@nValDepr6) + Abs(@nN3_VRDACM6)) - @nSalvAux
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr6  = ( @nN3_VORIG6 + @nN3_AMPLIA6)- (@nN3_VRDACM6) - @nSalvAux
                End
            End
        End
        ##ENDFIELDP02

        ##FIELDP03( 'SN3.N3_VORIG7' )
        If @nTxDep7 != 0 begin
            Select @nSalvAux = 0
            Select @nSalvAux = @nN3_VORIG7 * @nPercent
            If Abs(@nSalvAux) < ( Abs( @nN3_VORIG7 + @nN3_AMPLIA7 )  - Abs(@nN3_VRDACM7) ) begin
                Select @nValDepr7 = ( ( @nN3_VORIG7 + @nN3_AMPLIA7 - Abs(@nN3_VRDACM7) ) * @nTxDep7 )
                Select @nDiferenca = Abs(@nN3_VORIG7 + @nN3_AMPLIA7) - (Abs(@nValDepr7) + Abs(@nN3_VRDACM7)) - @nSalvAux
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr7  = ( @nN3_VORIG7 + @nN3_AMPLIA7)- (@nN3_VRDACM7) - @nSalvAux
                End
            End
        End
        ##ENDFIELDP03

        ##FIELDP04( 'SN3.N3_VORIG8' )
        If @nTxDep8 != 0 begin
            Select @nSalvAux = 0
            Select @nSalvAux = @nN3_VORIG8 * @nPercent
            If Abs(@nSalvAux) < ( Abs( @nN3_VORIG8 + @nN3_AMPLIA8 )  - Abs(@nN3_VRDACM8) ) begin
                Select @nValDepr8 = ( ( @nN3_VORIG8 + @nN3_AMPLIA8 - Abs(@nN3_VRDACM8) ) * @nTxDep8 )
                Select @nDiferenca = Abs(@nN3_VORIG8 + @nN3_AMPLIA8) - (Abs(@nValDepr8) + Abs(@nN3_VRDACM8)) - @nSalvAux
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr8  = ( @nN3_VORIG8 + @nN3_AMPLIA8)- (@nN3_VRDACM8) - @nSalvAux
                End
            End
        End
        ##ENDFIELDP04

        ##FIELDP05( 'SN3.N3_VORIG9' )
        If @nTxDep9 != 0 begin
            Select @nSalvAux = 0
            Select @nSalvAux = @nN3_VORIG9 * @nPercent
            If Abs(@nSalvAux) < ( Abs( @nN3_VORIG9 + @nN3_AMPLIA9 )  - Abs(@nN3_VRDACM9) ) begin
                Select @nValDepr9 = ( ( @nN3_VORIG9 + @nN3_AMPLIA9 - Abs(@nN3_VRDACM9) ) * @nTxDep9 )
                Select @nDiferenca = Abs(@nN3_VORIG9 + @nN3_AMPLIA9) - (Abs(@nValDepr9) + Abs(@nN3_VRDACM9)) - @nSalvAux
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr9  = ( @nN3_VORIG9 + @nN3_AMPLIA9)- (@nN3_VRDACM9) - @nSalvAux
                End
            End
        End
        ##ENDFIELDP05

        ##FIELDP06( 'SN3.N3_VORIG10' )
        If @nTxDep10 != 0 begin
            Select @nSalvAux = 0
            Select @nSalvAux = @nN3_VORIG10 * @nPercent
            If Abs(@nSalvAux) < ( Abs( @nN3_VORIG10 + @nN3_AMPLIA10 )  - Abs(@nN3_VRDACM10) ) begin
                Select @nValDepr10 = ( ( @nN3_VORIG10 + @nN3_AMPLIA10 - Abs(@nN3_VRDACM10) ) * @nTxDep10 )
                Select @nDiferenca = Abs(@nN3_VORIG10 + @nN3_AMPLIA10) - (Abs(@nValDepr10) + Abs(@nN3_VRDACM10)) - @nSalvAux
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr10  = ( @nN3_VORIG10 + @nN3_AMPLIA10)- (@nN3_VRDACM10) - @nSalvAux
                End
            End
        End
        ##ENDFIELDP06

        ##FIELDP07( 'SN3.N3_VORIG11' )
        If @nTxDep11 != 0 begin
            Select @nSalvAux = 0
            Select @nSalvAux = @nN3_VORIG11 * @nPercent
            If Abs(@nSalvAux) < ( Abs( @nN3_VORIG11 + @nN3_AMPLIA11 )  - Abs(@nN3_VRDACM11) ) begin
                Select @nValDepr11 = ( ( @nN3_VORIG11 + @nN3_AMPLIA11 - Abs(@nN3_VRDACM11) ) * @nTxDep11 )
                Select @nDiferenca = Abs(@nN3_VORIG11 + @nN3_AMPLIA11) - (Abs(@nValDepr11) + Abs(@nN3_VRDACM11)) - @nSalvAux
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr11  = ( @nN3_VORIG11 + @nN3_AMPLIA11)- (@nN3_VRDACM11) - @nSalvAux
                End
            End
        End
        ##ENDFIELDP07

        ##FIELDP08( 'SN3.N3_VORIG12' )
        If @nTxDep12 != 0 begin
            Select @nSalvAux = 0
            Select @nSalvAux = @nN3_VORIG12 * @nPercent
            If Abs(@nSalvAux) < ( Abs( @nN3_VORIG12 + @nN3_AMPLIA12 )  - Abs(@nN3_VRDACM12) ) begin
                Select @nValDepr12 = ( ( @nN3_VORIG12 + @nN3_AMPLIA12 - Abs(@nN3_VRDACM12) ) * @nTxDep12 )
                Select @nDiferenca = Abs(@nN3_VORIG12 + @nN3_AMPLIA12) - (Abs(@nValDepr12) + Abs(@nN3_VRDACM12)) - @nSalvAux
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr12  = ( @nN3_VORIG12 + @nN3_AMPLIA12)- (@nN3_VRDACM12) - @nSalvAux
                End
            End
        End
        ##ENDFIELDP08

        ##FIELDP09( 'SN3.N3_VORIG13' )
        If @nTxDep13 != 0 begin
            Select @nSalvAux = 0
            Select @nSalvAux = @nN3_VORIG13 * @nPercent
            If Abs(@nSalvAux) < ( Abs( @nN3_VORIG13 + @nN3_AMPLIA13 )  - Abs(@nN3_VRDACM13) ) begin
                Select @nValDepr13 = ( ( @nN3_VORIG13 + @nN3_AMPLIA13 - Abs(@nN3_VRDACM13) ) * @nTxDep13 )
                Select @nDiferenca = Abs(@nN3_VORIG13 + @nN3_AMPLIA13) - (Abs(@nValDepr13) + Abs(@nN3_VRDACM13)) - @nSalvAux
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr13  = ( @nN3_VORIG13 + @nN3_AMPLIA13)- (@nN3_VRDACM13) - @nSalvAux
                End
            End
        End
        ##ENDFIELDP09

        ##FIELDP10( 'SN3.N3_VORIG14' )
        If @nTxDep14 != 0 begin
            Select @nSalvAux = 0
            Select @nSalvAux = @nN3_VORIG14 * @nPercent
            If Abs(@nSalvAux) < ( Abs( @nN3_VORIG14 + @nN3_AMPLIA14 )  - Abs(@nN3_VRDACM14) ) begin
                Select @nValDepr14 = ( ( @nN3_VORIG14 + @nN3_AMPLIA14 - Abs(@nN3_VRDACM14) ) * @nTxDep14 )
                Select @nDiferenca = Abs(@nN3_VORIG14 + @nN3_AMPLIA14) - (Abs(@nValDepr14) + Abs(@nN3_VRDACM14)) - @nSalvAux
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr14  = ( @nN3_VORIG14 + @nN3_AMPLIA14)- (@nN3_VRDACM14) - @nSalvAux
                End
            End
        End
        ##ENDFIELDP10

        ##FIELDP11( 'SN3.N3_VORIG15' )
        If @nTxDep15 != 0 begin
            Select @nSalvAux = 0
            Select @nSalvAux = @nN3_VORIG15 * @nPercent
            If Abs(@nSalvAux) < ( Abs( @nN3_VORIG15 + @nN3_AMPLIA15 )  - Abs(@nN3_VRDACM15) ) begin
                Select @nValDepr15 = ( ( @nN3_VORIG15 + @nN3_AMPLIA15 - Abs(@nN3_VRDACM15) ) * @nTxDep15 )
                Select @nDiferenca = Abs(@nN3_VORIG15 + @nN3_AMPLIA15) - (Abs(@nValDepr15) + Abs(@nN3_VRDACM15)) - @nSalvAux
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr15  = ( @nN3_VORIG15 + @nN3_AMPLIA15)- (@nN3_VRDACM15) - @nSalvAux
                End
            End
        End
        ##ENDFIELDP11
    end
    ##FIELDP01( 'SN3.N3_CODIND' )
       /*   ------------------------------------------------------------------------------
                quebra de fonte - informix  tem limitação 35000 caracteres
              ------------------------------------------------------------------------------   */ 
    If @cN3_TPDEPR = 'A' begin
        Exec ATF015_## @nTxDep1, @nTxDep2, @nTxDep3, @nTxDep4, @nTxDep5,  @IN_RECNO,  @IN_CODIND,
                                ##FIELDP02( 'SN3.N3_VORIG6' )
                                @nTxDep6,
                                ##ENDFIELDP02
                                ##FIELDP03( 'SN3.N3_VORIG7' )
                                @nTxDep7,
                                ##ENDFIELDP03
                                ##FIELDP04( 'SN3.N3_VORIG8' )
                                @nTxDep8,
                                ##ENDFIELDP04
                                ##FIELDP05( 'SN3.N3_VORIG9' )
                                @nTxDep9,
                                ##ENDFIELDP05
                                ##FIELDP06( 'SN3.N3_VORIG10' )
                                @nTxDep10, 
                                ##ENDFIELDP06
                                ##FIELDP07( 'SN3.N3_VORIG11' )
                                @nTxDep11,
                                ##ENDFIELDP07
                                ##FIELDP08( 'SN3.N3_VORIG12' )
                                @nTxDep12,
                                ##ENDFIELDP08
                                ##FIELDP09( 'SN3.N3_VORIG13' )
                                @nTxDep13,
                                ##ENDFIELDP09
                                ##FIELDP10( 'SN3.N3_VORIG14' )
                                @nTxDep14,
                                ##ENDFIELDP10
                                ##FIELDP11( 'SN3.N3_VORIG15' )
                                @nTxDep15,
                                ##ENDFIELDP11
                                @nValDepr1 OutPut,
                                @nValDepr2 OutPut,
                                @nValDepr3 OutPut,
                                @nValDepr4  OutPut,
                                @nValDepr5 OutPut
                                ##FIELDP02( 'SN3.N3_VORIG6' )
                                , @nValDepr6 OutPut
                                ##ENDFIELDP02
                                ##FIELDP03( 'SN3.N3_VORIG7' )
                                , @nValDepr7 OutPut
                                ##ENDFIELDP03
                                ##FIELDP04( 'SN3.N3_VORIG8' )
                                , @nValDepr8  OutPut
                                ##ENDFIELDP04
                                ##FIELDP05( 'SN3.N3_VORIG9' )
                                , @nValDepr9 OutPut
                                ##ENDFIELDP05
                                ##FIELDP06( 'SN3.N3_VORIG10' )
                                , @nValDepr10  OutPut
                                ##ENDFIELDP06
                                ##FIELDP07( 'SN3.N3_VORIG11' )
                                , @nValDepr11 OutPut
                                ##ENDFIELDP07
                                ##FIELDP08( 'SN3.N3_VORIG12' )
                                , @nValDepr12 OutPut
                                ##ENDFIELDP08
                                ##FIELDP09( 'SN3.N3_VORIG13' )
                                , @nValDepr13 OutPut
                                ##ENDFIELDP09
                                ##FIELDP10( 'SN3.N3_VORIG14' )
                                , @nValDepr14 OutPut
                                ##ENDFIELDP10
                                ##FIELDP11( 'SN3.N3_VORIG15' )
                                , @nValDepr15 OutPut
                                ##ENDFIELDP11
    end
    ##ENDFIELDP01
    
    If @cN3_TPDEPR != '2' and @cN3_TPDEPR != '6' and @cN3_TPDEPR != '7' and @cN3_TPDEPR != 'A' begin
        /* ----------------------------------------------------------------------------------
        @cN3_TPDEPR = '1'  Depreciação Linear
            ---------------------------------------------------------------------------------- */
        If @nTxDep1 != 0 begin
            If Abs(@nN3_VRDACM1 + @nN3_VRCDA1) < Abs(@nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1) begin
                Select @nValDepr1 = ( ( @nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1) * @nTxDep1 )
                Select @nDiferenca = Abs(@nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1) - (Abs(@nValDepr1) + Abs(@nN3_VRDACM1 + @nN3_VRCDA1))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr1  = ( @nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1)- (@nN3_VRDACM1 + @nN3_VRCDA1)
                End
            End
        End
        If @nTxDep2 != 0 begin
            If Abs(@nN3_VRDACM2 ) < Abs( @nN3_VORIG2 + @nN3_AMPLIA2 ) begin
                Select @nValDepr2 = ( ( @nN3_VORIG2 + @nN3_AMPLIA2) * @nTxDep2 )
                Select @nDiferenca = Abs(@nN3_VORIG2 + @nN3_AMPLIA2) - (Abs(@nValDepr2) + Abs(@nN3_VRDACM2))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr2  = ( @nN3_VORIG2 + @nN3_AMPLIA2)- (@nN3_VRDACM2)
                end
            End
        End
        If @nTxDep3 != 0 begin
            If Abs(@nN3_VRDACM3 ) < Abs( @nN3_VORIG3 + @nN3_AMPLIA3 ) begin
                Select @nValDepr3 = ( ( @nN3_VORIG3 + @nN3_AMPLIA3) * @nTxDep3 )
                Select @nDiferenca = Abs(@nN3_VORIG3 + @nN3_AMPLIA3) - (Abs(@nValDepr3) + Abs(@nN3_VRDACM3))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr3  = ( @nN3_VORIG3 + @nN3_AMPLIA3)- (@nN3_VRDACM3)
                end
            End
        End
        If @nTxDep4 != 0 begin
            If Abs(@nN3_VRDACM4 ) < Abs( @nN3_VORIG4 + @nN3_AMPLIA4 ) begin
            Select @nValDepr4 = ( ( @nN3_VORIG4 + @nN3_AMPLIA4) * @nTxDep4 )
            Select @nDiferenca = Abs(@nN3_VORIG4 + @nN3_AMPLIA4) - (Abs(@nValDepr4) + Abs(@nN3_VRDACM4))
            If ( @nDiferenca ) <= 0 begin
                Select @nValDepr4  = ( @nN3_VORIG4 + @nN3_AMPLIA4)- (@nN3_VRDACM4)
            end
            End
        End
        If @nTxDep5 != 0 begin
            If Abs(@nN3_VRDACM5 ) < Abs( @nN3_VORIG5 + @nN3_AMPLIA5 ) begin
                Select @nValDepr5 = ( ( @nN3_VORIG5 + @nN3_AMPLIA5) * @nTxDep5 )
                Select @nDiferenca = Abs(@nN3_VORIG5 + @nN3_AMPLIA5) - (Abs(@nValDepr5) + Abs(@nN3_VRDACM5))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr5  = ( @nN3_VORIG5 + @nN3_AMPLIA5)- (@nN3_VRDACM5)
                End
            End
        End
        ##FIELDP02( 'SN3.N3_VORIG6' )
        If @nTxDep6 != 0 begin
            If Abs(@nN3_VRDACM6 ) < Abs( @nN3_VORIG6 + @nN3_AMPLIA6 ) begin
                Select @nValDepr6 = ( ( @nN3_VORIG6 + @nN3_AMPLIA6) * @nTxDep6 )
                Select @nDiferenca = Abs(@nN3_VORIG6 + @nN3_AMPLIA6) - (Abs(@nValDepr6) + Abs(@nN3_VRDACM6))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr6  = ( @nN3_VORIG6 + @nN3_AMPLIA6)- (@nN3_VRDACM6)
                End
            End
        End
        ##ENDFIELDP02

        ##FIELDP03( 'SN3.N3_VORIG7' )
        If @nTxDep7 != 0 begin
            If Abs(@nN3_VRDACM7 ) < Abs( @nN3_VORIG7 + @nN3_AMPLIA7 ) begin
                Select @nValDepr7 = ( ( @nN3_VORIG7 + @nN3_AMPLIA7) * @nTxDep7 )
                Select @nDiferenca = Abs(@nN3_VORIG7 + @nN3_AMPLIA7) - (Abs(@nValDepr7) + Abs(@nN3_VRDACM7))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr7  = ( @nN3_VORIG7 + @nN3_AMPLIA7)- (@nN3_VRDACM7)
                End
            End
        End
        ##ENDFIELDP03

        ##FIELDP04( 'SN3.N3_VORIG8' )
        If @nTxDep8 != 0 begin
            If Abs(@nN3_VRDACM8 ) < Abs( @nN3_VORIG8 + @nN3_AMPLIA8 ) begin
                Select @nValDepr8 = ( ( @nN3_VORIG8 + @nN3_AMPLIA8) * @nTxDep8 )
                Select @nDiferenca = Abs(@nN3_VORIG8 + @nN3_AMPLIA8) - (Abs(@nValDepr8) + Abs(@nN3_VRDACM8))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr8  = ( @nN3_VORIG8 + @nN3_AMPLIA8)- (@nN3_VRDACM8)
                End
            End
        End
        ##ENDFIELDP04

        ##FIELDP05( 'SN3.N3_VORIG9' )
        If @nTxDep9 != 0 begin
            If Abs(@nN3_VRDACM9 ) < Abs( @nN3_VORIG9 + @nN3_AMPLIA9 ) begin
                Select @nValDepr9 = ( ( @nN3_VORIG9 + @nN3_AMPLIA9) * @nTxDep9 )
                Select @nDiferenca = Abs(@nN3_VORIG9 + @nN3_AMPLIA9) - (Abs(@nValDepr9) + Abs(@nN3_VRDACM9))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr9  = ( @nN3_VORIG9 + @nN3_AMPLIA9)- (@nN3_VRDACM9)
                End
            End
        End
        ##ENDFIELDP05

        ##FIELDP06( 'SN3.N3_VORIG10' )
        If @nTxDep10 != 0 begin
            If Abs(@nN3_VRDACM10 ) < Abs( @nN3_VORIG10 + @nN3_AMPLIA10 ) begin
                Select @nValDepr10 = ( ( @nN3_VORIG10 + @nN3_AMPLIA10) * @nTxDep10 )
                Select @nDiferenca = Abs(@nN3_VORIG10 + @nN3_AMPLIA10) - (Abs(@nValDepr10) + Abs(@nN3_VRDACM10))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr10  = ( @nN3_VORIG10 + @nN3_AMPLIA10)- (@nN3_VRDACM10)
                End
            End
        End
        ##ENDFIELDP06

        ##FIELDP07( 'SN3.N3_VORIG11' )
        If @nTxDep11 != 0 begin
            If Abs(@nN3_VRDACM11 ) < Abs( @nN3_VORIG11 + @nN3_AMPLIA11 ) begin
                Select @nValDepr11 = ( ( @nN3_VORIG11 + @nN3_AMPLIA11) * @nTxDep11 )
                Select @nDiferenca = Abs(@nN3_VORIG11 + @nN3_AMPLIA11) - (Abs(@nValDepr11) + Abs(@nN3_VRDACM11))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr11  = ( @nN3_VORIG11 + @nN3_AMPLIA11)- (@nN3_VRDACM11)
                End
            End
        End
        ##ENDFIELDP07

        ##FIELDP08( 'SN3.N3_VORIG12' )
        If @nTxDep12 != 0 begin
            If Abs(@nN3_VRDACM12 ) < Abs( @nN3_VORIG12 + @nN3_AMPLIA12 ) begin
                Select @nValDepr12 = ( ( @nN3_VORIG12 + @nN3_AMPLIA12) * @nTxDep12 )
                Select @nDiferenca = Abs(@nN3_VORIG12 + @nN3_AMPLIA12) - (Abs(@nValDepr12) + Abs(@nN3_VRDACM12))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr12  = ( @nN3_VORIG12 + @nN3_AMPLIA12)- (@nN3_VRDACM12)
                End
            End
        End
        ##ENDFIELDP08

        ##FIELDP09( 'SN3.N3_VORIG13' )
        If @nTxDep13 != 0 begin
            If Abs(@nN3_VRDACM13 ) < Abs( @nN3_VORIG13 + @nN3_AMPLIA13 ) begin
                Select @nValDepr13 = ( ( @nN3_VORIG13 + @nN3_AMPLIA13) * @nTxDep13 )
                Select @nDiferenca = Abs(@nN3_VORIG13 + @nN3_AMPLIA13) - (Abs(@nValDepr13) + Abs(@nN3_VRDACM13))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr13  = ( @nN3_VORIG13 + @nN3_AMPLIA13)- (@nN3_VRDACM13)
                End
            End
        End
        ##ENDFIELDP09

        ##FIELDP10( 'SN3.N3_VORIG14' )
        If @nTxDep14 != 0 begin
            If Abs(@nN3_VRDACM14 ) < Abs( @nN3_VORIG14 + @nN3_AMPLIA14 ) begin
                Select @nValDepr14 = ( ( @nN3_VORIG14 + @nN3_AMPLIA14) * @nTxDep14 )
                Select @nDiferenca = Abs(@nN3_VORIG14 + @nN3_AMPLIA14) - (Abs(@nValDepr14) + Abs(@nN3_VRDACM14))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr14  = ( @nN3_VORIG14 + @nN3_AMPLIA14)- (@nN3_VRDACM14)
                End
            End
        End
        ##ENDFIELDP10

        ##FIELDP11( 'SN3.N3_VORIG15' )
        If @nTxDep15 != 0 begin
            If Abs(@nN3_VRDACM15 ) < Abs( @nN3_VORIG15 + @nN3_AMPLIA15 ) begin
                Select @nValDepr15 = ( ( @nN3_VORIG15 + @nN3_AMPLIA15) * @nTxDep15 )
                Select @nDiferenca = Abs(@nN3_VORIG15 + @nN3_AMPLIA15) - (Abs(@nValDepr15) + Abs(@nN3_VRDACM15))
                If ( @nDiferenca ) <= 0 begin
                    Select @nValDepr15  = ( @nN3_VORIG15 + @nN3_AMPLIA15)- (@nN3_VRDACM15)
                End
            End
        End
        ##ENDFIELDP11
    End
    /* ----------------------------------------------------------------------------------
    Proporcionaliza as depreciacoes
    ---------------------------------------------------------------------------------- */
    If @IN_LMESCHEIO = '0' and (@IN_ULTDIA != @IN_NRODIAS) begin
        select @nValDepr1 = (@nValDepr1 / @IN_ULTDIA) * @IN_NRODIAS
        select @nValDepr2 = (@nValDepr2 / @IN_ULTDIA) * @IN_NRODIAS
        select @nValDepr3 = (@nValDepr3 / @IN_ULTDIA) * @IN_NRODIAS
        select @nValDepr4 = (@nValDepr4 / @IN_ULTDIA) * @IN_NRODIAS
        select @nValDepr5 = (@nValDepr5 / @IN_ULTDIA) * @IN_NRODIAS

        ##FIELDP02( 'SN3.N3_VORIG6' )
        select @nValDepr6 = (@nValDepr6 / @IN_ULTDIA) * @IN_NRODIAS
        ##ENDFIELDP02

        ##FIELDP03( 'SN3.N3_VORIG7' )
        select @nValDepr7 = (@nValDepr7 / @IN_ULTDIA) * @IN_NRODIAS
        ##ENDFIELDP03

        ##FIELDP04( 'SN3.N3_VORIG8' )
        select @nValDepr8 = (@nValDepr8 / @IN_ULTDIA) * @IN_NRODIAS
        ##ENDFIELDP04

        ##FIELDP05( 'SN3.N3_VORIG9' )
        select @nValDepr9 = (@nValDepr9 / @IN_ULTDIA) * @IN_NRODIAS
        ##ENDFIELDP05

        ##FIELDP06( 'SN3.N3_VORIG10' )
        select @nValDepr10 = (@nValDepr10 / @IN_ULTDIA) * @IN_NRODIAS
        ##ENDFIELDP06

        ##FIELDP07( 'SN3.N3_VORIG11' )
        select @nValDepr11 = (@nValDepr11 / @IN_ULTDIA) * @IN_NRODIAS
        ##ENDFIELDP07

        ##FIELDP08( 'SN3.N3_VORIG12' )
        select @nValDepr12 = (@nValDepr12 / @IN_ULTDIA) * @IN_NRODIAS
        ##ENDFIELDP08

        ##FIELDP09( 'SN3.N3_VORIG13' )
        select @nValDepr13 = (@nValDepr13 / @IN_ULTDIA) * @IN_NRODIAS
        ##ENDFIELDP09

        ##FIELDP10( 'SN3.N3_VORIG14' )
        select @nValDepr14 = (@nValDepr14 / @IN_ULTDIA) * @IN_NRODIAS
        ##ENDFIELDP10

        ##FIELDP11( 'SN3.N3_VORIG15' )
        select @nValDepr15 = (@nValDepr15 / @IN_ULTDIA) * @IN_NRODIAS
        ##ENDFIELDP11
    End
    Select @OUT_DEP1 = @nValDepr1
    Select @OUT_DEP2 = @nValDepr2
    Select @OUT_DEP3 = @nValDepr3
    Select @OUT_DEP4 = @nValDepr4
    Select @OUT_DEP5 = @nValDepr5
    ##FIELDP02( 'SN3.N3_VORIG6' )
    Select @OUT_DEP6 = @nValDepr6
    ##ENDFIELDP02

    ##FIELDP03( 'SN3.N3_VORIG7' )
    Select @OUT_DEP7 = @nValDepr7
    ##ENDFIELDP03

    ##FIELDP04( 'SN3.N3_VORIG8' )
    Select @OUT_DEP8 = @nValDepr8
    ##ENDFIELDP04

    ##FIELDP05( 'SN3.N3_VORIG9' )
    Select @OUT_DEP9 = @nValDepr9
    ##ENDFIELDP05

    ##FIELDP06( 'SN3.N3_VORIG10' )
    Select @OUT_DEP10 = @nValDepr10
    ##ENDFIELDP06

    ##FIELDP07( 'SN3.N3_VORIG11' )
    Select @OUT_DEP11 = @nValDepr11
    ##ENDFIELDP07

    ##FIELDP08( 'SN3.N3_VORIG12' )
    Select @OUT_DEP12 = @nValDepr12
    ##ENDFIELDP08

    ##FIELDP09( 'SN3.N3_VORIG13' )
    Select @OUT_DEP13 = @nValDepr13
    ##ENDFIELDP09

    ##FIELDP10( 'SN3.N3_VORIG14' )
    Select @OUT_DEP14 = @nValDepr14
    ##ENDFIELDP10

    ##FIELDP11( 'SN3.N3_VORIG15' )
    Select @OUT_DEP15 = @nValDepr15
    ##ENDFIELDP11
end
