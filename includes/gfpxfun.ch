#ifdef SPANISH
	#define STR0001 '0=En adquisición;1=Activo;2=Prescrito;3=Pagado;4=Anulado;5=Rectificado'
	#define STR0002 '1=Activo;2=Prescrito;3=Pagado'
	#define STR0003 "Atención"
	#define STR0004 "El ítem generado anteriormente no se publicó aun y se modificará en este momento"
	#define STR0005 "El ítem generado anteriormente se publicó. Debe realizarse un nuevo ítem para la anulación"
	#define STR0006 "Sustituto no válido. Seleccione un nuevo sustituto."
#else
	#ifdef ENGLISH
		#define STR0001 '0=In acquisition;1=Asset;2=Prescribed;3=Paid;4=Canceled;5=Corrected'
		#define STR0002 '1=Active 2=Prescribed;3=Paid'
		#define STR0003 "Attention"
		#define STR0004 "The previously generated item was not published yet and will be edited now."
		#define STR0005 "The generated previously item was published. A new item is required for cancellation."
		#define STR0006 "Invalid substitute. Select a new substitute."
	#else
		#define STR0001 '0=Em aquisicao;1=Ativo;2=Prescrito;3=Pago;4=Cancelado;5=Retificado'
		#define STR0002 '1=Ativo;2=Prescrito;3=Pago'
		#define STR0003 "Atenção"
		#define STR0004 "O Item gerado anteriormente ainda não foi publicado e será alterado neste momento."
		#define STR0005 "O Item gerado anteriormente foi publicado. Deve ser feito um novo item para o cancelamento."
		#define STR0006 "Substituto inválido. Selecione um novo substituto."
	#endif
#endif
