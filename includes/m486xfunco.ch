#ifdef SPANISH
	#define STR0001 "Procesado Correctamente"
	#define STR0002 "Producción"
	#define STR0003 "Pruebas"
	#define STR0004 "Documento No Transmitido"
	#define STR0005 "Documento Recibido"
	#define STR0006 "Esperando procesamiento DIAN"
	#define STR0007 "Documento autorizado DIAN"
	#define STR0008 "Transmision Electrónica de Documentos"
	#define STR0009 "Leyenda"
	#define STR0010 "Ocurrio un error de actualización del estatus en la plataforma del Proveedor Tecnológico."
#else
	#ifdef ENGLISH
		#define STR0001 "Processed correctly"
		#define STR0002 "Production"
		#define STR0003 "Tests"
		#define STR0004 "Document not transmitted"
		#define STR0005 "Document received"
		#define STR0006 "Waiting for DIAN processing"
		#define STR0007 "Authorized DIAN document"
		#define STR0008 "Electronic document transmission"
		#define STR0009 "Caption"
		#define STR0010 "A status update error has occurred on the platform of the Technology Provider."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Procesado Correctamente", "Processado corretamente" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Producción", "Produção" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Pruebas", "Testes" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Documento No Transmitido", "Documento Não Transmitido" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Documento Recibido", "Documento Recebido" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Esperando procesamiento DIAN", "Aguardando Processamento DIAN" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Documento autorizado DIAN", "Documento Autorizado DIAN" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Transmision Electrónica de Documentos", "Transmissão Eletrônica de Documentos" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Leyenda", "Legenda" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Ocurrio un error de actualización del estatus en la plataforma del Proveedor Tecnológico.", "Ocorreu um erro de atualização do status na plataforma do Fornecedor Tecnológico." )
	#endif
#endif
