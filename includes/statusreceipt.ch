#ifdef SPANISH
	#define STR0001 "Disponible"
	#define STR0002 "Indisponible"
	#define STR0003 "Tiene cheque de billetera"
	#define STR0004 "Cancelacion pendiente"
	#define STR0005 "Timbrado"
	#define STR0006 "Cancelado"
	#define STR0007 "Version inactiva"
	#define STR0008 "Version activa"
#else
	#ifdef ENGLISH
		#define STR0001 "Available"
		#define STR0002 "Unavailable"
		#define STR0003 "Has portfolio check"
		#define STR0004 "Cancelacion pendiente"
		#define STR0005 "With letterhead"
		#define STR0006 "Cancelado"
		#define STR0007 "Version inactiva"
		#define STR0008 "Version activa"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Disponible", "Disponível" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Indisponible", "Indisponível" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Tiene cheque de billetera", "Tem cheque de carteira" )
		#define STR0004 "Cancelacion pendiente"
		#define STR0005 "Timbrado"
		#define STR0006 "Cancelado"
		#define STR0007 "Version inactiva"
		#define STR0008 "Version activa"
	#endif
#endif
