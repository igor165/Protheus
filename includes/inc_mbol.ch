#ifdef SPANISH
	#define STR0001 ": : Erro : :"
	#define STR0002 "<< fechar"
#else
	#ifdef ENGLISH
		#define STR0001 ": : Error : :"
		#define STR0002 "<< close"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", ": : erro : :", ": : Erro : :" )
		#define STR0002 "<< fechar"
	#endif
#endif
