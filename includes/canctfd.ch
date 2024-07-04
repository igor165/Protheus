#ifdef SPANISH
	#define STR0001 "Anulación de timbres fiscales de Recibos de Nómina"
	#define STR0002 "Matricula"
	#define STR0003 "Nombre"
	#define STR0004 "Buscar"
	#define STR0005 "UUID"
	#define STR0006 "Marcar Todos"
	#define STR0007 "Desmarcar Todos"
	#define STR0008 "Invertir seleccion"
	#define STR0009 "Parametros"
	#define STR0010 "Atencion"
	#define STR0011 "No se encontraron recibos con timbre fiscal."
	#define STR0012 "OK"
	#define STR0013 "Procesando anulación de timbre fiscal de los recibos seleccionados."
	#define STR0014 "Obteniendo lista de recibos con timbre fiscal. Por favor, espere..."
	#define STR0015 "No se encontraron recibos para anular."
	#define STR0016 "No se seleccionó ningún recibo para anular."
	#define STR0017 "No se anularon folios fiscales."
	#define STR0018 "Se anuló 1 folio fiscal."
	#define STR0019 "Se anularon #nTimbres# folios fiscales."
	#define STR0020 "Sucursal"
	#define STR0021 "Hay parámetros sin definir para el proceso de timbrado."
	#define STR0022 "La ruta del ejecutable de timbrado no es válida."
	#define STR0023 "No hay el ejecutable para acceder al servicio web:"
	#define STR0024 "No se puede crear el archivo temporal en el directorio."
	#define STR0025 "Verificando anulación de folios fiscales de recibos... "
	#define STR0026 "No se encuentra respuesta de cancelación del recibo"
	#define STR0027 "No se pudo anular el folio fiscal del recibo"
	#define STR0028 "Hay errores. Revise el log en el directorio:"
	#define STR0029 "No fue posible crear el archivo. Error: "
#else
	#ifdef ENGLISH
		#define STR0001 "Cancellation Revenue stamps payroll receipts"
		#define STR0002 "Registration"
		#define STR0003 "Name"
		#define STR0004 "Search"
		#define STR0005 "UUID"
		#define STR0006 "Select All"
		#define STR0007 "Uncheck All"
		#define STR0008 "Invert Selection"
		#define STR0009 "Parameters"
		#define STR0010 "Attention"
		#define STR0011 "No revenue stamp receipts found."
		#define STR0012 "OK"
		#define STR0013 "Processing revenue stamp cancellation of selected receipts."
		#define STR0014 "Getting list of receipts with revenue stamp. Please wait..."
		#define STR0015 "Receipts to cancel were not found."
		#define STR0016 "No receipt selected to cancel."
		#define STR0017 "No tax folios canceled."
		#define STR0018 "1 tax folio canceled."
		#define STR0019 "Canceled #nSelos# tax folios."
		#define STR0020 "Branch"
		#define STR0021 "There are parameters not set for the stamping procedure."
		#define STR0022 "The executable path to the stamp is invalid."
		#define STR0023 "There is no executable file to access web service:"
		#define STR0024 "Unable to create a temporary register in the directory."
		#define STR0025 "Checking receipts tax folio cancellation..."
		#define STR0026 "No receipt cancellation response"
		#define STR0027 "Unable to cancel receipt tax folio"
		#define STR0028 "There are errors. Review Query log:"
		#define STR0029 "Unable to create file. Error:"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Anulación de timbres fiscales de Recibos de Nómina", "Cancelam. Selos fiscais Recibos Folha de Pag." )
		#define STR0002 "Matricula"
		#define STR0003 "Nome"
		#define STR0004 "Buscar"
		#define STR0005 "UUID"
		#define STR0006 "Marcar Todos"
		#define STR0007 "Desmarcar Todos"
		#define STR0008 "Inverter Seleção"
		#define STR0009 "Parametros"
		#define STR0010 "Atenção"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "No se encontraron recibos con timbre fiscal.", "Não foram encontrados recibos com selo fiscal." )
		#define STR0012 "OK"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Procesando anulación de timbre fiscal de los recibos seleccionados.", "Processando cancelamento de selo fiscal dos recibos selecionados." )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Obteniendo lista de recibos con timbre fiscal. Por favor, espere...", "Obtendo lista de recibos com selo fiscal. Por favor, aguarde..." )
		#define STR0015 "Nao foram encontrados recibos para cancelar."
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "No se seleccionó ningún recibo para anular.", "Não foi selecionado nenhum recibo para cancelar." )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "No se anularon folios fiscales.", "Não foram cancelados fólios fiscais." )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Se anuló 1 folio fiscal.", "Cancelado 1 fólio fiscal." )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Se anularon #nTimbres# folios fiscales.", "Cancelados #nSelos# fólios fiscais." )
		#define STR0020 "Filial"
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Hay parámetros sin definir para el proceso de timbrado.", "Há parâmetros sem definir para o processo de selagem." )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "La ruta del ejecutable de timbrado no es válida.", "O caminho do executável para o selo é inválido." )
		#define STR0023 "Nao existe ol executavel para acessar o serviço web:"
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "No se puede crear el archivo temporal en el directorio.", "Não é possível criar o cadastro temporário no diretório." )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Verificando anulación de folios fiscales de recibos... ", "Conferindo cancelamento de fólios fiscais de recibos..." )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "No se encuentra respuesta de cancelación del recibo", "Não se encontrou resposta de cancelamento do recibo" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "No se pudo anular el folio fiscal del recibo", "Não foi possível cancelar o fólio fiscal do recibo" )
		#define STR0028 "Existe erros. Revise o log no diretorio:"
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "No fue posible crear el archivo. Error: ", "Não foi possível criar o arquivo. Erro:" )
	#endif
#endif
