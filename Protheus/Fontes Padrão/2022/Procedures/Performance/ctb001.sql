Create procedure CTB001_##
( 
   @IN_LCUSTO       Char(01),
   @IN_LITEM        Char(01),
   @IN_LCLVL        Char(01),
   @IN_FILIALDE     Char('CV1_FILIAL'),
   @IN_FILIALATE    Char('CV1_FILIAL'),
   @IN_DATAINI      Char(08),
   @IN_DATAFIM      Char(08),
   @IN_LMOEDAESP    Char(01),
   @IN_MOEDA        Char('CV1_MOEDA'),
   @IN_OPERACAO     Char(01),
   @IN_INTEGRIDADE  Char(01),
   @IN_MVCTB190D    Char(01),
   @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  012 </a>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Reprocessamento SigaCTB </d>
    Fonte Microsiga - <s>  CTB390.PRW </s>
    Funcao do Siga  -      CTB390Rep()
    Entrada         - <ri> @IN_LCUSTO       - Centro de Custo em uso
                           @IN_LITEM        - Item em uso
                           @IN_LCLVL        - Classe de Valor em uso
                           @IN_FILIALDE     - Filial inicio do processamento
                           @IN_FILIALATE    - Filial final do processamento
                           @IN_DATAINI      - Data Inicial
                           @IN_DATAFIM      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1' 
                           @IN_MOEDA        - Moeda escolhida
                           @IN_OPERACAO     - Operacao = '1' no Reprocessamento
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada. 
                           @IN_MVCTB190D    - '1' exclui fisicamente, '0' marca como deletado</ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Marco Norbiato	</r>
    Data        :     19/09/2003
   
    CTB001 - Reprecessamento Contábil - Orçamentos
      +--> CTB012 - Zera Saldos CQ0/CQ1/CQ2/CQ3/CQ4/CQ5/CQ6/CQ7/CQ8/CQ9- Obs: Nos saldos por entidades zera todas as entidades
      +--> CTB003 - Ctb390Atu() - Reproc 
      |      +--> CTB011  -  CTB390Recn() - Rotina para saber o numero de entidades do intervalo.
      |      +--> CTB010  -  Ctb390CTI()  - Grava os saldos do arquivo CQ6/CQ7.
      |      |      +--> CTB013  -  Ctb390CTI()  - Grava os saldos do arquivo CQ6/CQ7 qdo as entidades inicio e fim forem as mesmas
      |      +--> CTB004  -  Ctb390CTD()  - Grava os saldos do arquivo CQ4/CQ5.
      |      |      +--> CTB245  -  Grava os saldos do arquivo CQ4/CQ5 qdo as entidades inicio e fim forem as mesmas
      |      +--> CTB005  -  Ctb390CTT()  - Grava os saldos do arquivo CQ2/CQ3.
      |      |      CTB246  -  Grava os saldos do arquivo CQ2/CQ3 qdo as entidades inicio e fim forem as mesmas
      |      +--> CTB006  -  Ctb390CT1()  - Grava os saldos do arquivo CQ0/CQ1.
         
-------------------------------------------------------------------------------------- */
declare @cFilial_CV1 char( 'CV1_FILIAL' )
declare @cCV1FilDe char( 'CV1_FILIAL' )
declare @cFilial_CQ0 char( 'CQ0_FILIAL' )
declare @cFilial_CQ1 char( 'CQ1_FILIAL' )
declare @cFilial_CQ2 char( 'CQ2_FILIAL' )
declare @cFilial_CQ3 char( 'CQ3_FILIAL' )
declare @cFilial_CQ4 char( 'CQ4_FILIAL' )
declare @cFilial_CQ5 char( 'CQ5_FILIAL' )
declare @cFilial_CQ6 char( 'CQ6_FILIAL' )
declare @cFilial_CQ7 char( 'CQ7_FILIAL' )
declare @cFilial_CQ8 char( 'CQ8_FILIAL' )
declare @cFilial_CQ9 char( 'CQ9_FILIAL' )
declare @cCV1_FILIAL char('CV1_FILIAL' )
declare @cAux        char( 03 )
declare @cAux2       char( 01 )
declare @cAux3       char( 01 )
declare @cDataIni    char( 08 )
declare @cDataFim    char( 08 )
declare @cCV1_CT1INI char( 'CV1_CT1INI' )
declare @cCV1_CT1FIM char( 'CV1_CT1FIM' )
declare @cCV1_CTTINI char( 'CV1_CTTINI' )
declare @cCV1_CTTFIM char( 'CV1_CTTFIM' )
declare @cCV1_CTDINI char( 'CV1_CTDINI' )
declare @cCV1_CTDFIM char( 'CV1_CTDFIM' )
declare @cCV1_CTHINI char( 'CV1_CTHINI' )
declare @cCV1_CTHFIM char( 'CV1_CTHFIM' )
declare @cCV1_MOEDA	char( 'CV1_MOEDA' )
declare @cCV1_DTFIM	char( 'CV1_DTFIM' )
declare @nCV1_VALOR	float
declare @cCV1_STATUS	char( 'CV1_STATUS' )
Declare @cData       Char( 08 )
Declare @cDataF      Char( 08 )
Declare @cDataAnt    Char( 08 )
Declare @cContaAnt   char( 'CV1_CT1FIM' )
Declare @cCustoAnt   char( 'CV1_CTTFIM' )
Declare @cItemAnt    char( 'CV1_CTDFIM' )
Declare @cClvlAnt    char( 'CV1_CTHFIM' )
Declare @iMinRecno   integer
Declare @iMaxRecno   integer
Declare @iLinhas     integer

begin
   
   If @IN_FILIALDE = ' ' select @cCV1FilDe = ' '
   else select @cCV1FilDe = @IN_FILIALDE
   
   select @cAux = 'CT2'
   exec XFILIAL_## @cAux, @cCV1FilDe, @cFilial_CV1 OutPut
   
   /* ------------------------------------------------------------
      Variavel auxiliar
      ------------------------------------------------------------*/   
   select @iMinRecno = 0
   select @iMaxRecno = 0
   select @iLinhas   = 1024
   select @cAux2     = '0'
   
   Select @cDataIni = Isnull( Min( CV1_DTFIM ), '0' ), @cDataFim = Isnull( Max( CV1_DTFIM ), '1' )
     from CV1###
    where CV1_FILIAL between @cFilial_CV1 and @IN_FILIALATE
      and D_E_L_E_T_ = ' '
   
   if ( ( @cDataIni = '0' ) and ( @cDataFim = '1' ) ) begin
      --Nao Temos Dados para processar
      select @OUT_RESULTADO = '1'
   end else begin
      Select @cDataIni = Substring( @IN_DATAINI ,1,6 )||'01'
      Exec LASTDAY_## @IN_DATAFIM, @cDataF OutPut
      /* ------------------------------------------------------------
         ZERA SALDOS DE CONTAS CQ0/CQ1
         ------------------------------------------------------------*/
      select @cAux = 'CQ0'
      exec XFILIAL_## @cAux, @IN_FILIALDE, @cFilial_CQ0 OutPut
      EXEC CTB012_## @cAux,  @IN_LMOEDAESP, @IN_MOEDA, @cAux2, @cFilial_CQ0, @IN_FILIALATE, @IN_DATAINI, @IN_DATAFIM, @OUT_RESULTADO Output 
      
      select @cAux = 'CQ1'
      exec XFILIAL_## @cAux, @IN_FILIALDE, @cFilial_CQ1 OutPut
      EXEC CTB012_## @cAux,  @IN_LMOEDAESP, @IN_MOEDA, @cAux2, @cFilial_CQ1, @IN_FILIALATE, @IN_DATAINI, @IN_DATAFIM, @OUT_RESULTADO Output 
      /* ------------------------------------------------------------
         ZERA SALDOS DE CUSTOS
         ------------------------------------------------------------*/
      if @IN_LCUSTO = '1' begin
         select @cAux  = 'CQ2'
         exec XFILIAL_## @cAux, @IN_FILIALDE, @cFilial_CQ2 OutPut
         EXEC CTB012_## @cAux, @IN_LMOEDAESP, @IN_MOEDA, @cAux2, @cFilial_CQ2, @IN_FILIALATE, @IN_DATAINI, @IN_DATAFIM, @OUT_RESULTADO Output 
         
         select @cAux  = 'CQ3'
         exec XFILIAL_## @cAux, @IN_FILIALDE, @cFilial_CQ3 OutPut
         EXEC CTB012_## @cAux, @IN_LMOEDAESP, @IN_MOEDA, @cAux2, @cFilial_CQ3, @IN_FILIALATE, @IN_DATAINI, @IN_DATAFIM, @OUT_RESULTADO Output 
      end
      /* ------------------------------------------------------------
         ZERA SALDOS DE ITEM - CQ4/CQ5
         ------------------------------------------------------------*/
      if @IN_LITEM  = '1' begin
         select @cAux = 'CQ4'
         exec XFILIAL_## @cAux, @IN_FILIALDE, @cFilial_CQ4 OutPut
         EXEC CTB012_## @cAux, @IN_LMOEDAESP, @IN_MOEDA, @cAux2, @cFilial_CQ4, @IN_FILIALATE, @IN_DATAINI, @IN_DATAFIM, @OUT_RESULTADO Output 
         
         select @cAux = 'CQ5'
         exec XFILIAL_## @cAux, @IN_FILIALDE, @cFilial_CQ5 OutPut
         EXEC CTB012_## @cAux, @IN_LMOEDAESP, @IN_MOEDA, @cAux2, @cFilial_CQ5, @IN_FILIALATE, @IN_DATAINI, @IN_DATAFIM, @OUT_RESULTADO Output 
      end
      /* ------------------------------------------------------------
         ZERA SALDOS DE CLASSE VALOR - CQ6/CQ7
         ------------------------------------------------------------*/
      if @IN_LCLVL  = '1' begin
         select @cAux = 'CQ6'
         exec XFILIAL_## @cAux, @IN_FILIALDE, @cFilial_CQ6 OutPut
         EXEC CTB012_## @cAux, @IN_LMOEDAESP, @IN_MOEDA, @cAux2, @cFilial_CQ6, @IN_FILIALATE, @IN_DATAINI, @IN_DATAFIM, @OUT_RESULTADO Output
         
         select @cAux = 'CQ7'
         exec XFILIAL_## @cAux, @IN_FILIALDE, @cFilial_CQ7 OutPut
         EXEC CTB012_## @cAux, @IN_LMOEDAESP, @IN_MOEDA, @cAux2, @cFilial_CQ7, @IN_FILIALATE, @IN_DATAINI, @IN_DATAFIM, @OUT_RESULTADO Output
      end
      /* ------------------------------------------------------------------------
         ZERA SALDOS DE ENTIDADES - CQ8/CQ9
         Nos saldos por entidades zera todas as entidades
         ------------------------------------------------------------------------ */
      if @IN_LCUSTO = '1' or @IN_LITEM  = '1' or @IN_LCLVL  = '1' begin
         select @cAux = 'CQ8'
         exec XFILIAL_## @cAux, @IN_FILIALDE, @cFilial_CQ8 OutPut
         EXEC CTB012_## @cAux, @IN_LMOEDAESP, @IN_MOEDA, @cAux2, @cFilial_CQ8, @IN_FILIALATE, @IN_DATAINI, @IN_DATAFIM, @OUT_RESULTADO Output
         
         select @cAux = 'CQ9'
         exec XFILIAL_## @cAux, @IN_FILIALDE, @cFilial_CQ9 OutPut
         EXEC CTB012_## @cAux, @IN_LMOEDAESP, @IN_MOEDA, @cAux2, @cFilial_CQ9, @IN_FILIALATE, @IN_DATAINI, @IN_DATAFIM, @OUT_RESULTADO Output
      end
      
      select @cDataAnt  = ' '
      select @cContaAnt = ' '
      select @cCustoAnt = ' '
      select @cItemAnt  = ' '
      select @cClvlAnt  = ' '
      
      declare Ctb390Rep insensitive cursor for
         select CV1_FILIAL, CV1_CT1INI, CV1_CT1FIM, CV1_CTTINI, CV1_CTTFIM, CV1_CTDINI, CV1_CTDFIM, CV1_CTHINI,
                CV1_CTHFIM, CV1_MOEDA , CV1_DTFIM , CV1_STATUS, SUM(CV1_VALOR)
           from CV1### CV1
          where CV1.CV1_FILIAL between @cFilial_CV1 and @IN_FILIALATE
            and CV1.CV1_DTFIM between @IN_DATAINI and @IN_DATAFIM
            and CV1.CV1_STATUS = '2'
            and CV1.CV1_VALOR != 0
            and ( ( ( CV1.CV1_MOEDA = @IN_MOEDA ) AND ( @IN_LMOEDAESP = '1' ) ) OR ( @IN_LMOEDAESP = '0' ) )
            and CV1.D_E_L_E_T_ = ' '
      group by CV1_FILIAL, CV1_CT1INI, CV1_CT1FIM, CV1_CTTINI, CV1_CTTFIM, CV1_CTDINI, CV1_CTDFIM, CV1_CTHINI,
                CV1_CTHFIM, CV1_MOEDA , CV1_DTFIM , CV1_STATUS
      order by CV1_FILIAL, CV1_MOEDA, CV1_DTFIM, CV1_CTHINI, CV1_CTDINI, CV1_CTTINI, CV1_CT1INI
      for read only
      
      open Ctb390Rep
      fetch Ctb390Rep into @cCV1_FILIAL, @cCV1_CT1INI, @cCV1_CT1FIM, @cCV1_CTTINI, @cCV1_CTTFIM, @cCV1_CTDINI, @cCV1_CTDFIM,
                           @cCV1_CTHINI, @cCV1_CTHFIM, @cCV1_MOEDA , @cCV1_DTFIM , @cCV1_STATUS, @nCV1_VALOR
      
      while ( @@fetch_status = 0 ) begin
         select @cAux3 = '3'
         /* ------------------------------------------------------------
            Ctb390Atu - Reprocessa orçamentos
            ------------------------------------------------------------*/
         exec CTB003_## @cCV1_FILIAL, @cCV1_CTHINI, @cCV1_CTHFIM, @cCV1_CTDINI, @cCV1_CTDFIM,
                        @cCV1_CTTINI, @cCV1_CTTFIM, @cCV1_CT1INI, @cCV1_CT1FIM, @cCV1_MOEDA,
                        @cCV1_DTFIM,  @nCV1_VALOR,  @IN_OPERACAO, @cAux3,       @cDataAnt, 
                        @cContaAnt,   @cCustoAnt,   @cItemAnt,    @cClvlAnt,    @OUT_RESULTADO Output
                        
         select @cDataAnt  = @cCV1_DTFIM
         select @cContaAnt = @cCV1_CT1INI
         select @cCustoAnt = @cCV1_CTTINI
         select @cItemAnt  = @cCV1_CTDINI
         select @cClvlAnt  = @cCV1_CTHINI
         /* --------------------------------------------------------------------------------------------------------------
			 Tratamento para o DB2
		  -------------------------------------------------------------------------------------------------------------- */
		  SELECT @fim_CUR = 0
         fetch Ctb390Rep into @cCV1_FILIAL, @cCV1_CT1INI, @cCV1_CT1FIM, @cCV1_CTTINI, @cCV1_CTTFIM, @cCV1_CTDINI, @cCV1_CTDFIM,
                              @cCV1_CTHINI, @cCV1_CTHFIM, @cCV1_MOEDA , @cCV1_DTFIM , @cCV1_STATUS, @nCV1_VALOR
      end
      close Ctb390Rep
      deallocate Ctb390Rep
      /* -------------------------------------------------------------------------------------------------
         APAGA os registros de saldos que nao possuem saldo  ou Marca os registros como apagado antes de
         'deletar' - so com integridade ligada   - Apaga CCUSTOS zerados
         -------------------------------------------------------------------------------------------------- */
      if ( @IN_LCUSTO = '1' ) begin
         select @iMinRecno = 0
         select @iMaxRecno = 0
         select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
           from CQ2###
          where CQ2_FILIAL between @cFilial_CQ2 and @IN_FILIALATE
            and CQ2_DEBITO = 0
            and CQ2_CREDIT = 0
            and CQ2_TPSALD = '0'
            and D_E_L_E_T_ = ' '
         
         If @iMinRecno != 0 begin
            While ( @iMinRecno <= @iMaxRecno ) begin
               begin tran
               If @IN_MVCTB190D = '1' begin
                  If @IN_INTEGRIDADE = '1' begin
                     Update CQ2###
                        Set D_E_L_E_T_ = '*'
                      Where CQ2_FILIAL between @cFilial_CQ2 and @IN_FILIALATE
                        and CQ2_DEBITO = 0
                        and CQ2_CREDIT = 0
                        and CQ2_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               
                     Delete From CQ2###
                      Where CQ2_FILIAL between @cFilial_CQ2 and @IN_FILIALATE
                        and CQ2_DEBITO = 0
                        and CQ2_CREDIT = 0
                        and CQ2_TPSALD = '0'
                        and D_E_L_E_T_ = '*'
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  end else begin
                     Delete From CQ2###
                      Where CQ2_FILIAL between @cFilial_CQ2 and @IN_FILIALATE
                        and CQ2_DEBITO = 0
                        and CQ2_CREDIT = 0
                        and CQ2_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  End
               end else begin
                  Update CQ2###
                     Set D_E_L_E_T_ = '*'
                        ##FIELDP01( 'CQ2.R_E_C_D_E_L_' )
                           , R_E_C_D_E_L_ = R_E_C_N_O_
                        ##ENDFIELDP01
                   Where CQ2_FILIAL between @cFilial_CQ2 and @IN_FILIALATE
                     and CQ2_DEBITO = 0
                     and CQ2_CREDIT = 0
                     and CQ2_TPSALD = '0'
                     and D_E_L_E_T_ = ' '
                     and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               end
               commit tran
               select @iMinRecno = @iMinRecno + @iLinhas
            End
         End
         /* ------------------------------------------------------------
            Apaga CQ3 - CCUSTOS zerados DIA
            ------------------------------------------------------------*/
         select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
           from CQ3###
          where CQ3_FILIAL between @cFilial_CQ3 and @IN_FILIALATE
            and CQ3_DEBITO = 0
            and CQ3_CREDIT = 0
            and CQ3_TPSALD = '0'
            and D_E_L_E_T_ = ' '
            
         If @iMinRecno != 0 begin
            While ( @iMinRecno <= @iMaxRecno ) begin
               begin tran
               If @IN_MVCTB190D = '1' begin
                  If @IN_INTEGRIDADE = '1' begin
                     Update CQ3###
                        Set D_E_L_E_T_ = '*'
                      Where CQ3_FILIAL between @cFilial_CQ3 and @IN_FILIALATE
                        and CQ3_DEBITO = 0
                        and CQ3_CREDIT = 0
                        and CQ3_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                     
                     Delete From CQ3###
                      Where CQ3_FILIAL between @cFilial_CQ3 and @IN_FILIALATE
                        and CQ3_DEBITO = 0
                        and CQ3_CREDIT = 0
                        and CQ3_TPSALD = '0'
                        and D_E_L_E_T_ = '*'
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  end else begin
                     Delete From CQ3###
                      Where CQ3_FILIAL between @cFilial_CQ3 and @IN_FILIALATE
                        and CQ3_DEBITO = 0
                        and CQ3_CREDIT = 0
                        and CQ3_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  End
               end else begin
                  Update CQ3###
                     Set D_E_L_E_T_ = '*'
                        ##FIELDP01( 'CQ3.R_E_C_D_E_L_' )
                           , R_E_C_D_E_L_ = R_E_C_N_O_
                        ##ENDFIELDP01
                   Where CQ3_FILIAL between @cFilial_CQ3 and @IN_FILIALATE
                     and CQ3_DEBITO = 0
                     and CQ3_CREDIT = 0
                     and CQ3_TPSALD = '0'
                     and D_E_L_E_T_ = ' '
                     and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               end
               commit tran
               select @iMinRecno = @iMinRecno + @iLinhas
            End
         End
      End
      /* ------------------------------------------------------------
         Apaga CQ4 - ITEM zerados MES
         ------------------------------------------------------------*/
      if ( @IN_LITEM = '1' ) begin
         select @iMinRecno = 0
         select @iMaxRecno = 0
         select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
           from CQ4###
          where CQ4_FILIAL between @cFilial_CQ4 and @IN_FILIALATE
            and CQ4_DEBITO = 0
            and CQ4_CREDIT = 0
            and CQ4_TPSALD = '0'
            and D_E_L_E_T_ = ' '
            
         If @iMinRecno != 0 begin
            While ( @iMinRecno <= @iMaxRecno ) begin
               begin tran
               If @IN_MVCTB190D = '1' begin
                  If @IN_INTEGRIDADE = '1' begin
                     Update CQ4###
                        Set D_E_L_E_T_ = '*'
                      Where CQ4_FILIAL between @cFilial_CQ4 and @IN_FILIALATE
                        and CQ4_DEBITO = 0
                        and CQ4_CREDIT = 0
                        and CQ4_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               
                     Delete From CQ4###
                      Where CQ4_FILIAL between @cFilial_CQ4 and @IN_FILIALATE
                        and CQ4_DEBITO = 0
                        and CQ4_CREDIT = 0
                        and CQ4_TPSALD = '0'
                        and D_E_L_E_T_ = '*'
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  end else begin
                     Delete From CQ4###
                      Where CQ4_FILIAL between @cFilial_CQ4 and @IN_FILIALATE
                        and CQ4_DEBITO = 0
                        and CQ4_CREDIT = 0
                        and CQ4_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  End
               end else begin
                  Update CQ4###
                     Set D_E_L_E_T_ = '*'
                        ##FIELDP01( 'CQ4.R_E_C_D_E_L_' )
                           , R_E_C_D_E_L_ = R_E_C_N_O_
                        ##ENDFIELDP01
                   Where CQ4_FILIAL between @cFilial_CQ4 and @IN_FILIALATE
                     and CQ4_DEBITO = 0
                     and CQ4_CREDIT = 0
                     and CQ4_TPSALD = '0'
                     and D_E_L_E_T_ = ' '
                     and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               end
               commit tran
               select @iMinRecno = @iMinRecno + @iLinhas
            End
         End
         /* ------------------------------------------------------------
            Apaga CQ5 - ITEM zerados DIA
            ------------------------------------------------------------*/
         select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
           from CQ5###
          where CQ5_FILIAL between @cFilial_CQ5 and @IN_FILIALATE
            and CQ5_DEBITO = 0
            and CQ5_CREDIT = 0
            and CQ5_TPSALD = '0'
            and D_E_L_E_T_ = ' '
            
         If @iMinRecno != 0 begin
            While ( @iMinRecno <= @iMaxRecno ) begin
               begin tran
               If @IN_MVCTB190D = '1' begin
                  If @IN_INTEGRIDADE = '1' begin
                     Update CQ5###
                        Set D_E_L_E_T_ = '*'
                      Where CQ5_FILIAL between @cFilial_CQ5 and @IN_FILIALATE
                        and CQ5_DEBITO = 0
                        and CQ5_CREDIT = 0
                        and CQ5_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               
                     Delete From CQ5###
                      Where CQ5_FILIAL between @cFilial_CQ5 and @IN_FILIALATE
                        and CQ5_DEBITO = 0
                        and CQ5_CREDIT = 0
                        and CQ5_TPSALD = '0'
                        and D_E_L_E_T_ = '*'
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  end else begin
                     Delete From CQ5###
                      Where CQ5_FILIAL between @cFilial_CQ5 and @IN_FILIALATE
                        and CQ5_DEBITO = 0
                        and CQ5_CREDIT = 0
                        and CQ5_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  End
               end else begin
                  Update CQ5###
                     Set D_E_L_E_T_ = '*'
                        ##FIELDP01( 'CQ5.R_E_C_D_E_L_' )
                           , R_E_C_D_E_L_ = R_E_C_N_O_
                        ##ENDFIELDP01
                   Where CQ5_FILIAL between @cFilial_CQ5 and @IN_FILIALATE
                     and CQ5_DEBITO = 0
                     and CQ5_CREDIT = 0
                     and CQ5_TPSALD = '0'
                     and D_E_L_E_T_ = ' '
                     and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               end
               commit tran
               select @iMinRecno = @iMinRecno + @iLinhas
            End
         End
      End
      /* ------------------------------------------------------------
         Apaga CQ6 - CLVL zerados MES
         ------------------------------------------------------------*/
      if ( @IN_LCLVL = '1' ) begin
         select @iMinRecno = 0
         select @iMaxRecno = 0
         select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
           from CQ6###
          where CQ6_FILIAL between @cFilial_CQ6 and @IN_FILIALATE
            and CQ6_DEBITO = 0
            and CQ6_CREDIT = 0
            and CQ6_TPSALD = '0'
            and D_E_L_E_T_ = ' '
            
         If @iMinRecno != 0 begin
            While ( @iMinRecno <= @iMaxRecno ) begin
               begin tran
               If @IN_MVCTB190D = '1' begin
                  If @IN_INTEGRIDADE = '1' begin
                     Update CQ6###
                        Set D_E_L_E_T_ = '*'
                      Where CQ6_FILIAL between @cFilial_CQ6 and @IN_FILIALATE
                        and CQ6_DEBITO = 0
                        and CQ6_CREDIT = 0
                        and CQ6_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               
                     Delete From CQ6###
                      Where CQ6_FILIAL between @cFilial_CQ6 and @IN_FILIALATE
                        and CQ6_DEBITO = 0
                        and CQ6_CREDIT = 0
                        and CQ6_TPSALD = '0'
                        and D_E_L_E_T_ = '*'
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  end else begin
                     Delete From CQ6###
                      Where CQ6_FILIAL between @cFilial_CQ6 and @IN_FILIALATE
                        and CQ6_DEBITO = 0
                        and CQ6_CREDIT = 0
                        and CQ6_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  End
               end else begin
                  Update CQ6###
                     Set D_E_L_E_T_ = '*'
                        ##FIELDP01( 'CQ6.R_E_C_D_E_L_' )
                           , R_E_C_D_E_L_ = R_E_C_N_O_
                        ##ENDFIELDP01
                   Where CQ6_FILIAL between @cFilial_CQ6 and @IN_FILIALATE
                     and CQ6_DEBITO = 0
                     and CQ6_CREDIT = 0
                     and CQ6_TPSALD = '0'
                     and D_E_L_E_T_ = ' '
                     and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               end
               commit tran
               select @iMinRecno = @iMinRecno + @iLinhas
            End
         End
         /* ------------------------------------------------------------
            Apaga CQ7 - CLVL zerados DIA
            ------------------------------------------------------------*/
         select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
           from CQ7###
          where CQ7_FILIAL between @cFilial_CQ7 and @IN_FILIALATE
            and CQ7_DEBITO = 0
            and CQ7_CREDIT = 0
            and CQ7_TPSALD = '0'
            and D_E_L_E_T_ = ' '
            
         If @iMinRecno != 0 begin
            While ( @iMinRecno <= @iMaxRecno ) begin
               begin tran
               If @IN_MVCTB190D = '1' begin
                  If @IN_INTEGRIDADE = '1' begin
                     Update CQ7###
                        Set D_E_L_E_T_ = '*'
                      Where CQ7_FILIAL between @cFilial_CQ7 and @IN_FILIALATE
                        and CQ7_DEBITO = 0
                        and CQ7_CREDIT = 0
                        and CQ7_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               
                     Delete From CQ7###
                      Where CQ7_FILIAL between @cFilial_CQ7 and @IN_FILIALATE
                        and CQ7_DEBITO = 0
                        and CQ7_CREDIT = 0
                        and CQ7_TPSALD = '0'
                        and D_E_L_E_T_ = '*'
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  end else begin
                     Delete From CQ7###
                      Where CQ7_FILIAL between @cFilial_CQ7 and @IN_FILIALATE
                        and CQ7_DEBITO = 0
                        and CQ7_CREDIT = 0
                        and CQ7_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  End
               end else begin
                  Update CQ7###
                     Set D_E_L_E_T_ = '*'
                        ##FIELDP01( 'CQ7.R_E_C_D_E_L_' )
                           , R_E_C_D_E_L_ = R_E_C_N_O_
                        ##ENDFIELDP01
                   Where CQ7_FILIAL between @cFilial_CQ7 and @IN_FILIALATE
                     and CQ7_DEBITO = 0
                     and CQ7_CREDIT = 0
                     and CQ7_TPSALD = '0'
                     and D_E_L_E_T_ = ' '
                     and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               end
               commit tran
               select @iMinRecno = @iMinRecno + @iLinhas
            End
         End
      End
      /* ------------------------------------------------------------
         Apaga CQ8/CQ9 - ENTIDADES 
         ------------------------------------------------------------*/
      if @IN_LCUSTO = '1' or @IN_LITEM = '1' or @IN_LCLVL = '1' begin
         /* ------------------------------------------------------------
            Apaga CQ8 - ENTIDADES zerados MES
            ------------------------------------------------------------*/
         select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
           from CQ8###
          where CQ8_FILIAL between @cFilial_CQ8 and @IN_FILIALATE
            and CQ8_DEBITO = 0
            and CQ8_CREDIT = 0
            and CQ8_TPSALD = '0'
            and D_E_L_E_T_ = ' '
               
         If @iMinRecno != 0 begin
            While ( @iMinRecno <= @iMaxRecno ) begin
               begin tran
               If @IN_MVCTB190D = '1' begin
                  If @IN_INTEGRIDADE = '1' begin
                     Update CQ8###
                        Set D_E_L_E_T_ = '*'
                      Where CQ8_FILIAL between @cFilial_CQ8 and @IN_FILIALATE
                        and CQ8_DEBITO = 0
                        and CQ8_CREDIT = 0
                        and CQ8_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               
                     Delete From CQ8###
                      Where CQ8_FILIAL between @cFilial_CQ8 and @IN_FILIALATE
                        and CQ8_DEBITO = 0
                        and CQ8_CREDIT = 0
                        and CQ8_TPSALD = '0'
                        and D_E_L_E_T_ = '*'
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  end else begin
                     Delete From CQ8###
                      Where CQ8_FILIAL between @cFilial_CQ8 and @IN_FILIALATE
                        and CQ8_DEBITO = 0
                        and CQ8_CREDIT = 0
                        and CQ8_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  End
               end else begin
                  Update CQ8###
                     Set D_E_L_E_T_ = '*'
                        ##FIELDP01( 'CQ8.R_E_C_D_E_L_' )
                           , R_E_C_D_E_L_ = R_E_C_N_O_
                        ##ENDFIELDP01
                   Where CQ8_FILIAL between @cFilial_CQ8 and @IN_FILIALATE
                     and CQ8_DEBITO = 0
                     and CQ8_CREDIT = 0
                     and CQ8_TPSALD = '0'
                     and D_E_L_E_T_ = ' '
                     and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               end
               commit tran
               select @iMinRecno = @iMinRecno + @iLinhas
            End
         End      
         /* ------------------------------------------------------------
            Apaga CQ8 - ENTIDADES zerados DIA
            ------------------------------------------------------------*/
         select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
           from CQ9###
          where CQ9_FILIAL between @cFilial_CQ9 and @IN_FILIALATE
            and CQ9_DEBITO = 0
            and CQ9_CREDIT = 0
            and CQ9_TPSALD = '0'
            and D_E_L_E_T_ = ' '
            
         If @iMinRecno != 0 begin
            While ( @iMinRecno <= @iMaxRecno ) begin
               begin tran
               If @IN_MVCTB190D = '1' begin
                  If @IN_INTEGRIDADE = '1' begin
                     Update CQ9###
                        Set D_E_L_E_T_ = '*'
                      Where CQ9_FILIAL between @cFilial_CQ9 and @IN_FILIALATE
                        and CQ9_DEBITO = 0
                        and CQ9_CREDIT = 0
                        and CQ9_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               
                     Delete From CQ9###
                      Where CQ9_FILIAL between @cFilial_CQ9 and @IN_FILIALATE
                        and CQ9_DEBITO = 0
                        and CQ9_CREDIT = 0
                        and CQ9_TPSALD = '0'
                        and D_E_L_E_T_ = '*'
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  end else begin
                     Delete From CQ9###
                      Where CQ9_FILIAL between @cFilial_CQ9 and @IN_FILIALATE
                        and CQ9_DEBITO = 0
                        and CQ9_CREDIT = 0
                        and CQ9_TPSALD = '0'
                        and D_E_L_E_T_ = ' '
                        and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
                  End
               end else begin
                  Update CQ9###
                     Set D_E_L_E_T_ = '*'
                        ##FIELDP01( 'CQ9.R_E_C_D_E_L_' )
                           , R_E_C_D_E_L_ = R_E_C_N_O_
                        ##ENDFIELDP01
                   Where CQ9_FILIAL between @cFilial_CQ9 and @IN_FILIALATE
                     and CQ9_DEBITO = 0
                     and CQ9_CREDIT = 0
                     and CQ9_TPSALD = '0'
                     and D_E_L_E_T_ = ' '
                     and R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iLinhas
               end
               commit tran
               select @iMinRecno = @iMinRecno + @iLinhas
            End
         End
      End
   End
   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
   --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end
