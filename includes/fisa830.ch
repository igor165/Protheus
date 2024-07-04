#ifdef SPANISH
	#define STR0001 "Certificados"
	#define STR0002 "Leyenda"
	#define STR0003 "Pendiente"
	#define STR0004 "Certificada"
	#define STR0005 "Anulada"
	#define STR0006 "Liquidado parcialmente"
	#define STR0007 "Liquidado total"
#else
	#ifdef ENGLISH
		#define STR0001 "Certificates"
		#define STR0002 "Caption"
		#define STR0003 "Pending"
		#define STR0004 "Canceled"
		#define STR0005 "Canceled"
		#define STR0006 "Partially settled"
		#define STR0007 "Total Settled"
	#else
		#define STR0001 "Certificados"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Leyenda", "Legenda" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Pendiente", "Pendente" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Certificada", "Cancelada" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Anulada", "Cancelada" )
		#define STR0006 "Liquidado parcialmente"
		#define STR0007 "Liquidado total"
	#endif
#endif
