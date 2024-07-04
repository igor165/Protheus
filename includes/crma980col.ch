#ifdef SPANISH
	#define STR0001 "Se debe indicar el campo NIT del Cliente"
	#define STR0002 "El campo DI/Ced. Ext. debe estar vacío."
	#define STR0003 "El campo NIT del cliente debe estar vacío."
	#define STR0004 "Se debe indicar el campo DI/Ced Ext."
	#define STR0005 "Resp. Obligaciones DIAN"
	#define STR0006 "Tributos DIAN"
#else
	#ifdef ENGLISH
		#define STR0001 "Indicate field NIT of Customer"
		#define STR0002 "Field ID/Ext Ced must be empty."
		#define STR0003 "Field NIT of Customer must be blank."
		#define STR0004 "Indicate field if/ext ced."
		#define STR0005 "Resp. DIAN Requirements"
		#define STR0006 "DIAN Taxes"
	#else
		#define STR0001 "Deve ser indicado o campo NIT do Cliente"
		#define STR0002 "O campo RG/Ced. Ext. deve estar vazio."
		#define STR0003 "O campo NIT do Cliente deve estar vazio."
		#define STR0004 "Deve ser indicado o campo RG/Ced Ext."
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Resp. Obligaciones DIAN", "Resp. Obrigações DIAN" )
		#define STR0006 "Tributos DIAN"
	#endif
#endif
