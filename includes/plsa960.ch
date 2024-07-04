#ifdef SPANISH
	#define STR0001 "Buscar"
	#define STR0002 "Visualizar"
	#define STR0003 "Incluir"
	#define STR0004 "Modificar"
	#define STR0005 "Borrar"
	#define STR0006 "(Des)Bloquear"
	#define STR0007 "Historial de (Des)bloqueo"
	#define STR0008 "Historial"
	#define STR0009 "Historial de (Des)bloqueo de Profesionales de Salud"
	#define STR0010 "Profesional de Salud"
	#define STR0011 "No existe Historial de (Des)bloqueo para este Profesional de Salud."
	#define STR0012 "Ok"
	#define STR0013 "�Fecha de (Des)bloqueo INVALIDA!"
	#define STR0014 "Profesional de Salud Activo"
	#define STR0015 "Profesional de Salud Bloqueado"
	#define STR0016 "Leyenda"
	#define STR0017 "Profesionales de salud"
	#define STR0018 "Especialidades del profesional"
	#define STR0019 "Atenci�n"
	#define STR0020 "Informe un n�mero de registro v�lido - Debe contener solamente n�meros y ser mayor que cero."
	#define STR0021 "Profesional de salud registrado."
	#define STR0022 "Existe relaci�n de este Profesional de salud con una Red de atenci�n."
	#define STR0023 "Existen registros vinculados. Borrado no permitido."
	#define STR0024 "El mantenimiento de las especialidades de este profesional debe realizarse por el archivo de RDA"
	#define STR0025 "Faltan datos b�sicos para inclusi�n:"
	#define STR0026 "N�mero de colegio:"
	#define STR0027 "Estado/Provincia/Regi�n:"
	#define STR0028 "Sigla:"
	#define STR0029 "Este registro fue incluido por la Red de atenci�n, y debe actualizarse por la misma."
	#define STR0030 "C�digo:"
	#define STR0031 "No existe archivo de profesional con el BB0 informado:"
	#define STR0032 "RCPF/RCPJ no v�lido o existente para otro profesional. Se grabar� vac�o. Clave:"
	#define STR0033 "* Error de validaci�n MVC:"
	#define STR0034 "Campo y valor:"
	#define STR0035 "C�digo de la operadora se cambi� por el est�ndar. C�digo original:"
	#define STR0036 "Archivo sin nombre del profesional. Se incluy� el est�ndar."
#else
	#ifdef ENGLISH
		#define STR0001 "Search"
		#define STR0002 "View"
		#define STR0003 "Add"
		#define STR0004 "Edit"
		#define STR0005 "Delete"
		#define STR0006 "(Un)Block "
		#define STR0007 "(Un)block history"
		#define STR0008 "History "
		#define STR0009 "History of (un)block health professionals "
		#define STR0010 "Health professional "
		#define STR0011 "No history of (un)block for this health professional. "
		#define STR0012 "OK"
		#define STR0013 "INVALID (un)block date! "
		#define STR0014 "Active health professional "
		#define STR0015 "Blocked health professional "
		#define STR0016 "Caption"
		#define STR0017 "Health Professionals"
		#define STR0018 "Professional specialties"
		#define STR0019 "Attention"
		#define STR0020 "Enter a valid record number - it must have only numbers and be greater than zero."
		#define STR0021 "Health professional already registered."
		#define STR0022 "There is relationship of this Health Professional with the Service Network."
		#define STR0023 "There area records linked. Deletion not allowed."
		#define STR0024 "The maintenance of the specialties of this professional must be executed through the Service Network register."
		#define STR0025 "Lack of basic data for addition:"
		#define STR0026 "Council Number:"
		#define STR0027 "State:"
		#define STR0028 "Acronym:"
		#define STR0029 "This record was added and must be updated by the Service Network."
		#define STR0030 "Code:"
		#define STR0031 "No professional record with BB0 entered:"
		#define STR0032 "EIN/SSN invalid or existing for other professional. It is saved as Blank. Key:"
		#define STR0033 "- MVC Validation Error:"
		#define STR0034 "Field and Value:"
		#define STR0035 "Operator code switched to default. Original code:"
		#define STR0036 "File missing Professional name. Default was entered."
	#else
		#define STR0001 "Pesquisar"
		#define STR0002 "Visualizar"
		#define STR0003 "Incluir"
		#define STR0004 "Alterar"
		#define STR0005 "Excluir"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "(des)bloquear", "(Des)Bloquear" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Hist�rico de (des)bloqueio", "Hist�rico de (Des)bloqueio" )
		#define STR0008 "Hist�rico"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Hist�rico (des)bloqueio Dos Profissionais De Sa�de", "Hist�rico (Des)bloqueio dos Profissionais de Sa�de" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Profissional De Sa�de", "Profissional de Sa�de" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "N�o Existe Hist�rico De (des)bloqueio Para Este Profissional De Sa�de.", "N�o existe Hist�rico de (Des)bloqueio para este Profissional de Sa�de." )
		#define STR0012 "Ok"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Data De (des)bloqueio Inv�lida!", "Data de (Des)bloqueio INV�LIDA!" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Profissional De Sa�de Activo", "Profissional de Sa�de Ativo" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Profissional De Sa�de Bloqueado", "Profissional de Sa�de Bloqueado" )
		#define STR0016 "Legenda"
		#define STR0017 "Profissionais de Sa�de"
		#define STR0018 "Especialidades do profissional"
		#define STR0019 "Aten��o"
		#define STR0020 "Informe um n�mero de registro v�lido - Deve conter apenas n�meros e ser maior que zero."
		#define STR0021 "Profissional de Sa�de j� cadastrado."
		#define STR0022 "Existe relacionamento deste Profissional de Sa�de com uma Rede de Atendimento."
		#define STR0023 "Existem registros atrelados. Exclus�o n�o permitida."
		#define STR0024 "A manuten��o das especialidades deste profissional deve ser realizado pelo cadastro de RDA"
		#define STR0025 "Falta dados b�sicos para inclus�o: "
		#define STR0026 "N�mero Conselho: "
		#define STR0027 "Estado: "
		#define STR0028 "Sigla: "
		#define STR0029 "Este registro foi incluido pela Rede de Atendimento, e deve ser atualizado pela mesma."
		#define STR0030 "C�digo: "
		#define STR0031 "N�o existe cadastro de profissional com o BB0 informado: "
		#define STR0032 "CPF/CNPJ inv�lido ou existente para outro profissional. Ser� gravado vazio. Chave: "
		#define STR0033 "* Erro de Valida��o MVC: "
		#define STR0034 "Campo e Valor: "
		#define STR0035 "Codigo da Operadora foi trocado pelo padr�o. Codigo original: "
		#define STR0036 "Arquivo sem nome do Profissional. Inserido o padr�o."
	#endif
#endif
