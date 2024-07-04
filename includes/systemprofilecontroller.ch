#ifdef SPANISH
	#define STR0001 'Objecto Json invalido'
#else
	#ifdef ENGLISH
		#define STR0001 "Json object invalid"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", 'Objecto Json invalido', "Objeto Json inválido" )
	#endif
#endif
