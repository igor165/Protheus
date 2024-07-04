#ifdef SPANISH
	#define STR0001 "Informe con lista de clientes ordenados"
	#define STR0002 "por la secuencia de atención, en la cual el"
	#define STR0003 "cobrador utilizará en la visita al Campo."
	#define STR0004 "Clientes vs. Cobrador"
	#define STR0005 "    (Código) Cobrador"
	#define STR0006 "             Secuencia  CodCli-Sc Cliente"
	#define STR0007 "Seleccionando registros..."
	#define STR0008 "Código del cobrador"
	#define STR0009 "Nombre del cobrador"
	#define STR0010 "Cobradores"
	#define STR0011 "Cantidad"
	#define STR0012 "A rayas"
	#define STR0013 "Administración"
	#define STR0014 "*** ANULADO POR EL OPERADOR***"
#else
	#ifdef ENGLISH
		#define STR0001 "Report presenting the customer list in order"
		#define STR0002 "by the servicing sequence, in which the "
		#define STR0003 "which the collector will use during field visiting."
		#define STR0004 "Customer X Collector"
		#define STR0005 "    (Code)  Collector"
		#define STR0006 "             Sequence   Cus.Cd-Br Customer"
		#define STR0007 "Selecting records..."
		#define STR0008 "Collector code    "
		#define STR0009 "Collector name  "
		#define STR0010 "Collectors"
		#define STR0011 "Quantity"
		#define STR0012 "Z-form"
		#define STR0013 "Administration"
		#define STR0014 "*** CANCELED BY OPERATOR***"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Relatório com relação de clientes, ordenados", "Relatório com relacão de clientes, ordenados" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Pela sequência de atendimeto, na qual o ", "pela sequência de atendimento, na qual o " )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Credor utilizará em visita a campo.", "cobrador utilizara em visita a campo." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Clientes X Credor", "Clientes X Cobrador" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "    (código) Credor", "    (Código) Cobrador" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "             Sequência  Codcli-fil. Cliente", "             Sequência  CodCli-Fil. Cliente" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "A Seleccionar Registos...", "Selecionando Registros..." )
		#define STR0008 "Código do cobrador"
		#define STR0009 "Nome do cobrador"
		#define STR0010 "Cobradores"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Cantidad", "Quantidade" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "A rayas", "Zebrado" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Administración", "Administração" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "*** ANULADO POR EL OPERADOR***", "*** CANCELADO PELO OPERADOR***" )
	#endif
#endif
