Create Procedure ATF008_## (
   @IN_MOEDAATF  Char( 02 ),
   @IN_TAXACOR   Float,
   @IN_RECNO     Integer,
   @IN_DEP1      Float,
   @IN_DEP2      Float,
   @IN_DEP3      Float,
   @IN_DEP4      Float,
   @IN_DEP5      Float,
    ##FIELDP02( 'SN3.N3_VORIG6' )
    @IN_DEP6      Float,
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG7' )
    @IN_DEP7      Float,
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG8' )
    @IN_DEP8      Float,
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG9' )
    @IN_DEP9      Float,
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG10' )
    @IN_DEP10      Float,
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG11' )
    @IN_DEP11      Float,
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG12' )
    @IN_DEP12      Float,
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG13' )
    @IN_DEP13      Float,
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG14' )
    @IN_DEP14      Float,
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG15' )
    @IN_DEP15      Float,
    ##ENDFIELDP11
   @IN_DATADEP   Char( 08 ),
   @OUT_CORRECAO Float OutPut,
   @OUT_CORDEP   Float OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ATFA050.PRW </s>
    Descricao       - <d>  Calculo das Correcoes da Depreciacao e do Ativo </d>
    Funcao do Siga  -      Atfa050()
    Entrada         - <ri> @IN_MOEDAATF   - moeda do Ativo
                           @IN_TAXACOR    - Taxa de Correcao
                           @IN_RECNO      - recno do ativo no SN3
                           @IN_DEP1       - Valor da depreciacao na moeda 1
                           @IN_DEP2       - Valor da depreciacao na moeda 2
                           @IN_DEP3       - Valor da depreciacao na moeda 3
                           @IN_DEP4       - Valor da depreciacao na moeda 4
                           @IN_DEP5       - Valor da depreciacao na moeda 5
                           @IN_DATADEP    - Data do Calculo   </ri>
    Saida           - <o>  @OUT_CORDEP    - Valor da correcao da depreciacao
                           @OUT_CORRECAO  - Valor da correcao do bem </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     04/10/2006
-------------------------------------------------------------------------------------- */
Declare @nTaxCor     Float
Declare @nValCor     Float
Declare @nValCorDep  Float
Declare @nValDepr1   Float
Declare @nValDepr2   Float
Declare @nValDepr3   Float
Declare @nValDepr4   Float
Declare @nValDepr5   Float
Declare @nN3_VORIG1  Float
Declare @nN3_VORIG2  Float
Declare @nN3_VORIG3  Float
Declare @nN3_VORIG4  Float
Declare @nN3_VORIG5  Float
Declare @nN3_AMPLIA1 Float
Declare @nN3_AMPLIA2 Float
Declare @nN3_AMPLIA3 Float
Declare @nN3_AMPLIA4 Float
Declare @nN3_AMPLIA5 Float
Declare @nN3_VRDACM1 Float
Declare @nN3_VRDACM2 Float
Declare @nN3_VRDACM3 Float
Declare @nN3_VRDACM4 Float
Declare @nN3_VRDACM5 Float
Declare @nN3_VRCACM1 Float
Declare @nN3_VRCDA1  Float
Declare @cN3_CCORREC Char( 'N3_CCORREC' )
Declare @cN3_CDESP   Char( 'N3_CDESP' )
##FIELDP02( 'SN3.N3_VORIG6' )
Declare @nValDepr6   Float
Declare @nN3_VORIG6  Float
Declare @nN3_AMPLIA6 Float
Declare @nN3_VRDACM6 Float
##ENDFIELDP02
##FIELDP03( 'SN3.N3_VORIG7' )
Declare @nValDepr7   Float
Declare @nN3_VORIG7  Float
Declare @nN3_AMPLIA7 Float
Declare @nN3_VRDACM7 Float
##ENDFIELDP03
##FIELDP04( 'SN3.N3_VORIG8' )
Declare @nValDepr8   Float
Declare @nN3_VORIG8  Float
Declare @nN3_AMPLIA8 Float
Declare @nN3_VRDACM8 Float
##ENDFIELDP04
##FIELDP05( 'SN3.N3_VORIG9' )
Declare @nValDepr9   Float
Declare @nN3_VORIG9  Float
Declare @nN3_AMPLIA9 Float
Declare @nN3_VRDACM9 Float
##ENDFIELDP05
##FIELDP06( 'SN3.N3_VORIG10' )
Declare @nValDepr10   Float
Declare @nN3_VORIG10  Float
Declare @nN3_AMPLIA10 Float
Declare @nN3_VRDACM10 Float
##ENDFIELDP06
##FIELDP07( 'SN3.N3_VORIG11' )
Declare @nValDepr11   Float
Declare @nN3_VORIG11  Float
Declare @nN3_AMPLIA11 Float
Declare @nN3_VRDACM11 Float
##ENDFIELDP07
##FIELDP08( 'SN3.N3_VORIG12' )
Declare @nValDepr12   Float
Declare @nN3_VORIG12  Float
Declare @nN3_AMPLIA12 Float
Declare @nN3_VRDACM12 Float
##ENDFIELDP08
##FIELDP09( 'SN3.N3_VORIG13' )
Declare @nValDepr13   Float
Declare @nN3_VORIG13  Float
Declare @nN3_AMPLIA13 Float
Declare @nN3_VRDACM13 Float
##ENDFIELDP09
##FIELDP10( 'SN3.N3_VORIG14' )
Declare @nValDepr14   Float
Declare @nN3_VORIG14  Float
Declare @nN3_AMPLIA14 Float
Declare @nN3_VRDACM14 Float
##ENDFIELDP10
##FIELDP11( 'SN3.N3_VORIG15' )
Declare @nValDepr15   Float
Declare @nN3_VORIG15  Float
Declare @nN3_AMPLIA15 Float
Declare @nN3_VRDACM15 Float
##ENDFIELDP11

begin
    Select @nTaxCor    = @IN_TAXACOR
    Select @nValCor    = 0
    Select @nValCorDep = 0
    select @nValDepr1  = @IN_DEP1
    select @nValDepr2  = @IN_DEP2
    select @nValDepr3  = @IN_DEP3
    select @nValDepr4  = @IN_DEP4
    select @nValDepr5  = @IN_DEP5
    ##FIELDP02( 'SN3.N3_VORIG6' )
    select @nValDepr6    = @IN_DEP6
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG7' )
    Select @nValDepr7    = @IN_DEP7
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG8' )
    Select @nValDepr8    = @IN_DEP8
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG9' )
    Select @nValDepr9    = @IN_DEP9
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG10' )
    Select @nValDepr10    = @IN_DEP10
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG11' )
    Select @nValDepr11    = @IN_DEP11
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG12' )
    Select @nValDepr12    = @IN_DEP12
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG13' )
    Select @nValDepr13    = @IN_DEP13
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG14' )
    Select @nValDepr14    = @IN_DEP14
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG15' )
    Select @nValDepr15    = @IN_DEP15
    ##ENDFIELDP11
    
    If @nTaxCor != 0 begin
    Select @nN3_VORIG1  = N3_VORIG1,  @nN3_VORIG2  = N3_VORIG2,  @nN3_VORIG3  = N3_VORIG3,  @nN3_VORIG4  = N3_VORIG4,  @nN3_VORIG5  = N3_VORIG5,
            @nN3_AMPLIA1 = N3_AMPLIA1, @nN3_AMPLIA2 = N3_AMPLIA2, @nN3_AMPLIA3 = N3_AMPLIA3, @nN3_AMPLIA4 = N3_AMPLIA4, @nN3_AMPLIA5 = N3_AMPLIA5,
            @nN3_VRDACM1 = N3_VRDACM1, @nN3_VRDACM2 = N3_VRDACM2, @nN3_VRDACM3 = N3_VRDACM3, @nN3_VRDACM4 = N3_VRDACM4, @nN3_VRDACM5 = N3_VRDACM5,
            @nN3_VRCACM1 = N3_VRCACM1, @nN3_VRCDA1  = N3_VRCDA1,  @cN3_CCORREC = N3_CCORREC, @cN3_CDESP   = N3_CDESP
            ##FIELDP02( 'SN3.N3_VORIG6' )
            ,  @nN3_VORIG6  = N3_VORIG6,  @nN3_AMPLIA6 = N3_AMPLIA6, @nN3_VRDACM6 = N3_VRDACM6
            ##ENDFIELDP02
            ##FIELDP03( 'SN3.N3_VORIG7' )
            ,  @nN3_VORIG7  = N3_VORIG7,  @nN3_AMPLIA7 = N3_AMPLIA7, @nN3_VRDACM7 = N3_VRDACM7
            ##ENDFIELDP03
            ##FIELDP04( 'SN3.N3_VORIG8' )
            ,  @nN3_VORIG8  = N3_VORIG8,  @nN3_AMPLIA8 = N3_AMPLIA8, @nN3_VRDACM8 = N3_VRDACM8
            ##ENDFIELDP04
            ##FIELDP05( 'SN3.N3_VORIG9' )
            ,  @nN3_VORIG9  = N3_VORIG9,  @nN3_AMPLIA9 = N3_AMPLIA9, @nN3_VRDACM9 = N3_VRDACM9
            ##ENDFIELDP05
            ##FIELDP06( 'SN3.N3_VORIG10' )
            ,  @nN3_VORIG10  = N3_VORIG10,  @nN3_AMPLIA10 = N3_AMPLI10, @nN3_VRDACM10 = N3_VRDAC10
            ##ENDFIELDP06
            ##FIELDP07( 'SN3.N3_VORIG11' )
            ,  @nN3_VORIG11  = N3_VORIG11,  @nN3_AMPLIA11 = N3_AMPLI11, @nN3_VRDACM11 = N3_VRDAC11
            ##ENDFIELDP07
            ##FIELDP08( 'SN3.N3_VORIG12' )
            ,  @nN3_VORIG12  = N3_VORIG12,  @nN3_AMPLIA12 = N3_AMPLI12, @nN3_VRDACM12 = N3_VRDAC12
            ##ENDFIELDP08
            ##FIELDP09( 'SN3.N3_VORIG13' )
            ,  @nN3_VORIG13  = N3_VORIG13,  @nN3_AMPLIA13 = N3_AMPLI13, @nN3_VRDACM13 = N3_VRDAC13
            ##ENDFIELDP09
            ##FIELDP10( 'SN3.N3_VORIG14' )
            ,  @nN3_VORIG14  = N3_VORIG14,  @nN3_AMPLIA14 = N3_AMPLI14, @nN3_VRDACM14 = N3_VRDAC14
            ##ENDFIELDP10
            ##FIELDP11( 'SN3.N3_VORIG15' )
            ,  @nN3_VORIG15  = N3_VORIG15,  @nN3_AMPLIA15 = N3_AMPLI15, @nN3_VRDACM15 = N3_VRDAC15
            ##ENDFIELDP11
    From SN3###
    Where R_E_C_N_O_ = @IN_RECNO
    
    If @IN_MOEDAATF = '02'  begin
        select @nValCor    = ( Abs(@nN3_VORIG2 + @nN3_AMPLIA2) * @nTaxCor) - Abs(@nN3_VRCACM1 + @nN3_VORIG1 + @nN3_AMPLIA1)
        select @nValCorDep = ( (Abs(@nN3_VRDACM2 + @nValDepr2) * @nTaxCor) - (@nN3_VRDACM1 + @nValDepr1 + @nN3_VRCDA1))
    End
    If @IN_MOEDAATF = '03' begin
        select @nValCor    = ( Abs(@nN3_VORIG3 + @nN3_AMPLIA3) * @nTaxCor) - Abs(@nN3_VRCACM1 + @nN3_VORIG1 + @nN3_AMPLIA1)
        select @nValCorDep = ( (Abs(@nN3_VRDACM3 + @nValDepr3) * @nTaxCor) - (@nN3_VRDACM1 + @nValDepr1 + @nN3_VRCDA1))
    End
    If @IN_MOEDAATF = '04' begin
        select @nValCor    = ( Abs(@nN3_VORIG4 + @nN3_AMPLIA4) * @nTaxCor) - Abs(@nN3_VRCACM1 + @nN3_VORIG1 + @nN3_AMPLIA1)
        select @nValCorDep = ( (Abs(@nN3_VRDACM4 + @nValDepr4) * @nTaxCor) - (@nN3_VRDACM1 + @nValDepr1 + @nN3_VRCDA1))
    End
    If @IN_MOEDAATF = '05' begin
        select @nValCor    = ( Abs(@nN3_VORIG5 + @nN3_AMPLIA5) * @nTaxCor) - Abs(@nN3_VRCACM1 + @nN3_VORIG1 + @nN3_AMPLIA1)
        select @nValCorDep = ( (Abs(@nN3_VRDACM5 + @nValDepr5) * @nTaxCor) - (@nN3_VRDACM1 + @nValDepr1 + @nN3_VRCDA1))
    End
    ##FIELDP02( 'SN3.N3_VORIG6' )
    If @IN_MOEDAATF = '06' begin
        select @nValCor    = ( Abs(@nN3_VORIG6 + @nN3_AMPLIA6) * @nTaxCor) - Abs(@nN3_VRCACM1 + @nN3_VORIG1 + @nN3_AMPLIA1)
        select @nValCorDep = ( (Abs(@nN3_VRDACM6 + @nValDepr6) * @nTaxCor) - (@nN3_VRDACM1 + @nValDepr1 + @nN3_VRCDA1))
    End
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG7' )
    If @IN_MOEDAATF = '07' begin
        select @nValCor    = ( Abs(@nN3_VORIG7 + @nN3_AMPLIA7) * @nTaxCor) - Abs(@nN3_VRCACM1 + @nN3_VORIG1 + @nN3_AMPLIA1)
        select @nValCorDep = ( (Abs(@nN3_VRDACM7 + @nValDepr7) * @nTaxCor) - (@nN3_VRDACM1 + @nValDepr1 + @nN3_VRCDA1))
    End
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG8' )
    If @IN_MOEDAATF = '08' begin
        select @nValCor    = ( Abs(@nN3_VORIG8 + @nN3_AMPLIA8) * @nTaxCor) - Abs(@nN3_VRCACM1 + @nN3_VORIG1 + @nN3_AMPLIA1)
        select @nValCorDep = ( (Abs(@nN3_VRDACM8 + @nValDepr8) * @nTaxCor) - (@nN3_VRDACM1 + @nValDepr1 + @nN3_VRCDA1))
    End
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG9' )
    If @IN_MOEDAATF = '09' begin
        select @nValCor    = ( Abs(@nN3_VORIG9 + @nN3_AMPLIA9) * @nTaxCor) - Abs(@nN3_VRCACM1 + @nN3_VORIG1 + @nN3_AMPLIA1)
        select @nValCorDep = ( (Abs(@nN3_VRDACM9 + @nValDepr9) * @nTaxCor) - (@nN3_VRDACM1 + @nValDepr1 + @nN3_VRCDA1))
    End
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG10' )
    If @IN_MOEDAATF = '10' begin
        select @nValCor    = ( Abs(@nN3_VORIG10 + @nN3_AMPLIA10) * @nTaxCor) - Abs(@nN3_VRCACM1 + @nN3_VORIG1 + @nN3_AMPLIA1)
        select @nValCorDep = ( (Abs(@nN3_VRDACM10 + @nValDepr10) * @nTaxCor) - (@nN3_VRDACM1 + @nValDepr1 + @nN3_VRCDA1))
    End
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG11' )
    If @IN_MOEDAATF = '11' begin
        select @nValCor    = ( Abs(@nN3_VORIG11 + @nN3_AMPLIA11) * @nTaxCor) - Abs(@nN3_VRCACM1 + @nN3_VORIG1 + @nN3_AMPLIA1)
        select @nValCorDep = ( (Abs(@nN3_VRDACM11 + @nValDepr11) * @nTaxCor) - (@nN3_VRDACM1 + @nValDepr1 + @nN3_VRCDA1))
    End
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG12' )
    If @IN_MOEDAATF = '12' begin
        select @nValCor    = ( Abs(@nN3_VORIG12 + @nN3_AMPLIA12) * @nTaxCor) - Abs(@nN3_VRCACM1 + @nN3_VORIG1 + @nN3_AMPLIA1)
        select @nValCorDep = ( (Abs(@nN3_VRDACM12 + @nValDepr12) * @nTaxCor) - (@nN3_VRDACM1 + @nValDepr1 + @nN3_VRCDA1))
    End
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG13' )
    If @IN_MOEDAATF = '13' begin
        select @nValCor    = ( Abs(@nN3_VORIG13 + @nN3_AMPLIA13) * @nTaxCor) - Abs(@nN3_VRCACM1 + @nN3_VORIG1 + @nN3_AMPLIA1)
        select @nValCorDep = ( (Abs(@nN3_VRDACM13 + @nValDepr13) * @nTaxCor) - (@nN3_VRDACM1 + @nValDepr1 + @nN3_VRCDA1))
    End
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG14' )
    If @IN_MOEDAATF = '14' begin
        select @nValCor    = ( Abs(@nN3_VORIG14 + @nN3_AMPLIA14) * @nTaxCor) - Abs(@nN3_VRCACM1 + @nN3_VORIG1 + @nN3_AMPLIA1)
        select @nValCorDep = ( (Abs(@nN3_VRDACM14 + @nValDepr14) * @nTaxCor) - (@nN3_VRDACM1 + @nValDepr1 + @nN3_VRCDA1))
    End
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG15' )
    If @IN_MOEDAATF = '15' begin
        select @nValCor    = ( Abs(@nN3_VORIG15 + @nN3_AMPLIA15) * @nTaxCor) - Abs(@nN3_VRCACM1 + @nN3_VORIG1 + @nN3_AMPLIA1)
        select @nValCorDep = ( (Abs(@nN3_VRDACM15 + @nValDepr15) * @nTaxCor) - (@nN3_VRDACM1 + @nValDepr1 + @nN3_VRCDA1))
    End
    ##ENDFIELDP11

    If @cN3_CCORREC = ' ' select @nValCor = 0
    If @cN3_CDESP = ' ' select @nValCorDep = 0
    End
   
    select @OUT_CORRECAO = @nValCor
    select @OUT_CORDEP   = @nValCorDep
   
End
