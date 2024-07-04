#INCLUDE "TMKA280A.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280TLC01ºAutor  ³Armando M. Tessaroliº Data ³  16/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Painel de Pendencias Agendadas                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oExplorer - Objeto que contem todos os paineis do pre aten- º±±
±±º          ³            dimento.                                        º±±
±±º          ³nPanel    - numero do painel que esta sendo montado.        º±±
±±º          ³aPanels   - Todos objetos de todos paineis.                 º±±
±±º          ³aMemory   - Vaiaveis de memoria utilizada pelas MSMGET.     º±±
±±º          ³cOperador - Codigo do operador que esta trabalhando.        º±±
±±º          ³aRegCobr  - Array que contem as regras de cobranca.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk280TLC01(oExplorer,nPanel,aPanels,aMemory,cOperador,aRegCobr)

// Definicao de variaveis de manipulacao
Local nRow		:= Int((oExplorer:aPanel[nPanel]:nHeight * .97) / 2)
Local nCol		:= Int((oExplorer:aPanel[nPanel]:nWidth * .985) / 2)
Local aAgenda	:= {}
Local aFollow	:= {}

// Definicao de variaveis para objetos
Local oFonte
Local oSay1
Local oSay2
Local oSay3
Local oLbx
Local oBmp1
Local oBmp2
Local oBmp3
Local oBmp4
Local oFlw01
Local oFlw02
Local oFlw03
Local oFlw04
Local aPDCols :={}
					    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa informacoes do painel de Follow-Up               ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aFollow,{Padr(STR0009,10)+": "	,oFlw01})  //"Contato "
Aadd(aFollow,{Padr(STR0018,10)+": "	,oFlw02})  //"Endereço "
Aadd(aFollow,{Padr(STR0019,10)+": "	,oFlw03})  //"Cidade"
Aadd(aFollow,{Padr(STR0020,10)+": "	,oFlw04})  //"Telefone "

DEFINE FONT oFonte NAME "Arial" SIZE 0,14 BOLD

// Cria o grupo e um título para apresentar os ATENDIMENTOS AGENDADOS.
@ (nRow*.010), (nCol*.010) TO (nRow*.77), nCol OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.015), (nCol*.020) SAY oSay1 PROMPT STR0005 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// " Pendências Agendadas para Hoje"
oSay1:lTransparent := .F.
oSay1:nHeight := 14
oSay1:nWidth  := (Len(STR0005) * 6.2) //" Pendências Agendadas para Hoje"

// Cria o objeto que contara os atendimentos agendados.
@ (nRow*.05),(nCol*.02) LISTBOX oLbx FIELDS;
HEADER	"",;
		STR0006,; //"Cliente"
		STR0007,; //"Loja"
		STR0008,; //"Razão Social"
		STR0009,; //"Contato"
		STR0010,; //"Nome"
		STR0011,; //"Cobrança"
		STR0012,; //"Retorno"
		STR0013; //"Hora"
SIZE (nCol*.97), (nRow*.70) NOSCROLL OF oExplorer:GetPanel(nPanel) PIXEL
Aadd(aPanels, {oLbx, "AOBJ01", .F.} )

oLbx:aColSizes := {8,25,15,130,25,130,30,30,20}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o metodo do botao de atualizacao dos dados do objeto oLbx³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk280SU4(@aAgenda,cOperador,aRegCobr)
oLbx:SetArray(aAgenda)
oLbx:bLine:={||{	aAgenda[oLbx:nAt,1],;
					aAgenda[oLbx:nAt,2],;
					aAgenda[oLbx:nAt,3],;
					aAgenda[oLbx:nAt,4],;
					aAgenda[oLbx:nAt,5],;
					aAgenda[oLbx:nAt,6],;
					aAgenda[oLbx:nAt,7],;
					aAgenda[oLbx:nAt,8],;
					aAgenda[oLbx:nAt,9],;
					aAgenda[oLbx:nAt,10],;
					aAgenda[oLbx:nAt,11],;
					aAgenda[oLbx:nAt,12];
					}}
oLbx:nAt := 1


aPDCols= {"","U6_CODENT","U6_CODENT","A1_NOME",;    
"U6_CONTATO","U5_CONTAT","U6_CODLIG","U6_DATA",;    
"U6_HRINI",	"U6_STATUS","U6_LISTA",	"U6_CODIGO"}

If FATPDActive() .And. FTPDUse(.T.)
	FATPDLoad(Nil,Nil,aPDCols,Nil)
	oLbx:aObfuscatedCols := FATPDColObfuscate(aPDCols) 
	FATPDUnload()
Endif

// Cria um grupo Barra de Status e um rotulo para este grupo
@ (nRow*.780), (nCol*.010) TO nRow, nCol OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.780), (nCol*.020) SAY oSay2 PROMPT STR0014 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// " Barra de Status"
oSay2:lTransparent := .F.
oSay2:nHeight := 14
oSay2:nWidth  := (Len(STR0014) * 6.2) //" Barra de Status"

// Monta um sub grupo dentro de Barra de Status e um titulo para este grupo.
@ (nRow*.820), (nCol*.300) TO (nRow*.98), (nCol*.98) OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.820), (nCol*.340) SAY oSay3 PROMPT STR0015 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// " Follow-up de Cobrança" 
oSay3:lTransparent := .F.
oSay3:nHeight := 14
oSay3:nWidth  := (Len(STR0015) * 6.2) //" Follow-up de Cobrança" 

// Mostra os dados do contato
DEFINE FONT oFonte  NAME "Arial" SIZE 0,14 BOLD
@ (nRow*.850), (nCol*.320) SAY aFollow[01,02] PROMPT aFollow[01,01] OF oExplorer:GetPanel(nPanel) FONT oFonte PIXEL COLOR CLR_BLUE SIZE 250,10
@ (nRow*.880), (nCol*.320) SAY aFollow[02,02] PROMPT aFollow[02,01] OF oExplorer:GetPanel(nPanel) FONT oFonte PIXEL COLOR CLR_BLUE SIZE 250,10 
@ (nRow*.910), (nCol*.320) SAY aFollow[03,02] PROMPT aFollow[03,01] OF oExplorer:GetPanel(nPanel) FONT oFonte PIXEL COLOR CLR_BLUE SIZE 250,10 
@ (nRow*.940), (nCol*.320) SAY aFollow[04,02] PROMPT aFollow[04,01] OF oExplorer:GetPanel(nPanel) FONT oFonte PIXEL COLOR CLR_BLUE SIZE 250,10 

Aadd(aPanels, {aFollow[01,02], "AOBJ02", .F.} )
// Trata a acao na mudanca da linha das pendencias agendadas.  
oLbx:bChange := {||Tk280Follow(aFollow,Eval(oLbx:bLine)[5],Eval(oLbx:bLine)[11],oExplorer:GetPanel(nPanel)),; 
					aPanels[Ascan(aPanels, {|x| x[2]=="BOBJ01"} )][3] := .F.,;
					aPanels[Ascan(aPanels, {|x| x[2]=="COBJ01"} )][3] := .F.,;
					aPanels[Ascan(aPanels, {|x| x[2]=="DOBJ01"} )][3] := .F.;
					}

// Monta o conteudo da LEGENDA
@ (nRow*.820), (nCol*.030) BITMAP oBmp1 RESOURCE "BR_CINZA" NO BORDER SIZE (nCol*.02), (nRow*.025) ADJUST OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.820), (nCol*.065) SAY STR0001 COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// "Novo Pré-Atendimento"

@ (nRow*.860), (nCol*.030) BITMAP oBmp2 RESOURCE "BR_AZUL" NO BORDER SIZE (nCol*.02), (nRow*.025) ADJUST OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.860), (nCol*.065) SAY "Pendência Reagendada" COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// "Pendência Reagendada" STR0002

@ (nRow*.900), (nCol*.030) BITMAP oBmp3 RESOURCE "BR_VERDE" NO BORDER SIZE (nCol*.02), (nRow*.025) ADJUST OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.900), (nCol*.065) SAY STR0003 COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// "Disponível para Contato"

@ (nRow*.940), (nCol*.030) BITMAP oBmp4 RESOURCE "BR_VERMELHO" NO BORDER SIZE (nCol*.02), (nRow*.025) ADJUST OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.940), (nCol*.065) SAY STR0004 COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// "Contato já realizado" 

Return(.T.)        


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280Follow    ºAutor  ³Andrea Farias      ºData³03/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza painel de Follow-Up  com os dados do contato.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1: Array com os dados do contato.                       º±±
±±º          ³ExpC1: Codigo do contato.                                   º±± 
±±º          ³ExpC1: Codigo da lista pendente.                            º±± 
±±º          ³ExpO1: Objeto do painel de Follow-up.                       º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA.                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk280Follow(aFollow,cContato,cLista,oPFollow)

Local aArea	:=GetArea()    	//Salva a area atual
Local nI	:= 0 			//Contador para FOR
Local cTel	:= ""			//Telefone do contato que foi indicado para retornar a ligacao
Local cDDD	:= ""			//DDD do Contato
Local aPDFields     := {"U4_TIPOTEL","U5_FONE","U5_CELULAR","U5_FAX","U5_FCOM1","U5_FCOM2","U5_CONTAT","U5_END","U5_MUN","U5_EST"}

If !Empty(cLista) .AND. !Empty(cContato)
	DbSelectArea("SU4")
	DbSetOrder(1)
	MsSeek(xFilial("SU4")+cLista)

	DbSelectArea("SU5")
	DbSetOrder(1)
	
	If MsSeek(xFilial("SU5")+cContato) 
		cDDD:= 	SU5->U5_DDD 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o tipo de telefone para contato.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
			Case SU4->U4_TIPOTEL == "1" // Residencial
				cTel:= SU5->U5_FONE
			Case SU4->U4_TIPOTEL == "2" // Celular
				cTel:= SU5->U5_CELULAR
			Case SU4->U4_TIPOTEL == "3" // Fax
				cTel:= SU5->U5_FAX
			Case SU4->U4_TIPOTEL == "4" // Comercial 1
				cTel:= SU5->U5_FCOM1
			Case SU4->U4_TIPOTEL == "5" // Comercial 2
				cTel:= SU5->U5_FCOM2
		EndCase
		//Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
		FATPDLoad(/*cUser*/,/*aAlias*/, aPDFields, /*cSource*/)
		aFollow[01,1]:=Padr(STR0009,10)+": "+ FATPDObfuscate(SU5->U5_CONTAT,"U5_CONTAT") //"Contato "
		aFollow[02,1]:=Padr(STR0018,10)+": "+ FATPDObfuscate(SU5->U5_END,"U5_END") 	//"Endereço "
		aFollow[03,1]:=Padr(STR0019,10)+": "+ FATPDObfuscate(Alltrim(SU5->U5_MUN),"U5_MUN")+ "  -  " + FATPDObfuscate(SU5->U5_EST,"U5_EST") 	//"Cidade - Estado "
		aFollow[04,1]:=Padr(STR0020,10)+": "+ cDDD + FATPDObfuscate(cTel,"U4_TIPOTEL")	 	//"Telefone "
		FATPDUnload() //Finaliza load da ultima carga quando não passa parâmetro
	
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa informacoes do painel de Follow-up³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aFollow[01,1]:=Padr(STR0009,10)+": "	//"Contato"
		aFollow[02,1]:=Padr(STR0018,10)+": "	//"Endereço"
		aFollow[03,1]:=Padr(STR0019,10)+": "	//"Cidade - Estado"
		aFollow[04,1]:=Padr(STR0020,10)+": "	//"Telefone"
		
	EndIf	
		
	For nI := 1 To Len(aFollow)
		aFollow[nI][2]:Refresh() 
	Next x
	
	oPFollow:Refresh()

Endif

RestArea(aArea)

Return Nil 

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta função deve utilizada somente após a inicialização das variaveis 
    atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
