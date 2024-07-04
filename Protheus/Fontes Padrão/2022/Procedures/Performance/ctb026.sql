Create procedure CTB026_##
( 
   @IN_FILIAL       Char('CT2_FILIAL'),
   @IN_TABELA       Char(03),
   @IN_CONTA        Char('CT7_CONTA'),
   @IN_CUSTO        Char('CT3_CUSTO'),
   @IN_ITEM         Char('CT4_ITEM'),
   @IN_CLVL         Char('CTI_CLVL'),
   @IN_DATA         Char(08),
   @IN_MOEDA        Char('CT7_MOEDA'),
   @IN_TPSALDO      Char('CT7_TPSALD'),
   @OUT_ATUDEB      Float OutPut,
   @OUT_ATUCRD      Float OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P.11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Saldo base anterior a debito e credito </d>
    Funcao do Siga  -      SLDANTXXX - XXX -> CT7/CT3/CT4/CTI - Saldo anterior a debito e credito
                                       de saldos base
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente
                           @IN_TABELA       - Tabela
                           @IN_CONTA        - Conta
                           @IN_CUSTO        - CCUSTO
                           @IN_ITEM         - CCUSTO
                           @IN_CLVL         - CLVL
                           @IN_DATA         - Data
                           @IN_MOEDA        - Moeda
                           @IN_TPSALDO      - Tipos de Saldo
    Saida           - <o>  @IN_ATUDEB       - Debito atual da Data anterior é o saldo anterior a Debito
                           @IN_ATUCRD       - Credito da Data anterior é o saldo anterior a Credito </ro
    Responsavel :     <r>  Alice Yaeko Yamamoto	</r>
    Data        :     21/11/2003
-------------------------------------------------------------------------------------- */
declare @cFilial_CT3 char('CT3_FILIAL')
declare @cFilial_CT4 char('CT4_FILIAL')
declare @cFilial_CT7 char('CT7_FILIAL')
declare @cFilial_CTI char('CTI_FILIAL')
declare @cAux        varchar(03)
declare @nAtuDeb     Float
declare @nAtuCrd     Float

begin
   
   select @cAux = 'CT7'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT7 OutPut
   select @cAux = 'CT3'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT3 OutPut
   select @cAux = 'CT4'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT4 OutPut
   select @cAux = 'CTI'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CTI OutPut
   
   select @OUT_ATUDEB = 0
   select @OUT_ATUCRD = 0
   /*---------------------------------------------------------------
     Cálculo de saldos Anterior - CT7
   --------------------------------------------------------------- */
   If @IN_TABELA = 'CT7' begin
      Select @nAtuDeb = CT7_ATUDEB, @nAtuCrd = CT7_ATUCRD 
      From CT7### CT7 
      Where CT7.CT7_FILIAL = @cFilial_CT7
        and CT7.CT7_MOEDA  = @IN_MOEDA
        and CT7.CT7_TPSALD = @IN_TPSALDO
        and CT7.CT7_CONTA  = @IN_CONTA
        and CT7.D_E_L_E_T_ = ' '
        and CT7.CT7_DATA   = (Select MAX(CT7_DATA)
                                From CT7### CT72
                               Where CT72.CT7_FILIAL = @cFilial_CT7
                                 and CT72.CT7_MOEDA  = @IN_MOEDA
                                 and CT72.CT7_TPSALD = @IN_TPSALDO
                                 and CT72.CT7_CONTA  = @IN_CONTA
                                 and CT72.CT7_DATA   < @IN_DATA
                                 and CT72.D_E_L_E_T_ = ' ')
        and CT7.CT7_LP = (Select MAX(CT7_LP)
                            from CT7### CT73
                           Where CT73.CT7_FILIAL = @cFilial_CT7
                             and CT73.CT7_MOEDA  = @IN_MOEDA
                             and CT73.CT7_TPSALD = @IN_TPSALDO
                             and CT73.CT7_CONTA  = @IN_CONTA
                             and CT73.CT7_DATA   = (Select MAX(CT7_DATA) 
                                                      From CT7### CT74 
                                                     Where CT74.CT7_FILIAL = @cFilial_CT7
                                                       and CT74.CT7_MOEDA  = @IN_MOEDA
                                                       and CT74.CT7_TPSALD = @IN_TPSALDO
                                                       and CT74.CT7_CONTA  = @IN_CONTA
                                                       and CT74.CT7_DATA   < @IN_DATA
                                                       and CT74.D_E_L_E_T_ = ' ' )
                             and CT73.D_E_L_E_T_ = ' ')
      
   end
   /*---------------------------------------------------------------
     Cálculo de saldos Anterior - CT3 - Centro de Custos
   --------------------------------------------------------------- */
   If @IN_TABELA = 'CT3' begin
      Select @nAtuDeb = CT3_ATUDEB, @nAtuCrd = CT3_ATUCRD 
        From CT3### CT3
       Where CT3.CT3_FILIAL = @cFilial_CT3
         and CT3.CT3_MOEDA  = @IN_MOEDA
         and CT3.CT3_TPSALD = @IN_TPSALDO
         and CT3.CT3_CONTA  = @IN_CONTA
         and CT3.CT3_CUSTO  = @IN_CUSTO
         and CT3.D_E_L_E_T_ = ' '
         and CT3.CT3_DATA = (Select Max(CT3_DATA)
                               From CT3### CT32
                              Where CT32.CT3_FILIAL = @cFilial_CT3
                                and CT32.CT3_MOEDA  = @IN_MOEDA
                                and CT32.CT3_TPSALD = @IN_TPSALDO
                                and CT32.CT3_CONTA  = @IN_CONTA
                                and CT32.CT3_CUSTO  = @IN_CUSTO
                                and CT32.CT3_DATA   < @IN_DATA
                                and CT32.D_E_L_E_T_ = ' ')
         and CT3.CT3_LP = (Select Max(CT3_LP)
                             From CT3### CT33
                            Where CT33.CT3_FILIAL = @cFilial_CT3
                              and CT33.CT3_MOEDA  = @IN_MOEDA
                              and CT33.CT3_TPSALD = @IN_TPSALDO
                              and CT33.CT3_CONTA  = @IN_CONTA
                              and CT33.CT3_CUSTO  = @IN_CUSTO
                              and CT33.CT3_DATA   =(Select MAX(CT3_DATA)
                                                      From CT3### CT34
                                                     Where CT34.CT3_FILIAL = @cFilial_CT3
                                                       and CT34.CT3_MOEDA  = @IN_MOEDA
                                                       and CT34.CT3_TPSALD = @IN_TPSALDO
                                                       and CT34.CT3_CONTA  = @IN_CONTA
                                                       and CT34.CT3_CUSTO  = @IN_CUSTO
                                                       and CT34.CT3_DATA   < @IN_DATA
                                                       and CT34.D_E_L_E_T_ = ' ')
                              and CT33.D_E_L_E_T_ = ' ')
   end
   /*---------------------------------------------------------------
     Cálculo de saldos Anterior - CT4 - Item
   --------------------------------------------------------------- */
   If @IN_TABELA = 'CT4' begin
      Select @nAtuDeb = CT4_ATUDEB, @nAtuCrd = CT4_ATUCRD 
        From CT4### CT4
       Where CT4.CT4_FILIAL = @cFilial_CT4
         and CT4.CT4_MOEDA  = @IN_MOEDA
         and CT4.CT4_TPSALD = @IN_TPSALDO
         and CT4.CT4_CONTA  = @IN_CONTA
         and CT4.CT4_CUSTO  = @IN_CUSTO
         and CT4.CT4_ITEM   = @IN_ITEM
         and CT4.D_E_L_E_T_ = ' '
         and CT4.CT4_DATA = (Select Max(CT4_DATA)
                               From CT4### CT42
                              Where CT42.CT4_FILIAL = @cFilial_CT4
                                and CT42.CT4_MOEDA  = @IN_MOEDA
                                and CT42.CT4_TPSALD = @IN_TPSALDO
                                and CT42.CT4_CONTA  = @IN_CONTA
                                and CT42.CT4_CUSTO  = @IN_CUSTO
                                and CT42.CT4_ITEM   = @IN_ITEM
                                and CT42.CT4_DATA   < @IN_DATA
                                and CT42.D_E_L_E_T_ = ' ')
        and CT4.CT4_LP = (Select Max(CT4_LP)
                            From CT4### CT43
                           Where CT43.CT4_FILIAL = @cFilial_CT4
                             and CT43.CT4_MOEDA  = @IN_MOEDA
                             and CT43.CT4_TPSALD = @IN_TPSALDO
                             and CT43.CT4_CONTA  = @IN_CONTA
                             and CT43.CT4_CUSTO  = @IN_CUSTO
                             and CT43.CT4_ITEM   = @IN_ITEM
                             and CT43.CT4_DATA   =  (Select MAX(CT4_DATA)
                                                       From CT4### CT44
                                                      Where CT44.CT4_FILIAL = @cFilial_CT4
                                                        and CT44.CT4_MOEDA  = @IN_MOEDA
                                                        and CT44.CT4_TPSALD = @IN_TPSALDO
                                                        and CT44.CT4_CONTA  = @IN_CONTA
                                                        and CT44.CT4_CUSTO  = @IN_CUSTO
                                                        and CT44.CT4_ITEM   = @IN_ITEM
                                                        and CT44.CT4_DATA   < @IN_DATA
                                                        and CT44.D_E_L_E_T_  = ' ') 
                             and CT43.D_E_L_E_T_ = ' ')
   end
   /*---------------------------------------------------------------
     Cálculo de saldos Anterior - CTI - Casse de Valores
   --------------------------------------------------------------- */
   If @IN_TABELA = 'CTI' begin
      Select @nAtuDeb = CTI_ATUDEB, @nAtuCrd = CTI_ATUCRD 
        From CTI### CTI
       where CTI.CTI_FILIAL = @IN_FILIAL
         and CTI.CTI_MOEDA  = @IN_MOEDA
         and CTI.CTI_TPSALD = @IN_TPSALDO
         and CTI.CTI_CONTA  = @IN_CONTA
         and CTI.CTI_CUSTO  = @IN_CUSTO
         and CTI.CTI_ITEM   = @IN_ITEM
         and CTI.CTI_CLVL   = @IN_CLVL
         and CTI.D_E_L_E_T_ = ' '
         and CTI.CTI_DATA = (select Max(CTI_DATA)
                               from CTI### CTI2
                              Where CTI2.CTI_FILIAL = @cFilial_CTI
                                and CTI2.CTI_MOEDA  = @IN_MOEDA
                                and CTI2.CTI_TPSALD = @IN_TPSALDO
                                and CTI2.CTI_CONTA  = @IN_CONTA
                                and CTI2.CTI_CUSTO  = @IN_CUSTO
                                and CTI2.CTI_ITEM   = @IN_ITEM
                                and CTI2.CTI_CLVL   = @IN_CLVL
                                and CTI2.CTI_DATA   < @IN_DATA
                                and CTI2.D_E_L_E_T_ = ' ')
         and CTI.CTI_LP = (Select Max(CTI_LP)
                             From CTI### CTI3
                            Where CTI3.CTI_FILIAL = @cFilial_CTI 
                              and CTI3.CTI_MOEDA  = @IN_MOEDA
                              and CTI3.CTI_TPSALD = @IN_TPSALDO
                              and CTI3.CTI_CONTA  = @IN_CONTA
                              and CTI3.CTI_CUSTO  = @IN_CUSTO
                              and CTI3.CTI_ITEM   = @IN_ITEM
                              and CTI3.CTI_CLVL   = @IN_CLVL
                              and CTI3.CTI_DATA   = (Select MAX(CTI_DATA)
                                                       From CTI### CTI4
                                                      Where CTI4.CTI_FILIAL = @cFilial_CTI
                                                        and CTI4.CTI_MOEDA  = @IN_MOEDA
                                                        and CTI4.CTI_TPSALD = @IN_TPSALDO
                                                        and CTI4.CTI_CONTA  = @IN_CONTA
                                                        and CTI4.CTI_CUSTO  = @IN_CUSTO
                                                        and CTI4.CTI_ITEM   = @IN_ITEM 
                                                        and CTI4.CTI_CLVL   = @IN_CLVL
                                                        and CTI4.CTI_DATA   < @IN_DATA
                                                        and CTI4.D_E_L_E_T_ = ' ')
                              and CTI3.D_E_L_E_T_ = ' ' )
   end
   /*---------------------------------------------------------------
     Retornos
   --------------------------------------------------------------- */
   if @nAtuDeb is Null select @OUT_ATUDEB = 0
   else select @OUT_ATUDEB = @nAtuDeb
   
   if @nAtuCrd is Null select @OUT_ATUCRD = 0
   else select @OUT_ATUCRD = @nAtuCrd
      
end
