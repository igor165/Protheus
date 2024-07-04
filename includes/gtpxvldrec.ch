#ifdef SPANISH
	#define STR0001 "El documento #1 - #2 está vencido desde el día #3, sin embargo está dentro de la tolerancia máxima (#4). ¿Desea continuar?"
	#define STR0002 "¡Atención!"
#else
	#ifdef ENGLISH
		#define STR0001 "The document #1 - #2 is expired since day #3, however it is within the maximum tolerance (#4). Continue?"
		#define STR0002 "Attention!!!"
	#else
		#define STR0001 "O documento #1 - #2 encontra-se vencido desde o dia #3, porem está dentro da tolerância máxima (#4). Deseja Continuar?"
		#define STR0002 "Atenção!!!"
	#endif
#endif
