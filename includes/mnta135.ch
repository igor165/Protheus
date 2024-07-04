#ifdef SPANISH
	#define STR0001 "¿De Familia Estandar?"
	#define STR0002 "¿A  Familia Estandar?"
	#define STR0003 "Genera mantenimiento preventivo a partir del estandar"
	#define STR0004 "De Tipo Modelo"
	#define STR0005 "A Tipo Modelo"
	#define STR0006 "Total de mantenimientos generados:"
	#define STR0007 "Inconsistencias:"
	#define STR0008 "Bien:"
	#define STR0009 "Servicio:"
	#define STR0010 "Secuencia"
	#define STR0011 "Campo calendario del mantenimiento estándar no está cumplimentado."
	#define STR0012 "No se generó ningún mantenimiento, verifique los parámetros."
#else
	#ifdef ENGLISH
		#define STR0001 "From Standard Family?"
		#define STR0002 "To Standard Family  ?"
		#define STR0003 "Generates Preventive Maintenance from the Standard"
		#define STR0004 "Model Type from"
		#define STR0005 "Model Type to"
		#define STR0006 "Total of maintenances generated:"
		#define STR0007 "Inconsistencies:"
		#define STR0008 "Asset:"
		#define STR0009 "Service:"
		#define STR0010 "Sequence"
		#define STR0011 "Calendar field of standard Maintenance is not completed."
		#define STR0012 "No maintenance generated. Check parameters."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "De familia padrão ?", "De Familia Padrao ?" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Até família padrão ?", "Ate Familia Padrao ?" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Cria Manutenção Preventiva Apartir Do Padrão", "Gera Manutencao Preventiva apartir do Padrao" )
		#define STR0004 "De Tipo Modelo"
		#define STR0005 "Até Tipo Modelo"
		#define STR0006 "Total de manutenções geradas:"
		#define STR0007 "Inconsistências:"
		#define STR0008 "Bem:"
		#define STR0009 "Serviço:"
		#define STR0010 "Sequência"
		#define STR0011 "Campo calendário da manutenção padrão não está preenchido."
		#define STR0012 "Nenhuma manutenção gerada, verifique os parâmetros."
	#endif
#endif
