#ifdef SPANISH
	#define STR0001 "N/Exportación Nº"
	#define STR0002 "Nº R. E."
	#define STR0003 "Para"
	#define STR0004 "Transportadora"
	#define STR0005 "Despachante"
	#define STR0006 "Nº Fact"
	#define STR0007 "Trucker"
	#define STR0008 "Vessel"
	#define STR0009 "ETA    "
	#define STR0010 "Agencia   "
	#define STR0011 "Transporte"
	#define STR0012 "C/Copia"
	#define STR0013 "Minuta de B/L"
	#define STR0014 "Shipper"
	#define STR0015 "Tel.  "
	#define STR0016 " / Fax "
	#define STR0017 "L/C NBR"
	#define STR0018 "I/L NBR"
	#define STR0019 "Marks"
	#define STR0020 "Constar en el cuerpo de la"
	#define STR0021 "Factura"
	#define STR0022 "Observaciones"
	#define STR0023 "Emitir Facturas (03) originales y (10) copias"
	#define STR0024 "Atentamente,"
	#define STR0025 "Agente"
	#define STR0026 "Notificación"
	#define STR0027 "Tipo"
	#define STR0028 "Código"
	#define STR0029 "Descripción"
	#define STR0030 "Contactos"
	#define STR0031 "Agentes"
	#define STR0032 "Observaciones"
	#define STR0033 "Contacto 1 "
	#define STR0034 "Contacto 2 "
	#define STR0035 "Contacto 3 "
	#define STR0036 "¡Ya existen dos agentes seleccionados!"
	#define STR0037 "Aviso"
	#define STR0038 "Sacas"
	#define STR0039 "Granel"
	#define STR0040 "Contenedores"
	#define STR0041 "Otro"
	#define STR0042 "Arábica"
	#define STR0043 "Robusta"
	#define STR0044 "Torrado"
	#define STR0045 "Soluble"
	#define STR0046 "Otros"
	#define STR0047 "Vía seca (No lavado)"
	#define STR0048 "Vía húmeda (Lavado)"
	#define STR0049 "Descafeinado"
	#define STR0050 "Orgánico"
	#define STR0051 "Medio de transporte/Descripción del café"
	#define STR0052 "Transporte"
	#define STR0053 "Marca de IOC"
	#define STR0054 "Desc. Café"
	#define STR0055 "Método Proc."
	#define STR0056 "Unidad de peso"
	#define STR0057 "Códigos"
	#define STR0058 "Exportador"
	#define STR0059 "País de transbordo"
	#define STR0060 "Medio de transporte"
	#define STR0061 "Puerto de origen"
	#define STR0062 "País de origen"
	#define STR0063 "País de destino"
	#define STR0064 "Otra información"
	#define STR0065 "¡No se seleccionó ninguna notificación!"
	#define STR0066 "Atención"
#else
	#ifdef ENGLISH
		#define STR0001 "N/Export No."
		#define STR0002 "R.E. No."
		#define STR0003 "To"
		#define STR0004 "Carrier"
		#define STR0005 "Forwarding Agent"
		#define STR0006 "Inv. Num."
		#define STR0007 "Trucker"
		#define STR0008 "Vessel"
		#define STR0009 "ETA    "
		#define STR0010 "Agency   "
		#define STR0011 "Transport"
		#define STR0012 "W/Copy"
		#define STR0013 "B/L Minute"
		#define STR0014 "Shipper"
		#define STR0015 "Phone  "
		#define STR0016 " / Fax "
		#define STR0017 "NBR L/C"
		#define STR0018 "NBR I/L"
		#define STR0019 "Marks"
		#define STR0020 "Found in body of"
		#define STR0021 "INVOICE"
		#define STR0022 "Notes"
		#define STR0023 "Issue Invoices in (03) copies and (10) copies"
		#define STR0024 "Sincerely,"
		#define STR0025 "Agent"
		#define STR0026 "Notify"
		#define STR0027 "Type"
		#define STR0028 "Code"
		#define STR0029 "Description"
		#define STR0030 "Contacts"
		#define STR0031 "Agents"
		#define STR0032 "Notes"
		#define STR0033 "Contact 1"
		#define STR0034 "Contact 2"
		#define STR0035 "Contact 3 "
		#define STR0036 "Two agents are already selected!"
		#define STR0037 "Warning"
		#define STR0038 "Sacks"
		#define STR0039 "Bulk"
		#define STR0040 "Containers"
		#define STR0041 "Other"
		#define STR0042 "Arabian"
		#define STR0043 "Strong"
		#define STR0044 "Toasted"
		#define STR0045 "Soluble"
		#define STR0046 "Others"
		#define STR0047 "Dry Via (Not Washed)"
		#define STR0048 "Humid Via (Washed)"
		#define STR0049 "Decafeinated"
		#define STR0050 "Organic"
		#define STR0051 "Mean of Transp./Coffee Description"
		#define STR0052 "Transport"
		#define STR0053 "IOC Brand"
		#define STR0054 "Coffee Desc."
		#define STR0055 "Proc. Method"
		#define STR0056 "Weight Unit"
		#define STR0057 "Codes"
		#define STR0058 "Exporter"
		#define STR0059 "Transshipment Country"
		#define STR0060 "Means of Transportation"
		#define STR0061 "Source Harbor"
		#define STR0062 "Source Country"
		#define STR0063 "Target Country"
		#define STR0064 "Other Information"
		#define STR0065 "No Notification was selected !"
		#define STR0066 "Warning"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "N/exportação Nº", "N/Exportação Nº." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Núm. R.e.", "Nro. R.E." )
		#define STR0003 "Para"
		#define STR0004 "Transportadora"
		#define STR0005 "Despachante"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Núm. Fact", "Nº NF" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Camionista", "Trucker" )
		#define STR0008 "Vessel"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Eta    ", "ETA    " )
		#define STR0010 "Agência   "
		#define STR0011 "Transporte"
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "C/cópia", "C/Cópia" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Minuta De B/l", "Minuta de B/L" )
		#define STR0014 "Shipper"
		#define STR0015 "Tel  "
		#define STR0016 If( cPaisLoc $ "ANG|PTG", " / fax ", " / Fax " )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "L/c Nbr", "L/C NBR" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "I/l Nbr", "I/L NBR" )
		#define STR0019 "Marks"
		#define STR0020 "Constar no corpo da"
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Factura", "Nota Fiscal" )
		#define STR0022 "Observações"
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Emitir facturas em (03) originais e (10) cópias", "Emitir Notas Fiscais em (03) vias e (10) cópias" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Atentamente,", "Atenciosamente," )
		#define STR0025 "Agente"
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Notifique", "Notificação" )
		#define STR0027 "Tipo"
		#define STR0028 "Código"
		#define STR0029 "Descrição"
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Contactos", "Contatos" )
		#define STR0031 "Agentes"
		#define STR0032 "Observações"
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Contacto 1 ", "Contato 1 " )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "Contacto 2 ", "Contato 2 " )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "Contacto 3 ", "Contato 3 " )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Já existem dois agentes seleccionados !", "Já existem dois agentes selecionados!" )
		#define STR0037 "Aviso"
		#define STR0038 "Sacas"
		#define STR0039 "Granel"
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "Contentores", "Containers" )
		#define STR0041 "Outro"
		#define STR0042 "Arábica"
		#define STR0043 "Robusta"
		#define STR0044 "Torrado"
		#define STR0045 "Solúvel"
		#define STR0046 "Outros"
		#define STR0047 If( cPaisLoc $ "ANG|PTG", "Via Seca (não Lavado)", "Via Seca (Não Lavado)" )
		#define STR0048 If( cPaisLoc $ "ANG|PTG", "Via húmida (lavado)", "Via Úmida (Lavado)" )
		#define STR0049 If( cPaisLoc $ "ANG|PTG", "Descafeínado", "Descafeinado" )
		#define STR0050 "Orgânico"
		#define STR0051 If( cPaisLoc $ "ANG|PTG", "Meio Transporte/descrição Do Café", "Meio Transporte/Descrição do Café" )
		#define STR0052 "Transporte"
		#define STR0053 If( cPaisLoc $ "ANG|PTG", "Marca Da Ioc", "Marca da IOC" )
		#define STR0054 If( cPaisLoc $ "ANG|PTG", "Desc. café", "Desc.Café" )
		#define STR0055 "Método Proc."
		#define STR0056 If( cPaisLoc $ "ANG|PTG", "Unidade De Peso", "Unidade de Peso" )
		#define STR0057 If( cPaisLoc $ "ANG|PTG", "Código s", "Códigos" )
		#define STR0058 "Exportador"
		#define STR0059 If( cPaisLoc $ "ANG|PTG", "País De Transbordo", "País de Transbordo" )
		#define STR0060 If( cPaisLoc $ "ANG|PTG", "Meio De Transporte", "Meio de Transporte" )
		#define STR0061 If( cPaisLoc $ "ANG|PTG", "Porto De Origem", "Porto de Origem" )
		#define STR0062 If( cPaisLoc $ "ANG|PTG", "País De Origem", "País de Origem" )
		#define STR0063 If( cPaisLoc $ "ANG|PTG", "País De Destino", "País de Destino" )
		#define STR0064 If( cPaisLoc $ "ANG|PTG", "Outros Dados", "Outras Informações" )
		#define STR0065 If( cPaisLoc $ "ANG|PTG", "Nenhuma notificação foi seleccionada !", "Nenhuma notificação foi selecionada!" )
		#define STR0066 "Atenção"
	#endif
#endif
