#ifdef SPANISH
	#define STR0001 "Integracion Microsoft Project"
	#define STR0002 "Atencion Certifiquese de que el formato de la fecha en el Microsoft Project (Herramientas - Opciones) esta configurado correctamente. 31/12/00 12:33"
	#define STR0003 "Procesando informaciones..."
	#define STR0004 "Espere"
	#define STR0005 "Microsoft Project no instalado!"
	#define STR0006 "Plan"
	#define STR0007 "Orden"
	#define STR0008 "Nombre de la Tarea"
	#define STR0009 "Duracion"
	#define STR0010 "Inicio"
	#define STR0011 "Fin"
	#define STR0012 "Desea que las modificaciones hechas en el Project se sincronicen con el SIGAMNT ?"
	#define STR0013 "No hay datos para presentar."
	#define STR0014 "Informe un plan que este pendiente."
	#define STR0015 "ATENCION"
#else
	#ifdef ENGLISH
		#define STR0001 "Microsoft Integration Project"
		#define STR0002 "Attention! Be sure that date format in Microsoft Project (Tools - Options) is correctly configurated. 12/31/00 12:33"
		#define STR0003 "Processing information..."
		#define STR0004 "Please, wait"
		#define STR0005 "Microsoft Project not installed!"
		#define STR0006 "Plan"
		#define STR0007 "Order"
		#define STR0008 "Task Name"
		#define STR0009 "Duration"
		#define STR0010 "Beginning"
		#define STR0011 "End"
		#define STR0012 "Do you want changes in the Project to be synchronized with SIGAMNT?"
		#define STR0013 "There are no data to be displayed."
		#define STR0014 "Indicate a pending plan."
		#define STR0015 "ATTENTION"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Integra��o Microsoft Project", "Integracao Microsoft Project" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Aten��o! Certifique-se de que o formato da data no Microsoft Project (Ferramentas - Op��es) est� configurado correctamente. 31/12/00 12:33", "Atencao! Certifique-se de que o formato da data no Microsoft Project (Ferramentas - Opcoes) est� configurado corretamente. 31/12/00 12:33" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "A processar informa��es...", "Processando informa��es..." )
		#define STR0004 "Aguarde"
		#define STR0005 "Microsoft Project n�o instalado!"
		#define STR0006 "Plano"
		#define STR0007 "Ordem"
		#define STR0008 "Nome da Tarefa"
		#define STR0009 "Dura��o"
		#define STR0010 "In�cio"
		#define STR0011 "Fim"
		#define STR0012 "Deseja que as altera��es feitas no Project sejam sincronizadas com o SIGAMNT ?"
		#define STR0013 "N�o h� dados a serem mostrados."
		#define STR0014 "Informe um plano que esteja pendente."
		#define STR0015 "ATEN��O"
	#endif
#endif
