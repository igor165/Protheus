#ifdef SPANISH
	#define STR0001 'Inmuebles'
	#define STR0002 'Uso compartido de tablas'
	#define STR0003 'Las tablas FVV y FVG deben ser obligatoriamente exclusivas.'
	#define STR0004 'Incluir'
	#define STR0005 'Visualizar'
	#define STR0006 'Incluir'
	#define STR0007 'Modificar'
	#define STR0008 'Borrar'
	#define STR0009 'Imprimir'
	#define STR0010 'Archivo de inmuebles'
	#define STR0011 'Datos del inmueble'
	#define STR0012 'Datos de terceros'
	#define STR0013 'Campo obligatorio'
	#define STR0014 "Para país Brasil, es obligatorio informar los campos:"
	#define STR0015 'Porcentaje de terceros'
	#define STR0016 "Suma de los porcentajes de terceros sobrapasa el 100%."
	#define STR0017 'Inmueble por sucursal'
	#define STR0018 'Solo se permite registrar 1 inmueble por sucursal.'
	#define STR0019 'Tipo de persona'
	#define STR0020 'El propietario debe estar marcado como Declarante en el archivo de personas.'
	#define STR0021 'Inmueble por sucursal'
	#define STR0022 'Registro no encontrado en el archivo de personas'
	#define STR0023 'Sucursal'
	#define STR0024 '¡Esta sucursal ya está registrándose en otra estación!'
	#define STR0025 'Función no compilada'
	#define STR0026 'Fuente FINA820 no está compilada en el repositorio.'
	#define STR0027 'Propietario tercero'
	#define STR0028 'El Propietario/Contribuyente no puede ser un tercero'
	#define STR0029 'Explotación individual'
	#define STR0030 '¡Cuando el tipo Explotación sea individual, no informe terceros!'
	#define STR0031 'Porcentaje total superior al 100%'
	#define STR0032 "Total de los porcentajes de participación (propietario + terceros) no debe ser superior al 100%."
	#define STR0033 "Est/Prov/Reg"
	#define STR0034 "Cód. Municipio"
	#define STR0035 "CP"
	#define STR0036 "CAFIR"
	#define STR0037 "CAEPF"
	#define STR0038 "Para participación en conjunto (no individual), es necesaria la indicación"
	#define STR0039 "de por lo menos un asociado."
	#define STR0040 "Para el país Brasil, es obligatorio informar el CAEPF (representante) de por lo menos uno de los socios declarantes."
	#define STR0041 'Nombre del país'
	#define STR0042 'Descripción'
	#define STR0043 'NEGATIVO'
	#define STR0044 'Porcentaje de participación no puede ser negativa.'
	#define STR0045 'ASOCIADO'
	#define STR0046 'Tipo de explotación no permite explotación individual del 100%.'
	#define STR0047 "Informe un CAEPF para uno de los declarantes registrados."
	#define STR0048 "Cp no válido"
	#define STR0049 "Verifique el código e informe un Cp Válido"
	#define STR0050 "Para tipo de explotación individual, el CAEPF es obligatorio"
	#define STR0051 "Informe el CAEPF del declarante"
	#define STR0052 "¿Desea proseguir con la grabación del inmueble sin informar un CAEPF?"
	#define STR0053 "¡Atención!"
	#define STR0054 "Modif. Explotación"
	#define STR0055 'Existe una versión con vigencia en conflicto con la informada (vigencia inicial y final internas).'
	#define STR0056 "Por favor, verifique las fechas de vigencia inicial y final."
	#define STR0057 "Versión:"
	#define STR0058 "Existe una versión con vigencia inicial en conflicto con la informada."
	#define STR0059 "Por favor, verifique las fechas de vigencia inicial."
	#define STR0060 "Existe una versión con vigencia en conflicto con la informada (vigencia inicial y final externas)."
	#define STR0061 "Existe una versión con vigencia final en conflicto con la informada."
	#define STR0062 "Por favor, verifique las fechas de vigencia final."
	#define STR0063 "INTERVALO DE VIGENCIA"
	#define STR0064 'Vigencia'
	#define STR0065 '¡Fecha inicial no puede ser mayor que fecha final!'
	#define STR0066 'INMUEBLE VERSIONADO'
	#define STR0067 'Sucursal (versión 0001) que contiene otras versiones no puede borrarse.'
#else
	#ifdef ENGLISH
		#define STR0001 'Real State'
		#define STR0002 'Table Sharing'
		#define STR0003 'Tables FVV and FVG must be exclusive.'
		#define STR0004 'Add'
		#define STR0005 'View'
		#define STR0006 'Add'
		#define STR0007 'Edit'
		#define STR0008 'Delete'
		#define STR0009 'Print'
		#define STR0010 'Property Register'
		#define STR0011 'Property Data'
		#define STR0012 'Third Party Data'
		#define STR0013 'Mandatory Field'
		#define STR0014 "The following fields are required for Brazil:"
		#define STR0015 'Third Party Percentage'
		#define STR0016 "Sum of third party percentages exceeds 100%."
		#define STR0017 'Property per branch'
		#define STR0018 'You can only register 1 property per branch.'
		#define STR0019 'Type of person'
		#define STR0020 'The Owner must be set as Declarant in the Entities Register.'
		#define STR0021 'Property per branch'
		#define STR0022 'Record not found in Person Register'
		#define STR0023 'Branch'
		#define STR0024 'This branch is being registered in another station.'
		#define STR0025 'Function not compiled'
		#define STR0026 'Source FINA820 is not compiled in the repository.'
		#define STR0027 'Third party owner'
		#define STR0028 'Owner/Taxpayer cannot be a third party.'
		#define STR0029 'Individual Exploration'
		#define STR0030 'When Type of Export is individual, do not enter third parties!'
		#define STR0031 'Total percentage surpasses 100%'
		#define STR0032 "Total of participation percentages (owner + third parties) must not be above 100%."
		#define STR0033 "State"
		#define STR0034 "City Code"
		#define STR0035 "Postal Code"
		#define STR0036 "CAFIR"
		#define STR0037 "CAEPF"
		#define STR0038 "For group participation (not individual), you must appoint"
		#define STR0039 "at least one partner."
		#define STR0040 "For Brazil, it is mandatory to inform the CAEPF (representative) of at least one of the declaring partners."
		#define STR0041 'Country Name'
		#define STR0042 'Description'
		#define STR0043 'NEGATIVE'
		#define STR0044 'Participation percentage cannot be negative.'
		#define STR0045 'PARTNER'
		#define STR0046 'Exploration type does not allow 100% individual exploration.'
		#define STR0047 "Inform a CAEPF for one of the registered declarants."
		#define STR0048 "Invalid postal code"
		#define STR0049 "Check the Code and enter a valid Postal Code"
		#define STR0050 "For type of individual exploration, CAEPF is mandatory"
		#define STR0051 "Enter the declarant's CAEPF"
		#define STR0052 "Do you want to proceed recording the property without informing a CAEPF?"
		#define STR0053 "Attention!"
		#define STR0054 "Edit Exploration"
		#define STR0055 'There is a version in which the validity conflicts with the one entered (internal validity start and end)'
		#define STR0056 "Check the validity start and end dates."
		#define STR0057 "Version:"
		#define STR0058 "There is a version in which the validity start conflicts with the one entered."
		#define STR0059 "Check the validity start dates."
		#define STR0060 "There is a version in which the validity conflicts with the one entered (external validity start and end)"
		#define STR0061 "There is a version in which the validity end conflicts with the one entered."
		#define STR0062 "Check the validity end dates."
		#define STR0063 "VALIDITY INTERVAL"
		#define STR0064 'Validity'
		#define STR0065 'Start date cannot be after the end date!'
		#define STR0066 'VERSIONED PROPERTY'
		#define STR0067 'Branch (version 0001) that contains the other versions cannot be deleted.'
	#else
		#define STR0001 'Imóveis'
		#define STR0002 'Compartilhamento Tabelas'
		#define STR0003 'As tabelas FVV e FVG devem ser obrigatoriamente exclusivas.'
		#define STR0004 'Incluir'
		#define STR0005 'Visualizar'
		#define STR0006 'Incluir'
		#define STR0007 'Alterar'
		#define STR0008 'Excluir'
		#define STR0009 'Imprimir'
		#define STR0010 'Cadastro de Imóveis'
		#define STR0011 'Dados do Imóvel'
		#define STR0012 'Dados dos Terceiros'
		#define STR0013 'Campo Obrigatório'
		#define STR0014 "Para país Brasil, é obrigatório informar os campos: "
		#define STR0015 'Percentual Terceiros'
		#define STR0016 "Soma dos percentuais dos terceiros ultrapassa 100%."
		#define STR0017 'Imóvel por filial'
		#define STR0018 'Só é permitido cadastrar 1 imóvel por filial.'
		#define STR0019 'Tipo de Pessoa'
		#define STR0020 'O Proprietário deve estar marcado como Declarante no Cadastro de Pessoas.'
		#define STR0021 'Imóvel por filial'
		#define STR0022 'Registro não encontrado no Cadastro de Pessoas'
		#define STR0023 'Filial'
		#define STR0024 'Está filial já está sendo cadastrada em uma outra estação!'
		#define STR0025 'Função não compilada'
		#define STR0026 'Fonte FINA820 não está compilado no repositório.'
		#define STR0027 'Proprietário terceiro'
		#define STR0028 'O Proprietário/Contribuinte não pode ser um terceiro!'
		#define STR0029 'Exploração Individual'
		#define STR0030 'Quando Tipo de Exploração for Individual, não informar terceiros!'
		#define STR0031 'Percentagem total superior a 100%'
		#define STR0032 "Total das porcentagens de participação (proprietário + terceiros) não deve ser maior que 100%."
		#define STR0033 "Estado"
		#define STR0034 "Cód. Município"
		#define STR0035 "CEP"
		#define STR0036 "CAFIR"
		#define STR0037 "CAEPF"
		#define STR0038 "Para participação em conjunto (não individual), é necessária a indicação "
		#define STR0039 " de ao menos um parceiro."
		#define STR0040 "Para país Brasil, é obrigatório informar o CAEPF (representante) de ao menos um dos sócios declarantes."
		#define STR0041 'Nome do País'
		#define STR0042 'Descrição'
		#define STR0043 'NEGATIVO'
		#define STR0044 'Porcentagem de participação não pode ser negativa.'
		#define STR0045 'PARCEIR'
		#define STR0046 'Tipo de exploração não permite exploração individual de 100%.'
		#define STR0047 "Informe um CAEPF para um dos declarantes cadastrados. "
		#define STR0048 "Cep Inválido"
		#define STR0049 "Verificar o Código e informar um Cep Válido"
		#define STR0050 "Para tipo de exploração individual, o CAEPF é obrigatório"
		#define STR0051 "Informe o CAEPF do declarante"
		#define STR0052 "Deseja prosseguir com a gravação do imóvel sem informar um CAEPF?"
		#define STR0053 "Atenção!"
		#define STR0054 "Alt. Exploração"
		#define STR0055 'Existe uma versão com vigência conflitante com a informada (vigência inicial e final internas).'
		#define STR0056 "Por favor, verifique as datas de vigência inicial e final."
		#define STR0057 "Versão: "
		#define STR0058 "Existe uma versão com vigência inicial conflitante com a informada."
		#define STR0059 "Por favor, verifique as datas de vigência inicial."
		#define STR0060 "Existe uma versão com vigência conflitante com a informada (vigência inicial e final externas)."
		#define STR0061 "Existe uma versão com vigência final conflitante com a informada."
		#define STR0062 "Por favor, verifique as datas de vigência final."
		#define STR0063 "INTERVALO DE VIGENCIA"
		#define STR0064 'Vigência'
		#define STR0065 'Data Inicial não pode ser maior que a data final!'
		#define STR0066 'IMÓVEL VERSIONADO'
		#define STR0067 'Filial (versão 0001) que contém outras versões não pode ser excluída.'
	#endif
#endif
