##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
##FIELDP01( 'CT0.CT0_ID' )
Create procedure CTB209_##
(  
   @IN_FILIAL       Char( 'CT2_FILIAL' ),
   @IN_FILIALATE    Char( 'CT2_FILIAL' ),
   @IN_DATADE       Char( 08 ),
   @IN_DATAATE      Char( 08 ),
   @IN_LMOEDAESP    Char( 01 ),
   @IN_MOEDA        Char( 'CT7_MOEDA' ),
   @IN_TPSALDO      Char( 'CT2_TPSALD' )
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Descricao       - <d>  Reprocessamento SigaCTB </d>
    Procedure       -      Excluir saldos do CVX e CVY
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente
                           @IN_FILIALATE    - Filial final do processamento
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
    Saida           - <o>   </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     10/05/2010
   -------------------------------------------------------------------------------------- */
declare @cAux        char( 03 )
declare @cFilial_CVX char( 'CVX_FILIAL' )
declare @cFilial_CVY char( 'CVY_FILIAL' )
declare @cFilial_CT0 char( 'CT0_FILIAL' )
Declare @cDataI      Char( 08 )
Declare @cDataF      Char( 08 )
Declare @cData       Char( 06 )
Declare @cDataIn     Char( 08 )
Declare @cDataOut    Char( 08 )
Declare @cFil_CVX    Char( 'CVX_FILIAL' )
Declare @cConfig     Char( 'CVX_CONFIG' )
Declare @cMoeda      Char( 'CVX_MOEDA' )
Declare @cTpSaldo    Char( 'CVX_TPSALD' )
Declare @cNiv01      Char( 'CVX_NIV01' )
Declare @cNiv02      Char( 'CVX_NIV02' )
Declare @cNiv03      Char( 'CVX_NIV03' )
Declare @cNiv04      Char( 'CVX_NIV04' )
##FIELDP02( 'CT2.CT2_EC05DB' )
Declare @cNiv05      Char( 'CT2_EC05DB' )
##ENDFIELDP02
##FIELDP03( 'CT2.CT2_EC06DB' )
Declare @cNiv06      Char( 'CT2_EC06DB' )
##ENDFIELDP03
##FIELDP04( 'CT2.CT2_EC07DB' )
Declare @cNiv07      Char( 'CT2_EC07DB' )
##ENDFIELDP04
##FIELDP05( 'CT2.CT2_EC08DB' )
Declare @cNiv08      Char( 'CT2_EC08DB' )
##ENDFIELDP05
##FIELDP06( 'CT2.CT2_EC09DB' )
Declare @cNiv09      Char( 'CT2_EC09DB' )
##ENDFIELDP06
Declare @nCred       Float
Declare @nDeb        Float
Declare @cAtu        Char( 01 )
Declare @cCT0_CONTR  char( 'CT0_CONTR' )
Declare @iRecnoCVX   integer
Declare @iRecnoCVY   integer
Declare @iNroReg     integer
Declare @iTranCount  integer
Declare @cUPDATEVAL  char( 01 )

begin
   select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
   Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
   
   select @iRecnoCVX = 0 
   select @iRecnoCVY = 0
   SELECT @iNroReg   = 0
   select @cAtu = '2'
   select @cDataOut = ' '
   Select @cUPDATEVAL = '0'
   
   Select @cAux = 'CVX'
   Exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CVX OutPut
   Select @cAux = 'CVY'
   Exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CVY OutPut
   Select @cAux = 'CT0'
   Exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT0 OutPut
   /* ---------------------------------------------------------------------------------
      Exclusao de CVX - Saldos Diários  
      ---------------------------------------------------------------------------------- */
   Declare CUR_CVX insensitive cursor for
    select IsNull( CVX.R_E_C_N_O_, 0 )
      from CVX### CVX, CT0### CT0
     where CVX.CVX_FILIAL between @cFilial_CVX and @IN_FILIALATE
       and CVX.CVX_DATA   between @IN_DATADE   and @IN_DATAATE
       and ((CVX.CVX_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
       and CVX_TPSALD     = @IN_TPSALDO
       and CVX.D_E_L_E_T_ = ' '
       and CT0.CT0_FILIAL between @cFilial_CT0 and @IN_FILIALATE
       and CT0.CT0_CONTR  = '1'
       and CT0.CT0_ID     = CVX_CONFIG
       and CT0.D_E_L_E_T_ = ' '
   for read only
   Open CUR_CVX
   Fetch CUR_CVX into @iRecnoCVX
   
   While ( @@Fetch_status = 0 ) begin
      select @iNroReg = @iNroReg + 1
      If @iNroReg = 1 begin
         begin tran
         select @iNroReg = @iNroReg
      End
      
      Delete from CVX###
       Where R_E_C_N_O_ = @iRecnoCVX
      
      If @iNroReg > 30000 begin
         commit transaction
         select @iNroReg = 0
      End
      SELECT @fim_CUR = 0
      Fetch CUR_CVX into @iRecnoCVX
   End
   close CUR_CVX
   deallocate CUR_CVX
   
   If @iNroReg > 0 begin
      commit transaction
      select @iTranCount = 0
   End
   /* ---------------------------------------------------------------------------------
      Exclusao de CVY - Saldos Mensais
      ---------------------------------------------------------------------------------- */
   select @iNroReg = 0
   Declare CUR_CVY insensitive cursor for
   select IsNull( CVY.R_E_C_N_O_, 0 )
     from CVY### CVY, CT0### CT0
    where CVY.CVY_FILIAL between @cFilial_CVY and @IN_FILIALATE
      and CVY.CVY_DATA   between @cDataI and @cDataF
      and ((CVY.CVY_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
      and CVY_TPSALD     = @IN_TPSALDO
      and CVY.D_E_L_E_T_ = ' '
      and CT0.CT0_FILIAL between @cFilial_CT0 and @IN_FILIALATE
      and CT0.CT0_CONTR  = '1'
      and CT0.CT0_ID     = CVY_CONFIG
      and CT0.D_E_L_E_T_ = ' '
   for read only
   Open CUR_CVY
   Fetch CUR_CVY into @iRecnoCVY
   
   While ( @@Fetch_status = 0 ) begin
      select @iNroReg = @iNroReg + 1
      If @iNroReg = 1 begin
         begin tran
         select @iNroReg = @iNroReg
      End
       Delete from CVY###
       Where R_E_C_N_O_ = @iRecnoCVY
      
      If @iNroReg > 30000 begin
         commit transaction
         select @iNroReg = 0
      End
      SELECT @fim_CUR = 0
      Fetch CUR_CVY into @iRecnoCVY
   End
   close CUR_CVY
   deallocate CUR_CVY
   
   If @iNroReg > 0 begin
      commit transaction
      select @iTranCount = 0
   End
   /* ---------------------------------------------------------------------------------------------------
      Gerar os Saldos Mensais caso o periodo escolhido NÃO for mes cheio
      Ex: Periodo solicitado 15/01/15 a 20/04/15
      --------------------------------------------------------------------------------------------------- */
   Declare CUR_CVX190 insensitive cursor for
   Select CVX_FILIAL, CVX_CONFIG, CVX_MOEDA, CVX_TPSALD, Substring( CVX_DATA, 1, 6), CVX_NIV01, CVX_NIV02, CVX_NIV03, CVX_NIV04,
         ##FIELDP12( 'CT2.CT2_EC05DB' )
         CVX_NIV05,
         ##ENDFIELDP12
         ##FIELDP13( 'CT2.CT2_EC06DB' )
         CVX_NIV06,
         ##ENDFIELDP13
         ##FIELDP14( 'CT2.CT2_EC07DB' )
         CVX_NIV07,
         ##ENDFIELDP14
         ##FIELDP15( 'CT2.CT2_EC08DB' )
         CVX_NIV08,
         ##ENDFIELDP15
         ##FIELDP16( 'CT2.CT2_EC09DB' )
         CVX_NIV09,
         ##ENDFIELDP16
         IsNull(Sum(CVX_SLDCRD), 0), IsNull(Sum(CVX_SLDDEB), 0)
     From CVX###
    where CVX_FILIAL between @cFilial_CVX  and @IN_FILIALATE
      and CVX_DATA between @cDataI and @cDataF
      and (( CVX_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0')
      and CVX_TPSALD = @IN_TPSALDO
      and D_E_L_E_T_ = ' '
   Group by CVX_FILIAL, CVX_CONFIG, CVX_MOEDA, CVX_TPSALD, Substring( CVX_DATA, 1, 6), CVX_NIV01, CVX_NIV02, CVX_NIV03, CVX_NIV04
         ##FIELDP17( 'CT2.CT2_EC05DB' )
         , CVX_NIV05
         ##ENDFIELDP17
         ##FIELDP18( 'CT2.CT2_EC06DB' )
         , CVX_NIV06
         ##ENDFIELDP18
         ##FIELDP19( 'CT2.CT2_EC07DB' )
         , CVX_NIV07
         ##ENDFIELDP19
         ##FIELDP20( 'CT2.CT2_EC08DB' )
         , CVX_NIV08
         ##ENDFIELDP20
         ##FIELDP21( 'CT2.CT2_EC09DB' )
         , CVX_NIV09
         ##ENDFIELDP21
   for read only
   Open CUR_CVX190
   Fetch CUR_CVX190 into @cFil_CVX, @cConfig, @cMoeda, @cTpSaldo, @cData, @cNiv01, @cNiv02, @cNiv03, @cNiv04,
         ##FIELDP22( 'CT2.CT2_EC05DB' )
         @cNiv05,
         ##ENDFIELDP22
         ##FIELDP23( 'CT2.CT2_EC06DB' )
         @cNiv06,
         ##ENDFIELDP23
         ##FIELDP24( 'CT2.CT2_EC07DB' )
         @cNiv07,
         ##ENDFIELDP24
         ##FIELDP25( 'CT2.CT2_EC08DB' )
         @cNiv08,
         ##ENDFIELDP25
         ##FIELDP26( 'CT2.CT2_EC09DB' )
         @cNiv09,
         ##ENDFIELDP26
         @nCred, @nDeb
   While ( @@Fetch_Status = 0 ) begin
      Select @cAux = 'CT0'
      Exec XFILIAL_## @cAux, @cFil_CVX, @cFilial_CT0 OutPut
      
      select @cDataIn = @cData||'01'
      Exec LASTDAY_## @cDataIn, @cDataOut OutPut
      /* ---------------------------------------------------------------------------------------------------
         Gerar os Saldos Mensais CVY do periodo particionado
         --------------------------------------------------------------------------------------------------- */      
      Select @cCT0_CONTR = CT0_CONTR
        From CT0###
       Where CT0_FILIAL = @cFilial_CT0
         and CT0_ID     = @cConfig
         and D_E_L_E_T_ = ' '

      ##IF_002({|| cPaisLoc == "RUS" .And. SuperGetMV("MV_REDSTOR",.F.,.F.)})
	   If ( Round(@nDeb, 2 ) <> 0.00 or Round(@nCred, 2 ) <> 0.00 ) begin
         Select @cUPDATEVAL = '1'
      end else begin
         Select @cUPDATEVAL = '0'
      End
      ##ELSE_002
      If (Round(@nCred, 2 ) > 0.00 or Round(@nCred, 2 ) > 0.00) begin
         select @cUPDATEVAL = '1'
      End else begin
         select @cUPDATEVAL = '0'
      End
      ##ENDIF_002
      
      If ( @cCT0_CONTR = '1' and @cConfig = '01' ) begin
         If @cUPDATEVAL = '1' begin
            Exec CTB200_## @cAtu, @cConfig, @cFil_CVX, @cMoeda, @cTpSaldo, @cDataOut, @cNiv01, @nDeb, @nCred
         End
      End
      If @cCT0_CONTR = '1' and @cConfig = '02'  begin
         If @cUPDATEVAL = '1' begin
            Exec CTB201_## @cAtu, @cConfig, @cFil_CVX, @cMoeda, @cTpSaldo, @cDataOut, @cNiv01, @cNiv02, @nDeb, @nCred
         End
      End
      If @cCT0_CONTR = '1' and @cConfig = '03'  begin
         If @cUPDATEVAL = '1' begin
            Exec CTB202_## @cAtu, @cConfig, @cFil_CVX, @cMoeda, @cTpSaldo, @cDataOut, @cNiv01, @cNiv02, @cNiv03, @nDeb, @nCred
         End
      End
      If @cCT0_CONTR = '1' and @cConfig = '04'  begin
         If @cUPDATEVAL = '1' begin
            Exec CTB203_## @cAtu, @cConfig, @cFil_CVX, @cMoeda, @cTpSaldo, @cDataOut, @cNiv01, @cNiv02, @cNiv03, @cNiv04, @nDeb, @nCred
         End
      End
      ##FIELDP07( 'CT2.CT2_EC05DB' )
      If @cCT0_CONTR = '1' and @cConfig = '05'  begin
         If @cUPDATEVAL = '1' begin
            Exec CTB204_## @cAtu, @cConfig, @cFil_CVX, @cMoeda, @cTpSaldo, @cDataOut, @cNiv01, @cNiv02, @cNiv03, @cNiv04, @cNiv05, @nDeb, @nCred
         End
      End
      ##ENDFIELDP07
      ##FIELDP08( 'CT2.CT2_EC06DB' )
      If @cCT0_CONTR = '1' and @cConfig = '06' begin
         If @cUPDATEVAL = '1' begin
            Exec CTB205_## @cAtu, @cConfig, @cFil_CVX, @cMoeda, @cTpSaldo, @cDataOut, @cNiv01, @cNiv02, @cNiv03, @cNiv04, @cNiv05, @cNiv06, @nDeb, @nCred
         End
      End
      ##ENDFIELDP08
      ##FIELDP09( 'CT2.CT2_EC07DB' )
      If @cCT0_CONTR = '1' and @cConfig = '07' begin
         If @cUPDATEVAL = '1' begin
            Exec CTB206_## @cAtu, @cConfig, @cFil_CVX, @cMoeda, @cTpSaldo, @cDataOut, @cNiv01, @cNiv02, @cNiv03, @cNiv04, @cNiv05, @cNiv06, @cNiv07, @nDeb, @nCred
         End
      End
      ##ENDFIELDP09
      ##FIELDP10( 'CT2.CT2_EC08DB' )
      If @cCT0_CONTR = '1' and @cConfig = '08' begin
         If @cUPDATEVAL = '1' begin
            Exec CTB207_## @cAtu, @cConfig, @cFil_CVX, @cMoeda, @cTpSaldo, @cDataOut, @cNiv01, @cNiv02, @cNiv03, @cNiv04, @cNiv05, @cNiv06, @cNiv07, @cNiv08, @nDeb, @nCred
         End
      End
      ##ENDFIELDP10
      ##FIELDP11( 'CT2.CT2_EC09DB' )
      If @cCT0_CONTR = '1' and @cConfig = '09' begin
         If @cUPDATEVAL = '1' begin
            Exec CTB208_## @cAtu, @cConfig, @cFil_CVX, @cMoeda, @cTpSaldo, @cDataOut, @cNiv01, @cNiv02, @cNiv03, @cNiv04, @cNiv05, @cNiv06, @cNiv07, @cNiv08, @cNiv09, @nDeb, @nCred
         End
      End
      ##ENDFIELDP11
      
      SELECT @fim_CUR = 0
      Fetch CUR_CVX190 into @cFil_CVX, @cConfig, @cMoeda, @cTpSaldo, @cData, @cNiv01, @cNiv02, @cNiv03, @cNiv04,
            ##FIELDP32( 'CT2.CT2_EC05DB' )
            @cNiv05,
            ##ENDFIELDP32
            ##FIELDP33( 'CT2.CT2_EC06DB' )
            @cNiv06,
            ##ENDFIELDP33
            ##FIELDP34( 'CT2.CT2_EC07DB' )
            @cNiv07,
            ##ENDFIELDP34
            ##FIELDP35( 'CT2.CT2_EC08DB' )
            @cNiv08,
            ##ENDFIELDP35
            ##FIELDP36( 'CT2.CT2_EC09DB' )
            @cNiv09,
            ##ENDFIELDP36
            @nCred, @nDeb
   End
   Close CUR_CVX190
   Deallocate CUR_CVX190
End
##ENDFIELDP01
##ENDIF_001
