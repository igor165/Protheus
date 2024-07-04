#ifdef SPANISH
	#define STR0001 "Atención"
	#define STR0002 "OK"
	#define STR0003 "Emisión de Timbres Fiscales - Facturación -"
	#define STR0004 "Factura + Serie"
	#define STR0005 "Loja + Cliente + Factura + Serie"
	#define STR0006 "Fecha emisión"
	#define STR0007 "Status"
	#define STR0008 "Factura"
	#define STR0009 "Serie"
	#define STR0010 "Fecha Emis"
	#define STR0011 "Loja "
	#define STR0012 "Cliente"
	#define STR0013 "Nombre"
	#define STR0014 "Leyenda"
	#define STR0015 "Emisión de Timbres Fiscales"
	#define STR0016 "Generada"
	#define STR0017 "Pendiente"
	#define STR0018 "Ok"
	#define STR0019 "Atención"
	#define STR0020 "El timbre para esta factura ya fue generado"
	#define STR0021 "Es necesario seleccionar al menos una factura"
	#define STR0022 "No se encontró el archivo u ocurrió un error..."
	#define STR0023 "Se produjo el siguiente error: "
	#define STR0024 ", no se generó el timbre..."
	#define STR0025 "No se encontró la factura "
	#define STR0026 ", no es posible continuar con el timbrado."
	#define STR0027 "No se generaron timbres fiscales"
	#define STR0028 "Algunos campos necesarios no han sido creados.  Favor de ejecutar la rutina de actualización (UPDMODMI) que crea los campos."
	#define STR0029 "Se generó 1 timbre fiscal"
	#define STR0030 "Se generaron #nTimbres# timbres fiscales"
	#define STR0031 "Archivo XML no válido"
	#define STR0032 "No existe el cliente de servicio web:"
	#define STR0033 "Especie"
	#define STR0034 "Faltan parámetros por definir para este proceso"
	#define STR0035 "La ruta del ejecutable de timbrado no es válida"
	#define STR0036 "Marcar Todos"
	#define STR0037 "Desmarcar Todos"
	#define STR0038 "Invierte Selección"
	#define STR0039 "Buscar"
	#define STR0040 "No se encontraron facturas para timbrar.    Revise los parámetros de selección."
	#define STR0041 "No es posible crear un archivo temporal en la ruta "
#else
	#ifdef ENGLISH
		#define STR0001 "Attention"
		#define STR0002 "OK"
		#define STR0003 "Issue of Fiscal Stamps - Invoicing -"
		#define STR0004 "Invoice + Series"
		#define STR0005 "Store + Customer + Invoice + Series"
		#define STR0006 "Issue Date"
		#define STR0007 "Status"
		#define STR0008 "Invoice"
		#define STR0009 "Series"
		#define STR0010 "Issue Date"
		#define STR0011 "Store"
		#define STR0012 "Customer"
		#define STR0013 "Name"
		#define STR0014 "Caption"
		#define STR0015 "Issue of Fiscal Stamps"
		#define STR0016 "Generated"
		#define STR0017 "Pending"
		#define STR0018 "Ok"
		#define STR0019 "Attention"
		#define STR0020 "xxxxxxxxxxxxxxxx"
		#define STR0021 "Select at least one invoice"
		#define STR0022 "No file was found or an error occurred..."
		#define STR0023 "The following error occurred:"
		#define STR0024 ", stamp not generated..."
		#define STR0025 "No invoice found"
		#define STR0026 ", unable to continue stamping."
		#define STR0027 "No fiscal stamps were generated"
		#define STR0028 "Some necessary fields were not created. Please, run the update routine (UPDMODMI) to create fields."
		#define STR0029 "1 fiscal stamp was created"
		#define STR0030 "#nTimbres# fiscal stamps generated"
		#define STR0031 "XML file invalid"
		#define STR0032 "No web service client:"
		#define STR0033 "Class"
		#define STR0034 "There are no parameters enough to define this process"
		#define STR0035 "The path of the stamping executable is invalid"
		#define STR0036 "Select All"
		#define STR0037 "Uncheck All"
		#define STR0038 "Revert Selection"
		#define STR0039 "Search"
		#define STR0040 "No invoices found for stamping. Confirm selection parameters."
		#define STR0041 "Unable to create a temporary file in the path"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0002 "OK"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Emisión de Timbres Fiscales - Facturación -", "Emissão de Selos Fiscais - Faturamento -" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Factura + Serie", "Nota Fiscal + Série" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Loja + Cliente + Factura + Serie", "Loja + Cliente + Nota Fiscal + Série" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Fecha emisión", "Data de Emissão" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Status", "Estatus" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Factura", "Nota Fiscal" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Serie", "Série" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Fecha Emis", "Data Emis" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Loja ", "Loja" )
		#define STR0012 "Cliente"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Nombre", "Nome" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Leyenda", "Legenda" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Emisión de Timbres Fiscales", "Emissão de Selos Fiscais" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Generada", "Gerada" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Pendiente", "Pendente" )
		#define STR0018 "Ok"
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "El timbre para esta factura ya fue generado", "O selo para esta nota fiscal ya foi gerado" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Es necesario seleccionar al menos una factura", "É necessário selecionar pelo menos uma nota fiscal" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "No se encontró el archivo u ocurrió un error...", "Não foi encontrado do arquivo ou ocorreu um erro..." )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Se produjo el siguiente error: ", "Ocorreu o seguinte erro:" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", ", no se generó el timbre...", ", não foi gerado o selo..." )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "No se encontró la factura ", "Não foi encontrada a nota fiscal" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", ", no es posible continuar con el timbrado.", ", não é possível prosseguir com a selagem." )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "No se generaron timbres fiscales", "Não forão gerados os selos fiscais" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Algunos campos necesarios no han sido creados.  Favor de ejecutar la rutina de actualización (UPDMODMI) que crea los campos.", "Alguns campos necessários não foram criados. Por favor, execute a rotina de atualização (UPDMODMI) que cria os campos." )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Se generó 1 timbre fiscal", "Foi gerado 1 selo fiscal" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Se generaron #nTimbres# timbres fiscales", "Foram gerados #nTimbres# selos fiscais" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Archivo XML no válido", "Arquivo XML inválido" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "No existe el cliente de servicio web:", "Não existe o cliente de serviço web:" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Especie", "Classe" )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "Faltan parámetros por definir para este proceso", "Faltam parâmetros a definir para este processo" )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "La ruta del ejecutable de timbrado no es válida", "O caminho do executável da selagem é inválido" )
		#define STR0036 "Marcar Todos"
		#define STR0037 "Desmarcar Todos"
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "Invierte Selección", "Reverter Seleção" )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Buscar", "Pesquisar" )
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "No se encontraron facturas para timbrar.    Revise los parámetros de selección.", "Não foram encontradas as notas fiscais para selagem. Confirmar os parâmetros de seleção." )
		#define STR0041 If( cPaisLoc $ "ANG|PTG", "No es posible crear un archivo temporal en la ruta ", "Não é possível criar um arquivo temporário no caminho" )
	#endif
#endif
