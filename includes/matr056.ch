#ifdef SPANISH
	#define STR0001 "Generando informe, espere..."
	#define STR0002 "Fecha: "
	#define STR0003 "        Solicitamos a los señores <EMPRESA>, emitir Nota de Crédito con valor de <VALOR> debido a <MOTIVO>."
	#define STR0004 "Factura de Referencia "
	#define STR0005 " Serie "
	#define STR0006 "Atentamente"
	#define STR0007 "Dpto. de Compras"
	#define STR0008 "Solicitud numero: "
#else
	#ifdef ENGLISH
		#define STR0001 "Generating report. Please, wait..."
		#define STR0002 "Date: "
		#define STR0003 "We ask you, <COMPANY>, to issue a Credit Note in the amount of <AMOUNT> adjusted to <MOTIVE>."
		#define STR0004 "Reference Invoice "
		#define STR0005 " Series "
		#define STR0006 "Regards"
		#define STR0007 "Purchases Department"
		#define STR0008 "Requisition number: "
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "A criar relatório, aguarde...", "Gerando relatorio, aguarde..." )
		#define STR0002 "Data: "
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "        Solicitamos a los señores <EMPRESA>, emitir Nota de Crédito con valor de <VALOR> debido a <MOTIVO>.", "Solicitamos aos senhores <EMPRESA>, emitir Nota de Crédito com o valor de <VALOR> adeudado para <MOTIVO>." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Factura de referência ", "Nota Fiscal de Referencia " )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", " série ", " Serie " )
		#define STR0006 "Sem mais"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Depto De Compras", "Depto de Compras" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Solicitação número: ", "Solicitacao numero: " )
	#endif
#endif
