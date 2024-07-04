Create procedure MAT025_##
( 
   @IN_FILIALCOR  char('B1_FILIAL'),
   @IN_CPRODUTO   char('B1_COD'),
   @IN_CLOCAL     char('B2_LOCAL'),
   @OUT_RESULTADO integer output
)

as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Protheus P12 </v>
    -----------------------------------------------------------------------------------------------------------------    
    Programa    :   <s> CriaSB2 </s>
    -----------------------------------------------------------------------------------------------------------------    
    Assinatura  :   <a> 001 </a>
    -----------------------------------------------------------------------------------------------------------------    
    Descricao   :   <d> Padrao para criar registros no arquivo de saldos em estoque (SB2) </d>
    -----------------------------------------------------------------------------------------------------------------
    Entrada     :  <ri> @IN_FILIALCOR  - Filial Corrente
                        @IN_CPRODUTO   - Produto a ser incluido no B2 ( Caso nao exista )
                        @IN_CLOCAL     - Codigo do Almoxarifado </ri>                   
    -----------------------------------------------------------------------------------------------------------------
    Saida       :  <ro> @OUT_RESULTADO - Numero do R_E_C_N_O_ gerado no B2 </ro>
    -----------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Advanced Protheus </v>
    -----------------------------------------------------------------------------------------------------------------
    Observações :   <o>   </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Marco Norbiato </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 16/01/2001 </dt>
    -----------------------------------------------------------------------------------------------------------------
    Obs.: Não remova os tags acima. Os tags são a base para a geração automática, de documentação, pelo Parse.
--------------------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------------------------------------------------------------------------------------
   Declaração de variáveis para cursor (Declare abaixo todas as variáveis utilidas no select do cursor)
--------------------------------------------------------------------------------------------------------------------- */

--<*> ----- Fim da Declaração de variáveis para cursor ----------------------------------------------------------- <*>--


/* ---------------------------------------------------------------------------------------------------------------------
   Variaveis internas (Declare abaixo todas as variáveis utilizadas na procedure)
--------------------------------------------------------------------------------------------------------------------- */
declare @cFil_SB2   char('B2_FILIAL')
declare @nContador  integer
declare @cAux       Varchar(3)
--<*> ----- Fim da Declaração de variáveis internas -------------------------------------------------------------- <*>--

begin
   select @cAux = 'SB2'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB2 OutPut

   select @nContador = isnull( R_E_C_N_O_ , 0 )
     from SB2###
    where B2_FILIAL   = @cFil_SB2
      and B2_COD      = @IN_CPRODUTO
      and B2_LOCAL    = @IN_CLOCAL
      and D_E_L_E_T_  = ' '

   /* -------------------------------------------------------------------------------------------------------------------
      Cria registro quando nao existir
   ------------------------------------------------------------------------------------------------------------------- */
   if ( @nContador = 0 ) begin
      select @nContador = Max( R_E_C_N_O_ ) from SB2###
      if @nContador is Null select @nContador = 0

      select @nContador = @nContador + 1 
      begin tran
      insert into SB2### ( B2_FILIAL, B2_COD,       B2_LOCAL,   R_E_C_N_O_ )
           values        ( @cFil_SB2, @IN_CPRODUTO, @IN_CLOCAL, @nContador )
      Commit Tran
   end

   select @OUT_RESULTADO = @nContador   
   
end
