#Include "Rwmake.ch"        
#Include "IMPDARF.CH"

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���RdMake    � ImpDARF  � Autor � R.H. - Aldo               � Data � 22.10.97 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao da DARF em Formulario Continuo                       ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe e � Impdarf                                                        ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � RdMake                                                         ���
�����������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                 ���
�����������������������������������������������������������������������������Ĵ��
���Programador � Data   �   BOPS   �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������Ĵ��
���Marina      �30/08/00�----------�Retirada da parte DOS.                    ���
���Natie       �29/08/01�0000009963�PrnFlush-Descarrega spool impressao teste ���
���Natie       �12/12/01�0000009963�Acerto na impressao teste                 ���
���------------�13/01/03�----------�Rotina de Impressao Grafica               ���
���------------�16/03/04�    Melhor�Acerto impressao Zebrada                  ���
���------------�08/04/04�----------�Acerto no Driver p/Impressao              ���
���Renata Elena�06/08/07�0000129577�Ajuste na emissao grafica para SPOOL      ���
��|Natie       |03/01/11|0001952012|Impressao por Centro de custo (ch TEGZZK) ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
����������������������������������������������������������������������������������/*/
Function GPER989()

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������
SetPrvt("CCGC, LI, CSAVEMENUH, NOPCA")

If aInfo[15] == 1
	cCgc:=aInfo[8]
Else
	cCgc:=Transform(aInfo[8],"@R ##.###.###/####-##") // CGC
Endif


If nTipImp == 2
	//�������������������������������Ŀ
	//� Zebrada                       � 
	//���������������������������������
	fImpDpre()
Elseif nTipImp == 3
	//�������������������������������Ŀ
	//� Rotina de Impressao Grafica   � 
	//���������������������������������
	fImpGraf()
Endif

Return()        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fImpDpre  �Autor  �Recursos Humanos    � Data �  11/12/01   ���
�������������������������������������������������������������������������͹��
���Desc.     � Imprime Formulario Pre-impresso                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function  fImpDpre()
Local li := 25, nLiPadr := 25
Local lPagImpT := .T.
nOpca := 0

IF TYPE("NVEZ") == "U"	
	NVEZ  := 1
ENDIF

IF !TYPE("NLIDARF") == "U" .AND. NLIDARF > 0
	li := NLIDARF
ENDIF

IF TYPE("LIMPPRE") == "U" .OR. !LIMPPRE
	oPrint:StartPage()  //Inicio da P�gina
ENDIF

oPrint:SetPaperSize(1)
WHILE .T.
	// A cada 3 itens impressos, a rotina come�a uma nova p�gina. 
	IF NVEZ == 4
		oPrint:EndPage()
		oPrint:StartPage()
		oPrint:SetPaperSize(1)
		li 			:= nLiPadr
		NVEZ		:= 1
		lPagImpT 	:= .F.
	ENDIF
	oPrint:Say(li, 1670, DtoC(dDataAte), oFont12)  
	
	li += 96
	oPrint:Say(li, 1650, cCgc, oFont12)  	
	li += 96
	oPrint:Say(li, 1650, Iif(cOldRet==Space(4), "0561", cOldRet), oFont12)   	
	li += 96
	oPrint:Say(li, 1650, cNumRef, oFont12)	
	
	li += 25
	oPrint:Say(li, 100, Left(aInfo[3],37), oFont12)	 		
	li += 50
	oPrint:Say(li, 100, aInfo[10], oFont12)	 	
	li += 25
	
	oPrint:Say(li, 1650, DtoC(dVencto), oFont12)	
	li += 96	
	oPrint:Say(li, 1650, Transform(aFolIR[2]+aAdiIR[2]+aFerIR[2]+a13IR[2], "@E 9,999,999,999.99"), oFont12)	 	
	li += 280
	oPrint:Say(li, 1650, Transform(aFolIR[2]+aAdiIR[2]+aFerIR[2]+a13IR[2], "@E 9,999,999,999.99"), oFont12)	
	
	li += 340	

	NLIDARF := li
	//��������������������������������������������������������������Ŀ
	//� Descarrega teste de impressao                                � 
	//����������������������������������������������������������������
	IF NVEZ == 1 .AND. aReturn[5] == 3 .AND. lPagImpT
		oPrint:EndPage()
		fImpTeste()
		oPrint 	  	:= TMSPrinter():New() 	
		li 			:= nLiPadr
		oPrint:StartPage()
		oPrint:SetPaperSize(1) 

		IF nOpca == 1
			lPagImpT := .F.
			Loop
		ENDIF
	ENDIF
	NVEZ++

	Exit
ENDDO

IF TYPE("lImpPre") == "U" .OR. !lImpPre
	oPrint:EndPage() 
ENDIF

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fImpTeste �Autor  �Recursos Humanos    � Data �  11/29/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Testa impressao de Formulario Teste                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static function fImpTeste()

//��������������������������������������������������������������Ŀ
//� Descarrega teste de impressao                                � 
//����������������������������������������������������������������
MS_Flush()
oPrint:Print()
Pergunte("GPR30A",.T.)
nOpca  	:= Iif(mv_par01 == 1, 1, 2)

Return(nOpca)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fImpGraf  �Autor  �Recursos Humanos    � Data �  13/01/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Impressao da DARF modo Grafico.                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function  fImpGraf()
Local cStartPath := GetSrvProfString('StartPath', '')
Local cBmp 		 := ''
Local nLin       := 030
Local nBox       := 1    

//�������������������������������Ŀ 
//� Inicio da P�gina              �
//���������������������������������
oPrint:StartPage()  //Inicio da P�gina

//�������������������������������Ŀ 
//� Logo da Receita Federal       �
//���������������������������������
cBmp := cStartPath + 'Receita.BMP' //Logo da Receita Federal

For nBox := 1 To 2
	//�������������������������������Ŀ 
	//� Box do Formulario             �
	//���������������������������������
	oPrint:Box( nLin,0030,nLin+1100,2350)  		// box
	                                       
	If File(cBmp)
		oPrint:SayBitmap(nLin + 10,040,cBmp,200,180)
	Endif
	
	//�������������������������������Ŀ
	//� Cabecalho                     � 
	//���������������������������������
	oPrint:say(nLin +  20,250 ,STR0002, oFont15n)  //Ministerio da Fazenda
	oPrint:say(nLin +  70,250 ,STR0003, oFont10n)  //Secretaria da Receita Federal do Brasil
	oPrint:say(nLin + 120,250 ,STR0004, oFont10n)  //Documento de Arrecadacao ......
	oPrint:say(nLin + 170,250 ,STR0005, oFont21n)  //DARF
	oPrint:Line(nLin,1300,nLin + 1100,1300)   
	oPrint:Line(nLin,1800,nLin + 810,1800)
	
	//�������������������������������Ŀ
	//� Nome/Telefone                 � 
	//���������������������������������
	oPrint:Line(nLin + 270,030,nLin + 270,1300) 
	oPrint:say(nLin + 280,040 , "01"				, oFont15n)
	oPrint:say(nLin + 290,110 , STR0006				, oFont10)   //Nome/Telefone
	oPrint:say(nLin + 350,110 , Left(aInfo[3],37)	, oFont10)  
	oPrint:say(nLin + 380,110 , aInfo[10]			, oFont10) 
	
	oPrint:Line(nLin + 490,030,nLin + 490,1300)  
	oPrint:Line(nLin + 650,030,nLin + 650,1300)
	
	If IsInCallStack( "GPER055") .and. nQuebraCC == 1 .and. Empty(cCentra)  
		oPrint:say(nLin + 540,110 ,If(!Empty(cCEI),STR0026 + cCEI, STR0025 + cCCusto ) ,oFont10)  
	Endif 
	
	//�������������������������������Ŀ
	//� Periodo de Apuracao           � 
	//���������������������������������
	oPrint:say(nLin + 20,1305 , "02"																				, oFont15n)
	oPrint:say(nLin + 30,1370 , STR0013																				, oFont08)   //Periodo de Apuracao
	oPrint:say(nLin + 30,2090 , Subs(Dtos(dDataAte),7,2)+"/"+Subs (Dtos(dDataAte),5,2)+"/"+Subs(Dtos(dDataAte),1,4)	, oFont10) 
	
	//�������������������������������Ŀ
	//� Numero de CGG ou  CPF         � 
	//���������������������������������
	oPrint:Line(nLin + 090, 1300, nLin + 90,2350)
	oPrint:say( nLin + 120, 1305, "03"	 , oFont15n)
	oPrint:say( nLin + 130, 1370, STR0014, oFont08)   //Numero de CGG ou  CPF
	oPrint:say( nLin + 130, 1910, cCgc   , oFont10)  
	
	//�������������������������������Ŀ
	//� Codigo da Receita             � 
	//���������������������������������
	oPrint:Line(nLin + 180, 1300, nLin + 180,2350)
	oPrint:say( nLin + 200, 1305, "04"    								,oFont15n)
	oPrint:say( nLin + 210, 1370, STR0015								,oFont08)   //Codigo da Receita
	oPrint:say( nLin + 210, 2145, If(cOldRet==Space(4),"0561",cOldRet)	,oFont10)
	 
	//�������������������������������Ŀ
	//� Numero de Referencia          � 
	//���������������������������������
	oPrint:Line(nLin + 270, 1300, nLin + 270,2350)
	oPrint:say( nLin + 290, 1305, "05"	 , oFont15n)
	oPrint:say( nLin + 300, 1370, STR0016, oFont08)   //Numero de Referencia
	oPrint:say( nLin + 300, 1935, cNumRef, oFont10)  
	
	//�������������������������������Ŀ
	//� Data do Vencimento            � 
	//���������������������������������
	oPrint:Line(nLin + 360, 1300, nLin + 360,2350)
	oPrint:say( nLin + 380, 1305, "06"																				,oFont15n)
	oPrint:say( nLin + 390, 1370, STR0017																			,oFont08)   //Data do Vencimento
	oPrint:say( nLin + 390, 2090, Subs(Dtos(dVencto),7,2)+"/"+Subs (Dtos(dVencto),5,2)+"/"+Subs(Dtos(dVencto),1,4)	, oFont10)   
	 
	//�������������������������������Ŀ
	//� Valor Principal               � 
	//���������������������������������
	oPrint:Line(nLin + 450, 1300, nLin + 450,2350)
	oPrint:say( nLin + 470, 1305, "07"																		,oFont15n)
	oPrint:say( nLin + 480, 1370, STR0018																	,oFont08)   //Valor Principal
	oPrint:say( nLin + 480, 2000, Transform(aFolIR[2]+aAdiIR[2]+aFerIR[2]+a13IR[2],"@E 9,999,999,999.99")	,oFont10)  
	
	//�������������������������������Ŀ
	//� Valor da Multa                � 
	//���������������������������������
	oPrint:Line(nLin + 540, 1300, nLin + 540,2350)
	oPrint:say( nLin + 560, 1305, "08"	 , oFont15n)
	oPrint:say( nLin + 570, 1370, STR0019, oFont08)   //Valor da Multa
	
	//�������������������������������������������Ŀ
	//� Valor dos Juros e/ou Encargos DL 10225/69 � 
	//���������������������������������������������
	oPrint:Line(nLin + 630, 1300, nLin + 630,2350)
	oPrint:say( nLin + 650, 1305, "09"	 , oFont15n)
	oPrint:say( nLin + 640, 1370, STR0020, oFont08)   //Valor dos Juros e/ou
	oPrint:say( nLin + 670, 1370, STR0021, oFont08)   //Encargos DL 10225/69
	
	//�������������������������������Ŀ
	//� Valor Total                   � 
	//���������������������������������
	oPrint:Line(nLin + 720, 1300, nLin + 720,2350)
	oPrint:say( nLin + 740, 1305, "10"																		,oFont15n)
	oPrint:say( nLin + 750, 1370, STR0022																	,oFont08)   //Valor Total
	oPrint:say( nLin + 750, 2000, Transform(aFolIR[2]+aAdiIR[2]+aFerIR[2]+a13IR[2],"@E 9,999,999,999.99")	,oFont10)                                                                                                                        
	
	//�������������������������������Ŀ
	//� Autenticacao Bancaria         � 
	//� Somente nas 1 e 2 vias)       �
	//���������������������������������
	oPrint:Line(nLin + 810, 1300, nLin + 810,2350)
	oPrint:say( nLin + 830, 1305, "11"	 , oFont15n)
	oPrint:say( nLin + 830, 1370, STR0023, oFont08)   //Autenticacao Bancaria
	oPrint:say( nLin + 830, 1805, STR0024, oFont07)   //Somente nas 1 e 2 vias)
	
	oPrint:say( nLin + 710, 600, STR0007, oFont08)   //Atencao
	oPrint:say( nLin + 770, 040, STR0008, oFont08)    //� Vedado o ...
	oPrint:say( nLin + 800, 040, STR0009, oFont08)    //   .
	oPrint:say( nLin + 830, 040, STR0010, oFont08)    //   .
	oPrint:say( nLin + 860, 040, STR0011, oFont08)    //   .
	                                               
	oPrint:say(nlin + 1250, 000,Replicate("-",132),oFont11) 
	 
	nLin := 1480
	
Next nBox

//�������������������������������Ŀ
//� Finaliza a Impressao          � 
//���������������������������������
oPrint:EndPage()  
  
Return()
