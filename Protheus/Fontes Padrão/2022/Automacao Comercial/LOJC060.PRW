#INCLUDE "LOJC060.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FRTDEF.CH"

Static lCenVenda 	:= SuperGetMv("MV_LJCNVDA",,.F.)	//Integra com cenario de vendas

#DEFINE SIGALOJA  12
#DEFINE FRONTLOJA 23
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� DATA   � BOPS �Prograd.�ALTERACAO                                     ���
�������������������������������������������������������������������������Ĵ��
���05.08.99�PROTH �Julio W.� TIMER no Protheus deve ser anexado ao di�logo���
���05.08.99�PROTH �Julio W.� N�o precisa de oTimer:end() no Protheus      ���
���09.08.99�PROTH �Julio W.� Substituir GetSysColor() para oDlg:nClrPane  ���
���05.09.00�05805 �Marcos A� Nao estava funcionando a consulta com leitor.���
���29.05.01�XXXXX �A.Veiga � Alteracao da funcao para ser chamada do      ���
���        �      �        � FrontLoja ou da Venda Rapida.                ���
���03.01.03�61707 �Fernando� Inclusao da funcao LJ60Est para consulta de  ���
���        �      �        � Estoque                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � lojc060	� Autor � Pilar S. Albaladejo   � Data � 08.08.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta de Precos										  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SigaLoja 												  ���
�������������������������������������������������������������������������Ŀ��
��� DATA   � BOPS �Prograd.�ALTERACAO                                     ���
�������������������������������������������������������������������������Ĵ��
���13/12/06|9.12  �Fernando|Bops 115314 Alterado a array aRotina  para    ���
���        �      |        � cria��o do menu funcional            	      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function LojC060()

// Campo verificador se est� sendo chamado pelo Robo
Local lAutomato	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

// Pesq. / Consulta
Private aRotina	  := MenuDef()
Private lLojc060:= (ExistBlock("Lojc060"))

//��������������������������������������������������������������Ŀ
//� Define o cabe�alho da tela de atualiza��es					 �
//����������������������������������������������������������������
PRIVATE cCadastro := STR0003 // Produtos
PRIVATE oBmp

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE									 �
//����������������������������������������������������������������
If !lAutomato
	mBrowse( 6, 1,22,75,"SB1" )
EndIf

//��������������������������������������������������������������Ŀ
//� Recupera a Integridade dos dados							 �
//����������������������������������������������������������������
msUnlockAll( )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef	� Autor � Fernando Amorim       � Data �13/12/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 

Local aRotina:= { 		{ STR0001 ,"AxPesqui", 0 , 1 , , .F.},;		//Pesquisar
						{ STR0002 ,"lj060Vis", 0 , 2 , , .T.} }        //Visualizar

							
							
Return(ARotina)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � lj060Vis � Autor � Pilar S. Albaladejo   � Data � 08.08.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta de Precos (Usuario Final)						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � lj060Vis(ExpC1,ExpN1,ExpN2)								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo									  ���
���			 � ExpN1 = Numero do registro 								  ���
���			 � ExpN2 = Opcao selecionada								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Lj060Vis( cAlias,nReg,nOpcx )

Local oDlg
Local oFnt
Local oCod
Local oMens
Local oTimer
Local oTimerFrt
Local oButton
Local oEst
Local oDesc
Local oFnt1
Local oFnt2
Local oFnt3
Local oFnt4
Local oFnt5
Local oFnt6
Local oTexto
Local oPreco
Local cCod
Local cDesc
Local cPreco
Local cEst
Local cTexto		:= ""
Local cMens 		:= STR0004  // PASSE O LEITOR
Local nCont 		:= 1
Local lMultimidia 	:= .F.
Local cAliasF3 		:= ""
Local lTemplateDRO	:= .F.  // Verifica se a consulta esta sendo executada pela venda assistida ou frontloja.
Local nRPCInt		:= LjGetStation("RPCINT")   
Local lDrog         := HasTemplate("DRO")

// Grava posicao atual das tabelas antes de abrir a consulta de produtos
Local aAreaMHG := Nil	// Save da Area de trabalho da tabela MHG
Local aAreaSA1 := Nil	// Save da Area de trabalho da tabela SA1
Local aAreaMA6 := Nil	// Save da Area de trabalho da tabela MA6
Local aAreaSBI := Nil	// Save da Area de trabalho da tabela SBI

// Campo verificador se est� sendo chamado pelo Robo
Local lAutomato	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Static cRotina
Static cArqAlias
Static cArqPrefixo

nRPCInt := If(nRPCInt=0, 5, nRPCInt)

If lDrog  .AND. (FunName() == "LOJA701" .OR. FunName() == "FRTA010" .OR. FunName() == "FRTA271" )
	lTemplateDRO := .T.
EndIf

If lDrog  .AND. lTemplateDRO
	aAreaMHG := MHG->(GetArea())
	aAreaSA1 := SA1->(GetArea())
	aAreaMA6 := MA6->(GetArea())
	aAreaSBI := SBI->(GetArea())

	//���������������������������������������������������Ŀ
	//�Consulta de precos especifica do template drogaria.�
	//�����������������������������������������������������
	T_DROCONSPRC()

	RestArea(aAreaMHG)
	RestArea(aAreaSA1)
	RestArea(aAreaMA6)
	RestArea(aAreaSBI)
EndIf

If !lDrog  .OR. !lTemplateDRO 
	cRotina := iIf( ValType(cAlias) == "C" .AND. cAlias == "SBI", "FRT", "LOJA" )
	
	lMultimidia := (LjGetProfile("MULTIMI") == "S")
	If Valtype(cAlias) == "L"
		if ! lMultimidia
			Return NIL
		EndIf
	EndIf
	
	//����������������������������������������������������������������������������������������������Ŀ
	//�Diferencia quando e FrontLoja ou Sigaloja, pois a tabela para consulta de produtos e diferente�
	//������������������������������������������������������������������������������������������������
	If "FRT" $ cRotina
		cAliasF3 := "FRT"
	Else
		cAliasF3 := "PRL"
	EndIf
	
	Private cProd
	Private cCodAux
	Private nQuant
	
	If nReg <> 0
		cProd   := SB1->B1_COD
		cCodAux := cProd
		cCod	:= cProd
		cDesc   := Alltrim(SB1->B1_DESC)
		nQuant  := 1
		cPreco  := lj060Pr_1(cCod)
		
		LJ060Est(,@cEst,,.F.)
	Else
		cProd   := Space(TamSx3("B1_COD")[1])
		cCodAux := cProd
		cCod	:= cProd
		cDesc   := Space(TamSx3("B1_DESC")[1])
		nQuant  := 1
		cPreco  := SuperGetMV("MV_SIMB1")+ " 0.00"
		cEst    := 0.00
	Endif
	
	
	If nReg <> 0
		DbSelectArea("SB5")
		DbSetOrder(1)
		If DbSeek(xFilial("SB5")+SB1->B1_COD)
			cTexto := Capital(SB5->B5_CEME)
		Else
			cTexto := STR0005 // N�o existe hist�rico para este produto
		EndIf
	Endif
	
	DEFINE FONT oFnt  NAME "Arial" SIZE 25,35
	DEFINE FONT oFnt1 NAME "Arial" SIZE 15,20			//Pre�o e Letreiro
	DEFINE FONT oFnt2 NAME "Arial" SIZE 8,14			//Complemento e Saldo em Estoque
	DEFINE FONT oFnt3 NAME "Ms Sans Serif" BOLD
	DEFINE FONT oFnt4 NAME "Courier New" SIZE 10,16		//Codigo	
	DEFINE FONT oFnt5 NAME "Courier New" SIZE 08,12		//Codigo (quando maior que 22 caracteres)
	DEFINE FONT oFnt6 NAME "Courier New" SIZE 16,22		//Descri��o do Produto
			
	// Consulta Estoque
	DEFINE MSDIALOG oDlg FROM 1,1 TO 453,637 TITLE STR0006 PIXEL OF oMainWnd	
	
	@  10, 05 TO  30, 135 LABEL STR0007 PIXEL OF oDlg // C�digo
	
	@  19, 11 SAY oCod   VAR AllTrim(cCod) SIZE 120,09 OF oDlg PIXEL;
	CENTER FONT IIf( Len(AllTrim(cCod)) > 22, oFnt5, oFnt4) COLOR CLR_GREEN

	@  35, 05 TO  70,135 PIXEL OF oDlg
	@  43, 10 SAY oMens  VAR cMens SIZE 120,20 OF oDlg PIXEL;
	CENTER FONT oFnt1 COLOR CLR_HRED
	
	@  75, 05 TO 172,135 PIXEL OF oDlg
	@  85, 10 SAY oTexto VAR cTexto SIZE 120,80 OF oDlg PIXEL;
	FONT oFnt2 COLOR CLR_HRED

	@ 177, 05 TO 200,302 LABEL STR0008 PIXEL OF oDlg // Descri��o de Produto
	@ 183, 10 SAY oDesc  VAR cDesc  SIZE 280,20 OF oDlg PIXEL;
	CENTER FONT oFnt6 COLOR CLR_HRED
	
	If cAliasF3 <> "FRT"	
		@ 205, 05 TO 225,120 LABEL STR0013 PIXEL OF oDlg // "Saldo dispon�vel no Estoque:"
		@ 212, 30 SAY oEst   VAR cEst PICTURE PesqPict("SB9","B9_QINI") SIZE 280,20 OF oDlg PIXEL;
		FONT oFnt2 COLOR CLR_GREEN
	EndIf
	
	@  13,142 REPOSITORY oBmp SIZE 161,130        PIXEL OF oDlg
	@ 147,142 TO 172,302 LABEL STR0009 PIXEL OF oDlg // Pre�o
	
	@ 157,149 SAY oPreco VAR cPreco	 SIZE 144,12 PIXEL OF oDlg;
	RIGHT FONT oFnt1 COLOR CLR_BLUE
	
	oBmp:SetColor(oDlg:nClrPane,oDlg:nClrPane)
	oBmp:lStretch := .T.
	
	DEFINE TIMER oTimerFrt INTERVAL nRPCInt*1000 ACTION LjTimerFrt() OF oDlg
	DEFINE TIMER oTimer INTERVAL 900  ACTION LJ060Timer(oMens,@cMens,@nCont,oDlg) OF oDlg
	@ 250,01 MSGET oGet VAR cProd SIZE 74,10 OF oDlg PIXEL F3 cAliasF3 VALID;
		IIf(ExistBlock("L060PRODOK"),ExecBlock("L060PRODOK",.F.,.F.),.T.) .AND.;
		lJ060Cod(oCod,oDesc,@cCod,@cDesc,oBmp,@cTexto,oTexto,@cPreco,oPreco,@cEst,oEst) .AND.;
		lj060Pr(oPreco,@cPreco,oGet,cCod) .AND.; 
		LJ060Est(oEst,@cEst,oGet,.T.)
	
	oGet:bLostFocus := { || iIf( Type("lUsaLeitor") == "L" .AND. lUsaLeitor, LeitorFoco(nHdlLeitor, .T.), Nil ) }
	oGet:bGotFocus  := { || iIf( Type("lUsaLeitor") == "L" .AND. lUsaLeitor, LeitorFoco(nHdlLeitor, .T.), Nil ) }
	oDlg:bGotFocus  := { || oGet:SetFocus() }
	
	DEFINE SBUTTON FROM 250,100 oButton TYPE 1 ACTION cProd := Space(TamSx3("B1_COD")[1]) OF oDlg ENABLE
	oButton:bGotFocus := {|| oGet:SetFocus() }

	If !lAutomato // variavel de controle do Robo	
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT ((If(nReg<>0,ShowBitMap(oBmp,SB1->B1_BITMAP,"LOJAWIN"),ShowBitMap(oBmp,"LOJAWIN"))),;
													oTimer:Activate(),oTimerFrt:Activate()) VALID FrtValid(@oTimerFrt)
	Else
		lJ060Cod(oCod,oDesc,@cCod,@cDesc,oBmp,@cTexto,oTexto,@cPreco,oPreco,@cEst,oEst)
		lj060Pr(oPreco,@cPreco,oGet,cCod) 
		LJ060Est(oEst,@cEst,oGet,.T.)
	EndIf	
	If lMultimidia
		Final(STR0012)
	EndIf
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �lj060Cod	� Autor � Pilar S. Albaladejo   � Data � 08.08.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe descricao do produto na tela						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � lj060Cod()												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function lj060Cod(oCod,oDesc,cCod,cDesc,oBmp,cTexto,oTexto,cPreco,oPreco,cEst,oEst)
Local lRet 			:= .T.
Local nI			:= 0	
Local lFR271AFotPrd := FindFunction("U_FR271AFotPrd")	// Veririfica se o ponto de entrada esta' com�lado no rpo
Local c271AFotPrd 	:= ""								// Retorno do ponto de entrada
Local cTamSx3Cod    := Space(TamSx3("B1_COD")[1])       // Tamanho do campo Codigo do Produto na tabela SX3 
Local cTamSx3Desc   := Space(TamSx3("B1_DESC")[1])		// Tamanho do campo Descricao do Produto na tabela SX3

// Campo verificador se est� sendo chamado pelo Robo
Local lAutomato	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

nQuant  := 1
cCodAux := cTamSx3Cod

nI := At("|", cProd)
If nI > 0
	cProd := PadR(Stuff(cProd, nI, 1, ""), TamSX3("BI_COD")[1])
EndIf

//�������������������������������������������������������������������������������
//�Se for FrontLoja faz a checagem de precos no SB0                             �
//�������������������������������������������������������������������������������
If "FRT" $ cRotina
	cArqAlias := "SBI"
	cArqPrefixo := "SBI->BI_"
Else
	cArqAlias := "SB1"
	cArqPrefixo := "SB1->B1_"
Endif

//�������������������������������������������������������������������������������
//�Faz a pesquisa dos produtos, no SB1 e no SLK                                 �
//�������������������������������������������������������������������������������
DbSelectArea(cArqAlias)
DbSetOrder(1)
If !LJSB1SLK(@cProd,@nQuant,If("FRT"$cRotina,.T.,.F.))
	lRet 	:= .F.
	cCod   	:= cTamSx3Cod
	cDesc 	:= cTamSx3Desc
	cProd 	:= cTamSx3Cod
	cPreco 	:= SuperGetMV("MV_SIMB1")+ " 0.00"
	cEst 	:= 0.00
	ShowBitMap(oBmp,&(cArqPrefixo+"BITMAP"),"LOJAWIN")
	cProd  	:= cTamSx3Cod
	cCodAux	:= &(cArqPrefixo+"COD")
Else
	If DbSeek(xFilial(cArqAlias)+cProd)
		cCod	:= cProd
		cDesc := Alltrim(&(cArqPrefixo+"DESC"))
		//�������������������������������������������������Ŀ
		//� PE para buscar a foto em diret�rio especifico   �
		//���������������������������������������������������
		If lFR271AFotPrd
			c271AFotPrd := U_FR271AFotPrd(cProd)
			If ValType(c271AFotPrd) == "C"
				If oBmp:cBMPFile <> c271AFotPrd
					oBmp:cBMPFile := c271AFotPrd
					ShowBitMap(oBmp,c271AFotPrd)
				EndIf
	    	EndIf
		Else	
		    If !lAutomato
		    	ShowBitMap(oBmp,&(cArqPrefixo+"BITMAP"),"LOJAWIN")
		    EndIf
	    EndIf

		If !("FRT"$cRotina) .AND. SuperGetMV("MV_L060SB5")
			DbSelectArea("SB5")
			DbSetOrder(1)
			If DbSeek(xFilial("SB5")+cProd)
				cTexto := Capital(SB5->B5_CEME)
			Else
				If DbSeek(xFilial("SB5")+cCodAux)
					cTexto := Capital(SB5->B5_CEME)
				Else
					cTexto := STR0005  // N�o existe hist�rico para este produto
				EndIf
			EndIf
		Else
			If ExistBlock("MV_L060SB5")
				cTexto := ExecBlock("MV_L060SB5",.F.,.F.)
				cTexto := cTexto
			Else
				cTexto := " "
			Endif
		Endif
		
	Else
		cDesc   := Alltrim(STR0010)  // Produto N�o Cadastrado
		cCodAux := cProd
		cCod	:= cProd
		ShowBitMap(oBmp,"LOJAWIN")
		cTexto := STR0010          // Produto N�o Cadastrado
	Endif
Endif  

DbSelectArea(cArqAlias)
DbSetOrder(1)

oDesc:Refresh()
oCod:Refresh()
oBmp:lVisible:=.T.
oBmp:Refresh()
oTexto:Refresh() 
oPreco:Refresh()

If !lRet
	// Produto n�o Cadastrado
    If !( "FRT" $ cRotina )
        oEst:Refresh()
    EndIf

	MsgRun(STR0005,STR0010,{|| inkey(1)})
	oGet:SetFocus()
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �lj060Pr	� Autor � Pilar S. Albaladejo   � Data � 08.08.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe preco do produto na tela							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � lj060Pr()												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function lj060Pr(oPreco,cPreco,oGet,cCod)
Local nTmpPreco := 0
Local cTabela   := SuperGetMV( "MV_TABPAD" )
Local lL060Prc	:= ExistBlock( "L060PRC" )
Local nPreco	:= 0

cPreco := SuperGetMV("MV_SIMB1")+ " "

If lCenVenda
	LjxeValPre(@nPreco, cProd, /*cCliente*/, /*cLoja*/)
EndIf	
	
If "FRT" $ cRotina
	DbSelectArea("SBI")
	DbSetOrder(1)
	DbSeek(xFilial("SBI")+cProd)
	If lCenVenda
		nTmpPreco := nPreco * nQuant
	Else
		nTmpPreco := SBI->BI_PRV * nQuant	
	EndIf	
	cPreco := cPreco + Alltrim(Str(nTmpPreco,17,2))
Else
	If lCenVenda
		nTmpPreco := nPreco * nQuant	
		cPreco := Alltrim(Str( nTmpPreco,17,2))	    
	Else
		DbSelectArea("SB0")
		DbSetOrder(1)
		if DbSeek(xFilial("SB0")+cProd)
			nTmpPreco := SB0->&("B0_PRV" + cTabela) * nQuant
			cPreco := Alltrim(Str( nTmpPreco,17,2))
		Else
			cPreco := "0,00"
		EndIf
	EndIf	
Endif

If lL060Prc
	cPreco := ExecBlock( "L060PRC", .F., .F., {nTmpPreco,cCod} )
	If ValType(cPreco) <> "C"
		cPreco := Alltrim(Str(nTmpPreco,17,2))
	Endif
Endif

oPreco:Refresh()
oGet:Refresh()
Eval(oGet:bLostFocus)
Eval(oGet:bGotFocus)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �lj060Pr_1	� Autor � Pilar S. Albaladejo   � Data � 08.08.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe preco do produto na tela							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � lj060Pr()												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function lj060Pr_1(cCod)
Local cPreco
Local nTmpPreco := 0
Local cTabela   := SuperGetMV( "MV_TABPAD" )
Local lL060Prc	:= ExistBlock( "L060PRC" )
Local nPreco	:= 0

cPreco := SuperGetMV("MV_SIMB1")+ " "

If lCenVenda
	LjxeValPre(@nPreco, cProd, /*cCliente*/, /*cLoja*/)
	nTmpPreco := nPreco * nQuant
	cPreco := cPreco + Alltrim(Str(nTmpPreco,17,2))
Else	
	If "FRT" $ cRotina
		DbSelectArea("SBI")
		DbSetOrder(1)
		DbSeek(xFilial("SBI")+cProd)
		nTmpPreco := SBI->BI_PRV * nQuant
		cPreco := cPreco + Alltrim(Str(nTmpPreco,17,2))
	Else
		DbSelectArea("SB0")
		DbSetOrder(1)
		If DbSeek(xFilial("SB0")+cProd)
			nTmpPreco := SB0->&("B0_PRV" + cTabela) * nQuant
			cPreco := cPreco + Alltrim(Str( nTmpPreco,17,2))
		Else
			If DbSeek(xFilial("SB0")+cCodAux)
				nTmpPreco := SB0->&("B0_PRV" + cTabela) * nQuant
				cPreco := cPreco + Alltrim(Str( nTmpPreco,17,2))
			Else
				cPreco := cPreco + "0,00"
			EndIf
		Endif
	Endif
EndIf

If lL060Prc
	cPreco := ExecBlock( "L060PRC", .F., .F., {nTmpPreco,cCod} )
	If ValType(cPreco) <> "C"
		cPreco := Alltrim(Str(nTmpPreco,17,2))
	Endif
Endif

Return cPreco

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �lj060Timer� Autor � Fernando Godoy		� Data � 23.07.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Mostra mensagem animada 									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � lj060Timer												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function LJ060Timer(oMens,cMens,nCont,oLocalDlg)

If nCont == 1
	cMens := STR0004                     // PASSE O LEITOR
	nCont := 0
	oMens:SetColor(CLR_HRED,oLocalDlg:nClrPane)
ElseIf nCont == 0
	cMens := STR0011                     // DE CODIGO DE BARRAS
	nCont := 1
	oMens:SetColor(CLR_HBLUE,oLocalDlg:nClrPane)
EndIf

oMens:Refresh()

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJ060Est  �Autor  �Fernando Salvatori  � Data �  03/01/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     � Exibe o Saldo em Estoque do Produto                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � LOJC060                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LJ060Est(oEst,cEst,oGet,lRefresh)

//�����������������������������������������������������������������Ŀ
//� Funcao utilizada para verificar a ultima versao dos fontes      �
//� SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        �
//�������������������������������������������������������������������
If !(FindFunction("SIGACUS_V") .AND. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
If !(FindFunction("SIGACUSA_V") .AND. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
If !(FindFunction("SIGACUSB_V") .AND. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

DbSelectArea( "SB1" )
DbSetOrder( 1 )    
DbSeek( xFilial( "SB1" ) + cProd )

DbSelectArea( "SB2" )
DbSetOrder( 1 )
DbSeek( xFilial( "SB2" ) + cProd + RetFldProd(SB1->B1_COD,"B1_LOCPAD") )

cEst := SaldoSB2()

// Se a chamada desta funcao nao vier do Front Loja, atualiza o objeto oEst
If lRefresh
    If !( "FRT" $ cRotina )
        oEst:Refresh()
    EndIf
    oGet:SelectAll()
    oGet:SetFocus()
EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �ljTimerFrt� Autor � Vendas Clientes		� Data � 12.03.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ativa a integracao com a retaguarda						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � ljTimerFrt												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ljTimerFrt()

IpcGo(WAITID)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FrtValid  � Autor � Vendas Clientes		� Data � 12.03.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Desativa o Timer da integracao com a retaguarda			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � DroValid 												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FrtValid(oTimerFrt)

oTimerFrt:DeActivate()

Return .T.
