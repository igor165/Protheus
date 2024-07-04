#ifdef SPANISH
	#define STR0001 "Campo"
	#define STR0002 "T�tulo"
	#define STR0003 "Descripci�n"
	#define STR0004 "Campos del sistema"
	#define STR0005 "del cliente:"
	#define STR0006 "del proveedor:"
	#define STR0007 "C�lculo ya liberado, no se permite una nueva liberaci�n."
	#define STR0008 "Seleccione c�lculos que tengan el estatus igual a 'Esperando liberaci�n'"
	#define STR0009 "Confirma la liberaci�n del c�lculo: #1 "
	#define STR0010 "Liberando c�lculo..."
	#define STR0011 "C�lculo no liberado, no se permite la reversi�n."
	#define STR0012 "Seleccione c�lculos que tengan el estatus igual a 'C�lculo pendiente'"
	#define STR0013 "Confirma reversi�n de la liberaci�n del c�lculo: #1 "
	#define STR0014 "Revertida la liberaci�n del c�lculo..."
	#define STR0015 "No puede revertirse el c�lculo."
	#define STR0016 "Este c�lculo tiene �tems financieros que se finalizaron."
	#define STR0017 "No se permite generar ajuste de un ajuste."
	#define STR0018 "No se permite generar ajuste de DOC/ADM/ACM."
	#define STR0019 "No se permite generar ajuste de Servicio propio."
	#define STR0020 "No se permite generar ajuste de �tem que se fraccion� o anul�."
	#define STR0021 "Este �tem ya tiene ajuste."
	#define STR0022 "El contacto informado no es solicitante."
	#define STR0023 "Selecci�n de operaciones"
	#define STR0024 "Condici�n de pago del Tipo 9 sin el archivo de complemento."
	#define STR0025 "Condici�n de pago no registrada."
	#define STR0026 "Selecci�n de monedas"
	#define STR0027 "Marca"
	#define STR0028 "Desmarca"
	#define STR0029 "Id del formulario de origen: "
	#define STR0030 "Id del campo de origen: "
	#define STR0031 "Id del formulario de error: "
	#define STR0032 "Id del campo de error: "
	#define STR0033 "Id del error: "
	#define STR0034 "Mensaje de error: "
	#define STR0035 "Mensaje de la soluci�n: "
	#define STR0036 "Valor atribuido: "
	#define STR0037 "Valor anterior: "
	#define STR0038 "El contacto no est� asociado para este cliente"
	#define STR0039 ' no se encontr� en el De/A'
	#define STR0040 "Falla al conectar: #1"
	#define STR0041 "Falla al definir el tiempo de espera de env�o."
	#define STR0042 "Falla al autenticar: #1"
	#define STR0043 "No fue posible adjuntar archivo. El env�o del mensaje se interrumpir�."
	#define STR0044 "Falla al enviar el e-mail: #1"
	#define STR0045 "Es necesario especificar una modalidad."
	#define STR0046 "Verifique si la modalidad informada est� clasificada correctamente. Solo modalidades del titpo anal�tico se aceptar�n para este proceso."
	#define STR0047 "La modalidad no podr� utilizarse en esta rutina."
	#define STR0048 "No se encontr� la modalidad informada."
	#define STR0049 "Par�metro de integraci�n con el m�dulo Turismo (MV_INTTUR) desactivado."
	#define STR0050 "Active el par�metro para utilizar esta condici�n de pago."
	#define STR0051 "No existen �tems de acuerdos aplicados para que sean liberados. Verifique el c�lculo"
	#define STR0052 "Sin �tems."
	#define STR0053 "Atenci�n"
	#define STR0054 "Por favor, verifique el Archivo del proveedor, pues este no tiene su c�digo como cliente registrado."
	#define STR0055 " Estas tablas no tienen modos de acceso "
	#define STR0056 "(Empresa, Unidad de negocio y Sucursal que se compartan o sean exclusivos) equivalentes. "
	#define STR0057 "Entre en contacto con el administrador del sistema."
	#define STR0058 "Modos de acceso de las tablas divergen."
	#define STR0059 "Exclusivo"
	#define STR0060 "Uso compartido"
	#define STR0061 "La tabla #1 tiene modo de acceso "
	#define STR0062 "- tanto Empresa, Unidad de negocio como Sucursal - que difiere (al menos uno) de "
	#define STR0063 "Modos de acceso de las tablas divergen."
	#define STR0064 "No se pudo desvincular el c�lculo de los �tems financieros."
	#define STR0065 "No se pudo desvincular el c�lculo de los acuerdos aplicados."
	#define STR0066 "�C�lculo de metas ya tiene Conciliaci�n aprobada!"
	#define STR0067 "Verifique este c�lculo de metas por medio de la Conciliaci�n de metas"
	#define STR0068 "Sucursal+C�d. C�lculo"
	#define STR0069 "Funci�n:"
	#define STR0070 " L�nea: "
	#define STR0071 "Fecha/Hora: "
	#define STR0072 "Tiempo total: "
	#define STR0073 "Tiempo de la rutina "
	#define STR0074 "�tem de venta bloqueado (G3Q) : "
	#define STR0075 "Documento de reserva bloqueado (G3R) : "
	#define STR0076 "Camino del archivo"
	#define STR0077 "Problema de numeraci�n"
	#define STR0078 "El documento de reserva se encuentra en conciliaci�n."
	#define STR0079 "Retire el documento de reserva de la conciliaci�n antes de proseguir."
#else
	#ifdef ENGLISH
		#define STR0001 "Field"
		#define STR0002 "Bill"
		#define STR0003 "Description"
		#define STR0004 "System Fields"
		#define STR0005 "of the customer:"
		#define STR0006 "of the supplier:"
		#define STR0007 "Calculation already released, a new release is not allowed."
		#define STR0008 "Choose calculation with status 'Waiting Release'"
		#define STR0009 "Confirm calculation release: #1 "
		#define STR0010 "Release Calculation..."
		#define STR0011 "Calculation not released, you cannot perform return."
		#define STR0012 "Choose calculation with status 'Open Calculation'"
		#define STR0013 "Confirm reversal of calculation release: #1 "
		#define STR0014 "Reversing Calculation Release..."
		#define STR0015 "Calculation cannot be reversed."
		#define STR0016 "This calculation has completed financial items. "
		#define STR0017 "You cannot generate adjustment of adjust."
		#define STR0018 "You cannot generate adjustment of DOC/ADM/ACM."
		#define STR0019 "You cannot generate adjustment of adjust."
		#define STR0020 "You cannot generate adjust of item that was partioned or canceled."
		#define STR0021 "This item already has adjustment!"
		#define STR0022 "The contact entered is not a requester."
		#define STR0023 "Selection of Operations"
		#define STR0024 "Type 9 payment term without complement register."
		#define STR0025 "Payment term not registered."
		#define STR0026 "Selection of Currencies"
		#define STR0027 "Brand"
		#define STR0028 "Uncheck"
		#define STR0029 "Id of source form: "
		#define STR0030 "Id of the origin field: "
		#define STR0031 "Id of error form: "
		#define STR0032 "ID of error field: "
		#define STR0033 "Error ID: "
		#define STR0034 "Error message: "
		#define STR0035 "Solution message: "
		#define STR0036 "Value assigned: "
		#define STR0037 "Previous value: "
		#define STR0038 "The contact not linked to this Customer"
		#define STR0039 ' Not found in From/To'
		#define STR0040 "Failed to connect: #1"
		#define STR0041 "Failure defining the waiting time for delivery."
		#define STR0042 "Failed to authenticate: #1"
		#define STR0043 "Unable to attach file. The delivery of e-mail is aborted."
		#define STR0044 "Failure sending e-mail: #1"
		#define STR0045 "Specify class."
		#define STR0046 "Check if entered class is properly classified. Only detailed classes are accepted for this process."
		#define STR0047 "Class can not be used in this routine."
		#define STR0048 "Class indicated was not found."
		#define STR0049 "Parameter of Integration with Touristic Module (MV_INTTUR) deactivated."
		#define STR0050 "Activate parameter to use this payment term."
		#define STR0051 "No agreement items applied to be released. Check calculation."
		#define STR0052 "No items"
		#define STR0053 "Attention"
		#define STR0054 "Check supplier's register because they do not have your code as registered customer."
		#define STR0055 " These tables do not have equivalent access mode "
		#define STR0056 "(Company, Business Unit, and Branch that are shared or exclusive). "
		#define STR0057 "Contact the system administrator."
		#define STR0058 "Access mode of tables diverge."
		#define STR0059 "Exclusive"
		#define STR0060 "Shared"
		#define STR0061 "Table #1 has access mode "
		#define STR0062 "- Company, Business Unit and Branch - that diverges (at least one) from "
		#define STR0063 "Access mode of tables diverge."
		#define STR0064 "Unable to dissociate calculation from financial items."
		#define STR0065 "Unable to dissociate calculation from applied agreements."
		#define STR0066 "Calculation of Goals already have Approved Conciliation!"
		#define STR0067 "Check this calculation of goals through Conciliation of Goals"
		#define STR0068 "Branch+Code Calculation"
		#define STR0069 "Function:"
		#define STR0070 " Row: "
		#define STR0071 "Date/Time: "
		#define STR0072 "Total Time: "
		#define STR0073 "Routine time "
		#define STR0074 "Sales Item blocked (G3Q): "
		#define STR0075 "Reservation document blocked (G3R): "
		#define STR0076 "File Path"
		#define STR0077 "Numbering Problem"
		#define STR0078 "Reservation document in reconciliation"
		#define STR0079 "Remove reservation document from reconciliation before continuing"
	#else
		#define STR0001 "Campo"
		#define STR0002 "T�tulo"
		#define STR0003 "Descri��o"
		#define STR0004 "Campos do Sistema"
		#define STR0005 "do cliente:"
		#define STR0006 "do fornecedor:"
		#define STR0007 "Apura��o j� liberada, n�o � permitido uma nova libera��o."
		#define STR0008 "Escolha apura��es que estejam com o status igual a 'Aguardando Libera��o'"
		#define STR0009 "Confirma a libera��o da apura��o: #1 "
		#define STR0010 "Liberando Apura��o..."
		#define STR0011 "Apura��o n�o foi liberada, n�o � permitido realizar estorno."
		#define STR0012 "Escolha apura��es que estejam com o status igual a 'Apura��o em Aberto'"
		#define STR0013 "Confirma o estorno da libera��o da apura��o: #1 "
		#define STR0014 "Estornando Libera��o da Apura��o..."
		#define STR0015 "Apura��o n�o pode ser estornada."
		#define STR0016 "Esta apura��o possui itens financeiros que foram finalizados."
		#define STR0017 "N�o � permitido gerar acerto de um acerto."
		#define STR0018 "N�o � permitido gerar acerto de DOC/ADM/ACM."
		#define STR0019 "N�o � permitido gerar acerto de Servi�o Pr�prio."
		#define STR0020 "N�o � permitido gerar acerto de item que foi particionado ou cancelado."
		#define STR0021 "Este item j� possui acerto."
		#define STR0022 "O contato informado n�o � solicitante."
		#define STR0023 "Sele��o de Opera��es"
		#define STR0024 "Condi��o de pagamento do Tipo 9 sem o cadastro de complemento."
		#define STR0025 "Condi��o de pagamento n�o cadastrada."
		#define STR0026 "Sele��o de Moedas"
		#define STR0027 "Marca"
		#define STR0028 "Desmarca"
		#define STR0029 "Id do formul�rio de origem: "
		#define STR0030 "Id do campo de origem: "
		#define STR0031 "Id do formul�rio de erro: "
		#define STR0032 "Id do campo de erro: "
		#define STR0033 "Id do erro: "
		#define STR0034 "Mensagem do erro: "
		#define STR0035 "Mensagem da solu��o: "
		#define STR0036 "Valor atribu�do: "
		#define STR0037 "Valor anterior: "
		#define STR0038 "O contato n�o est� vinculado para esse Cliente"
		#define STR0039 ' N�o encontrado no D�/Para'
		#define STR0040 "Falha ao conectar: #1"
		#define STR0041 "Falha ao definir tempo de espera de envio."
		#define STR0042 "Falha ao autenticar: #1"
		#define STR0043 "N�o foi poss�vel anexar arquivo. O envio do e-mail ser� abortado."
		#define STR0044 "Falha ao enviar o e-mail: #1"
		#define STR0045 "� preciso especificar uma natureza."
		#define STR0046 "Verifique se a natureza informada est� classificada corretamente. Apenas naturezas do titpo anal�tico ser�o aceitas para este processo."
		#define STR0047 "A natureza n�o poder� ser usada nesta rotina."
		#define STR0048 "A natureza informada n�o foi encontrada."
		#define STR0049 "Par�metro de integra��o com M�dulo Turismo (MV_INTTUR) desativado."
		#define STR0050 "Ative o par�metro para utilizar esta condi��o de pagamento."
		#define STR0051 "N�o h� itens de acordos aplicados para serem liberados. Verifique a apura��o."
		#define STR0052 "Sem Itens"
		#define STR0053 "Aten��o"
		#define STR0054 "Favor verificar o cadastro do Fornecedor, pois ele n�o possui seu c�digo como cliente cadastrado."
		#define STR0055 " Estas Tabelas n�o possuem modos de acesso "
		#define STR0056 "(Empresa, Unidade de Neg�cio e Filial que sejam compartilhados ou exclusivos) equivalentes. "
		#define STR0057 "Entrem em contato com o administrador do sistema."
		#define STR0058 "Modos de acesso das tabelas divergem."
		#define STR0059 "Exclusivo"
		#define STR0060 "Compartilhado"
		#define STR0061 "A Tabela #1 possui modo de Acesso "
		#define STR0062 "- tanto Empresa, Unidade de neg�cio quanto Filial - que difere (ao menos um) de "
		#define STR0063 "Modos de acesso das tabelas divergem."
		#define STR0064 "N�o foi poss�vel desvincular a apura��o dos itens financeiros."
		#define STR0065 "N�o foi poss�vel desvincular a apura��o dos acordos aplicados."
		#define STR0066 "Apura��o de Metas j� possui Concilia��o Aprovada!"
		#define STR0067 "Verifique esta apura��o de metas atrav�s da Concilia��o de Metas"
		#define STR0068 "Filial+Cod. Apura��o"
		#define STR0069 "Fun��o:"
		#define STR0070 " Linha: "
		#define STR0071 "Data/Hora: "
		#define STR0072 "Tempo Total: "
		#define STR0073 "Tempo da rotina "
		#define STR0074 "Item de Venda bloqueado (G3Q) : "
		#define STR0075 "Documento de Reserva bloqueado (G3R) : "
		#define STR0076 "Caminho do Arquivo"
		#define STR0077 "Problema de Numera��o"
		#define STR0078 "O documento de reserva se encontra em concilia��o."
		#define STR0079 "Retire o documento de reserva da concilia��o antes de prosseguir."
	#endif
#endif
