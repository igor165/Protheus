#ifdef SPANISH
	#define STR0001 "Rendimientos Anuales"
	#define STR0002 "Ano Base"
	#define STR0003 "Dia/Mes Liberacion"
	#define STR0004 "Dia/Mes Informe"
	#define STR0005 "Responsable"
	#define STR0006 "Filtrar"
	#define STR0007 "Espere"
	#define STR0008 "¡Pagina invalida!"
	#define STR0009 "Limpiar Filtro"
	#define STR0010 "Pone a disposicion los anos de rendimiento anuales generados para el empleado, posibilitando que se imprima o solamente visualice el Demostrativo Anual del periodo seleccionado."
	#define STR0011 "Informe de ingresos liberado"
	#define STR0012 "Informe de ingresos bloqueado"
	#define STR0013 "Sucursal"
	#define STR0014 "Matrícula"
	#define STR0015 "Empresa"
	#define STR0016 "Acceso negado."
#else
	#ifdef ENGLISH
		#define STR0001 "Annual Income"
		#define STR0002 "Tax Year"
		#define STR0003 "Day/Month Release"
		#define STR0004 "Day/Month Report"
		#define STR0005 "Responsible"
		#define STR0006 "Filter"
		#define STR0007 "Wait"
		#define STR0008 "Void page!"
		#define STR0009 "Clear Filter"
		#define STR0010 "Provides the years of annual income generated for the employee, enabling the Annual Statement of the selected period to be printed or viewed."
		#define STR0011 "Enter Released Revenues"
		#define STR0012 "Enter Blocked Revenues"
		#define STR0013 "Branch"
		#define STR0014 "Registration"
		#define STR0015 "Company"
		#define STR0016 "Access Denied."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Rendimentos anuais", "Rendimentos Anuais" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Ano base", "Ano Base" )
		#define STR0003 "Dia/Mês Liberação"
		#define STR0004 "Dia/Mês Informe"
		#define STR0005 "Responsável"
		#define STR0006 "Filtrar"
		#define STR0007 "Aguarde"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Página inválida.", "Página inválida!" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Limpar filtro", "Limpar Filtro" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Disponibiliza os anos de rendimentos anuais gerados para o colaborador, possibilitando que seja impresso, ou somente visualizado, o Demonstrativo Anual do período seleccionado.", "Disponibiliza os anos de rendimentos anuais gerados para o funcionário, possibilitando que seja impresso, ou somente visualizado, o Demonstrativo Anual do período selecionado." )
		#define STR0011 "Informe de Rendimentos Liberado"
		#define STR0012 "Informe de Rendimentos Bloqueado"
		#define STR0013 "Filial"
		#define STR0014 "Matricula"
		#define STR0015 "Empresa"
		#define STR0016 "Acesso Negado."
	#endif
#endif
