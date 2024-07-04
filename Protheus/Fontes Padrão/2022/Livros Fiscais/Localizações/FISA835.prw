#include "FISA835.ch" 
#include 'protheus.ch'
#include 'parmtype.ch'
#include "TopConn.ch"

/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISA835  ³ Autor ³ DANILO SANTOS       ³ Data ³ 14.10.2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ :RG 12-18 – IIBB - Retenciones y Percepciones – Exclusion  ³±±
±±³Actualizar los registros SFH cuyos titulares (CUITs)                   ³±±
±±³se encuentran identificados en el Padrón de Exentos de                 ³±± 
±±³Retenciones/Percepciones de IIBB de la Provincia de Santa Fe,          ³±±
±±³informando la situación de “exento temporariamente de                  ³±±
±±³retención y percepción de IIBB” correspondiente a la                   ³±±
±±³fecha informada em los parámetros                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Uso       ³ Fiscal - Santa Fé - Argentina                              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   

Function FISA835()

Local   cCombo := ""
Local   aCombo := {}
Local	 aTipo:= {}
Local   oDlg   := Nil
Local   oFld   := Nil
Private cMes   := StrZero(Month(dDataBase),2)
Private cAno   := StrZero(Year(dDataBase),4)
Private cTipo := ""
Private lRet   := .T.
Private lPer   := .T.
Private lCuitSM0 := .F.
Private dDatIni := CTOD("  /  /  ") 
Private dDatFim := CTOD("  /  /  ") 

aAdd( aTipo, STR0002 ) //Percepiciones
aAdd( aTipo, STR0003 ) //Retenciones
aAdd( aTipo, STR0004 ) //Ambos

DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 250,450 OF oDlg PIXEL //RG 12-18 – IIBB - Retenciones y Percepciones
	 
	@ 006,006 TO 040,170 LABEL STR0006 OF oDlg PIXEL //"Info. Preliminar"
	@ 011,010 SAY STR0007 SIZE 065,008 PIXEL OF oFld //"Arquivo :"
	@ 020,010 COMBOBOX oCombo VAR cTipo ITEMS aTipo SIZE 65,8 PIXEL OF oFld //ON CHANGE ValidChk(cCombo)
	
	//+----------------------   
	//| Campos Check-Up
	//+----------------------
	@ 041,006 FOLDER oFld OF oDlg PROMPT STR0011 PIXEL SIZE 165,075 //"&Importação de Arquivo CSV"
	
	//+----------------
	//| Campos Folder 2
	//+----------------
	@ 005,005 SAY STR0012 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta opcao tem como objetivo atualizar o cadastro    "
	@ 015,005 SAY STR0013 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Fornecedor / Cliente                                 "
	@ 025,005 SAY STR0014 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"disponibilizado pelo governo                         "
	@ 045,005 SAY STR0015 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Informe o periodo:"
	@ 045,055 MSGET cMes PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1]	                                          
	@ 045,070 SAY "/" SIZE  150, 8 PIXEL OF oFld:aDialogs[1]
	@ 045,075 MSGET cAno PICTURE "@E 9999" VALID !Empty(cMes) SIZE 020,008 PIXEL OF oFld:aDialogs[1]
	
	//+-------------------
	//| Boton de MSDialog
	//+-------------------
	@ 055,178 BUTTON STR0016 SIZE 036,016 PIXEL ACTION ImpArq(aCombo,cTipo) //"&Importar"
	@ 075,178 BUTTON STR0017 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"

ACTIVATE MSDIALOG oDlg CENTER

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpArq   ³ Autor ³ TOTVS               ³ Data ³ 19.10.2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa a importacao do arquivo.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPar01 - Variavel com as opcoes do combo cliente/fornec.   ³±±
±±³          ³ cPar01 - Variavel com a opcao escolhida do combo.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Santa Fé - Argentina                              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpArq(aCombo,cTipo)

Local   cLine    := ""
Local cAliasTMP	:= ""	// Alias atribuido ao arquivo temporario
Local lRet	 	:= .T.
Local lnoimp := .T.
Local lProcCli := .F.
Local lProcFor := .F.
Local lProCAmb := .F.
Local cImptxt := ""
Private  cFile    := ""
Private lFor     := .F.
Private lCli     := .F.
Private lImp     := .F.
Private oTmpTable	:= Nil	// Arquivo temporario para importacao

Default aCombo := {}
Default cTipo := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivo temporario a partir do XLS importado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Seleciona o arquivo
cFile := FGetFile()
If Empty(cFile)
	Return Nil
EndIf

// Cria e alimenta a tabela temporaria 
Processa({|| lRet := GeraTemp(@oTmpTable)})

dDatIni := CTOD("01/"+cMes+"/"+cAno) 
dDatFim := LastDay(dDatIni) 

If lRet
	If Substr(cTipo,1,1) $ "1|3" .Or. lCuitSM0// Cliente/Fornecedor - Percepção Ambos.
		cImptxt := "P"
		//³Processo de valiadacao para Clientes³
		Processa({|| PercCliFor(cImptxt,"SA1")})
		If lCuitSM0
			//³Processo de valiadacao para Fornecedores³
			Processa({|| PercCliFor(cImptxt,"SA2")})
		Endif
	Endif
	If SubStr(cTipo,1,1) $ "2|3"  //Fornecedor - Retenção
		cImptxt := "R"
		//³Processo de valiadacao para Fornecedores ³
		Processa({|| ProcRetFor(cImptxt,"SA2")})
	EndIf
Endif	
Msginfo(STR0020)
oTmpTable:Delete()

Return Nil

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGetFile ³ Autor ³ TOTVS               ³ Data ³ 19.10.2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de seleção do arquivo CSV a ser importado.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet - Diretori e arquivo selecionado.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Santa Fé - Argentina - MSSQL                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGetFile()

	Local cRet := Space(50)
	
	oDlg01 := MSDialog():New(000,000,100,500,STR0020,,,,,,,,,.T.)//"Selecionar arquivo"
	
		oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,,,,,,,.T.,,,,,,,,,,"cRet")
		oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0020,,.T.)//"Selecionar arquivo"
		
		oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
		oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)
	
	oDlg01:Activate(,,,.T.,,,)

Return cRet

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGetDir  ³ Autor ³ TOTVS               ³ Data ³ 19.10.2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para procurar e selecionar o arquivo nos diretorios   ³±±
±±³          ³ locais/servidor/unidades mapeadas.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oPar1 - Objeto TGet que ira receber o local e o arquivo    ³±±
±±³          ³         selecionado.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Santa Fé - Argentina - MSSQL                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGetDir(oTGet)

	Local cDir := ""
	
	cDir := cGetFile(,STR0020,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³GeraTemp     ³ Autor ³ TOTVS                 ³ Data ³20/10/2020  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Gera arquivo temporario a partir do CSV importado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GeraTemp(ExpC1)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico FISA835                                               ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function GeraTemp(oTmpTable)
Local aInforma   := {} 									// Array auxiliar com as informacoes da linha lida no arquivo XLS
Local aCampos    := {}         							// Array auxiliar para criacao do arquivo temporario
Local aIteAge    := {}         							// Array de itens selecionaveis na tela de Wizard
Local cArqProc   := cFile									// Arquivo a ser importado selecionado na tela de Wizard
Local cTitulo    := STR0008								// "Problemas na Importação de Arquivo"
Local cErro	     := ""   								// Texto de mensagem de erro ocorrido na validacao do arquivo a ser importado
Local cSolucao   := ""           						// Texto de solucao proposta em relacao a algum erro ocorrido na validacao do arquivo a ser importado
Local cLinha     := ""									// Informacao lida para cada linha do arquivo XLS
Local lArqValido := .T.                               	// Determina se o arquivo XLS esta ok para importacao
Local nInd       := 0                   				// Indexadora de laco For/Next
Local nHandle    := 0            						// Numero de referencia atribuido na abertura do arquivo XLS
Local nTam       := 0 									// Tamanho de buffer do arquivo XLS
Local cDelimit := ""  
Local cPeriod := "" 
Local lPrimi := .T.  
Local aOrdem := {"CUIT"}

lRet := .T. // Determina a continuidade do processamento como base nas informacoes da tela de Wizard 						

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o arquivo temporario para a importacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//*************Modelo do arquivo*************
//CUIT|ALICUOTA|

AADD(aCampos,{"CUIT"	,"C",TamSX3("A2_CGC")[1],0}) //CUIT
AADD(aCampos,{"ALIQ"    ,"C",6,0})                   //ALICUOTA

oTmpTable := FWTemporaryTable():New("TMPSF",aCampos )
oTmpTable:AddIndex( "I1", aOrdem )
oTmpTable:Create()
cArqTmp := oTmpTable:GetAlias() 

aArqTmp := {cArqTmp,"TMPSF"}

cPeriod := cMes + cAno

If File(cArqProc) .And. lRet

	nHandle	:= FOpen(cArqProc)
   
	If nHandle > 0 
		nTam := FSeek(nHandle,0,2)  
	
		FSeek(nHandle,0,0)
		FT_FUse(cArqProc)
		FT_FGotop()
		
	Else
		lArqValido := .F.	
		cErro	   := STR0009 + cArqProc	//"Não foi possível efetuar a abertura do arquivo: "
		cSolucao  := STR0010 			//"Verifique se foi informado o arquivo correto para importação"
	EndIf

	If lArqValido 

		ProcRegua(nTam)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera arquivo temporario a partir do arquivo XLS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While (!FT_FEof()) 
		 			            
			cLinha   := FT_FREADLN()
			IncProc()
			aInforma := {} 
			
   			If !("CUIT" $ cLinha) .And.  !("Cuit" $ cLinha)
   				If "," $ cLinha
					cDelimit := ","
				ElseIf ";" $ cLinha
					cDelimit := ";"
				Endif
					
        		RecLock("TMPSF",.T.)

				For nInd := 1 to 2
					nPos := at(cDelimit,cLinha)
					If nPos > 0
						AADD (aInforma,Alltrim(SubStr(cLinha,1,(nPos-1))))
					Else
						AADD (aInforma,Alltrim(cLinha))
					Endif	
					cLinha := SubStr(cLinha,nPos+1,Len(cLinha))
				Next
				
				cCuit := SM0->M0_CGC
				
  	  			TMPSF->CUIT		:= STRTRAN(aInforma[1],"", "")
  	  			If Alltrim(TMPSF->CUIT) $ SM0->M0_CGC
  	  				lCuitSM0 := .T.
  	  			Endif 
				TMPSF->ALIQ 	 := Alltrim(aInforma[2])

			MsUnLock()	
			Endif
			FT_FSkip()
		Enddo
	Endif	

	FT_FUse()
	FClose(nHandle)

	If Empty(cErro) .and. TMPSF->(LastRec())==0     
		cErro		:= STR0023	//"A importação não foi realizada por não existirem informações no arquivo texto informado."
		cSolucao	:= STR0024	//"Verifique se foi informado o arquivo correto para importação"
	Endif
	
Else

	cErro	 := STR0021+CHR(13)+cArqProc	//"O arquivo informado para importação não foi encontrado: "
	cSolucao := STR0022 		   			//"Informe o diretório e o nome do arquivo corretamente e processe a rotina novamente."

EndIf
	 
If !Empty(cErro)

	xMagHelpFis(cTitulo,cErro,cSolucao)

	lRet := .F.
	
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±/±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PercCliFor³ Autor ³ TOTVS                 ³ Data ³ 20/10/20 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa os arquivos de clientes/fornecedores para          ³±±
±±³          ³aplicacao das regras de validacao para agente retenedor     ³±±
±±³          ³em relacao ao arquivo enviado                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PercCliFor(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Tipo de imposto a ser processado Percepcao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico - FISA835                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PercCliFor(cImptxt,cAlias)
Local aArea     := GetArea()			// Salva area atual para posterior restauracao
Local lExistTXT := .F.					// Determina se o Clinte ou Fornecedor consta no arquivo importado
Local lCli      := (cAlias=="SA1")		// Determina se a rotina foi chamada para processar o arquivo de clientes ou fornecedores
Local cPrefTab  := Substr(cAlias,2,2)	// Prefixo para acesso dos campos

Default cImptxt := ""
Default cAlias := ""

dbSelectArea(cAlias)
(cAlias)->(dbGoTop())
TMPSF->(dbGoTop())
    
ProcRegua(RecCount())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Loop para varrer arquivo de Cliente ou Fornecedor e validar se existe no arquivo XLS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Eof() 

	IncProc(Iif(lCli,STR0015,STR0016))	//##"(15)Processando Clientes/(16)Processando Fornecedores"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Verifica se o cliente/fornecedor consta no arquivo temporario - ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If TMPSF->(MsSeek((cAlias)->&(cPrefTab+"_CGC")))

		While TMPSF->CUIT == (cAlias)->&(cPrefTab+"_CGC")
			If cAlias == 'SA1'		
					PesqSFH(3,(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IBK"+"SF",lCli,.T.,cImptxt)
			Else
					PesqSFH(1,(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IBK"+"SF",lCli,.T.,cImptxt)
			Endif
			TMPSF->(dbSkip())
			
		EndDo	
				
	Else 
		If cAlias == 'SA1'	
			PesqSFH(3,(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IBK"+"SF",lCli,.F.,cImptxt)
		Else		
			PesqSFH(1,(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IBK"+"SF",lCli,.F.,cImptxt)
		Endif
		
	EndIf	
	
	If !lCli
		MsUnLock()
	EndIf

	dbSkip()
	
EndDo

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcRetFor³ Autor ³ TOTVS                 ³ Data ³ 20/10/20 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa os arquivos de fornecedores para retencão          ³±±
±±³          ³aplicacao das regras de validacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ProcCliFor(cImptxt,cAlias)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cImptxt = tipo do imposto a ser processado                 ³±±
               ExpC1 = Alias da tabela a ser processada(SA1/SA2)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico - FISA835                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcRetFor(cImptxt,cAlias)
Local aArea     := GetArea()			// Salva area atual para posterior restauracao
Local lExistTXT := .F.					// Determina se o Cliente ou Fornecedor consta no arquivo importado
Local lCli      := (cAlias=="SA1")		// Determina se a rotina foi chamada para processar o arquivo de clientes ou fornecedores
Local cPrefTab  := Substr(cAlias,2,2)	// Prefixo para acesso dos campos
Default cImptxt := ""
Default cAlias  := ""

dbSelectArea(cAlias)
(cAlias)->(dbGoTop())
TMPSF->(dbGoTop())
    
ProcRegua(RecCount())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Loop para varrer arquivo de Cliente ou Fornecedor e validar se existe no arquivo CSV³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Eof()  

	IncProc(Iif(lCli,STR0025,STR0026))	//##"(25)Processando Clientes/(26)Processando Fornecedores" 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Verifica se o cliente/fornecedor consta no arquivo temporario - ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If TMPSF->(MsSeek((cAlias)->&(cPrefTab+"_CGC")))

		While TMPSF->CUIT == (cAlias)->&(cPrefTab+"_CGC")
			
			PesqSFH(Iif(cAlias=="SA1",3,1),(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IBR"+"SF",lCli,.T.,cImptxt)
			
			TMPSF->(dbSkip())
			
		EndDo	
				
	Else 
		
		PesqSFH(1,(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IBR"+"SF",lCli,.F.,cImptxt)	
		
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
±±³Uso       ³Especifico - FISA200                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function PesqSFH(nOrd,cKeySFH,lCli,lExistTXT,cImptxt)
Local aArea    := GetArea()		// Salva area atual para posterior restauracao
Local lRet     := .T.			// Conteudo e retorno
Local lIncSFH  := lExistTXT		// Determina se deve ser incluido um novo registro na tabela SFH
Local lAtuSFH  := .F.			// Determina se deve atualizar a tabela SFH
Local nRegSFH  := 0				// Numero do registros correspondente ao ultimo periodo de vigencia na SFH
Local lFinPer  := .F.
Local cSitSFH  := ""
Local cFilSFH  := ""
Local cCliente := ""
Local cFornece := ""
Local cLoja    := ""
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
Local lEncontra := .F.
Local dDatAux  := CTOD("  /  /  ")
Default cImptxt := ""
Private nUltimoReg := 0
dbSelectArea("SFH")
DbSetOrder(nOrd) 
SFH->(DbGoTo(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro do Cliente ou Fornecedor na tabela SFH ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
If 	SFH->(MsSeek(xFilial("SFH")+cKeySFH)) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Loop para pegar o registro referente ao periodo vigente do cliente ou fornecedor na tabela SFH ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lExistTXT
		
		While xFilial("SFH")+cKeySFH==SFH->FH_FILIAL+Iif(lCli,SFH->FH_CLIENTE,SFH->FH_FORNECE)+SFH->FH_LOJA +SFH->FH_IMPOSTO+SFH->FH_ZONFIS
			lEncontra := .T.
			If (!Empty(SFH->FH_FIMVIGE) .And. dDatIni <=SFH->FH_FIMVIGE) //Situação 1
				lIncSFH:= .F.
				lAtuSFH := .F.
				cSitSFH := "0"            
				nRegSFH := SFH->(Recno())	
			ElseIf !Empty (SFH->FH_FIMVIGE) .And. dDatIni == (SFH->FH_FIMVIGE + 1) .And. SFH->FH_ALIQ == Val(TMPSF->ALIQ) .And. SFH->FH_PERCENT== IIf(Val(TMPSF->ALIQ) == 0 ,100,0 ) //Situação 2
				dDatAux := SFH->FH_FIMVIGE
				lIncSFH := .F. 
				lAtuSFH := .F.
				Reclock("SFH",.F.) 
					SFH->FH_FIMVIGE := dDatFim
					cSitSFH := "0" 
					nRegSFH := SFH->(Recno())
				MsUnLock()							
			Else //Situação 3
				lIncSFH:= .F.
				lAtuSFH := .F.
				cSitSFH := "3"            
				nRegSFH := SFH->(Recno())
				nUltimoReg=regMayorFe(Iif(lCli,SFH->FH_CLIENTE,SFH->FH_FORNECE),SFH->FH_LOJA,SFH->FH_IMPOSTO,lCli)
				If nRegSFH == nUltimoReg
					lIncSFH:= .F.
					lAtuSFH := .F.
					cSitSFH := "3"
				EndIf		
			EndIf
			
			SFH->(DbSkip())
				
		EndDo
		
	Else

		While xFilial("SFH")+cKeySFH==SFH->FH_FILIAL+Iif(lCli,SFH->FH_CLIENTE,SFH->FH_FORNECE)+SFH->FH_LOJA +SFH->FH_IMPOSTO+SFH->FH_ZONFIS
			If !Empty(SFH->FH_FIMVIGE) .And. dDatIni <= SFH->FH_FIMVIGE
				lFinPer := .F.
				lAtuSFH := .F.
				lIncSFH := .F.
				cSitSFH := ""  
				nRegSFH := SFH->(Recno())		
			ElseIf !lCuitSM0 .And. !Empty (SFH->FH_FIMVIGE) .And. dDatIni > SFH->FH_FIMVIGE //Situação 4
				lFinPer := .F.
				lAtuSFH := .F.
				lIncSFH := .F.
				
				nRegSFH := SFH->(Recno())
				nUltimoReg=regMayorFe(Iif(lCli,SFH->FH_CLIENTE,SFH->FH_FORNECE),SFH->FH_LOJA,SFH->FH_IMPOSTO,lCli)
				If nRegSFH == nUltimoReg
					lIncSFH:= .F.
					lAtuSFH := .F.
					cSitSFH := "4"
				EndIf 
			ElseIf lCuitSM0 .And. cImptxt == "P" .And. !Empty (SFH->FH_FIMVIGE) .And. dDatIni > SFH->FH_FIMVIGE .And. SFH->FH_FIMVIGE <>  dDatIni //Situação 5
				lFinPer := .F.
				lAtuSFH := .F.
				lIncSFH := .F.
				nRegSFH := SFH->(Recno())
				nUltimoReg=regMayorFe(Iif(lCli,SFH->FH_CLIENTE,SFH->FH_FORNECE),SFH->FH_LOJA,SFH->FH_IMPOSTO,lCli)
				If nRegSFH == nUltimoReg
					lIncSFH:= .F.
					lAtuSFH := .F.
					cSitSFH :="5"
					Reclock("SFH",.F.)            
						SFH->FH_FIMVIGE := (dDatIni -1)
					MsUnLock()
				EndIf
			ElseIf cImptxt == "R" .And. !Empty (SFH->FH_FIMVIGE) .And. dDatIni > SFH->FH_FIMVIGE //Situação 6           
				nRegSFH := SFH->(Recno())
				nUltimoReg=regMayorFe(Iif(lCli,SFH->FH_CLIENTE,SFH->FH_FORNECE),SFH->FH_LOJA,SFH->FH_IMPOSTO,lCli)
				If nRegSFH == nUltimoReg
					lFinPer := .F.
					lAtuSFH := .F.
					lIncSFH := .F.
					cSitSFH := "6"
				Endif
			EndIf
			
			SFH->(DbSkip())
				
		EndDo
		
	Endif
	
	SFH->(dbGoto(nRegSFH))
	
	If lExistTXT
		cFilSFH := SFH->FH_FILIAL 
		cAgent  := SFH->FH_AGENTE
		cCliente:= SFH->FH_CLIENTE
		cLoja   := SFH->FH_LOJA
		cAperib := SFH->FH_APERIB
		cPerc   := SFH->FH_PERCIBI 
		cTipo   := SFH->FH_TIPO   
		cZonfis := SFH->FH_ZONFIS
		cImp    := SFH->FH_IMPOSTO
		cAliq   := Val(TMPSF->ALIQ)	
		nPercent:= IIf(Val(TMPSF->ALIQ) == 0,100,0)
		cIsent  := "N" 		
	Else
		If !lCuitSM0
			cFilSFH := SFH->FH_FILIAL 
			cAgent  := SFH->FH_AGENTE
			cCliente:= SFH->FH_CLIENTE
			cLoja   := SFH->FH_LOJA
			cAperib := SFH->FH_APERIB
			cPerc   := SFH->FH_PERCIBI 
			cTipo   := SFH->FH_TIPO   
			cZonfis := SFH->FH_ZONFIS
			cImp    := SFH->FH_IMPOSTO
			cAliq   := 0	
			nPercent:= 100
			cIsent  := "N"	
		Else
			cFilSFH := SFH->FH_FILIAL
			cAgent  := SFH->FH_AGENTE
			cFornece:= SFH->FH_FORNECE
			cLoja   := SFH->FH_LOJA
			cTipo   := SFH->FH_TIPO
			cAperib := SFH->FH_APERIB
			cPerc   := SFH->FH_PERCIBI
			cZonfis := SFH->FH_ZONFIS
			cImp    := SFH->FH_IMPOSTO
			cAliq   := 0
			nPercent:= 100
			cIsent  := "N"
		Endif
	Endif	
ElseIf cImptxt == "P" .and. lExistTXT .And. lCli
	lEncontra:= .T.
ElseIf cImptxt == "R" .and. lExistTXT 
	lEncontra:= .F.
EndIf

If lExistTXT	

	If lIncSFH
		If cImptxt == "P" .And. lEncontra
			Reclock("SFH",.T.)
			SFH->FH_FILIAL  := xFilial("SFH")
			SFH->FH_TIPO    := "I"
			SFH->FH_PERCIBI := "S"
			SFH->FH_ISENTO  := "N"
			SFH->FH_APERIB  := "S"
			SFH->FH_IMPOSTO := "IBK"
			If Val(TMPSF->ALIQ) == 0
				SFH->FH_PERCENT := 100
				SFH->FH_ALIQ	  := Val(TMPSF->ALIQ)
			Else
				SFH->FH_PERCENT := 0
				SFH->FH_ALIQ	  := Val(TMPSF->ALIQ)
			Endif
			SFH->FH_INIVIGE := dDatIni
			SFH->FH_FIMVIGE := dDatFim
			SFH->FH_AGENTE  := "N"
			SFH->FH_ZONFIS := "SF"
			If lCli
				SFH->FH_CLIENTE := SA1->A1_COD
				SFH->FH_NOME    := SA1->A1_NOME
				SFH->FH_FORNECE := ""
				SFH->FH_LOJA    := SA1->A1_LOJA
			Else	
				SFH->FH_FORNECE := SA2->A2_COD
				SFH->FH_NOME    := SA2->A2_NOME
				SFH->FH_CLIENTE := ""
				SFH->FH_LOJA    := SA2->A2_LOJA
			EndIf
			MsUnLock()
		ElseIf cImptxt == "R" .and. lEncontra
			Reclock("SFH",.T.)
			SFH->FH_FILIAL  := xFilial("SFH")
			SFH->FH_AGENTE  := "N"
			SFH->FH_TIPO    := "I"
			SFH->FH_PERCIBI := "N"
			SFH->FH_APERIB  := "N"
			SFH->FH_IMPOSTO := "IBR"
			SFH->FH_ISENTO  := "N"
			SFH->FH_ZONFIS := "SF"
			If Val(TMPSF->ALIQ) == 0
				SFH->FH_PERCENT := 100
				SFH->FH_ALIQ	  := Val(TMPSF->ALIQ)
			Else
				SFH->FH_PERCENT := 0
				SFH->FH_ALIQ	  := Val(TMPSF->ALIQ)
			Endif
			SFH->FH_FORNECE := SA2->A2_COD
			SFH->FH_NOME    := SA2->A2_NOME
			SFH->FH_CLIENTE := ""
			SFH->FH_LOJA    := SA2->A2_LOJA

			SFH->FH_INIVIGE := dDatIni
			SFH->FH_FIMVIGE := dDatFim
			MsUnLock()
		Endif
	EndIf
	
	GrvSFH200(lCli,lExistTXT,cSitSFH,cFilSFH,cTipo,cPerc,cIsent,cAperib,cImp,nPercent,cAliq,dDatIni,dDatFim,cAgent,cSituac,cZonfis,dDatAux)
Else

	GrvSFH200(lCli,lExistTXT,cSitSFH,cFilSFH,cTipo,cPerc,cIsent,cAperib,cImp,nPercent,cAliq,dDatIni,dDatFim,cAgent,cSituac,cZonfis,dDatAux,lIncSFH)	

Endif

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³GrvSFH200     ³ Autor ³ Totvs                 ³ Data ³15/05/18  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Função utilizada para gravar os dados da tabela SFH conforme    ³±±
±±³          ³regra informada na especificação                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GrvSFH200(lCli,lExistTXT,cSitSFH,cFil,cTipo,cPerc,cIsent,       ³±±
±±³cAperib,cImp,cPercent,cAliq,dDatIni,dDatFim,cAgent,cSituac,cZonfis)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lCli = Indica se é cliente ou fornecedor                        ³±±
±±³          ³lExistTXT = Indica se o cliente ou fornecedor existe no arquivo ³±±
±±³          ³cSitSFH = Indicia a situação do registro na tabela SFH          ³±±
±±³          ³cFil,cTipo,cPerc,cIsent,cAperib,cImp,cPercent,cAliq,dDatIni,    ³±±    
±±³          ³dDatFim,cAgent,cSituac,cZonfis = informações gravadas na tabela ³±±
±±³          ³SFH para criar um novo registro similar atualizado              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico - FISA200                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Static Function GrvSFH200(lCli,lExistTXT,cSitSFH,cFilSFH,cTipo,cPerc,cIsent,cAperib,cImp,nPercent,cAliq,dDatIni,dDatFim,cAgent,cSituac,cZonfis,dDatAux,lIncSFH)

Default lCli := .T.
Default lExistTXT := .T.
Default cSitSFH := .T.
Default cFilSFH := ""
Default cTipo := ""
Default cPerc := ""
Default cIsent := ""
Default cAperib := "" 
Default cImp := ""
Default nPercent := 0
Default cAliq := ""
Default dDatIni := CTOD("  /  /  ")
Default dDatFim := CTOD("  /  /  ")
Default dDatAux := CTOD("  /  /  ")
Default cAgent:= ""
Default cSituac := ""
Default cZonfis := ""
Default lIncSFH := .T.

If lExistTXT
	If cSitSFH $ "3" 
		Reclock("SFH",.T.)
		
		SFH->FH_FILIAL := cFilSFH 
		SFH->FH_AGENTE := cAgent
		SFH->FH_APERIB := cAperib
		SFH->FH_PERCIBI := cPerc 
		SFH->FH_TIPO := cTipo   
		SFH->FH_ZONFIS := cZonfis
		SFH->FH_IMPOSTO := cImp
		SFH->FH_ALIQ := cAliq
		SFH->FH_PERCENT := nPercent 
		SFH->FH_ISENTO := cIsent
		SFH->FH_INIVIGE := dDatIni
		SFH->FH_FIMVIGE := dDatFim
	
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
	If cSitSFH $ "4|5|6" .and. lIncSFH
		Reclock("SFH",.T.)
		SFH->FH_FILIAL  := cFilSFH
		SFH->FH_TIPO    := cTipo
		SFH->FH_PERCIBI := cPerc
		SFH->FH_ISENTO  := "N"
		SFH->FH_APERIB  := cAperib
		SFH->FH_IMPOSTO := cImp
		SFH->FH_PERCENT := 100
		SFH->FH_ALIQ	:= 0
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
			SFH->FH_FORNECE := SA2->A2_COD	
			SFH->FH_LOJA    := SA2->A2_LOJA
			SFH->FH_NOME    := SA2->A2_NOME
		EndIf
		MsUnLock()
	Endif
Endif
			
Return

Static Function regMayorFe(cCod,cLoja,cImpuesto,lTabla)

	Local dFecAnt := ""
	Local nAux :=0
	Local cCliPro :=""
	Local nAuxIni :=0
	Local cQuery :=""
	Local dUltMes :=""
		
	Iif(lTabla,cCliPro:="FH_CLIENTE",cCliPro:="FH_FORNECE")
	cQuery	:= ""
	cQuery := "SELECT  FH_FIMVIGE AS FIN,R_E_C_N_O_ AS NUM,FH_INIVIGE AS INI"
	cQuery += " FROM " + RetSqlName("SFH") 
	cQuery += " WHERE FH_FILIAL = '" + xFilial("SFH") + "'"
	cQuery += " AND "+cCliPro+" = '"+cCod+"'"
	cQuery += " AND FH_LOJA ='"+cLoja+"'"
	cQuery += " AND FH_IMPOSTO ='"+cImpuesto+"'"
	cQuery += " AND FH_ZONFIS = 'SF' " 
	cQuery += " AND D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cTMayor", .T., .T.)

	cTMayor->(dbGoTop())
	Do While cTMayor->(!EOF()) 
		If !Empty(cTMayor->FIN)
			If cTMayor->FIN > dFecAnt
				nAux := cTMayor->NUM
				dFecAnt := cTMayor->FIN
			EndIf
		Else
			If cTMayor->INI > dFecAnt
				nAux := cTMayor->NUM
				dUltMes := CTOD("01/"+"12"+"/"+cAno) 
				dUltMes := DTOS(LastDay(dUltMes))
				dFecAnt := dUltMes
			EndIf
		EndIF
		
		If(DTOS(dDatIni) == cTMayor->INI)
			nAuxIni :=cTMayor->NUM
		EndIf
		cTMayor->(dbSkip())
	EndDo
	If(nAuxIni<>0)
		nAux :=nAuxIni
	EndIf
	cTMayor->(dbCloseArea())
Return nAux