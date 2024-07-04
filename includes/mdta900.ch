#ifdef SPANISH
	#define STR0001 "Buscar"
	#define STR0002 "Visualizar"
	#define STR0003 "Historial"
	#define STR0004 "Modificaciones del GFIP"
	#define STR0005 "Codigo GFIP"
	#define STR0006 "Matricula"
	#define STR0007 "Nombre"
	#define STR0008 "La fecha de modificacion no puede ser anterior a fecha de admision del funcionario."
	#define STR0009 "Fecha de Admision: "
	#define STR0010 "Leyenda"
	#define STR0011 "Empleados"
	#define STR0012 "ATENCIÓN"
	#define STR0013 "Fecha en blanco."
	#define STR0014 "Informe la fecha."
	#define STR0015 "Fecha no válida."
	#define STR0016 "La fecha informada no puede ser mayor que la fecha actual."
#else
	#ifdef ENGLISH
		#define STR0001 "Search"
		#define STR0002 "View"
		#define STR0003 "History"
		#define STR0004 "GFIP Changes"
		#define STR0005 "GFIP Code"
		#define STR0006 "Registration no."
		#define STR0007 "Name"
		#define STR0008 "The alteration date cannot be lower than the employee admission date."
		#define STR0009 "Admission Date  : "
		#define STR0010 "Subtitle"
		#define STR0011 "Employees"
		#define STR0012 "ATTENTION"
		#define STR0013 "Date blank."
		#define STR0014 "Enter date."
		#define STR0015 "Invalid Date."
		#define STR0016 "Date informed cannot be later than current date."
	#else
		#define STR0001 "Pesquisar"
		#define STR0002 "Visualizar"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Histórico", "Historico" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Alterações Do Gfip", "Alteracoes do GFIP" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Código Gfip", "Codigo GFIP" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Matrícula", "Matricula" )
		#define STR0007 "Nome"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "A data de alteração não pode ser anterior à data de admissão do funcionário.", "A data de alteracao nao pode ser anterior a data de admissao do funcionario." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Data de admissão: ", "Data de Admissao: " )
		#define STR0010 "Legenda"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Colaboradores", "Funcionários" )
		#define STR0012 "ATENÇÃO"
		#define STR0013 "Data em branco."
		#define STR0014 "Informar a data."
		#define STR0015 "Data inválida."
		#define STR0016 "A data informada nao pode ser maior que a data atual."
	#endif
#endif
