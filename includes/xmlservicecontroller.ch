#ifdef SPANISH
	#define STR0001 'Objeto Json invalido.'
#else
	#ifdef ENGLISH
		#define STR0001 "Invalid Json object."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", 'Objeto Json invalido.', "Objeto Json inválido." )
	#endif
#endif
