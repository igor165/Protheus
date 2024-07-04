#ifdef SPANISH
	#define STR0001 "Buscar"
	#define STR0002 "Visualizar"
	#define STR0003 "Incluir"
	#define STR0004 "Modificar"
	#define STR0005 "Borrar "
	#define STR0006 "Archivo de Departamentos/Sector"
	#define STR0007 "¡Debido a la integración, el mantenimiento del departamento solo se podrá realizar mediante la gestión de personal!"
	#define STR0008 "Atención"
	#define STR0009 "¡Debido a la integración, el borrado del departamento solo se podrá hacer por medio de la gestión de personal!"
#else
	#ifdef ENGLISH
		#define STR0001 "Search   "
		#define STR0002 "View     "
		#define STR0003 "Insert "
		#define STR0004 "Edit   "
		#define STR0005 "Delete  "
		#define STR0006 "Department/Sector File"
		#define STR0007 "Due to integration, Department maintenance can be performed only through Personnel Management!"
		#define STR0008 "Attention"
		#define STR0009 "Due to integration, Department deletion can be performed only through Personnel Management!"
	#else
		#define STR0001 "Pesquisar"
		#define STR0002 "Visualizar"
		#define STR0003 "Incluir"
		#define STR0004 "Alterar"
		#define STR0005 "Excluir"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Registo De Departamentos/sector", "Cadastro de Departamentos/Setor" )
		#define STR0007 "Devido a integracao, a manutencao do Departamento somente podera ser feita atraves do Gestao de Pessoal!"
		#define STR0008 "Atenção"
		#define STR0009 "Devido a integracao, a exclusao do Departamento somente podera ser feita atraves do Gestao de Pessoal!"
	#endif
#endif
