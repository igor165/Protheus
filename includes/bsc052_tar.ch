#ifdef SPANISH
	#define STR0001 "Informe de Iniciativas y Tareas"
	#define STR0002 "Informes de Iniciativas y Tareas"
	#define STR0003 "Iniciando generacion del informe [REL052_"
	#define STR0004 "Error en la creacion del archivo [REL052_"
	#define STR0005 "Operacion abortada"
	#define STR0006 "Finalizada la generacion del informe ["
	#define STR0007 "Organizacion"
	#define STR0008 "Estrategia:"
	#define STR0009 "Periodo"
	#define STR0010 " a "
	#define STR0011 "Emision:"
	#define STR0012 "Tareas en el periodo de "
	#define STR0013 "Descripcion:"
	#define STR0014 "Persona en Cobranza:"
	#define STR0015 "Perspectiva:"
	#define STR0016 "Objetivo:"
	#define STR0017 "Iniciativa"
	#define STR0018 "Tarea"
	#define STR0019 "Situacion"
	#define STR0020 "% Completado"
	#define STR0021 "Monto"
	#define STR0022 "Urgencia"
	#define STR0023 "No se encontraron informaciones dentro de las especificaciones dadas"
	#define STR0024 "o no existen personas en cobranza para las tareas verificadas."
	#define STR0025 "Iniciativas"
	#define STR0026 "Tareas"
	#define STR0027 "Ambas"
	#define STR0028 "En Ejecucion"
	#define STR0029 "Parada"
	#define STR0030 "Completa"
	#define STR0031 "Fecha inicio: "
	#define STR0032 "Fecha final: "
	#define STR0033 "Periodo"
	#define STR0034 "A-Vital  B-Importante  C-Interesante"
	#define STR0035 "0-Urgente  1-Corto Plazo  2-Medio Plazo  3-Largo Plazo"
#else
	#ifdef ENGLISH
		#define STR0001 "Report of Initiatives and Tasks"
		#define STR0002 "Reports of Initiatives and Tasks"
		#define STR0003 "Starting generation of report [REL052_"
		#define STR0004 "Error creating file [REL052_"
		#define STR0005 "Operation aborted"
		#define STR0006 "Finished generation of report ["
		#define STR0007 "Organization"
		#define STR0008 "Strategy: "
		#define STR0009 "Period:"
		#define STR0010 " to "
		#define STR0011 "Issued: "
		#define STR0012 "Tasks in the period from "
		#define STR0013 "Description:"
		#define STR0014 "Person in Collections:"
		#define STR0015 "Perspective:"
		#define STR0016 "Objective:"
		#define STR0017 "Iniciative"
		#define STR0018 "Task "
		#define STR0019 "Status  "
		#define STR0020 "% Complete "
		#define STR0021 "Importance "
		#define STR0022 "Urgency "
		#define STR0023 "No information found within the specifications entered "
		#define STR0024 "or thare are no people in collections in the tasks checked."
		#define STR0025 "Initiatives"
		#define STR0026 "Tasks"
		#define STR0027 "Both "
		#define STR0028 "In progress"
		#define STR0029 "Stoped"
		#define STR0030 "Finished  "
		#define STR0031 "Start date: "
		#define STR0032 "End date: "
		#define STR0033 "Period "
		#define STR0034 "A-Vital  B-Important  C-Interesting"
		#define STR0035 "0-Urgent  1-Short term  2-Mid term  3-Long term"
	#else
		#define STR0001 "Relat�rio de Iniciativas e Tarefas"
		#define STR0002 "Relat�rios de Iniciativas e Tarefas"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "A iniciar gera��o do relat�rio [REL052_", "Iniciando gera��o do relat�rio [REL052_" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Erro na cria��o do ficheiro [REL052_", "Erro na cria��o do arquivo [REL052_" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Opera��o abortada", "Operac�o abortada" )
		#define STR0006 "Finalizada  a gera��o do relat�rio ["
		#define STR0007 "Organiza��o"
		#define STR0008 "Estrat�gia:"
		#define STR0009 "Per�odo:"
		#define STR0010 " a "
		#define STR0011 "Emiss�o:"
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Actividades no per�odo de ", "Tarefas no per�odo de " )
		#define STR0013 "Descri��o:"
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Pessoa Em Cobran�a:", "Pessoa em Cobran�a:" )
		#define STR0015 "Perspectiva:"
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Objectivo:", "Objetivo:" )
		#define STR0017 "Iniciativa"
		#define STR0018 "Tarefa"
		#define STR0019 "Situa��o"
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "% Conclu�da", "% Completado" )
		#define STR0021 "Import�ncia"
		#define STR0022 "Urg�ncia"
		#define STR0023 "N�o foram encontradas informa��es dentro das especifica��es passadas"
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Ou n�o existem pessoas em cobran�a nas actividades verificadas.", "ou n�o existem pessoas em cobran�a nas tarefas verificadas." )
		#define STR0025 "Iniciativas"
		#define STR0026 "Tarefas"
		#define STR0027 "Ambas"
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Em Execu��o", "Em Execuc�o" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Paragem", "Parada" )
		#define STR0030 "Completada"
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Data inicial: ", "Data in�cio: " )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Data de fim: ", "Data fim: " )
		#define STR0033 "Per�odo"
		#define STR0034 "A-Vital  B-Importante  C-Interessante"
		#define STR0035 "0-Urgente  1-Curto Prazo  2-M�dio Prazo  3-Longo Prazo"
	#endif
#endif
