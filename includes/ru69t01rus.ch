#ifdef SPANISH
	#define STR0001 "Contratos legales"
	#define STR0002 "Visiуn"
	#define STR0003 "Incluir"
	#define STR0004 "Editar"
	#define STR0005 "Borrar"
	#define STR0006 "Intervalo de tiempo"
	#define STR0007 "Datos principales"
	#define STR0008 "Datos del contrato"
	#define STR0009 "Contrato legal"
	#define STR0010 "Informe el cliente o el proveedor"
	#define STR0011 "El contrato legal no puede tener proveedor y cliente informados"
	#define STR0012 "No existe intervalo de tiempo registrado para esta fecha"
	#define STR0013 "Intervalo de tiempo solamente se permite para actualizaciуn y visualizaciуn de operaciones"
	#define STR0014 "La entidad vinculada no puede encontrarse"
	#define STR0015 "No puede haber intersecciуn de intervalo de tiempo. Verifique la lнnea actual."
	#define STR0016 "Error en el intervalo de tiempo"
	#define STR0017 "Conflicto del tipo relaciуn"
	#define STR0018 "Con este tipo de relaciуn solamente es posible especificar el cуdigo del cliente. їQuiere continuar sin grabar el cуdigo del proveedor?"
	#define STR0019 "Con este tipo de relaciуn solamente es posible especificar el cуdigo del proveedor. їQuiere continuar sin grabar el cуdigo del cliente?"
	#define STR0020 "En la sucursal"
	#define STR0021 "existe un registro con este cуdigo:"
	#define STR0022 "Nє"
	#define STR0023 "de"
	#define STR0024 "Copiar"
	#define STR0025 "Действует"
	#define STR0026 "Закрыт"
	#define STR0027 "Выберите договор"
#else
	#ifdef ENGLISH
		#define STR0001 "Legal Contracts"
		#define STR0002 "View"
		#define STR0003 "Add"
		#define STR0004 "Edit"
		#define STR0005 "Delete"
		#define STR0006 "Time span"
		#define STR0007 "Main data"
		#define STR0008 "Contract data"
		#define STR0009 "Legal contract"
		#define STR0010 "Either customer or supplier must be filled"
		#define STR0011 "A legal contract cannot have supplier and customer filled"
		#define STR0012 "No valid time span register for this date"
		#define STR0013 "Time span allowed only for update and view operations"
		#define STR0014 "The related entity could not be found"
		#define STR0015 "There can be no timespan intersection. Check current line."
		#define STR0016 "Timespan error"
		#define STR0017 "Relation type conflict"
		#define STR0018 "With this type of relation it is available to specify only Customer code. Do you want to continue without saving of the Supplier code?"
		#define STR0019 "With this type of relation it is available to specify only Supplier code. Do you want to continue without saving of the Customer code?"
		#define STR0020 "In the branch "
		#define STR0021 ", there already exists a contract with this code: "
		#define STR0022 "Nr. "
		#define STR0023 " from "
		#define STR0024 "Copy"
		#define STR0025 "Open"
		#define STR0026 "Closed"
		#define STR0027 "Select Legal Contract"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Договоры", "Contratos legais" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Просмотр", "Visгo" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Добавить", "Incluir" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Изменить", "Editar" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Удалить", "Excluir" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Диапазон времени", "Intervalo de tempo" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Основные данные", "Dados principais" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Переменные реквизиты", "Dados do contrato" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Договор", "Contrato legal" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Одно из полей Покупатель или Поставщик должно быть заполнено", "Informe ou o cliente ou o fornecedor" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "В договоре не может быть одновременно указан Покупатель и Поставщик", "O contrato legal nгo pode ter fornecedor e cliente informados" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Нет действительного временного диапазона для этой даты", "Nгo hб intervalo de tempo registrado para esta data" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Временной диапазон разрешен только для операций обновления и просмотра", "Intervalo de tempo й somente permitido para atualizaзгo e visualizar operaзхes" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Связанный объект не найден", "A entidade relacionada nгo pode ser encontrada" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Не должно быть пересечений временных интервалов. Проверьте данные.", "Nгo pode haver intersecзгo de intervalo de tempo. Verifique a atual linha." )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Ошибка с диапозоном времени", "Erro no intervalo de tempo" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Ошибка с типом отношений", "Conflito do tipo relaзгo" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Выбранный тип отношений позволяет указать только код Покупателя. Вы хотите продолжить без сохранения кода Поставщика?", "Com esse tipo de relaзгo, й possнvel somente especificar o cуdigo do Cliente. Quer continuar sem salvar o cуdigo do Fornecedor?" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Выбранный тип отношений позволяет указать только код Поставщика. Вы хотите продолжить без сохранения кода Покупателя?", "Com esse tipo de relaзгo, й possнvel somente especificar o cуdigo do Fornecedor. Quer continuar sem salvar o cуdigo do Cliente?" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "В филиале ", "Na filial" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", ", уже существует договор с кодом: ", "jб existe um contrato com este cуdigo:" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "№ ", "Nє" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", " от ", "de" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Копирование", "Copiar" )
		#define STR0025 "Действует"
		#define STR0026 "Закрыт"
		#define STR0027 "Выберите договор"
	#endif
#endif
