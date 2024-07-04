Create Procedure FIN001_##
 (
  @IN_PREFIXO     Char('E1_PREFIXO'),
  @IN_NUMERO      Char('E1_NUM'),
  @IN_PARCELA     Char('E1_PARCELA'),
  @IN_CCART       Char('E5_RECPAG'),
  @IN_MOEDA       Float,
  @IN_DDATA       Char(08),
  @IN_CFORNCLI    Char('E2_FORNECE'),
  @IN_LOJA        Char('E1_LOJA'),
  @IN_FILIALCOR   Char('E1_FILIAL'),
  @IN_DATABASE    Char(08),
  @IN_TIPO        Char('E1_TIPO'),
  @IN_BD          Char(01),
  @OUT_TOTABAT    Float Output
 )

as

/* ---------------------------------------------------------------------
    Procedure   -  <d> Recupera a somatoria dos abatimentos </d>
    Fonte Siga  -  <s> SumAbat </s>
    Assinatura  - <a>  011 </a>
    Entrada     -  <ri> 
                   @IN_PREFIXO     - Prefixo do titulo
                   @IN_NUMERO      - Numero 
                   @IN_PARCELA     - Parcela
                   @IN_CCART       - Carteira
                   @IN_MOEDA       - Moeda
                   @IN_DDATA       - Data
                   @IN_CFORNCLI    - Cliente ou Fornecedor
                   @IN_LOJA        - Loja
                   @IN_DATABASE    - Database
                   @IN_FILIALCOR   - Filial corrente
                   </ri>

    Saida       -  <ro> @OUT_TOTABAT    - Total de Abatimentos </ro>

    Autor       :  <r> Vicente Sementilli </r>
    Criacao     :  <dt> 11/08/1998 </dt>


   Estrutura de chamadas
   ========= == ========

    0.FIN001 - Recupera a somatoria dos abatimentos
      1.MAT021 - Converte valor da moeda origem para moeda destino com base na data
        2.MAT020 - Recupera taxa para moeda na data em questao

 ---------------------------------------------------------------------- */
/*
Checada compatibilidade de versão 609 e 710 em 06/03/03 Marco.
*/
declare @E1_FILIAL      Char('E1_FILIAL')
declare @E2_FILIAL      Char('E2_FILIAL')
declare @ValorAbat      Float
declare @MoedaAbat      Float
declare @cAux           Varchar(3)

begin

  /* -----------------------------------------------------------------
    Recupera filial para tabela SE1 e SE2
  ----------------------------------------------------------------- */
  select @cAux = 'SE1'
  exec XFILIAL_## @cAux, @IN_FILIALCOR, @E1_FILIAL Output
  select @cAux = 'SE2'
  exec XFILIAL_## @cAux, @IN_FILIALCOR, @E2_FILIAL Output

  select @OUT_TOTABAT = 0
  select @ValorAbat   = 0

  /* -----------------------------------------------------------------
    Montagem de cursor - Receber ou Pagar
  ----------------------------------------------------------------- */
  if @IN_CCART = 'R' begin

    if @IN_BD = '1' begin
      /* -----------------------------------
        Query para SQL Server
       ---------------------------------- */
      declare CUR_SUMABAT_A cursor for
      select E1_VALOR, E1_MOEDA
        from SE1###
        where E1_FILIAL    = @E1_FILIAL
          and E1_PREFIXO   = @IN_PREFIXO
          and E1_NUM       = @IN_NUMERO
          and E1_PARCELA   = @IN_PARCELA
          and E1_TIPO      LIKE '%-'
          and (E1_CLIENTE  = @IN_CFORNCLI or E1_CLIENTE  = 'UNIAO ')
          and (E1_LOJA     = @IN_LOJA     or E1_CLIENTE  = 'UNIAO ')
          and E1_EMISSAO  <= @IN_DATABASE
          and (E1_TITPAI	= @IN_PREFIXO+@IN_NUMERO+@IN_PARCELA+@IN_TIPO+@IN_CFORNCLI+@IN_LOJA)
          and D_E_L_E_T_  <> '*'
                
      for read only

      open  CUR_SUMABAT_A
      fetch CUR_SUMABAT_A into @ValorAbat, @MoedaAbat

      while (@@fetch_status = 0) begin
        /* -----------------------------------------------------------------
          Converte o saldo do movimento para a moeda do titulo 
        ----------------------------------------------------------------- */
        exec MAT021_## @ValorAbat, @IN_DDATA, @MoedaAbat, @IN_MOEDA, @ValorAbat Output

        select @OUT_TOTABAT =  @OUT_TOTABAT + @ValorAbat
        fetch CUR_SUMABAT_A into @ValorAbat, @MoedaAbat
      end

      close      CUR_SUMABAT_A
      deallocate CUR_SUMABAT_A
    
    end else begin
      /* -----------------------------------------------------------------
        Query para demais banco de dados 'ORACLE.POSTGRES.DB2.INFORMIX'
       ----------------------------------------------------------------- */
      declare CUR_SUMABAT_C cursor for
      select E1_VALOR, E1_MOEDA
        from SE1###
        where E1_FILIAL    = @E1_FILIAL
          and E1_PREFIXO   = @IN_PREFIXO
          and E1_NUM       = @IN_NUMERO
          and E1_PARCELA   = @IN_PARCELA
          and E1_TIPO      LIKE '%-'
          and (E1_CLIENTE  = @IN_CFORNCLI or E1_CLIENTE  = 'UNIAO ')
          and (E1_LOJA     = @IN_LOJA     or E1_CLIENTE  = 'UNIAO ')
          and E1_EMISSAO  <= @IN_DATABASE
          and (RTRIM(E1_TITPAI)	= RTRIM(@IN_PREFIXO||@IN_NUMERO||@IN_PARCELA||@IN_TIPO||@IN_CFORNCLI||@IN_LOJA))
          and D_E_L_E_T_  <> '*'
      for read only

      open  CUR_SUMABAT_C
      fetch CUR_SUMABAT_C into @ValorAbat, @MoedaAbat

      while (@@fetch_status = 0) begin
        /* -----------------------------------------------------------------
          Converte o saldo do movimento para a moeda do titulo
        ----------------------------------------------------------------- */
        exec MAT021_## @ValorAbat, @IN_DDATA, @MoedaAbat, @IN_MOEDA, @ValorAbat Output

        select @OUT_TOTABAT =  @OUT_TOTABAT + @ValorAbat
        fetch CUR_SUMABAT_C into @ValorAbat, @MoedaAbat
      end

      close      CUR_SUMABAT_C
      deallocate CUR_SUMABAT_C

    end
          
  end

  else begin
    declare CUR_SUMABAT_B cursor for
     select E2_VALOR, E2_MOEDA
       from SE2###
      where E2_FILIAL   = @E2_FILIAL
        and E2_PREFIXO  = @IN_PREFIXO  
        and E2_NUM      = @IN_NUMERO
        and E2_PARCELA  = @IN_PARCELA
        and E2_TIPO     LIKE '%-'
        and E2_FORNECE  = @IN_CFORNCLI
        and E2_LOJA     = @IN_LOJA
        and E2_EMISSAO <= @IN_DATABASE
        and D_E_L_E_T_ <> '*'
    for read only

    open  CUR_SUMABAT_B
    fetch CUR_SUMABAT_B into @ValorAbat, @MoedaAbat

    while (@@fetch_status = 0) begin
      /* -----------------------------------------------------------------
        Converte o saldo do movimento para a moeda do titulo
      ----------------------------------------------------------------- */
      exec MAT021_## @ValorAbat, @IN_DDATA, @MoedaAbat, @IN_MOEDA, @ValorAbat Output

      select @OUT_TOTABAT = @OUT_TOTABAT + @ValorAbat

      fetch CUR_SUMABAT_B into @ValorAbat, @MoedaAbat
    end

    close CUR_SUMABAT_B
    deallocate CUR_SUMABAT_B
  end

  if @OUT_TOTABAT is Null select @OUT_TOTABAT = 0

end
