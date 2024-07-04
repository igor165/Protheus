/* -----------------------------------------------------------------------------------
   CTB002a - CLocalización COL/PER - Zera Saldos - QL6, QL7
   ---------------------------------------------------------------------------------- */
##IF_001({|| cPaisLoc $ 'COL|PER' .And. CtbMovSaldo('CT0',,'05') })
##FIELDP01( 'QL6.QL6_FILIAL' )
Create procedure CTB002A_##
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
    Responsavel :     <r> Alberto Rodriguez	</r>
    Data        :     20/09/2021
-------------------------------------------------------------------------------------- */
declare @iMinRecno   integer
declare @iMaxRecno   integer
declare @cFilial_CT2 char('CT2_FILIAL')
declare @cAux        char(03)
declare @cDataI      char(08)
declare @cDataF      char(08)
##IF_001({|| cPaisLoc $ 'COL|PER' .And. CtbMovSaldo('CT0',,'05') })
   declare @cFilial_QL6 char('QL6_FILIAL')
   declare @cFilial_QL7 char('QL7_FILIAL')
##ELSE_001
   declare @cFilial_QL6 char('CT2_FILIAL')
   declare @cFilial_QL7 char('CT2_FILIAL')
##ENDIF_001

begin

   If @IN_FILIALDE = ' ' select @cFilial_CT2 = ' '
   else select @cFilial_CT2 = @IN_FILIALDE

   /* -------------------------------------------------------------------------
      Zera a tabela Entidad 05 QL6 - Mes
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'QL6' ) begin
      select @cDataI = Substring(@IN_DATADE, 1, 6 )||'01'
      Exec LASTDAY_## @IN_DATAATE, @cDataF OutPut
      select @cAux = 'QL6'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_QL6 OutPut

      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
         from QL6###
      where QL6_FILIAL between @cFilial_QL6 and @IN_FILIALATE
         and QL6_DATA   between @cDataI      and @cDataF
         and QL6_TPSALD = @IN_TPSALDO
         and ( ( QL6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )

      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               if ( @IN_SOALGUNS = '1' ) begin
                  update QL6###
                     set QL6_DEBITO =  0, QL6_CREDIT = 0
                  where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and QL6_FILIAL between @cFilial_QL6 and @IN_FILIALATE
                     and QL6_DATA   between @cDataI      and @cDataF
                     and QL6_TPSALD = @IN_TPSALDO
                     and ( ( QL6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
               end else begin
                  If @IN_INTEGRIDADE = '1' begin
                     UpDate QL6###
                        Set D_E_L_E_T_ = '*'
                     where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and QL6_FILIAL between @cFilial_QL6 and @IN_FILIALATE
                        and QL6_DATA   between @cDataI      and @cDataF
                        and QL6_TPSALD = @IN_TPSALDO
                        and ( ( QL6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )

                     delete
                        from QL6###
                     where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and QL6_FILIAL between @cFilial_QL6 and @IN_FILIALATE
                        and QL6_DATA   between @cDataI      and @cDataF
                        and QL6_TPSALD = @IN_TPSALDO
                        and ( ( QL6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = '*'
                  end else begin
                     delete
                        from QL6###
                      where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and QL6_FILIAL between @cFilial_QL6 and @IN_FILIALATE
                        and QL6_DATA   between @cDataI      and @cDataF
                        and QL6_TPSALD = @IN_TPSALDO
                        and ( ( QL6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  end
               end
            end else begin
               /* ----------------------
                  Marcar como deletado
                  ---------------------- */
               UpDate QL6###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP07( 'QL6.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP07
               where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and QL6_FILIAL between @cFilial_QL6 and @IN_FILIALATE
                  and QL6_DATA   between @cDataI      and @cDataF
                  and QL6_TPSALD = @IN_TPSALDO
                  and ( ( QL6_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end
   /* -------------------------------------------------------------------------
      Zera a tabela Entidad 05 QL7 - DIA
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'QL7' ) begin
      select @cDataI = @IN_DATADE
      select @cDataF = @IN_DATAATE
      select @cAux = 'QL7'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_QL7 OutPut

      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
         from QL7###
      where QL7_FILIAL between @cFilial_QL7 and @IN_FILIALATE
         and QL7_DATA   between @cDataI   and @cDataF
         and QL7_TPSALD = @IN_TPSALDO
         and ( ( QL7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )

      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            /* ----------------------
               Exclui fisicamente
               ---------------------- */
            begin tran
            If @IN_MVCTB190D = '1' begin
               if ( @IN_SOALGUNS = '1' ) begin
                  update QL7###
                     set QL7_DEBITO =  0, QL7_CREDIT = 0
                  where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                     and QL7_FILIAL between @cFilial_QL7 and @IN_FILIALATE
                     and QL7_DATA   between @cDataI   and @cDataF
                     and QL7_TPSALD = @IN_TPSALDO
                     and ( ( QL7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
               end else begin
                  If @IN_INTEGRIDADE = '1' begin
                     UpDate QL7###
                        Set D_E_L_E_T_ = '*'
                     where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and QL7_FILIAL between @cFilial_QL7 and @IN_FILIALATE
                        and QL7_DATA   between @cDataI   and @cDataF
                        and QL7_TPSALD = @IN_TPSALDO
                        and ( ( QL7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )

                     delete
                        from QL7###
                     where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and QL7_FILIAL between @cFilial_QL7 and @IN_FILIALATE
                        and QL7_DATA   between @cDataI   and @cDataF
                        and QL7_TPSALD = @IN_TPSALDO
                        and ( ( QL7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                        and D_E_L_E_T_ = '*'
                  end else begin
                     delete
                        from QL7###
                     where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                        and QL7_FILIAL between @cFilial_QL7 and @IN_FILIALATE
                        and QL7_DATA   between @cDataI   and @cDataF
                        and QL7_TPSALD = @IN_TPSALDO
                        and ( ( QL7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
                  end
               end
            end else begin
               /* ----------------------
                  Marcar como deletado
                  ---------------------- */
               UpDate QL7###
                  Set D_E_L_E_T_ = '*'
               ##FIELDP08( 'QL7.R_E_C_D_E_L_' )
                  , R_E_C_D_E_L_ = R_E_C_N_O_
               ##ENDFIELDP08
               where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
                  and QL7_FILIAL between @cFilial_QL7 and @IN_FILIALATE
                  and QL7_DATA   between @cDataI   and @cDataF
                  and QL7_TPSALD = @IN_TPSALDO
                  and ( ( QL7_MOEDA  = @IN_MOEDA AND @IN_MOEDAESP = '1' ) OR @IN_MOEDAESP = '0' )
            end
            commit tran
            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end

   select @OUT_RESULTADO = '1'

end
##ENDFIELDP01
##ENDIF_001
