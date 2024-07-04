#ifdef SPANISH
	#define STR0001 "error interno"
#else
	#ifdef ENGLISH
		#define STR0001 "internal error"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "internal error", "erro interno" )
	#endif
#endif
