#INCLUDE "PROTHEUS.ch"
#INCLUDE 'FILEIO.CH'    
#INCLUDE 'QPPM040.CH'    
                                                                             
#Define PARETO "6"      

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � QPPM040	  � Autor � Cleber Souza          � Data � 17/08/05 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Grafico de Pareto - FMEA�s Processo e Projeto.        	    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPM040()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros� EXPC1 = Numero da Peca      								    ���
���			 � EXPC2 = Revisao da Pecao 								    ���
���			 � EXPC3 = Tipo do Grafico (1= Projeto, 2= Processo)		    ���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAPPAP				                 					    ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS  � MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function QPPM040(cPeca,cRevisao,cTipo)

Local cPerg     := "QPPM40"
Private aNPR    := {}
Private aDados  :={}

If Pergunte(cPerg,.T.) 
	QPPM40PROC(cPeca,cRevisao,cTipo)
EndIF

Return          

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QPPM40PROC�Autor  �Cleber Souza        � Data �  17/08/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Gera��o do Grafico de Pareto.                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � QPPM040                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function QPPM40PROC(cPeca,cRevisao,cTipo) 

Local nI       := 0
Local cArqSPC  := "" 
Local cDir	   := GetMv("MV_QDIRGRA")   //Diretorio para geracao do grafico
Local cSenhas  := "1"
	      
// Verifica se o diretorio do grafico �  um  diretorio Local
If !QA_VerQDir(cDir) 
	Return
EndIf

If cTipo=="1"
	//Pesquisa dados referentes ao projeto
	DbSelectArea("QK6")
	DbSetOrder(4)
	DbSeek(xFilial("QK6")+cPeca+cRevisao)

	While !Eof() .and. cPeca+cRevisao == QK6->QK6_PECA+QK6->QK6_REV
    	AADD(aNPR,{QK6->QK6_SEQ,IIF(mv_par01==1,QK6->QK6_NPR,QK6->QK6_RNPR)})
    	QK6->(dbSkip())
    EndDo 
    
Else
	//Pesquisa dados referentes ao projeto
	DbSelectArea("QK8")
	DbSetOrder(4)
	DbSeek(xFilial("QK8")+cPeca+cRevisao)

	While !Eof() .and. cPeca+cRevisao == QK8->QK8_PECA+QK8->QK8_REV
    	AADD(aNPR,{QK8->QK8_SEQ,IIF(mv_par01==1,QK8->QK8_NPR,QK8->QK8_RNPR)})
    	QK8->(dbSkip())
    EndDo 

EndIf

//��������������������������������������Ŀ
//� Organiza array com as NPRs.		     �
//����������������������������������������
If mv_par02==2
	aNPR := aSort(aNPR,,, { | x,y | x[2] < y[2] })
ElseIf mv_par02==3
   	aNPR := aSort(aNPR,,, { | x,y | x[2] > y[2] })
EndIF

//��������������������������������������Ŀ
//� Monta vetor com os dados do grafico  �
//����������������������������������������
Aadd(aDados,"QACHART.DLL - PARETO")

//Define Texto do Titulo
aAdd( aDados,"[TITLE]" )

If cTipo=="1"
	aAdd( aDados,STR0001) //" - FMEA de Projeto"
Else
	aAdd( aDados,STR0002) //" - FMEA de Processo"
EndIF

Aadd(aDados,"[LANGUAGE]")
Aadd(aDados,Upper(__Language) )

//Tira a linha do Pareto
aAdd( aDados,"[LINHA PARETO]" )
aAdd( aDados,"FALSE" )

//Define o Rodape do grafico.
aAdd( aDados,"[FOOT]" )
aAdd( aDados,STR0003+Alltrim(cPeca)+STR0004+Alltrim(cRevisao) ) //"Peca: "###" Revisao: "

Aadd(aDados,"[DADOS PARETO]")

For nI := 1 to Len(aNPR)
	Aadd(aDados,AllTrim(aNPR[nI,2])+";"+Alltrim(aNPR[nI,1]))
Next nI

Aadd(aDados,"[FIM DADOS PARETO]")

// Gera o nome do arquivo SPC
cArqSPC := QPP40NoArq(cDir)

If !Empty(cArqSPC)
	//���������������������Ŀ
	//� Grava o arquivo SPC �
	//�����������������������
	QPP40GerAr(aDados ,cArqSPC, cDir)

	//��������������������������������������������������������������������������������������Ŀ
	//� Controle para abertura do grafico. Caso o grafico fique aberto por mais de 3 minutos �
	//� nao perca a conexao.																 �
	//����������������������������������������������������������������������������������������
	PtInternal(9,"FALSE")
		
	Calldll32("ShowChart",cArqSPC,PARETO,cDir,PARETO,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))

	// Exclui o arquivo SPC gerado	
	Ferase(cArqSPC)
	PtInternal(9,"TRUE")
Else
	MessageDlg(STR0005,,3)  //"N�o foram encontradas NPRs, a partir dos dados solicitados."
EndIf

Return
          

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QPP40NoArq� Autor � Cleber Souza          � Data � 17/08/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera nome do arquivo SPC									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QPPM040													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function QPP40NoArq(cDir)
Local cArq	:= ""
Local nI 	:= 0
//������������������������������������������������Ŀ
//� Verifica o arquivo disponivel com extensao SPC �
//��������������������������������������������������
For nI := 1 to 99999
	cArq := "QPP" + StrZero(nI,5) + ".SPC"
	If !File(Alltrim(cDir)+cArq)
		Exit
	EndIf
Next nI
Return cArq     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QPP40GerAr� Autor � Cleber Souza      	� Data �17/08/05  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava um arquivo Txt no formato da OCX QC_CHART		      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpA1 - Array com os dados a gravar						  ���
���			 �ExpC1 - Arquivo para dados								  ���
���			 �ExpC2 - Diretorio para gerar o arquivo					  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 �ExpL1 - TRUE - caso criou o arquivo corretamente e FALSE	  ���
���			 � caso tenha havido alguma falha							  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �Generico													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function QPP40GerAr( aDados , cFile , cDir )
Local lOk		:= .T.
Local nHandle	:= 0
Local nSec		:= 0

Default cFile	:= "QACHART.SPC"
Default aDados	:= { }

//�����������������������������������������Ŀ
//� Formato do array a ser passado		    �
//� Array de uma coluna contendo uma string �
//�������������������������������������������
If File( cDir+cFile )
	If FErase(cDir+cFile) == 0
		lOk := .T.
	else
		nSec := Seconds()
		While FErase(cDir+cFile) <> 0
			if Seconds() > nSec + 5
				lOk := .F.
				Exit
			Endif
		EndDo
		if !lOk
			MsgStop(STR0006,STR0007)	//"Outro usu�rio utilizando o arquivo. Tente novamente" #### "Aten��o"
		Endif
	Endif
Endif

If lOk
	IF (nHandle := FCREATE(cDir+cFile, FC_NORMAL)) == -1
		lOk := .F.
		MsgStop(STR0008 + cDir+cFile,STR0007) //"N�o foi poss�vel criar o arquivo para o gr�fico " #### "Aten��o" 
	Endif
Endif

If lOk
	aEval( aDados, { |cTexto,nX| FWrite( nHandle, cTexto + Chr(13)+Chr(10) ), Len(cTexto) } )
	FClose(nHandle)
Endif

Return lOk
