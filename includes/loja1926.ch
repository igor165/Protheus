#ifdef SPANISH
	#define STR0001 "Pin-Pad no configurado. No sera posible realizar transacciones de Debito."
	#define STR0002 "Anulando Transacc. TEF. Espere..."
	#define STR0003 "Transaccion TEF no se realizo. ¡Por favor retenga el Comprobante!"
	#define STR0004 "Acceso negado, contraseña del Superior invalida"
	#define STR0005 "Pase el documento y espere la lectura..."
	#define STR0006 "Error al intentar leer el documento. ¿Intentar leer nuevamente?"
	#define STR0007 "Codigo de barras inconsistente."
	#define STR0008 "Inconsistencias en el bloque "
	#define STR0009 " del codigo de barras."
	#define STR0010 "¡Acceso negado, usuario sin permiso para anular transacción TEF!"
#else
	#ifdef ENGLISH
		#define STR0001 "Pin-Pad not configured. Debit transactions cannot be performed."
		#define STR0002 "Canceling EFT transaction. Wait..."
		#define STR0003 "EFT transaction was not performed. Retain the receipt!"
		#define STR0004 "Access denied, Superior password is invalid!"
		#define STR0005 "Pass the document and wait for the reading..."
		#define STR0006 "Error trying to read the document. Try to read again?"
		#define STR0007 "Inconsistent bar code."
		#define STR0008 "Inconsistencies in block "
		#define STR0009 " of bar code."
		#define STR0010 "Access denied. User not allowed to cancel TEF transaction."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Pin-Pad não configurado. Não será possível realizar transacções de Débito.", "Pin-Pad não configurado. Não será possível realizar transações de Débito." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Cancelando Transacção TEF. Aguarde...", "Cancelando Transacao TEF. Aguarde..." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Transacção TEF não foi efectuada. Favor reter o Cupão!", "Transação TEF não foi efetuada. Favor reter o Cupom!" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Accesso negado. Palavra-passe do Superior inválida!", "Acesso negado, senha do Superior inválida!" )
		#define STR0005 "Passe o documento e aguarde a leitura..."
		#define STR0006 "Erro ao tentar ler o documento. Tentar ler novamente?"
		#define STR0007 "Código de barras inconsistente."
		#define STR0008 "Inconsistências no bloco "
		#define STR0009 " do código de barras."
		#define STR0010 "Acesso negado, usuário sem permissão para cancelar transação TEF!"
	#endif
#endif
