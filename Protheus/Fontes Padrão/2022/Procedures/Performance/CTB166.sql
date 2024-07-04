Create procedure CTB166_##
 ( 
  @IN_CALIAS       Char(03),
  @IN_MOEDAESP     Char(01),
  @IN_MOEDA        Char( 'CQ0_MOEDA' ),
  @IN_TPSALDO      char( 'CQ0_TPSALD' ),
  @IN_FILIAL       Char( 'CQ0_FILIAL' ),
  @IN_DATADE       Char( 08 ),
  @IN_DATAATE      Char( 08 ),
  @IN_INTEGRIDADE  Char( 01 ),
  @IN_MVCTB190D    Char( 01 ),
  @IN_CONTA        Char( 'CQ0_CONTA' ),
  @IN_IDENT        Char( 03 ),
  @IN_CODIGO       Char( 'CQ8_CODIGO' ),
  @OUT_RESULTADO   Char( 01 ) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P11 </v>
    Assinatura      - <a>  000 </a>
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Zera os arquivos a serem posteriormente reprocessados </d>
    Funcao do Siga  -     
    Fonte Microsiga - <s> CTBA192.PRW </s>
    Entrada         - <ri> @IN_CALIAS       - Alias do arquivo a ser processado
                           @IN_MOEDAESP     - Define se eh moeda especifica
                           @IN_MOEDA        - Moeda
                           @IN_TPSALDO      - Tipo de Saldo
                           @IN_FILIAL       - Filial do processo
                           @IN_DATADE       - Data de
                           @IN_DATAATE      - Data Ate
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada.  
                           @IN_MVCTB190D    - '1' exclui fisicamente, '0' marca como deletado
                           @IN_CONTA        - Conta a Processar
                           @IN_CODIGO       - entida de a exckuir
                           @IN_IDENT        - Identificador para tabelas CQ8/CQ9                       </ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r> Alice Y Yamamoto </r>
    Data        :     13/06/07
-------------------------------------------------------------------------------------- */
declare @iMinRecno   integer
declare @iMaxRecno   integer
declare @cFilial_CTC char( 'CTC_FILIAL' )
declare @cFilial_CT2 char( 'CT2_FILIAL' )
declare @cFilial_CQ0 char( 'CQ0_FILIAL' )
declare @cFilial_CQ1 char( 'CQ1_FILIAL' )
declare @cFilial_CQ2 char( 'CQ2_FILIAL' )
declare @cFilial_CQ3 char( 'CQ3_FILIAL' )
declare @cFilial_CQ4 char( 'CQ4_FILIAL' )
declare @cFilial_CQ5 char( 'CQ5_FILIAL' )
declare @cFilial_CQ6 char( 'CQ6_FILIAL' )
declare @cFilial_CQ7 char( 'CQ7_FILIAL' )
declare @cFilial_CQ8 char( 'CQ6_FILIAL' )
declare @cFilial_CQ9 char( 'CQ7_FILIAL' )
declare @cAux        char(03)

begin
   
   /* -------------------------------------------------------------------------
      Zera a tabela CQ0
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ0' ) begin
      select @cAux = 'CQ0'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CQ0 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ0###
       where CQ0_FILIAL = @cFilial_CQ0
         and CQ0_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ0_TPSALD = @IN_TPSALDO
         and ( ( CQ0_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
         and CQ0_CONTA = @IN_CONTA
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               If @IN_INTEGRIDADE = '1' begin
                  /* -------------------------------------------------------------------------
                     Zera a tabela CQ0
                     -------------------------------------------------------------------------*/
                  UpDate CQ0###
                     Set D_E_L_E_T_ = '*'
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ0_FILIAL = @cFilial_CQ0
                     and CQ0_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ0_TPSALD = @IN_TPSALDO
                     and ( ( CQ0_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ0_CONTA = @IN_CONTA
                  delete
                    from CQ0###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ0_FILIAL = @cFilial_CQ0
                     and CQ0_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ0_TPSALD = @IN_TPSALDO
                     and ( ( CQ0_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ0_CONTA = @IN_CONTA
                     and D_E_L_E_T_ = '*'
               end else begin
                  delete
                    from CQ0###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ0_FILIAL = @cFilial_CQ0
                     and CQ0_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ0_TPSALD = @IN_TPSALDO
                     and ( ( CQ0_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ0_CONTA = @IN_CONTA
               end
            end else begin
               /* ----------------------
                  Marcar como deletado   
                  ---------------------- */
               UpDate CQ0###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP01( 'CQ0.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP01
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and CQ0_FILIAL = @cFilial_CQ0
                  and CQ0_DATA   between @IN_DATADE   and @IN_DATAATE
                  and CQ0_TPSALD = @IN_TPSALDO
                  and ( ( CQ0_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  and CQ0_CONTA = @IN_CONTA
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
      /* -------------------------------------------------------------------------
      Zera a tabela CQ1
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ1' ) begin
      select @cAux = 'CQ1'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CQ1 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ1###
       where CQ1_FILIAL = @cFilial_CQ1
         and CQ1_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ1_TPSALD = @IN_TPSALDO
         and ( ( CQ1_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
         and CQ1_CONTA = @IN_CONTA
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               If @IN_INTEGRIDADE = '1' begin
                  /* -------------------------------------------------------------------------
                     Zera a tabela CQ1
                     -------------------------------------------------------------------------*/
                  UpDate CQ1###
                     Set D_E_L_E_T_ = '*'
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ1_FILIAL = @cFilial_CQ1
                     and CQ1_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ1_TPSALD = @IN_TPSALDO
                     and ( ( CQ1_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ1_CONTA = @IN_CONTA
                  delete
                    from CQ1###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ1_FILIAL = @cFilial_CQ1
                     and CQ1_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ1_TPSALD = @IN_TPSALDO
                     and ( ( CQ1_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ1_CONTA = @IN_CONTA
                     and D_E_L_E_T_ = '*'
               end else begin
                  delete
                    from CQ1###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ1_FILIAL = @cFilial_CQ1
                     and CQ1_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ1_TPSALD = @IN_TPSALDO
                     and ( ( CQ1_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ1_CONTA = @IN_CONTA
               end
            end else begin
               /* ----------------------
                  Marcar como deletado   
                  ---------------------- */
               UpDate CQ1###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP01( 'CQ1.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP01
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and CQ1_FILIAL = @cFilial_CQ1
                  and CQ1_DATA   between @IN_DATADE   and @IN_DATAATE
                  and CQ1_TPSALD = @IN_TPSALDO
                  and ( ( CQ1_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  and CQ1_CONTA = @IN_CONTA
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela CQ2 -CCustos
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ2' ) begin
      select @cAux = 'CQ2'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CQ2 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ2###
       where CQ2_FILIAL = @cFilial_CQ2
         and CQ2_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ2_TPSALD = @IN_TPSALDO
         and ( ( CQ2_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
         and CQ2_CONTA = @IN_CONTA
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               If @IN_INTEGRIDADE = '1' begin
                  /* -------------------------------------------------------------------------
                     Zera a tabela CQ2
                     -------------------------------------------------------------------------*/
                  UpDate CQ2###
                     Set D_E_L_E_T_ = '*'
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ2_FILIAL = @cFilial_CQ2
                     and CQ2_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ2_TPSALD = @IN_TPSALDO
                     and ( ( CQ2_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ2_CONTA = @IN_CONTA
                  delete
                    from CQ2###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ2_FILIAL = @cFilial_CQ2
                     and CQ2_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ2_TPSALD = @IN_TPSALDO
                     and ( ( CQ2_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ2_CONTA = @IN_CONTA
                     and D_E_L_E_T_ = '*'
               end else begin
                  delete
                    from CQ2###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ2_FILIAL = @cFilial_CQ2
                     and CQ2_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ2_TPSALD = @IN_TPSALDO
                     and ( ( CQ2_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ2_CONTA = @IN_CONTA
               end
            end else begin
               /* ----------------------
                  Marcar como deletado   
                  ---------------------- */
               UpDate CQ2###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP02( 'CQ2.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP02
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and CQ2_FILIAL = @cFilial_CQ2
                  and CQ2_DATA   between @IN_DATADE   and @IN_DATAATE
                  and CQ2_TPSALD = @IN_TPSALDO
                  and ( ( CQ2_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  and CQ2_CONTA = @IN_CONTA
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela CQ3 - CCustos
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ3' ) begin
      select @cAux = 'CQ3'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CQ3 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ3###
       where CQ3_FILIAL = @cFilial_CQ3
         and CQ3_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ3_TPSALD = @IN_TPSALDO
         and ( ( CQ3_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
         and CQ3_CONTA = @IN_CONTA
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               If @IN_INTEGRIDADE = '1' begin
                  /* -------------------------------------------------------------------------
                     Zera a tabela CQ3
                     -------------------------------------------------------------------------*/
                  UpDate CQ3###
                     Set D_E_L_E_T_ = '*'
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ3_FILIAL = @cFilial_CQ3
                     and CQ3_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ3_TPSALD = @IN_TPSALDO
                     and ( ( CQ3_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ3_CONTA = @IN_CONTA
                  delete
                    from CQ3###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ3_FILIAL = @cFilial_CQ3
                     and CQ3_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ3_TPSALD = @IN_TPSALDO
                     and ( ( CQ3_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ3_CONTA = @IN_CONTA
                     and D_E_L_E_T_ = '*'
               end else begin
                  delete
                    from CQ3###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ3_FILIAL = @cFilial_CQ3
                     and CQ3_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ3_TPSALD = @IN_TPSALDO
                     and ( ( CQ3_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ3_CONTA = @IN_CONTA
               end
            end else begin
               /* ----------------------
                  Marcar como deletado   
                  ---------------------- */
               UpDate CQ3###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP02( 'CQ3.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP02
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and CQ3_FILIAL = @cFilial_CQ3
                  and CQ3_DATA   between @IN_DATADE   and @IN_DATAATE
                  and CQ3_TPSALD = @IN_TPSALDO
                  and ( ( CQ3_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  and CQ3_CONTA = @IN_CONTA
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela item contabil Mes - CQ4
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ4' ) begin
      select @cAux = 'CQ4'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CQ4 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ4###
       where CQ4_FILIAL = @cFilial_CQ4
         and CQ4_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ4_TPSALD = @IN_TPSALDO
         and ( ( CQ4_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
         and CQ4_CONTA = @IN_CONTA
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               /* -------------------------------------------------------------------------
                  Zera a tabela CQ4
                  -------------------------------------------------------------------------*/
               if @IN_INTEGRIDADE = '1' begin
                  UpDate CQ4###
                     Set D_E_L_E_T_ = '*'
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ4_FILIAL = @cFilial_CQ4
                     and CQ4_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ4_TPSALD = @IN_TPSALDO
                     and ( ( CQ4_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ4_CONTA = @IN_CONTA
                  
                  delete
                    from CQ4###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ4_FILIAL = @cFilial_CQ4
                     and CQ4_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ4_TPSALD = @IN_TPSALDO
                     and ( ( CQ4_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ4_CONTA = @IN_CONTA
                     and D_E_L_E_T_ = '*'
               end else begin
                  delete
                    from CQ4###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ4_FILIAL = @cFilial_CQ4
                     and CQ4_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ4_TPSALD = @IN_TPSALDO
                     and ( ( CQ4_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ4_CONTA = @IN_CONTA
                     and D_E_L_E_T_ = ' '
               end
            end else begin
               /* ----------------------
                  Marcar como deletado   
                  ---------------------- */
               UpDate CQ4###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP03( 'CQ4.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP03
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and CQ4_FILIAL = @cFilial_CQ4
                  and CQ4_DATA   between @IN_DATADE   and @IN_DATAATE
                  and CQ4_TPSALD = @IN_TPSALDO
                  and ( ( CQ4_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  and CQ4_CONTA = @IN_CONTA
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela item contabil Dia - CQ5
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ5' ) begin
      select @cAux = 'CQ5'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CQ5 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ5###
       where CQ5_FILIAL = @cFilial_CQ5
         and CQ5_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ5_TPSALD = @IN_TPSALDO
         and ( ( CQ5_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
         and CQ5_CONTA = @IN_CONTA
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               /* -------------------------------------------------------------------------
                  Zera a tabela CQ5
                  -------------------------------------------------------------------------*/
               if @IN_INTEGRIDADE = '1' begin
                  UpDate CQ5###
                     Set D_E_L_E_T_ = '*'
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ5_FILIAL = @cFilial_CQ5
                     and CQ5_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ5_TPSALD = @IN_TPSALDO
                     and ( ( CQ5_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ5_CONTA = @IN_CONTA
                  
                  delete
                    from CQ5###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ5_FILIAL = @cFilial_CQ5
                     and CQ5_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ5_TPSALD = @IN_TPSALDO
                     and ( ( CQ5_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ5_CONTA = @IN_CONTA
                     and D_E_L_E_T_ = '*'
               end else begin
                  delete
                    from CQ5###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ5_FILIAL = @cFilial_CQ5
                     and CQ5_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ5_TPSALD = @IN_TPSALDO
                     and ( ( CQ5_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ5_CONTA = @IN_CONTA
                     and D_E_L_E_T_ = ' '
               end
            end else begin
               /* ----------------------
                  Marcar como deletado   
                  ---------------------- */
               UpDate CQ5###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP03( 'CQ5.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP03
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and CQ5_FILIAL = @cFilial_CQ5
                  and CQ5_DATA   between @IN_DATADE   and @IN_DATAATE
                  and CQ5_TPSALD = @IN_TPSALDO
                  and ( ( CQ5_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  and CQ5_CONTA = @IN_CONTA
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela clvl Mes CQ6
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ6' ) begin
      select @cAux = 'CQ6'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CQ6 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ6###
       where CQ6_FILIAL = @cFilial_CQ6
         and CQ6_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ6_TPSALD = @IN_TPSALDO
         and ( ( CQ6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
         and CQ6_CONTA = @IN_CONTA
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               If @IN_INTEGRIDADE = '1' begin
                  UpDate CQ6###
                     Set D_E_L_E_T_ = '*'
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ6_FILIAL = @cFilial_CQ6
                     and CQ6_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ6_TPSALD = @IN_TPSALDO
                     and ( ( CQ6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ6_CONTA = @IN_CONTA
                  
                  delete
                    from CQ6###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ6_FILIAL = @cFilial_CQ6
                     and CQ6_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ6_TPSALD = @IN_TPSALDO
                     and ( ( CQ6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ6_CONTA = @IN_CONTA
                     and D_E_L_E_T_ = '*'
               end else begin
                  delete
                    from CQ6###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ6_FILIAL = @cFilial_CQ6
                     and CQ6_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ6_TPSALD = @IN_TPSALDO
                     and ( ( CQ6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ6_CONTA = @IN_CONTA
               end
            end else begin
               /* ----------------------
                  Marcar como deletado   
                  ---------------------- */
               UpDate CQ6###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP04( 'CQ6.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP04
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and CQ6_FILIAL = @cFilial_CQ6
                  and CQ6_DATA   between @IN_DATADE   and @IN_DATAATE
                  and CQ6_TPSALD = @IN_TPSALDO
                  and ( ( CQ6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  and CQ6_CONTA = @IN_CONTA
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela clvl Dia CQ7
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ7' ) begin
      select @cAux = 'CQ7'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CQ7 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ7###
       where CQ7_FILIAL = @cFilial_CQ7
         and CQ7_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ7_TPSALD = @IN_TPSALDO
         and ( ( CQ7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
         and CQ7_CONTA = @IN_CONTA
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               If @IN_INTEGRIDADE = '1' begin
                  UpDate CQ7###
                     Set D_E_L_E_T_ = '*'
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ7_FILIAL = @cFilial_CQ7
                     and CQ7_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ7_TPSALD = @IN_TPSALDO
                     and ( ( CQ7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ7_CONTA = @IN_CONTA
                  
                  delete
                    from CQ7###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ7_FILIAL = @cFilial_CQ7
                     and CQ7_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ7_TPSALD = @IN_TPSALDO
                     and ( ( CQ7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ7_CONTA = @IN_CONTA
                     and D_E_L_E_T_ = '*'
               end else begin
                  delete
                    from CQ7###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ7_FILIAL = @cFilial_CQ7
                     and CQ7_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ7_TPSALD = @IN_TPSALDO
                     and ( ( CQ7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ7_CONTA = @IN_CONTA
               end
            end else begin
               /* ----------------------
                  Marcar como deletado   
                  ---------------------- */
               UpDate CQ7###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP04( 'CQ7.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP04
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and CQ7_FILIAL = @cFilial_CQ7
                  and CQ7_DATA   between @IN_DATADE   and @IN_DATAATE
                  and CQ7_TPSALD = @IN_TPSALDO
                  and ( ( CQ7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  and CQ7_CONTA = @IN_CONTA
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela Entidades CQ8
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ8' ) begin
      select @cAux = 'CQ8'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CQ8 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ8###
       where CQ8_FILIAL = @cFilial_CQ8
         and CQ8_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ8_TPSALD = @IN_TPSALDO
         and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
         and CQ8_IDENT = @IN_IDENT
         and CQ8_CODIGO = @IN_CODIGO
      
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
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ8_FILIAL = @cFilial_CQ8
                     and CQ8_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ8_TPSALD = @IN_TPSALDO
                     and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ8_IDENT = @IN_IDENT
                     and CQ8_CODIGO = @IN_CODIGO
                  
                  delete
                    from CQ8###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ8_FILIAL = @cFilial_CQ8
                     and CQ8_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ8_TPSALD = @IN_TPSALDO
                     and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ8_IDENT = @IN_IDENT
                     and CQ8_CODIGO = @IN_CODIGO
                     and D_E_L_E_T_ = '*'
               end else begin
                  delete
                    from CQ8###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ8_FILIAL = @cFilial_CQ8
                     and CQ8_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ8_TPSALD = @IN_TPSALDO
                     and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ8_IDENT = @IN_IDENT
                     and CQ8_CODIGO = @IN_CODIGO
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
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and CQ8_FILIAL = @cFilial_CQ8
                  and CQ8_DATA   between @IN_DATADE   and @IN_DATAATE
                  and CQ8_TPSALD = @IN_TPSALDO
                  and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  and CQ8_IDENT = @IN_IDENT
                  and CQ8_CODIGO = @IN_CODIGO
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela Entidades CQ9
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ9' ) begin
      select @cAux = 'CQ9'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CQ9 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ9###
       where CQ9_FILIAL = @cFilial_CQ9
         and CQ9_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ9_TPSALD = @IN_TPSALDO
         and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
         and CQ9_IDENT = @IN_IDENT
         and CQ9_CODIGO = @IN_CODIGO
         
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
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ9_FILIAL = @cFilial_CQ9
                     and CQ9_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ9_TPSALD = @IN_TPSALDO
                     and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ9_IDENT = @IN_IDENT
                     and CQ9_CODIGO = @IN_CODIGO
                  
                  delete
                    from CQ9###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ9_FILIAL = @cFilial_CQ9
                     and CQ9_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ9_TPSALD = @IN_TPSALDO
                     and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ9_IDENT = @IN_IDENT
                     and CQ9_CODIGO = @IN_CODIGO
                     and D_E_L_E_T_ = '*'
               end else begin
                  delete
                    from CQ9###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ9_FILIAL = @cFilial_CQ9
                     and CQ9_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CQ9_TPSALD = @IN_TPSALDO
                     and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and CQ9_IDENT = @IN_IDENT
                     and CQ9_CODIGO = @IN_CODIGO
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
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and CQ9_FILIAL = @cFilial_CQ9
                  and CQ9_DATA   between @IN_DATADE   and @IN_DATAATE
                  and CQ9_TPSALD = @IN_TPSALDO
                  and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  and CQ9_IDENT = @IN_IDENT
                  and CQ9_CODIGO = @IN_CODIGO
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela CTC
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CTC' ) begin
      select @cAux = 'CTC'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_CTC OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTC###
       where CTC_FILIAL = @cFilial_CTC
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
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CTC_FILIAL = @cFilial_CTC
                     and CTC_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CTC_TPSALD = @IN_TPSALDO
                     and ( ( CTC_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  
                  delete
                    from CTC###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CTC_FILIAL = @cFilial_CTC
                     and CTC_DATA   between @IN_DATADE   and @IN_DATAATE
                     and CTC_TPSALD = @IN_TPSALDO
                     and ( ( CTC_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     and D_E_L_E_T_ = '*'
               end else begin
                  delete
                    from CTC###
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CTC_FILIAL = @cFilial_CTC
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
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and CTC_FILIAL = @cFilial_CTC
                  and CTC_DATA   between @IN_DATADE   and @IN_DATAATE
                  and CTC_TPSALD = @IN_TPSALDO
                  and ( ( CTC_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
   select @OUT_RESULTADO = '1'
end
