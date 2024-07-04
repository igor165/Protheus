Create Procedure CTB188_##(
   @IN_FILIAL    Char( 'CT2_FILIAL' ),
   @IN_DATA      Char( 08 ),
   @IN_LOTE      Char( 'CT2_LOTE' ),
   @IN_SBLOTE    Char( 'CT2_SBLOTE' ),
   @IN_DOC       Char( 'CT2_DOC' ),
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
                           @IN_INTEGRID     - '1' integridade ligada, '0'- Integridade desligada
                           @IN_MVSOMA       - '1' somo o valor no total digitado, se '2' somo duas vezes
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>
    Data        :     19/10/2009
--------------------------------------------------------------------------------------------------------------------- */
declare @cFilial_CT2 Char( 'CT2_FILIAL' )
declare @cAux        VarChar( 03 )
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
declare @nValor      Float
declare @cMoedaN     Char( 'CT2_MOEDLC' )
declare @cDebitoN    Char( 'CT2_DEBITO' )
declare @cCreditN    Char( 'CT2_CREDIT' )
declare @cCustoDN    Char( 'CT2_CCD' )
declare @cCustoCN    Char( 'CT2_CCC' )
declare @cItemDN     Char( 'CT2_ITEMD' )
declare @cItemCN     Char( 'CT2_ITEMC' )
declare @cClvlDN     Char( 'CT2_CLVLDB' )
declare @cClvlCN     Char( 'CT2_CLVLCR' )
declare @cTpSaldoN   Char( 'CT2_TPSALD' )
declare @cDcN        Char( 'CT2_DC' )
##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
##FIELDP01( 'CT2.CT2_EC05DB' )
declare @cCT2_EC05DB Char( 'CT2_EC05DB' )
declare @cCT2_EC05CR Char( 'CT2_EC05CR' )
declare @cCT2_EC05DBN Char( 'CT2_EC05DB' )
declare @cCT2_EC05CRN Char( 'CT2_EC05CR' )
##ENDFIELDP01
##FIELDP02( 'CT2.CT2_EC06DB' )
declare @cCT2_EC06DB Char( 'CT2_EC06DB' )
declare @cCT2_EC06CR Char( 'CT2_EC06CR' )
declare @cCT2_EC06DBN Char( 'CT2_EC06DB' )
declare @cCT2_EC06CRN Char( 'CT2_EC06CR' )
##ENDFIELDP02
##FIELDP03( 'CT2.CT2_EC07DB' )
declare @cCT2_EC07DB Char( 'CT2_EC07DB' )
declare @cCT2_EC07CR Char( 'CT2_EC07CR' )
declare @cCT2_EC07DBN Char( 'CT2_EC07DB' )
declare @cCT2_EC07CRN Char( 'CT2_EC07CR' )
##ENDFIELDP03
##FIELDP04( 'CT2.CT2_EC08DB' )
declare @cCT2_EC08DB Char( 'CT2_EC08DB' )
declare @cCT2_EC08CR Char( 'CT2_EC08CR' )
declare @cCT2_EC08DBN Char( 'CT2_EC08DB' )
declare @cCT2_EC08CRN Char( 'CT2_EC08CR' )
##ENDFIELDP04
##FIELDP05( 'CT2.CT2_EC09DB' )
declare @cCT2_EC09DB Char( 'CT2_EC09DB' )
declare @cCT2_EC09CR Char( 'CT2_EC09CR' )
declare @cCT2_EC09DBN Char( 'CT2_EC09DB' )
declare @cCT2_EC09CRN Char( 'CT2_EC09CR' )
##ENDFIELDP05
##ENDIF_001
declare @nValorN     Float
declare @nValorAux   Float
declare @cDataN      Char( 08 )
declare @cDtlpN      Char( 08 )
declare @cOper       Char( 01 )
declare @cResult     Char( 01 )
declare @iRecnoTRW   integer
declare @iRecnoCT2   integer
declare @lExec       char( 01 )

begin
   Select @OUT_RESULT = '0'
   Select @cResult    = '0'
   Select @lExec      = '1'
   select @cMoedaN = ' ', @cTpSaldo = ' ', @cDc     = ' ', @nValor = 0,    @nValorAux = 0
   select @cDebito = ' ', @cCredit = ' ', @cCustoD  = ' ', @cCustoC = ' ', @cItemD = ' '
   select @cItemC  = ' ', @cClvlD  = ' ', @cClvlC   = ' ', @iRecnoTRW = null
   
   select @cAux = 'CT2'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT2 OutPut
   /*---------------------------------------------------------------
     Ler Dados do CT2 - dados novos
     --------------------------------------------------------------- */
   Declare CTB_CT2 insensitive cursor for
      select CT2_MOEDLC, CT2_DATA,  CT2_TPSALD, CT2_DC,     CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_CCD, CT2_CCC,
             CT2_ITEMD,  CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_DTLP,   R_E_C_N_O_
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
           From CT2###
          Where CT2_FILIAL  = @cFilial_CT2
            and CT2_DATA    = @IN_DATA
            and CT2_LOTE    = @IN_LOTE
            and CT2_SBLOTE  = @IN_SBLOTE
            and CT2_DOC     = @IN_DOC
            and CT2_DC     != '4'
            and CT2_TPSALD != '9'
            and D_E_L_E_T_  = ' '
     Order by R_E_C_N_O_
     For read only
     Open CTB_CT2
   Fetch CTB_CT2 into @cMoedaN, @cDataN,  @cTpSaldoN, @cDcN,    @cDebitoN, @cCreditN, @nValorN,  @cCustoDN, @cCustoCN,
                      @cItemDN, @cItemCN, @cClvlDN,   @cClvlCN, @cDtlpN,   @iRecnoCT2
                     ##IF_003({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                     ##FIELDP11( 'CT2.CT2_EC05DB' )
                        , @cCT2_EC05DBN
                        , @cCT2_EC05CRN
                     ##ENDFIELDP11
                     ##FIELDP12( 'CT2.CT2_EC06DB' )
                        , @cCT2_EC06DBN
                        , @cCT2_EC06CRN
                     ##ENDFIELDP12
                     ##FIELDP13( 'CT2.CT2_EC07DB' )
                        , @cCT2_EC07DBN
                        , @cCT2_EC07CRN
                     ##ENDFIELDP13
                     ##FIELDP14( 'CT2.CT2_EC08DB' )
                        , @cCT2_EC08DBN
                        , @cCT2_EC08CRN
                     ##ENDFIELDP14
                     ##FIELDP15( 'CT2.CT2_EC09DB' )
                        , @cCT2_EC09DBN
                        , @cCT2_EC09CRN
                     ##ENDFIELDP15
                     ##ENDIF_003
   While ( @@Fetch_status = 0 ) begin
      select @iRecnoTRW = null
      select @cTpSaldo = CT2_TPSALD, @cDc = CT2_DC,        @nValor = CT2_VALOR,  @cDebito = CT2_DEBITO,  
             @cCredit = CT2_CREDIT,  @cCustoD = CT2_CCD,   @cCustoC = CT2_CCC,   @cItemD = CT2_ITEMD,
             @cItemC = CT2_ITEMC,    @cClvlD = CT2_CLVLDB, @cClvlC = CT2_CLVLCR, @iRecnoTRW = R_E_C_N_O_
            ##IF_004({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
            ##FIELDP16( 'CT2.CT2_EC05DB' )
               , @cCT2_EC05DB = CT2_EC05DB
               , @cCT2_EC05CR = CT2_EC05CR
            ##ENDFIELDP16
            ##FIELDP17( 'CT2.CT2_EC06DB' )
               , @cCT2_EC06DB = CT2_EC06DB
               , @cCT2_EC06CR = CT2_EC06CR
            ##ENDFIELDP17
            ##FIELDP18( 'CT2.CT2_EC07DB' )
               , @cCT2_EC07DB = CT2_EC07DB
               , @cCT2_EC07CR = CT2_EC07CR
            ##ENDFIELDP18
            ##FIELDP19( 'CT2.CT2_EC08DB' )
               , @cCT2_EC08DB = CT2_EC08DB
               , @cCT2_EC08CR = CT2_EC08CR
            ##ENDFIELDP19
            ##FIELDP20( 'CT2.CT2_EC09DB' )
               , @cCT2_EC09DB = CT2_EC09DB
               , @cCT2_EC09CR = CT2_EC09CR
            ##ENDFIELDP20
            ##ENDIF_004
        From TRW###
       Where R_E_C_N_O_ = @iRecnoCT2 and CT2_TPSALD <> '9'
      
      select @lExec = '0'
      If @iRecnoTRW is not null begin
         /*----------------------------------------------------------------------
           Achou a linha no TRW
           Verifica se houve alguma alteracao na linha. Se nao houve, @lExec = '0',
           se houve, @lExec = '1', Subtrai o vlr antigo e soma o novo
           ---------------------------------------------------------------------- */
         If @cDcN      = @cDc     and @cDebitoN = @cDebito and @cCreditN = @cCredit and @cCustoDN  = @cCustoD  and
            @cCustoCN  = @cCustoC and @cItemDN  = @cItemD  and @cItemCN  = @cItemC  and @cClvlDN   = @cClvlD   and
            @cClvlCN   = @cClvlC  and @nValorN  = @nValor  and @cTpSaldoN = @cTpSaldo 
            ##IF_005({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
            ##FIELDP21( 'CT2.CT2_EC05DB' )
               and @cCT2_EC05DBN = @cCT2_EC05DB
               and @cCT2_EC05CRN = @cCT2_EC05CR
            ##ENDFIELDP21
            ##FIELDP22( 'CT2.CT2_EC06DB' )
               and @cCT2_EC06DBN = @cCT2_EC06DB
               and @cCT2_EC06CRN = @cCT2_EC06CR
            ##ENDFIELDP22
            ##FIELDP23( 'CT2.CT2_EC07DB' )
               and @cCT2_EC07DBN = @cCT2_EC07DB
               and @cCT2_EC07CRN = @cCT2_EC07CR
            ##ENDFIELDP23
            ##FIELDP24( 'CT2.CT2_EC08DB' )
               and @cCT2_EC08DBN = @cCT2_EC08DB
               and @cCT2_EC08CRN = @cCT2_EC08CR
            ##ENDFIELDP24
            ##FIELDP25( 'CT2.CT2_EC09DB' )
               and @cCT2_EC09DBN = @cCT2_EC09DB
               and @cCT2_EC09CRN = @cCT2_EC09CR
            ##ENDFIELDP25
            ##ENDIF_005
            begin
            select @lExec = '0'
         end else begin
			select @lExec = '1'
		 end
         
         If @lExec = '1' begin
            select @cOper = '-'
            /*---------------------------------------------------------------
              Exclusão de contas a Debito e/ou Credito
              --------------------------------------------------------------- */
            exec CTB189_## @IN_FILIAL, @cOper,   @cDc,    @cDebito, @cCredit, @cCustoD,     @cCustoC, @cItemD, @cItemC, @cClvlD, @cClvlC,
                           @cTpSaldo,  @cMoedaN, @cDataN, @cDtlpN,  @nValor,   @IN_INTEGRID, @cResult OutPut
            /*---------------------------------------------------------------
              Exclusão/subtração de Totais por lote
              --------------------------------------------------------------- */
            exec CTB233_##  @cFilial_CT2, @cDataN,  @IN_LOTE,  @IN_SBLOTE, @IN_DOC, @cMoedaN, @cTpSaldo,  @cDc, @cOper, @IN_MVSOMA, @nValor, @cResult OutPut
            /*-------------------------------------------------------------------
              Subtrai os valores anteriores dop TRW nos Cubos Diários e Mensais - CVX e CVY
              ------------------------------------------------------------------- */
            ##IF_006({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
            ##FIELDP66( 'CT0.CT0_ID' )
            select @nValorAux = @nValor * ( -1 )
            Exec CTB156_## @cFilial_CT2, @cDebito, @cCredit, @cCustoD, @cCustoC, @cItemD, @cItemC, @cClvlD, @cClvlC
                        ##FIELDP26( 'CT2.CT2_EC05DB' )
                           , @cCT2_EC05DB
                           , @cCT2_EC05CR
                        ##ENDFIELDP26
                        ##FIELDP27( 'CT2.CT2_EC06DB' )
                           , @cCT2_EC06DB
                           , @cCT2_EC06CR
                        ##ENDFIELDP27
                        ##FIELDP28( 'CT2.CT2_EC07DB' )
                           , @cCT2_EC07DB
                           , @cCT2_EC07CR
                        ##ENDFIELDP28
                        ##FIELDP29( 'CT2.CT2_EC08DB' )
                           , @cCT2_EC08DB
                           , @cCT2_EC08CR
                        ##ENDFIELDP29
                        ##FIELDP30( 'CT2.CT2_EC09DB' )
                           , @cCT2_EC09DB
                           , @cCT2_EC09CR
                        ##ENDFIELDP30
                        ,@cMoedaN
                        ,@cDc
                        ,@cDataN
                        ,@cTpSaldo
                        ,@nValorAux
                        ,@cResult OutPut
            ##ENDFIELDP66
            ##ENDIF_006
            select @cOper = '+'
            /*---------------------------------------------------------------
              Soma de contas a Debito e/ou Credito
              --------------------------------------------------------------- */
            exec CTB189_## @IN_FILIAL, @cOper,   @cDcN,   @cDebitoN, @cCreditN, @cCustoDN,    @cCustoCN, @cItemDN, @cItemCN, @cClvlDN, @cClvlCN,
                           @cTpSaldoN, @cMoedaN, @cDataN, @cDtlpN,   @nValorN,  @IN_INTEGRID, @cResult OutPut
            /*---------------------------------------------------------------
              Soma de Totais por lote
              --------------------------------------------------------------- */
            exec CTB233_## @cFilial_CT2, @cDataN,  @IN_LOTE,  @IN_SBLOTE, @IN_DOC, @cMoedaN, @cTpSaldoN,  @cDcN, @cOper, @IN_MVSOMA, @nValorN, @cResult OutPut
            /*-------------------------------------------------------------------
              Soma os valores atuais nos Cubos Diários e Mensais - CVX e CVY
              ------------------------------------------------------------------- */
            ##IF_007({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
            ##FIELDP67( 'CT0.CT0_ID' )
            Exec CTB156_## @cFilial_CT2, @cDebitoN, @cCreditN, @cCustoDN, @cCustoCN, @cItemDN, @cItemCN, @cClvlDN, @cClvlCN
                        ##FIELDP31( 'CT2.CT2_EC05DB' )
                           , @cCT2_EC05DBN
                           , @cCT2_EC05CRN
                        ##ENDFIELDP31
                        ##FIELDP32( 'CT2.CT2_EC06DB' )
                           , @cCT2_EC06DBN
                           , @cCT2_EC06CRN
                        ##ENDFIELDP32
                        ##FIELDP33( 'CT2.CT2_EC07DB' )
                           , @cCT2_EC07DBN
                           , @cCT2_EC07CRN
                        ##ENDFIELDP33
                        ##FIELDP34( 'CT2.CT2_EC08DB' )
                           , @cCT2_EC08DBN
                           , @cCT2_EC08CRN
                        ##ENDFIELDP34
                        ##FIELDP35( 'CT2.CT2_EC09DB' )
                           , @cCT2_EC09DBN
                           , @cCT2_EC09CRN
                        ##ENDFIELDP35
                        ,@cMoedaN
                        ,@cDcN
                        ,@cDataN
                        ,@cTpSaldoN
                        ,@nValorN
                        ,@cResult OutPut
            ##ENDFIELDP67
            ##ENDIF_007
         End
         /*-----------------------------------------------------------------------
           Excluir a linha do TRW que ja foi atualizada ou a que nao teve alteraçao
           ------------------------------------------------------------------------ */
         begin tran
         delete from TRW###
          where R_E_C_N_O_ = @iRecnoTRW
         commit tran
         
      End else begin
         /*-------------------------------------------------------------------
           Se NÃO achou o recno TRW, é uma linha nova inclusao
           ------------------------------------------------------------------- */
         If @iRecnoTRW is null begin
            select @cOper = '+'
            exec CTB189_## @IN_FILIAL, @cOper,   @cDcN,   @cDebitoN, @cCreditN, @cCustoDN,    @cCustoCN, @cItemDN, @cItemCN, @cClvlDN, @cClvlCN,
                           @cTpSaldoN, @cMoedaN, @cDataN, @cDtlpN,   @nValorN,  @IN_INTEGRID, @cResult OutPut
            /*---------------------------------------------------------------
              Soma de Totais por lote
              --------------------------------------------------------------- */
            exec CTB233_## @cFilial_CT2, @cDataN,  @IN_LOTE,  @IN_SBLOTE, @IN_DOC, @cMoedaN, @cTpSaldoN,  @cDcN, @cOper, @IN_MVSOMA, @nValorN, @cResult OutPut
         /*-------------------------------------------------------------------
           Soma os valores atuais nos Cubos Diários e Mensais - CVX e CVY
           ------------------------------------------------------------------- */
         ##IF_008({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
         ##FIELDP68( 'CT0.CT0_ID' )
         Exec CTB156_## @cFilial_CT2, @cDebitoN, @cCreditN, @cCustoDN, @cCustoCN, @cItemDN, @cItemCN, @cClvlDN, @cClvlCN
                        ##FIELDP36( 'CT2.CT2_EC05DB' )
                           , @cCT2_EC05DBN
                           , @cCT2_EC05CRN
                        ##ENDFIELDP36
                        ##FIELDP37( 'CT2.CT2_EC06DB' )
                           , @cCT2_EC06DBN
                           , @cCT2_EC06CRN
                        ##ENDFIELDP37
                        ##FIELDP38( 'CT2.CT2_EC07DB' )
                           , @cCT2_EC07DBN
                           , @cCT2_EC07CRN
                        ##ENDFIELDP38
                        ##FIELDP39( 'CT2.CT2_EC08DB' )
                           , @cCT2_EC08DBN
                           , @cCT2_EC08CRN
                        ##ENDFIELDP39
                        ##FIELDP40( 'CT2.CT2_EC09DB' )
                           , @cCT2_EC09DBN
                           , @cCT2_EC09CRN
                        ##ENDFIELDP40
                        ,@cMoedaN
                        ,@cDcN
                        ,@cDataN
                        ,@cTpSaldoN
                        ,@nValorN
                        ,@cResult OutPut
         ##ENDFIELDP68
         ##ENDIF_008
         End
      End
      
      SELECT @fim_CUR = 0
      Fetch CTB_CT2 into @cMoedaN, @cDataN,  @cTpSaldoN, @cDcN,    @cDebitoN, @cCreditN, @nValorN,  @cCustoDN, @cCustoCN,
                         @cItemDN, @cItemCN, @cClvlDN,   @cClvlCN, @cDtlpN,   @iRecnoCT2
                        ##IF_009({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                        ##FIELDP41( 'CT2.CT2_EC05DB' )
                           , @cCT2_EC05DBN
                           , @cCT2_EC05CRN
                        ##ENDFIELDP41
                        ##FIELDP42( 'CT2.CT2_EC06DB' )
                           , @cCT2_EC06DBN
                           , @cCT2_EC06CRN
                        ##ENDFIELDP42
                        ##FIELDP43( 'CT2.CT2_EC07DB' )
                           , @cCT2_EC07DBN
                           , @cCT2_EC07CRN
                        ##ENDFIELDP43
                        ##FIELDP44( 'CT2.CT2_EC08DB' )
                           , @cCT2_EC08DBN
                           , @cCT2_EC08CRN
                        ##ENDFIELDP44
                        ##FIELDP45( 'CT2.CT2_EC09DB' )
                           , @cCT2_EC09DBN
                           , @cCT2_EC09CRN
                        ##ENDFIELDP45
                        ##ENDIF_009
   End
   Close CTB_CT2
   Deallocate CTB_CT2
   /* ---------------------------------------------------------------
      Ler Dados restantes do TRW
      Se está no TRW e nao esta no CT2 - linhas excluidas na alteracao 
      --------------------------------------------------------------- */
   Declare CTB_TRW insensitive cursor for
      select CT2_MOEDLC, CT2_DATA,  CT2_TPSALD, CT2_DC,     CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_CCD, CT2_CCC,
             CT2_ITEMD,  CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_DTLP,   R_E_C_N_O_
            ##IF_010({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
            ##FIELDP46( 'CT2.CT2_EC05DB' )
               , CT2_EC05DB
               , CT2_EC05CR
            ##ENDFIELDP46
            ##FIELDP47( 'CT2.CT2_EC06DB' )
               , CT2_EC06DB
               , CT2_EC06CR
            ##ENDFIELDP47
            ##FIELDP48( 'CT2.CT2_EC07DB' )
               , CT2_EC07DB
               , CT2_EC07CR
            ##ENDFIELDP48
            ##FIELDP49( 'CT2.CT2_EC08DB' )
               , CT2_EC08DB
               , CT2_EC08CR
            ##ENDFIELDP49
            ##FIELDP50( 'CT2.CT2_EC09DB' )
               , CT2_EC09DB
               , CT2_EC09CR
            ##ENDFIELDP50
            ##ENDIF_010
           From TRW###
          Where CT2_FILIAL  = @cFilial_CT2
            and CT2_DATA    = @IN_DATA
            and CT2_LOTE    = @IN_LOTE
            and CT2_SBLOTE  = @IN_SBLOTE
            and CT2_DOC     = @IN_DOC
            and D_E_L_E_T_  = ' '
     Order by R_E_C_N_O_
     For read only
     Open CTB_TRW
   Fetch CTB_TRW into @cMoedaN, @cDataN,  @cTpSaldoN, @cDcN,    @cDebitoN, @cCreditN, @nValorN,  @cCustoDN, @cCustoCN,
                      @cItemDN, @cItemCN, @cClvlDN,   @cClvlCN, @cDtlpN,   @iRecnoTRW
                     ##IF_011({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                     ##FIELDP51( 'CT2.CT2_EC05DB' )
                        , @cCT2_EC05DBN
                        , @cCT2_EC05CRN
                     ##ENDFIELDP51
                     ##FIELDP52( 'CT2.CT2_EC06DB' )
                        , @cCT2_EC06DBN
                        , @cCT2_EC06CRN
                     ##ENDFIELDP52
                     ##FIELDP53( 'CT2.CT2_EC07DB' )
                        , @cCT2_EC07DBN
                        , @cCT2_EC07CRN
                     ##ENDFIELDP53
                     ##FIELDP54( 'CT2.CT2_EC08DB' )
                        , @cCT2_EC08DBN
                        , @cCT2_EC08CRN
                     ##ENDFIELDP54
                     ##FIELDP55( 'CT2.CT2_EC09DB' )
                        , @cCT2_EC09DBN
                        , @cCT2_EC09CRN
                     ##ENDFIELDP55
                     ##ENDIF_011
   While ( @@Fetch_status = 0 ) begin
      select @cOper = '-'
      exec CTB189_## @IN_FILIAL, @cOper,   @cDcN,   @cDebitoN, @cCreditN,    @cCustoDN, @cCustoCN, @cItemDN, @cItemCN, @cClvlDN, @cClvlCN,
                     @cTpSaldoN, @cMoedaN, @cDataN, @cDtlpN, @nValorN,  @IN_INTEGRID, @cResult OutPut
      /*---------------------------------------------------------------
        Soma de Totais por lote
        --------------------------------------------------------------- */
      exec CTB233_## @cFilial_CT2, @cDataN,  @IN_LOTE,  @IN_SBLOTE, @IN_DOC, @cMoedaN, @cTpSaldoN,  @cDcN, @cOper, @IN_MVSOMA, @nValorN, @cResult OutPut
      /*-------------------------------------------------------------------
        Subtrai os valores anteriores dop TRW nos Cubos Diários e Mensais - CVX e CVY
        ------------------------------------------------------------------- */
      ##IF_012({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
      ##FIELDP69( 'CT0.CT0_ID' )
      select @nValorAux = @nValorN * ( -1 )
      Exec CTB156_## @cFilial_CT2, @cDebitoN, @cCreditN, @cCustoDN, @cCustoCN, @cItemDN, @cItemCN, @cClvlDN, @cClvlCN
                     ##FIELDP56( 'CT2.CT2_EC05DB' )
                        , @cCT2_EC05DBN
                        , @cCT2_EC05CRN
                     ##ENDFIELDP56
                     ##FIELDP57( 'CT2.CT2_EC06DB' )
                        , @cCT2_EC06DBN
                        , @cCT2_EC06CRN
                     ##ENDFIELDP57
                     ##FIELDP58( 'CT2.CT2_EC07DB' )
                        , @cCT2_EC07DBN
                        , @cCT2_EC07CRN
                     ##ENDFIELDP58
                     ##FIELDP59( 'CT2.CT2_EC08DB' )
                        , @cCT2_EC08DBN
                        , @cCT2_EC08CRN
                     ##ENDFIELDP59
                     ##FIELDP60( 'CT2.CT2_EC09DB' )
                        , @cCT2_EC09DBN
                        , @cCT2_EC09CRN
                     ##ENDFIELDP60
                     ,@cMoedaN
                     ,@cDcN
                     ,@cDataN
                     ,@cTpSaldoN
                     ,@nValorAux
                     ,@cResult OutPut
      ##ENDFIELDP69
      ##ENDIF_012
      /*-------------------------------------------------------------------
        Excluir a linha do TRW que ja foi atualizada
        ------------------------------------------------------------------- */
      begin tran
      delete from TRW###
       where R_E_C_N_O_ = @iRecnoTRW
      commit tran
      Fetch CTB_TRW into @cMoedaN, @cDataN,  @cTpSaldoN, @cDcN,    @cDebitoN, @cCreditN, @nValorN,  @cCustoDN, @cCustoCN,
                         @cItemDN, @cItemCN, @cClvlDN,   @cClvlCN, @cDtlpN,   @iRecnoTRW
                     ##IF_013({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                     ##FIELDP61( 'CT2.CT2_EC05DB' )
                        , @cCT2_EC05DBN
                        , @cCT2_EC05CRN
                     ##ENDFIELDP61
                     ##FIELDP62( 'CT2.CT2_EC06DB' )
                        , @cCT2_EC06DBN
                        , @cCT2_EC06CRN
                     ##ENDFIELDP62
                     ##FIELDP63( 'CT2.CT2_EC07DB' )
                        , @cCT2_EC07DBN
                        , @cCT2_EC07CRN
                     ##ENDFIELDP63
                     ##FIELDP64( 'CT2.CT2_EC08DB' )
                        , @cCT2_EC08DBN
                        , @cCT2_EC08CRN
                     ##ENDFIELDP64
                     ##FIELDP65( 'CT2.CT2_EC09DB' )
                        , @cCT2_EC09DBN
                        , @cCT2_EC09CRN
                     ##ENDFIELDP65
                     ##ENDIF_013
   End
   Close CTB_TRW
   Deallocate CTB_TRW
   
   Select @OUT_RESULT = @cResult
End
