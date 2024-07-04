#ifdef SPANISH
	#define STR0001 "COBROS DIVERSOS"
#else
	#ifdef ENGLISH
		#define STR0001 "MISCELLANEOUS RECEIPTS"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "COBROS DIVERSOS", "RECEBIMENTOS DIVERSOS" )
	#endif
#endif
