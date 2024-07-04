#INCLUDE "pcoa191.ch"
#Include "Protheus.ch"
/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA191  ³ AUTOR ³ Edson Maricate        ³ DATA ³ 26.11.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de Cadastro das configurações dos Cubos Estrateficos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA191                                                      ³±±
±±³_DESCRI_  ³ Programa de Cadastro de Configuracções de Cubos Estratégicos ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal    ³±±
±±³          ³ partir do Menu ou a partir de uma funcao pulando assim o     ³±±
±±³          ³ browse principal e executando a chamada direta da rotina     ³±±
±±³          ³ selecionada.                                                 ³±±
±±³          ³ Exemplo: PCOA191(2) - Executa a chamada da funcao de visua-  ³±±
±±³          ³                       zacao da rotina.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : Chamada direta sem passar pela mBrowse               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA191(nCallOpcx)

Local bBlock
Local nPos
Private cCadastro	:= STR0001 //"Configuração de Cubos"
Private M->AKR_ORCAME := ""  //NAO EXCLUIR USADO EM CONSULTA PADRAO
Private aRotina := MenuDef()

	If nCallOpcx <> Nil
		nPos := Ascan(aRotina,{|x| x[4]== nCallOpcx})
		If ( nPos # 0 )
			bBlock := &( "{ |x,y,z,k| " + aRotina[ nPos,2 ] + "(x,y,z,k) }" )
			Eval( bBlock,Alias(),AL4->(Recno()),nPos)
		EndIf
	Else
		mBrowse(6,1,22,75,"AL3")
	EndIf

Return


Function Pcoa191Brw(cAlias,nReg,nOpcx)
Local aSize		:= MsAdvSize(,.F.,430)
Local cConfig		:= AL3->AL3_CODIGO
Local l191Visual := .F.
Local l191Inclui := .F.
Local l191Deleta := .F.
Local l191Altera := .F.
Local aIndexAL4	:= {}
Local cFiltraAL4	:= "AL4_FILIAL=='"+xFilial("AL4")+"' .And. AL4_CODIGO=='"+AL3->AL3_CODIGO+"'"
				
SaveInter()

PRIVATE bFiltraBrw	:= {|| Nil}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
Case aRotina[nOpcX][4] == 2
	l191Visual := .T.
Case aRotina[nOpcX][4] == 3 
	l191Inclui	:= .T.
Case aRotina[nOpcX][4] == 4
	l191Altera	:= .T.
	FKCOMMIT()
Case aRotina[nOpcX][4] == 5
	l191Deleta	:= .T.
	l191Visual	:= .T.
EndCase

If l191Deleta 
	If AxDeleta(cAlias,nReg,nOpcx) == 2
		dbSelectArea("AL4")
		dbSetOrder(1)
		dbSeek(xFilial()+cConfig)
		While !Eof() .And. xFilial('AL4')+cConfig == AL4_FILIAL+AL4_CODIGO
			RecLock("AL4",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
		End
	EndIf
ElseIf l191Inclui
	AxInclui(cAlias,nReg,nOpcx,,,,,,"Pcoa191Brw('AL4',"+STr(AL1->(RecNo()))+",4)") 
EndIf
	
If l191Altera
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Redefine o aRotina                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRotina 	:= {	{ STR0008, 	"Pcoa191Vis" , 0 , 2},;     //"&Visualizar"
						{ STR0009, 		"Pcoa191Inc" , 0 , 3},;	   //"&Incluir"
						{ STR0010, 		"Pcoa191Alt" , 0 , 4},;  //"&Alterar"
						{ STR0011, 		"AxDeleta" , 0 , 5}}  //"&Excluir"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a Filtragem                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bFiltraBrw := {|| FilBrowse("AL4",@aIndexAL4,@cFiltraAL4) }
	Eval(bFiltraBrw)
	dbGoTop()
	
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro,"AL4",,aRotina,,,,.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndFilBrw("AL4",aIndexAL4)		
EndIf

RestInter()

Return


Function Pcoa191Inc(cAlias,nOpcx,nRecno)
Local aButtons := { {"FILTRO",{||Pcoa191Fil() },STR0012,STR0013},; //"Configurar Filtro"###"Filtro"
							 {"PESQUISA",{||Pcoa191Pesq() },STR0014,STR0015} } //"Consulta Padrao"###"Pesquisa"
Inclui := .T.
Altera := .F.
Return axInclui(cAlias,nOpcx,nRecno,,,,,,,aButtons) 

Function Pcoa191Alt(cAlias,nOpcx,nRecno)
Local aButtons := { {"FILTRO",{||Pcoa191Fil() },STR0012,STR0013},; //"Configurar Filtro"###"Filtro"
							 {"PESQUISA",{||Pcoa191Pesq() },STR0014,STR0015} } //"Consulta Padrao"###"Pesquisa"
Inclui := .F.
Altera := .T.
Return axAltera(cAlias,nOpcx,nRecno,,,,,,,,aButtons) 

Function Pcoa191Vis(cAlias,nOpcx,nRecno)
Local aButtons := { {'FILTRO',{||Pcoa191Fil(.T.) },STR0012,STR0013} } //"Configurar Filtro"###"Filtro"
Inclui := .F.
Altera := .F.
Return axVisual(cAlias,nOpcx,nRecno,,,,,aButtons) 



Function Pcoa191Fil(lVisual)
Default lVisual := .F.

dbSelectArea("AKW")
dbSetOrder(1)
If !Empty(M->AL4_CONFIG+M->AL4_NIVEL) .And. dbSeek(xFilial()+M->AL4_CONFIG+M->AL4_NIVEL)
	If lVisual 
		BuildExpr(AKW->AKW_ALIAS,,M->AL4_FILTER)	
	Else
		M->AL4_FILTER := BuildExpr(AKW->AKW_ALIAS,,M->AL4_FILTER)
	EndIf
EndIf

Return 


Function Pcoa191Pesq()
dbSelectArea("AKW")
dbSetOrder(1)
If ReadVar() == "M->AL4_EXPRIN" .Or. ReadVar() == "M->AL4_EXPRFI" 
	If !Empty(M->AL4_CONFIG+M->AL4_NIVEL) .And. dbSeek(xFilial()+M->AL4_CONFIG+M->AL4_NIVEL)
		If !Empty(AKW->AKW_F3)
		   If ConPad1( , , , AKW->AKW_F3 , , , .F. )
				&(ReadVar()) := &(AKW->AKW_RELAC)
			EndIf	
		EndIf
	EndIf
EndIf
Return		

Function Pcoa191Par()
Local aArea := GetArea()
Local aIni := {}, aFim := {}
Local aAlias := {}, aDescri := {}
Local aParametros := {}, aConfig := {}, nX

dbSelectArea("AKW")
dbSetOrder(1)
	If !Empty(M->AL4_CONFIG+M->AL4_NIVEL) .And. dbSeek(xFilial()+M->AL4_CONFIG+M->AL4_NIVEL)
		dbSelectArea("AKW")
		dbSetOrder(1)
		nx := 0
		If dbSeek(xFilial()+M->AL4_CONFIG)
			While !Eof() .And. xFilial()+M->AL4_CONFIG == AKW->AKW_FILIAL+AKW->AKW_COD
				aAdd(aAlias,Alltrim(AKW->AKW_ALIAS))
				aAdd(aIni,SPACE(AKW->AKW_TAMANH))
				aAdd(aFim,Replicate("z",AKW->AKW_TAMANH)) 
				aAdd(aDescri,AKW->AKW_DESCRI)
				dbSkip()
			End 
		EndIf
EndIf

For nx := 1 To Len(aAlias)
	If nx == 1
		aAdd(aParametros,{4,STR0017,.T./*aTotais[nx]*/,STR0018+StrZero(nX, 2)+"(MV_PAR"+StrZero(nX,2)+")",120,,.F.}) //"Imprimir Totais : "###"Nivel "
	Else
		aAdd(aParametros,{4,"",.T./*aTotais[nx]*/,STR0018+StrZero(nX, 2)+"(MV_PAR"+StrZero(nX,2)+")",120,,.F.}) //"Nivel "
	EndIf
Next

For nx := 1 to Len(aAlias)
	aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0021,"(MV_PAR"+StrZero(Len(aAlias)+((nX*3)-3)+1,2)+")"/*+aIni[nx]*/, "" ,"",""/*aF3[nx]*/,".F.",  70,.F.}) //" de "
	aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0019,"(MV_PAR"+StrZero(Len(aAlias)+((nX*3)-3)+2,2)+")"/*+aFim[nx]*/, "" ,"",""/*aF3[nx]*/,".F.", 70,.F.}) //" Ate "
	aAdd(aParametros,{7,STR0020+AllTrim(aDescri[nx]),aAlias[nx],"(MV_PAR"+StrZero(Len(aAlias)+((nX*3)-3)+3,2)+")"}) //"Filtro "
Next

If !Empty(aParametros)
	ParamBox(  aParametros ,STR0016,aConfig,,,.F.) //"Configuração de Saldos"
EndIf	

Restarea(aArea)

Return		

Static Function AjustSX9()
Local cQuery, nFKInUse, nRecno
Local aEmprLst := {}
Local oDlg, oListBox, lOk := .F.
Local oOk			:= LoadBitMap(GetResources(), "LBTIK")
Local oNo			:= LoadBitMap(GetResources(), "LBNO")
Local cEmpAnt
Local nX
Local nRecAtu, nRecProx
Local aProc := {}
Local nCFil		:= 0
Local aSM0		:= {}
Local cMens := STR0022 + Chr(13) +;  //"Atencao !"
		 	STR0023 + Chr(13) +;  //"Esta rotina ira atualizar o dicionario de dados - Tabela Relacionamento (SX9) "
		 	STR0024 + Chr(13) +;  //"para correcao da ligacao da tabela de configuracoes de cubo."
		 	STR0025 //"Nao deve existir usuarios utilizando o sistema durante a atualizacao!"

cArqEmp := "SigaMat.Emp"
nModulo		:= 44
__cInterNet := Nil
PRIVATE __lPyme  := .F.

OpenSm0Excl()
aSM0 := AdmAbreSM0()

TCInternal(5,'*OFF') //-- Desliga Refresh no Lock do Top

Set Dele On

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ So continua se conseguir abrir o SX2 como exclusivo          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Aviso(STR0022, cMens,{STR0026,STR0027},3) != 1  //"Atencao !"###"Confirma"###"Cancela"
   Return
EndIf

For nCFil := 1 to Len(aSM0)
	If Ascan(aEmprLst, {|x|x[2]==aSM0[nCFil][SM0_GRPEMP]}) == 0
		aAdd(aEmprLst, { .F., aSM0[nCFil][SM0_GRPEMP], aSM0[nCFil][SM0_NOME]}) 
	EndIf	
Next nCFil

If Len(aEmprLst) > 0
	
	DEFINE MSDIALOG oDlg FROM 40,168 TO 380,730 TITLE STR0037 Of oMainWnd PIXEL  //"Escolha a Empresa a Ajustar Relacionamentos (SX9)"
	
		@ 0,0 BITMAP oBmp RESNAME "PROJETOAP" Of oDlg SIZE 100,300 NOBORDER When .F. PIXEL
		oListBox := TWBrowse():New( 10,10,206,152,,{" OK ",STR0028,STR0029},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  //"Codigo"###"Nome da Empresa"
		oListBox:SetArray(aEmprLst)
		oListBox:bLine := { || {If(aEmprLst[oListBox:nAt,1],oOk,oNo), aEmprLst[oListBox:nAT][2], aEmprLst[oListBox:nAT][3]}}
		oListBox:bLDblClick := { ||	oListbox:aArray[oListBox:nAt,1] := ! oListbox:aArray[oListBox:nAt,1]}
	
	   @ 10,230 BUTTON STR0026+' >>'	SIZE 45 ,10   FONT oDlg:oFont ACTION (lOk:=.T.,oDlg:End())  OF oDlg PIXEL   //"Confirma"
	   @ 25,230 BUTTON '<< '+STR0027	SIZE 45 ,10   FONT oDlg:oFont ACTION (lOk:=.F.,oDlg:End())  OF oDlg PIXEL   //"Cancela"
	
	ACTIVATE MSDIALOG oDlg CENTERED

    If lOk

		For nX := 1 TO Len(aEmprLst)
			If aEmprLst[nX, 1]
		    	cEmpAnt := aEmprLst[nX, 2]
		    	
				For nCFil := 1 to Len(aSM0)
			
					If aSM0[nCFil][SM0_GRPEMP] == cEmpAnt
						RpcSetType(3)
						RpcSetEnv(aSM0[nCFil][SM0_GRPEMP], aSM0[nCFil][SM0_CODFIL])

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se a integridade referencial está ativa                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cQuery := "SELECT count(*) TOTAL FROM TOP_PARAM WHERE PARAM_NAME = 'FKINUSE" + cEmpAnt + "'"
						dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'INTEGR', .F., .T.)
						nFKInUse := INTEGR->TOTAL
						INTEGR->( dbCloseArea() )
				
						If nFKInUse != 0
							lOk := .F.
                            MsgStop(STR0030 + cEmpAnt + STR0031) //"Atencao!! Integridade referencial ligada na Empresa "###" - Operacao Abortada."
						EndIf
						
						RpcClearEnv()		
					EndIf
  				Next nCFil 
						
			EndIf
		Next
				   
    EndIf

	If lOk	
		For nX := 1 TO Len(aEmprLst)
			If aEmprLst[nX, 1] .And. aScan(aProc, aEmprLst[nX, 2]) == 0
		    	cEmpAnt := aEmprLst[nX, 2]

				For nCFil := 1 to Len(aSM0)

					If aSM0[nCFil][SM0_GRPEMP] == cEmpAnt  .And. aScan(aProc, cEmpAnt) == 0
						RpcSetType(3)
						RpcSetEnv(aSM0[nCFil][SM0_GRPEMP], aSM0[nCFil][SM0_CODFIL])
						
						dbSelectArea("SX9")
						dbSetOrder(1)
						aAdd(aProc, cEmpAnt)
											
						RpcClearEnv()
						
					EndIf
			
				Next nCFil 
			
			EndIf	
		
		Next
		
	EndIf	

EndIf

If Len(aProc) > 0
	MsgStop(STR0032+CRLF+STR0033) //"Relacionamentos (SX9) corrigidos com sucesso,  "###"referente a configuracoes de cubo."
EndIf

Return

User Function PCO_AJSX9()
	DEFINE WINDOW oMainWnd FROM 0,0 TO 01,1 TITLE STR0034 //"Atualizacao do Dicionario - Relacionamentos (SX9)"
	ACTIVATE WINDOW oMainWnd ICONIZED;
	ON INIT (Processa({|lEnd| AjustSX9(@lEnd)},STR0035,STR0036,.F.) , oMainWnd:End()) //"Processando"###"Aguarde , processando preparacao dos arquivos"
Return	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³29/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1, ,.F.},;     //"Pesquisar"
							{ STR0003, 	"AxVisual" , 0 , 2},;     //"Visualizar"
							{ STR0004, 		"Pcoa191Brw" , 0 , 3},;	   //"Incluir"
							{ STR0005, 		"AxAltera" , 0 , 4},;  //"Alterar"
							{ STR0006,		"Pcoa191Brw" , 0 , 4},;  //"Estrutura"
							{ STR0007, 		"Pcoa191Brw" , 0 , 5}}  //"Excluir"
					
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario no Browse                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA1911" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ³
		//P_E³ browse da tela de Centros Orcamentarios                                            ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
		//P_E³               Ex. :  User Function PCOA1951                            ³
		//P_E³                      Return {{"Titulo", {|| U_Teste() } }}             ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsRotina := ExecBlock( "PCOA1911", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf      
EndIf	
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AdmAbreSM0³ Autor ³ Orizio                ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as informacoes das filias das empresas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AdmAbreSM0()
Local aArea			:= SM0->( GetArea() )
Local aAux			:= {}
Local aRetSM0		:= {}
Local lFWLoadSM0	:= FindFunction( "FWLoadSM0" )
Local lFWCodFilSM0 	:= FindFunction( "FWCodFil" )

If lFWLoadSM0
	aRetSM0	:= FWLoadSM0()
Else
	DbSelectArea( "SM0" )
	SM0->( DbGoTop() )
	While SM0->( !Eof() )
		aAux := { 	SM0->M0_CODIGO,;
					IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
					"",;
					"",;
					"",;
					SM0->M0_NOME,;
					SM0->M0_FILIAL }

		aAdd( aRetSM0, aClone( aAux ) )
		SM0->( DbSkip() )
	End
EndIf

RestArea( aArea )
Return aRetSM0
