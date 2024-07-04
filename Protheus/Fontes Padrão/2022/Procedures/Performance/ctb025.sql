Create procedure CTB025_##
( 
   @IN_FILIALCOR    Char('CQ0_FILIAL'),
   @IN_TABELA       Char(03),
   @IN_IDENT        Char(03),
   @IN_CONTA        Char('CQ0_CONTA'),
   @IN_CUSTO        Char('CQ2_CCUSTO'),
   @IN_ITEM         Char('CQ4_ITEM'),
   @IN_CLVL         Char('CQ6_CLVL'),
   @IN_DATALP       Char(08),
   @IN_MOEDA        Char('CQ0_MOEDA'),
   @IN_TPSALDO      Char('CT2_TPSALD'),
   @IN_EMPANT       Char(02),
   @IN_FILANT       Char('CT2_FILIAL'), 
   @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Atualiza os flags dos saldos ref. lucros/perdas </d>
    Funcao do Siga  -      Ct190FlgLP()     - Atualiza os flags dos saldos ref. lucros/perdas
    Entrada         - <ri> @IN_FILIALCOR    - Filial Corrente
                           @IN_TABELA       - Tabela a processar
                           @IN_IDENT        - Sub tabela
                           @IN_CONTA        - Conta
                           @IN_CCUSTO       - CCusto
                           @IN_ITEM         - Item
                           @IN_CLVL         - Classe de Valor
                           @IN_DATALP       - Data Ap L/P
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     18/11/2003
-------------------------------------------------------------------------------------- */
Declare @iMin            Integer
Declare @iMax            Integer
Declare @cDataF          Char(08)
Declare @cApuracao       Char( 'CW0_DESC01' )
Declare @cApuracaoAnt    Char( 'CW0_DESC01' )
Declare @cAux            Char(03)
Declare @cFilial_CW0     Char( 'CT2_FILIAL' )
Declare @cDataI          Char(08)
Declare @cCW0_DESC01Aux1 Char( 'CW0_DESC01' )
Declare @cCW0_CHAVE      Char( 'CW0_CHAVE' )
Declare @cDataLpAnt      Char(08)

begin
   
    select @OUT_RESULTADO = '0'
    Exec LASTDAY_## @IN_DATALP, @cDataF OutPut
    select @cDataI = Substring(@IN_DATALP, 1, 6)||'01'
    
    select @cAux = 'CW0'
    exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CW0 OutPut
    
    Select @iMin      = 0
    Select @cDataF    = ' '
    Select @cApuracao = ' '
    Select @cApuracaoAnt  = ' '
    select @cCW0_DESC01Aux1 = ' '
    select @cCW0_CHAVE = ' '
    select @cDataLpAnt = ' '
    /* -----------------------------------------------------------------------------------------------------
       20150131011P - Mesmo com duas AP Ponte no mesmo dias, grava UMA CW0
       20150131011Z - Idem 
       Gravar 'S' em datas anteriores somente quando for apuracao de zeramento
       1 - Verificar se @IN_DATALP é Apur de Zeramento, se sim, executa os próximos passos abaixo
           2 - Busca no CW0 - a maior data de apuração de zeramento anterior a @IN_DATALP ( @IN_DATALP-1 )
              2.a - Se não achar, gravo 'S' em todos
              2.b - Se achar, gravo 'S' de @IN_DATALP-1 (zeramento anterior) até @IN_DATALP
       ---------------------------------------------------------------------------------------------------- */
    Select @cCW0_DESC01Aux1 = @IN_DATALP||@IN_MOEDA||@IN_TPSALDO||'Z'
        /* ----------------------------------------------------------------------------------------------------
       20150531011Z
       1 - Verificar se @IN_DATALP é Apur de Zeramento, se sim, executa os próximos passos abaixo
       ----------------------------------------------------------------------------------------------------- */
    Select @cApuracao = IsNull(CW0_DESC01, ' ')
      From CW0###
     WHERE CW0_FILIAL = @cFilial_CW0
       and CW0_TABELA = 'LP'
       and CW0_CHAVE  = @IN_EMPANT||@IN_FILANT   --'T1X CT101      '
       AND CW0_DESC01 = @cCW0_DESC01Aux1
       and D_E_L_E_T_ = ' '

    If @cApuracao != ' ' begin 
        /* -----------------------------------------------------------------------------------------------
           2 - Busca no CW0 - a maior data de apuração de zeramento anterior a @IN_DATALP ( @IN_DATALP-1 )
                  2.a - Se não achar, gravo 'S' em todos
                  2.b - Se achar, gravo 'S' de @IN_DATALP-1 (zeramento anterior) até @IN_DATALP
          ------------------------------------------------------------------------------------------------- */
        Select @cApuracaoAnt = IsNull(MAX(CW0_DESC01), ' ')
          From CW0###
         WHERE CW0_FILIAL  = @cFilial_CW0
           and CW0_TABELA  = 'LP'
           and CW0_CHAVE   = @IN_EMPANT||@IN_FILANT
           and CW0_DESC01  < @cCW0_DESC01Aux1
           and SUBSTRING (CW0_DESC01, 9, 04) = @IN_MOEDA||@IN_TPSALDO||'Z'
           and D_E_L_E_T_ = ' '
        
        If @cApuracaoAnt != ' ' begin
           select @cDataLpAnt = Substring( @cApuracaoAnt, 1, 8 )
           select @cDataI = Convert( char( 08 ), dateadd( day, 1, @cDataLpAnt ), 112 )
           select @cDataF = @IN_DATALP
        end else begin
           select @cDataI = ' '
           select @cDataF = @IN_DATALP
        End
        /*---------------------------------------------------------------
           Atualiza CQ0 - Saldo MES de Plano de Contas
          --------------------------------------------------------------- */
        If @IN_TABELA = 'CQ0' begin
            Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
              From CQ0###
             Where CQ0_FILIAL  = @IN_FILIALCOR
               and CQ0_CONTA   = @IN_CONTA
               and CQ0_DATA between @cDataI and @cDataF
               and CQ0_TPSALD  = @IN_TPSALDO
               and CQ0_MOEDA   = @IN_MOEDA
               and CQ0_LP     in( 'N', ' ')
               and D_E_L_E_T_  = ' '
            
            If @iMin > 0 begin
                While ( @iMin <= @iMax) begin
                    /* ---------------------------------------------------------------
                       Atualiza flags de L/P
                       --------------------------------------------------------------- */
                    begin tran
                    Update CQ0###
                       Set CQ0_LP ='S',  CQ0_DTLP = @IN_DATALP
                     Where CQ0_FILIAL  = @IN_FILIALCOR
                       and CQ0_CONTA   = @IN_CONTA
                       and CQ0_DATA    between @cDataI and @cDataF
                       and CQ0_MOEDA   = @IN_MOEDA
                       and CQ0_TPSALD  = @IN_TPSALDO
                       and CQ0_LP     in( 'N', ' ')
                       and D_E_L_E_T_  = ' '
                       and R_E_C_N_O_  between @iMin and @iMin + 5000
                    commit tran
                    select @iMin = @iMin + 5000
                End
            End
        End
        /*---------------------------------------------------------------
            Atualiza CQ1 - Saldo DIA de Plano de Contas
          --------------------------------------------------------------- */
        If @IN_TABELA = 'CQ1' begin
            Select  @iMin = Isnull(Min(R_E_C_N_O_),0)  ,  @iMax = Isnull(Max(R_E_C_N_O_),0)
              From CQ1###
             Where CQ1_FILIAL  = @IN_FILIALCOR
               and CQ1_CONTA   = @IN_CONTA
               and CQ1_DATA    between  @cDataI and @cDataF
               and CQ1_TPSALD  = @IN_TPSALDO
               and CQ1_MOEDA   = @IN_MOEDA
               and CQ1_LP     in( 'N', ' ')
               and D_E_L_E_T_  = ' '
           
            If @iMin > 0 begin
                While ( @iMin <= @iMax) begin
                    /*---------------------------------------------------------------
                        Atualiza flags de L/P
                        --------------------------------------------------------------- */         
                    begin tran
                    Update CQ1###
                       Set CQ1_LP ='S',  CQ1_DTLP = @IN_DATALP
                     Where CQ1_FILIAL  = @IN_FILIALCOR
                       and CQ1_CONTA   = @IN_CONTA
                       and CQ1_DATA    between @cDataI and @cDataF
                       and CQ1_MOEDA   = @IN_MOEDA
                       and CQ1_TPSALD  = @IN_TPSALDO
                       and CQ1_LP     in( 'N', ' ')
                       and D_E_L_E_T_  = ' '
                       and R_E_C_N_O_  between @iMin and @iMin + 5000
                    commit tran
                    select @iMin = @iMin + 5000
                End
            End
        End
        /*---------------------------------------------------------------
        Atualiza CQ2 - Saldos MES de Centros de Custos
        --------------------------------------------------------------- */
        If @IN_TABELA = 'CQ2' begin
            Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
              From CQ2###
             Where CQ2_FILIAL  = @IN_FILIALCOR
               and CQ2_CCUSTO  = @IN_CUSTO
               and CQ2_CONTA   = @IN_CONTA
               and CQ2_DATA    between @cDataI and @cDataF
               and CQ2_TPSALD  = @IN_TPSALDO
               and CQ2_MOEDA   = @IN_MOEDA
               and CQ2_LP     in( 'N', ' ')
               and D_E_L_E_T_  = ' '
      
            if @iMin > 0 begin
                While ( @iMin <= @iMax ) begin
                   /*---------------------------------------------------------------
                       Atualiza flags de L/P
                       --------------------------------------------------------------- */         
                   begin tran
                   Update CQ2###
                      Set CQ2_LP ='S',  CQ2_DTLP = @IN_DATALP
                    Where CQ2_FILIAL  = @IN_FILIALCOR
                      and CQ2_CCUSTO  = @IN_CUSTO
                      and CQ2_CONTA   = @IN_CONTA
                      and CQ2_DATA    between @cDataI and @cDataF
                      and CQ2_MOEDA   = @IN_MOEDA
                      and CQ2_TPSALD  = @IN_TPSALDO
                      and CQ2_LP      in( 'N', ' ')
                      and D_E_L_E_T_  = ' '
                      and R_E_C_N_O_  between @iMin and @iMin + 5000
                   commit tran
                   select @iMin = @iMin + 5000
                End
            End
        End
        /*---------------------------------------------------------------
        Atualiza CQ3 - Saldos DIA de Centros de Custos
        --------------------------------------------------------------- */
        If @IN_TABELA = 'CQ3' begin
            Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
              From CQ3###
             Where CQ3_FILIAL  = @IN_FILIALCOR
               and CQ3_CCUSTO  = @IN_CUSTO
               and CQ3_CONTA   = @IN_CONTA
               and CQ3_DATA   between @cDataI and @cDataF
               and CQ3_TPSALD  = @IN_TPSALDO
               and CQ3_MOEDA   = @IN_MOEDA
               and CQ3_LP     in( 'N', ' ')
               and D_E_L_E_T_  = ' '
      
            if @iMin > 0 begin
                While ( @iMin <= @iMax ) begin
                   /*---------------------------------------------------------------
                       Atualiza flags de L/P
                       --------------------------------------------------------------- */         
                   begin tran
                   Update CQ3###
                      Set CQ3_LP ='S',  CQ3_DTLP = @IN_DATALP
                    Where CQ3_FILIAL  = @IN_FILIALCOR
                      and CQ3_CCUSTO  = @IN_CUSTO
                      and CQ3_CONTA   = @IN_CONTA
                      and CQ3_DATA    between @cDataI and @cDataF
                      and CQ3_MOEDA   = @IN_MOEDA
                      and CQ3_TPSALD  = @IN_TPSALDO
                      and CQ3_LP      in( 'N', ' ')
                      and D_E_L_E_T_  = ' '
                      and R_E_C_N_O_  between @iMin and @iMin + 5000
                   commit tran
                   select @iMin = @iMin + 5000
                End
            End
        End
        /*---------------------------------------------------------------
        Atualiza CQ4 - Saldos MES de Item
        --------------------------------------------------------------- */
        If @IN_TABELA = 'CQ4' begin
            Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
              From CQ4###
             Where CQ4_FILIAL  = @IN_FILIALCOR
               and CQ4_ITEM    = @IN_ITEM
               and CQ4_CCUSTO  = @IN_CUSTO
               and CQ4_CONTA   = @IN_CONTA
               and CQ4_DATA    between @cDataI and @cDataF
               and CQ4_TPSALD  = @IN_TPSALDO
               and CQ4_MOEDA   = @IN_MOEDA
               and CQ4_LP      in( 'N', ' ')
               and D_E_L_E_T_  = ' '
      
            If @iMin > 0 begin
                While ( @iMin <= @iMax ) begin
                   /*---------------------------------------------------------------
                       Atualiza flags de L/P
                       --------------------------------------------------------------- */  
                   begin tran       
                   Update CQ4###
                      Set CQ4_LP ='S',  CQ4_DTLP = @IN_DATALP
                    Where CQ4_FILIAL  = @IN_FILIALCOR
                      and CQ4_ITEM    = @IN_ITEM
                      and CQ4_CCUSTO  = @IN_CUSTO
                      and CQ4_CONTA   = @IN_CONTA
                      and CQ4_DATA    between @cDataI and @cDataF
                      and CQ4_MOEDA   = @IN_MOEDA
                      and CQ4_TPSALD  = @IN_TPSALDO
                      and CQ4_LP     in( 'N', ' ')
                      and D_E_L_E_T_  = ' '
                      and R_E_C_N_O_  between @iMin and @iMin + 5000
                   commit tran
                   select @iMin = @iMin + 5000
                End
            End
        End
        /*---------------------------------------------------------------
        Atualiza CQ5 - Saldos DIA de Item
        --------------------------------------------------------------- */
        If @IN_TABELA = 'CQ5' begin
            Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
              From CQ5###
             Where CQ5_FILIAL  = @IN_FILIALCOR
               and CQ5_ITEM    = @IN_ITEM
               and CQ5_CCUSTO  = @IN_CUSTO
               and CQ5_CONTA   = @IN_CONTA
               and CQ5_DATA    between @cDataI and @cDataF
               and CQ5_TPSALD  = @IN_TPSALDO
               and CQ5_MOEDA   = @IN_MOEDA
               and CQ5_LP     in( 'N', ' ')
               and D_E_L_E_T_  = ' '
      
            If @iMin > 0 begin
                While ( @iMin <= @iMax ) begin
                /*---------------------------------------------------------------
                    Atualiza flags de L/P
                    --------------------------------------------------------------- */  
                begin tran       
                Update CQ5###
                   Set CQ5_LP ='S',  CQ5_DTLP = @IN_DATALP
                 Where CQ5_FILIAL  = @IN_FILIALCOR
                   and CQ5_ITEM    = @IN_ITEM
                   and CQ5_CCUSTO  = @IN_CUSTO
                   and CQ5_CONTA   = @IN_CONTA
                   and CQ5_DATA    between @cDataI and @cDataF 
                   and CQ5_MOEDA   = @IN_MOEDA
                   and CQ5_TPSALD  = @IN_TPSALDO
                   and CQ5_LP      in( 'N', ' ')
                   and D_E_L_E_T_  = ' '
                   and R_E_C_N_O_  between @iMin and @iMin + 5000
                commit tran
                select @iMin = @iMin + 5000
                End
            End
        End
        /*  ---------------------------------------------------------------
        Atualiza CQ6 - Saldos MES de Classe de Valores
        --------------------------------------------------------------- */
        If @IN_TABELA = 'CQ6' begin
            Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
              From CQ6###
             Where CQ6_FILIAL  = @IN_FILIALCOR
               and CQ6_CLVL    = @IN_CLVL
               and CQ6_ITEM    = @IN_ITEM
               and CQ6_CCUSTO  = @IN_CUSTO
               and CQ6_CONTA   = @IN_CONTA
               and CQ6_DATA    between @cDataI and @cDataF
               and CQ6_TPSALD  = @IN_TPSALDO
               and CQ6_MOEDA   = @IN_MOEDA
               and CQ6_LP     in( 'N', ' ')
               and D_E_L_E_T_  = ' '
      
            If @iMin > 0 begin
                While ( @iMin <= @iMax ) begin
                   /*---------------------------------------------------------------
                       Atualiza flags de L/P
                       --------------------------------------------------------------- */         
                   begin tran
                   Update CQ6###
                      Set CQ6_LP ='S',  CQ6_DTLP = @IN_DATALP
                    Where CQ6_FILIAL  = @IN_FILIALCOR
                      and CQ6_CLVL    = @IN_CLVL
                      and CQ6_ITEM    = @IN_ITEM
                      and CQ6_CCUSTO  = @IN_CUSTO
                      and CQ6_CONTA   = @IN_CONTA
                      and CQ6_DATA    between @cDataI and @cDataF
                      and CQ6_MOEDA   = @IN_MOEDA
                      and CQ6_TPSALD  = @IN_TPSALDO
                      and CQ6_LP     in( 'N', ' ')
                      and D_E_L_E_T_  = ' '
                      and R_E_C_N_O_  between @iMin and @iMin + 5000
                   commit tran
                   select @iMin = @iMin + 5000
                End
            End
        End
        /*  ---------------------------------------------------------------
        Atualiza CQ7 - Saldos DIA de Classe de Valores
        --------------------------------------------------------------- */
        If @IN_TABELA = 'CQ7' begin
            Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
              From CQ7###
             Where CQ7_FILIAL  = @IN_FILIALCOR
               and CQ7_CLVL    = @IN_CLVL
               and CQ7_ITEM    = @IN_ITEM
               and CQ7_CCUSTO  = @IN_CUSTO
               and CQ7_CONTA   = @IN_CONTA
               and CQ7_DATA    between @cDataI and @cDataF
               and CQ7_TPSALD  = @IN_TPSALDO
               and CQ7_MOEDA   = @IN_MOEDA
               and CQ7_LP     in( 'N', ' ')
               and D_E_L_E_T_  = ' '
      
            If @iMin > 0 begin
                While ( @iMin <= @iMax ) begin
                   /*---------------------------------------------------------------
                       Atualiza flags de L/P
                       --------------------------------------------------------------- */         
                   begin tran
                   Update CQ7###
                      Set CQ7_LP ='S',  CQ7_DTLP = @IN_DATALP
                    Where CQ7_FILIAL  = @IN_FILIALCOR
                      and CQ7_CLVL    = @IN_CLVL
                      and CQ7_ITEM    = @IN_ITEM
                      and CQ7_CCUSTO  = @IN_CUSTO
                      and CQ7_CONTA   = @IN_CONTA
                      and CQ7_DATA    between @cDataI and @cDataF
                      and CQ7_MOEDA   = @IN_MOEDA
                      and CQ7_TPSALD  = @IN_TPSALDO
                      and CQ7_LP     in( 'N', ' ')
                      and D_E_L_E_T_  = ' '
                      and R_E_C_N_O_  between @iMin and @iMin + 5000
                   commit tran
                   select @iMin = @iMin + 5000
                End
            End
        End
        /*---------------------------------------------------------------
        Atualiza Saldos Totais por Entidades CQ8 - MES   (CTU)
        --------------------------------------------------------------- */
        If @IN_TABELA = 'CQ8' begin
            If @IN_IDENT = 'CTD' begin
                Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
                  From CQ8###
                 Where CQ8_FILIAL  = @IN_FILIALCOR
                   and CQ8_IDENT   = 'CTD'
                   and CQ8_CODIGO  = @IN_ITEM
                   and CQ8_DATA    between @cDataI and @cDataF
                   and CQ8_TPSALD  = @IN_TPSALDO
                   and CQ8_MOEDA   = @IN_MOEDA
                   and CQ8_LP      = 'N'
                   and D_E_L_E_T_  = ' '
      
                If @iMin > 0 begin
                    While ( @iMin <= @iMax ) begin
                        /*---------------------------------------------------------------
                            Atualiza flags de L/P
                            --------------------------------------------------------------- */         
                        begin tran
                        Update CQ8###
                            Set CQ8_LP ='S',  CQ8_DTLP = @IN_DATALP
                        Where CQ8_FILIAL  = @IN_FILIALCOR
                            and CQ8_IDENT   = 'CTD'
                            and CQ8_CODIGO  = @IN_ITEM
                            and CQ8_DATA    between @cDataI and @cDataF
                            and CQ8_MOEDA   = @IN_MOEDA
                            and CQ8_TPSALD  = @IN_TPSALDO
                            and CQ8_LP      = 'N'
                            and D_E_L_E_T_  = ' '
                            and R_E_C_N_O_  between @iMin and @iMin + 5000
                        commit tran
                        select @iMin = @iMin + 5000
                    End
                End
            End
      
            If @IN_IDENT = 'CTH' begin
                Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
                  From CQ8###
                 Where CQ8_FILIAL  = @IN_FILIALCOR
                   and CQ8_IDENT   = 'CTH'
                   and CQ8_CODIGO  = @IN_CLVL
                   and CQ8_DATA    between @cDataI and @cDataF
                   and CQ8_TPSALD  = @IN_TPSALDO
                   and CQ8_MOEDA   = @IN_MOEDA
                   and CQ8_LP      = 'N'
                   and D_E_L_E_T_  = ' '
      
                If @iMin > 0 begin
                    While ( @iMin <= @iMax ) begin
                        /*---------------------------------------------------------------
                            Atualiza flags de L/P
                            --------------------------------------------------------------- */         
                        begin tran
                        Update CQ8###
                            Set CQ8_LP ='S',  CQ8_DTLP = @IN_DATALP
                        Where CQ8_FILIAL  = @IN_FILIALCOR
                            and CQ8_IDENT   = 'CTH'
                            and CQ8_CODIGO  = @IN_CLVL
                            and CQ8_DATA    between @cDataI and @cDataF
                            and CQ8_MOEDA   = @IN_MOEDA
                            and CQ8_TPSALD  = @IN_TPSALDO
                            and CQ8_LP      = 'N'
                            and D_E_L_E_T_  = ' '
                            and R_E_C_N_O_  between @iMin and @iMin + 5000
                        commit tran
                        select @iMin = @iMin + 5000
                    End
                End
            End
      
            If @IN_IDENT = 'CTT' begin
                Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
                  From CQ8###
                 Where CQ8_FILIAL  = @IN_FILIALCOR
                   and CQ8_IDENT   = 'CTT'
                   and CQ8_CODIGO  = @IN_CUSTO
                   and CQ8_DATA    between @cDataI and @cDataF
                   and CQ8_TPSALD  = @IN_TPSALDO
                   and CQ8_MOEDA   = @IN_MOEDA
                   and CQ8_LP      = 'N'
                   and D_E_L_E_T_  = ' '
      
                If @iMin > 0 begin
                    While ( @iMin <= @iMax ) begin
                        /*---------------------------------------------------------------
                            Atualiza flags de L/P
                            --------------------------------------------------------------- */         
                        begin tran
                        Update CQ8###
                            Set CQ8_LP ='S',  CQ8_DTLP = @IN_DATALP
                        Where CQ8_FILIAL  = @IN_FILIALCOR
                            and CQ8_IDENT   = 'CTT'
                            and CQ8_CODIGO  = @IN_CUSTO
                            and CQ8_DATA    between @cDataI and @cDataF
                            and CQ8_MOEDA   = @IN_MOEDA
                            and CQ8_TPSALD  = @IN_TPSALDO
                            and CQ8_LP      = 'N'
                            and D_E_L_E_T_  = ' '
                            and R_E_C_N_O_  between @iMin and @iMin + 5000
                        commit tran
                        select @iMin = @iMin + 5000
                    End
                End
            End
        End
        /*---------------------------------------------------------------
        Atualiza Saldos Totais por Entidades CQ9 - DIA   (CTU)
        --------------------------------------------------------------- */
        If @IN_TABELA = 'CQ9' begin
            If @IN_IDENT = 'CTD' begin
                 Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
                   From CQ9###
                  Where CQ9_FILIAL  = @IN_FILIALCOR
                    and CQ9_IDENT   = 'CTD'
                    and CQ9_CODIGO  = @IN_ITEM
                    and CQ9_DATA    between @cDataI and @cDataF
                    and CQ9_TPSALD  = @IN_TPSALDO
                    and CQ9_MOEDA   = @IN_MOEDA
                    and CQ9_LP      = 'N'
                    and D_E_L_E_T_  = ' '
      
                 If @iMin > 0 begin
                    While ( @iMin <= @iMax ) begin
                       /*---------------------------------------------------------------
                         Atualiza flags de L/P
                         --------------------------------------------------------------- */         
                       begin tran
                       Update CQ9###
                          Set CQ9_LP ='S',  CQ9_DTLP = @IN_DATALP
                        Where CQ9_FILIAL  = @IN_FILIALCOR
                          and CQ9_IDENT   = 'CTD'
                          and CQ9_CODIGO  = @IN_ITEM
                          and CQ9_DATA    between @cDataI and @cDataF
                          and CQ9_MOEDA   = @IN_MOEDA
                          and CQ9_TPSALD  = @IN_TPSALDO
                          and CQ9_LP      = 'N'
                          and D_E_L_E_T_  = ' '
                          and R_E_C_N_O_  between @iMin and @iMin + 5000
                       commit tran
                       select @iMin = @iMin + 5000
                    End
                 End
            End
      
              If @IN_IDENT = 'CTH' begin
                 Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
                   From CQ9###
                  Where CQ9_FILIAL  = @IN_FILIALCOR
                    and CQ9_IDENT   = 'CTH'
                    and CQ9_CODIGO  = @IN_CLVL
                    and CQ9_DATA    between @cDataI and @cDataF
                    and CQ9_TPSALD  = @IN_TPSALDO
                    and CQ9_MOEDA   = @IN_MOEDA
                    and CQ9_LP      = 'N'
                    and D_E_L_E_T_  = ' '
      
                 If @iMin > 0 begin
                    While ( @iMin <= @iMax ) begin
                       /*---------------------------------------------------------------
                         Atualiza flags de L/P
                         --------------------------------------------------------------- */         
                       begin tran
                       Update CQ9###
                          Set CQ9_LP ='S',  CQ9_DTLP = @IN_DATALP
                        Where CQ9_FILIAL  = @IN_FILIALCOR
                          and CQ9_IDENT   = 'CTH'
                          and CQ9_CODIGO  = @IN_CLVL
                          and CQ9_DATA    between @cDataI and @cDataF
                          and CQ9_MOEDA   = @IN_MOEDA
                          and CQ9_TPSALD  = @IN_TPSALDO
                          and CQ9_LP      = 'N'
                          and D_E_L_E_T_  = ' '
                          and R_E_C_N_O_  between @iMin and @iMin + 5000
                       commit tran
                       select @iMin = @iMin + 5000
                    End
                 End
              End
      
              If @IN_IDENT = 'CTT' begin
                 Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
                   From CQ9###
                  Where CQ9_FILIAL  = @IN_FILIALCOR
                    and CQ9_IDENT   = 'CTT'
                    and CQ9_CODIGO  = @IN_CUSTO
                    and CQ9_DATA    between @cDataI and @cDataF
                    and CQ9_TPSALD  = @IN_TPSALDO
                    and CQ9_MOEDA   = @IN_MOEDA
                    and CQ9_LP      = 'N'
                    and D_E_L_E_T_  = ' '
      
                 If @iMin > 0 begin
                    While ( @iMin <= @iMax ) begin
                       /*---------------------------------------------------------------
                         Atualiza flags de L/P
                         --------------------------------------------------------------- */         
                       begin tran
                       Update CQ9###
                          Set CQ9_LP ='S',  CQ9_DTLP = @IN_DATALP
                        Where CQ9_FILIAL  = @IN_FILIALCOR
                          and CQ9_IDENT   = 'CTT'
                          and CQ9_CODIGO  = @IN_CUSTO
                          and CQ9_DATA    between @cDataI and @cDataF
                          and CQ9_MOEDA   = @IN_MOEDA
                          and CQ9_TPSALD  = @IN_TPSALDO
                          and CQ9_LP      = 'N'
                          and D_E_L_E_T_  = ' '
                          and R_E_C_N_O_  between @iMin and @iMin + 5000
                       commit tran
                       select @iMin = @iMin + 5000
                    End
                 End
              End
       End
    End
    /*---------------------------------------------------------------
    Se a execucao foi OK retorna '1'
    --------------------------------------------------------------- */
    select @OUT_RESULTADO = '1'
end
