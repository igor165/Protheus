#ifdef SPANISH
	#define STR0001 "Buscar "
	#define STR0002 "Visualizar"
	#define STR0003 "Incluir"
	#define STR0004 "Modificar"
	#define STR0005 "Borrar"
	#define STR0006 "Ensayos"
	#define STR0007 "No Conformidades"
	#define STR0008 "Metodo"
	#define STR0009 "Atención"
	#define STR0010 "Se digitó algún caracter de control"
	#define STR0011 "Utilice otro caracter, evite comillas simples, caracteres especiales y operadores"
#else
	#ifdef ENGLISH
		#define STR0001 "Search   "
		#define STR0002 "View      "
		#define STR0003 "Add "
		#define STR0004 "Edit   "
		#define STR0005 "Delete "
		#define STR0006 "Tests  "
		#define STR0007 "Non-conformances "
		#define STR0008 "Method"
		#define STR0009 "Attention"
		#define STR0010 "A control character was entered"
		#define STR0011 "Use a different character, avoid single quotation marks, special characters and operators"
	#else
		#define STR0001 "Pesquisar"
		#define STR0002 "Visualizar"
		#define STR0003 "Incluir"
		#define STR0004 "Alterar"
		#define STR0005 "Excluir"
		#define STR0006 "Ensaios"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Não Conformidades", "Nao Conformidades" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Método", "Metodo" )
		#define STR0009 "Atenção"
		#define STR0010 "Foi digitado algum caracter de controle"
		#define STR0011 "Utilize outro caracter, evite aspas simples, caracteres especiais e operadores"
	#endif
#endif
