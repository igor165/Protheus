Create procedure MAT012_##

 ( 
	@IN_PRODUTO 	 Char('B1_COD'),
	@IN_FILIALCOR 	 Char('B1_FILIAL'),
	@IN_MV_WMSNEW    Char(01),
	@IN_MV_ARQDPROD	 Char(03),	
	@OUT_RESULTADO	 Char(01) OutPut
 )

as

/* ---------------------------------------------------------------------------------------------------------------------
      Versão      -  <v> Protheus P12 </v>
      Programa    -  LOCALIZA
      Assinatura  -  <a> 001 </a>
      Descricao   -  <d> Pesquisa no SB1 se produto corrente usa localizacao fisica </d>
      Entrada     -  <ri> @IN_PRODUTO      - Codigo do produto a ser pesquisado
                          @IN_FILIALCOR    - Filial Corrente </ri>

      Saida       -  <ro> @OUT_RESULTADO	 - Indica o termino OK da procedure </ro>
      Responsavel -  <r> Emerson Tobar </r>
      Data        -  <dt> 20/06/00 </dt>
--------------------------------------------------------------------------------------------------------------------- */

declare @cFil_SB1   Char('B1_FILIAL')
declare @B1_LOCALIZ Char('B1_LOCALIZ')
declare @cAux       Varchar(3)
declare @cFil_SBZ   Char('BZ_FILIAL')
declare @BZ_LOCALIZ Char('BZ_LOCALIZ')

begin
    select @cAux = 'SB1'
	 EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB1 OutPut

	 select @cAux = 'SBZ'
	 EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBZ OutPut
		/* -----------------------------------------------------------------------------------------------------------------
			Recupera a informacao do SB1
		----------------------------------------------------------------------------------------------------------------- */
		select @B1_LOCALIZ = B1_LOCALIZ
			from SB1###
		 where B1_FILIAL   = @cFil_SB1
			 and B1_COD     = @IN_PRODUTO
			 and D_E_L_E_T_ = ' '

		if (@IN_MV_WMSNEW = '1') or (@IN_MV_ARQDPROD = 'SBZ') begin
			/* --------------------------
			Recupera a informacao do SBZ
			---------------------------- */
			select @BZ_LOCALIZ = BZ_LOCALIZ
			from SBZ###
			where BZ_FILIAL   = @cFil_SBZ
				and BZ_COD     = @IN_PRODUTO
				and D_E_L_E_T_ = ' '

			if  ( @BZ_LOCALIZ = '1' ) or ( @BZ_LOCALIZ = 'S' ) or ( @BZ_LOCALIZ = '0' ) or ( @BZ_LOCALIZ = 'N' ) begin
				if ( @BZ_LOCALIZ = '1' ) or ( @BZ_LOCALIZ = 'S' ) select @OUT_RESULTADO = '1'
				else select @OUT_RESULTADO = '0'
			end else begin
				if ( @B1_LOCALIZ = '1' ) or ( @B1_LOCALIZ = 'S' ) select @OUT_RESULTADO = '1'
				else select @OUT_RESULTADO = '0'
			end
		end else begin

			if ( @B1_LOCALIZ = '1' ) or ( @B1_LOCALIZ = 'S' ) select @OUT_RESULTADO = '1'
			else select @OUT_RESULTADO = '0'
	
		end
		/* -----------------------------------------------------------------------------------------------------------------
			Retorna falso no caso de nao usar localizacao
		----------------------------------------------------------------------------------------------------------------- */
end
