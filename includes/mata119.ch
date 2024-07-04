#ifdef SPANISH
	#define STR0001 "Use la rutina de inclusion de facturas de entrada, seleccionado el tipo FLETE, para incluir facturas de gasto de importacion. "
	#define STR0002 "Rutina fuera de uso"
	#define STR0003 "Gasto de Importacion"
	#define STR0004 "Busca"
	#define STR0005 "Visualizar"
	#define STR0006 "Borrar"
	#define STR0007 "Genera Gasto."
	#define STR0008 "Totales"
	#define STR0009 "Inf. Proveedor/Cliente"
	#define STR0010 "Descuentos/Flete/Gastos"
	#define STR0011 "Libros Fiscales"
	#define STR0012 "Impuestos"
	#define STR0013 "Titulos"
	#define STR0014 "Pro. CC"
	#define STR0015 "Prorrateo por Cent. Costo"
	#define STR0016 "Entre los items seleccionados ya existe un documento de flete y o gasto de importacion vinculado."
	#define STR0017 "Información DANFE"
	#define STR0018 "Tributos genéricos"
	#define STR0019 "Valor del gasto no válido."
	#define STR0020 "Informe el valor del gasto de importación."
	#define STR0021 "Por favor, actualice el fuente FINXIMP para una versión igual o superior a 29/11/2019"
	#define STR0022 "Seleccione un documento para la generación del gasto."
#else
	#ifdef ENGLISH
		#define STR0001 "Use the incoming invoice inclusion routine, selecting the FREIGHT type, to include import expense invoices. "
		#define STR0002 "Routine out of use"
		#define STR0003 "Import Expenses"
		#define STR0004 "Search"
		#define STR0005 "View"
		#define STR0006 "Delete"
		#define STR0007 "Generates Expenses"
		#define STR0008 "Totals"
		#define STR0009 "Enter Supplier/Customer"
		#define STR0010 "Discounts/Freight/Expenses"
		#define STR0011 "Tax Records"
		#define STR0012 "Taxes"
		#define STR0013 "Trade Notes"
		#define STR0014 "C.C. Proration"
		#define STR0015 "Proration per Cost Center"
		#define STR0016 "Among the items selected is a document of freight and/or import expense linked."
		#define STR0017 "DANFE Information"
		#define STR0018 "Generic Taxes"
		#define STR0019 "Invalid Expense Value."
		#define STR0020 "Enter Import Expense Value."
		#define STR0021 "Use the FINXIMP source to a version equal to or greater than 11/29/2019."
		#define STR0022 "Select document for the generation of expense."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Utilize o procedimento de inclusão de notas de entrada, seleccionado o tipo de frete, para incluir notas fiscais de despesa de importação. ", "Use a rotina de inclusao de notas de entrada, selecionado o tipo FRETE, para incluir notas fiscais de despesa de importacao. " )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Procedimento fora de utilização", "Rotina fora de uso" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Despesa De Importação", "Despesa de Importação" )
		#define STR0004 "Pesquisar"
		#define STR0005 "Visualizar"
		#define STR0006 "Excluir"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "A Criar A Despesa", "Gera Despesa." )
		#define STR0008 "Totais"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Informação Ao Fornecedor/cliente", "Inf. Fornecedor/Cliente" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Descontos/serviço/despesas", "Descontos/Frete/Despesas" )
		#define STR0011 "Livros Fiscais"
		#define STR0012 "Impostos"
		#define STR0013 "Duplicatas"
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Rat. Cc", "Rat. CC" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Rateio Por Centro De Custo", "Rateio por Centro de Custo" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Entre os itens seleccionados já existe um documento de frete e/ou despesa de importação vinculado.", "Entre os itens selecionados ja existe um documento de frete e ou despesa de importacao vinculado." )
		#define STR0017 "Informações DANFE"
		#define STR0018 "Tributos Genéricos"
		#define STR0019 "Valor da Despesa Inválido."
		#define STR0020 "Informe o valor da Despesa de Importação."
		#define STR0021 "Por favor, atualize o fonte FINXIMP para uma versão igual ou superior a 29/11/2019"
		#define STR0022 "Selecione documento para geração da despesa."
	#endif
#endif
