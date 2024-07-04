#ifdef SPANISH
	#define STR0001 "Orden de producción no registrada"
	#define STR0002 "Tipo de apunte no se informó"
	#define STR0003 "Orden de producción no se informó"
	#define STR0004 "Cantidad apuntada no se informó."
	#define STR0005 "El tipo de apunte del formulario debe ser del tipo Apunte simplificado (MATA250)"
	#define STR0006 "Parámetros del apunte no enviados o no válidos."
	#define STR0007 "Tipo de movimiento no se informó."
	#define STR0008 "No se informó si el apunte es parcial/total"
	#define STR0009 "No se informó la cantidad que se apuntará."
	#define STR0010 "Operación no informada."
	#define STR0011 "El tipo de apunte del formulario debe ser Producción PCP Mod2 (MATA681)"
	#define STR0012 "¡Enviado a rutina de Apuntes pendientes! - Causa:"
	#define STR0013 "El tipo de apunte del formulario debe ser Producción Piso de fábrica."
	#define STR0014 "No se informó la máquina."
	#define STR0015 "No se informó la fecha inicial de la producción."
	#define STR0016 "No se informó la hora inicial de producción."
	#define STR0017 "No se informó la fecha final de producción."
	#define STR0018 "No se informó la hora final de producción."
	#define STR0019 "No se informó la fecha inicial del setup."
	#define STR0020 "No se informó la fecha final del setup."
	#define STR0021 "No se informó la hora inicial del setup."
	#define STR0022 "No se informó la hora final del setup."
	#define STR0023 "No se informó el código del setup."
	#define STR0024 "No se informó el ID de la operación."
	#define STR0025 "No se informó la cantidad aprobada."
	#define STR0026 "Hubo errores al realizar el apunte."
	#define STR0027 "No se informó el split."
	#define STR0028 "No se informó el ID del split."
	#define STR0029 "Split no registrado."
	#define STR0030 "Operaciones de la orden no registrada."
	#define STR0031 "Máquina no pertenece al Id de la operación."
	#define STR0032 "Operación no pertenece al Id de la operación."
	#define STR0033 "El indicador de apunte Inicial y Final debe ser I(inicial), F(final) o A(abandonar)."
	#define STR0034 "No fue posible encontrar la secuencia del apunte inicial para realizar la finalización."
	#define STR0035 "Serial del apunte inicial no registrado."
	#define STR0036 "No fue posible encontrar la secuencia del apunte inicial para abandonar el apunte."
	#define STR0037 "Solamente apuntes iniciados pueden abandonarse."
	#define STR0038 "Solamente el usuario que inició el apunte pueden abandonarlo."
	#define STR0039 "Apunte abandonado con éxito."
	#define STR0040 "Apunte enviado para pendiente con éxito."
	#define STR0041 "Apunte efectuado con éxito."
	#define STR0042 "Inicio del apunte efectuado con éxito."
	#define STR0043 "Operación no registrada."
	#define STR0044 "Máquina que inició el apunte difiere de la máquina corriente. Para devolver el apunte, debe seleccionarse la máquina que inició el apunte."
	#define STR0045 'Código del formulario no se informó.'
	#define STR0046 'Campo personalizado informado en el PCPA125 (Formulario de apunte) no existe en la tabla SD3.'
	#define STR0047 'Campo personalizado informado en el PCPA125 (Formulario de apunte) no existe en la tabla SH6.'
	#define STR0048 'Campo personalizado informado en el PCPA125 (Formulario de apunte) no existe en la tabla CYV.'
	#define STR0049 'Campo personalizado no se encontró en el formulario de parámetros (PCPA125).'
	#define STR0050 'En el Campo personalizado solamente se permite informar números del tipo Decimal. Valor informado:'
	#define STR0051 'Valor entero informado para el campo personalizado del tipo decimal es superior al definido en el SIGACFG.'
	#define STR0052 'Tamaño entero permitido:'
	#define STR0053 '. Valor informado:'
	#define STR0054 'Valor decimal informado al campo personalizado del tipo decimal es superior al definido en el SIGACFG.'
	#define STR0055 'Decimal permitido:'
	#define STR0056 'Valor informado para el campo personalizado del tipo fecha no válido.'
	#define STR0057 'Valor informado:'
	#define STR0058 'Valor informado para el campo personalizado del tipo lógico difiere del permitido: .T., T, 1, .F. ,F, 0.'
	#define STR0059 'Valor informado para el campo personalizado del tipo carácter es superior al tamaño definido en el SIGACFG.'
	#define STR0060 'Tamaño permitido:'
#else
	#ifdef ENGLISH
		#define STR0001 "Production order not registered."
		#define STR0002 "Type of annotation not entered"
		#define STR0003 "Production order not entered"
		#define STR0004 "Annotated quantity not entered"
		#define STR0005 "The type of annotation of the form must be Simplified (MATA250)"
		#define STR0006 "Annotation parameters not sent or not valid."
		#define STR0007 "Type of transaction not entered"
		#define STR0008 "It was not informed if the annotation is partial/complete"
		#define STR0009 "The quantity was not entered in the annotation"
		#define STR0010 "Operation not informed."
		#define STR0011 "The type of annotation of the form must be Production PCP Mod2 (MATA681)"
		#define STR0012 "Submitted to the Pending Notes routine. - Cause:"
		#define STR0013 "The type of annotation of the form must be Shop Floor Production."
		#define STR0014 "Machine not entered."
		#define STR0015 "Enter the production start date."
		#define STR0016 "Production start time not entered."
		#define STR0017 "Production end date not entered."
		#define STR0018 "Production end time not entered."
		#define STR0019 "Setup start date not entered."
		#define STR0020 "Setup end date not entered."
		#define STR0021 "Setup start time not entered."
		#define STR0022 "Setup end time not entered."
		#define STR0023 "Setup code not entered."
		#define STR0024 "Operation ID not entered."
		#define STR0025 "Approved quantity not entered."
		#define STR0026 "Errors in annotation."
		#define STR0027 "Split not entered."
		#define STR0028 "Split ID not entered."
		#define STR0029 "Split not registered."
		#define STR0030 "Order Operations not registered."
		#define STR0031 "Machine does not belong to the Operation Id."
		#define STR0032 "Operation does not belong to the Operation Id."
		#define STR0033 "The Start and End annotation indicator must be I(start), F(end) or A(discard)."
		#define STR0034 "Unable to locate start annotation sequence to finalize it."
		#define STR0035 "Annotation serial of start not registered."
		#define STR0036 "Unable to locate start annotation sequence to discard the annotation."
		#define STR0037 "Only started annotations can be discarded."
		#define STR0038 "Only the user who started the annotation can discard it."
		#define STR0039 "Annotation successfully discarded."
		#define STR0040 "Annotation successfully sent to pending."
		#define STR0041 "Annotation successfully executed."
		#define STR0042 "Start of Annotation successfully executed."
		#define STR0043 "Operation not registered."
		#define STR0044 "Machine starting the annotation is different than the current machine. To return the annotation, select the machine starting the annotation."
		#define STR0045 'Form Code not entered.'
		#define STR0046 'Custom Field entered in PCPA125 (Annotation Form) not exist in SD3 Table.'
		#define STR0047 'Custom Field entered in PCPA125 (Annotation Form) not exist in SH6 Table.'
		#define STR0048 'Custom Field entered in the PCPA125 (Annotation Form) not exist in the CYV table.'
		#define STR0049 'Custom Field not found in the parameters form (PCPA125).'
		#define STR0050 ' You can enter only numbers in the Customized Field of Decimal type.'
		#define STR0051 'Full value entered for the field customized of the decimal field is greater than the value defined in the SIGACFG.'
		#define STR0052 'Full value allowed:'
		#define STR0053 '. Value entered:'
		#define STR0054 'Decimal value entered for the field customized of the decimal type is greater than the value defined in the SIGACFG.'
		#define STR0055 'Decimal allowed:'
		#define STR0056 'Value entered for the field customized of the date type invalid.'
		#define STR0057 'Value entered:'
		#define STR0058 'Value entered for the field customized of the logic type differs from the value allowed: .T., T, 1, .F. ,F, 0.'
		#define STR0059 'Value entered for the field customized of the character type is greater than the size defined in the SIGACFG.'
		#define STR0060 'Size allowed:'
	#else
		#define STR0001 "Ordem de Produção não cadastrada"
		#define STR0002 "Tipo de apontamento não informado"
		#define STR0003 "Ordem de Produção não informada"
		#define STR0004 "Quantidade apontada não informada."
		#define STR0005 "O tipo de apontamento do formulário deve ser do tipo Apontamento simplificado (MATA250)"
		#define STR0006 "Parâmetros do apontamento não enviados ou inválidos."
		#define STR0007 "Tipo de movimento não informada."
		#define STR0008 "Não foi informado se o apontamento é parcial/total"
		#define STR0009 "Não foi informado a quantidade a ser apontada"
		#define STR0010 "Operação não informada"
		#define STR0011 "O tipo de apontamento do formulário deve ser Produção PCP Mod2 (MATA681)"
		#define STR0012 "Enviado para rotina de Apontamentos Pendentes! - Causa:"
		#define STR0013 "O tipo de apontamento do formulário deve ser Produção Chão de Fábrica."
		#define STR0014 "Não foi informada a máquina."
		#define STR0015 "Não foi informada a data de início da produção."
		#define STR0016 "Não foi informada a hora de início da produção."
		#define STR0017 "Não foi informada a data fim da produção."
		#define STR0018 "Não foi informada a hora fim da produção."
		#define STR0019 "Não foi informada a data de início do setup."
		#define STR0020 "Não foi informada a data final do setup."
		#define STR0021 "Não foi informada a hora de início do setup."
		#define STR0022 "Não foi informada a hora final do setup."
		#define STR0023 "Não foi informado o código do setup."
		#define STR0024 "Não foi informado o ID da operação."
		#define STR0025 "Não foi informada a quantidade aprovada."
		#define STR0026 "Ocorreram erros ao realizar o apontamento."
		#define STR0027 "Não foi informado o split."
		#define STR0028 "Não foi informado o ID do split."
		#define STR0029 "Split não cadastrado."
		#define STR0030 "Operações da Ordem não cadastrada."
		#define STR0031 "Máquina não pertence ao Id da Operação."
		#define STR0032 "Operação não pertence ao Id da Operação."
		#define STR0033 "O indicador de apontamento Início e Fim deve ser I(início), F(fim) ou A(abandonar)."
		#define STR0034 "Não foi possível localizar a sequência do apontamento de inicio para realizar a finalização."
		#define STR0035 "Serial do apontamento de inicio não cadastrado."
		#define STR0036 "Não foi possível localizar a sequência do apontamento de inicio para abandonar o apontamento."
		#define STR0037 "Somente apontamentos iniciados podem ser abandonados."
		#define STR0038 "Somente o usuário que iniciou o apontamento pode abandoná-lo."
		#define STR0039 "Apontamento abandonado com sucesso."
		#define STR0040 "Apontamento enviado para pendente com sucesso."
		#define STR0041 "Apontamento efetuado com sucesso."
		#define STR0042 "Inicio do Apontamento efetuado com sucesso."
		#define STR0043 "Operação não cadastrada."
		#define STR0044 "Máquina que iniciou o apontamento difere da máquina corrente. Para retomar o apontamento deve ser selecionada a máquina que iniciou o apontamento."
		#define STR0045 'Código do Formulário não informado.'
		#define STR0046 'Campo Customizado informado no PCPA125 (Formulário de Apontamento) não existe na tabela SD3.'
		#define STR0047 'Campo Customizado informado no PCPA125 (Formulário de Apontamento) não existe na tabela SH6.'
		#define STR0048 'Campo Customizado informado no PCPA125 (Formulário de Apontamento) não existe na tabela CYV.'
		#define STR0049 'Campo Customizado não encontrado no formulário de parâmetros (PCPA125).'
		#define STR0050 'É permitido informar somente números no Campo Customizado do tipo Decimal. Valor informado: '
		#define STR0051 'Valor inteiro informado para o campo customizado do tipo decimal é maior que o definido no SIGACFG. '
		#define STR0052 'Tamanho inteiro permitido: '
		#define STR0053 '. Valor informado: '
		#define STR0054 'Valor decimal informado para o campo customizado do tipo decimal é maior que o definido no SIGACFG. '
		#define STR0055 'Decimal permitido: '
		#define STR0056 'Valor informado para o campo customizado do tipo data inválido.'
		#define STR0057 'Valor informado: '
		#define STR0058 'Valor informado para o campo customizado do tipo lógico difere do permitido: .T., T, 1, .F. ,F, 0.'
		#define STR0059 'Valor informado para o campo customizado do tipo caracter é maior que o tamanho definido no SIGACFG. '
		#define STR0060 'Tamanho permitido: '
	#endif
#endif
