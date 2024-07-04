#ifdef SPANISH
	#define STR0001 "Tipos Operaciones/Deducciones"
#else
	#ifdef ENGLISH
		#define STR0001 "Types Operations/Deductions"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Tipos Operaciones/Deducciones", "Tipos Operações/Deduções" )
	#endif
#endif
