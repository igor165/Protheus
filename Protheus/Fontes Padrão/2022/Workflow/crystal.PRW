#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "SHELL.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "CRYSTAL.CH"

#DEFINE CRYSINI 	"CRYSINI.INI"  
#DEFINE CRWINI 	"CRWINI.INI" 
#DEFINE VERSION	"VERSION.CRW" 
#DEFINE SGCRYS32	"SGCRYS32.EXE"
     
#DEFINE CXLS		".XLS"
#DEFINE CPDF   	".PDF"
#DEFINE CTXT		".TXT"
#DEFINE CDOC 		".DOC" 

#DEFINE NPRINT2	2 
#DEFINE NPRINT3	3
#DEFINE NXLS		4 
#DEFINE NXLST		5
#DEFINE NPDF   	6
#DEFINE NTXT		7
#DEFINE NDOC 		8

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CallCrys
Chama um relatorio do Crystal Reports.
   
@param 		Nome do relatório.  
@param 		Parâmetros do relatório.
@param 		Configuração de impressão.  
	Onde:
	
	x 	 = Impressão em Vídeo(1), Impressora(2), Impressora(3), Excel(4), Excel Tabular(5), PDF(6), Texto (7) e Word (8).
	y 	 = Atualiza Dados(0) ou não(1)
	z 	 = Número de Cópias, para exportação este valor sempre será 1.
	w 	 = Título do Report, para exportação este será o nome do arquivo sem extensão.

@param 		Define se interrompe o processamento.
@param      lShowGauge Define se exibe o gauge de processamento.  
@param 		lRunOnServer Indica se a execução será realizada no servidor.   
@param		lExportFromServer Indica que o relatório gerado no servidor será exportado. 
@param		aTables Array: Define que as tabelas nele inclusas não receberão tratamento de filial e de deleção.
                   Formato:  {'tabela1', 'tabela2', 'tabela3' ...} Exemplo: {'SA1', 'SB1'}
@author    	Marcelo Bomura Abe 
@version   	P11
@since      21/03/96  
/*/
//-------------------------------------------------------------------------------------      
function CallCrys( cReportName, cParams, cOptions, lWaitRun, lShowGauge, lRunOnServer, lExportFromServer, aTables )
	local cUserPass   	:= ""
	local cParamsCom  	:= ""
	local cAliasOri   	:= Getarea()
	local cArqSX1     	:= ""
	local cArqSX2     	:= ""
	local cPathCrys   	:= SuperGetMV("MV_CRYSTAL")
	local cTitulo     	:= AllTrim( cReportName )
	local cString     	:= "SM2"
	local cTamanho    	:= "G"	
	local cCoordsCrys 	:= ""	
	local cCmd				:= ""	
	local cWnrel       	:= ""	
	local nLang       	:= 0
	local aOptions     	:= {}
	local aOrd        	:= {}
	local lExec			:= .F.  
	local pcFilial		:= StrTran( FWFilial(), " ", "*" )			//Filial
	local cUnidade		:= StrTran( FWUnitBusiness(), " ", "*" ) 	//Unidade de Negócio
	local cEmpresa		:= StrTran( FWCompany(), " ", "*" )		//Empresas
	local aParam        	:= {}  
	local aServerParam	:= {}   
	local aLixo			:= {}   
	local nArquivo		:= 0  
	local cInstallPath	:= cBIFixPath( GetPvProfString( GetEnvServer(), "CRWINSTALLPATH", "" , GetADV97() ), "\" )
	local cDeployPath		:= cBIFixPath( cPathCrys, "\" ) + "DEPLOY\"
	local cClientPath		:= cBIFixPath( GetClientDir(), "\" )
	local cUserPath		:= ""
	local dBuild			:= Nil
	local lUpdate			:= .F.
	local cHandle 		:= ""
	local cExtensao		:= ""
	local nDestino		:= 0
	local cArqCrwAuto 	:= "*" // Legado.
	local cSession 		:= ""  // Legado.
	Local cTables			:= ""  // Receberá as tabelas que não terão tratamento de filial e / ou deleção.
	Local nCnt				:= 0	// Contadora.
	Local cTempPath		:= Iif( GetRemoteType() == 2, "l:", "") + GetTempPath(.T.)
	Local cContent		:= ""
	Local cDBUser		:= ""
	Local cDBPsw		:= ""
	Local cMsg			:= ""
	
	Private aReturn   	:= { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1 }

	Default lWaitRun 	 			:= .F.
	Default lShowGauge   		:= .T.
	Default lRunOnServer 		:= .F.
	Default lExportFromServer	:= .F.
	Default aTables				:= {}

	//--------------------------------------------------
	// Verifica se o aTables recebido é do tipo array.
	//--------------------------------------------------
	If ValType( aTables ) == "A"
		If Len( aTables ) > 0
			//--------------------------------------------------
			// Alimenta o cTables com tabela1#tabela2#.....
			//--------------------------------------------------
			cTables := cBIConcatWSep( "#", aTables)
		EndIf
	Else
		MsgAlert( STR0012, STR0002 )  //"O Parâmetro aTables deve ser do tipo Array."##Protheus Crystal Integration"
		Return
	EndIf

    //--------------------------------------------------
	// Verifica se o ambiente de execução é suportado.
	// Caso seja SmartClient HTML não será suportado a menos que esteja rodando o crystal em servidor.
	//--------------------------------------------------
	If ( GetRemoteType() == 5 .And. !lRunOnServer )
		MsgAlert( STR0003, STR0002 )  //"A Integração com o Crystal no SmartClient HTML está disponível apenas para utilização em servidor!"##Protheus Crystal Integration"
		Return
	EndIf
	 
    //--------------------------------------------------
	// Verifica se o tem interface.  
	//--------------------------------------------------  	
	If ( ValType( oMainWnd ) == "O" )
		cHandle := Alltrim( Str( oMainWnd:hWnd, 20, 0) )
	EndIf

    //--------------------------------------------------
	// Verifica se o conteúdo do parâmetro MV_CRYSTAL foi informado.  
	//--------------------------------------------------   
	If !( Alltrim( cPathCrys ) == "")
		//--------------------------------------------------
		// Verifica se o relatório existe no caminho informado.
		//--------------------------------------------------     
		if ! ( File( cPathCrys + cTitulo + ".RPT" ) )
			MsgAlert( STR0004, STR0002 )  //"Relatório não encontrado no servidor!"##"Protheus Crystal Integration" 
			Return  
		Else
			//--------------------------------------------------
			// Identifica se a execução é no servidor.
			//--------------------------------------------------
			If ( lRunOnServer ) 
				//--------------------------------------------------
				// Cria um diretório exclusivo para o usuário no servidor.
				//--------------------------------------------------  
				cUserPath := cBIFixPath( cPathCrys, "\" ) + "EXEC\" + AllTrim( __cUserId )  + "\"  

				//--------------------------------------------------
				// Garante que o diretório estará criado no momento da execução.
				//--------------------------------------------------  
				WFForceDir( cUserPath )  
				
				//--------------------------------------------------
				// Limpa os arquivos gerados em execuções anteriores.
				//--------------------------------------------------  
				AEval( Directory( cUserPath + "*.*"), { |aArquivo| FErase( cUserPath + aArquivo[ 1 ] ) } )  
				
				//--------------------------------------------------
				// Garante as configurações necessárias estão disponíveis. 
				//--------------------------------------------------  
				If ( Empty( cInstallPath ) .Or. cInstallPath == "\" ) 
			   		MsgAlert( STR0007, STR0002) //"A chave CRWINSTALLPATH não está configurada no servidor!"##"Protheus Crystal Integration"
			   		Return 	 		
				EndIf
			EndIf 	
		EndIf

		//--------------------------------------------------
		// Garante que o diretório estará criado no momento da execução.
		//--------------------------------------------------  
		WFForceDir( cDeployPath ) 
	           
		If ! ( lRunOnServer )
			//--------------------------------------------------
			// Garante que o SGCRYS32 estará atualizado no smartclient. 
			//--------------------------------------------------  
			If ( File( cDeployPath + SGCRYS32 ) )
				If ( File( cClientPath + SGCRYS32 ) )  
			   		dBuild	:= Directory( cClientPath + SGCRYS32 )[1][3]  
		
				 	If ( File( cDeployPath + SGCRYS32 ) )                              
				 	 	lUpdate :=  ( Directory( cDeployPath + SGCRYS32 )[1][3] > dBuild ) 
				    EndIf 
				Else
					lUpdate := .T.
				EndIf  
				
				If ( lUpdate ) 
			   		lUpdate := .F.   
	
			   		If ( ":" $ cClientPath )
						If ( CpyS2T ( cDeployPath + SGCRYS32, cClientPath, .T. ) )
					 		QOut( STR0008 + cClientPath + SGCRYS32 ) //"Arquivo de integração com o Crystal Reports atualizado com sucesso no cliente: "
					 	Else
					 		QOut( STR0009 ) //"O arquivo SGCRYS32 não pôde ser atualizado no cliente!"##"Protheus Crystal Integration" 
					 	EndIf  
					EndIf
				EndIf		
			EndIf
		EndIf               

		//--------------------------------------------------
		// Exibe a tela de perguntas configurada para o relatório.
		//-------------------------------------------------- 
		If ( SX1->(DbSeek(cTitulo)) )
			Pergunte(cTitulo,.f.)
		Endif
		
		//--------------------------------------------------
		// Recupera as configurações de impressão para relatório.
		//-------------------------------------------------- 
		If (cOptions != Nil)			
			aOptions := aBIToken(cOptions, ";", .F.) 
			If Len(aOptions) <> 4
				aOptions := {}
			Endif			
		endif
		 
		//--------------------------------------------------
		// Recupera o idioma do sistema.
		//--------------------------------------------------      
		If __Language == 'SPANISH'
			nLang := "1"
		Else
			IF __Language == 'ENGLISH'
				nLang := "2"
			Else
				nLang := "0"
			EndIf
		EndIf 
		         
		//--------------------------------------------------
		// Recupera o usuário e senha do banco de dados.
		//-------------------------------------------------- 		
		#IFDEF TOP
			cUserPass := TCINTERNAL(2)
			//--------------------------------------------------------------------------------------
			// Tratamento caso o DBAccess não esteja retornando a senha de acesso ao banco de dados.
			//--------------------------------------------------------------------------------------
			If Right(cUserPass, 1) == '/'
				//--------------------------------------------------------------------------------------
				// Valida se a configuração já foi feita.
				//--------------------------------------------------------------------------------------
				If !File('\crystal\crysdb.ini') 
					If FindFunction("CrysConfig")
						cMsg := STR0013 + CRLF //"Por favor, entre em contato com o Administrador do sistema para executar a Integração Crystal."
					Else
						cMsg := STR0014 + CRLF //"Por favor, entre em contato com o Administrador do sistema para solicitar o pacote da função CrysConfig."
					EndIf
					
					//--------------------------------------------------------------------------------------
					// Chama a tela de mensagens
					//--------------------------------------------------------------------------------------
					CrysMsgDlg( cMsg )
					Return
				Else
					//--------------------------------------------------
					// Lê as informações do arquivo de configuração
					//-------------------------------------------------- 		
					cContent := MemoRead( '\crystal\crysdb.ini' )
					
					cDBUser := MemoLine( cContent, , 1 )
					cDBUser := BICrypt( cDBUser, 2  )
					
					cDBPsw := MemoLine( cContent, , 2 )
					cDBPsw := BICrypt( cDBPsw, 2  )

					cUserPass := cDBUser + '/' + cDBPsw
				EndIf
			EndIf     
			If (Valtype(cUserPass) = "N" .or. TcSrvType() = "AS/400")
				cUserPass := " "
			EndIf
		#ENDIF   
		
		//--------------------------------------------------
		// Recupera os parâmetros do usuário.
		//-------------------------------------------------- 
		If (cParams <> Nil)  
			If (cParams == "")
				cParamsCom := " "
			Else
			  	cParamsCom := cParams  
			EndIf
		Else
			cParamsCom := " "
		EndIf

		//--------------------------------------------------
		// Realiza a transferência do arquivo crysini.ini para as estações.	 
		//--------------------------------------------------  
     	CRWSingleConfig()  			

		//--------------------------------------------------
		// Identifica se deve exibir tela de impressão.
		//--------------------------------------------------   
		If (Len(aOptions) = 0)
			cWnrel := cTitulo
			cWnrel := setprint(cString,cWnrel,cTitulo,@cTitulo,"","","",.F.,aOrd,.f.,cTamanho,,.f.,.t.)
                                    
			cTitulo 	:= AllTrim( cTitulo ) 	//Título do relatório. 
			cArqSX1 	:= CrwSX1( cTitulo )  	//Nome do arquivo com informaçãoes do SX1. 
	   		cArqSX2 	:= CrwSX2( cEmpAnt )   //Nome do arquivo com informaçãoes do SX2. 

			If nLastKey == 27				
				SET FILTER TO
			Else          
				aAdd (aParam, cParametro( cPathCrys + cTitulo + ".RPT" ) ) 		//1Caminho  
				aAdd (aParam, cParametro( cTitulo ) )								//2Nome  
				aAdd (aParam, cParametro( alltrim( Str(aReturn[8],2,0) ) ) )	//3Ordem 
				aAdd (aParam, cParametro( "" ) ) 									//4Filtro 
				aAdd (aParam, cParametro( cEmpAnt ) ) 								//5Grupo de Empresa
				aAdd (aParam, cParametro( cTitulo ) ) 								//6Título
				aAdd (aParam, cParametro( str(aReturn[5],1,0) ) )  				//7Destino
				aAdd (aParam, cParametro( alltrim(str(aReturn[2],3,0)) ) ) 		//8Cópias
				aAdd (aParam, cParametro( cCoordsCrys ) )							//9Coordenadas?
				aAdd (aParam, cParametro( cHandle ) )  						    //10Handle
				aAdd (aParam, cParametro( aReturn[6] ) )  						//11Atualiza
				aAdd (aParam, cParametro( nLang ) ) 								//12Idioma
				aAdd (aParam, cParametro( cUserPass ) ) 							//13Senha
				aAdd (aParam, cParametro( cEmpresa ) ) 							//14Empresa
				aAdd (aParam, cParametro( cUnidade ) )  							//15Unidade
				aAdd (aParam, cParametro( pcFilial ) )  							//16Filial 
				aAdd (aParam, cParametro( cParamsCom ) )							//17Parâmetros
				aAdd (aParam, cParametro( cArqSX1 ) ) 								//18SX1
				aAdd (aParam, cParametro( cArqSX2 ) ) 								//19SX2
				aAdd (aParam, cParametro( cSession  ) )							//20
				aAdd (aParam, cParametro( getenvserver() ) ) 						//21Ambiente
				aAdd (aParam, cParametro( getadv97() ) )							//22Arquivo de configuração. 			
				aAdd (aParam, cParametro( cArqCrwAuto ) )	  						//23zArquivo de auto configuração.
				aAdd (aParam, cParametro( cBIStr ( lShowGauge ) ) )   			//24Mostra gauge?      
				aAdd (aParam, cParametro( cBIStr ( lRunOnServer ) ) )			//25Está rodando no servidor? 
				aAdd (aParam, cParametro( cUserPath ) )							//26Diretório do usuário.
				aAdd (aParam, cParametro( cTables ) ) 								//27 Tabelas exceção de tratamento.					                                                             
									
				cCmd 	:= "SGCRYS32 " + StrTran( cBIConcatWSep( "|", aParam), " ","*")
				lExec 	:= .T.                
			EndIf
		Else    
			cArqSX1 	:= CrwSX1( cTitulo ) 	//Nome do arquivo com informaçãoes do SX1.
	   		cArqSX2 	:= CrwSX2( cEmpAnt )   //Nome do arquivo com informaçãoes do SX2.

			aAdd (aParam, cParametro( cPathCrys+cTitulo +".RPT"))            //1Caminho                        
			aAdd (aParam, cParametro( cTitulo))                              //2Nome                           
			aAdd (aParam, cParametro( "1"))                                  //3Ordem                          
			aAdd (aParam, cParametro( ""))                                   //4Filtro                         
			aAdd (aParam, cParametro( cEmpAnt))                              //5Grupo de Empresa               
			aAdd (aParam, cParametro( aOptions[4]))                       	 	//6Título                         
			aAdd (aParam, cParametro( aOptions[1]))                     	 //7Destino                        
			aAdd (aParam, cParametro( aOptions[3]))                          //8Cópias                         
			aAdd (aParam, cParametro( cCoordsCrys ))                         //9Coordenadas?                   
			aAdd (aParam, cParametro( cHandle ) )  							 //10Handle                    
			aAdd (aParam, cParametro( aOptions[2]))                          //11Atualiza                      
			aAdd (aParam, cParametro( nLang))                                //12Idioma                        
			aAdd (aParam, cParametro( cUserPass))                            //13Senha                         
			aAdd (aParam, cParametro( cEmpresa))                             //14Empresa                       
			aAdd (aParam, cParametro( cUnidade))                             //15Unidade                       
			aAdd (aParam, cParametro( pcFilial))                             //16Filial                        
			aAdd (aParam, cParametro( cParamsCom))                           //17Parâmetros                    
			aAdd (aParam, cParametro( cArqSX1))                              //18SX1                           
			aAdd (aParam, cParametro( cArqSX2))                              //19SX2                           
			aAdd (aParam, cParametro( cSession ))     						 //20                              
			aAdd (aParam, cParametro( getenvserver()))                       //21Ambiente                      
			aAdd (aParam, cParametro( getadv97()))                           //22Arquivo de configuração. 	    
			aAdd (aParam, cParametro( cArqCrwAuto ) )                        //23zArquivo de auto configuração.
			aAdd (aParam, cParametro( cBIStr ( lShowGauge ) ) )   			 //24Mostra gauge?      
			aAdd (aParam, cParametro( cBIStr ( lRunOnServer ) ) )			 //25Está rodando no servidor? 
			aAdd (aParam, cParametro( cUserPath ) )							 //26Diretório do usuário.  
			aAdd (aParam, cParametro( cTables ) )								 // 27 Tabelas exceção de tratamento.	
			
           cCmd:= "SGCRYS32 " + StrTran( cBIConcatWSep( "|", aParam), " ","*")
			lExec := .T.
		EndIf		
		//--------------------------------------------------
		// Executa o aplicativo SGCRYS32.
		//--------------------------------------------------
		If (lExec)  
			//--------------------------------------------------
			// Identifica se a execução é no servidor.
			//--------------------------------------------------
			If ( lRunOnServer ) 
				aServerParam := aClone( aParam )  
				
				//--------------------------------------------------
				// Define um nome randômico para o relatório e Ajusta parâmetros de nome e título do relatório.
				//--------------------------------------------------	
				If ! ( lExportFromServer )
					cTitulo := CriaTrab( ,.F. ) 
					aServerParam[2] 	:= cTitulo  //Altera o nome do relatório.
					aServerParam[6] 	:= cTitulo  //Altera o título do relatório.	 
				EndIf
				 
				//--------------------------------------------------
				// Define que não será exibido o gauge.
				//--------------------------------------------------
				aServerParam[24] 	:= "F"
				
				//--------------------------------------------------
				// Define que será exportado para PDF quando for visualização ou impressão.
				//--------------------------------------------------   
				nDestino := nBIVal( aServerParam[7] )
				
				If ( nDestino <= 3 ) //1 - Tela, 2 e 3 Impressora.
					aServerParam[7] := NPDF 
				EndIf
                
              //--------------------------------------------------
				// Quando for exportação não gera o relatório no diretório do usuário.
				//--------------------------------------------------        
				If ( lExportFromServer )
					aServerParam[26] := "*"
				EndIf

				//--------------------------------------------------
				// Monta a linha de comando.
				//--------------------------------------------------			
			 	cCmd:= "SGCRYS32 " + StrTran( cBIConcatWSep( "|", aServerParam), " ","*")
  
				//--------------------------------------------------
				// Executa o SGCRYS32 no diretório do appserver.
				//--------------------------------------------------
				If ( WaitRunSrv( cCmd, .T., cBIFixPath( cInstallPath, "\" ) ) )  
					//--------------------------------------------------
					// Identifica se o relatório deve ser exportado ou exibido.
					//--------------------------------------------------
					If ! ( lExportFromServer )
						If ( nBIVal( aServerParam[7] ) == NXLS .Or. nBIVal( aServerParam[7] ) == NXLST )
							cExtensao := CXLS
						ElseIf ( nBIVal( aServerParam[7] ) == NPDF )
					     	cExtensao := CPDF
	          			ElseIf ( nBIVal( aServerParam[7] ) == NTXT )
	             			cExtensao := CTXT
						ElseIf ( nBIVal( aServerParam[7] ) == NDOC )
	     					cExtensao := CDOC
	          			EndIf
	
				   		//--------------------------------------------------
						// Verifica se o relatório foi criado.
						//--------------------------------------------------					
						If File( cUserPath + cTitulo + cExtensao )  
							//--------------------------------------------------
							// Copia o relatório para a estação.
							//--------------------------------------------------
						  	If ( CpyS2T ( cUserPath + cTitulo + cExtensao, cTempPath, .T. ) ) 
						  		//--------------------------------------------------
						  		// O Arquivo só será aberto ou enviado para impressora local se não vier do smartclientHTML.
						  		//--------------------------------------------------
						  		If !(GetRemoteType() == 5)						  		
						  			//--------------------------------------------------
									// Define se o arquivo será aberto ou enviado para impressora local.
									//--------------------------------------------------   
							  		If ( nDestino == NPRINT2 .Or. nDestino == NPRINT3 ) 
							  			If GetRemoteType() == 1    
								  	     	ShellExecute("Print", cBIFixPath( cTempPath, "\")  + cTitulo + cExtensao ,"" ,"" ,SW_HIDE )                                                              
							  	     	Else
								  			//-------------------------------------------------------
											// Se for Remote Linux\Mac força a execução via WaitRun
											//-------------------------------------------------------
							  	     		WaitRun("print", Lower( cTempPath + cTitulo + cExtensao) ,"" ,"" ,SW_HIDE )
							  	     	EndIf
							  		Else
							  			If GetRemoteType() == 1
							  				ShellExecute("Open", cBIFixPath( cTempPath, "\")  + cTitulo + cExtensao ,"" ,"" ,SW_SHOW )
							  			Else
								  			//-------------------------------------------------------
											// Se for Remote Linux\Mac força a execução via WaitRun
											//-------------------------------------------------------
							  				WaitRun("open " + Lower( cTempPath + cTitulo + cExtensao))
							  			EndIf
							  		EndIf
						  		EndIf
							Else
								MsgAlert( STR0010, STR0002 ) //"Não foi possível copiar o relatório para a estação!"##"Protheus Crystal Integration"	
						  	EndIf
						Else
							MsgAlert( STR0011, STR0002 ) //"Não foi possível executar o relatório solicitado!"##"Protheus Crystal Integration"
						EndIf 
					EndIf
				EndIf			
			Else 
				//--------------------------------------------------
				// Executa o SGCRYS32 no smartclient.
				//--------------------------------------------------
		  		If (lWaitRun)				
					WaitRun(cCmd, SW_MAXIMIZE)     
				Else
				    WinExec(cCmd)
				EndIf		
			EndIf 		
		EndIf 
	Endif    
	
	Restarea(cAliasOri) 
return     
  
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cParametro
Retorna o conteúdo gravado pelas funções CRWSX1 e CRWSX2 em formato de array.          

@param cDictionary Nome do arquivo gerado. 

@author    	Valdiney V GOMES
@version   	P11
@since      27/12/2012
/*/
//------------------------------------------------------------------------------------- 
Function CrwSX( cDictionary )
    Local aRecord 		:= {}
    Local cFile 		:= CurDir() + cDictionary   
    Local nHandle		:= 0   
       
	nHandle := FT_FUse( cFile )
   
	If ! ( nHandle == -1 )
		FT_FGoTop()
		
		While !FT_FEof()   
		   aAdd( aRecord, AllTrim( FT_FReadLn() ) )  
			FT_FSKIP()
		End  
		
		FT_FUse()
	EndIf
Return( aRecord )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CrwSX1
Cria um arquivo Txt com informações do SX1 para o Crystal.
   
@param 		Nome do relatório.    
@author    	Debaldo Pereira
@version   	P11
@since      28/12/00 
/*/
//------------------------------------------------------------------------------------- 
function CrwSX1( cNomeRel )
	local cArquivo	:= ""
	local nArqTxt 	:= ""
	local cDet    	:= ""
	local cDir    	:= ""
	local cCnt    	:= ""
	local cPresel 	:= ""
	local i       	:= 1
	Local nFtPrt		:= SuperGetMV("MV_CRFTPRT"	, .T.,  "1")

	If ! ( Empty( cNomerel ) )
		cArquivo := CriaTrab( NIL,.F. ) + ".TXT"
		nArqTxt  := FCreate(cDir + cArquivo)

		DbSelectArea("SX1")
		DbSetOrder(1)

		//-----------------------------------------------------------
		// Verifica se existe pergunta cadastrada para o relatório.
		//-----------------------------------------------------------
		If DbSeek( cNomerel )
			While !eof() .And. AllTrim(X1_GRUPO) == AllTrim(cNomeRel)
				If i < 10
					cNomePar := "MV_PAR0" + AllTrim(Str(i))
				Else
					cNomePar := "MV_PAR" + AllTrim(Str(i))
				EndIf

				//-----------------------------------------------------------
				// Recebe o parametro em tempo de executação. 
				//-----------------------------------------------------------
				cValPar := &cNomePar

				If ValType(cValPar) == "N"
					cValPar := AllTrim(Str(cValPar))
				ElseIf ValType(cValPar) == "D"
					Do Case
						Case nFtPrt == "1"
							//-----------------------------------------------------------
							// Converte para DD/MM/YY.
							//-----------------------------------------------------------
							cValPar := AllTrim(DtoS(cValPar))
							cValPar := "'" + Right(cValPar,2) + "/" + SubStr(cValPar, 5, 2) + "/" + SubStr(cValPar, 3, 2) + "'"
						Case nFtPrt == "2"
							//-----------------------------------------------------------
							// Converte data para YYYYMMDD (No protheus as datas são caracteres).
							//-----------------------------------------------------------
							cValPar := AllTrim(DtoS(cValPar))
						Case nFtPrt == "3"
							//-----------------------------------------------------------
							// Converte para DD/MM/YYYY.
							//-----------------------------------------------------------
							cValPar := AllTrim(DtoS(cValPar))
							cValPar := "'" + Right(cValPar,2) + "/" + SubStr(cValPar, 5, 2) + "/" + SubStr(cValPar, 1, 4) + "'"
					EndCase
				EndIf

				If (AllTrim(X1_GSC) <> "C")
					cCnt := cValPar
					cPreSel := "0"
				Else
					cCnt := ""
					cPreSel := cValPar
				EndIf
				
				//-----------------------------------------------------------
				// Monta formato que irá ser gravado no arquivo.
				//-----------------------------------------------------------
				cDet := AllTrim(X1_GRUPO) + ";" + AllTrim(cCnt) + ";" + AllTrim(X1_GSC) + ";" + SubStr(cPreSel,-1) + ";" + AllTrim(X1_ORDEM) + Chr(13) + Chr(10)
				FWrite(nArqtxt,cDet,len(cDet))
				i := i + 1
				DbSkip()
				loop
			EndDo
		EndIf
		FClose(nArqTxt)
	EndIf
return(cArquivo)
  
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CrwSX2
Cria um arquivo Txt com informações do SX2 para o Crystal.

@param 		Nome do relatório.       
@author    	Debaldo Pereira
@version   	P11
@since      28/12/00 
/*/
//------------------------------------------------------------------------------------- 
function CrwSX2( cGrupoEmpresa )		   		              
	Local cArquivo 	:= "CRWSX2" + AllTrim( cGrupoEmpresa ) + ".TXT"   	//Nome do arquivo contendo informações do SX2.
	Local nArquivo	:= 0             									//Handler do arquivo. 
	Local cRelacao 	:= ""              									//Conteúdo de cada linha do arquivo.  
	Local cLayout	:= FWSM0Layout()         
	Local cTable    := ""
	 	
	If ( File( cArquivo ) ) 
	     Return( cArquivo )
	EndIf    
	
	nArquivo := FCreate( cArquivo ) 
	
	DBSelectArea( "SX2" )
	DBGoTop()

	While !(  Eof() )

		cRelacao := alltrim( X2_ARQUIVO  )    //Arquivo.
		
		cTable   := SubStr( cRelacao,1,3 )   //Tabela
		
		cRelacao += ";"
		cRelacao += alltrim( FWSX2Util():GetPath( cTable ) )       //Path.
		cRelacao += ";"
		cRelacao += FWModeAccess( cTable,3 ) //Filial.
		cRelacao += ";"  
		cRelacao += FWModeAccess( cTable,2 ) //Unidade de Negócio.
		cRelacao += ";"  
		cRelacao += FWModeAccess( cTable,1 ) //Empresa. 
		cRelacao += ";"  
		cRelacao += alltrim( cLayout ) 	     //Layout.  		

		cRelacao += chr( 13 ) 
		cRelacao += chr( 10 )  
		
		FWrite( nArquivo, cRelacao, Len( cRelacao ) )
		DBskip()
		Loop
	EndDo    
	
	FClose( nArquivo )
Return( cArquivo )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CRWSingleConfig
Transfere os arquivos de configuração do servidor para estação.

@author    	Valdiney V GOMES
@version   	P11
/*/
//------------------------------------------------------------------------------------- 
function CRWSingleConfig()                                                                                                                    
	Local cPathStartup 	:= cBIFixPath(SuperGetMV("MV_CRYSTAL"),"\") + "STARTUP\"  //Local de origem do arquivo crisini.ini.
	Local cPathCli  	:= GetClientDir()			//Local de instalação do remote ou activex.
	Local cIni  		:= cPathStartup + CRYSINI	//Nome qualificado do arquivo crisini.ini.      
	Local cCrw 			:= cPathStartup + CRWINI	//Nome qualificado do arquivo crisini.ini.
	Local cFileVersion	:= cPathStartup + VERSION	//Nome qualificado do arquivo version.crw.
	Local cSever		:= ""						//Versão do Servidor.
	Local cClient		:= ""						//Versão do Client.
	Local lRet			:= .T.						//Retorno da função.
	Local oCrysIni		:= Nil						//Objeto do arquivo crisini.ini.
	Local oCrwIni		:= Nil						//Objeto do arquivo crwini.ini.
	Local oServer		:= Nil						//Objeto do arquivo version.crw do servidor.
	Local oClient  		:= Nil 			   			//Objeto do arquivo version.crw da estação.

	WFForceDir(cPathStartup)
	oCrysIni 	:= TBIFileIO():New(cIni)    
	oCrwIni 	:= TBIFileIO():New(cCrw)    	                                   
	
	If (oCrysIni:lExists())
		oServer := TBIFileIO():New(cFileVersion)
		oClient := TBIFileIO():New(cBIFixPath(cPathCli, "\") + VERSION)
         
		If (oServer:lExists())
			oServer:lOpen(FO_READ)
			oServer:nRead(@cSever,8)
		Else
			If oServer:lCreate()
				oServer:nWrite(cSever := DToS(Date())) 		
			EndIf
		EndIf
		
		If (oClient:lExists())
			oClient:lOpen(FO_READ)
			oClient:nRead(@cClient,8)
		EndIf
		
		oClient:lClose()  
		  
		If(SToD(cClient) < SToD(cSever))			                                        
			Processa( { || lRet := oCrysIni:lCopyFile(cBIFixPath(cPathCli, "\") + CRYSINI) }, STR0001 + CRYSINI ) // Transferindo   
			
			If ( oCrwIni:lExists() )  
				Processa( { || lRet := oCrwIni:lCopyFile(cBIFixPath(cPathCli, "\") + CRWINI) }, STR0001 + CRWINI ) // Transferindo 
			EndIf 
			
			If (lRet) 			
				Processa( { || lRet := oServer:lCopyFile(cBIFixPath(cPathCli, "\") + VERSION) }, STR0001 + VERSION) // Transferindo
			EndIf
		EndIf
						
		oServer:lClose()
		oCrysIni:lClose()
		oCrwIni:lClose()
	Endif
return lRet    

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} lCrysIni   
Cria o arquivo CrysIni padrão. 

@author    	Valdiney V GOMES
@version   	P11
@since      11/06/2013
/*/
//------------------------------------------------------------------------------------- 
Static Function CrysIni( cDiretorio )
	Local cIni 			:= ""     
	Local cRootPath		:= GetPvProfString( GetEnvServer(), "ROOTPATH", "", GetADV97() )
	Local cSystem			:= GetPvProfString( GetEnvServer(), "STARTPATH", "", GetADV97() )  
	Local cStartPath 		:= cBIFixPath( cRootPath, "\") + cSystem   
	Local cLogPath 		:= cBIFixPath( cRootPath, "\") + SuperGetMV("MV_CRYSTAL") + "\LOG\
	Local lRet				:= .T. 
  
	Default cDiretorio	:= ""  
	  
	//--------------------------------------------------
	// Garante que o diretório estará criado no momento da execução.
	//--------------------------------------------------  	   
	WFForceDir( cLogPath )
	
	//--------------------------------------------------
	// Monta a estrutura básica do arquivo.
	//--------------------------------------------------	
	cIni += "[PATH]"   	+ CRLF
	cIni += "SXS=" 		+ cStartPath 	+ CRLF
	cIni += "DATA=" 		+ cRootPath 	+ CRLF
	cIni += "LOG=" 		+ "1" 			+ CRLF
	cIni += "PATHLOG="	+ cLogPath 
	
	//--------------------------------------------------
	// Cria o arquivo, apenas se não existir no diretório.
	//--------------------------------------------------	
	If ! File( cBIFixPath( cDiretorio, "\") + CRWINI )
		lRet := MemoWrite ( cBIFixPath( StrTran( Upper( cDiretorio ), Upper( cRootPath ), "\" ) , "\") + CRYSINI, cIni ) 
	EndIf 
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} lCrwIni
Cria o arquivo CrwIni padrão. 

@author    	Valdiney V GOMES
@version   	P11
@since      11/06/2013
/*/
//------------------------------------------------------------------------------------- 
Static Function CrwIni( cDiretorio )
	Local cIni 		:= ""  
	Local lRet		:= .T.
	Local cRootPath	:= GetPvProfString( GetEnvServer(), "ROOTPATH", "", GetADV97() )    

	Default cDiretorio	:= "" 
	
	//--------------------------------------------------
	// Monta a estrutura básica do arquivo.
	//--------------------------------------------------		
	cIni += "[SXS]" 	+ CRLF
	cIni += "SX1=1" 	+ CRLF
	cIni += "SX2=1" 	

	//--------------------------------------------------
	// Cria o arquivo, apenas se não existir no diretório.
	//--------------------------------------------------
	If ! File( cBIFixPath( cDiretorio, "\") + CRWINI )
		lRet := MemoWrite ( cBIFixPath( StrTran( Upper( cDiretorio ), Upper( cRootPath ), "\" ), "\") + CRWINI, cIni ) 
	EndIf 
Return lRet  

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cParametro

@author    	Pedro Imai Gomes
@version   	P11
@since      27/12/2012
/*/
//------------------------------------------------------------------------------------- 
Static Function cParametro( cValor )
	Local cParametro	:= ""
	
	If ( Empty( AllTrim( cValor ) ) )
	 	cParametro := "*"
	Else
	  	cParametro := AllTrim( cValor )
	EndIf
Return cParametro 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CrysMsgDlg

Apresenta a tela de Mensagem ao usuário

@param cMsg, caracter, Mensagem a ser apresentada ao usuário
@author    	Marcia Junko
@version   	P12
@since      07/07/2019
/*/
//------------------------------------------------------------------------------------- 
Static Function CrysMsgDlg( cMsg )
	Local oDlg := Nil
	Local oPanel := Nil
	Local oSayLink := Nil
	Local oBtn
	
	//-------------------------------------------------------------------
	// Monta tela de login
	//-------------------------------------------------------------------
	DEFINE DIALOG oDlg TITLE STR0002 FROM 050, 051 TO 180, 580 PIXEL//"Protheus Crystal Integration"

    	@ 000, 000 MSPANEL oPanel OF oDlg SIZE 000,000 
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT
		
			@ 10,05 SAY cMsg OF oPanel PIXEL
			
			@ 25, 05 SAY oSayLink PROMPT STR0015 + "<b><a target='_blank' href='http://tdn.totvs.com/x/fMm5HQ'>" + STR0016 + "</a></b>" + ;
            "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>" OF oPanel PIXEL HTML //"Para mais informações, ### "acesse"
            
            oSayLink:bLClicked := {|| ShellExecute("open", 'http://tdn.totvs.com/x/fMm5HQ', "", "", 1) }
            
            @ 40, 200  BUTTON oBtn PROMPT STR0017 SIZE 50,15 ACTION (oDlg:End()) OF oPanel PIXEL //'Fechar'

	ACTIVATE DIALOG oDlg CENTERED 
	
Return
