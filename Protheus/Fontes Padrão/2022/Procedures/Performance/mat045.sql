Create procedure MAT045_##
(
  @IN_FILIAL_SD5  char('D5_FILIAL'),
  @IN_PROD        char('B1_COD'),
  @IN_LOCAL       char('B1_LOCPAD'),
  @IN_LOTE        char('BJ_LOTECTL'),
  @IN_DATA        char(08),
  @IN_SUBLOTE     char('BK_NUMLOTE'),
  @IN_cDtSaldo    char(08),
  @IN_cRastroS    char(01),
  @IN_nSLD1SD5    float,
  @IN_nSLD7SD5    float,
  @OUT_SALDO1     float output,
  @OUT_SALDO7     float output
)

as

/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> Virada de Saldo (MATA280.PRX)</s>
    Descricao   -  <d> Retorna o saldo da movimentacao do arquivo SD5 </d>
    Assinatura  -  <a> 003 </a>
    Entrada     -  <ri> @IN_FILIAL_SD5 - Filial corrente tabela SD5
                        @IN_PROD       - Codigo do Produto corrente
                        @IN_LOCAL      - Local ( almoxarifado )
                        @IN_LOTE       - Lote de controle
                        @IN_DATA       - Data Final para obter o saldo
                        @IN_SUBLOTE    - SubLote
                        @IN_cDtSaldo   - Data Inicial para obter o saldo
                        @IN_cRastroS   - Flag para rastro SubLote.</ri>

    Saida       -  <ro> @OUT_SALDO1   - Saldos de saida valor 1
                        @OUT_SALDO7   - Saldos de saida valor 7</ro>

    Responsavel :  <r> Marcelo Pimentel </r>
    Data        :  <dt> 06.07.2004 </dt>
    Observacao  :  <o> Criada a procedure para compatibilizar com o banco DB2, para que que nao seja necessario
                       criado cursor dinamico devido a variavel cDtSaldo.
--------------------------------------------------------------------------------------------------------------------- */
Declare @lAvalia       char(01)
Declare @cD5_NUMLOTE   char('D5_NUMLOTE')
Declare @nD5_QUANT     decimal( 'D5_QUANT' )
Declare @nD5_QTSEGUM   decimal( 'D5_QTSEGUM' )
Declare @cD5_ORIGLAN   char('D5_ORIGLAN')

Declare @cFilial     char( 'D5_FILIAL' )
Declare @cProduto    char( 'D5_PRODUTO' )
Declare @cLocal      char( 'D5_LOCAL' )
Declare @cLote       char( 'D5_LOTECTL' )
Declare @cDataInicio char(8)
Declare @cDataFim    char(8)

Begin

   /* -------------------------------------------------------------------------
    Evitando Parameter Sniffing
   ------------------------------------------------------------------------- */
   Select @cFilial     = @IN_FILIAL_SD5
   Select @cProduto    = @IN_PROD
   Select @cLocal      = @IN_LOCAL
   Select @cLote       = @IN_LOTE
   Select @cDataInicio = @IN_cDtSaldo
   Select @cDataFim    = @IN_DATA

   /* -------------------------------------------------------------------------------------------------------------------
      Zerando variaveis de saida
   ------------------------------------------------------------------------------------------------------------------- */
   select @OUT_SALDO1 = @IN_nSLD1SD5
   select @OUT_SALDO7 = @IN_nSLD7SD5


   declare CUR_MAT029_B insensitive cursor for
      select D5_NUMLOTE, SUM(D5_QUANT) D5_QUANT, SUM(D5_QTSEGUM) D5_QTSEGUM
         ,D5_ORIGLAN
      from SD5### (nolock)
      where D5_FILIAL    = @cFilial
         and D5_PRODUTO  = @cProduto
         and D5_LOCAL    = @cLocal
         and D5_LOTECTL  = @cLote
         and D5_ESTORNO <> 'S'
         and D5_DATA     > @cDataInicio
         and D5_DATA     < @cDataFim
         and ((D5_ORIGLAN <= '500') or (substring( D5_ORIGLAN, 1, 2 ) in ( 'DE', 'PR')) or (D5_ORIGLAN = 'MAN'))
         and D_E_L_E_T_  = ' '
   	group by D5_NUMLOTE,D5_ORIGLAN
      union all
      select D5_NUMLOTE, SUM(D5_QUANT)*-1 D5_QUANT, SUM(D5_QTSEGUM)*-1 D5_QTSEGUM
         ,D5_ORIGLAN
      from SD5### (nolock)
      where D5_FILIAL    = @cFilial
         and D5_PRODUTO  = @cProduto
         and D5_LOCAL    = @cLocal
         and D5_LOTECTL  = @cLote
         and D5_ESTORNO <> 'S'
         and D5_DATA     > @cDataInicio
         and D5_DATA     < @cDataFim
         and (D5_ORIGLAN > '500' and substring( D5_ORIGLAN, 1, 2 ) not in ( 'DE','RE') and (D5_ORIGLAN <> 'MAN'))
         and D_E_L_E_T_  = ' '
   	group by D5_NUMLOTE,D5_ORIGLAN
   for read only

   open CUR_MAT029_B
   fetch CUR_MAT029_B into @cD5_NUMLOTE, @nD5_QUANT, @nD5_QTSEGUM, @cD5_ORIGLAN

   while (@@Fetch_Status = 0 ) begin
      select @lAvalia = '1'

      /* ---------------------------------------------------------------------------------
         Filtro por sub-lote
      --------------------------------------------------------------------------------- */
      if (@IN_SUBLOTE <> ' ') and (@IN_cRastroS = '1') and (@cD5_NUMLOTE <> @IN_SUBLOTE )
         select @lAvalia = '0'

      if @lAvalia = '1' begin
         select @OUT_SALDO1 = @OUT_SALDO1 + @nD5_QUANT
         select @OUT_SALDO7 = @OUT_SALDO7 + @nD5_QTSEGUM
      end

      fetch CUR_MAT029_B into @cD5_NUMLOTE, @nD5_QUANT, @nD5_QTSEGUM, @cD5_ORIGLAN

   end
   close CUR_MAT029_B
   deallocate CUR_MAT029_B
End
