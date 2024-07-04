Create procedure CTB049_##
( 
   @IN_FILIAL       Char('CTY_FILIAL'),
   @IN_MOEDA        Char('CTY_MOEDA'),
   @IN_TPSALDO      Char('CTY_TPSALD'),
   @IN_CUSTO        Char('CTY_CUSTO'),
   @IN_ITEM         Char('CTY_ITEM'),
   @IN_CLVL         Char('CTY_CLVL'),
   @IN_LP           Char('CTY_LP'),
   @IN_DATA         Char(08),
   @OUT_ANTDEB      Float OutPut,
   @OUT_ANTCRD      Float OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Fonte Microsiga - <s>  CTBXSAL.PRW </s>
    Assinatura      - <a>  001 </a>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Recuperar slds anteriores a debito e credito a data informada </d>
    Funcao do Siga  -      SLDANTCTY  - Recuperar slds anteriores a debito e credito a data informada
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente onde buscar o sld anterior
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_CUSTO        - Custo
                           @IN_ITEM         - Item
                           @IN_CLVL         - ClVl
                           @IN_LP           - Lancto de apuracao
                           @IN_DATA         - Data
    Saida           - <o>  @OUT_ANTDEB      - sald anterior a debito
                           @OUT_ANTCRD      - sald anterior a credito  </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     02/01/2004
-------------------------------------------------------------------------------------- */

begin
   
   Select @OUT_ANTDEB = CTY_ATUDEB, @OUT_ANTCRD = CTY_ATUCRD
     From CTY### CTY
    Where CTY.CTY_FILIAL = @IN_FILIAL
      and CTY.CTY_MOEDA  = @IN_MOEDA
      and CTY.CTY_TPSALD = @IN_TPSALDO
      and CTY.CTY_CLVL   = @IN_CLVL
      and CTY.CTY_ITEM   = @IN_ITEM
      and CTY.CTY_CUSTO  = @IN_CUSTO
      and CTY.D_E_L_E_T_ = ' '
      and CTY.CTY_DATA = (Select Max(CTY_DATA)
                           From CTY### CTY2
                          Where CTY2.CTY_FILIAL = @IN_FILIAL
                            and CTY2.CTY_MOEDA  = @IN_MOEDA
                            and CTY2.CTY_TPSALD = @IN_TPSALDO
                            and CTY2.CTY_DATA   < @IN_DATA
                            and CTY2.CTY_CLVL   = @IN_CLVL
                            and CTY2.CTY_ITEM   = @IN_ITEM
                            and CTY2.CTY_CUSTO  = @IN_CUSTO
                            and CTY2.D_E_L_E_T_ = ' ')
      and CTY.CTY_LP = (Select MAX(CTY_LP)
                          from CTY### CTY3
                         Where CTY3.CTY_FILIAL = @IN_FILIAL
                           and CTY3.CTY_MOEDA  = @IN_MOEDA
                           and CTY3.CTY_TPSALD = @IN_TPSALDO
                           and CTY3.CTY_CLVL   = @IN_CLVL
                           and CTY3.CTY_ITEM   = @IN_ITEM
                           and CTY3.CTY_CUSTO  = @IN_CUSTO
                           and CTY3.CTY_DATA   = (Select MAX(CTY_DATA) 
                                                    From CTY### CTY4 
                                                   Where CTY4.CTY_FILIAL = @IN_FILIAL
                                                     and CTY4.CTY_MOEDA  = @IN_MOEDA
                                                     and CTY4.CTY_TPSALD = @IN_TPSALDO
                                                     and CTY4.CTY_CLVL   = @IN_CLVL
                                                     and CTY4.CTY_ITEM   = @IN_ITEM
                                                     and CTY4.CTY_CUSTO  = @IN_CUSTO
                                                     and CTY4.CTY_DATA   < @IN_DATA
                                                     and CTY4.D_E_L_E_T_ = ' ' )
                           and CTY3.D_E_L_E_T_ = ' ')
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
     --------------------------------------------------------------- */
   If @OUT_ANTDEB is null select @OUT_ANTDEB = 0
   If @OUT_ANTCRD is null select @OUT_ANTCRD = 0
end
