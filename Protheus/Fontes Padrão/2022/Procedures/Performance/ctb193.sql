Create procedure CTB193_##
( 
   @IN_FILIAL       Char('CT2_FILIAL'),
   @IN_LCUSTO       Char(01),
   @IN_LITEM        Char(01),
   @IN_LCLVL        Char(01),
   @OUT_RESULTADO   Char(01) OutPut
 )
as

/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  010 </a>
    Fonte Microsiga - <s>  CTBA193.PRW </s>
    Descricao       - <d>  Processamento de Saldo em Fila </d>
    Funcao do Siga  -      CTB193Proc()
    Entrada         - <ri> @IN_FILIAL     - Filial do processamento</ri>
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alvaro Camillo Neto	</r>
    Data        :     09/04/2014
    
    CTB193 - Processamento de Saldo em Fila
      +--> CTB194 - Ct190SlBse  - Atualizar Saldos base - CQ0, CQ1, CQ2, CQ3
               +--> CTB195  - Atualizar Saldos base - - CQ4, CQ5, CQ6, CQ7
      +--> CTB300 - - Atualiza os CUBOS
      |        +--> LASTDAY - Retorna o ultimo dia do mes
      |        +--> CTB310 - Chama Gravacao dos Cubos
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
      +--> CTB196 - Zera Fila
-------------------------------------------------------------------------------------- */
declare @cFilial_CQA char('CQA_FILIAL')
declare @cFILCQA     char('CT2_FILIAL')
declare @cAux        char(03)
declare @cAux2       char(01)
declare @dDataIni    char(08)
declare @dDataFim    char(08)
declare @cAlias      char(03)
declare @RecMin      integer
declare @RecMax      integer

begin
   
   select @OUT_RESULTADO = '0'
   select @RecMin = 0
   select @RecMax = 0
   select @cFILCQA = ' '
   
   If @IN_FILIAL = ' ' select @cFILCQA = ' '
   else select @cFILCQA = @IN_FILIAL
   
   select @cAux = 'CQA'  
   exec XFILIAL_## @cAux, @cFILCQA, @cFilial_CQA OutPut
   
   select @RecMin = Isnull( Min( R_E_C_N_O_ ), 0 ), @RecMax = Isnull( Max( R_E_C_N_O_ ), 0 )
     from CQA###
    where CQA_FILIAL = @cFilial_CQA 
      and D_E_L_E_T_ = ' '
   if ( ( @RecMin = 0 ) and ( @RecMax = 0 ) ) begin
      /* ------------------------------------------------------------
         Nao tem dados a reprocessar
         ------------------------------------------------------------*/
      select @OUT_RESULTADO = '1'
   end
   else begin
      /* -------------------------------------------------------------------------
         CTB194 - Ct190SlBse - Atualizar Saldos base - CQ0/CQ1 - CQ2/CQ3 - CQ4/CQ5 - CQ6/CQ7
         -------------------------------------------------------------------------*/
     select @OUT_RESULTADO = '0'
     EXEC CTB194_## @cFilial_CQA, @RecMin,  @RecMax , @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @OUT_RESULTADO Output
 
      /* -------------------------------------------------------------------------
         ATUALIZA CUBOS
         -------------------------------------------------------------------------*/
      ##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
      ##FIELDP01( 'CT0.CT0_ID' )
      Exec CTB300_##  @RecMin,  @RecMax , @OUT_RESULTADO OutPut
      ##ENDFIELDP01
      ##ENDIF_001
      
      select @OUT_RESULTADO = '0'
      EXEC CTB196_## @RecMin,  @RecMax,  @IN_FILIAL, @OUT_RESULTADO Output
   end

   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
   --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end
