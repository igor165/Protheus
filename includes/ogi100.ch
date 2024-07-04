#ifdef SPANISH
	#define STR0001 'Falla en el manejo del Xml recibido.'
	#define STR0002 'Error en la devolución. ¡La Referencia/Marca es obligatoria!'
	#define STR0003 'Error en la devolución. ¡El OriginalInternalId es obligatorio!'
	#define STR0004 'Error en la devolución. ¡El DestinationInternalId es obligatorio!'
	#define STR0005 '¡Contenido del MessageContent vacío!'
	#define STR0006 '¡Evento de la devolución no valido!'
	#define STR0007 '¡Error en el parser de devolución!'
	#define STR0008 'COSECHA'
	#define STR0009 "Existe un registro integrado con este código."
	#define STR0010 "No se permite modificar el código de la cosecha en el Protheus."
#else
	#ifdef ENGLISH
		#define STR0001 'Error manipulating received XML.'
		#define STR0002 'Error in return. Reference/brand is mandatory'
		#define STR0003 'Error in return. OriginalInternalId is mandatory!'
		#define STR0004 'Error in return. DestinationlInternalId is mandatory!'
		#define STR0005 'Content of MessageContent empty!'
		#define STR0006 'Invalid return event!'
		#define STR0007 'Error in return parser!'
		#define STR0008 'CROP'
		#define STR0009 "There is already a record integrated with this code."
		#define STR0010 "Unable to edit the Crop code in Protheus."
	#else
		#define STR0001 'Falha na manipulação do Xml recebido.'
		#define STR0002 'Erro no retorno. A Referencia/Marca é obrigatória!'
		#define STR0003 'Erro no retorno. O OriginalInternalId é obrigatório!'
		#define STR0004 'Erro no retorno. O DestinationInternalId é obrigatório!'
		#define STR0005 'Conteúdo do MessageContent vazio!'
		#define STR0006 'Evento do retorno inválido!'
		#define STR0007 'Erro no parser do retorno!'
		#define STR0008 'SAFRA'
		#define STR0009 "Já existe um registro integrado com este código."
		#define STR0010 "Não é permitido alterar o código da Safra no Protheus."
	#endif
#endif
