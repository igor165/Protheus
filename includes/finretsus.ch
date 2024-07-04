#ifdef SPANISH
	#define STR0001 "Atención"
	#define STR0002 "Ok"
	#define STR0003 "El proveedor "
	#define STR0004 " no cuenta con la configuración necesaria para calcular la retención de SUSS a partir del documento origen. Indique concepto y/o tipo cálculo correspondiente a valor informado."
#else
	#ifdef ENGLISH
		#define STR0001 "Attention"
		#define STR0002 "Ok"
		#define STR0003 "The supplier"
		#define STR0004 "does not have the setting required to calculate the SUSS withholding from the source document. Indicate item and/or type of calculation corresponding to the value entered."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0002 "Ok"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "El proveedor ", "O fornecedor" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", " no cuenta con la configuración necesaria para calcular la retención de SUSS a partir del documento origen. Indique concepto y/o tipo cálculo correspondiente a valor informado.", "não conta com a configuração necessária para calcular a retenção de SUSS a partir do documento origem. Indique a verba e/ou tipo de cálculo correspondente ao valor informado." )
	#endif
#endif
