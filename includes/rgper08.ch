#ifdef SPANISH
	#define STR0001 "Corp. Avíc. y Gan, Jarabacoa, C.por A."
	#define STR0002 "Relación de Prestaciones Laborales y Regalías"
	#define STR0003 "Al "
	#define STR0004 " de "
	#define STR0005 "INGRESOS "
	#define STR0006 "DECUENTOS"
	#define STR0007 "NÚM."
	#define STR0008 "EMPLEADOS"
	#define STR0009 "CARGO"
	#define STR0010 "SUE.PROM."
	#define STR0011 "DÍAS"
	#define STR0012 "CESANTÍA"
	#define STR0013 "REGALÍA"
	#define STR0014 "VACACIÓN"
	#define STR0015 "TOT.GAN."
	#define STR0016 "$OTROS"
	#define STR0017 "TOTAL"
	#define STR0018 "DESCUENTOS"
	#define STR0019 "SUE.DIA"
	#define STR0020 "TOTAL"
	#define STR0021 "NETO"
	#define STR0027 "CENTRO DE COSTO: "
	#define STR0028 "SUBTOTAL.............: "
	#define STR0029 "TOTAL................: "
	#define STR0030 " de "
	#define STR0031 "Página: "
	#define STR0032 "INGRESO"
	#define STR0033 "MES"
#else
	#ifdef ENGLISH
		#define STR0001 "Corp. Avíc. y Gan, Jarabacoa, C.por A."
		#define STR0002 "Report of Compensations and Year-End Bonus"
		#define STR0003 "Al "
		#define STR0004 " From "
		#define STR0005 "COMPENSATIONS "
		#define STR0006 "DISCOUNTS "
		#define STR0007 "NUMBER"
		#define STR0008 "EMPLOYEES"
		#define STR0009 "POSITION"
		#define STR0010 "AVER.SAL."
		#define STR0011 "DAYS"
		#define STR0012 "Severance Pay"
		#define STR0013 "YEAR-END BONUS"
		#define STR0014 "VACATION"
		#define STR0015 "COMP.TOTAL"
		#define STR0016 "$OTHERS"
		#define STR0017 "TOTAL"
		#define STR0018 "DISCOUNTS"
		#define STR0019 "DAY SAL."
		#define STR0020 "TOTAL"
		#define STR0021 "NET"
		#define STR0027 "COST CENTER: "
		#define STR0028 "SUBTOTAL.............: "
		#define STR0029 "TOTAL................: "
		#define STR0030 " From "
		#define STR0031 "Page: "
		#define STR0032 "REMUNERATION"
		#define STR0033 "MONTH"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Corp. Avid. Y Gan, Jarabacoa, C.por A.", "Corp. Avíc. y Gan, Jarabacoa, C.por A." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Relacão De Prestações Laborais E Regalias", "Relatório de Remunerações e 13º salário" )
		#define STR0003 "Al "
		#define STR0004 " de "
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Ingressos ", "REMUNERAÇÕES " )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Descontos ", "DESCONTOS " )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Núm.", "NÚM." )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Empregados", "FUNCIONÁRIOS" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Cargo", "CARGO" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Sue.prom.", "SÁL.MÉD." )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Dias", "DIAS" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Prestação", "Inden.Demiss" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Regalias", "13º SALÁRIO" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Férias", "FÉRIAS" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Tot.gan.", "TOT.REM." )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Outros", "$OUTROS" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Total", "TOTAL" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Descontos", "DESCONTOS" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Sue.dia", "SÁL.DIA" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Total", "TOTAL" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Produto nacional líquido", "LÍQUIDO" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Centro de custo: ", "CENTRO DE CUSTO: " )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Subtotal.............: ", "SUBTOTAL.............: " )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Total................: ", "TOTAL................: " )
		#define STR0030 " de "
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Pagina: ", "Página: " )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Ingresso", "REMUNERAÇÃO" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Mês", "MÊS" )
	#endif
#endif
