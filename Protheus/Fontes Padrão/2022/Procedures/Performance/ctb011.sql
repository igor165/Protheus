Create procedure CTB011_##
 ( 
   @IN_FILIALCOR  Char( 'CT1_FILIAL' ),
   @IN_CALIAS     Char(03),
   @IN_INICIO     VarChar(250),
   @IN_FIM        VarChar(250),
   @OUT_Fator     int Output
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Rotina para saber o numero de entidades do intervalo.
    Funcao do Siga  -     CTB390Recn()
    Fonte Microsiga - <s> CTBA390.PRW </s>
    Entrada         - <ri> @IN_FILIALCOR  - Filial Corrente
                           @IN_CALIAS     - Alias
                           @IN_INICIO     - Inicio do Range
                           @IN_FIM        - Fim do Range
    Saida           - <ro> @OUT_Fator     - Fator  </ro>
    Responsavel :     <r> Marco Norbiato	</r>
    Data        :     19/09/2003
-------------------------------------------------------------------------------------- */
declare @cFilial_CTH  char( 'CT1_FILIAL' )
declare @cFilial_CTD  char( 'CT1_FILIAL' )
declare @cFilial_CTT  char( 'CT1_FILIAL' )
declare @cFilial_CT1  char( 'CT1_FILIAL' )
declare @cAux         char( 3 )

begin
   
   select @cAux = 'CTH'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTH OutPut
   select @cAux = 'CTT'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTT OutPut
   select @cAux = 'CTD'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTD OutPut
   select @cAux = 'CT1'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CT1 OutPut
   
   if ( @IN_CALIAS = 'CTH' ) begin
      select @OUT_Fator = isnull( count(*), 1 )
        from CTH###
       where CTH_FILIAL = @cFilial_CTH
         and CTH_CLVL  between @IN_INICIO and @IN_FIM
         and CTH_CLASSE = '2'
         and D_E_L_E_T_ = ' '
   end else begin
      if ( @IN_CALIAS = 'CTD' ) begin
         select @OUT_Fator = isnull( count(*), 1 )
           from CTD###
          where CTD_FILIAL = @cFilial_CTD
            and CTD_ITEM  between @IN_INICIO  and @IN_FIM
            and CTD_CLASSE = '2'
            and D_E_L_E_T_ = ' '
      end else begin
         if ( @IN_CALIAS = 'CTT' ) begin
            select @OUT_Fator = isnull( count(*), 1 )
              from CTT###
             where CTT_FILIAL = @cFilial_CTT
               and CTT_CUSTO between @IN_INICIO and @IN_FIM
               and CTT_CLASSE = '2'
               and D_E_L_E_T_ = ' '
         end else begin
            if ( @IN_CALIAS = 'CT1' ) begin
               select @OUT_Fator = isnull( count(*), 1 )
                 from CT1###
                where CT1_FILIAL = @cFilial_CT1
                  and CT1_CONTA between @IN_INICIO and @IN_FIM
                  and CT1_CLASSE = '2'
                  and D_E_L_E_T_ = ' '
            end
         end
      end
   end
end
