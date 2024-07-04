#INCLUDE "WFA010.ch"
#include "SIGAWF.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WFA010    ³ Autor ³Fernando Patelli       ³ Data ³ 18/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra log de envio de arquivos. Permite remoção dos mesmos.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³WFA010                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³WFA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

    // Pega o diretório de Log de envio de arq. do arquivo de parâmetros
    cLogDir := alltrim( WFGetMV( "MV_WFLOG", "\workflow" ) )
	If Left( cLogDir, 1 ) == "\"                                 	
		cLogDir := Substr( cLogDir, 2 )
	end
	If Right( cLogDir, 1 ) <> "\"                                 	
		cLogDir += "\"
	end

	// Verifica se há Logs no diretório informado, incrementando as opções da ComboBox de nomes-de-arquivo-log
   	if ( lRemove := CarregaLogFiles( ) )
		// Carrega o conteúdo do log padrão (primeiro da lista)
		cArqLog  := Substr( aLogFiles[1], 1, Encontra( " - ", aLogFiles[1] ) ) 
		cLogText := MemoRead( cLogDir + cArqLog ) 
		if ( Len( cLogText ) > 64000 )  // Memo pode ter no máximo 64K
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

	//  Botão de escolha de pastas diferentes
	@ 06, 128	SAY STR0005 OF oDlg PIXEL //"Diretório de Log:"
	@ 15, 128  MSGET oLogSelDir VAR cLogDir SIZE 120,9 OF oDlg PIXEL
	@ 14, 248 	BUTTON "..." Size 12,13 OF oDlg ACTION ( GetLogDir( ), oLogText:Refresh() ) PIXEL

	// Memo do arquivo log
	@ 30, 7  GET oLogText VAR cLogText PIXEL MEMO READONLY SIZE 252,110 OF oDlg 
	@ 140,176 BUTTON oButton1 PROMPT STR0006	Size 50,13 OF oDlg ACTION DelLogs( cLogDir + cArqLog	) PIXEL //"Remover"
    oButton1:SetEnable( lRemove )  // Habilita ou Desabilita o botão "Remove", se tiver ou não Logs no diretório
	
	// Botão "Cancela" para encerrar a caixa de diálogo
	DEFINE SBUTTON FROM 140,230 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End()) PIXEL
   	
	ACTIVATE MSDIALOG oDlg CENTERED
Return Nil


// Evento OnClick do Botão "..." - Abre janela para escolha do diretório
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
		// Carrega o conteúdo do log padrão (primeiro da lista)
		cArqLog  := Substr( aLogFiles[1], 1, Encontra( " - ", aLogFiles[1] ) ) 
		cLogText := MemoRead( cLogDir + cArqLog ) 
		if ( Len( cLogText ) > 64000 )  // Memo pode ter no máximo 64K
			cLogText := STR0001 //"Arquivo muito grande para ser carregado! Use WordPad ou Edit..."
		end	

		oLogSelected:aItems := aLogFiles  // Renova a lista de opções
		oLogSelected:Refresh()
	else
		// Nenhum log encontrado
        cArqLog := ""
    	aLogFiles := { STR0002 } //"Nenhum arquivo de log!"
		cLogText := STR0002	//"Nenhum arquivo de log!"
		oLogSelected:aItems := aLogFiles  // Renova a lista de opções
		oLogSelected:Refresh()
	end
Return .T.


// Funcao verifica diretorio de log em busca de log files
STATIC Function CarregaLogFiles( )
    Local bRet
    Local nC
	// Zera vetor para nova busca de arquivos no diretório
	aAllFiles := {}
	aLogFiles := {}
    // Busca os arquivos da mascara de log (*.log) no diretório formado por (cRootPath + cLogDir)
	if Len( aAllFiles := Directory( cLogDir + cLogMask, "D" ) ) > 0
		for nC := 1 to Len( aAllFiles )
			if aAllFiles[ nC, 5 ] <> "D"
                if Upper( Left( aAllFiles[ nC,1 ], 2) ) == "WF"					// Caso o log seja do workflow (WF...)
					cLogData := 	Substr( aAllFiles[ nC,1 ], 7, 2 ) + "/" +;	// separo os caracteres do nome que representam
										Substr( aAllFiles[ nC,1 ], 5, 2 ) + "/" +;	// a data do arquivo, para apresentação na combo
										Substr( aAllFiles[ nC,1 ], 3, 2 ) 
					AAdd( aLogFiles, aAllFiles[ nC,1 ] + " - " + cLogData )
				else
					AAdd( aLogFiles, aAllFiles[ nC,1 ] )
				end							
			end
		next
        if Len( aLogFiles ) > 0	// Se existem arquivos Log, retorno True
			ASort( aLogFiles,,, { |x, y| x > y } )  	// Ordeno os arquivos pela última data
			bRet := .T.
		else 						// Senão False
   		 	bRet := .F.
   		end	
    else  							// Senão False
    	bRet := .F.
    end
	if oButton1 <> Nil  // Se o botão "Remover" já existe...
		if bRet
			oButton1:SetEnable( .T. )  // ...Habilita botão "Remover"
		else
			oButton1:SetEnable( .F. )  // ...Desabilita botão "Remover"
	    end
    end
Return bRet


// Função para buscar separador cOque dentro de cOnde,
// mas se não encontrar, retorna o tamanho de cOnde 
STATIC Function Encontra( cOque, cOnde )
    Local nCol
    nCol := ( At( cOque, cOnde ) - 1)
    if nCol <= 0
		nCol :=  Len( cOnde ) 
	end
Return nCol		


// Evento OnClick do botão " Remover "
STATIC Function DelLogs( cFile )
	Local nTamanho
	nTamanho := Len( oLogSelected:aItems )
	if ( nTamanho > 0 )
		if MsgYesNo( STR0007 ) //"Deseja remover este arquivo log?"
			if File( cFile )
				ferase( cFile )  // Apaga o arquivo de log que está sendo exibido
			end
		    if CarregaLogFiles( )
				// Carrega o conteúdo do log padrão (primeiro da lista)	
				cArqLog  := Substr( aLogFiles[1], 1, Encontra( " - ", aLogFiles[1] ) ) 
				cLogText := MemoRead( cLogDir + cArqLog ) 
				if ( Len( cLogText ) > 64000 )  // Memo pode ter no máximo 64K
					cLogText := STR0001 //"Arquivo muito grande para ser carregado! Use WordPad ou Edit..."
				endIf	
				oLogSelected:aItems := aLogFiles  // Renova a lista de opções
				oLogSelected:Refresh()
			else
				// Nenhum log encontrado
    	   		cArqLog := ""
    			aLogFiles := { STR0002 } //"Nenhum arquivo de log!"
				cLogText := STR0002	//"Nenhum arquivo de log!"
				oLogSelected:aItems := aLogFiles  // Renova a lista de opções
				oLogSelected:Refresh()
			end
		end	
	end
Return Nil
