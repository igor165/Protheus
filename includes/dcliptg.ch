#ifdef SPANISH
	#define STR0001 "N� Ident. Fiscal + N� Decl. Exportacion"
	#define STR0002 "La Lista de Clientes debe entregarse cuando existe reembolso del saldo a credito del IVA calcado en el periodo. Si no existiera este pedido, no es necesaria su generacion."
	#define STR0003 "LISTA DE CLIENTES - referencia a) del n� 1 del D. N. N� 53/2005 del 15/12"
	#define STR0004 "Informaciones sobre el contribuyente"
	#define STR0005 "NIF"
	#define STR0006 "Periodo del Impuesto"
	#define STR0007 "Operaciones efectuadas con clientes nacionales"
	#define STR0008 "Linea"
	#define STR0009 "N� Ident. Fiscal"
	#define STR0010 "Valor"
	#define STR0011 "Operaciones con clientes nacionales"
	#define STR0012 "Operaciones con clientes nacionales de valor inferior a 5.000 euros"
	#define STR0013 "Exportacion de bienes"
	#define STR0014 "N� Decl. Exportacion"
	#define STR0015 "Operaciones efectuadas en el extranjero"
	#define STR0016 "Operaciones efectuadas en el extranjero"
	#define STR0017 "Total"
	#define STR0018 "Operaciones efectuadas con clientes nacionales"
	#define STR0019 "*** Sin informacion ***"
	#define STR0020 "Exportacion de bienes"
#else
	#ifdef ENGLISH
		#define STR0001 "Tax Id.Nr. + Export Decl.Nr."
		#define STR0002 "Customer list must be delivered when there is reimbursement of credit balance of a periord calculated IVA.If no order exists, generation is not mandatory."
		#define STR0003 "CUSTOMER LIST - paragraph a) of nr. 1 of D. N. Nr. 53/2005 of 15/12"
		#define STR0004 "Taxpayer information"
		#define STR0005 "TIN"
		#define STR0006 "Tax Period"
		#define STR0007 "Operations perfomed with national customers."
		#define STR0008 "Line"
		#define STR0009 "Tax Identif.No."
		#define STR0010 "Value"
		#define STR0011 "Operations with national customers."
		#define STR0012 "Operations with national customers worthing less than 5,000 euros."
		#define STR0013 "Assets export"
		#define STR0014 "Export Decl. Nr."
		#define STR0015 "Operations performed overseas."
		#define STR0016 "Operations performed overseas."
		#define STR0017 "Total"
		#define STR0018 "Operations performed in national customers."
		#define STR0019 "*** No information ***"
		#define STR0020 "Assets Export"
	#else
		#define STR0001 "Nr. Ident. Fiscal + Nr. Decl. Exporta��o"
		#define STR0002 If( cPaisLoc $ "ANG|EQU|HAI", "A Rela��o de Clientes dever� ser entregue quando h� reembolso do saldo a cr�dito do IVA apurado no per�odo. Caso n�o exista esse pedido, n�o � necess�ria a sua cria��o.", If( cPaisLoc == "PTG", "A rela��o  de clientes dever� ser entregue quando h�  reembolso do saldo a cr�dito do iva apurado no per�odo . caso n�o exista esse pedido, n�o e necess�ria   a sua cria��o .", "A Rela��o de Clientes dever� ser entregue quando h� reembolso do saldo a cr�dito do IVA apurado no per�odo. Caso n�o exista esse pedido, n�o � necess�ria a sua gera��o." ) )
		#define STR0003 "RELA��O DE CLIENTES - al�nea a) do n� 1 do D. N. N� 53/2005 de 15/12"
		#define STR0004 "Informa��es sobre o contribuinte"
		#define STR0005 "NIF"
		#define STR0006 "Per�odo de Imposto"
		#define STR0007 If( cPaisLoc $ "ANG|EQU|HAI|PTG", "Opera��es efectuadas com clientes nacionais", "Opera��es efetuadas com clientes nacionais" )
		#define STR0008 "Linha"
		#define STR0009 "Nr. Ident. Fiscal"
		#define STR0010 "Valor"
		#define STR0011 "Opera��es com clientes nacionais"
		#define STR0012 "Opera��es com clientes nacionais de montante inferior a 5.000 euros"
		#define STR0013 "Exporta��o de bens"
		#define STR0014 "Nr. Decl. Exporta��o"
		#define STR0015 If( cPaisLoc $ "ANG|EQU|HAI|PTG", "Opera��es efectuadas no estrangeiro", "Opera��es efetuadas no estrangeiro" )
		#define STR0016 If( cPaisLoc $ "ANG|EQU|HAI|PTG", "Opera��es efectuadas no estrangeiro", "Opera��es efetuadas no estrangeiro" )
		#define STR0017 "Total"
		#define STR0018 If( cPaisLoc $ "ANG|EQU|HAI|PTG", "Opera��es efectuadas com clientes nacionais", "Opera��es efetuadas com clientes nacionais" )
		#define STR0019 "*** Sem informa��o ***"
		#define STR0020 "Exporta��o de bens"
	#endif
#endif
