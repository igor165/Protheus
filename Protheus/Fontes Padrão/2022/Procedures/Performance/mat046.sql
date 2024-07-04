Create procedure MAT046_##

(
  @IN_FILIAL_SDB  char('DB_FILIAL'),
  @IN_PROD        char('B1_COD'),
  @IN_LOCAL       char('B1_LOCPAD'),
  @IN_LOTE        char('BJ_LOTECTL'),
  @IN_LOCALIZA    char('BK_LOCALIZ'),
  @IN_NUMSER      char('BK_NUMSERI'),
  @IN_SUBLOTE     char('BK_NUMLOTE'),
  @IN_DATA        char(08),
  @IN_cDtSaldo    char(08),
  @IN_cRastroL    char(01),
  @IN_cRastroS    char(01),
  @IN_nSLD1SDB    float,
  @IN_nSLD7SDB    float,
  @IN_MV_WMSNEW   char(01),
  @IN_PRDORI      char('B1_COD'),
  @OUT_SALDO1     float output,
  @OUT_SALDO7     float output
)

as


/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> Virada de Saldo (MATA280.PRX) </s>
    Descricao   -  <d> Retorna o saldo da movimentacao do arquivo SDB </d>
    Assinatura  -  <a> 003 </a>
    Entrada     -  <ri> @IN_FILIAL_SDB - Filial corrente tabela SDB
                        @IN_PROD       - Codigo do Produto corrente
                        @IN_LOCAL      - Local ( almoxarifado )
                        @IN_LOTE       - Lote de controle
                        @IN_LOCALIZA   - Localizacao
                        @IN_NUMSER     - Numero de Serie
                        @IN_SUBLOTE    - SubLote
                        @IN_DATA       - Data Final para obter o saldo
                        @IN_cDtSaldo   - Data Inicial para obter o saldo
                        @IN_cRastroL   - Flag para rastro Lote
                        @IN_cRastroS   - Flag para rastro SubLote</ri>

    Saida       -  <ro> @OUT_SALDO1   - Saldos de saida valor 1
                        @OUT_SALDO7   - Saldos de saida valor 7</ro>

    Responsavel :  <r> Marcelo Pimentel </r>
    Data        :  <dt> 06.07.2004 </dt>
    Observacao  :  <o> Criada a procedure para compatibilizar com o banco DB2, para que que nao seja necessario
                       criado cursor dinamico devido a variavel cDtSaldo.
--------------------------------------------------------------------------------------------------------------------- */
Declare @nDB_QUANT     decimal( 'DB_QUANT' )
Declare @nDB_QTSEGUM   decimal( 'DB_QTSEGUM' )
Declare @cDB_TM        char('DB_TM')
Declare @cFilial       char('DB_FILIAL')
Declare @cProduto      char('DB_PRODUTO')
Declare @cLocal        char('DB_LOCAL')
Declare @cLocaliz      char('DB_LOCALIZ')
Declare @cNumSeri      char('DB_NUMSERI')
Declare @cLote         char('DB_LOTECTL')
Declare @cSubLote      char('DB_NUMLOTE')
Declare @cDataInicio   char(8)
Declare @cDataFim      char(8)

Begin

   /* -------------------------------------------------------------------------
    Evitando Parameter Sniffing
   ------------------------------------------------------------------------- */
   Select @cFilial     = @IN_FILIAL_SDB
   Select @cProduto    = @IN_PROD
   Select @cLocal      = @IN_LOCAL
   Select @cLocaliz    = @IN_LOCALIZA
   Select @cNumSeri    = @IN_NUMSER
   Select @cLote       = @IN_LOTE
   Select @cSubLote    = @IN_SUBLOTE
   Select @cDataInicio = @IN_cDtSaldo
   Select @cDataFim    = @IN_DATA

   select @OUT_SALDO1 = @IN_nSLD1SDB
   select @OUT_SALDO7 = @IN_nSLD7SDB

   /* -------------------------------------------------------------------------------------------------
      Verifica se existe rastro e aplica filtros por lote e sub-lote
   ------------------------------------------------------------------------------------------------- */
  if @IN_cRastroL = '1' begin

    if @IN_cRastroS = '1' and @IN_SUBLOTE <> ' ' begin

      declare CUR_MAT029_D1 insensitive cursor for
        select DB_TM ,SUM(DB_QUANT) DB_QUANT ,SUM(DB_QTSEGUM) DB_QTSEGUM
          from SDB### (nolock)
          where DB_FILIAL   = @cFilial
            and DB_PRODUTO  = @cProduto
            and DB_LOCAL    = @cLocal
            and DB_LOCALIZ  = @cLocaliz
            and DB_NUMSERI  = @cNumSeri
            and DB_LOTECTL  = @cLote
            and DB_NUMLOTE  = @cSubLote
            and DB_ESTORNO  = ' '
            and DB_DATA     > @cDataInicio
            and DB_DATA     < @cDataFim
            and DB_ATUEST  <> 'N'
            and ( DB_TM <= '500' or substring( DB_TM, 1, 2 ) in ( 'DE', 'PR') or DB_TM = 'MAN')
            and D_E_L_E_T_  = ' '
          group by DB_TM
        union
        select DB_TM ,SUM(DB_QUANT)*-1 DB_QUANT ,SUM(DB_QTSEGUM)*-1 DB_QTSEGUM
          from SDB### (nolock)
          where DB_FILIAL   = @cFilial
            and DB_PRODUTO  = @cProduto
            and DB_LOCAL    = @cLocal
            and DB_LOCALIZ  = @cLocaliz
            and DB_NUMSERI  = @cNumSeri
            and DB_LOTECTL  = @cLote
            and DB_NUMLOTE  = @cSubLote
            and DB_ESTORNO  = ' '
            and DB_DATA     > @cDataInicio
            and DB_DATA     < @cDataFim
            and DB_ATUEST  <> 'N'
            and ( DB_TM > '500' and substring( DB_TM, 1, 2 ) not in ( 'DE', 'PR') and DB_TM <> 'MAN')
            and D_E_L_E_T_  = ' '
          group by DB_TM
      for read only

      open CUR_MAT029_D1

      fetch CUR_MAT029_D1 into @cDB_TM, @nDB_QUANT, @nDB_QTSEGUM

      while (@@Fetch_Status = 0 ) begin
          select @OUT_SALDO1 = @OUT_SALDO1 + @nDB_QUANT
          select @OUT_SALDO7 = @OUT_SALDO7 + @nDB_QTSEGUM

          fetch CUR_MAT029_D1 into @cDB_TM, @nDB_QUANT, @nDB_QTSEGUM
      end
      close CUR_MAT029_D1
      deallocate CUR_MAT029_D1

    end else begin

      declare CUR_MAT029_D2 insensitive cursor for
        select DB_TM ,SUM(DB_QUANT) DB_QUANT ,SUM(DB_QTSEGUM) DB_QTSEGUM
        from SDB### (nolock)
        where DB_FILIAL   = @cFilial
          and DB_PRODUTO  = @cProduto
          and DB_LOCAL    = @cLocal
          and DB_LOCALIZ  = @cLocaliz
          and DB_NUMSERI  = @cNumSeri
          and DB_LOTECTL  = @cLote
          and DB_ESTORNO  = ' '
          and DB_DATA     > @cDataInicio
          and DB_DATA     < @cDataFim
          and DB_ATUEST  <> 'N'
          and D_E_L_E_T_  = ' '
          and ( DB_TM <= '500' or substring( DB_TM, 1, 2 ) in ( 'DE', 'PR') or DB_TM = 'MAN')
        group by DB_TM
        union
        select DB_TM ,SUM(DB_QUANT)*-1 DB_QUANT ,SUM(DB_QTSEGUM)*-1 DB_QTSEGUM
        from SDB### (nolock)
        where DB_FILIAL   = @cFilial
          and DB_PRODUTO  = @cProduto
          and DB_LOCAL    = @cLocal
          and DB_LOCALIZ  = @cLocaliz
          and DB_NUMSERI  = @cNumSeri
          and DB_LOTECTL  = @cLote
          and DB_ESTORNO  = ' '
          and DB_DATA     > @cDataInicio
          and DB_DATA     < @cDataFim
          and DB_ATUEST  <> 'N'
          and D_E_L_E_T_  = ' '
          and ( DB_TM > '500' and substring( DB_TM, 1, 2 ) not in ( 'DE', 'PR') and DB_TM <> 'MAN')
        group by DB_TM
      for read only

      open CUR_MAT029_D2

      fetch CUR_MAT029_D2 into @cDB_TM, @nDB_QUANT, @nDB_QTSEGUM

      while (@@Fetch_Status = 0 ) begin
        select @OUT_SALDO1 = @OUT_SALDO1 + @nDB_QUANT
        select @OUT_SALDO7 = @OUT_SALDO7 + @nDB_QTSEGUM
        fetch CUR_MAT029_D2 into @cDB_TM, @nDB_QUANT, @nDB_QTSEGUM
      end
      close CUR_MAT029_D2
      deallocate CUR_MAT029_D2
    end

  /* -------------------------------------------------------------------------------------------------
    Filtro por Endereco
  ------------------------------------------------------------------------------------------------- */
  end else begin

    declare CUR_MAT029_D3 insensitive cursor for
      select DB_TM ,SUM(DB_QUANT) DB_QUANT ,SUM(DB_QTSEGUM) DB_QTSEGUM
      from SDB### (nolock)
        where DB_FILIAL   = @cFilial
          and DB_PRODUTO  = @cProduto
          and DB_LOCAL    = @cLocal
          and DB_LOCALIZ  = @cLocaliz
          and DB_NUMSERI  = @cNumSeri
          and DB_ESTORNO  = ' '
          and DB_DATA     > @cDataInicio
          and DB_DATA     < @cDataFim
          and DB_ATUEST  <> 'N'
          and ( DB_TM <= '500' or substring( DB_TM, 1, 2 ) in ( 'DE', 'PR') or DB_TM = 'MAN')
          and D_E_L_E_T_  = ' '
      group by DB_TM
      union
      select DB_TM ,SUM(DB_QUANT)*-1 DB_QUANT ,SUM(DB_QTSEGUM)*-1 DB_QTSEGUM
      from SDB### (nolock)
        where DB_FILIAL   = @cFilial
          and DB_PRODUTO  = @cProduto
          and DB_LOCAL    = @cLocal
          and DB_LOCALIZ  = @cLocaliz
          and DB_NUMSERI  = @cNumSeri
          and DB_ESTORNO  = ' '
          and DB_DATA     > @cDataInicio
          and DB_DATA     < @cDataFim
          and DB_ATUEST  <> 'N'
          and ( DB_TM > '500' and substring( DB_TM, 1, 2 ) not in ( 'DE', 'PR') and DB_TM <> 'MAN')
          and D_E_L_E_T_  = ' '
      group by DB_TM
    for read only

    open CUR_MAT029_D3

    fetch CUR_MAT029_D3 into @cDB_TM, @nDB_QUANT, @nDB_QTSEGUM

    while (@@Fetch_Status = 0 ) begin
      select @OUT_SALDO1 = @OUT_SALDO1 + @nDB_QUANT
      select @OUT_SALDO7 = @OUT_SALDO7 + @nDB_QTSEGUM
      fetch CUR_MAT029_D3 into @cDB_TM, @nDB_QUANT,  @nDB_QTSEGUM
    end
    close CUR_MAT029_D3
    deallocate CUR_MAT029_D3
  end

End