Create Procedure CTB150_##(
   @IN_FILIAL    Char( 'CT2_FILIAL' ),
   @IN_LOTE      Char( 'CT2_LOTE' ),
   @IN_SBLOTE    Char( 'CT2_SBLOTE' ),
   @IN_DOC       Char( 'CT2_DOC' ),
   @IN_DATA      Char( 08 ),
   @IN_OPERACAO  Char( 01 ),
   @IN_MVSOMA    Char( 01 ),
   @IN_LINHA     Char( 'CT2_LINHA' ),
   @IN_MOEDA     Char( 'CT2_MOEDLC' ),
   @IN_FLAG      Char( 01 ),
   @IN_INTEGRIDADE Char(01),
   @OUT_RESULT   Char( 01 ) Output
)

as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  010 </a>
    Fonte Microsiga - <s>  CTBA102.PRW </s>
    Descricao       - <d>  Inclusao/Alteracao/Exclusao de Registros </d>
    Funcao do Siga  -      CTB102Proc()
    Entrada         - <ri> @IN_FILIAL       - Filial corrente da manutencao do arquivo de lanctos
                           @IN_LOTE         - Lote a efetuar manutencao
                           @IN_SBLOTE       - Sublote a efetuar manutencao
                           @IN_DOC          - Documento a efetuar manutencao
                           @IN_DATA         - Data da manutencao
                           @IN_OPERACAO     - Operacao realizada, 3-Inclusao, 4-Alteracao, 5-Exclusao
                           @IN_MVSOMA       - Indica se soma 1 ou 2 vezes no CTC E CT6 
                           @IN_LINHA        - Nro da linha a atualizar
                           @IN_MOEDA        - Moeda a atualizar
                           @IN_FLAG         - Somente na Op de alteracao. Se '1', a linha excluida na alteracao
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada </ri>
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     20/05/2005
    
    1. CTB150 - Manutencao de Cadastros de lactos contabeis
         2. CTB151 - Faz as chamadas de acordo com a operacao direcionada
              3. CTB152 - EXCLUSÃO
                   4. CTB159 - Exclusão de Débitos
                        5.  CTB161 - Atualizacao de CTX_SLCOMP com 'N'
                   4. CTB160 - Exclusão de Créditos
                        5.  CTB161 - Atualizacao de CTX_SLCOMP com 'N'
         2. CTB156 - ATUALIZACAO DE CUBOS - SE ATIVO
              3. CTB200 - Atualizacao do CUBO 01 - PLANO CONTAS
              3. CTB201 - Atualizacao do CUBO 02 - CENTRO DE CUSTO
              3. CTB202 - Atualizacao do CUBO 03 - ITEM 
              3. CTB203 - Atualizacao do CUBO 04 - CLASSE DE VALOR
              3. CTB204 - Atualizacao do CUBO 05 - ENTIDADE NIV05
              3. CTB205 - Atualizacao do CUBO 06 - ENTIDADE NIV06
              3. CTB206 - Atualizacao do CUBO 07 - ENTIDADE NIV07
              3. CTB207 - Atualizacao do CUBO 08 - ENTIDADE NIV08
              3. CTB208 - Atualizacao do CUBO 09 - ENTIDADE NIV09
              3. CTB154 - INCLUSAO
                   4. CTB157 - Inclusão de Débitos
                        5.  CTB161 - Atualizacao de CTX_SLCOMP com 'N'
                   4. CTB158 - Inclusão de Créditos
                        5.  CTB161 - Atualizacao de CTX_SLCOMP com 'N'
              3. CTB155 - ALTERACAO
                   4. CTB159 - Exclusão de Débitos
                        5.  CTB161 - Atualizacao de CTX_SLCOMP com 'N'
                   4. CTB160 - Exclusão de Créditos
                        5.  CTB161 - Atualizacao de CTX_SLCOMP com 'N'
                   4. CTB157 - Inclusão de Débitos
                        5.  CTB161 - Atualizacao de CTX_SLCOMP com 'N'
                   4. CTB158 - Inclusão de Créditos
                        5.  CTB161 - Atualizacao de CTX_SLCOMP com 'N'
         2. CTB164 - Exclui as linhas das entidades com debito e credito zeros
1 - INCLUSAO de lancamentos
   - Le o CT2 e atualiza os saldos até a data de hj
   - Na data de inclusão atualiza os campos CTX_DEBITO e/ CTX_CREDITO, CTX_ATUDEB e/ CTX_ATUCRD
   - Nas datas posteriores a da inclusao atualiza CTX_ATUDEB e/ CTX_ATUCRD, CTX_ANTDEB/CTX_ANTCRD
2 - EXCLUSAO de lancamentos
   - Le a tabela temporaria TRW### (*) que contêm os dados da(s) linha(s) a excluir.
   - Na data da exclusão subtraio o valor a excluir dos campos CTX_DEBITO e/ CTX_CREDITO, CTX_ATUDEB e/ CTX_ATUCRD
   - Nas datas posteriores subtraio o valor a excluir dos campos CTX_ATUDEB e/ CTX_ATUCRD, CTX_ANTDEB/CTX_ANTCRD
2 - ALTERACAO de lancamentos
   - Le a tabela temporária TRW### (*) que contém as linhas do Lote a ser alterado
   - Se a linha estiver deletada faz a exclusao comodescritoacima, se for linha nova faz a inclusao tb como
      descrito acima, se não houver alteração nao faz nada se houver alteraçao em alguns campos efetua a subtração
      do valor anterior e a soma do valor novo

   (*)A TRW### é criada através do  CFGX051, no momento da instalaçao das procedures. É utilizada na manutenção dos
      lanctos, especificamente, na exclusão e na alteração de lanctos.
      É populada antes da operacao de exclusao ou alteracao.
--------------------------------------------------------------------------------------------------------------------- */
declare @cFilial_CT2 Char( 'CT2_FILIAL' )
declare @cFilial_CT3 Char( 'CT3_FILIAL' )
declare @cFilial_CT4 Char( 'CT4_FILIAL' )
declare @cFilial_CT7 Char( 'CT7_FILIAL' )
declare @cFilial_CTI Char( 'CTI_FILIAL' )
declare @cMoeda      Char( 'CT7_MOEDA' )
declare @cMoedaA     Char( 'CT7_MOEDA' )
declare @cLinha      Char( 'CT2_LINHA' )
declare @cLinhaA     Char( 'CT2_LINHA' )
declare @cTpSaldo    Char( 'CT2_TPSALD')
declare @cTpSaldoA   Char( 'CT2_TPSALD')
declare @cDc         Char( 'CT2_DC' )
declare @cDcA        Char( 'CT2_DC' )
declare @cDebito     Char( 'CT7_CONTA' )
declare @cDebitoA    Char( 'CT7_CONTA' )
declare @cCredit     Char( 'CT7_CONTA' )
declare @cCreditA    Char( 'CT7_CONTA' )
declare @cCustoD     Char( 'CT3_CUSTO' )
declare @cCustoDA    Char( 'CT3_CUSTO' )
declare @cCustoC     Char( 'CT3_CUSTO' )
declare @cCustoCA    Char( 'CT3_CUSTO' )
declare @cItemD      Char( 'CT4_ITEM' )
declare @cItemDA     Char( 'CT4_ITEM' )
declare @cItemC      Char( 'CT4_ITEM' )
declare @cItemCA     Char( 'CT4_ITEM' )
declare @cClvlD      Char( 'CTI_CLVL' )
declare @cClvlDA     Char( 'CTI_CLVL' )
declare @cClvlC      Char( 'CTI_CLVL' )
declare @cClvlCA     Char( 'CTI_CLVL' )
declare @cOperacao   Char( 01 )
declare @cDelet      Char( 01 )
declare @cDeletA     Char( 01 )
declare @lExec       Char( 01 )
declare @cDtLp       Char( 08 )
declare @cResult     Char( 01 )
declare @cAux        VarChar( 03 )
declare @iRecno      Integer
declare @iRecnoA     Integer
declare @nValorA     Float
declare @nValor      Float
declare @iRecnoMax   Integer
declare @cLinhaMax   Char( 'CT2_LINHA' )
declare @cMoedaMax   Char( 'CT7_MOEDA' )
##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
##FIELDP01( 'CT2.CT2_EC05DB' )
   Declare @cNiv05DbA Char( 'CT2_EC05DB' )
   Declare @cNiv05Db  Char( 'CT2_EC05DB' )
   Declare @cNiv05CrA Char( 'CT2_EC05DB' )
   Declare @cNiv05Cr  Char( 'CT2_EC05DB' )
##ENDFIELDP01
##FIELDP02( 'CT2.CT2_EC06DB' )
   Declare @cNiv06DbA Char( 'CT2_EC06DB' )
   Declare @cNiv06Db  Char( 'CT2_EC06DB' )
   Declare @cNiv06CrA Char( 'CT2_EC06DB' )
   Declare @cNiv06Cr  Char( 'CT2_EC06DB' )
##ENDFIELDP02
##FIELDP03( 'CT2.CT2_EC07DB' )
   Declare @cNiv07DbA Char( 'CT2_EC07DB' )
   Declare @cNiv07Db  Char( 'CT2_EC07DB' )
   Declare @cNiv07CrA Char( 'CT2_EC07DB' )
   Declare @cNiv07Cr  Char( 'CT2_EC07DB' )
##ENDFIELDP03
##FIELDP04( 'CT2.CT2_EC08DB' )
   Declare @cNiv08DbA Char( 'CT2_EC08DB' )
   Declare @cNiv08Db  Char( 'CT2_EC08DB' )
   Declare @cNiv08CrA Char( 'CT2_EC08DB' )
   Declare @cNiv08Cr  Char( 'CT2_EC08DB' )
##ENDFIELDP04
##FIELDP05( 'CT2.CT2_EC09DB' )
   Declare @cNiv09DbA Char( 'CT2_EC09DB' )
   Declare @cNiv09Db  Char( 'CT2_EC09DB' )
   Declare @cNiv09CrA Char( 'CT2_EC09DB' )
   Declare @cNiv09Cr  Char( 'CT2_EC09DB' )
##ENDFIELDP05
##ENDIF_001

begin
   
   select @OUT_RESULT = '0'
   select @cResult = '0'
   select @cAux = 'CT2'
   select @iRecno   = 0,   @iRecnoA  = 0,   @nValor  = 0, @nValorA = 0
   select @cDelet   = ' ', @cDtLp    = ' '
   Select @cMoedaA  = ' ', @cMoeda   = ' ', @cTpSaldoA = ' ', @cTpSaldo = ' ', @cDc     = ' ', @cDcA    = ' ', @cLinhaA = ' ', @cLinha  = ' '
   Select @cDebitoA = ' ', @cCreditA = ' ', @cCustoDA  = ' ', @cCustoCA = ' ', @cItemDA = ' ', @cItemCA = ' ', @cClvlDA = ' ', @cClvlCA = ' '
   select @cDebito  = ' ', @cCredit  = ' ', @cCustoD   = ' ', @cCustoC  = ' ', @cItemD  = ' ', @cItemC  = ' ', @cClvlD  = ' ', @cClvlC  = ' '
   ##IF_002({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
      ##FIELDP06( 'CT2.CT2_EC05DB' )
         Select @cNiv05DbA = ' ' , @cNiv05Db = ' ', @cNiv05CrA = ' ' ,@cNiv05Cr = ' '
      ##ENDFIELDP06
      ##FIELDP07( 'CT2.CT2_EC06DB' )
         Select @cNiv06DbA = ' ', @cNiv06Db = ' ', @cNiv06CrA = ' ', @cNiv06Cr = ' '
      ##ENDFIELDP07
      ##FIELDP08( 'CT2.CT2_EC07DB' )
         Select @cNiv07DbA = ' ', @cNiv07Db = ' ', @cNiv07CrA = ' ', @cNiv07Cr = ' '
      ##ENDFIELDP08
      ##FIELDP09( 'CT2.CT2_EC08DB' )
         Select @cNiv08DbA = ' ', @cNiv08Db = ' ', @cNiv08CrA = ' ', @cNiv08Cr = ' '
      ##ENDFIELDP09
      ##FIELDP10( 'CT2.CT2_EC09DB' )
         Select @cNiv09DbA = ' ', @cNiv09Db = ' ', @cNiv09CrA = ' ', @cNiv09Cr = ' '
      ##ENDFIELDP10
   ##ENDIF_002
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT2 OutPut
   
   If @IN_OPERACAO = '3' begin
      /*---------------------------------------------------------------
        Ler CT2 com valores atualizados
        --------------------------------------------------------------- */
      select @cMoeda  = CT2_MOEDLC, @cLinha = CT2_LINHA, @cTpSaldo = CT2_TPSALD, @cDc     = CT2_DC,  @cDebito = CT2_DEBITO,
             @cCredit = CT2_CREDIT, @nValor = CT2_VALOR, @cCustoD  = CT2_CCD,    @cCustoC = CT2_CCC, @cItemD  = CT2_ITEMD,
             @cItemC  = CT2_ITEMC,  @cClvlD = CT2_CLVLDB,@cClvlC   = CT2_CLVLCR, @cDtLp   = CT2_DTLP
            ##IF_003({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
             ##FIELDP11( 'CT2.CT2_EC05DB' )
               , @cNiv05Db = CT2_EC05DB, @cNiv05Cr = CT2_EC05CR
             ##ENDFIELDP11
             ##FIELDP12( 'CT2.CT2_EC06DB' )
               , @cNiv06Db = CT2_EC06DB, @cNiv06Cr = CT2_EC06CR
             ##ENDFIELDP12
             ##FIELDP13( 'CT2.CT2_EC07DB' )
               , @cNiv07Db = CT2_EC07DB, @cNiv07Cr = CT2_EC07CR
             ##ENDFIELDP13
             ##FIELDP14( 'CT2.CT2_EC08DB' )
               , @cNiv08Db = CT2_EC08DB, @cNiv08Cr = CT2_EC08CR
             ##ENDFIELDP14
             ##FIELDP15( 'CT2.CT2_EC09DB' )
               , @cNiv09Db = CT2_EC09DB, @cNiv09Cr = CT2_EC09CR
             ##ENDFIELDP15
            ##ENDIF_003
        From CT2###
       Where CT2_FILIAL  = @cFilial_CT2
         and CT2_DATA    = @IN_DATA
         and CT2_LOTE    = @IN_LOTE
         and CT2_SBLOTE  = @IN_SBLOTE
         and CT2_DOC     = @IN_DOC
         and CT2_LINHA   = @IN_LINHA
         and CT2_MOEDLC  = @IN_MOEDA
         and D_E_L_E_T_  = ' '
      
      /*----------------------------------------------------------------------
        Faz a leitura do CT2 e atualiza os saldos
        ---------------------------------------------------------------------- */
      Select @cDcA     = @cDc,     @cDebitoA = @cDebito, @cCreditA  = @cCredit, @cCustoDA = @cCustoD,
             @cCustoCA = @cCustoC, @cItemDA  = @cItemD,  @cItemCA   = @cItemC,  @cClvlDA  = @cClvlD,
             @cClvlCA  = @cClvlC,  @nValorA  = @nValor,  @cTpSaldoA = @cTpSaldo
      
      exec CTB151_## @IN_FILIAL, @cDebitoA, @cDebito,     @cCreditA,  @cCredit, @cCustoDA,  @cCustoD,
                     @cCustoCA,  @cCustoC,  @cItemDA,     @cItemD,    @cItemCA, @cItemC,    @cClvlDA,
                     @cClvlD,    @cClvlCA,  @cClvlC,      @cMoeda,    @cDcA,    @cDc,       @IN_DATA,
                     @cTpSaldoA, @cTpSaldo, @IN_OPERACAO, @IN_MVSOMA, @IN_LOTE, @IN_SBLOTE, @IN_DOC,
                     @cDtLp,     @nValorA,  @nValor,      @cResult OutPut
      /*----------------------------------------------------------------------
        Atualizar os Cubos - INCLUSAO
        ---------------------------------------------------------------------- */
      ##IF_004({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
      ##FIELDP16( 'CT0.CT0_ID' )
      exec CTB156_## @cFilial_CT2, @cDebito, @cCredit, @cCustoD, @cCustoC, @cItemD,  @cItemC,  @cClvlD, @cClvlC
      ##ENDFIELDP16
                ##FIELDP17( 'CT2.CT2_EC05DB' )
                  , @cNiv05Db, @cNiv05Cr
                ##ENDFIELDP17
                ##FIELDP18( 'CT2.CT2_EC06DB' )
                  , @cNiv06Db, @cNiv06Cr
                ##ENDFIELDP18
                ##FIELDP19( 'CT2.CT2_EC07DB' )
                  , @cNiv07Db, @cNiv07Cr
                ##ENDFIELDP19
                ##FIELDP20( 'CT2.CT2_EC08DB' )
                  , @cNiv08Db, @cNiv08Cr
                ##ENDFIELDP20
                ##FIELDP21( 'CT2.CT2_EC09DB' )
                  , @cNiv09Db, @cNiv09Cr
                ##ENDFIELDP21
                ##FIELDP22( 'CT0.CT0_ID' )
                  ,@cMoeda, @cDc, @IN_DATA,  @cTpSaldo, @nValor, @cResult OutPut
                ##ENDFIELDP22
      ##ENDIF_004
   end
   
   If @IN_OPERACAO = '4' begin
   
      if (@IN_FLAG = '0') begin

         /*---------------------------------------------------------------
           Ler CT2 com valores atualizados
           --------------------------------------------------------------- */
         select @cMoeda  = CT2_MOEDLC, @cLinha = CT2_LINHA,  @cTpSaldo = CT2_TPSALD, @cDc     = CT2_DC,   @cDebito = CT2_DEBITO,
                @cCredit = CT2_CREDIT, @nValor = CT2_VALOR,  @cCustoD  = CT2_CCD,    @cCustoC = CT2_CCC,  @cItemD  = CT2_ITEMD,
                @cItemC  = CT2_ITEMC,  @cClvlD = CT2_CLVLDB, @cClvlC   = CT2_CLVLCR, @cDtLp   = CT2_DTLP, @cDelet  = D_E_L_E_T_,
                @iRecno  = R_E_C_N_O_
               ##IF_005({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                ##FIELDP23( 'CT2.CT2_EC05DB' )
                  , @cNiv05Db = CT2_EC05DB, @cNiv05Cr = CT2_EC05CR
                ##ENDFIELDP23
                ##FIELDP24( 'CT2.CT2_EC06DB' )
                  , @cNiv06Db = CT2_EC06DB, @cNiv06Cr = CT2_EC06CR
                ##ENDFIELDP24
                ##FIELDP25( 'CT2.CT2_EC07DB' )
                  , @cNiv07Db = CT2_EC07DB, @cNiv07Cr = CT2_EC07CR
                ##ENDFIELDP25
                ##FIELDP26( 'CT2.CT2_EC08DB' )
                  , @cNiv08Db = CT2_EC08DB, @cNiv08Cr = CT2_EC08CR
                ##ENDFIELDP26
                ##FIELDP27( 'CT2.CT2_EC09DB' )
                  , @cNiv09Db = CT2_EC09DB, @cNiv09Cr = CT2_EC09CR
                ##ENDFIELDP27
               ##ENDIF_005
           From CT2###
          Where CT2_FILIAL  = @cFilial_CT2
            and CT2_DATA    = @IN_DATA
            and CT2_LOTE    = @IN_LOTE
            and CT2_SBLOTE  = @IN_SBLOTE
            and CT2_DOC     = @IN_DOC
            and CT2_LINHA   = @IN_LINHA
            and CT2_MOEDLC  = @IN_MOEDA
            and D_E_L_E_T_  = ' '
         
         select @cOperacao = @IN_OPERACAO
         select @lExec = '1'
         
         /*---------------------------------------------------------------
           Carrega os dados anteriores a alteracao
           --------------------------------------------------------------- */
         Select @cMoedaA  = CT2_MOEDLC, @cTpSaldoA = CT2_TPSALD, @cDcA     = CT2_DC,     @cDebitoA = CT2_DEBITO,
                @cCreditA = CT2_CREDIT, @cCustoDA = CT2_CCD,     @cCustoCA = CT2_CCC,    @cItemDA  = CT2_ITEMD,
                @cItemCA  = CT2_ITEMC,  @cClvlDA  = CT2_CLVLDB,  @cClvlCA  = CT2_CLVLCR, @nValorA  = CT2_VALOR,
                @cLinhaA  = CT2_LINHA,  @iRecnoA  = IsNull(R_E_C_N_O_,0)
               ##IF_006({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                ##FIELDP28( 'CT2.CT2_EC05DB' )
                  , @cNiv05DbA = CT2_EC05DB, @cNiv05CrA = CT2_EC05CR
                ##ENDFIELDP28
                ##FIELDP29( 'CT2.CT2_EC06DB' )
                  , @cNiv06DbA = CT2_EC06DB, @cNiv06CrA = CT2_EC06CR
                ##ENDFIELDP29
                ##FIELDP30( 'CT2.CT2_EC07DB' )
                  , @cNiv07DbA = CT2_EC07DB, @cNiv07CrA = CT2_EC07CR
                ##ENDFIELDP30
                ##FIELDP31( 'CT2.CT2_EC08DB' )
                  , @cNiv08DbA = CT2_EC08DB, @cNiv08CrA = CT2_EC08CR
                ##ENDFIELDP31
                ##FIELDP32( 'CT2.CT2_EC09DB' )
                  , @cNiv09DbA = CT2_EC09DB, @cNiv09CrA = CT2_EC09CR
                ##ENDFIELDP32
               ##ENDIF_006
          From  TRW###
         Where R_E_C_N_O_ = @iRecno
         
         If @iRecnoA = @iRecno begin
            /*----------------------------------------------------------------------
                 Verifica se houve alguma alteracao na linha. Se nao houve, @lExec = '0'
              ---------------------------------------------------------------------- */
            If @cDcA      = @cDc      and @cDebitoA = @cDebito and @cCreditA = @cCredit and
               @cCustoDA  = @cCustoD  and @cCustoCA = @cCustoC and @cItemDA  = @cItemD  and @cItemCA  = @cItemC  and
               @cClvlDA   = @cClvlD   and @cClvlCA  = @cClvlC  and @nValorA  = @nValor  and @iRecnoA  = @iRecno  and
               @cTpSaldoA = @cTpSaldo and @cDelet = ' '
               ##IF_007({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                ##FIELDP33( 'CT2.CT2_EC05DB' )
                  and @cNiv05DbA = @cNiv05Db and @cNiv05CrA = @cNiv05Cr
                ##ENDFIELDP33
                ##FIELDP34( 'CT2.CT2_EC06DB' )
                  and @cNiv06DbA = @cNiv06Db and @cNiv06CrA = @cNiv06Cr
                ##ENDFIELDP34
                ##FIELDP35( 'CT2.CT2_EC07DB' )
                  and @cNiv07DbA = @cNiv07Db and @cNiv07CrA = @cNiv07Cr
                ##ENDFIELDP35
                ##FIELDP36( 'CT2.CT2_EC08DB' )
                  and @cNiv08DbA = @cNiv08Db and @cNiv08CrA = @cNiv08Cr
                ##ENDFIELDP36
                ##FIELDP37( 'CT2.CT2_EC09DB' )
                  and @cNiv09DbA = @cNiv09Db and @cNiv09CrA = @cNiv09Cr
                ##ENDFIELDP37
               ##ENDIF_007
            begin
               select @lExec = '0'
            End
         End
         
         If @lExec = '1' begin
            If ( @iRecno > @iRecnoA or @iRecnoA is null) begin
               Select @cDcA     = @cDc,     @cMoedaA  = @cMoeda,  @cDebitoA = @cDebito, @cCreditA = @cCredit,
                      @cCustoDA = @cCustoD, @cCustoCA = @cCustoC, @cItemDA  = @cItemD,  @cItemCA  = @cItemC,
                      @cClvlDA  = @cClvlD,  @cClvlCA  = @cClvlC,  @nValorA  = @nValor
               Select @cOperacao = '3'
               
               exec CTB151_## @IN_FILIAL, @cDebitoA, @cDebito,   @cCreditA,  @cCredit, @cCustoDA,  @cCustoD,
                              @cCustoCA,  @cCustoC,  @cItemDA,   @cItemD,    @cItemCA, @cItemC,    @cClvlDA,
                              @cClvlD,    @cClvlCA,  @cClvlC,    @cMoeda,    @cDcA,    @cDc,       @IN_DATA,
                              @cTpSaldoA, @cTpSaldo, @cOperacao, @IN_MVSOMA, @IN_LOTE, @IN_SBLOTE, @IN_DOC,
                              @cDtLp,     @nValorA,  @nValor,    @cResult OutPut
               /*----------------------------------------------------------------------
                 Atualizar os Cubos - INCLUSAO
                 ---------------------------------------------------------------------- */
               ##IF_008({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
               ##FIELDP38( 'CT0.CT0_ID' )
                  exec CTB156_## @cFilial_CT2, @cDebito, @cCredit, @cCustoD, @cCustoC, @cItemD,  @cItemC,  @cClvlD, @cClvlC
               ##ENDFIELDP38
                            ##FIELDP39( 'CT2.CT2_EC05DB' )
                              , @cNiv05Db, @cNiv05Cr
                            ##ENDFIELDP39
                            ##FIELDP40( 'CT2.CT2_EC06DB' )
                              , @cNiv06Db, @cNiv06Cr
                            ##ENDFIELDP40
                            ##FIELDP41( 'CT2.CT2_EC07DB' )
                              , @cNiv07Db, @cNiv07Cr
                            ##ENDFIELDP41
                            ##FIELDP42( 'CT2.CT2_EC08DB' )
                              , @cNiv08Db, @cNiv08Cr
                            ##ENDFIELDP42
                            ##FIELDP43( 'CT2.CT2_EC09DB' )
                              , @cNiv09Db, @cNiv09Cr
                            ##ENDFIELDP43
                            ##FIELDP44( 'CT0.CT0_ID' )
                                 ,@cMoeda, @cDc, @IN_DATA,  @cTpSaldo, @nValor, @cResult OutPut
                            ##ENDFIELDP44
               ##ENDIF_008
            end else begin
               If @iRecno = @iRecnoA begin
                  /*----------------------------------------------------------------------
                    algum dado alterado
                    ---------------------------------------------------------------------- */
                  Select @cOperacao = '4'
                  exec CTB151_## @IN_FILIAL, @cDebitoA, @cDebito,   @cCreditA,  @cCredit, @cCustoDA,  @cCustoD,
                                 @cCustoCA,  @cCustoC,  @cItemDA,   @cItemD,    @cItemCA, @cItemC,    @cClvlDA,
                                 @cClvlD,    @cClvlCA,  @cClvlC,    @cMoeda,    @cDcA,    @cDc,       @IN_DATA,
                                 @cTpSaldoA, @cTpSaldo, @cOperacao, @IN_MVSOMA, @IN_LOTE, @IN_SBLOTE, @IN_DOC,
                                 @cDtLp,     @nValorA,  @nValor,    @cResult OutPut
               /*----------------------------------------------------------------------
                 Excluir DADOS anteriores
                 ---------------------------------------------------------------------- */
               ##IF_009({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
               ##FIELDP45( 'CT0.CT0_ID' )
                  select @nValorA = @nValorA * (-1)
                  exec CTB156_## @cFilial_CT2, @cDebitoA, @cCreditA, @cCustoDA, @cCustoCA, @cItemDA,  @cItemCA,  @cClvlDA, @cClvlCA
               ##ENDFIELDP45
                         ##FIELDP46( 'CT2.CT2_EC05DB' )
                           , @cNiv05DbA, @cNiv05CrA
                         ##ENDFIELDP46
                         ##FIELDP47( 'CT2.CT2_EC06DB' )
                           , @cNiv06DbA, @cNiv06CrA
                         ##ENDFIELDP47
                         ##FIELDP48( 'CT2.CT2_EC07DB' )
                           , @cNiv07DbA, @cNiv07CrA
                         ##ENDFIELDP48
                         ##FIELDP49( 'CT2.CT2_EC08DB' )
                           , @cNiv08DbA, @cNiv08CrA
                         ##ENDFIELDP49
                         ##FIELDP50( 'CT2.CT2_EC09DB' )
                           , @cNiv09DbA, @cNiv09CrA
                         ##ENDFIELDP50
                         ##FIELDP51( 'CT0.CT0_ID' )
                         ,@cMoeda, @cDc, @IN_DATA,  @cTpSaldo, @nValorA, @cResult OutPut
                         ##ENDFIELDP51
               /*----------------------------------------------------------------------
                 INCLUIR DADOS 
                 ---------------------------------------------------------------------- */
               ##FIELDP52( 'CT0.CT0_ID' )
                  exec CTB156_## @cFilial_CT2, @cDebito, @cCredit, @cCustoD, @cCustoC, @cItemD,  @cItemC,  @cClvlD, @cClvlC
               ##ENDFIELDP52
                            ##FIELDP53( 'CT2.CT2_EC05DB' )
                              , @cNiv05Db, @cNiv05Cr
                            ##ENDFIELDP53
                            ##FIELDP54( 'CT2.CT2_EC06DB' )
                              , @cNiv06Db, @cNiv06Cr
                            ##ENDFIELDP54
                            ##FIELDP55( 'CT2.CT2_EC07DB' )
                              , @cNiv07Db, @cNiv07Cr
                            ##ENDFIELDP55
                            ##FIELDP56( 'CT2.CT2_EC08DB' )
                              , @cNiv08Db, @cNiv08Cr
                            ##ENDFIELDP56
                            ##FIELDP57( 'CT2.CT2_EC09DB' )
                              , @cNiv09Db, @cNiv09Cr
                            ##ENDFIELDP57
                            ##FIELDP58( 'CT0.CT0_ID' )
                            ,@cMoeda, @cDc, @IN_DATA,  @cTpSaldo, @nValor, @cResult OutPut
                            ##ENDFIELDP58
               ##ENDIF_009
               End
            End
         End
      end else begin
         
         Select @cMoedaA  = CT2_MOEDLC, @cTpSaldoA = CT2_TPSALD, @cDcA     = CT2_DC,     @cDebitoA = CT2_DEBITO,
                @cCreditA = CT2_CREDIT, @cCustoDA = CT2_CCD,     @cCustoCA = CT2_CCC,    @cItemDA  = CT2_ITEMD,
                @cItemCA  = CT2_ITEMC,  @cClvlDA  = CT2_CLVLDB,  @cClvlCA  = CT2_CLVLCR, @nValorA  = CT2_VALOR,
                @cLinhaA  = CT2_LINHA,  @iRecnoA  = IsNull(R_E_C_N_O_,0)
               ##IF_010({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                ##FIELDP76( 'CT2.CT2_EC05DB' )
                  , @cNiv05Db = CT2_EC05DB, @cNiv05Cr = CT2_EC05CR
                ##ENDFIELDP76
                ##FIELDP77( 'CT2.CT2_EC06DB' )
                  , @cNiv06Db = CT2_EC06DB, @cNiv06Cr = CT2_EC06CR
                ##ENDFIELDP77
                ##FIELDP78( 'CT2.CT2_EC07DB' )
                  , @cNiv07Db = CT2_EC07DB, @cNiv07Cr = CT2_EC07CR
                ##ENDFIELDP78
                ##FIELDP79( 'CT2.CT2_EC08DB' )
                  , @cNiv08Db = CT2_EC08DB, @cNiv08Cr = CT2_EC08CR
                ##ENDFIELDP79
                ##FIELDP80( 'CT2.CT2_EC09DB' )
                  , @cNiv09Db = CT2_EC09DB, @cNiv09Cr = CT2_EC09CR
                ##ENDFIELDP80
               ##ENDIF_010
          From  TRW###
          WHERE CT2_FILIAL  = @cFilial_CT2
            and CT2_DATA    = @IN_DATA
            and CT2_LOTE    = @IN_LOTE
            and CT2_SBLOTE  = @IN_SBLOTE
            and CT2_DOC     = @IN_DOC
            and CT2_LINHA   = @IN_LINHA
            and CT2_MOEDLC  = @IN_MOEDA
         
          /*---------------------------------------------------------------
           Os dados anteriores são os mesmos
           --------------------------------------------------------------- */
         Select @cMoeda  = @cMoedaA,  @cTpSaldo = @cTpSaldoA, @cDc     = @cDcA,     @cDebito  = @cDebitoA,
                @cCredit = @cCreditA, @cCustoD  = @cCustoDA,  @cCustoC = @cCustoCA, @cItemD   = @cItemDA,
                @cItemC  = @cItemCA,  @cClvlD   = @cClvlDA,   @cClvlC  = @cClvlCA,  @nValor   = @nValorA
            ##IF_011({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
             ##FIELDP81( 'CT2.CT2_EC05DB' )
               , @cNiv05DbA = @cNiv05Db, @cNiv05CrA = @cNiv05Cr
             ##ENDFIELDP81
             ##FIELDP82( 'CT2.CT2_EC06DB' )
               , @cNiv06DbA = @cNiv06Db, @cNiv06CrA = @cNiv06Cr
             ##ENDFIELDP82
             ##FIELDP83( 'CT2.CT2_EC07DB' )
               , @cNiv07DbA = @cNiv07Db, @cNiv07CrA = @cNiv07Cr
             ##ENDFIELDP83
             ##FIELDP84( 'CT2.CT2_EC08DB' )
               , @cNiv08DbA = @cNiv08Db, @cNiv08CrA = @cNiv08Cr
             ##ENDFIELDP84
             ##FIELDP85( 'CT2.CT2_EC09DB' )
               , @cNiv09DbA = @cNiv09Db, @cNiv09CrA = @cNiv09Cr
             ##ENDFIELDP85
            ##ENDIF_011
         Select @cOperacao = '5'
         exec CTB151_## @IN_FILIAL, @cDebitoA, @cDebito,   @cCreditA,  @cCredit, @cCustoDA,  @cCustoD,
                        @cCustoCA,  @cCustoC,  @cItemDA,   @cItemD,    @cItemCA, @cItemC,    @cClvlDA,
                        @cClvlD,    @cClvlCA,  @cClvlC,    @cMoeda,    @cDcA,    @cDc,       @IN_DATA,
                        @cTpSaldoA, @cTpSaldo, @cOperacao, @IN_MVSOMA, @IN_LOTE, @IN_SBLOTE, @IN_DOC,
                        @cDtLp,     @nValorA,  @nValor,    @cResult OutPut
         ##IF_012({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
         ##FIELDP86( 'CT0.CT0_ID' )
            select @nValor = @nValor *(-1)
            exec CTB156_## @cFilial_CT2, @cDebito, @cCredit, @cCustoD, @cCustoC, @cItemD,  @cItemC,  @cClvlD, @cClvlC
         ##ENDFIELDP86
                         ##FIELDP87( 'CT2.CT2_EC05DB' )
                           , @cNiv05Db, @cNiv05Cr
                         ##ENDFIELDP87
                         ##FIELDP88( 'CT2.CT2_EC06DB' )
                           , @cNiv06Db, @cNiv06Cr
                         ##ENDFIELDP88
                         ##FIELDP89( 'CT2.CT2_EC07DB' )
                           , @cNiv07Db, @cNiv07Cr
                         ##ENDFIELDP89
                         ##FIELDP90( 'CT2.CT2_EC08DB' )
                           , @cNiv08Db, @cNiv08Cr
                         ##ENDFIELDP90
                         ##FIELDP91( 'CT2.CT2_EC09DB' )
                           , @cNiv09Db, @cNiv09Cr
                         ##ENDFIELDP91
                         ##FIELDP92( 'CT0.CT0_ID' )
                           ,@cMoeda, @cDc, @IN_DATA,  @cTpSaldo, @nValor, @cResult OutPut
                         ##ENDFIELDP92
         ##ENDIF_012
         begin tran
			DELETE FROM TRW###
			WHERE CT2_FILIAL  = @cFilial_CT2
            and CT2_DATA    = @IN_DATA
            and CT2_LOTE    = @IN_LOTE
            and CT2_SBLOTE  = @IN_SBLOTE
            and CT2_DOC     = @IN_DOC
            and CT2_LINHA   = @IN_LINHA
            and CT2_MOEDLC  = @IN_MOEDA
         commit tran
      end
   end
   
   /*----------------------------------------------------------------------
     Se for exclusão
     ---------------------------------------------------------------------- */
   If @IN_OPERACAO = '5' begin
      select @cMoeda  = CT2_MOEDLC, @cTpSaldo = CT2_TPSALD, @cDc     = CT2_DC,     @cDebito = CT2_DEBITO,
             @cCredit = CT2_CREDIT, @nValor   = CT2_VALOR,  @cCustoD = CT2_CCD,    @cCustoC = CT2_CCC,
             @cItemD  = CT2_ITEMD,  @cItemC   = CT2_ITEMC,  @cClvlD  = CT2_CLVLDB, @cClvlC = CT2_CLVLCR,
             @cDtLp   = CT2_DTLP
            ##IF_013({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
             ##FIELDP59( 'CT2.CT2_EC05DB' )
               , @cNiv05Db = CT2_EC05DB, @cNiv05Cr = CT2_EC05CR
             ##ENDFIELDP59
             ##FIELDP60( 'CT2.CT2_EC06DB' )
               , @cNiv06Db = CT2_EC06DB, @cNiv06Cr = CT2_EC06CR
             ##ENDFIELDP60
             ##FIELDP61( 'CT2.CT2_EC07DB' )
               , @cNiv07Db = CT2_EC07DB, @cNiv07Cr = CT2_EC07CR
             ##ENDFIELDP61
             ##FIELDP62( 'CT2.CT2_EC08DB' )
               , @cNiv08Db = CT2_EC08DB, @cNiv08Cr = CT2_EC08CR
             ##ENDFIELDP62
             ##FIELDP63( 'CT2.CT2_EC09DB' )
               , @cNiv09Db = CT2_EC09DB, @cNiv09Cr = CT2_EC09CR
             ##ENDFIELDP63
            ##ENDIF_013
        From TRW###
       Where CT2_FILIAL  = @cFilial_CT2
         and CT2_DATA    = @IN_DATA
         and CT2_LOTE    = @IN_LOTE
         and CT2_SBLOTE  = @IN_SBLOTE
         and CT2_DOC     = @IN_DOC
         and CT2_LINHA   = @IN_LINHA
         and CT2_MOEDLC  = @IN_MOEDA
         and D_E_L_E_T_  = ' '
      
      /*---------------------------------------------------------------
        Os dados anteriores são os mesmos
        --------------------------------------------------------------- */
      Select @cMoedaA  = @cMoeda,  @cTpSaldoA = @cTpSaldo, @cDcA     = @cDc,     @cDebitoA  = @cDebito,
             @cCreditA = @cCredit, @cCustoDA  = @cCustoD,  @cCustoCA = @cCustoC, @cItemDA   = @cItemD,
             @cItemCA  = @cItemC,  @cClvlDA   = @cClvlD,   @cClvlCA  = @cClvlC,  @nValorA   = @nValor
            ##IF_014({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
             ##FIELDP64( 'CT2.CT2_EC05DB' )
               , @cNiv05DbA = @cNiv05Db, @cNiv05CrA = @cNiv05Cr
             ##ENDFIELDP64
             ##FIELDP65( 'CT2.CT2_EC06DB' )
               , @cNiv06DbA = @cNiv06Db, @cNiv06CrA = @cNiv06Cr
             ##ENDFIELDP65
             ##FIELDP66( 'CT2.CT2_EC07DB' )
               , @cNiv07DbA = @cNiv07Db, @cNiv07CrA = @cNiv07Cr
             ##ENDFIELDP66
             ##FIELDP67( 'CT2.CT2_EC08DB' )
               , @cNiv08DbA = @cNiv08Db, @cNiv08CrA = @cNiv08Cr
             ##ENDFIELDP67
             ##FIELDP68( 'CT2.CT2_EC09DB' )
               , @cNiv09DbA = @cNiv09Db, @cNiv09CrA = @cNiv09Cr
             ##ENDFIELDP68
            ##ENDIF_014
      /*----------------------------------------------------------------------
        ATUALIZAR OS CUBOS - EXCLUSAO
        ---------------------------------------------------------------------- */
      exec CTB151_## @IN_FILIAL, @cDebitoA, @cDebito,     @cCreditA,  @cCredit, @cCustoDA,  @cCustoD,
                     @cCustoCA,  @cCustoC,  @cItemDA,     @cItemD,    @cItemCA, @cItemC,    @cClvlDA,
                     @cClvlD,    @cClvlCA,  @cClvlC,      @cMoeda,    @cDcA,    @cDc,       @IN_DATA,
                     @cTpSaldoA, @cTpSaldo, @IN_OPERACAO, @IN_MVSOMA, @IN_LOTE, @IN_SBLOTE, @IN_DOC,
                     @cDtLp,     @nValorA,  @nValor,      @cResult OutPut
      ##IF_015({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
      ##FIELDP69( 'CT0.CT0_ID' )
         select @nValor = @nValor *(-1)
         exec CTB156_## @cFilial_CT2, @cDebito, @cCredit, @cCustoD, @cCustoC, @cItemD,  @cItemC,  @cClvlD, @cClvlC
      ##ENDFIELDP69
                         ##FIELDP70( 'CT2.CT2_EC05DB' )
                           , @cNiv05Db, @cNiv05Cr
                         ##ENDFIELDP70
                         ##FIELDP71( 'CT2.CT2_EC06DB' )
                           , @cNiv06Db, @cNiv06Cr
                         ##ENDFIELDP71
                         ##FIELDP72( 'CT2.CT2_EC07DB' )
                           , @cNiv07Db, @cNiv07Cr
                         ##ENDFIELDP72
                         ##FIELDP73( 'CT2.CT2_EC08DB' )
                           , @cNiv08Db, @cNiv08Cr
                         ##ENDFIELDP73
                         ##FIELDP74( 'CT2.CT2_EC09DB' )
                           , @cNiv09Db, @cNiv09Cr
                         ##ENDFIELDP74
                         ##FIELDP75( 'CT0.CT0_ID' )
                           ,@cMoeda, @cDc, @IN_DATA,  @cTpSaldo, @nValor, @cResult OutPut
                         ##ENDFIELDP75
      ##ENDIF_015
      begin tran
		DELETE FROM TRW###
		WHERE CT2_FILIAL  = @cFilial_CT2
         and CT2_DATA    = @IN_DATA
         and CT2_LOTE    = @IN_LOTE
         and CT2_SBLOTE  = @IN_SBLOTE
         and CT2_DOC     = @IN_DOC
         and CT2_LINHA   = @IN_LINHA
         and CT2_MOEDLC  = @IN_MOEDA
       commit tran
      
   End
   /*---------------------------------------------------------------
     Exclui as linhas da entidades com debito e credito zeros
     --------------------------------------------------------------- */ 
   Exec CTB164_## @IN_FILIAL, @IN_DATA, @cCredit, @cDebito, @cCustoC, @cCustoD, @cItemC, @cItemD,
                  @cClvlC, @cClvlD, @cTpSaldo, @IN_MOEDA, @IN_INTEGRIDADE, @cResult OutPut
   
   Exec CTB164_## @IN_FILIAL, @IN_DATA, @cCreditA, @cDebitoA, @cCustoCA, @cCustoDA, @cItemCA, @cItemDA,
                  @cClvlCA, @cClvlDA, @cTpSaldo, @IN_MOEDA, @IN_INTEGRIDADE, @cResult OutPut
   /*---------------------------------------------------------------
     Exclui os dados utilizados na alteracao/exclusao
     --------------------------------------------------------------- */   
   If @IN_OPERACAO = '4'  begin
      begin tran
		DELETE FROM TRW###
		WHERE CT2_FILIAL  = @cFilial_CT2
         and CT2_DATA    = @IN_DATA
         and CT2_LOTE    = @IN_LOTE
         and CT2_SBLOTE  = @IN_SBLOTE
         and CT2_DOC     = @IN_DOC
         and CT2_LINHA   = @IN_LINHA
         and CT2_MOEDLC  = @IN_MOEDA
       commit tran
      
   End
   select @OUT_RESULT = @cResult
   
End
