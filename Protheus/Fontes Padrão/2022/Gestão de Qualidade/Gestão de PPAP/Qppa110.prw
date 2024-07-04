#INCLUDE "QPPA110.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE GANTT "8"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPA110  � Autor � Eduardo de Souza      � Data � 31/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Cronograma                                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPA110()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPPAP                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� Robson Ramiro�25.09.01�      � Inclusao de Botao para chamada de rela-���
���              �        �      � torio e tratamento do mesmo            ���
���              �        �      � Melhorias no tratamento de exclusoes   ���
���              �        �      � Permissao de inclusao de atividade sem ���
���              �        �      � codigo cadastrado                      ���
���              �        �      � Acerto de Gatilho para atuliz. de Campo���
��� Robson Ramiro�18.02.02�VERSAO� Retirada dos ajustes 609 x 710         ���
��� Robson Ramiro�24.04.02�META  � Troca do Alias da familia SR para QA   ���
��� Robson Ramiro�18.07.02�XMETA � Inclusao de legenda nos itens da       ���
���              �        �      � getdados. Melhoria para a reorganizacao���
���              �        �      � das atividades.                        ���
���              �        �      � Troca do CvKey por GetSXENum           ���
��� Robson Ramiro�13.08.03�xMeta � Alteracao e inclusao nos conceitos de  ���
���              �        �      � legenda e prazos para conclusao e troca���
���              �        �      � tabela QF SX5 para o arquivo QKZ       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui", 		0, 1,,.F.} ,; 	//"Pesquisar"
					{ OemToAnsi(STR0002), "QPPA110Visu", 	0, 2} ,;    	//"Visualizar"
					{ OemToAnsi(STR0003), "QPPA110Grav", 	0, 3} ,;    	//"Incluir"
					{ OemToAnsi(STR0004), "QPPA110Grav", 	0, 4} ,; 	    //"Alterar"
					{ OemToAnsi(STR0005), "QPPA110Visu", 	0, 5} ,;     	//"Excluir"
					{ OemToAnsi(STR0025), "PPA110Lege", 	0, 6,,.F.} ,;	//"Legenda"
					{ OemToAnsi(STR0029), "QPPR110(.T.)",	0, 8,,.T.} } 	//"Imprimir"

Return aRotina

Function QPPA110
//���������������������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                                �
//�����������������������������������������������������������������������������
Private cCadastro := OemToAnsi(STR0006) //"Cronograma"
Private lLacuna   := GetMv("MV_QLACUN",,"N") == "S"
Private lIntGPE	   := GetlIntGPE() 
Private lAltUsr   := GetlAltUsr()
 
aCores  := { 	{"QPP110CorB(1) == 1", 'ENABLE'    },; 	// Verde    - Cronograma em dia
				{"QPP110CorB(2) == 2", 'BR_AMARELO'},;	// Amarelo  - Expirando nos proximos dias
				{"QPP110CorB(3) == 3", 'DISABLE'   },;	// Vermelho - Cronograma Atrasado
				{"QPP110CorB(4) == 4", 'BR_CINZA'  } } 	// Cinza	- Cronograma Encerrado

Private aRotina := MenuDef()

DbSelectArea("QKG")
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QKG",,,,,,aCores)

Return .t.

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �QPPA110Visu � Autor � Eduardo de Souza      � Data �02/08/01  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Visualizacao \ Exclusao                                      ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPA110Visu(ExpC1,ExpN1,ExpN2)                               ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � QPP110                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function QPPA110Visu(cAlias,nReg,nOpc)

Local aButtons    	:= {}
Local aAlter		:= {} 
Local aPosObj		:= {}
Local oSize			:= NIL
Local oDlg			:= NIL
Local oEnchoice 	:= NIL

Private aGets		:= {}
Private aTela		:= {}
Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL

oSize := FwDefSize():New()                
oSize:AddObject( "CABECALHO",  100, 40, .T.,.F.)
oSize:AddObject( "GETDADOS" ,  100, 60, .T.,.T.)         
oSize:aMargins := { 3, 3, 3, 3 }
oSize:Process() // Dispara os calculos 

DbSelectArea("QKG")
RegToMemory("QKG",.F.)

//��������������������������������������������������������������Ŀ
//� Monta Enchoice 			                                     �
//����������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006); // "Cronograma"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

aAdd(aPosObj,{oSize:GetDimension('CABECALHO', 'LININI'),oSize:GetDimension('CABECALHO', 'COLINI'),oSize:GetDimension('CABECALHO', 'LINEND'),oSize:GetDimension('CABECALHO', 'COLEND')})
aAdd(aPosObj,{oSize:GetDimension('GETDADOS' , 'LININI'),oSize:GetDimension('GETDADOS' , 'COLINI'),oSize:GetDimension('GETDADOS' , 'LINEND'),oSize:GetDimension('GETDADOS' , 'COLEND')})

oEnchoice := Msmget():New("QKG",nReg,nOpc,,,,,aPosObj[1],,,,,,,,)

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
DbSelectArea("QKP")

QPP110Ahead("QKP")
nUsado	:= Len(aHeader)
QPP110Acols(nOpc)

aAlter := {}
Aadd(aAlter,"QKP_OBS")

// Foi usado a Opcao 4 fixa no nOpc para permitir a visualizacao das observacoes
oGet := MSGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4],4,"AllwaysTrue","AllwaysTrue","+QKP_SEQ",.F.,aAlter,,,Len(Acols))

aButtons := { 	{"RELATORIO",	{ || QP110EdTxt( nOpc,QKG->QKG_PECA,QKG->QKG_REV,QKG->QKG_CHAVE ) }	, OemToAnsi(STR0014), OemToAnsi(STR0037) },;		//"Observacoes do Cronograma"###"Obs"
				{"BMPVISUAL",	{ || QPPR110() }														, OemToAnsi(STR0021), OemToAnsi(STR0038) }}	//"Visualizar/Imprimir"###"Vis/Prn"

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,Iif(nOpc==5,{|| QPP110Exc(),oDlg:End()} , {|| oDlg:End()} ),{||oDlg:End()}, , aButtons), AlignObject(oDlg,{oEnchoice:oBox, oGet:oBrowse},1,,{166}),oGet:oBrowse:Refresh())

Return .t.

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �QPPA110Grav � Autor � Eduardo de Souza      � Data �31/07/01  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Inclusao do Cronograma                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void QPPA110Grav(ExpC1,ExpN1,ExpN2)                          ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function QPPA110Grav(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local lOk 			:= .f.
Local aButtons    	:= {}
Local aCposQKG	   	:= {}
Local aPosObj		:= {}

Local oSize			:= NIL
Private aGets		:= {}
Private aTela		:= {}
Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL

aCposQKG := {	"QKG_RESP" }

If nOpc == 4
	If !QPPVldAlt(QKG->QKG_PECA,QKG->QKG_REV)
		Return
	Endif
Endif

oSize := FwDefSize():New()                
oSize:AddObject( "CABECALHO",  100, 40, .T.,.F.)
oSize:AddObject( "GETDADOS" ,  100, 60, .T.,.T.)         
oSize:aMargins := { 3, 3, 3, 3 }
oSize:Process() // Dispara os calculos  

DbSelectArea(cAlias)
//��������������������������������������������������������������Ŀ
//� Monta Enchoice 			                                     �
//����������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006); // "Cronograma"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
RegToMemory("QKG",(nOpc == 3))

aAdd(aPosObj,{oSize:GetDimension('CABECALHO', 'LININI'),oSize:GetDimension('CABECALHO', 'COLINI'),oSize:GetDimension('CABECALHO', 'LINEND'),oSize:GetDimension('CABECALHO', 'COLEND')})
aAdd(aPosObj,{oSize:GetDimension('GETDADOS' , 'LININI'),oSize:GetDimension('GETDADOS' , 'COLINI'),oSize:GetDimension('GETDADOS' , 'LINEND'),oSize:GetDimension('GETDADOS' , 'COLEND')})

oEnchoice := Msmget():New("QKG",nReg,nOpc,,,,,aPosObj[1],Iif(nOpc == 4,aCposQKG,),,,,,,,)

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
DbSelectArea("QKP")
QPP110Ahead("QKP")
nUsado	:= Len(aHeader)
QPP110Acols(nOpc)

oGet := MSGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4],nOpc,"QPP110LinOk","QPP110TudOk(nOpc)","+QKP_SEQ",.T.,,,,999)

aButtons := {}

If nOpc == 3
	AADD(aButtons, {"BMPINCLUIR" ,{ || QPPCarQKZ(oGet) }, OemToAnsi(STR0013), OemToAnsi(STR0039) } ) // "Atividades Padrao"###"Incl Ativ"
EndIf

AADD(aButtons, {"RELATORIO"	,	{ || QP110EdTxt( nOpc ) }	, OemToAnsi(STR0014), OemToAnsi(STR0037) } ) //"Observacoes do Cronograma"###"Obs"

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||lOk := QPP110TudOk(nOpc), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons), AlignObject(oDlg,{oEnchoice:oBox, oGet:oBrowse},1,,{166}),oGet:oBrowse:Refresh())

If lOk
	Q110Grav(nOpc)
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QPP110Ahead� Autor �Eduardo de Souza      � Data � 31/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Monta Ahead para aCols                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP110Ahead(ExpC1)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA110/QPPC010                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QPP110Ahead(cAlias,lPend)

Local aStruAlias := FWFormStruct(3, cAlias,, .F.)[3]
Local nX

Default lPend := .F.

aHeader := {}
nUsado 	:= 0

If !Empty(GetSX3Cache("QKP_LEGEND","X3_CAMPO"))
	If X3Uso(GetSX3Cache("QKP_LEGEND","X3_USADO")) .and. cNivel >= GetSX3Cache("QKP_LEGEND","X3_NIVEL")
		nUsado++
		aAdd(aHeader, Q110GetSX3("QKP_LEGEND", "", "") )
	Endif
Endif

If !Empty(GetSX3Cache("QKP_SEQ","X3_CAMPO"))
	If X3Uso(GetSX3Cache("QKP_SEQ","X3_USADO")) .and. cNivel >= GetSX3Cache("QKP_SEQ","X3_NIVEL")
		nUsado++
		aAdd(aHeader, Q110GetSX3("QKP_SEQ", "", "") )
	Endif
Endif

For nX := 1 To Len(aStruAlias)
	
	If (AllTrim(aStruAlias[nX,1])) == "QKP_LEGEND" .or. (AllTrim(aStruAlias[nX,1])) == "QKP_SEQ"
		Loop
	Endif

	If lPend .and. (AllTrim(aStruAlias[nX,1]) == "QKP_MAT" .or. AllTrim(aStruAlias[nX,1]) == "QKP_NOME")
		Loop
	Endif

	If X3Uso(GetSX3Cache(aStruAlias[nX,1],"X3_USADO"))  .and. cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL")
		nUsado++
		aAdd(aHeader, Q110GetSX3(aStruAlias[nX,1], "", "") )
	Endif

	If lPend .and. (AllTrim(aStruAlias[nX,1]) == "QKP_PECA" .or. AllTrim(aStruAlias[nX,1]) == "QKP_REV")
		nUsado++
		aAdd(aHeader, Q110GetSX3(aStruAlias[nX,1], "", "") )
	Endif	
Next nX 

Return

/*����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �QPP110Acols� Autor �Eduardo de Souza      � Data � 31/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega vetor aCols para a GetDados                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP110Acols()                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao no mBrowse                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QPP110Acols(nOpc)

Local nI   := 0
Local nPos := 0

//������������������������������������������������������Ŀ
//� Montagem do aCols               					 �
//��������������������������������������������������������
If nOpc == 3
	aCols := Array(1,nUsado+1)
	For nI = 1 To Len(aHeader)
		If aHeader[nI,8] == "C"
			If Alltrim(Upper(aHeader[nI,2])) == "QKP_LEGEND"
				aCols[1,nI] := LoadBitmap( GetResources(), "BR_AMARELO" )
			Else
				aCols[1,nI] := Space(aHeader[nI,4])
			Endif	
		ElseIf aHeader[nI,8] == "N"
			aCols[1,nI] := 0
		ElseIf aHeader[nI,8] == "D"
			aCols[1,nI] := CtoD("  /  /  ")
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI

	nPos			:= aScan(aHeader,{ |x| AllTrim(x[2])== "QKP_SEQ" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	aCols[1,nUsado+1] := .F.
Else
	DbSelectArea("QKP")
	DbSetOrder(2)
	DbSeek(xFilial()+QKG->QKG_PECA+QKG->QKG_REV)
	While QKP->(!Eof()) .and. xFilial() == QKG->QKG_FILIAL .and.;
		QKP->QKP_PECA+QKP->QKP_REV == QKG->QKG_PECA+QKG->QKG_REV
		
		aAdd(aCols,Array(nUsado+1))
		For nI := 1 to nUsado
			If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
				If AllTrim(Upper(aHeader[nI,2])) == "QKP_LEGEND"
					aCols[Len(aCols),nI] := LoadBitmap( GetResources(), Alltrim(QKP->QKP_LEGEND) )
				Else
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))				
				Endif	
			Else										// Campo Virtual
				cCpo := AllTrim(Upper(aHeader[nI,2]))
				If cCpo == "QKP_LEGEND"
					aCols[Len(aCols),nI] := LoadBitmap( GetResources(), Alltrim(QKP->QKP_LEGEND) )
				Else
					aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
				Endif	
			Endif
		Next nI
		aCols[Len(aCols),nUsado+1] := .F.
		DbSkip()
	Enddo
Endif

//��������������������������������������������������������������������Ŀ
//� Como a cor esta ligada ao registro atualizo antes de exibir a tela �
//����������������������������������������������������������������������
For nI = 1 To Len(aCols)
	QPP110CorIt(nI)
Next

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Q110Grav   � Autor � Eduardo de Souza     � Data � 02/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Gravacao do Cronograma - Incl./Alter.                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q10Grav(ExpN1)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao no mBrowse                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function Q110Grav(nOpc)

Local nIt
Local nCont
Local nNumSeq  		:= 1
Local nPosDel  		:= Len(aHeader) + 1
Local nCpo
Local bCampo   		:= { |nCPO| Field(nCPO) }
Local lGraOk   		:= .T.   // Indica se todas as gravacoes obtiveram sucesso
Local nPosSEQ	    := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QKP_SEQ"})
Local nPosAtiv 		:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_ATIV"	})
Local cEspecie 		:= "QPPA110 " 


DbSelectArea("QKG")
DbSetOrder(1)

Begin Transaction
If Inclui
	RecLock("QKG",.T.)
Else
	RecLock("QKG",.F.)
Endif

For nCont := 1 To FCount()
	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QKG"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif
Next nCont

QKG->QKG_FILRES := cFilAnt
QKG->QKG_REVINV := Inverte(QKG->QKG_REV)
MsUnLock()
If Inclui
	FKCOMMIT()
EndIf

DbSelectArea("QKP")
DbSetOrder(2)
// Excluo registros pois na alteracao pode haver duplicacao
If lLacuna	
    DbSeek(xFilial("QKP")+ M->QKG_PECA + M->QKG_REV + "001",.T.)
    While !Eof() .And. xFilial("QKG")+ M->QKG_PECA + M->QKG_REV == xFilial("QKP")+ QKP->QKP_PECA + QKP->QKP_REV
        RecLock("QKP",.F.)
        DbDelete() 
        MsUnlock()
        QKP->(DbSkip())
    End
EndIf
For nIt := 1 To Len(aCols)
	If !aCols[nIt, nPosDel] .and. !Empty(aCols[nIt,nPosAtiv])  // Verifica se o item foi deletado
		If Altera
			If !lLacuna	
				If DbSeek(xFilial("QKP")+ M->QKG_PECA + M->QKG_REV + StrZero(nIt,Len(QKP->QKP_SEQ)))
					RecLock("QKP",.F.)
				Else
					RecLock("QKP",.T.)
				Endif
			Else
				RecLock("QKP",.T.)
			EndIf
		Else
			RecLock("QKP",.T.)
		Endif
		
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
				QKP->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			EndIf
		Next nCpo
		
		//���������������������������������������������������������Ŀ
		//� Campos  nao informados                                  �
		//�����������������������������������������������������������
		QKP->QKP_FILIAL		:= xFilial("QKG")
		QKP->QKP_PECA		:= M->QKG_PECA
		QKP->QKP_REV 	 	:= M->QKG_REV
		QKP->QKP_FILMAT		:= cFilAnt
		QKP->QKP_REVINV 	:= Inverte(QKP->QKP_REV)

		//��������������������������������������������������������������Ŀ
		//� Controle de itens do acols                                   �
		//���������������������������������������������������������������� 
		//��������������������������������������������������������������Ŀ
		//� Se MV_QLACUN estiver com "S" nao vai refazer sequencia       �
		//����������������������������������������������������������������
		If !lLacuna
			QKP->QKP_SEQ := StrZero(nNumSeq,Len(QKP->QKP_SEQ))
		Else 
			QKP->QKP_SEQ := aCols[nIt,nPosSeq]		
		EndIf
		
		nNumSeq++
		MsUnlock()
	Else
		If DbSeek(xFilial("QKP")+ M->QKG_PECA + M->QKG_REV + aCols[nIt,nPosSeq])
			If !Empty(QKP->QKP_CHAVE)
				QO_DelTxt(QKP->QKP_CHAVE,cEspecie)    //QPPXFUN
			Endif

			RecLock("QKP",.F.)
			DbDelete() 
			MsUnlock()
		Endif
	Endif
Next nIt
FKCOMMIT()

End Transaction

If ExistBlock("QP110INCL")
	ExecBlock("QP110INCL",.F.,.F.,{QKG->QKG_FILIAL,QKG->QKG_PECA,QKG->QKG_REV})			
Endif

Return lGraOk

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �QPPA110Exc  � Autor � Eduardo de Souza      � Data �04/08/01  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Exclusao														���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPA110Exc()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Uso       � QPPA110                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function QPP110Exc()

Local cEspecie	:= "QPPA110"

DbSelectArea("QKG")
DbSetOrder(1)
If DbSeek(xFilial("QKG")+ QKG->QKG_PECA + QKG->QKG_REV)
	If MsgYesNo(STR0008,STR0009) // "Tem certeza que deseja Excluir este Registro" ### "Atencao"

		//����������������������������������������������������Ŀ
		//�Deleta Atividades do Cronograma					   �
		//������������������������������������������������������
		DbSelectArea("QKP")
		DbSetOrder(2)
		If DbSeek(xFilial("QKP") + QKG->QKG_PECA + QKG->QKG_REV)
			Do While QKP->QKP_FILIAL+QKP->QKP_PECA+QKP->QKP_REV == QKG->QKG_FILIAL+QKG->QKG_PECA+QKG->QKG_REV
				If !Empty(QKP->QKP_CHAVE)
					QO_DelTxt(QKP->QKP_CHAVE,cEspecie+" ")    //QPPXFUN
				Endif

				RecLock("QKP",.F.)
				QKP->(DbDelete())
				MsUnlock()
				FKCOMMIT()
				QKP->(DbSkip())
			Enddo
		Endif

		//����������������������������������������������������Ŀ
		//�Deleta Cabecalho do Cronograma			           �
		//������������������������������������������������������
		DbSelectArea("QKG")

		If !Empty(QKG->QKG_CHAVE)
			QO_DelTxt (QKG->QKG_CHAVE,cEspecie+"A")    //QPPXFUN
		Endif

		RecLock("QKG",.F.)
		QKG->(DbDelete())
		MsUnlock()
		FKCOMMIT()
	Endif
Endif

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QPP110TudOk� Autor � Eduardo de Souza     � Data � 02/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para inclusao/alteracao                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP110TudOk                                                ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QPPA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function QPP110TudOk(nOpc)

Local lRet   	 	:= .T.
Local nIt 		 	:= 0
Local nTot		 	:= 0
Local nPosDel 	 	:= Len(aHeader) + 1
Local nPosAtiv	 	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_ATIV" })

lRet:= QPP110LinOk()

If lRet

	For nIt := 1 To Len(aCols)
		If aCols[nIt, nPosDel] .or. Empty(aCols[nIt,nPosAtiv])
			nTot ++
		Endif
		QPP110CorIt(nIt)
	Next nIt
	
	If Empty(M->QKG_PECA) .Or. Empty(M->QKG_REV) .Or. nTot == Len(aCols) .Or. Empty(aCols[n,nPosAtiv]) .and. !aCols[n, nPosDel]
		Help("", 1, "QPP110OBRI") //"Existem campos obrigatorios nao informados" 
		lRet:=.F.
	EndIf
	
	If lRet
		lRet := Q110ValiRv(nOpc)
	Endif

Endif

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Q110ValiRv�Autor  �Eduardo de Souza    � Data �  01/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se Peca/Revisao ja esta cadastrada                 ���
�������������������������������������������������������������������������͹��
���Sintaxe   �Q110ValiRv(ExpN1)											  ���
�������������������������������������������������������������������������͹��
���Parametros� ExpN1 - Numero da opcao do Cadastro                        ���
�������������������������������������������������������������������������͹��
���Uso       � QPPA110                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function Q110ValiRv( nOpc )

Local cCodCli 	:= ""
Local cLojaCli 	:= ""
Local lRet   	:= .t.

DbSelectArea("QKG")
DbSetOrder(1) //QKF_FILIAL+QKF_PECA+QKF_REV
If DbSeek(xFilial("QKG")+M->QKG_PECA+M->QKG_REV) .And. nOpc == 3 // Se encontrar e for Inclusao
	lRet:= .f.
	Help("", 1, "Q140PCEXIS")	// "Numero de Revisao ja cadastrada para esta Peca "
Else
	lRet:= .t.
EndIf

If lRet
	DbSelectArea("QK1")
	DbSetOrder(1) // QK1_FILIAL+QK1_PECA+QK1_REV
	If DbSeek(xFilial("QK1")+M->QKG_PECA+M->QKG_REV)
		M->QKG_DESCPC := QK1->QK1_DESC
		cCodCli  := QK1->QK1_CODCLI
		cLojaCli := Qk1->QK1_LOJCLI
		DbSelectArea("SA1")
		DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
		If DbSeek(XFilial("SA1")+cCodCli+cLojaCli)
			M->QKG_CLIENT := SA1->A1_NOME
		EndIf
	Else
		lRet:= .F.
		Help("", 1, "Q140RVPCNC")	// "Revisao para esta Peca nao existe"
		M->QKG_DESCPC := " "
		M->QKG_CLIENT := " "
	EndIf
EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Q110ValiPc�Autor  �Eduardo de Souza    � Data �  01/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida se Peca existe 									  ���
�������������������������������������������������������������������������͹��
���Sintaxe   �Q110ValiPc(ExpN1)											  ���
�������������������������������������������������������������������������͹��
���Uso       � QPPA110                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function Q110ValiPc()

Local lRet:= .T.

DbSelectArea("QK1")
DbSetOrder(1) // QK1_FILIAL+QK1_PECA+QK1_REV

If !Empty(M->QKG_PECA)
	If !DbSeek(xFilial("QK1")+M->QKG_PECA)
		lRet:= .F.
		Help("", 1, "Q140PCNC") // "Peca nao Cadastrada"
	EndIf
EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QPP110LinOk� Autor � Eduardo de Souza     � Data � 01/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para mudanca/inclusao de linhas               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP110LinOk                                                ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QPPA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function QPP110LinOk

Local lRet       := .t.
Local nCont      := 0
Local nPosAtiv   := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QKP_ATIV"   })
Local nPosDel    := Len(aHeader) + 1        
Local nPosSEQ	 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QKP_SEQ"}) 

If aCols[ n, nUsado + 1 ]  = .f.
	If nPosAtiv # 0
		Aeval( aCols, { |X| If( X[nPosDel]==.F. .And. X[ nPosAtiv ] == aCols[ N, nPosAtiv ] , nCont ++, nCont ) } )
		If nCont > 1
			Help( " ", 1, "QPP110JAEX") // "Informacao ja cadastrada"
			lRet:= .F.
		EndIf
	EndIf
	
	If Empty(aCols[n,nPosAtiv  ]) .And. !aCols[n, nPosDel]
		lRet := .F.
		Help("", 1, "QPP110OBRI") // "Existem campos obrigatorios nao informados"
	EndIf
EndIf

If lLacuna
	//����������������������������������Ŀ
	//�Verifica se a Sequencia ja existe �
	//������������������������������������
	nCont := 0
	aEval( aCols, { |x| Iif(x[nPosDel] == .F. .and. x[nPosSEQ] == aCols[n, nPosSEQ], nCont++, nCont)})
	If nCont > 1
		Help(" ", 1, "QPP110JAEX") // "Informacao ja cadastrada"
		lRet := .F.
	Endif
	
	//�������������������Ŀ
	//�Re-Organiza o Acols�
	//���������������������
	If lRet
		aCols := aSort(aCols,,,{|x,y| x[nPosSEQ]+x[nPosAtiv] < y[nPosSEQ]+y[nPosAtiv]}) 
		oGet:oBrowse:Refresh()    
	Endif
EndIf
	
QPP110CorIt()

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QPPDescPc �Autor  �Eduardo de Souza    � Data �  03/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza Descricao da Peca                                  ���
�������������������������������������������������������������������������͹��
���Sintaxe   � QPPDescPc(ExpC1,ExpC2,ExpL1)                               ���
�������������������������������������������������������������������������͹��
���Parametros� ExpC1 = Numero da Peca                                     ���
���          � ExpC2 = Numero da Revisao                                  ���
���          � ExpL1 = Indica se e' gatilho                               ���
�������������������������������������������������������������������������͹��
���Uso       � QPPA110                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QPPDescPc(cNumPc,cRev, lGatilho)

Local cArea   	 := Alias()
Local nOrdem  	 := IndexOrd()
Local cDescPc 	 := ""
Default lGatilho := .t.

If ValType("INCLUI") == "U"
	Private Inclui := .F.
Endif

If !Inclui .or. lGatilho   // Se Inic. Padrao ou gatilho
	dbSelectArea("QK1")
	QK1->(dbSetOrder(1))
	If DbSeek(xFilial("QK1")+cNumPc+cRev)
		cDescPc := Padr(QK1->QK1_DESC,150)
	Endif
Endif
dbSelectArea( cArea )
dbSetOrder( nOrdem )

Return ( cDescPc )


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QPPCliente�Autor  �Eduardo de Souza    � Data �  03/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza Nome do Cliente                                    ���
�������������������������������������������������������������������������͹��
���Sintaxe   � QPPCliente(ExpC1,ExpC2,ExpL1)                              ���
�������������������������������������������������������������������������͹��
���Parametros� ExpC1 = Numero da Peca                                     ���
���          � ExpC2 = Numero da Revisao                                  ���
���          � ExpL1 = Indica se e' gatilho                               ���
�������������������������������������������������������������������������͹��
���Uso       � QPPA110                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QPPCliente(cNumPc,cRev, lGatilho)

Local cArea   	 := Alias()
Local nOrdem  	 := IndexOrd()
Local cCliente	 := ""
Default lGatilho := .t.


If ValType("INCLUI") == "U"
	Private Inclui := .F.
Endif


If !Inclui .or. lGatilho   // Se Inic. Padrao ou gatilho
	dbSelectArea("QK1")
	QK1->(dbSetOrder(1))
	If DbSeek(xFilial("QK1")+cNumPc+cRev)
		cCodCli  := QK1->QK1_CODCLI
		cLojaCli := Qk1->QK1_LOJCLI
		DbSelectArea("SA1")
		DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
		If DbSeek(xFilial("SA1")+cCodCli+cLojaCli)
			cCliente := Padr(SA1->A1_NOME,40)
		EndIf
	EndIf
EndIf
dbSelectArea( cArea )
dbSetOrder( nOrdem )

Return ( cCliente )


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QPPNUSR  � Autor � Eduardo de Souza      � Data � 03/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gatilho para preencher o nome do usuario                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPNUSR(ExpC1,ExpC2,ExpL1)                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo da Filial                                   ���
���          � ExpC2 = Codigo do Funcionario                              ���
���          � ExpL1 = Indica se e' gatilho                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QPPNUSR(cCodFI,cCodDe,lGatilho)

Local cArea  	 := Alias()
Local nOrdem 	 := IndexOrd()
Local cNome  	 := ""
Default lGatilho := .t.

If ValType("INCLUI") == "U"
	Private Inclui := .F.
Endif

// Verifica se o arquivo QAA est� aberto
If !Inclui .or. lGatilho   // Se Inic. Padrao ou gatilho
	dbSelectArea("QAA")
	QAA->(dbSetOrder(1))
	If dbSeek(cCodFI + cCodDe)
		cNome := Padr(QAA->QAA_NOME,40)
	Endif
Endif

dbSelectArea( cArea )
dbSetOrder( nOrdem )

Return ( cNome )

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QP110EdTxt � Autor �  Eduardo de Souza          � Data � 04/08/01 ���
���������������������������������������������������������������������������������Ĵ��
���Descri�ao  � Abra a janela para digitacao da observacao do cronograma          ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QP110EdTxt( ExpN1, ExpC1, ExpC2, ExpC3 )                          ���
���������������������������������������������������������������������������������Ĵ��
���Parametros � ExpN1 - Opcao do mBrowse										  ���
���           � ExpC1 - Numero da Peca                                            ���
���           � ExpC2 - Numero da Revisao                                         ���
���           � ExpC3 - Chave de Ligacao                                          ���
���������������������������������������������������������������������������������Ĵ��
���Uso		  � QPPA110                                                           ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

Function QP110EdTxt( nOpc, cNumPc, cRev, cChave)

Local cCabec    := ""
Local cTitulo   := ""
Local cEspecie  := "QPPA110"
Local nTamLin   := TamSX3( "QKO_TEXTO" )[1]
Local lEdit     := .f.
Local axTextos  := {}
Local cCod      := ""
Local nSaveSX8	:= GetSX8Len()

Default cNumPc  := M->QKG_PECA
Default cRev    := M->QKG_REV
Default cChave  := M->QKG_CHAVE

cCod  := STR0026 + AllTrim(cNumPc) + STR0027 + cRev //"Peca: "###" - Rev: "

DbSelectArea("QKG")
DbSetOrder(1)

If Empty( cNumPc ) .Or. Empty( cRev )
	Help("", 1, "QPP110CABE") // "Preencha o Cabecalho do Cronograma para atualizar as Atividades Padrao"
	Return .f.
EndIf

Titulo := OemtoAnsi( STR0014 )  // "Observacoes do Cronograma"
cCabec := OemtoAnsi( STR0014 )  // "Observacoes do Cronograma"

If Empty(cChave)
	cChave := GetSXENum("QKG", "QKG_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	If !Inclui
		RecLock( "QKG", .F. )
		QKG->QKG_CHAVE := cChave
		MsUnLock()
		FKCOMMIT()
	Endif
	M->QKG_CHAVE:= cChave
Else
	If !Inclui
		cChave := QKG->QKG_CHAVE
	EndIf
EndiF

If nOpc <> 2 .And. nOpc <> 5
	lEdit := .t.
EndIf

If QO_TEXTO( cChave, cEspecie+"A", nTamlin, cTitulo, cCod, @axtextos, 1, cCabec, lEdit )
	QO_GrvTxt( cChave, cEspecie+"A", 1, @axtextos )
EndIf

Return .t.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �QPP110OBS � Autor � Eduardo de Souza      � Data � 06/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cadastra Observacoes da Atividade           				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QPP110OBS(ExpN1)                               			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao do mBrowse									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QPPA110													  ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� Robson Ramir �27.08.01�----- � Alteracao do retorno da funcao         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QPP110Obs(nOpc)

Local cChave  	:= ""
Local cCabec 	:= ""
Local cTitulo 	:= ""//OemToAnsi(STR0007) //"Observacao da Atividade"
Local nTamLin 	:= TamSX3("QKO_TEXTO")[1]
Local nPosChave := aScan(aHeader,{ |x| AllTrim(x[2]) == "QKP_CHAVE"  } )
Local cEspecie  := "QPPA110 "   //Para gravacao de textos
Local lEdit		:= .F.
Local cInf		:= ""
Local nSaveSX8	:= GetSX8Len()

If !Inclui
	M->QKG_PECA := QKG->QKG_PECA
	M->QKG_REV  := QKG->QKG_REV
EndIf

If INCLUI .Or. ALTERA
	lEdit := .T.
Endif

axTextos	:= {} 	//Vetor que contem os textos dos Produtos
cCabec		:= OemToAnsi(STR0007) //"Observacao da Atividade"

//����������������������������������������������������������Ŀ
//� Gera/obtem a chave de ligacao com o texto da Peca/Rv     �
//������������������������������������������������������������
If Empty(aCols[n,nPosChave]) .and. lEdit
	cChave := GetSXENum("QKP", "QKP_CHAVE",,5)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	aCols[n,nPosChave] := cChave
Else
	cChave := aCols[n,nPosChave]
EndIf

If !Empty(M->QKG_PECA)
	cInf := STR0026 + AllTrim(M->QKG_PECA) + STR0027 + M->QKG_REV + " - " + OemToAnsi(STR0010) + StrZero(n,Len(QKP->QKP_SEQ)) //"Item: " //"Peca: "###" - Rev: "
Else
	cInf := STR0028 //"Atividades Pendentes"
Endif

If QO_TEXTO(cChave,cEspecie,nTamlin,cTitulo,cInf, @axtextos,1,cCabec,lEdit)
	QO_GrvTxt(cChave,cEspecie,1,@axTextos)
Endif	

Return .F.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �QPPCarQKZ � Autor � Robson Ramiro Oliveira� Data � 13/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Carrega vetor com as atividades padroes    				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QPPCarQKZ(oGet)                                 			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto da Getdados                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QPPA110													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QPPCarQKZ(oGet)

Local lRet		 	:= .T.
Local nCnt		 	:= 1
Local nPosCodAti	:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QKP_CODATI"	})
Local nPosAtiv   	:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QKP_ATIV"		})
Local nPosPComp  	:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QKP_PCOMP"		})
Local nPosObs    	:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QKP_OBS"		})
Local nPosSEQ		:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QKP_SEQ"		})
Local nPosLEGEND	:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QKP_LEGEND"	})
Local nI

If Inclui
	If Empty(M->QKG_PECA) .or. Empty(M->QKG_REV) .or. Empty(M->QKG_DATA)
		lRet := .f.
		Help("", 1, "QPP110CABE") // "Preencha o Cabecalho do Cronograma para atualizar as Atividades Padrao"
	Else
		If Len(aCols) == 1.and. Empty(aCols[1][nPosCodAti]) .and. Empty(aCols[1][nPosAtiv])  .or. (len(acols) == 1 .and. acols[1,len(aheader)+1])
			If MsgYesNo(STR0011,STR0012) // "Deseja utilizar as Atividades do Cronograma Padrao" ### " Atividades"
				DbSelectArea("QKZ")
				DbSetOrder(1)
				If DbSeek(xFilial())
					aCols := {}

					Do While !Eof() .AND. xFilial("QKZ") = QKZ->QKZ_FILIAL
						aAdd(aCols,Array(nUsado+1))
						For nI = 1 To Len(aHeader)
							If aHeader[nI,8] == "C"
								aCols[Len(aCols),nI] := Space(aHeader[nI,4])
							ElseIf aHeader[nI,8] == "N"
								aCols[Len(aCols),nI] := 0
							ElseIf aHeader[nI,8] == "D"
								aCols[Len(aCols),nI] := CtoD("  /  /  ")
							ElseIf aHeader[nI,8] == "M"
								aCols[Len(aCols),nI] := ""
							Else
								aCols[Len(aCols),nI] := .F.
							Endif
						Next nI

						aCols[nCnt][nPosCodAti]		:= QKZ->QKZ_COD
						aCols[nCnt][nPosAtiv]		:= QaxIdioma("QKZ->QKZ_DESC","QKZ->QKZ_DESCEN","QKZ->QKZ_DESCSP")
						aCols[nCnt][nPosObs]		:= "<< Enter >>"
						aCols[nCnt][nPosPComp]		:= "0"
						aCols[nCnt][nPosSEQ	]		:= StrZero(nCnt,Len(QKP->QKP_SEQ))
						aCols[nCnt][nPosLEGEND]		:= "ENABLE"
						aCols[Len(aCols),nUsado+1]	:= .F.

						nCnt++
						QKZ->(DbSkip())
					Enddo
				Endif
			Endif
		Else
			lRet:= .f.
			Help("", 1, "QPP110Acol") // "Para utilizar o preenchimento de atividades padrao, nao devera ter nenhuma atividade preenchida"
		Endif
	Endif
Endif

oGet:ForceRefresh()

Return lRet

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QPP110CorB � Autor �Eduardo de Souza        � Data � 08/08/01 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao �Retorna o numero da opcao correspondente a cor da situacao    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 �QPP110CorB(ExpN1)                                             ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Numero Referente a Cor								���
���������������������������������������������������������������������������Ĵ��
���Uso		 �QPPA110                                                       ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
��� Robson Ramiro�13.08.03�      � Alteracao e inclusao nos conceitos       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function QPP110CorB(nOpcQKP)

Local nRet	:= nOpcQKP
Local nDias	:= GetMv("MV_QNDIAS")
Local cRet	:= ""

If nOpcQKP == 1 .Or. nOpcQKP == 2 .Or. nOpcQKP == 3 .or. nOpcQKP == 4
	DbSelectArea("QKP")
	DbSetOrder(2)
	If DbSeek(xFilial("QKP")+QKG->QKG_PECA+QKG->QKG_REV)
		While QKP->(!Eof()) .And. 	QKG->QKG_FILIAL+QKG->QKG_PECA+QKG->QKG_REV ==;
												QKP->QKP_FILIAL+QKP->QKP_PECA+QKP->QKP_REV
			
			If !Empty(QKP->QKP_DTINI) .and. !Empty(QKP->QKP_DTFIM) .and. QKP->QKP_PCOMP == "4"
				cRet+= "4"
			Elseif Empty(QKP->QKP_DTINI) .or. Empty(QKP->QKP_DTPRA)
				cRet+= "1"
			Elseif DtoS(dDataBase) >= DtoS(QKP->QKP_DTINI) .and. DtoS(dDataBase) <= DtoS(QKP->QKP_DTPRA);
					.and. (QKP->QKP_DTPRA - dDataBase) > nDias
				cRet+= "1"
			Elseif DtoS(dDataBase) > DtoS(QKP->QKP_DTPRA) .and. !Empty(QKP->QKP_DTPRA)
				cRet+= "3"
				Exit
			Elseif (QKP->QKP_DTPRA - dDataBase) <= nDias
				cRet+= "2"
			Else
				cRet+= "1"
			Endif
			
			QKP->(DbSkip())
		EndDo
	EndIf

	If "3"$cRet
		nRet := 3
	Elseif "2"$cRet
		nRet := 2
	Elseif "1"$cRet
		nRet := 1
	Elseif "4"$cRet
		nRet := 4
	Endif
EndIf

DbSelectArea("QKG")
Return nRet

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QPP110Email� Autor �Eduardo de Souza        � Data � 08/08/01 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao �Dispara email para responsavel da atividade                   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 �QPP110Email(ExpN1)                                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Numero Referente a Cor								���
���������������������������������������������������������������������������Ĵ��
���Uso		 �QPPA110                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function QPP110Email()

Local nMvDias  := GetMV("MV_QPPEMAI")
Local cEmail   := GetMV("MV_RELACNT")
Local dDtAtual := dDataBase
Local aUsrMail := {}
Local nOrdQAA 
Local nRegQAA 

DbSelectArea("QKG")
DbSetOrder(1)
DbGoTop()

Do While QKG->(!Eof()) 
	DbSelectArea("QKP")
	DbSetOrder(2)
	If DbSeek(xFilial("QKP")+QKG->QKG_PECA+QKG->QKG_REV)
		Do While QKP->(!Eof()) .And. 	QKG->QKG_FILIAL+QKG->QKG_PECA+QKG->QKG_REV ==;
										QKP->QKP_FILIAL+QKP->QKP_PECA+QKP->QKP_REV
			
			If (nMvDias == (QKP->QKP_DTPRA - dDtAtual)) .Or. ;
				(!Empty(QKP->QKP_DTPRA) .And. !Empty(QKP->QKP_DTINI);
			 	.And.  nMvDias > (QKP->QKP_DTPRA - QKP->QKP_DTINI))

         		//�����������������������������������������������������Ŀ
	         	//� Envia email para o usuario Resp. da Atividade	    �
	         	//�������������������������������������������������������

				nOrdQAA:=QAA->(IndexOrd())
				nRegQAA:=QAA->(Recno())
				QAA->(DbSetOrder(1))             

				If QAA->(DbSeek( QKP->QKP_FILMAT + QKP->QKP_MAT ))
					If !Empty(QAA->QAA_EMAIL) .And. (QKP->QKP_AVEMAI <> "S")

						QPPEmail(@aUsrMail, QKP->QKP_PECA,QKP->QKP_REV,QKP->QKP_DTINI,QKP->QKP_DTPRA,;
			   						QKP->QKP_ATIV, QAA->QAA_EMAIL,QKP->QKP_FILMAT,QAA->QAA_APELID,QKP->QKP_MAT,"")

			  			RecLock("QKP",.F.)
			   	  		QKP->QKP_AVEMAI:= "S"
			   	  		MsUnlock()
				   	EndIf
				EndIf   

				QAA->(dbSetOrder(nOrdQAA))
				QAA->(dbGoTo(nRegQAA))
			EndIf

			QKP->(DbSkip())
		EndDo
	EndIf

	QKG->(DbSkip())
EndDo
FKCOMMIT()

If Len(aUsrMail) > 0
	QaEnvMail(aUsrMail,,,,cEmail)
EndIf

Return .T.

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � QPPEMail    � Autor � Eduardo de Souza      � Data �08/08/01 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Envia eMail para o Usuario Comunicando as Atividades         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPEMail(@aUsrMail,cDocto,cRv,cAtividade,cMail,cFilMat,      ���
���          � cApelido,cCodMat,cAttach)                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametro � 1 aUsrMail  :retorna todos os dados referente aos emails     ���
���          � 2 cDocto    :Numero da Peca                                  ���
���          � 3 cRv       :Numero da Revisao da Peca                       ���
���          � 4 dDataIni  :Data Inicial                                    ���
���          � 5 dDataPra  :Data Prazo                                      ���
���          � 6 cAtividade:Atividade do Cronograma                         ���
���          � 7 cMail     :eMail do Responsavel                            ���
���          � 8 cFilMat   :Codigo da Filial                                ���
���          � 9 cApelido  :Nome do Usuario                                 ���
���          �10 cCodMat   :Codigo do Usuario                               ���
���          �11 cAttach   :Arquivo anexado no email                        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/           
Function QPPEMail(aUsrMail,cPeca,cRev,dDataIni,dDataPra,cAtividade,cMail,cFilMat,cApelido,cCodMat,cAttach)

Local cMsg		:= ""     
Local cSubject	:= ""
Local aMsg		:= {}
Local nQAARecno := QAA->(Recno())
Local nQAAOrd	:= QAA->(IndexOrd())

Default cAttach	:= "" 
Default cCodMat := ""

cSubject := Trim(cPeca)+"-" + Trim(Posicione("QK1",1,xFilial("QK1")+cPeca+cRev,"QK1_DESC")) + "-" +Trim(cRev)+"-"+Trim(cAtividade)+" - "+DTOC(dDataBase)

cMsg := cApelido
cMsg := OemToAnsi(STR0016) + " " + DToC(dDataIni) + " " + OemToAnsi(STR0017)+ " " + DToC(dDataPra)
cMsg += CHR(13) + CHR(10) + CHR(13) + CHR(10)    
cMsg += OemToAnsi(STR0018) + " " + cPeca   + " " + Trim(Posicione("QK1",1,xFilial("QK1")+cPeca+cRev,"QK1_DESC")) + " " + OemToAnsi(STR0019) + " " + cRev
cMsg += CHR(13) + CHR(10) + CHR(13) + CHR(10)    
cMsg += OemToAnsi(STR0020) + " " + cAtividade  
cMsg += CHR(13) + CHR(10) + CHR(13) + CHR(10)    
cMsg += CHR(13) + CHR(10) 
cMsg += OemToAnsi(STR0015)  //"Mensagem gerada Automaticamente pelo Modulo SIGAPPAP"

aMsg:=  { { cSubject,cMsg,cAttach } }     

aadd(aUsrMail,{ AllTrim(cApelido),Trim(cMail),aMsg })

QAA->(dbSetOrder(nQAAOrd))
QAA->(dbGoTo(nQAARecno))

Return nil			

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QPPValPra �Autor  �Eduardo de Souza    � Data �  09/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida se Data Prazo eh superior que a Inicial              ���
�������������������������������������������������������������������������͹��
���Sintaxe   �QPPValPra()     											  ���
�������������������������������������������������������������������������͹��
���Uso       � QPPA110                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QPPValPra()

Local lRet		:= .T.
Local nPosDtIni := aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_DTINI"  })

If M->QKP_DTPRA < Acols[n][nPosDtIni] .And. !Empty(M->QKP_DTPRA)
	lRet := .F.
	Help("", 1, "QPP110PRA") // "Data prazo nao pode ser inferior que a Data Inicio"
EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QPPValFim �Autor  �Eduardo de Souza    � Data �  09/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida se Data Final eh superior que a Inicial              ���
�������������������������������������������������������������������������͹��
���Sintaxe   �QPPValFim()      											  ���
�������������������������������������������������������������������������͹��
���Uso       � QPPA110                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QPPValFim()

Local lRet		:= .T.
Local nPosDtIni := aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_DTINI"  })

If M->QKP_DTFIM < Acols[n][nPosDtIni] .And. !Empty(M->QKP_DTFIM)
	lRet := .F.
	Help("", 1, "QPP110FIM") // "Data Final nao pode ser inferior que a Data Inicial"
EndIf

Return lRet


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA110Lege � Autor � Robson Ramiro A.Olive� Data � 04.12.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cria uma janela contendo a legenda da mBrowse              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA110Lege

Local aLegenda := {	{ 'ENABLE',		OemtoAnsi(STR0022)	},;  	//"Cronograma em dia"
					{ 'BR_AMARELO',	OemtoAnsi(STR0023)	},;  	//"Prazo para conclusao expirando"
					{ 'DISABLE',	OemtoAnsi(STR0024)	},;		//"Cronograma Atrasado"
					{ 'BR_CINZA',	OemtoAnsi(STR0031) } } 		//"Cronograma Concluido"

BrwLegenda(cCadastro,STR0025,aLegenda) //"Legenda"

Return .T.

/*
������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao	 �QPP110CorIt� Autor �Robson Ramiro A. Oliveir� Data � 18/07/02 ���
���������������������������������������������������������������������������Ĵ��
���Descricao �Retorna a cor correspondente ao status                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 �QPP110CorIt(ExpN1)                                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Numero da linha ou do contador   					���
���������������������������������������������������������������������������Ĵ��
���Uso		 �QPPA110                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Function QPP110CorIt(nIt)

Local nRet
Local nDias := GetMv("MV_QNDIAS")
Local aCor 	:= {	"ENABLE" 	,;	// Verde    - Em dia
					"BR_AMARELO",;	// Amarelo  - Expirando nos proximos dias
					"DISABLE"	,; 	// Vermelho - Item Atrasado
					"BR_CINZA"	 }	// Cinza 	- Concluido
					
Local nPosDTINI		:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_DTINI"	})
Local nPosDTFIM		:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_DTFIM"	})
Local nPosDTPRA		:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_DTPRA"	})
Local nPosPCOMP		:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_PCOMP"	})
Local nPosLEGEND	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_LEGEND"	})

Default nIt := n

If !Empty(aCols[nIt,nPosDTINI]) .and. !Empty(aCols[nIt,nPosDTFIM]) .and. aCols[nIt,nPosPCOMP] == "4"
	nRet := 4
Elseif Empty(aCols[nIt,nPosDTINI]) .or. Empty(aCols[nIt,nPosDTPRA])
	nRet := 1
Elseif DtoS(dDataBase) >= DtoS(aCols[nIt,nPosDTINI]) .and. DtoS(dDataBase) <= DtoS(aCols[nIt,nPosDTPRA]);
		.and. (aCols[nIt,nPosDTPRA] - dDataBase) > nDias
	nRet := 1
Elseif DtoS(dDataBase) > DtoS(aCols[nIt,nPosDTPRA]) .and. !Empty(aCols[nIt,nPosDTPRA])
	nRet := 3
Elseif (aCols[nIt,nPosDTPRA] - dDataBase) <= nDias
	nRet := 2
Else
	nRet := 1
Endif

aCols[nIt,nPosLEGEND] := aCor[nRet]

Return
//--------------------Q110GetSX3-------------------------------------------------
/*/{Protheus.doc} Q215GetSX3 
Busca dados da SX3 
@author Brunno de Medeiros da Costa
@since 18/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q110GetSX3(cCampo, cTitulo, cWhen)
Local aHeaderTmp := {}
aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
              GetSx3Cache(cCampo,'X3_CAMPO'),;
              GetSx3Cache(cCampo,'X3_PICTURE'),;
              GetSx3Cache(cCampo,'X3_TAMANHO'),;
              GetSx3Cache(cCampo,'X3_DECIMAL'),;
              GetSx3Cache(cCampo,'X3_VALID'),;              
              GetSx3Cache(cCampo,'X3_USADO'),;
              GetSx3Cache(cCampo,'X3_TIPO'),;
              GetSx3Cache(cCampo,'X3_ARQUIVO'),;
              GetSx3Cache(cCampo,'X3_CONTEXT') }
Return aHeaderTmp
