#ifdef SPANISH
	#define STR0001 "Tipos de Documentos - <F4>"
	#define STR0002 "Tp.Docto."
	#define STR0003 "Cuentas Especiales"
	#define STR0004 "Buscar"
	#define STR0005 "Visualizar"
	#define STR0006 "Incluir"
	#define STR0007 "Modificar"
	#define STR0008 "Borrar"
#else
	#ifdef ENGLISH
		#define STR0001 "Document Types - <F4>"
		#define STR0002 "Doc. Tp."
		#define STR0003 "Special Accounts"
		#define STR0004 "Search"
		#define STR0005 "View"
		#define STR0006 "Add"
		#define STR0007 "Edit"
		#define STR0008 "Delete"
	#else
		#define STR0001 "Tipos de Documentos - <F4>"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Tp.Doc.", "Tp.Docto." )
		#define STR0003 "Contas Especiais"
		#define STR0004 "Pesquisar"
		#define STR0005 "Visualizar"
		#define STR0006 "Incluir"
		#define STR0007 "Alterar"
		#define STR0008 "Excluir"
	#endif
#endif
