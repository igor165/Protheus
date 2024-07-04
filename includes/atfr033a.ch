#ifdef SPANISH
	#define STR0001 "Libro de inventario y balances - Detalles del saldo de la cuenta 34 Intangibles "
	#define STR0002 "EJERCICIO: "
	#define STR0003 "RUC: "
	#define STR0004 "Apellidos y nombres, denominacion o razon social:  "
	#define STR0005 "Fecha de"
	#define STR0006 "Inicio de La"
	#define STR0007 "Operacion"
	#define STR0008 "Descripcion"
	#define STR0009 "Del"
	#define STR0010 "Intangible "
	#define STR0011 "Tipo de"
	#define STR0012 " "
	#define STR0013 "Valor"
	#define STR0014 "Amortizacion"
	#define STR0015 "Contable"
	#define STR0016 "Acumulada"
	#define STR0017 "Valor Neto"
	#define STR0018 "Contable Del"
	#define STR0019 "Totales "
	#define STR0020 "¿Generar archivo TXT?"
	#define STR0021 "Generando archivo..."
	#define STR0022 "Ocurrió un error al crear el archivo Txt."
	#define STR0023 "Archivo Txt generado con éxito."
#else
	#ifdef ENGLISH
		#define STR0001 "Inventory and Balance Sheet - Details of Account Balance 34 Fixed Asset"
		#define STR0002 "YEAR:"
		#define STR0003 "RUC:"
		#define STR0004 "Last names and first names, company name:"
		#define STR0005 "From date"
		#define STR0006 "Start of"
		#define STR0007 "Operation"
		#define STR0008 "Description"
		#define STR0009 "From"
		#define STR0010 "Fixed Asset"
		#define STR0011 "Type from"
		#define STR0012 " "
		#define STR0013 "Value"
		#define STR0014 "Amortization"
		#define STR0015 "Accounting"
		#define STR0016 "Accrued"
		#define STR0017 "Net Amount"
		#define STR0018 "Accounting of"
		#define STR0019 "Total"
		#define STR0020 "Generate TXT register?"
		#define STR0021 "Generating File..."
		#define STR0022 "Error creating TXT register"
		#define STR0023 "TXT register generated successfully."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Libro de inventario y balances - Detalles del saldo de la cuenta 34 Intangibles ", "Livro de Inventário e Balanços - Detalhes do saldo da conta 34 Ativo Imobilizado" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "EJERCICIO: ", "EXERCÍCIO:" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "RUC: ", "RUC:" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Apellidos y nombres, denominacion o razon social:  ", "Sobrenomes e nomes, denominação ou razão social:" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Fecha de", "Data de" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Inicio de La", "Início da" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Operacion", "Operação" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Descripcion", "Descrição" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Del", "De" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Intangible ", "Ativo Imobilizado" )
		#define STR0011 "Tipo de"
		#define STR0012 " "
		#define STR0013 "Valor"
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Amortizacion", "Amortização" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Contable", "Contábil" )
		#define STR0016 "Acumulada"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Valor Neto", "Valor Líquido" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Contable Del", "Contábil do" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Totales ", "Totais" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "¿Generar archivo TXT?", "Gerar cadastro TXT?" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Generando archivo...", "Gerando arquivo..." )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Ocurrió un error al crear el archivo Txt.", "Ocorreu um erro ao criar o cadastro TXT." )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Archivo Txt generado con éxito.", "Cadastro TXT gerado com sucesso." )
	#endif
#endif
