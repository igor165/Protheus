#ifdef SPANISH
	#define STR0001 "Buscar"
	#define STR0002 "Visualizar"
	#define STR0003 "Granos"
	#define STR0004 "MV_POSON debe ser 2 para usar esta rutina"
	#define STR0005 "Anular"
	#define STR0006 "Leyenda"
	#define STR0007 "Generación NDC por Iva PosDatado"
	#define STR0009 "Grabando documentos"
	#define STR0010 "Borrando documentos"
	#define STR0011 "Grabando documento : "
	#define STR0012 "Dando de baja documento:"
	#define STR0014 "Borrando "
	#define STR0015 "Generacion de"
	#define STR0017 "¿Confirma?"
	#define STR0018 "Confirmar"
	#define STR0019 "Titulo pendiente"
	#define STR0020 "De baja parcial "
	#define STR0021 "De baja total "
	#define STR0022 "gen. por Lote"
	#define STR0023 "Visualizacion de"
	#define STR0024 "NDC para Iva Posdatado"
	#define STR0027 "Cargando NDC de Iva Posdatado"
	#define STR0028 "Cargando Documentos para Iva Posdatado"
	#define STR0030 "Emision"
	#define STR0031 "Tipo"
	#define STR0032 "Prefijo"
	#define STR0033 "Numero"
	#define STR0034 "Cliente"
	#define STR0035 "NDC"
	#define STR0036 "NCC"
	#define STR0037 "Marca todos"
	#define STR0038 "Marca"
	#define STR0039 "Desmarca todos"
	#define STR0040 "Desmarca"
	#define STR0041 "Invierte todos"
	#define STR0042 "Invierte"
	#define STR0043 "Borrando la baja de documento"
	#define STR0044 "Borrando documento"
	#define STR0045 "Confirmacion"
	#define STR0048 "La serie "
	#define STR0049 "no esta registrada en la tabla de numeracion. Para concluir el procesamiento se utilizara la serie "
	#define STR0050 "¿Desea continuar?"
	#define STR0051 "Confimacion"
	#define STR0052 "Revisar tabla SEL y checar los campos EL_DOCPOS,EL_FILPOS,EL_SERPOS,EL_STPOSDT,EL_TIPAGR"
	#define STR0053 "Verificar tabla SF2 y revisar campos  F2_RECPOS, F2_IVAPOS  y campos de tabla SF1: F1_RECPOS, F1_IVAPOS"
	#define STR0054 "Checar parámetros MV_IVACAN, MV_PIVCAN, MV_CONDGR deben estar informados"
	#define STR0055 "Falta informar ambas TES de entrada y salida en los productos informados"
	#define STR0056 "Verificar TES de salida y entrada en el producto informado en"
	#define STR0057 "No existe producto informado en "
	#define STR0058 "MV_IVACAN"
	#define STR0059 "MV_PIVCAN"
	#define STR0060 "No se generará IVAPOSDATADO, pues el Impuesto/Percepción se calculó en el documento original"
	#define STR0061 "Generado en el origen"
	#define STR0062 "Solo se puede seleccionar un registro a la vez"
	#define STR0063 "Faltan documentos agrupados"
	#define STR0064 "Es necesario considerar los siguientes documentos para anular el documento "
	#define STR0065 " No hay documentos para los parametros informado"
	#define STR0066 "¿Desea continuar? Los documentos serán considerados."
#else
	#ifdef ENGLISH
		#define STR0001 "Search"
		#define STR0002 "View"
		#define STR0003 "Grains"
		#define STR0004 "MV_POSON must be 2 to use this routine"
		#define STR0005 "Cancel"
		#define STR0006 "Caption"
		#define STR0007 "Post-dated VAT NDC generation"
		#define STR0009 "Saving Documents"
		#define STR0010 "Deleting Documents"
		#define STR0011 "Saving Document :"
		#define STR0012 "Downloading Document:"
		#define STR0014 "Deleting"
		#define STR0015 "From Generation"
		#define STR0017 "Confirm?"
		#define STR0018 "Confirm"
		#define STR0019 "Pending bill"
		#define STR0020 "Partial post"
		#define STR0021 "Full post"
		#define STR0022 "Gen Per Batch"
		#define STR0023 "View from"
		#define STR0024 "NDC for post-dated VAT"
		#define STR0027 "Loading post-dated VAT NDC"
		#define STR0028 "Loading Documents for post-dated VAT"
		#define STR0030 "Issue"
		#define STR0031 "Type"
		#define STR0032 "Prefix"
		#define STR0033 "Number"
		#define STR0034 "Customer"
		#define STR0035 "NDC"
		#define STR0036 "NCC"
		#define STR0037 "Select all"
		#define STR0038 "Select"
		#define STR0039 "Uncheck all"
		#define STR0040 "Uncheck"
		#define STR0041 "Reverse All"
		#define STR0042 "Reverse"
		#define STR0043 "Deleting document post"
		#define STR0044 "Deleting document"
		#define STR0045 "Confirmation"
		#define STR0048 "Series"
		#define STR0049 "not registered in the numbering table. To finish processing, the series used will be"
		#define STR0050 "Continue?"
		#define STR0051 "Confirmation"
		#define STR0052 "Review table SEL and check fields EL_DOCPOS,EL_FILPOS,EL_SERPOS,EL_STPOSDT,EL_TIPAGR"
		#define STR0053 "Check table SF2 and review fields F2_RECPOS, F2_IVAPOS and SF1 table fields: F1_RECPOS, F1_IVAPOS"
		#define STR0054 "Check parameters MV_IVACAN, MV_PIVCAN, MV_CONDGR that must be filled"
		#define STR0055 "Enter both in and out TIO in the products informed"
		#define STR0056 "Check in and out TIO in the product informed in"
		#define STR0057 "No product informed in"
		#define STR0058 "MV_IVACAN"
		#define STR0059 "MV_PIVCAN"
		#define STR0060 "No IVAPOSDATADO will be generated, since the Tax/Perception has already been calculated in the original document"
		#define STR0061 "Generated at origin"
		#define STR0062 "Select only one record at a time"
		#define STR0063 "Grouped documents missing"
		#define STR0064 "To cancel document, take the following documents into account"
		#define STR0065 "No documents found for the parameters entered"
		#define STR0066 "Continue? Documents are considered."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Buscar", "Pesquisar" )
		#define STR0002 "Visualizar"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Granos", "Grãos" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "MV_POSON debe ser 2 para usar esta rutina", "MV_POSON deve ser 2 para usar essa rotina" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Anular", "Cancelar" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Leyenda", "Legenda" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Generación NDC por Iva PosDatado", "Geração NDC por IVA Pós-datado" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Grabando documentos", "Salvando documentos" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Borrando documentos", "Excluindo documentos" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Grabando documento : ", "Salvando documento :" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Dando de baja documento:", "Baixando documento:" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Borrando ", "Excluindo" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Generacion de", "Geração De" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "¿Confirma?", "Confirma?" )
		#define STR0018 "Confirmar"
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Titulo pendiente", "Título pendente" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "De baja parcial ", "Baixa parcial" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "De baja total ", "Baixa total" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "gen. por Lote", "Ger. por Lote" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Visualizacion de", "Visualização de" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "NDC para Iva Posdatado", "NDC para IVA Pós-datado" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Cargando NDC de Iva Posdatado", "Carregando NDC de IVA Pós-datado" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Cargando Documentos para Iva Posdatado", "Carregando Documentos para IVA Pós-datado" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Emision", "Emissão" )
		#define STR0031 "Tipo"
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Prefijo", "Prefixo" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Numero", "Número" )
		#define STR0034 "Cliente"
		#define STR0035 "NDC"
		#define STR0036 "NCC"
		#define STR0037 "Marca todos"
		#define STR0038 "Marca"
		#define STR0039 "Desmarca todos"
		#define STR0040 "Desmarca"
		#define STR0041 If( cPaisLoc $ "ANG|PTG", "Invierte todos", "Estornar todos" )
		#define STR0042 If( cPaisLoc $ "ANG|PTG", "Invierte", "Estorna" )
		#define STR0043 If( cPaisLoc $ "ANG|PTG", "Borrando la baja de documento", "Excluindo a baixa do documento" )
		#define STR0044 If( cPaisLoc $ "ANG|PTG", "Borrando documento", "Excluindo documento" )
		#define STR0045 If( cPaisLoc $ "ANG|PTG", "Confirmacion", "Confirmação" )
		#define STR0048 If( cPaisLoc $ "ANG|PTG", "La serie ", "A série" )
		#define STR0049 If( cPaisLoc $ "ANG|PTG", "no esta registrada en la tabla de numeracion. Para concluir el procesamiento se utilizara la serie ", "não está cadastrada na tabela de numeração. Para concluir o processameento será utilizada a série" )
		#define STR0050 If( cPaisLoc $ "ANG|PTG", "¿Desea continuar?", "Deseja prosseguir?" )
		#define STR0051 If( cPaisLoc $ "ANG|PTG", "Confimacion", "Confimação" )
		#define STR0052 If( cPaisLoc $ "ANG|PTG", "Revisar tabla SEL y checar los campos EL_DOCPOS,EL_FILPOS,EL_SERPOS,EL_STPOSDT,EL_TIPAGR", "Revisar tabela SEL e conferir os campos EL_DOCPOS,EL_FILPOS,EL_SERPOS,EL_STPOSDT,EL_TIPAGR" )
		#define STR0053 If( cPaisLoc $ "ANG|PTG", "Verificar tabla SF2 y revisar campos  F2_RECPOS, F2_IVAPOS  y campos de tabla SF1: F1_RECPOS, F1_IVAPOS", "Conferir tabela SF2 e revisar campos F2_RECPOS, F2_IVAPOS e campos de tabela SF1: F1_RECPOS, F1_IVAPOS" )
		#define STR0054 If( cPaisLoc $ "ANG|PTG", "Checar parámetros MV_IVACAN, MV_PIVCAN, MV_CONDGR deben estar informados", "Conferir parâmetros MV_IVACAN, MV_PIVCAN, MV_CONDGR que devem estar informados" )
		#define STR0055 If( cPaisLoc $ "ANG|PTG", "Falta informar ambas TES de entrada y salida en los productos informados", "Falta informar ambas as TES de entrada e saída nos produtos informados" )
		#define STR0056 If( cPaisLoc $ "ANG|PTG", "Verificar TES de salida y entrada en el producto informado en", "Conferir TES de saída e entrada no produto informado em" )
		#define STR0057 If( cPaisLoc $ "ANG|PTG", "No existe producto informado en ", "Não existe produto informado em" )
		#define STR0058 "MV_IVACAN"
		#define STR0059 "MV_PIVCAN"
		#define STR0060 "Nao sera gerado IVAPOSDATADO, pois o Imposto/Percepção ja foi calculado no documento documento original"
		#define STR0061 "Gerado na Origem"
		#define STR0062 If( cPaisLoc $ "ANG|PTG", "Solo se puede seleccionar un registro a la vez", "Só é possível selecionar um registro a cada vez" )
		#define STR0063 If( cPaisLoc $ "ANG|PTG", "Faltan documentos agrupados", "Faltam documentos agrupados" )
		#define STR0064 If( cPaisLoc $ "ANG|PTG", "Es necesario considerar los siguientes documentos para anular el documento ", "É necessário considerar os seguintes documentos para cancelar o documento" )
		#define STR0065 If( cPaisLoc $ "ANG|PTG", " No hay documentos para los parametros informado", "Não existem documentos para os parâmetros informados" )
		#define STR0066 If( cPaisLoc $ "ANG|PTG", "¿Desea continuar? Los documentos serán considerados.", "Deseja prosseguir? Os documentos serão considerados." )
	#endif
#endif
