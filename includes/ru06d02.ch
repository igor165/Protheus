#ifdef SPANISH
	#define STR0001 "Clasificador de bancos"
	#define STR0002 "Visiуn"
	#define STR0003 "Upload"
	#define STR0004 "Upload de clasificador de bancos"
	#define STR0005 "Esta rutina realizarб el upload del catбlogo del Clasificador de bancos del RBC (RosBusinessConsulting)."
	#define STR0006 "їDesea continuar?"
	#define STR0007 "Anular"
	#define STR0008 "Banco estб en uploaded"
	#define STR0009 "Catбlogo de clasificador de bancos estб en uploaded..."
	#define STR0010 "Updload de clasificador de bancos realizado"
	#define STR0011 "Se realizу el upload."
	#define STR0012 "OK"
	#define STR0013 "Leyendo catбlogo de bancos..."
	#define STR0014 "Leyendo catбlogo de bancos eliminado..."
	#define STR0015 "Cargando bancos..."
	#define STR0016 "Cargando bancos borrados..."
	#define STR0017 "Catбlogo de clasificador de bancos estб en uploaded..."
	#define STR0018 "Incluir"
	#define STR0019 "Cambiar"
	#define STR0020 "Borrar"
	#define STR0021 "Solo es posible eliminar bancos extranjeros"
	#define STR0022 "No es posible borrar. Algunas cuentas estбn vinculadas a este banco"
	#define STR0023 "El registro se eliminу con йxito"
	#define STR0024 "Un banco extranjero solo puede modificarse"
	#define STR0025 "Preparando sincronizaciуn de bancos extranjeros..."
	#define STR0026 "La lista para sincronizaciуn estб preparбndose..."
	#define STR0027 "Sincronizando"
	#define STR0028 "Ошибка во время загрузки"
	#define STR0029 "Код: "
#else
	#ifdef ENGLISH
		#define STR0001 "Banks Classifier"
		#define STR0002 "View"
		#define STR0003 "Upload"
		#define STR0004 "Banks Classifier Upload"
		#define STR0005 "This routine will upload the Banks Classifier catalog from RBC (RosBusinessConsulting)."
		#define STR0006 "Continue"
		#define STR0007 "Cancel"
		#define STR0008 "Banks Uploading"
		#define STR0009 "Uploading Banks Classifier Catalog..."
		#define STR0010 "Banks Classifier Upload Done"
		#define STR0011 "The upload has been done."
		#define STR0012 "OK"
		#define STR0013 "Reading Banks Catalog..."
		#define STR0014 "Reading Deleted Banks Catalog..."
		#define STR0015 "Loading Banks..."
		#define STR0016 "Loading Deleted Banks..."
		#define STR0017 "Uploading Banks Classifier Catalog..."
		#define STR0018 "Add"
		#define STR0019 "Change"
		#define STR0020 "Delete"
		#define STR0021 "You can only remove foreign banks"
		#define STR0022 "Imposible to delete. Some accounts are related to this bank"
		#define STR0023 "The record was delete successfully"
		#define STR0024 "A foreign bank can only be changed"
		#define STR0025 "Preparin synching of foreign banks..."
		#define STR0026 "The list  for synching are preparing..."
		#define STR0027 "Synching ..."
		#define STR0028 "Error during downloading"
		#define STR0029 "Code: "
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Классификатор банков", "Classificador de bancos" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Просмотр", "Visгo" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Загрузить", "Upload" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Обновление Классификатора банков", "Upload de Classificador de bancos" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Эта программа обновит классификатор банков с сайта РБК", "Esta rotina vai fazer o upload to catбlogo do Classificador de Bancos do RBC (RosBusinessConsulting)." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Продолжить", "Deseja continuar?" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Отмена", "Cancelar" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Обновление Классификатора банков", "Banco estб sendo uploaded" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Обновление классификатора банков", "Catбlogo de Classificador de Bancos estб sendo uploaded..." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Обновление Классификатора банков закончено", "Updload de Classificador de Bancos Feito" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Обновление закончено", "O upload foi feito." )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "ОК", "OK" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Чтение файла  банков ", "Lendo Catбlogo de Bancos..." )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Чтение файла закрытых банков", "Lendo Catбlogo de Bancos Removido..." )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Загрузка банков...", "Carregando Bancos..." )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Загрузка неработающих банков...", "Carregando Bancos Deletados..." )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Обновление классификатора банков", "Catбlogo de Classificador de Bancos estб sendo uploaded..." )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Создать", "Incluir" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Изменить", "Mudar" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Удалить", "Excluir" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Можно удалить только иностранные банки", "Sу й possнvel remover bancos estrangeiros" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Удаление невозможно. Некоторые счета относятся к этому банку", "Nгo й possнvel apagar. Algumas contas estгo relacionadas a este banco" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Запись успешно удалена", "O registro foi removido com sucesso" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Редактировать можно только иностранные банки", "Um banco estrangeiro sу podem ser modificados" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Подготовка к синхронизации...", "Preparando sincronizaзгo de bancos estrangeiros..." )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Готовим список реквизитов для синхронизации...", "A lista para sincronizaзгo estб sendo preparada..." )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Синхронизация...", "Sincronizando..." )
		#define STR0028 "Ошибка во время загрузки"
		#define STR0029 "Код: "
	#endif
#endif
