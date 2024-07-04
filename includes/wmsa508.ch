#ifdef SPANISH
	#define STR0001 "Prevista"
	#define STR0002 "Pendiente"
	#define STR0003 "Iniciada"
	#define STR0004 "Ociosa"
	#define STR0005 "Finalizada parcialmente"
	#define STR0006 "Finalizada totalmente"
	#define STR0007 "Buscar"
	#define STR0008 "Visualizar"
	#define STR0009 "Generar requisici�n"
	#define STR0010 "Revertir requisici�n"
	#define STR0011 "Orden de producci�n"
	#define STR0012 "Espere"
	#define STR0013 "Procesando"
	#define STR0014 "�OP [VAR01] solicitada o no existen �tems por solicitar!"
	#define STR0015 "�OP [VAR01] no tiene orden de servicio de solicitud generada!"
	#define STR0016 "�Orden de producci�n no se inform�!"
	#define STR0017 "�Almac�n est�ndar no se inform� en el archivo del producto (SB1)!"
	#define STR0018 "�Ubicaci�n de destino no se inform� en el archivo de complementos del producto (SB5)!"
	#define STR0019 "�Servicio WMS no se inform� en el archivo de complementos del producto (SB5)!"
	#define STR0020 "�No existe saldo disponible para atender la requisici�n!"
	#define STR0021 "Cantidad reservada"
	#define STR0022 "Orden de servicio [VAR01] generada"
	#define STR0023 "�Orden de servicio [VAR01] borrada!"
	#define STR0024 "�La orden de servicio [VAR01] no puede revertirse, requisici�n tiene baja!"
	#define STR0025 "La orden de servicio [VAR01] debe revertirse manualmente en el WMS."
	#define STR0026 "�La orden de servicio [VAR01] no puede extornarse, existen requisiciones dadas de baja!"
	#define STR0027 "�Orden de servicio [VAR01] modificada!"
	#define STR0028 "Orden de producci�n [VAR01]"
	#define STR0029 "Secuencia [VAR01]"
	#define STR0030 "Producto [VAR01]"
	#define STR0031 "Lote [VAR01]"
	#define STR0032 "Sublote [VAR01]"
	#define STR0033 "Cantidad [VAR01]"
	#define STR0034 "RESUMEN DE LA(S) DIVERGENCIA(S)"
	#define STR0035 "RESUMEN OP(S) INTEGRADA(S) WMS"
#else
	#ifdef ENGLISH
		#define STR0001 "Estimated"
		#define STR0002 "Pending"
		#define STR0003 "Started"
		#define STR0004 "Idle"
		#define STR0005 "Partially closed"
		#define STR0006 "Fully closed"
		#define STR0007 "Search"
		#define STR0008 "View"
		#define STR0009 "Generate Request"
		#define STR0010 "Reverse Request"
		#define STR0011 "Production Order"
		#define STR0012 "Wait"
		#define STR0013 "Processing"
		#define STR0014 "PO [VAR01] already requested or there are no items to request!"
		#define STR0015 "PO [VAR01] does not have request service order generated!"
		#define STR0016 "Production order not entered!"
		#define STR0017 "Standard warehouse not informed in the product register (SB1)!"
		#define STR0018 "Destination address not informed in the product complements register (SB5)!"
		#define STR0019 "WMS service not informed in the product complements register (SB5)!"
		#define STR0020 "No balance available to serve the request!"
		#define STR0021 "Allocated Quantity"
		#define STR0022 "Service order [VAR01] generated"
		#define STR0023 "Service order [VAR01] deleted!"
		#define STR0024 "Service Order [VAR01] cannot be reversed, request is already written-off!"
		#define STR0025 "Service order [VAR01] must be manually reversed in WMS."
		#define STR0026 "Service Order [VAR01] cannot be reversed, there are written-off requests!"
		#define STR0027 "Service Order [VAR01] edited!"
		#define STR0028 "Production order [VAR01]"
		#define STR0029 "Sequence [VAR01]"
		#define STR0030 "Product [VAR01]"
		#define STR0031 "Batch [VAR01]"
		#define STR0032 "Sub-batch [VAR01]"
		#define STR0033 "Quantity [VAR01]"
		#define STR0034 "SUMMARY OF DIVERGENCY(IES)"
		#define STR0035 "WMS INTEGRATED OP(S) SUMMARY"
	#else
		#define STR0001 "Prevista"
		#define STR0002 "Em Aberto"
		#define STR0003 "Iniciada"
		#define STR0004 "Ociosa"
		#define STR0005 "Encerrada Parcialmente"
		#define STR0006 "Encerrada Totalmente"
		#define STR0007 "Pesquisar"
		#define STR0008 "Visualizar"
		#define STR0009 "Gerar Requisi��o"
		#define STR0010 "Estornar Requisi��o"
		#define STR0011 "Ordem de Produ��o"
		#define STR0012 "Aguarde"
		#define STR0013 "Processando"
		#define STR0014 "OP [VAR01] j� requisitada ou n�o h� itens � requisitar!"
		#define STR0015 "OP [VAR01] n�o possui ordem de servi�o de requisi��o gerada!"
		#define STR0016 "Ordem de produ��o n�o informada!"
		#define STR0017 "Armaz�m padr�o n�o informado no cadastro do produto (SB1)!"
		#define STR0018 "Endere�o destino n�o informado no cadastro de complementos do produto (SB5)!"
		#define STR0019 "Servi�o WMS n�o informado no cadatro de complementos do produto (SB5)!"
		#define STR0020 "N�o h� saldo dispon�vel para atender a requisi��o!"
		#define STR0021 "Quantidade empenhada"
		#define STR0022 "Ordem de servi�o [VAR01] gerada"
		#define STR0023 "Ordem de servi�o [VAR01] exclu�da!"
		#define STR0024 "A ordem de servi�o [VAR01] n�o pode ser estornada, requisi�ao j� possui baixa!"
		#define STR0025 "A ordem de servi�o [VAR01] dever� ser estornada manualmente no WMS."
		#define STR0026 "A ordem de servi�o [VAR01] n�o pode ser estornada, existem requisi�oes baixadas!"
		#define STR0027 "Ordem Servi�o [VAR01] alterada!"
		#define STR0028 "Ordem de produ��o [VAR01]"
		#define STR0029 "Sequ�ncia [VAR01]"
		#define STR0030 "Produto [VAR01]"
		#define STR0031 "Lote [VAR01]"
		#define STR0032 "Sub-lote [VAR01]"
		#define STR0033 "Quantidade [VAR01]"
		#define STR0034 "RESUMO DA(S) DIVERG�NCIA(S)"
		#define STR0035 "RESUMO OP(S) INTEGRADA(S) WMS"
	#endif
#endif
