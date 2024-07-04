#ifdef SPANISH
	#define STR0001 "Visualizar PDF/XML"
	#define STR0002 "Cargar Listado 69-B"
	#define STR0003 "Esta función tiene como objetivo cargar el listado de contribuyentes que desvirtuaron"
	#define STR0004 "la presunción de inexistencia de operaciones ante el SAT, a través de la emisión de "
	#define STR0005 "facturas  o comprobantes fiscales. (Artículo 69-B del Código Fiscal de la Federación)"
	#define STR0006 "Importante: Cada que se ejecute el proceso se actualizara el listado por completo de"
	#define STR0007 "acuerdo al contenido del archivo "
	#define STR0008 "Ruta del archivo: "
	#define STR0009 "Carga del Listado 69-B"
	#define STR0010 "Existe información en el listado 69-B. ¿Desea continuar para cargar nuevamente?"
	#define STR0011 "Descargando el Listado 69-B..."
	#define STR0012 "Actualizando el Listado 69-B..."
	#define STR0013 "No se encontró el archivo: "
	#define STR0014 "No se indicó el parámetro con la ruta que contiene el archivo .CSV"
	#define STR0015 "No se puede leer el archivo "
	#define STR0016 "Registros insertados: "
	#define STR0017 "El documento XML es invalido, verifique!"
	#define STR0018 "-Elemento UUID (nodo tfd:TimbreFiscalDigital)"
	#define STR0019 "-Elemento Número de Certificado SAT (nodo tfd:TimbreFiscalDigital)"
	#define STR0020 "-Elemento Fecha de Timbrado (nodo tfd:TimbreFiscalDigital)"
	#define STR0021 "-Nodo Timbre Fiscal (tfd:TimbreFiscalDigital)"
	#define STR0022 "-Elemento RFC del Emisor (nodo cfdi:Emisor)"
	#define STR0023 "-Nodo de datos del Emisor (cfdi:Emisor)"
	#define STR0024 "-Elemento RFC del Receptor (nodo cfdi:Receptor)"
	#define STR0025 "-Nodo de datos del Receptor (cfdi:Receptor)"
	#define STR0026 "-Nodo Comprobante (cfdi:Comprobante)"
	#define STR0027 "El XML no tiene la estructura necesaria para obtener los datos:"
	#define STR0028 "El Folio Fiscal ya fue utilizado para la factura: "
	#define STR0029 "Proveedor"
	#define STR0030 "Cliente"
	#define STR0031 "El RFC de la empresa (###) no coincide con el RFC del Receptor del documento XML ("
	#define STR0032 "El RFC del Proveedor (###) no coincide con el RFC del Receptor del documento XML ("
	#define STR0033 "-El elemento RFC del nodo Emisor se encuentra vacío."
	#define STR0034 "-Nodo Complemento (cfdi:Complemento)"
	#define STR0035 "¿Desea continuar?"
	#define STR0036 "Situación: "
	#define STR0037 " Fec. Pres.: "
	#define STR0038 " Fec. Desv.: "
	#define STR0039 " Fec. Def.: "
	#define STR0040 " Fec. Sent. Fav.: "
	#define STR0041 "No se tiene configurada la URL para descarga del archivo Listado69b.csv (MV_WSRTSS)."
	#define STR0042 "No se tienen configuradas todas las posiciones para los datos a actualizar a partir del archivo Listado69B.cvs (MV_IDCBAJA):"
	#define STR0043 "-RFC"
	#define STR0044 "-Situación"
	#define STR0045 "-Fecha Publicación de Presunto"
	#define STR0046 "-Fecha Publicación de Desvirtuado"
	#define STR0047 "-Fecha Publicación de Definitivo"
	#define STR0048 "-Fecha Publicación de Sentencia Favorable"
	#define STR0049 "No existe la tabla Listado 69-B (MB0) o no contiene registros, ejecute la acción Cargar Listado 69-B desde Otras acciones de la rutina de Facturas de Entrada (MATA101N)"
	#define STR0050 "-El elemento RFC del nodo Receptor se encuentra vacío."
	#define STR0051 "-El Elemento UUID del nodo TimbreFiscalDigital se encuentra vacío."
	#define STR0052 "-El Elemento Timbre Fiscal del nodo TimbreFiscalDigital se encuentra vacío."
	#define STR0053 "-El Elemento No. Certificado SAT del nodo TimbreFiscalDigital se encuentra vacío."
	#define STR0054 "El RFC del Emisor (###) existe en el listado de contribuyentes que desvirtuaron la presunción de inexistencia de operaciones ante el SAT: "
	#define STR0055 "No existe creada la tabla Listado 69-B (MB0)."
	#define STR0056 "¡Archivo no seleccionado!"
	#define STR0057 "El UUID del documento seleccionado no corresponde con el UUID informado, seleccione el archivo nuevamente."
	#define STR0058 "Serie"
	#define STR0059 "Especie"
	#define STR0060 "Núm.Doc"
	#define STR0061 "El Folio Fiscal ya fue utilizado en el siguiente documento: "
#else
	#ifdef ENGLISH
		#define STR0001 "View PDF/XML"
		#define STR0002 "Load List 69-B"
		#define STR0003 "This function aims to load the list of taxpayers who distorted"
		#define STR0004 "the presumption that there were no transactions before the SAT, by issuing"
		#define STR0005 "invoices or tax receipts. (Article 69-B of the Federal Fiscal Code)"
		#define STR0006 "Important: Each time the process is executed, the list will be updated"
		#define STR0007 "according to the content of the register"
		#define STR0008 "Path of register:"
		#define STR0009 "Load of List 69-B"
		#define STR0010 "There is information in list 69-B. Do you want to upload again?"
		#define STR0011 "Unloading List 69-B..."
		#define STR0012 "Updating List 69-B..."
		#define STR0013 "Register not found:"
		#define STR0014 "The parameter with the path containing the .CSV register was not indicated"
		#define STR0015 "Unable to read register"
		#define STR0016 "Registers included:"
		#define STR0017 "The XML document is not valid. Check it."
		#define STR0018 "- UUID element (nodo tfd:TimbreFiscalDigital)"
		#define STR0019 "- SAT Certificate Number element (nodo tfd:TimbreFiscalDigital)"
		#define STR0020 "- Stamp Date element (nodo tfd:TimbreFiscalDigital)"
		#define STR0021 "- Fiscal stamp node (tfd:TimbreFiscalDigital)"
		#define STR0022 "- Issuer RFC element (nodo cfdi:Emisor)"
		#define STR0023 "- Issuer Data node (nodo cfdi:Emisor)"
		#define STR0024 "- Receiver RFC element (nodo cfdi:Receptor)"
		#define STR0025 "- Receiver Data node (cfdi:Receptor)"
		#define STR0026 "- Statement node (cfdi:Comprobante)"
		#define STR0027 "The XML does not have the necessary structure to obtain the data:"
		#define STR0028 "The Tax Schedule has already been used in invoice:"
		#define STR0029 "Supplier"
		#define STR0030 "Customer"
		#define STR0031 "RFC of the company (###) is not the same as the Receiver RFC of the XML document ("
		#define STR0032 "RFC of the Supplier (###) is not the same as the RFC of the Receiver of the XML document ("
		#define STR0033 "- The RFC element of the Issuer node is empty."
		#define STR0034 "- Complement node (cfdi:Complemento)"
		#define STR0035 "Continue?"
		#define STR0036 "Status:"
		#define STR0037 "Date Pres.:"
		#define STR0038 "Date Desv.:"
		#define STR0039 "Date Def.:"
		#define STR0040 "Date Sent. Fav.:"
		#define STR0041 "The URL for downloading the Listado69b.csv register (MV_WSRTSS) is not configured."
		#define STR0042 "Not all positions are configured for the data to be updated from the List6969.cvs register (MV_IDCBAJA):"
		#define STR0043 "-RFC"
		#define STR0044 "-Status"
		#define STR0045 "-Date Publication of Presumption"
		#define STR0046 "-Date Publication of Distorted"
		#define STR0047 "-Date Publication of Definitive"
		#define STR0048 "-Date Publication of Favorable Sentence"
		#define STR0049 "The List 69-B (AIU) table does not exist or does not contain any records, perform the action Load List 69-B from Other actions of the Incoming Invoice routine (MATA101N)"
		#define STR0050 "- The RFC element of the Receiver node is empty."
		#define STR0051 "- The UUID element of the TimbreFiscalDigital node is empty."
		#define STR0052 "- The Tax Stamp element of the TimbreFiscalDigital node is empty."
		#define STR0053 "- Element no. SAT certificate of the TimbreFiscalDigital node is empty."
		#define STR0054 "The RFC of the Issuer (###) is in the list of taxpayers that have distorted the presumption of non-existence before the SAT:"
		#define STR0055 "Table List 69-B (AIU) does not exist"
		#define STR0056 "Register not selected"
		#define STR0057 "The UUID of the selected document does not match the UUID informed, select the registration again."
		#define STR0058 "Series"
		#define STR0059 "Class"
		#define STR0060 "Doc. Number"
		#define STR0061 "The Fiscal Payroll has already been used in the document:"
	#else
		#define STR0001 "Visualizar PDF/XML"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Cargar Listado 69-B", "Carregar Listado 69-B" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Esta función tiene como objetivo cargar el listado de contribuyentes que desvirtuaron", "Essa função tem como objetivo carregar o listado de contribuintes que desvirtuaram" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "la presunción de inexistencia de operaciones ante el SAT, a través de la emisión de ", "a presunção de inexistência de operações perante o SAT, por meio da emissão de" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "facturas  o comprobantes fiscales. (Artículo 69-B del Código Fiscal de la Federación)", "notas fiscais ou comprovantes fiscais. (Artigo 69-B do Código Fiscal da Federação)" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Importante: Cada que se ejecute el proceso se actualizara el listado por completo de", "Importante: A cada vez que for executado o processo, será atualizado o listado totalmente" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "acuerdo al contenido del archivo ", "segundo o conteúdo do cadastro" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Ruta del archivo: ", "Caminho do cadastro:" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Carga del Listado 69-B", "Carga do Listado 69-B" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Existe información en el listado 69-B. ¿Desea continuar para cargar nuevamente?", "Existe informação no listado 69-B. Deseja prosseguir para carregar novamente?" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Descargando el Listado 69-B...", "Descarregando o Listado 69-B..." )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Actualizando el Listado 69-B...", "Atualizando o Listado 69-B..." )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "No se encontró el archivo: ", "Não foi encontrado o cadastro:" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "No se indicó el parámetro con la ruta que contiene el archivo .CSV", "Não foi indicado o parâmetro com o caminho que contém o cadastro .CSV" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "No se puede leer el archivo ", "Não é possível ler o cadastro" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Registros insertados: ", "Cadastros incluídos:" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "El documento XML es invalido, verifique!", "O documento XML é inválido, confira!" )
		#define STR0018 "-Elemento UUID (nodo tfd:TimbreFiscalDigital)"
		#define STR0019 "-Elemento Número de Certificado SAT (nodo tfd:TimbreFiscalDigital)"
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "-Elemento Fecha de Timbrado (nodo tfd:TimbreFiscalDigital)", "-Elemento Data de Timbrado (nodo tfd:TimbreFiscalDigital)" )
		#define STR0021 "-Nodo Timbre Fiscal (tfd:TimbreFiscalDigital)"
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "-Elemento RFC del Emisor (nodo cfdi:Emisor)", "-Elemento RFC do Emissor (nodo cfdi:Emisor)" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "-Nodo de datos del Emisor (cfdi:Emisor)", "-Nodo de Dados do Emissor (cfdi:Emisor)" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "-Elemento RFC del Receptor (nodo cfdi:Receptor)", "-Elemento RFC do Receptor (nodo cfdi:Receptor)" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "-Nodo de datos del Receptor (cfdi:Receptor)", "-Nodo de Dados do Receptor (cfdi:Receptor)" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "-Nodo Comprobante (cfdi:Comprobante)", "-Nodo Comprovante (cfdi:Comprobante)" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "El XML no tiene la estructura necesaria para obtener los datos:", "O XML não tem a estrutura necessária para obter os dados:" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "El Folio Fiscal ya fue utilizado para la factura: ", "A Folha Fiscal já foi utilizada na nota fiscal:" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Proveedor", "Fornecedor" )
		#define STR0030 "Cliente"
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "El RFC de la empresa (###) no coincide con el RFC del Receptor del documento XML (", "O RFC da empresa (###) não é igual ao RFC do Receptor do documento XML (" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "El RFC del Proveedor (###) no coincide con el RFC del Receptor del documento XML (", "O RFC do emissor (###) que foi informado no XML existe no Listado 69-B" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "-El elemento RFC del nodo Emisor se encuentra vacío.", "O RFC da empresa ### não é igual ao RFC do Receptor do documento XML, RFC:" )
		#define STR0034 "-Nodo Complemento (cfdi:Complemento)"
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "¿Desea continuar?", "Deseja prosseguir?" )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Situación: ", "Situação:" )
		#define STR0037 If( cPaisLoc $ "ANG|PTG", " Fec. Pres.: ", "Dat. Pres.:" )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", " Fec. Desv.: ", "Dat. Desv.:" )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", " Fec. Def.: ", "Dat. Def.:" )
		#define STR0040 If( cPaisLoc $ "ANG|PTG", " Fec. Sent. Fav.: ", "Dat. Sent. Fav.:" )
		#define STR0041 If( cPaisLoc $ "ANG|PTG", "No se tiene configurada la URL para descarga del archivo Listado69b.csv (MV_WSRTSS).", "Não está configurada a URL para a descarga do cadastro Listado69b.csv (MV_WSRTSS)." )
		#define STR0042 If( cPaisLoc $ "ANG|PTG", "No se tienen configuradas todas las posiciones para los datos a actualizar a partir del archivo Listado69B.cvs (MV_IDCBAJA):", "Não estão configuradas todas as posições para os dados a atualizar a partir do cadastro Listado69B.cvs (MV_IDCBAJA):" )
		#define STR0043 "-RFC"
		#define STR0044 If( cPaisLoc $ "ANG|PTG", "-Situación", "-Situação" )
		#define STR0045 If( cPaisLoc $ "ANG|PTG", "-Fecha Publicación de Presunto", "-Data Publicação da Presunção" )
		#define STR0046 If( cPaisLoc $ "ANG|PTG", "-Fecha Publicación de Desvirtuado", "-Data Publicação de Desvirtuado" )
		#define STR0047 If( cPaisLoc $ "ANG|PTG", "-Fecha Publicación de Definitivo", "-Data Publicação de Definitivo" )
		#define STR0048 If( cPaisLoc $ "ANG|PTG", "-Fecha Publicación de Sentencia Favorable", "-Data Publicação de Sentença Favorável" )
		#define STR0049 If( cPaisLoc $ "ANG|PTG", "No existe la tabla Listado 69-B (MB0) o no contiene registros, ejecute la acción Cargar Listado 69-B desde Otras acciones de la rutina de Facturas de Entrada (MATA101N)", "Não existe a tabela Listagem 69-B (AIU) ou não contém registros, execute a ação Carregar Listagem 69-B a partir de Outras ações da rotina Notas Fiscais de Entrada (MATA101N)" )
		#define STR0050 If( cPaisLoc $ "ANG|PTG", "-El elemento RFC del nodo Receptor se encuentra vacío.", "- O elemento RFC do nodo Receptador está vazio." )
		#define STR0051 If( cPaisLoc $ "ANG|PTG", "-El Elemento UUID del nodo TimbreFiscalDigital se encuentra vacío.", "- O elemento UUID do nodo TimbreFiscalDigital está vazio." )
		#define STR0052 If( cPaisLoc $ "ANG|PTG", "-El Elemento Timbre Fiscal del nodo TimbreFiscalDigital se encuentra vacío.", "- O elemento Timbre Fiscal do nodo TimbreFiscalDigital está vazio." )
		#define STR0053 If( cPaisLoc $ "ANG|PTG", "-El Elemento No. Certificado SAT del nodo TimbreFiscalDigital se encuentra vacío.", "- O elemento No. Certificado SAT do nodo TimbreFiscalDigital está vazio." )
		#define STR0054 If( cPaisLoc $ "ANG|PTG", "El RFC del Emisor (###) existe en el listado de contribuyentes que desvirtuaron la presunción de inexistencia de operaciones ante el SAT: ", "O RFC do Emissor (###) existe na listagem de contribuintes que desvirtuaram a presunção de inexistência de operações perante o SAT:" )
		#define STR0055 If( cPaisLoc $ "ANG|PTG", "No existe creada la tabla Listado 69-B (MB0).", "Não existe a tabela Listagem 69-B (AIU)." )
		#define STR0056 If( cPaisLoc $ "ANG|PTG", "¡Archivo no seleccionado!", "Cadastro não selecionado!" )
		#define STR0057 If( cPaisLoc $ "ANG|PTG", "El UUID del documento seleccionado no corresponde con el UUID informado, seleccione el archivo nuevamente.", "O UUID do documento selecionado não coincide com o UUID informado, selecione o cadastro novamente." )
		#define STR0058 If( cPaisLoc $ "ANG|PTG", "Serie", "Série" )
		#define STR0059 If( cPaisLoc $ "ANG|PTG", "Especie", "Classe" )
		#define STR0060 "Núm.Doc"
		#define STR0061 If( cPaisLoc $ "ANG|PTG", "El Folio Fiscal ya fue utilizado en el siguiente documento: ", "A Folha Fiscal já foi utilizada no seguinte documento:" )
	#endif
#endif
