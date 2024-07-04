#Include "Protheus.ch"
#Include "CFGX060.ch"

/*/{Protheus.doc} CFGX060
Wizard de convers�o de Certificado Digital - SIAFI

@author Pedro Alencar	
@since 15/01/2015	
@version 12.1.3
/*/
Function CFGX060()
	WizCertif()
Return Nil

/*/{Protheus.doc} WizCertif
Fun��o que monta as etapas do Wizard de convers�o do arquivo .PFX, do 
certificado digital, em arquivos .PEM.

@author Pedro Alencar	
@since 15/01/2015	
@version 12.1.3
/*/
Static Function WizCertif()
	Local oWizard
	Local cArquivo := ""
	Local cPsw := ""
	Local cArqCA := "\certif_ca"
	Local cArqCERT := "\certif_cert"
	Local cArqKEY := "\certif_key"
	Local cRet := ""
	Local bNextPn3 := {|| Iif( VldPanel3( cArqCA, cArqCERT, cArqKEY ), ConvCertif( cArquivo, cPsw, cArqCA, cArqCERT, cArqKEY, @cRet ), .F. ) }
	
	//Painel 1 - Tela inicial do Wizard
	oWizard := APWizard():New( OemToAnsi(STR0001), "", OemToAnsi(STR0002), OemToAnsi(STR0003), {||.T.}, {||.T.}, .F. ) // "Convers�o de arquivo .PFX em arquivos .PEM", "Assistente de Convers�o de Certificado Digital", "Essa rotina ir� converter o arquivo .PFX, do certificado digital, em arquivos .PEM com a extra��o do Certificado de Autoriza��o, Certificado de Cliente e Chave Privada."
	
	//Painel 2 - Caminho e Senha do Certificado Digital
	oWizard:NewPanel( OemToAnsi(STR0004), OemToAnsi(STR0005), {||.T.}, {|| VldPanel2( cArquivo, cPsw ) }, {||.T.}, .T., {|| MontaTela1( oWizard, @cArquivo, @cPsw ) } ) //"Caminho do Certificado Digital", "Defini��o do caminho do arquivo .PFX, do certificado digital, para a convers�o."
	
	//Painel 3 - Caminho dos arquivos de sa�da
	oWizard:NewPanel( OemToAnsi(STR0006), OemToAnsi(STR0007), {||.T.}, bNextPn3, {||.T.}, .T., {|| MontaTela2( oWizard, @cArqCA, @cArqCERT, @cArqKEY ) } ) //"Local de grava��o dos arquivos de sa�da", "Defini��o do caminho dos arquivos .PEM que ser�o gerados."
	
	//Painel 4 - T�rmino da Convers�o
	oWizard:NewPanel( OemToAnsi(STR0008), OemToAnsi(STR0009), {||.F.}, {||.T.}, {||.T.}, .T., {|| MontaTela3( oWizard, cRet ) } ) //"T�rmino da Convers�o", "Resultado do processo de convers�o do certificado digital."
	
	//Ativa a tela do wizard
	oWizard:Activate( .T., {||.T.}, {||.T.}, {||.T.} )
	
Return Nil

/*/{Protheus.doc} MontaTela1
Fun��o que monta, no Wizard, a tela com o campo de sele��o do arquivo 
.PFX, do certificado digital, e a senha para ser convertido.

@param oWizard, Objeto da classe APWizard
@param cArquivo, Caminho do arquivo de certificado (por refer�ncia)
@param cPsw, Senha de autoriza��o do certificado (por refer�ncia) 

@author Pedro Alencar	
@since 15/01/2015
@version 12.1.3
/*/
Static Function MontaTela1( oWizard, cArquivo, cPsw )
	Local oPanel := oWizard:oMPanel[oWizard:nPanel]   
	Local oGet1
	Local cArqAnt := ""
	Local cFiltro := OemToAnsi(STR0010) + " (*.pfx)|*.pfx" //"Arquivo de Certificado"
	Local bAction := {|| cArqAnt := cArquivo, cArquivo := AllTrim( cGetFile( cFiltro, OemToAnsi(STR0011), 0, "", .T., GETF_ONLYSERVER, .T. ) ) , Iif( Empty( cArquivo ), cArquivo := cArqAnt, ) } //"Sele��o de certificado"
	Default cArquivo := ""
	Default cPsw := ""
	
	//Caminho do arquivo de certificado
	TSay():New( 010, 018, {|| OemToAnsi(STR0012) }, oPanel, , , , , , .T. ) //"Caminho do Certificado Digital: "
	oGet1 := TGet():New( 008, 095, {|u| Iif( PCount() > 0, cArquivo := u, cArquivo + Space( 250 - Len( cArquivo ) ) ) }, oPanel, 150,,,,,,,,,.T.,,,,,,,,.F.,,"cArquivo" )
	oGet1:bHelp := {|| Help( , , "CERTIFILE", , OemToAnsi(STR0013), 1, 0 ) } //"Caminho do arquivo .PFX, do certificado digital, que ser� convertido nos arquivos .PEM."
	TButton():New( 0.6, 62, OemToAnsi(STR0014), oPanel, bAction, 40 ) //"Procurar..."   
	
	//Senha de autoriza��o do certificado
	TSay():New( 030, 018, {|| OemToAnsi(STR0015) }, oPanel, , , , , , .T. ) //"Senha de autoriza��o: "
	oGet1 := TGet():New( 028, 095, {|u| Iif( PCount() > 0, cPsw := u, cPsw + Space( 250 - Len( cPsw ) ) ) }, oPanel, 150,,,,,,,,,.T.,,,,,,,,.F.,,"cPsw" )
	oGet1:bHelp := {|| Help( , , "CERTIFPASS", , OemToAnsi(STR0016), 1, 0 ) } //"Senha de autoriza��o definida na instala��o do certificado digital."
	
Return Nil

/*/{Protheus.doc} MontaTela2
Fun��o que monta, no Wizard, a tela com os campos de defini��o de nome e
localde grava��o dos novos arquivos .PEM.

@param oWizard, Objeto da classe APWizard
@param cArqCA, Caminho do arquivo CA que ser� criado (por refer�ncia)
@param cArqCERT, Caminho do arquivo CERT que ser� criado (por refer�ncia)
@param cArqKEY, Caminho do arquivo KEY que ser� criado (por refer�ncia) 

@author Pedro Alencar	
@since 15/01/2015
@version 12.1.3
/*/
Static Function MontaTela2( oWizard, cArqCA, cArqCERT, cArqKEY )
	Local oPanel := oWizard:oMPanel[oWizard:nPanel]   
	Local oGet1
	Local cArqAnt := ""
	Local cFiltro := OemToAnsi(STR0010) + " (*.pem)|*.pem" //"Arquivo de Certificado"
	Local bActCA := {|| cArqAnt := cArqCA, cArqCA := AllTrim( cGetFile( cFiltro, OemToAnsi(STR0017), 0, "", .F., GETF_ONLYSERVER, .T. ) ) , Iif( Empty( cArqCA ), cArqCA := cArqAnt, ) } //"Sele��o da pasta de grava��o"
	Local bActCERT := {|| cArqAnt := cArqCERT, cArqCERT := AllTrim( cGetFile( cFiltro, OemToAnsi(STR0017), 0, "", .F., GETF_ONLYSERVER, .T. ) ) , Iif( Empty( cArqCERT ), cArqCERT := cArqAnt, ) } //"Sele��o da pasta de grava��o"
	Local bActKEY := {|| cArqAnt := cArqKEY, cArqKEY := AllTrim( cGetFile( cFiltro, OemToAnsi(STR0017), 0, "", .F., GETF_ONLYSERVER, .T. ) ) , Iif( Empty( cArqKEY ), cArqKEY := cArqAnt, ) } //"Sele��o da pasta de grava��o"
	Default cArqCA := ""
	Default cArqCERT := ""
	Default cArqKEY := ""
	
	//Caminho do Certificado de Autoriza��o 
	TSay():New( 010, 018, {|| OemToAnsi(STR0018) }, oPanel, , , , , , .T. ) //"Certificado de Autoriza��o (CA):"
	oGet1 := TGet():New( 008, 100, {|u| Iif( PCount() > 0, cArqCA := u, cArqCA + Space( 250 - Len( cArqCA ) ) ) }, oPanel, 150,,,,,,,,,.T.,,,,,,,,.F.,,"cArqCA" )
	oGet1:bHelp := {|| Help( , , "OUTFILE1", , OemToAnsi(STR0019), 1, 0 ) } //"Defina o nome do arquivo (sem extens�o) e a pasta no qual o mesmo ser� gravado ao t�rmino da convers�o."
	TButton():New( 0.6, 63, OemToAnsi(STR0014), oPanel, bActCA, 40 ) //"Procurar..."
	
	//Caminho do Certificado de Cliente
	TSay():New( 030, 018, {|| OemToAnsi(STR0020) }, oPanel, , , , , , .T. ) //"Certificado de Cliente (CERT):"
	oGet1 := TGet():New( 028, 100, {|u| Iif( PCount() > 0, cArqCERT := u, cArqCERT + Space( 250 - Len( cArqCERT ) ) ) }, oPanel, 150,,,,,,,,,.T.,,,,,,,,.F.,,"cArqCERT" )
	oGet1:bHelp := {|| Help( , , "OUTFILE2", , OemToAnsi(STR0019), 1, 0 ) } //"Defina o nome do arquivo (sem extens�o) e a pasta no qual o mesmo ser� gravado ao t�rmino da convers�o."
	TButton():New( 2.6, 63, OemToAnsi(STR0014), oPanel, bActCERT, 40 ) //"Procurar..."
	
	//Caminho da Chave Privada
	TSay():New( 050, 018, {|| OemToAnsi(STR0021) }, oPanel, , , , , , .T. ) //"Chave Privada (KEY):"
	oGet1 := TGet():New( 048, 100, {|u| Iif( PCount() > 0, cArqKEY := u, cArqKEY + Space( 250 - Len( cArqKEY ) ) ) }, oPanel, 150,,,,,,,,,.T.,,,,,,,,.F.,,"cArqKEY" )
	oGet1:bHelp := {|| Help( , , "OUTFILE3", , OemToAnsi(STR0019), 1, 0 ) } //"Defina o nome do arquivo (sem extens�o) e a pasta no qual o mesmo ser� gravado ao t�rmino da convers�o."
	TButton():New( 4.6, 63, OemToAnsi(STR0014), oPanel, bActKEY, 40 ) //"Procurar..."
	
Return Nil

/*/{Protheus.doc} MontaTela3
Fun��o que monta, no Wizard, a tela de conclus�o da convers�o

@param oWizard, Objeto da classe APWizard
@param cRet, Mensagem de erro, se a convers�o falhou 

@author Pedro Alencar	
@since 15/01/2015
@version 12.1.3
/*/
Static Function MontaTela3( oWizard, cRet )
	Local oPanel := oWizard:oMPanel[oWizard:nPanel]   
	Default cRet := ""
	
	If AllTrim( cRet ) == ""
		TSay():New( 010, 018, {|| OemToAnsi(STR0022) }, oPanel, , , , , , .T. ) //"Convers�o conclu�da com sucesso!:"
	Else
		TSay():New( 010, 018, {|| OemToAnsi(STR0023) }, oPanel, , , , , , .T. ) //"N�o foi poss�vel gerar os arquivos corretamente."		
		//Exibe a mensagem de erro do processamento da fun��es de convers�o
		TSay():New( 030, 018, {|| cRet }, oPanel, , , , , , .T. )
	Endif
	
Return Nil

/*/{Protheus.doc} VldPanel2
Fun��o que valida os dados informados no painel de defini��o
do caminho do arquivo .PFX e senha de autoriza��o

@param cArquivo, Caminho do arquivo .PFX do certificado
@param cPsw, Senha de autoriza��o do certificado

@author Pedro Alencar	
@since 15/01/2015
@version 12.1.3
/*/
Static Function VldPanel2( cArquivo, cPsw )
	Local lRet := .T.
	
	If AllTrim( cArquivo ) == "" .OR. AllTrim( cPsw ) == ""
		Help( "", 1, "VldPanel2", , OemToAnsi(STR0024), 2, 0 ) //"� necess�rio informar o caminho do arquivo .PFX do certificado e a senha de autoriza��o configurada."
		lRet := .F.		
	Endif
	
Return lRet

/*/{Protheus.doc} VldPanel3
Fun��o que valida os dados informados no painel de defini��o
do caminho do arquivo .PFX e senha de autoriza��o

@param cArqCA, Caminho do arquivo CA que ser� criado
@param cArqCERT, Caminho do arquivo CERT que ser� criado
@param cArqKEY, Caminho do arquivo KEY que ser� criado 

@author Pedro Alencar	
@since 15/01/2015
@version 12.1.3
/*/
Static Function VldPanel3( cArqCA, cArqCERT, cArqKEY )
	Local lRet := .T.
	
	If AllTrim( cArqCA ) == "" .OR. AllTrim( cArqCERT ) == "" .OR. AllTrim( cArqKEY ) == ""
		Help( "", 1, "VldPanel3", , OemToAnsi(STR0025), 2, 0 ) //"� necess�rio informar o caminho e o nome dos tr�s arquivos .PEM que ser�o gerados na convers�o."
		lRet := .F.		
	Endif
	
Return lRet

/*/{Protheus.doc} ConvCertif
Fun��o que converte o certificado em 3 arquivos .PEM, sendo eles:
Certificado de Autoriza��o, Certificado de Cliente e Chave Privada.

@param cArquivo, Caminho do arquivo .PFX do certificado
@param cPsw, Senha de autoriza��o do certificado
@param cArqCA, Caminho do arquivo CA que ser� criado
@param cArqCERT, Caminho do arquivo CERT que ser� criado
@param cArqKEY, Caminho do arquivo KEY que ser� criado 
@param cRet, Mensagem de retorno, em caso de erro

@author Pedro Alencar	
@since 15/01/2015
@version 12.1.3
/*/
Static Function ConvCertif( cArquivo, cPsw, cArqCA, cArqCERT, cArqKEY, cRet )	
	Local cError := ""
	Default cArquivo := ""
	Default cPsw := ""
	Default cArqCA := ""
	Default cArqCERT := ""
	Default cArqKEY := ""
	Default cRet := ""
	
	cArquivo := AllTrim( cArquivo )
	cPsw := AllTrim( cPsw )
	cArqCA := AllTrim( cArqCA )
	cArqCERT := AllTrim( cArqCERT )
	cArqKEY := AllTrim( cArqKEY )
	
	//Garante que os arquivos ser�o gerados com a extens�o correta
	If Right( Upper( cArqCA ), 4 ) != ".PEM"
		cArqCA += ".pem"
	Endif
	If Right( Upper( cArqCERT ), 4 ) != ".PEM"
		cArqCERT += ".pem"
	Endif
	If Right( Upper( cArqKEY ), 4 ) != ".PEM"
		cArqKEY += ".pem"
	Endif
	
	//Gera o arquivo de Certificado de Autoriza��o
	If PFXCA2PEM( cArquivo, cArqCA, @cError, cPsw )
		//Gera o arquivo de Certificado de Cliente
		If PFXCert2PEM( cArquivo, cArqCERT, @cError, cPsw )
			//Gera o arquivo de Chave Privada
			If ! PFXKey2PEM( cArquivo, cArqKEY, @cError, cPsw )
				cRet := OemToAnsi(STR0026) + cError //"Erro ao extrair a chave privada. "
			Endif
		Else
			cRet := OemToAnsi(STR0027) + cError //"Erro ao extrair o Certificado de Cliente. "
		Endif
	Else
		cRet := OemToAnsi(STR0028) + cError //"Erro ao extrair o Certificado de Autoriza��o. "
	Endif	
	
Return .T.