#INCLUDE "FINA631.CH"
#INCLUDE "PROTHEUS.CH"
                             
Static _lCpoEnt05 //Entidade 05
Static _lCpoEnt06 //Entidade 06
Static _lCpoEnt07 //Entidade 07
Static _lCpoEnt08 //Entidade 08
Static _lCpoEnt09 //Entidade 09
Static _cFilLog   //Filial a qual a tela foi aberta
Static __lFA631APV := ExistBlock( "FA631APV" )
Static __lMunic    := .F.
Static __lDedIns   := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fina631  ³ Autor ³ Claudio D. de Souza   ³ Data ³ 09/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetuar a transferencia/distribuição a partir das 		  ³±±
±±³          ³ solicitacoes incluidas									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fina631()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION Fina631(aAuto,nPosArotina)

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

Private aRotina 	:= MenuDef()
Private aRotAuto 	:= aAuto
Private cFilPad		:= "E6_TIPOSOL='P'"
Private lImp    	:= (SuperGetMv("MV_IMPTRAN",.F.,"1") == "2" )

PRIVATE cCadastro := STR0001//"Transferência/Distribuição de Crédito"

_cFilLog := cFilAnt

lMsErroAuto := .F. // variavel interna da rotina automatica	   	

Ctb161IniVar()

MV_PAR01 := 2
If lPanelFin
	PergInPanel("AFI631",.T.)
Else
   pergunte("AFI631",.T.)
Endif

DEFAULT nPosArotina := 0

If nPosArotina > 0 // Sera executada uma opcao diretamento de aRotina, sem passar pela mBrowse	
	dbSelectArea("SE6")
	bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
	lRet := Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina)
Else	
	If MV_PAR01 == 1 // Apenas solicitacoes em aberto
		dbSelectArea("SE6")
		DbSetOrder(2)
		MsSeek(xFilial("SE6")+"1") // Posiciona na primeira solicitacao em aberto
		// Browse com filtro
		mBrowse(6,1,22,75,"SE6",,,,,,Fa631Leg(),"IniFimTrans","IniFimTrans",,,,,,cFilPad)
	Else
		// Browse sem filtro
		mBrowse(6,1,22,75,"SE6",,,,,,Fa631Leg(),,,,,,,,cFilPad)
	Endif	
Endif	

dbSelectArea("SE6")
dbSetOrder(1) 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa631Apv ³ Autor ³ Claudio D. de Souza   ³ Data ³ 14/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Aprovar solicitacoes de transferencia de debito            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa631Apv(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa631Apv(cAlias,nReg,nOpc)

Local lPanelFin := IsPanelFin()
Local nOpcA                                                                
Local aTit := {}
Local nX
Local nSaldo
Local aAcho := {}
Local cFilSe2 	:= xFilial("SE2")
Local cFilBkpSE2:= xFilial("SE2") 
Local cFilOld 	:= cFilAnt // Guarda filial atual
Local cEmpOld	:= cEmpAnt		
Local cChave
Local aRecno := {}
Local nY := 0
Local cParcela	:= Space(TamSx3("E2_PARCELA")[1])
Local lSolicAb	:= (mv_par01==1)	// Apenas solicitacoes em aberto
Local lDtMovFin := .T.
Local lRet		:= .F.
Local cTipo 	:= ""
Local nValBx	:= 0
Local cParcRec	:= Space(TamSx3("E2_PARCELA")[1])
Local aBkpSM0	:= {}
Local lTrocaParc := .F.
Local cParcAux   := cParcela

Private lF631Auto := aRotAuto <> nil

if lF631Auto
	DbSelectArea("SE6")
	DbSetorder(3)
	If (nT := ascan(aRotAuto,{|x| x[1]='E6_NUMSOL'}) ) > 0
		DbSeek(xFilial("SE6")+ Padr(aRotAuto[nT,2],TamSx3('E6_NUMSOL')[1 ]) )
	EndIf
Endif

// Apenas solicitacoes em aberto podem ser aprovadas.
If SE6->E6_SITSOL != "1"
	Help( ,, 'HELP',, STR0003 , 1, 0) 
	Return .F.
Endif

// Nao é permitido aprovar transferencias de titulos solicitados para outra filial.
If _cFilLog <> SE6->E6_FILDEB
	Help( ,,"FIL_TRFA",, STR0004 + CRLF + STR0005 + SE6->E6_FILDEB + CRLF + STR0006 + _cFilLog, 1 , 0,,,,,, {STR0007} )
	Return .F.
Endif

If __lFA631APV
	lDtMovFin := Execblock( "FA631APV", .f., .f. )
    If !lDtMovFin
		Return .F.
    EndIf
EndIf

aAcho := F631Campos(.T.)

If lPanelFin
	RegToMemory(cAlias,.T.,,,FunName())                                       
	oPanelDados := FinWindow:GetVisPanel()
	oPanelDados:FreeChildren()		
	aDim := DLGinPANEL(oPanelDados)		
	nOpca := AxVisual(cAlias,nReg,nOpc,aAcho,,,,,,,.T.,,.T.,.T.,aDim)
Else
	If !lF631Auto
		nOpca := AxVisual(cAlias,nReg,nOpc,aAcho,,,,,,,,,.T.)
	Else
		If ascan(aRotAuto,{|x| x[1]='E6_NUMSOL'})>0 .and. SE6->(DbSeek(xFilial("SE6")+ Padr(aRotAuto[nT,2],TamSx3('E6_NUMSOL')[1]) ))		
			RegToMemory(cAlias,.T.)
			nOpca := 1
		EndIf
	EndIf
Endif	

If nOpcA == 1
	// Filial a ser utilizada para localizar o titulo, FILIAL ORIGEM do SE6 caso o SE2
	// seja exclusivo ou xFilial se o SE2 for compartilhado
	cFilSe2 := If(!Empty(cFilSe2),xFilial("SE2",SE6->E6_FILORIG),cFilSe2)
	cChave := cFilSe2 + SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO)
	SE2->(MsSeek(cChave))
	While SE2->(!Eof()) .And. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO) == cChave
		If SE2->E2_NUMSOL <> SE6->E6_NUMSOL	
			SE2->(DbSkip())
			Loop
		Else
			Exit
		EndIf
	EndDo
			
	nRecNoSe2 := SE2->(Recno())
	lMsErroAuto := .F. // variavel interna da rotina automatica	   	

	If SE2->(!Eof())
		BEGIN TRANSACTION
			If RecLock("SE6",.F.)
				
				If SE2->E2_VRETISS > 0 .and. lImp
					//Verifica se as filiais estão localizadas no mesmo municipio
					__lMunic := FMunicFil()
				EndiF	

				SE6->E6_SITSOL := "2" // Solicitacao aprovada
				SE6->E6_USRAPV := RetCodUsr() //Aprovador
				SE6->(MsUnlock())
			   
				// Baixa o titulo na filial de origem
				aTit := {}
				nAbatim := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA, cFilSe2)
				nSaldo := (SE2->E2_SALDO - nAbatim)
				nSaldo += SE2->E2_SDACRES
				nSaldo -= SE2->E2_SDDECRE
				SE2->(MsGoTo(nRecNoSe2))
				// Primeiro adiciona os registros a serem transferidos, pois os primeiro
				// deve-se transferir o titulo principal, depois os agragados. Como os agragados podem
				// vir primeiro, entao utiliza-se uma matriz de recnos para transferir os titulos na ordem
				// em que foram incluidos, pois um abatimento nunca eh incluido primeiro que um titulo
				// principal
				// Os titulos de impostos nao se incluem nesta lista visto que os mesmos serao incluidos junto com
				// o titulo principal
				While SE2->(!Eof()) .And. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO) == cChave
					If SE2->E2_NUMSOL <> SE6->E6_NUMSOL	
						SE2->(DbSkip())
						Loop
					EndIf

				  	If !(SE2->E2_TIPO $ MVABATIM) .OR. ;
				  		((SE2->E2_TIPO $ MVABATIM) .AND. !(SE2->E2_TIPO $ MVIRABT+"/"+MVINABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVISABT+"/"+MVFUABT+"/"+MVI2ABT))
						Aadd(aRecno, SE2->(Recno()))
					Endif

					SE2->(DbSkip())
				Enddo	
				aSort(aRecno)

				//Zera valor da baixa
				nValBx := 0

				// Transfere todos os titulos agregados
				nY := 1
				
				While !lMsErroAuto .And. nY <= Len(aRecno)
					SE2->(MsGoto(aRecno[nY]))

					aTit       := {}
					lTrocaParc := .F.
					cParcela   := cParcAux

					For nX := 1 To SE2->(fCount())
						If !Empty(SE2->(FieldGet(nX))) .Or. SE2->(FieldName(nX)) == "E2_PARCELA"//A parcela faz parte da chave e precisa estar presente para que seja incrementada no caso de título já existente no destino
							aAdd(aTit, { SE2->(FieldName(nX)), SE2->(FieldGet(nX)), NIL } )
						EndIf
					Next nX

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_FILIAL"})
					If nX > 0
						aTit[nX][2] := SE6->E6_FILDEB // Codigo da filial que recebera o titulo
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_TIPO"})
					If nX > 0
						cTipo := aTit[nX][2]  //Tipo do titulo que sera incluido para verificar a parcela
					Endif 				

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_ORIGEM"})
					If nX > 0
						aTit[nX][2] := "FINA631"
					Endif
					
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_FORNECE"})
					If nX > 0
						aTit[nX][2] := SE6->E6_CLIENTE // Codigo do cliente que recebera o titulo
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_LOJA"})
					If nX > 0
						aTit[nX][2] := SE6->E6_LOJA // Codigo da loja do cliente que recebera o titulo
					Endif

					__lDedIns := F631DedIns(SE2->E2_NATUREZ)

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_CODRET"})
					If nX > 0
						aTit[nX][2] := SE2->E2_CODRET
					Endif

					If lImp
						F631RecVl(@aTit)		
					Endif	

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_PARCIR"})
					If nX > 0
						aTit[nX][2] := ''
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_PARCINS"})
					If nX > 0
						aTit[nX][2] := ''
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_PARCCOF"})
					If nX > 0
						aTit[nX][2] := ''
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_PARCPIS"})
					If nX > 0
						aTit[nX][2] := ''
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_PARCSLL"})
					If nX > 0
						aTit[nX][2] := ''
					Endif
					
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_MDRTISS"})
					If nX > 0
						IF Empty(aTit[nX][2])
							aTit[nX][2] := '1'
						EndIf
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_TEMDOCS"})
					If nX > 0
						If(Empty(aTit[nX][2]),aTit[nX][2] := "2",aTit[nX][2]) // Forca o dirf se estiver em branco
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_DIRF"})
					If nX > 0
						If(Empty(aTit[nX][2]),aTit[nX][2] := "2",aTit[nX][2]) // Forca o dirf se estiver em branco
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_DESDOBR"})
					If nX > 0
						aTit[nX][2] := "N" // Forca o desdobramento como nao
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_NUMSOL"})
					If nX > 0
						aTit[nX][2] := "" // Limpa numero da solicitacao na filial destino (debito)
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_VALOR"})
					If cTipo == SE6->E6_TIPO
						If nX > 0
							nValBx += aTit[nX][2]
						Endif
					EndIf

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_DECRESC"})
					If nX > 0
						nValBx -= aTit[nX][2]
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_ACRESC"})
					If nX > 0
						nValBx += aTit[nX][2]
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_MULTNAT"})
					If nX > 0 
						aTit[nX][2] := "2"
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_RATEIO"})
					If nX > 0 
						aTit[nX][2] := "N"
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_ARQRAT"})
					If nX > 0
						aTit[nX][2] := ""						
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_MODSPB"})
					If nX > 0
						If(Empty(aTit[nX][2]),aTit[nX][2]:="1",.T.)						
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_APLVLMN"})
					If nX > 0
						If(Empty(aTit[nX][2]),aTit[nX][2]:="1",.T.)
					Endif
					
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_PARCELA"})
					If nX > 0
						// Incrementa a parcela para que nao haja registro duplicado na filial Debito
						lTrocaParc := .T.
						If cTipo $ MVABATIM
							aTit[nX][2] := cParcela
						Else
							aTit[nX][2] := SE6->E6_PARCELA
							cFilSe2 := If(!Empty(cFilSe2),xFilial("SE2",SE6->E6_FILDEB),cFilSe2)
							cChave := cFilSe2 + SE6->(E6_PREFIXO+E6_NUM+aTit[nX][2]+cTipo)
							While SE2->(MsSeek(cChave))
								aTit[nX][2] := Soma1(aTit[nX][2])
								cChave := cFilSe2 + SE6->(E6_PREFIXO+E6_NUM+aTit[nX][2]+cTipo)
							Enddo
							cParcela := aTit[nX][2]  //Parcela do titulo Principal
						Endif
					Endif
   					SE2->(MsGoto(aRecno[nY]))//ponteiro pode ter sido desposicionado ao buscar pelas parcelas do Titulo	

					cFilBkpSE2 := SE6->E6_FILORIG
					aTitBx := {}
					// Altera para filial do titulo de origem para fazer a baixa
 					
					aBkpSM0 := SM0->(GetArea())
					cFilAnt := cFilBkpSE2
					cFilSe2 := If(!Empty(cFilSE2),xFilial("SE2",SE6->E6_FILORIG),cFilSE2)

					If !Empty( cFilAnt )
 						SM0->(DbSetOrder(1))
						SM0->(DbSeek(cEmpAnt+cFilAnt))
					Else
 						SM0->(DbSetOrder(1))
						SM0->(DbSeek(cEmpAnt+SE6->E6_FILORIG))
					EndIf

					AADD(aTitBx , {"E2_PREFIXO"	, SE6->E6_PREFIXO	, NIL})
					AADD(aTitBx , {"E2_NUM"		, SE6->E6_NUM		, NIL})
					AADD(aTitBx , {"E2_PARCELA"	, SE6->E6_PARCELA	, NIL})
					AADD(aTitBx , {"E2_TIPO"	, SE6->E6_TIPO		, NIL})
					AADD(aTitBx , {"E2_FORNECE"	, SE2->E2_FORNECE	, NIL})
					AADD(aTitBx , {"E2_LOJA"	, SE2->E2_LOJA		, NIL})
					AADD(aTitBx , {"AUTMOTBX"	, "TRF"				, NIL})
					AADD(aTitBx , {"AUTDTBAIXA"	, dDataBase			, NIL})
					AADD(aTitBx , {"AUTHIST"	, STR0018 + SE6->E6_FILORIG + STR0026 + SE6->E6_FILDEB,NIL}) //"Bx. transf. da "###" p/ " 

					//Verificar titulos de impostos já gerados na filial de origem
					If lImp
						F631Impos()	
					EndIf

					//Executa a Baixa do Titulo                                  
					MSExecAuto({|x, y| FINA080(x, y)}, aTitBx, 3)

					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
						Break
					Else
						//Transfere SK1 tambem.
						If SK1->(MsSeek(xFilial("SK1")+SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO)))
							RecLock("SK1")
							SK1->K1_FILIAL		:= SE6->E6_FILDEB
							SK1->K1_CLIENTE	:= SE6->E6_CLIENTE
							SK1->K1_LOJA		:= SE6->E6_LOJA
							MsUnlock()
						Endif

						cFilAnt := cFilOld //Restaura filial atual	
						cEmpAnt	:= cEmpOld
						
						If Len(aBkpSM0) > 0
							RestArea(aBkpSM0)
						EndIf
						lRet	:= .T.
					Endif
				
   					SE2->(MsGoto(aRecno[nY]))//ponteiro pode ter sido desposicionado ao buscar pelas parcelas do Titulo	
					
					//Altera a FILORIG para a filial de destino
					cFilAnt := SE6->E6_FILDEB
					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_FILORIG"})
					If nX > 0
						aTit[nX][2] := cFilAnt // Codigo da filial que recebera o titulo
					Endif

					nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_NATUREZ"})
					If nX > 0
						If !lImp //MV_IMPTRAN = 1
							If !(AllTrim(cTipo) $ MVTAXA+"/"+MVINSS+"/"+MVISS+"/"+MVTXA+"/"+"SES"+"/"+"INA")
								F631SemImp(@aTit) 
								aTit[nX][2] := fNatTrf(SE6->E6_FILDEB)
								If Empty(aTit[nX][2])
									aTit[nX][2] := fNatNTrf(cFilAnt, aTit)
								Endif	
							Else
								aTit[nX][2] := SE2->E2_NATUREZ
							EndIf
						Else //MV_IMPTRAN = 2
							If !Empty(FWFilial("SED"))
								aTit[nX][2] := fNatNTrf(cFilAnt, aTit) 
							Else
								aTit[nX][2] := SE2->E2_NATUREZ
							Endif
						Endif
					Endif		
					
					//Grava titulo na filial de debito destino
					MSExecAuto({|x, y, z| FINA050(x, y, z)}, aTit, 3, 3)
					
					cFilAnt := cFilOld	// Restaura filial atual

					SE2->(MsGoto(aRecno[nY]))

					If lTrocaParc
						cParcRec := cParcela
					Else
						cParcRec := SE6->E6_PARCELA
					EndIf
	
					nY ++
				End	
				
				If lMsErroAuto
					if !IsBlind()
						MostraErro()
					EndIf
					DisarmTransaction()
					Break
				Else	
					SE6->(RecLock("SE6"))
					SE6->E6_PARCDES := cParcRec						
					SE6->(MSUnlock())
				Endif	
			Endif
		END TRANSACTION	
	Endif	
Endif

__lMunic := .F.
cFilAnt	 := cFilOld	// Restaura filial atual
cEmpAnt	 := cEmpOld
If Len(aBkpSM0) > 0
	RestArea(aBkpSM0)
EndIf

If lSolicAb // Apenas solicitacoes em aberto
	SE6->(DbSetOrder(2))
	SE6->(MsSeek(xFilial("SE6")+"1")) // Posiciona na primeira solicitacao em aberto
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa631Rej ³ Autor ³ Claudio D. de Souza   ³ Data ³ 26/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rejeitar solicitacoes de transferencia de debito           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa631Rej(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa631Rej(cAlias,nReg,nOpc)
Local nOpcA
Local aAcho := {}
Local aArea := GetArea()
Local cFilSE2 := xFilial("SE2")
Local lDtMovFin := .T.
PRIVATE aMemos // Campos memos virtuais, utilizada na AxAltera.

// Apenas solicitacoes em aberto podem ser rejeitadas.
If SE6->E6_SITSOL != "1"
	Help(,,"HELP",,STR0019,1,0) // Apenas solicitacoes em aberto podem ser rejeitadas.
	Return
Endif

// Nao eh permitido rejeitar transferencias de titulos solicitados para outra filial.
If _cFilLog <> SE6->E6_FILDEB
	Help( ,,"FIL_TRFR",, STR0004 + CRLF + STR0005 + SE6->E6_FILDEB + CRLF + STR0006 + _cFilLog, 1 , 0,,,,,, {STR0007} )
	Return .F.
Endif

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Ponto de Entrada ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If ExistBlock( "FA631REJ" )

    lDtMovFin := Execblock( "FA631REJ", .f., .f. )

    If !lDtMovFin
       Return
    EndIf

 EndIf

aAcho := F631Campos()

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
	BEGIN TRANSACTION
		If RecLock("SE6",.F.)
			SE6->E6_SITSOL := "3" // Solicitacao rejeitada
			SE6->E6_USRAPV :=	RetCodUsr() // Rejeitado por
			// Filial a ser utilizada para localizar o titulo, FILIAL ORIGEM do SE6 caso o SE2
			// seja exclusivo ou xFilial se o SE2 for compartilhado
			cFilSe2 := If(!Empty(cFilSe2),xFilial("SE2",SE6->E6_FILORIG),cFilSe2) 
			aGetRec := SE2->(getArea())
			cQuery:= " SELECT R_E_C_N_O_ FROM "+RetSqlName("SE2")+" SE2 " 
			cQuery+= " WHERE D_E_L_E_T_ = ' ' AND E2_FILIAL = '"+cFilSE2+"' "
			cQuery+= " AND E2_PREFIXO ='"+SE6->E6_PREFIXO+"' AND E2_NUM='"+SE6->E6_NUM+"' AND "
			cQuery+= " E2_NUMSOL='"+SE6->E6_NUMSOL+"'"
			
			If Select("TSQL") > 0
				dbSelectArea("TSQL")
				DbCloseArea()
			EndIf
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSQL",.F.,.T.)
			dbSelectArea("SE2")			
			dbSelectArea("TSQL")
			dbGotop()
			Do While TSQL->(!Eof())
				TCSetField("TSQL", "R_E_C_N_O_" ,"N",14,0)
				SE2->(DbGoTo(TSQL->R_E_C_N_O_))
				Reclock("SE2", .F.)
				SE2->E2_NUMSOL		:= ""
				SE2->(MsUnlock())
				TSQL->(dbSkip())
			Enddo				
			SE6->(MsUnlock())
			If Select("TSQL") > 0
				dbSelectArea("TSQL")
				DbCloseArea()
			EndIf
			RestArea(aGetRec)
		Endif
	END TRANSACTION	
Endif
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa631Exc ³ Autor ³ Claudio D. de Souza   ³ Data ³ 27/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Excluir solicitacoes de transferencia de debito em aberto  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa631Exc(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa631Exc(cAlias,nReg,nOpc)
Local lPanelFin := IsPanelFin()
Local aAcho := {}
Local cFilSE2 := xFilial("SE2")
Local cFilSe5 := xFilial("SE5")
Local cFilBkpSE2:= xFilial("SE2")
Local cFilBkpSE5:= xFilial("SE5")
Local nX := 0
Local lRet := .T.
Local cFilAtu := cFilAnt
Local lBaixaTRF := .F.
Local nOpca := 0              
Local nCampos := (cAlias)->(FCount())
Local aTitBxI := {}

PRIVATE aMemos // Campos memos virtuais, utilizada na AxDeleta para excluir campos
					// memo.
Private lF631Auto := aRotAuto<>nil

if lF631Auto

	DbSelectArea("SE6")
	DbSetorder(3)
	If (nT := ascan(aRotAuto,{|x| x[1]='E6_NUMSOL'}) ) > 0
		If !DbSeek(xFilial("SE6")+ Padr(aRotAuto[nT,2],TamSx3('E6_NUMSOL')[1 ]) )
			lRet := .F.
		EndIf
	EndIf

Endif

aAcho := F631Campos()

lMsErroAuto := .F. // variavel interna da rotina automatica	   	

// Apenas solicitacoes em aberto podem ser excluidas.
If lRet .and. (nOpc == 5 .and. SE6->E6_SITSOL != "1") 
	Help("",1,"Fa631Exc",,STR0009,1,0)
   lRet := .F.
ElseIf lRet .and. (nOpc == 6 .and. SE6->E6_SITSOL != "2") 
	Help("",1,"Fa631Exc",,STR0010,1,0)
   lRet := .F.
Endif

//Ponto de entrada para permitir ou nao que determinado usuario efetue esta operacao (estorno)
If lRet .and. nOpc == 6 .and. ExistBlock("FA631EST")
	lRet := ExecBlock("FA631EST",.F.,.F.)
Endif

If lRet
	aMemos := {	{"E6_CDHSOL","E6_HISTSOL"},;
					{"E6_CDHREJ","E6_HISREJ"}}
	
	If lF631Auto
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
		bCampo := {|nCPO| (cAlias)->(Field(nCPO)) }
		FOR nX := 1 TO nCampos
			M->&(EVAL(bCampo,nX)) := (cAlias)->(FieldGet(nX))
		NEXT i
		
		nOpcx := 0
		nOpcx := AxVisual( cAlias, (cAlias)->( Recno() ), 2)
		
		If nOpcx == 1 //Confirmou operacao
			nOpca := 2
		Else	
			nOpca := 1
		Endif
	Endif
	
	If nOpca == 2
		BEGIN TRANSACTION

		If nOpc == 5 //Exclusao 
			SE2->(DbSetOrder(1))
		  	// Filial a ser utilizada para localizar o titulo, FILIAL ORIGEM do SE6 caso o SE2
			// seja exclusivo ou xFilial se o SE2 for compartilhado
			cFilSe2 := If(!Empty(cFilSE2),xFilial("SE2",SE6->E6_FILORIG),cFilSE2)
			aGetRec := getArea()
			cQuery:= " SELECT R_E_C_N_O_ FROM "+RetSqlName("SE2")+" SE2 " 
			cQuery+= " WHERE D_E_L_E_T_ = ' ' AND E2_FILIAL = '"+cFilSE2+"' "
			cQuery+= " AND E2_PREFIXO ='"+SE6->E6_PREFIXO+"' AND E2_NUM='"+SE6->E6_NUM+"' AND "
			cQuery+= " E2_NUMSOL='"+SE6->E6_NUMSOL+"'"
			
			If Select("TSQL") > 0
				dbSelectArea("TSQL")
				DbCloseArea()
			EndIf
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSQL",.F.,.T.)
			dbSelectArea("SE2")			
			dbSelectArea("TSQL")
			dbGotop()
			Do While TSQL->(!Eof())
				TCSetField("TSQL", "R_E_C_N_O_" ,"N",14,0)
				SE2->(DbGoTo(TSQL->R_E_C_N_O_))
				RecLock("SE2",.F.)
				SE2->E2_NUMSOL := " " // Limpa o numero para que ele seja possivel nova solicitacao de transferencia
				SE2->(MsUnlock())
				
				TSQL->(dbSkip())
			Enddo
			If lF631Auto
				RecLock("SE6",.F.)
				SE6->(DbDelete())
				SE6->(MsUnlock())
			EndIF
			If Select("TSQL") > 0
				dbSelectArea("TSQL")
				DbCloseArea()
			EndIf
			RestArea(aGetRec)

		ElseIf RecLock("SE6",.F.) //Estorno

			SE2->(DbSetOrder(1))
		  	// Filial a ser utilizada para localizar o titulo, FILIAL ORIGEM do SE6 caso o SE2
			// seja exclusivo ou xFilial se o SE2 for compartilhado
			cQuery := "SELECT COUNT(E6_NUMSOL) CAPROV FROM " + RetSqlName( "SE6" ) + " "
			cQuery += "WHERE D_E_L_E_T_ = ' ' AND E6_SITSOL = '2' "
			cQuery += "AND E6_NUMSOL='" + SE6->E6_NUMSOL + "' "
		
			cQuery := ChangeQuery( cQuery ) 
			dbUseArea( .t., "TOPCONN", Tcgenqry( , , cQuery ), "TMPSE6", .F., .T. )
			TMPSE6->(dbGoTop())
			If TMPSE6->CAPROV == 1
				cFilSe2 := If(!Empty(cFilSE2), xFilial("SE2",SE6->E6_FILORIG),cFilSE2)
				SE2->(MsSeek(cFilSE2+SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO)))
				While SE2->(!Eof()) .And. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO) == (cFilSE2+SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO))
					If SE2->E2_NUMSOL <> SE6->E6_NUMSOL	
						SE2->(DbSkip())
						Loop
					Else
						RecLock("SE2",.F.)
						SE2->E2_NUMSOL := " " // Limpa o numero para que ele seja possivel nova solicitacao de transferencia
						SE2->(MsUnlock())
						Exit
					EndIf
				EndDo
			EndIf
			dbSelectArea("TMPSE6")
			dbCloseArea()
			//Cancela a baixa por TRF na filial origem

			SE5->(dbSelectArea("SE5"))
			SE5->(dbSetOrder(7)) //		E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA
			cFilSe5 := If(!Empty(cFilSE5),xFilial("SE5",SE6->E6_FILORIG),cFilSE5)
			cFilBkpSE5:= SE6->E6_FILORIG 
			cFilAtu := cFilAnt
			cFilAnt := cFilBkpSE5

			lBaixaTRF := .F.
			
			If SE5->(MsSeek(cFilSe5+SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO)))
				cKeySe5 := SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)
				While SE5->(!EOF()) .AND. cKeySe5 == SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)
					If SE5->(E5_CLIFOR+E5_LOJA) == SE2->(E2_FORNECE+E2_LOJA)
						If SE5->E5_MOTBX == "TRF" .AND. SE5->E5_SITUACA != 'C'
							lBaixaTRF := .T.
							Exit
			            Endif
			    	EndIf
	     			SE5->(dbSkip())
	     		Enddo

				If lBaixaTRF
					//Cancelo Baixa Titulos a Receber
					cFilAnt := SE6->E6_FILORIG
					If lImp
						cFilSe2 := If(!Empty(cFilSE2),xFilial("SE2",SE6->E6_FILORIG),cFilSE2)
						aGetImp := SE2->(GetArea())
						cQuery := " SELECT E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_VALOR "
						cQuery += " FROM "+RetSqlName("SE2")+" SE2 "
						cQuery += " WHERE E2_TITPAI = '"+SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO)+SE2->(E2_FORNECE+E2_LOJA)+"' "
						cQuery += " AND E2_FILIAL = '"+cFilSE2+"' AND D_E_L_E_T_ = ' ' AND E2_SALDO = 0"
					
						If Select("TSQL") > 0
							dbSelectArea("TSQL")
							DbCloseArea()
						EndIf
						
						dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSQL",.F.,.T.)
						
						dbSelectArea("TSQL")
						dbGotop()
						Do While TSQL->(!Eof())
							aTitBxI := {}		
							AADD(aTitBxI , {"E2_PREFIXO"	, TSQL->E2_PREFIXO, NIL})
							AADD(aTitBxI , {"E2_NUM"			, TSQL->E2_NUM	, NIL})
							AADD(aTitBxI , {"E2_PARCELA"	, TSQL->E2_PARCELA, NIL})
							AADD(aTitBxI , {"E2_TIPO"		, TSQL->E2_TIPO	, NIL})
							AADD(aTitBxI , {"E2_FORNECE"	, TSQL->E2_FORNECE, NIL})
							AADD(aTitBxI , {"E2_LOJA"		, TSQL->E2_LOJA	, NIL})
							
							MSExecAuto({|x, y| FINA080(x, y)}, aTitBxI, 5)
							If lMsErroAuto
								MostraErro()
								DisarmTransaction()
								Break
							EndIf
							TSQL->(dbSkip())			
						EndDo
						dbSelectArea("TSQL")
						DbCloseArea()	
						RestArea(aGetImp)	
					EndIf
					
					_aTit := {}
					AADD(_aTit , {"E2_PREFIXO"	,SE6->E6_PREFIXO	,NIL})
					AADD(_aTit , {"E2_NUM"		,SE6->E6_NUM		,NIL})
					AADD(_aTit , {"E2_PARCELA"	,SE6->E6_PARCELA	,NIL})
					AADD(_aTit , {"E2_TIPO"  	,SE6->E6_TIPO		,NIL})
					AADD(_aTit , {"E2_FORNECE"	,SE2->E2_FORNECE	,NIL})
					AADD(_aTit , {"E2_LOJA"  	,SE2->E2_LOJA		,NIL})
	
					MSExecAuto({|x, y| FINA080(x, y)}, _aTit, 5)
					cFilAnt := cFilBkpSe5

					If  lMsErroAuto
						lRet	:= .F.
						If !IsBlind()
							MOSTRAERRO() // Sempre que o micro comeca a apitar esta ocorrendo um erro desta forma
						EndIf
						DisarmTransaction()
						Break
					Else
	
						// Exclui o registro gerado pela transferencia original na filial destino (debito)
						cFilSe2 := If(!Empty(cFilSE2),xFilial("SE2",SE6->E6_FILDEB),cFilSE2)
						cFilBkpSE2:= SE6->E6_FILDEB
						cFilAnt := cFilBkpSE2
						
						SE2->(DbSetOrder(1))
						If SE2->(MsSeek(cFilSE2+SE6->(E6_PREFIXO+E6_NUM+E6_PARCDES+E6_TIPO)))
							_aTit := {}
							AADD(_aTit , {"E2_PREFIXO"	,SE6->E6_PREFIXO	,NIL})
							AADD(_aTit , {"E2_NUM"		,SE6->E6_NUM		,NIL})
							AADD(_aTit , {"E2_PARCELA"	,SE6->E6_PARCDES	,NIL})
							AADD(_aTit , {"E2_TIPO"  	,SE6->E6_TIPO		,NIL})
							AADD(_aTit , {"E2_FORNECE"	,SE6->E6_CLIENTE	,NIL})
							AADD(_aTit , {"E2_LOJA"  	,SE6->E6_LOJA		,NIL})
							
							cFilAnt := SE6->E6_FILDEB
							MSExecAuto({|x, y, z| FINA050(x, y, z)}, _aTit, 5, 5)
							cFilAnt := cFilBkpSE2

							If  lMsErroAuto
								lRet := .F.
								If !IsBlind()
									MOSTRAERRO() // Sempre que o micro comeca a apitar esta ocorrendo um erro desta forma
								EndIf
								DisarmTransaction()
								Break
							Else
								Reclock("SE6",.f.)
								SE6->E6_SITSOL := "4" // Solicitacao estornada
								SE6->E6_USRAPV :=	RetCodUsr() // Rejeitado por
								SE6->(MSUNLOCK())
							EndiF
					   Endif
					Endif
				Endif					
			Endif

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
±±³Fun‡„o    ³ Fa631Pes ³ Autor ³ Claudio D. de Souza   ³ Data ³ 27/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa com filtro                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa631Pes( )                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA631 / TMS                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa631Pes
Local nRecNo := RecNo()
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
±±³Fun‡…o    ³Fa631Leg    ³ Autor ³ Claudio D. de Souza ³ Data ³ 27.03.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse ou retorna a ³±±
±±³          ³ para o BROWSE                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA631                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa631Leg(nReg)

Local aLegenda := { 	{"BR_VERDE", STR0013 },;  //"Solicitação em aberto"
							{"BR_AZUL",STR0014 },;  //"Solicitação aprovada"
							{"BR_VERMELHO", STR0015 },; //"Solicitação rejeitada"
							{"BR_PRETO", STR0016 } } //"Transferência estornada"
Local uRetorno := .T.

If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, { "E6_SITSOL == '1'"	, aLegenda[1][1] } )
	Aadd(uRetorno, { "E6_SITSOL == '2'"	, aLegenda[2][1] } )
	Aadd(uRetorno, { "E6_SITSOL == '3'"	, aLegenda[3][1] } )
	Aadd(uRetorno, { "E6_SITSOL == '4'"	, aLegenda[4][1] } )	
Else
	BrwLegenda(cCadastro, STR0017 ,aLegenda) // "Legenda"
Endif

Return uRetorno


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
Local aRotina	:=	{{STR0020	,"Fa631Pes", 0 , 1,,.F.},; //"Pesquisar"
                   	 {STR0021	,"AxVisual", 0 , 2},;      //"Visualizar"
                   	 {STR0022	,"Fa631Apv", 0 , 4},;      //"Aprovar"
                   	 {STR0023	,"Fa631Rej", 0 , 4},;  	   //"Rejeitar"
					 {STR0024	,"Fa631Exc", 0 , 5},;      //"Excluir"
					 {STR0025	,"Fa631Exc", 0 , 6},;      //"Estornar"
					 {STR0017	,"Fa631Leg", 0 , 5, ,.F.}} //"Legenda"
Return(aRotina)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinA631T   ³ Autor ³ Marcelo Celi Marques ³ Data ³ 04.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada semi-automatica utilizado pelo gestor financeiro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA631                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FinA631T(aParam)
	cRotinaExec := "FINA631"
	ReCreateBrow("SE6",FinWindow)      		
	FinA631(aParam[1])         
	ReCreateBrow("SE6",FinWindow)      	

	dbSelectArea("SE6")
	
	INCLUI := .F.
	ALTERA := .F.
	
Return .T.
                                                               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb161IniVar  ºAutor  ³Microsiga       º Data ³  18/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Analise da existência dos campos das novas entidades       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb161IniVar()

Local aSaveArea := GetArea()

dbSelectArea("SE2")

If _lCpoEnt05 == Nil
	_lCpoEnt05 := SE2->(FieldPos("E2_EC05DB")>0 .And. FieldPos("E2_EC05CR")>0)
EndIf
     
If _lCpoEnt06 == Nil
	_lCpoEnt06 := SE2->(FieldPos("E2_EC06DB")>0 .And. FieldPos("E2_EC06CR")>0)
EndIf

If _lCpoEnt07 == Nil
	_lCpoEnt07 := SE2->(FieldPos("E2_EC07DB")>0 .And. FieldPos("E2_EC07CR")>0)
EndIf

If _lCpoEnt08 == Nil
	_lCpoEnt08 := SE2->(FieldPos("E2_EC08DB")>0 .And. FieldPos("E2_EC08CR")>0)
EndIf

If _lCpoEnt09 == Nil
	_lCpoEnt09 := SE2->(FieldPos("E2_EC09DB")>0 .And. FieldPos("E2_EC09CR")>0)
EndIf

RestArea(aSaveArea)

Return

/*/ {Protheus.doc} fNatTrf
Compatibilizacao dos parametros MV_NATTRFF
            
@author Andre Lago
@version P11
@since 14/11/2012
@return Nil
@obs.
@sample 
/*/
Static Function fNatTrf(cFilTransf)

Local aArea     := GetArea()
Local cVar		  := ""

Default cFilTransf := cFilAnt

dbSelectArea("SED")
cVar := Alltrim(GetMV("MV_NATTRFF"))

If !Empty(Alltrim(cVar))
	cVar := cVar + Space(Len(SED->ED_CODIGO)-Len(cVar))
	If !(DbSeek(xFilial("SED",cFilTransf)+cVar))
		RecLock("SED",.T.)
		SED->ED_FILIAL  := xFilial( "SED" , cFilTransf )
		SED->ED_CODIGO  := cVar
		SED->ED_CALCIRF := "N"
		SED->ED_CALCISS := "N"
		SED->ED_CALCINS := "N"
		SED->ED_CALCCSL := "N"
		SED->ED_CALCCOF := "N"
		SED->ED_CALCPIS := "N"
		SED->ED_DESCRIC := "TITULOS TRANSFERIDOS"
		Msunlock()
		FKCommit()
	EndIf
Endif

RestArea(aArea)

Return(cVar)

/*/ {Protheus.doc} fNatNTrf
Informar natureza no momento da transferencia entre filiais.
            
@author Caique
@version P11
@since 12/01/2015
@return Nil
@obs.
@sample 
/*/

Static Function fNatNTrf(cFilTransf,aTit)

Local aArea     := GetArea()
Local cNewNatTr := ""
Local nVar		:= ""
Local oDlg		:= NIL

Default cFilTransf := cFilAnt
Default aTit := {}

DbSelectArea("SED")

Private cCodNat := SPACE(LEN(SED->ED_CODIGO))
Private cNomNat:= SPACE(LEN(SED->ED_DESCRIC))
Private cObserv := "--------------------------------------"+CRLF

cObserv += "------> Impostos do Título <------"+CRLF
cObserv += "--------------------------------------"+CRLF

If lImp
	If (nVar := SE2->E2_IRRF ) > 0 
		cObserv += "IRRF =    "+ TransForm(nVar,PesqPict('SE2',"E2_VALOR"))+CRLF
	EndIf
	If (nVar := SE2->E2_COFINS) > 0 
		cObserv += "COFINS = "+ TransForm(nVar,PesqPict('SE2',"E2_VALOR"))+CRLF
	EndIf
	If (nVar := SE2->E2_CSLL) > 0 
		cObserv += "CSLL =    "+ TransForm(nVar,PesqPict('SE2',"E2_VALOR"))+CRLF
	EndIF
	If (nVar := SE2->E2_PIS ) > 0 
		cObserv += "PIS =    "+ TransForm(nVar,PesqPict('SE2',"E2_VALOR"))+CRLF
	EndIf
	If __lMunic
		If (nVar := SE2->(E2_ISS) ) > 0 
			cObserv += "ISS =    "+ TransForm(nVar,PesqPict('SE2',"E2_VALOR"))+CRLF
		EndIf
		If (nVar := SE2->(E2_PRISS) ) > 0 
			cObserv += "ISS PROV. =    "+ TransForm(nVar,PesqPict('SE2',"E2_VALOR"))+CRLF
		EndIf
	Endif	
	If (nVar := SE2->(E2_INSS) ) > 0 
		cObserv += "INSS =    "+ TransForm(nVar,PesqPict('SE2',"E2_VALOR"))+CRLF
	EndIf
	If (nVar := SE2->(E2_PRINSS) ) > 0 
		cObserv += "INSS PROV. =    "+ TransForm(nVar,PesqPict('SE2',"E2_VALOR"))+CRLF
	EndIf
Endif

DEFINE MSDIALOG oDlg TITLE "Natureza - Filial Destino" FROM 100,250  TO 400,750 OF oMainWnd PIXEL Style 128
	@ 10, 10 TO 130,240 of oDlg PIXEL
	@ 20, 020 SAY " Natureza....: " SIZE 70,10 of oDlg PIXEL 	
	@ 20, 060 MSGET cCodNat F3 "SED"  VALID ValNat(aTit) SIZE 40,10 PIXEL HASBUTTON
	@ 20, 110 MSGET cNomNat WHEN .F. SIZE 70,10 PIXEL

	@ 40, 020 SAY "Observações: " SIZE 70,10 of oDlg PIXEL 
	oTMultiget := tMultiget():new( 40, 60, {| u | if( pCount() > 0, cObserv := u, cObserv ) }, ;
    oDlg, 120, 60, , , , , , .T. )
    oTMultiget:EnableVScroll( .T. )
    oTMultiget:lReadOnly := .T.
  	@ 20, 200 BUTTON "OK" VALID FnatTudOk(oDlg) SIZE 030, 020 PIXEL OF oDlg ACTION (cNewNatTr := cCodNat, oDlg:End())
	oDlg:lEscClose     := .F. //Nao permite sair ao se pressionar a tecla ESC.
ACTIVATE MSDIALOG oDlg 

RestArea(aArea)

Return(cNewNatTr)

/*/ {Protheus.doc} ValNat
Validar natureza digitada pela fNatNTrf
           
@author Caique
@version P11
@since 12/01/2015
@return Nil
@obs.
@sample 
/*/

Static Function ValNat(aTit)

Local lRet:= .F.  
Local lIrrf := .F.
Local lPis := .F.
Local lCsll := .F.
Local lCofins := .F.
Local lIss		:= .F.
Local lInss	:= .F.
Local lDedInsDes	:= .F. 
Local aAreaSED	:= {}

Local aTaxas	:=  {}

aAdd(aTaxas, {if(lImp,SE2->E2_IRRF,0)   , 	SED->ED_PERCIRF })
aAdd(aTaxas, {if(lImp,SE2->E2_PIS,0)    ,  	SED->ED_PERCPIS })
aAdd(aTaxas, {If(lImp,SE2->E2_CSLL,0)   , 	SED->ED_PERCCSL })
aAdd(aTaxas, {If(lImp,SE2->E2_COFINS,0) , 	SED->ED_PERCCOF })
aAdd(aTaxas, {If(lImp,SE2->E2_ISS,0)	, 	SuperGetMv("MV_ALIQISS",.F.,5, SE6->E6_FILORIG) })
aAdd(aTaxas, {If(lImp,SE2->E2_INSS,0)	, 	SED->ED_PERCINS })

If Empty(Alltrim(cCodNat))
	MSGINFO(STR0041) //"Atenção! Natureza não pode ter o conteúdo em branco!"
	Return lRet
Endif	

aAreaSED := SED->(GetArea())
SED->(dbSetOrder(1))
IF !SED->(dbSeek(xFilial("SED")+cCodNat))
	MSGINFO(STR0027) //"Atenção! Natureza não localizada no cadastro!"
	lRet := .F.
Else 
	If aTaxas[1,1] > 0 .And. SED->ED_CALCIRF = 'S' .And. SED->ED_PERCIRF > 0 .And. SED->ED_PERCIRF == aTaxas[1,2] 
		lRet := .T.	
	ElseIf aTaxas[1,1] == 0 .And. SED->ED_CALCIRF = 'N' 
		lRet := .T.
	ElseIf aTaxas[1,1] > 0 .And. SED->ED_CALCIRF = 'N' 
		lRet := .F.
		MSGINFO(STR0028)//"Atenção! A Natureza não calcula IRRF, selecione outra natureza que calcule. "
	Else 
		MSGINFO(STR0029)//"Atenção! A Natureza calcula IRRF, selecione outra natureza que não calcule. "
		lRet :=.F.
	EndIf
	lIrrf := lRet
	If lRet
		If aTaxas[2,1] > 0 .And. SED->ED_CALCPIS = 'S' .And. SED->ED_PERCPIS > 0 .And. SED->ED_PERCPIS == aTaxas[2,2]
			lRet := .T.
		ElseIf aTaxas[2,1] == 0 .And. SED->ED_CALCPIS = 'N' 
			lRet := .T.
		ElseIf aTaxas[2,1] > 0 .And. SED->ED_CALCPIS = 'N' 
			lRet := .F.
			MSGINFO(STR0030)//"Atenção! A Natureza não calcula PIS, selecione outra natureza que calcule. "
		Else
			lRet := .F.
			MSGINFO(STR0031)//"Atenção! A Natureza calcula PIS, selecione outra natureza que não calcule. "
		EndIf
		lPis := lRet
		If lRet 
			If aTaxas[3,1] > 0 .And. SED->ED_CALCCSL = 'S' .And. SED->ED_PERCCSL > 0 .And. SED->ED_PERCCSL == aTaxas[3,2]
				lRet := .T.
			ElseIf aTaxas[3,1] == 0 .And. SED->ED_CALCCSL = 'N' 
				lRet := .T.
			ElseIf aTaxas[3,1] > 0 .And. SED->ED_CALCCSL = 'N' 
				lRet := .F.
				MSGINFO(STR0032)//"Atenção! A Natureza não calcula CSLL, selecione outra natureza que calcule. "
			Else
				lRet := .F.
				MSGINFO(STR0033)//"Atenção! A Natureza calcula CSLL, selecione outra natureza que não calcule. "
			EndIf
			lCsll := lRet
			If lRet
				If aTaxas[4,1] > 0 .And. SED->ED_CALCCOF = 'S' .And. SED->ED_PERCCOF > 0 .And. SED->ED_PERCCOF == aTaxas[4,2]
					lRet := .T.
				ElseIf aTaxas[4,1] == 0 .And. SED->ED_CALCCOF = 'N' 
					lRet := .T.
				ElseIf aTaxas[4,1] > 0 .And. SED->ED_CALCCOF = 'N' 
					lRet := .F.
					MSGINFO(STR0034)//"Atenção! A Natureza não calcula COFINS, selecione outra natureza que calcule. "
				Else
					lRet := .F.
					MSGINFO(STR0035)//"Atenção! A Natureza calcula COFINS, selecione outra natureza que não calcule. "
				EndIf
				lCofins := lRet
				If lRet
					If aTaxas[6,1] > 0 .And. SED->ED_CALCINS = 'S' .And. SED->ED_PERCINS > 0 .And. SED->ED_PERCINS == aTaxas[6,2]
						lRet := .T.
						lDedInsDes :=  ( SED->ED_DEDINSS == "1" .And. __lDedIns ) .Or. ( SED->ED_DEDINSS <> "1" .And. !__lDedIns )  
						If lRet .And. !lDedInsDes 
							lRet	:= .F.
							MSGINFO(STR0040)//"Atenção! "O campo 'Ded. Inss' está diferente da Natureza origem."	
						EndIf
					ElseIf aTaxas[6,1] == 0 .And. SED->ED_CALCINS = 'N' 
						lRet := .T.
					ElseIf aTaxas[6,1] > 0 .And. SED->ED_CALCINS = 'N' 
						lRet := .F.
						MSGINFO(STR0038)//"Atenção! A Natureza não calcula INSS, selecione outra natureza que calcule. "
					Else
						lRet := .F.
						MSGINFO(STR0039)//"Atenção! A Natureza calcula INSS, selecione outra natureza que não calcule. "
					EndIf
					lInss := lRet
					If lRet
						If !__lMunic
							If SED->ED_CALCISS = 'S' .And. SuperGetMv("MV_ALIQISS",.F.,5, SE6->E6_FILDEB) > 0 
								lRet := .F.
								MSGINFO(STR0037)//"Atenção! A Natureza calcula ISS, selecione outra natureza que não calcule. "
							EndIf	

						Else
							
							If aTaxas[5,1] > 0 .And. SED->ED_CALCISS = 'S' .And. SuperGetMv("MV_ALIQISS",.F.,5, SE6->E6_FILDEB) > 0
								lRet := .T.
							ElseIf aTaxas[5,1] == 0 .And. SED->ED_CALCISS = 'N' 
								lRet := .T.
							ElseIf aTaxas[5,1] > 0 .And. SED->ED_CALCISS = 'N' 
								lRet := .F.
								MSGINFO(STR0036)//"Atenção! A Natureza não calcula ISS, selecione outra natureza que calcule. "
							Else
								lRet := .F.
								MSGINFO(STR0037)//"Atenção! A Natureza calcula ISS, selecione outra natureza que não calcule. "
							EndIf
						EndIf 
						lIss := lRet
					EndIf
				Endif	
			EndIf
		EndIf
	EndIf
	
	If lRet 
		cNomNat := SED->ED_DESCRIC
	EndIF
ENDIF 

RestArea(aAreaSED)                  

Return lRet

/*/{Protheus.doc} FnatTudOk
	Validação da dialog na função fNatNTrf
	@type  Static Function
	@author Vitor Duca
	@since 28/02/2020
	@version 1.0
	@param oDlg, Objeto, Objeto de tela que foi criado
	@return lRet, Logico, Valid dos botões
/*/
Static Function FnatTudOk(oDlg As Object) As Logical
	Local lRet As Logical

	Default oDlg := NIL

	lRet := .T.

	If Empty(Alltrim(cCodNat))
		MSGINFO(STR0041) //"Atenção! Natureza não pode ter o conteúdo em branco!"
		lRet := .F.
	Endif

Return lRet

/*/{Protheus.doc} F631DedIns
	Verifica se a natureza deduz INSS
	@type  Static Function
	@author Vitor Duca
	@since 28/02/2020
	@version 1.0
	@param cNaturez, Caracter, Codigo da natureza a ser verificada
	@return lDeduz, Logico, Define se a natureza deduz ou não
/*/
Static Function F631DedIns(cNaturez As Character) As Logical
	Local lDeduz   As Logical
	Local aAreaSED As Array
	Local cFilSED  As Character

	Default cNaturez := ""

	lDeduz 		:= .F.
	cFilSED     := xFilial("SED")
	aAreaSED	:= SED->(GetArea())

	If !Empty(cFilSED)
		cFilSED := xFilial("SED",SE2->E2_FILORIG)
	Endif

	SED->(dbSetOrder(1))
	If SED->(DbSeek(cFilSED+cNaturez))
		lDeduz	:= SED->ED_DEDINSS == "1"
	EndIf

	RestArea(aAreaSED)
	FwFreeArray(aAreaSED)

Return lDeduz

/*/{Protheus.doc} F631Campos
	Prepara os campos que serão enviados para as funções
	(AXINCLUI, AXDELETA, AXALTERA)
	@type  Static Function
	@author Vitor Duca
	@since 28/02/2020
	@version 1.0
	@param lInsert , Logico, Define se esta sendo chamado pela inserção
	@return aCampos, Array, Matriz contendo os campos (SX3)
/*/
Static Function F631Campos(lAprova As Logical) As Array
	Local aCampos 	As Array
	Local aArea   	As Array
	Local aAreaSx3	As Array

	Default lAprova := .F.

	aCampos  := {}
	aArea	 := GetArea()
	aAreaSx3 := SX3->(GetArea())

	SX3->(dbSetOrder(1))
	SX3->(MsSeek("SE6"))
	While !SX3->(EOF()) .And. (SX3->X3_Arquivo == "SE6")
		If X3USO(SX3->X3_Usado) .And. cNivel >= SX3->X3_NIVEL
			if lAprova
				// Na aprovacao, o historico da rejeicao nao deve ser apresentado
				If AllTrim(SX3->X3_CAMPO) != "E6_HISREJ"
					Aadd(aCampos, SX3->X3_CAMPO)
				Endif
			Else
				// Na rejeicao, o historico da solicitacao nao deve ser apresentado
				If AllTrim(SX3->X3_CAMPO) != "E6_HISTSOL"
					Aadd(aCampos, SX3->X3_CAMPO)
				Endif
			Endif				
		Endif
		SX3->(dbSkip())
	EndDo

	RestArea(aAreaSx3)
	RestArea(aArea)

	FwFreeArray(aArea)
	FwFreeArray(aAreaSx3)

Return aCampos

/*/{Protheus.doc} F631OriIss
	Função responsavel por manter o iss na filial de origem, 
	por se tratar de um imposto municipal, devera ser mantido na filial que o gerou
	@type  Static Function
	@author Vitor Duca
	@since 02/03/2020
	@version 1.0
	@param aTit, Array, Matriz contendo as informações que serão enviadas para a execauto
/*/
Static Function F631OriIss(aTit As Array) As Numeric
	Local nZ 	  As Numeric
	Local nRetIss As Numeric

	Default aTit := {}

	nZ      := 0
	nRetIss := 0

	If __lMunic
		If	(SuperGetMv('MV_MRETISS',.F.,'1',SE6->E6_FILORIG) == '1')						
			nZ := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_ISS"})
			If nZ > 0
				nRetIss	:= aTit[nZ][2]
			EndIf
		EndIf
	Else
		// Se os municipios forem diferentes nao deve realizar a transferencia do imposto	
		nZ := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_VRETISS"})
		If nZ > 0
			aTit[nZ][2] := 0
		Endif

		nZ := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_ISS"})
		If nZ > 0
			aTit[nZ][2] := 0
		Endif

		nZ := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_VBASISS"})
		If nZ > 0
			aTit[nZ][2] := 0
		Endif

		nZ := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_BASEISS"})
		If nZ > 0
			aTit[nZ][2] := 0
		Endif
	Endif		

Return nRetIss

/*/{Protheus.doc} FMunicFil
	Verifica se as filiais envolvidas na transferencia
	estam localizadas no mesmo municipio para tratamento da transferencia do ISS
	@type  Static Function
	@author Vitor Duca
	@since 02/03/2020
	@version 1.0
/*/
Static Function FMunicFil() As Logical
	Local lRet     As Logical
	Local aFilorig As Array
	Local aFilDeb  As Array

	lRet := .F.

	aFilorig := FWSM0Util():GetSM0Data(,SE6->E6_FILORIG, { "M0_CODMUN" } )
	aFilDeb  := FWSM0Util():GetSM0Data(, SE6->E6_FILDEB, { "M0_CODMUN" } )

	If Alltrim(aFilorig[1][2]) == Alltrim(aFilDeb[1][2])
		lRet := .T.
	Elseif FindFunction("FinHelp")
		FIN_ISSMUNIC()
	Endif		

Return lRet

/*/{Protheus.doc} FIN_ISSMUNIC
Montagem do HELP no processo de transferencia
@type  Static Function
@author Vitor Duca
@since 02/03/2020
@version 1.0
@return 
/*/
static function FIN_ISSMUNIC()
	Local cMsg 		AS Character
	Local cTitulo 	AS Character
	Local aBtLinks 	AS Array

	cTitulo  := "Aprovação e rejeição de transferência"
	aBtLinks := ARRAY(2,2)

	cMsg := "<font size='6' color='#0c9abe'><b>HELP - ISSMUNIC</b></font><br/><br/>"

	cMsg += "<font size='4' color='#444'><b>Ocorrência</b></font><br/>"
	cMsg += "<font size='4' color='#666'>Verificamos no processo de transferencia a retenção do imposto ISS (Imposto sobre serviços)<br/>"
	cMsg += "<font size='4' color='#666'>por se tratar de filiais com o municipio diferente o imposto não será transferido </font><br/>"
	cMsg += "</font><br/><br/>"

	cMsg += "<font size='4' color='#444'><b>Solução</b></font><br/>"
	cMsg += "<font size='4' color='#666'>Para a correta transferencia do imposto de ISS, as filiais devem estar dentro do mesmo municipio (M0_CODMUN) </font><br/><br/>"

	cMsg += "<font size='4' color='#444'><b>Para maiores informações acesse:</b></font>"
	cMsg += "<br/><br/>"

	aBtLinks[1,1] := "Transferencia de titulos com ISS"
	aBtLinks[1,2] := "https://tdn.totvs.com/x/xRw9I"

	FinHelp(cTitulo, cMsg, aBtLinks, 300, 600)

Return

/*/{Protheus.doc} F631Impos
	Verifica titulos de impostos retidos na emissão do titulo da 
	filial origem, para realizar a baixa (MV_IMPTRAN = 2)
	@type  Static Function
	@author Vitor Duca
	@since 05/03/2020
	@version 1.0
/*/
Static Function F631Impos()
	Local lBxImp	 As Logical
	Local cNatIss	 As Character
	Local aAreaSE2	 As Array
	Local aImpos     As Array
	Local cQry       As Character

	lBxImp	 	:= .T.
	cNatIss	 	:= AllTrim(&(GetMv("MV_ISS")))
	aAreaSE2	:= SE2->(GetArea())
	aImpos     	:= {}
	cQry       	:= ""

	cQry := " SELECT E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_VALOR, E2_NATUREZ "
	cQry += " FROM "+RetSqlName("SE2")+" SE2 "
	cQry += " WHERE E2_TITPAI = '"+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)+"' "
	cQry += " AND E2_FILIAL = '"+SE2->E2_FILIAL+"' AND D_E_L_E_T_ = ' '  AND E2_SALDO > 0"

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TIMP",.F.,.T.)
	TCSetField("TIMP", "E2_VALOR" ,"N",14,2)
	TIMP->(dbGotop())

	Do While TIMP->(!Eof())
		lBxImp := .T.

		If AllTrim(TIMP->E2_NATUREZ) == cNatIss .and. !__lMunic
			lBxImp := .F.
		Endif

		If lBxImp	
			aImpos := {}		
			AADD(aImpos , {"E2_PREFIXO"	, TIMP->E2_PREFIXO, NIL})
			AADD(aImpos , {"E2_NUM"			, TIMP->E2_NUM	, NIL})
			AADD(aImpos , {"E2_PARCELA"	, TIMP->E2_PARCELA, NIL})
			AADD(aImpos , {"E2_TIPO"		, TIMP->E2_TIPO	, NIL})
			AADD(aImpos , {"E2_FORNECE"	, TIMP->E2_FORNECE, NIL})
			AADD(aImpos , {"E2_LOJA"		, TIMP->E2_LOJA	, NIL})
			AADD(aImpos , {"AUTMOTBX"		, "TRF"			, NIL})
			AADD(aImpos , {"AUTDTBAIXA"	, dDataBase		, NIL})
			AADD(aImpos , {"AUTHIST"		, STR0018 + SE6->E6_FILORIG + " p/" + SE6->E6_FILDEB,NIL}) 	
		
			MSExecAuto({|x, y| FINA080(x, y)}, aImpos, 3)

			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
				Break
			EndIf

		Endif

		TIMP->(dbSkip())			
	EndDo

	TIMP->(DbCloseArea())
	RestArea(aAreaSE2)	

Return 

/*/{Protheus.doc} F631RecVl
	Recomposição do valor e saldo do titulos quando os impostos estiverem na emissão
	@type  Static Function
	@author Vitor Duca
	@since 06/03/2020
	@version 1.0
	@param aTit, Array, Matriz contendo as informações do titulo que sera transferido
/*/
Static Function F631RecVl(aTit As Array)
	Local nImp 		 As Numeric
	Local nVlImp     As Numeric
	Local nAux1		 As Numeric
	Local nAux2		 As Numeric
	
	nVlImp	:= 0
	nImp	:= 0
	nAux1	:= 0
	nAux2	:= 0

	//ISS
	nVlImp += F631OriIss(@aTit)

	//PCC
	If	(SuperGetMv('MV_BX10925',.F.,'1',SE6->E6_FILORIG) == '2')						
		nImp		:= Ascan(aTit, {|e| AllTrim(e[1]) == "E2_PIS"})
		If nImp > 0
			nVlImp	+= aTit[nImp][2]
		Endif
		nImp		:= Ascan(aTit, {|e| AllTrim(e[1]) == "E2_COFINS"})
		If nImp > 0
			nVlImp	+= aTit[nImp][2]
		Endif
		nImp		:= Ascan(aTit, {|e| AllTrim(e[1]) == "E2_CSLL"})
		If nImp > 0
			nVlImp	+= aTit[nImp][2]
		Endif
	EndIf

	//INSS
	If	(SuperGetMv('MV_INSBXCP',.F.,'1',SE6->E6_FILORIG) == '2')						
		nImp		:= Ascan(aTit, {|e| AllTrim(e[1]) == "E2_INSS"})
		If nImp > 0 .And. __lDedIns
			nVlImp	+= aTit[nImp][2]
		Endif
	EndIf

	//IRRF
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(xFilial("SA2")+SE6->E6_CLIENTE+SE6->E6_LOJA))
		If SA2->A2_CALCIRF == "1"				
			nImp		:= Ascan(aTit, {|e| AllTrim(e[1]) == "E2_IRRF"})
			If nImp > 0
				nVlImp	+= aTit[nImp][2]
			Endif
		EndIf
	EndIf

	nAux1	:= Ascan(aTit, {|e| AllTrim(e[1]) == "E2_VALOR"})
	nAux2	:= Ascan(aTit, {|e| AllTrim(e[1]) == "E2_SALDO"})
		
	If (nVlImp > 0) .and. (nAux1 > 0) .and. (nAux2 > 0) 
		aTit[nAux1][2] += nVlImp
		aTit[nAux2][2] := aTit[nAux1][2] // Atualiza o Saldo
	Endif

Return 

/*/{Protheus.doc} F631SemImp
	Retira os impostos retidos na emissão se o parametro MV_IMPTRAN = 1
	para evitar duplicidade entre as filiais
	@type  Static Function
	@author Vitor Duca
	@since 06/03/2020
	@version 1.0
	@param aTit, Array, Matriz contendo as informações do titulo que sera incluido (Filial Destino)
/*/
Static Function F631SemImp(aTit As Array)
	Local nLimpa As Numeric

	nLimpa := 0

	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_DIRF"})
	If nLimpa > 0
		aTit[nLimpa][2] := "2" 
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_IRRF"})
	If nLimpa > 0
		aTit[nLimpa][2] := 0
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_INSS"})
	If nLimpa > 0
		aTit[nLimpa][2] := 0
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_COFINS"})
	If nLimpa > 0
		aTit[nLimpa][2] := 0
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_PIS"})
	If nLimpa > 0
		aTit[nLimpa][2] := 0
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_CSLL"})
	If nLimpa > 0
		aTit[nLimpa][2] := 0
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_VRETPIS"})
	If nLimpa > 0
		aTit[nLimpa][2] := 0
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_VRETCOF"})
	If nLimpa > 0
		aTit[nLimpa][2] := 0
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_VRETCSL"})
	If nLimpa > 0
		aTit[nLimpa][2] := 0
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_VRETINS"})
	If nLimpa > 0
		aTit[nLimpa][2] := 0
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_VRETIRF"})
	If nLimpa > 0
		aTit[nLimpa][2] := 0
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_BASEIRF"})
	If nLimpa > 0
		aTit[nLimpa][2] := 0
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_BASEINS"})
	If nLimpa > 0
		aTit[nLimpa][2] := 0
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_PRETPIS"})
	If nLimpa > 0
		aTit[nLimpa][2] := ''
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_PRETCOF"})
	If nLimpa > 0
		aTit[nLimpa][2] := ''
	Endif
	nLimpa := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_PRETCSL"})
	If nLimpa > 0
		aTit[nLimpa][2] := ''
	Endif
	nZ := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_VRETISS"})
	If nZ > 0
		aTit[nZ][2] := 0
	Endif
	nZ := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_ISS"})
	If nZ > 0
		aTit[nZ][2] := 0
	Endif
	nZ := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_VBASISS"})
	If nZ > 0
		aTit[nZ][2] := 0
	Endif
	nZ := Ascan(aTit, {|e| AllTrim(e[1]) == "E2_BASEISS"})
	If nZ > 0
		aTit[nZ][2] := 0
	Endif

Return 
