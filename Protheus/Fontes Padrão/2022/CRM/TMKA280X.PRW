#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "TMKA280X.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA280X  บAutor  ณArmando M. Tessaroliบ Data ณ  02/06/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEste fonte guarda as funcoes que realizam as pesquisas nas  บฑฑ
ฑฑบ          ณbases de dados e alimentam as fun็oes de tela, especificas  บฑฑ
ฑฑบ          ณdo Pre-atendimento de TELECOBRANCA.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

                                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณTk280SU4      บAutor  ณArmando M. Tessaroliบ Data ณ21/05/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณ- Metodo do botao de atualizacao dos dados da agenda do dia บฑฑ
ฑฑบ          ณ- Disponibiliza a conta do operador para outro grupo, se    บฑฑ
ฑฑบ          ณalgum Titulo passou a conta para uma regra superior.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaAgenda   - Array com os dados dos atendimentos que serao   บฑฑ
ฑฑบ          ณ            utilizados pelo objeto anterior.                บฑฑ
ฑฑบ          ณcOperador - Codigo do operador que esta trabalhando.        บฑฑ
ฑฑบ          ณaRegCobr  - Contem as regras de selecao dos titulos de todosบฑฑ
ฑฑบ          ณ            os operadores para validar qual titulo o opera- บฑฑ
ฑฑบ          ณ            dor corrente podera trabalhar.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑบฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบฑฑ
ฑฑบAndrea F. ณ06/07/05ณ8.11  ณBOPS 83837- Reordenacao do array de         บฑฑ
ฑฑบ          ณ        ณ      ณpendencias agendadas.                       บฑฑ
ฑฑบAndrea F. ณ07/07/05ณ8.11  ณBOPS 83837- Criacao do parametro MV_TMKPHJ  บฑฑ
ฑฑบ          ณ        ณ      ณpara controlar a exibicao das pendencias.   บฑฑ
ฑฑบ          ณ        ณ      ณencerradas.   							  บฑฑ
ฑฑบAndrea F. ณ27/10/05ณ8.11  ณDella Via - Encerrar as pendencias que nao  บฑฑ
ฑฑบ          ณ        ณ      ณpossuirem SK1.							  บฑฑ
ฑฑบAndrea F. ณ21/03/06ณ8.11  ณBOPS 95516 - Disponibilizar a conta do      บฑฑ
ฑฑบ          ณ        ณ      ณoperador para um grupo inferior, quando nao บฑฑ
ฑฑบ          ณ        ณ      ณexistir titulo que esteja em sua regra.     บฑฑ
ฑฑบAndrea F. ณ30/03/06ณ8.11  ณBOPS 95516 - Implementado log na funcao que บฑฑ
ฑฑบ          ณ        ณ      ณdisponibiliza as contas para outros grupos  บฑฑ
ฑฑบ          ณ        ณ      ณde cobranca.                                บฑฑ
ฑฑบAndrea F. ณ25/04/06ณ811   ณBOPS 97585 - Utilizar a ordem 2 da tabela   บฑฑ
ฑฑบ          ณ        ณ      ณSE1 para posicionar no titulo vencido       บฑฑ
ฑฑบ          ณ        ณ      ณdo cliente.                                 บฑฑ
ฑฑบAndrea F. ณ25/04/06ณ811   ณMelhorado o texto das mensagens que serao   บฑฑ
ฑฑบ          ณ        ณ      ณgeradas no console do protheus.             บฑฑ
ฑฑบAndrea F. ณ25/04/06ณ811   ณBOPS 97587 - Gravar a funcao que encerrou a บฑฑ
ฑฑบ          ณ        ณ      ณpendencia de telecobranca.                  บฑฑ
ฑฑบMichel M. ณ30/03/07ณ8.11  ณBops 121869 - Nao limpa o campo K1_OPERAD   บฑฑ
ฑฑบ          ณ        ณ      ณquando um dos titulos passa para regra de   บฑฑ
ฑฑบ          ณ        ณ      ณselecao superior, apenas reagenda a penden- บฑฑ
ฑฑบ          ณ        ณ      ณ-cia para o proximo dia.                    บฑฑ
ฑฑบMichel M. ณ04/06/07ณ8.11  ณBops 127465 - Retirado RecLock() na tabela  บฑฑ
ฑฑบ          ณ        ณ      ณSK1 que nao era mais utilizado.             บฑฑ
ฑฑบNorbert W.ณ05/10/07ณ10    ณBops 131694 - Melhorias gerais na sintaxe doบฑฑ
ฑฑบ          ณ        ณ      ณfonte.                                      บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280SU4(aAgenda,cOperador,aRegCobr)

Local oCor
Local cSA1			:= "SA1"
Local cSU6			:= "SU6"
Local cSU4			:= "SU4"
Local cRegSel		:= TKPosto(cOperador,"U0_REGSEL")			// Regra de selecao do operador
Local nPos			:= 0										// Posicao do array em que se encontra a regra de selecao do operador
Local dIni			:= dDatabase								// Data inicio para cobranca dos titulos para esse operador (vencimento mais antigo)
Local dLimite		:= dDataBase								// Data limite para vencimento do titulo em atraso para cobranca (vencimento mais novo)
Local lEncerraSU4	:= .F.                                   	// Indica que a lista sera encerrada quando a conta for transferida para um grupo superior
Local aEncerradas	:= {}										// Possui as listas que deverao ser encerradas
Local nI			:= 0  										// Contador do FOR
Local lMV_TMKPHJ	:= GetNewPar("MV_TMKPHJ",.T.)				// Indica se as pendencias encerradas na database serao exibidas no painel de pendencias agendadas									
Local lTransf		:= .F.                                     	// Indica se sera necessario transferir a conta para um grupo superior
Local lPertence		:= .T.                                    	// Indica se os titulos se encaixam no prazo da regra de selecao do operador
Local cFilOrig		:= ""										// Filial de origem do titulo
Local nTotSK1		:= 0 										// Armazena o numero de titulos importados no sk1	
Local nTotSE1       := 0                                       	// Armazeno o numeto de titulos do cliente
Local aReagendar	:= {}										// Armazena as listas a serem reagendadas 1 dia. Utilizado no caso de Clientes que nao se enquadram na regra de selecao do operador
Local lSuperouRS	:= .F.										// Indica que o cliente nao se enquadra na regra de selecao do operador
Local lNewRolTLC	:= IIf( FindFunction( 'Tk280NewTC' ), Tk280NewTC(), .F. )

#IFDEF TOP
	Local cQuery	:= ""										// Sintaxe da query
#ENDIF

nPos := Ascan(aRegCobr, {|x| x[1] == cRegSel })	
If nPos > 0 
	dIni 	:= dDataBase - aRegCobr[nPos][3]					// Data Inicial de vencimento do titulo (mais antiga) para cobranca para este operador
	dLimite	:= dDataBase - aRegCobr[nPos][2]					// Data Final de vencimento do titulo   (mais nova) para cobranca para esse operador
Endif

aAgenda := {}

DbSelectArea("SU4")
DbSetOrder(5)		// U4_OPERAD+U4_STATUS
#IFDEF TOP
	cSU4	:= "TMPSU4"
	cSA1	:= cSU4
	cSU6	:= cSU4
	cQuery	:=	" SELECT	A1_COD, A1_LOJA, A1_NOME, U4_STATUS, U4_FORMA, U4_OPERAD, U4_TIPO, U6_CODENT, " +;
				" 			U6_CODLIG, U6_CONTATO, U6_DATA, U6_FILIAL, U6_LISTA, U6_STATUS, U4_FILIAL, " +;
				" 			U6_HRINI, U4_LISTA, U6_CODIGO " +;
				" FROM " +	RetSqlName("SU4") + " SU4, " +;
							RetSqlName("SU6") + " SU6, " +;
							RetSqlName("SA1") + " SA1 " +;
				" WHERE	SU4.U4_FILIAL = '" + xFilial("SU4") + "' AND" +;
				"		SU4.U4_OPERAD = '" + cOperador + "' AND " 
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSe as existirem pendencias encerradas, e o parametro que indica a exibicao das pendencias encerradas 	 ณ
				//ณestiver ativo exibe, caso contrario somente exibe as pendencias em aberto a serem executadas ate hoje    ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If lMV_TMKPHJ
					cQuery +="	((SU4.U4_STATUS = '1' AND SU4.U4_DATA <= '" + DtoS(dDataBase) + "' )  OR  " 	// Aberto ate hoje e; 
					cQuery +="	 (SU4.U4_STATUS = '2' AND SU4.U4_DATA =  '" + DtoS(dDataBase) + "' )) AND " 	// Os encerrados na data de hoje
				Else
					cQuery +="	 (SU4.U4_STATUS = '1' AND SU4.U4_DATA <= '" + DtoS(dDataBase) + "' )  AND " 	// Aberto ate hoje ; 
				Endif
				
				cQuery += "		SU4.U4_TIPO = '2' AND" +;		// Cobranca
				"		SU4.U4_FORMA = '5' AND" +;				// Pendencia
				"		SU4.D_E_L_E_T_ = '' AND" +;
				"		SU6.U6_FILIAL = '" + xFilial("SU6") + "' AND" +;
				"		SU6.U6_LISTA = SU4.U4_LISTA AND" +;
				"		SU6.D_E_L_E_T_ = '' AND" +;
				"		SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND" +;
				"		SA1.A1_COD = SUBSTRING(SU6.U6_CODENT,1," + Alltrim(Str(TamSX3("A1_COD")[1])) + ") AND" +;
				"		SA1.A1_LOJA = SUBSTRING(SU6.U6_CODENT," + Alltrim(Str(TamSX3("A1_COD")[1]+1)) + "," + Alltrim(Str(TamSX3("A1_LOJA")[1])) + ") AND" +;
				"		SA1.D_E_L_E_T_ = ''" +;
				" ORDER BY U4_OPERAD " 
		
	cQuery	:= ChangeQuery(cQuery)
	MemoWrite("TK280SU4.SQL", cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cSU4, .F., .T.)

	TCSetField(cSU4, "U6_DATA", 'D', 8, 0)
#ELSE
	DbSeek(xFilial("SU4")+cOperador+"1")		// Listas de um operador em aberto
#ENDIF

While	!(cSU4)->(Eof()) .AND.;
		(cSU4)->U4_FILIAL == xFilial("SU4")	.AND.;
		(cSU4)->U4_OPERAD == cOperador
	
	#IFNDEF TOP
		If	!(((cSU4)->U4_STATUS == "1" .AND. (cSU4)->U4_DATA <= dDataBase) .OR.;		// Todas as pendencias abertas ate hoje
			((cSU4)->U4_STATUS == "2" .AND. (cSU4)->U4_DATA == dDataBase))			// Pendencias realizadas hoje
			DbSelectArea(cSU4)
			DbSkip()
			Loop
		Endif
		
		If (cSU4)->U4_TIPO <> "2"		// Filtra somente os de Cobranca
			DbSelectArea(cSU4)
			DbSkip()
			Loop
		Endif
		
		If (cSU4)->U4_FORMA <> "5"		// Filtra somente as Pendencias
			DbSelectArea(cSU4)
			DbSkip()
			Loop
		Endif
		
		If (cSU4)->U4_OPERAD <> cOperador   
			DbSelectArea(cSU4)
			DbSkip()
			Loop
		Endif
		
		DbSelectArea("SU6")
		DbSetOrder(1)
		DbSeek(xFilial("SU6") + (cSU4)->U4_LISTA)
		
	    DbSelectArea("SA1")
	    DbSetOrder(1)
	    DbSeek(xFilial("SA1") + SU6->U6_CODENT)
	#ENDIF
	
	// Pesquisa o contato fora da query, pois pode nao ter contato amarrado.
	DbSelectArea("SU5")
	DbSetOrder(1)
	DbSeek(xFilial("SU5") + (cSU6)->U6_CONTATO)
	
	Do Case
		Case Empty((cSU6)->U6_CODLIG) .AND. (cSU6)->U6_STATUS == "1"
			oCor := LoadBitmap( GetResources(), "BR_CINZA" )
		Case (cSU6)->U6_STATUS <> "1"
			oCor := LoadBitmap( GetResources(), "BR_VERMELHO" )
		Case (cSU6)->U6_DATA <> dDataBase .OR. (cSU6)->U6_HRINI <= SubStr(Time(),1,5)
			oCor := LoadBitmap( GetResources(), "BR_VERDE" )
		Otherwise
			oCor := LoadBitmap( GetResources(), "br_azul" )
	EndCase
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se algum Titulo passou a conta para uma regra inferior ou superior para as pendencias em abertoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   	If (cSU6)->U6_STATUS <> "3"   //So processa as pendencias em Aberto
	   	DbSelectArea("SK1")
		DbSetOrder(4)		// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
		If DbSeek(xFilial("SK1") + (cSA1)->A1_COD + (cSA1)->A1_LOJA) 
		    
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณEsta posicionado no primeiro titulo mais antigo do cliente          ณ
			//ณSe existe um titulo para um grupo superior, entao nao pode carregar.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If SK1->K1_VENCREA < dIni 		
				lTransf:= .T.          
				TmkConout(STR0002 + cOperador + STR0003 + (cSA1)->A1_COD + (cSA1)->A1_LOJA + STR0004 + Dtos(SK1->K1_VENCREA) + STR0005 + Dtos(dIni) + STR0006 + cOperador, NIL)         //" Operador-> " /" 1- TK280SU4 Cliente: " /" ->> Vencimento: " /" menor que o Inicio: "  /" para o operador:  "
			Endif	
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณComo nao existe nenhum titulo com vencimento acima da sua faixa de cobranca (limite do operador),    ณ
			//ณVerifica se o cliente tem titulos que estejam APENAS na regra de selecao do seu grupo de atendimento ณ
			//ณe se estao pagos. Dessa forma a conta sera disponibilizada para um outro grupo.                  	ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !lTransf  .And. !( lNewRolTLC )
				While !SK1->(Eof())						.AND.;
					SK1->K1_FILIAL 	== xFilial("SK1")	.AND.;
					SK1->K1_CLIENTE	== (cSA1)->A1_COD	.AND.;
					SK1->K1_LOJA 	== (cSA1)->A1_LOJA	.AND.;
					SK1->K1_VENCREA <= dLimite

					nTotSK1 ++
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVerifica se os titulos existentes APENAS na faixa do operador ja estao pagos. ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

					cFilOrig	:= SK1->K1_FILORIG
		
					DbSelectArea("SE1")
					DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
					If DbSeek(cFilOrig + SK1->K1_CLIENTE + SK1->K1_LOJA + SK1->K1_PREFIXO + SK1->K1_NUM + SK1->K1_PARCELA + SK1->K1_TIPO)
						If SE1->E1_SALDO == 0
		                	nTotSE1 ++
		                Endif	
	                Endif
	
					SK1->(DbSkip())
				End
				
				// Se leu pelo menos um registro do SK1
				If nTotSK1 > 0 
					// Todos os titulos da regra de selecao do operador ja estao pagos, essa conta nao podera ser cobrada por ele
					If nTotSK1 == nTotSE1
						lPertence 	:= .F.
						lEncerraSU4 := .T.
						TmkConout(STR0002 + cOperador + STR0007 + (cSA1)->A1_COD + (cSA1)->A1_LOJA + STR0008 + cOperador + STR0009 + Str(nTotSK1,2) + " = " + Str(nTotSE1,2),NIL )       //" Operador-> " /" 2- TK280SU4 Cliente: " /" ->> Titulos processados na faixa do operador " /" estao pagos: "
					Endif
				Else
					// Se nao possui nenhum titulo na sua faixa
					lPertence := .F. 
					TmkConout(STR0002 + cOperador + STR0010 + (cSA1)->A1_COD + (cSA1)->A1_LOJA + STR0011 + cOperador, NIL)				//" Operador-> " /" 3- TK280SU4 Cliente: " /" nao possui nenhum titulo na faixa do operador "
				Endif
					
				//Retorna para o primeiro registro do SK1 para este cliente
				SK1->(DbSetOrder(4))
				SK1->(DbSeek(xFilial("SK1") + (cSA1)->A1_COD + (cSA1)->A1_LOJA))
				
			Endif
					
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe o operador que estiver gravado no SK1 for diferente do operador da pendenciaณ
			//ณassume que o cliente eh de outro operador e encerra a pendencia.               ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !Empty(SK1->K1_OPERAD) .AND. SK1->K1_OPERAD <> cOperador
				lEncerraSU4:= .T. 
				TmkConout(STR0002 + cOperador + STR0012 + (cSA1)->A1_COD + (cSA1)->A1_LOJA + STR0002 + cOperador + STR0013 + SK1->K1_OPERAD + STR0014, NIL)        //" Operador-> " /" 4- TK280SU4 Cliente: " /" ->> Operador "  /" diferente do SK1: " /" vai encerrar a pendencia"
			Endif
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe existir algum titulo para um grupo superior, OU                 ณ
			//ณSe nao existir pelo menos um titulo na regra de selecao do operadorณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If lTransf  .OR. !lPertence
				lSuperouRS := .F.			

				//Posiciona no primeiro registro do SK1 para este cliente
				SK1->(DbSetOrder(4))
				SK1->(DbSeek(xFilial("SK1") + (cSA1)->A1_COD + (cSA1)->A1_LOJA))

				While !SK1->(Eof())						.AND.;
					SK1->K1_FILIAL 	== xFilial("SK1")	.AND.;
					SK1->K1_CLIENTE	== (cSA1)->A1_COD	.AND.;
					SK1->K1_LOJA 	== (cSA1)->A1_LOJA	.AND.;
					!lSuperouRS
						
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณDisponibiliza a conta (todos os titulos que estavam com o operador) para outro grupo ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If SK1->K1_OPERAD == cOperador
						lSuperouRS := .T.
						TmkConout(STR0002 + cOperador + STR0015 + (cSA1)->A1_COD + (cSA1)->A1_LOJA + STR0016 + SK1->K1_NUM + SK1->K1_PREFIXO + SK1->K1_PARCELA + SK1->K1_TIPO+ STR0017 + SK1->K1_CLIENTE + SK1->K1_LOJA + STR0018 + cOperador, NIL) 		//" Operador-> " /" 5- TK280SU4 Cliente: "  /" ->> Limpou o titulo " /" do Cliente: " / " para o operador: "
					Else
						TmkConout(STR0002 + cOperador + STR0019 + (cSA1)->A1_COD + (cSA1)->A1_LOJA + STR0020 + SK1->K1_OPERAD +  STR0021 + cOperador, NIL)			//" Operador-> " /" 5b- TK280SU4 Cliente: " /" nao limpou o operador do SK1 " /" porque e diferente de : "
					Endif

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณSe entrou no laco para limpar o codigo do operador mesmo que nao tenha limpado o K1_OPERAD  ณ
					//ณessa conta nao pertence mais a ele, por isso encerra a pendencia.                           ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					lEncerraSU4	:= .T.
	
					SK1->(DbSkip())
					
				End
			Endif
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณArmazena a pendencia quando o titulo passou para um grupo superior para ser encerrada posteriomenteณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	        If lEncerraSU4 .AND. !lSuperouRS
				aAdd(aEncerradas, {(cSU4)->U4_LISTA})
				oCor := LoadBitmap( GetResources(), "BR_VERMELHO" )//Atualiza o bitmap quando for encerrado  
			ElseIf lEncerraSU4 .AND. lSuperouRS
			    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//| Reagenda a pendencia, pois o cliente pode pagar o titulo que nao permitiu     |
				//|ser cobrado pelo operador e se nao foi pego para cobranca por outro operador   |
				//|com regra de selecao superior continua com o operador original.                |
			    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
				aAdd(aReagendar, {(cSU4)->U4_LISTA})
				oCor := LoadBitmap( GetResources(), "BR_VERMELHO" )//Atualiza o bitmap quando for encerrado  
			Endif			
		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe nao existir mais o SK1 para esse cliente, significa que nao existem mais titulos a serem cobradosณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aAdd(aEncerradas, {(cSU4)->U4_LISTA})
			oCor := LoadBitmap( GetResources(), "BR_VERMELHO" )//Atualiza o bitmap quando for encerrado  
			TmkConout(STR0002 + cOperador + STR0022 + (cSA1)->A1_COD + (cSA1)->A1_LOJA + STR0023 + (cSU4)->U4_LISTA, NIL )			//" Operador-> " /" Nao encontrou o SK1 do cliente " / " da pendencia "
		Endif
	
	Endif	
	
	aAdd(aAgenda, {	oCor							,;		// 01 - Legenda
					SubStr((cSU6)->U6_CODENT,1,TamSx3("A1_COD")[1])						,;		// 02 - Cliente
					SubStr((cSU6)->U6_CODENT,TamSx3("A1_COD")[1]+1,TamSx3("A1_LOJA")[1])	,;		// 03 - Loja
					(cSA1)->A1_NOME					,;		// 04 - Nome Cliente
					(cSU6)->U6_CONTATO				,;		// 05 - Cod. Contato
					SU5->U5_CONTAT					,;		// 06 - Nome Contato
					(cSU6)->U6_CODLIG				,;		// 07 - Atendimento
					(cSU6)->U6_DATA					,;		// 08 - Data
					(cSU6)->U6_HRINI				,;		// 09 - Hora
					(cSU6)->U6_STATUS				,;		// 10 - Status
					(cSU6)->U6_LISTA				,;		// 11 - Cod. Lista
					(cSU6)->U6_CODIGO				;		// 12 - Cod. Item da Lista
					})

	lEncerraSU4	:= .F.
	lTransf		:= .F.    
	lPertence	:= .T.
    nTotSK1		:=  0
    nTotSE1		:=  0
    
	DbSelectArea(cSU4)
	DbSkip()
End
	
If Len(aEncerradas) > 0
	For nI:= 1 to Len(aEncerradas)
		DbSelectArea("SU4")
		DbSetOrder(1)
		If DbSeek(xFilial("SU4") + aEncerradas[nI,1])
			RecLock("SU4", .F.)
			REPLACE SU4->U4_STATUS WITH "2"
			REPLACE SU4->U4_ROTINA WITH "TK280SU4"
	
			MsUnLock()
			TmkConout(STR0002 + cOperador + STR0024 + aEncerradas[nI,1] + STR0025 + cOperador, NIL)	      //" Operador-> " / " 6a- TK280SU4 ->> Encerrado o SU4 : " / " para o operador : "
			
			DbSelectArea("SU6")
			DbSetOrder(1)
			If DbSeek(xFilial("SU6") +  aEncerradas[nI,1])
				RecLock("SU6", .F.)
				REPLACE SU6->U6_STATUS WITH "3"
				REPLACE SU6->U6_ROTINA WITH "TK280SU4"	

				MsUnLock()           
				TmkConout(STR0002 + cOperador + STR0026 + aEncerradas[nI,1] + STR0017 + Alltrim(SU6->U6_CODENT) + STR0025 + cOperador, NIL)				//" Operador-> " /" 6b- TK280SU4 ->> Encerrado o SU6 : "   / " do cliente " /" para o operador : "
			
				nPos:= Ascan(aAgenda,{|x| x[11] == aEncerradas[nI,1]})
				If nPos > 0
					aAgenda[nPos][10]:= "3" //Atualiza o array com o status de encerrado
				Endif
			Endif
		Endif			
	Next nI	
Endif	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Reagenda a pendencia, pois o cliente pode pagar o titulo que nao permitiu     |
//|ser cobrado pelo operador e se nao foi pego para cobranca por operador com     |
//|regra de selecao superior continua com o operador original.                    |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aReagendar)>0
	For nI:= 1 to Len(aReagendar)
		DbSelectArea("SU4")
		DbSetOrder(1)
		If DbSeek(xFilial("SU4") + aReagendar[nI,1])
			RecLock("SU4", .F.)
			REPLACE SU4->U4_DATA WITH SU4->U4_DATA + 1
			REPLACE SU4->U4_ROTINA WITH "TK280SU4"
			MsUnLock()
		EndIf
		nPos:= Ascan(aAgenda,{|x| x[11] == aReagendar[nI,1]})
		If nPos > 0
			aAgenda[nPos][10]:= "3" //Atualiza o array com o status de encerrado
		Endif		
	Next nI
EndIf

#IFDEF TOP
	DbSelectArea(cSU4)
	DbCloseArea()
#ENDIF

If Len(aAgenda) = 0
	aAdd(aAgenda, {	LoadBitmap( GetResources(), "BR_CINZA" ),"","","","","","","","","","",""})
Else
	Asort( aAgenda,,, { |x,y| ( x[10] + DtoC(x[8]) + x[9] ) < ( y[10] + DtoC(y[8]) + y[9] ) } )
Endif

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณTk280SU6      บAutor  ณAndrea Farias       บ Data ณ12/04/06 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณ- Atualiza os status de todas as pendencias.                บฑฑ
ฑฑบ          ณ- Atualiza os dados de uma pendencia selecionada            บฑฑ
ฑฑบ          ณ- Inclui ou Exclui uma pendencia do array (novo pre-atend.) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaAgenda   - Array com os dados dos atendimentos que serao   บฑฑ
ฑฑบ          ณ            utilizados pelo objeto anterior.                บฑฑ
ฑฑบ          ณcAtend    - Codigo do atendimento posicionado no array de   บฑฑ
ฑฑบ          ณ            pendencias.                                     บฑฑ
ฑฑบ          ณlNovo     - Indica se a solicitacao veio de um novo pre-atenบฑฑ
ฑฑบ          ณ            cimento.                                        บฑฑ
ฑฑบ          ณlForce	- Indica se deve atualizar o status de todas as   บฑฑ
ฑฑบ          ณ            pendencias do array.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑบฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบฑฑ
ฑฑบAndrea F. ณ12/04/06ณ8.11  ณ                                            บฑฑ
ฑฑบ          ณ        ณ      ณ                                            บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280SU6(aPanels,lNovo,cLista,lForce)

Local oCor          													// Objeto com status da pendencia
Local oLbx		:= aPanels[Ascan(aPanels, {|x| x[2]=="AOBJ01"} )][1]	// Objeto com as pendencias da agenda do operador
Local aAgenda	:= oLbx:aArray											// Conteudo da agenda do operador 
Local nPosLista	:= 0                                                  	// Posicao do codigo do atendimento no array de pendencias
Local cAtend	:= ""													// Codigo do atendimento 
Local nY		:= 0													// Contador do FOR
Local cTamCli	:= TamSX3("A1_COD")[1] 									// Tamanho do campo A1_CLIENTE
Local cTamLoja	:= TamSX3("A1_LOJA")[1]                                // Tamanho do campo A1_LOJA
DEFAULT lForce	:= .F.                                           		// Forca a atualizacao dos status do array de pendencias

If lNovo .AND. Len(aAgenda) == 1 .AND. Empty(aAgenda[1][2])
	aAgenda:={}
Endif
	
cAtend := oLbx:aArray[oLbx:nAt][7]
             
If !Empty(cLista)
	DbSelectArea("SU4")
	DbSetOrder(1)	//U4_LISTA 
	If DbSeek(xFilial("SU4")+ cLista)
	
		DbSelectArea("SU6")
		DbSetOrder(1)
		If DbSeek(xFilial("SU6") +  SU4->U4_LISTA)
		
			DbSelectArea("SU5")
			DbSetOrder(1)
			DbSeek(xFilial("SU5") + SU6->U6_CONTATO)
			
			Do Case
				Case Empty(SU6->U6_CODLIG) .AND. SU6->U6_STATUS == "1"
					oCor := LoadBitmap( GetResources(), "BR_CINZA" )
				Case SU6->U6_STATUS <> "1"
					oCor := LoadBitmap( GetResources(), "BR_VERMELHO" )
				Case SU6->U6_DATA <> dDataBase .OR. SU6->U6_HRINI <= SubStr(Time(),1,5)
					oCor := LoadBitmap( GetResources(), "BR_VERDE" )
				Otherwise
					oCor := LoadBitmap( GetResources(), "br_azul" )
			EndCase
		
		    nPosLista:= Ascan(aAgenda,{|x| x[11] == cLista})
		    If nPosLista > 0
		    
			    If SU6->U6_DATA <= dDatabase //Se a data nao foi reagendada
			    	aAgenda[nPosLista][1]:=  oCor
			    	aAgenda[nPosLista][2]:=  SubStr(SU6->U6_CODENT,1,cTamCli)
			    	aAgenda[nPosLista][3]:=  SubStr(SU6->U6_CODENT,cTamCli+1,cTamLoja)
			    	aAgenda[nPosLista][4]:=  Posicione("SA1",1,xFilial("SA1")+ SU6->U6_CODENT,"A1_NOME")
			    	aAgenda[nPosLista][5]:=  SU6->U6_CONTATO
			    	aAgenda[nPosLista][6]:=  SU5->U5_CONTAT
			    	aAgenda[nPosLista][7]:=  SU6->U6_CODLIG
			    	aAgenda[nPosLista][8]:=  SU6->U6_DATA
			    	aAgenda[nPosLista][9]:=  SU6->U6_HRINI
			    	aAgenda[nPosLista][10]:= SU6->U6_STATUS
			    	aAgenda[nPosLista][11]:= SU6->U6_LISTA
			    	aAgenda[nPosLista][12]:= SU6->U6_CODIGO
			    Else
			    	ADel( aAgenda, nPosLista )
					ASize( aAgenda, Len(aAgenda)-1 )		
			    Endif		
		
			ElseIf nPosLista == 0 .AND. lNovo
				aAdd(aAgenda, {	oCor,;							// 01 - Legenda
								SubStr(SU6->U6_CODENT,1,cTamCli)									,;	// 02 - Cliente
								SubStr(SU6->U6_CODENT,cTamCli+1,cTamLoja)							,;	// 03 - Loja
								Posicione("SA1",1,xFilial("SA1")+ SU6->U6_CODENT,"A1_NOME"),;	// 04 - Nome Cliente
								SU6->U6_CONTATO,;				// 05 - Cod. Contato
								SU5->U5_CONTAT,;				// 06 - Nome Contato
								SU6->U6_CODLIG,;				// 07 - Atendimento
								SU6->U6_DATA,;					// 08 - Data
								SU6->U6_HRINI,;					// 09 - Hora
								SU6->U6_STATUS,;				// 10 - Status
								SU6->U6_LISTA,;					// 11 - Cod. Lista
								SU6->U6_CODIGO;					// 12 - Cod. Item da Lista
								})
		    Endif
		Endif    
	Endif
Endif
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza os status de todas as pendencias quando necessarioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lForce
		
	For nY:= 1 to Len(aAgenda)
		Do Case
			Case Empty(aAgenda[nY][7]) .AND. aAgenda[nY][10] == "1"
				oCor := LoadBitmap( GetResources(), "BR_CINZA" )
			Case aAgenda[nY][10] <> "1"
				oCor := LoadBitmap( GetResources(), "BR_VERMELHO" )
			Case aAgenda[nY][8] <> dDataBase .OR. aAgenda[nY][9] <= SubStr(Time(),1,5)
				oCor := LoadBitmap( GetResources(), "BR_VERDE" )
			Otherwise
				oCor := LoadBitmap( GetResources(), "br_azul" )
	    EndCase
	    
        aAgenda[nY][1]:= oCor
        
    Next nY
    
Endif
        
If Len(aAgenda) = 0
	aAdd(aAgenda, {	LoadBitmap( GetResources(), "BR_CINZA" ),"","","","","","","","","","",""})
Else
	If !Empty(aAgenda[1][2])//Se o array nao estiver em branco
	 	//Status+Data+Hora+Cliente+Loja
		ASort( aAgenda,,, { |x,y| ( x[10] + DtoC(x[8]) + x[9]  ) < ( y[10] + DtoC(y[8]) + y[9] ) } )
	Endif
Endif

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
oLbx:Refresh()

// Se o refresh posicionou em outro atendimento, os panels abaixo deverao ser recriados
If cAtend <> oLbx:aArray[oLbx:nAt][7]
	aPanels[Ascan(aPanels, {|x| x[2]=="BOBJ01"} )][3] := .F.
	aPanels[Ascan(aPanels, {|x| x[2]=="COBJ01"} )][3] := .F.
	aPanels[Ascan(aPanels, {|x| x[2]=="DOBJ01"} )][3] := .F.
Endif

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณTk280ACG      บAutor  ณArmando M. Tessaroliบ Data ณ21/05/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณFuncao que carrega o aHeader e o aCols da tabela ACG        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeadNew - @ Header da GetDados                             บฑฑ
ฑฑบ          ณaColsNew - @ Cols da GetDados                               บฑฑ
ฑฑบ          ณaRodape  - @ Contem os valores totais do rodape de TLC      บฑฑ
ฑฑบ          ณcCodigo  - Codigo do atendimento                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAndrea F. ณ27/04/04ณ609   ณ- Preenchimento automatico dos campos  	  บฑฑ
ฑฑบ          ณ        ณ      ณACG_BAIXA e ACG_STATUS de acordo com o SE1. บฑฑ
ฑฑบAndrea F. ณ17/11/05ณ811   ณBOPS 88872 - Permitir via parametrizacao queบฑฑ
ฑฑบ          ณ        ณ      ณo calculo de juros do titulo seja baseado   บฑฑ
ฑฑบ          ณ        ณ      ณnos parametros do SIGALOJA.                 บฑฑ
ฑฑบAndrea F. ณ21/12/05ณ811   ณBOPS 82531- Chamada da funcao componentizadaบฑฑ
ฑฑบ          ณ        ณ      ณpara calculo de juros em virtude da entrada บฑฑ
ฑฑบ          ณ        ณ      ณautomatica.                                 บฑฑ
ฑฑบAndrea F. ณ09/03/06ณ811   ณBOPS 94721 - Passagem de parametros na funcaoฑฑ
ฑฑบ          ณ        ณ      ณque calcula os valores financeiros do Contasบฑฑ
ฑฑบ          ณ        ณ      ณa Receber.                                  บฑฑ
ฑฑบAndrea F. ณ25/04/06ณ811   ณBOPS 97585 - Utilizar a ordem 2 da tabela   บฑฑ
ฑฑบ          ณ        ณ      ณSE1 para posicionar no titulo vencido do    บฑฑ
ฑฑบ          ณ        ณ      ณcliente. Passagem de dois novos parametros  บฑฑ
ฑฑบ          ณ        ณ      ณcliente e loja para utilizar na chave de    บฑฑ
ฑฑบ          ณ        ณ      ณindice.                                     บฑฑ
ฑฑบMarcelo K.ณ01/07/06ณ811   ณBOPS 101732 - Documentacao adequada das     บฑฑ
ฑฑบ          ณ        ณ      ณfuncoes.                                    บฑฑ
ฑฑบNorbert W.ณ06/02/07ณ912   ณBOPS 115792 - Compatibilizacao com o Walk-  บฑฑ
ฑฑบ          ณ        ณ      ณTrhu.                                       บฑฑ
ฑฑบNorbert W.ณ04/05/07ณ912   ณBOPS 122616 - Recalculo dos descontos dados บฑฑ
ฑฑบ          ณ        ณ      ณao titulo, considerando descontos nos juros.บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280ACG(	aHeadNew,	aColsNew,	aRodape, cCodigo,;
					cCliente, 	cLoja)

Local nUsado   		:= 0    												// Contador
Local nI	   		:= 0    												// Contador de Loop     
Local nPBaixa  		:= 0													// Log de Baixa
Local nPStatus 		:= 0   													// Status do Item
Local cFilOrig 		:= ""       											// Filial de origem do titulo
Local nPFilOrig		:=  0  													// Posicao da Filial de origem do titulo
Local nPMulta		:= 0													// Posicao do campo ACG_MULTA que armazena o valor de multa nos itens do atendimento de telecobranca  (somente para integracao com sigaloja)
Local nPJuros		:= 0													// Posicao do campo ACG_JUROS que contem o valor de juros do titulo
Local nPRecebe 		:= 0													// Posicao do campo ACG_RECEBE que armazena o valor a receber
Local nPValRef 		:= 0													// Posicao do campo ACG_VALREF que contem o valor de juros do titulo
Local aRet	   		:= {}  													// Retorno da funcao que calcula os juros do titulo baseado nos parametros do sigaloja
Local cTmkJuros		:= GetNewPar("MV_TMKAJUR","1")							// Define se o calculo de juros sera baseado nos campos do financeiro ou nos parametros do sigaloja.  1-Financeiro, 2- Sigaloja
Local aHeadBkp		:= {}													// Vetor que armazena o aHeadNew preenchido recebido
Local bAfterHeader	:= NIL													// CodeBlock executado apos a montagem do aHeadNew
Local bMontCols		:= NIL													// CodeBlock responsavel pela criacao do aColsNew

DEFAULT cCliente:= ""														// Codigo do cliente
DEFAULT cLoja	:= ""														// Loja do cliente

aColsNew	:= {}

//Zera os totais da negociacao para serem recalculados com os novos dados carregados
For nI := 1 To Len(aRodape)
	aRodape[nI][2] := 0
Next nI

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem do aHeadNew e aColsNew utilizando a FillGetDados,ณ
//ณpara utilizacao do WalkTrhu.                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
bAfterHeader	:= {|aHeadNew| ACGAfHead(		aHeadNew	, @nPBaixa	, @nPStatus		, @nPJuros	,;
												@nPRecebe	, @nPValRef	, @nPFilOrig	, @nPMulta	)}

bMontCols		:= {|aColsNew| ACGMntCols(	aHeadNew	, cCodigo	, @aColsNew	, @nPFilOrig	,;
											@cFilOrig	, @aRodape	, cCliente	, cLoja			,;
											nPBaixa		, nPStatus	, cTmkJuros		)}

If Len(aHeadNew) > 0
	aHeadBkp := aClone(aHeadNew)
	aHeadNew := {}
EndIf

FillGetDados(	2					, "ACG"			, 1				, /*cSeekKey*/		,;
				/*bSeekWhile*/		, /*bSeekFor*/	, /*aNoFields*/	, /*aYesFields*/	,;
				/*lOnlyYes*/		, /*cQuery*/	, bMontCols		, /*lEmpty*/		,;
				@aHeadNew			, @aColsNew		, /*bAfterCols*/, /*bBeforeCols*/	,;
				bAfterHeader		, /*cAliasQry*/	)

If Len(aHeadBkp) > 0
	aHeadNew := aClone(aHeadBkp)
EndIf

nUsado := Len(aHeadNew)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem da linha em branco, no caso do aColsNew estarณ
//ณvazio                                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(aColsNew)
	Aadd(aColsNew,Array(nUsado+1))
	For nI := 1 To nUsado
		If IsHeadRec(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := 0
		ElseIf IsHeadAlias(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := "ACG" 
		Else
			aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.F.)
		EndIf
	Next nI
	aColsNew[Len(aColsNew)][nUsado+1] := .F.
	
	For nI := 1 To Len(aRodape)
		aRodape[nI][2] := 0
	Next nI
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk280MemoryบAutor ณArmando M. Tessaroliบ Data ณ  06/06/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualizacao das variaveis de memoria que alimentam o objeto บฑฑ
ฑฑบ          ณda enchoice com os dados da posicao atual.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcAlias  - Nome da tabela a ser trabalhada                   บฑฑ
ฑฑบ          ณaMemory - Variaveis de memoria utilizadas pela enchoice     บฑฑ
ฑฑบ          ณlDados  - Define se as veriaveis serao iniciadas com conteudบฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280Memory(cAlias, aMemory, lDados)

Local lRet		:= .T.		// Retorno da funcao
Local cCampo	:= ""		// Nome do campo
Local nPos		:= 0		// Posicao de objeto
Local nI		:= 0		// Contador de loop

Default lDados	:= .T.		// Define se cria as variaveis com dados ou em branco

nPos := Ascan(aMemory, {|x| x[1] == cAlias })
If nPos == 0
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAlias)
	While ( !SX3->( Eof() ) .AND. SX3->X3_ARQUIVO == cAlias)
		If X3USO(SX3->X3_USADO)
			cCampo := ALLTRIM(SX3->X3_CAMPO)
			Aadd(aMemory, {cAlias, cCampo, X3_CONTEXT} )
			If lDados
				If (X3_CONTEXT # "V")
					M->&(cCampo) := (cAlias)->&(cCampo)
				Else
					M->&(cCampo) := CriaVar(cCampo, lDados)
				Endif
			Else
				M->&(cCampo) := CriaVar(cCampo, lDados)
			Endif
		Endif
		
		SX3->(DbSkip())
	End
Else
	For nI := nPos To Len(aMemory)
		cCampo := AllTrim(aMemory[nI][2])
		If lDados
			If (aMemory[nI][3] # "V")
				M->&(cCampo) := (cAlias)->&(cCampo)
			Else
				M->&(cCampo) := CriaVar(cCampo, lDados)
			Endif
		Else
			M->&(cCampo) := CriaVar(cCampo, lDados)
		Endif
		
		If aMemory[nI][1] <> cAlias
			Exit
		Endif
	End
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณTk280SE1      บAutor  ณArmando M. Tessaroliบ Data ณ21/05/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณVerifica no cadastro de titulos a receber se houve alguma   บฑฑ
ฑฑบ          ณbaixa efeturada para algum titulos do cliente com data posteบฑฑ
ฑฑบ          ณrior ao titulo que esta sendo cobrado.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeadNew - Header do browser que sera montado.              บฑฑ
ฑฑบ          ณaColsNew - Conteudo do browser que sera montado.            บฑฑ
ฑฑบ          ณaPos     - Header do ultimo atendimento onde sera pesquisadaบฑฑ
ฑฑบ          ณ           a posicao do campo da data do vencimento.        บฑฑ
ฑฑบ          ณaTitulos - Titulos do ultimo atendimento onde serao pesquisaบฑฑ
ฑฑบ          ณ           dos a ultima dade de vencimento para saber se houบฑฑ
ฑฑบ          ณ           ve um pagamento com data posterior.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280SE1(	aHeadNew,	aColsNew,	aPos,	aTitulos)

Local nUsado	:= 0								// Tamanho do aHeader(aHeadNew)
Local nI		:= 0								// Controle de loop
Local dVencIni	:= CtoD("  /  /  ")					// Data de vencimento inicial
Local nPos		:= 0								// Resultado da pesquisa no vetor aPos

#IFDEF TOP
	Local cQuery	:= ""
	Local aStruct	:= SE1->(DbStruct())
#ENDIF

aColsNew	:= {}

If Len(aPos) > 0
	nPos := Ascan(aPos, {|x| x[2] == "ACG_DTVENC" })
EndIf

If nPos > 0
	For nI := 1 To Len(aTitulos)
		If dVencIni < aTitulos[nI][nPos]
			dVendIni := aTitulos[nI][nPos]
		EndIf
	Next nI
EndIf

If Empty(aHeadNew)
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SE1")
	While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SE1"
		If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
			Aadd(aHeadNew, {   AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_F3,;
			SX3->X3_CONTEXT } )
			nUsado++
		EndIf
		DbSelectArea("SX3")
		DbSkip()
	End
Else
	nUsado := Len(aHeadNew)
EndIf

DbSelectArea("SE1")
DbSetOrder(7)	// DTOS(E1_VENCREA)+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA
#IFDEF TOP
	cQuery	:=	" SELECT	* " +;
				" FROM " +	RetSqlName("SE1") + " SE1 " +;
				" WHERE	SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND" +;
				"		SE1.E1_VENCREA >= '" + DtoS(dVencIni) + "' AND" +;
				"		SE1.E1_VALOR <> SE1.E1_SALDO AND" +;
				"		SE1.D_E_L_E_T_ = ' '" +;
				" ORDER BY " + SqlOrder(IndexKey())
		
	cQuery	:= ChangeQuery(cQuery)
	// MemoWrite("TMKA280D.SQL", cQuery)
	DbSelectArea("SE1")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1', .F., .T.)

	For nI := 1 To Len(aStruct)
		If aStruct[nI][2] $ "NDL"
			TCSetField("SE1", aStruct[nI][1], aStruct[nI][2], aStruct[nI][3], aStruct[nI][4])
		Endif
	Next nI
#ELSE
	DbSeek(xFilial("SE1") + DtoS(dVencIni))
#ENDIF

While	!SE1->(Eof()) .AND.;
		SE1->E1_FILIAL == xFilial("SE1")	.AND.;
		SE1->E1_VENCREA == dVencIni
	
	#IFNDEF TOP
		If SE1->E1_VALOR == SE1->E1_SALDO
			SE1->(DbSkip())
			Loop
		Endif
	#ENDIF
	
	Aadd(aColsNew,Array(nUsado+1))
	For nI := 1 To nUsado
		If IsHeadRec(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := 0
		ElseIf IsHeadAlias(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := "SE1" 
		ElseIf ( aHeadNew[nI,10] <>  "V" )
			aColsNew[Len(aColsNew)][nI] := SE1->(FieldGet(FieldPos(aHeadNew[nI,2])))
		Else
			aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.T.)
		EndIf
	Next nI
	aColsNew[Len(aColsNew)][nUsado+1] := .F.
	
	SE1->(DbSkip())
End

#IFDEF TOP
	DbSelectArea("SE1")
	DbCloseArea()
	ChkFile("SE1")
#ENDIF

If Empty(aColsNew)
	Aadd(aColsNew,Array(nUsado+1))
	For nI := 1 To nUsado
		If IsHeadRec(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := 0
		ElseIf IsHeadAlias(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := "SE1" 
		Else
			aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.F.)
		EndIf
	Next nI
	aColsNew[Len(aColsNew)][nUsado+1] := .F.
EndIf

Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณTk280SK1      บAutor  ณArmando M. Tessaroliบ Data ณ21/05/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณFuncao que carrega o aHeader e o aCols da tabela SK1        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeadNew - @ Header da GetDados                             บฑฑ
ฑฑบ          ณaColsNew - @ Cols da GetDados                               บฑฑ
ฑฑบ          ณaRodape  - @ Valores totais do rodape.                      บฑฑ
ฑฑบ          ณcCliente - Codigo do cliente a ser pesquisado               บฑฑ
ฑฑบ          ณcLoja    - Loja do cliente a ser pesquisado                 บฑฑ
ฑฑบ          ณlVazio   - .F. Carrega aCols, .T. Limpa o aCols             บฑฑ
ฑฑบ          ณdAtend   - Pesquisa a partir desta data                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAndrea F. ณ17/11/05ณ811   ณBOPS 88872 - Permitir via parametrizacao queบฑฑ
ฑฑบ          ณ        ณ      ณo calculo de juros do titulo seja baseado   บฑฑ
ฑฑบ          ณ        ณ      ณnos parametros do SIGALOJA.                 บฑฑ
ฑฑบAndrea F. ณ09/03/06ณ811   ณBOPS 94721 - Passagem de parametros na funcaoฑฑ
ฑฑบ          ณ        ณ      ณque calcula os valores financeiros do Contasบฑฑ
ฑฑบ          ณ        ณ      ณa Receber.                                  บฑฑ
ฑฑบAndrea F. ณ25/04/06ณ811   ณBOPS 97585 - Utilizar a ordem 2 da tabela   บฑฑ
ฑฑบ          ณ        ณ      ณSE1 para posicionar no titulo vencido do    บฑฑ
ฑฑบ          ณ        ณ      ณcliente. E na query utilizar Join dos camposบฑฑ
ฑฑบ          ณ        ณ      ณcliente e loja nas tabelas SE1 e SK1.       บฑฑ
ฑฑบNorbert W.ณ06/02/07ณ912   ณBOPS 115793 - Compatibilizacao com o Walk-  บฑฑ
ฑฑบ          ณ        ณ      ณTrhu.                                       บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280SK1(	aHeadNew,	aColsNew,	aRodape,	cCliente,;
					cLoja,		lVazio,		dAtend)

Local nUsado		:= 0												// Controle interno
Local nI			:= 0												// Controle de Loop
Local nPVencto		:= Ascan(aHeadNew, {|x| x[2] == "E1_VENCTO "} )	// Ponteiro de array
Local cFilOrig		:= ""												// Filial de Origem do titulo
Local bMontCols		:= NIL												// CodeBlock responsavel pela criacao do aColsNew
Local aYesFields	:= {}												// Vetor de campos contidos no aHeadNew
Local aHeadBkp 		:= {}												// Vetor que armazena o aHeadNew recebido
Local bAfterHeader	:= NIL												// Codeblock avaliado apos a montagem do aHeader
          	
Default cCliente	:= ACF->ACF_CLIENT									// Codigo do cliente
Default cLoja		:= ACF->ACF_LOJA									// Loja do cliente
Default lVazio		:= .F.												// Assume a carga do aCols se lVazio for NIL
Default dAtend		:= CtoD("01/01/80")									// Assume 01/01/80 como data inicial do atendimento se dAtend for NIL

aColsNew	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem do aHeadNew e aColsNew utilizando a FillGetDados,ณ
//ณpara utilizacao do WalkTrhu.                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SE1") 

While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SE1"
	If (X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL) .OR. (SX3->X3_CAMPO == "E1_FILIAL ")
		AAdd(aYesFields,AllTrim(SX3->X3_CAMPO))
	EndIf
	SX3->(DbSkip())
End

bMontCols		:= {|aColsNew| SK1MntCols(	lVazio	, aHeadNew	, @aColsNew	, cCliente	,;
											cLoja	, dAtend	, @cFilOrig	, @aRodape	)}
											
bAfterHeader	:= {|aHeadNew| SK1AftHead(@aHeadNew) }
If Len(aHeadNew) > 0
	aHeadBkp := aClone(aHeadNew)
	aHeadNew := {}
EndIf

FillGetDados(	2					, "SE1"			, 1				, /*cSeekKey*/		,;
				/*bSeekWhile*/		, /*bSeekFor*/	, /*aNoFields*/	, aYesFields		,;
				/*lOnlyYes*/		, /*cQuery*/	, bMontCols		, /*lEmpty*/		,;
				@aHeadNew			, @aColsNew		, /*bAfterCols*/, /*bBeforeCols*/	,;
				bAfterHeader	, /*cAliasQry*/	)

If Len(aHeadBkp) > 0
	aHeadNew := aClone(aHeadBkp)
EndIf

nUsado := Len(aHeadNew)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem da linha em branco, no caso do aColsNew estarณ
//ณvazio                                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(aColsNew)
	Aadd(aColsNew,Array(nUsado+1))
	For nI := 1 To nUsado
		If IsHeadRec(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := 0
		ElseIf IsHeadAlias(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := "SK1"
		Else
			aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.F.)
		EndIf
	Next nI
	aColsNew[Len(aColsNew)][nUsado+1] := .F.
	
	For nI := 1 To Len(aRodape)
		aRodape[nI][2] := 0
	Next nI
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณReordena pela data de vencimentoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aColsNew := Asort(aColsNew,,,{|x,y| x[nPVencto] < y[nPVencto]})
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณTk280ACF      บAutor  ณArmando M. Tessaroliบ Data ณ21/05/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณFuncao que carrega o aHeader e o aCols da tabela ACF        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeadNew  - @ Header da GetDados                            บฑฑ
ฑฑบ          ณaColsNew  - @ Cols da GetDados                              บฑฑ
ฑฑบ          ณcOperador - Operador para pesquisa dos dados                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNorbert W.ณ07/02/07ณ912   ณBOPS 115794 - Compatibilizacao com o Walk-  บฑฑ
ฑฑบ          ณ        ณ      ณTrhu.                                       บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280ACF(	aHeadNew,	aColsNew,	cOperador)

Local nUsado		:= 0												// Tamanho do aHeadNew
Local nI			:= 0												// Contador de Loop
Local bMontCols		:= NIL												// CodeBlock responsavel pela criacao do aColsNew
Local aHeadBkp 		:= {}												// Vetor que armazena o aHeadNew recebido

#IFDEF TOP
	Local cQuery	:= ""
	Local aStruct	:= ACF->(DbStruct())
#ENDIF

If Len(aHeadNew) > 0
	aHeadBkp := aClone(aHeadNew)
	aHeadNew := {}
EndIf

aColsNew	:= {}
bMontCols	:= {|aColsNew| ACFMntCols( cOperador, aHeadNew, @aColsNew )}

FillGetDados(	2					, "ACF"			, 1				, /*cSeekKey*/		,;
				/*bSeekWhile*/		, /*bSeekFor*/	, /*aNoFields*/	, /*aYesFields*/	,;
				/*lOnlyYes*/		, /*cQuery*/	, bMontCols		, /*lEmpty*/		,;
				@aHeadNew			, @aColsNew		, /*bAfterCols*/, /*bBeforeCols*/	,;
				/*bAfterHeader*/	, /*cAliasQry*/	)

If Len(aHeadBkp) > 0
	aHeadNew := aClone(aHeadBkp)
EndIf

nUsado := Len(aHeadNew)

If Empty(aColsNew)
	Aadd(aColsNew,Array(nUsado+1))
	For nI := 1 To nUsado
		If IsHeadRec(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := 0
		ElseIf IsHeadAlias(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := "ACF" 
		Else
			aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.F.)
		EndIf
	Next nI
	aColsNew[Len(aColsNew)][nUsado+1] := .F.
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณTk280SUC      บAutor  ณArmando M. Tessaroliบ Data ณ21/05/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณFuncao que carrega o aHeader e o aCols da tabela SUC        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeadNew - @ Header da GetDados                             บฑฑ
ฑฑบ          ณaColsNew - @ Cols da GetDados                               บฑฑ
ฑฑบ          ณnChave   - Chave de pesquisa dos Dados                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNorbert W.ณ07/02/07ณ912   ณBOPS 115796 - Compatibilizacao com o Walk-  บฑฑ
ฑฑบ          ณ        ณ      ณTrhu.                                       บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280SUC(	aHeadNew,	aColsNew,	cChave)

Local nUsado	:= 0								// Tamanho do aHeadNew
Local nI		:= 0								// Controle de loop
Local bMontCols	:= 0								// CodeBlock para montagem do aColsNew
Local aHeadBkp	:= {}								// Vetor que armazena o aHeadNew preenchido recebido

aColsNew	:= {}
bMontCols	:= {|aColsNew| SUCMntCols( cChave, aHeadNew, @aColsNew )}

If Len(aHeadNew) > 0
	aHeadBkp := aClone(aHeadNew)
	aHeadNew := {}
EndIf

FillGetDados(	2					, "SUC"			, 5				, /*cSeekKey*/		,;
				/*bSeekWhile*/		, /*bSeekFor*/	, /*aNoFields*/	, /*aYesFields*/	,;
				/*lOnlyYes*/		, /*cQuery*/	, bMontCols		, /*lEmpty*/		,;
				@aHeadNew			, @aColsNew		, /*bAfterCols*/, /*bBeforeCols*/	,;
				/*bAfterHeader*/	, /*cAliasQry*/	)

If Len(aHeadBkp) > 0
	aHeadNew := aClone(aHeadBkp)
EndIf

nUsado := Len(aHeadNew)

If Empty(aColsNew)
	Aadd(aColsNew,Array(nUsado+1))
	For nI := 1 To nUsado
		If IsHeadRec(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := 0
		ElseIf IsHeadAlias(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := "SUC" 
		Else
			aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.F.)
		EndIf
	Next nI
	aColsNew[Len(aColsNew)][nUsado+1] := .F.
EndIf

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณTk280SUD      บAutor  ณArmando M. Tessaroliบ Data ณ21/05/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณFuncao que carrega o aHeader e o aCols da tabela SUD        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeadNew - @ Header da GetDados                             บฑฑ
ฑฑบ          ณaColsNew - @ Cols da GetDados                               บฑฑ
ฑฑบ          ณnCodigo  - Codigo de pesquisa dos dados                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNorbert W.ณ07/02/07ณ912   ณBOPS 115796 - Compatibilizacao com o Walk-  บฑฑ
ฑฑบ          ณ        ณ      ณTrhu.                                       บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280SUD(	aHeadNew,	aColsNew,	cCodigo, aPanels )

Local nUsado	:= 0								// Tamanho do aHeadNew
Local nI		:= 0								// Controle de loop
Local bMontCols	:= 0								// CodeBlock para montagem do aColsNew
Local aHeadBkp	:= {}								// Vetor que armazena o aHeadNew preenchido recebido

aColsNew	:= {}

bMontCols	:= {|aColsNew| SUDMntCols( cCodigo, aHeadNew, @aColsNew )}

If Len(aHeadNew) > 0
	aHeadBkp := aClone(aHeadNew)
	aHeadNew := {}
EndIf

FillGetDados(	2					, "SUD"			, 1				, /*cSeekKey*/		,;
  				/*bSeekWhile*/		, /*bSeekFor*/	, /*aNoFields*/	, /*aYesFields*/	,;
				/*lOnlyYes*/		, /*cQuery*/	, bMontCols		, /*lEmpty*/		,;
	  			@aHeadNew			, @aColsNew		, /*bAfterCols*/, /*bBeforeCols*/	,;
				/*bAfterHeader*/	, /*cAliasQry*/	)

If Len(aHeadBkp) > 0
	aHeadNew := aClone(aHeadBkp)
EndIf

nUsado := Len(aHeadNew)

If Empty(aColsNew)
	Aadd(aColsNew,Array(nUsado+1))
	For nI := 1 To nUsado
		If IsHeadRec(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := 0
		ElseIf IsHeadAlias(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := "SUD" 
		Else
			aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.F.)
		EndIf
	Next nI
	aColsNew[Len(aColsNew)][nUsado+1] := .F.
EndIf

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณTk280SUA      บAutor  ณArmando M. Tessaroliบ Data ณ21/05/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณFuncao que carrega o aHeader e o aCols da tabela SUA        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeadNew - @ Header da GetDados                             บฑฑ
ฑฑบ          ณaColsNew - @ Cols da GetDados                               บฑฑ
ฑฑบ          ณcCliente - Codigo do cliente a ser pesquisado               บฑฑ
ฑฑบ          ณcLoja    - Loja do cliente a ser pesquisado                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNorbert W.ณ07/02/07ณ912   ณBOPS 115797 - Compatibilizacao com o Walk-  บฑฑ
ฑฑบ          ณ        ณ      ณTrhu.                                       บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280SUA(	aHeadNew,	aColsNew,	cCliente,	cLoja)

Local nUsado	:= 0								// Tamanho do aHeader(aHeadNew)
Local nI		:= 0								// Controle de loop
Local bMontCols	:= 0								// CodeBlock para montagem do aColsNew
Local aHeadBkp	:= {}								// Vetor que armazena o aHeadNew preenchido recebido

aColsNew	:= {}

bMontCols	:= {|aColsNew| SUAMntCols( cCliente, cLoja, aHeadNew, @aColsNew )}

If Len(aHeadNew) > 0
	aHeadBkp := aClone(aHeadNew)
	aHeadNew := {}
EndIf

FillGetDados(	2					, "SUA"			, 6				, /*cSeekKey*/		,;
  				/*bSeekWhile*/		, /*bSeekFor*/	, /*aNoFields*/	, /*aYesFields*/	,;
				/*lOnlyYes*/		, /*cQuery*/	, bMontCols		, /*lEmpty*/		,;
	  			@aHeadNew			, @aColsNew		, /*bAfterCols*/, /*bBeforeCols*/	,;
				/*bAfterHeader*/	, /*cAliasQry*/	)

If Len(aHeadBkp) > 0
	aHeadNew := aClone(aHeadBkp)
EndIf

nUsado := Len(aHeadNew)

If Empty(aColsNew)
	Aadd(aColsNew,Array(nUsado+1))
	For nI := 1 To nUsado
		If IsHeadRec(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := 0
		ElseIf IsHeadAlias(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := "SUA" 
		Else
			aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.F.)
		EndIf
	Next nI
	aColsNew[Len(aColsNew)][nUsado+1] := .F.
EndIf

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณTk280SUB      บAutor  ณArmando M. Tessaroliบ Data ณ21/05/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณFuncao que carrega o aHeader e o aCols da tabela SUB        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeadNew - @ Header da GetDados                             บฑฑ
ฑฑบ          ณaColsNew - @ Cols da GetDados                               บฑฑ
ฑฑบ          ณcCodigo  - Codigo para pesquisa dos dados                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNorbert W.ณ07/02/07ณ912   ณBOPS 115797 - Compatibilizacao com o Walk-  บฑฑ
ฑฑบ          ณ        ณ      ณTrhu.                                       บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280SUB(	aHeadNew,	aColsNew,	cCodigo)

Local nUsado	:= 0								// Tamanho do aHeader(aHeadNew)
Local nI		:= 0								// Controle de loop
Local bMontCols	:= 0								// CodeBlock para montagem do aColsNew
Local aHeadBkp	:= {}								// Vetor que armazena o aHeadNew preenchido recebido

aColsNew	:= {}

bMontCols	:= {|aColsNew| SUBMntCols( cCodigo, aHeadNew, @aColsNew )}

If Len(aHeadNew) > 0
	aHeadBkp := aClone(aHeadNew)
	aHeadNew := {}
EndIf

FillGetDados(	2					, "SUB"			, 1				, /*cSeekKey*/		,;
  				/*bSeekWhile*/		, /*bSeekFor*/	, /*aNoFields*/	, /*aYesFields*/	,;
				/*lOnlyYes*/		, /*cQuery*/	, bMontCols		, /*lEmpty*/		,;
	  			@aHeadNew			, @aColsNew		, /*bAfterCols*/, /*bBeforeCols*/	,;
				/*bAfterHeader*/	, /*cAliasQry*/	)

If Len(aHeadBkp) > 0
	aHeadNew := aClone(aHeadBkp)
EndIf

nUsado := Len(aHeadNew)

If Empty(aColsNew)
	Aadd(aColsNew,Array(nUsado+1))
	For nI := 1 To nUsado
		If IsHeadRec(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := 0
		ElseIf IsHeadAlias(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := "SUB" 
		Else
			aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.F.)
		EndIf
	Next nI
	aColsNew[Len(aColsNew)][nUsado+1] := .F.
EndIf

Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk280Box  บAutor  ณArmando M. Tessaroliบ Data ณ  19/02/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ   Funcao que monta um array com todas as opcoes do combo   บฑฑ
ฑฑบ          ณbox a partir da leitura do dicionario de dados SX3.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCampo - Nome do campo que sera pesquisado no SX3.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Call Center                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280Box(cCampo)
Local aArea		:= GetArea()						// Salva o ambiente atual para restauracao ao final da rotina
Local aBox		:= {}								// Conteudo do box (descricao)
Local aItens	:= {}								// Vetor de boxes
Local nI		:= 0								// Controle de loop

DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek(cCampo)
	aAdd( aBox, &('{"' + StrTran( AllTrim( X3CBox() ), ';', '","' ) + '"}' ) )
EndIf

For nI := 1 To Len(aBox[1])
	aAdd(aItens, aBox[1][nI] )
Next nI

RestArea(aArea)

Return(aItens)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk280ListaบAutor  ณArmando M. Tessaroliบ Data ณ  30/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se existe uma lista de cobranca para o operador exeบฑฑ
ฑฑบ          ณcutar.                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cOperador - Codigo do Operador do atendimento.             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280Lista(cOperador)

Local aArea		:= GetArea()						// Salva o ambiente atual para restauracao ao final da rotina
Local lRet		:= .F.								// Retorno da rotina (Existencia de lista de cobranca em aberto)

#IFDEF TOP
	Local cQuery	:= ""							// Sintaxe da query para TopConnect
	Local aStruct	:= SU4->(DbStruct())			// Estrutura da tabela SU4
	Local nI		:= 0 							// Controle de loop
#ENDIF

DbSelectArea("SU4")
DbSetOrder(5)		// U4_FILIAL+U4_OPERAD+U4_STATUS
#IFDEF TOP
	cQuery	:=	" SELECT	* " +;
				" FROM " +	RetSqlName("SU4") + " SU4 " +;
				" WHERE	SU4.U4_FILIAL = '" + xFilial("SU4") + "' AND" +;
				"		SU4.U4_OPERAD = '" + cOperador + "' AND" +;
				"		SU4.U4_DATA  <= '" + Dtos(dDatabase) + "' AND " +;  //Pendencias agendadas ate hoje
				"		SU4.U4_STATUS = '1' AND" +;
				"		SU4.U4_TELE = '3' AND" +;		// Telecobranca
				"		SU4.U4_FORMA = '1' AND" +;		// Voz
				"		SU4.D_E_L_E_T_ = ' '" +;
				" ORDER BY " + SqlOrder(IndexKey())
		
	cQuery	:= ChangeQuery(cQuery)
	// MemoWrite("TK280SU4.SQL", cQuery)
	DbSelectArea("SU4")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SU4', .F., .T.)

	For nI := 1 To Len(aStruct)
		If aStruct[nI][2] $ "NDL"
			TCSetField("SU4", aStruct[nI][1], aStruct[nI][2], aStruct[nI][3], aStruct[nI][4])
		Endif
	Next nI
#ELSE
	DbSeek(xFilial("SU4")+cOperador)
#ENDIF

While	!SU4->(Eof())						.AND.;
		SU4->U4_FILIAL == xFilial("SU4")	.AND.;
		SU4->U4_OPERAD == cOperador			.AND.;
		SU4->U4_STATUS == "1"

	If SU4->U4_DATA >= dDatabase  		//Pendencias agendadas ate hoje
		SU4->(DbSkip())
		Loop
	Endif
	
	If SU4->U4_TELE <> "3" 				// Telecobranca
		SU4->(DbSkip())
		Loop
	ElseIf SU4->U4_TELE == "3" .AND. SU4->U4_FORMA <> "1"	//Apenas Telecobranca e Voz
		SU4->(DbSkip())
		Loop
	Endif
	
	// Se chegou aqui, tem lista de cobranca em aberto para ser executada
	lRet := .T.
	Exit
	
	DbSelectArea("SU4")
	DbSkip()
End

#IFDEF TOP
	DbSelectArea("SU4")
	DbCloseArea()
	ChkFile("SU4")
#ENDIF

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณTk280AtuSK1   บAutor  ณAndrea Farias       บ Data ณ30/07/04 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณFuncao para atualizar no SK1 os titulos para o operador que บฑฑ
ฑฑบ          ณainda nao estao nomeados.       			                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Codigo do cliente                                   บฑฑ
ฑฑบ          ณExpC2 - Codigo da loja                                      บฑฑ
ฑฑบ          ณExpC3 - Codigo do Operador                                  บฑฑ
ฑฑบ          ณExpC4 - Array com as regras de cobranca                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELECOBRANCA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Tk280AtuSK1(cCliente,cLoja,cOperador,aRegras)  

Local aArea		:= GetArea()								// Salva a area anterior
Local cRegSel	:= TKPosto(cOperador,"U0_REGSEL")			// Regra de selecao do operador
Local nPos		:= 0										// Posicao do array em que se encontra a regra de selecao do operador
Local dIni  	:= dDataBase						   		// Data inicial para cobranca do titulo em atraso 
Local lRet		:= .T.										// Retorno da funcao

nPos := Ascan(aRegras, {|x| x[1] == cRegSel })	
If nPos > 0
	dIni := dDataBase - aRegras[nPos][3]		   			// Data inicial para cobranca do titulo em atraso 
Endif

DbSelectArea("SK1")
DbSetOrder(4)		// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
DbSeek(xFilial("SK1") + cCliente + cLoja + Dtos(dIni),.T.)
While	!SK1->(Eof())					.AND.;
	SK1->K1_FILIAL 	== xFilial("SK1")	.AND.;
	SK1->K1_CLIENTE	== cCliente			.AND.;
	SK1->K1_LOJA 	== cLoja

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe a data do vencimento do titulo e menor que a data inicial estipulada para o   ณ
	//ณo operador realizar a cobranca significa que a cobranca sera feita por outro     ณ
	//ณgrupo. Dessa forma nao atualizo o codigo do operador, e a Funcao que limpa o     ณ
    //ณcodigo do operador  no SK1 Tk280SU4() se encarregara de passar para outro grupo  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	If SK1->K1_VENCREA < dIni 
		Exit
	Endif	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSomente atualiza o codigo do operador se o titulo pertencer ao seu grupo.   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(cOperador)  .AND. Empty(SK1->K1_OPERAD)
		RecLock("SK1", .F.)
		REPLACE SK1->K1_OPERAD WITH cOperador
		MsUnLock()
	Endif
	DbSelectArea("SK1")	
	Dbskip()
End

RestArea(aArea)

Return(lRet) 
	  	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK280Pago บAutor  ณAndrea Farias       บ Data ณ  08/19/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se todos os titulos informados em um atendimento   บฑฑ
ฑฑบ          ณde telecobranca foram pagos. 								  บฑฑ
ฑฑบ          ณ1)Atualiza o atendimento com a situacao atual do titulo     บฑฑ
ฑฑบ          ณ2)Atualiza o SE5 (Movimento Bancario) com o codigo do  	  บฑฑ
ฑฑบ          ณ operador que realizou a cobranca, quando sofrer baixa.     บฑฑ
ฑฑบ          ณ3)Deleta o registro do SK1 quando o titulo foi pago.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER TELECOBRANCA       	                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAndrea F. ณ04/02/05ณ811   ณ- Passagem dos parametros Cliente e Loja    บฑฑ
ฑฑบAndrea F. ณ06/07/05ณ811   ณ- Nao atualizar o SE5 (Movimento Bancario)  บฑฑ
ฑฑบ          ณ        ณ      ณquando nao existir negociacao (atendimento).บฑฑ
ฑฑบAndrea F. ณ25/04/06ณ811   ณBOPS 97585 - Utilizar a ordem 2 da tabela   บฑฑ
ฑฑบ          ณ        ณ      ณSE1 para posicionar no titulo vencido do    บฑฑ
ฑฑบ          ณ        ณ      ณcliente.                                    บฑฑ
ฑฑบMarcelo K.ณ10/09/06ณ811   ณBOPS 104687 - Correcao de sintaxe do campo  บฑฑ
ฑฑบ          ณ        ณ      ณACG_PREFIX                                  บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280Pago(cCodAtend,cOperador,cCliente,cLoja)
                        
Local aArea		:= GetArea() 	// Salva a area atual
Local nACG		:= 0           	// Contador dos titulos processados do ACG
Local nSE1  	:= 0           	// Contador dos titulos baixados do SE1
Local nSK1		:= 0			// Contador dos titulos baixados do SK1
Local cBaixa	:= ""			// Flag de baixa do titulo para ser atualizado no ACG
Local lRet		:= .F.			// Retorno da funcao
Local cFilOrig	:= ""			// Filial Original do titulo

If !Empty(cCodAtend)
	DbSelectArea("ACF")
	DbSetOrder(1)
	If DbSeek(xFilial("ACF") + cCodAtend )
	
		DbSelectArea("ACG")
		DbSetOrder(1)
		If DbSeek(xFilial("ACG") + ACF->ACF_CODIGO)
			While	!ACG->(Eof())						.AND.;
				ACG->ACG_FILIAL == xFilial("ACF")		.AND.;
				ACG->ACG_CODIGO == ACF->ACF_CODIGO
				nACG++
				cFilOrig	:= ACG_FILORI
							
				If ACG->ACG_STATUS == "1" //Pago
					nSE1++
					DbSelectArea("ACG")
					DbSkip()
					Loop
				Endif
	   
				DbSelectArea("SE1")
				DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
				If DbSeek(cFilOrig + cCliente + cLoja + ACG->ACG_PREFIX + ACG->ACG_TITULO + ACG->ACG_PARCEL + ACG->ACG_TIPO)
					If !Empty(SE1->E1_BAIXA) .AND. SE1->E1_SALDO > 0
						cBaixa := "4"	// Baixa parcial
					ElseIf  SE1->E1_SALDO <= 0
						cBaixa := "1"	// Pago
					Endif
					
					If !Empty(cBaixa)			
						Begin Transaction
						
							DbSelectArea("ACG")
							RecLock("ACG", .F.)
							REPLACE ACG->ACG_STATUS WITH cBaixa
							MsUnLock()
								
							If cBaixa == "1"	// Pago Totalmente
								nSE1++
								DbSelectArea("SK1")
								DbSetOrder(1)
								If DbSeek(xFilial("SK1") + ACG->ACG_PREFIX + ACG->ACG_TITULO + ACG->ACG_PARCEL + ACG->ACG_TIPO + cFilOrig)
									RecLock("SK1", .F., .T.)
									DbDelete()
									MsUnLock()
								Endif
							Endif
									
						End Transaction
				    Endif
				
				Endif
		        
		        cBaixa:= ""
				DbSelectArea("ACG")
				DbSkip()
	
			End  
		
			If nACG == nSE1
				lRet:= .T.
			Endif	
		Endif	
	Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณQuando nao existir um atendimento, pesquiso diretamente no SE1ณ
//ณpara checar se todos os titulos foram pagos.                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf !Empty(cCliente) .AND. !Empty(cLoja)
	DbSelectArea("SK1")
	DbSetOrder(4)		// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
	If DbSeek(xFilial("SK1") + cCliente + cLoja)
		While	!SK1->(Eof())					.AND.;
			SK1->K1_FILIAL 	== xFilial("SK1")	.AND.;
			SK1->K1_CLIENTE	== cCliente			.AND.;
			SK1->K1_LOJA 	== cLoja
			nSK1++
			cFilOrig	:= K1_FILORIG


			DbSelectArea("SE1")
			DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
			If DbSeek(cFilOrig + cCliente + cLoja + SK1->K1_PREFIXO + SK1->K1_NUM + SK1->K1_PARCELA + SK1->K1_TIPO)
				If SE1->E1_SALDO <= 0

					nSE1++
				
					DbSelectArea("SK1")
					RecLock("SK1", .F., .T.)
					DbDelete()
					MsUnLock()
					
				Endif
            Endif
           
			DbSelectArea("SK1")
			Dbskip()	
		End
		
		If nSK1 == nSE1
			lRet:= .T.
		Endif	
	Endif	
Endif

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณACGAfHead     บAutor  ณNorbert Waage Juniorบ Data ณ06/02/07 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณRotina de armazenamento das posicoes dos campos do aHeader  บฑฑ
ฑฑบ          ณutilizado no preenchimento do aColsNew                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeadNew   - aHeader para GetDados da tabela ACG            บฑฑ
ฑฑบ          ณnPBaixa    - Posicao da baixa no aHeader                    บฑฑ
ฑฑบ          ณnPStatus   - Posicao do status no aHeader                   บฑฑ
ฑฑบ          ณnPJuros    - Posicao do juros no aHeader                    บฑฑ
ฑฑบ          ณnPRecebe   - Posicao do valor a receber no aHeader          บฑฑ
ฑฑบ          ณnPValRef   - Posicao do valor dos juros no aHeader          บฑฑ
ฑฑบ          ณnPFilOrig  - Posicao da Filial original do titulo no aHeaderบฑฑ
ฑฑบ          ณnPMulta    - Posicao do valor da multa no aHeader           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELECOBRANCA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ACGAfHead(	aHeadNew	, nPBaixa	, nPStatus	, nPJuros	,;
							nPRecebe	, nPValRef	, nPFilOrig	, nPMulta	)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBusca no aHeader a posicao do campo ACG_BAIXAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPBaixa 	:= Ascan(aHeadNew, {|x| x[2] == "ACG_BAIXA "} )			
nPStatus	:= Ascan(aHeadNew, {|x| x[2] == "ACG_STATUS"} )			
nPJuros		:= Ascan(aHeadNew, {|x| x[2] == "ACG_JUROS "} )
nPRecebe 	:= Ascan(aHeadNew, {|x| x[2] == "ACG_RECEBE"} )
nPValRef	:= Ascan(aHeadNew, {|x| x[2] == "ACG_VALREF"} )

nPFilOrig:= Ascan(aHeadNew, {|x| x[2] == "ACG_FILORI"} )					

nPMulta	:= Ascan(aHeadNew, {|x| x[2] == "ACG_MULTA "} )


Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณACGMntCols    บAutor  ณNorbert Waage Juniorบ Data ณ06/02/07 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณRotina de criacao do vetor aColsNew, estruturado de modo a  บฑฑ
ฑฑบ          ณcontemplar a rotina de WalkThru para a tabela ACG.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeadNew   - aHeader para GetDados da tabela ACG            บฑฑ
ฑฑบ          ณcCodigo    - Codigo do atendimento para pesquisa            บฑฑ
ฑฑบ          ณaColsNew   - aCols para GetDados da tabela ACG              บฑฑ
ฑฑบ          ณnPFilOrig  - Posicao da Filial original do titulo no aHeaderบฑฑ
ฑฑบ          ณcFilOrig   - Filial de origem do titulo                     บฑฑ
ฑฑบ          ณaRodape    - Valores dos campos do rodape para TLC          บฑฑ
ฑฑบ          ณcCliente   - Codigo do cliente                              บฑฑ
ฑฑบ          ณcLoja      - Loja do cliente                                บฑฑ
ฑฑบ          ณnPBaixa    - Posicao da baixa no aHeader                    บฑฑ
ฑฑบ          ณnPStatus   - Posicao do status no aHeader                   บฑฑ
ฑฑบ          ณcTmkJuros  - Tipo de calculo de juros                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELECOBRANCA                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑบฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบฑฑ
ฑฑบMichel M. ณ13/03/07ณ9.12  ณBOPS 115794-Corrigida query de selecao      บฑฑ
ฑฑบ          ณ        ณ      ณ    que gerava nao conformidade com DB2.    บฑฑ
ฑฑบNorbert W.ณ20/06/07ณ912   ณBOPS 127031 - Alteracao do sexto parametro  บฑฑ
ฑฑบ          ณ        ณ      ณna chamada da funcao FaVlAtuCr(), para que  บฑฑ
ฑฑบ          ณ        ณ      ณsejam calculados os abatimentos do titulo.  บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ACGMntCols(	aHeadNew	, cCodigo	, aColsNew	, nPFilOrig	,;
							cFilOrig	, aRodape	, cCliente	, cLoja		,;
							nPBaixa		, nPStatus	, cTmkJuros	)

Local cQuery 	:= ""											//Conteudo da query
Local lQuery	:= .F.											//Indica se a rotina esta em ambiente TopConnect
Local nI		:= 0											//Contador
Local aStruct	:= {}											//Array que armazenara a estrutura da tabela ACG
Local nUsado	:= Len(aHeadNew)								//Tamanho do vetor aHeadNew
Local nLin		:= 0											//Linha atual do vetor aColsNew
Local aValores	:= {}											//Array com os valores do titulo
Local nPDescFi	:= 0											// Posicao do campo ACG_DESCFI que contem o percentual de desconto sobre o valor do titulo
Local nPDescJu	:= 0											// Posicao do campo ACG_DESCJU que contem o percentual de desconto sobre os juros do titulo
Local nPSituac	:= 0
Local nPDSituac	:= 0


If !Empty(cCodigo)

	DbSelectArea("ACG")
	DbSetOrder(1)
	
  	#IFDEF TOP
		aStruct	:= ACG->(DbStruct())
		
		cQuery	:=	" SELECT	* " +;
		" FROM " +	RetSqlName("ACG") + " ACG " +;
		" WHERE	ACG.ACG_FILIAL = '" + xFilial("ACG") + "' AND" +;
		"		ACG.ACG_CODIGO = '" + cCodigo + "' AND" +;
		"		ACG.D_E_L_E_T_ = ' '" +;
		" ORDER BY " + SqlOrder(IndexKey())
		
		cQuery	:= ChangeQuery(cQuery)
		// MemoWrite("TK280ACG.SQL", cQuery)
		DbSelectArea("ACG")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACG', .F., .T.)
		
		For nI := 1 To Len(aStruct)
			If aStruct[nI][2] $ "NDL"
				TCSetField("ACG", aStruct[nI][1], aStruct[nI][2], aStruct[nI][3], aStruct[nI][4])
			Endif
		Next nI
		
		lQuery := .T.
		
	#ELSE
		ACG->(DbSeek(xFilial("ACG")+cCodigo))
	#ENDIF
	
	nPDescFi	:= aScan(aHeadNew, {|x| x[2] == "ACG_DESCFI"} )
	nPDescJu	:= aScan(aHeadNew, {|x| x[2] == "ACG_DESCJU"} )
	nPSituac	:= aScan(aHeadNew, {|x| x[2] == "ACG_SITUAC"} )
	nPDSituac	:= aScan(aHeadNew, {|x| x[2] == "ACG_DSITCB"} )    
	
	DbSelectArea("SE1")
	DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Numero + Parcela + Tipo
	

	While !ACG->(Eof()) .AND.;
		ACG->ACG_FILIAL == xFilial("ACG")	.AND.;
		ACG->ACG_CODIGO == cCodigo
		
		If nPFilOrig > 0
			cFilOrig:= ACG->ACG_FILORI
		Else
			cFilOrig:= xFilial("SE1")
		Endif
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCria uma linha no acols temporarioณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
		Aadd(aColsNew,Array(nUsado+1))
		nLin := Len(aColsNew)
		For nI := 1 To nUsado
			If IsHeadRec(aHeadNew[nI][2])
            	#IFDEF TOP
                	aColsNew[nLin][nI] := ACG->R_E_C_N_O_
             	#ELSE
                	aColsNew[nLin][nI] := ACG->(Recno())			                                
              	#ENDIF								
			ElseIf IsHeadAlias(aHeadNew[nI][2])
				aColsNew[nLin][nI] := "ACG"
			ElseIf ( aHeadNew[nI,10] <>  "V" )
				aColsNew[nLin][nI] := ACG->(FieldGet(FieldPos(aHeadNew[nI,2])))
			Else
				aColsNew[nLin][nI] := CriaVar(aHeadNew[nI,2],.T.)
			EndIf
		Next nI
		aColsNew[nLin][nUsado+1] := .F.
		
		If Len(aRodape) > 0
			
			If !Empty(cCliente) .AND. !Empty(cLoja)
				
				If SE1->(DbSeek(cFilOrig + cCliente + cLoja + ACG->ACG_PREFIX + ACG->ACG_TITULO + ACG->ACG_PARCEL + ACG->ACG_TIPO))
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณAtualiza o campo Baixa com o status da Baixaณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					Do Case
						Case !Empty(SE1->E1_BAIXA) // Se houve uma baixa verifica se foi TOTAL ou PARCIAL
							If (SE1->E1_SALDO > 0)
								aColsNew[nLin][nPBaixa] := "1" //Baixa Parcial
								aColsNew[nLin][nPStatus]:= "4" //Baixa
							Endif
							
							If (SE1->E1_SALDO == 0)
								aColsNew[nLin][nPBaixa] := "3" //Baixa Total
								aColsNew[nLin][nPStatus]:= "1" //Pago
							Endif
							
						Case Empty(SE1->E1_BAIXA) // Nao houve nenhuma baixa
							aColsNew[nLin][nPBaixa] := "2" //Sem Baixa
							
					EndCase

					If nPSituac > 0
						aColsNew[nLin][nPSituac] := SE1->E1_SITUACA 
					EndIf
				
					If nPDSituac > 0
						aColsNew[nLin][nPDSituac] := Posicione("FRV",1,xFilial("FRV")+SE1->E1_SITUACA,"FRV_DESCRI")	//Descricao da situa็ใo do tํtulo
					EndIf
					
					/*
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ   Retorno   ณExpA1: Array com a seguinte estrutura                        ณ
					//ณ             ณ       [1] Valor Original do Titulo                          ณ
					//ณ             ณ       [2] Abatimentos                                       ณ
					//ณ             ณ       [3] Pagto Parcial                                     ณ
					//ณ             ณ       [4] Decrescimo                                        ณ
					//ณ             ณ       [5] Acrescimo                                         ณ
					//ณ             ณ       [6] Saldo do Titulo na Moeda do Titulo                ณ
					//ณ             ณ       [7] Saldo do Titulo na Moeda Corrente                 ณ
					//ณ             ณ       [8] Juros                                             ณ
					//ณ             ณ       [9] Desconto                                          ณ
					//ณ             ณ       [10] Correcao Monetaria                               ณ
					//ณ             ณ       [11] Valor a ser Recebido na moeda do titulo          ณ
					//ณ             ณ       [12] Valor a ser Recebido na moeda corrente           ณ
					//ณ             ณ       [13] Multa                                            ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					*/
					aValores := FaVlAtuCr(	NIL		, NIL	, NIL	, NIL	,;
											cFilOrig, .T.	)
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณSe o calculo dos juros do titulo for baseado nos parametros MV_LJJUROS e MV_LJMULT ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If cTmkJuros == "2"
						Tk274CalcJuros(	@aValores	, @aColsNew, aHeadNew, NIL,;
						cCliente	, cLoja)
					Endif
					
					// [1] Valor Original do Titulo
					// [2] Abatimentos
					// [3] Pagto Parcial
					// [4] Decrescimo					
					// [5] Acrescimo
					// [6] Saldo do Titulo na Moeda do Titulo
					// [7] Saldo do Titulo na Moeda Corrente					
					// [8] Juros
					// [9] Desconto
					// [A] Correcao Monetaria				
					// [B] Valor a ser Recebido na moeda do titulo
					// [C] Valor a ser Recebido na moeda corrente
					
					//aRodape
					//1 - Abatimentos
					//2 - Corr. Monetaria
					//3 - Juros
					//4 - Acrescimos
					//5 - Descrescimos
					//6 - Descontos
					//7 - Valor Original
					//8 - Sld Mda Tit.
					//9 - Sld Mda Corr.
					//10- Pagto Parcial
					//11- Dํv Mda Tํt
					//12- Dํv Mda Corr
					
					aRodape[1][2]	:= aRodape[1][2] + aValores[2]
					aRodape[2][2]	:= aRodape[2][2] + aValores[10]
					aRodape[3][2]	:= aRodape[3][2] + aValores[8]
					aRodape[4][2]	:= aRodape[4][2] + ACG->ACG_ACRESC
					aRodape[5][2]	:= aRodape[5][2] + ACG->ACG_DECRESC
					aRodape[6][2]	:= aRodape[6][2] 
					aRodape[7][2]	:= aRodape[7][2] + aValores[1]
					aRodape[8][2]	:= aRodape[8][2] + aValores[6]
					aRodape[9][2]	:= aRodape[9][2] + aValores[7]
					aRodape[10][2]	:= aRodape[10][2] + aValores[3]
					aRodape[11][2]	:= aRodape[11][2] + aValores[11] + aValores[9] + ACG->ACG_ACRESC - ACG->ACG_DECRESC
					aRodape[12][2]	:= aRodape[12][2] + aValores[12] + aValores[9] + ACG->ACG_ACRESC - ACG->ACG_DECRESC
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณRecalcula os descontos ja aplicadosณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู						
					Tk274DescFi(	aColsNew[Len(aColsNew)][nPDescFi]	, aColsNew	, Len(aColsNew)	, TkOperador()	,;
									aHeadNew 							, @aRodape	, .T.)
										
		            If (nPDescJu <> 0) 
			            Tk274DescJu(aColsNew[Len(aColsNew)][nPDescJu]	, aColsNew	, Len(aColsNew)	, TkOperador()	,;
			            			aHeadNew							, @aRodape	, .T.)
			        EndIf

					aRodape[01][01]:Refresh()
					aRodape[02][01]:Refresh()
					aRodape[03][01]:Refresh()
					aRodape[04][01]:Refresh()
					aRodape[05][01]:Refresh()
					aRodape[06][01]:Refresh()
					aRodape[07][01]:Refresh()
					aRodape[08][01]:Refresh()
					aRodape[09][01]:Refresh()
					aRodape[10][01]:Refresh()
					aRodape[11][01]:Refresh()
					aRodape[12][01]:Refresh()

				Endif
			Endif
		Endif
		
		ACG->(DbSkip())
	End 
	
	#IFDEF TOP
		DbSelectArea("ACG")
		DbCloseArea()
		ChkFile("ACG")
	#ENDIF

EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณSK1MntCols    บAutor  ณNorbert Waage Juniorบ Data ณ06/02/07 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณRotina de criacao do vetor aColsNew, estruturado de modo a  บฑฑ
ฑฑบ          ณcontemplar a rotina de WalkThru para a tabela SK1.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณlVazio     - Indica se o aColsNew nao deve ser montado      บฑฑ
ฑฑบ          ณaHeadNew   - aHeader para GetDados da tabela SK1(SE1)       บฑฑ
ฑฑบ          ณaColsNew   - aCols para GetDados da tabela SK1              บฑฑ
ฑฑบ          ณcCliente   - Codigo do cliente                              บฑฑ
ฑฑบ          ณcLoja      - Loja do cliente                                บฑฑ
ฑฑบ          ณdAtend     - Pesquisa a partir desta data                   บฑฑ
ฑฑบ          ณcFilOrig   - Filial de origem do titulo                     บฑฑ
ฑฑบ          ณaRodape    - Valores dos campos do rodape para TLC          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELECOBRANCA                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑบฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบฑฑ
ฑฑบMichel M. ณ13/03/07ณ9.12  ณBOPS 115794-Corrigida query de selecao      บฑฑ
ฑฑบ          ณ        ณ      ณ    que gerava nao conformidade com DB2.    บฑฑ
ฑฑบMichel M. ณ23/04/07ณ9.12  ณBOPS 124639-Correcao no alias utilizado peloบฑฑ
ฑฑบ          ณ        ณ      ณfieldget e fieldpos ao preencher o aCols.   บฑฑ
ฑฑบNorbert W.ณ20/06/07ณ912   ณBOPS 127031 - Alteracao do sexto parametro  บฑฑ
ฑฑบ          ณ        ณ      ณna chamada da funcao FaVlAtuCr(), para que  บฑฑ
ฑฑบ          ณ        ณ      ณsejam calculados os abatimentos do titulo.  บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SK1MntCols(	lVazio	, aHeadNew	, aColsNew	, cCliente	,;
							cLoja	, dAtend	, cFilOrig	, aRodape	)

Local aStructSK1:= {}										// Estrutura da tabela SK1
Local aStructSE1:= {}										// Estrutura da tabela SE1
Local cSE1		:= ""										// Nome do alias SE1 utilizado na rotina
Local cQuery	:= ""										// Conteudo da query
Local lQuery	:= .F.										// Indica se a rotina utiliza TopConnect
Local aValores	:= {}										// Array com os valores do titulo
Local nUsado	:= Len(aHeadNew)							// Tamanho do vetor aHeadNew
Local nI		:= 0										// Controle de Loop
Local lNewRolTLC:= IIf( FindFunction( 'Tk280NewTC' ), Tk280NewTC(), .F. )

If !lVazio

	DbSelectArea("SK1")
	DbSetOrder(4)	// K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)

	#IFDEF TOP
		
		lQuery		:= .T.
		aStructSK1	:= SK1->(DbStruct())
		aStructSE1	:= SE1->(DbStruct())
	
		cSE1 	:= "SK1"
		cQuery	:=	" SELECT	* "
		cQuery	+=	" FROM " +	RetSqlName("SK1") + " SK1, " + RetSqlName("SE1") + " SE1 "
		cQuery	+=	" WHERE	SK1.K1_FILIAL = '" + xFilial("SK1") + "' AND"
		cQuery	+=	"		SK1.K1_CLIENTE = '" + cCliente + "' AND"
		cQuery	+=	"		SK1.K1_LOJA = '" + cLoja + "' AND"
		cQuery	+=	"		SK1.K1_VENCREA BETWEEN '" + DtoS(dAtend) + "' AND '" + DtoS(dDataBase) + "' AND"
		cQuery	+=	"		SK1.K1_OPERAD <> 'XXXXXX' AND"
		If ( lNewRolTLC )
			cQuery	+=	"		SK1.K1_DTFRENE = '        ' AND"
			cQuery	+=	"		SK1.K1_HRFRENE = '     '    AND"
		EndIf
		cQuery	+=	"		SK1.D_E_L_E_T_ = ' ' AND" 

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณTratamento para filtrar apenas os titulos da filial de origem.  ณ
					//ณSe o campo nao estiver criado, assumo a filial corrente do SE1. ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cQuery+= "	SE1.E1_FILIAL 	= SK1.K1_FILORIG 	AND"
		cQuery+= "		SE1.E1_CLIENTE 	= SK1.K1_CLIENTE AND"
		cQuery+= "		SE1.E1_LOJA 	= SK1.K1_LOJA AND"
		cQuery+= "		SE1.E1_PREFIXO 	= SK1.K1_PREFIXO AND"
		cQuery+= "		SE1.E1_NUM 		= SK1.K1_NUM AND"
		cQuery+= "		SE1.E1_PARCELA 	= SK1.K1_PARCELA AND"
		cQuery+= "		SE1.E1_TIPO 	= SK1.K1_TIPO AND"
		cQuery+= "		SE1.D_E_L_E_T_ = ' '"
		cQuery+= " ORDER BY " + SqlOrder(IndexKey())
		
		cQuery	:= ChangeQuery(cQuery)
		//MemoWrite("TK280SK1.SQL", cQuery)
		DbSelectArea("SK1")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SK1', .F., .T.)
	
		For nI := 1 To Len(aStructSK1)
			If aStructSK1[nI][2] $ "NDL"
				TCSetField("SK1", aStructSK1[nI][1], aStructSK1[nI][2], aStructSK1[nI][3], aStructSK1[nI][4])
			Endif
		Next nI
	
		For nI := 1 To Len(aStructSE1)
			If aStructSE1[nI][2] $ "NDL"
				TCSetField("SK1", aStructSE1[nI][1], aStructSE1[nI][2], aStructSE1[nI][3], aStructSE1[nI][4])
			Endif
		Next nI
	#ELSE
		SK1->(DbSeek(xFilial("SK1") + cCliente + cLoja + DtoS(dAtend),.T.))
	#ENDIF

	DbSelectArea("SE1")
	DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
	
	While	!SK1->(Eof())						.AND.;
			SK1->K1_FILIAL	== xFilial("SK1")	.AND.;
			SK1->K1_CLIENTE	== cCliente			.AND.;
			SK1->K1_LOJA	== cLoja			.AND.;
			SK1->K1_VENCREA	>= dAtend			.AND.;
			SK1->K1_VENCREA	<= dDataBase
	
			cFilOrig:= SK1->K1_FILORIG


		#IFNDEF TOP
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe for um registro marcado como EXCECAO de cobranca nao carregaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If SK1->K1_OPERAD == "XXXXXX"
				SK1->(DbSkip())
				Loop
			Endif
			
			If !SE1->(DbSeek(cFilOrig + SK1->K1_CLIENTE + SK1->K1_LOJA + SK1->K1_PREFIXO + SK1->K1_NUM + SK1->K1_PARCELA + SK1->K1_TIPO))
				SK1->(DbSkip())
				Loop
			Endif

		#ENDIF
		
		Aadd(aColsNew,Array(nUsado+1))
		For nI := 1 To nUsado
			If IsHeadRec(aHeadNew[nI][2])  			
            	#IFDEF TOP
                	aColsNew[Len(aColsNew)][nI] := SK1->R_E_C_N_O_
             	#ELSE
                	aColsNew[Len(aColsNew)][nI] := SK1->(Recno())			                                
              	#ENDIF			
			ElseIf IsHeadAlias(aHeadNew[nI][2])
				aColsNew[Len(aColsNew)][nI] := "SK1" 
			ElseIf ( aHeadNew[nI,10] <>  "V" )
				#IFDEF TOP
					aColsNew[Len(aColsNew)][nI] := SK1->(FieldGet(FieldPos(aHeadNew[nI,2])))
				#ELSE
					aColsNew[Len(aColsNew)][nI] := SE1->(FieldGet(FieldPos(aHeadNew[nI,2])))
				#ENDIF
			Else
				aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.T.)
			EndIf
		Next nI
		aColsNew[Len(aColsNew)][nUsado+1] := .F.
		
		If Len(aRodape) > 0

			If SE1->(DbSeek(cFilOrig + SK1->K1_CLIENTE + SK1->K1_LOJA + SK1->K1_PREFIXO + SK1->K1_NUM + SK1->K1_PARCELA + SK1->K1_TIPO))
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ   Retorno   ณExpA1: Array com a seguinte estrutura                        ณ
				//ณ             ณ       [1] Valor Original do Titulo                          ณ
				//ณ             ณ       [2] Abatimentos                                       ณ
				//ณ             ณ       [3] Pagto Parcial                                     ณ
				//ณ             ณ       [4] Decrescimo                                        ณ
				//ณ             ณ       [5] Acrescimo                                         ณ
				//ณ             ณ       [6] Saldo do Titulo na Moeda do Titulo                ณ
				//ณ             ณ       [7] Saldo do Titulo na Moeda Corrente                 ณ
				//ณ             ณ       [8] Juros                                             ณ
				//ณ             ณ       [9] Desconto                                          ณ
				//ณ             ณ       [10] Correcao Monetaria                               ณ
				//ณ             ณ       [11] Valor a ser Recebido na moeda do titulo          ณ
				//ณ             ณ       [12] Valor a ser Recebido na moeda corrente           ณ
				//ณ             ณ       [13] Multa                                            ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				
				aValores := FaVlAtuCr(	NIL		, NIL	, NIL	, NIL	,;
										cFilOrig, .T.	)

				// [2] Abatimentos
				// [A] Correcao Monetaria
				// [8] Juros
				// [5] Acrescimo
				// [4] Decrescimo
				// [9] Desconto
				// [1] Valor Original do Titulo
				// [6] Saldo do Titulo na Moeda do Titulo
				// [7] Saldo do Titulo na Moeda Corrente
				// [3] Pagto Parcial
				// [B] Valor a ser Recebido na moeda do titulo
				// [C] Valor a ser Recebido na moeda corrente
				
				aRodape[1][2]	:= aRodape[1][2] + aValores[2]
				aRodape[2][2]	:= aRodape[2][2] + aValores[10]
				aRodape[3][2]	:= aRodape[3][2] + aValores[8]
				aRodape[4][2]	:= aRodape[4][2] + aValores[5]
				aRodape[5][2]	:= aRodape[5][2] + aValores[4]
				aRodape[6][2]	:= aRodape[6][2] + aValores[9]
				aRodape[7][2]	:= aRodape[7][2] + aValores[1]
				aRodape[8][2]	:= aRodape[8][2] + aValores[6]
				aRodape[9][2]	:= aRodape[9][2] + aValores[7]
				aRodape[10][2]	:= aRodape[10][2] + aValores[3]
				aRodape[11][2]	:= aRodape[11][2] + aValores[11]
				aRodape[12][2]	:= aRodape[12][2] + aValores[12]
				
				aRodape[1][1]:Refresh()
				aRodape[2][1]:Refresh()
				aRodape[3][1]:Refresh()
				aRodape[4][1]:Refresh()
				aRodape[5][1]:Refresh()
				aRodape[6][1]:Refresh()
				aRodape[7][1]:Refresh()
				aRodape[8][1]:Refresh()
				aRodape[9][1]:Refresh()
				aRodape[10][1]:Refresh()
				aRodape[11][1]:Refresh()
				aRodape[12][1]:Refresh()
			Endif
		Endif

		SK1->(DbSkip())	
	End
	
	#IFDEF TOP
		DbSelectArea("SK1")
		DbCloseArea()
		ChkFile("SK1")
	#ENDIF
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณACFMntCols    บAutor  ณNorbert Waage Juniorบ Data ณ07/02/07 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณRotina de criacao do vetor aColsNew, estruturado de modo a  บฑฑ
ฑฑบ          ณcontemplar a rotina de WalkThru para a tabela ACF.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcOperador  - Codigo do operador                             บฑฑ
ฑฑบ          ณaHeadNew   - aHeader para GetDados da tabela ACF            บฑฑ
ฑฑบ          ณaColsNew   - aCols para GetDados da tabela ACF              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELECOBRANCA                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑบฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบฑฑ
ฑฑบMichel M. ณ13/03/07ณ9.12  ณBOPS 115794-Corrigida query de selecao      บฑฑ
ฑฑบ          ณ        ณ      ณ    que gerava nao conformidade com DB2.    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ACFMntCols( cOperador, aHeadNew, aColsNew )

Local cQuery	:= ""											//Conteudo da query
Local aStruct	:= {}											//Array que armazenara a estrutura da tabela ACG
Local nI		:= 0											//Variavel de controle de loop
Local nUsado	:= Len(aHeadNew)								//Tamanho do vetor aHeadNew
Local lQuery	:= .F.

If !Empty(cOperador)

	DbSelectArea("ACF")
	DbSetOrder(4)	// DTOS(ACF_DATA)

	#IFDEF TOP

		aStruct	:= ACF->(DbStruct())
		lQuery	:= .T.

		cQuery	:=	" SELECT	* " +;
					" FROM " +	RetSqlName("ACF") + " ACF " +;
					" WHERE	ACF.ACF_FILIAL = '" + xFilial("ACF") + "' AND" +;
					"		ACF.ACF_DATA = '" + DtoS(dDataBase) + "' AND" +;
					"		ACF.ACF_OPERAD = '" + cOperador + "' AND" +;
					"		ACF.D_E_L_E_T_ = ' '" +;
					" ORDER BY " + SqlOrder(IndexKey())
			
		cQuery	:= ChangeQuery(cQuery)
		// MemoWrite("TK280ACF.SQL", cQuery)

		DbSelectArea("ACF")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACF', .F., .T.)
	
		For nI := 1 To Len(aStruct)
			If aStruct[nI][2] $ "NDL"
				TCSetField("ACF", aStruct[nI][1], aStruct[nI][2], aStruct[nI][3], aStruct[nI][4])
			Endif
		Next nI
	#ELSE
		DbSeek(xFilial("ACF") + DtoS(dDataBase))
	#ENDIF
	
	While	!ACF->(Eof()) .AND.;
			ACF->ACF_FILIAL == xFilial("ACF")	.AND.;
			ACF->ACF_DATA == dDataBase
		
		If ACF->ACF_OPERAD <> cOperador
			ACF->(DbSkip())
			Loop
		Endif
		
		Aadd(aColsNew,Array(nUsado+1))
		For nI := 1 To nUsado
			If IsHeadRec(aHeadNew[nI][2])   
            	#IFDEF TOP
                	aColsNew[Len(aColsNew)][nI] := ACF->R_E_C_N_O_
             	#ELSE
                	aColsNew[Len(aColsNew)][nI] := ACF->(Recno())			                                
              	#ENDIF			
			ElseIf IsHeadAlias(aHeadNew[nI][2])
				aColsNew[Len(aColsNew)][nI] := "ACF" 
			ElseIf ( aHeadNew[nI,10] <>  "V" )
				aColsNew[Len(aColsNew)][nI] := ACF->(FieldGet(FieldPos(aHeadNew[nI,2])))
			Else
				aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.T.)
			EndIf
		Next nI
		aColsNew[Len(aColsNew)][nUsado+1] := .F.
		
		ACF->(DbSkip())
		
	End
	
	#IFDEF TOP
		DbSelectArea("ACF")
		DbCloseArea()
		ChkFile("ACF")
	#ENDIF
Endif

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณSK1AftHead    บAutor  ณNorbert Waage Juniorบ Data ณ07/02/07 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณRotina utilizada para adicionar o campo E1_FILIAL ao aHeaderบฑฑ
ฑฑบ          ณda GetDados para a tabela SK1, pois a FillGetDados ignora o บฑฑ
ฑฑบ          ณcampo ??_FILIAL, mesmo quando forcado via parametro.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeadNew   - aHeader para GetDados da tabela SK1(SE1)       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELECOBRANCA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SK1AftHead(aHeadNew)

Local aArea		:= GetArea()					// Armazena a Area atual
Local aAreaSX3	:= SX3->(GetArea())			// Armazena o posicionamento do SX3
Local aHeadTmp	:= {}							// Vetor de apoio
Local nX		:= 0							// Controle do contador

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPesquisa se o campo esta no aHeadNewณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aScan(aHeadNew,{|x|x[2]=="E1_FILIAL"}) == 0
	
	DbSelectArea("SX3")
	DbSetOrder(2)

	If DbSeek("E1_FILIAL")
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAcrescenta o campo E1_FILIALณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Aadd(aHeadTmp, {AllTrim(X3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_F3,;
						SX3->X3_CONTEXT } )

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAcrescenta os demais camposณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nX := 1 to Len(aHeadNew)
			AAdd(aHeadTmp,aClone(aHeadNew[nX]))
		Next nX

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza o aHeadNewณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aHeadNew := aClone(aHeadTmp)
		
	EndIf

EndIf

RestArea(aAreaSX3)
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณSUCMntCols    บAutor  ณNorbert Waage Juniorบ Data ณ07/02/07 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณRotina de criacao do vetor aColsNew, estruturado de modo a  บฑฑ
ฑฑบ          ณcontemplar a rotina de WalkThru para a tabela SUC.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcChave     - Cliente+Loja para pesquisa na SUC              บฑฑ
ฑฑบ          ณaHeadNew   - aHeader para GetDados da tabela SUC            บฑฑ
ฑฑบ          ณaColsNew   - aCols para GetDados da tabela SUC              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELECOBRANCA                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑบฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบฑฑ
ฑฑบMichel M. ณ13/03/07ณ9.12  ณBOPS 115794-Corrigida query de selecao      บฑฑ
ฑฑบ          ณ        ณ      ณ    que gerava nao conformidade com DB2.    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SUCMntCols( cChave, aHeadNew, aColsNew )

Local cQuery	:= ""							// Conteudo da query
Local lQuery	:= .F.							// Indica se a rotina utiliza TopConnect
Local nI		:= 0							// Controle do loop
Local aStruct	:= {}							// Estrutura do arquivo SUC
Local nUsado	:= Len(aHeadNew)				// Tamanho do aHeadNew

If !Empty(cChave)
	DbSelectArea("SUC")
	DbSetOrder(5)	// UC_ENTIDAD+UC_CHAVE
	#IFDEF TOP
		lQuery	:= .T.
		aStruct	:= SUC->(DbStruct())
		cQuery	:=	" SELECT	* " +;
					" FROM " +	RetSqlName("SUC") + " SUC " +;
					" WHERE	SUC.UC_FILIAL = '" + xFilial("SUC") + "' AND" +;
					"		SUC.UC_ENTIDAD = 'SA1' AND" +;
					"		SUC.UC_CHAVE = '" + AllTrim(cChave) + "' AND" +;
					"		SUC.UC_STATUS ='" + Str(PENDENTE,1) + "' AND" +;
					"		SUC.D_E_L_E_T_ = ' '" +;
					" ORDER BY " + SqlOrder(IndexKey())
			
		cQuery	:= ChangeQuery(cQuery)
		// MemoWrite("TK280SUC.SQL", cQuery)
		DbSelectArea("SUC")                    
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUC', .F., .T.)
	
		For nI := 1 To Len(aStruct)
			If aStruct[nI][2] $ "NDL"
				TCSetField("SUC", aStruct[nI][1], aStruct[nI][2], aStruct[nI][3], aStruct[nI][4])
			Endif
		Next nI
	#ELSE
		DbSeek(xFilial("SUC") + "SA1" + AllTrim(cChave))
	#ENDIF
	
	While	!SUC->(Eof()) .AND.;
			SUC->UC_FILIAL == xFilial("SUC")	.AND.;
			SUC->UC_ENTIDAD == "SA1"			.AND.;
			AllTrim(SUC->UC_CHAVE) == AllTrim(cChave)
		
		If AllTrim(SUC->UC_STATUS) <> Str(PENDENTE,1)
			SUC->(DbSkip())
			Loop
		Endif
		
		Aadd(aColsNew,Array(nUsado+1))
		For nI := 1 To nUsado
			If IsHeadRec(aHeadNew[nI][2])       
            	#IFDEF TOP
                	aColsNew[Len(aColsNew)][nI] := SUC->R_E_C_N_O_
             	#ELSE
                	aColsNew[Len(aColsNew)][nI] := SUC->(Recno())			                                
              	#ENDIF			
			ElseIf IsHeadAlias(aHeadNew[nI][2])
				aColsNew[Len(aColsNew)][nI] := "SUC" 
			ElseIf ( aHeadNew[nI,10] <>  "V" )
				aColsNew[Len(aColsNew)][nI] := SUC->(FieldGet(FieldPos(aHeadNew[nI,2])))
			Else
				aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.T.)
			EndIf
		Next nI
		aColsNew[Len(aColsNew)][nUsado+1] := .F.
		
		SUC->(DbSkip())
	End
	
	#IFDEF TOP
		DbSelectArea("SUC")
		DbCloseArea()
		ChkFile("SUC")
	#ENDIF
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณSUDMntCols    บAutor  ณNorbert Waage Juniorบ Data ณ07/02/07 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณRotina de criacao do vetor aColsNew, estruturado de modo a  บฑฑ
ฑฑบ          ณcontemplar a rotina de WalkThru para a tabela SUD.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcCodigo    - Codigo do atendimento no TMK                   บฑฑ
ฑฑบ          ณaHeadNew   - aHeader para GetDados da tabela SUD            บฑฑ
ฑฑบ          ณaColsNew   - aCols para GetDados da tabela SUD              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELECOBRANCA                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑบฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบฑฑ
ฑฑบMichel M. ณ13/03/07ณ9.12  ณBOPS 115794-Corrigida query de selecao      บฑฑ
ฑฑบ          ณ        ณ      ณ    que gerava nao conformidade com DB2.    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SUDMntCols( cCodigo, aHeadNew, aColsNew )

Local cQuery	:= ""							// Conteudo da query
Local lQuery	:= .F.							// Indica se a rotina utiliza TopConnect
Local nI		:= 0							// Controle do loop
Local aStruct	:= {}							// Estrutura do arquivo SUD
Local nUsado	:= Len(aHeadNew)				// Tamanho do aHeadNew

If !Empty(cCodigo)
	DbSelectArea("SUD")
	DbSetOrder(1)
	#IFDEF TOP
		aStruct	:= SUD->(DbStruct())
		lQuery	:= .T.
		cQuery	:=	" SELECT	* " +;
					" FROM " +	RetSqlName("SUD") + " SUD " +;
					" WHERE	SUD.UD_FILIAL = '" + xFilial("SUD") + "' AND" +;
					"		SUD.UD_CODIGO = '" + cCodigo + "' AND" +;
					"		SUD.D_E_L_E_T_ = ' '" +;
					" ORDER BY " + SqlOrder(IndexKey())
			
		cQuery	:= ChangeQuery(cQuery)
		// MemoWrite("TK280SUD.SQL", cQuery)
		DbSelectArea("SUD")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUD', .F., .T.)
	
		For nI := 1 To Len(aStruct)
			If aStruct[nI][2] $ "NDL"
				TCSetField("SUD", aStruct[nI][1], aStruct[nI][2], aStruct[nI][3], aStruct[nI][4])
			Endif
		Next nI
	#ELSE
		DbSeek(xFilial("SUD")+cCodigo)
	#ENDIF
	
	While	!SUD->(Eof()) .AND.;
			SUD->UD_FILIAL == xFilial("SUD")	.AND.;
			SUD->UD_CODIGO == cCodigo
		
		Aadd(aColsNew,Array(nUsado+1))
		For nI := 1 To nUsado
			If IsHeadRec(aHeadNew[nI][2])     
            	#IFDEF TOP
                	aColsNew[Len(aColsNew)][nI] := SUD->R_E_C_N_O_
             	#ELSE
                	aColsNew[Len(aColsNew)][nI] := SUD->(Recno())			                                
              	#ENDIF			
			ElseIf IsHeadAlias(aHeadNew[nI][2])
				aColsNew[Len(aColsNew)][nI] := "SUD" 
			ElseIf ( aHeadNew[nI,10] <>  "V" )
				aColsNew[Len(aColsNew)][nI] := SUD->(FieldGet(FieldPos(aHeadNew[nI,2])))
			Else
				aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.T.)
			EndIf
		Next nI
		aColsNew[Len(aColsNew)][nUsado+1] := .F.
		
		SUD->(DbSkip())
	End
	
	#IFDEF TOP
		DbSelectArea("SUD")
		DbCloseArea()
		ChkFile("SUD")
	#ENDIF
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณSUAMntCols    บAutor  ณNorbert Waage Juniorบ Data ณ08/02/07 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณRotina de criacao do vetor aColsNew, estruturado de modo a  บฑฑ
ฑฑบ          ณcontemplar a rotina de WalkThru para a tabela SUA.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcCliente   - Codigo do cliente                              บฑฑ
ฑฑบ          ณcLoja      - Loja do cliente                                บฑฑ
ฑฑบ          ณaHeadNew   - aHeader para GetDados da tabela SUA            บฑฑ
ฑฑบ          ณaColsNew   - aCols para GetDados da tabela SUA              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELECOBRANCA                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑบฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบฑฑ
ฑฑบMichel M. ณ13/03/07ณ9.12  ณBOPS 115794-Corrigida query de selecao      บฑฑ
ฑฑบ          ณ        ณ      ณ    que gerava nao conformidade com DB2.    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SUAMntCols( cCliente, cLoja, aHeadNew, aColsNew )

Local cQuery	:= ""							// Conteudo da query
Local lQuery	:= .F.							// Indica se a rotina utiliza TopConnect
Local nI		:= 0							// Controle do loop
Local aStruct	:= {}							// Estrutura do arquivo SUD
Local nUsado	:= Len(aHeadNew)				// Tamanho do aHeadNew

If !Empty(cCliente) .AND. !Empty(cLoja)
	DbSelectArea("SUA")
	DbSetOrder(6)	// UA_CLIENTE+UA_LOJA+DTOS(UA_EMISSAO)
	#IFDEF TOP
		aStruct	:= SUA->(DbStruct())
		lQuery	:= .T.
		cQuery	:=	" SELECT	* " +;
					" FROM " +	RetSqlName("SUA") + " SUA " +;
					" WHERE	SUA.UA_FILIAL = '" + xFilial("SUA") + "' AND" +;
					"		SUA.UA_CLIENTE = '" + AllTrim(cCliente) + "' AND" +;
					"		SUA.UA_LOJA = '" + AllTrim(cLoja) + "' AND" +;
					"		(SUA.UA_STATUS = 'SUP' OR SUA.UA_STATUS = 'LIB') AND" +;
					"		SUA.D_E_L_E_T_ = ' '" +;
					" ORDER BY " + SqlOrder(IndexKey())
			
		cQuery	:= ChangeQuery(cQuery)
		// MemoWrite("TK280SUA.SQL", cQuery)
		DbSelectArea("SUA")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUA', .F., .T.)
	
		For nI := 1 To Len(aStruct)
			If aStruct[nI][2] $ "NDL"
				TCSetField("SUA", aStruct[nI][1], aStruct[nI][2], aStruct[nI][3], aStruct[nI][4])
			Endif
		Next nI
	#ELSE
		DbSeek(xFilial("SUA") + AllTrim(cCliente) + AllTrim(cLoja))
	#ENDIF
	
	While	!SUA->(Eof()) .AND.;
			SUA->UA_FILIAL == xFilial("SUA")	.AND.;
			SUA->UA_CLIENTE == cCliente			.AND.;
			SUA->UA_LOJA == cLoja
		
		If SUA->UA_STATUS <> "SUP" .AND. SUA->UA_STATUS <> "LIB"
			DbSelectArea("SUA")
			DbSkip()
			Loop
		Endif
		
		Aadd(aColsNew,Array(nUsado+1))
		For nI := 1 To nUsado
			If IsHeadRec(aHeadNew[nI][2])   
            	#IFDEF TOP
                	aColsNew[Len(aColsNew)][nI] := SUA->R_E_C_N_O_
             	#ELSE
                	aColsNew[Len(aColsNew)][nI] := SUA->(Recno())			                                
              	#ENDIF			
			ElseIf IsHeadAlias(aHeadNew[nI][2])
				aColsNew[Len(aColsNew)][nI] := "SUA" 
			ElseIf ( aHeadNew[nI,10] <>  "V" )
				aColsNew[Len(aColsNew)][nI] := SUA->(FieldGet(FieldPos(aHeadNew[nI,2])))
			ElSE
				aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.T.)
			EndIf
		Next nI
		aColsNew[Len(aColsNew)][nUsado+1] := .F.
		
		SUA->(DbSkip())
	End
	
	#IFDEF TOP
		DbSelectArea("SUA")
		DbCloseArea()
		ChkFile("SUA")
	#ENDIF
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณSUBMntCols    บAutor  ณNorbert Waage Juniorบ Data ณ08/02/07 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณRotina de criacao do vetor aColsNew, estruturado de modo a  บฑฑ
ฑฑบ          ณcontemplar a rotina de WalkThru para a tabela SUB.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcCodigo    - Codigo do atendimento                          บฑฑ
ฑฑบ          ณaHeadNew   - aHeader para GetDados da tabela SUB            บฑฑ
ฑฑบ          ณaColsNew   - aCols para GetDados da tabela SUB              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER - TELECOBRANCA                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑบฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบฑฑ
ฑฑบMichel M. ณ13/03/07ณ9.12  ณBOPS 115794-Corrigida query de selecao      บฑฑ
ฑฑบ          ณ        ณ      ณ    que gerava nao conformidade com DB2.    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SUBMntCols( cCodigo, aHeadNew, aColsNew )

Local cQuery	:= ""							// Conteudo da query
Local lQuery	:= .F.							// Indica se a rotina utiliza TopConnect
Local nI		:= 0							// Controle do loop
Local aStruct	:= {}							// Estrutura do arquivo SUD
Local nUsado	:= Len(aHeadNew)				// Tamanho do aHeadNew

DbSelectArea("SUB")
DbSetOrder(1)

#IFDEF TOP
	lQuery	:= .T.
	aStruct	:= SUB->(DbStruct())
	cQuery	:=	" SELECT	* " +;
				" FROM " +	RetSqlName("SUB") + " SUB " +;
				" WHERE	SUB.UB_FILIAL = '" + xFilial("SUB") + "' AND" +;
				"		SUB.UB_NUM = '" + cCodigo + "' AND" +;
				"		SUB.D_E_L_E_T_ = ' '" +;
				" ORDER BY " + SqlOrder(IndexKey())
		
	cQuery	:= ChangeQuery(cQuery)
	// MemoWrite("TK280SUB.SQL", cQuery)
	DbSelectArea("SUB")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUB', .F., .T.)

	For nI := 1 To Len(aStruct)
		If aStruct[nI][2] $ "NDL"
			TCSetField("SUB", aStruct[nI][1], aStruct[nI][2], aStruct[nI][3], aStruct[nI][4])
		Endif
	Next nI
#ELSE
	DbSeek(xFilial("SUB")+cCodigo)
#ENDIF

While	!SUB->(Eof()) .AND.;
		SUB->UB_FILIAL == xFilial("SUB")	.AND.;
		SUB->UB_NUM == cCodigo
	
	Aadd(aColsNew,Array(nUsado+1))
	For nI := 1 To nUsado
		If IsHeadRec(aHeadNew[nI][2])
           	#IFDEF TOP
               	aColsNew[Len(aColsNew)][nI] := SUB->R_E_C_N_O_
           	#ELSE
               	aColsNew[Len(aColsNew)][nI] := SUB->(Recno())			                                
           	#ENDIF		
		ElseIf IsHeadAlias(aHeadNew[nI][2])
			aColsNew[Len(aColsNew)][nI] := "SUB" 
		ElseIf ( aHeadNew[nI,10] <>  "V" )
			aColsNew[Len(aColsNew)][nI] := SUB->(FieldGet(FieldPos(aHeadNew[nI,2])))
		Else
			aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.T.)
		EndIf
	Next nI
	aColsNew[Len(aColsNew)][nUsado+1] := .F.
	
	SUB->(DbSkip())
End

#IFDEF TOP
	DbSelectArea("SUB")
	DbCloseArea()
	ChkFile("SUB")
#ENDIF

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk280TemReagบAutor  ณ Vendas CRM	     บ Data ณ  25/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existe uma lista de cobranca (reagendamento)   บฑฑ
ฑฑบ          ณ agendada para uma data posterior ao do atendimento.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 		                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cOperador - Codigo do Operador do atendimento.             บฑฑ
ฑฑบ			 ณ cCliente  - Codigo do cliente.							  บฑฑ
ฑฑบ			 ณ cLoja     - Loja do cliente.								  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280TemReag(cOperador, cCliente, cLoja)

Local aArea		:= GetArea()
Local lRet		:= .F.

#IFDEF TOP
	Local cQuery	:= ""
	
	cQuery	:=	" SELECT U4_FILIAL, U4_OPERAD, U4_DATA, U4_STATUS, U4_TELE, U4_FORMA, U6_CODENT " +;
				" FROM " +	RetSqlName("SU4") + " SU4, " +	RetSqlName("SU6") + " SU6 " +;
				" WHERE	SU4.U4_FILIAL = '" + xFilial("SU4") + "' AND" +;
				"		SU4.U4_OPERAD = '" + cOperador + "' AND" +;
				"		SU4.U4_DATA  > '" + Dtos(dDatabase) + "' AND " +;
				"		SU4.U4_STATUS = '1' AND" +;		//Ativo
				"		SU4.U4_TELE = '3' AND" +;		//Telecobranca
				"		SU4.U4_FORMA = '5' AND" +;     	//Pendencia
				"		SU4.U4_FILIAL = SU6.U6_FILIAL AND" +;
				"		SU4.U4_LISTA = SU6.U6_LISTA AND" +;
				"		SU4.U4_CODLIG = SU6.U6_CODLIG AND" +;
				"		SU6.U6_ENTIDA = 'SA1' AND " +;
				"		SU6.U6_CODENT = '" + cCliente+cLoja + "' AND" +; 
				"		SU6.D_E_L_E_T_ = ' ' AND" +;
				"		SU4.D_E_L_E_T_ = ' '"
		
	cQuery	:= ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRBSU4', .F., .T.)
	 
	DbSelectArea("TRBSU4")
	
	If TRBSU4->(!Eof())
		lRet := .T.
	EndIf
	
	TRBSU4->(DbCloseArea())
#ENDIF

RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} Tk280NewTC
	Funcao Responsavel Por Identificar Se a Nova Regra de TeleCobranca Pode Ser Utilizada
	@type  Function
	@author Paulo V. Beraldo
	@since Jan/2021
	@version 1.00
/*/
Function Tk280NewTC()
Local lRet := GetNewPar( 'MV_NEWTCOB', .F. ) .And. SK1->( ColumnPos( 'K1_DTFRENE' ) ) > 0  .And. SK1->( ColumnPos( 'K1_HRFRENE' ) ) > 0 .And. SU0->( ColumnPos( 'U0_TEMPCOB' ) ) > 0
Return lRet

/*/{Protheus.doc} Tk280CanAtd
	Funcao Responsavel Por Identificar Se o Cliente Pode Entrar ou Nao na Fila de Atendimento
	@type  Function
	@author Paulo V. Beraldo
	@param cClient   , Caracter, Codigo do Cliente
	@param cLojaCli  , Caracter, Loja do Cliente
	@param cOperador , Caracter, Codigo do Operador
	@param aRegras   , Array   , Vetor de Regras do Operador
	@param lForceAtd , Boolean , Informa se Deseja For็ar o Atendimento Sim/Nao
	@param aAgenda 	 , Array   , Vetor com as Informacoes da Agenda do Operador
	@since Jan/2021
	@version 1.00
/*/
Function Tk280CanAtd( cClient, cLojaCli, cOperador, aRegras, lForceAtd, aAgenda )
Local aArea		:= GetArea()
Local aAreaSU7	:= SU7->( GetArea() )
Local aAreaSU0	:= SU0->( GetArea() )
Local aAreaSK0	:= SU0->( GetArea() )

Local lRet		:= .T.
Local nQtdDias	:= 0
Local nAuxDias 	:= 0
Local nAuxHor1 	:= 0
Local nPosVet	:= 0

Local cQuery	:= Nil
Local cQryAlias	:= GetNextAlias()
Local cTempRet	:= Nil
Local cHrUltAtd := Nil
Local cHrUltPen := Nil
Local cStatAtd	:= Nil
Local cHrLastAtd:= Nil
Local dDtUltAtd := Ctod( '' )

Default cClient		:= ''
Default cLojaCli	:= ''
Default lForceAtd	:= .F.
Default aAgenda		:= {}

dbSelectArea( 'SU7' )
SU7->( dbSetOrder( 1 ) )

dbSelectArea( 'SU0' )
SU0->( dbSetOrder( 1 ) )

dbSelectArea( 'SK0' )
SK0->( dbSetOrder( 1 ) )


cQuery := " SELECT DISTINCT ACF.ACF_FILIAL, ACF.ACF_CLIENT, ACF.ACF_LOJA, ACF.ACF_STATUS , ACF.ACF_ULTATE, MAX( ACF.ACF_HRPEND ) ACF_HRPEND, MAX( ACF.ACF_FIM ) ACF_FIM "+CRLF
cQuery += " FROM "+ RetSQLName( 'ACF' ) +" ACF "+CRLF
cQuery += " 	INNER JOIN "+ RetSQLName( 'SU4' ) +" SU4 ON ( SU4.U4_FILIAL = '"+ FWxFilial( 'SU4' ) +"' AND ACF.ACF_FILIAL = '"+ FWxFilial( 'ACF' ) +"' AND ACF.ACF_CODIGO = SU4.U4_CODLIG ) "+CRLF
cQuery += " 	INNER JOIN "+ RetSQLName( 'SU6' ) +" SU6 ON ( SU6.U6_FILIAL = '"+ FWxFilial( 'SU6' ) +"' AND ACF.ACF_FILIAL = '"+ FWxFilial( 'ACF' ) +"' AND ACF.ACF_CODIGO = SU6.U6_CODLIG ) "+CRLF
cQuery += " WHERE ACF.ACF_FILIAL = '"+ FWxFilial( 'ACF' ) +"' "+CRLF
cQuery += " 	AND ACF.ACF_CLIENT = '"+ cClient +"' "+CRLF
cQuery += " 	AND ACF.ACF_LOJA = '"+ cLojaCli +"' "+CRLF
cQuery += " 	AND ACF.ACF_ULTATE IN ( SELECT MAX(ACFX.ACF_ULTATE) DATA3 FROM "+ RetSQLName( 'ACF' ) +" ACFX WHERE ACFX.ACF_FILIAL = ACF.ACF_FILIAL AND ACFX.ACF_CLIENT = ACF.ACF_CLIENT AND ACFX.ACF_LOJA = ACF.ACF_LOJA AND ACFX.D_E_L_E_T_ = ' ' )  "+CRLF
cQuery += " 	AND ACF.D_E_L_E_T_ = ' '  "+CRLF
cQuery += " 	AND SU4.D_E_L_E_T_ = ' '  "+CRLF
cQuery += " 	AND SU6.D_E_L_E_T_ = ' '  "+CRLF
cQuery += " GROUP BY ACF.ACF_FILIAL, ACF.ACF_CLIENT, ACF.ACF_LOJA, ACF.ACF_STATUS , ACF.ACF_ULTATE "
cQuery := ChangeQuery( cQuery )

dbUseArea( .T., __cRdd, TcGenQry( ,, cQuery ), cQryAlias, .T., .F. )
TcSetField( ( cQryAlias ), 'ACF_ULTATE', TamSx3( 'ACF_ULTATE' )[ 3 ], TamSx3( 'ACF_ULTATE' )[ 1 ], TamSx3( 'ACF_ULTATE' )[ 2 ] )

dbSelectArea( cQryAlias )
If ( !( cQryAlias )->( Eof() ) )

	dDtUltAtd := ( cQryAlias )->ACF_ULTATE
	cHrUltAtd := ( cQryAlias )->ACF_FIM
	cHrUltPen := ( cQryAlias )->ACF_HRPEND
	cStatAtd  := ( cQryAlias )->ACF_STATUS
	nQtdDias  := DateDiffDay( dDtUltAtd, dDataBase )

	If !SU7->( dbSeek( FWxFilial( 'SU7' ) + cOperador ) )
		lRet := .F.
	Else
		If !SU0->( dbSeek( FWxFilial( 'SU0' ) + SU7->U7_POSTO ) )
			lRet := .F.
		Else
			cTempRet := IIf( Empty( SU0->U0_TEMPCOB ), '00:01', SU0->U0_TEMPCOB )
			If !SK0->( dbSeek( FWxFilial( 'SK0' ) + SU0->U0_REGSEL ) )
				lRet := .F.
			Else
				lRet := Ascan( aRegras, { | x | x[ 1 ] == SU0->U0_REGSEL } ) > 0 .And. !( Empty( cTempRet ) )
			EndIf
		EndIf
	EndIf

	nPosVet := Ascan( aAgenda,{ | x |  AllTrim( x[2] ) == AllTrim( cClient ) .And. AllTrim( x[3] ) == AllTrim( cLojaCli ) .And. ( AllTrim( x[10] ) == '1' .Or. AllTrim( x[10] ) == '2' )  } )
	If nQtdDias == 0
		cHrLastAtd := SubStr( ElapTime( cHrUltAtd, Time() ), 1, 5 )
		If cStatAtd $ '1|2' //ACF_STATUS | 1=Atendimento;2=Cobranca;3=Encerrado
			If nPosVet == 0
				If ( SubStr( Time(), 1, 5 ) >= cHrUltPen )
					lRet := .T.
				Else
					lRet := IIf( lForceAtd, .T., .F. )
				EndIf
			Else
				lRet := .F.
			EndIf
		Else
			If ( cHrLastAtd >= cTempRet )
				lRet := .T.
			Else
				lRet := IIf( lForceAtd, .T., .F. )
			EndIf
		EndIf
	Else
		nAuxDias 	:= IIf( nQtdDias == 1, nQtdDias, nQtdDias - 1 )
		nAuxHor1 	:= nAuxDias * 24
		cHrLastAtd 	:= SubStr( IntToHora( HoraToInt( ElapTime( cHrUltAtd, '23:59:59' ) ) + HoraToInt( ElapTime( '00:00:00', Time() ) ) + nAuxHor1 ), 1, 5 )
		If nPosVet == 0
			If ( cHrLastAtd >= cTempRet )
				lRet := .T.
			Else
				lRet := IIf( lForceAtd, .T., .F. )
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
EndIf

IIf( Select( cQryAlias ) > 0, ( cQryAlias )->( dbCloseArea() ), Nil )
RestArea( aAreaSK0 )
RestArea( aAreaSU0 )
RestArea( aAreaSU7 )
RestArea( aArea )
Return lRet

/*/{Protheus.doc} Tk280GvSk1
	Funcao Responsavel Por Identificar os Titulos Que Foram Negociados no Atendimento e Atualizar com Data/Hora de Atendimento
	@type  Function
	@author Paulo V. Beraldo
	@param cCodAtend  , Caracter, Codigo do Atendimento
	@since Jan/2021
	@version 1.00
/*/
Function Tk280GvSk1( cCodAtend )
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aAreaSk1	:= SK1->( GetArea() )
Local cQuery	:= Nil
Local cACGAlias	:= GetNextAlias()
Local cFilACG	:= FWxFilial( 'SK1' )

SK1->( dbSetOrder( 1 ) )

cQuery := " SELECT ACG.ACG_CODIGO, ACG.ACG_PREFIX, ACG.ACG_TITULO, ACG.ACG_PARCEL, ACG.ACG_TIPO "+CRLF
cQuery += " FROM "+ RetSQLName( 'ACG' ) +" ACG  "+CRLF
cQuery += " WHERE ACG.ACG_FILIAL = '"+ FWxFilial( 'ACG' ) +"'  "+CRLF
cQuery += " 	AND ACG.ACG_CODIGO = '"+ cCodAtend +"'  "+CRLF
cQuery += " 	AND ACG.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery( cQuery )

dbUseArea( .T., __cRdd, TcGenQry( ,, cQuery ), cACGAlias, .T., .F. )
dbSelectArea( cACGAlias )

While !( cACGAlias )->( Eof() )
	If SK1->( dbSeek( cFilACG + ( cACGAlias )->ACG_PREFIX + ( cACGAlias )->ACG_TITULO + ( cACGAlias )->ACG_PARCEL + ( cACGAlias )->ACG_TIPO + cFilACG ) ) //K1_FILIAL, K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO, K1_FILORIG
		RecLock( 'SK1', .F. )
		SK1->K1_DTFRENE := dDataBase
		SK1->K1_HRFRENE := SubStr( Time(), 1, 5 )
		SK1->( MsUnLock() )
	EndIf

	( cACGAlias )->( dbSkip() )
EndDo

IIf( Select( cACGAlias ) > 0, ( cACGAlias )->( dbCloseArea() ), Nil )
RestArea( aAreaSk1 )
RestArea( aArea )
Return lRet