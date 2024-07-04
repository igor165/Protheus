#Include 'Protheus.ch' 
#Include 'RwMake.ch'
#Include 'FisaExtWiz_Class.ch'
#Include 'FisaExtWiz.ch'

Static lJob		:= IsBlind() .or. IsInCallStack('TAFXGSP') 
Static cBarra	:= IIf(IsSrvUnix(),'/','\')

/*/{Protheus.doc} FisaExtWiz_Class
	(Classe com os tributos da wizard do extrator fiscal)

	@type Class
	@author Vitor Ribeiro
	@since 15/03/2018

	@return Nil, nulo, não tem retorno.
	/*/
Class FisaExtWiz_Class

    Data aLayouts as Array
	Data aLayReinf as Array
    Data aFiliais as Array
	Data cSystemDiretorio as String

// Inicio - Atributos da wizard pagina Geração (Folder 1)
	Data dDataDe as Date
	Data dDataAte as Date  
	Data cTipoSaida as String  
	Data cDiretorioDestino as String  
	Data cArquivoDestino as String  
	Data cFiltraReinf as String  
	Data cFiltraInteg as String  
	Data cMoviCadastral as String  
	Data cAtvMultiThread as String  
	Data nQtdeThread as Numeric Init 0  
// Fim - Atributos da wizard pagina Geração (Folder 1)

// Inicio - Atributos da wizard pagina Movimento (Folder 2)
	Data cTipoMovimento as String  
	Data cNotaDe as String  
	Data cNotaAte as String  
	Data cSerieDe as String  
	Data cSerieAte as String  
	Data cEspecie as String  
// Fim - Atributos da wizard pagina Movimento (Folder 2)

// Inicio - Atributos da wizard pagina Apuração / SPED (Folder 3)
	Data cApuracaoIPI as String  
	Data cIncidTribPeriodo as String  
	Data cIniObrEscritFiscalCIAP as String  
	Data cTipoContribuicao as String  
	Data cIndRegimeCumulativo as String  
	Data cTipoAtividade as String  
	Data cIndNaturezaPJ as String  
	Data cServicoCodReceita as String  
	Data cCentralizarUnicaFilial as String  
	Data cOutrosCodReceita as String  
	Data cIndIncidTribut as String  
	
// Fim - Atributos da wizard pagina Apuração / SPED (Folder 3)

// Inicio - Atributos da wizard pagina Inventário (Folder 4)
	Data cMotivoInventario as String  
	Data dDataFechamentoEstoque as Date  
	Data cReg0210Mov as String  
// Fim - Atributos da wizard pagina Inventário (Folder 4)

// Inicio - Atributos da wizard pagina Financeiro (Folder 5)
	Data cTituReceber as String  
	Data cTituPagar as String  
	Data cBxReceber as String  
	Data cBxPagar as String  
// Fim - Atributos da wizard pagina Financeiro (Folder 5)

// Inicio - Atributos da wizard pagina Contribuinte (Folder 6)
	Data cEnviaContribuinte as String  
	Data cObrigatoriedadeECD as String  
	Data cClassIfTribTabela8 as String  
	Data cAcordoInterIsenMultas as String  
	Data cNomeContribuinte as String  
	Data cCpfContribuinte as String  
	Data cTelefoneContribuinte as String  
	Data cCelularContribuinte as String  
	Data cEmailContribuinte as String  
	Data cEnteFederativo as String  
	Data cCnpjEnteFederativo as String  
	Data cIndDesoneracaoCPRB as String  
	Data cIndSituacaoPJ as String  
	Data cEmail_ContatoReinf as String  
	Data cNome_ContatoReinf as String  
	Data cCPF_ContatoReinf as String  
	Data cDDD_ContatoReinf as String  
	Data cTEL_ContatoReinf as String  
	Data cDDDCEL_ContatoReinf as String  
	Data cCEL_ContatoReinf as String  
	
// Fim - Atributos da wizard pagina Contribuinte (Folder 6)

// Inicio - Atributos da wizard pagina Empresa de software (Folder 7)
	Data cCnpjEmpSoftware as String  
	Data cRazaoSocialEmpSoftware as String  
	Data cContatoEmpSoftware as String  
	Data cTelEmpSoftware as String  
	Data cCelEmpSoftware as String  
	Data cEmailEmpSoftware as String  
// Fim - Atributos da wizard pagina Empresa de software (Folder 7)

    Method New() Constructor
    Method LoadWizard()
    Method WriteWizard()
    Method LoadLayouts()
	Method LoadLayReinf()
	Method LoadFiliais()
	Method FilialSel(c_Filial)
	Method LayoutSel(c_Layout)
	Method LayoutDel(c_Layout)
	Method LayoutInc(c_Layout)
	
	Method SetJobFiliais()
	Method SetJobLayouts(l_Diario, l_selcLay)

// Inicio - Method's Set da wizard pagina Geração (Folder 1)
	Method SetDataDe(d_Set)
	Method SetDataAte(d_Set)
	Method SetTipoSaida(c_Set)
	Method SetDiretorioDestino(c_Set)
	Method SetArquivoDestino(c_Set)
	Method SetMoviCadastral(c_Set)
	Method SetFiltraReinf(c_Set)
	Method SetFiltraInteg(c_Set)
	Method SetAtvMultiThread(c_Set)
	Method SetQtdeThread(n_Set)
// Fim - Method's Set da wizard pagina Geração (Folder 1)

// Inicio - Method's Set da wizard pagina Movimento (Folder 2)
	Method SetTipoMovimento(c_Set)
	Method SetNotaDe(c_Set)
	Method SetNotaAte(c_Set)
	Method SetSerieDe(c_Set)
	Method SetSerieAte(c_Set)
	Method SetEspecie(c_Set)
// Fim - Method's Set da wizard pagina Movimento (Folder 2)

// Inicio - Method's Set da wizard pagina Apuração / SPED (Folder 3)
	Method SetApuracaoIPI(c_Set)
	Method SetIncidTribPeriodo(c_Set)
	Method SetIniObrEscritFiscalCIAP(c_Set)
	Method SetTipoContribuicao(c_Set)
	Method SetIndRegimeCumulativo(c_Set)
	Method SetTipoAtividade(c_Set)
	Method SetIndNaturezaPJ(c_Set)
	Method SetCentralizarUnicaFilial(c_Set)
	Method SetServicoCodReceita(c_Set)
	Method SetOutrosCodReceita(c_Set)
	Method SetIndIncidTribut(c_Set)
// Fim - Method's Set da wizard pagina Apuração / SPED (Folder 3)

// Inicio - Method's Set da wizard pagina Inventário (Folder 4)
	Method SetMotivoInventario(c_Set)
	Method SetDataFechamentoEstoque(d_Set)
	Method SetReg0210Mov(c_Set)
// Fim - Method's Set da wizard pagina Inventário (Folder 4)

// Inicio - Method's Set da wizard pagina Financeiro (Folder 5)
	Method SetTituReceber(c_Set)
	Method SetTituPagar(c_Set)
	Method SetBxReceber(c_Set)
	Method SetBxPagar(c_Set)

// Fim - Method's Set da wizard pagina Financeiro (Folder 5)

// Inicio - Method's Set da wizard pagina Contribuinte (Folder 6)
	Method SetEnviaContribuinte(c_Set)
	Method SetObrigatoriedadeECD(c_Set)
	Method SetClassIfTribTabela8(c_Set)
	Method SetAcordoInterIsenMultas(c_Set)
	Method SetNomeContribuinte(c_Set)
	Method SetCpfContribuinte(c_Set)
	Method SetTelContribuinte(c_Set)
	Method SetCelularContribuinte(c_Set)
	Method SetEmailContribuinte(c_Set)
	Method SetEnteFederativo(c_Set)
	Method SetCnpjEnteFederativo(c_Set)
	Method SetIndDesoneracaoCPRB(c_Set)
	Method SetIndSituacaoPj(c_Set)
	Method SetEmail_ContatoReinf(c_Set)
	Method SetNome_ContatoReinf(c_Set)
	Method SetCPF_ContatoReinf(c_Set)
	Method SetDDD_ContatoReinf(c_Set)
	Method SetTEL_ContatoReinf(c_Set)
	Method SetDDDCEL_ContatoReinf(c_Set)
	Method SetCEL_ContatoReinf(c_Set)
	
// Fim - Method's Set da wizard pagina Contribuinte (Folder 6)

// Inicio - Method's Set da wizard pagina Empresa de software (Folder 7)
	Method SetCnpjEmpSoftware(c_Set)
	Method SetRazaoSocialEmpSoftware(c_Set)
	Method SetContatoEmpSoftware(c_Set)
	Method SetTelEmpSoftware(c_Set)
	Method SetCelEmpSoftware(c_Set)
	Method SetEmailEmpSoftware(c_Set)
// Fim - Method's Set da wizard pagina Empresa de software (Folder 7)

	Method GetSystemDiretorio()
	Method GetQtdeFiliaisSelecionados()
	Method GetQtdeLayoutsSelecionados()

	Method GetShowMultiThread()
    Method GetLayouts()
    Method GetFiliais()

// Inicio - Method's Get da wizard pagina Geração (Folder 1)
	Method GetDataDe()
	Method GetDataAte()
	Method GetTipoSaida()
	Method GetDiretorioDestino()
	Method GetArquivoDestino()
	Method GetFiltraReinf()
	Method GetFiltraInteg()
	Method GetAtvMultiThread()
	Method GetQtdeThread()
// Fim - Method's Get da wizard pagina Geração (Folder 1)

// Inicio - Method's Get da wizard pagina Movimento (Folder 2)
	Method GetTipoMovimento()
	Method GetNotaDe()
	Method GetNotaAte()
	Method GetSerieDe()
	Method GetSerieAte()
	Method GetEspecie()
// Fim - Method's Get da wizard pagina Movimento (Folder 2)

// Inicio - Method's Get da wizard pagina Apuração / SPED (Folder 3)
	Method GetApuracaoIPI()
	Method GetIncidTribPeriodo()
	Method GetIniObrEscritFiscalCIAP()
	Method GetTipoContribuicao()
	Method GetIndRegimeCumulativo()
	Method GetTipoAtividade()
	Method GetIndNaturezaPJ()
	Method GetCentralizarUnicaFilial()
	Method GetServicoCodReceita()
	Method GetOutrosCodReceita()
	Method GetIndIncidTribut()
// Fim - Method's Get da wizard pagina Apuração / SPED (Folder 3)

// Inicio - Method's Get da wizard pagina Inventário (Folder 4)
	Method GetMotivoInventario()
	Method GetDataFechamentoEstoque()
	Method GetReg0210Mov()
// Fim - Method's Get da wizard pagina Inventário (Folder 4)

// Inicio - Method's Get da wizard pagina Financeiro (Folder 5)
	Method GetTituReceber()
	Method GetTituPagar()
	Method GetBxReceber()
	Method GetBxPagar()	
// Fim - Method's Get da wizard pagina Financeiro (Folder 5)

// Inicio - Method's Get da wizard pagina Contribuinte (Folder 6)
	Method GetEnviaContribuinte()
	Method GetObrigatoriedadeECD()
	Method GetClassIfTribTabela8()
	Method GetAcordoInterIsenMultas()
	Method GetNomeContribuinte()
	Method GetCpfContribuinte()
	Method GetTelContribuinte()
	Method GetCelularContribuinte()
	Method GetEmailContribuinte()
	Method GetEnteFederativo()
	Method GetCnpjEnteFederativo()
	Method GetIndDesoneracaoCPRB()
	Method GetIndSituacaoPj()
	Method GetEmail_ContatoReinf()
	Method GetNome_ContatoReinf()
	Method GetCPF_ContatoReinf()
	Method GetDDD_ContatoReinf()
	Method GetTEL_ContatoReinf()
	Method GetDDDCEL_ContatoReinf()
	Method GetCEL_ContatoReinf()
// Fim - Method's Get da wizard pagina Contribuinte (Folder 6)

// Inicio - Method's Get da wizard pagina Empresa de software (Folder 7)
	Method GetCnpjEmpSoftware()
	Method GetRazaoSocialEmpSoftware()
	Method GetContatoEmpSoftware()
	Method GetTelEmpSoftware()
	Method GetCelEmpSoftware()
	Method GetEmailEmpSoftware()
// Fim - Method's Get da wizard pagina Empresa de software (Folder 7)

EndClass

/*/{Protheus.doc} New
	(Method construtor da classe)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return Self, objeto, retorna o objeto da classe FisaExtWiz_Class
	/*/
Method New() Class FisaExtWiz_Class

    Self:aLayouts := {}
	Self:aLayReinf := {}
    Self:aFiliais := {}
	Self:cSystemDiretorio := ''

// Inicio - Atributos da wizard pagina Parametros (Folder Parametrização) 
	Self:cTipoSaida := ''
	Self:cDiretorioDestino := ''
	Self:cArquivoDestino := ''
	Self:cFiltraReinf	:=	'1'
	Self:cFiltraInteg	:= '1'
	Self:cAtvMultiThread := '2'
	Self:nQtdeThread := 0
// Fim - Atributos da wizard pagina Parametros (Folder Parametrização)

// Inicio Atributos da wizard pagina Movimento (Folder 1)
	Self:dDataDe := CToD('')
	Self:dDataAte := CToD('')
	Self:cCentralizarUnicaFilial := ''
	Self:cMoviCadastral := ''
	Self:cTipoMovimento := ''
	Self:cNotaDe := ''
	Self:cNotaAte := ''
	Self:cSerieDe := ''
	Self:cSerieAte := ''
	Self:cEspecie := ''
// Fim Atributos da wizard pagina Movimento (Folder 1)

// Inicio Atributos da wizard pagina Apuração / SPED (Folder 2)
	Self:cApuracaoIPI := ''
	Self:cIncidTribPeriodo := ''
	Self:cIniObrEscritFiscalCIAP := ''
	Self:cTipoContribuicao := ''
	Self:cIndRegimeCumulativo := ''
	Self:cTipoAtividade := ''
	Self:cIndNaturezaPJ := ''
	Self:cServicoCodReceita := ''
	Self:cOutrosCodReceita := ''
	Self:cIndIncidTribut := ''
// Fim Atributos da wizard pagina Apuração / SPED (Folder 2)

// Inicio Atributos da wizard pagina Inventário (Folder 3)
	Self:cMotivoInventario := ''
	Self:dDataFechamentoEstoque := CToD('')
	Self:cReg0210Mov := ''
// Fim Atributos da wizard pagina Inventário (Folder 3)

// Inicio - Folder 4 - Financeiro
	Self:cTituReceber := '2'
	Self:cTituPagar := '2'
	Self:cBxReceber := '1'
	Self:cBxPagar := '1'
// Fim - Folder 4 - Financeiro

// Inicio - Folder 5 - Contribuinte
	Self:cEnviaContribuinte := '2'
	Self:cObrigatoriedadeECD := ''
	Self:cClassIfTribTabela8 := ''
	Self:cAcordoInterIsenMultas := ''
	Self:cNomeContribuinte := ''
	Self:cCpfContribuinte := ''
	Self:cTelefoneContribuinte := ''
	Self:cCelularContribuinte := ''
	Self:cEmailContribuinte := ''
	Self:cEnteFederativo := ''
	Self:cCnpjEnteFederativo := ''
	Self:cIndDesoneracaoCPRB := ''
	Self:cIndSituacaoPJ := ''
	Self:cEmail_ContatoReinf := ''
	Self:cNome_ContatoReinf := ''
	Self:cCPF_ContatoReinf := ''
	Self:cDDD_ContatoReinf := ''
	Self:cTEL_ContatoReinf := ''
	Self:cDDDCEL_ContatoReinf := ''
	Self:cCEL_ContatoReinf := ''

// Fim - Folder 5 - Contribuinte

// Inicio - Folder 6 - Empresa de software
	Self:cCnpjEmpSoftware := ''
	Self:cRazaoSocialEmpSoftware := ''
	Self:cContatoEmpSoftware := ''
	Self:cTelEmpSoftware := ''
	Self:cCelEmpSoftware := ''
	Self:cEmailEmpSoftware := ''
// Fim - Folder 6 - Empresa de software

	// Carrega o profile
	Self:LoadWizard()

	// Carrega os layouts
	Self:LoadLayouts()

	// Carrega os layouts da Reinf
	Self:LoadLayReinf()

Return Self

/*/{Protheus.doc} LoadWizard
	(Method para carregar a wizard)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018
	
	@return Nil, nulo, não tem retorno.
	/*/
Method LoadWizard() Class FisaExtWiz_Class

    Local aProfile := {}

    Local nCount := 1

	Local oError := ErrorBlock({|Obj| ConOut("LoadWizard - Mensagem de Erro: " + Chr(10)+ Obj:Description + chr(10) + Obj:ErrorStack)} )

	Local bCodeBlock := {|| }
	
    // Funão para realizar a leitura no arquivo profile e retornar em um array separado por CRLF
    aProfile := fReadProf()

    // Percorre o array
    For nCount := 1 To Len(aProfile)
        // Se existir conteudo.
        If !Empty(aProfile[nCount])
            // Grava um bloco de codigo
            bCodeBlock := &('{|| Self:' + aProfile[nCount] + '}')

			// Trata para não gerar erro caso o arquivo seja alterado
			Begin Sequence
				Eval(bCodeBlock)
			Recover
				ErrorBlock(oError)
			End Sequence
        EndIf
    Next
    
Return Nil

/*/{Protheus.doc} fReadProf
	(Função para realizar a leitura do profile.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018
	
	@return aProfile, array, contém as informações da wizard.
	/*/
Static Function fReadProf()

	Local cProfile := ''
	Local cDiretorio := ''

	Local aProfile := {}

	// Se não for job
	If lJob
        cProfile := _WIZARD_JOB_
    Else
		cProfile := _WIZARD_ + '_' + __cUserID + '_' + cEmpAnt
	EndIf

    cProfile += '.PRB'

    // Retorna o diretorio
    cDiretorio := fGetFolder()

	// VerIfica se existe o arquivo na pasta
	If File(cDiretorio + cProfile)
		// Le o arquivo
		aProfile := Separa(MemoRead(cDiretorio + cProfile),CRLF)
	EndIf
	
Return aProfile

/*/{Protheus.doc} WriteWizard
	(Method para gravar a wizard)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018
	
	@return Nil, nulo, não tem retorno.
	/*/
Method WriteWizard() Class FisaExtWiz_Class

    Local aProfile := {}

// Inicio - Gravação da wizard pagina Parametros (Folder Parametrização)
    Aadd(aProfile,'SetTipoSaida("' + Self:cTipoSaida + '")')
    Aadd(aProfile,'SetDiretorioDestino("' + Self:cDiretorioDestino + '")')
    Aadd(aProfile,'SetArquivoDestino("' + Self:cArquivoDestino + '")')
	Aadd(aProfile,'SetFiltraReinf("' + Self:cFiltraReinf + '")')
	Aadd(aProfile,'SetFiltraInteg("' + Self:cFiltraInteg + '")')
// Fim - Gravação da wizard pagina Parametros (Folder Parametrização)

// Inicio - Gravação da wizard pagina Movimento (Folder 1)
    Aadd(aProfile,'SetDataDe(SToD("' + DToS(Self:dDataDe) + '"))')
    Aadd(aProfile,'SetDataAte(SToD("' + DToS(Self:dDataAte) + '"))')
    Aadd(aProfile,'SetCentralizarUnicaFilial("' + Self:cCentralizarUnicaFilial + '")')
    Aadd(aProfile,'SetMoviCadastral("' + Self:cMoviCadastral + '")')
    Aadd(aProfile,'SetTipoMovimento("' + Self:cTipoMovimento + '")')
    Aadd(aProfile,'SetNotaDe("' + Self:cNotaDe + '")')
    Aadd(aProfile,'SetNotaAte("' + Self:cNotaAte + '")')
    Aadd(aProfile,'SetSerieDe("' + Self:cSerieDe + '")')
    Aadd(aProfile,'SetSerieAte("' + Self:cSerieAte + '")')
    Aadd(aProfile,'SetEspecie("' + Self:cEspecie + '")')
// Fim - Gravação da wizard pagina Movimento (Folder 1)

// Inicio - Gravação da wizard pagina Apuração / SPED (Folder 2)
    Aadd(aProfile,'SetApuracaoIPI("' + Self:cApuracaoIPI + '")')
    Aadd(aProfile,'SetIncidTribPeriodo("' + Self:cIncidTribPeriodo + '")')
    Aadd(aProfile,'SetIniObrEscritFiscalCIAP("' + Self:cIniObrEscritFiscalCIAP + '")')
    Aadd(aProfile,'SetTipoContribuicao("' + Self:cTipoContribuicao + '")')
    Aadd(aProfile,'SetIndRegimeCumulativo("' + Self:cIndRegimeCumulativo + '")')
    Aadd(aProfile,'SetTipoAtividade("' + Self:cTipoAtividade + '")')
    Aadd(aProfile,'SetIndNaturezaPJ("' + Self:cIndNaturezaPJ + '")')
    Aadd(aProfile,'SetServicoCodReceita("' + Self:cServicoCodReceita + '")')
    Aadd(aProfile,'SetOutrosCodReceita("' + Self:cOutrosCodReceita + '")')
    Aadd(aProfile,'SetIndIncidTribut("' + Self:cIndIncidTribut + '")')
// Fim - Gravação da wizard pagina Apuração / SPED (Folder 2)

// Inicio - Gravação da wizard pagina Inventário (Folder 3)
    Aadd(aProfile,'SetMotivoInventario("' + Self:cMotivoInventario + '")')
    Aadd(aProfile,'SetDataFechamentoEstoque(SToD("' + DToS(Self:dDataFechamentoEstoque) + '"))')
    Aadd(aProfile,'SetReg0210Mov("' + Self:cReg0210Mov + '")')
// Fim - Gravação da wizard pagina Inventário (Folder 3)

// Inicio - Gravação da wizard pagina Financeiro (Folder 4)
    Aadd(aProfile,'SetTituReceber("' + Self:cTituReceber + '")')
    Aadd(aProfile,'SetTituPagar("' + Self:cTituPagar + '")')
	Aadd(aProfile,'SetBxReceber("' + Self:cBxReceber + '")')
	Aadd(aProfile,'SetBxPagar("' + Self:cBxPagar + '")')
// Fim - Gravação da wizard pagina Financeiro (Folder 4)

// Inicio - Gravação da wizard pagina Contribuinte (Folder 5)
    Aadd(aProfile,'SetObrigatoriedadeECD("' 		+ Self:cObrigatoriedadeECD 		+ '")')
    Aadd(aProfile,'SetClassIfTribTabela8("' 		+ Self:cClassIfTribTabela8 		+ '")')
    Aadd(aProfile,'SetAcordoInterIsenMultas("' 		+ Self:cAcordoInterIsenMultas 	+ '")')
    Aadd(aProfile,'SetNomeContribuinte("' 			+ Self:cNomeContribuinte 		+ '")')
    Aadd(aProfile,'SetCpfContribuinte("' 			+ Self:cCpfContribuinte 		+ '")')
    Aadd(aProfile,'SetTelContribuinte("' 			+ Self:cTelefoneContribuinte 	+ '")')
    Aadd(aProfile,'SetCelularContribuinte("' 		+ Self:cCelularContribuinte 	+ '")')
    Aadd(aProfile,'SetEmailContribuinte("' 			+ Self:cEmailContribuinte 		+ '")')
    Aadd(aProfile,'SetEnteFederativo("' 			+ Self:cEnteFederativo 			+ '")')
    Aadd(aProfile,'SetCnpjEnteFederativo("' 		+ Self:cCnpjEnteFederativo 		+ '")')
    Aadd(aProfile,'SetIndDesoneracaoCPRB("' 		+ Self:cIndDesoneracaoCPRB 		+ '")')
    Aadd(aProfile,'SetIndSituacaoPj("' 				+ Self:cIndSituacaoPJ 			+ '")')
    Aadd(aProfile,'SetEmail_ContatoReinf("' 		+ Self:cEmail_ContatoReinf 		+ '")')
	Aadd(aProfile,'SetNome_ContatoReinf("' 			+ Self:cNome_ContatoReinf		+ '")')
	Aadd(aProfile,'SetCPF_ContatoReinf("' 			+ Self:cCPF_ContatoReinf 		+ '")')
	Aadd(aProfile,'SetDDD_ContatoReinf("' 			+ Self:cDDD_ContatoReinf 		+ '")')
	Aadd(aProfile,'SetTEL_ContatoReinf("' 			+ Self:cTEL_ContatoReinf 		+ '")')
	Aadd(aProfile,'SetDDDCEL_ContatoReinf("' 		+ Self:cDDDCEL_ContatoReinf 	+ '")')
	Aadd(aProfile,'SetCEL_ContatoReinf("'			+ Self:cCEL_ContatoReinf 		+ '")')
// Fim - Gravação da wizard pagina Contribuinte (Folder 5)

// Inicio - Gravação da wizard pagina Empresa de software (Folder 6)
    Aadd(aProfile,'SetCnpjEmpSoftware("' + Self:cCnpjEmpSoftware + '")')
    Aadd(aProfile,'SetRazaoSocialEmpSoftware("' + Self:cRazaoSocialEmpSoftware + '")')
    Aadd(aProfile,'SetContatoEmpSoftware("' + Self:cContatoEmpSoftware + '")')
    Aadd(aProfile,'SetTelEmpSoftware("' + Self:cTelEmpSoftware + '")')
    Aadd(aProfile,'SetCelEmpSoftware("' + Self:cCelEmpSoftware + '")')
    Aadd(aProfile,'SetEmailEmpSoftware("' + Self:cEmailEmpSoftware + '")')
// Fim - Gravação da wizard pagina Empresa de software (Folder 6)

	// Sava a wizard
	fWriteProf(aProfile)

Return Nil

/*/{Protheus.doc} fWriteProf
	(Função para salvar os parametros no profile.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018
	
	@param a_Wizard, array, contém as informações da wizard.
	
	@return Nil, nulo, não tem retorno.
	/*/
Static Function fWriteProf(a_Profile)

	Local nCount := 0

	Local cWrite := ''
	Local cProfile := ''
	Local cDiretorio := ''

	Default a_Profile := {}

	// Se não for job
	If lJob
        cProfile := _WIZARD_JOB_
    Else
		cProfile := _WIZARD_ + '_' +  __cUserID + '_' + cEmpAnt
	EndIf

    cProfile += '.PRB'

    // Retorna o diretorio
    cDiretorio := fGetFolder()

	For nCount := 1 to Len(a_Profile)
		If ValType(a_Profile[nCount]) == 'N'
			cWrite += AllTrim(Str(a_Profile[nCount]))
		ElseIf ValType(a_Profile[nCount]) == 'L'
			cWrite += IIf(a_Profile[nCount],'.T.','.F.')
		ElseIf ValType(a_Profile[nCount]) == 'D'
			cWrite += DToS(a_Profile[nCount])
		Else
			cWrite += a_Profile[nCount]
		EndIf

		cWrite += CRLF
	Next

	// Grava o arquivo
	MemoWrit(cDiretorio + cProfile,cWrite)

Return Nil

/*/{Protheus.doc} fGetFolder
	(Função para buscar o folder do profile.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return cDiretorio, caracter, diretorio do profile
	/*/
Static Function fGetFolder()

	Local cDiretorio := ''

    // Pega o diretorio especIfido
	cDiretorio := cBarra + _DIRETORIO_ + cBarra

	// Se não existir o diretório
	If !ExistDir(cDiretorio)
		// Cria o diretório
		Makedir(cDiretorio)
	EndIf

	// Pega o diretorio especIfido do extrator.
	cDiretorio += _DIRETORIO_EXTRATOR_ + cBarra

	// Se não existir o diretório
	If !ExistDir(cDiretorio)
		// Cria o diretório
		Makedir(cDiretorio)
	EndIf

Return cDiretorio

/*/{Protheus.doc} LoadLayouts
	(Method para carregar os layouts do TAF.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018
	
	@return Nil, nulo, não tem retorno.
	/*/
Method LoadLayouts() Class FisaExtWiz_Class
	
	// Retorna os layouts
	Self:aLayouts := fLayouts()

Return Nil

/*/{Protheus.doc} LoadLayReinf
	(Method para carregar os layouts do TAF.)

	@type Static Function
	@author Henrique Pereira
	@since 10/02/2018
	
	@return Nil, nulo, não tem retorno.
	/*/
Method LoadLayReinf() Class FisaExtWiz_Class
	
	// Retorna os layouts
	Self:aLayReinf := fLayReinf()

Return Nil

/*/{Protheus.doc} fLayouts
	(Method para retornar os layouts.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018
	
	@return aLays, array, layouts para seleção
	/*/
Function fLayouts()

	Local aLays := {}

	Local lUsaTMS := IntTms()	// Identifica se usa a integracao TMS com os outros modulos

	/*
				Mark browser	,Layout		,Descrição do layout											,Periodo	,Layouts relacionados
	*/
	Aadd(aLays,{_MARK_NO_		,'T001AB'	,'PROCESSOS REFERENCIADOS'										,'DIARIO'	,{},'C'})

	If lUsaTMS
		Aadd(aLays,{_MARK_NO_		,'T001AC'	,'CADASTRO DE VEICULOS'											,'DIARIO'	,{},'C'})
	EndIf
	
	Aadd(aLays,{_MARK_NO_		,'T001AD'	,'CADASTRO DO ECF / SAT-CFE'									,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_NO_		,'T001AE'	,'DOCUMENTOS DE ARRECADACAO'									,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_NO_		,'T001AK'	,'INFORMACOES COMPLEMENTARES'									,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_NO_		,'T001AN'	,'DESENVOLVEDORA SOFTWARE'										,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_NO_		,'T002'		,'CADASTRO DE CONTABILISTAS'									,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_NO_		,'T003'		,'CADASTRO DE PARTICIPANTES'									,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_NO_		,'T005'		,'UNIDADE DE MEDIDA'											,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_NO_		,'T006'		,'FATORES DE CONVERSAO DA UM'									,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_NO_		,'T007'		,'IDENTIfICACAO DO ITEM'										,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_NO_		,'T009'		,'NATUREZA DE OPERACAO'											,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_NO_		,'T010'		,'PLANO DE CONTAS CONTABEIS'									,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_NO_		,'T011'		,'CENTRO DE CUSTO'												,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_NO_		,'T012'		,'DISPOSITIVO AIDF'												,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_NO_		,'T013'		,'DOCUMENTO FISCAL'												,'DIARIO'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T020'		,'APURACAO DE ICMS'												,'MENSAL'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T021'		,'APURACAO DE ICMS - ST'										,'MENSAL'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T022'		,'APURACAO DE IPI'												,'MENSAL'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T035'		,'DEDUCOES DIVERSAS'											,'MENSAL'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T045'		,'CONTROLE DE PRODUÇÃO E ESTOQUE'								,'MENSAL'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T065'		,'CONTR.CRD PIS/PASEP/COFINS'									,'MENSAL'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T066'		,'INF EXPORTACAO COMP DOCUMENTO'								,'DIARIO'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T067'		,'CONTROLE DOS CREDITOS FISCAIS'								,'MENSAL'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T069'		,'MOV. DIARIA DE COMBUSTIVEIS'									,'DIARIO'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T071'		,'CONTR.VAL.RET.PIS/PASEP/COFINS'								,'DIARIO'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T072'		,'INFO SOBRE VALORES AGREGADOS'									,'MENSAL'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T075'		,'INCORPORACAO IMOBILIARIA'										,'DIARIO'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T076'		,'DEM. CRED. TRANSP. AEREO'										,'DIARIO'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T078'		,'CADASTRO DE EQUIPAMENTO ECF'									,'DIARIO'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T079'		,'INVENTARIO'													,'MENSAL'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,"T080"		,'IDENT. EQUIPAMENTO SAT CFE'									,'DIARIO'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T082'		,'CONTRIB PREV RECEITA BRUTA'									,'MENSAL'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T154'		,'CADASTRO DE RECIBOS / FATURAS'								,'DIARIO'	,{},'M'})
	Aadd(aLays,{_MARK_NO_		,'T157'		,'CADASTRO DE OBRAS'											,'DIARIO'	,{},'C'})
	
	/*
		As linhas abaixo são layouts que ja foram desenvolvidos, porém não estão sendo usados.
		
		Aadd(aLays,{_MARK_NO_		,'T001AH'	,'REC. BRUTA MENSAL RATEIO CRED.'								,'MENSAL'	,{},'M'})	
		Aadd(aLays,{_MARK_NO_		,'T001AL'	,'LANCAMENTO FISCAL DO DOCUMENTO'								,'DIARIO'	,{},'C'})
		Aadd(aLays,{_MARK_NO_		,'T004'		,'REG AP CONTRIB PREV REC BRUTA'								,'MENSAL'	,{'T082','T083'},'M'})
		Aadd(aLays,{_MARK_NO_		,'T008'		,'BENS/COMP. ATV IMOBILIZADO'									,'MENSAL'	,{},'C'})		
		Aadd(aLays,{_MARK_NO_		,'T023'		,'CRÉDITO DE PIS/COFINS RELATIVO AO PERÍODO'					,'MENSAL'	,{'T024'},'M'})
		Aadd(aLays,{_MARK_NO_		,'T024'		,'CONSOLIDAÇÃO DA CONTRIBUÍÇÃO DO PERÍODO'						,'MENSAL'	,{'T023'},'M'})		
		Aadd(aLays,{_MARK_NO_		,'T030'		,'DEMAIS DOCS NAO VINCULADOS'									,'MENSAL'	,{},'M'})
		Aadd(aLays,{_MARK_NO_		,'T031'		,'BENS INCORP. ATIVO IMOBILIZADO - DEPRECIAÇÃO / AMORTIZAÇÃO'	,'MENSAL'	,{},'M'})
		Aadd(aLays,{_MARK_NO_		,'T032'		,'BENS INCORP. ATIVO IMOBILIZADO - AQUISIÇÃO / CONTRIBUIÇÃO'	,'MENSAL'	,{},'M'})		
		Aadd(aLays,{_MARK_NO_		,'T033'		,'OPER DA ATIVIDADE IMOBILIARIA'								,'MENSAL'	,{'T034','T037','T084','T085'},'M'})
		Aadd(aLays,{_MARK_NO_		,'T034'		,'CONTRIBUICAO RETIDA NA FONTE'									,'MENSAL'	,{'T033','T037','T084','T085'},'M'})		
		Aadd(aLays,{_MARK_NO_		,'T037'		,'CREDITO PRES ESTOQUE ABERTURA'								,'MENSAL'	,{'T033','T034','T084','T085'},'M'})		
		Aadd(aLays,{_MARK_NO_		,'T050'		,'CRED.ICMS SOBRE ATIVO PERMAN.'								,'MENSAL'	,{},'M'})		
		Aadd(aLays,{_MARK_NO_		,'T083'		,'CONS. CONTR. PREV. REC. BRUTA'								,'MENSAL'	,{'T004','T082'},'M'})
		Aadd(aLays,{_MARK_NO_		,'T084'		,'CONSOL. PJ - REGIME LUCRO PRESUMIDO'							,'DIARIO'	,{'T033','T034','T037','T085'},'M'})
		Aadd(aLays,{_MARK_NO_		,'T085'		,'COMPOS. RECEITA - REGIME DE CAIXA'							,'DIARIO'	,{'T033','T034','T037','T084'},'M'})		
		Aadd(aLays,{_MARK_NO_		,'T051'		,'APURACAO DE DIfAL/FECP'										,'MENSAL'	,{'T013'},'M'})
	*/
	
	
	/*
		As linhas abaixo são layouts que ainda não foram desenvolvidos. 
	
		Aadd(aLays,{_MARK_OK_		,'T001AI'	,'PER DISPENSADOS DA EFD CONTRIB'								,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T036'		,'CRDS DE EVENTOS INC/FUSAO/CISA'								,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T060'		,'PIS/COFINS DIfERIDA PER. ANT.'								,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T061'		,'FOLHA SALARIOS PIS/PASEP'										,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T062'		,'DETALHAM.RECEITAS ISENTAS'									,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T068'		,'CONTR.EXTEMP.PIS/PASEP/COFINS'								,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T070'		,'BOMBAS'														,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T081'		,'CONTR.PROD.DIARIA DA USINA'									,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T900'		,'RESUMO MENSAL DOS ITENS DO ECF POR ESTABELE'					,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T901'		,'RESUMO MENSAL DE ITENS DO ECF'								,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T902'		,'CONSOLIDACAO DIARIA DOCS MOD.06/28(CONV115)'					,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T903'		,'IDENTIfICACAO EQUIP. SAT-CF-E'								,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T904'		,'BILHETE CONSOLIDADOS DE PASSAGEM'								,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T905'		,'ANALITICO DOS BILHETES CONSOLIDADOS'							,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T906'		,'RESUMO DIARIO DE CUPOM FISCAL POR ECF'						,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T907'		,'CONSOLIDACAO DA PRESTACAO DE SERVICOS'						,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'T908'		,'CONSOLIDACAO DA PRESTACAO DE SERVICOS'						,''			,{}})
		Aadd(aLays,{_MARK_OK_		,'SPDC'		,'SPED Contribuições - Blocos F, I, M e P'						,''			,{}})
	*/
	
	// Ordena o array de acordo com os layouts
	Asort(aLays,,,{|x,y| x[2] < y[2] })

Return aLays

/*/{Protheus.doc} fLayReinf
	(Method para retornar os layouts.)

	@type Static Function
	@author Henrique Pereira
	@since 10/02/2018
	
	@return aLays, array, layouts para seleção
	/*/
Static Function fLayReinf()

	Local aLays := {}

	Aadd(aLays,{_MARK_OK_		,'T001AB'	,'PROCESSOS REFERENCIADOS'										,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_OK_		,'T001AK'	,'INFORMACOES COMPLEMENTARES'									,'DIARIO'	,{},'C'})	
	Aadd(aLays,{_MARK_OK_		,'T001AN'	,'DESENVOLVEDORA SOFTWARE'										,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_OK_		,'T003'		,'CADASTRO DE PARTICIPANTES'									,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_OK_		,'T005'		,'UNIDADE DE MEDIDA'											,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_OK_		,'T007'		,'IDENTIfICACAO DO ITEM'										,'DIARIO'	,{'T005'},'C'})
	Aadd(aLays,{_MARK_OK_		,'T009'		,'NATUREZA DE OPERACAO'											,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_OK_		,'T010'		,'PLANO DE CONTAS CONTABEIS'									,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_OK_		,'T011'		,'CENTRO DE CUSTO'												,'DIARIO'	,{},'C'})
	Aadd(aLays,{_MARK_OK_		,'T013'		,'DOCUMENTO FISCAL'												,'DIARIO'	,{},'M'})
	Aadd(aLays,{_MARK_OK_		,'T082'		,'CONTRIB PREV RECEITA BRUTA'									,'MENSAL'	,{},'M'})
	Aadd(aLays,{_MARK_OK_		,'T154'		,'CADASTRO DE RECIBOS / FATURAS'								,'DIARIO'	,{},'M'})
	Aadd(aLays,{_MARK_OK_		,'T157'		,'CADASTRO DE OBRAS'											,'DIARIO'	,{},'C'})
	 
	// Ordena o array de acordo com os layouts
	Asort(aLays,,,{|x,y| x[2] < y[2] })

Return aLays

/*/{Protheus.doc} LoadFiliais
	(Method para carregar as filiais.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018
	
	@return Nil, nulo, não tem retorno.
	/*/
Method LoadFiliais() Class FisaExtWiz_Class

	Local aArea := GetArea()
	Local aAreaSM0 := SM0->(GetArea())
	Local aFilxTaf := {}

	Local cCodFilLog 	:= ""
	Local cMensagem 	:= ""
	Local cCondic		:=	''

	Local nPosicao := 0
	Local aFilAtv := FWLoadSM0(.T.,.T.)


	Self:aFiliais := {}

	// Código da filial que o usuário esta logado
	cCodFilLog := SM0->M0_CODFIL

	SM0->(DbGoTop())
	While SM0->(!Eof()) 


		//não há necessidade de validação ao acesso a filial no cqso de schedule, pois a validação já ocorre no cadastro
		if lJob 
			cCondic := 'aScan( aFilAtv, {|x| AllTrim( x[1] ) + Alltrim(x[2]) == AllTrim( SM0->M0_CODIGO ) + Alltrim( SM0->M0_CODFIL ) } )'
		else
			// Busca somente as filais em que o usuário possui acesso
			cCondic := 'aFilAtv[aScan( aFilAtv, {|x| AllTrim( x[1] ) + Alltrim(x[2]) == AllTrim( SM0->M0_CODIGO ) + Alltrim( SM0->M0_CODFIL ) } )][11]'
		endif
		
		If &cCondic
	
			/*
				Dependendo da escolha do usuário na Wizard mostro todas as empresa e filiais
				em tela para seleção de processamento ou apenas as filiais onde a chave seja 
				igual a filial onde o cliente esta logado
			*/
			
			If cEmpAnt == SM0->M0_CODIGO
				// Validar a chave a ser considerada no TAF (COD.EMPRESA + CNPJ + IE + CODMUN)
				nPosicao := Ascan(aFilxTaf,{|x| x[1]+x[2]+x[3]+x[4]+x[6] == SM0->(M0_CODIGO+M0_CGC+M0_INSC+M0_CODMUN+M0_INSCM) })
				
				If Empty(nPosicao)
					Aadd(aFilxTaf,{SM0->M0_CODIGO,SM0->M0_CGC,SM0->M0_INSC,SM0->M0_CODMUN,IIf(Self:cCentralizarUnicaFilial=="2",cCodFilLog,SM0->M0_CODFIL),SM0->M0_INSCM})

					cMensagem := 'NÃO CENTRALIZAR as informações desta filial'
				Else
					cMensagem := 'CENTRALIZAR as informações desta filial'

					Self:aFiliais[nPosicao][3] := cMensagem
				EndIf

				Aadd(Self:aFiliais,{})
				nPosicao := Len(Self:aFiliais)

				Aadd(Self:aFiliais[nPosicao],_MARK_NO_)
				Aadd(Self:aFiliais[nPosicao],PadR(SM0->M0_CODFIL,Len(cFilAnt)))
				Aadd(Self:aFiliais[nPosicao],cMensagem)
				Aadd(Self:aFiliais[nPosicao],SM0->(' CNPJ: ' + M0_CGC + '| IE: ' + M0_INSC + '| CODMUN: ' + M0_CODMUN + '| IM: ' + M0_INSCM))
				Aadd(Self:aFiliais[nPosicao],SM0->M0_FILIAL)
			EndIf
		EndIf
		SM0->(DbSkip())
	EndDo

	RestArea(aAreaSM0)
	RestArea(aArea)
	cCondic := ''
Return Nil

/*/{Protheus.doc} FilialSel
	(Method para verificar se uma filial foi selecionada)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Filial, caracter, codigo da filial

	@return lFilialSel, logico, se a filial foi selecionada
	/*/
Method FilialSel(c_Filial) Class FisaExtWiz_Class

	Local lFilialSel := .F.

	// Verifica se a filial foi selecionada
	lFilialSel := Ascan(Self:aFiliais,{|x| x[1] == _MARK_OK_ .And. x[2] == c_Filial }) > 0

Return lFilialSel

/*/{Protheus.doc} LayoutDel
	(Method para retirar um layout para não ser selecionado)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Layout, caracter, codigo do layout

	@return Nil, nulo, não tem retorno.
	/*/
Method LayoutDel(c_Layout) Class FisaExtWiz_Class

	Local nPosicao := 0

	// Se foi informado um layout
	If !Empty(c_Layout)
		// Verifica se o layout foi selecionado
		nPosicao := Ascan(Self:aLayouts,{|x| x[2] == c_Layout })

		// Se encontrou o layout
		If !Empty(nPosicao)
			// Retira o layout do array
			ADel(Self:aLayouts,nPosicao)
			
			// Ajusta o array do layout
			ASize(Self:aLayouts,Len(Self:aLayouts) - 1)
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} LayoutInc
	(Method para incluir um layout para ser selecionado)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Layout, caracter, codigo do layout

	@return Nil, nulo, não tem retorno.
	/*/
Method LayoutInc(c_Layout) Class FisaExtWiz_Class

	Local nPosicao := 0
	Local nCount := 0

	Local aLays := {}

	// Se foi informado um layout
	If !Empty(c_Layout)
		// Verifica se o layout está no array
		nPosicao := Ascan(Self:aLayouts,{|x| x[2] == c_Layout })

		// Se não encontrou o layout
		If Empty(nPosicao)
			// Pega os layouts
			aLays := fLayouts()

			// Verifica o layout na lista de layouts
			nPosicao := Ascan(aLays,{|x| x[2] == c_Layout })

			// Se encontrou o layout
			If !Empty(nPosicao)
				// Adiciona uma posição
				Aadd(Self:aLayouts,{})

				// Percorre o array
				For nCount := 1 To Len(aLays[nPosicao])
					// Adiciona no array
					Aadd(Self:aLayouts[Len(Self:aLayouts)],aLays[nPosicao][nCount])
				Next

				// Ordena o array de acordo com os layouts
				Asort(Self:aLayouts,,,{|x,y| x[2] < y[2] })
			EndIf
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} LayoutSel
	(Method para verificar se um layout foi selecionado ou está relacionado a um layout selecionado)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Layout, caracter, codigo do layout

	@return lLayoutSel, logico, se o layout foi selecionado ou está relacionado a um layout selecionado
	/*/
Method LayoutSel(c_Layout) Class FisaExtWiz_Class

	Local lLayoutSel := .F.

	Local nCount := 0
	
	if lFiltReinf 
		lLayoutSel := Ascan(Self:aLayReinf,{|x| x[1] == _MARK_OK_ .And. x[2] == c_Layout }) > 0
	else
		// Verifica se o layout foi selecionado
		lLayoutSel := Ascan(Self:aLayouts,{|x| x[1] == _MARK_OK_ .And. x[2] == c_Layout }) > 0
	EndIf

	// Se não foi selecionado
	If !lLayoutSel
		// Percorre todos os layouts
		For nCount := 1 To Len(Self:aLayouts)
			// Se o layout foi selecionado
			If Self:aLayouts[nCount][1] == _MARK_OK_
				// Verifica se o layout está relacionado
				lLayoutSel := Ascan(Self:aLayouts[nCount][5],{|x| x == c_Layout }) > 0

				// Se o layout está relacionado
				If lLayoutSel
					Exit
				EndIf
			EndIf
		Next
	EndIf

Return lLayoutSel

/*/{Protheus.doc} SetJobFiliais
	(Method setar as filiais para o job)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param a_Filiais, array, contém as filiais

	@return Nil, nulo, não tem retorno
	/*/
Method SetJobFiliais(a_Filiais) Class FisaExtWiz_Class

	Local nCount := 0
	Local nPosicao := 0

	Default a_Filiais := {cFilAnt}

	For nCount := 1 To Len(a_Filiais)
		nPosicao := Ascan(Self:aFiliais,{|x| x[2] == a_Filiais[nCount] })

		If !Empty(nPosicao)
			Self:aFiliais[nPosicao][1] := _MARK_OK_
		EndIf
	Next

Return Nil

/*/{Protheus.doc} SetJobLayouts
	(Method setar os layouts para o job)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param l_Diario, logico, se somente os layouts diarios

	@return Nil, nulo, não tem retorno
	/*/
Method SetJobLayouts(l_Diario, l_selcLay, lLayGia) Class FisaExtWiz_Class
	Local nX			:=	0
	Local lAlsV5M		:= AliasInDic('V5M') 
	Local lAutoExt 		:= .f.
	Local nAuto			:= 0
	Local cLayGia		:= ''
	Default l_Diario 	:= .F.
	Default l_selcLay	:= .F.
	Default lLayGia		:= .f.

	//Se foi chamada da automação de teste.
	if lJob 
		while !empty(ProcName(nAuto))
			lAutoExt := 'EXTFIS_' $ ProcName(nAuto)
			if lAutoExt; exit; endif	
			nAuto++
		enddo
	endif
	
	if !lLayGia
		if !l_selcLay .or. lAutoExt
			// Se for diario e o layout for mensal, ele não deve ser marcado, se não deve marcar todos.
			AEval(Self:aLayouts,{|x| IIf(l_Diario .And. x[4] == "MENSAL",x[1] := _MARK_NO_,x[1] := _MARK_OK_) })
		elseif lAlsV5M .and. l_selcLay
			DbSelectArea('V5M')  
			V5M->(DbSetOrder(1))
			for nX = 1 to Len(Self:aLayouts)			
				If V5M->(MsSeek(XFilial('V5M')+Self:aLayouts[nX][2])) .and. !Empty(V5M->V5M_MARKED)
					Self:aLayouts[nX][1] := _MARK_OK_ 
				endif 
			next
		endif 
	else
		cLayGia := iif( lCadMov ,'T003|T005|T007|T009|T013|T020','T013|T020')
		for nX := 1 to len(self:aLayouts)
			if self:aLayouts[nX][2] $ cLayGia
				self:aLayouts[nX][1] := _MARK_OK_ 
			endif	
		next
	endif	

Return Nil

/*/{Protheus.doc} SetTipoSaida
	(Method para setar o valor no atributo cTipoSaida)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cTipoSaida

	@return Nil, nulo, não tem retorno
	/*/
Method SetTipoSaida(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cTipoSaida := c_Set
    
Return Nil

/*/{Protheus.doc} SetDiretorioDestino
	(Method para setar o valor no atributo cDiretorioDestino)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cDiretorioDestino

	@return Nil, nulo, não tem retorno
	/*/
Method SetDiretorioDestino(c_Set) Class FisaExtWiz_Class
    
    Default c_Set := ''

    Self:cDiretorioDestino := c_Set
    
Return Nil

/*/{Protheus.doc} SetArquivoDestino
	(Method para setar o valor no atributo cArquivoDestino)

	@type Method  
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cArquivoDestino

	@return Nil, nulo, não tem retorno
	/*/
Method SetArquivoDestino(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cArquivoDestino := c_Set
    
Return Nil

/*/{Protheus.doc} SetFiltraReinf
	(Method para setar o valor no atributo cFiltraReinf)

	@type Method  
	@author Henrique Pereira
	@since 28/11/2018

    @param c_Set, caracter, valor para atribuir no atributo cFiltrareinf

	@return Nil, nulo, não tem retorno
	/*/
Method SetFiltraReinf(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cFiltraReinf := c_Set
    
Return Nil

/*/{Protheus.doc} SetFiltraInteg
	(Method para setar o valor no atributo cFiltraInteg)

	@type Method  
	@author Bruno Cremaschi
	@since 15/02/2019

    @param c_Set, caracter, valor para atribuir no atributo cFiltrareinf

	@return Nil, nulo, não tem retorno
	/*/
Method SetFiltraInteg(c_set) Class FisaExtWiz_Class

	Default c_Set := ''

	Self:cFiltraInteg := c_Set

Return Nil

/*/{Protheus.doc} SetAtvMultiThread
	(Method para setar o valor no atributo cAtvMultiThread)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cAtvMultiThread

	@return Nil, nulo, não tem retorno
	/*/
Method SetAtvMultiThread(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cAtvMultiThread := c_Set
    
Return Nil

/*/{Protheus.doc} SetQtdeThread
	(Method para setar o valor no atributo nQtdeThread)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo nQtdeThread

	@return Nil, nulo, não tem retorno
	/*/
Method SetQtdeThread(n_Set) Class FisaExtWiz_Class

    Default n_Set := 0

    Self:nQtdeThread := n_Set
    
Return Nil

/*/{Protheus.doc} SetDataDe
	(Method para setar o valor no atributo dDataDe)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param d_Set, data, valor para atribuir no atributo dDataDe

	@return Nil, nulo, não tem retorno
	/*/
Method SetDataDe(d_Set) Class FisaExtWiz_Class  

    Default d_Set := StoD('') 

    Self:dDataDe := d_Set
    
Return Nil

/*/{Protheus.doc} SetDataAte
	(Method para setar o valor no atributo dDataAte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param d_Set, data, valor para atribuir no atributo dDataAte

	@return Nil, nulo, não tem retorno
	/*/
Method SetDataAte(d_Set) Class FisaExtWiz_Class

    Default d_Set := StoD('')

    Self:dDataAte := d_Set
    
Return Nil

/*/{Protheus.doc} SetCentralizarUnicaFilial
	(Method para setar o valor no atributo cCentralizarUnicaFilial)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cCentralizarUnicaFilial

	@return Nil, nulo, não tem retorno
	/*/
Method SetCentralizarUnicaFilial(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cCentralizarUnicaFilial := c_Set

	// Carrega as filiais
	Self:LoadFiliais()
    
Return Nil

/*/{Protheus.doc} SetMoviCadastral
	(Method para setar o valor no atributo cMoviCadastral)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cMoviCadastral

	@return Nil, nulo, não tem retorno
	/*/
Method SetMoviCadastral(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cMoviCadastral := c_Set
    
Return Nil

/*/{Protheus.doc} SetTipoMovimento
	(Method para setar o valor no atributo cTipoMovimento)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cTipoMovimento

	@return Nil, nulo, não tem retorno
	/*/
Method SetTipoMovimento(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cTipoMovimento := c_Set
    
Return Nil

/*/{Protheus.doc} SetNotaDe
	(Method para setar o valor no atributo cNotaDe)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cNotaDe

	@return Nil, nulo, não tem retorno
	/*/
Method SetNotaDe(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cNotaDe := c_Set
    
Return Nil

/*/{Protheus.doc} SetNotaAte
	(Method para setar o valor no atributo cNotaAte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cNotaAte

	@return Nil, nulo, não tem retorno
	/*/
Method SetNotaAte(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cNotaAte := c_Set
    
Return Nil

/*/{Protheus.doc} SetSerieDe
	(Method para setar o valor no atributo cSerieDe)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cSerieDe

	@return Nil, nulo, não tem retorno
	/*/
Method SetSerieDe(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cSerieDe := c_Set
    
Return Nil

/*/{Protheus.doc} SetSerieAte
	(Method para setar o valor no atributo cSerieAte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cSerieAte

	@return Nil, nulo, não tem retorno
	/*/
Method SetSerieAte(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cSerieAte := c_Set
    
Return Nil

/*/{Protheus.doc} SetEspecie
	(Method para setar o valor no atributo cEspecie)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cEspecie

	@return Nil, nulo, não tem retorno
	/*/
Method SetEspecie(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cEspecie := c_Set
    
Return Nil

/*/{Protheus.doc} SetApuracaoIPI
	(Method para setar o valor no atributo cApuracaoIPI)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cApuracaoIPI

	@return Nil, nulo, não tem retorno
	/*/
Method SetApuracaoIPI(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cApuracaoIPI := c_Set
    
Return Nil

/*/{Protheus.doc} SetIncidTribPeriodo
	(Method para setar o valor no atributo cIncidTribPeriodo)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cIncidTribPeriodo

	@return Nil, nulo, não tem retorno
	/*/
Method SetIncidTribPeriodo(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cIncidTribPeriodo := c_Set
    
Return Nil

/*/{Protheus.doc} SetIniObrEscritFiscalCIAP
	(Method para setar o valor no atributo cIniObrEscritFiscalCIAP)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cIniObrEscritFiscalCIAP

	@return Nil, nulo, não tem retorno
	/*/
Method SetIniObrEscritFiscalCIAP(c_Set) Class FisaExtWiz_Class
    
    Default c_Set := ''

    Self:cIniObrEscritFiscalCIAP := c_Set
    
Return Nil

/*/{Protheus.doc} SetTipoContribuicao
	(Method para setar o valor no atributo cTipoContribuicao)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cTipoContribuicao

	@return Nil, nulo, não tem retorno
	/*/
Method SetTipoContribuicao(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cTipoContribuicao := c_Set
    
Return Nil

/*/{Protheus.doc} SetIndRegimeCumulativo
	(Method para setar o valor no atributo cIndRegimeCumulativo)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cIndRegimeCumulativo

	@return Nil, nulo, não tem retorno
	/*/
Method SetIndRegimeCumulativo(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cIndRegimeCumulativo := c_Set
    
Return Nil

/*/{Protheus.doc} SetTipoAtividade
	(Method para setar o valor no atributo cTipoAtividade)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cTipoAtividade

	@return Nil, nulo, não tem retorno
	/*/
Method SetTipoAtividade(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cTipoAtividade := c_Set
    
Return Nil

/*/{Protheus.doc} SetIndNaturezaPJ
	(Method para setar o valor no atributo cIndNaturezaPJ)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cIndNaturezaPJ

	@return Nil, nulo, não tem retorno
	/*/
Method SetIndNaturezaPJ(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cIndNaturezaPJ := c_Set
    
Return Nil

/*/{Protheus.doc} SetServicoCodReceita
	(Method para setar o valor no atributo cServicoCodReceita)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cServicoCodReceita

	@return Nil, nulo, não tem retorno
	/*/
Method SetServicoCodReceita(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cServicoCodReceita := c_Set
    
Return Nil

/*/{Protheus.doc} SetOutrosCodReceita
	(Method para setar o valor no atributo cOutrosCodReceita)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cOutrosCodReceita

	@return Nil, nulo, não tem retorno
	/*/
Method SetOutrosCodReceita(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cOutrosCodReceita := c_Set
    
Return Nil

/*/{Protheus.doc} SetIndIncidTribut
	(Method para setar o valor no atributo cOutrosCodReceita)
	@type Method
	@author Paulo Krüger
	@since 20/07/2018
    @param c_Set, caracter, valor para atribuir no atributo cIndIncidTribut
	@return Nil, nulo, não tem retorno
	/*/
Method SetIndIncidTribut(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cIndIncidTribut := c_Set

Return Nil
	

/*/{Protheus.doc} SetMotivoInventario
	(Method para setar o valor no atributo cMotivoInventario)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cMotivoInventario

	@return Nil, nulo, não tem retorno
	/*/
Method SetMotivoInventario(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cMotivoInventario := c_Set
    
Return Nil

/*/{Protheus.doc} SetReg0210Mov
	(Method para setar o valor no atributo cReg0210Mov)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cReg0210Mov

	@return Nil, nulo, não tem retorno
	/*/
Method SetReg0210Mov(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cReg0210Mov := c_Set
    
Return Nil

/*/{Protheus.doc} SetDataFechamentoEstoque
	(Method para setar o valor no atributo dDataFechamentoEstoque)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param d_Set, data, valor para atribuir no atributo dDataFechamentoEstoque

	@return Nil, nulo, não tem retorno
	/*/
Method SetDataFechamentoEstoque(d_Set) Class FisaExtWiz_Class

    Default d_Set := StoD('')

    Self:dDataFechamentoEstoque := d_Set
    
Return Nil

/*/{Protheus.doc} SetTituReceber
	(Method para setar o valor no atributo cTituReceber)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cTituReceber

	@return Nil, nulo, não tem retorno
	/*/
Method SetTituReceber(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cTituReceber := c_Set
    
Return Nil

/*/{Protheus.doc} SetTituPagar
	(Method para setar o valor no atributo cTituPagar)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cTituPagar

	@return Nil, nulo, não tem retorno
	/*/
Method SetTituPagar(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cTituPagar := c_Set
    
Return Nil

/*/{Protheus.doc} SetBxReceber
	(Method para setar o valor no atributo cBxReceber)

	@type Method
	@author Karen Honda
	@since 10/06/2021

    @param c_Set, caracter, valor para atribuir no atributo cBxReceber

	@return Nil, nulo, não tem retorno
	/*/
Method SetBxReceber(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cBxReceber := c_Set
    
Return Nil

/*/{Protheus.doc} SetBxPagar
	(Method para setar o valor no atributo cBxPagar)

	@type Method
	@author Karen Honda
	@since 10/06/2021

    @param c_Set, caracter, valor para atribuir no atributo cBxPagar

	@return Nil, nulo, não tem retorno
	/*/
Method SetBxPagar(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cBxPagar := c_Set
    
Return Nil

/*/{Protheus.doc} SetEnviaContribuinte
	(Method para setar o valor no atributo cEnviaContribuinte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cEnviaContribuinte

	@return Nil, nulo, não tem retorno
	/*/
Method SetEnviaContribuinte(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cEnviaContribuinte := c_Set
    
Return Nil

/*/{Protheus.doc} SetObrigatoriedadeECD
	(Method para setar o valor no atributo cObrigatoriedadeECD)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cObrigatoriedadeECD

	@return Nil, nulo, não tem retorno
	/*/
Method SetObrigatoriedadeECD(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cObrigatoriedadeECD := c_Set
    
Return Nil

/*/{Protheus.doc} SetClassIfTribTabela8
	(Method para setar o valor no atributo cClassIfTribTabela8)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cClassIfTribTabela8

	@return Nil, nulo, não tem retorno
	/*/
Method SetClassIfTribTabela8(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cClassIfTribTabela8 := c_Set
    
Return Nil

/*/{Protheus.doc} SetAcordoInterIsenMultas
	(Method para setar o valor no atributo cAcordoInterIsenMultas)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cAcordoInterIsenMultas

	@return Nil, nulo, não tem retorno
	/*/
Method SetAcordoInterIsenMultas(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cAcordoInterIsenMultas := c_Set
    
Return Nil

/*/{Protheus.doc} SetNomeContribuinte
	(Method para setar o valor no atributo cNomeContribuinte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cNomeContribuinte

	@return Nil, nulo, não tem retorno
	/*/
Method SetNomeContribuinte(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cNomeContribuinte := c_Set
    
Return Nil

/*/{Protheus.doc} SetCpfContribuinte
	(Method para setar o valor no atributo cCpfContribuinte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cCpfContribuinte

	@return Nil, nulo, não tem retorno
	/*/
Method SetCpfContribuinte(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cCpfContribuinte := c_Set
    
Return Nil

/*/{Protheus.doc} SetTelContribuinte
	(Method para setar o valor no atributo cTelefoneContribuinte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cTelefoneContribuinte

	@return Nil, nulo, não tem retorno
	/*/
Method SetTelContribuinte(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cTelefoneContribuinte := c_Set
    
Return Nil

/*/{Protheus.doc} SetCelularContribuinte
	(Method para setar o valor no atributo cCelularContribuinte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cCelularContribuinte

	@return Nil, nulo, não tem retorno
	/*/
Method SetCelularContribuinte(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cCelularContribuinte := c_Set
    
Return Nil

/*/{Protheus.doc} SetEmailContribuinte
	(Method para setar o valor no atributo cEmailContribuinte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cEmailContribuinte

	@return Nil, nulo, não tem retorno
	/*/
Method SetEmailContribuinte(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cEmailContribuinte := c_Set
    
Return Nil

Method SetEmail_ContatoReinf(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cEmail_ContatoReinf := c_Set
    
Return Nil

Method SetNome_ContatoReinf(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cNome_ContatoReinf := c_Set
    
Return Nil

Method SetCPF_ContatoReinf(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cCPF_ContatoReinf := c_Set
    
Return Nil

Method SetDDD_ContatoReinf(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cDDD_ContatoReinf := c_Set
    
Return Nil

Method SetTEL_ContatoReinf(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cTEL_ContatoReinf := c_Set
    
Return Nil

Method SetDDDCEL_ContatoReinf(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cDDDCEL_ContatoReinf := c_Set
    
Return Nil

Method SetCEL_ContatoReinf(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cCEL_ContatoReinf := c_Set
    
Return Nil

/*/{Protheus.doc} SetEnteFederativo
	(Method para setar o valor no atributo cEnteFederativo)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cEnteFederativo

	@return Nil, nulo, não tem retorno
	/*/
Method SetEnteFederativo(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cEnteFederativo := c_Set
    
Return Nil

/*/{Protheus.doc} SetCnpjEnteFederativo
	(Method para setar o valor no atributo cCnpjEnteFederativo)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cCnpjEnteFederativo

	@return Nil, nulo, não tem retorno
	/*/
Method SetCnpjEnteFederativo(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cCnpjEnteFederativo := c_Set
    
Return Nil

/*/{Protheus.doc} SetIndDesoneracaoCPRB
	(Method para setar o valor no atributo cIndDesoneracaoCPRB)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cIndDesoneracaoCPRB

	@return Nil, nulo, não tem retorno
	/*/
Method SetIndDesoneracaoCPRB(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cIndDesoneracaoCPRB := c_Set
    
Return Nil

/*/{Protheus.doc} SetIndSituacaoPj
	(Method para setar o valor no atributo cIndSituacaoPJ)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cIndSituacaoPJ

	@return Nil, nulo, não tem retorno
	/*/
Method SetIndSituacaoPj(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cIndSituacaoPJ := c_Set
    
Return Nil

/*/{Protheus.doc} SetCnpjEmpSoftware
	(Method para setar o valor no atributo cCnpjEmpSoftware)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cCnpjEmpSoftware

	@return Nil, nulo, não tem retorno
	/*/
Method SetCnpjEmpSoftware(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cCnpjEmpSoftware := c_Set
    
Return Nil


/*/{Protheus.doc} SetRazaoSocialEmpSoftware
	(Method para setar o valor no atributo cRazaoSocialEmpSoftware)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cRazaoSocialEmpSoftware

	@return Nil, nulo, não tem retorno
	/*/
Method SetRazaoSocialEmpSoftware(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cRazaoSocialEmpSoftware := c_Set
    
Return Nil

/*/{Protheus.doc} SetContatoEmpSoftware
	(Method para setar o valor no atributo cContatoEmpSoftware)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cContatoEmpSoftware

	@return Nil, nulo, não tem retorno
	/*/
Method SetContatoEmpSoftware(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cContatoEmpSoftware := c_Set
    
Return Nil

/*/{Protheus.doc} SetTelEmpSoftware
	(Method para setar o valor no atributo cTelEmpSoftware)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cTelEmpSoftware

	@return Nil, nulo, não tem retorno
	/*/
Method SetTelEmpSoftware(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cTelEmpSoftware := c_Set
    
Return Nil

/*/{Protheus.doc} SetCelEmpSoftware
	(Method para setar o valor no atributo cCelEmpSoftware)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cCelEmpSoftware

	@return Nil, nulo, não tem retorno
	/*/
Method SetCelEmpSoftware(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cCelEmpSoftware := c_Set
    
Return Nil

/*/{Protheus.doc} SetEmailEmpSoftware
	(Method para setar o valor no atributo cEmailEmpSoftware)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

    @param c_Set, caracter, valor para atribuir no atributo cEmailEmpSoftware

	@return Nil, nulo, não tem retorno
	/*/
Method SetEmailEmpSoftware(c_Set) Class FisaExtWiz_Class

    Default c_Set := ''

    Self:cEmailEmpSoftware := c_Set
    
Return Nil

/*/{Protheus.doc} GetSystemDiretorio()
	(Method para verIficar se mostra a opção de multi thread na wizard)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return lShowMulti, logico, se mostra a opção multi thread na wizard
	/*/
Method GetSystemDiretorio() Class FisaExtWiz_Class

	// Se não tiver o diretorio e as datas de até estiverem preenchidas
	If Empty(Self:cSystemDiretorio) .And. !Empty(Self:dDataDe) .And. !Empty(Self:dDataAte)
		// Cria o diretorio
		Self:cSystemDiretorio := fMkDirSys(Self:dDataDe,Self:dDataAte)
	EndIf

Return Self:cSystemDiretorio

/*/{Protheus.doc} fMkDirSys
	(Esta Funcao realiza a Criacao dos Diretorios na RootPath)

	@type Static Function
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cNomeDir, caracter, nome do diretorio.
	/*/
Static Function fMkDirSys(d_DataDe,d_DataAte)

	Local nRetDir := 0

	Local cNomeDir := "\Extrator_TAF"

	Default d_DataDe := CToD("")
	Default d_DataAte := CToD("")

	// Se o diretorio não existir
	If !File(cNomeDir)
		// Cria o diretorio
		nRetDir := MakeDir(cNomeDir)

		// Se não conseguiu criar o diretorio
		If !Empty(nRetDir)
			cNomeDir := ""
		EndIf
	EndIf

	// Se o diretorio existe
	If !Empty(cNomeDir)
		cNomeDir += "\" + AllTrim(DToS(d_DataDe)) + "_" + AllTrim(DToS(d_DataAte))

		// Se o diretorio não existir
		If !File(cNomeDir)
			// Cria o diretorio
			nRetDir := MakeDir(cNomeDir)

			// Se não conseguiu criar o diretorio
			If !Empty(nRetDir)
				cNomeDir := ""
			EndIf
		EndIf
	EndIf

	// Se o diretorio existe
	If !Empty(cNomeDir)
		cNomeDir += "\" + StrTran(AllTrim(cFilAnt)," ","")

		// Se o diretorio não existir
		If !File(cNomeDir)
			// Cria o diretorio
			nRetDir := MakeDir(cNomeDir)

			// Se não conseguiu criar o diretorio
			If !Empty(nRetDir)
				cNomeDir := ""
			EndIf
		EndIf
	EndIf
	
Return cNomeDir

/*/{Protheus.doc} GetQtdeFiliaisSelecionados()
	(Method para verIficar se mostra a opção de multi thread na wizard)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return lShowMulti, logico, se mostra a opção multi thread na wizard
	/*/
Method GetQtdeFiliaisSelecionados() Class FisaExtWiz_Class

	Local nQtdeFil := 0

	AEval(Self:aFiliais,{|x| IIf(x[1]==_MARK_OK_,nQtdeFil++,) })

Return nQtdeFil

/*/{Protheus.doc} GetQtdeLayoutsSelecionados()
	(Method para verIficar se mostra a opção de multi thread na wizard)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return lShowMulti, logico, se mostra a opção multi thread na wizard
	/*/
Method GetQtdeLayoutsSelecionados() Class FisaExtWiz_Class

	Local nQtdeLay := 0

	AEval(Self:aLayouts,{|x| IIf(x[1]==_MARK_OK_,nQtdeLay++,) })

Return nQtdeLay

/*/{Protheus.doc} GetShowMultiThread()
	(Method para verIficar se mostra a opção de multi thread na wizard)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return lShowMulti, logico, se mostra a opção multi thread na wizard
	/*/
Method GetShowMultiThread() Class FisaExtWiz_Class

    Local lShowMulti := .F.

    Local aMvExtAThr := {}

    Local nCount := 0

    aMvExtAThr := Separa(AllTrim(GetMv("MV_EXTATHR",,"")),";")

    If !Empty(aMvExtAThr)
        If aMvExtAThr[1] == "S"     // Mostra a opção de multi thread na wizard sempre
            lShowMulti := .T.
        ElseIf aMvExtAThr[1] $ "A|E" // Mostra a opção de multi thread para administrador / usuários especIficos

            // Se a opção for administrador e o usuário for
            If aMvExtAThr[1] == "A" .And. FWIsAdmin(__cUserID)
                lShowMulti := .T.
            Else
                // Se existir ID's de usuários no parâmetro 
                If Len(aMvExtAThr) > 1
                    For nCount := 2 To Len(aMvExtAThr)
                        If AllTrim(aMvExtAThr[nCount]) == __cUserID
                            lShowMulti := .T.
                            Exit
                        EndIf
                    Next
                EndIf
            EndIf
        EndIf
    EndIf

Return lShowMulti

/*/{Protheus.doc} GetLayouts
	(Method para recuperar o valor do atributo aLayouts)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return aLayouts, array, retorna os layouts
	/*/
Method GetLayouts() Class FisaExtWiz_Class
Return Self:aLayouts

/*/{Protheus.doc} GetFiliais
	(Method para recuperar o valor do atributo aFiliais)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return aFiliais, array, retorna as filiais
	/*/
Method GetFiliais() Class FisaExtWiz_Class
Return Self:aFiliais

/*/{Protheus.doc} GetTipoSaida
	(Method para recuperar o valor do atributo cTipoSaida)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cTipoSaida, caracter, retorna o tipo da saida
	/*/
Method GetTipoSaida() Class FisaExtWiz_Class
Return Self:cTipoSaida

/*/{Protheus.doc} GetDiretorioDestino
	(Method para recuperar o valor do atributo cDiretorioDestino)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cDiretorioDestino, caracter, retorna o diretorio destino
	/*/
Method GetDiretorioDestino() Class FisaExtWiz_Class
Return Self:cDiretorioDestino

/*/{Protheus.doc} GetArquivoDestino
	(Method para recuperar o valor do atributo cArquivoDestino)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cArquivoDestino, caracter, retorna o arquivo destino
	/*/
Method GetArquivoDestino() Class FisaExtWiz_Class
Return Self:cArquivoDestino

/*/{Protheus.doc} GetFiltrareinf
	(Method para recuperar o valor do atributo cFiltraReinf)

	@type Method
	@author Henrique Pereira
	@since 28/11/2018

	@return cFiltraReinf, caracter, retorna o arquivo destino
	/*/
Method GetFiltraReinf() Class FisaExtWiz_Class
Return Self:cFiltraReinf

/*/{Protheus.doc} GetFiltraInteg
	(Method para recuperar o valor do atributo cFiltraInteg)

	@type Method
	@author Bruno Cremaschi
	@since 15/02/2019

	@return cFiltraReinf, caracter, retorna o arquivo destino
	/*/
Method GetFiltraInteg() Class FisaExtWiz_Class
Return Self:cFiltraInteg

/*/{Protheus.doc} GetAtvMultiThread
	(Method para recuperar o valor do atributo cAtvMultiThread)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cAtvMultiThread, caracter, retorna se ativa multi thread
	/*/
Method GetAtvMultiThread() Class FisaExtWiz_Class
Return Self:cAtvMultiThread

/*/{Protheus.doc} GetQtdeThread
	(Method para recuperar o valor do atributo cQtdeThread)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return nQtdeThread, numerico, retorna a quantidade de multi thread
	/*/
Method GetQtdeThread() Class FisaExtWiz_Class
Return Self:nQtdeThread

/*/{Protheus.doc} GetDataDe
	(Method para recuperar o valor do atributo dDataDe)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return dDataDe, data, retorna a data inicial
	/*/
Method GetDataDe() Class FisaExtWiz_Class
Return Self:dDataDe

/*/{Protheus.doc} GetDataAte
	(Method para recuperar o valor do atributo dDataAte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return dDataAte, data, retorna a data final
	/*/
Method GetDataAte() Class FisaExtWiz_Class
Return Self:dDataAte

/*/{Protheus.doc} GetCentralizarUnicaFilial
	(Method para recuperar o valor do atributo cCentralizarUnicaFilial)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cCentralizarUnicaFilial, caracter, retorna se deve centralizar em uma unica filial
	/*/
Method GetCentralizarUnicaFilial() Class FisaExtWiz_Class
Return Self:cCentralizarUnicaFilial

/*/{Protheus.doc} GetTipoMovimento
	(Method para recuperar o valor do atributo cTipoMovimento)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cTipoMovimento, caracter, retorna se o tipo de movimento
	/*/
Method GetTipoMovimento() Class FisaExtWiz_Class
Return Self:cTipoMovimento

/*/{Protheus.doc} GetNotaDe
	(Method para recuperar o valor do atributo cNotaDe)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cNotaDe, caracter, retorna a nota inicial
	/*/
Method GetNotaDe() Class FisaExtWiz_Class
Return Self:cNotaDe

/*/{Protheus.doc} GetNotaAte
	(Method para recuperar o valor do atributo cNotaAte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cNotaAte, caracter, retorna a nota final
	/*/
Method GetNotaAte() Class FisaExtWiz_Class
Return Self:cNotaAte

/*/{Protheus.doc} GetSerieDe
	(Method para recuperar o valor do atributo cSerieDe)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cSerieDe, caracter, retorna a Serie inicial
	/*/
Method GetSerieDe() Class FisaExtWiz_Class
Return Self:cSerieDe

/*/{Protheus.doc} GetSerieAte
	(Method para recuperar o valor do atributo cSerieAte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cSerieAte, caracter, retorna a Serie final
	/*/
Method GetSerieAte() Class FisaExtWiz_Class
Return Self:cSerieAte

/*/{Protheus.doc} GetEspecie
	(Method para recuperar o valor do atributo cEspecie)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cEspecie, caracter, retorna a Serie final
	/*/
Method GetEspecie(l_Query) Class FisaExtWiz_Class

	Local cEspecie := AllTrim(Self:cEspecie)

	Default l_Query := .F.

	If l_Query
		cEspecie := "'" + StrTran(cEspecie,";","','") + "'"
	EndIf

Return cEspecie

/*/{Protheus.doc} GetApuracaoIPI
	(Method para recuperar o valor do atributo cApuracaoIPI)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cApuracaoIPI, caracter, retorna a apuração de IPI
	/*/
Method GetApuracaoIPI() Class FisaExtWiz_Class
Return Self:cApuracaoIPI

/*/{Protheus.doc} GetIncidTribPeriodo
	(Method para recuperar o valor do atributo cIncidTribPeriodo)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cIncidTribPeriodo, caracter, retorna incidência tributária no periodo
	/*/
Method GetIncidTribPeriodo() Class FisaExtWiz_Class
Return Self:cIncidTribPeriodo

/*/{Protheus.doc} GetIniObrEscritFiscalCIAP
	(Method para recuperar o valor do atributo cIniObrEscritFiscalCIAP)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cIniObrEscritFiscalCIAP, caracter, retorna a obrigação de escrituração fiscal CIAP
	/*/
Method GetIniObrEscritFiscalCIAP() Class FisaExtWiz_Class
Return Self:cIniObrEscritFiscalCIAP

/*/{Protheus.doc} GetTipoContribuicao
	(Method para recuperar o valor do atributo cTipoContribuicao)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cTipoContribuicao, caracter, retorna o tipo de contribuição
	/*/
Method GetTipoContribuicao() Class FisaExtWiz_Class
Return Self:cTipoContribuicao

/*/{Protheus.doc} GetIndRegimeCumulativo
	(Method para recuperar o valor do atributo cIndRegimeCumulativo)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cIndRegimeCumulativo, caracter, retornar o indicador regime cumulativo
	/*/
Method GetIndRegimeCumulativo() Class FisaExtWiz_Class
Return Self:cIndRegimeCumulativo

/*/{Protheus.doc} GetTipoAtividade
	(Method para recuperar o valor do atributo cTipoAtividade)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cTipoAtividade, caracter, retorna o tipo de atividade
	/*/
Method GetTipoAtividade() Class FisaExtWiz_Class
Return Self:cTipoAtividade

/*/{Protheus.doc} GetIndNaturezaPJ
	(Method para recuperar o valor do atributo cIndNaturezaPJ)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cIndNaturezaPJ, caracter, retorna o indicador da natureza do PJ
	/*/
Method GetIndNaturezaPJ() Class FisaExtWiz_Class
Return Self:cIndNaturezaPJ

/*/{Protheus.doc} GetServicoCodReceita
	(Method para recuperar o valor do atributo cServicoCodReceita)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cServicoCodReceita, caracter, retorna o codigo da receita para prestação de serviços
	/*/
Method GetServicoCodReceita() Class FisaExtWiz_Class
Return Self:cServicoCodReceita

/*/{Protheus.doc} GetOutrosCodReceita
	(Method para recuperar o valor do atributo cOutrosCodReceita)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cOutrosCodReceita, caracter, retorna o codigo da receita para demais operações
	/*/
Method GetOutrosCodReceita() Class FisaExtWiz_Class
Return Self:cOutrosCodReceita

/*/{Protheus.doc} GetIndIncidTribut
	(Method para recuperar o valor do atributo GetIndIncidTribut)

	@type Method
	@author Paulo Krüger
	@since 15/03/2018

	@return cOutrosCodReceita, caracter, retorna o codigo da receita para demais operações
	/*/
Method GetIndIncidTribut() Class FisaExtWiz_Class
Return Self:cIndIncidTribut

/*/{Protheus.doc} GetMotivoInventario
	(Method para recuperar o valor do atributo cMotivoInventario)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cMotivoInventario, caracter, retorna o motivo do inventario.
	/*/
Method GetMotivoInventario() Class FisaExtWiz_Class
Return Self:cMotivoInventario

/*/{Protheus.doc} GetDataFechamentoEstoque
	(Method para recuperar o valor do atributo dDataFechamentoEstoque)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return dDataFechamentoEstoque, data, retorna a data de fechamento do estoque
	/*/
Method GetDataFechamentoEstoque() Class FisaExtWiz_Class
Return Self:dDataFechamentoEstoque

/*/{Protheus.doc} GetReg0210Mov
	(Method para recuperar o valor do atributo cReg0210Mov)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cReg0210Mov, caracter, retorna o registro T046 por mov.
	/*/
Method GetReg0210Mov() Class FisaExtWiz_Class
Return Self:cReg0210Mov

/*/{Protheus.doc} GetTituReceber
	(Method para recuperar o valor do atributo cTituReceber)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cTituReceber, caracter, retorna a obrigatoriedade do ECD
	/*/
Method GetTituReceber() Class FisaExtWiz_Class
Return Self:cTituReceber

/*/{Protheus.doc} GetTituPagar
	(Method para recuperar o valor do atributo cTituPagar)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cTituPagar, caracter, retorna a obrigatoriedade do ECD
	/*/
Method GetTituPagar() Class FisaExtWiz_Class
Return Self:cTituPagar

/*/{Protheus.doc} GetBxReceber
	(Method para recuperar o valor do atributo cBxReceber)

	@type Method
	@author Karen Honda
	@since 10/06/2021

	@return cBxReceber, caracter, retorna a obrigatoriedade do Reinf
	/*/
Method GetBxReceber() Class FisaExtWiz_Class
Return Self:cBxReceber

/*/{Protheus.doc} GetBxPagar
	(Method para recuperar o valor do atributo cBxPagar)

	@type Method
	@author Karen Honda
	@since 10/06/2021

	@return cBxPagar, caracter, retorna a obrigatoriedade do REINF
	/*/
Method GetBxPagar() Class FisaExtWiz_Class
Return Self:cBxPagar

/*/{Protheus.doc} GetEnviaContribuinte
	(Method para recuperar o valor do atributo cEnviaContribuinte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cEnviaContribuinte, caracter, retorna a obrigatoriedade do ECD
	/*/
Method GetEnviaContribuinte() Class FisaExtWiz_Class
Return Self:cEnviaContribuinte

/*/{Protheus.doc} GetObrigatoriedadeECD
	(Method para recuperar o valor do atributo cObrigatoriedadeECD)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cObrigatoriedadeECD, caracter, retorna a obrigatoriedade do ECD
	/*/
Method GetObrigatoriedadeECD() Class FisaExtWiz_Class
Return Self:cObrigatoriedadeECD

/*/{Protheus.doc} GetClassIfTribTabela8
	(Method para recuperar o valor do atributo cClassIfTribTabela8)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cClassIfTribTabela8, caracter, retorna a classIficação tributaria 
	/*/
Method GetClassIfTribTabela8() Class FisaExtWiz_Class
Return Self:cClassIfTribTabela8

/*/{Protheus.doc} GetAcordoInterIsenMultas
	(Method para recuperar o valor do atributo cAcordoInterIsenMultas)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cAcordoInterIsenMultas, caracter, retorna o acordo internacional isenção de multas
	/*/
Method GetAcordoInterIsenMultas() Class FisaExtWiz_Class
Return Self:cAcordoInterIsenMultas

/*/{Protheus.doc} GetNomeContribuinte
	(Method para recuperar o valor do atributo cNomeContribuinte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cNomeContribuinte, caracter, retorna o objeto da classe FisaExtWiz_Class
	/*/
Method GetNomeContribuinte() Class FisaExtWiz_Class
Return Self:cNomeContribuinte

/*/{Protheus.doc} GetCpfContribuinte
	(Method para recuperar o valor do atributo cCpfContribuinte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cCpfContribuinte, caracter, retorna o cpf do contribuinte
	/*/
Method GetCpfContribuinte() Class FisaExtWiz_Class
Return Self:cCpfContribuinte

/*/{Protheus.doc} GetTelefoneContribuinte
	(Method para recuperar o valor do atributo cTelefoneContribuinte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cTelefoneContribuinte, caracter, retorna o telefone do contribuinte
	/*/
Method GetTelContribuinte() Class FisaExtWiz_Class
Return Self:cTelefoneContribuinte

/*/{Protheus.doc} GetCelularContribuinte
	(Method para recuperar o valor do atributo cCelularContribuinte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cCelularContribuinte, caracter, retorna o celular do contribuinte
	/*/
Method GetCelularContribuinte() Class FisaExtWiz_Class
Return Self:cCelularContribuinte

/*/{Protheus.doc} GetEmailContribuinte
	(Method para recuperar o valor do atributo cEmailContribuinte)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cEmailContribuinte, caracter, retorna o email do contribuinte
	/*/
Method GetEmailContribuinte() Class FisaExtWiz_Class
Return Self:cEmailContribuinte

/*/{Protheus.doc} GetEmail_ContatoReinf
	(Method para recuperar o valor do atributo Email do Contato Reinf)

	@type Method
	@author Paulo Krüger
	@since 13/07/2018

	@return cEmail_ContatoReinf, caracter, retorna o email contato do REINF
	/*/
Method GetEmail_ContatoReinf() Class FisaExtWiz_Class
Return Self:cEmail_ContatoReinf 

/*/{Protheus.doc} GetNome_ContatoReinf
	(Method para recuperar o valor do atributo Nome do Contato Reinf)

	@type Method
	@author Paulo Krüger
	@since 13/07/2018

	@return cNome_ContatoReinf, caracter, retorna o nome do contato do REINF
	/*/
Method GetNome_ContatoReinf() Class FisaExtWiz_Class
Return Self:cNome_ContatoReinf

/*/{Protheus.doc} GetCPF_ContatoReinf
	(Method para recuperar o valor do atributo CPF do Contato Reinf)

	@type Method
	@author Paulo Krüger
	@since 13/07/2018

	@return cCPF_ContatoReinf, caracter, retorna o CPF do contato do REINF
	/*/
Method GetCPF_ContatoReinf() Class FisaExtWiz_Class
Return Self:cCPF_ContatoReinf


/*/{Protheus.doc} GetDDDContatoReinf
	(Method para recuperar o valor do atributo DDD do Contato Reinf)

	@type Method
	@author Paulo Krüger
	@since 13/07/2018

	@return cDDD_ContatoReinf, caracter, retorna o DDD do contato do REINF
	/*/
Method GetDDD_ContatoReinf() Class FisaExtWiz_Class
Return Self:cDDD_ContatoReinf


/*/{Protheus.doc} GetTEL_ContatoReinf
	(Method para recuperar o valor do atributo TEL do Contato Reinf)

	@type Method
	@author Paulo Krüger
	@since 13/07/2018

	@return cTEL_ContatoReinf, caracter, retorna o TEL do contato do REINF
	/*/
Method GetTEL_ContatoReinf() Class FisaExtWiz_Class
Return Self:cTEL_ContatoReinf


/*/{Protheus.doc} GetDDDCEL_ContatoReinf
	(Method para recuperar o valor do atributo DDD do Celular do Contato Reinf)

	@type Method
	@author Paulo Krüger
	@since 13/07/2018

	@return cDDDCEL_ContatoReinf, caracter, retorna o TEL do contato do REINF
	/*/
Method GetDDDCEL_ContatoReinf() Class FisaExtWiz_Class
Return Self:cDDDCEL_ContatoReinf


/*/{Protheus.doc} GetCEL_ContatoReinf
	(Method para recuperar o valor do atributo Celular do Contato Reinf)

	@type Method
	@author Paulo Krüger
	@since 13/07/2018

	@return cCEL_ContatoReinf, caracter, retorna o TEL do contato do REINF
	/*/
Method GetCEL_ContatoReinf() Class FisaExtWiz_Class
Return Self:cCEL_ContatoReinf


/*/{Protheus.doc} GetEnteFederativo
	(Method para recuperar o valor do atributo cEnteFederativo)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cEnteFederativo, caracter, retorna o email do contribuinte
	/*/
Method GetEnteFederativo() Class FisaExtWiz_Class
Return Self:cEnteFederativo

/*/{Protheus.doc} GetCnpjEnteFederativo
	(Method para recuperar o valor do atributo cCnpjEnteFederativo)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cCnpjEnteFederativo, caracter, retorna o email do contribuinte
	/*/
Method GetCnpjEnteFederativo() Class FisaExtWiz_Class
Return Self:cCnpjEnteFederativo

/*/{Protheus.doc} GetIndDesoneracaoCPRB
	(Method para recuperar o valor do atributo cIndDesoneracaoCPRB)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cIndDesoneracaoCPRB, caracter, retorna o email do contribuinte
	/*/
Method GetIndDesoneracaoCPRB() Class FisaExtWiz_Class
Return Self:cIndDesoneracaoCPRB

/*/{Protheus.doc} GetIndSituacaoPj
	(Method para recuperar o valor do atributo cIndSituacaoPj)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cIndSituacaoPj, caracter, retorna o email do contribuinte
	/*/
Method GetIndSituacaoPj() Class FisaExtWiz_Class
Return Self:cIndSituacaoPj


/*/{Protheus.doc} GetCnpjEmpSoftware
	(Method para recuperar o valor do atributo cCnpjEmpSoftware)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cCnpjEmpSoftware, caracter, retorna o cnpj da empresa de software
	/*/
Method GetCnpjEmpSoftware() Class FisaExtWiz_Class
Return Self:cCnpjEmpSoftware

/*/{Protheus.doc} GetRazaoSocialEmpSoftware
	(Method para recuperar o valor do atributo cRazaoSocialEmpSoftware)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cRazaoSocialEmpSoftware, caracter, retorna a razao social da empresa de software
	/*/
Method GetRazaoSocialEmpSoftware() Class FisaExtWiz_Class
Return Self:cRazaoSocialEmpSoftware

/*/{Protheus.doc} GetContatoEmpSoftware
	(Method para recuperar o valor do atributo cContatoEmpSoftware)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cContatoEmpSoftware, caracter, retorna o contato da empresa de software
	/*/
Method GetContatoEmpSoftware() Class FisaExtWiz_Class
Return Self:cContatoEmpSoftware

/*/{Protheus.doc} GetTelEmpSoftware
	(Method para recuperar o valor do atributo cTelEmpSoftware)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cTelEmpSoftware, caracter, retorna o telefone da empresa de software
	/*/
Method GetTelEmpSoftware() Class FisaExtWiz_Class
Return Self:cTelEmpSoftware

/*/{Protheus.doc} GetCelEmpSoftware
	(Method para recuperar o valor do atributo cCelEmpSoftware)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cCelEmpSoftware, caracter, retorna o telefone da empresa de software
	/*/
Method GetCelEmpSoftware() Class FisaExtWiz_Class
Return Self:cCelEmpSoftware

/*/{Protheus.doc} GetEmailEmpSoftware
	(Method para recuperar o valor do atributo cEmailEmpSoftware)

	@type Method
	@author Vitor Ribeiro
	@since 15/03/2018

	@return cEmailEmpSoftware, caracter, retorna o email da empresa de software
	/*/
Method GetEmailEmpSoftware() Class FisaExtWiz_Class
Return Self:cEmailEmpSoftware
