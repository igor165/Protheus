Create Procedure CTB161_##(
   @IN_FILIAL   char( 'CTT_FILIAL' ),
   @IN_DATA     char( 08 ),
   @IN_ENTIDADE char( 03 ),
   @IN_CUSTO    char( 'CTT_CUSTO' ),
   @IN_ITEM     char( 'CTD_ITEM' ),
   @IN_CLVL     char( 'CTH_CLVL' ),
   @IN_MOEDA    char( 'CT7_MOEDA' ),
   @IN_TPSALDO  char( 'CT7_TPSALD' ),
   @IN_LP       char( 'CT7_LP' )
)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBXFUN  </s>
    Descricao       - <d>  Atualizar flag CTX_SLCOMP com das tabelas CTU/CTV/CTW/CTY </d>
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL       - Filial corrente da manutencao do arquivo de lanctos
                           @IN_DATA         - Data do Lancto
                           @IN_ENTIDADE     - Determina qual a Entidade contabil ( CTT,CTD,CTH )
                           @IN_CUSTO        - CCusto
                           @IN_ITEM         - Item
                           @IN_CLVL         - ClVl
                           @IN_MOEDA        - Moeda do Lancto
                           @IN_TPSALDO      - Tipo de Saldo
                           @IN_LP           - Flag de Apuracao de Resultados
    Saida           - <o>  @OUT_RESULT      -  </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     01/12/2005
    
    CTT -> atualiza CTU 
    CTD -> atualiza CTU e se Custo <> ' ' atualiza CTV
    CTH -> atualiza CTU e se custo <> ' ' atualiza CTW
                        e se Item  <> ' ' atualiza CTX
                        e se custo <> ' ' e item <> ' ' atualiza CTY
    -------------------------------------------------------------------------------------- */

Declare @cFilial_CTU char( 'CTU_FILIAL' )
Declare @cFilial_CTV char( 'CTV_FILIAL' )
Declare @cFilial_CTW char( 'CTW_FILIAL' )
Declare @cFilial_CTX char( 'CTX_FILIAL' )
Declare @cFilial_CTY char( 'CTY_FILIAL' )
Declare @cAux        varchar( 03 )
Declare @cCodigo     Char( 'CTU_CODIGO' )
Declare @iMinRecno   integer
Declare @iMaxRecno   integer

Begin
   select @cAux = 'CTU'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CTU OutPut
   select @cAux = 'CTV'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CTV OutPut
   select @cAux = 'CTW'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CTW OutPut
   select @cAux = 'CTX'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CTX OutPut
   select @cAux = 'CTY'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CTY OutPut
   
   If @IN_ENTIDADE = 'CTT' select @cCodigo = @IN_CUSTO
   If @IN_ENTIDADE = 'CTD' select @cCodigo = @IN_ITEM
   If @IN_ENTIDADE = 'CTH' select @cCodigo = @IN_CLVL
   /*---------------------------------------------------------------
     Atualizar flag CTX_SLCOMP com 'N' na tabela CTU
     --------------------------------------------------------------- */
   select @iMinRecno = 0
   select @iMaxRecno = 0
   
   Select @iMinRecno = IsNull(Min( R_E_C_N_O_ ), 0), @iMaxRecno = IsNull(Max( R_E_C_N_O_ ), 0)
     From CTU###
    Where CTU_FILIAL  = @cFilial_CTU
      and CTU_DATA   >= @IN_DATA
      and CTU_IDENT   = @IN_ENTIDADE
      and CTU_CODIGO  = @cCodigo
      and CTU_MOEDA   = @IN_MOEDA
      and CTU_TPSALD  = @IN_TPSALDO
      and CTU_LP      = @IN_LP
      and CTU_SLCOMP <> 'N'
      and D_E_L_E_T_ = ' '
   
   While ( @iMinRecno <= @iMaxRecno and (@iMinRecno != 0 and @iMaxRecno != 0 )) begin
      Begin tran
      Update CTU###
         Set CTU_SLCOMP = 'N'
       Where R_E_C_N_O_ between @iMinRecno and @iMinRecno+4096
         and CTU_FILIAL = @cFilial_CTU
         and CTU_DATA  >= @IN_DATA
         and CTU_IDENT  = @IN_ENTIDADE
         and CTU_CODIGO = @cCodigo
         and CTU_MOEDA  = @IN_MOEDA
         and CTU_TPSALD = @IN_TPSALDO
         and CTU_LP     = @IN_LP
         and CTU_SLCOMP <> 'N'
         and D_E_L_E_T_ = ' '
      Commit Tran
      
      Select @iMinRecno = @iMinRecno + 4096
   End
   /*---------------------------------------------------------------
     Atualizar flag CTX_SLCOMP com 'N' na tabela CTV ( CUSTO /ITEM )
     --------------------------------------------------------------- */
   if @IN_ENTIDADE = 'CTD' and ( @IN_CUSTO <> ' ' AND @IN_ITEM <> ' ' ) begin
      select @iMinRecno = 0
      select @iMaxRecno = 0
      
      Select @iMinRecno = IsNull(Min( R_E_C_N_O_ ), 0), @iMaxRecno = IsNull(Max( R_E_C_N_O_ ), 0)
        From CTV###
       Where CTV_FILIAL = @cFilial_CTV
         and CTV_DATA  >= @IN_DATA
         and CTV_CUSTO  = @IN_CUSTO
         and CTV_ITEM   = @IN_ITEM
         and CTV_MOEDA  = @IN_MOEDA
         and CTV_TPSALD = @IN_TPSALDO
         and CTV_LP     = @IN_LP
         and CTV_SLCOMP <> 'N'
         and D_E_L_E_T_ = ' '
      
      While ( @iMinRecno <= @iMaxRecno and (@iMinRecno != 0 and @iMaxRecno != 0 )) begin
         Begin tran
         Update CTV###
            Set CTV_SLCOMP = 'N'
          Where R_E_C_N_O_ between @iMinRecno and @iMinRecno+4096
            and CTV_FILIAL = @cFilial_CTV
            and CTV_DATA  >= @IN_DATA
            and CTV_CUSTO  = @IN_CUSTO
            and CTV_ITEM   = @IN_ITEM
            and CTV_MOEDA  = @IN_MOEDA
            and CTV_TPSALD = @IN_TPSALDO
            and CTV_LP     = @IN_LP
            and CTV_SLCOMP <> 'N'
            and D_E_L_E_T_ = ' '
         Commit Tran
         
         Select @iMinRecno = @iMinRecno + 4096
      End
   End
   /*-----------------------------------------------------------------------------------------------------------------------
     Atualizar flag CTX_SLCOMP com 'N' na tabela CTW( CUSTO/CLVL ), CTX ( CLVL /ITEM ), CTY( CUSTO/ITEM/CLVL )
     ----------------------------------------------------------------------------------------------------------------------- */
   if ( @IN_ENTIDADE = 'CTH' ) begin
      
      If @IN_CUSTO <> ' ' begin
         Select @iMinRecno = IsNull(Min( R_E_C_N_O_ ), 0), @iMaxRecno = IsNull(Max( R_E_C_N_O_ ), 0)
           From CTW###
          Where CTW_FILIAL = @cFilial_CTW
            and CTW_DATA  >= @IN_DATA
            and CTW_CUSTO  = @IN_CUSTO
            and CTW_CLVL   = @IN_CLVL
            and CTW_MOEDA  = @IN_MOEDA
            and CTW_TPSALD = @IN_TPSALDO
            and CTW_LP     = @IN_LP
            and CTW_SLCOMP <> 'N'
            and D_E_L_E_T_ = ' '
         
         While ( @iMinRecno <= @iMaxRecno and (@iMinRecno != 0 and @iMaxRecno != 0 ) ) begin
            Begin tran
            Update CTW###
               Set CTW_SLCOMP = 'N'
             Where R_E_C_N_O_ between @iMinRecno and @iMinRecno+4096
               and CTW_FILIAL = @cFilial_CTW
               and CTW_DATA  >= @IN_DATA
               and CTW_CUSTO  = @IN_CUSTO
               and CTW_CLVL   = @IN_CLVL
               and CTW_MOEDA  = @IN_MOEDA
               and CTW_TPSALD = @IN_TPSALDO
               and CTW_LP     = @IN_LP
               and CTW_SLCOMP <> 'N'
               and D_E_L_E_T_ = ' '
            Commit Tran
            
            Select @iMinRecno = @iMinRecno + 4096
         End
      End
      
      If @IN_ITEM <> ' ' begin
         Select @iMinRecno = IsNull(Min( R_E_C_N_O_ ), 0), @iMaxRecno = IsNull(Max( R_E_C_N_O_ ), 0)
           From CTX###
          Where CTX_FILIAL = @cFilial_CTX
            and CTX_DATA  >= @IN_DATA
            and CTX_CLVL   = @IN_CLVL
            and CTX_ITEM   = @IN_ITEM
            and CTX_MOEDA  = @IN_MOEDA
            and CTX_TPSALD = @IN_TPSALDO
            and CTX_LP     = @IN_LP
            and CTX_SLCOMP <> 'N'
            and D_E_L_E_T_ = ' '
         
         While ( @iMinRecno <= @iMaxRecno and (@iMinRecno != 0 and @iMaxRecno != 0 ) ) begin
           Begin tran
            Update CTX###
               Set CTX_SLCOMP = 'N'
             Where R_E_C_N_O_ between @iMinRecno and @iMinRecno+4096
               and CTX_FILIAL = @cFilial_CTX
               and CTX_DATA  >= @IN_DATA
               and CTX_CLVL   = @IN_CLVL
               and CTX_ITEM   = @IN_ITEM
               and CTX_MOEDA  = @IN_MOEDA
               and CTX_TPSALD = @IN_TPSALDO
               and CTX_LP     = @IN_LP
               and CTX_SLCOMP <> 'N'
               and D_E_L_E_T_ = ' '
            Commit Tran
            
            Select @iMinRecno = @iMinRecno + 4096
         End
      End
      
      If ( @IN_CUSTO <> ' '  and @IN_ITEM <> ' ' and @IN_CLVL <> ' ' ) begin
         Select @iMinRecno = IsNull(Min( R_E_C_N_O_ ), 0), @iMaxRecno = IsNull(Max( R_E_C_N_O_ ), 0)
           From CTY###
          Where CTY_FILIAL = @cFilial_CTY
            and CTY_DATA  >= @IN_DATA
            and CTY_CLVL   = @IN_CLVL
            and CTY_ITEM   = @IN_ITEM
            and CTY_CUSTO  = @IN_CUSTO
            and CTY_MOEDA  = @IN_MOEDA
            and CTY_TPSALD = @IN_TPSALDO
            and CTY_LP     = @IN_LP
            and CTY_SLCOMP <> 'N'
            and D_E_L_E_T_ = ' '
         
         While ( @iMinRecno <= @iMaxRecno  and (@iMinRecno != 0 and @iMaxRecno != 0 )) begin
            Begin tran
            Update CTY###
               Set CTY_SLCOMP = 'N'
             Where R_E_C_N_O_ between @iMinRecno and @iMinRecno+4096
               and CTY_FILIAL = @cFilial_CTY
               and CTY_DATA  >= @IN_DATA
               and CTY_CLVL   = @IN_CLVL
               and CTY_ITEM   = @IN_ITEM
               and CTY_CUSTO  = @IN_CUSTO
               and CTY_MOEDA  = @IN_MOEDA
               and CTY_TPSALD = @IN_TPSALDO
               and CTY_LP     = @IN_LP
               and CTY_SLCOMP <> 'N'
               and D_E_L_E_T_ = ' '
            Commit Tran
            
            Select @iMinRecno = @iMinRecno + 4096
         End
      End
   End
End
