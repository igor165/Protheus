#ifdef SPANISH
	#define STR0001 "Prorrateo de gastos de depreciación de prorrateo de activo fijo"
	#define STR0002 "Alias SNV no existe."
	#define STR0003 "Funcionalidad disponible solamente para la localización de Argentina."
	#define STR0004 "Buscar"
	#define STR0005 "Visualizar"
	#define STR0006 "Incluir"
	#define STR0007 "Modificar"
	#define STR0008 "Borrar"
	#define STR0009 "Bloq/Desbloq"
	#define STR0010 "Generar Rev."
	#define STR0011 "Vincular"
	#define STR0012 "Leyenda"
	#define STR0013 "La revisión de este archivo de Prorrateo que se desea modificar ou borrar no es la más actual."
	#define STR0014 "Este archivo de Prorrateo no puede desbloquearse, porque tiene una revisión más actual."
	#define STR0015 "Este Prorrateo no puede bloquearse, pues esta finalizado."
	#define STR0016 "Generar revisión solamente para los prorrateos que estén disponibles, vinculados a bienes o bloqueados."
	#define STR0017 "Solamente los prorrateos disponibles pueden vincularse con algun bien (Activo)."
	#define STR0018 "Vincular Prorrateo con Bien"
	#define STR0019 "&Filtro"
	#define STR0020 "&Ok"
	#define STR0021 "&Anular"
	#define STR0022 "Elección de prorrateo configurado previamente"
	#define STR0023 "Prorrateo de gastos de depreciación"
	#define STR0024 "% Prorrateado:"
	#define STR0025 "% Por prorratear:"
	#define STR0026 "Porcentaje prorrateado no puede asumir un valor superior a 100."
	#define STR0027 "Porcentaje por prorratear no puede asumir un valor por inferior a 0."
	#define STR0028 "Porcentaje con valor cero. Defina un valor superior a cero. Error ocurrido en la secuencia "
	#define STR0029 "No se completó ninguno de los entes contables. Complete por lo menos uno de estos. [Centro de costo, Cuenta contable, Ítem de la cuenta o clase de valor]. Error en la secuencia"
	#define STR0030 "No se permite repetir los mismos entes contables en líneas diferentes del prorrateo. Por lo menos una de estas debe estar diferente."
	#define STR0031 "El porcentaje distribuido no alcanzó el 100%."
	#define STR0032 "Prorrateo disponible"
	#define STR0033 "Prorrateo vinculado a bien (Activo)"
	#define STR0034 "Pendiente de clasificación"
	#define STR0035 "Activo dado de bajado"
	#define STR0036 "Prorrateo finalizado"
	#define STR0037 "Prorrateo bloqueado"
	#define STR0038 "Clasificación de los prorrateos"
	#define STR0039 "Existe algún movimiento ocurrido para este prorrateo."
	#define STR0040 "Función AdmDiffArray(...) no compilada. ¡El prorrateo no se conservará en la base (no generado)! Entre en contacto con el administrador del sistema o con el soporte técnico."
	#define STR0041 'Para utilizar este informe, es necesario que los procesos de depreciación de bienes estén implementados con un control de prorrateo. Por favor, actualice el entorno.'
	#define STR0042 "Este prorrateo está vinculado a un bien y no puede borrarse"
#else
	#ifdef ENGLISH
		#define STR0001 "Apportionment of expenses for depreciation of fixed assets"
		#define STR0002 "Alias SNV does not exist."
		#define STR0003 "Feature available only for Argentina localization."
		#define STR0004 "Search"
		#define STR0005 "View"
		#define STR0006 "Add"
		#define STR0007 "Edit"
		#define STR0008 "Delete"
		#define STR0009 "Block/Unblock"
		#define STR0010 "Generate Rev."
		#define STR0011 "Link"
		#define STR0012 "Caption"
		#define STR0013 "The revision of the Apportionment register you want to edit or delete is not the most current."
		#define STR0014 "This Apportionment register cannot be unblocked, because he has a more current review."
		#define STR0015 "This Apportion cannot be blocked because it is finished."
		#define STR0016 "Generate review only for apportionment available, linked to assets or blocked."
		#define STR0017 "Only available apportionments can be linked to some Good (Asset)."
		#define STR0018 "Link Apportionment to Asset"
		#define STR0019 "&Filter"
		#define STR0020 "&Ok"
		#define STR0021 "&Cancel"
		#define STR0022 "Pre-configured Apportionment Selection"
		#define STR0023 "Apportionment of Expenses for Depreciation"
		#define STR0024 "% Apportioned:"
		#define STR0025 "% To be apportioned:"
		#define STR0026 "Apportioned percentage cannot have value above 100."
		#define STR0027 "Percentage to be apportioned cannot have value below 0."
		#define STR0028 "Percentage Zeroed. Define a value higher than zero. Error occurred in the Sequence "
		#define STR0029 "None of the accounting entities have been filled out. Fill out at least one of them. [Cost Center, Ledger Account, account item or value class]. Error in the sequence "
		#define STR0030 "You cannot repeat the same accounting entities on different lines of apportionment. At least one of them must be different."
		#define STR0031 "The percentage distributed did not reach 100%."
		#define STR0032 "Apportionment Available"
		#define STR0033 "Apportionment linked to Good (Asset)"
		#define STR0034 "Pending classification"
		#define STR0035 "Asset Written-off"
		#define STR0036 "Apportionment Finished"
		#define STR0037 "Apportionment Blocked"
		#define STR0038 "Apportionment Classification"
		#define STR0039 "There is some movement occurred for this apportionment."
		#define STR0040 "AdmDiffArray(...) function not compiled. Proration will not be held onto in base (not generated)! Contact systems administrator or technical support."
		#define STR0041 'To use this report, depreciation processes goods with apportionment control must be implemented. Please, update environment'
		#define STR0042 "The apportionment is linked to an asset and cannot be deleted"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Rateio de despesas de depreciação do imobilizado", "Rateio de despesas de depreciacao do imobilizado" )
		#define STR0002 "Alias SNV não existe."
		#define STR0003 "Funcionalidade disponível somente para a localização da Argentina."
		#define STR0004 "Pesquisar"
		#define STR0005 "Visualizar"
		#define STR0006 "Incluir"
		#define STR0007 "Alterar"
		#define STR0008 "Excluir"
		#define STR0009 "Bloq/Desbloq"
		#define STR0010 "Gerar Rev."
		#define STR0011 "Vincular"
		#define STR0012 "Legenda"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "A revisão deste registo de Rateio que deseja-se alterar ou excluir não é a mais actual.", "A revisao deste cadastro de Rateio que deseja-se alterar ou excluir não é a mais atual." )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Este registo de Rateio não pode ser desbloqueado porque ele já possui uma revisão mais actual.", "Este cadastro de Rateio não pode ser desbloqueado, porque ele já possui uma revisão mais atual." )
		#define STR0015 "Este Rateio não pode ser bloqueado, pois está finalizado."
		#define STR0016 "Gerar revisão somente para os rateios que estejam disponíveis, vinculados a bens ou bloqueados."
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Somente rateios disponíveis poderão ser vinculados com algum Bem (Activo).", "Somente rateios disponíveis poderão ser vinculados com algum Bem (Ativo)." )
		#define STR0018 "Vincular Rateio com Bem"
		#define STR0019 "&Filtro"
		#define STR0020 "&Ok"
		#define STR0021 "&Cancelar"
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Escolha de Rateio Pré-Configurado", "Escolha de Rateio Pre-Configurado" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Rateio de Despesas de Depreciação", "Rateio de Despesas de Depreciacao" )
		#define STR0024 "% Rateado:"
		#define STR0025 "% A ratear:"
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Percentagem rateada não pode assumir valor acima de 100.", "Percentual Rateado não pode assumir valor acima de 100." )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Percentagem a ratear não pode assumir valor abaixo de 0.", "Percentual A Ratear não pode assumir valor Abaixo de 0." )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Percentagem zerada. Defina um valor maior que zero. Erro ocorrido na sequência ", "Percentual Zerado. Defina um valor maior que zero. Erro ocorrido na Sequência " )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Nenhuma das entidades contabilísticas foram preenchidas. Preencha ao menos uma delas. [Centro de Custo, Conta Contabilística, Item da Conta ou Classe de Valor]. Erro na seqüência. ", "Nenhuma das entidades contábeis foram preenchidas. Preencha ao menos uma delas. [Centro de Custo, Conta Contábil, Item da conta ou classe de valor]. Erro na sequência " )
		#define STR0030 "Não é permitido repetir as mesmas entidades contábeis em linhas diferentes do rateio. Ao menos uma delas deve estar diferente."
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "A percentagem distribuída não alcançou 100%.", "O percentual distribuído não alcançou 100%." )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Rateio disponível", "Rateio Disponível" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Rateio vinculado a bem (Activo)", "Rateio vinculado a Bem (Ativo)" )
		#define STR0034 "Pendente de classificação"
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "Activo Liquidado", "Ativo Baixado" )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Rateio finalizado", "Rateio Finalizado" )
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "Rateio bloqueado", "Rateio Bloqueado" )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "Classificação dos rateios", "Classificação dos Rateios" )
		#define STR0039 "Existe alguma movimentação ocorrida para este rateio."
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "Função AdmDiffArray(...) não compilada. O rateio não será persistido em base (não gerado). Entre em contacto com administrador de sistemas ou o suporte técnico.", "Função AdmDiffArray(...) não compilada. O rateio não será persistido em base (não gerado)! Entre em contato com administrador de sistemas ou o suporte técnico." )
		#define STR0041 If( cPaisLoc $ "ANG|PTG", 'Para utilizar este relatório, é necessário que estejam implementados os processos de Depreciação de bens com controlo de rateio. Por favor, actualize o ambiente', 'Para utilizar este relatório, é necessário que estejam implementados os processos de Depreciação de bens com controle de rateio. Por favor, atualize o ambiente' )
		#define STR0042 "Este rateio está vinculado a um bem e não pode ser excluído"
	#endif
#endif
