Create procedure MAT011_##
 ( 
  @IN_MV_RASTRO    Char(01),
  @IN_PRODUTO      Char('B1_COD'),
  @IN_TIPO         Char('B1_TIPO'),
  @IN_FILIALCOR    Char('B1_FILIAL'),
  @OUT_RESULTADO   Char(01) OutPut
 )
as

/* --------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <o> RASTRO </o>
    Descricao   -  <d> Pesquisa no SB1 se produto corrente usa rastreabilidade </d>
    Assinatura  -  <a> 001 </a>
    Entrada        <ri> @IN_MV_RASTRO    - Conteudo de GetMV("MV_RASTRO")
                   @IN_PRODUTO      - Codigo do produto a ser pesquisado
                   @IN_TIPO         - Tipo de Rastreabilidade
                   @IN_FILIALCOR    - Filial Corrente </ri>

    Saida       -  <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :  <r> Emerson Tobar </r>	
    Data        :  <dt> 20/06/00 </dt>
-------------------------------------------------------------------------------------- */

declare @cTipo      char('B1_TIPO')
declare @cFil_SB1   char('B1_FILIAL')
declare @B1_RASTRO  char('B1_RASTRO')
declare @cAux       Varchar(3)

begin
	select @cAux = 'SB1'
	EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB1 OutPut
	if ( @IN_MV_RASTRO = '1' ) or ( @IN_MV_RASTRO = 'S' ) begin
		
		/* -------------------------------------------------------------------------
		Passa parametro para variavel para poder alterar conteudo
		------------------------------------------------------------------------- */
		select @cTipo = @IN_TIPO
		if ( @cTipo is null ) select @cTipo = ' '
		
		/* -------------------------------------------------------------------------
		Recupera a informacao do SB1                                              
		------------------------------------------------------------------------- */
		select @B1_RASTRO = B1_RASTRO
		  from SB1### ( NOLOCK )
		 where B1_FILIAL  = @cFil_SB1
			and B1_COD     = @IN_PRODUTO
			and D_E_L_E_T_ = ' '
		
		/* -------------------------------------------------------------------------
		Testa o tipo enviado para setar o resultado                                              
		------------------------------------------------------------------------- */
		if ( @cTipo = ' ' ) begin
			if ( CharIndex(@B1_RASTRO, 'S') > 0 ) or ( CharIndex(@B1_RASTRO, 'L') > 0 ) select @OUT_RESULTADO = '1'
			else																		select @OUT_RESULTADO = '0'
		end else begin
			if ( CharIndex(@B1_RASTRO, @cTipo) > 0 ) select @OUT_RESULTADO = '1'
			else                                     select @OUT_RESULTADO = '0'
		end
	end else begin
		/* -------------------------------------------------------------------------
		Retorna falso no caso de nao usar localizacao
		------------------------------------------------------------------------- */
		select @OUT_RESULTADO = '0'
	end
end
