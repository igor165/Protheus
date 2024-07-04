/* -----------------------------------------------------------------------------------
   CTB025a - Ct190SlBse - Atualizar Saldos base - CQ0/CQ1 - CQ2/CQ3 - CQ4/CQ5 - CQ6/CQ7
   ---------------------------------------------------------------------------------- */
##IF_001({|| cPaisLoc $ 'COL|PER' .And. CtbMovSaldo('CT0',,'05') })
##FIELDP01( 'QL6.QL6_FILIAL' )

Create procedure CTB025A_##
(
   @IN_FILIALCOR    Char('CQ0_FILIAL'),
   @IN_TABELA       Char(03),
   @IN_IDENT        Char(03),
   @IN_CONTA        Char('CQ0_CONTA'),
   @IN_CUSTO        Char('CQ2_CCUSTO'),
   @IN_ITEM         Char('CQ4_ITEM'),
   @IN_CLVL         Char('CQ6_CLVL'),
   @IN_ENT05        Char('QL6_ENT05'),
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
                           @IN_ENT05        - Entidad 05
                           @IN_DATALP       - Data Ap L/P
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_EMPANT       - Empresa
                           @IN_FILANT       - Sucursal
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alberto Rodriguez	</r>
    Data        :     22/09/2021
-------------------------------------------------------------------------------------- */
Declare @iMin            Integer
Declare @iMax            Integer
Declare @cDataF          Char(08)
Declare @cDataI          Char(08)
Declare @cApuracao       Char( 'CW0_DESC01' )
Declare @cApuracaoAnt    Char( 'CW0_DESC01' )
Declare @cAux            Char(03)
Declare @cFilial_CW0     Char( 'CT2_FILIAL' )
Declare @cCW0_DESC01Aux1 Char( 'CW0_DESC01' )
Declare @cDataLpAnt      Char(08)
Declare @cCodigo         Char('CQ8_CODIGO')
##IF_001({|| cPaisLoc $ 'COL|PER' .And. CtbMovSaldo("CT0",,"05") })
      Declare @cENT05 Char('QL6_ENT05')
##ELSE_001
      Declare @cENT05 Char('CT2_EC05DB')
##ENDIF_001

begin

   select @OUT_RESULTADO = '0'
   Exec LASTDAY_## @IN_DATALP, @cDataF OutPut
   select @cDataI = Substring(@IN_DATALP, 1, 6)||'01'

   select @cAux = 'CW0'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CW0 OutPut

   Select @cApuracao = ' '
   Select @cApuracaoAnt  = ' '
   select @cCW0_DESC01Aux1 = ' '
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
   WHERE CW0_FILIAL  = @cFilial_CW0
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
      WHERE CW0_FILIAL   = @cFilial_CW0
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
      Atualiza Saldos Totais por Entidades CQ8 - MES   (CTU)
      --------------------------------------------------------------- */
      If @IN_TABELA = 'CQ8' begin
         /*---------------------------------------------------------------
            Atualiza entidad 05, el código viene en la variable IN_ENT05
            --------------------------------------------------------------- */
         If @IN_IDENT = 'CV0' begin
            select @cCodigo = @IN_ENT05
            Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
            From CQ8###
            Where CQ8_FILIAL   = @IN_FILIALCOR
               and CQ8_IDENT   = 'CV0'
               and CQ8_CODIGO  = @cCodigo
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
                  Where CQ8_FILIAL   = @IN_FILIALCOR
                     and CQ8_IDENT   = 'CV0'
                     and CQ8_CODIGO  = @cCodigo
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
         /*---------------------------------------------------------------
            Atualiza entidad 05, el código viene en la variable IN_ENT05
            --------------------------------------------------------------- */
         If @IN_IDENT = 'CV0' begin
            select @cCodigo = @IN_ENT05
            Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
            From CQ9###
            Where CQ9_FILIAL   = @IN_FILIALCOR
               and CQ9_IDENT   = 'CV0'
               and CQ9_CODIGO  = @cCodigo
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
                  Where CQ9_FILIAL   = @IN_FILIALCOR
                     and CQ9_IDENT   = 'CV0'
                     and CQ9_CODIGO  = @cCodigo
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

      /*  ---------------------------------------------------------------
         Atualiza QL6 - Saldos MES de entidad 05, código en variable IN_ENT05
         --------------------------------------------------------------- */
      If @IN_TABELA = 'QL6' begin
         select @cENT05 = @IN_ENT05
         Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
         From QL6###
         Where QL6_FILIAL   = @IN_FILIALCOR
            and QL6_ENT05   = @cENT05
            and QL6_CLVL    = @IN_CLVL
            and QL6_ITEM    = @IN_ITEM
            and QL6_CCUSTO  = @IN_CUSTO
            and QL6_CONTA   = @IN_CONTA
            and QL6_DATA    between @cDataI and @cDataF
            and QL6_TPSALD  = @IN_TPSALDO
            and QL6_MOEDA   = @IN_MOEDA
            and QL6_LP      in ('N', ' ')
            and D_E_L_E_T_  = ' '

         If @iMin > 0 begin
            While ( @iMin <= @iMax ) begin
               /*---------------------------------------------------------------
               Atualiza flags de L/P
               --------------------------------------------------------------- */
               begin tran
               Update QL6###
                  Set QL6_LP ='S',  QL6_DTLP = @IN_DATALP
               Where QL6_FILIAL   = @IN_FILIALCOR
                  and QL6_ENT05   = @cENT05
                  and QL6_CLVL    = @IN_CLVL
                  and QL6_ITEM    = @IN_ITEM
                  and QL6_CCUSTO  = @IN_CUSTO
                  and QL6_CONTA   = @IN_CONTA
                  and QL6_DATA    between @cDataI and @cDataF
                  and QL6_MOEDA   = @IN_MOEDA
                  and QL6_TPSALD  = @IN_TPSALDO
                  and QL6_LP      in ('N', ' ')
                  and D_E_L_E_T_  = ' '
                  and R_E_C_N_O_  between @iMin and @iMin + 5000
               commit tran
               select @iMin = @iMin + 5000
            End
         End
      End

      /*  ---------------------------------------------------------------
         Atualiza QL7 - Saldos DIA de entidad 05, código en variable IN_ENT05
         --------------------------------------------------------------- */
      If @IN_TABELA = 'QL7' begin
         select @cENT05 = @IN_ENT05
         Select @iMin = Isnull(Min(R_E_C_N_O_),0),  @iMax = Isnull(Max(R_E_C_N_O_),0)
         From QL7###
         Where QL7_FILIAL   = @IN_FILIALCOR
            and QL7_ENT05   = @cENT05
            and QL7_CLVL    = @IN_CLVL
            and QL7_ITEM    = @IN_ITEM
            and QL7_CCUSTO  = @IN_CUSTO
            and QL7_CONTA   = @IN_CONTA
            and QL7_DATA    between @cDataI and @cDataF
            and QL7_TPSALD  = @IN_TPSALDO
            and QL7_MOEDA   = @IN_MOEDA
            and QL7_LP      in ('N', ' ')
            and D_E_L_E_T_  = ' '

         If @iMin > 0 begin
            While ( @iMin <= @iMax ) begin
               /*---------------------------------------------------------------
               Atualiza flags de L/P
               --------------------------------------------------------------- */
               begin tran
               Update QL7###
                  Set QL7_LP ='S',  QL7_DTLP = @IN_DATALP
               Where QL7_FILIAL   = @IN_FILIALCOR
                  and QL7_ENT05   = @cENT05
                  and QL7_CLVL    = @IN_CLVL
                  and QL7_ITEM    = @IN_ITEM
                  and QL7_CCUSTO  = @IN_CUSTO
                  and QL7_CONTA   = @IN_CONTA
                  and QL7_DATA    between @cDataI and @cDataF
                  and QL7_MOEDA   = @IN_MOEDA
                  and QL7_TPSALD  = @IN_TPSALDO
                  and QL7_LP      in ('N', ' ')
                  and D_E_L_E_T_  = ' '
                  and R_E_C_N_O_  between @iMin and @iMin + 5000
               commit tran
               select @iMin = @iMin + 5000
            End
         End
      End
   End

   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
   --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end
##ENDFIELDP01
##ENDIF_001
