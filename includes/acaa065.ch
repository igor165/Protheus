#ifdef SPANISH
	#define STR0001 "Seleccionando alumnos ..."
	#define STR0002 "No se enviará ningún e-mail a los parámetros informados."
	#define STR0003 "No se enviará ningun e-mail, pues el Punto de entrada AC065Msg no existe."
	#define STR0004 "¿De RA?"
	#define STR0005 "¿A RA  ?"
	#define STR0006 "¿De Curso estándar?"
	#define STR0007 "¿A Curso estándar?"
	#define STR0008 "¿De Período lectivo?"
	#define STR0009 "¿A Período lectivo?"
	#define STR0010 "¿De Habilitación?"
	#define STR0011 "¿A Habilitación?"
	#define STR0012 "¿De Año?"
	#define STR0013 "¿A Año?"
	#define STR0014 "¿De Unidad?"
	#define STR0015 "¿A Unidad?"
	#define STR0016 "¿De Turno?"
	#define STR0017 "¿A Turno ?"
	#define STR0018 "¿Alumnos graduados?"
#else
	#ifdef ENGLISH
		#define STR0001 "Selectiong students ..."
		#define STR0002 "For the parameters entered, no e-maill will be sent."
		#define STR0003 "No e-mail will be sent because the point of entry AC065Msg does not exist."
		#define STR0004 "From RA?"
		#define STR0005 "To RA?"
		#define STR0006 "From standard course?"
		#define STR0007 "To standard course?"
		#define STR0008 "From school year?"
		#define STR0009 "To school year?"
		#define STR0010 "From qualification?"
		#define STR0011 "To qualification?"
		#define STR0012 "From year?"
		#define STR0013 "To year?"
		#define STR0014 "From unit?"
		#define STR0015 "To unit?"
		#define STR0016 "From shift?"
		#define STR0017 "To shift?"
		#define STR0018 "Graduated students?"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "A selecionar alunos ...", "Selecionando Alunos ..." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Para os parâmetro s informados, nenhum e-mail será enviado.", "Para os parametros informados, nenhum e-mail sera enviado." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Nenhum e-mail será enviado pois o ponto de entrada ac065msg não existe.", "Nenhum e-mail sera enviado pois o Ponto de Entrada AC065Msg nao existe." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Ra de ?", "RA de ?" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Ra até ?", "RA ate ?" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Curso padrão de ?", "Curso Padrão de ?" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Curso padrão até ?", "Curso Padrão ate ?" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Período lectivo de ?", "Periodo Letivo de ?" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Período lectivo até ?", "Periodo Letivo ate ?" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Activação de ?", "Habilitacao de ?" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Activação ate ?", "Habilitacao ate ?" )
		#define STR0012 "Ano de ?"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Ano até ?", "Ano ate ?" )
		#define STR0014 "Unidade de ?"
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Unidade até ?", "Unidade ate ?" )
		#define STR0016 "Turno de ?"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Turno até ?", "Turno ate ?" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Alunos formados ?", "Alunos Formados ?" )
	#endif
#endif
