#ifdef SPANISH
	#define STR0001 "Aumento de salario mínimo"
	#define STR0002 "OK"
	#define STR0003 "Atención"
	#define STR0004 "Indique una Fecha de Resolución"
	#define STR0005 "Procesando... "
	#define STR0006 "Informe un porcentaje de aumento."
	#define STR0007 "Categoría... "
	#define STR0008 "Historico de Categorias"
	#define STR0009 "Generando reporte... "
	#define STR0010 "Visualizar"
	#define STR0011 "Buscar"
	#define STR0012 "Reporte de Aumento de Salario Mínimo"
	#define STR0013 "Reajuste Salarial"
	#define STR0014 "Código"
	#define STR0015 "Descripción"
	#define STR0016 "Salario "
	#define STR0017 "Mensual"
	#define STR0018 "Diario"
	#define STR0019 "Factor"
	#define STR0020 "por Tarea"
	#define STR0021 "De "
	#define STR0022 "A "
	#define STR0023 "Antigüedad"
	#define STR0024 "Fecha de Resolución"
	#define STR0025 "No existe información para esos parámetros."
#else
	#ifdef ENGLISH
		#define STR0001 "Minimum Wage Raise"
		#define STR0002 "OK"
		#define STR0003 "Attention"
		#define STR0004 "Enter Instruction Date"
		#define STR0005 "Processing..."
		#define STR0006 "Enter percentage of increase."
		#define STR0007 "Category..."
		#define STR0008 "Category History"
		#define STR0009 "Generating report..."
		#define STR0010 "View"
		#define STR0011 "Search"
		#define STR0012 "Minimum Wage Increase Report"
		#define STR0013 "Wage Adjustment"
		#define STR0014 "Code"
		#define STR0015 "Description"
		#define STR0016 "Wage"
		#define STR0017 "Monthly"
		#define STR0018 "Daily"
		#define STR0019 "Factor"
		#define STR0020 "Per Task"
		#define STR0021 "From"
		#define STR0022 "To"
		#define STR0023 "Time of Serv"
		#define STR0024 "Instruction Date"
		#define STR0025 "No information for these parameters."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Aumento de salario mínimo", "Aumento de Salário Mínimo" )
		#define STR0002 "OK"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Indique una Fecha de Resolución", "Indique uma Data da Instrução" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Procesando... ", "Processando..." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Informe un porcentaje de aumento.", "Informe uma porcentagem de acréscimo." )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Categoría... ", "Categoria..." )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Historico de Categorias", "Histórico de Categorias" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Generando reporte... ", "Gerando relatório..." )
		#define STR0010 "Visualizar"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Buscar", "Pesquisar" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Reporte de Aumento de Salario Mínimo", "Relatório de Acréscimo de Salário Mínimo" )
		#define STR0013 "Reajuste Salarial"
		#define STR0014 "Código"
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Descripción", "Descrição" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Salario ", "Salário" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Mensual", "Mensal" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Diario", "Diário" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Factor", "Fator" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "por Tarea", "por Tarefa" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "De ", "De" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "A ", "Até" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Antigüedad", "Tempo de Serv" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Fecha de Resolución", "Data da Instrução" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "No existe información para esos parámetros.", "Não existe informação para esses parâmetros." )
	#endif
#endif
