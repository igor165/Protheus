#INCLUDE "plsr420n.ch"
#include "PROTHEUS.CH"   

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PLSR420N � Autor � Luciano Aparecido     � Data � 13.08.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Guia de Internacao Hospitalar /Resumo Interna��o           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PLSR420(nGuia)                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSR420N(nGuia,cPathRelW,lOldPror)        

	//��������������������������������������������������������������Ŀ
	//� Define Variaveis                                             �
	//����������������������������������������������������������������
	Local CbCont, Cabec1, Cabec2, Cabec3, nPos, wnRel
	Local cTamanho := "M"
	Local cTitulo  := ""
	Local cDesc1  := ""
	Local cDesc2  := STR0003 //"de acordo com a configuracao do usuario."
	Local cDesc3  := " "
	Local nLayout
	
	Default cPathRelW:=""
	Default lOldPror := .F.
	Private aReturn  := { "Zebrado", 1,"Administra��o", 2, 2, 1, "", 1 }
	Private aLinha   := { }
	Private nLastKey := 0
	Private cPerg    := ""	
	Private lWeb     := IsInCallStack("u_PPRELPRG")
	
	If     nGuia ==1
		cTitulo  := STR0004 //"GUIA DE SOLICITA��O INTERNA��O"
		cDesc1  := STR0005 //"Ira imprimir a Guia de Solicita��o Interna��o"
	ElseIf nGuia ==2
		cTitulo  := STR0006 //"GUIA DE RESUMO INTERNA��O"
		cDesc1  := STR0007 //"Ira imprimir a Guia de Resumo Interna��o"  
	Else
		cTitulo  := "GUIA DE SOLICITA��O DE PRORROGA��O DE INTERNA��O" 
		cDesc1  := "Ira imprimir a Guia de Solicita��o de Interna��o"  
	Endif
	
	cPerg := "PL420N"
	
	IF (cPathRelW <> "NR")	
		If ! (BE4->BE4_STATUS $ "1,2,3,4")
			Help("",1,"PLSR420")
			Return
		EndIf   
	endif	  
		
	//��������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
	//����������������������������������������������������������������
	CbCont  := 0
	
	if nGuia ==1
		Cabec1  := STR0008 //"GUIA DE INTERNA�AO HOSPITALAR"
	elseIf nGuia ==2
		Cabec1  := STR0009 //"GUIA DE RESUMO INTERNA�AO"
	Else
		Cabec1  := "GUIA DE SOLICITA��O DE PRORROGA��O DE INTERNA��O OU COMPLEMENTA��O DO TRATAMENTO"
	Endif
	
	Cabec2  := " "
	Cabec3  := " "
	cString := "BE4"
	aOrd    := {}
	wnRel   := "PLSR420" // Nome Default do relatorio em Disco
	 
	If nGuia == 1
		Pergunte(cPerg,.F.)	
		cMail	:= mv_par03
	ElseIf nGuia == 2	
		Pergunte(cPerg,.F.)
		If nLastKey = 27
			Set Filter To
			Return
		EndIf
		cMail	:= mv_par03	   
	Else
		cMail	:= ""
		IF (cPathRelW <> "NR")  //Para n�o exibir o pergunte aqui.
			cPerg:='PL420G'

		   	IF !lWeb
				If !Pergunte(cPerg,.T.) 
					Return
				EndIf
			Endif	
			If nLastKey = 27
				Set Filter To
				Return
			EndIf  
			cMail	:= ""	   
		ENDIF   
	EndIf
		
	nLayout := 2
	nMail	:= 2

	IF !lWeb
		RptStatus({|lEnd| R420NImp(@lEnd,wnRel,cString,nGuia,nLayout,nMail,cMail,nil,lOldPror)}, cTitulo)
	Else
		aRet:=R420NImp(@lEnd,wnRel,cString,nGuia,nLayout,nMail,cMail,cPathRelW,lOldPror)
		If Len(aRet)= 3
			Return(aRet)
		Endif
	Endif	
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � R420NIMP � Autor � Sandro Hoffman Lopes  � Data � 19/10/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR420N                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function R420NImp(lEnd,wRel,cString,nGuia,nLayout,nMail,cMail,cPathRelW,lOldPror)

	LOCAL aDados  := {}
	LOCAL aRetPto := {}             
	LOCAL aRet	  := {}
	DEFAULT nMail := 0
	DEFAULT cMail := ""
	DEFAULT cPathRelW:=""
	DEFAULT lOldPror := .F.
		
	aAdd(aDados, MtaDados(nGuia,lOldPror))
    
    If ExistBlock("PLS420IM")
       aRetPto := ExecBlock("PLS420IM",.F.,.F.,{nGuia,aDados})
       aDados := aRetPto[1]
    Endif   

	If nGuia == 1
	    If PLSTISSVER() >= "3"
			aRet:=PlsTISSE(aDados,,nLayout,,mv_par02==1)
		Else
			aRet:=PlsTISS3(aDados,,nLayout,,mv_par02==1)
		EndIf
	    If aRet[1] 	   
	    	If Pergunte(cPerg,.T.) 
				If mv_par02 == 1
					If PLSTrtMAIL(AllTrim(mv_par03),aRet[2])
						Aviso("Aten��o","E-mail enviado com sucesso!",{"Ok"},1)
					EndIf
				EndIf
			Endif
		Endif		
	ElseIf nGuia == 2
		If PLSTISSVER() >= "3"
			PLSTISSF(aDados,,nLayout)
		Else
			PlsTISS4(aDados,,nLayout)
		EndIf 
	ElseIf nGuia == 3
		If lWeb
			aRet:=PLSTISSP(aDados,,nLayout,,,lWeb,cPathRelW)
			Return(aRet)
		Else
			If PLSTISSVER() >= "3"
				PLSTISSP(aDados,,nLayout)
			Else
				PlsTISS4(aDados,,nLayout)
			EndIf
		Endif	 
	EndIf  
	
	MS_FLUSH()
		
Return
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � MtaDados � Autor � Luciano Aparecido       � Data � 22/03/07 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Grava STATUS das tabelas BE4/BEA e chama a funcao "PLSGINT"  ���
���          � que ira retornar o array com os dados a serem impressos.     ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR420N                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MtaDados(nGuia,lOldPror)

	Local aDados := {}
	Default lOldPror := .F.

	DbSelectArea("BE4")
	BE4->(RecLock("BE4",.F.))
	BE4->BE4_GUIIMP := "1"
	If BE4->BE4_STATUS == "4"
		BE4->BE4_STATUS := "1"
	EndIf
	BE4->(MsUnLock())
	
	BEA->(DbSetOrder(6))
	If BEA->(DbSeek(xFilial("BEA")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
		BEA->(RecLock("BEA",.F.))
		BEA->BEA_GUIIMP := "1"
		If BEA->BEA_STATUS == "4"
			BEA->BEA_STATUS := "1"
		EndIf   
		BEA->(MsUnLock())        
	EndIf
	
	aDados := PLSGINT(nGuia,lOldPror) // Funcao que monta o array com os dados da guia
	
Return aDados 