#Include 'Protheus.ch'
#Include "TCBROWSE.CH"
#Include "Font.ch"
#Include "LjLogXml.ch"

Static cNomArq := ""	//Nome da Tabela

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjLogXml
Gera arquivo .xml dos arquivos .log para serem abertos pelo Excel.

@author    Marcos Augusto Dias
@version   12.1
@since     26.07.2016

@param -		
@return NIL

/*/
//------------------------------------------------------------------------------------------
Function LJLOGXML()
Local cNomInd   := ""										//Nome do Indice
Local aTrabStru := {}										//Array de trabalho
Local cIndChave  := "Dtos(LOG_DATA)+LOG_NOME"				//Chave para o índice
Local aLog := {}												//Array do nome dos arquivos de log
Local cPrefixo := "log_"	// log_05d mg 01 _20160511		//Prefixo do nome dos arquivos de log
Local _n1														//Contador _n1             
Local _afields:={}											//Array com o nome dos campos
Local cEmpr := ""												//Empresa selecionada
Local nI														//Contador nI
Local aRet     := {}											//Retorno
Local aVetor   := {}											//Vetor para Empresa
Local oChkMar  := NIL										//Objeto Checkbox
Local oLbx     := NIL										//Objeto Listbox
Local oButInv  := NIL										//Objeto Button
Local oSay     := NIL										//Objeto Say
Local oOk      := LoadBitmap( GetResources(), "LBOK" )	//Objeto Bitmap Ok
Local oNo      := LoadBitmap( GetResources(), "LBNO" )	//Objeto Bitmap No
Local lChk     := .F.										//Check
Local lTeveMarc:= .F.										//Se houve marcação
Local cVar     := ""											//Retorno de Listbox
Local dDataX   := dDataBase									//Data da Origem
Local oDataX													//Objeto oDataX
Local aMarcadas  := {}										//Array de empresas marcadas
Local oDirArqO												//Objeto Diretório de Arquivos - Origem
Local oDirArqv												//Objeto Diretório de Arquivos - Destino
Local oBtnSelOri												//Objeto Botão para Origem da Exportação
Local oBtnSelDir												//Objeto Botão para Destino da Exportação
Local lRet		:= .T.											//Variável de Retorno
Local nPos		:= 0											//Posição da string
Local lConfDlg		:= .F.									//Caso confirmou a seleção da janela principal
Local oTabTemp	:= NIL

Private cCadastro := 'Geração XML Log'
Private aRotina := {}
Private cMark	:= GetMark()
Private oDlg     := NIL
Private cDirArqO 	:= Space(50)
Private cDirArqV 	:= Space(50)

//+------------------------------------+
//| Local gravação dos arquivos de log |
//+------------------------------------+
Private cLocalLog   := ""
Private cLocalXml   := GetTempPath() //\users\marcos\appdata\local\temp\ - captura a pasta temporária do usuario

cLocalLog	:= GetSrvProfString("RootPath","")
cLocalLog	+= IIf(!(Right(cLocalLog,1) == IIf(IsSrvUnix(),"/","\")),IIf(IsSrvUnix(),"/","\"),"") + "autocom\logs\"

aRotina := { { STR0016 ,;			//"Geração .XML"
							 'LjMsgRun( "' + STR0017 + '",, {|| LJGERXML(cDirArqO) } )' ,;	//"Aguarde, exportando para arquivo XML..."
				  0, 1 }}

//+------------------------------------+
//| Cria vetor empresas para seleção.  |
//+------------------------------------+
dbSelectArea( "SM0" )
dbSetOrder( 1 )		//M0_CODIGO+M0_CODFIL
dbGoTop()

While !SM0->( EOF() )
	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO .and. x[3] == SM0->M0_CODFIL} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf
	dbSkip()
End

If Len(aVetor) == 0
	MsgInfo(STR0018, STR0014)	//"Selecione pelo menos uma empresa."###"Atenção"
	lRet := .F.
Endif

If lRet
	cDirArqO := cLocalLog
	cDirArqV := cLocalLog
		
	//+------------------------------------+
	//| Define a janela parâmetros.        |
	//+------------------------------------+
	Define MSDialog  oDlg Title STR0001 From 0, 0 To 417,471 Pixel	//"Geração XML Log"
	
	oDlg:cToolTip := STR0002	//"Tela para Múltiplas Seleções de Empresas/Filiais"
	
	@ 09, 10 Say  oSay Prompt STR0003 Size  120, 08 Of oDlg Pixel	//"Selecione a(s) Empresa(s) para Exportação:"
	
	@ 17, 10 Listbox  oLbx Var  cVar Fields Header " ", STR0004, STR0005 Size 216, 091 Of oDlg Pixel	//"Empresa"###"Filial"
	oLbx:SetArray(  aVetor )
	oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
	aVetor[oLbx:nAt, 2], ;
	aVetor[oLbx:nAt, /*4*/ 3]}}
	oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
	oLbx:cToolTip   :=  oDlg:cTitle
	oLbx:lHScroll   := .F. // NoScroll
		
	@ 111, 10 CheckBox oChkMar Var  lChk Prompt STR0006   Message  Size 40, 007 Pixel Of oDlg;	//"Todos"
	on Click MarcaTodos( lChk, @aVetor, oLbx )
	
	@ 121, 10 Button oButInv Prompt STR0007  Size 25, 07 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;	//"&Inverter"
	Message STR0008 Of oDlg	//"Inverter Seleção"
	
	// Marca/Desmarca por mascara
	@ 133, 10 Say  oSay Prompt STR0009 Size  40, 08 Of oDlg Pixel		//"Data do Log"
	@ 132, 45 MSGet  oDataX Var  dDataX Size  45, 08 Pixel Picture "@D"
	
	@ 148, 10 Say  oSay Prompt STR0010 Size  40, 08 Of oDlg Pixel	//"Local Origem"
	
	//"Informe o diretório onde os arquivos serão gerados"
	TSay():New( 160 /*183*//*<nRow>*/, 010/*<nCol>*/, {|| STR0028 }	/*<{cText}>*/, oDlg/*[<oWnd>]*/,;	//"Local Destino"
					 /*[<cPict>]*/, /*<oFont>*/, /*<.lCenter.>*/, /*<.lRight.>*/,;
					  /*<.lBorder.>*/, .T./*<.lPixel.>*/, /*<nClrText>*/, /*<nClrBack>*/,;
					   157/*<nWidth>*/, 08/*<nHeight>*/, /*<.design.>*/, /*<.update.>*/,;
					    /*<.lShaded.>*/, /*<.lBox.>*/, /*<.lRaised.>*/, /*<.lHtml.>*/ )
	
	//Campo - "Informe o diretório onde os arquivos serão gerados"
	oDirArqO := TGET():Create(oDlg)
	oDirArqO:cName := "oDirArqO"
	oDirArqO:nLeft := 90
	oDirArqO:nTop := 293
	oDirArqO:nWidth := 290
	oDirArqO:nHeight := 21
	oDirArqO:lShowHint := .F.
	oDirArqO:lReadOnly := .F.
	oDirArqO:Align := 0
	oDirArqO:cVariable := "cDirArqO"
	oDirArqO:bSetGet := {|u| If(PCount()>0,cDirArqO:=u,cDirArqO) }
	oDirArqO:lVisibleControl := .T.
	oDirArqO:lPassword := .F.
	oDirArqO:lHasButton := .F.
	oDirArqO:PICTURE := ""	//Não é case sensitive.
	oDirArqO:bWhen := {|| .f.}
		
	//Campo - "Informe o diretório onde os arquivos serão gerados"
	oDirArqv := TGET():Create(oDlg)
	oDirArqv:cName := "oDirArqv"
	oDirArqv:nLeft := 90
	oDirArqv:nTop := 320
	oDirArqv:nWidth := 290
	oDirArqv:nHeight := 21
	oDirArqv:lShowHint := .F.
	oDirArqv:lReadOnly := .F.
	oDirArqv:Align := 0
	oDirArqv:cVariable := "cDirArqv"
	oDirArqv:bSetGet := {|u| If(PCount()>0,cDirArqv:=u,cDirArqv) }
	oDirArqv:lVisibleControl := .T.
	oDirArqv:lPassword := .F.
	oDirArqv:lHasButton := .F.
	oDirArqv:PICTURE := ""	//Não é case sensitive.
	oDirArqv:bWhen := {|| .f.}
		
	//Botao - Legenda (Origem da exportação)
	oBtnSelOri := TButton():Create(oDlg)
	oBtnSelOri:cName := "oBtnSelOri"
	oBtnSelOri:cCaption := STR0011 //"Localizar..."
	oBtnSelOri:nLeft := 381
	oBtnSelOri:nTop  := 292
	oBtnSelOri:nHeight := 22
	oBtnSelOri:nWidth := 70
	oBtnSelOri:lShowHint := .F.
	oBtnSelOri:lReadOnly := .F.
	oBtnSelOri:Align := 0
	oBtnSelOri:bAction := {|| AExpSelOri() } 
	
	//Botao - Legenda (Destino da exportação)
	oBtnSelDir := TButton():Create(oDlg)
	oBtnSelDir:cName := "oBtnSelDir"
	oBtnSelDir:cCaption := STR0011 //"Localizar..."
	oBtnSelDir:nLeft := 381
	oBtnSelDir:nTop  := 319
	oBtnSelDir:nHeight := 22
	oBtnSelDir:nWidth := 70
	oBtnSelDir:lShowHint := .F.
	oBtnSelDir:lReadOnly := .F.
	oBtnSelDir:Align := 0
	oBtnSelDir:bAction := {|| AExpSelDir() } 
	
	Define SButton From 188, 085 Type 1 Action ( oDlg:End(), lConfDlg := .T. ) OnStop STR0012  Enable Of oDlg		//"Confirma a Seleção"
	Define SButton From 188, 118 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End(), lRet := .F. ) OnStop STR0013 Enable Of oDlg		//"Abandona a Seleção"
		
	Activate MSDialog  oDlg Center
		
	If !lConfDlg		//Se não confirmou a seleção, abandona as operações.
		lRet := .F.
	EndIf		
		
EndIf

If lRet .AND. Empty(cLocalXml)
	MsgInfo(STR0015, STR0014)	//"Local de geração dos arquivos não definido."###"Atenção"
	lRet := .F.
Endif

If lRet	
	//+------------------------------------+
	//| Define estrutura arquivo de traba- |
	//| lho para apresentação na Mbrowse.  |
	//+------------------------------------+
	AADD( aTrabStru , { "LOG_OK"   , "C" , 02 , 00 })
	AADD( aTrabStru , { "LOG_NOME" , "C" , 50 , 00 })
	AADD( aTrabStru , { "LOG_DATA" , "D" , 08 , 00 })
	AADD( aTrabStru , { "LOG_HORA" , "C" , 10 , 00 })
	AADD( aTrabStru , { "LOG_TAM"  , "N" , 16 , 02 })

	//+------------------------------------+
	//| Cria arquivo temporario de trabalho|
	//+------------------------------------+
	oTabTemp := FWTemporaryTable():New( GetNextAlias() )
	oTabTemp:SetFields(aTrabStru)
	oTabTemp:AddIndex("1", {"LOG_DATA","LOG_NOME"} )
	oTabTemp:Create()
	cNomArq := oTabTemp:GetAlias()
	(cNomArq)->(dbSetOrder(1))	//Dtos(LOG_DATA)+LOG_NOME
	(cNomArq)->(dbGoTop())
	
	//+------------------------------------+
	//| Cria array contendo os arquivos de |
	//| log a serem processados.           |
	//+------------------------------------+
	aLog := Directory(cDirArqO+cPrefixo+"*.TXT")
	
	If Len(aLog) == 0
		MsgInfo(STR0019, STR0014)	//"Não foram encontrados arquivos para importação."###"Atenção"
		lRet := .F.
	EndIf
EndIf	

If lRet
	//+------------------------------------+
	//| Cria variavel de empresas marcadas |
	//| para filtro dos arquivos de log.   |
	//+------------------------------------+
	For nI := 1 To Len( aVetor )
		If aVetor[nI][1]
			cEmpr += Upper(aVetor[nI][2])+aVetor[nI][3]+"/"
		EndIf
	Next nI

	If Empty(cEmpr)
		MsgInfo(STR0020, STR0014)	//"Selecione pelo menos uma empresa."###"Atenção"
		lRet := .F.
	Endif
EndIf

If lRet
	//+------------------------------------+
	//| Grava no arquivo temporario os ar- |
	//| quivos de log que serão processados|
	//+------------------------------------+
	For _n1 := 1 To Len(aLog)
     	dbSelectArea(cNomArq)
     	nPos := At("_",Substr(aLog[_n1][1],5)) //As filiais são strings de comprimentos variáveis, de 2 a 10.
     	If (nPos>2) .AND. Upper( AllTrim(SubStr( AllTrim( aLog[_n1][1] ) , 5, nPos-1 )) ) $ cEmpr .And. Iif(!Empty(dDataX),Dtos(dDataX) $ aLog[_n1][1],.T.)	// log_05d mg 01 _20160201
	     	RecLock(cNomArq,.T.)
     	 	(cNomArq)->LOG_NOME	:= aLog[_n1][1]
     	 	(cNomArq)->LOG_DATA   := aLog[_n1][3]
     	 	(cNomArq)->LOG_HORA   := aLog[_n1][4]
     	 	(cNomArq)->LOG_TAM    := aLog[_n1][2]
     	 	MsUnlock()
     	EndIf
	Next _n1   
	//+------------------------------------+
	//| Cria as colunas da markbrowse.     |
	//+------------------------------------+
	AADD(_afields,{"LOG_OK","",""})
	AADD(_afields,{"LOG_NOME","","Nome"})
	AADD(_afields,{"LOG_DATA","","Data"})
	AADD(_afields,{"LOG_HORA","","Hora"})
	AADD(_afields,{"LOG_TAM","","Tamanho"})

	//+-----------------------------------------+
	//| Mostra os arquivos de log na markbrowse |
	//+-----------------------------------------+
	dbSelectArea(cNomArq)
	dbGoTop()
	If !Eof()
	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  	//³ Endereça a função de BROWSE                                  ³
	  	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MarkBrow( cNomArq, 'LOG_OK',,_afields,, cMark,'LjXMarkAll()',,,,'LjXMark()',{|| LjXMarkAll()},,,,,,,.F.)
	Else
		MsgAlert(STR0021)		//"Não Existem arquivos de log."
	EndIf
EndIf

//+------------------------------------------+
//| Fecha arquivos temporarios.              |
//+------------------------------------------+
If !Empty(cNomArq) .And. (Select( cNomArq ) <> 0 )
	dbSelectArea(cNomArq)
	dbCloseArea()
EndIf

If oTabTemp <> NIL
	oTabTemp:Delete()
	oTabTemp := NIL
EndIf

Return Nil

  
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjGerXml
Gera XML do Log a partir do(s) arquivo(s) de origem selecionado(s)

@author    Marcos Augusto Dias
@version   12.1
@since     26.07.2016

@param cLocalLog		//Pasta onde se encontra o log		
@param cNomeLog		//Nome do log
@return NIL

/*/
//------------------------------------------------------------------------------------------
Function LJGERXML(cLocalLog,cNomeLog)

Default cLocalLog		:= ""
Default cNomeLog		:= ""

//+-----------------------------------------+
//| Inicia processo de geração arquivos log |
//+-----------------------------------------+
If Empty(cNomeLog)
	CursorWait()
Else
	conout(STR0022+allTrim(cNomeLog)+"...")		//"Processando arquivo "
EndIf

If Empty(cNomeLog)	
	ProcRegua((cNomArq)->(LastRec()))
EndIf

(cNomArq)->(DbGotop())
While .Not. (cNomArq)->(Eof())
	If .Not. Iif(Empty(cNomeLog),Empty((cNomArq)->LOG_OK),.F.)
		IncProc(STR0023 + (cNomArq)->LOG_NOME) //"Processando arquivo de log =>"  //'Processando NF seq. '
		
		//+-----------------------------------------+
		//| Chama função que cria o csv do log.     |
		//+-----------------------------------------+
		LOJAPLOG(cLocalLog,Iif(Empty(cNomeLog),(cNomArq)->LOG_NOME,cNomeLog))
		
	EndIf
	(cNomArq)->(DbSkip())
EndDo

CursorArrow()
ApMsgInfo(STR0024,STR0014)		//"Arquivos .XML gerados com Sucesso!"###"Atenção!"

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LojaPlog
Faz a leitura do log e converte em linhas de xml

@author    Marcos Augusto Dias
@version   12.1
@since     26.07.2016

@param cLocalLog		//Pasta onde se encontra o log		
@param cNomeLog		//Nome do log
@return NIL

/*/
//------------------------------------------------------------------------------------------
Static Function LOJAPLOG(cLocalLog,cNomeLog)

Local nI						//Contador I
Local nX						//Contador X
Local nY						//Contador Y
Local nW						//Contador W
Local nK						//Contador K
Local nT						//Contador T
Local hFile					//Handle do arquivo
Local clinha := ""			//Retorno da linha
Local nTamMax	:= 4096		//Tamanho máximo dos caracteres

Private cEOL := CHR(13) + CHR(10)
Private nBuffer := nTamMax
Private nFilePos := nTamMax
Private nPos := 0
Private cLine := ""

Default cLocalLog		:= ""
Default cNomeLog		:= ""

//+-----------------------------------------+
//| Ajusta o nome do arquivo log.           |
//+-----------------------------------------+
cArqImpor := cLocalLog + AllTrim(cNomeLog)

//+---------------------------------------------------------------------+
//| Cria o nome do arquivo csv                                          |
//+---------------------------------------------------------------------+
cArqExpor := AllTrim(cDirArqV) + AllTrim(cNomeLog)
cArqExpor := SubStr(cArqExpor,1,RAt(".",cArqExpor)-1)+"_"+Dtos(dDataBase)+"_"+Left(time(),2)+"h"+SubStr(time(),4,2)+"m"+Right(time(),2)+"s"+".xml"

//Valida arquivo
If !file(cArqImpor)
	Aviso(STR0025,STR0026,{STR0029},1)		//"Arquivo"###"Arquivo não selecionado ou inválido."###"Sair"
	Return
Else

	ProcRegua(1000)	// ProcRegua(Len(aRet))
	nI := 1
	
	//+---------------------------------------------------------------------+
	//| Executa Excel                                                       |
	//+---------------------------------------------------------------------+
	oExcel    := FWMSEXCEL():New()
	cFilePrint := CriaTrab(cArqExpor, .F.)	
	
	aDados:={}
	cBuffer := ""

	// hFile := FOPEN("C:\CiaShop\_v11\Protheus_data\autocom\logs\log_9901      _01010102_20160711_LEANDRO.TXT", 32)    // ABRE O ARQUIVO TEXTO
	hFile := FOPEN(cArqImpor, 32)    // ABRE O ARQUIVO TEXTO
	nFilePos := FSEEK(hFile, 0, 0)              // POSICIONA PONTEIRO DO ARQUIVO NO PRIMEIRO CARACTER
	cBuffer := SPACE(nBuffer)                   // ALOCA BUFFER
	lRead := FREAD(hFile, cBuffer, nBuffer)     // LE OS PRIMEIROS 1000 CARACTERES DO ARQUIVO
	nPos := AT(cEOL, cBuffer)                   // PROCURA O PRIMEIRO FINAL DE LINHA
	
	WHILE !(lRead == 0)
	    
	    WHILE (nPos == 0)                               // SE CARACTER DE FINAL DE LINHA NAO FOR ENCONTRADO
	        nBuffer += nTamMax                          // AUMENTA TAMANHO DO BUFFER
	        cBuffer := SPACE(nBuffer)                   // REALOCA BUFFER
	        nFilePos := FSEEK(hFile, nFilePos, 0)       // REPOSICIONA PONTEIRO DO ARQUIVO
	        lRead := FREAD(hFile, cBuffer, nBuffer)     // LE OS CARACTERES DO ARQUIVO
	        nPos := AT(cEOL, cBuffer)                   // PROCURA O PRIMEIRO FINAL DE LINHA
	    END
	    
	    // LEITURA DOS CAMPOS E GRAVACAO DOS DADOS DA TABELA AQUI
    	cLine := SUBSTR(cBuffer, 0, nPos)
    	conout(cLine)
		_lCab := .t.
		IncProc(STR0027 + Alltrim(cLine) )		//"Importando Linha: "
		clinha := LjRmvChEs(cLine)
		
		//+---------------------------------------------------------------------+
		//| Processa aba Header Information                                     |
		//+---------------------------------------------------------------------+
		If "BEGIN HEADER INFORMATION" $ Upper(clinha)

				If _lCab

					oExcel:AddworkSheet( "HEADER INFORMATION" ) // Nome da planilha				
					oExcel:AddTable ( "HEADER INFORMATION", STR0030 ) // Nome da tabela		//"Linhas do Cabeçalho"
					oExcel:AddColumn( "HEADER INFORMATION", STR0030, STR0031 , 1, 1 ) 	//"Linhas do Cabeçalho"###"Cabeçalho"		// Coluna, Alinhamento ( 1.Esquerdo ), Formatação ( 1.Geral )   , Se totaliza (.t.) ou (.f.)

					_lCab := .f.
					
				EndIf
				
				//+---------------------------------------------------------------------+
				//| Processa linhas do arquivo até encontrar a lista de fontes          |
				//+---------------------------------------------------------------------+
				While .Not. "LIST OF SOURCES" $ Upper(clinha)
					
					oExcel:AddRow( "HEADER INFORMATION", STR0030,;		//"Linhas do Cabeçalho"
						{ 	cLinha  } )

					// LEITURA DA PROXIMA LINHA DO ARQUIVO
    				cBuffer := SPACE(nBuffer)                   // ALOCA BUFFER
    				nFilePos += nPos + 1                        // POSICIONA ARQUIVO APÓS O ULTIMO EOL ENCONTRADO
    				nFilePos := FSEEK(hFile, nFilePos, 0)       // POSICIONA PONTEIRO DO ARQUIVO
    				lRead := FREAD(hFile, cBuffer, nBuffer)     // LE OS CARACTERES DO ARQUIVO
    				nPos := AT(cEOL, cBuffer)                   // PROCURA O PRIMEIRO FINAL DE LINHA
					
					If (lRead == 0)
						Exit 
					EndIf

					// LEITURA DOS CAMPOS E GRAVACAO DOS DADOS DA TABELA AQUI
    				cLine := SUBSTR(cBuffer, 0, nPos)
					clinha := AllTrim(LjRmvChEs(cLine))
					conout(cLine)
					
				EndDo	 
			
		//+---------------------------------------------------------------------+
		//| Processa aba lista de fontes                                        |
		//+---------------------------------------------------------------------+
		ElseIf "THREAD" $ Upper(clinha)
			
			While .T. 
				
				If _lCab
					
					oExcel:AddworkSheet( "List of sources" ) // Nome da planilha				
					oExcel:AddTable ( "List of sources", STR0032 ) //"Lista de Fontes"  // Nome da tabela
					oExcel:AddColumn( "List of sources", STR0032, STR0033, 1, 1 ) //"Lista de Fontes"###"Thread"  // Coluna, Alinhamento ( 1.Esquerdo ), Formatação ( 1.Geral )   , Se totaliza (.t.) ou (.f.)
					oExcel:AddColumn( "List of sources", STR0032, STR0034, 1, 1 )	//"Lista de Fontes"###"Programa"
					oExcel:AddColumn( "List of sources", STR0032, STR0035, 1, 1 )	//"Lista de Fontes"###"Data"
					oExcel:AddColumn( "List of sources", STR0032, STR0036, 1, 1 )	//"Lista de Fontes"###"Hora"
					oExcel:AddColumn( "List of sources", STR0032, STR0037, 1, 1 )	//"Lista de Fontes"###"Build"
					
					_lCab := .f.
					
				EndIf
				
				aDadosX := StrTokArr( clinha , " " )
				
				oExcel:AddRow( "List of sources", STR0032,;		//"Lista de Fontes"
				{ aDadosX[1]+" "+aDadosX[2], ;
				aDadosX[3],;
				aDadosX[4],;
				aDadosX[5],;
				aDadosX[6] } )
				
				// LEITURA DA PROXIMA LINHA DO ARQUIVO
    			cBuffer := SPACE(nBuffer)                   // ALOCA BUFFER
    			nFilePos += nPos + 1                        // POSICIONA ARQUIVO APÓS O ULTIMO EOL ENCONTRADO
    			nFilePos := FSEEK(hFile, nFilePos, 0)       // POSICIONA PONTEIRO DO ARQUIVO
    			lRead := FREAD(hFile, cBuffer, nBuffer)     // LE OS CARACTERES DO ARQUIVO
    			nPos := AT(cEOL, cBuffer)                   // PROCURA O PRIMEIRO FINAL DE LINHA
					
				If (lRead == 0)
					Exit
				EndIf

				// LEITURA DOS CAMPOS E GRAVACAO DOS DADOS DA TABELA AQUI
    			cLine := SUBSTR(cBuffer, 0, nPos)
    
				clinha := AllTrim(LjRmvChEs(cLine))
	
				conout(cLine)
					
				If .not. "THREAD" $ Upper(clinha)
					Exit
				EndIf
					
			EndDo
			
		//+---------------------------------------------------------------------+
		//| Processa aba funções                                                |
		//+---------------------------------------------------------------------+
		ElseIf "FUNCTION" $ Upper(clinha)	
			
			While ( SubStr(clinha,3,1) == ":" .And. SubStr(clinha,6,1) == ":" )
				
				If _lCab
					
					oExcel:AddworkSheet( "Function Lines" ) // Nome da planilha				
					oExcel:AddTable ( "Function Lines", STR0038 ) //"Funções"		// Nome da tabela
					oExcel:AddColumn( "Function Lines", STR0038, STR0036, 1, 1 )	//"Funções"###"Hora" // Coluna, Alinhamento ( 1.Esquerdo ), Formatação ( 1.Geral )   , Se totaliza (.t.) ou (.f.)
					oExcel:AddColumn( "Function Lines", STR0038, STR0033 , 1, 1 )	//"Funções"###"Thread"
					oExcel:AddColumn( "Function Lines", STR0038, STR0039 , 1, 1 )	//"Funções"###"Função"
					oExcel:AddColumn( "Function Lines", STR0038, STR0040 , 1, 1 )	//"Funções"###"Linha"
					oExcel:AddColumn( "Function Lines", STR0038, STR0041 , 1, 1 )	//"Funções"###"Mensagem"
					
					_lCab := .f.
					
				EndIf
				
				aDadosX := StrTokArr( clinha , " " )
				
				// LEITURA DA PROXIMA LINHA DO ARQUIVO
    			cBuffer := SPACE(nBuffer)                   // ALOCA BUFFER
    			nFilePos += nPos + 1                        // POSICIONA ARQUIVO APÓS O ULTIMO EOL ENCONTRADO
    			nFilePos := FSEEK(hFile, nFilePos, 0)       // POSICIONA PONTEIRO DO ARQUIVO
    			lRead := FREAD(hFile, cBuffer, nBuffer)     // LE OS CARACTERES DO ARQUIVO
    			nPos := AT(cEOL, cBuffer)                   // PROCURA O PRIMEIRO FINAL DE LINHA
					
				If (lRead == 0)
					Exit
				Else
				
					// LEITURA DOS CAMPOS E GRAVACAO DOS DADOS DA TABELA AQUI
					If nPos == 0
						cLine := AllTrim(cBuffer)
					Else
    					cLine := SUBSTR(cBuffer, 0, nPos)
    				EndIf
    
					clinha := AllTrim(LjRmvChEs(cLine))
			
					conout(cLine)

 					sUniLin := ""
					
					While .NOT. ( SubStr(clinha,3,1) == ":" .And. SubStr(clinha,6,1) == ":" )
						sUniLin := AllTrim(clinha)
						
						If .Not. AllTrim(sUniLin) == ""
							
							sUniLin := StrTran(sUniLin,"<!CDATA[","")	//Primeiro, eu retiro todos os "<!CDATA[" e "]]>" pois CDATA dentro de CDATA o xml não reconhece.
							sUniLin := StrTran(sUniLin,"]]>","")
							sUniLin := "<![CDATA["+sUniLin+"]]>"	//XML dentro de XML. Para não confundir o leitor de XML, aplico CDATA.
										
							If Len(sUniLin) > nTamMax 				//Quebra de linha
								nX := NoRound(Len(sUniLin)/nTamMax,0)
								nY := Len(sUniLin)% nTamMax
								If nY > 0
									nX += 1
								EndIf
								nK := 1
								nT := nTamMax
								nW := 1 
								While nW <= nX
									
									If .Not. AllTrim(SubStr(AllTrim(sUniLin),nK,nT)) == ""
										oExcel:AddRow( "Function Lines", "Funções",;
										{ 	aDadosX[1],;	// Hora
										aDadosX[2],;		// Thread
										aDadosX[3]+" "+aDadosX[4],; // Function Nome
										aDadosX[5]+" "+aDadosX[6],; // Line Número
										SubStr(AllTrim(sUniLin),nK,nT) } )	// Demais Linhas
									EndIf
									nK += nTamMax
									
									If Len(AllTrim(sUniLin)) - nK < nTamMax
										nT := nY	
									EndIf
									
									nW++
									
								EndDo
							Else
								oExcel:AddRow( "Function Lines", "Funções",;
								{ 	aDadosX[1],;	// Hora
								aDadosX[2],;		// Thread
								aDadosX[3]+" "+aDadosX[4],; // Function Nome
								aDadosX[5]+" "+aDadosX[6],; // Line Número
								sUniLin } )	// Demais Linhas
							EndIf
						EndIf
						
						// LEITURA DA PROXIMA LINHA DO ARQUIVO
    					cBuffer := SPACE(nBuffer)                   // ALOCA BUFFER
		    			nFilePos += nPos + 1                        // POSICIONA ARQUIVO APÓS O ULTIMO EOL ENCONTRADO
		    			nFilePos := FSEEK(hFile, nFilePos, 0)       // POSICIONA PONTEIRO DO ARQUIVO
		    			lRead := FREAD(hFile, cBuffer, nBuffer)     // LE OS CARACTERES DO ARQUIVO
		    			nPos := AT(cEOL, cBuffer)                   // PROCURA O PRIMEIRO FINAL DE LINHA
							
						If (lRead == 0)
							Exit
						EndIf	
						
						// LEITURA DOS CAMPOS E GRAVACAO DOS DADOS DA TABELA AQUI
    					cLine := SUBSTR(cBuffer, 0, nPos)
    
						clinha := AllTrim(LjRmvChEs(cLine))
					
						conout(cLine)

					EndDo
					
				EndIf
			EndDo
		Else
		
			// LEITURA DA PROXIMA LINHA DO ARQUIVO
			cBuffer := SPACE(nBuffer)                   // ALOCA BUFFER
			nFilePos += nPos + 1                        // POSICIONA ARQUIVO APÓS O ULTIMO EOL ENCONTRADO
			nFilePos := FSEEK(hFile, nFilePos, 0)       // POSICIONA PONTEIRO DO ARQUIVO
			lRead := FREAD(hFile, cBuffer, nBuffer)     // LE OS CARACTERES DO ARQUIVO
			nPos := AT(cEOL, cBuffer)                   // PROCURA O PRIMEIRO FINAL DE LINHA
			
			If (lRead == 0)
				Exit
			EndIf
			
		EndIf
		
	End
	FClose(hFile) 
EndIf

//+---------------------------------------------------------------------+
//| Ativa Excel                                                         |
//+---------------------------------------------------------------------+
oExcel:Activate()

//+---------------------------------------------------------------------+
//| Gera o arquivo de xml com os dados do log                           |
//+---------------------------------------------------------------------+
oExcel:GetXMLFile( AllTrim( cArqExpor ) )

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjXMark
Grava marca no campo

@author    Marcos Augusto Dias
@version   12.1
@since     26.07.2016

@param -
@return NIL

/*/
//------------------------------------------------------------------------------------------
Function LjXMark()
If IsMark( 'LOG_OK', cMark )
	RecLock( cNomArq, .F. )
	Replace LOG_OK With Space(2)
	MsUnLock()
Else
	RecLock( cNomArq, .F. )
	Replace LOG_OK With cMark
	MsUnLock()
EndIf          

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjXMarkAll
Grava marca em todos os registros validos

@author    Marcos Augusto Dias
@version   12.1
@since     26.07.2016

@param -
@return NIL

/*/
//------------------------------------------------------------------------------------------
Function LjXMarkAll()
Local oMark := GetMarkBrow()			//Objeto Mark

dbSelectArea(cNomArq)
dbGotop()
While !Eof()
	LjXMark()
	dbSkip()
End

MarkBRefresh( )

// força o posicionamento do browse no primeiro registro
oMark:oBrowse:Gotop()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Funcao Auxiliar para marcar/desmarcar todos os itens do ListBox ativo

@author    Marcos Augusto Dias
@version   12.1
@since     26.07.2016

@param lMarca		.T. para marcar todos, .F. para desmarcar todos
@param aVetor		Vetor para Grid
@param oLbx		Objeto Listbox
@return NIL

/*/
//------------------------------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0				//Contador

Default lMarca		:= .F.
Default aVetor		:= {}
Default oLbx			:= nil

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Funcao Auxiliar para inverter selecao do ListBox Ativo

@author    Marcos Augusto Dias
@version   12.1
@since     26.07.2016

@param aVetor		Vetor para Grid
@param oLbx		Objeto Listbox
@return NIL

/*/
//------------------------------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0				//Contador

Default aVetor	:= {}
Default oLbx		:= nil

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Funcao Auxiliar para verificar se estão todos marcados ou não

@author    Marcos Augusto Dias
@version   12.1
@since     26.07.2016

@param aVetor		Vetor para Grid
@param lChk		True marca todos, False desmarca todos
@param oChkMar		Objeto Checkbox
@return NIL

/*/
//------------------------------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.			//Flag de marcação
Local nI     := 0				//Contador

Default aVetor	:= {}
Default lChk		:= .F.
Default oChkMar	:= nil

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AExpSelOri
Abre tela para selecionar o diretório onde os arquivos serão gerados

@author    Alberto Deviciente
@version   12.1
@since     26.07.2016

@param  - 
@return lRet 			Retorno da seleção do diretório

/*/
//------------------------------------------------------------------------------------------
Static Function AExpSelOri()
Local lRet			:= .T.			//Retorno
Local cDiretorio	:= ""			//Diretório a ser gravado

cDiretorio := cGetFile(,,,,.F.,GETF_LOCALHARD+128)
If !Empty(cDiretorio)
	cDirArqO := alltrim(cDiretorio)	//cDirArqO = Private
EndIf
if !empty(cDirArqO)
	cDirArqO := alltrim(cDirArqO)	// +"_migracao_\"
endif
cLocalXml := cDirArqO 

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AExpSelDir
Abre tela para selecionar o diretório onde os arquivos serão gerados

@author    Alberto Deviciente
@version   12.1
@since     26.07.2016

@param  - 
@return lRet 			Retorno da seleção do diretório

/*/
//------------------------------------------------------------------------------------------
Static Function AExpSelDir()
Local lRet			:= .T.			//Retorno
Local cDiretorio	:= ""			//Diretório a ser gravado

cDiretorio := cGetFile(,,,,.F.,GETF_LOCALHARD+128)
If !Empty(cDiretorio)
	cDirArqv := alltrim(cDiretorio)	//cDirArqV = Private
EndIf
if !empty(cDirArqv)
	cDirArqv := alltrim(cDirArqv)	// +"_migracao_\"
endif
cLocalXml := cDirArqv 

Return lRet
