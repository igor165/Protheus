#ifdef SPANISH
	#define STR0001 "No se encontró el servicio en la tabla (#1), a partir del recno: #2"
	#define STR0002 "Error al cargar configuración (#1): #2"
	#define STR0003 "No fue posible efectuar la grabación del servicio"
	#define STR0004 "No se encontró el servicio en la tabla #1, a partir del Índice (#2) y Clave (#3)"
	#define STR0005 "Error al cargar configuración (#1): #2"
#else
	#ifdef ENGLISH
		#define STR0001 "Unable to locate the service in table (#1) using recno: #2"
		#define STR0002 "Error loading configuration (#1): #2"
		#define STR0003 "Unable to save service"
		#define STR0004 "Unable to locate the service in table #1 using Index (#2) and Key (#3) "
		#define STR0005 "Error loading configuration (#1): #2"
	#else
		#define STR0001 "Não foi encontrado o serviço na tabela (#1), a partir do recno: #2"
		#define STR0002 "Erro ao carregar configuração (#1): #2"
		#define STR0003 "Não foi possivel efetuar a gravação do serviço"
		#define STR0004 "Não foi encontrado o serviço na tabela #1, a partir do Índice (#2) e Chave (#3)"
		#define STR0005 "Erro ao carregar configuração (#1): #2"
	#endif
#endif
