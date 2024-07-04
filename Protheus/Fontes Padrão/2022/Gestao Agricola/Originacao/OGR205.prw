#include 'PROTHEUS.CH'
#include 'PARMTYPE.CH'
#include "FWBROWSE.CH" 
#INCLUDE "DBINFO.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE 'OGR205.CH'

/*
+=================================================================================================+
| Programa  : OGR205                                                                            |
| Descrição : Impressão da reserva  (modelo word)                                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 23/05/2016                                                                          |
+=================================================================================================+     
|Parâmentro : Código da reserva                                                        Obrigatório|
+=================================================================================================+
*/
Function OGR205( cCodRes )
	Private aMatC		 := {		{"NJR_UMPRC"		,STR0001	," "," "},{"NJB_QTDPUM"		,STR0006	," "," "},{"NJB_QTDPRC"		,STR0010	," "," "},;
								  	{"NJB_PRCEXTENSO"	,STR0002	," "," "},{"NJJ_LOCAL"		,STR0007	," "," "},{"NJ0_NOMLOJ"		,STR0011	," "," "},;
							  		{"A2_MUN"			,STR0003	," "," "},{"A2_EST"			,STR0005	," "," "},{"NJ0_CGC"		,"CNPJ/CPF"	," "," "},;
									{"NJ0_INSCR"		,STR0004	," "," "},{"NJR_VLRUNI"		,STR0008	," "," "},{"M0_CIDENT"		,STR0012	," "," "},;
									{"M0_ESTENT"		,STR0005	," "," "},{"DATAAT"		 	,STR0009	," "," "}}
	Private cReserva 	:= cCodRes
	
	If Empty(NJB->NJB_WRRANT)
		Help(,,"HELP",,STR0013 +" Warrant",1,0)  //"Reserva não possui"
		Return .f.
	EndIf
	
	Pergunte('OGR205',.F.)
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	
	// Chamda da impressões do arquivo Word
	AGRWORDDOC("NJB",MV_PAR01,aMatC,"OGR205IWPROC()",'OGR205')
Return 

/*
+=================================================================================================+
| Programa  : OGR200IWPROC                                                                        |
| Descrição : Processamento (atribuição de valores)                                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 23/05/2016                                                                          |
+=================================================================================================+ 
| Retorno   : aMatDad - Matriz com campos e dados                                                 |
+=================================================================================================+   
*/
Function OGR205IWPROC() 
	Local nx,nPos
	Local cPitpro   := AGRSEEKDIC("SX3","NJB_QTDPRO",2,"X3_PICTURE")
	Local cPitpru   := AGRSEEKDIC("SX3","NJR_VLRUNI",2,"X3_PICTURE")
	Local lOGA200P3 := ExistBlock('OGA200P3')
	
	// Posicionamento nos registros
	Posicione("NJB",1,xFilial("NJB")+cReserva,"NJB_FILIAL")
	Posicione("NJR",1,xFilial("NJR")+NJB->NJB_CODCTR,"NJR_FILIAL")
	Posicione("NJJ",1,xFilial("NJJ")+NJB->NJB_CODROM,"NJJ_FILIAL")
	Posicione("SA1",1,xFilial("SA1")+NJB->NJB_CODTER+NJB->NJB_LOJTER,"A1_FILIAL")
	Posicione("SA2",1,xFilial("SA2")+NJB->NJB_CODTER+NJB->NJB_LOJTER,"A2_FILIAL")
	Posicione("SB1",1,xFilial("SB1")+NJB->NJB_CODPRO,"B1_FILIAL")
	Posicione("NJ0",1,xFilial("NJ0")+NJB->NJB_CODENT+NJB->NJB_LOJENT,"NJ0_FILIAL")
	Posicione("NNR",1,xFilial("NNR")+NJJ->NJJ_LOCAL,"NNR_FILIAL")
	
	For nx := 1 To Len(aDadC)
		nPos := Ascan(aMatC,{|x| Alltrim(x[1]) = Alltrim(aDadC[nx,1])})
		cVal := ''
		If nPos > 0 // Campos específicos 
			If  Alltrim(aDadC[nx,1]) = "NJR_UMPRC"
	        cVal := NJR->NJR_UMPRC
	     ElseIf  Alltrim(aDadC[nx,1]) = "NJB_QTDPUM" // Qtidade da reserva por extenso na UM; 
	    		cVal := AGRQTDEXTEN(NJB->NJB_QTDPRO)+ " "+NJB->NJB_UM1PRO
	    	ElseIf  Alltrim(aDadC[nx,1]) = "NJB_QTDPRC" // -Qtidade da reserva na UmPRC
	     		cVal := Alltrim(Transform(AGRX001(NJB->NJB_UM1PRO,NJR->NJR_UMPRC,NJB->NJB_QTDPRO, NJR->NJR_CODPRO),cPitpro))+" "+NJR->NJR_UMPRC
	     ElseIf  Alltrim(aDadC[nx,1]) = "NJB_PRCEXTENSO" //-Qtidade da reserva Por extenso na UmPRC 
	     		nCon := AGRX001(NJB->NJB_UM1PRO,NJR->NJR_UMPRC,NJB->NJB_QTDPRO, NJR->NJR_CODPRO)
	     		cVal := AGRQTDEXTEN(nCon)+" "+NJR->NJR_UMPRC
	     ElseIf  Alltrim(aDadC[nx,1]) = "NJJ_LOCAL"
	     		cVal := NNR->NNR_DESCRI
	     ElseIf  Alltrim(aDadC[nx,1]) = "NJ0_NOMLOJ"
	     		cVal := NJ0->NJ0_NOMLOJ
	     ElseIf  Alltrim(aDadC[nx,1]) = "A2_MUN"
	        cVal := SA2->A2_MUN
	     ElseIf  Alltrim(aDadC[nx,1]) = "A2_EST"
	     		cVal := SA2->A2_EST
	     ElseIf  Alltrim(aDadC[nx,1]) = "NJ0_CGC"
	     		cVal := NJ0->NJ0_CGC
	     ElseIf  Alltrim(aDadC[nx,1]) = "NJ0_INSCR"
	     		cVal := NJ0->NJ0_INSCR
	     	ElseIf  Alltrim(aDadC[nx,1]) = "NJR_VLRUNI"
	     		cVal := Alltrim(Transform(NJB->NJB_VLRBAS/NJB->NJB_QTDPRO,cPitpru))
	     	ElseIf  Alltrim(aDadC[nx,1]) = "M0_CIDENT"
	     		cVal := Alltrim(SM0->M0_CIDENT)
	     	ElseIf  Alltrim(aDadC[nx,1]) = "M0_ESTENT"
	     		cVal := SM0->M0_ESTENT
	     	ElseIf  Alltrim(aDadC[nx,1]) = "DATAAT"
	     		cDat := Dtos(dDataBase)
	     		cVal := SubStr(cDat,7,2)+" de "+MesExtenso(Val(SubStr(cDat,5,2)))+" de "+SubStr(cDat,1,4) 
	     	  	// Ponto de entrada para atribuir valor a campo especícifico do warrant referente ao ponto OGA200P2	
	     	ElseIf lOGA200P3
				cVal := ExecBlock('OGA200P3',.F.,.F.,{nx})
	     EndIf 
	     	Aadd(aMatDad,{aDadC[nx,1],cVal,"@!",aDadC[nx,2]})
	  	EndIf
	Next nx	
Return 

/*
+=================================================================================================+
| Função    : AGRWORDDOC                                                                          |
| Descrição : Consulta e/ou impressão de um arquivo Word (dot..)                                  |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 24/05/2016                                                                          |
+=================================================================================================+
| Parâmetros: cAliaP - Alias da tabela principal (ponteiro deve estar no registro)     Obrigatório|                                                                           |
|             cNomDc - Nome do arquivo Com a extensão                                  Obrigatorio|  
|             aMatCD - Matriz com os campos específicos                                Não Obrigat|
|             cFuncP - Nome da função que vai atribuir os campos e dados               Não Obrigat|
|             cPergu - Nome das perguntas                                              Não Obrigat|
+=================================================================================================+
|Referências : OGA200                                                                             |
+=================================================================================================+ 
*/
Static Function AGRWORDDOC(cAliaP,cNomDc,aMatCD,cFuncP,cPergu)
	Local cPathEst1 	:= Alltrim(GetMv("MV_DIREST"))     // Path do arquivo a ser armazanado na estação de trabalho
	Local cBarraRem 	:= If(GetRemoteType() == 2,"/","\")// Estação com sistema operacional unix = 2
	Local aAdvSize		:=  MsAdvSize(),nx,nPos,lInclui,aAreaAtu := GetArea() 
	Local aInfoAdvSize	:= {aAdvSize[1],aAdvSize[2],aAdvSize[3],aAdvSize[4],0,0}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aGDCoord		:= {}
	Local aDadP			:= {} 
	Local vVetCamp   	:= {} 
	Private cPathEst  	:= cPathEst1+If(Substr(cPathEst1,len(cPathEst1),1) != cBarraRem,cBarraRem,"")
	Private cArqDot		:= cNomDc,oDlg
	Private aDadC		:= If(aMatCD <> Nil .And. !Empty(aMatCD),Aclone(aMatCD),{})
	Private aMatDad		:= {}
	Private aInfo		:= {}
	
	OpenProfile()
	
	If type("inclui") <> "U"
		lInclui := inclui
	EndIf	
	inclui := .t.
	
	// Define os campos do registro principal
	vVetCamp := FWSX3Util():GetAllFields( 'NJB' , .T. )

	For nx := 1 To Len(vVetCamp)
		Aadd(aDadP,{vVetCamp[nx],Alltrim(X3Descric(vVetCamp[nx])),AGRRETCTXT('NJB', vVetCamp[nx]),X3CBOX(vVetCamp[nx])})
		Aadd(aDadC,{vVetCamp[nx],Alltrim(X3Descric(vVetCamp[nx])),AGRRETCTXT('NJB', vVetCamp[nx]),X3CBOX(vVetCamp[nx])})
	Next nx
	
	// Carrega os dados do registro principal
	For nx := 1 To Len(aDadC)
		nPos := Ascan(aDadP,{|x| Alltrim(x[1]) = Alltrim(aDadC[nx,1])})
		cVal := ''
		If nPos > 0 
			If !Empty(aDadC[nx,3])  // Virtual
				cRelac := AGRSEEKDIC("SX3",Alltrim(aDadC[nx,1])+Space(10-Len(Alltrim(aDadC[nx,1]))),2,"X3_RELACAO")
				cVal := &(cRelac)
				Aadd(aMatDad,{aDadC[nx,1],cVal,"@!",aDadC[nx,2]})
			ElseIf !Empty(aDadC[nx,4])  // Box
				cVal := AGRRETSX3BOX(Alltrim(aDadC[nx,1])+Space(10-Len(Alltrim(aDadC[nx,1]))),&(cAliaP+"->"+aDadC[nx,1]))
				Aadd(aMatDad,{aDadC[nx,1],cVal,"@!",aDadC[nx,2]})	
			Else
				Aadd(aMatDad,{aDadC[nx,1],&(cAliaP+"->"+aDadC[nx,1]),x3Picture(aDadC[nx,1]),aDadC[nx,2]})
			EndIf
		EndIf	
	Next nx	
	
	//	Monta as Dimensoes dos Objetos  
	aAdvSize[5]  := (aAdvSize[5]/100) * 60	//horizontal
	aAdvSize[6]	:= (aAdvSize[6]/100) * 40	//Vertical	
	aAdd(aObjCoords,{000,000,.T.,.T.})
	aObjSize := MsObjSize(aInfoAdvSize,aObjCoords)
	aGdCoord := {(aObjSize[1,1]+3),(aObjSize[1,2]+5),(((aObjSize[1,3])/100)*20),(((aObjSize[1,4])/100)*59)}	//1,3 Vertical /1,4 Horizontal
	
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0029 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL		//"Integração Com Ms-word"
		
		@ aGdCoord[1],aGdCoord[2] TO aGdCoord[3],aGdCoord[4]   PIXEL
		@ aGdCoord[1]+10,aGdCoord[2]+10 SAY OemToAnsi( STR0030 ) PIXEL	//"Impressão de documentos no Word."
		@ aGdCoord[1]+20,aGdCoord[2]+10 SAY OemToAnsi( STR0031) PIXEL	//"Serão impressos de acordo com a Seleção Dos Parâmetros."
		
		If cPergu <> Nil
			@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-95 BMPBUTTON TYPE 5 ACTION Eval( { || Pergunte(cPergu,.T.)})
		EndIf
		 
		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-60 BUTTON OemToAnsi( STR0032 ) SIZE 55,11 ACTION Eval({|| ARGVARWIMP(aDadC)})//"Impr. _Variáveis"
		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+5  BUTTON OemToAnsi( STR0033 ) SIZE 55,11 ACTION Eval({|| AGRWORDIMP(cFuncP)})//"Impr. _Documento"
		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+70 BMPBUTTON TYPE 2 ACTION Close(oDlg)
		
	ACTIVATE DIALOG oDlg CENTERED
	
	If !Empty(lInclui)
		inclui := lInclui
	EndIf

	RestArea( aAreaAtu )
Return
/*
+=================================================================================================+
| Função    : ARGVARWIMP                                                                          |
| Descrição : Chamada da impressão das variáveis usadas o arquivo Word                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 24/05/2016                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: aVarDes - Matriz com as variáveis e descrição                            Obrigatório|
+=================================================================================================+
|Referências : AGRWORDDOC                                                                         |
+=================================================================================================+ 
*/
Static Function ARGVARWIMP(aVarDes)
	Local cString	    := 'SB1'
	Local aOrd		    := {STR0034 , STR0035 } // "Variável","Descrição Da Variável"
	Private NomeProg	:= FunName()
	Private AT_PRG		:= NomeProg
	Private aReturn		:= { STR0036 ,1, STR0037,2,2,1,'',1} //"Código de barras" # "Administração"
	Private cDesc1		:= STR0038 		//"Relatório Das Variáveis do arqduivo Word"
	Private cDesc2		:= STR0039      //"Será impresso de acordo com os parâmetros solicitados pelo"               
	Private cDesc3		:= STR0040 		// "Utilizador."  	
	Private wCabec0		:= 1
	Private wCabec1		:= STR0041		//"Variáveis                      Descrição"
	Private wCabec2		:= ""
	Private wCabec3		:= ""
	Private nTamanho	:= "P"
	Private lEnd		:= .F.
	Private Titulo		:= cDesc1
	Private Li			:= 0
	Private ContFl		:= 1
	Private cBtxt		:= ""
	Private aLinha		:= {}
	Private nLastKey	:= 0
	
	// Envia controle para a funcao SETPRINT
	WnRel := "WORD_VAR"
	WnRel := SetPrint(cString,Wnrel,"",Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho,,.F.)
	
	If nLastKey == 27
		Return 
	EndIF
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	EndIF
	
	// Chamada do Relatorio
	RptStatus({|lEnd|AGRIMPVAR(aVarDes)},Titulo)
Return

/*
+=================================================================================================+
| Função    : ARGVARWIMP                                                                          |
| Descrição : Impressão das variáveis e desrição usadas o arquivo Word                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 24/05/2016                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: aVarDes - Matriz com as variáveis e descrição                            Obrigatório|
+=================================================================================================+
|Referências : ARGVARWIMP                                                                         |
+=================================================================================================+ 
*/
Static Function AGRIMPVAR(aVarDes)
	Local nOrdem	 := aReturn[8]
	Local nx		 := 0
	Local cDescr	 := ""
	
	// Ordena aCampos de Acordo com a Ordem Selecionada        
	nCol := If(nOrdem = 1,1,2)
	aSort(aVarDes,,,{|x,y|x[nCol] < y[nCol]})
		
	// Carrega Regua de Processamento        
	SetRegua(Len(aVarDes))
	
	// Impressao do Relatorio        
	For nX := 1 To Len(aVarDes)
		IncRegua()
	  	If lEnd
			@ Prow()+1,0 PSAY cCancel
			Exit
		EndIF
		
		cDescr := AllTrim(aVarDes[nX,2])
	   //Imprimindo Relatorio
		Impr(Padr(aVarDes[nX,1],31)+Left(cDescr,50))
		
		If Len(cDescr) > 50
			Impr(Space(31)+SubStr(cDescr,51,50))
		Endif
		If Len(cDescr) > 100
			Impr(Space(31)+SubStr(cDescr,101,50))
		Endif
	Next nX
	
	If aReturn[5] == 1
		Set Printer To
		dbCommit()
		OurSpool(WnRel)
	EndIF
	MS_FLUSH()
Return 

/*
+=================================================================================================+
| Função    : AGRWORDIMP                                                                          |
| Descrição : Impressão do arquivo em Word                                                        |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 24/05/2016                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cFuncP - Nome da função que vai atribuir os campos e dados              Já atribuído|
+=================================================================================================+
|Referências : AGRWORDDOC                                                                         |
+=================================================================================================+ 
*/
Static Function AGRWORDIMP(cFuncPr)
	Local oWord	 		:= NIL
	Local cArqOrigem 	:= ""
	Local x
	Local cDrive
	Local cPasta
	Local cFile
	Local cExtensao
	
	/*PARAMETROS*/
	Local cArqWord 		:= mv_par01		//local do arquivo
	Local cDestino 		:= mv_par02		//local destino do arquivo
		
	// Checa o só do Remote (1=Windows, 2=Linux)
	If GetRemoteType() == 2
		MsgAlert(OemToAnsi( STR0018 ),OemToAnsi( STR0019 ))	//"A integração word funciona somente com windows!!!"#"Atenção !"	
		Return
	EndIf
	
	SplitPath(cArqword, @cDrive, @cPasta, @cFile, @cExtensao )
	
	If Empty( cArqWord ) .or. ! Upper(alltrim(cExtensao)) $ ".DOT|.DOTX"   
		Help( , , STR0020, , STR0021, 1, 0 )		//"AJUDA"#"Arquivo modelo invalido, favor informal o caminho e o nome do arquivo modelo com sua extensão"
	    Return
	EndIF
	
	cArqOrigem := cFile   //Guarda o nome do Arq. de Origem
		
	SplitPath(cDestino, @cDrive, @cPasta, @cFile, @cExtensao )
	
	If Empty( cdrive ) .or. Empty(cPasta)   
		Help( , , STR0020 , , STR0022 , 1, 0 )		//"AJUDA"#"Favor informar a Pasta destino, para salvar o arquivo"
	    Return
	EndIF
		
	// *CONECTA COM WORD
	oWord	 := OLE_CreateLink()
	OLE_NewFile(oWord,cArqWord)

	// Exibe ou oculta a janela da aplicacao Word no momento em que estiver descarregando os valores.
	OLE_SetProperty( oWord, oleWdVisible, .F. )	
	
	// Exibe ou oculta a aplicacao Word.
	//OLE_SetProperty( oWord, oleWdWindowState, '1' )
	
	CursorWait() // Muda o Cursor
	
	If Type("oWord") <> "0" 
		If cFuncPr <> Nil
			&cFuncPr // Carrega os campos e dados especifico
		EndIf	
	   //[x,1] - Campo ,[x,2] - Valor, [x,3] - Pciture, [x,4] - Nome/descrição
		Aeval(aMatDad,{|x| OLE_SetDocumentVar(oWord,x[1],If(ValType(x[2]) = "N",Alltrim(Transform(x[2],Alltrim(x[3]))),;
																				  If(ValType(x[2]) = "D",Dtoc(x[2]),x[2])))})
		// Atualiza as Variaveis
		OLE_UpDateFields(oWord) 
		
	    SplitPath(cDestino, @cDrive, @cPasta, @cFile, @cExtensao )
	    
	    IF Empty(cFile)
	       cFile := cArqOrigem
	    EndIF
	    
	    cExtensao := ".PDF"	
		cDestino := upper(Alltrim(cDrive)+Alltrim(cPasta)+alltrim(cFile))
		
		// Ativa ou desativa impressao em segundo plano. 
		OLE_SetProperty( oWord, oleWdPrintBack, .F. )		
		//-- SALVA O ARQUIVO EM PDF
		OLE_SaveAsFile( oWord, cDestino+".PDF", , , .f., 17 )            		
		// Fecha Documento Criado no Word 
		OLE_CLOSEFILE(oWord)		
		// Encerra link de comunicacao com o word
		OLE_CLOSELINK(oWord)		
		//gera PDF para arquivamento
		ShellExecute("open",cDestino+".PDF","","",5) // Windows - 5=SW_SHOW        
		EndMsOle()	
	
	Else
		Help(,, STR0020 ,,STR0023 ,1,0)  //"AJUDA"#"Não foi possivel imprimir o arquivo!"
	EndIf 
	oDlg:End()
	
	CursorArrow() //Retorna o cursor Normal
Return