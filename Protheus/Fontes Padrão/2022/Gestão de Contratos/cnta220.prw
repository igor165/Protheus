#INCLUDE "CNTA220.CH"
#INCLUDE "PROTHEUS.CH"

Static lLGPD := FindFunction("SuprLGPD") .And. SuprLGPD()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �CN220Aval � Autor � Marcelo Custodio      � Data �15.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Avalia��o Contrato X Fornecedor                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN220Aval(cExp01,nExp02,nExp03,xExp04,lExp05,cExp06,cExp07,���
���          �           cExp08)                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA100,CNTA150                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� -cExp01 - Alias do arquivo                                 ���
���          � -nExp02 - Registro do contrato                             ���
���          � -nExp03 - Opcao                                            ���
���          � -xExp04 - Array padrao do aRotina                          ���
���          � -lExp05 - Apenas visualizacao                              ���
���          � -cExp06 - Situacao alterada do contrato                    ���
���          � -cExp07 - Codigo do fornecedor quando visualizacao         ���
���          � -cExp08 - Loja do fornecedor quando visualizacao           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN220Aval(cAlias,nReg,nOpc,xFiller,lVisu,cSituac,cForn,cLoja,cContra,cRevisa)
Local lForn      := (cForn != Nil)//Exibe historico do fornecedor
Local aSituac    := {}

Local cFilCod    := 0
Local nx          := 0
Local nCntFor    := 0
Local nPos       := 0

Local cCampo     := ""
Local cQuery     := ""
Local cAliasQry  := ""
Local cNmForn    := ""
Local cDescSt    := ""

Local lHist
//������������������������������������������������������Ŀ
//� Controles visuais                                    �
//��������������������������������������������������������
Local aSize     := MsAdvSize( .F. )
Local aObjects  := {}
Local aPosObj   := {}
Local aPosObj2  := {}
Local nPosForn  := 0
Local nY	      := 0
Local nPosNome  := 0
//������������������������������������������������������Ŀ
//� Controles das getdados                               �
//��������������������������������������������������������
Local oPanel,oGetDad1,oGetDad2
Local aHeader := {}
Local aHeader1:= {}
Local aCols   := {}
Local aCols1  := {}
Local aNoFields:= {"CNM_FILIAL","CNM_CDAVAL"}//Campos nao exibidos na getdados
Local aBox      := {}
Local aStruCNM := {} 

Local bCondicao:= {|| .T. }    
Local cWhile   := ""   //Condicao While para montar o aCols
Local cSeek	   := "" 
Local cFilCNM  := ""

Local lRet     := .T.      
Local lCN220AVF:= .T.
Local lCNM     := .F.
Local aAlter   := {}	

Default cContra := ""
Default cRevisa := ""
Default lVisu 	:= .T.//Apenas Visualizacao

dbSelectArea("SX3")
dbSetOrder(2)
lCNM := dbSeek("CNM_FORNEC")


//Ponto de entrada para permitir ou n�o a execu��o da Avalia��o dos Fornecedores.
If ExistBlock("CN220AVF")
	lCN220AVF := ExecBlock("CN220AVF",.F.,.F.)
	If valtype(lCN220AVF) == "L"
		lRet := lCN220AVF
	EndIf
EndIf


If lRet
	If lCNM
		//������������������������������������������������������Ŀ
		//� Configura variavel para exibicao da situacao do      �
		//� contrato                                             �
		//��������������������������������������������������������
		If cSituac != Nil
			aSituac:= RetSx3Box( Posicione("SX3", 2, "CN9_SITUAC", "X3CBox()" ),,, 1 )
			cDescSt:= AllTrim( aSituac[Ascan( aSituac, { |aBox| substr(aBox[1],1,At("=",aBox[1])-1) = AllTrim(cSituac)} )][3] )
		EndIf
		
		If !lForn
			//������������������������������������������������������Ŀ
			//� Quando visualizacao pelo contrato nao exibe numero   �
			//� de contrato                                          �
			//��������������������������������������������������������
			aAdd(aNoFields,"CNM_CONTRA")
		Else
			//������������������������������������������������������Ŀ
			//� Quando visualizacao pelo fornecedor nao exibe campos �
			//� dos fornecedores                                     �
			//��������������������������������������������������������
			aAdd(aNoFields,"CNM_FORNEC")
			aAdd(aNoFields,"CNM_LOJA")
			aAdd(aNoFields,"CNM_NOME")
			
			//������������������������������������������������������Ŀ
			//� Seleciona nome do fornecedor                         �
			//��������������������������������������������������������
			dbSelectArea("SA2")
			dbSetOrder(1)
			If dbSeek(xFilial("SA2")+cForn+cLoja)
				cNmForn := SA2->A2_NOME
			EndIf
		EndIf
		
		If nReg != Nil
			dbSelectArea("CN9")
			dbGoTo(nReg)
			cContra := CN9->CN9_NUMERO
			cRevisa := CN9->CN9_REVISA
		EndIf
		
		//������������������������������������������������������Ŀ
		//� Verifica se exibe historico durante a avaliacao      �
		//��������������������������������������������������������
		dbSelectArea("CNM")
		If !lForn
			dbSetOrder(1)
			lHist := dbSeek(xFilial("CNM")+cContra)
		Else
			dbSetOrder(2)	
			lHist := dbSeek(xFilial("CNM")+cForn+cLoja)
		EndIf
		
		If (lVisu .And. lHist) .Or. !lVisu
			//������������������������������������������������������Ŀ
			//� Configura componentes visuais                        �
			//��������������������������������������������������������
			aObjects := {}
			AAdd( aObjects, { 230, 030, .T., .F., .T. } )//Painel superior
			AAdd( aObjects, { 230, 200, .T., .T., .F. } )//GetDados
			AAdd( aObjects, { 120, 20, .T., .F., .F. } )//Botoes
			
			aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
			aPosObj  := MsObjSize( aInfo, aObjects, .T., .F. )
			
			aObjects := {}
			If lHist
				AAdd( aObjects, { 115, 200, .T., .T., .F. } )//GetDados de historico
			EndIf
			//������������������������������������������������������Ŀ
			//� Inclui getdados para preenchimento                   �
			//��������������������������������������������������������
			If !lVisu
				AAdd( aObjects, { 115, 200, .T., .T., .F. } )//GetDados a preencher
				nPosForn := len(aObjects)
			EndIf
			
			aInfo    := { aPosObj[2,2],aPosObj[2,1], aPosObj[2,4], aPosObj[2,3], 3, 3 }
			aPosObj2  := MsObjSize( aInfo, aObjects, .T., .T. )
			
		   If lHist
				//������������������������������������������������������Ŀ
				//� Filtra historico do contrato/fornecedor              �
				//��������������������������������������������������������
	   			dbSelectArea("CNM")   
	   			dbSetOrder(1)    
				aStruCNM := CNM->(dbStruct())

				If Empty(Ascan(aStruCNM,{|x| x[2]=="M"}))
					cQuery := "SELECT CNM.* FROM " + RetSQLName("CNM") + " CNM "
					cQuery += " WHERE CNM.CNM_FILIAL = '"+ xFilial("CNM") +"' AND "
					If !lForn
						cQuery += "   CNM.CNM_CONTRA = '"+ cContra +"' AND "//Filtra Contrato
					Else
						cQuery += "   CNM.CNM_FORNEC = '"+ cForn   +"' AND "//Filtra Fornecedor
						cQuery += "   CNM.CNM_LOJA   = '"+ cLoja   +"' AND "
					EndIf
					cQuery += "       CNM.D_E_L_E_T_ = ' ' "
					cQuery += "ORDER BY CNM.CNM_CONTRA,CNM.CNM_DTAVAL,CNM.CNM_SITUAC,CNM.CNM_FORNEC,CNM.CNM_LOJA"
				EndIf     
				
				If !lForn  
					dbSelectArea("CNM")   
		   			dbSetOrder(1)            
					cSeek   := xFilial("CNM")+cContra
					cWhile  := "CNM_FILIAL+CNM_CONTRA" 
				Else    
					dbSelectArea("CNM")   
		   			dbSetOrder(1)            
					cSeek   := xFilial("CNM")+cContra+cForn+cLoja	
					cWhile  := "CNM_FILIAL+CNM_CONTRA+CNM_FORNEC+CNM_LOJA"    			
				EndIf      
				
				
				FillGetDados(2,"CNM",1,cSeek,{|| &cWhile },bCondicao,aNoFields,,,cQuery,,,aHeader,aCols,{|aColsX| CN220LdMe(aColsX,aHeader,cAliasQry) })
			
			EndIf

			nPosNome := aScan(aHeader,{|x| AllTrim(x[2]) == "CNM_NOME"})
			If nPosNome > 0
				For nY:=1 To Len(aCols)
					If Empty(aCols[nY][nPosNome])
						aCols[nY][nPosNome] := Posicione( "SA2", 1, xFilial("SA2") + aCols[nY][1]+aCols[nY][2], "A2_NOME" )
					EndIf
				Next
			EndIf
		
			//����������������������������������������������������������Ŀ
			//� Quando nao for visualizacao gera acols para preenchimento�
			//� dos fornecedores do contrato                             �
			//������������������������������������������������������������
			If !lVisu
				//���������������������������������������������Ŀ
				//� Exclui campos da inclusao                   �
				//�����������������������������������������������
				aAdd(aNoFields,"CNM_DTAVAL")
				aAdd(aNoFields,"CNM_SITUAC")
				
				//�������������������������������������������������������Ŀ
				//� Monta aheader da inclusao de avaliacao                �
				//���������������������������������������������������������
				FillGetDados(nOpc,"CNM",1,,,{|| .T. },aNoFields,,,cQuery,,.T.,aHeader1)
		
		
				cFilCod := xFilial("CNC")
		  		dbSelectArea("CNC")
				dbSetOrder(1)
				dbSeek(cFilCod+CN9->CN9_NUMERO+CN9->CN9_REVISA)
				
				//�������������������������������������������������������Ŀ
				//� Filtra fornecedores da CNC                            �
				//���������������������������������������������������������
				While !Eof() .And. CNC->CNC_FILIAL = cFilCod .And. CNC->CNC_NUMERO == CN9->CN9_NUMERO .And. CNC->CNC_REVISA == CN9->CN9_REVISA
					dbSelectArea("CNM")
					aAdd(aCols1,Array(Len(aHeader1)+1))
					
					For nx:=1 to len(aHeader1)
						Do Case
							Case aHeader1[nX,2] == "CNM_FORNEC"
								aCols1[Len(aCols1)][nX] := CNC->CNC_CODIGO
							Case aHeader1[nX,2] == "CNM_LOJA  "
								aCols1[Len(aCols1)][nX] := CNC->CNC_LOJA
							Case aHeader1[nX,2] == "CNM_NOME  "
								aCols1[Len(aCols1)][nX] := Posicione( "SA2", 1, xFilial("SA2") + CNC->CNC_CODIGO+CNC->CNC_LOJA, "A2_NOME" )
							Case aHeader1[nX,10] != "V"
								aCols1[Len(aCols1)][nX] := CriaVar(aHeader1[nX,2])
						EndCase
					Next
					
					aCols1[Len(aCols1)][len(aHeader1)+1] := .F.
					
					dbSelectArea("CNC")
					dbSkip()
				EndDo
			EndIf
			
			DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From aSize[7],0 TO aSize[6],aSize[5] PIXEL//"Avalia��o Fornecedor X Contrato"
			
			@ aPosObj[1,1], aPosObj[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj[1,3],aPosObj[1,4] OF oDlg
			
			If !lForn
				//�������������������������������������������������������Ŀ
				//� Informacoes do contrato                               �
				//���������������������������������������������������������
				@ 001,000 Say  OemToAnsi(STR0002) Of oPanel PIXEL//"Contrato"
				@ 000,024 MsGet oGet1 Var cContra When .F. PIXEL  Size 50,5 Of oPanel
				
				@ 001,090 Say  OemToAnsi(STR0003) Of oPanel PIXEL//"Revisao"
				@ 000,114 MsGet oGet2 Var cRevisa When .F. PIXEL  Size 50,5 Of oPanel
				
				If !lVisu
					@ 012,000 Say RetTitle("CN9_SITUAC") Of oPanel PIXEL//"Situacao"
					@ 011,024 MsGet oGet3 Var cDescSt When .F. PIXEL  Size 50,5 Of oPanel
				EndIf
				
				If lHist
					@ aPosObj2[1,1]-007,aPosObj2[1,2] Say OemToAnsi(STR0007) Of oDlg PIXEL//"Hist�rico do Contrato"
				EndIf
			Else
				//�������������������������������������������������������Ŀ
				//� Informacoes do fornecedor                             �
				//���������������������������������������������������������
				@ 001,000 Say  OemToAnsi(STR0004) Of oPanel PIXEL//"Cod. Forn."
				@ 000,030 MsGet oGet1 Var cForn When .F. PIXEL  Size 50,5 Of oPanel
				
				@ 001,100 Say  OemToAnsi(STR0005) Of oPanel PIXEL//"Loja Forn."
				@ 000,130 MsGet oGet2 Var cLoja When .F. PIXEL  Size 50,5 Of oPanel
				
				@ 012,000 Say  OemToAnsi(STR0006) Of oPanel PIXEL//"Nome Forn."
				@ 011,030 MsGet oGet3 Var cNmForn When .F. PIXEL  Size 50,5 Of oPanel
				If(lLGPD,OfuscaLGPD(oGet3,"A2_NOME"),.F.)
		
				@ aPosObj2[1,1]-007,aPosObj2[1,2] Say OemToAnsi(STR0014) Of oDlg PIXEL//"Hist�rico do Fornecedor"
			EndIf
			
			@ aPosObj[2,1]-010,aPosObj[2,2] GROUP oGroup To aPosObj[2,3],aPosObj[2,4] Of oDlg PIXEL
			
			oGetDad1 := MsNewGetDados():New(aPosObj2[1,1],aPosObj2[1,2],aPosObj2[1,3],aPosObj2[1,4],0,,,,,,,,,,oDlg,aHeader,aCols)			
			
			aAlter := {"CNM_AVALIA","CNM_NOTA"}
			SX3->(DbSetOrder(1))
			SX3->(DbSeek("CNM"))
			While ( SX3->(!Eof() .And. AllTrim(X3_ARQUIVO) == 'CNM' ))
				If(SX3->(AllTrim(X3_PROPRI) == 'U' .And. AllTrim(X3_VISUAL) != 'V'))
					aAdd(aAlter, AllTrim(SX3->X3_CAMPO))
				EndIf				
				SX3->(dbSkip())
			EndDo			
			
			If !lVisu
				@ aPosObj2[nPosForn,1]-007,aPosObj2[nPosForn,2] Say OemToAnsi(STR0008) Of oDlg PIXEL//"Fornecedores"
				oGetDad2 := MsNewGetDados():New(aPosObj2[nPosForn,1],aPosObj2[nPosForn,2],aPosObj2[nPosForn,3],aPosObj2[nPosForn,4],(GD_UPDATE+GD_DELETE),,,,aAlter,,,,,,oDlg,aHeader1,aCols1)
			EndIf
			
			DEFINE SBUTTON FROM aPosObj[3,1], aPosObj[3,4]-65 TYPE 1 ACTION (If (!lVisu,If(CN220Grv(oGetDad2:aCols,aHeader1,cContra,cSituac,oGetDad2,cRevisa),oDlg:End(),),oDlg:End())) ENABLE OF oDlg
			DEFINE SBUTTON FROM aPosObj[3,1], aPosObj[3,4]-35 TYPE 2 ACTION (If(lVisu .OR. (Aviso("CNTA220",OemToAnsi(STR0010),{OemToAnsi(STR0012),OemToAnsi(STR0011)})==2),oDlg:End(),)) ENABLE OF oDlg
			
			ACTIVATE MSDIALOG oDlg CENTERED
		Else
			Aviso( STR0018, If(lForn,STR0017,STR0016), { "OK" }, 2 )//"Atencao"##"O contrato n�o possui avalia��o!"##"O contrato n�o possui avalia��o!"
		Endif
	Else
		Aviso("CNTA220",OemToAnsi(STR0013),{"OK"})//"Imposs�vel executar rotina de valida��o dos fornecedores, tabela 'CNM' inexistente na estrutura do SX3."
	EndIf
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �CN220Grv  � Autor � Marcelo Custodio      � Data �15.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Gravacao da avaliacao dos fornecedores                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN220Grv(aExp01,aExp02,cExp03,cExp04)                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA100,CNTA150                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� -aExp01 - Acols com as avaliacoes                          ���
���          � -aExp02 - Cabecalho da getdados                            ���
���          � -cExp03 - Codigo do contrato                               ���
���          � -cExp04 - Codigo da situacao                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN220Grv(aCols,aHeader,cContra,cSituac,oGetDad2,cRevisa)
Local nx,ny
Local nPosCpo
Local nPos
Local lRet := .T.
Local nPosNota := aScan(aHeader,{|x| AllTrim(x[2]) == "CNM_NOTA"})

//�������������������������������������������������������Ŀ
//� Verifica se algum fornecedor nao foi avaliado         �
//���������������������������������������������������������
If (nPos := aScan(aCols,{|x| !x[len(aheader)+1] .And. Empty(x[nPosNota])})) > 0
	Aviso("CNTA220",OemToAnsi(STR0009),{"OK"})//"Todos os fornecedores devem ser avaliados"
	lRet := .F.
Else
	//�������������������������������������������������������Ŀ
	//� Grava registros dos fornecores                        �
	//���������������������������������������������������������
	dbSelectArea("CNM")
	For nx:=1 to len(aCols)
		if !aCols[nx,len(aheader)+1]
			RecLock("CNM",.T.)
			For ny:=1 to Fcount()
				If (nPosCpo := aScan(aHeader,{|x| AllTrim(x[2]) == FieldName(ny)})) > 0 .And. aHeader[nPosCpo,10] <> "V"
					CNM->&(aHeader[nPosCpo,2]) := aCols[nx,nPosCpo]
				Endif
			Next
			CNM->CNM_FILIAL := xFilial("CNM")
			CNM->CNM_CONTRA := cContra
			If CNM->(Columnpos('CNM_REVGER')) > 0
				CNM->CNM_REVGER := cRevisa
			EndIf
			CNM->CNM_SITUAC := cSituac
			CNM->CNM_DTAVAL := dDataBase
			MsUnlock()
			//�������������������������������������������������������Ŀ
			//� Configura campo MEMO                                  �
			//���������������������������������������������������������
			MSMM(CNM->CNM_CDAVAL,,,aCols[nx,aScan(aHeader,{|x| x[2] == "CNM_AVALIA"})],1,,,"CNM","CNM_CDAVAL")
		EndIf
	Next
EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �CN220LdMe � Autor � Marcelo Custodio      � Data �19.01.2007���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Preenche campo Memo no aCols                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN220Grv(aExp01,aExp02)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� -aExp01 - Acols com as avaliacoes                          ���
���          � -aExp02 - Cabecalho da getdados                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN220LdMe(aColsX,aHeader)
Local nPosAval := 0

//�����������������������������������������Ŀ
//� Verifica posicao dos campos             �
//�������������������������������������������
If !Empty(CNM_CDAVAL) .And. (nPosAval := aScan(aHeader,{|x| x[2]=="CNM_AVALIA"})) > 0
	aColsX[Len(aColsX),nPosAval] := MSMM(CNM_CDAVAL)
EndIf

Return .T.
