#ifdef SPANISH
	#define STR0001 "Esta rutina solamente puede ejecutarse una vez por usuario."
	#define STR0002 "Verifique si la rutina '#1' está abierta para el usuario '#2' en otra conexión."
	#define STR0003 "Error al ejecutar el parse del xml #1, rutina: '#2'."
	#define STR0004 "Aviso al ejecutar el parse del xml '#1', rutina: '#2'."
#else
	#ifdef ENGLISH
		#define STR0001 "You can only run this routine once per user."
		#define STR0002 "Check whether routine '#1' is open for user '#2' in another connection."
		#define STR0003 "Error running parse of xml #1, routine: '#2'."
		#define STR0004 "Alert running parse of xml '#1', routine: '#2'."
	#else
		#define STR0001 "Esta rotina só pode ser executada apenas uma vez por usuário."
		#define STR0002 "Verifique se a rotina '#1' esta aberta para o usuário '#2' em outra conexão."
		#define STR0003 "Erro ao executar o parse do xml #1, rotina: '#2'."
		#define STR0004 "Alerta ao executar o parse do xml '#1', rotina: '#2'."
	#endif
#endif
