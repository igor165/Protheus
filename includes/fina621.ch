#ifdef SPANISH
	#define STR0001 "Solicitud de transferencia"
	#define STR0002 "�Retorno del punto de entrada FA621TOK invalido!"
	#define STR0003 " "
	#define STR0004 "Check-list de transferencia"
	#define STR0005 "La transferencia solo podra solicitarse si el titulo no tiene bajas parciales y no tiene solicitudes pendientes."
	#define STR0006 "Titulo anulado. No se permite la inclusion de la solicitud de transferencia"
	#define STR0007 "Atencion"
	#define STR0008 "No se permite la inclusion de la solicitud de transferencia para titulos de descuento. Por favor posicione sobre el titulo principal para efectuar la solicitud."
	#define STR0009 "Ya existe solicitud de transferencia del titulo"
	#define STR0010 "Datos del titulo para transferir"
	#define STR0011 "Check-List para transferencia"
	#define STR0012 "Items para verificacion"
	#define STR0013 "Datos de la transferencia"
	#define STR0014 "Tipo Operacion"
	#define STR0015 " "
	#define STR0016 "Sucursal de Credito"
	#define STR0017 "Proveedor Credito"
	#define STR0018 "Historial"
	#define STR0019 "Transferencia automatica"
	#define STR0020 "Solicitud no efectuada, intente de nuevo"
	#define STR0021 "Prohibida la inclusion de la solicitud de transfeencia para la misma Empesa/Sucursal ("
	#define STR0022 ")"
	#define STR0023 "La empresa destino debe ser igual a la empresa origen"
	#define STR0024 "Es necesario que todos los items de la lista de verificacion se verifiquen para efectuar la solicitud"
	#define STR0025 "Sin solicitud"
	#define STR0026 "Con solicitud"
	#define STR0027 "Factura anulada."
	#define STR0028 "Leyenda"
	#define STR0029 "Solicitud de transferencia de titulo entre sucursales."
	#define STR0030 "Este titulo no fue utilizado en transferencia"
	#define STR0031 "Buscar"
	#define STR0032 "Visualizar"
	#define STR0033 "Solicitar"
	#define STR0034 "Leyenda"
	#define STR0035 "Las tablas SE6/SE2 deben tener el mismo modo compartido. Verifique con el administrador."
	#define STR0036 "Los campos Proveedor y Tienda se deben cumplimentar"
	#define STR0037 "Las tablas SE6/SE2 est�n compartidas. No es necesario realizar la transferencia entre sucursales para el mismo proveedor."
	#define STR0038 "El parametro MV_IMPTRAN esta activo. La transferencia solo debe realizarse por el titulo principal."
	#define STR0039 "Seleccione un proveedor con el mismo C�digo/Tienda y RCPJ/RCPF"
	#define STR0040 "No se permite la solicitud de transferencia de titulos de anticipo."
	#define STR0041 "El proveedor informado no tiene relaci�n con el proveedor original del t�tulo."
	#define STR0042 "Seleccione un proveedor de destino con el mismo RCPJ/RCPF del proveedor del t�tulo que desea transferir."
#else
	#ifdef ENGLISH
		#define STR0001 "Transference request"
		#define STR0002 "Invalid return of entry point FA621TOK."
		#define STR0003 " "
		#define STR0004 "Transfer check list"
		#define STR0005 "Transfer can only be requested if the bill was not partially written off or if it does not have pending requests."
		#define STR0006 "Bill canceled. Inclusion of transfer request inclusion"
		#define STR0007 "Attention"
		#define STR0008 "The inclusion of transfer/distribution request for discount bills is not allowed. Please select main bill to execute request."
		#define STR0009 "There is already a request for transfer of bill "+CHR(13)+"to branch "
		#define STR0010 "Data of the bill to transfer"
		#define STR0011 "Check-List for transfer"
		#define STR0012 "Check-list Items"
		#define STR0013 "Transfer Data"
		#define STR0014 "Operation Type"
		#define STR0015 " "
		#define STR0016 "Credit Branch"
		#define STR0017 "Credit Provider"
		#define STR0018 "History"
		#define STR0019 "Automatic Transfer"
		#define STR0020 "Request not executed, try again"
		#define STR0021 "The inclusion transfer request to the same Company/Branch is not allowed ("
		#define STR0022 ")"
		#define STR0023 "The target company must be equal to the source company"
		#define STR0024 "All items in the check list must be verified to execute the request"
		#define STR0025 "Without request"
		#define STR0026 "With request"
		#define STR0027 "Invoice canceled"
		#define STR0028 "Caption"
		#define STR0029 "Request of Bill Transfer between branches."
		#define STR0030 "This bill was not used in transfer."
		#define STR0031 "Search"
		#define STR0032 "View"
		#define STR0033 "Request"
		#define STR0034 "Caption"
		#define STR0035 "The tables SE6/SE2 must have the same sharing. Check with Manager."
		#define STR0036 "The fields Supplier and Store cannot be completed"
		#define STR0037 "The SE6/SE2 tables are shared. Unable to transfer between branches to the same supplier."
		#define STR0038 "Parameter MV_IMPTRAN is active! The transfer must be performed by the main bill."
		#define STR0039 "Select a supplier with the same Code/Store and CNPJ/CPF"
		#define STR0040 "Request of prepayment bills transfer is not allowed."
		#define STR0041 "The entered supplier has no relation to the original supplier of bill."
		#define STR0042 "Select a destination supplier with same CNPJ/CPF of supplier of bill you wish to transfer."
	#else
		#define STR0001 "Solicita��o de transfer�ncia"
		#define STR0002 "Retorno do ponto de entrada FA621TOK invalido!"
		#define STR0003 ""
		#define STR0004 "Check-list de transfer�ncia"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "A transfer�ncia somente poder� ser solicitada se o t�tulo n�o tiver liquida��es parciais e nem solicita��es em aberto.", "A transfer�ncia somente poder� ser solicitada se o t�tulo n�o tiver baixas parciais e n�o tenha solicita��es em aberto." )
		#define STR0006 "Titulo cancelado. N�o � permitida a inclus�o da solicita��o de transfer�ncia"
		#define STR0007 "Aten��o"
		#define STR0008 "N�o � permitida a inclus�o da solicita��o de transfer�ncia para titulos de abatimento. Por favor posicione sobre o titulo principal para efetuar a solicita��o."
		#define STR0009 "J� existe solicita��o de transfer�ncia do titulo"+CHR(13)+"para a filial "
		#define STR0010 "Dados do t�tulo a transferir"
		#define STR0011 "Check-List para transfer�ncia"
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Itens para veifica��o", "Itens para checagem" )
		#define STR0013 "Dados da Transfer�ncia"
		#define STR0014 "Tipo Opera��o"
		#define STR0015 ""
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Filial de cr�dito", "Filial de Cr�dito" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Fornecedor cr�dito", "Fornecedor Credito" )
		#define STR0018 "Hist�rico"
		#define STR0019 "Transfer�ncia Autom�tica"
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Solicita��o n�o efectuada. Tente novamente.", "Solicita��o n�o efetuada, tente novamente" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Proibida a inclus�o da solicita��o de transfer�ncia para a mesma empresa/filial (", "Proibido a inclus�o da solicita��o de transfer�ncia para a mesma Empresa/Filial (" )
		#define STR0022 ")"
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "A empresa destino deve ser igual � empresa origem", "A empresa destino deve ser igual a empresa origem" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "� necess�rio que todos os itens do check-list sejam verificados para efectuar a solicita��o", "� necess�rio que todos os itens do check-list sejam verificados para efetuar a solicita��o" )
		#define STR0025 "Sem solicita��o"
		#define STR0026 "Com solicita��o"
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Factura cancelada", "Fatura cancelada" )
		#define STR0028 "Legenda"
		#define STR0029 "Solicita��o de Transferencia de titulo entre filiais."
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Este t�tulo n�o foi utilizado em transfer�ncia.", "Este titulo n�o foi utilizado em tranferencia." )
		#define STR0031 "Pesquisar"
		#define STR0032 "Visualizar"
		#define STR0033 "Solicitar"
		#define STR0034 "Legenda"
		#define STR0035 "As tabelas SE6/SE2 devem ter o mesmo compartilhamento. Verifique com Administrador."
		#define STR0036 "Os campos Fornecedor e Loja devem ser preenchidos"
		#define STR0037 "As tabelas SE6/SE2 est�o compartilhadas. N�o sendo necess�rio realizar a transfer�ncia entre filiais para o mesmo fornecedor."
		#define STR0038 "O parametro MV_IMPTRAN est� ativo!A transf�rencia deve ser feita apenas pelo t�tulo principal."
		#define STR0039 "Selecione um fornecedor com o mesmo C�digo/Loja e CNPJ/CPF"
		#define STR0040 "N�o � permitida a solicita��o de transfer�ncia de t�tulos de adiantamento."
		#define STR0041 "O fornecedor informado n�o tem rela��o com o fornecedor original do t�tulo.."
		#define STR0042 "Selecione um fornecedor de destino com o mesmo CNPJ/CPF do fornecedor do titulo que deseja transferir."
	#endif
#endif
