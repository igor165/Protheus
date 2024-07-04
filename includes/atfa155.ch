#ifdef SPANISH
	#define STR0001 "Ampliación"
	#define STR0002 "Módulo SIGAATF desactualizado, por favor, actualice con el último update"
	#define STR0003 "Leyenda"
	#define STR0004 "Mismo bien (Tipo 11)"
	#define STR0005 "Nuevo bien (Incorporación)"
	#define STR0006 "Vinculada"
	#define STR0007 "Propia"
	#define STR0008 "Vida útil"
	#define STR0009 "Valor"
	#define STR0010 "Ambos"
	#define STR0011 "(Meses)"
	#define STR0012 "(Años)"
	#define STR0013 "El bien marcado no tiene ampliaciones de tipo 11 que puedan revertirse. Para revertir ampliaciones de tipo incorporación, utilice la opción borrar en el archivo de activo"
	#define STR0014 "¡No es posible revertir la ampliación, pues esta tiene calendario de ejercicio completo!"
	#define STR0015 "No es posible revertir la ampliación, pues esta tiene movimientos"
	#define STR0016 "Este bien fue dado de baja, no puede tener ampliación."
	#define STR0017 "Este bien está bloqueado, no puede tener ampliación."
	#define STR0018 "La fecha de adquisición del bien es igual o inferior a la fecha de bloqueo del movimiento: "
	#define STR0019 "La Database del sistema debe tener la subsiguiente al mes del parametro MV_ULTDEPR = "
	#define STR0020 "Datos del bien: Original"
	#define STR0021 "Datos de la operación"
	#define STR0022 "Método"
	#define STR0023 "Tipo de vida útil"
	#define STR0024 "Acción"
	#define STR0025 "Vida útil "
	#define STR0026 "Vida útil actual"
	#define STR0027 "Transcurrida"
	#define STR0028 "Datos del bien: Incorporación"
	#define STR0029 "Para la ampliación de la vida útil debe informarse por lo menos 12 meses más que la vida útil actual que es de: "
	#define STR0030 "Para la ampliación de la vida útil debe informarse por lo menos 1 año más que la vida útil actual que es de: "
	#define STR0031 "Para esta configuración, la Tasa de depreciación debe informarse en Incorporación: campo "
	#define STR0032 "Para la acción seleccionada es necesario informar el valor en Incorporación: campo "
	#define STR0033 "Buscar"
	#define STR0034 "Visualizar"
	#define STR0035 "Reversión"
	#define STR0036 "Mismo ítem (Tipo 01)"
	#define STR0037 "Este campo no se utiliza en el método de depreciación seleccionado, el valor informado no se considerará."
	#define STR0038 "Criterio de depreciación no es válido para el tipo del referido activo"
	#define STR0039 "Método válido solamente para acción = Vida útil"
	#define STR0040 "El bien marcado tuvo modificación de tasa y no podrá revertirse"
	#define STR0041 "Tracker contable"
#else
	#ifdef ENGLISH
		#define STR0001 "Expansion"
		#define STR0002 "SIGAATF module outdated, please apply the last update"
		#define STR0003 "Caption"
		#define STR0004 "Same Asset (Type 11)"
		#define STR0005 "New Asset (Incorporation)"
		#define STR0006 "Attached"
		#define STR0007 "Own"
		#define STR0008 "Useful Life"
		#define STR0009 "Amount"
		#define STR0010 "Both"
		#define STR0011 "(Months)"
		#define STR0012 "(Years)"
		#define STR0013 "Well positioned has no reversible expansions type 11. To reverse expansions type incorporation, use the option delete in the active register"
		#define STR0014 "It is not possible to reverse the expansion, for it has a complete exercise schedule"
		#define STR0015 "It is not possible to reverse the expansion, for it has transactions"
		#define STR0016 "This Asset has been written off and it cannot experience expansions."
		#define STR0017 "This item is blocked, it cannot experience expansion."
		#define STR0018 "The asset acquisition date is equal to or earlier than the transaction stoppage date: "
		#define STR0019 "The system Database must have subsequent to month of parameter MV_ULTDEPR = "
		#define STR0020 "Asset Data: Original"
		#define STR0021 "Operation Data"
		#define STR0022 "Method"
		#define STR0023 "Type of Useful Life"
		#define STR0024 "Action"
		#define STR0025 "Useful Life "
		#define STR0026 "Current Useful Life"
		#define STR0027 "Elapsed"
		#define STR0028 "Asset Data: Annexation"
		#define STR0029 "To expand the useful life, enter at least 12 months more than current useful life which is: "
		#define STR0030 "To expand the useful life, enter at least 1 year more than current useful life which is: "
		#define STR0031 "For this configuration the Depreciation Rate must be entered in Annexation: field "
		#define STR0032 "For the operation selected you must enter the value in Annexation: field "
		#define STR0033 "Search"
		#define STR0034 "View"
		#define STR0035 "Reversal"
		#define STR0036 "Same Item (Type 01)"
		#define STR0037 "This field is not used by the selected method of depreciation, the entered value is not considered."
		#define STR0038 "Depreciation criterion not valid for asset type at issue"
		#define STR0039 "Method Valid only for action = Life Cycle"
		#define STR0040 "The asset selected had its rate edited and cannot be reversed"
		#define STR0041 "Accounting Tracker"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Ampliação", "Ampliacao" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Módulo SIGAATF desactualizado. Por favor, actualizar com o último update.", "Modulo SIGAATF desatualizado, por favor atualizar com o ultimo update" )
		#define STR0003 "Legenda"
		#define STR0004 "Mesmo Bem (Tipo 11)"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Novo Bem (Incorporação)", "Novo Bem (Incorporacao)" )
		#define STR0006 "Vinculada"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Própria", "Propria" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Vida útil", "Vida Util" )
		#define STR0009 "Valor"
		#define STR0010 "Ambos"
		#define STR0011 "(Meses)"
		#define STR0012 "(Anos)"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Bem posicionado, não possui ampliações de tipo 11 que possam ser estornadas. Para estornar ampliações do tipo incorporação, utilize a opção eliminar no registo de activo", "Bem posicionado não possui ampliações de tipo 11 que possam ser estornadas. Para estornar ampliações do tipo incorporação, utilizar a opção excluir no cadastro de ativo" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Não é possível estornar a ampliação, pois ela possui calendário de exercício completo.", "Não é possível estornar a ampliação, pois a mesma possui calendário de exercício completo!" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Não é possível estornar a ampliação, pois ela possui movimentações.", "Não é possível estornar a ampliação, pois a mesma possui movimentaçoes" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Este bem foi liquidado, não pode sofrer ampliação.", "Este bem foi baixado, não pode sofrer ampliação." )
		#define STR0017 "Este bem está bloqueado, não pode sofrer ampliação."
		#define STR0018 "A data de aquisição do bem é igual ou menor que a data de bloqueio de movimentação : "
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "A Database do sistema deve ter o subseqüente ao mês do parâmetro MV_ULTDEPR = ", "A Database do sistema deve ter o subsequente ao mês do parâmetro MV_ULTDEPR = " )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Dados do bem: Original", "Dados do Bem: Original" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Dados da operação", "Dados da Operacao" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Método", "Metodo" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Tipo de vida útil", "Tipo de Vida Util" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Acção", "Acao" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Vida útil ", "Vida Util " )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Vida útil actual", "Vida Util Atual" )
		#define STR0027 "Transcorrida"
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Dados do bem: Incorporação", "Dados do Bem: Incorporacao" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Para ampliação da vida útil, deve ser informado ao menos 12 meses a mais que a vida útil actual, que é de : ", "Para ampliação da vida útil deve ser informado ao menos 12 meses a mais que a vida útil atual que é de : " )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Para ampliação da vida útil, deve ser informado ao menos 1 ano a mais que a vida útil actual, que é de : ", "Para ampliação da vida útil deve ser informado ao menos 1 ano a mais que a vida útil atual que é de : " )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Para esta configuração, a taxa de depreciação deve ser informada em incorporação: campo ", "Para esta configuração a Taxa de Depreciação deve ser informada em Incorporacao: campo " )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Para acção seleccionada é necessário informar o valor em incorporação: campo ", "Para ação selecionada é necessário informar o valor em Incorporacao: campo " )
		#define STR0033 "Pesquisar"
		#define STR0034 "Visualizar"
		#define STR0035 "Estorno"
		#define STR0036 "Mesmo Item (Tipo 01)"
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "Esse campo não é utilizado pelo método de depreciação seleccionado; o valor informado não será considerado.", "Esse campo não é utilizado pelo método de depreciação selecionado, o valor informado não será considerado." )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "O critério de depreciação não é valido para o tipo de activo em questão", "Critério de depreciação não é valido para o tipo de ativo em questão" )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Método válido apenas para Acção = Vida útil", "Metodo Valido apenas para Acao = Vida Util" )
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "O bem seleccionado sofreu alteração de taxa e não poderá ser estornado", "Bem posicionado sofreu alteração de taxa e não podera ser estornado" )
		#define STR0041 "Tracker Contábil"
	#endif
#endif
