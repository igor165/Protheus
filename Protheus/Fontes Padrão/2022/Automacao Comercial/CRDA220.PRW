#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRDA220.CH"

Function CRDA220()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o menu da gestao de acervos                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCols 	:= {}													// Campos da GetDados
Private aHeader	:= {}												 	// Array com Cabecalho dos campos
Private aRotina := MenuDef()
					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabe‡alho da tela de atualiza‡oes                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro	:= STR0008 //"Regras de Pontuação"

mBrowse( 6, 1,22,75,"MAS" )

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MenuDef  ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 13.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CRDA220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0001	,"AxPesqui"		,0	,1	,0	,.F.	}	,;	 	//"Pesquisar"
					 	{STR0002	,"Crd220Man"	,0	,2	,0	,.T.	}	,;	 	//"Visualizar"
						{STR0003	,"Crd220Man"	,0	,3	,0	,.T.	}	,;	 	//"Incluir"
						{STR0004	,"Crd220Man"	,0	,4	,0	,.T.	}	,;	 	//"Alterar"
						{STR0005	,"Crd220Man"	,0	,5	,0	,.T.	}	} 	 	//"Excluir"
Return aRotina


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDA220ManºAutor  ³Marcos R. Andrade   º Data ³  29/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para manutencao no cadastro de campanha              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGACRD                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd220Man( cAlias, nReg, nOpc )

Local lProcessa		:= .T.						// Valida se exite o processamento ou nao
Local nSaveSx8		:= GetSx8Len()				// Controle de semaforo
Local aCamposEnc	:= {}						// Relacao dos campos que estao na enchoice para gravacao do
Local nX			:= 0                     	// Contador
Local aRecno		:= {}						// Array com a posicao do Registro
Local lRet			:= .F.						// Variavel de retorno	
Local cOperacao		:= ""						// Opercao clicada pelo usuario (Inclusao, Alteracao,...)

Do Case
	Case nOpc == 2
		cOperacao := STR0002 //"Visualizar"
	Case nOpc == 3
		cOperacao := STR0003 //"Incluir"
	Case nOpc == 4
		cOperacao := STR0004 //"Alterar"
	Case nOpc == 5
		cOperacao := STR0005 //"Excluir"
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se for exclusao e se pode excluir³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 5
	lProcessa := Crd220CanDel()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forca a abertura dos arquivos                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lProcessa
	
	DbSelectArea("MAS")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializacao das variaveis da Enchoice                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory( "MAS", (nOpc==3), (nOpc==3) )
	
	DbSelectArea( "SX3" )
	SX3->(DbSetOrder(1))	// X3_ARQUIVO+X3_ORDEM
	SX3->(DbSeek( "MAS" ))
	While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "MAS"
		If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
			aAdd( aCamposEnc, SX3->X3_CAMPO )
		Endif
		SX3->(DbSkip())
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aHeader e aCols da GetDados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsado	:=0
	DbSelectArea("SX3")
	SX3->(DbSeek("MAT"))
	aHeader	:={}
	
	While !SX3->(Eof()) .AND. (X3_ARQUIVO == "MAT" )
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
		SX3->(DbSkip())
	End
	
	aCols:={}
	DbSelectArea("MAT")
	MAT->(DbSetOrder(1))
	nUsado	:= Len( aHeader )
	
	If !INCLUI
		If MAT->(DbSeek( xFilial( "MAT" ) + M->MAS_CODCAM ))
			
			While 	!MAT->(EOF())							.AND.;
					MAT->MAT_FILIAL == xFilial( "MAT" ) 	.AND.;
					MAT->MAT_CODCAM == M->MAS_CODCAM
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Nao acrescenta recno caso for copia³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AAdd( aCols, Array( nUsado + 1 ) )
				AAdd( aRecno, MAT->( Recno() ) )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acrescenta acols de regras³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 To nUsado
					If ( aHeader[nX][10] <>  "V" )
						aCols[Len( aCols )][nX] := MAT->( FieldGet( FieldPos( aHeader[nX][2] ) ) )
					Else
						aCols[Len( aCols )][nX] := CriaVar( aHeader[nX][2], .T. )
					Endif
				Next nX
				
				aCols[Len( aCols )][ nUsado + 1 ] := .F.
				
				MAT->( DbSkip() )
			End
		Endif
		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se for uma inclusao inicializa o acols     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aCols, Array( nUsado + 1 ) )
		For nX := 1 To nUsado
			If AllTrim( aHeader[ nX][2] ) == "MAT_ITEM"
				aCols[Len( aCols )][nX] := StrZero( 1, Len( MAT->MAT_ITEM ) )
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
		cTitulo			:= STR0008 + " - " + cOperacao // Regras de pontuacao
		cLinOk			:= "CRD220LOK()"
		cTudOk			:= "CRD220TOK()"
		cFieldOk		:= "AllwaysTrue()"
		lRet 			:=CRD220Tela(	cTitulo,	"MAS",	"MAT",	aCamposEnc,;
										cLinOk,		cTudOk,	nOpc,	nOpc,;
										cFieldOk )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executar processamento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chama a funcao de gravacao - PONTOS DA CAMPANHA                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lGravou := Crd220Grv(	nOpc,	aCamposEnc, aHeader, aCols,;
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
			
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Controle do semaforo                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While (GetSx8Len() > nSaveSx8)
				RollBackSx8()
			End
		Endif
	Endif
Else
	Help(" ",1,"NODELETA")
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Crd220Grv ³ Autor ³ Henry Fila            ³ Data ³ 17/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Gravacao da campanha                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Crd220Grv                                                     ³±±
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
Static Function Crd220Grv(	nOpc,		aCamposEnc, 	aHeader,	aCols,;
							aRecno )

Local aArea     := GetArea()						// Salva a area atual
Local bCampo 	:= {|nCPO| Field(nCPO) }    		// Nome do campo	
Local cItem     := Repl("0",Len( MAT->MAT_ITEM ))	// Numero do Item
Local nX        := 0								// Contador 
Local nField    := 0								// Contador
Local nLinha    := 0								// Contador de linhas do Acols
Local nPos		:= 0								// Posicao do campo MAT_VALOR
Local lTravou   := .F.								// Flag para garantir o lock de registro

DbSelectArea( "MAS" )
DbSelectArea( "MAT" )

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
		MAS->(DbSetOrder(1))
		If MAS->(DbSeek( xFilial( "MAS" ) + M->MAS_CODCAM ))
			RecLock("MAS",.F.)
		Else
			RecLock("MAS",.T.)
		Endif       
		        
		For nField := 1 To MAS->( FCount() )	  				
  			FieldPut(nField, M->&(EVAL( bCampo, nField ) ) )
		Next nField       
		
		Replace MAS->MAS_FILIAL With xFilial("MAS")                         
		
		MAS->(MsUnLock())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os dados  do MAT (Pontos da Campanha) - itens do cadastro ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		bCampo := {|nCPO| Field(nCPO) }
		
		For nX := 1 To Len( aCols )
			
			// Flag para garantir o lock de registro
			lTravou := .F.
			
			// Se a linha atual for menor que o total de registros
			If nX <= Len( aRecNo )
				DbSelectArea( "MAT" )
				MAT->(DbGoTo( aRecNo[nX] ))
				RecLock("MAT",.F.)
				
				// Lock do regsitro que sera alterado
				lTravou := .T.
			Endif
			
			// Se a linha atual nao foi DELETADA
			If ( !aCols[nX][nUsado+1] )

				//Se nao fez o LOCK significa que e uma nova Linha
				If !lTravou
					RecLock("MAT",.T.)
				Endif

				cItem := Soma1(cItem,Len(MAT->MAT_ITEM))
				Replace MAT->MAT_FILIAL With xFilial("MAT")
				Replace MAT->MAT_CODCAM With MAS->MAS_CODCAM
				Replace MAT->MAT_ITEM   With cItem
				
				bCampo := {|nCPO| Field(nCPO) }
					
				For nLinha := 1 To MAT->(FCount())
				
					If !(EVAL(bCampo,nLinha) == "MAT_FILIAL") 
						nPos:= Ascan(aHeader,{|x| ALLTRIM(EVAL(bCampo,nLinha)) == ALLTRIM(x[2])})
						If (nPos > 0)
							If (aHeader[nPos][10] <> "V" .AND. aHeader[nPos][08] <> "M")
								Replace MAT->&(EVAL(bCampo,nLinha)) With aCols[nX][nPos]
							Endif
						Endif
					Endif
						
				Next nLinha
				
				lGravou := .T.
			Else
				If lTravou
					RecLock("MAT",.F.)
					MAT->(DbDelete())
				Endif
			Endif
			MAT->(MsUnLock())
			
		Next nX
		
	END TRANSACTION
	
ElseIf !nOpc == 2
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deleta MAT (Pontos da Campanha)            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MAT")
	MAT->(DbSetOrder(1))
	If MAT->(DbSeek(xFilial("MAT")+M->MAS_CODCAM))
		RecLock("MAT",.F.)
		MAT->(DbDelete())
		MAT->(MsUnlock())
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deleta MAS (Campanha)                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MAS")
	RecLock("MAS", .F.)
	MAS->(DbDelete())
	MAS->(MsUnlock())

Endif

RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CRD220CanDel³ Autor ³Marcos R. Andrade    ³ Data ³30.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da exclusao da Campanha                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanha de Fidelizacao             					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Crd220CanDel()

Local lRet 		:= .T.						// Retorno da funcao
Local cAliasMAX	:= "MAX"					// Alias da relacao pontos x campanha x cliente
Local aArea		:= GetArea()				// Salva area

#IFDEF TOP
	Local cQuery	:= ""
	Local lQuery	:= .F.
#ENDIF

#IFDEF TOP
	
	lQuery := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se tem algum registro na tabela MAX (Cliente X Total de pontos da campanha)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cAliasMAX := "QRYMAX"
	
	cQuery := "SELECT COUNT(*) QTDMAX "
	cQuery += " FROM "
	cQuery += RetSqlName("MAX")+ " MAX "
	cQuery += " WHERE "
	
	cQuery += "MAX_FILIAL = '" + xFilial( "MAX" ) +"' AND "
	cQuery += "MAX_CODCAM = '" + MAS->MAS_CODCAM +"' AND "
	cQuery += "MAX.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasMAX,.F.,.T.)
	
	If (cAliasMAX)->QTDMAX > 0
		lRet := .F.
	Endif
	
	DbCloseArea()
	
	DbSelectArea("MAS")
	
#ELSE
	cAliasMAX := "MAX"
	DbSelectArea( "MAX" )
	DbSetOrder( 2 )
	
	If MAX->( DbSeek(xFilial("MAX")+ MAS->MAS_CODCAM ) )
		lRet := .F.
	Endif
	
#ENDIF

RestArea( aArea )

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDProcCam ºAutor  ³Marcos Roberto Andradeº Data ³ 30/11/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe alguma campanha ativa.                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA220                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÑÍÏÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  DATA  ³ BOPS ³Program.³ ALTERACAO                                    º±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±º        ³      ³        ³                                              º±±
±±º        ³      ³        ³                                              º±±
±±º        ³      ³        ³                                              º±±
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRD220ProcCam()
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local cAliasMAS	:= "MAS"

#IFDEF TOP
	Local cQuery	:= ""
	Local lQuery	:= .F.
#ELSE
	Local cIndMAS	:= ""
	Local cKey		:= ""
	Local nIndMAS	:= 0
#ENDIF

#IFDEF TOP
	
	lQuery := .T.
	
	cAliasMAS := "QRYMAS"
	
	cQuery := "SELECT COUNT(*) QTDMAS "
	cQuery += " FROM "
	cQuery += RetSqlName("MAS")+ " MAS "
	cQuery += " WHERE "
	
	cQuery += "MAS_FILIAL = '" + xFilial( "MAS" ) +"' AND "
	cQuery += "MAS_CODCAM <> '" + M->MAS_CODCAM + "' AND "
	cQuery += "MAS_STATUS = '1'  AND "
	cQuery += "MAS.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasMAS,.F.,.T.)
	
	If (cAliasMAS)->QTDMAS > 0
		lRet := .F.
	Endif
	
	DbCloseArea()
	
	DbSelectArea("MAS")
	
#ELSE
	cAliasMAS := "MAS"
	DbSelectArea( "MAS" )
	DbSetOrder( 1 )
	cIndMAS := CriaTrab( NIL, .F.)
	
	cKey      := "MAS_FILIAL+MAS_STATUS"
	
	IndRegua( "MAS", cIndMAS, cKey)
	nIndMAS := RetIndex( "MAS" )
	DbSetIndex( cIndMAS + OrDbagExT() )
	DbSetOrder( nIndMAS + 1 )
	
	If MAS->( DbSeek(xFilial("MAS")+'1' ) )
		If MAS->MAS_CODCAM <> M->MAS_CODCAM
			lRet := .F.
		EndIf
	Endif
	
	DbSelectArea("MAS")
	DbClearFilter()
	RetIndex("MAS")
	Ferase(cIndMAS+OrDbagExt())
	
#ENDIF

If !lRet
	Aviso(STR0006, STR0007, {STR0009 } )  // Para ativar esta campanha será necessário inativar a campanha que esta ativa no momento, OK
EndIf


RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRD220LOK ºAutor  ³Hanna C. Inglez     º Data ³  27/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para validacao do linkok. Valida se o valor foi      º±±
±±º          ³preenchido.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRD220LOK()
Local lRet	:= .F.		// Retorno da funcao

If !aCols[n,Len(aHeader)+1]
	If 	(aScan(aHeader,{|x| Alltrim( x[2] ) == "MAT_VALOR"}) ) 	>  0 	.Or.;
		(aScan(aHeader,{|x| Alltrim( x[2] ) == "MAT_PRODUTO"}) ) 	<> "" 	.Or.;
		(aScan(aHeader,{|x| Alltrim( x[2] ) == "MAT_GRUPO"}) ) 	<> ""
		
		lRet	:= .T.
	Endif
Else
	lRet := .T.
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRD220TOK ºAutor  ³Hanna C. Inglez     º Data ³  27/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para validacao do TudoOK. Valida se o valor foi      º±±
±±º          ³preenchido.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRD220TOK()
Local lRet	:= .F.				// Retorno da funcao
If !Empty( M->MAS_PONTOS )
	lRet	:= .T.
Endif
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Modelo3	  ³ Autor ³ Wilson				³ Data ³ 17/03/97 ³±±
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
Static Function CRD220Tela(	cTitulo,	cAlias1,	cAlias2,	aMyEncho,;
							cLinOk,		cTudoOk,	nOpcE,		nOpcG,;
							cFieldOk,	lVirtual,	nLinhas,	aAltEnchoice,;
							nFreeze,	aButtons )

Local lRet
Local nOpca 	 := 0
Local nReg		 :=(cAlias1)->(Recno())
Local oDlg
Local oEnchoice
Local aSize      := MsAdvSize( .T., .F., 400 )		// Size da Dialog
Local aObjects   := {} 
Local aInfo      := {}
Local aPosObj    := {}

Private aTELA:=Array(0,0)
Private aGets:=Array(0)
Private bCampo:={|nCPO|Field(nCPO)}

nOpcE := If(nOpcE==Nil,3,nOpcE)
nOpcG := If(nOpcG==Nil,3,nOpcG)
lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas:=Iif(nLinhas==Nil,99,nLinhas)
	
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
oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"+MAT_ITEM",.T.,,nFreeze,,nLinhas,cFieldOk)

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons),;
AlignObject(oDlg,{oEnchoice:oBox,oGetDados:oBrowse},1,,{110}))

lRet:=(nOpca==1)
Return lRet
