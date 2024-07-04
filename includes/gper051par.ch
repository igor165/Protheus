#ifdef SPANISH
	#define STR0001 "Reporte Salario Mínimo - Categorías"
	#define STR0002 "OK"
	#define STR0003 "Atención"
	#define STR0004 "Indique una Fecha de Resolución"
	#define STR0005 "Procesando... "
	#define STR0006 "No existe información para esos parámetros."
	#define STR0007 "Categorías... "
	#define STR0008 "S070 - Salario por Tarea"
	#define STR0009 "Generando reporte... "
	#define STR0010 "S003 - Salario por Antigüedad"
	#define STR0011 "Antigüedad"
	#define STR0012 "Fecha de Resolución"
	#define STR0013 "Filial + Categoría"
	#define STR0014 "Código"
	#define STR0015 "Descripción"
	#define STR0016 "Salario "
	#define STR0017 "Mensual"
	#define STR0018 "Diario"
	#define STR0019 "Factor"
	#define STR0020 "por Tarea"
	#define STR0021 "De "
	#define STR0022 "A "
	#define STR0023 "Filial + Tipo de Salario (Categoría, Por Tarea y Antigüedad)"
#else
	#ifdef ENGLISH
		#define STR0001 "Min Salary Report - Categories"
		#define STR0002 "OK"
		#define STR0003 "Attention"
		#define STR0004 "Enter Instruction Date"
		#define STR0005 "Processing..."
		#define STR0006 "No information for these parameters."
		#define STR0007 "Categories..."
		#define STR0008 "S070 - Salary per Task"
		#define STR0009 "Generating report..."
		#define STR0010 "S003 - Salary per Service Length"
		#define STR0011 "Serv Length"
		#define STR0012 "Instruction Date"
		#define STR0013 "Branch+Category"
		#define STR0014 "Code"
		#define STR0015 "Description"
		#define STR0016 "Salary"
		#define STR0017 "Monthly"
		#define STR0018 "Daily"
		#define STR0019 "Factor"
		#define STR0020 "Per Task"
		#define STR0021 "From"
		#define STR0022 "To"
		#define STR0023 "Branch + Type of Salary (Category, Per Task and Serv Length)"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Reporte Salario Mínimo - Categorías", "Relatório Salário Mínimo - Categorias" )
		#define STR0002 "OK"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Indique una Fecha de Resolución", "Indique uma Data da Instrução" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Procesando... ", "Processando..." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "No existe información para esos parámetros.", "Não existe informação para esses parâmetros." )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Categorías... ", "Categorias..." )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "S070 - Salario por Tarea", "S070 - Salário por Tarefa" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Generando reporte... ", "Gerando relatório..." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "S003 - Salario por Antigüedad", "S003 - Salário por Tempo de Serviço" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Antigüedad", "Tempo de Serv" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Fecha de Resolución", "Data da Instrução" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Filial + Categoría", "Filial + Categoria" )
		#define STR0014 "Código"
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Descripción", "Descrição" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Salario ", "Salário" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Mensual", "Mensal" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Diario", "Diário" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Factor", "Fator" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "por Tarea", "por Tarefa" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "De ", "De" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "A ", "Até" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Filial + Tipo de Salario (Categoría, Por Tarea y Antigüedad)", "Filial + Tipo de Salário (Categoria, Por Tarefa e Tempo de Serv)" )
	#endif
#endif
