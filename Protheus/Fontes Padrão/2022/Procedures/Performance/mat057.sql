Create procedure MAT057_##
 ( 
	@IN_PRODUTO 	 Char('B5_COD'),
	@IN_FILIALCOR 	 Char('B5_FILIAL'),
	@OUT_RESULTADO	 Char(01) OutPut
 )

##FIELDP01( 'SB5.B5_CTRWMS' )
as


/* ---------------------------------------------------------------------------------------------------------------------
      Versão      -  <v> Protheus P11 </v>
      Programa    -  INTDL
      Assinatura  -  <a> 010 </a>
      Descricao   -  <d> Pesquisa no SB5 e SBZ se produto corrente controla o Novo Wms </d>
      Entrada     -  <ri> @IN_PRODUTO      - Codigo do produto a ser pesquisado
                          @IN_FILIALCOR    - Filial Corrente </ri>

      Saida       -  <ro> @OUT_RESULTADO	 - Indica o termino OK da procedure </ro>
      Responsavel -  <r> Bruno Schmidt / Alexsander Correa </r>
      Data        -  <dt> 24/10/15 </dt>
--------------------------------------------------------------------------------------------------------------------- */

declare @cFil_SB5  Char('B5_FILIAL')
declare @B5_CTRWMS Char(1)
declare @cAux      Varchar(3)
declare @cFil_SBZ  Char('BZ_FILIAL')
declare @BZ_CTRWMS Char(1)

begin
    select @cAux = 'SB5'
	 EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB5 OutPut
	select @cAux = 'SBZ'
	 EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBZ OutPut

		/* -----------------------------------------------------------------------------------------------------------------
			Recupera a informacao do SB1
		----------------------------------------------------------------------------------------------------------------- */
		select @B5_CTRWMS = B5_CTRWMS
			from SB5###
		 where B5_FILIAL   = @cFil_SB5
			 and B5_COD     = @IN_PRODUTO
			 and D_E_L_E_T_ = ' '

		/* -----------------------------------------------------------------------------------------------------------------
			Recupera a informacao do SBZ
		----------------------------------------------------------------------------------------------------------------- */
		select @BZ_CTRWMS = BZ_CTRWMS
			from SBZ###
		 where BZ_FILIAL   = @cFil_SBZ
			 and BZ_COD     = @IN_PRODUTO
			 and D_E_L_E_T_ = ' '


		if @BZ_CTRWMS = '1' or @BZ_CTRWMS = '0' begin

			if  ( @BZ_CTRWMS = '1' ) or ( @BZ_CTRWMS = 'S' ) select @OUT_RESULTADO = '1'
			else select @OUT_RESULTADO = '0'

		end else begin

			if ( @B5_CTRWMS = '1' ) or ( @B5_CTRWMS = 'S' ) select @OUT_RESULTADO = '1'
			else select @OUT_RESULTADO = '0'

		end
		/* -----------------------------------------------------------------------------------------------------------------
			Retorna falso no caso de nao usar localizacao
		----------------------------------------------------------------------------------------------------------------- */
end
##ENDFIELDP01