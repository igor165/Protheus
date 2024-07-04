#ifdef SPANISH
	#define STR0001 "- Éxito en la conexión con el entorno. Intento:"
	#define STR0002 "de"
	#define STR0003 "- Falla de conexión con el entorno. Ejecutando nuevo intento"
	#define STR0004 "FALLA"
#else
	#ifdef ENGLISH
		#define STR0001 "- Successful connection to the environment. Attempt:"
		#define STR0002 "from"
		#define STR0003 "- Failed to connect to the environment. Trying again."
		#define STR0004 "FAILURE"
	#else
		#define STR0001 " - Sucesso na conexao com o ambiente. Tentativa: "
		#define STR0002 " de "
		#define STR0003 " - Falha na conexao com o ambiente. Executando nova tentativa. "
		#define STR0004 "FALHA"
	#endif
#endif
