#ifdef SPANISH
	#define STR0001 "Buscar"
	#define STR0002 "Visualizar"
	#define STR0003 "Incluir"
	#define STR0004 "Modificar"
	#define STR0005 "Borrar"
	#define STR0006 "Archivo de Modelos"
	#define STR0007 "ATENCAO"
	#define STR0008 "O código informado é de uso reservado e não pode ser cadastrado."
	#define STR0009 "Utilize outro valor para o código de tipo modelo."
#else
	#ifdef ENGLISH
		#define STR0001 "Search"
		#define STR0002 "View"
		#define STR0003 "Add"
		#define STR0004 "Edit"
		#define STR0005 "Delete"
		#define STR0006 "Model File"
		#define STR0007 "ATENCAO"
		#define STR0008 "O código informado é de uso reservado e não pode ser cadastrado."
		#define STR0009 "Utilize outro valor para o código de tipo modelo."
	#else
		#define STR0001 "Pesquisar"
		#define STR0002 "Visualizar"
		#define STR0003 "Incluir"
		#define STR0004 "Alterar"
		#define STR0005 "Excluir"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Registo De Modelos", "Cadastro de Modelos" )
		#define STR0007 "ATENCAO"
		#define STR0008 "O código informado é de uso reservado e não pode ser cadastrado."
		#define STR0009 "Utilize outro valor para o código de tipo modelo."
	#endif
#endif
