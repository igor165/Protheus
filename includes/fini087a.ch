#ifdef SPANISH
	#define STR0001 "El contenido de la etiqueta Request es inválido o no se envió."
	#define STR0002 "No se encontró la etiqueta que identifica la marca integrada."
	#define STR0003 "La etiqueta AccountDocumentInternalId no se encontró en el mensaje."
	#define STR0004 "No se encontró el título para actualización del valor."
	#define STR0005 "Error en el XML recibido."
#else
	#ifdef ENGLISH
		#define STR0001 "The content of the tag Request is not valid or was not sent."
		#define STR0002 "Label that identifies the the integrated brand was not found."
		#define STR0003 "AccountDocumentInternalId label not found in the message."
		#define STR0004 "Bill for value update not found."
		#define STR0005 "Error in XML receipt."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "El contenido de la etiqueta Request es inválido o no se envió.", "O conteúdo da etiqueta Request é inválido ou não foi enviado." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "No se encontró la etiqueta que identifica la marca integrada.", "Não foi encontrada a etiqueta que identifica a marca integrada." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "La etiqueta AccountDocumentInternalId no se encontró en el mensaje.", "A etiqueta AccountDocumentInternalId não foi encontrada na mensagem." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "No se encontró el título para actualización del valor.", "Não foi encontrado o título para atualização do valor." )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Error en el XML recibido.", "Erro no XML recebido." )
	#endif
#endif
