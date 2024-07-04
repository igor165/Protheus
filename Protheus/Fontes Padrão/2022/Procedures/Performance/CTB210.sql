##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
##FIELDP01( 'CT0.CT0_ID' )
Create procedure CTB210_##
(  
   @IN_FILIAL       Char( 'CT2_FILIAL' ),
   @IN_DATA         Char( 08 ),
   @IN_MOEDA        Char( 'CT7_MOEDA' ),
   @IN_TPSALDO      Char( 'CT2_TPSALD' ),
   @IN_NIV01        Char( 'CVY_NIV01' ), 
   @IN_NIV02        Char( 'CVY_NIV02' ), 
   @IN_NIV03        Char( 'CVY_NIV03' ), 
   @IN_NIV04        Char( 'CVY_NIV04' ), 
   ##FIELDP02( 'CT2.CT2_EC05DB')
    @IN_NIV05       Char( 'CT2_EC05DB' ), 
   ##ENDFIELDP02
   ##FIELDP03( 'CT2.CT2_EC06DB' )
    @IN_NIV06       Char( 'CT2_EC06DB' ), 
   ##ENDFIELDP03
   ##FIELDP04( 'CT2.CT2_EC07DB' )
    @IN_NIV07       Char( 'CT2_EC07DB' ), 
   ##ENDFIELDP04
   ##FIELDP05( 'CT2.CT2_EC08DB' )
    @IN_NIV08       Char( 'CT2_EC08DB' ), 
   ##ENDFIELDP05
   ##FIELDP06( 'CT2.CT2_EC09DB' )
    @IN_NIV09      Char( 'CT2_EC09DB' ),
   ##ENDFIELDP06
   @IN_CUBO         Char( 'CT0_ID' ),
   @IN_ATU          Char( 01 ),
   @IN_VALD         Float,
   @IN_VALC         Float
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Descricao       - <d>  Reprocessamento SigaCTB </d>
    Procedure       -      Excluir saldos do CVX e CVY
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL      - Filial Corrente
                           @IN_DATA        - Data Inicial
                           @IN_MOEDA       - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO     - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_NIV01       - Conta, entidade de nivel 1
                           @IN_NIV02       - Ccusto, entidade de nivel 2
                           @IN_NIV03       - Item, entidade de nivel 3
                           @IN_NIV04       - Classe de valor, entidade de nivel 4
                           .....
                           @IN_NIV09        - Entidade nove, entidade de nivel 9
                           @IN_ATU          - Saldo a ser atualizado 1 - CVX, 2 - CVY, 3 - AMBOS
                           @IN_VALD         - Conta , entidade de nivel 1
                           @IN_VALC         - Conta , entidade de nivel 1
    Saida           - <o>   </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     10/05/2010
   -------------------------------------------------------------------------------------- */
declare @cAux        char( 03 )
declare @cFilial_CT0 char( 'CT0_FILIAL' )
Declare @cCT0_CONTR  char( 'CT0_CONTR' )
Declare @cUPDATEVAL  char( 01 )

begin
   
   Select @cCT0_CONTR = ' '
   Select @cAux = 'CT0'
   Select @cUPDATEVAL = '0'
   
   ##IF_002({|| cPaisLoc == "RUS" .And. SuperGetMV("MV_REDSTOR",.F.,.F.)})
	If ( Round(@IN_VALD, 2 ) <> 0.00 or Round(@IN_VALC, 2 ) <> 0.00 ) begin
      Select @cUPDATEVAL = '1'
   end else begin
      Select @cUPDATEVAL = '0'
   End
   ##ELSE_002
   If (Round(@IN_VALD, 2 ) > 0.00 or Round(@IN_VALC, 2 ) > 0.00) begin
      select @cUPDATEVAL = '1'
   End
   ##ENDIF_002
      
   Exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT0 OutPut

   Select @cCT0_CONTR = CT0_CONTR
     From CT0###
    Where CT0_FILIAL = @cFilial_CT0
      and CT0_ID     = @IN_CUBO
      and D_E_L_E_T_ = ' '
   
   If ( @cCT0_CONTR = '1' and @IN_CUBO = '01' ) begin
      If @cUPDATEVAL = '1' begin
         Exec CTB200_## @IN_ATU, @IN_CUBO, @IN_FILIAL, @IN_MOEDA, @IN_TPSALDO, @IN_DATA, @IN_NIV01, @IN_VALD, @IN_VALC
      End
   End
   
   If @cCT0_CONTR = '1' and @IN_CUBO = '02'  begin
      If @cUPDATEVAL = '1' begin
  
         Exec CTB201_## @IN_ATU, @IN_CUBO, @IN_FILIAL, @IN_MOEDA, @IN_TPSALDO, @IN_DATA, @IN_NIV01, @IN_NIV02, @IN_VALD, @IN_VALC

      End
   End
   
   If @cCT0_CONTR = '1' and @IN_CUBO = '03'  begin
      If @cUPDATEVAL = '1' begin
         Exec CTB202_## @IN_ATU, @IN_CUBO, @IN_FILIAL, @IN_MOEDA, @IN_TPSALDO, @IN_DATA, @IN_NIV01, @IN_NIV02, @IN_NIV03, @IN_VALD, @IN_VALC
      End
   End
   
   If @cCT0_CONTR = '1' and @IN_CUBO = '04'  begin
      If @cUPDATEVAL = '1' begin
         Exec CTB203_## @IN_ATU, @IN_CUBO, @IN_FILIAL, @IN_MOEDA, @IN_TPSALDO, @IN_DATA, @IN_NIV01, @IN_NIV02, @IN_NIV03, @IN_NIV04, @IN_VALD, @IN_VALC
      End
   End
   ##FIELDP07( 'CT2.CT2_EC05DB' )
   
   If @cCT0_CONTR = '1' and @IN_CUBO = '05'  begin
      If @cUPDATEVAL = '1' begin
         Exec CTB204_## @IN_ATU, @IN_CUBO, @IN_FILIAL, @IN_MOEDA, @IN_TPSALDO, @IN_DATA, @IN_NIV01, @IN_NIV02, @IN_NIV03, @IN_NIV04, @IN_NIV05, @IN_VALD, @IN_VALC
      End
   End
   ##ENDFIELDP07
   ##FIELDP08( 'CT2.CT2_EC06DB' )
   
   If @cCT0_CONTR = '1' and @IN_CUBO = '06' begin
      If @cUPDATEVAL = '1' begin
         Exec CTB205_## @IN_ATU, @IN_CUBO, @IN_FILIAL, @IN_MOEDA, @IN_TPSALDO, @IN_DATA, @IN_NIV01, @IN_NIV02, @IN_NIV03, @IN_NIV04, @IN_NIV05, @IN_NIV06, @IN_VALD, @IN_VALC
      End
   End
   ##ENDFIELDP08
   ##FIELDP09( 'CT2.CT2_EC07DB' )
   
   If @cCT0_CONTR = '1' and @IN_CUBO = '07' begin
		If @cUPDATEVAL = '1' begin
          Exec CTB206_## @IN_ATU, @IN_CUBO, @IN_FILIAL, @IN_MOEDA, @IN_TPSALDO, @IN_DATA, @IN_NIV01, @IN_NIV02, @IN_NIV03, @IN_NIV04, @IN_NIV05, @IN_NIV06, @IN_NIV07, @IN_VALD, @IN_VALC
      End
   End
   ##ENDFIELDP09
   ##FIELDP10( 'CT2.CT2_EC08DB' )
   
   If @cCT0_CONTR = '1' and @IN_CUBO = '08' begin
      If @cUPDATEVAL = '1' begin
         Exec CTB207_## @IN_ATU, @IN_CUBO, @IN_FILIAL, @IN_MOEDA, @IN_TPSALDO, @IN_DATA, @IN_NIV01, @IN_NIV02, @IN_NIV03, @IN_NIV04, @IN_NIV05, @IN_NIV06, @IN_NIV07, @IN_NIV08, @IN_VALD, @IN_VALC
      End
   End
   ##ENDFIELDP10
   ##FIELDP11( 'CT2.CT2_EC09DB' )
   
   If @cCT0_CONTR = '1' and @IN_CUBO = '09' begin
      If @cUPDATEVAL = '1' begin
         Exec CTB208_## @IN_ATU, @IN_CUBO, @IN_FILIAL, @IN_MOEDA, @IN_TPSALDO, @IN_DATA, @IN_NIV01, @IN_NIV02, @IN_NIV03, @IN_NIV04, @IN_NIV05, @IN_NIV06, @IN_NIV07, @IN_NIV08, @IN_NIV09, @IN_VALD, @IN_VALC
      End
   End
   ##ENDFIELDP11
End
##ENDFIELDP01
##ENDIF_001
