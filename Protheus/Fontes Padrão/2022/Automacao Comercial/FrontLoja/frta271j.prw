#INCLUDE "PROTHEUS.CH"
#INCLUDE "FRTA271J.CH"
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �FR271ChkOrcAb�Autor  �Renato Calabro'     � Data �  08/31/10   ���
����������������������������������������������������������������������������͹��
���Desc.     �Valida se existem orcamentos em aberto no PDV e caso houver,   ���
���          �pergunta ao usuario se deve realizar o reprocessamento. Caso o ���
���          �usuario recusar, passa pela aprovacao de senha do supervisor.  ���
����������������������������������������������������������������������������͹��
���Sintaxe   �nExp := FR271CHKORCAB(cExp1,cExp2,cExp3,lExp4,lExp5)           ���
����������������������������������������������������������������������������͹��
���Parametros�cExp1 - numero do PDV  						                 ���
���          �cExp2 - numero do Estacao                                      ���
���          �cExp3 - numero do orcamento                                    ���
���          �nExp4 - Verifica se rotina deve ser reprocessada               ���
���          �nExp5 - Controle de retorno da funcao                          ���
����������������������������������������������������������������������������͹��
���OBS       �Rotina contempla tambem orcamentos Duplicados ou com Erro de   ���
���          �Transmissao a serem reprocessadas na Retaguarda.               ���
����������������������������������������������������������������������������͹��
���Retorno   �1=Reprocessa/2=Erro/3=Cancelar	                             ���
����������������������������������������������������������������������������͹��
���Uso       �FRONTLOJA                                                      ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function FR271ChkOrcAb(cPdv, cEstacao, cOrcam, nNumReproc,lRet)

Local nTotalAb := 0														//total de orcamentos abertos (L1_SITUA == '00')
Local nTotalER := 0														//total de orcamentos com erro de transmissao (L1_SITUA == 'ER')
Local nTotalDupl := 0					     	  						//total de orcamentos duplicados (L1_SITUA == 'DU')       
Local aOrcReproc := {}													//array que carrega dados da SL1 (Filial, No.Orcamento, Serie, No. PDV, Dt.Emissao, Situacao )
Local nI := 0															//valor numerico para contagem
Local lReprocErDu := .F.												//valor logico de resposta do usuario para reprocessar orcamentos com erro ou duplicados 
Local aRegERDU := {}            										//array com orcamentos duplicados ou com erro de transmissao
Local nTotalProc := 0													//valor numerico somatorio de nTotalAb, nTotalER e nTotalDupl
Local nTotReproc := SuperGetMV("MV_LJNRPEN")							//valor numerico para busca de valor padr�o do reprocessamento de orcamentos pendentes
Local nX := 0															//valor numerico para contagem
Local nIntJob := Nil													//valor de intervalo do job (cadastro SLG->LG_RPCINT)
Local aSoOrcAb := {}													//array para listar apenas orcamentos em aberto
Local nPosDUER := 0														//posicao contido no array para orcamentos com erros ou duplicados
Local lRepNovam := .T.													//valor logico que verifica se e' usuario solicitou o reprocessamento novamente
Local aThread := GetUserInfoArray()										//array com conteudos referente aos jobs em execucao
Local nPosJob := aScan( aThread, {|x| Trim(x[5]) == "FRTA020"} )		//posicao para verificar se job FRTA020 esta ativado

Local oSLG := Nil   													//objeto de consulta da tabela SLG
Local oRetSlg := Nil                                                    //objeto de retorno da consulta da tabela SLG

Default lRet := .F.                                                    	//valor logico de retorno para controle da funcao
Default nNumReproc := 0													//valor numerico para contagem de numero de reprocessamento

cPdv := PadR(cPdv, TamSX3("L1_PDV")[1])									//Tratamento para sempre considerar o tamanho que esta em L1_PDV

aOrcReproc = FR271GetOrcAb(cPdv, @nTotalAb, @nTotalER, @nTotalDupl)

If (nTotalAb > 0 .OR. nTotalER > 0  .OR. nTotalDupl > 0) .AND. lRepNovam
	If nNumReproc == 0
		MsgInfo(STR0004)		//"Existem or�amentos pendentes de integra��o"
	EndIf
	
	If nTotalER > 0  .OR. nTotalDupl > 0
		lReprocErDu = MsgYesNo(STR0005 + cValToChar(nTotalER) + STR0006 + cValToChar(nTotalDupl) +  STR0007 +;		//"Existem " + ## + " or�amentos com Erro de Transmiss�o e " + cValToChar(nTotalDupl) + " or�amentos Duplicados." +
								CRLF + STR0008)																		//"For�ar nova tentativa de grava��o?"
	EndIf
	If lReprocErDu
		For nI := 1 to Len(aOrcReproc)

		//���������������������������������������������������������Ŀ
		//�L1_FILIAL+L1_NUM somente dos orcamentos que sao DU ou ER �
		//�Aqui nao e' necessario orderar, pois ja' foi ordenado ao �
		//�preencher o aOrcReproc.                                  �
		//�����������������������������������������������������������
		
			If aOrcReproc[nI][6] $ "DU/ER"
				aAdd( aRegERDU, {aOrcReproc[nI][1], aOrcReproc[nI][2],aOrcReproc[nI][6]} )		//L1_FILIAL, L1_NUM, L1_SITUA
			EndIf
		Next
		FR271AltL1Situa(aRegERDU)
		aOrcReproc = FR271GetOrcAb( cPdv, @nTotalAb, @nTotalER, @nTotalDupl )
	EndIf        
	
	//������������������������������������������������Ŀ
	//�Somente continua se existir orcamentos em aberto�
	//��������������������������������������������������
	If nTotalAb > 0
		//�������������������������������������������������������������������������������Ŀ
		//�Tratamento para gerar array somente com orcamentos em aberto (L1_SITUA == '00')�
		//���������������������������������������������������������������������������������
		aSoOrcAb := aClone(aOrcReproc)

		For nI := Len(aSoOrcAb) to 1 Step -1
			nPosDUER := aScan( aSoOrcAb, {|x| (Trim(x[2]) == aSoOrcAb[nI][2] .AND. Trim(x[6]) == "DU" ) .OR.;
												(Trim(x[2]) == aSoOrcAb[nI][2] .AND. Trim(x[6]) == "ER")} )
			If nPosDUER > 0
				aDel(aSoOrcAb, nPosDUER)
				aSize(aSoOrcAb, Len(aSoOrcAb) - 1)
			EndIf

		Next

		//���������������������������������������������������������������������������������������������Ŀ
		//�Apresenta tela com or�amentos em aberto, duplicados ou nao transmitidos (erro na transmissao)�
		//�����������������������������������������������������������������������������������������������
		lRet := FR271TelaOrcAb(cPdv,aSoOrcAb, nPosJob)

	Else
		//����������������������������������������������������������������������������������������������Ŀ
		//�Se nao houver orcamentos, em aberto e o usuario nao solicitar o reprocessamento de orcamentos �
		//�com erro ou duplicados, o programa continua a reducao Z                                       �
		//������������������������������������������������������������������������������������������������
		lRet := .T.
	EndIf

Else
	lRet := .T.
EndIf

If lRet .AND. Len(aSoOrcAb) > 0
	//�����������������������������������������������������������������������������Ŀ
	//�Consulta intervalo do Job no cadastro de Estacao (SLG) pelo c�digo da estacao�
	//�������������������������������������������������������������������������������
	oSLG := LJCEntEstacao():New()
	oSLG:DadosSet('LG_CODIGO', cEstacao)
	oRetSlg := oSLG:Consultar(1)
		                               	
	If oRetSlg:Count() > 0
		
		//�����������������������������������������Ŀ
		//�nIntJob - valor gravado no SLG referente �
		//�ao intervalo do Job de processamento	    �
		//�������������������������������������������
		nIntJob := oRetSlg:Elements(1):DadosGet('LG_RPCINT')
	
		//�����������������������������������������������Ŀ
		//�Verifica se job FRTA020 encontra-se em execucao�
		//�������������������������������������������������
		nPosJob := aScan( aThread, {|x| Trim(x[5]) == "FRTA020"} )
		
		If nPosJob == 0
			//�������������������������������������������������������������Ŀ
			//�Aciona execucao de job para checar orcamentos abertos no PDV �
			//���������������������������������������������������������������
			StartJob("FRTA020",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cEstacao)
			Sleep(nIntJob)
		EndIf
	Else
		MsgAlert(STR0009 + CRLF + STR0010) 			//"Estacao n�o cadastrada!" + CRLF + "Cadastre a estacao para continuar processamento" )
		lRet := .F.
	EndIf
	
	freeObj(oSLG)
	freeObj(oRetSlg)
			
	If lRet
		
		//������������������������������������������������������������������������Ŀ
		//�Verifica se existem orcamentos em aberto para reprocessar		 	   �
		//�Nao e' necessario zerar variaveis pois FR271GetOrcAb faz este tratamento�
		//��������������������������������������������������������������������������
		aOrcReproc := FR271GetOrcAb( cPdv, @nTotalAb )
			
		//��������������������������������������������������������������������������������������������������Ŀ
		//�Realiza o reprocessamento dos orcamentos de acordo com o numero cadastrado no parametro MV_LJNRPEN�
		//����������������������������������������������������������������������������������������������������
		If nTotalAb <> 0 .AND. nNumReproc < nTotReproc
			nNumReproc++		
			lRepNovam := MsgYesNo(STR0011 + CRLF + STR0012 + CRLF + CRLF + STR0013 + cValToChar(nNumReproc) + Chr(9) + STR0014 + cValToChar(nTotReproc))			//"Ainda existem vendas pendentes a serem reprocessadas no servidor." + CRLF + "Deseja processar novamente?" + CRLF + CRLF + "Tentativa atual: " + chr(9) + "Total de Tentativas: " 
			If lRepNovam
	
				//�����������������������������������������������������������
				//�Ajusta retorno, caso reprocessamento atingir o numero de �
				//�vezes mas nao obter sucesso de envio `a retaguarda       �
				//�����������������������������������������������������������
				lRet := .F.
				FR271ChkOrcAb(cPdv, cEstacao, cOrcam, @nNumReproc, @lRet)
			Else
				lRet := LJProfile(24,,,,,, cOrcam)
				If !lRet
					FR271ChkOrcAb(cPdv, cEstacao, cOrcam, @nNumReproc, @lRet)
				EndIf
			EndIf
		ElseIf nNumReproc >= nTotReproc
			MsgInfo(STR0024)		//"N�mero de tentativas para reprocessar foi alcan�ado. Para continuar a Redu��o Z ser� necess�rio a senha do superior"
			lRet := LJProfile(24,,,,,, cOrcam)
		EndIf
	EndIf
EndIf

Return (lRet)

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �FR271GetOrcAb�Autor  �Renato Calabro'     � Data �  08/31/10   ���
����������������������������������������������������������������������������͹��
���Desc.     �Preenche no array aOrcReproc as informacoes dos orcamentos em  ���
���          �Aberto, Duplicados ou com Erro de Transmissao	gravados na SL1  ���
����������������������������������������������������������������������������͹��
���Sintaxe   �FR271GetOrcAb(cExp1,cExp2,cExp3,nExp4)		                 ���
����������������������������������������������������������������������������͹��
���Parametros�cExp1 - numero do PDV	                                         ���
���          �cExp2 - contador de orcamentos em Aberto                   	 ���
���          �cExp3 - contador de orcamentos com Erro de Transmissao		 ���
���          �cExp4 - contador de orcamentos Duplicados               	     ���
����������������������������������������������������������������������������͹��
���Retorno   �Array aOrcReproc preenchido		                             ���
����������������������������������������������������������������������������͹��
���Uso       �FRONTLOJA                                                      ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function FR271GetOrcAb( cPdv, nTotalAb, nTotalER, nTotalDupl )

Local aOrcReproc := {}						//array dos orcamentos que serao reprocessados
Local aTpOrcSL1 := {"00","ER","DU"}			//array de referencia com os tipos de situacoes para tratamento
Local aAreaSL1 := {}						//array para preservar o SL1
Local nI := 0								//valor numerico para contagem e controle

aAreaSL1 := getArea("SL1")

nTotalAb := 0
nTotalER := 0
nTotalDupl := 0

For nI := 1 to Len(aTpOrcSL1)

	dbSelectArea("SL1")
	dbSetOrder(9)	// L1_FILIAL + L1_SITUA + L1_PDV
	dbSeek( SL1->(xFilial("SL1"))+aTpOrcSL1[nI] )
	
	While !SL1->(Eof()) .AND. ( SL1->L1_FILIAL+SL1->L1_SITUA+SL1->L1_PDV == xFilial("SL1")+aTpOrcSL1[nI]+cPdv )

		If AllTrim(SL1->L1_SITUA) == "00"
			nTotalAb ++
            aAdd( aOrcReproc, {SL1->L1_FILIAL,;
            					SL1->L1_NUM,;
            					SL1->L1_SERIE,;
            					SL1->L1_PDV,;
            					SL1->L1_EMISSAO,;
        	    				SL1->L1_SITUA} )

		ElseIf AllTrim(SL1->L1_SITUA) == "ER"
			nTotalER ++
            aAdd( aOrcReproc, {SL1->L1_FILIAL,;
    	        				SL1->L1_NUM,;
	            				SL1->L1_SERIE,;
            					SL1->L1_PDV,;
            					SL1->L1_EMISSAO,;
            					SL1->L1_SITUA} )

		ElseIf AllTrim(SL1->L1_SITUA) == "DU"
			nTotalDupl ++
            aAdd( aOrcReproc, {SL1->L1_FILIAL, ;
	            				SL1->L1_NUM, ;
    	        				SL1->L1_SERIE, ;
        	    				SL1->L1_PDV, ;
            					SL1->L1_EMISSAO, ;
            					SL1->L1_SITUA} )
		EndIf
	
		SL1->( dbSkip() )
	End
	
Next	

restArea(aAreaSL1)
Return(aOrcReproc)

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  �FR271AltL1Situa�Autor  �Renato Calabro'     � Data �  08/31/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Altera orcamentos com Erro de Transmissao ('ER') ou Duplicados   ���
���          �('DU') para condicao de orcamento em aberto ('00')               ���
������������������������������������������������������������������������������͹��
���Sintaxe   �FR271AltL1Situa(aExp1,lExp2)					                   ���
������������������������������������������������������������������������������͹��
���Parametros�aExp1 - array com os orcamentos Duplicados ou com Erro de 	   ���
���          �        Transmissao		                                       ���
������������������������������������������������������������������������������͹��
���Uso       �FRONTLOJA                                                        ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Function FR271AltL1Situa(aRegERDU)

Local aArea	:= {}		//array para preservar a tabela SL1
Local nI := 0			//valor numerico para contagem

aArea := getArea("SL1")

For nI := 1 to Len(aRegERDU)
	dbSelectArea("SL1")
	dbSetOrder(1)
	dbSeek(aRegERDU[nI][1]+aRegERDU[nI][2])
		RecLock("SL1",.F.)
		SL1->L1_SITUA = "00"
		SL1->(msUnlock())
	SL1->(dbSkip())
Next

restArea(aArea)
Return Nil

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �FR271TelaOrcAb �Autor  �Renato Calabro'     � Data �  08/31/10 ���
����������������������������������������������������������������������������͹��
���Desc.     �Ativa tela com orcamentos em aberto em uma TWBrowse			 ���
����������������������������������������������������������������������������͹��
���Sintaxe   �FR271TelaOrcAb(cExp1,aExp2)					                 ���
����������������������������������������������������������������������������͹��
���Parametros�cExp1 - numero do PDV  						                 ���
���          �aExp2 - array com orcamentos pendentes						 ���
����������������������������������������������������������������������������͹��
���Retorno   �Retorno da acao do usuario 1=Reprocessa/2=Cancelar	         ���
����������������������������������������������������������������������������͹��
���Uso       �FRONTLOJA                                                      ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function FR271TelaOrcAb(cPdv,aOrcReproc, nPosJob)

Local lReprocessa := .F.																			//valor logico que recebe valor de orcamentos serao reprocessados
Local lImpRelGer := .F.																				//valor logico que recebe valor de impressao gerencial
Local lCancela := .F.																				//valor logico que recebe valor de cancelamento da rotina
Local lRet := Nil																					//valor logico de controle de retorno da funcao 
Local aHEADERSL1 := {"Filial", "No.Orcamento", "Serie", "No. PDV", "Dt.Emissao", "Situacao"}		//array com cabecalho da janela TWBrowse

Local oDlg := Nil																					//objeto da Dialog
Local oLbx := Nil																					//objeto da listbox
Local oTPanel1 := Nil																				//objeto Panel com os orcamentos
Local oTPanel2 := Nil																				//objeto Panel com o rodape de botoes e total de orcamentos
Local oTotOrcamento := Nil																			//objeto que apresenta o total de orcamentos
Local oServStatus := Nil																			//objeto que apresenta o status do servidor

While ValType(lRet) <> "L"

	DEFINE MSDIALOG oDlg TITLE STR0015 FROM 0,0 TO 250,555 PIXEL STYLE DS_MODALFRAME STATUS			//"Or�amentos Pendentes no PDV"
	
	//�����Ŀ
	//�Panel�
	//�������
	
	oTPanel1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,300,095,.T.,.F.)
	oTPanel1:Align := CONTROL_ALIGN_ALLCLIENT
	
	oTPanel2 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,170,020,.T.,.F.)
	oTPanel2:Align := CONTROL_ALIGN_BOTTOM
	

	oTotOrcamento := TPanel():Create(oTPanel2,02,02, STR0016 + cValToChar(Len(aOrcReproc)),,,,CLR_BLUE,,350,30)		//"Total de or�amentos em aberto: "
	oServStatus	 := TPanel():Create(oTPanel2,10,02, STR0017 + If(nPosJob > 0, STR0018, STR0019),,,,CLR_BLUE,,350,30)		//"Status do Servidor: ", "EM OPERA��O", "PARADO"

	oLbx := TwBrowse():New(0,0,0,0,,aHeaderSL1,,oTPanel1,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx:Align := CONTROL_ALIGN_ALLCLIENT

	oLbx:SetArray( aOrcReproc )
	oLbx:bLine := {|| {aOrcReproc[oLbx:nAt,1],;
						aOrcReproc[oLbx:nAt,2],;
						aOrcReproc[oLbx:nAt,3],;
						aOrcReproc[oLbx:nAt,4],;
						aOrcReproc[oLbx:nAt,5],;
						aOrcReproc[oLbx:nAt,6]}}
	//������Ŀ
	//�Botoes�
	//��������
		
	@03,153 BUTTON oButReproc Prompt STR0020 SIZE 36,15 ACTION (lRet := .T.,oDlg:End()) PIXEL OF oTPanel2 	 		//"Reprocessar"
		
	@03,193 BUTTON oButPrint Prompt STR0021 SIZE 36,15 ACTION (FR271ImpOrcAB(cPdv),oDlg:End()) PIXEL OF oTPanel2	//"Imprimir"
	
	@03,233 BUTTON oButCancela Prompt STR0022 SIZE 36,15 ACTION (lRet := .F.,oDlg:End()) PIXEL OF oTPanel2			//"Cancelar"
		
	ACTIVATE MSDIALOG oDlg CENTERED
End

Return(lRet)

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �FR271ImpOrcAb  �Autor  �Renato Calabro'     � Data �  08/31/10 ���
����������������������������������������������������������������������������͹��
���Desc.     �Impressao de relatorio gerencial de orcamentos em aberto		 ���
����������������������������������������������������������������������������͹��
���Sintaxe   �FR271ImpOrcAb(cExp1)							                 ���
����������������������������������������������������������������������������͹��
���Parametros�cExp1 - numero do PDV  						                 ���
����������������������������������������������������������������������������͹��
���Uso       �FRONTLOJA                                                      ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function FR271ImpOrcAb(cPdv)

Local oImpFrm := LJCFrmtLay():New(4)					//objeto com o Formulario de impressao
Local aTpOrcSL1 := {"00","ER","DU"}						//array de referencia com os tipos de situacoes para tratamento
Local nI := 1											//valor numerico para contagem
Local nX := 1											//valor numerico para contagem

Local oSL1 := LJCEntOrcamento():New()					//objeto de consulta da tabela SL1
Local oRetSl1											//objeto de retorno da consulta da tabela SL1
				
oImpFrm:AddStruct(2,6,.T.,.T.,,,{"Filial", "N.Orc","Serie","N.PDV","Emissao","Situa"})	//Cabecalho
oImpFrm:SetTotCol(45)																		//ajuste de colunas
oImpFrm:PrintLineWD()																		//insere linha de tabulacao
For nI := 1 to Len(aTpOrcSL1)

	oSL1:DadosSet("L1_SITUA", aTpOrcSL1[nI])
	
	oRetSL1 := oSL1:Consultar(9)
	
	If oRetSL1:Count() > 0 
		For nX := 1 to oRetSL1:Count()
			oImpFrm:Add(2,{oRetSL1:Elements(nX):DadosGet("L1_FILIAL"),;
							oRetSL1:Elements(nX):DadosGet("L1_NUM"),;
							oRetSL1:Elements(nX):DadosGet("L1_SERIE"),;
							oRetSL1:Elements(nX):DadosGet("L1_PDV"),;
							oRetSL1:Elements(nX):DadosGet("L1_EMISSAO"),;
							oRetSL1:Elements(nX):DadosGet("L1_SITUA")})
		Next
	EndIf
Next
oImpFrm:PrintLineWD()
oImpFrm:SetAlign(1,{"C"})
oImpFrm:PrintText(STR0023)		//"FIM DA LISTAGEM"
oImpFrm:PrintBlank()
oImpFrm:Exec()

oImpFrm:Finish()
freeObj(oSL1)
freeObj(oRetSl1)

Return Nil

