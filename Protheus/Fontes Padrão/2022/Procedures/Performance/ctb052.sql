Create procedure CTB052_##
( 
   @IN_FILDE       Char('CT3_FILIAL'),
   @IN_FILATE      Char('CT3_FILIAL'),
   @IN_TABELA      Char(03),
   @IN_DATADE      Char(08),
   @IN_DATAATE     Char(08),
   @IN_LMOEDAESP   Char(01),
   @IN_MOEDA       Char('CT3_MOEDA'),
   @IN_TPSALDO     Char('CT3_TPSALD')
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Atualiza flag de slds compostos </d>
    Fonte Microsiga - <s>  CTBA360.PRW </s>
    Funcao do Siga  -      Ct360Flag - Atualiza flag de slds compostos
    Entrada         - <ri> @IN_FILDE        - Filial De
                           @IN_FILATE       - Filial Ate
                           @IN_TABELA       - Tabela
                           @IN_DATADE       - Data De
                           @IN_DATAATE      - Data Ate
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0' todas ou especifica
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
    Saida           - <o>  </o>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     14/01/2004
   -------------------------------------------------------------------------------------- */
declare @iMin Integer
declare @iMax Integer

begin
   /*---------------------------------------------------------------
     Atualizacao do CT3
   --------------------------------------------------------------- */
   If @IN_TABELA = 'CT3' begin
      Select @iMin = IsNull(Min(R_E_C_N_O_),0), @iMax = IsNull(Max(R_E_C_N_O_),0)
        From CT3###
       Where CT3_FILIAL  between @IN_FILDE and @IN_FILATE
         and CT3_DATA   between @IN_DATADE and @IN_DATAATE
         and ( ( CT3_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
         and CT3_TPSALD  = @IN_TPSALDO
         and CT3_SLCOMP != 'S'
         and D_E_L_E_T_  = ' '
      
      If @iMin > 0 begin
         While @iMin <= @iMax begin
            begin tran
            Update CT3###
      		   Set CT3_SLCOMP = 'S'
      		 Where CT3_FILIAL between @IN_FILDE and @IN_FILATE
               and CT3_DATA  between @IN_DATADE and @IN_DATAATE
               and ( ( CT3_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
               and CT3_TPSALD = @IN_TPSALDO
               and CT3_SLCOMP != 'S'
      		   and D_E_L_E_T_ = ' '
               and R_E_C_N_O_  between @iMin and @iMin + 5000
            commit tran
            select @iMin = @iMin + 5000
         end
      end
   End
   
   /*---------------------------------------------------------------
     Atualizacao do CT4
   --------------------------------------------------------------- */
   If @IN_TABELA = 'CT4' begin
      Select @iMin = IsNull(Min(R_E_C_N_O_),0), @iMax = IsNull(Max(R_E_C_N_O_),0)
        From CT4###
       Where CT4_FILIAL   between @IN_FILDE and @IN_FILATE
         and CT4_DATA   between @IN_DATADE and @IN_DATAATE
         and ( ( CT4_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
         and CT4_TPSALD  = @IN_TPSALDO
         and CT4_SLCOMP != 'S'
         and D_E_L_E_T_  = ' '
      
      If @iMin > 0 begin
         While @iMin <= @iMax begin
            begin tran
            Update CT4###	
      		   Set CT4_SLCOMP = 'S'
      		 Where CT4_FILIAL between @IN_FILDE and @IN_FILATE
               and CT4_DATA  between @IN_DATADE and @IN_DATAATE
               and ( ( CT4_MOEDA  = @IN_MOEDA and @IN_LMOEDAESP ='1') or @IN_LMOEDAESP = '0')
               and CT4_TPSALD = @IN_TPSALDO
               and CT4_SLCOMP != 'S'
               and R_E_C_N_O_  between @iMin and @iMin + 5000
      		   and D_E_L_E_T_ = ' '
            commit tran
            select @iMin = @iMin + 5000
          end
      end
   End
   /*---------------------------------------------------------------
     Atualizacao do CTI
   --------------------------------------------------------------- */
   If @IN_TABELA = 'CTI' begin
      Select @iMin = IsNull(Min(R_E_C_N_O_),0), @iMax = IsNull(Max(R_E_C_N_O_),0)
        From CTI###
       Where CTI_FILIAL  between @IN_FILDE and @IN_FILATE
         and CTI_DATA   between @IN_DATADE and @IN_DATAATE
         and ( (CTI_MOEDA = @IN_MOEDA  and @IN_LMOEDAESP = '1') or @IN_LMOEDAESP = '0')
         and CTI_TPSALD  = @IN_TPSALDO
         and CTI_SLCOMP != 'S'
         and D_E_L_E_T_  = ' '
      
      If @iMin > 0 begin
         While @iMin <= @iMax begin
            Begin tran
            Update CTI###
      		   Set CTI_SLCOMP = 'S'
      		 Where CTI_FILIAL between @IN_FILDE and @IN_FILATE
               and CTI_DATA  between @IN_DATADE and @IN_DATAATE
               and ( (CTI_MOEDA  = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0')
               and CTI_TPSALD = @IN_TPSALDO
               and CTI_SLCOMP != 'S'
               and R_E_C_N_O_  between @iMin and @iMin + 5000
      		   and D_E_L_E_T_ = ' '
            commit tran
            select @iMin = @iMin + 5000
         end
      end
   End
end

