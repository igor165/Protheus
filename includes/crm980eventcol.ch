#ifdef SPANISH
	#define STR0001 "Debe indicarse el campo NIT del cliente."
	#define STR0002 "El campo DI/Céd. Ext. debe estar vacío."
	#define STR0003 "El campo NIT del cliente debe estar vacío."
	#define STR0004 "Debe indicarse el campo DI/Céd Ext."
	#define STR0005 "Hubo cambios en el NIT o la Cédula Extranjera, sin embargo, existen movimientos contables asociados (tablas CT2, CVX o CVY) a esos ID."
	#define STR0006 "Debe retornar los valores de dichos campos para continuar."
#else
	#ifdef ENGLISH
		#define STR0001 "Indicate field Customer NIT"
		#define STR0002 "Field ID/ext ced must be empty."
		#define STR0003 "Field Customer NIT must be empty."
		#define STR0004 "Indicate field ID/ext ced"
		#define STR0005 "There were changes to the NIT or RNE (Foreigners National Registration), but there are related accounting transfers (tables CT2, CVX or CVY) with these IDs."
		#define STR0006 "Return these fields' values to continue."
	#else
		#define STR0001 "Deve ser indicado o campo NIT do Cliente."
		#define STR0002 "O campo RG/Ced. Ext. deve estar vazio."
		#define STR0003 "O campo NIT do Cliente deve estar vazio."
		#define STR0004 "Deve ser indicado o campo RG/Ced Ext."
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Hubo cambios en el NIT o la Cédula Extranjera, sin embargo, existen movimientos contables asociados (tablas CT2, CVX o CVY) a esos ID.", "Aconteceram alterações no NIT ou no RNE (Reg. Nac. de Estrangeiros), porém, existem movimentos contábeis relacionados (tabelas CT2, CVX ou CVY) com esses ID." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Debe retornar los valores de dichos campos para continuar.", "Deve retornar os valores de tais campos para prosseguir." )
	#endif
#endif
