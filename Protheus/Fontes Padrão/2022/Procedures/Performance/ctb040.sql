Create procedure CTB040_##
( 
   @IN_FILIAL       Char('CTV_FILIAL'),
   @IN_MOEDA        Char('CTV_MOEDA'),
   @IN_TPSALDO      Char('CTV_TPSALD'),
   @IN_CUSTO        Char('CTV_CUSTO'),
   @IN_ITEM         Char('CTV_ITEM'),
   @IN_LP           Char('CTV_LP'),
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
    Funcao do Siga  -      SLDANTCTV  - Recuperar slds a debito e credito anteriores a data inicial
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente onde buscar o sld anterior
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_CUSTO        - CCusto
                           @IN_ITEM         - Item
                           @IN_LP           - Lncto de Apuracao
                           @IN_DATA         - Data
    Saida           - <o>  @OUT_ANTDEB      - sald anterior a debito
                           @OUT_ANTCRD      - sald anterior a credito  </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     08/12/2003
-------------------------------------------------------------------------------------- */

begin
   
   Select @OUT_ANTDEB = CTV_ATUDEB, @OUT_ANTCRD = CTV_ATUCRD
     From CTV### CTV
    Where CTV.CTV_FILIAL = @IN_FILIAL
      and CTV.CTV_MOEDA  = @IN_MOEDA
      and CTV.CTV_TPSALD = @IN_TPSALDO
      and CTV.CTV_CUSTO  = @IN_CUSTO
      and CTV.CTV_ITEM   = @IN_ITEM
      and CTV.D_E_L_E_T_ = ' '
      and CTV.CTV_DATA = (Select Max(CTV_DATA)
                           From CTV### CTV2
                          Where CTV2.CTV_FILIAL = @IN_FILIAL
                            and CTV2.CTV_MOEDA  = @IN_MOEDA
                            and CTV2.CTV_TPSALD = @IN_TPSALDO
                            and CTV2.CTV_CUSTO  = @IN_CUSTO
                            and CTV2.CTV_ITEM   = @IN_ITEM
                            and CTV2.CTV_DATA   < @IN_DATA
                            and CTV2.D_E_L_E_T_ = ' ')
      and CTV.CTV_LP = (Select MAX(CTV_LP)
                          from CTV### CTV3
                         Where CTV3.CTV_FILIAL = @IN_FILIAL
                           and CTV3.CTV_MOEDA  = @IN_MOEDA
                           and CTV3.CTV_TPSALD = @IN_TPSALDO
                           and CTV3.CTV_CUSTO  = @IN_CUSTO
                           and CTV3.CTV_ITEM   = @IN_ITEM
                           and CTV3.CTV_DATA   = (Select MAX(CTV_DATA) 
                                                    From CTV### CTV4
                                                   Where CTV4.CTV_FILIAL = @IN_FILIAL
                                                     and CTV4.CTV_MOEDA  = @IN_MOEDA
                                                     and CTV4.CTV_TPSALD = @IN_TPSALDO
                                                     and CTV4.CTV_CUSTO  = @IN_CUSTO
                                                     and CTV4.CTV_ITEM   = @IN_ITEM
                                                     and CTV4.CTV_DATA   < @IN_DATA
                                                     and CTV4.D_E_L_E_T_ = ' ' )
                           and CTV3.D_E_L_E_T_ = ' ')

   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
     --------------------------------------------------------------- */
   If @OUT_ANTDEB is null select @OUT_ANTDEB = 0
   If @OUT_ANTCRD is null select @OUT_ANTCRD = 0
end
