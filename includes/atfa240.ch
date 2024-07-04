#ifdef SPANISH
	#define STR0001 "Buscar"
	#define STR0002 "Visualizar"
	#define STR0003 "Clasificar"
	#define STR0004 "Clasificaci�n de activos fijos"
	#define STR0005 "�Modificar el c�digo?"
	#define STR0006 "Clasificaci�n de activos fijos"
	#define STR0007 "Modificaci�n de c�digos de bienes"
	#define STR0008 "C�digo Base Origen"
	#define STR0009 "Nuevo C�digo Base"
	#define STR0010 "Leyenda"
	#define STR0011 "Bien no clasificado"
	#define STR0012 "Bien clasificado"
	#define STR0013 "Bien totalmente dado de baja"
	#define STR0014 "Modulo SIGAATF desactualizado, por favor actualizar el ultimo update"
	#define STR0015 "La fecha de adquisicion del bien es igual o inferior a la fecha de bloqueo de movimiento: "
	#define STR0016 "Bien planificado"
	#define STR0017 "Contr. de Terceros"
	#define STR0018 "Contr. en Terceros"
	#define STR0019 "Este bien fue clasificado."
	#define STR0020 "Clasificaci�n en lote"
	#define STR0021 "El grupo de clasificaci�n no existe."
	#define STR0022 "Debe informarse el c�digo base."
	#define STR0023 "El �tem inicial debe haberse completado."
	#define STR0024 "El n�mero de la plaqueta debe haberse completado."
	#define STR0025 "No hay bienes para clasificarse."
	#define STR0026 "ERROR"
	#define STR0027 "FIN"
	#define STR0028 "Existen l�neas duplicadas (C�d. Base e �tem iguales)."
	#define STR0029 "El n�mero de la plaqueta existe."
	#define STR0030 "El c�digo de la jurisdicci�n debe estar informado"
	#define STR0031 "Existe bien clasificado con el c�digo: "
	#define STR0032 " e �tem: "
	#define STR0033 "No existe ning�n �tem seleccionado"
	#define STR0034 "Clasificaci�n en lote"
	#define STR0035 "Confirmar"
	#define STR0036 "Anular"
	#define STR0037 "Par�metro MV_ATFMOED configurado incorrectamente"
#else
	#ifdef ENGLISH
		#define STR0001 "Search"
		#define STR0002 "View"
		#define STR0003 "Classify"
		#define STR0004 "Classify Fixed Assets"
		#define STR0005 "Do you want to edit the Code?"
		#define STR0006 "Classify of Fixed Assets"
		#define STR0007 "Edit Assets Codes"
		#define STR0008 "Origin Base Code"
		#define STR0009 "New Base Code"
		#define STR0010 "Title"
		#define STR0011 "Asset not Classified"
		#define STR0012 "Asset Classified"
		#define STR0013 "Asset totally posted"
		#define STR0014 "SIGAATF module is outdated. Renew the last update."
		#define STR0015 "The asset acquisition date is equal to or earlier than the transaction stoppage date: "
		#define STR0016 "Planned Asset"
		#define STR0017 "Third Party Control"
		#define STR0018 "Control in Third Party"
		#define STR0019 "This asset is already classified."
		#define STR0020 "Classification in Batch"
		#define STR0021 "The classification group does not exist."
		#define STR0022 "The Base Code must be completed."
		#define STR0023 "The Start Item must be completed."
		#define STR0024 "The plate Number must be completed."
		#define STR0025 "There are no assets to be classified."
		#define STR0026 "ERROR"
		#define STR0027 "END"
		#define STR0028 "There are duplicated lines (equal Base Cod. and Item)."
		#define STR0029 "The platelet number already exists."
		#define STR0030 "Enter group code."
		#define STR0031 "There is an asset already classified with the Code : "
		#define STR0032 " and Item: "
		#define STR0033 "There is no item selected."
		#define STR0034 "Batch classification"
		#define STR0035 "Confirm"
		#define STR0036 "Cancel"
		#define STR0037 "Parameter MV_ATFMOED improperly configured"
	#else
		#define STR0001 "Pesquisar"
		#define STR0002 "Visualizar"
		#define STR0003 "Classificar"
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Classifica��o De Activos Imobilizados", "Classifica��o de Ativos Imobilizados" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Deseja Alterar O C�digo?", "Deseja alterar o C�digo?" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Classifica��o De Activos Imobilizados", "Classificacao de Ativos Imobilizados" )
		#define STR0007 "Altera��o dos C�digos dos Bens"
		#define STR0008 "C�digo Base Origem"
		#define STR0009 "Novo C�digo Base"
		#define STR0010 "Legenda"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Artigo N�o Classificado", "Bem nao Classificado" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Artigo Classificado", "Bem Classificado" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Artigo totalmente expedido", "Bem totalmente baixado" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "M�dulo SIGAATF desactualizado. Por favor, actualizar o �ltimo update.", "Modulo SIGAATF desatualizado, por favor atualizar o ultimo update" )
		#define STR0015 "A data de aquisi��o do bem � igual ou menor que a data de bloqueio de movimenta��o : "
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Bem Planeado", "Bem Planejado" )
		#define STR0017 "Contr. de Terceiros"
		#define STR0018 "Contr. em Terceiros"
		#define STR0019 "Este bem j� foi classificado."
		#define STR0020 "Classifica��o em Lote"
		#define STR0021 "O grupo da classifica��o n�o existe."
		#define STR0022 "O C�digo Base deve estar preenchido."
		#define STR0023 "O Item Inicial deve estar preenchido."
		#define STR0024 "O N�mero da plaqueta deve estar preenchido."
		#define STR0025 "N�o h� bens a serem classificados."
		#define STR0026 "ERRO"
		#define STR0027 "FIM"
		#define STR0028 "Existe linhas duplicadas (Cod. Base e Item iguais)."
		#define STR0029 "O N�mero da plaqueta j� existe."
		#define STR0030 "Codigo do grupo deve estar preenchido."
		#define STR0031 "J� existe bem classificado com o Codigo : "
		#define STR0032 " e Item : "
		#define STR0033 "N�o h� nenhum item selecionado."
		#define STR0034 "Classifica��o em lote"
		#define STR0035 "Confirmar"
		#define STR0036 "Cancelar"
		#define STR0037 "Par�metro MV_ATFMOED configurado incorretamente"
	#endif
#endif
