#ifdef SPANISH
	#define STR0001 "Devolución bancaria automática (Pagar)"
	#define STR0002 "Sólo por Schedule se podrá ejecutar el proceso"
	#define STR0003 "No fue posible copiar el archivo"
	#define STR0004 "al directorio"
	#define STR0005 "No se pudo borrar el archivo"
	#define STR0006 "Error"
#else
	#ifdef ENGLISH
		#define STR0001 "Automatic Banking Return (to pay)"
		#define STR0002 "Process can be performed only via Schedule"
		#define STR0003 "File could not be copied"
		#define STR0004 "to the directory"
		#define STR0005 "Excluding file was not possible "
		#define STR0006 "Error "
	#else
		#define STR0001 "Retorno Bancário Automatico (Pagar)"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "O processo pode ser executado somente via Schedule", "Processo pode ser executado apenas via Schedule" )
		#define STR0003 "Não foi possível copiar o arquivo "
		#define STR0004 " para o diretório "
		#define STR0005 "Não foi possível excluir o arquivo "
		#define STR0006 "Erro "
	#endif
#endif
