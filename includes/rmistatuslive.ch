#ifdef SPANISH
	#define STR0001 "Parámetros incorrectos en el servicio RMISTATUS"
	#define STR0002 "Servicio RMISTATUS ya lo está utilizando otra instancia"
	#define STR0003 "Problema al efectuar el ParseUrl verificar las configuraciones en el  archivo de suscriptores"
	#define STR0004 "Tag <a:SituacionProcesamiento> no encontrada en el Xml de devolución"
	#define STR0005 "Problema al efectuar SendSoapMsg"
#else
	#ifdef ENGLISH
		#define STR0001 "Incorrect parameters in the service RMISTATUS"
		#define STR0002 "Service RMISTATUS already being used by another instance."
		#define STR0003 "Problem executing the ParseUrl, check the configurations in the Subscribers registration"
		#define STR0004 "Tag <a:SituacaoProcessamento> not found in the return XML"
		#define STR0005 "Problem executing SendSoapMsg"
	#else
		#define STR0001 "Parâmetros incorretos no serviço RMISTATUS "
		#define STR0002 "Serviço RMISTATUS já esta sendo utilizado por outra instância "
		#define STR0003 "Problema ao efetuar o ParseUrl verificar as configurações no cadastro de Assinantes "
		#define STR0004 " Tag <a:SituacaoProcessamento> não encontrada no Xml de retorno"
		#define STR0005 " Problema ao efetuar SendSoapMsg "
	#endif
#endif
