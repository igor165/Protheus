Create Procedure ATF004_##
(
   @IN_FILIAL   Char( 'N5_FILIAL' ),
   @IN_LCUSTO   Char( 01 ),
   @IN_LITEM    Char( 01 ),
   @IN_LCLVL    Char( 01 ),
 	@IN_CONTA    Char( 'N5_CONTA' ),
   @IN_DATA     Char( 08 ),
   @IN_TIPO     Char( 'N5_TIPO' ),
   @IN_VALOR1   Float,
   @IN_VALOR2   Float,
   @IN_VALOR3   Float,
   @IN_VALOR4   Float,
   @IN_VALOR5   Float,
   @IN_SINAL    Char( 01 ),
   @IN_TAXA     Float,
	@IN_SUBCTA   Char( 'N4_SUBCTA' ),
   @IN_CLVL     Char( 'N4_CLVL' ),
   @IN_CUSTO    Char( 'N4_CCUSTO' ),
   @IN_TIPOCNT  Char( 'N4_TIPOCNT' ),    --tipo de conta
   @IN_PROGRAMA Char( 10 ),
   @IN_TPBEM    Char( 02 ),
   @IN_TPSALDO  Char( 01 ),
   @IN_CASA1    Integer,
   @IN_CASA2    Integer,
   @IN_CASA3    Integer,
   @IN_CASA4    Integer,
   @IN_CASA5    Integer
    ##FIELDP05( 'SN3.N3_VORIG6' )
    , @IN_VALOR6   Float
    , @IN_CASA6    Integer
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG7' )
    , @IN_VALOR7   Float
    , @IN_CASA7    Integer
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG8' )
    , @IN_VALOR8   Float
    , @IN_CASA8    Integer
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG9' )
    , @IN_VALOR9   Float
    , @IN_CASA9    Integer
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG10' )
    , @IN_VALOR10   Float
    , @IN_CASA10    Integer
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG11' )
    , @IN_VALOR11   Float
    , @IN_CASA11    Integer
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG12' )
    , @IN_VALOR12   Float
    , @IN_CASA12    Integer
    ##ENDFIELDP11
    ##FIELDP12( 'SN3.N3_VORIG13' )
    , @IN_VALOR13   Float
    , @IN_CASA13    Integer
    ##ENDFIELDP12
    ##FIELDP13( 'SN3.N3_VORIG14' )
    , @IN_VALOR14   Float
    , @IN_CASA14    Integer
    ##ENDFIELDP13
    ##FIELDP14( 'SN3.N3_VORIG15' )
    , @IN_VALOR15   Float
    , @IN_CASA15    Integer
    ##ENDFIELDP14
 )

as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ATFA050.PRW </s>
    Descricao       - <d>  Gera linha de movimentos no SN4 </d>
    Funcao do Siga  -      AtfSaldo - Atualizacao de Saldos
    Entrada         - <ri> @IN_FILIAL  - Filial
                           @IN_LCUSTO  - Flag se existe custo
                           @IN_LITEM   - Flag se existe Item
                           @IN_LCLVL   - Flag se existe clvl
                         	@IN_CONTA   - Conta a Atualizar
                           @IN_DATA    - Data do movimento
                           @IN_TIPO    - tipo de movimento
                           @IN_VALOR1  - Vlr na Moeda1
                           @IN_VALOR2  - Vlr na Moeda2
                           @IN_VALOR3  - Vlr na Moeda3
                           @IN_VALOR4  - Vlr na Moeda4
                           @IN_VALOR5  - Vlr na Moeda5
                           @IN_SINAL   - Sinal
                           @IN_TAXA    - Taxa de conversao do vlr
                        	@IN_SUBCTA  - subconta ( item )
                           @IN_CLVL    - Classe de valor
                           @IN_CUSTO   - CCusto
                           @IN_TIPOCNT - Tipo de conta
                           @IN_PROGRAMA - Programa
                           @IN_TPBEM    - Tipo de Bem - SAUDE
                           @IN_TPSALDO  - tipo de saldo </ri>
                           @IN_CASA1   - Casas Decimais moeda 1
                           @IN_CASA2   - Casas Decimais moeda 2
                           @IN_CASA3   - Casas Decimais moeda 3
                           @IN_CASA4   - Casas Decimais moeda 4
                           @IN_CASA5   - Casas Decimais moeda 5 </ri>
    Saida           - <o>    </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     01/09/2006
-------------------------------------------------------------------------------------- */

Declare @nValor1     Float
Declare @nValor2     Float
Declare @nValor3     Float
Declare @nValor4     Float
Declare @nValor5     Float
Declare @nValXX1     Float
Declare @nValXX2     Float
Declare @nValXX3     Float
Declare @nValXX4     Float
Declare @nValXX5     Float
Declare @nTaxa       Float
Declare @iRecno      Integer
Declare @cAux        Char( 03 )
Declare @cFilial_SN5 Char( 'N5_FILIAL' )
Declare @cFilial_SNC Char( 'N5_FILIAL' )
Declare @cFilial_SN6 Char( 'N5_FILIAL' )
Declare @cFilial_SNA Char( 'N5_FILIAL' )
Declare @cConta      Char( 'N5_CONTA' )
Declare @cSinal      Char( 01 )
Declare @cTipo       Char( 'N5_TIPO' )
Declare @cTabela     Char( 03 )
##FIELDP05( 'SN3.N3_VORIG6' )
Declare @nValor6     Float
Declare @nValXX6     Float
##ENDFIELDP05
##FIELDP06( 'SN3.N3_VORIG7' )
Declare @nValor7     Float
Declare @nValXX7     Float
##ENDFIELDP06
##FIELDP07( 'SN3.N3_VORIG8' )
Declare @nValor8     Float
Declare @nValXX8     Float
##ENDFIELDP07
##FIELDP08( 'SN3.N3_VORIG9' )
Declare @nValor9     Float
Declare @nValXX9     Float
##ENDFIELDP08
##FIELDP09( 'SN3.N3_VORIG10' )
Declare @nValor10     Float
Declare @nValXX10     Float
##ENDFIELDP09
##FIELDP10( 'SN3.N3_VORIG11' )
Declare @nValor11     Float
Declare @nValXX11     Float
##ENDFIELDP10
##FIELDP11( 'SN3.N3_VORIG12' )
Declare @nValor12     Float
Declare @nValXX12     Float
##ENDFIELDP11
##FIELDP12( 'SN3.N3_VORIG13' )
Declare @nValor13     Float
Declare @nValXX13     Float
##ENDFIELDP12
##FIELDP13( 'SN3.N3_VORIG14' )
Declare @nValor14     Float
Declare @nValXX14     Float
##ENDFIELDP13
##FIELDP14( 'SN3.N3_VORIG15' )
Declare @nValor15     Float
Declare @nValXX15     Float
##ENDFIELDP14
begin
   
    Select @nValor1  = @IN_VALOR1
    Select @nValor2  = @IN_VALOR2
    Select @nValor3  = @IN_VALOR3
    Select @nValor4  = @IN_VALOR4
    Select @nValor5  = @IN_VALOR5
    ##FIELDP05( 'SN3.N3_VORIG6' )
    Select @nValor6  = @IN_VALOR6
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG7' )
    Select @nValor7  = @IN_VALOR7
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG8' )
    Select @nValor8  = @IN_VALOR8
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG9' )
    Select @nValor9  = @IN_VALOR9
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG10' )
    Select @nValor10  = @IN_VALOR10
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG11' )
    Select @nValor11  = @IN_VALOR11
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG12' )
    Select @nValor12  = @IN_VALOR12
    ##ENDFIELDP11
    ##FIELDP12( 'SN3.N3_VORIG13' )
    Select @nValor13  = @IN_VALOR13
    ##ENDFIELDP12
    ##FIELDP13( 'SN3.N3_VORIG14' )
    Select @nValor14  = @IN_VALOR14
    ##ENDFIELDP13
    ##FIELDP14( 'SN3.N3_VORIG15' )
    Select @nValor15  = @IN_VALOR15
    ##ENDFIELDP14

    If ((@nValor1 + @nValor2 + @nValor3 + @nValor4 + @nValor5
                    ##FIELDP05( 'SN3.N3_VORIG6' )
                     + @nValor6
                    ##ENDFIELDP05
                    ##FIELDP06( 'SN3.N3_VORIG7' )
                     + @nValor7
                    ##ENDFIELDP06
                    ##FIELDP07( 'SN3.N3_VORIG8' )
                     + @nValor8
                    ##ENDFIELDP07
                    ##FIELDP08( 'SN3.N3_VORIG9' )
                     + @nValor9
                    ##ENDFIELDP08
                    ##FIELDP09( 'SN3.N3_VORIG10' )
                     + @nValor10
                    ##ENDFIELDP09
                    ##FIELDP10( 'SN3.N3_VORIG11' )
                     + @nValor11
                    ##ENDFIELDP10
                    ##FIELDP11( 'SN3.N3_VORIG12' )
                     + @nValor12
                    ##ENDFIELDP11
                    ##FIELDP12( 'SN3.N3_VORIG13' )
                     + @nValor13
                    ##ENDFIELDP12
                    ##FIELDP13( 'SN3.N3_VORIG14' )
                     + @nValor14
                    ##ENDFIELDP13
                    ##FIELDP14( 'SN3.N3_VORIG15' )
                     + @nValor15
                    ##ENDFIELDP14 ) != 0 ) and @IN_CONTA != ' ' and @IN_DATA != ' ' begin
        Select @nValXX1  = 0
        Select @nValXX2  = 0
        Select @nValXX3  = 0
        Select @nValXX4  = 0
        Select @nValXX5  = 0
        Select @nTaxa    = @IN_TAXA
        Select @iRecno   = null
        Select @cConta   = @IN_CONTA
        Select @cSinal   = @IN_SINAL
        Select @cTipo    = ' '
        ##FIELDP05( 'SN3.N3_VORIG6' )
        Select @nValXX6  = 0
        ##ENDFIELDP05
        ##FIELDP06( 'SN3.N3_VORIG7' )
        Select @nValXX7  = 0
        ##ENDFIELDP06
        ##FIELDP07( 'SN3.N3_VORIG8' )
        Select @nValXX8  = 0
        ##ENDFIELDP07
        ##FIELDP08( 'SN3.N3_VORIG9' )
        Select @nValXX9  = 0
        ##ENDFIELDP08
        ##FIELDP09( 'SN3.N3_VORIG10' )
        Select @nValXX10  = 0
        ##ENDFIELDP09
        ##FIELDP10( 'SN3.N3_VORIG11' )
        Select @nValXX11  = 0
        ##ENDFIELDP10
        ##FIELDP11( 'SN3.N3_VORIG12' )
        Select @nValXX12  = 0
        ##ENDFIELDP11
        ##FIELDP12( 'SN3.N3_VORIG13' )
        Select @nValXX13  = 0
        ##ENDFIELDP12
        ##FIELDP13( 'SN3.N3_VORIG14' )
        Select @nValXX14  = 0
        ##ENDFIELDP13
        ##FIELDP14( 'SN3.N3_VORIG15' )
        Select @nValXX15  = 0
        ##ENDFIELDP14
        
        select @cAux     = 'SN5'
        exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_SN5 OutPut
      
        /* ----------------------------------------------------------------------------------
            Pontos de entrada - ATFCONTA, ATFSINAL e ATFTIPO
            ---------------------------------------------------------------------------------- */
        Exec ATFCONTA_## @IN_CONTA, @IN_DATA, @IN_TIPO,   @nValor1,   @nValor2, @nValor3, @nValor4, @nValor5,
                        @IN_SINAL, @nTaxa,   @IN_SUBCTA, @IN_FILIAL, @IN_CLVL, @IN_CUSTO, 
                                ##FIELDP05( 'SN3.N3_VORIG6' )
                                @nValor6, 
                                ##ENDFIELDP05
                                ##FIELDP06( 'SN3.N3_VORIG7' )
                                @nValor7, 
                                ##ENDFIELDP06
                                ##FIELDP07( 'SN3.N3_VORIG8' )
                                @nValor8, 
                                ##ENDFIELDP07
                                ##FIELDP08( 'SN3.N3_VORIG9' )
                                @nValor9, 
                                ##ENDFIELDP08
                                ##FIELDP09( 'SN3.N3_VORIG10' )
                                @nValor10, 
                                ##ENDFIELDP09
                                ##FIELDP10( 'SN3.N3_VORIG11' )
                                @nValor11, 
                                ##ENDFIELDP10
                                ##FIELDP11( 'SN3.N3_VORIG12' )
                                @nValor12, 
                                ##ENDFIELDP11
                                ##FIELDP12( 'SN3.N3_VORIG13' )
                                @nValor13, 
                                ##ENDFIELDP12
                                ##FIELDP13( 'SN3.N3_VORIG14' )
                                @nValor14, 
                                ##ENDFIELDP13
                                ##FIELDP14( 'SN3.N3_VORIG15' )
                                @nValor15, 
                                ##ENDFIELDP14
                                @cConta OutPut
      
        Exec ATFSINAL_## @IN_CONTA, @IN_DATA, @IN_TIPO,   @nValor1,   @nValor2, @nValor3,  @nValor4,    @nValor5,
                        @IN_SINAL, @nTaxa,   @IN_SUBCTA, @IN_FILIAL, @IN_CLVL, @IN_CUSTO, @IN_TIPOCNT, @IN_PROGRAMA, 
                                ##FIELDP05( 'SN3.N3_VORIG6' )
                                @nValor6,
                                ##ENDFIELDP05
                                ##FIELDP06( 'SN3.N3_VORIG7' )
                                @nValor7,
                                ##ENDFIELDP06
                                ##FIELDP07( 'SN3.N3_VORIG8' )
                                @nValor8,
                                ##ENDFIELDP07
                                ##FIELDP08( 'SN3.N3_VORIG9' )
                                @nValor9,
                                ##ENDFIELDP08
                                ##FIELDP09( 'SN3.N3_VORIG10' )
                                @nValor10,
                                ##ENDFIELDP09
                                ##FIELDP10( 'SN3.N3_VORIG11' )
                                @nValor11,
                                ##ENDFIELDP10
                                ##FIELDP11( 'SN3.N3_VORIG12' )
                                @nValor12,
                                ##ENDFIELDP11
                                ##FIELDP12( 'SN3.N3_VORIG13' )
                                @nValor13,
                                ##ENDFIELDP12
                                ##FIELDP13( 'SN3.N3_VORIG14' )
                                @nValor14,
                                ##ENDFIELDP13
                                ##FIELDP14( 'SN3.N3_VORIG15' )
                                @nValor15,
                                ##ENDFIELDP14
                                @cSinal OutPut
      
        Exec ATFTIPO_## @IN_CONTA, @IN_DATA, @IN_TIPO,   @nValor1,   @nValor2, @nValor3,  @nValor4,    @nValor5,
                        @cSinal,   @nTaxa,   @IN_SUBCTA, @IN_FILIAL, @IN_CLVL, @IN_CUSTO, @IN_TIPOCNT, @IN_PROGRAMA, 
                                ##FIELDP05( 'SN3.N3_VORIG6' )
                                @nValor6,
                                ##ENDFIELDP05
                                ##FIELDP06( 'SN3.N3_VORIG7' )
                                @nValor7,
                                ##ENDFIELDP06
                                ##FIELDP07( 'SN3.N3_VORIG8' )
                                @nValor8,
                                ##ENDFIELDP07
                                ##FIELDP08( 'SN3.N3_VORIG9' )
                                @nValor9,
                                ##ENDFIELDP08
                                ##FIELDP09( 'SN3.N3_VORIG10' )
                                @nValor10,
                                ##ENDFIELDP09
                                ##FIELDP10( 'SN3.N3_VORIG11' )
                                @nValor11,
                                ##ENDFIELDP10
                                ##FIELDP11( 'SN3.N3_VORIG12' )
                                @nValor12,
                                ##ENDFIELDP11
                                ##FIELDP12( 'SN3.N3_VORIG13' )
                                @nValor13,
                                ##ENDFIELDP12
                                ##FIELDP13( 'SN3.N3_VORIG14' )
                                @nValor14,
                                ##ENDFIELDP13
                                ##FIELDP14( 'SN3.N3_VORIG15' )
                                @nValor15,
                                ##ENDFIELDP14
                        @cTipo OutPut
        /* ----------------------------------------------------------------------------------
            Atualizacao do SN5  - Contas
            ---------------------------------------------------------------------------------- */
        Select @iRecno   = null
        Select @iRecno = R_E_C_N_O_
        From SN5###
        where N5_FILIAL  = @cFilial_SN5
            and N5_CONTA   = @cConta
            and N5_DATA    = @IN_DATA
            and N5_TIPO    = @IN_TIPO
		    ##FIELDP01( 'SN5.N5_TPBEM;N5_TPSALDO' )
		    and N5_TPBEM   = @IN_TPBEM 
		    and N5_TPSALDO = @IN_TPSALDO
		    ##ENDFIELDP01
            and D_E_L_E_T_ = ' '
      
        if @iRecno is Null begin
         
            If @cSinal = '+' begin
                Select @nValXX1 = Round(@nValor1, @IN_CASA1 )
                Select @nValXX2 = Round(@nValor2, @IN_CASA2 )
                Select @nValXX3 = Round(@nValor3, @IN_CASA3 )
                Select @nValXX4 = Round(@nValor4, @IN_CASA4 )
                Select @nValXX5 = Round(@nValor5, @IN_CASA5 )
                 ##FIELDP05( 'SN3.N3_VORIG6' )
                 Select @nValXX6 = Round(@nValor6, @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = Round(@nValor7, @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = Round(@nValor8, @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = Round(@nValor9, @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = Round(@nValor10, @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = Round(@nValor11, @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = Round(@nValor12, @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = Round(@nValor13, @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = Round(@nValor14, @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = Round(@nValor15, @IN_CASA15 )
                ##ENDFIELDP14
            end else begin
                Select @nValXX1 = Round(@nValor1 *(-1), @IN_CASA1 )
                Select @nValXX2 = Round(@nValor2 *(-1), @IN_CASA2 )
                Select @nValXX3 = Round(@nValor3 *(-1), @IN_CASA3 )
                Select @nValXX4 = Round(@nValor4 *(-1), @IN_CASA4 )
                Select @nValXX5 = Round(@nValor5 *(-1), @IN_CASA5 )
                ##FIELDP05( 'SN3.N3_VORIG6' )
                Select @nValXX6 = Round(@nValor6 *(-1), @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = Round(@nValor7 *(-1), @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = Round(@nValor8 *(-1), @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = Round(@nValor9 *(-1), @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = Round(@nValor10 *(-1), @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = Round(@nValor11 *(-1), @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = Round(@nValor12 *(-1), @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = Round(@nValor13 *(-1), @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = Round(@nValor14 *(-1), @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = Round(@nValor15 *(-1), @IN_CASA15 )
                ##ENDFIELDP14
            end
         
            select @iRecno = IsNull( Max( R_E_C_N_O_), 0) from SN5###
            select @iRecno = @iRecno + 1
            begin tran
            insert into SN5### ( N5_FILIAL,    N5_CONTA,  N5_DATA, N5_TIPO,  N5_TAXA, N5_VALOR1, N5_VALOR2, N5_VALOR3, N5_VALOR4, N5_VALOR5, R_E_C_N_O_ 
                                ##FIELDP01( 'SN5.N5_TPBEM;N5_TPSALDO' )
                                , N5_TPBEM, N5_TPSALDO
                                ##ENDFIELDP01
                                ##FIELDP05( 'SN3.N3_VORIG6' )
                                 , N5_VALOR6
                                ##ENDFIELDP05
                                ##FIELDP06( 'SN3.N3_VORIG7' )
                                , N5_VALOR7
                                ##ENDFIELDP06
                                ##FIELDP07( 'SN3.N3_VORIG8' )
                                , N5_VALOR8
                                ##ENDFIELDP07
                                ##FIELDP08( 'SN3.N3_VORIG9' )
                                , N5_VALOR9
                                ##ENDFIELDP08
                                ##FIELDP09( 'SN3.N3_VORIG10' )
                                , N5_VALOR10
                                ##ENDFIELDP09
                                ##FIELDP10( 'SN3.N3_VORIG11' )
                                , N5_VALOR11
                                ##ENDFIELDP10
                                ##FIELDP11( 'SN3.N3_VORIG12' )
                                , N5_VALOR12
                                ##ENDFIELDP11
                                ##FIELDP12( 'SN3.N3_VORIG13' )
                                , N5_VALOR13
                                ##ENDFIELDP12
                                ##FIELDP13( 'SN3.N3_VORIG14' )
                                , N5_VALOR14
                                ##ENDFIELDP13
                                ##FIELDP14( 'SN3.N3_VORIG15' )
                                , N5_VALOR15
                                ##ENDFIELDP14
                                )
                        values ( @cFilial_SN5, @cConta,  @IN_DATA, @IN_TIPO, @nTaxa,  @nValXX1,  @nValXX2,  @nValXX3,  @nValXX4,  @nValXX5,  @iRecno 
                                ##FIELDP01( 'SN5.N5_TPBEM;N5_TPSALDO' )
                                , @IN_TPBEM, @IN_TPSALDO
                                ##ENDFIELDP01
                                ##FIELDP05( 'SN3.N3_VORIG6' )
                                ,  @nValXX6
                                ##ENDFIELDP05
                                ##FIELDP06( 'SN3.N3_VORIG7' )
                                ,  @nValXX7
                                ##ENDFIELDP06
                                ##FIELDP07( 'SN3.N3_VORIG8' )
                                ,  @nValXX8
                                ##ENDFIELDP07
                                ##FIELDP08( 'SN3.N3_VORIG9' )
                                ,  @nValXX9
                                ##ENDFIELDP08
                                ##FIELDP09( 'SN3.N3_VORIG10' )
                                ,  @nValXX10
                                ##ENDFIELDP09
                                ##FIELDP10( 'SN3.N3_VORIG11' )
                                ,  @nValXX11
                                ##ENDFIELDP10
                                ##FIELDP11( 'SN3.N3_VORIG12' )
                                ,  @nValXX12
                                ##ENDFIELDP11
                                ##FIELDP12( 'SN3.N3_VORIG13' )
                                ,  @nValXX13
                                ##ENDFIELDP12
                                ##FIELDP13( 'SN3.N3_VORIG14' )
                                ,  @nValXX14
                                ##ENDFIELDP13
                                ##FIELDP14( 'SN3.N3_VORIG15' )
                                ,  @nValXX15
                                ##ENDFIELDP14
                                )
            commit tran
        end else begin
            Select @nValXX1 = N5_VALOR1, @nValXX2 = N5_VALOR2, @nValXX3 = N5_VALOR3, @nValXX4 = N5_VALOR4, @nValXX5 = N5_VALOR5
                ##FIELDP05( 'SN3.N3_VORIG6' )
                , @nValXX6 = N5_VALOR6
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                , @nValXX7 = N5_VALOR7
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                , @nValXX8 = N5_VALOR8
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                , @nValXX9 = N5_VALOR9
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                , @nValXX10 = N5_VALOR10
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                , @nValXX11 = N5_VALOR11
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                , @nValXX12 = N5_VALOR12
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                , @nValXX13 = N5_VALOR13
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                , @nValXX14 = N5_VALOR14
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                , @nValXX15 = N5_VALOR15
                ##ENDFIELDP14
            From SN5###
            where R_E_C_N_O_ = @iRecno
         
            If @cSinal = '+' begin
                Select @nValXX1 = @nValXX1 + Round(@nValor1, @IN_CASA1 )
                Select @nValXX2 = @nValXX2 + Round(@nValor2, @IN_CASA2 )
                Select @nValXX3 = @nValXX3 + Round(@nValor3, @IN_CASA3 )
                Select @nValXX4 = @nValXX4 + Round(@nValor4, @IN_CASA4 )
                Select @nValXX5 = @nValXX5 + Round(@nValor5, @IN_CASA5 )
                ##FIELDP05( 'SN3.N3_VORIG6' )
                Select @nValXX6 = @nValXX6 + Round(@nValor6, @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = @nValXX7 + Round(@nValor7, @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = @nValXX8 + Round(@nValor8, @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = @nValXX9 + Round(@nValor9, @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = @nValXX10 + Round(@nValor10, @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = @nValXX11 + Round(@nValor11, @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = @nValXX12 + Round(@nValor12, @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = @nValXX13 + Round(@nValor13, @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = @nValXX14 + Round(@nValor14, @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = @nValXX15 + Round(@nValor15, @IN_CASA15 )
                ##ENDFIELDP14
            end else begin
                Select @nValXX1 = @nValXX1 - Round(@nValor1, @IN_CASA1 )
                Select @nValXX2 = @nValXX2 - Round(@nValor2, @IN_CASA2 )
                Select @nValXX3 = @nValXX3 - Round(@nValor3, @IN_CASA3 )
                Select @nValXX4 = @nValXX4 - Round(@nValor4, @IN_CASA4 )
                Select @nValXX5 = @nValXX5 - Round(@nValor5, @IN_CASA5 )
                ##FIELDP05( 'SN3.N3_VORIG6' )
                Select @nValXX6 = @nValXX6 - Round(@nValor6, @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = @nValXX7 - Round(@nValor7, @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = @nValXX8 - Round(@nValor8, @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = @nValXX9 - Round(@nValor9, @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = @nValXX10 - Round(@nValor10, @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = @nValXX11 - Round(@nValor11, @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = @nValXX12 - Round(@nValor12, @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = @nValXX13 - Round(@nValor13, @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = @nValXX14 - Round(@nValor14, @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = @nValXX15 - Round(@nValor15, @IN_CASA15 )
                ##ENDFIELDP14
            end
         
            Begin tran
            Update SN5###
            Set N5_TAXA = @nTaxa, N5_VALOR1 = @nValXX1, N5_VALOR2 = @nValXX2, N5_VALOR3 = @nValXX3, N5_VALOR4 = @nValXX4, N5_VALOR5 = @nValXX5
                ##FIELDP05( 'SN3.N3_VORIG6' )
                , N5_VALOR6 = @nValXX6
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                , N5_VALOR7 = @nValXX7
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                , N5_VALOR8 = @nValXX8
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                , N5_VALOR9 = @nValXX9
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                , N5_VALOR10 = @nValXX10
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                , N5_VALOR11 = @nValXX11
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                , N5_VALOR12 = @nValXX12
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                , N5_VALOR13 = @nValXX13
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                , N5_VALOR14 = @nValXX14
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                , N5_VALOR15 = @nValXX15
                ##ENDFIELDP14
            Where R_E_C_N_O_ = @iRecno
            Commit tran
        end
        /* ----------------------------------------------------------------------------------
            Pontos de entrada - ATFGRSLD
            ---------------------------------------------------------------------------------- */
        Select @cTabela = 'SN5'
        Exec ATFGRSLD_## @cTipo, @cSinal, @cTabela, @iRecno
      
        Select @nValXX1 = N5_VALOR1, @nValXX2 = N5_VALOR2, @nValXX3 = N5_VALOR3, @nValXX4 = N5_VALOR4, @nValXX5 = N5_VALOR5,
                @iRecno = R_E_C_N_O_
                ##FIELDP05( 'SN3.N3_VORIG6' )
                , @nValXX6 = N5_VALOR6
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                , @nValXX7 = N5_VALOR7
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                , @nValXX8 = N5_VALOR8
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                , @nValXX9 = N5_VALOR9
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                , @nValXX10 = N5_VALOR10
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                , @nValXX11 = N5_VALOR11
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                , @nValXX12 = N5_VALOR12
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                , @nValXX13 = N5_VALOR13
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                , @nValXX14 = N5_VALOR14
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                , @nValXX15 = N5_VALOR15
                ##ENDFIELDP14
          From SN5###
        where R_E_C_N_O_ = @iRecno
      
        If (@nValXX1 = 0) and (@nValXX2 = 0) and (@nValXX3 = 0) and (@nValXX4 = 0) and (@nValXX5 = 0) 
                    ##FIELDP05( 'SN3.N3_VORIG6' )
                     and (@nValXX6 = 0) 
                    ##ENDFIELDP05
                    ##FIELDP06( 'SN3.N3_VORIG7' )
                     and (@nValXX7 = 0) 
                    ##ENDFIELDP06
                    ##FIELDP07( 'SN3.N3_VORIG8' )
                     and (@nValXX8 = 0) 
                    ##ENDFIELDP07
                    ##FIELDP08( 'SN3.N3_VORIG9' )
                     and (@nValXX9 = 0) 
                    ##ENDFIELDP08
                    ##FIELDP09( 'SN3.N3_VORIG10' )
                     and (@nValXX10 = 0) 
                    ##ENDFIELDP09
                    ##FIELDP10( 'SN3.N3_VORIG11' )
                     and (@nValXX11 = 0) 
                    ##ENDFIELDP10
                    ##FIELDP11( 'SN3.N3_VORIG12' )
                     and (@nValXX12 = 0) 
                    ##ENDFIELDP11
                    ##FIELDP12( 'SN3.N3_VORIG13' )
                     and (@nValXX13 = 0) 
                    ##ENDFIELDP12
                    ##FIELDP13( 'SN3.N3_VORIG14' )
                     and (@nValXX14 = 0) 
                    ##ENDFIELDP13
                    ##FIELDP14( 'SN3.N3_VORIG15' )
                     and (@nValXX15 = 0) 
                    ##ENDFIELDP14  begin
            begin tran
            delete from SN5###
            where R_E_C_N_O_ = @iRecno
            commit tran
        End
        /* ----------------------------------------------------------------------------------
            Caso o Centro de Custo estiver preenchido atualizo saldos no SNC
            ---------------------------------------------------------------------------------- */
        If @IN_LCUSTO = '1' and   @IN_CUSTO <> ' ' begin
            Select @nValXX1 = 0
            Select @nValXX2 = 0
            Select @nValXX3 = 0
            Select @nValXX4 = 0
            Select @nValXX5 = 0

            ##FIELDP05( 'SN3.N3_VORIG6' )
            Select @nValXX5 = 0
            ##ENDFIELDP05
            ##FIELDP06( 'SN3.N3_VORIG7' )
            Select @nValXX5 = 0
            ##ENDFIELDP06
            ##FIELDP07( 'SN3.N3_VORIG8' )
            Select @nValXX5 = 0
            ##ENDFIELDP07
            ##FIELDP08( 'SN3.N3_VORIG9' )
            Select @nValXX5 = 0
            ##ENDFIELDP08
            ##FIELDP09( 'SN3.N3_VORIG10' )
            Select @nValXX5 = 0
            ##ENDFIELDP09
            ##FIELDP10( 'SN3.N3_VORIG11' )
            Select @nValXX5 = 0
            ##ENDFIELDP10
            ##FIELDP11( 'SN3.N3_VORIG12' )
            Select @nValXX5 = 0
            ##ENDFIELDP11
            ##FIELDP12( 'SN3.N3_VORIG13' )
            Select @nValXX5 = 0
            ##ENDFIELDP12
            ##FIELDP13( 'SN3.N3_VORIG14' )
            Select @nValXX5 = 0
            ##ENDFIELDP13
            ##FIELDP14( 'SN3.N3_VORIG15' )
            Select @nValXX5 = 0
            ##ENDFIELDP14
            Select @iRecno  = null
            select @cAux = 'SNC'
            exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_SNC OutPut
         
            Select @iRecno = R_E_C_N_O_
            From SNC###
            where NC_FILIAL  = @cFilial_SNC
            and NC_CONTA   = @cConta
            and NC_CCUSTO  = @IN_CUSTO
            and NC_DATA    = @IN_DATA
            and NC_TIPO    = @IN_TIPO
            ##FIELDP02( 'SNC.NC_TPBEM;NC_TPSALDO' )
				    and NC_TPBEM   = @IN_TPBEM 
				    and NC_TPSALDO = @IN_TPSALDO
		    ##ENDFIELDP02
            and D_E_L_E_T_ = ' '
         
            if @iRecno is Null begin
            If @cSinal = '+' begin
                Select @nValXX1 = Round(@nValor1, @IN_CASA1 )
                Select @nValXX2 = Round(@nValor2, @IN_CASA2 )
                Select @nValXX3 = Round(@nValor3, @IN_CASA3 )
                Select @nValXX4 = Round(@nValor4, @IN_CASA4 )
                Select @nValXX5 = Round(@nValor5, @IN_CASA5 )
                ##FIELDP05( 'SN3.N3_VORIG6' )
                 Select @nValXX6 = Round(@nValor6, @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = Round(@nValor7, @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = Round(@nValor8, @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = Round(@nValor9, @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = Round(@nValor10, @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = Round(@nValor11, @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = Round(@nValor12, @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = Round(@nValor13, @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = Round(@nValor14, @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = Round(@nValor15, @IN_CASA15 )
                ##ENDFIELDP14
            end else begin
                Select @nValXX1 = Round(@nValor1 *(-1), @IN_CASA1 )
                Select @nValXX2 = Round(@nValor2 *(-1), @IN_CASA2 )
                Select @nValXX3 = Round(@nValor3 *(-1), @IN_CASA3 )
                Select @nValXX4 = Round(@nValor4 *(-1), @IN_CASA4 )
                Select @nValXX5 = Round(@nValor5 *(-1), @IN_CASA5 )
                ##FIELDP05( 'SN3.N3_VORIG6' )
                Select @nValXX6 = Round(@nValor6 *(-1), @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = Round(@nValor7 *(-1), @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = Round(@nValor8 *(-1), @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = Round(@nValor9 *(-1), @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = Round(@nValor10 *(-1), @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = Round(@nValor11 *(-1), @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = Round(@nValor12 *(-1), @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = Round(@nValor13 *(-1), @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = Round(@nValor14 *(-1), @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = Round(@nValor15 *(-1), @IN_CASA15 )
                ##ENDFIELDP14
            end
            
            select @iRecno = IsNull( Max( R_E_C_N_O_), 0) from SNC###
            select @iRecno = @iRecno + 1
            begin tran
            insert into SNC### ( NC_FILIAL,    NC_CONTA,  NC_CCUSTO, NC_DATA,  NC_TIPO,  NC_TAXA, NC_VALOR1, NC_VALOR2, NC_VALOR3, NC_VALOR4,
                                    NC_VALOR5,    R_E_C_N_O_ 
                                    ##FIELDP02( 'SNC.NC_TPBEM;NC_TPSALDO' )
                                    , NC_TPBEM, NC_TPSALDO
                                    ##ENDFIELDP02
                                    ##FIELDP05( 'SN3.N3_VORIG6' )
                                    , NC_VALOR6
                                    ##ENDFIELDP05
                                    ##FIELDP06( 'SN3.N3_VORIG7' )
                                    , NC_VALOR7
                                    ##ENDFIELDP06
                                    ##FIELDP07( 'SN3.N3_VORIG8' )
                                    , NC_VALOR8
                                    ##ENDFIELDP07
                                    ##FIELDP08( 'SN3.N3_VORIG9' )
                                    , NC_VALOR9
                                    ##ENDFIELDP08
                                    ##FIELDP09( 'SN3.N3_VORIG10' )
                                    , NC_VALOR10
                                    ##ENDFIELDP09
                                    ##FIELDP10( 'SN3.N3_VORIG11' )
                                    , NC_VALOR11
                                    ##ENDFIELDP10
                                    ##FIELDP11( 'SN3.N3_VORIG12' )
                                    , NC_VALOR12
                                    ##ENDFIELDP11
                                    ##FIELDP12( 'SN3.N3_VORIG13' )
                                    , NC_VALOR13
                                    ##ENDFIELDP12
                                    ##FIELDP13( 'SN3.N3_VORIG14' )
                                    , NC_VALOR14
                                    ##ENDFIELDP13
                                    ##FIELDP14( 'SN3.N3_VORIG15' )
                                    , NC_VALOR15
                                    ##ENDFIELDP14
                                    )
                        values ( @cFilial_SNC, @cConta, @IN_CUSTO, @IN_DATA, @IN_TIPO, @nTaxa,  @nValXX1,  @nValXX2,  @nValXX3,  @nValXX4,
                                    @nValXX5,     @iRecno
                                    ##FIELDP02( 'SNC.NC_TPBEM;NC_TPSALDO' )
                                    , @IN_TPBEM, @IN_TPSALDO
                                    ##ENDFIELDP02
                                    ##FIELDP05( 'SN3.N3_VORIG6' )
                                    ,  @nValXX6
                                    ##ENDFIELDP05
                                    ##FIELDP06( 'SN3.N3_VORIG7' )
                                    ,  @nValXX7
                                    ##ENDFIELDP06
                                    ##FIELDP07( 'SN3.N3_VORIG8' )
                                    ,  @nValXX8
                                    ##ENDFIELDP07
                                    ##FIELDP08( 'SN3.N3_VORIG9' )
                                    ,  @nValXX9
                                    ##ENDFIELDP08
                                    ##FIELDP09( 'SN3.N3_VORIG10' )
                                    ,  @nValXX10
                                    ##ENDFIELDP09
                                    ##FIELDP10( 'SN3.N3_VORIG11' )
                                    ,  @nValXX11
                                    ##ENDFIELDP10
                                    ##FIELDP11( 'SN3.N3_VORIG12' )
                                    ,  @nValXX12
                                    ##ENDFIELDP11
                                    ##FIELDP12( 'SN3.N3_VORIG13' )
                                    ,  @nValXX13
                                    ##ENDFIELDP12
                                    ##FIELDP13( 'SN3.N3_VORIG14' )
                                    ,  @nValXX14
                                    ##ENDFIELDP13
                                    ##FIELDP14( 'SN3.N3_VORIG15' )
                                    ,  @nValXX15
                                    ##ENDFIELDP14
                                    )
            commit tran
            end else begin
            Select @nValXX1 = NC_VALOR1, @nValXX2 = NC_VALOR2, @nValXX3 = NC_VALOR3, @nValXX4 = NC_VALOR4, @nValXX5 = NC_VALOR5
                From SNC###
                where R_E_C_N_O_ = @iRecno
            
            If @cSinal = '+' begin
                Select @nValXX1 = @nValXX1 + Round(@nValor1, @IN_CASA1 )
                Select @nValXX2 = @nValXX2 + Round(@nValor2, @IN_CASA2 )
                Select @nValXX3 = @nValXX3 + Round(@nValor3, @IN_CASA3 )
                Select @nValXX4 = @nValXX4 + Round(@nValor4, @IN_CASA4 )
                Select @nValXX5 = @nValXX5 + Round(@nValor5, @IN_CASA5 )
                ##FIELDP05( 'SN3.N3_VORIG6' )
                Select @nValXX6 = @nValXX6 + Round(@nValor6, @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = @nValXX7 + Round(@nValor7, @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = @nValXX8 + Round(@nValor8, @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = @nValXX9 + Round(@nValor9, @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = @nValXX10 + Round(@nValor10, @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = @nValXX11 + Round(@nValor11, @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = @nValXX12 + Round(@nValor12, @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = @nValXX13 + Round(@nValor13, @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = @nValXX14 + Round(@nValor14, @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = @nValXX15 + Round(@nValor15, @IN_CASA15 )
                ##ENDFIELDP14
            end else begin
                Select @nValXX1 = @nValXX1 - Round(@nValor1, @IN_CASA1 )
                Select @nValXX2 = @nValXX2 - Round(@nValor2, @IN_CASA2 )
                Select @nValXX3 = @nValXX3 - Round(@nValor3, @IN_CASA3 )
                Select @nValXX4 = @nValXX4 - Round(@nValor4, @IN_CASA4 )
                Select @nValXX5 = @nValXX5 - Round(@nValor5, @IN_CASA5 )
                ##FIELDP05( 'SN3.N3_VORIG6' )
                 Select @nValXX6 = Round(@nValor6, @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = Round(@nValor7, @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = Round(@nValor8, @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = Round(@nValor9, @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = Round(@nValor10, @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = Round(@nValor11, @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = Round(@nValor12, @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = Round(@nValor13, @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = Round(@nValor14, @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = Round(@nValor15, @IN_CASA15 )
                ##ENDFIELDP14
            end
            begin tran
            Update SNC###
                Set NC_TAXA = @nTaxa, NC_VALOR1 = @nValXX1, NC_VALOR2 = @nValXX2, NC_VALOR3 = @nValXX3, NC_VALOR4 = @nValXX4, NC_VALOR5 = @nValXX5
                 ##FIELDP05( 'SN3.N3_VORIG6' )
                 , NC_VALOR6 = @nValXX6
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                , NC_VALOR7 = @nValXX7
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                , NC_VALOR8 = @nValXX8
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                , NC_VALOR9 = @nValXX9
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                , NC_VALOR10 = @nValXX10
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                , NC_VALOR11 = @nValXX11
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                , NC_VALOR12 = @nValXX12
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                , NC_VALOR13 = @nValXX13
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                , NC_VALOR14 = @nValXX14
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                , NC_VALOR15 = @nValXX15
                ##ENDFIELDP14
                Where R_E_C_N_O_ = @iRecno
            commit tran
            end
            /* ----------------------------------------------------------------------------------
            Pontos de entrada - ATFGRSLD
            ---------------------------------------------------------------------------------- */
            Select @cTabela = 'SNC'
            Exec ATFGRSLD_## @cTipo, @cSinal, @cTabela, @iRecno
         
            Select @nValXX1 = NC_VALOR1, @nValXX2 = NC_VALOR2, @nValXX3 = NC_VALOR3, @nValXX4 = NC_VALOR4, @nValXX5 = NC_VALOR5,
                @iRecno = R_E_C_N_O_
                 ##FIELDP05( 'SN3.N3_VORIG6' )
                 , @nValXX6 = NC_VALOR6
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                , @nValXX7 = NC_VALOR7
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                , @nValXX8 = NC_VALOR8
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                , @nValXX9 = NC_VALOR9
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                , @nValXX10 = NC_VALOR10
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                , @nValXX11 = NC_VALOR11
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                , @nValXX12 = NC_VALOR12
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                , @nValXX13 = NC_VALOR13
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                , @nValXX14 = NC_VALOR14
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                , @nValXX15 = NC_VALOR15
                ##ENDFIELDP14
            From SNC###
            where R_E_C_N_O_ = @iRecno
         
            If (@nValXX1 = 0) and (@nValXX2 = 0) and (@nValXX3 = 0) and (@nValXX4 = 0) and (@nValXX5 = 0) 
                    ##FIELDP05( 'SN3.N3_VORIG6' )
                     and (@nValXX6 = 0) 
                    ##ENDFIELDP05
                    ##FIELDP06( 'SN3.N3_VORIG7' )
                     and (@nValXX7 = 0) 
                    ##ENDFIELDP06
                    ##FIELDP07( 'SN3.N3_VORIG8' )
                     and (@nValXX8 = 0) 
                    ##ENDFIELDP07
                    ##FIELDP08( 'SN3.N3_VORIG9' )
                     and (@nValXX9 = 0) 
                    ##ENDFIELDP08
                    ##FIELDP09( 'SN3.N3_VORIG10' )
                     and (@nValXX10 = 0) 
                    ##ENDFIELDP09
                    ##FIELDP10( 'SN3.N3_VORIG11' )
                     and (@nValXX11 = 0) 
                    ##ENDFIELDP10
                    ##FIELDP11( 'SN3.N3_VORIG12' )
                     and (@nValXX12 = 0) 
                    ##ENDFIELDP11
                    ##FIELDP12( 'SN3.N3_VORIG13' )
                     and (@nValXX13 = 0) 
                    ##ENDFIELDP12
                    ##FIELDP13( 'SN3.N3_VORIG14' )
                     and (@nValXX14 = 0) 
                    ##ENDFIELDP13
                    ##FIELDP14( 'SN3.N3_VORIG15' )
                     and (@nValXX15 = 0) 
                    ##ENDFIELDP14  begin
                begin tran
                delete from SNC###
                    where R_E_C_N_O_ = @iRecno
                commit tran
            End
        end
        /* ----------------------------------------------------------------------------------
            Caso as subContas estejam preenchidas atualizo saldos no SN6 - Item
            ---------------------------------------------------------------------------------- */
        If @IN_LITEM = '1' and @IN_SUBCTA <> ' ' begin
            Select @nValXX1 = 0
            Select @nValXX2 = 0
            Select @nValXX3 = 0
            Select @nValXX4 = 0
            Select @nValXX5 = 0
            ##FIELDP05( 'SN3.N3_VORIG6' )
            Select @nValXX6 = 0
            ##ENDFIELDP05
            ##FIELDP06( 'SN3.N3_VORIG7' )
            Select @nValXX7 = 0
            ##ENDFIELDP06
            ##FIELDP07( 'SN3.N3_VORIG8' )
            Select @nValXX8 = 0
            ##ENDFIELDP07
            ##FIELDP08( 'SN3.N3_VORIG9' )
            Select @nValXX9 = 0
            ##ENDFIELDP08
            ##FIELDP09( 'SN3.N3_VORIG10' )
            Select @nValXX10 = 0
            ##ENDFIELDP09
            ##FIELDP10( 'SN3.N3_VORIG11' )
            Select @nValXX11 = 0
            ##ENDFIELDP10
            ##FIELDP11( 'SN3.N3_VORIG12' )
            Select @nValXX12 = 0
            ##ENDFIELDP11
            ##FIELDP12( 'SN3.N3_VORIG13' )
            Select @nValXX13 = 0
            ##ENDFIELDP12
            ##FIELDP13( 'SN3.N3_VORIG14' )
            Select @nValXX14 = 0
            ##ENDFIELDP13
            ##FIELDP14( 'SN3.N3_VORIG15' )
            Select @nValXX15 = 0
            ##ENDFIELDP14
            Select @iRecno  = null
            select @cAux = 'SN6'
            exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_SN6 OutPut
         
            Select @iRecno = R_E_C_N_O_
            From SN6###
            where N6_FILIAL  = @cFilial_SN6
            and N6_CONTA   = @cConta
            and N6_CCUSTO  = @IN_CUSTO
            and N6_SUBCTA  = @IN_SUBCTA
            and N6_DATA    = @IN_DATA
            and N6_TIPO    = @IN_TIPO
		    ##FIELDP03( 'SN6.N6_TPBEM;N6_TPSALDO' )
			    and N6_TPBEM   = @IN_TPBEM 
			    and N6_TPSALDO = @IN_TPSALDO
		    ##ENDFIELDP03
            and D_E_L_E_T_ = ' '
         
            if @iRecno is Null begin
            If @cSinal = '+' begin
                Select @nValXX1 = Round(@nValor1, @IN_CASA1 )
                Select @nValXX2 = Round(@nValor2, @IN_CASA2 )
                Select @nValXX3 = Round(@nValor3, @IN_CASA3 )
                Select @nValXX4 = Round(@nValor4, @IN_CASA4 )
                Select @nValXX5 = Round(@nValor5, @IN_CASA5 )
                 ##FIELDP05( 'SN3.N3_VORIG6' )
                 Select @nValXX6 = Round(@nValor6, @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = Round(@nValor7, @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = Round(@nValor8, @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = Round(@nValor9, @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = Round(@nValor10, @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = Round(@nValor11, @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = Round(@nValor12, @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = Round(@nValor13, @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = Round(@nValor14, @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = Round(@nValor15, @IN_CASA15 )
                ##ENDFIELDP14
            end else begin
                Select @nValXX1 = Round(@nValor1 *(-1), @IN_CASA1 )
                Select @nValXX2 = Round(@nValor2 *(-1), @IN_CASA2 )
                Select @nValXX3 = Round(@nValor3 *(-1), @IN_CASA3 )
                Select @nValXX4 = Round(@nValor4 *(-1), @IN_CASA4 )
                Select @nValXX5 = Round(@nValor5 *(-1), @IN_CASA5 )
                ##FIELDP05( 'SN3.N3_VORIG6' )
                Select @nValXX6 = Round(@nValor6 *(-1), @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = Round(@nValor7 *(-1), @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = Round(@nValor8 *(-1), @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = Round(@nValor9 *(-1), @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = Round(@nValor10 *(-1), @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = Round(@nValor11 *(-1), @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = Round(@nValor12 *(-1), @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = Round(@nValor13 *(-1), @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = Round(@nValor14 *(-1), @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = Round(@nValor15 *(-1), @IN_CASA15 )
                ##ENDFIELDP14
            end
            
            select @iRecno = IsNull( Max( R_E_C_N_O_), 0) from SN6###
            select @iRecno = @iRecno + 1
            begin tran
            insert into SN6### ( N6_FILIAL,    N6_CONTA,  N6_CCUSTO, N6_SUBCTA,  N6_DATA,  N6_TIPO,  N6_TAXA, N6_VALOR1, N6_VALOR2, N6_VALOR3,
                                    N6_VALOR4,    N6_VALOR5, R_E_C_N_O_
                                    ##FIELDP03( 'SN6.N6_TPBEM;N6_TPSALDO' )
                                    , N6_TPBEM, N6_TPSALDO
                                    ##ENDFIELDP03
                                     ##FIELDP05( 'SN3.N3_VORIG6' )
                                     ,    N6_VALOR6
                                    ##ENDFIELDP05
                                    ##FIELDP06( 'SN3.N3_VORIG7' )
                                    ,    N6_VALOR7
                                    ##ENDFIELDP06
                                    ##FIELDP07( 'SN3.N3_VORIG8' )
                                    ,    N6_VALOR8
                                    ##ENDFIELDP07
                                    ##FIELDP08( 'SN3.N3_VORIG9' )
                                    ,    N6_VALOR9
                                    ##ENDFIELDP08
                                    ##FIELDP09( 'SN3.N3_VORIG10' )
                                    ,    N6_VALOR10
                                    ##ENDFIELDP09
                                    ##FIELDP10( 'SN3.N3_VORIG11' )
                                    ,    N6_VALOR11
                                    ##ENDFIELDP10
                                    ##FIELDP11( 'SN3.N3_VORIG12' )
                                    ,    N6_VALOR12
                                    ##ENDFIELDP11
                                    ##FIELDP12( 'SN3.N3_VORIG13' )
                                    ,    N6_VALOR13
                                    ##ENDFIELDP12
                                    ##FIELDP13( 'SN3.N3_VORIG14' )
                                    ,    N6_VALOR14
                                    ##ENDFIELDP13
                                    ##FIELDP14( 'SN3.N3_VORIG15' )
                                    ,    N6_VALOR15
                                    ##ENDFIELDP14
                                    )
                        values ( @cFilial_SN6, @cConta, @IN_CUSTO, @IN_SUBCTA, @IN_DATA, @IN_TIPO, @nTaxa,  @nValXX1,  @nValXX2,  @nValXX3,
                                    @nValXX4,     @nValXX5,  @iRecno
                                    ##FIELDP03( 'SN6.N6_TPBEM;N6_TPSALDO' )
                                    , @IN_TPBEM, @IN_TPSALDO
                                    ##ENDFIELDP03
                                    ##FIELDP05( 'SN3.N3_VORIG6' )
                                    ,  @nValXX6
                                    ##ENDFIELDP05
                                    ##FIELDP06( 'SN3.N3_VORIG7' )
                                    ,  @nValXX7
                                    ##ENDFIELDP06
                                    ##FIELDP07( 'SN3.N3_VORIG8' )
                                    ,  @nValXX8
                                    ##ENDFIELDP07
                                    ##FIELDP08( 'SN3.N3_VORIG9' )
                                    ,  @nValXX9
                                    ##ENDFIELDP08
                                    ##FIELDP09( 'SN3.N3_VORIG10' )
                                    ,  @nValXX10
                                    ##ENDFIELDP09
                                    ##FIELDP10( 'SN3.N3_VORIG11' )
                                    ,  @nValXX11
                                    ##ENDFIELDP10
                                    ##FIELDP11( 'SN3.N3_VORIG12' )
                                    ,  @nValXX12
                                    ##ENDFIELDP11
                                    ##FIELDP12( 'SN3.N3_VORIG13' )
                                    ,  @nValXX13
                                    ##ENDFIELDP12
                                    ##FIELDP13( 'SN3.N3_VORIG14' )
                                    ,  @nValXX14
                                    ##ENDFIELDP13
                                    ##FIELDP14( 'SN3.N3_VORIG15' )
                                    ,  @nValXX15
                                    ##ENDFIELDP14
                                    )
            commit tran
            end else begin
            Select @nValXX1 = N6_VALOR1, @nValXX2 = N6_VALOR2, @nValXX3 = N6_VALOR3, @nValXX4 = N6_VALOR4, @nValXX5 = N6_VALOR5
                        ##FIELDP05( 'SN3.N3_VORIG6' )
                        , @nValXX6 = N6_VALOR6
                        ##ENDFIELDP05
                        ##FIELDP06( 'SN3.N3_VORIG7' )
                        , @nValXX7 = N6_VALOR7
                        ##ENDFIELDP06
                        ##FIELDP07( 'SN3.N3_VORIG8' )
                        , @nValXX8 = N6_VALOR8
                        ##ENDFIELDP07
                        ##FIELDP08( 'SN3.N3_VORIG9' )
                        , @nValXX9 = N6_VALOR9
                        ##ENDFIELDP08
                        ##FIELDP09( 'SN3.N3_VORIG10' )
                        , @nValXX10 = N6_VALOR10
                        ##ENDFIELDP09
                        ##FIELDP10( 'SN3.N3_VORIG11' )
                        , @nValXX11 = N6_VALOR11
                        ##ENDFIELDP10
                        ##FIELDP11( 'SN3.N3_VORIG12' )
                        , @nValXX12 = N6_VALOR12
                        ##ENDFIELDP11
                        ##FIELDP12( 'SN3.N3_VORIG13' )
                        , @nValXX13 = N6_VALOR13
                        ##ENDFIELDP12
                        ##FIELDP13( 'SN3.N3_VORIG14' )
                        , @nValXX14 = N6_VALOR14
                        ##ENDFIELDP13
                        ##FIELDP14( 'SN3.N3_VORIG15' )
                        , @nValXX15 = N6_VALOR15
                        ##ENDFIELDP14
                From SN6###
                where R_E_C_N_O_= @iRecno
            
            If @cSinal = '+' begin
                Select @nValXX1 = @nValXX1 + Round(@nValor1, @IN_CASA1 )
                Select @nValXX2 = @nValXX2 + Round(@nValor2, @IN_CASA2 )
                Select @nValXX3 = @nValXX3 + Round(@nValor3, @IN_CASA3 )
                Select @nValXX4 = @nValXX4 + Round(@nValor4, @IN_CASA4 )
                Select @nValXX5 = @nValXX5 + Round(@nValor5, @IN_CASA5 )
                ##FIELDP05( 'SN3.N3_VORIG6' )
                Select @nValXX6 = @nValXX6 + Round(@nValor6, @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = @nValXX7 + Round(@nValor7, @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = @nValXX8 + Round(@nValor8, @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = @nValXX9 + Round(@nValor9, @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = @nValXX10 + Round(@nValor10, @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = @nValXX11 + Round(@nValor11, @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = @nValXX12 + Round(@nValor12, @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = @nValXX13 + Round(@nValor13, @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = @nValXX14 + Round(@nValor14, @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = @nValXX15 + Round(@nValor15, @IN_CASA15 )
                ##ENDFIELDP14
            end else begin
                Select @nValXX1 = @nValXX1 - Round(@nValor1, @IN_CASA1 )
                Select @nValXX2 = @nValXX2 - Round(@nValor2, @IN_CASA2 )
                Select @nValXX3 = @nValXX3 - Round(@nValor3, @IN_CASA3 )
                Select @nValXX4 = @nValXX4 - Round(@nValor4, @IN_CASA4 )
                Select @nValXX5 = @nValXX5 - Round(@nValor5, @IN_CASA5 )
                ##FIELDP05( 'SN3.N3_VORIG6' )
                Select @nValXX6 = @nValXX6 - Round(@nValor6, @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = @nValXX7 - Round(@nValor7, @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = @nValXX8 - Round(@nValor8, @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = @nValXX9 - Round(@nValor9, @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = @nValXX10 - Round(@nValor10, @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = @nValXX11 - Round(@nValor11, @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = @nValXX12 - Round(@nValor12, @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = @nValXX13 - Round(@nValor13, @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = @nValXX14 - Round(@nValor14, @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = @nValXX15 - Round(@nValor15, @IN_CASA15 )
                ##ENDFIELDP14
            end
            begin tran
            Update SN6###
                Set N6_TAXA = @nTaxa, N6_VALOR1 = @nValXX1, N6_VALOR2 = @nValXX2, N6_VALOR3 = @nValXX3, N6_VALOR4 = @nValXX4, N6_VALOR5 = @nValXX5
                 ##FIELDP05( 'SN3.N3_VORIG6' )
                 , N6_VALOR6 = @nValXX6
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                , N6_VALOR7 = @nValXX7
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                , N6_VALOR8 = @nValXX8
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                , N6_VALOR9 = @nValXX9
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                , N6_VALOR10 = @nValXX10
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                , N6_VALOR11 = @nValXX11
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                , N6_VALOR12 = @nValXX12
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                , N6_VALOR13 = @nValXX13
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                , N6_VALOR14 = @nValXX14
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                , N6_VALOR15 = @nValXX15
                ##ENDFIELDP14
                Where R_E_C_N_O_ = @iRecno
            commit tran
            end
            /* ----------------------------------------------------------------------------------
            Pontos de entrada - ATFGRSLD
            ---------------------------------------------------------------------------------- */
            Select @cTabela = 'SN6'
            Exec ATFGRSLD_## @cTipo, @cSinal, @cTabela, @iRecno
         
            Select @nValXX1 = N6_VALOR1, @nValXX2 = N6_VALOR2, @nValXX3 = N6_VALOR3, @nValXX4 = N6_VALOR4, @nValXX5 = N6_VALOR5,
                @iRecno = R_E_C_N_O_
                ##FIELDP05( 'SN3.N3_VORIG6' )
                , @nValXX6 = N6_VALOR6
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VOIG7' )
                , @nValXX7 = N6_VALOR7
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                , @nValXX8 = N6_VALOR8
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                , @nValXX9 = N6_VALOR9
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                , @nValXX10 = N6_VALOR10
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                , @nValXX11 = N6_VALOR11
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                , @nValXX12 = N6_VALOR12
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                , @nValXX13 = N6_VALOR13
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                , @nValXX14 = N6_VALOR14
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                , @nValXX15 = N6_VALOR15
                ##ENDFIELDP14
            From SN6###
            where R_E_C_N_O_ = @iRecno
         
            If (@nValXX1 = 0) and (@nValXX2 = 0) and (@nValXX3 = 0) and (@nValXX4 = 0) and (@nValXX5 = 0)  
                    ##FIELDP05( 'SN3.N3_VORIG6' )
                     and (@nValXX6 = 0) 
                    ##ENDFIELDP05
                    ##FIELDP06( 'SN3.N3_VORIG7' )
                     and (@nValXX7 = 0) 
                    ##ENDFIELDP06
                    ##FIELDP07( 'SN3.N3_VORIG8' )
                     and (@nValXX8 = 0) 
                    ##ENDFIELDP07
                    ##FIELDP08( 'SN3.N3_VORIG9' )
                     and (@nValXX9 = 0) 
                    ##ENDFIELDP08
                    ##FIELDP09( 'SN3.N3_VORIG10' )
                     and (@nValXX10 = 0) 
                    ##ENDFIELDP09
                    ##FIELDP10( 'SN3.N3_VORIG11' )
                     and (@nValXX11 = 0) 
                    ##ENDFIELDP10
                    ##FIELDP11( 'SN3.N3_VORIG12' )
                     and (@nValXX12 = 0) 
                    ##ENDFIELDP11
                    ##FIELDP12( 'SN3.N3_VORIG13' )
                     and (@nValXX13 = 0) 
                    ##ENDFIELDP12
                    ##FIELDP13( 'SN3.N3_VORIG14' )
                     and (@nValXX14 = 0) 
                    ##ENDFIELDP13
                    ##FIELDP14( 'SN3.N3_VORIG15' )
                     and (@nValXX15 = 0) 
                    ##ENDFIELDP14    begin
                begin tran
                delete from SN6###
                    where R_E_C_N_O_ = @iRecno
                commit tran
            End      
        end
        /* ----------------------------------------------------------------------------------
            Caso as Cl Vlrs   estejam preenchidas atualizo saldos no SNA
            ---------------------------------------------------------------------------------- */
        If @IN_LCLVL = '1' and @IN_CLVL <> ' ' begin
            Select @nValXX1 = 0
            Select @nValXX2 = 0
            Select @nValXX3 = 0
            Select @nValXX4 = 0
            Select @nValXX5 = 0
            ##FIELDP05( 'SN3.N3_VORIG6' )
            Select @nValXX6 = 0
            ##ENDFIELDP05
            ##FIELDP06( 'SN3.N3_VORIG7' )
            Select @nValXX7 = 0
            ##ENDFIELDP06
            ##FIELDP07( 'SN3.N3_VORIG8' )
            Select @nValXX8 = 0
            ##ENDFIELDP07
            ##FIELDP08( 'SN3.N3_VORIG9' )
            Select @nValXX9 = 0
            ##ENDFIELDP08
            ##FIELDP09( 'SN3.N3_VORIG10' )
            Select @nValXX10 = 0
            ##ENDFIELDP09
            ##FIELDP10( 'SN3.N3_VORIG11' )
            Select @nValXX11 = 0
            ##ENDFIELDP10
            ##FIELDP11( 'SN3.N3_VORIG12' )
            Select @nValXX12 = 0
            ##ENDFIELDP11
            ##FIELDP12( 'SN3.N3_VORIG13' )
            Select @nValXX13 = 0
            ##ENDFIELDP12
            ##FIELDP13( 'SN3.N3_VORIG14' )
            Select @nValXX14 = 0
            ##ENDFIELDP13
            ##FIELDP14( 'SN3.N3_VORIG15' )
            Select @nValXX15 = 0
            ##ENDFIELDP14
            Select @iRecno  = null
            select @cAux = 'SNA'
            exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_SNA OutPut
         
            Select @iRecno = R_E_C_N_O_
            From SNA###
            where NA_FILIAL  = @cFilial_SNA
            and NA_CONTA   = @cConta
            and NA_CCUSTO  = @IN_CUSTO
            and NA_SUBCTA  = @IN_SUBCTA
            and NA_CLVL    = @IN_CLVL
            and NA_DATA    = @IN_DATA
            and NA_TIPO    = @IN_TIPO
 		    ##FIELDP04( 'SNA.NA_TPBEM;NA_TPSALDO' )
			    and NA_TPBEM   = @IN_TPBEM 
			    and NA_TPSALDO = @IN_TPSALDO
		    ##ENDFIELDP04
            and D_E_L_E_T_ = ' '
         
            if @iRecno is Null begin
            If @cSinal = '+' begin
                Select @nValXX1 = Round(@nValor1, @IN_CASA1 )
                Select @nValXX2 = Round(@nValor2, @IN_CASA2 )
                Select @nValXX3 = Round(@nValor3, @IN_CASA3 )
                Select @nValXX4 = Round(@nValor4, @IN_CASA4 )
                Select @nValXX5 = Round(@nValor5, @IN_CASA5 )
                 ##FIELDP05( 'SN3.N3_VORIG6' )
                 Select @nValXX6 = Round(@nValor6, @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = Round(@nValor7, @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = Round(@nValor8, @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = Round(@nValor9, @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = Round(@nValor10, @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = Round(@nValor11, @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = Round(@nValor12, @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = Round(@nValor13, @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = Round(@nValor14, @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = Round(@nValor15, @IN_CASA15 )
                ##ENDFIELDP14
            end else begin
                Select @nValXX1 = Round(@nValor1 *(-1), @IN_CASA1 )
                Select @nValXX2 = Round(@nValor2 *(-1), @IN_CASA2 )
                Select @nValXX3 = Round(@nValor3 *(-1), @IN_CASA3 )
                Select @nValXX4 = Round(@nValor4 *(-1), @IN_CASA4 )
                Select @nValXX5 = Round(@nValor5 *(-1), @IN_CASA5 )
                ##FIELDP05( 'SN3.N3_VORIG6' )
                Select @nValXX6 = Round(@nValor6 *(-1), @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = Round(@nValor7 *(-1), @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = Round(@nValor8 *(-1), @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = Round(@nValor9 *(-1), @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = Round(@nValor10 *(-1), @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = Round(@nValor11 *(-1), @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = Round(@nValor12 *(-1), @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = Round(@nValor13 *(-1), @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = Round(@nValor14 *(-1), @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = Round(@nValor15 *(-1), @IN_CASA15 )
                ##ENDFIELDP14
            end
            
            select @iRecno = IsNull( Max( R_E_C_N_O_), 0) from SNA###
            select @iRecno = @iRecno + 1  
            begin tran
            insert into SNA### ( NA_FILIAL,    NA_CONTA,  NA_CCUSTO, NA_SUBCTA,  NA_CLVL,  NA_DATA,  NA_TIPO,  NA_TAXA, NA_VALOR1, NA_VALOR2,
                                    NA_VALOR3,    NA_VALOR4, NA_VALOR5, R_E_C_N_O_
                                    ##FIELDP04( 'SNA.NA_TPBEM;NA_TPSALDO' )
                                    , NA_TPBEM, NA_TPSALDO
                                    ##ENDFIELDP04
                                    ##FIELDP05( 'SN3.N3_VORIG6' )
                                    , NA_VALOR6
                                    ##ENDFIELDP05
                                    ##FIELDP06( 'SN3.N3_VORIG7' )
                                    , NA_VALOR7
                                    ##ENDFIELDP06
                                    ##FIELDP07( 'SN3.N3_VORIG8' )
                                    , NA_VALOR8
                                    ##ENDFIELDP07
                                    ##FIELDP08( 'SN3.N3_VORIG9' )
                                    , NA_VALOR9
                                    ##ENDFIELDP08
                                    ##FIELDP09( 'SN3.N3_VORIG10' )
                                    , NA_VALOR10
                                    ##ENDFIELDP09
                                    ##FIELDP10( 'SN3.N3_VORIG11' )
                                    , NA_VALOR11
                                    ##ENDFIELDP10
                                    ##FIELDP11( 'SN3.N3_VORIG12' )
                                    , NA_VALOR12
                                    ##ENDFIELDP11
                                    ##FIELDP12( 'SN3.N3_VORIG13' )
                                    , NA_VALOR13
                                    ##ENDFIELDP12
                                    ##FIELDP13( 'SN3.N3_VORIG14' )
                                    , NA_VALOR14
                                    ##ENDFIELDP13
                                    ##FIELDP14( 'SN3.N3_VORIG15' )
                                    , NA_VALOR15
                                    ##ENDFIELDP14
                                    )
                        values ( @cFilial_SNA, @cConta, @IN_CUSTO, @IN_SUBCTA, @IN_CLVL, @IN_DATA, @IN_TIPO, @nTaxa,  @nValXX1,  @nValXX2,
                                    @nValXX3,     @nValXX4,  @nValXX5,  @iRecno
                                    ##FIELDP04( 'SNA.NA_TPBEM;NA_TPSALDO' )
                                    , @IN_TPBEM, @IN_TPSALDO
                                    ##ENDFIELDP04
                                    ##FIELDP05( 'SN3.N3_VORIG6' )
                                    ,  @nValXX5
                                    ##ENDFIELDP05
                                    ##FIELDP06( 'SN3.N3_VORIG7' )
                                    ,  @nValXX7
                                    ##ENDFIELDP06
                                    ##FIELDP07( 'SN3.N3_VORIG8' )
                                    ,  @nValXX8
                                    ##ENDFIELDP07
                                    ##FIELDP08( 'SN3.N3_VORIG9' )
                                    ,  @nValXX9
                                    ##ENDFIELDP08
                                    ##FIELDP09( 'SN3.N3_VORIG10' )
                                    ,  @nValXX10
                                    ##ENDFIELDP09
                                    ##FIELDP10( 'SN3.N3_VORIG11' )
                                    ,  @nValXX11
                                    ##ENDFIELDP10
                                    ##FIELDP11( 'SN3.N3_VORIG12' )
                                    ,  @nValXX12
                                    ##ENDFIELDP11
                                    ##FIELDP12( 'SN3.N3_VORIG13' )
                                    ,  @nValXX13
                                    ##ENDFIELDP12
                                    ##FIELDP13( 'SN3.N3_VORIG14' )
                                    ,  @nValXX14
                                    ##ENDFIELDP13
                                    ##FIELDP14( 'SN3.N3_VORIG15' )
                                    ,  @nValXX15
                                    ##ENDFIELDP14
                                    )
            commit tran
            end else begin
            Select @nValXX1 = NA_VALOR1, @nValXX2 = NA_VALOR2, @nValXX3 = NA_VALOR3, @nValXX4 = NA_VALOR4, @nValXX5 = NA_VALOR5
                         ##FIELDP05( 'SN3.N3_VORIG6' )
                         , @nValXX6 = NA_VALOR6
                        ##ENDFIELDP05
                        ##FIELDP06( 'SN3.N3_VORIG7' )
                        , @nValXX7 = NA_VALOR7
                        ##ENDFIELDP06
                        ##FIELDP07( 'SN3.N3_VORIG8' )
                        , @nValXX8 = NA_VALOR8
                        ##ENDFIELDP07
                        ##FIELDP08( 'SN3.N3_VORIG9' )
                        , @nValXX9 = NA_VALOR9
                        ##ENDFIELDP08
                        ##FIELDP09( 'SN3.N3_VORIG10' )
                        , @nValXX10 = NA_VALOR10
                        ##ENDFIELDP09
                        ##FIELDP10( 'SN3.N3_VORIG11' )
                        , @nValXX11 = NA_VALOR11
                        ##ENDFIELDP10
                        ##FIELDP11( 'SN3.N3_VORIG12' )
                        , @nValXX12 = NA_VALOR12
                        ##ENDFIELDP11
                        ##FIELDP12( 'SN3.N3_VORIG13' )
                        , @nValXX13 = NA_VALOR13
                        ##ENDFIELDP12
                        ##FIELDP13( 'SN3.N3_VORIG14' )
                        , @nValXX14 = NA_VALOR14
                        ##ENDFIELDP13
                        ##FIELDP14( 'SN3.N3_VORIG15' )
                        , @nValXX15 = NA_VALOR15
                        ##ENDFIELDP14
                From SNA###
                where R_E_C_N_O_ = @iRecno
            
            If @cSinal = '+' begin
                Select @nValXX1 = @nValXX1 + Round(@nValor1, @IN_CASA1 )
                Select @nValXX2 = @nValXX2 + Round(@nValor2, @IN_CASA2 )
                Select @nValXX3 = @nValXX3 + Round(@nValor3, @IN_CASA3 )
                Select @nValXX4 = @nValXX4 + Round(@nValor4, @IN_CASA4 )
                Select @nValXX5 = @nValXX5 + Round(@nValor5, @IN_CASA5 )
                ##FIELDP05( 'SN3.N3_VORIG6' )
                Select @nValXX5 = @nValXX6 + Round(@nValor6, @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = @nValXX7 + Round(@nValor7, @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = @nValXX8 + Round(@nValor8, @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = @nValXX9 + Round(@nValor9, @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = @nValXX10 + Round(@nValor10, @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = @nValXX11 + Round(@nValor11, @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = @nValXX12 + Round(@nValor12, @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = @nValXX13 + Round(@nValor13, @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = @nValXX14 + Round(@nValor14, @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = @nValXX15 + Round(@nValor15, @IN_CASA15 )
                ##ENDFIELDP14
            end else begin
                Select @nValXX1 = @nValXX1 - Round(@nValor1, @IN_CASA1 )
                Select @nValXX2 = @nValXX2 - Round(@nValor2, @IN_CASA2 )
                Select @nValXX3 = @nValXX3 - Round(@nValor3, @IN_CASA3 )
                Select @nValXX4 = @nValXX4 - Round(@nValor4, @IN_CASA4 )
                Select @nValXX5 = @nValXX5 - Round(@nValor5, @IN_CASA5 )
                ##FIELDP05( 'SN3.N3_VORIG6' )
                Select @nValXX6 = @nValXX6 - Round(@nValor6, @IN_CASA6 )
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                Select @nValXX7 = @nValXX7 - Round(@nValor7, @IN_CASA7 )
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                Select @nValXX8 = @nValXX8 - Round(@nValor8, @IN_CASA8 )
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                Select @nValXX9 = @nValXX9 - Round(@nValor9, @IN_CASA9 )
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                Select @nValXX10 = @nValXX10 - Round(@nValor10, @IN_CASA10 )
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                Select @nValXX11 = @nValXX11 - Round(@nValor11, @IN_CASA11 )
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                Select @nValXX12 = @nValXX12 - Round(@nValor12, @IN_CASA12 )
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                Select @nValXX13 = @nValXX3 - Round(@nValor13, @IN_CASA13 )
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                Select @nValXX14 = @nValXX14 - Round(@nValor14, @IN_CASA14 )
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                Select @nValXX15 = @nValXX15 - Round(@nValor15, @IN_CASA15 )
                ##ENDFIELDP14
            end
            begin tran
            Update SNA###
                Set NA_TAXA = @nTaxa, NA_VALOR1 = @nValXX1, NA_VALOR2 = @nValXX2, NA_VALOR3 = @nValXX3, NA_VALOR4 = @nValXX4, NA_VALOR5 = @nValXX5
                 ##FIELDP05( 'SN3.N3_VORIG6' )
                 , NA_VALOR6 = @nValXX6
                ##ENDFIELDP05
                ##FIELDP06( 'SN3.N3_VORIG7' )
                , NA_VALOR7 = @nValXX7
                ##ENDFIELDP06
                ##FIELDP07( 'SN3.N3_VORIG8' )
                , NA_VALOR8 = @nValXX8
                ##ENDFIELDP07
                ##FIELDP08( 'SN3.N3_VORIG9' )
                , NA_VALOR9 = @nValXX9
                ##ENDFIELDP08
                ##FIELDP09( 'SN3.N3_VORIG10' )
                , NA_VALOR10 = @nValXX10
                ##ENDFIELDP09
                ##FIELDP10( 'SN3.N3_VORIG11' )
                , NA_VALOR11 = @nValXX11
                ##ENDFIELDP10
                ##FIELDP11( 'SN3.N3_VORIG12' )
                , NA_VALOR12 = @nValXX12
                ##ENDFIELDP11
                ##FIELDP12( 'SN3.N3_VORIG13' )
                , NA_VALOR13 = @nValXX13
                ##ENDFIELDP12
                ##FIELDP13( 'SN3.N3_VORIG14' )
                , NA_VALOR14 = @nValXX14
                ##ENDFIELDP13
                ##FIELDP14( 'SN3.N3_VORIG15' )
                , NA_VALOR15 = @nValXX15
                ##ENDFIELDP14
                Where R_E_C_N_O_ = @iRecno
            commit tran
            end
            /* ----------------------------------------------------------------------------------
            Pontos de entrada - ATFGRSLD
            ---------------------------------------------------------------------------------- */
            Select @cTabela = 'SNA'
            Exec ATFGRSLD_## @cTipo, @cSinal, @cTabela, @iRecno
         
            Select @nValXX1 = NA_VALOR1, @nValXX2 = NA_VALOR2, @nValXX3 = NA_VALOR3, @nValXX4 = NA_VALOR4, @nValXX5 = NA_VALOR5,
                        ##FIELDP05( 'SN3.N3_VORIG6' )
                        @nValXX6 = NA_VALOR6,
                        ##ENDFIELDP05
                        ##FIELDP06( 'SN3.N3_VORIG7' )
                        @nValXX7 = NA_VALOR7,
                        ##ENDFIELDP06
                        ##FIELDP07( 'SN3.N3_VORIG8' )
                        @nValXX8 = NA_VALOR8,
                        ##ENDFIELDP07
                        ##FIELDP08( 'SN3.N3_VORIG9' )
                        @nValXX9 = NA_VALOR9,
                        ##ENDFIELDP08
                        ##FIELDP09( 'SN3.N3_VORIG10' )
                        @nValXX10 = NA_VALOR10,
                        ##ENDFIELDP09
                        ##FIELDP10( 'SN3.N3_VORIG11' )
                        @nValXX11 = NA_VALOR11,
                        ##ENDFIELDP10
                        ##FIELDP11( 'SN3.N3_VORIG12' )
                        @nValXX12 = NA_VALOR12,
                        ##ENDFIELDP11
                        ##FIELDP12( 'SN3.N3_VORIG13' )
                        @nValXX13 = NA_VALOR13,
                        ##ENDFIELDP12
                        ##FIELDP13( 'SN3.N3_VORIG14' )
                        @nValXX14 = NA_VALOR14,
                        ##ENDFIELDP13
                        ##FIELDP14( 'SN3.N3_VORIG15' )
                        @nValXX15 = NA_VALOR15,
                        ##ENDFIELDP14
                @iRecno = R_E_C_N_O_
            From SNA###
            where R_E_C_N_O_ = @iRecno
         
            If (@nValXX1 = 0) and (@nValXX2 = 0) and (@nValXX3 = 0) and (@nValXX4 = 0) and (@nValXX5 = 0) 
                    ##FIELDP05( 'SN3.N3_VORIG6' )
                     and (@nValXX6 = 0) 
                    ##ENDFIELDP05
                    ##FIELDP06( 'SN3.N3_VORIG7' )
                     and (@nValXX7 = 0) 
                    ##ENDFIELDP06
                    ##FIELDP07( 'SN3.N3_VORIG8' )
                     and (@nValXX8 = 0) 
                    ##ENDFIELDP07
                    ##FIELDP08( 'SN3.N3_VORIG9' )
                     and (@nValXX9 = 0) 
                    ##ENDFIELDP08
                    ##FIELDP09( 'SN3.N3_VORIG10' )
                     and (@nValXX10 = 0) 
                    ##ENDFIELDP09
                    ##FIELDP10( 'SN3.N3_VORIG11' )
                     and (@nValXX11 = 0) 
                    ##ENDFIELDP10
                    ##FIELDP11( 'SN3.N3_VORIG12' )
                     and (@nValXX12 = 0) 
                    ##ENDFIELDP11
                    ##FIELDP12( 'SN3.N3_VORIG13' )
                     and (@nValXX13 = 0) 
                    ##ENDFIELDP12
                    ##FIELDP13( 'SN3.N3_VORIG14' )
                     and (@nValXX14 = 0) 
                    ##ENDFIELDP13
                    ##FIELDP14( 'SN3.N3_VORIG15' )
                     and (@nValXX15 = 0) 
                    ##ENDFIELDP14     begin
            begin tran
            delete from SNA###
                where R_E_C_N_O_ = @iRecno
            commit tran
            End      
        end
    End
End
