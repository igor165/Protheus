#Include "TopConn.CH"
#Include "Protheus.ch"
Static objCENFUNLGP := CENFUNLGP():New() 
//#Include "PLSR956.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PLSR956   � Autor �F�bio S. dos Santos	� Data �02/12/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relat�rio de Manuten��o de benefici�rio no portal do 		  ���
���			 �benefici�rio/empresa .	               			   		  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - PLS				                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PLSR956(nRecno,lWeb,cPathW)
Static oRel		:= nil

Local nPixLin		:= 40
Local nPixCol		:= 35
Local cRelName		:= "ProtSolBen"+CriaTrab(NIL,.F.)   
Local cCodInt		:= PLSINTPAD()
Local cAns			:= Posicione("BA0",1,xFilial("BA0")+cCodInt,"BA0_SUSEP")
Local aBMPEsq		:= {}
Local aBMPDir		:= {}
Local aDep			:= {} 
Local nCont			:= 0
Local nLinMax		:= 0
Local nColMax		:= 0
Local nLayout		:= 0
Local cNomTit		:= ""
Local cMatTit		:= ""
Local cCpfTit		:= ""
Local cEndTit		:= ""
Local cLograTit		:= ""
Local cBairroTit	:= ""
Local cCodTel		:= ""
Local cTelTit		:= ""
Local cEmailTit		:= ""
Local cPathDest	:= Lower(GETMV("MV_RELT")) 
Local cMsg			:= ""
Local lTitu		:= .F.
Default cPathW		:= ""
Default nRecno		:= 131//138
Default lWeb		:= .F.

//-- LGPD ----------
if funName() <> "RPC" .And. !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------

If lWeb
	cPathDest	:= cPathW
Else	 
	cPathDest	:= PswRet()[2,3] 	
EndIf	

//�����������������������������������������Ŀ
//� Posiciona no PROTOCOLO				    �
//�������������������������������������������
BBA->(DbSetOrder(1))
BBA->(DbGoTo(nRecno))

oRel := FWMSPrinter():New(cRelName,6	  ,.F.,nil,.T.,nil,@oRel,nil,nil,.F.,.F.)	
oRel:cPathPDF := cPathDest

If BBA->BBA_TIPMAN $ ("1|3") //INCLUS�O/EXCLUS�O
	B2N->(DbSetOrder(1))
	B2N->(DbSeek(xFilial("B2N")+BBA->BBA_CODSEQ))
	While !B2N->(Eof()) .And. B2N->B2N_FILIAL+B2N->B2N_PROTOC == xFilial("BBA")+BBA->BBA_CODSEQ 
		If B2N->B2N_TIPUSU == "T"
			cNomTit		:= B2N->B2N_NOMUSR
			cMatTit		:= BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO  
			cCpfTit		:= B2N->B2N_CPFUSR
			cEndTit		:= AllTrim(B2N->B2N_ENDERE) + ", " + AllTrim(B2N->B2N_NR_END) + " " + Iif(Empty(B2N->B2N_COMEND), "", AllTrim(B2N->B2N_COMEND)) + " - " + AllTrim(B2N->B2N_BAIRRO) + " - " + AllTrim(B2N->B2N_MUNICI) + " - " + B2N->B2N_ESTADO
			cLograTit	:= AllTrim(B2N->B2N_ENDERE) + ", " + AllTrim(B2N->B2N_NR_END) + " "
			cBairroTit	:= Iif(Empty(B2N->B2N_COMEND), "", AllTrim(B2N->B2N_COMEND)) + " - " + AllTrim(B2N->B2N_BAIRRO) + " - " + AllTrim(B2N->B2N_MUNICI) + " - " + B2N->B2N_ESTADO
			cCodTel		:= B2N->B2N_DDD
			cTelTit		:= B2N->B2N_TELEFO
			cEmailTit	:= B2N->B2N_EMAIL
			lTitu			:= .T.
		Else
			aAdd(aDep,{B2N->B2N_NOMUSR,B2N->B2N_GRAUPA,B2N->B2N_CPFUSR,B2N->B2N_DRGUSR,B2N->B2N_DATNAS,B2N->B2N_MAE,B2N->B2N_PAI})
		EndIf
		B2N->(DbSkip())
	End
Else
	//�����������������������������������������Ŀ
	//� Posiciona no BENEFICIARIO			    �
	//�������������������������������������������
	BA1->(DbSetOrder(2))
	BA1->(MsSeek(xFilial("BA1")+SubStr(BBA->BBA_MATRIC,1,14)))
	While !BA1->(Eof()) .AND. (BA1->BA1_FILIAL+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC == xFilial("BBA")+SubStr(BBA->BBA_MATRIC,1,14))
		If BA1->BA1_TIPUSU == "T"
			cNomTit	:= BA1->BA1_NOMUSR
			cMatTit		:= BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO
			cCpfTit		:= BA1->BA1_CPFUSR
			cEndTit		:= AllTrim(BA1->BA1_ENDERE) + ", " + AllTrim(BA1->BA1_NR_END) + " " + Iif(Empty(BA1->BA1_COMEND), "", AllTrim(BA1->BA1_COMEND)) + " - " + AllTrim(BA1->BA1_BAIRRO) + " - " + AllTrim(BA1->BA1_MUNICI) + " - " + BA1->BA1_ESTADO
			cLograTit	:= AllTrim(BA1->BA1_ENDERE) + ", " + AllTrim(BA1->BA1_NR_END) + " "
			cBairroTit	:= Iif(Empty(BA1->BA1_COMEND), "", AllTrim(BA1->BA1_COMEND)) + " - " + AllTrim(BA1->BA1_BAIRRO) + " - " + AllTrim(BA1->BA1_MUNICI) + " - " + BA1->BA1_ESTADO
			cCodTel		:= B2N->B2N_DDD
			cTelTit		:= BA1->BA1_TELEFO
			cEmailTit	:= BA1->BA1_EMAIL
		Else
			aAdd(aDep,{BA1->BA1_NOMUSR,BA1->BA1_GRAUPA,BA1->BA1_CPFUSR,BA1->BA1_DRGUSR,BA1->BA1_DATNAS,BA1->BA1_MAE,BA1->BA1_PAI})
		EndIf
		BA1->(DbSkip())
	End
EndIf

if EmpTy(cNomTit)
	BA1->(DbSetOrder(2))
	BA1->(MsSeek(xFilial("BA1")+SubStr(BBA->BBA_MATRIC,1,14)))
	While !BA1->(Eof()) .AND. (BA1->BA1_FILIAL+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC == xFilial("BBA")+SubStr(BBA->BBA_MATRIC,1,14))
		If BA1->BA1_TIPUSU == "T"
			cNomTit	:= BA1->BA1_NOMUSR
			cMatTit		:= BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO
			cCpfTit		:= BA1->BA1_CPFUSR
			cEndTit		:= AllTrim(BA1->BA1_ENDERE) + ", " + AllTrim(BA1->BA1_NR_END) + " " + Iif(Empty(BA1->BA1_COMEND), "", AllTrim(BA1->BA1_COMEND)) + " - " + AllTrim(BA1->BA1_BAIRRO) + " - " + AllTrim(BA1->BA1_MUNICI) + " - " + BA1->BA1_ESTADO
			cLograTit	:= AllTrim(BA1->BA1_ENDERE) + ", " + AllTrim(BA1->BA1_NR_END) + " "
			cBairroTit	:= Iif(Empty(BA1->BA1_COMEND), "", AllTrim(BA1->BA1_COMEND)) + " - " + AllTrim(BA1->BA1_BAIRRO) + " - " + AllTrim(BA1->BA1_MUNICI) + " - " + BA1->BA1_ESTADO
			cCodTel		:= B2N->B2N_DDD
			cTelTit		:= BA1->BA1_TELEFO
			cEmailTit	:= BA1->BA1_EMAIL
			Exit
		EndIf
	EndDo	
EndIf
					
//��������������������������������������������������������������Ŀ
//� Instancia os objetos de fonte antes da pintura do relatorio  �  
//����������������������������������������������������������������
oFont9  	:= TFont():New( "Arial",, 9,,.F.)
oFont10  	:= TFont():New( "Arial",, 10,,.F.)
oFont10N 	:= TFont():New( "Arial",, 10,,.T.)
oFont12  	:= TFont():New( "Arial",, 12,,.F.)
oFont12N 	:= TFont():New( "Arial",, 12,,.T.)
oFont14 	:= TFont():New( "Arial",, 14,,.F.)
oFont14N 	:= TFont():New( "Arial",, 14,,.T.)
oFont16 	:= TFont():New( "Arial",, 16,,.F.)
oFont16N 	:= TFont():New( "Arial",, 16,,.T.)

//��������������������������������������������������������������Ŀ
//� obj															 �  
//����������������������������������������������������������������
oRel:setResolution(72)
oRel:setPortrait()
oRel:setPaperSize(DMPAPER_A4)

//��������������������������������������������������������������Ŀ
//� nEsquerda, nSuperior, nDireita, nInferior 					 �  
//����������������������������������������������������������������
oRel:setMargin(05,05,05,05)

//��������������������������������������������������������������Ŀ
//� setup da impressora						 					 �  
//����������������������������������������������������������������		
If !lWeb
	oRel:Setup()
	lMarc:=.F.

	If oRel:nModalResult == 2 //Verifica se foi Cancelada a Impress�o
		Return{"",""}
	EndIf

EndIf

If oRel:nPaperSize  == 9 // Pap�l A4
	nLinMax	:= 2350
	nColMax	:= 750
	nLayout := 2
ElseIf oRel:nPaperSize == 1 // Papel Carta
	nLinMax	:= 790
	nColMax	:= 575
	nLayout := 3
Else // Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	nLinMax	:= 3705
	nColMax	:= 2400
	nLayout := 1
EndIf	
//��������������������������������������������������������������Ŀ
//� Inicializa uma pagina					 					 �  
//����������������������������������������������������������������			

oRel:StartPage()
//��������������������������������������������������������������Ŀ
//� Insere logo no relatorio					 				 �  
//����������������������������������������������������������������	
aBMPEsq	:= {"lgesq.bmp"}
aBMPDir  := {"lgdir.bmp"}
	
If File("lgesq" + FWGrpCompany() + FWCodFil() + ".bmp")
	aBMPEsq := { "lgesq" + FWGrpCompany() + FWCodFil() + ".bmp" }
ElseIf File("lgesq" + FWGrpCompany() + ".bmp")
	aBMPEsq := { "lgesq" + FWGrpCompany() + ".bmp" }
EndIf
	
If File("lgdir" + FWGrpCompany() + FWCodFil() + ".bmp")
	aBMPDir := { "lgdir" + FWGrpCompany() + FWCodFil() + ".bmp" }
ElseIf File("lgdir" + FWGrpCompany() + ".bmp")
	aBMPDir := { "lgdir" + FWGrpCompany() + ".bmp" }
EndIf
	
If !Empty(aBMPEsq[1])
	oRel:SayBitmap(10,10, aBMPEsq[1],130,50) 		//-- Tem que estar abaixo do RootPath -- esta no SYSTEM
Endif

If !Empty(aBMPDir[1])
	oRel:SayBitmap(10,450, aBMPDir[1],130,50) 		//-- Tem que estar abaixo do RootPath
Endif

nPixLin += 25

//��������������������������������������������������������������Ŀ
//� Imprime cabe�alho							 				 �  
//����������������������������������������������������������������	
		
oRel:say(nPixLin,nPixCol + 150,Posicione("BI3",1,xFilial("BI3")+cCodInt+BBA->BBA_CODPRO,"BI3_DESCRI"),oFont16n)
nPixLin += 30

oRel:Line( nPixLin, nPixCol, nPixLin, nColMax) //linha horizontal
nPixLin += 10	

oRel:say(nPixLin,nPixCol,"Nome Completo do Titular ",oFont12N)
nPixLin += 10	
oRel:say(nPixLin + 5,nPixCol,cNomTit,oFont10)

oRel:Line( nPixLin-20, nPixCol+400, nPixLin+10, nPixCol+400) //linha vertical
oRel:say(nPixLin-10,nPixCol+402,"Matr�cula ",oFont12N)

oRel:say(nPixLin +5,nPixCol + 402,cMatTit,oFont10)
nPixLin += 10

oRel:Line( nPixLin, nPixCol, nPixLin, nColMax)//linha horizontal	
nPixLin += 10

oRel:say(nPixLin,nPixCol,"Endere�o Residencial " ,oFont12N)
nPixLin += 10
If len(cEndTit) > 90
	nPixLin += 5
	oRel:say(nPixLin,nPixCol,cLograTit,oFont10) 
	nPixLin += 5
	oRel:say(nPixLin + 5,nPixCol,cBairroTit,oFont10) 
	oRel:Line( nPixLin-35, nPixCol+400, nPixLin+10, nPixCol+400)//linha vertical
	oRel:say(nPixLin - 20,nPixCol + 402 ,"Telefone ",oFont12N)
	oRel:say(nPixLin - 5,nPixCol + 402,Transform(cCodTel+cTelTit,"@R (99)9999-9999"),oFont10)
Else
	oRel:say(nPixLin + 5,nPixCol,cEndTit,oFont10) 
	oRel:Line( nPixLin-5, nPixCol+400, nPixLin+10, nPixCol+400)//linha vertical
	oRel:say(nPixLin - 10,nPixCol + 402 ,"Telefone ",oFont12N)
	oRel:say(nPixLin + 5,nPixCol + 402,Transform(cCodTel+cTelTit,"@R (99)9999-9999"),oFont10)
EndIf

nPixLin += 10

oRel:Line( nPixLin, nPixCol, nPixLin, nColMax)//linha horizontal
nPixLin += 10

oRel:say(nPixLin,nPixCol,"Email " ,oFont12N)
nPixLin += 10
oRel:say(nPixLin + 5,nPixCol,cEmailTit,oFont10)
nPixLin += 10

oRel:Line( nPixLin, nPixCol, nPixLin, nColMax, , "+2")	//linha horizontal
nPixLin += 20	 

oRel:say(nPixLin,nPixCol+195,"Movimenta��o Realizada: " ,oFont14N)
nPixLin += 010	

//��������������������������������������������������������������Ŀ
//� Imprime BOX 1    							 				 �  
//����������������������������������������������������������������
oRel:Box(nPixLin,nPixCol,nPixLin+040,nPixCol + 185)//box externo
oRel:Box(nPixLin + 5,nPixCol + 10 ,nPixLin + 15,nPixCol + 20)//box checkbox
oRel:say(nPixLin + 13,nPixCol + 25,"Inclus�o de Titular " ,oFont12) 
oRel:Box(nPixLin + 25,nPixCol + 10 ,nPixLin + 35,nPixCol + 20)//box checkbox
oRel:say(nPixLin + 33,nPixCol + 25,"Inclus�o de Dependentes " ,oFont12) 

//��������������������������������������������������������������Ŀ
//� Imprime BOX 2    							 				 �  
//����������������������������������������������������������������
oRel:Box(nPixLin,nPixCol + 195,nPixLin+040,nPixCol + 360)//box externo
oRel:Box(nPixLin + 5,nPixCol + 205 ,nPixLin + 15,nPixCol + 215)//box checkbox
oRel:say(nPixLin + 13,nPixCol + 220,"Exclus�o de Titular " ,oFont12) 
oRel:Box(nPixLin + 25,nPixCol + 205 ,nPixLin + 35,nPixCol + 215)//box checkbox
oRel:say(nPixLin + 33,nPixCol + 220,"Exclus�o de Dependentes " ,oFont12)  
//��������������������������������������������������������������Ŀ
//� Imprime BOX 3    							 				 �  
//����������������������������������������������������������������
oRel:Box(nPixLin,nPixCol + 370,nPixLin+040,nPixCol + 535)//box externo
oRel:Box(nPixLin + 5,nPixCol + 380 ,nPixLin + 15,nPixCol + 390)//box checkbox
oRel:say(nPixLin + 13,nPixCol + 395,"Altera��o de Dados " ,oFont12) 

If BBA->BBA_TIPMAN == "1"
	if lTitu
		oRel:say(nPixLin + 14,nPixCol + 12,"X" ,oFont10)
	EndIf
	If Len(aDep) > 0
		oRel:say(nPixLin + 34,nPixCol + 12,"X" ,oFont10)
	EndIf
ElseIf BBA->BBA_TIPMAN == "2"
	oRel:say(nPixLin + 14,nPixCol + 382,"X" ,oFont10)	
Else
	B2N->(DbSetOrder(1))
	B2N->(MsSeek(xFilial("B2N")+BBA->BBA_CODSEQ))
	If B2N->B2N_TIPUSU == "T"
		oRel:say(nPixLin + 14,nPixCol + 207,"X" ,oFont10)
	Else
		oRel:say(nPixLin + 34,nPixCol + 207,"X" ,oFont10)
	EndIf
EndIf

nPixLin += 050

For nCont := 1 To Len(aDep)
	If nCont == 1
		oRel:Box(nPixLin,nPixCol,nPixLin+020,nPixCol + 535)
		oRel:say(nPixLin + 13,nPixCol + 175,"Rela��o de Dependentes " ,oFont14N)
		
		oRel:Box(nPixLin + 20,nPixCol,nPixLin+110,nPixCol + 15)
		oRel:say(nPixLin + 63,nPixCol + 02,StrZero(nCont,2) ,oFont12N)
		
		oRel:Box(nPixLin + 20,nPixCol+15,nPixLin+050,nPixCol + 400)
		oRel:say(nPixLin + 33,nPixCol + 16,"Nome Completo",oFont12N)
		oRel:say(nPixLin + 43,nPixCol + 16,aDep[nCont,1],oFont10)
		
		oRel:Box(nPixLin + 20,nPixCol+400,nPixLin+050,nPixCol + 535)
		oRel:say(nPixLin + 33,nPixCol + 401,"Parentesco",oFont12N)
		oRel:say(nPixLin + 43,nPixCol + 401,AllTrim(Posicione("BRP",1,xFilial("BRP")+aDep[nCont,2],"BRP_DESCRI")),oFont10)
		
		oRel:Box(nPixLin + 50,nPixCol+15,nPixLin+080,nPixCol + 250)
		oRel:say(nPixLin + 63,nPixCol + 16,"CPF",oFont12N)
		oRel:say(nPixLin + 73,nPixCol + 16,Transform(aDep[nCont,3],"@R 999.999.999-99"),oFont10)
		
		oRel:Box(nPixLin + 50,nPixCol+250,nPixLin+080,nPixCol + 400)
		oRel:say(nPixLin + 63,nPixCol + 251,"RG",oFont12N)
		oRel:say(nPixLin + 73,nPixCol + 251,Transform(aDep[nCont,4],"@R !!.!!!.!!!-!"),oFont10)
		
		oRel:Box(nPixLin + 50,nPixCol+400,nPixLin+080,nPixCol + 535)
		oRel:say(nPixLin + 63,nPixCol + 401,"Nascimento",oFont12N)
		oRel:say(nPixLin + 73,nPixCol + 401,DtoC(aDep[nCont,5]),oFont10)
		
		oRel:Box(nPixLin + 080,nPixCol+15,nPixLin+110,nPixCol + 400)
		oRel:say(nPixLin + 093,nPixCol + 16,"Nome Completo da M�e",oFont12N)
		oRel:say(nPixLin + 103,nPixCol + 16,aDep[nCont,6],oFont10)
		
		oRel:Box(nPixLin + 080,nPixCol+250,nPixLin+110,nPixCol + 535)
		oRel:say(nPixLin + 093,nPixCol + 251,"Nome Completo da Pai",oFont12N)
		oRel:say(nPixLin + 103,nPixCol + 251,aDep[nCont,7],oFont10)
		
		nPixLin += 090
		
	Else
	
		oRel:Box(nPixLin + 20,nPixCol,nPixLin+110,nPixCol + 15)
		oRel:say(nPixLin + 63,nPixCol + 02,StrZero(nCont,2) ,oFont12N)
		
		oRel:Box(nPixLin + 20,nPixCol+15,nPixLin+050,nPixCol + 400)
		oRel:say(nPixLin + 33,nPixCol + 16,"Nome Completo",oFont12N)
		oRel:say(nPixLin + 43,nPixCol + 16,aDep[nCont,1],oFont10)
		
		oRel:Box(nPixLin + 20,nPixCol+400,nPixLin+050,nPixCol + 535)
		oRel:say(nPixLin + 33,nPixCol + 401,"Parentesco",oFont12N)
		oRel:say(nPixLin + 43,nPixCol + 401,AllTrim(Posicione("BRP",1,xFilial("BRP")+aDep[nCont,2],"BRP_DESCRI")),oFont10)
		
		oRel:Box(nPixLin + 50,nPixCol+15,nPixLin+080,nPixCol + 250)
		oRel:say(nPixLin + 63,nPixCol + 16,"CPF",oFont12N)
		oRel:say(nPixLin + 73,nPixCol + 16,Transform(aDep[nCont,3],"@R 999.999.999-99"),oFont10)
		
		oRel:Box(nPixLin + 50,nPixCol+250,nPixLin+080,nPixCol + 400)
		oRel:say(nPixLin + 63,nPixCol + 251,"RG",oFont12N)
		oRel:say(nPixLin + 73,nPixCol + 251,Transform(aDep[nCont,4],"@R 99.999.999-9"),oFont10)
		
		oRel:Box(nPixLin + 50,nPixCol+400,nPixLin+080,nPixCol + 535)
		oRel:say(nPixLin + 63,nPixCol + 401,"Nascimento",oFont12N)
		oRel:say(nPixLin + 73,nPixCol + 401,DtoC(aDep[nCont,5]),oFont10)
		
		oRel:Box(nPixLin + 080,nPixCol+15,nPixLin+110,nPixCol + 400)
		oRel:say(nPixLin + 093,nPixCol + 16,"Nome Completo da M�e",oFont12N)
		oRel:say(nPixLin + 103,nPixCol + 16,aDep[nCont,6],oFont10)
		
		oRel:Box(nPixLin + 080,nPixCol+250,nPixLin+110,nPixCol + 535)
		oRel:say(nPixLin + 093,nPixCol + 251,"Nome Completo da Pai",oFont12N)
		oRel:say(nPixLin + 103,nPixCol + 251,aDep[nCont,7],oFont10)
		
		nPixLin += 090	
	EndIf
	//�������������������
	//�Quebra de Paginas
	//�������������������
	If nPixLin > 700
		nPixLin := 40
		oRel:EndPage()
		oRel:StartPage()	
	EndIf
Next nCont
nPixLin += 045

aMsg := PLSRETMSG("0",,"POR","PLSR9561") //primeiro grupo de msgs

If Len(aMsg) > 0
	oRel:say(nPixLin,nPixCol,"DOCUMENTA��O NECESS�RIA",oFont14N)
	nPixLin += 010
	For nCont := 1 To Len(aMsg)
		oRel:say(nPixLin,nPixCol + 10,"- " + aMsg[nCont,2],oFont10)
		nPixLin += 010
		//Cria nova pagina
		If nPixLin >= nLinMax
			nPixLin := 40
			nPixCol := 35 
			GeraCab(@nPixLin,@nPixCol)
		EndIf
			
	Next nCont
	oRel:Line( nPixLin, nPixCol, nPixLin, nColMax, , "+2")	//linha horizontal
	nPixLin += 15
EndIf

//Pegar do cadastro de msg - Importante: cada linha do relat�rio tem aproximadamente 130 caracteres, se por um acaso for cadastrado mais que o limite
//n�o vai aparecer
aMsg := PLSRETMSG("0",,"POR","PLSR9562")//segundo grupo de msgs	
If Len(aMsg) > 0
	For nCont := 1 To Len(aMsg)
		oRel:say(nPixLin,nPixCol + 10,"- " + aMsg[nCont,2],oFont10N)
		nPixLin += 010
		If nPixLin >= nLinMax
			nPixLin := 40
			nPixCol := 35 
			GeraCab(@nPixLin,@nPixCol)
		EndIf
	Next nCont
	oRel:Line( nPixLin + 5, nPixCol, nPixLin + 5, nColMax, , "+2")	//linha horizontal
	nPixLin += 15
EndIf

//�������������������
//�Quebra de Paginas
//�������������������
If nPixLin + 65 > 700
	nPixLin := 40
	oRel:EndPage()
	oRel:StartPage()	
EndIf
 
oRel:say(nPixLin,nPixCol,"ASSINATURA",oFont12N)
oRel:say(nPixLin,nPixCol + 450,"DATA",oFont12N)
nPixLin += 15
oRel:say(nPixLin,nPixCol + 450,DtoC(dDataBase),oFont12)
nPixLin += 15
oRel:Line( nPixLin, nPixCol, nPixLin, nColMax)//linha horizontal
nPixLin += 10
oRel:Box(nPixLin,nPixCol,nPixLin+020,nPixCol + 100)
oRel:say(nPixLin + 13,nPixCol + 05,"ANS - N� " + Posicione("BA0",1,xFilial("BA0")+cCodInt,"BA0_SUSEP"),oFont12N)
oRel:Box(nPixLin,nPixCol+400,nPixLin+035,nPixCol + 535)
oRel:say(nPixLin + 10,nPixCol + 405,"N�mero do Protocolo:",oFont12N)
nPixLin += 25
oRel:say(nPixLin,nPixCol + 405,Iif(Len(AllTrim(BBA->BBA_NROPRO)) == 14, cAns+BBA->BBA_NROPRO, BBA->BBA_NROPRO),oFont12)
							
oRel:EndPage()

oRel:Preview()
//��������������������������������������������������������������������
//�Fim da rotina
//��������������������������������������������������������������������
Return{cRelName+".pdf",cMsg}

/*/
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o	 �GeraCab   �Autor  � F�bio S. dos Santos         � Data �02/12/2015���
�������������������������������������������������������������������������������Ĵ��
���Descri��o �Gera nova pagina													���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
/*/ 
Function GeraCab(nPixLin,nPixCol)
		
oRel:StartPage()

//insere logo na nova pagina
aBMPEsq	:= {"lgesq.bmp"}
aBMPDir	:= {"lgdir.bmp"}

If File("lgesq" + FWGrpCompany() + FWCodFil() + ".bmp")
	aBMPEsq := { "lgesq" + FWGrpCompany() + FWCodFil() + ".bmp" }
ElseIf File("lgesq" + FWGrpCompany() + ".bmp")
	aBMPEsq := { "lgesq" + FWGrpCompany() + ".bmp" }
EndIf

If File("lgdir" + FWGrpCompany() + FWCodFil() + ".bmp")
	aBMPDir := { "lgdir" + FWGrpCompany() + FWCodFil() + ".bmp" }
ElseIf File("lgdir" + FWGrpCompany() + ".bmp")
	aBMPDir := { "lgdir" + FWGrpCompany() + ".bmp" }
EndIf

If !Empty(aBMPEsq[1])
	oRel:SayBitmap(10,10, aBMPEsq[1],130,50) 		//-- Tem que estar abaixo do RootPath -- esta no SYSTEM
Endif

If !Empty(aBMPDir[1])
	oRel:SayBitmap(10,450, aBMPDir[1],130,50) 		//-- Tem que estar abaixo do RootPath
Endif
		
nPixLin += 25

//��������������������������������������������������������������Ŀ
//� Imprime cabe�alho							 				 �  
//����������������������������������������������������������������			
oRel:say(nPixLin,nPixCol + 150,FWFilRazSocial(),oFont16n)
nPixLin += 30		
		
Return