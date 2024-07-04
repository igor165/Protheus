#ifdef SPANISH
	#define STR0001 "Existe otro usuario utilizando el título"
	#define STR0002 "Atención "
	#define STR0003 "Moneda"
	#define STR0004 "Tasa"
	#define STR0005 "Val. en "
	#define STR0116 "Tasas"
#else
	#ifdef ENGLISH
		#define STR0001 "Another user is using the bill"
		#define STR0002 "Attention"
		#define STR0003 "Currency"
		#define STR0004 "Rate"
		#define STR0005 "Amt in"
		#define STR0116 "Rates"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Existe otro usuario utilizando el título", "Há outro usuário utilizando o título" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Atención ", "Atenção" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Moneda", "Moeda" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Tasa", "Taxa" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Val. en ", "Val. em" )
		#define STR0116 If( cPaisLoc $ "ANG|PTG", "Tasas", "Taxas" )
	#endif
#endif
