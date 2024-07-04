#ifdef SPANISH
	#define STR0001 "Reporte IR-3"
	#define STR0002 "Encabezado"
	#define STR0003 "Datos Empleador"
	#define STR0004 "No. Periodo"
	#define STR0005 "RNC"
	#define STR0006 "Razón Social"
	#define STR0007 "No. Periodo"
	#define STR0008 "Detalle"
	#define STR0009 "DIRECCIÓN GENERAL DE IMPUESTOS INTERNOS"
	#define STR0010 "DECLARACIÓN Y/O PAGO DE RETENCIONES DE ASALARIADOS"
	#define STR0011 "(Valores en RD$)"
	#define STR0012 "B. ASALARIADOS"
	#define STR0013 "TOTAL"
	#define STR0014 "1.- Total asalariados"
	#define STR0015 "2.- Asalariados sujetos a Retención"
	#define STR0016 "3.- Sueldos Pagados por el Agente"
	#define STR0017 "4.- Otras Remuneraciones"
	#define STR0018 "5.- Remuneraciones de Otros Agentes"
	#define STR0019 "6.- Total Pagado (Sumar casillas 3 + 4 + 5)"
	#define STR0020 "7.- Pago Total Sujeto a Retención"
	#define STR0021 "8.- Impuesto sobre la Renta"
	#define STR0022 "9.- Saldo Compensado Autorizado"
	#define STR0023 "10.- Saldo por Compensar"
	#define STR0024 "C. LIQUIDACIÓN"
	#define STR0025 "11.- Impuesto a Pagar (Si el valor de la casilla 8 - 9 es positivo"
	#define STR0026 "12.- Crédito Autorizado"
	#define STR0027 "13.- Crédito Gastos Educativos IR-18"
	#define STR0028 "14.- Pagos Computables a Cuenta"
	#define STR0029 "15.- Saldo a Favor Anterior"
	#define STR0030 "16.- Diferencia a Pagar (Si el valor de casilla 11 - 12 - 13 - 14 - 15 es positivo)"
	#define STR0031 "17.- Saldos a Favor (Si el valor de casilla 11 - 12 - 13 - 14 - 15 es negativo)"
	#define STR0032 "D. PENALIDADES"
	#define STR0033 "18.- Recargos"
	#define STR0034 "19.- Interes Indemnizatorio"
	#define STR0035 "E. MONTO A PAGAR"
	#define STR0036 "20.- Total a Pagar (Sumar casillas 16 + 18 + 19)"
#else
	#ifdef ENGLISH
		#define STR0001 "Report IR-3"
		#define STR0002 "Header"
		#define STR0003 "Employer Data"
		#define STR0004 "Period Number"
		#define STR0005 "RNC"
		#define STR0006 "Corporate Name"
		#define STR0007 "Period Number"
		#define STR0008 "Detail"
		#define STR0009 "INTERNAL TAXES GENERAL BOARD"
		#define STR0010 "STATEMENT AND/OR SALARIED WORKERS BENEFICIARIES PAYMENT"
		#define STR0011 "(Amount in RD$)"
		#define STR0012 "B. SALARIED WORKERS BENEFICIARIES"
		#define STR0013 "TOTAL"
		#define STR0014 "1.- Total salaried workers beneficiaries"
		#define STR0015 "2.- Salaried workers subject to Withholding"
		#define STR0016 "3.- Salary Paid by Agent"
		#define STR0017 "4 - Other Compensations"
		#define STR0018 "5.- Compensations of Other Agents"
		#define STR0019 "6.- Total Paid (Add places 3 + 4 + 5)"
		#define STR0020 "7.- Total Payment Subject to Withholding"
		#define STR0021 "8.- Tax on Income"
		#define STR0022 "9.- Authorized Compensated Balance"
		#define STR0023 "10.- Balance to Compensate"
		#define STR0024 "C. SETTLEMENT"
		#define STR0025 "11.- Tax to Pay (If value of place 8 - 9 is positive"
		#define STR0026 "12.- Authorized Credit"
		#define STR0027 "13.- Education Expenses Credit IR-18"
		#define STR0028 "14.- Payments Counted in the Accounted"
		#define STR0029 "15.- Previous Positive Balance"
		#define STR0030 "16.- Difference to Pay (If value of place 11 - 12 - 13 - 14 - 15 is positive)"
		#define STR0031 "17.- Positive Balances (If value of place 11 - 12 - 13 - 14 - 15 is negative)"
		#define STR0032 "D. PENALTIES"
		#define STR0033 "18- Sanctions"
		#define STR0034 "19.- Compensatory Interests"
		#define STR0035 "E. VALUE TO PAY"
		#define STR0036 "20.- Total to Pay (Add places 16 + 18 + 19)"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Reporte IR-3", "Relatório IR-3" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Encabezado", "Cabeçalho" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Datos Empleador", "Dados Empregador" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "No. Periodo", "Nº Período" )
		#define STR0005 "RNC"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Razón Social", "Razão Social" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "No. Periodo", "Nº Período" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Detalle", "Detalhe" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "DIRECCIÓN GENERAL DE IMPUESTOS INTERNOS", "DIREÇÃO GERAL DE IMPOSTOS INTERNOS" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "DECLARACIÓN Y/O PAGO DE RETENCIONES DE ASALARIADOS", "DECLARAÇAO E/OU PAGAMENTO DE RETENÇÕES DE ASSALARIADOS" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "(Valores en RD$)", "(Valores em RD$)" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "B. ASALARIADOS", "B. ASSALARIADOS" )
		#define STR0013 "TOTAL"
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "1.- Total asalariados", "1.- Total assalariados" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "2.- Asalariados sujetos a Retención", "2.- Assalariados sujeitos à Retenção" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "3.- Sueldos Pagados por el Agente", "3.- Salários Pagos pelo Agente" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "4.- Otras Remuneraciones", "4.- Outras Remunerações" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "5.- Remuneraciones de Otros Agentes", "5.- Remunerações de Outros Agentes" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "6.- Total Pagado (Sumar casillas 3 + 4 + 5)", "6.- Total Pago (Somar casas 3 + 4 + 5)" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "7.- Pago Total Sujeto a Retención", "7.- Pagamento Total Sujeito a Retenção" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "8.- Impuesto sobre la Renta", "8.- Imposto sobre a Renda" )
		#define STR0022 "9.- Saldo Compensado Autorizado"
		#define STR0023 "10.- Saldo por Compensar"
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "C. LIQUIDACIÓN", "C. LIQUIDAÇÃO" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "11.- Impuesto a Pagar (Si el valor de la casilla 8 - 9 es positivo", "11.- Imposto por Pagar (Se o valor da casa 8 - 9 é positivo" )
		#define STR0026 "12.- Crédito Autorizado"
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "13.- Crédito Gastos Educativos IR-18", "13.- Crédito Despesas Educativas IR-18" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "14.- Pagos Computables a Cuenta", "14.- Pagamentos Computáveis na Conta" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "15.- Saldo a Favor Anterior", "15.- Saldo Positivo Anterior" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "16.- Diferencia a Pagar (Si el valor de casilla 11 - 12 - 13 - 14 - 15 es positivo)", "16.- Diferença a Pagar (Se o valor da casa 11 - 12 - 13 - 14 - 15 é positivo)" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "17.- Saldos a Favor (Si el valor de casilla 11 - 12 - 13 - 14 - 15 es negativo)", "17.- Saldos Positivos (Se o valor da casa 11 - 12 - 13 - 14 - 15 é negativo)" )
		#define STR0032 "D. PENALIDADES"
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "18.- Recargos", "18.- Sanções" )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "19.- Interes Indemnizatorio", "19.- Juros Indenizatórios" )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "E. MONTO A PAGAR", "E. VALOR A PAGAR" )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "20.- Total a Pagar (Sumar casillas 16 + 18 + 19)", "20.- Total a Pagar (Somar casas 16 + 18 + 19)" )
	#endif
#endif
