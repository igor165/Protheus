#INCLUDE "QIPA230.CH"
#INCLUDE "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QIPA230   �Autor  �Cleber Souza        � Data �  02/12/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de Administracao do Cadastro OP x Lote              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � QIPA230                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local   aRotAdic := {}
Private aRotina  := {}

Aadd(aRotina,{OemToAnsi(STR0002)   , "AxPesqui",   0, 1,,.F.})  //"Pesquisar"
Aadd(aRotina,{OemToAnsi(STR0003)   , "QP230Atu",   0, 2})  //"Visualizar"
Aadd(aRotina,{OemToAnsi(STR0004 )  , "QP230Atu",   0, 3})  //"Incluir"
Aadd(aRotina,{OemToAnsi(STR0005)   , "QP230Atu",   0, 4})  //"Alterar"
Aadd(aRotina,{OemToAnsi(STR0006)   , "QP230Atu",   0, 5})  //"Excluir"
Aadd(aRotina,{OemToAnsi(STR0007)   , "QP215LegOp", 0, 6,,.F.})  //"Legenda"

If ExistBlock("QIP230ENT")
	aRotAdic := ExecBlock("QIP230ENT", .F., .F.)
	If ValType(aRotAdic) == "A" .And. Len(aRotAdic)==1
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIF
EndIF

Return aRotina

Function QIPA230()
Private aRotina   := MenuDef()
Private aSitEnt   := {}
Private cCadastro := OemtoAnsi(STR0001) //"Relacionamento OP x Lote"
               
aadd(aSitEnt, {"QP215LdoPe()", "BR_CINZA"}) 	//OP sem medicoes cadastradas 
aadd(aSitEnt, {"QP215EntSM()", "BR_AZUL"}) 		//Laudo Pedente
aadd(aSitEnt, {"QP215LdoAp()", "BR_VERDE"}) 	//Laudo Aprovado 
aadd(aSitEnt, {"QP215LdoRe()", "BR_VERMELHO"}) 	//Laudo Reprovado	
aadd(aSitEnt, {"QP215LdoUr()", "BR_AMARELO"}) 	//Liberacao Urgente
aadd(aSitEnt, {"QP215LdoCo()", "BR_LARANJA"}) 	//Laudo Condicional
aadd(aSitEnt, {"QP215LdoSM()", "BR_AZUL_OCEAN"})//Laudo sem Movimentacao de Estoque
             

mBrowse(06,1,22,75,"QPK",,"QPK_SITOP",,,,aSitEnt)

dbSelectArea('QPK') 
dbClearFilter()

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QP230Atu  �Autor  �Cleber Souza        � Data �  02/12/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de Administracao do Cadastro OP x Lote              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � QIPA230                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QP230Atu(cAlias,nReg,nOpc)

Local oGet 
Local oDlg
Local aCpoInc    := {{},{}}
Local nOpcA      := 0
Local bOk        := {||nOpcA := 1,QP230TOKRel(),IIF(lTudoOk,oDlg:End(),.f.)}
Local bCancel    := {||nOpcA := 0,oDlg:End()}
Local nY         := 0   
Local cChaveQPK  := ""   
Local oSize 
Local nX
  
//��������������������������������������������������������������������Ŀ
//� Indica onde sera realizada a Inspecao do Material, quando houver   �
//� integracao entre o QIP e PCP,sendo as seguintes opcoes:			   �
//� 1 - Ordens de Producoes											   �
//� 2 - Apontamento das Producoes									   �
//����������������������������������������������������������������������
Local cInspecao := GetMV("MV_QINSPEC",.T.,"1") 

Private lTudoOk  := .t. 
Private nOpcx    := nOpc 
Private aAltera  := {"QPK_TAMLOT"}
Private aStruQPK


If cInspecao == "2" .And. (nOpc == 3 .or. nOpc == 4 .or. nOpc == 5)
	Help (" ",1,"QA_QINSPEC" )
	Return .T.
EndIf
//��������������������������������������������������������������Ŀ
//� Verifica na exclusao, se existem medicoes cadastradas, para  �
//� OPs sem Laudos Informados.			    					 �
//����������������������������������������������������������������
If nOpc == 5 .or. nOpc == 4
	If !(QPA230VerMed(QPK->QPK_OP,QPK->QPK_LOTE,QPK->QPK_NUMSER))
		Return(NIL)  
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Cria o vetor com os campos a serem utilizados na Enchoice OPE�
//����������������������������������������������������������������

AADD(aAltera,"QPK_LOTE")
AADD(aAltera,"QPK_NUMSER")
AADD(aAltera,"QPK_CLIENT")
AADD(aAltera,"QPK_LOJA")

aStruQPK := FWFormStruct(3,"QPK")[3]
For nX := 1 to Len(aStruQPK)
	If cNivel >= GetSx3Cache(aStruQPK[nX,1],"X3_NIVEL")
		Aadd(aCpoInc[1],AllTrim(GetSx3Cache(aStruQPK[nX,1],"X3_CAMPO")))
		Aadd(aCpoInc[2],GetSx3Cache(aStruQPK[nX,1],"X3_CONTEXT"))
		If GetSx3Cache(aStruQPK[nX,1],"X3_PROPRI") == "U"
			AADD(aAltera,AllTrim(GetSx3Cache(aStruQPK[nX,1],"X3_CAMPO")))
		EndIf
	EndIf 
Next nX

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New( .F. )

oSize:AddObject( "BAIXO",  100, 100, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//��������������������������������������������������������������Ŀ
//� Monta Dialog                                                 �
//����������������������������������������������������������������

DEFINE MSDIALOG oDlg TITLE cCadastro ;  //"Relacionamento OP x Lote"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

//��������������������������������������������������������������Ŀ
//� Monta os vetores das Enchoices de Laudos da Operacao		 �
//����������������������������������������������������������������  
RegToMemory("QPK")
If nOpc==3
	//Limpa Variaveis
	For nY:=1 to Len(aCpoInc[1]) 
		If aCpoInc[2][nY]#"V" 
			&("M->"+Alltrim(aCpoInc[1][nY])) := CriaVar(Alltrim(aCpoInc[1][nY]))
		EndIF          
	Next nY

Else 
	//Carrega conteudo tabela QPK
	For nY:=1 to Len(aCpoInc[1]) 
		If aCpoInc[2][nY]#"V" 
			&("M->"+Alltrim(aCpoInc[1][nY])) := &("QPK->"+Alltrim(aCpoInc[1][nY]))
		EndIF          
	Next nY
    M->QPK_DESCPO := Posicione("SB1",1,xFilial("SB1")+M->QPK_PRODUT,"B1_DESC")
EndIf                                                  

cChaveQPK := M->QPK_OP+M->QPK_LOTE+M->QPK_NUMSER

If nOpc==4 
	oGet:=MsMGet():New("QPK",nReg,nOPC,,,,,oSize:aPosObj[1],aAltera,3,,,,oDlg,,.T.,,,,,,,.T.)
Else
	oGet:=MsMGet():New("QPK",nReg,nOPC,,,,,oSize:aPosObj[1],aCpoInc[1],3,,,,oDlg,,.T.,,,,,,,.T.)
EndIF                                                                    

oGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT

If (nOpc <> 2)             
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) CENTERED;
		VALID Qp230VldQtd()
Else
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) CENTERED
EndIf	  

If (nOpc==3 .or. nOpc==4) .And. nOpcA==1
	dbSelectArea("QPK")
	dbSetOrder(1)
	If !dbSeek(xFilial("QPK")+cChaveQPK)
		RecLock("QPK",.t.) 
		QPK->QPK_FILIAL := xFilial("QPK")
	Else 
		RecLock("QPK",.F.) 
	EndIF
	For nY:=1 to Len(aCpoInc[1]) 
		If aCpoInc[2][nY]#"V" 
			&("QPK->"+Alltrim(aCpoInc[1][nY])) := &("M->"+Alltrim(aCpoInc[1][nY]))
		EndIF          
	Next nY
	MsUnlock()

   	//��������������������������������������������������������������Ŀ
	//� Ponto de Entrada criado para Chamada do relatorio OP X Lote  �
	//����������������������������������������������������������������
	If ExistBlock("Q230RELO")               
		ExecBlock("Q230RELO",.F., .F., {nOpc,aCpoInc})
	EndIf

ElseIf nOpc==5 .and. nOpcA==1

	dbSelectArea("QPK")
	RecLock("QPK",.F.)
	dbDelete()
	MsUnlock()
    
EndIf      

//Limpa Variaveis
For nY:=1 to Len(aCpoInc[1]) 
	If aCpoInc[2][nY]#"V" 
		&("M->"+Alltrim(aCpoInc[1][nY])) :=  CriaVar(Alltrim(aCpoInc[1][nY]))
	EndIF          
Next nY

Return .t.   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QP230ValRel�Autor  �Cleber Souza       � Data �  01/28/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao do tamanho do Lote e Numero de Serie digitdos na ���
���          � rotina de inclusao do Relacionamento Lote x OP             ���
�������������������������������������������������������������������������͹��
���Uso       � QIPA230                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QP230ValRel()
Local aAreaSC2  := {}
Local cAliasSD3 := GetNextAlias()
Local cQuery    := ""
Local cVar      := Alltrim(ReadVar())
Local lRet      := .T.
Local nRecQPK   := 0
Local nSomLot   := 0
Local nValMaior := 0
Local oExec     := Nil

Default lFwExecSta := FindClass( Upper("FwExecStatement") ) //Declarado como Default para auxiliar na cobertura de c�digo
Default lFwQtToChr := FindFunction( "FwQtToChr" ) //Declarado como Default para auxiliar na cobertura de c�digo

If cVar == "M->QPK_TAMLOT"

	If Empty(M->QPK_OP) 
		MsgAlert(STR0009) //"Favor informaro numero da OP antes do tamanho do Lote"
		lRet := .f.
	EndIF                       
	
	If M->QPK_TAMLOT <= 0
		lRet := .F.
	EndIf	
	
	If lRet 
		//Posiciona na tabela SC2
		aAreaSC2 := SC2->(GetArea())
		dbSelectArea("SC2")                
		SC2->(dbSetOrder(1))   
		If SC2->(dbSeek(xFilial("SC2")+M->QPK_OP))
			nValMaior := SC2->C2_QUANT
		EndIf
		SC2->(DbCloseArea())
		RestArea(aAreaSC2)
		                                           
		nRecQPK := QPK->(Recno())
		
		///Soma todas as qtds dos lotes para essa OP.
		dbSelectArea("QPK")
		QPK->(dbSetOrder(1))
		If QPK->(dbSeek(xFilial("QPK")+M->QPK_OP))
			While QPK->(!EOF()) .And. QPK->QPK_OP == M->QPK_OP
				nSomLot += QPK->QPK_TAMLOT
				QPK->(dbSkip())
			EndDo
		EndIF
		

		QPK->(dbGoTo(nRecQPK))
		     
		//Na Alteracao subtrai a quantidade que esta sendo alterada
		If nOpcX == 4
			nSomLot -= QPK->QPK_TAMLOT
		EndIF

		nSomLot += M->QPK_TAMLOT

		cQuery := "	SELECT COALESCE(SUM(SD3.D3_QUANT),0) AS D3_QUANT "
		
		cQuery += "	  FROM " + RetSqlName("SD3") + " SD3 "
	
		If lFwExecSta
			cQuery += "	 WHERE SD3.D3_COD= ? "
			cQuery += "	   AND SD3.D3_OP= ? "
			cQuery += "	   AND SD3.D3_FILIAL= ?  "
			cQuery += "	   AND SD3.D3_ESTORNO = ' ' "
			cQuery += "	   AND SD3.D3_CF='PR0' "
			cQuery += "    AND SD3.D_E_L_E_T_=''"
			oExec := FwExecStatement():New(cQuery)
			If lFwQtToChr
				oExec:setString( 1, FwQtToChr(M->QPK_PRODUT) )
				oExec:setString( 2, FwQtToChr(M->QPK_OP) )
			Else
				oExec:setString( 1, M->QPK_PRODUT )
				oExec:setString( 2, M->QPK_OP )
			EndIf
			oExec:setString( 3, xFilial("SD3") )
			cAliasSD3 := oExec:OpenAlias()
			oExec:Destroy()
			oExec := nil 
		Else
			If lFwQtToChr
				cQuery += " WHERE SD3.D3_COD='"+ StrTran(FwQtToChr(M->QPK_PRODUT),"'","") +"' " 
				cQuery += "	  AND SD3.D3_OP='"+ StrTran(FwQtToChr(M->QPK_OP),"'","") +"' "
			Else
				cQuery += " WHERE SD3.D3_COD='" + M->QPK_PRODUT + "' " 
				cQuery += "   AND SD3.D3_OP='" + M->QPK_OP + "' "
			EndIf
			cQuery += "	   AND SD3.D3_FILIAL='" + xFilial("SD3") + "' "
			cQuery += "	   AND SD3.D3_ESTORNO = ' ' "
			cQuery += "	   AND SD3.D3_CF='PR0' "
			cQuery += "    AND SD3.D_E_L_E_T_=''"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD3)
		Endif 
		
		If (cAliasSD3)->D3_QUANT > nValMaior
			nValMaior := (cAliasSD3)->D3_QUANT
		EndIf

		(cAliasSD3)->(DbCloseArea())

   		If nSomLot > nValMaior
			//STR0010 + M->QPK_OP + STR0011 "A soma de todos os lotes para a OP "###" esta acima da quantidade produzida."
			//STR? Verificar a quantidade digitada na OP e/ou a soma dos apontamentos.
			Help("",1,"QP230VALTAM",,STR0010 + M->QPK_OP + STR0011,1,0,,,,,,{STR0018})
			lRet := .F.
        EndIf
        
    EndIF

	If lRet
		//Verifica se possui numero de serie
		If !Empty(M->QPK_NUMSER) .and. M->QPK_TAMLOT > 1
			MsgAlert(STR0012) //"Nao eh permitdo mais de 1 produto por numero de serie."
			lRet := .f.
	    EndIf
    EndIf

ElseIf cVar == "M->QPK_NUMSER"
	
	If !Empty(M->QPK_NUMSER) .and. M->QPK_TAMLOT > 1
		MsgAlert(STR0012) //"Nao eh permitdo mais de 1 produto por numero de serie."
		lRet := .f.
    EndIf

EndIf

Return(lRet)

     
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QP230TOKRel�Autor  �Cleber Souza       � Data �  01/28/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao do TudoOk da tela de inclusao do QPK.            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � QIPA230			                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QP230TOKRel()

Local nRecQPK    := QPK->(Recno())
Local nCount     := 0
Local cOP        := QPK->QPK_OP

lTudoOk := .T.

If nOpcx == 3
	If lTudoOk
		lTudoOk := Q230VlCpOb()
	EndIf
	
	//Verifica se esta com lote + numedo de serie duplicado
	dbSelectArea("QPK")
	dbSetOrder(1)
	If dbSeek(xFilial("QPK")+M->QPK_OP+M->QPK_LOTE+M->QPK_NUMSER)
		Help(" ",1,"QPH23001")  //Existem medicoes cadastradas para esse relaciomanto.
		lTudoOk := .f.
	EndIF

	//Verifica se o produto tem especificacao cadastrada
	dbSelectArea("QP6")
	dbSetOrder(1)
	If lTudoOk .And. !dbSeek(xFilial("QP6")+M->QPK_PRODUT)
		If Empty(QP6->QP6_GRUPO) //Especificacao por produto
			MessageDlg(STR0014,,1) //"Nao existe especificacao para o produto em questao. Favor cadastrar a espeficifacao."
			lTudoOk := .f.
		Endif	
	Endif

	If lTudoOk .And. !Empty(M->QPK_CLIENT) .And. !Empty(M->QPK_LOJA)
		dbSelectArea("QQ4")
		dbSetOrder(1)
		If !dbseek(xFilial("QQ4")+M->QPK_PRODUTO+M->QPK_CLIENT+M->QPK_LOJA)
			lTudoOk:=.F.
			MsgAlert(STR0016)
		Endif 
	EndIf
	
ElseIf nOpcx == 4
	If lTudoOk
		lTudoOk := Q230VlCpOb()
	EndIf
	
	If !Empty(M->QPK_CLIENT) .And. !Empty(M->QPK_LOJA)
		dbSelectArea("QQ4")
		dbSetOrder(1)
		If !dbseek(xFilial("QQ4")+M->QPK_PRODUTO+M->QPK_CLIENT+M->QPK_LOJA)
			lTudoOk:=.F.
			MsgAlert(STR0016)
		Endif 
	EndIf
	
ElseIf nOpcx == 5
	dbSelectArea("QPR")
	dbSetOrder(9)
	If dbSeek(xFilial("QPP")+M->QPK_OP+M->QPK_LOTE+M->QPK_NUMSER)
		Help(" ",1,"QPH23002")  //Existem medicoes cadastradas para esse relaciomanto.
		lTudoOk := .f.
	EndIf
	
	If lTudoOk
		dbSelectArea("QPK")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("QPK")+cOP)
			While QPK->(!EOF()) .and. cOP==QPK->QPK_OP
				nCount ++
				QPK->(dbSkip())
			EndDo
			If nCount == 1
				Help(" ",1,"QPH23004")  //N�o � permitida a exclus�o desse relacionamento pois � o �nico existente para essa Ordem de Produ��o.
				lTudoOk := .f.
			EndIF
		EndIf
		QPK->(dbGoTo(nRecQPK))
	EndIF
	
EndIf

Return(NIL)   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QP230CalTlo �Autor  �Cleber Souza		 � Data �  01/28/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Calcula tamamnho do Lote na tela de inclusao do QPK.       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � QIPA230                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QP230CalTlo()

Local aArea		:= GetArea()
Local nSomLot	:= 0

dbSelectArea("SC2")                
dbSetOrder(1)   
dbSeek(xFilial("SC2")+M->QPK_OP)
		
//Soma todas as qtds dos lotes para essa OP.
dbSelectArea("QPK")
dbSetOrder(1)
If dbSeek(xFilial("QPK")+M->QPK_OP)
	While QPK->(!EOF()) .and. QPK->QPK_OP == M->QPK_OP
		nSomLot += QPK->QPK_TAMLOT		
		dbSkip()
	EndDo
EndIF

RestArea(aArea)
Return(SC2->C2_QUANT-nSomLot)     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QP230VALOP �Autor  �Cleber Souza		 � Data �  05/04/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida OP digitado no relacionamento com Lote do Estoque.  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � QIPA230                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QP230VALOP()  

Local  lRet  := .T.
Local  aArea := GetArea()
               
dbSelectArea("SC2")
dbSetOrder(1)                   
dbSeek(xFilial("SC2")+M->QPK_OP) 
If !GetMV("MV_QPOPINT",.F.,.T.) //Parametro identifica se o usu�rio deseja inspecionar OPs intermedi�rias.
	If !Empty(SC2->C2_SEQPAI)
		Help(" ",1,"QPH23003")  //"Nao � permitido relacinar essa OP a qualquer numero de Lote pois a mesma foi gerada a partir de uma OP pai."
		lRet := .F.
	EndIF
EndIF

RestArea(aArea)

Return(lRet) 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Qp230VldQtd � Autor �Paulo Emidio      � Data �  16/04/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Valida a Quantidade informada para a Inspecao			  ���
�������������������������������������������������������������������������͹��
���Uso       � QIPA230                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Qp230VldQtd()
Local lRetorno  

If M->QPK_TAMLOT <=0
	MsgAlert(STR0013) //"A quantidade informada nao podera ser menor ou igual a Zero"
	lRetorno := .F.
EndIf

Return(lRetorno)    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QPA230VerMed� Autor �Cleber Souza          �Data �19/08/05  ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Verifica a existencia de medicoes cadastradas com a OP     ���
���			 � x Lote x Num.Serie a ser manipulada.	    				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QPA230VerMed(cOP,cLote,cNumSer)  						  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� EXPC1 = Numero da Ordem de Produ��o						  ���
���			 � EXPC2 = Numero do Lote									  ���
���			 � EXPC3 = Numero de Serie									  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � EXPL1 = .T. possui medicoes								  ���
���			 � 		 = .F. nao possui medicoes							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIPA010													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QPA230VerMed(cOP,cLote,cNumSer)
Local lRetorno := .T.
Local aAreaAnt := GetArea()

//Inserir o tratamento para verificar as Ordens de Producoes
dbSelectArea("QPR")
dbSetOrder(9)
If dbSeek(xFilial("QPR")+cOP+cLote+cNumSer)
	//*verificar se existe a Ordem de Producao*
	Help(" ",1,"QPH23002")  //Existem medicoes cadastradas para esse relaciomanto.
	lRetorno := .F.
EndIf 
If lRetorno
	dbSelectArea("QPL")
	dbSetOrder(2)
	If dbSeek(xFilial("QPL")+cOP+cLote)
		Help(" ",1,"QPH23005")//A ordem de Produ��o j� possui laudo. N�o poder� efetuar altera��o.
		lRetorno := .F.
	EndIf 
Endif	

RestArea(aAreaAnt)
Return(lRetorno)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Q230VlCpOb  � Autor �Gustavo D Giustina� Data �  05/04/2018 ���
�������������������������������������������������������������������������͹��
���Descricao � Valida se os campos obrigatorios foram informados          ���
�������������������������������������������������������������������������͹��
���Uso       � QIPA230                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Q230VlCpOb()
Local lRetorno := .T.
Local nX
Local cAviso := ""
Local cNewLine := CHR(13)+ CHR(10) 

For nX := 1 to Len(aStruQPK)
 If X3Obrigat(aStruQPK[nX,1]) .And. Empty(&("M->"+aStruQPK[nX,1]))
 	cAviso += cNewLine + "- " + aStruQPK[nX,3]
 EndIf
Next nX

If !Empty(cAviso)
	lRetorno := .F.
	cAviso := STR0017 + cNewLine + cAviso
	MsgAlert(cAviso, "")
EndIf

Return(lRetorno)      
