#Include "PROTHEUS.CH"
#INCLUDE "QNCR020.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QNCR020  � Autor � Aldo Marini Junior    � Data � 24.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Ficha de Ocorrencias/Nao-conformidades        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QNCR020(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Aldo        �22/08/01� 9495 � Alterado para imprimir cabecalho grafico ���
���Eduardo S.  �06/02/03�062249� Acerto para filtrar por Ano corretamente.���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function QNCR020
//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais (Basicas)                            �
//����������������������������������������������������������������
Local cDesc1 	:= STR0001		//"Relatorio de Ficha de Ocorrencias/Nao-conformidades."
Local cDesc2 	:= STR0002		//"Ser� impresso de acordo com os parametros solicitados pelo usuario."
Local cDesc3 	
Local cString	:= "QI2"       				// alias do arquivo principal (Base)
Local aOrd      := {STR0003,STR0004}		//"Ano+Codigo FNC+Revisao"###"Codigo FNC+Revisao"
Local wnRel

//��������������������������������������������������������������Ŀ
//� Define Variaveis Private(Basicas)                            �
//����������������������������������������������������������������
Private aReturn  := { STR0005, 1,STR0006, 2, 2, 1,"",1 }	//"Zebrado"###"Administra��o"
Private nomeprog := "QNCR020"
Private aLinha   := {}
Private nLastKey := 0
Private cPerg    := "QNR020"

//��������������������������������������������������������������Ŀ
//� Variaveis Utilizadas na funcao IMPR                          �
//����������������������������������������������������������������
Private Titulo	 := STR0007		//"FICHA DE OCORRENCIAS/NAO-CONFORMIDADES"
Private cCabec
Private AT_PRG  := "QNCR020"
Private wCabec0 := 7
Private wCabec1 := ""
Private	wCabec2	:= "" 
Private wCabec3 := ""
Private wCabec4 
Private wCabec5 
Private wCabec6 
Private wCabec7
Private CONTFL  := 1
Private LI      := 0
Private nTamanho:= "M"
Private lFirst := .T.

//��������������������������������������������������������������Ŀ
//� Define Variaveis Private(Programa)                           �
//����������������������������������������������������������������
Private nOrdem
INCLUI := .F.	// Utilizado devido algumas funcoes de retorno de descricao/nome
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������

pergunte("QNR020",.F.)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01        //  Filial  De                               �
//� mv_par02        //  Filial  Ate                              �
//� mv_par03        //  Ano De                                   �
//� mv_par04        //  Ano Ate             			         �
//� mv_par05        //  Codigo FNC De     	                     �
//� mv_par06        //  Codigo FNC Ate                           �
//� mv_par07        //  Revisao De                               �
//� mv_par08        //  Revisao Ate                              �
//� mv_par09        //  Tipo 1-N.C.Potencial/2-N.C.Existente/3-Melhoria/4-Ambas �
//� mv_par10        //  Plano de Acao Relac. 1-Sim/2-Nao         �
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel:="QNCR020"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho,,.t.)

//��������������������������������������������������������������Ŀ
//� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
//����������������������������������������������������������������
nOrdem   := aReturn[8]
cFilDe   := mv_par01
cFilAte  := mv_par02
cAnoDe   := mv_par03
cAnoAte  := mv_par04
cFNCDe   := mv_par05
cFNCAte  := mv_par06
cRevDe   := mv_par07
cRevAte  := mv_par08
nTipo    := mv_par09
nRelac   := mv_par10

If	nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If	nLastKey == 27
	Return
Endif

RptStatus({|lEnd| QNCR020Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QNCR020Imp� Autor � Aldo Marini Junior    � Data � 24.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ficha de Ocorrencias/Nao-conformidades                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �QNCR020Imp(lEnd,wnRel,cString)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd        - A��o do Codelock                             ���
���          � wnRel       - T�tulo do relat�rio                          ���
���Parametros� cString     - Mensagem                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QNCR010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function QNCR020Imp(lEnd,WnRel,cString)

Local aPriori := {}
Local cTxtDet := ""
Local aTxtDet := {}
Local nT
Local aUsrMat	:= QNCUSUARIO()
Local cMatFil  	:= aUsrMat[2]
Local cMatCod	:= aUsrMat[3]
Local lSigiloso := .f.
Local nPos 		:= 0
Local nTamQI2	:= (TamSX3("QI2_FNC")[1]- 4)

//��������������������������������������������������������������Ŀ
//� Carrega o conteudo do X3_CBOX no array                       �
//����������������������������������������������������������������
QNCCBOX("QI2_PRIORI",@aPriori)

QI9->(dbSetOrder(2))	// Buscar por FNC

dbSelectArea( "QI2" )
QI2->(dbGoTop())

If nOrdem == 1
	QI2->(dbSetOrder( 1 ))
	QI2->(dbSeek(IF((FWModeAccess("QI2") == "C"),xFilial("QI2"),cFilDe) + cAnoDe + cFNCDe + cRevDe,.T.))
	cInicio  := "QI2->QI2_FILIAL + QI2->QI2_ANO + QI2->QI2_FNC + QI2->QI2_REV"
	cFim     := IF((FWModeAccess("QI2") == "C"),xFilial("QI2"),cFilAte) + cAnoAte + cFNCAte + cRevAte
ElseIf nOrdem == 2
	QI2->(dbSetOrder( 2 ))
	QI2->(dbSeek(IF((FWModeAccess("QI2") == "C"),xFilial("QI2"),cFilDe) + cFNCDe + cRevDe,.T.))
	cInicio  := "QI2->QI2_FILIAL + QI2->QI2_FNC + QI2->QI2_REV"
	cFim     := IF((FWModeAccess("QI2") == "C"),xFilial("QI2"),cFilAte) + cFNCAte + cRevAte
Endif

//��������������������������������������������������������������Ŀ
//� Carrega Regua de Processamento                               �
//����������������������������������������������������������������
SetRegua(QI2->(RecCount()))

While QI2->(!EOF()) .And. &cInicio <= cFim
	//��������������������������������������������������������������Ŀ
	//� Movimenta Regua de Processamento                             �
	//����������������������������������������������������������������
	IncRegua()

	If lEnd
		@Prow()+1,0 PSAY cCancel
		Exit
	Endif

	//��������������������������������������������������������������Ŀ
 	//� Consiste Parametrizacao do Intervalo de Impressao            �
	//����������������������������������������������������������������
   
	If	( QI2->QI2_ANO < cAnoDe ) .Or. ( QI2->QI2_ANO > cAnoAte ) .Or. ;
		( QI2->QI2_REV < cRevDe ) .Or. ( QI2->QI2_REV > cRevAte ) .Or. ;
		( Right(Alltrim(QI2->QI2_FNC),4) + Left(QI2->QI2_FNC,nTamQI2) < Right(Alltrim(cFNCDe ),4) + Left(cFNCDe ,nTamQI2) ) .Or. ;
		( Right(Alltrim(QI2->QI2_FNC),4) + Left(QI2->QI2_FNC,nTamQI2) > Right(Alltrim(cFNCAte),4) + Left(cFNCAte,nTamQI2) )		
		QI2->(dbSkip())
		Loop
	Endif

	//��������������������������������������������������������������Ŀ
 	//� Consiste o tipo de Ficha de Ocorrencia/Nao-conformidade      �
	//����������������������������������������������������������������
	If nTipo <> 4 .And. Val(QI2->QI2_TPFIC) <> nTipo
		dbSkip()
		Loop
	Endif

	WCabec1	:= Padr("| "+OemToAnsi(Alltrim(TITSX3("QI2_FNC")[1])+": ")+TransForm(QI2->QI2_FNC,PesqPict("QI2","QI2_FNC"))+"  "+;			
				OemToAnsi(Alltrim(TITSX3("QI2_REV")[1])+": ")+QI2->QI2_REV+"   "+OemToAnsi(Alltrim(TITSX3("QI2_OCORRE")[1])+": ")+PADR(DTOC(QI2->QI2_OCORRE),10)+;		
				" "+OemToAnsi(Alltrim(TITSX3("QI2_CONREA")[1])+": ")+PADR(DTOC(QI2->QI2_CONREA),10)+" "+OemToAnsi(Alltrim(TITSX3("QI2_TPFIC")[1])+": ")+;	
				Padr(QA_CBOX("QI2_TPFIC",QI2->QI2_TPFIC),32),131)+"|"

	WCabec2 := Padr("|"+Space(94)+OemToAnsi(Alltrim(TITSX3("QI2_PRIORI")[1])+": ")+aPriori[Val(QI2->QI2_PRIORI)],131)+"|"	

	WCabec3	:= Padr("| "+OemToAnsi(STR0025)+PADR(QA_NUSR(QI2->QI2_FILMAT,QI2->QI2_MAT,.F.),83)+OemToAnsi(Alltrim(TITSX3("QI2_STATUS")[1])+": ")+QA_CBOX("QI2_STATUS",QI2->QI2_STATUS),131)+"|"	// "Originador: " 

	WCabec4	:= Nil    
	WCabec5	:= Nil    
	WCabec6	:= Nil    
	WCabec7	:= Padr("| "+OemToAnsi(STR0038)+PADR(QA_NUSR(QI2->QI2_FILRES,QI2->QI2_MATRES,.F.),83),131)+"|"     
	
	If mv_par11 == 1 
		If !Empty(QI2->QI2_CODCLI)		
			WCabec4	:= Padr("| "+OemToAnsi(Alltrim(TITSX3("QI2_NOMCLI")[1])+": ")+QI2->QI2_CODCLI+" - "+Posicione("SA1",1,xFilial("SA1")+QI2->QI2_CODCLI+QI2->QI2_LOJCLI,"A1_NOME"),131)+"|"	     	
		Endif	
    Endif
				
	If mv_par12 == 1 
		If !Empty(QI2->QI2_CODFOR)
			WCabec5	:= Padr("| "+OemToAnsi(Alltrim(TITSX3("QI2_NOMFOR")[1])+": ")+QI2->QI2_CODFOR+" - "+FQNCDESFOR(QI2->QI2_CODFOR,QI2->QI2_LOJFOR,"1"),131)+"|"	 
    	Endif
    Endif
    
    If mv_par13 == 1
	    If !Empty(QI2->QI2_CONTAT)
	    	WCabec6	:= Padr("| "+OemToAnsi(Alltrim(TITSX3("QI2_CONTAT")[1])+": ")+QI2->QI2_CONTAT,131)+"|"	 
    	Endif
	Endif
    
	//�������������������������������������������������������������������������������Ŀ
	//� Verifica se FNC eh Sigilosa. Somente Responsavel e Digitador podem Imprimir   �
	//���������������������������������������������������������������������������������	
	lSigiloso := .f.
	
	If QI2->QI2_SIGILO == "1"	
		If ! (cMatFil+cMatCod == QI2->QI2_FILMAT+QI2->QI2_MAT .or. ;
		   	  cMatFil+cMatCod == QI2->QI2_FILRES+QI2->QI2_MATRES)
			lSigiloso := .T.
		Endif
	Endif

	If lSigiloso
		QImpr("|-"+OemToAnsi(STR0039)+Replicate("-",114)+"|","C")		// "Dados Sigilosos"
		QImpr("|"+Space(130)+"|","C")
		nPos := TamSx3("QAA_NOME")[1]
		QImpr("| "+OemToAnsi(STR0040 + Posicione("QAA",1, QI2->QI2_FILMAT+QI2->QI2_MAT,"QAA_NOME"))+Space(110-nPos)+"|","C")		// "Acesso Permitido a "
		QImpr("| "+OemToAnsi(STR0041 + Posicione("QAA",1, QI2->QI2_FILRES+QI2->QI2_MATRES,"QAA_NOME"))+Space(127-nPos)+"|","C")		// "e "
	Else

		//��������������������������������������������������������������Ŀ
	 	//� Imprime a Descricao Detalhada                                �
		//����������������������������������������������������������������
		cTxtDet := MSMM(QI2->QI2_DDETA)
		If !Empty(cTxtDet)
			aTxtDet := {}
			Q_MemoArray(cTxtDet, @aTxtDet, 128)
			If Len(aTxtDet) > 0
				QImpr("|-"+OemToAnsi(STR0027)+Replicate("-",110)+"|","C")		// "Descricao Detalhada"
				QImpr("|"+Space(130)+"|","C")
				For nT:=1 to Len(aTxtDet)
					QImpr("| "+aTxtDet[nT]+" |","C")
				Next
				QImpr("|"+Space(130)+"|","C")
		    Endif
		Endif

		//��������������������������������������������������������������Ŀ
	 	//� Imprime a Descricao dos Comentarios                          �
		//����������������������������������������������������������������
		cTxtDet  := MSMM(QI2->QI2_COMEN)
		If !Empty(cTxtDet)
			aTxtDet := {}
			Q_MemoArray(cTxtDet, @aTxtDet, 128)
			If Len(aTxtDet) > 0
				QImpr("|-"+OemToAnsi(STR0028)+Replicate("-",118)+"|","C")		// "Comentarios"
				QImpr("|"+Space(130)+"|","C")
				For nT:=1 to Len(aTxtDet)
					QImpr("| "+aTxtDet[nT]+" |","C")
				Next
				QImpr("|"+Space(130)+"|","C")
		    Endif
		Endif
	
		//��������������������������������������������������������������Ŀ
	 	//� Imprime a Descricao da Disposicao                            �
		//����������������������������������������������������������������
		cTxtDet := MSMM(QI2->QI2_DISPOS)
		If !Empty(cTxtDet)
			aTxtDet := {}
			Q_MemoArray(cTxtDet, @aTxtDet, 128)
			If Len(aTxtDet) > 0
				QImpr("|-"+OemToAnsi(STR0029)+Replicate("-",119)+"|","C")		// "Disposicao"
				QImpr("|"+Space(130)+"|","C")
				For nT:=1 to Len(aTxtDet)
					QImpr("| "+aTxtDet[nT]+" |","C")
				Next
				QImpr("|"+Space(130)+"|","C")
		    Endif
		Endif
	
		QImpr("|-"+OemToAnsi(STR0030)+Replicate("-",122)+"|","C")		// "Analise"
		QImpr("|"+Space(130)+"|","C")
	
		QImpr("| "+OemToAnsi(STR0031)+QI2->QI2_CODDIS+"-"+PADR(FQNCCHKDIS(QI2->QI2_CODDIS),38)+" "+;					// "Disposicao: "
					(TitSX3("QI2_CODORI")[1])+":"+QI2->QI2_CODORI+"-"+PADR(FQNCNTAB("3",QI2->QI2_CODORI),50)+"  |","C")			// "Origem: "
	    
		QImpr("| "+OemToAnsi(STR0033)+QI2->QI2_CODCAU+"-"+PADR(FQNCNTAB("1",QI2->QI2_CODCAU),43)+" "+;				// "Causa: "
					OemToAnsi(STR0034)+QI2->QI2_CODEFE+"-"+PADR(FQNCNTAB("2",QI2->QI2_CODEFE),50)+"  |","C")			// "Efeito: "
	
		QImpr(PADR("| "+OemToAnsi(STR0035)+QI2->QI2_CODCAT+"-"+PADR(FQNCNTAB("4",QI2->QI2_CODCAT),50),131)+"|","C")	// "Categoria FNC: "
	
		//��������������������������������������������������������������Ŀ
	 	//� Imprime os Plano de Acao Relacionadas                        �
		//����������������������������������������������������������������
		If nRelac == 1	// Sim
	
			If QI9->(dbSeek(QI2->QI2_FILIAL + QI2->QI2_FNC + QI2->QI2_REV))
				QImpr("|"+Space(130)+"|","C")
				QImpr("|-"+OemToAnsi(STR0036)+Replicate("-",129-Len(OemToAnsi(STR0036)))+"|","C")		// "Plano de Acao Relacionados"	
				QImpr(Padr("| "+OemToAnsi(STR0037),131)+"|","C")				// "No.A.C.     Rv Originador                     Abertura    Encerr.Previsto   Encerr.Real"
				QImpr("|"+Space(130)+"|","C")
				While !Eof() .And. QI9->QI9_FILIAL + QI9->QI9_FNC + QI9->QI9_REVFNC == QI2->QI2_FILIAL + QI2->QI2_FNC + QI2->QI2_REV
					IF QI3->(dbSeek(QI9->QI9_FILIAL+Right(QI9->QI9_CODIGO,4)+QI9->QI9_CODIGO+QI9->QI9_REV))
						QImpr(Padr("| "+Transform(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+" "+QI3->QI3_REV+" "+;
							  Padr(QA_NUSR(QI3->QI3_FILMAT,QI3->QI3_MAT,.F.),30)+" "+;
							  PADR(DTOC(QI3->QI3_ABERTU),10)+"  "+PADR(DTOC(QI3->QI3_ENCPRE),10)+Space(8)+PADR(DTOC(QI3->QI3_ENCREA),10),131)+"|","C")
					Endif
					QI9->(dbSkip())
				Enddo
			Endif
		Endif	
	Endif
    IF Li < 60
		QImpr("|"+Space(130)+"|","C")
		QImpr(" "+Replicate("-",130)+" ","C")
		QImpr("","P")
	Endif
	QI2->(dbSkip())
Enddo

If !lFirst
	Roda(0," ",nTamanho)
Endif

//��������������������������������������������������������������Ŀ
//� Termino do relatorio                                         �
//����������������������������������������������������������������
QI9->(dbSetOrder(1))

dbSelectArea("QI2")
Set Filter to
dbSetOrder(1)
Set Device To Screen
If aReturn[5] == 1
	Set Printer To
	dbCommit()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return Nil
