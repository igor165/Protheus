#INCLUDE "QIPA040.CH"
#include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPA040  ³ Autor ³ Cleber Souza          ³ Data ³ 05/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Grupo de Produtos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001)  ,"AxPesqui"  , 0 , 1,,.F.},; //"Pesquisa" 
                     {OemToAnsi(STR0002)  ,"QP040GPr"  , 0 , 2},;     //"Visualiza"
                     {OemToAnsi(STR0003)  ,"QP040GPr"  , 0 , 3},;     //"Incluir" 
                     {OemToAnsi(STR0004)  ,"QP040GPr"  , 0 , 4},;     //"Alterar" 
                     {OemToAnsi(STR0005)  ,"QP040GPr"  , 0 , 5 , 3} } //"Excluir"


Return aRotina

Function QIPA040(xAutoCab,xAutoItens,nOpcAuto)
PRIVATE l040Auto   := xAutoCab <> NIL  .And. xAutoItens <> NIL
PRIVATE aAutoCab   := {}
PRIVATE aAutoItens := {}

PRIVATE __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
PRIVATE lProduto   := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0006)  //"Grupos de Produtos" 

DEFAULT nOpcAuto := 3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
PRIVATE aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento de Rotina Automatica            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ( Type("l040Auto") <> "U" .And. l040Auto )
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"QP3")
	xAutoCab   := aAutoCab
	xAutoItens := aAutoItens	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"QP3")
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A040GPr  ³ Autor ³ Cleber Souza          ³ Data ³ 05/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastra Produtos dos Grupos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040GPr(ExpC1,ExpN1,ExpN2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada no menu                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 

Function QP040GPr(cAlias,nReg,nOpc)                 

Local	nOpcA		:= 0
Local 	nX			:= 0
Local	nY			:= 0
Local	lExecuta	:= .T.
Local 	oSize
Local 	aPosObj	:= {}
Local aStruAlias := FWFormStruct(3, "QP3")[3]
Private oGet,oEncQP3  
Private aCpoQP3  := {{},{}} 
Private nPosPro  := 0
Private nPosDPr  := 0
Private nPosTipo := 0
Private nPosAli  := 0
Private nPosRec  := 0
Private aCols    := {}
Private aColsAnt := {}
Private aHeader  := {}   
Private aTela    := {}
Private aGets    := {}       
Private aespecificacao:={}                
Private aroteiros:={}                      
Private aHeaderQQK := aClone(APBuildHeader("QQK"))
Private aHeaderQP7 := QPA010HeadEsp(aClone(APBuildHeader("QP7"))) //Prepara o aHeader com os demais campos a serem utilizados na Especificacao
Private aHeaderQQ1 := aClone(APBuildHeader("QQ1"))
Private aHeaderQP9 := aClone(APBuildHeader("QP9"))
Private aHeaderQQ2 := AClone(APBuildHeader("QQ2"))
Private aHeaderQQH := AClone(APBuildHeader("QQH"))                //somente para montagem da estrutura 
Private nPosLab   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LABOR" })
Private nPosSeq   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_SEQLAB"})
Private nPosOper    := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_OPERAC" }) 
Private nPosEns   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_ENSAIO"}) 
Private nPosNiv   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_NIVEL" })
Private nPosInstr := Ascan(aHeaderQQ1,{|x|AllTrim(x[2])=="QQ1_INSTR"})     
Private nPosNC  := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_NAOCON"})
Private nPosPlano  := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_PLANO"}) 
Private nPosNQA    := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_NQA"   })
Private nPosNivel  := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_NIVAMO"})
Private nPosAmo    := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_AMOST" })
Private nPosDPl   := Ascan(aHeaderQP7,{|x|AllTrim(x[2])=="QP7_DESPLA"})
Private nPosChav    := AsCan(aHeaderQQK,{|x|AllTrim(x[2])=="QQK_CHAVE"  })
Private nPosDescr := Ascan(aHeaderQQ1,{|x|AllTrim(x[2])=="QQ1_DESCR"}) 
Private nPosCla := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_CLASSE"})     
Private nPosUM    := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_UNIMED"}) 
Private nPosAFI   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_AFI"   })
Private nPosAFS   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_AFS"   })
Private nPosDNC := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_DESNCO"})
Private nPosDCl := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_DESCLA"})
Private nPosDesc  := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_DESC"  }) 
Private nPosPlA   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_PLAMO" })
Private nPosDoc	  := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_METODO"})
Private nPosRvDoc := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_RVDOC" })
Private nPosTipIn := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_TIPO"  })
Private nPosNom   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_NOMINA"})
Private nPosRastr := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_PRODUT"})
Private lIntQMT := If(GetMV('MV_QIPQMT')=="S",.T.,.F.) //Define a Integracao com o QMT  
Private __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo 
Private __cREVISAO := CriaVar("QP6_REVI")   //Revisao do Produto ou Grupo
Private __dREVISAO := CriaVar("QP6_DTINI")  //Vigencia do Produto ou Grupo
Private __cROTEIRO := CriaVar("QP6_CODREC") //Roteiro de Operacoes do Produto ou Grupo 
Private cPrioriR := GetMv("MV_QIPOPEP",.F.,"2") //Prioriza dados do Roteiro/Operacoes de 1 = Materiais / 2 - Quality   


Private __lQP010DEL := ExistBlock("QP010DEL")
Private __lQPATUSB1 := ExistBlock("QPATUSB1")
Private __lQPA010R  := ExistBlock("QPA010R")
Private __lQP010GRV := ExistBlock("QP010GRV")
Private __lQP010OPE := ExistBlock("QP010OPE")
Private __lQP010J11 := ExistBlock("QP010J11")
Private __lQIP010JR := ExistBlock("QIP010JR")
Private __lQPATUGRV := ExistBlock("QPATUGRV")          
Private cEspecie := "QIPA010 "

Default cRotGrp := CriaVar("QP6_CODREC")
Default cStatus := CriaVar("QP6_SITREV")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o vetor com os campos a serem utilizados na Enchoice    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aStruAlias)
	If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") 
		Aadd(aCpoQP3[1],aStruAlias[nX,1])
		Aadd(aCpoQP3[2],GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT"))
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria as variaveis para edicao na Enchoice     		         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.F.)  

If nOpc != 3
	FillGetDados(nOpc,"QPA" ,1     ,       ,            ,         ,         ,          ,        ,     ,{|| QP040Cols(nOpc)},       ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols           ,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
Else
	FillGetDados(nOpc,"QPA" ,1     ,      ,             ,         ,         ,          ,        ,      ,        ,  .T.  ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva aCols original                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Altera
	aColsAnt := aClone( aCols )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a posicao dos campos no aHeader p/ posterior consistencia   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosPro  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_PRODUT"})
nPosDPr  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_DESPRO"})
nPosTipo := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_TIPO"})
nPosAli  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_ALI_WT"})
nPosRec  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_REC_WT"})

If ( Type("l040Auto") == "U" .Or. ! l040Auto )
	oSize := FwDefSize():New(.T.)
	
	oSize:AddObject('HEADER',100,70,.T.,.F.)
	oSize:AddObject('GRID'  ,100,10,.T.,.T.)
	
	oSize:aMargins 	:= { 3, 3, 3, 3 }
	oSize:Process()
	
	aAdd(aPosObj,{oSize:GetDimension('HEADER', 'LININI'),oSize:GetDimension('HEADER', 'COLINI'),oSize:GetDimension('HEADER', 'LINEND'),oSize:GetDimension('HEADER', 'COLEND')})
	aAdd(aPosObj,{oSize:GetDimension('GRID'  , 'LININI'),oSize:GetDimension('GRID'  , 'COLINI'),oSize:GetDimension('GRID'  , 'LINEND'),oSize:GetDimension('GRID'  , 'COLEND')})

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0006) FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL	 //"Grupos de Produtos"

		oEncQP3 := MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,.F.,,,,,,,.T.)
		oGet    := MsGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4], nOpc,"QP040lOk","QP040TOk",,.T.,NIL,NIL,NIL,999,,,,,oDlg)			

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,IIf(Obrigatorio(aGets,aTela) .AND. oGet:TudoOk(),oDlg:End(),nOpcA:=0)},{||oDlg:End()}) CENTERED  
Else  
	If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela)},aRotina[nOpc][4]) .and. MsGetDAuto(aAutoItens,"QP040lOk",{|| QP040TOk()},aAutoCab,aRotina[nOpc][4])      
		nOpcA := 1
	EndIf
EndIF

IF nOpcA == 1	// Confirma
                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rotina de Exclusao do Grupo x Produtos						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 5
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe  especificao para o Grupo antes de  exclui-lo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QQC")
		dbSetorder(1)
		DbSeek(xFilial("QQC")+QP3->QP3_GRUPO)
		IF !EOF() .AND. (QQC_FILIAL+QQC_GRUPO==xFilial("QQC")+QP3->QP3_GRUPO)
			lExecuta := .F.		
			MsgAlert(OemToAnsi(STR0008))
		EndIf
		If lExecuta
			Begin Transaction
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apaga tambem do QPA -> Amarracao Grupo X Produtos    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea('QPA')
			dbSetOrder(1)
			dbSeek( xFilial("QPA")+QP3->QP3_GRUPO )
			While !EOF() .And. QPA_FILIAL+QPA_GRUPO==xFilial("QPA")+QP3->QP3_GRUPO
				RecLock("QPA",.F.,.t.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apos passar por todas as verificacoes , deleta o registro    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.)
			dbDelete()
			MsUnLock()
	
			End Transaction
        EndIf
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rotina de Alteração / Inclusão do Grupo x Produtos			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    ElseIf nOpc == 4 .or. nOpc == 3
    
	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao do Cabecalho (QP3).								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QP3")
		dbSetOrder(1)
		If !dbSeek(xFilial("QP3")+M->QP3_GRUPO)		    
			RecLock("QP3",.T.)
			QP3->QP3_FILIAL := xFilial("QP3")
		Else
			RecLock("QP3",.F.)
		EndIf
        Aeval(aCpoQP3[1],{|x,y|QP3->&(aCpoQP3[1,y]):=M->&(aCpoQP3[1,y])})
 		MsUnlock()

	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o arquivo QPA											 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		For nX := 1 to Len(aCols)
			If !Acols[nX,Len(aHeader)+1]	// Nao esta deletado
					dbSelectArea("QPA")
					dbSetOrder(1)
					If dbSeek(xFilial("QPA") + QP3->QP3_GRUPO + aCols[nX,nPosPro])			
						RecLock("QPA",.F.)	 
					Else
						RecLock("QPA",.T.) 
					Endif
					For nY := 1 to Len(aHeader)
						If aHeader[nY,10] # "V"
							cVar := Trim(aHeader[nY][2])
							Replace &cVar. With aCols[nX,nY]
						Endif
					Next nY
					RecLock("QPA",.F.)
					QPA->QPA_GRUPO  := QP3->QP3_GRUPO
					QPA->QPA_FILIAL := xFilial("QPA")
					MsUnLock()
				If nopc == 4
					//Obtem a ultima Revisao do Produto
					cProduto := QPA->QPA_PRODUT
					cUltRev  := QA_UltRevEsp(cProduto,,,.T.,"QIP")
					
					cRevGrp:=QA_UltRvG(QPA->QPA_GRUPO,,.F.)
					QQC->(DbSetOrder(1))
					If QQC->(DbSeek(xFilial("QQC")+QPA->QPA_GRUPO))
						cRotGrp:= QQC->QQC_CODREC
						cStatus:= QQC->QQC_SITREV
						
					Endif
					
					QP6->(dbSetorder(1))
					IF QP6->(dbSeek(xFilial("QP6")+cProduto+Inverte(cUltRev)))
						If EMPTY(QP6->QP6_GRUPO) .AND. EMPTY(QP6->QP6_REVIGR)
							//Atualiza os dados referentes a Especificacao dos Produtos
							_nrec:=QP6->(RECNO())
							QP6->(dbSetOrder(4)) //Grupo+Revisao
							IF QP6->(dbSeek(xFilial("QP6")+QPA->QPA_GRUPO+cRevGrp))
								If QP6->(!Eof())
									cProduto := QP6->QP6_PRODUT
									cRevisao := QP6->QP6_REVI
									cRoteiro := QP6->QP6_CODREC
								    
									QP6->(Dbgoto(_nrec))
									//Preenche os dados referentes a Especificacao do Grupo
									_aArea:=GetArea()
									QPA010FilEsp(cProduto,cRevisao,cRoteiro)
									
									QPAAtuEsp(QP6->QP6_PRODUT,QP6->QP6_REVI,.T.,nopc)
									
									RestArea(_aArea)								
	
									//Atualiza os dados referentes ao Grupo
									RecLock("QP6",.F.)
									QP6->QP6_GRUPO  := QPA->QPA_GRUPO
									QP6->QP6_REVIGR := cRevGrp
									QP6->QP6_CODREC := cRotGrp
									QP6->QP6_SITREV := cStatus
									MsUnLock() 
								Endif
							EndIf
						
						
						
						EndIf
					EndIf             
					
				Endif
			Else
			 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cancela o Produto no QPA              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("QPA")
				If dbSeek(xFilial("QPA") + QP3->QP3_GRUPO + aCols[nX,nPosPro])			
					RecLock("QPA",.F.)
					dbDelete()
					MsUnLock()
				EndIf
	 		EndIf
		Next nX
    EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto ode entrada QP040GRV executado apos a gravacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QP040GRV")
		ExecBlock("QP040GRV",.F.,.F.,{nOpc,aClone(aHeader),aClone(aCols)})
	EndIf
EndIF

Return
          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A040Cols  ºAutor  ³ Cleber Souza       º Data ³  05/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carega aCols com os Produtos.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIPA040                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QP040Cols(nOpc)

Local nX       := 0
Local nPosAli  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_ALI_WT"})
Local nPosRec  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_REC_WT"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega aCols com os produtos relacionados.	                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc<> 3 
	dbSelectArea("QPA")
	DbSetOrder(1)
	dbSeek(xFilial("QPA")+QP3->QP3_GRUPO)
	While !EOF() .And. QPA_FILIAL+QPA_GRUPO == xFilial("QPA")+QP3->QP3_GRUPO 
		Aadd(aCols,Array(Len(aHeader)+1))
	    For nX := 1 to Len(aHeader) 
		    If aHeader[nX,10] <> "V"
				aCols[Len(aCols),nX] := &("QPA->"+aHeader[nX,2])
			ElseIF aHeader[nX,10] == "V"
				If !(aHeader[nX,2] $ "QPA_ALI_WT | QPA_REC_WT")
					If aHeader[nX,2] == "QPA_DESPRO"
						aCols[Len(aCols),nX] := QIPXDePr(QPA->QPA_PRODUT)
					Else
						aCols[Len(aCols),nX] := CriaVar(AllTrim(aHeader[nX,2]))
					EndIf
				ElseIf nPosAli > 0 .and. nPosRec > 0
					aCols[Len(aCols),nPosAli] := "QPA"
					If IsHeadRec(aHeader[nPosRec,2])
						aCols[Len(aCols),nPosRec] := QPA->(RecNo())
					EndIf
				Endif	
			Endif
		Next nX	
		aCols[Len(aCols),Len(aHeader)+1] := .F.
		QPA->(dbSkip())
	Enddo    
	
Else
    Aadd(aCols,Array(Len(aHeader)+1))
	Aeval(aHeader,{|x,y|aCols[Len(aCols),y]:=CriaVar(AllTrim(aHeader[y,2]))})
	aCols[Len(aCols),Len(aHeader)+1] := .F.    
EndIf
       
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QP040lOk  ³ Autor ³ Cleber Souza          ³ Data ³ 06/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP040lOk(o)

Local lRetu    :=.T.
Local nAchou   :=0
Local cProcura := aCols[n][nPosPro]

If !(aCols[n,Len(aCols[n])])  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se campo Produto esta' preenchido                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[n][Len(aHeader)+1] .And. LastKey() != 5 .And. LastKey() != 27 .And. lRetu
		If Empty(aCols[n][nPosPro])
			Help(" ",1,"QA_CPOOBR")
			lRetu:=.F.	
		EndIf
	EndIf 
	
	If lRetu
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Produto ja' existe                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nAchou := Ascan(aCols,{|x| x[nPosPro] == cProcura .And. !(x[Len(aCols[n])])})
		If nAchou > 0 .And. nAchou # n
			Help(" ",1,"A040EXIPRG")
			lRetu:=.F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Produto esta' cadastrado          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetu
		If ! Empty(aCols[n][nPosPro])
			If ! ExistCpo("QP6",aCols[n][nPosPro])
				lRetu := .f.
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Produto esta' relacionado a outro Grupo      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetu
		If !Empty(aCols[n][nPosPro])
			nReg := QPA->(Recno())
			QPA->(dbSetOrder(2))
			If QPA->(dbSeek(xFilial("QPA") + aCols[n][nPosPro]))
				If QPA->QPA_GRUPO <> M->QP3_GRUPO
					HELP(" ",1,"A040GRPEXI",,QPA->QPA_GRUPO,3,1)
					lRetu := .f.
				EndIf
			EndIf
			QPA->(dbSetOrder(1))
			QPA->(dbGoto(nReg))
		EndIf
	EndIf
EndIf
Return lRetu

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QP040TOk  ³ Autor ³ Cleber Souza          ³ Data ³ 06/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se toda a getdados esta' Ok                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP040TOk(o)
Local nI, lRetu := .t.  
Local nAchado,lOpera:=.F.
Local cSeek := ""

For nI := 1 to Len(aCols)
	If !aCols[nI][Len(aCols[nI])]	//Deletado
		If !QP040lOk(o)
			lRetu := .f.
			Exit
		EndIf
		If Altera
			If aScan( aColsAnt, {|x| x[1] == aCols[nI][1]} ) > 0
				Loop
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Recupera a revisao ativa do produto						   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aCols[ni][nPosPro])
			cSeek := aCols[ni][nPosPro] + QA_UltRevEsp(aCols[ni][nPosPro],,,.T.,"QIP")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Produto ja contem roteiro/operacoes/ensaios  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetu .And. !Empty(aCols[ni][nPosPro])
			nReg := QP7->(Recno())
			QP7->(dbSetOrder(1))
			If QP7->(dbSeek(xFilial("QP7") + cSeek))
				If !Empty(aCols[ni][nPosEns]) 
					MSGSTOP(OemToAnsi(STR0009)) //"O produto informado ja possui Roteiro de Operacoes/Ensaios cadastrados"
					lRetu := .f.
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Produto ja contem roteiro/operacoes/ensaios  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetu .And. !Empty(aCols[ni][nPosPro])
			nReg := QP8->(Recno())
			QP8->(dbSetOrder(1))
			If QP8->(dbSeek(xFilial("QP8") + cSeek))
				If ! Empty (QP8->QP8_ENSAIO)
					MSGSTOP(OemToAnsi(STR0009)) //"O produto informado ja possui Roteiro de Operacoes/Ensaios cadastrados"
					lRetu := .f.
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Produto ja contem roteiro/operacoes/ensaios  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetu .And. Altera
			If !Empty(aCols[ni][nPosPro])
				nReg := QQK->(Recno())
				QQK->(dbSetOrder(1))
				If QQK->(dbSeek(xFilial("QQK") + cSeek))
					If !Empty(QQK->QQK_PRODUT) .and. !Empty(QQK->QQK_REVIPR)
						MSGSTOP(OemToAnsi(STR0009)) //"O produto informado ja possui Roteiro de Operacoes/Ensaios cadastrados"
						lRetu := .f.
						lopera:=.f.
			   		EndIf
					If !Empty(QQK->QQK_PRODUT) .and. !Empty(QQK->QQK_REVIPR)
						lopera  := .t.
					EndIf
				EndIf
			EndIf
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existem ordens de producao para o produto	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aCols[ni][nPosPro])
			lRetu := QIPCheckEsp(aCols[ni][nPosPro],QA_UltRevEsp(aCols[ni][nPosPro],,,.T.,"QIP"),.F.)
			IF !lRetu
				Aviso(STR0010,STR0011+ALLTRIM(aCols[ni][nPosPro])+STR0012,{STR0013}) // "Ordem Produção "Produto: XXXX " nao podera ser excluido, localizado em Ordem(s) de produção "                                                                                                                                                                                                                                                                                                                                                                                                                                                     ,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
			EndIf
		EndIf
	Endif
Next

nAchado := Ascan(aCols,{|x| x[Len(aCols[n])] == .F.})
If nAchado == 0
	lRetu := .F.
	Help(" ",1,"SQP040VLD",,OemToAnsi(STR0007),1,0)
Endif

Return(lRetu)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A040DEqu ³ Autor ³ Cleber Souza          ³ Data ³ 06/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para preencher a descricao da Equipe Follow-up     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040DEqu(ExpC1,ExpL1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Equipe                                   ³±±
±±³          ³ ExpL1 = Indica se e' gatilho                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico-Cham. no X3_RELACAO,X3_INIBRW e gat. (QP3_EQUIPE) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040DEqu(cCodEq,lGatilho)
Local lnOpc := Iif(Type('Inclui') == 'U',.T.,Inclui)
lGatilho    := Iif(lGatilho == NIL,.t.,lGatilho)

IF !lnOpc .or. lGatilho	// Se Inic. Padrao ou gatilho a partir do cod. equipe
	QP4->(dbSeek(xFilial("QP4") + cCodEq))
	Return(QP4->QP4_DESCRI)
Else
	Return Space(Len(QP4->QP4_DESCRI))
Endif

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A040VlPr ³ Autor ³ Cleber Souza          ³ Data ³ 06/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Produto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA040 - E' chamada no X3_VALID do cpo. QPA_PRODUT - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040VlPr()

Local lRetu := .T.
Local nI	:= 0
Local nReg	:= 0	
Local cVar	:= &(readvar()) // Conteudo da variavel do campo NC 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se mudou o Produto (Alterou o campo ja' digitado)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[n,nPosPro]) .and. !Empty(cVar) .and. aCols[n,nPosPro] <> cVar
	Help(" ",1,"A010ALTCHA")	// Campo nao pode ser alterado	
	lRetu := .f.
EndIf

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Produto esta' cadastrado          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[n,nPosPro] := M->QPA_PRODUT
	If ! ExistCpo("QP6",aCols[n,nPosPro])
		lRetu := .f.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Produto esta' relacionado a outro Grupo      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetu
	nReg := QPA->(Recno())
	QPA->(dbSetOrder(2))
	If QPA->(dbSeek(xFilial("QPA") + aCols[n,nPosPro]))
		If QPA->QPA_GRUPO <> QP3->QP3_GRUPO
			HELP(" ",1,"a040GRPEXI",,QPA->QPA_GRUPO,3,1)
			lRetu := .f.
		EndIf
	EndIf
	QPA->(dbSetOrder(1))
	QPA->(dbGoto(nReg))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Produto ja' existe                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetu
	For nI := 1 to len(aCols)
		If cVar == acols[nI,nPosPro] .and. nI <> n
			Help(" ",1,"A040EXIPRD")
			acols[n,nPosPro]	:= CriaVar("QPA_PRODUT")
			M->QPA_PRODUT		:= acols[n,nPosPro]
		EndIf
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche a Descricao e Tipo do Produto          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetu
	aCols[n,nPosDPr] := QIPXDePr(aCols[n,nPosPro])
	aCols[n,nPosTipo]:= QIPXTipo(aCols[n,nPosPro])
EndIf

Return(lRetu)
