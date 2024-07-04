#include "iRep_Run.ch"
#include "BIDefs.ch"
#include "iReportDefs.ch" 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IReport_Run
Classe para execução do relatorio atraves do Jasper.

@param		Nome do relatório.
@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//------------------------------------------------------------------------------------- 
class IReport_Run 
	data cReportPath		//Nome do relatorio.
	data cConnType			//Tipo da conexão.
	data cDbName			//Nome do banco de dados ou ODBC
	data cDbURL				//Endereço do banco de dados. pode ser o end. ip.
	data cDbPort			//Porta do banco de dados.
	data cDbLogin			//Nome do usuario para logar no DB.
	data cDbPass			//Senha do usuario para logar no DB.
	data cWsReport			//Localização do web service para obtenção do relatorio.    
	data cRepDestino   		//Para onde sera enviado o relatorio, 1-impressora, 2-video.
	data nNumCopias			//Numero de copias para ser impresso.
	data lShowImpDlg		//Mostra a caixa de dialogo da impressora.
	
	//Construtor
	method New() constructor
	method IReport_Run()
	//Metodos para armazenamento das propriedades.
	method cReportName(cPath) 
	method cConnType() 
	method cDbName() 
	method cDbURL() 
	method cDbPort() 
	method cDbLogin() 
	method cDbPass() 	
	method cWsReport()
	method cReportDestino(cRepDes) 
	method nNumCopias(nQtd) 
	method lShowPrintDialog(isVisible)	
	//Metodo de execucao do relatorio.
	method nRun()
	method nPrepCliente()
endclass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Construtores.

@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//------------------------------------------------------------------------------------- 
method New() class IReport_Run
	::IReport_Run()
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IReport_Run
Construtores.

@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//------------------------------------------------------------------------------------- 
method IReport_Run() class IReport_Run
	::cRepDestino 	:= "0"
	::nNumCopias	:= 1
	::lShowImpDlg	:= .t.
return                     

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cReportName
Define e Retorna o nome do relatorio

@param 		Caminho do relatorio.
@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//------------------------------------------------------------------------------------- 
method cReportName(cPath) class IReport_Run
	property ::cReportPath := cPath	
return alltrim(::cReportPath)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cConnType
Define e Retorna tipo da conexão do relatório.

@param 		Tipo da conexão do relatório.
@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//------------------------------------------------------------------------------------- 
method cConnType() class IReport_Run
	Local cTipoDB := SuperGetMv( "MV_IRDBTP" , .F. , Upper( TCGetDB() ) ,  ) 

	If( cTipoDB == "MSSQL" .or. cTipoDB == "MSSQL7" )
		property ::cConnType := CONN_MSSQL
	ElseIf( cTipoDB == "ORACLE" )
		property ::cConnType := CONN_ORACLE
	ElseIf( cTipoDB == "DB2" )
		property ::cConnType := CONN_DB2
	ElseIf( cTipoDB == "DB2/400" )
		property ::cConnType := CONN_DB2400     
	ElseIf ( cTipoDB == "ODBC" )
		property ::cConnType := CONN_ODBC
	endif
return ::cConnType

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cDbName
Retorna o nome do banco de dados.

@param 		Nome do banco de dados.
@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//------------------------------------------------------------------------------------- 
method cDbName() class IReport_Run
	property ::cDbName := SuperGetMv( "MV_IRDB" , .F. , "MP11" ,  )  
return ::cDbName

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cDbURL
Retorna o endereco do banco de dados.

@param 		Endereco do banco de dados.
@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//------------------------------------------------------------------------------------- 
method cDbURL() class IReport_Run
	property ::cDbURL := SuperGetMv( "MV_IRDBURL" , .F. , "localhost" ,  ) 
return ::cDbURL

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cDbPort
Retorna a porta do banco de dados.

@param 		Porta do banco de dados.
@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//------------------------------------------------------------------------------------- 
method cDbPort() class IReport_Run
	property ::cDbPort := SuperGetMv( "MV_IRDBPOR" , .F. , "" ,  ) 
return ::cDbPort

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cDbLogin
Retorna a login de usuário para o banco de dados.

@param 		Login de usuário para o banco de dados.
@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//------------------------------------------------------------------------------------- 
method cDbLogin() class IReport_Run
	property ::cDbLogin := SuperGetMv( "MV_IRDBUSR" , .F. , "" ,  ) 
return ::cDbLogin

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cDbPass
Retorna a enha de usuário para o banco de dados.

@param 		Senha de usuário para o banco de dados.
@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//------------------------------------------------------------------------------------- 
method cDbPass() class IReport_Run
	property ::cDbPass := SuperGetMv( "MV_IRDBPSS" , .F. , "" ,  ) 
return ::cDbPass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cWsReport
Retorna a URL do webservice para obtencao do relatorio.

@param 		URL do webservice para obtencao do relatorio.
@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//-------------------------------------------------------------------------------------
method cWsReport() class IReport_Run
	property ::cWsReport := SuperGetMv( "MV_IRWS" , .F. , "localhost/ws" ,  )  
return ::cWsReport

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cReportDestino
Define e Retorna o destino do relatorio.

@param 		Destino do relatorio.
@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//-------------------------------------------------------------------------------------
method cReportDestino(cRepDes) class IReport_Run
	property ::cRepDestino := cRepDes
return ::cRepDestino

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nNumCopias
Define e Retorna a quantidade de copias relatorio.

@param 		Quantidade de copias relatorio.
@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//-------------------------------------------------------------------------------------
method nNumCopias(nQtd) class IReport_Run
	property ::nNumCopias := nQtd
return ::nNumCopias              

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} lShowPrintDialog
Define e Retorna a caixa de dialogo da impressora

@param 		Mostrar a caixa de dialogo da impressora.
@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//-------------------------------------------------------------------------------------
method lShowPrintDialog(isVisible) class IReport_Run
	property ::lShowImpDlg := isVisible
return ::lShowImpDlg
  
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nRun
Executa o relatório.

@author    	Alexandre Alves da Silva 
@See 		Todos os parâmetros devem ser marcados com '|' através da função addMarca().
@version   	P11
@since     	23/11/2006
/*/
//-------------------------------------------------------------------------------------
method nRun() class IReport_Run
	Local nRet		:= 0
	Local cComando	:= "" 
	Local aLog		:= {}
	Local cPais 	:= getPais()
	Local cIdioma	:= getIdioma()		

 	If ( Empty(::cDbName()) .OR. Empty(::cDbURL()) .OR. Empty(::cWsReport()) )
 		MsgAlert (STR0020 , STR0021 ) //###"Favor entrar em contato com o Administrador e requisitar a configuração da integração iReports com o Protheus"###"Atenção: integração não configurada"
 	
 	ElseIf( ::nPrepCliente() != -1 )  
 		//Instrução para exibição do relatório
		cComando	+=	"javaw -jar " 
		cComando 	+=	GetClientDir() + "\ireport\iReportRun.jar "    
		cComando	+=	addMarca(::cReportName())							+ " " //Nome do relatorio.
		cComando	+=	addMarca(::cConnType())    				   			+ " " //Tipo da conexão.
		cComando	+=	addMarca(::cDbName())  					   			+ " " //Nome do banco de dados ou conexão ODBC.
		cComando	+=	addMarca(::cDbURL()) 	   				   			+ " " //URL do banco de dados.
		cComando 	+=	addMarca(::cDbPort()) 								+ " " //Porta de conexão do banco de dados. 
		cComando	+=	addMarca(::cDbLogin()) 	   	  						+ " " //Usuario do banco de dados.
		cComando	+=	addMarca(::cDbPass())  	   	  						+ " " //Senha do Usuario do banco de dados.	
		cComando	+=	addMarca(::cWsReport())	  	 						+ " " //Localização do webservice para obtencao do relatório.  
		cComando	+=	addMarca( FWGrpCompany() ) 	   						+ " " //Grupo de Empresas.	
		cComando	+=	addMarca( StrTran( FWCompany(), " ", "*" ) ) 		+ " " //Empresas.		
		cComando	+=	addMarca( StrTran( FWUnitBusiness(), " ", "*" )  )	+ " " //Unidade de Negócio.
		cComando	+=	addMarca( StrTran( FWFilial(), " ", "*" )  ) 	   	+ " " //Filial. 
		cComando	+=	addMarca(::cReportDestino())   						+ " " //Destino do relatorio
		cComando	+=	addMarca(alltrim(str(::nNumCopias())))  			+ " " //Numero de copias.
		cComando	+=	addMarca(iif(::lShowPrintDialog(),"T","F")) 		+ " " //Mostra a tela da seleção da impressora.
		cComando	+=	addMarca("UTF-8")										+ " "  //Codificação do relatório
		cComando	+=	addMarca( cPais )										+ " "  //País da instalação
		cComando	+=	addMarca( cIdioma )									+ " "  //idioma da instalação

		nRet := winExec( cComando )
		
		//Log dos parâmetros passados para o relatório.     
		aAdd( aLog, { STR0011, ::cReportName() } ) 		   												//"Nome do relatório: "
		aAdd( aLog, { STR0012, Upper( tcGetDB() ) } )       											//"Tipo da conexão: "
		aAdd( aLog, { STR0013, ::cDbName() } )             												//"Nome do banco de dados [MV_IRDB]: "
		aAdd( aLog, { STR0014, ::cDbURL() } )               											//"URL do banco de dados [MV_IRDBURL]: "
		aAdd( aLog, { STR0016, If( Empty( ::cDbPort()), STR0015, ::cDbPort() ) } ) 		   				//"Porta da conexão [MV_IRDBPOR]: "
		aAdd( aLog, { STR0022, SuperGetMv( "MV_IRDBTP" , .F. , Upper( TCGetDB() ) ,  )  } )				//"Driver JDBC [MV_IRDBTP]:" 
		aAdd( aLog, { STR0017, ::cDbLogin() } )	   		   												//"Usuário do banco de dados: " 
		aAdd( aLog, { STR0018, ::cWsReport() } )           												//"URL do webservice [MV_IRWS]: "
		aAdd( aLog, { STR0019, FWGrpCompany() + "/" + FWCompany() + FWUnitBusiness() + FWFilial() } ) 	//"Empresa/Filial: "	

		iLog( STR0010, aLog )
	else
		MsgAlert (STR0001 , STR0002 )  //"Não foi possivel fazer a instalação do iReport no Cliente"###"Atenção!"
	endif
return nRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nPrepCliente
Copia, do servidor para o cliente, os arquivos necessários para a integração.

@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//-------------------------------------------------------------------------------------
method nPrepCliente() class IReport_Run              
	Local aJDBCFiles	:= Directory("ireport\jdbc\*.*") 
	Local aLibFiles 	:= Directory("ireport\lib\*.*")  
	Local aFiles		:= Directory("ireport\*.*")
	
	Private	nRet	:=	0     
	
	Processa( {|| nRet := copyIRepFile(aLibFiles,aFiles, aJDBCFiles)}, STR0003, "",.F. ) //"Aguarde. Instalando o iReport no cliente"
return nRet
    
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} copyIRepFile
Copia, do servidor para o cliente, os arquivos necessários para a integração.

@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//-------------------------------------------------------------------------------------
Static function copyIRepFile(aLibFiles, aFiles, aJDBCFiles)
	local nFile		:= 0
	local nRet		:= 0
	local nQtdLibFi	:= Len(aLibFiles)
	local nQtdFile	:= Len(aFiles)   
	Local nQtdJDBC	:= Len(aJDBCFiles)
	local cDirCli	:= GetClientDir() + IREPORTS_PROTHEUS + "\"
	local cDirSer	:= IREPORTS_LIB + "\" 
	local cDirJDBC	:= IREPORTS_JDBC + "\" 
	local cFile		:= ""
	local cTmpDir	:= ""
	
	ProcRegua( nQtdFile + nQtdLibFi )                          

	MakeDir(cDirCli)
	MakeDir(cDirCli + "lib\")
	MakeDir(cDirCli + "jdbc\")

	if( !File( IREPORTS_PROTHEUS + "\version.ctrl" ) )
		MsgAlert (STR0004 , STR0002 ) 			//"Arquivo de controle não encontrado no servidor."###"Atenção!"
		nRet := -1
	else
		If( File( cDirCli + "version.ctrl" ) )
			cCliVer := cGetArqCtrVer( cDirCli + "version.ctrl" )
			cSerVer := cGetArqCtrVer( IREPORTS_PROTHEUS + "\version.ctrl" )      
			
			If( !Empty( cCliVer ) .and.  !Empty( cCliVer ) )
				If( cCliVer == cSerVer )
					nRet := 1
				EndIf
			Else
				MsgAlert(STR0005 , STR0002 ) 	//"Erro na comparação de versão entre os arquivos de controle."###"Atenção!"
				nRet := -1
			EndIf
		Endif
		
		If( nRet == 0 )
			cTmpDir := cDirCli            
			
			//Remove os arquivos antigos de execucao.
        	aEval( Directory( cBIFixPath( cTmpDir, "\" ) + "*.*" ), { |aFile| FERASE(cTmpDir + aFile[1]) } )
			
			//Copia os arquivos novos de execucao.
			for nFile := 1 to nQtdFile
				incProc(STR0006 + aFiles[nFile,1] + ".") 	//"Copiando arquvivo: "
				cFile	:= IREPORTS_PROTHEUS + "\" +  aFiles[nFile,1]
				
				if cpys2t(cFile,cTmpDir, .f.)
					conout(STR0007 + cFile + STR0008) 		//"Copia do arquivo: "###" realizada."
					nRet := 1                           	
				else
					conout(STR0009 + cFile + ".") 			//"Erro ao copiar o arquivo: "
					nRet := 0                    	
					break
				endif
			next nFile

			cTmpDir := cDirCli + "lib\"   
									
			//Remove os arquivos antigos da lib.
        	aEval( Directory( cBIFixPath( cTmpDir, "\" ) + "*.*" ), { |aFile| FERASE( cTmpDir + aFile[1]) } )
               
			//Copia os arquivos novos para a lib.
			for nFile := 1 to nQtdLibFi
				incProc(STR0006 + aLibFiles[nFile,1] + ".") //"Copiando arquvivo: "
				cFile	:=	cDirSer +  aLibFiles[nFile,1]
				
				if cpys2t(cFile,cTmpDir, .f.)
					conout(STR0007 + cFile + STR0008) 		//"Copia do arquivo: "###" realizada."
					nRet := 1
				else
					conout(STR0009 + cFile + ".") 			//"Erro ao copiar o arquivo: "
					nRet := 0
					break
				endif
			next nFile      
			
			cTmpDir := cDirCli + "jdbc\"   
									
			//Remove os arquivos JDBC antigos.
        	aEval( Directory( cBIFixPath( cTmpDir, "\" ) + "*.*" ), { |aFile| FERASE( cTmpDir + aFile[1]) } )
               
			//Copia os novos arquivos JDBC.
			for nFile := 1 to nQtdJDBC
				incProc(STR0006 + aJDBCFiles[nFile,1] + ".") //"Copiando arquvivo: "
				cFile	:=	cDirJDBC +  aJDBCFiles[nFile,1]
				
				if cpys2t(cFile,cTmpDir, .f.)
					conout(STR0007 + cFile + STR0008) 		//"Copia do arquivo: "###" realizada."
					nRet := 1
				else
					conout(STR0009 + cFile + ".") 			//"Erro ao copiar o arquivo: "
					nRet := 0
					break
				endif
			next nFile  
		endif
	endif
return nRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cGetArqCtrVer
Retorna a versao do arquivo de controle.
   
@param 		Arquivo de controle do cliente.
@author    	Alexandre Alves da Silva
@version   	P11
@since     	23/11/2006
/*/
//-------------------------------------------------------------------------------------
Static Function cGetArqCtrVer(cArquivo)
	local cVersao	:=	""
	local cLidos	:=	""
	local cBuffer	:=	""
	local nByteRead	:=	0
	local nArqSize	:=	0
	local oCliCont	:=	TBIFileIO():New(cArquivo) 
	local nPosIni	:=	0
	local nPosFin	:=	0
	
	if(oCliCont:lOpen(FO_SHARED))
		nArqSize:=	oCliCont:nSize()
		
		do while (nByteRead <  nArqSize )
			oCliCont:nRead(@cLidos,1024)
			cBuffer		+= cLidos
			nByteRead	+= 1024
		enddo
		oCliCont:lClose()
	endif
	
	nPosIni	:=	at("->", cBuffer)
	nPosFin	:=	at("<-", cBuffer)
	
	cVersao := subStr(cBuffer,nPosIni+2,nPosFin-(nPosIni+2))
return cVersao

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addMarca
Adiciona um marcador que será utilizado pelo Java para o tratamento de campos vazios.
   
@param 		Valor a ser marcado.
@author    	Valdiney V GOMES
@version   	P11
@since     	13/08/2011
/*/
//-------------------------------------------------------------------------------------
Static Function addMarca(cValor) 
	Local cMarcado	:= ""

	Default cValor 	:= ""  
	
	cMarcado := '|' + AllTrim( cValor ) + '|'
return cMarcado 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} iLog
Cria o log no console do servidor.
   
@param 		Título do log.  
@param 		Valores que serão logados no formato {{chave, valor}} .
@author    	Valdiney V GOMES
@version   	P11
@since     	13/08/2011
/*/
//-------------------------------------------------------------------------------------                    
Static Function iLog(cMensagem, aChaves)
	Local aLog 			:= {}
	
	Default cMensagem 	:= "" 
	Default aChaves 	:= {}     
	
	aAdd( aLog, DtoC( Date() ) + " " + Time() + " " + cMensagem )	                  
    aEval(aChaves, {|x| aAdd( aLog, x[1] + x[2] ) } )                 
return Conout( DwConcatWSep( CRLF + " .", aLog ) )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} getPais
Retorna o país de instalação do Protheus

@author		Marcia Junko
@version		P11
@since			19/04/2013
@return		cSiglaJava - Sigla do país da instalação para uso no Java
@obs			A informação retornada por esta função será utilizada no iReport
				para efetuar a formatação dos dados de data e valores conforme o
				país da instalação.
/*/
//-------------------------------------------------------------------------------------                    
Static Function getPais()
	Local aPaises		:= GetCountryList() // retorna a lista de países homologados do Protheus
	Local cPais		:= SuperGetMv( "MV_PAISLOC" , .F. , "BRA" ,  ) // pega o país de instalação do Protheus
	Local nPos			:= 0
	Local cSiglaJava	:= ""
	
	//----------------------------------------------------------------
	// Verifica se a estrutura do array aPaises já contem as posições 
	// referentes ao JAVA
	//----------------------------------------------------------------
	If Len(aPaises[1]) < 5
		//----------------------------------------------------------------
		// Se o GetCountryList não estiver atualizado realiza o 
		// tratamento no JAVA, pegando as informações do sistema 
		// operacional.  
		//----------------------------------------------------------------
		Return cSiglaJava
	Endif
	
	//----------------------------------------------------------------
	// Verifica as informações do JAVA na posição referente ao país.
	//----------------------------------------------------------------
	nPos := ascan(aPaises, {|x| x[1] == Upper(Alltrim(cPais))})
	If nPos > 0
		cSiglaJava	:= aPaises[nPos][5]
	Else
		//----------------------------------------------------------------
		// Se não encontrar o país no array utiliza a formatação padrão 
		// "Brasil"
		//----------------------------------------------------------------
		cSiglaJava	:= "BR"
	Endif
Return cSiglaJava

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} getIdioma
Retorna o idioma de instalação do Protheus
 
@author    	Marcia Junko
@@version		P11
@since			18/04/2013
@return		cIdiomaJava - Sigla do idioma da instalação para uso no Java 
@obs			A informação retornada por esta função será utilizada no iReport 
				para efetuar a formatação dos dados de data e valores conforme o 
				idioma da instalação.
				O retorno deve ser: "pt", "en" ou "es" sempre em minúsculo
/*/
//-------------------------------------------------------------------------------------                    
Static Function getIdioma()
Local cIdiomaJava := ""
Local cLang		  := FWRetIdiom()

	// Verifica o idioma instalado
	if cLang == "en"
		cIdiomaJava := "en"
	else
		if cLang == "es"
			cIdiomaJava := "es"
		else
			cIdiomaJava := "pt"
		endif
	endif
Return cIdiomaJava

Function __IReport_Run()
return nil