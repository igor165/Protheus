Create procedure MAT059_##
(
   @IN_FILIALCOR    Char('B1_FILIAL'),
   @IN_COD          Char('B1_COD'),
   @IN_MV_PRODMOD   Char(01)      ,
   @OUT_RESULTADO   Char(01) Output
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      - <v> Protheus P12 </v>
    Programa    - <s> IsProdMOD </s>
    Assinatura  - <a> 001 </a>
    Descricao   - <d> Identifica se produto é MOD </d>
    Entrada     - <ri>
                   @IN_FILIALCOR    - Filial Corrente
                   @IN_COD			- Codigo do Produto 
                   @IN_MV_PRODMOD   - Considera o campo B1_CCCUSTO
                   </ri>
    Saida         <ro> @OUT_RESULT      - Produto é MOD </ro>
    Responsavel : <r> Bruno Schmidt </r>
    Data        : <dt> 28/08/2017 </dt>
--------------------------------------------------------------------------------------------------------------------- */
declare @cFil_SB1     char('B1_FILIAL')
declare @cAux         varchar(03)
declare @cB1_CCCUSTO  char('B1_CCCUSTO')

begin
   select @cAux = 'SB1'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB1 OutPut

	select @cB1_CCCUSTO = IsNull(B1_CCCUSTO,' ') 
	  from SB1### 
	 where B1_FILIAL   = @cFil_SB1 
	   and B1_COD      = @IN_COD
	   and D_E_L_E_T_  = ' '

	if ( substring( @IN_COD, 1, 3 ) = 'MOD' )  begin
		select @OUT_RESULTADO = '1'
	end else begin
	    if @IN_MV_PRODMOD = '1' AND @cB1_CCCUSTO <> ' ' begin
			select @OUT_RESULTADO = '1'
		end else begin
			select @OUT_RESULTADO = '0'
    	end 
	end 
end