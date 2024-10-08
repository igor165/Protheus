#INCLUDE "FINA996.ch"
#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FINA996  �Autor  �	Bruno Schmidt    � Data � 20/02/2013  ���
�������������������������������������������������������������������������͹��
���Desc.     �Le o arquivo de retorno 			                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������͹��
���LuisEnr�quez�10/02/17�SERINN001-1122�-Se realiza merge para modifica-  ���
���            �        �              � cion en creacion de tabla tempo- ���
���            �        �              � ral  PRO, se usa clase FWTempora ���
���            �        �              � -ry Table en lugar de funcion    ���
���            �        �              � CriaTrab (CTREE).                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/      
Function FINA996()                     

Local aArqTmp	 := {}
Local aCarga	 := {}
Local cTitulo	 := ""
Local cErro	 := ""
Local cSolucao := ""
Local cTexto   := ""
Local lCarga   := .F.
Local nRegProc := 0
Local nRegAtu  := 0

Private oTmpTable := Nil

If FINA996Wiz()
	//������������������������������������������������������������������Ŀ
	//�Carrega no arquivo temporario as informacoes do arquivo de retorno�
	//��������������������������������������������������������������������
    Processa({|| aCarga := FINA996Le(@aArqTmp)})
    lCarga := aCarga[01]

    If lCarga
		//����������������������������������������������Ŀ
		//�Atualiza tabelas com as informacoes do retorno�
		//������������������������������������������������
        Processa({|| FINA996ATU(aCarga[02],@nRegProc,@nRegAtu)})
			 
        cTexto  += STR0048+AllTrim(Str(nRegProc,10))+CHR(13)+CHR(10)    // "Registros processados: "
        cTexto  += STR0049+AllTrim(Str(nRegAtu,10))+CHR(13)+CHR(10)     // "Registros atualizados: " 
        cTexto  := STR0050+CHR(13)+CHR(10)+""+CHR(13)+CHR(10)+cTexto    // "Importa��o de arquivo concluida "
        
        DEFINE MSDIALOG oDlg TITLE STR0051 From 3,0 to 270,320 PIXEL // "Importa��o de Reten��o de Lucros" 

            DEFINE FONT oFont NAME "Tahoma" SIZE 7,15   //6,15
            @ 5,6 GET oMemo  VAR cTexto MEMO SIZE 150,108 OF oDlg PIXEL
    
            oMemo:bRClicked := {||AllwaysTrue()}
            oMemo:oFont     := oFont
            oMemo:lReadOnly := .t.
        
            DEFINE SBUTTON  FROM 118,130 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
        
        ACTIVATE MSDIALOG oDlg CENTER
			 
    Else
        cTitulo 	:= STR0024		//"Importa��o n�o realizada"
        cErro		:= STR0025		//"A importa��o do arquivo de retorno n�o foi realizada "
        cErro		+= STR0026		//"por n�o existirem informa��es de retorno no arquivo "
        cErro		+= STR0027		//"texto informado. "
        cSolucao	:= STR0028		//"Verifique se o arquivo de retorno informado nas "
        cSolucao	+= STR0029		//"perguntas da rotina � o enviado pela Reproweb "
        cSolucao	+= STR0030		//"e processe esta rotina novamente."
        xMagHelpFis(cTitulo,cErro,cSolucao)
    Endif
		//�������������������������������������Ŀ
		//�Excluindo o arquivo temporario criado�
		//���������������������������������������
    dbSelectArea(aArqTmp[1,2])
    dbCloseArea()
    If &(aArqTmp[1,1]) <> Nil   
		&(aArqTmp[1,1]):Delete()  
		&(aArqTmp[1,1]) := Nil 
	EndIf     
Else
    cTitulo 	:= STR0018 				//"Implementa��o n�o efetuada"
    cErro		:= STR0019 				//"A implementa��o do processo de atualiza��o"
    cErro		+= STR0020 				//"Reproweb n�o foi efetuada corretamente."
    cSolucao	:= STR0021 				//"verifique a documenta��o que acompanha a rotina e "
    cSolucao	+= STR0022 				//"execute todos os procedimentos indicados e processe "
    cSolucao	+= STR0023 				//"esta rotina novamente."
    xMagHelpFis(cTitulo,cErro,cSolucao)
Endif

Return(.T.)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �FINA996Wiz  �Autor  �   Bruno Schmidt    � Data � 20/02/2013  ���
���������������������������������������������������������������������������͹��
���Desc.     �Monta a wizard com as perguntas a rotina de importacao        ���
���������������������������������������������������������������������������͹��
���Uso       �Reproweb                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function FINA996Wiz()

//������������������������Ŀ
//�Declaracao das variaveis�
//��������������������������
Local aTxtPre 		:= {}
Local aPaineis 		:= {}

Local cTitObj1		:= ""                
Local cMask			:= Replicate("X",245)
	
Local nPos			:= 0
	
Local lRet			:= 0
Local cCab			:= STR0001 //"Importa��o do Arquivo Reproweb"
//�����������������������������������������Ŀ
//�Monta wizard com as perguntas necessarias�
//�������������������������������������������
aAdd(aTxtPre,STR0001) //"Importa��o do Arquivo "
aAdd(aTxtPre,STR0002) //"Aten��o"
aAdd(aTxtPre,STR0003) //"Preencha corretamente as informa��es solicitadas."
aAdd(aTxtPre,Alltrim(STR0004)+" "+cCab+Alltrim(STR0005)+" "+Alltrim(STR0006))	
										//"Esta rotina ira importar o arquivo de retorno disponibilizado pela Reproweb       "
										//", contendo informa��es sobre fornecedores     "
										//"em um deternimado per�odo."

//�������������������������������������Ŀ
//�Painel 1 - Informacoes da Empresa    �
//���������������������������������������
aAdd(aPaineis,{})
nPos :=	Len(aPaineis)
aAdd(aPaineis[nPos],STR0007) //"Assistente de parametriza��o" 
aAdd(aPaineis[nPos],STR0008) //"Informa��es sobre o arquivo de retorno: "
aAdd(aPaineis[nPos],{})

cTitObj1 :=	STR0009 //"Arquivo de retorno: "
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{2,"",cMask,1,,,,245,,.T.})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

lRet :=	xMagWizard(aTxtPre,aPaineis,"Rproweb")
	
Return(lRet)   

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �FINA996Tmp  �Autor  �   Bruno Schmidt    � Data � 20/02/2013  ���
���������������������������������������������������������������������������͹��
���Desc.     �Cria o arquivo temporario para importacao                     ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �Reproweb                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function FINA996Tmp()

Local aArqPRO   := {}                                 
Local aArqTmp	:= {}
Local aOrdem := {}

AADD(aArqPRO,{"CUIT"    ,"C",11 ,0})
AADD(aArqPRO,{"PERFISC" ,"C",04 ,0})
AADD(aArqPRO,{"PORC"	,"C",03 ,0})
AADD(aArqPRO,{"DTPUBLI" ,"C",10 ,0})
AADD(aArqPRO,{"DTVIGEN"	,"C",10 ,0})
AADD(aArqPRO,{"IMPORT"		,"C",01,0}) 
AADD(aArqPRO,{"ERRO"		,"C",35,0}) 

oTmpTable := FWTemporaryTable():New("PRO")
oTmpTable:SetFields( aArqPRO ) 

aOrdem	:=	{"CUIT"} 

oTmpTable:AddIndex("IN1", aOrdem) 

oTmpTable:Create() 

aArqTmp := {{"oTmpTable","PRO"}}

Return(aArqTmp)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  � FINA996Le  �Autor  �   Bruno Schmidt    � Data � 20/02/2013  ���
���������������������������������������������������������������������������͹��
���Desc.     �Le arquivo de retorno e carrega o arquivo temporario          ���
���          �para atualizar cadastro de Fornecedor.                        ���
���������������������������������������������������������������������������͹��
���Uso       �Reproweb                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function FINA996Le(aArqTmp)

Local aWizard		:= {}
Local aInforma      := {}
	
Local lRet			:= !xMagLeWiz("Rproweb",@aWizard,.T.)
	
Local cArqProc		:= Alltrim(aWizard[01][01])
Local cTitulo		:= ""
Local cErro			:= ""
Local cSolucao		:= ""
Local cLinha		:= ""
Local cChar			:= ""

Local lCarga		:= .F.   
Local lArqValido	:= .F.

Local nCont			:= 0
Local nX            := 0 

//���������������������������������������������
//�Cria o arquivo temporario para a importacao�
//���������������������������������������������
aArqTmp := FINA996TMP()                                  

//����������������������������������������������������
//�Verifica se o arquivo existe no diretorio indicado�
//����������������������������������������������������
If File(cArqProc) .And. !lRet

	nHandle	:=	FOpen(cArqProc)
	nTam	:=	FSeek(nHandle,0,2)
	FSeek(nHandle,0,0)
	ProcRegua(nTam)

	FT_FUse(cArqProc)
	FT_FGotop()

	//�����������������������������������������������������������������������Ŀ
	//�Verifica se o arquivo aberto e um arquivo valido com o mesmo CGC do SM0�
	//�������������������������������������������������������������������������
	lArqValido 	:= .T.	
	cChar  		:= "."       
	nCont	    := 0
	
	cLinha := ""
  	cLinha := FT_FREADLN()	
	
	If lArqValido 
		FT_FGotop()
		FSeek(nHandle,0,0)
		cChar  := ","		
		cLinha := ""		

		While (!FT_FEof()) 		
			IncProc()
			cLinha := ""        
			aDadosSA := {}
		    aInforma := {}	            
   			cLinha := FT_FREADLN()
        	RecLock("PRO",.T.)
        			For nX := 1 to 8
        				If nX ==  8
        			   	 	AADD (aInforma,Alltrim(SubStr(cLinha,1,(nPos-1))))
        				Else
	        	        	nPos := at(";",cLinha)
	        	        	AADD (aInforma,Alltrim(SubStr(cLinha,1,(nPos-1))))
	        	        	cLinha := SubStr(cLinha,nPos+1,Len(cLinha))
	        	        EndIf	
        	        nEXT
					PRO->CUIT  	 := aInforma [2]
					PRO->PERFISC := aInforma [4] 
					PRO->PORC  	 := aInforma [5] 
					PRO->DTPUBLI :=  aInforma [7] 
					PRO->DTVIGEN := aInforma [8] 
				
			FT_FSkip()
		Enddo 
		lCarga := .T.        
	Else
		lCarga := .F.
	Endif	
	FT_FUse()
	FClose(nHandle)
Else 
	cTitulo 	:= STR0011 						//"Arquivo de importa��o n�o localizado"	
	cErro		:= STR0012 + cArqProc			//"N�o foi localizado no diret�rio "
	cErro		+= STR0013 + STR0014 	        //" o arquivo "," indicado nas perguntas "
	cErro		+= STR0015 						//"da rotina."
	cSolucao	:= STR0016 						//"Informe o diret�rio e o nome do arquivo "
	cSolucao	+= STR0017 						//"corretamente e processe a rotina novamente."
	xMagHelpFis(cTitulo,cErro,cSolucao)
	lCarga := .F.
Endif

Return({lCarga,cArqProc})

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �FINA996ATU  �Autor  �	  Bruno Schmidt    � Data � 20/02/2013  ���
���������������������������������������������������������������������������͹��
���Desc.     �Atualiza tabela do Protheus com as informacoes retornadas     ���
���          �pela tabela de Fornecedores                        	        ���
���������������������������������������������������������������������������͹��
���Uso       �Reproweb                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/                                                                                                    
Static Function FINA996ATU(cCarga,nRegProc,nRegAtu)


	nRegProc := PRO->(LastRec())
	ProcRegua(nRegProc)

	SA2->(dbSetOrder(3))

	PRO->(dbGoTop())
	While !(PRO->(Eof()))

		IncProc()
		//��������������������������������Ŀ
		//�Atualizando tabelas posicionadas�
		//����������������������������������
		If SA2->(MsSeek(xFilial("SA2")+Alltrim(PRO->CUIT)))
			While !SA2->(EOF()) .And. xFilial("SA2") == SA2->A2_FILIAL .And. Alltrim(PRO->CUIT) == Alltrim(SA2->A2_CGC)
				Begin Transaction
					RecLock("SA2",.F.)
					SA2->A2_PORGAN	:= 100 - Val(PRO->PORC)
					If FieldPos("A2_DTICALG") > 0 .And. FieldPos("A2_DTFCALG") > 0
						SA2->A2_DTICALG	:= Ctod(PRO->DTPUBLI)
						SA2->A2_DTFCALG := Ctod(PRO->DTVIGEN)
					EndIf
					MsUnLock()
				End Transaction
				SA2->(dbSkip())
			EndDo

			nRegAtu++
			
			RecLock("PRO",.F.)
			PRO->ERRO :=STR0041 //"Importado"
			MsUnLock()
		Else
			//����������������������������������������������Ŀ
			//�Se houve algum erro na atualizacao das tabelas�
			//������������������������������������������������
			RecLock("PRO",.F.)
			PRO->IMPORT	:= "1"
			PRO->ERRO	:= STR0031 //"Fornecedor n�o encontrado"
			MsUnLock() 	
		EndIf
		PRO->(dbSkip())
	Enddo


Return(.T.)	
