#INCLUDE "PROTHEUS.CH"
#INCLUDE "FRTA801.CH"

Static nTiopoOp := 0

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FRTA801   �Autor  �VENDAS CRM          � Data �  04/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para manutencao no cadastro de botoes dos produtos   ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA Interface TOUCHSCREEN                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FRTA801()
//�������������������������������������������������������������������������Ŀ
//� Define o menu da gestao de acervos                                      �
//���������������������������������������������������������������������������
PRIVATE aCols 	:= {}													// Campos da GetDados
PRIVATE aHeader	:= {}												 	// Array com Cabecalho dos campos
Private aRotina := {	{  	STR0001   ,	"AxPesqui", 	0 , 1},;	 	//"Pesquisar"
						{ 	STR0002   ,	"Fr801Main", 	0 , 2},;	 	//"Visualizar"
						{ 	STR0003   ,	"Fr801Main", 	0 , 3},;	 	//"Incluir"
						{ 	STR0004   ,	"Fr801Main", 	0 , 4},;	 	//"Alterar"
						{ 	STR0005   ,	"Fr801Main", 	0 , 5}} 	 	//"Excluir"

//�������������������������������������������������������������������������Ŀ
//� Define o cabe�alho da tela de atualiza�oes                              �
//���������������������������������������������������������������������������
Private cCadastro	:= STR0006	//"Cadastro de Menus de Produtos"
mBrowse( 6, 1,22,75,"MDV" )

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fr801Main �Autor  �VENDAS CRM          � Data �  04/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para manutencao no cadastro de botoes dos produtos   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       �  FrontLoja                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function Fr801Main( cAlias, nReg, nOpc )

Local nSaveSx8		:= GetSx8Len()				// Controle de semaforo
Local aCamposEnc	:= {}						// Relacao dos campos que estao na enchoice para gravacao do
Local nX			:= 0                     	// Contador
Local aRecno		:= {}						// Array com a posicao do Registro
Local lRet			:= .F.						// Variavel de retorno

nTiopoOp := nOpc
//�������������������������������������������������������������������������Ŀ
//� Forca a abertura dos arquivos                                           �
//���������������������������������������������������������������������������
DbSelectArea("MDV")
//�������������������������������������������������������������������������Ŀ
//� Inicializacao das variaveis da Enchoice                                 �
//���������������������������������������������������������������������������
RegToMemory( "MDV", (nOpc == 3), (nOpc == 3) )

DbSelectArea( "SX3" )
DbSetOrder( 1 )	// X3_ARQUIVO+X3_ORDEM
DbSeek( "MDV" )
While !Eof() .AND. SX3->X3_ARQUIVO == "MDV"
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
DbSeek("MDX")
aHeader	:={}

While !Eof() .AND. (X3_ARQUIVO == "MDX" )
	If (X3Uso(SX3->X3_USADO)) .AND. (cNivel >= SX3->X3_NIVEL) 
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
DbSelectArea("MDX")
DbSetOrder(1)
nUsado	:= Len( aHeader )

If !INCLUI
	If DbSeek( xFilial( "MDX" ) + M->MDV_CODIGO )
		
		While 	!EOF() 								.AND.;
			MDX->MDX_FILIAL == xFilial( "MDX" ) 	.AND.;
			MDX->MDX_CODIGO == M->MDV_CODIGO
			
			//������������������������������������Ŀ
			//� Nao acrescenta recno caso for copia�
			//��������������������������������������
			AAdd( aCols, Array( nUsado + 1 ) )
			AAdd( aRecno, MDX->( Recno() ) )
			
			//������������������Ŀ
			//� Acrescenta acols �
			//��������������������
			For nX := 1 To nUsado
				If ( aHeader[nX][10] <>  "V" )
					aCols[Len( aCols )][nX] := MDX->( FieldGet( FieldPos( aHeader[nX][2] ) ) )
				Else
					aCols[Len( aCols )][nX] := CriaVar( aHeader[nX][2], .T. )
				Endif
			Next nX
			
			aCols[Len( aCols )][ nUsado + 1 ] := .F.
			
			MDX->( DbSkip() )
		End
	Endif
	
Else
	//��������������������������������������������Ŀ
	//� Se for uma inclusao inicializa o acols     �
	//����������������������������������������������
	AAdd( aCols, Array( nUsado + 1 ) )
	For nX := 1 To nUsado
		If AllTrim( aHeader[ nX][2] ) == "MDX_ITEM"
			aCols[Len( aCols )][nX] := StrZero( 1, Len( MDX->MDX_ITEM ) )
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
	cLinOk			:= "Fr801LOK()"
	cTudOk			:= "Fr801TOK()"
	cFieldOk		:= "AllwaysTrue()"
	lRet 			:= Fr801Tela(	cTitulo,	"MDV",	"MDX",	aCamposEnc,;
									cLinOk ,   cTudOk,	 nOpc,	nOpc      ,;
									cFieldOk )
	//������������������������Ŀ
	//� Executar processamento �
	//��������������������������
	If lRet
		
		//�������������������������������������������������������������������������Ŀ
		//� Chama a funcao de gravacao - Botoes para os produtos                    �
		//���������������������������������������������������������������������������
		lGravou := fr801Grv( nOpc,	aCamposEnc, aHeader, aCols,;
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
���Fun��o    �Fr801Grv  � Autor �VENDAS CRM             � Data �  04/06/10  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de Gravacao                                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1: Opcao da Gravacao sendo:                               ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Pesquisa e Resultado                                         ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function Fr801Grv( nOpc,		aCamposEnc, 	aHeader,	aCols,;
						  aRecno )

Local aArea     := GetArea()						// Salva a area atual
Local bCampo 	:= {|nCPO| Field(nCPO) }    		// Nome do campo
Local cItem     := Repl("0",Len( MDX->MDX_ITEM ))	// Numero do Item
Local nX        := 0								// Contador
Local nField    := 0								// Contador
Local nLinha    := 0								// Contador de linhas do Acols
Local nPos		:= 0								// Posicao do campo SL8_VALOR
Local lTravou   := .F.								// Flag para garantir o lock de registro
Local cTextoBtn := ""								// Conteudo que sera' gravado no campo L8_TEXTO

DbSelectArea( "MDV" )
DbSelectArea( "MDX" )

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
	DbSelectArea( "MDV" )
	DbSetOrder(2)
	If !Empty(M->MDV_CODIGO) .AND. DbSeek( xFilial( "MDV" ) + M->MDV_CODIGO )
		RecLock("MDV",.F.)
	Else
		RecLock("MDV",.T.)
		REPLACE MDV->MDV_CODIGO WITH GetSxENum("MDV","MDV_CODIGO")
	Endif
	
	For nField := 1 To MDV->( FCount() )
		If EVAL( bCampo, nField ) <> "MDV_CODIGO"
			FieldPut(nField, M->&(EVAL( bCampo, nField ) ) )
		EndIf	
	Next nField
	
	REPLACE MDV->MDV_FILIAL WITH xFilial("MDV")
	
	MsUnLock()
	
	//����������������������������������������������������������������Ŀ
	//�Grava os dados  do SL8 (Itens do Menu)                    	   �
	//������������������������������������������������������������������
	
	DbSelectarea("MDX")
	bCampo := {|nCPO| Field(nCPO) }
	
	For nX := 1 To Len( aCols )
		
		// Flag para garantir o lock de registro
		lTravou := .F.
		
		// Se a linha atual for menor que o total de registros
		If nX <= Len( aRecNo )
			DbSelectArea( "MDX" )
			DbGoTo( aRecNo[nX] )
			RecLock("MDX",.F.)
			
			// Lock do regsitro que sera alterado
			lTravou := .T.
		Endif

		// Se a linha atual nao foi DELETADA
		If(!aCols[nX][nUsado+1] .AND.;
		  (!Empty(aCols[nX][aScan(aHeader,{|x| Alltrim( x[2] ) == "MDX_ITEM"})])   .AND. ;
		   !Empty(aCols[nX][aScan(aHeader,{|x| Alltrim( x[2] ) == "MDX_CODADM"})])))

		
			//Se nao fez o LOCK significa que e uma nova Linha
			If !lTravou
				RecLock("MDX",.T.)
			Endif
			
			cItem := Soma1(cItem,Len(MDX->MDX_ITEM))
			REPLACE MDX->MDX_FILIAL WITH xFilial("MDX")
			REPLACE MDX->MDX_CODIGO WITH MDV->MDV_CODIGO
			REPLACE MDX->MDX_ITEM   WITH cItem
			REPLACE MDX->MDX_NPARC  WITH MDV->MDV_NPARC
			
			bCampo := {|nCPO| Field(nCPO) }
			
			For nLinha := 1 To MDX->(FCount())
				
				If (!(EVAL(bCampo,nLinha) == "MDX_FILIAL")) .AND. (!(EVAL(bCampo,nLinha) == "MDX_CODIGO")) .AND.;
				 	(!(EVAL(bCampo,nLinha) == "MDX_ITEM")) .AND. (!(EVAL(bCampo,nLinha) == "MDX_NPARC")) 
					
					nPos := Ascan(aHeader,{|x| ALLTRIM(EVAL(bCampo,nLinha)) == ALLTRIM(x[2])})
					If (nPos > 0)
						If (aHeader[nPos][10] <> "V" .AND. aHeader[nPos][08] <> "M")
							REPLACE MDX->&(EVAL(bCampo,nLinha)) WITH aCols[nX][nPos]
						Endif
					Endif
				Endif
				
			Next nLinha
			MsUnLock()
			
			lGravou := .T.
		Else
			If lTravou
				RecLock("MDX",.F.)
				MDX->(DbDelete())
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
	DbSelectArea("MDX")
	DbSetOrder(1)
	If DbSeek(xFilial("MDX")+M->MDV_CODIGO)
		While !MDX->(EOF()) .AND. DbSeek(xFilial("MDX")+M->MDV_CODIGO)
			RecLock("MDX",.F.)
			DbDelete()
			MsUnlock()
		End
	EndIf
	
	//�������������������������������������������Ŀ
	//�Deleta SL7                                 �
	//���������������������������������������������
	DbSelectArea("MDV")
	RecLock("MDV", .F.)
	DbDelete()
	MsUnlock()
	
Endif

RestArea(aArea)

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fr801LOK  �Autor  �VENDAS CRM          � Data �  04/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para validacao do linkok. Valida se o valor foi      ���
���          �preenchido.                                                 ���
�������������������������������������������������������������������������͹��
���Uso       � LOJA801 - SIGALOJA                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fr801LOK()

Local lRet := .T. // Retorno

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fr801TOK 	�Autor  �VENDAS CRM          � Data �  04/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para validacao do TudoOK                             ���
�������������������������������������������������������������������������͹��
���Uso       � LOJA801 SIGALOJA                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fr801TOK()
Local lRet	   := .T.				// Retorno da funcao
Local nCount   := 0              	// Controle de loop
Local nCt      := 0              	// Controle de loop
Local nPosItem := aScan(aHeader,{|x| Alltrim( x[2] ) == "MDX_ITEM"}) // Posicao da coluna ITEM

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
���Fun��o	 �Fr801Tela	  � Autor �VENDAS CRM           � Data �  04/06/10���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Enchoice e GetDados									  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                       	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 �       													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Fr801Tela(	cTitulo,	cAlias1,	cAlias2,	aMyEncho,;
							cLinOk,		cTudOk ,	nOpcE,		nOpcG,;
							cFieldOk,	lVirtual,	nLinhas,	aAltEnchoice,;
							nFreeze,	aButtons )

Local lRet
Local nOpca 	:= 0
Local cSaveMenuh
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
oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudOk,"+MDX_ITEM",.T.,,nFreeze,,nLinhas,cFieldOk)

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca := 1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons),;
AlignObject(oDlg,{oEnchoice:oBox,oGetDados:oBrowse},1,,{110}))

lRet := (nOpca == 1)

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fr801ValCa� Autor �VENDAS CRM          � Data �  04/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para validacao do TudoOK                             ���
�������������������������������������������������������������������������͹��
���Uso       � LOJA801 SIGALOJA                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fr801ValCa(nTipVal)

Local lRet	   := .F.				// Retorno da funcao

If nTipVal == 1
    lRet := Fr801VFm()
ElseIf nTipVal == 2
	lRet := Fr801VFi()
ElseIf nTipVal == 3
	lRet := Fr801VAdm()
ElseIf nTipVal == 4
	lRet := Fr801VPa()
ElseIf nTipVal == 5 
	lRet := Fr801VCod()
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fr801VFm 	� Autor �VENDAS CRM          � Data �  04/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para validacao do TudoOK                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                       	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FRONT LOJA												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Fr801VFm()

Local lRet	   		:= .F.				// Retorno da funcao
Local cMV_LJPGSAD 	:= SuperGetMv("MV_LJPGSAD",,'')

dbSelectArea("SX5")           
dbSetOrder(1)
If SX5->(DbSeek(xFilial("SX5")+"24"+AllTrim(M->MDV_FPG))) 
	If AllTrim(M->MDV_FPG) $ cMV_LJPGSAD
		If Len(acols) > 1 
			Alert(STR0017)//"Para essa forma de pagamento nao existe administradora"
			lRet := .F.
		Else
			lRet := .T.
			oGetDados:Disable()	
		EndIf
	Else
		lRet := .T.
		oGetDados:Enable()	
	EndIf
	
Else
	Alert(STR0018)  // "Forma de pagamento invalida"
	lRet := .F.
EndIf                  


Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fr801VFi 	� Autor �VENDAS CRM          � Data �  04/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para validacao do TudoOK                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                       	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FRONT LOJA												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Fr801VFi()

Local lRet	   := .F.				// Retorno da funcao

If M->MDV_VALINI <=  M->MDV_VALFIM
	lRet := .T.
Else
	Alert(STR0019) //"Valor final, tem que ser maior que o valor inicial"
	lRet := .F.
EndIf                  

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fr801VAdm �Autor  � Autor VENDAS CRM   � Data �  04/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para validacao do TudoOK                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                       	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FRONT LOJA												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Fr801VAdm()

Local lRet	   := .F.				// Retorno da funcao
Local nPosTexto   := aScan(aHeader,{|x| Alltrim( x[2] ) == "MDX_DESADM"})  

dbSelectArea("SAE")           
dbSetOrder(1)

If !Empty(M->MDX_CODADM) .AND. SAE->(DbSeek(xFilial("SAE")+AllTrim(M->MDX_CODADM)))
	
	aCols[n,nPosTexto] 	:= SAE->AE_DESC   
	lRet	   			:= .T.

Else
	
	Alert(STR0020)
	lRet	   := .F.

EndIf                  

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fr801VFi 	� Autor �VENDAS CRM          � Data �  04/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para validacao do TudoOK                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                       	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FRONT LOJA												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Fr801VPa()

Local lRet	   := .F.				// Retorno da funcao
Local nPosTexto   := aScan(aHeader,{|x| Alltrim( x[2] ) == "MDX_NPARC"})  

dbSelectArea("SAE")           
dbSetOrder(1)

If M->MDX_NPARC > 0
	
	lRet	   := .T.

Else

	
	Alert(STR0021) //"Numero de parcelas invalido"
	lRet	   := .F.

EndIf                  

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fr801VCod	� Autor �VENDAS CRM          � Data �  04/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para validacao do TudoOK                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                       	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FRONT LOJA												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Fr801VCod()

Local lRet	   := .T.				// Retorno da funcao

dbSelectArea("MDV")           
dbSetOrder(2)

If nTiopoOp == 3 .and. DbSeek( xFilial( "MDV" ) + M->MDV_CODIGO )
	
	Alert(STR0022) //			"Codigo ja existe"
	lRet	   := .F.

EndIf                  

Return(lRet)
