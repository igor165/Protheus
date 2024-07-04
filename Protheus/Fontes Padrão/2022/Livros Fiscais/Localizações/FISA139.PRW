#INCLUDE "FISA139.ch"   
#INCLUDE "Protheus.ch"   
#INCLUDE "TopConn.ch"
#INCLUDE "REPORT.CH"

#DEFINE _BUFFER 16384
#DEFINE _SEPARADOR ";"

/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISA139  ³ Autor ³ Raul Ortiz Medina   ³ Data ³ 02.01.2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a partir de um arquivo CSV gerado                 ³±±
±±³          ³ atualizando as aliquotas de percepcao na tabela            ³±±
±±³          ³ SFH (ingressos brutos).                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ Fiscal - Cordoba - Argentina                               ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   

Function FISA139()

Local   cCombo 	:= ""
Local 	cPadron	:= ""
Local   aCombo 	:= {}
Local 	aPadron	:= {}
Local   oDlg   	:= Nil
Local   oFld   	:= Nil
Private cMes   	:= StrZero(Month(dDataBase),2)
Private cAno   	:= StrZero(Year(dDataBase),4)
Private lRet   	:= .T.
Private lCuitSM0:= .F.
Private dDatIni := CTOD("  /  /  ") // Data inicial do periodo enviada no XLS
Private dDatFim := CTOD("  /  /  ") // Data final do periodo enviada no XLS
Private oTmpTable := Nil
Private lAct	:= .F.
Private aProvAct:= {}

aAdd( aCombo, STR0002 ) //"1- Fornecedor"
aAdd( aCombo, STR0003 ) //"2- Cliente"
aAdd( aCombo, STR0004 ) //"3- Ambos"

aAdd( aPadron, STR0005 ) //Alicuota Percepcion incrementada - CL
aAdd( aPadron, STR0006 ) //Alicuota Percepcion incrementada - CM

DEFINE MSDIALOG oDlg TITLE STR0007 FROM 0,0 TO 250,450 OF oDlg PIXEL //"Dcto. 1205/2015 - IIBB - Padrón Sujetos No Pasibles de Percepción"
	 
	@ 006,006 TO 040,170 LABEL STR0008 OF oDlg PIXEL //"Info. Preliminar"
	
	@ 011,010 SAY STR0009 SIZE 065,008 PIXEL OF oFld //"Arquivo :"
	@ 020,010 COMBOBOX oPadron VAR cPadron ITEMS aPadron SIZE 75,8 PIXEL OF oFld //ON CHANGE ValidChk(cCombo)
	@ 020,095 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 65,8 PIXEL OF oFld //ON CHANGE ValidChk(cCombo)
	
	//+----------------------   
	//| Campos Check-Up
	//+----------------------
	@ 041,006 FOLDER oFld OF oDlg PROMPT STR0010 PIXEL SIZE 165,075 //"&Importação de Arquivo CSV"
	
	//+----------------
	//| Campos Folder 2
	//+----------------
	@ 005,005 SAY STR0011 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta opcao tem como objetivo atualizar o cadstro    "
	@ 015,005 SAY STR0012 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Fornecedor / Cliente  x Imposto segundo arquivo CSV  "
	@ 025,005 SAY STR0013 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"disponibilizado pelo governo                         "
	@ 045,005 SAY STR0014 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Informe o periodo:"      
	@ 045,070 MSGET cMes PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1]	                                          
	@ 045,085 SAY "/" SIZE  150, 10 PIXEL OF oFld:aDialogs[1]
	@ 045,090 MSGET cAno PICTURE "@E 9999" VALID !Empty(cAno) SIZE 020,008 PIXEL OF oFld:aDialogs[1]
	
	//+-------------------
	//| Boton de MSDialog
	//+-------------------
	@ 055,178 BUTTON STR0015 SIZE 036,016 PIXEL ACTION ImpArq(cPadron,cCombo) //"&Importar"
	@ 075,178 BUTTON STR0016 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"

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
Static Function ImpArq(cPadron,cCombo)

Local aArqTmp	:= {}	// Arquivo temporario para importacao
Local lRet	 	:= .T.
Local lnoimp 	:= .T.
Private  cFile  := ""
Private lCli	:= .F.

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
	If SubStr(cCombo,1,1) $ "1|3"// Fornecedor ou Ambos
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processo de valiadacao para Fornecedores ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({|| ProcCliFor("SA2",SubStr(cPadron,1,1))})
	EndIf
	If SubStr(cCombo,1,1) $ "2|3" // Cliente ou Ambos
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processo de valiadacao para Clientes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({|| ProcCliFor("SA1",SubStr(cPadron,1,1))})
	EndIf
	
	
	If lAct
		MsgInfo(STR0026)  //"Proceso finalizado con éxito!"
	Else
		MsgAlert(STR0028)  //"El proceso no finalizo correctamente, verifique el archivo."
	EndIf
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

	Local cRet := Space(150)
	
	oDlg01 := MSDialog():New(000,000,100,500,STR0017,,,,,,,,,.T.)//"Selecionar arquivo"
	
		oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,,,,,,,.T.,,,,,,,,,,"cRet")
		oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0017,,.T.)//"Selecionar arquivo"
		
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
	
	cDir := cGetFile(,STR0017,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
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
Local cErro	     := ""   								// Texto de mensagem de erro ocorrido na validacao do arquivo a ser importado
Local cSolucao   := ""           						// Texto de solucao proposta em relacao a algum erro ocorrido na validacao do arquivo a ser importado
Local lArqValido := .T.                               	// Determina se o arquivo XLS esta ok para importacao
Local nInd       := 0                   				// Indexadora de laco For/Next
Local nHandle    := 0            						// Numero de referencia atribuido na abertura do arquivo XLS
Local nTam       := 0 									// Tamanho de buffer do arquivo XLS
Local cDelimit	 := ""  
Local cMsg		 := STR0018  
Local nI 		 := 0
Local oFile
Local nFor		 := 0
Local cBuffer    := ""
Local aArea      := ""
Local cTitulo	 := STR0033

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

dDatIni := CTOD("01" +"/"+ cMes +"/"+ cAno)
dDatFim := CTOD(AllTrim(STR(F_UltDia(dDatIni)))+"/"+ cMes +"/"+ cAno)


If File(cArqProc) .And. lRet

	nHandle := FT_FUse(cArqProc)
	
	If nHandle > 0 
		//Se posiciona en la primera línea
		FT_FGoTop()
		nFor := FT_FLastRec()	
		FT_FUSE()	
	Else
		lArqValido := .F.	
		cErro	   := STR0019 + cArqProc + STR0020	//"Não foi possível efetuar a abertura do arquivo: "
		cSolucao   := STR0021 			//"Verifique se foi informado o arquivo correto para importação"
	EndIf

	If lArqValido 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera arquivo temporario a partir do arquivo XLS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oFile := FWFileReader():New(cArqProc)
		// Se hay error al abrir el archivo
		If !oFile:Open()
			MsgAlert(STR0019 + cArqProc + STR0020)  //"El archivo" CGF "no puede abrirse."
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
		cErro		:= STR0022	//"La importación no se realizó por no existir información en el archivo informado."
		cSolucao	:= STR0023	//"Verifique se foi informado o arquivo correto para importação"
	Endif
	
Else

	cErro	   := STR0019 + cArqProc + STR0020	//"Não foi possível efetuar a abertura do arquivo: "
	cSolucao   := STR0021 			//"Verifique se foi informado o arquivo correto para importação"
EndIf
	 
If !Empty(cErro)

	xMagHelpFis(cTitulo,cErro,cSolucao)

	lRet := .F.
	
Endif

//Se realiza la busqueda por CUIT en la tabla Temporal 
aArea := GetArea()
dbSetOrder(1)
If TMP->(MsSeek(AllTrim(SM0->M0_CGC)))
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
Static Function ProcCliFor(cAlias,cPadron)
Local aArea     := GetArea()			// Salva area atual para posterior restauracao
Local lCli      := (cAlias=="SA1")		// Determina se a rotina foi chamada para processar o arquivo de clientes ou fornecedores
Local cPrefTab  := Substr(cAlias,2,2)	// Prefixo para acesso dos campos
Local cOrigen	:= IIf(lCli,"C","E")
Local cTipo 	:= Iif(cPadron == "1", "I", "V")
Local nI 		:= 0

dbSelectArea(cAlias)
(cAlias)->(dbSetOrder(3))
(cAlias)->(dbGoTop())
    
ProcRegua(RecCount())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Loop para varrer arquivo de Cliente ou Fornecedor e validar se existe no arquivo XLS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(Iif(lCli,STR0024,STR0025))	//##""Incluyendo Cliente"/"Incluyendo Proveedor"

While (cAlias)->(!Eof())
	nI++
	IncProc(Iif(lCli,STR0024,STR0025) + Str(nI))
			
	If Empty((cAlias)->&(cPrefTab+"_CGC"))
		(cAlias)->(dbSkip())
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Verifica se o cliente/fornecedor consta no arquivo temporario - ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lCli .and. TMP->(MsSeek((cAlias)->&(cPrefTab+"_CGC")))
		BuscaSFH(cAlias,lCli,cOrigen,.T.,cTipo)		
	Else 
		BuscaSFH(cAlias,lCli,cOrigen,Iif(lCli,.F.,lCuitSM0),cTipo)		
	EndIf
	(cAlias)->(dbSkip())
	
EndDo

RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±³
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±³
±±³Funcao    ³BuscaSFH  ³Autor  ³Raul Ortiz Medina    ³Data  ³02/01/2019  ³±³
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±³
±±³Descricao ³Busca y actualiza registros en SFH 						  ³±³
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±³
±±³Parametros³cAlias - Tabla temp con los registros obtenidos de SA1/SA2  ³±³
±±³          ³lCli   - Si .T. est?procesando Clientes					  ³±³
±±³          ³			Si .F. est?procesandoProveedores				  ³±³
±±³          ³lExiste- Si .T. se encuentra CUIT de Cliente/Prov en 	      ³±³
±±³          ³			archivo ASCII 									  ³±³
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±³
±±³Retorno   ³Nulo                                                        ³±³
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±³
±±³Uso       ³Fiscal - Argentina 			                  			  ³±³
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±³
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±³
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BuscaSFH(cAlias,lCli,cOrigen,lPadron,cTipo)

	Local aArea		:= GetArea()
	Local cQuery	:= ""	
	Local cSFH		:= InitSqlName("SFH")
	Local cTmp		:= GetNextAlias()                                
	Local cPref		:= IIf(lCli,"A1","A2")
	Local aTmp		:= {}
	Local nReg		:= 0
	Local cPerAux	:= ""
	Local dDataAux	:= CTOD("  /  /  ")

	//Seleccionar cliente o proveedor de SFH  
	cQuery := "SELECT * "
	cQuery += "FROM "
	cQuery +=		cSFH + " SFH " 
	cQuery += 	"WHERE " 
	cQuery += 	"FH_FILIAL ='" + xFilial("SFH") + "' AND "
	If  lCli	
		cQuery +=  	"FH_CLIENTE='" + (cAlias)->A1_COD	  	+ "' AND "
		cQuery += 	"FH_LOJA   ='" + (cAlias)->A1_LOJA   	+ "' AND "
	Else      
		cQuery +=  	"FH_FORNECE='" + (cAlias)->A2_COD		+ "' AND "
		cQuery += 	"FH_LOJA   ='" + (cAlias)->A2_LOJA   	+ "' AND "
	EndIf
	cQuery +=	"FH_IMPOSTO = 'IB8' AND "
	cQuery += 	"FH_ZONFIS  = 'CO'  AND " 
	cQuery +=	"D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY "//FH_FIMVIGE DESC, FH_INIVIGE DESC"
	cQuery += "FH_INIVIGE DESC " 

	cQuery := ChangeQuery(cQuery)                    
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 

	Count to nCont
	(cTmp)->(dbGoTop())
	
	If nCont > 0 //Actualizar registro
		If lPadron
			If (Empty((cTmp)->FH_INIVIGE) .and. Empty((cTmp)->FH_FIMVIGE)) .or. (!Empty((cTmp)->FH_INIVIGE) .and. Empty((cTmp)->FH_FIMVIGE))
				If (cTmp)->FH_SITUACA <> "5"
					If lCli
						NewReg((cTmp)->FH_AGENTE,(cAlias)->A1_COD,""	 ,(cAlias)->A1_LOJA,(cAlias)->&(cPref+"_NOME"),cTipo  ,(cTmp)->FH_PERCIBI,"IB8"	,(cTmp)->FH_ALIQ  ,0	   ,"N"	   ,(cTmp)->FH_APERIB,"5",dDatIni,dDatFim)
						aAdd(aProvAct,{(cAlias)->A1_LOJA,(cAlias)->A1_COD,(cAlias)->&(cPref+"_NOME"),(cAlias)->A1_CGC })
					Else
						NewReg((cTmp)->FH_AGENTE,"",(cAlias)->A2_COD	 ,(cAlias)->A2_LOJA,(cAlias)->&(cPref+"_NOME"),cTipo  ,(cTmp)->FH_PERCIBI,"IB8"	,(cTmp)->FH_ALIQ  ,0	   ,"N"	   ,(cTmp)->FH_APERIB,"5",dDatIni,dDatFim)
						aAdd(aProvAct,{(cAlias)->A2_LOJA,(cAlias)->A2_COD,(cAlias)->&(cPref+"_NOME"),(cAlias)->A2_CGC })
					EndIf
					lAct := .T.
				EndIf
			ElseIf (Empty((cTmp)->FH_INIVIGE) .and. !Empty((cTmp)->FH_FIMVIGE)) .or. (!Empty((cTmp)->FH_INIVIGE) .and. !Empty((cTmp)->FH_FIMVIGE))
				If (cTmp)->FH_SITUACA == "5"
					SFH->(DBGOTO((cTmp)->R_E_C_N_O_))
					Reclock("SFH",.F.)
						SFH->FH_FIMVIGE := dDatFim
					SFH->(MsUnlock())
					aAdd(aProvAct,{(cAlias)->&(cPref+"_LOJA"),(cAlias)->&(cPref+"_COD"),(cAlias)->&(cPref+"_NOME"),(cAlias)->&(cPref+"_CGC") })
					lAct := .T.
				Else
					SFH->(DBGOTO((cTmp)->R_E_C_N_O_))
					dDataAux := Iif (CTOD((cTmp)->FH_FIMVIGE) > dDatFim, CTOD((cTmp)->FH_FIMVIGE) ,dDatFim)
					Reclock("SFH",.F.)
						SFH->FH_FIMVIGE := dDatIni - 1
					SFH->(MsUnlock())
					If lCli
						NewReg((cTmp)->FH_AGENTE,(cAlias)->A1_COD,""	 ,(cAlias)->A1_LOJA,(cAlias)->&(cPref+"_NOME"),cTipo  ,(cTmp)->FH_PERCIBI,"IB8"	,(cTmp)->FH_ALIQ  ,0	   ,"N"	   ,(cTmp)->FH_APERIB,"5",dDatIni,dDataAux)
						aAdd(aProvAct,{(cAlias)->A1_LOJA,(cAlias)->A1_COD,(cAlias)->&(cPref+"_NOME"),(cAlias)->A1_CGC })
					Else
						NewReg((cTmp)->FH_AGENTE,"",(cAlias)->A2_COD	 ,(cAlias)->A2_LOJA,(cAlias)->&(cPref+"_NOME"),cTipo  ,(cTmp)->FH_PERCIBI,"IB8"	,(cTmp)->FH_ALIQ  ,0	   ,"N"	   ,(cTmp)->FH_APERIB,"5",dDatIni,dDataAux)
						aAdd(aProvAct,{(cAlias)->A2_LOJA,(cAlias)->A2_COD,(cAlias)->&(cPref+"_NOME"),(cAlias)->A2_CGC })
					EndIf
					lAct := .T.
				EndIf
			EndIf
		Else
			If (cTmp)->FH_SITUACA == "5"
				SFH->(DBGOTO((cTmp)->R_E_C_N_O_))
				dDataAux := Iif (CTOD((cTmp)->FH_FIMVIGE) > dDatFim, CTOD((cTmp)->FH_FIMVIGE) ,dDatFim)
				Reclock("SFH",.F.)
					SFH->FH_FIMVIGE := dDatIni - 1
				SFH->(MsUnlock())
				If lCli
					NewReg((cTmp)->FH_AGENTE,(cAlias)->A1_COD,""	 ,(cAlias)->A1_LOJA,(cAlias)->&(cPref+"_NOME"),(cTmp)->FH_TIPO  ,(cTmp)->FH_PERCIBI,"IB8"	,(cTmp)->FH_ALIQ  ,0	   ,"N"	   ,(cTmp)->FH_APERIB,"1",dDatIni,dDataAux)
					aAdd(aProvAct,{(cAlias)->A1_LOJA,(cAlias)->A1_COD,(cAlias)->&(cPref+"_NOME"),(cAlias)->A1_CGC })
				Else
					NewReg((cTmp)->FH_AGENTE,"",(cAlias)->A2_COD	 ,(cAlias)->A2_LOJA,(cAlias)->&(cPref+"_NOME"),(cTmp)->FH_TIPO  ,(cTmp)->FH_PERCIBI,"IB8"	,(cTmp)->FH_ALIQ  ,0	   ,"N"	   ,(cTmp)->FH_APERIB,"1",dDatIni,dDataAux)
					aAdd(aProvAct,{(cAlias)->A2_LOJA,(cAlias)->A2_COD,(cAlias)->&(cPref+"_NOME"),(cAlias)->A2_CGC })
				EndIf
				lAct := .T.
			EndIf
		EndIf	  
	Else
		If lPadron .and. cOrigen == "C" 
			NewReg("N",(cAlias)->A1_COD,"",(cAlias)->A1_LOJA,(cAlias)->&(cPref+"_NOME"),cTipo,"S","IB8",0,0,"N","N","5",dDatIni,dDatFim)
			aAdd(aProvAct,{(cAlias)->A1_LOJA,(cAlias)->A1_COD,(cAlias)->&(cPref+"_NOME"),(cAlias)->A1_CGC })
			lAct := .T. 
		EndIf	  

		
	Endif 

	(cTmp)->(dbCloseArea())
	RestArea(aArea)
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NewReg    ³Autor  ³Raúl Ortiz           ³Data  ³11/10/2018  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Crea un nuevo registro en la SFH      					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAgente - Indica si es agente o no                          ³±±
±±³          ³cCliente  - Si es cliente se informa el código 		      ³±±
±±³          ³cFornec   - Si es proveedor se informa el código	    	  ³±±
±±³          ³cLoja - Se informa la loja correspondiente Cliente/Proveedor³±±
±±³          ³cNome   - Nombre Cliente/Proveedor     					  ³±±
±±³          ³cTipo   - Tipo de contribuyente       					  ³±±
±±³          ³cPercibi   - sistema es agente recaudador (S/N)   		  ³±±
±±³          ³cImposto   - Clave del impuesto (IB2, IBP, IBR, etc.)	      ³±±
±±³          ³nAliq   - Alicuota                     					  ³±±
±±³          ³nPercent   - Porcentaje de exencion.    					  ³±±
±±³          ³cIsento   - Exento (S/N)               					  ³±±
±±³          ³cAperIb   - Agente de recaudaciones Cliente/Proveedor (S/N) ³±±
±±³          ³cSituaca - Situación del Cliente/Proveedor				  ³±±
±±³          ³dIniVige   - Fecha de inicio de vigencia					  ³±±
±±³          ³dFimVige   - Fecha de fin de vigencia 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nulo                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Fiscal - Argentina 			                  			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß /*/
Static Function NewReg(cAgente,cCliente,cFornec,cLoja,cNome,cTipo,cPercibi,cImposto,nAliq,nPercent,cIsento,cAperIb,cSituaca,dIniVige,dFimVige)
Default cAgente		:= ""
Default cCliente	:= ""
Default cFornec		:= ""
Default cLoja		:= ""
Default cNome		:= ""
Default cTipo		:= ""
Default cPercibi	:= ""
Default cImposto	:= ""
Default nAliq		:= 0
Default nPercent	:= 0
Default cIsento		:= ""
Default cAperIb		:= ""
Default cSituaca	:= ""
Default dIniVige	:= CTOD("//")
Default dFimVige	:= CTOD("//")

	Reclock("SFH",.T.)
		SFH->FH_FILIAL	:= xFilial("SFH")
		SFH->FH_AGENTE	:= cAgente
		SFH->FH_CLIENTE	:= cCliente
		SFH->FH_FORNECE	:= cFornec
		SFH->FH_LOJA	:= cLoja
		SFH->FH_NOME	:= cNome
		SFH->FH_TIPO	:= cTipo
		SFH->FH_PERCIBI	:= cPercibi
		SFH->FH_ZONFIS	:= "CO"
		SFH->FH_IMPOSTO	:= cImposto
		SFH->FH_ALIQ	:= nAliq
		SFH->FH_PERCENT	:= nPercent
		SFH->FH_ISENTO	:= cIsento
		SFH->FH_APERIB	:= cAperIb
		SFH->FH_SITUACA	:= cSituaca
		SFH->FH_INIVIGE	:= dIniVige
		SFH->FH_FIMVIGE	:= dFimVige
	SFH->(MsUnlock())
Return