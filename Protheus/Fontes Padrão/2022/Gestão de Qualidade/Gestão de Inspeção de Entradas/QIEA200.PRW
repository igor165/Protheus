#INCLUDE "QIEA200.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE K_F4 VK_F4

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QIEA200   ³ Autor ³ Quality 				³ data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Entradas a Inspecionar						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³STR 	     ³ Ultimo utilizado -> STR00XX                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³ 										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MenuDef()

Local aRotina := {{OemToAnsi(STR0004),"AxPesqui"    ,0,1  },; //"Pesquisar"
				{OemToAnsi(STR0005),"Q200Atualiza",0,2  },; //"Visualizar"
				{OemToAnsi(STR0006),"Q200Atualiza",0,3  },; //"Incluir"
				{OemToAnsi(STR0007),"Q200Atualiza",0,4  },; //"Alterar"
				{OemToAnsi(STR0008),"Q200Atualiza",0,5  },; //"Excluir"
				{OemToAnsi(STR0009),"Q200TxtPro"  ,0,4  },; //"Texto"
				{OemToAnsi(STR0061),"Q200Legenda" ,0,4,,.F.}}  //"Legenda"
				
Return aRotina

Function QIEA200(xAutoCab,nOpcAuto)

Local aRotAdic   :={}

Private xAutoCab :=  xAutoCab
Private l200Auto := (xAutoCab <> NIL .And. ValType(xAutoCab) == "A")
Private aAutoCab := {}
Private cEspecie := "QIEA200 "  //Para gravacao das Observacoes da Entrada
Private cFatCon  := " "
Private cTipCon  := " " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do Browse  										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0010) //"Entradas"
Private Inclui    := .F.
Private Altera    := .F.  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private a200Cor := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ 1 - Nome a aparecer no cabecalho                             ³
//³ 2 - Nome da Rotina associada                                 ³
//³ 3 - Usado pela rotina                                        ³
//³ 4 - Tipo de Transa‡„o a ser efetuada                         ³
//³    1) Pesquisa e Posiciona em um Banco de Dados              ³
//³    2) Simplesmente Mostra os Campos                          ³
//³    3) Inclui registros no Bancos de Dados                    ³
//³    4) Altera o registro corrente                             ³
//³    5) Remove o registro corrente do Banco de Dados           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina 	:= MenuDef()
Private lUsaNewKey  := GetNewPar( "MV_CHVEDOC" , .F. ) 

Aadd(a200Cor,{"Q200LdoPen()","BR_CINZA"   })//Entrada sem medicoes cadastradas 
Aadd(a200Cor,{"Q200EntSMC()","BR_MARROM"   })//Laudo Geral Pedente
Aadd(a200Cor,{"Q200LdoApr()","BR_VERDE"   })//Laudo Aprovado 
Aadd(a200Cor,{"Q200LdoRep()","BR_VERMELHO"})//Laudo Reprovado	
Aadd(a200Cor,{"Q200LdoUrg()","BR_AMARELO" })//Liberacao Urgente
Aadd(a200Cor,{"Q200LdoCon()","BR_LARANJA" })//Laudo Condicional
Aadd(a200Cor,{"Q200LdoSME()","BR_AZUL"    })//Laudo sem Movimentacao de Estoque
Aadd(a200Cor,{"Q200EntSLL()","BR_BRANCO"  })//Laudo Sem laudo laboratorio 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
If ExistBlock("QE200ROT")   
	aRotAdic := ExecBlock("QE200ROT", .F., .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf	

If (Type("l200Auto") <> "U" .And. l200Auto )
	aAutoCab := xAutoCab
	mBrowseAuto(nOpcAuto,Aclone(aAutoCab),"QEK")
Else
   mBrowse(6,1,22,75,"QEK",,,,,,a200Cor)
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q200Atualiza³Autor³Paulo Emidio de Barros ³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Manutencao de Entrada a Inspecionar						  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q200Atualiza(EXPC1,EXPN1,EXPN2)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias do arquivo									  ³±±
±±³			 ³ EXPN1 = Numero do registro 								  ³±±
±±³			 ³ EXPN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA200													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q200Atualiza(cAlias,nReg,nOpc)
Local oDlg
Local nOpcA     := 0
Local aAreaAnt  := GetArea()
Local lImpFich	:= .F. //Indica se imprime a Ficha do Produto
Local lEtiqRast := .F. //Indica se imprime Etiqueta de Rastreabilidade
Local nMv_par04 := 0
Local nMv_par05 := 0
Local lEsc		:= .F.
Local cPerg     := " "
Local aAreaQEK  := {}
Local oEnchoice
Local l200Perg  :=.F.  
Local aObjects    := {}
Local aSize       := {} 
Local aInfo       := {}
Local aPosObj     := {} 

Private aTela    := {}
Private aGets    := {}                                           
Private aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as variaveis padroes utilizadas na rotina			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
Private aJustif   := {}  //Vetor para a justificativa da Inspecao/Certificacao
Private nVerifica        //Opcao para Inspecionar e/ou Certificar
Private lAltEsp   := .F. //Indica se ‚ a 1a. Entrada ap¢s alteracao especificacao
Private lPrimDoc  := .T. //Indica se   a 1a. ocorrencia Doc. Entrada para o Fornecedor x Grupo
Private aEnsInsp  := {}	 //Vetor que contem os ensaios a inspecionar pelo Skip-Teste
Private cRevi     := " " //Revisao vigente do Produto na data da entrada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a definicao de Laudo com categoria Aprovado Total   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cFatApr := Fator('1',.T.) //Aprovado Total
Private cFatRep := Fator('3',.T.) //Reprovado Total  
Private cCliFor := ""      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta a largura para o tamanho padrao Protheus ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()       
		
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo    := { aSize[1], aSize[2], aSize[3], aSize[4], 2, 2 } 

aPosObj := MsObjSize(aInfo,aObjects,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para inclusão de botões na tela de entrada  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QA200BUT")
   aButtons := ExecBlock("QA200BUT",.f.,.f.,{cAlias,nReg,nOpc})
EndIF   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para execucao funcao INVERTE.               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QIE200IV")
   ExecBlock("QIE200IV",.F.,.F.)
EndIF   

If Empty(cFatApr)
	Help(" ",1,"A200FATAPR") //"Nao foi cadastrado nenhum Fator Aprovado Total"
	Return(NIL)
EndIf         

If (nOpc == 4) .Or. (nOpc == 5) //Alteracao ou Exclusao

	//Verifica se o sistema está integrado com o Compras e nao permite alteracao nos dados da Entrada          			
	If AllTrim(QEK->QEK_ORIGEM) $"MATA100ßMATA103ßMATA260ßMATA261ßMATA101N"
		MessageDlg(OemToAnsi(STR0057),,3)	//"Produto está no C.Q. da Qualidade. A Entrada somente poderá ser alterada pelo Compras."
		Return(NIL)
	EndIf           
	
	//Verifica se a Entrada podera ser excluida					 
	If QEK->QEK_SITENT <> "1" //Entrada Pendente
		HELP(" ",1,"A200EXIRES") //Entrada com Resultados
		Return(NIL)	
	EndIf
	
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F4 para visualizar as ultimas 50 Entradas        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l200Auto
	SetKey(K_F4,{|a,b,c|Q200UltEnt(a,b,c)})
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria as variaveis para edicao na enchoice					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("QEK",If(nOpc==3,.T.,.F.),.T.)            

If !l200Auto
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd Pixel	 

	oEnchoice := Msmget():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,3,,,,,,)

	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||nOpcA :=1,If(Obrigatorio(aGets,aTela) .And. Q200EncOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()},,aButtons)  ,;
									AlignObject(oDlg,{oEnchoice:oBox},1))

Else
    If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela) .And. Q200EncOk()})
		If nopc ==3
			nOpcA := AxIncluiAuto(cAlias,,,nOpc)
		Else
			If l200Auto
			    nOpcA := AxIncluiAuto(cAlias,,,nOpc,QEK->(RECNO()))
			Else
				nOpcA := AxIncluiAuto(cAlias,,,nOpc)
			Endif
		Endif
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza os dados referentes a Entrada					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpcA == 1) .And. (nOpc <> 2)
	Q200Grava(nOpc)

	//Flag para Impressao das Fichas	
	If (nOpc == 3) .Or. (nOpc == 4)	
		lImpFich := If(!lImpFich,.T.,.F.)
	EndIf

EndIf 

If ExistBlock("QE200PERG")
	ExecBlock("QE200PERG",.F.,.F.,)
	l200Perg := .T.
Endif 
                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao da Ficha do Produto - Uso, Etiquetas de Rastreabi- ³
//³ lidade e de Laudo, Independente de Inspecionar ou Certificar ³
//³ a Entrada.                                          		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lImpFich .And. !l200Auto .And. !l200Perg
		
	cPerg := "QIE200"
	If !Pergunte (cPerg,.T.)
		lEsc := .T.
	EndIf
		
	If !lEsc
		lEtiqRast  := If(mv_par02==1,.T.,.F.)
		lEtiqLaudo := If(mv_par03==1,.T.,.F.)
		nMv_par04  := mv_par04 //Assumir Tamanho do lote ? 1 - Sim, 2 - Nao
		nMv_par05  := mv_par05 //Tamanho do lote a ser considerado, caso mv_par04 = 2
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Ficha do Produto - Uso 								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par01 == 1  
			aAreaQEK := QEK->(GetArea())
			If ExistBlock("QIER200R")
				SetaPilha()
				ExecBlock("QIER200R",.F.,.F.,"QIEA200")
				SetaPilha()
			Else
				QIER200("QIEA200")
			EndIf
			RestArea(aAreaQEK)
		EndIf
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Etiqueta de Rastreabilidade 						 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEtiqRast   
			aAreaQEK := QEK->(GetArea())
			If ExistBlock("QIER240R")
				SetaPilha()
				Execblock("QIER240R",.F.,.F.,{"QIEA200",nMv_par04,nMv_par05})
				SetaPilha()
			Else
				QIER240("QIEA200",nMv_par04,nMv_par05)
			EndIf
			RestArea(aAreaQEK)
		EndIf
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Etiqueta de Laudo 									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEtiqLaudo
			aAreaQEK := QEK->(GetArea())
			If ExistBlock("QIER270R")
				SetaPilha()
				ExecBlock("QIER270R",.F.,.F.,{"QIEA200",nMv_par04,nMv_par05})
				SetaPilha()
			Else
				QIER270("QIEA200",nMv_par04,nMv_par05)
			EndIf
			RestArea(aAreaQEK)
		EndIf
			
	EndIf
EndIf

RestArea(aAreaAnt)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desativa tecla F4 para visualizar as ultimas 50 Entradas     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l200Auto
   	SetKey(K_F4,{||NIL})
EndIf	

Return(NIL)                    
             
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200Grava ³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a Atualizacao das Entradas						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200											  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Q200Grava(nOpc)
Local lContinua := .T.             
Local aAreaQEK  := {}          
Local cChave    := " "
Local cGrupo    := " "
Local cCodEnt   := " "
Local lAtuPA    := .T.
Local nIQSRep   := 0
Local nX        := 0
Local bCampo    := {|nCPO|FieldName(nCPO)} 
Local lInspecna := .T.
//Private lInsAmoIni := GetMv("MV_QAMOINI")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclusao da Entrada											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 5 //Exclusao

	If ExistBlock("QVAL200D")
		lContinua := ExecBlock("QVAL200D",.F.,.F.)
	EndIf	
			  
	If lContinua			
		Begin Transaction
		RecLock("QEK",.F.,.T.)
		dbDelete()
		MsUnLock()
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui as amarracoes associadas a Entrada					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		A200ExEn()
		End Transaction
		
	EndIf
Else                            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obtem o codigo sequencial do Identificador da Entrada        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpc == 3)
		cCodEnt := QA_SEQU("QIE_IDEN",TamSX3("QEK_IDENTE")[1],"A",OemToAnsi(STR0012))	//"Identificador Entrada"
			                
		//Caso o Codigo Sequencial nao seja gerado a Entrada nao sera gravada.
		If Empty(cCodEnt)	
			Help(" ",1,"Q200NCODSE") //"Nao foi possivel a geracao do Identificador sequencial da Entrada"
		    Return(NIL)
		EndIf
	Else                          
		cCodEnt := QEK->QEK_IDENTE
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera a Chave de Ligacao utilizada na Entrada a Inspecionar   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpc == 3) .Or. (nOpc == 4 .And. Empty(QEK->QEK_CHAVE))
		aAreaQEK := GetArea()   
		cChave   := QA_NewChave("QEK",7)
    	RestArea(aAreaQEK)   
	Else
		cChave := QEK->QEK_CHAVE
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obtem o Grupo de Produtos									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpc == 3) 
		dbSelectArea("QEA")
		dbSetOrder(2)
		dbSeek(xFilial("QEA")+M->QEK_PRODUT)
		cGrupo := QEA->QEA_GRUPO
	Else
		cGrupo := QEK->QEK_GRUPO
	EndIf	
	
	If !l200auto
		RecLock("QEK",If(nOpc==3,.T.,.F.))
		For nX := 1 to fCount()
			FieldPut(nX,M->&(Eval(bCampo,nX)))
		Next nX       
	Else
		RecLock("QEK",.F.) 
	Endif                    
		
		QEK->QEK_FILIAL := xFilial("QEK") 
		QEK->QEK_REVI   := QA_UltRevEsp(QEK->QEK_PRODUT,QEK->QEK_DTENTR,.T.,,"QIE")
		QEK->QEK_IDENTE := cCodEnt
		QEK->QEK_ENTINV := Inverte(QEK->QEK_DTENTR)
		QEK->QEK_LOTINV := Inverte(QEK->QEK_LOTE)
		QEK->QEK_IDEINV := Inverte(QEK->QEK_IDENTE)
		QEK->QEK_SITENT := "1"
		QEK->QEK_ALTESP := lAltEsp //Indica a primeira Entrada apos a alteracao da Especificacao do Produto
		QEK->QEK_SKLDOC := lPrimDoc
		QEK->QEK_DTCAEN := dDataBase
		QEK->QEK_CODENT := If(nOpc==3,'A','E') //Inclusao/Alteracao via cadastro
		QEK->QEK_ORIGEM := FunName()
		QEK->QEK_GRUPO  := cGrupo
		QEK->QEK_CHAVE  := cChave
		QEK->QEK_NTFISC  := M->QEK_NTFISC
		SerieNfId ("QEK",1,"QEK_SERINF",M->QEK_DTNFIS,padr(M->QEK_TIPDOC,TamSX3( alltrim("F1_ESPECIE")) [1]),AllTrim(SubStr(M->QEK_SERINF,1,3)))
		QEK->QEK_ITEMNF  := M->QEK_ITEMNF
		
		MsUnLock()    
	
	
		
	/*If lInsAmoIni
		QE7->(dbSetOrder(4))
		If QE7->(MsSeek(xFilial("QE7")+QEK->QEK_PRODUT+QEK->QEK_REVI))
			While QE7->(!Eof()) .And. (QE7->QE7_FILIAL+QE7->QE7_PRODUT+QE7->QE7_REVI) ==;
				(xFilial("QE7")+QEK->QEK_PRODUT+QEK->QEK_REVI)
				If QE7->QE7_AM_INS == "1" //Amostra Inicial
					lInspecna := QieAmoIni(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QEK->QEK_IDEINV)
				Endif	
				QE7->(dbSkip())
			Enddo	
		Endif	
    Endif	   
    */

	If !lInspecna
		RecLock("QEK",.F.)
		QEK->QEK_VERIFI  := 2	
		MsUnLock()
	Endif	

	If (nOpc == 3) //Inclusao
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava a Certificacao da Entrada, se em Regime de Skip-Lote	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QEK->QEK_VERIFI == 2
        	QieAtuLaudo(1)
		
		EndIf
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o Controle do Skip-Teste							 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QieAtuSkpTst(1,aEnsInsp)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava os Dados referentes ao Plano de Amostragem			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA5")
		dbSetOrder(2)
		If dbSeek(xFilial("SA5")+QEK->QEK_PRODUT+QEK->QEK_FORNEC+QEK->QEK_LOJFOR)
			QAtuPlAmEn(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QEK->QEK_REVI,QEK->QEK_CHAVE,QEK->QEK_TAMAMO,QEK->QEK_TIPONF,1)
			
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o Plano de Amostragem automaticamente				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SuperGetMv("MV_QATUPAM") == "S"	 //Atualizacao Automatica do Plano de Amostragem

			If SuperGetMv("MV_QPAMIQS") == "S"	//Atualizacao do Plano Amostragem vinculado ao IQS
				
				nIQSRep := SuperGetMv("MV_QIQSREP")	//IQS Reprovado
				             
				dbSelectArea("SA2")
				dbSetOrder(1)
				dbSeek(xFilial("SA2")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR)
				If (A2_FATAVA == 0 .And. Empty(A2_DTAVA)) .Or. (A2_FATAVA <= nIQSRep)
					lAtuPA := .F.
				EndIf
				
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizacao automatica do Plano de Amostragem                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lAtuPA 
				A200AtPA()
				
			EndIf

		EndIf
		
	EndIf
	                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compatibiliza a Unidade de Medida no Cadastro de Produtos	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QE6")
	dbSetorder(1)
	If dbSeek(xFilial("QE6")+QEK->QEK_PRODUT+Inverte(QEK->QEK_REVI))
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+QE6->QE6_PRODUT))
			If SB1->B1_UM <> QE6->QE6_UNMED1
				RecLock("SB1",.F.)
				SB1->B1_UM := QE6->QE6_UNMED1
				MsUnLock()
			EndIf
		EndIf
    EndIf
	
EndIf
//Ponto de entrada que passa como parametro o nOpc
If ExistBlock("QIE200EN")
	ExecBlock("QIE200EN",.F., .F., {nOpc})
EndIf
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200EncOk ³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao dos campos editados na Enchoice 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200											  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q200EncOk()
Local lRetorno := .T.
Local aAreaSA5 := SA5->(GetArea())
Local cTitQEK  := FWX3Titulo("QEK_DOCENT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o Produto tiver Integracao com Materiais, verifica os tamanhos do campo NISERI ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+QEK->QEK_PRODUT))
	If RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == "Q"
		If (TamSx3("QEK_NTFISC")[1]+TamSx3("QEK_SERINF")[1]+TamSx3("QEK_ITEMNF")[1] > TamSx3("QEL_NISERI")[1] .OR.;
		    TamSx3("QEK_NTFISC")[1]+TamSx3("QEK_SERINF")[1]+TamSx3("QEK_ITEMNF")[1] > TamSx3("QER_NISERI")[1] .OR.;
			TamSx3("D1_DOC")[1]+TamSx3("D1_SERIE")[1]+ TamSx3("D1_ITEM")[1] > TamSx3("QER_NISERI")[1] .OR.;
		 	TamSx3("D1_DOC")[1]+TamSx3("D1_SERIE")[1]+ TamSx3("D1_ITEM")[1] > TamSx3("QEL_NISERI")[1])
			Help(" ",1,"QIENISERI")
			lRetorno := .F.
		EndIf
    Endif
Endif

If ExistBlock("QVAL200IA")
   lRetorno := ExecBlock("QVAL200IA",.F.,.F.)
EndIF		

If Inclui .And. lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a chave est  duplicada                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRetorno := A200Chav()
EndIf

If lRetorno
	If M->QEK_TIPONF$("DßB") 
		DbselectArea("SA1")
		Dbsetorder(1)
		If !EMPTY(M->QEK_FORNEC) .AND. !EMPTY(M->QEK_LOJFOR) .AND.DBSEEK(XFILIAL("SA2")+M->QEK_FORNEC+M->QEK_LOJFOR)
			If SA1->A1_MSBLQL == "1"
				lRetorno:=.F.          
				MessageDlg(STR0091)//"Cliente selecionado está inativo"
			Endif
		Endif 
	Else
		
		DbselectArea("SA2")
		Dbsetorder(1)
		If !EMPTY(M->QEK_FORNEC) .AND. !EMPTY(M->QEK_LOJFOR) .AND.DBSEEK(XFILIAL("SA2")+M->QEK_FORNEC+M->QEK_LOJFOR)
			If SA2->A2_MSBLQL == "1"
				lRetorno:=.F.
				MessageDlg(STR0092) //"Fornecedor selecionado está inativo" 
			Endif
		Endif
	Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Situacao Prod x For sem Skip-Lote (C)			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA5")
	dbSetOrder(2)
	dbSeek(xFilial("SA5")+M->QEK_PRODUT+M->QEK_FORNEC+M->QEK_LOJFOR)
          
	dbSelectArea("QEG")
	dbSetOrder(1)
	dbSeek(xFilial("QEG")+SA5->A5_SITU)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sem tratamento de Skip-Lote, devera ser informado o solici-  ³
	//³ tante.														 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QEG->QEG_CATEG == "3" .and. Empty(M->QEK_SOLIC) .And. GetMv("MV_QSOLPQU") == "S"
		Help(" ",1,"A200SOLVAZ") //"Informe o Solicitante"
		lRetorno := .F.
	EndIf
	
EndIf

If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Documento de Entradaesta preenchido p/ o Skip- ³
	//³ Lote 1/Documento de Entrada.								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//Verifica se unidade do Skip-Lote ‚ por Lote
	dbSelectArea("QEF") 
	dbSetOrder(1)
	dbSeek(xFilial("QEF")+SA5->A5_SKPLOT)
	If QEF->QEF_UNSKLT == 'L' .And. Empty(M->QEK_DOCENT)
		//#STR0102 - "Atenção"
		//#STR0099 - "Informe o "+"Lote do Fornecedor"
		//#STR0100 - "Como o Skip-Lote definido para o ProdutoX Fornecedor é controlado pelo "+"Lote do Fornecedor" 
		//#STR0101 - ", este campo deve ser informado."
		Help(NIL, NIL, STR0102, NIL, STR0099+cTitQEK, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0100+cTitQEK+STR0101})
		lRetorno := .F.
	EndIf
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a Entrada foi certificada, verifica se o Certificado do   ³
//³ Fornecedor foi Informado.									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .And. M->QEK_VERIFI == 2 .And. Empty(M->QEK_CERFOR)
	HELP(" ",1,"A200CFOVAZ")	//"Especifique o Certificado do Fornecedor"
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o RIAI possui validade vencida                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	If !Empty(SA5->A5_RIAI) .And. M->QEK_DTENTR > SA5->A5_VALRIAI
		Help(" ",1,"A200RIAEXP")	//"Data de Validade do RIAI esta' expirada"
		lRetorno := .F.
	EndIf
EndIf

If lRetorno .And. !Empty(M->QEK_PRODUT) .And. !Empty(M->QEK_FORNEC) .And.;
	!Empty(M->QEK_DTENTR) .And. !Empty(M->QEK_LOTE) .And. !Empty(M->QEK_TAMAMO) .And.;
	!Empty(M->QEK_LOJFOR)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula e exibe o Tamanho da Amostra, Aceite e Rejeite       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A200CAAR(M->QEK_TAMAMO,M->QEK_UNIAMO) 
	
EndIf                  
             
RestArea(aAreaSA5)

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A200Chave ³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao dos campos chaves								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200											  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a200Chav()
Local lRetorno := .T.  
Local cSeriNF       

If !Empty(M->QEK_PRODUT) .And. !Empty(M->QEK_FORNEC) .And. !Empty(M->QEK_DTENTR) .And. !Empty(M->QEK_LOTE) .And. !Empty(M->QEK_LOJFOR)
	
	DbSelectArea("QEK")
	DbSetOrder(14)
	
	cSeriNf := SerieNfId ('QEK',4,'QEK_SERINF',M->QEK_DTNFIS,padr(M->QEK_TIPDOC,TamSX3( alltrim("F1_ESPECIE")) [1]),Alltrim(Substr(M->QEK_SERINF,1,3)))

	If dbSeek(xFilial("QEK")+M->QEK_FORNEC+M->QEK_LOJFOR+M->QEK_PRODUT+M->QEK_NTFISC+cSeriNF+DTOS(M->QEK_DTENTR)+M->QEK_LOTE) //M->QEK_ITEMNF+M->QEK_TIPONF+
		While !QEK->(Eof()) .and. xFilial("QEK")+M->QEK_FORNEC+M->QEK_LOJFOR+M->QEK_PRODUT+M->QEK_NTFISC+cSeriNF+DTOS(M->QEK_DTENTR)+M->QEK_LOTE ==xFilial("QEK")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_NTFISC+QEK->QEK_SERINF+DTOS(QEK->QEK_DTENTR)+QEK->QEK_LOTE
			If Alltrim(M->QEK_ITEMNF+M->QEK_TIPONF) == Alltrim(QEK->QEK_ITEMNF+QEK->QEK_TIPONF)
				Help( " ", 1, "JAGRAVADO" )
				lRetorno := .F.
				Exit
			Endif	                       
			DbSelectArea("QEK")
			DbSetOrder(14)
			DbSkip()         
		Enddo
	EndIf	
EndIf
Return(lRetorno) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200CAAR ³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a Amostra, Aceite e Rejeite e mostra na tela       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200											  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200CAAR(cTamAmo,cUniAmo)
Local oDlg
Local oListBox
Local aAreaAnt := " "
Local cSeq1	   := " "
Local cDescPl  := " "
Local aTabela  := {}
Local aTam1	   := {}
Local aTam2	   := {}
Local aTam3	   := {}
Local aTam4	   := {}
Local aTam5	   := {}             
Local aTam6    := {}
Local nAce11   := 0
Local nRej11   := 0
Local nTamA11  := 0
Local nAce12   := 0
Local nRej12   := 0
Local nTamA12  := 0
Local cTab1    := " "
Local cCam1    := " "
Local cTab2    := " "
Local cCam2    := " "
Local cPCod    := " "               
Local cPLoj    := " "
Local aAmostra := {}     
Local nX       := 0

If QEK->QEK_TIPONF $ 'DB'
	cTab1    := "SA7"
	cCam1    := "SA7->A7_"
	cTab2    := "QF6"
	cCam2    := "QF6->QF6_"
	cPCod    := "QF6->QF6_CLIENT"
	cPLoj    := "QF6->QF6_LOJCLI"
	aAreaAnt := SA7->(GetArea())
	
Else
	cTab1    := "SA5"
	cCam1    := "SA5->A5_"
	cTab2    := "QF4"
	cCam2    := "QF4->QF4_"
	cPCod    := "QF4->QF4_FORNEC"
	cPLoj    := "QF4->QF4_LOJFOR"
	aAreaAnt := SA5->(GetArea())
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na Amarracao Produto x Fornecedor ou Cliente		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cTab1)
dbSetOrder(2)
dbSeek(xFilial(cTab1)+M->QEK_PRODUT+M->QEK_FORNEC+M->QEK_LOJFOR)

dbSelectArea(cTab2)
dbSetOrder(1)    
dbSeek(xFilial(cTab2)+M->QEK_FORNEC+M->QEK_LOJFOR+M->QEK_PRODUT+M->QEK_REVI,.T.)

While &(cTab2+"->(!Eof())") .And. xFilial(cTab2) == &(cCam2+"FILIAL") .And.;
	(&(cPCod)+&(cPLoj)+&(cCam2+"PRODUT")+&(cCam2+"REVI")) == (M->QEK_FORNEC+M->QEK_LOJFOR+M->QEK_PRODUT+M->QEK_REVI)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se definiu o 1o. Plano Amostragem, calcula 1o. Tamanho Amostra³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(&(cCam2+"PLAMO"))

		//Retorna a Amostra, Aceite e Rejeite, basendo-se na codificacao do Plano de Amostragem selecionado
		aAmostra := Qep_RetAmostra(&(cCam2+"TIPAMO"),&(cCam2+"PLAMO"),&(cCam2+"NIVEL") ,&(cCam2+"NQA"),cTamAmo,"QEK_TAMAMO",.F.)
		If &(cCam2+"TIPAMO") == "3" //Plano Interno
	 
			For nX:=1 to Len(aAmostra)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exibe os dados referentes aos Planos de Amostragens			 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aAmostra[nX][7] == '0'
					cDescpl := STR0094
				Elseif aAmostra[nX][7] == '1'  
            		cDescpl := STR0095
            	Elseif aAmostra[nX][7] == '2'	
            		cDescpl := STR0096
            	Elseif aAmostra[nX][7] == '3'
            		cDescpl := STR0097
            	Elseif aAmostra[nX][7] == '4'
            		cDescpl := STR0098
            	Else
            		cDescpl := STR0094
            	Endif
				
		    	//Obtem somente a primeira sequencia do Plano de Amostragem
				nTamA11  := aAmostra[nX,3]
				nAce11   := aAmostra[nX,1]
				nRej11   := aAmostra[nX,2]
				nTamA12  := aAmostra[nX,6]
				nAce12   := aAmostra[nX,4]
		  		nRej12   := aAmostra[nX,5]
				cSeq1    := If(Left(&(cCam2+"PLAMO"),1)=="D","1","0")
		
				//Amostragem Simples e Dupla - Amostra 01
				Aadd(aTabela,{cDescPl,&(cCam2+"ENSAIO"),aAmostra[nX][7],&(cCam2+"NQA"),;
					Str(nTamA11,TamSX3("QF5_TAMA1")[1] ,TamSX3("QF5_TAMA1")[2] )+" "+cUniAmo,;
					Str(nAce11 ,TamSX3("QF5_ACEI1")[1] ,TamSX3("QF5_ACEI1")[2] )+" N/C",;
					Str(nRej11 ,TamSX3("QF5_REJEI1")[1],TamSX3("QF5_REJEI1")[2])+" N/C"})
		
			Next nX

		Else		
			nTamA11  := aAmostra[1]
			nAce11   := aAmostra[2]
			nRej11   := aAmostra[3]
			nTamA12  := aAmostra[4]
			nAce12   := aAmostra[5]
	  		nRej12   := aAmostra[6]
			cSeq1    := If(Left(&(cCam2+"PLAMO"),1)=="D","1","0")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibe os dados referentes aos Planos de Amostragens			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDescPl := QA_Plano(&(cCam2+"TIPAMO"),.T.) 
	
			//Amostragem Simples e Dupla - Amostra 01
			Aadd(aTabela,{cDescPl,&(cCam2+"ENSAIO"),&(cCam2+"NIVEL"),&(cCam2+"NQA"),;
				Str(nTamA11,TamSX3("QF5_TAMA1")[1] ,TamSX3("QF5_TAMA1")[2] )+" "+cUniAmo,;
				Str(nAce11 ,TamSX3("QF5_ACEI1")[1] ,TamSX3("QF5_ACEI1")[2] )+" N/C",;
				Str(nRej11 ,TamSX3("QF5_REJEI1")[1],TamSX3("QF5_REJEI1")[2])+" N/C"})
	
			If cSeq1 == "1" //Dupla Amostragem - Dupla		
		   		aTam1 := TamSX3(cTab2+"_NIVEL")
				aTam2 := TamSX3(cTab2+"_NQA")
				aTam3 := TamSX3(cTab2+"_FORNEC")
				aTam6 := TamSX3(cTab2+"_ENSAIO")

	   			Aadd(aTabela,{Space(aTam3[1]),Space(aTam6[1]),Space(aTam1[1]),Space(aTam2[1]),;
  					  Str(nTamA12,TamSX3("QF5_TAMA1")[1] ,TamSX3("QF5_TAMA1")[2] )+' '+cUniAmo,;
					  Str(nAce12 ,TamSX3("QF5_ACEI1")[1] ,TamSX3("QF5_ACEI1")[2] )+' N/C',;
					  Str(nRej12 ,TamSX3("QF5_REJEI1")[1],TamSX3("QF5_REJEI1")[2])+' N/C'})
			EndIf
		
		EndIf	
		 	
			
	Else
	    cDescPl := "N/A"
	 	aTam1   := TamSX3(cTab2+"_NIVEL") 
	 	aTam2   := TamSX3(cTab2+"_NQA")
	 	aTam3   := TamSX3("QF5_TAMA1")
	 	aTam4   := TamSX3("QF5_ACEI1")
	 	aTam5   := TamSX3("QF5_REJEI1")
	 	aTam6   := TamSX3(cTab2+"_ENSAIO")
		
	   	Aadd(aTabela,{cDescPl,Space(aTam6[1]),Space(aTam1[1]),Space(aTam2[1]),;
	    	Space(aTam3[1]),Space(aTam4[1]),Space(aTam5[1])})
	 	
	EndIf
	dbSelectArea(cTab2) 
	dbSkip()
	
EndDo

If Len(aTabela) > 0 .And. !l200Auto

	DEFINE MSDIALOG oDlg FROM  18,08 TO 150,558 TITLE OemToAnsi(STR0032) PIXEL	// "Amostragem"

	@ 00.3,00.3 LISTBOX oListBox FIELDS HEADER OemToAnsi(STR0033),; //"Plano Amostragem"
											   OemToAnsi(STR0059),; //"Ensaio"
											   OemToAnsi(STR0034),; //"N¡vel"
											   OemToAnsi(STR0035),; //"NQA"
											   OemToAnsi(STR0036),; //"Amostra"
											   OemToAnsi(STR0037),; //"Aceite"
											   OemToAnsi(STR0038) ; //"Rejeite"
		SIZE 240,52 OF oDlg
	oListBox:SetArray( aTabela )
	oListBox:bLine := {||{aTabela[oListBox:nAT,1],aTabela[oListBox:nAT,2],;
		aTabela[oListBox:nAT,3],aTabela[oListBox:nAT,4],;
		aTabela[oListBox:nAT,5],aTabela[oListBox:nAT,6],aTabela[oListBox:nAT,7]}}
                                         
	DEFINE SBUTTON FROM 05, 246 TYPE 1 ENABLE OF oDlg Action (oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTERED                                      
	
EndIf
RestArea(aAreaAnt)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200TxtPro³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Edita o Texto das Observacoes da Entrada					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200											  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q200TxtPro(cAlias,nReg,nOpc)
Local cChave   := QEK->QEK_CHAVE
Local cCabec   := OemtoAnsi(STR0021)    //"Observacoes da Entrada"
Local cTitulo  := OemtoAnsi(STR0020)    //"Entrada"
Local nTamLin  := TamSX3("QA2_TEXTO")[1]
Local aAreaAnt := GetArea()
Local aTextos  := {}                    //Vetor que contem as observacoes das Entradas
Local lRetTex

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Edita as Observacoes da Entrada								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l200Auto
	lRetTex := QA_TEXTO(cChave,cEspecie,nTamLin,cTitulo,AllTrim(QEK_FORNEC)+" - "+QEK_LOJFOR+" - "+QEK_PRODUT+" - "+Dtoc(QEK_DTENTR)+" - "+QEK_LOTE,@aTextos,1,cCabec)
EndIf		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava as Observacoes da Entrada								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l200Auto .and. lRetTex
	QA_GrvTxt(cChave,cEspecie,1,@aTextos)    
EndIf	

RestArea(aAreaAnt)

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200Legenda³Autor ³ Paulo Emidio de Barros³ Data ³01/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o status das Entradas							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q200Legenda()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q200Legenda() 
Local aLegenda := {}

Aadd(aLegenda,{"BR_CINZA",   OemToAnsi(STR0083)}) //"Laudo Pendente"                   
Aadd(aLegenda,{"BR_MARROM",	 OemToAnsi(STR0062)}) //"Entrada c/ Med Laudo Geral Pendente"
Aadd(aLegenda,{"BR_BRANCO",	 OemToAnsi(STR0090)}) //"Entrada c/ Med Laudo Laboratorio Pendente"
Aadd(aLegenda,{"BR_VERDE",   OemToAnsi(STR0063)}) //"Laudo Aprovado"
Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0064)}) //"Laudo Reprovado"
Aadd(aLegenda,{"BR_AMARELO", OemToAnsi(STR0065)}) //"Laudo com Liberacao Urgente"
Aadd(aLegenda,{"BR_LARANJA", OemToAnsi(STR0066)}) //"Laudo Aprovado Condicionalmente"
Aadd(aLegenda,{"BR_AZUL",    OemToAnsi(STR0067)}) //"Laudo s/ Movimentacao de Estoque" 
	
BrwLegenda(cCadastro,STR0068,aLegenda) //"Entradas"

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200LdoPen³ Autor ³ Paulo Emidio de Barros³ Data ³01/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o status dos laudos pendentes					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q200LdoPen()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q200LdoPen()       
Local lRetorno := .F.

If QEK->QEK_SITENT == "1"                
	lRetorno := .T.                    
EndIf

Return(lRetorno)                                     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200LdoApr³ Autor ³ Paulo Emidio de Barros³ Data ³01/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o status dos laudos aprovados					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q200LdoApr()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q200LdoApr()
Local lRetorno := .F.

If QEK->QEK_SITENT == "2"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200Ldorep³ Autor ³ Paulo Emidio de Barros³ Data ³01/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o status dos laudos reprovados					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q200LdoRep()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q200LdoRep()
Local lRetorno := .F.

If QEK->QEK_SITENT == "3"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)        

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200LdoUrg³ Autor ³ Paulo Emidio de Barros³ Data ³01/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o status dos laudos com Liberacao Urgente		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q200LdoUrg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q200LdoUrg()
Local lRetorno := .F.

If QEK->QEK_SITENT == "4"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200LdoCon³ Autor ³ Paulo Emidio de Barros³ Data ³01/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o status dos laudos liberados condicionalmente	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q200LdoCon()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q200LdoCon()
Local lRetorno := .F.

If QEK->QEK_SITENT == "5"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)        

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200LdoSME³ Autor ³ Paulo Emidio de Barros³ Data ³30/01/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o status dos Laudos sem movimentacao de Estoque    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q200LdoSME()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q200LdoSME()
Local lRetorno := .F.

If QEK->QEK_SITENT == "6"
	lRetorno := .T.
EndIf
Return(lRetorno)	    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q200EntSMC³ Autor ³Paulo Emidio de Barros ³ Data ³02/05/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status das Entradas sem Medicoes				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q200EntSMC()								                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q200EntSMC()       
Local lRetorno := .F.

If QEK->QEK_SITENT == "7"                
	lRetorno := .T.                    
EndIf
Return(lRetorno) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q200EntSLL³ Autor ³Cleber Souza           ³ Data ³06/07/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status das Entradas sem Laudo do Laboratorio	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q200EntSLL()								                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q200EntSLL()       
Local lRetorno := .F.

If QEK->QEK_SITENT == "8"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)                                     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200ExEn ³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui as Amarracoes relacionadas a Entrada				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200											  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200ExEn()
Local cChave

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclusao dos Historicos dos Planos de Amostragem			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QF5->(dbSetOrder(1))
QF5->(dbSeek(xFilial("QF5")+QEK->QEK_CHAVE))
If QF5->(!Eof())
	While QF5->(!Eof()) .And. QEK->QEK_CHAVE == QF5->QF5_CHAVE
	 	RecLock("QF5",.F.)
		dbDelete()
		MsUnLock()
		dbSkip()
    EndDo                             
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem a chave de ligacao da Entrada							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave := QEK->QEK_CHAVE

If !Empty(cChave)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui a Mensagem para a proxima Entrada					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QA_DelTxt(cChave,"QIEA210M")	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui as Observacoes das Entradas            	 			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QA_DelTxt(cChave,"QIEA200 ")                                      
	
EndIf

cChave := QEK->QEK_CHAVE1
If !Empty(cChave)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui o Texto da Liberacao Urgente    	 					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QA_DelTxt(cChave,"QIEA210U")
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui as NNCs das Entradas                   	 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QieAtuNNC(2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui os controles do Skip-teste                    	 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QieAtuSkpTst(2,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui o registro da Entrada no QEP							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea('QEP')    
DbSetOrder(2)
If DbSeek(xFilial("QEP")+"1"+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF+QEK->QEK_TIPONF+;
	DTOS(QEK->QEK_DTENTR)+QEK->QEK_LOTE)
	RecLock("QEP",.F.,.t.)
	DbDelete()
	MsUnLock()
EndIf     

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200COIN ³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza consistencias para determinar a Inspecao da entrada³±±
±±³          ³ sendo: 1a. entrada do Produto/Fornecedor         		  ³±±
±±³          ³        Tempo limite sem Entradas est  expirado     		  ³±±
±±³          ³        1a. entrada ap¢s alteracao especificacao  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200COIN(cFornece,cLoja,cProduto,cRevisao,dEntrada,cLote,aJustif,nVerifica,lAltEsp)
Local aAreaSA5       := SA5->(GetArea())
Local aAreaQE6       := QE6->(GetArea())
Local aAreaQEK       := QEK->(GetArea())
Local lContinua      := .T.
Local lJustificativa := .F.      
Local nSklEnt        := 0
Local nEntradas      := 0     
Local dVigencia
Local nQSKLENT := SuperGetMv("MV_QSKLENT")

Default nVerifica := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for a 1a. Entrada do Fornecedor/Produto, verifica o para- ³
//³ metro MV_QSQLENT, para determinar se inspeciona direto ou se ³
//³ verifica o skip-lote (respeitando conceito do no. Entradas   ³
//³ iniciais).      											 ³
//³ Observacoes: Se for 0, aplica o skip-lote direto, desde a    ³
//³       		 primeira Entrada(Alteracao solicitada pela      ³
//³       		 Transbracal - eles usam Free-Pass e nao querem  ³
//³       		 inspecionar nem a 1a. Entrada).                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QEK")
dbSetOrder(2)		
If !dbSeek(xFilial("QEK")+cFornece+cLoja+cProduto)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inspeciona a primeira Entrada de um Produto x Fornecedor	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nQSKLENT > 0 //"Numero de Entradas iniciais p/ aplicacao skip-lote"
		Aadd(aJustif,OemToAnsi(STR0069)) //"Primeira Entrada do Fornecedor/Produto."
		lJustificativa := .T.
		nVerifica      := 1
		lContinua      := .F.
		
	EndIf	
EndIf

If lContinua      

	dbSelectArea("SA5")
	dbSetOrder(2)
	dbSeek(xFilial("SA5")+cProduto+cFornece+cLoja)

	dbSelectArea("QE6")
	dbSetOrder(1)
	dbSeek(xFilial("QE6")+cProduto+Inverte(cRevisao))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a data da ultima Entrada do Fornecedor x Produto    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QEK")
	dbSetOrder(1)    
	If dbSeek(xFilial("QEK")+cFornece+cLoja+cProduto)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Verifica se o Tempo Limite est   expirado               	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SA5->A5_TEMPLIM) .And. (dEntrada-QEK->QEK_DTENTR) > (SA5->A5_TEMPLIM * 30)
			Aadd(aJustif,OemToAnsi(STR0070)) //"Tempo Limite sem Entradas expirado."
			lJustificativa := .T.
			nVerifica      := 1
		Else                                 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define se o numero de Entradas a inspecionar, para uma nova revi- ³
			//³ sao sera igual a quantidade definida no parametro MV_QSKLENT.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If GetMV("MV_QINSRVI",.T.,.F.) 
				nSklEnt   := 0
				nEntradas := 0     
			
				dbSelectArea("QEK")
				dbSetOrder(2)
				If dbSeek(xFilial("QEK")+cFornece+cLoja+cProduto)
					dVigencia := QE6->QE6_DTINI
					While !Eof() .And. QEK->QEK_FILIAL==xFilial("QEK") .And. (QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT==cFornece+cLoja+cProduto)
						
						nSklEnt++		
						
						If DtoS(QEK->QEK_DTENTR) < DtoS(dVigencia)
							nEntradas++         
							Exit
						EndIf	
						
						If nSklEnt >= nQSKLENT  			
							Exit
	                    EndIf
						dbSkip() 
					EndDo	    
				Endif
				If nEntradas > 0
					Aadd(aJustif,OemToAnsi(STR0086)) //"A quantidade de Entradas a Inspecionar, apos "
					Aadd(aJustif,OemToAnsi(STR0087)) //"a definicao de uma nova Revisao, sera igual a"
					Aadd(aJustif,OemToAnsi(STR0088)) //"quantidade definida no parametro MV_QSKLENT. "
					lJust     := .T.
					nVerifica := 1
				EndIf
	
			Else		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se ‚ a 1a. Entrada ap¢s altera‡Æo de especifica‡Æo  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If QEK->QEK_DTENTR < QE6->QE6_DTINI
					Aadd(aJustif,OemToAnsi(STR0071)) //"Primeira Entrada ap¢s altera‡„o Especifica‡„o"
					lJustificativa := .T.
					nVerifica      := 1
					lAltEsp        := .T.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If lJustificativa
	Aadd(aJustif,OemToAnsi(STR0072)) //"Entrada dever  ser inspecionada."
EndIf
RestArea(aAreaSA5)   
RestArea(aAreaQE6)   
RestArea(aAreaQEK)   

Return(nVerifica)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200SkLT ³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o Skip-Lote de uma Entrada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200SkLt(ExpC1,ExpC2,ExpD1,ExpC3,ExpC4,ExpC5,ExpA1,ExpC6)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Fornecedor                               ³±±
±±³          ³ ExpC2 = Loja do Fornecedor                                 ³±±
±±³          ³ ExpC3 = Codigo do Produto                                  ³±±
±±³          ³ ExpD1 = Data da Entrada                                    ³±±
±±³          ³ ExpC4 = Numero do Lote                                     ³±±
±±³          ³ ExpC5 = Documento de Entrada                    			  ³±±
±±³          ³ ExpC6 = Grupo de Produtos                                  ³±±
±±³          ³ ExpA1 = Justificativa para Inspecionar/Certificar          ³±±
±±³          ³ ExpC7 = Fator de Reprovacao do laudo                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200SkLt(cFor,cLojFor,cProd,dDtEntr,cLote,cDocEnt,cGrupo,aJustif,cFatRep)
Return(nVerifica:=QieSkipLote(cFor,cLojFor,cProd,cGrupo,dDtEntr,cLote,cDocEnt,@aJustif))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200SkTe ³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o Skip-Teste de uma Entrada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200SkTe(ExpC1,ExpC2,ExpC3,ExpL1,ExpC5,ExpL2)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Fornecedor                               ³±±
±±³          ³ ExpC2 = Loja do Fornecedor                                 ³±±
±±³          ³ ExpC3 = Codigo do Produto                                  ³±±
±±³          ³ ExpL1 = Ind. se ‚ a 1a. ocorr. Doc. Entr. p/ o Forn/Grupo  ³±±
±±³          ³ ExpC4 = Fator de reprovacao do laudo                       ³±±
±±³          ³ ExpC5 = Revisao do Produto                                 ³±±
±±³          ³ ExpL2 = Ind. se ‚ a 1a. ocorr. apos alteracao Especificacao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se houve Entrada anterior c/ Laudos Reprov., mostra mensagem p/ usuario  	     ³
//³ As consistencias realizadas para verificar se aplica o skip-lote valem   		 ³
//³ tambem para o skip-teste: no. Entradas iniciais, riai vencido, etc..	 		 ³
//³ Forca inspecao de todos os ensaios: 1a. Entrada apos alteracao especifi- 		 ³
//³ cao, Entrada anterior recusada (mesmas regras do skip-lote).			 		 ³
//³ Se o parametro para calcular o skip-teste somente para as Entradas inspecionadas ³
//³ estiver ligado, nao calcula o skip-teste se a Entrada for certificada pelo		 ³
//³ skip-lote. Neste caso, na impressao da ficha de uso, os ensaios aparecerao 		 ³
//³ como certificados tambem.														 ³
//³ Se o calculo para skip-teste for para todas as Entradas, verifica o				 ³
//³ skip-teste mesmo que a Entrada seja certificada pelo skip-lote,				     ³
//³ porque pode ter ensaio a inspecionar, e se o parametro MV_QCERENT = "N"			 ³
//³ (nao certifica a Entrada se tiver ensaio a insp. pelo skip-teste),				 ³
//³ forca a inspecao da Entrada.													 ³
//³ Para gravar os controles de skip-teste (atualizar os contadores),				 ³
//³ verifica o parametro MV_QSKPTES, para atualizar todas as Entradas ou			 ³
//³ somente as inspecionadas (verificacao na gravacao da Entrada).					 ³
//³ Skip-Teste Individual: controla pelo contador de cada ensaio.					 ³
//³ Skip-Teste por Grupo: somente verifica o skip-teste se for a 1a. ocorrencia		 ³
//³ do Documento de Entrada para o Fornecedor/Loja/Grupo. Para as demais repeticoes, ³
//³ os ensaios serao certificados.													 ³
//³ Na 1a. Entrada apos alteracao de especificacao de um produto, verifica se		 ³
//³ j  inspecionou o ensaio, depois do inicio vigencia da alteracao. Pode ter		 ³
//³ inspecionado para outro Produto do grupo, porque tambem teve alter. e j 		 ³
//³ teve Entrada, ou por ter estourado o contador. Neste caso, como j  inspe-		 ³
//³ cionou o ensaio do grupo, apos a alteracao, pode certifica-lo.					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function A200SkTe(cFornece,cLoja,cProduto,lPDoc,cFatRep,cRevi,lAltEsp)
Local aEnsPro  := {}
Local nI	   := 0
Local cGrupo   := Space(TamSX3("QEA_GRUPO")[1])
Local aEns	   := {}
Local nCt	   := 0
Local nCtRecu  := 0
Local nEntInsp := 0 
Local aAreaAnt := GetArea()
Local aAreaQEK := QEK->(GetArea())
Local cSeek    := ""
Local cNiseri  := ""
//Identifica no. Entradas a Inspecionar referente ao fator de Reprovacao
nEntInsp := Fator("3",.F.) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os Ensaio para aplicar o Skip-Teste Individual e por ³
//³ Grupo.														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QE7")
dbSetOrder(1)
dbSeek(xFilial("QE7")+cProduto+cRevi)
While QE7_FILIAL+QE7_PRODUT+QE7_REVI == xFilial("QE7")+cProduto+cRevi .And. !Eof()
	Aadd(aEnsPro,QE7_ENSAIO)
	dbSkip()
EndDo           

dbSelectArea("QE8")
dbSetOrder(1)
dbSeek(xFilial("QE8")+cProduto+cRevi)
While QE8_FILIAL+QE8_PRODUT+QE8_REVI == xFilial("QE8")+cProduto+cRevi .And. !Eof()
	Aadd(aEnsPro,QE8_ENSAIO)
	dbSkip()
EndDo

//Identifica o Grupo do Produto
dbSelectArea("QEA")
dbSetOrder(2)
If dbSeek(xFilial("QEA")+cProduto)
	cGrupo := QEA_GRUPO
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencia de Entradas recusadas					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nCt     := 0
nCtRecu := 1

dbSelectArea("QEK")
dbSetOrder(2)  
dbSeek(xFilial("QEK")+cFornece+cLoja+cProduto)	//ultima entrada do Fornecedor/Produto
While QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT == xFilial("QEK")+cFornece+cLoja+cProduto .And. !Eof()

	dbSelectArea("QEL")

	
	cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
	dbSetOrder(3)          
	cSeek := QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+cNiseri+QEK->QEK_TIPONF+;
	DTOS(QEK->QEK_DTENTR)+QEK->QEK_LOTE

	If dbSeek(xFilial("QEL")+cSeek+Space(TamSX3("QEL_LABOR")[1]))
	
		// Verifica se o Fator do Laudo tem no. Entradas a inspecionar
		dbSelectArea("QED")
		dbSetOrder(1)
		dbSeek(xFilial("QED")+QEL->QEL_LAUDO)
		If QED->QED_ENTINS <> 0 .And. nCt <= QED->QED_ENTINS-1
			nCtRecu := 2
			Exit
		EndIf   
		
	EndIf

	nCt++
	If nCt > nEntInsp
		Exit
	EndIf
	
	dbSelectArea("QEK")
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza o Calculo do Skip-Teste								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aEnsPro)

	//Verifica se h  skip-teste individual definido
	dbSelectArea("QEH")
	dbSetOrder(1)
	If dbSeek(xFilial("QEH")+cFornece+cLoja+cProduto+aEnsPro[nI])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se houve alteracao de especificacao ou Entrada anterior com  ³
		//³ laudo reprovado, inspeciona o ensaio.						 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAltEsp .Or. nCtRecu <> 1
			Aadd(aEns,{aEnsPro[nI],1})
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o ensaio dever  ser inspecionado				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QEN")
			dbSetOrder(1)
			If !dbSeek(xFilial("QEN")+cFornece+cLoja+cProduto+aEnsPro[nI])
				Aadd(aEns,{aEnsPro[nI],1})
			Else
				If QEN_CONTAD+1 > QEH->QEH_SKPTES
					Aadd(aEns,{aEnsPro[nI],1})
				Else
					Aadd(aEns,{aEnsPro[nI],QEN_CONTAD+1})
				EndIf
			EndIf
		EndIf

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o Skip_teste por Grupo somente na primeira ocorren- ³
		//³ cia por Documento de Entrada para o Fornecedor x Produto	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPDoc  
		
			//Verifica se h  skip-teste por Grupo definido
			dbSelectArea("QEI")
			dbSetOrder(1)
			If dbSeek(xFilial("QEI")+cFornece+cLoja+cGrupo+aEnsPro[nI])

				//Verifica se j  inspecionou o ensaio
				dbSelectArea("QEO")
				dbSetOrder(1)
				If !dbSeek(xFilial("QEO")+cFornece+cLoja+cGrupo+aEnsPro[nI])
					Aadd(aEns,{aEnsPro[nI],1})
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se houve alteracao de especificacao, inspeciona o ensaio, se ³
					//³ ainda nao foi inspecionado p/ o grupo, ou se Entradas anterio³
					//³ res tiveram laudo reprovado.								 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nCtRecu <> 1
						Aadd(aEns,{aEnsPro[nI],1})
					Else
						If lAltEsp

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica se j  inspecionou apos a alteracao especificacao,   ³
							//³ algum produto do grupo.										 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If QEO_DTENTR < QE6->QE6_DTINI
								Aadd(aEns,{aEnsPro[nI],1})
								
							Else
								//Verifica se precisa inspecionar o ensaio pelo contador
								If QEO_CONTAD+1 > QEI->QEI_SKPTES
									Aadd(aEns,{aEnsPro[nI],1})
								Else
									Aadd(aEns,{aEnsPro[nI],QEO_CONTAD+1})
								EndIf
							EndIf
						Else
							// Verifica se precisa inspecionar o ensaio pelo contador
							If QEO_CONTAD+1 > QEI->QEI_SKPTES
								Aadd(aEns,{aEnsPro[nI],1})
							Else
								Aadd(aEns,{aEnsPro[nI],QEO_CONTAD+1})
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Next nI

RestArea(aAreaQEK)
RestArea(aAreaAnt)

Return(aEns)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QE200SkTe³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca para inspecao os ensaios com skip-teste definido.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Grupo a que o Produto pertence                     ³±±
±±³          ³ EXPL1 = Indica se eh a 1a. ocorrencia do Documento Entrada ³±±
±±³          ³ EXPC2 = Fornecedor                                         ³±±
±±³          ³ EXPC3 = Loja do Fornecedor                                 ³±±
±±³          ³ EXPC4 = Produto                                            ³±±
±±³          ³ EXPC5 = Revisao do Produto								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPA1 = Vetor com os ensaios marcados para inspecao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QE200SkTe(cGrupo,lPDoc,cFornece,cLoja,cProduto,cRevi)
Local aEnsPro := {}   
Local aEns	  := {}
Local nI      := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os Ensaios conforme a Revisao do Produto			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QE7")
dbSetOrder(1)
dbSeek(xFilial("QE7")+cProduto+cRevi)
While QE7_FILIAL+QE7_PRODUT+QE7_REVI == xFilial("QE7")+cProduto+cRevi .And. !Eof()
	Aadd(aEnsPro,QE7_ENSAIO)
	dbSkip()
EndDo

dbSelectArea("QE8")
dbSetOrder(1)
dbSeek(xFilial("QE8")+cProduto+cRevi)
While QE8_FILIAL+QE8_PRODUT+QE8_REVI == xFilial("QE8")+cProduto+cRevi .And. !Eof()
	Aadd(aEnsPro,QE8_ENSAIO)	
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena os ensaios para Inspecao							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aEnsPro)

	//Verifica se existe Skip-Teste Individual definido
	dbSelectArea("QEH")
	dbSetOrder(1)
	If dbSeek(xFilial("QEH")+cFornece+cLoja+cProduto+aEnsPro[nI])

		dbSelectArea("QEN")
		dbSetOrder(1)
		If !dbSeek(xFilial("QEN")+cFornece+cLoja+cProduto+aEnsPro[nI])
			Aadd(aEns,{aEnsPro[nI],1})
		Else
			If QEN_CONTAD > QEH->QEH_SKPTES
				Aadd(aEns,{aEnsPro[nI],1}) 
			Else
				Aadd(aEns,{aEnsPro[nI],QEN_CONTAD+1})
			EndIf
		EndIf

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³	Verifica o Skip_Teste por Grupo, se for a primeira ocorrencia³
		//³ por Documento de Entrada do Produto x Fornecedor.			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPDoc
			dbSelectArea("QEI")
			dbSetOrder(1)
			If dbSeek(xFilial("QEI")+cFornece+cLoja+cGrupo+aEnsPro[nI])
				Aadd(aEns,{aEnsPro[nI],1})
			EndIf	
		EndIf
	EndIf	
Next nI             
Return(aEns)	    
        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Q200F3Pr ³ Autor ³ Cleber Souza          ³ Data ³ 26/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da pesquisa de Produto na Entrada.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1: Indicador logico que identifica registro analisado. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q200F3Pr()
Local aArea    := GetArea()
Local lRetorno := .T.
Local cRev     :=  " " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica de o fornecedor possui amarracao Produto x Fornecedor³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  SA5->A5_FORNECE == M->QEK_FORNEC .AND. ;
	SA5->A5_LOJA == M->QEK_LOJFOR
    
	cRev := QA_UltRevEsp(SA5->A5_PRODUTO,dDatabase,.F.,,"QIE")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se o produto possui revisao vigente					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QE6")
	dbSetOrder(3)
	If !dbSeek(xFilial("QE6")+SA5->A5_PRODUTO+cRev)
		lRetorno := .F.
    EndIF
Else
	lRetorno := .F.
EndIf

RestArea(aArea)

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200GaVe ³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para o campo Verifica: Inspeciona/Certifica         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200GaVe()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200GaVe()
Local aOpc     := {}
Local nSklEnt  := SuperGetMv("MV_QSKLENT")	 //"No. Entradas iniciais p/ aplicacao skip-lote"
Local nCntEnt  := 0	// Contador Entradas
Local nCntAte  := 0	// Contador Entradas com Plano Atenuado
Local cGrupo   := ""
Local nI	   := 0           
Local aAreaAnt := GetArea()
Local aAreaSA5 := SA5->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaQEA := QEA->(GetArea())
Local aAreaQEK := QEK->(GetArea())
Local lInspecna:= .T. 
Private lInsAmoIni := GetMV("MV_QAMOINI")

If ReadVar() == "M->QEK_VERIFI" .Or. (l200Auto .And. ReadVar() == "M->QEK_OPCION")
	
	If !Inclui
		Return(.F.)
	EndIf
	
	If M->QEK_TIPONF $ 'DßB'             
		nVerifica     := 1
		M->QEK_VERIFI := nVerifica 
		M->QEK_INSCER := A200DICL(nVerifica,.T.)
		Return(.T.)
	EndIf
	
	//Limpa vetor Justificativas
	aJustif := {}
	
    //Posiciona a Amarracao Produto x Fornecedor
	dbSelectArea("SA5")
	dbSetOrder(2)
	dbSeek(xFilial("SA5")+M->QEK_PRODUT+M->QEK_FORNEC+M->QEK_LOJFOR,.F.)
	
	//Verifica a categotria da Situacao Produto x Fornecedor
	dbSelectArea("QEG")
	dbSetOrder(1)
	dbSeek(xFilial("QEG")+SA5->A5_SITU)
	
	//Identifica o Grupo a que o Produto pertence
	dbSelectArea("QEA") 
	dbSetOrder(2)
	dbSeek(xFilial("QEA")+M->QEK_PRODUT)
	cGrupo := QEA->QEA_GRUPO
	                          
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as opcoes para Inspecionar/Certificar 				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVerifica := 1	//Inspecionar
	
	//Verifica se a situacao do Skip-Lote controla todas as Entradas
	dbSelectArea("QEF")
	dbSetOrder(1)
	dbSeek(xFilial("QEF")+SA5->A5_SKPLOT)
	
	Aadd(aOpc,{OemToAnsi(STR0014),1 })	//"Inspecionar"
	
	//Skip-Lote por Entrega e Controla todas
	If !(QEF_UNSKLT == 'E' .And. QEF_QTDE == 1)
		Aadd(aOpc,{OemToAnsi(STR0015),2 })	//"Certificar"
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ‚ a primeira ocorrencia do Documento de Entrada  ³
	//³ para o Fornecedor x Grupo.									 ³
	//³ Se for, a Entrada sera gravada com a devida identificacao.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(M->QEK_DOCENT)
	
		//Verifica se ha' skip-teste definido por grupo
		dbSelectArea("QEI")
		dbSetOrder(1)
		If dbSeek(xFilial("QEI")+M->QEK_FORNEC+M->QEK_LOJFOR+cGrupo)
		
			dbSelectArea("QEK")
			dbSetOrder(4)
			dbSeek(xFilial("QEK")+M->QEK_DOCENT+M->QEK_FORNEC+M->QEK_LOJFOR)
			While (QEK_FILIAL+QEK_DOCENT+QEK_FORNEC+QEK_LOJFOR) == xFilial("QEK")+M->QEK_DOCENT+M->QEK_FORNEC+M->QEK_LOJFOR .And. !Eof()
				If QEK_GRUPO == cGrupo
					lPrimDoc := .F.
					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza consistencias iniciais que indicam insp. Entrada 	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A200CoIn(M->QEK_FORNEC,M->QEK_LOJFOR,M->QEK_PRODUT,cRevi,M->QEK_DTENTR,M->QEK_LOTE,aJustif,@nVerifica,@lAltEsp)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a categoria da Situacao for A (Skip-Lote Total) ou        ³
	//³ B (Skip_Lote 25%), verifica o Skip-Lote.					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QEG->QEG_CATEG $ "1.2"
		If Len(aJustif) == 0	// Se houver Justif. p/ inspecao, nem verif. skip-lote
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplicacao da NBR-5426 no Skip-Lote                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
			dbSelectArea("QEK")
			dbSetOrder(2)
			dbSeek(xFilial("QEK")+M->QEK_FORNEC+M->QEK_LOJFOR+M->QEK_PRODUT)
			
			If SuperGetMv("MV_QNBR542") == "S"
			
				//Verifica se as 5 ultimas entradas possuem Plano de Amostragem Atenuado
				While QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT == xFilial("QEK")+M->QEK_FORNEC+M->QEK_LOJFOR+M->QEK_PRODUT .And. !Eof()
				
					nCntEnt++
					
					//Verifica o Historico do Plano de Amostragem
					QF5->(dbSetOrder(1))
					If QF5->(dbSeek(xFilial("QF5")+QEK->QEK_CHAVE))
					    If QEK_TIPONF $ "DßB" //Devolucao ou Beneficiamento
							QF6->(dbSetOrder(1))
							If QF6->(dbSeek(xFilial("QF6")+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_REVI)) 
								While QF6->(!Eof()) .And. QF6->QF6_FILIAL == xFilial("QF6") .And.;        		
									QF6->(QF6_CLIENT+QF6_LOJCLI+QF6_PRODUT+QF6_REVI)==(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_REVI)
									If Right(QF6->QF6_PLAMO,1) == "A"
										nCntAte++
										Exit
									EndIf
									QF6->(dbSkip())
								EndDo	
							EndIf
						Else
							QF4->(dbSetOrder(1))
							If QF4->(dbSeek(xFilial("QF4")+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_REVI)) 
								While QF4->(!Eof()) .And. QF4->QF4_FILIAL == xFilial("QF4") .And.;        		
									QF4->(QF4_FORNEC+QF4_LOJFOR+QF4_PRODUT+QF4_REVI)==(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_REVI)
									If Right(QF4->QF4_PLAMO,1) == "A"
										nCntAte++
										Exit
									EndIf
									QF4->(dbSkip())
								EndDo	
							EndIf
						EndIF
					EndIf
					
					If nCntEnt >= 5
						Exit
					EndIf   
					dbSelectArea("QEK")
					dbSkip()
					
				EndDo
				If nCntEnt >= 5 .And. nCntAte == 5
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o Skip-Lote na Entrada							     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
					nVerifica := QieSkipLote(M->QEK_FORNEC,M->QEK_LOJFOR,M->QEK_PRODUT,cGrupo,M->QEK_DTENTR,M->QEK_LOTE,M->QEK_DOCENT,@aJustif)						
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se o parametro para considerar o skip-teste somente para as  ³
					//³ entradas inspecionadas estiver ligado, nem calcula o 		 ³
					//³ Skip-Teste.													 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
					If SuperGetMv("MV_QSKPTES") == "1"                          .Or.; // Skip-teste para todas as Entradas
						(SuperGetMv("MV_QSKPTES") == "2" .And. nVerifica == 1) .Or.; // Somente as Entradas Inspecionadas
						(SuperGetMv("MV_QSKPTES") == "2" .And. nVerifica == 2)	      // As Certificadas em Skip-Lote que poderao ser Inspecionadas
				
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calcula o Skip-Teste										 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
						aEnsInsp := A200SkTe(M->QEK_FORNEC,M->QEK_LOJFOR,M->QEK_PRODUT,lPrimDoc,cFatRep,cRevi,lAltEsp)
						
						//Verifica se a Entrada pode ser certificada, se existir ensaio a Inspecionar
						If nVerifica == 2 .And. SuperGetMv("MV_QCERENT") == "N"
							For nI := 1 To Len(aEnsInsp)
								If aEnsInsp[nI,2] == 1
									aJustif   := {}
									nVerifica := 1
									Aadd(aJustif,OemToAnsi(STR0051)) //"Entrada ser  inspecionada por ter ensaio a inspecionar "
									Aadd(aJustif,OemToAnsi(STR0058)) //"(skip-teste)."
									Exit
								EndIf
							Next nI
						EndIf
					EndIf
				Else
					//Justificativa para a Inspecao
					Aadd(aJustif,OemToAnsi(STR0026)) // "N„o h  hist¢rico de 5 Entradas consecutivas"
					Aadd(aJustif,OemToAnsi(STR0027)) // "com Plano Atenuado, para aplica‡„o Skip-Lote."
					Aadd(aJustif,OemToAnsi(STR0028)) // "A Entrada dever  ser inspecionada."
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Marca os ensaios definidos com Skip-Teste, para inspecionar  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
					aEnsInsp := QE200SkTe(cGrupo,lPrimDoc,M->QEK_FORNEC,M->QEK_LOJFOR,M->QEK_PRODUT,cRevi)
					
				EndIf
			Else
				If nSklEnt > 1
					While QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT == xFilial("QEK")+M->QEK_FORNEC+M->QEK_LOJFOR+M->QEK_PRODUT .And. !Eof() .And. nCntEnt<=nSklEnt						
						nCntEnt++
						dbSkip()
					EndDo       
					
					If nCntEnt >= nSklEnt
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Aplica o Skip-Lote na Entrada								 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
						nVerifica := QieSkipLote(M->QEK_FORNEC,M->QEK_LOJFOR,M->QEK_PRODUT,cGrupo,M->QEK_DTENTR,M->QEK_LOTE,M->QEK_DOCENT,@aJustif)													
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se o parametro para considerar o skip-teste somente para as  ³
						//³ entradas inspecionadas estiver ligado, nem calcula o         ³
						//³ Skip-Teste.													 ³ 
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
						If SuperGetMv("MV_QSKPTES") == "1"                          .Or.; // Skip-teste para todas as Entradas
							(SuperGetMv("MV_QSKPTES") == "2" .And. nVerifica == 1) .Or.; // Somente as Entradas Inspecionadas
							(SuperGetMv("MV_QSKPTES") == "2" .And. nVerifica == 2)	      // As Certificadas em Skip-Lote que poderao ser Inspecionadas
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Calcula o Skip-Teste 										 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
							aEnsInsp := A200SkTe(M->QEK_FORNEC,M->QEK_LOJFOR,M->QEK_PRODUT,lPrimDoc,cFatRep,cRevi,lAltEsp)
							
							//Verifica se a Entrada pode ser certificada, se existir ensaio a inspecionar pelo Skip-Teste
							If nVerifica == 2 .And. SuperGetMv("MV_QCERENT") == "N"
								For nI := 1 To Len(aEnsInsp)
									If aEnsInsp[nI,2] == 1
										aJustif   := {}
										nVerifica := 1
										Aadd(aJustif,OemToAnsi(STR0051)) //"Entrada ser  inspecionada por ter ensaio a inspecionar "
										Aadd(aJustif,OemToAnsi(STR0058)) //"(skip-teste)."
										Exit
									EndIf
								Next nI
							EndIf
						EndIf
					Else
						//Justificativa para a Inspecao
						Aadd(aJustif,OemToAnsi(STR0029))	// "N„o h  o n£mero de Entradas iniciais "
						Aadd(aJustif,OemToAnsi(STR0030))	// "necess rio para a aplica‡„o Skip-Lote."
						Aadd(aJustif,OemToAnsi(STR0028))	// "A Entrada dever  ser inspecionada."
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Marca para inspecao os ensaios com skip-teste definido       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
						aEnsInsp := QE200SkTe(cGrupo,lPrimDoc,M->QEK_FORNEC,M->QEK_LOJFOR,M->QEK_PRODUT,cRevi)
					EndIf
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o Skip-Lote na Entrada								 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
					nVerifica := QieSkipLote(M->QEK_FORNEC,M->QEK_LOJFOR,M->QEK_PRODUT,cGrupo,M->QEK_DTENTR,M->QEK_LOTE,M->QEK_DOCENT,@aJustif)							
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se o parametro para considerar o skip-teste somente para as  ³
					//³ entradas inspecionadas estiver ligado, nem calcula o         ³
					//³ Skip-Teste.													 ³ 
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
					If SuperGetMv("MV_QSKPTES") == "1"                          .Or.; // Skip-teste para todas as Entradas
						(SuperGetMv("MV_QSKPTES") == "2" .And. nVerifica == 1) .Or.; // Somente as Entradas Inspecionadas
						(SuperGetMv("MV_QSKPTES") == "2" .And. nVerifica == 2)	      // As Certificadas em Skip-Lote que poderao ser Inspecionadas
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calcula o Skip-Teste 										 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
						aEnsInsp := A200SkTe(M->QEK_FORNEC,M->QEK_LOJFOR,M->QEK_PRODUT,lPrimDoc,cFatRep,cRevi,lAltEsp)
						
						//Verifica se a Entrada pode ser certificada, se existir ensaio a inspecionar pelo Skip-Teste
						If nVerifica == 2 .And. SuperGetMv("MV_QCERENT") == "N"
							For nI := 1 To Len(aEnsInsp)
								If aEnsInsp[nI,2] == 1
									aJustif   := {}
									nVerifica := 1
									Aadd(aJustif,OemToAnsi(STR0051)) //"Entrada ser  inspecionada por ter ensaio a inspecionar "
									Aadd(aJustif,OemToAnsi(STR0058)) //"(skip-teste)."
									Exit
								EndIf
							Next nI
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Marca para inspecao os ensaios com Skip-Teste definido 		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
			aEnsInsp := QE200SkTe(cGrupo,lPrimDoc,M->QEK_FORNEC,M->QEK_LOJFOR,M->QEK_PRODUT,cRevi)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Menu Inspeciona/Certifica									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
		If !l200Auto
			nVerifica := QA_Choice(aOpc, aJustif, nVerifica, OemToAnsi(STR0031)) //"Tipo de Inspe‡„o"
		EndIf			
	Else            
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o Skip-Teste para Fornecedores com Categoria 		 ³
		//³ Pre-Qualificado.				 		 					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
		aEnsInsp := A200SkTe(M->QEK_FORNEC,M->QEK_LOJFOR,M->QEK_PRODUT,lPrimDoc,cFatRep,cRevi,lAltEsp)
	EndIf

	If lInsAmoIni
		QE7->(dbSetOrder(4))
		If QE7->(MsSeek(xFilial("QE7")+M->QEK_PRODUT+M->QEK_REVI))
			While QE7->(!Eof()) .And. (QE7->QE7_FILIAL+QE7->QE7_PRODUT+QE7->QE7_REVI) ==;
				(xFilial("QE7")+M->QEK_PRODUT+M->QEK_REVI)
				If QE7->QE7_AM_INS == "1" //Amostra Inicial
					lInspecna := QieAmoIni(M->QEK_FORNEC,M->QEK_LOJFOR,M->QEK_PRODUT,M->QEK_IDEINV)
					If !lInspecna
						nVerifica := 2
					Endif	
				Endif	
				QE7->(dbSkip())
			Enddo	
		Endif	
    Endif	   

	M->QEK_VERIFI := nVerifica	
	M->QEK_INSCER := A200DICL(nVerifica,.T.)
EndIf

RestArea(aAreaSA5)
RestArea(aAreaSB1)
RestArea(aAreaQEA)
RestArea(aAreaQEK)
RestArea(aAreaAnt)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200AtPA ³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualizacao automatica dos Planos de Amostragem            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200AtPA()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200AtPA(nOpcEnt)
Local aAmostra  := {} 
Local aAreaAnt  := GetArea()
Local aEntAtu   := QEK->(GetArea())
Local cAliasQry := GetNextAlias()
Local cCam1     := ''
Local cCam2     := ''  
Local cEntinv   := QEK->QEK_ENTINV
Local cFor	    := QEK->QEK_FORNEC
Local cLojFor   := QEK->QEK_LOJFOR
Local cNewPla   := ''
Local cNiseri   := ""
Local cOldPla   := ''
Local cPCod     := ''    
Local cPLoj     := ''
Local cProd	    := QEK->QEK_PRODUT
Local cQEKChav  := ""
Local cQEKtam   := ""
Local cQEKtpnf  := ""
Local cRevi     := QEK->QEK_REVI
Local cSeek     := ''
Local cTab1     := ''
Local cTab2     := ''
Local lPlaDif   := .F.
Local nCntApr   := 0
Local nCntEnt   := 0 
Local nCntRep   := 0
Local nSaveSX8  := GetSX8Len()


Default nOpcEnt := 1

If QEK->QEK_TIPONF $ 'DßB'
	cTab1   := "SA7"
	cCam1   := "SA7->A7_"
	cTab2   := "QF6"
	cCam2   := "QF6->QF6_"
	cPCod   := "QF6->QF6_CLIENT"
	cPLoj   := "QF6->QF6_LOJCLI"
Else
	cTab1   := "SA5"
	cCam1   := "SA5->A5_"
	cTab2   := "QF4"
	cCam2   := "QF4->QF4_"
	cPCod   := "QF4->QF4_FORNEC"
	cPLoj   := "QF4->QF4_LOJFOR"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a ocorrencia de entradas com mesmo plano            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
dbSelectArea(cTab2)
dbSetOrder(1)
dbSeek(xFilial(cTab2)+cFor+cLojFor+cProd+cRevi,.T.)
While &(cCam2+"FILIAL")==xFilial(cTab2) .And. &(cPCod)==cFor .And. &(cPLoj)==cLojFor .And. &(cCam2+"PRODUT")==cProd .And.; 
	&(cCam2+"REVI")==cRevi .And. &(cTab2+"->(!Eof())")

	If &(cCam2+"TIPAMO") == "1" .And. Empty(&(cCam2+"NIVEL"))
    	&(cTab2+"->(dbSkip())")
    	Loop
    EndIf                                                          
    
	nCntEnt := 0
	nCntApr := 0
	nCntRep := 0
	lPlaDif := .F.
	cNewPla := &(cCam2+"PLAMO")
	cOldPla := &(cCam2+"PLAMO")

	cQuery := "   SELECT * "
	cQuery += "     FROM "+RetSqlName("QEK")+" QEK "
	cQuery += "    WHERE QEK.QEK_FILIAL = '"+xFilial("QEK")+"' "
	cQuery += "      AND QEK.QEK_FORNEC = '"+cFor+"' "
	cQuery += "      AND QEK.QEK_LOJFOR = '"+cLojFor+"' "
	cQuery += "      AND QEK.QEK_PRODUT = '"+cProd+"' "
	cQuery += "      AND QEK.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY QEK.QEK_LOTE DESC "   
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)	
				
	//Seleciona a tabela 
	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) .And. nCntEnt < 11
    	If (cAliasQry)->QEK_REVI # cRevi
    		(cAliasQry)->(dbSkip())
    		Loop
    	EndIf
		nCntEnt++

		QF5->(dbSetOrder(2))
		If QF5->(dbSeek(xFilial("QF5")+&(cCam2+"ENSAIO")+(cAliasQry)->QEK_CHAVE))
		
			dbSelectArea("QEL")
	
			cNiseri := (cAliasQry)->QEK_NTFISC+(cAliasQry)->QEK_SERINF+(cAliasQry)->QEK_ITEMNF
			dbSetOrder(3)          
			cSeek := (cAliasQry)->QEK_FORNEC+(cAliasQry)->QEK_LOJFOR+(cAliasQry)->QEK_PRODUT+cNiseri+(cAliasQry)->QEK_TIPONF+;
			(cAliasQry)->QEK_DTENTR+(cAliasQry)->QEK_LOTE

			If dbSeek(xFilial("QEL")+cSeek+Space(TamSX3("QEL_LABOR")[1]))
			
				//Verifica a categoria do Laudo
				dbSelectArea("QED")
				dbSetOrder(1)
				dbSeek(xFilial("QED")+QEL->QEL_LAUDO)
				If QED->QED_CATEG == "1"	//Aprovado Total
					nCntApr++
				ElseIf QED->QED_CATEG == "3" //Reprovado Total
					nCntRep++
				EndIf
			Else 
			 	nCntEnt--
			EndIf            

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ 1 lote Reprovado:  Atenuado para Normal                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
			If nCntRep == 1 .And. Right(&(cCam2+"PLAMO"),1) == "A"
				cNewPla := Left(cNewPla,1) + "N"
				lPlaDif := .T.
				Exit
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o Historico das 5 Entradas anteriores				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
			If nCntEnt == 5

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ 5 lotes consecutivos e 2 Reprovados:  Normal para Severo     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
				If nCntRep == 2 .And. Right(&(cCam2+"PLAMO"),1) == "N"
				    cNewPla := Left(cNewPla,1) + "S"
					lPlaDif := .T.
					Exit
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ 5 lotes consecutivos aprovados:  Severo para Normal          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
				If nCntApr == 5 .And. &(cCam2+"PLAMO") $ "SS.DS"
					cNewPla := Left(cNewPla,1) + "N"
					lPlaDif := .T.
					Exit
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ 10 lotes consecutivos aprovados:  Normal para Atenuado       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
			If (nCntEnt == 10) .And. (nCntApr == 10) .And. Right(&(cCam2+"PLAMO"),1) == "N"
				cNewPla := Left(cNewPla,1) + "A"
				lPlaDif := .T.
				Exit
			EndIf

			cQEKChav := (cAliasQry)->QEK_CHAVE
			cQEKtam  := (cAliasQry)->QEK_TAMAMO
			cQEKtpnf := (cAliasQry)->QEK_TIPONF
			
		EndIf
		(cAliasQry)->(dbSkip())
		
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aEntAtu)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se houve alteracao do Plano de Amostragem			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
	If (lPlaDif)
   	
   		QF5->(dbSetOrder(2))
		If QF5->(dbSeek(xFilial("QF5")+&(cCam2+"ENSAIO")+cQEKChav))
		                           
			//Retorna a Amostra, Aceite e Rejeite, basendo-se na codificacao do Plano de Amostragem selecionado
			aAmostra := Qep_RetAmostra(&(cCam2+"TIPAMO"),&(cCam2+"PLAMO"),&(cCam2+"NIVEL") ,&(cCam2+"NQA"),cQEKtam,"QEK_TAMAMO",.F.)
			nTamA11  := aAmostra[1]
			nAce11   := aAmostra[2]
			nRej11   := aAmostra[3]
			nTamA12  := aAmostra[4]
			nAce12   := aAmostra[5]
	  		nRej12   := aAmostra[6]

			RecLock("QF5",.F.)
			QF5->QF5_TAMA1  := nTamA11
			QF5->QF5_ACEI1  := nAce11
			QF5->QF5_REJEI1 := nRej11
			QF5->QF5_TAMA2  := nTamA12
			QF5->QF5_ACEI2  := nAce12
			QF5->QF5_REJEI2 := nRej12
			QF5->QF5_TIPO   := cQEKtpnf
			MsUnLock()
			
			RecLock(cTab2,.F.)
			&(cCam2+"PLAMO") := cNewPla
			MsUnLock()
    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Edita a Justificativa e gera Historico do Plano Amostragem   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
			If Empty(SA5->A5_CHAVE)
				cChvHis := GetSxeNum("SA5","A5_CHAVE",,6)
				While ( GetSX8Len() > nSaveSx8 )
					ConfirmSX8()
				EndDo
				
				RecLock("SA5",.F.)
			    SA5->A5_CHAVE := cChvHis
				MsUnLock()
			Else
				cChvHis := SA5->A5_CHAVE
			EndIf  
			
			If cOldPla <> cNewPla	
				If nOpcEnt == 1	//Cadastro de Entradas
					QA_JUST(OemToAnsi(STR0080)+&(cCam2+"ENSAIO"),"MATA060A",cChvHis,.T.,cOldPla)	//"Justificativa do Plano Amostragem referente ao Ensaio :"	
					
				Else //Entradas Importadas 
				
				    dbSelectArea("QA3")
				    dbSetOrder(1)
				    If !dbSeek(xFilial("QA3")+"MATA060A"+cChvHis+Inverte(dDataBase))
						RecLock("QA3",.T.)
						QA3->QA3_FILIAL	:= xFilial("QA3")
						QA3->QA3_ESPEC 	:= "MATA060A"
						QA3->QA3_CHAVE 	:= cChvHis
						QA3->QA3_DATINV	:= Inverte(dDataBase)
				    Else
						RecLock("QA3",.F.)
				    EndIF
					QA3->QA3_TEXTO 	:= OemToAnsi(STR0081)	//"Atualizado automaticamente pelo sistema."
					QA3->QA3_DATA	:= dDataBase
					QA3->QA3_ANT	:= cOldPla
					MsUnLock()
				EndIf               
			EndIf
	 	EndIf
 	EndIf
	&(cTab2+"->(dbSkip())")
	
EndDo	

RestArea(aEntAtu)
RestArea(aAreaAnt)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200UltEnt³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra as ultimas 50 Entradas do Fornecedor/Produto        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200AtPA()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q200UltEnt()
Local aAreas   := {QEK->(GetArea()), QEL->(GetArea())}
Local cNiseri  := ""
Local cSeek    := ""
Local oDlg     := NIL
Local oLbx     := NIL

Default l200Auto := .F.

Private aTabela := {} //Array das Entradas

If Empty(M->QEK_FORNEC) .Or. Empty(M->QEK_PRODUT) .Or. Empty(M->QEK_LOJFOR)
	HELP(" ",1,"A200PRFVAZ") //Especifique o Produto e o Fornecedor
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena e exibe as 50 ultimas entradas do Fornecedor x Pro- ³
//³ dutos. 														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
dbSelectArea("QEK")
QEK->(dbSetOrder(2))
QEK->(dbSeek(xFilial("QEK")+M->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)))
While !QEK->(Eof()) .and. QEK->(QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT) == xFilial("QEK")+M->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)
	
	//Posiciona no Laudo Geral da Entrada
	cNiseri := QEK->(QEK_NTFISC+QEK_SERINF+QEK_ITEMNF)
	QEL->(dbSetOrder(3))                  
	cSeek := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+cNiseri+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE)
	
	QEL->(dbSeek(xFilial("QEL")+cSeek+Space(TamSx3("QEL_LABOR")[1])))
	
	Aadd(aTabela,{PadR(dToc(QEK->QEK_DTENTR),13),PadR(QEK->QEK_LOTE,Len(QEK->QEK_LOTE)),;
		PadR(If(QEK->QEK_VERIFI<>2,OemToAnsi(STR0022),OemToAnsi(STR0023)),12),;
		PadR(If(QEL->(Eof()),"N/A",QEL->QEL_LAUDO),12),PadR(QEK->QEK_DOCENT,TamSX3('D1_LOTEFOR')[1])}) // "Inspeciona" ### "Certifica"
	
	QEK->(dbSkip())
	
	If Len(aTabela) == 50
		Exit
	EndIf
	
EndDo

If Len(aTabela) > 0 .And. !l200Auto
	
	DEFINE MSDIALOG oDlg FROM  018,016 TO 246,561 TITLE OemToAnsi(STR0050) PIXEL //"Ultimas Entradas"
	
	DEFINE SBUTTON FROM 005,243 TYPE 1 ENABLE OF oDlg Action (oDlg:End())

	@ 0.3,0.3 LISTBOX oLbx FIELDS      ;
		HEADER TitSX3("QEK_DTENTR")[1],;
		TitSX3("QEK_LOTE")[1]         ,;
		TitSX3("QEK_VERIFI")[1]       ,;
		TitSX3("QEL_LAUDO")[1]        ,;
		TitSX3("QEK_DOCENT")[1]	SIZE 240,100 OF oDlg
		
	oLbx:SetArray(aTabela)
	oLbx:bLine := {||{aTabela[oLbx:nAT,1],aTabela[oLbx:nAT,2],aTabela[oLbx:nAT,3],aTabela[oLbx:nAT,4],aTabela[oLbx:nAT,5]}}
	ACTIVATE MSDIALOG oDlg CENTERED
	
EndIf

AEval(aAreas,{|x| RestArea(x)})

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200TxtPrxEnt³Autor³ Quality   		    ³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Edita a Mensagem p/ Proxima Entrada se Laudo	nao for 	  ³±±
±±³			 ³ Aprovado. 										  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q200TxtPrxEnt()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q200TxtPrxEnt(cChaveQEK,lEdita,lGrvTmp,cAliasQA2,cFornece,cLoja,cProduto,dEntrada,cLote,nLi)
Local cTitulo := OemToAnsi(STR0020) //"Entrada"
Local cCabec  := OemToAnsi(STR0055) //"Mensagem Pr¢xima Entrada"
Local nTamLin := TamSX3("QA2_TEXTO")[1]
Local aTexto  := {}       
Local lRetTex

cEspecie := "QIEA210M" //Mensagem para Proxima Entrada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Edita a Mensagem para a proxima Entrada						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
If !l200Auto
	lRetTex := QA_TEXTO(cChaveQEK,cEspecie,nTamLin,cTitulo,cFornece+" - "+cLoja+" - "+cProduto+" - "+;
		dToc(dEntrada)+" - "+cLote,@aTexto,nLi,cCabec,lEdita,cAliasQA2)
		
	If lGrvTmp .and. lRetTex
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava a mensagem no QA2TMP									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
		QA_GrvTxt(cChaveQEK,cEspecie,Len(aCols),@aTexto,"QA2TMP") 

	EndIf
	
EndIf	

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³																		  ³±±
±±³              FUNCOES UTILIZADAS NA VALIDACOES DOS CAMPOS              ³±±
±±³																		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200VlFo ³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Fornecedor no cad. Entradas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - E' cham. no X3_VALID do QEK_FORNEC               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A200VlFo()
Local lRetorno := .t. 
                 
If M->QEK_TIPONF$("DßB")
	If !ExistCpo("SA1",M->QEK_FORNEC,,,,.F.)
		lRetorno := .F.
	EndIf
Else
	If !ExistCpo("SA2",M->QEK_FORNEC,,,,.F.)
	 	lRetorno := .F.
    Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza consistencias a partir do Produto/Fornecedor         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
If lRetorno .And. !Empty(M->QEK_FORNEC) .and. !Empty(M->QEK_PRODUT) .And.	!Empty(M->QEK_LOJFOR)
	lRetorno := A200VlPF()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se os campos estao repetidos (For/Prod/Dt Ent/Lote) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
If lRetorno
	lRetorno := A200Chav()
EndIf          

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200VlLF ³ Autor ³ Quality   			³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Loja do Fornecedor no cad. Entradas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - E' cham. no X3_VALID do QEK_LOJFOR               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200VlLF()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe a Loja do Fornecedor                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
If M->QEK_TIPONF$("DßB")
	If !Empty(M->QEK_FORNEC) .And. !Empty(M->QEK_LOJFOR)
		If ! ExistCpo("SA1",M->QEK_FORNEC+M->QEK_LOJFOR)
			lRetorno := .F.
		EndIf
	Endif
Else
 	If !Empty(M->QEK_FORNEC) .And. !Empty(M->QEK_LOJFOR)
		If ! ExistCpo("SA2",M->QEK_FORNEC+M->QEK_LOJFOR)
			lRetorno := .F.
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza consistencias a partir do Produto x Fornecedor       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
		If lRetorno .And. !Empty(M->QEK_FORNEC) .And. !Empty(M->QEK_PRODUT) .And. !Empty(M->QEK_LOJFOR)
			lRetorno := A200VlPF()
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se os campos estao repetidos (For/Prod/Dt Ent/Lote) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
		If lRetorno
			lRetorno := A200Chav()
		EndIf
	EndIf
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200VlPr ³ Autor ³ Quality			    ³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Produto no cad. Entradas                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - E' cham. no X3_VALID do QEK_PRODUT               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200VlPr()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o Produto tiver Integracao com Materiais, verifica os tamanhos do campo NISERI ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+QE6->QE6_PRODUT))
	If RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == "Q"
		If (TamSx3("QEK_NTFISC")[1]+TamSx3("QEK_SERINF")[1]+TamSx3("QEK_ITEMNF")[1] > TamSx3("QEL_NISERI")[1] .OR.;
		    TamSx3("QEK_NTFISC")[1]+TamSx3("QEK_SERINF")[1]+TamSx3("QEK_ITEMNF")[1] > TamSx3("QER_NISERI")[1] .OR.;
			TamSx3("D1_DOC")[1]+TamSx3("D1_SERIE")[1]+ TamSx3("D1_ITEM")[1] > TamSx3("QER_NISERI")[1] .OR.;
		 	TamSx3("D1_DOC")[1]+TamSx3("D1_SERIE")[1]+ TamSx3("D1_ITEM")[1] > TamSx3("QEL_NISERI")[1]) 
			Help(" ",1,"QIENISERI")
			Return(.F.)
		EndIf
    Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe o Produto                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
If !ExistCpo("QE6",M->QEK_PRODUT)
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza consistencias a partir do Produto/Fornecedor         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
If lRetorno .And. !Empty(M->QEK_FORNEC) .And. !Empty(M->QEK_PRODUT) .And. !Empty(M->QEK_LOJFOR)
	lRetorno := A200VlPF()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se os campos estao repetidos (For/Prod/Dt Ent/Lote) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
If lRetorno
	lRetorno := A200Chav()
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200VlPF ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacoes a partir do Produto/Fornecedor                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - E' cham. no A200VlFo, A200VlLF e A200VlPr        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200VlPF()
Local lRetorno := .T.
Local aAreaSA5 := SA5->(GetArea())
Local aAreaSA7 := SA7->(GetArea())

If M->QEK_TIPONF $ 'DßB'
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe amarracao Produto x Fornecedor            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA7->(dbSetOrder(2))
	If !SA7->(dbSeek(xFilial("SA7")+M->QEK_PRODUT+M->QEK_FORNEC+M->QEK_LOJFOR))
		HELP(" ",1,"A200NAOPRC",,OemToAnsi("Não existe amarracao do Produto com o Cliente."),1,0)
		lRetorno := .F.
	EndIf
	
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe amarracao Produto x Fornecedor            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA5->(dbSetOrder(2))
	If !SA5->(dbSeek(xFilial("SA5")+M->QEK_PRODUT+M->QEK_FORNEC+M->QEK_LOJFOR))
		Help(" ",1,"A200NAOPRF")	// "Nao existe Amarracao do Produto com o Fornecedor"
		lRetorno := .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verif. se esta com a situação do produto x fornecedor em branco	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		If Empty(SA5->A5_SITU)
			Help(" ",1,"A200SEMSIT",,STR0089,1,0) //"O Relacionamento Produto x Fornecedor nao possui situação cadastrada !!"
			lRetorno := .f.
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a situacao do Produto X Fornecedor e' Nao Recebe ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QEG->(dbSetOrder(1))
	QEG->(dbSeek(xFilial("QEG")+SA5->A5_SITU))
	If QEG->QEG_CATEG == "4"
		Help(" ",1,"A200SITNHA") //"Situacao do Produto X Fornecedor tem Categoria Nao Recebe"
		lRetorno := .F.
		
	EndIf
	
EndIf

RestArea(aAreaSA5)
RestArea(aAreaSA7)

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200VlLt ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Numero do Lote                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - E' cham. no X3_VALID do QEK_LOTE                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A200VlLt()
Local lRetorno := .T.
Local cVar     := &(ReadVar()) 
Local cChave   := " "
Local nPosLt   := 0
Local aAreaQEK := QEK->(GetArea())
Local cNiseri  := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se utilizar Lote unico, verifica se j  existe				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
If GetMv("MV_QLOTUNI") == "S"
	QEK->(dbSetOrder(6))	
	If QEK->(dbSeek(xFilial("QEK")+cVar))
		Help(" ",1,"A200EXILOT") //"Numero do Lote j  existe."
		lRetorno := .F.

	EndIf
EndIf

If lRetorno .And. Inclui
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se Entrada anterior nao foi aprovada e exibe mensagem³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
	QEK->(dbSetOrder(2))
	If QEK->(dbSeek(xFilial("QEK")+M->QEK_FORNEC+M->QEK_LOJFOR+M->QEK_PRODUT))

		cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
		QEL->(dbSetOrder(3))
		cSeek := QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+cNiseri+QEK->QEK_TIPONF+;
		DTOS(QEK->QEK_DTENTR)+QEK->QEK_LOTE

		If QEL->(dbSeek(xFilial("QEL")+cSeek+Space(TamSX3("QEL_LABOR")[1])))
			
			If QEL->QEL_LAUDO <> cFatApr
				cChave := QEK->QEK_CHAVE
				
				Q200TxtPrxEnt(cChave,.F.,.F.,"QA2",QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QEK->QEK_DTENTR,QEK->QEK_LOTE,1)

				M->QEK_LOTE := cVar 
				nPosLt      := Ascan(aGets,{|x|Subs(x,9,10)=="QEK_LOTE  "})
				If nPosLt > 0
					aTela[Val(Subs(aGets[nPosLt],1,2))][Val(Subs(aGets[nPosLt],3,1))*2] := M->QEK_LOTE
				EndIf
				
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaQEK)

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200VlTl ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Tamanho do Lote e Tamanho da Amostra          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - E' cham. no X3_VALID do QEK_TAMLOT e QEK_TAMAMO  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200VlTL()
Local lRetorno := .T.
Local cVar     := &(ReadVar())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Tamanho do Lote/Amostra e' um numero valido    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
If !QA_VerNum(@cVar)
	HELP(" ",1,"QA_NUMINV")
	lRetorno := .F.
EndIf             

If ReadVar() == "M->QEK_TAMLOT"
	M->QEK_TAMLOT := cVar
ElseIf ReadVar() == "M->QEK_TAMAMO"
	M->QEK_TAMAMO := cVar
EndIf                         

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200VlUM ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Unidade de Medida                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - E' cham. no X3_VALID do QEK_UNIMED               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200VlUM(cUniMed)
Local lRetorno := .T.
Local cVar	   := &(ReadVar())	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Unidade de Medida foi associada ao Produto     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
QE6->(dbSetOrder(1))
QE6->(dbSeek(xFilial("QE6")+M->QEK_PRODUT+Inverte(M->QEK_REVI)))
If cVar <> QE6->QE6_UNMED1 .And. cVar <> QE6->QE6_UNMED2
	If !l200Auto
		MessageDlg(OemToAnsi(STR0053),,1)	//"Unidade de Medida n„o foi associada ao Produto."
	EndIf	
	lRetorno := .F.
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200VlDi ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Dias de Atraso                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA200 - E' cham. no X3_VALID do QEK_DIASAT               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A200VlDi()
Local nVar     := &(ReadVar())
Local nMvDiAtr := 0
Local cMvCoDia := " "

//Parametro que indica o numero maximo de dias em atraso
nMvDiAtr := SuperGetMv("MV_QDIAIPO")

//Parametro que indica se ir  consistir o no. de dias em atraso
cMvCoDia := SuperGetMv("MV_QCONDIA")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o no. Dias for maior que o parametro, assume o parametro  ³
//³ Compara com o valor em modulo, porque pode ser negativo.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
If cMvCoDia == "S"
	nVar          := If(Abs(nVar)>nMvDiAtr,If(nVar<0,0-nMvDiAtr,nMvDiAtr),nVar)
	M->QEK_DIASAT := nVar
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200VldVer³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a situacao a ser aplicada na Entrada				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - VALID QEK_VERIFI								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q200VldVer(nVerifi)
Local lRetorno := .T.

If !(nVerifi == 1 .Or. nVerifi == 2)
	lRetorno := .F.
Else	
	M->QEK_INSCER := A200DICL(nVerifi,.T.)
EndIf

//Verifica se a sugestao do Skip-Lote foi alterada pelo usuario
If (nVerifi <> nVerifica) .And. lRetorno .And. !l200Auto
   	Help(" ",1,"QE200NSKLT",,OemToAnsi(STR0085),1) //"Nao e permitido alterar a Situacao do Skip-Lote que foi sugerida"
	lRetorno := .F.
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200VldSol³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a Matricula do Usuario em sua respectiva filial     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - VALID QEK_SOLIC								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q200VldSol()
Local lRetorno := QA_ChkMat(M->QEK_FILMAT,M->QEK_SOLIC)

If M->QEK_FILMAT # xFilial('QAA')
	M->QEK_FILMAT := xFilial('QAA')
EndIf

Return(lRetorno)          

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200RIAI ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche os dados do RIAI, a partir do Fornecedor/Produto  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - E' cham. via gatilho a partir do QEK_PRODUT      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200RIAI(nDesc)
Local cRetorno := " " 
Local aAreaAnt := GetArea()
Local aAreaSA5 := SA5->(GetArea())

If !Empty(M->QEK_FORNEC) .And. !Empty(M->QEK_PRODUT) .And. !Empty(M->QEK_LOJFOR)
	SA5->(dbSetOrder(2))
	SA5->(dbSeek(xFilial("SA5")+M->QEK_PRODUT+M->QEK_FORNEC+M->QEK_LOJFOR))
	cRetorno := If(nDesc==1,SA5->A5_RIAI,SA5->A5_VALRIAI)
EndIf
RestArea(aAreaSA5)         
RestArea(aAreaAnt)

Return(cRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200CEn1 ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Aciona consistencias a partir do Produto/Data Entrada      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - E' cham. no valid de QEK_PRODUT e QEK_DTENTR     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200cEn1()
Local lRetorno := .T.
Local aAreaSA5 := SA5->(GetArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a validade do RIAI                     			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
If !Empty(M->QEK_DTENTR) .And. !Empty(M->QEK_PRODUT) .And. !Empty(M->QEK_FORNEC) .And. !Empty(M->QEK_LOJFOR)
	SA5->(dbSetOrder(2))
	SA5->(dbSeek(xFilial("SA5")+M->QEK_PRODUT+M->QEK_FORNEC+M->QEK_LOJFOR))
	If !Empty(SA5->A5_RIAI) .And. M->QEK_DTENTR > SA5->A5_VALRIAI
		If Readvar() == "M->QEK_DTENTR"
			Help(" ",1,"A200RIAEXP")	// "Data de Validade do RIAI esta' expirada"
			lRetorno := .F.
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica a revisao vigente do Produto                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
If lRetorno .And. INCLUI .And. !Empty(M->QEK_DTENTR)
	cRevi := QA_UltRevEsp(M->QEK_PRODUT,M->QEK_DTENTR,.T.,,"QIE")
	If Empty(cRevi)	
		lRetorno := .F.
	EndIf
	M->QEK_REVI := cRevi
EndIf

RestArea(aAreaSA5)

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200UnMe ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para preencher a Unidade de Medida                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - Cham. no X3_RELACAO e gatilho (QEK_DTENTR)       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200UnMe(cProduto,cRevisao,lGatilho)
Local aAreaAnt := GetArea()
Local cRetorno := Space(Len(QE6->QE6_UNMED1))

lGatilho := If(lGatilho==NIL,.T.,lGatilho)

IF !Inclui .Or. lGatilho
	If !Empty(cProduto) .And. !Empty(cRevisao)
		QE6->(dbSetOrder(1))
		QE6->(dbSeek(xFilial("QE6")+cProduto+Inverte(cRevisao)))
		cRetorno      := QE6->QE6_UNMED1
		M->QEK_DUNMED := QA_DESUM(cRetorno,.T.)
	EndIf
EndIf                      
RestArea(aAreaAnt)
Return(cRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200UnAm ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para preencher a Unidade de Amostragem             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - Cham. no X3_RELACAO e gatilho (QEK_UNIMED)       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200UnAm(cUnMed,lGatilho)
Local aAreaAnt := GetArea()
Local cRetorno := Space(TamSX3("QE6_UNAMO1")[1])
Local cProduto := If(Inclui .Or. Altera,M->QEK_PRODUT,QEK->QEK_PRODUT)
Local cRevisao := If(Inclui .Or. Altera,M->QEK_REVI,QEK->QEK_REVI)

lGatilho := If(lGatilho == NIL,.T.,lGatilho)

IF !Inclui .Or. lGatilho
	QE6->(dbSetOrder(1))
	QE6->(dbSeek(xFilial("QE6")+cProduto+Inverte(cRevisao)))      
	
	If QE6->QE6_UNMED1 == cUnMed
		SAH->(dbSetOrder(1))
		SAH->(dbSeek(xFilial("SAH")+QE6->QE6_UNAMO1))
		cRetorno := SAH->AH_UMRES
		cFatCon  := QE6->QE6_FATCO1	 //variavel definida na Q200Atualiza()
		cTipCon  := QE6->QE6_TIPCO1	 //variavel definida na Q200Atualiza()

	ElseIf QE6->QE6_UNMED2 == cUnMed
		SAH->(dbSetOrder(1))
		SAH->(dbSeek(xFilial("SAH")+QE6->QE6_UNAMO2))
		cRetorno := SAH->AH_UMRES
		cFatCon  := QE6->QE6_FATCO2	//variavel definida na Q200Atualiza()
		cTipCon  := QE6->QE6_TIPCO2	//variavel definida na Q200Atualiza()

	EndIf
EndIf
RestArea(aAreaAnt)
Return(cRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200GaTA ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para preencher o Tamanho da Amostra                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - Cham. no X3_RELACAO e gatilho (QEK_TAMLOT)       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200GaTA(cTamLot,lGatilho)
Local cRetorno := " "
Local nDec     := 0
Local aAreaAnt := GetArea()
                          
lGatilho := If(lGatilho==NIL,.T.,lGatilho)
If lGatilho
	cTamLot  := If(Empty(cTamLot),M->QEK_TAMAMO,cTamLot)
EndIF

Inclui := IIf(Type('Inclui') == "U" , .F. , Inclui)

IF !Inclui .Or. lGatilho
	If M->QEK_UNIMED == M->QEK_UNIAMO
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se as Unidades de Medida e Amostragem forem as mesmas, assume³
		//³ o Tamanho do Lote para a Amostra, sem get                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
		cRetorno := cTamLot
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o numero de casas decimais do Tamanho do Lote       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
		nDec := QA_NumDec(cTamLot)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define novamente o Fator Conversao, se nao estiver definido  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
		If cFatCon == NIL	
			QE6->(dbSetOrder(1))
			QE6->(dbSeek(xFilial("QE6")+M->QEK_PRODUT+Inverte(M->QEK_REVI)))
			If QE6->QE6_UNMED1 == M->QEK_UNIMED
				cFatCon := QE6->QE6_FATCO1
				cTipCon := QE6->QE6_TIPCO1
			ElseIf QE6->QE6_UNMED2 == M->QEK_UNIMED
				cFatCon := QE6->QE6_FATCO2
				cTipCon := QE6->QE6_TIPCO2
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o Tamanho da Amostra                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
		If SuperVal(cFatCon) <> 0
			If cTipCon == "D"
				cRetorno := Str(SuperVal(cTamLot)/SuperVal(cFatCon),TamSX3("QEK_TAMAMO")[1],nDec)
			Else
				cRetorno := Str(SuperVal(cTamLot)*SuperVal(cFatCon),TamSX3("QEK_TAMAMO")[1],nDec)
			EndIf
		Else
			cRetorno := PadR(AllTrim(cTamLot),TamSX3("QEK_TAMAMO")[1])
		EndIf

		//Muda de ponto para virgula a casa decimal
		cRetorno := StrTran(cRetorno,'.',',')
		
	EndIf
Else
	cRetorno := Space(TamSX3("QEK_TAMAMO")[1])
EndIf

RestArea(aAreaAnt)

Return(cRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200DICL ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra a descricao das opcoes: Inspeciona/Certifica/Libera ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - Cham. X3_RELACAO,X3_INIBRW e gatilho (QEK_VERIFI)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200DICL(nOpcao,lGatilho)
Local cRetorno := " "

lGatilho := If(lGatilho == NIL,.T.,lGatilho)
Inclui := IIf(Type('Inclui') == "U" , .F. , Inclui)

If !Inclui .Or. lGatilho
	If nOpcao == 1
		cRetorno := OemToAnsi(STR0022)	//"Inspeciona"
	ElseIf nOpcao == 2
		cRetorno := OemToAnsi(STR0023)	//"Certifica"
	EndIf
Else
	cRetorno := Space(TamSX3("QEK_INSCER")[1])
EndIf
Return(cRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200DSOL ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra o nome do Solicitante                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - Cham. X3_RELACAO,X3_INIBRW e gatilho (QEK_SOLIC) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200DSol(cFilUsu,cSolic,lGatilho)
Local cRetorno := Space(TamSX3("QAA_NOME")[1])
Local aAreaAnt := GetArea()
Local aAreaQAA := QAA->(GetArea())

lGatilho := If(lGatilho==NIL,.T.,lGatilho)
Inclui := IIf(Type('Inclui') == "U" , .F. , Inclui)

If !Inclui .Or. lGatilho
	QAA->(dbSetOrder(1))
	If QAA->(dbSeek(cFilUsu+cSolic))
		cRetorno := QAA->QAA_NOME
	EndIf
EndIf
RestArea(aAreaQAA) 
RestArea(aAreaAnt)
Return(cRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200DeFo ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra a descricao do Fornecedor                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - Cham. via gatilho e X3_RELACAO - QEK_FORNEC      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200DeFo(cFornece,cLoja,lGatilho,cTipoNF)
Local cRetorno := Space(TamSX3("A2_NOME")[1])
Local aAreaSA1
Local aAreaSA2                
Local aAreaAnt := GetArea()  

Default cTipoNF := QEK->QEK_TIPONF

lGatilho := If(lGatilho == NIL,.T.,lGatilho)
Inclui := IIf(Type('Inclui') == "U" , .F. , Inclui)

IF !Inclui .Or. lGatilho	
	If !Empty(cFornece) .And. !Empty(cLoja)
		If cTipoNF $ 'DßB'
			aAreaSA1 := SA1->(GetArea())
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+cFornece+cLoja))
				cRetorno := SA1->A1_NOME
			EndIf	
			RestArea(aAreaSA1)
		Else                 
			aAreaSA2 := SA2->(GetArea())
			SA2->(dbSetOrder(1))
			If SA2->(dbSeek(xFilial("SA2")+cFornece+cLoja))
			 	cRetorno := SA2->A2_NOME
			EndIf                        
			RestArea(aAreaSA2)
		EndIf
	EndIf
EndIf

RestArea(aAreaAnt)

Return(cRetorno)
               
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200DePr ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra a descricao do Produto do QE6                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - Cham. via gatilho e X3_RELACAO - QEK_PRODUT      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200DePr(cProduto,lGatilho,cRevi)
Local cRetorno := Space(TamSX3("QE6_DESCPO")[1])
Local aAreaAnt := GetArea()
Local aAreaQE6 := QE6->(GetArea())
Default cRevi    := ""

lGatilho := If(lGatilho==NIL,.T.,lGatilho)

IF !Inclui .Or. lGatilho	
	If ! Empty(cProduto)   
		dbSelectArea("QE6")
		dbSetOrder(3)
		dbSeek(xFilial("QE6")+cProduto+cRevi,.T.)
		If !Eof()
			If cRevi <> ""
				cRevi    := QE6->QE6_REVI
				cRetorno := QE6->QE6_DESCPO
		    Else
				While !Eof() .And. cProduto == QE6->QE6_PRODUT
					If QE6->QE6_REVI > cRevi
						cRetorno := QE6->QE6_DESCPO
					EndIf
					dbSkip()
				EndDo
			Endif
		EndIf
	EndIf
EndIf
RestArea(aAreaQE6)
RestArea(aAreaAnt)

Return(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³																		  ³±±
±±³            FUNCOES UTILIZADAS NA PRE-VALIDACOES DOS CAMPOS            ³±±
±±³																		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200WhDE ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para When do campo Data de Entrada                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - Chamada no QEK_DTENTR (X3_WHEN)                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A200WhDE()
Local lRetorno := .T.

If ReadVar() == "M->QEK_DTENTR"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Forca a entrada do Fornecedor e Produto primeiro.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
	If Empty(M->QEK_PRODUT) .Or. Empty(M->QEK_FORNEC) .Or. Empty(M->QEK_LOJFOR)
		HELP(" ",1,"A200VAZFPR")	// Especifique primeiramente o Fornecedor e o Produto.
		lRetorno := .F.
	EndIf
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200WhLt ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para When do campo Lote                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - Chamada no QEK_LOTE (X3_WHEN)                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200WhLt()
Local lRetorno := .T.
Local aAreaAnt 
Local nSaveSX8 := GetSX8Len()

If ReadVar() == "M->QEK_LOTE"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Forca a entrada do Fornecedor, Produto e Data Entrada primeiro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
	If Empty(M->QEK_PRODUT) .or. Empty(M->QEK_FORNEC) .Or. Empty(M->QEK_DTENTR) .Or. Empty(M->QEK_LOJFOR)
		HELP(" ",1,"A200VAZFPD")	// Especifique primeiramente o Fornecedor, o Produto e a Data Entrada.
		lRetorno := .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se utilizar Lote sequencial, calcula o proximo Lote.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
	If lRetorno .And. Inclui .And. GetMv("MV_QLOTSEQ") == "S"
		If Empty(M->QEK_LOTE) 
			aAreaAnt := QEK->(GetArea())              
			dbSelectArea("QEK")
			dbSetOrder(6)
			M->QEK_LOTE := AllTrim(GetSx8Num("QEK","QEK_LOTE","LOTESEQU"+cNumEmp,6)) 
		    While dbSeek(xFilial("QEK")+M->QEK_LOTE)
				While ( GetSX8Len() > nSaveSx8 )
					ConfirmSX8()
				EndDo
			    M->QEK_LOTE := AllTrim(GetSx8Num("QEK","QEK_LOTE","LOTESEQU"+cNumEmp,6))
			EndDo   
		   	ConfirmSX8()
			RestArea(aAreaAnt)
		EndIf	
	EndIf
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200WhUM ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para When do campo Unidade de Medida                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - Chamada no QEK_UNIMED (X3_WHEN)                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200WhUM()
Local lRetorno := .T.

If ReadVar() == "M->QEK_UNIMED"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Forca a entrada do Fornecedor, Produto e Data Entrada primeiro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
	If Empty(M->QEK_PRODUT) .Or. Empty(M->QEK_FORNEC) .Or. Empty(M->QEK_DTENTR) .Or. Empty(M->QEK_LOJFOR)
		HELP(" ",1,"A200VAZFPD")	// Especifique primeiramente o Fornecedor,Produto e a Data Entrada.
		lRetorno := .F.
	EndIf
	
	If lRetorno
		QE6->(dbSetOrder(1))
		QE6->(dbSeek(xFilial("QE6")+M->QEK_PRODUT+Inverte(M->QEK_REVI)))
		
		If Empty(QE6->QE6_UNMED2)
			lRetorno := .F.
		EndIf
	EndIf
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200WhTA ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para When do campo Tamanho da Amostra               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - Chamada no QEK_TAMAMO (X3_WHEN)                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200WhTA()
Local lRetorno := .T.
Local aAreaAnt := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Forca a entrada do Tamanho do Lote primeiro.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
If ReadVar() == "M->QEK_TAMAMO"
	If Empty(M->QEK_TAMLOT)
		HELP(" ",1,"A200VAZTLO")	//Especifique primeiramente o Tamanho do Lote
		lRetorno := .F.
	EndIf
	
	If lRetorno
		If M->QEK_UNIMED == M->QEK_UNIAMO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se as Unidades de Medida e Amostragem forem as mesmas, assume³
			//³ o Tamanho do Lote para a Amostra, sem get.                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
			lRetorno := .F.
		EndIf
	EndIf
	
	If Altera          
		//Verifica se ha integracao com Materiais x EIC
		If !Empty(QEK->QEK_TES)
			lRetorno := .F.
		EndIf             
		
		//Verifica se ha medicoes informadas para a Entrada
		If QEK_SITENT <> "1"
			lRetorno := .F.
		EndIf                        
	EndIf
EndIf

RestArea(aAreaAnt)

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200WhSo ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para When do campo Solicitante                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - Chamada no QEK_SOLIC (X3_WHEN)                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200WhSo()
Local lRetorno := .T. 
Local aAreaAnt := GetArea()

If ReadVar() == "M->QEK_SOLIC"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verif. se a Situacao Produto X Fornecedor possui categoria   ³
	//³ Sem Skip-Lote (C) 											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(M->QEK_FORNEC) .And. !Empty(M->QEK_PRODUT) .And. !Empty(M->QEK_LOJFOR)
		SA5->(dbSetOrder(2))
		If SA5->(dbSeek(xFilial("SA5")+M->QEK_PRODUT+M->QEK_FORNEC+M->QEK_LOJFOR))
			QEG->(dbSetOrder(1))
			QEG->(dbSeek(xFilial("QEG")+SA5->A5_SITU))
	
			If QEG->QEG_CATEG <> "3" .Or. ;
				QEG->QEG_CATEG == "3" .And. SuperGetMv("MV_QSOLPQU") <> "S"	// Par. p/ Solic. p/ "Sem Skip-Lote"
				lRetorno := .F.
			EndIf
		EndIf
	EndIf		
EndIf

RestArea(aAreaAnt)

Return(lRetorno)                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Q200WhnNF³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se os campos referentes a Nota Fiscal poderao ser ³±±
±±³			 ³ alterados.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                       
Function Q200WhnNF()
Local lRetorno := .T.

If !Inclui
	If (ReadVar() == "M->QEK_HRENTR") .Or. (ReadVar() == "M->QEK_NTFISC") .Or.;
		(ReadVar() == "M->QEK_DTNFIS") .Or. (ReadVar() == "M->QEK_SERINF")
		lRetorno := .F.	
	EndIf
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200WhTL ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para When do campo Tamanho do Lote                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - Chamada no QEK_TAMLOT (X3_WHEN)                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A200WhTL()
Local lRetorno := .T.
Local aAreaAnt := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Forca a entrada do Fornecedor, Produto e Data Entrada primeiro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
If ReadVar() == "M->QEK_TAMLOT"
	If Empty(M->QEK_PRODUT) .Or. Empty(M->QEK_FORNEC) .Or. Empty(M->QEK_DTENTR) .Or.Empty(M->QEK_UNIMED) .Or. Empty(M->QEK_LOJFOR)
		//Especifique primeiramente o Fornecedor,Produto,Data Entrada e Unid. Medida
		HELP(" ",1,"A200VAFPDU")
		lRetorno := .F.

	EndIf
	
	If Altera          
		//Verifica se ha integracao com Materiais x EIC
		If !Empty(QEK->QEK_TES)
			lRetorno := .F.
		EndIf             
		
		//Verifica se ha medicoes informadas para a Entrada
		If QEK_SITENT <> "1"
			lRetorno := .F.
		EndIf                        
	EndIf
EndIf

RestArea(aAreaAnt)

Return(lRetorno)              

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q200FilPro³ Autor ³Paulo Emidio de Barros ³ Data ³27/12/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Devolve o filtro com os Produtos na revisao corrente       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA200 - X3_F3 do campo QEK_PRODUT                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q200FilPro()   
Local xRetorno := .T.

If INCLUI
	If !Empty(M->QEK_FORNEC)
		
		If M->QEK_TIPONF $ "D|B"                             
			//Posiciona no registro da Amarracao Produto x Cliente
			SA7->(dbSetorder(1))
			SA7->(MsSeek(xFilial("SA7")+M->QEK_FORNEC+M->QEK_LOJFOR+QE6->QE6_PRODUT))
	   	
			xRetorno := QE6->QE6_FILIAL==xFilial("QE6") .And. M->QEK_FORNEC==SA7->A7_CLIENTE  .And. M->QEK_LOJFOR==SA7->A7_LOJA .And.;
				SA7->A7_PRODUTO==QE6->QE6_PRODUT .And. UniqueKey("QE6_PRODUT" + "QE6_REVI","QE6") .And.;
				dTos(QE6->QE6_DTINI)<=dTos(dDataBase)
		Else 
			//Posiciona no registro da Amarracao Produto x Fornecedor
			SA5->(dbSetorder(1))
			SA5->(MsSeek(xFilial("SA5")+M->QEK_FORNEC+M->QEK_LOJFOR+QE6->QE6_PRODUT))
	   	
			xRetorno := QE6->QE6_FILIAL==xFilial("QE6") .And. M->QEK_FORNEC==SA5->A5_FORNECE .And. M->QEK_LOJFOR==SA5->A5_LOJA .And.;
				SA5->A5_PRODUTO==QE6->QE6_PRODUT .And. UniqueKey("QE6_PRODUT" + "QE6_REVI","QE6") .And.;
				dTos(QE6->QE6_DTINI)<=dTos(dDataBase)
		EndIF
	Else
		xRetorno := .T.
	EndIf	
EndIF

Return(xRetorno)       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 QE200F3CF	³ Autor ³ Cleber Souza          ³ Data ³ 19/09/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta uma consulta via SXB especifica						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA200.PRW												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE200F3CF()
        
Local lRet

If IIF(type('M->QEK_TIPONF') <> 'U',M->QEK_TIPONF $ 'DB',.F.)
	cCliFor := "C"
	lRet := ConPad1(,,,"SA1")
Else
	cCliFor := "F"
	lRet := ConPad1(,,,"QFO")
EndIf                        

Return(lRet)
