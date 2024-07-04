Create procedure CTB046_##
( 
   @IN_FILIAL       Char('CTX_FILIAL'),
   @IN_MOEDA        Char('CTX_MOEDA'),
   @IN_TPSALDO      Char('CTX_TPSALD'),
   @IN_ITEM         Char('CTX_ITEM'),
   @IN_CLVL         Char('CTX_CLVL'),
   @IN_LP           Char('CTX_LP'),
   @IN_DATA         Char(08),
   @OUT_ANTDEB      Float OutPut,
   @OUT_ANTCRD      Float OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBXSAL.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Recuperar slds anteriores a debito e credito a data inicial </d>
    Funcao do Siga  -      SLDANTCTX  - Recuperar slds anteriores a debito e credito a data inicial
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente onde buscar o sld anterior
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_ITEM         - Item
                           @IN_CLVL         - ClVl
                           @IN_LP           - Lancto de Apuracao
                           @IN_DATA         - Data
    Saida           - <o>  @OUT_ANTDEB      - sald anterior a debito
                           @OUT_ANTCRD      - sald anterior a credito  </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     02/01/2004
-------------------------------------------------------------------------------------- */

begin
   
   Select @OUT_ANTDEB = CTX_ATUDEB, @OUT_ANTCRD = CTX_ATUCRD
     From CTX### CTX
    Where CTX.CTX_FILIAL = @IN_FILIAL
      and CTX.CTX_MOEDA  = @IN_MOEDA
      and CTX.CTX_TPSALD = @IN_TPSALDO
      and CTX.CTX_CLVL   = @IN_CLVL
      and CTX.CTX_ITEM   = @IN_ITEM 
      and CTX.D_E_L_E_T_ = ' '
      and CTX.CTX_DATA = (Select Max(CTX_DATA)
                           From CTX### CTX2
                          Where CTX2.CTX_FILIAL = @IN_FILIAL
                            and CTX2.CTX_MOEDA  = @IN_MOEDA
                            and CTX2.CTX_TPSALD = @IN_TPSALDO
                            and CTX2.CTX_DATA   < @IN_DATA
                            and CTX2.CTX_CLVL   = @IN_CLVL
                            and CTX2.CTX_ITEM   = @IN_ITEM
                            and CTX2.D_E_L_E_T_ = ' ')
      and CTX.CTX_LP = (Select MAX(CTX_LP)
                          from CTX### CTX3
                         Where CTX3.CTX_FILIAL = @IN_FILIAL
                           and CTX3.CTX_MOEDA  = @IN_MOEDA
                           and CTX3.CTX_TPSALD = @IN_TPSALDO
                           and CTX3.CTX_CLVL   = @IN_CLVL
                           and CTX3.CTX_ITEM   = @IN_ITEM
                           and CTX3.CTX_DATA   = (Select MAX(CTX_DATA) 
                                                    From CTX### CTX4 
                                                   Where CTX4.CTX_FILIAL = @IN_FILIAL
                                                     and CTX4.CTX_MOEDA  = @IN_MOEDA
                                                     and CTX4.CTX_TPSALD = @IN_TPSALDO
                                                     and CTX4.CTX_CLVL   = @IN_CLVL
                                                     and CTX4.CTX_ITEM   = @IN_ITEM
                                                     and CTX4.CTX_DATA   < @IN_DATA
                                                     and CTX4.D_E_L_E_T_ = ' ' )
                           and CTX3.D_E_L_E_T_ = ' ')
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
     --------------------------------------------------------------- */
   If @OUT_ANTDEB is null select @OUT_ANTDEB = 0
   If @OUT_ANTCRD is null select @OUT_ANTCRD = 0
end
