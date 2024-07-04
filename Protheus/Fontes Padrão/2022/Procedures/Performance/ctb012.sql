Create procedure CTB012_##
 ( 
  @IN_CALIAS       Char( 03 ),
  @IN_MOEDAESP     Char( 01 ),
  @IN_MOEDA        Char( 'CV1_MOEDA' ),
  @IN_TPSALDO      char( 'CQ0_TPSALD' ),
  @IN_FILIALDE     Char( 'CQ0_FILIAL' ),
  @IN_FILIALATE    Char( 'CQ0_FILIAL' ),
  @IN_DATADE       Char( 08 ),
  @IN_DATAATE      Char( 08 ),
  @OUT_RESULTADO   Char( 01 ) OutPut
 )
as

/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Zera os arquivos a serem posteriormente reprocessados </d>
    Funcao do Siga  -     CtbZeraOrc()
    Fonte Microsiga - <s> CTBA390.PRW </s>
    Entrada         - <ri> @IN_CALIAS       - Alias do arquivo a ser processado
                           @IN_MOEDAESP     - Define se eh moeda especifica
                           @IN_MOEDA        - Moeda
                           @IN_TPSALDO      - Tipo de Saldo
                           @IN_FILIALDE     - Filial De
                           @IN_FILIALATE    - Filial Ate
                           @IN_DATADE       - Data de
                           @IN_DATAATE      - Data Ate
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r> Marco Norbiato	</r>
    Data        :     19/09/2003
-------------------------------------------------------------------------------------- */
declare @iMinRecno    integer
declare @iMaxRecno    integer
declare @iLinhas      integer

begin
   
   select @iLinhas = 1024
   /* -------------------------------------------------------------------------
      Zera a tabela CQ0 - MES
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ0' ) begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ0###
       where CQ0_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CQ0_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ0_TPSALD     = @IN_TPSALDO
         and ( ( CQ0_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
         and D_E_L_E_T_     = ' '
         
      If @iMinRecno != 0 begin
         While ( @iMinRecno <= @iMaxRecno ) begin
            begin tran
            update CQ0###
               set CQ0_DEBITO =  0, CQ0_CREDIT = 0
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
               and CQ0_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CQ0_DATA   between @IN_DATADE   and @IN_DATAATE
               and CQ0_TPSALD     = @IN_TPSALDO
               and ( ( CQ0_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
               and D_E_L_E_T_     = ' '
            commit tran
            select @iMinRecno = @iMinRecno + @iLinhas
         End
      End
   end
   /* -------------------------------------------------------------------------
      Zera a tabela CQ1 - DIA
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ1' ) begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ1###
       where CQ1_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CQ1_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ1_TPSALD     = @IN_TPSALDO
         and ( ( CQ1_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
         and D_E_L_E_T_     = ' '
         
      If @iMinRecno != 0 begin
         While ( @iMinRecno <= @iMaxRecno ) begin
            begin tran
            update CQ1###
               set CQ1_DEBITO =  0, CQ1_CREDIT = 0
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
               and CQ1_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CQ1_DATA   between @IN_DATADE   and @IN_DATAATE
               and CQ1_TPSALD     = @IN_TPSALDO
               and ( ( CQ1_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
               and D_E_L_E_T_     = ' '
            commit tran
            select @iMinRecno = @iMinRecno + @iLinhas
         End
      End
   end
   /* -------------------------------------------------------------------------
      Zera a tabela CQ2 -- CUSTO DIA
      -------------------------------------------------------------------------*/
   If ( @IN_CALIAS = 'CQ2' ) begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ2###
       where CQ2_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CQ2_DATA   between @IN_DATADE   and @IN_DATAATE
         and ( ( CQ2_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
         and CQ2_TPSALD     = @IN_TPSALDO
         and D_E_L_E_T_     = ' '
      
      If @iMinRecno != 0 begin
         While ( @iMinRecno <= @iMaxRecno ) begin
            begin tran
            update CQ2###
               set CQ2_DEBITO =  0, CQ2_CREDIT = 0
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno+ @iLinhas
               and CQ2_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CQ2_DATA   between @IN_DATADE   and @IN_DATAATE
               and CQ2_TPSALD     = @IN_TPSALDO
               and ( ( CQ2_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
               and D_E_L_E_T_     = ' '
            commit tran
            select @iMinRecno = @iMinRecno + @iLinhas
         End
      End
   End
   /* -------------------------------------------------------------------------
      Zera a tabela CQ3 -- CUSTO DIA
      -------------------------------------------------------------------------*/
   If ( @IN_CALIAS = 'CQ3' ) begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ3###
       where CQ3_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CQ3_DATA   between @IN_DATADE   and @IN_DATAATE
         and ( ( CQ3_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
         and CQ3_TPSALD     = @IN_TPSALDO
         and D_E_L_E_T_     = ' '
      
      If @iMinRecno != 0 begin
         While ( @iMinRecno <= @iMaxRecno ) begin
            begin tran
            update CQ3###
               set CQ3_DEBITO =  0, CQ3_CREDIT = 0
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno+ @iLinhas
               and CQ3_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CQ3_DATA   between @IN_DATADE   and @IN_DATAATE
               and CQ3_TPSALD     = @IN_TPSALDO
               and ( ( CQ3_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
               and D_E_L_E_T_     = ' '
            commit tran
            select @iMinRecno = @iMinRecno + @iLinhas
         End
      End
   End
   /* -------------------------------------------------------------------------
      Zera a tabela CQ4
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ4' ) begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ4###
       where CQ4_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CQ4_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ4_TPSALD     = @IN_TPSALDO
         and ( ( CQ4_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
         and D_E_L_E_T_     = ' '
               
      If @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            begin tran
            update CQ4###
               set CQ4_DEBITO =  0, CQ4_CREDIT = 0
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
               and CQ4_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CQ4_DATA   between @IN_DATADE   and @IN_DATAATE
               and CQ4_TPSALD     = @IN_TPSALDO
               and ( ( CQ4_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
               and D_E_L_E_T_     = ' '
            commit tran
            select @iMinRecno = @iMinRecno + @iLinhas
         End
      End
   end
      /* -------------------------------------------------------------------------
      Zera a tabela CQ5 -- CUSTO DIA
      -------------------------------------------------------------------------*/
   If ( @IN_CALIAS = 'CQ5' ) begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ5###
       where CQ5_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CQ5_DATA   between @IN_DATADE   and @IN_DATAATE
         and ( ( CQ5_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
         and CQ5_TPSALD     = @IN_TPSALDO
         and D_E_L_E_T_     = ' '
      
      If @iMinRecno != 0 begin
         While ( @iMinRecno <= @iMaxRecno ) begin
            begin tran
            update CQ5###
               set CQ5_DEBITO =  0, CQ5_CREDIT = 0
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno+ @iLinhas
               and CQ5_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CQ5_DATA   between @IN_DATADE   and @IN_DATAATE
               and CQ5_TPSALD     = @IN_TPSALDO
               and ( ( CQ5_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
               and D_E_L_E_T_     = ' '
            commit tran
            select @iMinRecno = @iMinRecno + @iLinhas
         End
      End
   End
   /* -------------------------------------------------------------------------
      Zera a tabela CQ6 - CLVL MES
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ6' ) begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ6###
       where CQ6_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CQ6_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ6_TPSALD     = @IN_TPSALDO
         and ( ( CQ6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
         and D_E_L_E_T_     = ' '
               
      If @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            begin tran
            update CQ6###
               set CQ6_DEBITO =  0, CQ6_CREDIT = 0
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
               and CQ6_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CQ6_DATA   between @IN_DATADE   and @IN_DATAATE
               and CQ6_TPSALD     = @IN_TPSALDO
               and ( ( CQ6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
               and D_E_L_E_T_     = ' '
            commit tran
            select @iMinRecno = @iMinRecno + @iLinhas
         End
      End
   end
   /* -------------------------------------------------------------------------
      Zera a tabela CQ7 - CLVL DIA
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ7' ) begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ7###
       where CQ7_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CQ7_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ7_TPSALD     = @IN_TPSALDO
         and ( ( CQ7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
         and D_E_L_E_T_     = ' '
               
      If @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            begin tran
            update CQ7###
               set CQ7_DEBITO =  0, CQ7_CREDIT = 0
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
               and CQ7_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CQ7_DATA   between @IN_DATADE   and @IN_DATAATE
               and CQ7_TPSALD     = @IN_TPSALDO
               and ( ( CQ7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
               and D_E_L_E_T_     = ' '
            commit tran
            select @iMinRecno = @iMinRecno + @iLinhas
         End
      End
   end
   /* -------------------------------------------------------------------------
      Zera a tabela CQ8 - CLVL MES
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ8' ) begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ8###
       where CQ8_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CQ8_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ8_TPSALD     = @IN_TPSALDO
         and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
         and D_E_L_E_T_     = ' '
               
      If @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            begin tran
            update CQ8###
               set CQ8_DEBITO =  0, CQ8_CREDIT = 0
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
               and CQ8_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CQ8_DATA   between @IN_DATADE   and @IN_DATAATE
               and CQ8_TPSALD     = @IN_TPSALDO
               and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
               and D_E_L_E_T_     = ' '
            commit tran
            select @iMinRecno = @iMinRecno + @iLinhas
         End
      End
   end
   /* -------------------------------------------------------------------------
      Zera a tabela CQ9 - CLVL DIA
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ9' ) begin
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ9###
       where CQ9_FILIAL between @IN_FILIALDE and @IN_FILIALATE
         and CQ9_DATA   between @IN_DATADE   and @IN_DATAATE
         and CQ9_TPSALD     = @IN_TPSALDO
         and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
         and D_E_L_E_T_     = ' '
               
      If @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            begin tran
            update CQ9###
               set CQ9_DEBITO =  0, CQ9_CREDIT = 0
             where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + @iLinhas
               and CQ9_FILIAL between @IN_FILIALDE and @IN_FILIALATE
               and CQ9_DATA   between @IN_DATADE   and @IN_DATAATE
               and CQ9_TPSALD     = @IN_TPSALDO
               and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP != '1' )
               and D_E_L_E_T_     = ' '
            commit tran
            select @iMinRecno = @iMinRecno + @iLinhas
         End
      End
   end
   select @OUT_RESULTADO = '1'
end
