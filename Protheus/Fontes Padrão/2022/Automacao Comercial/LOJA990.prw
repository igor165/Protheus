#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA990.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �loja990   �Autor  �TOTVS               � Data �  12/11/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Exibe o historico de montagens do uMov, ref. a OS          ���
�������������������������������������������������������������������������͹��
���Uso       � uMov                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HisImpUMov(cChave)
Local oList    := Nil //Objeto do Listbox  
Local oDlguMov := Nil //Dialogo principal
Local aDados   := {}  // Contem as montagens importadas do uMov

aDados:= LJCARDADOS(cChave) //Carregar os resgistros das importa��es de montagem

If !Empty(aDados)

    DEFINE MSDIALOG oDlguMov TITLE OemToAnsi() FROM 000,000 TO 385,625 PIXEL //"Hist�rico de montagens."

    @ 005,003 LISTBOX oList FIELDS HEADER ,;                                     
                                      STR0003,;//"Status"
									  STR0004,;//"OS"
									  STR0005,;//"Rev"
									  STR0006,;//"Prod."
                                  	  STR0007,;//"Descri��o"
                                   	  STR0008,;//"Dt. Montagem"
									  STR0009,;//"Hr. Montagem"
                                      STR0010,;//"Obs.Montagem"
                                      STR0011,;//"Foto pos montagem"
                                      STR0012,;//"Dt Importa��o"
                                      STR0013,;//"Hr Importa��o"
                                      STR0014,;//"Dt. Solicita��o"
                                      STR0015,;//"Hr. Solicita��o"
                                      STR0016 SIZE 308,120 PIXEL //"Usuario"



	oList:SetArray(aDados)
	oList:cToolTip := "Duplo-clique no registro para visualizar a foto p�s montagem."
	oList:bLine := { || { CorLed(aDados,oList:nAt),aDados[oList:nAt,1],aDados[oList:nAt,2],aDados[oList:nAt,3],aDados[oList:nAt,4],;
	                      aDados[oList:nAt,5],aDados[oList:nAt,6],aDados[oList:nAt,7],aDados[oList:nAt,8],aDados[oList:nAt,9],;
	                      aDados[oList:nAt,10],aDados[oList:nAt,11],aDados[oList:nAt,12],aDados[oList:nAt,13],aDados[oList:nAt,14]}}
	oList:bLDblClick := {|| VerImg(aDados[oList:nAt,9])} 
	oList:GoTop()
	oList:Refresh()
	
	@ 130,010 TO 180,120 Label STR0017 OF oDlguMov PIXEL COLOR CLR_BLUE //Legenda :                 
	
	@ 145,020 BITMAP oBmp2 ResName "BR_VERDE" OF oDlguMov Size 10,10 NoBorder When .F. Pixel 
	@ 145,030 SAY  STR0018 OF oDlguMov PIXEL //"Completa"
	
	@ 155,020 BITMAP oBmp1 ResName "BR_AMARELO" OF oDlguMov Size 10,10 NoBorder When .F. Pixel                                        
	@ 155,030 SAY STR0019 OF oDlguMov PIXEL //"Pendente"
	
	@ 165,020 BITMAP oBmp2 ResName "BR_VERMELHO" OF oDlguMov Size 10,10 NoBorder When .F. Pixel 
	@ 165,030 SAY STR0020  OF oDlguMov PIXEL //"N�o realizada"
	
	DEFINE SBUTTON oBTN1 FROM 175,250 TYPE 1 ACTION LJGeraTarefauMov(cChave,oList:nAt,aDados,@oList) ENABLE OF oDlguMov PIXEL 
	oBTN1:cCaption := STR0021 //"Tarefa"
	oBTN1:CTOOLTIP := STR0022 //"Selecione um produto com montagem pendente para habilit�-lo novamente para ser gerado uma nova tarefa de montagem."
	
	DEFINE SBUTTON oBTN2 FROM 175,280 TYPE 1 ACTION oDlguMov:End() ENABLE OF oDlguMov PIXEL
	oBTN2:cCaption := STR0023 //"Fechar"
	
	ACTIVATE MSDIALOG oDlguMov CENTERED
Endif
	
Return(.T.)


/*���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �LJCARDADOS    �Autor  �TOTVS               � Data � 12/11/13    ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna os valores que serao impressos pelo painel             ���
�����������������������������������������������������������������������������Ĵ��
��� obs.:    � Se o atendimento estiver aberto significa que falta montar item���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Static Function LJCARDADOS(cChave)
Local aArea  	:= GetArea() //salva a area atual
Local aDados    := {} // Contem as montagens importadas do uMov
Local cQuery    := "" // Texto SQL que � enviado para o comando TCGenQry
Local cStatus   := "" // Trata a descricao do status da montagem

If  !Empty(AB9->AB9_NUMOS)
	cQuery :=	" SELECT * " +;
			" FROM 	" + RetSqlName("MG4") +;
			" WHERE MG4_FILIAL = '"+alltrim(xFilial("AB9"))+"'"+;
			" AND MG4_NUMLOJ    = '"+alltrim(cChave)+"'"+;
			" AND D_E_L_E_T_ = ''" +;
			" ORDER BY MG4_REV "
 
	cQuery := ChangeQuery(cQuery)
	
	DbSelectArea("MG4")
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F., .T.)
	
	If !Empty(TRB->(!Eof()))
		While TRB->(!Eof()) 			

			If TRB->MG4_STATUS == "1"    
				cStatus := STR0018//"Completa"
			ElseIf TRB->MG4_STATUS = "2" 
				cStatus := STR0019//"Pendente"
			ElseIf TRB->MG4_STATUS = "3" 
				cStatus :=STR0020//"N�o realizada"
			Endif	

		   	Aadd(aDados,{ cStatus,;
			    	   	  TRB->MG4_NUMLOJ,;
			    	   	  TRB->MG4_REV,;
			    	   	  TRB->MG4_PRODUT,;
		   	              Posicione("SB1",1,xFilial("SB1")+TRB->MG4_PRODUT,"B1_DESC"),;
		   	              stod(TRB->MG4_DTMONT),;
		   	              TRB->MG4_HRMONT,;
		   	              TRB->MG4_OBSERV,;
		   	              TRB->MG4_FOTO,;
		   	              stod(TRB->MG4_DTPROT),;//Data que foi importado para o Protheus
		   	              TRB->MG4_HRPROT,;//Hora que foi importado para o Protheus
		   	              stod(TRB->MG4_DTSOLI),;
		   	              TRB->MG4_HRSOLI,;
		   	              TRB->MG4_USU})

			TRB->(dbSkip())
		
		EndDo
	Else
      MSGAlert(STR0025,STR0024)//"N�o existe registro de importa��es de montagens."##"Aten��o"
    Endif	 
	
	TRB->(DbCloseArea())
	RestArea(aArea)
	
Else
      MSGAlert(STR0025,STR0024)//"N�o existe registro de importa��es de montagens."##"Aten��o"
Endif

Return aDados

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �loja990 �Autor  �TOTVS	     � Data �  12/11/2013         ���
�������������������������������������������������������������������������͹��
���Desc.     � Led dos status das montagens                               ���
�������������������������������������������������������������������������͹��
���Sintaxe	 � CorLed(aDados)				              				  ���
�������������������������������������������������������������������������͹��
���Parametro � aDados - posicao na linha    			                  ���
�������������������������������������������������������������������������͹��
���Uso       � Loja                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CorLed(aDados,nAt)
Local oLed    	:= "" //Objeto principal de retorno
Local oVerde  	:= LoaDbitmap(GetResources(),"BR_VERDE")   //carrega a imagem do reposit�rio no objeto	
Local oAmarelo  := LoaDbitmap(GetResources(),"BR_AMARELO") //carrega a imagem do reposit�rio no objeto
Local oVermelho := LoaDbitmap(GetResources(),"BR_VERMELHO")//carrega a imagem do reposit�rio no objeto

If !Empty(aDados)
	If alltrim(aDados[nAt,1]) == STR0018//"Completa"
		oLed:= oVerde
	Else
		If alltrim(aDados[nAt,1]) == STR0019//"Pendente"
			oLed:= oAmarelo
		Else
			oLed:= oVermelho //"N�o realizada"
		Endif	
	Endif			
Endif
			
Return(oLed)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �loja990 �Autor  �TOTVS	     � Data �  18/11/2013         ���
�������������������������������������������������������������������������͹��
���Desc.     � Led dos status das montagens                               ���
�������������������������������������������������������������������������͹��
���Sintaxe	 � VerImg(aDados)				              				  ���
�������������������������������������������������������������������������͹��
���Parametro � cEndereco - endereco url da foto 		                  ���
��������������������������������������������������������������o����������͹��
���Uso       � Loja                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VerImg(cEndereco)
Local oDlg       := Nil  //Objeto principal
Local oTIBrowser := Nil  //Cria um objeto do tipo p�gina de internet.
Local aSize      := MsAdvSize()// Size da Dialog - Funcao de calculo para coordenadas de tela.
Local cUrl       := cEndereco // endereco da foto

// Atualiza as corrdenadas da Janela MAIN
oMainWnd:CoorsUpdate()
nMyWidth  := oMainWnd:nClientWidth - 10
nMyHeight := oMainWnd:nClientHeight - 30
 
If !Empty(cUrl)
  DEFINE DIALOG oDlg TITLE STR0026 From aSize[7],00 To nMyHeight,nMyWidth PIXEL//"Foto"
  oTIBrowser := TIBrowser():New(07,07,nMyHeight-220, nMyWidth-820,cUrl,oDlg)
  oTIBrowser:GoHome()

  ACTIVATE DIALOG oDlg CENTERED 

Else
   MsgAlert(STR0027)//"N�o foi inserida nenhuma imagem para essa montagem!"
EndIf

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �loja990 �Autor  �TOTVS              � Data �  19/11/2013    ���
�������������������������������������������������������������������������͹��
���Desc.     � Zera a data e a hora do SL1 e dos itens do SL2 para gerar  ���
���          � novamente um tarefa no umov                                ��� 
�������������������������������������������������������������������������͹��
���Sintaxe	 � LJGeraTarefauMov(aDados)			          				  ���
�������������������������������������������������������������������������͹��
���Parametro � aDados - posicao na linha    			                  ���
�������������������������������������������������������������������������͹��
���Uso       � Loja                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LJGeraTarefauMov(cChave,nAt,aDados,oList)                                                                                             
Local lOk  := .F. //controla a atualizacao da SL1
Local nRev := 0   //controla a revis�o do atendimento que esta sendo solicitada

If alltrim(aDados[nAt,1]) <> STR0018 //"Completa" - so podera gerar uma nova tarefa se o status do item for diferente de completa
	DbSelectArea("SL2")
	SL2->(DbSetOrder(1))//L2_FILIAL+L2_NUM                                                                                                                            
	If SL2->(DbSeek(xFilial("SL2")+alltrim(cChave)))
		While SL2->(!Eof()) .And. (SL2->L2_FILIAL+SL2->L2_NUM) == (xFilial("SL2")+alltrim(cChave))
			If alltrim(SL2->L2_PRODUTO) == alltrim(aDados[nAt,4])
				RecLock("SL2",.F.)
				SL2->L2_DTUMOV := Ctod("  /  /  ","DDMMYY")
				SL2->L2_HRUMOV := ""
				SL2->(MsUnlock())	    				
			Endif	
			SL2->(dbSkip())
		Enddo	
		If lOk 
			MsgAlert(STR0028,STR0024)//"Solicita��o gerada com sucesso!"##"Aten��o"
			lOk  := .F.
		Else
			MsgAlert(STR0028,STR0024)//"Solicita��o gerada com sucesso!"##"Aten��o"
			lOk  := .F.			
		Endif
			
   
		//Atualizacao da data e hora que foi solicitada uma nova tarefa de montagem no uMov
		DbSelectArea("MG4")                                                    
		MG4->(dbGoTop())
		MG4->(DbSetOrder(1))//MG4_FILIAL+MG4_NUMLOJ+MG4_PRODUT+MG4_REV     
		nRev :=  PadL(alltrim(str(aDados[nAt,3])),2)
		If MG4->(DbSeek(xFilial("AB9")+alltrim(cChave)))
			While MG4->(!Eof()) .And. (MG4->MG4_FILIAL+alltrim(MG4->MG4_NUMLOJ)) == (xFilial("MG4")+alltrim(cChave))
				If alltrim(MG4->MG4_PRODUT) == alltrim(aDados[nAt,4]) .And. alltrim(str(MG4->MG4_REV)) == alltrim(nRev)
					RecLock("MG4",.F.)
					MG4->MG4_DTSOLI := dDataBase
					MG4->MG4_HRSOLI := SubStr( StrTran(Time(),":",""),1,2)+":"+SubStr( StrTran(Time(),":",""),3,2)
					MG4->MG4_USU    := cUserName
					MG4->(MsUnlock())           
					aDados[nAt,12] :=  dDataBase
					aDados[nAt,13] :=  SubStr( StrTran(Time(),":",""),1,2)+":"+SubStr( StrTran(Time(),":",""),3,2)
					aDados[nAt,14] := cUserName
				Endif
				MG4->(dbSkip())		
			EndDo	
		Endif
	
		LJCARDADOS(cChave)
		oList:SetArray(aDados)
		oList:bLine := { || { CorLed(aDados,oList:nAt),aDados[oList:nAt,1],aDados[oList:nAt,2],aDados[oList:nAt,3],aDados[oList:nAt,4],;
	                      aDados[oList:nAt,5],aDados[oList:nAt,6],aDados[oList:nAt,7],aDados[oList:nAt,8],aDados[oList:nAt,9],;
	                      aDados[oList:nAt,10],aDados[oList:nAt,11],aDados[oList:nAt,12],aDados[oList:nAt,13],aDados[oList:nAt,14]}}
		oList:GoTop()
		oList:Refresh()
	Endif	
Else
	MsgAlert(STR0029,STR0024)//"O status desse item esta completo!"##"Aten��o"
Endif

Return Nil
