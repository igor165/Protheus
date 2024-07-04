Create Procedure MAT021_##
(
 @IN_VALOR       Float,
 @IN_DATA        Char(08),
 @IN_MOEDAO      Float,
 @IN_MOEDAD      Float,
 @OUT_VALOR      Float  Output
)

as

/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus 12 </v>
    Procedure   -  <d> Converte valor da moeda origem para moeda destino com base na data </d>
    Assinatura  -  <a> 001 </a>
    Entrada     -  <ri>
                   @IN_VALOR     - Valor a ser convertido            
                   @IN_DATA      - Data da conversao                 
                   @IN_MOEDAO    - Moeda Origem
                   @IN_MOEDAD    - Moeda Destino
                   </ri>

    Saida       -  <ro> @OUT_VALOR    - Valor convertido </ro>

    Autor       :  <r> Marcos Patricio </r>
    Criacao     :  <dt> 28/07/1998 </dt>
<o>
    Alteracao   :  Conformidade com Informix
    Autor       :  Marcelo Rodrigues de Oliveira
    Data        :  29/05/2000

</o>

    Estrutura de chamadas
    ========= == ========

    0.MAT021 - Converte valor da moeda origem para moeda destino com base na data
      1.MAT020 - Recupera taxa para moeda na data em questao

---------------------------------------------------------------------- */

declare @nTaxa   Float
declare @nMoedaO Float

begin

  select @OUT_VALOR = 0
  select @nTaxa = 0

  if @IN_MOEDAO = @IN_MOEDAD select @OUT_VALOR = @IN_VALOR
  else begin
    select @nMoedaO = @IN_MOEDAO
    if (@nMoedaO is Null) or (@nMoedaO = 0) select @nMoedaO = 1

    /* ------------------------------------------------------------------------------
      Recupera a taxa para Data e Moeda em questao - Origem
    ------------------------------------------------------------------------------ */
    if @nMoedaO = 1 select @nTaxa = 1
    else exec MAT020_## @IN_DATA, @nMoedaO, @nTaxa OutPut

    select @OUT_VALOR = (@IN_VALOR * @nTaxa)
    select @nTaxa  = Null

    /* ------------------------------------------------------------------------------
      Recupera a taxa para Data e Moeda em questao - Destino
    ------------------------------------------------------------------------------ */
    if @IN_MOEDAD = 1 select @nTaxa = 1
    else exec MAT020_## @IN_DATA, @IN_MOEDAD, @nTaxa OutPut

    /* ------------------------------------------------------------------------------
      Se nao houver taxa para a data informada, retorna zero.
    ------------------------------------------------------------------------------ */
    if @nTaxa = 0 select @OUT_VALOR = 0
    else          select @OUT_VALOR = (@OUT_VALOR / @nTaxa)
  end
end
