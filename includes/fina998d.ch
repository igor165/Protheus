#ifdef SPANISH
	#define STR0001 "SERVICIO FILTRO ED TITULOS"
#else
	#ifdef ENGLISH
		#define STR0001 "BILLS ED FILTER SERVICE"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "SERVICIO FILTRO ED TITULOS", "SERVI�O FILTRO ED T�TULOS" )
	#endif
#endif
