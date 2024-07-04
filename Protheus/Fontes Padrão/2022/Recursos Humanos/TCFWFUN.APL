#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCFWFUN.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "TCFWDEF.CH"
 
/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Programa  ³TCFWFUN   ³ Autor ³ Marinaldo de Jesus	       ³ Data ³04/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Web Functions do Terminal de Consulta de Funcionarios            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Void>                                                           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³ Gen‚rico                                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                     ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.      ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Programador ³ Data   ³ BOPS      ³  Motivo da Alteracao                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Ricardo D.  ³05/05/05³FN1783     ³Ajuste em TCFWUPDPSW() na gravacao da     ³
³            ³        ³/2005      ³senha alterada pelo funcionario.          ³ 
³Emerson G.R.³26/07/05³082069     ³Nao permit.acesso a opcoes desabil.no menu³
³            ³        ³	          ³mesmo qdo.acessadas diretamente p/Browser.³
³Ricardo D.  ³14/10/05³FN3234     ³Retirar o teste de opcoes desabil.no menu ³
³            ³        ³/2005      ³p/a funcao TCFWESPELHO.                   ³
³Kelly       ³15/02/08³140980     ³Ajuste para utilizacao de verbas de em-   ³
³            ³        ³           ³presas diferentes no recibo de pagto.     ³
³Marcelo     ³16/06/08³146179     ³Ajuste na funcao TCFW013 para priorizar o ³
³            ³        ³           ³uso do rdmake recibo no RHOnLine caso ele ³
³            ³        ³           ³esteja compilado no RPO.                  ³
³Jonatas     ³26/11/08³007427/2008³Ajuste na funcao TCFW013 para utilizar o  ³
³            ³        ³           ³rdmake RECIBO.PRX somente se habilitado   ³
³            ³        ³           ³via parametro MV_TCFDEMO.                 ³
³Renata      ³26/01/09³142201/2008³Ajuste na funcao TCFW016 e TCFWIR016 para,³
³            ³        ³           ³de acordo com os dados informados, paginar³
³            ³        ³           ³nos informes o nome do Responsavel de     ³
³            ³        ³           ³acordo com a empresa\filial do usuario.   ³
³Renata      ³03/03/09³005130/2009³Ajuste na funcao TCFWIR016, no ano da data³
³            ³        ³           ³para visualizacao dos informes.		     ³
³Leandro Dr. ³17/04/09³008118/2009³Tratamento do parametro MV_TCF013A, usado ³
³            ³        ³           ³para restringir as opcoes do demonstrativo³
³            ³        ³           ³de pagamento.                             ³
³Luciana   . ³01/09/09³020084/2009³Inclusao dos campos valor de saque e saldo³
³            ³        ³           ³real na consulta de extrato do FGTS       ³
³Allyson M.  ³08/09/09³021321/2009³Ajuste em TCFW010() para nao complementar ³
³            ³        ³           ³informacao do campo quando o mesmo estiver³
³            ³        ³           ³vazio na tabela SRA                       ³
³Mauricio MR ³26/11/09³00000027196³Criada uma nova categoria para reconhecer ³
³            ³        ³/2009      ³funcoes Web de usuario com o prefixo "B_" ³
³Alex        ³29/01/10³00000025836³ Adaptação Gestão Corporativa, controles: ³
³            ³        ³       2009³ Grupo de campos de filial.               ³
³Mauricio MR ³21/06/10³00000013667³Realizado ajuste para permitir acessar    ³
³            ³        ³/2010      ³mais de uma empresa/funcao sem perda de   ³
³            ³        ³           ³conexao.                                  ³
³Allyson M   ³19/05/11³0000011915/³Ajuste para buscar o arquivo GRHPER.FCH   ³
³            ³--------³       2011³da empresa do funcionario. 				 ³
³Allyson M   ³07/11/11³0000028555/³Ajuste para reinicializar tabela RBC -    ³
³            ³--------³       2011³configuracao de menus.	 				 ³
³Leandro Dr. ³15/03/12³     TEPWXC³Ajuste na montagem da URL do frame.       ³
³Allyson M   ³27/07/12³ 19042/2012³Ajuste para permitir o acesso a funciona- ³
³            ³        ³     TFLDMT³rios transferidos.   					 ³
³Luis Artuso ³15/10/12³025208/2012³Ajuste para verificar a data de acesso ao ³
³            ³        ³     TFVQMG³portal, para funcionarios demitidos.		 ³
³Luis Artuso ³19/10/12³025855/2012³Ajuste para nao permitir funcionarios de- ³
³            ³        ³     TFXHER³mitidos consultem o portal ao clicar no   ³
³            ³        ³           ³botao 'voltar' do navegador.              ³
³Claudinei S.³21/03/13³006696/2013³Ajuste para buscar o arquivo GRHPER.FCH da³
³            ³        ³     TGXGO6³filial caso MV_TCFFIL esteja .T.          ³
³Fabio G.    ³28/03/13³		TGWDR8³Ajuste p/ Liberar acesso Portal RhOnline  ³
³            ³        ³     	  ³para funcionario demitidos caso o param.  ³
³            ³        ³     	  ³MV_TCFVREN estaja habilitado com S.       ³
³Gustavo M.  ³16/05/13³		THCXCH³Ajuste na exibicao do Informe de Rendiment³
³            ³        ³     	  ³caso utilizado o parametro MV_TCFVREN.    ³
³Allyson M.	 ³22/05/13³     THFJCK³Ajuste na utilizacao das tabelas XX8 e XX9³
³Allyson M.	 ³14/08/13³     THPPUX³Ajuste p/ nao perder os dados de login ao ³
³            ³        ³     	  ³executar a rotina de alterao de senha.    ³
³Gustavo M.	 ³10/01/13³     TIBVTY³Ajuste para utilizar o param MV_TCFVREN 	 ³
³            ³        ³     	  ³apenas em func. demitidos.			     ³
³Matheus M.	 ³15/12/15³     TTTSGK³Ajuste para imprimir o logo utilizado     ³
³            ³        ³     	  ³corretamente no portal GCH.		         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 

ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW001  	³Autor ³ Marinaldo de Jesus   ³ Data ³04/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Index do Terminal de Consulta                               ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW001()													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Terminal de Consulta                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW001()

Local cHtml
Local nHandle
Local cFileMsg	    := "TCFEMP.MSG"

Private aEmpresas   := GetEmpSigaMat()
Private cMatInic	:= ""
Private nTamLogin   := 0
Private aMsgEmp	    := {}

HttpFreeSession()

TCF INIT cHtml

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada p/ Alterar conteudo da variavel cMatInc	  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("TCFSTRLOGIN")
		ExecBlock("TCFSTRLOGIN",.F.,.F.)
	Else
		cMatInic := STR0045	//"Matr&iacute;cula" 
		nTamLogin:= TamSx3("RA_MAT")[1]
	Endif

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Carrega variavel com o Conteudo do arquivo de Informacoes   da³
	³empresa que sera mostrado no RH OnLine a Todos os Funcionarios³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	nHandle := fOpen( cFileMsg )
	aMsgEmp := GetAllTxtFile( nHandle )
	fClose( nHandle )

 	cHtml := H_TCFH004()

TCF END cHtml

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFWINIT  	³Autor ³ Marinaldo de Jesus   ³ Data ³25/08/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Init do Terminal de Consultas							    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW001()													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Terminal de Consulta                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFWINIT()

Local cHtml

HttpFreeSession()
TCF INIT cHtml

	cHtml := W_TCFW001()

TCF END cHtml

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW002 	³Autor ³ Marinaldo de Jesus   ³ Data ³04/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³iFrame com o Logo da Empresa/Foto e Nome do Funcionario     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW002()                             					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW002()

Local cHtml := ""

Private cNomeFun
Private lShowFoto

WEB EXTENDED INIT cHtml START "TCFWInSite"

	TCF INIT cHtml

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define o Modulo em Uso                          					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		SetModulo( "SIGAGPE" , "GPE" )
	
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Posiciona no Funcionario                     				   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		SRA->( dbSetOrder( RetOrdem("SRA") ) )
		SRA->( MsSeek( xFilial( "SRA" , TCFWGetFil() ) + TCFWGetMat() ) )
		
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Carrega no Nome do Funcionario               				   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		cNomeFun := Capital( AllTrim( SRA->RA_NOME ) )
	
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Carrega a Foto do Funcionario								   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		HttpSession->cBmpPict := RetPictFun( @lShowFoto )
		
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Carrega o Logo da Empresa/Filial							   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		HttpSession->cLogoEmp := RetLogoEmp()
	
		cHtml += H_TCFH002()

	TCF END cHtml
	
WEB EXTENDED END

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³RetPictFun	³Autor ³ Marinaldo de Jesus   ³ Data ³19/09/2003³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Retornar a Foto do Funcionario                              ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>               					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>               					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³Foto do Funcionario                							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RhOnLine                                                    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function RetPictFun( lShowFoto )

Local cBmpPict

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carrega a Foto do Funcionario								   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
IF !Empty( cBmpPict := Upper( AllTrim( SRA->RA_BITMAP ) ) )

	lShowFoto	:= .T.
	cBmpPict	:= "W_TCFPictFun.apw?IdPictFun="+cBmpPict

Else

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Se nao Existir Foto Para o Funcionario Carrega Imagem padrao ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	lShowFoto	:= .F.
	cBmpPict	:= ( TcfRetDirImg()+"/foto.gif" )

EndIF

Return( cBmpPict )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFPictFun	  ³ Autor ³Marinaldo de Jesus ³ Data ³25/03/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Chamada via http , recebe via URL o parametro ID, contendo o³
³          ³codigo da foto do funcionario. Retorna a Imagem 			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFPictFun()

Local cIMGCode 		:= HttpGet->IdPictFun
Local cIMGSource 	:= ""

Begin Sequence

	IF Empty( cIMGCode )
		Break
	EndIF

	// Carrega a imagem do repositorio em variavel de memoria
	cIMGSource := LoadReposit( cIMGCode )
	FechaReposit() //For‡o o Fechamento o Repositorio de Imangens

	IF ( Len( cIMGSource ) == 0 )
		Break
	EndIF
	
	IF ( Left( cIMGSource , 2 ) == "BM" )
		// Identifica se é BMP ou JPG pelos 2 primeiros bytes
		HttpCTType( "application/xbitmap" )
	Else
		// Se não for BMP ... é JPG ! 
		HttpCTType( "image/jpeg" )
	EndIF
	
	// Seta tamanho da imagem para header HTTP de saida
	HttpCTLen( Len( cIMGSource ) )
		
	// Manda a imagem via HTTPSend 
	cIMGSource := HttpSend( cIMGSource )

End Sequence

// Caso a httpsend não envie toda a imagem , retorna 
// o conteudo remanescente.
Return( cIMGSource )

/*/{Protheus.doc} RetLogoEmp
Retornar no Logo da Empresa de acordo com o grupo de empresas e filial passados
@author  Marinaldo de Jesus
@since   19/09/2003
/*/
Function RetLogoEmp(lPortal, EmpPortal, FilPortal, cNome, lGPER030 )
	
	Local cLogoEmp
	Local cExtension
	Local lShowLogo  	:= .F.
	Local lShowLogo2	:= .F.
	
	Default cNome 		:= "LGRO"
	Default lPortal 	:= .F.
	Default EmpPortal 	:= cEmpAnt
	Default FilPortal	:= cFilAnt
	Default lGPER030	:= .F.
	
	If lPortal
		cNome := "LGRECIBO"
	Endif
	
	Begin Sequence
		
		// Carrega o Logo da Empresa/Filial
		cLogoEmp 	:= ( cNome + EmpPortal + FilPortal )
		
		// Procuro Primeiro pelo Tipo JPG
		cExtension	:= ".JPG"
		IF !lGPER030 .And. (lShowLogo := File( cLogoEmp + cExtension ))
			Break
		EndIF
		
		IF !lGPER030 .And. (lShowLogo2 := File( rTrim(cLogoEmp) + cExtension ))
			Break
		EndIF	
		
		// Se nao encontrei JPG, Procuro BMP
		cExtension	:= ".BMP"
		IF ( lShowLogo := File( cLogoEmp + cExtension ) )
			Break
		EndIF
		
		IF ( lShowLogo2 := File( rTrim(cLogoEmp) + cExtension ) )
			Break
		EndIF
		
		// Carrega o Logo da Empresa
		cLogoEmp := ( cNome + EmpPortal )
		
		// Procuro Primeiro pelo Tipo JPG
		cExtension	:= ".JPG"
		IF !lGPER030 .And.  (lShowLogo := File( cLogoEmp + cExtension ) )
			Break
		EndIF
		
		IF !lGPER030 .And.  (lShowLogo2 := File( rTrim(cLogoEmp) + cExtension ) )
			Break
		EndIF
		
		// Se nao encontrei JPG, Procuro BMP
		cExtension	:= ".BMP"
		IF ( lShowLogo := File( cLogoEmp + cExtension ) )
			Break
		EndIF
		
		IF ( lShowLogo2 := File( rTrim(cLogoEmp) + cExtension ) )
			Break
		EndIF
		
		// Carrega Logo Generico
		If lPortal
			cLogoEmp := "Logo"
		Else
			cLogoEmp := "LGRO"
		EndIf
		
		// Procuro Primeiro pelo Tipo JPG
		cExtension	:= ".JPG"
		IF !lGPER030 .And. (lShowLogo := File( cLogoEmp + ".JPG" ) )
			Break
		EndIF
		
		// Se nao encontrei JPG, Procuro BMP
		cExtension	:= ".BMP"
		IF ( lShowLogo := File( cLogoEmp + cExtension ) )
			Break
		EndIF
		
		// Carrego o Logo Padrao
		cExtension	:= ".JPG"
		cLogoEmp	:= ( TcfRetDirImg() + "/" + cLogoEmp + cExtension )
		
	End Sequence
	
	IF lShowLogo .And. ! lGPER030
		cLogoEmp := "W_TCFLogoEmp.apw?IdLogoEmp=" + ( cLogoEmp + cExtension )
	ElseIf lShowLogo2 .And. ! lGPER030
		cLogoEmp := "W_TCFLogoEmp.apw?IdLogoEmp=" + ( rTrim(cLogoEmp) + cExtension )
	ElseIf lShowLogo .And. lGPER030
		cLogoEmp := cLogoEmp + cExtension
	ElseIf lShowLogo2 .And. lGPER030
		cLogoEmp := rTrim(cLogoEmp) + cExtension
	EndIF
	
Return( cLogoEmp )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³W_TCFLogoEmp  ³ Autor ³Marinaldo de Jesus ³ Data ³25/08/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Chamada via http , recebe via URL o parametro ID, contendo o³
³          ³nome do arquivo do Logo. Retorna a Imagem 					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFLogoEmp()

Local cLogoFile		:= HttpGet->IdLogoEmp
Local cLogoSource 	:= ""

Local nLenLogoSource

Begin Sequence

	IF Empty( cLogoFile )
		Break
	EndIF

	// Carrega a imagem do repositorio em variavel de memoria
	cLogoSource := TCFLoadLogo( cLogoFile )

	nLenLogoSource := Len( cLogoSource )
	IF ( nLenLogoSource == 0 )
		Break	//Não Tem Imagem alguma a enviar
	EndIF
	
	IF ( Left( cLogoSource , 2 ) == "BM" )
		// Identifica se é BMP ou JPG pelos 2 primeiros bytes
		HttpCTType( "application/xbitmap" )
	Else
		// Se não for BMP ... é JPG ! 
		HttpCTType( "image/jpeg" )
	EndIF
	
	// Seta tamanho da imagem para header HTTP de saida
	HttpCTLen( nLenLogoSource )
		
	// Manda a imagem via HTTPSend 
	cLogoSource := HttpSend( cLogoSource )

End Sequence

// Caso a httpsend não envie toda a imagem , retorna 
// o conteudo remanescente.
Return( cLogoSource )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFLoadLogo	³Autor ³ Marinaldo de Jesus   ³ Data ³25/08/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Obtem o Binario com os dados do Logo da Empresa             ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<vide parametros formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Terminal de Consulta                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function TCFLoadLogo( cLogoFile )

Local nHandle 		:= fOpen( cLogoFile )
Local aAllLogoFile	:= GetAllTxtFile( nHandle )
Local cBinaryFile	:= ""

Local nLoop
Local nLoops

nLoops := Len( aAllLogoFile )
For nLoop := 1 To nLoops
	cBinaryFile += aAllLogoFile[ nLoop ]
Next nLoop
fClose( nHandle )

Return( cBinaryFile )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW003		³Autor ³ Marinaldo de Jesus   ³ Data ³04/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Index do Terminal de Consulta                               ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW003()													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Terminal de Consulta                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW003()

Local cHtml

TCF INIT cHtml

	cHtml := H_TCFH003()

TCF END cHtml

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW004		³Autor ³ Marinaldo de Jesus   ³ Data ³04/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Tela de Entrada do Terminal de Consultas                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW004()													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Terminal de Consulta                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW004()

Local	cHtml
Private aEmpresas := GetEmpSigaMat()
Private cMatInic	:= ""
Private nTamLogin   := 0

HttpFreeSession()

TCF INIT cHtml

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada p/ Alterar conteudo da variavel cMatInc	  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("TCFSTRLOGIN")
		ExecBlock("TCFSTRLOGIN",.F.,.F.)
	Else
		cMatInic := STR0045	//"Matr&iacute;cula" 
		nTamLogin:= TamSx3("RA_MAT")[1]
	Endif

 	cHtml := ExecInPage("TCFH004")// H_TCFH004()

TCF END cHtml

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW005		³Autor ³ Marinaldo de Jesus   ³ Data ³04/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³iFrame do Terminal de Consultas								³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW005()													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Terminal de Consulta                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW005()

	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "TCFWInSite"
	
		TCF INIT cHtml
	                   
			cHtml += H_TCFH005()
		
		TCF END cHtml	
	
	WEB EXTENDED END

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW006		³Autor ³ Marinaldo de Jesus   ³ Data ³04/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³iFrame de Informacoes do Funcionario para Terminal de Consul³
³          ³tas														    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW006()	                            					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW006()

Local cHtml 	:= ""

Local cMsgFun
Local cFileMsg
Local nHandle

Private aMsgFun		:= {}

WEB EXTENDED INIT cHtml START "TCFWInSite"

	TCF INIT cHtml

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define o Modulo em Uso                          					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		SetModulo( "SIGAGPE" , "GPE" )
	
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Posiciona no Funcionario                     				   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		SRA->( dbSetOrder( RetOrdem("SRA") ) )
		SRA->( MsSeek( xFilial( "SRA" , TCFWGetFil() ) + TCFWGetMat() ) )
	
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Carrega a Mensagem Para o Funcionario						   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		IF Empty( cMsgFun := MsMm(SRA->RA_TCFMSG) )
			aAdd( aMsgFun , "<center><b>" + STR0035 + "</b></center>" ) //"Bem Vindo ao RH OnLine"
		Else
			cFileMsg := ( CriaTrab( NIL , .F. ) + ".MSG" )
			MemoWrite( cFileMsg , cMsgFun )
			nHandle := fOpen( cFileMsg )
			aMsgFun := GetAllTxtFile( nHandle )
			fClose( nHandle )
			fErase( cFileMsg )
		EndIF	
		
		cHtml += H_TCFH006()

	TCF END cHtml
	
WEB EXTENDED END

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW007    	³Autor ³ Marinaldo de Jesus   ³ Data ³04/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³iFrame de Menu de Opcoes do Terminal de Consultas           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW007()                                					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW007()

Local aUnique		:= { "RBC_FILIAL" , "RBC_CODMNU" }
Local cFilRBC		:= ""
Local cRotina		:= ""
Local cDescri		:= ""
Local cHtml 		:= ""

Private aMenuTcf	:= {}

WEB EXTENDED INIT cHtml START "TCFWInSite"

	TCF INIT cHtml

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define o Modulo em Uso                          					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		SetModulo( "SIGAGPE" , "GPE" )
	
		//-- Reinicializa a variavel statica do POSALIAS
		//-- Util na troca de empresas ...
		fSrvStatic()
		RstPosAlias("RBC")
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Posiciona no Menu conforme Filial            				   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		RBC->( MsSeek( ( cFilRBC := xFilial("RBC") ) ) )
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Carrega o Array aMenuTcf com Informacoes para a Montagem   do³
		³ Menu do RH OnLine											   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		While RBC->( !Eof() .and. ( RBC_FILIAL == cFilRBC ) )
			
			IF RBC->( UniqueKey( aUnique ) )
				aAdd( aMenuTcf , {} )
			EndIF
					
			IF ( RBC->RBC_STATUS == "A" )
				
				IF !Empty( cRotina := AllTrim(RBC->RBC_ROTINA) )
					IF FindFunction( "w_"+cRotina )
						/*/
						ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³ Web Functions w_?	ou W_?									   ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
						cRotina := "w_"+cRotina+".APW"
					ElseIF FindFunction( "l_"+cRotina )
						/*/
						ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³ UserHtml Functions l_? ou L_?								   ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
						cRotina := "l_"+cRotina+".APW"
					ElseIF FindFunction( "h_"+cRotina )
						/*/
						ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³ Html Functions h_? ou H_?								   	   ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
						cRotina := "h_"+cRotina+".APW"
					ElseIF FindFunction( ALLTRIM(UPPER("B_"+cRotina)) )
						/*/
						ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³ Web User Functions b_? 								   	   ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
						cRotina := "B_"+cRotina+".APW"						
					Else
						//"Fun&ccedil;&atilde;o n&atilde;o encontrada no Reposit&oacute;rio"
						//"Existem inconsist&ecirc;ncias a serem verificadas:"
						cRotina := "w_TCFNoFunction.APW?NoFunction="+cRotina
					EndIF	
				Else
					cRotina := "#"
				EndIF
				
				cDescri := Capital( AllTrim( RBC->RBC_DESCRI ) )
					
				If Len( aMenuTcf ) > 0
					aAdd( aMenuTcf[Len( aMenuTcf ) ],	{; 
									  						cDescri ,; //Descricao do Menu
															cRotina	 ; //Programa a Ser Executado
									 					};
						   )
				EndIf				
			EndIF
			
			RBC->( dbSkip() )
		
		End While
		
		cHtml += H_TCFH007()

	TCF END cHtml	
			
WEB EXTENDED END

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW008   	³Autor ³ Marinaldo de Jesus   ³ Data ³11/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Opcoes do Espelho de Ponto Para o Terminal de Consulta      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW008()													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Terminal de Consulta                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW008()

Local cHtml			:= ""

Private aPeriodos	:= {}

WEB EXTENDED INIT cHtml START "TCFWInSite"

	TCF INIT cHtml
 
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Opcao habilitada Configurador de Menu          					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		If TcfChkMenu()
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Define o Modulo em Uso                          					 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SetModulo( "SIGAPON" , "PON" )
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Inicializa as Static do SIGAPON                 					 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			PonDestroyStatic()
		 
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Posiciona no Funcionario                     				   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SRA->( dbSetOrder( RetOrdem("SRA") ) )
			SRA->( MsSeek( xFilial( "SRA" , TCFWGetFil() ) + TCFWGetMat() ) )
			
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Retorna os Periodos de Apontamento Validos prara o Funcionario³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			aPeriodos := {}
			SPO->(DbGoTop())
			IF !Empty( aPeriodos := GetPerAponta( GetMv("MV_TCFMARC",,12) , TCFWGetFil() , TCFWGetMat() , .F. , NIL , NIL , RetPerSPO( TCFWGetFil() ) ) )
				cHtml += H_TCFH008()
			Else
				//"Consultar Marca&ccedil;&otilde;es"###"N&atilde;o existem marca&ccedil;&otilde;es neste per&iacute;odo" 
				cHtml += HtmlDefault( STR0020 , STR0009 ) 
			EndIF

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Opcao nao habilitada Configurador de Menu        					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		Else
			//"Consultar Marca&ccedil;&otilde;es"###"Opção não está habilitada no menu do Terminal de Consultas"
			cHtml += HtmlDefault( STR0020 , STR0041 ) 
		EndIf	
		
	TCF END cHtml
	
WEB EXTENDED END

Return( cHtml )

Web Function TCFWEspelho()

Local cHtml			:= ""

WEB EXTENDED INIT cHtml START "TCFWInSite"

	TCF INIT cHtml

			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Define o Modulo em Uso                          					 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SetModulo( "SIGAPON" , "PON" )
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Inicializa as Static do SIGAPON                 					 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			PonDestroyStatic()
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Posiciona no Funcionario                     				   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SRA->( dbSetOrder( RetOrdem("SRA") ) )
			SRA->( MsSeek( xFilial( "SRA" , TCFWGetFil() ) + TCFWGetMat() ) )
			
			If ExistBlock("IMPESP")
				IF EmptyHtml( cHtml += u_IMPESP( .T. , TCFWGetFil() , TCFWGetMat() , HttpPost->cPerAponta ) )
					//"Consultar Marca&ccedil;&otilde;es"###"N&atilde;o existem marca&ccedil;&otilde;es neste per&iacute;odo"
					cHtml += HtmlDefault( STR0020 , STR0009 ) 
				EndIF			
			Else
				/*/
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Chama o Ponr010 para gerar o Codigo HTML correspondente ao  Es³
				³pelho de Ponto												   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
				IF EmptyHtml( cHtml += Ponr010( .T. , TCFWGetFil() , TCFWGetMat() , HttpPost->cPerAponta ) )
					//"Consultar Marca&ccedil;&otilde;es"###"N&atilde;o existem marca&ccedil;&otilde;es neste per&iacute;odo"
					cHtml += HtmlDefault( STR0020 , STR0009 ) 
				EndIF
			EndIf

	TCF END cHtml
			
WEB EXTENDED END

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW009   	³Autor ³ Marinaldo de Jesus   ³ Data ³04/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³iFrame com os Dados do Rodape do Terminal de Consultas      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW009()	                            					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW009()

Local cHtml

TCF INIT cHtml

	cHtml := H_TCFH009()

TCF END cHtml

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW010		³Autor ³ Marinaldo de Jesus   ³ Data ³04/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Informacoes do Cadastro de Funcionarios (Consulta)          ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW010()	                            					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW010()

Local aDicFch		:= {}
Local aDicion		:= {}
Local cFile			:= If( SuperGetMv("MV_TCFFIL",, .F., )== .T., "GRHPER" + cEmpAnt + cFilAnt + ".FCH", "GRHPER" + cEmpAnt + ".FCH")
Local cBuffer		:= ""
Local cConteudo		:= ""
Local cHtml			:= ""
Local cPict			:= ""
Local cXF3			:= "XM0"
Local cTCFCxFx		:= SuperGetMv("MV_TCFCXFX",,'')
Local lCapital		:= .T.
Local nHdl			:= 0
Local nDicion		:= 0
Local nForDicion	:= 0
Local nTamArq		:= 0
Local uVar			
Local uVarAux 

Private aFunc := {}

WEB EXTENDED INIT cHtml START "TCFWInSite"

	TCF INIT cHtml
	
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Opcao habilitada Configurador de Menu          					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		If TcfChkMenu()
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Define o Modulo em Uso                          					 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SetModulo( "SIGAGPE" , "GPE" )
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Monta Array com as Informacoes do Funcionario a Ser   Mostrado³
			³no Terminal de Consultas									   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			IF File( cFile )
			
				nHdl := fOpen(cfile,64)
				fSeek(nHdl,0,0)
				nTamArq := fSeek(nHdl,0,2)
				fSeek(nHdl,0,0)
				nForDicion := ( nTamArq / 63 )
			
				For nDicion := 1 To nForDicion
					cBuffer := Space(63)
					fRead(nHdl,@cBuffer,63)
					aAdd(aDicFch,cBuffer)
				Next nDicion
			
				fClose(nHdl)
			
				aEval( aDicFch ,{ |x| IF(SubStr(x,32,1) == "X" ,aAdd(aDicion,{SubStr(x,04,12),SubStr(x,44,10),"","",""}),"")})
				
				IF ( ( nForDicion := Len( aDicion ) ) > 0 )
			
					// Alimenta o aDicion com os dados do X3_F3
					SX3->( dbSetOrder(2) )
			
					For nDicion := 1 To nForDicion
						IF SX3->( MsSeek( aDicion[nDicion,2] ) )
							aDicion[ nDicion , 3 ] := SX3->( IF( Empty( X3_F3 ) , ( IF ( !Empty( X3_CBOX ) , "CBOX" ,"" ) ) , IF( SubStr( X3_F3 , 1 , 1 ) == "X" .and. !( AllTrim( Upper( X3_F3 ) ) $ cXF3 ) , "SRX" , "F3" ) ) )
							aDicion[ nDicion , 4 ] := SX3->X3_PICTURE
							aDicion[ nDicion , 5 ] := SX3->X3_F3
						EndIF	
					Next nDicion                  
			
					SX3->( dbSetOrder(1) )
		
					/*/
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³ Posiciona no Funcionario                     				   ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
					SRA->( dbSetOrder( RetOrdem("SRA") ) )
					IF SRA->( MsSeek( xFilial( "SRA" , TCFWGetFil() ) + TCFWGetMat() ) )
						// Preencher os campos do SRA conforme as tabelas ou arquivos
						For nDicion := 1 To nForDicion
							cPict	:= ""
							uVarAux	:= ""
							uVar	:= SRA->( &( aDicion[ nDicion , 2 ] ) )
							IF !Empty(uVar) .And. !Empty( aDicion[ nDicion , 3 ] )
								uVarAux := TcfTabela( TCFWGetFil() , aDicion[ nDicion , 3 ] , AllToChar( uVar ) , aDicion[ nDicion , 2 ] , aDicion[ nDicion , 5 ] , @cPict )
							EndIF
							uVar := AllToChar( uVar , aDicion[ nDicion , 4 ] )
							IF !Empty( uVarAux )
								uVar += ( " - " +  AllToChar( uVarAux , cPict ) )
							EndIF	
							If AllTrim(aDicion[ nDicion , 2 ]) $ cTCFCxFx .or. cTCFCxFx == '*'
								lCapital := .F.
							Else
								lCapital := .T.
							EndIf
							aAdd( aFunc , { ( SubStr( aDicion[ nDicion , 1 ] , 01 , 12 ) + ":" ) , uVar , lCapital } )
						Next nDicion
					EndIF	
			
					cHtml += H_TCFH010()
			
				Else
			
					//"Consultar Dados Cadastrais""###"Falta definir os campos do Cadastro de Funcionarios""
					cHtml += HtmlDefault( STR0021 , STR0004 )
			
				EndIF
			
			Else
				 //"Consultar Dados Cadastrais""###"Falta definir os campos do Cadastro de Funcionarios""
				cHtml += HtmlDefault( STR0021 , STR0004 )
			EndIF
        
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Opcao nao habilitada Configurador de Menu        					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		Else
			//"Consultar Dados Cadastrais""###"Opção não está habilitada no menu do Terminal de Consultas"
			cHtml += HtmlDefault( STR0021 , STR0041 ) 
		EndIf	
		
	TCF END cHtml
	
WEB EXTENDED END

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW011    	³Autor ³ Marinaldo de Jesus   ³ Data ³04/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Informacoes de Ferias do Funcionario (Consulta)           	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW011()                                					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW011()

Local cHtml				:= ""
Local dIniAquisFerias	:= Ctod("//")
Local dFimAquisFerias	:= Ctod("//")
Local dIniIdealFerias	:= Ctod("//")
Local dFimIdealFerias	:= Ctod("//")

Private aFerias:= {}

WEB EXTENDED INIT cHtml START "TCFWInSite"

	TCF INIT cHtml
            
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Opcao habilitada Configurador de Menu          					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		If TcfChkMenu()
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Define o Modulo em Uso                          					 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SetModulo( "SIGAGPE" , "GPE" )
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Posiciona no Funcionario                     				   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SRF->( dbSetOrder( RetOrdem("SRF") ) )
			IF SRF->( MsSeek( xFilial( "SRF" , TCFWGetFil() ) + TCFWGetMat() ) )
			
				/*/
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Monta Array com as Informacoes de Ferias do Funcionario       ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
				While SRF->( !Eof() .and. ( RF_FILIAL + RF_MAT ) == ( TCFWGetFil() + TCFWGetMat() ) )
			
					dIniAquisFerias := SRF->RF_DATABAS
					dFimAquisFerias := fCalcFimAq( dIniAquisFerias )
					dIniIdealFerias := dFimAquisFerias + 30
					dFimIdealFerias := ( fCalcFimAq( dFimAquisFerias + 1 ) - 45 )
			
					SRF->(;
							 aAdd(	aFerias,	{;
													Dtoc( dIniAquisFerias ),;									//Data Base
													AllTrim( Str( RF_DFERVAT - RF_DFERANT ) ) ,;				//Dias de Ferias Vencidas
													AllTrim( Str( RF_DFERAAT ) ) ,;								//Dias de Ferias Proporcionais		
													Dtoc(dIniIdealFerias) + " a " + Dtoc(dFimIdealFerias),;	//Periodo para Gozo
													Dtoc(SRF->RF_DATAINI),;										//Data Inicial das Ferias
													Str(SRF->RF_DFEPRO1),;										//Dias de Ferias Programadas
													Str(SRF->RF_DABPRO1);										//Dias de Abonos Programados
												};
								   );
						  )		   	
					
					/*/
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Se Tiver Gozo de Ferias Dividido em mais de um Periodo        ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
					IF !Empty( SRF->RF_DATINI2 )
						SRF->( aAdd(aFerias,{"","","","",Dtoc(RF_DATINI2),AllTrim( Str(RF_DFEPRO2) ), AllTrim( Str(RF_DABPRO2))}) )
					EndIF
					
					IF !Empty( SRF->RF_DATINI3 ) 
						SRF->( aAdd(aFerias,{"","","","",Dtoc(RF_DATINI3),AllTrim( Str(RF_DFEPRO3) ), AllTrim( Str(RF_DABPRO3))}) )
					EndIF
					
					SRF->( dbSkip() )
			
				End While
			
				cHtml += H_TCFH011()
			
			Else
			
				//"Consultar Dados de F&eacute;rias"###"N&atilde;o h&aacute; dados de F&eacute;rias a serem visualizados"
				cHtml += HtmlDefault( STR0005 , STR0002 ) 
			
			EndIF

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Opcao nao habilitada Configurador de Menu        					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		Else
			//"Consultar Dados de F&eacute;rias"###"Opção não está habilitada no menu do Terminal de Consultas"
			cHtml += HtmlDefault( STR0005 , STR0041 ) 
		EndIf	
			
	TCF END cHtml
	
WEB EXTENDED END

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW012		³Autor ³ Marinaldo de Jesus   ³ Data ³11/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Informacoes de FGTS do Funcionario (Consulta)           	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW011()	                                				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW012()

Local cHtml	  := ""

Private aFgts := {}

WEB EXTENDED INIT cHtml START "TCFWInSite"

	TCF INIT cHtml
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Opcao habilitada Configurador de Menu          					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		If TcfChkMenu()
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Define o Modulo em Uso                          					 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SetModulo( "SIGAGPE" , "GPE" )
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Posiciona no Funcionario                     				   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SRS->( dbSetOrder( RetOrdem("SRS") ) )
			IF SRS->( MsSeek( xFilial( "SRS" , TCFWGetFil() ) + TCFWGetMat() ) )
		
				/*/
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Monta Array com as Informacoes de FGTS do Funcionario         ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
				While SRS->( !Eof() .and. ( RS_FILIAL + RS_MAT ) == ( TCFWGetFil() + TCFWGetMat() ) )
			
					SRS->( aAdd(aFgts,	{; 
											( RS_MES + "/" + RS_ANO ),;
											Transform(RS_SALANT,"@E 999,999,999.99"),;
											Transform(RS_PERJUR,"@E 99.99"),;
											Transform(RS_VALJUR,"@E 999,999,999.99"),;
											Transform(RS_VALDEP,"@E 999,999,999.99"),; 
											Transform(RS_VALSAQ,"@E 999,999,999.99"),; 
											Transform(RS_SALATU,"@E 999,999,999.99"),;
											Transform(RS_SALREAL,"@E 999,999,999.99");
										 };
								);
						  )
			
					SRS->( dbSkip() )
			
				End While
			
				/*/
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Ordena o Array aFgts em Ordem Decrescente de Data             ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
				IF !Empty( aFgts )
					aSort( aFgts ,,, { |x,y| SubStr(x[1],-4)+SubStr(x[1],1,2) > SubStr(y[1],-4)+SubStr(y[1],1,2) } )
				EndIF
			
				cHtml += H_TCFH012()
			
			Else
			
				 //"Consultar Dados de FGTS"###"N&atilde;o h&aacute; dados de FGTS a serem visualizados" 
				 cHtml += HtmlDefault( STR0022 , STR0001 )
			
			EndIF

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Opcao nao habilitada Configurador de Menu        					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		Else
			//"Consultar Dados de FGTS"###"Opção não está habilitada no menu do Terminal de Consultas"
			cHtml += HtmlDefault( STR0022 , STR0041 ) 
		EndIf	
		
	TCF END cHtml
	
WEB EXTENDED END

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW013   	³Autor ³ Marinaldo de Jesus   ³ Data ³11/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Tela de Opcoes do Demonstrativo de Pagammento do TCF        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW013()													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW013()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "TCFWInSite"

	TCF INIT cHtml
            
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Definie opcoes de impressao do demonstrativo de pagamento.
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		HttpSession->cOpcRec := SuperGetMv("MV_TCF013A",,"01.02.03.04.05")
		
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Opcao habilitada Configurador de Menu          					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		If TcfChkMenu()
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Define o Modulo em Uso                          					 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SetModulo( "SIGAGPE" , "GPE" )
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Posiciona no Funcionario                     				   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SRA->( dbSetOrder( RetOrdem("SRA") ) )
			SRA->( MsSeek( xFilial( "SRA" , TCFWGetFil() ) + TCFWGetMat() ) )
			
			cHtml += H_TCFH013()

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Opcao nao habilitada Configurador de Menu        					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		Else
			//"Demonstrativo de pagamento"###"Opção não está habilitada no menu do Terminal de Consultas"
			cHtml += HtmlDefault( STR0023 , STR0041 ) 
		EndIf	
		
	TCF END cHtml
	
WEB EXTENDED END
		
Return( cHtml )
		
Web Function TCFWShowDemo()
		
Local cHtml			:= ""
Local cSvHtml		:= ""
Local nRecnoSRA		:= 0
Local lRecibo		:= ( SuperGetMv("MV_TCFDEMO",,"2") == "1" ) // Define se utiliza o rdmake RECIBO.PRX na emissao do recibo de pagto.
		
WEB EXTENDED INIT cHtml START "TCFWInSite"

	TCF INIT cHtml

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define o Modulo em Uso                          					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		SetModulo( "SIGAGPE" , "GPE" )
	
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Posiciona no Funcionario                     				   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		SRA->( dbSetOrder( RetOrdem("SRA") ) )
		IF SRA->( MsSeek( xFilial( "SRA" , TCFWGetFil() ) + TCFWGetMat() ) )
		
			nRecnoSRA := SRA->( Recno() )
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Chama o Gper030 para gerar o Codigo HTML correspondente ao  De³
			³monstrativo de Pagamento									   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			cSvHtml := cHtml
			If lRecibo .And. ExistBlock("RECIBO") 
			
				IF EmptyHtml( cHtml += u_Recibo(.T.,TCFWGetFil(),TCFWGetMat(),StrZero(Val(HttpPost->cMes),2) + StrZero(Val(HttpPost->cAno),4),Val(HttpPost->cRecTipo),HttpPost->cSemana) )
					HttpPost->cSemana := StrZero( Val( HttpPost->cSemana ) , TamSx3( "RC_SEMANA" ) [1] )
					cHtml	:= cSvHtml
					SRA->( dbGoto( nRecnoSRA ) )
					IF EmptyHtml( cHtml += u_Recibo(.T.,TCFWGetFil(),TCFWGetMat(),StrZero(Val(HttpPost->cMes),2) + StrZero(Val(HttpPost->cAno),4),Val(HttpPost->cRecTipo),HttpPost->cSemana) )
						//"Demonstrativo de Pagamento" ###"N&atilde;o existem valores a serem visualizados"
						cHtml += HtmlDefault( STR0023 , STR0003 )
					EndIF
				EndIF			
			
			Else
			
				IF EmptyHtml( cHtml += Gper030(.T.,TCFWGetFil(),TCFWGetMat(),StrZero(Val(HttpPost->cMes),2) + StrZero(Val(HttpPost->cAno),4),Val(HttpPost->cRecTipo),HttpPost->cSemana) )
					HttpPost->cSemana := StrZero( Val( HttpPost->cSemana ) , TamSx3( "RC_SEMANA" ) [1] )
					cHtml	:= cSvHtml
					SRA->( dbGoto( nRecnoSRA ) )
					IF EmptyHtml( cHtml += Gper030(.T.,TCFWGetFil(),TCFWGetMat(),StrZero(Val(HttpPost->cMes),2) + StrZero(Val(HttpPost->cAno),4),Val(HttpPost->cRecTipo),HttpPost->cSemana) )
						//"Demonstrativo de Pagamento" ###"N&atilde;o existem valores a serem visualizados"
						cHtml += HtmlDefault( STR0023 , STR0003 )
					EndIF
				EndIF

			EndIF
		
		Else
	
			//"Demonstrativo de Pagamento" ###"N&atilde;o existem valores a serem visualizados"
			cHtml += HtmlDefault( STR0023 , STR0003 )
	
		EndIF	

	TCF END cHtml
	
WEB EXTENDED END

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW014   	³Autor ³ Marinaldo de Jesus   ³ Data ³11/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Tela de Cadastro/Alteracao de Senhas						³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW014()													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW014()

Local cHtml
Local cMatric	  := TCFWGetMat() 

Private aEmpresas := GetEmpSigaMat()

If ValType(cMatric) == "U"
	HttpFreeSession()
EndIf

TCF INIT cHtml

	cHtml := H_TCFH014()

TCF END cHtml	

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW015		³Autor ³ Marinaldo de Jesus   ³ Data ³17/12/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³iFrame de Informacoes Empresa no Terminal de Consultas      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW015()	                            					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW015()

Local cFileMsg	:= "TCFEMP.MSG"

Local cHtml
Local nHandle

Private aMsgEmp	:= {}

TCF INIT cHtml

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Carrega variavel com o Conteudo do arquivo de Informacoes   da³
	³empresa que sera mostrado no RH OnLine a Todos os Funcionarios³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	nHandle := fOpen( cFileMsg )
	IF (;
			!File( cFileMsg );
			.or.;
			Empty( aMsgEmp := GetAllTxtFile( nHandle ) ); 
		)	
		aAdd( aMsgEmp , "<center><b>" + STR0035 + "</b></center>" ) //"Bem Vindo ao RH OnLine"
	EndIF
	fClose( nHandle )
	
	cHtml := H_TCFH015()

TCF END cHtml
	
Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFPonQdHr	³Autor ³ Marinaldo de Jesus   ³ Data ³28/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Calendario de Marcacoes                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³w_TCFPonQdHr()												³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Terminal de Consulta                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFPonQdHr()

Local cHtml

WEB EXTENDED INIT cHtml START "TCFWInSite"

	TCF INIT cHtml
        
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Opcao habilitada Configurador de Menu          					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		If TcfChkMenu()
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Define o Modulo em Uso                          					 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SetModulo( "SIGAPON" , "PON" )
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Inicializa as Static do SIGAPON                 					 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			PonDestroyStatic()
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Posiciona no Funcionario                     				   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SRA->( dbSetOrder( RetOrdem("SRA") ) )
			SRA->( MsSeek( xFilial( "SRA" , TCFWGetFil() ) + TCFWGetMat() ) )
			
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Chama o u_PonQdHr para gerar o Codigo HTML correspondente   ao³
			³Quadro de Horario do Funcionario (Baseado no Calendario de Mar³
			³cacoes)													   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			IF EmptyHtml( cHtml := u_PonQdHr( .T. , TCFWGetFil() , TCFWGetMat() ) )
				//"Calend&aacute;rio de Marca&ccedil;&otilde;es"###"N&atilde;o existem informac&otilde;es de calend&aacute;rio a serem visualizadas"
				cHtml := HtmlDefault( STR0025 , STR0011 )
			EndIF

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Opcao nao habilitada Configurador de Menu        					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		Else
			//"Calend&aacute;rio de Marca&ccedil;&otilde;es"###"Opção não está habilitada no menu do Terminal de Consultas"
			cHtml += HtmlDefault( STR0025 , STR0041 ) 
		EndIf	
		
	TCF END cHtml
	
WEB EXTENDED END
		
Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFExtraBh	³Autor ³ Marinaldo de Jesus   ³ Data ³28/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Extrato do Banco de Horas                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³w_TCFExtraBh()												³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Terminal de Consulta                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFExtraBh()
                
Local cHtml

WEB EXTENDED INIT cHtml START "TCFWInSite"

	TCF INIT cHtml
        
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Opcao habilitada Configurador de Menu          					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		If TcfChkMenu()
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Define o Modulo em Uso                          					 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SetModulo( "SIGAPON" , "PON" )
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Inicializa as Static do SIGAPON                 					 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			PonDestroyStatic()
		
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Posiciona no Funcionario                     				   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			SRA->( dbSetOrder( RetOrdem("SRA") ) )
			SRA->( MsSeek( xFilial( "SRA" , TCFWGetFil() ) + TCFWGetMat() ) )
			
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Chama o u_ExtraBh para gerar o Codigo HTML correspondente   ao³
			³Extrato de Banco de Horas									   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			IF EmptyHtml( cHtml := u_ExtraBh( .T. , TCFWGetFil() , TCFWGetMat() ) )
				//"Banco de Horas" ###"N&atilde;o existem informac&otilde;es de Banco de Horas a serem visualizadas"
				cHtml := HtmlDefault( STR0024 , STR0010 )
			EndIF

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Opcao nao habilitada Configurador de Menu        					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		Else
			//"Banco de Horas"###"Opção não está habilitada no menu do Terminal de Consultas"
			cHtml += HtmlDefault( STR0024 , STR0041 ) 
		EndIf	
		
	TCF END cHtml
	
WEB EXTENDED END
	
Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³W_TCFWRETURN³Autor ³ Marinaldo de Jesus   ³ Data ³04/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Retorna a Pagina de Entrada do Terminal de Consultas        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³w_TcfReturn()                            					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFWRETURN()

Local cHtml
//Local cDataHorSec := StrTran(dtoc(DATE()),"/","")+StrTran(time(),":","")+LTRIM(str(seconds(),5))

HttpFreeSession()

If Select("XX8") > 0
	XX8->( dbCloseArea() )
EndIf
If Select("XX9") > 0
	XX9->( dbCloseArea() )
EndIf

TCF INIT cHtml

	cHtml := W_TCFWINIT()
	/*cHtml := '<html>'																	+ CRLF
	cHtml += '<head>'																	+ CRLF
	cHtml += '<script language="JavaScript">'											+ CRLF
	cHtml +=	'window.open("w_TCFWINIT.apw?DataHorSec=<%='+cDataHorSec+'%>","blank")' + CRLF
	cHtml += '</script>'																+ CRLF
	cHtml += '</head>' 																	+ CRLF
	cHtml += '</html>' 																	+ CRLF*/

TCF END cHtml

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFWInSite³ Autor ³ Marinaldo de Jesus    ³ Data ³25/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Validacao do Acesso ao Terminal de Consulta                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TCFWInSite( cReturn , lLogout )

Local aEmpresas
Local cHtml
Local cEmp
Local cFil
Local cMatricula
Local cPassWord
Local cInconsistencia
Local cSraPassWord
Local lAllOk
Local lChkEnv
Local cVisRen	:= SuperGetMv("MV_TCFVREN", ,"N") // Define se usuário demitido pode acessar Portal para visualizar rendimento.

Begin Sequence
	IF ( ValType( HttpPost->cMatricula ) == "U" .AND. TCFGelAllOk() )
		Break
	EndIF

	cEmp := TCFGetPstEmp()
	IF Empty( cEmp )
		cInconsistencia := STR0039	//"Empresa inv&aacute;lida"
		Break
	EndIF

	cFil := TCFGetPstFil()
	IF Empty( cFil ) 
		cInconsistencia := STR0034	//"Filial inv&aacute;lida"
		Break
	EndIF

	IF Empty( HttpPost->cMatricula )
		cInconsistencia := STR0008	//"Matricula inv&aacute;lida"
		Break
	EndIF
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Posiciona no Funcionario                     				   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	SRA->( dbSetOrder( RetOrdem("SRA") ) )
	SRA->( MsSeek( xFilial( "SRA" , cFil ) + HttpPost->cMatricula ) )
	
	If ( cVisRen <> "S" )
		If SRA->RA_SITFOLH == 'D' .and. (!Empty(SRA->RA_DEMISSA) .AND. dDataBase >= SRA->RA_DEMISSA) .AND.  !( SRA->RA_RESCRAI $ '30/31' )
			cInconsistencia := STR0049 //'Funcinário com status de demitido'
		EndIf	
	EndIf


	aEmpresas	:= GetEmpSigaMat()
	IF (;
			Empty( aEmpresas );
			.or.;
			( aScan( aEmpresas , { |x| x[1] == HttpPost->cEmpFil } ) == 0 );
		)	
		cInconsistencia := STR0028 //"Empresa ou Filial inv&aacute;lida"
		Break
	EndIF
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Prepara o ambiente a ser utilizado pelo usuario 					 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/    
	lChkEnv := fRhOnPrepEnv( aEmpresas, , , cEmp, cFil )

	If (lChkEnv)
	
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define o Modulo em Uso                          					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		SetModulo( "SIGAGPE" , "GPE" )
	
		If ExistBlock("TCFVERMAT") 
			ExecBlock("TCFVERMAT",.F.,.F.)
		Else
			HttpPost->cMatricula := Padr( HttpPost->cMatricula , TamSx3("RA_MAT")[1] )
		Endif
	
		SRA->( dbSetOrder( RetOrdem("SRA") ) )
		IF (;
				Empty( HttpPost->cMatricula );
				.or.;
				SRA->( !MsSeek( xFilial( "SRA" , cFil ) + HttpPost->cMatricula , .F. ) );
			)	
			cInconsistencia := STR0006 //"Usu&aacute;rio n&atilde;o autorizado"
			Break
		EndIF
	
		IF (;
				Empty( HttpPost->cPassWord );
				.and.;
				Empty( TCFWGetPas() );
			)
			cInconsistencia := STR0038	//"Senha Inv&aacute;lida"
			Break
		EndIF
	
		cPassWord 		:= APXTo64( Upper( AllTrim( HttpPost->cPassWord ) ) )
		cPassWord 		:= IF( ( cPassWord == "00" ) , "" , cPassWord )
		cSraPassWord	:= APXTo64( Embaralha( Upper( AllTrim( SRA->RA_SENHA ) ) , 1 ) )
		IF (;
				Empty( cPassWord );
				.or.;
				!( cSraPassWord == cPassWord );
			)	
			cInconsistencia := STR0038	//"Senha Inv&aacute;lida"
			Break
		EndIF    
	
		TCFWSetEmp( cEmp )
		TCFWSetFil( cFil )
		TCFWSetMat( HttpPost->cMatricula )
		TCFWSetPas( HttpPost->cPassWord )
		TCFSetAllOk( .T. )
	
	Else
		cInconsistencia := OemToAnsi(STR0047) //"Falha na abertura de Empresa/Filial! Verifique configuração EMPSELECT e/ou arquivo SIGAMAT.EMP"
	EndIf

End Sequence

TCF INIT cHtml

	DEFAULT lLogout := .T.
	IF !Empty( cInconsistencia )
		cHtml := HtmlDefault( STR0012 , cInconsistencia , cReturn , lLogout , .F. )  //"Existem inconsist&ecirc;ncias a serem verificadas:"
	ElseIF !( TCFGelAllOk() )
		cHtml := HtmlDefault( STR0012 , NIL , cReturn , lLogout , .F. )
	EndIF

TCF END cHtml

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TcfStart  ³ Autor ³ Marinaldo de Jesus    ³ Data ³25/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Validacao do Acesso ao Terminal de Consulta                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TcfStart()

Local cHtml

IF EmptyHtml( ( cHtml := TCFWInSite() ) )
	TCF INIT cHtml
		cHtml := W_TCFW005()
	TCF END cHtml
EndIF

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFNoFunction ³ Autor ³Marinaldo de Jesus ³ Data ³25/03/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna Codigo Padrao Caso Nao Tenha Encontrada a Funcao    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFNoFunction()

Local cHtml		  := ""

DEFAULT HttpGet->NoFunction := ""

WEB EXTENDED INIT cHtml START "TCFWInSite"

	TCF INIT cHtml

		HttpGet->NoFunction := Space( 01 ) + HttpGet->NoFunction + Space( 01 )
		
		//"Existem inconsist&ecirc;ncias a serem verificadas:"
		//"Fun&ccedil;&atilde;o n&atilde;o encontrada no Reposit&oacute;rio"
		cHtml := HtmlDefault( STR0012 , ( STR0032 + HttpGet->NoFunction + STR0033 ) )

	TCF END cHtml
	
WEB EXTENDED END

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFWUPDPSW	  ³ Autor ³Marinaldo de Jesus ³ Data ³25/03/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Alteracao da Senha no Terminal de Consulta					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFWUPDPSW()

Local cHtml			:= ""
Local cMatric		:= TCFWGetMat()

Local aEmpresas
Local aPassWordAsc

Local cFil
Local cTemp
Local cReturn
Local cInconsistencia
Local cPassWordChar
Local cSraPassWord

Local dAdmissa
Local dNascimento

Local lCpfOk
Local lPassW
Local lAdmis
Local lNasci

Local nX
Local nPos
Local nLenPassWord
Local nPassWSeq
Local cTCFSDoc		:= SuperGetMv( "MV_TCFSDOC" , .F. , "1" ) // '1' = Utiliza CPF   '2'= Utiliza RG
Local cDescSDoc		:= OemToAnsi( AllTrim( RetTitle( If( cTCFSDoc=="2", "RA_RG", "RA_CIC" ) ) ) )

WEB EXTENDED INIT cHtml START "TcfUpdStart"

	TCF INIT cHtml

		HttpPost->cPassWord			:= APXTo64( Upper( AllTrim( HttpPost->cPassWord ) ) )
		HttpPost->cNewPassWord		:= APXTo64( Upper( AllTrim( HttpPost->cNewPassWord ) ) )
		HttpPost->cConNewPassWord	:= APXTo64( Upper( AllTrim( HttpPost->cConNewPassWord ) ) )
	
		Begin Sequence
	
			IF Empty( HttpPost->cNewPassWord ) 
				cInconsistencia := STR0017  + "<br><br>" + CRLF		//"A senha n&atilde;o foi preenchida"
				Break
			EndIF
	
			IF !( HttpPost->cNewPassWord == HttpPost->cConNewPassWord )
				cInconsistencia := STR0014 + "<br><br>" + CRLF		//"Senhas inv&aacute;lidas"
				Break
			EndIF
	
			SRA->( MsSeek( xFilial( "SRA" , TCFWGetFil() ) + TCFWGetMat() ) )
			lCpfOk	:= ( Ap64ToX( APXTo64(Upper(AllTrim(HttpPost->cCPF))) ) == Upper( AllTrim(SRA->RA_CIC) ) )
			IF !( lCpfOk )
				If cPaisLoc <> "BRA"
					cInconsistencia := cDescSDoc+STR0048 + "<br><br>" + CRLF //"{Titulo do RA_CIC conforme localizacao} inv&aacute;lido"
				Else
					cInconsistencia := STR0013 + "<br><br>" + CRLF		     //"CPF inv&aacute;lido"
				EndIf
				Break
			EndIF
	
			dAdmissa	:= Ctod(Day2Str(HttpPost->cDiaAdmissao)+"/"+Month2Str(HttpPost->cMesAdmissao)+"/"+Year2Str(HttpPost->cAnoAdmissao),"DDMMYY")
			lAdmis		:= ( dAdmissa == SRA->RA_ADMISSA )
			IF !( lAdmis )
				cInconsistencia := STR0015 + "<br><br>" + CRLF	//"Data de admiss&atilde;o inv&aacute;lida"
				Break
			EndIF
	
			dNascimento	:= Ctod(Day2Str(HttpPost->cDiaNascimento)+"/"+Month2Str(HttpPost->cMesNascimento)+"/"+Year2Str(HttpPost->cAnoNascimento),"DDMMYY")
			lNasci		:= ( dNascimento == SRA->RA_NASC )
			IF !( lNasci )
				cInconsistencia := STR0016 + "<br><br>" + CRLF	//"Data de nascimento inv&aacute;lida"
				Break
			EndIF
	
			cTemp := Ap64ToX( HttpPost->cNewPassWord )
			nLenPassWord	:= Len( cTemp )
			IF ( nLenPassWord < GetSx3Cache( "RA_SENHA" , "X3_TAMANHO" ) )
				HttpPost->cNewPassWord := "__LENINVALIDO__"
			EndIF
			IF ( HttpPost->cNewPassWord <> "__LENINVALIDO__" )
				aPassWordAsc := {}
				For nX := 1 To nLenPassWord
					cPassWordChar := SubStr( cTemp , nX , 1 )
					IF (;
							Empty( StrTran(cTemp,cPassWordChar,"") );
							.or.;
							( Len( StrTran(cTemp,cPassWordChar,"") ) <= 3 );
						)	
						HttpPost->cNewPassWord := "__CHARIGUAL__"
						Exit
					EndIF
					aAdd( aPassWordAsc , Asc( cPassWordChar ) ) 
				Next nX
				IF ( HttpPost->cNewPassWord <> "__CHARIGUAL__" )
					nX := 0
					IF (;
							!Empty( aPassWordAsc );
							.and.;
							( Len( aPassWordAsc ) > 1 );
						)	
						IF ( aPassWordAsc[1] < aPassWordAsc[2] )
							aEval( aPassWordAsc , { |x,y| IF( ( y == 1 ) .or. ( ( x - nX ) <>  1 ) , nX := x , ( ++nPassWSeq , nX := x ) ) } )
						Else
							aEval( aPassWordAsc , { |x,y| IF( ( y == 1 ) .or. ( ( x - nX ) <> -1 ) , nX := x , ( ++nPassWSeq , nX := x ) ) } )
						EndIF
					EndIF
					IF ( nPassWSeq == ( Len( cTemp ) - 1 ) )
						HttpPost->cNewPassWord := "__PASSWSEQUENC__"
					ElseIF ( cTemp == AllTrim( SRA->RA_MAT ) )
						HttpPost->cNewPassWord := "__PASSWEQUALMAT__"
					EndIF
				EndIF
				cTemp := ""
			EndIF
	
			lPassW := !( HttpPost->cNewPassWord $ "__CHARIGUAL__*__LENINVALIDO__*__PASSWEQUALMAT__*__PASSWSEQUENC__" ) 
			IF !( lPassW )
				Break
			EndIF
	
			cSraPassWord := APXTo64( AllTrim( Embaralha( Upper( AllTrim( SRA->RA_SENHA ) ) , 1 ) ) )
			IF !( cSraPassWord == HttpPost->cPassWord )
				cInconsistencia := STR0007 + "<br><br>" + CRLF	//"Senha Anterior Inv&aacute;lida"
				Break
			EndIF		
	
			IF !SRA->( RecLock( "SRA" , .F. ) )
				cInconsistencia := STR0040	//"N&atilde;o foi  poss&iacutevem gravar a nova senha."
				Break
			EndIF
			SRA->RA_SENHA := Embaralha( Ap64ToX( HttpPost->cNewPassWord ) , 0 )
			SRA->( MsUnLock() )

			If ValType(cMatric) == "U"
				HttpFreeSession()
			EndIf

			cReturn := '<p align="right"><a href="javascript:window.close()"><img src="'+TcfRetDirImg()+'/confirmar.gif" border="0"></a></p>'
			cHtml	:= HtmlDefault( STR0026 , STR0027 , cReturn ) //"Alterar/Cadastrar Senha"###"Senha Alterada/Cadastrada com Sucesso:"
	
		End Sequence
	
		IF !( lPassW )
			IF ( HttpPost->cNewPassWord == "__CHARIGUAL__" )
				cInconsistencia := STR0018 + "<br><br>" + CRLF	//"N&atilde;o podem existir mais de 3 carecteres iguais na senha"
			ElseIF ( HttpPost->cNewPassWord == "__LENINVALIDO__" )
				cInconsistencia := STR0019 + "<br><br>" + CRLF	//"O n&uacute;mero de caracteres da senha &eacute; menor que 6 (seis)"
			ElseIF ( HttpPost->cNewPassWord == "__PASSWSEQUENC__" )
				cInconsistencia := STR0037 + "<br><br>" + CRLF	//"A Senha n&atilde;o pode conter Caracteres Sequenciais"
			ElseIF ( HttpPost->cNewPassWord == "__PASSWEQUALMAT__" )
				cInconsistencia := STR0036 + "<br><br>" + CRLF	//"A Senha n&atilde;o pode ser igual a Matricula"
			EndIF
		EndIF
	
		IF !Empty( cInconsistencia )
			cReturn := '<p align="right"><a href="W_TCFW014.APW"><img src="'+TcfRetDirImg()+'/confirmar.gif" border="0"></a></p>'
			cHtml	:= HtmlDefault( STR0012 , cInconsistencia , cReturn )  //"Existem inconsist&ecirc;ncias a serem verificadas:"
		EndIF

	TCF END cHtml
	
WEB EXTENDED END

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TcfUpdStart	  ³ Autor ³Marinaldo de Jesus ³ Data ³25/03/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Validacao do Acesso ao Terminal de Consulta					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TcfUpdStart()

Local cReturn := '<p align="right"><a href="W_TCFW014.APW"><img src="'+TcfRetDirImg()+'/confirmar.gif" border="0"></a></p>'

Return( TCFWInSite( cReturn , .F. ) )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³InTcfwFunExec ³Autor ³Marinaldo de Jesus   ³ Data ³24/08/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Executar Funcoes Dentro de TCFWFUN                           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³InTcfwFunExec( cExecIn , aFormParam )						 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³uRet                                                 	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico 													 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function InTcfwFunExec( cExecIn , aFormParam )
         
Local uRet

DEFAULT cExecIn		:= ""
DEFAULT aFormParam	:= {}

IF !Empty( cExecIn )
	cExecIn	:= BldcExecInFun( cExecIn , aFormParam )
	uRet	:= cExecIn
	CheckExecForm( @uRet )
EndIF

Return( uRet )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TcfChkMenu    ³Autor ³Emerson Grassi Rocha ³ Data ³25/07/2005³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Checa se a opcao esta habilitada na config. do menu (RBC)    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³TcfChkMenu()												 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³lRet = .T. ou .F.                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³SIGATCF 													 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function TcfChkMenu()

Local lRet 		:= .F.
	
RBC->( dbGoTop() )
While RBC->( !Eof() )
	If Upper(Alltrim(RBC->RBC_ROTINA)) $ Upper(Procname(1))
		If RBC->RBC_STATUS == "A"
			lRet := .T.
			Exit
		EndIf
	EndIf
					
	RBC->( dbskip() )
EndDo      

Return lRet

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFW016   	³Autor ³ Tatiane Vieira Matias³ Data ³19/01/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Tela de Opcoes do Informe de Rendimentos do TCF             ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFW016()									   			    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFW016()

Local cHtml
Local nHdl				:= 0.00
Local cFile				:= "GRHINF2.FCH"
Local nTamArq			:= 0.00
Local nFor				:= 0.00
Local nX				:= 0.00
Local n					:= 0
Local cBuffer			:= ""
Local cAnoBase			:= ""
Local aDados			:= {}

Private aAnos			:= {}

TCF INIT cHtml

	//Le o arquivo com as configuracoes do Informe de Rendimento e armazena em array
	IF File(cFile)
		nHdl := Fopen(cfile,64)
		fSeek(nHdl,0,0)
		nTamArq := fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		nFor := nTamArq / (80+FwGetTamFilial)

		For nX := 1 To nFor
			cBuffer := Space(81+FwGetTamFilial)
			fRead(nHdl,@cBuffer,81+FwGetTamFilial)
			aAdd(aDados, { Substr(cBuffer,77,2) 	,;	// Empresa
							Substr(cBuffer,80,FwGetTamFilial)	,;	// Filial
							Substr(cBuffer,1,4)     ,;  // Ano Base
							.F. 					})  // GDDELETED 
		Next nX                              	
		
		fClose(nHdl)
		aDados:= aSort(aDados,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]}) //Empresa + Filial + AnoBase		
	
		For n:= 1 To len(aDados)		
			If ( aDados[n,1] == cEmpAnt .and. aDados[n,2] == tcfwgetfil() ) .or. ;
				( aDados[n,1] == cEmpAnt .and. Empty(aDados[n,2]) ) .or. ;		
				( Empty(aDados[n,1]) .and. Empty(aDados[n,2] ) )
			  
				cAnoBase := aDados[n,3]

				If Ascan(aAnos,cAnoBase) == 0
					Aadd(aAnos,cAnoBase)     
				EndIf	
  	    	
  	    	 EndIf   
  	    Next n	 

	EndIf
  
	cHtml := H_TCFH016()

TCF END cHtml


Return( cHtml )


/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFWIR016  	³Autor ³ Tatiane Vieira Matias³ Data ³19/01/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Informe de Rendimentos do TCF                               ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFWIR016()											    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   						    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             								³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFWIR016()

Local cHtml
Local cAno 			:= HttpPost->cAno
Local dDtVisualiza 	:= CTOD("//")
Local nHdl			:= 0.00
Local cFile			:= "GRHINF2.FCH"
Local nTamArq		:= 0.00
Local nFor			:= 0.00
Local nX			:= 0.00
Local n1			:= 0.00
Local cBuffer		:= ""
Local dDataInf		:= CTOD("//")
Local cNomeResp	 	:= ""
Local cDataHorSec	:= StrTran(dtoc(DATE()),"/","")+StrTran(time(),":","")+LTRIM(str(seconds(),5))
Local aDados		:= {}

TCF INIT cHtml

	IF File(cFile)
		nHdl := Fopen(cfile,64)
		fSeek(nHdl,0,0)
		nTamArq := fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		nFor := nTamArq / (80+FwGetTamFilial)

		For nX := 1 To nFor
			cBuffer := Space(81+FwGetTamFilial)
			fRead(nHdl,@cBuffer,81+FwGetTamFilial)
			If Substr(cBuffer,1,4) = cAno 
				aAdd(aDados, { Substr(cBuffer,77,2)	,;     	    // Empresa
									Substr(cBuffer,80,FwGetTamFilial)	,;	// Filial
									Substr(cBuffer,1,4) 	,; // Ano Base
									CTOD(Substr(cBuffer,6,2) + "/" + Substr(cBuffer,8,2) + "/"  + Strzero(Val(Substr(cBuffer,1,4))+1,4) )		,; // Data Liberacao
								    CTOD(Substr(cBuffer,11,2) + "/" + Substr(cBuffer,13,2) + "/" + Strzero(Val(Substr(cBuffer,1,4))+1,4) ) 	,; // Data do Innforme de Rendimento
									Substr(cBuffer,16,60)	,; // Responsavel
									.F. 					}) // GDDELETED 
    		EndIf
		Next nX                              	

		aDados:= aSort(aDados,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]}) //Empresa + Filial + AnoBase
		fClose(nHdl)

  		If nPos := Ascan(aDados,{|X|,X[1] == cEmpAnt .and. X[2] == tcfwgetfil() })  > 0
			nPos := Ascan(aDados,{|X|,X[1] == cEmpAnt .and. X[2] == tcfwgetfil() })
			dDtVisualiza := aDados[nPos,4]
			cNomeResp	 := aDados[nPos,6]
			dDataInf	 := aDados[nPos,5]
		 ElseIf nPos:= Ascan(aDados,{|X|, X[1] == cEmpAnt .and. Empty([2]) } )  > 0 
				nPos:= Ascan(aDados,{|X|, X[1] == cEmpAnt .and. Empty([2]) } ) 
				dDtVisualiza := aDados[nPos,4]
				cNomeResp	 := aDados[nPos,6]
				dDataInf	 := aDados[nPos,5]
		 ElseIf nPos:= Ascan(aDados,{|X|, Empty(X[1]) .and. Empty(X[2] ) })  > 0 
				nPos:= Ascan(aDados,{|X|, Empty(X[1]) .and. Empty(X[2] ) })  
				dDtVisualiza := aDados[nPos,4]
				cNomeResp	 := aDados[nPos,6]
				dDataInf	 := aDados[nPos,5]
		EndIf
	
   EndIf
    
	If  dDtVisualiza > Date() 
		//"Informe de Rendimentos" ###"N&atilde;o existem valores a serem visualizados"
		cHtml += HtmlDefault( STR0043 , STR0003 )
	Else           
		/*
		 Foi criado dois frames: o mainFrame onde sera visualizado o Informe de rendimento e 
		 o bottomFrame que sera uma versao para impressao e sera escondido.
		*/                                                                
	
		cHtml += '<html>' + CRLF
		cHtml += '<frameset rows="*,1" cols="*" framespacing="0" frameborder="NO" border="0">' + CRLF
		cHtml += '  <frame src="W_TCFWInfRend.APW?DataHorSec='+cDataHorSec+'&cFrame=1&cAno=' + cAno + '&cResp=' + cNomeResp + '&DtInf=' + DTOC(dDataInf) + '" name="mainFrame">' + CRLF
		cHtml += '  <frame src="W_TCFWInfRend.APW?DataHorSec='+cDataHorSec+'&cFrame=2&cAno=' + cAno + '&cResp=' + cNomeResp + '&DtInf=' + DTOC(dDataInf) + '" name="bottomFrame">' + CRLF
		cHtml += '</frameset>' + CRLF
		cHtml += '<noframes><body style="background-color: transparent;">' + CRLF
		cHtml += '</body></noframes>' + CRLF
		cHtml += '</html>' + CRLF
	EndIf

TCF END cHtml

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TCFWInfRend    ³Autor ³ Tatiane Vieira Matias³ Data ³19/01/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Chamada da funcao para montar o html do Informe de Rendimento  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³W_TCFWShowInfRend()								 			   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico                                                       ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³                                   					  		   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                             						  		   ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Web Function TCFWInfRend()
		
Local cHtml			:= ""
Local cSvHtml		:= ""
Local nRecnoSRA	:= 0    

//Pega os parametros passados na url - Ano e qual o frame que esta montando
Local cAno			:= HttpGet->cAno

Private cFrame		:= HttpGet->cFrame
Private cNomeResp	:= HttpGet->cResp
Private dDataInf	:= HttpGet->DtInf

WEB EXTENDED INIT cHtml START "TCFWInSite"

	TCF INIT cHtml

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define o Modulo em Uso                          					 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		SetModulo( "SIGAGPE" , "GPE" )
	
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Posiciona no Funcionario                     				   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		SRA->( dbSetOrder( RetOrdem("SRA") ) )
		IF SRA->( MsSeek( xFilial( "SRA" , TCFWGetFil() ) + TCFWGetMat() ) )
		
			nRecnoSRA := SRA->( Recno() )
		
				/*/
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Chama o Gpem580 para gerar o Codigo HTML correspondente ao    ³
				³Informe de Rendimentos  									   			³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
				cSvHtml := cHtml
				IF EmptyHtml( cHtml += Gpem580(.T.,TCFWGetFil(),TCFWGetMat(),cAno,  ))
					//"Informe de Rendimentos" ###"N&atilde;o existem valores a serem visualizados"
					cHtml += HtmlDefault( STR0043 , STR0003 )
				EndIF

		Else
	
			//"Informe de Rendimentos" ###"N&atilde;o existem valores a serem visualizados"
			cHtml += HtmlDefault( STR0043 , STR0003 )
	
		EndIF	

	TCF END cHtml
	
WEB EXTENDED END

Return( cHtml )
Web Function TCFW000()
	Local cHtml := ""

	WEB EXTENDED INIT cHtml START "TCFWInSite"
		TCF INIT cHtml
			SetModulo("SIGAGPE" , "GPE")
			SRA->(dbSetOrder(RetOrdem("SRA")))
			SRA->(MsSeek(xFilial("SRA", TCFWGetFil()) + TCFWGetMat()))
			
			Private cNomeFun := AllTrim(SRA->RA_NOME)
			Private cPicture := RetPictFun(.T.)
			Private aMenuTCF := GetTCFMenu()
					
 			cHtml += H_TCFH000()
		TCF END cHtml	
	WEB EXTENDED END

Return( cHtml )



Static Function GetTCFMenu()
	Local aUnique	:= { "RBC_FILIAL" , "RBC_CODMNU" }
	Local cFilRBC	:= ""
	Local cRotina	:= ""
	Local cDescri	:= ""
	Local cVisRen	:= SuperGetMv("MV_TCFVREN", ,"N")
	Local lIncluir	:= .T. 
	Local aMenuTcf	:= {}	
               
	DBSelectArea("RBC")
	RBC->( MsSeek( ( cFilRBC := xFilial("RBC") ) ) )

	While RBC->( !Eof() .and. ( RBC_FILIAL == cFilRBC ) )		
		
		IF RBC->( UniqueKey( aUnique ) )
			aAdd(aMenuTcf , {})
		EndIF
				
		IF ( RBC->RBC_STATUS == "A" )			
			IF !Empty( cRotina := AllTrim(RBC->RBC_ROTINA) )
				If ( cVisRen == "S" ) .And. SRA->RA_SITFOLH == 'D'  .And.  !( SRA->RA_RESCRAI $ '30/31' )
					IF FindFunction( "w_"+cRotina )							//Web Functions w_?	ou W_?
						cRotina := "w_"+cRotina+".APW"
						If (Upper(AllTrim(cRotina)) <> "W_TCFW016.APW")
							lIncluir:= .F.
						EndIf	
					EndIf	
				Else	
					IF FindFunction( "w_"+cRotina )							//Web Functions w_?	ou W_?
						cRotina := "w_"+cRotina+".APW"					
					ElseIF FindFunction( "l_"+cRotina )						//UserHtml Functions l_? ou L_?
						cRotina := "l_"+cRotina+".APW"
					ElseIF FindFunction( "h_"+cRotina )						//Html Functions h_? ou H_?
						cRotina := "h_"+cRotina+".APW"
					ElseIF FindFunction( ALLTRIM(UPPER("B_"+cRotina)) )		//Web User Functions b_?
						cRotina := "B_"+cRotina+".APW"						
					Else													//"Função não encontrada no repositório
						cRotina := "w_TCFNoFunction.APW?NoFunction="+cRotina
					EndIF
				EndIf		
			Else
				cRotina := "#"
			EndIF
			
			IF lIncluir
				cDescri := Capital( AllTrim( RBC->RBC_DESCRI ) )
					
				aAdd( aMenuTcf[Len( aMenuTcf ) ],	{; 
								  						cDescri ,; //Descricao do Menu
														cRotina	 ; //Programa a Ser Executado
								 					};
					   )  
			Else
				lIncluir:= .T.
			Endif
		EndIF
		
		RBC->( dbSkip() )
	End While
Return aMenuTcf
