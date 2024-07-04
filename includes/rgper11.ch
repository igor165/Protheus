#ifdef SPANISH
	#define STR0001 "RECIBO DE DESCARGO"
	#define STR0002 "A rayas"
	#define STR0003 "Administración"
	#define STR0004 "Recibo de descargo por concepto de pago total"
	#define STR0005 "de bonificación"
	#define STR0006 "de Regalía"
	#define STR0007 "El suscrito: "
	#define STR0008 ", mayor de edad, de ocupación"
	#define STR0009 ", cédula de identificación personal Nº"
	#define STR0010 "por medio del presente documento otorgo formal recibo de descargo y finiquito por la"
	#define STR0011 "suma de "
	#define STR0012 "en favor de mi empleador"
	#define STR0013 "por concepto de pago total de mi "
	#define STR0014 "Bonificación "
	#define STR0015 "Regalía "
	#define STR0016 "correspondiente al año "
#else
	#ifdef ENGLISH
		#define STR0001 "SETTLEMENT RECEIPT"
		#define STR0002 "Z.Form "
		#define STR0003 "Management   "
		#define STR0004 "Settlement Receipt as total payment"
		#define STR0005 "of Bonus"
		#define STR0006 "of Year-end bonus"
		#define STR0007 "The subscriber: "
		#define STR0008 ", of age, occupation"
		#define STR0009 ", SSN number"
		#define STR0010 "by the present document, I give a formal receipt of settlement by"
		#define STR0011 "the value of "
		#define STR0012 "in the name of my employer"
		#define STR0013 "as the total payment of my "
		#define STR0014 "Bonus "
		#define STR0015 "Year-end bonus "
		#define STR0016 "corresponding to the year "
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Recibo De Descarga", "RECIBO DE LIQUIDAÇÃO" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
		#define STR0003 "Administração"
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Recibo de despromoção por conceito de pagamento total", "Recibo de Liquidação a título de pagamento total" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "De Bonificação", "de Bonificação" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "De Regalia", "de 13º salário" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "O subscrito: ", "O assinante: " )
		#define STR0008 ", maior de idade, de ocupação"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", ", Bilhete De Identidade  Pessoal No.", ", documento de identidade pessoal Nº" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Por média  do presente  documento outorga  formal recibo de despromoção  e demissão pela", "pelo presente documento outorgo formal recibo de liquidação pelo" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Soma de ", "valor de " )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "A favor do meu empregador", "em nome do meu empregador" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Por conceito de pagamento total do meu ", "a título de pagamento total da minha " )
		#define STR0014 "Bonificação "
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Regalia ", "13º salário " )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Correspondente no ano ", "correspondente ao ano " )
	#endif
#endif
