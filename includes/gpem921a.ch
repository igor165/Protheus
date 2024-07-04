#ifdef SPANISH
	#define STR0001 "Inicio de procesamiento del JOB."
	#define STR0002 "La rutina 'GPEM921A' está siendo ejecutada por otro proceso"
	#define STR0003 "Error en la recepción de los parámetros utilizados en la ejecución del JOB"
	#define STR0004 "Final del procesamiento del JOB."
	#define STR0005 "Error al enviar el(los) evento(s) al gobierno, verifique si los servidores TSS y REST están activos y configurados correctamente."
	#define STR0006 "No fue posible ordenar los eventos para enviar al gobierno."
	#define STR0007 "No fue posible encontrar los eventos en la base de datos para enviar al gobierno."
#else
	#ifdef ENGLISH
		#define STR0001 "Start of JOB Processing!"
		#define STR0002 "Another process is running routine 'GPEM921A'"
		#define STR0003 "Error in receipt of parameters used in execution of JOB"
		#define STR0004 "End of JOB Processing!"
		#define STR0005 "Error sending the events to the government. Check if the TSS and REST servers are active and properly configured."
		#define STR0006 "Unable to order the events to send to the government."
		#define STR0007 "Unable to find the events in the database to send to the government."
	#else
		#define STR0001 "Início do Processamento do JOB!"
		#define STR0002 "A rotina 'GPEM921A' está sendo executada por outro processo"
		#define STR0003 "Erro no recebimento dos parâmetros utilizados na execução do JOB"
		#define STR0004 "Fim do Processamento do JOB!"
		#define STR0005 "Erro ao enviar o(s) evento(s) para o governo, verifique se os servidores TSS e REST estão ativos e configurados corretamente."
		#define STR0006 "Não foi possível ordenar os eventos para enviar ao governo."
		#define STR0007 "Não foi possível encontrar os eventos no banco de dados para enviar ao governo."
	#endif
#endif
