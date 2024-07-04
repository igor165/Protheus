#ifdef SPANISH
	#define STR0001 "Matrícula"
	#define STR0002 "C Costo"
	#define STR0003 "Nombre"
	#define STR0004 "A C H S"
	#define STR0005 "Asociación chilena de seguridad"
	#define STR0006 "Emisión de la planilla de declaración y pago de cotizaciones."
	#define STR0007 "Se imprimirá de acuerdo con los parámetros solicitados por"
	#define STR0008 "el usuario."
	#define STR0009 "A Rayas"
	#define STR0010 "Administración"
	#define STR0011 "EMISIÓN DE DECLARACIÓN DE SEGURIDAD"
	#define STR0012 "A S O C I A C I Ó N  C H I L E N A  D E  S E G U R I D A D"
	#define STR0013 "DECLARACIÓN Y PAGO DE COTIZACIONES"
	#define STR0014 "En el "
	#define STR0015 "Mes de "
	#define STR0016 "PÁGINA: "
	#define STR0017 "DECLARACIÓN Y PAGO SIMULTÁNEO"
#else
	#ifdef ENGLISH
		#define STR0001 "Registration"
		#define STR0002 "Cost Center"
		#define STR0003 "Name"
		#define STR0004 "A C H S"
		#define STR0005 "Chilean Safety Association"
		#define STR0006 "Issue of statement spreadsheet and quotization payments."
		#define STR0007 "It will be printed in accordance with the parameters requested "
		#define STR0008 "by the user."
		#define STR0009 "Z-form"
		#define STR0010 "Administration"
		#define STR0011 "ISSUE OF SAFETY STATEMENT"
		#define STR0012 "A S S O C I A T I O N   O F  S E C U R I T Y  O F  C H I L E"
		#define STR0013 "STATEMENT OF PAYMENT OF QUOTIZATIONS"
		#define STR0014 "In the "
		#define STR0015 "Month "
		#define STR0016 "PAGE: "
		#define STR0017 "STATEMENT OF SIMULTANEOUS PAYMENT"
	#else
		#define STR0001 "Matrícula"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "C.custo", "C.Custo" )
		#define STR0003 "Nome"
		#define STR0004 "A C H S"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Associação chilena de segurança", "Associação de Segurança do Chile" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Emissão da folha de cálculo de declaração e pagamento de quotizações.", "Emissão da planiha de declaração e pagamento de cotizações." )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Será impresso de acordo com os parâmetros requeridos por", "Será impresso de acordo com os parâmetros solicitados " )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "El utilizador.", "pelo usuário." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "A Rayas", "Zebrado" )
		#define STR0010 "Administração"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Emissão De Declaração De Segurança", "EMISSÃO DE DECLARAÇÃO DE SEGURANÇA" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Associação Chilena De Segurança", "A S S O C I A Ç Ã O  D E  S E G U R A N Ç A  D O  C H I L E" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Declaração E Pagamento De Quotizações", "DECLARAÇÃO E PAGAMENTO DE COTIZAÇÕES" )
		#define STR0014 "No "
		#define STR0015 "Mês de "
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Pagina: ", "PÁGINA: " )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Declaração E Pagamento Simultâneo", "DECLARAÇÃO E PAGAMENTO SIMULTÂNEO" )
	#endif
#endif
