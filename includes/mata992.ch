#ifdef SPANISH
	#define STR0001 "Archivo de control de formularios"
	#define STR0002 "Buscar"
	#define STR0003 "Visualizar"
	#define STR0004 "Incluir"
	#define STR0005 "Modificar"
	#define STR0006 "Borrar"
	#define STR0007 "Ya existe el CAI informado. Inclusión no efectuada."
	#define STR0008 "Ya existe un intervalo para el número inicial informado. Inclusión no efectuada"
	#define STR0009 "Ya existe un intervalo para el número final informado. Inclusión no realizada"
	#define STR0010 "Ese CAI ya se utilizó en la generación de facturas. Borrado no efectuado."
	#define STR0011 "No se podrá modificar el número inicial, pues su intervalo ya se utilizó."
	#define STR0012 "Es necesario informar una especie válida. Inclusión no efectuada."
	#define STR0013 "Los siguientes campos no pueden dejarse vacíos:"
	#define STR0014 "Por favor complételos."
	#define STR0015 "Ya existen la serie y los intervalos informados. Inclusión no realizada."
	#define STR0016 "Folio ya utilizado en la generación de facturas. Borrado no realizado."
	#define STR0017 "Comprobantes fiscales digitales"
	#define STR0018 "Si el Tipo de Form. fuera igual a Impreso previamente, el campo Cantidad de ítem impreso previamente debe ser diferente de cero"
	#define STR0019 "Cuando el Tipo de Form. sea igual a Autoimpreso, el campo de cantidad de ítem Impreso previamente debe ser igual a cero"
	#define STR0020 " Número final de formulario es obligatorio"
	#define STR0021 "Número final no debe completarse para el formulario autoimpreso"
	#define STR0022 "La serie informada ya está en uso"
	#define STR0023 "La serie "
	#define STR0024 " esta reservada para la estación "
	#define STR0025 "Operación anulada"
	#define STR0026 "Control de formulario utilizado en la generación de facturas."
	#define STR0027 "Los primeros dígitos de la numeración inicial difieren del número del punto de venta."
	#define STR0028 "Los primeros dígitos de la numeración final difieren del número del punto de venta."
	#define STR0029 "El Punto de venta seleccionado tiene un tamaño diferente de "
	#define STR0030 ". Seleccione un Punto de venta que corresponda con la configuración "
	#define STR0031 "Tamaño Punto Venta"
#else
	#ifdef ENGLISH
		#define STR0001 "XXXXXXXXXXXXXXX"
		#define STR0002 "Search"
		#define STR0003 "View"
		#define STR0004 "Insert"
		#define STR0005 "Edit"
		#define STR0006 "Delete"
		#define STR0007 "There is already a CAI informed. Insertion not executed."
		#define STR0008 "There is already a range for the initial number informed. Insertion not executed."
		#define STR0009 "There is already a range for the final number informed. Insertion not executed."
		#define STR0010 "This CAI has already been used during the invoices generation. Deletion not executed."
		#define STR0011 "Initial Number cannot be changed as its range has already been used."
		#define STR0012 "XXXXXXXXXXXXXX"
		#define STR0013 "The fields below cannot be left blank: "
		#define STR0014 "Please, fill in. "
		#define STR0015 "Series and range entered already exist. Addition not accomplished."
		#define STR0016 "Page already used in generation of invoices. Deletion not accomplished."
		#define STR0017 "Digital Tax Vouchers "
		#define STR0018 "When type of Form. is equal to Pre-Printed, the field amount of Pre-Printed Item must be different from zero"
		#define STR0019 "When type of Form. is equal to Auto-Print, the field Amount of Pre-Printed Item must be equal to zero"
		#define STR0020 "Final form number is mandatory."
		#define STR0021 "Final number must not be filled out for the auto-printed form."
		#define STR0022 "Informed series already in use!"
		#define STR0023 "Series "
		#define STR0024 " is/are reserved for the statios "
		#define STR0025 "Operation cancelled."
		#define STR0026 "Form control already used for generating invoices."
		#define STR0027 "The first digits of initial numbering differ from the point of sales number."
		#define STR0028 "The first digits of final numbering differ from the point of sales number."
		#define STR0029 "The Point of Sales selected has size different than"
		#define STR0030 ". Select a Point of Sales corresponding to the configuration"
		#define STR0031 "Point of Sales Size"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Ficehiro De Controle De Formulários", "Cadastro de Controle de Formulários" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Procurar", "Pesquisar" )
		#define STR0003 "Visualizar"
		#define STR0004 "Incluir"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Modificar", "Alterar" )
		#define STR0006 "Apagar"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Já existe o util/cai introduzido. inclusão não realizada.", "Já existe o CAI informado. Inclusão não efetuada." )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Já existe um range para o número inicial introduzido. inclusão não realizada", "Já existe uma faixa para o número inicial informado. Inclusão não efetuada" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Já existe um range para o número final introduzido. inclusão não realizada", "Já existe uma faixa para o número final informado. Inclusão não efetuada" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Esse util/cai já foi utilizado na criação de facturas. exclusão não realizada.", "Esse CAI já foi utilizado na geração de notas fiscais. Exclusão não efetuada." )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "O número inicial não poderá ser alterado, pois o seu range já foi utilizado.", "O número inicial não pode ser alterado, pois a faixa já foi utilizada." )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "é necessário introduzir um tipo válido. inclusão não realizada.", "É necessário incluir uma espécie válida. Inclusão não efetuada." )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Os campos abaixo não podem ser deixados vazios:", "Os campos abaixo não podem ficar vazios:" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Por favor preencha-os.", "Favor preencher." )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Já existe a série e o intervalo indicados. inclusão não realizada.", "Já existe a série e o intervalo informados. Inclusão não efetuada." )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Fólio já utilizado na criação de notas fiscais. exclusão não realizada.", "Fólio já utilizado na geração de notas fiscais. Exclusão não efetuada." )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Comprovativos Fiscais Digitais", "Comprovantes Fiscais Digitais" )
		#define STR0018 "Quando o Tipo de Form. for igual a Pré-Impresso, o campo de Quantidade de Item Pré-Impresso deve ser diferente de zero"
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Quando o Tipo de Form. for igual a Auto-Impresso, o campo de quantidade de elemento Pré-Impresso deve ser igual a zero", "Quando o Tipo de Form. for igual a Auto-Impresso, o campo de quantidade de item Pré-Impresso deve ser igual a zero" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", " Número final de formulário é obrigatorio", " Número final de formulário é obrigatório" )
		#define STR0021 "Número final não deve ser preenchido para o formulário auto impresso"
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "A série informada já está em uso.", "A série informada já está em uso !" )
		#define STR0023 "A série "
		#define STR0024 " está reservada para a estação "
		#define STR0025 "Operação cancelada."
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Controlo de formulário ja utilizado na criação de facturas.", "Controle de formulário já utilizado na geração de notas fiscais." )
		#define STR0027 "Os primeiros dígitos da numeração inicial diferem do número do ponto de venda."
		#define STR0028 "Os primeiros dígitos da numeração final diferem do número do ponto de venda."
		#define STR0029 "O Ponto de Venda que foi  seleconado tem um tamanho diferente de "
		#define STR0030 ". Selecione um Punto de venda que corresponda com a configuracao "
		#define STR0031 "Tamanho Ponto Venda"
	#endif
#endif
