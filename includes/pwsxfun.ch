#ifdef SPANISH
	#define STR0001 "Portal Gestion de Capital Humano"
	#define STR0002 "[GetAuthWs] - Servicio no informado"
	#define STR0003 "[GetAuthWs] - Carpeta con el archivo authportal.json no encontrado"
	#define STR0004 "[GetAuthWs] - authportal.json JSON PARSE ERROR"
	#define STR0005 "[GetAuthWs] - Datos de conexión no válidos"
	#define STR0006 "[GetAuthWs] - Datos de autenticación no válidos - MV_AUTHWS"
	#define STR0007 "[GetAuthWs] - Falla en la apertura del archivo authportal.json"
	#define STR0008 "[GetAuthWs] - Conexión no disponible con el WebService."
#else
	#ifdef ENGLISH
		#define STR0001 "Human Capital Management Portal"
		#define STR0002 "[GetAuthWs] - Service not entered"
		#define STR0003 "[GetAuthWs] - Folder with file authportal.json not found"
		#define STR0004 "[GetAuthWs] - authportal.json JSON PARSE ERROR"
		#define STR0005 "[GetAuthWs] - Connection data not valid"
		#define STR0006 "[GetAuthWs] - Authentication Data not valid - MV_AUTHWS"
		#define STR0007 "[GetAuthWs] - Error opening file authportal.json"
		#define STR0008 "[GetAuthWs] - Connection unavailable with WebService."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Portal de gestão do capital humano", "Portal Gestão do Capital Humano" )
		#define STR0002 "[GetAuthWs] - Servico nao informado"
		#define STR0003 "[GetAuthWs] - Pasta contendo o arquivo authportal.json nao localizado"
		#define STR0004 "[GetAuthWs] - authportal.json JSON PARSE ERROR"
		#define STR0005 "[GetAuthWs] - Dados de conexao invalidos"
		#define STR0006 "[GetAuthWs] - Dados de Autenticacao invalidos - MV_AUTHWS"
		#define STR0007 "[GetAuthWs] - Falha na abertura do arquivo authportal.json"
		#define STR0008 "[GetAuthWs] - Conexão indisponível com o WebService."
	#endif
#endif
