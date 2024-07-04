#ifdef SPANISH
	#define STR0001 " Caracteres "
	#define STR0002 " Tamaño "
	#define STR0003 " El campo "
	#define STR0004 "Cuenta Ordenante"
	#define STR0005 "Cuenta Beneficiario"
	#define STR0006 " a "
	#define STR0007 " no cumple con el patrón requerido. "
	#define STR0008 " contiene caracteres no permitidos: "
	#define STR0009 " supera la longitud máxima permitida."
	#define STR0010 "La hora indicada "
	#define STR0011 " no es válida."
#else
	#ifdef ENGLISH
		#define STR0001 "Characters"
		#define STR0002 "Size"
		#define STR0003 "Field"
		#define STR0004 "Ordering Account"
		#define STR0005 "Beneficiary Account"
		#define STR0006 "to"
		#define STR0007 "does not meet the required standard."
		#define STR0008 "has forbidden characters:"
		#define STR0009 "exceeds the maximum length."
		#define STR0010 "The time entered"
		#define STR0011 "is invalid."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", " Caracteres ", "Caracteres" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", " Tamaño ", "Tamanho" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", " El campo ", "O campo" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Cuenta Ordenante", "Conta Ordenante" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Cuenta Beneficiario", "Conta Beneficiária" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", " a ", "até" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", " no cumple con el patrón requerido. ", "não cumple com o padrão requerido." )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", " contiene caracteres no permitidos: ", "contém caracteres não permitidos:" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", " supera la longitud máxima permitida.", "supera o comprimento máximo permitido." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "La hora indicada ", "A hora indicada" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", " no es válida.", "é inválida." )
	#endif
#endif
