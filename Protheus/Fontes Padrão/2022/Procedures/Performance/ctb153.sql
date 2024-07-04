Create Procedure CTB153_##(
   @IN_FILIAL    Char( 'CT2_FILIAL' ),
   @IN_DATA      Char( 08 ),
   @IN_LOTE      Char( 'CT2_LOTE' ),
   @IN_SBLOTE    Char( 'CT2_SBLOTE' ),
   @IN_DOC       Char( 'CT2_DOC' ),
   @OUT_RESULT   Char( 01 ) OutPut
)

as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  010 </a>
    Fonte Microsiga - <s>  ctbxfun.prx </s>
    Descricao       - <d>  Popular o TRW### </d>
    Funcao do Siga  -      ctbxfun
    Entrada         - <ri> @IN_FILIAL       - Filial onde a manutencao sera feita
                           @IN_DATA         - Data do Lote
                           @IN_LOTE         - Nro do Lote a ser alterado ou excluido
                           @IN_SBLOTE       - Nro do Sublote a ser alterado ou excluido
                           @IN_DOC          - Nro do Documento a ser alterado ou excluido
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     20/05/2005
--------------------------------------------------------------------------------------------------------------------- */

declare @cFilial_CT2 Char( 'CT2_FILIAL' )
declare @cMoeda      Char( 'CT2_MOEDLC' )
declare @cLinha      Char( 'CT2_LINHA' )
declare @cDebito     Char( 'CT2_DEBITO' )
declare @cCredit     Char( 'CT2_CREDIT' )
declare @cCustoD     Char( 'CT2_CCD' )
declare @cCustoC     Char( 'CT2_CCC' )
declare @cItemD      Char( 'CT2_ITEMD' )
declare @cItemC      Char( 'CT2_ITEMC' )
declare @cClvlD      Char( 'CT2_CLVLDB' )
declare @cClvlC      Char( 'CT2_CLVLCR' )
declare @cAux        VarChar( 03 )
declare @cTpSaldo    Char( 'CT2_TPSALD' )
declare @cDc         Char( 'CT2_DC' )
declare @cEmpOri     Char( 'CT2_EMPORI' )
declare @cFilOri     Char( 'CT2_FILORI' )
declare @iRecno      Integer
declare @nValor      Float
##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
##FIELDP01( 'CT2.CT2_EC05DB' )
declare @cEc05Db     Char( 'CT2_EC05DB' )
declare @cEc05Cr     Char( 'CT2_EC05CR' )
##ENDFIELDP01
##FIELDP02( 'CT2.CT2_EC06DB' )
declare @cEc06Db     Char( 'CT2_EC06DB' )
declare @cEc06Cr     Char( 'CT2_EC06CR' )
##ENDFIELDP02
##FIELDP03( 'CT2.CT2_EC07DB' )
declare @cEc07Db     Char( 'CT2_EC07DB' )
declare @cEc07Cr     Char( 'CT2_EC07CR' )
##ENDFIELDP03
##FIELDP04( 'CT2.CT2_EC08DB' )
declare @cEc08Db     Char( 'CT2_EC08DB' )
declare @cEc08Cr     Char( 'CT2_EC08CR' )
##ENDFIELDP04
##FIELDP05( 'CT2.CT2_EC09DB' )
declare @cEc09Db     Char( 'CT2_EC09DB' )
declare @cEc09Cr     Char( 'CT2_EC09CR' )
##ENDFIELDP05
##ENDIF_001
begin
   Select @OUT_RESULT = '0'
   /*---------------------------------------------------------------
     Popular a CT2TMP### com dados do registro a excluir ou alterar
     --------------------------------------------------------------- */
   select @cAux = 'CT2'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT2 OutPut
   
   /*---------------------------------------------------------------
     Excluir sujeira da tabela TRW###
     --------------------------------------------------------------- */
   begin tran
   Delete from TRW###
     Where CT2_FILIAL  = @cFilial_CT2
       and CT2_DATA    = @IN_DATA
       and CT2_LOTE    = @IN_LOTE
       and CT2_SBLOTE  = @IN_SBLOTE
       and CT2_DOC     = @IN_DOC
       and CT2_DC     != '4'
       and D_E_L_E_T_  = ' '
   commit tran
   /*---------------------------------------------------------------
     Trazer os dados do lancto a alterar ou excluir
     --------------------------------------------------------------- */
   Declare CTB_CT2 insensitive cursor for
    select CT2_MOEDLC, CT2_LINHA, CT2_TPSALD, CT2_DC,     CT2_DEBITO, CT2_CREDIT, CT2_VALOR,  CT2_CCD, CT2_CCC,
           CT2_ITEMD,  CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_EMPORI, CT2_FILORI, R_E_C_N_O_
         ##IF_002({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
           ##FIELDP06( 'CT2.CT2_EC05DB' )
             , CT2_EC05DB, CT2_EC05CR
           ##ENDFIELDP06
           ##FIELDP07( 'CT2.CT2_EC06DB' )
             , CT2_EC06DB, CT2_EC06CR
           ##ENDFIELDP07
           ##FIELDP08( 'CT2.CT2_EC07DB' )
             , CT2_EC07DB, CT2_EC07CR
           ##ENDFIELDP08
           ##FIELDP09( 'CT2.CT2_EC08DB' )
             , CT2_EC08DB, CT2_EC08CR
           ##ENDFIELDP09
           ##FIELDP10( 'CT2.CT2_EC09DB' )
             , CT2_EC09DB, CT2_EC09CR
           ##ENDFIELDP10
         ##ENDIF_002
      From CT2###
     Where CT2_FILIAL  = @cFilial_CT2
       and CT2_DATA    = @IN_DATA
       and CT2_LOTE    = @IN_LOTE
       and CT2_SBLOTE  = @IN_SBLOTE
       and CT2_DOC     = @IN_DOC
       and CT2_DC      != '4'
       and CT2_TPSALD <> '9'
	   and D_E_L_E_T_  = ' '	   
     For read only
     Open CTB_CT2
   Fetch CTB_CT2 into @cMoeda, @cLinha, @cTpSaldo, @cDc,    @cDebito, @cCredit, @nValor,  @cCustoD, @cCustoC,
                      @cItemD, @cItemC, @cClvlD, @cClvlC,  @cEmpOri, @cFilOri, @iRecno
                     ##IF_003({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                        ##FIELDP11( 'CT2.CT2_EC05DB' )
                        , @cEc05Db, @cEc05Cr
                        ##ENDFIELDP11
                        ##FIELDP12( 'CT2.CT2_EC06DB' )
                        , @cEc06Db, @cEc06Cr
                        ##ENDFIELDP12
                        ##FIELDP13( 'CT2.CT2_EC07DB' )
                        , @cEc07Db, @cEc07Cr
                        ##ENDFIELDP13
                        ##FIELDP14( 'CT2.CT2_EC08DB' )
                        , @cEc08Db, @cEc08Cr
                        ##ENDFIELDP14
                        ##FIELDP15( 'CT2.CT2_EC09DB' )
                        , @cEc09Db, @cEc09Cr
                        ##ENDFIELDP15
                     ##ENDIF_003
   While ( @@Fetch_status = 0 ) begin
      Begin Tran 
      Insert Into TRW### ( CT2_FILIAL, CT2_DATA,   CT2_LOTE,   CT2_SBLOTE, CT2_DOC, CT2_MOEDLC, CT2_TPSALD, CT2_DC,
                           CT2_DEBITO, CT2_CREDIT, CT2_VALOR,  CT2_CCD,    CT2_CCC, CT2_ITEMD,  CT2_ITEMC,  CT2_CLVLDB,
                           CT2_CLVLCR, CT2_EMPORI, CT2_FILORI, CT2_LINHA,  R_E_C_N_O_ 
                           ##IF_004({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                           ##FIELDP16( 'CT2.CT2_EC05DB' )
                            , CT2_EC05DB, CT2_EC05CR
                           ##ENDFIELDP16
                           ##FIELDP17( 'CT2.CT2_EC06DB' )
                            , CT2_EC06DB, CT2_EC06CR
                           ##ENDFIELDP17
                           ##FIELDP18( 'CT2.CT2_EC07DB' )
                            , CT2_EC07DB, CT2_EC07CR
                           ##ENDFIELDP18
                           ##FIELDP19( 'CT2.CT2_EC08DB' )
                            , CT2_EC08DB, CT2_EC08CR
                           ##ENDFIELDP19
                           ##FIELDP20( 'CT2.CT2_EC09DB' )
                            , CT2_EC09DB, CT2_EC09CR
                           ##ENDFIELDP20
                           ##ENDIF_004
                         )
                  Values ( @cFilial_CT2, @IN_DATA, @IN_LOTE, @IN_SBLOTE, @IN_DOC,  @cMoeda, @cTpSaldo, @cDc,
                           @cDebito,     @cCredit, @nValor,  @cCustoD,   @cCustoC, @cItemD, @cItemC,   @cClvlD,
                           @cClvlC,      @cEmpOri, @cFilOri, @cLinha,    @iRecno
                           ##IF_005({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                           ##FIELDP21( 'CT2.CT2_EC05DB' )
                           , @cEc05Db, @cEc05Cr
                           ##ENDFIELDP21
                           ##FIELDP22( 'CT2.CT2_EC06DB' )
                           , @cEc06Db, @cEc06Cr
                           ##ENDFIELDP22
                           ##FIELDP23( 'CT2.CT2_EC07DB' )
                           , @cEc07Db, @cEc07Cr
                           ##ENDFIELDP23
                           ##FIELDP24( 'CT2.CT2_EC08DB' )
                           , @cEc08Db, @cEc08Cr
                           ##ENDFIELDP24
                           ##FIELDP25( 'CT2.CT2_EC09DB' )
                           , @cEc09Db, @cEc09Cr
                           ##ENDFIELDP25
                           ##ENDIF_005
                         )
      commit tran   
      Fetch CTB_CT2 into @cMoeda, @cLinha, @cTpSaldo, @cDc,    @cDebito, @cCredit, @nValor, @cCustoD, @cCustoC,
                         @cItemD, @cItemC, @cClvlD, @cClvlC,  @cEmpOri, @cFilOri, @iRecno
                           ##IF_006({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                           ##FIELDP26( 'CT2.CT2_EC05DB' )
                           , @cEc05Db, @cEc05Cr
                           ##ENDFIELDP26
                           ##FIELDP27( 'CT2.CT2_EC06DB' )
                           , @cEc06Db, @cEc06Cr
                           ##ENDFIELDP27
                           ##FIELDP28( 'CT2.CT2_EC07DB' )
                           , @cEc07Db, @cEc07Cr
                           ##ENDFIELDP28
                           ##FIELDP29( 'CT2.CT2_EC08DB' )
                           , @cEc08Db, @cEc08Cr
                           ##ENDFIELDP29
                           ##FIELDP30( 'CT2.CT2_EC09DB' )
                           , @cEc09Db, @cEc09Cr
                           ##ENDFIELDP30
                           ##ENDIF_006
   End
   Close CTB_CT2
   Deallocate CTB_CT2
   
   Select @OUT_RESULT = '1'
End
