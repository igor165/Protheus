Create Procedure ATF001_##
(  @IN_FILIAL     Char( 'N3_FILIAL' ),
   @IN_FILIALATE  Char( 'N3_FILIAL' ),
   @IN_LCUSTO     Char( 01 ),
   @IN_LITEM      Char( 01 ),
   @IN_LCLVL      Char( 01 ),
   @IN_DATADEP    Char( 08 ),
   @IN_LMESCHEIO  Char( 01 ),          -- 1 MES CHEIO 0 proporcional
   @IN_CPAISLOC   Char( 03 ),
   @IN_LFUNDADA   Char( 01 ),
   @IN_MOEDAATF   Char( 02 ), 
   @IN_LCORRECAO  Char( 01 ),
   @IN_VCORRECAO  Float,
   @IN_LEYDL824   Char( 01 ),
   @IN_TXDEPOK    Float,
   @IN_ATFMBLQ    Char( 01 ),
   @IN_CALCDEP    Char( 01 ),
   @IN_ATFMDMX    Char( 02 ), 
   @IN_IDMOV      Char( 10 ),
   @IN_CASAS1     Char( 02 ),
   @IN_CASAS2     Char( 02 ),
   @IN_CASAS3     Char( 02 ),
   @IN_CASAS4     Char( 02 ),
   @IN_CASAS5     Char( 02 ),
   @IN_CASASN     Char(200),
   @IN_MOEDAMAX   Integer , 
   @IN_LATFCTAP   Char(01) , 
   @OUT_RESULTADO Char( 01 ) OutPut )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  012 </a>
    Fonte Microsiga - <s>  ATFA050.PRW </s>
    Descricao       - <d>  Calculo de Depreciação </d>
    Funcao do Siga  -      Atfa050()
    Entrada         - <ri> @IN_FILIAL     - Filial De
                           @IN_FILIALATE  - Filial ate
                           @IN_LCUSTO     - 1, CCusto em uso
                           @IN_LITEM      - 1, Item em uso
                           @IN_LCLVL      - 1, Clvl em uso
                           @IN_DATADEP    - Data de Calculo da depreciacao
                           @IN_LMESCHEIO  - 1, considera mes cheio, 0 proprocional, 2 ( RIPASA )- nao calcula depr na baixa
                           @IN_CPAISLOC   - Pais
                           @IN_LFUNDADA   -
                           @IN_MOEDAATF   - Moeda do Ativo
                           @IN_LCORRECAO  - 1 e @IN_VCORRECAO > 0,S faz a correcao
                           @IN_VCORRECAO  - Valor da taxa a considerar na correcao
                           @IN_LEYDL824   - CHILE
                           @IN_TXDEPOK    - mv_par05
                           @IN_ATFMBLQ    - '0' bloqueio total, '1' - Proporcial ao restante do mes 
                           @IN_CALCDEP    - '0' Calc de Depreciacao Mensal, '1' - calc de depreciacao anual
                           @IN_ATFMDMX    - Define a moeda de referencia para o valor limite de depreciação N3_TPDEPR = '7' </ri>
                           @IN_IDMOV      - XXX_IDMOV para gravar o SN4
                           @IN_CASAS1     - Numero de casa decimais na moeda 1
                           @IN_CASAS2     - Numero de casa decimais na moeda 2
                           @IN_CASAS3     - Numero de casa decimais na moeda 3
                           @IN_CASAS4     - Numero de casa decimais na moeda 4
                           @IN_CASAS5     - Numero de casa decimais na moeda 5
                           @IN_CASASN     - String com os nros de casas decimais das moedas de 6 a @IN_MOEDAMAX, se não tiver moeda adicionais deve receber um espaço em branco ' ',
                                                       o conteúdo deve vir dessa forma '02040202040404'
                                                        @IN_CASASN -> '020204060899'
                                                                                    |  |   |   |  |   |---> Moeda 11 - 99 ---> 99 casas decimais
                                                                                    |  |   |   |  |-------> Moeda 10 - 08 ---> 08 casas decimais
                                                                                    |  |   |   |----------> Moeda 09 - 06 ---> 06 casas decimais
                                                                                    |  |   |--------------> Moeda 08 - 04 ---> 04 casas decimais
                                                                                    |  |-----------------> Moeda 07 - 02 ---> 02 casas decimais
                                                                                    |--------------------> Moeda 06 - 02 ---> 02 casas decimais
                           @IN_MOEDAMAX  - ultima moeda de cálculo - até 15 moedas - Se for 0 NÂO tem moedas adicionais
                            </ri>
    Saida           - <o>  @OUT_RESULTADO - 1 - ok </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     01/09/2006
    
    ATF001 - Calculo de depreciacao - Atfa050
       +--> ATF011 - chamada de procedures - ( Quebra devido ao DB2/400)
       |       +--> ATF002 - Retorna a taxa de depreciacao Mensal - TODOS OS PAISES
       |       +--> ATF006 - calculo das depreciacoes nas moedas 1,.., 5
       |                 +-->  ATF015  - Calc das depreciações nas moedas 1...até  15 para TpDepr 'A' ( Quebra de fonte- informix aceita até 35000 caractres)
       |       +--> ATF007 - Retorna a Taxa de correcao - TODOS OS PAISES
       |       +--> ATF008 - Calculo das correcoes das Depreciacoes e do Bem 
       |--> ATF014  - Grava data da fim de depreciação - N3_FIMDEPR
       |--> ATF012  - Chama as atualizacao do SN4
       |       +--> ATF003 - Gera linha de movimentos no SN4
       |--> ATF013  - Chama a Atualizacao do SN5
       |       +--> ATF004 - Gera linhas de SALDOS no SN5   
   Pontos de entrada
      ATF001 - AF050FPR
             - A30EMBRA
             - AF050CAL
      ATF004 - ATFCONTA
             - ATFSINAL
             - ATFTIPO
             - ATFGRSLD
-------------------------------------------------------------------------------------- */
Declare @cFilial     Char( 'N3_FILIAL' )
Declare @cFilial_SN1 Char( 'N1_FILIAL' )
Declare @cFilial_SN3 Char( 'N3_FILIAL' )
Declare @cFilial_SN4 Char( 'N4_FILIAL' )
Declare @cFilial_SNG Char( 'N4_FILIAL' )
Declare @cDataIniDep Char( 08 )
Declare @cN1_GRUPO   Char( 'N1_GRUPO' )
Declare @iRecnoSN1   Integer
Declare @cN3_CBASE   Char( 'N3_CBASE' )
Declare @cN3_ITEM    Char( 'N3_ITEM' )
Declare @cN3_TIPO    Char( 'N3_TIPO' )
Declare @cN3_SEQ     Char( 'N3_SEQ' )
Declare @cN3_TPDEPR  Char( 01 )
Declare @cN3_BAIXA   Char( 01 )
Declare @nN3_VRDACM1 Float
Declare @nN3_VORIG1  Float
Declare @nN3_VORIG2  Float
Declare @nN3_VORIG3  Float
Declare @nN3_VORIG4  Float
Declare @nN3_VORIG5  Float
Declare @nN3_TXDEPR1 Float
Declare @nN3_TXDEPR2 Float
Declare @nN3_TXDEPR3 Float
Declare @nN3_TXDEPR4 Float
Declare @nN3_TXDEPR5 Float
Declare @nN3_VRCDA1  Float
Declare @cN3_DTBAIXA Char( 08 )
Declare @cN3_AQUISIC Char( 08 )
Declare @cN3_DINDEPR Char( 08 )
Declare @cN3_CCONTAB Char( 'N3_CCONTAB' )
Declare @cN3_DEPREC  Char( 'N3_DEPREC' )
Declare @cN3_CCORREC Char( 'N3_CCORREC' )
Declare @cN3_CCCORR  Char( 'N3_CCCORR' )
Declare @cN3_SUBCCOR Char( 'N3_SUBCCOR' )
Declare @cN3_CCCDEP  Char( 'N3_CCCDEP' )
Declare @cN3_SUBCCDE Char( 'N3_SUBCCDE' )
Declare @cN3_CDEPREC Char( 'N3_CDEPREC' )
Declare @cN3_SUBCDEP Char( 'N3_SUBCDEP' )
Declare @cN3_CCCDES  Char( 'N3_CCCDES' )
Declare @cN3_SUBCDES Char( 'N3_SUBCDES' )
Declare @cN3_CLVLCON Char( 'N3_CLVLCON' )
Declare @cN3_CUSTBEM Char( 'N3_CUSTBEM' )
Declare @cN3_CLVLDEP Char( 'N3_CLVLDEP' )
Declare @cN3_CCDESP  Char( 'N3_CCDESP' )
Declare @cN3_CCDEPR  Char( 'N3_CCDEPR' )
Declare @cN3_CLVLCDE Char( 'N3_CLVLCDE' )
Declare @cN3_CDESP   Char( 'N3_CDESP' )
declare @cN3_CLVLDES Char( 'N3_CLVLDES' )
Declare @cN3_SUBCTA  Char( 'N3_SUBCTA' )
Declare @cN3_CLVL    Char( 'N3_CLVL' )
Declare @cN3_SUBCCON Char( 'N3_SUBCCON' )
Declare @cN3_CLVLCOR Char( 'N3_CLVLCOR' )
Declare @cN3_FIMDEPR Char( 08 )
Declare @cN3_FIMDEPR_07 Char( 08 )
Declare @cN3_NOVO    Char( 01 )
Declare @iRecnoSN3   Integer
Declare @nN3_PRODMES Float
Declare @nN3_PRODANC Float
Declare @nN3_YTD     Integer
Declare @cAux        VarChar( 03 )
Declare @lCalcCor    Char( 01 )
Declare @nTxMedia    Float
Declare @iRecnoSNG   Integer
Declare @nValDepr1   Float
Declare @nValDepr2   Float
Declare @nValDepr3   Float
Declare @nValDepr4   Float
Declare @nValDepr5   Float
Declare @nValCor     Float
Declare @nValCorDep  Float
Declare @nValorOrig  Float
Declare @nValorAcum  Float
Declare @nVORIG1     Float
Declare @nVORIG2     Float
Declare @nVORIG3     Float
Declare @nVORIG4     Float
Declare @nVORIG5     Float
Declare @nVRDACM1    Float
Declare @nVRDACM2    Float
Declare @nVRDACM3    Float
Declare @nVRDACM4    Float
Declare @nVRDACM5    Float
Declare @nVRCACM1    Float
Declare @nVRCDA1     Float
Declare @cFIMDEPR    char( 08 )
Declare @cHistor     Char( 'N3_HISTOR' )
Declare @cN3_SEQREAV Char( 'N3_SEQREAV' )
Declare @cN3_CCUSTO  Char( 'N3_CCUSTO' )
Declare @iSeq        integer
Declare @iAux        integer
Declare @nAMPLIA1    Float
Declare @nAMPLIA2    Float
Declare @nAMPLIA3    Float 
Declare @nAMPLIA4    Float
Declare @nAMPLIA5    Float
Declare @nTxDep      float
Declare @iRecnoAux   Integer
Declare @nVRDACM1_TP01 Float
Declare @nVRCDA1_TP01  Float
Declare @nVORIG1_TP01  Float
Declare @nVRCACM1_TP01 Float
Declare @iRecnoSN3_TP09 Integer
Declare @cN3_DTACELE  Char( 08 )
Declare @nN3_VLACEL1  Float
Declare @nN3_VLACEL2  Float
Declare @nN3_VLACEL3  Float
Declare @nN3_VLACEL4  Float
Declare @nN3_VLACEL5  Float
Declare @lAcelera     char( 01 )  --Verifica se calcula aceleracao
Declare @cCalcula     char( 01 ) 
Declare @cN3_TIPOAux  Char( 'N3_TIPO' )
Declare @nVRDACM1Tp07 Float
Declare @nVRDACM2Tp07 Float
Declare @nVRDACM3Tp07 Float
Declare @nVRDACM4Tp07 Float
Declare @nVRDACM5Tp07 Float
Declare @nVRCDA1Tp07  Float
Declare @iRecnoTp07   Integer
Declare @nValor1      Float
Declare @nValor2      Float
Declare @nValor3      Float
Declare @nValor4      Float
Declare @nValor5      Float
Declare @nValorX      Float
Declare @cCasas1      Varchar(4)
Declare @cCasas2      Varchar(4)
Declare @cCasas3      Varchar(4)
Declare @cCasas4      Varchar(4)
Declare @cCasas5      Varchar(4)
Declare @nCasas1      Integer
Declare @nCasas2      Integer
Declare @nCasas3      Integer
Declare @nCasas4      Integer
Declare @nCasas5      Integer
Declare @nCasasAtf    Integer
Declare @iN3_PERDEPR  Integer
Declare @nN3_PRODANO  Float
Declare @nN3_VMXDEPR  Float
Declare @nN3_VLSALV1  Float
Declare @cN3_TPSALDO  char( 01 )
Declare @cN1_TPBEM    Char( 04 )
Declare @cNX_TPBEM    Char( 02 )
Declare @cN3_CODIND   Char( 08 )
##FIELDP17( 'SN1.N1_CALCPIS' )
Declare @cN1_CALCPIS  Char( 'N1_CALCPIS' )
##ENDFIELDP17
##FIELDP18( 'SN3.N3_VORIG6' )
Declare @nN3_VORIG6   Float
Declare @nN3_TXDEPR6 Float
Declare @nValDepr6        Float
Declare @nVORIG6         Float
Declare @nVRDACM6     Float
Declare @nAMPLIA6       Float
Declare @nN3_VLACEL6 Float
Declare @nValor6            Float
Declare @cCasas6          Varchar(4)
Declare @nCasas6          Integer
Declare @nVRDACM6Tp07 Float
##ENDFIELDP18
##FIELDP19( 'SN3.N3_VORIG7' )
Declare @nN3_VORIG7  Float
Declare @nN3_TXDEPR7 Float
Declare @nValDepr7        Float
Declare @nVORIG7         Float
Declare @nVRDACM7     Float
Declare @nAMPLIA7       Float
Declare @nN3_VLACEL7 Float
Declare @nValor7            Float
Declare @cCasas7          Varchar(4)
Declare @nCasas7          Integer
Declare @nVRDACM7Tp07 Float
##ENDFIELDP19
##FIELDP20( 'SN3.N3_VORIG8' )
Declare @nN3_VORIG8   Float
Declare @nN3_TXDEPR8 Float
Declare @nValDepr8        Float
Declare @nVORIG8         Float
Declare @nVRDACM8     Float
Declare @nAMPLIA8       Float
Declare @nN3_VLACEL8 Float
Declare @nValor8            Float
Declare @cCasas8          Varchar(4)
Declare @nCasas8          Integer
Declare @nVRDACM8Tp07 Float
##ENDFIELDP20
##FIELDP21( 'SN3.N3_VORIG9' )
Declare @nN3_VORIG9   Float
Declare @nN3_TXDEPR9 Float
Declare @nValDepr9        Float
Declare @nVORIG9         Float
Declare @nVRDACM9     Float
Declare @nAMPLIA9       Float
Declare @nN3_VLACEL9 Float
Declare @nValor9            Float
Declare @cCasas9          Varchar(4)
Declare @nCasas9          Integer
Declare @nVRDACM9Tp07 Float
##ENDFIELDP21
##FIELDP22( 'SN3.N3_VORIG10' )
Declare @nN3_VORIG10 Float
Declare @nN3_TXDEPR10 Float
Declare @nValDepr10      Float
Declare @nVORIG10         Float
Declare @nVRDACM10     Float
Declare @nAMPLIA10       Float
Declare @nN3_VLACEL10 Float
Declare @nValor10            Float
Declare @cCasas10          Varchar(4)
Declare @nCasas10          Integer
Declare @nVRDACM10Tp07 Float
##ENDFIELDP22
##FIELDP23( 'SN3.N3_VORIG11' )
Declare @nN3_VORIG11   Float
Declare @nN3_TXDEPR11 Float
Declare @nValDepr11        Float
Declare @nVORIG11         Float
Declare @nVRDACM11     Float
Declare @nAMPLIA11       Float
Declare @nN3_VLACEL11 Float
Declare @nValor11            Float
Declare @cCasas11          Varchar(4)
Declare @nCasas11          Integer
Declare @nVRDACM11Tp07 Float
##ENDFIELDP23
##FIELDP24( 'SN3.N3_VORIG12' )
Declare @nN3_VORIG12   Float
Declare @nN3_TXDEPR12 Float
Declare @nValDepr12       Float
Declare @nVORIG12         Float
Declare @nVRDACM12     Float
Declare @nAMPLIA12       Float
Declare @nN3_VLACEL12 Float
Declare @nValor12            Float
Declare @cCasas12          Varchar(4)
Declare @nCasas12          Integer
Declare @nVRDACM12Tp07 Float
##ENDFIELDP24
##FIELDP25( 'SN3.N3_VORIG13' )
Declare @nN3_VORIG13   Float
Declare @nN3_TXDEPR13 Float
Declare @nValDepr13        Float
Declare @nVORIG13         Float
Declare @nVRDACM13     Float
Declare @nAMPLIA13       Float
Declare @nN3_VLACEL13 Float
Declare @nValor13            Float
Declare @cCasas13          Varchar(4)
Declare @nCasas13          Integer
Declare @nVRDACM13Tp07 Float
##ENDFIELDP25
##FIELDP26( 'SN3.N3_VORIG14' )
Declare @nN3_VORIG14   Float
Declare @nN3_TXDEPR14  Float
Declare @nValDepr14         Float
Declare @nVORIG14          Float
Declare @nVRDACM14      Float
Declare @nAMPLIA14        Float
Declare @nN3_VLACEL14  Float
Declare @nValor14             Float
Declare @cCasas14           Varchar(4)
Declare @nCasas14           Integer
Declare @nVRDACM14Tp07 Float
##ENDFIELDP26

##FIELDP27( 'SN3.N3_VORIG15' )
Declare @nN3_VORIG15   Float
Declare @nN3_TXDEPR15 Float
Declare @nValDepr15        Float
Declare @nVORIG15         Float
Declare @nVRDACM15     Float
Declare @nAMPLIA15       Float
Declare @nN3_VLACEL15 Float
Declare @nValor15            Float
Declare @cCasas15          Varchar(4)
Declare @nCasas15          Integer
Declare @nVRDACM15Tp07 Float
##ENDFIELDP27
##FIELDP28( 'SN1.N1_BLQDEPR' )
Declare @cN1_BLQDEPR Char('N1_BLQDEPR')
##ENDFIELDP28
begin
   
    Select @nCasas1 = 0, @nCasas2 = 0, @nCasas3 = 0, @nCasas4 = 0, @nCasas5 = 0, @nCasasAtf = 0  -- casas decimais para gravacao nas respectivas moedas
    Select @cCasas1 = '2', @cCasas2 = '2', @cCasas3 = '2', @cCasas4 = '2', @cCasas5 = '2'  -- casas decimais para gravacao nas respectivas moedas   
    Select @iN3_PERDEPR = 0, @nN3_PRODMES = 0, @nN3_PRODANO = 0, @nN3_VMXDEPR = 0, @nN3_VLSALV1 = 0, @nN3_VRDACM1 = 0, @nVRDACM2 = 0,@nVRDACM3 = 0,@nVRDACM4 = 0,@nVRDACM5 = 0,@nVRCACM1 = 0,@cN3_TPSALDO = ' '
    ##FIELDP17( 'SN1.N1_CALCPIS' )
    , @cN1_CALCPIS = ' '
    ##ENDFIELDP17
    Select @cN1_TPBEM = ' ', @cNX_TPBEM = ' '
    Select @cN3_CODIND = ' '
    Select @cCasas1 = @IN_CASAS1, @cCasas2 = @IN_CASAS2, @cCasas3 = @IN_CASAS3, @cCasas4 = @IN_CASAS4, @cCasas5 = @IN_CASAS5 
    select @nCasas1 = Convert(integer, @cCasas1), @nCasas2 = Convert(integer, @cCasas2), @nCasas3 = Convert(integer, @cCasas3), @nCasas4 = Convert(integer, @cCasas4), @nCasas5 = Convert(integer, @cCasas5)
    ##FIELDP18( 'SN3.N3_VORIG6' )
    select @nN3_VORIG6   = 0
    select @nN3_TXDEPR6 = 0
    select @nValDepr6        = 0
    select @nVORIG6         = 0
    select @nVRDACM6     = 0
    select @nAMPLIA6       = 0
    select @nN3_VLACEL6 = 0
    select @nValor6            = 0
    select @cCasas6          = Substring(@IN_CASASN, 1, 2 )
    select @nCasas6          = Convert(integer, @cCasas6)
    select @nVRDACM6Tp07 = 0
    ##ENDFIELDP18
    ##FIELDP19( 'SN3.N3_VORIG7' )
    select @nN3_VORIG7   = 0
    select @nN3_TXDEPR7 = 0
    select @nValDepr7        = 0
    select @nVORIG7         = 0
    select @nVRDACM7     = 0
    select @nAMPLIA7       = 0
    select @nN3_VLACEL7 = 0
    select @nValor7            = 0
    select @cCasas7          = Substring(@IN_CASASN, 3, 2 )
    select @nCasas7          = Convert(integer, @cCasas7)
    select @nVRDACM7Tp07 = 0
    ##ENDFIELDP19
    ##FIELDP20( 'SN3.N3_VORIG8' )
    select @nN3_VORIG8   = 0
    select @nN3_TXDEPR8 = 0
    select @nValDepr8        = 0
    select @nVORIG8         = 0
    select @nVRDACM8     = 0
    select @nAMPLIA8       = 0
    select @nN3_VLACEL8 = 0
    select @nValor8            = 0
    select @cCasas8          = Substring( @IN_CASASN, 5, 2 )
    select @nCasas8         = Convert(integer, @cCasas8)
    select @nVRDACM8Tp07 = 0
    ##ENDFIELDP20
    ##FIELDP21( 'SN3.N3_VORIG9' )
    select @nN3_VORIG9   = 0
    select @nN3_TXDEPR9 = 0
    select @nValDepr9        = 0
    select @nVORIG9         = 0
    select @nVRDACM9     = 0
    select @nAMPLIA9       = 0
    select @nN3_VLACEL9 = 0
    select @nValor9            = 0
    select @cCasas9          = Substring(@IN_CASASN, 7, 2 )
    select @nCasas9          = Convert(integer, @cCasas9)
    select @nVRDACM9Tp07 = 0
    ##ENDFIELDP21
    ##FIELDP22( 'SN3.N3_VORIG10' )
    select @nN3_VORIG10   = 0
    select @nN3_TXDEPR10 = 0
    select @nValDepr10        = 0
    select @nVORIG10         = 0
    select @nVRDACM10     = 0
    select @nAMPLIA10       = 0
    select @nN3_VLACEL10 = 0
    select @nValor10            = 0
    select @cCasas10          = Substring(@IN_CASASN, 9, 2 )
    select @nCasas10          = Convert(integer, @cCasas10)
    select @nVRDACM10Tp07 = 0
    ##ENDFIELDP22    
    ##FIELDP23( 'SN3.N3_VORIG11' )
    select @nN3_VORIG11   = 0
    select @nN3_TXDEPR11 = 0
    select @nValDepr11        = 0
    select @nVORIG11         = 0
    select @nVRDACM11     = 0
    select @nAMPLIA11       = 0
    select @nN3_VLACEL11 = 0
    select @nValor11            = 0
    select @cCasas11          = Substring(@IN_CASASN, 11, 2 )
    select @nCasas11          = Convert(integer, @cCasas11)
    select @nVRDACM11Tp07 = 0
    ##ENDFIELDP23    
    ##FIELDP24( 'SN3.N3_VORIG12' )
    select @nN3_VORIG12   = 0
    select @nN3_TXDEPR12 = 0
    select @nValDepr12        = 0
    select @nVORIG12         = 0
    select @nVRDACM12     = 0
    select @nAMPLIA12       = 0
    select @nN3_VLACEL12 = 0
    select @nValor12            = 0
    select @cCasas12          = Substring(@IN_CASASN, 13, 2 )
    select @nCasas12          = Convert(integer, @cCasas12)
    select @nVRDACM12Tp07 = 0
    ##ENDFIELDP24    
    ##FIELDP25( 'SN3.N3_VORIG13' )
    select @nN3_VORIG13   = 0
    select @nN3_TXDEPR13 = 0
    select @nValDepr13        = 0
    select @nVORIG13         = 0
    select @nVRDACM13     = 0
    select @nAMPLIA13       = 0
    select @nN3_VLACEL13 = 0
    select @nValor13            = 0
    select @cCasas13          = Substring(@IN_CASASN, 15, 2 )
    select @nCasas13          = Convert(integer, @cCasas13)
    select @nVRDACM13Tp07 = 0
    ##ENDFIELDP25    
    ##FIELDP26( 'SN3.N3_VORIG14' )
    select @nN3_VORIG14   = 0
    select @nN3_TXDEPR14 = 0
    select @nValDepr14        = 0
    select @nVORIG14         = 0
    select @nVRDACM14     = 0
    select @nAMPLIA14       = 0
    select @nN3_VLACEL14 = 0
    select @nValor14            = 0
    select @cCasas14          = Substring(@IN_CASASN, 17, 2 )
    select @nCasas14          = Convert(integer, @cCasas14)
    select @nVRDACM14Tp07 = 0
    ##ENDFIELDP26    
    ##FIELDP27( 'SN3.N3_VORIG15' )
    select @nN3_VORIG15   = 0
    select @nN3_TXDEPR15 = 0
    select @nValDepr15        = 0
    select @nVORIG15         = 0
    select @nVRDACM15     = 0
    select @nAMPLIA15       = 0
    select @nN3_VLACEL15 = 0
    select @nValor15            = 0
    select @cCasas15          = Substring(@IN_CASASN, 19, 2 )
    select @nCasas15          = Convert(integer, @cCasas15)
    select @nVRDACM15Tp07 = 0
    ##ENDFIELDP27
    ##FIELDP28( 'SN1.N1_BLQDEPR' )
    select @cN1_BLQDEPR = ' '
    ##ENDFIELDP28
    select @cAux = 'SN3'
    exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_SN3 OutPut
    Select @cFilial = ' ' 
    select @OUT_RESULTADO = '0', @cCalcula = '1', @iRecnoSN1 = null, @iRecnoSN3 = 0, @iRecnoSNG = null,  @lCalcCor = '0', @cN3_DTACELE = ' '
    select @nTxMedia = 0, @nTxDep = 0, @nN3_PRODMES = 0, @nN3_PRODANC = 0, @iSeq = 0, @nN3_YTD = 0, @nN3_VLACEL1 = 0, @nN3_VLACEL2 = 0, @nN3_VLACEL3 = 0, @nN3_VLACEL4 = 0, @nN3_VLACEL5 = 0
    select @cDataIniDep = Substring( @IN_DATADEP, 1, 6 )||'01'

    If (( @IN_LCORRECAO = '1' and @IN_VCORRECAO > 0 ) or (@IN_DATADEP < '19960101')) select @lCalcCor = '1'
   
    Declare CUR_ATF050 insensitive cursor for
    select N3_CBASE,   N3_ITEM,    N3_TIPO,    N3_SEQ,     N3_TPDEPR,  N3_DEPREC,  N3_CCORREC, N3_CCCORR,  N3_SUBCCOR,
            N3_BAIXA,   N3_VRDACM1, N3_VRDACM2, N3_VRDACM3, N3_VRDACM4, N3_VRDACM5
            ##FIELDP18( 'SN3.N3_VORIG6' )
            , N3_VRDACM6
            ##ENDFIELDP18
            ##FIELDP19( 'SN3.N3_VORIG7' )
            , N3_VRDACM7
            ##ENDFIELDP19
            ##FIELDP20( 'SN3.N3_VORIG8' )
            , N3_VRDACM8
            ##ENDFIELDP20
            ##FIELDP21( 'SN3.N3_VORIG9' )
            , N3_VRDACM9
            ##ENDFIELDP21
            ##FIELDP22( 'SN3.N3_VORIG10' )
            , N3_VRDAC10
            ##ENDFIELDP22
            ##FIELDP23( 'SN3.N3_VORIG11' )
            , N3_VRDAC11
            ##ENDFIELDP23
            ##FIELDP24( 'SN3.N3_VORIG12' )
            , N3_VRDAC12
            ##ENDFIELDP24
            ##FIELDP25( 'SN3.N3_VORIG13' )
            , N3_VRDAC13
            ##ENDFIELDP25
            ##FIELDP26( 'SN3.N3_VORIG14' )
            , N3_VRDAC14
            ##ENDFIELDP26
            ##FIELDP27( 'SN3.N3_VORIG15' )
            , N3_VRDAC15
            ##ENDFIELDP27
            , N3_VRCACM1, N3_VORIG1,  N3_VORIG2,  N3_VORIG3,  N3_VORIG4,  N3_VORIG5,  N3_TXDEPR1, N3_TXDEPR2,
            N3_TXDEPR3, N3_TXDEPR4, N3_TXDEPR5, N3_VRCDA1,  N3_AQUISIC, N3_DTBAIXA, N3_DINDEPR, N3_CCUSTO,
            N3_CCONTAB, N3_CCCDEP,  N3_SUBCCDE, N3_CDEPREC, N3_SUBCDEP, N3_CCCDES,  N3_SUBCDES, N3_NOVO,    N3_CLVLCON,
            N3_CUSTBEM, N3_CLVLDEP, N3_CCDESP,  N3_CCDEPR,  N3_CLVLCDE, N3_CDESP,   N3_CLVLDES, N3_SUBCTA,  N3_CLVL,
            N3_SUBCCON, N3_CLVLCOR, N3_SEQREAV, N3_FILIAL,  R_E_C_N_O_, N3_FIMDEPR
            ##FIELDP01( 'SN3.N3_PRODANC;N3_YTD' )
                , N3_PRODANC, N3_YTD
            ##ENDFIELDP01
            ##FIELDP02( 'SN3.N3_DTACELE;N3_VLACEL1;N3_VLACEL2;N3_VLACEL3;N3_VLACEL4;N3_VLACEL5' )
                , N3_DTACELE, N3_VLACEL1, N3_VLACEL2, N3_VLACEL3, N3_VLACEL4, N3_VLACEL5
            ##ENDFIELDP02
            ##FIELDP08( 'SN3.N3_PERDEPR;N3_PRODMES;N3_PRODANO;N3_VMXDEPR;N3_VLSALV1' )
                , N3_PERDEPR, N3_PRODMES, N3_PRODANO, N3_VMXDEPR, N3_VLSALV1
            ##ENDFIELDP08
            ##FIELDP11( 'SN3.N3_TPSALDO' )
                , N3_TPSALDO
            ##ENDFIELDP11
            ##FIELDP14( 'SN3.N3_CODIND' )
			    , N3_CODIND
            ##ENDFIELDP14
        ##FIELDP18( 'SN3.N3_VORIG6' )
            ,N3_VORIG6, N3_TXDEPR6, N3_VLACEL6
        ##ENDFIELDP18
        ##FIELDP19( 'SN3.N3_VORIG7' )
            ,N3_VORIG7, N3_TXDEPR7, N3_VLACEL7
        ##ENDFIELDP19
        ##FIELDP20( 'SN3.N3_VORIG8' )
            ,N3_VORIG8, N3_TXDEPR8, N3_VLACEL8
        ##ENDFIELDP20
        ##FIELDP21( 'SN3.N3_VORIG9' )
            ,N3_VORIG9, N3_TXDEPR9, N3_VLACEL9
        ##ENDFIELDP21
        ##FIELDP22( 'SN3.N3_VORIG10' )
            ,N3_VORIG10, N3_TXDEP10, N3_VLACE10
        ##ENDFIELDP22
        ##FIELDP23( 'SN3.N3_VORIG11' )
            ,N3_VORIG11, N3_TXDEP11, N3_VLACE11
        ##ENDFIELDP23
        ##FIELDP24( 'SN3.N3_VORIG12' )
            ,N3_VORIG12, N3_TXDEP12, N3_VLACE12
        ##ENDFIELDP24
        ##FIELDP25( 'SN3.N3_VORIG13' )
            ,N3_VORIG13, N3_TXDEP13, N3_VLACE13
        ##ENDFIELDP25
        ##FIELDP26( 'SN3.N3_VORIG14' )
            ,N3_VORIG14, N3_TXDEP14, N3_VLACE14
        ##ENDFIELDP26
        ##FIELDP27( 'SN3.N3_VORIG15' )
            ,N3_VORIG15, N3_TXDEP15, N3_VLACE15
        ##ENDFIELDP27
		, N3_AMPLIA1
        From SN3### 
    Where N3_FILIAL      between @cFilial_SN3 and @IN_FILIALATE
	    and ( N3_FIMDEPR = ' ' OR ( N3_FIMDEPR != ' ' AND ( N3_VRDMES1+N3_VRDMES2+N3_VRDMES3+N3_VRDMES4+N3_VRDMES5 > 0 ) ) )
        and N3_CCONTAB    != ' '
        and N3_AQUISIC    <= @IN_DATADEP
        and N3_DINDEPR    <= @IN_DATADEP
        and ( N3_DTBAIXA = ' ' OR (N3_DTBAIXA BETWEEN @cDataIniDep AND @IN_DATADEP ))
        and (N3_BAIXA < '1' OR (N3_BAIXA >= '1' AND N3_NOVO = '1'))
        and N3_TIPO      NOT IN ( '03', '33', '13' )
        and ( (@IN_LATFCTAP = '0')  
        or  ((@IN_CPAISLOC = 'BOL') and (N3_TPDEPR NOT IN ('4','8','9')))
        or  ((@IN_CPAISLOC <> 'BOL') and (N3_TPDEPR NOT IN ('4','5','8','9'))))
        and D_E_L_E_T_     = ' '
    order by N3_FILIAL, N3_CBASE, N3_ITEM, N3_TIPO
    for read only
    Open CUR_ATF050
    Fetch CUR_ATF050 into
            @cN3_CBASE,   @cN3_ITEM,    @cN3_TIPO,    @cN3_SEQ,     @cN3_TPDEPR,  @cN3_DEPREC,  @cN3_CCORREC, @cN3_CCCORR,  @cN3_SUBCCOR,
            @cN3_BAIXA,   @nN3_VRDACM1, @nVRDACM2, @nVRDACM3, @nVRDACM4, @nVRDACM5
            ##FIELDP18( 'SN3.N3_VORIG6' )
            , @nVRDACM6
            ##ENDFIELDP18
            ##FIELDP19( 'SN3.N3_VORIG7' )
            , @nVRDACM7
            ##ENDFIELDP19
            ##FIELDP20( 'SN3.N3_VORIG8' )
            , @nVRDACM8
            ##ENDFIELDP20
            ##FIELDP21( 'SN3.N3_VORIG9' )
            , @nVRDACM9
            ##ENDFIELDP21
            ##FIELDP22( 'SN3.N3_VORIG10' )
            , @nVRDACM10
            ##ENDFIELDP22
            ##FIELDP23( 'SN3.N3_VORIG11' )
            , @nVRDACM11
            ##ENDFIELDP23
            ##FIELDP24( 'SN3.N3_VORIG12' )
            , @nVRDACM12
            ##ENDFIELDP24
            ##FIELDP25( 'SN3.N3_VORIG13' )
            , @nVRDACM13
            ##ENDFIELDP25
            ##FIELDP26( 'SN3.N3_VORIG14' )
            , @nVRDACM14
            ##ENDFIELDP26
            ##FIELDP27( 'SN3.N3_VORIG15' )
            , @nVRDACM15
            ##ENDFIELDP27
            , @nVRCACM1, @nN3_VORIG1,  @nN3_VORIG2,  @nN3_VORIG3,  @nN3_VORIG4,  @nN3_VORIG5,  @nN3_TXDEPR1, @nN3_TXDEPR2,
            @nN3_TXDEPR3, @nN3_TXDEPR4, @nN3_TXDEPR5, @nN3_VRCDA1,  @cN3_AQUISIC, @cN3_DTBAIXA, @cN3_DINDEPR, @cN3_CCUSTO,
            @cN3_CCONTAB, @cN3_CCCDEP,  @cN3_SUBCCDE, @cN3_CDEPREC, @cN3_SUBCDEP, @cN3_CCCDES,  @cN3_SUBCDES, @cN3_NOVO,    @cN3_CLVLCON,
            @cN3_CUSTBEM, @cN3_CLVLDEP, @cN3_CCDESP,  @cN3_CCDEPR,  @cN3_CLVLCDE, @cN3_CDESP,   @cN3_CLVLDES, @cN3_SUBCTA,  @cN3_CLVL,
            @cN3_SUBCCON, @cN3_CLVLCOR, @cN3_SEQREAV, @cFilial,     @iRecnoSN3,   @cN3_FIMDEPR
            ##FIELDP03( 'SN3.N3_PRODANC;N3_YTD' )
            , @nN3_PRODANC, @nN3_YTD
            ##ENDFIELDP03
            ##FIELDP04( 'SN3.N3_DTACELE;N3_VLACEL1;N3_VLACEL2;N3_VLACEL3;N3_VLACEL4;N3_VLACEL5' )
                , @cN3_DTACELE, @nN3_VLACEL1, @nN3_VLACEL2, @nN3_VLACEL3, @nN3_VLACEL4, @nN3_VLACEL5
            ##ENDFIELDP04
            ##FIELDP09( 'SN3.N3_PERDEPR;N3_PRODMES;N3_PRODANO;N3_VMXDEPR;N3_VLSALV1' )
                , @iN3_PERDEPR, @nN3_PRODMES, @nN3_PRODANO, @nN3_VMXDEPR, @nN3_VLSALV1
            ##ENDFIELDP09
            ##FIELDP12( 'SN3.N3_TPSALDO' )
                , @cN3_TPSALDO
            ##ENDFIELDP12         
            ##FIELDP15( 'SN3.N3_CODIND' )
			    , @cN3_CODIND
            ##ENDFIELDP15
            ##FIELDP18( 'SN3.N3_VORIG6' )
            ,@nN3_VORIG6, @nN3_TXDEPR6, @nN3_VLACEL6
            ##ENDFIELDP18
            ##FIELDP19( 'SN3.N3_VORIG7' )
            ,@nN3_VORIG7, @nN3_TXDEPR7, @nN3_VLACEL7
            ##ENDFIELDP19
            ##FIELDP20( 'SN3.N3_VORIG8' )
            ,@nN3_VORIG8, @nN3_TXDEPR8, @nN3_VLACEL8
            ##ENDFIELDP20
            ##FIELDP21( 'SN3.N3_VORIG9' )
            ,@nN3_VORIG9, @nN3_TXDEPR9, @nN3_VLACEL9
            ##ENDFIELDP21
            ##FIELDP22( 'SN3.N3_VORIG10' )
            ,@nN3_VORIG10, @nN3_TXDEPR10, @nN3_VLACEL10
            ##ENDFIELDP22
            ##FIELDP23( 'SN3.N3_VORIG11' )
            ,@nN3_VORIG11, @nN3_TXDEPR11, @nN3_VLACEL11
            ##ENDFIELDP23
            ##FIELDP24( 'SN3.N3_VORIG12' )
            ,@nN3_VORIG12, @nN3_TXDEPR12, @nN3_VLACEL12
            ##ENDFIELDP24
            ##FIELDP25( 'SN3.N3_VORIG13' )
            ,@nN3_VORIG13, @nN3_TXDEPR13, @nN3_VLACEL13
            ##ENDFIELDP25
            ##FIELDP26( 'SN3.N3_VORIG14' )
            ,@nN3_VORIG14, @nN3_TXDEPR14, @nN3_VLACEL14
            ##ENDFIELDP26
            ##FIELDP27( 'SN3.N3_VORIG15' )
            ,@nN3_VORIG15, @nN3_TXDEPR15, @nN3_VLACEL15
            ##ENDFIELDP27
			,@nAMPLIA1
         
    While (@@Fetch_status = 0 ) begin
        select @cAux = 'SN1'
        exec XFILIAL_## @cAux, @cFilial, @cFilial_SN1 OutPut
        select @cAux = 'SN4'
        exec XFILIAL_## @cAux, @cFilial, @cFilial_SN4 OutPut
        select @cAux = 'SNG'
        exec XFILIAL_## @cAux, @cFilial, @cFilial_SNG OutPut
        select @nVRCDA1 = 0, @iRecnoAux = null, @nValDepr1 = 0, @nValDepr2 = 0, @nValDepr3 = 0,     @nValDepr4 = 0, @nValDepr5 = 0, @lAcelera = '0', @nValor1 = 0,  @nValor2 = 0
        Select @nValor3 = 0, @nValor4   = 0,    @nValor5 = 0,   @nValorX = 0,   @iRecnoTp07 = null, @nAMPLIA2 = 0,  @nAMPLIA3 = 0,   @nAMPLIA4 = 0, @nAMPLIA5 = 0
        select @nValorOrig = 0, @nValorAcum = 0
        ##FIELDP17( 'SN1.N1_CALCPIS' )
        ,  @cN1_CALCPIS = ' '
        ##ENDFIELDP17
        ##FIELDP18( 'SN3.N3_VORIG6' )
        ,@nValDepr6 = 0, @nValor6 = 0, @nAMPLIA6 = 0
        ##ENDFIELDP18
        ##FIELDP19( 'SN3.N3_VORIG7' )
        ,@nValDepr7 = 0, @nValor7 = 0, @nAMPLIA7 = 0
        ##ENDFIELDP19
        ##FIELDP20( 'SN3.N3_VORIG8' )
        ,@nValDepr8 = 0, @nValor8 = 0, @nAMPLIA8 = 0
        ##ENDFIELDP20
        ##FIELDP21( 'SN3.N3_VORIG9' )
        ,@nValDepr9 = 0, @nValor9 = 0, @nAMPLIA9 = 0
        ##ENDFIELDP21
        ##FIELDP22( 'SN3.N3_VORIG10' )
        ,@nValDepr10 = 0, @nValor10 = 0, @nAMPLIA10 = 0
        ##ENDFIELDP22
        ##FIELDP23( 'SN3.N3_VORIG11' )
        ,@nValDepr11 = 0, @nValor11 = 0, @nAMPLIA11 = 0
        ##ENDFIELDP23
        ##FIELDP24( 'SN3.N3_VORIG12' )
        ,@nValDepr12 = 0, @nValor12 = 0, @nAMPLIA12 = 0
        ##ENDFIELDP24
        ##FIELDP25( 'SN3.N3_VORIG13' )
        ,@nValDepr13 = 0, @nValor13 = 0, @nAMPLIA13 = 0
        ##ENDFIELDP25
        ##FIELDP26( 'SN3.N3_VORIG14' )
        ,@nValDepr14 = 0, @nValor14 = 0, @nAMPLIA14 = 0
        ##ENDFIELDP26
        ##FIELDP27( 'SN3.N3_VORIG15' )
        ,@nValDepr14 = 0, @nValor14 = 0, @nAMPLIA14 = 0
        ##ENDFIELDP27
        /* ----------------------------------------------------------------------------------
        Ponto de Entrada - RIPASA
        Se retorno, @cCalcula,  for '1' calcula a depreciacao, se '0',
        não deprecia e vai para o proximo Ativo
        ---------------------------------------------------------------------------------- */
        exec AF050FPR_## @cFilial, @cN3_CBASE, @cN3_ITEM, @cN3_TIPO, @cN3_SEQ, @IN_DATADEP, @cCalcula OutPut
        ##FIELDP28( 'SN1.N1_BLQDEPR' )
        /* ----------------------------------------------------------------------------------
            N1_BLQDEPR - se preenchido com 'S' Não calcular a depreciação.
            Ativos com motivo de baixa 'Venda' - não deve sofrer depreciação. CPC -31
            ---------------------------------------------------------------------------------- */
        select @cN1_BLQDEPR = Isnull(N1_BLQDEPR, ' ')
        from SN1###
        where N1_FILIAL  = @cFilial_SN1
        and N1_CBASE   = @cN3_CBASE
        and N1_ITEM    = @cN3_ITEM
        and D_E_L_E_T_ = ' '
        If @cN1_BLQDEPR = 'S' select @cCalcula = '0'
        else select @cCalcula = '1'							
        ##ENDFIELDP28

        If @cCalcula = '1' begin
            /* ----------------------------------------------------------------------------------
            Verifica se calcula depreciacao acelerada
            A depreciacao mensal do Ativo q teve depreciacao Acelerada no mes do cálculo sera
            efetuada se esta fora feita com data menor que a do calculo de depreciacao.
            SE @lAcelera for = '0' Ativos sem Depreciacao Acelerada
            SE @lAcelera for = '1' calcula a depreciacao para o restante do mes
            SE @lAcelera for = '2' acelerada no ultimo dia do mes = dia do calculo
            ---------------------------------------------------------------------------------- */
            If ( @cN3_DTACELE != ' ' and ( Substring(@cN3_DTACELE, 1, 6) = Substring(@IN_DATADEP, 1, 6) and ( @cN3_DTACELE <= @IN_DATADEP ))) begin
            select @lAcelera = '1'
            end else begin
            If ( @cN3_DTACELE != ' ' and ( @cN3_DTACELE > @IN_DATADEP )) begin
                select @lAcelera = '2'
            end
            end
            If (@lAcelera = '0' or @lAcelera = '1') begin
            /* --------------------------------------------------------------------------
                Se existe o tipo 09 , nao deprecio o tipo 08 -> @iRecnoAux > 0
                -------------------------------------------------------------------------- */
            If @cN3_TIPO = '08' and @IN_CPAISLOC = 'BRA' begin
                Select @iRecnoAux =  R_E_C_N_O_
                    From SN3### 
                Where N3_FILIAL  = @cFilial
                    AND N3_CBASE   = @cN3_CBASE
                    AND N3_ITEM    = @cN3_ITEM
                    AND N3_TIPO    = '09'
                    AND ( N3_BAIXA = ' ' OR N3_BAIXA  = '0' )
                    AND D_E_L_E_T_ = ' '
            End
            If @iRecnoAux is null begin
                If @cN3_DTBAIXA != ' ' and   (( Substring( @cN3_DTBAIXA, 5, 2 ) < Substring( @IN_DATADEP, 5, 2 ) ) and 
                                                ( Substring( @cN3_DTBAIXA, 1, 4 ) < Substring( @IN_DATADEP, 1, 4 ) )) begin
                    UpDate SN3### 
                    Set N3_VRDMES1 = 0, N3_VRDMES2 = 0, N3_VRDMES3 = 0, N3_VRDMES4 = 0, N3_VRDMES5 = 0, N3_VRCMES1 = 0, N3_VRCDM1 = 0
                    Where R_E_C_N_O_ =   @iRecnoSN3
                end else begin
                        /* ---------------------------------------------------------------------------------
                        Verifico se está no SN1 e atende aos requistos de cálculo ATFBLOQUEIO 
                        ---------------------------------------------------------------------------------*/
                        Select @cN1_GRUPO = N1_GRUPO, @iRecnoSN1 = R_E_C_N_O_
                            ##FIELDP12( 'SN1.N1_TPBEM' )
                            ,@cN1_TPBEM = N1_TPBEM
                            ##ENDFIELDP12
                            ##FIELDP17( 'SN1.N1_CALCPIS' )
                                , @cN1_CALCPIS = IsNull( N1_CALCPIS, ' ')
                                ##ENDFIELDP17
                        From SN1### 
                        Where N1_FILIAL   = @cFilial_SN1
                        and N1_CBASE    = @cN3_CBASE
                        and N1_ITEM     = @cN3_ITEM
                        and N1_DTBLOQ   < @IN_DATADEP
                        and D_E_L_E_T_  = ' '
                     
                        Exec ATF011_## @cFilial,     @IN_CPAISLOC, @cN3_CBASE,  @cN3_ITEM,    @cN3_CCDEPR,  @cN3_CDEPREC,@cN3_CCORREC,@cN3_CDESP,
                                    @cN3_DINDEPR, @IN_DATADEP,  @cN3_AQUISIC,@cN3_DTBAIXA, @nN3_TXDEPR1, @nN3_TXDEPR2,@nN3_TXDEPR3,@nN3_TXDEPR4,
                                    @nN3_TXDEPR5, @iRecnoSN3,   @cN3_TPDEPR, @nN3_YTD,     @nN3_PRODMES, @nN3_PRODANC,@IN_LFUNDADA,@IN_MOEDAATF,
                                    @IN_LCORRECAO,@IN_VCORRECAO,@IN_TXDEPOK, @IN_LEYDL824, @IN_LMESCHEIO,@IN_ATFMBLQ, @IN_CALCDEP, @iN3_PERDEPR,
                                    @nN3_PRODANO, @nN3_VRDACM1, @nN3_VORIG1, @nN3_VLSALV1, @IN_ATFMDMX,@cN3_CODIND
                                    ##FIELDP18( 'SN3.N3_VORIG6' )
                                    , @nN3_TXDEPR6
                                    ##ENDFIELDP18
                                    ##FIELDP19( 'SN3.N3_VORIG7' )
                                    , @nN3_TXDEPR7
                                    ##ENDFIELDP19
                                    ##FIELDP20( 'SN3.N3_VORIG8' )
                                    , @nN3_TXDEPR8
                                    ##ENDFIELDP20
                                    ##FIELDP21( 'SN3.N3_VORIG9' )
                                    , @nN3_TXDEPR9
                                    ##ENDFIELDP21
                                    ##FIELDP22( 'SN3.N3_VORIG10' )
                                    , @nN3_TXDEPR10
                                    ##ENDFIELDP22
                                    ##FIELDP23( 'SN3.N3_VORIG11' )
                                    , @nN3_TXDEPR11
                                    ##ENDFIELDP23
                                    ##FIELDP24( 'SN3.N3_VORIG12' )
                                    , @nN3_TXDEPR12
                                    ##ENDFIELDP24
                                    ##FIELDP25( 'SN3.N3_VORIG13' )
                                    , @nN3_TXDEPR13
                                    ##ENDFIELDP25
                                    ##FIELDP26( 'SN3.N3_VORIG14' )
                                    , @nN3_TXDEPR14
                                    ##ENDFIELDP26
                                    ##FIELDP27( 'SN3.N3_VORIG15' )
                                    , @nN3_TXDEPR15
                                    ##ENDFIELDP27
                                    ,@nValDepr1 OutPut, @nValDepr2  OutPut, @nValDepr3 OutPut, @nValDepr4 OutPut, @nValDepr5 OutPut,
                                    @nValCor   OutPut, @nValCorDep OutPut, @nTxMedia  OutPut, @nTxDep OutPut
                                    ##FIELDP18( 'SN3.N3_VORIG6' )
                                    , @nValDepr6 OutPut
                                    ##ENDFIELDP18
                                    ##FIELDP19( 'SN3.N3_VORIG7' )
                                    , @nValDepr7 OutPut
                                    ##ENDFIELDP19
                                    ##FIELDP20( 'SN3.N3_VORIG8' )
                                    , @nValDepr8 OutPut
                                    ##ENDFIELDP20
                                    ##FIELDP21( 'SN3.N3_VORIG9' )
                                    , @nValDepr9 OutPut
                                    ##ENDFIELDP21
                                    ##FIELDP22( 'SN3.N3_VORIG10' )
                                    , @nValDepr10 OutPut
                                    ##ENDFIELDP22
                                    ##FIELDP23( 'SN3.N3_VORIG11' )
                                    , @nValDepr11 OutPut
                                    ##ENDFIELDP23
                                    ##FIELDP24( 'SN3.N3_VORIG12' )
                                    , @nValDepr12 OutPut
                                    ##ENDFIELDP24
                                    ##FIELDP25( 'SN3.N3_VORIG13' )
                                    , @nValDepr13 OutPut
                                    ##ENDFIELDP25
                                    ##FIELDP26( 'SN3.N3_VORIG14' )
                                    , @nValDepr14 OutPut
                                    ##ENDFIELDP26
                                    ##FIELDP27( 'SN3.N3_VORIG15' )
                                    , @nValDepr15 OutPut
                                    ##ENDFIELDP27

                    
                    /* --------------------------------------------------------------------------
                        Depreciacao Acelerada tipo '07'
                        -------------------------------------------------------------------------- */
                    If @cN3_TIPO IN ('07', '01') and @IN_CPAISLOC = 'BRA' begin
                        If @cN3_TIPO = '07' begin
                        select @cN3_TIPOAux = '01'
                        end else begin
                        select @cN3_TIPOAux = '07'
                        end
                        Select @nVRDACM1Tp07 = N3_VRDACM1, @nVRDACM2Tp07 = N3_VRDACM2, @nVRDACM3Tp07 = N3_VRDACM3, @nVRDACM4Tp07 = N3_VRDACM4,
                            @nVRDACM5Tp07 = N3_VRDACM5, @nVRCDA1Tp07  = N3_VRCDA1,  @iRecnoTp07   = R_E_C_N_O_ , @cN3_FIMDEPR_07 = N3_FIMDEPR,
							@nAMPLIA1 = N3_AMPLIA1	 	
                        ##FIELDP18( 'SN3.N3_VORIG6' )
                        ,@nVRDACM6Tp07 = N3_VRDACM6
                        ##ENDFIELDP18
                        ##FIELDP19( 'SN3.N3_VORIG7' )
                        ,@nVRDACM7Tp07 = N3_VRDACM7
                        ##ENDFIELDP19
                        ##FIELDP20( 'SN3.N3_VORIG8' )
                        ,@nVRDACM8Tp07 = N3_VRDACM8
                        ##ENDFIELDP20
                        ##FIELDP21( 'SN3.N3_VORIG9' )
                        ,@nVRDACM9Tp07 = N3_VRDACM9
                        ##ENDFIELDP21
                        ##FIELDP22( 'SN3.N3_VORIG10' )
                        ,@nVRDACM10Tp07 = N3_VRDAC10
                        ##ENDFIELDP22
                        ##FIELDP23( 'SN3.N3_VORIG11' )
                        ,@nVRDACM11Tp07 = N3_VRDAC11
                        ##ENDFIELDP23
                        ##FIELDP24( 'SN3.N3_VORIG12' )
                        ,@nVRDACM12Tp07 = N3_VRDAC12
                        ##ENDFIELDP24
                        ##FIELDP25( 'SN3.N3_VORIG13' )
                        ,@nVRDACM13Tp07 = N3_VRDAC13
                        ##ENDFIELDP25
                        ##FIELDP26( 'SN3.N3_VORIG14' )
                        ,@nVRDACM14Tp07 = N3_VRDAC14
                        ##ENDFIELDP26
                        ##FIELDP27( 'SN3.N3_VORIG15' )
                        ,@nVRDACM15Tp07 = N3_VRDAC15
                        ##ENDFIELDP27
                        From SN3### 
                        Where N3_FILIAL  = @cFilial
                        AND N3_CBASE   = @cN3_CBASE
                        AND N3_ITEM    = @cN3_ITEM
                        AND N3_TIPO    = @cN3_TIPOAux
                        AND  (N3_BAIXA  = ' '  OR N3_BAIXA  = '0' ) 
						AND D_E_L_E_T_ = ' '
									
                        If @iRecnoTp07 is not null begin
                            select @nValor1 = @nVRDACM1Tp07 + @nVRCDA1Tp07
                            select @nValor2 = @nVRDACM2Tp07
                            select @nValor3 = @nVRDACM3Tp07
                            select @nValor4 = @nVRDACM4Tp07
                            select @nValor5 = @nVRDACM5Tp07
                            ##FIELDP18( 'SN3.N3_VORIG6' )
                            select @nValor6 = @nVRDACM6Tp07
                            ##ENDFIELDP18
                            ##FIELDP19( 'SN3.N3_VORIG7' )
                            select @nValor7 = @nVRDACM7Tp07
                            ##ENDFIELDP19
                            ##FIELDP20( 'SN3.N3_VORIG8' )
                            select @nValor8 = @nVRDACM8Tp07
                            ##ENDFIELDP20
                            ##FIELDP21( 'SN3.N3_VORIG9' )
                            select @nValor9 = @nVRDACM9Tp07
                            ##ENDFIELDP21
                            ##FIELDP22( 'SN3.N3_VORIG10' )
                            select @nValor10 = @nVRDACM10Tp07
                            ##ENDFIELDP22
                            ##FIELDP23( 'SN3.N3_VORIG11' )
                            select @nValor11 = @nVRDACM11Tp07
                            ##ENDFIELDP23
                            ##FIELDP24( 'SN3.N3_VORIG12' )
                            select @nValor12 = @nVRDACM12Tp07
                            ##ENDFIELDP24
                            ##FIELDP25( 'SN3.N3_VORIG13' )
                            select @nValor13 = @nVRDACM13Tp07
                            ##ENDFIELDP25
                            ##FIELDP26( 'SN3.N3_VORIG14' )
                            select @nValor14 = @nVRDACM14Tp07
                            ##ENDFIELDP26
                            ##FIELDP27( 'SN3.N3_VORIG15' )
                            select @nValor15 = @nVRDACM15Tp07
                            ##ENDFIELDP27

                            If @IN_MOEDAATF = '02' begin
                                select @nValorX = @nValor2
                            End
                            If @IN_MOEDAATF = '03' begin
                                select @nValorX = @nValor3
                            end
                            If @IN_MOEDAATF = '04' begin
                                select @nValorX = @nValor4
                            end
                            If @IN_MOEDAATF = '05' begin
                                select @nValorX = @nValor5
                            end
                            ##FIELDP18( 'SN3.N3_VORIG6' )
                            select @nValorX = @nValor6
                            ##ENDFIELDP18
                            ##FIELDP19( 'SN3.N3_VORIG7' )
                            select @nValorX = @nValor7
                            ##ENDFIELDP19
                            ##FIELDP20( 'SN3.N3_VORIG8' )
                            select @nValorX = @nValor8
                            ##ENDFIELDP20
                            ##FIELDP21( 'SN3.N3_VORIG9' )
                            select @nValorX = @nValor9
                            ##ENDFIELDP21
                            ##FIELDP22( 'SN3.N3_VORIG10' )
                            select @nValorX = @nValor10
                            ##ENDFIELDP22
                            ##FIELDP23( 'SN3.N3_VORIG11' )
                            select @nValorX = @nValor11
                            ##ENDFIELDP23
                            ##FIELDP24( 'SN3.N3_VORIG12' )
                            select @nValorX = @nValor12
                            ##ENDFIELDP24
                            ##FIELDP25( 'SN3.N3_VORIG13' )
                            select @nValorX = @nValor13
                            ##ENDFIELDP25
                            ##FIELDP26( 'SN3.N3_VORIG14' )
                            select @nValorX = @nValor14
                            ##ENDFIELDP26
                            ##FIELDP27( 'SN3.N3_VORIG15' )
                            select @nValorX = @nValor15
                            ##ENDFIELDP27
                        End
                        /*CONTROLE PARA DEFINIÇÃO DO VALOR A DEPRECIAR QUANDO HOUVER/NÃO HOUVER DEPRECIAÇÃO ACELERADA */
                        If  (@nN3_VORIG1 + @nAMPLIA1 + @nVRCACM1) < (@nValor1 + @nValDepr1 + @nN3_VRDACM1)  begin 
                            IF  @cN3_FIMDEPR_07 = ' ' begin
                                select @nValDepr1 =   (@nN3_VORIG1 + @nAMPLIA1 + @nVRCACM1) -  (@nValor1 +  @nN3_VRDACM1)
                                select @nValDepr2 =   (@nN3_VORIG2 + @nAMPLIA2) - (@nValor2 +  @nVRDACM2)
                                select @nValDepr3 =   (@nN3_VORIG3 + @nAMPLIA3) - (@nValor3 +  @nVRDACM3)
                                select @nValDepr4 =   (@nN3_VORIG4 + @nAMPLIA4) - (@nValor4 +  @nVRDACM4)
                                select @nValDepr5 =   (@nN3_VORIG5 + @nAMPLIA5) - (@nValor5 +  @nVRDACM5)
                                ##FIELDP18( 'SN3.N3_VORIG6' )
                                    select @nValDepr6 = (@nN3_VORIG6 + @nAMPLIA6) - (@nValor6 +  @nVRDACM6)
                                ##ENDFIELDP18
                                ##FIELDP19( 'SN3.N3_VORIG7' )
                                    select @nValDepr7 = (@nN3_VORIG7 + @nAMPLIA7) - (@nValor7 +  @nVRDACM7)
                                ##ENDFIELDP19
                                ##FIELDP20( 'SN3.N3_VORIG8' )
                                    select @nValDepr8 = (@nN3_VORIG8 + @nAMPLIA8) - (@nValor8 +  @nVRDACM8)
                                ##ENDFIELDP20
                                ##FIELDP21( 'SN3.N3_VORIG9' )
                                    select @nValDepr9 = (@nN3_VORIG9 + @nAMPLIA9) - (@nValor9 +  @nVRDACM9)
                                ##ENDFIELDP21
                                ##FIELDP22( 'SN3.N3_VORIG10' )
                                    select @nValDepr10 = (@nN3_VORIG10 + @nAMPLIA10) - (@nValor10 +  @nVRDACM10)
                                ##ENDFIELDP22
                                ##FIELDP21( 'SN3.N3_VORIG11' )
                                    select @nValDepr11 = (@nN3_VORIG11 + @nAMPLIA11) - (@nValor11 +  @nVRDACM11)
                                ##ENDFIELDP21
                                ##FIELDP22( 'SN3.N3_VORIG12' )
                                    select @nValDepr12 = (@nN3_VORIG12 + @nAMPLIA12) - (@nValor12 +  @nVRDACM12)
                                ##ENDFIELDP22
                                ##FIELDP23( 'SN3.N3_VORIG13' )
                                    select @nValDepr13 = (@nN3_VORIG13 + @nAMPLIA13) - (@nValor13 +  @nVRDACM13)
                                ##ENDFIELDP23
                                ##FIELDP24( 'SN3.N3_VORIG14' )
                                    select @nValDepr14 = (@nN3_VORIG14 + @nAMPLIA14) - (@nValor14 +  @nVRDACM14)
                                ##ENDFIELDP24
                                ##FIELDP25( 'SN3.N3_VORIG15' )
                                    select @nValDepr15 = (@nN3_VORIG15 + @nAMPLIA15) - (@nValor15 +  @nVRDACM15)
                                ##ENDFIELDP25
							 end else begin
                                select @nValDepr1 =   0
                                select @nValDepr2 =   0
                                select @nValDepr3 =   0
                                select @nValDepr4 =   0
                                select @nValDepr5 =   0
                                ##FIELDP18( 'SN3.N3_VORIG6' )
                                    select @nValDepr6 = 0
                                ##ENDFIELDP18
                                ##FIELDP19( 'SN3.N3_VORIG7' )
                                    select @nValDepr7 = 0
                                ##ENDFIELDP19
                                ##FIELDP20( 'SN3.N3_VORIG8' )
                                    select @nValDepr8 = 0
                                ##ENDFIELDP20
                                ##FIELDP21( 'SN3.N3_VORIG9' )
                                    select @nValDepr9 = 0
                                ##ENDFIELDP21
                                ##FIELDP22( 'SN3.N3_VORIG10' )
                                    select @nValDepr10 = 0
                                ##ENDFIELDP22
                                ##FIELDP21( 'SN3.N3_VORIG11' )
                                    select @nValDepr11 = 0
                                ##ENDFIELDP21
                                ##FIELDP22( 'SN3.N3_VORIG12' )
                                    select @nValDepr12 = 0
                                ##ENDFIELDP22
                                ##FIELDP23( 'SN3.N3_VORIG13' )
                                    select @nValDepr13 = 0
                                ##ENDFIELDP23
                                ##FIELDP24( 'SN3.N3_VORIG14' )
                                    select @nValDepr14 = 0
                                ##ENDFIELDP24
                                ##FIELDP25( 'SN3.N3_VORIG15' )
                                    select @nValDepr15 = 0
                                ##ENDFIELDP25
                            end
                        end
                    End

                    /* ----------------------------------------------------------------------------------
                        1 -  MovimentoLinha de correcao do bem NO SN4
                        ---------------------------------------------------------------------------------- */
                    If @cN1_TPBEM = ' ' select @cNX_TPBEM = @cN3_TIPO else select @cNX_TPBEM = substring( @cN1_TPBEM, 1, 2 )
                    Exec ATF012_## @IN_CPAISLOC, @cFilial_SN4, @cN3_CBASE,   @cN3_ITEM,   @cN3_TIPO,    @cN3_CCORREC, @cN3_CCONTAB, @cN3_SUBCCON,
                                    @cN3_CCDEPR,  @cN3_CCCDEP,  @cN3_SUBCCDE, @cN3_CDESP,  @cN3_CDEPREC, @cN3_CCDESP,  @cN3_SUBCDEP, @cN3_CCCDES,
                                    @cN3_SUBCDES, @IN_DATADEP,  @cN3_DINDEPR, @cN3_CCCORR, @cN3_SEQ,     @cN3_SUBCCOR, @cN3_SEQREAV, @nTxMedia,
                                    @nTxDep,      @nValCor,     @nValCorDep,  @nValDepr1,  @nValDepr2,   @nValDepr3,   @nValDepr4,   @nValDepr5,
                                    @cN3_TPSALDO, @nN3_PRODMES, @IN_IDMOV,   @cNX_TPBEM,   @nCasas1,     @nCasas2,     @nCasas3, @nCasas4,     @nCasas5
                                    ##FIELDP17( 'SN1.N1_CALCPIS' )
                                    , @cN1_CALCPIS
                                    ##ENDFIELDP17
                                    ##FIELDP18( 'SN3.N3_VORIG6' )
                                    , @nValDepr6, @nCasas6
                                    ##ENDFIELDP18
                                    ##FIELDP19( 'SN3.N3_VORIG7' )
                                    , @nValDepr7, @nCasas7
                                    ##ENDFIELDP19
                                    ##FIELDP20( 'SN3.N3_VORIG8' )
                                    , @nValDepr8, @nCasas8
                                    ##ENDFIELDP20
                                    ##FIELDP21( 'SN3.N3_VORIG9' )
                                    , @nValDepr9, @nCasas9
                                    ##ENDFIELDP21
                                    ##FIELDP22( 'SN3.N3_VORIG10' )
                                    , @nValDepr10, @nCasas10
                                    ##ENDFIELDP22
                                    ##FIELDP23( 'SN3.N3_VORIG11' )
                                    , @nValDepr11, @nCasas11
                                    ##ENDFIELDP23
                                    ##FIELDP24( 'SN3.N3_VORIG12' )
                                    , @nValDepr12, @nCasas12
                                    ##ENDFIELDP24
                                    ##FIELDP25( 'SN3.N3_VORIG13' )
                                    , @nValDepr13, @nCasas13
                                    ##ENDFIELDP25
                                    ##FIELDP26( 'SN3.N3_VORIG14' )
                                    , @nValDepr14, @nCasas14
                                    ##ENDFIELDP26
                                    ##FIELDP27( 'SN3.N3_VORIG15' )
                                    , @nValDepr15, @nCasas15
                                    ##ENDFIELDP27
                    /* ----------------------------------------------------------------------------------
                        Atualiza tabela SN3 Depreciacoes e Correcoes
                        ---------------------------------------------------------------------------------- */
                    If @cN3_NOVO = '1' Select @cN3_NOVO = '2'
                  
                    begin tran
                    If @lAcelera = '1' begin
                        Update SN3### 
                        Set N3_NOVO    = @cN3_NOVO, 
                            N3_VRDMES1 = N3_VRDMES1 + Round(@nValDepr1, @nCasas1), N3_VRDMES2 = N3_VRDMES2 + Round(@nValDepr2, @nCasas2), N3_VRDMES3 = N3_VRDMES3 + Round(@nValDepr3, @nCasas3),
                            N3_VRDMES4 = N3_VRDMES4 + Round(@nValDepr4, @nCasas4), N3_VRDMES5 = N3_VRDMES5 + Round(@nValDepr5, @nCasas5),
                            N3_VRDACM1 = N3_VRDACM1 + Round(@nValDepr1, @nCasas1), N3_VRDACM2 = N3_VRDACM2 + Round(@nValDepr2, @nCasas2), N3_VRDACM3 = N3_VRDACM3 + Round(@nValDepr3, @nCasas3),
                            N3_VRDACM4 = N3_VRDACM4 + Round(@nValDepr4, @nCasas4), N3_VRDACM5 = N3_VRDACM5 + Round(@nValDepr5, @nCasas5),
                            N3_VRDBAL1 = N3_VRDBAL1 + Round(@nValDepr1, @nCasas1), N3_VRDBAL2 = N3_VRDBAL2 + Round(@nValDepr2, @nCasas2), N3_VRDBAL3 = N3_VRDBAL3 + Round(@nValDepr3, @nCasas3),
                            N3_VRDBAL4 = N3_VRDBAL4 + Round(@nValDepr4, @nCasas4), N3_VRDBAL5 = N3_VRDBAL5 + Round(@nValDepr5, @nCasas5),
                            N3_VRCMES1 = Round(@nValCor, @nCasas1), N3_VRCACM1 =  N3_VRCACM1 + Round(@nValCor, @nCasas1), N3_VRCBAL1 = N3_VRCBAL1+ Round(@nValCor, @nCasas1),
                            N3_VRCDM1  = Round(@nValCorDep, @nCasas1), N3_VRCDB1 = N3_VRCDB1 + Round(@nValCorDep, @nCasas1), N3_VRCDA1 = N3_VRCDA1 + Round(@nValCorDep, @nCasas1)
                            ##FIELDP18( 'SN3.N3_VORIG6' )
                            , N3_VRDMES6 = N3_VRDMES6 + Round(@nValDepr6, @nCasas6), N3_VRDACM6 = N3_VRDACM6 + Round(@nValDepr6, @nCasas6), N3_VRDBAL6 = N3_VRDBAL6 + Round(@nValDepr6, @nCasas6)
                            ##ENDFIELDP18
                            ##FIELDP19( 'SN3.N3_VORIG7' )
                            , N3_VRDMES7 = N3_VRDMES7 + Round(@nValDepr7, @nCasas7), N3_VRDACM7 = N3_VRDACM7 + Round(@nValDepr7, @nCasas7), N3_VRDBAL7 = N3_VRDBAL7 + Round(@nValDepr7, @nCasas7)
                            ##ENDFIELDP19
                            ##FIELDP20( 'SN3.N3_VORIG8' )
                            , N3_VRDMES8 = N3_VRDMES8 + Round(@nValDepr8, @nCasas8), N3_VRDACM8 = N3_VRDACM8 + Round(@nValDepr8, @nCasas8), N3_VRDBAL8 = N3_VRDBAL8 + Round(@nValDepr8, @nCasas8)
                            ##ENDFIELDP20
                            ##FIELDP21( 'SN3.N3_VORIG9' )
                            , N3_VRDMES9 = N3_VRDMES9 + Round(@nValDepr9, @nCasas9), N3_VRDACM9 = N3_VRDACM9 + Round(@nValDepr9, @nCasas9), N3_VRDBAL9 = N3_VRDBAL9 + Round(@nValDepr9, @nCasas9)
                            ##ENDFIELDP21
                            ##FIELDP22( 'SN3.N3_VORIG10' )
                            , N3_VRDME10 = N3_VRDME10 + Round(@nValDepr10, @nCasas10), N3_VRDAC10 = N3_VRDAC10 + Round(@nValDepr10, @nCasas10), N3_VRDBA10 = N3_VRDBA10 + Round(@nValDepr10, @nCasas10)
                            ##ENDFIELDP22
                            ##FIELDP23( 'SN3.N3_VORIG11' )
                            , N3_VRDME11 = N3_VRDME11 + Round(@nValDepr11, @nCasas11), N3_VRDAC11 = N3_VRDAC11 + Round(@nValDepr11, @nCasas11), N3_VRDBA11 = N3_VRDBA11 + Round(@nValDepr11, @nCasas11)
                            ##ENDFIELDP23
                            ##FIELDP24( 'SN3.N3_VORIG12' )
                            , N3_VRDME12 = N3_VRDME12 + Round(@nValDepr12, @nCasas12), N3_VRDAC12 = N3_VRDAC12 + Round(@nValDepr12, @nCasas12), N3_VRDBA12 = N3_VRDBA12 + Round(@nValDepr12, @nCasas12)
                            ##ENDFIELDP24
                            ##FIELDP25( 'SN3.N3_VORIG13' )
                            , N3_VRDME13 = N3_VRDME13 + Round(@nValDepr13, @nCasas13), N3_VRDAC13 = N3_VRDAC13 + Round(@nValDepr13, @nCasas13), N3_VRDBA13 = N3_VRDBA13 + Round(@nValDepr13, @nCasas13)
                            ##ENDFIELDP25
                            ##FIELDP26( 'SN3.N3_VORIG14' )
                            , N3_VRDME14 = N3_VRDME14 + Round(@nValDepr14, @nCasas14), N3_VRDAC14 = N3_VRDAC14 + Round(@nValDepr14, @nCasas14), N3_VRDBA14 = N3_VRDBA14 + Round(@nValDepr14, @nCasas14)
                            ##ENDFIELDP26
                            ##FIELDP27( 'SN3.N3_VORIG15' )
                            , N3_VRDME15 = N3_VRDME15 + Round(@nValDepr15, @nCasas15), N3_VRDAC15 = N3_VRDAC15 + Round(@nValDepr15, @nCasas15), N3_VRDBA15 = N3_VRDBA15 + Round(@nValDepr15, @nCasas15)
                            ##ENDFIELDP27
                        Where R_E_C_N_O_ = @iRecnoSN3
                    end else begin
                        Update SN3### 
                        Set N3_NOVO    = @cN3_NOVO, 
                            N3_VRDMES1 = Round(@nValDepr1, @nCasas1), N3_VRDMES2 = Round(@nValDepr2, @nCasas2), N3_VRDMES3 = Round(@nValDepr3, @nCasas3), N3_VRDMES4 = Round(@nValDepr4, @nCasas4), N3_VRDMES5 = Round(@nValDepr5, @nCasas5),
                            N3_VRDACM1 = N3_VRDACM1 + Round(@nValDepr1, @nCasas1), N3_VRDACM2 = N3_VRDACM2 + Round(@nValDepr2, @nCasas2), N3_VRDACM3 = N3_VRDACM3 + Round(@nValDepr3, @nCasas3),
                            N3_VRDACM4 = N3_VRDACM4 + Round(@nValDepr4, @nCasas4), N3_VRDACM5 = N3_VRDACM5 + Round(@nValDepr5, @nCasas5),
                            N3_VRDBAL1 = N3_VRDBAL1 + Round(@nValDepr1, @nCasas1), N3_VRDBAL2 = N3_VRDBAL2 + Round(@nValDepr2, @nCasas2), N3_VRDBAL3 = N3_VRDBAL3 + Round(@nValDepr3, @nCasas3), 
                            N3_VRDBAL4 = N3_VRDBAL4 + Round(@nValDepr4, @nCasas4), N3_VRDBAL5 = N3_VRDBAL5 + Round(@nValDepr5, @nCasas5),
                            N3_VRCMES1 = Round(@nValCor, @nCasas1), N3_VRCACM1 =  N3_VRCACM1 + Round(@nValCor, @nCasas1), N3_VRCBAL1 = N3_VRCBAL1+ Round(@nValCor, @nCasas1),
                            N3_VRCDM1  = Round(@nValCorDep, @nCasas1), N3_VRCDB1 = N3_VRCDB1 + Round(@nValCorDep, @nCasas1), N3_VRCDA1 = N3_VRCDA1 + Round(@nValCorDep, @nCasas1)
                            ##FIELDP18( 'SN3.N3_VORIG6' )
                            , N3_VRDMES6 =  Round(@nValDepr6, @nCasas6), N3_VRDACM6 = N3_VRDACM6 + Round(@nValDepr6, @nCasas6), N3_VRDBAL6 = N3_VRDBAL6 + Round(@nValDepr6, @nCasas6)
                            ##ENDFIELDP18
                            ##FIELDP19( 'SN3.N3_VORIG7' )
                            , N3_VRDMES7 =  Round(@nValDepr7, @nCasas7), N3_VRDACM7 = N3_VRDACM7 + Round(@nValDepr7, @nCasas7), N3_VRDBAL7 = N3_VRDBAL7 + Round(@nValDepr7, @nCasas7)
                            ##ENDFIELDP19
                            ##FIELDP20( 'SN3.N3_VORIG8' )
                            , N3_VRDMES8 = Round(@nValDepr8, @nCasas8), N3_VRDACM8 = N3_VRDACM8 + Round(@nValDepr8, @nCasas8), N3_VRDBAL8 = N3_VRDBAL8 + Round(@nValDepr8, @nCasas8)
                            ##ENDFIELDP20
                            ##FIELDP21( 'SN3.N3_VORIG9' )
                            , N3_VRDMES9 = Round(@nValDepr9, @nCasas9), N3_VRDACM9 = N3_VRDACM9 + Round(@nValDepr9, @nCasas9), N3_VRDBAL9 = N3_VRDBAL9 + Round(@nValDepr9, @nCasas9)
                            ##ENDFIELDP21
                            ##FIELDP22( 'SN3.N3_VORIG10' )
                            , N3_VRDME10 = Round(@nValDepr10, @nCasas10), N3_VRDAC10 = N3_VRDAC10 + Round(@nValDepr10, @nCasas10), N3_VRDBA10 = N3_VRDBA10 + Round(@nValDepr10, @nCasas10)
                            ##ENDFIELDP22
                            ##FIELDP23( 'SN3.N3_VORIG11' )
                            , N3_VRDME11 = Round(@nValDepr11, @nCasas11), N3_VRDAC11 = N3_VRDAC11 + Round(@nValDepr11, @nCasas11), N3_VRDBA11 = N3_VRDBA11 + Round(@nValDepr11, @nCasas11)
                            ##ENDFIELDP23
                            ##FIELDP24( 'SN3.N3_VORIG12' )
                            , N3_VRDME12 = Round(@nValDepr12, @nCasas12), N3_VRDAC12 = N3_VRDAC12 + Round(@nValDepr12, @nCasas12), N3_VRDBA12 = N3_VRDBA12 + Round(@nValDepr12, @nCasas12)
                            ##ENDFIELDP24
                            ##FIELDP25( 'SN3.N3_VORIG13' )
                            , N3_VRDME13 = Round(@nValDepr13, @nCasas13), N3_VRDAC13 = N3_VRDAC13 + Round(@nValDepr13, @nCasas13), N3_VRDBA13 = N3_VRDBA13 + Round(@nValDepr13, @nCasas13)
                            ##ENDFIELDP25
                            ##FIELDP26( 'SN3.N3_VORIG14' )
                            , N3_VRDME14 = Round(@nValDepr14, @nCasas14), N3_VRDAC14 = N3_VRDAC14 + Round(@nValDepr14, @nCasas14), N3_VRDBA14 = N3_VRDBA14 + Round(@nValDepr14, @nCasas14)
                            ##ENDFIELDP26
                            ##FIELDP27( 'SN3.N3_VORIG15' )
                            , N3_VRDME15 = Round(@nValDepr15, @nCasas15), N3_VRDAC15 = N3_VRDAC15 + Round(@nValDepr15, @nCasas15), N3_VRDBA15 = N3_VRDBA15 + Round(@nValDepr15, @nCasas15)
                            ##ENDFIELDP27
                        Where R_E_C_N_O_ = @iRecnoSN3
                    End
                    commit tran
                  
                    Select @nVRDACM1 = N3_VRDACM1, @nVRDACM2 = N3_VRDACM2, @nVRDACM3 = N3_VRDACM3, @nVRDACM4 = N3_VRDACM4, @nVRDACM5 = N3_VRDACM5,
                            @nVORIG1  = N3_VORIG1 , @nVORIG2  = N3_VORIG2,  @nVORIG3  = N3_VORIG3,  @nVORIG4  = N3_VORIG4,  @nVORIG5  = N3_VORIG5,
                            @nAMPLIA1 = N3_AMPLIA1, @nAMPLIA2 = N3_AMPLIA2, @nAMPLIA3 = N3_AMPLIA3, @nAMPLIA4 = N3_AMPLIA4, @nAMPLIA5 = N3_AMPLIA5,
                            @nVRCACM1 = N3_VRCACM1, @nVRCDA1  = N3_VRCDA1,  @cFIMDEPR = N3_FIMDEPR
                        ##FIELDP18( 'SN3.N3_VORIG6' )
                        , @nVRDACM6 = N3_VRDACM6,  @nVORIG6  = N3_VORIG6 , @nAMPLIA6 = N3_AMPLIA6
                        ##ENDFIELDP18
                        ##FIELDP19( 'SN3.N3_VORIG7' )
                        , @nVRDACM7 = N3_VRDACM7,  @nVORIG7  = N3_VORIG7 , @nAMPLIA7 = N3_AMPLIA7
                        ##ENDFIELDP19
                        ##FIELDP20( 'SN3.N3_VORIG8' )
                        , @nVRDACM8 = N3_VRDACM8,  @nVORIG8  = N3_VORIG8, @nAMPLIA8 = N3_AMPLIA8
                        ##ENDFIELDP20
                        ##FIELDP21( 'SN3.N3_VORIG9' )
                        , @nVRDACM9 = N3_VRDACM9,  @nVORIG9  = N3_VORIG9, @nAMPLIA9 = N3_AMPLIA9
                        ##ENDFIELDP21
                        ##FIELDP22( 'SN3.N3_VORIG10' )
                        , @nVRDACM10 = N3_VRDAC10,  @nVORIG10  = N3_VORIG10 , @nAMPLIA10 = N3_AMPLI10
                        ##ENDFIELDP22
                        ##FIELDP23( 'SN3.N3_VORIG11' )
                        , @nVRDACM11 = N3_VRDAC11,  @nVORIG11  = N3_VORIG11, @nAMPLIA11 = N3_AMPLI11
                        ##ENDFIELDP23
                        ##FIELDP24( 'SN3.N3_VORIG12' )
                        , @nVRDACM12 = N3_VRDAC12,  @nVORIG12  = N3_VORIG12, @nAMPLIA12 = N3_AMPLI12
                        ##ENDFIELDP24
                        ##FIELDP25( 'SN3.N3_VORIG13' )
                        , @nVRDACM13 = N3_VRDAC13,  @nVORIG13  = N3_VORIG13 , @nAMPLIA13 = N3_AMPLI13
                        ##ENDFIELDP25
                        ##FIELDP26( 'SN3.N3_VORIG14' )
                        , @nVRDACM14 = N3_VRDAC14,  @nVORIG14  = N3_VORIG14, @nAMPLIA14 = N3_AMPLI14
                        ##ENDFIELDP26
                        ##FIELDP27( 'SN3.N3_VORIG15' )
                        , @nVRDACM15 = N3_VRDAC15,  @nVORIG15  = N3_VORIG15, @nAMPLIA15 = N3_AMPLI15
                        ##ENDFIELDP27
                    From SN3### 
                    Where R_E_C_N_O_ = @iRecnoSN3
                        AND N3_FIMDEPR = ' '
                        AND D_E_L_E_T_ = ' '
                  
                    If @IN_MOEDAATF = '01' begin
                        select @nValorOrig = @nVORIG1 + @nVRCACM1 + @nAMPLIA1
                        select @nValorAcum = @nVRDACM1 + @nVRCDA1
                        select @nCasasAtf = @nCasas1
                    End
                    If @IN_MOEDAATF = '02' begin
                        select @nValorOrig = @nVORIG2 + @nAMPLIA2
                        select @nValorAcum = @nVRDACM2
                        select @nCasasAtf = @nCasas2
                    End
                    If @IN_MOEDAATF = '03' begin
                        select @nValorOrig = @nVORIG3 + @nAMPLIA3
                        select @nValorAcum = @nVRDACM3
                        select @nCasasAtf = @nCasas3
                    end
                    If @IN_MOEDAATF = '04' begin
                        select @nValorOrig = @nVORIG4 + @nAMPLIA4
                        select @nValorAcum = @nVRDACM4
                        select @nCasasAtf = @nCasas4
                    end
                    If @IN_MOEDAATF = '05' begin
                        select @nValorOrig = @nVORIG5 + @nAMPLIA5
                        select @nValorAcum = @nVRDACM5
                        select @nCasasAtf = @nCasas5
                    end
                    ##FIELDP18( 'SN3.N3_VORIG6' )
                        select @nValorOrig = @nVORIG6 + @nAMPLIA6
                        select @nValorAcum = @nVRDACM6
                        select @nCasasAtf = @nCasas6
                    ##ENDFIELDP18
                    ##FIELDP19( 'SN3.N3_VORIG7' )
                        select @nValorOrig = @nVORIG7 + @nAMPLIA7
                        select @nValorAcum = @nVRDACM7
                        select @nCasasAtf = @nCasas7
                    ##ENDFIELDP19
                    ##FIELDP20( 'SN3.N3_VORIG8' )
                        select @nValorOrig = @nVORIG8 + @nAMPLIA8
                        select @nValorAcum = @nVRDACM8
                        select @nCasasAtf = @nCasas8
                    ##ENDFIELDP20
                    ##FIELDP21( 'SN3.N3_VORIG9' )
                        select @nValorOrig = @nVORIG9 + @nAMPLIA9
                        select @nValorAcum = @nVRDACM9
                        select @nCasasAtf = @nCasas9
                    ##ENDFIELDP21
                    ##FIELDP22( 'SN3.N3_VORIG10' )
                        select @nValorOrig = @nVORIG10 + @nAMPLIA10
                        select @nValorAcum = @nVRDACM10
                        select @nCasasAtf = @nCasas10
                    ##ENDFIELDP22
                    ##FIELDP23( 'SN3.N3_VORIG11' )
                        select @nValorOrig = @nVORIG11 + @nAMPLIA11
                        select @nValorAcum = @nVRDACM11
                        select @nCasasAtf = @nCasas11
                    ##ENDFIELDP23
                    ##FIELDP24( 'SN3.N3_VORIG12' )
                        select @nValorOrig = @nVORIG12 + @nAMPLIA12
                        select @nValorAcum = @nVRDACM12
                        select @nCasasAtf = @nCasas12
                    ##ENDFIELDP24
                    ##FIELDP25( 'SN3.N3_VORIG13' )
                        select @nValorOrig = @nVORIG13 + @nAMPLIA13
                        select @nValorAcum = @nVRDACM13
                        select @nCasasAtf = @nCasas13
                    ##ENDFIELDP25
                    ##FIELDP26( 'SN3.N3_VORIG14' )
                        select @nValorOrig = @nVORIG14 + @nAMPLIA14
                        select @nValorAcum = @nVRDACM14
                        select @nCasasAtf = @nCasas14
                    ##ENDFIELDP26
                    ##FIELDP27( 'SN3.N3_VORIG15' )
                        select @nValorOrig = @nVORIG15 + @nAMPLIA15
                        select @nValorAcum = @nVRDACM15
                        select @nCasasAtf = @nCasas15
                    ##ENDFIELDP27
                    
                    /* --------------------------------------------------------------------------
                        Grava N3_FIMDEPR
                        -------------------------------------------------------------------------- */
                    If @cFIMDEPR = ' ' and @cN3_FIMDEPR = ' ' begin
                        If @iRecnoTp07 is null Select @iRecnoTp07 = 0
                        Exec ATF014_## @cN3_TIPO,  @cN3_TPDEPR,  @IN_DATADEP, @cN3_DINDEPR, @IN_CALCDEP, @iN3_PERDEPR, @iRecnoSN3,  @iRecnoTp07, @nCasas1,
                                    @nCasasAtf, @nVORIG1,     @nVRCACM1,   @nAMPLIA1,    @nVRDACM1,   @nVRCDA1,     @nValorOrig, @nValorAcum, @nValor1,
                                    @nValorX,   @nN3_VLSALV1, @nN3_VMXDEPR
                    End
                    /* --------------------------------------------------------------------------
                        Depreciacao incentivada
                        -------------------------------------------------------------------------- */
                    If @cN3_TIPO = '08' and @IN_CPAISLOC = 'BRA' begin
                        /* --------------------------------------------------------------------------
                        Verifica se o registro do tipo '01' existe
                        -------------------------------------------------------------------------- */            
                        If @iRecnoAux is null begin
                        Select @nVORIG1_TP01 = N3_VORIG1, @nVRCACM1_TP01 = N3_VRCACM1, @nVRDACM1_TP01 = N3_VRDACM1, @nVRCDA1_TP01 = N3_VRCDA1
                            From SN3### 
                            Where N3_FILIAL  = @cFilial
                            AND N3_CBASE   = @cN3_CBASE
                            AND N3_ITEM    = @cN3_ITEM
                            AND N3_TIPO    = '01'
                            AND ( N3_BAIXA = ' ' OR N3_BAIXA  = '0' )
                            AND N3_SEQ     = '001'
                            AND D_E_L_E_T_ = ' '
                        /* --------------------------------------------------------------------------
                            Dep Ac Tipo01+ Dep Ac Tipo08 >= VOrig Tipo01
                            -------------------------------------------------------------------------- */
                        If ((@nVRDACM1_TP01 + @nVRCDA1_TP01) + (@nVRDACM1 + @nVRCDA1)) >= (@nVORIG1_TP01 + @nVRCACM1_TP01 ) begin
                            If @iRecnoSN1 is not null begin
                                Select @iRecnoSNG  = NULL
                                Select @iRecnoSNG = R_E_C_N_O_
                                From SNG### 
                                Where NG_FILIAL  = @cFilial_SNG
                                    and NG_GRUPO   = @cN1_GRUPO
                                    and D_E_L_E_T_ = ' '
                              
                                If @iRecnoSNG is not null begin
                                    Select @cN3_CCUSTO  = NG_CCUSTO,  @cN3_SUBCTA  = NG_SUBCTA,  @cN3_CLVL    = NG_CLVL,   @cN3_CCONTAB  = NG_CCONTAB,
                                        @cN3_CDEPREC = NG_CDEPREC, @cN3_CCDEPR  = NG_CCDEPR,  @cN3_CDESP   = NG_CDESP,  @cN3_CCORREC  = NG_CCORREC,
                                        @cN3_CUSTBEM = NG_CUSTBEM, @cN3_CCDESP  = NG_CCDESP,  @cN3_CCCDEP  = NG_CCCDEP, @cN3_CCCDES   = NG_CCCDES,
                                        @cN3_CCCORR  = NG_CCCORR,  @cN3_SUBCCON = NG_SUBCCON, @cN3_SUBCDEP = NG_SUBCDEP, @cN3_SUBCCDE = NG_SUBCCDE,
                                        @cN3_SUBCDES = NG_SUBCDES, @cN3_SUBCCOR = NG_SUBCCOR, @cN3_CLVLCON = NG_CLVLCON, @cN3_CLVLDEP = NG_CLVLDEP,
                                        @cN3_CLVLCDE = NG_CLVLCDE, @cN3_CLVLDES = NG_CLVLDES, @cN3_CLVLCOR = NG_CLVLCOR, @nN3_TXDEPR1 = NG_TXDEPR1,
                                        @nN3_TXDEPR2 = NG_TXDEPR2, @nN3_TXDEPR3 = NG_TXDEPR3, @nN3_TXDEPR4 = NG_TXDEPR4, @nN3_TXDEPR5 = NG_TXDEPR5
                                        ##FIELDP18( 'SN3.N3_VORIG6' )
                                        , @nN3_TXDEPR6 = NG_TXDEPR6
                                        ##ENDFIELDP18
                                        ##FIELDP19( 'SN3.N3_VORIG7' )
                                        , @nN3_TXDEPR7 = NG_TXDEPR7
                                        ##ENDFIELDP19
                                        ##FIELDP20( 'SN3.N3_VORIG8' )
                                        , @nN3_TXDEPR8 = NG_TXDEPR8
                                        ##ENDFIELDP20
                                        ##FIELDP21( 'SN3.N3_VORIG9' )
                                        , @nN3_TXDEPR9 = NG_TXDEPR9
                                        ##ENDFIELDP21
                                        ##FIELDP22( 'SN3.N3_VORIG10' )
                                        , @nN3_TXDEPR10 = NG_TXDEP10
                                        ##ENDFIELDP22
                                        ##FIELDP23( 'SN3.N3_VORIG11' )
                                        , @nN3_TXDEPR11 = NG_TXDEP11
                                        ##ENDFIELDP23
                                        ##FIELDP24( 'SN3.N3_VORIG12' )
                                        , @nN3_TXDEPR12 = NG_TXDEP12
                                        ##ENDFIELDP24
                                        ##FIELDP25( 'SN3.N3_VORIG13' )
                                        , @nN3_TXDEPR13 = NG_TXDEP13
                                        ##ENDFIELDP25
                                        ##FIELDP26( 'SN3.N3_VORIG14' )
                                        , @nN3_TXDEPR14 = NG_TXDEP14
                                        ##ENDFIELDP26
                                        ##FIELDP27( 'SN3.N3_VORIG15' )
                                        , @nN3_TXDEPR15 = NG_TXDEP15
                                        ##ENDFIELDP27
                                    From SNG### 
                                    Where R_E_C_N_O_ = @iRecnoSNG
                                End
                            End
                            Exec AF050CAL_##
                            Select @cN3_SEQ  = Substring(Max( N3_SEQ ), 1,3)
                                From SN3### 
                            Where N3_FILIAL  = @cFilial
                                and N3_CBASE   = @cN3_CBASE
                                and N3_ITEM    = @cN3_ITEM
                                and ( N3_BAIXA = ' ' OR N3_BAIXA  = '0' )
                                and D_E_L_E_T_ = ' '
                           
                            Select @iSeq     = Convert( integer, @cN3_SEQ ) + 1
                            Select @iAux     = 3 
                            exec MSSTRZERO @iSeq, @iAux, @cN3_SEQ OutPut
                           
                            Select @cN3_BAIXA = '0'
                            Select @cN3_NOVO  = 'S'
                            select @cHistor  = 'DEPRECIACAO ACEL. INCENTIVADA REVERSA'
                            select @cN3_TIPO = '09'
						   
						    /* ----------------------------------------------------------------------------------
                                Tratamento para o OpenEdge
							    ---------------------------------------------------------------------------------- */
                            ##IF_001({|| AllTrim(Upper(TcGetDB())) <> "OPENEDGE" })
						        select @cN3_DINDEPR = Convert( char( 08 ), dateadd( day, 1, @IN_DATADEP ), 112 )
						    ##ELSE_001
						        EXEC MSDATEADD 'DAY', 1, @IN_DATADEP, @cN3_DINDEPR OutPut
						    ##ENDIF_001
                           
                            select @iRecnoSN3_TP09 = IsNull(Max( R_E_C_N_O_ ), 0 ) from SN3### 
                            select @iRecnoSN3_TP09 = @iRecnoSN3_TP09 + 1
                            begin tran
                            ##TRATARECNO @iRecnoSN3_TP09\
                            Insert into SN3### (N3_FILIAL,  N3_CBASE,   N3_ITEM,    N3_TIPO,    N3_VORIG1,  N3_VORIG2,  N3_VORIG3,  N3_VORIG4,  N3_VORIG5,  N3_HISTOR,
                                                N3_CCUSTO,  N3_SUBCTA,  N3_CLVL,    N3_CCONTAB, N3_CDEPREC, N3_CCDEPR,  N3_CDESP,   N3_CCORREC, N3_CUSTBEM, N3_CCDESP,
                                                N3_CCCDEP,  N3_CCCDES,  N3_CCCORR,  N3_SUBCCON, N3_SUBCDEP, N3_SUBCCDE, N3_SUBCDES, N3_SUBCCOR, N3_CLVLCON, N3_CLVLDEP,
                                                N3_CLVLCDE, N3_CLVLDES, N3_CLVLCOR, N3_DINDEPR, N3_SEQ,     N3_BAIXA,   N3_NOVO,    N3_TXDEPR1, N3_TXDEPR2, N3_TXDEPR3,
                                                N3_TXDEPR4, N3_TXDEPR5, N3_AQUISIC, R_E_C_N_O_ 
                                                ##FIELDP18( 'SN3.N3_VORIG6' )
                                                , N3_VORIG6, N3_TXDEPR6 
                                                ##ENDFIELDP18
                                                ##FIELDP19( 'SN3.N3_VORIG7' )
                                                , N3_VORIG7, N3_TXDEPR7
                                                ##ENDFIELDP19
                                                ##FIELDP20( 'SN3.N3_VORIG8' )
                                                , N3_VORIG8, N3_TXDEPR8 
                                                ##ENDFIELDP20
                                                ##FIELDP21( 'SN3.N3_VORIG9' )
                                                , N3_VORIG9, N3_TXDEPR9
                                                ##ENDFIELDP21
                                                ##FIELDP22( 'SN3.N3_VORIG10' )
                                                , N3_VORIG10, N3_TXDEP10
                                                ##ENDFIELDP22
                                                ##FIELDP23( 'SN3.N3_VORIG11' )
                                                , N3_VORIG11, N3_TXDEP11
                                                ##ENDFIELDP23
                                                ##FIELDP24( 'SN3.N3_VORIG12' )
                                                , N3_VORIG12, N3_TXDEP12
                                                ##ENDFIELDP24
                                                ##FIELDP25( 'SN3.N3_VORIG13' )
                                                , N3_VORIG13, N3_TXDEP13
                                                ##ENDFIELDP25
                                                ##FIELDP26( 'SN3.N3_VORIG14' )
                                                , N3_VORIG14, N3_TXDEP14
                                                ##ENDFIELDP26
                                                ##FIELDP27( 'SN3.N3_VORIG15' )
                                                , N3_VORIG15, N3_TXDEP15 
                                                ##ENDFIELDP27
                                                )
                                        Values (@cFilial,     @cN3_CBASE,   @cN3_ITEM,    @cN3_TIPO,    @nN3_VORIG1,  @nN3_VORIG2,  @nN3_VORIG3,  @nN3_VORIG4,  @nN3_VORIG5,  @cHistor,
                                                @cN3_CCUSTO,  @cN3_SUBCTA,  @cN3_CLVL,    @cN3_CCONTAB, @cN3_CDEPREC, @cN3_CCDEPR,  @cN3_CDESP,   @cN3_CCORREC, @cN3_CUSTBEM, @cN3_CCDESP,
                                                @cN3_CCCDEP,  @cN3_CCCDES,  @cN3_CCCORR,  @cN3_SUBCCON, @cN3_SUBCDEP, @cN3_SUBCCDE, @cN3_SUBCDES, @cN3_SUBCCOR, @cN3_CLVLCON, @cN3_CLVLDEP,
                                                @cN3_CLVLCDE, @cN3_CLVLDES, @cN3_CLVLCOR, @cN3_DINDEPR, @cN3_SEQ,     @cN3_BAIXA,   @cN3_NOVO,    @nN3_TXDEPR1, @nN3_TXDEPR2, @nN3_TXDEPR3,
                                                @nN3_TXDEPR4, @nN3_TXDEPR5, @cN3_DINDEPR, @iRecnoSN3_TP09
                                                ##FIELDP18( 'SN3.N3_VORIG6' )
                                                , @nN3_VORIG6, @nN3_TXDEPR6 
                                                ##ENDFIELDP18
                                                ##FIELDP19( 'SN3.N3_VORIG7' )
                                                , @nN3_VORIG7, @nN3_TXDEPR7
                                                ##ENDFIELDP19
                                                ##FIELDP20( 'SN3.N3_VORIG8' )
                                                , @nN3_VORIG8, @nN3_TXDEPR8 
                                                ##ENDFIELDP20
                                                ##FIELDP21( 'SN3.N3_VORIG9' )
                                                , @nN3_VORIG9, @nN3_TXDEPR9
                                                ##ENDFIELDP21
                                                ##FIELDP22( 'SN3.N3_VORIG10' )
                                                , @nN3_VORIG10, @nN3_TXDEPR10
                                                ##ENDFIELDP22
                                                ##FIELDP23( 'SN3.N3_VORIG11' )
                                                , @nN3_VORIG11, @nN3_TXDEPR11
                                                ##ENDFIELDP23
                                                ##FIELDP24( 'SN3.N3_VORIG12' )
                                                , @nN3_VORIG12, @nN3_TXDEPR12
                                                ##ENDFIELDP24
                                                ##FIELDP25( 'SN3.N3_VORIG13' )
                                                , @nN3_VORIG13, @nN3_TXDEPR13
                                                ##ENDFIELDP25
                                                ##FIELDP26( 'SN3.N3_VORIG14' )
                                                , @nN3_VORIG14, @nN3_TXDEPR14
                                                ##ENDFIELDP26
                                                ##FIELDP27( 'SN3.N3_VORIG15' )
                                                , @nN3_VORIG15, @nN3_TXDEPR15 
                                                ##ENDFIELDP27
                                                 )
                            ##FIMTRATARECNO
                            commit tran
                        End
                        End
                    End
                    ---ATF013  -- GRAVA SALDOS DO ATIVO
                    Exec ATF013_## @cFilial,     @cN3_CBASE,   @cN3_ITEM,   @cN3_TIPO,    @IN_LCUSTO,   @IN_LITEM,    @IN_LCLVL,    @IN_DATADEP,  @cN3_CCORREC,
                                    @cN3_SUBCCOR, @cN3_CLVLCOR, @cN3_CCCORR, @cN3_CCONTAB, @cN3_SUBCCON, @cN3_CLVLCON, @cN3_CUSTBEM, @cN3_CDEPREC, @cN3_SUBCDEP,
                                    @cN3_CLVLDEP, @cN3_CCDESP,  @cN3_CCDEPR, @cN3_SUBCCDE, @cN3_CLVLCDE, @cN3_CCCDEP,  @cN3_CDESP,   @cN3_SUBCDES, @cN3_CLVLDES,
                                    @cN3_CCCDES,  @nTxMedia,    @nValCor,    @nValCorDep,  @nValDepr1,   @nValDepr2,   @nValDepr3,   @nValDepr4,   @nValDepr5,
                                    @cN3_TPSALDO, @nCasas1,     @nCasas2,    @nCasas3,     @nCasas4,     @nCasas5
                                    ##FIELDP18( 'SN3.N3_VORIG6' )
                                    ,  @nValDepr6,  @nCasas6
                                    ##ENDFIELDP18
                                    ##FIELDP19( 'SN3.N3_VORIG7' )
                                    ,  @nValDepr7,  @nCasas7
                                    ##ENDFIELDP19
                                    ##FIELDP20( 'SN3.N3_VORIG8' )
                                    ,  @nValDepr8,  @nCasas8
                                    ##ENDFIELDP20
                                    ##FIELDP21( 'SN3.N3_VORIG9' )
                                    ,  @nValDepr9,  @nCasas9
                                    ##ENDFIELDP21
                                    ##FIELDP22( 'SN3.N3_VORIG10' )
                                    ,  @nValDepr10,  @nCasas10
                                    ##ENDFIELDP22
                                    ##FIELDP23( 'SN3.N3_VORIG11' )
                                    ,  @nValDepr11,  @nCasas11
                                    ##ENDFIELDP23
                                    ##FIELDP24( 'SN3.N3_VORIG12' )
                                    ,  @nValDepr12,  @nCasas12
                                    ##ENDFIELDP24
                                    ##FIELDP25( 'SN3.N3_VORIG13' )
                                    ,  @nValDepr13,  @nCasas13
                                    ##ENDFIELDP25
                                    ##FIELDP26( 'SN3.N3_VORIG14' )
                                    ,  @nValDepr14,  @nCasas14
                                    ##ENDFIELDP26
                                    ##FIELDP27( 'SN3.N3_VORIG15' )
                                    ,  @nValDepr15,  @nCasas15
                                    ##ENDFIELDP27
                    /* ----------------------------------------------------------------------------------
                        Ponto de entrada - AF050CAL
                        ---------------------------------------------------------------------------------- */
                    Exec AF050CAL_##
                End
            End
            End
        End
        SELECT @fim_CUR = 0
        Fetch CUR_ATF050 into
            @cN3_CBASE,   @cN3_ITEM,    @cN3_TIPO,    @cN3_SEQ,     @cN3_TPDEPR,  @cN3_DEPREC,  @cN3_CCORREC, @cN3_CCCORR,  @cN3_SUBCCOR, @cN3_BAIXA,
            @nN3_VRDACM1, @nVRDACM2, @nVRDACM3, @nVRDACM4, @nVRDACM5
            ##FIELDP18( 'SN3.N3_VORIG6' )
            , @nVRDACM6
            ##ENDFIELDP18
            ##FIELDP19( 'SN3.N3_VORIG7' )
            , @nVRDACM7
            ##ENDFIELDP19
            ##FIELDP20( 'SN3.N3_VORIG8' )
            , @nVRDACM8
            ##ENDFIELDP20
            ##FIELDP21( 'SN3.N3_VORIG9' )
            , @nVRDACM9
            ##ENDFIELDP21
            ##FIELDP22( 'SN3.N3_VORIG10' )
            , @nVRDACM10
            ##ENDFIELDP22
            ##FIELDP23( 'SN3.N3_VORIG11' )
            , @nVRDACM11
            ##ENDFIELDP23
            ##FIELDP24( 'SN3.N3_VORIG12' )
            , @nVRDACM12
            ##ENDFIELDP24
            ##FIELDP25( 'SN3.N3_VORIG13' )
            , @nVRDACM13
            ##ENDFIELDP25
            ##FIELDP26( 'SN3.N3_VORIG14' )
            , @nVRDACM14
            ##ENDFIELDP26
            ##FIELDP27( 'SN3.N3_VORIG15' )
            , @nVRDACM15
            ##ENDFIELDP27
            , @nVRCACM1, @nN3_VORIG1,  @nN3_VORIG2,  @nN3_VORIG3,  @nN3_VORIG4,  @nN3_VORIG5,
            @nN3_TXDEPR1, @nN3_TXDEPR2, @nN3_TXDEPR3, @nN3_TXDEPR4, @nN3_TXDEPR5, @nN3_VRCDA1,  @cN3_AQUISIC, @cN3_DTBAIXA, @cN3_DINDEPR, @cN3_CCUSTO,
            @cN3_CCONTAB, @cN3_CCCDEP,  @cN3_SUBCCDE, @cN3_CDEPREC, @cN3_SUBCDEP, @cN3_CCCDES,  @cN3_SUBCDES, @cN3_NOVO,    @cN3_CLVLCON,
            @cN3_CUSTBEM, @cN3_CLVLDEP, @cN3_CCDESP,  @cN3_CCDEPR,  @cN3_CLVLCDE, @cN3_CDESP,   @cN3_CLVLDES, @cN3_SUBCTA,  @cN3_CLVL,
            @cN3_SUBCCON, @cN3_CLVLCOR, @cN3_SEQREAV, @cFilial,     @iRecnoSN3,   @cN3_FIMDEPR
            ##FIELDP06( 'SN3.N3_PRODANC;N3_YTD' )
                , @nN3_PRODANC, @nN3_YTD
            ##ENDFIELDP06
            ##FIELDP07( 'SN3.N3_DTACELE;N3_VLACEL1;N3_VLACEL2;N3_VLACEL3;N3_VLACEL4;N3_VLACEL5' )
                , @cN3_DTACELE, @nN3_VLACEL1, @nN3_VLACEL2, @nN3_VLACEL3, @nN3_VLACEL4, @nN3_VLACEL5
            ##ENDFIELDP07
            ##FIELDP10( 'SN3.N3_PERDEPR;N3_PRODMES;N3_PRODANO;N3_VMXDEPR;N3_VLSALV1' )
                , @iN3_PERDEPR, @nN3_PRODMES, @nN3_PRODANO, @nN3_VMXDEPR, @nN3_VLSALV1
            ##ENDFIELDP10
            ##FIELDP13( 'SN3.N3_TPSALDO' )
                , @cN3_TPSALDO
            ##ENDFIELDP13
            ##FIELDP16( 'SN3.N3_CODIND' )
                , @cN3_CODIND
            ##ENDFIELDP16
            ##FIELDP18( 'SN3.N3_VORIG6' )
            ,@nN3_VORIG6, @nN3_TXDEPR6, @nN3_VLACEL6
            ##ENDFIELDP18
            ##FIELDP19( 'SN3.N3_VORIG7' )
            ,@nN3_VORIG7, @nN3_TXDEPR7, @nN3_VLACEL7
            ##ENDFIELDP19
            ##FIELDP20( 'SN3.N3_VORIG8' )
            ,@nN3_VORIG8, @nN3_TXDEPR8, @nN3_VLACEL8
            ##ENDFIELDP20
            ##FIELDP21( 'SN3.N3_VORIG9' )
            ,@nN3_VORIG9, @nN3_TXDEPR9, @nN3_VLACEL9
            ##ENDFIELDP21
            ##FIELDP22( 'SN3.N3_VORIG10' )
            ,@nN3_VORIG10, @nN3_TXDEPR10, @nN3_VLACEL10
            ##ENDFIELDP22
            ##FIELDP23( 'SN3.N3_VORIG11' )
            ,@nN3_VORIG11, @nN3_TXDEPR11, @nN3_VLACEL11
            ##ENDFIELDP23
            ##FIELDP24( 'SN3.N3_VORIG12' )
            ,@nN3_VORIG12, @nN3_TXDEPR12, @nN3_VLACEL12
            ##ENDFIELDP24
            ##FIELDP25( 'SN3.N3_VORIG13' )
            ,@nN3_VORIG13, @nN3_TXDEPR13, @nN3_VLACEL13
            ##ENDFIELDP25
            ##FIELDP26( 'SN3.N3_VORIG14' )
            ,@nN3_VORIG14, @nN3_TXDEPR14, @nN3_VLACEL14
            ##ENDFIELDP26
            ##FIELDP27( 'SN3.N3_VORIG15' )
            ,@nN3_VORIG15, @nN3_TXDEPR15, @nN3_VLACEL15
            ##ENDFIELDP27
			,@nAMPLIA1
    End
    close CUR_ATF050
    deallocate CUR_ATF050
    select @OUT_RESULTADO = '1'
end
