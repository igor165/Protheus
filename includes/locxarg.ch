#ifdef SPANISH
	#define STR0001 "OK"
	#define STR0002 "¡ATENCIÓN!"
	#define STR0003 "Fecha de vigencia vencida"
	#define STR0004 "Debe informar la fecha de vigencia en la tabla de clientes"
	#define STR0005 "Se deben informar todos los campos relacionados a la RG 3668/14"
#else
	#ifdef ENGLISH
		#define STR0001 "OK"
		#define STR0002 "ATTENTION!"
		#define STR0003 "Validity date expired"
		#define STR0004 "Enter the validity date on the customers table."
		#define STR0005 "Enter all fields related to RG 3668/14"
	#else
		#define STR0001 "OK"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "¡ATENCIÓN!", "ATENÇÃO!" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Fecha de vigencia vencida", "Data de vigência vencida" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Debe informar la fecha de vigencia en la tabla de clientes", "Deve informar a data de vigência na tabela de clientes" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Se deben informar todos los campos relacionados a la RG 3668/14", "Devem ser informados todos os campos relacionados com a RG 3668/14" )
	#endif
#endif
