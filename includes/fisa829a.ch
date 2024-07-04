#ifdef SPANISH
	#define STR0001 "2"
	#define STR0002 "No se pudo crear el Archivo: "
	#define STR0003 "Error: "
	#define STR0004 "No se pudo abrir el archivo: "
	#define STR0005 "Atencion!"
	#define STR0006 "No se pudo cerrar el Archivo: "
	#define STR0007 "Error: "
	#define STR0008 "Atencion!"
	#define STR0009 "Archivo: "
	#define STR0010 " no abierto. No se efectu?el cierre."
#else
	#ifdef ENGLISH
		#define STR0001 "2"
		#define STR0002 "Unable to generate register:"
		#define STR0003 "Error:"
		#define STR0004 "Unable to generate register:"
		#define STR0005 "Attention!"
		#define STR0006 "Unable to generate register:"
		#define STR0007 "Error:"
		#define STR0008 "Attention!"
		#define STR0009 "Register:"
		#define STR0010 "not open. Not closed."
	#else
		#define STR0001 "2"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "No se pudo crear el Archivo: ", "Não foi possível gerar o Cadastro:" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Error: ", "Erro:" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "No se pudo abrir el archivo: ", "Não foi possível gerar o cadastro:" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Atencion!", "Atenção!" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "No se pudo cerrar el Archivo: ", "Não foi possível gerar o Cadastro:" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Error: ", "Erro:" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Atencion!", "Atenção!" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Archivo: ", "Cadastro:" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", " no abierto. No se efectu?el cierre.", "não aberto. No foi efetuado o encerramento." )
	#endif
#endif
