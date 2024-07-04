#INCLUDE "FISA030.ch"
#Include "SigaWin.ch"
#Include "Protheus.ch"
#Include "rwmake.ch"

/*/                                                                                                          
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                       
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                            
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISA030  ³ Autor ³ Wagner Montenegro   ³ Data ³ 05.03.2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Tabelas de Equivalencias                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Argentina                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³08/07/15³PCREQ-4256³Ajuste en los comentarios ya que oca- ³±±
±±³            ³        ³          ³sionaban problemas al momento de la   ³±±
±±³            ³        ³          ³compilacion                           ³±±
±±³M.Camargo   ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8		           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FISA030()
PRIVATE nRet,nG,nImp,cImp,aItemTab,aComb,cFiltro,cStart
PRIVATE oCbox,oDlg
WHILE .T.
   nRet:=0; nG:=0; nImp:=0; cImp:=""; cFiltro:=""; cStart:=1
   aItemTab:={} ;aComb:={}
   //Monta aItemTab com CODIGO+DESCRIÇÃO das Tabelas existentes
   //Monta aComb com DESCRIÇÃO das Tabels existentes //acomb é utilizado apenas para visualização de MSCOMBOBOX
   DbSelectarea("CCP")
   DbSetOrder(1)   
   CCP->(DBGOTOP())
   While !CCP->(EOF())    
      IF CCP->CCP_FILIAL=XFILIAL("CCP")
         IF ASCAN(aiTEMtAB,{|x| x[1]==CCP->CCP_COD})==0
            AADD(aItemTab,{CCP->CCP_COD,CCP->CCP_DESCR})
            AADD(aComb   ,CCP->CCP_DESCR)
         ENDIF
      ENDIF
      CCP->(DBSKIP())
   ENDDO  
   //Monta COMBOBOX 
   nRet:=0
   @000,000 TO 190,350 DIALOG oDlg TITLE STR0013
   @010,003 MSCOMBOBOX oCbox VAR cImp ITEMS aComb ON CHANGE (nImp:=oCbox:nAt) SIZE 120,50 OF oDlg PIXEL
   @070,003 BMPBUTTON TYPE 1 ACTION (If((nRet:=oCbox:nAt)<>0,FISA030V(),oDlg:End()),oDlg:End())
   @070,095 BMPBUTTON TYPE 2 ACTION (nRet:=0,oDlg:End())
   @070,047 BUTTON STR0014 SIZE 28,11 ACTION (FISA030I(),oDlg:End())
   ACTIVATE DIALOG oDlg CENTERED
   IF nRet=0
      EXIT
   ENDIF
ENDDO   
Return 

//FUNÇÃO: FISA030V
//AUTOR : WAGNER MONTENEGRO - 05/03/2010
//USO   : UTILIZADA PARA VISUALIZAÇÃO DA TABELA SELECIONADA ATRAVES DE MBROWSE
Function FISA030V()
SetPrvt("AFIXE,AROTINA,CCADASTRO,")
aFixe := { {STR0015    ,"CCP_COD"     },;  //Array de campos p/ visualização em MBROWSE
		   {STR0016 ,"CCP_DESCR"   },;  //Titulo no MBROWSE, Campo da TABELA
		   {STR0001,"CCP_VORIGE"  },;                    
		   {STR0002 ,"CCP_VDESTI"  },;                     
		   {STR0008 ,"CCP_ARQUIV"  },;                     
		   {STR0009 ,"CCP_CAMPO"}  }                      
aYesFields := {"CCP_FILIAL"+"CCP+COD"+"CCP_VORIGE","CCP_VDESTI","CCP_ARQUIV","CCP_CAMPO"}     //Campos usados para aHeader em MyFillGet
aRotina := {{ STR0010,"AxPesqui",0,1,0,.F.},;	// Buscar      //Array padrão para uso com MBROWSE
			{ STR0011,'FISA030A',0,4,0,NIL},;	// Modificar   //Caption Botao MBROWSE / Função
			{ STR0012,'FISA030E',0,5,0,NIL} }	// Excluir
cCadastro := STR0013

//FILTRO PARA USO EM MBROWSE
dbSelectArea("CCP")
dbSetOrder(1) 
cFiltro:=aItemTab[nRet,1]
dbSetFilter({|| CCP->CCP_FILIAL==xFilial('CCP') .and. CCP->CCP_COD==cFiltro},"CCP->CCP_FILIAL==xFilial('CCP') .and. CCP->CCP_COD==cFiltro")
dbGoTop()
mBrowse( 6, 1,22,75,"CCP",aFixe)
dbClearFilter()
Return
                                       

//FUNÇÃO: FISA030I
//AUTOR : WAGNER MONTENEGRO - 05/03/2010
//USO   : UTILIZADA PARA INCLUSÃO DE NOVA TABELA DE EQUIVALENCIA
FUNCTION FISA030I()
Local nY:=0
Local nX:=0
Local lAutomato := isBlind()
SetPrvt("NOPCX,AHEADER,ACOLS,CTABELA,cDESCR ")
SetPrvt("CMESATE,CPLANILLA,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,NMAXARRAY")
SetPrvt("NY,NCNTITEM,NX,CVAR,AROTINA,")
SetPrvt("AFIXE,AROTINA,CCADASTRO,")
aFixe := { {STR0001  ,"CCP_VORIGE"  },;  //Array com campos usados em MODELO2 //"VLR ORIGEM"
		   {STR0002   ,"CCP_VDESTI"  }}                   //"V.DESTINO"
aYesFields := {"CCP_VORIGE","CCP_VDESTI"}   //Campos usados para aHeader em MyFillGet
nOpcx:=3 //Inclusao
//dbSelectArea("CCP")
//dbSetOrder(1)
//Variaveis para uso no cabeçalho de MODELO2
cTabela   := Space(TamSX3("CCP_COD"   )[1])
cDESCR    := Space(TamSX3("CCP_DESCR" )[1])
cArquiv   := Space(TamSX3("CCP_ARQUIV")[1])
cxCampo   := Space(TamSX3("CCP_CAMPO" )[1])
cPlanilla := STR0003
nTotalItens := MyFillGet(nOpcx) //Rodape de MODELO2 / Montagem de aHeader e aCols
cTitulo:= STR0017
*///////////////////////////////////////////////////////////////*
// Array com descricao dos campos do Cabecalho do Modelo 2      
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"    ,{15,020} ,STR0004  ,"@!","sfCabTbEq(NOPCX)",,.T.})  // Nr. Tabla
AADD(aC,{"cDESCR"     ,{15,100} ,STR0005  ,"@!","sfCabTbEq(NOPCX)",,.T.})  // Fecha desde:
AADD(aC,{"cArquiv"    ,{30,020} ,STR0006  ,"@!","sfCabTbEq(NOPCX)",,.T.})  // Nr. Tabla
AADD(aC,{"cxCampo"    ,{30,100} ,STR0007  ,"@!","sfCabTbEq(NOPCX)",,.T.})  // Fecha desde:
aR:={}
AADD(aR,{"nTotalItens",{085,130},STR0027 ,"@E 999",,,.F.})  // Total de Items
aCGD:={75,5,80,400}
cLinhaOk:="fis030L()"// Validacoes na GetDados da Modelo 2 /Validação substituida por Validação de Sistema no SX3
cTudoOk :="fis030T()"//"AlwaysTrue()"
aGetEdit := {}

IF !lAutomato
	lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,CCP->(Reccount())+100)
	// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
	// objeto Getdados Corrente
Else
	If FindFunction("GetParAuto")
				aRetAuto 	:= GetParAuto("FISA030TESTCASE")
				aCols 		:= aRetAuto[1]
				CTABELA		:= aRetAuto[2]
				cDESCR		:= aRetAuto[3] 
	Endif
	lRetMod2 := .T.
Endif

If lRetMod2
	dbSelectArea("CCP")
	nMaxArray := Len(aCols)
	For ny := 1 to Len(aHeader)
		If Empty(aCols[nMaxArray][ny]) .AND. Trim(aHeader[ny][2]) == "CCP_COD"
			nMaxArray := nMaxArray - 1
			Exit
		EndIf
	Next ny
	nCntItem:= 1
	For nx := 1 to nMaxArray
		IF !aCols[nx][Len(aCols[nx])]
			// Atualiza dados da tabela.
			IF !Empty(aCols[nx,01])
   			   dbSelectArea("CCP")
			   RecLock("CCP",.T.)
			   Replace CCP_FILIAL  With xFilial("CCP"),;
			       	   CCP_COD     With cTabela,;
			       	   CCP_DESCR   With cDESCR ,;
			       	   CCP_ARQUIV  With cArquiv,;
			       	   CCP_CAMPO   With cxCampo
   			   For ny := 1 to Len(aHeader)
			       If aHeader[ny][10] # "V"
			          CCP->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
			       Endif
			   Next ny
		       dbUnLock()
		    ENDIF   
			nCntItem:=nCntItem + 1
		EndIF
	Next nx
Endif
//+-------------------------------------------------------+
//¦ Forçar o array aRotina para dribar a funcao ExecBrow. ¦
//+-------------------------------------------------------+
If !lAutomato 
	aRotina[3][4] := 0
Endif

Return(nRet:=3)

//FUNÇÃO: FISA030A
//AUTOR : WAGNER MONTENEGRO - 05/03/2010
//USO   : UTILIZADA PARA ALTERAÇÃO DA TABELA E INCLUSÃO DE NOVOS REGISTROS DE EQUIVALENCIA NA TABELA
FUNCTION FISA030A()
Local nX := 0
Local nY := 0
Local cSeek
Local lAutomato := isBlind()
SetPrvt("AFIXE,AROTINA,CCADASTRO")
SetPrvt("NOPCX,AHEADER,CTABELA,cDESCR,cArquiv,cxCampo,CMESATE")
SetPrvt("CPLANILLA,NCNT,ACOLS,NTOTALITENS,NTOTITENSFF")
SetPrvt("CTITULO,AC,AR,ACGD,CLINHAOK,CTUDOOK")
SetPrvt("AGETEDIT,LRETMOD2,NMAXARRAY,NY,NCNTITEM,NX")
SetPrvt("CVAR")
aFixe := { {STR0001   ,"CCP_VORIGE"  },;
		   {STR0002    ,"CCP_VDESTI"  }}                  
aYesFields := {"CCP_VORIGE","CCP_VDESTI"}     //campos
nOpcx:=4 //Alteração
If !lAutomato
	IF CCP->(dbSeek(xFilial("CCP")+aItemTab[nRet,1]))
	   cTabela   := CCP->CCP_COD
	   cDESCR    := CCP->CCP_DESCR
	   cArquiv   := CCP->CCP_ARQUIV
	   cxCampo   := CCP->CCP_CAMPO
	Endif
Else
	If FindFunction("GetParAuto")
				aRetAuto 	:= GetParAuto("FISA030TESTCASE")
				cTabela 	:= aRetAuto[1]
				cDesc		:= aRetAuto[2]
				nRet		:= aRetAuto[3] 
				aCols		:= aRetAuto[4] 
	Endif
	aItemTab := {} 
	AADD(aItemTab,{cTabela ,cDesc})
	IF CCP->(dbSeek(xFilial("CCP")+aItemTab[nRet,1]))
	   cTabela   := CCP->CCP_COD
	   cDESCR    := CCP->CCP_DESCR
	   cArquiv   := CCP->CCP_ARQUIV
	   cxCampo   := CCP->CCP_CAMPO
	Endif
Endif 

cPlanilla := aItemTab[nRet,2]
cSeek := xFilial("CCP")+aItemTab[nRet,1]
cWhile	:= "CCP_FILIAL+CCP_COD"
If !lAutomato
	FillGetDados(nOpcx,"CCP",1 , /*cSeekKey*/, /*bSeekWhile*/, /*bSeekFor*/,/*aNoFields*/, aYesFields, /*lOnlyYes*/, /*cQuery*/, {||FISA030aC(nOpcx,nRet)}/*bMontCols*/ )
Endif
nTotalItens := MyFillGet(nOpcx,1,cSeek)
nTotItensFF := nTotalItens
cTitulo:= STR0003 //"TABELA DE EQUIVALENCIAS"
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,020} ,STR0004   ,"@!","sfCabTbEq(NOPCX)",,.F.})  // Nr. Tabla //"Tabela: "
AADD(aC,{"cDESCR"   ,{15,100} ,STR0005,"@!","sfCabTbEq(NOPCX)",,.T.})  // Fecha desde: //"Descricao: "
AADD(aC,{"cArquiv"  ,{30,020} ,STR0006  ,"@!","sfCabTbEq(NOPCX)",,.F.})  // Nr. Tabla //"Arquivo: "
AADD(aC,{"cxCampo"  ,{30,100} ,STR0007    ,"@!","sfCabTbEq(NOPCX)",,.F.})  // Fecha desde: //"Campo: "
aR:={}
AADD(aR,{"nTotalItens"  ,{085,130},OemToAnsi(STR0027),"@E 999",,,.F.})  // Total de Items
aCGD:={75,5,080,400}
cLinhaOk:="fis030L()"// Validacoes na GetDados da Modelo 2 /Validação substituida por Validação de Sistema no SX3
cTudoOk :="fis030T()"//"AlwaysTrue()"
aGetEdit := {}
If !lAutomato
	lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,CCP->(Reccount())+100)
Else
	lRetMod2 := .T.
Endif
If lRetMod2
   nCntItem:= 1
   For nx := 1 to Len(aCols)
	   IF !aCols[nx][Len(aCols[nx])]
          If nX > nTotItensFF
		     RecLock("CCP",.T.)
		   Else
		     CCP->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "CCP_REC_WT" })]))
		     RecLock("CCP",.F.)
		  Endif
		  IF !Empty(aCols[nx,01])
  		     Replace CCP_FILIAL  With xFilial("CCP"),;
			         CCP_COD     With aItemTab[nRet,1],; 
  		       	     CCP_DESCR   With cDESCR ,;			      
				     CCP_ARQUIV  With cArquiv,;
				     CCP_CAMPO   With cxCampo
		     For ny := 1 to Len(aHeader)
			     If aHeader[ny][10] # "V"
			        CCP->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
			     Endif
		     Next ny
		  ENDIF   
		  MsUnLock()
		  nCntItem:=nCntItem + 1
		Else
		  If nX <=	nTotItensFF
			 CCP->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "CCP_REC_WT" })]))
			 RecLock("CCP",.F.)
			 CCP->(DbDelete())
			 MsUnLock()
		  Endif
	   Endif
   Next nX
Endif
Return()

//FUNÇÃO: FISA030E
//AUTOR : WAGNER MONTENEGRO - 05/03/2010
//USO   : UTILIZADA PARA EXCLUSÃO DE TABELA DE EQUIVALENCIA
FUNCTION FISA030E()
Local nX := 0
Local nY := 0
Local cSeek
Local lAutomato := isBlind()
SetPrvt("AFIXE,AROTINA,CCADASTRO,")
aFixe := { {STR0001   ,"CCP_VORIGE"  },;
		   {STR0002    ,"CCP_VDESTI"  }}                  
aYesFields := {"CCP_VORIGE","CCP_VDESTI"} //campos
SetPrvt("NOPCX,AHEADER,CTABELA,cDESCR ,CMESATE")
SetPrvt("CPLANILLA,NCNT,ACOLS,NTOTALITENS,NTOTITENSFF")
SetPrvt("CTITULO,AC,AR,ACGD,CLINHAOK,CTUDOOK")
SetPrvt("AGETEDIT,LRETMOD2,NMAXARRAY,NY,NCNTITEM,NX")
SetPrvt("CVAR,")
nOpcx:=5 //Exclusao
If !lAutomato
	IF CCP->(dbSeek(xFilial("CCP")+aItemTab[nRet,1]))
		cTabela   := CCP->CCP_COD
		cDESCR    := CCP->CCP_DESCR
		cArquiv   := CCP->CCP_ARQUIV
		cxCampo   := CCP->CCP_CAMPO
	Endif
Else
	If FindFunction("GetParAuto")
				aRetAuto 	:= GetParAuto("FISA030TESTCASE")
				cTabela 	:= aRetAuto[1]
				cDesc		:= aRetAuto[2]
				nRet		:= aRetAuto[3] 
	Endif
	aItemTab := {} 
	AADD(aItemTab,{cTabela ,cDesc})
	IF CCP->(dbSeek(xFilial("CCP")+aItemTab[nRet,1]))
		cTabela   := CCP->CCP_COD
		cDESCR    := CCP->CCP_DESCR
		cArquiv   := CCP->CCP_ARQUIV
		cxCampo   := CCP->CCP_CAMPO
	Endif  
Endif  

cPlanilla := aItemTab[nRet,2]
cSeek := xFilial("CCP")+aItemTab[nRet,1]
cWhile	:= "CCP_FILIAL+CCP_COD"
FillGetDados(nOpcx,"CCP", 1, /*cSeekKey*/, /*bSeekWhile*/, /*bSeekFor*/,/*aNoFields*/, aYesFields, /*lOnlyYes*/, /*cQuery*/, {||FISA030aC(nOpcx,nRet)}/*bMontCols*/ )
nTotalItens := MyFillGet(nOpcx,1,cSeek)
nTotItensFF := nTotalItens
cTitulo:= STR0003  //"TABELA DE EQUIVALENCIAS"
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,020} ,STR0004   ,"@!",".T."         ,,.F.})  // Nr. Tabla //"Tabela: "
AADD(aC,{"cDescr"   ,{15,100} ,STR0005,"@!",".T."         ,,.F.})  // Fecha desde: //"Descricao: "
AADD(aC,{"cArquiv"  ,{30,020} ,STR0006  ,"@!",".T."         ,,.F.})  // Nr. Tabla //"Arquivo: "
AADD(aC,{"cxCampo"  ,{30,100} ,STR0007    ,"@!",".T."         ,,.F.})  // Fecha desde: //"Campo: "
aR:={}
AADD(aR,{"nTotalItens"  ,{085,130},OemToAnsi("Total de Itens"),"@E 999",,,.F.})  // Total de Items
aCGD:={75,5,080,400}
cLinhaOk:="fis030L()"// Validacoes na GetDados da Modelo 2 /Validação substituida por Validação de Sistema no SX3
cTudoOk :="fis030T()"//"AlwaysTrue()"
aGetEdit := {}

If !lAutomato
	lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,".T.",,,,CCP->(Reccount())+100)
Else
	lRetMod2 := .T.
EndIf
// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
If lRetMod2
   dbSelectArea("CCP")
   dbSetOrder(1)
   dbSeek(xFilial("CCP")+aItemTab[nRet,1])
   If Found()
	  While !EOF() .And. CCP_FILIAL+CCP_COD == xFilial("CCP")+aItemTab[nRet,1]
         RecLock("CCP",.F.)
		 dbDelete()
		 dbUnLock()
		 dbSkip()
      End
   EndIf
EndIf
Return

//FUNÇÃO: MyFillGet    ³ Autor ³ Liber De Esteban      ³ Data ³29/01/2007
//ALTERADO POR: WAGNER MONTENEGRO - 05/03/2010
//USO   : UTILIZADA PARA MONTAGEM DE AHEADER E ACOLS               
//Retorno:  nCnt -> Numero de itens no aCols                         
//Parametros: nOpc -> Codigo da opcao (Incusao, Alteracao, ... )        
//          : nOrd -> Ordem para posicionamento na tabela SFF           
//          : cSeek -> Chave para posicionamento na tabela SFF          
//          : cWhile -> Expressão para comparacao no while do SFF       
Static Function MyFillGet(nOpc,nOrd,cSeek,cWhile)
Local nY   := 0
Local nI   := 0
Local nCnt := 0
Local lInclui := (nOpc == 3)
Local lAltera := (nOpc == 4)
DEFAULT nOrd   := 1
DEFAULT cSeek  := ""
DEFAULT cWhile := "CCP_FILIAL+CCP_COD"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aHeader                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader:={}
dbSelectArea("SX3")
dbSetOrder(2) // Seleciono campo a campo para manter sequencia no aHeader
For nI := 1 to len(aYesFields)
//	If  aYesFields[nI] == "CCP_COD" .And. (lInclui .or. lAltera)
//		Loop
//	ElseIf dbSeek(aYesFields[nI])
	If dbSeek(aYesFields[nI])
	   Aadd(aHeader,{TRIM(X3TITULO()),X3_CAMPO, X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	EndIf
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos de Alias e Recno ao aHeader para WalkThru.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ADHeadRec("CCP",aHeader)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aCols                             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lInclui
   aCols	:= Array(1,Len(aHeader)+1)
   For nY := 1 to Len(aHeader)
	   If IsHeadRec(aHeader[nY][2])
	  	  aCols[1][nY] := 0
		ElseIf IsHeadAlias(aHeader[nY][2])
		  aCols[1][nY] := "CCP"
		Else
		  aCols[1][nY] := CriaVar(aHeader[nY][2])
   	   EndIf
   Next nY
   aCols[1][Len(aHeader)+1] := .F.
 Else
   dbSelectArea("CCP")
   dbSetOrder(nOrd)
   dbSeek(cSeek)
   While !EOF() .And. &(cWhile) == cSeek
	  nCnt:=nCnt+1
	  dbSkip()
   End
   If nCnt == 0
      Help(" ",1,"NOITENS")
      Return nCnt
   EndIf
   //aCols	:= Array(nCnt,Len(aHeader)+1)
   nCnt	:= 0
   dbSeek(cSeek)
   While !EOF() .And. &(cWhile) == cSeek
      nCnt:=nCnt+1
	  For nY := 1 to Len(aHeader)
		  If IsHeadRec(aHeader[nY][2])
		   	 aCols[nCnt][nY] := CCP->(Recno())
		   ElseIf IsHeadAlias(aHeader[nY][2])
			 aCols[nCnt][nY] := "CCP"
		  EndIf
	  Next nY
  	  aCols[nCnt][Len(aHeader)+1] := .F.
	  dbSelectArea("CCP")
	  dbSkip()
   End
EndIf
Return (nCnt)
                    
//FUNÇÃO: sfCabTbEq
//AUTOR : WAGNER MONTENEGRO - 05/03/2010
//USO   : UTILIZADA PARA VALIDACAO DOS CAMPOS DE CABEÇALHO         
Function sfCabTbEq(nOpc)
SetPrvt("_LRET,")
_lRet := .T.
If Empty(cTabela) .or. READVAR()="CDESCR" .and. Empty(cDescr)  .OR. Len(acols)==0
     MsgAlert("Hay campos obligatorios que estan en blanco", "Campos")
   _lRet := .F.
 Else
   IF nOpc==3
  	  CCP->(dbSetOrder(1))
	  CCP->(dbSeek(xFilial("CCP")+cTabela))
	  If CCP->( Found() )
	     MsgAlert(STR0018, "")
	     _lRet := .F.
	   ELSE
	     IF !EMPTY(cArquiv)
	        SX3->(DBSETORDER(1))
	        IF !SX3->(dbSeek(cArquiv))
               _lRet := .F.
               MsgAlert(STR0019, "")
              ELSE  
               IF !EMPTY(cxCampo)
                  SX3->(DBSETORDER(2))
                  IF !SX3->(dbSeek(cxCampo))              
                     _lRet := .F.
                     MsgAlert(STR0020+cArquiv+"'!", "")
                  ENDIF   
                  SX3->(DBSETORDER(1))
                 ELSE
                  IF READVAR()="CXCAMPO"
                     _lRet := .F.
                     MsgAlert(STR0021, "")
                  ENDIF   
               ENDIF
            ENDIF   
         ENDIF    
	  EndIf
    ELSE  
      IF !EMPTY(cArquiv)
         SX3->(DBSETORDER(1))
	     IF !SX3->(dbSeek(cArquiv))
            _lRet := .F.
            MsgAlert(STR0019, "")
          ELSE  
            IF !EMPTY(cxCampo)
               SX3->(DBSETORDER(2))
               IF !SX3->(dbSeek(cxCampo))              
                  _lRet := .F.
                  MsgAlert(STR0020+cArquiv+"'!", "")
               ENDIF   
               SX3->(DBSETORDER(1))
            ENDIF
         ENDIF   
      ENDIF        
   ENDIF	
EndIf
Return( _lRet )

//FUNÇÃO: FISA030AC
//AUTOR : WAGNER MONTENEGRO - 05/03/2010
//USO   : UTILIZADA PARA CARREGAR ACOLS E GETDADOS PARA USO EM FILLGETDADOS
Function FISA030aC(nOpc,nRet)
Local aSaveArea := GetArea()
Local nCont		:= 0
Local nPos_ALI_WT, nPos_REC_WT, nX
nPos_ALI_WT := AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "CCP_ALI_WT"})
nPos_REC_WT := AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "CCP_REC_WT"})
nUsado := Len(aHeader)
If nOpc == 3   //incluir
   Aadd(aCols,Array(nUsado+1))
   aCols[1][1]	:= "001"
   For nX := 2 TO nUsado //comeca da 2a.coluna em diante
	   If aHeader[nX, 10] != "V"
	  	  If aHeader[nX, 8] == "C"
			 aCols[1, nX] := space( aHeader[nX, 4] ) // tamanho do campo 
			ElseIf 	aHeader[nX, 8] == "N"
			 aCols[1, nX] := 0
			ElseIf 	aHeader[nX, 8] == "D"
			 aCols[1, nX] := dDataBase
			ElseIf aHeader[nX, 8] == "M"
			 aCols[1, nX] := ""
			Else
			 aCols[1, nX] := .F.
		  EndIf
		ElseIf aHeader[nX, 10] == "V" .And. ! ( aHeader[nX, 2]$"CCP_ALI_WT|CTS_REC_WT" )
		  aCols[1, nX] := CriaVar(AllTrim(aHeader[nX, 2]))
	   EndIf
   Next
   aCols[1][nPos_ALI_WT] := "CCP"
   aCols[1][nPos_REC_WT] := 0
   aCOLS[1][nUsado+1] := .F.
Else				// Alteracao / Exclusao / Visualizacao
   dbSelectArea("CCP")
   dbSetOrder(1)
   IF CCP->(dbSeek(xFilial("CCP")+aItemTab[nRet,1]))
      cTabela   := CCP->CCP_COD
      cDESCR    := CCP->CCP_DESCR
      cArquiv   := CCP->CCP_ARQUIV
      cxCampo    := CCP->CCP_CAMPO
   Endif   	
   While !EOF() .And. CCP->CCP_FILIAL == xFilial("CCP") .And. CCP->CCP_COD == cTABELA
      nCont++
	  Aadd(aCols,Array(nUsado+1))
	  For nX := 1 TO nUsado
		  If aHeader[nX, 10] != "V"
		     aCOLS[nCont, nX] := &("CCP->"+aHeader[nX, 2])
			ElseIf aHeader[nX, 10] == "V" .And. ! ( aHeader[nX, 2]$"CCP_ALI_WT|CCP_REC_WT" )
			 aCols[nCont, nX] := CriaVar(AllTrim(aHeader[nX, 2]))
		  EndIf
      Next
	  aCols[nCont][nPos_ALI_WT] := "CCP"
	  aCols[nCont][nPos_REC_WT] := CCP->(Recno())
	  aCols[nCont][nUsado+1]:= .F.
	  dbSelectArea("CCP")
	  dbSkip()
   EndDo
EndIf
RestArea(aSaveArea)
Return

//FUNÇÃO: VldTbEq  
//AUTOR : WAGNER MONTENEGRO - 05/03/2010
//USO   : UTILIZADA PARA VALIDACAO DE DADOS DO CAMPO CCP_VORIGE / USO EM VALIDACAO DE SISTEMA NO SX3
Function VldTbEq(cStart)
Local i,lEmpty:= .F.,nPosHeader := 0,lret := .t.
Local nPosIdent
Local cColQry:="",cQuery:="",cColAlias:=""
Local cAliasA := GetNextAlias()
Local aValCol:={}
Local cAreaA:=GetArea() 
DEFAULT cStart:=1
nPosIdent  := Ascan(aHeader,{|x| "CCP_VORIGE" $ x[2]})
If aCols[n][Len(aCols[n])]   && caso tenha sido deletado
	Return .T.
Endif
IF !EMPTY(cArquiv)
   cColQry:=cArquiv+"."+cxCampo
   IF cStart=1 .and. !Empty(aCols[n,nPosIdent]) .or. cStart=2 .and. !Empty(&(READVAR()))
      cQuery:="SELECT DISTINCT "+cColQry+" FROM "+RETSQLNAME(cArquiv)+" "+cArquiv
      cQuery := ChangeQuery(cQuery)
      If Select( cAliasA ) > 0
         dbSelectArea( cAliasA )
         dbCloseArea()
      EndIf
      //// *** Abre Tabelas *** //
      dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasA , .F., .T.)
      dbSelectArea(cAliasA) 
      cColAlias:=cAliasA+"->"+cxCampo
      While !( cAliasA )->(Eof())
         AADD(aValCol,&cColAlias)
         ( cAliasA )->(DbSkip())
      Enddo
      ( cAliasA )->(dbCloseArea())
      IF cStart=1
         IF(ASCAN(aValCol,{|x| ALLTRIM(x)==ALLTRIM(aCols[n,nPosIdent]) })==0,lRet := .F.,lRet := .T.)
        ELSE
         IF(ASCAN(aValCol,{|x| ALLTRIM(x)==ALLTRIM(&(READVAR())) })==0,lRet := .F.,lRet := .T.)
      ENDIF   
      IF !lRet
         If MsgYesNo(STR0022+IF(cStart=1,ALLTRIM(aCols[n,nPosIdent]),ALLTRIM(&(READVAR())))+STR0023+cArquiv+STR0024)
            lRet:=.T.
         Endif   
      ENDIF   
   ENDIF   
ENDIF      
IF cStart=1
   IF Empty(aCols[n,nPosIdent])
      MsgAlert(STR0025, "")
      lRet:=.F.
    Else
      IF ASCAN(aCols,{|x| ALLTRIM(X[1])=ALLTRIM(aCols[n,nPosIdent])})<>0
         MsgAlert(STR0026, "")
         lRet:=.F.   
      ENDIF
   ENDIF
  ELSE
   IF Empty(ALLTRIM(&(READVAR())))
      MsgAlert(STR0025, "")
      lRet:=.F.
    ELSE
      npos:=ASCAN(aCols,{|x| ALLTRIM(x[1])=ALLTRIM(&(READVAR()))})
      IF npos <>0 .and. npos <> n .And.     !aCols[npos,len(aCols[npos])]
         MsgAlert(STR0026, "")
         lRet:=.F.   
      ENDIF   
   ENDIF   
ENDIF      
RestArea(cAreaA)
return lRet                                                                                               


Function fis030T()
Local lret:=.T.
Local nMaxArray := Len(aCols)
Local nX:= 1

For nx := 1 to nMaxArray
	IF Empty(aCols[nx,01]) .And. lRet .And. !aCols[n,len(aCols[n])]
     	MsgAlert("Hay campos obligatorios que estan en blanco", "Campos")
  		lret:=.F.
 		nx :=  nMaxArray
	EndiF
Next
Return (lRet)

Function fis030L()
Local lret:=.T.
IF ( Empty(aCols[n,01]) .or. Empty(aCols[n,02])) .And. !aCols[n,len(aCols[n])]
	lRet:=.F.                                                            
	MsgAlert("Hay campos obligatorios que estan en blanco", "Campos")
EndIf
nTotalItens:= Len(Acols)
Return (lRet)
