#ifdef SPANISH
	#define STR0001 "Revertir"
	#define STR0002 "Anular"
	#define STR0003 "Anulacion"
	#define STR0004 "Motivo de anulacion"
	#define STR0005 "Motivo:"
	#define STR0006 "Motivo debe rellenarse"
#else
	#ifdef ENGLISH
		#define STR0001 "Reverse"
		#define STR0002 "Cancel"
		#define STR0003 "Cancellation"
		#define STR0004 "Reason for cancellation"
		#define STR0005 "Reason:"
		#define STR0006 "Reason must be entered"
	#else
		#define STR0001 "Estornar"
		#define STR0002 "Cancelar"
		#define STR0003 "Cancelamento"
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Motivo De Cancelamento", "Motivo de Cancelamento" )
		#define STR0005 "Motivo:"
		#define STR0006 "Motivo deve ser prenchido"
	#endif
#endif
