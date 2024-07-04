#ifdef SPANISH
	#define STR0001 "Archivo de vehículos."
	#define STR0002 'Para registro de vehículos, es necesaria la integración con flotas por medio del parámetro MV_NGMNTFR.'
	#define STR0003 'Acceder al módulo configurador SIGACFG y efectuar la modificación del parámetro.'
	#define STR0004 'Visualizar'
	#define STR0005 'Incluir'
	#define STR0006 'Modificar'
	#define STR0007 'Excluir'
	#define STR0008 'Desactivar'
	#define STR0009 'Imprimir'
	#define STR0010 'Copiar'
	#define STR0011 "Conocimiento"
	#define STR0012 'Para archivo de vehículos, debe indicarse el tipo de la flota a través de la pantalla inicial.'
	#define STR0013 'Acceder nuevamente la rutina de vehículos y confirmar la flota que va a utilizar.'
	#define STR0014 'Para registro de vehículos del TMS, es necesaria la integración con TMS por medio del parámetro MV_NGMNTMS.'
	#define STR0015 'Acceder al módulo configurador SIGACFG y efectuar la modificación del parámetro.'
	#define STR0016 "NO CONFORMIDAD"
	#define STR0017 'Vehículo'
	#define STR0018 'Nombre vehíc.'
	#define STR0019 "Informaciones de tanque"
	#define STR0020 'Tanque'
	#define STR0021 "No es posible borrar el tanque, pues existe un abastecimiento."
	#define STR0022 ", pues el bien posee control por contador"
	#define STR0023 "El campo"
	#define STR0024 "no se informó."
	#define STR0025 "Informe el campo"
	#define STR0026 "El código del bien debe informarse antes del código del TMS."
	#define STR0027 "Ya existe bien con el Código del TMS relacionado."
	#define STR0028 "Ya existe TMS con el código del bien relacionado."
	#define STR0029 "Año del modelo es mayor que el año actual"
	#define STR0030 "¿Confirma?"
	#define STR0031 "Bien"
	#define STR0032 "no tiene contador propio o no tiene el"
	#define STR0033 "Contador 1"
	#define STR0034 "Contador 2"
	#define STR0035 "Año"
	#define STR0036 "del modelo"
	#define STR0037 "de fabricación"
	#define STR0038 "inválido."
	#define STR0039 "deberá ser menor o igual al año actual"
	#define STR0040 "Flota no integrada al TMS"
	#define STR0041 "Flota integrada al TMS"
	#define STR0042 "Categoría del vehículo"
	#define STR0043 "¿Tipo flota ?"
	#define STR0044 "Confirmar"
	#define STR0045 "Se encontró una incompatibilidad de diccionario, impidiendo el acceso a la rutina."
	#define STR0046 "Actualice el entorno para release 12.1.7 de diciembre o posterior."
	#define STR0047 "No es posible borrar el tanque, pues existe un abastecimiento."
	#define STR0048 "No es posible agregar un tanque para el segundo contador, pues este se desactivó."
	#define STR0049 "Modificar a Bien"
	#define STR0050 'PUNTO DE ENTRADA'
	#define STR0051 'Los puntos de entrada "MNTA0841" y "MNTA0842" deben modificarse de acuerdo con el nuevo modelo. Por favor, busque la ISSUE MNG-6626 para el punto de entrada "MNTA0841" y la ISSUE MNG-6281 para el punto de entrada "MNTA0842" en el TDN.'
	#define STR0052 "Convenio no compatible con el combustible informado."
	#define STR0053 "Informe un convenio compatible con el combustible."
	#define STR0054 "No es posible agregar un tanque para el segundo contador, porque fue desactivado."
	#define STR0055 "No es posible agregar un tanque para el contador 1, porque fue desactivado."
	#define STR0056 "No es posible agregar un tanque para el contador 2, porque fue desactivado."
	#define STR0057 "Incluir estructura"
#else
	#ifdef ENGLISH
		#define STR0001 "Vehicle Registration"
		#define STR0002 'For register of vehicles, integration with fleet is executed through parameter MV_NGMNTFR.'
		#define STR0003 'Access the configurator module SIGACFG and edit the parameter.'
		#define STR0004 'View'
		#define STR0005 'Add'
		#define STR0006 'Edit'
		#define STR0007 'Delete'
		#define STR0008 'Inactivate'
		#define STR0009 'Print'
		#define STR0010 'Copy'
		#define STR0011 "Awareness"
		#define STR0012 'For vehicles register, enter the type of fleet through start screen.'
		#define STR0013 'Access again the vehicles routine and confirm the fleet to use.'
		#define STR0014 'For register of TMS vehicles, integration with TMS is executed through parameter MV_NGMNTMS.'
		#define STR0015 'Access the configurator module SIGACFG and edit the parameter.'
		#define STR0016 "NON-CONFORMANCE"
		#define STR0017 'Vehicle'
		#define STR0018 'Veh. Name'
		#define STR0019 "Information of Tank"
		#define STR0020 'Tank'
		#define STR0021 "Unable to delete tank, because there is an existing fueling already."
		#define STR0022 ", as the asset has control by counter"
		#define STR0023 "The field"
		#define STR0024 "not entered."
		#define STR0025 "Enter the field"
		#define STR0026 "The code of asset must be entered before the TMS code."
		#define STR0027 "There already is Asset with TMS Code related."
		#define STR0028 "There already is TMS with Asset Code related."
		#define STR0029 "Model year and higher than current year"
		#define STR0030 "Confirm it?"
		#define STR0031 "Asset"
		#define STR0032 "does not have its own counter or does not have"
		#define STR0033 "Counter 1"
		#define STR0034 "Counter 2"
		#define STR0035 "Year"
		#define STR0036 "of model"
		#define STR0037 "from manufacturer"
		#define STR0038 "invalid"
		#define STR0039 "must be lower than or equal to current year"
		#define STR0040 "Fleet not integrated to TMS"
		#define STR0041 "Fleet not integrated to TMS"
		#define STR0042 "Vehicle Category"
		#define STR0043 "Type of Fleet ?"
		#define STR0044 "Confirm"
		#define STR0045 "Incompatibility of dictionary preventing access to routine."
		#define STR0046 "Update environment for release 12.1.7 from December or later."
		#define STR0047 "Unable to edit the tank, because there is an existing fueling already."
		#define STR0048 "Unable to add tank to second account, as it was deactivated."
		#define STR0049 "Change to Asset"
		#define STR0050 'ENTRY POINT'
		#define STR0051 'Entry points 'MNTA0841' and 'MNTA0842' must be edited according to the new model. Search ISSUE MNG-6626 for entry point 'MNTA0841' and ISSUE MNG-6281 for entry point 'MNTA0842' in TDN.'
		#define STR0052 "Agreement is not compatible with fuel informed."
		#define STR0053 "Enter agreement compatible with fuel."
		#define STR0054 "Unable to add tank to second account, as it was deactivated."
		#define STR0055 "Unable to add tank to counter 1, as it was deactivated."
		#define STR0056 "Unable to add tank to counter 2, as it was deactivated."
		#define STR0057 "Add Structure"
	#else
		#define STR0001 "Cadastro de Veiculos"
		#define STR0002 'Para cadastro de veículos, precisa integração com frotas através do parâmetro MV_NGMNTFR.'
		#define STR0003 'Acessar o módulo configurador SIGACFG e efetuar a alteração do parâmetro.'
		#define STR0004 'Visualizar'
		#define STR0005 'Incluir'
		#define STR0006 'Alterar'
		#define STR0007 'Excluir'
		#define STR0008 'Inativar'
		#define STR0009 'Imprimir'
		#define STR0010 'Copiar'
		#define STR0011 "Conhecimento"
		#define STR0012 'Para cadastro de veículos, precisa ser indicado o tipo da frota através da tela inicial.'
		#define STR0013 'Acessar novamente a rotina de veículos e confirmar qual frota vai utilizar.'
		#define STR0014 'Para cadastro de veículos do TMS, precisa integração com TMS através do parâmetro MV_NGMNTMS.'
		#define STR0015 'Acessar o módulo configurador SIGACFG e efetuar a alteração do parâmetro.'
		#define STR0016 "NAO CONFORMIDADE"
		#define STR0017 'Veículo'
		#define STR0018 'Nome Veíc.'
		#define STR0019 "Informações de Tanque"
		#define STR0020 'Tanque'
		#define STR0021 "Não é possível excluir o tanque, pois já existe um abastecimento."
		#define STR0022 ", pois o bem possui controle por contador"
		#define STR0023 "O campo"
		#define STR0024 "não foi informado."
		#define STR0025 "Informe o campo"
		#define STR0026 "O código do bem deve ser informardo antes do código do TMS."
		#define STR0027 "Ja existe Bem com o Codigo do TMS relacionado."
		#define STR0028 "Ja existe TMS com o Codigo do Bem relacionado."
		#define STR0029 "Ano do modelo e maior do que o ano atual"
		#define STR0030 "Confirma?"
		#define STR0031 "Bem"
		#define STR0032 "não tem contador próprio ou não possui o"
		#define STR0033 "Contador 1"
		#define STR0034 "Contador 2"
		#define STR0035 "Ano"
		#define STR0036 "do modelo"
		#define STR0037 "de fabricacao"
		#define STR0038 "invalido"
		#define STR0039 "devera ser menor ou igual ao ano atual"
		#define STR0040 "Frota não integrada ao TMS"
		#define STR0041 "Frota integrada ao TMS"
		#define STR0042 "Categoria do Veículo"
		#define STR0043 "Tipo Frota ?"
		#define STR0044 "Confirmar"
		#define STR0045 "Foi encontrada uma incompatibilidade de dicionário, impedindo o acesso a rotina."
		#define STR0046 "Atualize o ambiente para release 12.1.7 de dezembro ou posterior."
		#define STR0047 "Não é possível alterar o tanque, pois já existe um abastecimento."
		#define STR0048 "Não é possível adicionar tanque para o segundo contador pois o mesmo foi desativado."
		#define STR0049 "Alterar para Bem"
		#define STR0050 'PONTO DE ENTRADA'
		#define STR0051 'Os pontos de entrada "MNTA0841" e "MNTA0842" devem ser alterados conforme o novo modelo. Favor pesquisar a ISSUE MNG-6626 para o ponto de entrada "MNTA0841" e a ISSUE MNG-6281 para o ponto de entrada "MNTA0842" no TDN.'
		#define STR0052 "Convênio não compatível com o combustível informado."
		#define STR0053 "Informe um convênio compatível com o combustível."
		#define STR0054 "Não é possível adicionar tanque para o segundo contador pois o mesmo foi desativado."
		#define STR0055 "Não é possível adicionar tanque para o contador 1 pois o mesmo foi desativado."
		#define STR0056 "Não é possível adicionar tanque para o contador 2 pois o mesmo foi desativado."
		#define STR0057 "Incluir Estrutura"
	#endif
#endif
