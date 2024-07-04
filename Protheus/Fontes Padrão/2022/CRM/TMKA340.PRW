#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA340.CH"
#INCLUDE "CRMDEF.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA340   ºAutor  ³Vendas CRM          º Data ³  04/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualizacao do Cadastro de eventos para Marketing           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 Call Center                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmka340( cFilDef, aAddFil, xAutoCab, xAutoItens, nOpcAuto )

Local oMBrowse 		:= Nil
Local oTableAtt		:= Nil
Local nX        	:= 0
Local lRet			:= .F.

Private aRotina 	:= MenuDef()
Private l340Auto  	:= (xAutoCab <> NIL  .AND. xAutoItens <> NIL)
Private aAutoCab   	:= {}
Private aAutoItens 	:= {}

Default cFilDef 	:= ""
Default aAddFil 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := STR0001//Cadastro de Eventos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se e rotina automatica                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l340Auto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida array com os dados do cabecalho                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAutoCab := ACD->(MSArrayXDb(xAutoCab,,nOpcAuto))
	If ( Len(aAutoCab) == 0 )
		Return(lRet)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a validacao dos itens.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(xAutoItens)
		AAdd(aAutoItens,ACE->(MSArrayXDb(xAutoItens[nX],,nOpcAuto,.T.)))
		If Empty(aAutoItens[nX])
			Return(lRet)
		Endif
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a opcao desejada do menu solicitada via rotina automatica      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MBrowseAuto(nOpcAuto,aAutoCab,"ACD")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("ACD")			
	oMBrowse:SetDescription( STR0001 )		// "Cadastro de Eventos"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtro Default do Browse                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( cFilDef )
		oMBrowse:SetFilterDefault( cFilDef )
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtros adicionais do Browse                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len( aAddFil )
		oMBrowse:DeleteFilter( aAddFil[nX][ADDFIL_ID] )
		oMBrowse:AddFilter( aAddFil[nX][ADDFIL_TITULO], ;
							aAddFil[nX][ADDFIL_EXPR], ;
							aAddFil[nX][ADDFIL_NOCHECK], ;
							aAddFil[nX][ADDFIL_SELECTED], ; 
							aAddFil[nX][ADDFIL_ALIAS], ;
							aAddFil[nX][ADDFIL_FILASK], ;
							aAddFil[nX][ADDFIL_FILPARSER], ;
							aAddFil[nX][ADDFIL_ID] )		 
		oMBrowse:ExecuteFilter()	
	Next nX		
		
	oMBrowse:SetAttach( .T. )
	oTableAtt := TableAttDef()
	oMBrowse:SetViewsDefault( oTableAtt:aViews ) 

	oMBrowse:SetTotalDefault('ACD_CODIGO','COUNT',STR0049) //'Total de Registros'

	// se for diferente do modulo CRM, então abre o browse com o grafico fechado
	If nModulo <> 73
		oMBrowse:SetOpenChart( .F. )
	EndIf


	oMBrowse:Activate()
Endif

Return (.T.)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef

Cria as visões e gráficos padrão.

@sample	TableAttDef()

@param		Nenhum

@return	ExpA - Array de Objetos com as Visoes e Gráficos.

@author	Aline Kokumai
@since		02/05/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oTableAtt	:= FWTableAtt():New()
//Visões
Local oAtivos		:= Nil // Eventos Ativos
Local oInativos	:= Nil // Eventos Inativos

// Eventos Ativos 
oAtivos := FWDSView():New()
oAtivos:SetName(STR0047) //"Eventos Ativos"
oAtivos:SetID("Ativos") 
oAtivos:SetOrder(1) // ACD_FILIAL+ACD_CODIGO
oAtivos:SetCollumns({"ACD_CODIGO","ACD_DESC","ACD_TEMA","ACD_LOCAL","ACD_END",;
						"ACD_MUN","ACD_BAIRRO","ACD_EST","ACD_TEL","ACD_EMAIL"})
oAtivos:SetPublic( .T. )
oAtivos:AddFilter(STR0047, "ACD_MSBLQL == '2'") //"Eventos Ativos"
oTableAtt:AddView(oAtivos)

// Eventos Inativos
oInativos := FWDSView():New()
oInativos:SetName(STR0048) //"Eventos Inativos"
oInativos:SetID("Inativos") 
oInativos:SetOrder(1) // ACD_FILIAL+ACD_CODIGO
oInativos:SetCollumns({"ACD_CODIGO","ACD_DESC","ACD_TEMA","ACD_LOCAL","ACD_END",;
						"ACD_MUN","ACD_BAIRRO","ACD_EST","ACD_TEL","ACD_EMAIL"})
oInativos:SetPublic( .T. )
oInativos:AddFilter(STR0048, "ACD_MSBLQL == '1'") //"Eventos Inativos"
oTableAtt:AddView(oInativos)

oTableAtt:SetAlias("ACD")

Return (oTableAtt)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³Vendas CRM             ³ Data ³11/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina:= {}

AAdd(aRotina,{ STR0002 ,"AxPesqui"     , 0 , 1 , , .F.})	//"Pesquisar"
AAdd(aRotina,{ STR0003 ,"Tk340Eventos" , 0 , 2 , , .T.})	//"Visualizar"
AAdd(aRotina,{ STR0004 ,"Tk340Eventos" , 0 , 3 , , .T.})	//"Incluir"
AAdd(aRotina,{ STR0005 ,"Tk340Eventos" , 0 , 4 , , .T.})	//"Alterar"
AAdd(aRotina,{ STR0006 ,"Tk340Eventos" , 0 , 5 , , .T.})	//"Excluir"

If Select("SX2") > 0
	SX2->( dbSetOrder(1) )
	If SX2->( DbSeek( "AG5" ) )
		AAdd(aRotina,{ STR0025,"Tk340Eventos" , 0 , 6 , , .T.})//"Lista de Presenca"
	EndIf
EndIf

If nModulo == 73
	AAdd(aRotina,{ STR0046 ,"CRMA200('ACD')"    , 0 , 8 , , .T.})	//"Privilégios"
EndIf

aRotina := CRMXINCROT( "ACD", aRotina )

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK340Eventos ºAutor  ³Vendas CRM       º Data ³  04/12/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Janela Pincipal do Sistema                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1: Alias do cadastro.                                  º±±
±±º          ³ ExpN1: Registro posicionado.                               º±±
±±º          ³ ExpC1: Opcao de menu.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKA340                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk340Eventos(cAlias,nReg,nOpc)

Local   aAC			:= { STR0007,STR0008 }		//"Abandona","Confirma"
Local   oEnchoice	:= Nil
Local   oDlg		:= Nil
Local   oGet		:= Nil
Local   aCampos		:= {}						//Array com os campos do aHeader
Local   aSize		:= MsAdvSize(.T.,.F.,400)	//Array com as dimensoes da tela
Local   aInfo		:= {}						//Array temporario para a criacao dos objetos da tela
Local   aObjects	:= {}						//Array temporario para a criacao dos objetos da tela
Local   aPosObj		:= {}						//Array com as posicoes dos objetos da tela
Local 	nY			:= 0
Local 	nX			:= 0                        //Variavel For - inserido por carlos queiroz em 19/07/08
Local 	nCntFor		:= 0                        //Variavel For - inserido por carlos queiroz em 19/07/08
Local	nSelecao	:= 0						//Opcao selecionada pelo operador (OK,Cancel)
Local 	nSaveSx8	:= GetSX8Len()				//Funcao de numeracao
Local 	cCodigo		:= ""  						//Campo responsavel por armazenar o codigo do evento - inserido por carlos queiroz em 19/07/08
Local   nQtdEve		:= 1

Private aPosicoes	:= {}						//Posicionamento dos campos no aCols. Private devido a funcao de validacao da linha.
Private aTela		:= {}
Private aGets		:= {}

Private aHeader		:= {}
Private aHeader2	:= {} // Array contendo a estrutura da tabela AG5 no sx3 - inserido por carlos queiroz em 19/07/08

Private nUsado		:= 0
Private nUsado2		:= 0  // Campo responsavel por armazenar a quantidade de campos no aHeader - inserido por carlos queiroz em 19/07/08

Private aCols		:= {}
Private aCols2		:= {} // Array utilizado para armazenar os dados da getdados Lista de Presenca - inserido por carlos queiroz em 19/07/08

Private aTmpAcols2	:= {} // Array responsavel por relacionar o(s) item(ns) da primeira getdados com a segunda getdados - inserido por carlos queiroz em 19/07/08

Private nOpcx      := nOpc  // Campo que armazena a opcao selecionada no aRotina - inserido por carlos queiroz em 19/07/08
Private _nLinGet1  := 1		// Campo responsavel por armazenar o item posicionado na primeira getdados e efetuar a gravacao no aTmpAcols2
//Private nPosOcupac := 0

Private oGet1	   := Nil	 // Objeto GetDados 1 a ser criado no botao Lista de Presenca
Private oGet2	   := Nil 	 // Objeto GetDados 2 a ser criado no botao Lista de Presenca

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso a opcao seja o botao Lista de Presenca, ³
//³a enchoice e a primeira getdados sera visual.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpcx == 6)
	Private lGrvACE := .F.	//Variável utilizada para informar se será efetuado a gravação, dos campos ACE_OCUPAC e ACE_STATUS.
	nOpc := 2
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza as variaveis de memoria para os campos do CABECALHO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 3)
	RegToMemory("ACD",.T.)
Else
	RegToMemory("ACD",.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Na inclusao -> cria uma matriz acols em branco para a getdados dos ITENS          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols := {}
aCols2 := {}

//ÚÄÄÄÄÄÄÄÄ¿
//³Inclusao³
//ÀÄÄÄÄÄÄÄÄÙ
If nOpc == 3
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem aHeader, aCols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aNoFields := {	"ACE_CODIGO"	}
	
	If Len(aHeader) == 0 .AND. Len(aCols) == 0
		FillGetDados(	nOpc			,"ACE"		,1				,/*cSeek*/		,;
						/*{||cWhile}*/	,{|| .T. }	,aNoFields		,/*aYesFields*/	,; 
						/*lOnlyYes*/	,/*cQuery*/	,/*bMontCols*/	,.T.			)
	EndIf
	
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem aHeader, aCols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeek	:= xFilial("ACE")+M->ACD_CODIGO
	cWhile	:= "ACE->ACE_FILIAL+ACE->ACE_CODIGO"
	aNoFields := {	"ACE_CODIGO"	}
	
	If Len(aHeader) == 0 .AND. Len(aCols) == 0
		FillGetDados(	nOpc			,"ACE"			,1				,cSeek				,;
		  				{|| &cWhile }	,{|| .T. }		,aNoFields		,/*aYesFields*/		,; 
						/*lOnlyYes*/	,/*cQuery*/		,/*bMontCols*/	,/*lEmpty*/			,;
						/*aHeaderAux*/	,/*aColsAux*/	,/*bAfterCols*/	,/*bBeforeCols*/	)		
	EndIf
	
EndIf

nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os ITENS no array para que n„o	haja conflito na ordem dos campos no SX3  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aPosicoes,{"ACE_GRADE"		,GdFieldPos("ACE_GRADE"	)})	 	//1
AADD(aPosicoes,{"ACE_TEMA"		,GdFieldPos("ACE_TEMA"	)})	 	//2
AADD(aPosicoes,{"ACE_HRINI"		,GdFieldPos("ACE_HRINI"	)})	 	//3
AADD(aPosicoes,{"ACE_HRFIM"		,GdFieldPos("ACE_HRFIM"	)})	 	//4
AADD(aPosicoes,{"ACE_DATA"		,GdFieldPos("ACE_DATA"	)})	 	//5
AADD(aPosicoes,{"ACE_SALA"		,GdFieldPos("ACE_SALA"	)})	 	//6
AADD(aPosicoes,{"ACE_PALEST"	,GdFieldPos("ACE_PALEST")}) 	//7
AADD(aPosicoes,{"ACE_EMP"		,GdFieldPos("ACE_EMP "	)})	  	//8
AADD(aPosicoes,{"ACE_OCUPAC"	,GdFieldPos("ACE_OCUPAC")})	  	//9

DbSelectarea("ACD")

// Montagem do aHeader AG5 - inserido por carlos queiroz em 19/07/08
If (nOpcx == 6) .And. !(Type("l340Auto") <> "U" .And. l340Auto)
	
	Aadd(aHeader2,{"",	"XLEGENDA","@BMP",10,0,"","","C","",""}) // criacao do mark no aHeader para utilizacao na getdados.
	
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AG5")
	While ( !Eof() .And. SX3->X3_ARQUIVO == "AG5" )
		If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL) .And. !Eof()
			aAdd(aHeader2,{AllTrim(X3Titulo()),;
			AllTrim(SX3->X3_CAMPO),;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_F3,;
			SX3->X3_CONTEXT})
		EndIf
		dbSkip()
	EndDo
	
	nUsado2 := Len(aHeader2) // armazena a quantidade de campos no aHeader
	
	cCodigo := M->ACD_CODIGO // armazena o codigo do evento
	
	dbselectarea("ACE")
	dbsetorder(1)   
	
	If dbseek(xFilial("ACE")+cCodigo) // seek para localizacao do codigo do evento na tabela de grade de eventos

		dbselectarea("AG5")
		dbsetorder(2)		

		While ACE->(!Eof()) .And. ACD->ACD_FILIAL = xFilial("ACE") .And. ACD->ACD_CODIGO == ACE->ACE_CODIGO

			//Seek para pesquisa na tabela AG5 consistindo evento e grade
			If AG5->(dbseek(xFilial("AG5")+M->ACD_CODIGO+ACE->ACE_GRADE))

				While AG5->(!Eof()) .And. ACD->ACD_FILIAL == xFilial("ACD") .And.;
					Alltrim(cCodigo) == Alltrim(AG5->AG5_EVENT) .And. Alltrim(ACE->ACE_GRADE) == Alltrim(AG5->AG5_GRADE)
					
						aAdd(aCols2,Array(Len(aHeader2)+1))
						
						For nCntFor	:= 2 To Len(aHeader2)
							
							If ( aHeader2[nCntFor][10] != "V" )
								
								If aHeader2[nCntFor][2] == "AG5_PRESE"
									If FieldGet(FieldPos(aHeader2[nCntFor][2])) == "1" // se o campo Presente(s/n) igual a 'Sim', marca o campo com 'x'
										aCols2[Len(aCols2)][1] := "LBOK"
									Else
										aCols2[Len(aCols2)][1] := "LBNO"
									EndIf
								EndIf
								
								aCols2[Len(aCols2)][nCntFor] := AG5->(FieldGet(FieldPos(aHeader2[nCntFor][2])))
							Else
								aCols2[Len(aCols2)][nCntFor] := CriaVar(aHeader2[nCntFor][2],.T.) // cria campo com conteudo vazio ou de acordo com o inicializador padrao
							EndIf 
							
						Next nCntFor
						
						aCols2[Len(aCols2), Len(aHeader2)+1] := .F.

					AG5->(dbSkip())
					
				EndDo
			
			EndIf
            
			If Len(aCols2) > 0
				Aadd(aTmpAcols2, aClone(aCols2))
			Else
				//Se o aCols estiver vazio, insere uma linha em branco
				aAdd(aCols2,Array(Len(aHeader2)+1))
				aCols2[1,1] := "LBNO"
			
				For nX := 2 To Len(aHeader2)
					aCols2[1, nX] := CriaVar(aHeader2[nX, 2])
				Next nX
			
				aCols2[Len(aCols2), Len(aHeader2)+1] := .F.
				Aadd(aTmpAcols2, aClone(aCols2))
			EndIf
			
			aCols2 := {}
			ACE->(dbSkip())

		EndDo
	
	EndIf

	For nQtdEve := 1 to Len(Acols)
		If Len(aTmpAcols2) < Len(Acols)
			Aadd(aTmpAcols2, aClone(aTmpAcols2[Len(aTmpAcols2)]))      
		EndIf
		aTmpAcols2[nQtdEve][1][GDFieldPos("AG5_GRADE", aHeader2)]:=Acols[nQtdEve][1] 			      	
	Next nQtdEve
	
	
	aCols2 := aClone(aTmpAcols2[1])
	
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula as dimensoes da enchoiece e getdados                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aObjects := {}

AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

If (nOpcx == 6) .And. !(Type("l340Auto") <> "U" .And. l340Auto)// Utilizado para dimensionar a segunda getdados na interface - inserido por carlos queiroz em 19/07/08
	AAdd( aObjects, { 100, 100, .T., .T. } )
EndIf

aInfo       := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj     := MsObjSize( aInfo, aObjects,  , .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao da tela.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(Type("l340Auto") <> "U" .And. l340Auto)
	If Type("cCadastro") != "U"
		Do Case
			Case nOpc == 3
				cCadastro := STR0001 + " - INCLUIR"
			Case nOpc == 4
				cCadastro := STR0001 + " - ALTERAR"
			Case nOpc == 2
				cCadastro := STR0001 + " - VISUALIZAR"
			Case nOpc == 5
				cCadastro := STR0001 + " - EXCLUIR"
		EndCase
	EndIf
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM  aSize[7], 0 TO aSize[6],aSize[5]  PIXEL OF oMainWnd //Cadastro de Eventos

	Zero()

	oEnchoice:= MsMGet():New("ACD", nReg, nOpc, aAC,"AC",STR0009,,aPosObj[1],,,,,,,,.T.,.F.,"aTela",.T.) 	//"Quanto a exclusao ?"

	If nOpcx <> 6
		oGet:= MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"Tk340LinOk()","Tk340TudOk()","",.T.)
	Else
		oGet1 := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],2,"Tk340LinOk()","AlwaysTrue",,,,/*9999*/,,,,,aHeader,aCols)
	EndIf

	If (nOpcx == 6) // tratamento utilizado para o botao Lista de Presenca - inserido crmpor carlos queiroz em 19/07/08
		oGet1:lDelete := .F. // desabilita a delecao na getdados 1
		oGet1:lUPDATE := .F. // desabilita a edicao na getdados 1
		oGet2 := MsNewGetDados():New(aPosObj[3,1],aPosObj[3,2],aPosObj[3,3],aPosObj[3,4],nOpc,"Tk340LOk2()","AlwaysTrue",,,,/*9999*/,,,,,aHeader2,aCols2)
		oGet2:nMax := 9999   // numero maximo de linhas na getdados 2
		oGet2:lDelete := .F. // desabilita a delecao na getdados 2
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Checa se a data do sistema e maior ou igual a data ³
		//³do evento para habiitar/desabilitar a edicao.      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ddatabase >= oGet1:aCols[oGet1:obrowse:nat][aScan( oGet1:aHeader, { |x| Alltrim(x[2])=="ACE_DATA" } )]
			oGet2:lUPDATE := .t.
		Else
			oGet2:lUPDATE := .f.
		EndIf
		oGet2:lInsert := .t. // permite a insercao de linhas na getdados 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Bloco para ajustar o objeto getdados 2 caso seja alterado    ³
		//³um item na getdados 1 e o lnewline esteja 'true'.            ³
		//³Funcao refresh acionada para atualizar array multidimensional³
		//³que relaciona as duas getdados.                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGet1:oBrowse:bChange    := {|| oGet2:lnewline := .f.,tk340Refresh()}
		oGet2:oBrowse:bChange    := {|| tk340Refresh()} //Funcao refresh acionada para atualizar array multidimensional que relaciona as duas getdados.
		oGet2:AddAction("XLEGENDA",{||  tk340Marca() }) // atribui a acao de marcar no mark da getdados.
		oGet2:oBrowse:Refresh()
		
	Else
		oGet:oBrowse:bDelete:={ || aCols[n,Len(Acols[n])]:=!aCols[n,Len(Acols[n])],AlwaysTrue(),oGet:oBrowse:Refresh(.F.)}
	EndIf

	If nOpcx <> 6
		ACTIVATE MSDIALOG oDlg ON INIT (LChoiceBar(oDlg,nOpc,@nSelecao,nSaveSX8,oGet))
	Else
		ACTIVATE MSDIALOG oDlg ON INIT (LChoiceBar(oDlg,nOpc,@nSelecao,nSaveSX8,oGet1))
	EndIf
Else
	If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela)},aRotina[nOpc][4]) .and. MsGetDAuto(aAutoItens,"Tk340LinOk",{|| Tk340TudOk() .And. Tk340Grava(nOpc,nSaveSX8)},aAutoCab)
		nSelecao := 0
	EndIf
EndIf

If nSelecao == 0
	DbSelectarea("ACD")
	If nOpc == 3
		While (GetSx8Len() > nSaveSx8)
			RollBackSX8()
		End
	EndIf
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³tk340Refresh³ Autor ³  Vendas CRM           ³ Data ³19/07/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a validade da linha digitada 			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³           												    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³TmkA340		                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk340Refresh() 

Local lIntData := ACE->(FieldPos("ACE_DATA")) <> 0 //Valida a existencia do campo referente a data
Local nPosData := 0

If lIntData
	nPosData := aScan( oGet1:aHeader, { |x| Alltrim(x[2])=="ACE_DATA" } ) // retorna a posicao do campo data no aHeader
EndIf

If oGet2:lnewline == .t. .and. oGet2:nat >= len(aTmpAcols2[oGet1:nat])
	oGet2:aCols[oGet2:nat][1]:="LBNO" // atualiza como desmarcado	
EndIf

If oGet1:oBrowse:nAt <= Len(aTmpAcols2) .AND. _nLinGet1 <= Len(aTmpAcols2)
	aTmpAcols2[_nLinGet1] := aClone(oGet2:aCols) 
	oGet2:aCols := aClone(aTmpAcols2[oGet1:oBrowse:nAt])  
EndIf

If lIntData
	// Se a database for maior ou igual a data do evento a edicao da getdados eh habilitada
	If ddatabase >= oGet1:aCols[oGet1:oBrowse:nAt][nPosData]
		oGet2:lUPDATE := .t.
	Else
		oGet2:lUPDATE := .f.
	EndIf
EndIf

oGet2:aCols[Len(oGet2:aCols)][aScan( oGet2:aHeader, { |x| Alltrim(x[2])=="AG5_LISTA" } )] := Tk340ListIni()

oGet2:Refresh()

_nLinGet1 := oGet1:obrowse:nat

oGet1:oBrowse:Refresh()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ tk340Marca ³ Autor ³ Vendas CRM            ³ Data ³19/07/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o campo Presente (sim/nao) de acordo com a marcacao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³           												    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³TmkA340		                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk340Marca()

Local cMarca:=( IIf( oGet2:aCols[oGet2:nAt,1]=="LBNO","LBOK","LBNO"    ) )
Local lIntPresente := .f.  //Valida a existencia do campo referente a Presente
Local nPosPresente := 0

SX2->( dbSetOrder(1) )
If SX2->( DbSeek( "AG5" ) )
	lIntPresente := AG5->(FieldPos("AG5_PRESE")) != 0 //Valida a existencia do campo referente a Presente
EndIf

If lIntPresente
	nPosPresente := aScan( oGet2:aHeader, { |x| Alltrim(x[2])=="AG5_PRESE" } )
	oGet2:aCols[oGet2:nAt,nPosPresente] := iif(cMarca == "LBOK","1","2")     // atualiza para Sim ou Nao
EndIf

oGet2:oBrowse:Refresh()

Return cMarca

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk34LinOk ³ Autor ³Vendas CRM             ³ Data ³16/04/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a validade da linha digitada 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Tk340LinOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³TmkA340													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk340LinOk()

Local lRet		 := .T.					//Retorno logico da funcao
Local nColuna 	 := 0					//Variavel de auxilio para colunas do aHeader
Local nHrIni     := aPosicoes[3][2]    //Posicao do campo para validacao.
Local nHrFim     := aPosicoes[4][2]		//Posicao do campo para validacao.
Local nGrade     := aPosicoes[1][2]		//Posicao do campo para validacao.
Local nACEData   := aPosicoes[5][2]		//Posicao do campo para validacao.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                                           
//³Valida o aCols 			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len(aCols) >= 1) .AND. !aCols[n][nUsado+1]
	For nColuna := 1 to Len(aHeader)
		
		If Empty(aCols[n][nColuna]) .AND. !aCols[n][nUsado+1] .AND. X3Obrigat(aHeader[nColuna][2])
			lRet:=.F.
			Exit
		EndIf
	Next nColuna
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ valida se os horarios das atividades foram preenchidos e se essa validacao esta sendo executada  ³
//³ para uma atividade preechida ( !Empty(aCols[n][1]) )   										     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Empty(aCols[n][nHrFim]) .AND. !Empty(aCols[n][nHrIni]) .AND. !Empty(aCols[n][nGrade])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida os horarios digitados na grade. (Horario inicial e final)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCols[n][nHrFim] <= aCols[n][nHrIni] .AND. !aCols[n][nUsado+1]
		Help(" ",1,"TK340INVHR")
		Return(.F.)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida os horarios com base no cabecalho                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCols[n][nHrIni] < M->ACD_HRINI .OR. aCols[n][nHrIni] > M->ACD_HRFIM
		Help(" ",1,"TK340INVHC")
		Return (.F.)
	EndIf
	
	If aCols[n][nHrFim] < M->ACD_HRINI .OR. aCols[n][nHrFim] > M->ACD_HRFIM
		Help(" ",1,"TK340INVHC")
		Return (.F.)
	EndIf
	
Else
	If !aCols[n][nUsado+1]
		Help(" ",1,"TK340HRNPR")
		Return (.F.)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se os campos data nao estao vazios para a comparacao. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[n][nACEData]) .AND. !Empty(M->ACD_DTINI) .AND. !Empty(M->ACD_DTFIM)
	If (aCols[n][nACEData] < M->ACD_DTINI).AND. (!aCols[n][nUsado+1]) .OR. (aCols[n][nACEData] > M->ACD_DTFIM) .AND. (!aCols[n][nUsado+1])
		Help(" ",1,"TK340INVDT")
		Return(.F.)
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estando vazio um dos campos, valida se sao os campos do ACD(Evento) que estao em branco          ³
	//³ Caso nao exista atividade (Len(aCols) < 1), a validacao da data da grade se torna desnecessaria  ³
	//³ e o programa nao a valida.																		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(M->ACD_DTINI) .or. Empty(M->ACD_DTFIM) .AND. (Len(aCols[n]) >= 1)
		Help(" ",1,"TK340DTNCA")
		Return(.F.)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Sendo a grade valida (Len(aCols) >=1) verifica se a data que nao permitiu a validacao da grade    ³
	//³pertence ao aCols.																				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aCols[n][nACEData]) .AND. (Len(aCols[n]) >=1) .AND. !aCols[n][nUsado+1] 
		Help(" ",1,"TK340DTNPR")
		Return(.F.)
	EndIf
EndIf

If !lRet
	Help(" ",1,"A010VAZ")
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk340LOk2 ºAutor  ³Vendas CRM          º Data ³  09/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao da linha da segunda GetDados                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA340                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk340LOk2()

Local lRet		:= .T.
Local n			:= oGet2:nAt
Local nColuna	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida o aCols 			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len(oGet2:aCols) >= 1) .AND. !aTail(oGet2:aCols[n])

	For nColuna := 1 to Len(oGet2:aHeader)
		
		If Empty(oGet2:aCols[n][nColuna]) .AND. !aTail(oGet2:aCols[n]) .AND. X3Obrigat(oGet2:aHeader[nColuna][2])
			lRet:=.F.
			Exit
		EndIf
		
	Next nColuna
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LchoiceBar³ Autor ³Vendas CRM             ³ Data ³16/04/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra a EnchoiceBar na tela 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºParametros³ ExpO1: Objeto da Tela.                                     º±±
±±º          ³ ExpN1: Opcao de Menu selecionada.                          º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka340					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LChoiceBar(oDlg,nOpc,nSelecao,nSaveSX8,oGet)  

Local aButtons := {}
// Botao na enchoicebar que aciona a execauto para geracao de lista de presenca
If nOpcx == 6
	Aadd(aButtons,{"HISTORIC", {|| TK340EnvWF()}, STR0026}) //"Finalizar"
EndIf  

If nOpc <> 3 .And. nModulo == 73 .And. FindFunction( "CRMA090" )
	aAdd( aButtons,{ "", { ||	CRMA090( 'ACD', ACD->( Recno() ) ) }, STR0044, STR0044 } )//"Anotações"
EndIf

EnchoiceBar(oDlg,{||IIf(oGet:TudoOk() .and. Tk340Grava(nOpc,nSaveSX8),(nSelecao:=1,oDlg:End()),"")},{||Iif((nOpc==3 .And. Alias()=="ACD"),(nSelecao:=2,RollBackSX8()),""),oDlg:End()},,aButtons)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Tk340Grava³ Autor ³Vendas CRM             ³ Data ³28/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao dos dados (Inclusao, Alteracao) com Integridade   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1: Opcao do aRotina                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk340Grava(nOpc,nSaveSX8)

Local nI         := 0  // Contador de Linha
Local nJ	     := 0  // Contador de Linha
Local nY	     := 0  // Contador de Coluna
Local nK	     := 0  // Contador de Coluna
Local nPos       := 0  // Contador de posicao
Local lRet	     := .F.	// Retorno da funcao
Local lGrava     := .F.	// Flag para o Reclock
Local lReplace   := .t.	// Flag para o Reclock
Local lTmk340Fim := ExistBlock("TMK340FIM") 			// Ponto de Entrada no fim da gravacao para atualizar campos do usuario
Local nPosGt1Grad:= 0
Local nPosEvento := 0
Local nPosGrade  := 0
Local nPosContato:= 0
Local lIntEve    := .F.  //Valida a existencia do campo referente Presente
Local lIntGrd    := .F.  //Valida a existencia do campo referente Grade
Local lIntCont   := .F.  //Valida a existencia do campo referente Contato
Local cChave		:= ""
Local aAutoAO4	:= {}


If nOpcx == 6
	
	tk340Refresh()
	nPosGt1Grad := aScan( aHeader, { |x| Alltrim(x[2])=="ACE_GRADE" } )
	SX2->( dbSetOrder(1) )
	If SX2->( DbSeek( "AG5" ) )
		lIntEve    := AG5->(FieldPos("AG5_EVENT")) != 0 //Valida a existencia do campo referente Presente
		lIntGrd    := AG5->(FieldPos("AG5_GRADE")) != 0 //Valida a existencia do campo referente Grade
		lIntCont   := AG5->(FieldPos("AG5_CODCO")) != 0 //Valida a existencia do campo referente Contato
	EndIf
	
	If lIntEve
		nPosEvento  := aScan( oGet2:aHeader, { |x| Alltrim(x[2])=="AG5_EVENT" } )
	EndIf
	
	If lIntGrd
		nPosGrade   := aScan( oGet2:aHeader, { |x| Alltrim(x[2])=="AG5_GRADE" } )
	EndIf
	
	If lIntCont
		nPosContato := aScan( oGet2:aHeader, { |x| Alltrim(x[2])=="AG5_CODCO" } )
	EndIf
	
	If lIntEve .and. lIntGrd .and.	lIntCont
		BEGIN TRANSACTION
		// delecao dos contatos relacionados como confirmados para posterior gravacao conforme relacao do aCols
		DbSelectarea("AG5")
		DbSetOrder(2)
		If DbSeek(xFilial("AG5")+ACD->ACD_CODIGO)
			While AG5->(!Eof()) .AND. (AG5_FILIAL == xFilial("AG5")) .AND. (ACD->ACD_CODIGO == AG5->AG5_EVENT)
				//If AG5->AG5_STRES == "1"
					Reclock( "AG5" ,.F.)
					AG5->(DbDelete())
					AG5->(MsUnlock())
				//EndIf
				AG5->(DbSkip())
			EndDo
		EndIf
		
		For nJ:=1 To Len(aTmpAcols2)	 // Percorre as linhas do Acols com os contatos da Lista de Presenca
			
			bCampo := {|nCPO| Field(nCPO) }
			
			For nK:=1 To Len(aTmpAcols2[nJ])	 // Percorre as linhas do Acols
				
				DbSelectarea("AG5")
				If empty(aTmpAcols2[nJ][nK][nPosEvento]) .or. empty(aTmpAcols2[nJ][nK][nPosContato]) //checa se os campos eventos e contato estao preenchidos
					lReplace := .f.
				Else
					Reclock("AG5",.T.)
				EndIf
				
				If lReplace
					Replace AG5->AG5_FILIAL  With xFilial("AG5")
					
					For nY := 1 To AG5->(FCount())  // Percorre as colunas do Acols
						If (EVAL(bCampo,nY) <> "AG5_FILIAL")
							nPos:= Ascan(oGet2:aHeader,{|x| EVAL(bCampo,nY) $ x[2]})
							
							If (nPos > 0)
								Replace AG5->&(EVAL(bCampo,nY)) With aTmpAcols2[nJ][nK][nPos]
							EndIf
							
						EndIf
					Next nY
					
					AG5->(MsUnlock())
				EndIf
				lReplace := .t.
				
			Next nK
			
		Next nJ
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o usuário alterar o status do contato na lista de presença ³
		//³ para confirmada ou cancelada, efetua somente a gravação dos   ³
		//³ campos ACE_OCUPAC e ACE_STATUS, pois a tabela AG5 não pode ser³
		//³ alterada pelo usuário na rotina de lista de presença.		  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGrvACE .And. lReplace

			nPosGrade   := aScan( aHeader, { |x| Alltrim(x[2])=="ACE_GRADE" } )

			For nJ:=1 To Len(aCols)	 //aCols da tabela ACE				

				dbSelectarea("ACE")
				If ACE->(dbSeek(xFilial("ACE")+M->ACD_CODIGO+aCols[nJ][nPosGrade]))
				
					Reclock("ACE",.F.)
					bCampo := {|nCPO| Field(nCPO) }
					
					For nK := 1 To ACE->(FCount())
	                    If (EVAL(bCampo,nK) == "ACE_OCUPAC")
							nPos:= aScan( oGet1:aHeader, { |x| Alltrim(x[2])=="ACE_OCUPAC" } )
							If (nPos > 0)
								Replace ACE->ACE_OCUPAC With oGet1:aCols[nJ][nPos]
							EndIf			
						ElseIf (EVAL(bCampo,nK) $ "ACE_STATUS")			
							nPos:= aScan( oGet1:aHeader, { |x| Alltrim(x[2])=="ACE_STATUS" } )
							If (nPos > 0)
								Replace ACE->ACE_STATUS With oGet1:aCols[nJ][nPos]
							EndIf											
						EndIf
					Next nK					
					
					ACE->(MsUnlock())
				EndIf				
			
			Next nJ

        EndIf
		END TRANSACTION
	Else
		msgstop(STR0027,STR0028) //"Não é possível gravar os campos da lista de contatos devido nao conter os campos Contato, Grade e Evento"###"Lista não gravada"
	EndIf
EndIf

If (nOpc == 2) //Se for visualizacao nao grava nada e fecha a Tela
	Return(.T.)
Elseif (nOpc == 5) //Exclusao
	lRet := Tk340Dele(nOpc)
	
	Return(lRet)
EndIf

//Valida os campos obrigatorios
If !Obrigatorio(aGets,aTela)
	Return(lRet)
	
ElseIf Empty(M->ACD_CODIGO) // Valida o codigo do evento
	Help(" ",1,"TK340INVCO")
	Return(lRet)
	
ElseIf Empty(M->ACD_DESC) // Valida a descricao do evento
	Help(" ",1,"TK340INVDE")
	Return(lRet)
EndIf

If !Tk340LinOk()
	Return(lRet)
EndIf

BEGIN TRANSACTION

If (nOpc == 3) 	 	//Inclusao
	lGrava := .T.
	
ElseIf nOpc == 4 	//Alteracao
	lGrava := .F.
	
	nPosGt1Grad := aScan( aHeader, { |x| Alltrim(x[2])=="ACE_GRADE" } )	
	For nI:=1 to Len(aCols)
		If aCols[nI][Len(aHeader)+1]   // Caso haja uma delecao, os itens do AG5 relacionados tem seu status alterado
			dbselectarea("AG5")
			dbsetorder(2)
			If dbseek(xFilial("AG5")+M->ACD_CODIGO+aCols[nI][nPosGt1Grad])
				cSeek := xFilial("AG5")+M->ACD_CODIGO+aCols[nI][nPosGt1Grad]
				while AG5->(!EOF()) .and. cSeek == AG5->AG5_FILIAL+AG5->AG5_EVENT+AG5->AG5_GRADE
					reclock("AG5",.f.)
					AG5->AG5_STRES := "3"
					AG5->(msunlock())
					AG5->(dbskip())
				enddo
			EndIf
		EndIf
	Next i
	
	//Apago a grade do evento
	DbSelectarea("ACE")
	DbSetOrder(1)
	DbSeek(xFilial("ACE")+M->ACD_CODIGO )
	While !Eof() .AND. (xFilial("ACE") == ACE->ACE_FILIAL) .AND. (M->ACD_CODIGO == ACE->ACE_CODIGO)
		RecLock("ACE",.F.,.T.)
		DbDelete()
		MsUnlock()
		DbSkip()
	End
	
EndIf

RecLock("ACD",lGrava)

For nI := 1 TO ACD->(FCount())
	If (FieldName(nI) == "ACD_FILIAL")
		FieldPut(nI, xFilial("ACD"))
	Else
		FieldPut(nI, M->&(FieldName(nI)))
	EndIf
Next nI
FkCommit()

If nOpc == 3  // INCLUSAO
	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona ou Remove o privilegios deste registro.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChave 	:= PadR(xFilial("ACD")+ACD->ACD_CODIGO,TAMSX3( "AO4_CHVREG")[1])		
	aAutoAO4	:= CRMA200PAut(nOpc,"ACD",cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)    
	CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOpc)
	
	While (GetSx8Len() > nSaveSx8)
		ConfirmSX8()
	End
	
EndIf
MsUnlock()

For nI:=1 To Len(aCols)	 // Percorre as linhas do Acols
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foi deletado.					    		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCols[nI][Len(aHeader)+1] // alterado de posicao decorrente do recklock inserir uma linha em branco no banco de dados caso o teim esteja deletado
		Loop
	EndIf
	
	DbSelectarea("ACE")
	Reclock("ACE",.T.)
	bCampo := {|nCPO| Field(nCPO) }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foi deletado.					    		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//	If aCols[nI][Len(aHeader)+1]
	//		Loop
	//	EndIf
	
	Replace ACE->ACE_FILIAL  With xFilial("ACE")
	Replace ACE->ACE_CODIGO  With M->ACD_CODIGO
	
	For nY := 1 To ACE->(FCount())  // Percorre as colunas do ACE
		If (EVAL(bCampo,nY) <> "ACE_FILIAL") .AND. (EVAL(bCampo,nY) <> "ACE_CODIGO")
			nPos:= Ascan(aHeader,{|x| EVAL(bCampo,nY) $ x[2]})
			
			If (nPos > 0)
				Replace ACE->&(EVAL(bCampo,nY)) With aCols[nI][nPos]
			EndIf
			
		EndIf
	Next nY
	
	MsUnlock()
	
Next nI

lRet := .T.

END TRANSACTION

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³P.E para atualização dos campos do usuario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lTmk340Fim
	Execblock("TMK340FIM",.F.,.F.,{nOpc})
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk340Dele	³ Autor ³ Vendas CRM            ³ Data ³16/04/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de exclusao            				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³Tmk340     				 								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk340Dele(nOpc)

Local lRet := .T. 						// Retorno da funcao
Local cArqSUW   := CriaTrab(NIL,.F.) 	// Retorna um nome de arquivo válido mas não gera DBF
Local nInd      := 0					// Variavel para ordem de indices
Local lTmk340Del := ExistBlock("TMK340DEL") 			// Ponto de Entrada no fim da exclusao para atualizar campos do usuario

Local cChave     := ""		
Local aAutoAO4  := {}

Default nOpc	:= NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacoes de integridade da base de dados antes da exclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Na Exclusao  procura no SUW (Itens de Campanha) o codigo do evento.  ³
//³Se este evento possuir amarracao nao podera ser excluido.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SUW")
IndRegua("SUW",cArqSUW,"UW_FILIAL+UW_CODEVE")
nInd := RetIndex("SUW")

DbGoTop()
DbSetOrder(nInd+1)

If DbSeek(xFilial("SUW") + ACD->ACD_CODIGO,.T.)
	Aviso(STR0023,STR0024+SUW->UW_CODCAMP,{"OK"})  //"Atenção"###"Este evento esta relacionado a uma campanha. Apague o relacionamento para efetuar a exclusão. Campanha: "
	lRet := .F.
EndIf

DbSelectArea("SUW")
RetIndex("SUW")
DbSetOrder(1)
FErase (cArqSUW+OrdBagExt())

If lRet
	BEGIN TRANSACTION
	
	If (Type("l340Auto") <> "U" .And. l340Auto) .Or. TmkOK(STR0020) //"Confirma a exclus„o"
		lRet:= .T.
		
		//Verifica se existe a tabela AG5
		SX2->(DbSetOrder(1))
		If SX2->(DbSeek("AG5"))
		
			// Ao excluir, o status do contato da AG5 (Lista de Presenca) e alterado
			DbSelectarea("AG5")
			DbSetOrder(2)
			If DbSeek(xFilial("AG5")+M->ACD_CODIGO)
				While AG5->(!Eof()) .AND. (AG5_FILIAL == xFilial("AG5")) .AND. (M->ACD_CODIGO == AG5->AG5_EVENT)
					Reclock( "AG5",.F.)
					AG5->AG5_STRES := "3"
					AG5->(MsUnlock())
					AG5->(DbSkip())
				EndDo
			EndIf
			
		EndIf
		
		DbSelectarea("ACE")
		DbSetOrder(1)
		DbSeek(xFilial("ACE")+ACD->ACD_CODIGO)
		While (!Eof()) .AND. (ACE_FILIAL == xFilial("ACE")) .AND. (ACE_CODIGO == ACD->ACD_CODIGO)
			Reclock( "ACE" ,.F.,.T.)
			DbDelete()
			MsUnlock()
			DbSkip()
		End
		
		DbSelectarea("ACD")
		Reclock( "ACD" ,.F.,.T.)
		DbDelete()
		MsUnlock()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona ou Remove o privilegios deste registro.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cChave 	:= PadR(xFilial("ACD")+ACD->ACD_CODIGO,TAMSX3( "AO4_CHVREG")[1])		
		aAutoAO4	:= CRMA200PAut(nOpc,"ACD",cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)    
		CRMA200Auto(aAutoAO4[1],aAutoAO4[2],5)

	Else
		lRet := .F.
	EndIf      
	
	//--------------------------
	// Exclusao de Anotações   
	//--------------------------
	If nModulo == 73 .And. FindFunction( "CRMA090" )
		CRMA090Del( "ACD", ACD->( Recno() ) )
	EndIf
	
	END TRANSACTION
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³P.E para atualização de campos do usuario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lTmk340Del
	Execblock("TMK340DEL",.F.,.F.)
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK340ValPreco ºAutor  ³Vendas CRM          º Data ³  04/12/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao do campo Preco (ACD_PRECO)    		                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKA340                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk340ValPreco()

Local lRet := .T.

If (M->ACD_GRATUI == "1") .AND. (M->ACD_PRECO <> 0) //1=Sim
	Help(" ",1,"TK340PRECO")
	lRet := .F.
	M->ACD_PRECO := 0
ElseIf (M->ACD_GRATUI == "2") .AND. (M->ACD_PRECO <= 0) //2=Nao
	Help(" ",1,"TK340PREC1")
	lRet := .F.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³tk340IniContºAutor  ³ Vendas CRM         º Data ³  04/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicializador padrao para informar o nome do contato.        º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk340IniCont()

Local cDescricao := ""

dbSelectArea("SU5")
dbSetOrder(1)

If oGet2 == NIL  //executado antes da visualizacao da interface
	If Len(aCols2) > 0
		If !Empty(aCols2[1][aScan( aHeader2, { |x| Alltrim(x[2])=="AG5_CODCO" } )])
			If dbSeek(xfilial("SU5")+acols2[len(aCols2)][aScan( aHeader2, { |x| Alltrim(x[2])=="AG5_CODCO" } )])
				cDescricao := SU5->U5_CONTAT
			EndIf
		EndIf
	EndIf
Else             //executado ao inserir uma nova linha
	If Len(oGet2:aCols) > 0
		If !Empty(oGet2:aCols[1][aScan( oGet2:aHeader, { |x| Alltrim(x[2]) == "AG5_CODCO" } )])
			If dbSeek(xfilial("SU5")+oGet2:acols[len(oGet2:aCols)][aScan( oGet2:aHeader, { |x| Alltrim(x[2])=="AG5_CODCO" } )])
				cDescricao := SU5->U5_CONTAT
			EndIf
		EndIf
	EndIf
EndIf

Return cDescricao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³tk340EntIni ºAutor  ³ Vendas CRM         º Data ³  04/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicializador padrao para informar o nome do entidade.       º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk340EntIni()

Local cDescricao := ""

If oGet2 == NIL //executado antes da visualizacao da interface
	cDescricao := TkEntidade(acols2[len(aCols2)][aScan( aHeader2, { |x| Alltrim(x[2])=="AG5_ENTID" } )],acols2[len(aCols2)][aScan( aHeader2, { |x| Alltrim(x[2])=="AG5_CODEN" } )],1)
Else //executado ao inserir uma nova linha
	cDescricao := TkEntidade(oGet2:acols[len(oGet2:aCols)][aScan( oGet2:aHeader, { |x| Alltrim(x[2])=="AG5_ENTID" } )],oGet2:acols[len(oGet2:aCols)][aScan( oGet2:aHeader, { |x| Alltrim(x[2])=="AG5_CODEN" } )],1)
EndIf

Return cDescricao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³tk340InGrad ºAutor  ³ Vendas CRM         º Data ³  04/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicializador padrao para informar o Codigo da Grade.        º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk340InGrad()

Local cDescricao := ""

If oGet2 == NIL //executado antes da visualizacao da interface
	//cDescricao := Acols[len(aCols)][aScan( aHeader, { |x| Alltrim(x[2])=="ACE_GRADE" } )]
	cDescricao := Acols[1][aScan( aHeader, { |x| Alltrim(x[2])=="ACE_GRADE" } )]
Else
	cDescricao := oGet1:Acols[oGet1:nAt][aScan( oGet1:aHeader, { |x| Alltrim(x[2])=="ACE_GRADE" } )]
EndIf

Return cDescricao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³tk340ListIniºAutor  ³ Vendas CRM         º Data ³  04/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicializador padrao para informar o Codigo da Lista que     º±±
±±º          ³ compoe a concatenacao dos campo evento/grade.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk340ListIni()

Local cDescricao := ""

If oGet2 == NIL //executado antes da visualizacao da interface
	cDescricao := alltrim(M->ACD_CODIGO)+alltrim(Acols[1][aScan( aHeader, { |x| Alltrim(x[2])=="ACE_GRADE" } )])
Else  //executado ao inserir uma nova linha
	cDescricao := alltrim(M->ACD_CODIGO)+alltrim(oGet1:Acols[oGet1:nAt][aScan( oGet1:aHeader, { |x| Alltrim(x[2])=="ACE_GRADE" } )])
EndIf

Return cDescricao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK340EnvWF  ºAutor  ³Vendas CRM          º Data ³  13/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envia Workflow apos a finalizacao da lista de presenca        º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA340                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK340EnvWF()

Local aArea		:= GetArea()	// Grava a area
Local cCampo	:= ""			// Retorna o campo
Local nAuxFor	:= 0			// Auxilia o For... Next
Local nAuxFor1	:= 0			// Auxilia o For... Next
Local nPosCont	:= 0 			// Posicao do Contato
Local nPosPres	:= 0			// Posicao da presenca 1-Sim; 2-Nao

If MsgYesNo(STR0036)				//"Deseja confirmar a finalizacao da lista? Os emails serao disparados aos participantes e o evento sera encerrado."

	If !(Type("aTmpAcols2") == "A" .AND. Type("aHeader2") == "A")
		RestArea(aArea)
		Return
	Endif
		
	nPosCont :=	aScan( aHeader2, { |x| Alltrim(x[2])=="AG5_CODCO" } )
	nPosPres :=	aScan( aHeader2, { |x| Alltrim(x[2])=="AG5_PRESE" } )
	
	For nAuxFor := 1 to Len(aTmpAcols2)
		For nAuxFor1 := 1 to Len(aTmpAcols2[nAuxFor])
			If !Empty(aTmpAcols2[nAuxFor][nAuxFor1][nPosCont])			//Se o contato nao estiver em branco
	
				DbSelectArea("SU5")										//Posiciona o contato
				DbSetOrder(1)
				If DbSeek(xFilial("SU5") + aTmpAcols2[nAuxFor][nAuxFor1][nPosCont])
					If aTmpAcols2[nAuxFor][nAuxFor1][nPosPres] == "2"		//Se veio no evento
						ExecCrmPro("000020")								//Processo que o contato veio no evento
					ElseIf aTmpAcols2[nAuxFor][nAuxFor1][nPosPres] == "1"	//Se nao veio no evento
						ExecCRMPro("000021")								//Processo que o contato nao veio no evento
					Endif
				Endif
			Endif	
		Next nAuxFor1
	Next nAuxFor

	DbSelectArea("ACD")
	DbSetOrder(1)
	If DbSeek(xFilial("ACD")+M->ACD_CODIGO) 
		Begin transaction
			RecLock("ACD",.F.)
			ACD->ACD_STATUS := "3"
			ACD->(MsUnlock())
		End transaction	
	Endif
Endif	

RestArea(aArea)

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 |Tk340TudOk³ Autor ³Vendas CRM             ³ Data ³19/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a validade da linha digitada 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Tk340TudOk()       										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³TmkA340													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk340TudOk()

Local nX   := 0 
Local nDel := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                                           
//³Valida o aCols 			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aCols)
	If (Len(aCols) <= 0) .OR. ((Len(aCols) > 0) .AND. aCols[nX][nUsado+1])
		nDel++
	EndIf 		
Next nX	

If nDel == Len(aCols)
	Help(" ",1,"A010VAZ")
    Return(.F.)
Endif

Return(.T.)	  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 |Tk340Status³ Autor ³Vendas CRM            ³ Data ³21/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Função utilizada no X3_VALID do campo AG5_STRES, para		  ³±±
±±³			 ³atualizar a capacidade de pessoas do evento.		 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Tk340Status(N) N- Linha do aCols da tablela AG5			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³TmkA340													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk340Status(_nLinGet2)

Local aAreaAG5 := AG5->(GetArea())

Local nPosOcupac := aScan( oGet1:aHeader, { |x| Alltrim(x[2])=="ACE_OCUPAC" } )
Local nPosGrade  := aScan( oGet1:aHeader, { |x| Alltrim(x[2])=="ACE_GRADE"  } )
Local nPosMargem := aScan( oGet1:aHeader, { |x| Alltrim(x[2])=="ACE_MARGEM" } )
Local nPosCapaci := aScan( oGet1:aHeader, { |x| Alltrim(x[2])=="ACE_CAPAC"  } )
Local nPosStatus := aScan( oGet1:aHeader, { |x| Alltrim(x[2])=="ACE_STATUS" } )

Local nPosEvento := aScan( oGet2:aHeader, { |x| Alltrim(x[2])=="AG5_EVENT"  } )
Local nPosGrdAG5 := aScan( oGet2:aHeader, { |x| Alltrim(x[2])=="AG5_GRADE"  } )
Local nPosCodCo  := aScan( oGet2:aHeader, { |x| Alltrim(x[2])=="AG5_CODCO"  } )
Local nPosStaAG5 := aScan( oGet2:aHeader, { |x| Alltrim(x[2])=="AG5_STRES"  } )

Local nTotOcup	:= oGet1:aCols[_nLinGet1][nPosOcupac]

If M->AG5_STRES == "1"	//Confirmada

    If oGet2:aCols[_nLinGet2][nPosStaAG5] <> "1"
		nTotOcup += 1
	EndIf
	
	If nTotOcup >= ( (oGet1:aCols[_nLinGet1][nPosMargem] / 100) * oGet1:aCols[_nLinGet1][nPosCapaci] )		

		MsgInfo(STR0037 +;										//"Com a confirmação deste participante a grade "
				alltrim(oGet1:aCols[_nLinGet1][nPosGrade])+;
				STR0038 +;										//" deste evento, "
				STR0039 ,;										//" acabou atingindo o limite de ocupação."
				STR0040 )										//"Grade de Evento LOTADA"
		
		If nTotOcup > ( (oGet1:aCols[_nLinGet1][nPosMargem] / 100) * oGet1:aCols[_nLinGet1][nPosCapaci] )
			nTotOcup -= 1
			oGet2:aCols[_nLinGet2][nPosStaAG5] := ""
		EndIf

		oGet1:aCols[_nLinGet1][nPosOcupac] := nTotOcup
		oGet1:aCols[_nLinGet1][nPosStatus] := "2"	//Lotado
		oGet1:Refresh()

	Else
		oGet1:aCols[_nLinGet1][nPosOcupac] := nTotOcup
		oGet1:Refresh()
	EndIf	

	lGrvACE := .T.		//Variável utilizada para gravação da tabela ACE

ElseIf M->AG5_STRES == "2" 	.Or. M->AG5_STRES == ""		//Cancelada
	
	If oGet2:aCols[_nLinGet2][nPosStaAG5] == "1" .And. nTotOcup > 0

		nTotOcup -= 1

		If nTotOcup <= ( (oGet1:aCols[_nLinGet1][nPosMargem] / 100) * oGet1:aCols[_nLinGet1][nPosCapaci] )

			If oGet1:aCols[_nLinGet1][nPosStatus] == "2"	//Lotado
				MsgInfo(STR0041 +;										//"Com a desistencia deste participante a grade "
						alltrim(oGet1:aCols[_nLinGet1][nPosGrade])+;
						STR0038 +;										//" deste evento, "
						STR0042 ,;										//" acabou retornando o status para EM ABERTO."
						STR0043 )										//"Grade de Evento"
			EndIf

			oGet1:aCols[_nLinGet1][nPosOcupac] := nTotOcup
			oGet1:aCols[_nLinGet1][nPosStatus] := "1"	//Aberto
			oGet1:Refresh()

		Else
			oGet1:aCols[_nLinGet1][nPosOcupac] := nTotOcup
			oGet1:Refresh()	
		EndIf

		lGrvACE := .T.		//Variável utilizada para gravação da tabela ACE
	
	EndIf	
	
EndIf

RestArea(aAreaAG5)
							
Return (.T.)
