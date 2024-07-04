Create Procedure CTB190_##(
   @IN_FILIAL    Char( 'CT2_FILIAL' ),
   @IN_DATA      Char( 08 ),
   @IN_LOTE      Char( 'CT2_LOTE' ),
   @IN_SBLOTE    Char( 'CT2_SBLOTE' ),
   @IN_DOC       Char( 'CT2_DOC' ),
   @IN_ATIVDE    Char( 'CT2_ATIVDE' ),
   @IN_INTEGRID  Char( 01 ),
   @IN_MVSOMA    Char( 01 ),
   @OUT_RESULT   Char( 01 ) OutPut
)

as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ctbxatu.prx </s>
    Descricao       - <d>  Atualizacao de Saldos na Alteração do Lote  </d>
    Entrada         - <ri> @IN_FILIAL       - Filial onde a manutencao sera feita
                           @IN_DATA         - Data do Lote
                           @IN_LOTE         - Nro do Lote a ser alterado ou excluido
                           @IN_SBLOTE       - Nro do Sublote a ser alterado ou excluido
                           @IN_DOC          - Nro do Documento a ser alterado ou excluido
                           @IN_ATIVDE       - Identifica qual CT2 deverao ter os saldos atualizados
                           @IN_INTEGRID     - '1' integridade ligada, '0'- Integridade desligada
                           @IN_MVSOMA       - '1' somo o valor no total digitado, se '2' somo duas vezes
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>
    Data        :     19/10/2009
--------------------------------------------------------------------------------------------------------------------- */
declare @cFilial_CT2 Char( 'CT2_FILIAL' )
declare @cAux        VarChar( 03 )
declare @cMoeda      Char( 'CT2_MOEDLC' )
declare @cData       Char( 08 )
declare @cDtlp       Char( 08 )
declare @cDebito     Char( 'CT2_DEBITO' )
declare @cCredit     Char( 'CT2_CREDIT' )
declare @cCustoD     Char( 'CT2_CCD' )
declare @cCustoC     Char( 'CT2_CCC' )
declare @cItemD      Char( 'CT2_ITEMD' )
declare @cItemC      Char( 'CT2_ITEMC' )
declare @cClvlD      Char( 'CT2_CLVLDB' )
declare @cClvlC      Char( 'CT2_CLVLCR' )
declare @cTpSaldo    Char( 'CT2_TPSALD' )
declare @cDc         Char( 'CT2_DC' )
declare @cAtiv       Char( 'CT2_ATIVDE' )
##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
##FIELDP01( 'CT2.CT2_EC05DB' )
declare @cCT2_EC05DB Char( 'CT2_EC05DB' )
declare @cCT2_EC05CR Char( 'CT2_EC05CR' )
##ENDFIELDP01
##FIELDP02( 'CT2.CT2_EC06DB' )
declare @cCT2_EC06DB Char( 'CT2_EC06DB' )
declare @cCT2_EC06CR Char( 'CT2_EC06CR' )
##ENDFIELDP02
##FIELDP03( 'CT2.CT2_EC07DB' )
declare @cCT2_EC07DB Char( 'CT2_EC07DB' )
declare @cCT2_EC07CR Char( 'CT2_EC07CR' )
##ENDFIELDP03
##FIELDP04( 'CT2.CT2_EC08DB' )
declare @cCT2_EC08DB Char( 'CT2_EC08DB' )
declare @cCT2_EC08CR Char( 'CT2_EC08CR' )
##ENDFIELDP04
##FIELDP05( 'CT2.CT2_EC09DB' )
declare @cCT2_EC09DB Char( 'CT2_EC09DB' )
declare @cCT2_EC09CR Char( 'CT2_EC09CR' )
##ENDFIELDP05
##ENDIF_001
declare @nValor      Float
declare @cOper       Char( 01 )
declare @cResult     Char( 01 )
declare @iRecnoTRW   integer

begin
   Select @OUT_RESULT = '0'
   Select @cResult    = '0'
   select @cOper      = '+'
   
   select @cAux = 'CT2'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT2 OutPut
   /*---------------------------------------------------------------
     Ler Dados do CT2 - dados novos
     --------------------------------------------------------------- */
   Declare CTB_CT2 insensitive cursor for
      select CT2_MOEDLC, CT2_DATA,  CT2_TPSALD, CT2_DC,     CT2_DEBITO, CT2_CREDIT,  CT2_VALOR, CT2_CCD, CT2_CCC,
             CT2_ITEMD,  CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_DTLP,   CT2_ATIVDE, R_E_C_N_O_
            ##IF_002({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
            ##FIELDP06( 'CT2.CT2_EC05DB' )
               , CT2_EC05DB
               , CT2_EC05CR
            ##ENDFIELDP06
            ##FIELDP07( 'CT2.CT2_EC06DB' )
               , CT2_EC06DB
               , CT2_EC06CR
            ##ENDFIELDP07
            ##FIELDP08( 'CT2.CT2_EC07DB' )
               , CT2_EC07DB
               , CT2_EC07CR
            ##ENDFIELDP08
            ##FIELDP09( 'CT2.CT2_EC08DB' )
               , CT2_EC08DB
               , CT2_EC08CR
            ##ENDFIELDP09
            ##FIELDP10( 'CT2.CT2_EC09DB' )
               , CT2_EC09DB
               , CT2_EC09CR
            ##ENDFIELDP10
            ##ENDIF_002
           From TRW###
          Where CT2_FILIAL  = @cFilial_CT2
            and CT2_DATA    = @IN_DATA
            and CT2_LOTE    = @IN_LOTE
            and CT2_SBLOTE  = @IN_SBLOTE
            and CT2_ATIVDE  = @IN_ATIVDE
            and CT2_DC     != '4'
            and CT2_TPSALD != '9'
            and D_E_L_E_T_  = ' '
     Order by R_E_C_N_O_
     For read only
     Open CTB_CT2
   Fetch CTB_CT2 into @cMoeda, @cData,  @cTpSaldo, @cDc,    @cDebito, @cCredit, @nValor,  @cCustoD, @cCustoC,
                      @cItemD, @cItemC, @cClvlD,   @cClvlC, @cDtlp,   @cAtiv,   @iRecnoTRW
                     ##IF_003({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                     ##FIELDP11( 'CT2.CT2_EC05DB' )
                        , @cCT2_EC05DB
                        , @cCT2_EC05CR
                     ##ENDFIELDP11
                     ##FIELDP12( 'CT2.CT2_EC06DB' )
                        , @cCT2_EC06DB
                        , @cCT2_EC06CR
                     ##ENDFIELDP12
                     ##FIELDP13( 'CT2.CT2_EC07DB' )
                        , @cCT2_EC07DB
                        , @cCT2_EC07CR
                     ##ENDFIELDP13
                     ##FIELDP14( 'CT2.CT2_EC08DB' )
                        , @cCT2_EC08DB
                        , @cCT2_EC08CR
                     ##ENDFIELDP14
                     ##FIELDP15( 'CT2.CT2_EC09DB' )
                        , @cCT2_EC09DB
                        , @cCT2_EC09CR
                     ##ENDFIELDP15
                     ##ENDIF_003
   While ( @@Fetch_status = 0 ) begin
      
      If @cDc != '4' begin
         exec CTB189_## @IN_FILIAL, @cOper,  @cDc,   @cDebito, @cCredit, @cCustoD,     @cCustoC, @cItemD, @cItemC, @cClvlD, @cClvlC,
                        @cTpSaldo,  @cMoeda, @cData, @cDtlp,   @nValor,  @IN_INTEGRID, @cResult OutPut
         /*---------------------------------------------------------------
           Soma de Totais por lote
           --------------------------------------------------------------- */
         exec CTB233_## @cFilial_CT2, @cData,  @IN_LOTE,  @IN_SBLOTE, @IN_DOC, @cMoeda, @cTpSaldo,  @cDc, @cOper, @IN_MVSOMA, @nValor, @cResult OutPut
         /*-------------------------------------------------------------------
           Atualiza os Cubos Diários e Mensais - CVX e CVY
           ------------------------------------------------------------------- */
         ##IF_004({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
         ##FIELDP26( 'CT0.CT0_ID' )
         Exec CTB156_## @IN_FILIAL, @cDebito, @cCredit, @cCustoD, @cCustoC, @cItemD, @cItemC, @cClvlD, @cClvlC
                        ##FIELDP16( 'CT2.CT2_EC05DB' )
                           , @cCT2_EC05DB
                           , @cCT2_EC05CR
                        ##ENDFIELDP16
                        ##FIELDP17( 'CT2.CT2_EC06DB' )
                           , @cCT2_EC06DB
                           , @cCT2_EC06CR
                        ##ENDFIELDP17
                        ##FIELDP18( 'CT2.CT2_EC07DB' )
                           , @cCT2_EC07DB
                           , @cCT2_EC07CR
                        ##ENDFIELDP18
                        ##FIELDP19( 'CT2.CT2_EC08DB' )
                           , @cCT2_EC08DB
                           , @cCT2_EC08CR
                        ##ENDFIELDP19
                        ##FIELDP20( 'CT2.CT2_EC09DB' )
                           , @cCT2_EC09DB
                           , @cCT2_EC09CR
                        ##ENDFIELDP20
                        ,@cMoeda
                        ,@cDc
                        ,@cData
                        ,@cTpSaldo
                        ,@nValor
                        ,@cResult OutPut
       ##ENDFIELDP26
       ##ENDIF_004
      End
      /*-------------------------------------------------------------------
        Excluir a linha do TRW que ja foi atualizada
        ------------------------------------------------------------------- */
      begin tran
      delete from TRW###
       where R_E_C_N_O_ = @iRecnoTRW
      commit tran
      
      Fetch CTB_CT2 into @cMoeda, @cData,  @cTpSaldo, @cDc,    @cDebito, @cCredit, @nValor,  @cCustoD, @cCustoC,
                         @cItemD, @cItemC, @cClvlD,   @cClvlC, @cDtlp,   @cAtiv,   @iRecnoTRW
                        ##IF_005({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                        ##FIELDP21( 'CT2.CT2_EC05DB' )
                           , @cCT2_EC05DB
                           , @cCT2_EC05CR
                        ##ENDFIELDP21
                        ##FIELDP22( 'CT2.CT2_EC06DB' )
                           , @cCT2_EC06DB
                           , @cCT2_EC06CR
                        ##ENDFIELDP22
                        ##FIELDP23( 'CT2.CT2_EC07DB' )
                           , @cCT2_EC07DB
                           , @cCT2_EC07CR
                        ##ENDFIELDP23
                        ##FIELDP24( 'CT2.CT2_EC08DB' )
                           , @cCT2_EC08DB
                           , @cCT2_EC08CR
                        ##ENDFIELDP24
                        ##FIELDP25( 'CT2.CT2_EC09DB' )
                           , @cCT2_EC09DB
                           , @cCT2_EC09CR
                        ##ENDFIELDP25
                        ##ENDIF_005
   End
   Close CTB_CT2
   Deallocate CTB_CT2
   
   Select @OUT_RESULT = @cResult
End
