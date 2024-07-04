##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
##FIELDP01( 'CT0.CT0_ID' )
Create procedure CTB211_##
( 
   @IN_FILIAL       Char( 'CT2_FILIAL' ),
   @IN_FILIALATE    Char( 'CT2_FILIAL' ),
   @IN_DATADE       Char( 08 ),
   @IN_DATAATE      Char( 08 ),
   @IN_LMOEDAESP    Char( 01 ),
   @IN_MOEDA        Char( 'CT7_MOEDA' ),
   @IN_TPSALDO      Char( 'CT2_TPSALD' ),
   @OUT_RESULTADO   Char( 01 ) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Descricao       - <d>  Reprocessamento SigaCTB </d>
    Procedure       -      Atualizacao de slds Bases - CT3, CT4, CT7, CTI
    Funcao do Siga  -      Ct190SlBse()
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente
                           @IN_FILIALATE    - Filial final do processamento
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     03/11/2003
    Obs: a variável @iTranCount = 0 será trocada por 'commit tran' no CFGX051 pro SQLSERVER 
         e SYBASE
             +--> CTB211 - Chama Gravacao dos Cubos
                    +--> CTB200 - Atualizar Cubo01 - CONTA
                    +--> CTB201 - Atualizar Cubo02 - CCUSTO
                    +--> CTB202 - Atualizar Cubo03 - ITEM
                    +--> CTB203 - Atualizar Cubo04 - CLVL
                    +--> CTB204 - Atualizar Cubo05 - NIV05
                    +--> CTB205 - Atualizar Cubo06 - NIV06
                    +--> CTB206 - Atualizar Cubo07 - NIV07
                    +--> CTB207 - Atualizar Cubo08 - NIV08
                    +--> CTB208 - Atualizar Cubo09 - NIV09
   -------------------------------------------------------------------------------------- */
declare @cAtu        char( 01 )
declare @cAux        char( 03 )
declare @cFilial_CT2 char( 'CT2_FILIAL' )
declare @cFILCT2     char( 'CT2_FILIAL' )
declare @cFILCT2Ant  char( 'CT2_FILIAL' )
declare @cFilial_CT0 char( 'CT0_FILIAL' )
declare @cDATA       char( 08 )
declare @cDATAP      Char( 06 )
declare @cDATAPAnt   Char( 06 )
declare @cMOEDA      Char( 'CT7_MOEDA' )
declare @cMOEDAAnt   Char( 'CT7_MOEDA' )
declare @cCONTA      Char( 'CT7_CONTA' )
declare @cCONTAAnt   Char( 'CT7_CONTA' )
declare @cCUSTO      Char( 'CT3_CUSTO' )
declare @cCUSTOAnt   Char( 'CT3_CUSTO' )
declare @cITEM       Char( 'CT4_ITEM' )
declare @cITEMAnt    Char( 'CT4_ITEM' )
declare @cCLVL       Char( 'CTI_CLVL' )
declare @cCLVLAnt    Char( 'CTI_CLVL' )
##FIELDP02( 'CT2.CT2_EC05DB' )
declare @cEC05       Char( 'CT2_EC05DB' )
declare @cEC05Ant    Char( 'CT2_EC05DB' )
Declare @lCubo05     Char( 01 )
Declare @nTEC05DebM  Float
Declare @nTEC05CrdM  Float
##ENDFIELDP02
##FIELDP03( 'CT2.CT2_EC06DB' )
declare @cEC06       Char( 'CT2_EC06DB' )
declare @cEC06Ant    Char( 'CT2_EC06DB' )
Declare @lCubo06     Char( 01 )
Declare @nTEC06DebM  Float
Declare @nTEC06CrdM  Float
##ENDFIELDP03
##FIELDP04( 'CT2.CT2_EC07DB' )
declare @cEC07       Char( 'CT2_EC07DB' )
declare @cEC07Ant    Char( 'CT2_EC07DB' )
Declare @lCubo07     Char( 01 )
Declare @nTEC07DebM  Float
Declare @nTEC07CrdM  Float
##ENDFIELDP04
##FIELDP05( 'CT2.CT2_EC08DB' )
declare @cEC08       Char( 'CT2_EC08DB' )
declare @cEC08Ant    Char( 'CT2_EC08DB' )
Declare @lCubo08     Char( 01 )
Declare @nTEC08DebM  Float
Declare @nTEC08CrdM  Float
##ENDFIELDP05
##FIELDP06( 'CT2.CT2_EC09DB' )
declare @cEC09       Char( 'CT2_EC09DB' )
declare @cEC09Ant    Char( 'CT2_EC09DB' )
Declare @lCubo09     Char( 01 )
Declare @nTEC09DebM  Float
Declare @nTEC09CrdM  Float
##ENDFIELDP06
declare @cTIPO       Char( 01 )
declare @cTIPOAnt    Char( 01 )
declare @nVALOR      Float
Declare @nTContaDebM Float
Declare @nTContaCrdM Float
Declare @nTCustoDebM Float
Declare @nTCustoCrdM Float
Declare @nTItemDebM  Float
Declare @nTItemCrdM  Float
Declare @nTClvlDebM  Float
Declare @nTClvlCrdM  Float
Declare @lCubo01     Char( 01 )
Declare @lCubo02     Char( 01 )
Declare @lCubo03     Char( 01 )
Declare @lCubo04     Char( 01 )
Declare @cNivAux     Char( 01 )
Declare @cConfig     Char( 'CT0_ID' )
Declare @fim_CUR     integer
Declare @lPrim       char( 01 )

begin
   
   select @OUT_RESULTADO = '0'
   
   select @cAux    = 'CT2'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT2 OutPut
   
   Select @nTContaDebM = 0, @nTContaCrdM = 0, @nTCustoDebM = 0, @nTCustoCrdM = 0, @nTItemDebM = 0, @nTItemCrdM = 0, @nTClvlDebM = 0, @nTClvlCrdM = 0
   Select @cFILCT2Ant = ' ', @cDATA  = ' ', @cDATAPAnt = ' ', @cMOEDAAnt = ' ', @cCONTAAnt = ' ', @cCUSTOAnt = ' ', @cITEMAnt = ' ', @cCLVLAnt = ' ', @cTIPOAnt = ' '
   
   select @lCubo01 = '0', @lCubo02 = '0', @lCubo03 = '0', @lCubo04 = '0'
   ##FIELDP07( 'CT2.CT2_EC05DB' )
   Select @cEC05Ant = ' ', @lCubo05 = '0', @nTEC05DebM = 0, @nTEC05CrdM = 0
   ##ENDFIELDP07
   ##FIELDP08( 'CT2.CT2_EC06DB' )
   Select @cEC06Ant = ' ', @lCubo06 = '0', @nTEC06DebM = 0, @nTEC06CrdM = 0
   ##ENDFIELDP08
   ##FIELDP09( 'CT2.CT2_EC07DB' )
   Select @cEC07Ant = ' ', @lCubo07 = '0', @nTEC07DebM = 0, @nTEC07CrdM = 0
   ##ENDFIELDP09
   ##FIELDP10( 'CT2.CT2_EC08DB' )
   Select @cEC08Ant = ' ', @lCubo08 = '0', @nTEC08DebM = 0, @nTEC08CrdM = 0
   ##ENDFIELDP10
   ##FIELDP11( 'CT2.CT2_EC09DB' )
   Select @cEC09Ant = ' ', @lCubo09 = '0', @nTEC09DebM = 0, @nTEC09CrdM = 0
   ##ENDFIELDP11
   /*---------------------------------------------------------------
     Gerar Saldos MENSAIS, CVY, a partir do CT2
      --------------------------------------------------------------- */
   select @cNivAux = ' '
   select @lPrim = '1' 
   select @cAtu = '2'
   Declare CUR_CUBO190B insensitive cursor for
    Select CT2_FILIAL, Substring( CT2_DATA, 1, 6 ), CT2_MOEDLC, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_CLVLDB,
           ##FIELDP12( 'CT2.CT2_EC05DB' )
            CT2_EC05DB,
           ##ENDFIELDP12
           ##FIELDP13( 'CT2.CT2_EC06DB' )
            CT2_EC06DB,
           ##ENDFIELDP13
           ##FIELDP14( 'CT2.CT2_EC07DB' )
            CT2_EC07DB,
           ##ENDFIELDP14
           ##FIELDP15( 'CT2.CT2_EC08DB' )
            CT2_EC08DB,
           ##ENDFIELDP15
           ##FIELDP16( 'CT2.CT2_EC09DB' )
            CT2_EC09DB,
           ##ENDFIELDP16
           SUM(CT2_VALOR), 'D'
        From CT2###
       Where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE
         and (CT2_DC = '1' or CT2_DC = '3')
         and CT2_TPSALD = @IN_TPSALDO
         and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP != '1' )
         and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
         and CT2_DEBITO != ' '
         and D_E_L_E_T_= ' '
       Group By CT2_FILIAL, Substring( CT2_DATA, 1, 6 ), CT2_MOEDLC, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_CLVLDB
           ##FIELDP17( 'CT2.CT2_EC05DB' )
            ,CT2_EC05DB
           ##ENDFIELDP17
           ##FIELDP18( 'CT2.CT2_EC06DB' )
            ,CT2_EC06DB
           ##ENDFIELDP18
           ##FIELDP19( 'CT2.CT2_EC07DB' )
            ,CT2_EC07DB
           ##ENDFIELDP19
           ##FIELDP20( 'CT2.CT2_EC08DB' )
            ,CT2_EC08DB
           ##ENDFIELDP20
           ##FIELDP21( 'CT2.CT2_EC09DB' )
            ,CT2_EC09DB
           ##ENDFIELDP21
       Union
      Select CT2_FILIAL, Substring( CT2_DATA, 1, 6 ), CT2_MOEDLC, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_CLVLCR,
           ##FIELDP22( 'CT2.CT2_EC05CR' )
            CT2_EC05CR,
           ##ENDFIELDP22
           ##FIELDP23( 'CT2.CT2_EC06CR' )
            CT2_EC06CR,
           ##ENDFIELDP23
           ##FIELDP24( 'CT2.CT2_EC07CR' )
            CT2_EC07CR,
           ##ENDFIELDP24
           ##FIELDP25( 'CT2.CT2_EC08CR' )
            CT2_EC08CR,
           ##ENDFIELDP25
           ##FIELDP26( 'CT2.CT2_EC09CR' )
            CT2_EC09CR,
           ##ENDFIELDP26
           SUM(CT2_VALOR), 'C'
        From CT2###
       Where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE 
         and (CT2_DC = '2' or CT2_DC = '3')
         and CT2_TPSALD = @IN_TPSALDO
         and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP != '1' )
         and (CT2_DATA between @IN_DATADE and @IN_DATAATE)
         and CT2_CREDIT != ' '
         and D_E_L_E_T_ = ' '
      Group By CT2_FILIAL, Substring( CT2_DATA, 1, 6 ), CT2_MOEDLC, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_CLVLCR
           ##FIELDP27( 'CT2.CT2_EC05CR' )
            ,CT2_EC05CR
           ##ENDFIELDP27
           ##FIELDP28( 'CT2.CT2_EC06CR' )
            ,CT2_EC06CR
           ##ENDFIELDP28
           ##FIELDP29( 'CT2.CT2_EC07CR' )
            ,CT2_EC07CR
           ##ENDFIELDP29
           ##FIELDP30( 'CT2.CT2_EC08CR' )
            ,CT2_EC08CR
           ##ENDFIELDP30
           ##FIELDP31( 'CT2.CT2_EC09CR' )
            ,CT2_EC09CR
           ##ENDFIELDP31
      order by 1, 2, 3, 4, 5, 6, 7
              ##FIELDP32( 'CT2.CT2_EC05DB' )
               , 8
              ##ENDFIELDP32
              ##FIELDP33( 'CT2.CT2_EC06DB' )
               , 9
              ##ENDFIELDP33
              ##FIELDP34( 'CT2.CT2_EC07DB' )
               , 10
              ##ENDFIELDP34
              ##FIELDP35( 'CT2.CT2_EC08DB' )
               , 11
              ##ENDFIELDP35
              ##FIELDP36( 'CT2.CT2_EC09DB' )
               , 12
              ##ENDFIELDP36
              
   for read only
   Open CUR_CUBO190B
   Fetch CUR_CUBO190B into  @cFILCT2, @cDATAP, @cMOEDA, @cCONTA, @cCUSTO, @cITEM, @cCLVL,
                           ##FIELDP37( 'CT2.CT2_EC05DB' )
                           @cEC05,
                           ##ENDFIELDP37
                           ##FIELDP38( 'CT2.CT2_EC06DB' )
                           @cEC06,
                           ##ENDFIELDP38
                           ##FIELDP39( 'CT2.CT2_EC07DB' )
                           @cEC07,
                           ##ENDFIELDP39
                           ##FIELDP40( 'CT2.CT2_EC08DB' )
                           @cEC08,
                           ##ENDFIELDP40
                           ##FIELDP41( 'CT2.CT2_EC09DB' )
                           @cEC09,
                           ##ENDFIELDP41
                           @nVALOR, @cTIPO
   
   While (@@Fetch_status = 0 ) begin
      
      If @lPrim = '1' begin
         Select @cFILCT2Ant = @cFILCT2, @cDATAPAnt = @cDATAP, @cMOEDAAnt = @cMOEDA, @cCONTAAnt = @cCONTA
         Select @cCUSTOAnt  = @cCUSTO,  @cITEMAnt = @cITEM,  @cCLVLAnt  = @cCLVL,  @cTIPOAnt  = @cTIPO
         ##FIELDP42( 'CT2.CT2_EC05DB' )
         Select @cEC05Ant = @cEC05
         ##ENDFIELDP42
         ##FIELDP43( 'CT2.CT2_EC06DB' )
         Select @cEC06Ant = @cEC06
         ##ENDFIELDP43
         ##FIELDP44( 'CT2.CT2_EC07DB' )
         Select @cEC07Ant = @cEC07
         ##ENDFIELDP44
         ##FIELDP45( 'CT2.CT2_EC08DB' )
         Select @cEC08Ant = @cEC08
         ##ENDFIELDP45
         ##FIELDP46( 'CT2.CT2_EC09DB' )
         Select @cEC09Ant = @cEC09
         ##ENDFIELDP46
         select @lPrim = '0'
      End
      
      select @cAux    = 'CT0'
      exec XFILIAL_## @cAux, @cFILCT2Ant, @cFilial_CT0 OutPut
      /* ---------------------------------------------------------------
         Atualiza Cubo 1 - CONTA - CVY - Mensal
         select @cAtu = '2' - Atualiza saldos mensais
         --------------------------------------------------------------- */
      If ((@cFILCT2||@cMOEDA||@cCONTA||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cDATAPAnt)) begin
         select @cConfig = '01'
         select @lCubo01 = CT0_CONTR
           From CT0###
          where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo01 = '1' begin
            If @cCONTAAnt != ' ' begin
               Select @cDATA = @cDATAPAnt||'01'
               Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cNivAux, @cNivAux, @cNivAux,
                        ##FIELDP47( 'CT2.CT2_EC05DB' )
                         @cNivAux,
                        ##ENDFIELDP47
                        ##FIELDP48( 'CT2.CT2_EC06DB' )
                         @cNivAux,
                        ##ENDFIELDP48
                        ##FIELDP49( 'CT2.CT2_EC07DB' )
                         @cNivAux,
                        ##ENDFIELDP49
                        ##FIELDP50( 'CT2.CT2_EC08DB' )
                         @cNivAux,
                        ##ENDFIELDP50
                        ##FIELDP51( 'CT2.CT2_EC09DB' )
                         @cNivAux,
                        ##ENDFIELDP51
                        @cConfig, @cAtu, @nTContaDebM, @nTContaCrdM
               select @nTContaDebM = 0
               select @nTContaCrdM = 0
            End
         End
      End
      /* ---------------------------------------------------------------
         Atualiza Cubo 2 - ccusto
         --------------------------------------------------------------- */
      If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cDATAPAnt)) begin
         select @cConfig = '02'
         select @lCubo02 = CT0_CONTR
           From CT0###
          where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo02 = '1' begin
            If @cCONTAAnt != ' ' begin
               Select @cDATA = @cDATAPAnt||'01'
               Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cNivAux, @cNivAux,
                        ##FIELDP52( 'CT2.CT2_EC05DB' )
                         @cNivAux,
                        ##ENDFIELDP52
                        ##FIELDP53( 'CT2.CT2_EC06DB' )
                         @cNivAux,
                        ##ENDFIELDP53
                        ##FIELDP54( 'CT2.CT2_EC07DB' )
                         @cNivAux,
                        ##ENDFIELDP54
                        ##FIELDP55( 'CT2.CT2_EC08DB' )
                         @cNivAux,
                        ##ENDFIELDP55
                        ##FIELDP56( 'CT2.CT2_EC09DB' )
                         @cNivAux,
                        ##ENDFIELDP56
                        @cConfig, @cAtu, @nTCustoDebM, @nTCustoCrdM
               select @nTCustoDebM = 0
               select @nTCustoCrdM = 0
            End
         End
      End
      /* ---------------------------------------------------------------
         Atualiza Cubo 3 - ITEM CONTABIL
         --------------------------------------------------------------- */
      If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cITEM||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cITEMAnt||@cDATAPAnt)) begin
         select @cConfig = '03'
         select @lCubo03 = CT0_CONTR
           From CT0###
          where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo03 = '1' begin
            If @cCONTAAnt != ' ' begin
               Select @cDATA = @cDATAPAnt||'01'
               Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cITEMAnt, @cNivAux,
                        ##FIELDP57( 'CT2.CT2_EC05DB' )
                         @cNivAux,
                        ##ENDFIELDP57
                        ##FIELDP58( 'CT2.CT2_EC06DB' )
                         @cNivAux,
                        ##ENDFIELDP58
                        ##FIELDP59( 'CT2.CT2_EC07DB' )
                         @cNivAux,
                        ##ENDFIELDP59
                        ##FIELDP60( 'CT2.CT2_EC08DB' )
                         @cNivAux,
                        ##ENDFIELDP60
                        ##FIELDP61( 'CT2.CT2_EC09DB' )
                         @cNivAux,
                        ##ENDFIELDP61
                        @cConfig, @cAtu, @nTItemDebM, @nTItemCrdM
               select @nTItemDebM = 0
               select @nTItemCrdM = 0
            End
         End
      End
      /* ---------------------------------------------------------------
         Atualiza Cubo 4 - CLASSE DE VALOR
         --------------------------------------------------------------- */
      If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cITEM||@cCLVL||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cITEMAnt||@cCLVLAnt||@cDATAPAnt)) begin
         select @cConfig = '04'
         select @lCubo04 = CT0_CONTR
           From CT0###
          where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo04 = '1' begin
            If @cCONTAAnt != ' ' begin
               Select @cDATA = @cDATAPAnt||'01'
               Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cITEMAnt, @cCLVLAnt,
                        ##FIELDP62( 'CT2.CT2_EC05DB' )
                         @cNivAux,
                        ##ENDFIELDP62
                        ##FIELDP63( 'CT2.CT2_EC06DB' )
                         @cNivAux,
                        ##ENDFIELDP63
                        ##FIELDP64( 'CT2.CT2_EC07DB' )
                         @cNivAux,
                        ##ENDFIELDP64
                        ##FIELDP65( 'CT2.CT2_EC08DB' )
                         @cNivAux,
                        ##ENDFIELDP65
                        ##FIELDP66( 'CT2.CT2_EC09DB' )
                         @cNivAux,
                        ##ENDFIELDP66
                         @cConfig, @cAtu, @nTClvlDebM, @nTClvlCrdM
               select @nTClvlDebM = 0
               select @nTClvlCrdM = 0
            End
         End
      End
      /* ---------------------------------------------------------------
         Atualiza Cubo 5 - ENTIDADE NIVEL 05
         --------------------------------------------------------------- */
      ##FIELDP67( 'CT2.CT2_EC05DB' )
      If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cITEM||@cCLVL||@cEC05||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cITEMAnt||@cCLVLAnt||@cEC05Ant||@cDATAPAnt)) begin
         select @cConfig = '05'
         select @lCubo05 = CT0_CONTR
           From CT0###
          where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo05 = '1' begin
            If @cCONTAAnt != ' ' begin
               Select @cDATA = @cDATAPAnt||'01'
               Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cITEMAnt, @cCLVLAnt,
                        ##FIELDP68( 'CT2.CT2_EC05DB' )
                         @cEC05Ant,
                        ##ENDFIELDP68
                        ##FIELDP69( 'CT2.CT2_EC06DB' )
                         @cNivAux,
                        ##ENDFIELDP69
                        ##FIELDP70( 'CT2.CT2_EC07DB' )
                         @cNivAux,
                        ##ENDFIELDP70
                        ##FIELDP71( 'CT2.CT2_EC08DB' )
                         @cNivAux,
                        ##ENDFIELDP71
                        ##FIELDP72( 'CT2.CT2_EC09DB' )
                         @cNivAux,
                        ##ENDFIELDP72
                        @cConfig, @cAtu, @nTEC05DebM, @nTEC05CrdM
               select @nTEC05DebM = 0
               select @nTEC05CrdM = 0
            End
         End
      End
      ##ENDFIELDP67
      /* ---------------------------------------------------------------
         Atualiza Cubo 6 - ENTIDADE NIVEL 06
         --------------------------------------------------------------- */
      ##FIELDP73( 'CT2.CT2_EC06DB' )
      If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cITEM||@cCLVL||@cEC05||@cEC06||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cITEMAnt||@cCLVLAnt||@cEC05Ant||@cEC06Ant||@cDATAPAnt)) begin
         select @cConfig = '06'
         select @lCubo06 = CT0_CONTR
           From CT0###
          where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo06 = '1' begin
            If @cCONTAAnt != ' ' begin
               Select @cDATA = @cDATAPAnt||'01'
               Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cITEMAnt, @cCLVLAnt,
                        ##FIELDP74( 'CT2.CT2_EC05DB' )
                         @cEC05Ant,
                        ##ENDFIELDP74
                        ##FIELDP75( 'CT2.CT2_EC06DB' )
                         @cEC06Ant,
                        ##ENDFIELDP75
                        ##FIELDP76( 'CT2.CT2_EC07DB' )
                         @cNivAux,
                        ##ENDFIELDP76
                        ##FIELDP77( 'CT2.CT2_EC08DB' )
                         @cNivAux,
                        ##ENDFIELDP77
                        ##FIELDP78( 'CT2.CT2_EC09DB' )
                         @cNivAux,
                        ##ENDFIELDP78
                        @cConfig, @cAtu, @nTEC06DebM, @nTEC06CrdM
               select @nTEC06DebM = 0
               select @nTEC06CrdM = 0
            End
         End
      End
      ##ENDFIELDP73
      /* ---------------------------------------------------------------
         Atualiza Cubo 7 - ENTIDADE NIVEL 07
         --------------------------------------------------------------- */
      ##FIELDP79( 'CT2.CT2_EC07DB' )
      If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cITEM||@cCLVL||@cEC05||@cEC06||@cEC07||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cITEMAnt||@cCLVLAnt||@cEC05Ant||@cEC06Ant||@cEC07Ant||@cDATAPAnt)) begin
         select @cConfig = '07'
         select @lCubo07 = CT0_CONTR
           From CT0###
          where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo07 = '1' begin
            If @cCONTAAnt != ' ' begin
               Select @cDATA = @cDATAPAnt||'01'
               Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cITEMAnt, @cCLVLAnt,
                        ##FIELDP80( 'CT2.CT2_EC05DB' )
                         @cEC05Ant,
                        ##ENDFIELDP80
                        ##FIELDP81( 'CT2.CT2_EC06DB' )
                         @cEC06Ant,
                        ##ENDFIELDP81
                        ##FIELDP82( 'CT2.CT2_EC07DB' )
                         @cEC07Ant,
                        ##ENDFIELDP82
                        ##FIELDP83( 'CT2.CT2_EC08DB' )
                         @cNivAux,
                        ##ENDFIELDP83
                        ##FIELDP84( 'CT2.CT2_EC09DB' )
                         @cNivAux,
                        ##ENDFIELDP84
                        @cConfig, @cAtu, @nTEC07DebM, @nTEC07CrdM
               select @nTEC07DebM = 0
               select @nTEC07CrdM = 0
            End
         End
      End
      ##ENDFIELDP79
      /* ---------------------------------------------------------------
         Atualiza Cubo 8 - ENTIDADE NIVEL 08
         --------------------------------------------------------------- */
      ##FIELDP85( 'CT2.CT2_EC08DB' )
      If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cITEM||@cCLVL||@cEC05||@cEC06||@cEC07||@cEC08||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cITEMAnt||@cCLVLAnt||@cEC05Ant||@cEC06Ant||@cEC07Ant||@cEC08Ant||@cDATAPAnt)) begin
         select @cConfig = '08'
         select @lCubo08 = CT0_CONTR
           From CT0###
          where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo08 = '1' begin
            If @cCONTAAnt != ' ' begin
               Select @cDATA = @cDATAPAnt||'01'
               Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cITEMAnt, @cCLVLAnt,
                        ##FIELDP86( 'CT2.CT2_EC05DB' )
                         @cEC05Ant,
                        ##ENDFIELDP86
                        ##FIELDP87( 'CT2.CT2_EC06DB' )
                         @cEC06Ant,
                        ##ENDFIELDP87
                        ##FIELDP88( 'CT2.CT2_EC07DB' )
                         @cEC07Ant,
                        ##ENDFIELDP88
                        ##FIELDP89( 'CT2.CT2_EC08DB' )
                         @cEC08Ant,
                        ##ENDFIELDP89
                        ##FIELDP90( 'CT2.CT2_EC09DB' )
                         @cNivAux,
                        ##ENDFIELDP90
                        @cConfig, @cAtu, @nTEC08DebM, @nTEC08CrdM
               select @nTEC08DebM = 0
               select @nTEC08CrdM = 0
            End
         End
      End
      ##ENDFIELDP85
      /* ---------------------------------------------------------------
         Atualiza Cubo 9 - ENTIDADE NIVEL 09
         --------------------------------------------------------------- */
      ##FIELDP91( 'CT2.CT2_EC09DB' )
      If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cITEM||@cCLVL||@cEC05||@cEC06||@cEC07||@cEC08||@cEC09||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cITEMAnt||@cCLVLAnt||@cEC05Ant||@cEC06Ant||@cEC07Ant||@cEC08Ant||@cEC09Ant||@cDATAPAnt)) begin
         select @cConfig = '09'
         select @lCubo09 = CT0_CONTR
           From CT0###
          where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo09 = '1' begin
            If @cCONTAAnt != ' ' begin
               Select @cDATA = @cDATAPAnt||'01'
               Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cITEMAnt, @cCLVLAnt,
                        ##FIELDP92( 'CT2.CT2_EC05DB' )
                         @cEC05Ant,
                        ##ENDFIELDP92
                        ##FIELDP93( 'CT2.CT2_EC06DB' )
                         @cEC06Ant,
                        ##ENDFIELDP93
                        ##FIELDP94( 'CT2.CT2_EC07DB' )
                         @cEC07Ant,
                        ##ENDFIELDP94
                        ##FIELDP95( 'CT2.CT2_EC08DB' )
                         @cEC08Ant,
                        ##ENDFIELDP95
                        ##FIELDP96( 'CT2.CT2_EC09DB' )
                         @cEC09Ant,
                        ##ENDFIELDP96
                        @cConfig, @cAtu, @nTEC09DebM, @nTEC09CrdM
               select @nTEC09DebM = 0
               select @nTEC09CrdM = 0
            End
         End
      End
      ##ENDFIELDP91
      
      If @cTIPO = 'D' begin
         Select @nTContaDebM = @nTContaDebM + @nVALOR, @nTCustoDebM = @nTCustoDebM + @nVALOR, @nTItemDebM = @nTItemDebM + @nVALOR, @nTClvlDebM = @nTClvlDebM + @nVALOR
      End
      If @cTIPO = 'C' begin
         Select @nTContaCrdM = @nTContaCrdM + @nVALOR, @nTCustoCrdM = @nTCustoCrdM + @nVALOR, @nTItemCrdM = @nTItemCrdM + @nVALOR, @nTClvlCrdM = @nTClvlCrdM + @nVALOR
      End
      ##FIELDP92( 'CT2.CT2_EC05DB' )
      If @cTIPO = 'D' begin
         Select @nTEC05DebM = @nTEC05DebM + @nVALOR
      End
      If @cTIPO = 'C' begin   
         Select @nTEC05CrdM = @nTEC05CrdM + @nVALOR
      End
      ##ENDFIELDP92
      ##FIELDP93( 'CT2.CT2_EC06DB' )
      If @cTIPO = 'D' begin
         Select @nTEC06DebM = @nTEC06DebM + @nVALOR
      End
      If @cTIPO = 'C' begin
         Select @nTEC06CrdM = @nTEC06CrdM + @nVALOR
      End
      ##ENDFIELDP93
      ##FIELDP94( 'CT2.CT2_EC07DB' )
      If @cTIPO = 'D' begin
         Select @nTEC07DebM = @nTEC07DebM + @nVALOR
      End
      If @cTIPO = 'C' begin
         Select @nTEC07CrdM = @nTEC07CrdM + @nVALOR
      End
      ##ENDFIELDP94
      ##FIELDP95( 'CT2.CT2_EC08DB' )
      If @cTIPO = 'D' begin
         Select @nTEC08DebM = @nTEC08DebM + @nVALOR
      End
      If @cTIPO = 'C' begin
         Select @nTEC08CrdM = @nTEC08CrdM + @nVALOR
      End
      ##ENDFIELDP95
      ##FIELDP96( 'CT2.CT2_EC09DB' )
      If @cTIPO = 'D' begin
         Select @nTEC09DebM = @nTEC09DebM + @nVALOR
      End
      If @cTIPO = 'C' begin
         Select @nTEC09CrdM = @nTEC09CrdM + @nVALOR
      End
      ##ENDFIELDP96
      
      Select @cFILCT2Ant = @cFILCT2, @cDATAPAnt = @cDATAP, @cMOEDAAnt = @cMOEDA, @cCONTAAnt = @cCONTA
      Select @cCUSTOAnt  = @cCUSTO,  @cITEMAnt = @cITEM,  @cCLVLAnt  = @cCLVL,  @cTIPOAnt  = @cTIPO
      ##FIELDP97( 'CT2.CT2_EC05DB' )
      Select @cEC05Ant = @cEC05
      ##ENDFIELDP97
      ##FIELDP98( 'CT2.CT2_EC06DB' )
      Select @cEC06Ant = @cEC06
      ##ENDFIELDP98
      ##FIELDP99( 'CT2.CT2_EC07DB' )
      Select @cEC07Ant = @cEC07
      ##ENDFIELDP99
      ##FIELDP0A( 'CT2.CT2_EC08DB' )
      Select @cEC08Ant = @cEC08
      ##ENDFIELDP0A
      ##FIELDP0B( 'CT2.CT2_EC09DB' )
      Select @cEC09Ant = @cEC09
      ##ENDFIELDP0B

      SELECT @fim_CUR = 0
      Fetch CUR_CUBO190B into @cFILCT2, @cDATAP, @cMOEDA, @cCONTA, @cCUSTO, @cITEM, @cCLVL,
                           ##FIELDP0C( 'CT2.CT2_EC05DB' )
                           @cEC05,
                           ##ENDFIELDP0C
                           ##FIELDP0D( 'CT2.CT2_EC06DB' )
                           @cEC06,
                           ##ENDFIELDP0D
                           ##FIELDP0E( 'CT2.CT2_EC07DB' )
                           @cEC07,
                           ##ENDFIELDP0E
                           ##FIELDP0F( 'CT2.CT2_EC08DB' )
                           @cEC08,
                           ##ENDFIELDP0F
                           ##FIELDP0G( 'CT2.CT2_EC09DB' )
                           @cEC09,
                           ##ENDFIELDP0G
                           @nVALOR, @cTIPO
      
      If @@Fetch_status = -1 select @cDATAP = ' '
      /* ---------------------------------------------------------------
         Após passar pelo último do fetch - atualizo a ultima linha
         --------------------------------------------------------------- */
      If @cDATAP = ' ' begin
         If ((@cFILCT2||@cMOEDA||@cCONTA||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cDATAPAnt)) begin
            select @cConfig = '01'
            select @lCubo01 = CT0_CONTR
              From CT0###
             where CT0_FILIAL = @cFilial_CT0
               and CT0_ID     = @cConfig
               and D_E_L_E_T_ = ' '
            
            If @lCubo01 = '1' begin
               If @cCONTAAnt != ' ' begin
                  Select @cDATA = @cDATAPAnt||'01'
                  Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cNivAux, @cNivAux, @cNivAux,
                           ##FIELDP0H( 'CT2.CT2_EC05DB' )
                            @cNivAux,
                           ##ENDFIELDP0H
                           ##FIELDP0I( 'CT2.CT2_EC06DB' )
                            @cNivAux,
                           ##ENDFIELDP0I
                           ##FIELDP0J( 'CT2.CT2_EC07DB' )
                            @cNivAux,
                           ##ENDFIELDP0J
                           ##FIELDP0K( 'CT2.CT2_EC08DB' )
                            @cNivAux,
                           ##ENDFIELDP0K
                           ##FIELDP0L( 'CT2.CT2_EC09DB' )
                            @cNivAux,
                           ##ENDFIELDP0L
                           @cConfig, @cAtu, @nTContaDebM, @nTContaCrdM
                  select @nTContaDebM = 0
                  select @nTContaCrdM = 0
               End
            End
         End
         /* ---------------------------------------------------------------
            Atualiza Cubo 2 - ccusto
            --------------------------------------------------------------- */
         If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cDATAPAnt)) begin
            select @cConfig = '02'
            select @lCubo02 = CT0_CONTR
              From CT0###
             where CT0_FILIAL = @cFilial_CT0
               and CT0_ID     = @cConfig
               and D_E_L_E_T_ = ' '
            
            If @lCubo02 = '1' begin
               If @cCONTAAnt != ' ' begin
                  Select @cDATA = @cDATAPAnt||'01'
                  Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cNivAux, @cNivAux,
                           ##FIELDP0M( 'CT2.CT2_EC05DB' )
                            @cNivAux,
                           ##ENDFIELDP0M
                           ##FIELDP0N( 'CT2.CT2_EC06DB' )
                            @cNivAux,
                           ##ENDFIELDP0N
                           ##FIELDP0O( 'CT2.CT2_EC07DB' )
                            @cNivAux,
                           ##ENDFIELDP0O
                           ##FIELDP0P( 'CT2.CT2_EC08DB' )
                            @cNivAux,
                           ##ENDFIELDP0P
                           ##FIELDP0Q( 'CT2.CT2_EC09DB' )
                            @cNivAux,
                           ##ENDFIELDP0Q
                           @cConfig, @cAtu, @nTCustoDebM, @nTCustoCrdM
                  select @nTCustoDebM = 0
                  select @nTCustoCrdM = 0
               End
            End
         End
         /* ---------------------------------------------------------------
            Atualiza Cubo 3 - ITEM CONTABIL
            --------------------------------------------------------------- */
         If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cITEM||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cITEMAnt||@cDATAPAnt)) begin
            select @cConfig = '03'
            select @lCubo03 = CT0_CONTR
              From CT0###
             where CT0_FILIAL = @cFilial_CT0
               and CT0_ID     = @cConfig
               and D_E_L_E_T_ = ' '
            
            If @lCubo03 = '1' begin
               If @cCONTAAnt != ' ' begin
                  Select @cDATA = @cDATAPAnt||'01'
                  Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cITEMAnt, @cNivAux,
                           ##FIELDP0R( 'CT2.CT2_EC05DB' )
                            @cNivAux,
                           ##ENDFIELDP0R
                           ##FIELDP0S( 'CT2.CT2_EC06DB' )
                            @cNivAux,
                           ##ENDFIELDP0S
                           ##FIELDP0T( 'CT2.CT2_EC07DB' )
                            @cNivAux,
                           ##ENDFIELDP0T
                           ##FIELDP0U( 'CT2.CT2_EC08DB' )
                            @cNivAux,
                           ##ENDFIELDP0U
                           ##FIELDP0V( 'CT2.CT2_EC09DB' )
                            @cNivAux,
                           ##ENDFIELDP0V
                           @cConfig, @cAtu, @nTItemDebM, @nTItemCrdM
                  select @nTItemDebM = 0
                  select @nTItemCrdM = 0
               End
            End
         End
         /* ---------------------------------------------------------------
            Atualiza Cubo 4 - CLASSE DE VALOR
            --------------------------------------------------------------- */
         If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cITEM||@cCLVL||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cITEMAnt||@cCLVLAnt||@cDATAPAnt)) begin
            select @cConfig = '04'
            select @lCubo04 = CT0_CONTR
              From CT0###
             where CT0_FILIAL = @cFilial_CT0
               and CT0_ID     = @cConfig
               and D_E_L_E_T_ = ' '
            
            If @lCubo04 = '1' begin
               If @cCONTAAnt != ' ' begin
                  Select @cDATA = @cDATAPAnt||'01'
                  Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cITEMAnt, @cCLVLAnt,
                           ##FIELDP0X( 'CT2.CT2_EC05DB' )
                            @cNivAux,
                           ##ENDFIELDP0X
                           ##FIELDP0Y( 'CT2.CT2_EC06DB' )
                            @cNivAux,
                           ##ENDFIELDP0Y
                           ##FIELDP0W( 'CT2.CT2_EC07DB' )
                            @cNivAux,
                           ##ENDFIELDP0W
                           ##FIELDP0Z( 'CT2.CT2_EC08DB' )
                            @cNivAux,
                           ##ENDFIELDP0Z
                           ##FIELDP1A( 'CT2.CT2_EC09DB' )
                            @cNivAux,
                           ##ENDFIELDP1A
                            @cConfig, @cAtu, @nTClvlDebM, @nTClvlCrdM
                  select @nTClvlDebM = 0
                  select @nTClvlCrdM = 0
               End
            End
         End
         /* ---------------------------------------------------------------
            Atualiza Cubo 5 - ENTIDADE NIVEL 05
            --------------------------------------------------------------- */
         ##FIELDP1B( 'CT2.CT2_EC05DB' )
         If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cITEM||@cCLVL||@cEC05||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cITEMAnt||@cCLVLAnt||@cEC05Ant||@cDATAPAnt)) begin
            select @cConfig = '05'
            select @lCubo05 = CT0_CONTR
              From CT0###
             where CT0_FILIAL = @cFilial_CT0
               and CT0_ID     = @cConfig
               and D_E_L_E_T_ = ' '
            
            If @lCubo05 = '1' begin
               If @cCONTAAnt != ' ' begin
                  Select @cDATA = @cDATAPAnt||'01'
                  Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cITEMAnt, @cCLVLAnt,
                           ##FIELDP1C( 'CT2.CT2_EC05DB' )
                            @cEC05Ant,
                           ##ENDFIELDP1C
                           ##FIELDP1D( 'CT2.CT2_EC06DB' )
                            @cNivAux,
                           ##ENDFIELDP1D
                           ##FIELDP1E( 'CT2.CT2_EC07DB' )
                            @cNivAux,
                           ##ENDFIELDP1E
                           ##FIELDP1F( 'CT2.CT2_EC08DB' )
                            @cNivAux,
                           ##ENDFIELDP1F
                           ##FIELDP1G( 'CT2.CT2_EC09DB' )
                            @cNivAux,
                           ##ENDFIELDP1G
                           @cConfig, @cAtu, @nTEC05DebM, @nTEC05CrdM
                  select @nTEC05DebM = 0
                  select @nTEC05CrdM = 0
               End
            End
         End
         ##ENDFIELDP1B
         /* ---------------------------------------------------------------
            Atualiza Cubo 6 - ENTIDADE NIVEL 06
            --------------------------------------------------------------- */
         ##FIELDP1C( 'CT2.CT2_EC06DB' )
         If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cITEM||@cCLVL||@cEC05||@cEC06||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cITEMAnt||@cCLVLAnt||@cEC05Ant||@cEC06Ant||@cDATAPAnt)) begin
            select @cConfig = '06'
            select @lCubo06 = CT0_CONTR
              From CT0###
             where CT0_FILIAL = @cFilial_CT0
               and CT0_ID     = @cConfig
               and D_E_L_E_T_ = ' '
            
            If @lCubo06 = '1' begin
               If @cCONTAAnt != ' ' begin
                  Select @cDATA = @cDATAPAnt||'01'
                  Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cITEMAnt, @cCLVLAnt,
                           ##FIELDP1D( 'CT2.CT2_EC05DB' )
                            @cEC05Ant,
                           ##ENDFIELDP1D
                           ##FIELDP1E( 'CT2.CT2_EC06DB' )
                            @cEC06Ant,
                           ##ENDFIELDP1E
                           ##FIELDP1F( 'CT2.CT2_EC07DB' )
                            @cNivAux,
                           ##ENDFIELDP1F
                           ##FIELDP1G( 'CT2.CT2_EC08DB' )
                            @cNivAux,
                           ##ENDFIELDP1G
                           ##FIELDP1H( 'CT2.CT2_EC09DB' )
                            @cNivAux,
                           ##ENDFIELDP1H
                           @cConfig, @cAtu, @nTEC06DebM, @nTEC06CrdM
                  select @nTEC06DebM = 0
                  select @nTEC06CrdM = 0
               End
            End
         End
         ##ENDFIELDP1C
         /* ---------------------------------------------------------------
            Atualiza Cubo 7 - ENTIDADE NIVEL 07
            --------------------------------------------------------------- */
         ##FIELDP1I( 'CT2.CT2_EC07DB' )
         If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cITEM||@cCLVL||@cEC05||@cEC06||@cEC07||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cITEMAnt||@cCLVLAnt||@cEC05Ant||@cEC06Ant||@cEC07Ant||@cDATAPAnt)) begin
            select @cConfig = '07'
            select @lCubo07 = CT0_CONTR
              From CT0###
             where CT0_FILIAL = @cFilial_CT0
               and CT0_ID     = @cConfig
               and D_E_L_E_T_ = ' '
            
            If @lCubo07 = '1' begin
               If @cCONTAAnt != ' ' begin
                  Select @cDATA = @cDATAPAnt||'01'
                  Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cITEMAnt, @cCLVLAnt,
                           ##FIELDP1J( 'CT2.CT2_EC05DB' )
                            @cEC05Ant,
                           ##ENDFIELDP1J
                           ##FIELDP1K( 'CT2.CT2_EC06DB' )
                            @cEC06Ant,
                           ##ENDFIELDP1K
                           ##FIELDP1L( 'CT2.CT2_EC07DB' )
                            @cEC07Ant,
                           ##ENDFIELDP1L
                           ##FIELDP1M( 'CT2.CT2_EC08DB' )
                            @cNivAux,
                           ##ENDFIELDP1M
                           ##FIELDP1N( 'CT2.CT2_EC09DB' )
                            @cNivAux,
                           ##ENDFIELDP1N
                           @cConfig, @cAtu, @nTEC07DebM, @nTEC07CrdM
                  select @nTEC07DebM = 0
                  select @nTEC07CrdM = 0
               End
            End
         End
         ##ENDFIELDP1I
         /* ---------------------------------------------------------------
            Atualiza Cubo 8 - ENTIDADE NIVEL 08
            --------------------------------------------------------------- */
         ##FIELDP1O( 'CT2.CT2_EC08DB' )
         If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cITEM||@cCLVL||@cEC05||@cEC06||@cEC07||@cEC08||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cITEMAnt||@cCLVLAnt||@cEC05Ant||@cEC06Ant||@cEC07Ant||@cEC08Ant||@cDATAPAnt)) begin
            select @cConfig = '08'
            select @lCubo08 = CT0_CONTR
              From CT0###
             where CT0_FILIAL = @cFilial_CT0
               and CT0_ID     = @cConfig
               and D_E_L_E_T_ = ' '
            
            If @lCubo08 = '1' begin
               If @cCONTAAnt != ' ' begin
                  Select @cDATA = @cDATAPAnt||'01'
                  Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cITEMAnt, @cCLVLAnt,
                           ##FIELDP1P( 'CT2.CT2_EC05DB' )
                            @cEC05Ant,
                           ##ENDFIELDP1P
                           ##FIELDP1Q( 'CT2.CT2_EC06DB' )
                            @cEC06Ant,
                           ##ENDFIELDP1Q
                           ##FIELDP1R( 'CT2.CT2_EC07DB' )
                            @cEC07Ant,
                           ##ENDFIELDP1R
                           ##FIELDP1S( 'CT2.CT2_EC08DB' )
                            @cEC08Ant,
                           ##ENDFIELDP1S
                           ##FIELDP1T( 'CT2.CT2_EC09DB' )
                            @cNivAux,
                           ##ENDFIELDP1T
                           @cConfig, @cAtu, @nTEC08DebM, @nTEC08CrdM
                  select @nTEC08DebM = 0
                  select @nTEC08CrdM = 0
               End
            End
         End
         ##ENDFIELDP1O
         /* ---------------------------------------------------------------
            Atualiza Cubo 9 - ENTIDADE NIVEL 09
            --------------------------------------------------------------- */
         ##FIELDP1U( 'CT2.CT2_EC09DB' )
         If ((@cFILCT2||@cMOEDA||@cCONTA||@cCUSTO||@cITEM||@cCLVL||@cEC05||@cEC06||@cEC07||@cEC08||@cEC09||@cDATAP) != (@cFILCT2Ant||@cMOEDAAnt||@cCONTAAnt||@cCUSTOAnt||@cITEMAnt||@cCLVLAnt||@cEC05Ant||@cEC06Ant||@cEC07Ant||@cEC08Ant||@cEC09Ant||@cDATAPAnt)) begin
            select @cConfig = '09'
            select @lCubo09 = CT0_CONTR
              From CT0###
             where CT0_FILIAL = @cFilial_CT0
               and CT0_ID     = @cConfig
               and D_E_L_E_T_ = ' '
            
            If @lCubo09 = '1' begin
               If @cCONTAAnt != ' ' begin
                  Select @cDATA = @cDATAPAnt||'01'
                  Exec CTB210_## @cFILCT2Ant, @cDATA, @cMOEDAAnt, @IN_TPSALDO, @cCONTAAnt, @cCUSTOAnt, @cITEMAnt, @cCLVLAnt,
                           ##FIELDP1V( 'CT2.CT2_EC05DB' )
                            @cEC05Ant,
                           ##ENDFIELDP1V
                           ##FIELDP1W( 'CT2.CT2_EC06DB' )
                            @cEC06Ant,
                           ##ENDFIELDP1W
                           ##FIELDP1X( 'CT2.CT2_EC07DB' )
                            @cEC07Ant,
                           ##ENDFIELDP1X
                           ##FIELDP1Y( 'CT2.CT2_EC08DB' )
                            @cEC08Ant,
                           ##ENDFIELDP1Y
                           ##FIELDP1Z( 'CT2.CT2_EC09DB' )
                            @cEC09Ant,
                           ##ENDFIELDP1Z
                           @cConfig, @cAtu, @nTEC09DebM, @nTEC09CrdM
                  select @nTEC09DebM = 0
                  select @nTEC09CrdM = 0
               End
            End
         End
         ##ENDFIELDP1U
      End
   End
   close CUR_CUBO190B
   deallocate CUR_CUBO190B
   select @OUT_RESULTADO = '1'
End
##ENDFIELDP01
##ENDIF_001
