Create procedure CTB024_##
( 
   @IN_FILIALCOR    Char('CT2_FILIAL'),
   @IN_FILIALATE    Char('CT2_FILIAL'),
   @IN_DATADE       Char(08),
   @IN_DATAATE      Char(08),
   @IN_LMOEDAESP    Char(01),
   @IN_MOEDA        Char('CQ0_MOEDA'),
   @IN_TPSALDO      Char('CT2_TPSALD'),
   @IN_EMPANT       Char(02),
   @IN_FILANT       Char('CT2_FILIAL'), 
   @OUT_RESULTADO   Char(01) OutPut
 )
as

/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Atualiza os Flags de Conta Ponte </d>
    Funcao do Siga  -      CtbFlgPon() - Atualiza os Flags de Conta Ponte
    Entrada         - <ri> @IN_FILIALCOR    - Filial Corrente
                           @IN_FILIALATE    - Filial final do processamento
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     18/11/2003
-------------------------------------------------------------------------------------- */
declare @cFilial_CTZ  char('CTZ_FILIAL')
declare @cFilial_CQ0  char('CQ0_FILIAL')
declare @cFilial_CQ1  char('CQ1_FILIAL')
declare @cFilial_CQ2  char('CQ2_FILIAL')
declare @cFilial_CQ3  char('CQ3_FILIAL')
declare @cFilial_CQ4  char('CQ4_FILIAL')
declare @cFilial_CQ5  char('CQ5_FILIAL')
declare @cFilial_CQ6  char('CQ6_FILIAL')
declare @cFilial_CQ7  char('CQ7_FILIAL')
declare @cFilial_CQ8  char('CQ8_FILIAL')
declare @cFilial_CQ9  char('CQ9_FILIAL')
declare @cFILCTZ      char('CTZ_FILIAL')
declare @cAux         char(03)
declare @cAux1        char(01)
Declare @cCTZ_DATA    Char(08)
Declare @cDataI       Char(08)
Declare @cDataF       Char(08)
Declare @cCTZ_MOEDLC  Char('CTZ_MOEDLC')
Declare @cCTZ_CONTA   Char('CTZ_CONTA')
Declare @cCTZ_CUSTO   Char('CTZ_CUSTO')
Declare @cCTZ_ITEM    Char('CTZ_ITEM')
Declare @cCTZ_CLVL    Char('CTZ_CLVL')

begin
   
   select @OUT_RESULTADO = '0'
   
   If @IN_FILIALCOR = ' ' select @cFilial_CTZ = ' '
   else select @cFilial_CTZ = @IN_FILIALCOR
   
   select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
   Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
   
   Declare CUR_CT190FLGLP insensitive cursor for
      Select CTZ_FILIAL, CTZ_DATA, CTZ_MOEDLC, CTZ_CONTA, CTZ_CUSTO, CTZ_ITEM, CTZ_CLVL
        From CTZ###
       Where CTZ_FILIAL between @cFilial_CTZ and @IN_FILIALATE
         and CTZ_DATA   between @cDataI      and @cDataF
         and CTZ_TPSALD   = @IN_TPSALDO
         and ((CTZ_MOEDLC = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0')
         and D_E_L_E_T_ = ' '
    Group by CTZ_FILIAL, CTZ_DATA, CTZ_MOEDLC, CTZ_CLVL, CTZ_ITEM, CTZ_CUSTO, CTZ_CONTA
    ORDER BY CTZ_FILIAL, CTZ_DATA, CTZ_MOEDLC, CTZ_CLVL, CTZ_ITEM, CTZ_CUSTO, CTZ_CONTA
   for read only
   open CUR_CT190FLGLP
   Fetch CUR_CT190FLGLP Into @cFILCTZ, @cCTZ_DATA, @cCTZ_MOEDLC, @cCTZ_CONTA, @cCTZ_CUSTO, @cCTZ_ITEM, @cCTZ_CLVL
   
   While (@@fetch_status = 0) begin
      Select @cAux1 = ' '
      select @cAux = 'CQ0'
      exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ0 OutPut
      
      EXEC CTB025_## @cFilial_CQ0, @cAux,      @cAux1,     @cCTZ_CONTA,  @cAux1,
                     @cAux1,       @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                     @IN_EMPANT,   @IN_FILANT, @OUT_RESULTADO OutPut

      select @cAux = 'CQ1'
      exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ1 OutPut
      
      EXEC CTB025_## @cFilial_CQ1,  @cAux,      @cAux1,     @cCTZ_CONTA,  @cAux1,
                     @cAux1,        @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                     @IN_EMPANT,    @IN_FILANT, @OUT_RESULTADO OutPut
      
      if @cCTZ_CUSTO != ' ' begin
         select @cAux = 'CQ2'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ2 OutPut
         
         EXEC CTB025_## @cFilial_CQ2, @cAux,      @cAux1,     @cCTZ_CONTA,  @cCTZ_CUSTO,
                        @cAux1,       @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILANT, @OUT_RESULTADO OutPut
         
         Select @cAux = 'CQ3'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ3 OutPut
         EXEC CTB025_## @cFilial_CQ3, @cAux,      @cAux1,     @cCTZ_CONTA,  @cCTZ_CUSTO,
                        @cAux1,       @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILANT, @OUT_RESULTADO OutPut
                        
         select @cAux = 'CQ8'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ8 OutPut         
         EXEC CTB025_## @cFilial_CQ8, @cAux,      'CTT',      @cAux1,       @cCTZ_CUSTO,
                        @cAux1,       @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILANT, @OUT_RESULTADO OutPut
         select @cAux = 'CQ9'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ9 OutPut
         EXEC CTB025_## @cFilial_CQ9, @cAux,      'CTT',      @cAux1,       @cCTZ_CUSTO,
                        @cAux1,       @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILANT, @OUT_RESULTADO OutPut
      end
      
      if @cCTZ_ITEM != ' ' begin
         select @cAux = 'CQ4'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ4 OutPut
         
         EXEC CTB025_## @cFilial_CQ4, @cAux,      @cAux1,     @cCTZ_CONTA,  @cCTZ_CUSTO,
                        @cCTZ_ITEM,   @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILANT, @OUT_RESULTADO OutPut
         
         select @cAux = 'CQ5'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ5 OutPut
         EXEC CTB025_## @cFilial_CQ5, @cAux,      @cAux1,     @cCTZ_CONTA,  @cCTZ_CUSTO,
                        @cCTZ_ITEM,   @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILANT, @OUT_RESULTADO OutPut
                        
         select @cAux = 'CQ8'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ8 OutPut         
         EXEC CTB025_## @cFilial_CQ8, @cAux,      'CTD',      @cAux1,       @cAux1,
                        @cCTZ_ITEM,   @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILANT, @OUT_RESULTADO OutPut
         select @cAux = 'CQ9'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ9 OutPut
         EXEC CTB025_## @cFilial_CQ9, @cAux,      'CTD',      @cAux1,       @cAux1,
                        @cCTZ_ITEM,   @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILANT, @OUT_RESULTADO OutPut
      end      
      if @cCTZ_CLVL != ' ' begin
         select @cAux = 'CQ6'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ6 OutPut
         
         EXEC CTB025_## @cFilial_CQ6, @cAux,      @cAux1,     @cCTZ_CONTA,  @cCTZ_CUSTO,
                        @cCTZ_ITEM,   @cCTZ_CLVL, @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILANT, @OUT_RESULTADO OutPut
         
         select @cAux = 'CQ7'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ7 OutPut
         EXEC CTB025_## @cFilial_CQ7, @cAux,      @cAux1,     @cCTZ_CONTA,  @cCTZ_CUSTO,
                        @cCTZ_ITEM,   @cCTZ_CLVL, @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILANT, @OUT_RESULTADO OutPut

         select @cAux = 'CQ8'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ8 OutPut         
         EXEC CTB025_## @cFilial_CQ8, @cAux,      'CTH',      @cAux1,       @cAux1,
                        @cAux1,       @cCTZ_CLVL, @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILANT, @OUT_RESULTADO OutPut
         select @cAux = 'CQ9'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ9 OutPut
         EXEC CTB025_## @cFilial_CQ9, @cAux,      'CTH',      @cAux1,       @cAux1,
                        @cAux1,       @cCTZ_CLVL, @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILANT, @OUT_RESULTADO OutPut
      end
      
      Fetch CUR_CT190FLGLP Into @cFILCTZ, @cCTZ_DATA, @cCTZ_MOEDLC, @cCTZ_CONTA, @cCTZ_CUSTO, @cCTZ_ITEM, @cCTZ_CLVL
   End
   Close CUR_CT190FLGLP
   Deallocate CUR_CT190FLGLP
   
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
   --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end
