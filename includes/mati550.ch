#ifdef SPANISH
	#define STR0001 "No se implementó un adapter para esta versión de mensaje."
	#define STR0002 "¡Versión del mensaje no se informó!"
	#define STR0003 "Error en el parser del mensaje recibido: "
	#define STR0004 "No se implementó un adapter para esta versión de mensaje."
	#define STR0005 "Recepción no implementada para esta versión y adapter."
	#define STR0006 "No fue posible grabar en la tabla De/A."
	#define STR0007 "Valor interno o externo en blanco, no será posible grabar en la tabla De/A."
#else
	#ifdef ENGLISH
		#define STR0001 "Adapter not implemented for this message version."
		#define STR0002 "Message version not entered."
		#define STR0003 "Error in received message parser: "
		#define STR0004 "Adapter not implemented for this message version."
		#define STR0005 "Receipt not implented for this version and adapter."
		#define STR0006 "Could not save to table From/To."
		#define STR0007 "Internal or External Value is blank. Cannot save to table From/To."
	#else
		#define STR0001 "Não foi implementado adapter para esta versão de mensagem."
		#define STR0002 "Versão da mensagem não informada."
		#define STR0003 "Erro no parser da mensagem recebida: "
		#define STR0004 "Não foi implementado adapter para esta versão de mensagem."
		#define STR0005 "Recebimento não implementado para esta versão e adapter."
		#define STR0006 "Não foi possível gravar na tabela De/Para."
		#define STR0007 "Valor interno ou externo em branco não sendo possível gravar na tabela De/Para."
	#endif
#endif
