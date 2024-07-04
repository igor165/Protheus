#ifdef SPANISH
	#define STR0001 "Cosechas"
#else
	#ifdef ENGLISH
		#define STR0001 "Crops"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Cosechas", "Safras" )
	#endif
#endif
