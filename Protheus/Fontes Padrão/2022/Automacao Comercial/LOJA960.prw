#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA960.CH"

Function LOJA960()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o menu da gestao de acervos                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCols 	:= {}													// Campos da GetDados
PRIVATE aHeader	:= {}												 	// Array com Cabecalho dos campos
Private aRotina := {	{  	STR0001   ,	"AxPesqui", 	0 , 1},;	 	//"Pesquisar"
						{ 	STR0002   ,	"Lj960Main", 	0 , 2},;	 	//"Visualizar"
						{ 	STR0003   ,	"Lj960Main", 	0 , 3},;	 	//"Incluir"
						{ 	STR0004   ,	"Lj960Main", 	0 , 4},;	 	//"Alterar"
						{ 	STR0005   ,	"Lj960Main", 	0 , 5}} 	 	//"Excluir"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabe‡alho da tela de atualiza‡oes                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro	:= STR0006	//"Cadastro de Menus de Produtos"
mBrowse( 6, 1,22,75,"SL7" )

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj960Main ºAutor  ³Thiago Honorato     º Data ³  04/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para manutencao no cadastro de botoes dos produtos   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA Interface TOUCHSCREEN                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj960Main( cAlias, nReg, nOpc )

Local nSaveSx8		:= GetSx8Len()				// Controle de semaforo
Local aCamposEnc	:= {}						// Relacao dos campos que estao na enchoice para gravacao do
Local nX			:= 0                     	// Contador
Local aRecno		:= {}						// Array com a posicao do Registro
Local lRet			:= .F.						// Variavel de retorno
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forca a abertura dos arquivos                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SL7")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializacao das variaveis da Enchoice                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nao acrescenta recno caso for copia³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCols, Array( nUsado + 1 ) )
			AAdd( aRecno, SL8->( Recno() ) )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acrescenta acols ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for uma inclusao inicializa o acols     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo			:= STR0007	//"Menus de Produtos"
	cLinOk			:= "LJ960LOK()"
	cTudOk			:= "LJ960TOK()"
	cFieldOk		:= "AllwaysTrue()"
	lRet 			:= LJ960Tela(	cTitulo,	"SL7",	"SL8",	aCamposEnc,;
									cLinOk ,   cTudOk,	 nOpc,	nOpc      ,;
									cFieldOk )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executar processamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a funcao de gravacao - Botoes para os produtos                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc <> 2 // 2 = Visualizacao
			lGravou := LJ960Grv( nOpc,	aCamposEnc, aHeader, aCols,;
 								 aRecno )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Controle do semaforo                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle do semaforo                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While (GetSx8Len() > nSaveSx8)
			RollBackSx8()
		End
	Endif
Endif

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LJ960Grv  ³ Autor ³ Thiago Honorato       ³ Data ³ 17/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Gravacao                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Opcao da Gravacao sendo:                               ³±±
±±³          ³       [1] Inclusao                                           ³±±
±±³          ³       [2] Alteracao                                          ³±±
±±³          ³       [3] Exclusao                                           ³±±
±±³          ³ExpA2: Array de registros                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Pesquisa e Resultado                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se  for INCLUSAO ou ALTERACAO  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nOpc == 3 ) .OR. ( nOpc == 4)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava a pesquisa e as regras da pesquisa                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN TRANSACTION
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava os dados da Campanha³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava os dados  do SL8 (Itens do Menu)                    	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deleta SL8                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SL8")
	DbSetOrder(1)
	If DbSeek(xFilial("SL8")+M->L7_CODIGO)
		While !SL8->(EOF()) .AND. DbSeek(xFilial("SL8")+M->L7_CODIGO)
			RecLock("SL8",.F.)
			DbDelete()
			MsUnlock()
		End
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deleta SL7                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SL7")
	RecLock("SL7", .F.)
	DbDelete()
	MsUnlock()
	
Endif

RestArea(aArea)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ960LOK  ºAutor  ³Thiago Honorato     º Data ³  04/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para validacao do linkok. Valida se o valor foi      º±±
±±º          ³preenchido.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA960 - SIGALOJA                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
				MsgStop( STR0017 + CHR(10) + ;		//"O final do texto não pode conter quebra de linha."  
						 STR0018 )					//"Verifique o conteúdo da coluna Texto botão!"
				lRet := .F.
			Else	
				// verifica se o caracter '+' aparece mais de duas vezes dentro de uma string.
				For nCount := 1 to Len(aCols[n,nPosTexto])
					If SubStr(aCols[n,nPosTexto],nCount,1) == '+'
						nMais ++					
					Endif
                    If nMais > 2
						MsgStop( STR0019 + CHR(10) + ;		//"Quantidade de quebra de linhas inválido(máximo 3 linhas)." 
								 STR0018 )					//"Verifique o conteúdo da coluna Texto botão!"
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
		MsgStop(STR0010)		//"Verifique se o campo Item está preenchido"		
		lRet	:= .F.
	Endif
    //Verificando se o grupo escolhido esta' ATIVO      
    If lRet
	    If !Empty(aCols[n,nPosGrup])
			DbSelectArea("SL7")
			DbSetOrder(1)
			If DbSeek(xFilial("SL7") + aCols[n,nPosGrup] )
				If SL7->L7_ATIVO == "2"
					MsgStop(STR0011 + aCols[n,nPosGrup] + STR0012)	//"O grupo " + ##### + " não está Ativo!"
					lRet := .F.
				Endif
			Else
				MsgStop(STR0011 + aCols[n,nPosGrup] + STR0013)	//"O grupo " + ##### + 	" não está cadastrado!"
				lRet := .F.				
			Endif
		Endif	
    Endif 
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ960TOK 	ºAutor  ³Thiago Honorato     º Data ³  04/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para validacao do TudoOK                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA960 SIGALOJA                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³LJ960Tela	  ³ Autor ³ Thiago Honorato     ³ Data ³ 04/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Enchoice e GetDados									  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lRet:=Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk, 	  ³±±
±±³			 ³ cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice)³±±
±±³			 ³lRet=Retorno .T. Confirma / .F. Abandona					  ³±±
±±³			 ³cTitulo=Titulo da Janela 									  ³±±
±±³			 ³cAlias1=Alias da Enchoice									  ³±±
±±³			 ³cAlias2=Alias da GetDados									  ³±±
±±³			 ³aMyEncho=Array com campos da Enchoice						  ³±±
±±³			 ³cLinOk=LinOk 												  ³±±
±±³			 ³cTudOk=TudOk 												  ³±±
±±³			 ³nOpcE=nOpc da Enchoice									  ³±±
±±³			 ³nOpcG=nOpc da GetDados									  ³±±
±±³			 ³cFieldOk=validacao para todos os campos da GetDados 		  ³±±
±±³			 ³lVirtual=Permite visualizar campos virtuais na enchoice	  ³±±
±±³			 ³nLinhas=Numero Maximo de linhas na getdados				  ³±±
±±³			 ³aAltEnchoice=Array com campos da Enchoice Alteraveis		  ³±±
±±³			 ³nFreeze=Congelamento das colunas.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³RdMake 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Divide a tela horizontalmente para os objetos enchoice e getdados   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aObjects := {}

AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo       := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj     := MsObjSize( aInfo, aObjects,  , .F. )


DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 TO aSize[6],aSize[5] PIXEL OF oMainWnd //"Configura‡„o"

oEnchoice := Msmget():New(cAlias1,nReg,nOpcE,,,,aMyEncho, aPosObj[1], aAltEnchoice,3,,,,,,lVirtual,,,,,,,,.T.)
oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudOk,"+L8_ITEM",.T.,,nFreeze,,nLinhas,cFieldOk)

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca := 1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons),;
AlignObject(oDlg,{oEnchoice:oBox,oGetDados:oBrowse},1,,{110}))

lRet := (nOpca == 1)
Return lRet

