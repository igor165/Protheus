#Include "PROTHEUS.CH"
#INCLUDE "QNCR010.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QNCR010  � Autor � Aldo Marini Junior    � Data � 08.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Plano de Acao                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QNCR010(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Aldo        �22/08/01� 9495 � Alterado para imprimir cabecalho grafico ���
���Eduardo S.  �12/12/02�061393� Acerto para filtrar corretamente a etapa.���
���Eduardo S.  �12/12/02�062109� Incluido o pergunta "Plano de Acao" (Pen-���
���            �        �      � dente / Baixado / Ambos).                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function QNCR010

//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais (Basicas)                            �
//����������������������������������������������������������������
Local cDesc1 	:= STR0001		//"Relatorio de Plano de Acao"
Local cDesc2 	:= STR0002		//"Ser� impresso de acordo com os parametros solicitados pelo usuario."
Local cDesc3 	
Local cString	:= "QI3"       				// alias do arquivo principal (Base)
Local aOrd      := {STR0003,STR0004}		//"Ano+Plano de Acao+Revisao"###"Plano de Acao+Revisao"
Local wnRel

//��������������������������������������������������������������Ŀ
//� Define Variaveis Private(Basicas)                            �
//����������������������������������������������������������������
Private aReturn  := { STR0005, 1,STR0006, 2, 2, 1,"",1 }	//"Zebrado"###"Administra��o"
Private nomeprog := "QNCR010"
Private aLinha   := {}
Private nLastKey := 0
Private cPerg    := "QNR010"
Private lFirst   := .T.

//��������������������������������������������������������������Ŀ
//� Variaveis Utilizadas na funcao IMPR                          �
//����������������������������������������������������������������
Private Titulo	 := STR0007		//"PLANO DE ACAO"
Private cCabec
Private AT_PRG  := "QNCR010"
Private wCabec0 := 3
Private wCabec1 := ""
Private	wCabec2	:= Padr("| ",131)+"|"
Private wCabec3 := ""
Private CONTFL  := 1
Private LI      := 0
Private nTamanho:= "M"
Private lTMKPMS := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS �

//��������������������������������������������������������������Ŀ
//� Define Variaveis Private(Programa)                           �
//����������������������������������������������������������������
Private nOrdem

INCLUI := .F.	// Utilizado devido algumas funcoes de retorno de descricao/nome
                                       	
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("QNR010",.F.)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01        //  Filial  De                               �
//� mv_par02        //  Filial  Ate                              �
//� mv_par03        //  Ano De                                   �
//� mv_par04        //  Ano Ate                                  �
//� mv_par05        //  Plano de Acao                            �
//� mv_par06        //  Plano de Acao                            �
//� mv_par07        //  Revisao De                               �
//� mv_par08        //  Revisao Ate                              �
//� mv_par09        //  Etapas 1-Pendentes/2-Baixadas/3-Ambas    �
//� mv_par10        //  Acoes 1-Corretiva/2-Preventiva/3-Melhoria/4-Ambas
//� mv_par11        //  Status Acoes 1-Registrada/2-Em Analise/3-Procede/4-Nao Procede/5-Cancelada/6-Ambas
//� mv_par12        //  FNC Relacionadas 1-Sim/2-Nao			 |
//� mv_par13        //  Plano de Acao (1=Pendente/2=Baixado/3=Ambos)
//� mv_par14        //  Imprime Custo? Sim/Nao                   |
//� mv_par15        //  Cliente De                               |
//� mv_par16        //  Loja De                                  |
//� mv_par17        //  Cliente Ate                              |
//� mv_par18        //  Loja Ate                                 |
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel:="QNCR010"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

//��������������������������������������������������������������Ŀ
//� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
//����������������������������������������������������������������
nOrdem   := aReturn[8]
cFilDe   := mv_par01
cFilAte  := mv_par02
cAnoDe   := mv_par03
cAnoAte  := mv_par04
cAcaoDe  := mv_par05
cAcaoAte := mv_par06
cRevDe   := mv_par07
cRevAte  := mv_par08
nEtapa   := mv_par09
nAcao    := mv_par10
cStatus  := mv_par11
nRelac   := mv_par12
cImpCus	 := mv_par14

If	nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If	nLastKey == 27
	Return
Endif

RptStatus({|lEnd| QNCR010Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QNCR010Imp� Autor � Aldo Marini Junior    � Data � 08.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o Relatorio                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �QNCR010Imp(lEnd,wnRel,cString)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd        - A��o do Codelock                             ���
���          � wnRel       - T�tulo do relat�rio                          ���
���Parametros� cString     - Mensagem                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QNCR010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function QNCR010Imp(lEnd,WnRel,cString)

Local aTipQI3 := {OemToAnsi(STR0008),OemToAnsi(STR0009),OemToAnsi(STR0010)}	// "Corretiva" ### "Preventiva" ### "Melhoria"
Local aStatus := {OemtoAnsi(STR0011),OemToAnsi(STR0012),OemToAnsi(STR0013),OemToAnsi(STR0014),OemToAnsi(STR0015)}	// "Registrada" ### "Em Analise" ### "Procede" ### "Nao Procede" ### "Cancelada"
Local cTxtDet := ""
Local aTxtDet := {}
Local lPend   := .F.
Local cFiltro := "" 
Local cIndex1 := CriaTrab( Nil, .f. )
Local nT
Local cDescDet:= ""
Local aDescDet:= {} 

Local aUsrMat	:= QNCUSUARIO()
Local cMatFil  	:= aUsrMat[2]
Local cMatCod	:= aUsrMat[3]
Local lSigiloso := .F. 
Local cCodCli   := ""
Local cLojCli   := ""
Local nMVQTMKPMS := GetMv("MV_QTMKPMS",.F.,1)

dbSelectArea( "QI3" )
If nOrdem == 1
	QI3->(dbSetOrder( 1 ))
ElseIf nOrdem == 2
	QI3->(dbSetOrder( 2 ))
EndIf

cFiltro:= '( QI3->QI3_ANO >= "'+ cAnoDe  +'" ) .And. '
cFiltro+= '( QI3->QI3_ANO <= "'+ cAnoAte +'" ) .And. '
cFiltro+= '( QI3->QI3_REV >= "'+ cRevDe  +'" ) .And. '
cFiltro+= '( QI3->QI3_REV <= "'+ cRevAte +'" ) .And. '
If !lTMKPMS 
	cFiltro+= '( Right(Alltrim(QI3->QI3_CODIGO),4) + Left(QI3->QI3_CODIGO,15) >= "'+ Right(Alltrim(cAcaoDe ),4) + Left(cAcaoDe ,15) + '" ) .And. '
	cFiltro+= '( Right(Alltrim(QI3->QI3_CODIGO),4) + Left(QI3->QI3_CODIGO,15) <= "'+ Right(Alltrim(cAcaoAte),4) + Left(cAcaoAte,15) + '" ) '
Else
	cFiltro+= '( Right(Alltrim(QI3->QI3_CODIGO),4) + Left(QI3->QI3_CODIGO,11) >= "'+ Right(Alltrim(cAcaoDe ),4) + Left(cAcaoDe ,11) + '" ) .And. '
	cFiltro+= '( Right(Alltrim(QI3->QI3_CODIGO),4) + Left(QI3->QI3_CODIGO,11) <= "'+ Right(Alltrim(cAcaoAte),4) + Left(cAcaoAte,11) + '" ) '
Endif

If mv_par13 == 1
	cFiltro+= ' .And. Empty(QI3->QI3_ENCREA)'
ElseIf mv_par13 == 2
	cFiltro+= ' .And. !Empty(QI3->QI3_ENCREA)'
EndIf

cFiltro+= ' .And. QI3->QI3_STATUS $ "'+ cStatus + '"'

QI3->(DbSeek(xFilial("QI3")))
If nOrdem == 1
	QI3->(dbSeek(IF((FWModeAccess("QI3") == "C"),xFilial("QI3"),cFilDe) + cAnoDe + cAcaoDe + cRevDe,.T.))
	cInicio  := "QI3->QI3_FILIAL + QI3->QI3_ANO + QI3->QI3_CODIGO + QI3->QI3_REV"
	cFim     := IF((FWModeAccess("QI3") == "C"),xFilial("QI3"),cFilAte) + cAnoAte + cAcaoAte + cRevAte
ElseIf nOrdem == 2
	QI3->(dbSeek(IF((FWModeAccess("QI3") == "C"),xFilial("QI3"),cFilDe) + cAcaoDe + cRevDe,.T.))
	cInicio  := "QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV"
	cFim     := IF((FWModeAccess("QI3") == "C"),xFilial("QI3"),cFilAte) + cAcaoAte + cRevAte
Endif

While !EOF() .And. &cInicio <= cFim
	If !&(cFiltro)
		QI3->(DbSkip())
		Loop
	EndIf

	lPend:= .F.

	If lEnd
		@Prow()+1,0 PSAY cCancel
		Exit
	Endif

	//��������������������������������������������������������������Ŀ
 	//� Consiste o tipo de Plano de Acao                             �
	//����������������������������������������������������������������
	If nAcao <> 4 .And. Val(QI3->QI3_TIPO) <> nAcao
		dbSkip()
		Loop
	Endif
          
	//��������������������������������������������������������������Ŀ
 	//� Realiza o Filtro do Cliente                                  �
	//����������������������������������������������������������������
	QI2->(DbSetOrder(5))      //QI2_FILIAL+QI2_CODACA+QI2_REVACA                                
	If QI2->(DbSeek(xFilial("QI2")+QI3->QI3_CODIGO))
   		ADE->(DbSetOrder(1))  //ADE_FILIAL+ADE_CODIGO
		If ADE->(dbSeek(xFilial("ADE")+QI2->QI2_NCHAMA))
			If (AllTrim(ADE->ADE_CHAVE) < mv_par15+mv_par16 .OR. AllTrim(ADE->ADE_CHAVE) > mv_par17+mv_par18)
				QI3->(dbSkip())
				Loop
			Else
				cCodCli:= Left(ADE->ADE_CHAVE,TAMSX3("A1_COD")[1])
				cLojCli:= Substr(ADE->ADE_CHAVE,TAMSX3("A1_COD")[1]+1,TAMSX3("A1_LOJA")[1])
			Endif
		ElseIf QI2->(QI2_CODCLI+QI2_LOJCLI) < mv_par15+mv_par16 .Or. QI2->(QI2_CODCLI+QI2_LOJCLI) > mv_par17+mv_par18
			QI3->(dbSkip())
			Loop
		Else
			cCodCli:= QI2->QI2_CODCLI
			cLojCli:= QI2->QI2_LOJCLI
		Endif
	Endif

	If nEtapa == 1 // Pendente
		If QI5->(DbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
			While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
				If QI5->QI5_STATUS <> "4"
					lPend:= .T.
					Exit
				EndIf
				QI5->(DbSkip())
			EndDo		
		EndIf			

	ElseIf nEtapa == 2 // Baixada
		If QI5->(DbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
			While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
				If QI5->QI5_STATUS == "4"
					lPend:= .T.
					Exit
				EndIf
				QI5->(DbSkip())
			EndDo		
		EndIf			
	Else 
		lPend:= .T.
	EndIf

	If !lPend
		DbSkip()
		Loop
	EndIf

	WCabec1	:= Padr("| "+OemToAnsi(STR0016)+TransForm(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"  "+;			// "No. "
				OemToAnsi(STR0017)+QI3->QI3_REV+"   "+OemToAnsi(STR0018)+PADR(DTOC(QI3->QI3_ABERTU),10)+;		// "Revisao: " ### "Data Abertura: "
				"   "+OemToAnsi(STR0019)+PADR(DTOC(QI3->QI3_ENCREA),10)+"   "+OemToAnsi(STR0020)+;	// "Data Encerramento: " ### "Acao "
				Padr(aTipQI3[Val(QI3->QI3_TIPO)],10),131)+"|"
				
	//�������������������������������������������������������������������������������������Ŀ
	//� Verifica se h� Integra��o TMK/QNC/PMS. Caso afirmativo Imprime o Nome/C�d Cliente   �
	//���������������������������������������������������������������������������������������
	If (nMVQTMKPMS == 4)
		WCabec3	:= Padr("| "+OemToAnsi(STR0021)+Padr(QA_NUSR(QI3->QI3_FILMAT,QI3->QI3_MAT,.F.),30)+SPACE(2)+OemToAnsi(STR0022)+Padr(aStatus[Val(QI3->QI3_STATUS)],11)+; // "Responsavel: " ### "Status: "
							Space(2)+OemToAnsi(STR0041)+": "+cCodCli+"/"+cLojCli+"-"+FQNCDESCLI(cCodCli,cLojCli,"1"),131)+"|"
	Else
		WCabec3	:= Padr("| "+OemToAnsi(STR0021)+QA_NUSR(QI3->QI3_FILMAT,QI3->QI3_MAT,.F.)+SPACE(34)+OemToAnsi(STR0022)+aStatus[Val(QI3->QI3_STATUS)],131)+"|"	// "Responsavel: " ### "Status: "
	EndIf
	
	//�������������������������������������������������������������������������������������Ŀ
	//� Verifica se Plano eh Sigiloso. Somente Responsavel (plano e etapas) pode Imprimir   �
	//���������������������������������������������������������������������������������������	
	lSigiloso := .f.

	If QI3->QI3_SIGILO == "1"	
		If cMatFil+cMatCod <> QI3->QI3_FILMAT+QI3->QI3_MAT 
			lSigiloso := .T.
			QI5->(dbSetOrder(1))
			If QI5->(dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
				While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
					If QI5->QI5_FILMAT + QI5->QI5_MAT == cMatFil + cMatCod 
						lSigiloso := .f.
						Exit
					Endif
					QI5->(dbSkip())
				Enddo
			Endif							
		Endif
	Endif
	
	If lSigiloso
		QImpr("|-"+OemToAnsi(STR0038)+Replicate("-",114)+"|","C")		// "Dados Sigilosos"
		QImpr("|"+Space(130)+"|","C")
		nPos := TamSx3("QAA_NOME")[1]
		QImpr("| "+OemToAnsi(STR0039 + Posicione("QAA",1, QI3->QI3_FILMAT+QI3->QI3_MAT,"QAA_NOME")+ STR0040)+Space(78-nPos)+"|","C")		// "Acesso permitido a " ### " e aos respons�veis pelas etapas"
	Else

	//��������������������������������������������������������������Ŀ
 	//� Imprime a Descricao Detalhada                                �
	//����������������������������������������������������������������

	cTxtDet := MSMM(QI3->QI3_PROBLE)
	If !Empty(cTxtDet)
		aTxtDet := {}
		Q_MemoArray(cTxtDet, @aTxtDet, 128)
		If Len(aTxtDet) > 0
			QImpr("|-"+OemToAnsi(STR0023)+Replicate("-",110)+"|","C")		// "Descricao Detalhada"
			QImpr("|"+Space(130)+"|","C")
			For nT:=1 to Len(aTxtDet)
				QImpr("| "+aTxtDet[nT]+" |","C")
			Next
	    Endif
	Endif
    
	//��������������������������������������������������������������Ŀ
 	//� Imprime a Descricao Resumida das Possiveis Causas            �
	//����������������������������������������������������������������
	If QI6->(dbSeek( QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV ))
		QImpr("|"+Space(130)+"|","C")
		QImpr("|-"+OemToAnsi(STR0024)+Replicate("-",113)+"|","C")				// "Possiveis Causas"
		QImpr(Padr("| "+OemToAnsi(STR0035),131)+"|","C")//"Causa                                                Descricao detalhada"
		QImpr("|"+Space(130)+"|","C")
		While !Eof() .And. QI6->QI6_FILIAL + QI6->QI6_CODIGO + QI6->QI6_REV == QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV
		   	cDescDet := MSMM(QI6->QI6_DESCR)

			If !Empty(cDescDet)
				aDescDet := {}
				Q_MemoArray(cDescDet, @aDescDet, 75)
				For nT:=1 to Len(aDescDet)
					If nT == 1
						QImpr(PADR("| "+QI6->QI6_SEQ+" "+FQNCNTAB("1",QI6->QI6_CAUSA)+Alltrim(aDescDet[nT]),131)+"|","C")	
					Else
						QImpr("| "+Space(53) +aDescDet[nT]+" |","C")
					Endif	
				Next
			Endif

			QI6->(dbSkip())
		Enddo
	Endif

	//��������������������������������������������������������������Ŀ
 	//� Imprime as Etapas das Acoes                                  �
	//����������������������������������������������������������������
	IF QI5->(dbSeek( QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV ))
		QImpr("|"+Space(130)+"|","C")
		QImpr("|-"+OemToAnsi(STR0025)+Replicate("-",124)+"|","C")				// "Acoes"
		QImpr(Padr("| "+OemToAnsi(STR0026),131)+"|","C")  					// "Responsavel                    Previsao   Conclusao   Descricao"
		QImpr("|"+Space(130)+"|","C")
		While !Eof() .And. QI5->QI5_FILIAL + QI5->QI5_CODIGO + QI5->QI5_REV == QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV
         IF nEtapa == 3 .Or. ;
            ( nEtapa == 1 .And. QI5->QI5_STATUS <> "4" ) .Or. ;
            ( nEtapa == 2 .And. QI5->QI5_STATUS == "4" ) 
				QImpr(PADR("| "+PADR(QA_NUSR(QI5->QI5_FILMAT,QI5->QI5_MAT,.F.),30)+" "+PADR(DTOC(QI5->QI5_PRAZO),10)+" "+PADR(DTOC(QI5->QI5_REALIZ),10)+"  "+QI5->QI5_DESCRE,131)+"|","C")
			Endif
			QI5->(dbSkip())
		Enddo
	Endif

	//��������������������������������������������������������������Ŀ
 	//� Imprime a Descricao do Resultado Esperado                    �
	//����������������������������������������������������������������

	cTxtDet := MSMM(QI3->QI3_RESESP)
	If !Empty(cTxtDet)
		aTxtDet := {}
		Q_MemoArray(cTxtDet, @aTxtDet, 128)
		If Len(aTxtDet) > 0
			QImpr("|"+Space(130)+"|","C")
			QImpr("|-"+OemToAnsi(STR0027)+Replicate("-",111)+"|","C")		// "Resultado Esperado"
			QImpr("|"+Space(130)+"|","C")
			For nT:=1 to Len(aTxtDet)
				QImpr("| "+aTxtDet[nT]+" |","C")
			Next
	    Endif
	Endif
	
	//��������������������������������������������������������������Ŀ
 	//� Imprime a Descricao do Resultado Atingido                    �
	//����������������������������������������������������������������

	cTxtDet := MSMM(QI3->QI3_RESATI)
	If !Empty(cTxtDet)
		aTxtDet := {}
		Q_MemoArray(cTxtDet, @aTxtDet, 128)
		If Len(aTxtDet) > 0
			QImpr("|"+Space(130)+"|","C")
			QImpr("|-"+OemToAnsi(STR0028)+Replicate("-",111)+"|","C")		// "Resultado Atingido"
			QImpr("|"+Space(130)+"|","C")
			For nT:=1 to Len(aTxtDet)
				QImpr("| "+aTxtDet[nT]+" |","C")
			Next
	    Endif
	Endif

	//�����������������������������������������������������������������Ŀ
 	//� Imprime as Fichas de Ocorrencias/Nao-conformidades Relacionadas �
	//�������������������������������������������������������������������        
	QI2->(DbSetOrder(1))
	If nRelac == 1	// Sim
		If QI9->(dbSeek(QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV))
			QImpr("|"+Space(130)+"|","C")
			QImpr("|-"+OemToAnsi(STR0029)+Replicate("-",129-Len(OemToAnsi(STR0029)))+"|","C")		// "Ficha Ocorrencias/Nao-conformidades Relacionadas"	
			QImpr(Padr("| "+OemToAnsi(STR0030),131)+"|","C")				// "No.FNC.     Rv Originador                     Abertura   Descricao"
			QImpr("|"+Space(130)+"|","C")
			While !Eof() .And. QI9->QI9_FILIAL + QI9->QI9_CODIGO + QI9->QI9_REV == QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV
				IF QI2->(dbSeek(QI9->QI9_FILIAL+Right(QI9->QI9_FNC,4)+QI9->QI9_FNC+QI9->QI9_REVFNC))
					QImpr(Padr("| "+Transform(QI2->QI2_FNC,PesqPict("QI2","QI2_FNC"))+" "+QI2->QI2_REV+" "+;
						  Padr(QA_NUSR(QI2->QI2_FILMAT,QI2->QI2_MAT,.F.),30)+" "+;
						  PADR(DTOC(QI2->QI2_OCORRE),10)+" "+QI2->QI2_DESCR,131)+"|" , "C")
				Endif
				QI9->(dbSkip())
			Enddo
			Endif
		Endif	
		If mv_par14 == 1
			IF QI8->(dbSeek( QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV ))
				QImpr("|"+Space(130)+"|","C")
				QImpr("|"+OemToAnsi(STR0036)+Replicate("-",124)+"|","C")	// "Custos"
				QImpr(Padr("| "+OemToAnsi(STR0037),131)+"|","C")  			// "Descr��o           Vlr.Custo"
				QImpr("|"+Space(130)+"|","C")
				While !Eof() .And. QI8->QI8_FILIAL + QI8->QI8_CODIGO + QI8->QI8_REV == QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV
					QImpr("| "+Padr(FQNCDSX5("QB",QI8->QI8_CUSTO),53)+STR(QI8->QI8_VLCUST,10,2)+Space(66)+"|")
					QI8->(dbSkip())
				Enddo
			Endif           
		Endif
    Endif
    IF Li < 60
		QImpr("|"+Space(130)+"|","C")	
		QImpr(" "+Replicate("-",130)+" ","C")
		QImpr("","P")
	Endif
	dbSkip()
Enddo

If !lFirst
	Roda(0," ",nTamanho)
Endif

//��������������������������������������������������������������Ŀ
//� Devolve as ordens originais dos arquivos                     �
//����������������������������������������������������������������
RetIndex("QI3")
Set Filter to

//��������������������������������������������������������������Ŀ
//� Apaga indices de trabalho                                    �
//����������������������������������������������������������������
cIndex1 += OrdBagExt()
Delete File &(cIndex1)

Set Device To Screen

If aReturn[5] == 1
	Set Printer To
	dbCommit()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return Nil
