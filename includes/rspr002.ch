#ifdef SPANISH
	#define STR0001 "Seleccione archivo "
	#define STR0002 "No existe archivo seleccionado"
	#define STR0003 "Archivo esta siendo usado"
	#define STR0004 "Este archivo no pertenece a la busqueda"
	#define STR0005 "Modelo de documentos(*.PES)  |*.PES|Modelo de documentos(*.CSV) |*.CSV|"
	#define STR0006 "Seleccione"
	#define STR0007 "Resultados de búsquedas grabadas en su base"
	#define STR0008 "¡Informe el nombre de la tabla utilizada!"
	#define STR0009 "No existen búsquedas efectuadas en su base de datos. Si existen archivos de búsqueda (.RSP, .PES o .CSV) para consultar, utilice la rutina RSPM003 para importar los datos."
#else
	#ifdef ENGLISH
		#define STR0001 "Select file "
		#define STR0002 "File selected not found"
		#define STR0003 "File is in Use"
		#define STR0004 "File does not belong to the Search"
		#define STR0005 "Document template(*.PES)  |*.PES|Document template(*.CSV) |*.CSV|"
		#define STR0006 "Select"
		#define STR0007 "Results of Researches Saved in the Base"
		#define STR0008 "Enter table name used!"
		#define STR0009 "No researches made in its database. If there are search files (.PES or .CSV) to be queried, use the RSPM003 routine for data import."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Seleccionar ficheiro ", "Selecione arquivo " )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Não existe ficheiro seleccionado", "Nao existe arquivo selecionado" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Ficheiro a ser usado", "Arquivo esta sendo usado" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Este ficheiro não pertence à pesquisa", "Este arquivo nao pertence a pesquisa" )
		#define STR0005 "Modelo de documentos(*.PES)  |*.PES|Modelo de documentos(*.CSV) |*.CSV|"
		#define STR0006 "Selecionar"
		#define STR0007 "Resultados de Pesquisas Salvos em sua Base"
		#define STR0008 "Informe o nome da tabela utilizada!"
		#define STR0009 "Não existem pesquisas efetuadas em sua Base de dados. Caso existam arquivos de pesquisa (.PES ou .CSV) a serem consultados, utilize a rotina RSPM003 para importação dos dados."
	#endif
#endif
