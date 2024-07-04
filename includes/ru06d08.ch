#ifdef SPANISH
	#define STR0001 "Configuraciones de formato de cambio Cliente-Banco"
	#define STR0002 "Visiуn"
	#define STR0003 "Crear"
	#define STR0004 "Editar"
	#define STR0005 "Borrar"
	#define STR0006 "Copiar"
	#define STR0007 "Encabezado"
	#define STR0008 "Secciones"
	#define STR0009 "Una tag activa estб en la secciуn borrada"
	#define STR0010 "Estatus de tag incorrecta"
	#define STR0011 "Revierta el borrado de la secciуn"
	#define STR0012 "y borre nuevamente"
	#define STR0013 "Cуdigo duplicado"
	#define STR0014 "Cуdigo incorrecto"
	#define STR0015 "Incluya otro cуdigo"
	#define STR0016 "Sнmbolos de cуdigo son A-Z y 0-9 solamente"
	#define STR0017 "Esta secciуn ya existe"
	#define STR0018 "Secciуn duplicada"
	#define STR0019 "Seleccione otra secciуn"
	#define STR0020 "Secuencia de tag incorrecta"
	#define STR0021 "Nъmero de tag debe ser > 0"
	#define STR0022 "Entre otro nъmero de tag"
	#define STR0023 "Nъmero de tag ya existe"
	#define STR0024 "Formato de cambio de datos"
	#define STR0025 "Tag en el archivo"
	#define STR0026 "Todas las tags"
	#define STR0027 "Configuraciones del formato"
	#define STR0028 "Creaciуn"
	#define STR0029 "Editar"
	#define STR0030 "Seleccione directorio"
	#define STR0031 "Пожалуйста, проверьте поля Тип обмена и Тип раздела. Они должны быть заполнены."
	#define STR0032 "Пожалуйста, проверьте поля. Вы не можете изменить формат, если поле Значение уже заполнено кодом для другого Типа обмена."
	#define STR0033 "Это значение не принадлежит заголовку экспорта."
	#define STR0034 "Это значение не принадлежит платежному поручению для типа Экспорт."
	#define STR0035 "Это значение не принадлежит заголовку импорта."
	#define STR0036 "Это значение не принадлежит платежному поручению для типа Импорт."
	#define STR0037 "Не удается найти значение в основных таблицах. Пожалуйста, проверьте списки E0, E9, IH и IP."
#else
	#ifdef ENGLISH
		#define STR0001 'Client-Bank exchange format settings'
		#define STR0002 'View'
		#define STR0003 'Create'
		#define STR0004 'Edit'
		#define STR0005 'Delete'
		#define STR0006 'Copy'
		#define STR0007 'Header'
		#define STR0008 'Sections'
		#define STR0009 'Active tag is in deleted section'
		#define STR0010 'Incorrect tag status'
		#define STR0011 'Undelete section'
		#define STR0012 'and delete it again'
		#define STR0013 'Code duplicate'
		#define STR0014 'Incorrect code'
		#define STR0015 'Input another code'
		#define STR0016 'Code symbols are A-Z and 0-9 only'
		#define STR0017 'This section already exist'
		#define STR0018 'Section duplicate'
		#define STR0019 'Select another section'
		#define STR0020 'Incorrect tag sequence'
		#define STR0021 'Tag number must be > 0'
		#define STR0022 'Imput another tag number'
		#define STR0023 'Tag number already exist'
		#define STR0024 'Data exchange format'
		#define STR0025 'Tag in file'
		#define STR0026 'All tags'
		#define STR0027 'Format settings'
		#define STR0028 'Creation'
		#define STR0029 'Editing'
		#define STR0030 'Select directory'
		#define STR0031 "Please, check fields Exchange type and Section type. They must be filled."
		#define STR0032 "Please, check fields. You cannot change the format if the Value field is already filled with code for another Exchange format."
		#define STR0033 "This value does not belong to the Export Header."
		#define STR0034 "This value does not belong to the Export Payment order."
		#define STR0035 "This value does not belong to the Import Header."
		#define STR0036 "This value does not belong to the Import Payment order."
		#define STR0037 "Cannot find value in Generig tables. Please, check lists E0, E9, IH and IP."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", 'Настройка форматов для обмена Клиент-Банк', "Configuraзхes de formato de troca Cliente-Banco" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", 'Просмотр', "Visгo" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", 'Создать', "Criar" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", 'Изменить', "Editar" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", 'Удалить', "Excluir" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", 'Копировать', "Copiar" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", 'Заголовок', "Cabeзalho" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", 'Секции', "Seзхes" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", 'В удал-й секции есть активный тэг', "Uma tag ativa estб na seзгo deletada" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", 'Неверный статус тэга', "Status de tag incorreta" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", 'Отмените удаление секции', "Desfaзa a exclusгo da seзгo" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", 'Повторно удалите секцию', "e delete novamente" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", 'Дубликат кода', "Cуdigo duplicado" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", 'Неверный код', "Cуdigo incorreto" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", 'Введите иной код', "Entre outro cуdigo" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", 'Для кода допустимы: A-Z и 0-9', "Sнmbolos de cуdigo sгo A-Z e 0-9 somente" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", 'Секция существует', "Essa seзгo jб existe" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", 'Дубликат секции', "Seзгo duplicada" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", 'Выберите иную секцию', "Selecione outra seзгo" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", 'Неверный номер тэга', "Sequкncia de tag incorreta" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", 'Номер тэга должен быть > 0', "Nъmero de tag deve ser > 0" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", 'Введите иной номер тэга', "Entre outro nъmero de tag" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", 'Номер тэга существует', "Nъmero de tag jб existe" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", 'Формат обмена данных', "Formato de troca de dados" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", 'Тэг поля в файле', "Tag no arquivo" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", 'Все тэги', "Todas as tags" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", 'Настройка формата', "Configuraзхes do formato" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", 'Создание', "Criaзгo" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", 'Редактирование', "Editar" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", 'Выберите каталог', "Selecione diretуrio" )
		#define STR0031 "Пожалуйста, проверьте поля Тип обмена и Тип раздела. Они должны быть заполнены."
		#define STR0032 "Пожалуйста, проверьте поля. Вы не можете изменить формат, если поле Значение уже заполнено кодом для другого Типа обмена."
		#define STR0033 "Это значение не принадлежит заголовку экспорта."
		#define STR0034 "Это значение не принадлежит платежному поручению для типа Экспорт."
		#define STR0035 "Это значение не принадлежит заголовку импорта."
		#define STR0036 "Это значение не принадлежит платежному поручению для типа Импорт."
		#define STR0037 "Не удается найти значение в основных таблицах. Пожалуйста, проверьте списки E0, E9, IH и IP."
	#endif
#endif
