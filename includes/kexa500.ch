#ifdef SPANISH
	#define STR0000 "¡Atención!"
	#define STR0001 " A  T  E  N  C  I  Ó  N "
	#define STR0002 "Para actualizar la base de datos, el"
	#define STR0003 "sistema no puede estar en uso por "
	#define STR0004 "otras estaciones. En este momento se está "
	#define STR0005 "esperando la liberación de los ar "
	#define STR0006 "chivos. Pulse <Enter> cuando todas las "
	#define STR0007 "estaciones estén fuera del sis"
	#define STR0008 "tema p/ proseguir c/ la actualización."
	#define STR0009 "¡Es necesario registrar la Tabla De/A de Sucursales antes de ejecutar esta rutina!"
	#define STR0010 "¡Es necesario registrar los Grupos de productos antes de ejecutar esta rutina!"
	#define STR0011 "Límite para utilización de esta rutina excedido. Esta rutina ya no podrá procesarse."
	#define STR0012 "Integración Bisnet -> Microsiga"
	#define STR0013 " Este  programa  efectuará la lectura de un archivo de Texto Estándar, generado a "
	#define STR0014 "partir de la base de datos del sistema Bisnet y convertirlo en nuevos registros "
	#define STR0015 "de Microsiga.                                                               "
	#define STR0016 "En la primera ejecución de esta rutina se importarán una unica vez los archivos"
	#define STR0017 " acumulados de Sobres, Cheques diferidos, Ventas diarias acumuladas,"
	#define STR0018 " y Transacciones de inventario acumuladas, así como los archivos.     "
	#define STR0019 "Después de la primera importación, solamente se importarán los movimientos diarios del "
	#define STR0020 " Bisnet.     "
	#define STR0021 "Seleccione el directorio en el cual se copiaron los "
	#define STR0022 " archivos generados por el Bisnet.                   "
	#define STR0023 "¿Confirma la importación de los datos?"
	#define STR0024 "Archivo de clientes"
	#define STR0025 "Archivo de proveedores"
	#define STR0026 "Archivo de vendedores"
	#define STR0027 "Administradora de tarjetas"
	#define STR0028 "Archivo de productos"
	#define STR0029 "Archivo de sobres"
	#define STR0030 "Archivo de cheques - Maestro"
	#define STR0031 "Ítems de las Fact. de Salida - Acumuladas"
	#define STR0032 "Facturas de salida - Acumuladas"
	#define STR0033 "Notas de devolución - Acumuladas"
	#define STR0034 "Ítems de las Facturas de entrada y Movimiento interno- Acumuladas"
	#define STR0035 "Facturas de entrada - Acumuladas"
	#define STR0036 "Archivo de sobres - Diarios"
	#define STR0037 "Archivo de cheques - Diarios"
	#define STR0038 "Ítems de las Fact. de Salida - Diarias"
	#define STR0039 "Facturas de salida - Diarias"
	#define STR0040 "Notas de devolución - Diarias"
	#define STR0041 "Ítems de las Facturas de entrada y Movimiento interno - Diarias"
	#define STR0042 "Notas de entrada - Diarias"
	#define STR0043 "Transacciones de pagos"
	#define STR0044 "No fue posible abrir el archivo:= "
	#define STR0045 "Inicio de la importación del archivo:= "
	#define STR0046 "Importando a archivo - "
	#define STR0047 "Importando..."
	#define STR0048 "Se importaron:"
	#define STR0049 " registros a "
	#define STR0050 "Selección del directorio"
	#define STR0051 "Archivos TXT | TEXTOS.TXT"
	#define STR0052 "El directorio debe estar debajo del [SERVIDOR]"
	#define STR0053 "No se borrarán los datos del cliente:= "
	#define STR0054 "Se realizó la conversión. Solamente pueden importarse registros con modificación:= "
	#define STR0055 "No se borrarán los datos del proveedor:= "
	#define STR0056 "No se borrarán los datos del vendedor:= "
	#define STR0057 "No se borrarán los datos de la tarjeta de crédito:= "
	#define STR0058 "No se borrarán los datos del producto:= "
	#define STR0059 "No se borrarán los datos del cheque:= "
	#define STR0060 "Solamente se importarán cheques con estatus en blanco y devuelto(D):= "
	#define STR0061 "Esta factura de salida se importó al sistema:= "
	#define STR0062 "Esta nota de devolución se importó al sistema:= "
	#define STR0063 "Esta factura de entrada se importó al sistema:= "
	#define STR0064 "Este movimiento se importó al sistema:= "
	#define STR0065 "¡El archivo no puede ejecutarse!"
	#define STR0066 "SIGAPHOTO /KEXA500/v.10                                                         Log de importaciones                                                                "
	#define STR0067 "Ocurrió un error en la grabación del archivo de LOG: "
	#define STR0068 "Se generó el archivo : "
	#define STR0069 "¿Desea visualizar el Archivo de LOG?"
	#define STR0070 "Grupo no registrado : "
	#define STR0071 " - en el Producto: "
	#define STR0072 "¿La base del cliente esta normalizada?"
	#define STR0073 "Ya existe el código de la administradora: "
	#define STR0074 " en el archivo de clientes"
	#define STR0075 "El cliente "
	#define STR0076 " tuvo su código "
	#define STR0077 " sustituido por "
	#define STR0078 " debido a la incompatibilidad en el tamaño del campo."
	#define STR0079 "El proveedor "
	#define STR0080 "Doctos de salida - Acumuladas"
	#define STR0081 "Doctos de devolución - Acumuladas"
	#define STR0082 "Docto de entrada - Acumuladas"
	#define STR0083 "Doctos de salida - Diarias"
	#define STR0084 "Doctos de devolución - Diarias"
#else
	#ifdef ENGLISH
		#define STR0000 "Attention!"
		#define STR0001 " A  T  T  E  N  T  I  O  N "
		#define STR0002 "To update database,"
		#define STR0003 "system cannot be used by"
		#define STR0004 "other stations. In this moment "
		#define STR0005 "it is expected the release of "
		#define STR0006 "files. Press <Enter> when all "
		#define STR0007 "stations are already out of the"
		#define STR0008 "system to proceed with update."
		#define STR0009 "You must register Table From/To for Branches before running this routine!"
		#define STR0010 "You must register Product Groups before running this routine!"
		#define STR0011 "Limit for use of this routine was exceeded. This routine cannot be processed anymore."
		#define STR0012 "Integration Bisnet -> Microsiga"
		#define STR0013 " This program reads a Standard Text File, generated "
		#define STR0014 " as from the data base of the Bisnet system and convert it to new  "
		#define STR0015 " Microsiga  registrations.                                                               "
		#define STR0016 " In the first time this routine is run, accumulated files of"
		#define STR0017 " envelopes, pre-dated checks, accumulated dated sales"
		#define STR0018 " and accumulated inventory transactions, as well as registrations are imported.     "
		#define STR0019 " After the first import, only daily Bisnet transactions are imported. "
		#define STR0020 " Bisnet.     "
		#define STR0021 " Choose the directory to where  "
		#define STR0022 " files created by Bisnet.                    "
		#define STR0023 "Confirm data import?"
		#define STR0024 "Customers Register"
		#define STR0025 "Suppliers Register"
		#define STR0026 "Sales Representatives Register"
		#define STR0027 "Credit Card Company"
		#define STR0028 "Products Register"
		#define STR0029 "Envelopes Register"
		#define STR0030 "Checks Register - Master"
		#define STR0031 "Outgoing Invoice Items - Accrued"
		#define STR0032 "Outgoing Invoices - Accrued"
		#define STR0033 "Return Invoices - Accrued"
		#define STR0034 "Items of Incoming Invoice and Internal Transaction  - Accrued"
		#define STR0035 "Incoming Invoices - Accrued"
		#define STR0036 "Envelopes Register - Daily Rates"
		#define STR0037 "Checks Register - Daily Rates"
		#define STR0038 "Outgoing Invoice Items - Daily Rates"
		#define STR0039 "Outgoing Invoices - Daily Rates"
		#define STR0040 "Return Invoices - Daily Rates"
		#define STR0041 "Items of Incoming Invoice and Internal Transaction  - Daily Rates"
		#define STR0042 "Incoming Invoices - Daily Rates"
		#define STR0043 "Payment Transactions"
		#define STR0044 "Could not open file:= "
		#define STR0045 "Start of file import:= "
		#define STR0046 "Importing to file - "
		#define STR0047 "Importing..."
		#define STR0048 "Imported:"
		#define STR0049 " records to "
		#define STR0050 "Choose directory"
		#define STR0051 "TXT files | TEXTOS.TXT"
		#define STR0052 "Directory must be under [SERVER]"
		#define STR0053 "Data of customer will be kept:= "
		#define STR0054 "Conversion was carried out. Only records with changes can be imported:= "
		#define STR0055 "Data of Supplier will be kept:= "
		#define STR0056 "Data of Sales Representative will be kept:= "
		#define STR0057 "Data of Credit Card will be kept:= "
		#define STR0058 "Data of Product will be kept:= "
		#define STR0059 "Data of Check will be kept:= "
		#define STR0060 "Only checks with status Blank or Bounced(D):= "
		#define STR0061 "This outgoing invoice was already imported to the system:= "
		#define STR0062 "This return invoice was already imported to the system:= "
		#define STR0063 "This incoming invoice was already imported to the system:= "
		#define STR0064 "This transaction was already imported to the system:= "
		#define STR0065 "File cannot be run!"
		#define STR0066 "SIGAPHOTO /KEXA500/v.10                                                         Log of Imports                                                                     "
		#define STR0067 "Error saving LOG file: "
		#define STR0068 "File was generated: "
		#define STR0069 "Do you want to view log file?"
		#define STR0070 "Group not registered "
		#define STR0071 " - in the Product: "
		#define STR0072 "Is customer's database stabilized?"
		#define STR0073 "Code of provider already exists: "
		#define STR0074 " in customer register"
		#define STR0075 "The customer  "
		#define STR0076 " had his code  "
		#define STR0077 " replaced by  "
		#define STR0078 " due to incompatibility in field size."
		#define STR0079 "The supplier "
		#define STR0080 "Outgoing Documents - Accrued"
		#define STR0081 "Return Documents - Accrued"
		#define STR0082 "Incoming Document - Accrued"
		#define STR0083 "Outgoing Documents - Daily Rates"
		#define STR0084 "Return Documents - Daily Rates"
	#else
		#define STR0000 "Atenção!"
		#define STR0001 If( cPaisLoc $ "ANG|PTG", " A  T  E  N  Ç Ã  O ", " A  T  E  N  Ç  Ã  O " )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Para actualizar a  base de dados , o", "Para atualizar a base de dados, o" )
		#define STR0003 "sistema não poderá estar em uso por"
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "outras estações. Neste momento está", "outras estações. Nesse momento está" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "a ser aguardada a liberação dos fi-", "sendo aguardada a liberação dos ar-" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "cheiros. Tecle <Enter> qdo todas as ", "quivos. Tecle <Enter> qdo todas as " )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "estações já estiverem fora do  sis-", "estações já estiverem fora do sis-" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "tema p/ prosseguir c/ a actualização.", "tema p/ prosseguir c/ a atualização." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "É necessário registar a Tabela De/Para das Filiais antes de executar este procedimento .", "É necessário cadastrar a Tabela De/Até das Filiais antes de executar esta rotina!" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "É necessário registar os Grupos de Artigos antes de executar este procedimento.", "É necessário cadastrar os Grupos de produtos antes de executar esta rotina!" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Limite para utilização deste procedimento foi ultrapassado. Este procedimento não poderá mais ser processado.", "Limite para a utilização desta rotina foi ultrapassado. Esta rotina não pode mais ser processada." )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Integração Bisnet -> Microsiga", "Integracão Bisnet -> Microsiga" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", " Este  programa  efectuará  a leitura de um ficheiro de texto padrão , gerado a ", " Este  programa  irá efetuar a leitura de um arquivo de Texto Padrão, gerado a" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", " partir  da base  de dados  do sistema Bisnet e irá convertê-lo em novos  registos ", " partir  da base de dados do sistema Bisnet e convertê-lo em novos registros" )
		#define STR0015 " do Microsiga.                                                               "
		#define STR0016 If( cPaisLoc $ "ANG|PTG", " Na primeira execução deste procedimento serão importados uma única vez os ficheiros", "Na primeira execução desta rotina serão importados uma única vez os arquivos" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", " acumulados de Envelopes , Cheques Pré-datados , Vendas Diárias Acumuladas ,", " acumulados de Envelopes, Cheques pré-datados, Vendas diárias acumuladas," )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", " e Transacções de Inventário acumuladas, bem como os registos.     ", " e Transações de inventário acumuladas, bem como os cadastros.     " )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", " Após a primeira importação, só serão importadas as movimentações diárias do ", " Após a primeira importação só serão importadas as movimentações diárias do" )
		#define STR0020 " Bisnet.     "
		#define STR0021 If( cPaisLoc $ "ANG|PTG", " Escolha o directório para onde foram copiados os ", " Escolha o diretório para onde foram copiados os " )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", " ficheiros gerados pelo Bisnet.                   ", " arquivos gerados pelo Bisnet.                   " )
		#define STR0023 "Confirma a importação dos dados?"
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Registo de Clientes", "Cadastro de clientes" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Registo de Fornecedores", "Cadastro de fornecedores" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Registo de Vendedores", "Cadastro de vendedores" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Administradora de Cartões", "Administradora de cartões" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Registo de Artigos", "Cadastro de produtos" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Registo de Envelopes ", "Cadastro de envelopes" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Registo de Cheques - Mestre", "Cadastro de cheques - Mestre" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Itens das Fact. de Saída - Acumuladas", "Itens das NF de Saída - Acumuladas" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Facturas de Saída - Acumuladas", "Notas fiscais de saída - Acumuladas" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Facturas de Devolução - Acumuladas", "Notas de devolução - Acumuladas" )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "Itens das Fact. de Entrada e Movimentação Interna- Acumuladas", "Itens das NF de Entrada e Movimentação interna- Acumuladas" )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "Facturas de Entrada - Acumuladas", "Notas de entrada - Acumuladas" )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Registo de Envelopes", "Cadastro de envelopes - Diários" )
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "Registo de Cheques - Diários", "Cadastro de cheques - Diários" )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "Itens das Fact. de Saída - Diárias", "Itens das NF de saída - Diárias" )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Facturas de Saída - Diárias", "Notas fiscais de saída - Diárias" )
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "Facturas de Devolução - Diárias", "Notas de devolução - Diárias" )
		#define STR0041 If( cPaisLoc $ "ANG|PTG", "Itens das Fact. de Entrada e Movimentação Interna - Diárias", "Itens das NF de Entrada e Movimentação interna - Diárias" )
		#define STR0042 If( cPaisLoc $ "ANG|PTG", "Facturas de Entrada - Diárias", "Notas de Entrada - Diárias" )
		#define STR0043 If( cPaisLoc $ "ANG|PTG", "Transacções de Pagamentos", "Transações de pagamentos" )
		#define STR0044 If( cPaisLoc $ "ANG|PTG", "Não foi possível abrir o ficheiro := ", "Não foi possível abrir o arquivo:= " )
		#define STR0045 If( cPaisLoc $ "ANG|PTG", "Início da importação do ficheiro := ", "Início da importação do arquivo:= " )
		#define STR0046 If( cPaisLoc $ "ANG|PTG", "A importar para ficheiro - ", "Importando para arquivo - " )
		#define STR0047 If( cPaisLoc $ "ANG|PTG", "A importar...", "Importando..." )
		#define STR0048 If( cPaisLoc $ "ANG|PTG", "Foram Importados :", "Foram importados:" )
		#define STR0049 If( cPaisLoc $ "ANG|PTG", " registos para ", " registros para " )
		#define STR0050 If( cPaisLoc $ "ANG|PTG", "Escolha do directório", "Escolha do diretório" )
		#define STR0051 If( cPaisLoc $ "ANG|PTG", "Ficheiros TXT | TEXTOS.TXT", "Arquivos TXT | TEXTOS.TXT" )
		#define STR0052 If( cPaisLoc $ "ANG|PTG", "O directório deve estar abaixo do [SERVIDOR]", "O diretório deve estar abaixo do [SERVIDOR]" )
		#define STR0053 If( cPaisLoc $ "ANG|PTG", "não serao apagados os dados do Cliente := ", "Não serão apagados os dados do cliente:= " )
		#define STR0054 If( cPaisLoc $ "ANG|PTG", "A conversão já foi efectuada. Somente podem ser importados registos com alteração := ", "A conversao já foi efetuada. Somente podem ser importados registros com Alteração:= " )
		#define STR0055 If( cPaisLoc $ "ANG|PTG", "Não serão apagados os dados do Fornecedor := ", "Não serão apagados os dados do fornecedor:= " )
		#define STR0056 If( cPaisLoc $ "ANG|PTG", "Não serão apagados os dados do Vendedor := ", "Não serão apagados os dados do vendedor:= " )
		#define STR0057 If( cPaisLoc $ "ANG|PTG", "Não serão apagados os dados do Cartão de Crédito := ", "Não serão apagados os dados do cartão de crédito:= " )
		#define STR0058 If( cPaisLoc $ "ANG|PTG", "Não serão apagados os dados do Artigo := ", "Não serão apagados os dados do produto:= " )
		#define STR0059 If( cPaisLoc $ "ANG|PTG", "Não serão apagados os dados do Cheque := ", "Não serão apagados os dados do cheque:= " )
		#define STR0060 If( cPaisLoc $ "ANG|PTG", "So serão importados cheques com estado em branco e devolvido(D) := ", "Só serão importados cheques com status em branco e devolvido(D):= " )
		#define STR0061 If( cPaisLoc $ "ANG|PTG", "Esta factura de saída já foi importada para o sistema := ", "Esta nota de saída já foi importada para o sistema:= " )
		#define STR0062 If( cPaisLoc $ "ANG|PTG", "Esta factura de devolução já foi importada para o sistema := ", "Esta nota de devolução já foi importada para o sistema:= " )
		#define STR0063 If( cPaisLoc $ "ANG|PTG", "Esta factura de entrada já foi importada para o sistema := ", "Esta nota de entrada já foi importada para o sistema:= " )
		#define STR0064 If( cPaisLoc $ "ANG|PTG", "Esta movimentação já foi importada para o sistema := ", "Esta movimentação já foi importada para o sistema:= " )
		#define STR0065 If( cPaisLoc $ "ANG|PTG", "O ficheiro não pode ser executado!", "O arquivo não pode ser executado!" )
		#define STR0066 If( cPaisLoc $ "ANG|PTG", "SIGAPHOTO /KEXA500/v.10                                                         Log das Importações                                                                     ", "SIGAPHOTO /KEXA500/v.10                                                         Log das importações                                                                     " )
		#define STR0067 If( cPaisLoc $ "ANG|PTG", "Ocorreu um erro na gravação do ficheiro de LOG : ", "Ocorreu um erro na gravação do arquivo de LOG: " )
		#define STR0068 If( cPaisLoc $ "ANG|PTG", "Foi gerado o ficheiro : ", "Foi gerado o arquivo: " )
		#define STR0069 If( cPaisLoc $ "ANG|PTG", "Deseja visualizar o ficheiro de LOG ?", "Deseja visualizar o arquivo de LOG?" )
		#define STR0070 If( cPaisLoc $ "ANG|PTG", "Grupo não registado : ", "Grupo não cadastrado: " )
		#define STR0071 If( cPaisLoc $ "ANG|PTG", " - no Artigo : ", " - no produto: " )
		#define STR0072 If( cPaisLoc $ "ANG|PTG", "A base do cliente está normalizada ?", "A base do cliente está normalizada?" )
		#define STR0073 If( cPaisLoc $ "ANG|PTG", "Já existe o código da administradora : ", "Já existe o código da administradora: " )
		#define STR0074 If( cPaisLoc $ "ANG|PTG", " no registo de clientes", " no cadastro de clientes" )
		#define STR0075 "O cliente "
		#define STR0076 " teve seu código "
		#define STR0077 " substituído por "
		#define STR0078 " devido à incompatibilidade no tamanho do campo."
		#define STR0079 "O fornecedor "
		#define STR0080 If( cPaisLoc $ "ANG|PTG", "Doctos de salida - Acumuladas", "Doctos de saída - Acumuladas" )
		#define STR0081 "Doctos de devolução - Acumuladas"
		#define STR0082 "Docto de entrada - Acumuladas"
		#define STR0083 "Doctos de saída - Diárias"
		#define STR0084 "Doctos de devolução - Diárias"
	#endif
#endif
