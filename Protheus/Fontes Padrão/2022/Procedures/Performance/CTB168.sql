Create procedure CTB168_##
( 
   @IN_FILIAL       Char( 'CQ0_FILIAL' ),
   @IN_DATADE       Char( 08 ),
   @IN_DATAATE      Char( 08 ),
   @IN_LMOEDAESP    Char( 01 ),
   @IN_MOEDA        Char( 'CQ0_MOEDA' ),
   @IN_TPSALDO      Char( 'CQ0_TPSALD' ),
   @IN_CONTA        Char( 'CT1_CONTA' ),
   @IN_EMPANT       Char(02),
   @OUT_RESULTADO   Char( 01 ) OutPut
 )
as

/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  000 </a>
    Fonte Microsiga - <s>  CTBA192.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Atualiza os Flags de Conta Ponte </d>
    Funcao do Siga  -      CtbFlgPon() - Atualiza os Flags de Conta Ponte
    Entrada         - <ri> @IN_FILIAL       - Filial do processo
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_CONTA        - Conta do processamento
                           @IN_EMPANT       - Grupo de Emp atual
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     18/11/2003
-------------------------------------------------------------------------------------- */
declare @cFilial_CTZ  char( 'CTZ_FILIAL' )
declare @cFilial_CQ0  char( 'CQ0_FILIAL' )
declare @cFilial_CQ1  char( 'CQ1_FILIAL' )
declare @cFilial_CQ2  char( 'CQ2_FILIAL' )
declare @cFilial_CQ3  char( 'CQ3_FILIAL' )
declare @cFilial_CQ4  char( 'CQ4_FILIAL' )
declare @cFilial_CQ5  char( 'CQ5_FILIAL' )
declare @cFilial_CQ6  char( 'CQ6_FILIAL' )
declare @cFilial_CQ7  char( 'CQ7_FILIAL' )
declare @cFilial_CQ8  char( 'CQ8_FILIAL' )
declare @cFilial_CQ9  char( 'CQ9_FILIAL' )
declare @cFILCTZ      char( 'CT9_FILIAL' )
declare @cAux         char( 03 )
declare @cAux1        char( 01 )
Declare @cCTZ_DATA    Char( 08 )
Declare @cCTZ_MOEDLC  Char( 'CTZ_MOEDLC' )
Declare @cCTZ_CONTA   Char( 'CTZ_CONTA' )
Declare @cCTZ_CUSTO   Char( 'CTZ_CUSTO' )
Declare @cCTZ_ITEM    Char( 'CTZ_ITEM' )
Declare @cCTZ_CLVL    Char( 'CTZ_CLVL' )

begin
   
   select @OUT_RESULTADO = '0'
   select @cAux = 'CTZ'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CTZ OutPut
   
   Declare CUR_CT190FLGLP insensitive cursor for
      Select CTZ_FILIAL, CTZ_DATA, CTZ_MOEDLC, CTZ_CONTA, CTZ_CUSTO, CTZ_ITEM, CTZ_CLVL
        From CTZ###
       Where CTZ_FILIAL   = @cFilial_CTZ
         and CTZ_DATA     between @IN_DATADE   and @IN_DATAATE
         and CTZ_TPSALD   = @IN_TPSALDO
         and ((CTZ_MOEDLC = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP <>'1')
         and CTZ_CONTA    = @IN_CONTA
         and D_E_L_E_T_ = ' '
    ORDER BY 1, 2, 3, 7, 6, 5, 4
   for read only
   open CUR_CT190FLGLP
   Fetch CUR_CT190FLGLP Into @cFILCTZ, @cCTZ_DATA, @cCTZ_MOEDLC, @cCTZ_CONTA, @cCTZ_CUSTO, @cCTZ_ITEM, @cCTZ_CLVL
   
   While (@@fetch_status = 0) begin
      
      Select @cAux1 = ' '
      
      select @cAux = 'CQ0'
      exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ0 OutPut      
      EXEC CTB025_## @cFilial_CQ0, @cAux,      @cAux1,     @cCTZ_CONTA,  @cAux1,
                     @cAux1,       @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                     @IN_EMPANT,   @IN_FILIAL, @OUT_RESULTADO OutPut 
      
      select @cAux = 'CQ1'
      exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ1 OutPut
      EXEC CTB025_## @cFilial_CQ1, @cAux,      @cAux1,     @cCTZ_CONTA,  @cAux1,
                     @cAux1,       @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                     @IN_EMPANT,   @IN_FILIAL, @OUT_RESULTADO OutPut 
      
      if @cCTZ_CUSTO != ' ' begin
         select @cAux = 'CQ2'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ2 OutPut         
         EXEC CTB025_## @cFilial_CQ2, @cAux,      @cAux1,     @cCTZ_CONTA,  @cCTZ_CUSTO,
                        @cAux1,       @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILIAL, @OUT_RESULTADO OutPut
         
         select @cAux = 'CQ3'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ3 OutPut         
         EXEC CTB025_## @cFilial_CQ3, @cAux,      @cAux1,     @cCTZ_CONTA,  @cCTZ_CUSTO,
                        @cAux1,       @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILIAL, @OUT_RESULTADO OutPut
                        
         select @cAux = 'CQ8'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ8 OutPut         
         EXEC CTB025_## @cFilial_CQ8, @cAux,      'CTT',      @cAux1,       @cCTZ_CUSTO,
                        @cAux1,       @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILIAL, @OUT_RESULTADO OutPut
         select @cAux = 'CQ9'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ9 OutPut
         EXEC CTB025_## @cFilial_CQ9, @cAux,      'CTT',      @cAux1,       @cCTZ_CUSTO,
                        @cAux1,       @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILIAL, @OUT_RESULTADO OutPut
      end
      
      if @cCTZ_ITEM != ' ' begin
         select @cAux = 'CQ4'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ4 OutPut
         EXEC CTB025_## @cFilial_CQ4, @cAux,      @cAux1,     @cCTZ_CONTA,  @cCTZ_CUSTO,
                        @cCTZ_ITEM,   @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILIAL, @OUT_RESULTADO OutPut
         
         select @cAux = 'CQ5'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ5 OutPut
         EXEC CTB025_## @cFilial_CQ5, @cAux,      @cAux1,     @cCTZ_CONTA,  @cCTZ_CUSTO,
                        @cCTZ_ITEM,   @cAux1,     @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILIAL, @OUT_RESULTADO OutPut
                        
         select @cAux = 'CQ8'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ8 OutPut         
         EXEC CTB025_## @cFilial_CQ8, @cAux,      'CTD',      @cAux1,       @cAux1,
                        @cCTZ_ITEM,  @cAux1,      @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILIAL, @OUT_RESULTADO OutPut
         select @cAux = 'CQ9'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ9 OutPut
         EXEC CTB025_## @cFilial_CQ9, @cAux,      'CTD',      @cAux1,       @cAux1,
                        @cCTZ_ITEM,   @cAux1,      @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILIAL, @OUT_RESULTADO OutPut
      end
      
      if @cCTZ_CLVL != ' ' begin
         select @cAux = 'CQ6'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ6 OutPut
         EXEC CTB025_## @cFilial_CQ6, @cAux,      @cAux1,     @cCTZ_CONTA,  @cCTZ_CUSTO,
                        @cCTZ_ITEM,   @cCTZ_CLVL, @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILIAL, @OUT_RESULTADO OutPut
         
         select @cAux = 'CQ7'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ7 OutPut
         EXEC CTB025_## @cFilial_CQ7, @cAux,      @cAux1,     @cCTZ_CONTA,  @cCTZ_CUSTO,
                        @cCTZ_ITEM,   @cCTZ_CLVL, @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILIAL, @OUT_RESULTADO OutPut
                        
         select @cAux = 'CQ8'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ8 OutPut         
         EXEC CTB025_## @cFilial_CQ8, @cAux,      'CTH',      @cAux1,       @cAux1,
                        @cAux1,       @cCTZ_CLVL, @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILIAL, @OUT_RESULTADO OutPut
         select @cAux = 'CQ9'
         exec XFILIAL_## @cAux, @cFILCTZ, @cFilial_CQ9 OutPut
         EXEC CTB025_## @cFilial_CQ9, @cAux,      'CTH',      @cAux1,       @cAux1,
                        @cAux1,       @cCTZ_CLVL, @cCTZ_DATA, @cCTZ_MOEDLC, @IN_TPSALDO,
                        @IN_EMPANT,   @IN_FILIAL, @OUT_RESULTADO OutPut
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
