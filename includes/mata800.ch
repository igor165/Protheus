#ifdef SPANISH
	#define STR0001 "Ultimacion de OP's"
	#define STR0002 "Parametro"
	#define STR0003 "Confirmar"
	#define STR0004 "Desconfirmar"
	#define STR0005 "¿Ultimar las OPs marcadas?"
	#define STR0006 "Seleccionando registros..."
	#define STR0007 " ¿Reveritr ultimacion de las OPs marcadas?"
	#define STR0008 "Configuración de parámetros"
	#define STR0009 "Parámetro no configurado"
	#define STR0010 "Definir la información de los parámetros MV_PROCPCP, por el configurador"
#else
	#ifdef ENGLISH
		#define STR0001 "Prod.Order Confirmation"
		#define STR0002 "Parameter"
		#define STR0003 "Confirm"
		#define STR0004 "Undo         "
		#define STR0005 " Confirm the marked ones?   "
		#define STR0006 "Selecting Records...     "
		#define STR0007 " Undo the confirmation for marked POs?         "
		#define STR0008 "Parameter configuration"
		#define STR0009 "Parameter not configured"
		#define STR0010 "Set data of parameter MV_PROCPCP through the configurator"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Sacramento de OP´s", "Sacramento de OP's" )
		#define STR0002 "Parâmetro"
		#define STR0003 "Sacramentar"
		#define STR0004 "Dessacramentar"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", " sacramenta as ops marcadas ?", " Sacramenta as OPs marcadas ?" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "A Seleccionar Registos...", "Selecionando Registros..." )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", " dessacramenta as ops marcadas ?", " Dessacramenta as OPs marcadas ?" )
		#define STR0008 "Configuração de Parametros"
		#define STR0009 "Parametro não configurado"
		#define STR0010 "Definir as informações dos parametros MV_PROCPCP, pelo configurador"
	#endif
#endif
