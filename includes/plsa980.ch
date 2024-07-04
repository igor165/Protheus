#ifdef SPANISH
	#define STR0001 "Buscar"
	#define STR0002 "Visualizar"
	#define STR0003 "Incluir"
	#define STR0004 "Modificar"
	#define STR0005 "Borrar"
	#define STR0006 "Para funcionamiento de esta rutina es necesaria la tabla BX5"
	#define STR0007 "Operador vs. Institucion"
	#define STR0008 "Operador vs. Institucion vs. Criticas"
	#define STR0009 "Marca y Desmarca todos"
	#define STR0010 "Grupo/Empresa/Contrato"
	#define STR0011 "Regiones"
	#define STR0012 "Departamentos"
	#define STR0013 "GRABADO"
	#define STR0014 "Existe registro con esta información."
	#define STR0015 "Cambie la clave principal de este registro."
#else
	#ifdef ENGLISH
		#define STR0001 "Search"
		#define STR0002 "View"
		#define STR0003 "Add"
		#define STR0004 "Edit"
		#define STR0005 "Delete"
		#define STR0006 "This routine will work by using the BX5 table"
		#define STR0007 "Operator X Institution"
		#define STR0008 "Operator X Institution X Criticism"
		#define STR0009 "Mark and Unmark All"
		#define STR0010 "Group/Company/Contract"
		#define STR0011 "Regions"
		#define STR0012 "Departments"
		#define STR0013 "ALREADYSAVED"
		#define STR0014 "A record already exists with this information."
		#define STR0015 "Change the main key of this record."
	#else
		#define STR0001 "Pesquisar"
		#define STR0002 "Visualizar"
		#define STR0003 "Incluir"
		#define STR0004 "Alterar"
		#define STR0005 "Excluir"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Para Funcionamento Deste Procedimento  é Necessário A Tabela Bx5", "Para funcionamento desta rotina e necessario a tabela BX5" )
		#define STR0007 "Operador X Instituição"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Operador X Instituição X Críticas", "Operador X Instituição X Criticas" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Marca e desmarca todos", "Marca e Desmarca todos" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Grupo/empresa/contrato", "Grupo/Empresa/Contrato" )
		#define STR0011 "Regiões"
		#define STR0012 "Departamentos"
		#define STR0013 "JAGRAVADO"
		#define STR0014 "Já existe registro com esta informação."
		#define STR0015 "Troque a chave principal deste registro."
	#endif
#endif
