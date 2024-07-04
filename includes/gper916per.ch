#ifdef SPANISH
	#define STR0001 "Comunicado al trabajador cesado antes del reparto de utilidades."
	#define STR0002 "Sucursal + Matricula"
	#define STR0003 "Sucursal + Ceco + Matrícula"
	#define STR0004 "Sucursal + Nombre"
	#define STR0005 "Comunicacion al trabajador cesado antes del reparto de las utilidades para que proceda a recogerlas."
	#define STR0006 "Encabezado"
	#define STR0007 "Detalle"
	#define STR0008 "PiePagina"
	#define STR0009 "Lima, "
	#define STR0010 " de "
	#define STR0011 "Sr(a)."
	#define STR0012 "Ciudad: "
	#define STR0013 "La empresa "
	#define STR0014 ", debidamente identificada con RUC No.: "
	#define STR0015 ", domiciliada en "
	#define STR0016 " y representada por "
	#define STR0017 ", identidicada con DNI No.: "
	#define STR0018 ", cumple con comunicarle lo siguiente:"
	#define STR0019 "La empresa ha realizado el calculo de las utilidades correspondiente al ejercicio "
	#define STR0020 ", las cuales seran distribuidas entre los trabajadores que "
	#define STR0021 "laboraron durante el ejercicio antes mencionado."
	#define STR0022 "En la medida que usted es un ex trabajador y en aplicacion de las disposiciones contenidas en el D.Leg. No. 892, se ha determinado que usted tiene derecho "
	#define STR0023 "a la siguiente cantidad por este concepto:"
	#define STR0024 "S/. "
	#define STR0025 " nuevos soles."
	#define STR0026 "Con la finalidad de hacer efectivo el pago de estas utilidades y que entregarle su hoja de liquidacion, debera acercarse al local de la empresa "
	#define STR0027 "ubicada en "
	#define STR0028 ", en el horario de "
	#define STR0029 "Agradeciendo anticipadamente su atencion."
	#define STR0030 "Atentamente,"
	#define STR0031 "___________________________________________"
	#define STR0032 "(Empleador)"
#else
	#ifdef ENGLISH
		#define STR0001 "Communication for employees dismissed before the sharing of profits."
		#define STR0002 "Branch + Enrollment"
		#define STR0003 "Branch+Dismissal+Registration"
		#define STR0004 "Branch/name"
		#define STR0005 "Communication for employees dismissed before the sharing of profits, so the employee receives their share."
		#define STR0006 "Header"
		#define STR0007 "Detail"
		#define STR0008 "Footer"
		#define STR0009 "Lima,"
		#define STR0010 "from"
		#define STR0011 "Mr./Ms."
		#define STR0012 "City:"
		#define STR0013 "The company"
		#define STR0014 ", duly identified with RUC no.:"
		#define STR0015 ", living in"
		#define STR0016 "and represented by"
		#define STR0017 ", identified with Social Security Number"
		#define STR0018 ", communicates this:"
		#define STR0019 "The company calculated the profits related to fiscal year"
		#define STR0020 ", which will be split among the employees"
		#define STR0021 "that worked during the fiscal year before mentioned."
		#define STR0022 "As a former employee and according to provisions in Decree Law No. 892, it was determined that you are entitled to"
		#define STR0023 "this amount by this allowance:"
		#define STR0024 "S/"
		#define STR0025 "nuevos soles."
		#define STR0026 "To pay profits mentioned and deliver the settlement payroll, go to the company,"
		#define STR0027 "located in"
		#define STR0028 ", at"
		#define STR0029 "We thank you in advance."
		#define STR0030 "Sincerely,"
		#define STR0031 "___________________________________________"
		#define STR0032 "(Employer)"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Comunicado al trabajador cesado antes del reparto de utilidades.", "Comunicado para funcionários desligados antes da repartição dos lucros." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Sucursal + Matricula", "Filial + Matrícula" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Sucursal + Ceco + Matrícula", "Filial + Desligamento + Matrícula" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Sucursal + Nombre", "Filial / Nome" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Comunicacion al trabajador cesado antes del reparto de las utilidades para que proceda a recogerlas.", "Comunicação para funcionários desligados antes da repartição dos lucros para que possa receber sua parte." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Encabezado", "Cabeçalho" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Detalle", "Detalhe" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "PiePagina", "Rodapé" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Lima, ", "Lima," )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", " de ", "de" )
		#define STR0011 "Sr(a)."
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Ciudad: ", "Cidade:" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "La empresa ", "A empresa" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", ", debidamente identificada con RUC No.: ", ", devidamente identificada com RUC Nº:" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", ", domiciliada en ", ", domiciliada em" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", " y representada por ", "e representada por" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", ", identidicada con DNI No.: ", ", identificada com R.G. Nº:" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", ", cumple con comunicarle lo siguiente:", ", comunica o seguinte:" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "La empresa ha realizado el calculo de las utilidades correspondiente al ejercicio ", "A empresa efetuou o cálculo dos lucros correspondentes ao exercício" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", ", las cuales seran distribuidas entre los trabajadores que ", ", os quais serão distribuídos entre os funcionários que" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "laboraron durante el ejercicio antes mencionado.", "trabalharam durante o exercício mencionado." )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "En la medida que usted es un ex trabajador y en aplicacion de las disposiciones contenidas en el D.Leg. No. 892, se ha determinado que usted tiene derecho ", "Na qualidade de ex funcionário e conforme o previsto no Decreto Lei Nº 892, foi determinado que tem direito" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "a la siguiente cantidad por este concepto:", "à seguinte quantia por esta verba:" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "S/. ", "S/." )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", " nuevos soles.", "nuevos soles." )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Con la finalidad de hacer efectivo el pago de estas utilidades y que entregarle su hoja de liquidacion, debera acercarse al local de la empresa ", "Para efetuar o pagamento dos lucros mencionados e poder entregar sua folha de liquidação, apresente-se no local da empresa," )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "ubicada en ", "localizada em" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", ", en el horario de ", ", no horário de" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Agradeciendo anticipadamente su atencion.", "Agradecemos por adiantado sua colaboração." )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Atentamente,", "Atenciosamente,," )
		#define STR0031 "___________________________________________"
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "(Empleador)", "(Empregador)" )
	#endif
#endif
