Create Procedure FIN002_##
 (
   @IN_PREFIXO    Char('E5_PREFIXO'),
   @IN_NUMERO     Char('E5_NUMERO'),
   @IN_PARCELA    Char('E5_PARCELA'),
   @IN_TIPO       Char('E5_TIPO'),
   @IN_CLIFOR     Char('E5_CLIFOR'),
   @IN_CONVERSAO  Char(08),
   @IN_BAIXA      Char(08),
   @IN_LOJA       Char('E5_LOJA'),
   @IN_DATABASE   Char(08),
   @IN_FILIALCOR  Char('E5_FILIAL'),
   @IN_VALORTIT   Float,
   @IN_MOEDATIT   Float,
   @IN_CPAISLOC   Char(03),
   @IN_DISPONI    Char(01),
   @IN_PCCBAIXA   Char(01),
   @IN_CART       Char(01),
   @IN_ADIANT     Char( 01 ),
   @IN_IRFBAIXA   Char(01),
   @IN_TXTIT      Float ,   
   @IN_ISSBAIXA   Char(01),
   @IN_FILIALORI  Char('E5_FILORIG'),  
   @OUT_SALDO     Float   Output
 )

as

/* ---------------------------------------------------------------------
      Procedure    -  <d> Recupera o saldo do titulo na determinada data </d>
      Versão       -  <v> Protheus P12 </v>
      Assinatura   -  <a> 015 </a>
      Fonte Siga   -  <s> SaldoTit </s>
      Entrada      -  <ri> @IN_PREFIXO     - Prefixo do titulo
                           @IN_NUMERO      - Numero 
                           @IN_PARCELA     - Parcela
                           @IN_TIPO        - Tipo 
                           @IN_CLIFOR      - Cliente ou Fornecedor
                           @IN_CONVERSAO   - Data de conversao
                           @IN_BAIXA       - Data da baixa
                           @IN_LOJA        - Loja
                           @IN_DATABASE    - Database
                           @IN_FILIALCOR   - Filial corrente
                           @IN_VALORTIT    - Valor do Titulo
                           @IN_MOEDATIT    - Moeda do Titulo
                           @IN_CPAISLOC    - País de referente
                           @IN_DISPONI     - Se 1, considero E1_DTDISPO, senão E5_DATA
                           @IN_PCCBAIXA    - 
                           @IN_CART        - Caretira, R - Receber, P- Pagar
                           @IN_ADIANT      - Se '1' Adiantamento, senão '0' 
						   @IN_FILIALORI   - Filial do Titulo de origem </ri>
      Saida        -  <ro> @OUT_SALDO       - Saldo do titulo </ro>
      Autor      :  <r> Vicente Sementilli </r>
      Criacao    :  <dt> 28/07/1998 </dt>
      Alterações : Retirado o filtro da coluna E5_NATUREZ porque existe 
            movimento com natureza diferente do Tit.Principal

   Estrutura de chamadas
   ========= == ========

   0.FIN002 - Recupera o saldo do titulo na determinada data
     1.FIN004 - Recupera o saldo do titulo na determinada data para BRASIL
     1.FIN005 - Recupera o saldo do titulo na determinada data e cPaisLoc diferente de BRASIL

 ---------------------------------------------------------------------- */

declare @OUT_VALOR   Float
declare @cE5_FILIAL  Char('E5_FILIAL')
declare @cAux        Varchar(3)

begin
   select @OUT_VALOR = 0
   select @OUT_SALDO = 0
   /* ------------------------------------------------------------------------------
    Inicialicao filiais com status de compartilhado
   ------------------------------------------------------------------------------ */
   select @cAux = 'SE5'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cE5_FILIAL Output
   /* ------------------------------------------------------------------------------
    Traz saldos da movimentacao para BRASIL
   ------------------------------------------------------------------------------ */
   if ( @IN_MOEDATIT < 2 and @IN_CPAISLOC = 'BRA' ) begin
      exec FIN004_## @cE5_FILIAL,  @IN_PREFIXO,   @IN_NUMERO,  @IN_PARCELA,   @IN_TIPO,
                     @IN_CLIFOR,   @IN_CONVERSAO, @IN_BAIXA,   @IN_LOJA,      @IN_DATABASE,
                     @IN_VALORTIT, @IN_MOEDATIT,  @IN_DISPONI, @IN_PCCBAIXA,  @IN_CART,
                     @IN_ADIANT,   @IN_IRFBAIXA,  @IN_ISSBAIXA, @IN_FILIALORI, @OUT_VALOR OutPut
   end else begin
      exec FIN005_## @cE5_FILIAL,  @IN_PREFIXO,   @IN_NUMERO,  @IN_PARCELA,  @IN_TIPO,
                     @IN_CLIFOR,   @IN_CONVERSAO, @IN_BAIXA,   @IN_LOJA,     @IN_DATABASE,
                     @IN_VALORTIT, @IN_MOEDATIT,  @IN_DISPONI, @IN_CART,     @IN_ADIANT,
                     @IN_CPAISLOC, @IN_TXTIT,     @OUT_VALOR OutPut
   end
   select @OUT_SALDO = @OUT_VALOR
   if @OUT_SALDO is Null select @OUT_SALDO = 0
end
