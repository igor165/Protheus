#INCLUDE "WFA010.ch"
#include "SIGAWF.CH"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    砏FA010    � Autor 矲ernando Patelli       � Data � 18/04/00 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矼ostra log de envio de arquivos. Permite remo玢o dos mesmos.潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砏FA010                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      砏FA010                                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/


Function WFA010()
	ShowDlg()
Return nil

STATIC Function ShowDlg()
	Local lRemove
	
	Private cLogText, cLogSelected, cLogData, cLogDir, cArqLog, cLogMask := "*.LOG"
	Private aAllFiles := {}, aLogFiles := {}
    Private oDlg, oLogSelected, oButton1

	// PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" FUNNAME "WFA010"

    // Pega o diret髍io de Log de envio de arq. do arquivo de par鈓etros
    cLogDir := alltrim( WFGetMV( "MV_WFLOG", "\workflow" ) )
	If Left( cLogDir, 1 ) == "\"                                 	
		cLogDir := Substr( cLogDir, 2 )
	end
	If Right( cLogDir, 1 ) <> "\"                                 	
		cLogDir += "\"
	end

	// Verifica se h� Logs no diret髍io informado, incrementando as op珲es da ComboBox de nomes-de-arquivo-log
   	if ( lRemove := CarregaLogFiles( ) )
		// Carrega o conte鷇o do log padr鉶 (primeiro da lista)
		cArqLog  := Substr( aLogFiles[1], 1, Encontra( " - ", aLogFiles[1] ) ) 
		cLogText := MemoRead( cLogDir + cArqLog ) 
		if ( Len( cLogText ) > 64000 )  // Memo pode ter no m醲imo 64K
			cLogText := STR0001 //"Arquivo muito grande para ser carregado! Use WordPad ou Edit..."
		end	
	else
		// Nenhum log encontrado
        cArqLog := ""
		cLogText := STR0002 //"Nenhum arquivo de log!"
    	aLogFiles := { STR0002 } //"Nenhum arquivo de log!"
	end
			
  	DEFINE MSDIALOG oDlg FROM 92,69 TO 400,600 TITLE STR0003 PIXEL //"Log de Envio de Arquivos"
	
	// Escolha do arquivo log
	@ 06, 7  SAY STR0004 OF oDlg PIXEL //"Selecione o arquivo:"
	@ 15, 7  MSCOMBOBOX 	oLogSelected VAR cLogSelected ITEMS aLogFiles PIXEL SIZE 120,13 OF oDlg ;
										ON CHANGE 	( cArqLog :=Substr( 	cLogSelected, 1, Encontra( " - ", cLogSelected ) ), ;
										( cLogText := MemoRead( cLogDir + cArqLog ), ;
										Iif( Len( cLogText ) > 64000, cLogText := STR0001, ) ), ; //"Arquivo muito grande para ser carregado! Use WordPad ou Edit..."
										oDlg:Refresh(), oLogText:Setfocus() ) 

	//  Bot鉶 de escolha de pastas diferentes
	@ 06, 128	SAY STR0005 OF oDlg PIXEL //"Diret髍io de Log:"
	@ 15, 128  MSGET oLogSelDir VAR cLogDir SIZE 120,9 OF oDlg PIXEL
	@ 14, 248 	BUTTON "..." Size 12,13 OF oDlg ACTION ( GetLogDir( ), oLogText:Refresh() ) PIXEL

	// Memo do arquivo log
	@ 30, 7  GET oLogText VAR cLogText PIXEL MEMO READONLY SIZE 252,110 OF oDlg 
	@ 140,176 BUTTON oButton1 PROMPT STR0006	Size 50,13 OF oDlg ACTION DelLogs( cLogDir + cArqLog	) PIXEL //"Remover"
    oButton1:SetEnable( lRemove )  // Habilita ou Desabilita o bot鉶 "Remove", se tiver ou n鉶 Logs no diret髍io
	
	// Bot鉶 "Cancela" para encerrar a caixa de di醠ogo
	DEFINE SBUTTON FROM 140,230 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End()) PIXEL
   	
	ACTIVATE MSDIALOG oDlg CENTERED
Return Nil


// Evento OnClick do Bot鉶 "..." - Abre janela para escolha do diret髍io
// onde os arquivos de log devem ser procurados
STATIC Function GetLogDir( )
	Local cAuxDir
	cAuxDir := cLogDir
	cLogDir := AllTrim( cGetFile(,,,,.T.,128))
	if  Empty( cLogDir )
		cLogDir := cAuxDir
    end
	If Left( cLogDir, 1 ) == "\"                                 	
		cLogDir := Substr( cLogDir, 2 )
	end
	If Right( cLogDir, 1 ) <> "\"                                 	
		cLogDir += "\"
	end
    if CarregaLogFiles( )
		// Carrega o conte鷇o do log padr鉶 (primeiro da lista)
		cArqLog  := Substr( aLogFiles[1], 1, Encontra( " - ", aLogFiles[1] ) ) 
		cLogText := MemoRead( cLogDir + cArqLog ) 
		if ( Len( cLogText ) > 64000 )  // Memo pode ter no m醲imo 64K
			cLogText := STR0001 //"Arquivo muito grande para ser carregado! Use WordPad ou Edit..."
		end	

		oLogSelected:aItems := aLogFiles  // Renova a lista de op珲es
		oLogSelected:Refresh()
	else
		// Nenhum log encontrado
        cArqLog := ""
    	aLogFiles := { STR0002 } //"Nenhum arquivo de log!"
		cLogText := STR0002	//"Nenhum arquivo de log!"
		oLogSelected:aItems := aLogFiles  // Renova a lista de op珲es
		oLogSelected:Refresh()
	end
Return .T.


// Funcao verifica diretorio de log em busca de log files
STATIC Function CarregaLogFiles( )
    Local bRet
    Local nC
	// Zera vetor para nova busca de arquivos no diret髍io
	aAllFiles := {}
	aLogFiles := {}
    // Busca os arquivos da mascara de log (*.log) no diret髍io formado por (cRootPath + cLogDir)
	if Len( aAllFiles := Directory( cLogDir + cLogMask, "D" ) ) > 0
		for nC := 1 to Len( aAllFiles )
			if aAllFiles[ nC, 5 ] <> "D"
                if Upper( Left( aAllFiles[ nC,1 ], 2) ) == "WF"					// Caso o log seja do workflow (WF...)
					cLogData := 	Substr( aAllFiles[ nC,1 ], 7, 2 ) + "/" +;	// separo os caracteres do nome que representam
										Substr( aAllFiles[ nC,1 ], 5, 2 ) + "/" +;	// a data do arquivo, para apresenta玢o na combo
										Substr( aAllFiles[ nC,1 ], 3, 2 ) 
					AAdd( aLogFiles, aAllFiles[ nC,1 ] + " - " + cLogData )
				else
					AAdd( aLogFiles, aAllFiles[ nC,1 ] )
				end							
			end
		next
        if Len( aLogFiles ) > 0	// Se existem arquivos Log, retorno True
			ASort( aLogFiles,,, { |x, y| x > y } )  	// Ordeno os arquivos pela 鷏tima data
			bRet := .T.
		else 						// Sen鉶 False
   		 	bRet := .F.
   		end	
    else  							// Sen鉶 False
    	bRet := .F.
    end
	if oButton1 <> Nil  // Se o bot鉶 "Remover" j� existe...
		if bRet
			oButton1:SetEnable( .T. )  // ...Habilita bot鉶 "Remover"
		else
			oButton1:SetEnable( .F. )  // ...Desabilita bot鉶 "Remover"
	    end
    end
Return bRet


// Fun玢o para buscar separador cOque dentro de cOnde,
// mas se n鉶 encontrar, retorna o tamanho de cOnde 
STATIC Function Encontra( cOque, cOnde )
    Local nCol
    nCol := ( At( cOque, cOnde ) - 1)
    if nCol <= 0
		nCol :=  Len( cOnde ) 
	end
Return nCol		


// Evento OnClick do bot鉶 " Remover "
STATIC Function DelLogs( cFile )
	Local nTamanho
	nTamanho := Len( oLogSelected:aItems )
	if ( nTamanho > 0 )
		if MsgYesNo( STR0007 ) //"Deseja remover este arquivo log?"
			if File( cFile )
				ferase( cFile )  // Apaga o arquivo de log que est� sendo exibido
			end
		    if CarregaLogFiles( )
				// Carrega o conte鷇o do log padr鉶 (primeiro da lista)	
				cArqLog  := Substr( aLogFiles[1], 1, Encontra( " - ", aLogFiles[1] ) ) 
				cLogText := MemoRead( cLogDir + cArqLog ) 
				if ( Len( cLogText ) > 64000 )  // Memo pode ter no m醲imo 64K
					cLogText := STR0001 //"Arquivo muito grande para ser carregado! Use WordPad ou Edit..."
				endIf	
				oLogSelected:aItems := aLogFiles  // Renova a lista de op珲es
				oLogSelected:Refresh()
			else
				// Nenhum log encontrado
    	   		cArqLog := ""
    			aLogFiles := { STR0002 } //"Nenhum arquivo de log!"
				cLogText := STR0002	//"Nenhum arquivo de log!"
				oLogSelected:aItems := aLogFiles  // Renova a lista de op珲es
				oLogSelected:Refresh()
			end
		end	
	end
Return Nil
