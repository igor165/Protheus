#ifdef SPANISH
	#define STR0001 'Monitoreo de la e-CL-SEFAZ'
	#define STR0002 'Generacion de e-CL'
	#define STR0003 'Estatus'
	#define STR0004 '1-Con portada'
	#define STR0005 '2-Sin portada'
	#define STR0006 '3-Todas'
	#define STR0007 'Portada de lote'
	#define STR0008 'De Sucursal Origen'
	#define STR0009 'A Sucursal Origen'
	#define STR0010 'Serv. Transporte'
	#define STR0011 'De Viaje'
	#define STR0012 'A Viaje'
	#define STR0013 'Falla al asignar proceso'
	#define STR0014 'Consultando e-mails pendientes. Empresa:'
	#define STR0015 'Sucursal:'
	#define STR0016 'Ejecutando distribución de los e-mails pendientes. Empresa'
	#define STR0017 'Total de DACTES:'
	#define STR0018 'No puede crearse directorio, verifique los permisos de la carpeta del entorno. Error:'
	#define STR0019 'Fuente de impresión de DACTE no compilado. Acceda al portal del cliente y descargue los fuentes RTMSR35.PRW y compile en su entorno'
	#define STR0020 'No fue posible generar la DACTE para Empresa:'
	#define STR0021 'dacte:'
#else
	#ifdef ENGLISH
		#define STR0001 'CLe-SEFAZ Monitoring'
		#define STR0002 'Generate CL-e'
		#define STR0003 'Status'
		#define STR0004 'XXXX'
		#define STR0005 'XXXXXX'
		#define STR0006 '3-All'
		#define STR0007 'Lot Cover'
		#define STR0008 'Origin Branch from'
		#define STR0009 'Origin Branch to'
		#define STR0010 'Transportation Serv.'
		#define STR0011 'Trip From'
		#define STR0012 'Trip To'
		#define STR0013 'Error when allocating process'
		#define STR0014 'Querying pending e-mails. Company:'
		#define STR0015 'Branch:'
		#define STR0016 'Executing distribution of pending e-mails. Company:'
		#define STR0017 'DACTES Total:'
		#define STR0018 'Unable to create directory. Check environment folder permissions. Error:'
		#define STR0019 'DACTE printing source not compiled! Access the Customer Portal, download source codes RTMSR35.PRW and compile them in your environment'
		#define STR0020 'Unable to generate DACTE for Company:'
		#define STR0021 'dacte:'
	#else
		#define STR0001 'Monitoramento da CLe-SEFAZ'
		#define STR0002 'Gerar CL-e'
		#define STR0003 If( cPaisLoc $ "ANG|PTG", 'Estado', 'Status' )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", '1-Com capa', '1-Capeada' )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", '2-Sem capa', '2-Não Capeada' )
		#define STR0006 '3-Todas'
		#define STR0007 If( cPaisLoc $ "ANG|PTG", 'Capa de lote', 'Capa de Lote' )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", 'De filial origem', 'Filial Origem De' )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", 'Até filial origem', 'Filial Origem Ate' )
		#define STR0010 'Serv. Transporte'
		#define STR0011 If( cPaisLoc $ "ANG|PTG", 'De viagem', 'Viagem De' )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", 'Até viagem', 'Viagem Ate' )
		#define STR0013 'Falha ao alocar processo'
		#define STR0014 'Consultando E-mails pendentes. Empresa: '
		#define STR0015 ' Filial: '
		#define STR0016 'Excutando distribuicao dos E-mails pendentes. Empresa: '
		#define STR0017 ' Total de DACTES: '
		#define STR0018 'Diretorio nao pode ser criado, verIfique as permissoes da pasta do ambiente. Erro: '
		#define STR0019 'Fonte de impressao de DACTE nao compilado! Acesse o portal do cliente, baixe os fontes RTMSR35.PRW e compile em seu ambiente'
		#define STR0020 'Nao foi possivel gerar a DACTE para Empresa: '
		#define STR0021 ' dacte: '
	#endif
#endif
