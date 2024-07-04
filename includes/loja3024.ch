#ifdef SPANISH
	#define STR0001 "Define la prioridad de regla de Descuento"
	#define STR0002 "Para utilizar una nueva regla de descuento verifique MV_LJRGDES y Update"
	#define STR0003 "Modificar prioridad regla descuento"
	#define STR0004 "De prioridad:"
	#define STR0005 "Prioridad digitada no válida."
	#define STR0006 "A prioridad:"
#else
	#ifdef ENGLISH
		#define STR0001 "Define the Discount rule priority"
		#define STR0002 "To use new discount rule, check MV_LJRGDES and Update"
		#define STR0003 "Edit Discount Rule Priority"
		#define STR0004 "Of Priority"
		#define STR0005 "Typed priority not valid!!!"
		#define STR0006 "For Priority:"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Define a prioridade da regra de desconto", "Define a prioridade da regra de Desconto" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Para utilizar nova regra de desconto, verificar MV_LJRGDES e Update", "Para utilizar nova regra de desconto verificar MV_LJRGDES e Update" )
		#define STR0003 "Altera Prioridade Regra Desconto"
		#define STR0004 "Da Prioridade: "
		#define STR0005 "Prioridade digitada invalida!!!"
		#define STR0006 "Para Prioridade: "
	#endif
#endif
