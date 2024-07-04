Create procedure CTB165_##
(  
   @IN_LCUSTO       Char( 01 ),
   @IN_LITEM        Char( 01 ),
   @IN_LCLVL        Char( 01 ),
   @IN_FILIAL       Char( 'CT7_FILIAL' ),
   @IN_DATADE       Char( 08 ),
   @IN_DATAATE      Char( 08 ),
   @IN_LMOEDAESP    Char( 01 ),
   @IN_MOEDA        Char( 'CT7_MOEDA' ),
   @IN_TPSALDO      Char( 'CT2_TPSALD' ),
   @IN_INTEGRIDADE  Char( 01 ),
   @IN_MVCTB190D    Char( 01 ),
   @IN_CONTA        Char( 'CT1_CONTA' ),
   @IN_MVSOMA       Char( 01 ),
   @IN_EMPANT       Char(02),
   @OUT_RESULTADO   Char( 01 ) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  010 </a>
    Fonte Microsiga - <s>  CTBA192.PRW </s>
    Descricao       - <d>  Reprocessamento Contábil </d>
    Funcao do Siga  -      CTB192Proc()
    Entrada         - <ri> @IN_LCUSTO       - Centro de Custo em uso
                           @IN_LITEM        - Item em uso
                           @IN_LCLVL        - Classe de Valor em uso
                           @IN_FILIAL       - Filial do processamento
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada.
                           @IN_MVCTB190D    - '1' exclui fisicamente, '0' marca como deletado
                           @IN_CONTA        - Conta a reprocessar
                           @IN_EMPANT       - Grupo de Emp atual
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     03/11/2003
    
    CTB165 - Reprecessamento Contábil por conta
      +--> CTB166 - Zera Saldos
      +--> CTB167 - Ct190SlBse  - Atualizar Saldos base - CTI, CT4, CT3,CT7
      |        +--> CTB166 - Zera Saldos CQ8 , CQ9
      |        +--> CTB025  - Ct190FlgLP - Atualiza slds referentes a Apur de LP
      |        +--> CTB231  - CaTUALIZA ITEM E CLVL
      +--> CTB168 - CtbFlgPon()  - Atualiza os Flags de Conta Ponte
      |        +--> CTB025  - Ct190FlgLP() - Atualiza os flags dos saldos ref. lucros/perdas
Obs : CTB240 - ATUALIZA DOCUMENTOS
-------------------------------------------------------------------------------------- */
declare @cAlias char(03)
declare @cDataI char(08)
declare @cDataF char(08)
Declare @cIdent Char( 03 )
Declare @cAux   Char(02)

begin
  
   select @OUT_RESULTADO = '0'
   select @cAux = ' '
   /* -------------------------------------------------------------------------
      Data Inicial, primeiro dia do Mes e final, Ultimo dia do mes 
      -------------------------------------------------------------------------*/    
   select @cDataI = SUBSTRING(@IN_DATADE,1,6)||'01'
   Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
   /* -------------------------------------------------------------------------
      Zera CQ0 Contas Mes - CQ1 Dia
      -------------------------------------------------------------------------*/
   select @cIdent = ' '
   select @cAlias    = 'CQ0'
   EXEC CTB166_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIAL, @cDataI, @cDataF,
                  @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_CONTA, @cIdent, @cAux, @OUT_RESULTADO Output 
   /* -------------------------------------------------------------------------
      Zera CQ1 Contas DIA
      -------------------------------------------------------------------------*/    
   select @cAlias    = 'CQ1'
   EXEC CTB166_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIAL, @cDataI, @cDataF,
                  @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_CONTA, @cIdent, @cAux, @OUT_RESULTADO Output 
   /* -------------------------------------------------------------------------
      Zera CQ2 CCusto Mes - CQ3 Dia
      -------------------------------------------------------------------------*/    
   if @IN_LCUSTO = '1' begin
      select @OUT_RESULTADO = '0'
      select @cAlias    = 'CQ2'
      EXEC CTB166_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIAL, @cDataI, @cDataF,
                     @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_CONTA, @cIdent, @cAux, @OUT_RESULTADO Output 
      
      select @OUT_RESULTADO = '0'
      select @cAlias    = 'CQ3'
      EXEC CTB166_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIAL, @cDataI, @cDataF,
                     @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_CONTA, @cIdent, @cAux, @OUT_RESULTADO Output
   end
   /* -------------------------------------------------------------------------
      Zera CQ4 Item Mes - CQ5 dia
      -------------------------------------------------------------------------*/    
   if @IN_LITEM  = '1' begin
      select @OUT_RESULTADO = '0'
      select @cAlias    = 'CQ4'
      EXEC CTB166_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIAL, @cDataI, @cDataF,
                     @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_CONTA, @cIdent, @cAux, @OUT_RESULTADO Output
                     
      select @OUT_RESULTADO = '0'
      select @cAlias    = 'CQ5'
      EXEC CTB166_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIAL, @cDataI, @cDataF,
                     @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_CONTA, @cIdent, @cAux, @OUT_RESULTADO Output 
   end
   /* -------------------------------------------------------------------------
      Zera CQ6 CLVL Mes - CQ7 dia
      -------------------------------------------------------------------------*/    
   if @IN_LCLVL  = '1' begin
      select @OUT_RESULTADO = '0'
      select @cAlias    = 'CQ6'
      EXEC CTB166_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIAL, @cDataI, @cDataF,
                     @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_CONTA, @cIdent, @cAux, @OUT_RESULTADO Output 
      
      select @OUT_RESULTADO = '0'
      select @cAlias    = 'CQ7'
      EXEC CTB166_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIAL, @cDataI, @cDataF,
                     @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_CONTA, @cIdent, @cAux, @OUT_RESULTADO Output 
   end
   /* ----------------------------------------------------------------------------------------------
      CTB167 - Ct190SlBse - Atualizar Saldos base - CQ0, CQ1, CQ2, CQ3, CQ4, CQ5, CQ6, CQ7, CQ8, CA9
      ---------------------------------------------------------------------------------------------- */
   select @OUT_RESULTADO = '0'
   EXEC CTB167_## @IN_FILIAL,    @IN_LCUSTO, @IN_LITEM,   @IN_LCLVL, @cDataI, @cDataF, @IN_LMOEDAESP, @IN_MOEDA,  @IN_TPSALDO, @IN_CONTA,
              @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_EMPANT,@OUT_RESULTADO Output
   /* -------------------------------------------------------------------------
      CTB168 - CtbFlgPon() - Atualiza os Flags de Conta Ponte
      -------------------------------------------------------------------------*/
   select @OUT_RESULTADO = '0'  -- CHAMA CTB025
   EXEC CTB168_## @IN_FILIAL, @cDataI,  @cDataF, @IN_LMOEDAESP,
                  @IN_MOEDA,  @IN_TPSALDO, @IN_CONTA, @IN_EMPANT, @OUT_RESULTADO  OutPut
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
   --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end
