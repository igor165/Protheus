#ifdef SPANISH
	#define STR0001 "Verificacion de Recoleccion"
	#define STR0002 "Buscar"
	#define STR0003 "Visualizar"
	#define STR0004 "Incluir"
	#define STR0005 "Modificar"
	#define STR0006 "Borrar"
	#define STR0007 "Leyenda"
	#define STR0008 "Estatus"
	#define STR0009 "Pendiente"
	#define STR0010 "Finalizada"
	#define STR0011 "Solicitudes de Recoleccion"
	#define STR0012 "Ya existe un documento informado para esta solicitud de recolecci�n, por lo tanto, no se permitir� el borrado."
	#define STR0013 "Esta solicitud de recolecci�n ya se inform�."
	#define STR0014 "Lectura C�d. de barras"
	#define STR0015 "Informe el c�digo de barras"
	#define STR0016 "Procesa e-Fact"
	#define STR0017 "Realizando comunicaci�n con el Fisco"
	#define STR0018 "Procesando"
#else
	#ifdef ENGLISH
		#define STR0001 "Pickup check "
		#define STR0002 "Search "
		#define STR0003 "View "
		#define STR0004 "Add "
		#define STR0005 "Edit "
		#define STR0006 "Delete "
		#define STR0007 "Caption"
		#define STR0008 "Status"
		#define STR0009 "Pending "
		#define STR0010 "Finished "
		#define STR0011 "Pickup requests "
		#define STR0012 "A Document already exists for this Collection Request, so deletion will not be allowed."
		#define STR0013 "This collection request was already entered."
		#define STR0014 "Barcode reading"
		#define STR0015 "Enter the barcode"
		#define STR0016 "Process NF-e"
		#define STR0017 "Communicating with SEFAZ"
		#define STR0018 "Processing"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Acordo De Recolha", "Confer�ncia de Coleta" )
		#define STR0002 "Pesquisar"
		#define STR0003 "Visualizar"
		#define STR0004 "Incluir"
		#define STR0005 "Alterar"
		#define STR0006 "Excluir"
		#define STR0007 "Legenda"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Estado", "Status" )
		#define STR0009 "Em Aberto"
		#define STR0010 "Encerrada"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Solicita��es Da Recolha", "Solicita��es de Coleta" )
		#define STR0012 "J� existe um Documento informado para essa Solicita��o de Coleta, portanto n�o ser� permitido a exclus�o."
		#define STR0013 "Esta solicita��o de coleta j� foi informada."
		#define STR0014 "Leitura C�d. de Barras"
		#define STR0015 "Informe o c�digo de barras"
		#define STR0016 "Processa NF-e"
		#define STR0017 "Realizando comunica��o com a SEFAZ"
		#define STR0018 "Processando"
	#endif
#endif
