#ifdef SPANISH
	#define STR0001 "COMUNICACIÓN DE ENTREGA AL MTPE DE   LOS APORTES AL FONDO EMPLEO"
#else
	#ifdef ENGLISH
		#define STR0001 "COMUNICACIÓN DE ENTREGA AL MTPE DE   LOS APORTES AL FONDO EMPLEO"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "COMUNICACIÓN DE ENTREGA AL MTPE DE   LOS APORTES AL FONDO EMPLEO", "COMUNICAÇÃO DE ENTREGA AO MTPE DAS CONTRIBUIÇÕES PARA O FUNDO DE EMPREGO" )
	#endif
#endif
