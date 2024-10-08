#INCLUDE "TMKC020.CH" 
#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMKC020()
Chamada para a fun豫o TMKC020A(). 

@author Enaldo Cardoso
@since 04/04/2014
/*/
//------------------------------------------------------------------------------------------------

Function TMKC020()

	TMKC020A()
	
Return

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMKC020A()
Monta uma consulta com todos os titulos negociados ematendimentos do telecobranca do call center.
Para cada titulo negociado, exibe os atendimentos que foram realizados.

@return .F.
@author Enaldo Cardoso
@since 04/04/2014
/*/
//------------------------------------------------------------------------------------------------

Function TMKC020A( cCodCli, cLoja, lExecList)

Local aSize     := MsAdvSize( .F. )					// Array para dimensionar a tela de posicao do cliente
Local lTKC20Hist:= ExistBlock( "TKC20Hist" ) 		// VAlida se existe o ponto de entrada criado

Default cCodCli := SA1->A1_COD
Default cLoja := SA1->A1_LOJA
Default lExecList := .F.

If FunName() $ "TMKC020/TMKA380"
	If FunName() == "TMKC020" .OR. ( FunName() == "TMKA380" .AND. (IsInCallStack('TK271SITUAC') .OR. lExecList) ) 
		If .NOT. Pergunte("TMKC20", .T.)
			Return(.F.)
		Endif
		
		DbSelectArea("SA1")
		DbSetOrder(1)
		If !DbSeek(xFilial("SA1") + MV_PAR03 + MV_PAR04)
			Help(" ", 1, "TMKCSEMCLI")
			Return(.F.)
		Endif			
	EndIf
	
	If ( FunName() == "TMKA380" .AND. IsInCallStack('A450F4Con') .AND. !lExecList)		
		DbSelectArea("SA1")
		DbSetOrder(1)
		If !DbSeek(xFilial("SA1")+cCodCli+cLoja)
			Help(" ", 1, "TMKCSEMCLI")
			Return(.F.)
		Endif
	EndIf
Else
	Pergunte("FIC010", .F.)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿛E para possivel personalizacao do historico de cobranca caso�
//쿬ontrario apresenta a tela de consulta posicao do cliente    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�컴컴켸
If !lTKC20Hist
	DEFINE MSDIALOG oDlg FROM aSize[7],0 TO aSize[6],aSize[5] TITLE STR0001 OF oMainWnd PIXEL //"Consulta negocia寤es do Telecobran�as"
	MsgRun(STR0002,"",{|| CursorWait(), TKC020Tela(oDlg) ,CursorArrow()}) //'Gerando Visualiza豫o, Aguarde...'
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {|| oDlg:End()}, {|| oDlg:End()}))
Else
	ExecBlock( "TKC20Hist", .F., .F. )
Endif
Return(.F.)



/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿟KC020Tela  튍utor  쿌rmando M. Tessaroli� Data �  28/08/02   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿎ria todos os objetos da dialog da funcao principal           볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿑INC010                                                       볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Function TKC020Tela(oDlg)

Local aArea		 := GetArea()			//Seleciona a area para ser restaurada ao final
Local nHeight	 := oDlg:nHeight / 2	//Define tamanho da tela
Local nWidth	 := oDlg:nWidth / 2		//Define tamanho da tela
Local oLB01				   				//Listbox do Cabecalho 			- contem todos os titulos da empresa - ACG
Local aCabeca	 := {}					//Array com os registros do ACG - representa os titulos cobrados
Local oLB02				   				//Listbox dos Itens da consulta - contem todas os atendimentos de um titulo - ACF
Local aItens	 := {}					//Array com os registros do ACF - representa os atendimentos(cobranca) de cada titulo
Local oObs								//Objeto para as observacoes
Local cObs								//Observacao digitada
Local lSelectFil := .F.					//Indicador de que o usuario pode ter selecionado varias filiais para a consulta de Historico de Cobranca
Local cFilOriHea := ""					//Descricao da filial de origem no campo E1_FILORIG

Local aPDCols01	 := {"","","","","","","","","","","","","","U7_NOME",""}
Local aPDCols02	 := {"","","","","","","","U7_NOME","","","","U7_NOME"}
Local aPDFields  := {"U7_NOME"}

FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)

lSelectFil := TK020SelFil()

cFilOriHea := Posicione("SX3", 2, "E1_FILORIG" ,"X3Titulo()")
RestArea(aArea)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿘onta o cabecalho desta consulta, neste caso os itens do telecobranca�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
aCabeca := TK020ListBox("ACG", , lSelectFil)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿘onta o Listbox do Cabecalho �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

@ (nHeight*.10),(nWidth*.02) ListBox oLB01 Fields;
		Header	cFilOriHea,; //"Filial Orig"
				STR0005,;    //"Prefixo"
				STR0006,;    //"Titulo"
				STR0007,;    //"Parcela"
				STR0008,;    //"Tipo"
				STR0009,;    //"Natureza"
				STR0010,;    //"Vencimento"
				STR0011,;    //"Venc.Real"
				STR0012,;    //"Valor"
				STR0013,;    //"Acrescimo"
				STR0014,;    //"Desconto"
				STR0015,;    //"Status"
				STR0016,;    //"Respons�vel"
				STR0017,;    //"Nome"
				STR0032;     //"Hist�rico"
		Size (nWidth*.95),(nHeight*.45) NoScroll Of oDlg Pixel

oLB01:SetArray(aCabeca)
oLB01:bLine:={||{	aCabeca[oLB01:nAt,1],;
					aCabeca[oLB01:nAt,2],;
					aCabeca[oLB01:nAt,3],;
					aCabeca[oLB01:nAt,4],;
					aCabeca[oLB01:nAt,5],;
					aCabeca[oLB01:nAt,6],;
					aCabeca[oLB01:nAt,7],;
					aCabeca[oLB01:nAt,8],;
					aCabeca[oLB01:nAt,9],;
					aCabeca[oLB01:nAt,10],;
					aCabeca[oLB01:nAt,11],;
					aCabeca[oLB01:nAt,12],;
					aCabeca[oLB01:nAt,13],;
					aCabeca[oLB01:nAt,14],;
					aCabeca[oLB01:nAt,15];
					}}
oLB01:nAt := 1

If FATPDActive() .And. FTPDUse(.T.)
	oLB01:aObfuscatedCols := FATPDColObfuscate(aPDCols01)
EndIf

oLB01:bChange := {||	aItens := TK020ListBox("ACF", aCabeca[oLB01:nAt][len(aCabeca[1])], lSelectFil),;
						oLB02:SetArray(aItens),;
						oLB02:bLine:={||{	aItens[oLB02:nAt,1],;
											aItens[oLB02:nAt,2],;
											aItens[oLB02:nAt,3],;
											aItens[oLB02:nAt,4],;
											aItens[oLB02:nAt,5],;
											aItens[oLB02:nAt,6],;
											aItens[oLB02:nAt,7],;
											aItens[oLB02:nAt,8],;
											aItens[oLB02:nAt,9],;
											aItens[oLB02:nAt,10],;					
											aItens[oLB02:nAt,11],;
											aItens[oLB02:nAt,12]}},;											
						oLB02:nAt := 1,;
						oLB02:Refresh(),;
						ACF->( DbSetOrder(1) ),;
						ACF->(DbSeek(Eval(oLB02:bLine)[1] + Eval(oLB02:bLine)[2])) ,;
						cObs := MSMM(ACF->ACF_CODOBS,80),;
						oObs:Refresh();
					}

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿘onta um browser tipo MSGetDados Read Only dos itens�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
@ (nHeight*.55),(nWidth*.02) ListBox oLB02 Fields;
			Header	STR0034,;	//"Filial Atendimento"
					STR0018,;	//"Atendimento"
					STR0019,;	//"Data"
					STR0020,;	//"Retorno"
					STR0021,;	//"Hora"
					STR0022,;	//"Liga豫o"
					STR0023,;	//"Operador"
					STR0017,;	//"Nome"
					STR0024,;	//"Ocorrencia"
					STR0025,;	//"Descri豫o"
					STR0033,;	//"Ultimo Operador"
					STR0017;	//"Nome"					
			Size (nWidth*.7),(nHeight*.35) NoScroll Of oDlg Pixel


oLB02:SetArray(aItens)
oLB02:bLine:={||{	aItens[oLB02:nAt,1],;
					aItens[oLB02:nAt,2],;
					aItens[oLB02:nAt,3],;
					aItens[oLB02:nAt,4],;
					aItens[oLB02:nAt,5],;
					aItens[oLB02:nAt,6],;
					aItens[oLB02:nAt,7],;
					aItens[oLB02:nAt,8],;
					aItens[oLB02:nAt,9],;
					aItens[oLB02:nAt,10],;					
					aItens[oLB02:nAt,11],;
					aItens[oLB02:nAt,12];
					}}
oLB02:nAt := 1

If FATPDActive() .And. FTPDUse(.T.)
	oLB02:aObfuscatedCols := FATPDColObfuscate(aPDCols02)
EndIf

oLB02:bChange := {||	ACF->( DbSetOrder(1) ),;                                             
						ACF->(DbSeek(Eval(oLB02:bLine)[1] + Eval(oLB02:bLine)[2])) ,;
						cObs := MSMM(ACF->ACF_CODOBS,80),;
						oObs:Refresh();
						}

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎ria um campo memo na tela para mostrar o historico das negociacoes�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
TSay():New((nHeight*.55),nWidth*.75,{|| STR0026 },oDlg,,,,,,.T.,CLR_HBLUE,CLR_WHITE) //"Observa寤es"

@ (nHeight*.6),nWidth*.75 GET oObs VAR cObs MEMO SIZE (nWidth*.22),(nHeight*.30) WHEN .T. OF oDlg PIXEL READONLY

FATPDUnload()
RestArea(aArea)
aSize(aPDFields,0)
aSize(aPDCols02,0)
aSize(aPDCols01,0)

Return(.F.)



/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    쿟K020ListBox     쿌utor  쿌rmando M. Tessaroli� Data � 29/08/02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Retorna os valores que serao impressos pelo painel             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe	 쿬Exp1: Alias para realizar a                                    낢�
굇�          쿪Exp2: Array com os codigos dos atendimentos realizados         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � CALL CENTER						                              낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿌nalista  � Data/Bops/Ver 쿘anutencao Efetuada                             낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K �20/08/01�609   �- Revisao do fonte                              낢�
굇쿌ndrea F. �13/05/04�710   �- Exibicao de todos os titulos NEGOCIADOS na    낢�
굇�          �        �      쿟elecobranca no cabecalho e os atendimentos     낢�
굇�          �        �      쿬orrespondentes nos itens.                      낢�
굇쿌ndrea F. �17/05/04�710   �- BOPS 71528 Exibicao do campo ACG_HIST         낢�
굇�          �        �      �(Historico) do titulo.                          낢�
굇쿙orbert W.�02/04/07�912   쿍ops 121340 - Correcao do indice de pesquisa da 낢�
굇�          �        �      쿭escricao da ocorrencia na tabela SU9.          낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function TK020ListBox(cAlias, aFiltro, lSelectFil)

Local aArea			:= GetArea()			//Seleciona a area para ser restaurada ao final
Local aDados		:= {}					//Array com os dados do ACF
Local nPosTitulo	:= 0
Local nPosAtend     := 0
Local aStatus		:= Tkc020Box("ACG_STATUS")
Local aOpera		:= Tkc020Box("ACF_OPERA")
Local cFilACF		:= xFilial("ACF")
Local cFilSU7		:= xFilial("SU7")
Local cFilSU9		:= xFilial("SU9")
Local cFilOriSE1    := ""

#IFDEF TOP
	Local cQuery	:= ""
#ENDIF

Do Case
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿗eitura do cabecalho telecobran�a�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	Case cAlias == "ACF"
		#IFDEF TOP
			If TcSrvType() <> "AS/400"

				If lSelectFil
					nPosAlias := FC010QFil(1,"ACF")
				Endif
			
				cQuery :=	"SELECT * " +;
							" FROM " + RetSqlName("ACF") +;
							" WHERE ACF_FILIAL " + Iif(	lSelectFil, ;
															aTmpFil[nPosAlias,2], ;
															"= '" + cFilACF + "'") + " AND " +;
							" ACF_CLIENT = '" + SA1->A1_COD + "' AND " +;
							" ACF_LOJA = '" + SA1->A1_LOJA + "' AND " +;
							" ACF_DATA >= '" + DtoS(MV_PAR01) + "' AND " +;
							" ACF_DATA <= '" + DtoS(MV_PAR02) + "' AND " +;
							" D_E_L_E_T_ <> '*' " +;
							" ORDER BY ACF_FILIAL,ACF_CODIGO"
				
				cQuery := ChangeQuery(cQuery)
				DbSelectArea("ACF")
				DbCloseArea()
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACF', .F., .T.)
				
				TCSetField('ACF', 'ACF_DATA', 'D')
				TCSetField('ACF', 'ACF_PENDEN', 'D')
			Else
		#ENDIF
			DbSelectArea("ACF")
			ACF->(DbSetOrder(2))
			If !lSelectFil
				ACF->(DbSeek(cFilACF + SA1->A1_COD + SA1->A1_LOJA))
			Endif
		#IFDEF TOP
			Endif		
		#ENDIF	
		While	!ACF->(Eof())								.AND.;
				ACF->ACF_FILIAL $ Iif(	lSelectFil, ;
											aTmpFil[nPosAlias,2], ;
											cFilACF)	.AND.;
				ACF->ACF_CLIENT == SA1->A1_COD		.AND.;
				ACF->ACF_LOJA   == SA1->A1_LOJA
			
			If ACF->ACF_DATA < MV_PAR01 .OR. ACF->ACF_DATA > MV_PAR02
				ACF->(DbSkip())
				Loop
			Endif
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//쿽 Array aFiltro que e passado como parametro possui as filiais �
			//� + os codigos dos atendimentos em que o titulo foi negociado.  �
			//쿙os itens serao exibidos apenas os atendimentos em que o titulo�
			//쿯oi negociado.                                                 �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			If Len(aFiltro) > 0
				nPosAtend  := Ascan(aFiltro, {|x| x == (ACF->ACF_FILIAL + ACF->ACF_CODIGO)} )
				If nPosAtend > 0
					Aadd(aDados, {	ACF->ACF_FILIAL,;			// Filial da Cobranca
									ACF->ACF_CODIGO,;			// Codigo da Cobranca
									ACF->ACF_DATA,;				// Data
									DtoC(ACF->ACF_PENDEN),;		// Retorno
									ACF->ACF_HRPEND,;			// Hora Retorno
									aOpera[Val(ACF_OPERA)+1],;	// Operacao ATIVO / RECEPTIVO
									ACF->ACF_OPERAD,;	//		// Cod Operador
									Posicione("SU7", 1, Iif(lSelectFil,	xFilial("SU7", ACF->ACF_FILIAL), cFilSU7) + ACF->ACF_OPERAD, "SU7->U7_NOME"),;	// Nome Operador
									ACF->ACF_MOTIVO,;			// Cod Motivo
									Posicione("SU9", 2, Iif(lSelectFil,	xFilial("SU9", ACF->ACF_FILIAL), cFilSU9) + ACF->ACF_MOTIVO, "SU9->U9_DESC"),;	// Motivo       
									ACF->ACF_OPERAT,;			// Cod Ultimo Operador
									Posicione("SU7", 1, Iif(lSelectFil,	xFilial("SU7", ACF->ACF_FILIAL), cFilSU7) + ACF->ACF_OPERAT, "SU7->U7_NOME");	// Nome Operador
									} )
				Endif
			Endif
			DbSelectArea(cAlias)
			(cAlias)->(DbSkip())
		End
		#IFDEF TOP
			If TcSrvType() <> "AS/400"
				DbSelectArea("ACF")
				DbCloseArea()
				ChKFile("ACF")
			Endif
		#ENDIF
		If len(aDados) == 0
			DbSelectArea("ACF")
			DbGoTo(0)
			AaDd(aDados, {	ACF->ACF_FILIAL,;			// Filial da Cobranca
							ACF->ACF_CODIGO,;			// Codigo da Cobranca
							ACF->ACF_DATA,;				// Data
							DtoC(ACF->ACF_PENDEN),;		// Retorno
							ACF->ACF_HRPEND,;			// Hora Retorno
							ACF->ACF_OPERA,;			// Operacao
							ACF->ACF_OPERAD,;			// Cod Operador
							ACF->ACF_OPERAD,;			// Nome Operador
							ACF->ACF_MOTIVO,;			// Cod Motivo
							ACF->ACF_MOTIVO,;			// Motivo
							ACF->ACF_OPERAT,;			// Ultimo Operador
							ACF->ACF_OPERAT;			// Nome Operador
							} )
		Endif
		Asort( aDados,,, { |x,y| x[1]+DtoS(x[3])+x[2] > y[1]+DtoS(y[3])+y[2] } )



	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿗eitura dos itens do telecobran�a - titulos a receber�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	Case cAlias == "ACG"
		#IFDEF TOP
			If TcSrvType() <> "AS/400"
				If lSelectFil
					nPosAlias := FC010QFil(1,"ACF")
				EndIf
				
				cQuery :=	"SELECT * " +;
							" FROM " + RetSqlName("ACF") +;
							" WHERE ACF_FILIAL " + Iif(	lSelectFil, ;
															aTmpFil[nPosAlias,2], ;
															"= '" + cFilACF + "'") + " AND " +;
							" ACF_CLIENT = '" + SA1->A1_COD + "' AND " +;
							" ACF_LOJA = '" + SA1->A1_LOJA + "' AND " +;
							" ACF_DATA >= '" + DtoS(MV_PAR01) + "' AND " +;
							" ACF_DATA <= '" + DtoS(MV_PAR02) + "' AND " +;
							" D_E_L_E_T_ <> '*' " +;
							" ORDER BY ACF_FILIAL,ACF_CODIGO"
				
				cQuery := ChangeQuery(cQuery)
				DbSelectArea("ACF")
				DbCloseArea()
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACF', .F., .T.)
				
				TCSetField('ACF', 'ACF_DATA', 'D')
			Else
		#ENDIF
				DbSelectArea("ACF")
				ACF->(DbSetOrder(2))
				If !lSelectFil
					ACF->(DbSeek(cFilACF + SA1->A1_COD + SA1->A1_LOJA))		// Cliente + Loja
				Endif
		#IFDEF TOP
			Endif		
		#ENDIF	
		While	!ACF->(Eof())						    .AND.;
				ACF->ACF_FILIAL $ Iif(	lSelectFil, ;
											aTmpFil[nPosAlias,2], ;
											cFilACF)	.AND.;
				ACF->ACF_CLIENT == SA1->A1_COD		.AND.;
				ACF->ACF_LOJA   == SA1->A1_LOJA

			If ACF->ACF_DATA < MV_PAR01 .OR. ACF->ACF_DATA > MV_PAR02
				ACF->(DbSkip())
				Loop
			Endif
            
			#IFDEF TOP
				If TcSrvType() <> "AS/400"
					
					If lSelectFil
						nPosAlias := FC010QFil(1,"ACF")
					EndIf
				
					cQuery :=	"SELECT ACG.*, " +;
								" SE1.E1_FILORIG " +;
								" FROM " + RetSqlName("ACG") + " ACG" +;
								" INNER JOIN " + RetSqlName("SE1") + " SE1" +;
								" ON " +;
								" ACG.ACG_FILORI = SE1.E1_FILIAL " +;
								" AND" +;
								" ACG.ACG_PREFIX = SE1.E1_PREFIXO" +;
								" AND" +;
								" ACG.ACG_TITULO = SE1.E1_NUM" +;
								" AND" +;
								" ACG.ACG_PARCEL = SE1.E1_PARCELA" +;
								" WHERE ACG.ACG_FILIAL = '" + ACF->ACF_FILIAL + "' AND " +;
								" ACG.ACG_CODIGO = '" + ACF->ACF_CODIGO + "' AND " +;
								" ACG.D_E_L_E_T_ <> '*' AND" +;
								" SE1.D_E_L_E_T_ <> '*' " +;
								" ORDER BY ACG.ACG_FILIAL, ACG.ACG_CODIGO"
					
					cQuery := ChangeQuery(cQuery)
					DbSelectArea("ACG")
					DbCloseArea()
					DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACG', .F., .T.)
					
					TCSetField('ACG', 'ACG_DTVENC', 'D')
					TCSetField('ACG', 'ACG_DTREAL', 'D')
					TCSetField('ACG', 'ACG_VALOR', 'N', 9, 2)
					TCSetField('ACG', 'ACG_ACRESC', 'N', 9, 2)
					TCSetField('ACG', 'ACG_DECRES', 'N', 9, 2)
				Else
			#ENDIF
					DbSelectArea("ACG")
					ACG->(DbSetOrder(1))
					ACG->(DbSeek(ACF->ACF_FILIAL + ACF->ACF_CODIGO))
			#IFDEF TOP
				Endif		
			#ENDIF	

			#IFNDEF TOP
				SE1->(DbSetOrder(1))	// E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
			#ENDIF
			While	!ACG->(Eof())					    .AND.;
					ACG->ACG_FILIAL == ACF->ACF_FILIAL	.AND.;
					ACG->ACG_CODIGO == ACF->ACF_CODIGO
				
				#IFDEF TOP
					cFilOriSE1 := ACG->E1_FILORIG
				#ELSE
					cFilOriSE1 := ""
					If SE1->(DbSeek(ACG->ACG_FILORI + ACG->ACG_PREFIX + ACG->ACG_TITULO + ACG->ACG_PARCEL + ACG->ACG_TIPO))
						cFilOriSE1 := SE1->E1_FILORIG
					Endif
				#ENDIF

				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//쿞e um titulo existir em atendimentos diferentes, guarda o codigo do atendimento   �
				//쿮m que ele se repete. No array aDados grava o titulo apenas uma vez.  		     �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				nPosTitulo := Ascan(aDados, {|x| x[1]+x[2]+x[3]+x[4]+x[5] == cFilOriSE1+ACG->ACG_PREFIX+ACG->ACG_TITULO+ACG->ACG_PARCEL+ACG->ACG_TIPO} )
				If nPosTitulo > 0
					AaDd(aDados[nPosTitulo][len(aDados[1])], ACF->ACF_FILIAL + ACF->ACF_CODIGO)
				Else
					AAdd(aDados, {	cFilOriSE1,;			    // Filial do Titulo
									ACG->ACG_PREFIX,;			// Prefixo
									ACG->ACG_TITULO,;			// Numero do titulo
									ACG->ACG_PARCEL,;			// Parcela
									ACG->ACG_TIPO,;				// Tipo
									ACG->ACG_NATURE,;			// Natureza
									DtoC(ACG->ACG_DTVENC),;		// Vencimento
									DtoC(ACG->ACG_DTREAL),;		// Vencimento real
									Transform(ACG->ACG_VALOR, PesqPict("ACG", "ACG_VALOR")),;		// Valor
									Transform(ACG->ACG_ACRESC, PesqPict("ACG", "ACG_ACRESC")),;	// Acrescimo
									Transform(ACG->ACG_DECRES, PesqPict("ACG", "ACG_DECRES")),;	// Desconto
									aStatus[Val(ACG_STATUS)+1],;									// Status
									ACG->ACG_OPERAD,;												// Responsavel
									Posicione("SU7",1,xFilial("SU7") + ACG->ACG_OPERAD,"U7_NOME"),;	// Nome do operador
									ACG->ACG_HIST,;	// Nome do operador
									{ACF->ACF_FILIAL + ACF->ACF_CODIGO};		// Todos os codigos de cobranca deste titulo
									} )
			    Endif

				DbSelectArea("ACG")
				ACG->(DbSkip())
            End
			#IFDEF TOP
				If TcSrvType() <> "AS/400"
					DbSelectArea("ACG")
					DbCloseArea()
					ChKFile("ACG")
				Endif
			#ENDIF
            
        	DbSelectArea("ACF")
        	ACF->(DbSkip())
		End
		#IFDEF TOP
			If TcSrvType() <> "AS/400"
				DbSelectArea("ACF")
				DbCloseArea()
				ChKFile("ACF")
			Endif
		#ENDIF
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿎aso nao tenha dados inicializa o objeto com valores em branco.�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		If len(aDados) == 0
			AaDd(aDados, { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )
		Else
			Asort( aDados,,, { |x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] } )
			FATPDLogUser("TK020LISTB")
		Endif

End Case

RestArea(aArea)
Return(aDados)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    쿟K020Recno       쿌utor  쿌rmando M. Tessaroli� Data � 29/08/02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Funcao que retorna o numero do record para o evento change     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � CALL CENTER						                              낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function TK020Recno(cAlias, cCodigo)

Local aArea := GetArea()
Local nRet	:= 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿛osiciona no registro para carregar a Enchoice�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSelectArea(cAlias)
DbSetOrder(1)
If DbSeek(xFilial(cAlias) + cCodigo)
	nRet := RecNo()
Else
	nRet := 0
Endif

RestArea(aArea)

Return(nRet)


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿟kSX3Box  튍utor  쿌rmando M. Tessaroli� Data �  19/02/03   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     �   Funcao que monta um array com todas as opcoes do combo   볍�
굇�          쿫ox a partir da leitura do dicionario de dados SX3.         볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros� cCampo - Nome do campo que sera pesquisado no SX3.         볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � Call Center                                                볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function Tkc020Box(cCampo)
Local aArea		:= GetArea()
Local aBox		:= {}
Local aItens	:= {}
Local nI		:= 0

DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek(cCampo)
	aAdd(aBox, &('{"' + StrTran(AllTrim( X3CBox() ),';','","') + '"}') )
Endif

aAdd(aItens, "" )
For nI := 1 To Len(aBox[1])
	aAdd(aItens, aBox[1][nI] )
Next nI

RestArea(aArea)

Return(aItens)

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMKC020A()
Verifica se o usuario selecionou mais de uma filial para realizar a consulta do historio de 
clientes. Esta funcao utiliza como premissa para indicar isso, a existencia das variaveis
aSelFil e aTmpFil que sao criadas no momento desta selecao na funcao Fc010Cli

@return lSelectFil Indica se a selecao de mais do que uma filial foi realizado pelo usuario
                   e se ela ser utilizada na consulta dos dados do historico de cobranca
@author Rafael Mota Previdi
@since 15/04/2019
/*/
//------------------------------------------------------------------------------------------------

Static Function TK020SelFil()

	Local lSelectFil   := .F.
	Local lHstCbMFil   := SuperGetMv("MV_HCOBMFL", .F., .F.)
	
	If (lHstCbMFil .And. !(Type("aSelFil") == "U") .And. !(Type("aTmpFil") == "U"))
		lSelectFil := .T.
	EndIf
	
Return lSelectFil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usu�rio utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que ser�o verificados.
    @param aFields, Array, Array com todos os Campos que ser�o verificados, utilizado 
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
    Finaliza o gerenciamento dos campos com prote豫o de dados.
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

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
    campos, esta fun豫o deve utilizada somente ap�s a inicializa豫o das variaveis 
    atravez da fun豫o FATPDLoad.
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, L�gico, Retorna se o campo ser� ofuscado.
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
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa寤es enviadas, 
    quando a regra de auditoria de rotinas com campos sens�veis ou pessoais estiver habilitada
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que ser� utilizada no log das tabelas
    @param nOpc, Numerico, Op豫o atribu�da a fun豫o em execu豫o - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria n�o esteja aplicada, tamb�m retorna falso.

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
    Fun豫o que verifica se a melhoria de Dados Protegidos existe.

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
