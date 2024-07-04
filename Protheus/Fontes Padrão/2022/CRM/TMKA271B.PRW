#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA271B.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TK271Track³ Autor ³ Marcelo Kotaki                  ³ Data ³12/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica qual a rotina e como sera a busca do tracker                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³CALL CENTER                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cicero C. ³03/12/05³8.11  ³-Incluida a Integracao com o Controle de Nao-Conformi-³±±
±±³          ³89415   ³      ³dades                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TK271Track()

Local aEnt     := {}		// Array com a chave de busca
Local cCliente := ""		// Codigo do CLIENTE ou do PROSPECT selecionado	
Local cLoja    := ""		// Codigo da Loja 
Local cAlias   := "SA1"		// Alias 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis usadas em Integracoes                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lIntQNC := SUQ->(FieldPos("UQ_GERFNC")) != 0 //Define a Integracao entre o ambiente Controle de Nao-Conformidades e o ambiente CallCenter     

If nFolder == 1 // TeleMarketing 
	If TkGetTipoAte() $ "145" 	//Telemarketing,  Ambos e TMK x TLV

		If (M->UC_ENTIDAD == "SA1")			//Cliente
			cCliente := SubStr(M->UC_CHAVE,1,TamSx3("A1_COD")[1])
			cLoja    := SubStr(M->UC_CHAVE,TamSx3("A1_COD")[1]+1,TamSx3("A1_LOJA")[1])
			cAlias 	 := "SA1"	

		ElseIf (M->UC_ENTIDAD == "SUS")		//Prospect
			cCliente  := SubStr(M->UC_CHAVE,1,TamSx3("US_COD")[1])
			cLoja     := SubStr(M->UC_CHAVE,TamSx3("US_COD")[1]+1,TamSx3("US_LOJA")[1])
			cAlias    := "SUS"
		Endif
		
	Elseif TkGetTipoAte() == "2" //Televendas
		cCliente   := M->UA_CLIENTE
		cLoja      := M->UA_LOJA
		
	ElseIf TkGetTipoAte() == "3" //Telecobranca
		cCliente   := M->ACF_CLIENT
		cLoja      := M->ACF_LOJA
	Endif
	
ElseIf nFolder == 2 // Televendas
	cCliente   := M->UA_CLIENTE
	cLoja      := M->UA_LOJA
	If lProspect
		cAlias := "SUS"
	Else
		cAlias := "SA1"
	Endif
	 
ElseIf nFolder == 3 // Telecobranca
	cCliente   := M->ACF_CLIENT
	cLoja      := M->ACF_LOJA
	cAlias 	   := "SA1"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura:                                            ³
//³1 - C - Alias da tabela                               ³
//³2 - C - Chave unica de relacionamento                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a funcao fiscal                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aEnt, { cAlias, cCliente + cLoja } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso  exista integracao com o Controle de Nao-Conformidades ³
//³o sistema ira  incluir no mesmo  nivel do SA1 o atendimento ³
//³com as FNCs                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIntQNC
	AAdd( aEnt, { "SUC", SUC->UC_CODIGO } )     // Adiciono ao Tracker o atendimento atual
EndIf

MaTrkShow( aEnt )

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk271EventoºAutor ³Rafael M. Quadrotti º Data ³  11/23/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Permite a visualizacao do cadastro de eventos na tela de   º±±
±±º          ³atendimento.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fernando  ³12/12/06³9.12  ³Bops 115417 Alterado a array aRotina        ³±±
±±³          ³        |      ³para criação do menu funcional              ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk271Evento()
Local aArea     := GetArea() // Salva area anterior.
Local aSRotina  := Iif(Type("aRotina")== "A",aClone(aRotina),{}) // Salva aRotina anterior.
Local cCodCamp	:= "" // Codigo da campanha.
Local aEvento	:= {}  
Local oDlgEve	
Local oLbxEve
Local lRet		:= .F.
Local nauxN		:=N

Private cCadastro := STR0001 //"Visualização de Eventos"
Private aRotina := MenuDef()
INCLUI := .F.


If nFolder == 1 // Telemarketing ou Televendas

	If TkGetTipoAte() == "1" .OR. TkGetTipoAte() == "4" // Telemarketing ou Ambos
		cCodCamp := M->UC_CODCAMP

	ElseIf TkGetTipoAte() == "2" 				// Televendas
		cCodCamp := M->UA_CODCAMP

	ElseIf TkGetTipoAte() == "3" 				// TeleCobranca
		cCodCamp := M->ACF_CODCAM
	
	Endif
	
ElseIf nFolder == 2  //Televendas
	cCodCamp := M->UA_CODCAMP
	
ElseIf nFolder == 3  //TeleCobranca
	cCodCamp := M->ACF_CODCAM
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se foi selecionado a campanha e o tipo da ligacao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cCodCamp) 
	Help(" ",1,"FALTA_CAMP" )
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona os eventos que pertencem a campanha selecionada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SUW")
DbSetOrder(1)
If DbSeek(xFilial("SUW") + cCodCamp)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os eventos para a selecao do operador ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !Eof() .AND. (xFilial("SUW") == SUW->UW_FILIAL) .AND. (SUW->UW_CODCAMP == cCodCamp)
	
		DbSelectarea("ACD")
		DbSetorder(1)
		If DbSeek(xFilial("ACD") + SUW->UW_CODEVE) 

			AAdd(aEvento,{	ACD->ACD_CODIGO,;								 //Codigo do Evento
							ACD->ACD_DESC  ,;								 //Descricao
							ACD->ACD_TEMA  ,;								 //Tema
							ACD->ACD_LOCAL })								 //Local

		Endif
				
		DbSelectarea("SUW")
		DbSkip()
	End


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existem eventos selecionados.               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Len(aEvento) > 0)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a tela para a escolha do evento				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlgEve FROM  50,0 TO 260,700 TITLE STR0002 PIXEL //"Eventos"
	
			@02,03 TO 87,337 LABEL "" OF oDlgEve PIXEL
			@05,05 LISTBOX oLbxEve FIELDS HEADER ;
				STR0002,;  //"Eventos"
				STR0003,;  //"Titulo"
				STR0004,;  //"Tema"
				STR0005;   //"Local"
				SIZE 330,80 OF oDlgEve PIXEL NOSCROLL 

			oLbxEve:SetArray(aEvento)
			oLbxEve:bLine:={||{		 aEvento[oLbxEve:nAt,1],;
									 aEvento[oLbxEve:nAt,2],;
									 aEvento[oLbxEve:nAt,3],;							 
									 aEvento[oLbxEve:nAt,4]}}
			oLbxEve:Refresh()


			DEFINE SBUTTON FROM 90,290  TYPE 1 ENABLE OF oDlgEve ACTION (lRet:= .T., nPos:= oLbxEve:nAt,oDlgEve:End())
			DEFINE SBUTTON FROM 90,320	TYPE 2 ENABLE OF oDlgEve ACTION (lRet:= .F.,oDlgEve:End())
	
		ACTIVATE MSDIALOG oDlgEve CENTERED
	

		If lRet

			DbSelectArea("ACD")
			DbSetOrder(1)

			If DbSeek(xFilial("ACD") + aEvento[nPos][1])
				Tk340Eventos("ACD",RECNO(),2)
				N := nauxN
			EndIf	
        EndIf
		
	Else
		Help(" ",1,"SEMEVENTO") //Nao existe evento para esta campanha
	Endif
Endif

Iif(Len(aSRotina)>0,aRotina:=aClone(aSRotina),)
RestArea(aArea)

Return(lRet)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Fernando Amorim       ³ Data ³11/12/06  ³±±
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

Local aRotina:= {  		{ STR0006  ,"AxPesqui"     , 0 , 1 , , .F.}  ,; //"Pesquisar"  
						{ STR0007 ,"Tk340Eventos"  , 0 , 2 , , .T.} }   //"Visualizar" 


							
							
Return(ARotina)
