#ifdef SPANISH
	#define STR0001 "De/A de sucursal (SM0) no encontrado - Cód. de la sucursal de origen:"
	#define STR0002 "Error al realizar el XMLParser -"
	#define STR0003 "El parámetro cMsgOriginal está vacío y no se podrá ejecutar el XMLParser"
	#define STR0004 "No se encontró el proceso (MHP), puede ser que el proceso no esté registrado o no esté activo. Suscriptor:"
	#define STR0005 "- Proceso:"
#else
	#ifdef ENGLISH
		#define STR0001 "Branch from/to (SM0) not found - Origin Branch Code:"
		#define STR0002 "Error in XMLParser -"
		#define STR0003 "The cMsgOriginal parameter is empty and it will not be possible to execute the XMLParser"
		#define STR0004 "The process (MHP) was not found, the process may not be registered or it is not active. Subscriber:"
		#define STR0005 "- Process:"
	#else
		#define STR0001 "De/para de filial (SM0) não encontrado - Cod. da Filial de Origem: "
		#define STR0002 "Erro ao realizar o XMLParser - "
		#define STR0003 "O parâmetro cMsgOriginal esta vazio e não vai ser possível executar o XMLParser"
		#define STR0004 "Não foi encontrado o processo (MHP), o processo pode não estar cadastrado ou não esta ativo. Assinante: "
		#define STR0005 " - Processo: "
	#endif
#endif
