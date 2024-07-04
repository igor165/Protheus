#INCLUDE "pcoa191.ch"
#Include "Protheus.ch"
/*/
_F_U_N_C_����������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOA191  � AUTOR � Edson Maricate        � DATA � 26.11.2003 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa de Cadastro das configura��es dos Cubos Estrateficos���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOA191                                                      ���
���_DESCRI_  � Programa de Cadastro de Configurac��es de Cubos Estrat�gicos ���
���_FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    ���
���          � partir do Menu ou a partir de uma funcao pulando assim o     ���
���          � browse principal e executando a chamada direta da rotina     ���
���          � selecionada.                                                 ���
���          � Exemplo: PCOA191(2) - Executa a chamada da funcao de visua-  ���
���          �                       zacao da rotina.                       ���
���������������������������������������������������������������������������Ĵ��
���_PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PCOA191(nCallOpcx)

Local bBlock
Local nPos
Private cCadastro	:= STR0001 //"Configura��o de Cubos"
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

//���������������������������������������������������������Ŀ
//� Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  �
//�����������������������������������������������������������
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
	//������������������������������������������������������������������������Ŀ
	//�Redefine o aRotina                                                      �
	//��������������������������������������������������������������������������
	aRotina 	:= {	{ STR0008, 	"Pcoa191Vis" , 0 , 2},;     //"&Visualizar"
						{ STR0009, 		"Pcoa191Inc" , 0 , 3},;	   //"&Incluir"
						{ STR0010, 		"Pcoa191Alt" , 0 , 4},;  //"&Alterar"
						{ STR0011, 		"AxDeleta" , 0 , 5}}  //"&Excluir"

	//������������������������������������������������������������������������Ŀ
	//�Realiza a Filtragem                                                     �
	//��������������������������������������������������������������������������
	bFiltraBrw := {|| FilBrowse("AL4",@aIndexAL4,@cFiltraAL4) }
	Eval(bFiltraBrw)
	dbGoTop()
	
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro,"AL4",,aRotina,,,,.F.)
	
	//������������������������������������������������������������������������Ŀ
	//� Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       �
	//��������������������������������������������������������������������������
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
	ParamBox(  aParametros ,STR0016,aConfig,,,.F.) //"Configura��o de Saldos"
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

//��������������������������������������������������������������Ŀ
//� So continua se conseguir abrir o SX2 como exclusivo          �
//����������������������������������������������������������������

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

						//���������������������������������������������������������������������������Ŀ
						//� Verifica se a integridade referencial est� ativa                          �
						//�����������������������������������������������������������������������������
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
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �29/11/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1, ,.F.},;     //"Pesquisar"
							{ STR0003, 	"AxVisual" , 0 , 2},;     //"Visualizar"
							{ STR0004, 		"Pcoa191Brw" , 0 , 3},;	   //"Incluir"
							{ STR0005, 		"AxAltera" , 0 , 4},;  //"Alterar"
							{ STR0006,		"Pcoa191Brw" , 0 , 4},;  //"Estrutura"
							{ STR0007, 		"Pcoa191Brw" , 0 , 5}}  //"Excluir"
					
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//������������������������������������������������������������������������Ŀ
	//� Adiciona botoes do usuario no Browse                                   �
	//��������������������������������������������������������������������������
	If ExistBlock( "PCOA1911" )
		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de Centros Orcamentarios                                            �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA1951                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E��������������������������������������������������������������������������
		If ValType( aUsRotina := ExecBlock( "PCOA1911", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf      
EndIf	
Return(aRotina)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AdmAbreSM0� Autor � Orizio                � Data � 22/01/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna um array com as informacoes das filias das empresas ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
