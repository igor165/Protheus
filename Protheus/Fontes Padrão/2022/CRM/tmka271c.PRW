#INCLUDE "TMKA271C.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk271SUWF3ºAutor  ³Vendas CRM          º Data ³  27/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela de pesquisa de scripts x campanha                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk271SUWF3()

Local oDlgSUW																// Tela
Local oLbx1																	// Listbox
Local nPosLbx  := 0															// Posicao do List
Local aItems   := {}														// Array com os itens
Local nPos     := 0															// Posicao no array
Local cCampanha := ""														// Descricao do Assunto
Local lRet     := .F.														// Retorno da funcao
Local nPosAcao := 0

CursorWait()

If "TMKR" $ FunName()	//Chama a consulta padrão, quando for executado através de qualquer relatório personalizável.
	lRet := ConPad1(,,,"ACD")
	Return(lRet)
EndIf

If Empty(M->UC_CODCAMP)														// Nao permite filtrar caso o codigo da campanha nao esteja preenchido
	MsgInfo(STR0001, STR0002) 												 //"Digitar obrigatoriamente o campo Campanha no cabeçalho."###"Atenção"
	CursorArrow()
	Return(lRet)
Endif

nPosAcao := aScan( aHeader, { |x| Alltrim(x[2])=="UD_SOLUCAO" } )	//Posicao do campo de solucao

cCampanha := M->UC_CODCAMP

DbSelectArea("SUQ")
DbSetOrder(1)
If DbSeek(xFilial("SUQ")+aCols[n][nPosAcao])
	
	DbSelectArea("SUW")
	DbSetOrder(2)
	If DbSeek(xFilial("SUW")+cCampanha)
		While SUW->(!Eof()) .AND. (xFilial("SUC") == SUW->UW_FILIAL) .AND. (SUW->UW_CODCAMP == cCampanha)
			
			If !Empty(SUW->UW_CODEVE)
				
				If SUQ->UQ_EVENTO == "3"
					
					DbSelectArea("AG5")
					DbSetOrder(4)
					If DbSeek(xFilial("AG5")+M->UC_CODCONT+SUW->UW_CODEVE)
						_cSeekAg5 := xFilial("AG5")+M->UC_CODCONT+SUW->UW_CODEVE
						While AG5->(!eof()) .AND. AG5->AG5_FILIAL + AG5->AG5_CODCO + AG5->AG5_EVENT == _cSeekAg5
							If AG5->AG5_STRES == "1"
								Aadd(aItems,{	SUW->UW_CODEVE,;														//Codigo do evento
								SUW->UW_DESCEVE,;														//Descricao
								SUW->UW_CODSCRI,;														//Codigo script
								Posicione("SUZ",1,xFilial("SUZ")+SUW->UW_CODSCRI,"UZ_DESC") })			//Titulo script
								Exit
							Endif
							AG5->(dbskip())
						End
					Endif
					
				ElseIf SUQ->UQ_EVENTO == "2"
					DbSelectArea("AG5")
					DbSetOrder(4)
					If !DbSeek( xFilial( "AG5" ) + M->UC_CODCONT + SUW->UW_CODEVE )
						Aadd(aItems,{	SUW->UW_CODEVE,;       											//Codigo do evento
										SUW->UW_DESCEVE,;      											//Descricao
										SUW->UW_CODSCRI,;      											//Codigo script
										Posicione("SUZ",1,xFilial("SUZ")+SUW->UW_CODSCRI,"UZ_DESC") })	//Titulo script
					Endif
					
				ElseIf SUQ->UQ_EVENTO == "1"
					Aadd(aItems,{	SUW->UW_CODEVE,;       //Codigo do evento
					SUW->UW_DESCEVE,;      //Descricao
					SUW->UW_CODSCRI,;      //Codigo script
					Posicione("SUZ",1,xFilial("SUZ")+SUW->UW_CODSCRI,"UZ_DESC") })      //Titulo script
				Endif
				
			Endif
			SUW->(DbSkip())
		End
	else
		MsgStop(STR0003,STR0004)  //"Não existem eventos relacionados a esta Campanha."###"Eventos Inexistentes"
	Endif
Else
	Help(" ",1,"FALTA_ACAO")
Endif

CursorArrow()

If Len(aItems) <= 0
	Help(" ",1,"FALTA_EVEN")
	Return(lRet)
Endif

DEFINE MSDIALOG oDlgSUW FROM  30,003 TO 260,600 TITLE STR0005 PIXEL  //"Eventos Relacionados"

@ 03,10 LISTBOX oLbx1 VAR nPosLbx FIELDS HEADER ;
	STR0006,;  //"Cod.Evento"
	STR0007,;  //"Descriçao"
	STR0008,;  //"Cod.Script"
	STR0009;  //"Título"
	SIZE 283,80 OF oDlgSUW PIXEL NOSCROLL
	oLbx1:SetArray(aItems)
	oLbx1:bLine:={||{aItems[oLbx1:nAt,1],;
	aItems[oLbx1:nAt,2],;
	aItems[oLbx1:nAt,3],;
	aItems[oLbx1:nAt,4] }}
	
oLbx1:BlDblClick := {||(lRet:= .T.,nPos:= oLbx1:nAt, oDlgSUW:End())}
oLbx1:Refresh()

DEFINE SBUTTON FROM 88,175 TYPE 1 ENABLE OF oDlgSUW ACTION (lRet:= .T.,nPos := oLbx1:nAt,oDlgSUW:End())
DEFINE SBUTTON FROM 88,210 TYPE 2 ENABLE OF oDlgSUW ACTION (lRet:= .F.,oDlgSUW:End())

ACTIVATE MSDIALOG oDlgSUW CENTERED

If lRet
	DbSelectArea("SUW")
	DbSetOrder(2)
	If DbSeek(xFilial("SUW")+cCampanha+aItems[nPos][1])
		M->UD_EVENTO := aItems[nPos][1]
	Endif
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	³Tk271ACEF3  ³ Autor ³Vendas CRM             ³ Data ³ 28/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³Carrega tela com as grades do evento selecionado.	           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ TeleMarketing - SX3                              	           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk271ACEF3()

Local oDlgACE														       // Tela
Local oLbx1                                                                // Listbox
Local nPosLbx   := 0                                                       // Posicao do List
Local aItems    := {}                                                      // Array com os itens
Local nPos      := 0                                                       // Posicao no array
Local nPEvento  := 0                                                       // Evento
Local nPosAcao  := 0                                                       // Acao
Local cEvento   := ""                                                       // Descricao do Assunto
Local _cStatus  := "2"                                                      // Descricao do Assunto
Local _cSeekAg5 := ""                                                       // Descricao do Assunto
Local lRet      := .F.                                                      // Retorno da funcao
Local oGreen    := Nil
Local oRed      := Nil
Local oBlue     := Nil
Local _cHoraIni := ""
Local _cHoraFim := ""
Local _cDataEve := ""
Local _cContato := ""
Local _cAcao    := "1"

CursorWait()

//Apresenta uma mensagem para o usuário, quando for executado através de qualquer relatório personalizável.
//O campo Grade não possui uma consulta padrão, somente personalizada.
If "TMKR" $ FunName()	
	MsgStop(STR0062, STR0061)	//##"Consulta padrão não disponível para relatórios personalizáveis." ##"TOTVS"
	Return(lRet)
EndIf

oGreen 	:= LoadBitmap( GetResources(), "BR_VERDE" )
oRed	:= LoadBitmap( GetResources(), "BR_VERMELHO" )
oBlue	:= LoadBitmap( GetResources(), "BR_AZUL" )

nPosAcao := aScan( aHeader, { |x| Alltrim(x[2])=="UD_SOLUCAO" } )

nPosEvento := aScan( aHeader, { |x| Alltrim(x[2])=="UD_EVENTO" } )

nPosGrade  := aScan( aHeader, { |x| Alltrim(x[2])=="UD_GRADE" } )  //Posicaodo campo evento
	
If empty(Acols[n][nPosEvento])
	MsgInfo(STR0010, STR0002)  //"Digitar obrigatoriamente o campo Evento no item relacionado."###"Atenção"
	CursorArrow()
	Return(lRet)
Endif

cEvento := Acols[n][nPosEvento]	

DbSelectArea("ACE")
DbSetOrder(1)
DbSeek(xFilial("ACE")+cEvento)
While ACE->(!Eof()) .AND. (xFilial("ACE") == ACE->ACE_FILIAL) .AND. (ACE->ACE_CODIGO == cEvento)
	DbSelectArea("AG5")
	DbSetOrder(4)
	If DbSeek(xFilial("AG5")+M->UC_CODCONT+cEvento+ACE->ACE_GRADE)
		_cSeekAg5 := xFilial("AG5")+M->UC_CODCONT+cEvento+ACE->ACE_GRADE
		While AG5->(!eof()) .AND. AG5->AG5_FILIAL+AG5->AG5_CODCO+AG5->AG5_EVENT+AG5->AG5_GRADE == _cSeekAg5
			
			If AG5->AG5_STRES == "1"        //ja inscrito
				_cStatus := "1"
			ElseIf ACE->ACE_STATUS == "1"    //disponivel
				_cStatus := "2"
			ElseIf ACE->ACE_STATUS == "2"    //lotado
				_cStatus := "3"
			Endif
			
			AG5->(dbskip())
		End
	Endif
	
	If !Empty(ACE->ACE_CODIGO) .AND. !Empty(ACE->ACE_GRADE)
		
		Aadd(aItems,{	iIf(_cStatus=="1",oBlue,iIf(_cStatus=="2",oGreen,oRed)),;
		iIf(_cStatus=="1",STR0011,iIf(_cStatus=="2",STR0012,STR0013)),;  //"Já Inscrito"###"Disponível"###"Lotado"
		ACE->ACE_CODIGO,;    //Codigo
		ACE->ACE_GRADE,;      //Grade
		ACE->ACE_TEMA,;      //Tema
		ACE->ACE_CAPAC,;      //Capacidade
		ACE->ACE_OCUPAC,;      //Ocupacao
		ACE->ACE_MARGEM,;      //Margem
		ACE->ACE_DATA,;      //Data
		ACE->ACE_HRINI,;      //Hora Inicial
		ACE->ACE_HRFIM,;      //Hora Final
		ACE->ACE_SALA})     //Sala
	Endif
	ACE->(DbSkip())
End

CursorArrow()

If Len(aItems) <= 0
	Help(" ",1,"FALTA_GRAD")
	Return(lRet)
Endif

DEFINE MSDIALOG oDlgACE FROM  30,003 TO 260,600 TITLE STR0014+alltrim(cEvento)+"." PIXEL   //"Ocorrencias Relacionadas"

@ 03,10 LISTBOX oLbx1 VAR nPosLbx FIELDS HEADER ;
	" ",;
	STR0015,;  //"Status"
	STR0016,;  //"Evento"
	STR0017,;  //"Grade"
	STR0018,;  //"Tema"
	STR0019,;  //"Capacidade"
	STR0020,;  //"Ocupação"
	STR0021,;  //"Margem"
	STR0022,;  //"Data"
	STR0023,;  //"Hora Inicial"
	STR0024,;  //"Hora Final"
	STR0025;  //"Sala"
	SIZE 283,80 OF oDlgACE PIXEL NOSCROLL //"Descricao","Ocorrencia","Prazo"
	oLbx1:SetArray(aItems)
	oLbx1:bLine:={||{aItems[oLbx1:nAt,1],;
	aItems[oLbx1:nAt,2],;
	aItems[oLbx1:nAt,3],;
	aItems[oLbx1:nAt,4],;
	aItems[oLbx1:nAt,5],;
	aItems[oLbx1:nAt,6],;
	aItems[oLbx1:nAt,7],;
	aItems[oLbx1:nAt,8],;
	aItems[oLbx1:nAt,9],;
	aItems[oLbx1:nAt,10],;
	aItems[oLbx1:nAt,11],;
	aItems[oLbx1:nAt,12] }}
	
oLbx1:BlDblClick := {||(lRet:= .T.,nPos:= oLbx1:nAt, oDlgACE:End())}
oLbx1:Refresh()

DEFINE SBUTTON FROM 88,175 TYPE 1 ENABLE OF oDlgACE ACTION (lRet:= .T.,nPos := oLbx1:nAt,oDlgACE:End())
DEFINE SBUTTON FROM 88,210 TYPE 2 ENABLE OF oDlgACE ACTION (lRet:= .F.,oDlgACE:End())

ACTIVATE MSDIALOG oDlgACE CENTERED

If lRet
	If STR0011 $ aItems[nPos][2]  //Nao valida a escolha do item caso o contato jah esteja escrito ou já havia recusado  //"Já Inscrito"
		DbSelectArea("SUQ")
		DbSetOrder(1)
		If DbSeek(xFilial("SUQ")+aCols[n][nPosAcao])
			If SUQ->UQ_EVENTO == "1" .or. SUQ->UQ_EVENTO == "2"
				msgalert(STR0026,STR0002)  //"Contato já inscrito para esta grade de eventos. Esta grade não poderá ser inserida."###"Atenção"
				Return .F.
			Endif
		Endif
		
	ElseIf STR0013 $ aItems[nPos][2]  //Nao permite desistir de um evento em que o contato nao se inscreveu  //"Lotado"
		
		DbSelectArea("SUQ")
		DbSetOrder(1)
		If DbSeek(xFilial("SUQ")+aCols[n][nPosAcao])
			If SUQ->UQ_EVENTO == "3"
				msgalert(STR0027,STR0002)  //"Contato não pode desistir de uma grade de eventos que não está inscrito. Esta grade não poderá ser inserida."###"Atenção"
				Return .F.
			Endif
		Endif
		
	else
		// valida se o contato ja foi inscrito no dia/horario em outro evento
		DbSelectArea("SUQ")
		DbSetOrder(1)
		If DbSeek(xFilial("SUQ")+aCols[n][nPosAcao])
	        _cAcao := SUQ->UQ_EVENTO
        Endif
	
		DbSelectArea("ACE")
		DbSetOrder(1)
		If DbSeek(xFilial("ACE")+cEvento+aItems[nPos][4])
			_cHoraIni := ACE->ACE_HRINI
			_cHoraFim := ACE->ACE_HRFIM
			_cDataEve := ACE->ACE_DATA
		Endif
		DbSelectArea("AG5")
		DbSetOrder(4)
		If DbSeek(xFilial("AG5")+M->UC_CODCONT)
			_cContato := M->UC_CODCONT
			While AG5->(!eof()) .AND. _cContato == AG5->AG5_CODCO
				If AG5->AG5_STRES == "1" .AND. _cAcao == "1"      //ja inscrito
					DbSelectArea("ACE")
					DbSetOrder(1)
					If DbSeek(xFilial("ACE")+AG5->AG5_EVENT+AG5->AG5_GRADE)
						If ACE->ACE_DATA == _cDataEve
							
							If (ACE->ACE_HRINI < _cHoraIni) .AND. (ACE->ACE_HRFIM <= _cHoraIni)
								lRet := .T.
							ElseIf (ACE->ACE_HRINI >= _cHoraFim) .AND. (ACE->ACE_HRFIM > _cHoraFim)
								lRet := .T.
							else
								MsgStop(STR0028+alltrim(AG5->AG5_EVENT)+STR0029+alltrim(AG5->AG5_GRADE)+STR0030+alltrim(ACE->ACE_HRINI)+STR0031+alltrim(ACE->ACE_HRFIM)+".",STR0032)  //"Hora já existente no evento "###", grade "###" no horário de "###" às "###"Período já preenchido!!!"
								Return .F.
							Endif
							
						Endif
					Endif
				Endif
				AG5->(dbskip())
			End
		Endif
	Endif
	
	DbSelectArea("ACE")
	DbSetOrder(1)
	DbSeek(xFilial("ACE")+cEvento+aItems[nPos][4])

Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk271ValSUWºAutor  ³Vendas CRM          º Data ³  30/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao nas digitacoes dos campos UD_EVENTO e UD_GRADE    º±±
±±º          ³ consistindo as regras de grade ja inscrita, lotada ou dis-  º±±
±±º          ³ ponivel para o contato atendido pelo Call Center.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk271ValSUW()

Local nPos      := 0                                                 // Posicao no array
Local cCampanha := ""                                                // Descricao do Assunto
Local cEvento   := ""                                                // Descricao do Assunto
Local lRet      := .F.                                               // Retorno da funcao
Local nPosAcao  := aScan( aHeader, { |x| Alltrim(x[2])=="UD_SOLUCAO" } )  //Posicao do campo acao ao ser acionado o x3_valid
Local nPosEvento:= aScan( aHeader, { |x| Alltrim(x[2])=="UD_EVENTO" } )  //Posicao do campo evento ao ser acionado o x3_valid
Local _cStatus  := "2"
Local _cAcao    := "1"

CursorWait()

If empty(M->UC_CODCAMP) // Valida somente se o codigo de campanha estiver digitado
	MsgInfo(STR0001, STR0002)  //"Digitar obrigatoriamente o campo Campanha no cabeçalho."###"Atenção"
	CursorArrow()
	Return(lRet)
Endif

cCampanha := M->UC_CODCAMP

If ReadVar()=="M->UD_EVENTO"
	
	If Empty(M->UD_EVENTO)
		Return .T.
	Endif
	
	DbSelectArea("SUQ")
	DbSetOrder(1)
	If DbSeek(xFilial("SUQ")+aCols[n][nPosAcao])
		
		DbSelectArea("SUW")
		DbSetOrder(2)
		If DbSeek(xFilial("SUW")+cCampanha+M->UD_EVENTO)
			
			If !Empty(M->UD_EVENTO)
				
				If SUQ->UQ_EVENTO == "1"    // Checa se a acao escolhida foi a opcao de Aceitar
					lRet := .T.

				ElseIf SUQ->UQ_EVENTO == "3" // Checa se a acao escolhida foi a opcao de Desistir
					DbSelectArea("AG5")
					DbSetOrder(4)
					If DbSeek(xFilial("AG5")+M->UC_CODCONT+M->UD_EVENTO)
						_cSeekAg5 := xFilial("AG5")+M->UC_CODCONT+M->UD_EVENTO
						While AG5->(!eof()) .AND. AG5->AG5_FILIAL+AG5->AG5_CODCO+AG5->AG5_EVENT == _cSeekAg5
							If AG5->AG5_STRES == "1"
								lRet := .T.
								Exit
							Endif
							AG5->(dbskip())
						End
					else
						MsgStop(STR0003,STR0037)  //"Não existem eventos relacionados a esta Campanha."###"Evento Inexistente"
						lRet := .F.
					Endif
					
					
				ElseIf SUQ->UQ_EVENTO == "2" // Checa se a acao escolhida foi a de Recusar
					DbSelectArea("AG5")
					DbSetOrder(4)
					If !DbSeek(xFilial("AG5")+M->UC_CODCONT+M->UD_EVENTO)
						lRet := .T.
					else
						MsgStop(STR0038,STR0037)  //"Não existem eventos relacionados a esta Campanha para a opção Recusar."###"Evento Inexistente"
						lRet := .F.
					Endif
				Endif
				
			Endif
			
		else
			MsgStop(STR0039,STR0002)  //"Não existe este evento relacionado a esta Campanha."###"Atenção"
			lRet := .F.
		Endif
	Endif
	
	
ElseIf ReadVar()=="M->UD_GRADE"
	
	If empty(M->UD_GRADE)  // checa se o campo grade estah com conteudo em 'branco'
		Return .T.
	Endif

	DbSelectArea("SUQ")
	DbSetOrder(1)
	If DbSeek(xFilial("SUQ")+aCols[n][nPosAcao])
		_cAcao := SUQ->UQ_EVENTO
	Endif
	
	DbSelectArea("ACE")
	DbSetOrder(1)
	If DbSeek(xFilial("ACE")+aCols[n][nPosEvento]+M->UD_GRADE)
		_cHoraIni := ACE->ACE_HRINI
		_cHoraFim := ACE->ACE_HRFIM
		_cDataEve := ACE->ACE_DATA
	Endif
	DbSelectArea("AG5")
	DbSetOrder(4)
	If DbSeek(xFilial("AG5")+M->UC_CODCONT)
		_cContato := M->UC_CODCONT
		While AG5->(!eof()) .AND. _cContato == AG5->AG5_CODCO
			If AG5->AG5_STRES == "1" .AND. _cAcao == "1"    //ja inscrito
				DbSelectArea("ACE")
				DbSetOrder(1)
				If DbSeek(xFilial("ACE")+AG5->AG5_EVENT+AG5->AG5_GRADE)
					If ACE->ACE_DATA == _cDataEve
						// checa se o contato ja se encontra inscrito no mesmo dia/horario em outros eventos/grades
						If (ACE->ACE_HRINI < _cHoraIni) .AND. (ACE->ACE_HRFIM <= _cHoraIni)
							lRet := .T.
						ElseIf (ACE->ACE_HRINI >= _cHoraFim) .AND. (ACE->ACE_HRFIM > _cHoraFim)
							lRet := .T.
						else
							MsgStop(STR0028+alltrim(AG5->AG5_EVENT)+STR0029+alltrim(AG5->AG5_GRADE)+STR0030+alltrim(ACE->ACE_HRINI)+STR0031+alltrim(ACE->ACE_HRFIM)+".",STR0032)  //"Hora já existente no evento "###", grade "###" no horário de "###" às "###"Período já preenchido!!!"
							CursorArrow()
							Return .F.
						Endif
						
					Endif
				Endif
			Endif
			AG5->(dbskip())
		End
	Endif
	
	DbSelectArea("SUQ")
	DbSetOrder(1)
	If DbSeek(xFilial("SUQ")+aCols[n][nPosAcao])
		
		DbSelectArea("SUW")
		DbSetOrder(2)
		If DbSeek(xFilial("SUW")+cCampanha+aCols[n][nPosEvento])
			
			cEvento := aCols[n][nPosEvento]
			
			DbSelectArea("ACE")
			DbSetOrder(1)
			If DbSeek(xFilial("ACE") + cEvento + M->UD_GRADE)

				// checa se a opcao se encontra jah inscrito, disponivel ou lotado para inFormar ao usuario
				DbSelectArea("AG5")
				DbSetOrder(4)
				If DbSeek(xFilial("AG5")+M->UC_CODCONT+cEvento+M->UD_GRADE)
					_cSeekAg5 := xFilial("AG5")+M->UC_CODCONT+cEvento+M->UD_GRADE
					While AG5->(!eof()) .AND. AG5->AG5_FILIAL+AG5->AG5_CODCO+AG5->AG5_EVENT+AG5->AG5_GRADE == _cSeekAg5
						
						If AG5->AG5_STRES == "1"        //ja inscrito
							_cStatus := "1"
						ElseIf ACE->ACE_STATUS == "1"    //disponivel
							_cStatus := "2"
						ElseIf ACE->ACE_STATUS == "2"    //lotado
							_cStatus := "3"
						Endif
						
						AG5->(dbskip())
					End
				else
					_cStatus := "2"
					lRet := .T.
				Endif
				
			else
				MsgStop(STR0040,STR0002)  //"Evento/Grade não localizado."###"Atenção"
				Return .F.
			Endif
			
			If _cStatus == "1" .AND. SUQ->UQ_EVENTO <> "3"
				MsgInfo(STR0041,STR0002)  //"Contato já inscrito no evento. Não será aceita a inclusão nesta grade."###"Atenção"
				lRet := .F.
			ElseIf _cStatus == "3" .AND. SUQ->UQ_EVENTO <> "3"
				MsgInfo(STR0042,STR0002)  //"Evento encontra-se lotado porém o contato poderá ser inscrito."###"Atenção"
				lRet := .T.
			ElseIf _cStatus == "3" .AND. SUQ->UQ_EVENTO == "3"
				MsgInfo(STR0043,STR0002)  //"Evento encontra-se Lotado e como não houve confirmação não poderá escolher a ação Desistir."###"Atenção"
				lRet := .F.
			else
				lRet := .T.
			Endif
			
		else
			MsgStop(STR0039,STR0002)  //"Não existe este evento relacionado a esta Campanha."###"Atenção"
			Return .F.
		Endif
	Endif
	
Endif

CursorArrow()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk271LimpSUDºAutor  ³Vendas CRM          º Data ³  30/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao que consiste se os campos campanha, ocorrencia,    º±±
±±º          ³ acao e grade Forem alterados, serao limpados os campos pos-  º±±
±±º          ³ teriores.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk271LimpSUD()

Local nPosOcorrencia := aScan( aHeader, { |x| Alltrim(x[2])=="UD_OCORREN" } )	//Posicao do campo acao
Local nPosDescOcorr  := aScan( aHeader, { |x| Alltrim(x[2])=="UD_DESCOCO" } )	//Posicao de ocorrencia
Local nPosAcao       := aScan( aHeader, { |x| Alltrim(x[2])=="UD_SOLUCAO" } )	//Posicao de solucao
Local nPosDescAcao   := aScan( aHeader, { |x| Alltrim(x[2])=="UD_DESCSOL" } )	//Posicao do campo com a descricao da solucao
Local nPosEvento     := 0														//Posicao do campo evento
Local nPosGrade      := 0														//Posicao do campo grade
Local nI := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificação necessária, pois se o usuário trocar de aba, antes³
//³da chamada dessa validação, o aCols e o aHeader, por          ³
//³consequencia não será mais o do telemarketing.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	nPosOcorrencia	== 0 .And.;
	nPosDescOcorr	== 0 .And.;
	nPosAcao		== 0 .And.;
	nPosDescAcao	== 0
	Return .T.
EndIf

nPosEvento := aScan( aHeader, { |x| Alltrim(x[2])=="UD_EVENTO" } )

nPosGrade  := aScan( aHeader, { |x| Alltrim(x[2])=="UD_GRADE" } )  //Posicao do campo evento
	
If ReadVar() == "M->UC_CODCAMP"
	// Limpa os campos ocorrencia, descricao da ocorrencia, acao, descr.acao, evento e grade
	If ( Type("lTk271Auto") <> "U" .And. !lTk271Auto ) .And. !Empty(aCols[1][nPosOcorrencia])
		If MsgYesNo(STR0044,STR0002)				 //"Ao modIficar/limpar o conteúdo campo Campanha, os campos ocorrencia, ação, evento e grade serão zerados em todas as linhas da grade."###"Atenção"
			For nI:=1 to len(aCols)
				aCols[nI][nPosOcorrencia]:= SPACE(len(aCols[n][nPosOcorrencia]))
				aCols[nI][nPosDescOcorr] := SPACE(len(aCols[n][nPosDescOcorr]))
				aCols[nI][nPosAcao]      := SPACE(len(aCols[n][nPosAcao]))
				aCols[nI][nPosDescAcao]  := SPACE(len(aCols[n][nPosDescAcao]))
				aCols[nI][nPosEvento]    := SPACE(len(aCols[n][nPosEvento]))
				aCols[nI][nPosGrade]     := SPACE(len(aCols[n][nPosGrade]))
			Next nI
		Endif
	Endif
	
ElseIf ReadVar() == "M->UD_OCORREN"
	// Limpa os campos acao, descr.acao, evento e grade
	If M->UD_OCORREN <> aCols[n][nPosOcorrencia]
		aCols[n][nPosAcao]    := SPACE(len(aCols[n][nPosAcao]))
		aCols[n][nPosDescAcao]:= SPACE(len(aCols[n][nPosDescAcao]))
		aCols[n][nPosEvento]  := SPACE(len(aCols[n][nPosEvento]))
		aCols[n][nPosGrade]   := SPACE(len(aCols[n][nPosGrade]))
	Endif
ElseIf ReadVar() == "M->UD_SOLUCAO"
	// limpa os campos evento e grade
	If M->UD_SOLUCAO <> aCols[n][nPosAcao]
		aCols[n][nPosEvento]:= SPACE(len(aCols[n][nPosEvento]))
		aCols[n][nPosGrade] := SPACE(len(aCols[n][nPosGrade]))
	Endif
ElseIf ReadVar() == "M->UD_EVENTO"
	// limpa os campos grade
	If M->UD_EVENTO <> aCols[n][nPosEvento]
		aCols[n][nPosGrade]:= SPACE(Len(aCols[n][nPosGrade]))
	Endif
Endif


If IsInCallStack("PLSCALLCENTER")
	If Type("oGetTmkPls") <> "U"
		oGetTmkPls:oBrowse:Refresh()
	EndIf
Else
	If Type("oGetTmk") <> "U"
		oGetTmk:oBrowse:Refresh()
	EndIf            
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271GrAG5  ºAutor  ³Vendas CRM          º Data ³  12/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava a lista de presenca  - Quando for utilizado Evento     º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKA271C                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK271GrAG5( ny )

Local nPosEvento := 0										// posicao do campo evento
Local nPosGrade  := 0										// posicao do campo grade
Local nPosAcao   := 0										// posicao do campo acao
Local cMensagem	 := ""


nPosEvento := aScan( aHeader, { |x| Alltrim(x[2])=="UD_EVENTO" } )

nPosGrade  := aScan( aHeader, { |x| Alltrim(x[2])=="UD_GRADE" } )

nPosAcao   := aScan( aHeader, { |x| Alltrim(x[2])=="UD_SOLUCAO" } )


If !Empty(M->UC_CODCAMP)
	If !Empty(aCols[ny][nPosEvento]) .AND. !Empty(aCols[ny][nPosGrade])		// grava apenas se evento e grade estiverem preenchidos

		Begin Transaction

		dbselectarea("SUQ")
		DbSetOrder(1)
		If DbSeek(xFilial("SUQ") + aCols[ny][nPosAcao])
			
			If SUQ->UQ_EVENTO == "1" // acao aceitar
				DbSelectArea("ACE")
				DbSetOrder(1)

				If dbseek(xFilial("ACE")+aCols[ny][nPosEvento]+aCols[ny][nPosGrade])
					Reclock("ACE",.F.)
					ACE->ACE_OCUPAC += 1												// adiciona na ocupacao na grade de eventos
					ACE->(MsUnlock())
					If ACE->ACE_OCUPAC > ((ACE->ACE_MARGEM/100)*ACE->ACE_CAPAC)
						Reclock("ACE",.F.)
						ACE->ACE_STATUS := "2"											// atualiza o status da grade
						ACE->(MsUnlock())
						cMensagem := (STR0045+alltrim(aCols[ny][nPosGrade])+STR0046+alltrim(aCols[ny][nPosEvento])+STR0047,STR0048) //"Com a confirmação deste participante a grade "###" do evento "###" superou seu limite de ocupação em número de participantes."###"Grade de Evento LOTADA"
						
						ExecCRMPro("000022") 
						
					ElseIf ACE->ACE_OCUPAC == ((ACE->ACE_MARGEM/100)*ACE->ACE_CAPAC)
						cMensagem := (STR0045+alltrim(aCols[ny][nPosGrade])+STR0046+alltrim(aCols[ny][nPosEvento])+STR0049,STR0050) //"Com a confirmação deste participante a grade "###" do evento "###" atingiu seu limite de ocupação."###"Grade de Evento"
					Endif
				Endif
				
				DbSelectArea("AG5")
				RecLock("AG5",.T.)
				AG5->AG5_FILIAL := xFilial("AG5")
				AG5->AG5_PRESE := "2"
				AG5->AG5_EVENT := aCols[ny][nPosEvento]
				AG5->AG5_GRADE := aCols[ny][nPosGrade]
				AG5->AG5_CODCO := M->UC_CODCONT
				AG5->AG5_ENTID := M->UC_ENTIDAD

				DbSelectArea("AC8")
				DbSetOrder(1)

				If DbSeek(xFilial("AC8") + M->UC_CODCONT + M->UC_ENTIDAD )
					AG5->AG5_CODEN := AC8->AC8_CODENT
				Endif

				AG5->AG5_DTRES := dDataBase
				AG5->AG5_STRES := "1"
				AG5->AG5_LISTA := Alltrim(aCols[nY][nPosEvento])+alltrim(aCols[nY][nPosGrade])
				AG5->(MsUnlock())
				
			ElseIf SUQ->UQ_EVENTO == "3"  //acao recusar
				
				DbSelectArea("ACE")
				DbSetOrder(1)
				If DbSeek(xFilial("ACE")+aCols[nY][nPosEvento]+aCols[nY][nPosGrade])
					Reclock("ACE",.F.)
					ACE->ACE_OCUPAC -= 1
					ACE->(MsUnlock())
				Endif
				
				If ACE->ACE_OCUPAC <= ((ACE->ACE_MARGEM/100)*ACE->ACE_CAPAC)
					Reclock("ACE",.F.)
					ACE->ACE_STATUS := "1"
					ACE->(MsUnlock())

				ElseIf ACE->ACE_OCUPAC == ((ACE->ACE_MARGEM/100)*ACE->ACE_CAPAC)
					Reclock("ACE",.F.)
					ACE->ACE_STATUS := "1"
					ACE->(MsUnlock())
					cMensagem := (STR0051+alltrim(aCols[nY][nPosGrade])+STR0046+alltrim(aCols[nY][nPosEvento])+STR0052,STR0050) //"Com a desistencia deste participante a grade "###" do evento "###" retornou seu status para EM ABERTO."###"Grade de Evento"
				Endif
				
				DbSelectArea("AG5")
				DbSetOrder(2)
				If DbSeek(xFilial("AG5")+aCols[nY][nPosEvento]+aCols[nY][nPosGrade]+M->UC_CODCONT)
					RecLock("AG5",.F.)
					AG5->AG5_STRES := "2"
					AG5->(MsUnlock())
				Endif
			Endif
		Endif
		End transaction
		
		If !Empty(cMensagem)
			MsgInfo(cMensagem)
		EndIf
						
	Endif
Endif

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271ValEvºAutor  ³Vendas CRM          º Data ³  08/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ExpC1 - Valida o evento no atendimento                      º±±
±±º          ³        '1'- valida na linha                                º±±
±±º          ³        '2'- valida Toda a GetDados                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK271ValEv( cVal )

Local nPosEvento := 0                           			//Posicao do campo evento
Local nPosGrade  := 0										//Posicao do campo grade
Local nI         := 0										// Variavel utilizada no For... Next
Local aColsAux   := {}
Local lRet		 := .T.										// Retorno da Funcao

nPosEvento := aScan( aHeader, { |x| Alltrim(x[2])=="UD_EVENTO" } )  //Posicao do campo evento

nPosGrade  := aScan( aHeader, { |x| Alltrim(x[2])=="UD_GRADE" } )  //Posicao do campo grade

If cVal == "1"		// Valida a linha
    aColsAux := aClone(aCols)	
	
	For nI:=1 to Len(aColsAux)
		If n <> nI
			If !aCols[nI][Len(aHeader)+1]
				If aCols[n][nPosEvento] == aColsAux[nI][nPosEvento] .and. aCols[n][nPosGrade] == aColsAux[nI][nPosGrade] .and. !empty(aCols[n][nPosEvento] + aColsAux[nI][nPosEvento])
					MsgStop(STR0053,STR0054)  //"Não pode ocorrer da mesma grade e evento ser utilizada duas vezes no mesmo atendimento. "###"Evento/Grade duplicada"
					lRet := .F.
					Exit
				Endif
			EndIf
		Endif
	Next nI
ElseIf cVal == "2"		// Valida a linha
	For nI:=1 to Len(aCols)
		If !aCols[nI][Len(aHeader)+1]
			If nI <> Len(aCols)
				If aCols[len(aCols)][nPosEvento]+aCols[Len(aCols)][nPosGrade] == aCols[nI][nPosEvento]+aCols[nI][nPosGrade];
				 .AND. !Empty(aCols[len(aCols)][nPosEvento]+aCols[Len(aCols)][nPosGrade])
					MsgStop(STR0055,STR0056)  //"O último item na interface do Call Center já existe cadastrado, altere-o para efetivar o chamado."###"Duplicidade em Evento/Grade"
					lRet := .F.
					Exit
				Endif
			Endif
		EndIf
	Next nI
Endif


Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271Contato  ³ Autor ³ Vendas CRM            ³ Data ³ 22/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra todas as entidades dos contatos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³AP6 Call Center                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkEnt2EvCont(cContato)

Local aArea		:= GetArea()					//Salva a area atual
Local aChave	:= TkEntEstru()					//Array de estrutura da chave para demonstracao
Local aCont		:= {}							//Array com os contatos
Local nOpcao	:= 0							//Opcao de resposta
Local nPos		:= 0							//Posicao escolhida no array
Local nPosEnt	:= 0							//Posicao da entidade dentro doa array de estrutura
Local oLbx										//Listbox
Local oDlg										//Tela
Local cEnt		:= Space(3)						//Alias da Entidade
Local cCodEnt	:= Space(25)					//Codigo da Entidade
Local cEntidade	:= ""							//Alias : SA1
Local cDescInd	:= Space(40)					//Indice: Codigo + Loja
Local cChave    := ""							//Codigo: 00000101
Local cDescChave:= ""							//Descr : Empresa X Ltda.
Local cDescEnt	:= Space(40)					//Nome  : Cadastro de Clientes
Local cDescCod	:= Space(40)					//Nome da Empresa de acordo com a entidade
Local cEntChave := ""							//Chave da entidade para exibicao no browse
Local lShowBtn	:= .T. 							//Flag para exibir ou nao o botao de CANCELA e INCLUIR
Local nPosBtn	:= 225							//Posicao do botao de OK
Local aAreaSA1	:= {}							//Area do SA1
Local cStatusA1	:= ""							//Status do cliente (bloqueado ou nao)
Local nTamCon	:= TamSx3('UC_CODCONT')[1]		//Tamanho do campo UC_CODCONT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a funcao foi executada por gatilho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TkSetTrigger()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A funcao e recurssiva se o parametro estiver preenchido mantem o valor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cContato:= IIf(ValType(cContato) == "C" ,cContato,"")
	
	DbSelectArea("AC8")
	DbSetOrder(1)
	If ! DbSeek(xFilial("AC8") + cContato)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao existe relacionamentos para o CONTATO entao executa a inclusao das entidades.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOpcao := TkInsertEnt(cContato,@aCont,@oLbx)
		If nOpcao == 1
			// Se o operador ja elencou uma entidade para esse contato
			lShowBtn := .F.
			nPosBtn  := 285
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega todos as ENTIDADES relacionadas do CONTATO escolhido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("AC8")
	DbSetOrder(1)
	If DbSeek(xFilial("AC8") + cContato , .T.)
		If nOpcao == 1
			aCont := {}
		Endif
		
		While !Eof() .AND. (xFilial("AC8") == AC8->AC8_FILIAL) .AND. (cContato == AC8->AC8_CODCON)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca a estrutura de chaves das entidades                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosEnt := Ascan( aChave, { |x| x[1] == ALLTRIM(AC8->AC8_ENTIDA) })
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso encontrou utiliza para demonstrar no browse            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPosEnt > 0
				cEntChave := Substr(AC8->AC8_CODENT,1,aChave[nPosEnt][2])
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso exista filial/loja exibe concatenando com o codigo     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aChave[nPosEnt][3] > 0
					cEntChave += "-" + Substr(AC8->AC8_CODENT,aChave[nPosEnt][2]+1,aChave[nPosEnt][3])
				Endif
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso nao encontrou utiliza diretamente o campo AC8_CODENT   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cEntChave := ALLTRIM(AC8->AC8_CODENT)
			Endif
			
			cEnt    := ALLTRIM(AC8->AC8_ENTIDA)			  						//Alias : SA1
			cDescEnt:= Posicione("SX2",1,cEnt,"X2NOME()")						//Nome  : Cadastro de Clientes
			cCodEnt := ALLTRIM(AC8->AC8_CODENT)			 						//Codigo: 00000101
			cDescCod:= TkEntidade(cEnt,cCodEnt,1)								//Descr : Empresa X Ltda.
			cDescInd:= ALLTRIM(Posicione("SIX",1,cEnt + "1","SIXDescricao()"))	//Indice: Codigo + Loja
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se ha bloqueio na entidade³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TmkBlqCont(cEnt,xFilial("SA1")+cCodEnt)
				AC8->(DbSkip())
				Loop
			EndIf
			
			Aadd(aCont,{cEnt,;			// 1 - Alias : SA1
						cDescInd,;		// 2 - Indice: Codigo + Loja
						cCodEnt,;		// 3 - Codigo: 00000101
						cDescEnt,;		// 4 - Nome  : Cadastro de Clientes
						cDescCod,;		// 5 - Descr : Empresa X Ltda.
						cEntChave})		// 6 - Chave para demonstracao no browse
			
			DbSelectArea("AC8")
			DbSkip()
		End
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se existe relacionamento para esse CONTATO mostra as Entidades³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If Len(aCont) > 0
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao estiver usando a entrada automatica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
			DEFINE MSDIALOG oDlg FROM  300,20 TO 560,650 TITLE STR0057  PIXEL  //"Relacionamento Contatos X Entidades"
			
			@01,03 TO 110,315 LABEL "" OF oDlg  PIXEL
			@05,05 LISTBOX oLbx FIELDS HEADER ;
				STR0058,;        //"Entidade"
				STR0059,;        //"Codigo"
				STR0060;         //"Descricao"
			SIZE 307,103 NOSCROLL OF oDlg PIXEL	ON DBLCLICK(nOpcao :=1 , nPos := oLbx:nAt ,oDlg:End())

			oLbx:SetArray(aCont)
			oLbx:bLine:={||{	aCont[oLbx:nAt,4],;
								aCont[oLbx:nAt,6],;
								aCont[oLbx:nAt,5] }}
			oLbx:nAt := 1                           
			
			DEFINE SBUTTON FROM 115,nPosBtn TYPE 1            ENABLE OF oDlg ACTION (nOpcao:=1, nPos:=oLbx:nAt, oDlg:End())     //OK
			
			If lShowBtn
				DEFINE SBUTTON FROM 115,255 TYPE 2        ENABLE OF oDlg ACTION (nOpcao:=0,oDlg:End())                //CANCELA
				DEFINE SBUTTON FROM 115,285 TYPE 4        ENABLE OF oDlg ACTION TkInsertEnt(cContato,@aCont,@oLbx)    //INCLUI
			Endif
			
			ACTIVATE MSDIALOG oDlg CENTER
			
		Else
			nOpcao:=1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pesquisa no array aCont qual e a posicao do contato passado no  ³
			//³array aAutoCab (entrada automatica)                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPos:= Ascan(aCont,{|x| x[1]+x[3] == aAutoCab[ProcTmk("UC_ENTIDAD"),2] + ALLTRIM(aAutoCab[ProcTmk("UC_CHAVE"),2]) })
		Endif
		
		If (nOpcao == 1) .AND. nPos > 0
			cEntidade	:= aCont[nPos,1]	// 1 - Alias : SA1
			cDescInd	:= aCont[nPos,2]	// 2 - Indice: Codigo + Loja
			cChave		:= aCont[nPos,3]	// 3 - Codigo: 00000101
			cDescEnt	:= aCont[nPos,4]	// 4 - Nome  : Cadastro de Clientes
			cDescChave	:= aCont[nPos,5]	// 5 - Descr : Empresa X Ltda.
			
			If cEntidade == "SUS"
				lProspect := .T.
			Else
				lProspect := .F.
			Endif
			
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nenhuma entidade encontrada:        ³
		//³Limpa os campos e notifica o usuario³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
			Help(" ",1,"TK061NAC8")
		EndIf
		
	Endif
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ativa novamente o flag de gatiho para TRUE - Dessa forma sera executado na proxima alteracao do campo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TkSetTrigger(.T.)

RestArea(aArea)
	
nDescCon := aScan( aHeader, { |x| Alltrim(x[2])=="AG5_DESCCO" } )
nEntid   := aScan( aHeader, { |x| Alltrim(x[2])=="AG5_ENTID" } )
nCodEnt  := aScan( aHeader, { |x| Alltrim(x[2])=="AG5_CODEN" } )
nDescEnt := aScan( aHeader, { |x| Alltrim(x[2])=="AG5_DESCEN" } )

ACols[n][nDescCon] := Posicione("SU5",1,xfilial("SU5")+M->AG5_CODCO,"SU5->U5_CONTAT")//cDescEnt
ACols[n][nEntid]   := cEntidade
ACols[n][nCodEnt]  := cChave
ACols[n][nDescEnt] := cDescChave


Return .T.