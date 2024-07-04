#ifdef SPANISH
	#define STR0001 "Ítems de desdoblamiento después del pago"
	#define STR0002 "Título"
	#define STR0003 "Grabando."
	#define STR0004 "Actualizando gastos..."
	#define STR0005 'Val. Neto'
	#define STR0006 'Valor neto'
	#define STR0007 'Desc. Modalidad'
	#define STR0008 'Descripción modalidad'
	#define STR0009 'Total desdoblamiento'
	#define STR0010 'Saldo desdoblamiento'
	#define STR0011 'Cód. Moneda'
	#define STR0012 'Código de la moneda'
	#define STR0013 'Símb. Moneda'
	#define STR0014 'Símbolo de la moneda'
	#define STR0015 "Existen desdoblamientos vinculados al Cuentas por pagar."
	#define STR0016 "Borre los desdoblamientos vinculados para permitir que se borre el registro."
	#define STR0017 'El valor total de los desdoblamientos no debe ser mayor que lo definido en la modalidad transitoria después del pago.'
	#define STR0018 'El valor máximo para el desdoblamiento es #1.'
	#define STR0019 "No será posible manejar los desdoblamientos del Cuentas por pagar, pues el usuario no está vinculado a un participante."
	#define STR0020 "Vincule su usuario a un participante para tener acceso a la operación."
	#define STR0021 "No existe desdoblamiento con la modalidad del tipo 'transitoria después del pago'."
	#define STR0022 "Realice un desdoblamiento transitorio para habilitar el desdoblamiento después del pago."
	#define STR0023 "No existe saldo para desdoblamiento."
	#define STR0024 "Verifique el(os) desdoblamiento(s) registrado(s) en el título."
	#define STR0025 "No existe la baja para el título con desdoblamiento transitorio después del pago."
	#define STR0026 "Realice una baja para habilitar el desdoblamiento después del pago."
	#define STR0027 "Desdoblamientos pago posterior"
	#define STR0028 "Desdoblamientos"
	#define STR0029 "Error al actualizar registro: "
	#define STR0030 "Actualizando registros..."
	#define STR0031 "Calendario contable bloqueado."
	#define STR0032 "Verifique el bloqueo del proceso 'PFS001' en el Calendario contable de la sucursal '#1', para el período de la fecha del registro."
	#define STR0033 "No es posible modificar la modalidad de este desdoblamiento."
	#define STR0034 "Indique una modalidad que tenga el mismo centro de costo jurídico de la modalidad '#1'."
	#define STR0035 "No es posible borrar/modificar el registro."
	#define STR0036 "Desdoblamiento postpago contabilizado."
	#define STR0037 "Archivos adjuntos"
	#define STR0038 "Leyenda"
	#define STR0039 "El desdoblamiento tiene documento(s) adjunto(s). Para indicar la modalidad '#1' es necesario borrar el (los) documento(s) adjunto(s)."
	#define STR0040 "No es posible adjuntar documentos a líneas nuevas."
	#define STR0041 "Confirme la inclusión del registro y acceda nuevamente la opción de documentos adjuntos."
	#define STR0042 "No es posible adjuntar documentos a líneas borradas."
	#define STR0043 "Verifique la situación del registro para acceder a la opción de documentos adjuntos."
	#define STR0044 "No es posible adjuntar documentos en este desdoblamiento."
	#define STR0045 "Verifique la modalidad del desdoblamiento. No se permite la inclusión de documento(s) adjunto(s) para desdoblamientos con modalidades transitorias de pago o transitorias post pago."
	#define STR0046 "Existe(n) documento(s) adjunto(s)"
	#define STR0047 "No existe(n) documento(s) adjunto(s)"
	#define STR0048 "Este desdoblamiento tiene como origen la aprobación de una solicitud de gastos. ¿Desea realmente borrar el desdoblamiento y reprobar la solicitud de gastos?"
	#define STR0049 "Operación anulada."
	#define STR0050 "Desdoblamiento sin eliminar."
	#define STR0051 "Es obligatorio completar el Historial, de acuerdo con el parámetro MV_JHISPAD."
	#define STR0052 "Informe un código válido para el Historial estándar."
	#define STR0053 "La situación de los gastos vinculada al desdoblamiento no permite modificaciones."
	#define STR0054 "Verifique el archivo de gastos '#1'."
	#define STR0055 "Actualizando aprobaciones de gastos..."
#else
	#ifdef ENGLISH
		#define STR0001 "Items of post payment breakdown"
		#define STR0002 "Bill"
		#define STR0003 "Saving"
		#define STR0004 "Updating expense"
		#define STR0005 'Net Value'
		#define STR0006 'Net Value'
		#define STR0007 'Desc. Class'
		#define STR0008 'Nature Description'
		#define STR0009 'Breakdown total'
		#define STR0010 'Breakdown balance'
		#define STR0011 'Currency Code'
		#define STR0012 'Currency code'
		#define STR0013 'Symb. Currency'
		#define STR0014 'Currency Symbol'
		#define STR0015 "Breakdowns linked to Accounts Payable."
		#define STR0016 "Delete the breakdowns to delete the record."
		#define STR0017 'The total value of the breakdown cannot be greater than defined in the transitory nature post payment.'
		#define STR0018 'Maximum value for the breakdown is #1.'
		#define STR0019 "Unable to edit breakdowns in Accounts Payable because the user is not linked to a participant."
		#define STR0020 "Link your user to a participant to access the operation."
		#define STR0021 "No breakdown with class of type 'transitory post-payment'."
		#define STR0022 "Execute transitory breakdown to enable post-payment breakdown."
		#define STR0023 "No balance to breakdown"
		#define STR0024 "Check breakdowns entered in the bill."
		#define STR0025 "No write-off exists for bill with post-payment transitory breakdown."
		#define STR0026 "Write-off to enable post payment breakdown."
		#define STR0027 "Desdobramentos pós pagamento"
		#define STR0028 "Desdobramentos"
		#define STR0029 "Error updating entry "
		#define STR0030 "Updating entries..."
		#define STR0031 "Accounting Calendar Blocked."
		#define STR0032 "Check blocking of process 'PFS001' in Accounting Calendar of branch '#1', for period of entry date."
		#define STR0033 "Unable to change the nature of this split item."
		#define STR0034 "Indicates a nature with the same legal cost center of nature '#'1'."
		#define STR0035 "Unable to edit/delete record."
		#define STR0036 "Post-payment breakdown already accounted."
		#define STR0037 "Attachments"
		#define STR0038 "Caption"
		#define STR0039 "The breakdown has attachment(s). To indicate the nature '#1', delete the attachment(s)."
		#define STR0040 "Unable to attach documents to new lines."
		#define STR0041 "Confirm the inclusion of the record, access the attachments option again."
		#define STR0042 "Unable to attach documents to deleted lines."
		#define STR0043 "Check the status of the record to access the attachments option."
		#define STR0044 "Unable to attach documents in this breakdown."
		#define STR0045 "Check the breakdown nature. You cannot add attachment(s) for breakdowns with transitory natures of payment or post-payment transitory."
		#define STR0046 "There are attachments"
		#define STR0047 "There are no attachments"
		#define STR0048 "This breakdown has its origin the approval of an expense request. Do you really want to delete the breakdown and reject the expense request?"
		#define STR0049 "Operation canceled."
		#define STR0050 "Breakdown not removed."
		#define STR0051 "Completion of Standard History, according to parameter MV_JHISPAD is required."
		#define STR0052 "Enter a valid code for standard history."
		#define STR0053 "The status of the expense linked to breakdown does not allow changes."
		#define STR0054 "Check register of expense '#1'."
		#define STR0055 "Updating Expenses Approvals..."
	#else
		#define STR0001 "Itens de desdobramento pós pagamento"
		#define STR0002 "Título"
		#define STR0003 "Gravando."
		#define STR0004 "Atualizando Despesa..."
		#define STR0005 'Vlr. Líquido'
		#define STR0006 'Valor líquido'
		#define STR0007 'Desc. Natureza'
		#define STR0008 'Descrição Natureza'
		#define STR0009 'Total desdobramento'
		#define STR0010 'Saldo desdobramento'
		#define STR0011 'Cód. Moeda'
		#define STR0012 'Código da Moeda'
		#define STR0013 'Símb. Moeda'
		#define STR0014 'Símbolo da Moeda'
		#define STR0015 "Existe(m) desdobramento(s) vinculado(s) ao Contas a Pagar."
		#define STR0016 "Exclua o(s) desdobramento(s) vinculado(s) para possibilitar a exclusão do registro."
		#define STR0017 'O valor total dos desdobramentos não pode ser maior do que foi definido na natureza transitória pós pagamento.'
		#define STR0018 'O valor máximo para o desdobramento é #1.'
		#define STR0019 "Não será possível manipular os desdobramentos do Contas Pagar, pois o usuário não está vinculado a um participante."
		#define STR0020 "Associe seu usuário a um participante para ter acesso a operação."
		#define STR0021 "Não existe desdobramento com natureza do tipo 'transitória pós pagamento'."
		#define STR0022 "Realize um desdobramento transitório para habilitar o desdobramento pós pagamento."
		#define STR0023 "Não existe saldo para ser desdobrado."
		#define STR0024 "Verifique o(s) desdobramento(s) lançado(s) no título."
		#define STR0025 "Não existe baixa para o título com desdobramento transitório pós pagamento."
		#define STR0026 "Realize uma baixa para habilitar o desdobramento pós pagamento."
		#define STR0027 "Desdobramentos pós pagamento"
		#define STR0028 "Desdobramentos"
		#define STR0029 "Erro ao atualizar lançamento: "
		#define STR0030 "Atualizando Lançamentos..."
		#define STR0031 "Calendário Contábil bloqueado."
		#define STR0032 "Verifique o bloqueio do processo 'PFS001' no Calendário Contábil da filial '#1', para o período da data do lançamento."
		#define STR0033 "Não é possível alterar a natureza desse desdobramento."
		#define STR0034 "Indique uma natureza que possua o mesmo centro de custo jurídico da natureza '#1'."
		#define STR0035 "Não é possível alterar/excluir o registro."
		#define STR0036 "Desdobramento Pós Pagamento já contabilizado."
		#define STR0037 "Anexos"
		#define STR0038 "Legenda"
		#define STR0039 "O desdobramento possui anexo(s). Para indicar a natureza '#1' é necessário excluir o(s) anexo(s)."
		#define STR0040 "Não é possível anexar documentos para linhas novas."
		#define STR0041 "Confirme a inclusão do registro e acesse novamente a opção de anexos."
		#define STR0042 "Não é possível anexar documentos para linhas deletadas."
		#define STR0043 "Verifique a situação do registro para acessar a opção de anexos."
		#define STR0044 "Não é possível anexar documentos neste desdobramento."
		#define STR0045 "Verifique a natureza do desdobramento. Não é permitida a inclusão de anexo(s) para desdobramentos com naturezas transitórias de pagamento ou transitórias pós pagamento."
		#define STR0046 "Há anexo(s)"
		#define STR0047 "Não há anexo(s)"
		#define STR0048 "Esse desdobramento tem como origem a aprovação de uma solicitação de despesa. Deseja realmente excluir o desdobramento e reprovar a solicitação de despesa?"
		#define STR0049 "Operação cancelada."
		#define STR0050 "Desdobramento não removido."
		#define STR0051 "É obrigatório o preenchimento do Histórico Padrão, conforme o parâmetro MV_JHISPAD."
		#define STR0052 "Informe um código válido para o Histórico Padrão."
		#define STR0053 "A situação da despesa vinculada ao desdobramento não permite alterações."
		#define STR0054 "Verifique o cadastro da despesa '#1'."
		#define STR0055 "Atualizando Aprovações de Despesas..."
	#endif
#endif
