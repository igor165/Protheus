#ifdef SPANISH
	#define STR0001 "Error en el XML recebido."
	#define STR0002 "El contenido de la etiqueta Request es inválido o no se envio."
	#define STR0003 "No se encontro la etiqueta que identifica la marca integrada."
	#define STR0004 "La etiqueta BusinessContent no se encontro en el mensaje."
	#define STR0005 "No se encontro el titulo para baja."
	#define STR0006 "Ya existe movimiento de baja con este InternalId."
	#define STR0007 "En caso de que desee modificar esta baja, es necesario realizar la reversion de la baja y dar baja el titulo nuevamente."
	#define STR0008 "No se encontro la baja para realizar la reversion."
	#define STR0009 "La etiqueta InternalId no se encontro en el mensaje."
	#define STR0010 "No se encontro el banco de la baja."
	#define STR0011 "Se envio la informacion del banco de la baja y el adapter MATI070 esta desactualizado. Entre en contacto con el Soporte Totvs."
	#define STR0012 "Para utilizar correctamente esta funcionalidad, es necesario actualizar la rutina Cobros Diversos (FINA087A)."
#else
	#ifdef ENGLISH
		#define STR0001 "Error in XML received"
		#define STR0002 "The content of the tag Request is not valid or was not sent."
		#define STR0003 "Label identifying integrated brand."
		#define STR0004 "BusinessContent label not found in the message."
		#define STR0005 "Bill not found for the write-off."
		#define STR0006 "A write-off transaction already exists with this Internalld."
		#define STR0007 "If you want to edit this write-off, reverse the write-off and write-off bill again."
		#define STR0008 "The write-off was not found to reverse."
		#define STR0009 "InternalId label not found in the message."
		#define STR0010 "Write-off bank not found."
		#define STR0011 "Information of write-off bank sent and adapter MATl070 is outdated. Contact TOTVS Support."
		#define STR0012 "To use this functionality properly, update routine Several Receivable (FINA087A) routine."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Error en el XML recebido.", "Erro no XML recebido." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "El contenido de la etiqueta Request es inválido o no se envio.", "O conteúdo da etiqueta Request é inválido ou não foi enviado." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "No se encontro la etiqueta que identifica la marca integrada.", "Não foi encontra a etiqueta que identifica a marca integrada." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "La etiqueta BusinessContent no se encontro en el mensaje.", "A etiqueta BusinessContent não foi encontrada na mensagem." )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "No se encontro el titulo para baja.", "Não foi encontrado o título para baixa." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Ya existe movimiento de baja con este InternalId.", "Já existe movimento de baixa com este InternalId." )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "En caso de que desee modificar esta baja, es necesario realizar la reversion de la baja y dar baja el titulo nuevamente.", "Caso deseje alterar esta baixa, é necessário efetuar o estorno da baixa e dar baixa no título novamente." )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "No se encontro la baja para realizar la reversion.", "Não foi encontra baixa para efetuar o estorno." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "La etiqueta InternalId no se encontro en el mensaje.", "A etiqueta InternalId não foi encontrada a mensagem." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "No se encontro el banco de la baja.", "Não foi encontrado o banco da baixa." )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Se envio la informacion del banco de la baja y el adapter MATI070 esta desactualizado. Entre en contacto con el Soporte Totvs.", "Foi enviada a informação do banco da baixa e o adapter MATI070 está desatualizado. Contacte o Suporte Totvs." )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Para utilizar correctamente esta funcionalidad, es necesario actualizar la rutina Cobros Diversos (FINA087A).", "Para usar corretamente esta funcionalidade, é necessário atualizar a rotina Recebimentos Diversos (FINA087A)." )
	#endif
#endif
