#INCLUDE  "QPPR040.CH"
#INCLUDE  "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPR040  � Autor � Robson Ramiro A. Olive� Data � 02.06.04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Equipe Multifuncional                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPR040(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PPAP                                                       ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPPR040(lBrow,cEquipAuto,cJPEG)

Local oPrint
Local lPergunte := .F.
Local cFiltro	:= ""
Local aArea		:= GetArea()

Private cEquip		:= ""
Private cStartPath 	:= GetSrvProfString("Startpath","")
Private lSeekQK1	:= !Empty(cEquipAuto)

Default lBrow 		:= .F.
Default cEquipAuto	:= ""              
Default cJPEG       := ""

If lSeekQK1
	DbSelectArea("QK1")
	DbSetOrder(1)
	If DbSeek(xFilial()+cEquipAuto)
		lSeekQK1	:= .T.
		cEquip		:= QK1->QK1_CODEQU  
		If Empty(cEquip)  
			MessageDlg(OemToAnsi(STR0022),,1)	//"Nao existe equipe multifuncional relacionada com esta peca"				
		Endif
	Else
		Return .F.
	Endif
Endif

oPrint := TMSPrinter():New(STR0001) //"Equipe Multifuncional"

oPrint:SetLandscape()

//�����������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros							�
//� mv_par01				// Cod. da Equipe   					�
//� mv_par02				// Impressora / Tela          			�
//�������������������������������������������������������������������

SX1->(DbSetOrder(1))

If Empty(cEquipAuto)
	If AllTrim(FunName()) == "QPPA040"
		cEquip := Iif(!lBrow, M->QKE_COD, QKE->QKE_COD)
	Else
		lPergunte := Pergunte("PPR040",.T.)

		If lPergunte
			cEquip := mv_par01
		Else
			Return Nil
		Endif
	Endif
Endif

DbSelectArea("QKE")

cFiltro := DbFilter()

If !Empty(cFiltro)
	Set Filter To
Endif

DbSetOrder(1)
If DbSeek(xFilial()+cEquip)

	If Empty(cEquipAuto)
		MsgRun(STR0002,"",{|| CursorWait(), MontaRel(oPrint) ,CursorArrow()}) //"Gerando Visualizacao, Aguarde..."
	Else
		MontaRel(oPrint)
	Endif

	If (lPergunte .and. mv_par02 == 1) .or. (!Empty(cEquipAuto) .and. !lBrow)
		If !Empty(cJPEG)
   			oPrint:SaveAllAsJPEG(cStartPath+cJPEG,1120,840,140)
        Else
			oPrint:Print()
		EndIF
	Else
		oPrint:Preview()  		// Visualiza antes de imprimir
	Endif
Endif

If !Empty(cFiltro)
	Set Filter To &cFiltro
Endif

If !lPergunte
	RestArea(aArea)
Endif

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MontaRel � Autor � Robson Ramiro A. Olive� Data � 02.06.04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Equipe Multifuncional                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MotaRel(ExpO1)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPR040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MontaRel(oPrint)


Local i := 1, nCont := 0
Local lin

Private oFont16, oFont08, oFont10, oFontCou08

oFont16		:= TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
oFont08		:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFontCou08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)

Cabecalho(oPrint,i)  	// Funcao que monta o cabecalho
lin := 390

DbSelectArea("QKE")

Do While !Eof() .and. QKE->QKE_COD == cEquip .and. xFilial("QKE") == QKE->QKE_FILIAL

	nCont++ 

	If lin > 2200
		nCont := 1
		i++
		oPrint:EndPage() 		// Finaliza a pagina
		Cabecalho(oPrint,i)  	// Funcao que monta o cabecalho
		lin := 390
	Endif

	oPrint:Say(lin,0040,QKE->QKE_MAT,oFontCou08)
	oPrint:Say(lin,0250,QKE->QKE_NOME,oFontCou08)

	QAA->(DbSetOrder(1))
	If QAA->(DbSeek(QKE->QKE_FILMAT + QKE->QKE_MAT))

		QAC->(DbSetOrder(1))
		If QAC->(DbSeek(xFilial("QAC") + QAA->QAA_CODFUN))
			oPrint:Say(lin,0800,SubStr(QAC->QAC_DESC,1,16),oFontCou08)		
		Endif

		QAD->(DbSetOrder(1))
		If QAD->(DbSeek(xFilial("QAD") + QAA->QAA_CC))
			oPrint:Say(lin,1100,QAD->QAD_DESC,oFontCou08)
		Endif

		oPrint:Say(lin,1600,QAA->QAA_EMAIL,oFontCou08)	
	Endif

	Do Case
		Case QKE->QKE_TIPO == "1"; oPrint:Say(lin,2500,STR0003,oFontCou08) //"PARTICIPANTE"
		Case QKE->QKE_TIPO == "2"; oPrint:Say(lin,2500,STR0004,oFontCou08) //"CONVIDADO"
		Case QKE->QKE_TIPO == "3"; oPrint:Say(lin,2500,STR0005,oFontCou08) //"LIDER"
	Endcase

	If QKE->QKE_TREINA == "1" 
		oPrint:Say(lin,2800,STR0006,oFontCou08) //"SIM"
	Else
		oPrint:Say(lin,2800,STR0007,oFontCou08) //"NAO"
	Endif

	lin += 40
	oPrint:Line( lin, 30, lin, 3000 )   	// horizontal
	lin += 40

	DbSelectArea("QKE")
	DbSkip()

Enddo

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Cabecalho� Autor � Robson Ramiro A. Olive� Data � 02.06.04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Equipe Multifuncional                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cabecalho(ExpO1,ExpN1)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpN1 = Contador de paginas                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPR040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Cabecalho(oPrint,i)

Local cFileLogo  := "LGRL"+SM0->M0_CODIGO+FWCodFil()+".BMP" // Empresa+Filial //SM0->M0_CODFIL

If !File(cFileLogo)
	cFileLogo := "LGRL" + SM0->M0_CODIGO+".BMP" // Empresa
Endif

oPrint:StartPage() 		// Inicia uma nova pagina

oPrint:SayBitmap(05,0005, cFileLogo,328,82)             // Tem que estar abaixo do RootPath

If Right(cStartPath,1) <> "\"
	cStartPath += "\"
Endif

oPrint:SayBitmap(05,2800,cStartPath+"Logo.bmp",237,58)

oPrint:Say(050,1350,OemToAnsi(STR0001),oFont16) //"Equipe Multifuncional"

// Box Cabecalho
oPrint:Box( 160, 30, 250, 3000 )

oPrint:Say(170,2810,STR0008,oFont10) //"Pagina"
oPrint:Say(210,2810,StrZero(i,3),oFontCou08)

oPrint:Say(170,040,OemToAnsi(STR0009),oFont10) //"Codigo"
oPrint:Say(210,040,QKE->QKE_COD,oFontCou08)

oPrint:Say(170,250,OemToAnsi(STR0010),oFont10) //"Descricao"
oPrint:Say(210,250,SubStr(QKE->QKE_DESC,1,TamSx3("QKE_DESC")[1]-3),oFontCou08)

oPrint:Say(170,650,OemToAnsi(STR0011),oFont10) //"Data Inicio"
oPrint:Say(210,650,DtoC(QKE->QKE_DATAC),oFontCou08)

oPrint:Say(170,900,OemToAnsi(STR0012),oFont10) //"Valida ate"
oPrint:Say(210,900,DtoC(QKE->QKE_DATAV),oFontCou08)

If lSeekQK1
	oPrint:Say(170,1100,OemToAnsi(STR0013),oFont10) //"Peca (Cliente)"
	oPrint:Say(210,1100,QK1->QK1_PCCLI,oFontCou08)

	oPrint:Say(170,1800,OemToAnsi(STR0014),oFont10) //"Peca (Fornecedor)"
	oPrint:Say(210,1800,AllTrim(QK1->QK1_PECA)+" / "+QK1->QK1_REV,oFontCou08)
Endif

// Box Cabecalho
oPrint:Box( 300, 30, 2200, 3000 )

oPrint:Say(310,0040,OemToAnsi(STR0015),oFont10) //"Mat."
oPrint:Say(310,0250,OemToAnsi(STR0016),oFont10) //"Nome"
oPrint:Say(310,0800,OemToAnsi(STR0017),oFont10) //"Funcao"
oPrint:Say(310,1100,OemToAnsi(STR0018),oFont10) //"Departamento"
oPrint:Say(310,1600,OemToAnsi(STR0019),oFont10) //"E-Mail"
oPrint:Say(310,2500,OemToAnsi(STR0020),oFont10) //"STATUS"
oPrint:Say(310,2800,OemToAnsi(STR0021),oFont10) //"Treinamento"

oPrint:Line( 350, 30, 350, 3000 )   	// horizontal

oPrint:Line(300, 0240, 2200, 0240)   	// vertical
oPrint:Line(300, 0790, 2200, 0790)   	// vertical
oPrint:Line(300, 1090, 2200, 1090)   	// vertical
oPrint:Line(300, 1590, 2200, 1590)   	// vertical
oPrint:Line(300, 2490, 2200, 2490)   	// vertical
oPrint:Line(300, 2790, 2200, 2790)   	// vertical

Return Nil