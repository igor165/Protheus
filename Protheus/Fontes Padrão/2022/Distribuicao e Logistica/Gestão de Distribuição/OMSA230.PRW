 #include "Protheus.ch"
 #include "OMSA230.ch"
 #include "pmsicons.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OMSA230  � Autor � Henry Fila            � Data � 14/07/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Unidades de Medida              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function OMSA230(aRotAuto)
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
PRIVATE aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0004)  // "Alocacao de Veiculos"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"DA3")

Set Key VK_F12 To
Return .T.


/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �OMS080MNT � Autor � Henry Fila            � Data �14.11.2001 ���
��������������������������������������������������������������������������Ĵ��
���          �Interface do cadastro de Setores por Zona                    ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias da tabela de carga                              ���
���          �ExpN2: Numero do Registro                                    ���
���          �ExpN3: Opcao do aRotina                                      ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo controlar a interface do cadas-���
���          �tro de setores por zona                                      ���
��������������������������������������������������������������������������Ĵ��
���Uso       � APDL                                                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function Oms230Aloc(cAlias, nReg, nOpc)

Local aCpoEnable:= {"DAN_DATINI","DAN_DATFIM","DAN_HORINI","DAN_HORFIM"}

Local nOpca     := 0

Local aPosObj   := {} 
Local aObjects  := {}
Local aSize     := MsAdvSize( .F. )             

Local nPosDat   := 0
Local nPosHor   := 0
Local nSaveSx8  := GetSx8Len()

Local oDlg
Local oDesc

Local cSeek     := ""
Local cWhile    := ""
Local aNoFields := {"DAN_CODVEI"}
Local bCond     := {|| .T.}				  		  // Se bCond .T. executa bAction1, senao executa bAction2
Local bAction1  := {|| Oms230Reg(aRecno) }  // Retornar .T. para considerar o registro e .F. para desconsiderar
Local bAction2  := {|| .F. }			        // Retornar .T. para considerar o registro e .F. para desconsiderar

Private aHeader := {}
Private aCols   := {} 
Private cVeiculo:= DA3->DA3_COD
Private cDesc   := DA3->DA3_DESC
Private aRecno  := {}

If Pergunte("OMS230",.T.)

	//�������������������������������������������������������Ŀ
	//� Montagem do aHeader e aCols                           �
	//���������������������������������������������������������    
	//������������������������������������������������������������������������������������������������������������Ŀ
	//�FillGetDados( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, uSeekFor, aNoFields, aYesFields, lOnlyYes,			�
	//�				  cQuery, bMountFile, lInclui )																			  			�
	//�nOpcx			- Opcao (inclusao, exclusao, etc). 																	     			�
	//�cAlias		- Alias da tabela referente aos itens																     			�
	//�nOrder		- Ordem do SINDEX																								  			�
	//�cSeekKey		- Chave de pesquisa																							  			�
	//�bSeekWhile	- Loop na tabela cAlias																						  			�
	//�uSeekFor		- Valida cada registro da tabela cAlias (retornar .T. para considerar e .F. para desconsiderar 	�
	//�				  o registro)																										     	�
	//�aNoFields	- Array com nome dos campos que serao excluidos na montagem do aHeader							     	�
	//�aYesFields	- Array com nome dos campos que serao incluidos na montagem do aHeader									�
	//�lOnlyYes		- Flag indicando se considera somente os campos declarados no aYesFields + campos do usuario		�
	//�cQuery		- Query para filtro da tabela cAlias (se for TOP e cQuery estiver preenchido, desconsidera      �
	//�	           parametros cSeekKey e bSeekWhiele) 																		      �
	//�bMountFile	- Preenchimento do aCols pelo usuario (aHeader e aCols ja estarao criados)								�
	//�lInclui		- Se inclusao passar .T. para qua aCols seja incializada com 1 linha em branco						�
	//�aHeaderAux	-																																�
	//�aColsAux		-																																�
	//�bAfterCols	- Bloco executado apos inclusao de cada linha no aCols														�
	//�bBeforeCols	- Bloco executado antes da inclusao de cada linha no aCols													�
	//��������������������������������������������������������������������������������������������������������������
	cSeek		:= xFilial("DAN")+cVeiculo
	cWhile	:= "DAN->DAN_FILIAL+DAN->DAN_CODVEI"
	FillGetDados(nOPc,"DAN",3,cSeek,{|| &cWhile },{{bCond,bAction1,bAction2}},aNoFields,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,Inclui,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/)
			
	nPosDat := GDFieldPos("DAN_DATINI")
	nPosHor := GDFieldPos("DAN_HORINI"	)

	aCols := aSort(aCols,,,{|x,y| +Dtos(x[nPosDat])+x[nPosHor] < +Dtos(y[nPosDat])+y[nPosHor] })
	
	AAdd( aObjects, { 100,  32, .t., .F. } )
	AAdd( aObjects, { 100, 100, .t., .t. } )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 } 
	aPosObj := MsObjSize( aInfo, aObjects ) 
		
		
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 to aSize[6],aSize[5] Of oMainWnd PIXEL
		@ 18,005 SAY FWX3Titulo("DA3_COD") SIZE 50,7 OF oDlg PIXEL	
		@ 18,030 MsGet cVeiculo PICTURE "@!" WHEN .F. SIZE 0,7 OF oDlg PIXEL	
		@ 18,075 MsGet oDesc Var cDesc PICTURE "@!" WHEN .F. SIZE 80,7 OF oDlg PIXEL	
				
		dbSelectArea("DAN")		
		oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"Oms230LOk()","AllwaysTrue()",,.T.,aCpoEnable,,,300)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, If(oGetd:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()})			
			
	Do Case                            
	
	Case ( nOpcA == 1 ) 
		Begin Transaction
			lGravou := Oms230Grv(aRecno)
			If ( lGravou )
				EvalTrigger()
				While ( GetSx8Len() > nSaveSx8 )
					ConfirmSx8()
				EndDo
			EndIf
		End Transaction
	Case nOpcA == 0	                            
		While ( GetSx8Len() > nSaveSx8 )		
			RollBackSx8()
		EndDo	
	EndCase
	
	MsUnlockAll()       

Endif	
		
dbSelectArea("DAN")
dbSetOrder(1)
Return NIL

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Oms230Grv � Autor � Henry Fila            � Data �            ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Alocacao de Veiculo                                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � APDL                                                         ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function Oms230Grv(aRecno)
Local nCntFor  := 0
Local nCntFor2 := 0           
Local nUsado   := Len(aHeader)
Local lGravou  := .F.


dbSelectArea("DAN")
For nCntFor := 1 To Len(aCols)
	If ( !aCols[nCntFor][nUsado+1] )

		If nCntFor > Len(aRecno)				
			RecLock("DAN",.T.)					
		Else						
		   DAN->(MsGoto(aRecno[nCntFor])) 
			RecLock("DAN",.F.)
		Endif						
			
		For nCntFor2 := 1 To nUsado
			If ( aHeader[nCntFor2][10] != "V" )
				DAN->(FieldPut(FieldPos(aHeader[nCntFor2][2]),aCols[nCntFor][nCntFor2]))
			EndIf
		Next nCntFor2
	
		DAN->DAN_FILIAL 	:= xFilial("DAN")
		DAN->DAN_CODVEI 	:= DA3->DA3_COD
	
		MsUnlock()					
	
		lGravou := .T.
	Endif	
Next nCntFor

Return(lGravou)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Oms230Lok � Autor � Henry Fila            � Data �            ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da linha                                           ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � APDL                                                         ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function Oms230LOk()

Local lRet     := .T.
Local nCntFor  := 0
Local nPosDtIni:= aScan(aHeader,{|x| AllTrim(x[2])=="DAN_DATINI"})
Local nPosDtFim:= aScan(aHeader,{|x| AllTrim(x[2])=="DAN_DATFIM"})
Local nPosHrIni:= aScan(aHeader,{|x| AllTrim(x[2])=="DAN_HORINI"})
Local nPosHrFim:= aScan(aHeader,{|x| AllTrim(x[2])=="DAN_HORFIM"})
Local nUsado   := Len(aHeader)

If !aCols[n][nUsado+1]

	If Dtos(aCols[n][nPosDtFim])+aCols[n][nPosHrFim] < Dtos(aCols[n][nPosDtIni])+aCols[n][nPosHrIni]
		Help(" ",1,"OMS230DIF")
		lRet := .F.	 	  
	Endif	
	
	If lRet
		dbSelectArea("DAN")
		dbSetOrder(3)
		dbSeek(xFilial("DAN")+cVeiculo+Dtos(aCols[n][nPosDtFim])+aCols[n][nPosHrFim],.T.)
		If ( 	DAN->DAN_CODVEI == cVeiculo .And. ;
			(( aCols[n][nPosDtFim] <= DAN->DAN_DATFIM .And.;
			  aCols[n][nPosHrFim] <= DAN->DAN_HORFIM .And.;
			  aCols[n][nPosDtFim] >= DAN->DAN_DATINI .And.;
			  aCols[n][nPosHrFim] >= DAN->DAN_HORINI ) .Or.;
			( aCols[n][nPosDtIni] <= DAN->DAN_DATFIM .And.;
			  aCols[n][nPosHrIni] <= DAN->DAN_HORFIM .And.;
			  aCols[n][nPosDtIni] >= DAN->DAN_DATINI .And.;
		 	  aCols[n][nPosHrIni] >= DAN->DAN_HORINI )))
		    If ( aScan(aRecno,DAN->(RecNo()))==0 )		 	  
				Help(" ",1,"OMS230ALOC")
				lRet := .F.	 	  
			Endif	
		EndIf
	Endif	
	
	If lRet
		For nCntFor := 1 To Len(aCols)
			If ( !aCols[nCntFor][nUsado+1] )
				If (( aCols[n][nPosDtFim] <= aCols[nCntFor][nPosDtFim] .And.;
					aCols[n][nPosHrFim] <= aCols[nCntFor][nPosHrFim] .And.;
					aCols[n][nPosDtFim] >= aCols[nCntFor][nPosDtIni] .And.;
					aCols[n][nPosHrFim] >= aCols[nCntFor][nPosHrIni] ) .Or.;
				 (	aCols[n][nPosDtIni] <= aCols[nCntFor][nPosDtFim] .And.;
					aCols[n][nPosHrIni] <= aCols[nCntFor][nPosHrFim] .And.;
					aCols[n][nPosDtIni] >= aCols[nCntFor][nPosDtIni] .And.;
					aCols[n][nPosHrIni] >= aCols[nCntFor][nPosHrIni]))
    		        If ( nCntFor != n )
						Help(" ",1,"OMS230ALOC")
						lRet := .F.
					EndIf
				EndIf
			EndIf
		Next nCntFor
		
	Endif
		
Endif	

Return(lRet)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Oms230Gnt � Autor � Henry Fila            � Data �12.04.2002 ���
��������������������������������������������������������������������������Ĵ��
���          �Exibe grafico de ] das cargas em aberto                      ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1 - .T.                                                  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo ordenar o acols de acordo com  ���
���          �o digitado para recalculo das horas de entrega               ���
��������������������������������������������������������������������������Ĵ��
���Uso       � APDL                                                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function Oms230Gnt()
Local aVeiculos := {}
Local aCores    := {CLR_HBLUE, CLR_HRED,CLR_BROWN, CLR_BLACK, CLR_GREEN, CLR_GRAY}
Local aConfig   := {}
Local aAuxCfg   := {}

Local nTop      := oMainWnd:nTop+23
Local nLeft     := oMainWnd:nLeft+5
Local nBottom   := oMainWnd:nBottom-60
Local nRight    := oMainWnd:nRight-10
Local nX        := 0
Local cDesc     := ""
Local lRet      := .T.
Local dIni      := ddatabase
Local nTsk

Local oFont
Local oDlgCar
Local oBtn

Private bRfshGantt //variavel utilizada no PMSGANTT para fazer o refresh

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

aConfig := {2,.T.,.T.,.T.,.T.,.T.,.T.,.T.}

aVeiculos  := OmsTimeVei(DA3->DA3_COD)

	//�����������������������������������������������������������Ŀ
	//�Estrutura do array de retorno a veiculo                    �
	//�              [1] - Codigo do veiculo                      �
	//�              [2] - Descricao                              �
	//�              [3] - Codigo da Carga                        �
	//�              [4] - Sequencia da carga                     �
	//�              [5] - Data inicial                           �
	//�              [6] - Hora inicial                           �
	//�              [7] - Data Final                             �
	//�              [8] - Hora Final                             �
	//�              [10] - Tipo de alocacao                      �
	//�                     1  - Por Carga                        �
	//�                     2  - Por Bloqueio                     �
	//�������������������������������������������������������������

aGant := {}
For nX := 1 to Len(aVeiculos)
	cDesc := Iif(Empty(aVeiculos[nX][3]),OemtoAnsi(STR0005),OemtoAnsi(STR0006)+aVeiculos[nX][3]+"-"+aVeiculos[nX][4])
	aAdd(aGant,{{cDesc,""},{{aVeiculos[nX][5],aVeiculos[nX][6],aVeiculos[nX][7],aVeiculos[nX][8],,Iif(aVeiculos[nX][9] == "1",aCores[1],aCores[2]),,1,}},CLR_GRAY,oBold})
Next

If !Empty(aGant)

	While lRet

		DEFINE FONT oFont NAME "Arial" SIZE 0, -10
		DEFINE MSDIALOG oDlgCar TITLE OemtoAnsi(STR0004) OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight //"Programacao de Entrega das Cargas"
		oDlgCar:lMaximized := .T.
		bRfshGantt := Nil

			DEFINE BUTTONBAR oBar SIZE 25,35 3D TOP OF oDlgCar

			// opcoes
			oBtn := TBtnBmp():NewBar(BMP_OPCOES, BMP_OPCOES,,, TIP_OPCOES, {|| If(Os230CfgGnt("Teste",@oDlgCar,aConfig,@dIni,aGant),(oDlgCar:End(),lRet := .T.),Nil) },.T.,oBar,,, TIP_OPCOES)
			If SetMdiChild()
				oBtn:cTitle := TOOL_OPCOES
			EndIf

			// sair
			oBtn := TBtnBmp():NewBar(BMP_SAIR, BMP_SAIR,,, TIP_SAIR +" < Ctrl-X >", {|| lRet := .F.,oDlgCar:End() },.T.,oBar,,,TIP_SAIR+" < Ctrl-X >")
			If SetMdiChild()
				oBtn:cTitle := TOOL_SAIR
			EndIf

			aAuxCfg := {aConfig[1],aConfig[3],aConfig[4],aConfig[5],aConfig[6],aConfig[7]}
			oPanel  := PmsGantt(aGant,aAuxCfg,@dIni,,oDlgCar,{14,1,(nBottom/2)-40,(nRight/2)-4},{{OemtoAnsi(STR0009),30}},@nTsk)
			aConfig[1] := aAuxCfg[1]

		ACTIVATE MSDIALOG oDlgCar VALID (lRet := .F.,.T.)

	EndDo
Else
	Help(" ",1,"OMS230GNT")
Endif
Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PmsCfgGnt� Autor � Edson Maricate         � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Exibe uma tela com as configuracoes de visualizacao do Gantt  ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �Generico                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function Os230CfgGnt(cVersao,oDlg,aConfig,dIni,aGantt)
Local lRet		:= .F.  
Local aConfigBk := aClone(aConfig)

lRet := ParamBox({	{3,OemtoAnsi(STR0010),aConfig[1],{OemtoAnsi(STR0011),OemtoAnsi(STR0012),OemtoAnsi(STR0013),OemtoAnsi(STR0014),OemtoAnsi(STR0015),OemtoAnsi(STR0016)},60,,.F.}},; //###"Diario"###"Semanal"###"Mensal"###"Mensal (Zoom 30%)"###"Bimestral"
				OemtoAnsi(STR0017),aConfig,,,.F.,120,3) //"Configuracoes do Gantt" //"Mostrar Recursos"

aConfigBk[1] := aConfig[1]
aConfig := aClone(aConfigBk)

Return lRet

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
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

Private aRotina := {	{OemToAnsi(STR0001), "AxPesqui"		, 0 , 1,0,.F.},;	// "Pesquisar"
						{OemToAnsi(STR0002), "Oms230Aloc"	, 0 , 4,0,NIL},;	// "Manutencao"
						{OemToAnsi(STR0003), "Oms230Gnt"	, 0 , 2,0,NIL} }	// "Alocacao"

If ExistBlock("OM230MNU")
	ExecBlock("OM230MNU",.F.,.F.)
EndIf

Return(aRotina)

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Oms230Reg � Autor � Marco Bianchi         � Data �22/12/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao disparada para validar cada registro da tabela      ���
���          � DAN. Se retornar .T. considera o registro.                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpA1:                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Oms230Reg(aRecno)

Local lRet := .T.

If Dtos(DAN_DATFIM) >= Dtos(mv_par01)
	lRet := .T.
	aadd(aRecno,Recno())
Else
	lRet := .F.
EndIf

Return(lRet)

