#INCLUDE "FINA630.CH"
#INCLUDE "PROTHEUS.CH"           

Static _cFilOld   //Filial 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fina630  ³ Autor ³ Claudio D. de Souza   ³ Data ³ 09/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetuar a transferencia a partir das solicitacoes incluidas³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fina630()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION Fina630(aAuto,nPosArotina)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lPanelFin := IsPanelFin()
Local lRet		:= .T.
Local IsAuto	:= Type("lMsErroAuto")<>"U"
Local lDefTop 	:= .F.
Local cAlias    := "SE6"

Private aRotina := MenuDef()
Private aRotAuto:= aAuto
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Vari veis para filtro do browse ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aIndexFil	:= {}	
Private bFiltraBrw
Private cFilPad := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro	:= STR0007 //"Transferência de débito"
Private lExcSX5	:= FWModeAccess("SX5",3) == "E"

If	!IsAuto
	lMsErroAuto := .F. // variavel interna da rotina automatica	   	
EndIf

_cFilOld := cFilAnt

#IFDEF TOP
	lDefTop := !(TcSrvType() == "AS/400" .Or. TcSrvType() == "iSeries")
#ENDIF

MV_PAR01 := 2
If lPanelFin
	PergInPanel("AFI630",.T.)
Else
   pergunte("AFI630",.T.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if MV_PAR01 = 1
	cFilPad += if(Empty(cFilpad),"", if(lDefTop," AND "," .AND. "))+" E6_SITSOL = '1' "
endif

cFilPad += If(Empty(cFilpad),"", " AND ") + "E6_TIPOSOL = 'R' "

If !lDefTop	
	bFiltraBrw := { || FilBrowse("SE6",@aIndexFil,@cFilPad) }
	dbSelectArea("SE6")
	Eval(bFiltraBrw)
Endif

DEFAULT nPosArotina := 0

If nPosArotina > 0 // Sera executada uma opcao diretamento de aRotina, sem passar pela mBrowse	
	dbSelectArea("SE6")
	bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
	lRet := Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina)
Else	
	mBrowse(6,1,22,75,"SE6",,,,,,Fa630Leg(),,,,,,,,Iif(lDefTop,cFilPad,Nil))
Endif	     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza o filtro MBROWSE                              		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SE6")
dbSetOrder(1) 
	
If !lDefTop
	EndFilBrw(cAlias,aIndexFil)
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa630Apv ³ Autor ³ Claudio D. de Souza   ³ Data ³ 14/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Aprovar solicitacoes de transferencia de debito            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa630Apv(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa630Apv(cAlias,nReg,nOpc)   
Local lPanelFin := IsPanelFin()
Local nOpcA                                                                
Local aTit := {}
Local nX
Local nSaldo
Local aAcho := {}
Local cFilSe1
Local cFilOld := cFilAnt // Guarda filial atual
Local cChave, cChave1
Local aRecno := {}
//Controle de abatimento
Local lTitpaiSE1 := .T.
Local cTitPai := ""

Local nY := 0
Local cParcela	:= Space(TamSx3("E1_PARCELA")[1])
Local lSolicAb	:= (mv_par01==1)	// Apenas solicitacoes em aberto
Local lDtMovFin := .T.
Local lRet		:= .F.
Local IsAuto	:= Type("lMsErroAuto")<>"U"
Local cHist     
Local aAreaSE1	:={} 
Local aAlt      :={}         
             
Local cTipo 	:= ""
Local nValBx	:= 0
Local nRecFRY	:= 0
Local cParcRec	:= ''
Local cDebito	:= ""
Local cCredit	:= ""
Local cCCD		:= ""
Local cCCC		:= ""
Local cItemD	:= ""
Local cItemC	:= ""
Local cCLVLDB	:= ""
Local cCLVLCR	:= ""
Local _cEnt05D	:= "" //Entidade 05
Local _cEnt05C	:= "" //Entidade 05
Local _cEnt06D	:= "" //Entidade 06
Local _cEnt06C	:= "" //Entidade 06
Local _cEnt07D	:= "" //Entidade 07
Local _cEnt07C	:= "" //Entidade 07
Local _cEnt08D	:= "" //Entidade 08
Local _cEnt08C	:= "" //Entidade 08
Local _cEnt09D	:= "" //Entidade 09
Local _cEnt09C	:= "" //Entidade 09
Local cFilSe2	:= xFilial("SE2")
//.T. - Gera o titulo de ISS (se houver) na filial de destino juntamente com o titulo NF, baixando o titulo ISS na origem
//.F. - Nã gera o titulo de ISS na filial de destino, permanecendo o titulo ISS na origem em aberto. 
Local lTrfISSf	:= GetNewPar("MV_TRFISSF",.T.)
Local cPrefixo	:= ""
Local lAltPref	:= .F.
Local aMsg		:= {}
Local aChaves 	:= {"E1_FILIAL", "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO"}
Local nPos 		:= 0
Local lCompSED	:= FwModeAccess("SED", 3) == "E"
Local nPosParc	:= 0

Private lF630Auto := aRotAuto<>nil

if lF630Auto
	DbSelectArea("SE6")
	DbSetorder(3)
	If (nT := ascan(aRotAuto,{|x| x[1]='E6_NUMSOL'}) ) > 0
		DbSeek(xFilial("SE6")+ Padr(aRotAuto[nT,2],TamSx3('E6_NUMSOL')[1 ]) )
	EndIf
Endif

// Apenas solicitacoes em aberto podem ser aprovadas.
If SE6->E6_SITSOL != "1"
	Help(" ",1,"FIN63004",,STR0021,1,0)
	Return .F.
Endif

// Nao eh permitido aprovar transferencias de titulos solicitados para
// outra filial.
If _cFilOld != SE6->E6_FILDEB
	Help(" ",1,"FIN63006",,	STR0008 + SE6->E6_FILDEB + CHR(13)+; //"Transferência solicitada para filial: "
									STR0009 + _cFilOld, 4 , 0 ) //"Filial atual: "
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "FA630APV" )

	lDtMovFin := Execblock( "FA630APV", .f., .f. )

	If !lDtMovFin
		Return .F.
	EndIf

EndIf

DbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SE6")
While ! SX3->(EOF()) .And. (SX3->X3_Arquivo == "SE6")
	If X3USO(SX3->X3_Usado) .And. cNivel >= SX3->X3_NIVEL
		// Na aprovacao, o historico da rejeicao nao deve ser apresentado
		If AllTrim(SX3->X3_CAMPO) != "E6_HISREJ"
			Aadd(aAcho, X3_CAMPO)
		Endif	
	Endif
	SX3->(dbSkip())
End

If lPanelFin
	RegToMemory(cAlias,.T.,,,FunName())                                       
   oPanelDados := FinWindow:GetVisPanel()
	oPanelDados:FreeChildren()		
   aDim := DLGinPANEL(oPanelDados)		
   nOpca := AxVisual(cAlias,nReg,nOpc,aAcho,,,,,,,.T.,,.T.,.T.,aDim)
Else
	If !lF630Auto
		nOpca := AxVisual(cAlias,nReg,nOpc,aAcho,,,,,,,,,.T.)
	Else
		If ascan(aRotAuto,{|x| x[1]='E6_NUMSOL'})>0 .and. SE6->(DbSeek(xFilial("SE6")+ Padr(aRotAuto[nT,2],TamSx3('E6_NUMSOL')[1]) ))
			INCLUI:= .F.
			RegToMemory(cAlias,.T.,,,) 
			nOpca := 1
		EndIf
	EndIf
Endif	

If nOpcA == 1
	cFilAnt 	:= SE6->E6_FILORIG
	cFilSe1 	:= xFilial("SE1")
	Posicione("SE1",1,cFilSe1+SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO),"E1_CLIENTE")

	lAltPref 	:= AllTrim(SE1->E1_ORIGEM) $ "MATA460" .And. (lExcSX5 .Or. ExistBlock("CHGX5FIL")) .And. GetMV("MV_TPNRNFS") == "1" .And.;
				AllTrim(SuperGetMV("MV_1DUPREF")) == "SF2->F2_SERIE" //Conteudo padrao do parametro

	If lAltPref
		aAdd(aMsg,STR0023)
		aAdd(aMsg,STR0024)
		aAdd(aMsg,STR0025)
		aAdd(aMsg,STR0026)
		aAdd(aMsg,STR0027)
		aAdd(aMsg,STR0028)
		
		FormBatch(STR0029,aMsg,{{1,.T.,{|| lExeFun := .T., FechaBatch()}}})
		cOrigem := SE1->E1_ORIGEM
	EndIf
			
	If	!IsAuto
		lMsErroAuto := .F. // variavel interna da rotina automatica	   	
	Endif
	If SE1->(!Eof())
		BEGIN TRANSACTION
			If RecLock("SE6",.F.)
				SE6->E6_SITSOL := "2" // Solicitacao aprovada
				SE6->E6_USRAPV :=	RetCodUsr() // Aprovador
				SE6->(MsUnlock())
				// Baixa o titulo na filial de origem
				aTit := {}
				aAreaSE1:=SE1->(GetArea())				
				nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA, cFilSe1,,SE1->E1_TIPO)
				RestArea(aAreaSE1)
				nSaldo := (SE1->E1_SALDO - nAbatim)
				nSaldo += SE1->E1_SDACRES
				nSaldo -= SE1->E1_SDDECRE
				cChave := cFilSe1 + SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA)   
				cTitPai := SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO+E6_CLIENTE+E6_LOJA)
				nRecNoSe1 := SE1->(Recno())
				SE1->(MsSeek(cChave))  
				// Primeiro adiciona os registros a serem transferidos, pois os primeiro
				// deve-se transferir o titulo principal, depois os agragados. Como os agragados podem
				// vir primeiro, entao utiliza-se uma matriz de recnos para transferir os titulos na ordem
				// em que foram incluidos, pois um abatimento nunca eh incluido primeiro que um titulo
				// principal
				// Os titulos de impostos nao se incluem nesta lista visto que os mesmos serao incluidos junto com
				// o titulo principal
				While ! lMsErroAuto .and. SE1->(!Eof()) .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA) == cChave
				  	// Nao eh abatimento
				  	If !(SE1->E1_TIPO $ MVABATIM)
				  		If SE1->E1_TIPO == SE6->E6_TIPO // Titulo Principal
							Aadd(aRecno, SE1->(Recno()))
						EndIf					  			
					// Abatimento (menos impostos) sem baixas						
				  	ElseIf	!(SE1->E1_TIPO $ MVIRABT+"/"+MVINABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVISABT+"/"+MVFUABT+"/"+MVI2ABT)
				  		// Se nao houve baixa, adiciona para transferencia
				  		If Empty( SE1->E1_BAIXA )
							If lTitpaiSE1 
								If !Empty(SE1->E1_TITPAI) .AND. Alltrim(SE1->E1_TITPAI) <> AllTrim(cTitPai)
									SE1->(DbSkip())  
									Loop
								Endif
				 			Endif				  		
			  				Aadd(aRecno, SE1->(Recno()))
			  			Else	// Se jah houver baixa, volta o saldo do titulo principal
			  				nSaldo += nAbatim
			  			EndIf			  				
					Endif  
					SE1->(DbSkip())
				Enddo	
				aSort(aRecno)              
				// Transfere todos os titulos agregados
				nY := 1
				While ! lMsErroAuto .And. nY <= Len(aRecno)
					SE1->(MsGoto(aRecno[nY]))    
					aTit := {}
					//garante que os campos chaves serao os primeiros itens do array
					//para validacao se chave existe
					For nX := 1 To Len(aChaves)
						nPos := SE1->(FieldPos(aChaves[nX])) 
						If nPos > 0
							AADD(aTit, { SE1->(FieldName(nPos)), SE1->(FieldGet(nPos)), NIL } )
						EndIf	
					Next nX  
					
					For nX := 1 To SE1->(fCount())
						If aScan(aChaves,{|x| x == FieldName(nX) }) == 0						
							AADD(aTit, { SE1->(FieldName(nX)), SE1->(FieldGet(nX)), NIL } )
							If aTit[nX][1] == "E1_NATUREZ" .And. lCompSED .And. !lF630Auto
								aTit[nX][2] := ConfigSED(aTit[nX][2])
							EndIf
						EndIf						
					Next
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_FILIAL"})
					If nX > 0
						cFilAnt := SE6->E6_FILDEB
						aTit[nX][2] := xFilial("SE1") // Codigo da filial que recebera o titulo
						cFilAnt := _cFilOld
					Endif       
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_FILORIG"})
					If nX > 0
						aTit[nX][2] := SE6->E6_FILDEB	// Codigo da filial de origem do titulo, lembrando que o E6_FILDEB posicionado é aonde está o título no momento
					Endif       
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_ORIGEM"})
					If nX > 0
						aTit[nX][2] := IIf(lAltPref,cOrigem,"FINA630") // Codigo da Rotina
					Endif
					cPrefixo := SE6->E6_PREFIXO
					If lAltPref
						nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_PREFIXO"})
						If nX > 0
							cPrefixo    := "TRS"
							aTit[nX][2] := cPrefixo // Prefixo do título
						Endif					
						nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_TITPAI"})
						If nX > 0
							aTit[nX][2] := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) // Prefixo do título
						Endif						
					EndIf
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_FATURA"})
					If nX > 0
						aTit[nX][2] := "" 
					Endif																			
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_CLIENTE"})
					If nX > 0
						aTit[nX][2] := SE6->E6_CLIENTE // Codigo do cliente que recebera o titulo
					Endif
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_LOJA"})
					If nX > 0
						aTit[nX][2] := SE6->E6_LOJA // Codigo da loja do cliente que recebera o titulo
					Endif
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_DESDOBR"})
					If nX > 0
						aTit[nX][2] := "2" // Forca o desdobramento como nao
					Endif    
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_NUMSOL"})
					If nX > 0
						aTit[nX][2] := "" // Limpa numero da solicitacao na filial destino (debito)
					Endif
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_TIPO"})
					If nX > 0
						cTipo := aTit[nX][2]  //Tipo do titulo que sera incluido para verificar a parcela
					Endif 		 
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_MODSPB"})
					If nX > 0
						If(Empty(aTit[nX][2]),aTit[nX][2]:="1",.T.)						
					Endif					
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_APLVLMN"})
					If nX > 0
						If(Empty(aTit[nX][2]),aTit[nX][2]:="1",.T.)
					Endif										
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_VALOR"})
					If nX > 0
						aTit[nX][2] := SE6->E6_VALOR
					Endif
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_RATFIN"})
					If nX > 0
						If Empty(aTit[nX][2])
							aTit[nX][2] := "2"
						Endif
					Endif		
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_TCONHTL"})
					If nX > 0
						If Empty(aTit[nX][2])
							aTit[nX][2] := "3"
						Endif
					Endif			
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_PARCELA"})
					If nX > 0
						nPosParc := nX
						// Incrementa a parcela para que nao haja registro duplicado na filial Debito
						If cTipo $ MVABATIM
							aTit[nX][2] := cParcela
						Else
							aTit[nX][2] := SE6->E6_PARCELA
							cFilAnt := SE6->E6_FILDEB
							cFilSe1 := xFilial("SE1")
							cFilAnt := _cFilOld
							cChave := cFilSe1 + SE6->(cPrefixo+E6_NUM+aTit[nX][2]+cTipo)
							While SE1->(MsSeek(cChave))
								aTit[nX][2] := Soma1(aTit[nX][2])
								cChave := cFilSe1 + SE6->(cPrefixo+E6_NUM+aTit[nX][2]+cTipo)
							Enddo
							cParcela := aTit[nX][2]  //Parcela do titulo Principal
						Endif
					Endif
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_TPDESC"})
					If nX > 0
						If Empty(aTit[nX][2])
							aTit[nX][2] := "C"
						Endif
					Endif			
					// Grava titulo na filial de debito destino
					MSExecAuto({|x, y| FINA040(x, y)}, aTit, 3)
					
					nY ++
				End	
				If lMsErroAuto
					if !IsBlind()
						MostraErro()
					EndIf
					DisarmTransaction()
					Break
				Else	
					If nPosParc > 0
						SE6->(RecLock("SE6"))          
						SE6->E6_PARCDES := aTit[nPosParc][2]
						SE6->(MSUnlock())
					EndIf	
					SE1->(MsGoto(nRecNoSe1))
					cFilSe1 := SE6->E6_FILORIG
					// Altera para filial do titulo de origem para fazer a baixa
					cFilAnt := cFilSe1
					aTit := {}
					AADD(aTit , {"E1_PREFIXO"	, SE6->E6_PREFIXO	, NIL})
					AADD(aTit , {"E1_NUM"		, SE6->E6_NUM		, NIL})
					AADD(aTit , {"E1_PARCELA"	, SE6->E6_PARCELA	, NIL})
					AADD(aTit , {"E1_TIPO"		, SE6->E6_TIPO		, NIL})
					AADD(aTit , {"E1_CLIENTE"	, SE1->E1_CLIENTE	, NIL})
					AADD(aTit , {"E1_LOJA"		, SE1->E1_LOJA		, NIL})
					AADD(aTit , {"AUTMOTBX"		, "TRF"				, NIL})
					AADD(aTit , {"AUTDTBAIXA"	, dDataBase			, NIL})
					AADD(aTit , {"AUTDTCREDITO", dDataBase			, NIL})
					//Ponto de entrada criado para alterar a gravação do histórico na SE5
					IF ExistBlock("F630HIST")
		 				cHist:=ExecBlock("F630HIST",.f.,.f.)  
	 					AADD(aTit , {"AUTHIST"		, cHist			,NIL})
	   				Else
					AADD(aTit , {"AUTHIST"		, STR0010 + SE6->E6_FILORIG + STR0011 + SE6->E6_FILDEB,NIL}) //"Bx. p/transf. da filial "###" p/"   
					EndIf
					AADD(aTit , {"AUTVALREC"	, nSaldo				, NIL })
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Executa a Baixa do Titulo                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !IsAuto
						MSExecAuto({|x, y| FINA070(x, y)}, aTit, 3)
					Else
						lRet	:= FINA070(aTit, 3)
					Endif
					If lMsErroAuto .or. !lRet
						If lMsErroAuto
							MostraErro()
						EndIf	
						DisarmTransaction()
						Break
					Else
						// Transfere SK1 tambem.
						If SK1->(MsSeek(xFilial("SK1")+SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO)))
							RecLock("SK1")
							SK1->K1_FILIAL		:= SE6->E6_FILDEB
							SK1->K1_CLIENTE		:= SE6->E6_CLIENTE
							SK1->K1_LOJA		:= SE6->E6_LOJA
							SK1->K1_FILORIG		:= SE6->E6_FILDEB
							MsUnlock()
						Endif
						lRet	:= .T.
					EndIf
					If lRet
	 					If SE1->E1_ISS != 0 .And. lTrfISSf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Baixa tambem os registro de impostos-ISS	  ³ 
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							dbSelectArea("SE2")
							dbSetOrder(1)
							If dbSeek(xFilial("SE2")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA))
								IF AllTrim(E2_NATUREZ) = Alltrim(&(GetMv("MV_ISS"))) .and. ;
															STR(SE2->E2_SALDO,17,2) == STR(SE2->E2_VALOR,17,2)
	
									cFilSe2 := If(!Empty(cFilSe2), SE6->E6_FILORIG,cFilSe2)
									aTit := {}
									// Altera para filial do titulo de origem para fazer a baixa
									cFilAnt := cFilSe2
									AADD(aTit , {"E2_FILIAL"	, SE2->E2_FILIAL	, NIL})								
									AADD(aTit , {"E2_PREFIXO"	, SE2->E2_PREFIXO	, NIL})
									AADD(aTit , {"E2_NUM"		, SE2->E2_NUM		, NIL})
									AADD(aTit , {"E2_PARCELA"	, SE2->E2_PARCELA	, NIL})
									AADD(aTit , {"E2_TIPO"		, SE2->E2_TIPO		, NIL})
									AADD(aTit , {"E2_NATUREZ"	, SE2->E2_NATUREZ	, NIL})
									AADD(aTit , {"E2_FORNECE"	, SE2->E2_FORNECE	, NIL})
									AADD(aTit , {"E2_LOJA"		, SE2->E2_LOJA		, NIL})
									AADD(aTit , {"AUTMOTBX"		, "TRF"				, NIL})
									AADD(aTit , {"AUTDTBAIXA"	, dDataBase			, NIL})
									//Ponto de entrada criado para alterar a gravação do histórico na SE5
								
									IF ExistBlock("F630HIST")
						 				cHist:=ExecBlock("F630HIST",.f.,.f.)  
					 					AADD(aTit , {"AUTHIST"		, cHist			,NIL})
				    				Else
				 						AADD(aTit , {"AUTHIST"		, STR0010 + SE6->E6_FILORIG + STR0011 + SE6->E6_FILDEB,NIL}) //"Bx. p/transf. da filial "###" p/"   
									EndIf
									AADD(aTit , {"AUTVLRPG"	, SE2->E2_SALDO	, NIL })
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Executa a Baixa do Titulo                                         ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If !IsAuto
										MSExecAuto({|x, y| FINA080(x, y)}, aTit, 3)
									Else
										lRet	:= FINA080(aTit, 3)
									Endif
				
									If lMsErroAuto
										MostraErro()
										DisarmTransaction()
										Break
									Else
										cFilAnt := cFilOld // Restaura filial atual	
										lRet	:= .T.
									Endif
								EndIf
							Endif
						EndIf
					EndIf
				Endif	
			Endif
		END TRANSACTION	
	Endif	
Endif

///numbor			
aadd( aAlt,{ STR0030,'','','',STR0031 +  Alltrim(cFilOld) })   
//chamada da Função que cria o Histórico de Cobrança
FinaCONC(aAlt)

cFilAnt := cFilOld	// Restaura filial atual
If lSolicAb 		// Apenas solicitacoes em aberto
	SE6->(DbSetOrder(2))
	SE6->(MsSeek(xFilial("SE6")+"1")) // Posiciona na primeira solicitacao em aberto
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa630Rej ³ Autor ³ Claudio D. de Souza   ³ Data ³ 26/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rejeitar solicitacoes de transferencia de debito           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa630Rej(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa630Rej(cAlias,nReg,nOpc)
Local nOpcA
Local aAcho := {}
Local aArea := GetArea()
Local cFilSe1
Local lDtMovFin := .T.
Local aAlt    := {} 
PRIVATE aMemos // Campos memos virtuais, utilizada na AxAltera.

// Apenas solicitacoes em aberto podem ser rejeitadas.
If SE6->E6_SITSOL != "1"
	Help(" ",1,"FIN63001")
	Return
Endif

// Nao eh permitido rejeitar transferencias de titulos solicitados para
// outra filial.
If _cFilOld != SE6->E6_FILDEB
	Help(" ",1,"FIN63002",,	STR0008 + SE6->E6_FILDEB + CHR(13)+; //"Transferência solicitada para filial: "
									STR0009 + _cFilOld, 4 , 0 ) //"Filial atual: "
	Return
Endif

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Ponto de Entrada ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If ExistBlock( "FA630REJ" )

    lDtMovFin := Execblock( "FA630REJ", .f., .f. )

    If !lDtMovFin
       Return
    EndIf

 EndIf

DbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SE6")
While ! SX3->(EOF()) .And. (SX3->X3_Arquivo == "SE6")
	If X3USO(SX3->X3_Usado) .And. cNivel >= SX3->X3_NIVEL
		// Na rejeicao, o historico da solicitacao nao deve ser apresentado
		If AllTrim(SX3->X3_CAMPO) != "E6_HISTSOL"
			Aadd(aAcho, X3_CAMPO)
		Endif	
	Endif
	SX3->(dbSkip())
End
aMemos := {{"E6_CDHREJ","E6_HISREJ"}}

If IsPanelFin()
	dbSelectArea("SET")
	RegToMemory("SET",.T.,,,FunName())                                       
	oPanelDados := FinWindow:GetVisPanel()	
	oPanelDados:FreeChildren()
	aDim := DLGinPANEL(oPanelDados)
	Altera := .T.			
	nOpca := AxAltera(cAlias,nReg,nOpc,aAcho,{"E6_HISREJ"},,,,,,,,,,,,.T.,oPanelDados,aDim,FinWindow)		
Else
	nOpca := AxAltera(cAlias,nReg,nOpc,aAcho,{"E6_HISREJ"})
Endif	

If nOpcA == 1
        
	cFilAnt := SE6->E6_FILORIG  //somente coloca cFilAnt na filial de origem para recuperar xfilial("SE1") utilizado na busca
	cFilSe1 := xFilial("SE1")
	cFilAnt := _cFilOld // volta a filial de origem
	BEGIN TRANSACTION
		//grava STATUS rejeitado na SE6
		RecLock("SE6",.F.)
		SE6->E6_SITSOL := "3" // Solicitacao rejeitada
		SE6->E6_USRAPV :=	RetCodUsr() // Rejeitado por
		SE6->(MsUnlock())
		//limpa numero da solicitacao na SE1
		SE1->(DbSetOrder(1))
		If SE1->(MsSeek(cFilSe1+SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO)))
			RecLock("SE1",.F.)
			SE1->E1_NUMSOL := " " // Limpa o numero para que ele seja possivel nova solicitacao de transferencia
			SE1->(MsUnlock())
		Endif
	END TRANSACTION	
	
	cFilAnt := SE6->E6_FILORIG 
	///numbor			
	aadd( aAlt,{ STR0032,'','','',STR0033 +  Alltrim(SE6->E6_FILDEB)  + ' rejeitada '})   
	//chamada da Função que cria o Histórico de Cobrança
	FinaCONC(aAlt)
	
	cFilAnt := _cFilOld // volta a filial de origem
	
Endif
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa630Exc ³ Autor ³ Claudio D. de Souza   ³ Data ³ 27/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Excluir solicitacoes de transferencia de debito em aberto  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa630Exc(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa630Exc(cAlias,nReg,nOpc)                 
Local lPanelFin := IsPanelFin()
Local aAcho := {}
Local cFilSe1 := xFilial("SE1")  
Local cFilSe5 := xFilial("SE5")
Local lRet := .T.
Local cFilAtu := cFilAnt
Local lBaixaTRF := .F.
Local nOpca := 0              
Local IsAuto	:= Type("lMsErroAuto")<>"U"   
Local nOpcX := 0
Local lAltPref := .F.
Local cPrefixTit := ""
Local nRecNoSM0 := 0
Local lSE5Cmp	:= FwModeAccess("SE5", 3 ) == "C"

PRIVATE aMemos // Campos memos virtuais, utilizada na AxDeleta para excluir campos
					// memo.
Private lF630Auto := aRotAuto<>nil

cFilAnt := _cFilOld // Para o caso do Browse ter mudado de filial

if lF630Auto

	DbSelectArea("SE6")
	DbSetorder(3)
	If (nT := ascan(aRotAuto,{|x| x[1]='E6_NUMSOL'}) ) > 0
		If !DbSeek(xFilial("SE6")+ Padr(aRotAuto[nT,2],TamSx3('E6_NUMSOL')[1 ]) )
			lRet := .F.
		EndIf
	EndIf

Endif

DbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SE6")
While ! SX3->(EOF()) .And. (SX3->X3_Arquivo == "SE6")
	If X3USO(SX3->X3_Usado) .And. cNivel >= SX3->X3_NIVEL
		// Na aprovacao, o historico da rejeicao nao deve ser apresentado
		If AllTrim(SX3->X3_CAMPO) != "E6_HISREJ"
			Aadd(aAcho, X3_CAMPO)
		Endif	
	Endif
	SX3->(dbSkip())
End

If	!IsAuto
	lMsErroAuto := .F. // variavel interna da rotina automatica	   	
Endif

// Apenas solicitacoes em aberto podem ser excluidas.
If lRet .and. (nOpc == 5 .and. SE6->E6_SITSOL != "1") 
	Help(" ",1,"FIN63007")
   lRet := .F.
ElseIf lRet .and. (nOpc == 6 .and. SE6->E6_SITSOL != "2") 
	Help(" ",1,"FIN63003",,STR0017,1,0)	 //"Apenas transferências aprovadas podem ser estornadas."
   lRet := .F.
Endif

//Ponto de entrada para permitir ou nao que determinado usuario efetue esta operacao (estorno)
If lRet .and. nOpc == 6 .and. ExistBlock("FA630EST")
	lRet := ExecBlock("FA630EST",.F.,.F.)
Endif

If lRet
	aMemos := {	{"E6_CDHSOL","E6_HISTSOL"},;
					{"E6_CDHREJ","E6_HISREJ"}}
	
	If lF630Auto
		nOpca := 2
	ElseIf  lRet .and. nOpc == 5  //Exclusao
		If lPanelFin		
			RegToMemory(cAlias,.T.,,,FunName())                                       
			oPanelDados := FinWindow:GetVisPanel()
			oPanelDados:FreeChildren()		
			aDim := DLGinPANEL(oPanelDados)		
			nOpca := AxDeleta(cAlias,nReg,nOpc,,,,,,,,aAcho,.T.,oPanelDados,aDim)		
		Else		
			nOpca := AxDeleta(cAlias,nReg,nOpc)
		Endif			
		
	ElseIf  lRet          //Estorno

		nOpcx := 0
		nOpcx := AxVisual( cAlias, (cAlias)->( Recno() ), 2)
		//Favor manter o procedimento abaixo pois ele adequa o resultado da AxVisual
		//ao da AxDeleta (Axaltera inverte os valores de retorno (1 = cancela e 2 = confirma))
		If nOpcx == 1 //Confirmou operacao
			nOpca := 2
		Else	
			nOpca := 1
		Endif
	Endif
	If nOpca == 2
		BEGIN TRANSACTION
		If RecLock("SE6",.F.)   
			SE6->E6_SITSOL := "4" // Solicitacao estornada
			SE6->E6_USRAPV :=	RetCodUsr() // Rejeitado por
			SE6->(MSUNLOCK())
			SE1->(DbSetOrder(1))
		  	// Filial a ser utilizada para localizar o titulo, FILIAL ORIGEM do SE6 caso o SE1
			// seja exclusivo ou xFilial se o SE1 for compartilhado			
			cFilSe1 := If(!Empty(cFilSe1), xFilial("SE1",SE6->E6_FILORIG),xFilial("SE1",cFilSe1)) 
			If SE1->(MsSeek(cFilSe1+SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO)))
				If RecLock("SE1",.F.)
					lAltPref := AllTrim(SE1->E1_ORIGEM) $ "MATA460" .And. (lExcSX5 .Or. ExistBlock("CHGX5FIL")) .And. GetMV("MV_TPNRNFS") == "1" .And.;
								AllTrim(SuperGetMV("MV_1DUPREF")) == "SF2->F2_SERIE" //Conteudo padrao do parametro
					// Limpa numero quando excluida a solicitacao da transferencia
					SE1->E1_NUMSOL := "" 
					MsUnlock()
				EndIf
			Endif	
			//Cancela a baixa por TRF na filial origem
			SE5->(dbSelectArea("SE5"))
			SE5->(dbSetOrder(7)) //		E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA
			cFilSe5 := If(!Empty(cFilSe5), SE6->E6_FILORIG,cFilSe5) 
			cFilAtu := cFilAnt
			cFilAnt := cFilSe5
			lBaixaTRF := .F.
			If SE5->(MsSeek(Iif(lSE5Cmp,xFilial("SE5"),cFilSe5)+SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO)))
				cKeySe5 := SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
				While SE5->(!EOF()) .AND. cKeySe5 == SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
					If SE5->E5_MOTBX == "TRF" .AND. SE5->E5_SITUACA != 'C' 
						lBaixaTRF := .T.
						lRet := FindISSBx(SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA))
						 FindIrfBx()
						Exit
					Endif
					SE5->(dbSkip())
				Enddo
				If lBaixaTRF .and. lRet
					//Cancelo Baixa Titulos a Receber
					_aTit := {}
					AADD(_aTit , {"E1_PREFIXO"	,SE6->E6_PREFIXO	,NIL})
					AADD(_aTit , {"E1_NUM"		,SE6->E6_NUM		,NIL})
					AADD(_aTit , {"E1_PARCELA"	,SE6->E6_PARCELA	,NIL})
					AADD(_aTit , {"E1_TIPO"  	,SE6->E6_TIPO		,NIL})
					AADD(_aTit , {"E1_CLIENTE"	,SE6->E6_CLIENTE	,NIL})
					AADD(_aTit , {"E1_LOJA"  	,SE6->E6_LOJA		,NIL})

					cFilAnt := SE6->E6_FILORIG
					If !IsAuto
						MSExecAuto({|x, y| FINA070(x, y)}, _aTit, 5)
					Else
						lRet	:= FINA070(_aTit, 5)
					EndIf
					cFilAnt := cFilSe5

					If  lMsErroAuto
						lRet	:= .F.
						If !IsBlind()
							MOSTRAERRO() // Sempre que o micro comeca a apitar esta ocorrendo um erro desta forma
						EndIf
						DisarmTransaction()
						Break
					ElseIf lRet
						// Exclui o registro gerado pela transferencia original na filial destino (debito)
						cFilSe1 := If(!Empty(cFilSe1), SE6->E6_FILDEB,cFilSe1) 
						cFilAnt := cFilSe1
						cFilSe1	:= xFilial("SE1",cFilSe1) 
						SE1->(DbSetOrder(1))

						If lAltPref
							cPrefixTit := "TRS"
						Else
							cPrefixTit := SE6->E6_PREFIXO
						EndIf

						If SE1->(MsSeek(cFilSe1+SE6->(cPrefixTit+E6_NUM+E6_PARCDES+E6_TIPO)))
							_aTit := {}
							AADD(_aTit , {"E1_PREFIXO"	,cPrefixTit		,NIL})
							AADD(_aTit , {"E1_NUM"		,SE6->E6_NUM		,NIL})
							AADD(_aTit , {"E1_PARCELA"	,SE6->E6_PARCDES	,NIL})
							AADD(_aTit , {"E1_TIPO"  	,SE6->E6_TIPO		,NIL})
							AADD(_aTit , {"E1_CLIENTE"	,SE6->E6_CLIENTE	,NIL})
							AADD(_aTit , {"E1_LOJA"  	,SE6->E6_LOJA		,NIL})

							//Posiciona na filial de transferencia
							cFilAnt := SE6->E6_FILDEB
							nRecNoSM0 := SM0->( RecNo() )
							If cFilAnt <> Trim( SM0->M0_CODFIL )
								SM0->( MsSeek( cEmpAnt + cFilAnt ) )
							EndIf

							If !IsAuto
								MSExecAuto({|x, y| FINA040(x, y)}, _aTit, 5)
							Else
								lRet :=FINA040(_aTit, 5)
							Endif

							//Posiciona na filial de origem
							cFilAnt := cFilSe1
							SM0->( MsGoTo( nRecNoSM0 ) )

							If  lMsErroAuto
								lRet := .F.
								If !IsBlind()
									MOSTRAERRO() // Sempre que o micro comeca a apitar esta ocorrendo um erro desta forma
								EndIf
								DisarmTransaction()
								Break
							EndIf
						 EndIf
					EndIf
				EndIf
				SE6->(DbSkip())
			EndIf
			cFilAnt := cFilAtu
		Endif
		END TRANSACTION
	Endif
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Fa630Pes ³ Autor ³ Claudio D. de Souza   ³ Data ³ 27/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa com filtro                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa630Pes( )                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA630 / TMS                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa630Pes
Local nRecNo := RecNo()

cFilAnt := _cFilOld // Para o caso do Browse ter mudado de filial

AxPesqui()
DbSetOrder(2)
If Eof() // Se estiver fora do filtro, posiciona no registro anterior antes da pesquisa
	Help(" ",1,"CPOFILTER")
	DbGoto(nRecNo)
Endif
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa630Leg    ³ Autor ³ Claudio D. de Souza ³ Data ³ 27.03.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse ou retorna a ³±±
±±³          ³ para o BROWSE                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA630                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa630Leg(nReg)

Local aLegenda := { {"BR_VERDE"		, STR0012 },;  //"Solicitação em aberto"
					{"BR_AZUL"		,STR0013 },;  //"Solicitação aprovada"
					{"BR_VERMELHO"	, STR0014 },; //"Solicitação rejeitada"
					{"BR_PRETO"		, STR0020 } } //"Transferência estornada" //"Transferência estornada"
Local uRetorno := .T.

If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, { "E6_SITSOL == '1'"	, aLegenda[1][1] } )
	Aadd(uRetorno, { "E6_SITSOL == '2'"	, aLegenda[2][1] } )
	Aadd(uRetorno, { "E6_SITSOL == '3'"	, aLegenda[3][1] } )
	Aadd(uRetorno, { "E6_SITSOL == '4'"	, aLegenda[4][1] } )	
Else
	BrwLegenda(cCadastro, STR0006,aLegenda) //"Legenda" //"Legenda"
Endif

Return uRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IniFimTran³ Autor ³ Claudio D. de Souza   ³ Data ³ 11/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a chave que restringe o Inicio/Fim das sol. transf.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Chave das solic. de transf.	                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA630                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function IniFimTrans
Return  xFilial('SE6')+'1' // Posiciona no inicio das solic. de transferencias


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³28/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina	:=	{	{STR0001	,"Fa630Pes", 0 , 1,,.F.},; //"Pesquisar"
						{STR0002	,"AxVisual", 0 , 2},; //"Visualizar"
						{STR0003	,"Fa630Apv", 0 , 2},; //"Aprovar"
						{STR0004	,"Fa630Rej", 0 , 4},; //"Rejeitar"
						{STR0005	,"Fa630Exc", 0 , 5},; //"Excluir"
						{STR0015	,"Fa630Exc", 0 , 6},;//"Estornar" //"Estornar"
						{STR0006	,"Fa630Leg", 0 , 5, ,.F.}}  //"Legenda"
Return(aRotina)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinA630T   ³ Autor ³ Marcelo Celi Marques ³ Data ³ 04.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada semi-automatica utilizado pelo gestor financeiro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA630                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FinA630T(aParam)
	cRotinaExec := "FINA630"
	ReCreateBrow("SE6",FinWindow)      		
	FinA630(aParam[1])         
	ReCreateBrow("SE6",FinWindow)      	

	dbSelectArea("SE6")
	
	INCLUI := .F.
	ALTERA := .F.
	
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FindISSBx  ºAutor  ³Karen Honda        º Data ³  30/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cancela a baixa do titulo ISS que foi baixado na transferencia
±±ºDesc.     ³ ao realizar o estorno.
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FindISSBx(cChaveReg)

Local aArea := GetArea()
Local aAreaSE5 := SE5->(GetArea())
Local lRet 	:= .T.
Local _aTit	:=	{}

Local cCompleteKey	:= "" 
Local cISSNatur 		:= AllTrim(&(GetMv("MV_ISS")))
Local cMunicip 		:= Padr(GetMV("MV_MUNIC"),TamSx3("E5_CLIFOR")[1])

Default cChaveReg := ""

cCompleteKey := cChaveReg+'TX '+cMunicip

dbSelectArea("SE5")
dbSetOrder(7) //	E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA
If dbSeek(cCompleteKey)
	While SE5->(!Eof()) .and. (cCompleteKey == E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR)

		If (Alltrim(SE5->E5_NATUREZ) == cISSNatur) .and. (SE5->E5_RECPAG == 'P')

			//Cancelo Baixa Titulos a Pagar de ISS
			_aTit := {}
			AADD(_aTit , {"E2_PREFIXO"	,SE5->E5_PREFIXO	,NIL})
			AADD(_aTit , {"E2_NUM"		,SE5->E5_NUMERO	,NIL})
			AADD(_aTit , {"E2_PARCELA"	,SE5->E5_PARCELA	,NIL})
			AADD(_aTit , {"E2_TIPO"  	,SE5->E5_TIPO		,NIL})
			AADD(_aTit , {"E2_FORNECE"	,SE5->E5_CLIFOR	,NIL})
			AADD(_aTit , {"E2_LOJA"  	,SE5->E5_LOJA		,NIL})

			MSExecAuto({|x, y| FINA080(x, y)}, _aTit, 5)

			If  lMsErroAuto
				lRet	:= .F.
				If !IsBlind()
					MOSTRAERRO() 
				EndIf
				DisarmTransaction()
				Break
			Else
				Exit
			Endif
		Endif

		SE5->(dbSkip())
	EndDo
Endif

RestARea(aAreaSE5)
RestARea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FindIrfBx  ºAutor  ³Jose.Gavetti       º Data ³  19/11/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cancela a baixa do titulo IRF que foi baixado na transferencia
±±ºDesc.     ³ ao realizar o estorno.
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FindIrfBx()

Local aArea := GetArea()
Local aAreaSE5 := SE5->(GetArea())
Local lRet 	:= .T.
Local _aTit	:=	{}
Local lIrPjBxCr	:= If (FindFunction("FIrPjBxCr"),FIrPjBxCr(),.F.)
Local cCompleteKey := ""
Local cForUNIAO	:= ""
Local cLojaIrrf	:= ""

cForUNIAO := PADR(GetMV("MV_UNIAO"),TAMSX3("E2_FORNECE")[1])
cLojaIrrf  := Padr( "00", Len( SE2->E2_LOJA ), "0" )
		
dbSelectArea("SE5")
dbSetOrder(7) // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	If dbSeek(xFilial("SE5")+SE5->(E5_PREFIXO+E5_NUMERO))
	 While !(EOF()) .And. (xFilial("SE5")== SE5->E5_FILIAL) .AND. SE5->(E5_PREFIXO+E5_NUMERO) == SE2->(E2_PREFIXO+E2_NUM)
	 If cForUNIAO+cLojaIrrf == (SE5->(E5_FORNECE+E5_LOJA)) .AND. cForUNIAO == SE5->E5_CLIFOR .AND. SE5->E5_TIPO = 'TX'
	 
			//Cancelo Baixa Titulos a Pagar de IRF
			_aTit := {}
			AADD(_aTit , {"E2_PREFIXO"	,SE5->E5_PREFIXO	,NIL})
			AADD(_aTit , {"E2_NUM"		,SE5->E5_NUMERO	,NIL})
			AADD(_aTit , {"E2_PARCELA"	,SE5->E5_PARCELA	,NIL})
			AADD(_aTit , {"E2_TIPO"  	,SE5->E5_TIPO		,NIL})
			AADD(_aTit , {"E2_FORNECE"	,SE5->E5_CLIFOR	,NIL})
			AADD(_aTit , {"E2_LOJA"  	,SE5->E5_LOJA		,NIL})

			MSExecAuto({|x, y| FINA080(x, y)}, _aTit, 5)

			If  lMsErroAuto
				lRet	:= .F.
				If !IsBlind()
					MOSTRAERRO() 
				EndIf
				DisarmTransaction()
				Break
			Else
				Exit
			Endif
		Endif

		SE5->(dbSkip())
	EndDo
Endif

RestARea(aAreaSE5)
RestARea(aArea)

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} ConfigSED
Verifica se a configuração da natureza destino é similar a da de 
origem.

@param cNat = código da natureza de origem

@author rodrigo.oliveira
@since 03/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ConfigSED(cNat)

	Local aConfSED	:= {}
	Local nX		:= 0
	Local nPos		:= 0
	Local aAreaSED	:= GetArea()
	Local cFilOld	:= cFilAnt
	Local cCpo		:= ""
	Local lSEDDif	:= .F.
	Local cNatAux	:= cNat

	
	DbSelectArea("SED")
	DbSetOrder(1)
	DbSeek(xFilial("SED") + cNat)
	For nX := 1 To SED->(fCount())
		If "_REC" $ (cCpo := SED->(FieldName(nX))) .Or. "BASE" $ cCpo .Or. "CALC" $ cCpo .Or. "PER" $ cCpo
			AADD(aConfSED, { SED->(FieldName(nX)), SED->(FieldGet(nX)) } )
		EndIf
	Next
	
	cFilAnt := SE6->E6_FILDEB // Codigo da filial que recebera o titulo
	If DbSeek(xFilial("SED") + cNat)
		For nX := 1 to Len(aConfSED)
			nPos := SED->(FieldPos(aConfSED[nX][1])) 
			If nPos > 0
				If ValType(aConfSED[nX][2]) == "C"
					If Empty(SED->(FieldGet(nPos))) .And. aConfSED[nX][2] $ "S|1|"
						lSEDDif := .T.
					EndIf
					If Empty(aConfSED[nX][2]) .And. SED->(FieldGet(nPos)) $ "S|1|"
						lSEDDif := .T.
					EndIf
					If !Empty(SED->(FieldGet(nPos))) .And. !Empty(aConfSED[nX][2])
						If SED->(FieldGet(nPos)) != aConfSED[nX][2]
							lSEDDif := .T.
						EndIf
					EndIf
				Else
					If SED->(FieldGet(nPos)) != aConfSED[nX][2]
						lSEDDif := .T.
					EndIf
				EndIf
				If lSEDDif == .T.
					Exit
				EndIf
			EndIf
		Next
		If lSEDDif
			MsgInfo(STR0036, STR0035)
			If !MsgYesNo(STR0037, STR0035)
				DEFINE MSDIALOG oDlg FROM	22,9 TO 130,310 TITLE STR0038 PIXEL  // "Natureza filial de destino"

				@ 010, 050 MSGET cNatAux	F3 "SED" Valid Fa630Nat(cNatAux)      		SIZE 55, 11 OF oDlg PIXEL Hasbutton
				@ 010, 020 SAY STR0039	OF oDlg PIXEL //"Natureza"
				@ 004, 007 TO 036, 150 OF oDlg PIXEL
				
				DEFINE SBUTTON FROM 07, 120 TYPE 1 ACTION (nOpca:=1,cNat := cNatAux, oDlg:End()) ENABLE OF oDlg
	
				ACTIVATE MSDIALOG oDlg CENTERED
			EndIf
		EndIf
	EndIf
	
	cFilAnt := cFilOld
		
	RestArea(aAreaSED)

Return cNat

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa630Nat
Valida a natureza selecionada para a filial de destino 

@param cNatAux = código da natureza de destino - MSGET

@author rodrigo.oliveira
@since 03/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
FUNCTION Fa630Nat(cNatAux)   

	Local cAlias	 := Alias()
	Local lRet		 := .T.
	Local lValidBloq := SED->(FieldPos("ED_MSBLQL")) > 0
	
	Default	cNatAux	:= ""
	
	dbSelectArea("SED")
	IF !dbSeek(xFilial("SED")+cNatAux)
		HELP(" " , 1 , "REGNOIS")
		lRet:=.F.
	Endif                  
	
	If lRet .And. lValidBloq
		If SED->ED_MSBLQL == "1"
			Help(" ",1,"EDBLOCKED",,STR0040,1,0)	 //"Natureza bloqueada para novas movimentações"
			lRet := .F.
		Endif
	EndIf
	
	//294 - Natureza sintetica/Analitica
	If lRet .and. !FinVldNat( .F., cNatAux, 1 )
		lRet := .F.
	Endif
	
	dbSelectArea(cAlias)

Return lRet
