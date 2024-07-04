#ifdef SPANISH
	#define STR0001 "bUscar"
	#define STR0002 "Visualizar"
	#define STR0003 "Incluir"
	#define STR0004 "Modificar"
	#define STR0005 "Borrar"
	#define STR0006 "Archivo de reglas de entrega"
	#define STR0007 "Regla de entrega"
	#define STR0008 "Ítems de la Regla de entrega"
#else
	#ifdef ENGLISH
		#define STR0001 "Search"
		#define STR0002 "View"
		#define STR0003 "Insert"
		#define STR0004 "Edit"
		#define STR0005 "Delete"
		#define STR0006 "Delivery Rules File"
		#define STR0007 "Delivery Rule"
		#define STR0008 "Delivery Rule Items"
	#else
		#define STR0001 "Pesquisar"
		#define STR0002 "Visualizar"
		#define STR0003 "Incluir"
		#define STR0004 "Alterar"
		#define STR0005 "Excluir"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Registo De Regras De Entregas", "Cadastro de Regras de Entregas" )
		#define STR0007 "Regra de Entrega"
		#define STR0008 "Itens da Regra de Entrega"
	#endif
#endif
