#ifdef SPANISH
	#define STR0001 "FINI136O:"
	#define STR0002 "GET:"
	#define STR0003 "Formato JSON no v�lido."
	#define STR0004 "Los par�metros 'cCodEmp' o 'cCodFil' est�n vac�os."
	#define STR0005 "Empresa actual difiere de la empresa informada por par�metro."
	#define STR0006 "JOB en ejecuci�n."
	#define STR0007 "Formato no v�lido para la fecha informada."
	#define STR0008 "opera��o  "
	#define STR0009 " informada no JSON n�o existente no ERP"
	#define STR0010 "Tama�o de la clave 'erpId' informado no est� correcto."
	#define STR0011 "T�tulo no encontrado en la base de datos."
	#define STR0012 "Clave 'operation' consta en blanco en el JSON."
	#define STR0013 "Clave '"
	#define STR0014 "' no encontrada."
	#define STR0015 "Layout del JSON no v�lido."
	#define STR0016 "POST:"
	#define STR0017 "Error en la requisici�n."
	#define STR0018 "�xito en la requisici�n."
	#define STR0019 "FINAuth Post"
	#define STR0020 "Cuota:"
	#define STR0021 "no se encuentra en la cartera TOTVS Anticipa"
	#define STR0022 "T�tulo se encontra con baja total."
	#define STR0023 "Valor informado para baja no debe ser mayor que el saldo del t�tulo."
	#define STR0024 "�TypeOperation no informado!"
	#define STR0025 "El banco enviado no est� registrado"
	#define STR0026 "El saldo pendiente de la factura est� diferente de su valor original. La factura se recomprar� autom�ticamente por el TOTVS Antecipa."
	#define STR0027 "La factura informada ya est� en la cartera TOTVS Antecipa."
	#define STR0028 "No es posible realizar la anulaci�n de un t�tulo que tenga baja total."
	#define STR0029 "Agencia Portador (MV_AGETECF) no debe estar blanco."
	#define STR0030 "Banco Portador (MV_BCOTECF) no debe estar blanco."
	#define STR0031 "Cuenta Portador (MV_CTNTECF) no debe estar blanco."
	#define STR0032 "Banco Portador no encontrado en el ERP."
	#define STR0033 "Cartera Techfin debe haberse informado (MV_CARTECF)."
	#define STR0034 "Cartera Techfin debe utilizar Banco. (FRV_BANCO = '1')."
	#define STR0035 "Cartera Techfin debe ser del tipo 'Descontada' (FRV_DESCON = '1')."
	#define STR0036 "Cartera Techfin no encontrada en el sistema."
	#define STR0037 "no inv�lido para el JSON."
	#define STR0038 "SECUENCIA:"
	#define STR0039 "FECHA:"
	#define STR0040 "VALOR:"
	#define STR0041 "No se encontr� ninguna baja para el valor informado."
	#define STR0042 "Conciliaci�n"
	#define STR0043 "Anticipaci�n"
	#define STR0044 "Anulaci�n"
	#define STR0045 "Se finalizar� la rutina."
	#define STR0046 "URL de acceso TOTVS Anticipa no puede estar en blanco."
	#define STR0047 "URL de autenticaci�n TOTVS Anticipa no puede estar en blanco"
	#define STR0048 "BAJA"
	#define STR0049 "ANULACI�N DE BAJA"
	#define STR0050 "El Banco informado no puede ser igual al Banco contenido en los par�metros TOTVS Anticipa"
	#define STR0051 "Vencimiento enviado es el mismo del t�tulo."
	#define STR0052 "CARTERA"
	#define STR0053 "TS COOBLIGA"
	#define STR0054 "TS DIVERCOM"
	#define STR0055 "TS RECOMPRA"
	#define STR0056 "TS PRORROGA"
	#define STR0057 "TS BONIFICA"
	#define STR0058 "Prorrogaci�n"
	#define STR0059 "Bonificaci�n"
	#define STR0060 "no encontrada."
	#define STR0061 "no es del tipo NCC."
	#define STR0062 "no tiene saldo."
	#define STR0063 "tiene saldo inferior al valor de cr�dito informado."
	#define STR0064 "Valor de la suma de la Nota de cr�dito y descuento no puede ser mayor que el saldo del t�tulo. Saldo:"
	#define STR0065 "Inconsistencia en la suma de valores de las Notas de cr�dito cliente informadas"
	#define STR0066 "Motivo de baja anticipa debe haberse completado (MV_MOTTECF)."
	#define STR0067 "descuento superior al saldo."
	#define STR0068 "est� en uso por otra rutina del sistema."
	#define STR0069 "no se encuera en cartera de devoluci�n Techfin."
	#define STR0070 "TX DEVOLUC"
	#define STR0071 "Devoluci�n"
	#define STR0072 "CARTERA"
	#define STR0073 "Cartera de devoluci�n Antecipa debe haberse completado (MV_DEVTECF)."
	#define STR0074 "Cartera de devoluci�n TOTVS Antecipa no debe utilizar Banco. (FRV_BANCO = '2')."
	#define STR0075 "Cartera de devoluci�n TOTVS Antecipa no puede ser del tipo 'Descontada' (FRV_DESCON = '1')."
	#define STR0076 "Saldo:"
	#define STR0077 "Saldo de la NCC no coincide."
	#define STR0078 "Iniciando ejecuci�n Job TOTVS Antecipa."
	#define STR0079 "Finalizando ejecuci�n Job TOTVS Antecipa."
	#define STR0080 "TX ANTICIPA"
	#define STR0081 "Coobligaci�n"
	#define STR0082 "Divergencia comercial"
	#define STR0083 "Recompra"
	#define STR0084 "TX CONCILIA"
	#define STR0085 "Liberaci�n de NCC"
#else
	#ifdef ENGLISH
		#define STR0001 "FINI136O:"
		#define STR0002 "GET:"
		#define STR0003 "Invalid JSON format."
		#define STR0004 "Parameters 'cCodEmp' or 'cCodFil' are empty."
		#define STR0005 "Current company differs from the company informed by parameter."
		#define STR0006 "JOB running."
		#define STR0007 "Invalid date format."
		#define STR0008 "operation"
		#define STR0009 "entered In JSON does not exist in the ERP"
		#define STR0010 "Size of key 'erpId' entered is incorrect."
		#define STR0011 "Bill not found in database."
		#define STR0012 "Key �operation� blank in JSON."
		#define STR0013 "Key �"
		#define STR0014 "� not found."
		#define STR0015 "Invalid JSON layout."
		#define STR0016 "POST:"
		#define STR0017 "Request error."
		#define STR0018 "Request successful."
		#define STR0019 "FINAuth Post"
		#define STR0020 "Installment:"
		#define STR0021 "not found in the TOTVS Antecipa portfolio."
		#define STR0022 "Bill is fully posted."
		#define STR0023 "Amount entered for posting cannot exceed the balance of the bill."
		#define STR0024 "TypeOperation not entered."
		#define STR0025 "Submitted bank is not registered"
		#define STR0026 "The invoice balance pending differs from its original value. The invoice will be automatically rebought by TOTVS Antecipa."
		#define STR0027 "The invoice entered is already in the TOTVS Antecipa portfolio."
		#define STR0028 "Unable to cancel a bill that has already been posted."
		#define STR0029 "Bearer Branch (MV_AGETECF) cannot be blank."
		#define STR0030 "Bearer Bank (MV_BCOTECF) cannot be blank."
		#define STR0031 "Bearer Account (MV_CTNTECF) cannot be blank."
		#define STR0032 "Bearer Bank not found in ERP."
		#define STR0033 "Enter the Techfin portfolio (MV_CARTECF)."
		#define STR0034 "Techfin portfolio must use Bank. (FRV_BANCO = '1')."
		#define STR0035 "Techfin portfolio must be type �Discounted� (FRV_DESCON = '1')."
		#define STR0036 "Techfin portfolio not found in the system."
		#define STR0037 "invalid for JSON."
		#define STR0038 "SEQUENCE:"
		#define STR0039 "DATE:"
		#define STR0040 "VALUE:"
		#define STR0041 "No range found for the entered value."
		#define STR0042 "Reconciliation"
		#define STR0043 "Advance"
		#define STR0044 "Cancellation"
		#define STR0045 "The routine will be closed."
		#define STR0046 "TOTVS Antecipa access URL cannot be blank."
		#define STR0047 "TOTVS Antecipa authentication URL cannot be blank."
		#define STR0048 "POST"
		#define STR0049 "CANCELLATION OF POST"
		#define STR0050 "The Bank entered cannot be the same as the Bank contained in the parameters of TOTVS Antecipa"
		#define STR0051 "Maturity sent is the same as the title."
		#define STR0052 "PORTFOLIO"
		#define STR0053 "TX COOBRIGA"
		#define STR0054 "TX DIVERCOM"
		#define STR0055 "TX RECOMPRA"
		#define STR0056 "TX PRORROGA"
		#define STR0057 "TX BONIFICA"
		#define STR0058 "Extension"
		#define STR0059 "Bonus"
		#define STR0060 "not found."
		#define STR0061 "is not NCC type."
		#define STR0062 "has no balance."
		#define STR0063 "has a balance lower than the credit amount informed."
		#define STR0064 "The sum of the Credit and Discount Notes cannot be greater than the bill balance. Balance:"
		#define STR0065 "Inconsistency in the sum of amounts of the Customer Credit Notes informed"
		#define STR0066 "Antecipa Posting Reason must be completed (MV_MOTTECF)."
		#define STR0067 "discount greater than balance."
		#define STR0068 "is being used by another system routine."
		#define STR0069 "not in Techfin return portfolio."
		#define STR0070 "RETURN RT"
		#define STR0071 "Return"
		#define STR0072 "PORTFOLIO"
		#define STR0073 "Inform the Return Portfolio Antecipa (MV_DEVTECF)."
		#define STR0074 "Return Portfolio TOTVS Antecipa must not use Bank. (FRV_BANCO = '2')."
		#define STR0075 "Return Portfolio TOTVS Antecipa cannot be type �Discounted� (FRV_DESCON = '1')."
		#define STR0076 "Balance:"
		#define STR0077 "NCC balance does not match."
		#define STR0078 "Starting execution of TOTVS Antecipa Job."
		#define STR0079 "Finishing execution of TOTVS Antecipa Job."
		#define STR0080 "ANTECIPA RT"
		#define STR0081 "Co-obligation"
		#define STR0082 "Commercial Divergence"
		#define STR0083 "Repurchase"
		#define STR0084 "RECONC RT"
		#define STR0085 "NCC Release"
	#else
		#define STR0001 "FINI136O: "
		#define STR0002 "GET: "
		#define STR0003 "Formato JSON inv�lido. "
		#define STR0004 " Par�metros 'cCodEmp' ou 'cCodFil' est�o vazios."
		#define STR0005 " Empresa atual difere da empresa informada por par�metro."
		#define STR0006 "JOB em execu��o."
		#define STR0007 "Formato inv�lido para a data informada."
		#define STR0008 "opera��o  "
		#define STR0009 " informada no JSON n�o existente no ERP"
		#define STR0010 "Tamanho da chave 'erpId' informado n�o est� correto. "
		#define STR0011 "T�tulo n�o encontrado na base de dados."
		#define STR0012 "Chave 'operation' consta em branco no JSON."
		#define STR0013 "Chave '"
		#define STR0014 "' nao encontrada."
		#define STR0015 "Layout do JSON inv�lido."
		#define STR0016 "POST: "
		#define STR0017 "Erro na requisi��o. "
		#define STR0018 "Sucesso na requisi�ao."
		#define STR0019 "FINAuth Post "
		#define STR0020 "Parcela: "
		#define STR0021 "n�o se encontra na carteira TOTVS Antecipa"
		#define STR0022 "T�tulo se encontra com baixa total."
		#define STR0023 "Valor informado para baixa n�o pode ser maior do que o saldo do t�tulo."
		#define STR0024 "TypeOperation n�o preenchido!"
		#define STR0025 "O banco enviado n�o esta cadastrado "
		#define STR0026 "O saldo em aberto da nota fiscal est� diferente do seu valor original. A nota ser� recomprada automaticamente pelo TOTVS Antecipa."
		#define STR0027 "A nota informada j� est� na carteira TOTVS Antecipa."
		#define STR0028 "N�o � poss�vel realizar o cancelamento de um t�tulo que j� possua baixa total"
		#define STR0029 "Ag�ncia Portador (MV_AGETECF) n�o pode estar branco."
		#define STR0030 "Banco Portador (MV_BCOTECF) n�o pode estar branco."
		#define STR0031 "Conta Portador (MV_CTNTECF) n�o pode estar branco."
		#define STR0032 "Banco Portador n�o encontrado no ERP."
		#define STR0033 "Carteira Techfin deve estar preenchida (MV_CARTECF)."
		#define STR0034 "Carteira Techfin deve utilizar Banco. (FRV_BANCO = '1')."
		#define STR0035 "Carteira Techfin deve ser do tipo 'Descontada' (FRV_DESCON = '1')."
		#define STR0036 "Carteira Techfin n�o encontrada no sistema."
		#define STR0037 "  no invalido para o JSON."
		#define STR0038 "SEQUENCIA: "
		#define STR0039 "DATA: "
		#define STR0040 "VALOR: "
		#define STR0041 "Nenhuma baixa encontrada para o valor informado."
		#define STR0042 "Concilia��o"
		#define STR0043 "Antecipacao"
		#define STR0044 "Cancelamento"
		#define STR0045 " A rotina ser� encerrada."
		#define STR0046 "URL de acesso TOTVS Antecipa n�o pode estar em branco."
		#define STR0047 "URL de autentica��o TOTVS Antecipa n�o pode estar em branco"
		#define STR0048 "BAIXA"
		#define STR0049 "CANCELAMENTO DE BAIXA"
		#define STR0050 "O Banco informado n�o pode ser igual ao Banco contido nos par�metros TOTVS Antecipa"
		#define STR0051 "Vencimento enviado � o mesmo do t�tulo."
		#define STR0052 "CARTEIRA "
		#define STR0053 "TX COOBRIGA"
		#define STR0054 "TX DIVERCOM"
		#define STR0055 "TX RECOMPRA"
		#define STR0056 "TX PRORROGA"
		#define STR0057 "TX BONIFICA"
		#define STR0058 "Prorroga��o"
		#define STR0059 "Bonifica��o"
		#define STR0060 " n�o encontrada."
		#define STR0061 " n�o � do tipo NCC."
		#define STR0062 " n�o possui saldo."
		#define STR0063 " possui saldo inferior ao valor de cr�dito informado."
		#define STR0064 "Valor da soma da Nota de Cr�dito e Desconto n�o pode ser maior que o saldo do t�tulo. Saldo: "
		#define STR0065 "Inconsist�ncia na soma dos valores das Notas de Cr�dito Cliente informadas"
		#define STR0066 "Motivo de Baixa Antecipa deve estar preenchido (MV_MOTTECF)."
		#define STR0067 "desconto superior ao saldo."
		#define STR0068 " est� em uso por outra rotina do sistema."
		#define STR0069 " n�o se encontra em carteira de devolu��o Techfin."
		#define STR0070 "TX DEVOLUC"
		#define STR0071 "Devolu��o"
		#define STR0072 "CARTEIRA"
		#define STR0073 "Carteira Devolu��o Antecipa deve estar preenchida (MV_DEVTECF)."
		#define STR0074 "Carteira Devolu��o TOTVS Antecipa n�o deve utilizar Banco. (FRV_BANCO = '2')."
		#define STR0075 "Carteira Devolu��o TOTVS Antecipa n�o pode ser do tipo 'Descontada' (FRV_DESCON = '1')."
		#define STR0076 "Saldo: "
		#define STR0077 " Saldo da NCC n�o confere. "
		#define STR0078 "Iniciando execu��o Job TOTVS Antecipa."
		#define STR0079 "Encerrando execu��o Job TOTVS Antecipa."
		#define STR0080 "TX ANTECIPA"
		#define STR0081 "Coobriga��o"
		#define STR0082 "Diverg�ncia Comercial"
		#define STR0083 "Recompra"
		#define STR0084 "TX CONCILIA"
		#define STR0085 "Libera��o de NCC"
	#endif
#endif
