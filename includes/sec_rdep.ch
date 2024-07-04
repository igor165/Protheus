#ifdef SPANISH
	#define STR0001 "Mensagem ao Departamento"
	#define STR0002 "Mensagem"
	#define STR0003 "Depto"
	#define STR0004 "Fechar"
#else
	#ifdef ENGLISH
		#define STR0001 "Department Message"
		#define STR0002 "Message"
		#define STR0003 "Dept"
		#define STR0004 "Close"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Mensagem Para O Departamento", "Mensagem ao Departamento" )
		#define STR0002 "Mensagem"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Dept.", "Depto" )
		#define STR0004 "Fechar"
	#endif
#endif
