Create procedure CTB043_##
( 
   @IN_FILIAL       Char('CTW_FILIAL'),
   @IN_MOEDA        Char('CTW_MOEDA'),
   @IN_TPSALDO      Char('CTW_TPSALD'),
   @IN_CUSTO        Char('CTW_CUSTO'),
   @IN_CLVL         Char('CTW_CLVL'),
   @IN_LP           Char('CTW_LP'),
   @IN_DATA         Char(08),
   @OUT_ANTDEB      Float  OutPut,
   @OUT_ANTCRD      Float  OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Recuperar slds anteriores a debito e credito a data inicial </d>
    Fonte Microsiga - <s>  CTBXSAL.PRW </s>
    Funcao do Siga  -      SLDANTCTW  - Recuperar slds anteriores a debito e credito a data inicial
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente onde buscar o sld anterior
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_CUSTO        - CCusto
                           @IN_CLVL         - ClVl
                           @IN_LP          - Lancto de Apuracao
                           @IN_DATA         - Data
    Saida           - <o>  @OUT_ANTDEB      - sald anterior a debito
                           @OUT_ANTCRD      - sald anterior a credito  </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     02/01/2004
-------------------------------------------------------------------------------------- */

begin
   
   Select @OUT_ANTDEB = CTW_ATUDEB, @OUT_ANTCRD = CTW_ATUCRD
     From CTW### CTW
    Where CTW.CTW_FILIAL = @IN_FILIAL
      and CTW.CTW_MOEDA  = @IN_MOEDA
      and CTW.CTW_TPSALD = @IN_TPSALDO
      and CTW.CTW_CLVL   = @IN_CLVL
      and CTW.CTW_CUSTO  = @IN_CUSTO
      and CTW.D_E_L_E_T_ = ' '
      and CTW.CTW_DATA = (Select Max(CTW_DATA)
                           From CTW### CTW2
                          Where CTW2.CTW_FILIAL = @IN_FILIAL
                            and CTW2.CTW_MOEDA  = @IN_MOEDA
                            and CTW2.CTW_TPSALD = @IN_TPSALDO
                            and CTW2.CTW_DATA   < @IN_DATA
                            and CTW2.CTW_CUSTO  = @IN_CUSTO
                            and CTW2.CTW_CLVL   = @IN_CLVL
                            and CTW2.D_E_L_E_T_ = ' ')
      and CTW.CTW_LP = (Select MAX(CTW_LP)
                          from CTW### CTW3
                         Where CTW3.CTW_FILIAL = @IN_FILIAL
                           and CTW3.CTW_MOEDA  = @IN_MOEDA
                           and CTW3.CTW_TPSALD = @IN_TPSALDO
                           and CTW3.CTW_CUSTO  = @IN_CUSTO
                           and CTW3.CTW_CLVL   = @IN_CLVL
                           and CTW3.CTW_DATA   = (Select MAX(CTW_DATA) 
                                                    From CTW### CTW4 
                                                   Where CTW4.CTW_FILIAL = @IN_FILIAL
                                                     and CTW4.CTW_MOEDA  = @IN_MOEDA
                                                     and CTW4.CTW_TPSALD = @IN_TPSALDO
                                                     and CTW4.CTW_CUSTO  = @IN_CUSTO
                                                     and CTW4.CTW_CLVL   = @IN_CLVL
                                                     and CTW4.CTW_DATA   < @IN_DATA
                                                     and CTW4.D_E_L_E_T_ = ' ' )
                           and CTW3.D_E_L_E_T_ = ' ')
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
     --------------------------------------------------------------- */
   If @OUT_ANTDEB is null select @OUT_ANTDEB = 0
   If @OUT_ANTCRD is null select @OUT_ANTCRD = 0
end
