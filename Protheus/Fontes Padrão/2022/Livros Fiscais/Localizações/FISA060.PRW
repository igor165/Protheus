#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA060.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FISA060  ³ Autor ³ Marcio Nunes          ³ Data ³05/03/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Importacao de arquivo TXT retornado ARBA                   ³±±
±±³          ³Embargo de Derechos de Crédito                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FISA060()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Argentina                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS     ³ Motivo da Alteracao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³26/12/16  ³SERINN001-539³creación de tablas temporales se³±±
±±³            ³          ³          ³asigna FWTemporaryTable y se inicia³±±
±±³            ³          ³          ³variable nStart=1 en func. GRTPARBA³±±
±±³Alf. Medrano³12/01/17  ³SERINN001-539³Merge Main vs 12.1.15           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISA060()

Local aArqTmp	:= {}	// Arquivo temporario para importacao
Local cAliasTMP	:= ""
Local cTitulo	:= ""
Local cErro		:= ""
Local cSolucao	:= ""
Local lCarga 	:= .F.
Local lRet	 	:= .T.
private oTmpTable

If MostraWiz()	            

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega no arquivo temporario com as informacoes do arquivo de retorno³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|| lRet := GRTPARBA(@aArqTmp)})

	cAliasTMP := aArqTmp[02]   
	
	If lRet

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processo de valiadacao para Fornecedor ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({|| ProcFor("SA2")})

	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Excluindo o arquivo temporario criado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If oTmpTable <> Nil  
		oTmpTable:Delete() 	
		oTmpTable := Nil 
	Endif

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MostraWiz ³ Autor ³Marcio Nunes      ³ Data ³    05/03/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Tela Wizard inicial pata selecao do arquivo a ser importado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MostraWiz()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico - FISA060                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MostraWiz()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao das variaveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aTxtPre 	:= {}
Local aPaineis 	:= {}
Local cTitObj1	:= ""                
Local cMask		:= Replicate("X",245)
Local nPos		:= 0
Local lRet		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta wizard com as perguntas necessarias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aTxtPre,STR0002) 			//"Importação do arquivo Padron de Embargo ARPA"
aAdd(aTxtPre,STR0001) 			//"Atenção"
aAdd(aTxtPre,STR0003) 			//"Preencha corretamente as informações solicitadas."
aAdd(aTxtPre,Alltrim(STR0004))	// "Esta rotina irá importar o arquivo padrão de Embargos de ARBA."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Painel 1 - Assistente de parametrização ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aPaineis,{})
nPos :=	Len(aPaineis)
aAdd(aPaineis[nPos],STR0005) //"Assistente de parametrização" 
aAdd(aPaineis[nPos],STR0006) //"Informações sobre o arquivo de retorno: "
aAdd(aPaineis[nPos],{})

cTitObj1 :=	STR0007 //"Arquivo a ser importado: "
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{2,"",cMask,1,,,,245,,.T.})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

lRet :=	xMagWizard(aTxtPre,aPaineis,"MostraWiz")
	
Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³GRTPARBA     ³ Autor ³ Marcio Nunes            ³ Data ³05/03/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Gera arquivo temporarioa a partir do TXT importado               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GRTPARBA(ExpC1)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Nome do arquivo temporario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function GRTPARBA(aArqTmp)
Local aWizard   := {}
Local aArqPro   := {}
Local lRet      := xMagLeWiz("MostraWiz",@aWizard,.T.)
Local cArqProc  := Alltrim(aWizard[01][01])
Local cTitulo   := STR0008		//"Problemas na Importação de Arquivo"
Local cErro	    := ""
Local cSolucao  := ""
Local cLinha    := ""
Local lArqValido:= .T. 
Local nHandle   := 0 
Local nTam      := 0 
Local cSearch 	:= "-"
Local cReplace	:= ""
Local nStart	:= 1
Local nCount	:= 2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o arquivo temporario para a importacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aArqPRO,{"DATAP"	,"D",08,0})
AADD(aArqPRO,{"CGC"		,"C",11,0})
AADD(aArqPRO,{"VALEMB"	,"C",13,0})
AADD(aArqPRO,{"RAZAO"	,"C",120,0})

cArqTmp := CriaTrab(nil,.f.)

aArqTmp := {cArqTmp,"TMP"}
oTmpTable:= FWTemporaryTable():New("TMP") 
oTmpTable:SetFields( aArqPRO ) 
oTmpTable:AddIndex("T1ORD1", {'CGC'})
//Creacion de la tabla
oTmpTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza arquivo temporario com dados do TXT importado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		cSolucao   := STR0010 				//"Verifique se foi informado o arquivo correto para importação"
	EndIf

	If lArqValido 
		ProcRegua(nTam)

		While (!FT_FEof()) 		
			IncProc()
			
   			cLinha   := FT_FREADLN()	

        	RecLock("TMP",.T.)

			// Retira hífem do CUIT caso necessario
			cLinha := StrTran(cLinha, cSearch, cReplace, nStart, nCount)
			
            TMP->DATAP		:= CtoD(SubStr(cLinha,7,2)+"/"+SubStr(cLinha,5,2)+"/"+SubStr(cLinha,1,4))
  	  	   	TMP->CGC		:= SubStr(cLinha,9,11)
		   	TMP->VALEMB  	:= SubStr(cLinha,20,13)
            TMP->RAZAO		:= SubStr(cLinha,33,120)			
			FT_FSkip()  

		Enddo 
	Endif	

	FT_FUse()
	FClose(nHandle)

	If Empty(cErro) .and. TMP->(LastRec())==0     
		cErro		:= STR0011	//"A importação não foi realizada por não existirem informações no arquivo texto informado."
		cSolucao	:= STR0012	//"Verifique se foi informado o arquivo correto para importação"
	Endif
Else
	cErro	 := STR0013+CHR(13)+cArqProc	//"O arquivo informado para importação não foi encontrado: "
	cSolucao := STR0014 		   			//"Informe o diretório e o nome do arquivo corretamente e processe a rotina novamente."
EndIf
	 
If !Empty(cErro)
	xMagHelpFis(cTitulo,cErro,cSolucao)
	lRet := .F.
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcFor   ³ Autor ³Marcio Nunes           ³ Data ³05/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa os arquivos para verificar se o fornecedor         ³±±
±±³          ³consta no arquivo Importado                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ProcFor(ExpC1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Alias da tabela a ser processada(SA2)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico - FISA060                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcFor(cAlias)
Local aArea     := GetArea()	// Salva area atual para posterior restauracao
Local lExistSFH := .F.			// Determina se o Fornecedor ja existem na tabela SFH

DEFAULT cAlias := "SA2"

dbSelectArea(cAlias)
dbGoTop()
  
ProcRegua(RecCount())

While !Eof()

	IncProc(STR0015)	//"Processando Fornecedor"	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Fornecedor consta no arquivo importado da ARPA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TMP->(dbSeek(SA2->A2_CGC))
		lExistSFH := PesqSFH(1,(cAlias)->A2_COD+(cAlias)->A2_LOJA+"IBRBA",cAlias)
	EndIf 

   	dbSkip()
	
EndDo

RestArea(aArea)

Return                                                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³PesqSFH     ³ Autor ³ Marcio Nunes            ³ Data ³05/03/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Pesquisa existencia de registros na tabela SFH referente ao     ³±±
±±³          ³fornecedor cadastrado.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PesqSFH(ExpN1,ExpC1,ExpC3)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Ordem do indice da tabela SFH                           ³±±
±±³          ³ExpC1 = Chave de pesquisa para a tabela SFH                     ³±±
±±³          ³ExpC3 = Alias da tabela a ser processada(SA2)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico - FISA060                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function PesqSFH(nOrd,cKeySFH,cAlias)
Local aArea    	 := GetArea()						// Salva area atual para posterior restauracao
Local IEncontro:=.F.
Local ICria:=.F.

dbSelectArea("SFH")
DbSetOrder(nOrd) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro do Fornecedor na tabela SFH ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      


//1. Acceder a la tabla "SFH" para el proveedor indicado, donde FH_IMPOSTO="IBR", FH_ZONAFIS="BA", FH_SITUACA="4" 
//   a.	Si encuentra registro y FH_INIVIGE=>cib_fecha No actualiza y continúa con la lectura del próximo registro "cib"
//   b.	Si encuentra registro y FH_INIVIGE<cib_fecha o no encuentra registro:-	Si FH_INIVIGE<cib_fecha y FH_FIMVIG=NULL
//      Actualiza: FH_FIMVIGE=cib_fecha - 1 día

If dbSeek(xFilial("SFH")+cKeySFH)
	While !Eof()  .and. SFH->(FH_FORNECE+FH_LOJA+FH_IMPOSTO+FH_ZONFIS) ==cKeySFH   //FH_SITUACA? 
    	If SFH->FH_SITUACA <> "4"       
			If !IEncontro
				ICria:=.T.
			EndIf     	 
		Else
			IEncontro:=.T.
			ICria:=.F.
			If SFH->FH_INIVIGE < TMP->DATAP .And. Empty(SFH->FH_FIMVIGE)
				Reclock("SFH",.F.)
   	 	    	SFH->FH_FIMVIGE := TMP->DATAP-1
   	   	    	MsUnLock()                  
                  
            	Reclock("SFH",.T.)
  				SFH->FH_FILIAL  := xFilial("SFH")
   				SFH->FH_ZONFIS 	:= "BA"
				SFH->FH_AGENTE  := "N"
				SFH->FH_FORNECE := (cAlias)->A2_COD
   				SFH->FH_LOJA    := (cAlias)->A2_LOJA
				SFH->FH_NOME    := (cAlias)->A2_NOME
				SFH->FH_IMPOSTO := "IBR"
   				SFH->FH_APERIB	:= "N"
				SFH->FH_PERCIBI	:= "N"
				SFH->FH_TIPO	:= "I"
				SFH->FH_SITUACA := "4"                                                                   
				SFH->FH_INIVIGE	:= TMP->DATAP
				SFH->FH_ISENTO  := "N"
				SFH->FH_VALEMB 	:= Val(TMP->VALEMB)/100             
				MsUnLock()
           EndIf             
               
        Endif 
        SFH->(dbSkip())
	EndDo
	If ICria
		Reclock("SFH",.T.)
		SFH->FH_FILIAL  := xFilial("SFH")
		SFH->FH_ZONFIS 	:= "BA"
		SFH->FH_AGENTE  := "N"
		SFH->FH_FORNECE := (cAlias)->A2_COD
		SFH->FH_LOJA    := (cAlias)->A2_LOJA
		SFH->FH_NOME    := (cAlias)->A2_NOME
		SFH->FH_IMPOSTO := "IBR"
		SFH->FH_APERIB	:= "N"
		SFH->FH_PERCIBI	:= "N"
		SFH->FH_TIPO	:= "I"
		SFH->FH_SITUACA := "4"                                                                   
		SFH->FH_INIVIGE	:= TMP->DATAP
		SFH->FH_ISENTO  := "N"
		SFH->FH_VALEMB 	:= Val(TMP->VALEMB)/100      
		MsUnLock() 
	EndIf
Else
	Reclock("SFH",.T.)
  	SFH->FH_FILIAL  := xFilial("SFH")
	SFH->FH_ZONFIS 	:= "BA"
	SFH->FH_AGENTE  := "N"
	SFH->FH_FORNECE := (cAlias)->A2_COD
	SFH->FH_LOJA    := (cAlias)->A2_LOJA
	SFH->FH_NOME    := (cAlias)->A2_NOME
	SFH->FH_IMPOSTO := "IBR"
	SFH->FH_APERIB	:= "N"
	SFH->FH_PERCIBI	:= "N"
	SFH->FH_TIPO	:= "I"
	SFH->FH_SITUACA := "4"                                                                   
	SFH->FH_INIVIGE	:= TMP->DATAP 
	SFH->FH_ISENTO  := "N"
	SFH->FH_VALEMB 	:= Val(TMP->VALEMB)/100             
	MsUnLock()
EndIf

RestArea(aArea)

Return(.T.)   
