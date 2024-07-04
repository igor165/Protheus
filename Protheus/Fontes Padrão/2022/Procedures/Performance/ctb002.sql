Create procedure CTB002_##
 ( 
  @IN_CALIAS       Char(03),
  @IN_MOEDAESP     Char(01),
  @IN_MOEDA        Char('CT2_MOEDLC'),
  @IN_TPSALDO      char('CT2_TPSALD'),
  @IN_FILIALDE     Char('CT2_FILIAL'),
  @IN_FILIALATE    Char('CT2_FILIAL'),
  @IN_DATADE       Char(08),
  @IN_DATAATE      Char(08),
  @IN_SOALGUNS     Char(01),
  @IN_INTEGRIDADE  Char(01),
  @IN_MVCTB190D    Char(01),
  @OUT_RESULTADO   Char(01) OutPut
 )
as

/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Zera os arquivos a serem posteriormente reprocessados </d>
    Funcao do Siga  -     CtbZeraTod()
    Fonte Microsiga - <s> CTBA190.PRW </s>
    Entrada         - <ri> @IN_CALIAS       - Alias do arquivo a ser processado
                           @IN_MOEDAESP     - Define se eh moeda especifica
                           @IN_MOEDA        - Moeda
                           @IN_TPSALDO      - Tipo de Saldo
                           @IN_FILIALDE     - Filial De
                           @IN_FILIALATE    - Filial Ate
                           @IN_DATADE       - Data de
                           @IN_DATAATE      - Data Ate
                           @IN_MVCTB190D    - '1' exclui fisicamente, '0' marca como deletado
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada.  </ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r> Marco Norbiato	</r>
    Data        :     19/09/2003
-------------------------------------------------------------------------------------- */
declare @iMinRecno    integer
declare @iMaxRecno    integer
declare @cFilial_CT2 char('CT2_FILIAL')
declare @cFilial_CQ0 char('CQ0_FILIAL')  --Conta Mes
declare @cFilial_CQ1 char('CQ1_FILIAL')  --Conta Dia
declare @cFilial_CQ2 char('CQ2_FILIAL')  --Ccusto Mes
declare @cFilial_CQ3 char('CQ3_FILIAL')  --CCusto Dia
declare @cFilial_CQ4 char('CQ4_FILIAL')  --Item Mes
declare @cFilial_CQ5 char('CQ5_FILIAL')  --Item Dia
declare @cFilial_CQ6 char('CQ6_FILIAL')  --Clvl Mes
declare @cFilial_CQ7 char('CQ7_FILIAL')  --Clvl Dia
declare @cFilial_CQ8 char('CQ8_FILIAL')  --CTU entidades Mes
declare @cFilial_CQ9 char('CQ9_FILIAL')  --CTU entidades Dia
declare @cFilial_CTC char('CTC_FILIAL')  -- documento
declare @cFilial_CQA char('CQA_FILIAL')  -- documento
declare @cCT2Fil     char('CT2_FILIAL')  -- documento
declare @cAux        char(03)
declare @cDataI      Char(08)
declare @cDataF      Char(08)

begin

   If @IN_FILIALDE = ' ' select @cFilial_CT2 = ' '
   else select @cFilial_CT2 = @IN_FILIALDE
   
   /* -------------------------------------------------------------------------
      Zera as tabelas Contas -  CQ0 Mes
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ0' ) begin
    select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
	Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
      select @cAux = 'CQ0'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_CQ0 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ0###
       where CQ0_FILIAL between @cFilial_CQ0 and @IN_FILIALATE
         and CQ0_DATA   between @cDataI      and @cDataF
         and CQ0_TPSALD =  @IN_TPSALDO
         and ( ( CQ0_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            Begin tran
            If @IN_MVCTB190D = '1' begin
               if ( @IN_SOALGUNS = '1' ) begin
                  update CQ0###
                     set CQ0_DEBITO =  0, CQ0_CREDIT = 0
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ0_FILIAL between @cFilial_CQ0 and @IN_FILIALATE
                     and CQ0_DATA   between @cDataI      and @cDataF
                     and CQ0_TPSALD =  @IN_TPSALDO
                     and ( ( CQ0_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
               end else begin
                  If @IN_INTEGRIDADE = '1' begin
                     /* -------------------------------------------------------------------------
                        Zera a tabela CQ0
                        -------------------------------------------------------------------------*/
                     Update CQ0###
                        Set D_E_L_E_T_ = '*'
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ0_FILIAL between @cFilial_CQ0 and @IN_FILIALATE
                        and CQ0_DATA   between @cDataI      and @cDataF
                        and CQ0_TPSALD =  @IN_TPSALDO
                        and ( ( CQ0_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        
                     delete
                       from CQ0###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ0_FILIAL between @cFilial_CQ0 and @IN_FILIALATE
                        and CQ0_DATA   between @cDataI      and @cDataF
                        and CQ0_TPSALD =  @IN_TPSALDO
                        and ( ( CQ0_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = '*'
                  end else begin
                     delete
                       from CQ0###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ0_FILIAL between @cFilial_CQ0 and @IN_FILIALATE
                        and CQ0_DATA   between @cDataI      and @cDataF
                        and CQ0_TPSALD =  @IN_TPSALDO
                        and ( ( CQ0_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  end
               end
            end else begin
               /* ----------------------
                  Marcar como deletado
                  ---------------------- */
               Update CQ0###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP01( 'CQ0.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP01
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and CQ0_FILIAL between @cFilial_CQ0 and @IN_FILIALATE
                  and CQ0_DATA   between @cDataI      and @cDataF
                  and CQ0_TPSALD =  @IN_TPSALDO
                  and ( ( CQ0_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024    
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera as tabelas Contas - CQ1 Dia
      -------------------------------------------------------------------------*/   
   if ( @IN_CALIAS = 'CQ1' ) begin
	select @cDataI = @IN_DATADE
	select @cDataF = @IN_DATAATE
      select @cAux = 'CQ1'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_CQ1 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ1###
       where CQ1_FILIAL between @cFilial_CQ1 and @IN_FILIALATE
         and CQ1_DATA   between @cDataI   and @cDataF
         and CQ1_TPSALD =  @IN_TPSALDO
         and ( ( CQ1_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            Begin tran
            If @IN_MVCTB190D = '1' begin
               if ( @IN_SOALGUNS = '1' ) begin
                  update CQ1###
                     set CQ1_DEBITO =  0, CQ1_CREDIT = 0
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ1_FILIAL between @cFilial_CQ1 and @IN_FILIALATE
                     
                     and CQ1_DATA   between @cDataI   and @cDataF
                     and CQ1_TPSALD =  @IN_TPSALDO
                     and ( ( CQ1_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
               end else begin
                  If @IN_INTEGRIDADE = '1' begin
                     /* -------------------------------------------------------------------------
                        Zera a tabela CQ1
                        -------------------------------------------------------------------------*/
                     Update CQ1###
                        Set D_E_L_E_T_ = '*'
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ1_FILIAL between @cFilial_CQ1 and @IN_FILIALATE
                        and CQ1_DATA   between @cDataI   and @cDataF
                        and CQ1_TPSALD =  @IN_TPSALDO
                        and ( ( CQ1_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        
                     delete
                       from CQ1###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ1_FILIAL between @cFilial_CQ1 and @IN_FILIALATE
                        and CQ1_DATA   between @cDataI   and @cDataF
                        and CQ1_TPSALD =  @IN_TPSALDO
                        and ( ( CQ1_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = '*'
                  end else begin
                     delete
                       from CQ1###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ1_FILIAL between @cFilial_CQ1 and @IN_FILIALATE
                        and CQ1_DATA   between @cDataI   and @cDataF
                        and CQ1_TPSALD =  @IN_TPSALDO
                        and ( ( CQ1_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  end
               end
            end else begin
               /* ----------------------
                  Marcar como deletado
                  ---------------------- */
               Update CQ1###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP01( 'CQ1.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP01
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and CQ1_FILIAL between @cFilial_CQ1 and @IN_FILIALATE
                  and CQ1_DATA   between @cDataI   and @cDataF
                  and CQ1_TPSALD =  @IN_TPSALDO
                  and ( ( CQ1_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024    
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera as tabelas CCustos - CQ2 Mes
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ2' ) begin
	select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
	Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
      select @cAux = 'CQ2'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_CQ2 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ2###
       where CQ2_FILIAL between @cFilial_CQ2 and @IN_FILIALATE
         and CQ2_DATA   between @cDataI      and @cDataF
         and CQ2_TPSALD = @IN_TPSALDO
         and ( ( CQ2_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               if ( @IN_SOALGUNS = '1' ) begin
                  update CQ2###
                     set CQ2_DEBITO =  0, CQ2_CREDIT = 0
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ2_FILIAL between @cFilial_CQ2 and @IN_FILIALATE
                     and CQ2_DATA   between @cDataI      and @cDataF
                     and CQ2_TPSALD = @IN_TPSALDO
                     and ( ( CQ2_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
               end else begin
                  If @IN_INTEGRIDADE = '1' begin
                     /* -------------------------------------------------------------------------
                        Zera a tabela CQ2
                        -------------------------------------------------------------------------*/
                     UpDate CQ2###
                        Set D_E_L_E_T_ = '*'
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ2_FILIAL between @cFilial_CQ2 and @IN_FILIALATE
                        and CQ2_DATA   between @cDataI      and @cDataF
                        and CQ2_TPSALD = @IN_TPSALDO
                        and ( ( CQ2_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     
                     delete
                       from CQ2###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ2_FILIAL between @cFilial_CQ2 and @IN_FILIALATE
                        and CQ2_DATA   between @cDataI      and @cDataF
                        and CQ2_TPSALD = @IN_TPSALDO
                        and ( ( CQ2_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = '*'
                  end else begin
                     delete
                       from CQ2###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ2_FILIAL between @cFilial_CQ2 and @IN_FILIALATE
                        and CQ2_DATA   between @cDataI      and @cDataF
                        and CQ2_TPSALD = @IN_TPSALDO
                        and ( ( CQ2_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  end
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
                  and CQ2_FILIAL between @cFilial_CQ2 and @IN_FILIALATE
                  and CQ2_DATA   between @cDataI      and @cDataF
                  and CQ2_TPSALD = @IN_TPSALDO
                  and ( ( CQ2_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera as tabelas CCustos - CQ3 Dia
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ3' ) begin
   	select @cDataI = @IN_DATADE
	select @cDataF = @IN_DATAATE
      select @cAux = 'CQ3'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_CQ3 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ3###
       where CQ3_FILIAL between @cFilial_CQ3 and @IN_FILIALATE
         and CQ3_DATA   between @cDataI   and @cDataF
         and CQ3_TPSALD = @IN_TPSALDO
         and ( ( CQ3_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               if ( @IN_SOALGUNS = '1' ) begin
                  update CQ3###
                     set CQ3_DEBITO =  0, CQ3_CREDIT = 0
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ3_FILIAL between @cFilial_CQ3 and @IN_FILIALATE
                     and CQ3_DATA   between @cDataI   and @cDataF
                     and CQ3_TPSALD = @IN_TPSALDO
                     and ( ( CQ3_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
               end else begin
                  If @IN_INTEGRIDADE = '1' begin
                     /* -------------------------------------------------------------------------
                        Zera a tabela CQ3
                        -------------------------------------------------------------------------*/
                     UpDate CQ3###
                        Set D_E_L_E_T_ = '*'
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ3_FILIAL between @cFilial_CQ3 and @IN_FILIALATE
                        and CQ3_DATA   between @cDataI   and @cDataF
                        and CQ3_TPSALD = @IN_TPSALDO
                        and ( ( CQ3_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     
                     delete
                       from CQ3###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ3_FILIAL between @cFilial_CQ3 and @IN_FILIALATE
                        and CQ3_DATA   between @cDataI   and @cDataF
                        and CQ3_TPSALD = @IN_TPSALDO
                        and ( ( CQ3_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = '*'
                  end else begin
                     delete
                       from CQ3###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ3_FILIAL between @cFilial_CQ3 and @IN_FILIALATE
                        and CQ3_DATA   between @cDataI   and @cDataF
                        and CQ3_TPSALD = @IN_TPSALDO
                        and ( ( CQ3_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  end
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
                  and CQ3_FILIAL between @cFilial_CQ3 and @IN_FILIALATE
                  and CQ3_DATA   between @cDataI   and @cDataF
                  and CQ3_TPSALD = @IN_TPSALDO
                  and ( ( CQ3_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela Item Contabil - CQ4 - Mes
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ4' ) begin
	select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
	Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
      select @cAux = 'CQ4'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_CQ4 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ4###
       where CQ4_FILIAL between @cFilial_CQ4 and @IN_FILIALATE
         and CQ4_DATA   between @cDataI      and @cDataF
         and CQ4_TPSALD = @IN_TPSALDO
         and ( ( CQ4_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               if ( @IN_SOALGUNS = '1' ) begin
                  update CQ4###
                     set CQ4_DEBITO =  0, CQ4_CREDIT = 0
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ4_FILIAL between @cFilial_CQ4 and @IN_FILIALATE
                     and CQ4_DATA   between @cDataI      and @cDataF
                     and CQ4_TPSALD = @IN_TPSALDO
                     and ( ( CQ4_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
               end else begin
                  /* -------------------------------------------------------------------------
                     Zera a tabela CQ4
                     -------------------------------------------------------------------------*/
                  if @IN_INTEGRIDADE = '1' begin
                     UpDate CQ4###
                        Set D_E_L_E_T_ = '*'
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ4_FILIAL between @cFilial_CQ4 and @IN_FILIALATE
                        and CQ4_DATA   between @cDataI      and @cDataF
                        and CQ4_TPSALD = @IN_TPSALDO
                        and ( ( CQ4_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     
                     delete
                       from CQ4###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ4_FILIAL between @cFilial_CQ4 and @IN_FILIALATE
                        and CQ4_DATA   between @cDataI      and @cDataF
                        and CQ4_TPSALD = @IN_TPSALDO
                        and ( ( CQ4_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = '*'
                  end else begin
                     delete
                       from CQ4###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ4_FILIAL between @cFilial_CQ4 and @IN_FILIALATE
                        and CQ4_DATA   between @cDataI      and @cDataF
                        and CQ4_TPSALD = @IN_TPSALDO
                        and ( ( CQ4_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = ' '
                  end
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
                  and CQ4_FILIAL between @cFilial_CQ4 and @IN_FILIALATE
                  and CQ4_DATA   between @cDataI      and @cDataF
                  and CQ4_TPSALD = @IN_TPSALDO
                  and ( ( CQ4_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )            
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
            
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera ITEM contabil CQ5 - Dia
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ5' ) begin
   	select @cDataI = @IN_DATADE
	select @cDataF = @IN_DATAATE
      select @cAux = 'CQ5'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_CQ5 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ5###
       where CQ5_FILIAL between @cFilial_CQ5 and @IN_FILIALATE
         and CQ5_DATA   between @cDataI   and @cDataF
         and CQ5_TPSALD = @IN_TPSALDO
         and ( ( CQ5_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               if ( @IN_SOALGUNS = '1' ) begin
                  update CQ5###
                     set CQ5_DEBITO =  0, CQ5_CREDIT = 0
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ5_FILIAL between @cFilial_CQ5 and @IN_FILIALATE
                     and CQ5_DATA   between @cDataI   and @cDataF
                     and CQ5_TPSALD = @IN_TPSALDO
                     and ( ( CQ5_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
               end else begin
                  /* -------------------------------------------------------------------------
                     Zera a tabela CQ5
                     -------------------------------------------------------------------------*/
                  if @IN_INTEGRIDADE = '1' begin
                     UpDate CQ5###
                        Set D_E_L_E_T_ = '*'
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ5_FILIAL between @cFilial_CQ5 and @IN_FILIALATE
                        and CQ5_DATA   between @cDataI   and @cDataF
                        and CQ5_TPSALD = @IN_TPSALDO
                        and ( ( CQ5_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     
                     delete
                       from CQ5###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ5_FILIAL between @cFilial_CQ5 and @IN_FILIALATE
                        and CQ5_DATA   between @cDataI   and @cDataF
                        and CQ5_TPSALD = @IN_TPSALDO
                        and ( ( CQ5_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = '*'
                  end else begin
                     delete
                       from CQ5###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ5_FILIAL between @cFilial_CQ5 and @IN_FILIALATE
                        and CQ5_DATA   between @cDataI   and @cDataF
                        and CQ5_TPSALD = @IN_TPSALDO
                        and ( ( CQ5_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = ' '
                  end
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
                  and CQ5_FILIAL between @cFilial_CQ5 and @IN_FILIALATE
                  and CQ5_DATA   between @cDataI   and @cDataF
                  and CQ5_TPSALD = @IN_TPSALDO
                  and ( ( CQ5_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )            
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
            
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela Classe de Valor CQ6 - Mes
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ6' ) begin
	select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
	Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
      select @cAux = 'CQ6'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_CQ6 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ6###
       where CQ6_FILIAL between @cFilial_CQ6 and @IN_FILIALATE
         and CQ6_DATA   between @cDataI      and @cDataF
         and CQ6_TPSALD = @IN_TPSALDO
         and ( ( CQ6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               if ( @IN_SOALGUNS = '1' ) begin
                  update CQ6###
                     set CQ6_DEBITO =  0, CQ6_CREDIT = 0
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ6_FILIAL between @cFilial_CQ6 and @IN_FILIALATE
                     and CQ6_DATA   between @cDataI      and @cDataF
                     and CQ6_TPSALD = @IN_TPSALDO
                     and ( ( CQ6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
               end else begin
                  If @IN_INTEGRIDADE = '1' begin
                     UpDate CQ6###
                        Set D_E_L_E_T_ = '*'
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ6_FILIAL between @cFilial_CQ6 and @IN_FILIALATE
                        and CQ6_DATA   between @cDataI      and @cDataF
                        and CQ6_TPSALD = @IN_TPSALDO
                        and ( ( CQ6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     
                     delete
                       from CQ6###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ6_FILIAL between @cFilial_CQ6 and @IN_FILIALATE
                        and CQ6_DATA   between @cDataI      and @cDataF
                        and CQ6_TPSALD = @IN_TPSALDO
                        and ( ( CQ6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = '*'
                  end else begin
                     delete
                       from CQ6###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ6_FILIAL between @cFilial_CQ6 and @IN_FILIALATE
                        and CQ6_DATA   between @cDataI      and @cDataF
                        and CQ6_TPSALD = @IN_TPSALDO
                        and ( ( CQ6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  end
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
                  and CQ6_FILIAL between @cFilial_CQ6 and @IN_FILIALATE
                  and CQ6_DATA   between @cDataI      and @cDataF
                  and CQ6_TPSALD = @IN_TPSALDO
                  and ( ( CQ6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela Classe de Valor CQ7 - DIA
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ7' ) begin
   	select @cDataI = @IN_DATADE
	select @cDataF = @IN_DATAATE
      select @cAux = 'CQ7'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_CQ7 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ7###
       where CQ7_FILIAL between @cFilial_CQ7 and @IN_FILIALATE
         and CQ7_DATA   between @cDataI   and @cDataF
         and CQ7_TPSALD = @IN_TPSALDO
         and ( ( CQ7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               if ( @IN_SOALGUNS = '1' ) begin
                  update CQ7###
                     set CQ7_DEBITO =  0, CQ7_CREDIT = 0
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ7_FILIAL between @cFilial_CQ7 and @IN_FILIALATE
                     and CQ7_DATA   between @cDataI   and @cDataF
                     and CQ7_TPSALD = @IN_TPSALDO
                     and ( ( CQ7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
               end else begin
                  If @IN_INTEGRIDADE = '1' begin
                     UpDate CQ7###
                        Set D_E_L_E_T_ = '*'
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ7_FILIAL between @cFilial_CQ7 and @IN_FILIALATE
                        and CQ7_DATA   between @cDataI   and @cDataF
                        and CQ7_TPSALD = @IN_TPSALDO
                        and ( ( CQ7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     
                     delete
                       from CQ7###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ7_FILIAL between @cFilial_CQ7 and @IN_FILIALATE
                        and CQ7_DATA   between @cDataI   and @cDataF
                        and CQ7_TPSALD = @IN_TPSALDO
                        and ( ( CQ7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = '*'
                  end else begin
                     delete
                       from CQ7###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ7_FILIAL between @cFilial_CQ7 and @IN_FILIALATE
                        and CQ7_DATA   between @cDataI   and @cDataF
                        and CQ7_TPSALD = @IN_TPSALDO
                        and ( ( CQ7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  end
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
                  and CQ7_FILIAL between @cFilial_CQ7 and @IN_FILIALATE
                  and CQ7_DATA   between @cDataI   and @cDataF
                  and CQ7_TPSALD = @IN_TPSALDO
                  and ( ( CQ7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
     /* -------------------------------------------------------------------------
      Zera a Saldo entidades CQ8 (CTU) - Mes
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ8' ) begin
	select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
	Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
      select @cAux = 'CQ8'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_CQ8 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ8###
       where CQ8_FILIAL between @cFilial_CQ8 and @IN_FILIALATE
         and CQ8_DATA   between @cDataI      and @cDataF
         and CQ8_TPSALD = @IN_TPSALDO
         and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               if ( @IN_SOALGUNS = '1' ) begin
                  update CQ8###
                     set CQ8_DEBITO =  0, CQ8_CREDIT = 0
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ8_FILIAL between @cFilial_CQ8 and @IN_FILIALATE
                     and CQ8_DATA   between @cDataI      and @cDataF
                     and CQ8_TPSALD = @IN_TPSALDO
                     and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
               end else begin
                  If @IN_INTEGRIDADE = '1' begin
                     UpDate CQ8###
                        Set D_E_L_E_T_ = '*'
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ8_FILIAL between @cFilial_CQ8 and @IN_FILIALATE
                        and CQ8_DATA   between @cDataI      and @cDataF
                        and CQ8_TPSALD = @IN_TPSALDO
                        and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     
                     delete
                       from CQ8###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ8_FILIAL between @cFilial_CQ8 and @IN_FILIALATE
                        and CQ8_DATA   between @cDataI      and @cDataF
                        and CQ8_TPSALD = @IN_TPSALDO
                        and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = '*'
                  end else begin
                     delete
                       from CQ8###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ8_FILIAL between @cFilial_CQ8 and @IN_FILIALATE
                        and CQ8_DATA   between @cDataI      and @cDataF
                        and CQ8_TPSALD = @IN_TPSALDO
                        and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  end
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
                  and CQ8_FILIAL between @cFilial_CQ8 and @IN_FILIALATE
                  and CQ8_DATA   between @cDataI      and @cDataF
                  and CQ8_TPSALD = @IN_TPSALDO
                  and ( ( CQ8_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end 
     /* -------------------------------------------------------------------------
      Zera a Saldo entidades CQ9 (CTU) - DIA
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ9' ) begin
   	select @cDataI = @IN_DATADE
	select @cDataF = @IN_DATAATE
      select @cAux = 'CQ9'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_CQ9 OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ9###
       where CQ9_FILIAL between @cFilial_CQ9 and @IN_FILIALATE
         and CQ9_DATA   between @cDataI   and @cDataF
         and CQ9_TPSALD = @IN_TPSALDO
         and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               if ( @IN_SOALGUNS = '1' ) begin
                  update CQ9###
                     set CQ9_DEBITO =  0, CQ9_CREDIT = 0
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CQ9_FILIAL between @cFilial_CQ9 and @IN_FILIALATE
                     and CQ9_DATA   between @cDataI   and @cDataF
                     and CQ9_TPSALD = @IN_TPSALDO
                     and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
               end else begin
                  If @IN_INTEGRIDADE = '1' begin
                     UpDate CQ9###
                        Set D_E_L_E_T_ = '*'
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ9_FILIAL between @cFilial_CQ9 and @IN_FILIALATE
                        and CQ9_DATA   between @cDataI   and @cDataF
                        and CQ9_TPSALD = @IN_TPSALDO
                        and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     
                     delete
                       from CQ9###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ9_FILIAL between @cFilial_CQ9 and @IN_FILIALATE
                        and CQ9_DATA   between @cDataI   and @cDataF
                        and CQ9_TPSALD = @IN_TPSALDO
                        and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = '*'
                  end else begin
                     delete
                       from CQ9###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CQ9_FILIAL between @cFilial_CQ9 and @IN_FILIALATE
                        and CQ9_DATA   between @cDataI   and @cDataF
                        and CQ9_TPSALD = @IN_TPSALDO
                        and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  end
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
                  and CQ9_FILIAL between @cFilial_CQ9 and @IN_FILIALATE
                  and CQ9_DATA   between @cDataI   and @cDataF
                  and CQ9_TPSALD = @IN_TPSALDO
                  and ( ( CQ9_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
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
	select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
	Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
      select @cAux = 'CTC'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_CTC OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTC###
       where CTC_FILIAL between @cFilial_CTC and @IN_FILIALATE
         and CTC_DATA   between @cDataI   and @cDataF
         and CTC_TPSALD = @IN_TPSALDO
         and ( ( CTC_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------------
               Exclui fisicamente
               ---------------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               if ( @IN_SOALGUNS = '1' ) begin
                  update CTC###
                     set CTC_DEBITO =  0, CTC_CREDIT = 0, CTC_DIG = 0
                   where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and CTC_FILIAL between @cFilial_CTC and @IN_FILIALATE
                     and CTC_DATA   between @cDataI   and @cDataF
                     and CTC_TPSALD = @IN_TPSALDO
                     and ( ( CTC_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
               end else begin
                  If @IN_INTEGRIDADE = '1' begin
                     UpDate CTC###
                        Set D_E_L_E_T_ = '*'
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CTC_FILIAL between @cFilial_CTC and @IN_FILIALATE
                        and CTC_DATA   between @cDataI   and @cDataF
                        and CTC_TPSALD = @IN_TPSALDO
                        and ( ( CTC_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                     
                     delete
                       from CTC###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CTC_FILIAL between @cFilial_CTC and @IN_FILIALATE
                        and CTC_DATA   between @cDataI   and @cDataF
                        and CTC_TPSALD = @IN_TPSALDO
                        and ( ( CTC_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = '*'
                  end else begin
                     delete
                       from CTC###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and CTC_FILIAL between @cFilial_CTC and @IN_FILIALATE
                        and CTC_DATA   between @cDataI   and @cDataF
                        and CTC_TPSALD = @IN_TPSALDO
                        and ( ( CTC_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  end
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
                  and CTC_FILIAL between @cFilial_CTC and @IN_FILIALATE
                  and CTC_DATA   between @cDataI   and @cDataF
                  and CTC_TPSALD = @IN_TPSALDO
                  and ( ( CTC_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
 
    /* -------------------------------------------------------------------------
      Zera as tabelas Contas -  CQA
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQA' ) begin
	select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
	Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
      select @cAux = 'CQA'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_CQA OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQA###
       where CQA_FILIAL between @cFilial_CQA and @IN_FILIALATE
         and CQA_DATA   between @cDataI      and @cDataF
         and CQA_TPSALD =  @IN_TPSALDO
         and ( ( CQA_MOEDLC  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente    
               ---------------------- */
            Begin tran
            If @IN_MVCTB190D = '1' begin
              If @IN_INTEGRIDADE = '1' begin
                 /* -------------------------------------------------------------------------
                    Zera a tabela CQA
                    -------------------------------------------------------------------------*/
                 Update CQA###
                    Set D_E_L_E_T_ = '*'
                  where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
					 and CQA_FILIAL between @cFilial_CQA and @IN_FILIALATE
					 and CQA_DATA   between @cDataI      and @cDataF
                    and CQA_DATA   between @cDataI      and @cDataF
                    and CQA_TPSALD =  @IN_TPSALDO
                    and ( ( CQA_MOEDLC  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                    
                 delete
                   from CQA###
                  where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
					and CQA_FILIAL between @cFilial_CQA and @IN_FILIALATE
                    and CQA_DATA   between @cDataI      and @cDataF
                    and CQA_TPSALD =  @IN_TPSALDO
                    and ( ( CQA_MOEDLC  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                    and D_E_L_E_T_ = '*'
              end else begin
                 delete
                   from CQA###
                  where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
					and CQA_FILIAL between @cFilial_CQA and @IN_FILIALATE
                    and CQA_DATA   between @cDataI      and @cDataF
                    and CQA_TPSALD =  @IN_TPSALDO
                    and ( ( CQA_MOEDLC  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
              end
               
            end else begin
               /* ----------------------
                  Marcar como deletado
                  ---------------------- */
               Update CQA###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP01( 'CQ0.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP01
                where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
				  and CQA_FILIAL between @cFilial_CQA and @IN_FILIALATE
                  and CQA_DATA   between @cDataI      and @cDataF
                  and CQA_TPSALD =  @IN_TPSALDO
                  and ( ( CQA_MOEDLC  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024    
         end
      end
   end
 
   select @OUT_RESULTADO = '1'
end
