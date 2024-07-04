Create Procedure ATF007_## (
   @IN_CPAISLOC   Char( 03 ),
   @IN_MOEDAATF   Char( 02 ),
   @IN_LCORRECAO  Char( 01 ),
   @IN_VCORRECAO  Float,
   @IN_DATADEP    Char( 08 ),
   @IN_DATAQUIS   Char( 08 ),
   @IN_DATAINIDEP Char( 08 ),
   @IN_DATAF      Char( 08 ),
   @IN_LEYDL824   Char( 01 ),
   @IN_FILIAL     Char( 02 ),
   @IN_NRODIAS    Integer,
   @IN_TXDEPOK    Float,
   @IN_RECNO      Integer, 
   @OUT_TXMEDIA   Float OutPut,
   @OUT_CORRECAO  Float OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ATFA050.PRW </s>
    Descricao       - <d>  Calculo de Depreciação </d>
    Funcao do Siga  -      Atfa050()
    Entrada         - <ri> @IN_CPAISLOC   - Pais
                           @IN_MOEDAATF   - moeda do Ativo
                           @IN_LCORRECAO  - 1 correcao, 0 nao correcao
                           @IN_VCORRECAO  - vlr usado pra correcao
                           @IN_DATADEP    - Data de calculo da depreciacao
                           @IN_DATAQUIS   - Data de aquisicao do bem
                           @IN_DATAINIDEP - Data inicio a considerar como inicio de calculo
                           @IN_DATAF      - Data para o calculo
                           @IN_LEYDL824   - CHILE
                           @IN_FILIAL     - Filial
                           @IN_NRODIAS    - nro de dias a depreciar
                           @IN_TXDEPOK    - Mv_par05
                           @IN_RECNO      - Recno do SN3 </ri>
    Saida           - <o>  @OUT_TXMEDIA   - média da taxa das moedas
                           @OUT_CORRECAO  - Taxa de correcao a utilizar   </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     10/10/2006
-------------------------------------------------------------------------------------- */
Declare @nTaxCor     Float
Declare @cDataAux    Char( 08 )
Declare @nMoeda2     Float
Declare @nMoeda3     Float
Declare @nMoeda4     Float
Declare @nMoeda5     Float
Declare @cFilial_SNF Char( 02 )
Declare @cAux        Char( 03 )
Declare @cAnoMes     Char( 06 )
Declare @cMesCalc    Char( 02 )
Declare @nNF_PERCIPC Float
Declare @iRecnoSNF   Integer
Declare @iRecnoSM2   Integer
Declare @nTxMedia    Float
Declare @nTxMedia2   Float
Declare @nTxMedia3   Float
Declare @nTxMedia4   Float
Declare @nTxMedia5   Float
Declare @lCalcCor    Char( 01 )
##FIELDP02( 'SN3.N3_VORIG6' )
Declare @nMoeda6     Float
Declare @nTxMedia6   Float
##ENDFIELDP02
##FIELDP03( 'SN3.N3_VORIG7' )
Declare @nMoeda7     Float
Declare @nTxMedia7   Float
##ENDFIELDP03
##FIELDP04( 'SN3.N3_VORIG8' )
Declare @nMoeda8     Float
Declare @nTxMedia8   Float
##ENDFIELDP04
##FIELDP05( 'SN3.N3_VORIG9' )
Declare @nMoeda9     Float
Declare @nTxMedia9   Float
##ENDFIELDP05
##FIELDP06( 'SN3.N3_VORIG10' )
Declare @nMoeda10     Float
Declare @nTxMedia10   Float
##ENDFIELDP06
##FIELDP07( 'SN3.N3_VORIG11' )
Declare @nMoeda11     Float
Declare @nTxMedia11   Float
##ENDFIELDP07
##FIELDP08( 'SN3.N3_VORIG12' )
Declare @nMoeda12     Float
Declare @nTxMedia12   Float
##ENDFIELDP08
##FIELDP09( 'SN3.N3_VORIG13' )
Declare @nMoeda13     Float
Declare @nTxMedia13   Float
##ENDFIELDP09
##FIELDP10( 'SN3.N3_VORIG14' )
Declare @nMoeda14     Float
Declare @nTxMedia14   Float
##ENDFIELDP10
##FIELDP11( 'SN3.N3_VORIG15' )
Declare @nMoeda15     Float
Declare @nTxMedia15   Float
##ENDFIELDP11
begin
    Select @nTaxCor   = 0
    Select @nTxMedia  = 0
    Select @nTxMedia2 = 0
    Select @nTxMedia3 = 0
    Select @nTxMedia4 = 0
    Select @nTxMedia5 = 0
    Select @iRecnoSM2 = 0
    ##FIELDP02( 'SN3.N3_VORIG6' )
    Select @nTxMedia6   = 0
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG7' )
    Select @nTxMedia7   = 0
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG8' )
    Select @nTxMedia8   = 0
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG9' )
    Select @nTxMedia9   = 0
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG10' )
    Select @nTxMedia10   = 0
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG11' )
    Select @nTxMedia11   = 0
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG12' )
    Select @nTxMedia12   = 0
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG13' )
    Select @nTxMedia13   = 0
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG14' )
    Select @nTxMedia14   = 0
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG15' )
    Select @nTxMedia15   = 0
    ##ENDFIELDP11
   
    If ( @IN_LCORRECAO = '1'  and @IN_VCORRECAO > 0 ) select @lCalcCor = '1'
    else select @lCalcCor = '0'
    /* ----------------------------------------------------------------------------------
        1 - Calculo da @nTxMedia1,..,n 
        ---------------------------------------------------------------------------------- */
    If @lCalcCor = '1' or @IN_DATADEP <= '19951231' begin
        Select @nTxMedia2 = IsNull(Sum(M2_MOEDA2), 0 ), @nTxMedia3 = IsNull(Sum(M2_MOEDA3), 0),
                @nTxMedia4 = IsNull(Sum(M2_MOEDA4), 0) , @nTxMedia5 = IsNull(Sum(M2_MOEDA5), 0)
                ##FIELDP02( 'SN3.N3_VORIG6' )
                , @nTxMedia6 = IsNull(Sum(M2_MOEDA6), 0)
                ##ENDFIELDP02
                ##FIELDP03( 'SN3.N3_VORIG7' )
                , @nTxMedia7 = IsNull(Sum(M2_MOEDA7), 0)
                ##ENDFIELDP03
                ##FIELDP04( 'SN3.N3_VORIG8' )
                , @nTxMedia8 = IsNull(Sum(M2_MOEDA8), 0)
                ##ENDFIELDP04
                ##FIELDP05( 'SN3.N3_VORIG9' )
                , @nTxMedia9 = IsNull(Sum(M2_MOEDA9), 0)
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG10' )
                , @nTxMedia10 = IsNull(Sum(M2_MOEDA10), 0)
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG11' )
                , @nTxMedia11 = IsNull(Sum(M2_MOEDA11), 0)
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG12' )
                , @nTxMedia12 = IsNull(Sum(M2_MOEDA12), 0)
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG13' )
                , @nTxMedia13 = IsNull(Sum(M2_MOEDA13), 0)
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG14' )
                , @nTxMedia14 = IsNull(Sum(M2_MOEDA14), 0)
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG15' )
                , @nTxMedia15 = IsNull(Sum(M2_MOEDA15), 0)
                ##ENDFIELDP11
        From SM2###
        Where M2_DATA between @IN_DATAINIDEP AND @IN_DATAF
            and D_E_L_E_T_ = ' '
      
        Select @nTxMedia2 = @nTxMedia2 / @IN_NRODIAS
        Select @nTxMedia3 = @nTxMedia3 / @IN_NRODIAS
        Select @nTxMedia4 = @nTxMedia4 / @IN_NRODIAS
        Select @nTxMedia5 = @nTxMedia5 / @IN_NRODIAS
      
        If @IN_MOEDAATF = '02' select @nTxMedia = @nTxMedia2
        If @IN_MOEDAATF = '03' select @nTxMedia = @nTxMedia3
        If @IN_MOEDAATF = '04' select @nTxMedia = @nTxMedia4
        If @IN_MOEDAATF = '05' select @nTxMedia = @nTxMedia5
        ##FIELDP02( 'SN3.N3_VORIG6' )
        Select @nTxMedia6 = @nTxMedia6 / @IN_NRODIAS
        If @IN_MOEDAATF = '06' select @nTxMedia = @nTxMedia6
        ##ENDFIELDP02
        ##FIELDP03( 'SN3.N3_VORIG7' )
        Select @nTxMedia7 = @nTxMedia7 / @IN_NRODIAS
        If @IN_MOEDAATF = '07' select @nTxMedia = @nTxMedia7
        ##ENDFIELDP03
        ##FIELDP04( 'SN3.N3_VORIG8' )
        Select @nTxMedia8 = @nTxMedia8 / @IN_NRODIAS
        If @IN_MOEDAATF = '08' select @nTxMedia = @nTxMedia8
        ##ENDFIELDP04
        ##FIELDP05( 'SN3.N3_VORIG9' )
        Select @nTxMedia9 = @nTxMedia9 / @IN_NRODIAS
        If @IN_MOEDAATF = '09' select @nTxMedia = @nTxMedia9
        ##ENDFIELDP05
        ##FIELDP06( 'SN3.N3_VORIG10' )
        Select @nTxMedia10 = @nTxMedia10 / @IN_NRODIAS
        If @IN_MOEDAATF = '10' select @nTxMedia = @nTxMedia10
        ##ENDFIELDP06
        ##FIELDP07( 'SN3.N3_VORIG11' )
        Select @nTxMedia11 = @nTxMedia11 / @IN_NRODIAS
        If @IN_MOEDAATF = '11' select @nTxMedia = @nTxMedia11
        ##ENDFIELDP07
        ##FIELDP08( 'SN3.N3_VORIG12' )
        Select @nTxMedia12 = @nTxMedia12 / @IN_NRODIAS
        If @IN_MOEDAATF = '12' select @nTxMedia = @nTxMedia12
        ##ENDFIELDP08
        ##FIELDP09( 'SN3.N3_VORIG13' )
        Select @nTxMedia13 = @nTxMedia13 / @IN_NRODIAS
        If @IN_MOEDAATF = '13' select @nTxMedia = @nTxMedia13
        ##ENDFIELDP09
        ##FIELDP10( 'SN3.N3_VORIG14' )
        Select @nTxMedia14 = @nTxMedia14 / @IN_NRODIAS
        If @IN_MOEDAATF = '14' select @nTxMedia = @nTxMedia14
        ##ENDFIELDP10
        ##FIELDP11( 'SN3.N3_VORIG15' )
        Select @nTxMedia15 = @nTxMedia15 / @IN_NRODIAS
        If @IN_MOEDAATF = '15' select @nTxMedia = @nTxMedia15
        ##ENDFIELDP11
    end else begin
        select @nTxMedia = @IN_TXDEPOK
        If @IN_DATADEP >= '19960101' and @IN_DATADEP <= '19960630' begin
            select @nTxMedia = @IN_TXDEPOK
        End
        If @IN_DATADEP >= '19960701' begin
            Select @cDataAux = N3_AQUISIC
            From SN3###
            Where R_E_C_N_O_ = @IN_RECNO
         
            If @cDataAux > '19970701' begin
            Select @iRecnoSM2 = IsNull( R_E_C_N_O_, 0 )
                From SM2###
                Where M2_DATA = @cDataAux
                and D_E_L_E_T_ = ' '
            
                If @iRecnoSM2 > 0 begin
                    Select @nTxMedia2 = IsNull(Sum(M2_MOEDA2), 0 ), @nTxMedia3 = IsNull(Sum(M2_MOEDA3), 0),
                            @nTxMedia4 = IsNull(Sum(M2_MOEDA4), 0) , @nTxMedia5 = IsNull(Sum(M2_MOEDA5), 0)
                            ##FIELDP02( 'SN3.N3_VORIG6' )
                            , @nTxMedia6 = IsNull(Sum(M2_MOEDA6), 0)
                            ##ENDFIELDP02
                            ##FIELDP03( 'SN3.N3_VORIG7' )
                            , @nTxMedia7 = IsNull(Sum(M2_MOEDA7), 0)
                            ##ENDFIELDP03
                            ##FIELDP04( 'SN3.N3_VORIG8' )
                            , @nTxMedia8 = IsNull(Sum(M2_MOEDA8), 0)
                            ##ENDFIELDP04
                            ##FIELDP05( 'SN3.N3_VORIG9' )
                            , @nTxMedia9 = IsNull(Sum(M2_MOEDA9), 0)
                            ##ENDFIELDP05
                            ##FIELDP06( 'SN3.N3_VORIG10' )
                            , @nTxMedia10 = IsNull(Sum(M2_MOEDA10), 0)
                            ##ENDFIELDP06
                            ##FIELDP07( 'SN3.N3_VORIG11' )
                            , @nTxMedia11 = IsNull(Sum(M2_MOEDA11), 0)
                            ##ENDFIELDP07
                            ##FIELDP08( 'SN3.N3_VORIG12' )
                            , @nTxMedia12 = IsNull(Sum(M2_MOEDA12), 0)
                            ##ENDFIELDP08
                            ##FIELDP09( 'SN3.N3_VORIG13' )
                            , @nTxMedia13 = IsNull(Sum(M2_MOEDA13), 0)
                            ##ENDFIELDP09
                            ##FIELDP10( 'SN3.N3_VORIG14' )
                            , @nTxMedia14 = IsNull(Sum(M2_MOEDA14), 0)
                            ##ENDFIELDP10
                            ##FIELDP11( 'SN3.N3_VORIG15' )
                            , @nTxMedia15 = IsNull(Sum(M2_MOEDA15), 0)
                            ##ENDFIELDP11
                        From SM2###
                    Where R_E_C_N_O_= @iRecnoSM2
               
                    If @IN_MOEDAATF = '02' select @nTxMedia = @nTxMedia2
                    If @IN_MOEDAATF = '03' select @nTxMedia = @nTxMedia3
                    If @IN_MOEDAATF = '04' select @nTxMedia = @nTxMedia4
                    If @IN_MOEDAATF = '05' select @nTxMedia = @nTxMedia5
                    ##FIELDP02( 'SN3.N3_VORIG6' )
                    If @IN_MOEDAATF = '06' select @nTxMedia = @nTxMedia6
                    ##ENDFIELDP02
                    ##FIELDP03( 'SN3.N3_VORIG7' )
                    If @IN_MOEDAATF = '07' select @nTxMedia = @nTxMedia7
                    ##ENDFIELDP03
                    ##FIELDP04( 'SN3.N3_VORIG8' )
                    If @IN_MOEDAATF = '08' select @nTxMedia = @nTxMedia8
                    ##ENDFIELDP04
                    ##FIELDP05( 'SN3.N3_VORIG9' )
                    If @IN_MOEDAATF = '09' select @nTxMedia = @nTxMedia9
                    ##ENDFIELDP05
                    ##FIELDP06( 'SN3.N3_VORIG10' )
                    If @IN_MOEDAATF = '10' select @nTxMedia = @nTxMedia10
                    ##ENDFIELDP06
                    ##FIELDP07( 'SN3.N3_VORIG11' )
                    If @IN_MOEDAATF = '11' select @nTxMedia = @nTxMedia11
                    ##ENDFIELDP07
                    ##FIELDP08( 'SN3.N3_VORIG12' )
                    If @IN_MOEDAATF = '12' select @nTxMedia = @nTxMedia12
                    ##ENDFIELDP08
                    ##FIELDP09( 'SN3.N3_VORIG13' )
                    If @IN_MOEDAATF = '13' select @nTxMedia = @nTxMedia13
                    ##ENDFIELDP09
                    ##FIELDP10( 'SN3.N3_VORIG14' )
                    If @IN_MOEDAATF = '14' select @nTxMedia = @nTxMedia14
                    ##ENDFIELDP10
                    ##FIELDP11( 'SN3.N3_VORIG15' )
                    If @IN_MOEDAATF = '15' select @nTxMedia = @nTxMedia15
                    ##ENDFIELDP11
                end
            end
        end
    end
    /* ----------------------------------------------------------------------------------
        2 - Calculo da Tx de Correção - @nTaxCor
        ---------------------------------------------------------------------------------- */
    If @lCalcCor = '1' begin
        select @nTaxCor = @IN_VCORRECAO
    end else begin
        /* ----------------------------------------------------------------------------------
            Nas datas abaixo uso a taxa do ultimo dia do mes ( dia do calculo )
            ---------------------------------------------------------------------------------- */
        If @IN_DATADEP <= '19931231' or ( @IN_DATADEP >= '19940101' and @IN_DATADEP >= '19940731')  begin
            Select @nMoeda2 = IsNull(M2_MOEDA2, 0), @nMoeda3 = IsNull(M2_MOEDA3, 0), @nMoeda4 = IsNull(M2_MOEDA4, 0), @nMoeda5 = IsNull(M2_MOEDA5, 0)
                            ##FIELDP02( 'SN3.N3_VORIG6' )
                            , @nMoeda6  = IsNull(M2_MOEDA6, 0)
                            ##ENDFIELDP02
                            ##FIELDP03( 'SN3.N3_VORIG7' )
                            , @nMoeda7 = IsNull(M2_MOEDA7, 0)
                            ##ENDFIELDP03
                            ##FIELDP04( 'SN3.N3_VORIG8' )
                            , @nMoeda8 = IsNull(M2_MOEDA8, 0)
                            ##ENDFIELDP04
                            ##FIELDP05( 'SN3.N3_VORIG9' )
                            , @nMoeda9 = IsNull(M2_MOEDA9, 0)
                            ##ENDFIELDP05
                            ##FIELDP06( 'SN3.N3_VORIG10' )
                            , @nMoeda10 = IsNull(M2_MOEDA10, 0)
                            ##ENDFIELDP06
                            ##FIELDP07( 'SN3.N3_VORIG11' )
                            , @nMoeda11 = IsNull(M2_MOEDA11, 0)
                            ##ENDFIELDP07
                            ##FIELDP08( 'SN3.N3_VORIG12' )
                            , @nMoeda12 = IsNull(M2_MOEDA12, 0)
                            ##ENDFIELDP08
                            ##FIELDP09( 'SN3.N3_VORIG13' )
                            , @nMoeda13 = IsNull(M2_MOEDA13, 0)
                            ##ENDFIELDP09
                            ##FIELDP10( 'SN3.N3_VORIG14' )
                            , @nMoeda14 = IsNull(M2_MOEDA14, 0)
                            ##ENDFIELDP10
                            ##FIELDP11( 'SN3.N3_VORIG15' )
                            , @nMoeda15 = IsNull(M2_MOEDA15, 0)
                            ##ENDFIELDP11
            From SM2###
            where M2_DATA = @IN_DATADEP
            and D_E_L_E_T_ = ' '         
        end
        /* ----------------------------------------------------------------------------------
            Nas datas abaixo uso a taxa do 1ro dia do mes seguinte
            ---------------------------------------------------------------------------------- */
        If ( @IN_DATADEP >= '19940801' and @IN_DATADEP >= '19941231') or  @IN_DATADEP = '19950331' or
            @IN_DATADEP = '19950630' or  @IN_DATADEP = '19950930'  or  @IN_DATADEP = '19951231' begin 
         
	        /* ----------------------------------------------------------------------------------
            Tratamento para o OpenEdge
		    --------------------------------------------------------------------------------- */
            ##IF_001({|| AllTrim(Upper(TcGetDB())) <> "OPENEDGE" })
		    select @cDataAux = Convert( Char( 08 ), dateadd( day, 1, @IN_DATADEP ), 112)
		    ##ELSE_001
		    EXEC MSDATEADD 'DAY', 1, @IN_DATADEP, @cDataAux OutPut
		    ##ENDIF_001
        
            Select @nMoeda2 = IsNull(M2_MOEDA2, 0), @nMoeda3 = IsNull(M2_MOEDA3, 0), @nMoeda4 = IsNull(M2_MOEDA4, 0), @nMoeda5 = IsNull(M2_MOEDA5, 0)
                            ##FIELDP02( 'SN3.N3_VORIG6' )
                            , @nMoeda6  = IsNull(M2_MOEDA6, 0)
                            ##ENDFIELDP02
                            ##FIELDP03( 'SN3.N3_VORIG7' )
                            , @nMoeda7 = IsNull(M2_MOEDA7, 0)
                            ##ENDFIELDP03
                            ##FIELDP04( 'SN3.N3_VORIG8' )
                            , @nMoeda8 = IsNull(M2_MOEDA8, 0)
                            ##ENDFIELDP04
                            ##FIELDP05( 'SN3.N3_VORIG9' )
                            , @nMoeda9 = IsNull(M2_MOEDA9, 0)
                            ##ENDFIELDP05
                            ##FIELDP06( 'SN3.N3_VORIG10' )
                            , @nMoeda10 = IsNull(M2_MOEDA10, 0)
                            ##ENDFIELDP06
                            ##FIELDP07( 'SN3.N3_VORIG11' )
                            , @nMoeda11 = IsNull(M2_MOEDA11, 0)
                            ##ENDFIELDP07
                            ##FIELDP08( 'SN3.N3_VORIG12' )
                            , @nMoeda12 = IsNull(M2_MOEDA12, 0)
                            ##ENDFIELDP08
                            ##FIELDP09( 'SN3.N3_VORIG13' )
                            , @nMoeda13 = IsNull(M2_MOEDA13, 0)
                            ##ENDFIELDP09
                            ##FIELDP10( 'SN3.N3_VORIG14' )
                            , @nMoeda14 = IsNull(M2_MOEDA14, 0)
                            ##ENDFIELDP10
                            ##FIELDP11( 'SN3.N3_VORIG15' )
                            , @nMoeda15 = IsNull(M2_MOEDA15, 0)
                            ##ENDFIELDP11            
            From SM2###
            where M2_DATA = @cDataAux
            and D_E_L_E_T_ = ' '
         
        End
        If @IN_MOEDAATF = '02' select @nTaxCor = @nMoeda2
        If @IN_MOEDAATF = '03' select @nTaxCor = @nMoeda3
        If @IN_MOEDAATF = '04' select @nTaxCor = @nMoeda4
        If @IN_MOEDAATF = '05' select @nTaxCor = @nMoeda5
        ##FIELDP02( 'SN3.N3_VORIG6' )
        If @IN_MOEDAATF = '06' select @nTaxCor = @nTxMedia6
        ##ENDFIELDP02
        ##FIELDP03( 'SN3.N3_VORIG7' )
        If @IN_MOEDAATF = '07' select @nTaxCor = @nTxMedia7
        ##ENDFIELDP03
        ##FIELDP04( 'SN3.N3_VORIG8' )
        If @IN_MOEDAATF = '08' select @nTaxCor = @nTxMedia8
        ##ENDFIELDP04
        ##FIELDP05( 'SN3.N3_VORIG9' )
        If @IN_MOEDAATF = '09' select @nTaxCor = @nTxMedia9
        ##ENDFIELDP05
        ##FIELDP06( 'SN3.N3_VORIG10' )
        If @IN_MOEDAATF = '10' select @nTaxCor = @nTxMedia10
        ##ENDFIELDP06
        ##FIELDP07( 'SN3.N3_VORIG11' )
        If @IN_MOEDAATF = '11' select @nTaxCor = @nTxMedia11
        ##ENDFIELDP07
        ##FIELDP08( 'SN3.N3_VORIG12' )
        If @IN_MOEDAATF = '12' select @nTaxCor = @nTxMedia12
        ##ENDFIELDP08
        ##FIELDP09( 'SN3.N3_VORIG13' )
        If @IN_MOEDAATF = '13' select @nTaxCor = @nTxMedia13
        ##ENDFIELDP09
        ##FIELDP10( 'SN3.N3_VORIG14' )
        If @IN_MOEDAATF = '14' select @nTaxCor = @nTxMedia14
        ##ENDFIELDP10
        ##FIELDP11( 'SN3.N3_VORIG15' )
        If @IN_MOEDAATF = '15' select @nTaxCor = @nTxMedia15
        ##ENDFIELDP11
    end
   
    ##FIELDP01( 'SNF.NF_FILIAL;NF_AMAQUIS;NF_MCALC;NF_PERCIPC' )
    If @IN_LEYDL824 = '1' begin
        Select @iRecnoSNF = 0
        Select @nTaxCor = 0
      
        If SubString( @IN_DATADEP, 1, 6 ) >= SubString( @IN_DATAQUIS, 1, 6 ) begin
            Select @cAux = 'SNF'
            exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_SNF OutPut
            Select @cMesCalc = SubString( @IN_DATADEP, 7, 2 )
         
            If SubString( @IN_DATAQUIS, 1, 4 ) < Substring ( @IN_DATADEP, 1, 4 ) begin
            select @cAnoMes  = SubString( @IN_DATADEP, 1, 4 )||'00'
            
            Select @nNF_PERCIPC = NF_PERCIPC, @iRecnoSNF = IsNull( R_E_C_N_O_, 0)
                From SNF###
                Where NF_FILIAL  = @cFilial_SNF
                and NF_AMAQUIS = @cAnoMes
                and NF_MCALC   = @cMesCalc
                and D_E_L_E_T_ = ' '
            end else begin
            select @cAnoMes  = SubString( @IN_DATAQUIS, 1, 6 )
            
            Select @nNF_PERCIPC = NF_PERCIPC, @iRecnoSNF = IsNull( R_E_C_N_O_, 0)
                From SNF###
                Where NF_FILIAL  = @cFilial_SNF
                and NF_AMAQUIS = @cAnoMes
                and NF_MCALC   = @cMesCalc
                and D_E_L_E_T_ = ' '
            end
            If ((SubString( @IN_DATADEP, 1, 6 ) > SubString( @IN_DATAQUIS, 1, 6 )) and ( @iRecnoSNF > 0 ))  Select @nTaxCor = @nNF_PERCIPC / 100
        End
    End
    ##ENDFIELDP01
    select @OUT_TXMEDIA  = @nTxMedia
    select @OUT_CORRECAO = @nTaxCor
End
