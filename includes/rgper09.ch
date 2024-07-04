#ifdef SPANISH
	#define STR0001 "Corp. Avíc. y Gan, Jarabacoa, C.por A."
	#define STR0002 "Relación de Prestaciones Laborales y Regalías"
	#define STR0003 "Al "
	#define STR0004 " de "
	#define STR0005 "NÚM."
	#define STR0006 "EMPLEADOS"
	#define STR0007 "CARGO"
	#define STR0008 "INGRESO"
	#define STR0009 "MES"
	#define STR0010 "TOTAL GANADO"
	#define STR0011 "SUELDO PROMEDIO"
	#define STR0012 "REGALÍA"
	#define STR0013 "SUBTOTAL............: "
	#define STR0014 "TOTAL................: "
	#define STR0015 " del "
	#define STR0016 "Página: "
	#define STR0017 "SALARIO"
#else
	#ifdef ENGLISH
		#define STR0001 "Corp. Avíc. y Gan, Jarabacoa, C.por A."
		#define STR0002 "Report of Compensations and Year-End Bonus"
		#define STR0003 "Al "
		#define STR0004 " From "
		#define STR0005 "NUMBER"
		#define STR0006 "EMPLOYEES"
		#define STR0007 "POSITION"
		#define STR0008 "REMUNERATION"
		#define STR0009 "MONTH"
		#define STR0010 "TOTAL RECEIVED"
		#define STR0011 "AVERAGE SALARY"
		#define STR0012 "YEAR-END BONUS"
		#define STR0013 "SUBTOTAL............: "
		#define STR0014 "TOTAL................: "
		#define STR0015 " from "
		#define STR0016 "Page: "
		#define STR0017 "SALARY"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Corp. Avid. Y Gan, Jarabacoa, C.por A.", "Corp. Avíc. y Gan, Jarabacoa, C.por A." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Relacão De Prestações Laborais E Regalias", "Relatório de Remunerações e 13º salário" )
		#define STR0003 "Al "
		#define STR0004 " de "
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Núm.", "NÚM." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Empregados", "FUNCIONÁRIOS" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Cargo", "CARGO" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Ingresso", "REMUNERAÇÃO" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Mês", "MÊS" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Total Ganho", "TOTAL RECEBIDO" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Metade Do Salário", "SALÁRIO MÉDIO" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Regalias", "13º SALÁRIO" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Sub-total............: ", "SUBTOTAL............: " )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Total................: ", "TOTAL................: " )
		#define STR0015 " do "
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Pagina: ", "Página: " )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Salário", "SALÁRIO" )
	#endif
#endif
