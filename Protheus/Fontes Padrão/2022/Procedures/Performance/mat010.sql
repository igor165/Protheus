CREATE PROCEDURE MAT010_##
(
   @IN_FILIALCOR   Char('F2_FILIAL'),
   @IN_NUMERO      Char('F2_DOC'),
   @IN_SERIE       Char('F2_SERIE'),
   @IN_DINICIO     Char(08),
   @OUT_RESULTADO  Char(01) OutPut
)

as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus 12 </v>
    Programa    -  <s> A330ANT </s>
    Assinatura  -  <a> 001 </a>
    Descricao   -  <d> Verifica se a DEV. VENDA e do mes anterior </d>
    Entrada     -  <ri>
                   @IN_FILIALCOR    - Filial Corrente
                   @IN_NUMERO       - Numero da Nota no SF2
                   @IN_SERIE        - Serie da Nota do SF2
                   @IN_DINICIO      - Data Inicial para processamento
                   </ri>
    Responsavel :  <r> Marco Norbiato </r>
    Data        :  <dt> 27/03/2000 </dt>
<o> Uso         :  MATA330 </o>
--------------------------------------------------------------------------------------------------------------------- */
declare @cFil_SF2  char('F2_FILIAL')
declare @dEmissao  char(08)

begin
   select @OUT_RESULTADO = '0'

   /* -----------------------------------------------------------------------------------------------------------
      Recuperando data de emissao do remito de origem
   ----------------------------------------------------------------------------------------------------------- */
   select @dEmissao = ''
   select @dEmissao = F2_EMISSAO
     from SF2###
    where F2_FILIAL   = @cFil_SF2
      and F2_DOC      = @IN_NUMERO
      and F2_SERIE    = @IN_SERIE
      and D_E_L_E_T_  = ' '

   if @dEmissao < @IN_DINICIO select @OUT_RESULTADO = '1'
   else                       select @OUT_RESULTADO = '0'

end
