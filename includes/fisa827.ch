#ifdef SPANISH
	#define STR0001 "DIAN"
	#define STR0002 "Responsabilidades"
	#define STR0003 "Tributos"
	#define STR0004 "Nombre"
	#define STR0005 "Nombre del cliente"
	#define STR0006 "Descripción"
	#define STR0007 "Descripción de resp/tributo"
#else
	#ifdef ENGLISH
		#define STR0001 "DIAN"
		#define STR0002 "Responsibilities"
		#define STR0003 "Taxes"
		#define STR0004 "Name"
		#define STR0005 "Customer Name"
		#define STR0006 "Description"
		#define STR0007 "Resp/Tax Description"
	#else
		#define STR0001 "DIAN"
		#define STR0002 "Responsabilidades"
		#define STR0003 "Tributos"
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Nombre", "Nome" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Nombre del cliente", "Nome do Cliente" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Descripción", "Descrição" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Descripción de resp/tributo", "Descrição Resp/Tributo" )
	#endif
#endif
