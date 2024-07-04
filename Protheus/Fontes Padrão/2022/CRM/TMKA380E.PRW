#INCLUDE "TMKA380E.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TMKDEF.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTMKA380E  บAutor  ณVendas Clientes     บ Data ณ  01/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAgenda do operador. Marketing Ativo.                        บฑฑ
ฑฑบ          ณTela de execucao do script dinamico.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Call Center                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380Script   ณAutor  ณVendas Clientes        ณData  ณ  19/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela de execucao de Scripts dinamicos do Modulo Call Center.       บฑฑ
ฑฑบ          ณUtilizada na Agenda do Operador e Atendimento Receptivo.           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAp8- Call Center - Agenda do Operador e Atendimento Receptivo      บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380Script( 	nOpc		,cCampanha	,cScript	,cCodCont	,;
						cEntidade	,cChave		,cAlias		,nReg		,;
						cOperador	,cLista		,cSU6Cod	,cCodAte	,;
						aParScript )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis utilizadas por todo o fonte.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local lRet				:= .F.						// Retorno da funcao
Local l380				:= .F.						// Flag para controlar quem esta executando a rotina
Local nCont 			:= 0						//Contador para criacao dos paineis.
Local aSizeDlg      	:= MsAdvSize(.T.,.F.,400)	//Array com as dimensoes da tela principal.
Local aBtn          	:= Array(7)					//Array com os botoes
Local oBar               							//Toolbar do Script
Local cTipTel       	:= ""                       // Tipo do Telefone - como DEFAULT vai pegar o "telefone comercial 1" do contato para exibir na tela 
Local cTel       		:= ""						//Telefone do Contato
Local cDDD       		:= ""						//DDD do Telefone do Contato
Local cPais       		:= ""						//Pais do Telefone do Contato
Local cDescChave   		:= ""						//Nome da Chave da Entidade
Local cDesEntida		:= ""						//Descricao da Entidade
Local cScore			:= CriaVar("UP_SCORE",.F.)  //Pontuacao
Local aObjects			:={}						//Array com os objetos da tela
Local aInfo				:={}						//Array para utilizacao do MsAdvSize
Local aPosObj			:= {}						//Array com as coordenadas para posicionamento dos objetos
Local cDescCont			:= ""						//Descricao do Contato
Local chTitle			:= ""						//Mensagem wizard. Descricao da campanha.
Local aPerguntas		:= {}						//Array com o questionario
Local oScroll   									//Scroll onde serao apresentadas as respostas                                                       
Local oFont1										//Tipo de Fonte da pergunta
Local cFormato			:= ""						//Formato do Script
Local aControl			:= {} 						//Array com as informacoes das respostas.
Local aMemos			:= {}						//Array com os memos da tela de scripts dinamicos 
Local bVarM				:= {||}						//Bloco de codigo para criacao de memo.
Local aMRes				:= {}						//Array com as inf. dos memos das respostas.
Local nLastPanel		:= 1						//Ultimo painel apresentado.
Local nPos				:= 0						//Posicao do array aParScript a ser modificada
Local oScrEnd										// ScrollBox da tela
Local oMemoFim			
Local cMemoFim			:= ""						//Resultado do Script.		
Local cCodigo			:= ""						
Local cCodLig			:= ""
Local cFixHeader		:= ""						// Texto fixo para apresentacao das mensgens do wizard.

// Novos Objetos Criados
Local oSayObsPerg									// Objeto say da Str da Observa็ใo da pergunta
Local aScroll			:= {}						// Array de Scroll das telas do wizard
Local aMemoPerg			:= {}						// Array do Memo para conter o enunciado de cada pergunta
Local aPanel			:= {}

Local aCoord 			:= {}						// Array auxiliar com as coordenadas de criacao de novos objetos do script
Local aPanelScore 		:= {} 						// Array para controle do score conforme as telas navegadas para o Tipo Atendimento

Local lUseTreeView		:= GetMv("MV_TK380T",,.F.) // Determina se ira mostrar o tree para facilitar o atendimento
Local aPosWizard		:= {}
Local oTree				:= Nil
Local aTreeXPanel		:= {}
Local nX				:= 0

DEFAULT cCampanha  		:= ""						// Codigo da Campanha
DEFAULT cScript  		:= ""						// Codigo do Script
DEFAULT cCodCont 		:= ""                		// Codigo do Contato
DEFAULT cEntidade		:= ""						// Entidade
DEFAULT cChave   		:= ""						// Chave da Entidade
DEFAULT cAlias   		:= "SU5"					// Alias Default do Contato para a execucao do atendimento
DEFAULT nReg	 	  	:= 0						// Registro do arquivo para a execucao do atendimento
DEFAULT cLista          := ""
DEFAULT cSU6Cod			:= ""
DEFAULT aParScript      := {}						// Array com as informacoes para alteracao e gravacao pelo atendimento receptivo.
           
DEFINE FONT oFont1   NAME "Tahoma" SIZE 0,15 BOLD   // Fontes para os Say dos STR - Negrito 
DEFINE FONT oFont2   NAME "Tahoma" SIZE 0,14 		// Fontes para os Say dos STR	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida quem esta executando essa funcaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Upper(FUNNAME()) == "TMKA380"
	l380 := .T.
Endif	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTipo do Telefone - como DEFAULT vai pegar o "telefone comercial 1" do contato para exibir na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTipTel  := Posicione("SU4",1,xFilial("SU4") + cLista,"U4_TIPOTEL")  

If Empty(Alltrim(cTipTel))
	cTipTel := "1"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega as perguntas e respostas			   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Tk380LeScript(aPerguntas,@cFormato,cScript,cLista)
	Help(" ",1,"SEMLIGACAO")
	Return(lRet)
Endif

aPosWizard := {aSizeDlg[7],000,aSizeDlg[6]-60,aSizeDlg[5]}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalculo do posicionamento as perguntas e respostas ณ
//ณnos paineis.                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aObjects := {}
AAdd( aObjects, { 100, 019, .T., .F. } )
AAdd( aObjects, { 100, 040, .T., .F. } )
AAdd( aObjects, { 100, 020, .T., .F. } ) 
AAdd( aObjects, { 100, 065, .T., .F. } )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณO calculo do posicionamento dos objetos sera feito depois     ณ
//ณda criacao do wizard devido a necessidade da criacao do objetoณ
//ณpanel.                                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes da tela.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cCodCont)
	cDescCont := Left(TkDadosContato(cCodCont,6,.T.),26)
	cDescChave:= Left(TkEntidade(cEntidade,cChave,1,,.T.),25)
	SX2->( DbSetOrder( 1 ) )
	SX2->( MsSeek( cEntidade ) )
	cDesEntida := Capital( X2NOME() )
	cDDD      := AllTrim(TkDadosContato(cCodCont,8,.T.))
	cPais     := AllTrim(TkDadosContato(cCodCont,9,.T.))
	cTel      := cPais + cDDD + AllTrim(TkDadosContato(cCodCont,Val(cTipTel),.T.))
Endif
                                                                                                                   
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTitulo da tela para Script		  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
chTitle := STR0001+ cCampanha+"  "+ Posicione("SUO",1,xFilial("SUO") + cCampanha,"UO_DESC")   //"Campanha: "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMensagem do Header fixa para concatenacao com o Score.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cFixHeader:= STR0002+Upper(cDescCont)+Space(10)+STR0003+Upper(cDescChave)+" - "+cDesEntida+STR0004+cTel+Space(15)+STR0018

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclaracao do objeto Wizardณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWizard:= APWizard():New( 	chTitle+CRLF+STR0002+UPPER(cDescCont)+Space(10)+STR0003+UPPER(cDescChave)+" - "+cDesEntida+STR0004+cTel,; //"Contato: ","Entidade: ","      Fone: "
							,; 
						  	STR0005,; //"Resposta de Scripts Dinโmicos Call Center"
							 ,;
							 {||Tk380Next(	aPerguntas	,cFormato	,@oWizard	,aControl	,;
							 				@nLastPanel	,@oMemoFim	,@cMemoFim	,@cScore	,;
							 				cFixheader	,@aPanelScore )},; 
							 {||.F.},.T., , , .T.,aPosWizard ,Iif (lUseTreeView,30,0))
            
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCalculo de coordenadas dos objetos da tela de acordo com as coordenada do painel.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aInfo   := { 0, 0, oWizard:GetPanel(1):nClientHeight, oWizard:GetPanel(1):nClientWidth, 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCriacao do arrays dos objetos variaveis          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Aadd(aScroll   ,NIL)     	// Array do Scroll de cada tela do Wizard
		Aadd(aMemos    ,{NIL, NIL}) // Array do memos para conter a observasao da Pergunta
		Aadd(aMemoPerg ,{NIL,NIL}) 	// Array do Memo para conter o enunciado de cada pergunta
		Aadd(aMRes     ,{NIL, NIL}) // Array do memos para conter a observasao da Resposta
		Aadd(aPanel   ,NIL)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณScroll para a criacao de todos os objetos da  resposta.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		@ 0,0 SCROLLBOX aScroll[1] OF oWizard:GETPANEL(1) PIXEL 
		aScroll[1]:Align:=CONTROL_ALIGN_ALLCLIENT

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณToolbar do primeiro painel.                              ณ
		//ณAs barras de ferramentas deverao ser criadas por painel. ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DEFINE BUTTONBAR oBar 3D TOP OF IIf(!lUseTreeView,oWizard:GETPANEL(1),aScroll[1])

		DEFINE BUTTON aBtn[1] RESOURCE "BMPUSER"	OF oBar TOOLTIP STR0007  ACTION Tk380VisContato(cCodCont) WHEN .T. 			//"Alteracao de Contatos"
		aBtn[1]:cTitle:=""

		DEFINE BUTTON aBtn[2] RESOURCE "VENDEDOR"	OF oBar TOOLTIP STR0009 ACTION Tk380VisEntidade(cEntidade,cChave) WHEN .T. 	//"Alteracao de Entidades"
		aBtn[2]:cTitle:=""
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe a rotina nao foi executada a partir da Agenda do Operador nao exibe o Botao de atendimento receptivoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If l380
			DEFINE BUTTON aBtn[3] RESOURCE "NOTE"	OF oBar TOOLTIP STR0011 ACTION Tk380CallCenter(cCodCont,cEntidade,cChave,0,3)  WHEN .T. //"Call Center Receptivo"
			aBtn[3]:cTitle:=""
		Else
			aBtn[3] := ""
		Endif	
		
		DEFINE BUTTON aBtn[4] RESOURCE "POSCLI"		OF oBar TOOLTIP STR0012 ACTION Tk380VisEvento(cLista) WHEN .T. //"Evento"
		aBtn[4]:cTitle:=""
		
		DEFINE BUTTON aBtn[5] RESOURCE "SIMULACAO"	OF oBar TOOLTIP STR0014 ACTION Tk380SituaC(cEntidade,cChave)  WHEN .T. //"Consulta posi็ใo de Clientes"
		aBtn[5]:cTitle:=""
		
		DEFINE BUTTON aBtn[6] RESOURCE "BUDGET"		OF oBar TOOLTIP STR0015  ACTION Tk380Titulo(cChave,cLista) WHEN .T.//"Consulta de Titulos"
		aBtn[6]:cTitle:=""

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Cria o painel para ser utilizado no Tree.       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lUseTreeView 
			@ 0,0 MSPANEL aPanel[1] OF oWizard:oDlg SIZE 237,90 RAISED
			aPanel[1]:Align := CONTROL_ALIGN_LEFT
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณTitulo da Observacao da pergunta                 ณ
		//ณObserva็ใo da Pergunta                           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		@ 0,0 SAY oSayObsPerg VAR STR0016 SIZE 60,10 FONT oFont2 COLOR CLR_RED OF aScroll[1] PIXEL //"Observa็ใo da Pergunta"
		oSayObsPerg:Align := CONTROL_ALIGN_TOP

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMemo da Observacao da pergunta                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Tk380ObsPerg(aPerguntas[1,1,5],aScroll,oFont2,1,aMemos)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMemo do enunciado da pergunta                    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Tk380Pergunta(aPerguntas[1,1,4],aScroll,oFont1,1,aMemoPerg)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณApresent o titulo da Observacao da pergunta      ณ
		//ณ"Observa็ใo da Pergunta"                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		@ 0,0 SAY oSayObsResp VAR STR0017 SIZE 60,10 FONT oFont2 COLOR CLR_RED OF aScroll[1] PIXEL //"Observa็ใo da Resposta"
		oSayObsResp:Align := CONTROL_ALIGN_TOP

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMemo da Observa็ใo da resposta                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Tk380MemRes(aPerguntas[1],aScroll,1,@aMRes,oFont2)		

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAvalia o tipo de objeto da resposta e cria a resposta no scroll.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aCoord := {55,03,aPosObj[4,3]-10,aPosObj[4,4]-10}

		If lUseTreeView                    
			oTree := xTree():New( 0 ,0, 10,10, aPanel[1])
			oTree:AddTree (aPerguntas[1,1,4], "FOLDER516","FOLDER616", aPerguntas[1,1,2],{||Tk380ChgTr(oTree,oWizard,aTreeXPanel,@aControl)})
			oTree:Align:=CONTROL_ALIGN_ALLCLIENT
			aAdd(aTreeXPanel,{1,aPerguntas[1,1,2],{}})
		Endif

		Tk380Resposta(	aPerguntas[1]	,aCoord		,aScroll	,@aControl	,;
						1				,nOpc		,cCodigo	,@oTree		,;
						@aTreeXPanel	,@oWizard	,@aMRes	)
		If lUseTreeView
			oTree:EndTree()		
		Endif
		
		For nCont := 2 TO Len(aPerguntas)
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCriacao dos paineis com as questoes e respostas.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			CREATE PANEL oWizard  HEADER cFixHeader+Transform(cScore,"999999")  MESSAGE " " ;  //"Contato: ","Entidade: ","      Fone: ","Score: "
					 			 BACK {||Tk380Prev(	aPerguntas	,cFormato	,oWizard	,@aControl	,;
					 			 					nLastPanel	,@cScore	,@aPanelScore)};
								 NEXT {||Tk380Next(	aPerguntas	,cFormato	,@oWizard	,aControl	,;
								 					@nLastPanel	,@oMemoFim	,@cMemoFim	,@cScore	,;
								 					cFixHeader	,@aPanelScore)};
								 FINISH {||.T.,lRet:=.T.} PANEL

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCriacao do arrays dos objetos variaveis          ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Aadd(aScroll   ,NIL)     	// Array do Scroll de cada tela do Wizard
			Aadd(aMemoPerg ,{NIL,NIL}) 	// Array do Memo para conter o enunciado de cada pergunta
			Aadd(aMRes     ,{NIL,NIL}) // Array do memos para conter a observasao da Resposta
			Aadd(aMemos    ,{NIL,NIL}) //Criacao de memos de acordo com a quantidade de panels
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณScroll para a criacao de todos os objetos da  resposta.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			@ 0,0 SCROLLBOX aScroll[nCont] SIZE aPosObj[4,3],(oWizard:GetPanel(1):nClientWidth/2)-5 OF oWizard:GETPANEL(nCont) PIXEL 
			aScroll[nCont]:Align:=CONTROL_ALIGN_ALLCLIENT
					
			DEFINE BUTTONBAR oBar 3D TOP OF IIf(!lUseTreeView,oWizard:GETPANEL(nCont),aScroll[nCont])

			DEFINE BUTTON aBtn[1] RESOURCE "BMPUSER"	OF oBar TOOLTIP STR0007  ACTION Tk380VisContato(cCodCont) WHEN .T. //"Altera็ใo de Contatos"
			aBtn[1]:cTitle:=""
			DEFINE BUTTON aBtn[2] RESOURCE "VENDEDOR"	OF oBar TOOLTIP STR0009 ACTION Tk380VisEntidade(cEntidade,cChave) WHEN .T. //"Altera็ใo de Entidades"
			aBtn[2]:cTitle:=""
			If l380
				DEFINE BUTTON aBtn[3] RESOURCE "NOTE"		OF oBar TOOLTIP STR0011 ACTION Tk380CallCenter(cCodCont,cEntidade,cChave,0,3)  WHEN .T. //"Call Center Receptivo"
				aBtn[3]:cTitle:=""
			Else
				aBtn[3]:= ""
			EndIf
			DEFINE BUTTON aBtn[4] RESOURCE "POSCLI"		OF oBar TOOLTIP STR0012 ACTION Tk380VisEvento(cLista) WHEN .T. //"Evento"
			aBtn[4]:cTitle:=""
			DEFINE BUTTON aBtn[5] RESOURCE "SIMULACAO"	OF oBar TOOLTIP STR0014 ACTION Tk380SituaC(cEntidade,cChave)  WHEN .T.//"Consulta posi็ใo de Clientes"
			aBtn[5]:cTitle:=""
			DEFINE BUTTON aBtn[6] RESOURCE "BUDGET"		OF oBar TOOLTIP STR0015 ACTION Tk380Titulo(cChave,cLista) WHEN .T. //"Consulta de Titulos"
			aBtn[6]:cTitle:=""

			If lUseTreeView
				oTree:AddTree (aPerguntas[nCont,1,4], "FOLDER516","FOLDER616", aPerguntas[nCont,1,2],{||Tk380ChgTr(oTree,oWizard,aTreeXPanel,@aControl)})
				aAdd(aTreeXPanel,{nCont,aPerguntas[nCont,1,2],{}})
			Endif
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณTitulo da Observacao da pergunta                 ณ
			//ณObserva็ใo da Pergunta                           ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			@ 0,0 SAY oSayObsPerg VAR STR0016 SIZE 60,10 FONT oFont2 COLOR CLR_RED OF aScroll[nCont] PIXEL //"Observa็ใo da Pergunta"
			oSayObsPerg:Align := CONTROL_ALIGN_TOP

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณMemo da Observacao da pergunta                   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Tk380ObsPerg(aPerguntas[nCont,1,5],aScroll,oFont2,nCont,aMemos)

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณMemo do enunciado da pergunta                    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Tk380Pergunta(aPerguntas[nCont,1,4],aScroll,oFont1,nCont,aMemoPerg)

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณTitulo da Observacao da pergunta                 ณ
			//ณObserva็ใo da Pergunta                           ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			@ 0,0 SAY oSayObsResp VAR STR0017 SIZE 60,10 FONT oFont2 COLOR CLR_RED OF aScroll[nCont] PIXEL //"Observa็ใo da Resposta"
			oSayObsResp:Align := CONTROL_ALIGN_TOP
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณMemo da Observa็ใo da resposta                   ณ
  			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Tk380MemRes(aPerguntas[nCont],aScroll,nCont,@aMRes,oFont2)		

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAvalia o tipo de objeto da resposta e cria a resposta no scroll.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aCoord := {55,03,aPosObj[4,3]-10,aPosObj[4,4]-10}
			
			Tk380Resposta(	aPerguntas[nCont]	,aCoord		,aScroll	,@aControl	,;
							nCont				,nOpc		,cCodigo	,@oTree		,;
							@aTreeXPanel		,@oWizard	,@aMRes	)
							
			If lUseTreeView
				oTree:EndTree()
			Endif					
			
		Next nCont
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCriacao de painel da conclusao do Script.	   ณ   
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		CREATE PANEL oWizard  HEADER STR0002+Upper(cDescCont)+Space(10)+STR0003+Upper(cDescChave)+" - "+cDesEntida+STR0004+cTel+Space(15)+STR0018+Transform(cScore,"999999")  MESSAGE " " ;  //"Contato: "###"Entidade: "###"      Fone: "###"Score: "
				 			 BACK {||Tk380Prev(	aPerguntas	,cFormato	,oWizard	,@aControl,;
				 			 					nLastPanel	,@cScore    ,@aPanelScore)};
							 NEXT {||};
							 FINISH {||.T.,;
							 			lRet:=.T.,;
							 			If(l380,Tk380Grava(	aControl	,aPerguntas	,cOperador	,cCodigo	,;
											                cFormato	,cCampanha	,cScript	,cEntidade	,;
											                cChave		,cCodCont	,cCodLig	,cLista	  	,;
											                cCodAte		),;
							    				 (nPos := aScan(aParScript,{|x| x[6]==cCampanha .AND. x[7]==cScript .AND. x[13]==cCodAte }),;
							    				 IIf(nPos==0,	Aadd(	aParScript,{aControl	,aPerguntas	,cOperador	,cCodigo,;
															 		 				cFormato	,cCampanha	,cScript	,cEntidade,;
       												              					cChave	,cCodCont	,cCodLig	,cLista   ,;
       												              					cCodAte}),;
       															aParScript[nPos][1]:=aControl )));
							    		,.T.} PANEL
							 
		
		DEFINE BUTTONBAR oBar 3D TOP OF oWizard:GETPANEL(nCont)
		DEFINE BUTTON aBtn[1] RESOURCE "BMPUSER"	OF oBar TOOLTIP STR0007  ACTION Tk380VisContato(cCodCont) WHEN .T. //"Altera็ใo de Contatos"
		aBtn[1]:cTitle:=""
		DEFINE BUTTON aBtn[2] RESOURCE "VENDEDOR"	OF oBar TOOLTIP STR0009 ACTION Tk380VisEntidade(cEntidade,cChave) WHEN .T.//"Altera็ใo de Entidades"
		aBtn[2]:cTitle:=""
		If l380
			DEFINE BUTTON aBtn[3] RESOURCE "NOTE"		OF oBar TOOLTIP STR0011 ACTION Tk380CallCenter(cCodCont,cEntidade,cChave,0,3)  WHEN .T. //"Call Center Receptivo"
			aBtn[3]:cTitle:=""
		Else
			aBtn[3]:= ""
		EndIf
		DEFINE BUTTON aBtn[4] RESOURCE "POSCLI"		OF oBar TOOLTIP STR0012 ACTION Tk380VisEvento(cLista) WHEN .T. //"Evento"
		aBtn[4]:cTitle:=""
		DEFINE BUTTON aBtn[5] RESOURCE "SIMULACAO"	OF oBar TOOLTIP STR0014 ACTION Tk380SituaC(cEntidade,cChave)  WHEN .T. //"Consulta posi็ใo de Clientes"
		aBtn[5]:cTitle:=""
		DEFINE BUTTON aBtn[6] RESOURCE "BUDGET"		OF oBar TOOLTIP STR0015  ACTION Tk380Titulo(cChave,cLista) WHEN .T. //"Consulta de Titulos"
		aBtn[6]:cTitle:=""
		
		@aPosObj[2,1],02 SCROLLBOX oScrEnd SIZE (oWizard:GetPanel(1):nClientHeight/2)-5,(oWizard:GetPanel(1):nClientWidth/2)-5 OF oWizard:GETPANEL(nCont) PIXEL 
		oMemoFim:=	TMultiGet():New( 	01,01, {||cMemoFim},;
			 							oScrEnd, (oWizard:GetPanel(1):nClientWidth/2)-10, (oWizard:GetPanel(1):nClientHeight/2)-20, NIL, .F.,;
										NIL, NIL, NIL, .T.,;
										NIL, .F., {||}, .F.,;
										.F., .T., NIL,;
										NIL, .F., NIL, NIL)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se ้ uma alteracao e carrega as informacoes para ณ
		//ณos objetos.                                               ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Tk380LRes(@aControl		,nOpc		,cCampanha	,cScript	,cCodCont	,;
				   cEntidade	,cChave		,cAlias		,nReg		,cOperador	,;
		    	   cLista   	,cSU6Cod	,cCodAte	,aParScript ,@cCodigo 	,;
				   aPerguntas)

		If lUseTreeView
			Tk380LoadT(@oTree, @aControl,@aTreeXPanel)
		EndIf

ACTIVATE WIZARD oWizard WHEN {||.T.} 

//Atribui as informacoes do script
If l380 

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se eh uma alteracao de um script ja respondido nesteณ
	//ณatendimento                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nPos := aScan(aParScript,{|x| x[6]==cCampanha .AND. x[7]==cScript .AND. x[13]==cCodAte })

	If nPos == 0
		Aadd(aParScript,{	aControl	,aPerguntas	,cOperador	,cCodigo,;
							cFormato	,cCampanha	,cScript	,cEntidade,;
       						cChave	,cCodCont	,cCodLig	,cLista   ,;
       						cCodAte}	)
	Else
		aParScript[nPos][1] := aControl 
	EndIf

EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380Pergunta   ณAutor  ณVendas Clientes         ณData  ณ  20/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria as perguntas do script                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcPergunta	: Texto para pergunta.                                 		บฑฑ
ฑฑบ          ณaScroll	: Array de Scroll das telas                                 บฑฑ 
ฑฑบ          ณoFont1	: Fonte do Memo                                             บฑฑ 
ฑฑบ          ณnCont		: Contador da questao					    				บฑฑ 
ฑฑบ          ณaMemoPerg	: Array do Objeto + Variavel GET							บฑฑ 
ฑฑบ          ณ           [1] Armazema o objeto GET         							บฑฑ 
ฑฑบ          ณ           [2] Armazema a variavel do objeto GET						บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAp8 - Agenda do Operador                                              บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380Pergunta(cPergunta,aScroll,oFont1,nCont,aMemoPerg)

aMemoPerg[nCont,2]:=cPergunta

@ 0,0 GET aMemoPerg[nCont,1] VAR aMemoPerg[nCont,2] MEMO SIZE 280,20 FONT oFont1 READONLY OF aScroll[nCont] PIXEL 
aMemoPerg[nCont,1]:Align := CONTROL_ALIGN_TOP

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380Pergunta   ณAutor  ณVendas Clientes         ณData  ณ  20/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria memo da observacao da pergunta                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcPergunta	: Texto da observacao                                       บฑฑ
ฑฑบ          ณaScroll	: Array de Scroll das telas                                 บฑฑ 
ฑฑบ          ณoFont2	: Fonte do Memo da pergunta (Negrito)                       บฑฑ 
ฑฑบ          ณnCont		: Contador da questao					    				บฑฑ 
ฑฑบ          ณaMemos	: Array do Objeto + Variavel GET							บฑฑ 
ฑฑบ          ณ           [1] Armazema o objeto GET         							บฑฑ 
ฑฑบ          ณ           [2] Armazema a variavel do objeto GET						บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAp8 - Agenda do Operador                                              บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380ObsPerg(cPergunta,aScroll,oFont2,nCont,aMemos)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArmazena os dados do campo observaco SYP						  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aMemos[nCont,2]:= MSMM(cPergunta,If( ((TamSx3("UP_OBS")[1]) < 80 ),80 , TamSx3("UP_OBS")[1]))

@ 0,0 GET aMemos[nCont,1] VAR aMemos[nCont,2] MEMO SIZE 280,30 FONT oFont2 READONLY OF aScroll[nCont] PIXEL 
aMemos[nCont,1]:Align := CONTROL_ALIGN_TOP

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380Resposta   ณ  AutorณVendas Clientes         ณData  ณ  21/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria as respostas do script                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Array com a pergunta e suas respostas.               			บฑฑ
ฑฑบ          ณExpA2: Array com as coordenadas para criacao dos objetos.   			บฑฑ 
ฑฑบ          ณExpO1: Objeto Scroll das respostas.                                   บฑฑ 
ฑฑบ          ณExpA3: Array com os controles das perguntas e respostas.              บฑฑ 
ฑฑบ          ณExpN1: Variavel que indica o posicionamento do laco.                  บฑฑ 
ฑฑบ          ณExpN2: Opcao de menu.                                                 บฑฑ 
ฑฑบ          ณExpC1: Codigo para busca de informacoes.(proveniente do atendimento)  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAP8 - Agenda do Operador                                              บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Tk380Resposta(	aItPerg		,aCoord	,aScroll	,aControl	,;
								nItems		,nOpc	,cCodigo	,oTree		,;
								aTreeXPanel	,oWizard,aMRes)

Local nResposta	:= 0      				// Contador auxiliar
Local nTop      := aCoord[1]			// Coordenada inicial do complemento de objeto (TOP)
Local aResposta := {}					// Array com as repostas
Local cTpObj	:= aItPerg[1,7]			// Tipo de objeto para o item de resposta
Local aMemos	:= {}   				// Memo
Local lUseTree  := (oTree <> Nil)
Local nRespResta                        
Local nPosTree, cChave

If Len(aItPerg[2])>0
	aResposta := aClone(aItPerg[2])
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica qual o tipo do objeto a ser criado para cada resposta.ณ
//ณ1 - Checkbox (Multipla Escolha)                                ณ
//ณ2 - Radiobutton (Unica Escolha)                                ณ
//ณ3 - Memo (Dissertativa)                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (Len(aResposta) > 0)

	For nResposta:= 1 To Len(aResposta)
    
		Do Case
	
			Case (cTpObj == "1") //Unica Escolha (Radio)
				
				If lUseTree                                  
					For nRespResta := 1 to Len(aResposta) 
						cChave := aResposta[nResposta][2] + "-"+Alltrim(Str(nRespResta))
						oTree:AddTreeItem(aResposta[nRespResta][4],"BPMSEDT4_mdi",cChave,,,{||Tk380ChgTr(oTree,oWizard,aTreeXPanel,@aControl)})
						nPosTree := Len(aTreeXPanel)
						aAdd(aTreeXPanel[nPosTree][3],cChave)

		
					Next nRespResta
				Endif

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCria um radio unico com todas as respostas da pergunta.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู				
					Tk380Radio(	aResposta	,@aCoord	,aScroll	,@aControl	,;
								@aMemos 	,nItems		,nOpc		,cCodigo	,;
								oTree		,aTreeXPanel,@aMRes)
					
                Exit

			Case (cTpObj == "2") //Multipla Escolha (Checkbox)
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCria um checkbox para cada resposta das perguntas.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				Tk380Check(	aResposta[nResposta]	,@nTop		,aScroll	,@aControl,;
							aItPerg[1,2]			,aCoord		,nOpc		,cCodigo,; 
							nItems					,nResposta	,oTree		,aTreeXPanel)
				If lUseTree                                  
					oTree:AddTreeItem(aResposta[nResposta][4],"BPMSEDT4_mdi",aResposta[nResposta][2],,,{||Tk380ChgTr(oTree,oWizard,aTreeXPanel,@aControl)})

					nPosTree := Len(aTreeXPanel)
					aAdd(aTreeXPanel[nPosTree][3],aResposta[nResposta][2])

				Endif
		EndCase

	Next nResposta

Else
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria um memo para a inclusao da resposta do cliente.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Tk380Memo(aCoord,aScroll,@aControl,aItPerg[1,2],nOpc,cCodigo,nItems) 

Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380Radio      ณ  AutorณVendas Clientes         ณData  ณ  21/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria radio para as respostas multipla escolha                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Array com as respostas                               			บฑฑ
ฑฑบ          ณExpA2: Array com as coordenadas para criacao dos objetos.   			บฑฑ 
ฑฑบ          ณExpO1: Objeto Scroll das respostas.                                   บฑฑ 
ฑฑบ          ณExpA3: Array com os controles das perguntas e respostas.              บฑฑ 
ฑฑบ          ณExpA4: Array om as informacoes dos Memos.                             บฑฑ 
ฑฑบ          ณExpN1: Controle do laco das questoes.                                 บฑฑ 
ฑฑบ          ณExpN2: Opcao de menu selecionada                                      บฑฑ 
ฑฑบ          ณExpC1: Codigo para busca de informacoes.(proveniente do atendimento)  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAP8 - Agenda do Operador                                              บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Tk380Radio(	aResposta	,aCoord		,aScroll	,aControl	,;
							aMemos		,nItems		,nOpc		,cCodigo	,;
							oTree		,aTreeXPanel,aMRes)
							
Local oRadio					//Objeto RADIO da resposta
Local nWidth	:= 0			//Tamanho da largura do objeto
Local bVar						//Execblock	
Local bVarMemo
Local cControl  := ""
Local cIDResp	:= aResposta[1][2]
Local aIdResp 	:= aClone(aResposta)
Local bItem     := {|| Tk380Search(cIdResp,aIdResp,"R",0,nOpc,cCodigo,NIL,oRadio:nOption) }
Local nTop		:= aCoord[1]	//Coordenada linha superior
Local nVal		:= 0 			//Variavel auxiliara para Ascan
Local oMemoY 					//Objetos Memo para as respostas
Local cMemoY	:= ""			//Variavel dos objetos Memo para as respostas.
Local bBlockTree :={||}
Local cChave
Local aIdMemo	:= {}			// Array com os Ids de Memo
Local nCont		:= 0			// Variavel auxiliar

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona o objeto no array de controle			  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ1 - Id da Pergunta															    ณ
ณ2 - Id da Resposta															    ณ
ณ3 - Conteudo do Checkbox (.T. ou .F.)											    ณ
ณ4 - Numero da Opcao do Radio Selecionado										    ณ
ณ5 - Texto da resposta dissertativa												    ณ
ณ6 - Texto do get de Complemento de Resposta										    ณ
ณ7 - Tipo de objeto (C - Checkbox, R - Radiobutton M - Memo)						    ณ
ณ																			    ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/    
cChave	:= aResposta[1,3]
AAdd(aControl,{ cChave ,; //para todas as respostas o ID da pergunta eh o mesmo.
				NIL,;
				NIL,;
				NIL,;
				Space(255),;
				NIL,;
				"R"})

For nCont := 1 TO LEN(aResposta)
	Aadd(aIdMemo,(MSMM(aResposta[nCont][5],If( ((TamSx3("UP_OBS")[1]) < 80 ),80 , TamSx3("UP_OBS")[1])) + CRLF + CRLF ))
Next nCont

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica o tamanho da string para ajusta-la		  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AEval(aResposta,{|x| x := Alltrim(x[4]),nWidth:= MAX(GetTextWidth(0,x)/1.5,nWidth)})
nWidth   := If(nWidth > 200,200,nWidth)

aControl[Len(aControl)][4]:= Tk380Search(cIdResp,aIdResp,"R",0,nOpc,cCodigo,NIL,NIL)
cControl := AllTrim(Str(Len(aControl)))

bVar     := &( "{|x|If(ValType(x)=='U',aControl["+cControl+"][4],aControl["+cControl+"][4]:=x) }" )

If  oTree <> Nil
	bBlockTree  := &( "{||Tk380ChgCt(oTree,cChave,aControl["+cControl+"],aTreeXPanel)}")
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria um radiobutton para cada resposta da pergunta ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*
[ <oRadMenu> := ] TRadMenu():New(<nRow>, <nCol>, {<cItems>},;
								 [bSETGET(<nVar>)], <oWnd>, [{<nHelpId>}], <{uChange}>,;
								 <nClrFore>, <nClrBack>, <cMsg>, <.update.>, <{uWhen}>,;
								 <nWidth>, <nHeight>, <{uValid}>, <.lDesign.>, <.lLook3d.>, <.lPixel.> )
*/                             

@0,0 MSPANEL oPanelRadio SIZE 100,Len(aResposta)*10 OF aScroll[nItems]
oPanelRadio:Align := CONTROL_ALIGN_TOP

oRadio:= TRadMenu():New( 	0, 0, aResposta,;
							bVar, oPanelRadio , NIL, {||bItem,;
							IIf(oRadio:nOption<>0,aMRes[nItems,2]:=aIdMemo[oRadio:nOption],aMRes[nItems,2]:=""),aMRes[nItems,1]:Refresh()},;
							CLR_BLUE, NIL, NIL, .F., NIL,;
							nWidth+20,10, Nil, .F., .T., .T. )          
							                                        
oRadio:bWhen:= {|| If(nOpc == 2,.F.,.T.)}
oRadio:bChange 	:= {|| If(Ascan(aResposta,{|x| ALLTRIM(x) == UPPER(STR0021)}) > 0,;		//"RESPOSTA ABERTA"
							If(Ascan(aResposta,{|x| ALLTRIM(x) == UPPER(STR0021)}) == oRadio:nOption,; //"RESPOSTA ABERTA"
								(oMemoY:Enable(),oMemoY:SetFocus()),;
							oMemoY:Disable()),;
                        	""),Eval(bBlockTree),;
                        	IIf(oRadio:nOption<>0,aMRes[nItems,2]:=aIdMemo[oRadio:nOption],aMRes[nItems,2]:=""),aMRes[nItems,1]:Refresh()}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAjusta o TOP do proximo objeto.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCoord[1] += 10

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria o objeto MEMO quando a descricao for "RESPOSTA ABERTA"ณ
//ณNesse memo quando houver uma alteracao da descricao o ARRAYณ
//ณsera atualizado na 5 posicao - Resposta Dissertativa       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se nas respostas do Panel existe a descricao RESPOSTA ABERTA.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nVal := Ascan(aResposta,{|x| ALLTRIM(x) == UPPER(STR0021)})  			//"RESPOSTA ABERTA"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria um memo de resposta aberta para cada painel.		     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

@ aCoord[1]+(Len(aResposta)*10), 10 GET oMemoY VAR cMemoY OF aScroll[nItems] MULTILINE  SIZE 250, 40 PIXEL
oMemoY:bSETGET := &( "{|x|If(ValType(x)=='U',aControl["+cControl+"][5],aControl["+cControl+"][5]:=x) }" )
oMemoY:Align:=CONTROL_ALIGN_TOP
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso exista resposta aberta, apresenta objeto memo. 			 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nVal > 0  	
	oMemoY:Show()
Else
	oMemoY:Hide()
Endif

Return(.T.)                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk380Search     ณ  AutorณVendas Clientes         ณData  ณ  03/04/01   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os valores das respostas dadas pelo cliente                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA061 - Agenda do Operador                                       	บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380Search(cIdResp,xIdAnswer,cTipo,cDefault,nOpc,cCodigo,aIdMemo,nPos)

Local xRet  := cDefault
Local nItem := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLe da base as respostas dadas quando nao for inclusaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SUK")
DbSetOrder(1)
If MsSeek(xFilial("SUK") + cCodigo)
	While !Eof() .AND. (xFilial("SUK") == SUK->UK_FILIAL) .AND. (cCodigo == SUK->UK_CODIGO)
		
		If (SUK->UK_CODPERG == cIdResp)
			Do Case
				Case (cTipo == "C")
					If (SUK->UK_CODRESP == xIdAnswer)
						xRet:= .T.
					Endif
					
				Case (cTipo == "R")
					For nItem:= 1 to Len(xIdAnswer)
						If (SUK->UK_CODRESP == xIdAnswer[nItem][2])
							xRet:= nItem
							Exit
						Endif
					Next
					
				Case (cTipo == "M")
					xRet:= MSMM(SUK->UK_CODMEMO,TamSX3("UK_RESMEMO")[1])
					
				Case (cTipo == "G")
					xRet:= SUK->UK_COMPRES
					
			EndCase
			
			Exit
		Endif
		
		SUK->(DbSkip())
	End
Endif

Return(xRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380Check      ณ  AutorณVendas Clientes         ณData  ณ  21/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria CheckBox para as respsotas do tipo multipla escolha.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Array com as respostas                               			บฑฑ
ฑฑบ          ณExpN1: Indica linha inicial para criacao do objeto.         			บฑฑ 
ฑฑบ          ณExpO1: Objeto Scroll das respostas.                                   บฑฑ 
ฑฑบ          ณExpA2: Array com os controles das perguntas e respostas.              บฑฑ 
ฑฑบ          ณExpC1: Identificacao da resposta                                      บฑฑ 
ฑฑบ          ณExpA4: Array com as coordenadas para objeto                           บฑฑ 
ฑฑบ          ณExpN2: Opcao de menu selecionada                                      บฑฑ 
ฑฑบ          ณExpC1: Codigo para busca de informacoes.(proveniente do atendimento)  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAP8 - Agenda do Operador                                              บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function Tk380Check(	aResposta	,nTop		,aScroll	,aControl,;
							cIdResp		,aCoord		,nOpc		,cCodigo,;
							nItems		,nResposta	,oTree		,aTreeXPanel)


Local oCheck              										// Objeto de CHEKBOX
Local oGet														// Objeto para o GET
Local bVar                 										// Execblock
Local cControl  := ""											// Variavel auxiliar para controle de posicao dos objetos na tela
Local bWhen     := {|| If(nOpc == 2,.F.,.T.)}  				// Desabilita na Visualizacao
Local cIdAnswer := ""											// Codigo da Resposta - Codigo do Cargo (TREE)
Local cAnswer   := ""											// Descricao da Resposta
Local nHeight   := 0											// Calculo da ALTURA
Local nWidth	:= 0 											// Calcula a largura
Local nTopAsk   := 0                            				// Calculo do TOP
Local nString   := 0											// Contador 
Local aString   := {}
Local bBlockTree :={||}
Static oPanelCheck

cIdAnswer:= aResposta[2]										//Codigo do Cargo (TREE)
cAnswer	 := AllTrim(aResposta[4])								//Descricao da Resposta
nHeight  := Tk380CalcHeight(cAnswer,@aString,aCoord[4]-5)
nWidth   := Tk380CalcWidth(cAnswer,aCoord[4]-5)
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona o objeto no array de controle.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aControl,{	cIdResp		,;		// 01
				cIdAnswer	,;		// 02
				NIL			,;		// 03
				NIL			,;		// 04
				NIL			,;		// 05
				SPACE(40)	,;		// 06
				"C" 	} )			// 07

cControl := AllTrim(Str(Len(aControl)))

aControl[Len(aControl)][3]:= Tk380Search(cIdResp,cIdAnswer,"C",.F.,nOpc,cCodigo)

bVar     	:= &( "{|x|If(ValType(x)=='U',aControl["+cControl+"][3],aControl["+cControl+"][3]:=x) }" )
If  oTree <> Nil
	bBlockTree  := &( "{||Tk380ChgCt(oTree,cIdAnswer,aControl["+cControl+"],aTreeXPanel)}")
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontar o Panel somente na primeira vez (Alternativa)ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nResposta=1
	@0,0 MSPANEL oPanelCheck SIZE 300,Len(aResposta)*40 OF aScroll[nItems]
	oPanelCheck:Align := CONTROL_ALIGN_TOP
Endif	


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria um checkbox para cada resposta da pergunta.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/* 

[ <oCbx> := ] TCheckBox():New(  <nRow>, <nCol>, <cCaption>,;
									[bSETGET(<lVar>)], <oWnd>, <nWidth>, <nHeight>, <nHelpId>,;  //Largura Altura
									[<{uClick}>], <oFont>, <{ValidFunc}>, <nClrFore>, <nClrBack>,;
									<.design.>, <.pixel.>, <cMsg>, <.update.>, <{WhenFunc}> )
*/


oCheck   := TCheckBox():New(	nTop, 10, aString[1],;
								bVar, oPanelCheck, nWidth, 10, NIL,;
								bBlockTree, NIL, NIL, CLR_BLUE, NIL,;
								.T., .T., NIL, .F., bWhen )
oCheck:Align := CONTROL_ALIGN_TOP

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe a RESPOSTA for muito grande, quebra em varias linha ณ
//ณutilizando-se do Checbox para a primeira linha e do Sayณ
//ณpara as outras linhas.                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nTopAsk:= nTop
For nString:= 2 To Len(aString)

	nTopAsk += 10
	Tk380Pergunta(aString[nString],aScroll,nTopAsk,20)

Next nString
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria um get para as respostas complementares.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aControl[Len(aControl)][6] := Tk380Search(	cIdResp	,cIdAnswer	,"G"	,Space(TamSX3("UK_COMPRES")[1])	,;
											nOpc	,cCodigo)
											
bVar:= &( "{|x|If(ValType(x)=='U',aControl["+cControl+"][6],aControl["+cControl+"][6]:=x) }" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o parametro para complemento de resposta existir e for ณ
//ณverdadeiro cria o get para complemento de respostas.      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


If aResposta[8] == "1" // Sim

/*
 [ <oGet> := ] TGet():New( 	<nRow>, <nCol>, bSETGET(<uVar>),;
							[<oWnd>], <nWidth>, <nHeight>, <cPict>, <{ValidFunc}>,;
							<nClrFore>, <nClrBack>, <oFont>, <.design.>,;
							<oCursor>, <.pixel.>, <cMsg>, <.update.>, <{uWhen}>,;
							<.lCenter.>, <.lRight.>,[\{|nKey, nFlags, Self| <uChange>\}], <.readonly.>,;
							<.pass.>, [<.lNoBorder.>], <nHelpId> )
*/


	oGet:= TGet():New( 	nTop, nWidth + 20, bVar,;
  						oPanelCheck, TamSX3("UK_COMPRES")[1], 6, "@!", NIL,;		//aScroll[nItems]
						NIL, NIL, NIL, .F.,;
						NIL, .T., NIL, .F., bWhen,;
	 					.F., .F., NIL, .F., .F., NIL, NIL)
	oGet:Align := CONTROL_ALIGN_TOP
Endif


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAjusta o Top do proximo objeto.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nTop+= nHeight

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380Memo       ณ  AutorณVendas Clientes         ณData  ณ  21/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria memo para resposta dissertativa.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Array com as coordenadas para o objeto.              			บฑฑ
ฑฑบ          ณExpN1: Indica linha inicial para criacao do objeto.         			บฑฑ 
ฑฑบ          ณExpA2: Array com os controles das perguntas e respostas.              บฑฑ 
ฑฑบ          ณExpC1: Identificacao da resposta                                      บฑฑ 
ฑฑบ          ณExpN2: Opcao de menu selecionada                                      บฑฑ 
ฑฑบ          ณExpC2: Codigo para busca de informacoes.(proveniente do atendimento)  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAP8 - Agenda do Operador                                              บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Tk380Memo(aCoord,aScroll,aControl,cIdResp,nOpc,cCodigo,nItems) 

Local oMemoX									//Objeto MEMO
Local bVar										//Execblock
Local cControl 	:= "" 
Local nWidth	:= 0
Local nHeigth	:= 0		
Local bWhen	  	:= {|| If(nOpc == 2,.F.,.T.)} 	//Desabilita na visualizacao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona o objeto no array de controle.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aControl,{cIdResp,NIL,NIL,NIL,Space(255),NIL,"M"})

nWidth   := aCoord[4]-5
nHeigth  := aCoord[3] - aCoord[1]-5
cControl := AllTrim(Str(Len(aControl)))
aControl[Len(aControl)][5]:= Tk380Search(cIdResp,NIL,"M","",nOpc,cCodigo)
bVar     := &( "{|x|If(ValType(x)=='U',aControl["+cControl+"][5],aControl["+cControl+"][5]:=x) }" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria um memo para que possa ser armazenado a resposta dada  pelo   ณ
//ณcliente, ja que esta pergunta nใo possui respostas pre-formatadas  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*   [ <oGet> := ] TMultiGet():New( <nRow>, <nCol>, bSETGET(<uVar>),;
									[<oWnd>], <nWidth>, <nHeight>, <oFont>, <.hscroll.>,;
									<nClrFore>, <nClrBack>, <oCursor>, <.pixel.>,;
									<cMsg>, <.update.>, <{uWhen}>, <.lCenter.>,;
									<.lRight.>, <.readonly.>, <{uValid}>,;
									[\{|nKey, nFlags, Self| <uChange>\}], <.lDesign.>,;
									[<.lNoBorder.>], [<.lNoVScroll.>] )
								
*/

oMemoX := TMultiGet():New( 	aCoord[1], aCoord[2], bVar,;
							aScroll[nItems], 280,30, NIL, .F.,;
							NIL, NIL, NIL, .T.,;
							NIL, .F., bWhen, .F.,;
							.F., NIL, NIL,;
							NIL, .F., NIL, NIL)
oMemoX:Align := CONTROL_ALIGN_TOP
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk380CalcHeight ณ  AutorณVendas Clientes         ณData  ณ  03/04/01   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula a altura dos objetos do script                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA380 - Agenda do Operador                                       	บฑฑ
ฑฑฬออออออออออหออออออออหออออออหออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ        ณ      ณ                                            	     	บฑฑ
ฑฑศออออออออออสออออออออสออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380CalcHeight(cCaption,aString,nWidthArea)

Local nHeight:= 0		//ALTURA
Local nWidth := 0		//LARGURA
Local nTam   := 0		//TAMANHO
Local cAux   := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalcula a altura dos objetos a serem criados para o script de pesquisaณ 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nWidth:= GetTextWidth(0,cCaption)
nWidthArea+= (nWidthArea * 1.5)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o tamanho da string for maior que o tamanho maximo permitido, quebra a string em varias linhas ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (nWidth > nWidthArea)

	For nTam:= 1 To Len(cCaption)
		cAux+= SubStr(cCaption,nTam,1)
		
		If (GetTextWidth(0,cAux) >= nWidthArea)
			Aadd(aString,cAux)
			cAux:= ""
		Endif
	Next nTam
	
	Aadd(aString,cAux)
	nHeight:= 10 * Len(aString)
Else
	Aadd(aString,cCaption)
	nHeight:= 10
Endif

Return(nHeight)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk380CalcWidth  ณ  AutorณVendas Clientes         ณData  ณ  03/04/01   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula a largura dos objetos do script                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA380 - Agenda do Operador                                       	บฑฑ
ฑฑฬออออออออออหออออออออหออออออหออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ        ณ      ณ                                            	     	บฑฑ
ฑฑศออออออออออสออออออออสออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380CalcWidth(cCaption,nWidthArea)

Local nWidth := 0		//LARGURA

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalcula a altura dos objetos a serem criados para o script de pesquisa ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nWidth	:= GetTextWidth(0,cCaption)   
nWidthArea += (nWidthArea * 4)

If nWidth > nWidthArea
	nWidth	:= nWidthArea
Else
	nWidth	:= nWidth	
Endif

Return(nWidth)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380MemResบAutor ณVendas Clientes     บ Data ณ  21/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria objetos com o memo das respostas.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Array com as perguntas                    			  บฑฑ
ฑฑบ          ณExpA2: Array com as coordenadas para objetos                บฑฑ 
ฑฑบ          ณExpO1: Objeto Scroll onde estaao os detalhes da resposta    บฑฑ 
ฑฑบ          ณExpN1: Identifica qual a questao trabalhada                 บฑฑ 
ฑฑบ          ณExpA3: Array com os objetos Memo                            บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8 Agenda do Operador                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380MemRes(aPerg,aScroll,nCont,aMRes,oFont2)		

Local nX		:= 0 // Contador para for.

@ 0,0 GET aMRes[nCont,1] VAR aMRes[nCont,2] MEMO SIZE 280,30 FONT oFont2 READONLY OF aScroll[nCont] PIXEL 
aMRes[nCont,1]:Align := CONTROL_ALIGN_TOP

Return .T.
                                                                                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380NExt	 บAutor ณVendas Clientes     บ Data ณ  21/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAvanca para o painel correto.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Array com as perguntas                    			  บฑฑ
ฑฑบ          ณExpC2: Formato do Script                                    บฑฑ 
ฑฑบ          ณExpO3: Objeto Wizard.    									  บฑฑ 
ฑฑบ          ณExpA4: Array com os controles das perguntas e respostas	  บฑฑ 
ฑฑบ          ณExpN5: Controle do ultimo painel          	              บฑฑ 
ฑฑบ          ณExpO6: Objeto Memo do resumo.                               บฑฑ 
ฑฑบ          ณExpC7: Texto para resumo.                                   บฑฑ 
ฑฑบ          ณExpC8: Controle do Score                                    บฑฑ 
ฑฑบ          ณExpC9: Texto fixo para atualizacao do header dos paineis    บฑฑ 
ฑฑบ          ณExpA10: Score por tela navegada para o tipo Atendimento     บฑฑ
ฑฑบ          ณExpA11: Array de Score por tela navegada para o tipo 		  บฑฑ 
ฑฑบ          ณ		 atendimento                                  		  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8 Agenda do Operador                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380Next(	aPerguntas	,cFormato	,oWizard	,aControl	,;
							nLastPanel	,oMemoFim	,cMemoFim	,cScore		,;
							cFixHeader	,aPanelScore)
Local nPos    		:= 0 		
Local cSup    		:= ""
Local nControl		:= 0		//Contador
Local nOpcao  		:= 0
Local nItem	  		:= 1
Local nPanel  		:= oWizard:nPanel
Local lEncontrou	:= .F.
Local lRet			:= .T.
Local lFinaliza		:= .F. 
Local nScan			:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica qual o proximo panel a ser exibido.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (cFormato <> "2")

	For nControl:= 1 To Len(aControl)//Array de controle dos itens das respostas

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPesquisa em todas as perguntas a resposta efetuada atrav้s do ID que define a amarracao(aControl[X][1] )         ณ
		//ณPesquisa com base no panel (aControl[nPanel][1]) ja que os panels possuem a mesma ordem de criacao das perguntas.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
		nPos:= Ascan(aPerguntas,{|aVal| aVal[nControl][2]== aControl[nPanel][1]})  
		If (nPos > 0)
			nOpcao:= aControl[nPos][4]
			Exit
		Endif

	Next nControl
	
	If (nOpcao > 0 )
	
		cSup  := aPerguntas[nPanel][2][nOpcao][2]
	
	
		For nItem:= 1 To Len(aPerguntas)
        	
			If (aPerguntas[nItem][1][3] == cSup)
				If nItem = Len(aPerguntas)
					nLastPanel := nItem
					lFinaliza := .T.
				Endif
				oWizard:nPanel:= nItem-1
				lEncontrou := .T.
				Exit
			Endif

		Next nItem
	
		If !lEncontrou
			nLastPanel:=nPanel
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณNao troca de painel e habilita o botao finalizar.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oWizard:nPanel:= Len(aPerguntas)
			lFinaliza := .T.
		Endif

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCalculo do Scoreณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nControl:= 1 To Len(aControl)//Array de controle dos itens das respostas

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPesquisa em todas as perguntas a resposta efetuada atrav้s do ID que define a amarracao(aControl[X][1] )         ณ
			//ณPesquisa com base no panel (aControl[nPanel][1]) ja que os panels possuem a mesma ordem de criacao das perguntas.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
			If aControl[nControl][1] == aPerguntas[nPanel][1][2]// encontrou a  Pergunta
	
				
				If aControl[nControl][7] == 'R'                 
				    If aControl[nControl][4]>0
						cScore := cScore+aPerguntas[nPanel][2][ aControl[nControl][4] ][6]
						AAdd(aPanelScore,{aPerguntas[nPanel][2][ aControl[nControl][4] ][6],aPerguntas[nPanel][1][2]})
						Exit
					Endif	
				Endif
			Endif	
		Next nControl	
        
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAltera texto do header do wizard para alteracao do score.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oWizard:SetHeader(cFixHeader+TRANSFORM(cScore,"999999"),nItem,.T.)			
	Else
		Help(" ",1,"TMK380NITE") //MsgInfo("Selecione uma resposta para prosseguir com o Script.")
		oWizard:nPanel:=oWizard:nPanel-1
	Endif	
Else	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza controle para funcao Tk380Prevณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nLastPanel :=  nPanel
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalculo do Scoreณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nControl:= 1 To Len(aControl)//Array de controle dos itens das respostas

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPesquisa em todas as perguntas a resposta efetuada atrav้s do ID que define a amarracao(aControl[X][1] )         ณ
		//ณPesquisa com base no panel (aControl[nPanel][1]) ja que os panels possuem a mesma ordem de criacao das perguntas.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
		If aControl[nControl][1] == aPerguntas[nPanel][1][2]// encontrou a  Pergunta
		
			If aControl[nControl][7] == 'R'                 
			    If aControl[nControl][4]>0
					cScore := cScore+aPerguntas[nPanel][2][ aControl[nControl][4] ][6]
					Exit
				Endif	
			Endif

			If aControl[nControl][7] == 'C'                 
			    If aControl[nControl][3]
					nScan := Ascan(aPerguntas[nPanel][2],{|aVal| aVal[2]== aControl[nControl][2]})  
					cScore := cScore+aPerguntas[nPanel][2][ nScan ][6]
				Endif
			Endif
		Endif
	Next nControl

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAltera texto do header do wizard para alteracao do score.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู       
	oWizard:SetHeader(cFixHeader+TRANSFORM(cScore,"999999"),nPanel+1,.T.) 	
	         
	                               
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPonto de entrada para validar respostas do Script Dinโmico
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
	
	If ExistBlock("TK380VLD")
		lRet := ExecBlock("TK380VLD",.F.,.F.,{cFormato,nPanel,aControl,aPerguntas})
	Endif

	If nPanel=Len(aPerguntas)
		lFinaliza := .T.
	Endif
Endif

If lFinaliza
	Tk380InfEnd(@oMemoFim,@cMemoFim,aPerguntas,aControl,cFormato, aPanelScore)
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380Prev  	  ณ  AutorณVendas Clientes         ณData  ณ  03/04/01   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe o panel anterior que conterao os objetos do script              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Array com as perguntas                    					    บฑฑ
ฑฑบ          ณExpC2: Formato do Script                                   		    บฑฑ 
ฑฑบ          ณExpO3: Objeto Wizard.    									 		    บฑฑ 
ฑฑบ          ณExpA4: Array de controle da perguntas e respostas  				    บฑฑ 
ฑฑบ          ณExpN5: Controle do ultimo painel          	             			บฑฑ 
ฑฑบ          ณExpC6: Controle do Score                                  			บฑฑ
ฑฑบ          ณExpA7: Array de Score por tela navegada para o tipo Atendimento 		บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAp8 - Agenda do Operador                                           	บฑฑ
ฑฑศออออออออออสออออออออสออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380Prev(aPerguntas,	cFormato,	oWizard,	aControl,;
 						  nLastPanel,	cScore,		aPanelScore)

Local nPos 		:= 0
Local cSup 		:= ""
Local nItem		:= 0
Local nPanel	:= oWizard:nPanel
Local nScCont   := 0 
Local nControl  := 0

If (cFormato = "2")
	//Formato Pesquisa
	For nScCont := 1 To Len(aControl)
		If aPerguntas[nPanel-1][1][2] == aControl[nScCont][1]
			If aControl[nScCont][7] == 'R'                 
		    	If aControl[nScCont][4]>0
					cScore := cScore-aPerguntas[nPanel-1][2][ aControl[nScCont][4] ][6]
					Exit
				Endif	
			Endif
			If aControl[nScCont][7] == 'C'                 
		    	If aControl[nScCont][3]
					nScan := Ascan(aPerguntas[nPanel-1][2],{|aVal| aVal[2]== aControl[nScCont][2]})  
					cScore := cScore-aPerguntas[nPanel-1][2][ nScan ][6]
				Endif
			Endif
		Endif	
	Next nScCont
Else                  
	//Formato Atendimento	      
	If nPanel == (Len(aPerguntas)+1)			
		oWizard:nPanel:= nlastPanel+1 
		If Len(aPanelScore) > 0
			cScore -= aPanelScore[Len(aPanelScore)][1]
		Endif 
	Else   

		cSup  := aPerguntas[nPanel][1][3]		
		For nItem:= 1 To Len(aPerguntas)		
			nPos:= Ascan(aPerguntas[nItem][2],{|aVal| aVal[2] == cSup})
			If (nPos > 0)
				oWizard:nPanel:= nItem+1
				Exit
			Endif			
		Next nItem	
		If Len(aPanelScore) > 0
			cScore -= aPanelScore[Len(aPanelScore)][1] 
		Endif
	Endif 
	//Retira o ๚ultimo elemento do array
	If Len(aPanelScore) > 0
		ASize(aPanelScore,Len(aPanelScore)-1)
	Endif	 
Endif

	
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380InfEnd	  ณ  AutorณVendas Clientes         ณData  ณ  03/04/01   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega as informacoes do script no painel final.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1: Objeto Memo do resumo.                    					    บฑฑ
ฑฑบ          ณExpC2: Texto do resumo final.                              		    บฑฑ 
ฑฑบ          ณExpO3: Array com as perguntas e respostas                             บฑฑ 
ฑฑบ          ณExpA4: Array de controle da perguntas e respostas  				    บฑฑ 
ฑฑบ          ณExpC5: Formato do Script Dinamico                         			บฑฑ 
ฑฑบ          ณExpA6: Array de Score por tela navegada para o tipo Atendimento 		บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAp8 - Agenda do Operador                                           	บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380InfEnd(	oMemoFim	,cMemoFim	,aPerguntas	,aControl,;
								cFormato	,aPanelScore)

Local nCont 		:= 0				// Contador auxiliar para o FOR
Local nControl  	:= 0      			// Contador auxiliar para os controles de objetos
Local nCol			:= 10				// Alinhamento da Coluna
Local nColR			:= 20				// Alinhamento da Coluna Direita
Local nX			:= 0				// Contador de colunas
Local nY			:= 0				// Contador de linhas
Local nAuxFor   	:= 0				// Contador para o FOR de objetos
Local nAuxPer		:= 0				// Contador para o FOR de perguntas
Local nPosaControl	:= 0       			// Posicao do campo no Array de controle dos itens das respostas
Local cIdRespAnt	:= ""

cMemoFim := STR0020 + CRLF+CRLF+CRLF	// Resumo das Informacoes


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o formato do SCRIPT for de DECISAO - para o formato de ATENDIMENTOณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If VAL(cFormato) == DECISAO // "1"
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPercorre os objetos criados dinamicamenteณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nAuxFor := Len(aControl) 
	For nControl := 1 TO nAuxFor
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPercorre as perguntas do SCRIPTณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nAuxPer  := Len(aPerguntas)
		For nCont := 1 TO nAuxPer
			
			If aPerguntas[nCont][1][2] == aControl[nControl][1]
				
				If aControl[nControl][4] > 0 
					//Verifica se a pergunta participou da pesquisa, senao nao imprime no final.
					If AScan(aPanelScore,{|x|x[2] == aPerguntas[nCont][1][2]}) <= 0
						If aControl[nControl][7] == "R"
							aControl[nControl][4] := 0
						EndIf
						Exit
					Endif  
										
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณCarrega as perguntasณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					cMemoFim += Space(nCol) + aPerguntas[nCont][1][4]+CRLF+CRLF
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณSe as perguntas forem diferentes de MEMOณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If aPerguntas[nCont][1][7] <> "M"
						If aControl[nControl][4] > 0
							cMemoFim += Space(nColR)+ aPerguntas[nCont][2][aControl[nControl][4]][4]+CRLF+CRLF
						Endif
						
					Else
						If aControl[nControl][4] > 0
							cMemoFim += Space(nColR)+ aPerguntas[nCont][2][aControl[nControl][4]][5]+CRLF+CRLF
						Endif
					Endif
					
					EXIT
				Endif
			Endif
		Next nCont
		
	Next nControl

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o formato do SCRIPT for de PESQUISA ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Else

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPercorre os objetos criados dinamicamenteณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nAuxFor := Len(aControl)
	For nControl:= 1 TO nAuxFor
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPercorre as perguntas do SCRIPTณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nAuxPer  := Len(aPerguntas)
		For nX := 1 TO nAuxPer
			If (aPerguntas[nX][1][2] == aControl[nControl][1])
				If aControl[nControl][7] <> "C"
					cMemoFim += Space(nCol) + aPerguntas[nX][1][4] + CRLF+CRLF
					Exit
				ElseIf (aControl[nControl][1] <> cIdRespAnt)
					cMemoFim += Space(nCol) + aPerguntas[nX][1][4] + CRLF+CRLF
				EndIf
				cIdRespAnt := aControl[nControl][1]
				Exit
			Endif
		Next nX
		
		If aPerguntas[nX][1][7] == "1" 	// Unica Escolha
			nPosaControl:= aControl[nControl][4]
			If nPosaControl > 0
				cMemoFim += Space(nColR)+ aPerguntas[nX][2][aControl[nControl][4]][4]+CRLF+CRLF
				If AllTrim(aPerguntas[nX][2][aControl[nControl][4]][4]) == "RESPOSTA ABERTA"
					cMemoFim += Space(nColR)+ aControl[nControl][5] +CRLF+CRLF
				EndIf
			Endif	
		ElseiF aPerguntas[nX][1][7] == "2"	// Multipla Escolha

			If aControl[nControl][3]   		// Posicao logica do array que indica se a alternativa foi selecionada              
			
				For nY := 1 To Len(aPerguntas[nX][2])
					If ( aPerguntas[nX][2][nY][2] == aControl[nControl][2] )
						cMemoFim += Space(nColR)+ aPerguntas[nX][2][nY][4]+CRLF+CRLF
					Endif
				Next nY
				
			Endif
			
		ElseiF aPerguntas[nX][1][7] == "3"
			cMemoFim += Space(nColR)+ aControl[nControl][5]+CRLF+CRLF
		Endif                 
		
	Next nAuxFor
	
Endif

oMemoFim:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk380ChgTrบAutor  ณVendas CRM          บ Data ณ  13/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza as perguntas a partir da tree                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto da xTree                                     บฑฑ
ฑฑบ          ณExpC2 - Identificado do elemento da arvore correspondente   บฑฑ
ฑฑบ          ณExpA3 - Array com as respostas do script                    บฑฑ
ฑฑบ          ณExpA4 - Array de amarracao entre o no da tree e o painel    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA380                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380ChgTr(oTree,oWizard,aTreeXPanel,aControl)  

Local cIdPergunta := oTree:GetCargo()
Local nPainel := aScan(aTreeXPanel,{|x| x[2] == cIdPergunta})
Local nPos
Local aTmp := {}
Local cPai
Local nPosPai

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArray aTreeXPanel:                                             ณ
//ณ1 - Numero do painel                                           ณ
//ณ2 - Codigo do Raiz do paiz									  ณ
//ณ3 - Array com o(s) Codigo(s) do No da arvore (filho)           ณ
//ณCaso seja Check Box, senao os dois (pai e filho) sao os mesmos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If nPainel > 0 //Atualizacao da Pergunta
	oWizard:SetPanel(nPainel)
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDetermina o Pai do Noณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nPos 	:= aScan(otree:aCargo,{|x| x[1] == cIdPergunta})
	nPosPai := aScan(otree:anodes,{|x| x[2] == oTree:ANODES[npos][1]})
	cPai 	:= oTree:aCargo[nPosPai][1]
	nPos    := aScan(aTreeXPanel,{|x| x[2] == cPai})
	oWizard:SetPanel(nPos)
	If at("-",cIdPergunta) >0 // Radio
		nPos 	:= aScan(aControl,{|x| x[1] == cPai}) //Determina o primeiro Radio
		nSelec := Val(SubStr(cIdPergunta,at("-",cIdPergunta)+1))
		If nSelec > 0
			If aControl[npos][4] > 0 //Desmarca na tree a opcao antiga
				oTree:ChangeBmp("BPMSEDT4","BPMSEDT4",oTree:aCargo[(nPosPai+aControl[npos][4])][1])
			Endif
			oTree:ChangeBmp("BPMSEDT3","BPMSEDT3",cIdPergunta)
			aControl[npos][4] := nSelec
		Endif
	Else
		aTmp    := aTreeXPanel[nPos][3]
		nPainel := aScan(aTmp,{|x| x == cIdPergunta})
		nPos 	 := aScan(aControl,{|x| x[2] == aTmp[nPainel]})
		If nPos >0
			aControl[nPos][3] := !aControl[nPos][3]
			If aControl[nPos][3]
				oTree:ChangeBmp("BPMSEDT3","BPMSEDT3",cIdPergunta)
			Else
				oTree:ChangeBmp("BPMSEDT4","BPMSEDT4",cIdPergunta)
			Endif
		Endif
	Endif
Endif

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk380ChgCtบAutor  ณVendas CRM          บ Data ณ  13/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualizacao da tree a partir das respostas do usuario       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto da xTree                                     บฑฑ
ฑฑบ          ณExpC2 - Identificado do elemento da arvore correspondente   บฑฑ
ฑฑบ          ณExpA3 - Array com as respostas do script                    บฑฑ
ฑฑบ          ณExpA4 - Array de amarracao entre o no da tree e o painel    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA380                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380ChgCt(oTree,cCargotree,aControl,aTreeXPanel)

Local cResource    
Local nPos
Local nInicio
Local nX 

If ( aControl[7]  == "R") //Radio
	nInicio := aScan(aTreeXPanel,{|x| x[2] == cCargotree})
	nPos := aScan(oTree:aCargo,{|x| x[1] == cCargotree})//Acha o pai
	For nX := 1 to Len(aTreeXPanel[nInicio][3]) 
		oTree:ChangeBmp("BPMSEDT4"  ,"BPMSEDT4"  ,oTree:aCargo[nPos+nX][1])
	Next nX
	nPos += aControl[4]                            
	oTree:ChangeBmp("BPMSEDT3" ,"BPMSEDT3" ,oTree:aCargo[nPos][1],.T.)
ElseIf  ( aControl[7]  == "C") 
	If aControl[3]
		cResource := "BPMSEDT3" 
	Else
		cResource := "BPMSEDT4" 
	Endif                                       
	oTree:BeginUpdate()
	oTree:ChangeBmp(cResource,cResource,cCargotree,.T.)		
	oTree:EndUpdate()
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk380LoadTบAutor  ณVendas CRM          บ Data ณ  13/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarga da arvore(xTree) respeitando as cores dos semaforos   บฑฑ
ฑฑบ          ณpreviamente carregados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto da xTree                                     บฑฑ
ฑฑบ          ณExpA2 - Array com as respostas do script                    บฑฑ
ฑฑบ          ณExpA3 - Array de amarracao entre o no da tree e o painel    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA380                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380LoadT(oTree, aControl, aTreeXPanel)

Local nPos    
    
For nPos := 1 to Len(aControl)
	If aControl[nPos][7]  == "R"
		If aControl[nPos][4] != Nil
			Tk380ChgCt(@oTree, aControl[nPos][1] ,aControl[nPos],@aTreeXPanel)
		Endif
	Else			                                                              
		Tk380ChgCt(@oTree, aControl[nPos][2],aControl[nPos],@aTreeXPanel)
	Endif
Next nPos

Return Nil
