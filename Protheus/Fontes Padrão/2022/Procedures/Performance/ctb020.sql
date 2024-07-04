Create procedure CTB020_##
( 
   @IN_LCUSTO       Char(01),
   @IN_LITEM        Char(01),
   @IN_LCLVL        Char(01),
   @IN_FILIALDE     Char('CT2_FILIAL'),
   @IN_FILIALATE    Char('CT2_FILIAL'),
   @IN_DATADE       Char(08),
   @IN_DATAATE      Char(08),
   @IN_LMOEDAESP    Char(01),
   @IN_MOEDA        Char('CT7_MOEDA'),
   @IN_TPSALDO      Char('CT2_TPSALD'),
   @IN_MVSOMA       Char(01),
   @IN_REPROC       Char(01),
   @IN_INTEGRIDADE  Char(01),
   @IN_MVCTB190D    Char(01),
   @IN_EMPANT       Char(02),
   @IN_FILANT       Char('CT2_FILIAL'), 
   @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  012 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Descricao       - <d>  Reprocessamento Contábil </d>
    Funcao do Siga  -      CTB190Proc()
    Entrada         - <ri> @IN_LCUSTO       - Centro de Custo em uso
                           @IN_LITEM        - Item em uso
                           @IN_LCLVL        - Classe de Valor em uso
                           @IN_FILIALDE     - Filial inicio do processamento
                           @IN_FILIALATE    - Filial final do processamento
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_MVSOMA       - Soma 2 vezes
                           @IN_REPROC       - Se Reproc -> '1'
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada.
                           @IN_MVCTB190D    - '1' exclui fisicamente, '0' marca como deletado</ri>
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice	</r>
    Data        :     03/11/2003
    
    CTB020 - Reprecessamento Contábil
      +--> CTB002 - Zera Saldos
      +--> CTB021 - Ct190SlBse  - Atualizar Saldos base - CQ0, CQ1, CQ2, CQ3
               +--> CTB230  - Atualizar Saldos base - - CQ4, CQ5, CQ6, CQ7
               +--> CTB232  - Atualizar Saldos base - CQ8, CQ9
      |        +--> CTB025  - Ct190FlgLP - Atualiza slds referentes a Apur de LP
      +--> CTB023 - Ct190Doc()  - Totais por Doc
         EXCLUIDO     +--> CTB024 - CtbFlgPon() - Atualiza os Flags de Conta Ponte. Não atualiza valores, somete grava Flags
         EXCLUIDO      |        |                  das AP LP com conta Ponte (CTZ - Lançamentos apurados com conta ponte  )
      |        +--> CTB025  - Ct190FlgLP() - Atualiza os flags dos saldos ref. lucros/perdas
      +-------------------------------------------------------------------------------
      | Localización COL/PER
      +--> CTB002A - Zera Saldos - QL6, QL7
      +--> CTB021A - Ct190SlBse  - Atualizar Saldos base - QL6, QL7
      |     +--> CTB025A  - Ct190FlgLP - Atualiza slds referentes a Apur de LP - QL7
      |     +--> CTB232A  - Atualizar Saldos base - CQ8, CQ9
      +-------------------------------------------------------------------------------
      +--> CTB220 - - Atualiza os CUBBOS
      |        +--> CTB209 - Apaga os dados do CVXe CVY no periodo solicitado
      |        +--> LASTDAY - Retorna o ultimo dia do mes
      |        +--> CTB211 - Chama Gravacao dos Cubos
      |                 +--> CTB210 - Chamada das Atualizacao de Cubos
      |                          +--> CTB200 - Atualizar Cubo01 - CONTA
      |                          +--> CTB201 - Atualizar Cubo02 - CCUSTO
      |                          +--> CTB202 - Atualizar Cubo03 - ITEM
      |                          +--> CTB203 - Atualizar Cubo04 - CLVL
      |                          +--> CTB204 - Atualizar Cubo05 - NIV05
      |                          +--> CTB205 - Atualizar Cubo06 - NIV06
      |                          +--> CTB206 - Atualizar Cubo07 - NIV07
      |                          +--> CTB207 - Atualizar Cubo08 - NIV08
      |                          +--> CTB208 - Atualizar Cubo09 - NIV09
-------------------------------------------------------------------------------------- */
declare @cFilial_CT2 char('CT2_FILIAL')

declare @cAux2       char(01)
declare @cAux        char(03)
declare @dDataIni    char(08)
declare @dDataFim    char(08)
declare @cAlias      char(03)

begin
   
   select @OUT_RESULTADO = '0'
   
   select @cAux = 'CT2'
   exec XFILIAL_## @cAux, @IN_FILIALDE, @cFilial_CT2 OutPut
          
   Select @dDataIni = Isnull( Min( CT2_DATA ), '0' ), @dDataFim = Isnull( Max( CT2_DATA ), '1' )
     from CT2###
    where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE
      and D_E_L_E_T_ = ' '
   if ( ( @dDataIni = '0' ) and ( @dDataFim = '1' ) ) begin
      /* ------------------------------------------------------------
         Nao tem dados a reprocessar
         ------------------------------------------------------------*/
      select @OUT_RESULTADO = '1'
   end
   else begin
      select @dDataIni = @IN_DATADE
      select @dDataFim = @IN_DATAATE
      /* -------------------------------------------------------------------------
         Zera/Exclui Saldos de Contas - CQ0 Mês / CQ1 Dia
         -------------------------------------------------------------------------*/    
      select @cAlias    = 'CQ0'
      select @cAux2     = '0'
      EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output 
      select @cAlias    = 'CQ1'
      EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output 
      
      select @cAlias    = 'CQA'
      EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output 
        
      /* -------------------------------------------------------------------------
         Zera/Exclui Saldos de CCustos - CQ2 Mês / CQ3 Dia
         -------------------------------------------------------------------------*/    
      if @IN_LCUSTO = '1' begin
         select @OUT_RESULTADO = '0'
         select @cAlias    = 'CQ2'
         select @cAux2     = '0'
         EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output 
         select @cAlias    = 'CQ3'
         EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output 
      end
      /* -------------------------------------------------------------------------
         Zera/Exclui Saldos de Item - CQ4 Mês / CQ5 Dia
         -------------------------------------------------------------------------*/    
      if @IN_LITEM  = '1' begin
         select @OUT_RESULTADO = '0'
         select @cAlias    = 'CQ4'
         select @cAux2     = '0'
         EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output 
         select @cAlias    = 'CQ5'
         EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output 
      end
      /* -------------------------------------------------------------------------
         Zera/Exclui Saldos de Classe de Valor - CQ6 Mês / CQ7 Dia
         -------------------------------------------------------------------------*/    
      if @IN_LCLVL  = '1' begin
         select @OUT_RESULTADO = '0'
         select @cAlias    = 'CQ6'
         select @cAux2     = '0'
         EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output 
         select @cAlias    = 'CQ7'
         EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output       
      end
      /* -------------------------------------------------------------------------
         Zera/Exclui Saldos por entidade - CQ8 Mês / CQ9 Dia
         -------------------------------------------------------------------------*/    
      if @IN_LCUSTO  = '1' or  @IN_LITEM  = '1' or @IN_LCLVL  = '1' begin
         select @OUT_RESULTADO = '0'
         select @cAlias    = 'CQ8'
         select @cAux2     = '0'
         EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output 
         select @cAlias    = 'CQ9'
         EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output       
      end
      /* -------------------------------------------------------------------------
         Zera/Exclui Saldos de Contas - CTC - Documento
         -------------------------------------------------------------------------*/
      select @OUT_RESULTADO = '0'
      select @cAlias    = 'CTC'
      select @cAux2     = '0'
      EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output 
      /* -----------------------------------------------------------------------------------
         CTB021 - Ct190SlBse - Atualizar Saldos base - CQ0/CQ1 - CQ2/CQ3 - CQ4/CQ5 - CQ6/CQ7
         ----------------------------------------------------------------------------------- */
      select @OUT_RESULTADO = '0'
      EXEC CTB021_## @IN_FILIALDE,  @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @IN_FILIALATE,  @dDataIni, @dDataFim,  @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @OUT_RESULTADO Output
      /* -------------------------------------------------------------------------
         Ct190Doc() - Totais por Doc
         -------------------------------------------------------------------------*/
      select @OUT_RESULTADO = '0'
      EXEC CTB023_## @IN_FILIALDE,  @IN_FILIALATE, @IN_DATADE, @IN_DATAATE, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_MVSOMA, @OUT_RESULTADO OutPut

      /* -------------------------------------------------------------------------
         Países Colombia y Perú
         -------------------------------------------------------------------------*/
      ##IF_002({|| cPaisLoc $ 'COL|PER' .And. CtbMovSaldo('CT0',,'05') })
      ##FIELDP02( 'QL6.QL6_FILIAL' )
         /* -------------------------------------------------------------------------
            Zera/Exclui Saldos de Entidad 05 - QL6 Mês / QL7 Dia
            -------------------------------------------------------------------------*/
         select @OUT_RESULTADO = '0'
         select @cAlias    = 'QL6'
         select @cAux2     = '0'
         EXEC CTB002A_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output
         select @cAlias    = 'QL7'
         EXEC CTB002A_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output
         /* -------------------------------------------------------------------------
            Zera/Exclui Saldos por entidade - CQ8 Mês / CQ9 Dia. Si maneja otras entidades, ya borró saldos, no repetir operación
            -------------------------------------------------------------------------*/
         if @IN_LCUSTO  = '0' and  @IN_LITEM  = '0' and @IN_LCLVL  = '0' begin
            select @OUT_RESULTADO = '0'
            select @cAlias    = 'CQ8'
            select @cAux2     = '0'
            EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output
            select @cAlias    = 'CQ9'
            EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @OUT_RESULTADO Output
         end
         /* -----------------------------------------------------------------------------------
            CTB021A - Ct190SlBse - Atualizar Saldos base - QL6/QL7
            ----------------------------------------------------------------------------------- */
         select @OUT_RESULTADO = '0'
         EXEC CTB021A_## @IN_FILIALDE,  @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @IN_FILIALATE, @dDataIni, @dDataFim, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @OUT_RESULTADO Output
      ##ENDFIELDP02
      ##ENDIF_002
      /* -------------------------------------------------------------------------
         CTB024 -CtbFlgPon() - Atualiza os Flags de Conta Ponte
         ------------------------S-------------------------------------------------*/
  /*    select @OUT_RESULTADO = '0'  -- CHAMA CTB025
      EXEC CTB024_## @IN_FILIALDE,  @IN_FILIALATE, @IN_DATADE, @IN_DATAATE, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @OUT_RESULTADO  OutPut
      select @OUT_RESULTADO = '0'*/
      /* -------------------------------------------------------------------------
         ATUALIZA CUBOS
         -------------------------------------------------------------------------*/
      ##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
      ##FIELDP01( 'CT0.CT0_ID' )
       Exec CTB220_## @IN_FILIALDE, @IN_FILIALATE, @IN_DATADE, @IN_DATAATE, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @OUT_RESULTADO OutPut
      ##ENDFIELDP01
      ##ENDIF_001
   end
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
   --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end
