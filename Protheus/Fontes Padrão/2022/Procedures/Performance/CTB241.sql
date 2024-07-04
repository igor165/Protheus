Create procedure CTB241_##
 ( 
  @IN_CALIAS       Char(03),
  @IN_MOEDAESP     Char(01),
  @IN_MOEDA        Char( 'CQ0_MOEDA' ),
  @IN_TPSALDO      char( 'CQ0_TPSALD' ),
  @IN_FILDE        Char( 'CQ0_FILIAL' ),
  @IN_FILATE       Char( 'CQ0_FILIAL' ),
  @IN_DATADE       Char( 08 ),
  @IN_DATAATE      Char( 08 ),
  @IN_INTEGRIDADE  Char( 01 ),
  @IN_MVCTB190D    Char( 01 ),
  @IN_IDENT        Char( 03 ),
  @OUT_RESULTADO   Char( 01 ) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P12 </v>
    Assinatura      - <a>  000 </a>
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Zera os arquivos a serem posteriormente reprocessados </d>
    Funcao do Siga  -     
    Fonte Microsiga - <s> CTBA192.PRW </s>
    Entrada         - <ri> @IN_CALIAS       - Alias do arquivo a ser processado
                           @IN_MOEDAESP     - Define se eh moeda especifica
                           @IN_MOEDA        - Moeda
                           @IN_TPSALDO      - Tipo de Saldo
                           @IN_FILDE        - Filial Inico
                           @IN_FILATE       - Filial fim
                           @IN_DATADE       - Data de
                           @IN_DATAATE      - Data Ate
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada.  
                           @IN_MVCTB190D    - '1' exclui fisicamente, '0' marca como deletado
                           @IN_IDENT        - Identificador para tabelas CQ8/CQ9                       </ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r> Alice Y Yamamoto </r>
    Data        :     13/06/07   
   -------------------------------------------------------------------------------------- */
declare @iMinRecno   integer
declare @iMaxRecno   integer
Declare @iLinhas     integer
Declare @cAux        Char( 03 )
Declare @cFilial_CTC char( 'CTC_FILIAL' )
Declare @cFilial_CQ8 char( 'CQ8_FILIAL' )
Declare @cFilial_CQ9 char( 'CQ9_FILIAL' )

begin
   select @OUT_RESULTADO = '0'
   select @iLinhas = 1024
   select @iMinRecno = 0
   select @iMaxRecno = 0
   /* -------------------------------------------------------------------------
      Zera a tabela CTC
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CTC' ) begin
      
      select @cAux = 'CTC'
      exec XFILIAL_## @cAux, @IN_FILDE, @cFilial_CTC OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTC###
       where CTC_FILIAL between @cFilial_CTC and @IN_FILATE
         and CTC_DATA   between @IN_DATADE   and @IN_DATAATE
         and CTC_TPSALD = @IN_TPSALDO
         and ( ( CTC_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------------
               Exclui fisicamente
               ---------------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               If @IN_INTEGRIDADE = '1' begin
                  UpDate CTC###
                     Set D_E_L_E_T_ = '*'
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
                     and CTC_FILIAL between @cFilial_CTC and @IN_FILATE
                     and CTC_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CTC_TPSALD = @IN_TPSALDO
                     and ( ( CTC_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  
                  delete
                    from CTC###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
                     and CTC_FILIAL between @cFilial_CTC and @IN_FILATE
                     and CTC_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CTC_TPSALD = @IN_TPSALDO
                     and ( ( CTC_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and D_E_L_E_T_ = '*'
               end else begin
                  delete
                    from CTC###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
                     and CTC_FILIAL between @cFilial_CTC and @IN_FILATE
                     and CTC_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CTC_TPSALD = @IN_TPSALDO
                     and ( ( CTC_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
               end
            end else begin
               /* ----------------------
                  Marcar como deletado   
                  ---------------------- */
               UpDate CTC###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP05( 'CTC.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP05
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
                  and CTC_FILIAL between @cFilial_CTC and @IN_FILATE
                  and CTC_DATA   between @IN_DATADE   and @IN_DATAATE
                  and CTC_TPSALD = @IN_TPSALDO
                  and ( ( CTC_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
            end
            commit tran
            select @iMinRecno = @iMinRecno + @iLinhas
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela Entidades CQ8
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ8' ) begin
      
      select @cAux = 'CQ8'
      exec XFILIAL_## @cAux, @IN_FILDE, @cFilial_CQ8 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ8###
       where CQ8_FILIAL between @cFilial_CQ8 and @IN_FILATE
         and CQ8_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ8_TPSALD = @IN_TPSALDO
         and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
         and CQ8_IDENT = @IN_IDENT
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               If @IN_INTEGRIDADE = '1' begin
                  UpDate CQ8###
                     Set D_E_L_E_T_ = '*'
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
                     and CQ8_FILIAL between @cFilial_CQ8 and @IN_FILATE
                     and CQ8_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ8_TPSALD = @IN_TPSALDO
                     and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ8_IDENT = @IN_IDENT
                  
                  delete
                    from CQ8###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
                     and CQ8_FILIAL between @cFilial_CQ8 and @IN_FILATE
                     and CQ8_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ8_TPSALD = @IN_TPSALDO
                     and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ8_IDENT = @IN_IDENT
                     and D_E_L_E_T_ = '*'
               end else begin
                  delete
                    from CQ8###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
                     and CQ8_FILIAL between @cFilial_CQ8 and @IN_FILATE
                     and CQ8_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ8_TPSALD = @IN_TPSALDO
                     and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ8_IDENT = @IN_IDENT
               end
            end else begin
               /* ----------------------
                  Marcar como deletado   
                  ---------------------- */
               UpDate CQ8###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP04( 'CQ8.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP04
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
                  and CQ8_FILIAL between @cFilial_CQ8 and @IN_FILATE
                  and CQ8_DATA   between @IN_DATADE   and @IN_DATAATE
                  and CQ8_TPSALD = @IN_TPSALDO
                  and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  and CQ8_IDENT = @IN_IDENT
            end
            commit tran
            select @iMinRecno = @iMinRecno + @iLinhas
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela Entidades CQ9
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ9' ) begin
      select @cAux = 'CQ9'
      exec XFILIAL_## @cAux, @IN_FILDE, @cFilial_CQ9 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ9###
       where CQ9_FILIAL between @cFilial_CQ9 and @IN_FILATE
         and CQ9_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ9_TPSALD = @IN_TPSALDO
         and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
         and CQ9_IDENT = @IN_IDENT
         
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               If @IN_INTEGRIDADE = '1' begin
                  UpDate CQ9###
                     Set D_E_L_E_T_ = '*'
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
                     and CQ9_FILIAL between @cFilial_CQ9 and @IN_FILATE
                     and CQ9_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ9_TPSALD = @IN_TPSALDO
                     and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ9_IDENT = @IN_IDENT
                  
                  delete
                    from CQ9###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
                     and CQ9_FILIAL between @cFilial_CQ9 and @IN_FILATE
                     and CQ9_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ9_TPSALD = @IN_TPSALDO
                     and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ9_IDENT = @IN_IDENT
                     and D_E_L_E_T_ = '*'
               end else begin
                  delete
                    from CQ9###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
                     and CQ9_FILIAL between @cFilial_CQ9 and @IN_FILATE
                     and CQ9_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ9_TPSALD = @IN_TPSALDO
                     and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ9_IDENT = @IN_IDENT
               end
            end else begin
               /* ----------------------
                  Marcar como deletado   
                  ---------------------- */
               UpDate CQ9###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP04( 'CQ9.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP04
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
                  and CQ9_FILIAL between @cFilial_CQ9 and @IN_FILATE
                  and CQ9_DATA   between @IN_DATADE   and @IN_DATAATE
                  and CQ9_TPSALD = @IN_TPSALDO
                  and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  and CQ9_IDENT = @IN_IDENT
            end
            commit tran
            select @iMinRecno = @iMinRecno + @iLinhas
         end
      end
   end
   select @OUT_RESULTADO = '1'
End