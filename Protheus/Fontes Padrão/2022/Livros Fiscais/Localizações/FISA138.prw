#INCLUDE "FISA138.ch"   
#INCLUDE "Protheus.ch"   
#INCLUDE "TopConn.ch"

#DEFINE _BUFFER 16384

/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISA138  ³ Autor ³ TOTVS               ³ Data ³ 08.05.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a partir de um arquivo CSV gerado                 ³±±
±±³          ³ atualizando as aliquotas de percepcao na tabela            ³±±
±±³          ³ SFH (ingressos brutos).                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ Fiscal - Cordoba - Argentina                               ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   

Function FISA138()

Local   cCombo := ""
Local   aCombo := {}
Local   oDlg   := Nil
Local   oFld   := Nil
Private cDia   := StrZero(Day(dDataBase),2)
Private cMes   := StrZero(Month(dDataBase),2)
Private cAno   := StrZero(Year(dDataBase),4)
Private lRet   := .T.
Private lCuitSM0 := .F.
Private dDatIni := CTOD("  /  /  ") // Data inicial do periodo enviada no XLS
Private dDatFim := CTOD("  /  /  ") // Data final do periodo enviada no XLS
Private oTmpTable := Nil
Private _SEPARADOR:= ";"

aAdd( aCombo, STR0002 ) //"1- Fornecedor"
aAdd( aCombo, STR0003 ) //"2- Cliente"
aAdd( aCombo, STR0004 ) //"3- Ambos"

DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 250,450 OF oDlg PIXEL //"Dcto. 1205/2015 - IIBB - Padrón Sujetos No Pasibles de Percepción"
	 
	@ 006,006 TO 040,170 LABEL STR0006 OF oDlg PIXEL //"Info. Preliminar"
	
	@ 011,010 SAY STR0007 SIZE 065,008 PIXEL OF oFld //"Arquivo :"
	@ 020,010 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 65,8 PIXEL OF oFld //ON CHANGE ValidChk(cCombo)
	
	//+----------------------   
	//| Campos Check-Up
	//+----------------------
	@ 041,006 FOLDER oFld OF oDlg PROMPT STR0011 PIXEL SIZE 165,075 //"&Importação de Arquivo CSV"
	
	//+----------------
	//| Campos Folder 2
	//+----------------
	@ 005,005 SAY STR0012 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta opcao tem como objetivo atualizar o cadstro    "
	@ 015,005 SAY STR0013 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Fornecedor / Cliente  x Imposto segundo arquivo CSV  "
	@ 025,005 SAY STR0014 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"disponibilizado pelo governo                         "
	@ 045,005 SAY STR0015 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Informe o periodo:"
	@ 045,070 MSGET cDia PICTURE "@E 99" VALID !Empty(cDia) SIZE  010,008 PIXEL OF oFld:aDialogs[1]	        
	@ 045,085 SAY "/" SIZE  150, 10 PIXEL OF oFld:aDialogs[1]
	@ 045,090 MSGET cMes PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1]	                                          
	@ 045,105 SAY "/" SIZE  150, 10 PIXEL OF oFld:aDialogs[1]
	@ 045,110 MSGET cAno PICTURE "@E 9999" VALID !Empty(cAno) SIZE 020,008 PIXEL OF oFld:aDialogs[1]
	
	//+-------------------
	//| Boton de MSDialog
	//+-------------------
	@ 055,178 BUTTON STR0016 SIZE 036,016 PIXEL ACTION ImpArq(aCombo,cCombo) //"&Importar"
	@ 075,178 BUTTON STR0018 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"

ACTIVATE MSDIALOG oDlg CENTER

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpArq   ³ Autor ³ TOTVS               ³ Data ³ 08.05.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa a importacao do arquivo.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPar01 - Variavel com as opcoes do combo cliente/fornec.   ³±±
±±³          ³ cPar01 - Variavel com a opcao escolhida do combo.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpArq(aCombo,cCombo)

Local aArqTmp	:= {}	// Arquivo temporario para importacao
Local lRet	 	:= .T.
Local lnoimp := .T.
Private  cFile    := ""
Private lCli     := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivo temporario a partir do XLS importado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Seleciona o arquivo
cFile := FGetFile()
If Empty(cFile)
	Return Nil
EndIf

// Cria e alimenta a tabela temporaria 
Processa({|| lRet := GeraTemp(@aArqTmp)})

If lRet
	If SubStr(cCombo,1,1) $ "1|3" .And. lCuitSM0	// Fornecedor ou Ambos
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processo de valiadacao para Fornecedores ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({|| ProcCliFor("SA2")})
		lnoimp := .F.
	ElseIf ! lCuitSM0 .And. SubStr(cCombo,1,1) <> "2"
		MsgAlert(STR0046) //"Cuit da empresa no esta no archivo"
		lnoimp := .F.	
	EndIf
	If SubStr(cCombo,1,1) $ "2|3" // Cliente ou Ambos
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processo de valiadacao para Clientes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({|| ProcCliFor("SA1")})
	EndIf
	
	If lnoimp
		MsgAlert(STR0041) //"Arquivo importado!"
	ElseIf SubStr(cCombo,1,1) == "3" .And. lCuitSM0 .and. ! lnoimp 
		MsgAlert(STR0047)	 //Arquivo de cliente e fornecedores importado
	ElseIf SubStr(cCombo,1,1) == "3" .And. lCuitSM0	
		MsgAlert(STR0048)	//Somente importado arquivo de cliente, Cuit da empresa nao se encontra no arquivo CSV 
	ElseIf ! lnoimp .And. lCuitSM0
		MsgAlert(STR0050)	//Fornecedores , Arquivo importado !
	Endif
Endif	

TMP->(dbCloseArea())
If oTmpTable <> Nil
	oTmpTable:Delete()
	oTmpTable := Nil
EndIf

Return Nil

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGetFile ³ Autor ³ TOTVS               ³ Data ³ 08.05.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de seleção do arquivo CSV a ser importado.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet - Diretori e arquivo selecionado.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Cordoba Argentina - MSSQL                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGetFile()

	Local cRet := Space(50)
	
	oDlg01 := MSDialog():New(000,000,100,500,STR0043,,,,,,,,,.T.)//"Selecionar arquivo"
	
		oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,,,,,,,.T.,,,,,,,,,,"cRet")
		oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0043,,.T.)//"Selecionar arquivo"
		
		oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
		oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)
	
	oDlg01:Activate(,,,.T.,,,)

Return cRet

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGetDir  ³ Autor ³ TOTVS               ³ Data ³ 08.05.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para procurar e selecionar o arquivo nos diretorios   ³±±
±±³          ³ locais/servidor/unidades mapeadas.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oPar1 - Objeto TGet que ira receber o local e o arquivo    ³±±
±±³          ³         selecionado.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Cordoba Argentina - MSSQL                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGetDir(oTGet)

	Local cDir := ""
	
	cDir := cGetFile(,STR0043,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³GeraTemp     ³ Autor ³ TOTVS                 ³ Data ³07/05/2018  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Gera arquivo temporario a partir do XLS importado               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GeraTemp(ExpC1)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico FISA138                                               ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function GeraTemp(aArqTmp)
Local aInforma   := {} 									// Array auxiliar com as informacoes da linha lida no arquivo XLS
Local aCampos    := {}         							// Array auxiliar para criacao do arquivo temporario
Local aIteAge    := {}         							// Array de itens selecionaveis na tela de Wizard
Local cArqProc   := cFile									// Arquivo a ser importado selecionado na tela de Wizard
Local cTitulo    := STR0008								// "Problemas na Importação de Arquivo"
Local cErro	     := ""   								// Texto de mensagem de erro ocorrido na validacao do arquivo a ser importado
Local cSolucao   := ""           						// Texto de solucao proposta em relacao a algum erro ocorrido na validacao do arquivo a ser importado
Local lArqValido := .T.                               	// Determina se o arquivo XLS esta ok para importacao
Local nInd       := 0                   				// Indexadora de laco For/Next
Local nHandle    := 0            						// Numero de referencia atribuido na abertura do arquivo XLS
Local nTam       := 0 									// Tamanho de buffer do arquivo XLS
Local cDelimit	 := ""  
Local cMsg		 := STR0024  
Local nI 		 := 0
Local oFile
Local nFor		 := 0
Local cBuffer    := ""
Local aArea      := ""

lRet := .T. // Determina a continuidade do processamento como base nas informacoes da tela de Wizard 						

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o arquivo temporario para a importacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//*************Modelo do arquivo*************
//Cuit|Denominacion|Nro Inscricion|Fecha Inicio|Fecha Hasta
AADD(aCampos,{"CUIT"	  ,"C",TamSX3("A2_CGC")[1],0})

oTmpTable := FWTemporaryTable():New("TMP")
oTmpTable:SetFields( aCampos )
aOrdem	:=	{"CUIT"}

oTmpTable:AddIndex("TMP", aOrdem)
oTmpTable:Create() 

dDatIni := CTOD(cDia +"/"+ cMes +"/"+ cAno)
dDatFim := CTOD("  /  /  ")


If File(cArqProc) .And. lRet

	nHandle := FT_FUse(cArqProc)
	
	If nHandle > 0 
		//Se posiciona en la primera línea
		FT_FGoTop()
		cBuffer := FT_FREADLN()
		cBuffer := Alltrim(cBuffer)
		If "," $ cBuffer
			cDelimit := ","
		ElseIf ";" $ cBuffer
			cDelimit := ";"
		Endif
		_SEPARADOR := Iif(!Empty(cDelimit),cDelimit,_SEPARADOR)
		nFor := FT_FLastRec()	
		FT_FUSE()	
	Else
		lArqValido := .F.	
		cErro	   := STR0037 + cArqProc + STR0038	//"Não foi possível efetuar a abertura do arquivo: "
		cSolucao   := STR0045 			//"Verifique se foi informado o arquivo correto para importação"
	EndIf

	If lArqValido 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera arquivo temporario a partir do arquivo XLS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oFile := FWFileReader():New(cArqProc)
		// Se hay error al abrir el archivo
		If !oFile:Open()
			MsgAlert(STR0037 + cArqProc + STR0038)  //"El archivo" CGF "no puede abrirse."
			Return .F.
		EndIf
		
		ProcRegua(nFor)
		oFile:setBufferSize(_BUFFER)
		
		While (!oFile:Eof())
		 	nI++
		 	IncProc(cMsg + str(nI))	        

			cBuffer := oFile:GetLine()
			cBuffer := Alltrim(cBuffer)
		
			aInforma := {} 
			aInforma := separa(cBuffer,_SEPARADOR)
				
        	TMP->( DBAppend(.F.) )
  	  			TMP->CUIT		:= STRTRAN(aInforma[1],"-", "")
			TMP->( DBCommit() )
			
		Enddo
	Endif
	
	TMP->(dbGoTop())		
	// Fecha o Arquivo
	oFile:Close()	

	If Empty(cErro) .and. TMP->(LastRec())==0     
		cErro		:= STR0044	//"La importación no se realizó por no existir información en el archivo informado."
		cSolucao	:= STR0045	//"Verifique se foi informado o arquivo correto para importação"
	Endif
	
Else

	cErro	   := STR0037 + cArqProc + STR0038	//"Não foi possível efetuar a abertura do arquivo: "
	cSolucao   := STR0045 			//"Verifique se foi informado o arquivo correto para importação"
EndIf
	 
If !Empty(cErro)

	xMagHelpFis(cTitulo,cErro,cSolucao)

	lRet := .F.
	
Endif

//Se realiza la busqueda por CUIT en la tabla Temporal 
aArea := GetArea()
dbSetOrder(1)
If TMP->(dbSeek(SM0->M0_CGC))
    lCuitSM0 := .T.	  					
EndIf
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcCliFor³ Autor ³ TOTVS                 ³ Data ³ 19/09/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa os arquivos de clientes/fornecedores para          ³±±
±±³          ³aplicacao das regras de validacao para agente retenedor     ³±±
±±³          ³em relacao ao arquivo enviado                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ProcCliFor(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Alias da tabela a ser processada(SA1/SA2)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico - FISA135                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcCliFor(cAlias)
Local aArea     := GetArea()			// Salva area atual para posterior restauracao
Local lCli      := (cAlias=="SA1")		// Determina se a rotina foi chamada para processar o arquivo de clientes ou fornecedores
Local cPrefTab  := Substr(cAlias,2,2)	// Prefixo para acesso dos campos

dbSelectArea(cAlias)
(cAlias)->(dbGoTop())
    
ProcRegua(RecCount())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Loop para varrer arquivo de Cliente ou Fornecedor e validar se existe no arquivo XLS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Eof()

	IncProc(Iif(lCli,STR0029,STR0031))	//##""Incluyendo Cliente"/"Incluyendo Proveedor"
        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Trava registro de fornecedor para atualizacoes referentes ao Retencion SUSS  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lCli
		RecLock("SA2",.F.)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Verifica se o cliente/fornecedor consta no arquivo temporario - ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If TMP->(MsSeek((cAlias)->&(cPrefTab+"_CGC")))

		While TMP->CUIT == (cAlias)->&(cPrefTab+"_CGC")
			
			PesqSFH(Iif(cAlias=="SA1",3,1),(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IB8",lCli,.T.)
			TMP->(dbSkip())
			
		EndDo	
				
	Else 
		
		PesqSFH(Iif(cAlias=="SA1",3,1),(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IB8",lCli,.F.)	
		
	EndIf	
	
	If !lCli
		MsUnLock()
	EndIf

	dbSkip()
	
EndDo

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³PesqSFH     ³ Autor ³ Totvs                   ³ Data ³07/05/18  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Pesquisa existencia de registros na tabela SFH(Ingressos Brutos)³±±
±±³          ³referente ao cliente ou forcedor passado como parametro         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PesqSFH(ExpN1,ExpC1,ExpL1,ExpL2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Ordem do indice da tabela SFH                           ³±±
±±³          ³ExpC1 = Chave de pesquisa para a tabela SFH                     ³±±
±±³          ³ExpL1 = Determina se a pesquisa trata cliente ou fornecedor     ³±±
±±³          ³ExpL2 = Determina se Cliente/Fornecedor consta no XLS/CSV       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico - FISA138                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function PesqSFH(nOrd,cKeySFH,lCli,lExistTXT)
Local aArea    := GetArea()		// Salva area atual para posterior restauracao
Local lRet     := .T.			// Conteudo e retorno
Local lIncSFH  := lExistTXT		// Determina se deve ser incluido um novo registro na tabela SFH
Local lAtuSFH  := .F.			// Determina se deve atualizar a tabela SFH
Local nRegSFH  := 0				// Numero do registros correspondente ao ultimo periodo de vigencia na SFH
Local cSitSFH  := ""
Local cFil     := ""
Local cTipo    := ""
Local cPerc    := ""
Local cIsent   := ""
Local cAperib  := ""
Local cImp     := ""
Local nPercent := ""
Local cAliq    := ""
Local cAgent   := ""
Local cSituac  := ""
Local cZonfis  := ""
Local cFilSFH  := xFilial("SFH")

dbSelectArea("SFH")
DbSetOrder(nOrd) 
SFH->(DbGoTo(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro do Cliente ou Fornecedor na tabela SFH ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
If 	SFH->(MsSeek(cFilSFH+cKeySFH))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Loop para pegar o registro referente ao periodo vigente do cliente ou fornecedor na tabela SFH ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lExistTXT
		While cFilSFH+cKeySFH==SFH->FH_FILIAL+Iif(lCli,SFH->FH_CLIENTE,SFH->FH_FORNECE)+SFH->FH_LOJA +SFH->FH_IMPOSTO
			If Empty (SFH->FH_INIVIGE) .And. Empty(SFH->FH_FIMVIGE) //Situação 1
				lIncSFH:= .F.
				lAtuSFH := .F.
				cSitSFH := "1"            
				If SFH->FH_ISENTO == "S"
					cSitSFH := "0"
				Else
					Reclock("SFH",.F.) 
						SFH->FH_FIMVIGE := (dDatIni - 1)
					MsUnLock()
				EndIf
				nRegSFH := SFH->(Recno()) 
			ElseIf Empty (SFH->FH_INIVIGE) .And. ! Empty (SFH->FH_FIMVIGE) //Situação 2
				lIncSFH:= .F.
				cSitSFH := "2"            
				If SFH->FH_ISENTO == "S"
					cSitSFH := "0"
				Else
					Reclock("SFH",.F.) 
						SFH->FH_FIMVIGE := (dDatIni - 1)
					MsUnLock()		
				EndIf
				nRegSFH := SFH->(Recno())
			ElseIf ! Empty(SFH->FH_INIVIGE) .And. Empty (SFH->FH_FIMVIGE)  //Situação 3
				lIncSFH:= .F.	
				cSitSFH := "3"            
				If SFH->FH_ISENTO == "S"
					cSitSFH := "0"
				Else
					Reclock("SFH",.F.) 
						SFH->FH_FIMVIGE := (dDatIni - 1)
					MsUnLock()
				EndIf
				nRegSFH := SFH->(Recno())
			ElseIf (! Empty(SFH->FH_INIVIGE) .And. ! Empty(SFH->FH_FIMVIGE)) //Situação 4
				lIncSFH:= .F.	
				cSitSFH := "4" 
				If SFH->FH_ISENTO == "S"
					cSitSFH := "0"
				Else	
					Reclock("SFH",.F.)
						SFH->FH_FIMVIGE := (dDatIni - 1)
					MsUnLock()	         
				Endif	
				nRegSFH := SFH->(Recno())
			EndIf
			
			SFH->(DbSkip())
				
		EndDo
		
	Else

		While cFilSFH+cKeySFH==SFH->FH_FILIAL+Iif(lCli,SFH->FH_CLIENTE,SFH->FH_FORNECE)+SFH->FH_LOJA +SFH->FH_IMPOSTO
			If Empty (SFH->FH_INIVIGE) .And. Empty(SFH->FH_FIMVIGE) //Situação 1
				lIncSFH:= .F.
				cSitSFH := "1"   
				If SFH->FH_ISENTO == "N" .Or. (SFH->FH_ISENTO == "S" .And. SFH->FH_TIPO <> "M")
					cSitSFH := "0"
				Else
					Reclock("SFH",.F.)            
						SFH->FH_FIMVIGE := (dDatIni-1)
					MsUnLock()
				EndIf         
				nRegSFH := SFH->(Recno()) 
			ElseIf Empty (SFH->FH_INIVIGE) .And. ! Empty (SFH->FH_FIMVIGE) //Situação 2
				lIncSFH:= .F.
				cSitSFH := "2"   
				If SFH->FH_ISENTO == "N" .Or. (SFH->FH_ISENTO == "S" .And. SFH->FH_TIPO <> "M")
					cSitSFH := "0"
				Else
					Reclock("SFH",.F.)            
						SFH->FH_FIMVIGE := (dDatIni-1)
					MsUnLock()	
				EndIf         
				nRegSFH := SFH->(Recno())
			ElseIf ! Empty(SFH->FH_INIVIGE) .And. Empty (SFH->FH_FIMVIGE)  //Situação 3
				lIncSFH:= .F.
				cSitSFH := "3"            
				If SFH->FH_ISENTO == "N" .Or. (SFH->FH_ISENTO == "S" .And. SFH->FH_TIPO <> "M")
					cSitSFH := "0"
				Else
					Reclock("SFH",.F.)            
						SFH->FH_FIMVIGE := (dDatIni-1)
					MsUnLock()
				EndIf
				nRegSFH := SFH->(Recno())
			ElseIf (! Empty(SFH->FH_INIVIGE) .And. ! Empty(SFH->FH_FIMVIGE)) //Situação 4
				lIncSFH:= .F.
				cSitSFH := "4"            
				If SFH->FH_ISENTO == "N" .Or. (SFH->FH_ISENTO == "S" .And. SFH->FH_TIPO <> "M")
					cSitSFH := "0"
				Else
					Reclock("SFH",.F.)           
						SFH->FH_FIMVIGE := (dDatIni-1)
					MsUnLock()	
				EndIf
				nRegSFH := SFH->(Recno())
			EndIf
			
			SFH->(DbSkip())
				
		EndDo
		
	Endif
	
	SFH->(dbGoto(nRegSFH))
	
	If lExistTXT
	
		If cSitSFH == "1" .And. (dDatIni == SFH->FH_INIVIGE .And. dDatFim == SFH->FH_FIMVIGE)
			cSitSFH := "0"
		ElseIf cSitSFH == "2" .And. SFH->FH_FIMVIGE <> (dDatIni-1)
			cSitSFH := "0"
		ElseIf cSitSFH == "3" .And. (dDatIni == SFH->FH_INIVIGE .And. dDatFim == SFH->FH_FIMVIGE)
		  	cSitSFH := "0" 
		ElseIf cSitSFH == "4" .And. (dDatFim == SFH->FH_FIMVIGE)  	
			cSitSFH := "0"
		Endif
		
	Else
	
		If cSitSFH == "1" .And. SFH->FH_FIMVIGE <> (dDatIni-1) 
			cSitSFH := "0"
		ElseIf cSitSFH == "2" .And. SFH->FH_FIMVIGE <> (dDatIni-1)
			cSitSFH := "0"
		ElseIf cSitSFH == "3" .And. SFH->FH_FIMVIGE <> (dDatIni-1)
		  	cSitSFH := "0" 
		ElseIf cSitSFH == "4" .And. SFH->FH_FIMVIGE <> (dDatIni-1)  	
			cSitSFH := "0"
		Endif
	
	Endif	
	
	cFil    := SFH->FH_FILIAL 
	cTipo   := SFH->FH_TIPO   
	cPerc   := SFH->FH_PERCIBI
	cIsent  := SFH->FH_ISENTO 
	cAperib := SFH->FH_APERIB 
	cImp    := "IB8"			
	nPercent:= SFH->FH_PERCENT
	cAliq   := SFH->FH_ALIQ	 
	cAgent  := SFH->FH_AGENTE 
	cSituac := SFH->FH_SITUACA
	cZonfis := "CO"
	
	If lExistTXT
		nPercent := 0
		cIsent   := "S"
		cTipo    := "M"
	Else
		nPercent := 0
		cIsent   := "N"
	EndIf
		
EndIf

If lExistTXT	

	If lIncSFH .And. lCli
		Reclock("SFH",.T.)
		SFH->FH_FILIAL  := cFilSFH
		SFH->FH_TIPO    := "M"
		SFH->FH_PERCIBI := "N"
		SFH->FH_ISENTO  := "S"
		SFH->FH_APERIB  := "N"
		SFH->FH_IMPOSTO := "IB8"
		SFH->FH_PERCENT := 0
		SFH->FH_ALIQ	:= 0
		SFH->FH_INIVIGE := dDatIni  
		SFH->FH_FIMVIGE := dDatFim
		SFH->FH_AGENTE  := "N"
		SFH->FH_SITUACA := "1"
		SFH->FH_ZONFIS  := "CO"
		If lCli
			SFH->FH_CLIENTE := SA1->A1_COD
			SFH->FH_LOJA    := SA1->A1_LOJA
			SFH->FH_NOME    := SA1->A1_NOME
		Else	
			SFH->FH_LOJA    := SA2->A2_LOJA
			SFH->FH_FORNECE := SA2->A2_COD
			SFH->FH_NOME    := SA2->A2_NOME
		EndIf
		MsUnLock()
		
	EndIf
	
	GrvSFH138(lCli,lExistTXT,cSitSFH,cFil,cTipo,cPerc,cIsent,cAperib,cImp,nPercent,cAliq,dDatIni,dDatFim,cAgent,cSituac,cZonfis)
Else

	GrvSFH138(lCli,lExistTXT,cSitSFH,cFil,cTipo,cPerc,cIsent,cAperib,cImp,nPercent,cAliq,dDatIni,dDatFim,cAgent,cSituac,cZonfis)	

Endif

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³GrvSFH138     ³ Autor ³ Totvs                 ³ Data ³15/05/18  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Função utilizada para gravar os dados da tabela SFH conforme    ³±±
±±³          ³regra informada na especificação                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GrvSFH138(lCli,lExistTXT,cSitSFH,cFil,cTipo,cPerc,cIsent,       ³±±
±±³cAperib,cImp,cPercent,cAliq,dDatIni,dDatFim,cAgent,cSituac,cZonfis)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lCli = Indica se é cliente ou fornecedor                        ³±±
±±³          ³lExistTXT = Indica se o cliente ou fornecedor existe no arquivo ³±±
±±³          ³cSitSFH = Indicia a situação do registro na tabela SFH          ³±±
±±³          ³cFil,cTipo,cPerc,cIsent,cAperib,cImp,cPercent,cAliq,dDatIni,    ³±±    
±±³          ³dDatFim,cAgent,cSituac,cZonfis = informações gravadas na tabela ³±±
±±³          ³SFH para criar um novo registro similar atualizado              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico - FISA138                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Static Function GrvSFH138(lCli,lExistTXT,cSitSFH,cFil,cTipo,cPerc,cIsent,cAperib,cImp,nPercent,cAliq,dDatIni,dDatFim,cAgent,cSituac,cZonfis)

Default lCli := .T.
Default lExistTXT := .T.
Default cSitSFH := "0"
Default cFil := ""
Default cTipo := ""
Default cPerc := ""
Default cIsent := ""
Default cAperib := "" 
Default cImp := ""
Default nPercent := 0
Default cAliq := ""
Default dDatIni := CTOD("  /  /  ")
Default dDatFim := CTOD("  /  /  ")
Default cAgent:= ""
Default cSituac := ""
Default cZonfis := ""

If lExistTXT
	If cSitSFH $ "1|2|3|4" 
		Reclock("SFH",.T.)
		SFH->FH_FILIAL  := cFil
		SFH->FH_TIPO    := cTipo
		SFH->FH_PERCIBI := cPerc
		SFH->FH_ISENTO  := cIsent
		SFH->FH_APERIB  := cAperib
		SFH->FH_IMPOSTO := cImp
		SFH->FH_PERCENT := nPercent
		SFH->FH_ALIQ	  := cAliq
		SFH->FH_INIVIGE := dDatIni  
		SFH->FH_FIMVIGE := dDatFim
		SFH->FH_AGENTE  := cAgent
		SFH->FH_SITUACA := cSituac
		SFH->FH_ZONFIS := cZonfis	
		If lCli
			SFH->FH_CLIENTE := SA1->A1_COD
			SFH->FH_LOJA    := SA1->A1_LOJA
			SFH->FH_NOME    := SA1->A1_NOME
		Else	
			SFH->FH_LOJA    := SA2->A2_LOJA
			SFH->FH_FORNECE := SA2->A2_COD
			SFH->FH_NOME    := SA2->A2_NOME
		EndIf
		MsUnLock()
	Endif
Else
	If cSitSFH $ "1|2|3|4" 
		Reclock("SFH",.T.)
		SFH->FH_FILIAL  := cFil
		SFH->FH_TIPO    := cTipo
		SFH->FH_PERCIBI := cPerc
		SFH->FH_ISENTO  := cIsent
		SFH->FH_APERIB  := cAperib
		SFH->FH_IMPOSTO := cImp
		SFH->FH_PERCENT := 0
		SFH->FH_ALIQ	  := cAliq
		SFH->FH_INIVIGE := dDatIni  
		SFH->FH_FIMVIGE := CTOD("  /  /  ")
		SFH->FH_AGENTE  := cAgent
		SFH->FH_SITUACA := cSituac
		SFH->FH_ZONFIS := cZonfis	
		If lCli
			SFH->FH_CLIENTE := SA1->A1_COD
			SFH->FH_LOJA    := SA1->A1_LOJA
			SFH->FH_NOME    := SA1->A1_NOME
		Else	
			SFH->FH_LOJA    := SA2->A2_LOJA
			SFH->FH_FORNECE := SA2->A2_COD
			SFH->FH_NOME    := SA2->A2_NOME
		EndIf
		MsUnLock()
	Endif
Endif
			
Return
