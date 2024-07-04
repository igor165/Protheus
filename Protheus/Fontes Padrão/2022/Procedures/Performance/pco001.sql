create procedure PCO001_##
( 
	@IN_FILIALCOR	Char('AKT_FILIAL'),
	@IN_CONFIG    	Char('AL1_CONFIG'),
	@IN_TIPOMOV    Char(01),
	@IN_FIMMES    	Char(08),
	@IN_CHAVE      Char('AKT_CHAVE'),
	@IN_VALOR1   	float,
	@IN_VALOR2   	float,
	@IN_VALOR3   	float,
	@IN_VALOR4   	float,
	@IN_VALOR5   	float,
	@OUT_RESULTADO Char(01) OutPut
	
)
as

/* ---------------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Protheus P11 </v>
    -----------------------------------------------------------------------------------------------------------------    
    Programa    :   <s> PCOXSLD.prx  </s>
    -----------------------------------------------------------------------------------------------------------------    
    Assinatura  :   <a> 010 </a>
    -----------------------------------------------------------------------------------------------------------------    
    Descricao   :   <d> Atualiza os saldos dos cubos nas datas posteriores ao movimento  </d>
    -----------------------------------------------------------------------------------------------------------------
    Entrada     :  <ri> @IN_FILIALCOR	- Filial corrente 
				   		@IN_CONFIG    	- Codigo do cubo
						@IN_TIPOMOV		- Tipo de movimento (C=Credito;D=Debito) 
						@IN_FIMMES    	- Ultimo dia do mes da data do movimento
						@IN_CHAVE  		- Chave do cubo
						@IN_VALOR1   	- Valor na moeda 1
						@IN_VALOR2   	- Valor na moeda 2
						@IN_VALOR3   	- Valor na moeda 3
						@IN_VALOR4   	- Valor na moeda 4
						@IN_VALOR5   	- Valor na moeda 5
					</ri>
    -----------------------------------------------------------------------------------------------------------------
    Saida       :  <ro> Sem saida </ro>
    -----------------------------------------------------------------------------------------------------------------
    Versão      :  <v> Advanced Protheus </v>
    -----------------------------------------------------------------------------------------------------------------
    Observações :  <o>   </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Marcelo Pimentel  </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 25/11/2005 </dt>

    Estrutura de chamadas
    ========= == ========

    0.PCO001 - Atualiza os saldos dos cubos (futuros)

    -----------------------------------------------------------------------------------------------------------------
    Obs.: Não remova os tags acima. Os tags são a base para a geração automática, de documentação, pelo Parse.
--------------------------------------------------------------------------------------------------------------------- */
Declare @cFil_AKS        Char('AKS_FILIAL')
Declare @cAux            Char(03)
begin
   select @OUT_RESULTADO = '0'
   /* ------------------------------------------------------------------------------------------------------------------
      Recuperando Filiais
   ------------------------------------------------------------------------------------------------------------------ */
   select @cAux = 'AKS'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_AKS OutPut
	 
   if @IN_TIPOMOV = 'C' begin
   	  update AKS###
  		set AKS_SDCRD1	=	AKS_SDCRD1 + @IN_VALOR1,	
			AKS_SDCRD2	=	AKS_SDCRD2 + @IN_VALOR2,	
			AKS_SDCRD3	=	AKS_SDCRD3 + @IN_VALOR3,	
			AKS_SDCRD4	=	AKS_SDCRD4 + @IN_VALOR4,	
			AKS_SDCRD5 	=	AKS_SDCRD5 + @IN_VALOR5
		where AKS_FILIAL    = @cFil_AKS
			and AKS_CONFIG  = @IN_CONFIG
			and AKS_CHAVE   = @IN_CHAVE
			and AKS_DATA	> @IN_FIMMES 
     		and D_E_L_E_T_  =  ' '
	end else begin
		update AKS###
   		set 	AKS_SDDEB1	=	AKS_SDDEB1 + @IN_VALOR1,	
			AKS_SDDEB2	=	AKS_SDDEB2 + @IN_VALOR2,	
			AKS_SDDEB3	=	AKS_SDDEB3 + @IN_VALOR3,	
			AKS_SDDEB4	=	AKS_SDDEB4 + @IN_VALOR4,	
			AKS_SDDEB5 	=	AKS_SDDEB5 + @IN_VALOR5
		where AKS_FILIAL   = @cFil_AKS
  	  		and AKS_CONFIG = @IN_CONFIG
			and AKS_CHAVE  = @IN_CHAVE
			and AKS_DATA   > @IN_FIMMES 
     		and D_E_L_E_T_  =  ' '
	end
   select @OUT_RESULTADO = '1'
end
