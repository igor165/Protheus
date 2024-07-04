#ifdef SPANISH
	#define STR0001 "Motivos de Mantenimiento de la Agenda"
	#define STR0002 "Visualizar"
	#define STR0003 "Incluir"
	#define STR0004 "Modificar"
	#define STR0005 "Borrar"
	#define STR0006 "Solo el tipo 04 puede tener un servicio definido."
	#define STR0007 "No es posible registrar el tipo Compensación sin el campo ABR_COMPEN configurado."
#else
	#ifdef ENGLISH
		#define STR0001 "Reasons of Schedule Maintenance"
		#define STR0002 "View"
		#define STR0003 "Add"
		#define STR0004 "Edit"
		#define STR0005 "Delete"
		#define STR0006 "Only type 04 can have a service defined."
		#define STR0007 "Unable to register the Compensation type without the ABR_COMPEN field configured."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Motivos de manutenção da agenda", "Motivos de Manutenção da Agenda" )
		#define STR0002 "Visualizar"
		#define STR0003 "Incluir"
		#define STR0004 "Alterar"
		#define STR0005 "Excluir"
		#define STR0006 "Apenas o tipo 04 pode ter um serviço definido."
		#define STR0007 "Não é possível cadastrar o tipo Compensação sem o campo ABR_COMPEN configurado."
	#endif
#endif
