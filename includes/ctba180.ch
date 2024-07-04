#ifdef SPANISH
	#define STR0001 "Archivos de costos"
	#define STR0002 "Opción disponible solamente para el módulo Contabilidad de gestión"
	#define STR0003 "Costos(CTBA180) descontinuado a partir de la versión 12.1.17."
	#define STR0004 "Sustituir el fuente CTBA180 del menú por:"
	#define STR0005 "Centro de costo(CTBA030 - CTT),"
	#define STR0006 "Ítem contable(CTBA040 - CTD),"
	#define STR0007 "Clase de valor(CTBA060 - CTH)."
#else
	#ifdef ENGLISH
		#define STR0001 "Costs File"
		#define STR0002 "Option available only for module Management Accounting"
		#define STR0003 "Costs (CTBA180) discontinued from version 12.1.17 on."
		#define STR0004 "Replace CTBA180 source of menu with:"
		#define STR0005 "Cost Center (CTBA030 - CTT),"
		#define STR0006 "Accounting Item (CTBA040 - CTD),"
		#define STR0007 "Value Class (CTBA060 - CTH)."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Registos De Custos", "Cadastros de Custos" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Opção Disponível Somente Para O Módulo De Contabilidade De Gestão", "Opcao disponivel somente para o modulo Contabilidade Gerencial" )
		#define STR0003 "Custos(CTBA180) descontinuado a partir da versão 12.1.17."
		#define STR0004 "Substituir o fonte CTBA180 do menu por: "
		#define STR0005 "Centro de Custo(CTBA030 - CTT), "
		#define STR0006 "Item Contábil(CTBA040 - CTD), "
		#define STR0007 "Classe Valor(CTBA060 - CTH)."
	#endif
#endif
