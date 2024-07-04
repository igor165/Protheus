#ifdef SPANISH
	#define STR0001 "LIQUIDACION FINAL"
	#define STR0002 "Empresa "
	#define STR0003 "Sucursal "
	#define STR0004 "RUC "
	#define STR0005 "Antigüedad  "
	#define STR0006 "Tipo ID y Num ID "
	#define STR0007 "Salario Mensual en Gs."
	#define STR0008 "Salario por día en Gs."
	#define STR0009 "SBC Indemnización"
	#define STR0010 "SBC Aviso Previo"
	#define STR0011 "SBC Vacaciones"
	#define STR0012 "SBC Aguinaldo"
	#define STR0013 "HABERES"
	#define STR0014 "DESCUENTOS "
	#define STR0015 "CARTA FINIQUITO PARAGUAY"
	#define STR0016 "TOTAL DESCUENTOS: "
	#define STR0017 "Representante Legal"
	#define STR0018 "Empleado"
	#define STR0019 "Recibí de "
	#define STR0020 " con RUC "
	#define STR0021 " el importe de Gs "
	#define STR0022 "en concepto de Liquidación final de haberes laborales correspondientes, conforme a detalle mostrado."
	#define STR0023 "TOTAL A PAGAR"
	#define STR0024 "en concepto de "
	#define STR0025 " AÑOS "
	#define STR0026 " MESES "
	#define STR0027 " DIAS  "
	#define STR0028 " Continua ... "
#else
	#ifdef ENGLISH
		#define STR0001 "FINAL SETTLEMENT"
		#define STR0002 "Company"
		#define STR0003 "Branch"
		#define STR0004 "RUC"
		#define STR0005 "Time of Serv"
		#define STR0006 "ID Type and ID No."
		#define STR0007 "Monthly Wage in Gs."
		#define STR0008 "Daily Wage in Gs."
		#define STR0009 "Indemnity SBC"
		#define STR0010 "Prior Notice SBC"
		#define STR0011 "Vacations SBC"
		#define STR0012 "Bonus Salary SBC"
		#define STR0013 "PAYMENTS"
		#define STR0014 "DISCOUNTS"
		#define STR0015 "PARAGUAY DISCHARGE LETTER"
		#define STR0016 "TOTAL DISCOUNTS:"
		#define STR0017 "Legal Representative"
		#define STR0018 "Employee"
		#define STR0019 "I received from"
		#define STR0020 "with RUC"
		#define STR0021 "the amount of Gs"
		#define STR0022 "referring to the final pay settlement for services performed according to the detail presented."
		#define STR0023 "TOTAL PAYABLE:"
		#define STR0024 "for"
		#define STR0025 "YEARS"
		#define STR0026 "MONTHS"
		#define STR0027 "DAYS"
		#define STR0028 "Continue..."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "LIQUIDACION FINAL", "LIQUIDAÇÃO FINAL" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Empresa ", "Empresa" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Sucursal ", "Filial" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "RUC ", "RUC" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Antigüedad  ", "Tempo de Serv" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Tipo ID y Num ID ", "Tipo ID e Núm ID" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Salario Mensual en Gs.", "Salário Mensal em Gs." )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Salario por día en Gs.", "Salário por dia em Gs." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "SBC Indemnización", "SBC Indenização" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "SBC Aviso Previo", "SBC Aviso Prévio" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "SBC Vacaciones", "SBC Férias" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "SBC Aguinaldo", "SBC 13º Salário" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "HABERES", "PAGAMENTOS" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "DESCUENTOS ", "DESCONTOS" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "CARTA FINIQUITO PARAGUAY", "CARTA QUITAÇÃO PARAGUAI" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "TOTAL DESCUENTOS: ", "TOTAL DESCONTOS:" )
		#define STR0017 "Representante Legal"
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Empleado", "Funcionário" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Recibí de ", "Recebi de" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", " con RUC ", "com RUC" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", " el importe de Gs ", "o valor de Gs" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "en concepto de Liquidación final de haberes laborales correspondientes, conforme a detalle mostrado.", "referente à Liquidação final de pagamentos por serviços prestados, segundo detalhe apresentado." )
		#define STR0023 "TOTAL A PAGAR"
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "en concepto de ", "por " )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", " AÑOS ", "ANOS" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", " MESES ", "MESES" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", " DIAS  ", "DIAS" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", " Continua ... ", "Prosseguir..." )
	#endif
#endif
