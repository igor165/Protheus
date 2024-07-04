#ifdef SPANISH
	#define STR0001 "Buscar"
	#define STR0002 "Visualizar"
	#define STR0003 "Incluir"
	#define STR0004 "Modificar"
	#define STR0005 "Borrar"
	#define STR0006 "Imprimir"
	#define STR0007 "Tipo de actividad Time sheet"
	#define STR0008 "Modelo de datos de tipo de actividad Time sheet"
	#define STR0009 "Datos de tipo de actividad Time sheet"
	#define STR0010 "Descripcion del Tipo por Idioma"
	#define STR0011 "Es necesario incluir todos los idiomas"
	#define STR0012 "Es necesario incluir todas descripciones"
	#define STR0013 "No fue posible borrar, existen Time Sheets relacionados a este codigo de actividad"
	#define STR0014 "Áreas jurídicas vs. Tipo de actividad"
#else
	#ifdef ENGLISH
		#define STR0001 "Search"
		#define STR0002 "View"
		#define STR0003 "Add"
		#define STR0004 "Change"
		#define STR0005 "Delete"
		#define STR0006 "Print"
		#define STR0007 "Time Sheet Activity Type"
		#define STR0008 "Data Model of Time-sheet Activity Type"
		#define STR0009 "Data of Time-sheet Activity Type"
		#define STR0010 "Description of Type by Language"
		#define STR0011 "All languages must be included"
		#define STR0012 "Add all descriptions"
		#define STR0013 "Could not be deleted. There are Time Sheets associated with this activity code."
		#define STR0014 "Legal Areas x Activity Type"
	#else
		#define STR0001 "Pesquisar"
		#define STR0002 "Visualizar"
		#define STR0003 "Incluir"
		#define STR0004 "Alterar"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Eliminar", "Excluir" )
		#define STR0006 "Imprimir"
		#define STR0007 "Tipo de Atividade Time Sheet"
		#define STR0008 "Modelo de Dados de Tipo de Atividade Time Sheet"
		#define STR0009 "Dados de Tipo de Atividade Time Sheet"
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Descrição do tipo por idioma", "Descrição do Tipo por Idioma" )
		#define STR0011 "É preciso incluir todos os idiomas"
		#define STR0012 "É preciso incluir todas descrições"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Não foi possível excluir. Existem time-sheets relacionados a este código de actividade.", "Não foi possível excluir, existem Time Sheets relacionados a este código de atividade" )
		#define STR0014 "Áreas Jurídicas x Tipo de Atividade"
	#endif
#endif
