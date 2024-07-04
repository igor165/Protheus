#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA960.CH"

Function LOJA960()
//�������������������������������������������������������������������������Ŀ
//� Define o menu da gestao de acervos                                      �
//���������������������������������������������������������������������������
PRIVATE aCols 	:= {}													// Campos da GetDados
PRIVATE aHeader	:= {}												 	// Array com Cabecalho dos campos
Private aRotina := {	{  	STR0001   ,	"AxPesqui", 	0 , 1},;	 	//"Pesquisar"
						{ 	STR0002   ,	"Lj960Main", 	0 , 2},;	 	//"Visualizar"
						{ 	STR0003   ,	"Lj960Main", 	0 , 3},;	 	//"Incluir"
						{ 	STR0004   ,	"Lj960Main", 	0 , 4},;	 	//"Alterar"
						{ 	STR0005   ,	"Lj960Main", 	0 , 5}} 	 	//"Excluir"

//�������������������������������������������������������������������������Ŀ
//� Define o cabe�alho da tela de atualiza�oes                              �
//���������������������������������������������������������������������������
Private cCadastro	:= STR0006	//"Cadastro de Menus de Produtos"
mBrowse( 6, 1,22,75,"SL7" )

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj960Main �Autor  �Thiago Honorato     � Data �  04/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para manutencao no cadastro de botoes dos produtos   ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA Interface TOUCHSCREEN                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Lj960Main( cAlias, nReg, nOpc )

Local nSaveSx8		:= GetSx8Len()				// Controle de semaforo
Local aCamposEnc	:= {}						// Relacao dos campos que estao na enchoice para gravacao do
Local nX			:= 0                     	// Contador
Local aRecno		:= {}						// Array com a posicao do Registro
Local lRet			:= .F.						// Variavel de retorno
//�������������������������������������������������������������������������Ŀ
//� Forca a abertura dos arquivos                                           �
//���������������������������������������������������������������������������
DbSelectArea("SL7")
//�������������������������������������������������������������������������Ŀ
//� Inicializacao das variaveis da Enchoice                                 �
//���������������������������������������������������������������������������
RegToMemory( "SL7", (nOpc == 3), (nOpc == 3) )

DbSelectArea( "SX3" )
DbSetOrder( 1 )	// X3_ARQUIVO+X3_ORDEM
DbSeek( "SL7" )
While !Eof() .AND. SX3->X3_ARQUIVO == "SL7"
	If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
		aAdd( aCamposEnc, SX3->X3_CAMPO )
	Endif
	DbSkip()
End

//����������������������������������Ŀ
//� Cria aHeader e aCols da GetDados �
//������������������������������������
nUsado	:=0
DbSelectArea("SX3")
DbSeek("SL8")
aHeader	:={}

While !Eof() .AND. (X3_ARQUIVO == "SL8" )
	If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
		Aadd(aHeader,{ 	TRIM( SX3->X3_TITULO )	,;  //01 - Titulo
		SX3->X3_CAMPO			,;	//02 - campo
		SX3->X3_PICTURE			,;	//03 - Picture
		SX3->X3_TAMANHO			,;	//04 - Tamanho
		SX3->X3_DECIMAL			,;	//05 - Decimal
		SX3->X3_VALID			,;	//06 - Valid do campo (Sistema)
		SX3->X3_USADO			,;	//07 - Usado ou nao
		SX3->X3_TIPO			,;	//08 - Tipo
		SX3->X3_ARQUIVO			,;	//09 - Arquivo
		SX3->X3_CONTEXT } )			//10 - Contexto
	Endif
	DbSkip()
End

aCols:={}
DbSelectArea("SL8")
DbSetOrder(1)
nUsado	:= Len( aHeader )

If !INCLUI
	If DbSeek( xFilial( "SL8" ) + M->L7_CODIGO )
		
		While 	!EOF() 								.AND.;
			SL8->L8_FILIAL == xFilial( "SL8" ) 	.AND.;
			SL8->L8_CODIGO == M->L7_CODIGO
			
			//������������������������������������Ŀ
			//� Nao acrescenta recno caso for copia�
			//��������������������������������������
			AAdd( aCols, Array( nUsado + 1 ) )
			AAdd( aRecno, SL8->( Recno() ) )
			
			//������������������Ŀ
			//� Acrescenta acols �
			//��������������������
			For nX := 1 To nUsado
				If ( aHeader[nX][10] <>  "V" )
					aCols[Len( aCols )][nX] := SL8->( FieldGet( FieldPos( aHeader[nX][2] ) ) )
				Else
					aCols[Len( aCols )][nX] := CriaVar( aHeader[nX][2], .T. )
				Endif
			Next nX
			
			aCols[Len( aCols )][ nUsado + 1 ] := .F.
			
			SL8->( DbSkip() )
		End
	Endif
	
Else
	//��������������������������������������������Ŀ
	//� Se for uma inclusao inicializa o acols     �
	//����������������������������������������������
	AAdd( aCols, Array( nUsado + 1 ) )
	For nX := 1 To nUsado
		If AllTrim( aHeader[ nX][2] ) == "L8_ITEM"
			aCols[Len( aCols )][nX] := StrZero( 1, Len( SL8->L8_ITEM ) )
		Else
			aCols[Len( aCols )][nX] := CriaVar( aHeader[nX][2], .T. )
		Endif
		aCols[Len( aCols )][ nUsado + 1 ] := .F.
		
	Next nX
	
Endif

If Len( aCols ) >= 0
	
	//��������������������Ŀ
	//� Executa a Modelo 3 �
	//����������������������
	cTitulo			:= STR0007	//"Menus de Produtos"
	cLinOk			:= "LJ960LOK()"
	cTudOk			:= "LJ960TOK()"
	cFieldOk		:= "AllwaysTrue()"
	lRet 			:= LJ960Tela(	cTitulo,	"SL7",	"SL8",	aCamposEnc,;
									cLinOk ,   cTudOk,	 nOpc,	nOpc      ,;
									cFieldOk )
	//������������������������Ŀ
	//� Executar processamento �
	//��������������������������
	If lRet
		
		//�������������������������������������������������������������������������Ŀ
		//� Chama a funcao de gravacao - Botoes para os produtos                    �
		//���������������������������������������������������������������������������
		If nOpc <> 2 // 2 = Visualizacao
			lGravou := LJ960Grv( nOpc,	aCamposEnc, aHeader, aCols,;
 								 aRecno )
		
			//�������������������������������������������������������������������������Ŀ
			//� Controle do semaforo                                                    �
			//���������������������������������������������������������������������������
			If lGravou
				If nOpc == 3
					While ( GetSx8Len() > nSaveSx8 )
						ConfirmSx8()
					End
				Endif
			Else
				While ( GetSx8Len() > nSaveSx8 )
					RollBackSx8()
				End
			Endif
		EndIf
	Else
		//�������������������������������������������������������������������������Ŀ
		//� Controle do semaforo                                                    �
		//���������������������������������������������������������������������������
		While (GetSx8Len() > nSaveSx8)
			RollBackSx8()
		End
	Endif
Endif

Return NIL

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �LJ960Grv  � Autor � Thiago Honorato       � Data � 17/02/2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de Gravacao                                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1: Opcao da Gravacao sendo:                               ���
���          �       [1] Inclusao                                           ���
���          �       [2] Alteracao                                          ���
���          �       [3] Exclusao                                           ���
���          �ExpA2: Array de registros                                     ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Pesquisa e Resultado                                         ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function LJ960Grv( nOpc,		aCamposEnc, 	aHeader,	aCols,;
						  aRecno )

Local aArea     := GetArea()						// Salva a area atual
Local bCampo 	:= {|nCPO| Field(nCPO) }    		// Nome do campo
Local cItem     := Repl("0",Len( SL8->L8_ITEM ))	// Numero do Item
Local nX        := 0								// Contador
Local nField    := 0								// Contador
Local nLinha    := 0								// Contador de linhas do Acols
Local nPos		:= 0								// Posicao do campo SL8_VALOR
Local lTravou   := .F.								// Flag para garantir o lock de registro

DbSelectArea( "SL7" )
DbSelectArea( "SL8" )

//�������������������������������Ŀ
//�Se  for INCLUSAO ou ALTERACAO  �
//���������������������������������
If ( nOpc == 3 ) .OR. ( nOpc == 4)
	
	//�������������������������������������������������������������������Ŀ
	//�Grava a pesquisa e as regras da pesquisa                           �
	//���������������������������������������������������������������������
	BEGIN TRANSACTION
	
	//��������������������������Ŀ
	//�Grava os dados da Campanha�
	//����������������������������
	DbSelectArea( "SL7" )
	DbSetOrder(1)
	If DbSeek( xFilial( "SL7" ) + M->L7_CODIGO )
		RecLock("SL7",.F.)
	Else
		RecLock("SL7",.T.)
	Endif
	
	For nField := 1 To SL7->( FCount() )
		FieldPut(nField, M->&(EVAL( bCampo, nField ) ) )
	Next nField
	
	REPLACE SL7->L7_FILIAL WITH xFilial("SL7")
	
	MsUnLock()
	
	//����������������������������������������������������������������Ŀ
	//�Grava os dados  do SL8 (Itens do Menu)                    	   �
	//������������������������������������������������������������������
	
	DbSelectarea("SL8")
	bCampo := {|nCPO| Field(nCPO) }
	
	For nX := 1 To Len( aCols )
		
		// Flag para garantir o lock de registro
		lTravou := .F.
		
		// Se a linha atual for menor que o total de registros
		If nX <= Len( aRecNo )
			DbSelectArea( "SL8" )
			DbGoTo( aRecNo[nX] )
			RecLock("SL8",.F.)
			
			// Lock do regsitro que sera alterado
			lTravou := .T.
		Endif
		
		// Se a linha atual nao foi DELETADA
		If(!aCols[nX][nUsado+1] .AND.;
		  (!Empty(aCols[nX][aScan(aHeader,{|x| Alltrim( x[2] ) == "L8_ITEM"})])   .AND. ;
		   !Empty(aCols[nX][aScan(aHeader,{|x| Alltrim( x[2] ) == "L8_TEXTO"})])) .AND. ;
		  (!Empty(aCols[nX][aScan(aHeader,{|x| Alltrim( x[2] ) == "L8_CODGRP"})]) .OR.  ;
		   !Empty(aCols[nX][aScan(aHeader,{|x| Alltrim( x[2] ) == "L8_CODPROD"})])))
			 			
			//Se nao fez o LOCK significa que e uma nova Linha
			If !lTravou
				RecLock("SL8",.T.)
			Endif
			
			cItem := Soma1(cItem,Len(SL8->L8_ITEM))
			REPLACE SL8->L8_FILIAL WITH xFilial("SL8")
			REPLACE SL8->L8_CODIGO WITH SL7->L7_CODIGO
			REPLACE SL8->L8_ITEM   WITH cItem
			
			bCampo := {|nCPO| Field(nCPO) }
			
			For nLinha := 1 To SL8->(FCount())
				
				If !(EVAL(bCampo,nLinha) == "L8_FILIAL")
					nPos := Ascan(aHeader,{|x| ALLTRIM(EVAL(bCampo,nLinha)) == ALLTRIM(x[2])})
					If (nPos > 0)
						If (aHeader[nPos][10] <> "V" .AND. aHeader[nPos][08] <> "M")
							REPLACE SL8->&(EVAL(bCampo,nLinha)) WITH aCols[nX][nPos]
						Endif
					Endif
				Endif
				
			Next nLinha
			MsUnLock()
			
			lGravou := .T.
		Else
			If lTravou
				RecLock("SL8",.F.)
				SL8->(DbDelete())
				MsUnlock()
			Endif
		Endif
		MsUnLock()
		
	Next nX
	
	END TRANSACTION
	
Else
	
	//�������������������������������������������Ŀ
	//�Deleta SL8                                 �
	//���������������������������������������������
	DbSelectArea("SL8")
	DbSetOrder(1)
	If DbSeek(xFilial("SL8")+M->L7_CODIGO)
		While !SL8->(EOF()) .AND. DbSeek(xFilial("SL8")+M->L7_CODIGO)
			RecLock("SL8",.F.)
			DbDelete()
			MsUnlock()
		End
	EndIf
	
	//�������������������������������������������Ŀ
	//�Deleta SL7                                 �
	//���������������������������������������������
	DbSelectArea("SL7")
	RecLock("SL7", .F.)
	DbDelete()
	MsUnlock()
	
Endif

RestArea(aArea)

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJ960LOK  �Autor  �Thiago Honorato     � Data �  04/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para validacao do linkok. Valida se o valor foi      ���
���          �preenchido.                                                 ���
�������������������������������������������������������������������������͹��
���Uso       � LOJA960 - SIGALOJA                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LJ960LOK()
Local lRet	      := .T.													// Retorno da funcao
Local nPosItem    := aScan(aHeader,{|x| Alltrim( x[2] ) == "L8_ITEM"})		// Posicao da coluna ITEM
Local nPosTexto   := aScan(aHeader,{|x| Alltrim( x[2] ) == "L8_TEXTO"})   	// Posicao da coluna TEXTO
Local nPosGrup    := aScan(aHeader,{|x| Alltrim( x[2] ) == "L8_CODGRP"})  	// Posicao da coluna COD. GRUPO
Local nPosProd    := aScan(aHeader,{|x| Alltrim( x[2] ) == "L8_CODPROD"}) 	// Posicao da coluna COD. PRODUTO
Local nCount	  := 0														// Controla loop
Local nMais		  := 0														// Controla o quantidade de caracter '+'	

If !aCols[n,Len(aHeader)+1]
    // Verificando se os campos Item e Texto Botao estao preenchidos
	If !Empty(aCols[n,nPosItem]) 
		//Verificando se os campo Cod. Grupo + Cod. Produto estao preenchidos (apenas um pode ser escolhido)
		If !Empty(aCols[n,nPosTexto])
			// Verifica se o ultimo caracter eh o caracter '+'
			If SubStr(aCols[n,nPosTexto],Len(AllTrim(aCols[n,nPosTexto])),1) == '+'
				MsgStop( STR0017 + CHR(10) + ;		//"O final do texto n�o pode conter quebra de linha."  
						 STR0018 )					//"Verifique o conte�do da coluna Texto bot�o!"
				lRet := .F.
			Else	
				// verifica se o caracter '+' aparece mais de duas vezes dentro de uma string.
				For nCount := 1 to Len(aCols[n,nPosTexto])
					If SubStr(aCols[n,nPosTexto],nCount,1) == '+'
						nMais ++					
					Endif
                    If nMais > 2
						MsgStop( STR0019 + CHR(10) + ;		//"Quantidade de quebra de linhas inv�lido(m�ximo 3 linhas)." 
								 STR0018 )					//"Verifique o conte�do da coluna Texto bot�o!"
						lRet := .F.			
						Exit
                    Endif
				Next nCount
			Endif
			If lRet
				If !Empty(aCols[n,nPosGrup]) .AND. ;
		 		   !Empty(aCols[n,nPosProd])
					MsgStop(STR0008)	//"Deve-se optar pelo preenchimento dos campos Cod. Grupo ou Cod. Produto!"
					lRet	:= .F.
				Else
					If  Empty(aCols[n,nPosGrup]) .AND. ;
					    Empty(aCols[n,nPosProd])
						MsgStop(STR0009)	//"Preencher os campos Cod. Grupo ou Cod. Produto!"				
						lRet	:= .F.
					Endif	
				Endif
			Endif
		Endif
	Else
		MsgStop(STR0010)		//"Verifique se o campo Item est� preenchido"		
		lRet	:= .F.
	Endif
    //Verificando se o grupo escolhido esta' ATIVO      
    If lRet
	    If !Empty(aCols[n,nPosGrup])
			DbSelectArea("SL7")
			DbSetOrder(1)
			If DbSeek(xFilial("SL7") + aCols[n,nPosGrup] )
				If SL7->L7_ATIVO == "2"
					MsgStop(STR0011 + aCols[n,nPosGrup] + STR0012)	//"O grupo " + ##### + " n�o est� Ativo!"
					lRet := .F.
				Endif
			Else
				MsgStop(STR0011 + aCols[n,nPosGrup] + STR0013)	//"O grupo " + ##### + 	" n�o est� cadastrado!"
				lRet := .F.				
			Endif
		Endif	
    Endif 
EndIf

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJ960TOK 	�Autor  �Thiago Honorato     � Data �  04/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para validacao do TudoOK                             ���
�������������������������������������������������������������������������͹��
���Uso       � LOJA960 SIGALOJA                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LJ960TOK()
Local lRet	   := .T.				// Retorno da funcao
Local nCount   := 0              	// Controle de loop
Local nCt      := 0              	// Controle de loop
Local nPosItem := aScan(aHeader,{|x| Alltrim( x[2] ) == "L8_ITEM"}) // Posicao da coluna ITEM

//Verificando repeticao de ITEM 
If Len(aCols) > 1
	For nCount := 1 to Len(aCols) - 1
		For nCt := nCount + 1  to Len(aCols)
			If !aCols[nCount,Len(aHeader)+1]
				If aCols[nCount,nPosItem] == aCols[nCt,nPosItem] .AND. !aCols[nCt,Len(aHeader)+1]     
					MsgStop(STR0015 + aCols[nCt,nPosItem] + STR0016 )	// "Item" + ### + "repetido. Favor verificar!"
					lRet := .F.
					Exit
				Endif
			Endif
		Next nCt
		If !lRet
			Exit
		Endif	
	Next nCount	
Endif

Return (lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �LJ960Tela	  � Autor � Thiago Honorato     � Data � 04/10/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Enchoice e GetDados									  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�lRet:=Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk, 	  ���
���			 � cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice)���
���			 �lRet=Retorno .T. Confirma / .F. Abandona					  ���
���			 �cTitulo=Titulo da Janela 									  ���
���			 �cAlias1=Alias da Enchoice									  ���
���			 �cAlias2=Alias da GetDados									  ���
���			 �aMyEncho=Array com campos da Enchoice						  ���
���			 �cLinOk=LinOk 												  ���
���			 �cTudOk=TudOk 												  ���
���			 �nOpcE=nOpc da Enchoice									  ���
���			 �nOpcG=nOpc da GetDados									  ���
���			 �cFieldOk=validacao para todos os campos da GetDados 		  ���
���			 �lVirtual=Permite visualizar campos virtuais na enchoice	  ���
���			 �nLinhas=Numero Maximo de linhas na getdados				  ���
���			 �aAltEnchoice=Array com campos da Enchoice Alteraveis		  ���
���			 �nFreeze=Congelamento das colunas.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 �RdMake 													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function LJ960Tela(	cTitulo,	cAlias1,	cAlias2,	aMyEncho,;
							cLinOk,		cTudOk ,	nOpcE,		nOpcG,;
							cFieldOk,	lVirtual,	nLinhas,	aAltEnchoice,;
							nFreeze,	aButtons )

Local lRet
Local nOpca 	:= 0
Local nReg := (cAlias1)->(Recno())
Local oDlg
Local oEnchoice
Local aSize      := MsAdvSize( .T., .F., 400 )		// Size da Dialog
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}

Private aTELA  := Array(0,0)
Private aGets  := Array(0)
Private bCampo := {|nCPO|Field(nCPO)}

nOpcE    := If(nOpcE    == NIL, 3  , nOpcE)
nOpcG    := If(nOpcG    == NIL, 3  , nOpcG)
lVirtual := If(lVirtual == NIL, .F., lVirtual)
nLinhas  := If(nLinhas  == NIL, 99 , nLinhas)

//���������������������������������������������������������������������Ŀ
//� Divide a tela horizontalmente para os objetos enchoice e getdados   �
//�����������������������������������������������������������������������
aObjects := {}

AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo       := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj     := MsObjSize( aInfo, aObjects,  , .F. )


DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 TO aSize[6],aSize[5] PIXEL OF oMainWnd //"Configura��o"

oEnchoice := Msmget():New(cAlias1,nReg,nOpcE,,,,aMyEncho, aPosObj[1], aAltEnchoice,3,,,,,,lVirtual,,,,,,,,.T.)
oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudOk,"+L8_ITEM",.T.,,nFreeze,,nLinhas,cFieldOk)

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca := 1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons),;
AlignObject(oDlg,{oEnchoice:oBox,oGetDados:oBrowse},1,,{110}))

lRet := (nOpca == 1)
Return lRet

