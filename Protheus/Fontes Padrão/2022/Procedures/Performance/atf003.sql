Create Procedure ATF003_##
(
   @IN_FILIAL   Char( 'N4_FILIAL' ),
   @IN_CBASE    Char( 'N4_CBASE' ),
   @IN_ITEM     Char( 'N4_ITEM' ),
   @IN_TIPO     Char( 'N4_TIPO' ),
   @IN_OCORR    Char( 'N4_OCORR' ),
   @IN_MOTIVO   Char( 'N4_MOTIVO' ),
   @IN_TIPOCNT  Char( 'N4_TIPOCNT' ),
   @IN_CONTA    Char( 'N4_CONTA' ),
   @IN_DATA     Char( 08 ),
   @IN_QUANTD   Float,
   @IN_VLROC1   Float,
   @IN_VLROC2   Float,
   @IN_VLROC3   Float,
   @IN_VLROC4   Float,
   @IN_VLROC5   Float,
   @IN_SERIE    Char( 'N4_SERIE' ),
   @IN_NOTA     Char( 'N4_NOTA' ),
   @IN_VENDA    Float,
   @IN_TXMEDIA  Float,
   @IN_TXDEPR   Float,
   @IN_CCUSTO   Char( 'N4_CCUSTO' ),
   @IN_LOCAL    Char( 'N4_LOCAL' ),
   @IN_SEQ      Char( 'N4_SEQ' ),
   @IN_SUBCTA   Char( 'N4_SUBCTA' ),
   @IN_SEQREAV  Char( 'N4_SEQREAV' ),
   @IN_CODBAIX  Char( 'N4_CODBAIX' ),
   @IN_FILORIG  Char( 'N4_FILORIG' ),
   @IN_CLVL     Char( 'N4_CLVL' ),
   @IN_DCONTAB  Char( 'N4_DCONTAB' ),
   @IN_TPSALDO  Char( 01 ),
   @IN_QUANTPR  Float,
   @IN_IDMOV    Char( 10 ),
   @IN_TPBEM    Char( 02 ),
   @IN_CASA1    Integer,
   @IN_CASA2    Integer,
   @IN_CASA3    Integer,
   @IN_CASA4    Integer,
   @IN_CASA5    Integer
   ##FIELDP06( 'SN1.N1_CALCPIS' )
    , @IN_CALCPIS  Char( 01 )
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG6' )
   , @IN_VLROC6   Float
   , @IN_CASA6    Integer
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG7' )
    , @IN_VLROC7   Float
   , @IN_CASA7    Integer
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG8' )
    , @IN_VLROC8   Float
   , @IN_CASA8    Integer
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG9' )
    , @IN_VLROC9   Float
   , @IN_CASA9    Integer
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG10' )
    , @IN_VLROC10   Float
   , @IN_CASA10    Integer
    ##ENDFIELDP11
    ##FIELDP12( 'SN3.N3_VORIG11' )
    , @IN_VLROC11   Float
   , @IN_CASA11    Integer
    ##ENDFIELDP12
    ##FIELDP13( 'SN3.N3_VORIG12' )
    , @IN_VLROC12   Float
   , @IN_CASA12    Integer
    ##ENDFIELDP13
    ##FIELDP14( 'SN3.N3_VORIG13' )
    , @IN_VLROC13   Float
   , @IN_CASA13    Integer
    ##ENDFIELDP14
    ##FIELDP15( 'SN3.N3_VORIG14' )
    , @IN_VLROC14   Float
   , @IN_CASA14    Integer
    ##ENDFIELDP15
    ##FIELDP16( 'SN3.N3_VORIG15' )
    , @IN_VLROC15   Float
   , @IN_CASA15    Integer
    ##ENDFIELDP16
)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ATFA050.PRW </s>
    Descricao       - <d>  Gera linha de movimentos no SN4 </d>
    Funcao do Siga  -      Atfa050()
    Entrada         - <ri> @IN_FILIAL   - Filial
                           @IN_CBASE    - Codigo base do Ativo a ter o movimento gerado
                           @IN_ITEM     - Item Base do Ativo
                           @IN_TIPO     - tipo do Ativo
                           @IN_OCORR    - Descricao da ocorrencia , N4_OCORR
                           @IN_MOTIVO   - Motivo da ocorrencia, N4_MOTIVO
                           @IN_TIPOCNT  - Tipo de conta, N4_TIPOCNT
                           @IN_CONTA    - Conta que tera o movimento gerado, N4_CONTA
                           @IN_DATA     - Data do Moviemto
                           @IN_QUANTD   - Quantidade
                           @IN_VLROC1   - Vlr na Moeda1
                           @IN_VLROC2   - Vlr na Moeda2
                           @IN_VLROC3   - Vlr na Moeda3
                           @IN_VLROC4   - Vlr na Moeda4
                           @IN_VLROC5   - Vlr na Moeda5
                           @IN_SERIE    - Serie da Nota
                           @IN_NOTA     - Nota
                           @IN_VENDA    - vlr venda
                           @IN_TXMEDIA  - tx media
                           @IN_TXDEPR   - tax de depreciacao
                           @IN_CCUSTO   - CCusto
                           @IN_LOCAL    - Local
                           @IN_SEQ      - Sequencia, N4_SEQ
                           @IN_SUBCTA   - Subconta, N4_SUBCTA
                           @IN_SEQREAV  - Seqeuncia de reavaliacao, N4_SEQREAV
                           @IN_CODBAIX  - N4_CODBAIX
                           @IN_FILORIG  - filial origem
                           @IN_CLVL     - Classe de vlr
                           @IN_DCONTAB  - N4_DCONTAB
                           @IN_TPSALDO  - Tipo de saldo
                           @IN_QUANTPR  - Qtd Produzida
						         @IN_CALCPIS  - Calcula PIS
						         @IN_IDMOV    - id do Movimento
						         @IN_TPBEM - TIPO DE BEM SAUDE
                           @IN_CASA1   - Casas Decimais moeda 1
                           @IN_CASA2   - Casas Decimais moeda 2
                           @IN_CASA3   - Casas Decimais moeda 3
                           @IN_CASA4   - Casas Decimais moeda 4
                           @IN_CASA5   - Casas Decimais moeda 5  </ri>
    Saida           - <o>    </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     01/09/2006
-------------------------------------------------------------------------------------- */
Declare @nQUANTD  Float
Declare @nVLROC1  Float
Declare @nVLROC2  Float
Declare @nVLROC3  Float
Declare @nVLROC4  Float
Declare @nVLROC5  Float
Declare @nVENDA   Float
Declare @nTXMEDIA Float
Declare @nTXDEPR  Float
Declare @iRecno   Integer
##FIELDP07( 'SN3.N3_VORIG6' )
Declare @nVLROC6  Float
##ENDFIELDP07
##FIELDP08( 'SN3.N3_VORIG7' )
Declare @nVLROC7  Float
##ENDFIELDP08
##FIELDP09( 'SN3.N3_VORIG8' )
Declare @nVLROC8  Float
##ENDFIELDP09
##FIELDP10( 'SN3.N3_VORIG9' )
Declare @nVLROC9  Float
##ENDFIELDP10
##FIELDP11( 'SN3.N3_VORIG10' )
Declare @nVLROC10  Float
##ENDFIELDP11
##FIELDP12( 'SN3.N3_VORIG11' )
Declare @nVLROC11  Float
##ENDFIELDP12
##FIELDP13( 'SN3.N3_VORIG12' )
Declare @nVLROC12  Float
##ENDFIELDP13
##FIELDP14( 'SN3.N3_VORIG13' )
Declare @nVLROC13  Float
##ENDFIELDP14
##FIELDP15( 'SN3.N3_VORIG14' )
Declare @nVLROC14  Float
##ENDFIELDP15
##FIELDP16( 'SN3.N3_VORIG15' )
Declare @nVLROC15  Float
##ENDFIELDP16
begin
   
   Select @nQUANTD  = @IN_QUANTD
   Select @nVLROC1  = Round(@IN_VLROC1, @IN_CASA1)
   Select @nVLROC2  = Round(@IN_VLROC2, @IN_CASA2)
   Select @nVLROC3  = Round(@IN_VLROC3, @IN_CASA3)
   Select @nVLROC4  = Round(@IN_VLROC4, @IN_CASA4)
   Select @nVLROC5  = Round(@IN_VLROC5, @IN_CASA5)
   Select @nVENDA   = @IN_VENDA
   Select @nTXMEDIA = @IN_TXMEDIA
   Select @nTXDEPR  = Round(@IN_TXDEPR,6)
   Select @iRecno   = 0
   
    ##FIELDP07( 'SN3.N3_VORIG6' )
    Select @nVLROC6  = Round(@IN_VLROC6, @IN_CASA6)
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG7' )
    Select @nVLROC7  = Round(@IN_VLROC7, @IN_CASA7)
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG8' )
    Select @nVLROC8  = Round(@IN_VLROC8, @IN_CASA8)
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG9' )
    Select @nVLROC9  = Round(@IN_VLROC9, @IN_CASA9)
    ##ENDFIELDP10
    ##FIELDP11( 'SN3.N3_VORIG10' )
    Select @nVLROC10  = Round(@IN_VLROC10, @IN_CASA10)
    ##ENDFIELDP11
    ##FIELDP12( 'SN3.N3_VORIG11' )
    Select @nVLROC11  = Round(@IN_VLROC11, @IN_CASA11)
    ##ENDFIELDP12
    ##FIELDP13( 'SN3.N3_VORIG12' )
    Select @nVLROC12  = Round(@IN_VLROC12, @IN_CASA12)
    ##ENDFIELDP13
    ##FIELDP14( 'SN3.N3_VORIG13' )
    Select @nVLROC13  = Round(@IN_VLROC13, @IN_CASA13)
    ##ENDFIELDP14
    ##FIELDP15( 'SN3.N3_VORIG14' )
    Select @nVLROC14  = Round(@IN_VLROC14, @IN_CASA14)
    ##ENDFIELDP15
    ##FIELDP16( 'SN3.N3_VORIG15' )
    Select @nVLROC15  = Round(@IN_VLROC15, @IN_CASA15)
    ##ENDFIELDP16

   select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from SN4### 
   Select @iRecno = @iRecno + 1
  
   begin tran
   ##TRATARECNO @iRecno\   
   
   insert into SN4###( N4_FILIAL,  N4_CBASE,  N4_ITEM,   N4_TIPO,    N4_OCORR,    N4_MOTIVO,   N4_TIPOCNT,  N4_CONTA,  N4_DATA,     N4_QUANTD,
                       N4_VLROC1,  N4_VLROC2, N4_VLROC3, N4_VLROC4,  N4_VLROC5,   N4_SERIE,    N4_NOTA,     N4_VENDA,  N4_TXMEDIA,  N4_TXDEPR,
                       N4_CCUSTO,  N4_LOCAL,  N4_SEQ,    N4_SUBCTA,  N4_SEQREAV,  N4_CODBAIX,  N4_FILORIG,  N4_CLVL,   N4_DCONTAB,  R_E_C_N_O_
                     ##FIELDP01( 'SN4.N4_TPSALDO;N4_QUANTPR' )
                        , N4_TPSALDO, N4_QUANTPR
                     ##ENDFIELDP01
                     ##FIELDP02( 'SN4.N4_CALCPIS' )
                        , N4_CALCPIS
                     ##ENDFIELDP02
                     ##FIELDP03( 'SN4.N4_IDMOV' )
                        , N4_IDMOV
                     ##ENDFIELDP03
                     ##FIELDP04( 'SN4.N4_TPBEM' )
                        , N4_TPBEM
                     ##ENDFIELDP04
                     ##FIELDP05( 'SN4.N4_ORIGEM;N4_LP;N4_LA' )
                        , N4_ORIGEM, N4_LP, N4_LA 
                     ##ENDFIELDP05
                     ##FIELDP07( 'SN3.N3_VORIG6' )
                     ,  N4_VLROC6
                     ##ENDFIELDP07
                     ##FIELDP08( 'SN3.N3_VORIG7' )
                     ,  N4_VLROC7
                     ##ENDFIELDP08
                     ##FIELDP09( 'SN3.N3_VORIG8' )
                     ,  N4_VLROC8
                     ##ENDFIELDP09
                     ##FIELDP10( 'SN3.N3_VORIG9' )
                     ,  N4_VLROC9
                     ##ENDFIELDP10
                     ##FIELDP11( 'SN3.N3_VORIG10' )
                     ,  N4_VLROC10
                     ##ENDFIELDP11
                     ##FIELDP12( 'SN3.N3_VORIG11' )
                     ,  N4_VLROC11
                     ##ENDFIELDP12
                     ##FIELDP13( 'SN3.N3_VORIG12' )
                     ,  N4_VLROC12
                     ##ENDFIELDP13
                     ##FIELDP14( 'SN3.N3_VORIG13' )
                     ,  N4_VLROC13
                     ##ENDFIELDP14
                     ##FIELDP15( 'SN3.N3_VORIG14' )
                     ,  N4_VLROC14
                     ##ENDFIELDP15
                     ##FIELDP16( 'SN3.N3_VORIG15' )
                     ,  N4_VLROC15
                     ##ENDFIELDP16
                         )
               Values( @IN_FILIAL, @IN_CBASE, @IN_ITEM,  @IN_TIPO,   @IN_OCORR,   @IN_MOTIVO,  @IN_TIPOCNT, @IN_CONTA, @IN_DATA,    @nQUANTD,
                       @nVLROC1,   @nVLROC2,  @nVLROC3,  @nVLROC4,   @nVLROC5,    @IN_SERIE,   @IN_NOTA,    @nVENDA,   @nTXMEDIA,   @nTXDEPR,
                       @IN_CCUSTO, @IN_LOCAL, @IN_SEQ,   @IN_SUBCTA, @IN_SEQREAV, @IN_CODBAIX, @IN_FILORIG, @IN_CLVL,  @IN_DCONTAB, @iRecno
                     ##FIELDP01( 'SN4.N4_TPSALDO;N4_QUANTPR' )
                        , @IN_TPSALDO, @IN_QUANTPR
                     ##ENDFIELDP01
                     ##FIELDP02( 'SN4.N4_CALCPIS' )
                        , @IN_CALCPIS
                     ##ENDFIELDP02
                     ##FIELDP03( 'SN4.N4_IDMOV' )
                        , @IN_IDMOV
                     ##ENDFIELDP03
                     ##FIELDP04( 'SN4.N4_TPBEM' )
                        , N4_TPBEM
                     ##ENDFIELDP04
                     ##FIELDP05( 'SN4.N4_ORIGEM;N4_LP;N4_LA' )
                        , 'ATFA050', '820', 'N' 
                     ##ENDFIELDP05
                     ##FIELDP07( 'SN3.N3_VORIG6' )
                     ,  @nVLROC6
                     ##ENDFIELDP07
                     ##FIELDP08( 'SN3.N3_VORIG7' )
                     ,  @nVLROC7
                     ##ENDFIELDP08
                     ##FIELDP09( 'SN3.N3_VORIG8' )
                     ,  @nVLROC8
                     ##ENDFIELDP09
                     ##FIELDP10( 'SN3.N3_VORIG9' )
                     ,  @nVLROC9
                     ##ENDFIELDP10
                     ##FIELDP11( 'SN3.N3_VORIG10' )
                     ,  @nVLROC10
                     ##ENDFIELDP11
                     ##FIELDP12( 'SN3.N3_VORIG11' )
                     ,  @nVLROC11
                     ##ENDFIELDP12
                     ##FIELDP13( 'SN3.N3_VORIG12' )
                     ,  @nVLROC12
                     ##ENDFIELDP13
                     ##FIELDP14( 'SN3.N3_VORIG13' )
                     ,  @nVLROC13
                     ##ENDFIELDP14
                     ##FIELDP15( 'SN3.N3_VORIG14' )
                     ,  @nVLROC14
                     ##ENDFIELDP15
                     ##FIELDP16( 'SN3.N3_VORIG15' )
                     ,  @nVLROC15
                     ##ENDFIELDP16
                     )
	##FIMTRATARECNO
    commit tran		 
End
