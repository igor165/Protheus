Create Procedure ATF014_## (
   @IN_N3TIPO    Char( 'N3_TIPO' ),
   @IN_TPDEPR    Char( 'N3_TPDEPR' ),
   @IN_DATADEP   Char( 08 ),
   @IN_DINDEPR   Char( 08 ),
   @IN_CALCDEP   Char( 01 ),
   @IN_PERDEPR   Integer,
   @IN_RECNOSN3  Integer,
   @IN_RECNOTP07 Integer,
   @IN_CASAS1    Integer,
   @IN_CASASATF  Integer,
   @IN_VORIG1    float,
   @IN_VRCACM1   float,
   @IN_AMPLIA1   float,
   @IN_VRDACM1   float,
   @IN_VRCDA1    float,
   @IN_VALORORIG float,
   @IN_VALORACUM float,
   @IN_VALOR1    float,
   @IN_VALORX    float,
   @IN_VLSALV1   float,
   @IN_VMXDEP    float
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus 9.12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ATFA050.PRW </s>
    Descricao       - <d>  Grava data de fim de depreciação - N3_FIMDEPR </d>
    Funcao do Siga  -      
    Entrada         - <ri> @IN_N3TIPO    - Pode ser '01' ou '07'
                           @IN_TPDEPR    - Tipo de depreciação
                           @IN_DATADEP   - Data de cálculo de deprecição
                           @IN_DINDEPR   - Data Inicio de depreciacao 
                           @IN_CALCDEP   - '0' se mensal , '1' se anual
                           @IN_PERDEPR   - nro de periodos a depreciar
                           @IN_RECNOSN3  - Recno do SN3
                           @IN_CASAS1    - Nro de casas decimais na moeda 1
                           @IN_CASASATF  - Nro de casas decimais na moeda atf
                           @IN_RECNOTP07 - Recno no SN3 do N3_TIPO = '03'
                           @IN_VORIG1    - vlr original na moeda 1
                           @IN_VRCACM1   - vlr da depreciação acumulada na moeda 1
                           @IN_AMPLIA1   - ampliacao na moeda 1
                           @IN_VRDACM1   - vlr da correcao acumulada na moeda 1
                           @IN_VRCDA1    - vlr da correcao da dep acumulada na moeda 1
                           @IN_VALORORIG - vlr original na moeda do ativo
                           @IN_VALORACUM - vlr da depreciacao na moeda referencia
                           @IN_VALORX    - valor relativa ao tipo '07' e '01'
                           @IN_VALOR     - valor relativa ao tipo '07' e '01'
                           @IN_VLSALV1   - Valor de salvamento
                           @IN_VMXDEP    - Valor max de depreciacao </ri>
    Saida           - <o>  @OUT_RESULTADO - 1 - ok </ro>
    Data        :     04/05/11
   --------------------------------------------------------------------------------------- */
Declare @lAtualiza char( 01 )
Declare @iPc1      float
Declare @iPc2      float
Declare @iPC       float

begin
   select @lAtualiza = '0'
   select @iPc1      = 0
   select @iPc2      = 0
   select @iPC       = 0
   /* --------------------------------------------------------------------------
      Redução de Saldos - (Vlr deprec acum + Vlr de salv = Vlr orig ) ou
      -------------------------------------------------------------------------- */
   If @IN_TPDEPR = '2' begin
      If Round(Abs(@IN_VRDACM1 + @IN_VRCDA1 + @IN_VLSALV1 ), @IN_CASAS1) >= Round(Abs(@IN_VORIG1 + @IN_VRCACM1 + @IN_AMPLIA1), @IN_CASAS1) begin
         select @lAtualiza = '1'
      End      
   end
   /* --------------------------------------------------------------------------
      Valor maximo de depreciação - Vlr de deprec acum = Vlr max deprec
      -------------------------------------------------------------------------- */
   If @IN_TPDEPR = '6' begin
      /* ------------------------------------------------------------------------------------------------------------------------------
         SOMA DOS DIGITOS
         ----------------
         MV_CALCDEP = '0'-> Mensal (DEFAULT), MV_CALCDEP = '1' -> /ANUAL
         TAXA DE DEPRECIACAO = ( n - pc + 1 ) / SD
                  n  -> nro total de periodos
                  pc -> periodo de cálculo ( 1 para primeira depreciacao, 2 para segunda depreciacao,.., n para a enésima depreciação )
                              pc -> (Ano de calc *12 + mes de calc) - (Ano de inic depr *12 + mes inic depr)
                  SD -> Soma dos digitos = ( a1 + an ) * n / 2         
         ------------------------------------------------------------------------------------------------------------------------------ */
      If @IN_PERDEPR > 0 begin
         If @IN_CALCDEP = '0' begin
            Select @iPc1 = Convert( integer , Substring(@IN_DATADEP, 1, 4))*12 + Convert( integer, Substring(@IN_DATADEP, 5, 2 ))
            Select @iPc2 = Convert( integer , Substring(@IN_DINDEPR, 1, 4))*12 + Convert( integer, Substring(@IN_DINDEPR, 5, 2 ))
         end else begin
            Select @iPc1 = Convert( integer , Substring(@IN_DATADEP, 1, 4)) + Convert( integer, Substring(@IN_DATADEP, 5, 2 ))
            Select @iPc2 = Convert( integer , Substring(@IN_DINDEPR, 1, 4)) + Convert( integer, Substring(@IN_DINDEPR, 5, 2 ))
         End
         Select @iPC  = @IN_PERDEPR - ( @iPc1 - @iPc2 )  -- periodo de calculo se 1 é o ultimo
         If @iPC = 1 select @lAtualiza = '1'
      
      End
   end
   /* --------------------------------------------------------------------------
      Valor maximo de depreciação - Vlr de deprec acum = Vlr max deprec
      -------------------------------------------------------------------------- */
   If @IN_TPDEPR = '7' begin
      If Round( Abs( @IN_VRDACM1 + @IN_VRCDA1 ), @IN_CASASATF) >= Round( Abs( @IN_VMXDEP), @IN_CASASATF) begin
         select @lAtualiza = '1'
      End
   end
   /* --------------------------------------------------------------------------
      Demais tipos de depreciacao
      -------------------------------------------------------------------------- */
   If @IN_TPDEPR != '7' and @IN_TPDEPR != '2' begin
      If Round( Abs(@IN_VRDACM1 + @IN_VRCDA1 + @IN_VALOR1 ), @IN_CASAS1) >= Round( Abs( @IN_VORIG1 + @IN_VRCACM1 + @IN_AMPLIA1), @IN_CASAS1) and
         Round( Abs(@IN_VALORACUM + @IN_VALORX), @IN_CASASATF)           >= Round( Abs( @IN_VALORORIG), @IN_CASASATF) begin
         select @lAtualiza = '1'
      End
   End
   
   If @lAtualiza ='1' begin
      begin tran
      Update SN3###
         Set N3_FIMDEPR = @IN_DATADEP
       Where R_E_C_N_O_ = @IN_RECNOSN3
      commit tran
      If ( @IN_N3TIPO in ('01','07') and ( @IN_RECNOTP07 > 0) ) begin
         begin tran
         Update SN3###
            Set N3_FIMDEPR = @IN_DATADEP
          Where R_E_C_N_O_ = @IN_RECNOTP07
         commit tran                           
      End
   End
End
