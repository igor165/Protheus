Create procedure CTB240_##
( 
   @IN_FILDE        Char( 'CT2_FILIAL' ),
   @IN_FILATE       Char( 'CT2_FILIAL' ),
   @IN_DATADE       Char( 08 ),
   @IN_DATAATE      Char( 08 ),
   @IN_LMOEDAESP    Char( 01 ),
   @IN_MOEDA        Char( 'CT7_MOEDA' ),
   @IN_TPSALDO      Char( 'CT2_TPSALD' ),
   @IN_MVSOMA       Char( 01 ),
   @IN_LCUSTO       Char( 01 ),
   @IN_LITEM        Char( 01 ),
   @IN_LCLVL        Char( 01 ),
   @IN_CONTADE      Char( 'CQ0_CONTA' ),
   @IN_CONTAATE     Char( 'CQ0_CONTA' ),
   @IN_INTEGRIDADE  Char( 01 ),
   @IN_MVCTB190D    Char( 01 ),
   @OUT_RESULTADO   Char( 01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Refaz saldos de documento  </d>
    Funcao do Siga  -      Ct190DOC() - Refaz saldos de documento não trata total informado
    Entrada         - <ri> @IN_FILDE        - Filial inicio
                           @IN_FILATE    - Filial final do processamento
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_MVSOMA       - Soma 2 vezes
                           @IN_LCUSTO       - '1' custo em uso
                           @IN_LITEM        - '1' Item em uso
                           @IN_LCLVL        - '1' clvl em uso
                           @IN_CONTADE      - Range Inicial da Conta a processar
                           @IN_CONTAATE     - Range final da Conta a processar
                           @IN_INTEGRIDADE  - Integridade ligada '1'
                           @IN_MVCTB190D    - Exclui fisicamente '1' </ri>
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     31/03/2014

    CTB240 - Atualiza CTC documentos e CQ8/CQ9 ( a partir dos CQ0 a CQ6 )
      +--> CTB241 - Zera Saldos CTC, CQ8, CQ9
      +--> CTB023 - Atualiza CTC
      +--> CTB242 - Atualiza CQ8, CQ9   
      
   Obs: esta procedure CTB240, faz as atualizações dos documentos e dos CQ8/CQ9  ests não podem
      ser atualizadas em threads. E chamada após a execução CTB165
  -------------------------------------------------------------------------------------- */
declare @cResult Char( 01 )
declare @cAlias  Char( 03 )
declare @cDataI  Char( 08 )
declare @cDataF  Char( 08 )
Declare @cIdent  Char( 03 )

begin
   
   select @OUT_RESULTADO = '0'
   select @cResult = '0'
   select @cDataI  = SUBSTRING( @IN_DATADE, 1, 6)||'01'
   Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
   /* ---------------------------------------------------------------
         exclui documentos
      --------------------------------------------------------------- */
   select @cAlias = 'CTC'
   SELECT @cIdent = ' '
   EXEC CTB241_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILDE, @IN_FILATE, @cDataI, @cDataF,
                  @IN_INTEGRIDADE, @IN_MVCTB190D, @cIdent, @cResult Output
   /* ---------------------------------------------------------------
      Exclui CQ8 Entidades Mensal - CTT -CTD -CTH
      --------------------------------------------------------------- */
   select @cAlias  = 'CQ8'
   If @IN_LCUSTO  = '1' begin
      select @cIdent = 'CTT'
      EXEC CTB241_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILDE, @IN_FILATE, @cDataI, @cDataF,
                     @IN_INTEGRIDADE, @IN_MVCTB190D, @cIdent, @cResult Output
   End
   If @IN_LITEM = '1' begin
      select @cIdent = 'CTD'
      EXEC CTB241_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILDE, @IN_FILATE, @cDataI, @cDataF,
                     @IN_INTEGRIDADE, @IN_MVCTB190D, @cIdent, @cResult Output
   End
   If @IN_LCLVL = '1' begin
      select @cIdent = 'CTH'
      EXEC CTB241_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILDE, @IN_FILATE, @cDataI, @cDataF,
                     @IN_INTEGRIDADE, @IN_MVCTB190D, @cIdent, @cResult Output
   End
   /* ---------------------------------------------------------------
      Exclui CQ9 Entidades Diario - CTT -CTD -CTH
      --------------------------------------------------------------- */
   select @cAlias = 'CQ9'
   If @IN_LCUSTO = '1' begin
      select @cIdent = 'CTT'
      EXEC CTB241_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILDE, @IN_FILATE, @cDataI, @cDataF,
                  @IN_INTEGRIDADE, @IN_MVCTB190D, @cIdent, @cResult Output
   End
   If @IN_LITEM = '1' begin
      select @cIdent = 'CTD'
      EXEC CTB241_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILDE, @IN_FILATE, @cDataI, @cDataF,
                     @IN_INTEGRIDADE, @IN_MVCTB190D, @cIdent, @cResult Output
   End
   If @IN_LCLVL = '1' begin
      select @cIdent = 'CTH'
      EXEC CTB241_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILDE, @IN_FILATE, @cDataI, @cDataF,
                     @IN_INTEGRIDADE, @IN_MVCTB190D, @cIdent, @cResult Output
   end
   /* ---------------------------------------------------------------
         atualiza DOCUMENTOS 
      --------------------------------------------------------------- */
   Exec CTB023_##  @IN_FILDE, @IN_FILATE, @cDataI, @cDataF, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO,@IN_MVSOMA, @cResult OutPut
   /* ---------------------------------------------------------------
         ATUALIZA CQ8/CQ9
      --------------------------------------------------------------- */
   EXEC CTB242_## @IN_FILDE,  @IN_FILATE, @cDataI,   @cDataF,     @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_MVSOMA, 
                  @IN_LCUSTO, @IN_LITEM,  @IN_LCLVL, @IN_CONTADE, @IN_CONTAATE,  @cResult Output
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
   --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end
