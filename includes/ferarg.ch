#ifdef SPANISH
	#define STR0001 "RECIBO DE VACACIONES"
	#define STR0002 "Periodo: "
	#define STR0003 "Nº Pago: "
	#define STR0004 "| Empleador: "
	#define STR0005 "| Domicilio: "
	#define STR0006 "| CUIT: "
	#define STR0007 "| Fecha. Ult. Dep.: "
	#define STR0008 "Periodo: "
	#define STR0009 "Dep. en Bco: "
	#define STR0010 "| Beneficiario: "
	#define STR0011 " CIC: "
	#define STR0012 "| Fch. Ingreso"
	#define STR0013 "Calif. Prof. "
	#define STR0014 "Tarea Cump. "
	#define STR0015 "| H A B E R E S "
	#define STR0016 "D E D U C C I O N E S"
	#define STR0017 "  B A S E S"
	#define STR0018 "¡CONTINUA!"
	#define STR0019 " TOTAL DE HABERES "
	#define STR0020 "| IMPORTE NETO "
	#define STR0021 "| IMPORTE NETO A COBRAR "
	#define STR0022 "| Anticipo correspondiente al mes de "
	#define STR0023 " de "
	#define STR0024 "| Recibi conforme la suma de pesos "
	#define STR0025 "| por concepto de mis haberes correspondientes al periodo anteriormente indicado y segun la presente liquidacion, dejando "
	#define STR0026 " constancia de haber recibido un duplicado de este recibo. "
	#define STR0027 "| Lugar y Fecha "
	#define STR0028 "| SON $ "
	#define STR0029 "| ORIGINAL "
#else
	#ifdef ENGLISH
		#define STR0001 "VACATION RECEIPT"
		#define STR0002 "Period: "
		#define STR0003 "Paym. No.: "
		#define STR0004 "| Employer: "
		#define STR0005 "| Address: "
		#define STR0006 "| CUIT:"
		#define STR0007 "| Last Dep. Date: "
		#define STR0008 "Period: "
		#define STR0009 "Depos. in Bank: "
		#define STR0010 "| Beneficiary: "
		#define STR0011 "CIC:"
		#define STR0012 "| Admiss. Date"
		#define STR0013 "Prof. Calif."
		#define STR0014 "Mission Accomp. "
		#define STR0015 "| C R E D I T S"
		#define STR0016 "D E B I T S"
		#define STR0017 "B A S E S"
		#define STR0018 "PROCEED!"
		#define STR0019 "TOTAL OF EARNINGS"
		#define STR0020 "| NET AMOUNT"
		#define STR0021 "| NET AMOUNT RECEIVABLE"
		#define STR0022 "| Advance corresponding to the month of"
		#define STR0023 "from"
		#define STR0024 "| Received the following quantity in reals"
		#define STR0025 "| regarding my compensation in aforementioned period, following the current clearance, leaving"
		#define STR0026 "a record that I have received a copy of this receipt."
		#define STR0027 "| Location and Date"
		#define STR0028 "| SON $"
		#define STR0029 "| ORIGINAL"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "RECIBO DE FÉRIAS", "HOLERITE DE FÉRIAS" )
		#define STR0002 "Período: "
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Nr. Pago: ", "Nº Pagamento: " )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "| Empleador: ", "| Empregador: " )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "| Domicílio: ", "| Endereço: " )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "| CUIT: ", "| CNPJ: " )
		#define STR0007 "| Data. Últ. Dep.: "
		#define STR0008 "Período: "
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Dep.: em Bco: ", "Dep. em Bco: " )
		#define STR0010 "| Beneficiário: "
		#define STR0011 If( cPaisLoc $ "ANG|PTG", " |NIF           | ", " CIC: " )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "| Dta. Admiss.", "| Dt. Admiss." )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Calif. Prof. ", "Qualif. Prof. " )
		#define STR0014 "Tarefa Cump. "
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "| H A B E R E S ", "| C R É D I T O S " )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "D E D U C C I O N E S", "D É B I T O S" )
		#define STR0017 "  B A S E S"
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "¡CONTINUA!", "PROSSEGUIR!" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", " TOTAL DE HABERES ", " TOTAL DE PAGAMENTOS " )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "| IMPORTE NETO ", "| VALOR LÍQUIDO " )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "| IMPORTE NETO A COBRAR ", "| VALOR LÍQUIDO A RECEBER " )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "| Anticipo correspondiente al mes de ", "| Adiantamento correspondente ao mês de " )
		#define STR0023 " de "
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "| Recibi conforme la suma de pesos ", "| Recebi a seguinte quantia em reais " )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "| por concepto de mis haberes correspondientes al periodo anteriormente indicado y segun la presente liquidacion, dejando ", "| referente à minha remuneração pelo período mencionado acima, segundo a presente liquidação, deixando" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", " constancia de haber recibido un duplicado de este recibo. ", " constância que recebi uma via desse recibo. " )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "| Lugar y Fecha ", "| Local e Data " )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "| SON $ ", "| SÃO R$ " )
		#define STR0029 "| ORIGINAL "
	#endif
#endif
