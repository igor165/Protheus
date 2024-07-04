#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TRMA190.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TRMA190  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 03.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realizar Avaliacoes                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TRMA190()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nChamada:        1-Funcionarios 2-Outros                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TRMA190                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³21.07.14³TPZSOX³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±³Oswaldo L.  ³03/04/17³DRHPONTP-9  ³Projeto cTree                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TRMA190(nChamada)	 

Local cFiltra		:= CHKRH(FunName(),"RAJ","1")	//Variavel para filtro quando Avaliacao de Eficacia
Local cFiltraRAJ	:= ""							//Variavel para filtro
Local cTop			:= ""
Local cBot      	:= ""
Local cAuxFil		:= ""	
Local aCores    	:= {}
Local nErro			:= 0
Local cAuxFiltra 	:= ""
Local aAuxCores 	:= {}

Private aFldRot 	:= {'RA_NOME'}
Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Private lOfuscaNom 	:= .F. //RA_NOME
Private aFldOfusca 	:= {}
If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
EndIf

Private aIndexRAJ	:= {}							//Variavel Para Filtro
Private bFiltraBrw 	:= {|| Nil}						//Variavel para Filtro
Private cCadastro	:= OemtoAnsi(STR0001)			//"Avaliacoes"
Private nOpMenu		:= nChamada
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
Private aRotina 	:= { 	{ STR0002,"PesqBrw"		,0,1},; //"Pesquisar" c/ Filtro
							{ STR0003,"Tr190Aciona"	,0,4},; //"Acionar"  
						   	{ STR0013,"Tr190Leg"	,0,2}}	 //"Legenda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Consiste o Modo de Acesso dos Arquivos                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
nErro := 0
nErro += Iif(xRetModo("SRA","RAI",.T.),0,1)
nErro += Iif(xRetModo("SRA","RAJ",.T.),0,1)
If nErro > 0
	Return
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array de Cores da Mbrowse											   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpMenu == 1
		aCores  := {	{ "RAJ->RAJ_DATA <= dDataBase .And. RAJ->RAJ_DATAF >= dDataBase .And. RAJ->RAJ_OK != 'S'",'BR_VERDE' },;
						{ "RAJ->RAJ_DATA <= dDataBase .And. RAJ->RAJ_DATAF >= dDataBase .And. RAJ->RAJ_OK == 'S'",'DISABLE' },;
						{ "dDataBase > RAJ->RAJ_DATAF .or. dDataBase < RAJ->RAJ_DATA" ,'BR_AMARELO' }}
Else 
		aCores  := {	{ "RAJ->RAJ_DATA >= dDataBase .And. RAJ->RAJ_DATAF <= dDataBase .And. RAJ->RAJ_OK != 'S'",'BR_VERDE' },;
						{ "RAJ->RAJ_OK == 'S' ",'DISABLE' },;
						{ "RAJ->RAJ_DATA != dDataBase .And. RAJ->RAJ_OK != 'S'" ,'BR_AMARELO' }}
EndIf					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definiao de cores por usuarios, veja tb na funcao Tr190Leg()           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("TRM190LEG")
	aAuxCores  := ExecBlock("TRM190LEG",.F.,.F.,{"C",nOpMenu,aCores} )
	If ValType(aAuxCores) == "A"
		aCores := aClone(aAuxCores)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RAJ")
dbSetOrder(1)

If nOpMenu == 1		// Realizada por Funcionarios
		cTop 		:= Tr190Top()
		cBot 		:= Tr190Top()
	
		cFiltraRAJ 	:= "(!Empty(RAJ->RAJ_TESTE).OR.!Empty(RAJ->RAJ_MODELO))"+;
						" .And. Dtos(RAJ->RAJ_DATA) <= " +"'"+cTop+"'"+;
						" .And. Dtos(RAJ->RAJ_DATAF) >= " +"'"+cBot+"'"+;
						" .And. RAJ->RAJ_QUEM != '2'"

Else				// Realizada por Outros
	cFiltraRAJ	:=	"RAJ->RAJ_QUEM == '2'"
EndIf	
If !Empty(cFiltra)
	cFiltraRAJ 	:= 	"RAJ->RAJ_QUEM == '2' .And. " + cFiltra	//Considera filtro criado pelo Usuario	
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para gerar filtro por funcao do usuário               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("TRM190FIL")
	cAuxFiltra  := ExecBlock("TRM190FIL",.F.,.F.,{cFiltraRAJ} )
	If !Empty(cAuxFiltra)
		cFiltraRAJ 	+= ".And. " + cAuxFiltra	
	EndIf	
Endif
bFiltraBrw 	:= {|| FilBrowse("RAJ",@aIndexRAJ,@cFiltraRAJ) }
Eval(bFiltraBrw)

dbGoTop()
mbrowse( 6, 1,22,75,'RAJ',,,,,,aCores)
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RAJ",aIndexRAJ)
Return 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 		  Filtra data atual 		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Tr190Top()         
Return DtoS(dDataBase)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra datas posteriores a data atual ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Tr190Bot()
Local cRet		:= ""
Local cData 	:= 	Dtos(dDataBase)
Local aSaveArea	:= GetArea()

dbSelectArea("RAJ")   
dbSetOrder(2)
dbGoBottom()

If Dtos(RAJ->RAJ_DATA) > cData
	cData := DtoS(RAJ->RAJ_DATA)
EndIf

cRet := cData

RestArea(aSaveArea)

Return  cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr190Aciona³ Autor ³ Emerson Grassi Rocha ³ Data ³ 03/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Aciona a Avaliacao que sera executada.    				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr190Aciona(ExpC1,ExpN1,ExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TRMA190		                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tr190Aciona(cAlias,nReg,nOpcx)

Local oDlg, oLbx, oFont, oBtn1, oBtn2, oGroup, oGroup1
Local aMSG		:= Array(4)
Local dData 	:= dDataBase
Local cNome		:= ""
Local cVar		:= ""
Local cMsg		:= GetMV("MV_RSPMSG")
Local aRet		:= {}
Local nSavRec	:= 0
Local nOrder 	:= IndexOrd()
Local nx		:= 0
Local nTipo		:= 0

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {} 

Local aAdv11Size	:= {}
Local aInfo11AdvSize:= {}
Local aObj11Size	:= {}
Local aObj11Coords	:= {}
                             
Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}
Local aLista        := {}
Local aLstIndices   := {}
Private oBrw13, oOK, oNOK, oRadio , oScroll
Private nListBox:= 0 
Private nSeq	:= 0 
Private nSeqAnt := 1
Private aAltern := {}
Private aListBox:= {}
Private aFinal  := {}
Private aRad	:= {}
Private cMemo	:= "" 		
Private cCalend	:= RAJ->RAJ_CALEND
Private cCurso	:= RAJ->RAJ_CURSO
Private cTurma	:= RAJ->RAJ_TURMA
Private cMat	:= RAJ->RAJ_MAT
Private cMatAva	:= RAJ->RAJ_MATAVA
Private aCampos	:= {}
Private oTmpTRC 
Private oTmpTRB 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Private aTreeCoords	:= {}
Private aEnchCoords	:= {}
Private aGetDCoords	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RAJ",aIndexRAJ)
aIndexRAJ := {}
dbGoto(nReg)

oOk := LoadBitmap( GetResources(), "LBOK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

aFill(aMSG,Space(90))

If RAJ->RAJ_OK == "S"
	Help("",1,"Tr190OK")	// Este Funcionario ja executou este teste verifique outro teste a ser executado
	           
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Eval(bFiltraBrw)
	dbGoto(nReg)
    
	dbSelectArea("RAJ")
	dbSetOrder(nOrder)
	Return .F.
EndIf
                                                    
If nOpMenu == 1		// Realizada por Funcionarios
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Entrada de campos para confirmacao de Funcionario. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Trm190Cpo(nOpcx)
	        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Eval(bFiltraBrw)
		dbGoto(nReg)
    	
		dbSelectArea("RAJ")
		dbSetOrder(nOrder)
		Return .F.
	EndIf
EndIf

nSavRec:= RecNo()

// Monta o arquivo de trabalho para Testes Aleatorios
aCampos:={}
Aadd(aCampos,{"TRC_FILIAL",  "C", FWGETTAMFILIAL, 0 } )	// Codigo da Filial
AADD(aCampos,{"TRC_TESTE"	,"C",  4, 0 } )	// Codigo do Teste
AADD(aCampos,{"TRC_ITEM"	,"C",  2, 0 } )	// Sequencia das questoes
AADD(aCampos,{"TRC_QUESTA"	,"C",  3, 0 } )	// Codigo da Questao
AADD(aCampos,{"TRC_TOPICO"	,"C",  3, 0 } )	// Codigo do Topico  
AADD(aCampos,{"TRC_DESCRI"	,"C", 30, 0 } )	// Descricao do Teste
AADD(aCampos,{"TRC_AREA"	,"C",  3, 0 } )	// Codigo da Area
AADD(aCampos,{"TRC_DURACA"	,"C",  8, 0 } )	// Duracao do Teste
AADD(aCampos,{"TRC_TIPO"	,"C",  8, 0 } )	// Tipo de Avaliacao



aLista := {"TRC_FILIAL","TRC_TESTE"}
AAdd( aLstIndices, aLista)

oTmpTRC := RhCriaTrab("TRC", aCampos, aLstIndices)

// Busca o nome do Funcionario
dbSelectArea("SRA")          
dbSetOrder(1)
If dbSeek(xFilial("SRA")+RAJ->RAJ_MAT)
	cNome:= SRA->RA_NOME
	cNome := If(lOfuscaNom,Replicate('*',15),cNome)
EndIf

// Monta o listbox com as Avaliacoes agendadas
dbSelectArea("RAJ")
dbSetOrder(1)
dbSeek(xFilial("RAJ")+cCalend+cCurso+cTurma+cMat)
While !Eof() .And. xFilial("RAJ")+cCalend+cCurso+cTurma+cMat ==;
					 RAJ->RAJ_FILIAL+RAJ->RAJ_CALEND+RAJ->RAJ_CURSO+RAJ->RAJ_TURMA+RAJ->RAJ_MAT
							 
	If RAJ->RAJ_OK == "S" .or. (Empty(RAJ->RAJ_TESTE).And.Empty(RAJ->RAJ_MODELO))  
    	dbSkip()
    	Loop
 	EndIf
 	
 	If !Empty(RAJ->RAJ_DATAF)
		If nOpMenu == 1 .And. (DtoS(dData) < DtoS(RAJ->RAJ_DATA) .Or.  DtoS(dData) > DtoS(RAJ->RAJ_DATAF))	//Funcionarios
			dbSkip()
			Loop
		EndIf								 
 	Else
		If nOpMenu == 1 .And. DtoS(RAJ->RAJ_DATA) # DtoS(dData)	//Funcionarios
			dbSkip()
			Loop
		EndIf								 
	EndIf  
	   
	// Verifica Quem esta realizando Avaliacao (Funcionario/Outro)
	If 	(nOpMenu == 2 .And. RAJ->RAJ_QUEM != "2") .Or.;
		(nOpMenu == 1 .And. RAJ->RAJ_QUEM == "2")
		
		dbSkip()
		Loop
	EndIf
	
	If !Empty(RAJ->RAJ_TESTE)
		nTipo := 1
		aRet:= RspxList(RAJ->RAJ_TESTE, nTipo)
	Else		  
		nTipo := 2
		aRet:= RspxList(RAJ->RAJ_MODELO, nTipo)
	EndIf
	
	//1- Descricao   2- Qtde Questoes 3-Duracao 4- Cod.Avaliacao 5-Tipo(Avaliacao/Modelo)
	Aadd(aListbox,{aRet[1],aRet[2],aRet[3],If(Empty(RAJ->RAJ_TESTE), RAJ->RAJ_MODELO, RAJ->RAJ_TESTE ),nTipo})
	//1- Descricao   2- Qtde Questoes 3-Duracao 4- Tempo que levou 5- Qtde resolvida
	Aadd(aFinal,{aRet[1],aRet[2],aRet[3],"",""})
	dbSkip()
EndDo	

If Len(aListBox) <= 0
	dbGoto( nSavRec )
	Help("",1,"Tr190VAZIO")	// Nao existe nenhum Funcionario cadastrado no dia de hoje
	    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Eval(bFiltraBrw)
	dbGoto(nReg)	
	
	dbSelectArea("TRC")
	dbCloseArea()
   
	If oTmpTRC <> Nil
		oTmpTRC:Delete()
		Freeobj(oTmpTRC)
	EndIf  
	
	dbSelectArea("RAJ")
	dbSetOrder(nOrder)
	
	Return .F.	
EndIf

If Val(aRet[2]) < 1  
	Help("",1,"Tr190QUEST") //Nao existe nenhuma questao cadastrada para o Teste
        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Eval(bFiltraBrw)
	dbGoto(nReg)
    
	dbSelectArea("TRC")
	dbCloseArea()

	If oTmpTRC <> Nil
		oTmpTRC:Delete()
		Freeobj(oTmpTRC)
	EndIf  
	
	dbSelectArea("RAJ")
	dbSetOrder(nOrder)
	
	Return .F.	
EndIf

// Monta o array com a mensagem a ser mostrada para o candidato
For nx:=1 To MLCount(cMsg,90)
	If nx > 4
		Exit
	EndIf	
	aMsg[nx]:=MemoLine(cMSG,90,nx,,.T.)
Next nx

// Monta o arquivo de trabalho para executar a Avaliacao
aCampos := {}
AADD(aCampos,{"TRB_TESTE"	,"C",004,0})	// Codigo da Avaliacao
AADD(aCampos,{"TRB_SEQ"		,"C",002,0})	// Sequencia das questoes
AADD(aCampos,{"TRB_QUESTA"	,"C",003,0})	// Codigo da Questao
AADD(aCampos,{"TRB_TOPICO"	,"C",003,0})	// Codigo do Topico  
AADD(aCampos,{"TRB_DQUEST"	,"M",010,0})	// Descricao da Questao
AADD(aCampos,{"TRB_ALTERN"	,"C",002,0})	// Codigo da Alternativa
AADD(aCampos,{"TRB_DALTER"	,"C",250,0})	// Descricao da Alternativa
AADD(aCampos,{"TRB_PERCEN"	,"N",006,2})	// Percentual de correcao
AADD(aCampos,{"TRB_RESPOS"	,"N",001,0})	// Resposta 1= se nao marcou 2= se marcou 3= se for memo
AADD(aCampos,{"TRB_MEMO"	,"M",010,0})	// Resposta dissertativa
AADD(aCampos,{"TRB_TIPOBJ"	,"C",001,0})	// Tipo de Objeto das Respostas
AADD(aCampos,{"TRB_QTRESP"	,"N",002,0})	// Qtde. Maxima de Respostas
AADD(aCampos,{"TRB_TIPO"	,"C",003,0})	// Tipo de Avaliacao

RspCriaTRB()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize(,.T.,380)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )				//1-Candidato - ListBox
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )				//2-Recado
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords ) 

//Divisao em Linhas 1-Candidato - ListBox 
aAdv1Size		:= aClone(aObjSize[1])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }					 
aAdd( aObj1Coords , { 000 , 018 , .T. , .F. } )				//1-Candidato 
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. , .T. } )			//2-ListBox
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords ) 


//Divisao em Colunas 1-Candidato 
aAdv11Size		:= aClone(aObj1Size[1])
aInfo11AdvSize	:= { aAdv11Size[2] , aAdv11Size[1] , aAdv11Size[4] , aAdv11Size[3] , 1 , 5 }					 
aAdd( aObj11Coords , { 050 , 000 , .F. , .T. } )				//1-Say 
aAdd( aObj11Coords , { 000 , 000 , .T. , .T. } )				//2-Get
aObj11Size		:= MsObjSize( aInfo11AdvSize , aObj11Coords,,.T. )


//Divisao em Linhas 2-Recado
aAdv2Size		:= aClone(aObjSize[2])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 8 , 5 }					 
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )				//1-Espaco
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )				//2-aMSG[1]
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )				//3-aMSG[2]
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )				//4-aMSG[3]
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )				//5-aMSG[4]
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )				//6-Espaco
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords ) 


DEFINE FONT oFont 	NAME "Arial Negrito" SIZE 0,-11
DEFINE MSDIALOG oDlg From aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] TITLE OemtoAnsi(STR0005) PIXEL//"Efetuar Avaliacao" OF oMainWnd 

	@ aObjSize[1,1], aObjSize[1,2] GROUP oGroup TO aObjSize[1,3], aObjSize[1,4] LABEL "" OF oDlg PIXEL 
	oGroup:oFont:= oFont		
	@ aObj11Size[1,1], aObj11Size[1,2] SAY OemToAnsi(STR0006) 	SIZE 50 ,10 OF oDlg PIXEL    //"Candidato:"
	@ aObj11Size[2,1], aObj11Size[2,2] SAY cMat+" - "+cNome 	SIZE 200,10 OF oDlg PIXEL 
	
   	@ aObj1Size[2,1], aObj1Size[2,2] LISTBOX oLbx VAR cVar ;
							FIELDS HEADERS 	OemtoAnsi(STR0007),;                         //"Avaliacao"
											OemtoAnsi(STR0008),;                         //"Qtde Questoes"
											OemtoAnsi(STR0009) SIZE aObj1Size[2,3], aObj1Size[2,4] OF oDlg PIXEL //"Duracao"
   	oLbx:SetArray(aListBox)
   	oLbx:bLine := { || {aListBox[oLbx:nAt,1],aListBox[oLbx:nAt,2],aListBox[oLbx:nAt,3]}}
	
	@ aObjSize[2,1], aObjSize[2,2] GROUP oGroup1 TO aObjSize[2,3], aObjSize[2,4] LABEL OemtoAnsi(STR0010) OF oDlg PIXEL //" Recados "
	
	@ aObj2Size[2,1], aObj2Size[2,2] SAY OemtoAnsi(Alltrim(aMSG[1]))	SIZE 280,7 OF oDlg PIXEL
	@ aObj2Size[3,1], aObj2Size[3,2] SAY OemtoAnsi(Alltrim(aMSG[2]))	SIZE 280,7 OF oDlg PIXEL
	@ aObj2Size[4,1], aObj2Size[4,2] SAY OemtoAnsi(Alltrim(aMSG[3]))	SIZE 280,7 OF oDlg PIXEL
	@ aObj2Size[5,1], aObj2Size[5,2] SAY OemtoAnsi(Alltrim(aMSG[4]))	SIZE 280,7 OF oDlg PIXEL

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta os Botoes para a EnchoiceBar             			  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
bSet15		:= { ||RspxCapa(),oDlg:End() }
bSet24		:= { ||oDlg:End() }

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , Nil , Nil ) CENTERED                                                                  

RspDelTRB()

dbSelectArea("TRC")
dbCloseArea()

If oTmpTRC <> Nil
	oTmpTRC:Delete()
	Freeobj(oTmpTRC)
EndIf  

DeleteObject(oOk)
DeleteObject(oNo)
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bFiltraBrw)
dbGoto(nReg)

dbSelectArea("RAJ")
dbGoTo(nSavRec)
dbSetOrder(nOrder)
 
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr190Leg      ³ Autor ³Emerson Grassi    ³ Data ³ 21.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aciona Legenda de cores da Mbrowse.				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr190Leg()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trma190                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr190Leg()

If ExistBlock("TRM190LEG")
	ExecBlock("TRM190LEG",.F.,.F.,{"L",nOpMenu} )
Else
	If nOpMenu == 1
		TrmLegenda(3)
	Else 
		TrmLegenda(4)
	EndIf	
EndIf

Return(Nil)
                                      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr190IniBrw   ³ Autor ³Emerson Grassi    ³ Data ³ 08/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra descricao da Avaliacao ou Modelo no Browse.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr190IniBrw()	                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trma190                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr190IniBrw()
Local cRet := " "

If !Empty(RAJ->RAJ_TESTE)
	cRet := Iif(SQQ->(dbSeek(xFilial("SQQ")+RAJ->RAJ_TESTE)),SQQ->QQ_DESCRIC ,"")
ElseIf !Empty(RAJ->RAJ_MODELO)
	cRet := Iif(SQW->(dbSeek(xFilial("SQW")+RAJ->RAJ_MODELO)),SQW->QW_DESCRIC ,"")
EndIf

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr190Cpo      ³ Autor ³Emerson Grassi    ³ Data ³ 28/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela com campos para confirmacao de Funcionario.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr190Cpo()	                                         	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trma190                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Trm190Cpo(nOpcx)

Local aSaveArea := GetArea()
Local cCpos		:= GetMv("MV_TRMCPOS")
Local aCpos		:= &("{"+CCPOS+"}")
Local lRet 		:= .T.
Local oDlg1
Local i			:= 0
Local aInfo		:= {}
Local nx		:= 0
Local n1		:= 0
Local n2		:= 0
Local nOpca		:= 0

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}
            
// Variaveis para salvar campos do arquivo em memoria
Local bCampo 	:= {|nCPO| Field(nCPO) }
Local cCampo	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva integridade dos campos do arquivo em variaveis de memoria ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SRA")
For i := 1 TO FCount()
	cCampo := EVAL(bCampo,i)
	M->&(cCampo) := FieldGet(i)
	If ValType(M->&(cCampo)) = "C"
		M->&(cCampo) := SPACE(LEN(M->&(cCampo)))
	ElseIf ValType(M->&(cCampo)) = "N"
		M->&(cCampo) := 0
	ElseIf ValType(M->&(cCampo)) = "D"
		M->&(cCampo) := CtoD("  /  /  ")
	ElseIf ValType(M->&(cCampo)) = "L"
		M->&(cCampo) := .F.
	EndIf
Next i

//------------------------
//	aInfo	[1] = Campo
//			[2] = Titulo
//	        [3] = Valid
//	        [4] = Picture
//			[5] = Objeto Get
//			[6] = Objeto Say
//------------------------
aInfo := {}
	        
dbSelectArea("SX3") 
dbSetOrder(2)

For nx := 1 To Len(aCpos)
	If dbSeek(aCpos[nx]) 
		Aadd( aInfo, {"M->"+(aCpos[nx]), AllTrim(X3Titulo()), X3_VALID, X3_PICTURE, Nil, Nil} ) 
	EndIf
Next nx

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF Len(aInfo) <= 13 	
	aAdvSize		:= MsAdvSize(,.T.,380)    	//tela pequena para limite de 13 campos disponibilizados
Else
	aAdvSize		:= MsAdvSize() 				//tela 100% para apresentacao de 14 ou mais campos
EndIf

aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )			//1-Group
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords)

//1-Divisao em Linhas da Tela
aAdv1Size		:= aClone(aObjSize[1])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }					 
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )		//1.a linha para centralizar as linhas a seguir

For nx := 1 To Len(aInfo)
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )	//Inclusao de 1 linha para cada campo
Next nx

aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )		//Ultima linha para centralizar as linhas anteriores	
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords ) 

//2- Divisao em Colunas da primeira Linha
aAdv2Size		:= aClone(aObj1Size[1])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 5 }
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )			//1-Espaco	
aAdd( aObj2Coords , { 050 , 000 , .F. , .T. } )			//2-Say	
aAdd( aObj2Coords , { 010 , 000 , .F. , .T. } )			//3-Espaco
aAdd( aObj2Coords , { 100 , 000 , .F. , .T. } )			//4-Get	
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )			//5-Espacao
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. ) 

SETAPILHA()
DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(STR0016) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL OF oMainWnd  //"Confirmacao	

	@ aObjSize[1,1],aObjSize[1,2] GROUP TO aObjSize[1,3], aObjSize[1,4] PROMPT '' OF oDlg1   PIXEL

	For nx := 1 To Len(aInfo)
    
		n1 	:= (nx + 1)
		@ aObj1Size[n1,1],aObj2Size[2,2] SAY aInfo[nx][6] Prompt Space(40) PIXEL OF oScroll
		aInfo[nx, 6]:bSetGet := &("{|u| If(pCount() == 0, aInfo["+Str(nx)+",2], aInfo["+Str(nx)+",2]:=u)}")
    	aInfo[nx, 6]:SetText(aInfo[nx,2])

	   	aInfo[nx][5] := TGet():New( aObj1Size[n1,1],aObj2Size[4,2], ,;
 					     oDlg1, 100, 7, aInfo[nx,4], , , , , , ,.T.)
 					     
		//Nao pode usar Valid dos Campos
        aInfo[nx][5]:bSetGet := &("{|u| If(pCount() == 0, &(aInfo["+AllTrim(Str(nx))+",1]), &(aInfo["+AllTrim(Str(nx))+",1]):=u)}")

	Next nx

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| nOpca := 1, oDlg1:End()},{|| nOpca := 2,oDlg1:End()}) CENTERED
SETAPILHA()
 
If nOpca == 1

	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek(xFilial("SRA")+cMat)

	For i := 1 To Len(aCpos)  
		If !Empty(aCpos[i]) .And. FieldPos(aCpos[i]) > 0
			If SRA->&(aCpos[i]) != M->&(aCpos[i])
				Aviso(OemToAnsi(STR0014), OemToAnsi(STR0015), {"OK"}) //"Atencao"#"Dados do Funcionario nao conferem!"
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next i

Else

	lRet := .F.
		
EndIf

RestArea(aSaveArea)

Return lRet     