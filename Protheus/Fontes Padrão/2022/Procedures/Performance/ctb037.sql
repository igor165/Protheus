Create procedure CTB037_##
( 
   @IN_FILIAL       Char('CTU_FILIAL'),
   @IN_MOEDA        Char('CTU_MOEDA'),
   @IN_TPSALDO      Char('CTU_TPSALD'),
   @IN_CODIGO       Char('CTU_CODIGO'),
   @IN_IDENT        Char('CTU_IDENT'),
   @IN_LP           Char('CTU_LP'),
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
    Descricao       - <d>  Recuperar slds a debito e credito anteriores a data inicial </d>
    Funcao do Siga  -      SLDANTCTU - Recuperar slds a debito e credito anteriores a data inicial
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente onde buscar o sld anterior
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_CODIGO       - Codigo
                           @IN_IDENT        - Identifica a tabela
                           @IN_LP           - se é lacto de Apuracao de Resultado
                           @IN_DATA         - Data
    Saida           - <o>  @OUT_ANTDEB      - sald anterior a debito
                           @OUT_ANTCRD      - sald anterior a credito  </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     08/12/2003
-------------------------------------------------------------------------------------- */

begin
   
   Select @OUT_ANTDEB = CTU_ATUDEB, @OUT_ANTCRD = CTU_ATUCRD
     From CTU### CTU
    Where CTU.CTU_FILIAL = @IN_FILIAL
      and CTU.CTU_MOEDA  = @IN_MOEDA
      and CTU.CTU_TPSALD = @IN_TPSALDO
      and CTU.CTU_CODIGO = @IN_CODIGO
      and CTU.CTU_IDENT  = @IN_IDENT
      and CTU.D_E_L_E_T_ = ' '
      and CTU.CTU_DATA = (Select Max(CTU_DATA)
                           From CTU### CTU2
                          Where CTU2.CTU_FILIAL = @IN_FILIAL
                            and CTU2.CTU_MOEDA  = @IN_MOEDA
                            and CTU2.CTU_TPSALD = @IN_TPSALDO
                            and CTU2.CTU_CODIGO = @IN_CODIGO
                            and CTU2.CTU_IDENT  = @IN_IDENT
                            and CTU2.CTU_DATA   < @IN_DATA
                            and CTU2.D_E_L_E_T_ = ' ')
      and CTU.CTU_LP = (Select MAX(CTU_LP)
                          from CTU### CTU3
                         Where CTU3.CTU_FILIAL = @IN_FILIAL
                           and CTU3.CTU_MOEDA  = @IN_MOEDA
                           and CTU3.CTU_TPSALD = @IN_TPSALDO
                           and CTU3.CTU_CODIGO = @IN_CODIGO
                           and CTU3.CTU_IDENT  = @IN_IDENT
                           and CTU3.CTU_DATA   = (Select MAX(CTU_DATA) 
                                                    From CTU### CTU4 
                                                   Where CTU4.CTU_FILIAL = @IN_FILIAL
                                                     and CTU4.CTU_MOEDA  = @IN_MOEDA
                                                     and CTU4.CTU_TPSALD = @IN_TPSALDO
                                                     and CTU4.CTU_CODIGO = @IN_CODIGO
                                                     and CTU4.CTU_IDENT  = @IN_IDENT
                                                     and CTU4.CTU_DATA   < @IN_DATA
                                                     and CTU4.D_E_L_E_T_ = ' ' )
                           and CTU3.D_E_L_E_T_ = ' ')
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
     --------------------------------------------------------------- */
   If @OUT_ANTDEB is null select @OUT_ANTDEB = 0
   If @OUT_ANTCRD is null select @OUT_ANTCRD = 0
end
