##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
##FIELDP11( 'CT0.CT0_ID' )
Create Procedure CTB156_##(
   @IN_FILIAL     Char( 'CT7_FILIAL' ),
   @IN_CONTAD     Char( 'CT7_CONTA' ),
   @IN_CONTAC     Char( 'CT7_CONTA' ),
   @IN_CUSTOD     Char( 'CT3_CUSTO' ),
   @IN_CUSTOC     Char( 'CT3_CUSTO' ),
   @IN_ITEMD      Char( 'CT4_ITEM' ),
   @IN_ITEMC      Char( 'CT4_ITEM' ),
   @IN_CLVLD      Char( 'CTI_CLVL' ),
   @IN_CLVLC      Char( 'CTI_CLVL' ),
   ##FIELDP01( 'CT2.CT2_EC05DB' )
      @IN_NIV05D Char( 'CT2_EC05DB' ),
      @IN_NIV05C Char( 'CT2_EC05DB' ),
   ##ENDFIELDP01
   ##FIELDP02( 'CT2.CT2_EC06DB' )
      @IN_NIV06D Char( 'CT2_EC06DB' ),
      @IN_NIV06C Char( 'CT2_EC06DB' ),
   ##ENDFIELDP02
   ##FIELDP03( 'CT2.CT2_EC07DB' )
      @IN_NIV07D Char( 'CT2_EC07DB' ),
      @IN_NIV07C Char( 'CT2_EC07DB' ),
   ##ENDFIELDP03
   ##FIELDP04( 'CT2.CT2_EC08DB' )
      @IN_NIV08D Char( 'CT2_EC08DB' ),
      @IN_NIV08C Char( 'CT2_EC08DB' ),
   ##ENDFIELDP04
   ##FIELDP05( 'CT2.CT2_EC09DB' )
      @IN_NIV09D Char( 'CT2_EC09DB' ),
      @IN_NIV09C Char( 'CT2_EC09DB' ),
   ##ENDFIELDP05
   @IN_MOEDA      Char( 'CT7_MOEDA' ),
   @IN_DC         Char( 'CT2_DC' ),
   @IN_DATA       Char( 08 ),
   @IN_TPSALD     Char( 'CT7_TPSALD' ),
   @IN_VALOR      Float,
   @OUT_RESULT    Char( 01) OutPut
)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA102.PRW </s>
    Descricao       - <d>  Faz a chamada da operacao ( Inclusao/Alteracao/Exclusao) </d>
    Funcao do Siga  -      CTB102Proc()
    Entrada         - <ri> @IN_FILIAL       - Filial corrente da manutencao do arquivo de lanctos
                           @IN_CONTAD       - Conta a Débito
                           @IN_CONTAC       - Conta Crébito
                           @IN_CUSTOD       - CCusto a Débito
                           @IN_CUSTOC       - CCusto Crébito
                           @IN_ITEMD        - Item Débito
                           @IN_ITEMC        - Item Crébito
                           @IN_CLVLD        - ClVl Débito
                           @IN_CLVLC        - ClVl Crébito
                           @IN_MOEDA        - Moeda do Lancto
                           @IN_DC           - Natureza do Lancto (1-Débito, 2-Crédito, 3-Partida Dobrada)
                           @IN_DATA         - Data do Lancto
                           @IN_TPSALDO      - Tipo de Saldo
                           @IN_VALOR        - Valor Atual
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  	</r>
   --------------------------------------------------------------------------------------------------------------------- */
Declare @cFilial_CT0 Char( 'CT2_FILIAL' )
Declare @cAux        char( 03)
Declare @cCT0_CONTR  Char( 'CT0_CONTR' )
Declare @cAtu        Char( 01 )
Declare @cCubo       Char( 'CT0_ID' )
Declare @nValorAux   Float

begin
   select @OUT_RESULT = '0'
   select @cAtu    = '3'
   select @cCT0_CONTR = ' '
   select @nValorAux = 0
   
   select @cAux    = 'CT0'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT0 OutPut
   /* --------------------------------------------------------------------
      CUBO 01 - PLANO DE CONTAS
     -------------------------------------------------------------------- */
   Select @cCubo = '01'
   Select @cCT0_CONTR = CT0_CONTR
     From CT0###
    Where CT0_FILIAL = @cFilial_CT0
      and CT0_ID     = @cCubo
      and D_E_L_E_T_ = ' '
   
   If @cCT0_CONTR = '1' begin
      If @IN_DC IN ( '1','3' ) and @IN_CONTAD != ' ' begin
         Exec CTB200_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAD, @IN_VALOR, @nValorAux
      End
      If @IN_DC IN ( '2','3' ) and @IN_CONTAC != ' ' begin
         Exec CTB200_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAC, @nValorAux, @IN_VALOR
      End
   End
   /*--------------------------------------------------------------------
      CUBO 02 - CCUSTO
     -------------------------------------------------------------------- */
   Select @cCubo = '02'
   Select @cCT0_CONTR = CT0_CONTR
     From CT0###
    Where CT0_FILIAL = @cFilial_CT0
      and CT0_ID     = @cCubo
      and D_E_L_E_T_ = ' '
   
   If @cCT0_CONTR = '1' begin
      If @IN_DC IN ( '1','3' )  and @IN_CONTAD != ' ' begin
         Exec CTB201_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAD, @IN_CUSTOD, @IN_VALOR, @nValorAux
      end
      If @IN_DC IN ( '2','3' ) and @IN_CONTAC != ' ' begin
         Exec CTB201_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAC, @IN_CUSTOC, @nValorAux, @IN_VALOR
      End
   End
   /*--------------------------------------------------------------------
      CUBO 03 - ITEM
     -------------------------------------------------------------------- */
   Select @cCubo = '03'
   Select @cCT0_CONTR = CT0_CONTR
     From CT0###
    Where CT0_FILIAL = @cFilial_CT0
      and CT0_ID     = @cCubo
      and D_E_L_E_T_ = ' '
   
   If @cCT0_CONTR = '1' begin
      If @IN_DC IN ( '1','3' ) and @IN_CONTAD != ' ' begin
         Exec CTB202_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAD, @IN_CUSTOD, @IN_ITEMD, @IN_VALOR, @nValorAux
      End
      If @IN_DC IN ( '2','3' ) and @IN_CONTAC != ' ' begin
         Exec CTB202_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC, @nValorAux, @IN_VALOR
      End
   End
   /*--------------------------------------------------------------------
      CUBO 04 - CLVL
     -------------------------------------------------------------------- */
   Select @cCubo = '04'
   Select @cCT0_CONTR = CT0_CONTR
     From CT0###
    Where CT0_FILIAL = @cFilial_CT0
      and CT0_ID     = @cCubo
      and D_E_L_E_T_ = ' '
   
   If @cCT0_CONTR = '1' begin
      If @IN_DC IN ( '1','3' ) and @IN_CONTAD != ' ' begin
         Exec CTB203_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAD, @IN_CUSTOD, @IN_ITEMD, @IN_CLVLD, @IN_VALOR, @nValorAux
      End
      If @IN_DC IN ( '2','3' ) and @IN_CONTAC != ' ' begin
         Exec CTB203_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC, @IN_CLVLC, @nValorAux, @IN_VALOR
      End
   End
   /*--------------------------------------------------------------------
      CUBO 05
     -------------------------------------------------------------------- */
   ##FIELDP06( 'CT2.CT2_EC05DB' )
   Select @cCubo = '05'
   Select @cCT0_CONTR = CT0_CONTR
     From CT0###
    Where CT0_FILIAL = @cFilial_CT0
      and CT0_ID     = @cCubo
      and D_E_L_E_T_ = ' '
   
   If @cCT0_CONTR = '1' begin
      If @IN_DC IN ( '1','3' ) and @IN_CONTAD != ' ' begin
         Exec CTB204_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAD, @IN_CUSTOD, @IN_ITEMD, @IN_CLVLD, @IN_NIV05D, @IN_VALOR, @nValorAux
      End
      If @IN_DC IN ( '2','3' ) and @IN_CONTAC != ' ' begin
         Exec CTB204_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC, @IN_CLVLC, @IN_NIV05C, @nValorAux, @IN_VALOR
      End
   End
   ##ENDFIELDP06
   /*--------------------------------------------------------------------
      CUBO 06
     -------------------------------------------------------------------- */
   ##FIELDP07( 'CT2.CT2_EC06DB' )
   Select @cCubo = '06'
   Select @cCT0_CONTR = CT0_CONTR
     From CT0###
    Where CT0_FILIAL = @cFilial_CT0
      and CT0_ID     = @cCubo
      and D_E_L_E_T_ = ' '
   
   If @cCT0_CONTR = '1' begin
      If @IN_DC IN ( '1','3' ) and @IN_CONTAD != ' ' begin
         Exec CTB205_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAD, @IN_CUSTOD, @IN_ITEMD, @IN_CLVLD, @IN_NIV05D, @IN_NIV06D, @IN_VALOR, @nValorAux
      End
      If @IN_DC IN ( '2','3' ) and @IN_CONTAC != ' ' begin
         Exec CTB205_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC, @IN_CLVLC, @IN_NIV05C, @IN_NIV06C, @nValorAux, @IN_VALOR
      End
   End
   ##ENDFIELDP07
   /*--------------------------------------------------------------------
      CUBO 07
     -------------------------------------------------------------------- */
   ##FIELDP08( 'CT2.CT2_EC07DB' )
   Select @cCubo = '07'
   Select @cCT0_CONTR = CT0_CONTR
     From CT0###
    Where CT0_FILIAL = @cFilial_CT0
      and CT0_ID     = @cCubo
      and D_E_L_E_T_ = ' '
   
   If @cCT0_CONTR = '1' begin
      If @IN_DC IN ( '1','3' ) and @IN_CONTAD != ' ' begin
         Exec CTB206_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAD, @IN_CUSTOD, @IN_ITEMD, @IN_CLVLD, @IN_NIV05D, @IN_NIV06D, @IN_NIV07D, @IN_VALOR, @nValorAux
      End
      If @IN_DC IN ( '2','3' ) and @IN_CONTAC != ' ' begin
         Exec CTB206_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC, @IN_CLVLC, @IN_NIV05C, @IN_NIV06C, @IN_NIV07C, @nValorAux, @IN_VALOR
      End
   End
   ##ENDFIELDP08
   /*--------------------------------------------------------------------
      CUBO 08
     -------------------------------------------------------------------- */
   ##FIELDP09( 'CT2.CT2_EC08DB' )
   Select @cCubo = '08'
   Select @cCT0_CONTR = CT0_CONTR
     From CT0###
    Where CT0_FILIAL = @cFilial_CT0
      and CT0_ID     = @cCubo
      and D_E_L_E_T_ = ' '
   
   If @cCT0_CONTR = '1' begin
      If @IN_DC IN ( '1','3' ) and @IN_CONTAD != ' ' begin
         Exec CTB207_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAD, @IN_CUSTOD, @IN_ITEMD, @IN_CLVLD, @IN_NIV05D, @IN_NIV06D, @IN_NIV07D, @IN_NIV08D, @IN_VALOR, @nValorAux
      End
      If @IN_DC IN ( '2','3' ) and @IN_CONTAC != ' ' begin
         Exec CTB207_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC, @IN_CLVLC, @IN_NIV05C, @IN_NIV06C, @IN_NIV07C, @IN_NIV08C, @nValorAux, @IN_VALOR
      End
   End
   ##ENDFIELDP09
   /*--------------------------------------------------------------------
      CUBO 09
     -------------------------------------------------------------------- */
   ##FIELDP10( 'CT2.CT2_EC09DB' )
   Select @cCubo = '09'
   Select @cCT0_CONTR = CT0_CONTR
     From CT0###
    Where CT0_FILIAL = @cFilial_CT0
      and CT0_ID     = @cCubo
      and D_E_L_E_T_ = ' '
   
   If @cCT0_CONTR = '1' begin
      If @IN_DC IN ( '1','3' ) and @IN_CONTAD != ' ' begin
         Exec CTB208_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAD, @IN_CUSTOD, @IN_ITEMD, @IN_CLVLD, @IN_NIV05D, @IN_NIV06D, @IN_NIV07D, @IN_NIV08D, @IN_NIV09D, @IN_VALOR, @nValorAux
      End
      If @IN_DC IN ( '2','3' ) and @IN_CONTAC != ' ' begin
         Exec CTB208_## @cAtu, @cCubo, @IN_FILIAL, @IN_MOEDA, @IN_TPSALD, @IN_DATA, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC, @IN_CLVLC, @IN_NIV05C, @IN_NIV06C, @IN_NIV07C, @IN_NIV08C, @IN_NIV09C, @nValorAux, @IN_VALOR
      End
   End
   ##ENDFIELDP10
   select @OUT_RESULT = '1'
End
##ENDFIELDP11
##ENDIF_001