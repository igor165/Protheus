Create procedure CTB036_##
( 
   @IN_DESTINO      char(03),
   @IN_IDENT        char(03),
   @IN_FILDE        Char('CT2_FILIAL'),
   @IN_FILATE       Char('CT2_FILIAL'),
   @IN_DATAMIN      Char(08),
   @IN_DATALIM      Char(08),
   @IN_LMOEDAESP    Char(01),
   @IN_MOEDA        Char('CT7_MOEDA'),
   @IN_TPSALDO      Char('CT2_TPSALD'),
   @IN_REPROC       Char(01),
   @IN_INTEGRIDADE  Char(01),
   @IN_MVCTB190D    Char(01),
   @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA360.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Apaga Saldos compostos das tabelas destino </d>
    Funcao do Siga  -      Ct360Del() - Apaga Saldos compostos das tabelas destino
    Entrada         - <ri> @IN_DESTINO      - Tabela Origem dos Saldos
                           @IN_IDENT        - Identifica a tabela
                           @IN_FILDE     - Filial inicio do processamento
                           @IN_FILATE    - Filial final do processamento
                           @IN_DATAMIN      - Data Minima
                           @IN_DATALIM      - Data Limite
                           @IN_LMOEDAESP    - Moeda Especifica - '1','0' todas
                           @IN_MOEDA        - Moeda escolhida
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_REPROC       - Se reprocessamento
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada.
                           @IN_MVCTB190D    - '1' exclui fisicamente, '0' marca como deletado </ri>
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     08/12/2003
-------------------------------------------------------------------------------------- */
Declare @iMinRecno integer
Declare @iMaxRecno integer
begin
   
   select @iMinRecno = 0
   select @iMaxRecno = 0
   select @OUT_RESULTADO = '0'
   
   If @IN_DESTINO = 'CTU' begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTU###
       where CTU_FILIAL between @IN_FILDE and @IN_FILATE
         and CTU_DATA   between @IN_DATAMIN and @IN_DATALIM
         and CTU_IDENT  = @IN_IDENT
         and CTU_TPSALD = @IN_TPSALDO
         and ( ( CTU_MOEDA  = @IN_MOEDA AND @IN_LMOEDAESP = '1' ) OR @IN_LMOEDAESP = '0' )
         and (( @IN_REPROC  = '1' and CTU_SLCOMP != 'S') or @IN_REPROC = '0')
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            
            begin tran
            If @IN_MVCTB190D = '1' begin
               /*---------------------------------------------------------------
                 Apagar os saldos a atualizar no CTU
                 --------------------------------------------------------------- */
               If @IN_INTEGRIDADE = '1' begin
                  UpDate CTU###
                     Set D_E_L_E_T_ = '*'
                   Where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 2000
                     and CTU_FILIAL between @IN_FILDE  and @IN_FILATE
                     and CTU_IDENT   = @IN_IDENT
                     and CTU_TPSALD  = @IN_TPSALDO
                     and ( ( CTU_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                     and CTU_DATA    between @IN_DATAMIN and @IN_DATALIM
                     and (( @IN_REPROC  = '1' and CTU_SLCOMP != 'S') or @IN_REPROC = '0')
                  
                  Delete From CTU###
                        Where  R_E_C_N_O_ between @iMinRecno and @iMinRecno + 2000
                          and CTU_FILIAL between @IN_FILDE and @IN_FILATE
                          and CTU_IDENT   = @IN_IDENT
                          and CTU_TPSALD  = @IN_TPSALDO
                          and ( ( CTU_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                          and CTU_DATA    between @IN_DATAMIN and @IN_DATALIM
                          and (( @IN_REPROC  = '1' and CTU_SLCOMP != 'S') or @IN_REPROC = '0')
                          and D_E_L_E_T_  = '*'
               end else begin
                  Delete From CTU###
                        Where  R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 2000
                          and CTU_FILIAL between @IN_FILDE and @IN_FILATE
                          and CTU_IDENT   = @IN_IDENT
                          and CTU_TPSALD  = @IN_TPSALDO
                          and ( ( CTU_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                          and CTU_DATA    between @IN_DATAMIN and @IN_DATALIM
                          and (( @IN_REPROC  = '1' and CTU_SLCOMP != 'S') or @IN_REPROC = '0')
               End
            end else begin
               /*----------------------
                 Marcar como deletado  
                 ---------------------- */
               UpDate CTU###
                  Set D_E_L_E_T_ = '*'
                  ##FIELDP01( 'CTU.R_E_C_D_E_L_' )
                     , R_E_C_D_E_L_ = R_E_C_N_O_
                  ##ENDFIELDP01
                Where  R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 2000
                  and CTU_FILIAL between @IN_FILDE and @IN_FILATE
                  and CTU_IDENT   = @IN_IDENT
                  and CTU_TPSALD  = @IN_TPSALDO
                  and ( ( CTU_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP =  '0' )
                  and CTU_DATA    between @IN_DATAMIN and @IN_DATALIM
                  and (( @IN_REPROC  = '1' and CTU_SLCOMP != 'S') or @IN_REPROC = '0')
                  and D_E_L_E_T_  = ' '
            end
            commit tran
            select @iMinRecno = @iMinRecno + 2000
         End  -- While
      End
   End
   
   If @IN_DESTINO = 'CTV' begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTV###
       where CTV_FILIAL between @IN_FILDE and @IN_FILATE
         and CTV_DATA   between @IN_DATAMIN and @IN_DATALIM
         and CTV_TPSALD = @IN_TPSALDO
         and ( ( CTV_MOEDA  = @IN_MOEDA AND @IN_LMOEDAESP = '1' ) OR @IN_LMOEDAESP = '0' )
         and (( @IN_REPROC  = '1' and CTV_SLCOMP != 'S') or @IN_REPROC = '0')
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin

            begin tran
            If @IN_MVCTB190D = '1' begin
               /*---------------------------------------------------------------
                 Apagar os saldos a atualizar no CTV
                 --------------------------------------------------------------- */
               If @IN_INTEGRIDADE = '1' begin
                  Update CTV###
                     Set D_E_L_E_T_ = '*'
                   Where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 2000
                     and CTV_FILIAL between @IN_FILDE and @IN_FILATE
                     and CTV_TPSALD  = @IN_TPSALDO
                     and ( ( CTV_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                     and CTV_DATA    between @IN_DATAMIN and @IN_DATALIM
                     and (( @IN_REPROC  = '1' and CTV_SLCOMP != 'S') or @IN_REPROC = '0')
                     and D_E_L_E_T_  = ' '
                  
                  Delete From CTV###
                        Where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 2000
                          and CTV_FILIAL between @IN_FILDE and @IN_FILATE
                          and CTV_TPSALD  = @IN_TPSALDO
                          and ( ( CTV_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                          and CTV_DATA    between @IN_DATAMIN and @IN_DATALIM
                          and (( @IN_REPROC  = '1' and CTV_SLCOMP != 'S') or @IN_REPROC = '0')
                          and D_E_L_E_T_  = '*'
               end else begin
                  Delete From CTV###
                        Where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 2000
                          and CTV_FILIAL between @IN_FILDE and @IN_FILATE
                          and CTV_TPSALD  = @IN_TPSALDO
                          and ( ( CTV_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                          and CTV_DATA    between @IN_DATAMIN and @IN_DATALIM
                          and (( @IN_REPROC  = '1' and CTV_SLCOMP != 'S') or @IN_REPROC = '0')
               End
            end else begin
               /*----------------------
                 Marcar como deletado  
                 ---------------------- */
               Update CTV###
                  Set D_E_L_E_T_ = '*'
                     ##FIELDP02( 'CTV.R_E_C_D_E_L_' )
                        , R_E_C_D_E_L_ = R_E_C_N_O_
                     ##ENDFIELDP02
                Where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 2000
                  and CTV_FILIAL between @IN_FILDE and @IN_FILATE
                  and CTV_TPSALD  = @IN_TPSALDO
                  and ( ( CTV_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                  and CTV_DATA    between @IN_DATAMIN and @IN_DATALIM
                  and (( @IN_REPROC  = '1' and CTV_SLCOMP != 'S') or @IN_REPROC = '0')
                  and D_E_L_E_T_  = ' '
            end
            commit tran
            select @iMinRecno = @iMinRecno + 2000
         End
      End
   End
   If @IN_DESTINO = 'CTW' begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTW###
       where CTW_FILIAL between @IN_FILDE and @IN_FILATE
         and CTW_DATA   between @IN_DATAMIN and @IN_DATALIM
         and CTW_TPSALD = @IN_TPSALDO
         and ( ( CTW_MOEDA  = @IN_MOEDA AND @IN_LMOEDAESP = '1' ) OR @IN_LMOEDAESP = '0' )
         and (( @IN_REPROC  = '1' and CTW_SLCOMP != 'S') or @IN_REPROC = '0')
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
         
            begin tran
            If @IN_MVCTB190D = '1' begin
               /*---------------------------------------------------------------
                 Apagar os saldos a atualizar no CTW
                 --------------------------------------------------------------- */
               If @IN_INTEGRIDADE = '1' begin
                  UpDate CTW###
                     Set D_E_L_E_T_ = '*'
                   Where CTW_FILIAL between @IN_FILDE and @IN_FILATE
                     and CTW_TPSALD  = @IN_TPSALDO
                     and ( ( CTW_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                     and CTW_DATA    between @IN_DATAMIN and @IN_DATALIM
                     and (( @IN_REPROC  = '1' and CTW_SLCOMP != 'S') or @IN_REPROC = '0')
                     and D_E_L_E_T_  = ' '
                  
                  Delete From CTW###
                        Where CTW_FILIAL between @IN_FILDE and @IN_FILATE
                          and CTW_TPSALD  = @IN_TPSALDO
                          and ( ( CTW_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                          and CTW_DATA    between @IN_DATAMIN and @IN_DATALIM
                          and (( @IN_REPROC  = '1' and CTW_SLCOMP != 'S') or @IN_REPROC = '0')
                          and D_E_L_E_T_  = '*'
               end else begin
                  Delete From CTW###
                        Where CTW_FILIAL between @IN_FILDE and @IN_FILATE
                          and CTW_TPSALD  = @IN_TPSALDO
                          and ( ( CTW_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                          and CTW_DATA    between @IN_DATAMIN and @IN_DATALIM
                          and (( @IN_REPROC  = '1' and CTW_SLCOMP != 'S') or @IN_REPROC = '0')
               end
            end else begin
               /*----------------------
                 Marcar como deletado  
                 ---------------------- */
               UpDate CTW###
                  Set D_E_L_E_T_ = '*'
                     ##FIELDP03( 'CTW.R_E_C_D_E_L_' )
                        , R_E_C_D_E_L_ = R_E_C_N_O_
                     ##ENDFIELDP03
                Where CTW_FILIAL between @IN_FILDE and @IN_FILATE
                  and CTW_TPSALD  = @IN_TPSALDO
                  and ( ( CTW_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                  and CTW_DATA    between @IN_DATAMIN and @IN_DATALIM
                  and (( @IN_REPROC  = '1' and CTW_SLCOMP != 'S') or @IN_REPROC = '0')
                  and D_E_L_E_T_  = ' '
            end
            commit tran
            select @iMinRecno = @iMinRecno + 2000
         End  -- While
      End
   End
   If @IN_DESTINO = 'CTX' begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTX###
       where CTX_FILIAL between @IN_FILDE and @IN_FILATE
         and CTX_DATA   between @IN_DATAMIN and @IN_DATALIM
         and CTX_TPSALD = @IN_TPSALDO
         and ( ( CTX_MOEDA  = @IN_MOEDA AND @IN_LMOEDAESP = '1' ) OR @IN_LMOEDAESP = '0' )
         and (( @IN_REPROC  = '1' and CTX_SLCOMP != 'S') or @IN_REPROC = '0')
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin

            begin tran
            If @IN_MVCTB190D = '1' begin
               /*---------------------------------------------------------------
                 Apagar os saldos a atualizar no CTX
                 --------------------------------------------------------------- */
               If @IN_INTEGRIDADE = '1' begin
                  Update CTX###
                     Set D_E_L_E_T_ = '*'
                   Where CTX_FILIAL between @IN_FILDE and @IN_FILATE
                     and CTX_TPSALD  = @IN_TPSALDO
                     and ( ( CTX_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                     and CTX_DATA    between @IN_DATAMIN and @IN_DATALIM
                     and (( @IN_REPROC  = '1' and CTX_SLCOMP != 'S') or @IN_REPROC = '0')
                     and D_E_L_E_T_  = ' '
                  
                  Delete From CTX###
                        Where CTX_FILIAL between @IN_FILDE and @IN_FILATE
                          and CTX_TPSALD  = @IN_TPSALDO
                          and ( ( CTX_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                          and CTX_DATA    between @IN_DATAMIN and @IN_DATALIM
                          and (( @IN_REPROC  = '1' and CTX_SLCOMP != 'S') or @IN_REPROC = '0')
                          and D_E_L_E_T_  = '*'
               end else begin
                  Delete From CTX###
                        Where CTX_FILIAL between @IN_FILDE and @IN_FILATE
                          and CTX_TPSALD  = @IN_TPSALDO
                          and ( ( CTX_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                          and CTX_DATA    between @IN_DATAMIN and @IN_DATALIM
                          and (( @IN_REPROC  = '1' and CTX_SLCOMP != 'S') or @IN_REPROC = '0')
               end
            end else begin
               /*----------------------
                 Marcar como deletado  
                 ---------------------- */
               Update CTX###
                  Set D_E_L_E_T_ = '*'
                     ##FIELDP04( 'CTX.R_E_C_D_E_L_' )
                        , R_E_C_D_E_L_ = R_E_C_N_O_
                     ##ENDFIELDP04
                Where CTX_FILIAL between @IN_FILDE and @IN_FILATE
                  and CTX_TPSALD  = @IN_TPSALDO
                  and ( ( CTX_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                  and CTX_DATA    between @IN_DATAMIN and @IN_DATALIM
                  and (( @IN_REPROC  = '1' and CTX_SLCOMP != 'S') or @IN_REPROC = '0')
                  and D_E_L_E_T_  = ' '
            end
            commit tran
            select @iMinRecno = @iMinRecno + 2000
         End  -- While
      End
   End
   If @IN_DESTINO = 'CTY' begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTY###
       where CTY_FILIAL between @IN_FILDE and @IN_FILATE
         and CTY_DATA   between @IN_DATAMIN and @IN_DATALIM
         and CTY_TPSALD = @IN_TPSALDO
         and ( ( CTY_MOEDA  = @IN_MOEDA AND @IN_LMOEDAESP = '1' ) OR @IN_LMOEDAESP = '0' )
         and (( @IN_REPROC  = '1' and CTY_SLCOMP != 'S') or @IN_REPROC = '0')
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin

            begin tran
            If @IN_MVCTB190D = '1' begin
               /*---------------------------------------------------------------
                 Apagar os saldos a atualizar no CTY
                 --------------------------------------------------------------- */
               If @IN_INTEGRIDADE = '1' begin
                  Update CTY###
                     Set D_E_L_E_T_= '*'
                   Where CTY_FILIAL between @IN_FILDE and @IN_FILATE
                     and CTY_TPSALD  = @IN_TPSALDO
                     and ( ( CTY_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                     and CTY_DATA    between @IN_DATAMIN and @IN_DATALIM
                     and (( @IN_REPROC  = '1' and CTY_SLCOMP != 'S') or @IN_REPROC = '0')
                     and D_E_L_E_T_  = ' '
                  
                  Delete From CTY###
                        Where CTY_FILIAL between @IN_FILDE and @IN_FILATE
                          and CTY_TPSALD  = @IN_TPSALDO
                          and ( ( CTY_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                          and CTY_DATA    between @IN_DATAMIN and @IN_DATALIM
                          and (( @IN_REPROC  = '1' and CTY_SLCOMP != 'S') or @IN_REPROC = '0')
                          and D_E_L_E_T_  = '*'
               end else begin
                  Delete From CTY###
                        Where CTY_FILIAL between @IN_FILDE and @IN_FILATE
                          and CTY_TPSALD  = @IN_TPSALDO
                          and ( ( CTY_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                          and CTY_DATA    between @IN_DATAMIN and @IN_DATALIM
                          and (( @IN_REPROC  = '1' and CTY_SLCOMP != 'S') or @IN_REPROC = '0')
               end
            end else begin
               /*----------------------
                 Marcar como deletado  
                 ---------------------- */
               Update CTY###
                  Set D_E_L_E_T_= '*'
                     ##FIELDP05( 'CTY.R_E_C_D_E_L_' )
                        , R_E_C_D_E_L_ = R_E_C_N_O_
                     ##ENDFIELDP05
                Where CTY_FILIAL between @IN_FILDE and @IN_FILATE
                  and CTY_TPSALD  = @IN_TPSALDO
                  and ( ( CTY_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                  and CTY_DATA    between @IN_DATAMIN and @IN_DATALIM
                  and (( @IN_REPROC  = '1' and CTY_SLCOMP != 'S') or @IN_REPROC = '0')
                  and D_E_L_E_T_  = ' '
            end
            commit tran
            select @iMinRecno = @iMinRecno + 2000
         End  -- While
      End
   End
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
     --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end
