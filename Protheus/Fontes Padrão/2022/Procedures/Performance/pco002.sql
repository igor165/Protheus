
create procedure PCO002_##
( 
	@IN_FILIALCOR	Char('AKT_FILIAL'),
	@IN_DATA    	Char(08),
	@IN_CONFIG    	Char('AL1_CONFIG'),
	@IN_CHAVE      Char('AKT_CHAVE'),
	@OUT_RESULT1   Float OutPut,
	@OUT_RESULT2   Float OutPut,
	@OUT_RESULT3   Float OutPut,
	@OUT_RESULT4   Float OutPut,
	@OUT_RESULT5   Float OutPut,
	@OUT_RESULT6   Float OutPut,
	@OUT_RESULT7   Float OutPut,
	@OUT_RESULT8   Float OutPut,
	@OUT_RESULT9   Float OutPut,
	@OUT_RESULT10  Float OutPut
)
as

/* ---------------------------------------------------------------------------------------------------------------------
    Versão          - <v> Protheus P11 </v>
    Assinatura      - <a> 011 </a>
    Fonte Microsiga - <s> PCOXSLD.PRX </s>
    Descricao       - <d> Retorna o saldo da chave correspondente ao cubo na data informada  </d>
    Funcao do Siga  -     PcoRetSld()
    -----------------------------------------------------------------------------------------------------------------
    Entrada         -  <ri> @IN_FILIALCOR	- Filial corrente 
         						 @IN_DATA    	- Data do movimento
       				   		 @IN_CONFIG    	- Codigo do cubo
         						 @IN_CHAVE  		- Chave do cubo	</ri>
    -----------------------------------------------------------------------------------------------------------------
    Saida       :  <ro> 	@OUT_RESULT1 - Valor Saldo a Credito na Moeda 1
	                        @OUT_RESULT2 - Valor Saldo a Credito na Moeda 2
	                        @OUT_RESULT3 - Valor Saldo a Credito na Moeda 3
	                        @OUT_RESULT4 - Valor Saldo a Credito na Moeda 4
	                        @OUT_RESULT5 - Valor Saldo a Credito na Moeda 5
   	                     @OUT_RESULT6 - Valor Saldo a Debito na Moeda 1
	                        @OUT_RESULT7 - Valor Saldo a Debito na Moeda 2
	                        @OUT_RESULT8 - Valor Saldo a Debito na Moeda 3
	                        @OUT_RESULT9 - Valor Saldo a Debito na Moeda 4
	                        @OUT_RESULT10 - Valor Saldo a Debito na Moeda 5  </ro>
    -----------------------------------------------------------------------------------------------------------------
    Versão      :  <v> Advanced Protheus </v>
    -----------------------------------------------------------------------------------------------------------------
    Observações :  <o>   </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Paulo Carnelossi  </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 18/07/2016 </dt>

    Estrutura de chamadas
    ========= == ========

    0.PCO002 - Retorna saldo da chave para o cubo e data informada

    -----------------------------------------------------------------------------------------------------------------
    Obs.: Não remova os tags acima. Os tags são a base para a geração automática, de documentação, pelo Parse.
   --------------------------------------------------------------------------------------------------------------------- */
Declare @nValorC1  Float
Declare @nValorC2  Float
Declare @nValorC3  Float
Declare @nValorC4  Float
Declare @nValorC5  Float
Declare @nValorD1  Float
Declare @nValorD2  Float
Declare @nValorD3  Float
Declare @nValorD4  Float
Declare @nValorD5  Float

begin
   select @OUT_RESULT1 = 0
   select @OUT_RESULT2 = 0
   select @OUT_RESULT3 = 0
   select @OUT_RESULT4 = 0
   select @OUT_RESULT5 = 0
   select @OUT_RESULT6 = 0
   select @OUT_RESULT7 = 0
   select @OUT_RESULT8 = 0
   select @OUT_RESULT9 = 0
   select @OUT_RESULT10 = 0

   select @nValorC1 = 0
   select @nValorC2 = 0
   select @nValorC3 = 0
   select @nValorC4 = 0
   select @nValorC5 = 0
   select @nValorD1 = 0
   select @nValorD2 = 0
   select @nValorD3 = 0
   select @nValorD4 = 0
   select @nValorD5 = 0
   /* --------------------------------------------------------------
      Query para retorno de saldo da chave no cubo e data informado
      -------------------------------------------------------------- */
	select @nValorC1 = IsNull(Sum(AKT_MVCRD1), 0 ) ,
          @nValorC2 = IsNull(Sum(AKT_MVCRD2), 0 ) , 
	       @nValorC3 = IsNull(Sum(AKT_MVCRD3), 0 ) ,
	       @nValorC4 = IsNull(Sum(AKT_MVCRD4), 0 ) ,
	       @nValorC5 = IsNull(Sum(AKT_MVCRD5), 0 ) ,
	       @nValorD1 = IsNull(Sum(AKT_MVDEB1), 0 ) ,
	       @nValorD2 = IsNull(Sum(AKT_MVDEB2), 0 ) ,
	       @nValorD3 = IsNull(Sum(AKT_MVDEB3), 0 ) ,
	       @nValorD4 = IsNull(Sum(AKT_MVDEB4), 0 ) ,
	       @nValorD5 = IsNull(Sum(AKT_MVDEB5), 0 ) 
	  from AKT###
	 where AKT_FILIAL = @IN_FILIALCOR 
	   and AKT_CONFIG = @IN_CONFIG 
	   and AKT_CHAVE  = @IN_CHAVE 
	   and AKT_DATA  <= @IN_DATA 
	   and D_E_L_E_T_ = ' '

   select @OUT_RESULT1 = @nValorC1
   select @OUT_RESULT2 = @nValorC2
   select @OUT_RESULT3 = @nValorC3
   select @OUT_RESULT4 = @nValorC4
   select @OUT_RESULT5 = @nValorC5
   select @OUT_RESULT6 = @nValorD1
   select @OUT_RESULT7 = @nValorD2
   select @OUT_RESULT8 = @nValorD3
   select @OUT_RESULT9 = @nValorD4
   select @OUT_RESULT10 = @nValorD5

end
