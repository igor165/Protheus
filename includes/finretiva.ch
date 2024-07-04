#ifdef SPANISH
	#define STR0001 "Atención"
	#define STR0002 "Ok"
	#define STR0003 "Informe el campo Código fiscal de la operación(FF_CFO) en la tabla SFF para retención de IVA"
	#define STR0004 "El período de observación del proveedor está vencido "
	#define STR0005 ". Informe una fecha válida para el proveedor en el archivo de proveedores."
	#define STR0006 "Inconsistencia"
	#define STR0007 "La actividad "
	#define STR0008 " de IVA no está registrada en la tabla SFF"
	#define STR0009 "por lo tanto no se generará retención de IVA. Si desea continuar con la "
	#define STR0010 "Orden de pago, sí o no. "
	#define STR0011 "La fecha de validez para la reducción del porcentaje de la retención de IVA del proveedor ya está vencida. "
#else
	#ifdef ENGLISH
		#define STR0001 "Attention"
		#define STR0002 "Ok"
		#define STR0003 "Enter Tax Code field from operation (FF_CFO) on SFF table for VAT withholding"
		#define STR0004 "The observation period of the supplier is expired"
		#define STR0005 ". Enter a valid date for the supplier in the register of suppliers."
		#define STR0006 "Inconsistency"
		#define STR0007 "The activity"
		#define STR0008 "of VAT is not registered in SFF Table"
		#define STR0009 "So, VAT withholding is not generated. To continue with"
		#define STR0010 "Payment Order, yes, or no."
		#define STR0011 "The expiration date for the reduction in the percentage of VAT withholding for the supplier has already been reached."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0002 "Ok"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Informe el campo Código fiscal de la operación(FF_CFO) en la tabla SFF para retención de IVA", "Preencha o campo Código fiscal da operação (FF_CFO) na tabela SFF para retenção de IVA" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "El período de observación del proveedor está vencido ", "O período de observação do fornecedor está vencido" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", ". Informe una fecha válida para el proveedor en el archivo de proveedores.", ". Informe uma data válida para o fornecedor no cadastro de fornecedores." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Inconsistencia", "Inconsistência" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "La actividad ", "A atividade" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", " de IVA no está registrada en la tabla SFF", "de IVA não está cadastrada na tabela SFF" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "por lo tanto no se generará retención de IVA. Si desea continuar con la ", "Portanto, não será gerada a retenção de IVA. Se deseja continuar com a" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Orden de pago, sí o no. ", "Ordem de Pagamento, sim ou não." )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "La fecha de validez para la reducción del porcentaje de la retención de IVA del proveedor ya está vencida. ", "A data de validade para a redução da porcentagem da retenção de IVA do fornecedor já está vencida." )
	#endif
#endif
