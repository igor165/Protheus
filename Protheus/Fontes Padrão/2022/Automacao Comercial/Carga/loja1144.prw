#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1144.CH"

Static oTempTable	:= Nil //Objeto tabela temporaria

// O protheus necessita ter ao menos uma função pública para que o fonte seja exibido na inspeção de fontes do RPO.
Function LOJA1144() ; Return
                   

//-------------------------------------------------------------------
/*/{Protheus.doc} LJCInitialLoadLoader

Classe responsável por efetuar a baixa, descompactação e importação
das tabelas disponibilizadas pelo servidor de carga.  

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Class LJCInitialLoadLoader
	Data oGroup
	Data cWebFileServer
	Data cTempPath
	Data cPath
	Data aoObservers
	Data oProgress
	Data lKillOtherThreads
	Data nExtFile
	
	Method New()
	Method Download()
	Method Import()
	Method IsTableShared()
	Method CheckPath()
	Method Decompress()
	Method AddObserver()
	Method ImportComplete()
	Method ImportPartial()
	Method ImportSpecial()
	Method Notify()
	Method Update()
	Method KillOtherThreads()
	Method ImportRecord()
	Method UpdateEnvironmentStatus()
	Method LjCSVToAli()
	Method DelImportedFiles()
	Method LjCSVDelFile()
	Method DownloadZip()
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New()

Construtor
  
@param oGroup Instância da classe LJCInitialLoadGroupConfig com as
informações dos dados disponibilazados pelo servidor de carga.  
@param cWebFileServer URL do servidor de arquivos para a execução da baixa
dos arquivos. 
@param cTempPath Diretório temporário de descompactação. 
@param cPath Diretório onde ficarão armazenados as tabelas compactadas
@param lKillOtherThreads .T. para se necessário derrubar os processos, .F. não

@return Self

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method New( oGroup, cWebFileServer, cTempPath, cPath, lKillOtherThreads ) Class LJCInitialLoadLoader
	Self:aoObservers		:= {}
	Self:oGroup 			:= oGroup
	Self:cWebFileServer		:= cWebFileServer
	Self:cTempPath			:= cTempPath
	Self:cPath				:= cPath
	Self:oProgress			:= LJCInitialLoadProgress():New(,1)
	Self:lKillOtherThreads	:= lKillOtherThreads
	Self:nExtFile			:= SuperGetMV("MV_LJTFILE",.F.,0)
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} Download()

Efetua o download da carga.  

@return Nenhum

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method Download() Class LJCInitialLoadLoader
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local nCount		   		:= 1
	Local aoFiles				:= {}
	Local aTableList			:= {}
	Local nPos					:= 0
	Local oFactory			:= LJCInitialLoadSpecialTableFactory():New()
	Local cBranch				:= ""
	Local cNameFile				:= ""
		
	// Informa o início do processamento de carga
	Self:oProgress:nStep := 2
	LjGrvLog( "Carga","Download Inicio processamento ")
	Self:Notify()
	
	// Efetua o download dos arquivos que compõem a carga inicial		
	If !oLJCMessageManager:HasError()
	
		// Informa o início da baixa da carga
		Self:oProgress:nStep := 3
		LjGrvLog( "Carga","Download Baixa do arquivo ")
		Self:Notify()
		
		If Len( Self:oGroup:oTransferFiles:aoFiles ) > 0
			Self:CheckPath()		
			If !oLJCMessageManager:HasError()
				oComunication := LJCFileDownloaderComunicationHTTP():New( Self:cWebFileServer, Self:oGroup:cCode  )	
				oDownloader := LJCFileDownloader():New( oComunication, Self:cTempPath, Self:cPath )			
				oDownloader:AddObserver( Self )
		
						
				// Cria a lista dos arquivos que serão baixados, somente são baixados os arquivos que interessam a essa filial (tabelas compartilhadas, tabelas exclusivas para essa filial ou transferências parciais no qual não há filial definida).
				For nCount := 1 To Len( Self:oGroup:oTransferFiles:aoFiles )
					nPos := AScan( Self:oGroup:oTransferTables:aoTables, {|x| x:cTable == Self:oGroup:oTransferFiles:aoFiles[nCount]:cTable } )
					If nPos > 0 .And. Lower(GetClassName( Self:oGroup:oTransferTables:aoTables[nPos] )) == Lower("LJCInitialLoadSpecialTable")
						cBranch := oFactory:GetXFilialByName( Self:oGroup:oTransferFiles:aoFiles[nCount]:cTable )
					Else
						cBranch := xFilial( Self:oGroup:oTransferFiles:aoFiles[nCount]:cTable )				
					EndIf
					
					If Self:oGroup:oTransferFiles:aoFiles[nCount]:IsForBranch( cBranch )
						aAdd( aoFiles, Self:oGroup:oTransferFiles:aoFiles[nCount] )
						aAdd( aTableList, Self:oGroup:oTransferFiles:aoFiles[nCount]:cTable )
					EndIf
				Next     
		
		
				Self:oProgress:oFilesProgress := LJCInitialLoadFilesProgress():New( aTableList )
				For nCount := 1 To Len( aoFiles )	
					Self:oProgress:oFilesProgress:nActualFile := nCount
					Self:Notify()
					cNameFile := aoFiles[nCount]:GetFile()
					If !oLJCMessageManager:HasError()
						If Self:nExtFile == 1
							Self:DownloadZip(oComunication, oDownloader, cNameFile)
						Else
							oDownloader:Download( cNameFile ) 
							If oLJCMessageManager:HasError()
								Exit
							EndIf
						EndIf
					Else
						Exit
					EndIf
				Next
			EndIf
		Else
			oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderInvalidRequest", 1, STR0001 ) ) // "Não há arquivos na lista de download."
		EndIf	
	EndIf	
	
	// Se houver algum erro informa.
	If !oLJCMessageManager:HasError()
		Self:oProgress:nStep := 5
		Self:Notify()	
	EndIf	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Import()

Efetua a importação da carga baixada para o banco de dados

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method Import() Class LJCInitialLoadLoader
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local nCount				:= 1
	Local oLJCGlobalLocker	:= LJCGlobalLocker():New()	
	Local aoFiles				:= {}	
	Local aTableList			:= {}
	Local nPos					:= 0
	Local oFactory				:= LJCInitialLoadSpecialTableFactory():New()
	Local cBranch				:= ""
	Local cHrIni				:= "" //Hora Inicial da Carga
	Local dDateIni				:= "" //Data Inicial da Carga

	// Informa o início do processamento de carga
	Self:oProgress:nStep := 2
	LjGrvLog( "Carga","Import Inicio do processo ")
	Self:Notify()

	// Atualiza o banco de dados		                                        	
	If !oLJCMessageManager:HasError()		
		Self:oProgress:nStep := 4
		Self:Notify()                           
		
		LjGrvLog( "Carga","Import Cria lista de arquivos a atualizar ")
		// Cria a lista dos arquivos que serão importados, somente são importados os arquivos que interessam a essa filial (tabelas compartilhadas, tabelas exclusivas para essa filial ou transferências parciais no qual não há filial definida).
		For nCount := 1 To Len( Self:oGroup:oTransferFiles:aoFiles )
			nPos := AScan( Self:oGroup:oTransferTables:aoTables, {|x| x:cTable == Self:oGroup:oTransferFiles:aoFiles[nCount]:cTable } )
			If nPos > 0 .And. Lower(GetClassName( Self:oGroup:oTransferTables:aoTables[nPos] )) == Lower("LJCInitialLoadSpecialTable")
				cBranch := oFactory:GetXFilialByName( Self:oGroup:oTransferFiles:aoFiles[nCount]:cTable )
			Else
				cBranch := xFilial( Self:oGroup:oTransferFiles:aoFiles[nCount]:cTable )				
			EndIf
			
			If Self:oGroup:oTransferFiles:aoFiles[nCount]:IsForBranch( cBranch )
				aAdd( aoFiles, Self:oGroup:oTransferFiles:aoFiles[nCount] )
			EndIf
		Next     
			
		LjGrvLog( "Carga","Import Cria lista de tabelas a atualizar ")
		For nCount := 1 To Len( Self:oGroup:oTransferTables:aoTables )
			aAdd( aTableList, Self:oGroup:oTransferTables:aoTables[nCount]:cTable )
		Next
			
		// Verifica se os arquivos informados no oGroup existem, ou seja, já forma baixados.
		LjGrvLog( "Carga","Import Verifica se a carga já foi baixada ")
		For nCount := 1 To Len( aoFiles )
			If !File( Self:cPath + IIF(Self:nExtFile == 0, aoFiles[nCount]:GetFile(), SubStr(aoFiles[nCount]:GetFile(), 1, At(".", aoFiles[nCount]:GetFile()) - 1) + "_1.zip" ))
				oLJCMessageManger:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoader", 1, STR0008) ) // "Não é possível importar porque a carga não foi baixada."
				Exit
			EndIf
		Next
			
		If !oLJCMessageManager:HasError()	
			Self:oProgress:oTablesProgress := LJCInitialLoadTablesProgress():New( aTableList )
			Self:oProgress:oTablesProgress:nStatus := 1
			
			// Descompacta os arquivos
			LjGrvLog( "Carga","Import Descompacta os arquivos ")	
			For nCount := 1 To Len( aoFiles )
				Self:oProgress:oTablesProgress:nActualTable := aScan( Self:oGroup:oTransferTables:aoTables, { |x| x:cTable == aoFiles[nCount]:cTable } )
				Self:oProgress:oTablesProgress:nStatus := 2
				Self:Notify()		
				Self:Decompress( aoFiles[nCount]:GetFile() )
				If oLJCMessageManager:HasError()
					Exit
				EndIf
			Next
				
			If !oLJCMessageManager:HasError()
				// Carga incremental não precisa de trava. - As travas são utilizadas durante a importação para tentar parar processos que podem estar sendo executados e que impossibilitem a abertura exclusiva das tabelas. Cada nome de lock equivale a um processo conhecido que utiliza o sistema de travas para verificar se devem parar, ou se deve continuar as suas execuções.				
				If Self:oGroup:cEntireIncremental == '2' .OR. oLJCGlobalLocker:MultiWaitGetLock( { "LOJA1115ILLock", "LOJA701AILLock", "LOJXFUNCILLock", "FRTA020ILLock" } )
					
					
					
					Sleep( 1000 ) // Dá um tempo para algum processo se derrubar
					Self:oProgress:oTablesProgress:nStatus := 3
					
					For nCount := 1 To Len( Self:oGroup:oTransferTables:aoTables )

						Self:oProgress:oTablesProgress:nActualTable := nCount
						Self:Notify()
						cHrIni				:=  Time()
						dDateIni			:= date()
						
						LjGrvLog( "Carga","Processando tabela " + GetClassName(Self:oGroup:oTransferTables:aoTables[nCount]) + " Inicio " + Dtoc(dDateIni) + " - " + cHrIni)
		
						If Lower(GetClassName( Self:oGroup:oTransferTables:aoTables[nCount] )) == Lower("LJCInitialLoadCompleteTable")
							Self:ImportComplete( Self:oGroup:oTransferTables:aoTables[nCount] )
						ElseIf Lower(GetClassName( Self:oGroup:oTransferTables:aoTables[nCount] )) == Lower("LJCInitialLoadPartialTable")
							Self:ImportPartial( Self:oGroup:oTransferTables:aoTables[nCount] )
						ElseIf Lower(GetClassName( Self:oGroup:oTransferTables:aoTables[nCount] )) == Lower("LJCInitialLoadSpecialTable")
							Self:ImportSpecial( Self:oGroup:oTransferTables:aoTables[nCount] )
						EndIf	
						
						LjGrvLog( "Carga","Processado tabela " + GetClassName(Self:oGroup:oTransferTables:aoTables[nCount]) + " Inicio " + Dtoc(date()) + " - " + Time()  + " Tempo  gasto : " +elaptime(cHrIni, time()))
									
					Next
					
					Self:oProgress:oTablesProgress:nStatus := 4
				Else
					oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoader", 1, STR0009 ) ) // "Não foi possível obter as travas para a abertura exclusiva das tabelas."
				EndIf
				
				
				
				If oLJCMessageManager:HasError()
					Self:oProgress:oTablesProgress:nStatus := 5
					LjGrvLog( "Carga","Import erro ao importar arquivos ")	
				Else
					LjGrvLog( "Carga","Import Carga Realizada com Sucesso ")
					Self:DelImportedFiles()			
				EndIf
			EndIf
		EndIf
	EndIf 
	
	// Se houver algum erro informa.
	If !oLJCMessageManager:HasError()		
		Self:oProgress:nStep := 5
		Self:Notify()
	EndIf			
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} IsTableShared()

Verifica no SX2 se a tabela compartilha filial
  
@param cTableName Nome da tabela  

@return lRet .T. tabela compartilhada, .F. tabela exclusiva. 

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method IsTableShared( cTableName ) Class LJCInitialLoadLoader
	Local lRet				:= .F.                        
	Local oLJCMessageManager	:= GetLJCMessageManager()

	DbSelectArea( "SX2" )
	If DbSeek( cTableName )
		If AllTrim(Upper(FWModeAccess(FWX2Chave(),3))) == "C"
			lRet := .T.
		EndIf
	Else
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJInitialLoadInvalidTableName", 1, STR0002 + " " + Self:cTableName + " " + STR0003 ) ) // "Tabela" "não existe no SX2."
	EndIf	
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} ImportComplete()

Faz importação de tabelas de transferência completa.
  
@param oCompleteTable Objeto ipo LJCInitialLoadCompleteTable.      

@return Nenhum

@author Vendas CRM
@since 16/10/10
/*/
//--------------------------------------------------------------------
Method ImportComplete( oCompleteTable ) Class LJCInitialLoadLoader
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local nCount				:= 0
	Local nCount2				:= 0
	Local cFileName				:= ""
	Local lRenewTimer			:= .T.
	Local nSecond1				:= 0
	Local nSecond2				:= 0
	Local nRecordsProcessed		:= 0
	Local _nRecord				:= 0
	Local lLJ1144Im				:= ExistBlock( "LJ1144Im" )
	Local lExclusiveOpenned		:= .F.
	Local aDir					:= {}
	Local cTablePrefix	 		:= If(SubStr(oCompleteTable:cTable,1,1) == "S", SubStr(oCompleteTable:cTable,2,3), oCompleteTable:cTable)
	Local cIndexKey				:= ""
	Local aPartial				:= {}
	Local aTRB					:= {}
	Local nPos					:= 0 
	Local aStructDest			:= {}
	Local aCampos				:= {}
	Local lOpenCSV				:= SuperGetMV("MV_LJGECSV",,"0") $ "12" //geracao de CSV 0 - Não gera, 1 - gera dbf/csv, 2 - somente csv 
	Local lSQLite 				:= AllTrim(Upper(GetSrvProfString("RpoDb",""))) == "SQLITE" //PDVM/Fat Client
	Local cTable				:= "" //tabela a ser importada
	Local cAlias				:= "" //Alias
	Local cHrIni				:= Time() //Hora Inicial
	Local dDataIni				:= Date()//Data Inicial
	Local lFieldMsExp			:= .f. //Existe o campo MSEXP?
	Local nTamKeyLocal    		:= 0      //Tamanho da chave de Pesquisas Locais
	Local nTamKeyCarga			:= 0      //Tamanho da chave de Pesquisa do arquivo de carga 
	Local lContinua				:= .T.    //Controle de fluxo
	Local cDeleted				:= "DEL" //Campo deletado para temporario. padroa DBF
	Local lExiste				:= .T.
	Local nContador				:= 1

	LjGrvLog( "Carga","ImportComplete Inicio ")
	LjGrvLog( "Carga","P.E LJ1144Im " ,lLJ1144Im )
	
	//Se for CTREE o campo deletado para temporario devera ser outro.
	If Upper(AllTrim(Self:oGroup:cDriver)) == "CTREECDX"
		cDeleted := "D_E_L_E_T_E_D_"
	EndIf
		
	// Abre e fecha a tabela para garantir que ela será criada no banco de dados caso não exista.
	DbSelectArea( oCompleteTable:cTable )		
	DbCloseArea() 
	
	//se for carga inteira abre em modo exclusivo - Se for incremental abre em modo compartilhado
	If Self:oGroup:cEntireIncremental == '1'	
		// Se conseguir pegar as travas e mesmo assim não for possível abrir a tabela em modo exclusivo, se for desejado derruba os processos em execução.						
		If ChkFile( oCompleteTable:cTable, .T. )
			lExclusiveOpenned := .T.
		Else
			If Self:lKillOtherThreads
				// Mata outras threads ativas da máquina
				Self:KillOtherThreads()	
				
				Sleep( 2000 )
			EndIf
			
			If ChkFile( oCompleteTable:cTable, .T. )
				lExclusiveOpenned := .T.
			Else
				lExclusiveOpenned := .F.
			EndIf			
		EndIf
		LjGrvLog( "Carga","Modo de abertura da tabela ", lExclusiveOpenned )
	EndIf
		
	If !oLJCMessageManager:HasError()
	
		//Se abrir a tabela em modo exclusivo, ou se for carga incremental e abriu a tabela em modo compartilhado
		If (lExclusiveOpenned .OR. (Self:oGroup:cEntireIncremental == '2' .AND. ChkFile( oCompleteTable:cTable, .F. )))
							
			DbSelectArea(oCompleteTable:cTable)
		
			For nCount := 1 To Len( oCompleteTable:aBranches )
				If Empty( xFilial( oCompleteTable:cTable ) ) .Or. Empty( oCompleteTables:aBranches[nCount] ) .Or. xFilial( oCompleteTable:cTable ) == oCompleteTables:aBranches[nCount]
					If lSQLite 
						If Self:nExtFile == 1
							cFileName := Self:cPath + oCompleteTable:cTable + cEmpAnt + AllTrim(oCompleteTable:aBranches[nCount]) + "_1.csv"
						Else
							cFileName := Self:cPath + oCompleteTable:cTable + cEmpAnt + AllTrim(oCompleteTable:aBranches[nCount]) + ".csv"
						EndIf
						lOpenCSV := .T.
					Else
						cFileName := Self:cPath + oCompleteTable:cTable + cEmpAnt + AllTrim(oCompleteTable:aBranches[nCount]) + Self:oGroup:cExtension
					EndIf
					
					LjGrvLog( "Carga","cFileName " , cFileName)
					If File(cFileName)
						// Abre a area com o arquivo novo
						If !lOpenCSV
							DbUseArea(.T., Self:oGroup:cDriver, cFileName, "TRB", .F., .F.)					 
						Else
							If lSQLite
								If Self:nExtFile == 1
									nContador := 1
									While lExiste
										Self:LjCSVToAli(cFileName, oCompleteTable:cTable,"TRB",Self:oGroup:cEntireIncremental != '1',,nContador)
										nContador++
										cFileName := SubStr(cFileName, 1, Len(cFileName) - 5) + AllTrim(Str(nContador)) + ".csv"
										If !File(cFileName)
											lExiste := .F.
										EndIf
									End
								Else
									Self:LjCSVToAli(cFileName, oCompleteTable:cTable,"TRB",Self:oGroup:cEntireIncremental != '1')
								EndIf
							EndIf 
						EndIf
						
						If Used()
						
							If !lOpenCSV .OR. (lOpenCSV .AND. lSQLite )
								Self:oProgress:oTablesProgress:nTotalRecords := TRB->(RecCount())
							EndIf
							
							// se for carga inteira, limpa o banco de dados
							If Self:oGroup:cEntireIncremental == '1'	

								If !lSQLite
									(oCompleteTable:cTable)->(__DbZap())
								Else
									(oCompleteTable:cTable)->(DbCloseArea())
									cAlias				:= oCompleteTable:cTable
									cTable := RetSqlName(cAlias) 
									USE (cTable) ALIAS (cAlias) EXCLUSIVE NEW VIA "SQLITE_SYS"
									If !NetErr()
										(cAlias)->(__DbZap())
										(cAlias)->(DbCloseArea())
									Else
										oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderFieldDoesntExist", 1, "Erro ao deletar registros da tabela " + cAlias ) )  //  "Campos necessários para a Carga Incremental não existem. Verifique se os campos " + cTablePrefix + "_MSEXP" + " e " + cTablePrefix + "_HREXP existem."
										Exit
									EndIf
								EndIf
							EndIf

							DbSelectArea( oCompleteTable:cTable )
							DbSetOrder( 1 )

							If (oCompleteTable:cTable) == "DA1"
								cIndexKey := GetSx2Unico(oCompleteTable:cTable)
							ElseIf (oCompleteTable:cTable) == "CLK"
								cIndexKey := (oCompleteTable:cTable)->(IndexKey(3))
							Else
								cIndexKey := (oCompleteTable:cTable)->(IndexKey(1))
							EndIf

							lFieldMsExp := 	(oCompleteTable:cTable)->(FieldPos(cTablePrefix + "_MSEXP")) > 0  .AND. (oCompleteTable:cTable)->(FieldPos(cTablePrefix + "_HREXP")) > 0 	
							 
							If !lOpenCSV .OR. (lOpenCSV .AND. lSQLite )
		
								//melhora na performance
								aPartial:= {}
								( oCompleteTable:cTable )->(DbGoTop())
								While ( oCompleteTable:cTable )->(!EOF())
									If nTamKeyLocal == 0
										nTamKeyLocal := Len((oCompleteTable:cTable )->(&cIndexKey))
									EndIf
									If (oCompleteTable:cTable )->(&cIndexKey) <> NIL
										aAdd(aPartial,{(oCompleteTable:cTable )->(&cIndexKey),(oCompleteTable:cTable)->(RECNO())})
									EndIf
									(oCompleteTable:cTable )->(DbSkip())
								End	
								ASORT(aPartial, , , { | x,y | x[1] < y[1] } )		
					
								aTRB := {}
								TRB->(DbGoTop()) 
								While TRB->(!EOF())
									If nTamKeyCarga == 0
										nTamKeyCarga := Len(TRB->(&cIndexKey))
									EndIf
									If TRB->(&cIndexKey) <> NIL 
										aAdd(aTRB,{TRB->(&cIndexKey),TRB->(RECNO()) , TRB->(&cDeleted) })
									EndIf	
									TRB->(DbSkip())
								End					
								ASORT(aTRB, , , { | x,y | x[3]+x[1] > y[3]+y[1] } )
								
								//Compara o tamanha das chaves de pesquisa da base local
								//Com a recebida da retaguarda na carga.
								//Se for diferente significa que uma base está diferente da outra.
								//Podendo gerar registros duplicados da base 
								If nTamKeyLocal > 0 .AND. nTamKeyCarga > 0 .AND. (nTamKeyLocal <> nTamKeyCarga)
									LjGrvLog( "Carga", STR0016 + ": " + ( oCompleteTable:cTable ) )
									Conout( STR0016 + ": " + ( oCompleteTable:cTable ) )
									oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderBasesDifferences", 1, STR0016 + ": " +  ( oCompleteTable:cTable ) ) ) // "Tamanho dos Campos PDV x Retaguarda divergentes. Valide o tamanho dos campos da tabela"
									lContinua := .F. //Controla o fluxo para nao duplicar registros
								EndIf
								 
								LjGrvLog( "Carga", "Registros a serem importados para a tabela : " + ( oCompleteTable:cTable ) + " : " + Alltrim(Str(Len(aTRB))))
				
								aStructDest	:= ( oCompleteTable:cTable ) -> (DBStruct())
								For nCount2 := 1 To Len(aStructDest)	
									aAdd(aCampos,{aStructDest[nCount2][1],TRB->(FieldPos(aStructDest[nCount2][1])) ,(oCompleteTable:cTable) ,(oCompleteTable:cTable)->(FieldPos( aStructDest[nCount2][1]))})
								Next nCount2
															
								cHrIni					:= Time()
								dDataIni				:= Date()	
								
								LjGrvLog( "Carga","Inserindo registros " + oCompleteTable:cTable + " Inicio " + Dtoc(dDataIni) + " Hora " + cHrIni)
			
								For _nRecord := 1 to Len(aTRB) 	
					
									If lLJ1144Im																				
										TRB->(dbGoto(aTRB[_nRecord][2])) //Posicionado no registro para o PE avaliar se descarta
										If ExecBlock( "LJ1144Im", .F., .F., { oCompleteTable:cTable, oCompleteTable:aBranches[nCount] } )
											Loop
										EndIf
									EndIf
						
									If lRenewTimer
										nSecond1			:= Seconds()
										nRecordsProcessed	:= 0
										lRenewTimer 		:= .F.
									EndIf
			
									If lContinua .AND. Self:oGroup:cEntireIncremental == '1'	 
										TRB->(dbGoto(aTRB[_nRecord][2]))
										
										LjGrvLog( "Carga","Carga inteira tabela" + oCompleteTable:cTable )
										Self:ImportRecord(oCompleteTable:cTable, 	"TRB", 	.T., 	/*aStruct*/,;
																/*aCampos*/,			/*lSTDStartProd*/) // .T. -> inclusao 
										
									ElseIf lContinua //se for carga incremental (obrigatoriamente a tabela deve conter pelo menos um indice)
										
										If lFieldMsExp //protecao - valida se os campos MSEXP e HREXP existem nas tabelas que receberao a carga
					
											nPos := aScan(aPartial,{|x|,x[1] ==  aTRB[_nRecord][1]} )   //procura se o registro ja existe
											If nPos > 0 
	
												(oCompleteTable:cTable)->(dbGoto(aPartial[nPos][2]))
												TRB->(dbGoto(aTRB[_nRecord][2]))
	
												// Compara MSEXP da carga com ambiente local (impede aplicar carga desatualizada)
												If Empty((oCompleteTable:cTable)->(&(cTablePrefix + "_MSEXP")) ) .OR. ( ( TRB->(&(cTablePrefix + "_MSEXP")) + TRB->(&(cTablePrefix + "_HREXP")) ) > ( (oCompleteTable:cTable)->(&(cTablePrefix + "_MSEXP")) + (oCompleteTable:cTable)->(&(cTablePrefix + "_HREXP")) ) ) 
													//Conout(" chave TRB" + aTRB[_nRecord][1] + " update ")
													Self:ImportRecord(oCompleteTable:cTable, "TRB", .F., 	/*aStruct*/,;
																/*aCampos*/,			/*lSTDStartProd*/) // .F. -> alteracao
												EndIf
											Else	//Se nao existir o registro insere ele
												TRB->(dbGoto(aTRB[_nRecord][2]))
												//Conout(" chave TRB" + aTRB[_nRecord][1] + " insert")
												Self:ImportRecord(oCompleteTable:cTable, "TRB", .T., 	/*aStruct*/,;
																/*aCampos*/,			/*lSTDStartProd*/) // .T. -> inclusao
											EndIf
	
										   If nPos > 0 .and. !lSQLite
										   	   aDel(aPartial,nPos)
											   aSize(aPartial, Len(aPartial)-1)
											EndIf										   

										   LjGrvLog( "Carga", "Tamanho do Array de Busca : " + Alltrim(Str(Len(aPartial))))
											
										Else //protecao - valida se os campos MSEXP e HREXP existem nas tabelas que receberao a carga
											oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderFieldDoesntExist", 1, STR0010 + cTablePrefix + "_MSEXP" + STR0011 + cTablePrefix + "_HREXP " + STR0012 ) )  //  "Campos necessários para a Carga Incremental não existem. Verifique se os campos " + cTablePrefix + "_MSEXP" + " e " + cTablePrefix + "_HREXP existem."
											Exit
										EndIf	
																				
									EndIf
						
									nSecond2 := Seconds()
						
									If nSecond2 - nSecond1 >= 1
										lRenewTimer := .T.
										// Reporta o progresso
										Self:oProgress:oTablesProgress:nRecordsPerSecond := Int(nRecordsProcessed / (nSecond2-nSecond1))
										Self:oProgress:oTablesProgress:nActualRecord := _nRecord
										Self:Notify()				
									EndIf
						
									nRecordsProcessed++
								Next 

								_nRecord := _nRecord - 1   	

							Else
							 	LjGrvLog( "Carga", "Carga em CSV ")

								If lFieldMsExp .Or. Self:oGroup:cEntireIncremental == '1' //Se não for completa checo os campos data e hora de exportação	

									Self:LjCSVToAli(cFileName, oCompleteTable:cTable, (oCompleteTable:cTable), .F.,Self:oGroup:cEntireIncremental == '2')

								Else //protecao - valida se os campos MSEXP e HREXP existem nas tabelas que receberao a carga
									oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderFieldDoesntExist", 1, STR0010 + cTablePrefix + "_MSEXP" + STR0011 + cTablePrefix + "_HREXP " + STR0012 ) )  //  "Campos necessários para a Carga Incremental não existem. Verifique se os campos " + cTablePrefix + "_MSEXP" + " e " + cTablePrefix + "_HREXP existem."
								EndIf 
								
								nRecordsProcessed := 1
								nSecond2 := Seconds()
								nSecond1 := Seconds()
								_nRecord := ( oCompleteTable:cTable)->(Recno()) 
									
							EndIf
				
							LjGrvLog( "Carga","Inserido registros " + oCompleteTable:cTable + " Inicio " + Dtoc(dDataIni) + " Hora " + cHrIni + " Tempo gasto " + Elaptime(cHrIni, time()))
				
							// Reporta o progresso
							Sleep(1000)
							Self:oProgress:oTablesProgress:nRecordsPerSecond := Int(nRecordsProcessed / (nSecond2-nSecond1))
							Self:oProgress:oTablesProgress:nActualRecord := _nRecord
							Self:Notify()	

							// Fecha o arquivo de trabalho e a tabela aberta em modo exclusivo	
							If !lOpenCSV .OR. (lOpenCSV .AND. lSQLite ) 
								TRB->(DBCloseArea())
								If( ValType(oTempTable) == "O")
								  oTempTable:Delete()
								  FreeObj(oTempTable)
								  oTempTable := Nil
								EndIf
							EndIf
							
							If lOpenCSV
								Self:LjCSVDelFile(oCompleteTable:cTable)
							EndIf
							
							// Pega os arquivos que compoem a tabela (normalmente é o dbf e um arquivo que contem o memo) e os apaga
							aDir := Directory( Self:cPath + oCompleteTable:cTable + cEmpAnt + AllTrim(oCompleteTable:aBranches[nCount]) + ".*" )	
							For nCount2 := 1 To Len( aDir )
								If Lower(Right(AllTrim(aDir[nCount2][1]),3)) != "mzp"
									FErase( Self:cPath + aDir[nCount2][1] )
								EndIf
							Next												
						EndIf
					Else
						oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderFileDoesntExist", 1, "Arquivo não existe " + " '" + cFileName ) ) // "Arquivo não existe " 	
					EndIf
				EndIf
			Next
			
			LjGrvLog( "Carga", "fechando tabela " + oCompleteTable:cTable)
			(oCompleteTable:cTable)->(DbCloseArea())
		Else			
			oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderExclusiveOpen", 1, STR0004 + " '" + oCompleteTable:cTable + "'. " + STR0005 ) ) // "Não foi possível abrir a tabela" "Ela pode estar aberta por outro programa."
		EndIf
	EndIf

	LjGrvLog( "Carga","ImportComplete Fim ")	
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ImportPartial()

Faz importação de tabelas de transferência parcial. 
  
@param oPartialTable Objeto ipo LJCInitialLoadPartialTable.  

@return Nenhum

@author Vendas CRM
@since 16/10/10
/*/
//--------------------------------------------------------------------
Method ImportPartial( oPartialTable ) Class LJCInitialLoadLoader
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local aStruct				:= {}
	Local aStructDest			:= {}
	Local nCount				:= 0
	Local nCount2				:= 0
	Local cFileName				:= ""
	Local lRenewTimer			:= .T.
	Local nSecond1				:= 0
	Local nSecond2				:= 0
	Local nRecordsProcessed		:= 0
	Local _nRecord				:= 0
	Local lLJ1144Im				:= ExistBlock( "LJ1144Im" )
	Local nPosTable				:= 0
	Local cTablePrefix	 		:= If(SubStr(oPartialTable:cTable,1,1) == "S", SubStr(oPartialTable:cTable,2,3), oPartialTable:cTable)
	Local cIndexKey				:= ""
	Local aRecords 				:= aClone( oPartialTable:aRecords )
	Local cFilter 				:= AllTrim(oPartialTable:cFilter)
	Local lOnlyFilter 	 		:= Len(aRecords) == 0 .And. !Empty(cFilter)
	Local aCampos 				:= {}
	Local lSTDStartProd			:= ExistFunc("STDStartProd")
	Local aPartial				:= {}
	Local aTRB					:= {}
	Local nPos					:= 0 
	Local lOpenCSV				:= SuperGetMV("MV_LJGECSV",,"0") $ "12" //geracao de CSV 0 - Não gera, 1 - gera dbf/csv, 2 - somente csv 
	Local lSQLite 				:= AllTrim(Upper(GetSrvProfString("RpoDb",""))) == "SQLITE
	Local cRelease				:= GetRPORelease()						//Release atual
	Local lFieldMsExp			:= .F. //Existe o campo MSEXP?
	
	LjGrvLog( "Carga","ImportPartial Inicio ")
	
	If MpDicInDb() .AND. cRelease >= "12.1.025" 
		lOpenCSV := .T.
		LjGrvLog( "Carga","Release Atua: " + cRelease + " e Dicionario no banco, parametro MV_LJGECSV obrigatoriamente devera ser igual a '2'")							
	EndIf
	
	// Abre e fecha a tabela para garantir que ela será criada no banco de dados caso não exista.
	If !(Left(oPartialTable:cTable,2) == "SX" .Or. Left(oPartialTable:cTable,2) == "XX")
		DbSelectArea( oPartialTable:cTable )		
		DbCloseArea()
	EndIf

	// Se conseguir pegar as travas e mesmo assim não for possível abrir a tabela em modo exclusivo, se for desejado derruba os processos em execução.						
	If ChkFile( oPartialTable:cTable, .F. )		
		DbSelectArea(oPartialTable:cTable)

		If lSQLite
			cFileName := Self:cPath + oPartialTable:cTable + cEmpAnt + ".csv"
			lOpenCSV := .T.
		Else
			cFileName := Self:cPath + oPartialTable:cTable + cEmpAnt + Self:oGroup:cExtension
		EndIf
		
		LjGrvLog( "Carga","cFileName " , cFileName)
		If File(cFileName) 
			// Abre a area com o arquivo novo
			If !lOpenCSV
				DbUseArea(.T., Self:oGroup:cDriver, cFileName, "TRB", .F., .F.)			
			Else
				If lSQLite
					Self:LjCSVToAli(cFileName, oPartialTable:cTable,"TRB")	
				Endif				
			EndIf

		EndIf
	
		If Used()
		
			// Pega a estrutura do banco de dados
		   	aStruct := (oPartialTable:cTable)->(DBStruct())
		
			// Atualiza progresso
			If !lOpenCSV .OR. (lOpenCSV .AND. lSQLite )
				Self:oProgress:oTablesProgress:nTotalRecords := TRB->(RecCount())				
			EndIf 

			//Filtra os registros da tabela, caso nao tenha definido nenhum indice da tabela, mas tenha definido expressao de filtro
			If lOnlyFilter
				aAdd( aRecords, { 1, "" } )
				
				// se for carga inteira, limpa do banco de dados os registros que serao inseridos
				If Self:oGroup:cEntireIncremental == '1'
					DbSelectArea( oPartialTable:cTable )
					(oPartialTable:cTable)->( dbSetFilter( {|| &(cFilter) } , cFilter ) )
					(oPartialTable:cTable)->(dbGoTop())					
					
					LjGrvLog( "Carga","limpa do banco de dados os registros que serao inseridos com filtro")
					While (oPartialTable:cTable)->( !EOF() )
						RecLock( oPartialTable:cTable, .F.)
						(oPartialTable:cTable)->(DbDelete())
						(oPartialTable:cTable)->(MsUnLock())						
						(oPartialTable:cTable)->(DbSkip())
					End
					
					//Limpa todas as condicoes de filtro
					DbSelectArea( oPartialTable:cTable )
					(oPartialTable:cTable)->( dbClearFilter() )
				EndIf
				
			EndIf

			DbSelectArea( oPartialTable:cTable )
			DbSetOrder( 1 )
			cIndexKey	:= ( oPartialTable:cTable ) -> (IndexKey(1)) 
			lFieldMsExp := 	(oPartialTable:cTable)->(FieldPos(cTablePrefix + "_MSEXP")) > 0  .AND. (oPartialTable:cTable)->(FieldPos(cTablePrefix + "_HREXP")) > 0 
			
			If !lOpenCSV .OR. (lOpenCSV .AND. lSQLite )

				For nCount := 1 To Len( aRecords )
					// Transporta o banco de dados para o arquivo local
					LjGrvLog( "Carga","Transporta o banco de dados para o arquivo local")
					(oPartialTable:cTable)->( DbSetOrder( aRecords[nCount][1] ) )
					
					If !lOnlyFilter .And. (oPartialTable:cTable)->( DbSeek( Rtrim(aRecords[nCount][2]) ) )
						cIndexKey := (oPartialTable:cTable)->(IndexKey(aRecords[nCount][1]))
						If Empty( cIndexKey )
							Loop
						EndIf     
						
						// se for carga inteira, limpa do banco de dados os registros que serao inseridos
						If Self:oGroup:cEntireIncremental == '1'
							LjGrvLog( "Carga","limpa do banco de dados os registros que serao inseridos")
							While 	Left((oPartialTable:cTable)->(&cIndexKey),Len(aRecords[nCount][2])) == (aRecords[nCount][2]) .And.;
									(oPartialTable:cTable)->(!EOF())					
								RecLock( oPartialTable:cTable, .F.)
								(oPartialTable:cTable)->(DbDelete())
								(oPartialTable:cTable)->(MsUnLock())						
								(oPartialTable:cTable)->(DbSkip())
							End
						EndIf             
					EndIf						
					
					//melhora na performance
					aPartial:= {}
					( oPartialTable:cTable )->(DbGoTop())
					While ( oPartialTable:cTable )->(!EOF())
						aAdd(aPartial,{(oPartialTable:cTable )->(&cIndexKey),(oPartialTable:cTable )->(RECNO())})
						(oPartialTable:cTable )->(DbSkip())
					End					

					aTRB := {}
					TRB->(DbGoTop())
					While TRB->(!EOF())
						aAdd(aTRB,{TRB->(&cIndexKey),TRB->(RECNO())})
						TRB->(DbSkip())
					End					


					aStructDest	:= ( oPartialTable:cTable ) -> (DBStruct())
					For nCount2 := 1 To Len(aStruct)	
						aAdd(aCampos,{aStruct[nCount2][1],TRB->(FieldPos(aStruct[nCount2][1])) ,(oPartialTable:cTable) ,(oPartialTable:cTable)->(FieldPos( aStruct[nCount2][1]))})
					Next nCount2

					For _nRecord := 1 to Len(aTRB)

						If lRenewTimer
							nSecond1			:= Seconds()
							nRecordsProcessed	:= 0
							lRenewTimer 		:= .F.
						EndIf

						If (oPartialTable:cTable $ "SX5,SX6")  .OR. (oPartialTable:cTable)->(FieldPos(cTablePrefix + "_MSEXP")) > 0  .AND. (oPartialTable:cTable)->(FieldPos(cTablePrefix + "_HREXP")) > 0 //protecao - valida se os campos MSEXP e HREXP existem nas tabelas que receberao a carga
								
							nPos := aScan(aPartial,{|x|,x[1] ==  aTRB[_nRecord][1]} )  //procura se o registro ja existe
							If nPos > 0 
								TRB->(dbGoto(aTRB[_nRecord][2]))
								(oPartialTable:cTable)->(dbGoto(aPartial[nPos][2]))
								
								// Se nao for carga inteira nem for carga da SX5 ou SX6, compara MSEXP da carga com ambiente local (impede aplicar carga desatualizada)
								If  (Self:oGroup:cEntireIncremental == '1') .OR. (oPartialTable:cTable $ "SX5,SX6") .OR. Empty((oPartialTable:cTable)->(cTablePrefix + "_MSEXP")) .OR. ( ( TRB->(&(cTablePrefix + "_MSEXP")) + TRB->(&(cTablePrefix + "_HREXP")) ) > ( (oPartialTable:cTable)->(&(cTablePrefix + "_MSEXP")) + (oPartialTable:cTable)->(&(cTablePrefix + "_HREXP")) ) ) 
									Self:ImportRecord(oPartialTable:cTable, "TRB", .F.) // .F. -> alteracao
								EndIf
								
							Else	//Se nao existir o registro insere ele
								TRB->(dbGoto(aTRB[_nRecord][2]))
								Self:ImportRecord(oPartialTable:cTable, "TRB", .T.,aStructDest,aCampos,lSTDStartProd) // .T. -> inclusao

							EndIf
						Else //protecao - valida se os campos MSEXP e HREXP existem nas tabelas que receberao a carga
							oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderFieldDoesntExist", 1, STR0010 + cTablePrefix + "_MSEXP" + STR0011 + cTablePrefix + "_HREXP " + STR0012 ) )  //  "Campos necessários para a Carga Incremental não existem. Verifique se os campos " + cTablePrefix + "_MSEXP" + " e " + cTablePrefix + "_HREXP existem."
							Exit
						EndIf	
									
						nSecond2 := Seconds()
				
						If nSecond2 - nSecond1 >= 1 
							lRenewTimer := .T.
							// Reporta o progresso
							Self:oProgress:oTablesProgress:nRecordsPerSecond := Int(nRecordsProcessed / (nSecond2-nSecond1))
							Self:oProgress:oTablesProgress:nActualRecord := _nRecord
							Self:Notify()				
						EndIf
			
						nRecordsProcessed++
					Next
					 					
					_nRecord := _nRecord - 1   	

				Next				
		
			Else
				LjGrvLog( "Carga", "Carga em CSV ")

				If lFieldMsExp .Or. Self:oGroup:cEntireIncremental == '1' //Se não for completa checo os campos data e hora de exportação	
					Self:LjCSVToAli(cFileName, oPartialTable:cTable, (oPartialTable:cTable), .F.,Self:oGroup:cEntireIncremental == '2')
				Else //protecao - valida se os campos MSEXP e HREXP existem nas tabelas que receberao a carga
					oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderFieldDoesntExist", 1, STR0010 + cTablePrefix + "_MSEXP" + STR0011 + cTablePrefix + "_HREXP " + STR0012 ) )  //  "Campos necessários para a Carga Incremental não existem. Verifique se os campos " + cTablePrefix + "_MSEXP" + " e " + cTablePrefix + "_HREXP existem."
				EndIf 
				
				nRecordsProcessed := 1
				nSecond2 := Seconds()
				nSecond1 := Seconds()
				_nRecord := ( oPartialTable:cTable)->(Recno())

			EndIf 
			
			// Reporta o progresso
			Self:oProgress:oTablesProgress:nRecordsPerSecond := Int(nRecordsProcessed / (nSecond2-nSecond1))
			Self:oProgress:oTablesProgress:nActualRecord := _nRecord
			Self:Notify()				

			If !lOpenCSV .OR. (lOpenCSV .AND. lSQLite )
				// Fecha o arquivo de trabalho e a tabela aberta em modo exclusivo
				TRB->(DBCloseArea())	
				If( ValType(oTempTable) == "O")
					oTempTable:Delete()
					FreeObj(oTempTable)
					oTempTable := Nil
				EndIf	
			EndIf 
			
			If lOpenCSV
				Self:LjCSVDelFile(oPartialTable:cTable)
			EndIf
			
			// Pega os arquivos que compoem a tabela (normalmente é o dbf e um arquivo que contem o memo) e os apaga
			aDir := Directory( Self:cPath + oPartialTable:cTable + cEmpAnt + ".*" )	
			For nCount2 := 1 To Len( aDir )
				If Lower(Right(AllTrim(aDir[nCount2][1]),3)) != "mzp"
					FErase( Self:cPath + aDir[nCount2][1] )
				EndIf
			Next															
		EndIf				
		If !(Left(oPartialTable:cTable,2) == "SX" .Or. Left(oPartialTable:cTable,2) == "XX")
			(oPartialTable:cTable)->(DbCloseArea())
		EndIf
	EndIf
	
	LjGrvLog( "Carga","ImportPartial Fim ")
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ImportSpecial()

Faz importação de tabelas de transferência special.
  
@param oSpecialTable Objeto ipo LJCInitialLoadSpecialTable

@return oSpecialTable Objeto ipo LJCInitialLoadSpecialTable.      

@author Vendas CRM
@since 16/10/10 
/*/
//--------------------------------------------------------------------
Method ImportSpecial( oSpecialTable ) Class LJCInitialLoadLoader
	Local oFactory			:= LJCInitialLoadSpecialTableFactory():New()
	Local oLJMessageManager	:= GetLJCMessageManager()	
	Local oImporter 		:= Nil
	LjGrvLog( "Carga","ImportSpecial Inicio ")
	oImporter := oFactory:GetImporterByName( oSpecialTable:cTable )
	
	//SBI não é importada no pdv mobile
	If !oLJMessageManager:HasError()
		oImporter:Execute( oSpecialTable, Self )
	EndIf
	LjGrvLog( "Carga","ImportSpecial Fim ")
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Decompress()

Descompacta o arquivo desejado.  
  
@param cFile Nome do arquivo a ser descompactado.      

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method Decompress( cFile ) Class LJCInitialLoadLoader
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local lExiste				:= .T.
	Local nContador				:= 1
	Local cArquivo				:= cFile

	If Self:nExtFile == 1
		While lExiste
			cFile := cArquivo
			cFile := SubStr(cFile, 1, At(".", cFile) - 1) + "_" + AllTrim(Str(nContador)) + ".zip"
			If File(Self:cPath + cFile)
				LjGrvLog("Carga","Descompactando o arquivo ", cFile)	
				If FUnzip(Self:cPath + cFile, "\") <> 0
					lExiste := .F.
					oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderDecompressError", 1, STR0006 + " '" + Self:cPath + cFile  + "'" ) ) // "Não foi possível descompactar o arquivo:"
				Else
					nContador++
					Sleep(1000)
				EndIf
			Else
				lExiste := .F.
			EndIf
		End
	Else
		LjGrvLog( "Carga","Decompacta arquivo ",cFile )	
		If !MsDecomp( Self:cPath + cFile, Self:cPath )
			oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderDecompressError", 1, STR0006 + " '" + Self:cPath + cFile  + "'" ) ) // "Não foi possível descompactar o arquivo:"
		EndIf
	EndIf
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} CheckPath()

Verifica se os caminhos estão formatados corretamente e se existem.
Esse método também cria os diretórios se eles não existirem. 

@return Nenhum 

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method CheckPath() Class LJCInitialLoadLoader
Local oLJCMessageManager	:= GetLJCMessageManager()
	
	
	// Garante que o path que receberá os arquivos que serão baixados do servidor existe
	Self:cPath := If( Right( Self:cPath,1) != If( IsSrvUnix(), "/", "\" ) , Self:cPath += If( IsSrvUnix(), "/", "\" ) , Self:cPath )
	If !ExistDir( Self:cPath )
		If MakeDir( Self:cPath ) != 0
			oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderIOMessage", 1, STR0007 + " '" + Self:cPath + "'.") ) // "Não foi possível criar o diretório"
		EndIf
	EndIf	
	
	Self:cTempPath := If( Right( Self:cTempPath,1) != If( IsSrvUnix(), "/", "\" ) , Self:cTempPath += If( IsSrvUnix(), "/", "\" ) , Self:cTempPath )
	If !ExistDir( Self:cTempPath )
		If MakeDir( Self:cTempPath ) != 0
			oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderIOMessage", 1, STR0007 + " '" + Self:cTempPath + "'.") ) // "Não foi possível criar o diretório"
		EndIf
	EndIf		
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} AddObserver()

Adiciona uma classe observadora.
Ver padrões de projetos orientados a objeto, padrão Observer.
  
@param oObserver Classe observadora.

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method AddObserver( oObserver ) Class LJCInitialLoadLoader
	aAdd( Self:aoObservers, oObserver )
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} Notify()

Notifica as classes observadoras que o progresso foi alterado.

@return Nil 

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method Notify() Class LJCInitialLoadLoader
	Local nCount	:= 0
	
	For nCount := 1 To Len( Self:aoObservers )
		Self:aoObservers[nCount]:Update( Self:oProgress )
	Next
Return             


//-------------------------------------------------------------------
/*/{Protheus.doc} Update()

Recebe a notificação da classe de baixa de arquivo sobre seu progresso
Também notifica seus observador
  
@param oDownloadProgress Instância da classe LJCFileDownloaderDownloadProgress

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method Update( oDownloadProgress ) Class LJCInitialLoadLoader
	Self:oProgress:oFilesProgress:oDownloadProgress:= oDownloadProgress
	Self:Notify()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} KillOtherThreads()

Mata todas as outras threads em execução
  
@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method KillOtherThreads() Class LJCInitialLoadLoader
	Local aThreads				:= GetUserInfoArray()
	Local nCount				:= 1
	Local nTry					:= 1
	Local nMaxTries				:= 10
	Local oLJCMessageManager	:= GetLJCMessageManager()
	
	LjGrvLog( "Carga","Derrubas todas as outras threads em execucao" )
		
	While nTry <= nMaxTries
		For nCount := 1 To Len( aThreads ) 
			If aThreads[nCount,3] <> ThreadId()
				KillUser( aThreads[nCount,1], aThreads[nCount,2], aThreads[nCount,3], "LOCALHOST" ) 
			EndIf
		Next
		
		aThreads	:= GetUserInfoArray()
		
		If Len(aThreads) > 1
			nTry++
			Sleep(1000)
		Else
			Exit
		EndIf
	End
	
	If nTry > nMaxTries
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderThreadKill", 1, STR0013 ) )
	EndIf
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} ImportRecord()

Importa o registro posicionado em cTempAlias 
  
@param cTable tabela que recebera o registro
@param cTempAlias alias que contem o registro a ser importado
@param lInsert determina se eh uma inclusao (.T.) ou uma alteracao (.F.)

@return Nil

@author Vendas CRM
@since 10/07/12
/*/
//--------------------------------------------------------------------
Method ImportRecord(cTable, cTempAlias, lInsert,aStruct,aCampos,lSTDStartProd) Class LJCInitialLoadLoader

Local nCount				:= 0		// Contador para percorrer a estrutura da tabela.
Local nPosTable				:= 0 
Local nPosTRB				:= 0
Local nPosDEL 				:= 0
Local oLJCMessageManager	:= GetLJCMessageManager()
Local nTries				:= 1
Local nMaxTries				:= 3
Local lUpdateSuccess		:= .F.
Local lDeleteSuccess		:= .F.
Local uValor				:= NIL //Valor
Local nRec					:= 0 //Registro
Local lSQLiteTop 			:=AllTrim(Upper(GetSrvProfString("RpoDb",""))) $ "SQLITE|TOP" //quando exclusao de registro em ambiente TOP, eh necessario o mesmo tratamento realizado para SQLite
Local lRegDel				:= .F. //Registro deletado?

DEFAULT aStruct 			:= (cTable)->(DBStruct())			//Valor passado pela method ImportPartial
DEFAULT aCampos 			:= {}								//Valor passado pela method ImportPartial
DEFAULT lSTDStartProd		:= ExistFunc("STDStartProd")
DEFAULT lInsert				:= .F.


nPosDEL	:= (cTempAlias)->( FieldPos( "DEL" ) )
While !lUpdateSuccess .And. nTries <= nMaxTries
		
	lRegDel := (lSQLiteTop .AND. lInsert .and. nPosDEL > 0 .AND. (cTempAlias)->DEL == "*")
	If !lRegDel  .AND. RecLock( cTable, lInsert )

		For nCount := 1 To Len(aStruct)	
			If Len(aCampos) == 0 // Legado
			
				nPosTRB	:= (cTempAlias)->( FieldPos( aStruct[nCount][1] ) )				
				If nPosTRB > 0 
					uValor := (cTempAlias)->&( aStruct[nCount][1] )
					(cTable)->&(aStruct[nCount][1]) := uValor
				EndIf
			Else 
					(cTable)->&(aCampos[nCount][1]) := (cTempAlias)->&(aCampos[nCount][1])
			EndIf
			
		Next
		
		(cTable)->(MsUnLock())
		nRec := (cTable)->(Recno())
		lUpdateSuccess := .T.
		
		If lSTDStartProd 
			//Verifica se o registro criado veio de uma carga incremental (2), é a tabela de produtos e se esta sendo um insert
			//Nesse caso chama a funcao para tratar o array global para consulta de produto do TOTVSPDV   
			If Self:oGroup:cEntireIncremental == "2" .And. lInsert .And. Upper(Alltrim(cTable)) == "SB1"
				STDStartProd(.T.,.T.)
			EndIf
		EndIf	

		Exit
	Else
		If lRegDel
			lUpdateSuccess := .T.
		Else
			Sleep(1000)
		EndIf
	EndIf	

	nTries++	
End

nTries := 1
While !lRegDel .AND.  lUpdateSuccess .and.  !lDeleteSuccess .And. nTries <= nMaxTries
	// Verifica se o arquivo esta excluido e exclui no ambiente.
	nPosDEL	:= (cTempAlias)->( FieldPos( "DEL" ) )
	If nPosDEL > 0 .AND. (cTempAlias)->DEL == "*"	
		If lSTDStartProd
			//Verifica se o registro criado veio de uma carga incremental (2), é a tabela de produtos e se esta sendo excluido o produto
			//Nesse caso chama a funcao para tratar o array global para consulta de produto do TOTVSPDV   
			If Self:oGroup:cEntireIncremental == "2" .And. Upper(Alltrim(cTable)) == "SB1"
				STDStartProd(.T.,.F.)
			EndIf
		EndIf
		
		If RecLock( cTable, .F. )
			(cTable)->(DbDelete())			
			(cTable)->(MsUnLock())
			If lSQLiteTop 
				(cTable)->(Dbcommit())
            EndIf
			lDeleteSuccess := .T.
			Exit
		Else
			Sleep(1000)
		EndIf
	Else
		lDeleteSuccess := .T.
		Exit
	EndIf
	nTries++
End

If !lUpdateSuccess .Or. !lDeleteSuccess
	If !lRegDel
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderRecordExclusiveOpen", 1, STR0014 ) ) // "Não foi possível abrir o registro para edição. Ele pode estar aberto por outro programa"
	EndIf
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateEnvironmentStatus()

Atualiza o status do ambiente para a carga instanciada
  
@param cStatus Status

@return Nil

@author Vendas CRM
@since 10/07/12
/*/
//--------------------------------------------------------------------
Method UpdateEnvironmentStatus(cStatus) Class LJCInitialLoadLoader

Local oLJCMessageManager	:= GetLJCMessageManager()

If AliasInDic("MBY")
	DbSelectArea("MBY")
	DbSetOrder(1) //MBY_FILIAL+MBY_CODGRP+MBY_AMBIEN
	
	If DbSeek(xFilial("MBY") + Self:oGroup:cCode)
		Reclock("MBY", .F.)
	Else
		Reclock("MBY", .T.)
		Replace MBY->MBY_FILIAL	With xFilial( "MBY" )
		Replace MBY->MBY_CODGRP	With Self:oGroup:cCode
		Replace MBY->MBY_ORDEM		With Self:oGroup:cOrder
		Replace MBY->MBY_INTINC	With Self:oGroup:cEntireIncremental
	EndIf
	
	Replace MBY->MBY_STATUS	With cStatus
	
	MBY->( MsUnLock() )
	
	LjGrvLog( "Carga","Atualizou status da carga tabela MBY ",cStatus)
	
Else
	oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadLoaderTableDoesntExist", 1, STR0015 ) )  // 
EndIf
	
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCSVToAli()

Realiza a conversão do CSV para tabela temporaria
  
@param cFileName Nome do Arquivo CSV
@param cAliasOri Alias da Tabela
@param cAliasDest Alias destino
@param lImportDel Importa Registros Excluídos
@return Nil

@author Vendas CRM
@since 11/09/2015
/*/
//--------------------------------------------------------------------
Method LjCSVToAli(cFileName, cAliasOri, cAliasDest, lImportDel, lIncrement, nContador) Class LJCInitialLoadLoader
Local lSQLite 			:= AllTrim(Upper(GetSrvProfString("RpoDb",""))) == "SQLITE" //Fatclient/PDV Movel
Local aEstr 			:= {} //Estrutura da Tabela temporaria
Local cDrive 			:= NIL //Driver da tabela
Local nC 				:= 0 //Contador
Local nC2 				:= 0//Contador
Local nTamTRBCSV 		:= 0 //Tamanho do array de dados
Local aStructOri 		:= {} //Campos do CSV
Local uValue			:= NIL //Valor a carregar
Local cFileTmp 			:= cAliasOri+".tmp" //Arquivo temporario
Local cLine 			:= ""  //Linha
Local cBuffer 			:= "" //Buffer
Local nLines 			:= 0   //Linhas
Local nAtPlus 			:= ( Len( CRLF ) -1 ) //Delimitador 
Local nBytesRead 		:= 0 //Bytes Lidos
local nBufferSize  		:= 6500 //Buffer
Local nfHandle 			:= 0 //handle do arquivo
Local nStatusOld 		:= 0 //Status antigo
Local lRenewTimer		:= .T. //Novo timer
Local nSecond1			:= 0 //Segundos
Local nSecond2			:= 0 //Segundos2
Local nRecordsProcessed	:= 0 //Registros Processados
Local _nRecord			:= 0 //Registro
Local nRecords			:= 0 //Registros
Local nRecMedia			:= 0 //Media dos registros
Local cHrIni			:= Time() //Hora inicial
Local dDataIni			:= Date() //data Inicial
Local nPosDel 			:= 0 //Posicao do Excluído

Default lImportDel 		:= .T. //Importa registro excluídos
Default lIncrement 		:= .F. //Importa registro excluídos
Default nContador		:= 1

nStatusOld := Self:oProgress:oTablesProgress:nStatus
aEstr := (cAliasOri)->(dbStruct())

AADD(aEstr, {"DEL", "C", 1 , 0} ) 

If cAliasDest == "TRB"
	If lSQLite
		cDrive := "SQLITE_TMP" 
	EndIf
	
	If Select(cAliasDest) > 0 .AND. nContador == 1
	
		(cAliasDest)->(DbcloseArea())
	EndIf
	
	If File(cFileTmp)
		LjGrvLog( "Carga","apagando o arquivo " + cFileTmp)
		FErase(cFileTmp)
	EndIf
	
	LjGrvLog( "Carga","criando a tabela " + cFileTmp)
	
	//Cria tabela temporaria
	If nContador == 1
		oTempTable := LjCrTmpTbl(cAliasDest, aEstr)
	EndIf
EndIf

LjGrvLog( "Carga","leando o arquivo  tabela " + "Inicio " + DtoC(dDataIni) + " Inicio " + cHrIni)

nfHandle := FOpen(cFileName)

If nfHandle <> -1
	
	Self:oProgress:oTablesProgress:nStatus := 6
	
	nFileSize := fSeek(nfHandle,0,2)
	fSeek(nfHandle,0, 0) //volta para o inicio
	
	nRecords := Int(nFileSize/nBufferSize)

	Self:oProgress:oTablesProgress:nTotalRecords  := nRecords  //total de linhas

	While ( nBytesRead <= nFileSize ) 
		If lRenewTimer
			nSecond1			:= Seconds()
			lRenewTimer 		:= .F.
			nRecMedia := 0
		EndIf

		cBuffer += fReadStr( @nfHandle , @nBufferSize ) 
		nRecordsProcessed := nRecordsProcessed + 1
		nBytesRead += nBufferSize 
		nRecMedia := nRecMedia + 1
	
		While ( CRLF $ cBuffer ) 
			
			cLine := SubStr( cBuffer , 1 , ( AT( CRLF , cBuffer ) + nAtPlus ) ) 
			cBuffer := SubStr( cBuffer , Len( cLine ) + 1 ) 
			cLine := StrTran( cLine , CRLF , "" ) 
			LjCSVInLn(cLine, @nLines, cAliasDest,aEstr, @aStructOri, lImportDel, @nPosDel, lIncrement )
			cLine := "" 
	
		End While 
		
		nSecond2 := Seconds()

		If nSecond2 - nSecond1 >= 1
			lRenewTimer := .T.
			// Reporta o progresso
			Self:oProgress:oTablesProgress:nRecordsPerSecond := Int(nRecMedia / (nSecond2-nSecond1))
			Self:oProgress:oTablesProgress:nActualRecord := nRecordsProcessed
			Self:Notify()				
		EndIf		
		
	End While 
		
	IF !Empty( cBuffer ) 
		While ( CRLF $ cBuffer ) 
			cLine := SubStr( cBuffer , 1 , ( AT( CRLF , cBuffer ) + nAtPlus ) ) 
			cBuffer := SubStr( cBuffer , Len( cLine ) + 1 ) 
			cLine := StrTran( cLine , CRLF , "" ) 
			LjCSVInLn(cLine, @nLines, cAliasDest,aEstr, @aStructOri, lImportDel, @nPosDel, lIncrement ) 
			cLine := "" 
	
		End While 
	
	EndIF
	
	//comita a ultima linha		
	If  cAliasDest <> "TRB"					
		(cAliasDest)->(Dbcommit())
	EndIf
	
	// Reporta o progresso
	Self:oProgress:oTablesProgress:nRecordsPerSecond := Int(nRecMedia / (nSecond2-nSecond1))
	Self:oProgress:oTablesProgress:nActualRecord := nRecordsProcessed - 1
	Self:Notify()	
	
	fClose(nfHandle) 
	Self:oProgress:oTablesProgress:nStatus := nStatusOld 
EndIf

LjGrvLog( "Carga","Processado tabela " + cAliasOri + "  final " + Dtoc(date()) + " - " + Time()  + " Tempo  gasto : " + elaptime(cHrIni, time()))

DbSelectArea(cAliasDest)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCSVInLn()

Realiza o tratamento da linha do arquivo CSV para a tabela temporaria
  
@param cLine Linha
@param nLines Contador de Linhas
@param cAliasDest Alias destino
@param aEstr Estrutura arquivo temporario
@param aStructOri Estrutura de Origem
@param lImportDel Importa os registros excluídos
@param nPosDel Posicao dos registros excluídos
@return Nil

@author Vendas CRM
@since 11/09/2015
/*/
//--------------------------------------------------------------------

Static Function LjCSVInLn(cLine, nLines, cAliasDest,aEstr, aStructOri, lImportDel, nPosDel, lIncrement ) 
Local aTmp 			:= {} //Array temporário
Local cDelimit 		:= ";" //Delimitador
Local nC 			:= 0 //Contador
Local nTamArr 		:= 0 //Tamanho do Array
Local nTamTRBCSV 	:= 0 //Tamanho dos campos CSV
Local nC2 			:= 0 //Contador
Local lDeleta 		:= .F. //deletado?
Local aChave		:= {}	
Local nPos			:= 0
Local nChave		:= 0
Local lReclock 		:= .T.
Local cChave		:= ""
Local cTablePrefix	:= Iif(SubStr(cAliasDest,1,1) == "S", SubStr(cAliasDest,2,3), cAliasDest)
Local cMSEXP		:= cTablePrefix + "_MSEXP"
Local cHREXP		:= cTablePrefix + "_HREXP"
Local nPosMSEXP		:= 0
Local nPosHREXP		:= 0
Local nPosParIni	:= 0
Local nPosParFim	:= 0
Default lImportDel 	:= .T.
Default lIncrement 	:= .F.

If !Empty(AllTrim(cLine))
	aTmp := STRTOKARR(cLine, cDelimit)

	DBSelectArea(cAliasDest)
	
	If cAliasDest <> "TRB"
		DbsetOrder(1)
		aChave := STRTOKARR((cAliasDest)->(IndexKey(1)),"+")
	Endif 

	nLines := nLines + 1
	If nLines > 1
			If cAliasDest <> "TRB" .AND. nPosDel > 0
				lDeleta := RTrim(aTmp[nPosDel] )  = "*"
			EndIf
			
			If !lDeleta
				If lImportDel .OR. ( nPosDel = 0 .OR. (RTrim(aTmp[nPosDel] )  <> "*")) 
					nTamTRBCSV := Len(aStructOri)
					
					If lIncrement// -- Se for carga incremental 
						// -- Acha os campos da chave 
						For nChave := 1 to len(aChave)
							//retira as funções de conversão dos campos da chave
							nPosParIni := At("(",aChave[nChave])
							nPosParFim := At(")",aChave[nChave])
							If nPosParIni > 0
								aChave[nChave] := SubStr(aChave[nChave], nPosParIni+1, nPosParFim-nPosParIni-1)
							Endif 
							nPos := aScan(aStructOri, {|x| AllTrim(Upper(x[1])) == aChave[nChave]})
							cChave += PADR(aTmp[nPos],aStructOri[nPos][3])
						Next

						nPosMSEXP	:= aScan(aStructOri, {|x| AllTrim(Upper(x[1])) == cMSEXP})
						nPosHREXP	:= aScan(aStructOri, {|x| AllTrim(Upper(x[1])) == cHREXP})

						If (cAliasDest)->(DBSeek(cChave))
							//-- Compara MSEXP e HREXP da carga com ambiente local (impede aplicar carga desatualizada)
							If Empty((cAliasDest)->(&(cMSEXP)) ) .OR. ( ( aTmp[nPosMSEXP] + aTmp[nPosHREXP] ) > ( (cAliasDest)->(&(cMSEXP)) + (cAliasDest)->(&(cHREXP)) ) ) 
								lReclock := .F. // -- Alteração
							EndIf 
						EndIf
					EndIf 

					RecLock(cAliasDest, lReclock)
					For nC := 1 to nTamTRBCSV
						If aStructOri[nC, 2] <> "U" 
							If cAliasDest == "TRB" .OR.  aStructOri[nC, 1] <> "DEL"
								uValue := aTmp[nC]
								uValue := LjCSVConvtype(uValue, aStructOri[nC, 2], aStructOri[nC, 3])
								(cAliasDest)->&(aStructOri[nC, 01]) :=  uValue
							EndIf
						EndIf
					Next			
					(cAliasDest)->(MsUnLock())
					
				EndIf
			Endif

	Else
		//insere a Estrutura
		aStructOri := {}
		nTamArr := Len(aTmp)
		
		//Ajusta a estrutura origem para não dar fieldpos toda hora
		For nC := 1 to nTamArr
			If ( nC2 := aScan(aEstr, { |e| AllTrim(e[1]) == Alltrim(aTmp[nC])})) > 0
				aAdd(aStructOri, aClone(aEstr[nC2]))
			Else
				aAdd(aStructOri,{ "", "U", 0, 0 })
			EndIf
		Next 
		nPosDel := aSCan( aStructOri, { |cCampo| RTrim(cCampo[1]) == "DEL" })
	EndIf
EndIf

Return nLines


//-------------------------------------------------------------------
/*/{Protheus.doc} LjCSVDelFile()

Deleta o Arquivo CSV
  
@param cAliasOri Alias do Arquivo
@return Nil

@author Vendas CRM
@since 11/09/2015
/*/
//--------------------------------------------------------------------
Method LjCSVDelFile(cAliasOri) Class LJCInitialLoadLoader
Local cFileTmp := cAliasOri+".tmp"

If File(cFileTmp)
	LjGrvLog( "Carga","apagando o arquivo " + cFileTmp)
	FErase(cFileTmp)
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LjCSVConvtype()

Realiza a conversão do tipo de dados CSV para o tipo destinp
  
@param uValue Valor
@param cType tipo de Dados
@return uValue Valor convertido

@author Vendas CRM
@since 11/09/2015
/*/
//--------------------------------------------------------------------
Function LjCSVConvtype(uValue, cType, nTam, lDesconv, nDec)
Local aDePara				:= {{";", "#__PONTO_E_VIRGULA__#"}, {CRLF, "#__QUEBRA_DE_LINHA__#"}} //Arrau de Strings  De-Para
Local nPosDe 				:= 2 //Posicao de
Local nPosPara				:= 1 //Posicao Param

Default uValue := ""
Default lDesconv := .T.

If !lDesconv 
	nPosDe := 1
	nPosPara:= 2
EndIf

Default nDec := 0


If !Empty(cType)

	Do Case
		Case cType == "C"
			aEval(aDePara, { |d| uValue := StrTran(uValue, d[nPosDe], d[nPosPara])})
			If !lDesconv .AND. Len(uValue) = 0
				uValue := space(2)
			EndIf
		Case cType == "M"
			//to do
			aEval(aDePara, { |d| uValue := StrTran(uValue, d[nPosDe], d[nPosPara])})
			If !lDesconv .AND. Len(uValue) = 0
				uValue := space(2)
			EndIf
		Case cType == "N"
			If lDesconv
				uValue := Val(uValue)
			Else
				uValue := Str(uValue, nTam, nDec)
			EndIf
		Case cType == "D"
			If lDesconv
				uValue := StoD(uValue)
			Else
				uValue := DtoS(uValue)
			EndIf
			If !lDesconv .AND. Len(uValue) = 0
				uValue := space(2)
			EndIf
		Case cType == "L"
			If lDesconv
				uValue := AllTrim(uValue) == ".T."
			Else
				uValue := IIF(uValue, ".T.", ".F.")
			EndIf
	EndCase

EndIf

Return uValue

//-------------------------------------------------------------------
/*/{Protheus.doc} DelImportedFiles()

Deleta os arquivos importados.  
  
@param cFile Nome do arquivo a ser descompactado.      

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method DelImportedFiles() Class LJCInitialLoadLoader
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local cFile 	:= "" //Arquivi
	Local aFiles 	:= {} //Array de Arquivos
	Local nFiles 	:= 0 //Contador de Arquivos
	Local nRet 		:= 0 //Retorno da exclusão
	Local nC 		:= 0 //Contador
	Local lDelOk 	:=	 .T. //Exclusão OK?
	
	Local cFileDir 	:= "" //Arquivo subdiretorio
	Local aFilesDir 	:= {} //Array de Arquivos subdiretorio
	Local nFilesDir 	:= 0 //Contador de Arquivos subdiretorio
	Local nD 			:= 0 //Contador subdiretorio

	LjGrvLog( "Carga","Apaga Carga")	
	
	aFiles := Directory(Self:cPath+"*.*", "D")
	nFiles := Len(aFiles)
	
	//Apaga primeiro os arquivos 
	For nC := 1 to nFiles
		cFile := aFiles[nC, 01]
		If cFile <> '.' .AND. cFile <> '..'
			nRet := 0
			If aFiles[nC, 5] == "A" // Se for um arquivo
				nRet := FErase(Self:cPath + cFile,,.t.)
				lDelOk := (nRet == 0)
			Endif
			
			If !lDelOk
				oLJCMessageManager:ThrowMessage( LJCMessage():New( "DelImportedFilessError", 1, "Não foi possível deletar o arquivo: " + " '" + Self:cPath + cFile  + "'" ) ) //"Não foi possível deletar o arquivo: "
				Exit
			EndIf
		EndIf
	
	Next
	
	//Deleta os sub-diretorios so depois de apagar os arquivos 
	For nC := 1 to nFiles
		cFile := aFiles[nC, 01]
		If cFile <> '.' .AND. cFile <> '..'
			nRet := 0
			If	aFiles[nC, 5] == "D" // apaga subdiretorios do Ctree
			
				//Apaga primeiro os arquivos dentro do subdiretorio
				aFilesDir := Directory(Self:cPath+cFile+ If( IsSrvUnix(), "/", "\" )+"*.*", "D")
				nFilesDir := Len(aFilesDir)
				For nD := 1 to nFilesDir
					cFileDir := aFilesDir[nD, 01]
					If cFileDir <> '.' .AND. cFileDir <> '..'
						nRet := 0
						If aFilesDir[nD, 5] == "A" // Se for um arquivo
							nRet := FErase(Self:cPath+cFile+ If( IsSrvUnix(), "/", "\" ) + cFileDir,,.t.)
							lDelOk := (nRet == 0)
						Endif
						
						If !lDelOk
							oLJCMessageManager:ThrowMessage( LJCMessage():New( "DelImportedFilessError", 1, "Não foi possível deletar o arquivo: " + " '" + Self:cPath + cFileDir  + "'" ) ) //"Não foi possível deletar o arquivo: "
							Exit
						EndIf
					EndIf
				
				Next
			
				lDelOk := DirRemove(Self:cPath + cFile + If( IsSrvUnix(), "/", "\" )) // Apaga diretório 
			Endif
			
			If !lDelOk
				oLJCMessageManager:ThrowMessage( LJCMessage():New( "DelImportedFilessError", 1, "Não foi possível deletar o diretorio: " + " '" + Self:cPath + cFile  + "'" ) ) // "Não foi possível deletar o diretorio: "
				Exit
			EndIf
		EndIf
	
	Next
	
	If lDelOk
		lDelOk := DirRemove(Self:Self:cPath)
			If !lDelOk
				oLJCMessageManager:ThrowMessage( LJCMessage():New( "DelImportedFilessError", 1, "Não foi possível deletar o diretorio:" + " '" + Self:Self:cPath + "'" ) ) // "Não foi possível descompactar o arquivo:"
			EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DownloadZip()

Faz o download dos arquivos .zip que estão no servidor
  
@param 	oComunication Classe para conectar e verificar se existe o arquivo
@param 	oDownloader Classe para realizar o download do arquivo
@param 	cArquivo Nome do arquivo que sera baixado do servidor
@return Nil
@author Bruno Almeida
@since 	07/02/10
/*/
//--------------------------------------------------------------------
Method DownloadZip(oComunication, oDownloader, cArquivo) Class LJCInitialLoadLoader

Local lExiste 	:= .T.
Local nContador	:= 1
Local cBaixaArq := cArquivo
Local oLJCMessageManager := GetLJCMessageManager()

While lExiste
	If oComunication:Connect()
		cBaixaArq := cArquivo
		cBaixaArq := SubStr(cBaixaArq, 1, At(".", cBaixaArq) - 1) + "_" + AllTrim(Str(nContador)) + ".zip"
		If oComunication:FileExist(cBaixaArq)
			oComunication:Disconnect()
			oDownloader:Download(cBaixaArq)
			If oLJCMessageManager:HasError()
				lExiste := .F.
			Else
				nContador++
			EndIf
		Else
			lExiste := .F.
		EndIf
	Else		
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderInvalidRequest", 1, "Não foi possível se conectar no servidor." ) )
		lExiste := .F.
	EndIf
End

Return Nil
