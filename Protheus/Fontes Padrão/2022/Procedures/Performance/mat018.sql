Create procedure MAT018_##
( 
  @IN_CCOD       Char('B1_COD'),
  @IN_FILIALCOR  Char('B1_FILIAL'),
  @IN_NQTD1	     Float,
  @IN_NQTD2      Float,
  @IN_NUNID      Float,

  @OUT_RESULTADO Float OutPut
)

as

/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  ConvUM
    Descricao   -  <d> Converte a Unidade de Medida </d>
    Assinatura  -  <a> 001 </a>
    Entrada     -  <ri> @IN_CCOD         - Codigo do Produto
                   @IN_FILIALCOR    - Filial Corrente
                   @IN_NQTD1        - Quantidade da Primeira Unidade de Medida
                   @IN_NQTD2        - Quantidade da Segunda  Unidade de Medida
                   @IN_NUNID        - Unidade de Medida ( 1 | 2 ) </ri>

    Saida       -  <ro> @OUT_RESULTADO   - Retorna a Quantidade Convertida </ro>

    Responsavel :  <r> Emerson Tobar </r>
    Data        :  <dt> 06/11/00 </dt>
--------------------------------------------------------------------------------------------------------------------- */

declare @cFilialSB1  char('B1_FILIAL')
declare @vB1_Conv    float
declare @vB1_TipConv char(01)
declare @cAux        Varchar(3)

begin 
   select @OUT_RESULTADO = 0

   /* -----------------------------------------------------------------
     Recupera filial de acesso das tabelas SB1
   ----------------------------------------------------------------- */
   select @cAux = 'SB1'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFilialSB1 OutPut

   /* -------------------------------------------------------------------
     Recupera dados do produto a ser convertido
   ------------------------------------------------------------------- */
   select @vB1_Conv = B1_CONV, @vB1_TipConv = B1_TIPCONV
     from SB1###
    where B1_FILIAL   = @cFilialSB1
      and B1_COD      = @IN_CCOD
      and D_E_L_E_T_  = ' '             

   if @vB1_Conv <> 0 begin
     /* --------------------------------------------------------------------------------------
       Se o tipo de conversao for 'M' (multiplicar)
          se a Unidade de Medida for 1 - divide-se a segunda qtd pelo fator de conversao
          se a Unidade de Medida for 2 - multiplica-se a primeira qtd pelo fator de conversao
      
       Se o tipo de conversao for 'D' (dividir)
          se a Unidade de Medida for 1 - multiplica-se a segunda qtd pelo fator de conversao
          se a Unidade de Medida for 2 - divide-se a primeira Qtde pelo fator de conversao
     -------------------------------------------------------------------------------------- */ 
      if @vB1_TipConv = 'D' begin
         if @IN_NUNID = 1 select @OUT_RESULTADO = @IN_NQTD2 * @vB1_Conv
         else             select @OUT_RESULTADO = @IN_NQTD1 / @vB1_Conv
      end else begin
         if @IN_NUNID = 1 select @OUT_RESULTADO = @IN_NQTD2 / @vB1_Conv
         else             select @OUT_RESULTADO = @IN_NQTD1 * @vB1_Conv
      end
   End
   else
   Begin
		select @OUT_RESULTADO = @IN_NQTD2
   end
end
