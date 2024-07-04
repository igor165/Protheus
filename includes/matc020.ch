#ifdef SPANISH
	#define STR0001 "Recurso"
	#define STR0002 "Histograma de Carga Maquina"
	#define STR0003 "Reserva (en %)"
	#define STR0004 "Configuración de parámetros"
	#define STR0005 "Parámetro no configurado"
	#define STR0006 "Definir la información de los parámetros MV_DIRPCP, por el configurador"
#else
	#ifdef ENGLISH
		#define STR0001 "Resource"
		#define STR0002 "Machine Load Histogram"
		#define STR0003 "Allocation (%)"
		#define STR0004 "Parameter configuration"
		#define STR0005 "Parameter not configured"
		#define STR0006 "Set data of parameter MV_DIRPCP through the configurator"
	#else
		#define STR0001 "Recurso"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Histograma da carga máquina", "Histograma da Carga Máquina" )
		#define STR0003 "Alocação (em %)"
		#define STR0004 "Configuração de Parametros"
		#define STR0005 "Parametro não configurado"
		#define STR0006 "Definir as informações dos parametros MV_DIRPCP, pelo configurador"
	#endif
#endif
