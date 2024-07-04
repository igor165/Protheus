#ifdef SPANISH
	#define STR0001 "Buscar"
	#define STR0002 "Visualizar"
	#define STR0003 "Incluir"
	#define STR0004 "Modificar"
	#define STR0005 "Borrar"
	#define STR0006 "Archivo de Documentos"
	#define STR0007 "La rutina Documentos (MNTA705) se descontinuó a partir del release 12.1.27 Octubre"
	#define STR0008 "Sustituya la rutina MNTA705 presente en el menú del módulo SIGAMNT por la rutina MNTA706."
#else
	#ifdef ENGLISH
		#define STR0001 "Search"
		#define STR0002 "View"
		#define STR0003 "Add"
		#define STR0004 "Edit"
		#define STR0005 "Delete"
		#define STR0006 "Document File"
		#define STR0007 "The Documents routine (MNTA705) was discontinued as of release 12.1.27 October"
		#define STR0008 "Substitute routine MNTA705 in the menu of the SIGAMNT module by routine MNTA706."
	#else
		#define STR0001 "Pesquisar"
		#define STR0002 "Visualizar"
		#define STR0003 "Incluir"
		#define STR0004 "Alterar"
		#define STR0005 "Excluir"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Registo De Documentos", "Cadastro de Documentos" )
		#define STR0007 "A rotina Documentos (MNTA705) foi descontinuada a partir do release 12.1.27 Outubro"
		#define STR0008 "Substitua a rotina MNTA705 presente no menu do módulo SIGAMNT pela rotina MNTA706."
	#endif
#endif
