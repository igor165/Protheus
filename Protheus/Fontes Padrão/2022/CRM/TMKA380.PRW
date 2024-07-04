#INCLUDE "TMKA380.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"

/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Estrutura do array de aAtividades  ³
  ³                                   ³
  ³Funcao Tmka380c/Tk380CarregaSU4    ³
  ³                                   ³
  ³1- Codigo da Lista de contato.     ³
  ³2- Status da Lista de Contatos     ³
  ³3- Data da Lista                   ³
  ³4- Hora  para execucao da Lista.   ³
  ³5- Nome da Lista.                  ³
  ³6- Operador que trabalhara a lista.³
  ³7- Rotina.                         ³
  ³8- Codigo da ligacao pendente.     ³
  |9- Forma 						  |
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA380   ºAutor  ³Rafael M. Quadrotti º Data ³  01/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Agenda do operador. Marketing Ativo.                        º±±
±±º          ³Funcao principal onde eh criada a tela da agenda do operadorº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K ³06/06/02³710   ³-Notacao e Logica                           º±±
±±ºHenry Fila³22/07/05³811   ³-Declaracao da variavel oLbx para nao causarº±±
±±º          ³        ³      ³ erro quando utilizado a consulta cliente   º±±
±±ºHanna C.  |30/03/07|10    ³Bops 118469 - Alterado o nome dos Bitmaps   ³±±
±±º        	 ³        |      ³definidos pela Engenharia para o Protheus 10³±±
±±ºConrado Q.³03/08/07³10    ³-BOPS 130949: Ajuste de mensagem de ajuda.  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmka380()     	

Local oDlgAgenda									// Principal Dialogo.
Local cCadastro 		:= STR0001 					// Titulo da Dialog //"Agenda do Operador"
Local cU6Status 		:= "0%"						// Status dos itens executados da atividade.
Local cSaudacao		 	:= DiaExtenso(dDatabase) + ", " 	+ StrZero(Day(dDatabase),2) + ;
													" " 	+ AllTrim(MesExtenso(Month(dDatabase))) + ; 
													" " 	+ StrZero(Year(dDatabase),4)
Local oFont 			:= "" 						// Fonte para saudacao.
Local oFont2 			:= "" 						// Fonte para saudacao.
Local oU6Status										// Status dos itens executados da atividade.
Local oCalend1										// Objeto do calendario 1
Local oCalend2										// Objeto do calendario 2
Local oCalend3										// Objeto do calendario 3
Local oPDetalhes									// Objeto para painel de detalhes
Local oScrDet										// Scroll do painel de detalhes.
Local oPPendencia									// Objeto para painel de pendencia
Local oLbx											// Objeto do listbox
Local oObj1											// Primeiro Objeto do painel de detalhes.
Local oObj2
Local oObj3
Local oObj4
Local oObj5
Local oObj6
Local oObj7
Local oObj8
Local oObj9
Local oObj10
Local oObj11
Local oObj12
Local oObj13
Local oObj14
Local oObj15
Local oObj16 										// Decimo Sexto Objeto do painel de detalhes.
Local oBmpA											// Bitmaps da legenda.
Local oBmpV											// Bitmaps da legenda.
Local oBmpVM 										// Bitmaps da legenda.
Local oUOMeta							   			// Meta de campanha para contatos
Local cUOMEta			:= "0"						// Meta de campanha para contatos
Local aAtividades		:= {}						// Array com as atividades do dia (SU4) ListBox.
Local nCol				:= 0						// Controle de coordenadas para a criacao da tela.
Local nRow				:= 0						// Controle de coordenadas para a criacao da tela.
Local nAjust			:= 34						// variável de controle de ajuste do tamanho da Dialog
Local aDet_Panel		:= {}						// Array com as informacoes do Painel de detalhes  
Local aPend_Panel		:= {}						// Array com as informacoes do Painel de pendencia
Local lRet				:= .F.						// Retorno da funcao
Local aPDFields 		:= {"U5_CONTAT","A1_NOME","US_NOME","ACH_RAZAO","U5_END","U5_EST","U5_FONE","U5_FCOM1","U5_CELULAR","U5_EMAIL","U5_MUN"}

// Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao permite a abertura simultanea para o modelo MDI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExcProcess("TMK" + __cUserId)
	Help("  ",1,"TMKPROMDI")
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o usuario da senha esta  no cadastro de operadores³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !TMKOPERADOR()
	Help("  ",1,STR0002) //"OPERADOR"
	Return(lRet)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta o Help.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaHelp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o Operador tiver acesso a TODAS as rotinas ou SOMENTE TELECOBRANCA	³
//³Verifica se o Operador possui regra de selecao e de negociacao			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (TkGetTipoAte() $ "34") // se utilizar telecobranca.
	If Empty(TkPosto(TkOperador(),"U0_REGSEL")) .OR. Empty(TkPosto(TkOperador(),"U0_REGNEG"))
		Help("  ",1,"TK280REGRA")
		Return(lRet)
	Endif
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o Operador realiza atendimento somente RECEPTIVO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If VAL(TkPosto(TkOperador(),"U0_BOUND")) == RECEPTIVO
	Help("  ",1,"TK280ATEND")
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona na agenda e apresenta as listas POR OPERADOR      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU4")
DbSetOrder(5)
DbSeek(xFilial("SU4"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa informacoes do painel de detalhes                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aDet_Panel,{STR0003,oObj1})  	//"Lista de "
AAdd(aDet_Panel,{STR0004,oObj2}) 	//"Entidade: "
AAdd(aDet_Panel,{STR0005,oObj3}) 	//"Rotina: "
AAdd(aDet_Panel,{STR0006,oObj4}) 	//"Campanha: "
AAdd(aDet_Panel,{STR0007,oObj5}) 	//"Script: "
AAdd(aDet_Panel,{STR0008,oObj6})  	//"Evento: "
AAdd(aDet_Panel,{STR0009,oObj7}) 	//"Tipo de Contato: "
AAdd(aDet_Panel,{STR0010,oObj8})   	//"Tipo de Telefone: "
AAdd(aDet_Panel,{STR0011,oObj9})  	//"Tipo de Endereço: "
AAdd(aDet_Panel,{STR0012,oObj10})  	//"Assunto do E-mail: "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa informacoes do painel de pendencias              ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aPend_Panel,{STR0013,oObj11})  //"Contato: "
Aadd(aPend_Panel,{STR0014,oObj12})  //"Cidade: "
Aadd(aPend_Panel,{STR0015,oObj13})  //"Estado: "
Aadd(aPend_Panel,{STR0016,oObj14})  //"Retorno: "
Aadd(aPend_Panel,{STR0017,oObj15})  //"Empresa: "
Aadd(aPend_Panel,{STR0018,oObj16})  //"Data da Pendência: "


// Defines das Fontes utilizadas no codigo.
DEFINE FONT oFont   NAME "Arial" SIZE 0,20 BOLD    
DEFINE FONT oFont2  NAME "Arial" SIZE 0,14 BOLD    

oMainWnd:ReadClientCoors()
nCol := oMainWnd:nClientWidth
nRow := oMainWnd:nClientHeight

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa ao gerenciador de múltiplos grupos de atendimento³
//³que a rotina agenda do operador está em execução.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TK091Start( AGENDAOPERADOR )

//Ajuste do tamanho da Dialog quando o tema for TEMAP10	
If AllTrim(GetTheme()) # "TEMAP10"
	nAjust := 70
Endif  

DEFINE MSDIALOG oDlgAgenda TITLE cCadastro + " - " + TK091Titulo(TkOperador()) FROM 00,00 TO nRow-nAjust,nCol-8 PIXEL

	oDlgAgenda:lMaximized := .T.
	
	@00,00 MSPANEL oPanel1 SIZE 50,50
	
	// Atualiza as coordenadas com as definicoes da dialog para facilitar a criacao dos objetos
	nCol := oDlgAgenda:nClientWidth/2
	nRow := oDlgAgenda:nClientHeight/2
	
	@00,00 MSPANEL oSPanel SIZE 12,12 OF oPanel1
	oSPanel:Align := CONTROL_ALIGN_TOP
	
	// Saudacao da tela de atendimento
	@ 01,03 SAY oSaudacao PROMPT cSaudacao OF oSPanel FONT oFont  PIXEL COLOR CLR_BLUE SIZE 300,10
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a tela estiver em MDI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !SetMDIChild()	
		@00,00 BITMAP oLogo RESOURCE "MDILOGO1" PIXEL OF oSPanel NO BORDER
		oLogo:lAutoSize := .T.
		oLogo:Align := CONTROL_ALIGN_RIGHT
	Endif

	// Status dos itens trabalhados no SU6
	@ 15,03 SAY STR0019    OF oPanel1 FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10	 //"Percentual executado desta Lista:"
	@ 15,CalcFieldSize("C",Len(STR0019),0) SAY oU6Status PROMPT cU6Status OF oPanel1 FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10	

	// Informacoes da campanha.
	@ 15,300 SAY STR0020 OF oPanel1 FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10	 //"Objetivo da Campanha:"
	@ 15,300+CalcFieldSize("C",Len(STR0020),0) SAY oUOMeta PROMPT cUOMeta  OF oPanel1 FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10	
	
	@00,00 SCROLLBOX oScr1 SIZE 50,50
	
	oCalend1:=MsCalend():New(02,02,oScr1)
	oCalend1:Disable()
	oCalend1:Refresh()
	
	oCalend2:=MsCalend():New(02,150,oScr1)
	oCalend2:dDiaAtu := dDataBase
	oCalend2:bChangeMes := {|| Tk380ChgMes(oCalend2:dDiaAtu,oCalend1,oCalend2,oCalend3),;
								oCalend3:dDiaAtu := oCalend2:dDiaAtu+30,;
								oCalend1:dDiaAtu := oCalend2:dDiaAtu-30,;
								oCalend1:Refresh(),;
								oCalend3:Refresh() }

	oCalend2:bChange    := {|| 	aAtividades:=Tk380CarregaSU4(oCalend2:dDiaAtu),;
								ASort(aAtividades,,,{|x,y| DToS(x[3])+x[4] < DToS(y[3])+y[4]}),;
								oLbx:SetArray(aAtividades),;
								oLbx:bLine:={||{Tk380Leg(	aAtividades[oLbx:nAt,2]),;
															aAtividades[oLbx:nAt,3],;
															aAtividades[oLbx:nAt,4],;
															aAtividades[oLbx:nAt,5],;
															aAtividades[oLbx:nAt,6],;
															Tk380RetRot(aAtividades[oLbx:nAt,7])}},;
								Tk380PDetalhes(@aDet_Panel,aAtividades[1],@oPDetalhes)	,;	  // Atualiza o painel de detalhes
								Tk380PPendencia(@aPend_Panel,aAtividades[1],@oPPendencia),;  // Atualiza o painel de pendencias
								Tk380AtuSaudacao(oU6Status,oUOMeta,aAtividades[1]),; // Atualiza os dados do cabecalho.
								oLbx:Refresh(),;
								oCalend3:dDiaAtu := oCalend2:dDiaAtu+30,;
								oCalend1:dDiaAtu := oCalend2:dDiaAtu-30}
	
	oCalend3:=MsCalend():New(02,298,oScr1)
	oCalend3:Disable()
	oCalend3:Refresh()
	
	oCalend3:dDiaAtu := oCalend2:dDiaAtu+30
	oCalend1:dDiaAtu := oCalend2:dDiaAtu-30
	
	//"Selecionando as atividades do dia "	
	Processa({|lEnd|aAtividades := Tk380CarregaSU4(dDataBase)},STR0021 + STRZERO(Day(dDataBase),2)+"/"+STRZERO(Month(dDatabase),2),,.T.)

	/*
	  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Estrutura do array de aAtividades  ³
	  ³                                   ³
	  ³Funcao Tmka380c/Tk380CarregaSU4    ³
	  ³                                   ³
	  ³1- Codigo da Lista de contato.     ³
	  ³2- Status da Lista de Contatos     ³
	  ³3- Data da Lista                   ³
	  ³4- Hora  para execucao da Lista.   ³
	  ³5- Nome da Lista.                  ³
	  ³6- Operador que trabalhara a lista.³
	  ³7- Rotina.                         ³
	  ³8- Codigo da ligacao pendente.     ³
	  |9- Forma 						  |
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/

	ASORT(aAtividades,,,{|x,y| DTOS(x[3])+ x[4] < DTOS(y[3])+y[4]})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tarefas relacionadas a data.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@00,00 LISTBOX oLbx FIELDS ;
			HEADER ;
			" ",;		// 01 - Legenda   
			STR0022,;	// 02 -  //"Data"
			STR0023,;	// 03 -  //"Hora"
			STR0024,;	// 04 -  //"Nome"
			STR0002,;	// 05 -  //"Operador"
			STR0025;	// 06 -  //"Rotina"
			SIZE 100,100 OF oDlgAgenda PIXEL 

			oLbx:SetArray(aAtividades)
			oLbx:bLine:={||{Tk380Leg(	aAtividades[oLbx:nAt,2]),;
										aAtividades[oLbx:nAt,3],;
										aAtividades[oLbx:nAt,4],;
										aAtividades[oLbx:nAt,5],;
										aAtividades[oLbx:nAt,6],;
										Tk380RetRot(aAtividades[oLbx:nAt,7])}}
        	oLbx:bChange := {||	Tk380PDetalhes(@aDet_Panel,aAtividades[oLbx:nAt],@oPDetalhes)	,;	// Atualiza o painel de detalhes
								Tk380PPendencia(@aPend_Panel,aAtividades[oLbx:nAt],@oPPendencia),;	// Atualiza o painel de pendencias
								Tk380AtuSaudacao(oU6Status,oUOMeta,aAtividades[oLbx:nAt])} 			// Atualiza os dados do cabecalho.
			
			oLbx:Refresh()
			oLbx:SetFocus(.T.)
	 		
	@00,00 MSPANEL oPanel2

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Paineis de detalhes.                           ³
	//³Painel 1 - Detalhes da Lista - SU4             ³
	//³Painel 2 - Detalhes de lista de Pendencia - SU4³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//Painel 1
	@ 01,01 TO 70,(nCol/2)-6 LABEL STR0026 OF oPanel2 PIXEL  //'Detalhes da Lista'
	@ 08,03 MSPANEL oPDetalhes  VAR "" OF oPanel2 SIZE (nCol/2)-12,49
	
	@ 0,0 SCROLLBOX oScrDet OF oPDetalhes PIXEL 
	oScrDet:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ 00, 00 SAY aDet_Panel[01,02] PROMPT aDet_Panel[01,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 
	@ 10, 00 SAY aDet_Panel[02,02] PROMPT aDet_Panel[02,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 20, 00 SAY aDet_Panel[03,02] PROMPT aDet_Panel[03,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 30, 00 SAY aDet_Panel[04,02] PROMPT aDet_Panel[04,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 40, 00 SAY aDet_Panel[05,02] PROMPT aDet_Panel[05,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 50, 00 SAY aDet_Panel[06,02] PROMPT aDet_Panel[06,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 60, 00 SAY aDet_Panel[07,02] PROMPT aDet_Panel[07,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 70, 00 SAY aDet_Panel[08,02] PROMPT aDet_Panel[08,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 80, 00 SAY aDet_Panel[09,02] PROMPT aDet_Panel[09,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 90, 00 SAY aDet_Panel[10,02] PROMPT aDet_Panel[10,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
 
	
	//Painel 2
	@ 01,(nCol/2)-3 TO 70,nCol-3 LABEL STR0027 OF oPanel2 PIXEL  //'Detalhes da lista de contato Pendente'
	@ 08,(nCol/2) MSPANEL oPPendencia VAR "" OF oPanel2 SIZE (nCol/2)-6,49

	@ 0,0 SCROLLBOX oScrPend OF oPPendencia PIXEL 
	oScrPend:Align := CONTROL_ALIGN_ALLCLIENT

	@ 00, 00 SAY aPend_Panel[01,02] PROMPT aPend_Panel[01,01] OF oScrPend FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 
	@ 10, 00 SAY aPend_Panel[02,02] PROMPT aPend_Panel[02,01] OF oScrPend FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 20, 00 SAY aPend_Panel[03,02] PROMPT aPend_Panel[03,01] OF oScrPend FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 30, 00 SAY aPend_Panel[04,02] PROMPT aPend_Panel[04,01] OF oScrPend FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 40, 00 SAY aPend_Panel[05,02] PROMPT aPend_Panel[05,01] OF oScrPend FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10	
	@ 50, 00 SAY aPend_Panel[06,02] PROMPT aPend_Panel[06,01] OF oScrPend FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10	

	@00,00 MSPANEL oPanel3

    //Legendas
	@ 01,01 TO 17,nCol-70 LABEL STR0028 OF oPanel3 PIXEL  //'Legendas'
	
	@ 08,03 BITMAP oBmpV ResName "BR_VERMELHO" OF oPanel3 Size 10,10 NoBorder When .F. Pixel 
	@ 08,15 SAY STR0029 OF oPanel3 Color CLR_RED,CLR_WHITE PIXEL   //"Listas não executadas."

	@ 08,80 BITMAP oBmpA ResName "BR_AZUL" OF oPanel3 Size 10,10 NoBorder When .F. Pixel
	@ 08,90 SAY STR0030 OF oPanel3 Color CLR_BLUE,CLR_WHITE PIXEL  	 //"Listas em andamento."

	@ 08,147 BITMAP oBmpVM ResName "BR_VERDE" OF oPanel3 Size 10,10 NoBorder When .F. Pixel
	@ 08,159 SAY STR0104 OF oPanel3 Color CLR_GREEN,CLR_WHITE PIXEL  	 //"Atividade encerrada"


	// Botoes da para execucao das tarefas.
	DEFINE SBUTTON FROM 05,nCol-65 TYPE 1  ;
							ACTION 	(IIF(	!Empty(aAtividades[oLbx:nAt,2]) .AND. Tk380Valido(aAtividades,oLbx:nAt,oCalend2:dDiaAtu),;
											(Tk380ExecLista(aAtividades[oLbx:nAt]),;
											aAtividades := Tk380CarregaSU4(oCalend2:dDiaAtu),;
											ASORT(aAtividades,,,{|x,y| DToS(x[3])+x[4] < DToS(y[3])+y[4]}),;
											oLbx:SetArray(aAtividades),;
											oLbx:bLine:={||{Tk380Leg(	aAtividades[oLbx:nAt,2]),;
																		aAtividades[oLbx:nAt,3],;
																		aAtividades[oLbx:nAt,4],;
																		aAtividades[oLbx:nAt,5],;
																		aAtividades[oLbx:nAt,6],;
																		Tk380RetRot(aAtividades[oLbx:nAt,7])}},;
											Tk380PDetalhes(@aDet_Panel,aAtividades[1],@oPDetalhes)	,;	  // Atualiza o painel de detalhes
											Tk380PPendencia(@aPend_Panel,aAtividades[1],@oPPendencia),;  // Atualiza o painel de pendencias
											Tk380AtuSaudacao(oU6Status,oUOMeta,aAtividades[1]),; 		// Atualiza os dados do cabecalho.
											oLbx:Refresh(),;
											oDlgAgenda:Refresh()),; 
											)) ;
							ENABLE OF oPanel3 PIXEL
											//MsgInfo(STR0105))) ;//"Nao existem listas ou esta lista não pode ser executada. Selecione uma lista valida."
											
	DEFINE SBUTTON FROM 05,nCol-35 TYPE 2 ACTION (TkGrvSUV(__cUserId, ""),oDlgAgenda:End()) ENABLE OF oPanel3 PIXEL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TkGrvSUV(__cUserId, "AGE0")

	FATPDLogUser('TMKA380')	// Log de Acesso LGPD
ACTIVATE MSDIALOG oDlgAgenda ON INIT (	AlignObject(oDlgAgenda,{oPanel1,oScr1,oLbx,oPanel2,oPanel3},1,3,{48,155,,115,36}),;
										Processa({|lEnd|Tk380ChgMes(dDataBase,oCalend1,oCalend2,oCalend3)},STR0032,,.T.) ) //"Selecionando Itens da Lista..."
										
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa ao gerenciador de múltiplos grupos de atendimento ³
//³que a rotina agenda do operador não está mais em execução.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TK091End( AGENDAOPERADOR )

//Finaliza o gerenciamento dos campos com proteção de dados.
FATPDUnLoad() 

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk380AtuCalendºAutor  ³Rafael M. Quadrotti º Data ³23/12/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criacao das marcacoes das tarefas no calendario.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpD1: Data de referencia.                                  º±±
±±º          ³ExpO1: Objeto do calendario.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³06/06/02³710   ³-Revisao do fonte                           º±±
±±º          ³        ³      ³                                            º±±
±±º          ³        ³      ³                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk380AtuCalend(dData,oCalend)

Local dAux1 		:= FirstDay(dData)				// Variavel auxiliar para controle de data.
Local dAux2 		:= LastDay(dData)				// Variavel auxiliar para controle de data.
Local nCont 		:= 0 							// Variavel contador.
Local lMV_TMKPHJ	:= GetNewPar("MV_TMKPHJ",.T.)	// Indica se as pendencias encerradas na database serao exibidas no painel de pendencias agendadas - Default EXIBE

ProcRegua(dAux2-dAux1)
	
DbSelectArea("SU4")
DbSetOrder(3) 			// FILIAL + DATA + STATUS    
MsSeek(xFilial("SU4")+DTOS(dAux1) ,.T.) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se existirem listas encerradas e o parametro que indica a exibicao das listas encerradas      ³
//³estiver .T. elas serao exibidas. Caso contrario (.F.) exibe somente as pendencias em aberto   ³
//³a serem executadas ate hoje. ESSA VALIDACAO ESTA SENDO FEITO PORQUE O WHILE E PARA CODEBASE   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

While 	!EOF() 								.AND. ;
		(xFilial("SU4") == SU4->U4_FILIAL) 	.AND.;
		(SU4->U4_DATA <= dAux2)  .AND. IIF(!lMV_TMKPHJ, SU4->U4_STATUS <> '2',.T.)

    nCont ++
	IncProc( STR0033 + StrZero(nCont,5) ) // "Tarefas do dia "

	oCalend:AddRestri(Day(SU4->U4_DATA),CLR_HRED,CLR_WHITE)
	
	SU4->(DbSkip())
End                           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso a  data recebida for a data base do sistema, ou seja,       ³
//³eh o objeto do calendário atual  efetua a marcacao no calendario.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dData == dDataBase
	oCalend:addRestri(Day(dDataBase),CLR_BLUE,CLR_BLUE)	
Endif 	
	
oCalend:Refresh()
		
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tk380ChgMe³ Autor ³Rafael M. Quadrotti    ³ Data ³ 24/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o calendario. Sabados e Domingos.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1: Data de referencia.                                 ³±±
±±³          ³ ExpO1: Objeto do Calendario1                               ³±±
±±³          ³ ExpO2: Objeto do Calendario2                               ³±±
±±³          ³ ExpO3: Objeto do Calendario3                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Call Center V.811 Agenda do operador.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk380ChgMes(dDtFoco,oCalend1,oCalend2,oCalend3)

Local aArea    := GetArea()						// Salva a area de trabalho.
Local dDataIni := FirstDay(oCalend2:dDiaAtu)	// Retorna o primeiro dia do mes.
Local dDataFim := LastDay(oCalend2:dDiaAtu)		// Retorna o ultimo dia do mes.

CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para apresentação dos fins de semana em cinza.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While ( dDataIni <= dDataFim )
	While ( Dow(dDataIni) == 1 .OR. Dow(dDataIni) == 7 )
		oCalend2:addRestri(Day(dDataIni),CLR_GRAY,CLR_WHITE)
		dDataIni++
	End
	dDataIni++
End
oCalend2:Refresh()                    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualizada as tarefas da agenda.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Calendario Principal
Tk380AtuCalend(dDtFoco,@oCalend2)

// Atualiza Calendario de tarefas do mes posterior
Tk380AtuCalend(LastDay(dDtFoco)+1,@oCalend3)

// Atualiza Calendario de tarefas do mes anterior
Tk380AtuCalend(FirstDay(dDtFoco)-1,@oCalend1)

RestArea(aArea)

CursorArrow()

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk380ValidoºAutor ºRafael M. Quadrotti º Data º  01/20/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se a lista ja foi encerrada e nao permite sua      º±±
±±º          ³visualizacao.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA: Vetor com todas as atividades da Agenda.              º±±
±±º          ³ExpN: Posicao do foco na tarefa.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8 Agenda do Operador                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K ³27/07/04³811   ³-Notacao e Logica                           º±±
±±º          ³        ³      ³                                            º±±
±±º          ³        ³      ³                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk380Valido(aAtividades,nP,dData)

Local lRet 		:= .F.										// Retorno da funcao.
Local cAgPrior  := TkPosto(TkOperador(),"U0_AGPRIOR")		// Prioridade de execucao da agenda.
Local aItemSel	:= aAtividades[nP]  						// Array com as listas de Contato
Local nCont		:= 0										// Contatodor
Local nLenAtiv  := Len(aAtividades)							// Contador com o total de listas
Local dDataLim  := dDataBase
Local lTK380BOK := ExistBlock("TK380BOK")

If aItemSel[2] <> "2" // Encerrada

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a data desta lista e posterior e emite um aviso.                                     ³
	//³Listas com datas posteriores nao poderao ser executadas. Somente visualizadas.                   ³
	//³Na execucao da segunda janela havera uma validacao que bloqueara o acesso aos dados desta lista  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PE para determinar data limite de execucao de listas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("TK380DAT") 
		dDataLim := Execblock("TK380DAT",.F.,.F.,{dData})	
		If dData > dDataLim
			MsgStop(STR0106, STR0107)      //"Listas com datas futuras nao podem ser executadas antes","Data inválida"
			Return(lRet)
		Endif
	Else
		If dData > dDataBase
			MsgStop(STR0106, STR0107)      //"Listas com datas futuras nao podem ser executadas antes","Data inválida"
			Return(lRet)
		Endif
	Endif
	
	If aItemSel[7] == "3"	//TeleCobranca
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica qual o tipo de regra de selecao foi aplicada: Por Lista ou por Grupo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea("SK0")
		DbSetOrder(1)
		MsSeek(xFilial("SK0"))
		If SK0->K0_ORDEM == "000001" .AND. SK0->K0_PRAZO == "999999"
			DbSelectArea("SU4")
			lRet := .T.
		Else
			MsgStop(STR0034,STR0082) //"A regra de seleção não permite a execução de Listas de Cobrança pela Agenda do Operador","Atencao"
		Endif
	Else
		lRet:= .T.
	Endif
Else
	Help(" ",1,"TMK380NACE")	//"Esta Lista ja foi encerrada e nao podera ser visualizada por esta rotina"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a lista pode ser executada avalia qual a prioridade do grupo de atendimento do Operador³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If !Empty(cAgPrior)
		Do Case
			Case cAgPrior == "1" //Lista de contatos pendente

				If Val(aItemSel[9]) <> PENDENCIA
					For nCont := 1 To nLenAtiv
						If Val(aAtividades[	nCont][9]) = PENDENCIA .AND. aAtividades[nCont][2] <> "2" //Encerrada
							If TkHoraComp(Time(), aAtividades[	nCont][4], ">=","")
								lRet := .F.
								Help("  ",1,"TK380PRIO1")//"De acordo com a definição do grupo de atendimento as listas de pendência devem ser executadas antes das outras atividades."
								Exit
							Endif
						Endif
					Next nCont
				Endif

			Case cAgPrior == "2" //Lista de contatos padrao

				If Val(aItemSel[9]) == PENDENCIA
					If TkHoraComp(Time(), aItemSel[4], "<","")
						For nCont := 1 To nLenAtiv
							If Val(aAtividades[	nCont][9]) <> PENDENCIA .AND. aAtividades[nCont][2] <> "2" //Encerrada
								lRet := .F.
								Help("  ",1,"TK380PRIO2")//"De acordo com a definição do grupo de atendimento as listas de contato padrão devem ser executadas antes das outras atividades."
								Exit
							Endif
						Next nCont
					Endif
				Endif

			Case cAgPrior == "3" //Lista de contatos por data.

				For nCont := 1 To nLenAtiv
					If aAtividades[	nCont][3] < aItemSel[3] .AND. aAtividades[nCont][2] <> "2" //Encerrada
						lRet := .F.
						Help("  ",1,"TK380PRIO3")//"De acordo com a definição do grupo de atendimento a ordem de execução das listas de contatos devem seguir a data."
						Exit
					Endif
				Next nCont
		EndCase
	
	Endif
Endif

If lRet .And. lTK380BOK
	lRet := ExecBlock("TK380BOK",.F.,.F.,{aAtividades,nP,dData})
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³AjustaHelp ºAutor ºConrado Q. Gomes    º Data º  03/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajuste de mensagem de ajuda.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Nenhum													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8 Agenda do Operador                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³        ³      ³                                            º±±
±±º          ³        ³      ³                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaHelp()
Local aHlpP	:= {}		// Texto em português
Local aHlpE	:= {}		// Texto em inglês
Local aHlpS   := {}		// Texto em castelhano

aAdd (aHlpP, STR0108)	// "Não existe Midia para esta campanha."
aAdd (aHlpE, STR0108)	// "Não existe Midia para esta campanha."
aAdd (aHlpS, STR0108)	// "Não existe Midia para esta campanha."	
PutHelp("PSEMMIDIA ", aHlpP, aHlpE, aHlpS, .T.)
	
aHelpP	:= {}
aHelpE	:= {}
aHelpS	:= {}

Aadd(aHelpP,"Verifique se todos os campos necessários " )
Aadd(aHelpP,"estão preenchidos corretamente." )
PutHelp("SSEMDADOS",aHelpP,aHelpE,aHelpS,.T.)

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
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

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
/*/{Protheus.doc} FATPDUserAcc
    @description
    Verifica se o usuario logado possui acesso a dados sensiveis e pessoais
    Exibindo mensagem de Help caso usuario não possua acesso.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDUserAcc()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Retorna se Usuario possui acesso a dados protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDUserAcc()

    Local lRet := .T.  

    If FATPDActive()
        lRet := FTPDUserAcc()
    Endif

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

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


